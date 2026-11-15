#!/usr/bin/env python3
"""probe.py — the masher diagnosis (diag/masher-vs-easy.md): CPU tier vs the masher (or any two tiers) on dev seeds, both seats, with
probe.lisp's counters and the combat log parsed per side. Tool side only.

  python3 docs/research/strategy-drsi/sp/diag/probe.py --hi easy --lo masher [--pairs KK,KI,...] [--seed0 500] [--seeds 20] [-j 18]
        [--set '*knob*=value;...']   (a load-time binding through PROBE_SET, never a source edit)
        [--lift 'normal=hard:@style,*ai-delay*;...']   (PROBE_LIFT: a difficulty's values copied to another, probe.lisp)
-> per cell and over all cells: the higher tier's share, then per side (hi / lo) per match: move starts by class, hits and damage by
   class, combos opened, neutral first moves and how many of them led to his own opener, state shares, Konpaku taken by Kikon / Soul
   Break, Bursts, awakenings, Hoho / perfect Hoho, cancels, refused SPs. --json writes the totals.
"""
import argparse, collections, json, os, re, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '../../../../../tools')))
from simlib import ROOT, ROW, build, pool, row_ko, run_lisp

RUNNER = os.path.relpath(os.path.join(HERE, 'probe.lisp'), os.path.join(ROOT, 'tools'))
ROSTER = {'K': 1, 'I': 3, 'H': 7}
TICK = re.compile(r'^\[\s*(\d+)\] (P[12]) (.*)$')
PSTAT = re.compile(r'^pstat (\d+) (P[12]) st (.*?) on(.*?) k(.*?) deaf (\d+) hold (\d+) open (\d+) hits (\d+) first (\d+) firstwin (\d+) dmg (\d+) ticks (\d+)')


def mclass(name):
    """A move name's triangle class: SA when a part is SA / SA1 (IC-SA, KE-S-SA, HS-SA-KIRI, HS-R-SA-G), else from its last part (J1 /
    NA3 NA, N1A NS, AS1), else 'other'. (Before arms5/clash2.md the bare SA names and Hisagi's NA3 / NA4 fell to 'other'.)"""
    parts = name.split('-')
    if any(re.fullmatch(r'SA\d*', p) for p in parts[1:]):
        return 'SA'
    t = parts[-1]
    for pre, c in (('AS', 'AS'), ('J', 'NA'), ('NA', 'NA'), ('N', 'NS')):
        if re.fullmatch(pre + r'\d+[A-Z]?', t):
            return c
    return 'other'


def parse(out):
    """One process's stdout -> {seed: {'winner': w, 'ko': k, 'P1': Counter, 'P2': Counter}}."""
    ms = collections.OrderedDict()
    cur = None
    last_hit = {}
    # The exchange accounting (arms5/clash2.md): an exchange is a run of cancels each within 60 ticks of the last (a step's two verdicts,
    # the J and the NS cancelling in turn); it is "from S's clash" (thrown class cto) when S logged `cpu clash` in the 40 ticks before
    # its first cancel, and ends with the first real hit (BREAK fs, CORE-BREAK!: xwin_<class> for the hitter) or with none (x_none).
    xt = clasher = cto = None
    clash_t = {}

    def x_none():
        if xt is not None and cur is not None:
            for sd in ('P1', 'P2'):
                cur[sd]['x_none'] += 1
            if clasher:
                cur[clasher]['xc_none_' + cto] += 1
    for l in out.splitlines():
        m = re.match(r'duel match seed (\d+)', l)
        if m:
            x_none(); xt = clasher = None; clash_t = {}
            cur = ms.setdefault(int(m[1]), {'P1': collections.Counter(), 'P2': collections.Counter()})
            continue
        m = ROW.search(l)
        if m:
            ms[int(m[1])].update(winner=m[2], ko=row_ko(l))
            x_none(); xt = clasher = None
            continue
        m = PSTAT.match(l)
        if m:
            c = ms[int(m[1])][m[2]]
            for kv in m[3].split():
                k, v = kv.split(':'); c['st_' + k] += int(v)
            for kv in m[4].split():
                k, v = kv.split(':'); c['on_' + k] += int(v)
            for kv in m[5].split():
                k, v = kv.split(':'); c['k_' + k] += int(v)
            for k, v in zip(('deaf', 'hold', 'open', 'hits', 'first', 'firstwin', 'dmg', 'ticks'), m.groups()[5:]):
                c[k] += int(v)
            continue
        m = TICK.match(l)
        if not m or cur is None:
            continue
        side, rest, t = m[2], m[3], int(m[1])
        c = cur[side]
        if rest.endswith(': CANCEL') and t != xt:
            cs = [sd for sd, (ct, _) in clash_t.items() if 0 <= t - ct <= 40]
            if cs or xt is None or t - xt > 60:          # a fresh exchange (else the open one goes on: a restamp)
                x_none()
                clasher = max(cs, key=lambda sd: clash_t[sd][0]) if cs else None
                cto = clash_t[clasher][1] if clasher else None
                if clasher:
                    cur[clasher]['xc_open_' + cto] += 1
            clash_t = {}
            xt = t
        elif rest.startswith('BREAK fs') and xt is not None:
            c['xwin_' + last_hit.get(side, '?')] += 1
            if clasher:
                cur[clasher][('xc_won_' if clasher == side else 'xc_lost_') + cto] += 1
            xt = clasher = None
        if rest.startswith('move '):
            c['start_' + mclass(rest.split()[1])] += 1
        elif re.match(r'(\S+) -> P[12] HIT (\d+)', rest):
            mm = re.match(r'(\S+) -> P[12] HIT (\d+)', rest)
            k = 'counter' if mm[1] == 'COUNTER' else mclass(mm[1]) if '-' in mm[1] else 'hazard'
            c['hit_' + k] += 1; last_hit[side] = k
        elif rest.startswith('dealt '):
            c['dmg_' + last_hit.get(side, '?')] += int(re.match(r'dealt (\d+)', rest)[1])
        elif ' konpaku, ' in rest:
            mm = re.match(r'(SOUL BREAK|KIKON) on P[12]: -(\d+) konpaku', rest)
            c['kp_' + ('soulbreak' if mm[1] == 'SOUL BREAK' else 'kikon')] += int(mm[2])
            c['n_' + ('soulbreak' if mm[1] == 'SOUL BREAK' else 'kikon')] += 1
        elif rest.startswith('BURST END'):
            pass
        elif rest.startswith('BURST '):
            c['burst'] += 1; c['burst_' + rest.split()[1].lower()] += 1
        elif rest.startswith('AWAKEN') or rest.startswith('BANKAI ('):
            c['awaken'] += 1
        elif ' paid ' in rest and rest.startswith('SP '):
            mm = re.search(r'fs ([\d.]+) cost ([\d.]+) paid ([\d.]+) x([\d.]+)', rest)
            c['sp_start'] += 1; c['sp_cost'] += float(mm[2]); c['sp_paid'] += float(mm[3])
            if float(mm[2]) == 0: c['sp_free'] += 1
            elif float(mm[4]) < 0.999: c['sp_scaled'] += 1
        elif rest == 'hoho':
            c['hoho'] += 1
        elif rest == 'PERFECT HOHO':
            c['perfect'] += 1
        elif rest.startswith('step'):
            c['step'] += 1
        elif rest.endswith(': CANCEL'):
            c['cancel'] += 1
        elif ': ABSORBED' in rest:
            c['absorbed'] += 1
        elif 'refused' in rest:
            c['refused'] += 1
        elif rest.startswith('lets go: no Kikon'):
            c['letgo'] += 1
        elif rest.startswith('KIKON FOLLOW-UP'):
            c['kfollow'] += 1
        elif rest.startswith('cpu clash'):
            mm = re.match(r'cpu clash (\w+) into his \w+ at ([\d.]+)', rest)
            c['clash'] += 1; c[f"clash_{mm[1]}_{'lt3' if float(mm[2]) < 3.0 else 'ge3'}"] += 1
            clash_t[side] = (t, mm[1])
        elif rest.startswith('cpu xch'):
            c['xch'] += 1
        elif rest.startswith('cpu holds'):
            c['holds'] += 1
        elif rest.startswith('BREAK fs'):
            c['fsbreak'] += 1
    return ms


def job(j):
    a, b, hs, hi, lo, s0, n, kset, lift = j
    env = dict(os.environ, **{f'STRAT_DIF_P{hs}': hi, f'STRAT_DIF_P{3 - hs}': lo}, PROBE_SET=kset or '', PROBE_LIFT=lift or '')
    r = run_lisp(RUNNER, [30000 + s0, 31100 + n, 81022, 200000 + 100 * ROSTER[a] + 10 * ROSTER[b]], env=env, timeout=4 * 3600)
    ms = parse(r.stdout)
    if r.returncode or len(ms) != n or any('winner' not in m for m in ms.values()):
        sys.exit(f'probe: job {j} gave {len(ms)} of {n} (exit {r.returncode}): {r.stderr[-600:]}')
    return j, ms


KEYS = ['start_NA', 'start_NS', 'start_AS', 'start_SA', 'start_other', 'step', 'hoho', 'perfect', 'burst', 'awaken',
        'open', 'hits', 'first', 'firstwin', 'dmg', 'hit_NA', 'hit_NS', 'hit_AS', 'hit_SA', 'hit_counter', 'hit_other', 'hit_hazard',
        'dmg_NA', 'dmg_NS', 'dmg_AS', 'dmg_SA', 'dmg_counter', 'dmg_other', 'dmg_hazard', 'kp_kikon', 'kp_soulbreak', 'n_kikon',
        'n_soulbreak', 'kfollow', 'letgo', 'cancel', 'absorbed', 'clash', 'xch', 'refused', 'holds', 'fsbreak',
        'xwin_NA', 'xwin_NS', 'xwin_AS', 'xwin_SA', 'xwin_counter', 'xwin_hazard', 'x_none',
        'clash_na_lt3', 'clash_na_ge3', 'clash_ns_lt3', 'clash_ns_ge3', 'xc_open_na', 'xc_won_na', 'xc_lost_na', 'xc_none_na',
        'xc_open_ns', 'xc_won_ns', 'xc_lost_ns', 'xc_none_ns']


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--hi', default='easy'); ap.add_argument('--lo', default='masher')
    ap.add_argument('--pairs', default=','.join(a + b for a in 'KIH' for b in 'KIH'))
    ap.add_argument('--seed0', type=int, default=500); ap.add_argument('--seeds', type=int, default=20)
    ap.add_argument('-j', type=int, default=18); ap.add_argument('--set', default=''); ap.add_argument('--lift', default='')
    ap.add_argument('--json'); ap.add_argument('--quiet', action='store_true')
    o = ap.parse_args()
    build()
    jobs = []
    for me, op in o.pairs.split(','):
        for hs in (1, 2):
            a, b = (me, op) if hs == 1 else (op, me)
            for k in range(0, o.seeds, 50):
                jobs.append((a, b, hs, o.hi, o.lo, o.seed0 + k, min(50, o.seeds - k), o.set, o.lift))
    cells = collections.OrderedDict()
    tot = {'hi': collections.Counter(), 'lo': collections.Counter(), 'n': 0, 'pts': 0.0, 'bell': 0}
    for (a, b, hs, *_), ms in pool(job, jobs, o.j):
        cell = (a + b) if hs == 1 else (b + a)
        c = cells.setdefault(cell, {'n': 0, 'pts': 0.0, 'bell': 0})
        for m in ms.values():
            w = m['winner']
            pt = 1.0 if w == f'P{hs}' else 0.0 if w == f'P{3 - hs}' else 0.5
            for t in (c, tot):
                t['n'] += 1; t['pts'] += pt; t['bell'] += 1 - m['ko']
            tot['hi'].update(m[f'P{hs}']); tot['lo'].update(m[f'P{3 - hs}'])
            c.setdefault('hi', collections.Counter()).update(m[f'P{hs}']); c.setdefault('lo', collections.Counter()).update(m[f'P{3 - hs}'])
    print(f"{o.hi} vs {o.lo}, seeds {o.seed0 + 1}-{o.seed0 + o.seeds}, both seats{'; set ' + o.set if o.set else ''}{'; lift ' + o.lift if o.lift else ''}")
    print('cell ' + ' '.join(f'{k:>6s}' for k in cells) + '    all')
    print('share' + ' '.join(f"{c['pts'] / c['n']:6.3f}" for c in cells.values()) + f"  {tot['pts'] / tot['n']:.3f}  (n {tot['n']}, bell {tot['bell']})")
    print('bell ' + ' '.join(f"{c['bell']:6d}" for c in cells.values()) + f"  {tot['bell']}  (matches at the bell, of {tot['n'] // len(cells)} a cell)")
    if not o.quiet:
        n = tot['n']
        print(f'{"per match":14s} {o.hi:>9s} {o.lo:>9s}')
        for k in KEYS:
            print(f'{k:14s} {tot["hi"][k] / n:9.2f} {tot["lo"][k] / n:9.2f}')
        st = sorted({k for t in ('hi', 'lo') for k in tot[t] if k.startswith('st_')})
        for t in ('hi', 'lo'):
            s = sum(tot[t][k] for k in st)
            print(f'{t} state share ' + ' '.join(f'{k[3:]} {tot[t][k] / s:.3f}' for k in st))
    if o.json:
        with open(o.json, 'w') as f:
            json.dump(dict(hi=o.hi, lo=o.lo, seed0=o.seed0, seeds=o.seeds, set=o.set, lift=o.lift, n=tot['n'], share=tot['pts'] / tot['n'],
                           cells={k: c['pts'] / c['n'] for k, c in cells.items()}, bells={k: c['bell'] for k, c in cells.items()},
                           per_match={t: {k: tot[t][k] / tot['n'] for k in sorted(tot[t])} for t in ('hi', 'lo')}), f, indent=1)


if __name__ == '__main__':
    main()

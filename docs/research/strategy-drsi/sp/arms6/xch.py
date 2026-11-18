#!/usr/bin/env python3
"""xch.py — q3-xch (arms6/xch.md): does the exchange after a cancel have situational value? An oracle test one layer under §8.5's: per cue
bin, each exchange option's mean outcome (randomised: the explored decisions only) against what the shipped exchange unit plays there.

  python3 xch.py log PAIR [--seeds 1-500] [--salt 11] [--eps 0.3] [-j 6]
  python3 xch.py tab PAIR [--seeds 1-500] [--y dh|dhs] [--boot 200] [--min 20]
  python3 xch.py ab PAIR --char kenpachi [--rule own|ownj|hold] [--seeds 301-500]   (a match-level check: STRAT_XPOL)

PAIR = ki | kh (the gate's character order is both ways: 200000 + 100 a + 10 b and b a). The logs: tools/simgate/strat-run.lisp STRAT_XLOG
"<salt> <eps> <seat>", HARD vs HARD on the shipped lookup tables, one exploring seat a run (his answers stay the shipped CPU's), so four runs a
pair: {a b, b a} x {seat 1, seat 2}. Logs under build/xch/ (ignored); a compact copy of the explored decisions goes to xch/xch-<pair>.tsv.gz.

The estimate: whether a decision explores is a hash coin, and the explored option is uniform over the side's legal ones, so the explored
decisions of a bin are a randomised comparison of the options there. Y = the change of MC-FULL-HEALTH mine - his (the teacher's unit: Konpaku
+ 1.5 x the Reishi bar) from the decision to the exchange's end (dh: both back in neutral, cap 900 ticks) or to the first change of the
exchange's own key (dhs: a fresh cancel or the end). Per bin b and option o: m(b, o). The shipped unit's value V(b) = sum_o pi_b(o) m(b, o),
pi = its logged chances (pas / pj, pw / pc) averaged over the bin. Reported, weighted by the bins' shares w(b) of the side's decisions:
  const = max_o sum_b w m(b, o) - sum_b w V(b)        a better flat unit (no situation needed)
  situ  = cross-validated: the best option per bin picked on odd seeds, scored on even seeds, minus the best flat option picked on odd
          seeds, scored on even seeds (and swapped); only this is situational value. A bin with fewer than --min explored samples of an
          option keeps the flat option.
SEs: a bootstrap over matches (seed x character order)."""
import argparse, collections, gzip, os, re, sys
import numpy as np
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '../../../../../tools')))
from simlib import ROOT, build, pool, run_lisp  # noqa: E402

ROSTER = {'k': 1, 'i': 3, 'h': 7}
NAME = {'k': 'kenpachi', 'i': 'ichigo', 'h': 'hisagi'}
LOGS = os.path.join(ROOT, 'build/xch')
FIELDS = ('seed t0 P char role pick ship ex fs ofs ptr optr red ored kon okon r or d form oform awk oawk time arm own asok reach pas pj pw pc '
          'mv omv dt dh ts dhs dk dr drf dfs brk bt osa end').split()


def seeds_of(s):
    a, b = (int(x) for x in s.split('-'))
    assert 1 <= a <= b <= 500, 'seeds: 1-500 only here (501-600 the lead, 801-1000 held out)'
    return a, b


def job(j):
    gate, seat, s0, n, salt, eps, path = j
    env = dict(os.environ, STRAT_DIF_P1='hard', STRAT_DIF_P2='hard', STRAT_XLOG=f'{salt} {eps} {seat}')
    r = run_lisp('simgate/strat-run.lisp', [30000 + s0, 31100 + n, 81022, gate], env=env, timeout=6 * 3600)
    if r.returncode:
        sys.exit(f'xch: {path}: exit {r.returncode}\n{r.stderr[-2000:]}')
    lines = [l for l in r.stdout.splitlines() if l.startswith('xd ') or l.startswith('duel gate row')]
    with gzip.open(path, 'wt') as f:
        f.write('\n'.join(lines) + '\n')
    return path


def runs(pair, a0, a1):
    a, b = pair[0], pair[1]
    for x, y in ((a, b), (b, a)):
        gate = 200000 + 100 * ROSTER[x] + 10 * ROSTER[y]
        for seat in (1, 2):
            for s0 in range(a0 - 1, a1, 50):
                n = min(50, a1 - s0)
                yield gate, seat, s0, n, os.path.join(LOGS, f'{x}{y}-s{seat}-{s0 + 1}-{s0 + n}.txt.gz')


def cmd_log(o):
    a0, a1 = seeds_of(o.seeds)
    build()
    os.makedirs(LOGS, exist_ok=True)
    jobs = [(g, s, s0, n, o.salt, o.eps, p) for g, s, s0, n, p in runs(o.pair, a0, a1)]
    for p in pool(job, jobs, o.j):
        print('xch: wrote', os.path.relpath(p, ROOT), flush=True)


def ab_job(j):
    gate, seat, s0, n, rule = j
    env = dict(os.environ, STRAT_DIF_P1='hard', STRAT_DIF_P2='hard', STRAT_XLOG='11 0')
    if rule != 'shipped':
        env['STRAT_XPOL'] = f'{seat} {rule}'
    r = run_lisp('simgate/strat-run.lisp', [30000 + s0, 31100 + n, 81022, gate], env=env, timeout=6 * 3600)
    if r.returncode:
        sys.exit(f'xch ab: exit {r.returncode}\n{r.stderr[-2000:]}')
    return j, [l for l in r.stdout.splitlines() if l.startswith('duel gate row')]


def cmd_ab(o):
    """The match-level check of a J-side rule (STRAT_XPOL) for CHAR against the shipped CPU, both character orders: CHAR's wins and K.O. wins."""
    a0, a1 = seeds_of(o.seeds)
    build()
    me = o.char[0]
    him = o.pair[1] if o.pair[0] == me else o.pair[0]
    jobs = []
    for rule in ('shipped', o.rule):
        for x, y, seat in ((me, him, 1), (him, me, 2)):
            gate = 200000 + 100 * ROSTER[x] + 10 * ROSTER[y]
            for s0 in range(a0 - 1, a1, 50):
                jobs.append((gate, seat, s0, min(50, a1 - s0), rule))
    res = collections.defaultdict(lambda: [0, 0, 0])
    for (gate, seat, s0, n, rule), rows in pool(ab_job, jobs, o.j):
        for l in rows:
            t = l.split()
            win = t[t.index('winner') + 1] == f'P{seat}'
            ko = l.rstrip().endswith('ko 1')
            res[rule][0] += 1
            res[rule][1] += win
            res[rule][2] += win and ko
    print(f'xch ab {o.pair} {NAME[me]} J-side rule {o.rule} vs shipped, HARD vs HARD, seeds {a0}-{a1}, both orders')
    for rule in ('shipped', o.rule):
        n, w, k = res[rule]
        p = w / n
        print(f'{rule:>8}: {NAME[me]} wins {w} / {n} = {p:.3f} (SE {np.sqrt(p * (1 - p) / n):.3f}), K.O. wins {k}')


def parse_line(l):
    t = l.split()
    d = {'seed': int(t[1]), 't0': int(t[2]), 'P': t[3], 'char': t[4], 'role': t[5]}
    i = 6
    while i < len(t):
        if t[i] == 'out':
            i += 1
            continue
        d[t[i]] = t[i + 1]
        i += 2
    return d


def load(pair, a0, a1):
    """-> list of dict rows: every decision of the exploring seat's runs (the explorer's own and his opponent's), with 'xseat' and 'order'."""
    rows = []
    for gate, seat, s0, n, p in runs(pair, a0, a1):
        order = os.path.basename(p)[:2]
        with gzip.open(p, 'rt') as f:
            for l in f:
                if l.startswith('xd '):
                    d = parse_line(l)
                    d['xseat'] = f'P{seat}'
                    d['order'] = order
                    rows.append(d)
    for d in rows:
        for k in ('fs', 'ofs', 'r', 'or', 'd', 'time', 'pas', 'pj', 'pw', 'pc', 'dh', 'dhs', 'drf', 'dfs'):
            d[k] = float(d[k])
        for k in ('ptr', 'optr', 'red', 'ored', 'kon', 'okon', 'awk', 'oawk', 'own', 'asok', 'reach', 'ex', 'dt', 'ts', 'dk', 'dr', 'bt', 'osa'):
            d[k] = int(d[k])
        d['match'] = (d['order'], d['seed'])
    return rows


def pi_of(d, o):
    """The shipped unit's chance of option O at decision D."""
    if d['role'] == 'j':
        return {'as': d['pas'], 'j': d['pj'], 'hold': max(0.0, 1.0 - d['pas'] - d['pj'])}[o]
    w, c = int(o[1]), int(o[3])
    return (d['pw'] if w else 1 - d['pw']) * (d['pc'] if c else 1 - d['pc'])


def opts_of(role):
    return ('as', 'j', 'hold') if role == 'j' else ('w1c1', 'w1c0', 'w0c1', 'w0c0')


def cell(x, lo, hi):
    return 0 if x <= lo else (1 if x <= hi else 2)


PARTS = {   # single-cue partitions (the bins), from the decider's view
    'all': lambda d: '-',
    'mfs': lambda d: ('<=100', '100-200', '>200')[cell(d['fs'], 100.5, 200.5)],          # my stake: what a break by him takes
    'ofs': lambda d: ('<=100', '100-200', '>200')[cell(d['ofs'], 100.5, 200.5)],         # his stake: what my break takes
    'red': lambda d: f"me{d['red']}",
    'ored': lambda d: f"him{d['ored']}",
    'ptr': lambda d: f"me{d['ptr']}",
    'optr': lambda d: f"him{d['optr']}",
    'dist': lambda d: ('<1.5', '1.5-2.5', '>2.5')[cell(d['d'], 1.5, 2.5)],
    'lead': lambda d: ('behind', 'even', 'ahead')[1 + (d['kon'] > d['okon']) - (d['kon'] < d['okon'])],
    'own': lambda d: f"own{d['own']}",
    'form': lambda d: f"{d['form']}/{d['oform']}",
    'time': lambda d: ('<.33', '.33-.66', '>.66')[cell(d['time'], 0.33, 0.66)],
}
PARTS['owndist'] = lambda d: PARTS['own'](d) + ' ' + PARTS['dist'](d)   # (two crossings with the strongest single cue)
PARTS['ownform'] = lambda d: PARTS['own'](d) + ' ' + PARTS['form'](d)


def side_rows(rows, char, role):
    """The decisions of CHAR in ROLE made by the exploring seat's CPU (his opponent's are pure shipped play)."""
    return [d for d in rows if d['char'] == char and d['role'] == role and d['P'] == d['xseat']]


class Side:
    """One side's decisions as arrays: the match index (for the bootstrap), the seed's parity (the CV halves), explored, the option played,
    Y, the shipped unit's chances per option."""
    def __init__(self, rs, opts, y):
        self.opts, self.rs = opts, rs
        keys = sorted({d['match'] for d in rs})
        ix = {k: i for i, k in enumerate(keys)}
        self.nm = len(keys)
        self.mi = np.array([ix[d['match']] for d in rs])
        self.par = np.array([d['seed'] % 2 for d in rs])
        self.ex = np.array([d['ex'] for d in rs], dtype=float)
        self.opt = np.array([opts.index(d['pick']) for d in rs])
        self.y = np.array([d[y] for d in rs])
        self.pi = np.array([[pi_of(d, o) for o in opts] for d in rs])
        self.oh = np.eye(len(opts))[self.opt] * self.ex[:, None]      # explored one-hot

    def bins(self, part):
        labs = [PARTS[part](d) for d in self.rs]
        names = sorted(set(labs))
        return names, np.array([names.index(x) for x in labs])


def stats(s, bi, nb, w):
    """Per bin (BI of NB) under row weights W: the share W(b), m(b, o) and its explored count n(b, o), the shipped chances pi(b, o)."""
    K = len(s.opts)
    wb = np.bincount(bi, weights=w, minlength=nb)
    share = wb / max(1e-12, wb.sum())
    n = np.zeros((nb, K))
    sy = np.zeros((nb, K))
    pi = np.zeros((nb, K))
    for k in range(K):
        n[:, k] = np.bincount(bi, weights=w * s.oh[:, k], minlength=nb)
        sy[:, k] = np.bincount(bi, weights=w * s.oh[:, k] * s.y, minlength=nb)
        pi[:, k] = np.bincount(bi, weights=w * s.pi[:, k], minlength=nb) / np.maximum(1e-12, wb)
    with np.errstate(invalid='ignore', divide='ignore'):
        m = sy / n
    return share, m, n, pi


def filled(m, n):
    """m with an option never explored in a bin set to the bin's mean over the others (0 when none)."""
    f = m.copy()
    for b in range(m.shape[0]):
        ok = n[b] > 0
        f[b, ~ok] = f[b, ok].mean() if ok.any() else 0.0
    return f


def gains(s, bi, nb, w, min_n):
    """(shipped V, the best flat option's value, const, situ): const = a better flat unit than the shipped one; situ = the CV gain of a
    per-bin pick (odd seeds pick, even seeds score, and swapped) over the best flat option picked the same way."""
    share, m, n, pi = stats(s, bi, nb, w)
    f = filled(m, n)
    vs = float((share * (pi * f).sum(1)).sum())
    vf = (share[:, None] * f).sum(0)
    out = []
    for a in (0, 1):
        sa = stats(s, bi, nb, w * (s.par == a))
        sb = stats(s, bi, nb, w * (s.par != a))
        fa, fb = filled(sa[1], sa[2]), filled(sb[1], sb[2])
        flat = int(np.argmax((sa[0][:, None] * fa).sum(0)))
        pick = np.where((sa[2] >= min_n).all(1), np.argmax(np.where(sa[2] > 0, fa, -np.inf), 1), flat)
        out.append(float((sb[0] * (fb[np.arange(nb), pick] - fb[:, flat])).sum()))
    return vs, float(vf.max()), float(vf.max()) - vs, float(np.mean(out))


def boot_w(s, rng):
    return np.bincount(rng.integers(0, s.nm, s.nm), minlength=s.nm)[s.mi].astype(float)


def joint(rows, side_rs, opts):
    """My explored option x his shipped pick in the same exchange (his record with the same match and decision tick): mean Y and n."""
    his = {(d['match'], d['t0']): d for d in rows if d['P'] != d['xseat']}
    tab = collections.defaultdict(list)
    for d in side_rs:
        if d['ex']:
            h = his.get((d['match'], d['t0']))
            tab[(d['pick'], h['pick'] if h else '-')].append(d)
    return tab


def cmd_tab(o):
    a0, a1 = seeds_of(o.seeds)
    rows = load(o.pair, a0, a1)
    rng = np.random.default_rng(1)
    write_tsv(o.pair, rows)
    print(f'xch {o.pair}: seeds {a0}-{a1}, {len(rows)} decisions logged (both seats of the four runs), Y = {o.y}, '
          f'bootstrap {o.boot} over matches, min {o.min} explored samples an option a bin for a per-bin pick')
    ends = collections.Counter(d['end'] for d in rows)
    print('ends:', dict(ends), f"(cap share {ends['cap'] / len(rows):.3f})")
    summary = []
    for char in (NAME[o.pair[0]], NAME[o.pair[1]]):
        for role in ('j', 'ns'):
            rs = side_rows(rows, char, role)
            if not rs:
                continue
            opts = opts_of(role)
            s = Side(rs, opts, o.y)
            print(f'\n=== {char} {role.upper()} side: {len(rs)} decisions of the exploring seat, {int(s.ex.sum())} explored ===')
            print('shipped picks:', dict(collections.Counter(d['ship'] for d in rs)),
                  ' mean pi:', {x: round(float(v), 3) for x, v in zip(opts, s.pi.mean(0))})
            print('option profile (explored): option | n | dh | dhs | dk (Konpaku) | drf (Reishi bars) | dfs (flash-step) | him first % | me first % | '
                  'his SA before it % | dt')
            for x in opts:
                e = [d for d in rs if d['ex'] and d['pick'] == x]
                if e:
                    mean = lambda k: float(np.mean([d[k] for d in e]))
                    print(f'{x:>6} | {len(e)} | {mean("dh"):+.3f} | {mean("dhs"):+.3f} | {mean("dk"):+.3f} | {mean("drf"):+.3f} | {mean("dfs"):+.1f} | '
                          f'{100 * np.mean([d["brk"] == "him" for d in e]):.0f} | {100 * np.mean([d["brk"] == "me" for d in e]):.0f} | '
                          f'{100 * mean("osa"):.0f} | {mean("dt"):.0f}')
            bws = [boot_w(s, rng) for _ in range(o.boot)]
            one = np.ones(len(rs))
            for part in o.parts.split(','):
                names, bi = s.bins(part)
                nb = len(names)
                share, m, n, pi = stats(s, bi, nb, one)
                vship = (pi * filled(m, n)).sum(1)
                def mv(w):   # (a resample's option means and shipped value per bin)
                    st = stats(s, bi, nb, w)
                    return np.concatenate([st[1], (st[3] * filled(st[1], st[2])).sum(1)[:, None]], 1)
                bm = np.array([mv(w) for w in bws]) if bws else None
                se = np.nanstd(bm, axis=0) if bm is not None else np.full((nb, len(opts) + 1), np.nan)
                print(f'-- {part}: bin | w | ' + ' | '.join(f'{x} mean (SE) n him%' for x in opts) + ' | shipped V (SE) | best (>= min)')
                for b in range(nb):
                    hims = [him_rate(rs, part, names[b], x) for x in opts]
                    cells = ' | '.join(f'{m[b, k]:+.3f} ({se[b, k]:.3f}) {int(n[b, k])} {hims[k]}' for k in range(len(opts)))
                    ok = [k for k in range(len(opts)) if n[b, k] >= o.min]
                    best = opts[max(ok, key=lambda k: m[b, k])] if ok else '-'
                    print(f'{names[b]:>15} | {share[b]:.3f} | {cells} | {vship[b]:+.3f} ({se[b, -1]:.3f}) | {best}')
                g = gains(s, bi, nb, one, o.min)
                gb = np.array([gains(s, bi, nb, w, o.min) for w in bws]) if bws else None
                gse = gb.std(axis=0) if gb is not None else np.full(4, np.nan)
                print(f'   shipped V {g[0]:+.4f} ({gse[0]:.4f})  best flat {g[1]:+.4f}  const {g[2]:+.4f} (SE {gse[2]:.4f})  '
                      f'situ (CV) {g[3]:+.4f} (SE {gse[3]:.4f})')
                summary.append((char, role, part, g[2], gse[2], g[3], gse[3]))
            tab = joint(rows, rs, opts)
            hp = sorted({k[1] for k in tab})
            print('-- my explored option x his shipped pick (same exchange): mean Y (n) him%')
            for x in opts:
                print(f'{x:>6} | ' + ' | '.join(f'{h}: {np.mean([d[o.y] for d in tab[(x, h)]]):+.3f} ({len(tab[(x, h)])}) '
                                                  f'{100 * np.mean([d["brk"] == "him" for d in tab[(x, h)]]):.0f}' for h in hp if tab[(x, h)]))
    print('\n=== summary: const (a better flat unit) and situ (CV, over the best flat option), per side and cue ===')
    for char, role, part, c, cs, si, ss in summary:
        print(f'{char:>9} {role:>2} {part:>5} | const {c:+.4f} ({cs:.4f}) | situ {si:+.4f} ({ss:.4f}){"  *" if ss > 0 and si > 2.5 * ss else ""}')


def him_rate(rs, part, b, o):
    """Share of the explored decisions with option O in bin B where he hit first (brk him), in %."""
    v = [d['brk'] == 'him' for d in rs if d['ex'] and d['pick'] == o and PARTS[part](d) == b]
    return f'{100 * np.mean(v):.0f}' if v else '-'


def write_tsv(pair, rows):
    keep = [k for k in FIELDS if k not in ('arm',)] + ['arm', 'xseat', 'order']
    p = os.path.join(HERE, 'xch', f'xch-{pair}.tsv.gz')
    with gzip.open(p, 'wt') as f:
        f.write('\t'.join(keep) + '\n')
        for d in rows:
            if d['ex'] and d['P'] == d['xseat']:
                f.write('\t'.join(str(d.get(k, '')) for k in keep) + '\n')


def main():
    ap = argparse.ArgumentParser()
    sp = ap.add_subparsers(dest='cmd', required=True)
    lg = sp.add_parser('log')
    lg.add_argument('pair')
    lg.add_argument('--seeds', default='1-500')
    lg.add_argument('--salt', type=int, default=11)
    lg.add_argument('--eps', type=float, default=0.3)
    lg.add_argument('-j', type=int, default=6)
    tb = sp.add_parser('tab')
    tb.add_argument('pair')
    tb.add_argument('--seeds', default='1-500')
    tb.add_argument('--y', default='dh')
    tb.add_argument('--boot', type=int, default=200)
    tb.add_argument('--min', type=int, default=20)
    tb.add_argument('--parts', default='all,mfs,ofs,red,ored,ptr,optr,dist,lead,own,form,time,owndist,ownform')
    ab = sp.add_parser('ab')
    ab.add_argument('pair')
    ab.add_argument('--char', required=True)
    ab.add_argument('--rule', default='own')
    ab.add_argument('--seeds', default='301-500')
    ab.add_argument('-j', type=int, default=6)
    o = ap.parse_args()
    {'log': cmd_log, 'tab': cmd_tab, 'ab': cmd_ab}[o.cmd](o)


if __name__ == '__main__':
    main()

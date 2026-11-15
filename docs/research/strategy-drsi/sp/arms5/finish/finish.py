#!/usr/bin/env python3
"""finish.py — the late-match finish (arms5/finish.md; the user, 2026-11-15: 「加「後段收尾」行為」): bar D (HARD vs HARD K.O. rate) and the
points per row on seeds 141-180, both seats (80 matches a row), and the stall diagnosis.

  python3 finish.py bar [--set shipped,a5h] [--seed0 140] [--env K=V] [-j 20] [--tag T] [--log FILE] [--switch]   # K.O. rate, points, bell
  (--switch, arms5/tables2.md: every judgement logged, STRAT_FQLOG "0 0" as ladder.py --switch, play unchanged; each side's median arm
   changes a match, bar A)
  python3 finish.py diag --row ROW [--secs 90] [-j 20]                       # the late-match trace (diag-run.lisp) of ROW's time-outs
  python3 finish.py onset --row ROW                                          # per time-out: the last move start, the Konpaku then

Rows: shipped (no STRAT_: each HARD CPU plays the game's lookup) ki kh ih kk ii hh; a5h (arms5's final tables, arms5/t0/, against each
other as inband.md §5 played them) kh5 ih5 hh5. Env SP_BUILD: refuse another sim build. Cache: build/finish-cache (keyed by the build and
the runner, the env texts, the commands)."""
import argparse, collections, hashlib, json, os, re, statistics, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import simlib  # noqa: E402

SEED0, SEEDS = 140, 40
R = {'kenpachi': 1, 'ichigo': 3, 'hisagi': 7}
T5 = os.path.join(HERE, '../t0')
CACHE = os.path.join(ROOT, 'build/finish-cache')
STRAT = 'simgate/strat-run.lisp'
DIAG = os.path.relpath(os.path.join(HERE, 'diag-run.lisp'), os.path.join(ROOT, 'tools'))
# row -> (character on side A, side B, table A, table B): None = the game's lookup
ROWS = {'ki': ('kenpachi', 'ichigo', None, None), 'kh': ('kenpachi', 'hisagi', None, None), 'ih': ('ichigo', 'hisagi', None, None),
        'kk': ('kenpachi', 'kenpachi', None, None), 'ii': ('ichigo', 'ichigo', None, None), 'hh': ('hisagi', 'hisagi', None, None),
        'kh5': ('kenpachi', 'hisagi', 't0-kh-kenpachi.lisp', 't0-kh-hisagi.lisp'),
        'ih5': ('ichigo', 'hisagi', 't0-ih-ichigo.lisp', 't0-ih-hisagi.lisp'),
        'hh5': ('hisagi', 'hisagi', 't0-hh-hisagi.lisp', 't0-hh-hisagi.lisp')}
SETS = {'shipped': ['ki', 'kh', 'ih', 'kk', 'ii', 'hh'], 'a5h': ['kh5', 'ih5', 'hh5']}
ROWRE = re.compile(r'duel gate row seed (\d+) \S+ \S+ secs ([\d.]+) winner (\S+).* ko ([01])$')


def pin():
    h = simlib.build_hash(os.path.join(ROOT, 'tools', STRAT))
    want = os.environ.get('SP_BUILD')
    if want and not h.startswith(want):
        sys.exit(f'finish: sim build {h[:12]} is not SP_BUILD {want}')
    return h


def run(job):
    """One sim process -> its stdout lines (cached)."""
    runner, c1, c2, env, keep = job
    texts = {k: (open(v).read() if os.path.isfile(v) else v) for k, v in sorted(env.items())}
    cmds = [30000 + SEED0, 31100 + SEEDS, 81022, 200000 + 100 * c1 + 10 * c2]
    key = hashlib.sha1(json.dumps([simlib.build_hash(os.path.join(ROOT, 'tools', STRAT), os.path.join(ROOT, 'tools', runner)), texts, cmds,
                                   keep]).encode()).hexdigest()[:20]
    path = os.path.join(CACHE, key + '.out')
    if os.path.exists(path):
        return open(path).read().splitlines()
    e = {k: v for k, v in os.environ.items() if not k.startswith(('STRAT_', 'FIN_'))}
    e.update(env)
    r = simlib.run_lisp(runner, cmds, e, timeout=7200)
    out = [l for l in r.stdout.splitlines() if l.startswith(tuple(keep))]
    rows = sum(l.startswith('duel gate row ') for l in out)
    if r.returncode or rows != SEEDS:
        sys.exit(f'finish: sim exited {r.returncode}, {rows} of {SEEDS} rows\n' + (r.stdout + r.stderr)[-2000:])
    os.makedirs(CACHE, exist_ok=True)
    with open(path + '.tmp', 'w') as f:
        f.write('\n'.join(out) + '\n')
    os.replace(path + '.tmp', path)
    return out


def jobs(row, runner=STRAT, extra=None, keep=('duel gate row ',)):
    """Both seats of ROW: [(seat of side A, job)]."""
    a, b, ta, tb = ROWS[row]
    out = []
    for seat in ('P1', 'P2'):
        env = dict(extra or {})
        c1, c2 = (R[a], R[b]) if seat == 'P1' else (R[b], R[a])
        if ta:
            other = 'P2' if seat == 'P1' else 'P1'
            env.update({'STRAT_' + seat: os.path.join(T5, ta), 'STRAT_' + other: os.path.join(T5, tb)})
        out.append((seat, (runner, c1, c2, env, list(keep))))
    return out


def cmd_bar(o):
    global SEED0
    SEED0 = o.seed0
    h = pin()
    rows = [r for s in o.set.split(',') for r in SETS.get(s, [s])]
    extra = dict(x.split('=', 1) for x in o.env)
    keep = ('duel gate row ',)
    if o.switch:
        extra['STRAT_FQLOG'] = '0 0'; keep += ('fq ',)
    js = [(row, seat, j) for row in rows for seat, j in jobs(row, extra=extra, keep=keep)]
    outs = simlib.pool(run, [j for _, _, j in js], o.j)
    acc = collections.OrderedDict()
    chg = collections.defaultdict(lambda: {'a': [], 'b': []})
    for (row, seat, _), lines in zip(js, outs):
        c = acc.setdefault(row, collections.Counter())
        seq = collections.defaultdict(list)                     # ((seed, seat) -> the arms judged, in order), ladder.py's count
        for m in map(FQ.match, lines):
            if m:
                seq[(int(m[1]), m[2])].append(int(m[3]))
        for (_, st), v in seq.items():
            chg[row]['a' if st == seat else 'b'].append(sum(1 for i in range(1, len(v)) if v[i] != v[i - 1]))
        for m in map(ROWRE.search, lines):
            if not m:
                continue
            w, ko = m[3], int(m[4])
            pa = 1.0 if w == seat else 0.0 if w in ('P1', 'P2') else 0.5
            c['n'] += 1; c['ko'] += ko; c['pa'] += pa
            if not ko:
                c['bell_a' if pa == 1 else 'bell_b' if pa == 0 else 'bell_draw'] += 1
            c['secs'] += float(m[2])
    print(f'finish bar, build {h[:12]}, seeds {SEED0 + 1}-{SEED0 + SEEDS} both seats, HARD vs HARD' + (f', {o.tag}' if o.tag else ''))
    print('row  | A        B        |  n | K.O.  | points A | bell: A ahead / B ahead / draw | mean secs' + (' | changes med A / B (zero)' if o.switch else ''))
    res = []
    for row, c in acc.items():
        a, b = ROWS[row][:2]
        r = dict(tag=o.tag, build=h[:12], seeds=f'{SEED0 + 1}-{SEED0 + SEEDS}', row=row, a=a, b=b, n=c['n'], ko_rate=round(c['ko'] / c['n'], 3), points_a=round(c['pa'] / c['n'], 3),
                 bell_a=c['bell_a'], bell_b=c['bell_b'], bell_draw=c['bell_draw'], secs=round(c['secs'] / c['n'], 1))
        if o.switch:
            for sd in ('a', 'b'):
                v = chg[row][sd]
                r[f'changes_{sd}'] = dict(median=statistics.median(v), zero=sum(x == 0 for x in v), matches=len(v)) if v else None
        res.append(r)
        sw = ''.join(f" {'/' if sd == 'b' else '|'} " + (f"{r['changes_' + sd]['median']} ({r['changes_' + sd]['zero']})" if r['changes_' + sd] else '-')
                     for sd in ('a', 'b')) if o.switch else ''
        print(f"{row:4s} | {a:8s} {b:8s} | {r['n']:2d} | {r['ko_rate']:.3f} | {r['points_a']:.3f}    | {r['bell_a']:2d} / {r['bell_b']:2d} / {r['bell_draw']:2d}"
              f"                   | {r['secs']}{sw}")
    if o.log:
        with open(o.log, 'a') as f:
            for r in res:
                f.write(json.dumps(r) + '\n')


FQ = re.compile(r'^fq (\d+) \d+ (P\d) .* arm (\d+) ')   # (ladder.py's: a judgement's seed, seat, pick)
FIN = re.compile(r'^fin (\d+) ([\d.]+) (P\d) lead (-?\d+) rp ([\d.]+) orp ([\d.]+) d ([\d.]+) st (\S+) form (\S+) arm (\S+) fn (\S+)')
FMV = re.compile(r'^fmv (\d+) ([\d.]+) (P\d) (\S+) d ([\d.]+)')


def cmd_diag(o):
    pin()
    js = jobs(o.row, DIAG, {'FIN_SECS': str(o.secs), 'STRAT_FQLOG': '0 0'}, ('duel gate row ', 'fin ', 'fmv '))
    outs = simlib.pool(run, [j for _, j in js], o.j)
    a, b = ROWS[o.row][:2]
    tot = collections.Counter()
    for (seat, _), lines in zip(js, outs):
        other = 'P2' if seat == 'P1' else 'P1'
        name = {seat: 'A:' + a, other: 'B:' + b}
        res = {int(m[1]): (m[3], int(m[4])) for m in map(ROWRE.search, lines) if m}
        fins = collections.defaultdict(list)
        mvs = collections.defaultdict(list)
        for l in lines:
            m = FIN.match(l)
            if m:
                fins[int(m[1])].append(m)
            m = FMV.match(l)
            if m:
                mvs[int(m[1])].append(m)
        for seed, (w, ko) in sorted(res.items()):
            if ko and not o.all:
                continue
            fs = fins[seed]
            last = [m for m in fs if float(m[2]) <= o.window]
            if not last:
                continue
            end = {m[3]: m for m in fs[-2:]}
            lead = lambda p: (int(end[p][4]), float(end[p][5]) - float(end[p][6])) if p in end else (0, 0)
            ahead = seat if lead(seat) > (0, 0) else other if lead(seat) < (0, 0) else None
            print(f"seed {seed} seat-A {seat} winner {w} ko {ko} | at the bell: ahead {name.get(ahead, 'even')} lead A {lead(seat)[0]} "
                  f"reishi% A-B {lead(seat)[1]:+.2f}")
            for p in (seat, other):
                mine = [m for m in last if m[3] == p]
                ds = [float(m[7]) for m in mine]
                arms = collections.Counter(m[10] for m in mine)
                fns = collections.Counter(m[11] for m in mine)
                sts = collections.Counter(m[8] for m in mine)
                forms = collections.Counter(m[9] for m in mine)
                mv = [m for m in mvs[seed] if m[3] == p and float(m[2]) <= o.window]
                mvc = collections.Counter(m[4] for m in mv)
                print(f"   {name[p]:11s} d med {statistics.median(ds):.2f} [{min(ds):.1f}-{max(ds):.1f}] states {dict(sts.most_common(4))} "
                      f"forms {dict(forms)} arms {dict(arms)} fns {dict(fns)}")
                print(f"   {'':11s} moves {len(mv)}: {dict(mvc.most_common(8))}")
                tot[(name[p], 'moves')] += len(mv); tot[(name[p], 'n')] += 1
    for (who, k), v in sorted(tot.items()):
        if k == 'moves':
            print(f"{who}: mean moves in the last {o.window:.0f} s of a time-out: {v / max(1, tot[(who, 'n')]):.1f}")


FINK = re.compile(r'^fin (\d+) ([\d.]+) (P\d) .* k (\d+) ok (\d+)$')


def cmd_onset(o):
    """Per time-out of ROW (the trace over the whole match): when the last move of either side started (s left on the timer; the freeze's
    onset when the rest is a stare), the Konpaku then (A-B), and the K.O. matches' pace (s of play per Konpaku taken, both sides)."""
    pin()
    js = jobs(o.row, DIAG, {'FIN_SECS': '300', 'STRAT_FQLOG': '0 0'}, ('duel gate row ', 'fin ', 'fmv '))
    outs = simlib.pool(run, [j for _, j in js], o.j)
    onsets, pace = [], []
    for (seat, _), lines in zip(js, outs):
        res = {int(m[1]): (float(m[2]), m[3], int(m[4])) for m in map(ROWRE.search, lines) if m}
        lastmv, ks = {}, collections.defaultdict(list)
        for l in lines:
            m = FMV.match(l)
            if m:
                lastmv[int(m[1])] = float(m[2])
            m = FINK.match(l)
            if m and m[3] == seat:
                ks[int(m[1])].append((float(m[2]), int(m[4]), int(m[5])))
        for seed, (secs, w, ko) in sorted(res.items()):
            k = ks[seed]
            if ko:
                pace.append(secs / max(1, (9 - k[-1][1]) + (9 - k[-1][2])))
                continue
            t = lastmv.get(seed, 300.0)
            at = min(k, key=lambda r: abs(r[0] - t))
            onsets.append((t, at[1], at[2]))
            print(f'seed {seed} seat-A {seat}: last move start {t:5.1f} s left, Konpaku then A {at[1]} B {at[2]}, at the bell A {k[-1][1]} B {k[-1][2]}')
    if onsets:
        ts = sorted(t for t, _, _ in onsets)
        print(f'{o.row}: {len(onsets)} time-outs; last move start (s left) median {statistics.median(ts):.1f}, quartiles '
              f'{ts[len(ts) // 4]:.1f} / {ts[3 * len(ts) // 4]:.1f}; stares > 30 s: {sum(t > 30 for t in ts)}')
        print(f'{o.row}: the trailing side\'s Konpaku at the onset: {dict(sorted(collections.Counter(min(a, b) for _, a, b in onsets).items()))}')
    if pace:
        print(f'{o.row}: K.O. matches {len(pace)}, s of play per Konpaku taken: median {statistics.median(pace):.1f}')


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    sub = ap.add_subparsers(dest='cmd', required=True)
    p = sub.add_parser('bar'); p.add_argument('--set', default='shipped,a5h'); p.add_argument('-j', type=int, default=20)
    p.add_argument('--seed0', type=int, default=140, help='the block: seeds SEED0+1 .. SEED0+40 (default 141-180)')
    p.add_argument('--tag', default=''); p.add_argument('--log'); p.add_argument('--env', action='append', default=[], help='K=V for the sims (e.g. STRAT_SET=...)')
    p.add_argument('--switch', action='store_true', help='log every judgement (STRAT_FQLOG "0 0") and report each side\'s arm changes a match')
    p = sub.add_parser('diag'); p.add_argument('--row', required=True); p.add_argument('--secs', type=int, default=90)
    p.add_argument('--window', type=float, default=60.0); p.add_argument('--all', action='store_true'); p.add_argument('-j', type=int, default=20)
    p = sub.add_parser('onset'); p.add_argument('--row', required=True); p.add_argument('-j', type=int, default=20)
    o = ap.parse_args()
    simlib.build()
    {'bar': cmd_bar, 'diag': cmd_diag, 'onset': cmd_onset}[o.cmd](o)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""ladder.py — the difficulty ladder (PLAN4 §1 bar B, §5; the user, 2026-11-15: 「請設計讓勝率能做到 hard > normal > easy > 亂按，對上前一階
難度的對手能獲得至少 70:30 的勝率」). 27 cells = 9 ordered (higher tier's character, lower tier's character) pairings, mirrors included,
x 3 rungs (HARD > NORMAL, NORMAL > EASY, EASY > masher), each on both seats over one seed block: tools/simgate/strat-run.lisp's pairing
gate (200000 + 100 c1 + 10 c2) with STRAT_DIF_P<n> per seat (`masher`: duel/lisp/masher.lisp).

  python3 docs/research/strategy-drsi/sp/ladder.py [--seed0 500] [--seeds 100] [--rungs hn,ne,em] [--pairs KK,KI,...] [-j 12]
                                                   [--json FILE]
  -> a table on stdout and the cells as JSON (default build/ladder/ladder-<seed0>-<seeds>-<rungs>.json).

A match's result is the game's own (the gate row's winner: a K.O., or at the bell more Konpaku, then Reishi %); a draw counts half (the
user: 「照遊戲判定」). Per cell: the higher tier's share, its one-sided 95 % Wilson lower bound, pass iff that bound >= 0.70 (400 matches:
>= 296 points; 200: >= 151), the time-outs (rows with `ko 0`), flagged (not failed) above 25 %.
Seed blocks (PLAN4 §1): 501-600 dev (--seed0 500 --seeds 100), 801-1000 the final once (--seed0 800 --seeds 200), 601-800 spent. A job
plays at most 50 seeds (the gate's 31100+n takes n <= 99: a larger n is a silent no-op), and each job's row count is checked. Env SP_BUILD
(a round's pin, PLAN4 §7): refuse a different sim build.
"""
import argparse, collections, json, math, os, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '../../../../tools')))
from simlib import ROOT, ROW, build, build_hash, pool, row_ko, run_lisp

RUNNER = 'simgate/strat-run.lisp'
ROSTER = {'K': 1, 'I': 3, 'H': 7}                           # kit.lisp *ROSTER* indices: Kenpachi, Ichigo, Hisagi
RUNGS = {'hn': ('hard', 'normal'), 'ne': ('normal', 'easy'), 'em': ('easy', 'masher'),
         'nm': ('normal', 'masher'), 'hm': ('hard', 'masher')}   # (the last two: context only, not ladder cells)
Z = 1.645                                                   # one-sided 95 %
BAR = 0.70
CHUNK = 50


def wilson_lo(points, n, z=Z):
    """The one-sided Wilson lower bound of a share POINTS / N (draws as half points)."""
    if n == 0:
        return 0.0
    p = points / n
    return (p + z * z / (2 * n) - z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))) / (1 + z * z / n)


# the rule's own check: 296 of 400 and 151 of 200 are the least that pass (PLAN4 §1 B)
assert wilson_lo(296, 400) >= BAR > wilson_lo(295, 400) and wilson_lo(151, 200) >= BAR > wilson_lo(150, 200)


def job(j):
    """One strat-run process: P1 character a, P2 b, the higher tier on seat hs, seeds s0+1 .. s0+n -> (j, [(winner, ko)])."""
    a, b, hs, rung, s0, n = j
    hi, lo = RUNGS[rung]
    env = dict(os.environ, **{f'STRAT_DIF_P{hs}': hi, f'STRAT_DIF_P{3 - hs}': lo})
    r = run_lisp(RUNNER, [30000 + s0, 31100 + n, 81022, 200000 + 100 * ROSTER[a] + 10 * ROSTER[b]], env=env, timeout=6 * 3600)
    rows = [(m[2], row_ko(l)) for l in r.stdout.splitlines() for m in [ROW.search(l)] if m]
    if r.returncode or len(rows) != n or any(k is None for _, k in rows):
        sys.exit(f'ladder: job {j} gave {len(rows)} rows of {n} (exit {r.returncode}): {r.stderr[-800:]}')
    return j, rows


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--seed0', type=int, default=500)
    ap.add_argument('--seeds', type=int, default=100)
    ap.add_argument('--rungs', default='hn,ne,em')
    ap.add_argument('--pairs', default=','.join(a + b for a in 'KIH' for b in 'KIH'), help='higher tier character + lower, e.g. KI')
    ap.add_argument('-j', type=int, default=12)
    ap.add_argument('--json')
    o = ap.parse_args()
    rungs = o.rungs.split(',')
    pairs = o.pairs.split(',')
    build()
    want = os.environ.get('SP_BUILD')
    if want and not build_hash(os.path.join(ROOT, 'tools', RUNNER)).startswith(want):
        sys.exit(f'ladder: sim build {build_hash(os.path.join(ROOT, "tools", RUNNER))[:12]} is not SP_BUILD {want}')
    chunks = [(o.seed0 + k, min(CHUNK, o.seeds - k)) for k in range(0, o.seeds, CHUNK)]
    jobs = []
    for rung in rungs:
        for me, op in pairs:
            for hs in (1, 2):                                    # the higher tier on P1, then on P2
                a, b = (me, op) if hs == 1 else (op, me)
                jobs += [(a, b, hs, rung, s0, n) for s0, n in chunks]
    cells = collections.OrderedDict()
    for (a, b, hs, rung, s0, n), rows in pool(job, jobs, o.j):
        me, op = (a, b) if hs == 1 else (b, a)
        c = cells.setdefault((rung, me + op), collections.Counter())
        for w, ko in rows:
            who = 'hi' if w == f'P{hs}' else 'lo' if w == f'P{3 - hs}' else 'draw'
            c[who] += 1; c['n'] += 1; c['bell'] += 1 - ko
            c[f'{who}-seat{hs}'] += 1; c[f'n-seat{hs}'] += 1
    out = []
    print(f'ladder seeds {o.seed0 + 1}-{o.seed0 + o.seeds}, both seats; share = (wins + draws/2) / n; pass = one-sided 95 % Wilson low >= {BAR}')
    print('rung   cell  |   n | hi : lo : draw  | share  wilson | pass | bell (flag > 25 %) | share hi on P1 / P2')
    for (rung, cell), c in cells.items():
        n = c['n']; pts = c['hi'] + 0.5 * c['draw']; lo = wilson_lo(pts, n)
        s1 = (c['hi-seat1'] + 0.5 * c['draw-seat1']) / max(1, c['n-seat1'])
        s2 = (c['hi-seat2'] + 0.5 * c['draw-seat2']) / max(1, c['n-seat2'])
        flag = c['bell'] > 0.25 * n
        row = dict(rung=rung, hi=RUNGS[rung][0], lo=RUNGS[rung][1], cell=cell, n=n, hi_wins=c['hi'], lo_wins=c['lo'], draws=c['draw'],
                   share=round(pts / n, 4), wilson_lo=round(lo, 4), passed=lo >= BAR, bell=c['bell'], bell_flag=flag,
                   share_p1=round(s1, 4), share_p2=round(s2, 4))
        out.append(row)
        print(f"{rung:2s} {RUNGS[rung][0][0].upper()}>{RUNGS[rung][1][0].upper()} {cell:4s} | {n:3d} | {c['hi']:3d} : {c['lo']:3d} : {c['draw']:2d} "
              f"| {pts / n:.3f}  {lo:.3f} | {'PASS' if lo >= BAR else 'fail'} | {c['bell']:3d}{' FLAG' if flag else ''} | {s1:.2f} / {s2:.2f}")
    print(f"{sum(r['passed'] for r in out)} of {len(out)} cells pass")
    path = o.json or os.path.join(ROOT, 'build/ladder', f'ladder-{o.seed0}-{o.seeds}-{"".join(rungs)}.json')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        json.dump(dict(seed0=o.seed0, seeds=o.seeds, build=build_hash(os.path.join(ROOT, 'tools', RUNNER)), cells=out), f, indent=1)
    print(f'json {os.path.relpath(path, ROOT)}')


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""lad.py — arms6/hh: the HH ladder cells with the bell / K.O. split, plus the parity rungs (ladder.py's job, its seeds and pass rule).

  python3 lad.py [TABLE|-] [--seed0 500] [--seeds 100] [--rungs hn,ne,em,nn,hh] [-j 12]
TABLE: a raw table file both seats play (STRAT_P1 / STRAT_P2, every difficulty); '-' = the game's lookup. Per cell: the higher tier's
share and Wilson bound (parity rungs: P1's tier = 'hi', the share is .5 by construction, read the K.O. rate), its K.O. wins, the lower
tier's K.O. wins, the bell count and the higher tier's points at the bell."""
import argparse, collections, os, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '../..'))
import ladder  # noqa: E402

ladder.RUNGS.update({'nn': ('normal', 'normal'), 'hh': ('hard', 'hard'), 'ee': ('easy', 'easy')})
ap = argparse.ArgumentParser()
ap.add_argument('table', nargs='?', default='-')
ap.add_argument('--seed0', type=int, default=500); ap.add_argument('--seeds', type=int, default=100)
ap.add_argument('--rungs', default='hn,ne,em,nn,hh'); ap.add_argument('-j', type=int, default=12)
o = ap.parse_args()
if o.table != '-':
    os.environ['STRAT_P1'] = os.environ['STRAT_P2'] = os.path.abspath(o.table)
ladder.build()
jobs = [('H', 'H', hs, r, o.seed0 + k, min(ladder.CHUNK, o.seeds - k)) for r in o.rungs.split(',') for hs in (1, 2)
        for k in range(0, o.seeds, ladder.CHUNK)]
cells = collections.OrderedDict()
for (a, b, hs, rung, s0, n), rows, _ in ladder.pool(ladder.job, jobs, o.j):
    c = cells.setdefault(rung, collections.Counter())
    for w, ko in rows:
        who = 'hi' if w == f'P{hs}' else 'lo' if w == f'P{3 - hs}' else 'draw'
        c['n'] += 1; c[who] += 1
        c[('ko_' if ko else 'bell_') + who] += 1
print(f"HH cells, seeds {o.seed0 + 1}-{o.seed0 + o.seeds} both seats, table {o.table}, build {ladder.build_hash(os.path.join(ladder.ROOT, 'tools', ladder.RUNNER))[:12]}")
print('rung      | n   | share  wilson | pass | K.O. rate | K.O. hi : lo | bell n, hi : lo : draw')
for rung, c in cells.items():
    pts = c['hi'] + 0.5 * c['draw']; lo = ladder.wilson_lo(pts, c['n']); h, l = ladder.RUNGS[rung]
    bell = c['bell_hi'] + c['bell_lo'] + c['bell_draw']
    print(f"{rung} {h[0].upper()}>{l[0].upper()} HH | {c['n']} | {pts / c['n']:.3f}  {lo:.3f} | {'PASS' if lo >= ladder.BAR else 'fail'} | "
          f"{1 - bell / c['n']:.3f}     | {c['ko_hi']:3d} : {c['ko_lo']:3d}    | {bell:3d}, {c['bell_hi']} : {c['bell_lo']} : {c['bell_draw']}")

#!/usr/bin/env python3
"""ih.py — batch p9-ih's measurement (arms6/ih.md): the Ichigo / Hisagi cells of ladder.py's ladder plus the parity rungs, with the
bell / K.O. split per cell. Reuses ladder.job (strat-run.lisp, STRAT_DIF_P<n> per seat, the game's lookup); a table under test is
played by both of its character's tiers through STRAT_ICHIGO / STRAT_HISAGI (env, as strat-run reads it).

  python3 ih.py [--cells hn:IH,hn:HI,ne:IH,ne:HI,em:IH,em:HI,nn:IH,hh:IH] [--seed0 500] [--seeds 100] [-j 10] [--ichigo FILE]
                [--hisagi FILE] [--json OUT]
-> per cell: share of the first-named character (the higher tier on hn / ne / em; Ichigo at parity), Wilson low, pass, at the bell n
   and the first-named's points there, K.O.s and his K.O. wins.
"""
import argparse, collections, json, os, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..'))
import ladder  # noqa: E402
from simlib import build, pool  # noqa: E402

ladder.RUNGS.update(nn=('normal', 'normal'), hh=('hard', 'hard'))
CELLS = 'hn:IH,hn:HI,ne:IH,ne:HI,em:IH,em:HI,nn:IH,hh:IH'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--cells', default=CELLS)
    ap.add_argument('--seed0', type=int, default=500)
    ap.add_argument('--seeds', type=int, default=100)
    ap.add_argument('-j', type=int, default=10)
    ap.add_argument('--ichigo'); ap.add_argument('--hisagi')
    ap.add_argument('--json')
    o = ap.parse_args()
    for k, v in (('STRAT_ICHIGO', o.ichigo), ('STRAT_HISAGI', o.hisagi)):
        if v:
            os.environ[k] = v if v == 'none' else os.path.abspath(v)
    build()
    cells = [tuple(c.split(':')) for c in o.cells.split(',')]
    chunks = [(o.seed0 + k, min(ladder.CHUNK, o.seeds - k)) for k in range(0, o.seeds, ladder.CHUNK)]
    jobs = [((me, op) if hs == 1 else (op, me)) + (hs, rung, s0, n) for rung, (me, op) in cells for hs in (1, 2) for s0, n in chunks]
    acc = collections.OrderedDict(((r, p), collections.Counter()) for r, p in cells)
    for (a, b, hs, rung, s0, n), rows, _ in pool(ladder.job, jobs, o.j):
        c = acc[(rung, (a + b) if hs == 1 else (b + a))]
        for w, ko in rows:
            pt = 1.0 if w == f'P{hs}' else 0.0 if w == f'P{3 - hs}' else 0.5
            c['n'] += 1; c['pts'] += pt
            if ko:
                c['ko'] += 1; c['kowin'] += pt
            else:
                c['bell'] += 1; c['bellpts'] += pt
    out = []
    print(f'seeds {o.seed0 + 1}-{o.seed0 + o.seeds} both seats; ichigo={o.ichigo or "lookup"} hisagi={o.hisagi or "lookup"}')
    print('rung cell |   n | share  wilson pass | bell  bellpts |  ko  kowins')
    for (rung, cell), c in acc.items():
        n = c['n']; lo = ladder.wilson_lo(c['pts'], n)
        row = dict(rung=rung, cell=cell, n=n, share=round(c['pts'] / n, 4), wilson_lo=round(lo, 4), passed=lo >= ladder.BAR,
                   bell=c['bell'], bellpts=c['bellpts'], ko=c['ko'], kowins=c['kowin'])
        out.append(row)
        print(f"{rung}   {cell}   | {n:3d} | {row['share']:.3f}  {lo:.3f}  {'PASS' if row['passed'] else '  - '} | {c['bell']:4d}  {c['bellpts']:6.1f}"
              f"  | {c['ko']:3d}  {c['kowin']:6.1f}")
    if o.json:
        with open(o.json, 'w') as f:
            json.dump(dict(ichigo=o.ichigo, hisagi=o.hisagi, seed0=o.seed0, seeds=o.seeds, cells=out), f, indent=1)


if __name__ == '__main__':
    main()

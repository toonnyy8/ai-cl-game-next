#!/usr/bin/env python3
"""assistgate.py — ASSIST's gate (docs/duel/DUEL_ASSIST.md): the button-masher (debug habit :dumb, P1) against a CPU (P2) on the
native sim (tools/simgate.py's build), every roster pairing, per assist setting; P1's wins per setting.

  python3 tools/assistgate.py                        settings 0 (none) 1 2 3 6 10 11, NORMAL, seeds 1-20
  python3 tools/assistgate.py --ks 0,10 --diff 2     none vs HOLD U + COMBO + BREAK against HARD

k = AUTO GUARD (0 off, 1 HOLD U, 2 ALWAYS) + 3 x AUTO COMBO + 6 x AUTO BREAK (debug 81000+k); --diff 0 EASY 1 NORMAL 2 HARD
(81020+i); --mult the assisted damage in % (81100+k); --learn 0 / 1 the assist's learner (81030+i, default on: its table
per opponent character grows over a pairing's seeds, one process each); --p2-dumb 1: P2 a masher too (81040+i: does
the assist answer J mashing?). It rebuilds the native sim first when a source changed.
"""
import argparse, os, sys
sys.dont_write_bytecode = True   # (no tools/__pycache__ from the import below)
from simgate import ROSTER, RETIRED, build, run_lisp, pool

NAMES = [n[:2] for n in ROSTER]   # YA KE RU IC SE (simgate.ROSTER: the roster in order)


def job(a):
    k, c1, c2, seeds, diff, mult, learn, p2 = a
    r = run_lisp('simgate/run.lisp', [30000, 31100 + seeds, 81000 + k, 81020 + diff, 81100 + mult, 81030 + learn, 81040 + p2,
                                      206000 + 100 * c1 + 10 * c2], timeout=3000)
    rows = [l for l in r.stdout.splitlines() if 'duel learn row' in l]
    return k, c1, c2, sum(' winner P1 ' in l for l in rows), len(rows), r.returncode


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--ks', default='0,1,2,3,6,10,11')
    ap.add_argument('--seeds', type=int, default=20)
    ap.add_argument('--diff', type=int, default=1)
    ap.add_argument('--mult', type=int, default=80)
    ap.add_argument('--learn', type=int, default=1, help="the assist's learner on (1) / off (0) (81030+i)")
    ap.add_argument('--p2-dumb', type=int, default=0, help='P2 a button-masher too, never assisted (81040+i)')
    ap.add_argument('--rows', action='store_true', help='a line per pairing too')
    a = ap.parse_args()
    jobs = [(int(k), c1, c2, a.seeds, a.diff, a.mult, a.learn, a.p2_dumb) for k in a.ks.split(',') for c1 in range(len(ROSTER)) for c2 in range(len(ROSTER))
            if ROSTER[c1] not in RETIRED and ROSTER[c2] not in RETIRED]   # (the retired out, 2026-10-12)
    tot = {}
    build()   # (a no-op unless a source is newer than the build: the stale-build class of DEVLOG §700)
    for k, c1, c2, w, n, rc in pool(job, jobs, min(16, os.cpu_count() or 1)):
        if a.rows or rc or n != a.seeds:
            print(f'k{k} {NAMES[c1]} vs {NAMES[c2]}: P1 wins {w}/{n}' + (f' rc {rc}' if rc else ''))
        t = tot.setdefault(k, [0, 0]); t[0] += w; t[1] += n
    for k, (w, n) in tot.items():
        print(f'assist gate k{k} (guard {k % 3} combo {k // 3 % 2} break {k // 6}) diff {a.diff} learn {a.learn} p2-dumb {a.p2_dumb}: P1 wins {w}/{n} = {100 * w / max(1, n):.0f}%')


if __name__ == '__main__':
    main()

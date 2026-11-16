#!/usr/bin/env python3
"""shares.py — arms6/ih.md's arm time shares: the judgements each arm of Ichigo's IH table won (STRAT_FQLOG "0 0", play unchanged), per
tier, over IH matches with Ichigo at TIER on both seats against Hisagi at OTHER.

  python3 shares.py TIER OTHER [--seed0 500] [--seeds 100] [-j 12]
"""
import argparse, collections, os, re, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '../../../../../tools'))
from simlib import build, pool, run_lisp  # noqa: E402

FQ = re.compile(r'^fq (\d+) \d+ (P\d) .* arm (\d+) ')


def job(j):
    seat, tier, other, s0, n = j
    env = dict(os.environ, STRAT_FQLOG='0 0', **{f'STRAT_DIF_P{seat}': tier, f'STRAT_DIF_P{3 - seat}': other})
    c = 200370 if seat == 1 else 200730
    r = run_lisp('simgate/strat-run.lisp', [30000 + s0, 31100 + n, 81022, c], env=env, timeout=7200)
    return j, collections.Counter(int(m[3]) for l in r.stdout.splitlines() for m in [FQ.match(l)] if m and m[2] == f'P{seat}')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('tier'); ap.add_argument('other')
    ap.add_argument('--seed0', type=int, default=500); ap.add_argument('--seeds', type=int, default=100); ap.add_argument('-j', type=int, default=12)
    o = ap.parse_args()
    build()
    jobs = [(seat, o.tier, o.other, o.seed0 + k, min(50, o.seeds - k)) for seat in (1, 2) for k in range(0, o.seeds, 50)]
    tot = collections.Counter()
    for _, c in pool(job, jobs, o.j):
        tot.update(c)
    n = sum(tot.values())
    print(f'Ichigo {o.tier} vs Hisagi {o.other}: {n} judgements; arm shares ' + ' '.join(f'{k}:{tot[k] / n:.3f}' for k in sorted(tot)))


if __name__ == '__main__':
    main()

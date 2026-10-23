#!/usr/bin/env python3
"""DANGAI's autopilot gate (docs/duel/DUEL_ROGUE.md §9, "Built: batch 5"): per character, 20 runs (seeds 1-20, door 0,
STAGE CLEAR's CONTINUE, rank 0, every reward unlocked) with P1 a HARD CPU, the rewards taken by a pick policy; prints each
character's runs / clears / median steps and, over all of them, each reward's runs (held at the run's end) and clears.

  python3 tools/roguegate.py [--pick first|random|greedy] [--chars 0,1,2,3,4,6,7] [-j N]

The native build is simgate's (tools/simgate.py builds build/simgate/duel.fas when a source is newer)."""
import argparse, collections, concurrent.futures as cf, os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import simgate

PICKS = {'first': 0, 'random': 1, 'greedy': 2}


def run(c, p):
    r = subprocess.run([simgate.ECL, '--norc', '--load', 'tools/roguegate/run.lisp', '--', simgate.FAS, str(84900 + 10 * c + p)],
                       cwd=simgate.ROOT, capture_output=True, text=True, env=dict(os.environ, LD_PRELOAD=simgate.MUSLM))
    if r.returncode:
        sys.exit(f'[roguegate] roster {c} exited {r.returncode}\n' + (r.stdout + r.stderr)[-2000:])
    return [l for l in r.stdout.splitlines() if l.startswith('duel rogue gate ')]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--pick', default='greedy', choices=PICKS)
    ap.add_argument('--chars', default=','.join(str(i) for i, c in enumerate(simgate.ROSTER) if c not in simgate.RETIRED))
    ap.add_argument('-j', type=int, default=min(8, os.cpu_count() or 1))
    a = ap.parse_args()
    simgate.build()
    chars = [int(x) for x in a.chars.split(',')]
    with cf.ThreadPoolExecutor(a.j) as ex:
        outs = list(ex.map(lambda c: run(c, PICKS[a.pick]), chars))
    rewards = collections.defaultdict(lambda: [0, 0, None])   # id -> [runs, clears, name]
    for lines in outs:
        for l in lines:
            m = re.match(r'duel rogue gate reward (\d+) (.+) runs (\d+) clears (\d+) median', l)
            if m:
                w = rewards[int(m[1])]
                w[0] += int(m[3]); w[1] += int(m[4]); w[2] = m[2]
            else:
                print(l)
    for i, (n, k, name) in sorted(rewards.items(), key=lambda x: -x[1][1] / max(1, x[1][0])):
        print(f'duel rogue gate reward {i} {name} runs {n} clears {k} rate {k / max(1, n):.2f}')


if __name__ == '__main__':
    main()

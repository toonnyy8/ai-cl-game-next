# ord.py TREE SEEDS : EASY <= NORMAL <= HARD (DUEL_AI_STRATEGY §11.17's check, fewer seeds): each side plays its lookup at one difficulty
# against the opponent's HARD `none`, seed blocks 200 and 300 (SEEDS each), both seats; K.O. wins of the candidate (TO = time-outs).
import sys, os, re, subprocess, collections
sys.dont_write_bytecode = True
T = sys.argv[1]; sys.path.insert(0, T + '/tools')
from simgate import build, pool
from simlib import ECL, FAS, MUSLM, ROW
build()
N = int(sys.argv[2]); C = {'K': 1, 'I': 3, 'H': 7}
jobs = [(me, op, dif, s0, seat) for me in 'KIH' for op in 'KIH' for dif in ('easy', 'normal', 'hard') for s0 in (200, 300) for seat in (1, 2)]
def job(j):
    me, op, dif, s0, seat = j
    a, b = (me, op) if seat == 1 else (op, me)
    env = dict(os.environ, LD_PRELOAD=MUSLM, **{f'STRAT_DIF_P{seat}': dif, f'STRAT_P{3 - seat}': 'none'})
    r = subprocess.run([ECL, '--norc', '--load', 'tools/simgate/strat-run.lisp', '--', FAS, str(30000 + s0), str(31100 + N), '81022',
                        str(200000 + 100 * C[a] + 10 * C[b])], cwd=T, capture_output=True, text=True, env=env, timeout=3000)
    ko = to = n = 0
    for l in r.stdout.splitlines():
        m = ROW.search(l)
        if not m: continue
        n += 1; k = l.rstrip().endswith('ko 1')
        if not k: to += 1
        elif m[2] == f'P{seat}': ko += 1
    return j, n, ko, to
R = collections.defaultdict(lambda: [0, 0, 0])
for (me, op, dif, s0, seat), n, ko, to in pool(job, jobs, 8):
    r = R[(me, op, dif)]; r[0] += n; r[1] += ko; r[2] += to
print('Side vs opp (HARD none) | EASY | NORMAL | HARD   (K.O. wins / matches, TO)')
for me in 'KIH':
    for op in 'KIH':
        cells = [R[(me, op, d)] for d in ('easy', 'normal', 'hard')]
        ok = cells[0][1] <= cells[1][1] <= cells[2][1]
        print(f'  {me} vs {op} | ' + ' | '.join(f'{c[1]:3d}/{c[0]} TO {c[2]:2d}' for c in cells) + ('' if ok else '   <-- order broken'))

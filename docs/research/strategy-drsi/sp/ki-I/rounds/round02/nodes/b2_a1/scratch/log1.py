# usage: python3 log1.py ICHIGO_ARM SEED0 N OUT [KEN_ARM]  (Ichigo P1 vs Kenpachi P2 (default r1-b2a2), HARD, full combat log)
import sys, os, subprocess
W = '/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-a9e43c5f5424bb955'
S = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, W + '/tools'); os.chdir(W)
import simlib
arm, s0, n, out = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
ken = sys.argv[5] if len(sys.argv) > 5 else W + '/docs/research/strategy-drsi/sp/arms/r1/c-ki-k-r1-b2a2.lisp'
env = dict(os.environ); env['STRAT_P1'] = os.path.abspath(arm); env['STRAT_P2'] = ken; env['LD_PRELOAD'] = simlib.MUSLM
cmds = [30000 + s0, 31100 + n, 81022, 200000 + 100 * 3 + 10 * 1]
with open(out, 'w') as f:
    r = subprocess.run([simlib.ECL, '--norc', '--load', S + '/strat-run-log.lisp', '--', simlib.FAS] + [str(c) for c in cmds],
                       cwd=W, stdout=f, stderr=subprocess.STDOUT, env=env, timeout=3000, stdin=subprocess.DEVNULL)
print(r.returncode)

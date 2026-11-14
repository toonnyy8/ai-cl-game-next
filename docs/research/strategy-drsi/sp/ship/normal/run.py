# run.py TREE OUT SEEDS DIF PAIRS [SEED0]: one gate log per pairing of TREE's native sim (tools/simgate/run-log.lisp: run.lisp with the
# combat log on), seeds SEED0+1 .. SEED0+SEEDS, difficulty DIF (81020 + DIF), pairings by simgate.py index; ko.py counts K.O.s
import sys, os, subprocess
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(sys.argv[1], 'tools'))
from simgate import build, gate_cmd, pool, PAIRS
from simlib import ECL, FAS, MUSLM, ROOT
build()
X = os.path.dirname(os.path.abspath(__file__))
out = sys.argv[2]; seeds = int(sys.argv[3]); dif = sys.argv[4]; os.makedirs(out, exist_ok=True)
seed0 = int(sys.argv[6]) if len(sys.argv) > 6 else 0
def job(k):
    r = subprocess.run([ECL, '--norc', '--load', os.path.join(sys.argv[1], 'tools/simgate/run-log.lisp'), '--', FAS] + [str(c) for c in [30000 + seed0, 31100 + seeds, 81020 + int(dif), gate_cmd(k)]],
                       cwd=ROOT, capture_output=True, text=True, env=dict(os.environ, LD_PRELOAD=MUSLM), timeout=3000)
    open(f'{out}/log-{PAIRS[k].replace(" ","-")}-d{dif}.txt', 'w').write(r.stdout + r.stderr)
    return k, r.returncode
for k, rc in pool(job, [int(x) for x in sys.argv[5].split(',')], 8): print(PAIRS[k], rc)

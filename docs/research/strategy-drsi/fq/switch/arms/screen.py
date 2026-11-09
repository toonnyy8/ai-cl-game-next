#!/usr/bin/env python3
"""screen.py — each candidate arm played whole (tools/strategy-switch.py --raw) against Ichigo's frozen :ki-ichigo, HARD, both seats, on a
training block (default seeds 1-300). usage: screen.py [--vs kenpachi --vs-strat SPEC --tag -hk] [--seed0 0] [--seeds 300] FILE.lisp ...  -> FILE-<lo>-<hi>.json beside each file."""
import json, os, subprocess, sys
sys.dont_write_bytecode = True
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../../../..'))
args = sys.argv[1:]
vs = args[args.index('--vs') + 1] if '--vs' in args else 'ichigo'
OPP = args[args.index('--vs-strat') + 1] if '--vs-strat' in args else os.path.join(ROOT, 'docs/research/strategy-drsi/counter/frozen/ki-ichigo.lisp')
tag = args[args.index('--tag') + 1] if '--tag' in args else ''
OPP = ','.join(x if x == 'none' else os.path.abspath(x) for x in OPP.split(','))
seed0 = int(args[args.index('--seed0') + 1]) if '--seed0' in args else 0
n = int(args[args.index('--seeds') + 1]) if '--seeds' in args else 300
files = [a for i, a in enumerate(args) if a.endswith('.lisp') and (i == 0 or args[i - 1] != '--vs-strat')]
for f in files:
    f = os.path.abspath(f)
    r = subprocess.run([sys.executable, 'tools/strategy-switch.py', '--char', 'hisagi', '--vs', vs, '--vs-strat', OPP, '--cand', f, '--raw',
                        '--seed0', str(seed0), '--seeds', str(n), '-j', '20'], cwd=ROOT, capture_output=True, text=True, check=True)
    out = os.path.splitext(f)[0] + f'{tag}-{seed0 + 1}-{seed0 + n}.json'
    open(out, 'w').write(r.stdout)
    d = json.loads(r.stdout)
    print(os.path.basename(f), 'share', d['comp_share'], 'shipped', d['inc_share'], 'b/c', d['b'], d['c'], 'held', d.get('held'), flush=True)

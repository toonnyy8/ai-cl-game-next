#!/usr/bin/env python3
"""run-logs.py — the behaviour logs of §8.18's six tables: fq.py log, salts 1-4, eps 0.15, seeds 1-599, both seats, the init table
(pairs/<p>/<p>-t0.lisp) on the character's seat, the frozen opponent or the proxy pool on the other.  usage: run-logs.py [P ...] [--table-suffix t0]
Tags: logs/<p>-<suffix>/ (gitignored)."""
import json, os, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__)); FQ = os.path.dirname(HERE)
POOLS = json.load(open(os.path.join(FQ, 'pools.json')))
pool = lambda k: ','.join(m if m == 'none' else os.path.normpath(os.path.join(FQ, m)) for m, _ in POOLS[k]['members'])
PAIRS = {'ki': ('kenpachi', 'ichigo', 'q1-ichigo-ken'), 'kh': ('kenpachi', 'hisagi', 'ki-ken'), 'kk': ('kenpachi', 'kenpachi', 'none'),
         'ii': ('ichigo', 'ichigo', 'none'), 'ik': ('ichigo', 'kenpachi', pool('ichigo-kenpachi')), 'ih': ('ichigo', 'hisagi', pool('ichigo-hisagi'))}
args = sys.argv[1:]
suf = 't0'
if '--table-suffix' in args:
    i = args.index('--table-suffix'); suf = args[i + 1]; del args[i:i + 2]
for p in args or list(PAIRS):
    c, v, opp = PAIRS[p]
    for salt in (1, 2, 3, 4):
        subprocess.run([sys.executable, 'fq.py', 'log', '--char', c, '--vs', v, '--table', f'pairs/{p}/{p}-{suf}.lisp', '--opp', opp,
                        '--tag', f'{p}-{suf}', '--salt', str(salt), '--eps', '0.15', '--seeds', '1-599', '-j', '8'],
                       cwd=FQ, check=True, stdout=subprocess.DEVNULL)
        print(p, salt, 'done', flush=True)

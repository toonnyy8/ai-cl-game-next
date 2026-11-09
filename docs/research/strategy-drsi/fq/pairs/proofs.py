#!/usr/bin/env python3
"""proofs.py — §8.18's proofs on the build with the lookup entries (601-700, both seats; OLD = the build hash before the entries):
cross.py (each t0 table = the old incumbent, now that the table is the lookup entry) and proof/identity.py (each fitted table run raw = the live
lookup, i.e. the lookup path plays the table).   usage: proofs.py OLD_BUILD_HASH  -> JSON lines"""
import json, os, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__)); FQ = os.path.dirname(HERE)
P = json.load(open(os.path.join(FQ, 'pools.json')))
pool = lambda k: ','.join(m if m == 'none' else os.path.normpath(os.path.join(FQ, m)) for m, _ in P[k]['members'])
F = os.path.join(FQ, '..', 'counter', 'frozen')
CASES = [('ki', 'kenpachi', 'ichigo', f'{F}/q1-ichigo-ken.lisp'), ('kh', 'kenpachi', 'hisagi', f'{F}/ki-ken.lisp'),
         ('kk', 'kenpachi', 'kenpachi', 'none'), ('ii', 'ichigo', 'ichigo', 'none'), ('ih', 'ichigo', 'hisagi', pool('ichigo-hisagi'))]
old = sys.argv[1]
for p, c, v, o in CASES:
    for cmd in (['pairs/cross.py', c, v, o, f'pairs/{p}/{p}-t0.lisp', old], ['proof/identity.py', c, v, o, f'pairs/{p}/{p}-fit.lisp']):
        r = subprocess.run([sys.executable] + cmd, cwd=FQ, capture_output=True, text=True)
        print(r.stdout.strip() or r.stderr[-1500:], flush=True)

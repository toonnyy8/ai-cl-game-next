#!/usr/bin/env python3
"""cross.py — a table run raw on THIS build against the incumbent of an EARLIER build (DUEL_AI_STRATEGY §8.18): the proof that a table's
arm 0 still plays the old incumbent once the table is itself the lookup entry (the NIL arm: no strategy, never the lookup). The duel hash /
duel state / gate-row lines of every match, both seats, compared with the earlier build's cached incumbent output (build/strategy-eval-cache,
keyed by that build's hash).   usage: cross.py CHAR VS VS_STRAT TABLE OLD_BUILD_HASH [--seed0 600] [--seeds 100]"""
import importlib.util, json, os, subprocess, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__)); FQ = os.path.dirname(HERE); ROOT = os.path.abspath(os.path.join(FQ, '../../../..'))
sp = importlib.util.spec_from_file_location('ss', os.path.join(ROOT, 'tools/strategy-switch.py')); ss = importlib.util.module_from_spec(sp); sp.loader.exec_module(ss)
me, vs, vss, table, old = sys.argv[1:6]
seed0 = int(sys.argv[sys.argv.index('--seed0') + 1]) if '--seed0' in sys.argv else 600
n = int(sys.argv[sys.argv.index('--seeds') + 1]) if '--seeds' in sys.argv else 100
table = os.path.abspath(table)
vss = ','.join(x if x == 'none' else os.path.abspath(x) for x in vss.split(','))
r = subprocess.run([sys.executable, 'tools/strategy-switch.py', '--char', me, '--vs', vs, '--vs-strat', vss, '--cand', table, '--raw',
                    '--seed0', str(seed0), '--seeds', str(n), '-j', '10'], cwd=ROOT, capture_output=True, text=True, check=True)
j = json.loads(r.stdout)
text = ss.strip_lisp(open(table).read()).strip() + '\n'
v = ss.vs_spec(vss)
keep = lambda t: [l for l in t.splitlines() if l.startswith(('duel hash', 'duel state', 'duel gate row'))]
same = diff = lines = 0
R = ss.ROSTER
for seat, (c1, c2) in (('P1', (R[me], R[vs])), ('P2', (R[vs], R[me]))):
    o = 'P2' if seat == 'P1' else 'P1'
    for s0 in range(seed0, seed0 + n, ss.CHUNK):
        k = min(ss.CHUNK, seed0 + n - s0)
        get = lambda comp, bh: keep(open(os.path.join(ss.CACHE, 'sw-' + ss.sha(json.dumps(
            [c1, c2, seat if comp else None, text if comp else None, 2, s0, k, bh, o, v[1]]).encode()) + '.out')).read())
        a, b = get(True, ss.build_hash()), get(False, old)
        lines += len(a); same += a == b; diff += a != b
print(json.dumps(dict(char=me, vs=vs, table=os.path.relpath(table, FQ), build=ss.build_hash(), old_build=old, table_share=j['comp_share'],
                      live_lookup_share=j['inc_share'], chunks_identical_to_old_incumbent=same, chunks_differing=diff, lines=lines)))

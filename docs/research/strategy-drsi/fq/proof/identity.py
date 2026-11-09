#!/usr/bin/env python3
"""identity.py — a table run raw (tools/strategy-switch.py --raw) must equal the incumbent bit for bit: the duel hash / duel state / gate-row
lines of every match, both seats (DUEL_AI_STRATEGY §8.15; the c1 identity proof's method, §8.12).
  usage: identity.py CHAR VS VS_STRAT TABLE [--seed0 600] [--seeds 100] [--ref FILE]   -> prints the evaluator's shares and the line comparison
  --ref FILE: compare with FILE run raw (a plain strategy, e.g. a table's arm 0 played whole) instead of the incumbent (§8.17)."""
import importlib.util, json, os, subprocess, sys
sys.dont_write_bytecode = True
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
sp = importlib.util.spec_from_file_location('ss', os.path.join(ROOT, 'tools/strategy-switch.py')); ss = importlib.util.module_from_spec(sp); sp.loader.exec_module(ss)
me, vs, vss, table = sys.argv[1:5]
table = os.path.abspath(table)
vss = ','.join(x if x == 'none' else os.path.abspath(x) for x in vss.split(','))
seed0 = int(sys.argv[sys.argv.index('--seed0') + 1]) if '--seed0' in sys.argv else 600
n = int(sys.argv[sys.argv.index('--seeds') + 1]) if '--seeds' in sys.argv else 100
ref = os.path.abspath(sys.argv[sys.argv.index('--ref') + 1]) if '--ref' in sys.argv else None
def run(cand):
    r = subprocess.run([sys.executable, 'tools/strategy-switch.py', '--char', me, '--vs', vs, '--vs-strat', vss, '--cand', cand, '--raw',
                        '--seed0', str(seed0), '--seeds', str(n), '-j', '8'], cwd=ROOT, capture_output=True, text=True, check=True)
    return json.loads(r.stdout)
j = run(table)
text = ss.strip_lisp(open(table).read()).strip() + '\n'
if ref:
    jr = run(ref)
    rtext = ss.strip_lisp(open(ref).read()).strip() + '\n'
v = ss.vs_spec(vss)
keep = lambda t: [l for l in t.splitlines() if l.startswith(('duel hash', 'duel state', 'duel gate row'))]
same = diff = lines = 0
R = ss.ROSTER
for seat, (c1, c2) in (('P1', (R[me], R[vs])), ('P2', (R[vs], R[me]))):
    o = 'P2' if seat == 'P1' else 'P1'
    for s0 in range(seed0, seed0 + n, ss.CHUNK):
        k = min(ss.CHUNK, seed0 + n - s0)
        get = lambda comp: keep(open(os.path.join(ss.CACHE, 'sw-' + ss.sha(json.dumps(
            [c1, c2, seat if comp else None, comp, 2, s0, k, ss.build_hash(), o, v[1]]).encode()) + '.out')).read())
        a, b = get(text), get(rtext if ref else None)
        lines += len(a); same += a == b; diff += a != b
print(json.dumps(dict(char=me, vs=vs, vs_strat=[x if x == 'none' else os.path.relpath(x, ROOT) for x in vss.split(',')], table=os.path.relpath(table, ROOT), table_share=j['comp_share'], inc_share=j['inc_share'], **({'ref': os.path.relpath(ref, ROOT), 'ref_share': jr['comp_share']} if ref else {}),
                      b=j['b'], c=j['c'], held=j['held'], chunks_identical=same, chunks_differing=diff, lines=lines)))

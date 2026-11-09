#!/usr/bin/env python3
"""heldout.py — strategies run raw on the character's seat against one opponent spec, HARD, both seats, the same seeds, paired against
each other and against the incumbent (the HARD CPU with the build's lookup) (DUEL_AI_STRATEGY §8.18).
  usage: heldout.py CHAR VS OPP [--seed0 700] [--seeds 100] FILE...   OPP: a file, a frozen id, none, or a comma list (a pool)
-> one JSON object: per file its share, and b / c / z against the incumbent and against every other file (b = seeds the row won and the
column lost)."""
import importlib.util, itertools, json, math, os, re, subprocess, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__)); FQ = os.path.dirname(HERE); ROOT = os.path.abspath(os.path.join(FQ, '../../../..'))
sp = importlib.util.spec_from_file_location('ss', os.path.join(ROOT, 'tools/strategy-switch.py')); ss = importlib.util.module_from_spec(sp); sp.loader.exec_module(ss)
args = sys.argv[1:]


def opt(k, d):
    if k in args:
        i = args.index(k); v = args[i + 1]; del args[i:i + 2]; return int(v)
    return d


seed0, n = opt('--seed0', 700), opt('--seeds', 100)
me, vs, opp, files = args[0], args[1], args[2], [os.path.abspath(f) for f in args[3:]]
FROZEN = os.path.join(FQ, '..', 'counter', 'frozen')
opp = ','.join('none' if x == 'none' else os.path.abspath(x if os.path.exists(x) else os.path.join(FROZEN, x + '.lisp')) for x in opp.split(','))
for f in files:
    subprocess.run([sys.executable, 'tools/strategy-switch.py', '--char', me, '--vs', vs, '--vs-strat', opp, '--cand', f, '--raw',
                    '--seed0', str(seed0), '--seeds', str(n), '-j', os.environ.get('HJ', '10')], cwd=ROOT, capture_output=True, text=True, check=True)
v = ss.vs_spec(opp)
R = ss.ROSTER


def wins(text):
    """{(seat, seed): 1 if the character won} from the cache (TEXT None: the incumbent)."""
    out = {}
    for seat, (c1, c2) in (('P1', (R[me], R[vs])), ('P2', (R[vs], R[me]))):
        o = 'P2' if seat == 'P1' else 'P1'
        for s0 in range(seed0, seed0 + n, ss.CHUNK):
            k = min(ss.CHUNK, seed0 + n - s0)
            key = [c1, c2, seat if text else None, text, 2, s0, k, ss.build_hash(), o, v[1]]
            for line in open(os.path.join(ss.CACHE, 'sw-' + ss.sha(json.dumps(key).encode()) + '.out')):
                m = re.search(r'duel gate row seed (\d+) .* winner (\S+)', line)
                if m:
                    out[(seat, int(m.group(1)))] = int(m.group(2) == seat)
    return out


W = {'incumbent': wins(None)}
for f in files:
    W[os.path.relpath(f, FQ)] = wins(ss.strip_lisp(open(f).read()).strip() + '\n')
res = dict(char=me, vs=vs, opp=[x if x == 'none' else os.path.relpath(x, FQ) for x in opp.split(',')], seeds=f'{seed0 + 1}-{seed0 + n}',
           share={k: round(sum(w.values()) / len(w), 4) for k, w in W.items()}, pairs={})
for a, b in itertools.permutations(W, 2):
    if a == 'incumbent':
        continue
    bb = sum(W[a][s] and not W[b][s] for s in W[a]); cc = sum(W[b][s] and not W[a][s] for s in W[a])
    res['pairs'][f'{a} vs {b}'] = dict(b=bb, c=cc, z=round((bb - cc) / math.sqrt(bb + cc), 2) if bb + cc else 0.0)
print(json.dumps(res, indent=1))

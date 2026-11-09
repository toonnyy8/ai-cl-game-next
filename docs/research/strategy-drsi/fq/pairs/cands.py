#!/usr/bin/env python3
"""cands.py — the arm-1 choice for the pairings at the ceiling (DUEL_AI_STRATEGY §8.18): each candidate strategy, run raw on the character's
seat, against the pairing's proxy pool (../pools.json, seed mod n), HARD, both seats; the incumbent (the HARD CPU with its lookup) on the
same seeds.   usage: cands.py PAIRING [--seed0 0] [--seeds 100] CAND...   -> JSON lines on stdout"""
import json, os, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__)); FQ = os.path.dirname(HERE); ROOT = os.path.abspath(os.path.join(FQ, '../../../..'))
args = sys.argv[1:]


def opt(k, d):
    if k in args:
        i = args.index(k); v = args[i + 1]; del args[i:i + 2]; return v
    return d


seed0, n = opt('--seed0', '0'), opt('--seeds', '100')
pair, cands = args[0], args[1:]
P = json.load(open(os.path.join(FQ, 'pools.json')))[pair]
pool = ','.join(m if m == 'none' else os.path.normpath(os.path.join(FQ, m)) for m, _ in P['members'])
for c in cands:
    r = subprocess.run([sys.executable, 'tools/strategy-switch.py', '--char', P['char'], '--vs', P['vs'], '--vs-strat', pool, '--cand',
                        os.path.abspath(c), '--raw', '--seed0', seed0, '--seeds', n, '-j', '10'], cwd=ROOT, capture_output=True, text=True)
    if r.returncode:
        sys.exit(r.stdout[-1000:] + r.stderr[-2000:])
    j = json.loads(r.stdout)
    print(json.dumps(dict(pairing=pair, cand=os.path.relpath(os.path.abspath(c), FQ), seeds=f'{int(seed0) + 1}-{int(seed0) + int(n)}',
                          share=j['comp_share'], inc=j['inc_share'], b=j['b'], c=j['c'], z=j['z'])), flush=True)

#!/usr/bin/env python3
"""measure.py — the incumbent's share against each member of a proxy pool and against the pool as a whole (seed mod n), seeds 601-700,
both seats (DUEL_AI_STRATEGY §8.15; ../pools.json).   usage: measure.py PAIRING [--seed0 600]  -> pool/<pairing>.json"""
import json, os, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__)); FQ = os.path.dirname(HERE); ROOT = os.path.abspath(os.path.join(FQ, '../../../..'))
pair = sys.argv[1]; seed0 = sys.argv[sys.argv.index('--seed0') + 1] if '--seed0' in sys.argv else '600'
P = json.load(open(os.path.join(FQ, 'pools.json')))[pair]
never = os.path.join(HERE, 'never.lisp')
def share(spec):
    r = subprocess.run([sys.executable, 'tools/strategy-switch.py', '--char', P['char'], '--vs', P['vs'], '--vs-strat', spec, '--cand', never,
                        '--seed0', seed0, '--seeds', '100', '-j', '8'], cwd=ROOT, capture_output=True, text=True, check=True)
    return json.loads(r.stdout)['inc_share']
paths = [m if m == 'none' else os.path.normpath(os.path.join(FQ, m)) for m, _ in P['members']]
res = dict(pairing=pair, seeds=f'{int(seed0) + 1}-{int(seed0) + 100}', members=[dict(member=m, what=w, inc_share=share(p)) for (m, w), p in zip(P['members'], paths)])
res['pool_seed_mod_n'] = share(','.join(paths))
res['pool_mean'] = round(sum(x['inc_share'] for x in res['members']) / len(paths), 4)
json.dump(res, open(os.path.join(HERE, f'{pair}-{seed0}.json'), 'w'), indent=1)
print(json.dumps(res, indent=1))

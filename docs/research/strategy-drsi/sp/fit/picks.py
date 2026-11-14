#!/usr/bin/env python3
"""picks.py TABLE_TAG ARM_NAMES...: what a measured table picks where, from sw.py measure's summaries TAG-mix.json / TAG-none.json
(fq/switch/<TAG>-<opp>.json): per opponent its switching; pooled over both, each rule's firing-weighted arm shares (arms under 5 % left out)
and the arm shares by form x distance band."""
import json, os, sys
import numpy as np
D = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../fq/switch')
tag, names = sys.argv[1], sys.argv[2:]
ds = {o: json.load(open(os.path.join(D, f'{tag}-{o}.json'))) for o in ('mix', 'none')}
for o, d in ds.items():
    print(f'{o}: {d["judged_per_match"]} judgements a match, arm changes {d["changes_per_match"]}, arm shares {d["arm_share"][:len(names)]}')


def pooled(key):
    out = {}
    for d in ds.values():
        for r, v in key(d).items():
            w = v.get('w', v.get('n'))
            out[r] = out.get(r, 0) + np.array(v['share'][:len(names)]) * w
    return out


for title, key in (('rules', lambda d: d['by_rule']), ('form x band', lambda d: d['by']['form-band'])):
    print(title + ' (pooled; weight, arm shares >= 0.05):')
    for r, a in pooled(key).items():
        s = a / a.sum()
        print(f'  {r:50s} {a.sum():8.0f}  ' + ' '.join(f'{n} {x:.2f}' for n, x in zip(names, s) if x >= 0.05))

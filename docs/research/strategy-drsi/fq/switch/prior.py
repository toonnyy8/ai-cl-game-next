#!/usr/bin/env python3
"""prior.py — sizing a learnable preference for one arm in one form (DUEL_AI_STRATEGY §8.19 round 3, the user: 「改成可學的偏好」).
At every judgement in FORM of the logged blocks, the margin m = max over the other arms of Q - Q(ARM) under TABLE (no bias). A bias b on
ARM in that form's G1 rows adds b to Q(ARM) there (G1's rows of one form sum to 1), so ARM is greedy where b > m. The online learner
(cap 0.01 per q from the offline value, DUEL_AI_STRATEGY §8.14) plays only the greedy arm, so it can lower Q(ARM) by at most 0.01 in each
of the 5 groups' rules: a state flips only where b - m < 0.05.
usage: prior.py TABLE ARMS TAG[,TAG] [--form 0] [--arm 0] [--seeds 1-599] [--salt 1]"""
import argparse, json, os, sys
from types import SimpleNamespace
import numpy as np
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sw  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument('table'); ap.add_argument('arms'); ap.add_argument('tags')
ap.add_argument('--form', type=int, default=0); ap.add_argument('--arm', type=int, default=0)
ap.add_argument('--seeds', default='1-599'); ap.add_argument('--salt', type=int, default=1)
ap.add_argument('--band', choices=('close', 'mid', 'far'), help='only judgements in this distance band (sw.band)')
a = ap.parse_args()
sw.configure(SimpleNamespace(me='hisagi', vs='ichigo', opp='none', arms=a.arms))
q = sw.read_q(a.table)
lo, hi = (int(x) for x in a.seeds.split('-'))
ms = []
for tag in a.tags.split(','):
    for m in sw.load(tag, lo, hi):
        if m['salt'] != a.salt:
            continue
        for j in m['js']:
            if j[5] != a.form or (a.band and sw.band(j[4]) != a.band):
                continue
            Q = np.zeros(sw.NA)
            for r, x in j[6].items():
                Q += x * q[r]
            ms.append(np.delete(Q, a.arm).max() - Q[a.arm])
ms = np.array(ms)
out = dict(table=a.table, judgements=len(ms), margin_quantiles={p: round(float(np.quantile(ms, p)), 4) for p in (0.05, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99)},
           bias={})
for b in (0.0, 0.02, 0.03, 0.04, 0.05, 0.06, 0.08, 0.10, 0.15):
    g = b - ms
    gr = g > 0
    out['bias'][b] = dict(greedy=round(float(gr.mean()), 3), learnable=round(float(((g > 0) & (g < 0.05)).sum() / max(1, gr.sum())), 3))
print(json.dumps(out))

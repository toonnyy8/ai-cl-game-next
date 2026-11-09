#!/usr/bin/env python3
"""gaps.py — a fitted table's arm gaps |q0 - q1| per cell, as the online learner sees them (DUEL_AI_STRATEGY §8.18): the cap-0.01 learner moves
each q at most 0.01 from its offline value, so it can flip a cell only where the gap is under 0.02. Cells are split by where the gap comes from:
`clamp` = the trainer kept / set the arm against the data's estimate and wrote the other q 0.001 below (fq.py train), `nodata` = an arm has no
sample (its q written 0), `data` = both arms seen and the written argmax is the data's.   usage: gaps.py TABLE.json ...  (the .lisp beside it)"""
import json, os, sys
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import fq   # noqa: E402

for jf in sys.argv[1:]:
    d = json.load(open(jf))
    q = fq.read_table(os.path.splitext(jf)[0] + '.lisp')[3]
    cat = {'data': [], 'clamp': [], 'nodata': []}
    for c in d['cells']:
        g = float(abs(q[c["cell"], 0] - q[c["cell"], 1]))
        if not c['n0'] or not c['n1']:
            cat['nodata'].append(g)
        elif abs(g - 0.001) < 1e-6 and (c['q0'] > c['q1']) != (c['pi'] == 0):
            cat['clamp'].append(g)
        else:
            cat['data'].append(g)
    data = sorted(cat['data'])
    out = dict(table=os.path.relpath(os.path.splitext(jf)[0] + '.lisp'), arm1_cells=sum(c['pi'] for c in d['cells']), flips=len(d['flips']),
               clamp=len(cat['clamp']), nodata=len(cat['nodata']), data=len(data),
               data_under_002=sum(g < 0.02 for g in data), data_002_005=sum(0.02 <= g < 0.05 for g in data), data_over_005=sum(g >= 0.05 for g in data),
               data_median=round(data[len(data) // 2], 4) if data else None,
               flippable_by_cap_001=sum(g < 0.02 for v in cat.values() for g in v))
    print(json.dumps(out))

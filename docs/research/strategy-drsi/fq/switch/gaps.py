#!/usr/bin/env python3
"""gaps.py — how far the online learner (cap 0.01 a q, DUEL_AI_STRATEGY §8.14) is from flipping a table's choices: at every judgement of
logged blocks (sw.py measure, eps 0), Q = the logged firing vector . the table's q; gap = best Q - second best, pooled and per form. With
:groups each arm's Q is a sum of one q per group (5 groups), so a cap-0.01 learner moves an arm's Q by up to 0.05 and a choice can flip
under a gap of 0.10 at most; one rule's own q moves 0.01 (a gap under 0.02 flips from one cell). Also: of the matches with no arm change,
how many never left the Shikai.  usage: gaps.py TABLE ARMS TAG [TAG ...]   (ARMS: the table's arms file, for the arm count)"""
import json, os, sys
from types import SimpleNamespace
import numpy as np
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sw  # noqa: E402

sw.configure(SimpleNamespace(me='hisagi', vs='ichigo', opp='none', arms=sys.argv[2]))
q = sw.read_q(sys.argv[1])
gaps, forms, zero, zero_shikai = [], [], 0, 0
for tag in sys.argv[3:]:
    for m in sw.load(tag, 1, 1000):
        js = m['js']
        if js and all(j[1] == js[0][1] for j in js):
            zero += 1
            zero_shikai += all(j[5] == 0 for j in js)
        for j in js:
            Q = np.zeros(sw.NA)
            for r, x in j[6].items():
                Q += x * q[r]
            s = np.sort(Q)
            gaps.append(s[-1] - s[-2])
            forms.append(j[5])
g, f = np.array(gaps), np.array(forms)


def st(x):
    return dict(n=len(x), median=round(float(np.median(x)), 4), under_002=round(float((x < 0.02).mean()), 3),
                under_005=round(float((x < 0.05).mean()), 3), under_010=round(float((x < 0.10).mean()), 3)) if len(x) else {}


print(json.dumps(dict(table=sys.argv[1], all=st(g), shikai=st(g[f == 0]), ranged=st(g[f == 1]), bind=st(g[f == 2]),
                      zero_change_matches=zero, of_them_never_left_shikai=zero_shikai)))

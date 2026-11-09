#!/usr/bin/env python3
"""gaps.py — how far the online learner (cap 0.01 a q, DUEL_AI_STRATEGY §8.14) is from flipping the pilot's choices: at every judgement of a
logged block (sw.py measure, eps 0), Q = the logged firing vector . the table's q; gap = best Q - second best. With :groups each arm's Q is a
sum of one q per group (5 groups), so a cap-0.01 learner moves an arm's Q by up to 0.05 and a choice can flip under a gap of 0.10 at most;
one rule's own q moves 0.01 (a gap under 0.02 flips from one cell).  usage: gaps.py TABLE TAG [TAG ...]"""
import json, os, sys
import numpy as np
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sw  # noqa: E402

q = sw.read_q(sys.argv[1])
gaps, groups_fired = [], []
for tag in sys.argv[2:]:
    for m in sw.load(tag, 1, 1000):
        for j in m['js']:
            Q = np.zeros(sw.NA)
            for r, x in j[6].items():
                Q += x * q[r]
            s = np.sort(Q)
            gaps.append(s[-1] - s[-2])
            groups_fired.append(len({sw.GROUP_OF[r] for r in j[6]}))
g = np.array(gaps)
print(json.dumps(dict(table=sys.argv[1], judgements=len(g), median=round(float(np.median(g)), 4),
                      under_002=round(float((g < 0.02).mean()), 3), under_005=round(float((g < 0.05).mean()), 3),
                      under_010=round(float((g < 0.10).mean()), 3), groups_fired_mean=round(float(np.mean(groups_fired)), 2))))

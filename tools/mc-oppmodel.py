#!/usr/bin/env python3
"""The light model's opponent model from tools/simgate/oppmodel.lisp logs (docs/duel/DUEL_AI_MCTS.md §9): per character, counts per distance
band (4) x opponent state class (5) x macro action (10), printed as the rows of mcts-lite.lisp's *MC-OPP-MODEL*. Usage: mc-oppmodel.py LOG..."""
import collections, fileinput
ACT = ['j1', 'sp', 'hoho', 'step-in', 'step-out', 'step-side', 'guard', 'wait', 'walk-in', 'walk-out']
c = collections.defaultdict(lambda: [0] * 200)
for l in fileinput.input():
    p = l.split()
    if p[:1] == ['opp'] and len(p) == 5 and p[4] in ACT:
        c[p[1]][(int(p[2]) * 5 + int(p[3])) * 10 + ACT.index(p[4])] += 1
for ch in sorted(c):
    print(f'    (:{ch} . ({" ".join(map(str, c[ch]))}))   ; n {sum(c[ch])}')

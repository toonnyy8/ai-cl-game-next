#!/usr/bin/env python3
"""The in-game MCTS's outcome values from tools/simgate/contact.lisp logs (docs/duel/DUEL_AI_TEACHER.md §9): per character form, the mean
health swing of a neutral contact by the attacker's class (NA, NS by pointer, a turn move AS / SA, a perfect Hoho's counter) and of a
blocked one, printed as the rows of cpu-mcts's *MC-OUTCOMES*. A slot with fewer than MIN samples takes the character's pooled mean,
then everyone's. Usage: python3 tools/mc-outcomes.py LOG... > rows.lisp"""
import collections, fileinput
MIN = 30
SLOTS = ['na', 'ns1', 'ns2', 'ns3', 'turn', 'counter', 'block']
by = collections.defaultdict(list)
for l in fileinput.input():
    p = l.split()
    if p[:1] != ['contact']: continue
    ch, fo, cl, pt, oc, v = p[1], p[2], p[3].strip(':'), p[4], p[5].strip(':'), float(p[6])
    if oc == 'block': slot = 'block'
    elif cl == 'ns': slot = 'ns' + str(min(3, max(1, int(pt))))
    elif cl in ('as', 'sa'): slot = 'turn'
    elif cl in ('na', 'counter'): slot = cl
    else: continue
    for key in ((ch, fo, slot), (ch, '*', slot), ('*', '*', slot)): by[key].append(v)
mean = lambda k: sum(by[k]) / len(by[k])
def val(ch, fo, s):
    for k in ((ch, fo, s), (ch, '*', s), ('*', '*', s)):
        if len(by[k]) >= MIN: return mean(k)
    return 0.0
forms = sorted({(k[0], k[1]) for k in by if k[0] != '*' and k[1] != '*'})
for ch, fo in forms + sorted({(k[0], '*') for k in by if k[0] != '*'}) + [('*', '*')]:
    n = sum(len(by[(ch, fo, s)]) for s in SLOTS)
    print(f'    (({ch} {fo}) {" ".join(f"{val(ch, fo, s):.3f}" for s in SLOTS)})   ; n {n}'.replace("'*'", 't').replace('(* *)', '(t t)').replace(' *)', ' t)'))

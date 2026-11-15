#!/usr/bin/env python3
"""grid.py — the openers' grid (trials.lisp section P) as Markdown matrices, from combo-trial.py --events output on stdin:
  python3 tools/combo-trial.py docs/research/strategy-drsi/sp/kits/ichigo/trials.lisp --events | python3 .../grid.py
A cell lists one letter per distance (the header's order): I = Ichigo's real hit first, H = his first, c = a cancel came first
(cI / cH / c-: who hit first after it, or nobody), - = nobody hit, A = an absorb (super armour) came first.
"""
import re, sys
rows = {}
for line in sys.stdin:
    m = re.match(r'\| P (\S+) vs his (\S+) at ([\d.]+) /(\w+) \|', line)
    if not m: continue
    mine, his, d, opp = m.groups()
    log = line.split('|')[11]
    out, pre = '-', ''
    for ev in [e.strip() for e in log.split(';')]:
        p2 = ev.startswith('[') and '] P2 ' in ev
        if 'CANCEL' in ev and not pre: pre = 'c'; continue
        if 'ABSORBED' in ev and not pre: pre = 'A'; continue
        if re.search(r' (HIT|COUNTER|ARMORED) ', ev + ' '):
            out = 'H' if p2 else 'I'; break
    rows.setdefault(opp, {}).setdefault(mine, {}).setdefault(his, {})[float(d)] = (pre + out) if pre else out
for opp, t in rows.items():
    dists = sorted({d for r in t.values() for c in r.values() for d in c})
    his_list = list(next(iter(t.values())).keys())
    print(f'\n**vs {opp}** (distances {" / ".join(str(d) for d in dists)} m)\n')
    print('| hers \\ his | ' + ' | '.join(his_list) + ' |')
    print('|---' * (len(his_list) + 1) + '|')
    for mine, r in t.items():
        print(f'| {mine} | ' + ' | '.join(' '.join(r[h].get(d, '?') for d in dists) for h in his_list) + ' |')

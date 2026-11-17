#!/usr/bin/env python3
"""table.py — arms6/ih-human.md's behaviour table: two beh.py JSONs (before, after) as one markdown table, each cell "before → after".

  python3 table.py BEFORE.json AFTER.json
"""
import json, sys

OPP = {'none': 'no strategy', 'arm:h5-all': 'h5-all (his band)', 'arm:h4-range': 'h4-range', 'lookup': 'his IH table'}
COLS = [('share', 'her share', '{:.3f}'), ('hit_nagi', 'NAGI hits', '{:.2f}'), ('hit_rj', 'ranged-J hits', '{:.2f}'),
        ('open', 'his openers', '{:.2f}'), ('openby_rec', 'her whiffs punished', '{:.2f}'), ('start', 'her attack starts', '{:.1f}'),
        ('band_r', 'ranged mode in 3.4-6.2 m', '{:.2f}'), ('band_s', 'Shikai in 3.1-6.0 m', '{:.2f}')]
a, b = ({(r['tier'], r['opp']): r for r in json.load(open(p))['rows']} for p in sys.argv[1:3])
print('| Ichigo | Hisagi plays | ' + ' | '.join(c[1] for c in COLS) + ' |')
print('|---|---|' + '---|' * len(COLS))
for k, x in a.items():
    y = b[k]
    print(f'| {k[0].upper()} | {OPP.get(k[1], k[1])} | ' + ' | '.join(f'{fmt.format(x[c])} → {fmt.format(y[c])}' for c, _, fmt in COLS) + ' |')

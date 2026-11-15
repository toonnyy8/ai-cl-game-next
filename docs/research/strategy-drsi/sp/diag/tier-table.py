#!/usr/bin/env python3
"""tier-table.py NAME [NAME ...]: run-tier.sh's JSON (diag/tier/<hi>-<lo>-<NAME>.json) as one markdown table per world: each rung's cell
shares, * = fails ladder.py's rule (one-sided 95 % Wilson low < .70: under 151 of 200), [n] = matches at the bell when over 50 of 200."""
import json, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from ladder import wilson_lo   # noqa: E402  (the ladder's own rule)

D = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'tier')
RUNGS = [('easy', 'masher'), ('normal', 'masher'), ('normal', 'easy'), ('hard', 'normal')]
CELLS = [a + b for a in 'KIH' for b in 'KIH']
for name in sys.argv[1:]:
    print(f'\n{name}\n\n| rung | ' + ' | '.join(CELLS) + ' | pass |\n|---|' + '---|' * (len(CELLS) + 1))
    for hi, lo in RUNGS:
        p = os.path.join(D, f'{hi}-{lo}-{name}.json')
        if not os.path.exists(p):
            continue
        j = json.load(open(p)); n = j['n'] // len(j['cells'])
        row, ok = [], 0
        for c in CELLS:
            if c not in j['cells']:
                row.append(''); continue
            s = j['cells'][c]; good = wilson_lo(s * n, n) >= 0.70; ok += good
            b = j['bells'][c]
            row.append(f"{s:.3f}{'' if good else '*'}{f' [{b}]' if b > n / 4 else ''}")
        print(f'| {hi[0].upper()}>{lo[0].upper()} | ' + ' | '.join(row) + f' | {ok} |')

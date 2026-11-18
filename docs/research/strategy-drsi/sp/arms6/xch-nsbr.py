#!/usr/bin/env python3
"""xch-nsbr.py (xch2.md §NS-BR): summarise xch/nsbr/*.txt: per Kenpachi NS arm (STRAT_XNS), Ichigo's shipped / j win rate in KI and
Hisagi's shipped / j / ownj in KH (the J side's character's win rate; SE about .035 at 200 matches)."""
import glob, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROW = re.compile(r'^\s*(\w+): (\w+) wins (\d+) / (\d+) = ([\d.]+)')
print('NS arm (Kenpachi) | KI Ichigo shipped | KI Ichigo j | KH Hisagi shipped | KH Hisagi j | KH Hisagi ownj')
for f in sys.argv[1:] or sorted(glob.glob(os.path.join(HERE, 'xch/nsbr/*.txt'))):
    r = {}
    for l in open(f):
        m = ROW.match(l)
        if m:
            r[(m[2], m[1])] = float(m[5])
    cell = lambda k: f'{r[k]:.3f}' if k in r else '  -  '
    print(f'{os.path.basename(f)[:-4]:>10} | {cell(("ichigo", "shipped"))} | {cell(("ichigo", "j"))} | {cell(("hisagi", "shipped"))} | '
          f'{cell(("hisagi", "j"))} | {cell(("hisagi", "ownj"))}')

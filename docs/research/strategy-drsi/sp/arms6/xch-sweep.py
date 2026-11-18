#!/usr/bin/env python3
"""xch-sweep.py (q4-defence, xch2.md): summarise the sweep files xch/sweep/*.txt (each: the four J sides' `xch.py ab` blocks under one
STRAT_SET of the exchange knobs). Per config and side: the shipped J side's win rate and the best fixed J policy's (its name); then the worst
side's best policy and the mean over the sides of best - shipped (how far a fixed policy beats the shipped AS).
  python3 xch-sweep.py [FILE ...]"""
import glob, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
HEAD = re.compile(r'^xch ab (\w+) (\w+) J-side')
ROW = re.compile(r'^\s*(\w+): \w+ wins (\d+) / (\d+) = ([\d.]+)')
files = sys.argv[1:] or sorted(glob.glob(os.path.join(HERE, 'xch/sweep/*.txt')))
print('config | ' + ' | '.join(f'{s:>22}' for s in ('ki kenpachi', 'kh kenpachi', 'kh hisagi', 'ki ichigo'))
      + ' | worst best | mean best - shipped')
for f in files:
    side, res = None, {}
    for l in open(f):
        m = HEAD.match(l)
        if m:
            side = f'{m[1]} {m[2]}'
            res[side] = {}
            continue
        m = ROW.match(l)
        if m and side:
            res[side][m[1]] = float(m[4])
    cells, bests, gaps = [], [], []
    for s in ('ki kenpachi', 'kh kenpachi', 'kh hisagi', 'ki ichigo'):
        r = res.get(s)
        if not r or 'shipped' not in r:
            cells.append(' ' * 22)
            continue
        b = max(r, key=r.get)
        cells.append(f'{r["shipped"]:.3f} / {r[b]:.3f} {b:>7}')
        bests.append(r[b])
        gaps.append(r[b] - r['shipped'])
    tail = f'{max(bests):.3f} | {sum(gaps) / len(gaps):+.3f}' if bests else ''
    print(f'{os.path.basename(f)[:-4]:>12} | ' + ' | '.join(cells) + ' | ' + tail)

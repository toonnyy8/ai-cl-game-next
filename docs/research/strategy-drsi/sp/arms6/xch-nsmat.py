#!/usr/bin/env python3
"""xch-nsmat.py (xch2.md §NS-BR): KI's match-level matrix from xch/nsmat/*.txt: Ichigo's J-side policies (rows: shipped / own / ownj / j)
x Kenpachi's fixed NS arms (columns), Ichigo's win rate; then the zero-sum mixed equilibrium (Ichigo maximises, Kenpachi minimises) by
fictitious play, with each side's mix and the game value.
  python3 xch-nsmat.py [--iters 200000] [--arms a,b,...]"""
import argparse, glob, os, re
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROW = re.compile(r'^\s*(\w+): ichigo wins (\d+) / (\d+) = ([\d.]+)')
ap = argparse.ArgumentParser()
ap.add_argument('--iters', type=int, default=200000)
ap.add_argument('--arms', default='')
o = ap.parse_args()
cols = {}
for f in sorted(glob.glob(os.path.join(HERE, 'xch/nsmat/*.txt'))):
    r = {}
    for l in open(f):
        m = ROW.match(l)
        if m:
            r[m[1]] = float(m[4])
    cols[os.path.basename(f)[:-4]] = r
arms = o.arms.split(',') if o.arms else sorted(cols)
pols = ['shipped', 'own', 'ownj', 'j']
A = np.array([[cols[a][p] for a in arms] for p in pols])
print('Ichigo win rate | ' + ' | '.join(f'{a:>8}' for a in arms))
for i, p in enumerate(pols):
    print(f'{p:>15} | ' + ' | '.join(f'{A[i, k]:8.3f}' for k in range(len(arms))))
print('  column max (his best fixed policy) | ' + ' | '.join(f'{A[:, k].max():8.3f}' for k in range(len(arms))))
# fictitious play
rc = np.zeros(len(pols)); cc = np.zeros(len(arms))
i, k = 0, 0
for t in range(o.iters):
    rc[i] += 1; cc[k] += 1
    i = int(np.argmax(A @ cc))
    k = int(np.argmin(rc @ A))
x = rc / rc.sum(); y = cc / cc.sum()
print(f'value about {float(x @ A @ y):.3f} (bounds: Ichigo guarantees {float((x @ A).min()):.3f}, Kenpachi holds him to {float((A @ y).max()):.3f})')
print('Ichigo mix: ' + ', '.join(f'{p} {v:.3f}' for p, v in zip(pols, x) if v > 0.005))
print('Kenpachi NS mix: ' + ', '.join(f'{a} {v:.3f}' for a, v in zip(arms, y) if v > 0.005))
print('each J policy against that NS mix: ' + ', '.join(f'{p} {v:.3f}' for p, v in zip(pols, A @ y)))

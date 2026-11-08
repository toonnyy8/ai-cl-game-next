#!/usr/bin/env python3
"""Two teacher tables side by side (docs/duel/DUEL_AI_TEACHER.md §7): per situation with 40+ points, each round's best action and value,
and the rank correlation of the ten actions' values. Usage: python3 tools/teach-compare.py A.lisp B.lisp"""
import re, sys
ACT = ['j1', 'sp', 'hoho', 'step-in', 'step-out', 'step-side', 'guard', 'wait', 'walk-in', 'walk-out']
def load(p):
    t = {}
    for l in open(p):
        m = re.match(r'\(setf \(gethash \(list ((?::\S+ ?)+)\) \*teach-table\*\) \(vector (\d+) (.*)\)\)', l)
        if m: t[tuple(x.strip(':') for x in m.group(1).split())] = (int(m.group(2)), [float(x) for x in m.group(3).split()])
    return t
def ranks(v): o = sorted(range(len(v)), key=lambda i: v[i]); r = [0] * len(v); [r.__setitem__(i, k) for k, i in enumerate(o)]; return r
def spearman(a, b):
    ra, rb, n = ranks(a), ranks(b), len(a)
    return 1 - 6 * sum((x - y) ** 2 for x, y in zip(ra, rb)) / (n * (n * n - 1))
A, B = load(sys.argv[1]), load(sys.argv[2])
same = tot = 0; rs = []
print('character band   opponent        n    A best              B best              rank r')
for k in sorted(A):
    if k not in B or A[k][0] < 40: continue
    a, b = A[k][1], B[k][1]; ia, ib = a.index(max(a)), b.index(max(b)); r = spearman(a, b); rs.append(r)
    tot += 1; same += ia == ib
    print(f'{" ".join(k):38} {A[k][0]:4}  {ACT[ia]:9} {a[ia]:+.3f}    {ACT[ib]:9} {b[ib]:+.3f}    {r:+.2f}')
print(f'best action unchanged in {same} of {tot}; mean rank correlation {sum(rs) / len(rs):.2f}')

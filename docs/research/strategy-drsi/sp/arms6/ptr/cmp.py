#!/usr/bin/env python3
"""cmp.py BASE.txt NEW.txt — ladder.py tables compared per cell: share before -> after, the change in standard errors (sqrt(p(1-p)/n) of the
pooled share), pass before / after, the bell counts."""
import re, sys
CELL = re.compile(r'^(\w\w) (\S+) (\w\w)\s+\|\s+(\d+) \|.*\| (\d\.\d+)\s+\S+ \| (PASS|fail) \|\s+(\d+)')


def cells(path):
    return {(m[1], m[3]): (int(m[4]), float(m[5]), m[6], int(m[7])) for l in open(path) for m in [CELL.match(l)] if m}


a, b = cells(sys.argv[1]), cells(sys.argv[2])
npass = 0
for k in a:
    if k not in b:
        npass += a[k][2] == 'PASS'
        continue
    n, p0, s0, t0 = a[k]
    _, p1, s1, t1 = b[k]
    npass += s1 == 'PASS'
    se = max(((p0 + p1) / 2 * (1 - (p0 + p1) / 2) / n) ** 0.5, 1e-9)
    flag = ' LOST' if s0 == 'PASS' and s1 != 'PASS' else (' GAINED' if s1 == 'PASS' and s0 != 'PASS' else '')
    print(f'{k[0]} {k[1]}  {p0:.3f} -> {p1:.3f}  ({(p1 - p0) / se:+.1f} se)  {s0} -> {s1}{flag}  bell {t0} -> {t1}')
print(f'{npass} of {len(a)} pass (cells missing from NEW keep BASE)')

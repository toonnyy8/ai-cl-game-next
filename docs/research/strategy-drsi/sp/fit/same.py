#!/usr/bin/env python3
"""same.py TAG_A TAG_B: the identity check (DUEL_AI_STRATEGY §8.19's form): two sw.py logs (fq/switch/logs/<tag>/) on the same seeds and
seats, their gate rows and `duel hash` lines compared file by file. Prints the counts and exits 1 on any difference."""
import gzip, os, sys
L = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../fq/switch/logs')


def lines(tag):
    out = {}
    for fn in sorted(os.listdir(os.path.join(L, tag))):
        if fn.endswith('.out.gz'):
            key = fn.split('-', 3)[-1]                                       # (seat-lo-hi, without the salt / eps)
            out[key] = [l for l in gzip.open(os.path.join(L, tag, fn), 'rt') if l.startswith(('duel gate row ', 'duel hash'))]
    return out


a, b = lines(sys.argv[1]), lines(sys.argv[2])
assert a.keys() == b.keys(), (sorted(a), sorted(b))
n = sum(len(v) for v in a.values())
diff = [k for k in a if a[k] != b[k]]
rows = sum(l.startswith('duel gate row') for v in a.values() for l in v)
print(f'{sys.argv[1]} vs {sys.argv[2]}: {len(a)} files, {rows} gate rows, {n - rows} hash lines, {"identical" if not diff else "DIFFER: " + str(diff)}')
sys.exit(1 if diff else 0)

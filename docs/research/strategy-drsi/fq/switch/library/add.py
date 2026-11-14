#!/usr/bin/env python3
"""add.py — append unit-format entries (entry.py's output) to duel/lisp/strategy.lisp's *STRAT-LIBRARY*, each after its comment lines, and
point *STRAT-LOOKUP*'s row for (ME VS) at it (DUEL_AI_STRATEGY §10). An entry whose id is already there replaces it in place (§11.27).
usage: add.py ENTRY-FILE ME VS "COMMENT LINE" ["COMMENT LINE" ...]"""
import os, sys
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../../../..'))
path = os.path.join(ROOT, 'duel/lisp/strategy.lisp')
entry_file, me, vs, comments = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
entry = open(entry_file).read().strip()
nid = entry.split()[1]
s = open(path).read()
k = s.index('\n  "Every strategy, composite and Q table, expanded from the units above')
head = s[:k]
assert head.endswith('))'), head[-20:]
block = ''.join(f'\n    ;; {c}' for c in comments) + '\n    ' + entry
i = head.find(f'\n    (:id {nid} ')
if i < 0:
    s = head[:-2] + block + '))' + s[k:]
else:   # an entry of that id exists (a re-collection reuses :f-<file>, §11.27): replace it and its comment lines in place, no duplicate
    d, e = 0, i + 5
    while True:
        d += {'(': 1, ')': -1}.get(s[e], 0)
        if d == 0:
            break
        e += 1
    while s[s.rindex('\n', 0, i) + 1:i].startswith('    ;; '):
        i = s.rindex('\n', 0, i)
    s = s[:i] + block + s[e + 1:]
import re
row = re.compile(r'\(:' + me + r' :' + vs + r' :hard :([a-z0-9-]+)\)')
m = row.search(s)
assert m, 'no lookup row'
old = m.group(1)
s = s[:m.start()] + f'(:{me} :{vs} :hard {nid})' + s[m.end():]
open(path, 'w').write(s)
print(f'{nid} added; lookup {me} vs {vs}: :{old} -> {nid}')

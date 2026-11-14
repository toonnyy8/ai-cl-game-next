#!/usr/bin/env python3
"""units.py — the arm units the final tables need that *STRAT-UNITS* lacks (DUEL_AI_STRATEGY §10, §11.16): each inline :fn arm of the
nine final tables as (:id ID :style ST ...its other keys...), ST the style unit of its :fn. Ids seen twice must be the same arm.
usage: units.py TABLE...   -> the unit lines on stdout (paste into *STRAT-UNITS*, then run ../../fq/switch/library/entry.py)"""
import os, sys
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../fq/switch/library'))
import contextlib, io  # noqa: E402
_argv, sys.argv = sys.argv, [sys.argv[0], os.path.join(os.path.dirname(os.path.abspath(__file__)), 'kh-hisagi.lisp'), ':x']
with contextlib.redirect_stdout(io.StringIO()):
    import entry  # noqa: E402  (entry.py runs on import: it reads strategy.lisp, then converts one table; kh-hisagi's arms are all units)
sys.argv = _argv
from sexp import read_all, show, pget, pkeys  # noqa: E402

style_of = {pget(s, ':fn'): pget(s, ':id') for s in entry.styles.values() if pget(s, ':fn')}
seen = {}
for f in sys.argv[1:]:
    for a in pget(pget(read_all(open(f).read())[0], ':fq'), ':arms'):
        if a == 'nil' or entry.norm(a) in entry.unit_of:
            continue
        aid, fn = pget(a, ':id'), pget(a, ':fn')
        if fn not in style_of:
            sys.exit(f'units.py: no style unit has :fn {fn} (add it to *STRAT-STYLES*)')
        st = entry.styles[style_of[fn]]
        rest = ''.join(f' {k} {show(pget(a, k))}' for k in pkeys(a) if k not in (':id', ':fn') and show(pget(a, k)) != show(pget(st, k)))
        line = f'(:id {aid} :style {style_of[fn]}{rest})'
        if aid in seen and seen[aid] != line:
            sys.exit(f'units.py: {aid} names two different arms')
        seen[aid] = line
print('\n'.join(seen.values()))

#!/usr/bin/env python3
# splice-tests.py — a cell's BARRO-CPU-TESTS section into the frozen host test (DUEL_LILLE_V3 §22; rescore.sh calls it).
# Only the lines between the markers of the CELL's copy of tests/duel-rules/barro.lisp are used (or of a whole pre-split duel-rules-test.lisp: only the markers matter); everything outside them is the
# FROZEN file's. The section's diff vs the frozen one is written for the coordinator's review (the checks must still pin
# the cell's own shipped values and may not weaken tests of shared behaviour, rules, hooks or other characters).
# usage: splice-tests.py <cell's copy of tests/duel-rules/barro.lisp> <the frozen tests/duel-rules/barro.lisp, rewritten in place> <diff out>
import difflib, sys

BEGIN, END = ';;; >>> BEGIN BARRO-CPU-TESTS', ';;; <<< END BARRO-CPU-TESTS'


def parts(path):
    """PATH's lines: (up to the BEGIN marker's comment block, the section, from the END marker)."""
    L = open(path).read().splitlines(keepends=True)
    b = [i for i, l in enumerate(L) if l.startswith(BEGIN)]
    e = [i for i, l in enumerate(L) if l.startswith(END)]
    if len(b) != 1 or len(e) != 1 or b[0] > e[0]:
        sys.exit(f'{path}: want one BEGIN and one END BARRO-CPU-TESTS marker, in that order')
    i = b[0]
    while i + 1 < e[0] and L[i + 1].startswith(';;;'):          # (the BEGIN marker's comment block)
        i += 1
    return L[:i + 1], L[i + 1:e[0]], L[e[0]:]


cell, frozen = parts(sys.argv[1]), parts(sys.argv[2])
with open(sys.argv[3], 'w') as f:
    f.writelines(difflib.unified_diff(frozen[1], cell[1], 'frozen BARRO-CPU-TESTS', 'cell BARRO-CPU-TESTS'))
with open(sys.argv[2], 'w') as f:
    f.writelines(frozen[0] + cell[1] + frozen[2])

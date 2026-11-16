#!/bin/sh
# add.sh — p9-ih's IH Ichigo table into duel/lisp/strategy.lisp (as arms5/t0/add.sh did): the two new arm units (:i6-economy, :i6-punish;
# final/units.py writes them) after the last unit block, then entry.py + add.py replace :t0-ih-ichigo in place. The unit :d-x-ih-i's
# base was edited by hand (its comment there). Run from the repo root after `python3 docs/research/strategy-drsi/sp/arms6/cands.py final`;
# idempotent; OUT a scratch directory.
set -e
D=docs/research/strategy-drsi/sp/arms6/ih
L=docs/research/strategy-drsi/fq/switch/library
OUT=${OUT:-/tmp}
python3 docs/research/strategy-drsi/sp/final/units.py $D/t0-ih-ichigo.lisp > $OUT/i6-units.txt
python3 - $OUT/i6-units.txt <<'EOF'
import sys
p = 'duel/lisp/strategy.lisp'
s, new = open(p).read(), [l.strip() for l in open(sys.argv[1]) if l.strip()]
new = [l for l in new if f'\n    {l}' not in s]
if new:
    end = s.index('\n  "The arm units: a style + data units')
    assert s[:end].endswith(')))'), s[end - 20:end]
    block = ('\n    ;; p9-ih\'s IH Ichigo job arms on arm 0\'s neutral (brawl: patience off, the ptr3 mode, no shut-gauge lunge), each its job key on top'
             '\n    ;; (docs/research/strategy-drsi/sp/arms6/ih.md; sp/final/units.py writes them)' + ''.join('\n    ' + l for l in new))
    s = s[:end - 1] + block + ')' + s[end:]
    open(p, 'w').write(s)
print(f'{len(new)} units added')
EOF
python3 $L/entry.py $D/t0-ih-ichigo.lisp :t0-ih-ichigo > $OUT/t0-ih-ichigo.entry
python3 $L/add.py $OUT/t0-ih-ichigo.entry ichigo hisagi "p9-ih (2026-11-17; was arms5's T0, checkpoint 2c, DUEL_AI_STRATEGY §11.29): arms5's job map and q for arm 0 / economy / punish / kessa-lunge, arm 0 = brawl, economy and punish on its neutral, the unit :d-x-ih-i with the clash on: $D/t0-ih-ichigo.lisp, docs/research/strategy-drsi/sp/arms6/ih.md"

#!/bin/sh
# add.sh — checkpoint 2b (the user, 2026-11-15, 「先保留 B4 舊表」): four arms5 final T0 tables replace B4's entries of the same ids in
# duel/lisp/strategy.lisp's *STRAT-LIBRARY* (add.py replaces in place; *STRAT-LOOKUP*'s rows already point at the ids). KH (both), IH (both)
# and HH keep B4's (arms4/t0final/add.sh). First the arms5 arm units *STRAT-UNITS* lacks (sp/final/units.py's lines, k5-* / a5-i-*) go in
# after B4's one-job block (skipped when there), then entry.py + add.py per table. Run from the repo root; OUT a scratch directory.
set -e
D=docs/research/strategy-drsi/sp/arms5/t0
L=docs/research/strategy-drsi/fq/switch/library
OUT=${OUT:-/tmp}
python3 docs/research/strategy-drsi/sp/final/units.py $D/t0-ki-kenpachi.lisp $D/t0-ki-ichigo.lisp $D/t0-kk-kenpachi.lisp $D/t0-ii-ichigo.lisp > $OUT/arms5-units.txt
python3 - $OUT/arms5-units.txt <<'EOF'
import sys
p = 'duel/lisp/strategy.lisp'
s, new = open(p).read(), [l.strip() for l in open(sys.argv[1]) if l.strip()]
if new:
    end = s.index('\n  "The arm units: a style + data units')
    assert s[:end].endswith(')))'), s[end - 20:end]
    block = ('\n    ;; checkpoint 2b\'s arms5 one-job arms in four T0 tables (DUEL_AI_STRATEGY §11.29; docs/research/strategy-drsi/sp/arms5/inband.md §5;'
             '\n    ;; sp/final/units.py writes them): Kenpachi poke wake climb, Ichigo answer economy punish kessa-lunge (k5-all = :c-ki-k-r2-b1a2)'
             + ''.join('\n    ' + l for l in new))
    s = s[:end - 1] + block + ')' + s[end:]
    open(p, 'w').write(s)
print(f'{len(new)} units added')
EOF
while read t me vs; do
  python3 $L/entry.py $D/t0-$t.lisp :t0-$t > $OUT/t0-$t.entry
  python3 $L/add.py $OUT/t0-$t.entry $me $vs "PLAN4's T0, arms5 (checkpoint 2b, DUEL_AI_STRATEGY §11.29; was B4's arms4/t0final/t0-$t.lisp): one-job arms admitted in band, switched by a designed :rb-sp2 job map (arm k +q in its job rules, -q / n in the rest of its groups), :keep-state, the pairing's :with exchange unit: $D/t0-$t.lisp"
done <<EOF
ki-ichigo ichigo kenpachi
ki-kenpachi kenpachi ichigo
kk-kenpachi kenpachi kenpachi
ii-ichigo ichigo ichigo
EOF

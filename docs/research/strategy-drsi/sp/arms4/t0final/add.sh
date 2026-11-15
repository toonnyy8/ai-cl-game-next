#!/bin/sh
# add.sh — B4's nine T0 tables into duel/lisp/strategy.lisp's *STRAT-LIBRARY* as :t0-<pair>-<side> and *STRAT-LOOKUP*'s nine rows pointed at
# them, by §10's path (sp/final/add.sh's): units.py's arm units pasted into *STRAT-UNITS* and the :d-x-* exchange units into *STRAT-DATA*
# first, then entry.py + add.py per table. Run from the repo root; OUT a scratch directory for the entry files.
set -e
D=docs/research/strategy-drsi/sp/arms4/t0final
L=docs/research/strategy-drsi/fq/switch/library
OUT=${OUT:-/tmp}
while read t me vs; do
  python3 $L/entry.py $D/t0-$t.lisp :t0-$t > $OUT/t0-$t.entry
  python3 $L/add.py $OUT/t0-$t.entry $me $vs "PLAN4's T0 (B4, DUEL_AI_STRATEGY §11.29): one-job arms switched by a designed :rb-sp2 job map (arm k +q in its job rules, -q / n in the rest of its groups), :keep-state, the pairing's :with exchange unit: $D/t0-$t.lisp"
done <<EOF
ki-ichigo ichigo kenpachi
ki-kenpachi kenpachi ichigo
kh-kenpachi kenpachi hisagi
kh-hisagi hisagi kenpachi
ih-ichigo ichigo hisagi
ih-hisagi hisagi ichigo
kk-kenpachi kenpachi kenpachi
ii-ichigo ichigo ichigo
hh-hisagi hisagi hisagi
EOF

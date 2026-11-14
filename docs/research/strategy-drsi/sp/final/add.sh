#!/bin/sh
# add.sh — the nine final tables into duel/lisp/strategy.lisp's *STRAT-LIBRARY* as :f-<file> and the HARD lookup pointed at them
# (DUEL_AI_STRATEGY §11.16), by §10's path: units.py's arm units pasted into *STRAT-UNITS* first, then entry.py + add.py per table.
# Run from the repo root; OUT a scratch directory for the entry files.
set -e
D=docs/research/strategy-drsi/sp/final
L=docs/research/strategy-drsi/fq/switch/library
OUT=${OUT:-/tmp}
while read t me vs kind; do
  python3 $L/entry.py $D/$t.lisp :f-$t > $OUT/$t.entry
  python3 $L/add.py $OUT/$t.entry $me $vs "the SP re-collection's final table, $kind (DUEL_AI_STRATEGY §11.15-§11.16): $D/$t.lisp"
done <<EOF
ki-ichigo ichigo kenpachi gaining
ki-kenpachi kenpachi ichigo fallback
kh-kenpachi kenpachi hisagi fallback
kh-hisagi hisagi kenpachi fallback
ih-ichigo ichigo hisagi fallback
ih-hisagi hisagi ichigo fallback
kk-kenpachi kenpachi kenpachi fallback
ii-ichigo ichigo ichigo fallback
hh-hisagi hisagi hisagi fallback
EOF

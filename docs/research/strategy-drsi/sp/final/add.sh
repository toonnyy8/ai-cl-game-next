#!/bin/sh
# add.sh — the final tables into duel/lisp/strategy.lisp's *STRAT-LIBRARY* as :f-<file> and the HARD lookup pointed at them, by §10's
# path: units.py's arm units pasted into *STRAT-UNITS* first, then entry.py + add.py per table (add.py replaces an :f-<file> in place).
# §11.16 (2026-11-14) added all nine; §11.27 (2026-11-15, PLAN3 re-collection) re-added the five tables that passed their ship test.
# Run from the repo root; OUT a scratch directory for the entry files.
set -e
D=docs/research/strategy-drsi/sp/final
L=docs/research/strategy-drsi/fq/switch/library
OUT=${OUT:-/tmp}
while read t me vs kind; do
  python3 $L/entry.py $D/$t.lisp :f-$t > $OUT/$t.entry
  python3 $L/add.py $OUT/$t.entry $me $vs "the re-collection's final table after the exchange rules, $kind (DUEL_AI_STRATEGY §11.27, PLAN3 re-collection; first §11.16): $D/$t.lisp"
done <<EOF
ki-kenpachi kenpachi ichigo fallback
ki-ichigo ichigo kenpachi fallback
kh-kenpachi kenpachi hisagi fallback
kh-hisagi hisagi kenpachi fallback
ih-ichigo ichigo hisagi fallback
EOF

#!/bin/sh
# add.sh — arms6/hh's HH table (t/t21.lisp) replaces B4's :t0-hh-hisagi in duel/lisp/strategy.lisp's *STRAT-LIBRARY* in place (same id:
# *STRAT-LOOKUP*'s HH row already points at it). Its three arms are existing units (:a-generic, :h5-all, :c-ih-h-r1-b2a0), so no unit is
# added. Run from the repo root; idempotent (add.py replaces an entry of the same id); OUT a scratch directory.
set -e
D=docs/research/strategy-drsi/sp/arms6/hh
L=docs/research/strategy-drsi/fq/switch/library
OUT=${OUT:-/tmp}
python3 $L/entry.py $D/t/t21.lisp :t0-hh-hisagi > $OUT/t0-hh-hisagi.entry
python3 $L/add.py $OUT/t0-hh-hisagi.entry hisagi hisagi \
  "arms6/hh (p9-hh, DUEL_AI_STRATEGY §11.29's HH rework; was B4's arms4/t0final/t0-hh-hisagi.lisp, which ran to the bell in 80 of 80 HARD mirrors): arm 0 the generic CPU + MCTS;" \
  "in the ranged mode h5-all (his own style) while he attacks (G2 atk) and c-ih-h-r1-b2a0 otherwise; no :with (a mirror): $D/t/t21.lisp, record docs/research/strategy-drsi/sp/arms6/hh.md"

#!/bin/sh
# hkmulti/start.sh — step 10's arms (DUEL_AI_STRATEGY §8.19 round 5, step 10; the user, 2026-11-10: 「新增一鍵開多條規則」), from the switch
# directory, on the build with duel/lisp/cpu-hk-hisagi.lisp (hksplit/split.py on round 3's b3_a1: each rule's action under its own key):
#   hk9.arms = HK's five arms + the three one-job arms (wake, pot, kite: strategy.lisp :a-hk-wake / :a-hk-pot / :a-hk-kite) + the arm that
#   turns all three on together (:a-hk-all = :st-hisagi-hk + :d-hk-wake :d-hk-pot :d-hk-kite), written inline as their units expand
#   (strat-run.lisp reads a research file raw); hk9-t0.lisp = :qhs-ken extended with them (each 1 below every row: never chosen), proved =
#   the live HK lookup (identity-t0-600.jsonl). The pairs (wake + pot ...) are left out: the log's run exploration spreads over every arm,
#   and step 9 found the gain needs all three rules at once.
set -e
S='(:fn hisagi-hk-style :ken-ranged t :apply (:hisagi)'
{ cat arms/hk.arms
  echo ";; step 10: Hisagi's three one-job rules (hkfn round 3's b3_a1, split): the wake-up punish / guard, the Reishi pot, the kite; then all three on"
  echo "(:id :a-hk-wake ${S#(} :base (:hk-wake 1.0))"
  echo "(:id :a-hk-pot ${S#(} :base (:hk-pot 1.0))"
  echo "(:id :a-hk-kite ${S#(} :base (:hk-kite 1.0))"
  echo "(:id :a-hk-all ${S#(} :base (:hk-wake 1.0 :hk-pot 1.0 :hk-kite 1.0))"; } > hkmulti/hk9.arms
python3 -B khjoint/extend.py --me hisagi --vs kenpachi --arms arms/hk.arms --table corefit/hk-r1.lisp --new-arms hkmulti/hk9.arms --out hkmulti/hk9-t0.lisp
cd ../../../../..
F=docs/research/strategy-drsi/fq
python3 $F/proof/identity.py hisagi kenpachi $F/switch/khevent/kh-t0.lisp $F/switch/hkmulti/hk9-t0.lisp > $F/switch/hkmulti/identity-t0-600.jsonl

#!/bin/sh
# hksplit/start.sh — step 9's split (DUEL_AI_STRATEGY §8.19 round 5, step 9), from the switch directory, on the build with the split
# cpu-hk-hisagi.lisp (split.py: one HISAGI-HK-STYLE, each rule's action gated by a strategy key, :hk-wake / :hk-pot / :hk-kite):
#   1. fidelity: the style with all three keys on, played whole (one-arm table), against the live KH on 601-800 -> ev/hsa-kh-*.json, to pair
#      seed by seed with the bundle's ev/hsb-kh-* (identical = the split code is the bundle's code);
#   2. hk8.arms = HK's five arms + the three one-job arms (wake, pot, kite); hk8-t0.lisp = :qhs-ken extended with them (never chosen),
#      proved = the live HK lookup (identity-t0-600.jsonl);
#   3. the diagnostic pinned table hk8-pin.lisp: hk8-t0 with a G1 bonus of 10 per form in each distance band (1.0 is not enough: a new
#      arm sits 1 below every row in all five groups), close -> wake, mid -> kite, far -> pot: whether switching between the arms can hold
#      the gain at all (not a rule candidate), measured against the live KH and the stand-in on 601-800 -> ev/hsq-*.json
set -e
W='(:id :hk-wake :fn hisagi-hk-style :ken-ranged t :apply (:hisagi) :base (:hk-wake 1.0))'
P='(:id :hk-pot :fn hisagi-hk-style :ken-ranged t :apply (:hisagi) :base (:hk-pot 1.0))'
K='(:id :hk-kite :fn hisagi-hk-style :ken-ranged t :apply (:hisagi) :base (:hk-kite 1.0))'
echo '(:id :hk-allon :fn hisagi-hk-style :ken-ranged t :apply (:hisagi) :base (:hk-wake 1.0 :hk-pot 1.0 :hk-kite 1.0))' > hksplit/allon.arms
python3 sw.py start --me hisagi --vs kenpachi --arms hksplit/allon.arms --period 30 --out hksplit/allon-t.lisp
for b in 601-700 701-800; do
  python3 sw.py measure --me hisagi --vs kenpachi --opp khevent/kh-t0.lisp --arms hksplit/allon.arms --table hksplit/allon-t.lisp --tag ev/hsa-kh-${b%%-*} --seeds $b -j 20 > /dev/null
done
{ cat arms/hk.arms
  echo ";; one-job arms of round 5 step 9's split (hkfn round 3's b3_a1): the wake-up punish / guard, the Reishi pot, the kite"
  echo "$W"; echo "$P"; echo "$K"; } > hksplit/hk8.arms
python3 -B khjoint/extend.py --me hisagi --vs kenpachi --arms arms/hk.arms --table corefit/hk-r1.lisp --new-arms hksplit/hk8.arms --out hksplit/hk8-t0.lisp
T=hksplit/hk8-t0.lisp
for f in 0 1 2; do
  for ab in "5 close" "7 mid" "6 far"; do
    set -- $ab
    python3 sw.py pin --me hisagi --vs kenpachi --arms hksplit/hk8.arms --table $T --out hksplit/hk8-pin.lisp --form $f --arm $1 --bonus 10.0 --band $2
    T=hksplit/hk8-pin.lisp
  done
done
for o in "kh khevent/kh-t0.lisp" "fz ../../counter/frozen/ki-ken.lisp"; do
  set -- $o
  for b in 601-700 701-800; do
    python3 sw.py measure --me hisagi --vs kenpachi --opp $2 --arms hksplit/hk8.arms --table hksplit/hk8-pin.lisp --tag ev/hsq-$1-${b%%-*} --seeds $b -j 20 > /dev/null
  done
done
cd ../../../../..
F=docs/research/strategy-drsi/fq
python3 $F/proof/identity.py hisagi kenpachi $F/switch/khevent/kh-t0.lisp $F/switch/hksplit/hk8-t0.lisp > $F/switch/hksplit/identity-t0-600.jsonl

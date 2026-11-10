#!/bin/sh
# hksplit/bundle.sh — step 9's reference (DUEL_AI_STRATEGY §8.19 round 5, step 9), from the switch directory, on the build with round 3's b3_a1
# (the three-rule bundle) as duel/lisp/cpu-hk-hisagi.lisp: the bundle played whole as a one-arm table (sw.py start: arm 0 everywhere), measured
# against the live KH :qks5-hisagi and the stand-in (Kenpachi's KI style CPU) on 601-700 / 701-800 -> ev/hsb-*.json (per-seed wins, so the
# split tables pair against it). Never a candidate: the bundle is two rules too many (the user's keep rule).
set -e
echo '(:id :hk-bundle :fn hisagi-hk-style :ken-ranged t :apply (:hisagi))' > hksplit/bundle.arms
python3 sw.py start --me hisagi --vs kenpachi --arms hksplit/bundle.arms --period 30 --out hksplit/bundle-t.lisp
for o in "kh khevent/kh-t0.lisp" "fz ../../counter/frozen/ki-ken.lisp"; do
  set -- $o
  for b in 601-700 701-800; do
    python3 sw.py measure --me hisagi --vs kenpachi --opp $2 --arms hksplit/bundle.arms --table hksplit/bundle-t.lisp --tag ev/hsb-$1-${b%%-*} --seeds $b -j 20 > /dev/null
  done
done

#!/bin/sh
# khjoint/iterate.sh T KH_T HK_T "KH_POOL" "HK_POOL" — one iteration of KH and HK optimised together (DUEL_AI_STRATEGY §8.19 round 5, step 4,
# joint/iterate.sh's method), from the switch directory: both sides logged from their current iterates (+ runs, 2 salts x seeds 1-599 x both
# seats) against their opponent pools (comma lists: the other side's past iterates [+ its frozen style CPU]), then both refit (gamma 0.98)
# -> OUT/kh-t<T+1>.lisp, OUT/hk-t<T+1>.lisp. Environment: KH_ARMS (default khjoint/kh.arms), HK_ARMS (khjoint/hk.arms), OUT (khjoint),
# TAGP (the log tags' prefix, j: jkh-t<T>, jhk-t<T>; step 5 uses its own), KH_EVENT (step 6: KH's tables carry this :KNOCKDOWN event arm).
set -e
T=$1; N=$((T + 1)); KA=${KH_ARMS:-khjoint/kh.arms}; HA=${HK_ARMS:-khjoint/hk.arms}; O=${OUT:-khjoint}; P=${TAGP:-j}
for s in 1 2; do
  python3 sw.py log --me kenpachi --vs hisagi --opp "$4" --arms $KA --table $2 --tag ${P}kh-t$T --salt $s -j ${J:-20} > /dev/null
  python3 sw.py log --me hisagi --vs kenpachi --opp "$5" --arms $HA --table $3 --tag ${P}hk-t$T --salt $s -j ${J:-20} > /dev/null
done
python3 sw.py fit --me kenpachi --vs hisagi --opp "$4" --arms $KA ${KH_EVENT:+--event "$KH_EVENT"} --tag ${P}kh-t$T --gamma 0.98 --out $O/kh-t$N.lisp > logs/${P}kh-t$T/fit.out 2>&1
python3 sw.py fit --me hisagi --vs kenpachi --opp "$5" --arms $HA --tag ${P}hk-t$T --gamma 0.98 --out $O/hk-t$N.lisp > logs/${P}hk-t$T/fit.out 2>&1

#!/bin/sh
# khjoint/iterate.sh T KH_T HK_T "KH_POOL" "HK_POOL" — one iteration of KH and HK optimised together (DUEL_AI_STRATEGY §8.19 round 5, step 4,
# joint/iterate.sh's method), from the switch directory: both sides logged from their current iterates (+ runs, 2 salts x seeds 1-599 x both
# seats) against their opponent pools (comma lists: the other side's past iterates [+ its frozen style CPU]), then both refit (gamma 0.98)
# -> khjoint/kh-t<T+1>.lisp, khjoint/hk-t<T+1>.lisp. The arms files: KH_ARMS (default khjoint/kh.arms), HK_ARMS (khjoint/hk.arms).
set -e
T=$1; N=$((T + 1)); KA=${KH_ARMS:-khjoint/kh.arms}; HA=${HK_ARMS:-khjoint/hk.arms}
for s in 1 2; do
  python3 sw.py log --me kenpachi --vs hisagi --opp "$4" --arms $KA --table $2 --tag jkh-t$T --salt $s -j ${J:-20} > /dev/null
  python3 sw.py log --me hisagi --vs kenpachi --opp "$5" --arms $HA --table $3 --tag jhk-t$T --salt $s -j ${J:-20} > /dev/null
done
python3 sw.py fit --me kenpachi --vs hisagi --opp "$4" --arms $KA --tag jkh-t$T --gamma 0.98 --out khjoint/kh-t$N.lisp > logs/jkh-t$T/fit.out 2>&1
python3 sw.py fit --me hisagi --vs kenpachi --opp "$5" --arms $HA --tag jhk-t$T --gamma 0.98 --out khjoint/hk-t$N.lisp > logs/jhk-t$T/fit.out 2>&1

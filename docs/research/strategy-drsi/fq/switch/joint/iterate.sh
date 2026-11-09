#!/bin/sh
# iterate.sh T KI_T IK_T "KI_POOL" "IK_POOL" — one iteration of KI and IK optimised together (DUEL_AI_STRATEGY §8.19 round 5, step 3; the user,
# 2026-11-09: 「請同時優化，不是一個做完再優化另一個」), from the switch directory: both sides logged from their current iterates (+ runs, 2 salts x
# seeds 1-599 x both seats) against their opponent pools (comma lists: every past iterate of the other side + its frozen style CPU), then both
# refit (gamma 0.98) -> joint/ki-t<T+1>.lisp, joint/ik-t<T+1>.lisp. The two sides run one after the other but see only iteration T's tables.
set -e
T=$1; N=$((T + 1))
for s in 1 2; do
  python3 sw.py log --me kenpachi --vs ichigo --opp "$4" --arms kenpachi/ki.arms --table $2 --tag jki-t$T --salt $s -j ${J:-20} > /dev/null
  python3 sw.py log --me ichigo --vs kenpachi --opp "$5" --arms ichigo/ik.arms --table $3 --tag jik-t$T --salt $s -j ${J:-20} > /dev/null
done
python3 sw.py fit --me kenpachi --vs ichigo --opp "$4" --arms kenpachi/ki.arms --tag jki-t$T --gamma 0.98 --out joint/ki-t$N.lisp > logs/jki-t$T/fit.out 2>&1
python3 sw.py fit --me ichigo --vs kenpachi --opp "$5" --arms ichigo/ik.arms --tag jik-t$T --gamma 0.98 --out joint/ik-t$N.lisp > logs/jik-t$T/fit.out 2>&1

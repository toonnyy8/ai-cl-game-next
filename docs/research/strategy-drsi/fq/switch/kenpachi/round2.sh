#!/bin/sh
# round2.sh P TABLE — a Kenpachi pairing's round 2 (DUEL_AI_STRATEGY §8.19 round 4), from the switch directory: 4 salts x seeds 1-599 x both
# seats with TABLE (round 1's pick on the selection block) + runs, then fits at gamma 0.966 / 0.98 -> kenpachi/P-r2-g*.lisp.
set -e
case $1 in
  ki) C="--me kenpachi --vs ichigo --opp ../../counter/frozen/ki-ichigo.lisp --arms kenpachi/ki.arms" ;;
  kh) C="--me kenpachi --vs hisagi --opp arms/ship-qh-ken.lisp --arms kenpachi/kh.arms" ;;
  kk) C="--me kenpachi --vs kenpachi --opp ../pairs/kk/kk-fit.lisp --arms kenpachi/kk.arms" ;;
esac
for s in 1 2 3 4; do python3 sw.py log $C --table $2 --tag k$1-r2 --salt $s -j ${J:-10} > /dev/null; done
for g in 0.966 0.98; do python3 sw.py fit $C --tag k$1-r2 --gamma $g --out kenpachi/$1-r2-g$g.lisp > logs/k$1-r2/fit-g$g.out 2>&1; done

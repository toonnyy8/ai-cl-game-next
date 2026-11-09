#!/bin/sh
# measure.sh P TAG TABLE [SEEDS] — one Kenpachi measure (DUEL_AI_STRATEGY §8.19 round 4), from the switch directory: P = ki / kh / kk picks the
# opponent and the arms file; ev/TAG.json gets the summary (sw.py measure).
set -e
case $1 in
  ki) C="--me kenpachi --vs ichigo --opp ../../counter/frozen/ki-ichigo.lisp --arms kenpachi/ki.arms" ;;
  kh) C="--me kenpachi --vs hisagi --opp arms/ship-qh-ken.lisp --arms kenpachi/kh.arms" ;;
  kk) C="--me kenpachi --vs kenpachi --opp ../pairs/kk/kk-fit.lisp --arms kenpachi/kk.arms" ;;
esac
python3 sw.py measure $C --table $3 --tag ev/$2 --seeds ${4:-801-1000} -j ${J:-8} > /dev/null

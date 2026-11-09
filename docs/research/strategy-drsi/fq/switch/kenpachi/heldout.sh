#!/bin/sh
# heldout.sh P PICK WHOLE — a Kenpachi pairing's held-out list (DUEL_AI_STRATEGY §8.19 round 4, fixed before running), from the switch
# directory: seeds 601-700 / 701-800, both seats: the shipped :q1-ken-* table, the best whole arm WHOLE, the selection's pick PICK; then the
# pick's b / c against each.
set -e
for b in 601-700 701-800; do
  k=${b%%-*}
  J=${J:-8} sh kenpachi/measure.sh $1 $1-ho$k-shipped ../pairs/$1/$1-fit.lisp $b
  J=${J:-8} sh kenpachi/measure.sh $1 $1-ho$k-whole $3 $b
  J=${J:-8} sh kenpachi/measure.sh $1 $1-ho$k-pick $2 $b
  python3 report.py ev/$1-ho$k-pick.json ev/$1-ho$k-shipped.json ev/$1-ho$k-whole.json
done

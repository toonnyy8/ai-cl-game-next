#!/bin/sh
# round2.sh P TABLE — one Ichigo pairing's round 2 (DUEL_AI_STRATEGY §8.19 round 5), from the switch directory: 4 salts with TABLE (round 1's
# pick) + runs against the live opponent, then fits at gamma 0.966 / 0.98 -> ichigo/P-r2-g*.lisp.
set -e
sh run.sh $1 log i$1-r2 $2
for g in 0.966 0.98; do sh run.sh $1 fit i$1-r2 ichigo/$1-r2-g$g.lisp $g; done

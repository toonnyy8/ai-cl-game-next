#!/bin/sh
# select.sh R — the co-refit's selection block for round R (DUEL_AI_STRATEGY §8.19 round 5, step 2), from the switch directory: each pairing's
# current table and its round-R candidate on seeds 801-1000 against the live opponent; then the candidate's b / c against the current one.
set -e
R=$1
for p in hi hk hh ki kh kk ik ih ii; do
  P=$p; . ./lineup.sh
  [ -f ev/cf-sel-$p-cur.json ] || sh run.sh $p measure cf-sel-$p-cur $CUR
  [ -f corefit/$p-r$R.lisp ] || continue
  [ -f ev/cf-sel-$p-r$R.json ] || sh run.sh $p measure cf-sel-$p-r$R corefit/$p-r$R.lisp
  python3 report.py ev/cf-sel-$p-r$R.json ev/cf-sel-$p-cur.json | cut -c1-200
done

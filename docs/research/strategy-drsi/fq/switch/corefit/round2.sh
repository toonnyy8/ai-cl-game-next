#!/bin/sh
# round2.sh — the co-refit's round 2 (DUEL_AI_STRATEGY §8.19 round 5, step 2), from the switch directory: only the pairings whose opponent
# changed in round 1 (KH against the new HK, IK against the new KI, HH against itself): the others' round-1 refits already met the same
# opponent. Behaviour = the current table (+ runs), 2 salts, one fit (gamma 0.98), HH's merged pin at ranged close put back -> corefit/<p>-r2.lisp;
# then the selection block (tags cf2-sel-<p>-cur / -r2) and the candidate's b / c.
set -e
for p in kh:kenpachi/qks-hisagi.lisp ik:ichigo/ik-s0-p30.lisp hh:corefit/hh-r1m.lisp; do
  k=${p%%:*}; t=${p#*:}
  if [ ! -f corefit/$k-r2.lisp ]; then
    sh run.sh $k log c$k-r2 $t "1 2"
    sh run.sh $k fit c$k-r2 corefit/$k-r2-fit.lisp 0.98
    if [ $k = hh ]; then sh run.sh $k pin corefit/$k-r2-fit.lisp corefit/$k-r2.lisp 1 1 0.25 close; else cp corefit/$k-r2-fit.lisp corefit/$k-r2.lisp; fi
  fi
  P=$k; . ./lineup.sh
  [ -f ev/cf2-sel-$k-cur.json ] || sh run.sh $k measure cf2-sel-$k-cur $CUR
  [ -f ev/cf2-sel-$k-r2.json ] || sh run.sh $k measure cf2-sel-$k-r2 corefit/$k-r2.lisp
  python3 report.py ev/cf2-sel-$k-r2.json ev/cf2-sel-$k-cur.json | cut -c1-200
done

#!/bin/sh
# run.sh — round 5's steps for one pairing P (DUEL_AI_STRATEGY §8.19 round 5), from the switch directory, against the live lineup (lineup.sh):
#   run.sh P measure TAG TABLE [SEEDS]         sw.py measure -> ev/TAG.json (default seeds 801-1000)
#   run.sh P log TAG TABLE [SALTS]              behaviour TABLE + runs, seeds 1-599 (default salts "1 2 3 4") -> logs/TAG/
#   run.sh P fit TAG OUT GAMMA [EXTRA...]       sw.py fit on logs/TAG -> OUT; stdout in logs/TAG/fit-<OUT name>.out
#   run.sh P start OUT [PERIOD] [EMBED]         sw.py start (arm 0 everywhere, or EMBED's 48 rules as arms 0 / 1)
#   run.sh P pin IN OUT FORM ARM BONUS [BAND]   sw.py pin (an arm's G1 bonus in a form)
#   run.sh P all IN OUT ARM                     IN with ARM in every state (a +5 G1 bonus in forms 0 and 1): that arm played whole, with the log
#   run.sh P heldout PICK [OTHER...]            seeds 601-700 / 701-800: CUR, each OTHER, PICK; then PICK's b / c against each
set -e
P=$1; CMD=$2; shift 2
. ./lineup.sh
case $CMD in
  measure) python3 sw.py measure $C --table $2 --tag ev/$1 --seeds ${3:-801-1000} -j ${J:-10} > /dev/null ;;
  log) for s in ${3:-1 2 3 4}; do python3 sw.py log $C --table $2 --tag $1 --salt $s -j ${J:-10} > /dev/null; done ;;
  fit) T=$1; O=$2; G=$3; shift 3
       python3 sw.py fit $C --tag $T --gamma $G --out $O "$@" > logs/$T/fit-$(basename $O .lisp).out 2>&1 ;;
  start) python3 sw.py start $C --out $1 ${2:+--period $2} ${3:+--embed $3} ;;
  pin) python3 sw.py pin $C --table $1 --out $2 --form $3 --arm $4 --bonus $5 ${6:+--band $6} ;;
  all) python3 sw.py pin $C --table $1 --out $2.tmp --form 0 --arm $3 --bonus 5
       python3 sw.py pin $C --table $2.tmp --out $2 --form 1 --arm $3 --bonus 5; rm -f $2.tmp ;;
  heldout) PICK=$1; shift
    for b in 601-700 701-800; do
      k=${b%%-*}
      python3 sw.py measure $C --table $CUR --tag ev/$P-r5-ho$k-cur --seeds $b -j ${J:-10} > /dev/null
      i=0; L=""
      for o in "$@"; do i=$((i+1)); python3 sw.py measure $C --table $o --tag ev/$P-r5-ho$k-o$i --seeds $b -j ${J:-10} > /dev/null; L="$L ev/$P-r5-ho$k-o$i.json"; done
      python3 sw.py measure $C --table $PICK --tag ev/$P-r5-ho$k-pick --seeds $b -j ${J:-10} > /dev/null
      python3 report.py ev/$P-r5-ho$k-pick.json ev/$P-r5-ho$k-cur.json $L
    done ;;
esac

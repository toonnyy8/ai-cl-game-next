#!/usr/bin/env bash
# sp/band/run.sh STEP: PLAN2 §5 step 1's commands (README.md here). Logs go to fq/switch/logs/spfit/band/, measure summaries to
# fq/switch/spfit/band/ (both gitignored). Seeds: identity 501-600, dev block 300, rescore block 200, admission 801-1000. Never 601-800. -j 6.
set -euo pipefail
cd "$(dirname "$0")/.."                          # sp/
A=arms
K0=$A/r2/c-ki-k-r2-b1a2.lisp; K1=$A/r1/c-ki-k-r1-b2a2.lisp; I0=$A/r2/c-ki-i-r2-b2a2.lisp
W() { python3 band.py write "$@"; }
SW() { (cd ../fq/switch && python3 sw.py "$@"); }
K=(--me kenpachi --vs ichigo); I=(--me ichigo --vs kenpachi)

case "${1:-}" in
tables)
  W "${K[@]}" --inc $K0 --var $K0 --band nocell --out band/id-k-nocell.lisp
  W "${K[@]}" --inc $K0 --var $K0 --band nocell --no-keep-state --out band/id-k-nocell-ks0.lisp
  W "${I[@]}" --inc $I0 --var $I0 --band myburst --out band/id-i-myburst.lisp
  W "${I[@]}" --inc $I0 --var $I0 --band myburst --no-keep-state --out band/id-i-myburst-ks0.lisp
  W "${K[@]}" --inc $K0 --var $K1 --band nocell --out band/ki-k-nocell-r1b2a2.lisp
  W "${I[@]}" --inc $I0 --var none --band myburst --out band/ki-i-myburst-none.lisp
  W "${I[@]}" --inc $I0 --var none --band myburst --no-keep-state --record --out band/ki-i-myburst-none-ks0.lisp ;;
measure)     # measure SIDE(k|i) TABLE TAG SEEDS: sw.py measure (TABLE sp-relative: a band table, or a raw arm) against the opponent's
  side=$2 tag=spfit/band/$4 seeds=$5      # mix (his pure r2 arm); --arms = the table's .arms (a raw arm: the side's identity table's, only counted)
  if [ $side = k ]; then o=$I0; R=("${K[@]}"); d=band/id-k-nocell.arms; else o=$K0; R=("${I[@]}"); d=band/id-i-myburst.arms; fi
  a=${3%.lisp}.arms; [ -f $a ] || a=$d
  SW measure "${R[@]}" --arms ../../sp/$a --rb :rb-sp --ko --opp ../../sp/$o --table ../../sp/$3 --tag $tag --seeds $seeds -j 6 ;;
same)        # same TAG_A TAG_B
  python3 fit/same.py spfit/band/$2 spfit/band/$3 ;;
eval)        # eval SIDE TABLE SEED0 [SEEDS [--spill]]
  side=$2; if [ $side = k ]; then R=("${K[@]}"); else R=("${I[@]}"); fi
  python3 eval.py "${R[@]}" --cand $3 --seed0 $4 --seeds ${5:-100} ${6:-} -j 6 ;;
pair)        # pair SIDE A B SEED0 SEEDS [--spill]
  side=$2; if [ $side = k ]; then R=("${K[@]}"); else R=("${I[@]}"); fi
  python3 band.py pair "${R[@]}" --a $3 --b $4 --seed0 $5 --seeds $6 ${7:-} -j 6 ;;
*) echo "usage: run.sh tables|measure|same|eval|pair ..." >&2; exit 2 ;;
esac

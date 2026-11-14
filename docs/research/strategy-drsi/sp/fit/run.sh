#!/usr/bin/env bash
# sp/fit/run.sh STEP: the KI fit probe's commands (README.md here). Run from anywhere; logs go to fq/switch/logs/spfit/ (gitignored).
# Seeds: fit logs on 201-400 (blocks 200 + 300), selection on 501-600 (block 500), the deciding test once on 401-500 (block 400).
# Never 601-800. -j 6.
set -euo pipefail
SELF=$(realpath "$0")
cd "$(dirname "$0")/../../fq/switch"
F=../../sp/fit
KO=../../sp/arms/r2/c-ki-k-r2-b1a2.lisp          # Kenpachi's equilibrium mix (pure, sp/pop/ki-K.json)
IO=../../sp/arms/r2/c-ki-i-r2-b2a2.lisp          # Ichigo's (sp/pop/ki-I.json)
K=(--me kenpachi --vs ichigo --arms $F/ki-k.arms --rb :rb-sp --ko)
I=(--me ichigo --vs kenpachi --arms $F/ki-i.arms --rb :rb-sp --ko)
SW() { python3 sw.py "$@"; }

case "${1:-}" in
start)       # the start tables: arm 0 (the newest admitted arm) in every state, period 30
  SW start "${K[@]}" --period 30 --out $F/ki-k-s0.lisp
  SW start "${I[@]}" --period 30 --out $F/ki-i-s0.lisp ;;
identity)    # the start table = arm 0 raw; a table whose arm 0 is nil = none (seeds 501-510, both seats, against the mix)
  T=${TMPDIR:-/tmp}/spfit-nil; mkdir -p $T
  printf 'nil\n(:id :x :fn ken-kh-standoff-style)\n' > $T/nil-k.arms; printf 'nil\n(:id :x :fn ichigo-ki-style)\n' > $T/nil-i.arms
  SW start --me kenpachi --vs ichigo --arms $T/nil-k.arms --rb :rb-sp --period 30 --out $T/nil-k-s0.lisp
  SW start --me ichigo --vs kenpachi --arms $T/nil-i.arms --rb :rb-sp --period 30 --out $T/nil-i-s0.lisp
  M=(measure --seeds "${2:-501-510}")
  SW "${M[@]}" "${K[@]}" --opp $IO --table $F/ki-k-s0.lisp --tag spfit/id-k-s0
  SW "${M[@]}" "${K[@]}" --opp $IO --table $KO --tag spfit/id-k-raw
  SW "${M[@]}" "${I[@]}" --opp $KO --table $F/ki-i-s0.lisp --tag spfit/id-i-s0
  SW "${M[@]}" "${I[@]}" --opp $KO --table $IO --tag spfit/id-i-raw
  SW "${M[@]}" "${K[@]}" --arms $T/nil-k.arms --opp $IO --table $T/nil-k-s0.lisp --tag spfit/id-k-nil
  SW "${M[@]}" "${K[@]}" --arms $T/nil-k.arms --opp $IO --table none --tag spfit/id-k-none
  SW "${M[@]}" "${I[@]}" --arms $T/nil-i.arms --opp $KO --table $T/nil-i-s0.lisp --tag spfit/id-i-nil
  SW "${M[@]}" "${I[@]}" --arms $T/nil-i.arms --opp $KO --table none --tag spfit/id-i-none
  for p in k-s0:k-raw i-s0:i-raw k-nil:k-none i-nil:i-none; do python3 $F/same.py spfit/id-${p%%:*} spfit/id-${p##*:}; done ;;
log)         # log SIDE(k|i) TABLE TAG SALTS...: exploration logs on 201-400 against the pool (mix, none): seed mod 2; TABLE in sp/fit
  side=$2 table=$F/$3 tag=$4; shift 4
  if [ $side = k ]; then A=("${K[@]}" --opp $IO,none); else A=("${I[@]}" --opp $KO,none); fi
  for s in "$@"; do SW log "${A[@]}" --table $table --tag spfit/$tag --salt $s --eps 0.03 --runs 6 18 --seeds 201-400 -j 6 > /dev/null; done ;;
measure)     # measure SIDE TABLE TAG SEEDS OPP(mix|none): TABLE in sp/fit, or ../arms/... for a raw arm
  side=$2 table=$F/$3 tag=$4 seeds=$5 opp=$6
  if [ $side = k ]; then A=("${K[@]}"); o=$IO; else A=("${I[@]}"); o=$KO; fi
  [ $opp = none ] && o=none
  SW measure "${A[@]}" --opp $o --table $table --tag spfit/$tag --seeds $seeds -j 6 ;;
fit)         # fit SIDE TAGS OUT [sw.py fit options...]: a table from logs on 201-400 (TAGS: comma list under spfit/); OUT in sp/fit
  side=$2 tags=spfit/${3//,/,spfit/} out=$F/$4; shift 4
  if [ $side = k ]; then A=("${K[@]}"); else A=("${I[@]}"); fi
  SW fit "${A[@]}" --tag $tags --seeds 201-400 --out $out "$@" | tail -1 ;;
sel)         # sel SIDE TABLE [SEEDS]: one line, the table against the mix and against none (default block 500, the selection set)
  side=$2 table=$3 seeds=${4:-501-600}; t=$(basename $table .lisp)
  for o in mix none; do
    bash "$SELF" measure $side $table sel/$t-$o-$seeds $seeds $o | python3 -c "import json,sys; d=json.loads(sys.stdin.read()); \
print('$t $o $seeds score', d['score'], 'ko_rate', d['ko_rate'], 'timeouts', d['timeouts'], 'arms', d['arm_share'], 'changes', d['changes_per_match']['mean'])"
  done ;;
*) echo "usage: run.sh start|identity|log|fit|measure|sel ..." >&2; exit 2 ;;
esac

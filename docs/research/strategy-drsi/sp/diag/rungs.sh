#!/bin/bash
# rungs.sh SEED0 SEEDS SPECFILE [RUNGS]: for each line "name<TAB>PROBE_SET[<TAB>PROBE_LIFT]" of SPECFILE, the ladder's rungs (hi:lo)
# through probe.py, one share row each (all-tiers-table.md). RUNGS default: easy:masher normal:masher hard:masher normal:easy hard:normal.
# PAIRS=KK,IK,HK (env) narrows the cells. JSON per run in diag/runs/<hi>-<lo>-<name>-<seed0>.json.
cd "$(dirname "$0")/../../../../.." || exit 1
P=docs/research/strategy-drsi/sp/diag
S0=$1; N=$2; SPEC=$3; RUNGS=${4:-"easy:masher normal:masher hard:masher normal:easy hard:normal"}
PA=${PAIRS:+--pairs $PAIRS}
while IFS=$'\t' read -r name set lift; do
  [ -z "$name" ] && continue
  case "$name" in \#*) continue;; esac
  for r in $RUNGS; do
    hi=${r%%:*}; lo=${r##*:}
    out=$(python3 $P/probe.py --hi "$hi" --lo "$lo" --seed0 "$S0" --seeds "$N" -j 20 --quiet $PA --set "$set" --lift "$lift" \
          --json "$P/runs/$hi-$lo-$name-$S0.json") || exit 1
    echo "$name $hi>$lo $(echo "$out" | sed -n 2p | cut -c6-) | $(echo "$out" | sed -n 3p) | $(echo "$out" | sed -n 4p | cut -c6- | sed 's/  (.*//')"
  done
done < "$SPEC"

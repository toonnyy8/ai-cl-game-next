#!/bin/bash
# run-tier.sh SPEC [RUNGS]: tier-t0.md's ladder per spec line ("name<TAB>PROBE_SET<TAB>PROBE_LIFT") through probe.py, seeds 501-600
# (SEEDS=n narrows: 501..500+n), both seats; one share row per rung. RUNGS default: easy:masher normal:easy hard:normal. PAIRS=KK,..
# narrows the cells. JSON per run in diag/tier/<hi>-<lo>-<name>.json.
cd "$(dirname "$0")/../../../../.." || exit 1
P=docs/research/strategy-drsi/sp/diag
RUNGS=${2:-"easy:masher normal:easy hard:normal"}
PA=${PAIRS:+--pairs $PAIRS}
mkdir -p $P/tier
while IFS=$'\t' read -r name set lift; do
  [ -z "$name" ] && continue
  case "$name" in \#*) continue;; esac
  for r in $RUNGS; do
    hi=${r%%:*}; lo=${r##*:}
    out=$(python3 $P/probe.py --hi "$hi" --lo "$lo" --seed0 500 --seeds ${SEEDS:-100} -j 22 --quiet $PA --set "$set" --lift "$lift" \
          --json "$P/tier/$hi-$lo-$name.json") || exit 1
    printf '%-8s %-13s %s | %s\n' "$name" "$hi>$lo" "$(echo "$out" | sed -n 3p | cut -c6-)" "$(echo "$out" | sed -n 4p | cut -c6- | sed 's/  (.*//')"
  done
done < "$1"

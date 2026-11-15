#!/bin/bash
# ablate.sh HI LO SEED0 SEEDS SPECFILE: one probe.py run per line "name<TAB>PROBE_SET" of SPECFILE (load-time bindings only), each
# run's share row printed under its name; JSON per run in diag/runs/<HI>-<LO>-<name>-<seed0>.json.
cd "$(dirname "$0")/../../../../.." || exit 1
P=docs/research/strategy-drsi/sp/diag
HI=$1; LO=$2; S0=$3; N=$4; SPEC=$5
while IFS=$'\t' read -r name set; do
  [ -z "$name" ] && continue
  case "$name" in \#*) continue;; esac
  out=$(python3 $P/probe.py --hi "$HI" --lo "$LO" --seed0 "$S0" --seeds "$N" -j 22 --quiet --set "$set" --json "$P/runs/$HI-$LO-$name-$S0.json") || exit 1
  echo "$name $(echo "$out" | sed -n 3p)"
done < "$SPEC"

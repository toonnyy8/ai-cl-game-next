#!/bin/bash
# tier-r2.md step 4 queue 2: X3 (three rungs), X4 (N>E, H>N), and the E>M diagnosis per cell as shipped (non-quiet probes: KK, IK, HH).
cd "$(dirname "$0")/../../../../../.." || exit 1
S=docs/research/strategy-drsi/sp/diag
bash $S/run-tier.sh <(grep '^r2X3' $S/tier/spec-r2-cand2.tsv)
bash $S/run-tier.sh <(grep '^r2X4' $S/tier/spec-r2-cand2.tsv) "normal:easy hard:normal"
for c in KK IK HH; do
  python3 $S/probe.py --hi easy --lo masher --pairs $c --seed0 500 --seeds 100 -j 22 > $S/tier/r2-em-$c-base.txt
done

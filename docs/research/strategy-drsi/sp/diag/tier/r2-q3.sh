#!/bin/bash
# tier-r2.md step 5 queue 3: is Block A IK vs KI only? X2's NORMAL against the masher on IK (EASY Ichigo's ceiling under monotone);
# X2 + Kenpachi's style at HARD's for EASY and NORMAL (X2k: E>M KK through Kenpachi's own group); main's IH with the bell split.
cd "$(dirname "$0")/../../../../../.." || exit 1
S=docs/research/strategy-drsi/sp/diag
PAIRS=IK bash $S/run-tier.sh <(grep '^r2X2' $S/tier/spec-r2-cand.tsv) "normal:masher"
printf 'r2X2k\t*cai-clash-p*=(:easy 0.45 :normal 0.45 :hard 1.0);*cai-clash-delay*=(:easy 8 :normal 8 :hard 4)\teasy=hard:@style-k;normal=hard:@style-k\n' > $S/tier/spec-r2-cand4.tsv
bash $S/run-tier.sh $S/tier/spec-r2-cand4.tsv
printf 'r2baseih\t\t\n' > $S/tier/spec-r2-baseih.tsv
PAIRS=IH bash $S/run-tier.sh $S/tier/spec-r2-baseih.tsv "normal:easy hard:normal"

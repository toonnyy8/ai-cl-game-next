#!/bin/bash
# tier-r2.md step 3 queue 1: the HARD-only raises on H>N KI, the parity matchups (HARD vs HARD, NORMAL vs NORMAL) as shipped, one
# non-quiet probe of H>N KI in r2c6_8, and two non-tier probes (*mc-full* nil on E>M; *mc-off-at* nil on H>N KI IH II).
cd "$(dirname "$0")/../../../../../.." || exit 1
S=docs/research/strategy-drsi/sp/diag
PAIRS=KI bash $S/run-tier.sh $S/tier/spec-r2-hki.tsv "hard:normal"
bash $S/run-tier.sh $S/tier/spec-r2-base.tsv "hard:hard normal:normal"
python3 $S/probe.py --hi hard --lo normal --pairs KI --seed0 500 --seeds 100 -j 22 \
  --set '*cai-clash-p*=(:easy 0.6 :normal 0.6 :hard 0.6);*cai-clash-delay*=(:easy 8 :normal 8 :hard 8)' > $S/tier/r2-hn-ki-c6_8.txt
python3 $S/probe.py --hi hard --lo normal --pairs KI --seed0 500 --seeds 100 -j 22 > $S/tier/r2-hn-ki-base.txt
printf 'r2mcfull\t*mc-full*=nil\teasy=easy:*ai-delay*\nr2mcoff\t*mc-off-at*=nil\teasy=easy:*ai-delay*\n' > $S/tier/spec-r2-nontier.tsv
bash $S/run-tier.sh $S/tier/spec-r2-nontier.tsv "easy:masher"
PAIRS=KI,IH,II bash $S/run-tier.sh <(grep r2mcoff $S/tier/spec-r2-nontier.tsv) "hard:normal"

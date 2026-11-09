#!/bin/sh
# khevent/proofs7.sh — step 7's KH swap (DUEL_AI_STRATEGY §8.19 round 5, step 7; the user: 「沒重擬合的表 0.915」), from the repo root, on the build
# with :qks5-hisagi: khevent/kh-t0.lisp (the no-refit start, the layer on) run raw = the live lookup (seeds 601-700, both seats, 8 of 8 chunks,
# against Hisagi's live :qhs-ken), then the 3x3 with both seats on the lookup -> khevent/proofs7-600.jsonl, khevent/live9-7-600.jsonl
set -e
F=docs/research/strategy-drsi/fq
S=$F/switch
python3 $F/proof/identity.py kenpachi hisagi $S/corefit/hk-r1.lisp $S/khevent/kh-t0.lisp > $S/khevent/proofs7-600.jsonl
sh $S/live9.sh $S/khevent/live9-7-600.jsonl

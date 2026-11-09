#!/bin/sh
# khstyle/proofs.sh — step 5's changed live table (DUEL_AI_STRATEGY §8.19 round 5, step 5), from the repo root, on the build with :qks3-hisagi:
# khstyle/kh-t2.lisp run raw = the live lookup (seeds 601-700, both seats, 8 of 8 chunks, against Hisagi's live :qhs-ken), then the 3x3 with both
# seats on the lookup -> khstyle/proofs-600.jsonl, khstyle/live9-600.jsonl
set -e
F=docs/research/strategy-drsi/fq
S=$F/switch
python3 $F/proof/identity.py kenpachi hisagi $S/corefit/hk-r1.lisp $S/khstyle/kh-t2.lisp > $S/khstyle/proofs-600.jsonl
sh $S/live9.sh $S/khstyle/live9-600.jsonl

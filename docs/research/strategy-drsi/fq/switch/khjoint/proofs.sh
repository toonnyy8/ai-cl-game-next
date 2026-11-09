#!/bin/sh
# khjoint/proofs.sh — step 4's changed live table (DUEL_AI_STRATEGY §8.19 round 5, step 4), from the repo root, on the build with :qks2-hisagi:
# khjoint/kh-t2.lisp run raw = the live lookup (seeds 601-700, both seats, 8 of 8 chunks, against Hisagi's live :qhs-ken), then the 3x3 with both
# seats on the lookup -> khjoint/proofs-600.jsonl, khjoint/live9-600.jsonl
set -e
F=docs/research/strategy-drsi/fq
S=$F/switch
python3 $F/proof/identity.py kenpachi hisagi $S/corefit/hk-r1.lisp $S/khjoint/kh-t2.lisp > $S/khjoint/proofs-600.jsonl
sh $S/live9.sh $S/khjoint/live9-600.jsonl

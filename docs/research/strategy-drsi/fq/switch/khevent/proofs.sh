#!/bin/sh
# khevent/proofs.sh — step 6's changed live table (DUEL_AI_STRATEGY §8.19 round 5, step 6), from the repo root, on the build with :qks4-hisagi:
# khevent/kh-t2.lisp run raw = the live lookup (seeds 601-700, both seats, 8 of 8 chunks, against Hisagi's live :qhs-ken), the 3x3 with both
# seats on the lookup, and the layer's statistics (KH_2 and the no-refit reference KH_0 against the live HK, 601-800, events.py)
# -> khevent/proofs-600.jsonl, khevent/live9-600.jsonl, khevent/events.json
set -e
F=docs/research/strategy-drsi/fq
S=$F/switch
python3 $F/proof/identity.py kenpachi hisagi $S/corefit/hk-r1.lisp $S/khevent/kh-t2.lisp > $S/khevent/proofs-600.jsonl
sh $S/live9.sh $S/khevent/live9-600.jsonl
cd $S
for t in 2 0; do
  for b in 601-700 701-800; do
    python3 sw.py measure --me kenpachi --vs hisagi --opp corefit/hk-r1.lisp --arms khevent/kh.arms --table khevent/kh-t$t.lisp --tag ev/ejx-kh$t-${b%%-*} --seeds $b -j 20 > /dev/null
  done
done
{ printf '{"KH_2": '; python3 -B khevent/events.py ev/ejx-kh2-601 ev/ejx-kh2-701 | tr -d '\n'
  printf ', "KH_0": '; python3 -B khevent/events.py ev/ejx-kh0-601 ev/ejx-kh0-701 | tr -d '\n'; printf '}\n'; } > khevent/events.json
cat khevent/events.json

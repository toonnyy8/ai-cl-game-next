#!/bin/sh
# live9.sh OUT — every pairing CPU vs CPU with both seats on the lookup (DUEL_AI_STRATEGY §8.19 round 5), from the repo root: HARD, seeds
# 601-700, both seats; the row character's share (strategy-switch.py's inc_share: no strategy file on either seat) -> OUT (jsonl).
set -e
O=$1
: > $O
for me in hisagi kenpachi ichigo; do
  for vs in hisagi kenpachi ichigo; do
    python3 tools/strategy-switch.py --char $me --vs $vs --cand docs/research/strategy-drsi/fq/switch/arms/a0-merged.lisp --raw --seed0 600 --seeds 100 -j 20 \
      | python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(dict(me='$me', vs='$vs', live_share=d['inc_share'])))" >> $O
  done
done
cat $O

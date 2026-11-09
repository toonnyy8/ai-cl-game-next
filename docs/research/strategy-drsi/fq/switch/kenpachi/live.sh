#!/bin/sh
# live.sh — round 4's cross effects (DUEL_AI_STRATEGY §8.19 round 4), from the repo root: both seats on the lookup, seeds 601-700, HARD;
# the incumbent's share of each pairing (strategy-switch.py's inc_share: no strategy file on either seat) -> kenpachi/live-600.jsonl.
set -e
O=docs/research/strategy-drsi/fq/switch/kenpachi/live-600.jsonl
: > $O
for p in kenpachi:ichigo ichigo:kenpachi kenpachi:hisagi hisagi:kenpachi kenpachi:kenpachi; do
  me=${p%%:*}; vs=${p#*:}
  python3 tools/strategy-switch.py --char $me --vs $vs --cand docs/research/strategy-drsi/fq/switch/arms/a0-merged.lisp --raw --seed0 600 --seeds 100 -j 20 \
    | python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(dict(me='$me', vs='$vs', live_share=d['inc_share'])))" >> $O
done
cat $O

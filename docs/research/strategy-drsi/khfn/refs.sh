#!/bin/sh
# refs.sh — the references the keep rule compares against (DUEL_AI_STRATEGY §8.19 round 5, step 5), from the repo root, before round 1:
# his KI code (the baseline: ken-kh-style = ken-ki-style), Ichigo's KI code on Kenpachi (khjoint/k/k5-iki.lisp) and the live KH table
# :qks2-hisagi (khjoint/kh-t2.lisp), each on the search (200) and dev (300) blocks and the held-out block at scale 2 (400) -> khfn/refs.jsonl
set -e
K=docs/research/strategy-drsi/khfn
SW=docs/research/strategy-drsi/fq/switch
O=$K/refs.jsonl
: > $O
for c in $K/cand-khfn.lisp $SW/khjoint/k/k5-iki.lisp $SW/khjoint/kh-t2.lisp; do
  for b in "200 1" "300 1" "400 2"; do
    set -- $b
    python3 $K/eval.py --cand $c --seed0 $1 --scale $2 -j 20 | python3 -c "import json,sys; d=json.load(sys.stdin); d['cand']='$(basename $c .lisp)'; print(json.dumps(d))" >> $O
  done
done
cut -c1-200 $O

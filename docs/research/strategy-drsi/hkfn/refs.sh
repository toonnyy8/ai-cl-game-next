#!/bin/sh
# refs.sh — the references the keep rule compares against (DUEL_AI_STRATEGY §8.19 round 5, step 7), from the repo root, before round 1:
# Hisagi's four existing styles played whole (his merged style = the baseline, Kenpachi's KI code, Ichigo's KI code, the ranged-mode style),
# and for context his live HK table :qhs-ken and his two best step-4 whole arms (Kenpachi's KI code + the kite's data, press), each on the
# search (200) and dev (300) blocks and the held-out block at scale 2 (400) -> hkfn/refs.jsonl
set -e
K=docs/research/strategy-drsi/hkfn
SW=docs/research/strategy-drsi/fq/switch
O=$K/refs.jsonl
: > $O
for c in $K/cand-hkfn.lisp $SW/khjoint/h/h2-kenki.lisp $SW/khjoint/h/h7-iki.lisp $SW/khjoint/h/h8-range.lisp $SW/corefit/hk-r1.lisp \
         $SW/khjoint/h/h9-kenkite.lisp $SW/khjoint/h/h3-press.lisp; do
  for b in "200 1" "300 1" "400 2"; do
    set -- $b
    python3 $K/eval.py --cand $c --seed0 $1 --scale $2 -j 20 | python3 -c "import json,sys; d=json.load(sys.stdin); d['cand']='$(basename $c .lisp)'; print(json.dumps(d))" >> $O
  done
done
python3 -c "
import json
for l in open('$O'):
    d = json.loads(l); print(d['cand'], d['seed0'], d['score'], d['groups'], d['inc_live'])"

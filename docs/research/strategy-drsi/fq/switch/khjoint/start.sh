#!/bin/sh
# khjoint/start.sh — the joint KH / HK fit's arms and start tables (DUEL_AI_STRATEGY §8.19 round 5, step 4), from the switch directory: each live
# table's arms + the kept arm from the joint search (matrix.json), the live table extended with it (extend.py: plays the live table bit for bit),
# proved = the live lookup (proof/identity.py, seeds 601-700, 8 of 8 chunks) -> khjoint/kh.arms, hk.arms, kh-t0.lisp, hk-t0.lisp, identity-t0-600.jsonl
set -e
{ cat kenpachi/kh.arms
  echo ";; targeted (round 5 step 4, the joint KH / HK search): Ichigo's KI style code on Kenpachi (:a-ichigo-ki), the best whole arm against :qhs-ken"
  cat khjoint/k/k5-iki.lisp; } > khjoint/kh.arms
{ cat arms/hk.arms
  echo ";; targeted (round 5 step 4, the joint KH / HK search): Kenpachi's KI style code at the kite's range (:a-ken-kite), the best whole arm across his pool"
  cat khjoint/h/h9-kenkite.lisp; } > khjoint/hk.arms
python3 -B khjoint/extend.py --me kenpachi --vs hisagi --arms kenpachi/kh.arms --table kenpachi/qks-hisagi.lisp --new-arms khjoint/kh.arms --out khjoint/kh-t0.lisp
python3 -B khjoint/extend.py --me hisagi --vs kenpachi --arms arms/hk.arms --table corefit/hk-r1.lisp --new-arms khjoint/hk.arms --out khjoint/hk-t0.lisp
cd ../../../../..
F=docs/research/strategy-drsi/fq
O=$F/switch/khjoint/identity-t0-600.jsonl
: > $O
python3 $F/proof/identity.py kenpachi hisagi $F/switch/corefit/hk-r1.lisp $F/switch/khjoint/kh-t0.lisp >> $O
python3 $F/proof/identity.py hisagi kenpachi $F/switch/kenpachi/qks-hisagi.lisp $F/switch/khjoint/hk-t0.lisp >> $O

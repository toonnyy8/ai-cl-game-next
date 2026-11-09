#!/bin/sh
# start.sh — Kenpachi's three start tables (DUEL_AI_STRATEGY §8.19 round 4), from the switch directory: each shipped :q1-ken-* table's 48 rules
# embedded (arms 0 / 1 its own), period 90 for the identity proof and 30 for round 1's behaviour; then the proofs (repo root), the start table
# run raw = the shipped table run raw, seeds 601-700, both seats, 8 of 8 chunks -> kenpachi/identity-s0-600.jsonl.
set -e
for p in ki:ichigo:../../counter/frozen/ki-ichigo.lisp kh:hisagi:arms/ship-qh-ken.lisp kk:kenpachi:../pairs/kk/kk-fit.lisp; do
  k=${p%%:*}; r=${p#*:}; vs=${r%%:*}; opp=${r#*:}
  python3 sw.py start --me kenpachi --vs $vs --opp $opp --arms kenpachi/$k.arms --embed ../pairs/$k/$k-fit.lisp --out kenpachi/$k-s0.lisp
  python3 sw.py start --me kenpachi --vs $vs --opp $opp --arms kenpachi/$k.arms --embed ../pairs/$k/$k-fit.lisp --period 30 --out kenpachi/$k-s0-p30.lisp
done
cd ../../../../..
F=docs/research/strategy-drsi/fq
K=$F/switch/kenpachi
python3 $F/proof/identity.py kenpachi ichigo $F/../counter/frozen/ki-ichigo.lisp $K/ki-s0.lisp --ref $F/pairs/ki/ki-fit.lisp > $K/identity-s0-600.jsonl
python3 $F/proof/identity.py kenpachi hisagi $F/switch/arms/ship-qh-ken.lisp $K/kh-s0.lisp --ref $F/pairs/kh/kh-fit.lisp >> $K/identity-s0-600.jsonl
python3 $F/proof/identity.py kenpachi kenpachi $F/pairs/kk/kk-fit.lisp $K/kk-s0.lisp --ref $F/pairs/kk/kk-fit.lisp >> $K/identity-s0-600.jsonl

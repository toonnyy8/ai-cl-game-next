#!/bin/sh
# proofs2.sh — the round-2 proofs on the final build (DUEL_AI_STRATEGY §8.19), from the repo root: each start table run raw = what it starts
# from (HI press whole, HK the shipped :qh-ken, HH the kite whole), and each shipped table run raw = the live lookup; seeds 601-700, both
# seats, 8 of 8 chunks. Output: docs/research/strategy-drsi/fq/switch/proofs2-600.jsonl
set -e
F=docs/research/strategy-drsi/fq
S=$F/switch
P=$F/proof/identity.py
O=$S/proofs2-600.jsonl
python3 $P hisagi ichigo $F/../counter/frozen/ki-ichigo.lisp $S/hi/hi2-s0.lisp --ref $S/arms/a6-press.lisp > $O
python3 $P hisagi kenpachi $F/pairs/kh/kh-fit.lisp $S/hk/hk2-s0.lisp --ref $F/hisagi/hk-fqm.lisp >> $O
python3 $P hisagi hisagi $S/arms/ship-qh-mirror.lisp $S/hh/hh2-s0.lisp --ref $S/arms/a7-kite.lisp >> $O
python3 $P hisagi ichigo $F/../counter/frozen/ki-ichigo.lisp $S/hi/qhs2-ichigo.lisp >> $O
python3 $P hisagi hisagi $S/arms/ship-qh-mirror.lisp $S/hh/qhs-mirror.lisp >> $O

#!/bin/sh
# proofs3.sh — round 3's proofs on the final build (DUEL_AI_STRATEGY §8.19 round 3), from the repo root: each lookup table run raw = the live
# lookup (HI :qhs2-ichigo, kept, on a build whose merged style gained :shikai-dswitch, off; HH :qhs2-mirror), seeds 601-700, both seats,
# 8 of 8 chunks. Output: docs/research/strategy-drsi/fq/switch/proofs3-600.jsonl
set -e
F=docs/research/strategy-drsi/fq
S=$F/switch
P=$F/proof/identity.py
O=$S/proofs3-600.jsonl
python3 $P hisagi ichigo $F/../counter/frozen/ki-ichigo.lisp $S/hi/qhs2-ichigo.lisp > $O
python3 $P hisagi hisagi $S/arms/ship-qh-mirror.lisp $S/hh/qhs2-mirror.lisp >> $O

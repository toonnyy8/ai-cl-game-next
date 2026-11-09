#!/bin/sh
# proofs4.sh — round 4's proofs on the final build (DUEL_AI_STRATEGY §8.19 round 4), from the repo root: each new lookup table run raw = the
# live lookup (HI :qhs3-ichigo; Kenpachi's :qks-ichigo, :qks-hisagi, :qks-ken), seeds 601-700, both seats, 8 of 8 chunks
# -> docs/research/strategy-drsi/fq/switch/proofs4-600.jsonl
set -e
F=docs/research/strategy-drsi/fq
S=$F/switch
P=$F/proof/identity.py
O=$S/proofs4-600.jsonl
python3 $P hisagi ichigo $F/../counter/frozen/ki-ichigo.lisp $S/hi/qhs3-ichigo.lisp > $O
python3 $P kenpachi ichigo $F/../counter/frozen/ki-ichigo.lisp $S/kenpachi/qks-ichigo.lisp >> $O
python3 $P kenpachi hisagi $S/arms/ship-qh-ken.lisp $S/kenpachi/qks-hisagi.lisp >> $O
python3 $P kenpachi kenpachi $F/pairs/kk/kk-fit.lisp $S/kenpachi/qks-ken.lisp >> $O

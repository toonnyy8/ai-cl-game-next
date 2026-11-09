#!/bin/sh
# proofs.sh — the co-refit's swapped tables in the lookup (DUEL_AI_STRATEGY §8.19 round 5, step 2), from the repo root: each research file run
# raw = the live lookup (its unit-format library entry), seeds 601-700, both seats, 8 of 8 chunks, against the live opponent
# -> docs/research/strategy-drsi/fq/switch/corefit/proofs-600.jsonl
set -e
F=docs/research/strategy-drsi/fq
S=$F/switch
P=$F/proof/identity.py
O=$S/corefit/proofs-600.jsonl
: > $O
python3 $P hisagi kenpachi $S/kenpachi/qks-hisagi.lisp $S/corefit/hk-r1.lisp >> $O
python3 $P hisagi hisagi $S/corefit/hh-r1m.lisp $S/corefit/hh-r1m.lisp >> $O
python3 $P kenpachi ichigo $S/corefit/ik-r2.lisp $S/corefit/ki-r1.lisp >> $O
python3 $P ichigo kenpachi $S/corefit/ki-r1.lisp $S/corefit/ik-r2.lisp >> $O
python3 -c "
import json
for l in open('$O'):
    d = json.loads(l); print(d['char'], d['vs'], d['table'].split('/')[-1], d['table_share'], d['inc_share'], d['chunks_identical'], d['lines'])"

#!/bin/sh
# proofs.sh — each final table's raw file (sp/final/<t>.lisp, run through STRAT_P*) = the live HARD lookup (:f-<t>, the unit library
# expanded), seeds 601-610, both seats, against the other side's final table (a mirror: itself) -> final/proofs-600.jsonl
# (DUEL_AI_STRATEGY §11.16; the method of ../../fq/switch/library/proofs.sh, §10). Run from the repo root.
set -e
D=docs/research/strategy-drsi/sp/final
P=docs/research/strategy-drsi/fq/proof/identity.py
O=$D/proofs-600.jsonl
: > $O
while read me vs t opp; do
  python3 $P $me $vs $D/$opp.lisp $D/$t.lisp --seed0 600 --seeds 10 -j 6 >> $O
done <<EOF
ichigo kenpachi ki-ichigo ki-kenpachi
kenpachi ichigo ki-kenpachi ki-ichigo
kenpachi hisagi kh-kenpachi kh-hisagi
hisagi kenpachi kh-hisagi kh-kenpachi
ichigo hisagi ih-ichigo ih-hisagi
hisagi ichigo ih-hisagi ih-ichigo
kenpachi kenpachi kk-kenpachi kk-kenpachi
ichigo ichigo ii-ichigo ii-ichigo
hisagi hisagi hh-hisagi hh-hisagi
EOF
python3 -c "
import json
for l in open('$O'):
    d = json.loads(l); print(d['char'], d['vs'], d['table'].split('/')[-1], d['table_share'], d['inc_share'], d['chunks_identical'], d['lines'])"

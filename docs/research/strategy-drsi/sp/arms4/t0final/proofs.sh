#!/bin/sh
# proofs.sh — each T0 table's raw file (t0final/t0-<t>.lisp, run through STRAT_P*; its :with expanded by the runner) = the live HARD lookup
# (:t0-<t>, the unit library expanded), seeds 501-510, both seats, against the other side's raw T0 (a mirror: itself) -> t0final/proofs-500.jsonl
# (sp/final/proofs.sh's method, DUEL_AI_STRATEGY §11.16). Run from the repo root.
set -e
D=docs/research/strategy-drsi/sp/arms4/t0final
P=docs/research/strategy-drsi/fq/proof/identity.py
O=$D/proofs-500.jsonl
: > $O
while read me vs t opp; do
  python3 $P $me $vs $D/t0-$opp.lisp $D/t0-$t.lisp --seed0 500 --seeds 10 -j 6 >> $O
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
    d = json.loads(l); print(d['char'], d['vs'], d['table'].split('/')[-1], d['table_share'], d['inc_share'], d['chunks_identical'], d['chunks_differing'], d['lines'])"

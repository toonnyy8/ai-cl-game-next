#!/bin/sh
# proofs.sh — checkpoint 2b's four arms5 T0 tables (KI both, KK, II) and checkpoint 2c's four (KH both, IH both; 2026-11-16): each raw file (arms5/t0/t0-<t>.lisp, run through STRAT_P*; its :with expanded by the
# runner) = the live HARD lookup (:t0-<t>, the unit library expanded), seeds 141-150 (arms5's block), both seats, against the other side's
# raw T0 (a mirror: itself) -> arms5/t0/proofs-140.jsonl (arms4/t0final/proofs.sh's method, DUEL_AI_STRATEGY §11.16). Run from the repo root.
set -e
D=docs/research/strategy-drsi/sp/arms5/t0
P=docs/research/strategy-drsi/fq/proof/identity.py
O=$D/proofs-140.jsonl
: > $O
while read me vs t opp; do
  python3 $P $me $vs $D/t0-$opp.lisp $D/t0-$t.lisp --seed0 140 --seeds 10 -j ${J:-10} >> $O
done <<EOF
ichigo kenpachi ki-ichigo ki-kenpachi
kenpachi ichigo ki-kenpachi ki-ichigo
kenpachi kenpachi kk-kenpachi kk-kenpachi
ichigo ichigo ii-ichigo ii-ichigo
kenpachi hisagi kh-kenpachi kh-hisagi
hisagi kenpachi kh-hisagi kh-kenpachi
ichigo hisagi ih-ichigo ih-hisagi
hisagi ichigo ih-hisagi ih-ichigo
EOF
python3 -c "
import json
for l in open('$O'):
    d = json.loads(l); print(d['char'], d['vs'], d['table'].split('/')[-1], d['table_share'], d['inc_share'], d['chunks_identical'], d['chunks_differing'], d['lines'])"

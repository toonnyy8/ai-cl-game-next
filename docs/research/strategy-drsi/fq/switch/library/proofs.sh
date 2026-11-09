#!/bin/sh
# proofs.sh — the library refactor plays the same (DUEL_AI_STRATEGY §10), from the repo root: each of the nine live lookup tables, its research
# file (inline arms) run raw = the live lookup (the unit library, expanded), seeds 601-700, both seats, 8 of 8 chunks, against the opponent its
# last proof used, so the shares can be read against those proofs -> docs/research/strategy-drsi/fq/switch/library/proofs-600.jsonl
set -e
F=docs/research/strategy-drsi/fq
S=$F/switch
P=$F/proof/identity.py
O=$S/library/proofs-600.jsonl
: > $O
python3 $P hisagi ichigo $F/../counter/frozen/ki-ichigo.lisp $S/hi/qhs3-ichigo.lisp >> $O              # (round 4: 0.87)
python3 $P hisagi kenpachi $F/pairs/kh/kh-fit.lisp $F/hisagi/hk-fqm.lisp >> $O                          # (round 2's HK start proof: 0.76)
python3 $P hisagi hisagi $S/arms/ship-qh-mirror.lisp $S/hh/qhs2-mirror.lisp >> $O                       # (round 3: 0.59)
python3 $P kenpachi ichigo $F/../counter/frozen/ki-ichigo.lisp $S/kenpachi/qks-ichigo.lisp >> $O        # (round 4: 0.885)
python3 $P kenpachi hisagi $S/arms/ship-qh-ken.lisp $S/kenpachi/qks-hisagi.lisp >> $O                   # (round 4: 0.625)
python3 $P kenpachi kenpachi $F/pairs/kk/kk-fit.lisp $S/kenpachi/qks-ken.lisp >> $O                     # (round 4: 0.52)
python3 $P ichigo kenpachi $S/kenpachi/qks-ichigo.lisp $F/../counter/frozen/q1-ichigo-ken.lisp >> $O    # (round 5 step 1: 0.6)
python3 $P ichigo hisagi $S/hi/qhs3-ichigo.lisp $S/ichigo/qis-hisagi.lisp >> $O                         # (round 5 step 1: 0.405)
python3 $P ichigo ichigo $F/pairs/ii/ii-fit.lisp $F/pairs/ii/ii-fit.lisp >> $O                          # (round 5 step 1: 0.025)
python3 -c "
import json
for l in open('$O'):
    d = json.loads(l); print(d['char'], d['vs'], d['table'].split('/')[-1], d['table_share'], d['inc_share'], d['chunks_identical'], d['lines'])"

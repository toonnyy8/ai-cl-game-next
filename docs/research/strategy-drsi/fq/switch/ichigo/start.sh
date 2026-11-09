#!/bin/sh
# start.sh — Ichigo's three start tables (DUEL_AI_STRATEGY §8.19 round 5), from the switch directory: each shipped :q1-ichigo-* table's 48 rules
# embedded (arms 0 / 1 its own), period 90 for the proof and 30 for round 1; the proof (repo root): the start table run raw = the shipped table
# run raw against the opponent's live table, seeds 601-700, both seats, 8 of 8 chunks -> ichigo/identity-s0-600.jsonl.
set -e
for p in ik:../../counter/frozen/q1-ichigo-ken.lisp ih:../pairs/ih/ih-fit.lisp ii:../pairs/ii/ii-fit.lisp; do
  k=${p%%:*}; e=${p#*:}
  sh run.sh $k start ichigo/$k-s0.lisp "" $e
  sh run.sh $k start ichigo/$k-s0-p30.lisp 30 $e
done
cd ../../../../..
F=docs/research/strategy-drsi/fq
S=$F/switch
P=$F/proof/identity.py
python3 $P ichigo kenpachi $S/kenpachi/qks-ichigo.lisp $S/ichigo/ik-s0.lisp --ref $F/../counter/frozen/q1-ichigo-ken.lisp > $S/ichigo/identity-s0-600.jsonl
python3 $P ichigo hisagi $S/hi/qhs3-ichigo.lisp $S/ichigo/ih-s0.lisp --ref $F/pairs/ih/ih-fit.lisp >> $S/ichigo/identity-s0-600.jsonl
python3 $P ichigo ichigo $F/pairs/ii/ii-fit.lisp $S/ichigo/ii-s0.lisp --ref $F/pairs/ii/ii-fit.lisp >> $S/ichigo/identity-s0-600.jsonl

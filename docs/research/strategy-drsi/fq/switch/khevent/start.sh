#!/bin/sh
# khevent/start.sh — step 6's start (DUEL_AI_STRATEGY §8.19 round 5, step 6), from the switch directory, on the build with the event layer and
# the stand-off breaker: KH's arms = :qks3-hisagi's (khstyle/kh.arms) + the stand-off breaker (:a-ken-kh-standoff) as arm 7;
#   kh-t0x.lisp = :qks3-hisagi extended with it, no layer: proved = the live lookup (identity-t0x-600.jsonl);
#   kh-t0.lisp  = the same with the layer on (:event-arms ((:knockdown <the bait>))): the fit's start and the "no refit" reference;
#   hk-t0.lisp  = HK's live :qhs-ken.
set -e
EV='(:id :kp7-kh :fn ken-kh-style :apply (:kenpachi))'
{ cat khstyle/kh.arms
  echo ";; targeted (round 5 step 6): Kenpachi's stand-off breaker against Hisagi (duel/lisp/cpu-kh-ken.lisp, :a-ken-kh-standoff)"
  echo "(:id :kp8-khso :fn ken-kh-standoff-style :apply (:kenpachi))"; } > khevent/kh.arms
python3 -B khjoint/extend.py --me kenpachi --vs hisagi --arms khstyle/kh.arms --table khstyle/kh-t2.lisp --new-arms khevent/kh.arms --out khevent/kh-t0x.lisp
python3 -B khjoint/extend.py --me kenpachi --vs hisagi --arms khstyle/kh.arms --table khstyle/kh-t2.lisp --new-arms khevent/kh.arms --out khevent/kh-t0.lisp --event "$EV"
cp corefit/hk-r1.lisp khevent/hk-t0.lisp
cd ../../../../..
F=docs/research/strategy-drsi/fq
python3 $F/proof/identity.py kenpachi hisagi $F/switch/corefit/hk-r1.lisp $F/switch/khevent/kh-t0x.lisp > $F/switch/khevent/identity-t0x-600.jsonl

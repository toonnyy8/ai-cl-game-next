#!/bin/sh
# khstyle/start.sh — the step-5 joint KH / HK fit's start (DUEL_AI_STRATEGY §8.19 round 5, step 5), from the switch directory, on the build with
# the kept duel/lisp/cpu-kh-ken.lisp: KH's live arms (khjoint/kh.arms) + the kept style as arm 6, the live :qks2-hisagi extended with it
# (khjoint/extend.py), HK's start = its live :qhs-ken (corefit/hk-r1.lisp, arms/hk.arms); kh-t0 proved = the live lookup (8 of 8 chunks)
# -> khstyle/kh.arms, kh-t0.lisp, hk-t0.lisp, identity-t0-600.jsonl
set -e
{ cat khjoint/kh.arms
  echo ";; targeted (round 5 step 5, the dream-rsi search): Kenpachi's style code against Hisagi (duel/lisp/cpu-kh-ken.lisp, :a-ken-kh)"
  echo "(:id :kp7-kh :fn ken-kh-style :apply (:kenpachi))"; } > khstyle/kh.arms
python3 -B khjoint/extend.py --me kenpachi --vs hisagi --arms khjoint/kh.arms --table khjoint/kh-t2.lisp --new-arms khstyle/kh.arms --out khstyle/kh-t0.lisp
cp corefit/hk-r1.lisp khstyle/hk-t0.lisp
cd ../../../../..
F=docs/research/strategy-drsi/fq
python3 $F/proof/identity.py kenpachi hisagi $F/switch/corefit/hk-r1.lisp $F/switch/khstyle/kh-t0.lisp > $F/switch/khstyle/identity-t0-600.jsonl

#!/bin/sh
# step4a.sh — step 4's KI / IK verdict (DUEL_AI_STRATEGY §8.19 round 5, step 4), from the switch directory, after run4.sh: the candidate per side
# (iterate 3 or 4 on 801-1000 against the last pool's members, select.sh), then the held-out 2x2 against the live lookup (old KI = :qks3-ichigo =
# joint/ki-t2.lisp, old IK = :q1-ichigo-ken) under step 3's fixed rule (heldout.sh) -> joint/select4.json, joint/heldout4.json.
set -e
FZI=../../counter/frozen/ki-ichigo.lisp
FZK=../../counter/frozen/ki-ken.lisp
Q1=../../counter/frozen/q1-ichigo-ken.lisp
KI0=kenpachi/qks-ichigo.lisp
TS="3 4" PFX=j4s OUT=joint/select4.json KPOOL="$Q1 joint/ik-t1.lisp joint/ik-t2.lisp joint/ik-t3.lisp $FZI" \
  IPOOL="$KI0 joint/ki-t1.lisp joint/ki-t2.lisp joint/ki-t3.lisp $FZK" sh joint/select.sh
K=$(python3 -c "import json; print(json.load(open('joint/select4.json'))['ki-pick'])")
I=$(python3 -c "import json; print(json.load(open('joint/select4.json'))['ik-pick'])")
KIO=joint/ki-t2.lisp PFX=j4h OUT=joint/heldout4.json sh joint/heldout.sh joint/ki-t$K.lisp joint/ik-t$I.lisp

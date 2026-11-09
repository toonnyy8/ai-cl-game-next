#!/bin/sh
# run4.sh — step 4's two more iterations of KI and IK optimised together (DUEL_AI_STRATEGY §8.19 round 5, step 4; the user, 2026-11-09:
# 「繼續同時優化 2 次」), from the switch directory. They start from the live lookup: KI_2 = :qks3-ichigo (joint/ki-t2.lisp), IK = :q1-ichigo-ken
# (its behaviour: ichigo/ik-s0-p30.lisp). Pools: every past iterate of the other side (step 3's included) + its frozen style CPU.
set -e
FZI=../../counter/frozen/ki-ichigo.lisp
FZK=../../counter/frozen/ki-ken.lisp
Q1=../../counter/frozen/q1-ichigo-ken.lisp
KI0=kenpachi/qks-ichigo.lisp
[ -f joint/ik-t3.lisp ] || sh joint/iterate.sh 2 joint/ki-t2.lisp ichigo/ik-s0-p30.lisp "$Q1,joint/ik-t1.lisp,joint/ik-t2.lisp,$FZI" "$KI0,joint/ki-t1.lisp,joint/ki-t2.lisp,$FZK"
[ -f joint/ik-t4.lisp ] || sh joint/iterate.sh 3 joint/ki-t3.lisp joint/ik-t3.lisp "$Q1,joint/ik-t1.lisp,joint/ik-t2.lisp,joint/ik-t3.lisp,$FZI" "$KI0,joint/ki-t1.lisp,joint/ki-t2.lisp,joint/ki-t3.lisp,$FZK"

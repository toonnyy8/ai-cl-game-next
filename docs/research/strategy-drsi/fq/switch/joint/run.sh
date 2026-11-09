#!/bin/sh
# run.sh — step 3's two iterations (DUEL_AI_STRATEGY §8.19 round 5, step 3), from the switch directory. KI_0 = :qks-ichigo, IK_0 = :q1-ichigo-ken
# (its behaviour: the grouped start embedding it). Pools: the other side's past iterates + its frozen style CPU.
set -e
FZI=../../counter/frozen/ki-ichigo.lisp
FZK=../../counter/frozen/ki-ken.lisp
Q1=../../counter/frozen/q1-ichigo-ken.lisp
KI0=kenpachi/qks-ichigo.lisp
mkdir -p joint
[ -f joint/ik-t1.lisp ] || sh joint/iterate.sh 0 $KI0 ichigo/ik-s0-p30.lisp "$Q1,$FZI" "$KI0,$FZK"
[ -f joint/ik-t2.lisp ] || sh joint/iterate.sh 1 joint/ki-t1.lisp joint/ik-t1.lisp "$Q1,joint/ik-t1.lisp,$FZI" "$KI0,joint/ki-t1.lisp,$FZK"

#!/bin/bash
# batch.sh name "k v k v" ... pairs
cd /media/8tsp/projects/ai-cl-game-next/docs/research/strategy-drsi/sp/ki-I/rounds/round02/nodes/b0_a0/scratch
base=${BASE:-v0.lisp}
while [ $# -ge 2 ]; do n=$1; a=$2; shift 2
 python3 mk.py $base p_$n.lisp $a; echo "$n [$a] => $(./ev.sh $PWD/p_$n.lisp)"; done

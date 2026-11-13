#!/bin/bash
cd /media/8tsp/projects/ai-cl-game-next
N=docs/research/strategy-drsi/sp/ki-I/rounds/round01/nodes/b1_a2/scratch
for f in "$@"; do
  r=$(SP_BUILD=29a3fe99 timeout 1500 python3 docs/research/strategy-drsi/sp/eval.py --me ichigo --vs kenpachi --cand /media/8tsp/projects/ai-cl-game-next/$N/$f.lisp --seed0 300 -j 3 2>&1 | tail -1)
  echo "$f $r" >> $N/results2.txt
done

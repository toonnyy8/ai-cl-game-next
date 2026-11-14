#!/bin/bash
# usage: run.sh name  (reads scratch/<name>.lisp)
cd /media/8tsp/projects/ai-cl-game-next; S=docs/research/strategy-drsi/sp; N=$S/ki-I-band/rounds/round01/nodes/b2_a1
python3 $S/band.py write --me ichigo --vs kenpachi --inc $S/arms/r2/c-ki-i-r2-b2a2.lisp --var $N/scratch/$1.lisp --band mycell --out $N/scratch/$1.cand.lisp >/dev/null || exit 1
SP_BUILD=db031584 python3 $S/eval.py --me ichigo --vs kenpachi --cand $N/scratch/$1.cand.lisp --seed0 300 -j 3 | tail -1

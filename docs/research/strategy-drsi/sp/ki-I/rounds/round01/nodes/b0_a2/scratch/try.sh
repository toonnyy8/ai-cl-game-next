#!/bin/bash
# usage: try.sh name "extra base keys"
S=/media/8tsp/projects/ai-cl-game-next/docs/research/strategy-drsi/sp/ki-I/rounds/round01/nodes/b0_a2/scratch
sed "s/:iks-gap-fs 150)/:iks-gap-fs 150 $2)/" $S/v0.lisp > $S/$1.lisp
cd /media/8tsp/projects/ai-cl-game-next
echo "$1 [$2] $(SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me ichigo --vs kenpachi --cand $S/$1.lisp --seed0 300 -j 3 | python3 -c "
import sys,json;d=json.load(sys.stdin);print(d['score'],{k:(v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in d['groups'].items()})")"

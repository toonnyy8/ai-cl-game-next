#!/bin/sh
# usage: run.sh name "extra base keys"
N=/media/8tsp/projects/ai-cl-game-next/docs/research/strategy-drsi/sp/ki-I/rounds/round02/nodes/b3_a0/scratch
sed "s/:iks-mix-whiff 1.5)/:iks-mix-whiff 1.5 $2)/" $N/v0.lisp | sed "s/:id :c-ki-i-r1-b3a2/:id :c-ki-i-r2-b3a0/" > $N/$1.lisp
cd /media/8tsp/projects/ai-cl-game-next && SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me ichigo --vs kenpachi --cand $N/$1.lisp --seed0 300 -j 3 2>&1 | python3 -c "
import sys,json
d=json.loads(sys.stdin.read().strip().splitlines()[-1]);g=d['groups']
print('$1','$2',d['score'],{k:(v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in g.items()})"

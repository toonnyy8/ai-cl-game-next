#!/bin/sh
# usage: run.sh "extra keys"  -> writes scratch/vN and evals
cd /media/8tsp/projects/ai-cl-game-next
sed "s/:kk-kikon-ptr-p 0.0)/:kk-kikon-ptr-p 0.0 $2)/" docs/research/strategy-drsi/sp/x-kh-H2/rounds/round01/nodes/b3_a0/scratch/v0.lisp > docs/research/strategy-drsi/sp/x-kh-H2/rounds/round01/nodes/b3_a0/scratch/$1.lisp
cat docs/research/strategy-drsi/sp/x-kh-H2/rounds/round01/nodes/b3_a0/scratch/$1.lisp
SP_BUILD=949a94db54fe python3 docs/research/strategy-drsi/sp/eval.py --me hisagi --vs kenpachi --cand $PWD/docs/research/strategy-drsi/sp/x-kh-H2/rounds/round01/nodes/b3_a0/scratch/$1.lisp --seed0 300 -j 3 2>&1 | python3 -c "
import sys,json
for l in sys.stdin:
    if l.startswith('{'):
        d=json.loads(l);print(d['score'],{k:(g['ko_wins'],g['ko_losses'],g['timeouts']) for k,g in d['groups'].items()})
    else: print(l)"

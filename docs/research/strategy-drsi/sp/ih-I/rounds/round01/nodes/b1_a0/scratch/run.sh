#!/bin/bash
# usage: run.sh name  (reads scratch/name.lisp)
cd /media/8tsp/projects/ai-cl-game-next
SP_BUILD=db031584 python3 docs/research/strategy-drsi/sp/eval.py --me ichigo --vs hisagi --cand $PWD/docs/research/strategy-drsi/sp/ih-I/rounds/round01/nodes/b1_a0/scratch/$1.lisp --seed0 300 -j 3 | python3 -c "
import json,sys
d=json.loads(sys.stdin.read());print('$1',d['score'],{k:(v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in d['groups'].items()})"

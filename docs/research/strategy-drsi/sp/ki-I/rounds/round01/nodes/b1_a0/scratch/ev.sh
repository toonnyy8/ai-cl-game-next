#!/bin/bash
cd /media/8tsp/projects/ai-cl-game-next
SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me ichigo --vs kenpachi --cand $PWD/docs/research/strategy-drsi/sp/ki-I/rounds/round01/nodes/b1_a0/scratch/$1.lisp --seed0 300 -j 3 | python3 -c "
import sys,json
d=json.loads(sys.stdin.read().strip().splitlines()[-1]); print('$1',d['score'],[(k,v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in d['groups'].items()] if 'groups' in d else d)"

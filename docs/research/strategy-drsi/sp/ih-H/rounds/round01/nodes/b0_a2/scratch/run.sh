#!/bin/bash
# usage: run.sh name  (reads scratch/name.lisp)
cd /media/8tsp/projects/ai-cl-game-next
N=docs/research/strategy-drsi/sp/ih-H/rounds/round01/nodes/b0_a2
SP_BUILD=5aac2ad2 python3 docs/research/strategy-drsi/sp/eval.py --me hisagi --vs ichigo --cand $PWD/$N/scratch/$1.lisp --seed0 300 -j 3 | python3 -c "
import sys,json
d=json.loads(sys.stdin.read().strip().splitlines()[-1]);print('$1',d['score'],{k:(v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in d['groups'].items()} if 'groups' in d else d)"

#!/bin/sh
cd /media/8tsp/projects/ai-cl-game-next
for v in "$@"; do echo $v; SP_BUILD=db031584 timeout 300 python3 docs/research/strategy-drsi/sp/eval.py --me hisagi --vs ichigo --cand $PWD/docs/research/strategy-drsi/sp/ih-H/rounds/round01/nodes/b1_a0/scratch/$v.lisp --seed0 300 -j 3 | python3 -c "
import json,sys;d=json.loads(sys.stdin.read());print(d['score'],{k:(g['ko_wins'],g['ko_losses'],g['timeouts']) for k,g in d['groups'].items()})"; done

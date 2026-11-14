#!/bin/sh
cd /media/8tsp/projects/ai-cl-game-next
SP_BUILD=db031584 python3 docs/research/strategy-drsi/sp/eval.py --me hisagi --vs ichigo --cand "$1" --seed0 300 -j 3 | python3 -c "
import sys,json;d=json.loads(sys.stdin.read().strip().splitlines()[-1]);print('$(basename $1)',d['score'],{g:(v['ko_wins'],v['ko_losses'],v['timeouts']) for g,v in d['groups'].items()})"

#!/bin/sh
cd /media/8tsp/projects/ai-cl-game-next
SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me ichigo --vs kenpachi --cand "$1" --seed0 300 -j 3 | python3 -c "
import sys,json
d=json.loads(sys.stdin.read().strip().splitlines()[-1]); g=d['groups']
print(d['score'],' '.join('%s %d/%d/%d'%(k,g[k]['ko_wins'],g[k]['ko_losses'],g[k]['timeouts']) for k in ('anchor','mix','rest')))"

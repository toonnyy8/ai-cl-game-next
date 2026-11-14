#!/bin/sh
# ev.sh FILE SEED0
cd /media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-a9e43c5f5424bb955
python3 docs/research/strategy-drsi/sp/eval.py --me ichigo --vs kenpachi --cand $1 --seed0 $2 -j 3 | python3 -c "
import json,sys; j=json.load(sys.stdin); g=j['groups']; print('$(basename $1) s$2', j['score'], {k:(g[k]['ko_wins'],g[k]['ko_losses'],g[k]['timeouts']) for k in g})"

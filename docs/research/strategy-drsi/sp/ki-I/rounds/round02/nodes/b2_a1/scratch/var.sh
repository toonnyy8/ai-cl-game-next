#!/bin/sh
# var.sh NAME "KEY VAL KEY VAL"  -> prepend keys into v1.lisp's :base, eval
S=/tmp/claude-1000/-media-8tsp-projects-ai-cl-game-next/ae4fc6c9-5486-4f14-9b2d-a6ec715b6738/scratchpad/b2a1
sed "s/:base (/:base ($2 /" $S/${3:-v1}.lisp > $S/var-$1.lisp
cd /media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-a9e43c5f5424bb955
python3 docs/research/strategy-drsi/sp/eval.py --me ichigo --vs kenpachi --cand $S/var-$1.lisp --seed0 300 -j 3 | python3 -c "
import json,sys; j=json.load(sys.stdin); g=j['groups']; print('$1', j['score'], {k:(g[k]['ko_wins'],g[k]['ko_losses'],g[k]['timeouts']) for k in g})"

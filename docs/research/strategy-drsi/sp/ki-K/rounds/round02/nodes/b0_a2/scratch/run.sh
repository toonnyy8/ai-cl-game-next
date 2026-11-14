cd /media/8tsp/projects/ai-cl-game-next
S=docs/research/strategy-drsi/sp/ki-K/rounds/round02/nodes/b0_a2/scratch
for v in "$@"; do echo $v; SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me kenpachi --vs ichigo --cand $PWD/$S/${v%@*}.lisp --seed0 ${v#*@} -j 3 | python3 -c "
import json,sys;d=json.loads(sys.stdin.read());print(d['score'],{g:(x['ko_wins'],x['ko_losses'],x['timeouts']) for g,x in d['groups'].items()})"; done

cd /media/8tsp/projects/ai-cl-game-next; N=docs/research/strategy-drsi/sp/ki-K/rounds/round01/nodes/b0_a0/scratch
for v in "$@"; do SP_BUILD=29a3fe99 timeout 300 python3 docs/research/strategy-drsi/sp/eval.py --me kenpachi --vs ichigo --cand $PWD/$N/$v.lisp --seed0 300 -j 3 | python3 -c "
import sys,json
d=json.loads(sys.stdin.read());print('$v',d['score'],{k:(v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in d['groups'].items()})"; done

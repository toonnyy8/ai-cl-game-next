cd /media/8tsp/projects/ai-cl-game-next
R=docs/research/strategy-drsi/sp/x-kh-H/rounds/round01/nodes/b3_a1
cp $R/scratch/$1.lisp $R/cand.lisp
SP_BUILD=949a94db54fe python3 docs/research/strategy-drsi/sp/eval.py --me hisagi --vs kenpachi --cand $PWD/$R/cand.lisp --seed0 300 -j 3 > $R/scratch/$1.out 2>&1
python3 - $R/scratch/$1.out <<'PY'
import sys,json
for l in open(sys.argv[1]):
    if l.startswith('{'):
        d=json.loads(l); print(d.get('score'), {k:(v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in d.get('groups',{}).items()})
        if 'groups' not in d: print(list(d))
    else: print(l[:300])
PY

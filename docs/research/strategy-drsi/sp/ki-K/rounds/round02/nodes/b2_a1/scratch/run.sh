cd /media/8tsp/projects/ai-cl-game-next
for v in v7 v8 v9; do echo $v; SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me kenpachi --vs ichigo --cand $PWD/docs/research/strategy-drsi/sp/ki-K/rounds/round02/nodes/b2_a1/scratch/$v.lisp --seed0 300 -j 3 2>&1 | cut -c1-420; done

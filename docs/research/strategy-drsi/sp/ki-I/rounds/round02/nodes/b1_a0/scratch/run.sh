#!/bin/bash
# usage: run.sh name "extra base keys"
cd /media/8tsp/projects/ai-cl-game-next
D=docs/research/strategy-drsi/sp/ki-I/rounds/round02/nodes/b1_a0/scratch
BASE=':range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :b-walk-in 0.06 :b-j1 0.05 :b-step-in 0.03 :b-wait -0.05 :b-walk-out -0.08 :b-step-out -0.05'
RULES='(((:ost :down)) (:b-walk-in 0.14 :b-j1 0.12 :b-wait -0.12)) (((:dj :in)) (:b-j1 0.12 :b-step-out -0.1)) (((:dj :afar)) (:b-walk-in 0.12 :b-step-in 0.08)) (((:ost :active) (:dj :in)) (:b-hoho -0.05))'
echo "(:id :c-ki-i-r2-b1a0 :fn ichigo-ki-style :apply (:ichigo) :base ($BASE $2) :rules ($RULES))" > $D/$1.lisp
SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me ichigo --vs kenpachi --cand $PWD/$D/$1.lisp --seed0 300 -j 3 | python3 -c "
import sys,json;d=json.loads(sys.stdin.read());g=d['groups'];print('$1','$2',d['score'],{k:(v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in g.items()})"

#!/bin/sh
D=/media/8tsp/projects/ai-cl-game-next/docs/research/strategy-drsi/sp/ki-I/rounds/round01/nodes/b3_a2
B=":iks-mix-ptr3 0.6 :iks-mix-space 0.1 :iks-wait-max 40 :iks-gap-p 1.0 :iks-gap-fs 150 :iks-ns-wait 24 :iks-getsuga-min 6.5"
cat > $D/scratch/$1.lisp <<EOT
(:id :c-ki-i-r1-b3a2 :fn ichigo-ki-style :apply (:ichigo) :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :b-walk-in 0.06 :b-j1 0.05 :b-step-in 0.03 :b-wait -0.05 :b-walk-out -0.08 :b-step-out -0.05 $B $2) :rules ((((:ost :down)) (:b-walk-in 0.14 :b-j1 0.12 :b-wait -0.12)) (((:dj :in)) (:b-j1 0.12 :b-step-out -0.1)) (((:dj :afar)) (:b-walk-in 0.12 :b-step-in 0.08)) (((:ost :active) (:dj :in)) (:b-hoho -0.05))))
EOT
cd /media/8tsp/projects/ai-cl-game-next && SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me ichigo --vs kenpachi --cand $D/scratch/$1.lisp --seed0 300 -j 3 | tail -1 > $D/scratch/$1.out
echo "$1 $2 :: $(python3 -c "import json;d=json.load(open('$D/scratch/$1.out'));print(d['score'],[(k,v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in d['groups'].items()])")"

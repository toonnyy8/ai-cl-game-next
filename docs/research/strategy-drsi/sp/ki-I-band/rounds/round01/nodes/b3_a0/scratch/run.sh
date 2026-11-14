#!/bin/sh
# usage: run.sh name "extra base keys"   (extra keys prepended to arm k's :base)
cd /media/8tsp/projects/ai-cl-game-next
S=docs/research/strategy-drsi/sp; N=$S/ki-I-band/rounds/round01/nodes/b3_a0
cat > $N/scratch/armk-$1.lisp <<EOT
(:id :c-ki-i-r3-b3a0-k :fn ichigo-ki-r2b2a1-style :apply (:ichigo) :base ($2 :ikw-roll-x 0.7 :ikw-roll-y 0.7 :range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :b-walk-in 0.06 :b-j1 0.05 :b-step-in 0.03 :b-wait -0.05 :b-walk-out -0.08 :b-step-out -0.05 :iks-mix-ptr3 0.6 :iks-mix-space 0.0 :iks-wait-max 40 :iks-gap-p 1.0 :iks-gap-fs 150 :iks-ns-wait 24 :iks-getsuga-min 6.5 :iks-meaty-p 0.0 :iks-mix-whiff 1.5) :rules ((((:ost :down)) (:b-walk-in 0.14 :b-j1 0.12 :b-wait -0.12)) (((:dj :in)) (:b-j1 0.12 :b-step-out -0.1)) (((:dj :afar)) (:b-walk-in 0.12 :b-step-in 0.08)) (((:ost :active) (:dj :in)) (:b-hoho -0.05))))
EOT
python3 $S/band.py write --me ichigo --vs kenpachi --inc $S/arms/r2/c-ki-i-r2-b2a2.lisp --var $N/scratch/armk-$1.lisp --band awake --out $N/scratch/cand-$1.lisp >/dev/null || exit 1
echo "$1: $2"
SP_BUILD=db031584 python3 $S/eval.py --me ichigo --vs kenpachi --cand $N/scratch/cand-$1.lisp --seed0 300 -j 3 | tail -1

#!/bin/sh
# usage: run.sh name "keys"
N=docs/research/strategy-drsi/sp/ki-K-band/rounds/round01/nodes/b0_a1
echo "(:id :c-ki-k-r3-b0a1-k :fn ken-kh-standoff-style :apply (:kenpachi) :base ($2 :range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 4.5 :kk-step-p 1.0 :kk-bankai-p 0.0 :kk-reach-p 0.5 :kk-ns-safe-p 0.8 :other 10.0 :kikon 0.3))" > $N/scratch/$1.lisp
python3 docs/research/strategy-drsi/sp/band.py write --me kenpachi --vs ichigo --inc docs/research/strategy-drsi/sp/arms/r2/c-ki-k-r2-b1a2.lisp --var $N/scratch/$1.lisp --band nocell --out $N/scratch/$1.cand.lisp >/dev/null || exit 1
SP_BUILD=db031584 python3 docs/research/strategy-drsi/sp/eval.py --me kenpachi --vs ichigo --cand $N/scratch/$1.cand.lisp --seed0 300 -j 3 | tail -1

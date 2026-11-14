#!/bin/bash
# usage: gen.sh name "extra keys"
D=docs/research/strategy-drsi/sp/ki-K/rounds/round02/nodes/b2_a2
FN=${FN:-ken-kh-standoff-style}
echo "(:id :c-ki-k-r2-b2a2 :fn $FN :apply (:kenpachi) :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 0.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 7.0 :kk-step-p 1.0 :kk-bankai-p 0.0 :kk-reach-p 0.5 :kk-dodge-p 0.0 :kk-brawl-p 0.2 $2) $3)" > $D/scratch/$1.lisp
SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me kenpachi --vs ichigo --cand $D/scratch/$1.lisp --seed0 300 -j 3 | tail -1 | cut -c1-600

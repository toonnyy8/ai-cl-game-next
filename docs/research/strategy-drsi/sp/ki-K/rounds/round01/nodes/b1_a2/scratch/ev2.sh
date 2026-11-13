#!/bin/bash
# usage: ev.sh "extra base keys"  name
N=/media/8tsp/projects/ai-cl-game-next/docs/research/strategy-drsi/sp/ki-K/rounds/round01/nodes/b1_a2
BASE=":range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :b-walk-in 0.06 :b-j1 0.05 :b-step-in 0.03 :b-wait -0.05 :b-walk-out -0.08 :b-step-out -0.05 :kk-step-in-p 0.0 :kk-awaken-p 0.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 7.0 :kk-step-p 1.0"
echo "(:id :c-ki-k-r1-b1a2 :fn ken-kh-standoff-style :apply (:kenpachi) :base ($BASE $1) :rules ($3 (((:ost :down)) (:b-walk-in 0.14 :b-j1 0.12 :b-wait -0.12)) (((:dj :in)) (:b-j1 0.12 :b-step-out -0.1)) (((:dj :afar)) (:b-walk-in 0.12 :b-step-in 0.08)) (((:ost :active) (:dj :in)) (:b-hoho -0.05))))" > $N/scratch/$2.lisp
cd /media/8tsp/projects/ai-cl-game-next
echo "$2 [$1]: $(SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me kenpachi --vs ichigo --cand $N/scratch/$2.lisp --seed0 300 -j 3 2>&1 | tail -1)"

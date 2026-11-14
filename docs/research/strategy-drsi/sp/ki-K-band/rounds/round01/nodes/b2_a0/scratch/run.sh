#!/bin/bash
# usage: run.sh name "base plist body"
cd /media/8tsp/projects/ai-cl-game-next
D=docs/research/strategy-drsi/sp/ki-K-band/rounds/round01/nodes/b2_a0
N=$1; B=$2
echo "(:id :c-ki-k-r3-b2a0-k :fn ken-kh-standoff-style :apply (:kenpachi) :base ($B :range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 4.5 :kk-step-p 1.0 :kk-bankai-p 0.0 :kk-reach-p 0.5 :kk-ns-safe-p 0.8 :other 10.0 :kikon 0.3))" > $D/scratch/$N.armk.lisp
python3 docs/research/strategy-drsi/sp/band.py write --me kenpachi --vs ichigo --inc docs/research/strategy-drsi/sp/arms/r2/c-ki-k-r2-b1a2.lisp --var $D/scratch/$N.armk.lisp --band bothrich --out $D/scratch/$N.cand.lisp >/dev/null || exit 1
SP_BUILD=db031584 python3 docs/research/strategy-drsi/sp/eval.py --me kenpachi --vs ichigo --cand $D/scratch/$N.cand.lisp --seed0 300 -j 3 | tail -1 | tee $D/scratch/$N.res | python3 -c "import sys,json;d=json.loads(sys.stdin.read());print(d[\"score\"],{k:(v[\"ko_wins\"],v[\"timeouts\"]) for k,v in d[\"groups\"].items()})"

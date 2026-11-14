# usage: gen.sh name "base extras" ["extra top-level e.g. :rules (...)"]
D=/media/8tsp/projects/ai-cl-game-next/docs/research/strategy-drsi/sp/ki-K/rounds/round02/nodes/b1_a2
echo "(:id :c-ki-k-r2-b1a2 :fn ken-kh-standoff-style :apply (:kenpachi) :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 4.5 :kk-step-p 1.0 :kk-bankai-p 0.0 :kk-reach-p 0.5 :kk-ns-safe-p 0.8 $2) $3)" > $D/scratch/$1.lisp
cd /media/8tsp/projects/ai-cl-game-next && SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me kenpachi --vs ichigo --cand $D/scratch/$1.lisp --seed0 300 -j 3 | tail -1 | grep -o '"score": [0-9.]*\|"anchor": {[^}]*\|"mix": {[^}]*'|cut -c1-90|tr '\n' ' '

#!/bin/sh
# usage: run.sh name 'base-plist-inner' 'rules'
D=/media/8tsp/projects/ai-cl-game-next/docs/research/strategy-drsi/sp/ih-H/rounds/round01/nodes/b3_a2
echo "(:id :c-ih-h-r1-b3a2 :fn hisagi-range-style :apply (:hisagi) :dswitch-map ((:base 1 3)) :base ($2) :rules ($3))" > $D/scratch/$1.lisp
cd /media/8tsp/projects/ai-cl-game-next && SP_BUILD=5aac2ad2 python3 docs/research/strategy-drsi/sp/eval.py --me hisagi --vs ichigo --cand $D/scratch/$1.lisp --seed0 300 -j 3 | cut -c1-600

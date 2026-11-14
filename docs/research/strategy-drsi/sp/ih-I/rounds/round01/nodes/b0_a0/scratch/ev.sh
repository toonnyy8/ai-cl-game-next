#!/bin/sh
cd /media/8tsp/projects/ai-cl-game-next && SP_BUILD=db031584 timeout 500 python3 docs/research/strategy-drsi/sp/eval.py --me ichigo --vs hisagi --cand "$1" --seed0 300 -j 3 | tail -1 | cut -c1-900

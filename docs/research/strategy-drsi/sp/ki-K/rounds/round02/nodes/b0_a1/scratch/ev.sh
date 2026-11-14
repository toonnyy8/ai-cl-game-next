#!/bin/sh
cd /media/8tsp/projects/ai-cl-game-next
SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me kenpachi --vs ichigo --cand $1 --seed0 300 -j 3

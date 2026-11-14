#!/bin/bash
cd /media/8tsp/projects/ai-cl-game-next
R=docs/research/strategy-drsi/sp; S=$PWD/$R/ki-K-band/rounds/round01/nodes/b1_a1/scratch
name=$1; extra=$2
python3 - "$S/$name.arm.lisp" "$extra" <<'PY'
import sys
out,extra=sys.argv[1:3]
src=open('docs/research/strategy-drsi/sp/arms/r2/c-ki-k-r2-b1a2.lisp').read().split('\n')[0]
src=src.replace(':id :c-ki-k-r2-b1a2',':id :c-ki-k-r3-b1a1-k').replace(':base (',':base ('+extra+' ',1)
open(out,'w').write(src+'\n')
PY
python3 $R/band.py write --me kenpachi --vs ichigo --inc $R/arms/r2/c-ki-k-r2-b1a2.lisp --var $S/$name.arm.lisp --band mycell --out $S/$name.cand.lisp >/dev/null || exit 1
echo "$name: $extra"; SP_BUILD=db031584 python3 $R/eval.py --me kenpachi --vs ichigo --cand $S/$name.cand.lisp --seed0 300 -j 3 | tail -1

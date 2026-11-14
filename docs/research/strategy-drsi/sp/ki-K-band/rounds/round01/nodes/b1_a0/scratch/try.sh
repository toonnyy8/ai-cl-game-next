#!/bin/bash
# usage: try.sh NAME "base-and-rules-plist-tail"  (keys appended to arm0 :base via first-wins: prepend)
cd /media/8tsp/projects/ai-cl-game-next
R=docs/research/strategy-drsi/sp; N=$PWD/$R/ki-K-band/rounds/round01/nodes/b1_a0; S=$N/scratch
name=$1; extra=$2; rules=$3
python3 - "$S/$name.arm.lisp" "$name" "$extra" "$rules" <<'PY'
import sys,re
out,name,extra,rules=sys.argv[1:5]
src=open('docs/research/strategy-drsi/sp/arms/r2/c-ki-k-r2-b1a2.lisp').read().split('\n')[0]
src=src.replace(':id :c-ki-k-r2-b1a2',':id :c-ki-k-r3-b1a0-k')
src=src.replace(':base (',':base ('+extra+' ',1)
if rules: src=src.rstrip()[:-1]+' :rules ('+rules+'))'
open(out,'w').write(src+'\n')
PY
python3 $R/band.py write --me kenpachi --vs ichigo --inc $R/arms/r2/c-ki-k-r2-b1a2.lisp --var $S/$name.arm.lisp --band mycell --out $S/$name.cand.lisp >/dev/null || exit 1
SP_BUILD=db031584 python3 $R/eval.py --me kenpachi --vs ichigo --cand $S/$name.cand.lisp --seed0 300 -j 3 | tail -1

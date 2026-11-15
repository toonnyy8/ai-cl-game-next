#!/bin/bash
# rec.sh WS CELL : re-run score.py on the cell's arm.lisp (block 300; a cache hit when the cell ran this file), record the measured score
D=/home/toonnyy8/.claude/skills/synced/7f737b32-2195-42cb-9ed8-f258b4adfc44_6dea4635-794e-428f-ad78-e0970a6148e7/dream-rsi/scripts/drsi.py
C=$(cd "$(dirname "$0")" && pwd)
W=$C/$1
N=$(ls -d $W/rounds/round*/nodes/$2 | tail -1)
if [ ! -f $N/arm.lisp ]; then python3 $D -w $W record --cell $2 --fail-class runtime --error "no arm.lisp written"; exit; fi
OUT=$(cd $C && python3 score.py $1 $N -j 4 2>&1 | tail -1)
SC=$(echo "$OUT" | python3 -c "import json,sys;print(json.load(sys.stdin)['score'])" 2>/dev/null)
if [ -n "$SC" ]; then
  echo "$1 $2 $SC $(echo "$OUT" | python3 -c "import json,sys;d=json.load(sys.stdin);print({p:{g:(v['ko_wins'],v['ko_losses'],v['timeouts']) for g,v in x['groups'].items()} for p,x in d['parts'].items()})")"
  python3 $D -w $W record --cell $2 --score $SC >/dev/null
else
  echo "$1 $2 FAIL $OUT"; python3 $D -w $W record --cell $2 --fail-class compile_other --error "$OUT" >/dev/null
fi

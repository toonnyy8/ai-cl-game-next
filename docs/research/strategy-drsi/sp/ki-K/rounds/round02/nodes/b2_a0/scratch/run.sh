#!/bin/bash
# usage: run.sh name "overrides" [rules]
cd /media/8tsp/projects/ai-cl-game-next
D=docs/research/strategy-drsi/sp/ki-K/rounds/round02/nodes/b2_a0
python3 - "$1" "$2" "${3:-}" <<'PY'
import sys,re,os
name,ov,rules=sys.argv[1:4]
D="docs/research/strategy-drsi/sp/ki-K/rounds/round02/nodes/b2_a0"
base=dict(re.findall(r":(\S+) (\S+)",":range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 0.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 7.0 :kk-step-p 1.0 :kk-bankai-p 0.0 :kk-reach-p 0.5"))
base.update(dict(re.findall(r":(\S+) (\S+)",ov)))
b=" ".join(f":{k} {v}" for k,v in base.items())
r=f" :rules ({rules})" if rules else ""
open(f"{D}/scratch/{name}.lisp","w").write(f"(:id :c-ki-k-r2-b2a0 :fn ken-kh-standoff-style :apply (:kenpachi) :base ({b}){r})\n")
PY
echo -n "$1 [$2 $3] "
SP_BUILD=29a3fe99 python3 docs/research/strategy-drsi/sp/eval.py --me kenpachi --vs ichigo --cand $PWD/$D/scratch/$1.lisp --seed0 300 -j 3 | python3 -c "import json,sys;j=json.loads(sys.stdin.read());print(j['score'],{k:(g['ko_wins'],g['ko_losses'],g['timeouts']) for k,g in j['groups'].items()})"

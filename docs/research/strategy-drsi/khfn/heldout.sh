#!/bin/bash
# heldout.sh NODE_DIR — the keep rule's measure (DUEL_AI_STRATEGY §8.19 round 5, step 5) for one delivered cell, in the coordinator's checkout
# under the rescore lock: the held-out block (seed0 400, scale 2) -> NODE_DIR/heldout.json, then the rule against refs.jsonl's two KI codes on
# the same block (score >= the better + 0.03; live group >= the better live; mean |member difference| >= 0.05 against both).
set -u
N=$(cd "$1" && pwd)
TOP=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$TOP/../../../.." && pwd)
F=$REPO/duel/lisp/cpu-kh-ken.lisp
exec 9>"$TOP/.rescore.lock"; flock 9
restore() { cp "$TOP/baseline/cpu-kh-ken.lisp" "$F"; touch "$F"; }
trap restore EXIT
cp "$N/cpu-kh-ken.lisp" "$F" && touch "$F"
cd "$REPO" && timeout 3600 python3 "$TOP/eval.py" --seed0 400 --scale 2 -j ${JOBS:-10} > "$N/heldout.json" || exit 5
python3 - "$N/heldout.json" "$TOP/refs.jsonl" <<'EOF'
import json, sys
h = json.load(open(sys.argv[1]))
refs = {d['cand']: d for d in map(json.loads, open(sys.argv[2])) if d['seed0'] == 400}
ki, ik = refs['cand-khfn'], refs['k5-iki']
dist = lambda a, b: round(sum(abs(a['members'][k] - b['members'][k]) for k in a['members']) / len(a['members']), 4)
best = max(ki['score'], ik['score']); live = max(ki['groups']['live'], ik['groups']['live'])
r = dict(score=h['score'], live=h['groups']['live'], need_score=round(best + 0.03, 4), need_live=live,
         dist_ken_ki=dist(h, ki), dist_ichigo_ki=dist(h, ik), inc_live=h['inc_live'])
r['keep'] = h['score'] >= best + 0.03 and h['groups']['live'] >= live and r['dist_ken_ki'] >= 0.05 and r['dist_ichigo_ki'] >= 0.05
print(json.dumps(r))
EOF

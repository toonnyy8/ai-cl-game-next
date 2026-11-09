#!/bin/bash
# heldout.sh NODE_DIR — the keep rule's measure (DUEL_AI_STRATEGY §8.19 round 5, step 7) for one delivered cell, in the coordinator's checkout
# under the rescore lock: the held-out block (seed0 400, scale 2) -> NODE_DIR/heldout.json, then the rule against refs.jsonl's four existing
# Hisagi styles on the same block (score >= the best + 0.03; the live-KH and the stand-in groups >= the best style's in each; mean |member
# difference| >= 0.05 against every one of the four).
set -u
N=$(cd "$1" && pwd)
TOP=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$TOP/../../../.." && pwd)
F=$REPO/duel/lisp/cpu-hk-hisagi.lisp
exec 9>"$TOP/.rescore.lock"; flock 9
restore() { cp "$TOP/baseline/cpu-hk-hisagi.lisp" "$F"; touch "$F"; }
trap restore EXIT
cp "$N/cpu-hk-hisagi.lisp" "$F" && touch "$F"
cd "$REPO" && timeout 3600 python3 "$TOP/eval.py" --seed0 400 --scale 2 -j ${JOBS:-10} > "$N/heldout.json" || exit 5
python3 - "$N/heldout.json" "$TOP/refs.jsonl" <<'EOF'
import json, sys
h = json.load(open(sys.argv[1]))
refs = {d['cand']: d for d in map(json.loads, open(sys.argv[2])) if d['seed0'] == 400}
st = [refs[c] for c in ('cand-hkfn', 'h2-kenki', 'h7-iki', 'h8-range')]   # (his merged style = the baseline, Kenpachi's KI code, Ichigo's, the ranged style)
dist = lambda a, b: round(sum(abs(a['members'][k] - b['members'][k]) for k in a['members']) / len(a['members']), 4)
best = max(x['score'] for x in st); live = max(x['groups']['live'] for x in st); sti = max(x['groups']['standin'] for x in st)
r = dict(score=h['score'], live=h['groups']['live'], standin=h['groups']['standin'], need_score=round(best + 0.03, 4), need_live=live,
         need_standin=sti, dist=[dist(h, x) for x in st], inc_live=h['inc_live'])
r['keep'] = h['score'] >= best + 0.03 and h['groups']['live'] >= live and h['groups']['standin'] >= sti and min(r['dist']) >= 0.05
print(json.dumps(r))
EOF

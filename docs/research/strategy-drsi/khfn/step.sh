#!/bin/bash
# step.sh — the coordinator's loop for the KH style-code search (DUEL_AI_STRATEGY §8.19 round 5, step 5), one dream-rsi workspace (this dir):
#   step.sh next                       ask the policy for the next batch; write a brief for each cell not yet briefed
#   step.sh done <cell> <round> <wt>   copy the cell's deliverables from its worktree, rescore (rescore.sh: the frozen evaluator, seed0 200),
#                                      record the RESCORED score with a truthful --fail-class, then next
#   step.sh fail <cell> <round> <class> <error>
# FORCE=1 re-records a cell (a coordinator's mistake only). DREAM_RSI = the skill's directory.
set -u
TOP=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$TOP/../../../.." && pwd); REL=${TOP#$REPO/}
DREAM_RSI=${DREAM_RSI:-$(ls -d "$HOME"/.claude/skills/synced/*/dream-rsi 2>/dev/null | head -1)}
DRSI="python3 $DREAM_RSI/scripts/drsi.py -w $TOP"
next() {
  local W ST R
  W=$($DRSI next-batch) || exit 1
  ST=$(python3 -c "import json,sys; print(json.loads(sys.argv[1])['status'])" "$W")
  R=$(python3 -c "import json,sys; print(json.loads(sys.argv[1]).get('round', 0))" "$W")
  [ "$ST" != execute ] && { echo "round $R: $ST"; return; }
  python3 - "$W" "$TOP" "$R" <<'PY'
import json, os, subprocess, sys
w, top, r = json.loads(sys.argv[1]), sys.argv[2], int(sys.argv[3])
for x in w['work']:
    d = os.path.join(top, 'rounds', f'round{r:02d}', 'nodes'); os.makedirs(d, exist_ok=True)
    b = os.path.join(d, x['cell'] + '.brief.md')
    if os.path.exists(b): print(f"in flight: {x['cell']}"); continue
    open(b, 'w').write(subprocess.run([sys.executable, '-B', os.path.join(top, 'brief.py'), x['cell'], str(r), json.dumps(x)],
                                      capture_output=True, text=True, check=True).stdout)
    print(f"dispatch: {x['cell']} (round {r}) {b}")
PY
}
record() { $DRSI record --round "$2" --cell "$1" ${3:+--score $3} --fail-class "$4" ${5:+--error "$5"} --note "$6" ${FORCE:+--force} >/dev/null || exit 1
           echo "recorded $1 (round $2): ${3:-none} $4 ${5:-}"; }
case "${1:-}" in
  next) next ;;
  fail) record "$2" "$3" "" "$4" "$5" "nothing scorable"; next ;;
  done) C=$2; R=$3; RR=$(printf %02d "$R"); N=$TOP/rounds/round$RR/nodes/$C; mkdir -p "$N"
        [ -f "$N/cpu-kh-ken.lisp" ] || cp "$4/$REL/rounds/round$RR/nodes/$C/"{cpu-kh-ken.lisp,proposal.md,score.json} "$N/" 2>/dev/null
        exec 9>"$TOP/.rescore.lock"; flock 9
        [ -f "$N/cpu-kh-ken.lisp" ] || { record "$C" "$R" "" runtime "no style file delivered" "-"; next; exit 0; }
        bash "$TOP/rescore.sh" "$N" >/dev/null; rc=$?
        case $rc in
          0) S=$(python3 -c "import json,sys; print(json.loads(open(sys.argv[1]).read().strip().splitlines()[-1])['score'])" "$N/score.rescored.json")
             P=$(python3 -c "import json,sys; j=json.loads(open(sys.argv[1]).read().strip().splitlines()[-1]); print(' '.join(f'{k} {v}' for k, v in j['groups'].items()))" "$N/score.rescored.json")
             record "$C" "$R" "$S" ok "" "$P" ;;
          2) record "$C" "$R" "" compile_other "native build failed" "rescore" ;;
          3) record "$C" "$R" "" correctness "host tests failed" "rescore" ;;
          4) record "$C" "$R" "" resource "eval timed out" "rescore" ;;
          *) record "$C" "$R" "" runtime "rescore exited $rc" "rescore" ;;
        esac; next ;;
  *) sed -n 2,8p "$0"; exit 2 ;;
esac

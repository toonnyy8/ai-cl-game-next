#!/bin/bash
# step.sh — the coordinator's loop for the KI matchup search (DUEL_MATCHUP_AI §7), one dream-rsi workspace a side (ken/, ichigo/):
#   step.sh <side> next                       ask the side's policy for the next batch; write a brief for each cell not yet briefed
#   step.sh <side> done <cell> <round> <wt>   copy the cell's deliverables from its worktree, rescore (frozen evaluator, the other side's
#                                             champion), record the RESCORED score with a truthful --fail-class, then next
#   step.sh <side> fail <cell> <round> <class> <error>
# FORCE=1 re-records a cell (a coordinator's mistake only).
set -u
TOP=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$TOP/../../.." && pwd); REL=${TOP#$REPO/}
SIDE=$1; shift; WS=$TOP/$SIDE
DREAM_RSI=${DREAM_RSI:-$(ls -d "$HOME"/.claude/skills/synced/*/dream-rsi 2>/dev/null | head -1)}
DRSI="python3 $DREAM_RSI/scripts/drsi.py -w $WS"
next() {
  local W ST R
  W=$($DRSI next-batch) || exit 1
  ST=$(python3 -c "import json,sys; print(json.loads(sys.argv[1])['status'])" "$W")
  R=$(python3 -c "import json,sys; print(json.loads(sys.argv[1]).get('round', 0))" "$W")
  [ "$ST" != execute ] && { echo "$SIDE round $R: $ST"; return; }
  python3 - "$W" "$TOP" "$SIDE" "$R" <<'PY'
import json, os, subprocess, sys
w, top, side, r = json.loads(sys.argv[1]), sys.argv[2], sys.argv[3], int(sys.argv[4])
for x in w['work']:
    d = os.path.join(top, side, 'rounds', f'round{r:02d}', 'nodes'); os.makedirs(d, exist_ok=True)
    b = os.path.join(d, x['cell'] + '.brief.md')
    if os.path.exists(b): print(f"in flight: {side} {x['cell']}"); continue
    open(b, 'w').write(subprocess.run([sys.executable, os.path.join(top, 'brief.py'), side, x['cell'], str(r), json.dumps(x)],
                                      capture_output=True, text=True, check=True).stdout)
    print(f"dispatch: {side} {x['cell']} (round {r}) {b}")
PY
}
record() { $DRSI record --round "$2" --cell "$1" ${3:+--score $3} --fail-class "$4" ${5:+--error "$5"} --note "$6" ${FORCE:+--force} >/dev/null || exit 1
           echo "recorded $SIDE $1 (round $2): ${3:-none} $4 ${5:-}"; }
case "${1:-}" in
  next) next ;;
  fail) record "$2" "$3" 0 "$4" "$5" "nothing scorable"; next ;;
  done) C=$2; R=$3; RR=$(printf %02d "$R"); N=$WS/rounds/round$RR/nodes/$C; mkdir -p "$N"
        [ -f "$N/cpu-ki-$SIDE.lisp" ] || cp "$4/$REL/$SIDE/rounds/round$RR/nodes/$C/"{cpu-ki-$SIDE.lisp,proposal.md,score.json} "$N/" 2>/dev/null
        exec 9>"$TOP/.rescore-$SIDE.lock"; flock 9
        [ -f "$N/cpu-ki-$SIDE.lisp" ] || { record "$C" "$R" 0 runtime "no style file delivered" "-"; next; exit 0; }
        "$TOP/rescore.sh" "$SIDE" "$N" >/dev/null; rc=$?
        case $rc in
          0) S=$(python3 -c "import json,sys; print(json.loads(open(sys.argv[1]).read().strip().splitlines()[-1])['score'])" "$N/score.rescored.json")
             P=$(python3 -c "import json,sys; j=json.loads(open(sys.argv[1]).read().strip().splitlines()[-1]); print(f\"str {j['strength']} sig {j['signature']} normal {j.get('normal',{}).get('share')} x{j.get('normal',{}).get('factor')} themes \" + ' '.join(f\"{k} {v['rate']}\" for k,v in j['themes'].items()))" "$N/score.rescored.json")
             record "$C" "$R" "$S" ok "" "$P" ;;
          2) record "$C" "$R" 0 compile_other "native build failed" "rescore" ;;
          3) record "$C" "$R" 0 correctness "host tests failed" "rescore" ;;
          4) record "$C" "$R" 0 resource "eval timed out" "rescore" ;;
          *) record "$C" "$R" 0 runtime "rescore exited $rc" "rescore" ;;
        esac; next ;;
  *) sed -n 2,7p "$0"; exit 2 ;;
esac

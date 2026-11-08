#!/bin/bash
# step.sh — the coordinator's loop for the counter-strategy search (DUEL_AI_STRATEGY §8.7), one dream-rsi workspace a direction
# (workspaces.json). Data cells only: no worktrees, the shared native build.
#   step.sh <ws> next                     the policy's next batch; a brief for each cell not yet briefed
#   step.sh <ws> done <cell> <round>      rescore NODE_DIR/cand.lisp on the search seeds (600-699 a seat), record, next
#   step.sh <ws> fail <cell> <round> <class> <error>
# FORCE=1 re-records a cell (a coordinator's mistake only).
set -u
TOP=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$TOP/../../../.." && pwd)
WSN=$1; shift; WS=$TOP/$WSN
DREAM_RSI=${DREAM_RSI:-$(ls -d "$HOME"/.claude/skills/synced/*/dream-rsi 2>/dev/null | head -1)}
DRSI="python3 $DREAM_RSI/scripts/drsi.py -w $WS"
CH=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))[sys.argv[2]]['char'])" "$TOP/workspaces.json" "$WSN")
VS=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))[sys.argv[2]]['vs'])" "$TOP/workspaces.json" "$WSN")
next() {
  local W ST R
  W=$($DRSI next-batch) || exit 1
  ST=$(python3 -c "import json,sys; print(json.loads(sys.argv[1])['status'])" "$W")
  R=$(python3 -c "import json,sys; print(json.loads(sys.argv[1]).get('round', 0))" "$W")
  [ "$ST" != execute ] && { echo "$WSN round $R: $ST"; return; }
  python3 - "$W" "$TOP" "$WSN" "$R" <<'PY'
import json, os, subprocess, sys
w, top, ws, r = json.loads(sys.argv[1]), sys.argv[2], sys.argv[3], int(sys.argv[4])
for x in w['work']:
    d = os.path.join(top, ws, 'rounds', f'round{r:02d}', 'nodes'); os.makedirs(os.path.join(d, x['cell']), exist_ok=True)
    b = os.path.join(d, x['cell'] + '.brief.md')
    if os.path.exists(b): print(f"in flight: {ws} {x['cell']}"); continue
    open(b, 'w').write(subprocess.run([sys.executable, os.path.join(top, 'brief.py'), ws, x['cell'], str(r), json.dumps(x)],
                                      capture_output=True, text=True, check=True).stdout)
    print(f"dispatch: {ws} {x['cell']} (round {r}) {b}")
PY
}
record() { $DRSI record --round "$2" --cell "$1" ${3:+--score $3} --fail-class "$4" ${5:+--error "$5"} --note "$6" ${FORCE:+--force} >/dev/null || exit 1
           echo "recorded $WSN $1 (round $2): ${3:-none} $4 ${5:-}"; }
case "${1:-}" in
  next) next ;;
  fail) record "$2" "$3" "" "$4" "$5" "nothing scorable"; next ;;
  done) C=$2; R=$3; N=$WS/rounds/round$(printf %02d "$R")/nodes/$C
        [ -f "$N/cand.lisp" ] || { record "$C" "$R" "" runtime "no cand.lisp delivered" "-"; next; exit 0; }
        (cd "$REPO" && timeout 3600 python3 tools/strategy-switch.py --char "$CH" --vs "$VS" --cand "$N/cand.lisp" --seed0 600 --seeds 100 -j 5 $( [ "$R" -ge 2 ] && echo --max-own 0.6 ) --out "$N/score.json" >/dev/null 2>"$N/score.err"); rc=$?
        if [ $rc = 0 ]; then
          S=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['score'])" "$N/score.json")
          P=$(python3 -c "import json,sys; j=json.load(open(sys.argv[1])); print(f\"comp {j['comp_share']} inc {j['inc_share']} gain {j['gain']} z {j['z']} own {j['own_share']} capped {j.get('capped')}\")" "$N/score.json")
          record "$C" "$R" "$S" ok "" "$P"
        else record "$C" "$R" "" runtime "rescore exited $rc: $(tail -c 300 "$N/score.err" | tr '\n' ' ')" "rescore"; fi; next ;;
  *) sed -n 2,7p "$0"; exit 2 ;;
esac

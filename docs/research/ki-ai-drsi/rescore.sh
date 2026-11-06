#!/bin/bash
# rescore.sh — re-measure one delivered KI cell with the FROZEN evaluator (DUEL_MATCHUP_AI §6-§7): a worktree per side detached at
# the freeze commit; duel/lisp/cpu-ki-<side>.lisp = the cell's file, the OTHER side's file = its current champion
# (../<other>/champion/); host rules test, then tools/matchup-eval.py --side <side> --seeds 40. Writes NODE_DIR/score.rescored.json.
# Exit 0 ok, 2 build failed, 3 host tests failed, 4 timed out, 5 other.
# usage: rescore.sh <side ken|ichigo> <node_dir>
set -u
SIDE=$1; N=$(cd "$2" && pwd)
TOP=$(cd "$(dirname "$0")" && pwd)                # docs/research/ki-ai-drsi in the coordinator's checkout
REPO=$(cd "$TOP/../../.." && pwd)
OTHER=$([ "$SIDE" = ken ] && echo ichigo || echo ken)
ECL=${ECL_HOST:-/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl}
FREEZE=${FREEZE:-$(cat "$TOP/FREEZE")}
WT=$REPO/.claude/worktrees/rescore-ki-$SIDE
F=duel/lisp/cpu-ki-$SIDE.lisp; FO=duel/lisp/cpu-ki-$OTHER.lisp
[ -f "$N/cpu-ki-$SIDE.lisp" ] || { echo '{"error": "no style file"}' > "$N/score.rescored.json"; exit 5; }
if [ ! -d "$WT" ]; then git -C "$REPO" worktree add -q --detach "$WT" "$FREEZE" || exit 5; fi
git -C "$WT" checkout -q -f --detach "$FREEZE" && git -C "$WT" checkout -q "$FREEZE" -- duel tools tests docs || exit 5
cp "$N/cpu-ki-$SIDE.lisp" "$WT/$F" && cp "$TOP/$OTHER/champion/cpu-ki-$OTHER.lisp" "$WT/$FO" && touch "$WT/$F" "$WT/$FO"
cd "$WT" || exit 5
timeout 1800 "$ECL" --norc --load tests/duel-rules-test.lisp > "$N/rescore-host.log" 2>&1
tail -1 "$N/rescore-host.log" | grep -q 'ALL PASS' || { echo '{"error": "host tests failed"}' > "$N/score.rescored.json"; exit 3; }
timeout 5400 python3 tools/matchup-eval.py --side "$SIDE" --seeds 40 -j ${JOBS:-4} > "$N/score.rescored.json" 2> "$N/rescore-eval.log"
rc=$?
[ $rc -eq 124 ] && { echo '{"error": "eval timed out"}' > "$N/score.rescored.json"; exit 4; }
if [ $rc -ne 0 ]; then
  grep -q 'BUILD FAILED\|build failed' "$N/score.rescored.json" "$N/rescore-eval.log" && { echo '{"error": "native build failed"}' > "$N/score.rescored.json"; exit 2; }
  echo "{\"error\": \"eval exited $rc\"}" > "$N/score.rescored.json"; exit 5
fi
tail -1 "$N/score.rescored.json"

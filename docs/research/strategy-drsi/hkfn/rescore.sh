#!/bin/bash
# rescore.sh NODE_DIR — re-measure one delivered cell with the frozen evaluator (DUEL_AI_STRATEGY §8.19 round 5, step 7), in the coordinator's
# checkout: duel/lisp/cpu-hk-hisagi.lisp = the cell's file, host rules test, then eval.py on the search seeds (seed0 200); the baseline file goes
# back afterwards. Writes NODE_DIR/score.rescored.json. Exit 0 ok, 2 build failed, 3 host tests failed, 4 timed out, 5 other.
set -u
N=$(cd "$1" && pwd)
TOP=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$TOP/../../../.." && pwd)
ECL=${ECL_HOST:-/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl}
F=$REPO/duel/lisp/cpu-hk-hisagi.lisp
[ -f "$N/cpu-hk-hisagi.lisp" ] || { echo '{"error": "no style file"}' > "$N/score.rescored.json"; exit 5; }
restore() { cp "$TOP/baseline/cpu-hk-hisagi.lisp" "$F"; touch "$F"; }
trap restore EXIT
cp "$N/cpu-hk-hisagi.lisp" "$F" && touch "$F"
cd "$REPO" || exit 5
timeout 1800 "$ECL" --norc --load tests/duel-rules-test.lisp > "$N/rescore-host.log" 2>&1
tail -1 "$N/rescore-host.log" | grep -q 'ALL PASS' || { echo '{"error": "host tests failed"}' > "$N/score.rescored.json"; exit 3; }
timeout 3600 python3 "$TOP/eval.py" --seed0 200 -j ${JOBS:-20} > "$N/score.rescored.json" 2> "$N/rescore-eval.log"
rc=$?
[ $rc -eq 124 ] && { echo '{"error": "eval timed out"}' > "$N/score.rescored.json"; exit 4; }
if [ $rc -ne 0 ]; then
  grep -qi 'BUILD FAILED\|build failed' "$N/rescore-eval.log" && { echo '{"error": "native build failed"}' > "$N/score.rescored.json"; exit 2; }
  echo "{\"error\": \"eval exited $rc\"}" > "$N/score.rescored.json"; exit 5
fi
# the tripwire: the live HK lookup's own share against the live KH (inc_live) must equal the baseline's, else the cell registered its style
B=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['inc_live'])" "$TOP/baseline/score.json")
I=$(python3 -c "import json,sys; print(json.loads(open(sys.argv[1]).read().strip().splitlines()[-1])['inc_live'])" "$N/score.rescored.json")
[ "$B" = "$I" ] || { echo "{\"error\": \"the live lookup moved: inc_live $I vs $B\"}" >> "$N/score.rescored.json"; exit 3; }
tail -1 "$N/score.rescored.json"

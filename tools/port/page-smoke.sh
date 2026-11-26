#!/usr/bin/env bash
# Bevy port M0 Task 3: the duel-app page's contract (docs/bevy/BEVY_PORT.md §3 "Browser") under tools/run.mjs.
#   tools/port/build-web.sh duel-app dist/rs-blank [release|web-dev]; tools/port/page-smoke.sh [DIST]   (DIST: dist/rs-blank)
# run.mjs exits 0 on a lost device, a Bevy rendering error and the page's own `engine fatal:` (docs/bevy/M0_NOTES.md §1), so
# every row but ?nogpu also fails on any of them in its log. Exit 0 = every row passed; logs and stills stay in the tmp dir.
set -uo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd); dist=$(realpath -m "${1:-$root/dist/rs-blank}")
mkdir -p /tmp/claude-1000; tmp=$(mktemp -d /tmp/claude-1000/page-smoke.XXXXXX); fails=0
row() { if [ "$2" = 0 ]; then echo "PASS $1"; else echo "FAIL $1 (logs: $tmp)"; fails=$((fails + 1)); fi; }
run() { local n=$1; shift; timeout 600 node "$root/tools/run.mjs" "$dist" "$@" > "$tmp/$n.log" 2>&1; }   # bounded wait
clean() { ! grep -qE 'DeviceLost|Caught rendering error|engine fatal:' "$tmp/$1.log"; }

# 1. wall clock, 8 s: exit 0, one startup: line, at least 2 perf: lines
run wall --secs 8; e=$?
[ $e = 0 ] && clean wall && [ "$(grep -c '^startup:' "$tmp/wall.log")" = 1 ] && [ "$(grep -c '^perf:' "$tmp/wall.log")" -ge 2 ]
row "wall 8 s: exit 0, one startup:, >= 2 perf:" $?

# 2. Module._debug_cmd(42) at virtual 9.0 s reaches the FixedUpdate drain (--secs 10: frames must run after the step)
echo '[{"at":9.0,"eval":"Module._debug_cmd(42)"}]' > "$tmp/debug.json"
run debug --fixed-dt 16.666667 --timeout 180 --script "$tmp/debug.json" --secs 10; e=$?
[ $e = 0 ] && clean debug && grep -qx 'debug 42' "$tmp/debug.log"
row "fixed-dt script: debug 42" $?

# 3. two fixed-dt stills at virtual 10 s are byte-identical (and frames ran: a canvas that never presents is identical too)
run shot-a --fixed-dt 16.666667 --timeout 180 --secs 10 --shot "$tmp/a.png"; ea=$?
run shot-b --fixed-dt 16.666667 --timeout 180 --secs 10 --shot "$tmp/b.png"; eb=$?
[ $ea = 0 ] && [ $eb = 0 ] && clean shot-a && clean shot-b && grep -q '^startup:' "$tmp/shot-a.log" && grep -q '^startup:' "$tmp/shot-b.log" && cmp "$tmp/a.png" "$tmp/b.png"
row "fixed-dt stills a.png == b.png" $?

# 4. no WebGPU (?nogpu): the page's fatal path prints `engine fatal:`
RUN_QUERY='?nogpu' run nogpu --secs 4
grep -q 'engine fatal:' "$tmp/nogpu.log"
row "?nogpu: engine fatal:" $?

[ $fails = 0 ] && echo "page-smoke: all rows pass ($tmp)" || echo "page-smoke: $fails row(s) failed ($tmp)"
exit $((fails > 0))

#!/usr/bin/env bash
# Bevy port M0 Task 3 (+ M3a Task 9: a drawn fight): the duel-app page's contract (docs/bevy/BEVY_PORT.md §3 "Browser") under
# tools/run.mjs.
#   tools/port/build-web.sh duel-app dist/rs-m3a [release|web-dev]; tools/port/page-smoke.sh [DIST]   (DIST: dist/rs-m3a)
# run.mjs exits 0 on a lost device, a Bevy rendering error and the page's own `engine fatal:` (docs/bevy/M0_NOTES.md §1), so
# every row but ?nogpu and the hook's also fails on any of them in its log. Exit 0 = every row passed; logs and stills stay in the tmp dir.
set -uo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd); dist=$(realpath -m "${1:-$root/dist/rs-m3a}")
mkdir -p /tmp/claude-1000; tmp=$(mktemp -d /tmp/claude-1000/page-smoke.XXXXXX); fails=0
row() { if [ "$2" = 0 ]; then echo "PASS $1"; else echo "FAIL $1 (logs: $tmp)"; fails=$((fails + 1)); fi; }
run() { local n=$1; shift; timeout 600 node "$root/tools/run.mjs" "$dist" "$@" > "$tmp/$n.log" 2>&1; }   # bounded wait
clean() { ! grep -qE 'DeviceLost|Caught rendering error|engine fatal:' "$tmp/$1.log"; }

# 1. wall clock, 8 s: exit 0, one startup: line, at least 2 perf: lines
run wall --secs 8; e=$?
[ $e = 0 ] && clean wall && [ "$(grep -c '^startup:' "$tmp/wall.log")" = 1 ] && [ "$(grep -c '^perf:' "$tmp/wall.log")" -ge 2 ]
row "wall 8 s: exit 0, one startup:, >= 2 perf:" $?

# 2. Module._debug_cmd(2005) at virtual 1.0 s starts the CPU fight (the driver logs `debug 2005`, nothing stops it); by virtual
# 16.9 s at least 900 frames were drawn, submitted and finished on the GPU (Module._frames_done(): M0's device-loss check, which
# died at ~700-900 frames, M0_NOTES §1)
printf '[{"at":1.0,"eval":"Module._debug_cmd(2005)"},{"at":16.9,"eval":"Module._frames_done()"}]' > "$tmp/debug.json"
run debug --size 640x360 --fixed-dt 16.666667 --timeout 1200 --script "$tmp/debug.json" --secs 17; e=$?
done_n=$(grep '^\[eval\]' "$tmp/debug.log" | tail -1 | tr -dc 0-9)
echo "  frames done at virtual 16.9 s: ${done_n:-none}; $(grep '^perf:' "$tmp/debug.log" | tail -1)"
[ $e = 0 ] && clean debug && grep -qx 'debug 2005' "$tmp/debug.log" && ! grep -q '^duel: stopped' "$tmp/debug.log" && [ "${done_n:-0}" -ge 900 ]
row "fixed-dt 2005: debug 2005, >= 900 frames done" $?

# 3. two fixed-dt stills of the drawn fight at virtual 6 s are byte-identical (the settle waits on Bevy's frames: index.html). With
# `?stills`, the harness's boot: since ruling R32 the default page's first frame is the renderer's first ready one, whose virtual frame
# moves by a frame or so between runs under a loaded SwiftShader (the pipelines compile on the wall clock), so its frames before 2005
# (and the fx clock they carry) are not fixed; `?stills` runs the title frames since the clock started (game.rs `Game::refresh`)
printf '[{"at":1.0,"eval":"Module._debug_cmd(2005)"}]' > "$tmp/fight.json"
RUN_QUERY='?stills' run shot-a --size 640x360 --fixed-dt 16.666667 --timeout 600 --script "$tmp/fight.json" --secs 6 --shot "$tmp/a.png"; ea=$?
RUN_QUERY='?stills' run shot-b --size 640x360 --fixed-dt 16.666667 --timeout 600 --script "$tmp/fight.json" --secs 6 --shot "$tmp/b.png"; eb=$?
[ $ea = 0 ] && [ $eb = 0 ] && clean shot-a && clean shot-b && grep -q '^startup:' "$tmp/shot-a.log" && grep -q '^startup:' "$tmp/shot-b.log" && cmp "$tmp/a.png" "$tmp/b.png"
row "fixed-dt fight stills a.png == b.png" $?

# 4. no WebGPU (?nogpu): the page's fatal path prints `engine fatal:`
RUN_QUERY='?nogpu' run nogpu --secs 4
grep -q 'engine fatal:' "$tmp/nogpu.log"
row "?nogpu: engine fatal:" $?

# 5. review I4: the page's console hook shows the overlay (not a black or frozen canvas) on each line that means rendering stopped. The
# lines are logged from a script step through the page's own console (no test code in the page): each eval hides the overlay, logs the
# line and reads the overlay's display back
probe() { printf '{"at":%s,"eval":"(document.getElementById(\\"fatal\\").style.display = \\"none\\", console.%s(\\"%s\\"), document.getElementById(\\"fatal\\").style.display)"}' "$1" "$2" "$3"; }
{ printf '['; probe 3.0 error 'Caught rendering error: Validation Error (probe)'; printf ,
  probe 3.1 error 'Quitting the application due to Validation RenderError (probe)'; printf ,
  probe 3.2 log 'render: pipeline 3 failed: probe'; printf ,
  probe 3.3 error 'Caught DeviceLost error: Unknown probe'; printf ']'; } > "$tmp/hook.json"
run hook --size 640x360 --script "$tmp/hook.json" --secs 3.5
[ "$(grep -c '^\[eval\] "block"' "$tmp/hook.log")" = 4 ]
row "the overlay shows on a rendering error, Bevy's quit, a failed pipeline and a lost device" $?

[ $fails = 0 ] && echo "page-smoke: all rows pass ($tmp)" || echo "page-smoke: $fails row(s) failed ($tmp)"
exit $((fails > 0))

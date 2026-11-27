#!/usr/bin/env bash
# Bevy port M3a Task 10: the Rust page's console against the frozen page's (docs/bevy/M3A_NOTES.md §10).
#   tools/port/page-log-check.sh [RUST_DIST] [FROZEN_DIST] [SECS]   (dist/rs-m3a, build/oracle/frozen-dist, 60)
# 1. Both pages under `run.mjs --fixed-dt 16.666667 --size 640x360`, Module._debug_cmd(2005) at virtual 1.0 s, SECS virtual seconds:
#    the combat log (`[tick] ...`) and HASH-LOG's state hash lines (`duel hash t=...`) are the same, line for line, up to the last tick
#    both reached (the run's end can split a frame). The Rust page runs with `?stills&log` (the title boot the script expects, the
#    combat log and hash lines printed); the frozen page prints both after any debug command. At least 300 combat lines and 4 hash
#    lines must be compared.
# 2. Review Focus 5: the Rust page started as Kenpachi vs Hisagi (`?p2=hisagi`: M4's) stops with its reason, logged exactly once
#    (`duel: stopped: unported ...`), with no rendering error; the GPU still finishes frames after the stop (Module._frames_done()
#    rises between virtual 4 s and 6 s: the page draws on, it does not freeze).
# The frozen dist must be the frozen browser build (index.wasm sha256 e35032a7..., as tools/port/stills.py and oracle/gen.py check).
# Both runs are bounded (timeout); logs stay in the tmp dir. Exit 0 = both checks pass.
set -uo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
rust=$(realpath -m "${1:-$root/dist/rs-m3a}"); frozen=$(realpath -m "${2:-$root/build/oracle/frozen-dist}"); secs=${3:-60}
sha=$(sha256sum "$frozen/index.wasm" 2>/dev/null | cut -c1-8)
[ "$sha" = e35032a7 ] || { echo "page-log-check: $frozen/index.wasm is ${sha:-missing}, not the frozen build e35032a7" >&2; exit 2; }
mkdir -p /tmp/claude-1000; tmp=$(mktemp -d /tmp/claude-1000/page-log.XXXXXX); fails=0
row() { if [ "$2" = 0 ]; then echo "PASS $1"; else echo "FAIL $1 (logs: $tmp)"; fails=$((fails + 1)); fi; }
clean() { ! grep -qE 'DeviceLost|Caught rendering error|engine fatal:|panicked' "$tmp/$1.log"; }
run() { local n=$1 dist=$2; shift 2; timeout 1500 node "$root/tools/run.mjs" "$dist" --size 640x360 --fixed-dt 16.666667 --timeout 1400 "$@" > "$tmp/$n.log" 2>&1; }

# 1. the logs (both pages at once; each wait is on its own PID)
printf '[{"at":1.0,"eval":"Module._debug_cmd(2005)"}]' > "$tmp/fight.json"
run frozen "$frozen" --script "$tmp/fight.json" --secs "$secs" & pf=$!
RUN_QUERY='?stills&log' run rust "$rust" --script "$tmp/fight.json" --secs "$secs" & pr=$!
wait $pf; ef=$?; wait $pr; er=$?
lines() { grep -E '^\[ *[0-9]+\] |^duel hash t=' "$tmp/$1.log" > "$tmp/$1.lines"; }
lines frozen; lines rust
# the last tick both reached: a combat line's [tick], a hash line's t=
last() { sed -nE 's/^\[ *([0-9]+)\].*/\1/p; s/^duel hash t=([0-9]+).*/\1/p' "$tmp/$1.lines" | tail -1; }
lf=$(last frozen); lr=$(last rust); cut=$(( ${lf:-0} < ${lr:-0} ? ${lf:-0} : ${lr:-0} ))
upto() { awk -v c="$cut" '{ t = $0; if (t ~ /^duel hash t=/) { sub(/^duel hash t=/, "", t) } else { sub(/^\[ */, "", t) } ; split(t, a, /[^0-9]/); if (a[1] + 0 < c) print }' "$tmp/$1.lines" > "$tmp/$1.cut"; }
upto frozen; upto rust
nc=$(grep -c '^\[' "$tmp/frozen.cut"); nh=$(grep -c '^duel hash' "$tmp/frozen.cut")
echo "  frozen: $(wc -l < "$tmp/frozen.lines") lines to tick $lf; rust: $(wc -l < "$tmp/rust.lines") lines to tick $lr; compared below tick $cut: $nc combat, $nh hash"
diff "$tmp/frozen.cut" "$tmp/rust.cut" > "$tmp/diff.txt"; d=$?
[ $d != 0 ] && head -6 "$tmp/diff.txt" | sed 's/^/  /'
[ $ef = 0 ] && [ $er = 0 ] && clean rust && ! grep -q '^duel: stopped' "$tmp/rust.log" && [ $d = 0 ] && [ "$nc" -ge 300 ] && [ "$nh" -ge 4 ]
row "2005 for $secs s: combat log and hash lines equal to the frozen page's" $?

# 2. an unported pick stops the page once, drawn, not frozen
printf '[{"at":4.0,"eval":"Module._frames_done()"},{"at":6.0,"eval":"Module._frames_done()"}]' > "$tmp/stop.json"
RUN_QUERY='?p2=hisagi' run hisagi "$rust" --script "$tmp/stop.json" --secs 6.5 --shot "$tmp/hisagi.png"; e=$?
d4=$(grep '^\[eval\]' "$tmp/hisagi.log" | sed -n 1p | tr -dc 0-9); d6=$(grep '^\[eval\]' "$tmp/hisagi.log" | sed -n 2p | tr -dc 0-9)
echo "  $(grep '^duel: stopped' "$tmp/hisagi.log" | head -1); frames done at 4 s / 6 s: ${d4:-none} / ${d6:-none}"
[ $e = 0 ] && clean hisagi && [ "$(grep -c '^duel: stopped: unported ' "$tmp/hisagi.log")" = 1 ] && [ "${d6:-0}" -gt "${d4:-0}" ]
row "?p2=hisagi: stopped once with its reason, the page draws on" $?

[ $fails = 0 ] && echo "page-log-check: all rows pass ($tmp)" || echo "page-log-check: $fails row(s) failed ($tmp)"
exit $((fails > 0))

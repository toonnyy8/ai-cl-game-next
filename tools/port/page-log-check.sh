#!/usr/bin/env bash
# Bevy port M3a Task 10 (+ Task 11's row 3): the Rust page's console against the frozen page's (docs/bevy/M3A_NOTES.md §10, §11).
#   tools/port/page-log-check.sh [RUST_DIST] [FROZEN_DIST] [SECS] [KEY_SECS]   (dist/rs-m3a, build/oracle/frozen-dist, 60, 36)
# 1. Both pages under `run.mjs --fixed-dt 16.666667 --size 640x360`, Module._debug_cmd(2005) at virtual 1.0 s, SECS virtual seconds:
#    the combat log (`[tick] ...`) and HASH-LOG's state hash lines (`duel hash t=...`) are the same, line for line, up to the last tick
#    both reached (the run's end can split a frame). The Rust page runs with `?stills&log` (the title boot the script expects, the
#    combat log and hash lines printed); the frozen page prints both after any debug command. At least 300 combat lines and 4 hash
#    lines must be compared.
# 2. Review Focus 5: the Rust page started as Kenpachi vs Hisagi (`?p2=hisagi`: M4's) stops with its reason, logged exactly once
#    (`duel: stopped: unported ...`), with no rendering error; the GPU still finishes frames after the stop (Module._frames_done()
#    rises between virtual 4 s and 6 s: the page draws on, it does not freeze).
# 3. Ruling R28, the keyboard end to end: run.mjs's key steps play a human Kenpachi against a thinking NORMAL Ichigo on both pages for
#    KEY_SECS virtual seconds; the same lines as row 1 are equal, with at least 5 P1 key-driven lines and 2 hash lines among them (below).
# The frozen dist must be the frozen browser build (index.wasm sha256 e35032a7..., as tools/port/stills.py and oracle/gen.py check).
# Both runs are bounded (timeout); logs stay in the tmp dir. Exit 0 = every row passes.
set -uo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
rust=$(realpath -m "${1:-$root/dist/rs-m3a}"); frozen=$(realpath -m "${2:-$root/build/oracle/frozen-dist}"); secs=${3:-60}; ksecs=${4:-36}
sha=$(sha256sum "$frozen/index.wasm" 2>/dev/null | cut -c1-8)
[ "$sha" = e35032a7 ] || { echo "page-log-check: $frozen/index.wasm is ${sha:-missing}, not the frozen build e35032a7" >&2; exit 2; }
mkdir -p /tmp/claude-1000; tmp=$(mktemp -d /tmp/claude-1000/page-log.XXXXXX); fails=0
row() { if [ "$2" = 0 ]; then echo "PASS $1"; else echo "FAIL $1 (logs: $tmp)"; fails=$((fails + 1)); fi; }
clean() { ! grep -qE 'DeviceLost|Caught rendering error|engine fatal:|panicked' "$tmp/$1.log"; }
run() { local n=$1 dist=$2; shift 2; timeout 1500 node "$root/tools/run.mjs" "$dist" --size 640x360 --fixed-dt 16.666667 --timeout 1400 "$@" > "$tmp/$n.log" 2>&1; }

# both pages at once on one script (each wait is on its own PID), then their combat log and hash lines below the last tick both reached
pair() {   # NAME SCRIPT SECS: sets ef er d nc nh np
  local n=$1
  run "$n-frozen" "$frozen" --script "$2" --secs "$3" & local pf=$!
  RUN_QUERY='?stills&log' run "$n-rust" "$rust" --script "$2" --secs "$3" & local pr=$!
  wait $pf; ef=$?; wait $pr; er=$?
  local f lf lr cut
  for f in frozen rust; do grep -E '^\[ *[0-9]+\] |^duel hash t=' "$tmp/$n-$f.log" > "$tmp/$n-$f.lines"; done
  # the last tick both reached: a combat line's [tick], a hash line's t=
  last() { sed -nE 's/^\[ *([0-9]+)\].*/\1/p; s/^duel hash t=([0-9]+).*/\1/p' "$tmp/$1.lines" | tail -1; }
  lf=$(last "$n-frozen"); lr=$(last "$n-rust"); cut=$(( ${lf:-0} < ${lr:-0} ? ${lf:-0} : ${lr:-0} ))
  for f in frozen rust; do
    awk -v c="$cut" '{ t = $0; if (t ~ /^duel hash t=/) { sub(/^duel hash t=/, "", t) } else { sub(/^\[ */, "", t) } ; split(t, a, /[^0-9]/); if (a[1] + 0 < c) print }' "$tmp/$n-$f.lines" > "$tmp/$n-$f.cut"
  done
  nc=$(grep -c '^\[' "$tmp/$n-frozen.cut"); nh=$(grep -c '^duel hash' "$tmp/$n-frozen.cut"); np=$(grep -cE '^\[ *[0-9]+\] P1 (move|step|hoho|roll)' "$tmp/$n-frozen.cut")
  echo "  frozen: $(wc -l < "$tmp/$n-frozen.lines") lines to tick $lf; rust: $(wc -l < "$tmp/$n-rust.lines") lines to tick $lr; compared below tick $cut: $nc combat ($np P1 moves, steps, Hoho and rolls), $nh hash"
  diff "$tmp/$n-frozen.cut" "$tmp/$n-rust.cut" > "$tmp/$n-diff.txt"; d=$?
  [ $d != 0 ] && head -6 "$tmp/$n-diff.txt" | sed 's/^/  /'
  # a run that timed out fails the row (run.mjs exits 1 on its TIMEOUT), whatever its lines
  [ $ef = 0 ] && [ $er = 0 ] && clean "$n-rust" && ! grep -q '^duel: stopped' "$tmp/$n-rust.log"
}

# 1. the logs
printf '[{"at":1.0,"eval":"Module._debug_cmd(2005)"}]' > "$tmp/fight.json"
pair fight "$tmp/fight.json" "$secs"
[ $? = 0 ] && [ $d = 0 ] && [ "$nc" -ge 300 ] && [ "$nh" -ge 4 ]
row "2005 for $secs s: combat log and hash lines equal to the frozen page's" $?

# 2. an unported pick stops the page once, drawn, not frozen
printf '[{"at":4.0,"eval":"Module._frames_done()"},{"at":6.0,"eval":"Module._frames_done()"}]' > "$tmp/stop.json"
RUN_QUERY='?p2=hisagi' run hisagi "$rust" --script "$tmp/stop.json" --secs 6.5 --shot "$tmp/hisagi.png"; e=$?
d4=$(grep '^\[eval\]' "$tmp/hisagi.log" | sed -n 1p | tr -dc 0-9); d6=$(grep '^\[eval\]' "$tmp/hisagi.log" | sed -n 2p | tr -dc 0-9)
echo "  $(grep '^duel: stopped' "$tmp/hisagi.log" | head -1); frames done at 4 s / 6 s: ${d4:-none} / ${d6:-none}"
[ $e = 0 ] && clean hisagi && [ "$(grep -c '^duel: stopped: unported ' "$tmp/hisagi.log")" = 1 ] && [ "${d6:-0}" -gt "${d4:-0}" ]
row "?p2=hisagi: stopped once with its reason, the page draws on" $?

# 3. the keyboard end to end (ruling R28): a human Kenpachi (P1, run.mjs's key steps) against a thinking NORMAL Ichigo: 2501 (human
# Kenpachi vs an idle Ichigo, seed 1, cinematics skipped) then 2105 (the CPU's brain on). Four 8 s rounds of W held 3 s with two J, Shift+J
# (the SP), A held 2 s, Space. It proves the keyboard path's parity on the page; no full-sim rollout runs before tick 2099, so the held
# keys inside rollouts are proven natively (duel-app tests/game.rs rollout_reads_the_held_keys, vs-cpu-ichigo's live trace; DIVERGENCES
# §1), and a page run long enough for one waits for M3b's run.mjs cancelAnimationFrame fix (ruling R31). The same
# lines as row 1, below the last tick both reached, with at least 5 P1 moves, steps or wake-up rolls among them (a roll is a direction
# held as he gets up; Ichigo's strings eat most presses: 7 below the cut in the frozen run).
# Few steps on purpose: under run.mjs every step leaves the Bevy page one more update per frame (M3A_NOTES §11), so the run's wall time grows with
# steps x frames; 58 steps over 36 s take about 12 minutes.
python3 -c '
import json
s = [{"at": 1.0, "eval": "Module._debug_cmd(2501)"}, {"at": 1.2, "eval": "Module._debug_cmd(2105)"}]
k = lambda t, key, d: s.append({"at": round(t, 3), "key": key, "down": d})
def tap(t, key): k(t, key, True); k(t + 0.05, key, False)
for c in range(4):
    b = 2 + 8 * c
    k(b, "KeyW", True); tap(b + 1.0, "KeyJ"); tap(b + 1.6, "KeyJ"); k(b + 3.0, "KeyW", False)
    k(b + 3.2, "ShiftLeft", True); tap(b + 3.3, "KeyJ"); k(b + 3.6, "ShiftLeft", False)
    k(b + 4.0, "KeyA", True); k(b + 6.0, "KeyA", False); tap(b + 6.3, "Space")
print(json.dumps(sorted(s, key=lambda x: x["at"])))' > "$tmp/keys.json"
pair keys "$tmp/keys.json" "$ksecs"
# (thin margins, 7 key-driven lines and 3 hash lines against 5 and 2: the run is deterministic under --fixed-dt, so they only move
# when the script, KEY_SECS or the frozen build changes; then re-count from the frozen log)
[ $? = 0 ] && [ $d = 0 ] && [ "$np" -ge 5 ] && [ "$nh" -ge 2 ]
row "keyboard VS CPU for $ksecs s: combat log and hash lines equal to the frozen page's" $?

[ $fails = 0 ] && echo "page-log-check: all rows pass ($tmp)" || echo "page-log-check: $fails row(s) failed ($tmp)"
exit $((fails > 0))

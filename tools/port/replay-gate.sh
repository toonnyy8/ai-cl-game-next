#!/usr/bin/env bash
# The replay gate (docs/bevy/M1_NOTES.md §5, M2_NOTES.md §9) through `duel-tools replay`, 4 at a time. Prints "name status first-step" rows.
# Exit 0 when every trace is OK (with --allow-unported: OK or UNPORTED). ORACLE defaults to this checkout's build/oracle.
# Default: M1's 22 brainless gate traces (18 + the 4 scripted outcome traces, docs/bevy/M0_NOTES.md §4).
# --live: M2's 17 with the brains thinking: the 15 cvc traces `--live`, vs-cpu / vs-learn `--live --inject-side 0` (the human P1 injected).
# --wasm: every row through the wasm32-wasip1 build under node (tools/port/replay-wasm.mjs) instead of the native binary.
# --stubbed: the replay's stubbed mode (docs/bevy/M1_NOTES.md §3: guarded stubs for the unported kit :tick hooks, kit state and H masked);
# not the gate's verdict, a check of the code behind them; not with --live. A stubbed row reads OK-MASKED. --snap: a 40-step rollout every
# 40 battle ticks, restored (M1_NOTES §5; the outcome line stays first).
# A rollout cut short by an `unported!` path fails its row even with --allow-unported, since its value was wrong: a --snap rollout's
# (SNAP-UNP) and a CPU rollout's (MC-FULL-STEP's / STRAT-ROLL's: CPU-UNP). NAMES (env): other trace names instead of the set's.
set -u
cd "$(dirname "$0")/../.."
allow=0; live=0; wasm=0; stub=0; extra=()
for a in "$@"; do
  case "$a" in
    --allow-unported) allow=1 ;;
    --stubbed) stub=1; extra+=(--stub HS-TICK,YAMA-TICK --mask 'hss-,yss-') ;;
    --snap) extra+=(--snap 40) ;;
    --live) live=1 ;;
    --wasm) wasm=1 ;;
    *) echo "usage: $0 [--live] [--wasm] [--snap] [--stubbed] [--allow-unported]"; exit 2 ;;
  esac
done
if [ $live = 1 ] && [ $stub = 1 ]; then echo "$0: --stubbed is not for a live run (duel-tools refuses --live with --stub / --mask)"; exit 2; fi
ORACLE=${ORACLE:-$PWD/build/oracle}
if [ $wasm = 1 ]; then
  (cd rs && cargo build -q --release -p duel-tools --target wasm32-wasip1) || exit 1
  cmd=(node tools/port/replay-wasm.mjs)
else
  (cd rs && cargo build -q --release -p duel-tools) || exit 1
  cmd=("$PWD/rs/target/release/duel-tools" replay)
fi
cvc="cvc-kk-s1 cvc-kk-s2 cvc-kk-s3 cvc-ki-s1 cvc-ki-s2 cvc-ki-s3 cvc-ik-s1 cvc-ik-s2 cvc-ik-s3 cvc-ii-s1 cvc-ii-s2 cvc-ii-s3
     cvctag-ii cvctag-ik cvctag-kk"
if [ $live = 1 ]; then
  names=${NAMES:-"$cvc vs-cpu vs-learn"}
else
  names=${NAMES:-"$cvc trial-ki-ai-kenpachi trial-ki-ai-ichigo trial-sp-xch-r3
         scr-counter-stance-break scr-bursts-chain-cut scr-blocked-guard-crush-back scr-draw"}
fi
out=$(mktemp -d)
pids=()
for n in $names; do
  row=()
  if [ $live = 1 ]; then
    row=(--live)
    case "$n" in vs-*) row+=(--inject-side 0) ;; esac
  fi
  timeout 3600 "${cmd[@]}" "$ORACLE/traces/$n.trace" "${row[@]}" "${extra[@]}" > "$out/$n" 2>&1 &
  pids+=($!)
  if [ ${#pids[@]} -ge 4 ]; then wait "${pids[0]}"; pids=("${pids[@]:1}"); fi
done
for p in "${pids[@]}"; do wait "$p"; done
ok=1
for n in $names; do
  line=$(head -1 "$out/$n")
  case "$line" in
    "replay OK (stubbed"*) st=OK-MASKED ;;
    "replay OK"*) st=OK ;;
    "replay UNPORTED"*"in a --snap rollout"*) st=SNAP-UNP; ok=0 ;;
    "replay UNPORTED"*"in a rollout from tick"*) st=CPU-UNP; ok=0 ;;
    "replay UNPORTED"*) st=UNPORTED; [ $allow = 1 ] || ok=0 ;;
    "replay DIVERGED"*) st=DIVERGED; ok=0 ;;
    *) st=ERROR; ok=0 ;;
  esac
  step=$(grep -o 'step [0-9]*' <<<"$line" | head -1)
  printf '%-28s %-9s %s   %s\n' "$n" "$st" "${step:-"-"}" "$line"
done
rm -rf "$out"
[ $ok = 1 ]

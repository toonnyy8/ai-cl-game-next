#!/usr/bin/env bash
# The M1 replay gate: the 22 gate traces (18 + the 4 scripted outcome traces, docs/bevy/M0_NOTES.md §4) through `duel-tools replay`, 4 at a time. Prints "name status first-step" rows.
# Exit 0 when every trace is OK (with --allow-unported: OK or UNPORTED). ORACLE defaults to this checkout's build/oracle.
# --stubbed: the replay's stubbed mode (docs/bevy/M1_NOTES.md §3: guarded stubs for the unported kit :tick hooks, kit
# state and H masked); not the gate's verdict, a check of the code behind them. NAMES (env): other trace names instead of the 22.
set -u
cd "$(dirname "$0")/../.."
allow=0; extra=()
for a in "$@"; do
  case "$a" in
    --allow-unported) allow=1 ;;
    --stubbed) extra=(--stub HS-TICK,YAMA-TICK --mask 'hss-,yss-') ;;
    *) echo "usage: $0 [--allow-unported] [--stubbed]"; exit 2 ;;
  esac
done
ORACLE=${ORACLE:-$PWD/build/oracle}
(cd rs && cargo build -q --release -p duel-tools) || exit 1
bin=$PWD/rs/target/release/duel-tools
out=$(mktemp -d)
names=${NAMES:-"cvc-kk-s1 cvc-kk-s2 cvc-kk-s3 cvc-ki-s1 cvc-ki-s2 cvc-ki-s3 cvc-ik-s1 cvc-ik-s2 cvc-ik-s3 cvc-ii-s1 cvc-ii-s2 cvc-ii-s3
       cvctag-ii cvctag-ik cvctag-kk trial-ki-ai-kenpachi trial-ki-ai-ichigo trial-sp-xch-r3
       scr-counter-stance-break scr-bursts-chain-cut scr-blocked-guard-crush-back scr-draw"}
pids=()
for n in $names; do
  timeout 3600 "$bin" replay "$ORACLE/traces/$n.trace" "${extra[@]}" > "$out/$n" 2>&1 &
  pids+=($!)
  if [ ${#pids[@]} -ge 4 ]; then wait "${pids[0]}"; pids=("${pids[@]:1}"); fi
done
for p in "${pids[@]}"; do wait "$p"; done
ok=1
for n in $names; do
  line=$(head -1 "$out/$n")
  case "$line" in
    "replay OK"*) st=OK ;;
    "replay UNPORTED"*) st=UNPORTED; [ $allow = 1 ] || ok=0 ;;
    "replay DIVERGED"*) st=DIVERGED; ok=0 ;;
    *) st=ERROR; ok=0 ;;
  esac
  step=$(grep -o 'step [0-9]*' <<<"$line" | head -1)
  printf '%-28s %-9s %s   %s\n' "$n" "$st" "${step:-"-"}" "$line"
done
rm -rf "$out"
[ $ok = 1 ]

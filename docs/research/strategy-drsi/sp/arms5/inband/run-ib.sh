#!/bin/sh
# run-ib.sh — every in-band test of inband.md §3 (candidate T0s), appended to inband/ib.jsonl. Run from arms5/: sh inband/run-ib.sh [-j N]
J=${1:-14}
export SP_BUILD=f0e2bb129de1
while read row arm; do
  python3 inband.py ib --row "$row" --arm "$arm" -j "$J" || exit 1
done <<EOF
ki-kenpachi k5-poke
ki-kenpachi k5-wake
ki-kenpachi k5-red
ki-kenpachi k5-climb
ki-kenpachi k5-getsuga
ki-ichigo a5-i-answer
ki-ichigo a4-i-brawl
ki-ichigo a5-i-economy
ki-ichigo a5-i-punish
ki-ichigo a5-i-kessa-lunge
ki-ichigo a4-i-keep
ki-ichigo@a4-i-kessa2 a4-i-kessa2
kh-kenpachi k5-poke
kh-kenpachi k5-wake
kh-kenpachi k5-red
kh-kenpachi k5-climb
kh-kenpachi k5-hug
kh-kenpachi@a4-k-bait a4-k-bait
kh-hisagi h5-cancel
kh-hisagi h5-tip
kh-hisagi h5-bind
kh-hisagi h5-wake
kh-hisagi h5-k1
kh-hisagi@h4-wake h4-wake
ih-ichigo a5-i-answer
ih-ichigo a4-i-brawl
ih-ichigo a5-i-economy
ih-ichigo a5-i-punish
ih-ichigo a5-i-kessa-lunge
ih-ichigo a5-i-inside
ih-ichigo@a4-i-kessa2 a4-i-kessa2
ih-hisagi h5-cancel
ih-hisagi h5-tip
ih-hisagi h5-bind
ih-hisagi h5-wake
ih-hisagi h5-i1
ih-hisagi h5-ihx
ih-hisagi@h4-wake h4-wake
kk-kenpachi k5-poke
kk-kenpachi k5-wake
kk-kenpachi k5-red
kk-kenpachi k5-climb
ii-ichigo a5-i-answer
ii-ichigo a4-i-brawl
ii-ichigo a5-i-economy
ii-ichigo a5-i-punish
ii-ichigo a5-i-kessa-lunge
ii-ichigo@a4-i-kessa2 a4-i-kessa2
hh-hisagi h5-cancel
hh-hisagi h5-tip
hh-hisagi h5-bind
hh-hisagi h5-wake
hh-hisagi@h4-wake h4-wake
EOF

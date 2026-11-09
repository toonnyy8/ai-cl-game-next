#!/bin/sh
# frozen.sh TAG — each live table against the frozen style CPU of its opponent, a stand-in for a human (DUEL_AI_STRATEGY §8.19 round 5,
# reported, not gating), from the switch directory: HI and KI against Ichigo's frozen :ki-ichigo, HK and IK against Kenpachi's frozen :ki-ken,
# seeds 601-700, both seats -> ev/TAG-<p>.json. (No style CPU exists for Hisagi, so HH, KH, IH and the mirrors have none.)
set -e
for p in hi hk ki ik; do
  P=$p; . ./lineup.sh
  OPP=$FROZEN
  python3 sw.py measure --me $ME --vs $VS --opp $OPP --arms $ARMS --table $CUR --tag ev/$1-$p --seeds 601-700 -j ${J:-12} > /dev/null
  python3 report.py ev/$1-$p.json | cut -c1-120
done

#!/bin/sh
# round1.sh — Kenpachi's round 1 (DUEL_AI_STRATEGY §8.19 round 4), from the switch directory: 4 salts x seeds 1-599 x both seats with the
# start table (period 30) + runs, then fits at gamma 0.966 / 0.98 (logs/k<p>-r1/, gitignored; tables kenpachi/<p>-r1-g*.lisp).
set -e
for p in ki:ichigo:../../counter/frozen/ki-ichigo.lisp kh:hisagi:arms/ship-qh-ken.lisp kk:kenpachi:../pairs/kk/kk-fit.lisp; do
  k=${p%%:*}; r=${p#*:}; vs=${r%%:*}; opp=${r#*:}
  C="--me kenpachi --vs $vs --opp $opp --arms kenpachi/$k.arms"
  for s in 1 2 3 4; do python3 sw.py log $C --table kenpachi/$k-s0-p30.lisp --tag k$k-r1 --salt $s -j 20 > /dev/null; done
  for g in 0.966 0.98; do python3 sw.py fit $C --tag k$k-r1 --gamma $g --out kenpachi/$k-r1-g$g.lisp > logs/k$k-r1/fit-g$g.out 2>&1; done
done

#!/bin/sh
# round.sh R TABLE_IK TABLE_IH TABLE_II — one round for Ichigo's three tables (DUEL_AI_STRATEGY §8.19 round 5), from the switch directory:
# 4 salts x seeds 1-599 x both seats with each behaviour table + runs against the live opponent (lineup.sh), then fits at gamma 0.966 / 0.98
# -> ichigo/<p>-r<R>-g<gamma>.lisp (logs/i<p>-r<R>/, gitignored).
set -e
R=$1; shift
for p in ik ih ii; do
  t=$1; shift
  sh run.sh $p log i$p-r$R $t
  for g in 0.966 0.98; do sh run.sh $p fit i$p-r$R ichigo/$p-r$R-g$g.lisp $g; done
done

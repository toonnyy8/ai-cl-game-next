#!/bin/sh
# fits.sh P TAG R — the gamma 0.966 / 0.98 fits of one Ichigo pairing's logs (DUEL_AI_STRATEGY §8.19 round 5), from the switch directory
# -> ichigo/P-rR-g*.lisp.
set -e
for g in 0.966 0.98; do sh run.sh $1 fit $2 ichigo/$1-r$3-g$g.lisp $g; done

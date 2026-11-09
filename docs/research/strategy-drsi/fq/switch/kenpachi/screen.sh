#!/bin/sh
# screen.sh — Kenpachi's candidate arms played whole (DUEL_AI_STRATEGY §8.19 round 4), from this directory: HARD, seeds 1-100, both seats,
# against KI Ichigo's frozen :ki-ichigo, KH Hisagi's live lookup table :qh-ken, KK the shipped mirror table :q1-ken-ken on the other seat.
set -e
S=../arms/screen.py
A="arms/k0-none.lisp arms/k1-ken.lisp arms/k2-press.lisp arms/k3-kite.lisp arms/k4-zone.lisp arms/k5-iki.lisp"
python3 $S --char kenpachi --vs ichigo --vs-strat ../../../counter/frozen/ki-ichigo.lisp --tag -ki --seeds 100 $A
python3 $S --char kenpachi --vs hisagi --vs-strat ../arms/ship-qh-ken.lisp --tag -kh --seeds 100 $A
python3 $S --char kenpachi --vs kenpachi --vs-strat ../../pairs/kk/kk-fit.lisp --tag -kk --seeds 100 $A

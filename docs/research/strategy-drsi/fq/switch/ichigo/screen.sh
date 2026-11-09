#!/bin/sh
# screen.sh — Ichigo's candidate arms played whole (DUEL_AI_STRATEGY §8.19 round 5), from this directory: HARD, seeds 1-100, both seats,
# against each opponent's live lookup table: IK Kenpachi's :qks-ichigo, IH Hisagi's :qhs3-ichigo, II the shipped :q1-ichigo-ichigo.
set -e
S=../arms/screen.py
A="arms/i0-none.lisp arms/i1-iki.lisp arms/i2-press.lisp arms/i3-kite.lisp arms/i4-zone.lisp arms/i5-kenki.lisp"
python3 $S --char ichigo --vs kenpachi --vs-strat ../kenpachi/qks-ichigo.lisp --tag -ik --seeds 100 $A
python3 $S --char ichigo --vs hisagi --vs-strat ../hi/qhs3-ichigo.lisp --tag -ih --seeds 100 $A
python3 $S --char ichigo --vs ichigo --vs-strat ../../pairs/ii/ii-fit.lisp --tag -ii --seeds 100 $A

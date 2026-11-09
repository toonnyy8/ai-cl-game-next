#!/bin/sh
# hold.sh — round 4's delayed awakening (DUEL_AI_STRATEGY §8.19 round 4) on the selection block, from this directory: the live :qhs3-ichigo,
# press + the Shikai's DRIVE switch whole, and press + the switch + :hold-awaken H (0.3 / 0.6) whole and inside the live table.
set -e
python3 sw.py measure --arms arms/hi-d.arms --table hi/qhs3-ichigo.lisp --tag ev/hi4-sel2-qhs3 --seeds 801-1000 > /dev/null
python3 sw.py measure --arms arms/hi-ds.arms --table arms/a9-pressds.lisp --tag ev/hi4-sel2-whole-pressds --seeds 801-1000 > /dev/null
for h in 0.3 0.6; do
  python3 sw.py pin --arms arms/hi-h$h.arms --table hi/qhs3-ichigo.lisp --bonus 0 --out hi/hi4-h$h.lisp
  python3 sw.py measure --arms arms/hi-h$h.arms --table hi/hi4-h$h.lisp --tag ev/hi4-sel2-h$h --seeds 801-1000 > /dev/null
  python3 sw.py measure --arms arms/hi-h$h.arms --table arms/a10-presshold$h.lisp --tag ev/hi4-sel2-whole-h$h --seeds 801-1000 > /dev/null
done
python3 report.py ev/hi4-sel2-qhs3.json ev/hi4-sel2-h0.3.json ev/hi4-sel2-h0.6.json ev/hi4-sel2-whole-h0.3.json ev/hi4-sel2-whole-h0.6.json ev/hi4-sel2-whole-pressds.json

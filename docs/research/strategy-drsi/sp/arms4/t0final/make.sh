#!/bin/sh
# make.sh VER — B4's nine T0 tables of map version VER (maps.py) -> t0final/VER/t0-<pair>-<side>.lisp (+ .arms). Run from anywhere.
# The shipped tables: `make.sh final`, then t0final/final/* copied to t0final/ (and t0final/final removed). v1 / v1c keep only the KH Hisagi
# table that differs from the final set (KH-a / h4-all with range on G1); v1b's KH Hisagi is the final one.
# band.py t0 --or, :rb-sp2 :xfeats t :keep-state t :margin 0.02 :period 30 :gamma 0.966 :scale 0.1 (band.py's writer), :with the pairing's
# exchange unit (mirrors none); Kenpachi q 0.075 (rush's 3-group --or floor, kenpachi.md), the others 0.06.
set -e
cd "$(dirname "$0")/.."
V=$1
mkdir -p t0final/$V
python3 t0final/maps.py $V > /dev/null
while read t me vs q w; do
  if [ "$w" = none ]; then W=""; else W="--with x-units/$w.lisp"; fi
  python3 proof.py t0 --me $me --vs $vs --map t0final/$V-$t.json --out t0final/$V/t0-$t.lisp --or --q $q $W
done <<EOF
ki-ichigo ichigo kenpachi 0.06 d-x-ki-i
ih-ichigo ichigo hisagi 0.06 d-x-ih-i
ii-ichigo ichigo ichigo 0.06 none
ki-kenpachi kenpachi ichigo 0.075 d-x-ki-k
kk-kenpachi kenpachi kenpachi 0.075 none
kh-kenpachi kenpachi hisagi 0.075 d-x-kh-k
kh-hisagi hisagi kenpachi 0.06 d-x-kh-h
ih-hisagi hisagi ichigo 0.06 d-x-ih-h
hh-hisagi hisagi hisagi 0.06 none
EOF

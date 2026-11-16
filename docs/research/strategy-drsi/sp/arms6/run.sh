#!/bin/bash
# run.sh CELLS NAME... : arms6/ih.md's candidate loop: write each candidate (cands.py), play it as Ichigo's table at every tier (ih.py),
# print its rows. CELLS e.g. hh:IH,nn:IH.
cd "$(dirname "$0")" || exit 1
cells=$1; shift
python3 cands.py "$@" > /dev/null || exit 1
for n in "$@"; do
  python3 ih.py --cells "$cells" -j ${J:-14} --ichigo ih/c/$n.lisp --json ih/r-$n.json > ih/r-$n.txt 2>&1 || echo "FAIL $n"
  echo "== $n"; grep -E '^(hh|nn|hn|ne|em) ' ih/r-$n.txt
done

#!/bin/bash
# measure.sh TAG: arms5/clash2.md's cells through diag/probe.py on the current build/simgate/duel.fas (seeds 501-600, both seats,
# 200 a cell; the shipped lookup), one run per cell so each keeps its own per-match accounting.
# Output: clash2/TAG/<hi>-<lo>-<cell>.{txt,json} and build-hash.txt.
cd "$(dirname "$0")/../../../../../.." || exit 1
P=docs/research/strategy-drsi/sp
O=$P/arms5/clash2/$1
mkdir -p "$O"
python3 -c "import sys; sys.path.insert(0, 'tools'); import simlib; simlib.build(); print(simlib.build_hash())" > "$O/build-hash.txt" || exit 1
run() {   # hi lo cell
  python3 $P/diag/probe.py --hi "$1" --lo "$2" --pairs "$3" --seed0 500 --seeds 100 -j 4 --json "$O/$1-$2-$3.json" > "$O/$1-$2-$3.txt"
}
run hard normal HK & run hard normal KH & run hard normal HI & run hard normal IH & run normal easy HK & run normal easy KH &
wait
run easy masher HK & run easy masher KH & run hard hard KH &
wait

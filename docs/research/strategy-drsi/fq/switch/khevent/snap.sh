#!/bin/sh
# khevent/snap.sh — the snapshot pollution test with the event layer on (DUEL_AI_STRATEGY §8.19 round 5, step 6), from the repo root: Kenpachi
# (the live :qks4-hisagi, its layer and its brain slots) against Hisagi, HARD, seeds 601-604, played STRAIGHT and with a rollout every ~40
# ticks (tools/simgate/snaptest.lisp POLLUTE: snapshot, reseeded play, restore); the two outputs must be equal but for the snaptest lines, the
# per-frame stats (consing, heap) and the `duel mcfull` lines -> prints "snap identical N lines" or the first differences.
set -e
E=${ECL_HOST:-/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl}
O=${TMPDIR:-/tmp}/khevent-snap.$$
C="30600 31104 81000 81022 81030 81040 200170"
LD_PRELOAD=build/simgate/muslm.so $E --norc --load tools/simgate/snaptest.lisp -- build/simgate/duel.fas straight $C 2>&1 | grep -v '^snaptest\|duel mcfull\|^stats: \|^brush: ' > $O.a
LD_PRELOAD=build/simgate/muslm.so $E --norc --load tools/simgate/snaptest.lisp -- build/simgate/duel.fas pollute $C > $O.b 2>&1
grep 'snaptest' $O.b || true
grep -v '^snaptest\|duel mcfull\|^stats: \|^brush: ' $O.b > $O.c
if cmp -s $O.a $O.c; then echo "snap identical $(wc -l < $O.a) lines, $(grep -c 'duel hash' $O.a) hash lines, $(grep -c 'gate row' $O.a) rows"; else diff $O.a $O.c | head -10; fi
rm -f $O.a $O.b $O.c

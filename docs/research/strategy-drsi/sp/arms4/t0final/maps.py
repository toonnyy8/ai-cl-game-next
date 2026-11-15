#!/usr/bin/env python3
"""maps.py — B4's job maps (PLAN4 §4 T0) for the nine final tables, from the ADMITTED arms only (arms4/*.md): writes <ver>-<pair>-<side>.json
here; tables by `make.sh`. v0 = the B3 maps as they stood; later versions change only the jobs named in b4.md."""
import json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
I = ["ichigo.lisp#a4-i-all", "ichigo.lisp#a4-i-brawl", "ichigo.lisp#a4-i-keep", "ichigo.lisp#a4-i-kessa2"]
I_KESSA_V0 = [[0, ["(:awst :k2)"]], [1, ["(:form :yes)"]]]
K = ["kenpachi.lisp#a4-k-all", "kenpachi.lisp#a4-k-spend", "kenpachi.lisp#a4-k-climb"]
K_SPEND = [[3, ["(:mcell :yes)"]], [3, ["(:mcell :p2up)"]], [4, ["(:mburst :yes)"]]]
K_CLIMB_V0 = [[0, ["(:lead :behind)", "(:awst :no)"]], [0, ["(:lead :behind)", "(:awst :yes)"]], [9, ["(:swopen :no)"]]]
H = ["cells-h/final/h4-all.lisp#h4-all", "cells-h/final/h4-range.lisp#h4-range", "cells-h/final/h4-wake.lisp#h4-wake"]
H_RANGE_G1 = [[1, ["(:form :yes)", "(:dm :m-mid)"]], [1, ["(:form :yes)", "(:dm :m-far)"]]]
H_RANGE_V0 = H_RANGE_G1 + [[9, ["(:swopen :yes)"]]]
DOWN = [[2, ["(:ost :down)"]]]
HOHO6 = [[2, ["(:ost :free)", "(:dm :m-mid)"]], [2, ["(:ost :free)", "(:dm :m-far)"]]]
IHX = [[7, ["(:mr :r-high)", "(:or :r-low)"]]]
BRAWL, KEEP = [[2, ["(:ost :free)"]]], [[8, ["(:lead :ahead)"]]]


def maps(kessa, climb, range_kh, range_ih, range_hh, kh_arm0=None):
    hk = ([kh_arm0] + H[1:]) if kh_arm0 else H
    return {
        'ki-ichigo': (I, [None, BRAWL, KEEP, kessa], 'KI Ichigo (t0/ki-ichigo.json v3)'),
        'ih-ichigo': (I, [None, BRAWL, KEEP, kessa], 'IH Ichigo (KI v3 map)'),
        'ii-ichigo': (I, [None, BRAWL, KEEP, kessa], 'II mirror (KI v3 map, no :with)'),
        'ki-kenpachi': (K, [None, K_SPEND, climb], 'KI Kenpachi (t0/ki-kenpachi.json)'),
        'kk-kenpachi': (K, [None, K_SPEND, climb], 'KK mirror (no :with)'),
        'kh-kenpachi': (K + ["kenpachi.lisp#a4-k-bait"], [None, K_SPEND, climb, DOWN], 'KH Kenpachi (bait G2 down)'),
        'kh-hisagi': (hk + ["cells-h/final/h4-hoho6.lisp#h4-hoho6"], [None, range_kh, DOWN, HOHO6], 'KH Hisagi'),
        'ih-hisagi': (H + ["cells-h/final/h4-ihx.lisp#h4-ihx"], [None, range_ih, DOWN, IHX], 'IH Hisagi'),
        'hh-hisagi': (H, [None, range_hh, DOWN], 'HH mirror (no :with)'),
    }


# v1 (pre-registered in ../../b4.md §1 from the offline scores, before any v1 bar run): kessa2 on awakened x distance, keep on ahead x not
# awakened, range on G1 only everywhere; KH Hisagi's arm 0 the 11-15 KH arm x-kh-h-r2-b3a1 (KH-a; KH-b = the same with range's v0 job).
I_KESSA_V1 = [[1, ["(:form :yes)", "(:dm :m-mid)"]], [1, ["(:form :yes)", "(:dm :m-far)"]]]
I_KEEP_V1 = [[0, ["(:lead :ahead)", "(:awst :no)"]], [0, ["(:lead :ahead)", "(:awst :yes)"]]]
KH_ARM0 = "t0final/kh-arm0.lisp#x-kh-h-r2-b3a1"


def maps_v1(range_kh, kh_arm0):
    m = maps(I_KESSA_V1, K_CLIMB_V0, range_kh, H_RANGE_G1, H_RANGE_G1, kh_arm0)
    for t in ('ki-ichigo', 'ih-ichigo', 'ii-ichigo'):
        arms, jobs, note = m[t]
        m[t] = (arms, [None, BRAWL, I_KEEP_V1, I_KESSA_V1], note + ', v1 keep / kessa2 jobs')
    return m


VERSIONS = {
    'v0': maps(I_KESSA_V0, K_CLIMB_V0, H_RANGE_V0, H_RANGE_G1, H_RANGE_V0),
    'v1': maps_v1(H_RANGE_G1, KH_ARM0),          # KH-a
    'v1b': maps_v1(H_RANGE_V0, KH_ARM0),         # KH-b (only kh-hisagi differs from v1)
    'v1c': maps_v1(H_RANGE_G1, None),            # KH Hisagi with arm 0 h4-all, range G1 only (= cells-h's KH v2)
}
# The pick (b4.md §1's rule): v1 everywhere, KH Hisagi = KH-b (KH-a failed bar A's three arms and bar D). make.sh final, then the nine
# t0final/final/t0-*.lisp are copied to t0final/t0-*.lisp (the names the game's entries take).
VERSIONS['final'] = dict(VERSIONS['v1'], **{'kh-hisagi': VERSIONS['v1b']['kh-hisagi']})

if __name__ == '__main__':
    ver = sys.argv[1]
    for k, (arms, jobs, note) in VERSIONS[ver].items():
        json.dump(dict(note=f'B4 {ver} (2026-11-15): {note}', arms=arms, jobs=jobs), open(os.path.join(HERE, f'{ver}-{k}.json'), 'w'), indent=1)
        print(f'{ver}-{k}.json')

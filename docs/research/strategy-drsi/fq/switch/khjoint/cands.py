#!/usr/bin/env python3
"""cands.py — round 5 step 4's joint KH / HK arm search (DUEL_AI_STRATEGY §8.19; the user, 2026-11-09: 「請再找策略的時候用全局性的觀點同時思考兩邊的策略，
並將具有「高內聚，低耦合」特性的策略保留下來」), from the switch directory: writes each side's candidate arms, played whole, into khjoint/k/ and khjoint/h/.
Every candidate is one style unit plus data units (§10): the tables' current arms, the other KI style on each side, each with the DRIVE switch
(:dswitch 1.0, the only data key the KI styles read besides :range, §8.8), Hisagi's ranged-mode style. One plist a file."""
import os
D = os.path.join(os.path.dirname(os.path.abspath(__file__)))
BRAWL = (':range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :b-walk-in 0.06 :b-j1 0.05 :b-step-in 0.03 :b-wait -0.05 :b-walk-out -0.08 '
         ':b-step-out -0.05', '((((:ost :down)) (:b-walk-in 0.14 :b-j1 0.12 :b-wait -0.12)) (((:dj :in)) (:b-j1 0.12 :b-step-out -0.1)) '
         '(((:dj :afar)) (:b-walk-in 0.12 :b-step-in 0.08)) (((:ost :active) (:dj :in)) (:b-hoho -0.05)))')
KITE = (':range 3.2 :ns 1.0 :hoho 1.0 :kikon 0.4 :cont 1.3 :awaken 4.0 :p 1.0 :b-walk-out 0.05 :b-wait 0.04 :b-j1 -0.3 :b-walk-in -0.08 :b-step-in -0.05',
        '((((:dn :reach)) (:b-sp 0.2 :b-walk-in -0.05)) (((:dn :out)) (:b-sp 0.15)) (((:dn :afar) (:wave :yes)) (:b-sp 0.22 :b-walk-in -0.06)) '
        '(((:do :in)) (:b-walk-out 0.2 :b-step-out 0.18 :b-j1 -0.1)) (((:do :reach)) (:b-walk-out 0.1 :b-step-out 0.08)))')
ZONE = (':range 1.5 :ns 0.9 :hoho 1.1 :kikon 0.4 :cont 0.8 :p 1.0 :b-walk-out 0.02 :b-wait 0.02 :b-j1 -0.08 :b-walk-in -0.04',
        '((((:dn :reach)) (:b-sp 0.15 :b-walk-in -0.05)) (((:dn :out)) (:b-sp 0.1 :b-walk-in 0.04)) (((:dn :afar) (:wave :yes)) (:b-sp 0.18 :b-walk-in -0.04)) '
        '(((:do :in)) (:b-walk-out 0.12 :b-step-out 0.1 :b-j1 -0.05)) (((:dj :in)) (:b-step-out 0.08 :b-j1 0.05)))')
MERGED = ':fn hisagi-merged-style :ken-ranged t'
NOFAR = '(((:dn :out)) (:b-sp -0.3 :ns 0.0)) (((:dn :afar)) (:b-sp -0.3 :ns 0.0))'
DSMAP = ':dswitch-map ((:base 1 3))'


def arm(i, style, who, base='', rules='', extra=''):
    s = f'(:id {i}'
    s += f' {style}' if style else ''
    s += f' :apply ({who})' + (f' {extra}' if extra else '') + (f' :base ({base})' if base else '') + (f' :rules {rules}' if rules else '') + ')'
    return s


K = {  # Kenpachi: (file, plist)
    'k0-shipped': '(:id :shipped)',
    'k1-ken': arm(':kp1-ken', ':fn ken-ki-style', ':kenpachi'),
    'k2-press': arm(':kp2-press', ':fn ken-ki-style', ':kenpachi', *BRAWL),
    'k3-kite': arm(':kp3-kite', ':fn ken-ki-style', ':kenpachi', *KITE),
    'k4-zone': arm(':kp4-zone', ':fn ken-ki-style', ':kenpachi', *ZONE),
    'k5-iki': arm(':kp5-iki', ':fn ichigo-ki-style', ':kenpachi'),
    'k6-ipress': arm(':kp6-ipress', ':fn ichigo-ki-style', ':kenpachi', *BRAWL),
    'k7-ikite': arm(':kp7-ikite', ':fn ichigo-ki-style', ':kenpachi', *KITE),
    'k8-izone': arm(':kp8-izone', ':fn ichigo-ki-style', ':kenpachi', *ZONE),
    'k10-kends': arm(':kp10-kends', ':fn ken-ki-style', ':kenpachi', ':dswitch 1.0'),
    'k11-ids': arm(':kp11-ids', ':fn ichigo-ki-style', ':kenpachi', ':dswitch 1.0'),
}
H = {  # Hisagi
    'h1-merged': arm(':hm1-merged', MERGED, ':hisagi'),
    'h2-kenki': arm(':ht2-ki', ':fn ken-ki-style', ':hisagi :kenpachi', ':p 1.3'),
    'h3-press': arm(':hm3-press', MERGED, ':hisagi', *BRAWL),
    'h4-dswitch': arm(':hm2-dswitch', MERGED, ':hisagi', ':dswitch 1.0', '', DSMAP),
    'h5-kite': arm(':hm4-kite', MERGED, ':hisagi', *KITE),
    'h6-pressd': arm(':hm7-pressd', MERGED, ':hisagi', ':dswitch 1.0 ' + BRAWL[0], BRAWL[1], DSMAP),
    'h7-iki': arm(':ht8-iki', ':fn ichigo-ki-style', ':hisagi'),
    'h8-range': arm(':h1-range', ':fn hisagi-range-style', ':hisagi', ':dswitch 1.0', f'({NOFAR})', DSMAP),
    'h9-kenkite': arm(':ht9-kenkite', ':fn ken-ki-style', ':hisagi', *KITE),
    'h10-kends': arm(':ht10-kends', ':fn ken-ki-style', ':hisagi', ':dswitch 1.0', '', DSMAP),
    'h11-ids': arm(':ht11-ids', ':fn ichigo-ki-style', ':hisagi', ':dswitch 1.0', '', DSMAP),
}
if __name__ == '__main__':
    for side, cands in (('k', K), ('h', H)):
        os.makedirs(os.path.join(D, side), exist_ok=True)
        for name, text in cands.items():
            open(os.path.join(D, side, name + '.lisp'), 'w').write(text + '\n')
    print(len(K), 'Kenpachi,', len(H), 'Hisagi candidates')

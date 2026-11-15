#!/usr/bin/env python3
"""analyze.py — results.json (run.py) -> tables.md: the catalogue's generated tables, grouped by section (PLAN4 step 2).

  python3 docs/research/strategy-drsi/sp/kits/hisagi/analyze.py
"""
import json, os
from collections import defaultdict
HERE = os.path.dirname(os.path.abspath(__file__))
R = json.load(open(os.path.join(HERE, 'results.json')))
OPPN = {'Kz': 'Kenpachi sealed', 'Ks0': 'Kenpachi Shikai L0', 'Ks3': 'Kenpachi Shikai L3', 'Kb': 'Kenpachi Bankai KYORAN',
        'Ib': 'Ichigo Shikai', 'Ik': 'Ichigo KESSA', 'Hh': 'Hisagi Shikai (mirror)'}
FORMN = {'Hb': 'Shikai', 'Hr': 'Bankai ranged', 'Hd': 'Bankai bind'}
out = []
def w(s=''): out.append(s)

def code(t):
    """The outcome of a both-act trial: H Hisagi's real hit first, o his, x a cancel, a armour only, - nothing; 'x>H' a cancel, then
    Hisagi's hit (the dummy does nothing after it). The damage each way follows (his / Hisagi's)."""
    c = 'x' if t['cancels'] else ''
    if t['first'] != 'none':
        c += ('>' if c else '') + ('H' if t['first'].startswith('P1') else 'o')
    elif any(h[3] not in ('HIT', 'COUNTER') for h in t['hits']):
        c += ('>' if c else '') + 'a'
    return c or '-'

def span(vals):
    """{dist: dmg} -> 'from-to (dmg)' runs of consecutive samples (sorted by distance) that hit."""
    runs, cur = [], None
    for d in sorted(vals):
        if vals[d] > 0:
            if cur is None:
                cur = [d, d, set()]; runs.append(cur)
            cur[1] = d; cur[2].add(vals[d])
        else:
            cur = None
    return ', '.join(f"{a:.1f}-{b:.1f} m ({'/'.join(str(x) for x in sorted(s))})" for a, b, s in runs) or 'none'

# ---------------------------------------------------------------- reach
w('## R. Reach by distance (a standing dummy; the 0.5 m grid 1-7 m merged with the 0.1 m edges; damage dealt in brackets)\n')
reach = defaultdict(dict)
for t in R:
    p = t['name'].split('|')
    if p[0] in ('R', 'RE'):
        reach[(p[1], p[2], p[3])][float(p[4])] = t['p2dmg']
    elif p[0] in ('RH', 'RHE'):
        reach[('his', p[1], p[2])][float(p[3])] = t['p1dmg']
w('| Hisagi form | opener | vs Kenpachi sealed (hurt r 0.45) | vs Ichigo Shikai (hurt r 0.38) |\n|---|---|---|---|')
for f in ('Hb', 'Hr', 'Hd'):
    for op in ('J1', 'NS1a', 'NS2a', 'NS3a'):
        if (f, op, 'Kz') in reach:
            w(f"| {FORMN[f]} | {op} | {span(reach[(f, op, 'Kz')])} | {span(reach[(f, op, 'Ib')])} |")
w('\nHis openers on a standing Hisagi (Shikai, hurt r 0.36), damage Hisagi takes:\n')
w('| his form | opener | hits Hisagi from-to |\n|---|---|---|')
for k, v in reach.items():
    if k[0] == 'his':
        w(f"| {OPPN[k[1]]} | {k[2]} | {span(v)} |")

# ---------------------------------------------------------------- the triangle
w('\n## T. Both press on the same frame (his opener at sim frame 0 with Hisagi\'s)\n')
w('Codes: H Hisagi\'s real hit lands first, o his, x a cancel (J vs NS, or a same-frame tie), x>H / x>o a cancel and then that side\'s')
w('hit (the scripted side does nothing after the cancel: read x>H as "the exchange opens", section X has the answers), a armour only')
w('(Kenpachi\'s sealed NS2a :armor-act), - nothing lands. Then his / Hisagi\'s damage.\n')
tri = defaultdict(dict)
for t in R:
    p = t['name'].split('|')
    if p[0] == 'T':
        f, mine, o, his, d = p[1:]
        tri[(f, o)][(mine, his, d)] = f"{code(t)} {t['p2dmg']}/{t['p1dmg']}"
for (f, o), cells in tri.items():
    ds = sorted({k[2] for k in cells}, key=float)
    mines = list(dict.fromkeys(k[0] for k in cells)); hiss = list(dict.fromkeys(k[1] for k in cells))
    w(f"\n**{FORMN[f]} vs {OPPN[o]}**\n")
    w('| Hisagi \\ his | ' + ' | '.join(f'{h} @ {d}' for h in hiss for d in ds) + ' |')
    w('|---|' + '---|' * (len(hiss) * len(ds)))
    for m in mines:
        w(f'| {m} | ' + ' | '.join(cells.get((m, h, d), '') for h in hiss for d in ds) + ' |')

# ---------------------------------------------------------------- routes
w('\n## C. Routes on a standing dummy\n')
w('dmg = his Reishi lost (after scaling, the form\'s x, his taken x); hits = Hisagi\'s real hits; adv = his first free frame - Hisagi\'s')
w('after the last hit (a knockdown counts his wake-up); end = distance at the end; SP = Hisagi\'s flash-step change; ptr = his pointer after.\n')
rt = defaultdict(dict)
for t in R:
    p = t['name'].split('|')
    if p[0] == 'C':
        rt[(p[1], p[2])][p[3]] = t
for f in ('Hb', 'Hr', 'Hd'):
    w(f"\n**{FORMN[f]}**\n")
    w('| route | dmg Kz / Ks0 / Ib / Ik | hits | adv (Kz) | end (Kz) | SP | ptr, form after | log tags (Kz) |\n|---|---|---|---|---|---|---|---|')
    for (ff, tag), d in rt.items():
        if ff != f: continue
        t = d['Kz']
        hits = len([h for h in t['hits'] if h[0] == 'P1' and h[3] == 'HIT'])
        more = t['more'].split('form ')[-1]
        tags = '; '.join(sorted({x.split(' (')[0].split(' from')[0].replace('P1 ', '') for x in t['tags'] if 'KIN' not in x}))
        w(f"| {tag} | {' / '.join(str(d[o]['p2dmg']) for o in ('Kz', 'Ks0', 'Ib', 'Ik'))} | {hits} | {t['adv']} | {t['dist']:.2f} | {t['fs']} | {more} | {tags} |")
w('\n**Short of SP** (sealed Kenpachi; DUEL_SP §3: a segment paid P of C deals x (0.5 + 0.5 P / C))\n')
w('| route | fs 300 | fs 100 | fs 30 | fs 0 |\n|---|---|---|---|---|')
cf = defaultdict(dict)
for t in R:
    p = t['name'].split('|')
    if p[0] == 'CF':
        cf[p[2]][p[4]] = f"{t['p2dmg']} ({t['fs']})"
for tag, v in cf.items():
    w(f"| {tag} | {rt[('Hb', tag)]['Kz']['p2dmg']} ({rt[('Hb', tag)]['Kz']['fs']}) | {v.get('fs 100')} | {v.get('fs 30')} | {v.get('fs 0')} |")
w('\n**The bind\'s clash** (a cancel inside the bind evens 25 % of the Reishi gap, half from each side; DUEL_HISAGI §28.4)\n')
w('| trial | his dmg | Hisagi dmg (- = gained) | tags |\n|---|---|---|---|')
for t in R:
    p = t['name'].split('|')
    if p[0] == 'B':
        w(f"| {' / '.join(p[1:])} | {t['p2dmg']} | {t['p1dmg']} | {'; '.join(x for x in t['tags'] if 'KIN' not in x)} |")

# ---------------------------------------------------------------- whiffs, approach, exchange, wake-up, mirror
def section(key, title, note=''):
    w(f'\n## {title}\n')
    if note: w(note + '\n')
    w('| trial | vs | dist | outcome | his dmg | Hisagi dmg | adv | end | hits |\n|---|---|---|---|---|---|---|---|---|')
    for t in R:
        p = t['name'].split('|')
        if p[0] == key:
            hs = '; '.join(f'{h[0]} {h[1]} {h[3]} {h[4]}' for h in t['hits'][:6]) + (' ...' if len(t['hits']) > 6 else '')
            w(f"| {FORMN[p[1]]}: {p[2]} | {p[3]} | {p[4] if len(p) > 4 else ''} | {code(t)} | {t['p2dmg']} | {t['p1dmg']} | {t['adv']} | {t['dist']:.1f} | {hs} |")
section('W', 'W. Punishing his whiff (his opener just out of reach at frame 0; Hisagi\'s move pressed +N frames)')
section('WH', 'WH. His punish of Hisagi\'s whiff (Hisagi\'s opener out of reach; his J1 / NS1a pressed +N sim frames)')
section('A', 'A. Anti-approach (he runs in from 6.5 m / walks in from 5 m / Hohos in from 4.5 m)')
section('X', 'X. The exchange after a cancel', 'Hisagi J1 x his NS1a at 1.6 m and Hisagi NS2a x his J1 at 1.8 m (the cancel on sim frame ~15 / ~10); his follow-up +N sim frames after the cancel.')
section('G', 'G. Ichigo\'s Getsuga route (NS2a > NS2b > NS2c JUJISHO: a 150 wave, 3.6 m wide, 14 m/s, 12 m), Hisagi pressing +N frames')
section('K', 'K. Wake-up (his knockdown, then Hisagi presses +N frames after he is free)')
section('H', 'H. The mirror\'s neutral (P2 Hisagi Shikai)')

open(os.path.join(HERE, 'tables.md'), 'w').write('<!-- generated by analyze.py from results.json -->\n\n' + '\n'.join(out) + '\n')
print(len(out), 'lines -> tables.md')

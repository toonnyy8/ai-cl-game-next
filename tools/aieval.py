#!/usr/bin/env python3
"""aieval.py — one character's CPU, scored (the per-character AI redesign, the user 2026-10-02; docs/duel/DUEL_AI_V2.md;
Lille's stylised CPU search, the user 2026-10-12: docs/duel/DUEL_LILLE_V3.md §22).

Native sim (tools/simgate.py's build of THIS checkout): character C's CPU, as its <name>.lisp now reads, against every other
character's CPU as it reads in the same checkout.

  python3 tools/aieval.py --char 3                 Ichigo: JSON with the parts and the score
  python3 tools/aieval.py --char 3 --seeds 6       a quicker, noisier pass
  python3 tools/aieval.py --char 6 --seeds 40 -j 2 Lille, as a dream-rsi cell is scored (DUEL_LILLE_V3 §22)

The parts (seeds 1..N, fixed; the mirror is never played: C vs C is 0.5 by symmetry and tells nothing):
  strength  HARD, C vs each other character in both seats (learning gate runner, plain CPUs): C's win share
  masher    HARD, the button-masher (debug habit :dumb, every character, C's own included) as P1 vs C as P2: C's win share
            (N * 4 // 5 seeds each)
  signature the share of C's dealt damage (written damage of its hits, strength runs) that is the character's own:
            Yamamoto .. Senjumaru: anything but its J / K links (move names -J1 / -K2S ...); Lille: SIG_BARRO (below)
  pacing    NORMAL, C vs each other character (C as P1): every match a K.O. and the median <= PACE_MAX (220 s), else the
            score is 0. A K.O.: for Lille the RESULTS line's Konpaku (his cinematics put K.O.s past 300 s of match ticks);
            for the others, as frozen on 2026-10-02, a match under 299.5 s
score = w_str strength + w_mash masher + w_sig signature: 0.6 / 0.2 / 0.2 (the user's choice 2026-10-02: win rate +
character colour); Lille (--char 6, DUEL_LILLE_V3 §22, the user 2026-10-12: 「風格偏重 0.4/0.2/0.4」) 0.4 / 0.2 / 0.4, his
signature the whitelist SIG_BARRO (the stance strings' J / K, the spending L L
follow-ups, SP2 spending every special, the charged L at level 2 / 3: the base snipe's copies by name, the awakened dash and
its cuts by the sim's "Px br-sig charged" tag), and instead of the drift a NORMAL band: his NORMAL win share (both seats)
in NORMAL_BAND [0.30, 0.60], the score x a factor falling to 0 at NORMAL_FALL (0.15) outside it. Index 5 (simgate
RETIRED: the old Lille's, removed 2026-10-13) is never played

--pace-seeds / --drift-seeds (default --seeds) run the NORMAL parts at another seed count (the cheaper split).
Roster index C: 0 Yamamoto 1 Kenpachi 2 Rukia 3 Ichigo 4 Senjumaru 6 Lille (simgate.ROSTER). Rebuilds the native sim first
when a source changed.
"""
import argparse, concurrent.futures as cf, json, os, re, statistics, subprocess, sys
sys.dont_write_bytecode = True
from simgate import ROOT, ECL, FAS, MUSLM, ROSTER, RETIRED, build

NAMES = ROSTER                                    # (simgate.ROSTER: the roster in order)
BARRO = NAMES.index('BARRO')                      # Lille (kit :barro): SIG_BARRO, the K.O. by the RESULTS line
HISAGI = NAMES.index('HISAGI')                    # Hisagi (kit :hisagi): SIG_HISAGI, the K.O. by the RESULTS line
PACE_MAX = 220.0   # a 20-seed median's ceiling here (the gate's 210 s at 60 seeds: 20-seed medians run ~10 s noisy)
WEIGHTS = {BARRO: (0.4, 0.2, 0.4),               # strength, masher, signature; everyone else DEFAULT_W (Lille: the user
           HISAGI: (0.3, 0.2, 0.5)}               # 2026-10-12, 「風格偏重 0.4/0.2/0.4」, DUEL_LILLE_V3 §22; Hisagi: the user
                                                  # 2026-10-18, 「0.3/0.2/0.5 招牌至上」, DUEL_HISAGI §25)
DEFAULT_W = (0.6, 0.2, 0.2)
LINK = re.compile(r'-[JK]\d')                    # a J / K string link's move name (YA-J1, KE-R-K2S, RU-A-K3-50 ...)
# Lille's signature whitelist (the user 2026-10-12: 「蓄力招」「資源循環」「架勢連段」, DUEL_LILLE_V3 §22): the stance strings'
# J / K segments (every form: BR-S- / BR-E- / BR-OE-J1..K3, the gun-kata, the rifle swung, the top, the great sword: the
# KIN J / K -> L -> stance links reach these), the spending follow-ups (-JL1..-KL3) and SP2 spending every special
# (HIRENKYAKU, NIJUSHI-KO, the owl's volley KAISHU BR-RC0..4 / BR-O-RC0..4), the charged L at level 2 / 3 (the base's snipe
# copies BR-S-L1-2 / -3 by name; the awakened dash and its cuts by the sim's "Px br-sig charged" tag, barro.lisp BARRO-HIT);
# never his attack-state J / K, the level-1 L, the Breaker, SP1 or the Kikons
SIG_BARRO = re.compile(r'^BR-(?:(?:S|E|OE)-(?:[JK]\d|JL\d|KL\d|L1-[23])|K-HIREN(?:-C)?|W-NIJUSHI(?:-C)?|(?:O-)?RC\d)$')
# Hisagi's signature whitelist (the user 2026-10-18: 「始解鎖鐮連段」「卍解遠距路線」「捆綁」, DUEL_HISAGI §25): the Shikai's
# chain (the K string NAGI / NOKO / TSUI and K2J, the leaps J2K / J3K, the windmill and its bridge KAZA / KAZA-J, SP1 RAIDEN,
# SP2 SHIBARI), the Bankai's ranged routes (K1, every route link past J1: J2 / J2S / J3 / J3G / K2 / K2S / K3 / K3G, the L
# SAHARAI, the SPs, KUBIKAKE), the bind (every HS-B- move but its Kikon); never his plain J string (HS-J1..3, the dormant
# one-handed ones), the ranged J1, the Breaker or a Kikon
SIG_HISAGI = {'chain': re.compile(r'^HS-(?:K[123]|K2[JS]|J[23]K|KAZA(?:-J)?|RAIDEN|SHIBARI)$'),
              'ranged': re.compile(r'^HS-R-(?:K1|K2S?|K3G?|J2S?|J3G?|L|SP1|SP2C?|KUBIKAKE(?:-C)?)$'),
              'bind': re.compile(r'^HS-B-(?:[JK]\dS?|SJ|L|SP\d)$')}   # (SJ: the Step J SENGEN, §25.10)
NORMAL_BAND = {BARRO: (0.30, 0.60),               # Lille II: his NORMAL win share (both seats) in this band (DREAM_RSI §5.5;
               HISAGI: (0.30, 0.60)}              # Hisagi: as Lille's, his shipped CPU weak (DUEL_HISAGI §25)
NORMAL_FALL = 0.15                                # the baseline's broken weak by R12-R17: 0.07), else the score x a factor falling
                                                  # linearly to 0 at NORMAL_FALL outside it (partial credit: the search's signal)


def sim(cmds, log=True):
    script = 'tools/simgate/run-log.lisp' if log else 'tools/simgate/run.lisp'
    r = subprocess.run([ECL, '--norc', '--load', script, '--', FAS] + [str(c) for c in cmds], cwd=ROOT,
                       capture_output=True, text=True, env=dict(os.environ, LD_PRELOAD=MUSLM), timeout=3600)
    return r.stdout


def matches(job):
    """One learning-gate process: P1 c1 (habit h), P2 c2, seeds 1..n at difficulty d -> per match (winner, secs, hits) and
    per match a K.O. by the RESULTS line; hits per side: [name, damage, tag] in order (a "Px br-sig TAG" line tags that
    side's hit just before it)."""
    c1, c2, h, n, d = job
    kos = []
    out = sim([30000, 31100 + n, 81000, 81020 + d, 81030, 81040, 200000 + 1000 * h + 100 * c1 + 10 * c2])
    res, hits, ko = [], {0: [], 1: []}, False
    for line in out.splitlines():
        m = re.match(r'duel -> RESULTS winner \S+ konpaku (\d+)-(\d+)', line)
        if m:
            ko = m.group(1) == '0' or m.group(2) == '0'
            continue
        m = re.search(r'\] P([12]) (\S+) -> P[12] (HIT|COUNTER) (\d+)', line)
        if m:
            hits[int(m.group(1)) - 1].append([m.group(2), int(m.group(4)), None])
            continue
        m = re.search(r'\] P([12]) br-sig (\S+)', line)   # (Lille's BARRO-HIT)
        if m:
            side = hits[int(m.group(1)) - 1]
            if side:
                side[-1][2] = m.group(2)
            continue
        m = re.search(r'duel gate row seed \d+ \S+ \S+ secs ([\d.]+) winner (\S+)', line)
        if m:
            res.append((m.group(2), float(m.group(1)), hits))
            hits = {0: [], 1: []}
            kos.append(ko)
    return job, res, kos


def barro_class(name, tag):
    """One of Lille's hits -> (counted, signature, category of the breakdown)."""
    if tag == 'charged':
        return True, True, 'charged'
    if SIG_BARRO.match(name):
        return True, True, re.sub(r'\d$', '', name.lower())
    if LINK.search(name):
        return True, False, 'plain-jk'
    return True, False, 'other:' + name.lower()


def hisagi_class(name):
    """One of Hisagi's hits -> (signature, category of the breakdown: a theme of SIG_HISAGI, else plain-j / other)."""
    for k, rx in SIG_HISAGI.items():
        if rx.match(name):
            return True, k
    return False, 'plain-j' if LINK.search(name) else 'other:' + name.lower()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--char', type=int, required=True)
    ap.add_argument('--seeds', type=int, default=20)
    ap.add_argument('--pace-seeds', type=int, default=0, help='seeds of the NORMAL pacing runs (default --seeds)')
    ap.add_argument('--drift-seeds', type=int, default=0, help="seeds of Lille's NORMAL band runs (default --seeds)")
    ap.add_argument('-j', type=int, default=8)
    a = ap.parse_args()
    build()                                       # (a no-op unless a source is newer than the build)
    play = [o for o in range(len(NAMES)) if NAMES[o] not in RETIRED]   # (index 5, the removed old Lille's, out)
    if a.char not in play:
        sys.exit(f'aieval: no character {a.char} (index 5 is the removed old Lille\'s)')
    c, n, others = a.char, a.seeds, [o for o in play if o != a.char]
    pn, dn = a.pace_seeds or n, a.drift_seeds or n
    barro = c == BARRO
    banded = c in NORMAL_BAND                     # (Lille II, Hisagi: the NORMAL band and the K.O. by the RESULTS line)
    jobs = ([('str', (c, o, 0, n, 2)) for o in others] + [('str', (o, c, 0, n, 2)) for o in others] +
            [('mash', (m, c, 6, max(4, n * 4 // 5), 2)) for m in play] +
            [('pace', (c, o, 0, pn, 1)) for o in others])
    if banded:                           # (the drift's P1 half is the pacing runs when the seed counts agree)
        jobs += [('drift', (o, c, 0, dn, 1)) for o in others]
        if dn != pn:
            jobs += [('drift', (c, o, 0, dn, 1)) for o in others]
    won = {'str': [0, 0], 'mash': [0, 0]}
    drift = {}                                    # Lille: opponent -> [his wins, matches] (both seats: NORMAL)
    sig = [0, 0]
    cat = {}                                      # Lille: his damage by category (the breakdown)
    pace_ok, pace = True, {}
    with cf.ProcessPoolExecutor(a.j) as ex:
        futs = {ex.submit(matches, job): kind for kind, job in jobs}
        for fu in cf.as_completed(futs):
            kind = futs[fu]
            (c1, c2, h, nn, d), res, ko = fu.result()
            # a K.O.: Lille's by the RESULTS line's Konpaku (his cinematics put K.O.s past 300 s of match ticks); the others'
            # as frozen on 2026-10-02: a match under 299.5 s (a time-up runs the 300 s clock out)
            nm, kos = len(res), sum(1 for (_, s, _), k in zip(res, ko) if (k if banded else s < 299.5))
            side = 1 if kind == 'mash' else (0 if c1 == c else 1)   # C's seat (the masher is always P1, C's mirror too)
            opp = NAMES[c2 if side == 0 else c1]
            if banded and (kind == 'drift' or (kind == 'pace' and pn == dn)):
                w = drift.setdefault(opp, [0, 0])
                w[0] += sum(1 for win, _, _ in res if win == ('P1' if side == 0 else 'P2'))
                w[1] += len(res)
            if kind == 'drift':
                continue
            if kind == 'pace':
                secs = sorted(s for _, s, _ in res)
                med = statistics.median(secs) if secs else 999.0
                pace[opp] = {'kos': kos, 'matches': nm, 'median': round(med, 1)}
                if nm == 0 or kos < nm or med > PACE_MAX:
                    pace_ok = False
                continue
            for w, _, hits in res:
                won[kind][1] += 1
                won[kind][0] += (w == ('P1' if side == 0 else 'P2'))
                if kind == 'str':
                    for name, dmg, tag in hits[side]:
                        if barro:
                            counted, mine, k = barro_class(name, tag)
                            cat[k] = cat.get(k, 0) + dmg
                            if counted:
                                sig[1] += dmg
                                sig[0] += dmg if mine else 0
                        elif c == HISAGI:
                            mine, k = hisagi_class(name)
                            cat[k] = cat.get(k, 0) + dmg
                            sig[1] += dmg
                            sig[0] += dmg if mine else 0
                        else:
                            sig[1] += dmg
                            sig[0] += 0 if LINK.search(name) else dmg
    part = {k: (won[k][0] / won[k][1] if won[k][1] else 0.0) for k in won}
    part['signature'] = sig[0] / sig[1] if sig[1] else 0.0
    ws, wm, wg = WEIGHTS.get(c, DEFAULT_W)
    out = {'char': NAMES[c], 'score': 0.0, 'strength': round(part['str'], 3), 'masher': round(part['mash'], 3),
           'signature': round(part['signature'], 3), 'pacing_ok': pace_ok, 'pacing': pace,
           'matches': {k: won[k][1] for k in won}}
    ok = pace_ok
    normal_k = 1.0
    if banded:                                    # (Lille II, Hisagi: a NORMAL band, not a drift from a broken baseline)
        dw, dm = sum(v[0] for v in drift.values()), sum(v[1] for v in drift.values())
        share = dw / dm if dm else 0.0
        lo, hi = NORMAL_BAND[c]
        band_ok = dm > 0 and lo <= share <= hi
        off = 1.0 if dm == 0 else max(lo - share, share - hi, 0.0)
        normal_k = max(0.0, 1.0 - off / NORMAL_FALL)
        out['normal'] = {'share': round(share, 4), 'band': [lo, hi], 'ok': band_ok, 'factor': round(normal_k, 4), 'seeds': dn,
                         'by_opp': {k: f'{v[0]}/{v[1]}' for k, v in sorted(drift.items())}}
    if barro or c == HISAGI:
        tot = sum(cat.values()) or 1
        out['sig_by'] = {k: round(v / tot, 3) for k, v in sorted(cat.items(), key=lambda kv: -kv[1])}
        out['weights'] = [ws, wm, wg]
        if pn != n:
            out['pace_seeds'] = pn
    raw = ws * part['str'] + wm * part['mash'] + wg * part['signature']
    if banded:
        out['raw'] = round(raw, 4)
        raw *= normal_k
    out['score'] = round(raw, 4) if ok else 0.0
    print(json.dumps(out))


if __name__ == '__main__':
    main()

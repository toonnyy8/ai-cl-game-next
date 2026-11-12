#!/usr/bin/env python3
"""matchup-eval.py — a matchup style CPU, scored (docs/duel/DUEL_MATCHUP_AI.md §1, §4; the user 2026-11-06). FROZEN for a search:
record the commit that last touched this file, tools/simgate/situ.lisp or run-situ.lisp.

  python3 tools/matchup-eval.py --side ken            Kenpachi's style against Ichigo (as the checkout's files read): JSON
  python3 tools/matchup-eval.py --side ichigo --seeds 20

Pairing KI (Kenpachi = roster 1, Ichigo = 3). Seeds 1..N, both seats, native sim (simgate's build of THIS checkout).
  strength   HARD, the side's CPU against the other side's CPU as this checkout has it (its style, or the generic CPU): the side's win share
  signature  HARD (the same matches): the mean over the side's four themes of successes / situations (situ.lisp; Ichigo's pointer-3 theme
             from the combat log: a SOUL BREAK of hers, ok at -5 Konpaku; a KIKON FOLLOW-UP of hers, ok when "(red)"); a theme with no
             situation scores 0, except a theme the opponent opens (OPP_TRIGGERED), which then leaves the mean
  normal     NORMAL, the side's CPU against the OTHER side's GENERIC CPU (its style unregistered), both seats: the side's win share; the
             score x a factor, 1 inside BAND[side], falling to 0 at FALL outside it (the band: the generic-vs-generic share +-0.10)
score = (0.4 strength + 0.6 signature) x the NORMAL factor (the user's 「勝率 0.4 / 招牌 0.6」).
"""
import argparse, concurrent.futures as cf, json, os, re, sys
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from simlib import build, run_lisp, ROW

KEN, ICH = 1, 3
THEMES = {'ken': ['brawl', 'shikai', 'bankai', 'antiwave'], 'ichigo': ['spacing', 'whiff', 'ptr3', 'kessa']}
# themes the OPPONENT's play opens (her Getsuga route; his whiff): with no situation in the whole run they leave the mean
# (the user, 2026-11-07: 「對手觸發的不列入平均」, DUEL_MATCHUP_AI §10); every other theme with no situation scores 0
OPP_TRIGGERED = {'ken': {'antiwave'}, 'ichigo': {'whiff'}}
CHAR = {'ken': 'kenpachi', 'ichigo': 'ichigo'}
OTHER = {'ken': 'ichigo', 'ichigo': 'ken'}
# the generic-vs-generic NORMAL share, 40 seeds a seat, measured at the freeze (DUEL_MATCHUP_AI §6); the band = that +- 0.10
BASE_NORMAL = {'ken': 0.9625, 'ichigo': 0.0375}   # 77/80 and 3/80, 2026-11-06 at bcf196a + the evaluator
BAND_HALF, FALL = 0.10, 0.15


def run(job):
    c1, c2, n, d, generic = job
    cmds = [30000, 31100 + n, 81020 + d, 200000 + 100 * c1 + 10 * c2]
    r = run_lisp('simgate/run-situ.lisp', cmds, dict(os.environ, SITU_GENERIC=generic or ''), timeout=3600)
    if r.returncode:
        sys.exit(f'matchup-eval: sim exited {r.returncode}\n' + (r.stdout + r.stderr)[-2000:])
    return job, r.stdout


def parse(out, side_char_seat):
    """-> (wins, matches, theme counts {theme: [ok, occ]}) for the side in seat side_char_seat ('P1' / 'P2')."""
    wins = matches = 0
    th = {}
    for line in out.splitlines():
        m = ROW.search(line)
        if m:
            matches += 1
            wins += m.group(2) == side_char_seat
            continue
        m = re.search(r'situ (P[12]) (\S+) (occ|ok)', line)
        if m and m.group(1) == side_char_seat:
            t = th.setdefault(m.group(2), [0, 0])
            t[1] += 1
            t[0] += m.group(3) == 'ok'
            continue
        m = re.search(r'\] (P[12]) SOUL BREAK on P[12]: -(\d+) konpaku', line)
        if m and m.group(1) == side_char_seat:
            t = th.setdefault('ptr3', [0, 0]); t[1] += 1; t[0] += int(m.group(2)) >= 5
            continue
        m = re.search(r'\] (P[12]) KIKON FOLLOW-UP on P[12]( \(red\))?', line)
        if m and m.group(1) == side_char_seat:
            t = th.setdefault('ptr3', [0, 0]); t[1] += 1; t[0] += bool(m.group(2))
    return wins, matches, th


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--side', choices=['ken', 'ichigo'], required=True)
    ap.add_argument('--seeds', type=int, default=40)
    ap.add_argument('-j', type=int, default=4)
    ap.add_argument('--no-normal', action='store_true', help='skip the NORMAL band runs (a quick in-cell look)')
    a = ap.parse_args()
    build()
    me = KEN if a.side == 'ken' else ICH
    op = ICH if a.side == 'ken' else KEN
    n = a.seeds
    jobs = [('hard', (me, op, n, 2, None)), ('hard', (op, me, n, 2, None))]
    if not a.no_normal:
        jobs += [('normal', (me, op, n, 1, CHAR[OTHER[a.side]])), ('normal', (op, me, n, 1, CHAR[OTHER[a.side]]))]
    won = {'hard': [0, 0], 'normal': [0, 0]}
    th = {t: [0, 0] for t in THEMES[a.side]}
    with cf.ProcessPoolExecutor(a.j) as ex:
        futs = {ex.submit(run, job): kind for kind, job in jobs}
        for fu in cf.as_completed(futs):
            kind = futs[fu]
            (c1, c2, nn, d, g), out = fu.result()
            seat = 'P1' if c1 == me else 'P2'
            w, m, t = parse(out, seat)
            won[kind][0] += w; won[kind][1] += m
            if kind == 'hard':
                for k, (ok, occ) in t.items():
                    if k in th:
                        th[k][0] += ok; th[k][1] += occ
    strength = won['hard'][0] / won['hard'][1] if won['hard'][1] else 0.0
    per = {k: (v[0] / v[1] if v[1] else 0.0) for k, v in th.items()}
    counted = [k for k in per if th[k][1] or k not in OPP_TRIGGERED[a.side]]
    signature = sum(per[k] for k in counted) / len(counted)
    out = {'side': a.side, 'seeds': n, 'strength': round(strength, 4), 'signature': round(signature, 4),
           'excluded': [k for k in per if k not in counted],
           'themes': {k: {'rate': round(per[k], 3), 'ok': th[k][0], 'occ': th[k][1]} for k in th},
           'hard': f"{won['hard'][0]}/{won['hard'][1]}"}
    raw = 0.4 * strength + 0.6 * signature
    factor = 1.0
    if not a.no_normal:
        share = won['normal'][0] / won['normal'][1] if won['normal'][1] else 0.0
        base = BASE_NORMAL[a.side]
        if base is not None:
            lo, hi = max(0.0, base - BAND_HALF), min(1.0, base + BAND_HALF)
            off = max(lo - share, share - hi, 0.0)
            factor = max(0.0, 1.0 - off / FALL)
            out['normal'] = {'share': round(share, 4), 'band': [round(lo, 3), round(hi, 3)], 'factor': round(factor, 4),
                             'matches': won['normal'][1]}
        else:
            out['normal'] = {'share': round(share, 4), 'band': None, 'factor': 1.0, 'matches': won['normal'][1]}
    out['raw'] = round(raw, 4)
    out['score'] = round(raw * factor, 4)
    print(json.dumps(out))


if __name__ == '__main__':
    main()

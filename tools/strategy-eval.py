#!/usr/bin/env python3
"""strategy-eval.py — the evaluator of the CPU strategy library search (docs/duel/DUEL_AI_STRATEGY.md §4, §8.2; the user, 2026-11-08).
FROZEN for a search round: record the commit that last touched this file and tools/simgate/strat-desc.lisp.

  python3 tools/strategy-eval.py --char kenpachi --vs ichigo --strat docs/research/strategy-drsi/X.lisp [--seeds 20] [--seed0 0]
         [--opp FILE_OR_DIR ...] [--library DIR] [--save-desc] [--no-normal] [-j 4]

A strategy file is one plist (duel/lisp/strategy.lisp); tools/simgate/strat-desc.lisp plays native matches (the simgate build of THIS checkout,
which is never rebuilt here) with the character's CPU on it and observes behaviour descriptors. Fixed seeds s0+1..s0+n, BOTH seats (common random numbers).
  strength  HARD, the character on FILE against the opponent's CURRENT CPU (its style CPU kept), or against --opp (files / dirs, equal weights; a
            name '@cpu' = the current CPU, '@generic' = its generic CPU): the character's win share (a draw counts 0; a time-out counts for
            the side ahead, or 0 with --ko-only: a win counts only if it was a K.O., in every share below, NORMAL's and its BASE's too)
  descript. the character's behaviour in those HARD matches, averaged over matches (see strat-desc.lisp: distance bands, attack / Hoho / Kikon rates ...)
  style     distinctness of the descriptor vector from every entry of --library DIR (its *.desc.json, same character): the mean over the descriptors
            of |a-b| / (|a|+|b|+floor) to the NEAREST entry, divided by --style-full (0.25) and clipped to 0-1; an empty library gives 1
  normal    NORMAL, the character on FILE against the opponent's GENERIC CPU, both seats: its win share, against BASE = the generic-vs-generic share
            (measured once, cached): factor 1 inside BASE +- 0.10, falling to 0 at 0.15 beyond it (as tools/matchup-eval.py)
  score     max(0.01, (0.5 strength + 0.5 style) x normal factor)
--save-desc writes <FILE>.desc.json (the descriptors, strength, the conditions) next to the strategy. Raw match output is cached in
build/strategy-eval-cache/ by (files' hashes, seats, difficulty, seeds, build hash), so a repeated call is free. At most 8 sim processes (-j).
"""
import argparse, glob, json, os, re, sys
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from simlib import ROOT, build, build_hash as _build_hash, run_lisp, sha, pool, ROW, row_win

ROSTER = {'kenpachi': 1, 'ichigo': 3, 'hisagi': 7}      # roster indices (kit.lisp *ROSTER*)
DEFAULT_VS = {'kenpachi': 'ichigo', 'ichigo': 'kenpachi', 'hisagi': 'kenpachi'}
KEYS = ['in', 'reach', 'out', 'afar', 'dist', 'na', 'ns', 'as', 'sa', 'atk', 'hoho', 'perf', 'wp', 'punished', 'kik', 'wav']
FLOOR = {'in': .05, 'reach': .05, 'out': .05, 'afar': .05, 'dist': .5, 'perf': .1}   # others (rates per minute): 1.0
BAND_HALF, FALL = 0.10, 0.15
CACHE = os.path.join(ROOT, 'build/strategy-eval-cache')
DESC_LISP = os.path.join(ROOT, 'tools/simgate/strat-desc.lisp')


def build_hash():
    return _build_hash(DESC_LISP)


def spec_id(spec):
    """'@cpu' / '@generic' stay as they are; a file is its content's hash."""
    return spec if spec.startswith('@') else sha(open(spec, 'rb').read())


def expand(items):
    """Files / dirs (and @names) -> a flat list of specs."""
    out = []
    for it in items:
        out += sorted(glob.glob(os.path.join(it, '*.lisp'))) if os.path.isdir(it) else [it]
    return out


def run_job(c1, c2, spec1, spec2, diff, seed0, n):
    """One sim process: roster c1 (P1) vs c2 (P2), specs '@cpu' | '@generic' | a strategy file, difficulty 0-2, seeds seed0+1..seed0+n.
    -> stdout (cached)."""
    key = sha(json.dumps([c1, c2, spec_id(spec1), spec_id(spec2), diff, seed0, n, build_hash()]).encode())
    path = os.path.join(CACHE, key + '.out')
    if os.path.exists(path):
        return open(path).read()
    os.makedirs(CACHE, exist_ok=True)
    chars = {c1: [k for k, v in ROSTER.items() if v == c1][0], c2: [k for k, v in ROSTER.items() if v == c2][0]}
    env = dict(os.environ)
    gen = []
    for seat, spec, c in (('P1', spec1, c1), ('P2', spec2, c2)):
        if spec == '@generic':
            gen.append(chars[c])
        elif spec != '@cpu':
            env['STRAT_' + seat] = os.path.abspath(spec)
    env['DESC_GENERIC'] = ','.join(gen)
    cmds = [30000 + seed0, 31100 + n, 81020 + diff, 200000 + 100 * c1 + 10 * c2]
    r = run_lisp('simgate/strat-desc.lisp', cmds, env, timeout=7200)
    if r.returncode:
        sys.exit(f'strategy-eval: sim exited {r.returncode}\n' + (r.stdout + r.stderr)[-2000:])
    out = '\n'.join(l for l in r.stdout.splitlines() if l.startswith(('desc ', 'duel gate row ', 'strat ')))
    with open(path + '.tmp', 'w') as f:
        f.write(out + '\n')
    os.replace(path + '.tmp', path)
    return out


def parse(out, seat, ko_only=False):
    """-> (wins (KO_ONLY: K.O. wins), matches, [descriptor dict of `seat`'s lines])."""
    wins = matches = 0
    desc = []
    for line in out.splitlines():
        m = ROW.search(line)
        if m:
            matches += 1
            wins += row_win(line, m, seat, ko_only)
            continue
        m = re.match(r'desc (P[12]) (\S+) (\d+) (.*)', line)
        if m and m.group(1) == seat:
            desc.append({k: float(v) for k, v in (kv.split('=') for kv in m.group(4).split())})
    return wins, matches, desc


def run_many(jobs, nproc):
    """jobs: list of run_job argument tuples -> outputs in order (parallel; <= 8 processes)."""
    nproc = max(1, min(8, nproc))
    build()
    return pool(lambda j: run_job(*j), jobs, nproc)


def share(me, opp, spec_me, spec_opp, diff, seed0, n, nproc=4):
    """Spec-level helper for single calls: -> (wins, matches, descriptors) of `me` (roster idx) vs `opp`, both seats."""
    outs = run_many([(me, opp, spec_me, spec_opp, diff, seed0, n), (opp, me, spec_opp, spec_me, diff, seed0, n)], nproc)
    w1, m1, d1 = parse(outs[0], 'P1')
    w2, m2, d2 = parse(outs[1], 'P2')
    return w1 + w2, m1 + m2, d1 + d2


def mean_desc(ds):
    return {k: round(sum(d[k] for d in ds) / len(ds), 4) for k in KEYS} if ds else {k: 0.0 for k in KEYS}


def distance(a, b):
    return sum(abs(a[k] - b[k]) / (abs(a[k]) + abs(b[k]) + FLOOR.get(k, 1.0)) for k in KEYS) / len(KEYS)


def style_of(desc, char, library, full):
    """-> (style 0-1, nearest entry name or None, raw distance)."""
    best = None
    for p in sorted(glob.glob(os.path.join(library, '*.desc.json'))) if library else []:
        e = json.load(open(p))
        if e.get('char') == char:
            d = distance(desc, e['desc'])
            if best is None or d < best[0]:
                best = (d, os.path.basename(p))
    if best is None:
        return 1.0, None, None
    return min(1.0, best[0] / full), best[1], round(best[0], 4)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--char', required=True, choices=list(ROSTER))
    ap.add_argument('--vs', choices=list(ROSTER), help='the opponent character (default: Kenpachi<->Ichigo, Hisagi vs Kenpachi)')
    ap.add_argument('--strat', required=True, help="the character's strategy file")
    ap.add_argument('--opp', nargs='*', default=['@cpu'], help="opponent specs: files / dirs / @cpu / @generic (equal weights)")
    ap.add_argument('--seeds', type=int, default=20, help='seeds a seat')
    ap.add_argument('--seed0', type=int, default=0)
    ap.add_argument('--library', help='dir of *.desc.json entries to be distinct from')
    ap.add_argument('--style-full', type=float, default=0.25, help='a nearest-entry distance of this scores style 1')
    ap.add_argument('--base', type=float, help='the generic-vs-generic NORMAL share (default: measured, cached)')
    ap.add_argument('--no-normal', action='store_true')
    ap.add_argument('--save-desc', action='store_true')
    ap.add_argument('-j', type=int, default=4)
    ap.add_argument('--ko-only', action='store_true', help='a win counts only if it was a K.O. (a time-out lead scores 0)')
    a = ap.parse_args()
    parse_ = lambda out, seat: parse(out, seat, a.ko_only)
    vs = a.vs or DEFAULT_VS[a.char]
    me, op = ROSTER[a.char], ROSTER[vs]
    opps = expand(a.opp)
    n, s0 = a.seeds, a.seed0
    jobs = []
    for o in opps:       # HARD, both seats, per opponent spec
        jobs += [(me, op, a.strat, o, 2, s0, n), (op, me, o, a.strat, 2, s0, n)]
    nh = len(jobs)
    if not a.no_normal:
        jobs += [(me, op, a.strat, '@generic', 1, s0, n), (op, me, '@generic', a.strat, 1, s0, n)]
        if a.base is None:
            jobs += [(me, op, '@generic', '@generic', 1, s0, n), (op, me, '@generic', '@generic', 1, s0, n)]
    outs = run_many(jobs, a.j)
    w = m = 0
    ds = []
    per_opp = {}
    for i in range(0, nh, 2):
        w1, m1, d1 = parse_(outs[i], 'P1'); w2, m2, d2 = parse_(outs[i + 1], 'P2')
        per_opp[os.path.basename(opps[i // 2])] = f'{w1 + w2}/{m1 + m2}'
        w += (w1 + w2) / max(1, m1 + m2) / len(opps); m += 1
        ds += d1 + d2
    strength = w / m
    desc = mean_desc(ds)
    style, nearest, dist = style_of(desc, a.char, a.library, a.style_full)
    res = {'char': a.char, 'vs': vs, 'strat': a.strat, 'seeds': n, 'seed0': s0, 'ko_only': a.ko_only, 'strength': round(strength, 4), 'hard': per_opp,
           'desc': desc, 'style': round(style, 4), 'nearest': nearest, 'nearest_dist': dist}
    factor = 1.0
    if not a.no_normal:
        wn1, mn1, _ = parse_(outs[nh], 'P1'); wn2, mn2, _ = parse_(outs[nh + 1], 'P2')
        share_n = (wn1 + wn2) / max(1, mn1 + mn2)
        if a.base is None:
            wb1, mb1, _ = parse_(outs[nh + 2], 'P1'); wb2, mb2, _ = parse_(outs[nh + 3], 'P2')
            base = (wb1 + wb2) / max(1, mb1 + mb2)
        else:
            base = a.base
        lo, hi = max(0.0, base - BAND_HALF), min(1.0, base + BAND_HALF)
        factor = max(0.0, 1.0 - max(lo - share_n, share_n - hi, 0.0) / FALL)
        res['normal'] = {'share': round(share_n, 4), 'base': round(base, 4), 'band': [round(lo, 3), round(hi, 3)], 'factor': round(factor, 4),
                         'matches': mn1 + mn2}
    res['raw'] = round(0.5 * strength + 0.5 * style, 4)
    res['score'] = round(max(0.01, res['raw'] * factor), 4)
    if a.save_desc:
        p = os.path.splitext(a.strat)[0] + '.desc.json'
        json.dump({'char': a.char, 'vs': vs, 'seeds': n, 'seed0': s0, 'strength': res['strength'], 'desc': desc, 'opp': a.opp}, open(p, 'w'), indent=1)
        res['saved'] = p
    print(json.dumps(res))


if __name__ == '__main__':
    main()

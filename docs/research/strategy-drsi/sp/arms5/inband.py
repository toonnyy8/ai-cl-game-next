#!/usr/bin/env python3
"""inband.py — PLAN4 §3 step 4's in-band admission test on the candidate T0s (arms5/inband.md; the lead's brief, 2026-11-15).

  python3 inband.py tables [--h0 h5-all]            # every candidate map (inband/maps/) and table (inband/t0/), checks job overlaps
  python3 inband.py selftest                         # inband-run.lisp = strat-run.lisp when STRAT_INBAND is unset or arm k = 0
  python3 inband.py result --me C --vs D --mine FILE --theirs FILE|none [--tag T]
                                                     # game result (a draw half) and K.O.s, seeds 141-180 both seats
  python3 inband.py ib --row ROW --arm K [--salts 10] [-j 20]
                                                     # the in-band test of arm K of candidate table ROW against the opponent's
  python3 inband.py bar --row ROW [--final]          # proof.py bar on the row's table (candidate, or arms5/t0/ with --final)

Rows: ki-kenpachi ki-ichigo kh-kenpachi kh-hisagi ih-ichigo ih-hisagi kk-kenpachi ii-ichigo hh-hisagi; an alternative arm in a slot is a
row variant "<row>@<id>" (e.g. kh-kenpachi@a4-k-bait). Seeds 141-180 only (PLAN4 "After the implementation batches"); salts 1..S.
The in-band test: on ME's seat (both seats in turn) the table plays as written, except that every run of judgements whose pick is arm K
is played by arm K or arm 0 on a coin (tools/simgate/inband-run.lisp, STRAT_INBAND). Per match: y = ME's game result (1 / 0.5 / 0),
s = the share of the pick-K judgements arm K played. Matches with no pick-K judgement carry nothing and are dropped. The effect = the
OLS slope of y on s with a fixed effect per (seed, seat) (the salts vary only the coins), i.e. "arm K plays all of its job" minus "arm 0
plays all of it", in match points; z = slope / its se.
Env SP_BUILD: refuse another sim build (fas + strat-run.lisp, as eval.py / ladder.py).
"""
import argparse, hashlib, importlib.util, json, os, re, statistics, subprocess, sys, types
from concurrent.futures import ThreadPoolExecutor
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
A4 = os.path.join(HERE, '..', 'arms4')
ROOT = os.path.abspath(os.path.join(HERE, '../../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import simlib  # noqa: E402
_s = importlib.util.spec_from_file_location('proof', os.path.join(A4, 'proof.py'))
proof = importlib.util.module_from_spec(_s); _s.loader.exec_module(proof)
sw, ss = proof.sw, proof.ss
import numpy as np  # noqa: E402

SEED0, SEEDS = 140, 40                     # seeds 141-180, the block PLAN4 named for this test
CACHE = os.path.join(ROOT, 'build/inband-cache')
RUNNER = 'simgate/inband-run.lisp'
XU = os.path.join(A4, 'x-units')

# ---- the arms (refs relative to arms4/, proof.py t0's form) and their jobs (:rb-sp2 [group, [antecedent substrings]] entries, an OR) ----
K5, I5, H5 = '../arms5/kenpachi/', '../arms5/ichigo/arms.lisp', '../arms5/hisagi/arms-clash.lisp'
ARM = {'k5-all': K5 + 'a0-all.lisp#k5-all', 'k5-poke': K5 + 'g1-poke.lisp#k5-poke', 'k5-wake': K5 + 'g2-wake.lisp#k5-wake',
       'k5-red': K5 + 'g3-red.lisp#k5-red', 'k5-climb': K5 + 'g4-climb.lisp#k5-climb', 'k5-getsuga': K5 + 't1-getsuga.lisp#k5-getsuga',
       'k5-hug': K5 + 't2-hug.lisp#k5-hug', 'a4-k-bait': 'kenpachi.lisp#a4-k-bait',
       'a4-i-kessa2': 'ichigo.lisp#a4-i-kessa2', 'h4-wake': 'cells-h/final/h4-wake.lisp#h4-wake',
       'h4-all': '../arms5/inband/h0.lisp#h4-all', 'h5-all0': '../arms5/inband/h0.lisp#h5-all0'}
ARM.update({i: f'{I5}#{i}' for i in ('a4-i-all', 'a5-i-answer', 'a4-i-brawl', 'a5-i-economy', 'a5-i-punish', 'a5-i-kessa-lunge', 'a4-i-keep',
                                     'a5-i-inside')})
ARM.update({i: f'{H5}#{i}' for i in ('h5-all', 'h5-cancel', 'h5-tip', 'h5-bind', 'h5-wake', 'h5-k1', 'h5-i1', 'h5-ihx')})
FREE, ATK, EVA, DOWN = '(:ost :free)', '(:ost :atk)', '(:ost :evade)', '(:ost :down)'
C, M, F = '(:dm :m-close)', '(:dm :m-mid)', '(:dm :m-far)'
JOB = {
    # Kenpachi (arms5/kenpachi.md "Job maps"; climb without his red: the 4 G0 rules red and climb both named go to red, inband.md §2)
    'k5-poke': [[1, ['(:form :no)', C]], [10, ['(:optr :yes)', C]]],
    'k5-wake': [[2, [DOWN, C]], [2, [DOWN, M]]],
    'k5-red': [[0, ['(:ored :yes)']], [7, ['(:or :r-low)']]],
    'k5-climb': [[0, ['(:lead :even)', '(:ored :no)', '(:awst :k2)']], [0, ['(:lead :ahead)', '(:ored :no)', '(:awst :k2)']]],
    'k5-getsuga': [[10, ['(:optr :k2)', M]], [10, ['(:optr :k2)', F]]],
    'k5-hug': [[10, ['(:optr :yes)', M]], [2, [FREE, M]]],
    'a4-k-bait': [[2, [DOWN]]],                                                      # (B4's)
    # Ichigo (arms5/ichigo/jobs.py; kessa2 = B4 v1's, the same rules as kessa-lunge)
    'a5-i-answer': [[2, [ATK, C]], [5, ['(:xch :yes)']]],
    'a4-i-brawl': [[2, [FREE]]],
    'a5-i-economy': [[3, ['(:mcell :no)', '(:ocell :yes)']], [3, ['(:mcell :no)', '(:ocell :p2up)']]],
    'a5-i-punish': [[2, [ATK, M]], [2, [EVA, C]], [2, [EVA, M]]],
    'a5-i-kessa-lunge': [[1, ['(:form :yes)', M]], [1, ['(:form :yes)', F]]],
    'a4-i-kessa2': [[1, ['(:form :yes)', M]], [1, ['(:form :yes)', F]]],
    'a4-i-keep': [[8, ['(:time :t-late)', '(:lead :ahead)']]],
    'a5-i-inside': [[1, ['(:form :no)', M]], [10, ['(:optr :yes)', M]]],
    # Hisagi (arms5/hisagi/jobs.json; h4-wake = h5-wake's)
    'h5-cancel': [[2, [ATK, C]], [2, [ATK, M]], [5, ['(:xch :yes)']]],
    'h5-tip': [[1, ['(:form :yes)', M]], [1, ['(:form :yes)', F]]],
    'h5-bind': [[0, ['(:lead :behind)', '(:awst :k2)']], [7, ['(:mr :r-low)', '(:or :r-high)']], [1, ['(:form :k2)', C]]],
    'h5-wake': [[2, [DOWN]]], 'h4-wake': [[2, [DOWN]]],
    'h5-k1': [[10, ['(:optr :yes)', M]], [10, ['(:optr :yes)', F]]],
    'h5-i1': [[10, ['(:optr :k2)', M]], [10, ['(:optr :k2)', F]], [10, ['(:optr :k3)', M]]],
    'h5-ihx': [[7, ['(:mr :r-high)', '(:or :r-low)']]],
}
TARGETED = {'k5-getsuga', 'k5-hug', 'a4-k-bait', 'a4-i-keep', 'a5-i-inside', 'h5-k1', 'h5-i1', 'h5-ihx'}
KG, IG, HG = ['k5-poke', 'k5-wake', 'k5-red', 'k5-climb'], ['a5-i-answer', 'a4-i-brawl', 'a5-i-economy', 'a5-i-punish', 'a5-i-kessa-lunge'], \
    ['h5-cancel', 'h5-tip', 'h5-bind', 'h5-wake']
# row -> (me, vs, arm ids (arm 0 first), :with unit, q, the opponent row). Mirrors: general arms, no :with (PLAN4 §3), against themselves.
ROWS = {
    'ki-kenpachi': ('kenpachi', 'ichigo', ['k5-all'] + KG + ['k5-getsuga'], 'd-x-ki-k', 0.075, 'ki-ichigo'),
    'ki-ichigo': ('ichigo', 'kenpachi', ['a4-i-all'] + IG + ['a4-i-keep'], 'd-x-ki-i', 0.06, 'ki-kenpachi'),
    'kh-kenpachi': ('kenpachi', 'hisagi', ['k5-all'] + KG + ['k5-hug'], 'd-x-kh-k', 0.075, 'kh-hisagi'),
    'kh-hisagi': ('hisagi', 'kenpachi', ['h5-all'] + HG + ['h5-k1'], 'd-x-kh-h', 0.075, 'kh-kenpachi'),
    'ih-ichigo': ('ichigo', 'hisagi', ['a4-i-all'] + IG + ['a5-i-inside'], 'd-x-ih-i', 0.06, 'ih-hisagi'),
    'ih-hisagi': ('hisagi', 'ichigo', ['h5-all'] + HG + ['h5-i1', 'h5-ihx'], 'd-x-ih-h', 0.075, 'ih-ichigo'),
    'kk-kenpachi': ('kenpachi', 'kenpachi', ['k5-all'] + KG, None, 0.075, 'kk-kenpachi'),
    'ii-ichigo': ('ichigo', 'ichigo', ['a4-i-all'] + IG, None, 0.06, 'ii-ichigo'),
    'hh-hisagi': ('hisagi', 'hisagi', ['h5-all'] + HG, None, 0.075, 'hh-hisagi'),
}
# the arms4 arms that passed and have no arms5 replacement that passed (the brief): each tried in the slot of the arms5 arm with its job
ALT = {'a4-k-bait': 'k5-wake', 'a4-i-kessa2': 'a5-i-kessa-lunge', 'h4-wake': 'h5-wake'}
ALT_ROWS = {'a4-k-bait': {'kh-kenpachi'}}   # (bait was arms4's targeted arm vs Hisagi: KH only, a targeted bar)
H0 = os.path.join(HERE, 'inband/h0.json')   # (Hisagi's arm 0 pick, inband.md §1: {"variant": "on" | "off"}; default on)


def hvariant():
    return json.load(open(H0))['variant'] if os.path.exists(H0) else 'on'


def row_arms(row):
    """ROW, 'ROW@ALT' (an arms4 alternative in its arms5 slot), 'ROW#off' (Hisagi's arms as arms5 built them: :clash-p 0 in every arm)
    or 'ROW#h4' (Hisagi's arm 0 the old h4-all, the job arms clash on) -> (me, vs, arm ids, unit, q, opp, Hisagi's variant)."""
    base, alt, var = row, None, None
    if '@' in base:
        base, alt = base.split('@')
    if '#' in base:
        base, var = base.split('#')
    me, vs, ids, unit, q, opp = ROWS[base]
    ids = list(ids)
    var = var or (hvariant() if me == 'hisagi' else None)
    if var == 'h4':
        ids[0] = 'h4-all'
    if alt:
        ids[ids.index(ALT[alt])] = alt
    return me, vs, ids, unit, q, opp, var


def ref(i, var):
    """An arm id -> its FILE#id (relative to arms4/); Hisagi's h5- arms from arms.lisp (clash off) under the variant 'off'."""
    return f'../arms5/hisagi/arms.lisp#{i}' if var == 'off' and i.startswith('h5-') else ARM[i]


def check_jobs(ids):
    """No rule is in two arms' jobs (a tie T0 would break by index), and every job entry names at least one rule."""
    sw.set_rule_base(':rb-sp2')
    owner = {}
    for k in ids[1:]:
        for g, subs in JOB[k]:
            rs = [r for r, (a, gg) in enumerate(sw.RULES) if gg == g and all(s in a for s in subs)]
            assert rs, f'{k}: job entry {g} {subs} matches no rule'
            for r in rs:
                assert owner.get(r, k) == k, f'rule {r} in the jobs of {owner[r]} and {k}'
                owner[r] = k


def table_of(row, final=False):
    return os.path.join(HERE, 't0' if final else 'inband/t0', f't0-{row.replace("@", "_").replace("#", "_")}.lisp')


def write_table(row, ids=None, out=None, note=''):
    """ROW's T0 (or IDS, a subset of its arms in its order) -> OUT (default the candidate path); its job map beside it (.json)."""
    me, vs, ids0, unit, q, _, var = row_arms(row)
    ids = ids or ids0
    check_jobs(ids)
    out = out or table_of(row)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    mp = out.replace('.lisp', '.json')
    json.dump(dict(note=f'arms5 in-band ({row}{note}): arm 0 {ids[0]}; jobs inband.py JOB', arms=[ref(i, var) for i in ids],
                   jobs=[None] + [JOB[i] for i in ids[1:]]), open(mp, 'w'), indent=1)
    cwd = os.getcwd()
    os.chdir(A4)                       # (proof.py t0 resolves FILE#id against arms4/ and writes there; paths relative to it)
    try:
        proof.cmd_t0(types.SimpleNamespace(me=me, vs=vs, map=os.path.relpath(mp, A4), out=os.path.relpath(out, A4), q=q, or_=True,
                                           with_=[os.path.join('x-units', unit + '.lisp')] if unit else None))
    finally:
        os.chdir(cwd)
    return out, mp


UNIT = {('hisagi', 'kenpachi'): 'd-x-kh-h', ('hisagi', 'ichigo'): 'd-x-ih-h', ('kenpachi', 'hisagi'): 'd-x-kh-k',
        ('ichigo', 'hisagi'): 'd-x-ih-i', ('kenpachi', 'ichigo'): 'd-x-ki-k', ('ichigo', 'kenpachi'): 'd-x-ki-i'}


def one_arm(me, vs, i, var=None):
    """Arm I played whole, as T0 plays an arm (proof.py desc's 1-arm :rb-sp2 table, keep-state, period 30) with the pairing's :with unit
    -> the file (inband/one/)."""
    unit = UNIT.get((me, vs))
    f, aid = ref(i, var).split('#')
    out = os.path.join(HERE, 'inband/one', f'one-{me}-{vs}-{i}{"-off" if var == "off" and i.startswith("h5-") else ""}.lisp')
    os.makedirs(os.path.dirname(out), exist_ok=True)
    proof.write_table(me, vs, [proof.forms(os.path.join(A4, f))[aid]], np.zeros((104, 1)), out, [os.path.join(XU, unit + '.lisp')] if unit else [],
                      f'inband.py: {aid} whole (a 1-arm table, as T0 plays it), :with {unit or "none"}')
    return out


def cmd_tables(a):
    rows = list(ROWS) + [f'{r}@{alt}' for r in ROWS for alt, slot in ALT.items() if slot in ROWS[r][2] and r in ALT_ROWS.get(alt, {r})]
    for r in rows:
        print(write_table(r)[0])


# ---- the sim ----
def pin():
    h = simlib.build_hash(os.path.join(ROOT, 'tools/simgate/strat-run.lisp'))
    want = os.environ.get('SP_BUILD')
    if want and not h.startswith(want):
        sys.exit(f'inband: sim build {h[:12]} is not SP_BUILD {want}')
    return h


KEEP = ('duel gate row ', 'ib ', 'strat ', 'fqend ')


def run(c1, c2, env, seed0, n, runner=RUNNER, keep=KEEP):
    """One sim process (cached by the build, the runners, the env texts and the commands) -> the kept lines."""
    simlib.build()
    texts = {k: (open(v).read() if os.path.isfile(v) else v) for k, v in sorted(env.items())}
    cmds = [30000 + seed0, 31100 + n, 81020 + proof.HARD, 200000 + 100 * c1 + 10 * c2]
    key = hashlib.sha1(json.dumps([simlib.build_hash(os.path.join(ROOT, 'tools/simgate/strat-run.lisp'), os.path.join(ROOT, 'tools', runner)),
                                   texts, cmds, list(keep or ())]).encode()).hexdigest()[:20]
    path = os.path.join(CACHE, key + '.out')
    if os.path.exists(path):
        return open(path).read().splitlines()
    e = {k: v for k, v in os.environ.items() if not k.startswith('STRAT_')}
    e.update(env)
    r = simlib.run_lisp(runner, cmds, e, timeout=7200)
    out = [l for l in r.stdout.splitlines() if l.startswith(keep)] if keep else r.stdout.splitlines()
    rows = sum(l.startswith('duel gate row ') for l in out)
    if r.returncode or rows != n:
        sys.exit(f'inband: sim exited {r.returncode}, {rows} of {n} rows\n' + (r.stdout + r.stderr)[-2000:])
    os.makedirs(CACHE, exist_ok=True)
    with open(path + '.tmp', 'w') as f:
        f.write('\n'.join(out) + '\n')
    os.replace(path + '.tmp', path)
    return out


ROWRE = re.compile(r'duel gate row seed (\d+) \S+ \S+ secs [\d.]+ winner (\S+).* ko ([01])$')


def results(lines, seat):
    """-> {seed: (points for SEAT: 1 / 0.5 / 0, K.O. 0/1, K.O. win 0/1)}"""
    out = {}
    for m in map(ROWRE.search, lines):
        if m:
            w, ko = m[2], int(m[3])
            out[int(m[1])] = (1.0 if w == seat else 0.0 if w in ('P1', 'P2') else 0.5, ko, int(ko == 1 and w == seat))
    return out


def jobs_both(me, vs, mine, theirs, env_of_seat, salts=(None,)):
    """[(seat, salt, c1, c2, env)] for MINE on ME's seat, both seats, each salt."""
    R = ss.ROSTER
    out = []
    for salt in salts:
        for seat in ('P1', 'P2'):
            other = 'P2' if seat == 'P1' else 'P1'
            c1, c2 = (R[me], R[vs]) if seat == 'P1' else (R[vs], R[me])
            out.append((seat, salt, c1, c2, dict(env_of_seat(seat, salt), **{'STRAT_' + seat: mine, 'STRAT_' + other: theirs})))
    return out


def play(jobs, j, runner=RUNNER, keep=KEEP):
    with ThreadPoolExecutor(max(1, min(22, j))) as ex:
        return list(ex.map(lambda x: run(x[2], x[3], x[4], SEED0, SEEDS, runner, keep), jobs))


def cmd_selftest(a):
    """inband-run.lisp without STRAT_INBAND, and with arm k = 0, = strat-run.lisp (every line), on one T0 pairing, seeds 141-150."""
    global SEEDS
    SEEDS = 10
    t1, t2 = table_of('ki-ichigo'), table_of('ki-kenpachi')
    env = {'STRAT_P2': t1, 'STRAT_P1': t2, 'STRAT_FQLOG': '0 0'}
    R = ss.ROSTER
    noise = ('stats:', 'brush:', ';;;')            # (timing, cons and memory lines, and the loader's own name)
    base = [l for l in run(R['kenpachi'], R['ichigo'], env, SEED0, SEEDS, 'simgate/strat-run.lisp', None) if not l.startswith(noise)]
    for extra in ({}, {'STRAT_INBAND': '2 0 7'}):
        got = run(R['kenpachi'], R['ichigo'], dict(env, **extra), SEED0, SEEDS, RUNNER, None)
        got = [l for l in got if not l.startswith(('ib ',) + noise)]
        same = base == got
        print(f'selftest {extra or "unset"}: {len(base)} lines, {"identical" if same else "DIFFER"}')
        if not same:
            sys.exit(1)
    got = run(R['kenpachi'], R['ichigo'], dict(env, STRAT_INBAND='2 2 7'), SEED0, SEEDS, RUNNER, None)
    print(f'selftest arm 2 salt 7: {sum(l.startswith("ib ") for l in got)} ib lines, played {sorted(set(l.split()[4] for l in got if l.startswith("ib ")))}')


def cmd_result(a):
    """MINE (a table / arm file) on ME's seat against THEIRS, seeds 141-180 both seats: points (a draw half), K.O.s, K.O. wins."""
    pin()
    js = jobs_both(a.me, a.vs, os.path.abspath(a.mine), a.theirs if a.theirs == 'none' else os.path.abspath(a.theirs), lambda s, t: {})
    outs = play(js, a.j)
    pts = ko = kow = n = 0
    for (seat, _, *_r), lines in zip(js, outs):
        for p, k, w in results(lines, seat).values():
            pts, ko, kow, n = pts + p, ko + k, kow + w, n + 1
    r = dict(tag=a.tag, me=a.me, vs=a.vs, mine=os.path.relpath(os.path.abspath(a.mine), HERE), theirs=a.theirs if a.theirs == 'none' else os.path.relpath(os.path.abspath(a.theirs), HERE),
             n=n, points=pts, share=round(pts / n, 3), ko_rate=round(ko / n, 3), ko_wins=kow, timeouts=n - ko)
    print(json.dumps(r))
    if a.log:
        with open(a.log, 'a') as f:
            f.write(json.dumps(r) + '\n')


def score(me, vs, mine, theirs, j):
    """MINE on ME's seat against THEIRS (file or none), seeds 141-180 both seats -> n, points share, K.O. rate, K.O. wins, the ids played."""
    js = jobs_both(me, vs, mine, theirs, lambda s, t: {})
    outs = play(js, j)
    pts = ko = kow = n = 0
    ids = set()
    for (seat, *_r), lines in zip(js, outs):
        ids |= {l.split()[2] for l in lines if l.startswith('strat ' + seat)}
        for p, k, w in results(lines, seat).values():
            pts, ko, kow, n = pts + p, ko + k, kow + w, n + 1
    return dict(n=n, share=round(pts / n, 3), ko_rate=round(ko / n, 3), ko_wins=kow, timeouts=n - ko, played=sorted(ids))


def cmd_h0(a):
    """Step 1 (inband.md §1): Hisagi's arm 0 with the clash restored. Whole (1-arm tables with the pairing's unit): h4-all, h5-all (on),
    h5-all (off: :clash-p 0) against Kenpachi's and Ichigo's none and their candidate T0s. The T0 setting: Hisagi's candidate T0 with each
    variant (on: every arm clash on; off: every arm :clash-p 0, as arms5 built them; h4: arm 0 h4-all, job arms on) against the
    opponent's candidate T0; the mirror against itself."""
    pin()
    out = []
    for vs, opp_row in (('kenpachi', 'kh-kenpachi'), ('ichigo', 'ih-ichigo')):
        for i, var in (('h4-all', None), ('h5-all', 'on'), ('h5-all', 'off')):
            f = one_arm('hisagi', vs, i, var)
            for theirs in ('none', table_of(opp_row)):
                r = score('hisagi', vs, f, theirs, a.j)
                out.append(dict(kind='whole', arm=i + ('' if var is None else f' ({var})'), vs=vs, opp='none' if theirs == 'none' else opp_row, **r))
                print(json.dumps(out[-1]), flush=True)
    for row, opp_row, vs in (('kh-hisagi', 'kh-kenpachi', 'kenpachi'), ('ih-hisagi', 'ih-ichigo', 'ichigo'), ('hh-hisagi', None, 'hisagi')):
        for var in ('on', 'off', 'h4'):
            t, _ = write_table(f'{row}#{var}')
            r = score('hisagi', vs, t, table_of(opp_row) if opp_row else t, a.j)
            out.append(dict(kind='t0', row=f'{row}#{var}', opp=opp_row or 'itself', **r))
            print(json.dumps(out[-1]), flush=True)
    with open(os.path.join(HERE, 'inband/h0-results.json'), 'w') as f:
        json.dump(dict(seeds=f'{SEED0 + 1}-{SEED0 + SEEDS} both seats', build=pin()[:12], rows=out), f, indent=1)


DESC_SETS = {   # (character, opponent): the arms whose distinctness is measured, arm 0 first (proof.py desc against his none)
    ('kenpachi', 'ichigo'): ['k5-all'] + KG + ['k5-getsuga'], ('kenpachi', 'hisagi'): ['k5-all'] + KG + ['k5-hug', 'a4-k-bait'],
    ('ichigo', 'kenpachi'): ['a4-i-all'] + IG + ['a4-i-keep', 'a4-i-kessa2'], ('ichigo', 'hisagi'): ['a4-i-all'] + IG + ['a5-i-inside', 'a4-i-kessa2'],
    ('hisagi', 'kenpachi'): ['h5-all'] + HG + ['h5-k1', 'h4-wake'], ('hisagi', 'ichigo'): ['h5-all'] + HG + ['h5-i1', 'h5-ihx', 'h4-wake']}


def cmd_desc(a):
    """Distinctness on seeds 141-180 (proof.py desc, each arm whole against his none, the pairing's unit): one arms file per (me, vs) in
    inband/desc/ (Hisagi's under his picked variant), then proof.py desc into inband/desc/<me>-vs-<vs>.json."""
    d = os.path.join(HERE, 'inband/desc')
    os.makedirs(d, exist_ok=True)
    for (me, vs), ids in DESC_SETS.items():
        if a.only and me not in a.only.split(','):
            continue
        var = hvariant() if me == 'hisagi' else None
        f = os.path.join(d, f'{me}-vs-{vs}.lisp')
        with open(f, 'w') as o:
            o.write(f';;;; inband.py desc: {me} vs {vs}, arm 0 first (refs inband.py ARM{", Hisagi variant " + var if var else ""})\n')
            for i in ids:
                fi, aid = ref(i, var).split('#')
                o.write(proof.forms(os.path.join(A4, fi))[aid] + '\n')
        r = subprocess.run([sys.executable, os.path.join(A4, 'proof.py'), 'desc', '--me', me, '--vs', vs, '--arms', os.path.relpath(f, A4),
                            '--with', os.path.join(XU, UNIT[(me, vs)] + '.lisp'), '--seed0', str(SEED0), '--seeds', str(SEEDS), '-j', str(a.j),
                            '--out', f.replace('.lisp', '.json')], capture_output=True, text=True, cwd=A4)
        if r.returncode:
            sys.exit(r.stdout[-2000:] + r.stderr[-2000:])
        print(r.stdout, flush=True)


def table_path(row, final):
    return table_of(row, final)


def cmd_ib(a):
    """The in-band test of arm index K of ROW's table, inside it, against the opponent row's table (both candidate, or --final)."""
    h = pin()
    me, vs, ids, _, _, opp, _ = row_arms(a.row)
    mine, theirs = table_path(a.row, a.final), table_path(a.opp or opp, a.final)
    k = ids.index(a.arm) if a.arm in ids else int(a.arm)
    salts = range(1, a.salts + 1)
    js = jobs_both(me, vs, mine, theirs, lambda seat, salt: {'STRAT_INBAND': f'{seat[1]} {k} {salt} {a.p}',
                                                             'STRAT_FQLOG': f'0 0 {seat[1]}'}, salts)   # (eps 0: play unchanged; for fqend)
    outs = play(js, a.j)
    ms, seen = [], set()
    for (seat, salt, *_r), lines in zip(js, outs):
        res = results(lines, seat)
        seq, mg = {}, {}
        for l in lines:
            if l.startswith('fqend ') and l.split()[2] == seat:
                p = l.split()
                mg[int(p[1])] = float(p[4]) - float(p[6])
            if l.startswith('ib '):
                p = l.split()
                if p[3] == seat:
                    seq.setdefault(int(p[1]), []).append((int(p[2]), int(p[4])))
        for sd, (y, ko, kow) in res.items():
            sq = tuple(seq.get(sd, ()))
            # the sim is deterministic: a match is fixed by (seed, seat) and the coins it drew, so salts that drew the same coins replayed
            # the same match; it counts once (else a job with one run a match would be counted salts times over)
            if (sd, seat, sq) in seen:
                continue
            seen.add((sd, seat, sq))
            ms.append(dict(seed=sd, seat=seat, salt=salt, y=y, ko=ko, margin=mg.get(sd), n=len(sq),
                           s=sum(x == k for _, x in sq) / len(sq) if sq else None))
    r = analyse(ms)
    r.update(row=a.row, arm=ids[k], k=k, targeted=ids[k] in TARGETED, opp=a.opp or opp, salts=a.salts, p=a.p, run_matches=len(outs) * SEEDS,
             seeds=f'{SEED0 + 1}-{SEED0 + SEEDS}', build=h[:12], final=a.final)
    r['mde'] = round(2 * r['se'], 3) if r.get('se') else None
    r['pass'] = (r['z'] is not None) and (r['z'] >= 2 if r['targeted'] else r['z'] > -2)
    print(json.dumps(r))
    out = a.out or os.path.join(HERE, 'inband/ib.jsonl')
    with open(out, 'a') as f:
        f.write(json.dumps(r) + '\n')


def fe_slope(use, key):
    """The OLS slope of m[KEY] on m['s'] with a fixed effect per (seed, seat), its se (classical, dof = n - groups - 1) and z. A KEY with
    no variance inside any group (e.g. every match lost) gives slope 0, se 0 and z 0 (nothing the game's result can show)."""
    g = {}
    for m in use:
        g.setdefault((m['seed'], m['seat']), []).append(m)
    ys, ss_, G = [], [], 0
    for v in g.values():
        if len(v) < 2:
            continue
        G += 1
        my, msx = statistics.fmean(m[key] for m in v), statistics.fmean(m['s'] for m in v)
        ys += [m[key] - my for m in v]; ss_ += [m['s'] - msx for m in v]
    y, s = np.array(ys), np.array(ss_)
    sxx = float(s @ s) if len(s) else 0.0
    if sxx <= 1e-9:
        return dict(groups=G, slope=None, se=None, z=None)
    b = float(s @ y) / sxx
    res = y - b * s
    se = (float(res @ res) / max(1, len(y) - G - 1) / sxx) ** 0.5
    if se == 0:
        return dict(groups=G, slope=round(b, 3), se=0.0, z=0.0, no_variance=True)
    return dict(groups=G, slope=round(b, 3), se=round(se, 3), z=round(b / se, 2))


def analyse(ms):
    """Per (distinct) match: y = ME's points (1 / 0.5 / 0), s = arm k's share of its pick-K judgements, margin = ME's mc-full-health
    minus his at the match's end (fqend; report only). The in-band effect = fe_slope(y); also the raw means of y for matches with s >= 0.5
    and s < 0.5, and how many matches carried the test."""
    use = [m for m in ms if m['s'] is not None]
    out = dict(matches=len(ms), used=len(use), with_job_share=round(len(use) / max(1, len(ms)), 3),
               job_judgements=round(statistics.fmean(m['n'] for m in use), 1) if use else 0,
               points=round(statistics.fmean(m['y'] for m in ms), 3) if ms else None)
    if len(use) < 10:
        return dict(out, slope=None, se=None, z=None)
    out.update(fe_slope(use, 'y'))
    sec = fe_slope([m for m in use if m.get('margin') is not None], 'margin')
    out.update(margin_slope=sec['slope'], margin_z=sec['z'])
    hi, lo = [m['y'] for m in use if m['s'] >= 0.5], [m['y'] for m in use if m['s'] < 0.5]
    return dict(out, mean_s=round(statistics.fmean(m['s'] for m in use), 3),
                y_k_major=round(statistics.fmean(hi), 3) if hi else None, n_k_major=len(hi),
                y_0_major=round(statistics.fmean(lo), 3) if lo else None, n_0_major=len(lo))


def cmd_bar(a):
    """proof.py bar for ROW against its opponent row (mirrors: itself), seeds 141-180; writes inband/bar/ (or arms5/t0/bar/ with --final)."""
    pin()
    me, vs, _, _, _, opp, _ = row_arms(a.row)
    d = os.path.join(HERE, 't0/bar' if a.final else 'inband/bar')
    os.makedirs(d, exist_ok=True)
    t1, t2 = table_path(a.row, a.final), table_path(a.opp or opp, a.final)
    m1, m2 = (t.replace('.lisp', '.json') for t in (t1, t2))
    out = os.path.join(d, f'bar-{a.row.replace("@", "_").replace("#", "_")}' + (f'-vs-{a.opp.replace("@", "_").replace("#", "_")}' if a.opp else '') + '.json')
    r = subprocess.run([sys.executable, os.path.join(A4, 'proof.py'), 'bar', '--p1', os.path.relpath(t1, A4), '--p1map', os.path.relpath(m1, A4),
                        '--p2', os.path.relpath(t2, A4), '--p2map', os.path.relpath(m2, A4), '--c1', me, '--c2', vs,
                        '--seeds', f'{SEED0 + 1}-{SEED0 + SEEDS}', '-j', str(a.j)], capture_output=True, text=True)
    if r.returncode:
        sys.exit(r.stdout[-2000:] + r.stderr[-2000:])
    j = json.loads(r.stdout)
    # the same matches again (proof.py's cache: same env texts and commands): ME's points by the game's result and, per arm, its runs
    # (maximal stretches of consecutive judgements it held) a match: what the in-band test randomises (inband.md §3, power)
    res = proof.both_seats(me, vs, t1, t2, SEED0, SEEDS, {'STRAT_FQLOG': '0 0'}, a.j)
    pts, n, runs, held, nm = 0.0, 0, {}, {}, {}
    for seat, lines in res.items():
        for p_, _, _ in results(lines, seat).values():
            pts, n = pts + p_, n + 1
        seq = {}
        for l in lines:
            m = proof.FQRE.match(l)
            if m and m[3] == seat:
                seq.setdefault(int(m[1]), []).append(int(m[4]))
        for s_ in seq.values():
            for k in set(s_):
                rk = sum(1 for x in range(len(s_)) if s_[x] == k and (x == 0 or s_[x - 1] != k))
                runs[k] = runs.get(k, 0) + rk; held[k] = held.get(k, 0) + s_.count(k); nm[k] = nm.get(k, 0) + 1
    s = j['sides']['c1 ' + me]
    s['points'] = round(pts / max(1, n), 3)
    s['runs'] = {k: dict(runs_per_match=round(runs[k] / max(1, n), 2), matches_with=round(nm[k] / max(1, n), 3),
                         judgements_per_run=round(held[k] / max(1, runs[k]), 1)) for k in sorted(runs)}
    open(out, 'w').write(json.dumps(j, indent=1))
    print(f"{a.row}: points {s['points']} changes {s['changes']} shares {s['arm_share']} K.O. {s['ko_rate']} A {s['A']} runs {s['runs']} " +
          ' '.join(f"{k}:{v['in_share']}/{v['out_share']} f{v['fire_share']}" for k, v in s['job'].items()))


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest='cmd', required=True)
    sub.add_parser('tables')
    sub.add_parser('selftest')
    p = sub.add_parser('h0'); p.add_argument('-j', type=int, default=12)
    p = sub.add_parser('desc'); p.add_argument('--only'); p.add_argument('-j', type=int, default=12)
    p = sub.add_parser('result')
    p.add_argument('--me', required=True); p.add_argument('--vs', required=True); p.add_argument('--mine', required=True)
    p.add_argument('--theirs', required=True); p.add_argument('--tag', default=''); p.add_argument('--log'); p.add_argument('-j', type=int, default=20)
    p = sub.add_parser('ib')
    p.add_argument('--row', required=True); p.add_argument('--arm', required=True); p.add_argument('--opp')
    p.add_argument('--salts', type=int, default=20); p.add_argument('--p', type=float, default=0.9); p.add_argument('--final', action='store_true')
    p.add_argument('--out')
    p.add_argument('-j', type=int, default=20)
    p = sub.add_parser('bar')
    p.add_argument('--row', required=True); p.add_argument('--opp'); p.add_argument('--final', action='store_true'); p.add_argument('-j', type=int, default=20)
    a = ap.parse_args()
    {'tables': cmd_tables, 'selftest': cmd_selftest, 'h0': cmd_h0, 'desc': cmd_desc, 'result': cmd_result, 'ib': cmd_ib, 'bar': cmd_bar}[a.cmd](a)


if __name__ == '__main__':
    main()

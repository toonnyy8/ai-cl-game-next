#!/usr/bin/env python3
"""duct.py — DUCT, the strength anchor (PLAN4 §6, steps D1-D2; the user, 2026-11-15: 「然後以 DUCT 作為強度錨點」). PROVISIONAL until
ANCHOR.md freezes it (sp/duct/README-provisional.md).

  python3 docs/research/strategy-drsi/sp/duct.py arms                 the arms, the pairing's exchange unit laid under each (sp/duct/arms/)
  python3 docs/research/strategy-drsi/sp/duct.py matrix --pair ki     each arm pair played whole, block 200 (seeds 201-300), both seats
  python3 docs/research/strategy-drsi/sp/duct.py anchor --pair ki     sp/duct/anchor-<pair>.lisp from the arms and the matrix
  python3 docs/research/strategy-drsi/sp/duct.py budget               D1: today's vs standard (vs heavy), DUCT against DUCT, KI + KH
  python3 docs/research/strategy-drsi/sp/duct.py fingerprint [--out F] DUCT against DUCT, seeds 181-200, nine rows
  python3 docs/research/strategy-drsi/sp/duct.py d2 [--tier name=dir ...]  D2: DUCT vs DUCT and each tier vs DUCT, seeds 501-550, both seats

Pairs (roster order K I H): kk ki kh ii ih hh; an anchor file holds both sides, so rows KI and IK read anchor-ki.lisp. A match's result
is the game's own (a K.O., or at the bell more Konpaku, then Reishi %; a draw half), as the payoff the strategy layer reads
(strat-seed-value: B's view is 1 - M, zero-sum); the K.O. counts are kept beside it. Every match runs tools/simgate/duct-run.lisp
(strat-run.lisp unchanged plus the per-seat budget and the arm counters), cached in build/duct-cache/ by every env text and the hashes.
Seeds above 600 are refused (601-800 spent, 801-1000 the final's). Env SP_BUILD: refuse another sim build (strategy-switch.py's hash).
"""
import argparse, hashlib, importlib.util, json, os, re, subprocess, sys, tempfile, time
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
from simlib import ECL, FAS, ROW, build, pool, row_ko
_p = importlib.util.spec_from_file_location('sppop', os.path.join(HERE, 'pop.py'))
pop = importlib.util.module_from_spec(_p); _p.loader.exec_module(pop)
ss = pop.ss

D = os.path.join(HERE, 'duct')
A4 = os.path.join(HERE, 'arms4')
CACHE = os.path.join(ROOT, 'build/duct-cache')
RUNNER = os.path.join(ROOT, 'tools/simgate/duct-run.lisp')
HOOK = os.path.join(ROOT, 'tools/simgate/duct-hook.lisp')
NAME = {'K': 'kenpachi', 'I': 'ichigo', 'H': 'hisagi'}
IDX = {'K': 1, 'I': 3, 'H': 7}
PAIRS = ['kk', 'ki', 'kh', 'ii', 'ih', 'hh']
ROWS9 = [a + b for a in 'KIH' for b in 'KIH']
CHUNK = 25
# the admitted arms (PLAN4 checkpoint B3; arms4/*.md): general arms of every pairing, then the pairing's targeted ones
GEN = {'K': ['all', 'spend', 'climb'], 'I': ['all', 'brawl', 'keep', 'kessa2'], 'H': ['all', 'range', 'wake']}
TARGETED = {('K', 'H'): ['bait'], ('H', 'K'): ['hoho6'], ('H', 'I'): ['ihx']}
BUDGETS = {'today': (8, 150, 90), 'standard': (16, 240, 90), 'heavy': (32, 300, 60)}   # rolls x steps, period (PLAN4 §6 D1)


def sha(b):
    return hashlib.sha256(b).hexdigest()


def fsha(p):
    return sha(open(p, 'rb').read())


def letters(pair):
    return pair[0].upper(), pair[1].upper()


def pair_of(x, y):
    return ''.join(sorted((x, y), key='KIH'.index)).lower()


def arm_src(c, arm):
    """(file, id) of character C's arm."""
    if c == 'K':
        return os.path.join(A4, 'kenpachi.lisp'), f':a4-k-{arm}'
    if c == 'I':
        return os.path.join(A4, 'ichigo.lisp'), f':a4-i-{arm}'
    return os.path.join(A4, 'cells-h/final', f'h4-{arm}.lisp'), f':h4-{arm}'   # (the cells' picks: wake, hoho6, ihx; all, range = drafts)


def arm_names(pair, c):
    a, b = letters(pair)
    o = b if c == a else a
    return GEN[c] + TARGETED.get((c, o), [])


def arm_file(pair, c, arm):
    return os.path.join(D, 'arms', f'{pair}-{c.lower()}-{arm}.lisp')


def unit_file(pair, c):
    a, b = letters(pair)
    return None if a == b else os.path.join(A4, 'x-units', f'd-x-{pair}-{c.lower()}.lisp')


def check_build():
    build()
    want = os.environ.get('SP_BUILD')
    h = ss.build_hash()
    if want and not h.startswith(want):
        sys.exit(f'duct: sim build {h[:12]} is not SP_BUILD {want}')
    return h


# ------------------------------------------------------------------ the sim job
def job(spec):
    """One duct-run.lisp process. SPEC = (c1, c2, s0, n, env dict) -> parsed output (cached)."""
    c1, c2, s0, n, env = spec
    if s0 + n > 600 or s0 < 0 or n > 99:
        sys.exit(f'duct: seeds {s0 + 1}-{s0 + n} refused (dev seeds 1-600 only; 601-800 spent, 801-1000 the final)')
    texts = {k: (open(v).read() if k in ('STRAT_P1', 'STRAT_P2', 'STRAT_ANCHOR') and v not in ('', 'none') else v) for k, v in env.items()}
    key = sha(json.dumps([c1, c2, s0, n, sorted(texts.items()), fsha(FAS), fsha(ss.RUNNER), fsha(RUNNER), fsha(HOOK)]).encode())
    path = os.path.join(CACHE, key + '.json')
    if os.path.exists(path) and not os.environ.get('DUCT_NOCACHE'):   # (DUCT_NOCACHE=1: rerun, e.g. the fingerprint's second run)
        return json.load(open(path))
    full = dict(os.environ)
    for k in ('STRAT_P1', 'STRAT_P2', 'STRAT_LAYER', 'STRAT_SET', 'STRAT_ANCHOR', 'STRAT_WIN', 'STRAT_DIF_P1', 'STRAT_DIF_P2',
              'DUCT_BUDGET_P1', 'DUCT_BUDGET_P2', 'DUCT_NOCACHE', 'STRAT_FQLOG', 'STRAT_FQLEARN', 'STRAT_HRANGE', 'STRAT_DESC'):
        full.pop(k, None)
    full.update(env)
    cmds = [30000 + s0, 31100 + n, 81022, 200000 + 100 * c1 + 10 * c2]
    with tempfile.TemporaryFile('w+') as out, open(os.devnull) as nul:
        p = subprocess.Popen([ECL, '--norc', '--load', RUNNER, '--', FAS] + [str(c) for c in cmds], cwd=ROOT, env=full,
                             stdin=nul, stdout=out, stderr=subprocess.STDOUT, text=True)
        t0 = time.time()
        _, status, ru = os.wait4(p.pid, 0)
        p.returncode = os.waitstatus_to_exitcode(status)
        wall = time.time() - t0
        out.seek(0); text = out.read()
    rows = []
    for line in text.splitlines():
        m = ROW.search(line)
        if m:
            rows.append([int(m[1]), m[2], row_ko(line)])
    if p.returncode or len(rows) != n or any(r[2] is None for r in rows):
        sys.exit(f'duct: job {c1}/{c2} seeds {s0 + 1}-{s0 + n} env {env}: exit {p.returncode}, {len(rows)} rows of {n}\n{text[-2500:]}')
    keep = lambda pre: [l for l in text.splitlines() if l.startswith(pre)]
    res = dict(c1=c1, c2=c2, s0=s0, n=n, env=env, rows=rows, hash=keep('duel hash'), layer=keep('duel stratlayer'), duct=keep('duct '),
               switch=keep('switch '), strat=keep('strat '), anchor=keep('anchor '), cpu_s=round(ru.ru_utime + ru.ru_stime, 2), wall_s=round(wall, 2))
    os.makedirs(CACHE, exist_ok=True)
    tmp = f'{path}.{os.getpid()}.tmp'
    json.dump(res, open(tmp, 'w')); os.replace(tmp, path)
    return res


def chunks(s0, n, size=CHUNK):
    return [(s0 + k, min(size, n - k)) for k in range(0, n, size)]


def score(res_list, seat):
    """Game-result points of SEAT ('P1'/'P2') over jobs -> dict(n, pts, wins, losses, draws, ko_w, ko_l, bell)."""
    c = dict(n=0, pts=0.0, wins=0, losses=0, draws=0, ko_w=0, ko_l=0, bell=0)
    for r in res_list:
        for _, w, ko in r['rows']:
            c['n'] += 1; c['bell'] += 1 - ko
            if w == seat:
                c['wins'] += 1; c['pts'] += 1; c['ko_w'] += ko
            elif w == 'DRAW':
                c['draws'] += 1; c['pts'] += 0.5
            else:
                c['losses'] += 1; c['ko_l'] += ko
    return c


def add(a, b):
    return {k: a[k] + b[k] for k in a}


# ------------------------------------------------------------------ arms
def cmd_arms(o):
    check_build()
    os.makedirs(os.path.join(D, 'arms'), exist_ok=True)
    spec = []
    for pair in PAIRS:
        a, b = letters(pair)
        for c in dict.fromkeys((a, b)):
            for arm in arm_names(pair, c):
                f, i = arm_src(c, arm)
                u = unit_file(pair, c)
                opp = b if c == a else a
                r = lambda q: os.path.relpath(q, ROOT)
                spec.append(f'("{r(arm_file(pair, c, arm))}" "{r(f)}" {i} {f"{chr(34)}{r(u)}{chr(34)}" if u else "nil"} '
                            f':dc-{pair}-{c.lower()}-{arm} (:{NAME[c]} :{NAME[opp]}))')
    with tempfile.NamedTemporaryFile('w', suffix='.lisp', delete=False) as t:
        t.write('\n'.join(spec) + '\n')
    r = subprocess.run([ECL, '--norc', '--load', os.path.join(D, 'write-arms.lisp'), '--', FAS, t.name], cwd=ROOT, capture_output=True, text=True)
    os.unlink(t.name)
    if r.returncode:
        sys.exit(r.stdout[-2000:] + r.stderr[-2000:])
    print(f'{len(spec)} arm files in {os.path.relpath(os.path.join(D, "arms"), ROOT)}')


def arm_plist(path):
    return ss.strip_lisp(open(path).read()).strip()


# ------------------------------------------------------------------ matrix
def cmd_matrix(o):
    h = check_build()
    for pair in o.pair.split(','):
        a, b = letters(pair)
        ra, cb = arm_names(pair, a), arm_names(pair, b)
        mirror = a == b
        cells = [(i, k) for i in range(len(ra)) for k in range(len(cb)) if not mirror or i <= k]
        specs, tags = [], []
        for i, k in cells:
            fa, fb = arm_file(pair, a, ra[i]), arm_file(pair, b, cb[k])
            for seat in ('P1', 'P2'):
                c1, c2 = (IDX[a], IDX[b]) if seat == 'P1' else (IDX[b], IDX[a])
                env = {'STRAT_P1': fa, 'STRAT_P2': fb} if seat == 'P1' else {'STRAT_P1': fb, 'STRAT_P2': fa}
                for s0, n in chunks(o.seed0, o.seeds):
                    specs.append((c1, c2, s0, n, env)); tags.append((i, k, seat))
        t0 = time.time()
        outs = pool(job, specs, o.j)
        acc = {}
        for (i, k, seat), r in zip(tags, outs):
            c = score([r], seat)
            acc[(i, k)] = add(acc[(i, k)], c) if (i, k) in acc else c
        n_a, n_b = len(ra), len(cb)
        M = [[None] * n_b for _ in range(n_a)]
        cellrec = []
        for (i, k), c in acc.items():
            M[i][k] = c['pts'] / c['n']
            cellrec.append(dict(row=ra[i], col=cb[k], **c))
            if mirror and i != k:                                    # (cell (k,i) is the same matches seen from the other side)
                M[k][i] = 1 - M[i][k]
        import numpy as np
        MA = np.array(M, dtype=float)
        if mirror:
            assert all(abs(MA[i, i] - 0.5) < 1e-9 for i in range(n_a)), f'{pair}: a mirror diagonal is not 0.5: {np.diag(MA)}'
        x, y, ga, gb = pop.solve(MA, 1 - MA, o.iters)
        out = dict(pair=pair, a=NAME[a], b=NAME[b], rows=ra, cols=cb, seeds=f'{o.seed0 + 1}-{o.seed0 + o.seeds}', both_seats=True,
                   matches_a_cell=2 * o.seeds, payoff="A's game-result share (K.O. or the bell's lead; a draw half); B's = 1 - M",
                   M=np.round(MA, 4).tolist(), x=np.round(x, 3).tolist(), y=np.round(y, 3).tolist(), value=round(float(x @ MA @ y), 4),
                   gap_a=round(ga, 4), gap_b=round(gb, 4), cells=cellrec, build=h, wall_s=round(time.time() - t0, 1),
                   cpu_s=round(sum(r['cpu_s'] for r in outs), 1))
        json.dump(out, open(os.path.join(D, f'matrix-{pair}.json'), 'w'), indent=1)
        print(f'{pair}: {NAME[a]} rows x {NAME[b]} cols, A share (game result); cpu {out["cpu_s"]} s, wall {out["wall_s"]} s')
        print(' ' * 10 + ''.join(f'{c:>9}' for c in cb))
        for i, r in enumerate(ra):
            ko = [next((c for c in cellrec if c['row'] == r and c['col'] == cb[k]), None) for k in range(n_b)]
            print(f'{r:10}' + ''.join(f'{MA[i, k]:9.3f}' for k in range(n_b)) + '   K.O. A:B ' +
                  ' '.join(f"{c['ko_w']}:{c['ko_l']}" if c else '(mirror)' for c in ko))
        print(f'x {dict(zip(ra, out["x"]))}  y {dict(zip(cb, out["y"]))}  value {out["value"]}  gaps {out["gap_a"]} {out["gap_b"]}')


# ------------------------------------------------------------------ anchor
def anchor_file(pair):
    return os.path.join(D, f'anchor-{pair}.lisp')


def cmd_anchor(o):
    for pair in o.pair.split(','):
        a, b = letters(pair)
        mx = json.load(open(os.path.join(D, f'matrix-{pair}.json')))
        ra, cb = arm_names(pair, a), arm_names(pair, b)
        assert mx['rows'] == ra and mx['cols'] == cb
        lib = [arm_plist(arm_file(pair, a, x)) for x in ra] + ([] if a == b else [arm_plist(arm_file(pair, b, x)) for x in cb])
        ids = lambda c, xs: ' '.join(f':dc-{pair}-{c.lower()}-{x}' for x in xs)
        f4 = lambda v: ' '.join(f'{float(z):.4f}' for z in v)
        m = ' '.join(f'({f4(r)})' for r in mx['M'])
        hdr = (f";; anchor-{pair}.lisp — DUCT's anchor for {NAME[a]} vs {NAME[b]} (PLAN4 §6; STRAT_ANCHOR, tools/simgate/strat-run.lisp). PROVISIONAL: not frozen\n"
               f";; (sp/duct/README-provisional.md). Written by sp/duct.py anchor. Library: each side's admitted arms (arms4/*.md), the pairing's exchange\n"
               f";; unit laid under each (STRAT-WITH; sp/duct/arms/). Payoff: {NAME[a]}'s game-result share, each arm pair played whole, seeds\n"
               f";; {mx['seeds']}, both seats, {mx['matches_a_cell']} matches a cell (sp/duct/matrix-{pair}.json), and its zero-sum equilibrium mixes x / y.\n"
               f";; Sim build {mx['build'][:12]}.\n")
        body = (f"(:library\n (" + '\n  '.join(lib) + f")\n :payoff\n ((:{NAME[a]} :{NAME[b]} ({ids(a, ra)}) ({ids(b, cb)})\n   ({m})\n"
                f"   ({f4(mx['x'])}) ({f4(mx['y'])}))))\n")
        open(anchor_file(pair), 'w').write(hdr + body)
        print('->', os.path.relpath(anchor_file(pair), ROOT))


# ------------------------------------------------------------------ DUCT runs
def row_specs(x, y, tier, s0, n, budget=None, seat_budgets=None, csize=CHUNK):
    """Jobs for row X (the tier's character) vs Y (DUCT), both seats -> [(spec, seat of X)]. TIER: 'duct' (DUCT on both seats) or a strategy
    file for X's seat. BUDGET (rolls, h, period) for every DUCT seat by STRAT_SET; SEAT_BUDGETS {'x': b, 'y': b} per character."""
    out = []
    for xs in ('P1', 'P2'):
        ys = 'P2' if xs == 'P1' else 'P1'
        c1, c2 = (IDX[x], IDX[y]) if xs == 'P1' else (IDX[y], IDX[x])
        env = {'STRAT_ANCHOR': anchor_file(pair_of(x, y))}
        if tier == 'duct':
            env['STRAT_LAYER'] = 't'
        else:
            env['STRAT_LAYER'] = ys; env['STRAT_' + xs] = tier
        if budget:
            env['STRAT_SET'] = f'*strat-rolls*={budget[0]},*strat-h*={budget[1]},*strat-period*={budget[2]}'
        if seat_budgets:
            env['DUCT_BUDGET_' + xs] = ' '.join(map(str, seat_budgets['x']))
            env['DUCT_BUDGET_' + ys] = ' '.join(map(str, seat_budgets['y']))
        for a, k in chunks(s0, n, csize):
            out.append(((c1, c2, a, k, env), xs))
    return out


def run_rows(plan, j):
    """PLAN = [(tag, [(spec, seat)])] -> {tag: (score of the tagged side, [results with seat])}."""
    flat = [(t, sp, se) for t, lst in plan for sp, se in lst]
    outs = pool(lambda z: job(z[1]), flat, j)
    res = {}
    for (t, _, se), r in zip(flat, outs):
        c = score([r], se)
        if t in res:
            res[t] = (add(res[t][0], c), res[t][1] + [(r, se)])
        else:
            res[t] = (c, [(r, se)])
    return res


LAYER = re.compile(r'duel stratlayer selections (\d+) rollouts (\d+) ms (\S+) a selection, worst step (\S+) picks P1 ([\d ]*) P2 ([\d ]*)')
DUCTL = re.compile(r'duct (\d+) (P[12]) changes (\d+) held(.*)')


def switching(results, seat_of_duct):
    """Per DUCT side: matches, selections done (picks), arm changes and steps held per arm id. RESULTS = [(job, seat of the tier's
    character)]; SEAT_OF_DUCT(seat) -> the DUCT seats to read."""
    sel, chg, held, nm, ms = [], [], {}, 0, []
    for r, se in results:
        seats = seat_of_duct(se)
        for line in r['layer']:
            m = LAYER.search(line)
            ms.append(float(m[3]))
            for s in seats:
                sel.append(sum(int(v) for v in (m[5] if s == 'P1' else m[6]).split()))
        for line in r['duct']:
            m = DUCTL.match(line)
            if m[2] in seats:
                chg.append(int(m[3])); nm += 1
                for kv in m[4].split():
                    k, v = kv.rsplit(':', 1); held[k] = held.get(k, 0) + int(v)
    tot = sum(held.values()) or 1
    med = lambda v: sorted(v)[len(v) // 2] if v else None
    return dict(sides=nm, sel_mean=round(sum(sel) / max(1, len(sel)), 1), changes_mean=round(sum(chg) / max(1, len(chg)), 2),
                changes_median=med(chg), no_change=sum(c == 0 for c in chg), ms_selection=round(sum(ms) / max(1, len(ms)), 2),
                shares={k: round(v / tot, 3) for k, v in sorted(held.items(), key=lambda kv: -kv[1])})


def cmd_budget(o):
    h = check_build()
    order = ['today', 'standard', 'heavy']
    plan_split = [('K', 'I', 0, 100), ('K', 'H', 100, 100)]          # pre-registered: KI seeds 1-100, KH seeds 101-200, new on each seat
    rec = dict(rule='take the cheapest setting the next one does not beat at >= 55 % of 400 (>= 220 points)', split='KI seeds 1-100 + KH seeds '
               '101-200; the newer budget on P1, then on P2 (gate order K first); game result, a draw half', build=h, comparisons=[])
    choice = None
    for lo, hi in zip(order, order[1:]):
        plan = []
        for x, y, s0, n in plan_split:                                 # (x on P1 always: the gate K first; the budgets swap seats)
            for new_seat in ('P1', 'P2'):
                env = {'STRAT_ANCHOR': anchor_file(pair_of(x, y)), 'STRAT_LAYER': 't',
                       'DUCT_BUDGET_' + new_seat: ' '.join(map(str, BUDGETS[hi])),
                       'DUCT_BUDGET_' + ('P2' if new_seat == 'P1' else 'P1'): ' '.join(map(str, BUDGETS[lo]))}
                plan.append(((x + y, new_seat), [((IDX[x], IDX[y], a, k, env), new_seat) for a, k in chunks(s0, n)]))
        t0 = time.time()
        res = run_rows(plan, o.j)
        tot = None
        rows = {}
        for (pr, seat), (c, rl) in res.items():
            rows[f'{pr} new on {seat}'] = dict(c, share=round(c['pts'] / c['n'], 3), cpu_s_match=round(sum(r['cpu_s'] for r, _ in rl) / c['n'], 2))
            tot = add(tot, c) if tot else c
        share = tot['pts'] / tot['n']
        cmp_ = dict(new=hi, old=lo, new_budget=BUDGETS[hi], old_budget=lo and BUDGETS[lo], n=tot['n'], new_points=tot['pts'],
                    new_share=round(share, 4), beats=tot['pts'] >= 0.55 * tot['n'], rows=rows, wall_s=round(time.time() - t0, 1),
                    cpu_s_match=round(sum(r['cpu_s'] for _, (c, rl) in res.items() for r, _ in rl) / tot['n'], 2))
        rec['comparisons'].append(cmp_)
        print(f"{hi} vs {lo}: {tot['pts']} of {tot['n']} = {share:.3f} ({'beats' if cmp_['beats'] else 'does not beat'}); "
              f"cpu {cmp_['cpu_s_match']} s a match (both seats DUCT)")
        for k, v in rows.items():
            print(f"  {k:16} {v['pts']:5} / {v['n']}  K.O. {v['ko_w']}:{v['ko_l']} bell {v['bell']}  cpu {v['cpu_s_match']} s/match")
        if not cmp_['beats']:
            choice = lo
            break
    rec['choice'] = choice or 'heavy'
    # every setting's own cost: DUCT against DUCT at one budget on both seats, KI seeds 1-20 (P1 K), a cost probe only
    rec['cost'] = {}
    for b in order:
        res = run_rows([(b, row_specs('K', 'I', 'duct', 0, 20, budget=BUDGETS[b]))], o.j)[b]
        rl = res[1]
        rec['cost'][b] = dict(matches=res[0]['n'], cpu_s_match=round(sum(r['cpu_s'] for r, _ in rl) / res[0]['n'], 2),
                              **switching(rl, lambda se: ['P1', 'P2']))
        print(f"cost {b}: {rec['cost'][b]['cpu_s_match']} CPU-s a match (two DUCT seats, KI 1-20), "
              f"{rec['cost'][b]['ms_selection']} ms a selection, {rec['cost'][b]['sel_mean']} selections a side and match")
    json.dump(rec, open(os.path.join(D, 'budget-provisional.json'), 'w'), indent=1)
    print('choice', rec['choice'])


def chosen_budget():
    return BUDGETS[json.load(open(os.path.join(D, 'budget-provisional.json')))['choice']]


def cmd_fingerprint(o):
    h = check_build()
    b = BUDGETS[o.budget] if o.budget else chosen_budget()
    lines = [f'# DUCT fingerprint (PLAN4 §6), PROVISIONAL: DUCT against DUCT, seeds 181-200, nine rows (P1 character first), budget '
             f'rolls {b[0]} x steps {b[1]}, period {b[2]}; build {h[:16]} (fas {fsha(FAS)[:16]}, strat-run.lisp {fsha(ss.RUNNER)[:16]})']
    for p in PAIRS:
        lines.append(f'# anchor-{p}.lisp sha256 {fsha(anchor_file(p))[:16]}')
    specs = [((IDX[x], IDX[y], 180, 20, {'STRAT_ANCHOR': anchor_file(pair_of(x, y)), 'STRAT_LAYER': 't',
                                         'STRAT_SET': f'*strat-rolls*={b[0]},*strat-h*={b[1]},*strat-period*={b[2]}'}), x + y) for x, y in ROWS9]
    outs = pool(lambda z: job(z[0]), specs, o.j)
    for (_, row), r in zip(specs, outs):
        lines.append(f'## row {row}')
        lines += [f'duel gate row seed {s} winner {w} ko {k}' for s, w, k in r['rows']] + r['hash']
    text = '\n'.join(lines) + '\n'
    open(o.out, 'w').write(text)
    print(f'{os.path.relpath(o.out, ROOT)}: {sum(1 for l in lines if l.startswith("duel gate"))} rows, {sum(1 for l in lines if l.startswith("duel hash"))} hash lines')


def cmd_d2(o):
    h = check_build()
    b = BUDGETS[o.budget] if o.budget else chosen_budget()
    tiers = [('duct', None)] + [tuple(t.split('=', 1)) for t in o.tier]
    plan = []
    for name, src in tiers:
        for x, y in ROWS9:
            f = 'duct' if name == 'duct' else os.path.join(src, f'{pair_of(x, y)}-{NAME[x]}.lisp')
            if f != 'duct' and not os.path.exists(f):
                sys.exit(f'duct: no table {f}')
            plan.append(((name, x + y), row_specs(x, y, f, o.seed0, o.seeds, budget=b, csize=o.chunk)))
    res = run_rows(plan, o.j)
    rec = dict(seeds=f'{o.seed0 + 1}-{o.seed0 + o.seeds}', both_seats=True, budget=b, build=h, tiers={n: s for n, s in tiers}, rows={})
    print(f'D2 seeds {rec["seeds"]}, both seats, game result (a draw half); share of the row character (tier) against DUCT on the other one')
    print('row | ' + ' | '.join(f'{n:>22}' for n, _ in tiers))
    pooled = {n: None for n, _ in tiers}
    for x, y in ROWS9:
        cols = []
        for n, _ in tiers:
            c, rl = res[(n, x + y)]
            pooled[n] = add(pooled[n], c) if pooled[n] else c
            p1 = score([r for r, se in rl if se == 'P1'], 'P1'); p2 = score([r for r, se in rl if se == 'P2'], 'P2')
            sw = switching(rl, (lambda se: ['P1', 'P2']) if n == 'duct' else (lambda se: ['P2' if se == 'P1' else 'P1']))
            rec['rows'].setdefault(x + y, {})[n] = dict(c, share=round(c['pts'] / c['n'], 4), share_p1=round(p1['pts'] / max(1, p1['n']), 4),
                                                         share_p2=round(p2['pts'] / max(1, p2['n']), 4), duct_switching=sw,
                                                         cpu_s_match=round(sum(r['cpu_s'] for r, _ in rl) / c['n'], 2))
            cols.append(f"{c['pts'] / c['n']:.3f} (P1 {p1['pts'] / max(1, p1['n']):.2f} P2 {p2['pts'] / max(1, p2['n']):.2f}) bell {c['bell']:2}")
        print(f'{x}{y}  | ' + ' | '.join(f'{s:>22}' for s in cols))
    rec['pooled'] = {n: dict(c, share=round(c['pts'] / c['n'], 4)) for n, c in pooled.items()}
    print('pooled | ' + ' | '.join(f"{n} {c['pts'] / c['n']:.3f}" for n, c in pooled.items()))
    json.dump(rec, open(o.json, 'w'), indent=1)
    print('->', os.path.relpath(o.json, ROOT))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    sub = ap.add_subparsers(dest='cmd', required=True)
    sub.add_parser('arms')
    m = sub.add_parser('matrix'); m.add_argument('--pair', required=True); m.add_argument('--seed0', type=int, default=200)
    m.add_argument('--seeds', type=int, default=100); m.add_argument('--iters', type=int, default=20000); m.add_argument('-j', type=int, default=16)
    a = sub.add_parser('anchor'); a.add_argument('--pair', required=True)
    b = sub.add_parser('budget'); b.add_argument('-j', type=int, default=16)
    f = sub.add_parser('fingerprint'); f.add_argument('--out', default=os.path.join(D, 'fingerprint-provisional.txt'))
    f.add_argument('--budget', choices=list(BUDGETS)); f.add_argument('-j', type=int, default=9)
    d = sub.add_parser('d2'); d.add_argument('--tier', action='append', default=[], help='NAME=DIR with DIR/<pair>-<character>.lisp')
    d.add_argument('--seed0', type=int, default=500); d.add_argument('--seeds', type=int, default=50); d.add_argument('--budget', choices=list(BUDGETS))
    d.add_argument('--chunk', type=int, default=CHUNK); d.add_argument('-j', type=int, default=16)
    d.add_argument('--json', default=os.path.join(D, 'd2-provisional.json'))
    o = ap.parse_args()
    dict(arms=cmd_arms, matrix=cmd_matrix, anchor=cmd_anchor, budget=cmd_budget, fingerprint=cmd_fingerprint, d2=cmd_d2)[o.cmd](o)


if __name__ == '__main__':
    main()

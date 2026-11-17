#!/usr/bin/env python3
"""ptr.py — q2-ptr (arms6/ptr.md): do the shipped T0 tables' arms do better at some SP pointer state? The data for :rb-sp2's G9 (my pointer x
the pointer switch open, rules 89-94) and G10 (his pointer x distance, rules 95-103).

  python3 ptr.py log TABLE [--seeds 1-500] [--salt 11] [--eps 0.04] [--runs 6 18] [--tiers hard,hard] [-j 20]
  python3 ptr.py tab TABLE [--seeds 1-500] [--boot 200] [--tiers hard,hard] [--by-greedy]

TABLE = a lookup row's table, e.g. ih-ichigo (`:t0-ih-ichigo`). The logs: the pairing's gate (200000 + 100 c1 + 10 c2) with the table's side on
seat 1 and on seat 2, both CPUs on the shipped lookup at the --tiers (mine, his); only the logging seat explores (strat-run.lisp STRAT_FQLOG
"<salt> <eps> <seat> <rmin> <rmax>": a judgement outside a run starts one with chance EPS, another arm drawn uniformly, held RMIN..RMAX
judgements). Logs under build/ptr/<table>-<tiers>/ (ignored).

The estimate (a randomised comparison, no model): among the judgements outside a run, whether a run starts is a hash coin, so a run start
with arm k at judgement t and the judgements where no run starts are samples of the same states. Per pointer rule s and arm k:
A(s, k) = mean Y over run starts with k - mean Y over the no-start judgements whose table pick is not k, each weighted by rule s's firing at t; Y = the discounted shaped
return from t (sw.py's design: 0.1 x the change of my mc-full-health - his per judgement window, +1 / -1 / 0 at the match's end by the game's
result, gamma 0.966 a judgement). A > 0: forcing a run of k in s beats the table there. The bootstrap resamples matches (seed x seat).
--by-greedy splits A by the table's own pick at t (which arm it would have played).
"""
import argparse, collections, gzip, os, re, subprocess, sys
import numpy as np
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '../../../../../tools')))
from simlib import ROOT, ROW, build, build_hash, pool, row_ko, run_lisp  # noqa: E402

ROSTER = {'kenpachi': 1, 'ichigo': 3, 'hisagi': 7}
PAIRS = {'k': 'kenpachi', 'i': 'ichigo', 'h': 'hisagi'}
GAMMA, SCALE = 0.966, 0.1
G9 = [f'my{p} sw{"open" if o else "shut"}' for o in (0, 1) for p in (1, 2, 3)]           # rules 89-94: (swopen no / yes) x (mptr 1 / 2 / 3)
G10 = [f'his{p} {d}' for p in (1, 2, 3) for d in ('close', 'mid', 'far')]               # rules 95-103: (optr 1 / 2 / 3) x distance
RULES = list(range(89, 104))
NAMES = dict(zip(RULES, G9 + G10))
LINE = re.compile(r'^fq (\d+) (\d+) (P\d) .* prev (\d+) greedy (\d+) arm (\d+) h (\S+) oh (\S+) .* fire(.*)$')
END = re.compile(r'^fqend (\d+) (P\d) h (\S+) oh (\S+)')


def sides(table):
    pair, me = table.split('-')
    a, b = PAIRS[pair[0]], PAIRS[pair[1]]
    vs = b if me == a else a
    assert me in (a, b), table
    return me, vs


def arm_names(table):
    src = open(os.path.join(ROOT, 'duel/lisp/strategy.lisp')).read()
    m = re.search(r'\(:id :t0-' + table + r' .*?:arms \(([^)]*)\)', src)
    return m[1].split()


def logdir(table, tiers):
    return os.path.join(ROOT, 'build/ptr', f'{table}-{tiers.replace(",", "-")}')


def job(j):
    table, tiers, seat, salt, eps, rmin, rmax, s0, n = j
    path = os.path.join(logdir(table, tiers), f's{salt}-e{eps}-P{seat}-{s0 + 1}-{s0 + n}.out.gz')
    if os.path.exists(path):
        return path
    me, vs = sides(table)
    c1, c2 = (me, vs) if seat == 1 else (vs, me)
    mt, ot = tiers.split(',')
    env = {k: v for k, v in os.environ.items() if not k.startswith('STRAT_')}
    env.update(STRAT_FQLOG=f'{salt} {eps} {seat} {rmin} {rmax}', **{f'STRAT_DIF_P{seat}': mt, f'STRAT_DIF_P{3 - seat}': ot})
    r = run_lisp('simgate/strat-run.lisp', [30000 + s0, 31100 + n, 81022, 200000 + 100 * ROSTER[c1] + 10 * ROSTER[c2]], env=env, timeout=7200)
    keep = [l for l in r.stdout.splitlines() if l.startswith(('fq ', 'fqend ', 'duel gate row '))]
    rows = sum(l.startswith('duel gate row ') for l in keep)
    if r.returncode or rows != n:
        sys.exit(f'ptr.py: {path}: exit {r.returncode}, {rows} of {n} rows\n{r.stderr[-1500:]}')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with gzip.open(path + '.tmp', 'wt') as f:
        f.write(f'; build {build_hash()}\n' + '\n'.join(keep) + '\n')
    os.replace(path + '.tmp', path)
    return path


def cmd_log(a):
    build()
    lo, hi = (int(x) for x in a.seeds.split('-'))
    jobs = [(a.table, a.tiers, seat, a.salt, a.eps, a.runs[0], a.runs[1], s0, min(50, hi - s0))
            for seat in (1, 2) for s0 in range(lo - 1, hi, 50)]
    for p in pool(job, jobs, a.j):
        print(p, flush=True)


def load(table, tiers, lo, hi):
    """-> matches: dicts seat, seed, js = [(arm, greedy, hdiff, fire {rule: x}, prev)], end hdiff, win."""
    out = []
    d = logdir(table, tiers)
    for fn in sorted(os.listdir(d)):
        m = re.match(r's\d+-e[\d.]+-P(\d)-(\d+)-(\d+)\.out\.gz$', fn)
        if not m or int(m[2]) < lo or int(m[3]) > hi:
            continue
        seat = 'P' + m[1]
        per = collections.defaultdict(lambda: dict(js=[]))
        for line in gzip.open(os.path.join(d, fn), 'rt'):
            if line.startswith('fq '):
                g = LINE.match(line)
                if g and g[3] == seat:
                    fire = {int(k): float(v) for k, v in (y.split(':') for y in g[9].split())}
                    per[int(g[1])]['js'].append((int(g[6]), int(g[5]), float(g[7]) - float(g[8]), fire, int(g[4])))
            elif line.startswith('fqend '):
                g = END.match(line)
                if g[2] == seat:
                    per[int(g[1])]['end'] = float(g[3]) - float(g[4])
            elif line.startswith('duel gate row '):
                r = ROW.search(line)
                per[int(r[1])]['win'] = 1.0 if r[2] == seat else (-1.0 if r[2] in ('P1', 'P2') else 0.0)
                per[int(r[1])]['ko'] = row_ko(line)
        out += [dict(x, seat=seat, seed=s) for s, x in per.items() if 'win' in x and x['js'] and lo <= s <= hi]
    return out


def returns(mt):
    js = mt['js']
    h = [j[2] for j in js] + [mt.get('end', js[-1][2])]
    r = [SCALE * (h[k + 1] - h[k]) for k in range(len(js))]
    r[-1] += mt['win']
    g, ys = 0.0, []
    for k in range(len(js) - 1, -1, -1):
        g = r[k] + GAMMA * g
        ys.append(g)
    return ys[::-1]


def design(ms, na, full=False):
    """-> per judgement outside a run: unit (match), kind (-1 no start, else the run's arm), greedy, Y, F (n x 15 pointer firings; FULL: n x
    104, every rule) and P (the previous arm, the pick's :prev)."""
    U, K, G, Y, F, P = [], [], [], [], [], []
    cols = range(104) if full else RULES
    for u, mt in enumerate(ms):
        ys = returns(mt)
        inrun = False
        for k, (arm, greedy, _, fire, prev) in enumerate(mt['js']):
            start = arm != greedy and not inrun
            # (a run: arm != the table's pick from its start; it may meet the pick later; it ends where the arm is the pick again and the
            #  next judgement follows the table. ponytail: a run whose arm becomes the table's pick mid-run reads as ended there.)
            if not inrun or start:
                U.append(u); K.append(arm if start else -1); G.append(greedy); Y.append(ys[k]); F.append([fire.get(r, 0.0) for r in cols])
                P.append(prev)
            inrun = arm != greedy
    return np.array(U), np.array(K), np.array(G), np.array(Y), np.array(F, dtype=np.float32), np.array(P)


def adv(U, K, G, Y, F, w, na):
    """A (15 x na): weighted mean Y of run starts with arm k minus the no-start judgements where the table's pick is not k (a run of k starts
    only there: the same population), per rule; also the treated weight."""
    wu = w[U]
    A = np.full((len(RULES), na), np.nan)
    N = np.zeros((len(RULES), na))
    for k in range(na):
        c = (K == -1) & (G != k)
        wc = F[c] * wu[c][:, None]
        mc = (wc * Y[c][:, None]).sum(0) / np.maximum(wc.sum(0), 1e-9)
        t = (K == k)
        wt = F[t] * wu[t][:, None]
        N[:, k] = wt.sum(0)
        A[:, k] = (wt * Y[t][:, None]).sum(0) / np.maximum(N[:, k], 1e-9) - mc
    return A, N


def cmd_tab(a):
    lo, hi = (int(x) for x in a.seeds.split('-'))
    names = arm_names(a.table)
    na = len(names)
    ms = load(a.table, a.tiers, lo, hi)
    U, K, G, Y, F, _ = design(ms, na)
    wins = sum(m['win'] > 0 for m in ms)
    print(f'{a.table} tiers {a.tiers} seeds {a.seeds}: {len(ms)} matches (won {wins}), {len(Y)} judgements outside a run, '
          f'run starts per arm {np.bincount(K[K >= 0], minlength=na).tolist()}; arms ' + ' '.join(f'{i}:{n}' for i, n in enumerate(names)))
    # the table's own picks per pointer rule (firing-weighted share of the no-start judgements)
    c = K == -1
    share = np.array([[F[c & (G == k), r].sum() for k in range(na)] for r in range(len(RULES))])
    occ = F[c].sum(0)
    rng = np.random.default_rng(1)
    groups = [('all', np.ones(len(Y), bool))] + ([(f'pick {k}', G == k) for k in range(na)] if a.by_greedy else [])
    for gname, gm in groups:
        Ug, Kg, Gg, Yg, Fg = U[gm], K[gm], G[gm], Y[gm], F[gm]
        A, N = adv(Ug, Kg, Gg, Yg, Fg, np.ones(len(ms)), na)
        bs = np.array([adv(Ug, Kg, Gg, Yg, Fg, rng.poisson(1.0, len(ms)).astype(float), na)[0] for _ in range(a.boot)])
        se = np.nanstd(bs, 0)
        print(f'\n[{gname}] rule          occ   table picks (share)        | per arm: A (z) [run-start weight]')
        for i, r in enumerate(RULES):
            if occ[i] < 1:
                continue
            pk = ' '.join(f'{share[i, k] / max(occ[i], 1e-9):.2f}' for k in range(na))
            cells = '  '.join(f'{A[i, k]:+.3f} ({A[i, k] / se[i, k]:+.1f}) [{N[i, k]:.0f}]' if N[i, k] >= 20 else f'{"-":>21s}'
                              for k in range(na))
            print(f'{r:3d} {NAMES[r]:12s} {occ[i] / len(Y):.3f}  {pk:24s} | {cells}')


# The tables the logs were made with (main before q2-ptr's commits; its T0 tables equal 9a4c9fa0's): the estimates' base and the scale of a
# delta. HEAD would read q2-ptr's own rows once committed (a 0.15 row doubles KI Kenpachi's scale).
BASE_REF = 'e16bda9c'


def table_q(table, ref=None):
    """The table's q (104 x arms) and :margin, read from strategy.lisp at git REF (None: the working tree). The estimates read BASE_REF's (the
    logs' table): an applied candidate in the working tree must not become their baseline."""
    src = (open(os.path.join(ROOT, 'duel/lisp/strategy.lisp')).read() if ref is None else
           subprocess.run(['git', 'show', f'{ref}:duel/lisp/strategy.lisp'], cwd=ROOT, capture_output=True, text=True, check=True).stdout)
    i = src.index('(:id :t0-' + table + ' ')
    margin = float(re.search(r':margin ([\d.]+)', src[i:i + 2000])[1])
    j = src.index(':q (', i)
    rows = re.findall(r'\(([-\d. ]+)\)', src[j + 3:j + 40000])[:104]
    return np.array([[float(x) for x in r.split()] for r in rows]), margin


def picks(F, P, q, margin):
    """STRAT-FQ-PICK on the logged states: argmax Q (ties: the first), the previous arm kept while it trails by less than MARGIN."""
    Q = F @ q
    best = Q.argmax(1)
    n = np.arange(len(P))
    keep = (P < q.shape[1]) & (Q[n, np.minimum(P, q.shape[1] - 1)] > Q[n, best] - margin)
    return np.where(keep, P, best)


def gain(U, K, G, Y, newp, w):
    """The randomised estimate of a new pick NEWP (per judgement outside a run) against the table: over the judgements where NEWP differs from
    the table's pick G, mean Y of the run starts whose run arm is NEWP minus mean Y of the no-start ones there, times their share of the
    no-start judgements (a run of the new arm there, per judgement). -> (gain, the switched share)."""
    wu = w[U]
    S = newp != G
    t = S & (K == newp)
    c = S & (K == -1)
    if wu[t].sum() <= 0 or wu[c].sum() <= 0:
        return 0.0, 0.0
    share = wu[c].sum() / wu[K == -1].sum()
    return ((wu[t] * Y[t]).sum() / wu[t].sum() - (wu[c] * Y[c]).sum() / wu[c].sum()) * share, share


def parse_deltas(spec, q0):
    """'ARM:ROW:MULT,...' -> a delta matrix: MULT x the table's own q at (ROW, ARM); ARM '*0' = every arm but 0 (arm 0 plays there)."""
    d = np.zeros_like(q0)
    qs = np.abs(q0[np.abs(q0) > 0]).max()
    for part in filter(None, spec.split(',')):
        arm, row, mult = part.split(':')
        for k in (range(1, q0.shape[1]) if arm == '*0' else [int(arm)]):
            d[int(row), k] += float(mult) * qs
    return d, qs


def evaluate(a, specs):
    lo, hi = (int(x) for x in a.seeds.split('-'))
    q0, margin = table_q(a.table, BASE_REF)
    na = q0.shape[1]
    ms = load(a.table, a.tiers, lo, hi)
    U, K, G, Y, F, P = design(ms, na, full=True)
    p0 = picks(F, P, q0, margin)
    print(f'{a.table}: {len(ms)} matches, {len(Y)} judgements outside a run; the recomputed pick = the logged one on {np.mean(p0 == G):.4f}')
    assert np.mean(p0 == G) >= 0.99, 'the base q is not the logged table (logs from another table, or HEAD moved): re-log'
    rng = np.random.default_rng(2)
    W = [rng.poisson(1.0, len(ms)).astype(float) for _ in range(a.boot)]
    half = np.array([m['seed'] <= (lo + hi) // 2 for m in ms])
    out = []
    for spec in specs:
        d, _ = parse_deltas(spec, q0)
        newp = picks(F, P, q0 + d, margin)
        g, sh = gain(U, K, G, Y, newp, np.ones(len(ms)))
        se = np.std([gain(U, K, G, Y, newp, w)[0] for w in W])
        h1 = gain(U, K, G, Y, newp, half.astype(float))[0]
        h2 = gain(U, K, G, Y, newp, (~half).astype(float))[0]
        out.append((spec, g, se, sh, h1, h2))
        if a.cmd == 'try':
            print(f'{spec:28s} gain {g * 1000:+7.2f} e-3 (z {g / max(se, 1e-12):+5.1f})  switched {sh:.3f}  halves {h1 * 1000:+6.2f} / {h2 * 1000:+6.2f}', flush=True)
    return out


def cmd_try(a):
    evaluate(a, a.spec)


def cmd_scan(a):
    """Every single pointer rule: arm k +2q at row s (k plays there), arm k -2q (never there), and arm 0 there (-2q for the rest)."""
    q0, _ = table_q(a.table, BASE_REF)
    na = q0.shape[1]
    specs = [f'{k}:{r}:{m}' for r in RULES for k in range(1, na) for m in (2, -2)] + [f'*0:{r}:-2' for r in RULES]
    out = evaluate(a, specs)
    # (the Fable review's bar: ~100 candidates a table give 1-4 false positives at z 2; z >= 3.3 and a switched share >= .03 is the gate,
    #  z 2-3.3 is listed for the record only)
    print('z >= 2, both halves the same sign (* = passes the gate: z >= 3.3, switched >= .03):')
    for spec, g, se, sh, h1, h2 in sorted(out, key=lambda x: -x[1] / max(x[2], 1e-12)):
        if g / max(se, 1e-12) >= 2 and h1 > 0 and h2 > 0:
            r = int(spec.split(':')[1])
            star = '*' if g / se >= 3.3 and sh >= 0.03 else ' '
            print(f' {star}{spec:12s} {NAMES[r]:12s} gain {g * 1000:+6.2f} e-3 (z {g / se:+4.1f}) switched {sh:.3f}  halves {h1 * 1000:+6.2f} / {h2 * 1000:+6.2f}')


def cmd_apply(a):
    """Add SPEC's pointer rules to the table's q in duel/lisp/strategy.lisp, in place (rows rewritten at 4 decimals)."""
    path = os.path.join(ROOT, 'duel/lisp/strategy.lisp')
    src = open(path).read()
    q0, _ = table_q(a.table, None)
    d, _ = parse_deltas(a.spec, table_q(a.table, BASE_REF)[0])   # (the scale: the logged table's q, not an applied row's)
    q = np.round(q0 + d, 4)
    j = src.index(':q (', src.index('(:id :t0-' + a.table + ' ')) + 3
    ms = list(re.finditer(r'\(([-\d. ]+)\)', src[j:j + 40000]))[:104]
    out, pos = [], j
    for m, row in zip(ms, q):
        out += [src[pos:j + m.start()], '(' + ' '.join(f'{x:.4f}' for x in row) + ')']
        pos = j + m.end()
    open(path, 'w').write(src[:j] + ''.join(out) + src[pos:])
    print(f'{a.table}: {int((d != 0).sum())} entries changed: ' + a.spec)


def share_job(j):
    table, tiers, seat, s0, n = j
    me, vs = sides(table)
    c1, c2 = (me, vs) if seat == 1 else (vs, me)
    mt, ot = tiers.split(',')
    env = {k: v for k, v in os.environ.items() if not k.startswith('STRAT_')}
    env.update(STRAT_FQLOG='0 0', **{f'STRAT_DIF_P{seat}': mt, f'STRAT_DIF_P{3 - seat}': ot})
    r = run_lisp('simgate/strat-run.lisp', [30000 + s0, 31100 + n, 81022, 200000 + 100 * ROSTER[c1] + 10 * ROSTER[c2]], env=env, timeout=7200)
    seq = collections.defaultdict(list)
    for l in r.stdout.splitlines():
        m = re.match(r'^fq (\d+) \d+ P(\d) .* arm (\d+) ', l)
        if m and int(m[2]) == seat:
            seq[int(m[1])].append(int(m[3]))
    return list(seq.values())


def cmd_share(a):
    """Bar A (DUEL_AI_STRATEGY §11.28) for the table as built: play unchanged (STRAT_FQLOG "0 0"), the table's side on both seats; per match
    the arm changes, pooled the arm shares. Pass: every match changes, median >= 10, >= 3 arms at >= 10 % (or every arm when fewer), none > 70 %."""
    build()
    lo, hi = (int(x) for x in a.seeds.split('-'))
    jobs = [(a.table, a.tiers, seat, s0, min(50, hi - s0)) for seat in (1, 2) for s0 in range(lo - 1, hi, 50)]
    ms = [s for r in pool(share_job, jobs, a.j) for s in r]
    na = len(arm_names(a.table))
    ch = sorted(sum(x != y for x, y in zip(s, s[1:])) for s in ms)
    tot = np.bincount([k for s in ms for k in s], minlength=na) / sum(len(s) for s in ms)
    ok = min(ch) > 0 and ch[len(ch) // 2] >= 10 and (tot >= 0.1).sum() >= min(3, na) and tot.max() <= 0.7
    print(f'{a.table} {a.tiers} seeds {a.seeds}: {len(ms)} matches, changes median {ch[len(ch) // 2]} min {ch[0]}, no change in '
          f'{sum(c == 0 for c in ch)}; shares ' + ' '.join(f'{k}:{x:.3f}' for k, x in enumerate(tot)) + f'  bar A {"PASS" if ok else "fail"}')


def main():
    ap = argparse.ArgumentParser()
    sp = ap.add_subparsers(dest='cmd', required=True)
    p = sp.add_parser('log'); p.add_argument('table'); p.add_argument('--seeds', default='1-500'); p.add_argument('--salt', type=int, default=11)
    p.add_argument('--eps', type=float, default=0.04); p.add_argument('--runs', type=int, nargs=2, default=[6, 18])
    p.add_argument('--tiers', default='hard,hard'); p.add_argument('-j', type=int, default=20)
    p = sp.add_parser('tab'); p.add_argument('table'); p.add_argument('--seeds', default='1-500'); p.add_argument('--boot', type=int, default=200)
    p.add_argument('--tiers', default='hard,hard'); p.add_argument('--by-greedy', action='store_true')
    p = sp.add_parser('apply'); p.add_argument('table'); p.add_argument('spec'); p.add_argument('--seeds', default='1-500')
    p = sp.add_parser('share'); p.add_argument('table'); p.add_argument('--seeds', default='501-540')
    p.add_argument('--tiers', default='hard,hard'); p.add_argument('-j', type=int, default=20)
    for c in ('try', 'scan'):
        p = sp.add_parser(c); p.add_argument('table'); p.add_argument('--seeds', default='1-500'); p.add_argument('--boot', type=int, default=100)
        p.add_argument('--tiers', default='hard,hard')
        if c == 'try':
            p.add_argument('spec', nargs='+')
    a = ap.parse_args()
    lo, hi = (int(x) for x in a.seeds.split('-'))
    assert hi <= 600 and not (801 <= lo <= 1000), 'seeds 801-1000 are held out'
    {'log': cmd_log, 'tab': cmd_tab, 'try': cmd_try, 'scan': cmd_scan, 'apply': cmd_apply, 'share': cmd_share}[a.cmd](a)


if __name__ == '__main__':
    main()

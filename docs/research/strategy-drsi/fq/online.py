#!/usr/bin/env python3
"""online.py — the online fuzzy Q against a player proxy, for one HARD pairing (docs/duel/DUEL_AI_STRATEGY.md §8.14, §8.15; README.md here;
online2.md: today's T0 tables, uncapped, with exploration).

The "player" is a proxy: the opponent's seat (P1) played by a CPU on a strategy (STRAT_P1), which the learner on P2 (as in VS CPU) treats as
the human (strat-run.lisp STRAT_FQLEARN with the learner's seat: only P2 learns, so a proxy that is itself a Q selector stays frozen).
The learner plays TABLE, its offline Q selector (it must carry :apply (me vs); the clamp's base stays this table in every chunk, the learned
copy is chained through IN). Defaults: Ichigo vs Kenpachi with the §8.14 table (counter/frozen/q1-ichigo-ken.lisp).

  python3 online.py dump  --char C --vs D --out FILE        the build's HARD lookup table for C vs D, expanded, as a strategy file
  python3 online.py train [--char C --vs D] [--table FILE] --proxy SPEC --tag T [--init TABLE] [--eta E] [--cap C] [--eps P] [--eps-decay K]
                          [--runs 4] [--seeds 1-599] [--out-root DIR]
  python3 online.py heldout [--char C --vs D] [--table FILE] [--proxy SPEC] --learned FILE... [--seed0 600] [--n 100]
  python3 online.py stats --table FILE FILE...              per learned table: rules moved, rules whose arm flipped, the largest |q|

SPEC: a strategy file, a frozen library id (counter/frozen/<id>.lisp), none (the opponent's shipped CPU, no strategy at all), or a comma list
(a pool: the match with seed s plays member s mod n, pools.json). Omitted: whatever the build's lookup gives him (his shipped HARD CPU).
train: run r learns over its own block of the training seeds in order, chunks of 25 matches chained through the table file
(<out-root>/<pairing>/<tag>/run<r>-<k>.lisp; Ichigo vs Kenpachi: <out-root>/<tag>/ as in §8.14); the same seeds are played by the frozen TABLE
for a paired learning curve ("q1" in the JSON = the frozen offline table). Writes train.json there. --cap omitted: the build's (NIL since
2026-11-17). --eps-decay K: chunk k (matches 25k.. of a run) plays eps / (1 + 25k / K), a chunk-wise stand-in for eps0 / (1 + matches / K).
heldout (alias eval): each learned table (frozen, learning off) and TABLE on the same held-out seeds, both seats; wins, paired b / c, z, the share of
judgements per arm. One JSON line per learned table on stdout.
"""
import argparse, concurrent.futures as cf, json, math, os, re, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
from simlib import build, run_lisp   # noqa: E402

ROSTER = {'kenpachi': 1, 'ichigo': 3, 'hisagi': 7}
OUT = os.path.join(HERE, 'online', 'out')
FROZEN = os.path.join(HERE, '..', 'counter', 'frozen')
CHUNK = 25
ME = VS = None                                            # (roster indices of the pairing, set by main)
SWITCH = re.compile(r'^switch (P[12]) \S+ judged (\d+) held((?: \d+)*)')


def spec_path(x):
    """A spec member -> an absolute path or none: a file, or a frozen library id."""
    if x == 'none' or os.path.exists(x):
        return x if x == 'none' else os.path.abspath(x)
    f = os.path.join(FROZEN, x.lstrip(':') + '.lisp')
    if not os.path.exists(f):
        sys.exit(f'online.py: no strategy file or frozen id {x}')
    return os.path.abspath(f)


def sim(seat, seed0, n, proxy, table=None, learn=None, knobs=None, held=None, fqbase=None):
    """The character on SEAT against the proxy on the other seat, seeds seed0+1..seed0+n. TABLE: the character's strategy file (the offline
    table when learning); LEARN: (in, out) table files, SEAT learns. HELD: a list to add the seat's per-arm judgement counts to, and with
    FQBASE (a table file, strat-run STRAT_FQBASE) its [judged, differ] at the end.
    -> list of (seed, character_won)."""
    c1, c2 = (ME, VS) if seat == 'P1' else (VS, ME)
    env = {k: v for k, v in os.environ.items() if not k.startswith('STRAT_')}
    if proxy:
        env['STRAT_' + ('P2' if seat == 'P1' else 'P1')] = proxy
    if table:
        env['STRAT_' + seat] = table
    if learn:
        env['STRAT_FQLEARN'] = f'{learn[0] or "-"} {learn[1]} {seat[1]}'
    if knobs:
        env['STRAT_SET'] = knobs
    if fqbase:
        env['STRAT_FQBASE'] = fqbase
    cmds = [30000 + seed0, 31100 + n, 81022, 200000 + 100 * c1 + 10 * c2]
    r = run_lisp('simgate/strat-run.lisp', cmds, env=env, timeout=7200)
    rows = [re.search(r'seed (\d+) .* winner (\S+)', l) for l in r.stdout.splitlines() if l.startswith('duel gate row ')]
    if r.returncode or len(rows) != n:
        sys.exit(f'online.py: sim exited {r.returncode}, {len(rows)} of {n} rows\n' + (r.stdout + r.stderr)[-2000:])
    if held is not None:                                  # (a "switch" line per match and side, printed when the next match starts)
        for m in map(SWITCH.match, r.stdout.splitlines()):
            if m and m.group(1) == seat:
                h = [int(x) for x in m.group(3).split()]
                held.extend([0] * (len(h) - len(held)))
                for i, x in enumerate(h):
                    held[i] += x
        if fqbase:
            dis = [re.match(r'^fqbase \d+ (P[12]) judged (\d+) differ (\d+)', l) for l in r.stdout.splitlines()]
            held.append([sum(int(m.group(2)) for m in dis if m and m.group(1) == seat), sum(int(m.group(3)) for m in dis if m and m.group(1) == seat)])
    return [(int(g.group(1)), int(g.group(2) == seat)) for g in rows]


def blocks(lo, hi, size=CHUNK):
    out, s = [], lo
    while s <= hi:
        n = min(size, hi - s + 1)
        out.append((s - 1, n))
        s += n
    return out


def knobs_for(a, k):
    eps = a.eps / (1 + CHUNK * k / a.eps_decay) if a.eps_decay else a.eps
    return ','.join([f'*fq-online-eta*={a.eta}', f'*fq-online-eps*={eps}'] + ([f'*fq-online-cap*={a.cap}'] if a.cap is not None else []))


def train_run(args):
    d, r, lo, hi, a = args
    prev, res = a.init, []
    for k, (s0, n) in enumerate(blocks(lo, hi)):
        out = os.path.join(d, f'run{r}-{k}.lisp')
        res += sim('P2', s0, n, a.proxy, table=a.table, learn=(prev, out), knobs=knobs_for(a, k))
        prev = out
    return res, prev


def cmd_train(a):
    lo, hi = (int(x) for x in a.seeds.split('-'))
    d = out_dir(a)
    os.makedirs(d, exist_ok=True)
    size = math.ceil((hi - lo + 1) / a.runs)
    spans = [(lo + i * size, min(hi, lo + (i + 1) * size - 1)) for i in range(a.runs)]
    with cf.ThreadPoolExecutor(max(1, a.j)) as ex:
        runs = ex.map(train_run, [(d, i, s, e, a) for i, (s, e) in enumerate(spans)])
        frozen = ex.map(lambda b: sim('P2', b[0], b[1], a.proxy, table=a.table), [b for s, e in spans for b in blocks(s, e)])
        runs, frozen = list(runs), dict(x for f in frozen for x in f)
    curve = []                                            # per block of CHUNK matches in order: learner wins, q1 wins (same seeds), b, c
    for r, (res, _) in enumerate(runs):
        for i in range(0, len(res), CHUNK):
            blk = res[i:i + CHUNK]
            curve.append(dict(run=r, seeds=f'{blk[0][0]}-{blk[-1][0]}', learner=sum(w for _, w in blk),
                              q1=sum(frozen[sd] for sd, _ in blk), b=sum(w and not frozen[sd] for sd, w in blk),
                              c=sum(frozen[sd] and not w for sd, w in blk), n=len(blk)))
    per_k = {}
    for i, (res, _) in enumerate(runs):
        for k in range(0, len(res), CHUNK):
            blk = res[k:k + CHUNK]
            p = per_k.setdefault(k // CHUNK, dict(learner=0, q1=0, n=0))
            p['learner'] += sum(w for _, w in blk); p['q1'] += sum(frozen[sd] for sd, _ in blk); p['n'] += len(blk)
    b = sum(c['b'] for c in curve); c = sum(c['c'] for c in curve)
    res = dict(char=a.char, vs=a.vs, table=rel(a.table), proxy=rel(a.proxy), init=rel(a.init), eta=a.eta, cap=a.cap, eps=a.eps,
               eps_decay=a.eps_decay, seeds=a.seeds, spans=spans, tables=[rel(t) for _, t in runs],
               learner=sum(x['learner'] for x in curve), q1=sum(x['q1'] for x in curve), n=sum(x['n'] for x in curve), b=b, c=c,
               z=round((b - c) / math.sqrt(b + c), 2) if b + c else 0.0, by_block=per_k, curve=curve)
    json.dump(res, open(os.path.join(d, 'train.json'), 'w'), indent=1)
    print(json.dumps({k: v for k, v in res.items() if k != 'curve'}, indent=1))


def cmd_heldout(a):
    tabs = [a.table] + a.learned                          # (the offline table first, played once for every learned one)
    jobs = [(seat, s0, n, t) for seat in ('P1', 'P2') for t in tabs for s0, n in blocks(a.seed0 + 1, a.seed0 + a.n)]

    def one(j):
        held = []
        o = sim(j[0], j[1], j[2], a.proxy, table=j[3], held=held, fqbase=a.table if j[3] != a.table else None)
        return o, held
    with cf.ThreadPoolExecutor(max(1, a.j)) as ex:
        outs = list(ex.map(one, jobs))
    won, held, dis = {}, {}, {}
    for (seat, _, _, t), (o, h) in zip(jobs, outs):
        for sd, w in o:
            won[(t, seat, sd)] = w
        if t != a.table:
            d = dis.setdefault(t, [0, 0]); jd, df = h.pop(); d[0] += jd; d[1] += df
        acc = held.setdefault(t, [])
        acc.extend([0] * (len(h) - len(acc)))
        for i, x in enumerate(h):
            acc[i] += x
    keys = [(seat, sd) for t, seat, sd in won if t == a.table]
    qw = sum(won[(a.table, s, d)] for s, d in keys)
    for t in a.learned:
        tw = sum(won[(t, s, d)] for s, d in keys)
        b = sum(won[(t, s, d)] and not won[(a.table, s, d)] for s, d in keys)
        c = sum(won[(a.table, s, d)] and not won[(t, s, d)] for s, d in keys)
        share = lambda h: [round(x / max(1, sum(h)), 3) for x in h]
        print(json.dumps(dict(char=a.char, vs=a.vs, proxy=rel(a.proxy), table=rel(t), base=rel(a.table), seeds=f'{a.seed0 + 1}-{a.seed0 + a.n}',
                              n=len(keys), table_share=tw / len(keys), q1_share=qw / len(keys), b=b, c=c,
                              z=round((b - c) / math.sqrt(b + c), 2) if b + c else 0.0,
                              by_seat={s: dict(table=sum(won[(t, x, d)] for x, d in keys if x == s), q1=sum(won[(a.table, x, d)] for x, d in keys if x == s))
                                       for s in ('P1', 'P2')},
                              arms=share(held[t]), arms_q1=share(held[a.table]), judged=dis.get(t, [0, 0])[0],
                              differ=round(dis.get(t, [0, 0])[1] / max(1, dis.get(t, [0, 0])[0]), 3))), flush=True)


def sexp(text):
    """A minimal READ of one Lisp form: lists -> Python lists, numbers -> float / int, everything else a string."""
    toks = re.findall(r'\(|\)|"(?:\\.|[^"])*"|[^\s()]+', text)
    stack = [[]]
    for t in toks:
        if t == '(':
            stack.append([])
        elif t == ')':
            x = stack.pop(); stack[-1].append(x)
        else:
            try:
                stack[-1].append(int(t))
            except ValueError:
                try:
                    stack[-1].append(float(t.replace('d', 'e').replace('f', 'e')))
                except ValueError:
                    stack[-1].append(t)
    return stack[0][0]


def plist(l, k):
    return next((l[i + 1] for i in range(0, len(l) - 1, 2) if l[i] == k), None)


def table_rules(f):
    return [r[1:] for r in plist(plist(sexp(open(f).read()), ':FQ'), ':RULES')]


def cmd_stats(a):
    """Rules moved (any q off the offline table's); of the rules whose offline row has a strict leader, those whose leader changed (flips);
    of the rules whose offline row is tied at its top (most T0 rows: all 0), those that now have a strict leader (gained); the largest |q|.
    A rule's own leader is not the arm played: with :GROUPS the arm is the argmax of the groups' sum (eval's differ / arms say that)."""
    base = table_rules(a.table)
    lead = lambda q: q.index(max(q)) if q.count(max(q)) == 1 else None
    for f in a.learned:
        rs = table_rules(f)
        print(json.dumps(dict(table=rel(f), rules=len(rs), moved=sum(r != b for r, b in zip(rs, base)),
                              led=sum(lead(b) is not None for b in base),
                              flips=sum(lead(b) is not None and lead(r) != lead(b) for r, b in zip(rs, base)),
                              gained=sum(lead(b) is None and lead(r) is not None for r, b in zip(rs, base)),
                              max_abs_q=max(abs(q) for r in rs for q in r), max_page_int=max(abs(round(q * 100000)) for r in rs for q in r))))


def cmd_dump(a):
    """The build's HARD lookup table for the learner's pairing, as a strategy file: one match (seed 501) learning at eta 0 writes it
    expanded (the :WITH units laid under its arms, the rule base's rules), :matches dropped."""
    tmp = os.path.abspath(a.out) + '.tmp'
    sim('P2', 500, 1, None, learn=(None, tmp), knobs='*fq-online-eta*=0')
    txt = open(tmp).read()
    os.remove(tmp)
    open(a.out, 'w').write(re.sub(r'^\(:MATCHES \d+ ', '(', txt))
    print(a.out)


def rel(p):
    return p and ','.join(os.path.relpath(x, ROOT) if os.path.isabs(x) else x for x in p.split(','))


def out_dir(a):
    """<out-root>/<tag> for Ichigo vs Kenpachi (as in §8.14), <out-root>/<char>-<vs>/<tag> for any other pairing (or with --out-root)."""
    if (a.char, a.vs) == ('ichigo', 'kenpachi') and not a.out_root:
        return os.path.join(OUT, a.tag)
    return os.path.join(a.out_root or OUT, f'{a.char}-{a.vs}', a.tag)


def main():
    global ME, VS
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest='cmd', required=True)
    p = sub.add_parser('train')
    p.add_argument('--proxy')                             # (omitted: the build's lookup for him; none: his shipped CPU, no strategy)
    p.add_argument('--init')                              # (a table to start every run from; none: the shipped table)
    p.add_argument('--tag', required=True)
    p.add_argument('--eta', type=float, default=0.05)
    p.add_argument('--cap', type=float)                   # (omitted: the build's *fq-online-cap*, NIL since 2026-11-17)
    p.add_argument('--eps', type=float, default=0.0)
    p.add_argument('--eps-decay', type=float)
    p.add_argument('--runs', type=int, default=4)
    p.add_argument('--seeds', default='1-500')   # (1-500 since online2: 501-600 is the check against the shipped CPU, online2.md)
    p.add_argument('--out-root')
    p.add_argument('-j', type=int, default=8)
    p = sub.add_parser('heldout', aliases=['eval'])   # (heldout since online2; eval, §8.14's name, kept)
    p.add_argument('--proxy')
    p.add_argument('--learned', required=True, nargs='+', help='the learned tables to evaluate (frozen)')
    p.add_argument('--seed0', type=int, default=600)
    p.add_argument('--n', type=int, default=100)
    p.add_argument('-j', type=int, default=8)
    p = sub.add_parser('stats')
    p.add_argument('learned', nargs='+')
    p = sub.add_parser('dump')
    p.add_argument('--out', required=True)
    for p in {id(p): p for p in sub.choices.values()}.values():   # (an alias maps to the same parser)
        p.add_argument('--char', default='ichigo', choices=list(ROSTER))
        p.add_argument('--vs', default='kenpachi', choices=list(ROSTER))
        p.add_argument('--table', help='the learner\'s offline table (default for Ichigo vs Kenpachi: counter/frozen/q1-ichigo-ken.lisp)')
    a = ap.parse_args()
    ME, VS = ROSTER[a.char], ROSTER[a.vs]
    # every sim runs build/simgate/duel.fas as it is: rebuild it first when a source is newer, or a swapped-in file plays the last build's
    # code (step 9's bundle and fidelity runs played round 3's b1_a2, §8.19 round 5, step 11). ponytail: mtime only, blind to `cp -p`.
    build()
    if a.cmd == 'dump':
        return cmd_dump(a)
    if not a.table:
        if (a.char, a.vs) != ('ichigo', 'kenpachi'):
            sys.exit('online.py: --table (the offline Q selector, with :apply) is required outside Ichigo vs Kenpachi')
        a.table = 'q1-ichigo-ken'
    a.table = spec_path(a.table)                          # (the sims run from the repo's root: absolute paths)
    if getattr(a, 'proxy', None):
        a.proxy = ','.join(spec_path(x) for x in a.proxy.split(','))
    for k in ('init', 'out_root'):
        if getattr(a, k, None):
            setattr(a, k, os.path.abspath(getattr(a, k)))
    if getattr(a, 'learned', None):
        a.learned = [os.path.abspath(x) for x in a.learned]
    {'train': cmd_train, 'heldout': cmd_heldout, 'eval': cmd_heldout, 'stats': cmd_stats}[a.cmd](a)


if __name__ == '__main__':
    main()

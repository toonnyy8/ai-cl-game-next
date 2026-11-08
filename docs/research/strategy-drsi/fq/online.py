#!/usr/bin/env python3
"""online.py — the online fuzzy Q against a player proxy, for one HARD pairing (docs/duel/DUEL_AI_STRATEGY.md §8.14, §8.15; README.md here).

The "player" is a proxy: the opponent's seat (P1) played by a CPU on a strategy (STRAT_P1), which the learner on P2 (as in VS CPU) treats as
the human (strat-run.lisp STRAT_FQLEARN with the learner's seat: only P2 learns, so a proxy that is itself a Q selector stays frozen).
The learner plays TABLE, its offline Q selector (it must carry :apply (me vs); the clamp's base stays this table in every chunk, the learned
copy is chained through IN). Defaults: Ichigo vs Kenpachi with the shipped table (counter/frozen/q1-ichigo-ken.lisp), as in §8.14.

  python3 online.py train [--char C --vs D] [--table FILE] --proxy SPEC --tag T [--init TABLE] [--eta E] [--cap C] [--eps P] [--runs 4] [--seeds 1-599]
  python3 online.py eval  [--char C --vs D] [--table FILE] --proxy SPEC --learned FILE [--seed0 600] [--n 100]

SPEC: a strategy file, a frozen library id (counter/frozen/<id>.lisp), none (the opponent's shipped CPU, no strategy at all), or a comma list
(a pool: the match with seed s plays member s mod n, pools.json). Omitted: whatever the build's lookup gives him.
train: run r learns over its own block of the training seeds in order, chunks of 25 matches chained through the table file
(out/<pairing>/<tag>/run<r>-<k>.lisp; Ichigo vs Kenpachi: out/<tag>/ as in §8.14); the same seeds are played by the frozen TABLE for a paired
learning curve ("q1" in the JSON = the frozen offline table). Writes train.json there.
eval: the learned table (frozen, learning off) and TABLE on the same held-out seeds, both seats; wins, paired b / c, z. JSON on stdout.
"""
import argparse, concurrent.futures as cf, json, math, os, re, subprocess, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
from simgate import ECL, FAS, MUSLM          # noqa: E402

ROSTER = {'kenpachi': 1, 'ichigo': 3, 'hisagi': 7}
OUT = os.path.join(HERE, 'online', 'out')
FROZEN = os.path.join(HERE, '..', 'counter', 'frozen')
CHUNK = 25
ME = VS = None                                            # (roster indices of the pairing, set by main)


def spec_path(x):
    """A spec member -> an absolute path or none: a file, or a frozen library id."""
    if x == 'none' or os.path.exists(x):
        return x if x == 'none' else os.path.abspath(x)
    f = os.path.join(FROZEN, x.lstrip(':') + '.lisp')
    if not os.path.exists(f):
        sys.exit(f'online.py: no strategy file or frozen id {x}')
    return os.path.abspath(f)


def sim(seat, seed0, n, proxy, table=None, learn=None, knobs=None):
    """The character on SEAT against the proxy on the other seat, seeds seed0+1..seed0+n. TABLE: the character's strategy file (the offline
    table when learning); LEARN: (in, out) table files, SEAT learns. -> list of (seed, character_won)."""
    c1, c2 = (ME, VS) if seat == 'P1' else (VS, ME)
    env = {k: v for k, v in os.environ.items() if not k.startswith('STRAT_')}
    env.update(LD_PRELOAD=MUSLM)
    if proxy:
        env['STRAT_' + ('P2' if seat == 'P1' else 'P1')] = proxy
    if table:
        env['STRAT_' + seat] = table
    if learn:
        env['STRAT_FQLEARN'] = f'{learn[0] or "-"} {learn[1]} {seat[1]}'
    if knobs:
        env['STRAT_SET'] = knobs
    cmds = [30000 + seed0, 31100 + n, 81000, 81022, 81030, 81040, 200000 + 100 * c1 + 10 * c2]
    r = subprocess.run([ECL, '--norc', '--load', 'tools/simgate/strat-run.lisp', '--', FAS] + [str(c) for c in cmds], cwd=ROOT,
                       capture_output=True, text=True, env=env, timeout=7200)
    rows = [re.search(r'seed (\d+) .* winner (\S+)', l) for l in r.stdout.splitlines() if l.startswith('duel gate row ')]
    if r.returncode or len(rows) != n:
        sys.exit(f'online.py: sim exited {r.returncode}, {len(rows)} of {n} rows\n' + (r.stdout + r.stderr)[-2000:])
    return [(int(g.group(1)), int(g.group(2) == seat)) for g in rows]


def blocks(lo, hi, size=CHUNK):
    out, s = [], lo
    while s <= hi:
        n = min(size, hi - s + 1)
        out.append((s - 1, n))
        s += n
    return out


def train_run(args):
    d, r, lo, hi, proxy, knobs, init, table = args
    prev, res = init, []
    for k, (s0, n) in enumerate(blocks(lo, hi)):
        out = os.path.join(d, f'run{r}-{k}.lisp')
        res += sim('P2', s0, n, proxy, table=table, learn=(prev, out), knobs=knobs)
        prev = out
    return res, prev


def cmd_train(a):
    lo, hi = (int(x) for x in a.seeds.split('-'))
    d = out_dir(a)
    os.makedirs(d, exist_ok=True)
    size = math.ceil((hi - lo + 1) / a.runs)
    spans = [(lo + i * size, min(hi, lo + (i + 1) * size - 1)) for i in range(a.runs)]
    knobs = f'*fq-online-eta*={a.eta},*fq-online-cap*={a.cap},*fq-online-eps*={a.eps}'
    with cf.ThreadPoolExecutor(max(1, a.j)) as ex:
        runs = ex.map(train_run, [(d, i, s, e, a.proxy, knobs, a.init, a.table) for i, (s, e) in enumerate(spans)])
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
    res = dict(char=a.char, vs=a.vs, table=a.table, proxy=a.proxy, init=a.init, eta=a.eta, cap=a.cap, eps=a.eps, seeds=a.seeds, spans=spans, tables=[t for _, t in runs],
               learner=sum(x['learner'] for x in curve), q1=sum(x['q1'] for x in curve), n=sum(x['n'] for x in curve), b=b, c=c,
               z=round((b - c) / math.sqrt(b + c), 2) if b + c else 0.0, by_block=per_k, curve=curve)
    json.dump(res, open(os.path.join(d, 'train.json'), 'w'), indent=1)
    print(json.dumps({k: v for k, v in res.items() if k != 'curve'}, indent=1))


def cmd_eval(a):
    jobs = [(seat, s0, n, t) for seat in ('P1', 'P2') for t in (a.learned, a.table) for s0, n in blocks(a.seed0 + 1, a.seed0 + a.n)]
    with cf.ThreadPoolExecutor(max(1, a.j)) as ex:
        outs = list(ex.map(lambda j: sim(j[0], j[1], j[2], a.proxy, table=j[3]), jobs))
    won = {}
    for (seat, _, _, t), o in zip(jobs, outs):
        for sd, w in o:
            won[(seat, sd, t == a.learned)] = w
    keys = [(seat, sd) for seat, sd, lt in won if lt]
    tw = sum(won[(s, d, True)] for s, d in keys); qw = sum(won[(s, d, False)] for s, d in keys)
    b = sum(won[(s, d, True)] and not won[(s, d, False)] for s, d in keys)
    c = sum(won[(s, d, False)] and not won[(s, d, True)] for s, d in keys)
    res = dict(char=a.char, vs=a.vs, proxy=a.proxy, table=a.learned, base=a.table, seeds=f'{a.seed0 + 1}-{a.seed0 + a.n}', n=len(keys), table_share=tw / len(keys),
               q1_share=qw / len(keys), b=b, c=c, z=round((b - c) / math.sqrt(b + c), 2) if b + c else 0.0,
               by_seat={s: dict(table=sum(won[(x, d, True)] for x, d in keys if x == s), q1=sum(won[(x, d, False)] for x, d in keys if x == s))
                        for s in ('P1', 'P2')})
    print(json.dumps(res))


def out_dir(a):
    """out/<tag> for Ichigo vs Kenpachi (as in §8.14), out/<char>-<vs>/<tag> for any other pairing."""
    return os.path.join(OUT, a.tag) if (a.char, a.vs) == ('ichigo', 'kenpachi') else os.path.join(OUT, f'{a.char}-{a.vs}', a.tag)


def main():
    global ME, VS
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest='cmd', required=True)
    p = sub.add_parser('train')
    p.add_argument('--proxy')                             # (omitted: the build's lookup for him; none: his shipped CPU, no strategy)
    p.add_argument('--init')                              # (a table to start every run from; none: the shipped table)
    p.add_argument('--tag', required=True)
    p.add_argument('--eta', type=float, default=0.05)
    p.add_argument('--cap', type=float, default=0.05)
    p.add_argument('--eps', type=float, default=0.0)
    p.add_argument('--runs', type=int, default=4)
    p.add_argument('--seeds', default='1-599')
    p.add_argument('-j', type=int, default=8)
    p = sub.add_parser('eval')
    p.add_argument('--proxy')
    p.add_argument('--learned', required=True, help='the learned table to evaluate (frozen)')
    p.add_argument('--seed0', type=int, default=600)
    p.add_argument('--n', type=int, default=100)
    p.add_argument('-j', type=int, default=8)
    for p in sub.choices.values():
        p.add_argument('--char', default='ichigo', choices=list(ROSTER))
        p.add_argument('--vs', default='kenpachi', choices=list(ROSTER))
        p.add_argument('--table', help='the learner\'s offline table (default for Ichigo vs Kenpachi: counter/frozen/q1-ichigo-ken.lisp)')
    a = ap.parse_args()
    ME, VS = ROSTER[a.char], ROSTER[a.vs]
    if not a.table:
        if (a.char, a.vs) != ('ichigo', 'kenpachi'):
            sys.exit('online.py: --table (the offline Q selector, with :apply) is required outside Ichigo vs Kenpachi')
        a.table = 'q1-ichigo-ken'
    a.table = spec_path(a.table)                          # (the sims run from the repo's root: absolute paths)
    if a.proxy:
        a.proxy = ','.join(spec_path(x) for x in a.proxy.split(','))
    for k in ('init', 'learned'):
        if getattr(a, k, None):
            setattr(a, k, os.path.abspath(getattr(a, k)))
    {'train': cmd_train, 'eval': cmd_eval}[a.cmd](a)


if __name__ == '__main__':
    main()

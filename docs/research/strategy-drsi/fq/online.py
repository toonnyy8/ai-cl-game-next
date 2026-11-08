#!/usr/bin/env python3
"""online.py — the proof that the online fuzzy Q adapts to a player (docs/duel/DUEL_AI_STRATEGY.md §8.14; README.md here).

The "player" is a proxy: Kenpachi's seat played by a CPU on a strategy file (STRAT_KENPACHI), which the learner treats as the human
(strat-run.lisp STRAT_FQLEARN sets *fq-learn-force*). Ichigo HARD plays the shipped Q selector (:q1-ichigo-ken from the lookup).

  python3 online.py train --proxy FILE --tag T [--init TABLE] [--eta E] [--cap C] [--eps P] [--runs 4] [--seeds 1-599]   # learning runs + frozen q1 on the same seeds
  python3 online.py eval --proxy FILE --table FILE [--seed0 600] [--n 100]                       # frozen: the table against q1, both seats

train: run r learns over its own block of the training seeds in order, Ichigo on P2 as in VS CPU, chunks of 25 matches chained through the
table file (out/<tag>/run<r>-<k>.lisp); the same seeds are played by frozen q1 for a paired learning curve. Writes out/<tag>/train.json.
eval: the table (a strategy file, learning off) and q1 on the same held-out seeds, both seats; wins, paired b / c, z. JSON on stdout.
"""
import argparse, concurrent.futures as cf, json, math, os, re, subprocess, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
from simgate import ECL, FAS, MUSLM          # noqa: E402

ICHIGO, KEN = 3, 1
OUT = os.path.join(HERE, 'online', 'out')
CHUNK = 25


def sim(seat, seed0, n, proxy, table=None, learn=None, knobs=None):
    """Ichigo on SEAT against the proxy, seeds seed0+1..seed0+n. TABLE: her strategy file (frozen); LEARN: (in, out) table files.
    -> list of (seed, ichigo_won)."""
    c1, c2 = (ICHIGO, KEN) if seat == 'P1' else (KEN, ICHIGO)
    env = {k: v for k, v in os.environ.items() if not k.startswith('STRAT_')}
    env.update(LD_PRELOAD=MUSLM)
    if proxy:
        env['STRAT_KENPACHI'] = proxy
    if table:
        env['STRAT_' + seat] = table
    if learn:
        env['STRAT_FQLEARN'] = f'{learn[0] or "-"} {learn[1]}'
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
    tag, r, lo, hi, proxy, knobs, init = args
    d = os.path.join(OUT, tag)
    prev, res = init, []
    for k, (s0, n) in enumerate(blocks(lo, hi)):
        out = os.path.join(d, f'run{r}-{k}.lisp')
        res += sim('P2', s0, n, proxy, learn=(prev, out), knobs=knobs)
        prev = out
    return res, prev


def cmd_train(a):
    lo, hi = (int(x) for x in a.seeds.split('-'))
    os.makedirs(os.path.join(OUT, a.tag), exist_ok=True)
    size = math.ceil((hi - lo + 1) / a.runs)
    spans = [(lo + i * size, min(hi, lo + (i + 1) * size - 1)) for i in range(a.runs)]
    knobs = f'*fq-online-eta*={a.eta},*fq-online-cap*={a.cap},*fq-online-eps*={a.eps}'
    with cf.ThreadPoolExecutor(max(1, a.j)) as ex:
        runs = ex.map(train_run, [(a.tag, i, s, e, a.proxy, knobs, a.init) for i, (s, e) in enumerate(spans)])
        frozen = ex.map(lambda b: sim('P2', b[0], b[1], a.proxy), [b for s, e in spans for b in blocks(s, e)])
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
    res = dict(proxy=a.proxy, init=a.init, eta=a.eta, cap=a.cap, eps=a.eps, seeds=a.seeds, spans=spans, tables=[t for _, t in runs],
               learner=sum(x['learner'] for x in curve), q1=sum(x['q1'] for x in curve), n=sum(x['n'] for x in curve), b=b, c=c,
               z=round((b - c) / math.sqrt(b + c), 2) if b + c else 0.0, by_block=per_k, curve=curve)
    json.dump(res, open(os.path.join(OUT, a.tag, 'train.json'), 'w'), indent=1)
    print(json.dumps({k: v for k, v in res.items() if k != 'curve'}, indent=1))


def cmd_eval(a):
    jobs = [(seat, s0, n, t) for seat in ('P1', 'P2') for t in (a.table, None) for s0, n in blocks(a.seed0 + 1, a.seed0 + a.n)]
    with cf.ThreadPoolExecutor(max(1, a.j)) as ex:
        outs = list(ex.map(lambda j: sim(j[0], j[1], j[2], a.proxy, table=j[3]), jobs))
    won = {}
    for (seat, _, _, t), o in zip(jobs, outs):
        for sd, w in o:
            won[(seat, sd, t is not None)] = w
    keys = [(seat, sd) for seat, sd, lt in won if lt]
    tw = sum(won[(s, d, True)] for s, d in keys); qw = sum(won[(s, d, False)] for s, d in keys)
    b = sum(won[(s, d, True)] and not won[(s, d, False)] for s, d in keys)
    c = sum(won[(s, d, False)] and not won[(s, d, True)] for s, d in keys)
    res = dict(proxy=a.proxy, table=a.table, seeds=f'{a.seed0 + 1}-{a.seed0 + a.n}', n=len(keys), table_share=tw / len(keys),
               q1_share=qw / len(keys), b=b, c=c, z=round((b - c) / math.sqrt(b + c), 2) if b + c else 0.0,
               by_seat={s: dict(table=sum(won[(x, d, True)] for x, d in keys if x == s), q1=sum(won[(x, d, False)] for x, d in keys if x == s))
                        for s in ('P1', 'P2')})
    print(json.dumps(res))


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest='cmd', required=True)
    p = sub.add_parser('train')
    p.add_argument('--proxy')                             # (none: the shipped Kenpachi CPU)
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
    p.add_argument('--table', required=True)
    p.add_argument('--seed0', type=int, default=600)
    p.add_argument('--n', type=int, default=100)
    p.add_argument('-j', type=int, default=8)
    a = ap.parse_args()
    for k in ('proxy', 'table', 'init'):                          # (the sims run from the repo's root)
        if getattr(a, k, None):
            setattr(a, k, os.path.abspath(getattr(a, k)))
    {'train': cmd_train, 'eval': cmd_eval}[a.cmd](a)


if __name__ == '__main__':
    main()

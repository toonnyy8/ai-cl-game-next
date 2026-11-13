#!/usr/bin/env python3
"""pop.py — the SP search's populations (PLAN.md §2 steps 1-2): seed them, and their payoff matrix and equilibrium mixes.

  python3 docs/research/strategy-drsi/sp/pop.py screen --me C --vs D [--margin 0.05] [--seed0 300] [--seeds 40] ARM.lisp...
      each ARM on C against D's `none`, both seats, K.O.s only (and C's `none` on the same seeds); writes pop/<pair>-<C>.json with the
      members `none` (the anchor), sp/arms/a-generic.lisp (the generic arm) and every ARM admitted:
        admitted = K.O. rate (matches ended before the bell, either side) >= 0.5 and score >= none's score + MARGIN,
        score = (K.O. wins + 1) / (matches + 2). Every ARM's numbers go into the file's "screen".
  python3 docs/research/strategy-drsi/sp/pop.py matrix --a C --b D [--seed0 200] [--seeds 100]
      every member of pop/<pair>-<C>.json against every member of pop/<pair>-<D>.json, both seats; per cell both sides' K.O. wins, the
      time-outs and the draws. Each side's mix by regret matching on its OWN K.O. win share (general-sum: a time-out is 0 to both, so it is
      not a win for the column player as strategy-matrix.py's zero-sum 1 - A would make it); writes pop/<pair>-matrix.json and each side's
      "mix" into its population file (eval.py's group "mix").
The matches are eval.py's (strategy-switch.py's run_job and cache, strat-run.lisp). tools/strategy-matrix.py is not used directly: its runner
strat-desc.lisp cannot play `none` (its no-strategy seat is the shipped HARD lookup) and strips the style CPU of a :fq / :switch strategy.
  python3 docs/research/strategy-drsi/sp/pop.py selftest      the solver and the mix pool on known cases (no sim)"""
import argparse, importlib.util, json, math, os, sys
import numpy as np
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
_e = importlib.util.spec_from_file_location('speval', os.path.join(HERE, 'eval.py'))
ev = importlib.util.module_from_spec(_e); _e.loader.exec_module(ev)
ss, ROOT = ev.ss, ev.ROOT
GENERIC = 'docs/research/strategy-drsi/sp/arms/a-generic.lisp'


def rel(p):
    return p if p == 'none' else os.path.relpath(os.path.abspath(p), ROOT)


def name(p):
    return 'none' if p == 'none' else os.path.splitext(os.path.basename(p))[0]


def summary(cnt, wins, base=None):
    m = cnt['matches']
    d = dict(cnt, ko_rate=round((cnt['ko_wins'] + cnt['ko_losses']) / m, 4), score=round((cnt['ko_wins'] + 1) / (m + 2), 4))
    if base is not None:                                 # paired against none on the same seed and seat
        b = sum(v == 1 and base[k] == 0 for k, v in wins.items()); c = sum(v == 0 and base[k] == 1 for k, v in wins.items())
        d.update(b=b, c=c, z=round((b - c) / math.sqrt(b + c), 3) if b + c else 0.0)
    return d


def screen(a):
    arms = ['none', GENERIC] + [x for x in a.arms if rel(x) != GENERIC]
    for x in arms[1:]:
        ev.check_cand(x)
    opp = ss.vs_spec('none')
    res = ev.play([ev.jobs(a.me, a.vs, ev.mine(x), opp, a.seed0, a.seeds) for x in arms], a.j)
    base = res[0][1]
    rows = {name(x): dict(file=rel(x), **summary(c, w, None if x == 'none' else base)) for x, (c, w) in zip(arms, res)}
    floor = rows['none']['score'] + a.margin
    for r in list(rows.values())[2:]:
        r['admitted'] = r['ko_rate'] >= 0.5 and r['score'] >= floor
    members = [dict(id='none', file='none', why='the anchor (no strategy: the shipped CPU, its matchup style CPU kept)'),
               dict(id=name(GENERIC), file=GENERIC, why='the generic arm (:st-generic: the generic CPU + MCTS, no style CPU)')]
    members += [dict(id=k, file=r['file'], why='an old arm that still K.O.s (screen)') for k, r in list(rows.items())[2:] if r['admitted']]
    path = os.path.join(HERE, 'pop', f'{ev.pair(a.me, a.vs)}-{ev.LETTER[a.me]}.json')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    doc = dict(pair=ev.pair(a.me, a.vs), side=a.me, vs=a.vs, anchor='none', members=members,
               screen=dict(vs="the opponent's none", seeds=f'{a.seed0 + 1}-{a.seed0 + a.seeds}', both_seats=True, margin=a.margin,
                           rule='K.O. rate >= 0.5 and score >= none + margin', build=ss.build_hash(), rows=rows))
    json.dump(doc, open(path, 'w'), indent=1)
    for k, r in rows.items():
        print(f"{k:20} KO {r['ko_wins']:3}:{r['ko_losses']:3} TO {r['timeouts']:3} dr {r['draws']:2} n {r['matches']} "
              f"rate {r['ko_rate']:.3f} score {r['score']:.3f} {('z %+.2f' % r['z']) if 'z' in r else ''} {'ADMIT' if r.get('admitted') else ''}")
    print('->', rel(path))


def solve(MA, MB, iters=20000):
    """General-sum regret matching: A (rows) maximises MA, B (columns) MB -> (x, y, A's gap, B's gap): each side's best pure reply to the
    other's average mix minus its mix's payoff (0 = a Nash equilibrium of the two-player game)."""
    r, c = MA.shape
    rr, rc, sx, sy = np.zeros(r), np.zeros(c), np.zeros(r), np.zeros(c)
    x, y = np.full(r, 1 / r), np.full(c, 1 / c)
    for _ in range(iters):
        sx += x; sy += y
        ur, uc = MA @ y, x @ MB
        rr += ur - x @ ur; rc += uc - y @ uc
        px, py = np.maximum(rr, 0), np.maximum(rc, 0)
        x = px / px.sum() if px.sum() > 0 else np.full(r, 1 / r)
        y = py / py.sum() if py.sum() > 0 else np.full(c, 1 / c)
    ax, ay = sx / sx.sum(), sy / sy.sum()
    return ax, ay, float((MA @ ay).max() - ax @ MA @ ay), float((ax @ MB).max() - ax @ MB @ ay)


def matrix(a):
    pr = ev.pair(a.a, a.b)
    pa, pb = (os.path.join(HERE, 'pop', f'{pr}-{ev.LETTER[c]}.json') for c in (a.a, a.b))
    A, B = json.load(open(pa)), json.load(open(pb))
    fa = [m['file'] if m['file'] == 'none' else os.path.join(ROOT, m['file']) for m in A['members']]
    fb = [m['file'] if m['file'] == 'none' else os.path.join(ROOT, m['file']) for m in B['members']]
    cells = [(i, k) for i in range(len(fa)) for k in range(len(fb))]
    res = ev.play([ev.jobs(a.a, a.b, ev.mine(fa[i]), ss.vs_spec(fb[k]), a.seed0, a.seeds) for i, k in cells], a.j)
    MA, MB = np.zeros((len(fa), len(fb))), np.zeros((len(fa), len(fb)))
    raw = []
    for (i, k), (cnt, _) in zip(cells, res):
        MA[i, k], MB[i, k] = cnt['ko_wins'] / cnt['matches'], cnt['ko_losses'] / cnt['matches']
        raw.append(dict(row=A['members'][i]['id'], col=B['members'][k]['id'], a_ko=cnt['ko_wins'], b_ko=cnt['ko_losses'],
                        timeouts=cnt['timeouts'], draws=cnt['draws'], matches=cnt['matches']))
    x, y, ga, gb = solve(MA, MB, a.iters)
    ra, cb = [m['id'] for m in A['members']], [m['id'] for m in B['members']]
    out = dict(a=a.a, b=a.b, seeds=f'{a.seed0 + 1}-{a.seed0 + a.seeds}', both_seats=True, build=ss.build_hash(), rows=ra, cols=cb,
               a_ko_share=np.round(MA, 4).tolist(), b_ko_share=np.round(MB, 4).tolist(), cells=raw,
               a_mix=dict(zip(ra, np.round(x, 3).tolist())), b_mix=dict(zip(cb, np.round(y, 3).tolist())),
               a_value=round(float(x @ MA @ y), 4), b_value=round(float(x @ MB @ y), 4), a_gap=round(ga, 4), b_gap=round(gb, 4))
    mpath = os.path.join(HERE, 'pop', f'{pr}-matrix.json')
    json.dump(out, open(mpath, 'w'), indent=1)
    for doc, path, mix in ((A, pa, out['a_mix']), (B, pb, out['b_mix'])):
        doc['mix'] = {k: v for k, v in mix.items() if v > 0}
        doc['mix_source'] = f"{rel(mpath)} (seeds {out['seeds']}, both seats, regret matching on own K.O. share)"
        json.dump(doc, open(path, 'w'), indent=1)
    print(f'{a.a} rows x {a.b} cols: cell = row K.O. share / col K.O. share (time-outs+draws = the rest)')
    print(' ' * 20 + ''.join(f'{c[:15]:>16}' for c in cb))
    for i, r in enumerate(ra):
        print(f'{r[:20]:20}' + ''.join(f'{MA[i, k]:>8.3f}/{MB[i, k]:.3f}' for k in range(len(cb))))
    print('a_mix', out['a_mix'], 'value', out['a_value'], 'gap', out['a_gap'])
    print('b_mix', out['b_mix'], 'value', out['b_value'], 'gap', out['b_gap'])


def selftest():
    """pop.py selftest: the solver and the mix pool on known cases (no sim)."""
    MA = np.array([[1., 0], [0, 1]])
    x, y, ga, gb = solve(MA, 1 - MA)
    assert np.allclose(x, .5, atol=.01) and np.allclose(y, .5, atol=.01) and ga < .01 and gb < .01   # matching pennies
    x, y, _, _ = solve(np.array([[.6, .6], [.2, .9]]), np.array([[.3, .1], [.7, .05]]))
    assert x[0] > .99 and y[0] > .99                     # B's column 0 dominates, A's best reply is row 0
    pool = ev.mix_pool({'n': .5, 'x': .33, 'y': .17}, {'n': 'N', 'x': 'X', 'y': 'Y'})
    assert [pool.count(k) for k in 'NXY'] == [10, 7, 3] and len(pool) == ev.SLOTS
    print('selftest ok')


def main():
    if sys.argv[1:] == ['selftest']:
        return selftest()
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest='cmd', required=True)
    s = sub.add_parser('screen')
    s.add_argument('--me', required=True, choices=list(ss.ROSTER)); s.add_argument('--vs', required=True, choices=list(ss.ROSTER))
    s.add_argument('--margin', type=float, default=0.05); s.add_argument('--seed0', type=int, default=300); s.add_argument('--seeds', type=int, default=40)
    s.add_argument('-j', type=int, default=6); s.add_argument('arms', nargs='+')
    m = sub.add_parser('matrix')
    m.add_argument('--a', required=True, choices=list(ss.ROSTER)); m.add_argument('--b', required=True, choices=list(ss.ROSTER))
    m.add_argument('--seed0', type=int, default=200); m.add_argument('--seeds', type=int, default=100)
    m.add_argument('--iters', type=int, default=20000); m.add_argument('-j', type=int, default=6)
    a = ap.parse_args()
    os.dup2(os.open(os.devnull, os.O_RDONLY), 0)
    ss.build()
    screen(a) if a.cmd == 'screen' else matrix(a)


if __name__ == '__main__':
    main()

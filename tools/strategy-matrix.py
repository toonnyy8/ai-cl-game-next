#!/usr/bin/env python3
"""strategy-matrix.py — the payoff matrix of one pairing and the admission test of a candidate strategy (docs/duel/DUEL_AI_STRATEGY.md §4, §8.2).

  python3 tools/strategy-matrix.py --a kenpachi --b ichigo --rows DIR_OR_FILES... --cols DIR_OR_FILES... [--cand FILE] [--seeds 20] [--eps 0.02]

rows = character A's strategies, columns = B's (files, dirs of *.lisp, or '@cpu' = the current CPU with its style, '@generic'); each cell = A's win
share, HARD, fixed seeds s0+1..s0+n, both seats (draws / time-outs count 0 for A: the matrix is NOT constant-sum when matches draw, the game below
takes B's payoff as 1 - A's). The meta-game's equilibrium is found by regret matching (--iters 20000): both mixes, the value (a lower bound = A's mix
against B's best column, an upper bound = B's mix against A's best row; a wide gap = not converged). With --cand FILE (a new row) the ADMISSION TEST:
  best response   the candidate's cell is the row's maximum (within --tie 0.0) in at least one column  -> "br_columns": [...]
  value           A's equilibrium value with the candidate minus without it >= --eps
admitted = either holds (the duplicate check, DUEL_AI_STRATEGY §3, and the behaviour descriptors are the caller's other filters).
Cells reuse tools/strategy-eval.py's cache (build/strategy-eval-cache/), so only new rows / columns cost anything. Output: one JSON.
"""
import argparse, importlib.util, json, os, sys
import numpy as np
sys.dont_write_bytecode = True
_p = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'strategy-eval.py')
_s = importlib.util.spec_from_file_location('strategy_eval', _p)
se = importlib.util.module_from_spec(_s)
_s.loader.exec_module(se)


def solve(M, iters=20000):
    """Zero-sum game, row player maximises M: regret matching (average strategies) -> (x, y, value lower bound, value upper bound)."""
    M = np.asarray(M, float)
    r, c = M.shape
    rr, rc = np.zeros(r), np.zeros(c)
    sx, sy = np.zeros(r), np.zeros(c)
    x, y = np.full(r, 1 / r), np.full(c, 1 / c)
    for _ in range(iters):
        sx += x; sy += y
        ur, uc = M @ y, -(x @ M)             # each player's payoff per pure action vs the other's current mix
        rr += ur - x @ ur; rc += uc - y @ uc
        px, py = np.maximum(rr, 0), np.maximum(rc, 0)
        x = px / px.sum() if px.sum() > 0 else np.full(r, 1 / r)
        y = py / py.sum() if py.sum() > 0 else np.full(c, 1 / c)
    ax, ay = sx / sx.sum(), sy / sy.sum()
    return ax, ay, float((ax @ M).min()), float((M @ ay).max())


def cells(a, b, rows, cols, n, s0, j):
    A, B = se.ROSTER[a], se.ROSTER[b]
    jobs = []
    for r in rows:
        for c in cols:
            jobs += [(A, B, r, c, 2, s0, n), (B, A, c, r, 2, s0, n)]
    outs = se.run_many(jobs, j)
    M = np.zeros((len(rows), len(cols)))
    for k in range(len(rows) * len(cols)):
        w1, m1, _ = se.parse(outs[2 * k], 'P1'); w2, m2, _ = se.parse(outs[2 * k + 1], 'P2')
        M[k // len(cols), k % len(cols)] = (w1 + w2) / max(1, m1 + m2)
    return M


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--a', required=True, choices=list(se.ROSTER)); ap.add_argument('--b', required=True, choices=list(se.ROSTER))
    ap.add_argument('--rows', nargs='+', required=True); ap.add_argument('--cols', nargs='+', required=True)
    ap.add_argument('--cand'); ap.add_argument('--seeds', type=int, default=20); ap.add_argument('--seed0', type=int, default=0)
    ap.add_argument('--eps', type=float, default=0.02); ap.add_argument('--tie', type=float, default=0.0)
    ap.add_argument('--iters', type=int, default=20000); ap.add_argument('-j', type=int, default=4)
    a = ap.parse_args()
    rows, cols = se.expand(a.rows), se.expand(a.cols)
    nm = lambda s: os.path.basename(s)
    M = cells(a.a, a.b, rows, cols, a.seeds, a.seed0, a.j)
    x, y, lo, hi = solve(M, a.iters)
    res = {'a': a.a, 'b': a.b, 'seeds': a.seeds, 'rows': [nm(r) for r in rows], 'cols': [nm(c) for c in cols],
           'matrix': np.round(M, 4).tolist(), 'row_mix': dict(zip(map(nm, rows), np.round(x, 3).tolist())),
           'col_mix': dict(zip(map(nm, cols), np.round(y, 3).tolist())), 'value': round((lo + hi) / 2, 4), 'value_bounds': [round(lo, 4), round(hi, 4)]}
    if a.cand:
        cr = cells(a.a, a.b, [a.cand], cols, a.seeds, a.seed0, a.j)[0]
        M2 = np.vstack([M, cr])
        x2, y2, lo2, hi2 = solve(M2, a.iters)
        br = [nm(c) for k, c in enumerate(cols) if cr[k] >= M[:, k].max() - a.tie]
        gain = (lo2 + hi2) / 2 - (lo + hi) / 2
        res['cand'] = {'file': a.cand, 'cells': np.round(cr, 4).tolist(), 'br_columns': br, 'value_with': round((lo2 + hi2) / 2, 4),
                       'value_gain': round(gain, 4), 'weight_in_mix': round(float(x2[-1]), 3), 'admitted': bool(br) or gain >= a.eps}
    print(json.dumps(res))


if __name__ == '__main__':
    main()

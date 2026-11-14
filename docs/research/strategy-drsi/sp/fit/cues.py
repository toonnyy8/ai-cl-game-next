#!/usr/bin/env python3
"""cues.py: would the cues :rb-sp left out (DUEL_AI_STRATEGY §11.3-§11.4: :ored, :awk, :oawk, :wall) carry signal? An offline refit only:
sw.py fit's design (the logged :rb-sp firing vectors) plus a crisp two-column group per extra cue (from the same fq lines), its ridge and its
bootstrap sign gate (sw.gated); prints how many deltas survive in each group, the :rb-sp groups included. No sim.

  python3 cues.py SW_COMMON_ARGS... --tag spfit/r1-k --seeds 201-400 [--gamma 0.966] [--lam 300] [--boot 20] [--conf 0.95]
"""
import argparse, os, sys
import numpy as np
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../fq/switch'))
import sw  # noqa: E402

ap = argparse.ArgumentParser()
for k in ('--me', '--vs', '--arms', '--tag', '--seeds'):
    ap.add_argument(k, required=True)
ap.add_argument('--rb', default=':rb-sp'); ap.add_argument('--ko', action='store_true'); ap.add_argument('--opp', default='none')
ap.add_argument('--gamma', type=float, default=0.966); ap.add_argument('--scale', type=float, default=0.1)
ap.add_argument('--lam', type=float, default=300.0); ap.add_argument('--lam-v', type=float, default=1.0)
ap.add_argument('--boot', type=int, default=20); ap.add_argument('--conf', type=float, default=0.95)
a = ap.parse_args()
sw.configure(a)
lo, hi = (int(x) for x in a.seeds.split('-'))
ms = sw.load(a.tag, lo, hi)
X, A, Y, U = sw.design(ms, a.gamma, a.scale)
# the extra cues, row for row in design's order (every judgement of every match with judgements); (tick, arm, greedy, h, dm, form, fire,
# oawk, gauge, wall, lead, ored, ost, awk)
EXTRA = {'ored': lambda j: j[11], 'awk': lambda j: j[13], 'oawk': lambda j: j[7], 'wall': lambda j: int(j[9] < 2.5)}   # (wall: :w-near's middle)
cols = {k: np.array([f(j) for m in ms if m['js'] for j in m['js']]) for k, f in EXTRA.items()}
Xe = np.hstack([X] + [np.stack([c == 0, c == 1], 1).astype(np.float32) for c in cols.values()])
groups = list(sw.GROUP_OF) + [len(sw.GROUPS) + i for i in range(len(EXTRA)) for _ in range(2)]
names = [f'G{g}' for g in range(len(sw.GROUPS))] + list(EXTRA)


def kept_per_group(arms):
    v, d, dg = sw.gated(Xe, arms, Y, U, len(ms), a.lam_v, a.lam, np.zeros((Xe.shape[1], sw.NA)), a.boot, a.conf)
    return dg, np.bincount([groups[r] for r in range(Xe.shape[1]) for k in range(sw.NA) if dg[r, k] != 0], minlength=len(names))


def placebo(rng):
    """The null that matches the exploration design: greedy rows keep their arm; each run of explored rows (arm != greedy, one arm, within
    a match) gets an arm redrawn uniformly from the others, as STRAT_FQLOG draws them. The gate's false positives at the runs' noise."""
    out, i = [], 0
    for m in ms:
        prev = None
        for j in m['js']:
            if j[1] == j[2]:
                out.append(j[1]); prev = None
                continue
            if prev is None or prev[0] != j[1]:
                prev = (j[1], rng.choice([k for k in range(sw.NA) if k != j[2]]))
            out.append(prev[1])
    return np.array(out)


dg, kept = kept_per_group(A)
nulls = np.array([kept_per_group(placebo(np.random.default_rng(seed)))[1] for seed in range(7, 12)])   # (five placebo draws)
print(f'{a.tag} {a.seeds}: {len(ms)} matches, {len(Y)} judgements, arms played {np.bincount(A, minlength=sw.NA).tolist()}')
print('share of judgements with the cue at 1: ' + ', '.join(f'{k} {c.mean():.3f}' for k, c in cols.items()))
form = np.array([j[5] for m in ms if m['js'] for j in m['js']])
print(f'awk agrees with G1 form >= 1 in {np.mean(cols["awk"] == (form >= 1)):.3f} of judgements')
print('kept deltas per group (cells): ' + ', '.join(f'{n} {int(x)}/{int(np.sum(np.array(groups) == i)) * sw.NA} (placebo {lo}-{hi})'
                                                   for i, (n, x, lo, hi) in enumerate(zip(names, kept, nulls.min(0), nulls.max(0)))))
# the randomised runs' effect on the outcome: per match, the K.O. win on the share of judgements explored into arm k (+ the pool member,
# seed mod 2), least squares; the runs start at random (sr-fq-u), so on a start-table log this is the effect of "a 3-9 s run of arm k".
w = np.array([float(m['win'] > 0) for m in ms])
for k in range(1, sw.NA):
    f = np.array([np.mean([j[1] == k and j[2] != k for j in m['js']]) if m['js'] else 0.0 for m in ms])
    Z = np.c_[np.ones(len(w)), f, [m['seed'] % 2 for m in ms]]
    beta = np.linalg.lstsq(Z, w, rcond=None)[0]
    r = w - Z @ beta
    se = np.sqrt((r @ r) / (len(w) - 3) * np.linalg.inv(Z.T @ Z)[1, 1])
    print(f'run effect of arm {k} on the K.O. win: {beta[1]:+.2f} per unit share (se {se:.2f}, z {beta[1] / se:+.2f}), mean share {f.mean():.3f}')

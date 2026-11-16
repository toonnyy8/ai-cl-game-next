#!/usr/bin/env python3
"""phase.py — arms6/hh: where the HH mirror's Konpaku go, per form (read only; finish.py's diag runner over the whole clock).

  python3 phase.py TABLE [--seed0 140] [--env K=V ...]   # TABLE: a raw table file both seats play ('-' = the game's lookup); --env e.g.
                                                          # STRAT_DIF_P1=easy STRAT_DIF_P2=masher (P1's side then reads 'P1')
-> per match: K.O. or not, the seconds each side spent per form, the Konpaku each side lost while it was in each form (sampled every 30
   ticks), pooled; and the seconds per Konpaku lost in each form (pace)."""
import collections, os, re, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '../../arms5/finish'))
import finish as fz  # noqa: E402

table = sys.argv[1]
fz.SEED0 = int(sys.argv[sys.argv.index('--seed0') + 1]) if '--seed0' in sys.argv else 140
env = {'FIN_SECS': '300', 'STRAT_FQLOG': '0 0'}
args = sys.argv[2:]
for i, x in enumerate(args):
    if x == '--env':
        k, v = args[i + 1].split('=', 1); env[k] = v
if table != '-':
    env.update(STRAT_P1=os.path.abspath(table), STRAT_P2=os.path.abspath(table))
fz.pin()
js = fz.jobs('hh', fz.DIAG, env, ('duel gate row ', 'fin '))
outs = fz.simlib.pool(fz.run, [j for _, j in js], 1)          # (one at a time: a mirror's two seat jobs can be the same job, one cache file)
secs = collections.Counter(); lost = collections.Counter(); arms = collections.Counter()
ko = n = 0
for (st, _), lines in zip(js, outs):
    last = {}
    for l in lines:
        m = fz.FINK.match(l)
        if not m:
            r = fz.ROWRE.search(l)
            if r:
                n += 1; ko += int(r[4])
            continue
        f = re.search(r' form (\S+) arm (\S+) ', l)
        side, k = m[3], int(m[4])
        key = (int(m[1]), side)
        seat = side                                            # (by seat: with STRAT_DIF_P<n> the tiers sit on fixed seats)
        secs[(seat, f[1])] += 0.5; arms[(f[1], f[2])] += 1
        if key in last and k < last[key]:
            lost[(seat, f[1])] += last[key] - k
        last[key] = k
print(f'{table}: {n} matches, K.O. {ko / max(1, n):.3f}')
for sd, form in sorted(secs):
    print(f'  {sd} {form:12s} side-seconds {secs[(sd, form)]:8.0f}  Konpaku lost {lost[(sd, form)]:4d}  s / Konpaku '
          f'{secs[(sd, form)] / max(1, lost[(sd, form)]):6.1f}')
print('  arms by form (both sides):', dict(arms))

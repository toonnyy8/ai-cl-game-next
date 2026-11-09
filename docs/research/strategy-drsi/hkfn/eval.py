#!/usr/bin/env python3
"""eval.py — the frozen evaluator of the HK style-code search (DUEL_AI_STRATEGY §8.19 round 5, step 7): Hisagi playing the style function
(cand-hkfn.lisp: `(:id :hkfn :fn hisagi-hk-style :ken-ranged t)`, played whole, HARD) against Kenpachi's pool, both seats, in this checkout's
native build.

Kenpachi's pool (fixed before round 1), four groups:
  live     his live KH table :qks5-hisagi (fq/switch/khevent/kh-t0.lisp: the bait as its event layer), 100 seeds a seat
  past     his earlier KH tables :qks4-hisagi, :qks3-hisagi, :qks2-hisagi, :qks-hisagi, 50 each
  arms     his 11 step-4 candidate arms played whole (khjoint/k/*.lisp) + the bait and the stand-off breaker played whole, 20 each
  standin  his KI style CPU (counter/frozen/ki-ken.lisp), 50
  score = the mean of the four groups' shares, each (wins + 1) / (matches + 2) over its members pooled (positive, higher is better).
Blocks (seed0): 200 = the search (the coordinator's rescore), 300 = the cells' dev runs, 400 = held-out (the keep decision; no cell sees it).
1,220 matches at scale 1 (--scale 0.5 halves them). inc_live = the live HK lookup's own share against the live KH (a tripwire).
usage: eval.py [--seed0 300] [--scale 1] [-j 5] [--cand FILE]   -> one JSON line on stdout"""
import glob, json, os, subprocess, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../..'))
SD = os.path.join(ROOT, 'docs/research/strategy-drsi')
SW = os.path.join(SD, 'fq/switch')
args = sys.argv[1:]
opt = lambda k, d: args[args.index(k) + 1] if k in args else d
seed0, scale, j = int(opt('--seed0', 300)), float(opt('--scale', 1)), opt('-j', '5')
cand = os.path.abspath(opt('--cand', os.path.join(HERE, 'cand-hkfn.lisp')))
POOL = ([('live', os.path.join(SW, 'khevent/kh-t0.lisp'), 100)]
        + [('past', os.path.join(SW, p), 50) for p in ('khevent/kh-t2.lisp', 'khstyle/kh-t2.lisp', 'khjoint/kh-t2.lisp', 'kenpachi/qks-hisagi.lisp')]
        + [('arms', p, 20) for p in sorted(glob.glob(os.path.join(SW, 'khjoint/k/*.lisp')))]
        + [('arms', os.path.join(SD, 'khfn', f), 20) for f in ('cand-khfn.lisp', 'cand-standoff.lisp')]
        + [('standin', os.path.join(SD, 'counter/frozen/ki-ken.lisp'), 50)])
groups, members, inc_live = {}, {}, None
for g, m, n in POOL:
    n = max(1, int(n * scale))
    r = subprocess.run([sys.executable, 'tools/strategy-switch.py', '--char', 'hisagi', '--vs', 'kenpachi', '--vs-strat', m,
                        '--cand', cand, '--raw', '--seed0', str(seed0), '--seeds', str(n), '-j', j], cwd=ROOT, capture_output=True, text=True)
    if r.returncode:
        sys.exit(f'eval: strategy-switch failed on {m}: {r.stderr[-1500:]}')
    d = json.loads(r.stdout)
    name = os.path.splitext(os.path.basename(m))[0]
    members[name if name not in members else os.path.basename(os.path.dirname(m)) + '/' + name] = d['comp_share']
    if g == 'live':
        inc_live = d['inc_share']   # (the live HK lookup against the live KH on the same seeds: a tripwire, it must not move)
    w, k = groups.get(g, (0, 0))
    groups[g] = (w + d['comp_wins'], k + d['comp_matches'])
share = {g: round((w + 1) / (k + 2), 4) for g, (w, k) in groups.items()}
print(json.dumps(dict(seed0=seed0, scale=scale, score=round(sum(share.values()) / len(share), 4), groups=share,
                      matches=sum(k for _, k in groups.values()), members=members, inc_live=inc_live)))

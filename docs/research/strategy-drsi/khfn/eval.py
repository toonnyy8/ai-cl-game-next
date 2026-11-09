#!/usr/bin/env python3
"""eval.py — the frozen evaluator of the KH style-code search (DUEL_AI_STRATEGY §8.19 round 5, step 5): Kenpachi playing the style function
(cand-khfn.lisp: `(:id :khfn :fn ken-kh-style)`, played whole, HARD) against Hisagi's pool, both seats, in this checkout's native build.

Hisagi's pool (fixed before round 1): his live table :qhs-ken (fq/switch/corefit/hk-r1.lisp), step 4's two HK iterates (khjoint/hk-t1, hk-t2)
and his 11 step-4 candidate arms played whole (khjoint/h/*.lisp).
  score = (live + iterates + arms) / 3, each group's share (wins + 1) / (matches + 2) over its members pooled (positive, higher is better).
Blocks (seed0): 200 = the search (the coordinator's rescore), 300 = the cells' dev runs, 400 = held-out (the keep decision; no cell sees it).
Seeds a seat: the live table 100, each iterate 50, each arm 25 (950 matches; --scale 0.5 halves them all).
usage: eval.py [--seed0 300] [--scale 1] [-j 5] [--fn ken-kh-style] [--cand FILE]   -> one JSON line on stdout"""
import glob, json, os, subprocess, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../..'))
SW = os.path.join(ROOT, 'docs/research/strategy-drsi/fq/switch')
args = sys.argv[1:]
opt = lambda k, d: args[args.index(k) + 1] if k in args else d
seed0, scale, j = int(opt('--seed0', 300)), float(opt('--scale', 1)), opt('-j', '5')
cand = os.path.abspath(opt('--cand', os.path.join(HERE, 'cand-khfn.lisp')))
POOL = [('live', 'corefit/hk-r1.lisp', 100)] + [('iterates', f'khjoint/hk-t{t}.lisp', 50) for t in (1, 2)] + \
       [('arms', os.path.relpath(p, SW), 25) for p in sorted(glob.glob(os.path.join(SW, 'khjoint/h/*.lisp')))]
groups, members = {}, {}
for g, m, n in POOL:
    n = max(1, int(n * scale))
    r = subprocess.run([sys.executable, 'tools/strategy-switch.py', '--char', 'kenpachi', '--vs', 'hisagi', '--vs-strat', os.path.join(SW, m),
                        '--cand', cand, '--raw', '--seed0', str(seed0), '--seeds', str(n), '-j', j], cwd=ROOT, capture_output=True, text=True)
    if r.returncode:
        sys.exit(f'eval: strategy-switch failed on {m}: {r.stderr[-1500:]}')
    d = json.loads(r.stdout)
    members[os.path.splitext(os.path.basename(m))[0]] = d['comp_share']
    if g == 'live':
        inc_live = d['inc_share']   # (the live KH lookup against the live HK on the same seeds: a tripwire, it must not move)
    w, k = groups.get(g, (0, 0))
    groups[g] = (w + d['comp_wins'], k + d['comp_matches'])
share = {g: round((w + 1) / (k + 2), 4) for g, (w, k) in groups.items()}
print(json.dumps(dict(seed0=seed0, scale=scale, score=round(sum(share.values()) / 3, 4), groups=share,
                      matches=sum(k for _, k in groups.values()), members=members, inc_live=inc_live)))

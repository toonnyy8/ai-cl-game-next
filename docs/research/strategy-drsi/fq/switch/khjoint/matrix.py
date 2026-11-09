#!/usr/bin/env python3
"""matrix.py — the joint KH / HK arm search's game matrix (DUEL_AI_STRATEGY §8.19 round 5, step 4), from the switch directory. Every Kenpachi
strategy (the candidates in khjoint/k/ + his live table :qks-hisagi + his past one :q1-ken-hisagi) against every Hisagi strategy (khjoint/h/ + his
live :qhs-ken + his past :qh-ken), played whole (tools/strategy-switch.py --raw, HARD, both seats), and every Hisagi candidate against the
stand-in (Kenpachi's KI style CPU). One JSON a cell in khjoint/m/; then a summary -> khjoint/matrix.json.
usage: matrix.py [--seed0 0] [--seeds 100] [--tag ''] [--only-summary]
Hisagi's share in a Kenpachi row is 1 - Kenpachi's (draws, which count 0 for both, are rare and ignored)."""
import glob, json, os, subprocess, sys
sys.dont_write_bytecode = True
SW = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(SW, '../../../../..'))
args = sys.argv[1:]
opt = lambda k, d: args[args.index(k) + 1] if k in args else d
seed0, n, tag = int(opt('--seed0', 0)), int(opt('--seeds', 100)), opt('--tag', '')
M = os.path.join(SW, 'khjoint', 'm' + tag)
KT = {'K-live': 'kenpachi/qks-hisagi.lisp', 'K-past': '../pairs/kh/kh-fit.lisp'}
HT = {'H-live': 'corefit/hk-r1.lisp', 'H-past': 'arms/ship-qh-ken.lisp'}
FZK = '../../counter/frozen/ki-ken.lisp'
name = lambda p: os.path.splitext(os.path.basename(p))[0]
KC = {name(p): os.path.relpath(p, SW) for p in sorted(glob.glob(os.path.join(SW, 'khjoint/k/*.lisp')))}
HC = {name(p): os.path.relpath(p, SW) for p in sorted(glob.glob(os.path.join(SW, 'khjoint/h/*.lisp')))}
ROWS, COLS = {**KC, **KT}, {**HC, **HT}


def cell(char, vs, cand, opp, out):
    if os.path.exists(out): return json.load(open(out))
    r = subprocess.run([sys.executable, 'tools/strategy-switch.py', '--char', char, '--vs', vs, '--vs-strat', os.path.join(SW, opp), '--cand',
                        os.path.join(SW, cand), '--raw', '--seed0', str(seed0), '--seeds', str(n), '-j', os.environ.get('J', '20')],
                       cwd=ROOT, capture_output=True, text=True, check=True)
    open(out, 'w').write(r.stdout); print(os.path.basename(out), json.loads(r.stdout)['comp_share'], flush=True)
    return json.loads(r.stdout)


if __name__ == '__main__':
    os.makedirs(M, exist_ok=True)
    k = {(r, c): cell('kenpachi', 'hisagi', ROWS[r], COLS[c], os.path.join(M, f'{r}__{c}.json'))['comp_share']
         for r in ROWS for c in COLS} if '--only-summary' not in args else \
        {tuple(os.path.basename(p)[:-5].split('__')): json.load(open(p))['comp_share'] for p in glob.glob(os.path.join(M, '*__*.json'))}
    fz = {h: cell('hisagi', 'kenpachi', HC[h], FZK, os.path.join(M, f'{h}--FZK.json'))['comp_share'] for h in HC}
    mean = lambda xs: round(sum(xs) / len(xs), 4)
    out = {'seeds': f'{seed0 + 1}-{seed0 + n}', 'kenpachi': {}, 'hisagi': {}}
    for r in ROWS:   # Kenpachi: against Hisagi's tables (live, past) and his new candidates
        v = {c: k[r, c] for c in COLS}
        out['kenpachi'][r] = dict(live=v['H-live'], past=v['H-past'], cands=mean([v[c] for c in HC]), worst=min(v.values()),
                                  pool=mean([v['H-live'], v['H-past'], mean([v[c] for c in HC])]), row=v)
    for c in COLS:   # Hisagi: against Kenpachi's tables, the stand-in and his new candidates
        v = {r: round(1 - k[r, c], 4) for r in ROWS}
        e = dict(live=v['K-live'], past=v['K-past'], cands=mean([v[r] for r in KC]), worst=min(v.values()), col=v)
        if c in fz: e['standin'] = fz[c]
        e['pool'] = mean([v['K-live'], v['K-past'], e['cands']] + ([fz[c]] if c in fz else []))
        out['hisagi'][c] = e
    json.dump(out, open(os.path.join(SW, 'khjoint', f'matrix{tag}.json'), 'w'), indent=1)
    for side in ('kenpachi', 'hisagi'):
        print(side)
        for s, e in sorted(out[side].items(), key=lambda x: -x[1]['pool']):
            print(f"  {s:12s} pool {e['pool']:.3f} live {e['live']:.3f} past {e['past']:.3f} cands {e['cands']:.3f} worst {e['worst']:.3f}"
                  + (f" standin {e['standin']:.3f}" if 'standin' in e else ''))

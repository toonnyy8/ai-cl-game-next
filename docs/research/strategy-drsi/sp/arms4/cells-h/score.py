#!/usr/bin/env python3
"""score.py — PLAN4 §3's scorer for Hisagi's B3 cells: the played policy, not the whole game. The cell's arm (one raw inline plist) is put
in its slot of Hisagi's T0 for the pairing (t0/kh-hisagi.json, t0/ih-hisagi.json: band.py t0 --or, q 0.06, :rb-sp2, :keep-state t, :with
the pairing's exchange unit), and that table is scored by eval.py (K.O.-only) against the opponent's groups: his `none` and his T0
(pop-kh-K.json, pop-ih-I.json; no mix, so the mix group is a 50/50 pool of the two).

  python3 score.py --slot press --arm NODE/arm.lisp --vs kenpachi|ichigo|both [--seed0 300] [-j 3]
  -> one JSON line: score (both: the mean of the two pairings, 50 seeds a seat each, so the same 600 matches as one eval.py block),
     per pairing eval.py's groups; the tables written beside the arm as cand-kh.lisp / cand-ih.lisp.
Slots: range press kite wake (general: both tables), hoho6 (KH only), ihx (IH only). SP_BUILD defaults to the B3 cells' pin."""
import argparse, json, os, re, subprocess, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
SP = os.path.abspath(os.path.join(HERE, '../..'))
ROOT = os.path.abspath(os.path.join(SP, '../../../..'))
PAIR = {'kenpachi': ('kh', 't0/kh-hisagi.json', 'pop-kh-K.json', '../x-units/d-x-kh-h.lisp'),
        'ichigo': ('ih', 't0/ih-hisagi.json', 'pop-ih-I.json', '../x-units/d-x-ih-h.lisp')}
SLOTS = {'range': 'kenpachi ichigo', 'press': 'kenpachi ichigo', 'kite': 'kenpachi ichigo', 'wake': 'kenpachi ichigo',
         'hoho6': 'kenpachi', 'ihx': 'ichigo'}


def table(vs, slot, arm, out):
    """Hisagi's T0 for VS with ARM in SLOT's place -> OUT (band.py t0)."""
    p, mp, _, unit = PAIR[vs]
    m = json.load(open(os.path.join(HERE, mp)))
    base = os.path.dirname(os.path.join(HERE, mp))
    arms = [os.path.abspath(os.path.join(base, a)) for a in m['arms']]
    k = [i for i, a in enumerate(arms) if os.path.basename(a) == f'h4-{slot}.lisp']
    if len(k) != 1:
        sys.exit(f'score: slot {slot} is not in {mp}')
    arms[k[0]] = os.path.abspath(arm)
    tmp = os.path.join(os.path.dirname(out), f'map-{p}.json')
    json.dump(dict(m, arms=[os.path.relpath(x, os.path.dirname(tmp)) for x in arms]), open(tmp, 'w'))   # (relative: band.py reads them from the map's dir)
    r = subprocess.run([sys.executable, os.path.join(SP, 'band.py'), 't0', '--me', 'hisagi', '--vs', vs, '--map', tmp, '--out', out,
                        '--with', os.path.relpath(os.path.join(HERE, unit), ROOT), '--or', '--q', '0.06'], capture_output=True, text=True, cwd=ROOT)
    if r.returncode:
        sys.exit(f'score: band.py t0 failed: {r.stderr[-1500:]}')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--slot', required=True, choices=list(SLOTS)); ap.add_argument('--arm', required=True)
    ap.add_argument('--vs', required=True, choices=('kenpachi', 'ichigo', 'both')); ap.add_argument('--seed0', type=int, default=300)
    ap.add_argument('-j', type=int, default=3)
    a = ap.parse_args()
    if a.seed0 not in (200, 300):
        sys.exit('score: --seed0 300 (the cells) or 200 (the coordinator\'s rescore) only')
    vss = ['kenpachi', 'ichigo'] if a.vs == 'both' else [a.vs]
    if any(v not in SLOTS[a.slot].split() for v in vss):
        sys.exit(f'score: slot {a.slot} plays only vs {SLOTS[a.slot]}')
    text = re.sub(r';[^\n]*', '', open(a.arm).read()).strip()
    if not text.startswith('(') or text.count('(') != text.count(')') or not re.search(r':apply\s+\(:hisagi\)', text):
        sys.exit(f'score: {a.arm}: not one inline plist with :apply (:hisagi)')
    os.environ.setdefault('SP_BUILD', 'b835ac41b83b')
    seeds = 100 if len(vss) == 1 else 50
    out, scores = {}, []
    for vs in vss:
        p, _, pop, _ = PAIR[vs]
        cand = os.path.join(os.path.dirname(os.path.abspath(a.arm)), f'cand-{p}.lisp')
        table(vs, a.slot, a.arm, cand)
        r = subprocess.run([sys.executable, os.path.join(SP, 'eval.py'), '--me', 'hisagi', '--vs', vs, '--cand', cand, '--seed0', str(a.seed0),
                            '--seeds', str(seeds), '--pop', os.path.join(HERE, pop), '-j', str(a.j)], capture_output=True, text=True, cwd=ROOT)
        if r.returncode:
            sys.exit(f'score: eval.py ({vs}) exited {r.returncode}: {(r.stdout + r.stderr)[-1500:]}')
        d = json.loads(r.stdout.strip().splitlines()[-1])
        scores.append(d['score'])
        out[p] = dict(score=d['score'], groups={g: dict(ko_wins=v['ko_wins'], ko_losses=v['ko_losses'], timeouts=v['timeouts'],
                                                        matches=v['matches']) for g, v in d['groups'].items()}, build=d['build'][:12])
    print(json.dumps(dict(slot=a.slot, arm=os.path.relpath(os.path.abspath(a.arm), ROOT), seed0=a.seed0, seeds_a_seat=seeds,
                          score=round(sum(scores) / len(scores), 4), pairings=out)))


if __name__ == '__main__':
    main()

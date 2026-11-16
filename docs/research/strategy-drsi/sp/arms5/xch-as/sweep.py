#!/usr/bin/env python3
"""sweep.py — the SA's reaction window after a cancel (DUEL_CORE §2.1.3; the user, 2026-11-16: 「相消後的 AS 前搖拉長」): scripted scenes
through tools/simgate/trial.lisp, no CPU. The J side's J1 cancels the NS side's first segment; the J side presses SP (its AS) one sim frame
after the cancel; the NS side presses J (its SA) n frames after that AS press. Per case: the n at which the SA side's hit lands first.

  python3 sweep.py [--fas build/simgate/duel.fas] [--only kh,hk,ki,combo]

Scenes: kh  Bankai Hisagi's NSa (P1, ptr 1 / 2, unbound / bound) x Kenpachi's J1 (P2; base / nozarashi / bankai) at 1.2 / 1.8 / 2.4 m
        hk  Hisagi's J1 (P1; base / bankai) x Kenpachi's NS1a (P2), Hisagi's AS1, Kenpachi's SA at +n
        ki  Ichigo's NS1a (P1; base / kessa) x Kenpachi's J1 (P2), Kenpachi's AS, Ichigo's SA at +n
        combo  a J1 that really hits a standing dummy, then SP on the hit: the AS's start and hit tick (unchanged by the rule)
"""
import argparse, os, re, subprocess, sys, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import simlib  # noqa: E402

T = re.compile(r'^\[\s*(\d+)\] (P[12]) (.*)$')
NS_ = (0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28)


def run(fas, trials):
    with tempfile.NamedTemporaryFile('w', suffix='.lisp', delete=False, dir=os.path.join(ROOT, 'build')) as f:
        f.write('\n'.join(trials) + '\n'); p = f.name
    try:
        r = subprocess.run([simlib.ECL, '--norc', '--load', 'tools/simgate/trial.lisp', '--', fas, p], cwd=ROOT, capture_output=True,
                           text=True, timeout=1800, env=dict(os.environ, LD_PRELOAD=simlib.MUSLM))
    finally:
        os.unlink(p)
    if r.returncode:
        sys.exit((r.stdout + r.stderr)[-3000:])
    out, name, cur = {}, None, []
    for l in r.stdout.splitlines():
        if 'trial begin ' in l: name, cur = l.split('trial begin ', 1)[1].strip(), []
        elif 'trial end ' in l and name: out[name] = cur; name = None
        elif name: cur.append(l)
    return out


def ev(lines):
    t0, res = None, []
    for l in lines:
        m = T.match(l)
        if not m: continue
        t = int(m[1]); t0 = t if t0 is None else t0
        res.append((t - t0, m[2], m[3]))
    return res


def first_hit(lines):
    """(side, move, tick) of the first real hit, or None."""
    for k, s, r in ev(lines):
        m = re.search(r'-> P([12]) (HIT|COUNTER)', r)
        if m: return s, r.split()[0], k
    return None


def cancel_at(lines):
    return next((k for k, s, r in ev(lines) if ': CANCEL' in r), None)


def sweep(fas, name, cases, head, ns_side, open_press, j_side):
    """CASES: tuples for HEAD(case) -> the trial head; OPEN_PRESS(case): (p1 script, p2-at list) that makes the cancel. J_SIDE 'P1'/'P2'
    presses SP one frame after the cancel; NS_SIDE presses J n frames after that."""
    o1 = run(fas, [f'(:name "c|{i}" {head(c)} {open_press(c, [], [])})' for i, c in enumerate(cases)])
    canc = {i: cancel_at(o1.get(f'c|{i}', [])) for i in range(len(cases))}
    tr = []
    for i, c in enumerate(cases):
        if canc[i] is None: continue
        a = canc[i] + 1
        jp = [(a, ':sp')]
        for n in ('none',) + NS_:
            sp = [] if n == 'none' else [(a + n, ':j')]
            p1, p2 = (jp, sp) if j_side == 'P1' else (sp, jp)
            tr.append(f'(:name "x|{i}|{n}" {head(c)} {open_press(c, p1, p2)})')
    o2 = run(fas, tr)
    rows = []
    for i, c in enumerate(cases):
        if canc[i] is None:
            rows.append((c, None, None, None)); continue
        wins, alone = [], first_hit(o2.get(f'x|{i}|none', []))
        for n in NS_:
            h = first_hit(o2.get(f'x|{i}|{n}', []))
            if h and h[0] == ns_side: wins.append(n)
        rows.append((c, canc[i], alone, wins))
    print(f'## {name}')
    for c, ct, alone, wins in rows:
        if ct is None:
            print(f'{c}: no cancel'); continue
        rng = f'+{wins[0]}..+{wins[-1]}' if wins else '-'
        holes = sorted(set(range(wins[0], wins[-1] + 1, 2)) - set(wins)) if wins else []
        print(f'{c} cancel@{ct} AS alone={alone and f"{alone[1]}@{alone[2]}"} SA wins {rng}{" holes " + str(holes) if holes else ""}')
    return rows


def at(lst):
    return '(' + ' '.join(f'({f} {b})' for f, b in lst) + ')'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--fas', default=simlib.FAS)
    ap.add_argument('--only', default='kh,hk,ki,combo')
    a = ap.parse_args()
    if a.fas == simlib.FAS: simlib.build()
    only = a.only.split(',')
    kf = (':base', ':nozarashi', ':bankai')
    if 'kh' in only:
        cases = [(hf, hp, k, d) for hf, hp in ((':bankai', 1), (':bankai', 2), (':bankai-bind', 1), (':bankai-bind', 2)) for k in kf
                 for d in (1.2, 1.8, 2.4)]
        sweep(a.fas, 'kh: Bankai Hisagi NSa (P1) x Kenpachi J1 (P2) -> his AS, her SA at +n', cases,
              lambda c: (f':p1 :hisagi :form {c[0]}{" :p1-bound t" if c[0] == ":bankai-bind" else ""} :p2 :kenpachi :p2-form {c[2]} '
                         f':ptr {c[1]} :p2-ptr 1 :fs 300 :frames 200 :seed 1 :dist {c[3]}'),
              'P1', lambda c, p1, p2: f':script ((:quick 1 :modded t :wait 2)) :p2-at {at([(0, ":j")] + p2)} :p1-at {at(p1)}', 'P2')
    if 'hk' in only:
        cases = [(hf, k, d) for hf in (':base', ':bankai') for k in kf for d in (1.2, 1.8, 2.4)]
        sweep(a.fas, 'hk: Hisagi J1 (P1) x Kenpachi NS1a (P2) -> his AS1, Kenpachi SA at +n', cases,
              lambda c: f':p1 :hisagi :form {c[0]} :p2 :kenpachi :p2-form {c[1]} :ptr 1 :p2-ptr 1 :fs 300 :p2-fs 300 :frames 200 :seed 1 :dist {c[2]}',
              'P2', lambda c, p1, p2: f':script ((:quick 1 :wait 2)) :p2-at {at([(0, ":sp")] + p2)} :p1-at {at(p1)}', 'P1')
    if 'ki' in only:
        cases = [(icf, k, d) for icf in (':base', ':kessa') for k in kf for d in (1.2, 1.8, 2.4)]
        sweep(a.fas, 'ki: Ichigo NS1a (P1) x Kenpachi J1 (P2) -> his AS, Ichigo SA at +n', cases,
              lambda c: f':p1 :ichigo :form {c[0]} :p2 :kenpachi :p2-form {c[1]} :ptr 1 :p2-ptr 1 :fs 300 :frames 200 :seed 1 :dist {c[2]}',
              'P1', lambda c, p1, p2: f':script ((:quick 1 :modded t :wait 2)) :p2-at {at([(0, ":j")] + p2)} :p1-at {at(p1)}', 'P2')
    if 'combo' in only:
        tr = []
        for ch, forms in ((':kenpachi', kf), (':hisagi', (':base', ':bankai')), (':ichigo', (':base', ':kessa'))):
            for fm in forms:
                d = 4.5 if (ch, fm) == (':hisagi', ':bankai') else 1.5
                tr.append(f'(:name "{ch} {fm}" :p1 {ch} :form {fm} :p2 :kenpachi :p2-form :base :ptr 1 :fs 300 :frames 150 :dist {d} '
                          f':script ((:quick 1) (:quick 1 :modded t :on :hit)))')
        o = run(a.fas, tr)
        print('## combo: J1 real hit -> SP on the hit (standing dummy, 1.5 m; Bankai Hisagi 4.5 m, his dead zone)')
        for name, lines in o.items():
            e = ev(lines)
            mv = [(k, r.split()[1]) for k, s, r in e if s == 'P1' and r.startswith('move ')]
            hits = [(k, r.split()[0]) for k, s, r in e if s == 'P1' and re.search(r'-> P2 (HIT|COUNTER)', r)]
            print(f'{name}: moves {mv[:3]} hits {hits[:4]}')


if __name__ == '__main__':
    main()

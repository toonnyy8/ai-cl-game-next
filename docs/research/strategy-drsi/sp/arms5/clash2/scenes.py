#!/usr/bin/env python3
"""scenes.py — arms5/clash2.md's scripted clash scenes (tools/simgate/trial.lisp; written presses for both sides, no CPU): Hisagi's
Shikai (P1) against sealed Kenpachi (P2) at 1.2 / 1.8 / 2.4 / 2.9 m.

  python3 docs/research/strategy-drsi/sp/arms5/clash2/scenes.py [GROUP ...] [--fas build/simgate/duel.fas] [--all]

Groups: a0 / b0 the cancel alone; a his J1, Hisagi's NAGI (pointer 1 NS) into it, then his AS at once vs Hisagi's SA 4 / 8 / 12
frames after the AS starts (and no SA); b his NS1a, Hisagi's J1 into it, then Hisagi's AS1 TSUMUJI vs his answers. Prints each scene's
combat log (moves, cancels, hits; --all: every line) and a one-line verdict.
"""
import os, re, subprocess, sys, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '../../../../../../tools'))
import simlib  # noqa: E402

DISTS = (1.2, 1.8, 2.4, 2.9)
HEAD = ':p1 :hisagi :form :base :p2 :kenpachi :p2-form :base :ptr 1 :fs 300 :frames 160 :seed 1 :p2-ptr 1'
# Ticks read from a0 / b0 (the sim frame his press is on, p2-at counts sim frames; the scene's tick 0 is his press).
AS_AT = 10            # his SP press for the AS: one sim frame after the cancel (his J1's hit on S9: the cancel on sim frame 9)
AS_START = 11         # his AS's first frame, sim frames (read from the a scenes without an SA)


def scenes(group):
    for d in DISTS:
        if group == 'a0':
            yield f'(:name "a0|{d}" {HEAD} :dist {d} :script ((:quick 1 :modded t :wait 2)) :p2-at ((0 :j)))'
        elif group == 'b0':
            yield f'(:name "b0|{d}" {HEAD} :dist {d} :script ((:quick 1 :wait 2)) :p2-at ((0 :sp)))'
        elif group == 'a':
            yield f'(:name "a|{d}|his AS, no SA" {HEAD} :dist {d} :script ((:quick 1 :modded t :wait 2)) :p2-at ((0 :j) ({AS_AT} :sp)))'
            for n in (0, 4, 8, 12, 16, 24, 32):   # SA = her J press in the NS after the cancel, n sim frames after his AS's press (:p1-at)
                yield (f'(:name "a|{d}|his AS, SA +{n}" {HEAD} :dist {d} :script ((:quick 1 :modded t :wait 2))'
                       f' :p2-at ((0 :j) ({AS_AT} :sp)) :p1-at (({AS_AT + n} :j)))')
        elif group == 'r':   # the same in his Bankai's ranged mode (its J and NS have dead zones too): ra = his J1 into her ranged NS1a,
            h = HEAD.replace(':form :base', ':form :bankai')   # then his AS vs her SA; rb = his NS1a, her ranged J1 into it, then RANSA
            yield f'(:name "ra|{d}|his AS, no SA" {h} :dist {d} :script ((:quick 1 :modded t :wait 2)) :p2-at ((0 :j) ({AS_AT} :sp)))'
            yield (f'(:name "ra|{d}|his AS, SA +8" {h} :dist {d} :script ((:quick 1 :modded t :wait 2))'
                   f' :p2-at ((0 :j) ({AS_AT} :sp)) :p1-at (({AS_AT + 8} :j)))')
            for tag, at in (('none', ''), ('SA +8', ' (23 :j)')):
                yield (f'(:name "rb|{d}|AS1 vs his {tag}" {h} :dist {d} :script ((:quick 1 :wait 2) (:quick 1 :modded t :on :hit))'
                       f' :p2-at ((0 :sp){at}))')
                yield (f'(:name "rb|{d}|J2 vs his {tag}" {h} :dist {d} :script ((:quick 1 :wait 2) (:quick 1 :on :hit))'
                       f' :p2-at ((0 :sp){at}))')
        elif group == 'awin' and d == 1.8:   # the SA window's late edge, sim frames after his AS press
            for n in range(1, 4):
                yield (f'(:name "awin|{d}|SA +{n}" {HEAD} :dist {d} :script ((:quick 1 :modded t :wait 2))'
                       f' :p2-at ((0 :j) ({AS_AT} :sp)) :p1-at (({AS_AT + n} :j)))')
            for n in range(17, 24):
                yield (f'(:name "awin|{d}|SA +{n}" {HEAD} :dist {d} :script ((:quick 1 :modded t :wait 2))'
                       f' :p2-at ((0 :j) ({AS_AT} :sp)) :p1-at (({AS_AT + n} :j)))')
        elif group == 'reach' and d == 2.9:   # where his J1 stops reaching her NAGI's startup (the a0 scene at 2.5-2.8 m)
            for dd in (2.5, 2.6, 2.7, 2.8):
                yield f'(:name "reach|{dd}" {HEAD} :dist {dd} :script ((:quick 1 :modded t :wait 2)) :p2-at ((0 :j)))'
        elif group == 'b':
            for tag, at in (('none', ''), ('SA +2', ' (17 :j)'), ('SA +8', ' (23 :j)'), ('NS1b +2', ' (17 :sp)'), ('J', ' (12 :j)')):
                yield (f'(:name "b|{d}|AS1 vs his {tag}" {HEAD} :dist {d} :script ((:quick 1 :wait 2) (:quick 1 :modded t :on :hit))'
                       f' :p2-at ((0 :sp){at}))')


KEEP = re.compile(r'trial begin|trial end|\] P[12] (move |press |.* x P[12]: |.*-> P[12] |KIN |BREAK |dealt |refused)')


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    fas = next((sys.argv[i + 1] for i, a in enumerate(sys.argv) if a == '--fas'), simlib.FAS)
    lines = [s for g in (args or ['a0', 'b0']) for s in scenes(g)]
    with tempfile.NamedTemporaryFile('w', suffix='.lisp', delete=False, dir=os.path.join(simlib.ROOT, 'build')) as f:
        f.write('\n'.join(lines) + '\n'); p = f.name
    try:
        r = subprocess.run([simlib.ECL, '--norc', '--load', 'tools/simgate/trial.lisp', '--', fas, p], cwd=simlib.ROOT,
                           capture_output=True, text=True, timeout=600)
    finally:
        os.unlink(p)
    if r.returncode:
        sys.exit((r.stdout + r.stderr)[-3000:])
    if '--rows' in sys.argv:
        return rows(r.stdout)
    for l in r.stdout.splitlines():
        if '--all' in sys.argv or KEEP.search(l):
            print(l[:220])


def rows(out):
    """One line a scene, ticks from the trial's first logged event (his press): the moves (1 Hisagi, 2 Kenpachi), C / A = a cancel /
    an absorb (by whose move's hit), and the first real hit (the exchange's breakthrough)."""
    T = re.compile(r'^\[\s*(\d+)\] (P[12]) (.*)$')
    name = None
    for l in out.splitlines():
        if 'trial begin ' in l:
            name, t0, ev, first = l.split('trial begin ', 1)[1], None, [], None
            continue
        m = T.match(l)
        if m and name:
            t, sd, rest = int(m[1]), m[2], m[3]
            t0 = t if t0 is None else t0
            k = t - t0
            if rest.startswith('move '):
                ev.append(f"{sd[1]}:{rest.split()[1].replace('HS-', '').replace('KE-Z-', '')}@{k}")
            elif ': CANCEL' in rest or ': ABSORBED' in rest:
                ev.append(f"{rest.split(':')[-1].strip()[0]}{sd[1]}@{k}")
            elif re.search(r'-> P[12] (HIT|COUNTER)', rest) and first is None:
                first = f"{sd} {rest.split()[0]} @{k}"
        if 'trial end ' in l and name:
            print(f"{name:26s} {' '.join(ev):64s} first: {first or 'none'}")
            name = None


if __name__ == '__main__':
    main()

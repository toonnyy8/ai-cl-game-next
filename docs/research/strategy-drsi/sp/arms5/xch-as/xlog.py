#!/usr/bin/env python3
"""xlog.py — what the HARD vs HARD bar's KH row does after a cancel (DUEL_CORE §2.1.3): seeds 141-180, both seats, the shipped lookup, with
the combat log on (xlog-run.lisp). Per side: the cancels, the ASs started out of one (an AS's `move` after a CANCEL line with no real hit
between), and who landed the next real hit after that AS (its own side or the other).

  python3 xlog.py [--root DIR] [--pair KH] [-j 2]     (DIR: a checkout with its build/simgate/duel.fas; default this one)
"""
import argparse, collections, os, re, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__))
R = {'K': 1, 'I': 3, 'H': 7}
NAME = {'K': 'KENPACHI', 'I': 'ICHIGO', 'H': 'HISAGI'}
L = re.compile(r'^\[\s*(\d+)\] (P[12]) (.*)$')


def run(root, c1, c2):
    fas = os.path.join(root, 'build/simgate/duel.fas')
    muslm = os.path.join(root, 'build/simgate/muslm.so')
    env = {k: v for k, v in os.environ.items() if not k.startswith('STRAT_')}
    env['LD_PRELOAD'] = muslm
    r = subprocess.run([os.environ.get('ECL_HOST', '/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl'), '--norc', '--load',
                        os.path.join(HERE, 'xlog-run.lisp'), '--', fas, '30140', '31140', '81022', str(200000 + 100 * c1 + 10 * c2)],
                       cwd=root, capture_output=True, text=True, env=env, timeout=7200)
    return r.stdout.splitlines()


def tally(lines, seat_of):
    """seat_of: {'P1': char, 'P2': char}. -> Counter keyed (char, what)."""
    c = collections.Counter()
    pend = None            # (side, tick) of an AS out of a cancel, waiting for the next real hit
    after_cancel = False
    for l in lines:
        if l.startswith('duel gate row'):
            pend, after_cancel = None, False
            continue
        m = L.match(l)
        if not m: continue
        side, rest = m[2], m[3]
        if ': CANCEL' in rest:
            c[(seat_of[side], 'cancel judged')] += 1
            after_cancel = True
            continue
        if re.search(r'-> P[12] (HIT|COUNTER)', rest):
            if pend:
                c[(seat_of[pend], 'AS out of a cancel, next hit ' + ('own' if side == pend else 'other'))] += 1
            pend, after_cancel = None, False
            continue
        mv = re.match(r'move (\S+)', rest)
        if mv and after_cancel and re.search(r'-(AS\d|S-BURST\d|S-SP\d|S-BANKAI|KR-SP|ZH-SP)', mv[1]) and not re.search(r'-N\d', mv[1]):
            c[(seat_of[side], 'AS out of a cancel')] += 1
            if pend is None: pend = side
    return c


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', default=os.path.abspath(os.path.join(HERE, '../../../../../..')))
    ap.add_argument('--pair', default='KH')
    a = ap.parse_args()
    x, y = a.pair[0], a.pair[1]
    tot = collections.Counter()
    for c1, c2, seats in ((R[x], R[y], {'P1': NAME[x], 'P2': NAME[y]}), (R[y], R[x], {'P1': NAME[y], 'P2': NAME[x]})):
        lines = run(a.root, c1, c2)
        rows = [l for l in lines if l.startswith('duel gate row')]
        if len(rows) != 40: sys.exit(f'{len(rows)} rows of 40')
        tot += tally(lines, seats)
    for k in sorted(tot): print(f'{k[0]:9} {k[1]:40} {tot[k]}')


if __name__ == '__main__':
    main()

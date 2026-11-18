#!/usr/bin/env python3
"""xch-econ.py (q4-defence R1, xch2.md §R1): the cancel economy of shipped CPU matches (HARD vs HARD, STRAT_CLOG=1; STRAT_SET from the
environment, e.g. the R1 knob). Per pairing: cancels per exchange (a chain from its first cancel until `exchange over` or a Kikon / Soul
Break reset), the share of cancels that are re-cancels, and per character and match the flash-step from cancel gains (`SP cancel gain`)
and from refunds (`SP refund`).
  python3 xch-econ.py [--pairs KI,KH] [--seeds 301-340] [-j 6]"""
import argparse, collections, os, re, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '../../../../../tools')))
from simlib import build, pool, run_lisp  # noqa: E402

ROSTER = {'K': 1, 'I': 3, 'H': 7}
NAME = {'K': 'kenpachi', 'I': 'ichigo', 'H': 'hisagi'}
TICK = re.compile(r'^\[ *(\d+)\] (.*)$')
GAIN = re.compile(r'^P(\d) SP cancel gain ([\d.]+)')
REF = re.compile(r'^P(\d) SP refund ([\d.]+)')


def job(j):
    a, b, s0, n = j
    env = dict(os.environ, STRAT_DIF_P1='hard', STRAT_DIF_P2='hard', STRAT_CLOG='1')
    r = run_lisp('simgate/strat-run.lisp', [30000 + s0, 31100 + n, 81022, 200000 + 100 * ROSTER[a] + 10 * ROSTER[b]], env=env, timeout=6 * 3600)
    return j, r.stdout


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--pairs', default='KI,KH')
    ap.add_argument('--seeds', default='301-340')
    ap.add_argument('-j', type=int, default=6)
    o = ap.parse_args()
    a0, a1 = (int(x) for x in o.seeds.split('-'))
    assert 1 <= a0 <= a1 <= 500, 'seeds 1-500 only'
    build()
    jobs = [(p[0], p[1], s0, min(10, a1 - s0)) for p in o.pairs.split(',') for s0 in range(a0 - 1, a1, 10)]
    acc = collections.defaultdict(collections.Counter)
    for (a, b, s0, n), out in pool(job, jobs, o.j):
        c = acc[a + b]
        chars = {'1': NAME[a], '2': NAME[b]}
        open_ = False
        for line in out.splitlines():
            if line.startswith('duel match seed'):
                c['matches'] += 1
                open_ = False
                continue
            t = TICK.match(line)
            if not t:
                continue
            body = t[2]
            if body.endswith(': CANCEL'):
                c['cancels'] += 1
                if open_:
                    c['recancels'] += 1
                else:
                    c['chains'] += 1
                open_ = True
            elif body == 'exchange over' or ' konpaku, ' in body:
                open_ = False
            m = GAIN.match(body)
            if m:
                c['gain ' + chars[m[1]]] += float(m[2])
            m = REF.match(body)
            if m:
                c['refund ' + chars[m[1]]] += float(m[2])
    print(f'xch-econ: seeds {a0}-{a1}, both orders not mixed (P1 = the first letter), STRAT_SET={os.environ.get("STRAT_SET", "")}')
    for p, c in acc.items():
        m = max(1, c['matches'])
        per = ', '.join(f'{x} {c["gain " + x] / m:.0f} / {c["refund " + x] / m:.0f}' for x in sorted({NAME[p[0]], NAME[p[1]]}))
        print(f'{p}: {c["matches"]} matches | cancels / exchange {c["cancels"] / max(1, c["chains"]):.2f} | re-cancels {100 * c["recancels"] / max(1, c["cancels"]):.0f} % '
              f'| cancels a match {c["cancels"] / m:.1f} | flash-step a match, cancel gain / refund: {per}')


if __name__ == '__main__':
    main()

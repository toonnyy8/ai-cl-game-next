#!/usr/bin/env python3
"""xch-econ.py (q4-defence R1, xch2.md §R1): the cancel economy of shipped CPU matches (HARD vs HARD, STRAT_CLOG=1; STRAT_SET from the
environment, e.g. the R1 knob). Per pairing: cancels per exchange (a chain from its first cancel until `exchange over` or a Kikon / Soul
Break reset), the share of cancels that are re-cancels, and per character and match the flash-step from cancel gains (`SP cancel gain`)
and from refunds (`SP refund`).
Also each pairing's K.O. count and median match time, and (R4) the AS segments in play at a cancel and how often that side's next move is an SA (its gate rows' secs: the match without its cinematics).
  python3 xch-econ.py [--pairs KI,KH] [--seeds 301-340] [-j 6]"""
import argparse, collections, os, re, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '../../../../../tools')))
from simlib import build, pool, run_lisp  # noqa: E402

ROSTER = {'K': 1, 'I': 3, 'H': 7}
NAME = {'K': 'kenpachi', 'I': 'ichigo', 'H': 'hisagi'}
TICK = re.compile(r'^\[ *(\d+)\] (.*)$')
MOVE = re.compile(r'^P(\d) move (\S+)')
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
    acc_secs = collections.defaultdict(list)
    for (a, b, s0, n), out in pool(job, jobs, o.j):
        c = acc[a + b]
        chars = {'1': NAME[a], '2': NAME[b]}
        open_ = False
        cur, asx = {}, {}
        for line in out.splitlines():
            if line.startswith('duel gate row'):
                t = line.split()
                acc_secs[a + b].append(float(t[t.index('secs') + 1]))
                c['ko'] += line.rstrip().endswith('ko 1')
                continue
            if line.startswith('duel match seed'):
                c['matches'] += 1
                open_ = False
                continue
            t = TICK.match(line)
            if not t:
                continue
            body = t[2]
            mv = MOVE.match(body)
            if mv:   # (R4: an SA right after an AS segment's cancel)
                if asx.get(mv[1]):
                    c['as->sa'] += '-SA' in mv[2]
                    asx[mv[1]] = False
                cur[mv[1]] = mv[2]
            if body.endswith(': CANCEL'):
                for side, name in cur.items():
                    if re.search(r'-AS\d', name):
                        c['as cancels'] += 1
                        asx[side] = True
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
        ss = sorted(acc_secs[p])
        print(f'{p}: K.O. {c["ko"]} / {len(ss)}, median {ss[len(ss) // 2] if ss else 0:.1f} s | cancels / exchange {c["cancels"] / max(1, c["chains"]):.2f} | re-cancels {100 * c["recancels"] / max(1, c["cancels"]):.0f} % '
              f'| cancels a match {c["cancels"] / m:.1f} | AS segments in a cancel {c["as cancels"] / m:.1f} a match, an SA next {100 * c["as->sa"] / max(1, c["as cancels"]):.0f} % '
              f'| flash-step a match, cancel gain / refund: {per}')


if __name__ == '__main__':
    main()

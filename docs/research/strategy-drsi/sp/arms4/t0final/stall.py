#!/usr/bin/env python3
"""stall.py — bar D's diagnosis (B4): two tables' bar-A matches (proof.py bar's cached sim output: no new sim when the run exists), split
into K.O. matches and time-outs, with each side's arm shares in each, and in the last 20 judgements of each match.
  python3 stall.py T1 C1 T2 C2 [SEEDS]   (tables relative to arms4/; SEEDS default 501-540)"""
import collections, importlib.util, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
A4 = os.path.dirname(HERE)
_s = importlib.util.spec_from_file_location('proof', os.path.join(A4, 'proof.py'))
proof = importlib.util.module_from_spec(_s); _s.loader.exec_module(proof)


def main():
    t1, c1, t2, c2 = sys.argv[1:5]
    lo, hi = (int(x) for x in (sys.argv[5] if len(sys.argv) > 5 else '501-540').split('-'))
    res = proof.both_seats(c1, c2, os.path.join(A4, t1), os.path.join(A4, t2), lo - 1, hi - lo + 1, {'STRAT_FQLOG': '0 0'}, 20)
    flip = {'P1': 'P2', 'P2': 'P1'}
    for side, char in ((1, c1), (2, c2)):
        acc = {k: collections.Counter() for k in ('ko', 'to', 'ko-last', 'to-last')}
        n = collections.Counter()
        for seat, lines in res.items():
            me = seat if side == 1 else flip[seat]
            rows = proof.rows(lines)
            seq = collections.defaultdict(list)
            for l in lines:
                m = proof.FQRE.match(l)
                if m and m[3] == me:
                    seq[int(m[1])].append(int(m[4]))
            for seed, arms in seq.items():
                k = 'ko' if rows[seed][1] else 'to'
                n[k] += 1
                acc[k].update(arms)
                acc[k + '-last'].update(arms[-20:])
        print(f'side {side} {char}: K.O. matches {n["ko"]}, time-outs {n["to"]}')
        for k, c in acc.items():
            t = sum(c.values())
            if t:
                print(f'  {k:8s} ' + ' '.join(f'arm{a}:{c[a] / t:.2f}' for a in sorted(c)))


if __name__ == '__main__':
    main()

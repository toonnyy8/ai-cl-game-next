#!/usr/bin/env python3
"""ship.py — PLAN2 §3's ship test: the ONLY tool that plays the held-out seeds 601-800 (eval.py and band.py refuse them). Seeds fixed, no seed0.

  python3 ship.py --me C --vs D --table FILE --arm0 FILE --opp FILE|none [FILE|none ...] [-j 6]
  -> one JSON line: per opponent and pooled over them, both seats, 200 seeds a seat (400 matches an opponent and candidate):
     b = the TABLE won by K.O. and arm 0 did not, c the reverse, z = (b - c) / sqrt(b + c) (positive favours the table; band.py pair and the
     admission files put arm 0 first, the opposite sign), and for each of the two: K.O. wins, K.O. rate (K.O. wins + losses) / n, time-outs,
     score (K.O. wins + 1) / (n + 2).

The matches are eval.py's (mine / jobs / play: the same sim path and cache), HARD, each opponent a single strategy (a file or `none`, his
shipped CPU), not a population. Run once per side; never in a search loop."""
import argparse, json, os, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import band                                              # noqa: E402  (its eval.py and paired b / c / z: one implementation)
ev, ss = band.ev, band.ss
SEED0, SEEDS = 600, 200                                  # 601-800 (PLAN §6, PLAN2 §3)


def side(cnt):
    n = cnt['matches']
    return dict(ko_wins=cnt['ko_wins'], ko_rate=round((cnt['ko_wins'] + cnt['ko_losses']) / n, 4), timeouts=cnt['timeouts'],
                score=round((cnt['ko_wins'] + 1) / (n + 2), 4), n=n)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--me', required=True, choices=list(ss.ROSTER)); ap.add_argument('--vs', required=True, choices=list(ss.ROSTER))
    ap.add_argument('--table', required=True); ap.add_argument('--arm0', required=True)
    ap.add_argument('--opp', required=True, nargs='+', help="the opponent's strategies: files or none")
    ap.add_argument('-j', type=int, default=6)
    a = ap.parse_args()
    os.dup2(os.open(os.devnull, os.O_RDONLY), 0)         # (an ECL error must not wait in its debugger on a terminal)
    for f in (a.table, a.arm0):
        ev.check_cand(f)
    ss.build()
    opps = [ss.vs_spec(o if o == 'none' else os.path.abspath(o)) for o in a.opp]
    res = ev.play([ev.jobs(a.me, a.vs, ev.mine(c), o, SEED0, SEEDS) for o in opps for c in (a.table, a.arm0)], a.j)
    out, tot = {}, {}
    for i, o in enumerate(a.opp):
        (ct, wt), (c0, w0) = res[2 * i], res[2 * i + 1]
        assert ct['matches'] == c0['matches'] == 2 * SEEDS, (ct, c0)
        b, c, z = band.paired(wt, w0)
        out[os.path.basename(o)] = dict(b=b, c=c, z=z, table=side(ct), arm0=side(c0))
        for k, cnt in (('b', b), ('c', c)):
            tot[k] = tot.get(k, 0) + cnt
        for who, cnt in (('table', ct), ('arm0', c0)):
            s = tot.setdefault(who, dict.fromkeys(ct, 0))
            for x in cnt:
                s[x] += cnt[x]
    pooled = dict(b=tot['b'], c=tot['c'], z=band.z(tot['b'], tot['c']), table=side(tot['table']), arm0=side(tot['arm0']))
    print(json.dumps(dict(me=a.me, vs=a.vs, table=a.table, arm0=a.arm0, seeds=f'{SEED0 + 1}-{SEED0 + SEEDS}', opps=out, pooled=pooled,
                          build=ss.build_hash()[:12])))


if __name__ == '__main__':
    main()

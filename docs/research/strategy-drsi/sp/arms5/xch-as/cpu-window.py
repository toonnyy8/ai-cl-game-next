#!/usr/bin/env python3
"""cpu-window.py — the CPU's SA against an AS out of a cancel (DUEL_CORE §2.1.3): P1 Kenpachi (script) J1 into P2 Bankai Hisagi's NSa
(:p2-start 2 frames after his press, so his J1's hit is the one judged: her SA must answer his AS), then her CPU plays (:p2-cpu DIF); his
AS one sim frame after the cancel. Per difficulty and Kenpachi form, over seeds 1-20: the trials where her CPU pressed the SA on seeing his
AS (its watch roll, *CAI-XCH-SA-P*; the log's `cpu xch SA on his as`), and who landed first then; and the same for an SA pressed on his
"new NA" (`on his na`: his J1's perceived start, tick - move frame, drifts past the cancel's tick over the cancel's hitstop and slow motion,
so XCH-TURN-SEEN-P takes it for a new link: the SA starts with his AS, the same tick).

  python3 cpu-window.py [--fas build/simgate/duel.fas]
"""
import argparse, collections, os, sys
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sweep  # noqa: E402

KF = (':base', ':nozarashi', ':bankai')
DIF = (':easy', ':normal', ':hard')


def head(kf, dif, seed):
    return (f':p1 :kenpachi :form {kf} :p2 :hisagi :p2-form :bankai :ptr 1 :p2-ptr 1 :fs 300 :p2-fs 300 :frames 150 :seed {seed} :dist 1.8 '
            f':p2-start ((2 :hs-r-n1a)) :p2-cpu {dif}')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--fas', default=sweep.simlib.FAS)
    a = ap.parse_args()
    if a.fas == sweep.simlib.FAS: sweep.simlib.build()
    o1 = sweep.run(a.fas, [f'(:name "c|{k}" {head(k, ":hard", 1)} :script ((:quick 1)))' for k in KF])
    canc = {k: sweep.cancel_at(o1[f'c|{k}']) for k in KF}
    tr = [f'(:name "{k}|{d}|{s}" {head(k, d, s)} :script ((:quick 1)) :p1-at (({canc[k] + 1} :sp)))'
          for k in KF for d in DIF for s in range(1, 21) if canc[k] is not None]
    o = sweep.run(a.fas, tr)
    print('Kenpachi form | dif | her SA pressed on his AS: n, SA first / AS first / none | on his "new NA" (a drifted perceived start): same')
    for k in KF:
        for d in DIF:
            row = []
            for why in ('as', 'na'):
                n, res = 0, collections.Counter()
                for sd in range(1, 21):
                    lines = o.get(f'{k}|{d}|{sd}', [])
                    if not any(f'cpu xch SA on his {why}' in l for l in lines): continue
                    n += 1
                    h = sweep.first_hit(lines)
                    res['SA' if h and h[0] == 'P2' else 'AS' if h else 'none'] += 1
                row.append(f'{n:2}: {res["SA"]} / {res["AS"]} / {res["none"]}')
            print(f'{k:11} | {d:7} | ' + ' | '.join(row))

if __name__ == '__main__':
    main()

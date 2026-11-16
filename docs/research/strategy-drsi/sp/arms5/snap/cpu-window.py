#!/usr/bin/env python3
"""cpu-window.py (snap) — xch-as/cpu-window.py's scene, the CPU's SA against an AS out of a cancel, with the trial's perception fixed
(trial.lisp :p2-cpu now sets the difficulty's BRAIN-DELAY and fills the SNAP ring with P1 as the trial starts; DUEL_AI_STRATEGY §11.29) and
the SA's timing counted in sim frames (:log-simf). P1 Kenpachi J1 (script) into P2 Bankai Hisagi's NSa (:p2-start 2 frames later), her CPU
plays; his AS on xch-as's frame (the cancel's tick offset + 1, as there); seeds 1-20 per difficulty and Kenpachi form.

Per row: the trials whose watch fired on his AS (`cpu xch SA on his as`) and on his "new NA" (`on his na`), who landed first in each; the
SA press in sim frames after his AS press (min / median / max), for each kind of fire, against the scenes' window (xch-as/notes.md: SA pressed +2..+22 sealed,
+20 Shikai, +18 Bankai still wins).

  python3 cpu-window.py [--fas build/simgate/duel.fas]
"""
import argparse, collections, os, re, statistics, sys
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '../xch-as'))
import sweep  # noqa: E402

KF = (':base', ':nozarashi', ':bankai')
WIN = {':base': 22, ':nozarashi': 20, ':bankai': 18}
DIF = (':easy', ':normal', ':hard')
SIMF = re.compile(r'\] simf (\d+)$')


def head(kf, dif, seed):
    return (f':p1 :kenpachi :form {kf} :p2 :hisagi :p2-form :bankai :ptr 1 :p2-ptr 1 :fs 300 :p2-fs 300 :frames 150 :seed {seed} :dist 1.8 '
            f':p2-start ((2 :hs-r-n1a)) :p2-cpu {dif} :log-simf t')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--fas', default=sweep.simlib.FAS)
    a = ap.parse_args()
    if a.fas == sweep.simlib.FAS: sweep.simlib.build()
    o1 = sweep.run(a.fas, [f'(:name "c|{k}" {head(k, ":hard", 1)} :script ((:quick 1)))' for k in KF])
    canc = {k: sweep.cancel_at(o1[f'c|{k}']) for k in KF}
    # his AS on xch-as's sim frame (the cancel's offset + 1); "simf N" is logged before the frame it numbers' successor runs, so a press
    # logged after "simf N" fell in the frame N labels, as "P1 at simf N" does
    cf = {k: canc[k] for k in KF}
    tr = [f'(:name "{k}|{d}|{s}" {head(k, d, s)} :script ((:quick 1)) :p1-at (({cf[k] + 1} :sp)))'
          for k in KF for d in DIF for s in range(1, 21) if canc[k] is not None]
    o = sweep.run(a.fas, tr)
    print('Kenpachi form | dif | SA on his AS: n, SA first / AS first / none | on his "new NA": same | SA press - AS press, sim frames, '
          'per kind of fire (min / median / max, in the window +2..+W)')
    for k in KF:
        for d in DIF:
            row, lags, nlags = [], [], []
            for why in ('as', 'na'):
                n, res = 0, collections.Counter()
                for sd in range(1, 21):
                    lines = o.get(f'{k}|{d}|{sd}', [])
                    f, hit = None, None
                    for l in lines:
                        m = SIMF.search(l)
                        if m: f = int(m[1])
                        if f'cpu xch SA on his {why}' in l: hit = f; break
                    if hit is None: continue
                    n += 1
                    (lags if why == 'as' else nlags).append(hit - (cf[k] + 1))
                    h = sweep.first_hit(lines)
                    res['SA' if h and h[0] == 'P2' else 'AS' if h else 'none'] += 1
                row.append(f'{n:2}: {res["SA"]} / {res["AS"]} / {res["none"]}')
            sm = lambda v: f'{min(v)} / {statistics.median(v):g} / {max(v)}' if v else '-'
            inw = lambda v: f'{sum(2 <= x <= WIN[k] for x in v)}/{len(v)}'
            print(f'{k:11} | {d:7} | ' + ' | '.join(row) + f' | as {sm(lags)} {inw(lags)} | na {sm(nlags)} {inw(nlags)} (W {WIN[k]})')


if __name__ == '__main__':
    main()

# ko.py LOG... : per log, matches, K.O.s, time-outs, wins P1/P2, cancels (J x NS and all) per match
import sys, re
for p in sys.argv[1:]:
    rows = [l for l in open(p) if l.startswith('duel gate row')]
    ko = sum(1 for l in rows if l.rstrip().endswith('ko 1')); w1 = sum(' winner P1 ' in l for l in rows); w2 = sum(' winner P2 ' in l for l in rows)
    canc = sum(1 for l in open(p) if re.search(r'\] P[12] \S+ x P[12]: CANCEL', l))
    secs = sorted(float(re.search(r'secs ([\d.]+)', l)[1]) for l in rows)
    med = secs[len(secs)//2] if secs else 0
    print(f'{p.split("/")[-1]:28s} n={len(rows):2d} KO {ko:2d} TO {len(rows)-ko:2d}  P1 {w1:2d} P2 {w2:2d}  cancels {canc:4d} ({canc/max(1,len(rows)):.1f}/match) median {med:.1f}s')

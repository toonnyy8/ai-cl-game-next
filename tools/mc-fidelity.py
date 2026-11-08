#!/usr/bin/env python3
"""The in-game MCTS's light model against the full sim (docs/duel/DUEL_AI_TEACHER.md §9): tools/simgate/teacher.lisp logs run with
TEACH_LITE=N print, per decision point, the full sim's mean value of each macro action ("teach" line) and the light model's ("lite"
line). Per point: the rank correlation of the ten values, whether the best action agrees, and the regret of the light model's pick (the
full sim's best minus the full sim's value of the light model's best), against a uniform pick's. By the opponent's state too.
With --table T (a teacher table, docs/research/ai-teacher/*.lisp), the table's pick at the same points as well (keyed as cpu-ki-teacher's
KT-KEY was, from the true state). Usage: python3 tools/mc-fidelity.py [--table T] LOG..."""
import collections, re, sys
ACT = ['j1', 'sp', 'hoho', 'step-in', 'step-out', 'step-side', 'guard', 'wait', 'walk-in', 'walk-out']
def ranks(v): o = sorted(range(len(v)), key=lambda i: v[i]); r = [0] * len(v); [r.__setitem__(i, k) for k, i in enumerate(o)]; return r
def spearman(a, b):
    ra, rb, n = ranks(a), ranks(b), len(a)
    return 1 - 6 * sum((x - y) ** 2 for x, y in zip(ra, rb)) / (n * (n * n - 1))
args = sys.argv[1:]
table = {}
if args[:1] == ['--table']:
    for l in open(args[1]):
        m = re.match(r'\(setf \(gethash \(list ((?::\S+ ?)+)\) \*teach-table\*\) \(vector (\d+) (.*)\)\)', l)
        if m: table[tuple(x.strip(':').upper() for x in m.group(1).split())] = [float(x) for x in m.group(3).split()]
    args = args[2:]
def key(head):
    g = lambda k: (re.search(r':%s (\S+)' % k, head) or [None, 'NIL'])[1].strip(':')
    d = int(g('D')); st = g('OST')
    band = 'CLOSE' if d < 20 else 'MID' if d < 40 else 'FAR' if d < 70 else 'OUT'
    return (g('CHAR'), g('FORM'), band, 'MOVE-' + g('OPHASE') if st == 'MOVE' else st)
pts, full = collections.defaultdict(list), None
lines = (l for a in args for l in open(a))
for l in lines:
    if l.startswith('teach '):
        head, tail = l.split('|')
        ost = re.search(r':OST :(\S+)', head)
        t = tail.split()
        full = ([float(t[i + 1]) for i in range(0, 30, 3)], ost.group(1) if ost else '?', table.get(key(head)))
    elif l.startswith('lite') and full:
        var, lite = l.split()[0], [float(x) for x in l.split()[1:]]
        f, ost, trow = full
        legal = [i for i in range(10) if lite[i] > -8]
        if len(legal) >= 2:
            fl, ll = [f[i] for i in legal], [lite[i] for i in legal]
            bf, bl = max(fl), fl[ll.index(max(ll))]
            tr = trow and [trow[i] for i in legal]
            pts[var].append((ost, spearman(fl, ll), fl.index(bf) == ll.index(max(ll)), bf - bl, bf - sum(fl) / len(fl),
                        tr and bf - fl[tr.index(max(tr))], tr and spearman(fl, tr)))
def row(name, ps):
    n = len(ps)
    print(f'{name:12} {n:6}  rank r {sum(p[1] for p in ps) / n:+.2f}  best agrees {100 * sum(p[2] for p in ps) / n:4.0f}%  '
          f'regret {sum(p[3] for p in ps) / n:.4f}  (uniform pick {sum(p[4] for p in ps) / n:.4f})' +
          (lambda t: f'  | table ({len(t)}): regret {sum(p[5] for p in t) / len(t):.4f} rank r {sum(p[6] for p in t) / len(t):+.2f}'
                     f', light on them {sum(p[3] for p in t) / len(t):.4f}' if t else '')([p for p in ps if p[5] is not None]))
for var in sorted(pts):
    print(f'== {var}')
    row('all', pts[var])
    by = collections.defaultdict(list)
    for p in pts[var]: by[p[0]].append(p)
    for k in sorted(by, key=lambda k: -len(by[k])):
        if len(by[k]) >= 30: row(k.lower(), by[k])

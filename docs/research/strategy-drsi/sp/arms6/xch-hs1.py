#!/usr/bin/env python3
"""xch-hs1.py (q4-defence, xch2.md): for CHAR's explored J-side decisions with OPTION at OWN (from build/xch, xch.py log with the hs1 field):
my first new action, his action / state at that step (hs1), and who hit first after it, with the mean dh.
  python3 xch-hs1.py CHAR OPTION OWN"""
import collections, glob, gzip, os, sys

L = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../../../build/xch'))
char, opt, own = sys.argv[1], sys.argv[2], sys.argv[3]


def parse(l):
    t = l.split()
    d = {'P': t[3], 'char': t[4], 'role': t[5]}
    i = 6
    while i < len(t):
        if t[i] == 'out':
            i += 1
            continue
        d[t[i]] = t[i + 1]
        i += 2
    return d


acc = collections.defaultdict(list)
n = 0
for p in glob.glob(f'{L}/*.txt.gz'):
    seat = 'P' + os.path.basename(p).split('-')[1][1]
    for l in gzip.open(p, 'rt'):
        if not l.startswith('xd '):
            continue
        d = parse(l)
        if d['char'] != char or d['role'] != 'j' or d['P'] != seat or d['ex'] != '1' or d['pick'] != opt or d['own'] != own:
            continue
        n += 1
        mine = d['m1'].split('@')[0]
        mine = mine.split(':')[0] if ':' in mine else mine          # my first action's class (as / na / ns / sa) or state
        acc[(mine, d['hs1'])].append(d)
print(f'{char} J {opt} own{own}: {n} explored decisions; my first action class | his action / state then | n | he hit first % | mean dh | median frame')
for k, v in sorted(acc.items(), key=lambda kv: -len(kv[1]))[:18]:
    fr = sorted(int(d['m1'].split('@')[1]) for d in v if '@' in d['m1'])
    print(f'{k[0]:>6} | {k[1]:>22} | {len(v):4d} | {100 * sum(d["brk"] == "him" for d in v) / len(v):3.0f} | '
          f'{sum(float(d["dh"]) for d in v) / len(v):+.3f} | {fr[len(fr) // 2] if fr else "-"}')

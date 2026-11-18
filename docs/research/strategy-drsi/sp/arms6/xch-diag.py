"""xch-diag.py (q4-defence, xch2.md): usage xch-diag.py CHAR [GLOB]; reads build/xch (xch.py log). Diagnose the J side's options by own: the NS side's pick, his first action, my first action, who hits first and with what."""
import collections, glob, gzip, os, sys
L = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../../../build/xch'))
char = sys.argv[1] if len(sys.argv) > 1 else 'kenpachi'
pat = sys.argv[2] if len(sys.argv) > 2 else '*'


def parse(l):
    t = l.split()
    d = {'seed': t[1], 't0': t[2], 'P': t[3], 'char': t[4], 'role': t[5]}
    i = 6
    while i < len(t):
        if t[i] == 'out':
            i += 1
            continue
        d[t[i]] = t[i + 1]
        i += 2
    return d


rows = []
for p in glob.glob(f'{L}/{pat}.txt.gz'):
    b = os.path.basename(p)
    seat = 'P' + b.split('-')[1][1]
    for l in gzip.open(p, 'rt'):
        if l.startswith('xd '):
            d = parse(l)
            d['xseat'] = seat
            d['f'] = b
            rows.append(d)
idx = {(d['f'], d['seed'], d['t0'], d['P']): d for d in rows}


def cat(a):
    """an action -> its class and name without the frame"""
    return a.split('@')[0]


def frm(a):
    return int(a.split('@')[1]) if '@' in a else None


acc = collections.defaultdict(list)
for d in rows:
    if d['char'] != char or d['role'] != 'j' or d['P'] != d['xseat'] or d['ex'] != '1':
        continue
    o = idx.get((d['f'], d['seed'], d['t0'], 'P2' if d['P'] == 'P1' else 'P1'))
    acc[(d['own'], d['pick'])].append((d, o))
for k in sorted(acc):
    v = acc[k]
    n = len(v)
    print(f'\n=== {char} J own{k[0]} {k[1]}: n {n}, mean dh {sum(float(d["dh"]) for d, _ in v) / n:+.3f}, '
          f'he hits first {100 * sum(d["brk"] == "him" for d, _ in v) / n:.0f} %, I {100 * sum(d["brk"] == "me" for d, _ in v) / n:.0f} %')
    c = collections.Counter(o['pick'] if o else '?' for d, o in v)
    print('  his NS pick:', ', '.join(f'{x} {100 * y / n:.0f}%' for x, y in c.most_common()))
    for lab, key in (('my first action', 'm1'), ('his first action', 'h1'), ('the first hit (hitter)', 'hit')):
        c = collections.Counter(cat(d[key]) for d, _ in v)
        fr = collections.defaultdict(list)
        for d, _ in v:
            if frm(d[key]) is not None:
                fr[cat(d[key])].append(frm(d[key]))
        print(f'  {lab}:', ', '.join(f'{x} {100 * y / n:.0f}%' + (f' (f{sorted(fr[x])[len(fr[x]) // 2]})' if fr[x] else '') for x, y in c.most_common(6)))
    # by who hit first: his first action
    for who in ('him', 'me'):
        sub = [(d, o) for d, o in v if d['brk'] == who]
        if sub:
            c = collections.Counter((cat(d['hit'])) for d, _ in sub)
            print(f'  first hit by {who} ({len(sub)}): ' + ', '.join(f'{x} {y}' for x, y in c.most_common(5)))

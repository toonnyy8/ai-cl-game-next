#!/usr/bin/env python3
"""phase.py — arms6/ih.md's phase split of logged IH matches (diag/probe.lisp's combat log, one file a seat): the Konpaku when Hisagi
awakens, who takes Konpaku in which forms, and Hisagi's hits by move while he is awakened.

  python3 phase.py LOG_ICHIGO_P1 LOG_ICHIGO_P2
"""
import collections, re, sys

rows, kp, hits = [], collections.Counter(), collections.Counter()
for path, ich in ((sys.argv[1], 'P1'), (sys.argv[2], 'P2')):
    his = 'P2' if ich == 'P1' else 'P1'
    k, at, iaw = {'I': 9, 'H': 9}, None, None
    for l in open(path):
        if re.match(r'duel match seed (\d+)', l):
            k, at, iaw = {'I': 9, 'H': 9}, None, None
        m = re.search(r'\[\s*(\d+)\] (P[12]) (KIKON|SOUL BREAK) on (P[12]): -(\d+) konpaku, (\d+) left \((\S+)\)', l)
        if m:
            k['I' if m[4] == ich else 'H'] = int(m[6])
            kp[('I' if m[2] == ich else 'H', m[3], m[7])] += int(m[5])
        m = re.search(r'\[\s*(\d+)\] (P[12]) AWAKEN', l)
        if m:
            if m[2] == his and at is None:
                at = (int(m[1]), dict(k))
            if m[2] == ich and iaw is None:
                iaw = int(m[1])
        m = re.search(rf'\] {his} (HS-[A-Z0-9-]+) -> {ich} HIT', l)
        if m and at:
            hits[m[1]] += 1
        if 'gate row' in l:
            w = re.search(r'winner (\S+)', l)[1]
            rows.append((at, iaw, dict(k), 'I' if w == ich else 'H' if w == his else 'D', l.strip().endswith('ko 1')))
n = len(rows)
haw = [r for r in rows if r[0]]
print(f'{n} matches; Hisagi awakened in {len(haw)} at {sum(r[0][0] for r in haw) / max(1, len(haw)) / 60:.1f} s; Ichigo in '
      f'{sum(1 for r in rows if r[1])} at {sum(r[1] for r in rows if r[1]) / max(1, sum(1 for r in rows if r[1])) / 60:.1f} s')
print('Konpaku at his awakening: Ichigo %.2f Hisagi %.2f' % (sum(r[0][1]['I'] for r in haw) / max(1, len(haw)),
                                                            sum(r[0][1]['H'] for r in haw) / max(1, len(haw))))
print('at his awakening:', collections.Counter('I ahead' if r[0][1]['I'] > r[0][1]['H'] else 'even' if r[0][1]['I'] == r[0][1]['H']
                                               else 'H ahead' for r in haw))
print('results:', collections.Counter((r[3], 'ko' if r[4] else 'bell') for r in rows))
print('Konpaku taken a match (taker, how, taker form):')
for key, v in sorted(kp.items()):
    print('  ', key, round(v / n, 2))
print("Hisagi's hits a match once awakened:", ', '.join(f'{m} {c / n:.1f}' for m, c in hits.most_common(14)))

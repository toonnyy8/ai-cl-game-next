#!/usr/bin/env python3
"""The teacher's table as a Lisp file the teacher CPU reads (docs/duel/DUEL_AI_TEACHER.md §7): per (character, distance band, the
opponent's state) the mean value of each macro action over its decision points.
Usage: python3 tools/teach-table.py OUT.lisp teacher-log... [--sides ichigo,kenpachi] (--sides: for logs without :char, side 0 / 1)."""
import re, sys, collections, statistics
args = [a for a in sys.argv[1:] if not a.startswith('--')]
sides = next((a.split('=', 1)[1] if '=' in a else None for a in sys.argv if a.startswith('--sides')), None)
if '--sides' in sys.argv: sides = sys.argv[sys.argv.index('--sides') + 1]; args.remove(sides)
out, logs = args[0], args[1:]
side_char = sides.split(',') if sides else None
ACTIONS = None
def band(d):   # deci-metres -> the band key (TEACH-BAND in teacher.lisp: the same edges)
    d = int(d)
    return 'close' if d < 20 else 'mid' if d < 40 else 'far' if d < 70 else 'out'
def ostate(f):  # the opponent's state key (TEACH-OSTATE: :move adds its phase)
    s = f['ost'].strip(':').lower()
    return 'move-' + f['ophase'].strip(':').lower() if s == 'move' else s
groups = collections.defaultdict(list)
for path in logs:
    for l in open(path):
        if not l.startswith('teach '): continue
        head, acts = l.split('|', 1)
        m = re.match(r'teach (\d+) (\d+) (\d+) \((.*)\) ?$', head.strip())
        side, feat = int(m.group(3)), m.group(4).split()
        f = {feat[i][1:].lower(): feat[i + 1] for i in range(0, len(feat) - 1, 2)}
        char = f.get('char', ':' + side_char[side] if side_char else None).strip(':').lower()
        a = acts.split()
        vals = {a[i]: float(a[i + 1]) for i in range(0, len(a), 3)}
        ACTIONS = ACTIONS or list(vals)
        groups[(char, band(f['d']), ostate(f))].append(vals)
with open(out, 'w') as o:
    o.write(';;;; The teacher table (tools/teach-table.py from %d logs): ((character band ostate) n mean...) in *TEACH-ACTIONS* order.\n' % len(logs))
    o.write('(setf *teach-table* (make-hash-table :test (quote equal)))\n')
    for k, vs in sorted(groups.items()):
        if len(vs) < 10: continue
        means = ' '.join('%.4f' % statistics.mean(v[x] for v in vs) for x in ACTIONS)
        o.write('(setf (gethash (list :%s :%s :%s) *teach-table*) (vector %d %s))\n' % (k[0], k[1], k[2], len(vs), means))
print('actions', ACTIONS, 'buckets', sum(1 for v in groups.values() if len(v) >= 10), 'of', len(groups))

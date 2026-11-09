#!/usr/bin/env python3
"""events.py — the event layer's statistics in a measure's logs (DUEL_AI_STRATEGY §8.19 round 5, step 6), from the switch directory:
strat-run.lisp's "event P<n> <id> fires F steps S ticks T out <steps per arm outside the layer>" lines -> takeovers a match, the layer's
share of match time, and the table's arm shares (by time) outside the layer.  usage: events.py TAG [TAG ...]   (e.g. ev/ejh-kh-n-vs-hko-601)"""
import glob, gzip, json, os, re, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
pat = re.compile(r'event P\d (\S+) fires (\d+) steps (\d+) ticks (\d+) out((?: \d+)*)')
fires = steps = ticks = n = 0
out = None
for tag in sys.argv[1:]:
    for p in glob.glob(os.path.join(HERE, 'logs', tag, '*.out.gz')):
        for line in gzip.open(p, 'rt'):
            m = pat.search(line)
            if not m:
                continue
            n += 1; fires += int(m.group(2)); steps += int(m.group(3)); ticks += int(m.group(4))
            v = [int(x) for x in m.group(5).split()]
            out = v if out is None else [a + b for a, b in zip(out, v)]
tot = sum(out or [0]) or 1
print(json.dumps(dict(matches=n, fires_per_match=round(fires / max(1, n), 2), layer_share_of_time=round(steps / max(1, ticks), 4),
                      arm_share_outside=[round(x / tot, 3) for x in (out or [])])))

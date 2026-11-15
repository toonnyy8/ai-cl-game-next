#!/usr/bin/env python3
"""holds.py RUN.json ...: per probe run, the share and per match the steps each side spent in the MCTS reaction hold (hold) or deaf in
any MCTS press-nothing (deaf), the lo side's openers on a hi side in the hold / free, the hi side's clashes and exchange answers."""
import json, sys
for f in sys.argv[1:]:
    d = json.load(open(f)); h = d['per_match']['hi']; l = d['per_match']['lo']
    g = lambda c, k: c.get(k, 0)
    print(f"{f.split('/')[-1]:34s} {d['share']:.3f} hold hi {g(h, 'hold'):5.0f} lo {g(l, 'hold'):5.0f} deaf hi {g(h, 'deaf'):5.0f}"
          f" | lo opens on hold {g(l, 'on_deaf'):5.1f} free {g(l, 'on_free'):5.1f} | clash {g(h, 'clash'):4.1f} xch {g(h, 'xch'):4.1f}")

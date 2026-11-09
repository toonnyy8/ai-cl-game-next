#!/usr/bin/env python3
"""extend.py — a live table with new arms appended (DUEL_AI_STRATEGY §8.19 round 5, step 4), from the switch directory: the q of every new arm is
1 below the row's minimum in every rule, so in each group it sits under every old arm and the sum never reaches the argmax: the table plays the
old one bit for bit (proved with proof/identity.py) while the log's run exploration can visit the new arms.
usage: extend.py --me C --vs D --arms OLD.arms --table OLD.lisp --new-arms NEW.arms --out FILE.lisp [--period 30]
NEW.arms = OLD.arms's lines followed by the new arms."""
import argparse, os, re, sys
import numpy as np
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, HERE)
import sw  # noqa: E402

ap = argparse.ArgumentParser()
for k in ('--me', '--vs', '--arms', '--table', '--new-arms', '--out'):
    ap.add_argument(k, required=True)
ap.add_argument('--period', type=int, default=30)
a = ap.parse_args()
a.opp = 'none'
sw.configure(a)
q0 = sw.read_q(os.path.join(HERE, a.table))
old = sw.ARMS[:]
a.arms = a.new_arms
sw.configure(a)
assert sw.ARMS[:len(old)] == old, 'NEW.arms must start with OLD.arms'
q = np.hstack([q0, np.repeat(q0.min(axis=1, keepdims=True) - 1.0, sw.NA - len(old), axis=1)])
src = open(os.path.join(HERE, a.table)).read()
m = re.search(r':gamma (\S+) :scale (\S+)', src)
sw.write_table(os.path.join(HERE, a.out), ':' + os.path.splitext(os.path.basename(a.out))[0], q,
               f'{a.table} with {sw.NA - len(old)} arm(s) appended from {a.new_arms}, each 1 below every row\'s minimum: plays {a.table} bit for bit.',
               period=a.period, gamma=m and m.group(1), scale=m and m.group(2), keep=':keep-state t' in src)
print('wrote', a.out, sw.NA, 'arms')

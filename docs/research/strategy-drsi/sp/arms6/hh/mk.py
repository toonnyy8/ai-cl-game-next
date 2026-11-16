#!/usr/bin/env python3
"""mk.py — arms6/hh: a T0 table whose job map needs per-rule values band.py t0 cannot write (a job split by a second group's cue).

  python3 mk.py SPEC.json OUT.lisp
SPEC: {"note": ..., "arms": [arm files, arm 0 first], "values": [null, [[[substring, ...], value], ...], ...]}: per arm k, every rule of
:rb-sp2 whose antecedent holds all the substrings gets that value (later entries win); 0 elsewhere. Written through band.py's writer
(sw.write_table: :rb-sp2, :keep-state, :margin 0.02, :period 30, :gamma 0.966, :scale 0.1, no :with), as band.py t0."""
import importlib.util, json, os, sys
import numpy as np
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.argv, (spec, out) = sys.argv[:1], sys.argv[1:3]
s = importlib.util.spec_from_file_location('band', os.path.join(HERE, '../../band.py'))
band = importlib.util.module_from_spec(s); s.loader.exec_module(band)
sw = band.sw
sw.set_rule_base(':rb-sp2')
m = json.load(open(spec))
base = os.path.dirname(os.path.abspath(spec))
arms = [band.arm_text(os.path.join(base, x)) for x in m['arms']]
assert len(m['values']) == len(arms) and m['values'][0] is None
q = np.zeros((sw.NR, len(arms)))
for k, vals in enumerate(m['values'][1:], 1):
    for subs, v in vals:
        hit = [r for r, (ante, _) in enumerate(sw.RULES) if all(x in ante for x in subs)]
        assert hit, f'arm {k}: no rule holds {subs}'
        q[hit, k] = v
sw.ARMS, sw.NA, sw.MEN, sw.VSN, sw.RB, sw.EVENT = arms, len(arms), 'hisagi', 'hisagi', ':rb-sp2', None
sw.write_table(out, ':' + os.path.splitext(os.path.basename(out))[0], q, f'arms6/hh mk.py: {os.path.basename(spec)}: {m["note"]}',
               period=30, gamma=0.966, scale=0.1, keep=True, margin=0.02, with_=[])
print(f'{out}: {len(arms)} arms, rules > 0 per arm ' + str([int((q[:, k] > 0).sum()) for k in range(len(arms))]))

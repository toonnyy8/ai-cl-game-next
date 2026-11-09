#!/usr/bin/env python3
"""lib-block.py — the *strat-library* entries of §8.18's shipped tables, printed from pairs/<p>/<p>-fit.lisp (renamed, same q values)."""
import os, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
import fq   # noqa: E402

NOTES = {
    'ki': (':q1-ken-ichigo', "Kenpachi vs Ichigo: arm 0 NIL (his shipped CPU, his KI style CPU after the MCTS), arm 1 Ichigo's KI style CPU (the whole-game replacement)"),
    'kh': (':q1-ken-hisagi', "Kenpachi vs Hisagi: arm 0 NIL (his shipped CPU), arm 1 his KI style CPU (the whole-game replacement)"),
    'kk': (':q1-ken-ken', "the Kenpachi mirror: arm 0 NIL (the shipped CPU), arm 1 his KI style CPU (the second search's best cell)"),
    'ii': (':q1-ichigo-ichigo', "the Ichigo mirror: arm 0 NIL (the shipped CPU), arm 1 her KI style CPU (the second search's best cell)"),
    'ih': (':q1-ichigo-hisagi', "Ichigo vs Hisagi: arm 0 :ki-ichigo (the incumbent), arm 1 Kenpachi's KI style CPU (the best other strategy against the proxy pool)"),
}
for p, (sid, note) in NOTES.items():
    _, ap, arms, q = fq.read_table(os.path.join(HERE, p, f'{p}-fit.lisp'))
    rules = '\n              '.join(f'({fq.ante(c)} {q[c, 0]:.4f} {q[c, 1]:.4f})' for c in range(fq.NC))
    print(f'    ;; {note}; docs/research/strategy-drsi/fq/pairs/{p}/{p}-fit.lisp (§8.18)')
    print(f'    (:id {sid} :apply {ap} :fq (:arms {arms}\n         :rules ({rules})))')

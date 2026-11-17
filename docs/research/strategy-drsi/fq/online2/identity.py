#!/usr/bin/env python3
"""identity.py — online2's proofs (online2.md §2): Ichigo's shipped HARD table played (a) by the lookup, (b) raw from the dumped file, (c) with
the learner attached at eta 0 and eps 0, must give the same duel hash / duel state / gate-row lines; (d) eps 0.1 at eta 0 and (e) eta 0.05 at
eps 0 must not (exploration acts from match 1; learning from match 2, match 1 identical). The opponent is his shipped HARD CPU (the lookup).
  usage: identity.py [--seed0 500] [--n 10]   -> one JSON line per pairing x seat"""
import json, os, sys, tempfile
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
from simlib import build, run_lisp, pool   # noqa: E402

seed0 = int(sys.argv[sys.argv.index('--seed0') + 1]) if '--seed0' in sys.argv else 500
n = int(sys.argv[sys.argv.index('--n') + 1]) if '--n' in sys.argv else 10
keep = lambda t: [l for l in t.splitlines() if l.startswith(('duel hash', 'duel state', 'duel gate row'))]


def per_match(lines):
    """The lines split per match (a gate row closes a match)."""
    out, cur = [], []
    for l in lines:
        cur.append(l)
        if l.startswith('duel gate row'):
            out.append(cur); cur = []
    return out


def run(job):
    vs, seat, mode = job
    me, v = 3, {'kenpachi': 1, 'hisagi': 7}[vs]
    c1, c2 = (me, v) if seat == 'P1' else (v, me)
    table = os.path.join(HERE, f't0-{"ki" if vs == "kenpachi" else "ih"}-ichigo.lisp')
    env = {k: x for k, x in os.environ.items() if not k.startswith('STRAT_')}
    if mode != 'lookup':
        env['STRAT_' + seat] = table
    if mode in ('learn0', 'eps', 'eta'):
        env['STRAT_FQLEARN'] = f'- {tempfile.mktemp(suffix=".lisp")} {seat[1]}'
        env['STRAT_SET'] = {'learn0': '*fq-online-eta*=0,*fq-online-eps*=0', 'eps': '*fq-online-eta*=0,*fq-online-eps*=0.1',
                            'eta': '*fq-online-eta*=0.05,*fq-online-eps*=0'}[mode]
    r = run_lisp('simgate/strat-run.lisp', [30000 + seed0, 31100 + n, 81022, 200000 + 100 * c1 + 10 * c2], env=env)
    assert r.returncode == 0, r.stderr[-2000:]
    return per_match(keep(r.stdout))


build()
modes = ('lookup', 'file', 'learn0', 'eps', 'eta')
jobs = [(vs, seat, m) for vs in ('kenpachi', 'hisagi') for seat in ('P1', 'P2') for m in modes]
res = dict(zip(jobs, pool(run, jobs, 12)))
for vs in ('kenpachi', 'hisagi'):
    for seat in ('P1', 'P2'):
        ref = res[(vs, seat, 'lookup')]
        out = dict(vs=vs, seat=seat, seeds=f'{seed0 + 1}-{seed0 + n}', matches=len(ref), lines=sum(map(len, ref)))
        for m in modes[1:]:
            got = res[(vs, seat, m)]
            out[m] = [int(a == b) for a, b in zip(got, ref)]       # (1 = that match's lines identical to the lookup's)
        print(json.dumps(out))

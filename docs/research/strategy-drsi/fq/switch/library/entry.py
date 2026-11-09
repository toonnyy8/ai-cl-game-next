#!/usr/bin/env python3
"""entry.py — a research Q table (inline arms, sw.py's format) as a library entry in the unit format (DUEL_AI_STRATEGY §10): each arm mapped
to the arm unit of duel/lisp/strategy.lisp that plays the same (its :ID, :APPLY and :BASE's :P aside), the rules to the rule base they match
(their antecedents in order) and :Q. Exits naming an arm no unit plays (add the unit first).
usage: entry.py TABLE NEW-ID   -> the entry's text on stdout"""
import os, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../../../..'))
sys.path.insert(0, HERE)
from sexp import read_all, show, pget, pkeys  # noqa: E402

src = open(os.path.join(ROOT, 'duel/lisp/strategy.lisp')).read()


def defparam(name):
    i = src.index(f'(defparameter {name}')
    form = read_all(src[i:src.index('\n(def', i + 10)])[0]
    return form[form.index("'") + 1]


styles = {pget(x, ':id'): x for x in defparam('*strat-styles*')}
data = {pget(x, ':id'): x for x in defparam('*strat-data*')}
units = defparam('*strat-units*')
rbs = {pget(x, ':id'): [show(a) for a in pget(x, ':antes')] for x in defparam('*strat-rule-bases*')}


def compose(u):
    st = styles.get(pget(u, ':style'))
    ds = [data[d] for d in (pget(u, ':data') or [])]
    out = [':id', pget(u, ':id')]
    for pl in [u, st] + ds:
        for kk in pkeys(pl or []):
            if kk in (':id', ':style', ':data', ':base', ':rules') or kk in out[0::2]:
                continue
            out += [kk, pget(pl, kk)]
    base = [x for d in ds for x in (pget(d, ':base') or [])] + (pget(u, ':base') or [])
    rules = [x for d in ds for x in (pget(d, ':rules') or [])] + (pget(u, ':rules') or [])
    return out + ([':base', base] if base else []) + ([':rules', rules] if rules else [])


def norm(arm):
    if arm == 'nil':
        return 'nil'
    d = {}
    for kk in pkeys(arm):
        if kk in (':id', ':apply'):
            continue
        v = pget(arm, kk)
        if kk == ':base':
            v = [x for a, b in zip(v[0::2], v[1::2]) if a != ':p' for x in (a, b)]
            if not v:
                continue
        d[kk] = show(v)
    return tuple(sorted(d.items()))


unit_of = {norm(compose(u)): pget(u, ':id') for u in units}
unit_of['nil'] = 'nil'
table = read_all(open(sys.argv[1]).read())[0]
fq = pget(table, ':fq')
arms = []
for a in pget(fq, ':arms'):
    n = norm(a)
    if n not in unit_of:
        sys.exit(f'entry.py: no arm unit plays {show(a)}')
    arms.append(unit_of[n])
rules = pget(fq, ':rules')
antes = [show(r[0]) for r in rules]
rb = next((k for k, v in rbs.items() if v == antes), None)
if not rb:
    sys.exit('entry.py: the rules match no rule base')
keys = ''.join(f' {kk} {show(pget(fq, kk))}' for kk in pkeys(fq) if kk not in (':arms', ':rules', ':groups'))
pre = ''.join(f' {kk} {show(pget(table, kk))}' for kk in pkeys(table) if kk not in (':id', ':fq'))
qs = '\n          '.join('(' + ' '.join(r[1:]) + ')' for r in rules)
print(f'(:id {sys.argv[2]}{pre} :fq (:arms ({" ".join(arms)}) :rule-base {rb}{keys}\n         :q ({qs})))')

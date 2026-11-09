#!/usr/bin/env python3
"""refactor.py — the one-time rewrite of duel/lisp/strategy.lisp's *STRAT-LIBRARY* into units (DUEL_AI_STRATEGY §10; the user, 2026-11-09:
「不設上限，但將相似的策略合併，或將策略解耦成更小的單位，確保策略庫的『高內聚、低耦合』」). Reads the inline library, writes:
  - the units (units.lisp here: styles, data, arms), the rule bases (built from the tables: the 48 crisp rules, the 89 grouped ones), the
    expansion (expand.lisp here), in front of the library;
  - each Q table as (:arms (arm ids) :rule-base RB :q ((q ...) ...) keys), each arm mapped to the unit that plays the same (its :ID, :APPLY and
    :P aside: :P is a strategy-layer prior, STRAT-PRIOR reads it only on library entries, never on a table's arms);
  - the plain strategies listed in COMPOSED by their units (comments kept);
  - *STRAT-LIBRARY* = (mapcar #'strat-expand '(...)).
usage: refactor.py FILE   (rewrites FILE in place; run once on the inline library)"""
import os, re, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from sexp import read_all, show, pget, pkeys  # noqa: E402

path = sys.argv[1]
src = open(path).read()
HEAD = "(defparameter *strat-library*\n  '("
i = src.index(HEAD)
j = src.index('\n  "The strategies the layer chooses from', i)
body = src[i + len(HEAD) - 1:j]                     # "(...entries...)" with comments
assert body.endswith(')')

# the top-level items of the list, with their source spans
items, k, depth, start = [], 1, 0, None
while k < len(body) - 1:
    ch = body[k]
    if ch == ';':
        k = body.index('\n', k)
        continue
    if ch == '(':
        if depth == 0:
            start = k
        depth += 1
    elif ch == ')':
        depth -= 1
        if depth == 0:
            items.append((start, k + 1))
    k += 1


def norm(arm):
    """An arm's behaviour: its keys but :ID / :APPLY, :BASE without :P (a strategy-layer prior only)."""
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


# the units' behaviour, from units.lisp (expanded as STRAT-COMPOSE does)
U = read_all(open(os.path.join(HERE, 'units.lisp')).read())
ql = lambda form: form[form.index("'") + 1]          # (the quoted list of a DEFPARAMETER)
styles = {pget(x, ':id'): x for x in ql(U[0])}
data = {pget(x, ':id'): x for x in ql(U[1])}
units = ql(U[2])


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


unit_of = {}
for u in units:
    n = norm(compose(u))
    assert n not in unit_of, ('two arm units play the same', pget(u, ':id'), unit_of[n])
    unit_of[n] = pget(u, ':id')
unit_of['nil'] = 'nil'

# the rule bases, from the first table of each size
lib = [read_all(body[a:b])[0] for a, b in items]
rb = {}
for e in lib:
    fq = pget(e, ':fq')
    if fq:
        antes = [r[0] for r in pget(fq, ':rules')]
        key = ':rb-switch89' if len(antes) == 89 else ':rb-crisp48'
        rb.setdefault(key, (antes, pget(fq, ':groups')))
        assert [show(a) for a in rb[key][0]] == [show(a) for a in antes], ('a table with other antecedents', pget(e, ':id'))


def table_text(e):
    fq = pget(e, ':fq')
    arms = [unit_of[norm(a)] for a in pget(fq, ':arms')]
    rules = pget(fq, ':rules')
    key = ':rb-switch89' if len(rules) == 89 else ':rb-crisp48'
    keys = [(kk, pget(fq, kk)) for kk in pkeys(fq) if kk not in (':arms', ':rules', ':groups')]
    if pget(fq, ':groups'):
        assert show(pget(fq, ':groups')) == show(rb[key][1])
    head = [kk for kk in pkeys(e) if kk not in (':id', ':fq')]
    pre = ' '.join(f'{kk} {show(pget(e, kk))}' for kk in head)
    qs = '\n          '.join('(' + ' '.join(r[1:]) + ')' for r in rules)
    ks = ''.join(f' {kk} {show(v)}' for kk, v in keys)
    return (f'(:id {pget(e, ":id")} {pre} :fq (:arms ({" ".join(arms)}) :rule-base {key}{ks}\n'
            f'         :q ({qs})))')


COMPOSED = {
    ':s1-brawler': '(:id :s1-brawler :data (:d-brawler :d-brawler-prior))',
    ':s3-zoner': '(:id :s3-zoner :data (:d-zoner :d-zoner-extra))',
    ':ki-ken': '(:id :ki-ken :style :st-ken-ki :apply (:kenpachi :ichigo) :base (:p 1.3))',
    ':ki-ichigo': '(:id :ki-ichigo :style :st-ichigo-ki :apply (:ichigo :kenpachi) :base (:p 1.3))',
    ':s7-kite': '(:id :s7-kite :apply (:hisagi :kenpachi) :data (:d-kite :d-red-kikon))',
    ':c1-ichigo-ken': '(:id :c1-ichigo-ken :apply (:ichigo :kenpachi)\n     :switch (((((:ost :free) (:lead :behind)) ((:ost :free) (:ored :yes))) . :a-ichigo-ki))\n     :else :a-ken-ki)',
    ':h1-range': '(:id :h1-range :style :st-hisagi-range :data (:d-dswitch :d-no-far-ns))',
    ':hm1-merged': '(:id :hm1-merged :style :st-hisagi-merged)',
}

out, last = [], 0
for (a, b), e in zip(items, lib):
    seg = body[last:a]
    if pget(e, ':id') == ':s7-kite':                     # (its inline comment rode on the entry's first line)
        seg = seg + ';; (the counter search\'s round 1, counter/kh-hisagi b1_a2, DUEL_AI_STRATEGY §8.8)\n    '
    out.append(seg)
    eid = pget(e, ':id')
    if pget(e, ':fq'):
        out.append(table_text(e))
    elif eid in COMPOSED:
        out.append(COMPOSED[eid])
    else:
        out.append(body[a:b])
    last = b
out.append(body[last:])
new_body = ''.join(out)


def rb_text(key):
    antes, groups = rb[key]
    a = '\n     '.join(show(x) for x in antes)
    g = f' :groups {show(groups)}' if groups else ''
    return f'    (:id {key}{g}\n     :antes ({a}))'


rbs = (';;; the rule bases: a Q table\'s antecedents in order (fq.py\'s 48 crisp cells; switch/sw.py\'s 89 in 5 groups, §8.19)\n'
       '(defparameter *strat-rule-bases*\n  \'(' + rb_text(':rb-crisp48')[4:] + '\n' + rb_text(':rb-switch89') + ')\n'
       '  "The rule bases: a Q table names one (:RULE-BASE) and carries only its q per rule and arm (:Q) (DUEL_AI_STRATEGY §10).")\n\n')
units_text = open(os.path.join(HERE, 'units.lisp')).read()
expand_text = open(os.path.join(HERE, 'expand.lisp')).read()
lib_text = '(defparameter *strat-library*\n  (mapcar #\'strat-expand\n  \'' + new_body + ')'
src = src[:i] + units_text + '\n' + rbs + expand_text + '\n' + lib_text + src[j:]
open(path, 'w').write(src)
print('items', len(items), 'units', len(units), 'rule bases', list(rb))

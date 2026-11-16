#!/usr/bin/env python3
"""tab.py — write a raw :rb-sp2 table file from a base table (arms5/t0/t0-ih-ichigo.lisp's layout: the rule base inline, one rule a line)
with new arms and a new q matrix. Used as a module by arms6/ih.md's candidate scripts (cands.py).

  write(base, out, sid, arms, q)   arms: list of one-line arm plists; q(ante, k) -> float for rule antecedent text ANTE and arm k
"""
import re

LINE = re.compile(r"^(\s*(?::rules \()?\()(\(\(.*?\)\))((?: -?\d+\.\d+)+)\)(\)*)\s*$")


def split_arms(s):
    """The :arms list's members (top-level plists) as strings, and the span of the list in S."""
    i = s.index(':arms (') + len(':arms (')
    out, depth, start = [], 0, None
    for j in range(i, len(s)):
        c = s[j]
        if c == '(':
            if depth == 0:
                start = j
            depth += 1
        elif c == ')':
            if depth == 0:
                return out, (i, j)
            depth -= 1
            if depth == 0:
                out.append(s[start:j + 1])


def rules(s):
    """[(ante, [q...])] in file order."""
    return [(m[2], [float(x) for x in m[3].split()]) for l in s.splitlines() for m in [LINE.match(l)] if m]


def write(base, out, sid, arms, q, note='', subs=()):
    """SUBS: (old, new) text replacements on the base first (each must occur once), e.g. the inline :with unit."""
    s = open(base).read()
    for old, new in subs:
        assert s.count(old) == 1, old
        s = s.replace(old, new)
    _, (a, b) = split_arms(s)
    s = s[:a] + ' '.join(arms) + s[b:]
    s = re.sub(r'\(:id :[\w-]+ :apply', f'(:id {sid} :apply', s, count=1)
    lines = []
    for l in s.splitlines():
        m = LINE.match(l)
        if m:
            l = m[1] + m[2] + ''.join(f' {q(m[2], k):.4f}' for k in range(len(arms))) + ')' + m[4]
        lines.append(l)
    body = '\n'.join(l for l in lines if not l.startswith(';;'))
    with open(out, 'w') as f:
        f.write(f';; arms6/tab.py from {base}: {note}\n' + body + '\n')


def arm(src_file, aid):
    """Arm AID's one-line plist from a table or arms file."""
    s = open(src_file).read()
    for t in (split_arms(s)[0] if ':arms (' in s else re.findall(r'^\(:id .*$', s, re.M)):
        if t.startswith(f'(:id {aid} '):
            return t
    raise KeyError(aid)

#!/usr/bin/env python3
"""SOUL DUEL's debug command ranges, checked without the engine (refactor round 2, 2026-10-21; it replaces the
DEFDEBUG registry of REFACTOR_NEXT N1).  python3 tests/debug-ranges-check.py [-v]  -> exit 1 on a problem (-v: list the nested ranges too).

Reads debug.lisp's DEBUG-COMMAND (its cond clauses `((<= lo c hi)` / `((= c n)` in order, and the clause that consults
*CHAR-DEBUG*) and every `(pushnew '(lo hi fn) *char-debug*)` (+ senjumaru.lisp's dolist) in MANIFEST order (pushnew: the
last file loaded is consulted first), then checks:
 1. two ranges overlap only as "specific before generic": the one consulted first lies inside the later one (2209 in
    2200-2299, the 2300-2399 specifics before FORCE-SPECIAL's catch-all, a character's art stills before its own range);
    a partial overlap, or a range swallowed by an earlier one, is an error;
 2. every clause of a registered character function lies inside that function's registered ranges (else unreachable);
 3. every range's low number appears in docs/duel/DUEL_GAMEPLAY.md "Debug commands" (claim a range THERE first);
 4. every DEBUG-COMMAND clause that plays a cinematic still (CINE-AT / FORCE-CINE) lies inside CINE-STILL-COMMAND-P
    (else the command before it lets go of the held cinematic)."""
import os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
LISP = os.path.join(ROOT, 'duel', 'lisp')
CLAUSE = re.compile(r'\(\((?:<= (\d+) c (\d+)|= c (\d+))\)|\(\(loop for \(lo hi fn\) in \*char-debug\*')


def defun(text, name):
    """The text of (defun NAME ...) up to the next top-level form."""
    i = text.index('(defun %s ' % name)
    m = re.compile(r'\n\(').search(text, i + 1)
    return text[i:m.start() if m else len(text)]


def clauses(body):
    """[(lo, hi, clause text)] in order; (None, None, '') for the *char-debug* clause."""
    ms = list(CLAUSE.finditer(body))
    out = []
    for k, m in enumerate(ms):
        txt = body[m.start():ms[k + 1].start() if k + 1 < len(ms) else len(body)]
        if m.group(3):
            out.append((int(m.group(3)), int(m.group(3)), txt))
        elif m.group(1):
            out.append((int(m.group(1)), int(m.group(2)), txt))
        else:
            out.append((None, None, ''))
    return out


def main():
    files = [l.strip() for l in open(os.path.join(ROOT, 'duel', 'MANIFEST')) if l.strip() and not l.startswith('#')]
    texts = {f: open(os.path.join(ROOT, 'duel', f)).read() for f in files}
    debug = texts['lisp/debug.lisp']
    pushes = []                                   # (lo, hi, fn, file) in load order
    for f in files:
        t = texts[f]
        for m in re.finditer(r"\(pushnew '\((\d+) (\d+) ([^ )]+)\) \*char-debug\*", t):
            pushes.append((int(m.group(1)), int(m.group(2)), m.group(3), f))
        for m in re.finditer(r"\(dolist \(r '\(((?:\(\d+ \d+ [^ )]+\) ?)+)\)\)\s*\(pushnew r \*char-debug\*", t):
            for r in re.finditer(r'\((\d+) (\d+) ([^ )]+)\)', m.group(1)):
                pushes.append((int(r.group(1)), int(r.group(2)), r.group(3), f))
    chars = [(lo, hi, 'char-debug %s (%s)' % (fn, f)) for lo, hi, fn, f in reversed(pushes)]
    order, stills = [], []
    for lo, hi, txt in clauses(defun(debug, 'debug-command')):
        if lo is None:
            order += chars
        else:
            order.append((lo, hi, 'debug-command (= %d)' % lo if lo == hi else 'debug-command (%d-%d)' % (lo, hi)))
            if '(cine-at ' in txt or '(force-cine ' in txt:
                stills.append((lo, hi))
    errors, notes = [], []
    for i, (alo, ahi, an) in enumerate(order):
        for blo, bhi, bn in order[i + 1:]:
            if ahi < blo or bhi < alo:
                continue
            if blo <= alo and ahi <= bhi and (alo, ahi) != (blo, bhi):
                notes.append('%s inside %s' % (an, bn))
            else:
                errors.append('overlap: %s is consulted before %s' % (an, bn))
    for fn in sorted({p[2] for p in pushes}):
        src = next((t for t in texts.values() if '(defun %s ' % fn in t), None)
        if src is None:
            errors.append('char-debug %s: no defun' % fn)
            continue
        regs = [(lo, hi) for lo, hi, f, _ in pushes if f == fn]
        for lo, hi, _ in clauses(defun(src, fn)):
            if lo is not None and not any(rlo <= lo and hi <= rhi for rlo, rhi in regs):
                errors.append('%s: its clause %d-%d is outside its registered ranges %s' % (fn, lo, hi, regs))
    gp = open(os.path.join(ROOT, 'docs', 'duel', 'DUEL_GAMEPLAY.md')).read()
    sec = gp[gp.index('## Debug commands'):]
    sec = sec[:sec.find('\n## ', 1)]
    for lo, hi, n in order:
        if not re.search(r'(?<!\d)%d(?!\d)' % lo, sec):
            errors.append('%s: %d is not in DUEL_GAMEPLAY "Debug commands"' % (n, lo))
    hold = [(int(a), int(b)) for a, b in re.findall(r'\(<= (\d+) c (\d+)\)', defun(debug, 'cine-still-command-p'))]
    for lo, hi in stills:
        if not any(a <= lo and hi <= b for a, b in hold):
            errors.append('debug-command %d-%d plays a cinematic still but is not in CINE-STILL-COMMAND-P' % (lo, hi))
    for n in notes if '-v' in sys.argv else ():
        print('ok   ', n)
    for e in errors:
        print('ERROR', e)
    print('%d ranges (%d through *char-debug*), %d nested, %d errors' % (len(order), len(chars), len(notes), len(errors)))
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())

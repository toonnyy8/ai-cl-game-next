#!/usr/bin/env python3
"""SOUL DUEL's debug command ranges, checked without the engine (refactor round 2, 2026-10-21; since REFACTOR_2026-11 R11,
2026-11-13, the ranges are DEFINE-DEBUG-RANGE forms, engine/lisp/debug-ranges.lisp, which refuses an overlap at load: this
checker also runs without a build and holds the doc and the still rules).
  python3 tests/debug-ranges-check.py [-v]  -> exit 1 on a problem (-v: list the nested ranges too).

Reads every `(define-debug-range (lo hi) HANDLER)` (a character file's function) and `(define-debug-range (lo hi) (c) BODY)`
(debug.lisp's own) in the duel MANIFEST's files, then checks:
 1. two ranges overlap only as one inside the other (the narrower one wins: 2209 in 2200-2299, the 2300-2399 specifics in
    FORCE-SPECIAL's catch-all, a character's art stills in its own range); a partial overlap or a span claimed twice is an
    error (the engine refuses it at load too);
 2. every clause of a character handler lies inside that function's registered ranges (else unreachable);
 3. every range's low number appears in docs/duel/DUEL_GAMEPLAY.md "Debug commands" (claim a range THERE first);
 4. every range that plays a cinematic still (CINE-AT / FORCE-CINE) lies inside CINE-STILL-COMMAND-P (else the command
    before it lets go of the held cinematic)."""
import os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
CLAUSE = re.compile(r'\(\((?:<= (\d+) c (\d+)|= c (\d+))\)')
RANGE = re.compile(r'^\(define-debug-range \((\d+) (\d+)\) (\([^)]*\)|[^ ()\n]+\))', re.M)


def defun(text, name):
    """The text of (defun NAME ...) up to the next top-level form."""
    i = text.index('(defun %s ' % name)
    m = re.compile(r'\n\(').search(text, i + 1)
    return text[i:m.start() if m else len(text)]


def clauses(body):
    """[(lo, hi)] of a handler's cond clauses, in order."""
    return [(int(m.group(3)), int(m.group(3))) if m.group(3) else (int(m.group(1)), int(m.group(2)))
            for m in CLAUSE.finditer(body)]


def ranges(files, texts):
    """[(lo, hi, handler or None, body text, file)] in load order (the body: up to the next top-level form)."""
    out = []
    for f in files:
        t = texts[f]
        ms = list(RANGE.finditer(t))
        for m in ms:
            nxt = re.compile(r'\n[(;]').search(t, m.end())
            body = t[m.end():nxt.start() if nxt else len(t)]
            h = m.group(3)
            out.append((int(m.group(1)), int(m.group(2)), None if h.startswith('(') else h[:-1], body, f))
    return out


def main():
    files = [l.strip() for l in open(os.path.join(ROOT, 'duel', 'MANIFEST')) if l.strip() and not l.startswith('#')]
    texts = {f: open(os.path.join(ROOT, 'duel', f)).read() for f in files}
    rs = ranges(files, texts)
    name = lambda r: '%s %d-%d (%s)' % (r[2] or 'inline', r[0], r[1], r[4])
    errors, notes = [], []
    for i, a in enumerate(rs):
        for b in rs[i + 1:]:
            if a[1] < b[0] or b[1] < a[0]:
                continue
            if (a[0], a[1]) == (b[0], b[1]):
                errors.append('claimed twice: %s and %s' % (name(a), name(b)))
            elif a[0] <= b[0] and b[1] <= a[1]:
                notes.append('%s inside %s' % (name(b), name(a)))
            elif b[0] <= a[0] and a[1] <= b[1]:
                notes.append('%s inside %s' % (name(a), name(b)))
            else:
                errors.append('overlap: %s and %s' % (name(a), name(b)))
    handlers = sorted({r[2] for r in rs if r[2]})
    for fn in handlers:
        src = next((t for t in texts.values() if '(defun %s ' % fn in t), None)
        if src is None:
            errors.append('debug handler %s: no defun' % fn)
            continue
        regs = [(r[0], r[1]) for r in rs if r[2] == fn]
        for lo, hi in clauses(defun(src, fn)):
            if not any(rlo <= lo and hi <= rhi for rlo, rhi in regs):
                errors.append('%s: its clause %d-%d is outside its registered ranges %s' % (fn, lo, hi, regs))
    gp = open(os.path.join(ROOT, 'docs', 'duel', 'DUEL_GAMEPLAY.md')).read()
    sec = gp[gp.index('## Debug commands'):]
    sec = sec[:sec.find('\n## ', 1)]
    for r in rs:
        if not re.search(r'(?<!\d)%d(?!\d)' % r[0], sec):
            errors.append('%s: %d is not in DUEL_GAMEPLAY "Debug commands"' % (name(r), r[0]))
    hold = [(int(a), int(b)) for a, b in re.findall(r'\(<= (\d+) c (\d+)\)', defun(texts['lisp/debug.lisp'], 'cine-still-command-p'))]
    for r in rs:
        if r[2] is None and ('(cine-at ' in r[3] or '(force-cine ' in r[3]):
            if not any(a <= r[0] and r[1] <= b for a, b in hold):
                errors.append('%s plays a cinematic still but is not in CINE-STILL-COMMAND-P' % name(r))
    for n in notes if '-v' in sys.argv else ():
        print('ok   ', n)
    for e in errors:
        print('ERROR', e)
    print('%d ranges (%d through a character handler), %d nested, %d errors'
          % (len(rs), sum(1 for r in rs if r[2]), len(notes), len(errors)))
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())

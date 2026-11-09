"""sexp.py — a small reader / printer for the strategy library's plists (DUEL_AI_STRATEGY §10): symbols and keywords as str, numbers as their
source text (so a printed float is the same token the Lisp reader saw), lists as list. No strings, no quotes inside the data."""
import re

TOK = re.compile(r'\s*(?:(;[^\n]*)|(\()|(\))|([^\s()]+))')


def read_all(text):
    """Every top-level form of TEXT (comments dropped)."""
    stack, out = [[]], None
    pos = 0
    while pos < len(text):
        m = TOK.match(text, pos)
        if not m or m.end() == pos:
            break
        pos = m.end()
        if m.group(1):
            continue
        if m.group(2):
            stack.append([])
        elif m.group(3):
            lst = stack.pop()
            stack[-1].append(lst)
        elif m.group(4):
            stack[-1].append(m.group(4))
    return stack[0]


def show(x):
    """X printed back."""
    if isinstance(x, list):
        return '(' + ' '.join(show(y) for y in x) + ')'
    return x


def pget(pl, key, default=None):
    """GETF on a parsed plist."""
    for i in range(0, len(pl) - 1, 2):
        if pl[i] == key:
            return pl[i + 1]
    return default


def pkeys(pl):
    return [pl[i] for i in range(0, len(pl) - 1, 2)]

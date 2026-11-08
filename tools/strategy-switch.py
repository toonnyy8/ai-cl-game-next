#!/usr/bin/env python3
"""strategy-switch.py — the evaluator of the counter-strategy search (docs/duel/DUEL_AI_STRATEGY.md §8.7; the user, 2026-11-08: 「只看切換增益」).

  python3 tools/strategy-switch.py --char ichigo --vs hisagi --cand FILE [--diff hard] [--seeds 100] [--seed0 500] [-j 5] [--out FILE.json]

FILE is a strategy plist (duel/lisp/strategy.lisp) with an extra :own, the situations it claims (antecedents as a :rules entry's, OR across
the list). The character plays the COMPOSITE (:id :switch-<id> :switch ((OWN . the strategy without :own))) -- the shipped CPU, with its
lookup and style CPU, except while OWN fires (re-judged every 90 steps in neutral) -- against the opponent's shipped CPU, both seats, seeds
seed0+1..seed0+n; the INCUMBENT (no strategy on either seat) plays the same seeds (cached: measured once per build).
  comp_share / inc_share  the character's win shares (a draw / time-out counts 0);  gain = comp - inc
  b / c                   paired counts on the same seed and seat: composite won and incumbent lost / the reverse;  z = (b - c) / sqrt(b + c)
  own_share               the candidate's judgements / all the composite's judgements (the share of windows it held)
  score                   max(0.005, comp_share), or the incumbent's share when own_share > --max-own (capped)
--raw: FILE goes to the character's seat as it is (STRAT_P<seat>, no wrapping, no :own needed): a composite or a Q selector (:fq) whose
every window is its own, measured against the incumbent (the shipped CPU, its lookup included); own_share then counts every judgement and
`held` gives the judgements per entry / arm (DUEL_AI_STRATEGY §8.12).
Raw match output is cached in build/strategy-eval-cache/ by (build hash, composite text, characters, difficulty, seed block). At most 8 sim processes.
"""
import argparse, concurrent.futures as cf, hashlib, json, math, os, re, subprocess, sys, tempfile, time
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from simgate import ROOT, ECL, FAS, MUSLM, build

ROSTER = {'kenpachi': 1, 'ichigo': 3, 'hisagi': 7}      # roster indices (kit.lisp *ROSTER*)
DIFF = {'easy': 0, 'normal': 1, 'hard': 2}
CACHE = os.path.join(ROOT, 'build/strategy-eval-cache')
RUNNER = os.path.join(ROOT, 'tools/simgate/strat-run.lisp')
CHUNK = 25                                               # seeds a sim process (<= 99: debug 31100+n)
KEEP = ('duel gate row ', 'switch ', 'strat ', 'duel -> RESULTS', 'duel hash', 'duel state')   # the raw lines worth keeping


def sha(b):
    return hashlib.sha1(b).hexdigest()[:16]


def strip_lisp(text):
    """The text without ;-comments (strings respected)."""
    out, i, n, instr = [], 0, len(text), False
    while i < n:
        ch = text[i]
        if instr:
            out.append(ch)
            if ch == '\\' and i + 1 < n:
                out.append(text[i + 1]); i += 1
            elif ch == '"':
                instr = False
        elif ch == '"':
            instr = True; out.append(ch)
        elif ch == ';':
            while i < n and text[i] != '\n':
                i += 1
            continue
        else:
            out.append(ch)
        i += 1
    return ''.join(out)


def form_end(text, i):
    """Index just past the form starting at text[i] (a list, a string or an atom)."""
    n = len(text)
    if text[i] == '(':
        depth, instr = 0, False
        while i < n:
            ch = text[i]
            if instr:
                if ch == '\\':
                    i += 1
                elif ch == '"':
                    instr = False
            elif ch == '"':
                instr = True
            elif ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
                if depth == 0:
                    return i + 1
            i += 1
        sys.exit('strategy-switch: unbalanced parentheses in the candidate file')
    while i < n and not text[i].isspace() and text[i] not in '()':
        i += 1
    return i


def split_cand(path):
    """-> (id, strategy text without :own, the :own form's text). Exits with a message when the file does not READ as a plist with :own."""
    text = strip_lisp(open(path).read()).strip()
    if not text.startswith('('):
        sys.exit(f'strategy-switch: {path}: not a plist (expected a form starting with an open parenthesis)')
    if form_end(text, 0) != len(text):
        sys.exit(f'strategy-switch: {path}: more than one top-level form, or unbalanced parentheses')
    i, own = 1, None
    cut = None
    while i < len(text) - 1:
        if text[i].isspace():
            i += 1
            continue
        j = form_end(text, i)
        if text[i:j].lower() == ':own':
            k = i + 1 + (j - i - 1)                      # the value follows
            while text[k].isspace():
                k += 1
            e = form_end(text, k)
            own, cut = text[k:e], (i, e)
            i = e
        else:
            i = j
    if own is None:
        sys.exit(f'strategy-switch: {path}: no :own in the candidate plist')
    strat = text[:cut[0]] + text[cut[1]:]
    m = re.search(r'\(\s*:id\s+(\S+?)[\s)]', strat) or re.search(r':id\s+([^\s()]+)', strat)
    cid = m.group(1).lstrip(':') if m else 'cand'
    return cid, strat, own


def composite_text(path):
    cid, strat, own = split_cand(path)
    return cid, f'(:id :switch-{cid} :switch (({own} . {strat})))\n'


_bh = []
def build_hash():
    if not _bh:
        _bh.append(sha(open(FAS, 'rb').read() + open(RUNNER, 'rb').read()))
    return _bh[0]


def run_job(c1, c2, comp, diff, seed0, n):
    """One sim process: roster c1 (P1) vs c2 (P2), seeds seed0+1..seed0+n; COMP = (seat 'P1'|'P2', composite file path, text) or None. -> kept stdout (cached)."""
    key = sha(json.dumps([c1, c2, comp[0] if comp else None, comp[2] if comp else None, diff, seed0, n, build_hash()]).encode())
    path = os.path.join(CACHE, 'sw-' + key + '.out')
    if os.path.exists(path):
        return open(path).read()
    os.makedirs(CACHE, exist_ok=True)
    env = dict(os.environ, LD_PRELOAD=MUSLM)
    for k in ('STRAT_P1', 'STRAT_P2', 'STRAT_LAYER', 'STRAT_SET', 'STRAT_WIN'):
        env.pop(k, None)
    if comp:
        env['STRAT_' + comp[0]] = comp[1]
    cmds = [30000 + seed0, 31100 + n, 81000, 81020 + diff, 81030, 81040, 200000 + 100 * c1 + 10 * c2]
    r = subprocess.run([ECL, '--norc', '--load', 'tools/simgate/strat-run.lisp', '--', FAS] + [str(c) for c in cmds], cwd=ROOT,
                       capture_output=True, text=True, env=env, timeout=7200)
    if r.returncode:
        sys.exit(f'strategy-switch: sim exited {r.returncode} (chars {c1}/{c2}, seeds {seed0 + 1}-{seed0 + n})\n' + (r.stdout + r.stderr)[-2000:])
    out = '\n'.join(l for l in r.stdout.splitlines() if l.startswith(KEEP))
    if not re.search(r'duel gate row ', out) or len(re.findall(r'duel gate row ', out)) != n:
        sys.exit(f'strategy-switch: expected {n} gate rows, got {len(re.findall("duel gate row ", out))}\n' + (r.stdout + r.stderr)[-2000:])
    with open(path + '.tmp', 'w') as f:
        f.write(out + '\n')
    os.replace(path + '.tmp', path)
    return out


def parse(outs, seat):
    """-> ({seed: 1 if `seat` won}, judged, [held per entry])."""
    wins, judged, held = {}, 0, None
    for out in outs:
        for line in out.splitlines():
            m = re.search(r'duel gate row seed (\d+) .* winner (\S+)', line)
            if m:
                wins[int(m.group(1))] = int(m.group(2) == seat)
                continue
            m = re.match(r'switch ' + seat + r' \S+ judged (\d+) held ?(.*)', line)
            if m:
                judged += int(m.group(1))
                h = [int(x) for x in m.group(2).split()]
                held = h if held is None else [a + b for a, b in zip(held, h)]
    return wins, judged, held or []


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--char', required=True, choices=list(ROSTER))
    ap.add_argument('--vs', required=True, choices=list(ROSTER))
    ap.add_argument('--cand', required=True, help='a strategy plist with :own')
    ap.add_argument('--diff', default='hard', choices=list(DIFF))
    ap.add_argument('--seeds', type=int, default=100, help='seeds a seat')
    ap.add_argument('--seed0', type=int, default=500, help='seeds seed0+1..seed0+seeds; the offset command (debug 30000+k) takes k <= 999')
    ap.add_argument('-j', type=int, default=5)
    ap.add_argument('--max-own', type=float, help='over this own_share the candidate scores as the incumbent (round 2: 0.6)')
    ap.add_argument('--raw', action='store_true', help='pass FILE through unwrapped (a composite or a Q selector)')
    ap.add_argument('--out')
    a = ap.parse_args()
    t0 = time.time()
    if not 0 <= a.seed0 <= 999 or a.seed0 + ((a.seeds - 1) // CHUNK) * CHUNK > 999:
        sys.exit('strategy-switch: each sim chunk starts at an offset k = seed0 + 25 i <= 999 (debug 30000+k)')
    if a.raw:
        text = strip_lisp(open(a.cand).read()).strip() + '\n'
        m = re.search(r':id\s+:?([^\s()]+)', text)
        cid = m.group(1) if m else 'cand'
    else:
        cid, text = composite_text(a.cand)
    me, op, diff = ROSTER[a.char], ROSTER[a.vs], DIFF[a.diff]
    tmp = tempfile.NamedTemporaryFile('w', suffix='.lisp', prefix='switch-', delete=False, dir=os.path.join(ROOT, 'build'))
    tmp.write(text); tmp.close()
    build()
    chunks = [(a.seed0 + s, min(CHUNK, a.seeds - s)) for s in range(0, a.seeds, CHUNK)]
    jobs = []                                            # (tag, seat, args)
    for seat, (c1, c2) in (('P1', (me, op)), ('P2', (op, me))):
        for tag in ('comp', 'inc'):
            for s0, n in chunks:
                jobs.append((tag, seat, (c1, c2, (seat, tmp.name, text) if tag == 'comp' else None, diff, s0, n)))
    try:
        with cf.ThreadPoolExecutor(max(1, min(8, a.j))) as ex:
            outs = list(ex.map(lambda j: run_job(*j[2]), jobs))
    finally:
        os.unlink(tmp.name)
    got = {(t, s): [] for t in ('comp', 'inc') for s in ('P1', 'P2')}
    for (tag, seat, _), o in zip(jobs, outs):
        got[(tag, seat)].append(o)
    cw = iw = m = b = c = judged = own = 0
    held_all = []
    for seat in ('P1', 'P2'):
        w_c, j, held = parse(got[('comp', seat)], seat)
        w_i, _, _ = parse(got[('inc', seat)], seat)
        judged += j
        own += sum(held)
        held_all = held if not held_all else [x + y for x, y in zip(held_all, held)]
        for sd, v in w_c.items():
            cw += v
            iw += w_i[sd]
            m += 1
            b += v == 1 and w_i[sd] == 0
            c += v == 0 and w_i[sd] == 1
    comp, inc = cw / m, iw / m
    osh = own / judged if judged else 0.0
    capped = a.max_own is not None and osh > a.max_own        # (DUEL_AI_STRATEGY §8.9: a counter owns a slice, not the game)
    res = dict(char=a.char, vs=a.vs, diff=a.diff, cand=cid, seeds=a.seeds, seed0=a.seed0,
               comp_wins=cw, comp_matches=m, inc_wins=iw, inc_matches=m, comp_share=round(comp, 4), inc_share=round(inc, 4),
               gain=round(comp - inc, 4), b=int(b), c=int(c), z=round((b - c) / math.sqrt(b + c), 3) if b + c else 0.0,
               own_share=round(own / judged, 4) if judged else 0.0, wall_s=round(time.time() - t0, 1), score=round(max(0.005, inc if capped else comp), 4), capped=capped,
               judged=judged, held=held_all, raw=a.raw)
    print(json.dumps(res, indent=1))
    if a.out:
        with open(a.out, 'w') as f:
            json.dump(res, f, indent=1)


if __name__ == '__main__':
    main()

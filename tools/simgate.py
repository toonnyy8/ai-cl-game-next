#!/usr/bin/env python3
"""simgate.py — SOUL DUEL's seed gate on the host, no browser (docs/duel/DUEL_GAMEPLAY.md "Pacing gate").

The duel's Lisp (engine + duel MANIFESTs, unchanged) is compiled natively by the 32-bit host ECL with a headless C layer
(tools/simgate/build.lisp, stubs.c); each process runs the page's real frame loop with the gate's debug commands, one
core each. Pairings x seed chunks fan out over -j processes; the rows are merged and every pairing gets the browser
gate's summary line, plus a wins / blow-aways line.

  python3 tools/simgate.py                         every pairing (15 for 5 characters), seeds 1-20 (= GATE_CMD(k) on the browser)
  python3 tools/simgate.py --pairs 0,1,2 --seeds 10         YY YK KK, seeds 1-10 (the quick pass)
  python3 tools/simgate.py --summary               summary lines only (rows omitted)
  python3 tools/simgate.py --cvc                   self-check: G2's three CPU matches (tests/scripts/duel-cvc-*.json)
                                                   natively vs the browser's tests/style-cvc-ref.txt, line for line

--cmd N (repeatable) queues debug command N before each process's gate command, as a run.mjs script would (knobs:
74385, ...; 39000+10a+b, the old awaken A/B, left with the old AI in R3). Pairing k is gate.lisp *PAIRS*' index (0 YY 1 YK 2 KK 3 RY 4 RK 5 RR 6 IY 7 IK 8 IR 9 II
10 SY 11 SK 12 SR 13 SS 14 SI; then, per later character in ROSTER order, its pairings with every earlier one and its
mirror: PAIRS, ROSTER-PAIRS in gate.lisp). A new character = its name appended to ROSTER, nothing else. The build (build/simgate/duel.fas, ~2 min) is redone when a source is newer.
One process plays a pairing's seeds back to back, as the page does. --chunk N splits them over processes (faster for
one long stream); rows are the same either way (Senjumaru's per-side state carried over between matches until
2026-09-29, DEVLOG §38-§39: SJ now makes a fresh one per fighter).
"""
import argparse, math, os, re, sys

sys.dont_write_bytecode = True   # (no tools/__pycache__ from the import below)
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from simlib import ROOT, ECL, FAS, EMSDK, MUSLM, build, run_lisp, pool   # noqa: E402,F401  (re-exported: the other tools and the research scripts import them from here)

ROSTER = ['YAMAMOTO', 'KENPACHI', 'RUKIA', 'ICHIGO', 'SENJUMARU', 'LILLE', 'BARRO', 'HISAGI']   # kit.lisp *ROSTER*, in order (the tools' one roster list)
RETIRED = {'LILLE', 'YAMAMOTO', 'RUKIA', 'SENJUMARU', 'BARRO'}   # kit.lisp *RETIRED*: index 5, the old Lille's slot (out 2026-10-12, his code removed 2026-10-13); BARRO is Lille
# gate.lisp ROSTER-PAIRS: the first five characters' fifteen in their historical order (YK has P1 Yamamoto; SS before SI),
# then per later character i its pairings (i, j) with every earlier j, then its mirror (i, i)
PAIRS = [f'{ROSTER[a]} {ROSTER[b]}' for a, b in ((0, 0), (0, 1), (1, 1), (2, 0), (2, 1), (2, 2), (3, 0), (3, 1), (3, 2), (3, 3),
                                                 (4, 0), (4, 1), (4, 2), (4, 4), (4, 3))]
PAIRS += [f'{ROSTER[i]} {ROSTER[j]}' for i in range(5, len(ROSTER)) for j in range(i + 1)]
COMPANION = re.compile(r'duel (?!(?:gate|evo|match|hash|learn|learning|probe|endless|practice|frame|bind|setting|page|manual|'
                       r'camera)\b)[a-z]+ ')   # a character's per-match pacing line after a gate row (band cups senju ichigo ...)


def gate_cmd(k):
    """debug.lisp's one-pairing seed gate: 2125+k for k 0-14, 2135+k for k 15-64 (2150-2199)."""
    assert 0 <= k <= 64, k
    return 2125 + k if k < 15 else 2135 + k


def lisp(cmds):
    """One native process: the debug commands CMDS, then frames until the gate (or the match) is over."""
    return run_lisp('simgate/run.lisp', cmds)


def run(job):
    k, s0, n, extra = job
    r = lisp([30000 + s0, 31100 + n] + extra + [gate_cmd(k)])
    if r.returncode:
        sys.exit(f'[simgate] pairing {k} seeds {s0 + 1}-{s0 + n} exited {r.returncode}\n' + (r.stdout + r.stderr)[-2000:])
    rows, ticks = [], None           # (seed, ticks, ko, row line, companion lines)
    for line in r.stdout.splitlines():
        m = re.match(r'duel -> RESULTS winner \S+ konpaku (\d+)-(\d+) ticks (\d+)', line)
        if m:
            ticks, ko = int(m[3]), m[1] == '0' or m[2] == '0'
        elif line.startswith('duel gate row '):
            rows.append([int(line.split()[4]), ticks, ko, line, []])
        elif rows and COMPANION.match(line):
            rows[-1][4].append(line)
    if len(rows) != n:
        sys.exit(f'[simgate] pairing {k} seeds {s0 + 1}-{s0 + n}: {len(rows)} rows\n' + r.stdout[-2000:])
    return k, rows


def cvc():
    """The native build against the browser's G2 reference: RESULTS + hash lines of seed 7 II / IK / KK (YY / YK before the core system)."""
    ref, bad = {}, 0
    for l in open(os.path.join(ROOT, 'tests/style-cvc-ref.txt')):
        if not l.startswith('#'): ref.setdefault(l[:2], []).append(l[3:].rstrip('\n'))
    for p, c in (('ii', 3007), ('ik', 4007), ('kk', 5007)):
        r = lisp([2102, c])
        got = [l for l in r.stdout.splitlines() if re.match(r'duel (-> RESULTS winner|hash)', l)]
        ok = got == ref[p]
        bad += not ok
        print(f"{'PASS' if ok else 'FAIL'} native cvc {p}: {len(got)} lines vs {len(ref[p])}; {got[-1] if got else 'no RESULTS'}")
    sys.exit(1 if bad else 0)


def summary(k, rows):
    sec = lambda r: re.search(r' secs (\S+) ', r[3])[1]      # the row's ~,1f: the match without its cinematics (2026-10-08)
    rows = sorted(rows, key=lambda r: (float(sec(r)), r[1]))
    wins = {w: sum(f' winner {w} ' in r[3] for r in rows) for w in ('P1', 'P2', 'DRAW')}
    blow = sum(int(re.search(r' blow (\d+)', r[3])[1]) for r in rows)   # (not the last field: " ko N" follows since 2026-11-14)
    return (f'duel gate {PAIRS[k]}: {len(rows)} matches, KOs {sum(r[2] for r in rows)}, median {sec(rows[len(rows) // 2])} s, '
            f'min {sec(rows[0])}, max {sec(rows[-1])} | ' + ' '.join(f'{math.floor(float(sec(r)) + 0.5)}.' for r in rows) +
            f' | with the cinematics median {sorted(r[1] for r in rows)[len(rows) // 2] / 60:.1f} s' +
            f'\nduel gate {PAIRS[k]} wins P1 {wins["P1"]} P2 {wins["P2"]} DRAW {wins["DRAW"]} blow {blow}')


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--pairs', default='all', help='comma-separated pairing indices (default all: 15 for 5 characters)')
    ap.add_argument('--seed0', type=int, default=0, help='seeds seed0+1 .. seed0+seeds (debug 30000+k)')
    ap.add_argument('--seeds', type=int, default=20)
    ap.add_argument('-j', type=int, default=min(16, os.cpu_count() or 1), help='processes (default 16)')
    ap.add_argument('--chunk', type=int, default=0,
                    help='seeds per process (default: all, back to back as the page plays them; see the docstring)')
    ap.add_argument('--cmd', type=int, action='append', default=[], help='debug command before the gate (repeatable)')
    ap.add_argument('--summary', action='store_true', help='print only the summary lines')
    ap.add_argument('--cvc', action='store_true', help="self-check against G2's browser reference")
    a = ap.parse_args()
    if a.cvc:
        build()
        cvc()
    pairs = ([k for k, p in enumerate(PAIRS) if not set(p.split()) & RETIRED] if a.pairs == 'all'   # (the retired out, 2026-10-12)
             else [int(p) for p in a.pairs.split(',')])
    a.chunk = a.chunk or a.seeds
    assert 0 <= a.seed0 <= 999 and 1 <= a.chunk <= 99 and all(0 <= k < len(PAIRS) for k in pairs)
    build()
    jobs = [(k, s, min(a.chunk, a.seed0 + a.seeds - s), a.cmd) for k in pairs for s in range(a.seed0, a.seed0 + a.seeds, a.chunk)]
    got = {k: [] for k in pairs}
    for k, rows in pool(run, jobs, a.j):
        got[k] += rows
    for k in pairs:
        if not a.summary:
            for r in sorted(got[k]):
                print('\n'.join([r[3]] + r[4]))
    for k in pairs:
        print(summary(k, got[k]))


if __name__ == '__main__':
    main()

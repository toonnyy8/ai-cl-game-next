#!/usr/bin/env python3
"""sp-costs-check.py — DUEL_SP S2's scripted scenes in the native sim (tools/simgate/trial.lisp, the combo trials' runner): each kit's NS
routes at flash-step 300 / 30 / 0 (at 0 whiffed, so no hit refills it), a full AS3 from 0, NS vs NS tie and J vs NS cancel (both refunds once), and a scaled hit's reaction and stun
equal to the full one's. Both sides' inputs are written (P1 the trial script, P2 :p2-at); the asserts read the combat log's `SP` lines
(core-sim.lisp CORE-START!: `SP <segment> fs F cost C paid P xS` / `SP <segment> refused`, CORE-NOHIT!: `SP refund P`) and `dealt` lines
(combat.lisp APPLY-HIT: `dealt D: <reaction> stun N`). The KOSEI flash-step of a hit (until S3) moves the gauge between segments, so every
check is made against the `fs` the segment started with, never a net change.

  python3 tests/sp-costs-check.py           PASS / FAIL per check, exit 1 on a failure
  python3 tests/sp-costs-check.py --log     and every trial's SP / dealt / CANCEL lines
"""
import os, re, sys, tempfile
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'tools'))
import simlib

# (character, form, :meter, [(pointer, segments, distance)], §4's NS route totals)
KITS = [
    ('kenpachi', 'base', 0, [(1, 3, 2.0), (2, 2, 2.0), (3, 3, 2.0)], [55, 55, 60]),
    ('kenpachi', 'nozarashi', 3, [(1, 5, 2.5), (2, 5, 1.4)], [100, 120]),
    ('kenpachi', 'bankai', 0, [(1, 4, 1.6)], [90]),
    ('kenpachi', 'bankai-2', 0, [(1, 4, 1.6)], [85]),
    ('ichigo', 'base', 0, [(1, 3, 2.0), (2, 3, 5.0), (3, 2, 3.0)], [85, 80, 70]),
    ('ichigo', 'kessa', 0, [(1, 3, 2.5), (2, 3, 5.0), (3, 3, 3.0)], [75, 80, 30]),
    ('hisagi', 'base', 0, [(1, 3, 2.5), (2, 3, 2.5), (3, 2, 2.5)], [75, 75, 25]),
    ('hisagi', 'bankai', 0, [(1, 3, 4.0), (2, 3, 4.0)], [40, 80]),
    ('hisagi', 'bankai-bind', 0, [(1, 3, 2.5), (2, 3, 2.5)], [65, 80]),
]
SP = '(:quick 1 :modded t)'


def trials():
    out = []
    for c, form, meter, routes, _ in KITS:
        for ptr, n, dist in routes:
            for fs in (300, 30, 0, 'h0'):                         # (at 0: out of reach, two presses; h0: at 0 in reach, the NSa hits)
                d, k = (12.0, 2) if fs == 0 else (dist, 2) if fs == 'h0' else (dist, n)
                out.append(f'(:name "NS {c} {form} {ptr} fs{fs}" :p1 :{c} :form :{form} :meter {meter} :p2 :ichigo :ptr {ptr} '
                           f':dist {d} :fs {0 if fs == "h0" else fs} :script ({" ".join([SP] * k)}) :frames {60 + 60 * k})')
    # a full AS3 at 0 (Ichigo: J1-J5, then the three segments)
    j = '(:quick 1) ' + ' '.join(['(:quick 1 :on :hit)'] * 4)
    for fs in (300, 0):
        out.append(f'(:name "AS3 ichigo base fs{fs}" :p1 :ichigo :dist 1.6 :fs {fs} :script ({j} (:quick 1 :modded t :on :hit) {SP} {SP}) :frames 300)')
    # NS vs NS (the same step: a same-class tie cancels), J vs NS (NA cancels NS); the mirror, both NS1a
    out.append(f'(:name "TIE ichigo NS1a vs NS1a" :p1 :ichigo :p2 :ichigo :ptr 1 :p2-ptr 1 :dist 2.0 :fs 300 :p2-at ((0 :sp)) :script ({SP}) :frames 90)')
    out.append('(:name "CANCEL ichigo J1 vs NS1a" :p1 :ichigo :p2 :ichigo :ptr 1 :p2-ptr 1 :dist 1.8 :fs 300 :p2-at ((0 :sp)) :script ((:quick 1 :wait 8)) :frames 90)')
    # Kenpachi's tame catches Ichigo's J1 and answers with the thrust (combat.lisp :parried): an NS segment, paid like any
    out.append('(:name "CATCH kenpachi tame thrust" :p1 :kenpachi :p2 :ichigo :ptr 3 :p2-ptr 1 :dist 1.2 :fs 300 :p2-at ((2 :j)) :script ((:quick 1 :modded t)) :frames 120)')
    return out


def run():
    simlib.build()
    with tempfile.NamedTemporaryFile('w', suffix='.lisp', delete=False) as f:
        f.write('\n'.join(trials()) + '\n')
        path = f.name
    try:
        r = simlib.run_lisp('simgate/trial.lisp', [path], timeout=1800)
    finally:
        os.unlink(path)
    if r.returncode:
        sys.exit((r.stdout + r.stderr)[-3000:] + f'\n[sp-costs] trial.lisp exited {r.returncode}')
    logs, cur = {}, None
    for line in r.stdout.splitlines():
        if 'trial begin ' in line:
            cur = line.split('trial begin ', 1)[1].strip(); logs[cur] = []
        elif 'trial end ' in line:
            cur = None
        elif cur and re.search(r'\] P[12] (SP |dealt |\S+ x P[12]: CANCEL)', line):
            logs[cur].append(re.sub(r'^.*?\[\s*(\d+)\] ', r'[\1] ', line))
    return logs


SPL = re.compile(r'P(\d) SP (\S+) fs ([\d.]+) cost ([\d.]+) paid ([\d.]+) x([\d.]+)')
REF = re.compile(r'P(\d) SP (\S+) refused')
BACK = re.compile(r'P(\d) SP refund ([\d.]+)')
DEALT = re.compile(r'P1 dealt (\d+): (\S+) stun (\d+)')


def main():
    show = '--log' in sys.argv
    logs = run()
    bad = 0

    def check(ok, what):
        nonlocal bad
        bad += not ok
        print(f"{'PASS' if ok else 'FAIL'} {what}")

    def sp(name, side='1'):
        return [(m[2], float(m[3]), float(m[4]), float(m[5]), float(m[6])) for l in logs[name] for m in [SPL.search(l)] if m and m[1] == side]

    for name, lines in logs.items():
        if show:
            print(f'== {name}'); print('\n'.join('   ' + l for l in lines))
    # every start obeys the rule against the gauge it started with: paid = min(cost, fs), scale = 0.5 + 0.5 paid / cost
    starts = [s for n in logs for s in sp(n)]
    check(all(abs(p - min(c, fs)) < 0.05 and abs(x - (0.5 + 0.5 * p / c)) < 0.006 for _, fs, c, p, x in starts),
          f'{len(starts)} SP starts: paid = min(cost, fs), scale = 0.5 + 0.5 x paid / cost')
    for c, form, meter, routes, totals in KITS:
        for (ptr, n, _), total in zip(routes, totals):
            k = f'{c} {form} {ptr}'
            full = sp(f'NS {k} fs300')
            check(len(full) == n and sum(s[2] for s in full) == total and all(s[3] == s[2] for s in full),
                  f'NS {k} at 300: {n} segments paid in full, total {sum(s[2] for s in full):g} (§4 {total}) '
                  f'[{" ".join(f"{s[0].lower()} {s[2]:g}" for s in full)}]')
            low = sp(f'NS {k} fs30'); ref30 = [l for l in logs[f'NS {k} fs30'] if REF.search(l)]
            # (a start at 0 after the refusal is a new route's NSa from neutral, at x0.5: NS1 can always be pressed, §3)
            lines30 = logs[f'NS {k} fs30']; iref = next((i for i, l in enumerate(lines30) if REF.search(l)), len(lines30))
            late0 = [l for l in lines30[:iref] if (m := SPL.search(l)) and m[1] == '1' and float(m[3]) == 0 and lines30.index(l) > 0]
            check(low and low[0][1] == 30 and not late0 and all(s[3] == 0 and abs(s[4] - 0.5) < 0.001 for s in low if s[1] == 0)
                  and (len(low) == n or ref30),
                  f'NS {k} at 30: ' + ', '.join(f'{s[0].lower()} fs {s[1]:g} paid {s[3]:g}/{s[2]:g} x{s[4]:.2f}' for s in low) +
                  (', next refused' if ref30 else ''))
            zero = sp(f'NS {k} fs0'); ref0 = [l for l in logs[f'NS {k} fs0'] if REF.search(l)]
            check(len(zero) == 1 and zero[0][3] == 0 and abs(zero[0][4] - 0.5) < 0.001 and len(ref0) == 1,
                  f'NS {k} at 0 (whiffed): NSa paid 0 x{zero[0][4]:.2f}' + (', NSb refused' if ref0 else ', NSb NOT refused'))
            hz = sp(f'NS {k} fsh0'); refh = [l for l in logs[f'NS {k} fsh0'] if REF.search(l)]
            hits = [l for l in logs[f'NS {k} fsh0'] if DEALT.search(l)]
            check(len(hz) == 1 and hz[0][3] == 0 and len(refh) == 1,          # (the user 2026-11-13: a hit at 0 must not open NSb;
                                                                                #  a wave / late hit may land after the second press)
                  f'NS {k} at 0 (NSa hits, {len(hits)} hit(s)): ' + (', NSb refused' if refh else ', NSb NOT refused'))
    a0 = sp('AS3 ichigo base fs0')
    # (the J string's KOSEI, until S3, refills a little before the AS: every segment starts, the ones at 0 at x0.5)
    check(len(a0) == 3 and a0[-1][1] == 0 and all(abs(s[4] - 0.5) < 0.001 for s in a0 if s[1] == 0),
          'AS3 from 0: every segment starts: ' + ', '.join(f'{s[0].lower()} fs {s[1]:g} paid {s[3]:g} x{s[4]:.2f}' for s in a0))
    # a scaled hit's reaction and stun equal the full hit's, its damage about half (AS3 at 0 vs at 300, hit by hit)
    def as_hits(name):                                             # the dealt lines after the AS's first segment started
        ls = logs[name]; i = next(i for i, l in enumerate(ls) if SPL.search(l))
        return [DEALT.search(l) for l in ls[i:] if DEALT.search(l)]
    pairs = list(zip(as_hits('AS3 ichigo base fs300'), as_hits('AS3 ichigo base fs0')))
    check(len(pairs) == 6 and all(a[2] == b[2] and a[3] == b[3] and int(b[1]) < int(a[1]) for a, b in pairs),
          'AS3 hits scaled vs full (dealt, reaction, stun): ' + ', '.join(f'{b[1]}/{a[1]} {b[2]} {b[3]}/{a[3]}' for a, b in pairs))
    for name in ('TIE ichigo NS1a vs NS1a', 'CANCEL ichigo J1 vs NS1a'):
        backs = [BACK.search(l) for l in logs[name] if BACK.search(l)]
        canc = [l for l in logs[name] if 'CANCEL' in l]
        paid = {s: sp(name, s) for s in '12'}
        want = {s for s in '12' if paid[s]}                        # the sides that were in an NS segment
        got = [b[1] for b in backs]
        check(canc and sorted(got) == sorted(want) and all(abs(float(b[2]) - paid[b[1]][-1][3]) < 0.05 for b in backs),
              f'{name}: {len(canc)} CANCEL verdict(s), refunds ' + ', '.join(f'P{b[1]} {b[2]}' for b in backs) +
              f' (paid: ' + ', '.join(f'P{s} {paid[s][-1][3]:g}' for s in '12' if paid[s]) + ')')
    ct = sp('CATCH kenpachi tame thrust')
    check([x[0] for x in ct] == ['KE-Z-N3A', 'KE-Z-N3B'] and ct[1][3] == ct[1][2] == 20,
          'the tame\'s catch starts the thrust through CORE-START!: ' + ', '.join(f'{x[0].lower()} paid {x[3]:g}/{x[2]:g}' for x in ct))
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()

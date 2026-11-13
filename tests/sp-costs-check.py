#!/usr/bin/env python3
"""sp-costs-check.py — DUEL_SP S2's and S3's scripted scenes in the native sim (tools/simgate/trial.lisp, the combo trials' runner): each kit's NS
routes at flash-step 300 / 30 / 0 (at 0 whiffed, so no hit refills it), a full AS3 from 0, NS vs NS tie and J vs NS cancel (both refunds once), and a scaled hit's reaction and stun
equal to the full one's. Both sides' inputs are written (P1 the trial script, P2 :p2-at); the asserts read the combat log's `SP` lines
(core-sim.lisp CORE-START!: `SP <segment> fs F cost C paid P xS` / `SP <segment> refused`, CORE-NOHIT!: `SP refund P`) and `dealt` lines
(combat.lisp APPLY-HIT: `dealt D: <reaction> stun N`). S3 (the ATK gains): `SP hit gain G (fs F)` (gauges.lisp SP-ATK-HIT!, a J / SA hit
window that dealt damage) and `SP cancel gain G (fs F)` (CORE-NOHIT!, a J / SA in a cancel, once per move); G is what the gauge really gained.
Since KOSEI's flash-step left, only a J / SA ever refills the gauge: an NS / AS hit pays nothing, so a route's starts follow each other
exactly (fs' = fs - paid) and a segment at 0 is refused.
S4 (the breakthrough, DUEL_SP §6): `BREAK fs T from P2 (fs V), gains G (fs F)` (core-sim.lisp CORE-BREAK!: T taken, V the victim after it, G what
the attacker's gauge really took), `STEAL fs ...` (an AS1's own steal, before it: Q10), `cancels the Kikon follow-up` (Q12) and `exchange over`
(CORE-XCH-STEP: both back in neutral, Q11).
S5 (projectiles, DUEL_SP §6): `P1 wave ns x P2: CANCEL` / `P1 ic-hit na x P2: CANCEL` (core-sim.lisp CORE-HAZARD-NOHIT!: a hazard judged as the
segment that fired it), `P2 beats P1's wave ns` (his class beats it: spent, no refund), `SP refund P (fs F), out of the move` (the owner no longer
in that segment: the refund only). P2's moves at the wave's range are started by trial.lisp's :p2-start (CORE-START!, a written debug drive).
S7 (the CPU, DUEL_SP §8.4): P2's CPU plays (trial.lisp :p2-cpu, :seed) from a written NSa (:p2-start) that hits at flash-step 0: it never
presses the segment the sim would refuse (no `P2 SP <NSb> refused`, a `P2 cpu holds <NSb>` line: core-ai CAI-NEXT-OK-P); the same seed
at 300 presses it (`P2 SP <NSb> fs ...`), so the roll did fire. The generic CPU (Ichigo vs Ichigo) and a matchup style (Kenpachi's KK-LINK).

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
    # S3, the ATK gains (P1 starts at 100 so the cap never hides one): J1-J3 on a standing dummy, an SA, a J tie, J vs NS, bursts, Hisagi's Bankai
    out.append(f'(:name "GAIN ichigo J1-J3" :p1 :ichigo :dist 1.6 :fs 100 :script ((:quick 1) (:quick 1 :on :hit) (:quick 1 :on :hit)) :frames 120)')
    out.append('(:name "GAIN ichigo SA" :p1 :ichigo :dist 2.0 :fs 100 :script ((:quick 1 :modded t) (:quick 1 :on :hit)) :frames 120)')
    out.append('(:name "GAIN ichigo J tie" :p1 :ichigo :p2 :ichigo :dist 1.4 :fs 100 :p2-fs 100 :p2-at ((0 :j)) :script ((:quick 1)) :frames 90)')
    out.append('(:name "GAIN ichigo J vs NS1a" :p1 :ichigo :p2 :ichigo :ptr 1 :p2-ptr 1 :dist 1.8 :fs 100 :p2-fs 100 :p2-at ((0 :sp)) :script ((:quick 1 :wait 8)) :frames 90)')
    for b in ('orange', 'white', 'blue'):
        out.append(f'(:name "GAIN ichigo J1-J3 in {b.upper()}" :p1 :ichigo :dist 1.6 :fs 200 :burst :{b} :script ((:quick 1) (:quick 1 :on :hit) (:quick 1 :on :hit)) :frames 120)')
    out.append('(:name "GAIN hisagi bankai J1 at the tip" :p1 :hisagi :form :bankai :p2 :ichigo :dist 5.75 :fs 100 :script ((:quick 1)) :frames 120)')
    out.append('(:name "GAIN hisagi bankai J1 off the tip" :p1 :hisagi :form :bankai :p2 :ichigo :dist 4.0 :fs 100 :script ((:quick 1)) :frames 120)')
    out.append('(:name "GAIN hisagi shikai J1" :p1 :hisagi :p2 :ichigo :dist 2.0 :fs 100 :script ((:quick 1)) :frames 120)')
    # S4, the breakthrough: J vs NS1a cancels, then the J side's AS beats the NS (Kenpachi: no steal; Ichigo: RAKUGA steals first, Q10); NS1a
    # cancelled by a J, then its SA beats the J2; two cancels then one AS hit; the victim at 100 / 80; both back in neutral before the hit;
    # the Kikon follow-up cancelled (Q12) and Hisagi's Bankai J1 from 5 m in the bounce's exchange
    jns = ':p2 :ichigo :ptr 1 :p2-ptr 1 :dist 1.8 :fs 100 :p2-at ((0 :sp)) :script ((:quick 1 :wait 8) (:quick 1 :modded t :on :hit)) :frames 150'
    out.append(f'(:name "BREAK kenpachi cancel then AS1" :p1 :kenpachi :p2-fs 300 {jns})')
    out.append(f'(:name "BREAK ichigo cancel then AS1 steal" :p1 :ichigo :p2-fs 300 {jns})')
    out.append(f'(:name "BREAK kenpachi victim at 100" :p1 :kenpachi :p2-fs 100 {jns})')
    out.append(f'(:name "BREAK kenpachi victim at 80" :p1 :kenpachi :p2-fs 80 {jns})')
    out.append('(:name "BREAK ichigo SA beats J" :p1 :ichigo :p2 :ichigo :ptr 1 :p2-ptr 1 :dist 1.8 :fs 200 :p2-fs 300 :p2-at ((6 :j) (20 :j) (24 :j) (28 :j)) '
               ':script ((:quick 1 :modded t) (:quick 1 :on :hit)) :frames 150)')
    out.append('(:name "BREAK ichigo two cancels then AS1" :p1 :ichigo :p2 :ichigo :ptr 1 :p2-ptr 1 :dist 1.8 :fs 100 :p2-fs 300 :p2-at ((0 :sp) (20 :sp) (24 :sp) (28 :sp)) '
               ':script ((:quick 1 :wait 8) (:quick 1 :on :hit) (:quick 1 :modded t :on :hit)) :frames 200)')
    out.append('(:name "BREAK ichigo neutral then J1" :p1 :ichigo :p2 :ichigo :ptr 1 :p2-ptr 1 :dist 1.8 :fs 100 :p2-fs 300 :p2-at ((0 :sp)) '
               ':script ((:quick 1 :wait 8) (:quick 1 :on :free :wait 30)) :frames 200)')
    # S5: Ichigo's JUJISHO (NS2c, cost 60) at 6 m meets P2's J / NS / AS / SA started 3-5 frames before it arrives (f73 on a standing P2);
    # at 10 m it arrives after NS2c is over (the refund only); fired at fs 50 (paid 30 of 60: x0.75); NOZARASHI's blade cuts it (CUT-HAZARDS);
    # KESSA's two NS3 clones (74904) replay his J1 into P2's NS1a window
    ns2 = ':p1 :ichigo :ptr 2 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 160'
    out.append(f'(:name "WAVE stand" :p2 :kenpachi :dist 6.0 :fs 300 {ns2})')
    for nm, at, mv in (('J', 70, 'ke-z-j1'), ('NS', 68, 'ke-z-n1a'), ('AS', 68, 'ke-z-as1'), ('SA', 70, 'ke-z-sa1')):
        out.append(f'(:name "WAVE vs {nm}" :p2 :kenpachi :dist 6.0 :fs 300 :p2-fs 100 :p2-start (({at} :{mv})) {ns2})')
    out.append(f'(:name "WAVE idle owner" :p2 :kenpachi :dist 10.0 :fs 300 :p2-fs 100 :p2-start ((88 :ke-z-j1)) {ns2})')
    out.append(f'(:name "WAVE scaled" :p2 :kenpachi :dist 6.0 :fs 50 {ns2})')
    out.append(f'(:name "WAVE cut" :p2 :kenpachi :p2-form :nozarashi :dist 6.0 :fs 300 :p2-fs 100 :p2-start ((58 :ke-s-j1)) {ns2})')
    out.append(f'(:name "WAVE passes" :p2 :kenpachi :p2-form :nozarashi :dist 6.0 :fs 300 :p2-fs 300 :p2-start ((40 :ke-s-n1a)) {ns2})')
    out.append('(:name "WAVE clone replay" :p1 :ichigo :form :kessa :p2 :kenpachi :dist 2.0 :fs 300 :p1-cmd (74904) :p2-start ((0 :ke-z-n1a)) '
               ':script ((:quick 1)) :frames 100)')
    out.append('(:name "BREAK kikon cancel then hisagi J1" :p1 :ichigo :p2 :hisagi :p2-form :bankai :ptr 1 :dist 2.0 :fs 300 :p2-fs 100 :p2-at ((24 :j) (28 :j)) '
               ':script ((:quick 60 :modded t)) :frames 220)')
    # S7: the CPU at 0 in an NS route (P2's CPU from a written NSa that hits), the same seed at 300 as the control
    for fs in (0, 300):
        out.append(f'(:name "CPU ichigo fs{fs}" :p1 :ichigo :p2 :ichigo :p2-ptr 1 :dist 2.0 :fs 300 :p2-fs {fs} :p2-cpu :hard :seed 4242 '
                   ':p2-start ((0 :ic-n1a)) :frames 90)')
        out.append(f'(:name "CPU kenpachi style fs{fs}" :p1 :ichigo :p2 :kenpachi :p2-ptr 1 :dist 1.6 :fs 300 :p2-fs {fs} :p2-cpu :hard :seed 4242 '
                   ':p2-start ((0 :ke-z-n1a)) :frames 90)')
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
        elif cur and re.search(r'\] (P[12] (SP |dealt |BREAK |STEAL |cancels |beats |blade x |[^:\]]* x P[12]: CANCEL)|exchange over|clone \S+ replays|P2 cpu holds |P2 kk link )', line):
            logs[cur].append(re.sub(r'^.*?\[\s*(\d+)\] ', r'[\1] ', line))
    return logs


SPL = re.compile(r'P(\d) SP (\S+) fs ([\d.]+) cost ([\d.]+) paid ([\d.]+) x([\d.]+)')
REF = re.compile(r'P(\d) SP (\S+) refused')
BACK = re.compile(r'P(\d) SP refund ([\d.]+)')
GAIN = re.compile(r'P(\d) SP (hit|cancel) gain ([\d.]+) \(fs ([\d.]+)\)')
DEALT = re.compile(r'P1 dealt (\d+): (\S+) stun (\d+)')
BRK = re.compile(r'P(\d) BREAK fs ([\d.]+) from P(\d) \(fs ([\d.]+)\), gains ([\d.]+) \(fs ([\d.]+)\)')


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
            # (no income between segments, so each start is the last one's fs - paid; a gauge at 0 refuses the next one)
            check(low and low[0][1] == 30 and not late0 and all(s[3] == 0 and abs(s[4] - 0.5) < 0.001 for s in low if s[1] == 0)
                  and all(abs(low[i + 1][1] - (low[i][1] - low[i][3])) < 0.5 for i in range(len(low) - 1))
                  and (len(low) == n or ref30) and (len(low) == n or abs(low[-1][1] - low[-1][3]) < 0.5),
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
    # (the five J hits' +10 each, and the natural regen trickle of the first second, lift the gauge to 50-60 before the AS: AS3a and b pay in
    #  full, AS3c the little that is left; an AS is never refused)
    jg = [float(m[3]) for l in logs['AS3 ichigo base fs0'] for m in [GAIN.search(l)] if m and m[1] == '1']
    check(len(a0) == 3 and jg == [10.0] * 5 and 50.0 <= a0[0][1] < 60.0 and a0[0][3] == a0[0][2] and a0[1][3] == a0[1][2] and 0 < a0[2][3] < a0[2][2] and all(abs(a0[i + 1][1] - (a0[i][1] - a0[i][3])) < 0.5 for i in range(2)),
          f'AS3 from 0: five J hits +10 each, so AS3a starts at fs {a0[0][1]:g} (50 + the regen trickle), and the segments follow exactly: ' +
          ', '.join(f'{s[0].lower()} fs {s[1]:g} paid {s[3]:g}/{s[2]:g} x{s[4]:.2f}' for s in a0))
    # a scaled hit's reaction and stun equal the full hit's, its damage less (AS3 from 0 vs at 300, hit by hit: AS3a / b paid in full, AS3c short)
    def as_hits(name):                                             # the dealt lines after the AS's first segment started
        ls = logs[name]; i = next(i for i, l in enumerate(ls) if SPL.search(l))
        return [DEALT.search(l) for l in ls[i:] if DEALT.search(l)]
    pairs = list(zip(as_hits('AS3 ichigo base fs300'), as_hits('AS3 ichigo base fs0')))
    check(len(pairs) == 6 and all(a[2] == b[2] and a[3] == b[3] and int(b[1]) <= int(a[1]) for a, b in pairs) and int(pairs[-1][1][1]) < int(pairs[-1][0][1])
          and all(int(b[1]) == int(a[1]) for a, b in pairs[:-1]),
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
    def gains(name, side='1'):
        return [(m[2], float(m[3]), float(m[4])) for l in logs[name] for m in [GAIN.search(l)] if m and m[1] == side]

    def fmt(g):
        return ', '.join(f'{k} +{v:g} (fs {f:g})' for k, v, f in g) or 'none'
    g = gains('GAIN ichigo J1-J3')
    check([x[1] for x in g] == [10.0] * 3 and [x[2] for x in g] == [110.0, 120.0, 130.0], f'J1-J3 on a dummy: {fmt(g)}')
    g = gains('GAIN ichigo SA')
    check(len(g) == 1 and g[0][:2] == ('hit', 15.0), f'NS1a then its SA hit (the NS hit pays nothing): {fmt(g)}')
    g1, g2 = gains('GAIN ichigo J tie', '1'), gains('GAIN ichigo J tie', '2')
    check(g1 == [('cancel', 30.0, 130.0)] and g2 == [('cancel', 30.0, 130.0)] and not any(BACK.search(l) for l in logs['GAIN ichigo J tie']),
          f'J vs J tie: P1 {fmt(g1)}, P2 {fmt(g2)} (once each however many verdicts)')
    n = 'GAIN ichigo J vs NS1a'; g1, g2 = gains(n, '1'), gains(n, '2'); bk = [b for b in map(BACK.search, logs[n]) if b]
    check(g1 == [('cancel', 30.0, 130.0)] and not g2 and len(bk) == 1 and bk[0][1] == '2' and float(bk[0][2]) == 25.0,
          f'J vs NS1a: P1 {fmt(g1)}, P2 gains {fmt(g2)} and is refunded {[b[2] for b in bk]}')
    for b in ('ORANGE', 'WHITE', 'BLUE'):
        n = f'GAIN ichigo J1-J3 in {b}'; g = gains(n)
        check(len(g) == 3 and all(x[1] == 0.0 for x in g) and g[0][2] > g[1][2] > g[2][2], f'J1-J3 in {b}: {fmt(g)} (the burst drains, nothing is earned)')
    g = gains('GAIN hisagi bankai J1 at the tip'); h = gains('GAIN hisagi bankai J1 off the tip'); k = gains('GAIN hisagi shikai J1')
    check(len(g) == 1 and abs(g[0][1] - 16.9) < 0.05 and len(h) == 1 and abs(h[0][1] - 13.0) < 0.05 and len(k) == 1 and k[0][1] == 10.0,
          f'Hisagi J1: Bankai at the tip {fmt(g)} (x1.3 tip x1.3 spread route), off the tip {fmt(h)} (spread route), Shikai {fmt(k)}')
    # S4: the breakthrough
    def brk(name):
        return [(m[1], float(m[2]), m[3], float(m[4]), float(m[5]), float(m[6]), i) for i, l in enumerate(logs[name]) for m in [BRK.search(l)] if m]

    def rule(b):                                                   # take = all of the victim's flash-step above 100 (before it), gain = half
                                                                   # (the user 2026-11-13: 「這邊是要奪取第一格以上的全部，並以 50% 效率轉換成自身量表」)
        att, take, vic, after, gain, fs, _ = b                     # (x his SUBLIMATION / DRIVE bonus: Hisagi's Bankai is an awakened form)
        return (abs(take - max(0.0, after + take - 100.0)) < 0.06
                and (0.5 * take - 0.06 <= gain <= 0.5 * take * 1.05 + 0.06 or fs >= 299.95))

    def bfmt(bs):
        return '; '.join(f'P{a} takes {t:g} from P{v} (left {af:g}), gains {g:g} (fs {f:g})' for a, t, v, af, g, f, _ in bs) or 'no BREAK'

    def tick(name, i):
        return logs[name][i].split(']')[0] + ']'
    n = 'BREAK kenpachi cancel then AS1'; b = brk(n)
    check(len(b) == 1 and b[0][0] == '1' and b[0][2] == '2' and rule(b[0]) and b[0][1] > 99 and any('CANCEL' in l for l in logs[n][:b[0][6]]),
          f'cancel then AS (the AS side breaks through): {bfmt(b)}')
    n = 'BREAK ichigo cancel then AS1 steal'; b = brk(n); st = [i for i, l in enumerate(logs[n]) if 'STEAL' in l]
    check(len(b) == 1 and rule(b[0]) and st == [b[0][6] - 1] and abs(b[0][1] - 160.0) < 0.05,
          f'AS1 steal on the same hit (Q10): {logs[n][st[0]].split("] ", 1)[1] if st else "no STEAL"}, then {bfmt(b)} (on 300 - 40 = 260)')
    n = 'BREAK kenpachi victim at 100'; b = brk(n)
    check(len(b) == 1 and rule(b[0]) and b[0][1] < 10 and abs(b[0][3] - 100.0) < 0.06,
          f"victim at 100: {bfmt(b)} (only the hit's own damage-taken gain is above the last cell)")
    n = 'BREAK kenpachi victim at 80'; b = brk(n)
    check(len(b) == 1 and b[0][1] == 0.0 and b[0][4] == 0.0 and b[0][3] < 100, f'victim at 80: {bfmt(b)} (nothing above the last cell)')
    n = 'BREAK ichigo SA beats J'; b = brk(n)
    check(len(b) == 1 and b[0][0] == '1' and rule(b[0]) and b[0][1] > 99 and any('SP hit gain 15.0' in l for l in logs[n][:b[0][6]]),
          f'NS1a cancelled by J1, then its SA beats J2: {bfmt(b)}')
    n = 'BREAK ichigo two cancels then AS1'; b = brk(n); ct = sorted({tick(n, i) for i, l in enumerate(logs[n]) if 'CANCEL' in l})
    check(len(b) == 1 and rule(b[0]) and len(ct) >= 2, f'two cancels (at {" ".join(ct)}) then the AS: one take, {bfmt(b)}')
    n = 'BREAK ichigo neutral then J1'; ov = [i for i, l in enumerate(logs[n]) if 'exchange over' in l]; hit = [i for i, l in enumerate(logs[n]) if 'SP hit gain' in l]
    check(not brk(n) and ov and hit and ov[0] < hit[0], f'both back in neutral (exchange over at {tick(n, ov[0]) if ov else "?"}), then a J1 hit at {tick(n, hit[0]) if hit else "?"}: no BREAK')
    n = 'BREAK kikon cancel then hisagi J1'; b = brk(n); kc = [i for i, l in enumerate(logs[n]) if 'cancels the Kikon' in l]
    g30 = [l for l in logs[n] if 'P2 SP cancel gain 30.0' in l]; ov = [i for i, l in enumerate(logs[n]) if 'exchange over' in l]
    check(len(b) == 1 and kc and g30 and b[0][0] == '2' and b[0][2] == '1' and rule(b[0]) and kc[0] < b[0][6] and not any(kc[0] < i < b[0][6] for i in ov),
          f"the Kikon follow-up cancelled (Q12) at {tick(n, kc[0]) if kc else '?'}: P2 +30 ({len(g30)}), the exchange lives through the bounce, Hisagi's J1 from 5 m: {bfmt(b)}")
    # S5: projectiles in the triangle
    def has(n, pat): return [l for l in logs[n] if re.search(pat, l)]
    def dealt(n): return [int(m[1]) for l in logs[n] for m in [re.search(r'P1 dealt (\d+)', l)] if m]
    full = dealt('WAVE stand')
    check(len(full) == 1 and not has('WAVE stand', 'CANCEL'), f'JUJISHO on a standing P2: dealt {full}')
    for nm in ('J', 'SA'):
        n = f'WAVE vs {nm}'; bk = has(n, r'P1 SP refund 60\.0 \(fs 280\.0\)$'); g = gains(n, '2')
        check(has(n, r'P1 wave ns x P2: CANCEL') and bk and g == [('cancel', 30.0, 130.0)] and not dealt(n) and has(n, 'exchange over'),
              f'JUJISHO vs {nm} at the hit frame: CANCEL, P1 refunded 60 in his NS2c (landed), P2 {fmt(g)}, no damage, an exchange')
    n = 'WAVE vs NS'
    check(dealt(n) == full and not has(n, 'CANCEL|refund'), f'JUJISHO vs NS1a: the wave hits (dealt {dealt(n)}, NS vs NS: the first hit wins), no refund')
    n = 'WAVE vs AS'
    check(has(n, r"P2 beats P1's wave ns") and not dealt(n) and not has(n, 'CANCEL|P1 SP refund|exchange over'),
          'JUJISHO vs AS1: the AS beats it (spent, no refund, no exchange)')
    n = 'WAVE idle owner'
    check(has(n, r'P1 SP refund 60\.0 \(fs 280\.0\), out of the move') and has(n, 'P1 wave ns x P2: CANCEL') and gains(n, '2') == [('cancel', 30.0, 130.0)],
          'JUJISHO from 10 m cancelled by J1 after NS2c ended: the refund only (out of the move), P2 +30')
    n = 'WAVE scaled'; sc = sp(n)
    check(sc and sc[-1][0] == 'IC-N2C' and abs(sc[-1][4] - 0.75) < 0.001 and dealt(n) and abs(dealt(n)[0] - 0.75 * full[0]) <= 1,
          f'JUJISHO fired at fs 30 (paid {sc[-1][3]:g}/{sc[-1][2]:g} x{sc[-1][4]:.2f}): dealt {dealt(n)} = x0.75 of {full} (frozen when fired, Q8)')
    n = 'WAVE cut'; bl = has(n, r"P2 blade x P1's wave ns: cancel")
    check(bl and has(n, 'P1 wave ns x P2: CANCEL') and has(n, r'P1 SP refund 60\.0') and not dealt(n),
          f"NOZARASHI's J1 blade meets JUJISHO in front of him (CUT-HAZARDS, J vs NS): {bl[0] if bl else 'no blade line'}, CANCEL, refunded")
    n = 'WAVE passes'; bl = has(n, r"P2 blade x P1's wave ns: passes")
    check(bl and dealt(n) == full and not has(n, 'CANCEL|refund'),
          f"NOZARASHI's NS1a blade meets JUJISHO (NS vs NS, the wave first): {len(bl)} x passes, then it hits, dealt {dealt(n)}")
    n = 'WAVE clone replay'; rc = has(n, r'P1 ic-hit na x P2: CANCEL'); bk = has(n, 'SP refund')
    check(has(n, 'clone NS-A replays IC-K-J1') and has(n, r'P1 IC-K-J1 x P2: CANCEL') and rc and len(bk) == 1 and bk[0].count('P2 SP refund 20.0'),
          f"KESSA's clone replays J1 into P2's NS1a: {rc[0].split('] ', 1)[1] if rc else 'no replay CANCEL'} (class na, nothing paid: no second refund)")
    ct = sp('CATCH kenpachi tame thrust')
    check([x[0] for x in ct] == ['KE-Z-N3A', 'KE-Z-N3B'] and ct[1][3] == ct[1][2] == 20,
          'the tame\'s catch starts the thrust through CORE-START!: ' + ', '.join(f'{x[0].lower()} paid {x[3]:g}/{x[2]:g}' for x in ct))
    # S7: the CPU never presses the refused segment; the control at 300 shows the same roll pressing it
    for who, nb in (('ichigo', 'IC-N1B'), ('kenpachi style', 'KE-Z-N1B')):
        z, f = f'CPU {who} fs0', f'CPU {who} fs300'
        ref = has(z, rf'P2 SP {nb} refused'); hold = has(z, rf'P2 cpu holds {nb} \(fs 0\.0\)'); ctl = [x for x in sp(f, '2') if x[0] == nb]
        check(not ref and hold and ctl and has(z, r'P2 dealt|P2 \S+ -> P1 HIT'),
              f'the CPU ({who}) at 0 after its NSa hit: {len(ref)} refused, {hold[0].split("] ", 1)[1] if hold else "no hold line"}; '
              f'at 300 the same seed presses {nb} ({len(ctl)} start(s))')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()

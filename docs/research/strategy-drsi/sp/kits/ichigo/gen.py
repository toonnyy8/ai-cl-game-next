#!/usr/bin/env python3
"""gen.py — writes trials.lisp, Ichigo's catalogue trials (PLAN4's kit study, step 2), and nothing else:
  python3 docs/research/strategy-drsi/sp/kits/ichigo/gen.py > docs/research/strategy-drsi/sp/kits/ichigo/trials.lisp
  python3 tools/combo-trial.py docs/research/strategy-drsi/sp/kits/ichigo/trials.lisp --events > out.md
Every trial names its pointers and gauges (one match carries every trial: an unnamed pointer is the last trial's).
P2 presses on SIM frames (:p2-at, hitstop not counted) except a walk / run / Step (:p2-press, trial frames: before any contact they agree).
Opponents: K Kenpachi sealed (:base), Ks his Shikai (:nozarashi), H Hisagi Shikai (:base), Hb his Bankai (ranged, :bankai), Hk Bankai bind.
"""
OPP = {'K': (':kenpachi', ':base'), 'Ks': (':kenpachi', ':nozarashi'), 'H': (':hisagi', ':base'),
       'Hb': (':hisagi', ':bankai'), 'Hk': (':hisagi', ':bankai-bind')}
J, JH = '(:quick 1)', '(:quick 1 :on :hit)'
SP, SPH = '(:quick 1 :modded t)', '(:quick 1 :modded t :on :hit)'
def jw(n): return f'(:quick 1 :wait {n})'
def spw(n): return f'(:quick 1 :modded t :wait {n})'
def jf(n=0): return f'(:quick 1 :on :free :wait {n})'
def spf(n=0): return f'(:quick 1 :modded t :on :free :wait {n})'
def hold(n=80, on=False): return f'(:quick {n} :modded t{" :on :hit" if on else ""})'
out = []
def T(name, opp, script, dist, ptr=1, form=':base', frames=150, fs=300, p2fs=300, p2ptr=1, extra=''):
    ch, pf = OPP[opp]
    out.append(f'(:name "{name} /{opp}" :p1 :ichigo :form {form} :p2 {ch} :p2-form {pf} :dist {dist} :ptr {ptr} :p2-ptr {p2ptr} '
               f':fs {fs} :p2-fs {p2fs} :script ({" ".join(script)}) :frames {frames}{" " + extra if extra else ""})')
def sec(s): out.append(f'\n;; {s}')

KH = ('K', 'H')
JS = [J] + [JH] * 4
# ---------------------------------------------------------------- A. the J string and the AS by press, 1.6 m
sec('A. the J string and the AS by press count (:as-by-press (1 1 2 2 3)), 1.6 m')
for o in KH:
    T('A1 J1', o, [J], 1.6, frames=70)
    T('A5 J1-J5', o, JS, 1.6, frames=130)
    T('A6 J1 AS1', o, [J, SPH], 1.6, frames=130)
    T('A7 J1 J2 AS1', o, [J, JH, SPH], 1.6, frames=140)
    T('A9 J1-J3 AS2ab', o, [J, JH, JH, SPH, SP], 1.6, frames=270)
    T('A10 J1-J4 AS2ab', o, [J, JH, JH, JH, SPH, SP], 1.6, frames=280)
    T('A12 J1-J5 AS3abc', o, JS + [SPH, SP, SP], 1.6, frames=330)
    T('A13 J1 at 2.0 m', o, [J], 2.0, frames=60)
    T('A14 J1 at 2.3 m', o, [J], 2.3, frames=60)
    T('A15 J1 at 2.6 m', o, [J], 2.6, frames=60)
# ---------------------------------------------------------------- B. NS1
sec('B. NS1 (pointer 1, the cleaver): a b c, the SA in its gaps (34), the AS after it')
for o in KH:
    T('B1 NS1a', o, [SP], 2.4, frames=90)
    T('B2 NS1a-c', o, [SP, SP, SP], 2.4, frames=200)
    T('B3 NS1a-c at 3.0 m', o, [SP, SP, SP], 3.0, frames=200)
    T('B4 NS1a SA', o, [SP, JH], 2.4, frames=110)
    T('B5 NS1a SA AS1', o, [SP, JH, SPH], 2.4, frames=160)
    T('B7 NS1a SA J2 J3 AS2ab', o, [SP, JH, JH, JH, SPH, SP], 2.4, frames=300)
    T('B8 NS1a SA J2-J5 AS3abc', o, [SP, JH, JH, JH, JH, JH, SPH, SP, SP], 2.4, frames=320)
    T('B9 NS1ab SA J2 J3 AS2ab', o, [SP, SP, JH, JH, JH, SPH, SP], 2.4, frames=330)
    T('B10 NS1a-c SA J2-J5 AS3abc', o, [SP, SP, SP, JH, JH, JH, JH, JH, SPH, SP, SP], 2.4, frames=420)
# ---------------------------------------------------------------- C. NS2
sec('C. NS2 (pointer 2, the Getsuga): two charges > JUJISHO (a wave in the triangle as an NS); the charged SAs')
for o in KH:
    for d in (2.4, 6.6, 10.0):
        T(f'C1 NS2abc at {d} m', o, [SP, SP, SP], d, ptr=2, frames=180)
    T('C6 NS2a SA-g1 J2 J3 AS2ab (x1.4)', o, [SP, jw(20), JH, JH, SPH, SP], 2.0, ptr=2, frames=240)
    T('C7 NS2ab SA-g2 J2 J3 AS2ab (x1.7)', o, [SP, SP, jw(16), JH, JH, SPH, SP], 2.0, ptr=2, frames=270)
    T('C8 NS2ab SA-g2 J2-J5 AS3abc (x1.7)', o, [SP, SP, jw(16), JH, JH, JH, JH, SPH, SP, SP], 2.0, ptr=2, frames=330)
    T('C10 NS2a SA-g1 at 3.5 m (the lunge)', o, [SP, jw(20)], 3.5, ptr=2, frames=110)
    T('C11 NS2a SA-g1 at 4.0 m', o, [SP, jw(20)], 4.0, ptr=2, frames=110)
# ---------------------------------------------------------------- D. NS3
sec('D. NS3 (pointer 3, the rush): RANGETSU lunge (4 cuts) > TSUKI-OTOSHI; the SA after it')
for o in KH:
    T('D1 NS3a at 3.0 m', o, [SP], 3.0, ptr=3, frames=90)
    T('D2 NS3ab at 3.0 m', o, [SP, SP], 3.0, ptr=3, frames=150)
    T('D5 NS3a SA J2-J5 AS3abc at 3.0 m', o, [SP, JH, JH, JH, JH, JH, SPH, SP, SP], 3.0, ptr=3, frames=320)
    T('D6 NS3a SA J2 J3 AS2ab at 4.6 m', o, [SP, JH, JH, JH, SPH, SP], 4.6, ptr=3, frames=320)
# ---------------------------------------------------------------- R. reach bands (him standing; centre to centre)
sec('R. reach: the openers against him standing, by distance (Kenpachi hurt r 0.45, Hisagi 0.36)')
for o in KH:
    for d in (3.0, 3.2, 3.4):
        T(f'R NS1a at {d} m', o, [SP], d, frames=70)
    for d in (4.8, 5.2, 5.6):
        T(f'R NS3a at {d} m', o, [SP], d, ptr=3, frames=70)
    for d in (3.8, 4.2):
        T(f'R NS2a SA-g1 at {d} m', o, [SP, jw(20)], d, ptr=2, frames=100)
    for d in (3.2, 3.6, 4.0):
        T(f'R KESSA NS1a at {d} m', o, [SP], d, form=':kessa', frames=70)
    for d in (2.0, 2.3, 2.6):
        T(f'R KESSA J1 at {d} m', o, [J], d, form=':kessa', frames=60)
# ---------------------------------------------------------------- G. the gauge: the headline routes at 300 / 100 / 0 SP
sec('G. the gauge: the headline routes started at 300 / 100 / 0 SP (a short segment deals x(0.5 + 0.5 paid / cost); a later NS segment refused at 0)')
for o in KH:
    for fs in (100, 0):
        T(f'G A12 J1-J5 AS3abc at fs {fs}', o, JS + [SPH, SP, SP], 1.6, fs=fs, frames=330)
        T(f'G B8 NS1a SA J2-J5 AS3abc at fs {fs}', o, [SP, JH, JH, JH, JH, JH, SPH, SP, SP], 2.4, fs=fs, frames=320)
        T(f'G B2 NS1a-c at fs {fs}', o, [SP, SP, SP], 2.4, fs=fs, frames=200)
        T(f'G C8 NS2ab SA-g2 J2-J5 AS3abc at fs {fs}', o, [SP, SP, jw(16), JH, JH, JH, JH, SPH, SP, SP], 2.0, ptr=2, fs=fs, frames=330)
        T(f'G C1 NS2abc at 6.6 m at fs {fs}', o, [SP, SP, SP], 6.6, ptr=2, fs=fs, frames=180)
        T(f'G A9 J1-J3 AS2ab at fs {fs}', o, [J, JH, JH, SPH, SP], 1.6, fs=fs, frames=270)
    T('G A6 J1 AS1 vs his 300 (the steal)', o, [J, SPH], 1.6, fs=100, p2fs=300, frames=130)
    T('G A6 J1 AS1 vs his 100 (the steal takes the last cell)', o, [J, SPH], 1.6, fs=100, p2fs=100, frames=130)
# ---------------------------------------------------------------- E. the Kikon
sec('E. the Kikon (SP held 80) off each pointer; red; his attack in the follow-up')
for o in KH:
    T('E1 NS1a held (ptr 1)', o, [hold()], 2.4, frames=230)
    T('E4 J1 AS1 held (ptr 1 before)', o, [J, hold(on=True)], 1.6, frames=250)
    T('E5 J1-J3 AS2a held (ptr 2 before the AS)', o, [J, JH, JH, hold(on=True)], 1.6, ptr=2, frames=270)
    T('E6 J1-J3 AS2a AS2b held (the wave strike, ptr 2 before)', o, [J, JH, JH, SPH, hold(90)], 1.6, ptr=2, frames=320)
    T('E7 NS2abc held at 6.6 m (JUJISHO Kikon)', o, [SP, SP, hold(110)], 6.6, ptr=2, frames=330)
    T('E9 NS3a held (ptr 3)', o, [hold()], 3.0, ptr=3, frames=230)
    T('E11 J1-J5 AS3abc, AS3c held (ptr 3)', o, JS + [SPH, SP, hold()], 1.6, ptr=3, frames=340)
    T('E12 NS1a held, he presses J in the follow-up', o, [hold()], 2.4, frames=230, extra=':p2-at ((40 :j) (44 :j) (48 :j))')
    T('E13 NS1a held, he is red and presses J', o, [hold()], 2.4, frames=230, extra=':p2-reishi 300 :p2-at ((40 :j) (44 :j) (48 :j))')
    T('E14 J1-J3 AS2a held, he is red (ptr 2: red = Soul Break)', o, [J, JH, JH, hold(on=True)], 1.6, ptr=2, frames=270, extra=':p2-reishi 300')
# ---------------------------------------------------------------- S. Soul Break by pointer
sec('S. the Soul Break (his Reishi to 0) by the pointer in play')
for o in KH:
    T('S1 J1-J5 AS3abc, his Reishi 150', o, JS + [SPH, SP, SP], 1.6, ptr=3, frames=330, extra=':p2-reishi 150')
    T('S2 J1-J4 AS2ab, his Reishi 110', o, [J, JH, JH, JH, SPH, SP], 1.6, ptr=2, frames=280, extra=':p2-reishi 110')
    T('S3 J1-J3 at ptr 1, his Reishi 40', o, [J, JH, JH], 1.6, ptr=1, frames=200, extra=':p2-reishi 40')
    T('S4 J1-J3 at ptr 3, his Reishi 40', o, [J, JH, JH], 1.6, ptr=3, frames=200, extra=':p2-reishi 40')
# ---------------------------------------------------------------- F. Hoho in a combo, Step
sec('F. Hoho off a hit goes on; Step; Step > J')
for o in KH:
    T('F1 J1 Hoho J2 J3', o, [J, '(:step 1 :modded t :on :hit)', jw(6), JH], 1.6, frames=150)
    T('F3 J1 Hoho AS1', o, [J, '(:step 1 :modded t :on :hit)', spw(6)], 1.6, frames=170)
    T('F4 Step forward then J1 at its end (from 4.2 m)', o, ['(:step 1 :stick 1.0)', jf()], 4.2, frames=90)
    T('F5 Hoho from 6 m then J1 at its end', o, ['(:step 1 :modded t)', jf()], 6.0, frames=90)
    T('F6 Hoho from 6 m then NS1a at its end', o, ['(:step 1 :modded t)', spf()], 6.0, frames=100)
# ---------------------------------------------------------------- K. KESSA
sec('K. KESSA (:form :kessa): the J string, AS1 the whip, AS2, AS3 with clones, NS1 chains, NS2, NS3 clones')
for o in KH:
    T('K1 J1-J5', o, JS, 1.6, form=':kessa', frames=130)
    T('K2 J1 AS1 (whip, 4 lashes, steal 15 a hit)', o, [J, SPH], 1.6, form=':kessa', fs=100, frames=140)
    T('K3 J1-J3 AS2ab', o, [J, JH, JH, SPH, SP], 1.6, form=':kessa', frames=260)
    T('K4 J1-J5 AS3abc (clones)', o, JS + [SPH, SP, SP], 1.6, form=':kessa', frames=340)
    T('K5 NS1a-c (chains)', o, [SP, SP, SP], 2.6, form=':kessa', frames=200)
    T('K6 NS1a SA J2-J5 AS3abc', o, [SP, JH, JH, JH, JH, JH, SPH, SP, SP], 2.6, form=':kessa', frames=340)
    T('K7 NS1a-c at 3.3 m', o, [SP, SP, SP], 3.3, form=':kessa', frames=200)
    T('K8 NS2abc at 6.6 m (black Getsuga)', o, [SP, SP, SP], 6.6, ptr=2, form=':kessa', frames=180)
    T('K9 NS2ab SA-g2 J2-J5 AS3abc', o, [SP, SP, jw(16), JH, JH, JH, JH, SPH, SP, SP], 2.0, ptr=2, form=':kessa', frames=340)
    T('K10 NS3a SA (clone summon, the lunge) at 3.5 m', o, [SP, jw(10)], 3.5, ptr=3, form=':kessa', frames=120)
    T('K11 NS3abc (3 summons, the X)', o, [SP, SP, SP], 3.0, ptr=3, form=':kessa', frames=200)
    T('K12 NS3ab, SA J2-J5 AS3abc (clone replays)', o, [SP, SP, jw(6), JH, JH, JH, JH, SPH, SP, SP], 2.6, ptr=3, form=':kessa', frames=380)
    T('K13 NS3a SA at 4.6 m', o, [SP, jw(10)], 4.6, ptr=3, form=':kessa', frames=120)
    T('K14 J1 AS1 held (whip Kikon, ptr 1 before)', o, [J, hold(on=True)], 1.6, form=':kessa', frames=260)
    T('K15 NS1a held (ptr 1)', o, [hold()], 2.6, form=':kessa', frames=240)
    T('K16 Step (clone on a Step?) then J1', o, ['(:step 1)', jf()], 1.6, form=':kessa', frames=120)
sec('L. the awakening (Mod + P): full gauge from neutral; refused below full')
for o in KH:
    T('L1 awaken (gauge 100) then J1-J3', o, ['(:awaken 1 :modded t)', jw(40), JH, JH], 1.6, frames=200, extra=':awaken 100')
    T('L2 awaken at gauge 90 (refused)', o, ['(:awaken 1 :modded t)', jw(40)], 1.6, frames=120, extra=':awaken 90')

# ---------------------------------------------------------------- P. the openers' grid: both press on the same frame
sec('P. both press their opener on the same frame (P1 frame 0, P2 sim frame 0): who hits first / cancel / both whiff, by distance')
MINE = [('J1', [J], 1, ':base'), ('NS1a', [SP], 1, ':base'), ('NS2a+SAg1', [SP, jw(20)], 2, ':base'), ('NS3a', [SP], 3, ':base'),
        ('kJ1', [J], 1, ':kessa'), ('kNS1a', [SP], 1, ':kessa'), ('kNS3a+SA', [SP, jw(10)], 3, ':kessa')]
HIS = {'K': [('J1', ':j', 1), ('NS1a', ':sp', 1), ('NS2a', ':sp', 2), ('NS3a+SA', ':sp', 3)],
       'H': [('J1', ':j', 1), ('NS1a', ':sp', 1), ('NS2a', ':sp', 2), ('NS3a', ':sp', 3)],
       'Ks': [('J1', ':j', 1), ('NS1a', ':sp', 1), ('NS2a', ':sp', 2)],
       'Hb': [('J1', ':j', 1), ('NS1a', ':sp', 1), ('NS2a', ':sp', 2)]}
for o in ('K', 'H', 'Ks', 'Hb'):
    for d in (1.6, 2.4, 3.2, 4.2, 5.4):
        for mn, ms, mp, mf in MINE:
            for hn, hb, hp in HIS[o]:
                extra = f':p2-at ((0 {hb}){" (10 :j)" if hn == "NS3a+SA" else ""})'
                T(f'P {mn} vs his {hn} at {d}', o, ms, d, ptr=mp, form=mf, p2ptr=hp, frames=110, extra=extra)

# ---------------------------------------------------------------- X. the exchange after a cancel
sec('X. after a cancel: J vs NS, then AS / SA / J / the next segment; the later start wins AS vs SA')
for o in KH:
    # Ichigo's J1 into his NS1a (cancel): her AS at once, J2, or nothing; his answers: none, SA (J) at t, his next segment
    for his, hx in (('none', ''), ('SA f24', ' (24 :j)'), ('SA f30', ' (30 :j)'), ('NS1b f24', ' (24 :sp)')):
        for mine, ms in (('AS1 on contact', [jw(4), SPH]), ('J2 on contact', [jw(4), JH]), ('stop', [jw(4)])):
            T(f'X1 her J1 into his NS1a ({mine}), his {his}', o, ms, 2.0, p2ptr=1, frames=140, extra=f':p2-at ((0 :sp){hx})')
    # her NS1a vs his J1 (cancel): his AS at once / J2 / nothing; her SA at once (reaction) / next segment / nothing
    for his, hx in (('none', ''), ('AS f16', ' (16 :sp)'), ('J2 f16', ' (16 :j)')):
        for mine, ms in (('SA at once', [SP, jw(22)]), ('NS1b', [SP, spw(22)]), ('stop', [SP])):
            T(f'X2 her NS1a vs his J1 f8 ({mine}), his {his}', o, ms, 2.4, frames=140, extra=f':p2-at ((8 :j){hx})')
    # the JUJISHO wave against his J / SA / AS (in the triangle: J and SA cancel it, AS beats it)
    T('X3 NS2abc at 6.6 m, his J1 into the wave', o, [SP, SP, SP], 6.6, ptr=2, frames=180, extra=':p2-at ((60 :j) (64 :j) (68 :j) (72 :j))')
    T('X4 NS2abc at 3.0 m, his J1 into the wave', o, [SP, SP, SP], 3.0, ptr=2, frames=180, extra=':p2-at ((54 :j) (58 :j) (62 :j))')
    T('X5 her J1 hits, AS2a, AS2b point blank, his J', o, [J, JH, JH, SPH, SP], 1.6, ptr=2, frames=270, extra=':p2-at ((70 :j) (76 :j) (82 :j))')

# ---------------------------------------------------------------- W. his whiffs punished, and his reach
sec('W. his openers against her standing (his reach), and her punish of his whiff')
for o in ('K', 'H', 'Ks', 'Hb'):
    for hn, hb, hp, dists in {'K': [('J1', ':j', 1, (2.2, 2.6)), ('NS1a', ':sp', 1, (2.4, 2.9, 3.6)), ('NS2a', ':sp', 2, (2.4, 3.3)), ('NS3a+SA', ':sp', 3, (2.4, 3.2))],
                              'H': [('J1', ':j', 1, (2.1, 2.5)), ('NS1a', ':sp', 1, (2.6, 3.4, 6.0, 6.8)), ('NS2a', ':sp', 2, (2.8, 3.8)), ('NS3a', ':sp', 3, (4.4, 5.2))],
                              'Ks': [('J1', ':j', 1, (2.7, 3.6)), ('NS1a', ':sp', 1, (3.0, 4.5, 6.0)), ('NS2a', ':sp', 2, (1.8, 2.8))],
                              'Hb': [('J1', ':j', 1, (2.6, 3.4, 6.2, 6.8)), ('NS1a', ':sp', 1, (3.0, 3.6)), ('NS2a', ':sp', 2, (2.2, 4.4, 5.0))]}[o]:
        for d in dists:
            extra = f':p2-at ((0 {hb}){" (10 :j)" if hn == "NS3a+SA" else ""})'
            T(f'W his {hn} at {d}', o, [], d, p2ptr=hp, frames=80, extra=extra)
for o in KH:
    # his whiff then her punish (her press after his active frames)
    for hn, hb, hp, d in {'K': [('J1', ':j', 1, 3.0), ('NS1a', ':sp', 1, 3.4), ('NS2a', ':sp', 2, 3.6)],
                          'H': [('J1', ':j', 1, 2.8), ('NS2a', ':sp', 2, 4.0), ('NS1a (dead zone)', ':sp', 1, 2.2), ('NS3a', ':sp', 3, 5.6)]}[o]:
        for mn, ms, mp in (('NS1a f10', [spw(10)], 1), ('NS3a f14', [spw(14)], 3), ('NS3a f24', [spw(24)], 3), ('J1 f14 (walk in)', ['(:walk 8)', jw(6)], 1)):
            T(f'W his {hn} whiffs at {d}, her {mn}', o, ms, d, ptr=mp, p2ptr=hp, frames=120, extra=f':p2-at ((0 {hb}))')

# ---------------------------------------------------------------- N. anti-approach: he comes in
sec('N. anti-approach: he runs / walks in from range, she answers')
for o in KH:
    for d in (6.6, 8.5, 10.0):
        T(f'N1 NS2abc at {d} m, he runs in (Step held) then J', o, [SP, SP, SP], d, ptr=2, frames=180,
          extra=f':p2-press ((0 :step {int(d * 6)} nil 1) ({int(d * 6)} :quick 1))')
    for d in (5.0, 6.0):
        T(f'N2 NS3a at {d} m as he walks in (f6)', o, [spw(6)], d, ptr=3, frames=110, extra=':p2-press ((0 :walk 40 nil 1))')
        T(f'N3 NS1a at {d} m as he walks in (f10)', o, [spw(10)], d, ptr=1, frames=110, extra=':p2-press ((0 :walk 40 nil 1))')
        T(f'N4 J1 at {d} m as he walks in (f16)', o, [jw(16)], d, ptr=1, frames=110, extra=':p2-press ((0 :walk 40 nil 1))')
    T('N5 he Hohos in from 6 m, her J1 at f8', o, [jw(8)], 6.0, frames=90, extra=':p2-press ((0 :step 1 t))')
    T('N6 he Hohos in from 6 m, her NS1a at f2', o, [spw(2)], 6.0, frames=90, extra=':p2-press ((0 :step 1 t))')

# ---------------------------------------------------------------- Z. wake-up (after her knockdown): her meaty vs his wake-up J
sec('Z. after her AS knockdown: her next opener on his wake-up, he presses J on waking (the CPU-like answer)')
for o in KH:
    for w in (0, 10, 20, 30):
        T(f'Z1 J1 AS1, then J1 {w} f after she is free', o, [J, SPH, jf(w)], 1.6, ptr=1, fs=300, frames=200)
        T(f'Z2 J1 AS1, then NS1a {w} f after she is free', o, [J, SPH, spf(w)], 1.6, ptr=1, fs=300, frames=210)
    for w in (0, 10, 20):
        T(f'Z3 J1 AS1, then NS1a {w} f after she is free, he mashes J from sim f58', o, [J, SPH, spf(w)], 1.6, ptr=1, frames=210,
          extra=':p2-at ' + '(' + ' '.join(f'({t} :j)' for t in range(58, 110, 4)) + ')')
        T(f'Z4 J1 AS1, then J1 {w} f after she is free, he mashes J from sim f58', o, [J, SPH, jf(w)], 1.6, ptr=1, frames=210,
          extra=':p2-at ' + '(' + ' '.join(f'({t} :j)' for t in range(58, 110, 4)) + ')')
    T('Z5 J1-J5 AS3abc, then NS3a 20 f after she is free (ptr 3)', o, JS + [SPH, SP, SP, spf(20)], 1.6, ptr=3, frames=400)

print(';;;; trials.lisp: Ichigo\'s catalogue trials (PLAN4\'s kit study, step 2), GENERATED by gen.py in this directory; do not edit by hand.')
print(';;;;   python3 tools/combo-trial.py docs/research/strategy-drsi/sp/kits/ichigo/trials.lisp --events')
print(';;;; P1 Ichigo pressing only its script; P2 standing, or pressing J / SP on sim frames (:p2-at), or walking / running (:p2-press).')
print('\n'.join(out))

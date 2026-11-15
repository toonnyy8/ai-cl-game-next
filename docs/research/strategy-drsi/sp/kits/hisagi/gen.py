#!/usr/bin/env python3
"""gen.py — writes trials.lisp, Hisagi's catalogue trials (PLAN4 step 2), for tools/simgate/trial.lisp / tools/combo-trial.py.

  python3 docs/research/strategy-drsi/sp/kits/hisagi/gen.py      (writes trials.lisp next to it)

A trial's name is "SEC|id|...": run.py groups the results by it. P1 is always Hisagi (Hb Shikai :base, Hr the Bankai's ranged mode,
Hd the bind mode, bound). P2 forms: Kz sealed Kenpachi, Ks0 / Ks3 his Shikai at L0 / L3, Kb his Bankai KYORAN, Ib Ichigo's Shikai, Ik
KESSA, Hh Hisagi's Shikai (the mirror). Buttons: J = (:quick 1), SP = (:quick 1 :modded t), a held SP = the Kikon hold; P2's
:p2-at ((sim-frame :j|:sp)) presses on that sim frame (0 = with P1's first press), :p2-press ((frame button n modded stick)) any button.
"""
import os

OPP = {'Kz': ':p2 :kenpachi :p2-form :base', 'Ks0': ':p2 :kenpachi :p2-form :nozarashi :p2-meter 0',
       'Ks3': ':p2 :kenpachi :p2-form :nozarashi :p2-meter 3', 'Kb': ':p2 :kenpachi :p2-form :bankai',
       'Ib': ':p2 :ichigo :p2-form :base', 'Ik': ':p2 :ichigo :p2-form :kessa', 'Hh': ':p2 :hisagi :p2-form :base'}
FORM = {'Hb': ':form :base', 'Hr': ':form :bankai', 'Hd': ':form :bankai-bind :p1-bound t'}
J, SP = '(:quick 1)', '(:quick 1 :modded t)'
def jn(n): return ' '.join([J] * n)
def sp(n=1, **k): return ' '.join(['(:quick 1 :modded t%s)' % ''.join(f' :{a} {v}' for a, v in k.items())] * n)
# the neutral openers per form: (tag, pointer, script)
OPENERS = {'Hb': [('J1', 1, J), ('NS1a', 1, SP), ('NS2a', 2, SP), ('NS3a', 3, SP)],
           'Hr': [('J1', 1, J), ('NS1a', 1, SP), ('NS2a', 2, SP)],
           'Hd': [('J1', 1, J), ('NS1a', 1, SP), ('NS2a', 2, SP)]}
# the opponents' openers: (tag, his pointer, :p2-at entry)
HIS = {'Kz': [('J1', 1, '(0 :j)'), ('NS1a', 1, '(0 :sp)'), ('NS2a', 2, '(0 :sp)')],
       'Ks0': [('J1', 1, '(0 :j)'), ('NS1a', 1, '(0 :sp)'), ('NS2a', 2, '(0 :sp)')],
       'Kb': [('J1', 1, '(0 :j)'), ('NS1a', 1, '(0 :sp)')],
       'Ib': [('J1', 1, '(0 :j)'), ('NS1a', 1, '(0 :sp)'), ('NS3a', 3, '(0 :sp)')],
       'Ik': [('J1', 1, '(0 :j)'), ('NS1a', 1, '(0 :sp)'), ('NS3a', 3, '(0 :sp)')],
       'Hh': [('J1', 1, '(0 :j)'), ('NS1a', 1, '(0 :sp)'), ('NS2a', 2, '(0 :sp)'), ('NS3a', 3, '(0 :sp)')]}
out = []
def T(name, form, opp, dist, script, ptr=1, frames=120, fs=300, **k):
    extra = ''.join(f' :{a.replace("_", "-")} {v}' for a, v in k.items())
    out.append(f'(:name "{name}" :p1 :hisagi {FORM[form]} {OPP[opp]} :ptr {ptr} :dist {dist} :fs {fs} :script ({script}) :frames {frames}{extra})')
def rng(a, b, s): return [round(a + i * s, 2) for i in range(int(round((b - a) / s)) + 1)]

# ---------------------------------------------------------------- R: reach by band (a standing dummy)
for f, ops in OPENERS.items():
    for tag, p, sc in ops:
        for o in ('Kz', 'Ib'):
            for d in rng(1.0, 7.0, 0.5):
                T(f'R|{f}|{tag}|{o}|{d}', f, o, d, sc, ptr=p, frames=80)
# the edges at 0.1 m (RE): Hisagi's openers' near / far edges, then his
EDGES = {('Hb', 'J1'): [(1.8, 2.6)], ('Hb', 'NS1a'): [(2.6, 3.2), (5.8, 6.6)], ('Hb', 'NS2a'): [(3.3, 4.1)], ('Hb', 'NS3a'): [(4.6, 5.4)],
         ('Hr', 'J1'): [(2.6, 3.2), (5.0, 5.6), (5.8, 6.6)], ('Hr', 'NS1a'): [(2.8, 3.6)], ('Hr', 'NS2a'): [(2.2, 2.8), (3.6, 4.4), (4.4, 5.2)],
         ('Hd', 'J1'): [(1.0, 1.6), (1.6, 2.4)], ('Hd', 'NS1a'): [(6.4, 7.2)], ('Hd', 'NS2a'): [(2.8, 3.6)]}
for (f, tag), spans in EDGES.items():
    p, sc = [(q, x) for t, q, x in OPENERS[f] if t == tag][0]
    for o in ('Kz', 'Ib'):
        for a, b in spans:
            for d in rng(a, b, 0.1):
                T(f'RE|{f}|{tag}|{o}|{d}', f, o, d, sc, ptr=p, frames=80)
HEDGES = {('Kz', 'J1'): (2.2, 3.0), ('Kz', 'NS1a'): (2.8, 3.6), ('Kz', 'NS2a'): (2.8, 3.6), ('Ks0', 'J1'): (2.8, 3.6),
          ('Ks0', 'NS1a'): (5.2, 6.2), ('Ks0', 'NS2a'): (2.2, 3.0), ('Kb', 'NS1a'): (4.4, 5.2), ('Ib', 'J1'): (1.8, 2.6),
          ('Ib', 'NS1a'): (2.8, 3.6), ('Ib', 'NS3a'): (4.8, 5.6), ('Ik', 'J1'): (1.4, 2.2), ('Ik', 'NS1a'): (2.8, 3.6), ('Ik', 'NS3a'): (2.8, 3.6)}
for (o, tag), (a, b) in HEDGES.items():
    hp, at = [(q, x) for t, q, x in HIS[o] if t == tag][0]
    for d in rng(a, b, 0.1):
        T(f'RHE|{o}|{tag}|{d}', 'Hb', o, d, '', frames=80, p2_ptr=hp, p2_at=f'({at})')
# his openers against a standing Shikai Hisagi (P1 presses nothing)
for o in ('Kz', 'Ks0', 'Ks3', 'Kb', 'Ib', 'Ik'):
    for tag, p, at in HIS.get(o, HIS['Ks0']):
        for d in rng(1.0, 7.0, 0.5):
            T(f'RH|{o}|{tag}|{d}', 'Hb', o, d, '', frames=80, p2_ptr=p, p2_at=f'({at})')

# ---------------------------------------------------------------- T: the triangle, both press on the same frame
for f, opps, dists in (('Hb', ('Kz', 'Ks0', 'Ib', 'Ik', 'Hh'), (1.5, 2.5, 3.5, 4.5, 5.5)),
                       ('Hr', ('Kz', 'Ks0', 'Ib', 'Ik'), (1.5, 2.5, 3.5, 4.5, 5.5)),
                       ('Hd', ('Ks0', 'Ik'), (1.0, 2.0, 3.0, 4.0))):
    for tag, p, sc in OPENERS[f]:
        for o in opps:
            for htag, hp, at in HIS[o]:
                for d in dists:
                    T(f'T|{f}|{tag}|{o}|{htag}|{d}', f, o, d, sc, ptr=p, frames=120, p2_ptr=hp, p2_at=f'({at})')

# ---------------------------------------------------------------- C / D / E: hit-confirmed routes (a standing dummy)
ROUTES = {
 'Hb': [('J1', 1, 1.4, jn(1)), ('J1-J5', 1, 1.4, jn(5)), ('J1 AS1', 1, 1.4, jn(1) + ' ' + sp(on=':hit')),
        ('J1 J2 AS1', 1, 1.4, jn(2) + ' ' + sp(on=':hit')), ('J1-J3 AS2ab', 1, 1.4, jn(3) + ' ' + sp(on=':hit') + ' ' + sp()),
        ('J1-J4 AS2ab', 1, 1.4, jn(4) + ' ' + sp(on=':hit') + ' ' + sp()), ('J1-J5 AS3abc', 1, 1.4, jn(5) + ' ' + sp(on=':hit') + ' ' + sp(2)),
        ('NS1a 4.5', 1, 4.5, sp()), ('NS1abc 3.2', 1, 3.2, sp(3)), ('NS1abc 4.5', 1, 4.5, sp(3)), ('NS1abc 5.8', 1, 5.8, sp(3)),
        ('NS1a SA 3.5', 1, 3.5, sp() + ' ' + J), ('NS1a SA 4.5', 1, 4.5, sp() + ' ' + J),
        ('NS1a SA J2-J5 AS3abc 3.5', 1, 3.5, sp() + ' ' + J + ' ' + jn(4) + ' ' + sp(on=':hit') + ' ' + sp(2)),
        ('NS1a SA AS1 3.5', 1, 3.5, sp() + ' ' + J + ' ' + sp(on=':hit')),
        ('NS1ab SA J2 J3 AS2ab 3.5', 1, 3.5, sp(2) + ' ' + J + ' ' + jn(2) + ' ' + sp(on=':hit') + ' ' + sp()),
        ('NS1abc SA 4.5', 1, 4.5, sp(3) + ' ' + J),
        ('NS2a 2.5', 2, 2.5, sp()), ('NS2abc 2.5', 2, 2.5, sp(3)), ('NS2abc 3.4', 2, 3.4, sp(3)),
        ('NS2a SA J2-J5 AS3abc 2.5', 2, 2.5, sp() + ' ' + J + ' ' + jn(4) + ' ' + sp(on=':hit') + ' ' + sp(2)),
        ('NS2ab SA J2 J3 AS2ab 2.5', 2, 2.5, sp(2) + ' ' + J + ' ' + jn(2) + ' ' + sp(on=':hit') + ' ' + sp()),
        ('NS3a 4.0', 3, 4.0, sp()), ('NS3a 4.9', 3, 4.9, sp()),
        ('NS3a SA(YOSE) J2-J5 AS3abc 4.0', 3, 4.0, sp() + ' ' + J + ' ' + jn(4) + ' ' + sp(on=':hit') + ' ' + sp(2)),
        ('NS3a SA J2 J3 AS2ab 4.0', 3, 4.0, sp() + ' ' + J + ' ' + jn(2) + ' ' + sp(on=':hit') + ' ' + sp()),
        ('NS3ab HODEN 4.0', 3, 4.0, sp(2) + ' ' + J), ('NS3ab HODEN 2.0', 3, 2.0, sp(2) + ' ' + J),
        ('NS3ab then J1-J5 (ZANDEN)', 3, 3.0, sp(2) + ' (:walk 30 :on :free) ' + jn(5)),
        ('NS3ab then NS3ab HODEN (ZANDEN x1.6)', 3, 3.0, sp(2) + ' (:walk 1 :on :free) ' + sp(2) + ' ' + J),
        ('J1-J5 AS3abc then J1-J5 (ZANDEN)', 1, 1.4, jn(5) + ' ' + sp(on=':hit') + ' ' + sp(2) + ' (:walk 60 :on :free) ' + jn(5)),
        ('Kikon J1 J2 AS1 held', 1, 1.4, jn(2) + ' (:quick 60 :modded t :on :hit)'),
        ('Kikon NS1a held 4.5', 1, 4.5, '(:quick 60 :modded t)'), ('Kikon NS2a held 2.5', 2, 2.5, '(:quick 60 :modded t)'),
        ('Kikon NS3a held 4.0', 3, 4.0, '(:quick 60 :modded t)'),
        ('Kikon J1-J5 AS3abc, c held', 1, 1.4, jn(5) + ' ' + sp(on=':hit') + ' ' + sp() + ' (:quick 60 :modded t)')],
 'Hr': [('J1 4.5', 1, 4.5, jn(1)), ('J1 5.8 (tip)', 1, 5.8, jn(1)), ('J1-J5 5.8', 1, 5.8, jn(5)), ('J1-J5 4.5', 1, 4.5, jn(5)),
        ('J1 AS1 5.8', 1, 5.8, jn(1) + ' ' + sp(on=':hit')), ('J1 J2 AS1 4.5', 1, 4.5, jn(2) + ' ' + sp(on=':hit')),
        ('J1-J3 AS2ab 5.8', 1, 5.8, jn(3) + ' ' + sp(on=':hit') + ' ' + sp()), ('J1-J3 AS2ab 4.5', 1, 4.5, jn(3) + ' ' + sp(on=':hit') + ' ' + sp()),
        ('J1-J5 AS3abc 5.8 (the bind)', 1, 5.8, jn(5) + ' ' + sp(on=':hit') + ' ' + sp(2)),
        ('NS1abc 1.5 (WA push)', 1, 1.5, sp(3)), ('NS1abc 2.5', 1, 2.5, sp(3)), ('NS1a 3.5 (WA reach)', 1, 3.5, sp()),
        ('NS1a SA J2-J5 AS3abc 2.0', 1, 2.0, sp() + ' ' + J + ' ' + jn(4) + ' ' + sp(on=':hit') + ' ' + sp(2)),
        ('NS1ab SA AS1 2.0', 1, 2.0, sp(2) + ' ' + J + ' ' + sp(on=':hit')),
        ('NS2abc 3.0', 2, 3.0, sp(3)), ('NS2abc 4.25 (tip)', 2, 4.25, sp(3)), ('NS2a 2.0 (dead)', 2, 2.0, sp()),
        ('NS2a SA-g J2s J3g 3.5', 2, 3.5, sp() + ' ' + J + ' ' + jn(2)), ('NS2a SA-g AS1 3.5', 2, 3.5, sp() + ' ' + J + ' ' + sp(on=':hit')),
        ('NS2a SA-g J2s AS2ab 4.25', 2, 4.25, sp() + ' ' + J + ' ' + J + ' ' + sp(on=':hit') + ' ' + sp()),
        ('NS2ab SA-g J2s J3g AS3abc 3.0', 2, 3.0, sp(2) + ' ' + J + ' ' + jn(2) + ' ' + sp(on=':hit') + ' ' + sp(2)),
        ('Kikon J1 AS1 held 5.8', 1, 5.8, jn(1) + ' (:quick 60 :modded t :on :hit)'), ('Kikon NS2a held 4.25', 2, 4.25, '(:quick 60 :modded t)')],
 'Hd': [('J1 1.2 (close)', 1, 1.2, jn(1)), ('J1 1.6', 1, 1.6, jn(1)), ('J1-J5 1.2', 1, 1.2, jn(5)), ('J1 AS1 1.2', 1, 1.2, jn(1) + ' ' + sp(on=':hit')),
        ('J1-J3 AS2ab 1.2', 1, 1.2, jn(3) + ' ' + sp(on=':hit') + ' ' + sp()),
        ('J1-J5 AS3abc 1.2 (release)', 1, 1.2, jn(5) + ' ' + sp(on=':hit') + ' ' + sp(2)),
        ('NS1a 5.0 (hook)', 1, 5.0, sp()), ('NS1abc 5.0', 1, 5.0, sp(3)), ('NS1abc 2.0', 1, 2.0, sp(3)), ('NS1a 6.5', 1, 6.5, sp()),
        ('NS2abc 2.0', 2, 2.0, sp(3)), ('NS2abc 3.0', 2, 3.0, sp(3)),
        ('NS1a SA J2-J5 AS3abc 5.0', 1, 5.0, sp() + ' ' + J + ' ' + jn(4) + ' ' + sp(on=':hit') + ' ' + sp(2)),
        ('NS2a SA J2 J3 AS2ab 2.0', 2, 2.0, sp() + ' ' + J + ' ' + jn(2) + ' ' + sp(on=':hit') + ' ' + sp()),
        ('SA from 6 m (HIKIYOSE) in NS1a gap', 1, 6.0, sp() + ' ' + J)]}
for f, rs in ROUTES.items():
    for o in ('Kz', 'Ks0', 'Ib', 'Ik'):
        for tag, p, d, sc in rs:
            T(f'C|{f}|{tag}|{o}', f, o, d, sc, ptr=p, frames=420)
# the resource race: the same routes short of SP
for fs in (0, 30, 100):
    for tag, p, d, sc in [r for r in ROUTES['Hb'] if r[0] in ('J1-J5 AS3abc', 'NS1abc 4.5', 'NS2abc 2.5', 'NS3a SA(YOSE) J2-J5 AS3abc 4.0')]:
        T(f'CF|Hb|{tag}|Kz|fs {fs}', 'Hb', 'Kz', d, sc, ptr=p, frames=420, fs=fs)
# the bind's clash evening (DUEL_HISAGI §28): his NS1a cancelled by Hisagi's J1 inside the bind, from behind / ahead
for tag, k in (('behind (P1 300)', 'p1_reishi=300'), ('ahead (P2 300)', 'p2_reishi=300')):
    kw = {'p1_reishi': 300} if 'P1' in tag else {'p2_reishi': 300}
    for o in ('Ks0', 'Ik'):
        T(f'B|Hd|clash {tag}|{o}', 'Hd', o, 1.6, J, frames=120, p2_ptr=1, p2_at='((0 :sp))', **kw)
        T(f'B|Hr|clash {tag} (not bound)|{o}', 'Hr', o, 1.6, SP, frames=120, p2_ptr=1, p2_at='((0 :j))', **kw)

# ---------------------------------------------------------------- W: whiff punishes
# his opener just out of reach, Hisagi's answer N frames after his start
WH = {'Kz': [('J1', 1, '(0 :j)', 2.8), ('NS1a', 1, '(0 :sp)', 3.6)], 'Ks0': [('J1', 1, '(0 :j)', 3.4), ('NS1a', 1, '(0 :sp)', 6.0)],
      'Ib': [('J1', 1, '(0 :j)', 2.4), ('NS1a', 1, '(0 :sp)', 3.6)], 'Ik': [('J1', 1, '(0 :j)', 2.6), ('NS1a', 1, '(0 :sp)', 3.8)]}
for o, lst in WH.items():
    for htag, hp, at, d in lst:
        for tag, p, sc in OPENERS['Hb']:
            for w in (10, 20, 30):
                T(f'W|Hb|{tag} +{w} on his {htag} whiff|{o}|{d}', 'Hb', o, d, sc.replace(')', f' :wait {w})', 1), ptr=p, frames=140,
                  p2_ptr=hp, p2_at=f'({at})')
# Hisagi's whiff, his answer N frames after Hisagi's start (J1 / NS1a)
for o in ('Kz', 'Ks0', 'Ib', 'Ik'):
    for tag, p, sc, d in (('NS1a', 1, SP, 2.4), ('J1', 1, J, 2.4), ('NS2a', 2, SP, 3.9), ('NS3a', 3, SP, 5.3)):
        for htag, hp, key in (('J1', 1, ':j'), ('NS1a', 1, ':sp')):
            for w in (10, 20, 30):
                T(f'WH|Hb|his {htag} +{w} on Hisagi {tag} whiff|{o}|{d}', 'Hb', o, d, sc, ptr=p, frames=140, p2_ptr=hp, p2_at=f'(({w} {key}))')

# ---------------------------------------------------------------- A: anti-approach
for o in ('Kz', 'Ks0', 'Ib', 'Ik'):
    for w in (0, 6, 12, 18, 24):   # he runs in from 6.5 m, NAGI w frames later
        T(f'A|Hb|NS1a +{w} on his run-in|{o}|6.5', 'Hb', o, 6.5, f'(:quick 1 :modded t :wait {w})', ptr=1, frames=120,
          p2_press='((0 :step 60 nil 1))')
    for w in (0, 6, 12):           # he walks in from 5 m
        T(f'A|Hb|NS1a +{w} on his walk-in|{o}|5.0', 'Hb', o, 5.0, f'(:quick 1 :modded t :wait {w})', ptr=1, frames=120,
          p2_press='((0 :walk 80 nil 1))')
    for tag, p, sc in OPENERS['Hb'] + [('Step back', 1, '(:step 1 :stick -1)')]:   # his Hoho in from 4.5 m (he lands 1.6 m behind)
        for w in (0, 8):
            T(f'A|Hb|{tag} +{w} on his Hoho|{o}|4.5', 'Hb', o, 4.5, sc.replace(')', f' :wait {w})', 1), ptr=p, frames=120,
              p2_press='((0 :step 1 t))')
    for tag, p, sc in (('J1', 1, J), ('NS2a', 2, SP), ('Step back', 1, '(:step 1 :stick -1)')):   # his Hoho in, then his J1 as he lands
        for w in (6, 12, 18):
            T(f'A|Hb|{tag} +{w} on his Hoho > J1|{o}|4.5', 'Hb', o, 4.5, sc.replace(')', f' :wait {w})', 1), ptr=p, frames=140,
              p2_press='((0 :step 1 t) (26 :quick 1))')
    for tag, p, sc in (('J1', 1, J), ('NS1a (WA)', 1, SP), ('Step back', 1, '(:step 1 :stick -1)')):
        for w in (6, 12, 18):
            T(f'A|Hr|{tag} +{w} on his Hoho > J1|{o}|4.5', 'Hr', o, 4.5, sc.replace(')', f' :wait {w})', 1), ptr=p, frames=140,
              p2_press='((0 :step 1 t) (26 :quick 1))')
    for tag, p, sc in OPENERS['Hr']:
        for w in (0, 6, 12):
            T(f'A|Hr|{tag} +{w} on his run-in|{o}|6.5', 'Hr', o, 6.5, sc.replace(')', f' :wait {w})', 1), ptr=p, frames=120,
              p2_press='((0 :step 60 nil 1))')

# ---------------------------------------------------------------- X: the exchange after a cancel
for o in ('Kz', 'Ks0', 'Ib', 'Ik'):
    # X-a: Hisagi J1 x his NS1a at 1.6 m (a cancel), Hisagi's next x his
    for mine, sc in (('AS1', J + ' ' + sp(on=':hit')), ('J2', J + ' (:quick 1 :on :hit)'), ('nothing', J)):
        for his, at in (('none', ''), ('SA +2', ':j 2'), ('SA +8', ':j 8'), ('NS1b +2', ':sp 2')):
            ats = '((0 :sp))' if not at else '((0 :sp) (CF %s))' % at
            T(f'X|Hb|J1 x his NS1a, {mine} vs his {his}|{o}|1.6', 'Hb', o, 1.6, sc, frames=160, p2_ptr=1, p2_at=ats)
    # X-b: Hisagi NS2a x his J1 at 1.8 m, Hisagi's next (SA / NS2b / nothing) x his (AS / J2 / none)
    for mine, sc in (('SA', SP + ' (:quick 1 :on :hit)'), ('NS2b', SP + ' ' + sp(on=':hit')), ('nothing', SP)):
        for his, at in (('none', ''), ('AS +2', ':sp 2'), ('AS +8', ':sp 8'), ('J2 +2', ':j 2')):
            ats = '((0 :j))' if not at else '((0 :j) (CF %s))' % at
            T(f'X|Hb|NS2a x his J1, {mine} vs his {his}|{o}|1.8', 'Hb', o, 1.8, sc, ptr=2, frames=160, p2_ptr=1, p2_at=ats)
    # X-c: the ranged J1 x his NS1a at 4.5 m / 2.2 m (dead zone: his hit judged), then AS1 / J2
    for d in (2.2, 4.5):
        for mine, sc in (('AS1', J + ' ' + sp(on=':hit')), ('J2', J + ' (:quick 1 :on :hit)')):
            for his, at in (('none', ''), ('SA +8', ':j 8')):
                ats = '((0 :sp))' if not at else '((0 :sp) (CF %s))' % at
                T(f'X|Hr|J1 x his NS1a, {mine} vs his {his}|{o}|{d}', 'Hr', o, d, sc, frames=160, p2_ptr=1, p2_at=ats)

# X-d: Hisagi J1 into the long NS openers (his Shikai's lunge, his Bankai's, Ichigo's NS3a rush), then TSUMUJI / nothing
for o, htag, hp, dists in (('Ks0', 'NS1a (lunge)', 1, (3.0, 4.0, 5.0)), ('Kb', 'NS1a', 1, (2.5, 4.0)), ('Ib', 'NS3a', 3, (2.5, 3.5, 4.5))):
    for d in dists:
        for mine, sc in (('AS1', J + ' ' + sp(on=':hit')), ('nothing', J)):
            for his, ats in (('none', '((0 :sp))'), ('SA +8', '((0 :sp) (24 :j))')):
                T(f'X|Hb|J1 x his {htag}, {mine} vs his {his}|{o}|{d}', 'Hb', o, d, sc, frames=170, p2_ptr=hp, p2_at=ats)

# ---------------------------------------------------------------- G: Ichigo's Getsuga route (NS2a > NS2b > NS2c JUJISHO, the wave), Hisagi's answers
for o in ('Ib', 'Ik'):
    for d in (4.0, 6.0, 8.0):
        for tag, p, sc in (('nothing', 1, ''), ('NS1a +0', 1, SP), ('NS1a +20', 1, '(:quick 1 :modded t :wait 20)'),
                           ('NS1a +40', 1, '(:quick 1 :modded t :wait 40)'), ('NS3a +20', 3, '(:quick 1 :modded t :wait 20)'),
                           ('J1 +50', 1, '(:quick 1 :wait 50)'), ('J1 +60', 1, '(:quick 1 :wait 60)'),
                           ('Step back +40', 1, '(:step 1 :stick -1 :wait 40)'), ('Hoho +50', 1, '(:step 1 :modded t :wait 50)'),
                           ('Hoho +60', 1, '(:step 1 :modded t :wait 60)')):
            T(f'G|Hb|{tag} vs his Getsuga|{o}|{d}', 'Hb', o, d, sc, ptr=p, frames=200, p2_ptr=2, p2_at='((0 :sp) (22 :sp) (40 :sp))')

# ---------------------------------------------------------------- K: wake-up (his knockdown, then Hisagi's meaty)
for o in ('Kz', 'Ib'):
    for rtag, p, d, pre in (('J1 AS1', 1, 1.4, jn(1) + ' ' + sp(on=':hit')),
                            ('J1-J5 AS3abc', 1, 1.4, jn(5) + ' ' + sp(on=':hit') + ' ' + sp(2)),
                            ('NS2abc', 2, 2.5, sp(3))):
        for mtag, msc in (('NS1a', '(:quick 1 :modded t :on :free :wait %d)'), ('J1', '(:quick 1 :on :free :wait %d)'),
                          ('walk-in J1', '(:walk 20 :on :free :wait %d) (:quick 1)')):
            for w in (0, 20, 40):
                T(f'K|Hb|{rtag} then {mtag} +{w}|{o}', 'Hb', o, d, pre + ' ' + (msc % w), ptr=p, frames=520)
        # his wake-up answers to the J1 AS1 knockdown + NAGI: Hoho / J1 mashed through his wake-up
        if rtag == 'J1 AS1':
            for his, pp in (('Hoho mash', ' '.join(f'({k} :step 1 t)' for k in range(70, 160, 6))),
                            ('J1 mash', ' '.join(f'({k} :quick 1)' for k in range(70, 160, 6)))):
                T(f'K|Hb|J1 AS1 then NS1a +20 vs his {his}|{o}', 'Hb', o, 1.4, pre + ' (:quick 1 :modded t :on :free :wait 20)', ptr=1,
                  frames=520, p2_press=f'({pp})')

# ---------------------------------------------------------------- H: the mirror's neutral (more in T|Hb|..|Hh)
for d in (3.5, 4.5, 5.5):
    T(f'H|Hb|NS1a vs his NS1a +4|Hh|{d}', 'Hb', 'Hh', d, SP, frames=120, p2_ptr=1, p2_at='((4 :sp))')
    T(f'H|Hb|NS1a +4 vs his NS1a|Hh|{d}', 'Hb', 'Hh', d, '(:quick 1 :modded t :wait 4)', frames=120, p2_ptr=1, p2_at='((0 :sp))')
    T(f'H|Hb|Step back vs his NS1a|Hh|{d}', 'Hb', 'Hh', d, '(:step 1 :stick -1)', frames=120, p2_ptr=1, p2_at='((0 :sp))')

here = os.path.dirname(os.path.abspath(__file__))
CANCEL = {('X-a', 'Kz'): 15, ('X-a', 'Ks0'): 15, ('X-a', 'Ib'): 15, ('X-a', 'Ik'): 15,
          ('X-b', 'Kz'): 10, ('X-b', 'Ks0'): 10, ('X-b', 'Ib'): 15, ('X-b', 'Ik'): 9}
lines = []
for l in out:
    if '(CF ' in l:
        o = l.split('|')[3]
        kind = 'X-a' if ('J1 x his NS1a' in l) else 'X-b'
        if '|Hr|' in l: kind = 'X-a'
        cf = CANCEL[(kind, o)]
        seg = l.split('(CF ')[1].split(')')[0]          # ":j 2"
        key, off = seg.split()
        l = l.replace(f'(CF {seg})', f'({cf + int(off)} {key})')
    lines.append(l)
with open(os.path.join(here, 'trials.lisp'), 'w') as f:
    f.write(';;;; trials.lisp — Hisagi\'s catalogue trials, generated by gen.py (PLAN4 step 2). Run: python3 '
            'docs/research/strategy-drsi/sp/kits/hisagi/run.py (tools/simgate/trial.lisp; combo-trial.py reads it too).\n')
    f.write('\n'.join(lines) + '\n')
print(len(lines), 'trials')

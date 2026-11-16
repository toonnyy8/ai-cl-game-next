#!/usr/bin/env python3
"""cands.py — batch p9-ih's candidate IH Ichigo tables (arms6/ih.md). Each candidate = a list of arms (one-line plists) and a q function
over the :rb-sp2 rules; written as raw table files into arms6/ih/c/<name>.lisp with tab.py, on t0-ih-ichigo.lisp's layout.

  python3 cands.py [NAME ...]     (no name: all)
"""
import os, re, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import tab  # noqa: E402

BASE = os.path.join(HERE, '../arms5/t0/t0-ih-ichigo.lisp')
OUT = os.path.join(HERE, 'ih/c')
T0 = open(BASE).read()
ARMS0, _ = tab.split_arms(T0)
Q0 = dict(tab.rules(T0))
A = {re.match(r'\(:id (:[\w-]+)', a)[1]: a for a in ARMS0}


def derive(src, nid, add='', drop=()):
    """Arm SRC (an id of t0's arms) renamed NID, base keys DROP removed and the plist text ADD put first in its :base (GETF: the first wins)."""
    t = A[src].replace(f'(:id {src} ', f'(:id {nid} ', 1)
    for k in drop:
        t = re.sub(rf' {re.escape(k)} [-\d.]+', '', t)
    return t.replace(':base (', ':base (' + (add + ' ' if add else ''), 1)


def one(arm):
    return [arm], (lambda ante, k: 0.0)


C = {}
# --- single arms played whole (diagnosis: which play is least dominated at parity) ---
for i, a in enumerate(ARMS0):
    C['one-' + re.match(r'\(:id :([\w-]+)', a)[1]] = one(a)
C['one-generic'] = one(derive(':a4-i-all', ':i6-generic', ':iks-mix-generic 1.0 :iks-mix-space 0.0 :iks-mix-whiff 0.0 :iks-mix-ptr3 0.0 :iks-mix-kessa 0.0'))
C['one-close'] = one(derive(':a4-i-all', ':i6-close', ':iks-mix-generic 0.0 :iks-mix-space 0.0 :iks-mix-whiff 1.0 :iks-mix-ptr3 0.0 :iks-mix-kessa 0.0 '
                            ':iks-patient-p 1.0 :iks-hover-add -1.5 :iks-wait-max 300', drop=(':iks-wait-max',)))
C['one-spacein'] = one(derive(':a4-i-all', ':i6-spacein', ':iks-mix-generic 0.0 :iks-mix-space 1.0 :iks-mix-whiff 0.0 :iks-mix-ptr3 0.0 :iks-mix-kessa 0.0 '
                              ':iks-patient-p 1.0 :iks-hover-add -1.5 :iks-wait-max 300', drop=(':iks-wait-max',)))
C['one-lunge'] = one(derive(':a4-i-all', ':i6-lunge', ':iks-mix-generic 0.0 :iks-mix-space 1.0 :iks-mix-whiff 0.0 :iks-mix-ptr3 0.0 :iks-mix-kessa 0.0 '
                            ':iks-patient-p 0.0 :iks-hover-add -1.5 :iks-gap-p 0.0 :iks-wait-max 300', drop=(':iks-wait-max', ':iks-gap-p')))

# --- round 2: the NS punish misreads Hisagi's reach (*IKS-HIS-REACH* :base is sealed Kenpachi's NS 3.65 m; NAGI reaches 6.0): off; the
# timed Hoho at every tier (perfect Hoho = the counter on NAGI) ---
MODES0 = ':iks-mix-generic 0.0 :iks-mix-whiff 0.0 :iks-mix-ptr3 0.0 :iks-mix-kessa 0.0 '
C['v1-nopun'] = one(derive(':a4-i-all', ':i6-v1', ':iks-punish-p 0.0'))
C['v2-hoho'] = one(derive(':a4-i-all', ':i6-v2', ':iks-punish-p 0.0 :iks-hoho-p 1.0'))
C['v3-space'] = one(derive(':a4-i-all', ':i6-v3', MODES0 + ':iks-mix-space 1.0 :iks-patient-p 1.0 :iks-punish-p 0.0 :iks-hoho-p 1.0 :iks-wait-max 300',
                           drop=(':iks-wait-max',)))
C['v4-spacefar'] = one(derive(':a4-i-all', ':i6-v4', MODES0 + ':iks-mix-space 1.0 :iks-patient-p 1.0 :iks-punish-p 0.0 :iks-hoho-p 1.0 :iks-hover-add 0.6 :iks-wait-max 300',
                              drop=(':iks-wait-max',)))
C['v5-whiffin'] = one(derive(':a4-i-all', ':i6-v5', ':iks-mix-generic 0.0 :iks-mix-space 0.0 :iks-mix-ptr3 0.0 :iks-mix-kessa 0.0 :iks-mix-whiff 1.0 '
                             ':iks-patient-p 1.0 :iks-punish-p 0.0 :iks-hoho-p 1.0 :iks-hover-add -1.5 :iks-wait-max 300', drop=(':iks-wait-max',)))

# --- round 3: the shut-gauge lunge (IKS-GAP) also misfires: Hisagi spends his gauge on NAGI, so his Hoho reads shut, she backs off to 6.5 m
# and lunges NS3a (5.0 m) into his NAGI from 6.2 m. Off (:iks-gap-p 0), with the punish off and the Hoho at every tier ---
G0 = ' :iks-gap-p 0.0 :iks-punish-p 0.0 :iks-hoho-p 1.0'
C['w1-all'] = one(derive(':a4-i-all', ':i6-w1', G0.strip(), drop=(':iks-gap-p',)))
C['w2-space'] = one(derive(':a4-i-all', ':i6-w2', MODES0 + ':iks-mix-space 1.0 :iks-patient-p 1.0 :iks-wait-max 300' + G0, drop=(':iks-wait-max', ':iks-gap-p')))
C['w3-spacefar'] = one(derive(':a4-i-all', ':i6-w3', MODES0 + ':iks-mix-space 1.0 :iks-patient-p 1.0 :iks-hover-add 0.6 :iks-wait-max 300' + G0,
                              drop=(':iks-wait-max', ':iks-gap-p')))
C['w4-whiffin'] = one(derive(':a4-i-all', ':i6-w4', ':iks-mix-generic 0.0 :iks-mix-space 0.0 :iks-mix-ptr3 0.0 :iks-mix-kessa 0.0 :iks-mix-whiff 1.0 '
                             ':iks-patient-p 1.0 :iks-hover-add -1.5 :iks-wait-max 300' + G0, drop=(':iks-wait-max', ':iks-gap-p')))
C['w5-gaponly'] = one(derive(':a4-i-all', ':i6-w5', ':iks-gap-p 0.0', drop=(':iks-gap-p',)))
C['w6-spacefar2'] = one(derive(':a4-i-all', ':i6-w6', MODES0 + ':iks-mix-space 1.0 :iks-patient-p 1.0 :iks-hover-add 1.3 :iks-wait-max 300' + G0,
                               drop=(':iks-wait-max', ':iks-gap-p')))

# --- round 4: the match is decided after both awaken (phase.py: Hisagi takes ~8 of his ~9 Konpaku in his Bankai / bind; in KESSA she
# hovers at the :nozarashi entry 4.9-5.3 m, inside his ranged J's 3.4-6.2 m, and punishes his J as if it reached 3.2 m). Arm rules on
# (:awk :yes) (her KESSA; she awakens ~3 s after him) change only the awakened play ---


def rule(t, r):
    """Arm text T with the rule R (text) put first in its :rules."""
    return t.replace(':rules (', ':rules (' + r + ' ', 1)


B4 = derive(':a4-i-all', ':i6-b4', G0.strip(), drop=(':iks-gap-p',))
MIX = lambda m: ' '.join(f':iks-mix-{k} {1.0 if k == m else 0.0}' for k in ('generic', 'space', 'whiff', 'ptr3', 'kessa'))  # noqa: E731
K = {'kfar': MIX('whiff') + ' :iks-hover-add 1.6',
     'kfar2': MIX('whiff') + ' :iks-hover-add 2.4',
     'kin': MIX('whiff') + ' :iks-hover-add -2.6',
     'kmid': MIX('whiff') + ' :iks-hover-add -1.2',
     'klunge': MIX('space') + ' :iks-hover-add 1.6 :iks-kessa-lunge-lo 4.2 :iks-kessa-lunge-hi 5.0',
     'kgen': MIX('generic'),
     'kptr3': MIX('ptr3'),
     'kkessa': MIX('kessa') + ' :iks-hover-add 1.6'}
for _n, _k in K.items():
    C['x-' + _n] = one(rule(B4.replace(':i6-b4', ':i6-' + _n), f'(((:awk :yes)) ({_k}))'))
C['x-b4'] = one(B4)

# --- round 5: the IH unit (d-x-ih-i) turns her clash off (:clash-p 0.0), set before X2's clash (§11.30: .45 / 8 at EASY / NORMAL, 1.0 / 4
# at HARD); the answer arm, the one arm over .09 at parity, turns it back on (1.7). The clash and the exchange keys on arm 0 ---
XA = ':clash-p 1.7 :xch-sa-p 1.6 :xch-carry-p 0.3 :clash-margin 0.5'
C['c1-all'] = one(derive(':a4-i-all', ':i6-c1', XA))
C['c2-allg0'] = one(derive(':a4-i-all', ':i6-c2', XA + G0, drop=(':iks-gap-p',)))
C['c3-clash'] = one(derive(':a4-i-all', ':i6-c3', ':clash-p 1.7'))
C['c4-clashm'] = one(derive(':a4-i-all', ':i6-c4', ':clash-p 1.7 :clash-margin 1.5'))
C['c5-answerg0'] = one(derive(':a5-i-answer', ':i6-c5', G0.strip(), drop=(':iks-gap-p',)))
C['c6-kfar'] = one(rule(derive(':a4-i-all', ':i6-c6', XA + G0, drop=(':iks-gap-p',)), f"(((:awk :yes)) ({K['klunge']}))"))

# --- round 6 (switching tables): the answer arm alone passes N>E and E>M IH (.935 / .930, f8-one-a5-i-answer). Which part, in the T0's
# switching table: the IH unit with the answer's exchange keys (the clash back on), and arm 0 as brawl's play ---
UNIT0 = '(:id :d-x-ih-i :base (:clash-p 0.0 :awaken-break-p 0.0 :awaken-kikon-p 1.2 :clash-margin 0.3))'
UNIT1 = '(:id :d-x-ih-i :base (:clash-p 1.7 :xch-sa-p 1.6 :xch-carry-p 0.3 :clash-margin 0.5 :awaken-break-p 0.0 :awaken-kikon-p 1.2))'
T0Q = lambda ante, k: Q0[ante][k]  # noqa: E731
BRAWL0 = ':iks-patient-p 0.0 :iks-gap-p 0.0 ' + MIX('ptr3')
C['t-unit'] = (ARMS0, T0Q, [(UNIT0, UNIT1)])
C['t-unit-b0'] = ([derive(':a4-i-all', ':i6-all', BRAWL0, drop=(':iks-gap-p',))] + ARMS0[1:], T0Q, [(UNIT0, UNIT1)])
C['t-b0'] = ([derive(':a4-i-all', ':i6-all', BRAWL0, drop=(':iks-gap-p',))] + ARMS0[1:], T0Q, [])


def fix(t, add):
    """Arm text T with ADD's keys first in its :base, the same keys dropped from the rest of it (GETF reads the first anyway)."""
    for k in re.findall(r'(:[\w-]+) [-\d.]+', add):
        t = re.sub(rf' {re.escape(k)} [-\d.]+', '', t)
    return t.replace(':base (', ':base (' + add + ' ', 1)


ARMSB = [derive(':a4-i-all', ':i6-all', BRAWL0, drop=(':iks-gap-p',))] + ARMS0[1:]
C['t-ug'] = ([fix(a, G0.strip()) for a in ARMSB], T0Q, [(UNIT0, UNIT1)])
C['t-ug2'] = ([fix(a, ':iks-gap-p 0.0 :iks-punish-p 0.0') for a in ARMSB], T0Q, [(UNIT0, UNIT1)])
C['t-ug3'] = ([fix(a, ':iks-gap-p 0.0') for a in ARMSB], T0Q, [(UNIT0, UNIT1)])

# --- round 7: H>N IH stays at .55-.60 with the clash on (baseline .63 with it off). The unit's :clash-p scales *cai-clash-p* (clamped to
# 1): 1.7 lifts EASY / NORMAL to .765, 1.0 keeps the shipped tiers (.45 / .45 / 1.0) ---
U = lambda body: f'(:id :d-x-ih-i :base ({body}))'  # noqa: E731
C['u1'] = (ARMS0, T0Q, [(UNIT0, U(':clash-p 1.0 :awaken-break-p 0.0 :awaken-kikon-p 1.2 :clash-margin 0.3'))])
C['u2'] = (ARMS0, T0Q, [(UNIT0, U(':clash-p 1.0 :xch-sa-p 1.6 :xch-carry-p 0.3 :clash-margin 0.5 :awaken-break-p 0.0 :awaken-kikon-p 1.2'))])
C['u3'] = (ARMSB, T0Q, [(UNIT0, U(':clash-p 1.0 :xch-sa-p 1.6 :xch-carry-p 0.3 :clash-margin 0.5 :awaken-break-p 0.0 :awaken-kikon-p 1.2'))])
C['u4'] = (ARMS0, T0Q, [(UNIT0, U(':clash-p 1.7 :awaken-break-p 0.0 :awaken-kikon-p 1.2 :clash-margin 0.3'))])
C['u5'] = (ARMS0, T0Q, [(UNIT0, U(':clash-p 1.7 :xch-sa-p 1.6 :awaken-break-p 0.0 :awaken-kikon-p 1.2 :clash-margin 0.3'))])

# --- round 8: in H>N her generic neutral (brawl's ptr3 mode) throws NS1a (3.4 m) at his band's floor; his back Step takes him out, the NS
# whiffs (ns-stop) and his whiff rule NAGIs it (hn-1.log). The generic's NS share (:ns, .35 in every arm) and its walk band (:range .7) ---
A0 = ARMSB[0]
C['n1'] = ([fix(A0, ':ns 0.0')] + ARMSB[1:], T0Q, [(UNIT0, UNIT1)])
C['n2'] = ([fix(A0, ':ns 0.1 :range 0.5')] + ARMSB[1:], T0Q, [(UNIT0, UNIT1)])
C['n3'] = ([fix(a, ':ns 0.0') for a in ARMSB], T0Q, [(UNIT0, UNIT1)])
C['n4'] = ([fix(A0, ':range 0.5')] + ARMSB[1:], T0Q, [(UNIT0, UNIT1)])

# --- round 9: arm 0 that waits for NAGI (its timed Hoho: HARD .9, NORMAL / EASY 0 as shipped) instead of walking into his back Step ---
SPC = derive(':a4-i-all', ':i6-all', MIX('space') + ' :iks-patient-p 1.0 :iks-punish-p 0.0 :iks-gap-p 0.0 :iks-wait-max 300', drop=(':iks-wait-max', ':iks-gap-p'))
C['h1'] = ([SPC] + ARMSB[1:], T0Q, [(UNIT0, UNIT1)])
C['h2'] = ([fix(SPC, ':iks-hover-add 0.6')] + ARMSB[1:], T0Q, [(UNIT0, UNIT1)])
C['h3'] = ([derive(':a4-i-all', ':i6-all', ':iks-punish-p 0.0 :iks-gap-p 0.0', drop=(':iks-gap-p',))] + ARMSB[1:], T0Q, [(UNIT0, UNIT1)])

# --- round 10: t-unit-b0's arm 0 is the answer arm in effect (brawl's keys + the unit's clash keys), yet the table trails the answer arm
# alone (E>M .760 / .930, N>E .870 / .935, H>N .545 / .610): the job arms misfire against Hisagi. punish hovers at 3.7-4.2 m (his NAGI
# band) and punishes by sealed Kenpachi's reach (*IKS-HIS-REACH*); kessa-lunge keeps the shut-gauge lunge (:iks-gap-p 1.0) ---
A = dict(zip([re.match(r'\(:id (:[\w-]+)', a)[1] for a in ARMSB], ARMSB))
PUN2 = fix(A[':a5-i-punish'], MIX('whiff') + ' :iks-patient-p 1.0 :iks-punish-p 0.0 :iks-confirm-p 1.0 :iks-hover-add -1.5 :iks-wait-max 300')
KL2 = fix(A[':a5-i-kessa-lunge'], ':iks-gap-p 0.0 :iks-punish-p 0.0')
EC2 = fix(A[':a5-i-economy'], ':iks-gap-p 0.0 :iks-punish-p 0.0')
C['f1'] = ([ARMSB[0], A[':a5-i-answer'], A[':a4-i-brawl'], EC2, PUN2, KL2], T0Q, [(UNIT0, UNIT1)])
C['f2'] = ([ARMSB[0], A[':a5-i-answer'], A[':a4-i-brawl'], A[':a5-i-economy'], PUN2, A[':a5-i-kessa-lunge']], T0Q, [(UNIT0, UNIT1)])
C['f3'] = ([ARMSB[0], A[':a5-i-answer'], A[':a4-i-brawl'], A[':a5-i-economy'], A[':a5-i-punish'], KL2], T0Q, [(UNIT0, UNIT1)])
C['f4'] = ([ARMSB[0], A[':a5-i-answer'], A[':a4-i-brawl'], EC2, A[':a5-i-punish'], A[':a5-i-kessa-lunge']], T0Q, [(UNIT0, UNIT1)])
# the job arms on arm 0's neutral (brawl's: patience off, the ptr3 mode, no shut-gauge lunge), each keeping its own job key on top:
# economy its steer to AS1; punish its whiff confirm at 1.0 (the start-time punish off: it reads sealed Kenpachi's reach)
EC3 = fix(A[':a5-i-economy'], BRAWL0)
PUN3 = fix(A[':a5-i-punish'], BRAWL0 + ' :iks-punish-p 0.0 :iks-confirm-p 1.0')
C['g1'] = ([ARMSB[0], A[':a5-i-answer'], A[':a4-i-brawl'], EC3, PUN3, A[':a5-i-kessa-lunge']], T0Q, [(UNIT0, UNIT1)])
C['g2'] = ([ARMSB[0], A[':a5-i-answer'], A[':a4-i-brawl'], EC3, PUN3, KL2], T0Q, [(UNIT0, UNIT1)])
# the pick (arms6/ih.md): g1 with its two changed job arms under ids of their own (their plists differ from the KI / II tables' arms)
FINAL = [ARMSB[0], A[':a5-i-answer'], A[':a4-i-brawl'], EC3.replace('(:id :a5-i-economy ', '(:id :i6-economy ', 1),
         PUN3.replace('(:id :a5-i-punish ', '(:id :i6-punish ', 1), A[':a5-i-kessa-lunge']]
# under the new unit, arm 0 (= a4-i-brawl's plist) and the answer arm (brawl + the same exchange keys the unit now lays) play alike: drop
# both duplicate columns (answer 1, brawl 2), keeping arm 0, economy, punish, kessa-lunge and their q columns
KEEP = (0, 3, 4, 5)
FINAL4 = [FINAL[i] for i in KEEP]
Q4 = lambda ante, k: Q0[ante][KEEP[k]]  # noqa: E731
C['g1d'] = (FINAL4, Q4, [(UNIT0, UNIT1)])
# ablation: t-unit-b0 with job arm k replaced by arm 0's play (its job rules and q kept)
for _k, _n in ((3, 'economy'), (4, 'punish'), (5, 'kessa')):
    C['s-' + _n] = ([a if i != _k else ARMSB[0].replace(':i6-all', f':i6-s{_k}', 1) for i, a in enumerate(ARMSB)], T0Q, [(UNIT0, UNIT1)])


def main():
    os.makedirs(OUT, exist_ok=True)
    if sys.argv[1:] == ['final']:   # the installed table's source (strategy.lisp :t0-ih-ichigo)
        tab.write(BASE, os.path.join(HERE, 'ih/t0-ih-ichigo.lisp'), ':t0-ih-ichigo', FINAL4, Q4, subs=[(UNIT0, UNIT1)],
                  note="p9-ih's IH Ichigo table (= candidate g1d): arms5's T0 job map and q for arms 0 / economy / punish / kessa-lunge (answer "
                       "and brawl dropped: under the new unit they play as arm 0), arm 0 = a4-i-brawl, economy and punish on its neutral "
                       "(:i6-economy, :i6-punish), the unit :d-x-ih-i with the clash on")
        return
    names = sys.argv[1:] or list(C)
    for n in names:
        arms, q, *subs = C[n]
        tab.write(BASE, os.path.join(OUT, n + '.lisp'), ':' + 'i6-' + n, arms, q, note=n, subs=subs[0] if subs else ())
        print(n, len(arms))


if __name__ == '__main__':
    main()

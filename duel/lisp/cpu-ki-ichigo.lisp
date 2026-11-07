;;;; cpu-ki-ichigo.lisp — the KI matchup style CPU: Ichigo against Kenpachi (docs/duel/DUEL_MATCHUP_AI.md §4–§5; the means and their
;;;; trials: docs/research/ki-ai/ichigo/means.md, catalogue.md). Registered by CAI-DEFSTYLE: it runs before the generic core CPU on
;;;; every free step and returns T when it decided, NIL to leave the step to the generic CPU (core-ai.lisp).
;;;;
;;;; Each neutral episode (a stretch of :idle / :run) rolls ONE mode from *IKS-MIX* by difficulty: :generic (the shipped CPU plays the
;;;; episode), or one of the four styles the user chose (2026-11-06):
;;;;   :space  間合い管理   no exchange at 1.7–3.6 m: NS3a's lunge from his form's band (4–5 m sealed), NS1a on his walk-in under
;;;;                        pointer 1, else hover out of his reach
;;;;   :whiff  揮空反擊     hover just outside his reach and punish his whiff (the punish itself runs in every style mode)
;;;;   :ptr3   指針三狩魂   strings run to J5 + SP (AS3 writes pointer 3: a Soul Break there takes 5 Konpaku)
;;;;   :kessa  KESSA 強攻   awaken once the gauge is full at a free moment; in KESSA the chains at 2.8–3.4 m, NS3a's SA lunge
;;;;                        from 4.2 m, strings to AS3 (pointer 3 kept), to AS2 (+79, the red Kikon) when he is red
;;;; Pointer 3 is home (b2_a1): AS3 keeps it in both forms, the whiff confirm (b1_a0: a whiff SEEN through the delayed SNAP is
;;;; punished by the fastest of *IKS-PUNISHERS* that lands inside his recovery) pays there through NS3a, and pointer 2 backs off to
;;;; the Getsuga on each move of his (b0_a0's re-arm). Every style mode shares: no NS2 charge inside *IKS-NS2-MIN* (pointer 2: back off and shoot the Getsuga from *IKS-GETSUGA-MIN*,
;;;; where his run-in loses: R17 / R18), the whiff punish, the SA after a landed NS1a / NS3a, all segments of an AS, and the Kikon
;;;; held only when he is red and IKS-KIKON-VALUE says the Kikon is worth at least the Soul Break (a K.O., or pointer 2 against red: 3,
;;;; E14; pointer 1 / 3 take 1 and refill his Reishi, throwing away a 3 / 5 Konpaku Soul Break); against red a string runs to the
;;;; finisher (IKS-FINISH-TARGET), and at HARD the :generic episodes take the same Kikon rule (*IKS-GENERIC-KIKON*).
;;;; Rolls: the mode once per neutral episode, the punish once per his move start (SNAP-START), the steer / read / Kikon once per own
;;;; string or move; never per step. The opponent is read through the perceived SNAP S and distance D; his form (a visible fact, as
;;;; GAUGES-RED-P is) picks the band table. Every knob below is a plist by difficulty (EASY <= NORMAL <= HARD for the style chances);
;;;; the dream-rsi search tunes only these.
;;;; Round 2 (b1_a0, against Kenpachi's round-1 champion, 揮空反擊 first): at HARD the sealed form is patient (*IKS-PATIENT-FORMS*): every
;;;; style mode hovers at the whiff distance and attacks only through the whiff punish / confirm (no generic neutral starts, no walk-in,
;;;; no sealed lunge); her own whiffed NS stops instead of running into his dodge (*IKS-NS-STOP*); his attacks in reach are Hohoed into
;;;; the perfect window in both forms (*IKS-HOHO-P*, b3_a1's KESSA Hoho extended; the untimed generic Hoho off there) with a J1
;;;; follow-up; in his combo the breaker spends the full awakening gauge or a Burst (*IKS-BREAK-P*); no Hoho into a stale SNAP after
;;;; her Burst (*IKS-BURST-NO-HOHO*); KESSA's pointer-1 chains are gone (wait for his whiff there too).
;;;; Round 2, b1_a1: b1_a0's file + b3_a0's pieces (round 2, the KESSA cell): his slide in the timed Hoho's reach, the follow-up window
;;;; 64 f and after any perfect Hoho, the wake-up Hoho against his meaty J1 (IKS-WAKE), b3_a1's read floor in KESSA, b0_a0's far
;;;; k-lunge for :space in KESSA pointer 3; the awakening neutral again, no breaker. New here: pointer 2 against his released forms waits
;;;; for his whiff instead of shooting the Getsuga into his lunge (*IKS-P2-WAIT*), and the meaty J1 on his wake-up (IKS-MEATY).
;;;; Round 3, b0_a0 (間合い管理 first): the shut-gauge lunge (IKS-GAP, *IKS-GAP-P*). His dodge picks the Hoho only if it is open as he
;;;; perceives her start, else the back Step only within 5.0 m; so while his Hoho is shut (his flash-step on the HUD, or his Hoho seen
;;;; within its lockout) she dashes out to 6.5 m, stands, and as he walks in lunges (NS3a, KESSA NS3a + SA) once his read of it comes
;;;; beyond 5.0 m and it still reaches him walking in (her SNAP is 8 frames old: his read comes 2 x 8 frames of his walk short of what
;;;; she sees). No dash while his move is live.
;;;; Round 3, b0_a1: the shut-gauge lunge made to fire. The dash-out only on a shut that lasts (*IKS-GAP-DASH-NEED*), not into his
;;;; Shikai lunge in KESSA (*IKS-GAP-DASH-HIS-FORMS*), and the lunge on her next free frame once she stands (*IKS-GAP-DASH-DT*: the
;;;; generic cadence let him walk through the band); the NS punish only within reach (*IKS-PUNISH-NS-REACH*); under b2_a0's bait hover
;;;; (*IKS-BAIT-HOVER*) with its k-SA dodge-stop and perceived reach, and b3_a0's k-SA floor.
(in-package :duel)

(defparameter *iks-mix* '(:easy (:generic 1.0)
                          :normal (:generic 0.88 :space 0.03 :whiff 0.03 :ptr3 0.03 :kessa 0.03)
                          :hard (:generic 0.04 :space 0.26 :whiff 0.26 :ptr3 0.28 :kessa 0.16))
  "The mode of a neutral episode, weights by difficulty (normalised): :generic leaves the episode to the shipped CPU. NORMAL stays
near the shipped CPU (its win share is the evaluator's NORMAL band); HARD is where the styles live (the user, 2026-11-06).")
(defparameter *iks-punish-p* '(:easy 0.0 :normal 0.5 :hard 0.9)
  "In a style mode: punish a perceived move of his that starts out of his reach (one roll per his move start).")
(defparameter *iks-his-reach* '(:base (:na 2.7 :ns 3.65) :nozarashi (:na 3.2 :ns 4.8))
  "His reach (m, centre to centre) by his form, J (NA) and NS: a move he starts beyond it whiffs (sealed J1 hits 2.4 / misses 2.7,
NS1a 3.3 / 3.6, NS3b 3.6 / 4.0; Shikai J1 3.0, NS1a 4.6: catalogue's range band). Another form: :nozarashi's.")
(defparameter *iks-punish-reach* '(3.4 0.0 5.0)
  "Her punisher's reach (m) by pointer against his J whiff: NS1a 3.4 (M29 at 3.2), none under 2 (a charge), NS3a 5.0 (R5).")
(defparameter *iks-punish-ns-reach* t
  "The whiff punish against his NS presses only within her punisher's reach (*IKS-PUNISH-REACH*), as against his J; else it waits
while his move lasts. Round 3 b0_a1: 24 of 28 NS punishes came at 6.6-7.0 m once *IKS-NS-WAIT* ran out (his NS started far, his slide
never brought him in), whiffed into NS-STOP and ate his Shikai lunge or his dodge.")
(defparameter *iks-confirm-p* '(:easy 0.0 :normal 0.1 :hard 0.95)
  "In a style mode: punish a whiff SEEN (his perceived move past its active frames with no contact, not a parry), once per his move
start, with the fastest punisher that reaches and lands inside his perceived recovery (*IKS-PUNISHERS*). Catches the whiffs the
start-time reach guess (*IKS-PUNISH-P*) passed as hits, and pointer 2 / KESSA, which that guess never covers (b1_a0, 2026-11-06;
grafted onto b2_a0's finisher by b2_a1, NORMAL 0.3 -> 0.1 there: NORMAL's share read 5 of 40 at 0.3, the band's edge is 5.5).")
(defparameter *iks-confirm-slack* 3
  "Frames her punisher's first hit may land after his perceived whiff recovery ends: his fastest answer, the sealed J1, is S6, so a hit
3 f after his recovery still can't be beaten (his move-end frame is read from the SNAP, the 8 f perception delay subtracted).")
(defparameter *iks-punishers*
  '(:base   ((:j 14 2.3 nil) (:ns1 22 3.4 nil) (:ns3 18 5.0 :lunge) (:ns2 29 3.5 :g-sa))
    :kessa  ((:j 8 1.9 nil) (:ns1 22 3.4 nil) (:ns3 29 4.2 :k-lunge) (:ns2 29 3.5 :g-sa)))
  "Whiff-confirm punishers by her form: (what first-hit-frame reach-m plan). :j = J1 (S14 / KESSA S8); :nsN = SP from neutral, only
under pointer N: NS1a S22 (3.4 m, M29), NS3a S18 (5.0 m, R5), KESSA NS3a + its SA 18 + 10 (4.2 m, R27), NS2a + the SA in its gap
20 + 8 (2.4 m arc + 1.4 slide; his whiff recovery can't punish the charge). The fastest one that fits is pressed (b1_a0).")
(defparameter *iks-confirm-walk* 0.06
  "Metres a frame her walk closes (4.2 m/s, a margin off): a confirm whose punisher is short of his recovering body by a little walks
in first when the frames still fit (pointer 1's NS1a against his NS1a / J1 whiffs ending at 3.5 m: 1 of 26 punished before).
0.001 (off): whiff 0.531, score 0.636 against 0.629 / 0.658 at 0.06 (40 seeds, b1_a0).")
(defparameter *iks-ns-wait* '(:easy 32 :normal 32 :hard 32)
  "Frames after his whiffing NS starts before the punish is pressed: earlier runs into his next segment (U6), f32 lands (U7).")
(defparameter *iks-hover* '(:base (3.7 4.2) :nozarashi (4.9 5.3))
  "The :whiff / :space hover band (m) by his form: just outside his NS reach, inside NS3a's 5.0 m.")
(defparameter *iks-hover-p1* '(:base (3.4 3.8) :nozarashi (4.9 5.3))
  "The :whiff / :space hover band (m) under pointer 1: her J-whiff punisher (NS1a) reaches only 3.4 m (*IKS-PUNISH-REACH*), so v0's
3.7-4.2 never let her punish his J whiff; 3.4-3.8 stays past his sealed NS1a (3.3 m). b0_a0 2026-11-06: new (v0 used *IKS-HOVER*).")
(defparameter *iks-bait-hover* '(:base (2.3 2.7) :nozarashi nil)
  "The hover band (m) by his form for the episodes of *IKS-BAIT-MODES* (NIL: *IKS-HOVER* / *IKS-HOVER-P1*): inside the distance his
sealed neutral starts its NS1a from (KK-REACH: 2.6 m) and just out of his J1's (1.9 m), so he commits to the NS1a (S14: seen 6 f before
its hit, inside the timed Hoho's lead window), which the timed Hoho turns into a perfect Hoho's counter, the follow-up's J string and
AS3. Round 3, b2_a0's bait hover (0.8517 rescored: the 3.4-4.2 m stand-off ended), grafted by b0_a1 under the shut-gauge lunge, which
still takes the step first while his Hoho is shut.")
(defparameter *iks-bait-modes* '(:easy nil :normal nil :hard (:whiff :ptr3 :kessa))
  "By difficulty, the style modes that hover at *IKS-BAIT-HOVER* (round 3, b2_a0). :space keeps *IKS-HOVER*.")
(defun iks-hover-band (b o mode table)
  "The hover band (lo hi) for this episode's MODE against O's form: *IKS-BAIT-HOVER* for *IKS-BAIT-MODES*, else TABLE's."
  (or (and (member mode (brain-chance b *iks-bait-modes*)) (iks-form-get *iks-bait-hover* o))
      (iks-form-get table o)))
(defparameter *iks-lunge-band* '(:base (4.0 5.0) :nozarashi (4.8 5.0))
  "Pointer 3: NS3a's lunge from this band (m) when he is not attacking (R5 / R25: only her NS3a reaches 4–5 m sealed; his Shikai
NS1a reaches 4.6, R15).")
(defparameter *iks-patient-forms* '(:base)
  "Her forms in which every style mode is patient (揮空反擊: wait for his whiff): it hovers at the whiff distance (*IKS-HOVER*,
*IKS-HOVER-P1*) and attacks only through the whiff punish / confirm, never hands the episode to the generic CPU (*IKS-WAIT-MAX*), no
walk-in NS1a. :ptr3 and a :kessa episode before the gauge is full hover too (v0 gave both the generic neutral). Round 2, b1_a0: in the
sealed form against this Kenpachi her neutral starts lost their first hits (20 seeds a seat: the generic's NS from :whiff episodes 7
hers / 71 his, from :ptr3 26 / 57, walk-in 6 / 33) while the confirm's J won 51 / 2; in KESSA the generic's starts are about even
(100 / 85), and hovering in KESSA lost its ledger in round 1 (b3_a0 v1d, b3_a1), so KESSA keeps v0's play.")
(defparameter *iks-patient-lunge* nil
  "A patient form's :space episodes still lunge (NS3a from *IKS-LUNGE-BAND* at pointer 3). NIL (round 2, b1_a0): the sealed lunge
lost its first hits 12 hers / 52 his against this Kenpachi (his Hoho / back Step through it, KK-READ), the 4-5 m band now comes from
the whiff confirm's NS3a (5.0 m) instead. Round 2, b1_a1: T again on b3_a0's pieces, paired seeds 1-20 a seat: spacing 0.063 -> 0.102,
whiff 0.903 -> 0.857, HARD 38 -> 37 of 40, raw 0.7596 -> 0.7485; kept NIL.")
(defparameter *iks-patient-p* '(:easy nil :normal nil :hard t)
  "*IKS-PATIENT-FORMS* applies at this difficulty (HARD only: at NORMAL it lifted the NORMAL share to 6 of 40, past the band's 5.5).")
(defparameter *iks-ns-stop* '(:easy nil :normal nil :hard t)
  "In a style mode's own NS (one with hits of its own; not KESSA's clone segments or the Getsuga's charges): the next segment waits
for the segment's contact, and a whiff stops the route there. Round 2, b1_a0: the generic CPU pressed the next segment on its first
active frame, hit or not, so a whiff confirm's NS1a that came up short ran on into NS1b, which his dodge (the Hoho, often perfect: 60
and a 40 f lock) and back Step answered: the confirm's walk-in lost 12 hers / 51 his first hits. His own style stops his whiffed NS
(KK-NS-WHIFF) for the same reason.")
(defparameter *iks-walkin-band* nil
  "Pointer 1, :space: NS1a when he walks into this band (T14 / T15: her NS1a at 3.4 m catches his walk-in); NIL: none. v0 (2.9 3.4) ->
NIL (round 2, b1_a0): it lost its first hits 20 hers / 61 his against this Kenpachi (his read and dodge; in KESSA 4 / 13 once the
sealed form stopped using it).")
(defparameter *iks-wait-max* '(:easy 0 :normal 90 :hard 150)
  "Frames a style mode may hover / back off in one neutral episode before it hands the episode to the generic CPU (no stalling).")
(defparameter *iks-ns2-min* 3.6 "Pointer 2: no NS2 charge inside this distance (M13 / M14: his J1 > AS1 or NS1a punishes the charge).")
(defparameter *iks-getsuga-min* 7.5 "Pointer 2: the Getsuga from this distance on (R17 / R18 / M16: his run-in loses).")
(defparameter *iks-retreat-to* 8.2 "Pointer 2: the back dash's target distance (m) to get the Getsuga's range.")
(defparameter *iks-retreat-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Pointer 2 out of J reach and inside the Getsuga's range: back dash to *IKS-RETREAT-TO* (one roll per neutral episode, or per his
move with *IKS-RETREAT-REARM*). HARD 0.8 -> 1.0 (b0_a0).")
(defparameter *iks-retreat-rearm* t
  "Pointer 2 in the middle band: each move of his he starts re-arms the back dash's roll (*IKS-RETREAT-P*), not only the episode's
start. b0_a0 2026-11-06: NIL -> T (v0's one roll an episode left her walking back at 2.3-3.6 m while his Shikai kamae (KE-S-N2A) came
again and again: 15 whiffs of his in 900 frames with no answer, since pointer 2 has no punisher).")
(defparameter *iks-p2-wait* '(:easy nil :normal nil :hard t)
  "By difficulty: pointer 2 against his released forms (any but *IKS-GETSUGA-HIS-FORMS*) shoots no Getsuga and backs off no more: out of
her J reach it hovers at his form's whiff distance (*IKS-HOVER*) and waits for his whiff (the confirm's J / NS2a + SA) or his attack
(the timed Hoho). Round 2, b1_a1: the Getsuga route was the opener of his biggest share of combos on her (b1_a0 + b3_a0's pieces, 20
seeds a seat: 44 combos, 14.2k, from pointer 2's Getsuga in both forms, all but a few KE-S-N1A, his Shikai lunge landing on the charge:
his 破月牙 answers it from 7-12 m by Hohoing in, KK-WAVE-PLAN).")
(defparameter *iks-getsuga-his-forms* '(:base) "His forms against which pointer 2 still shoots the Getsuga (*IKS-P2-WAIT*).")
(defparameter *iks-j-reach* 2.3 "Her J1's reach (m): pointer 2 inside it opens a J string instead of a charge (A13 2.4 hits, R6 2.6 misses).")
(defparameter *iks-shot-gap* 80 "Steps before the next decision after a Getsuga (as *CAI-RANGED-GAP*: the wave is not spammed).")
(defparameter *iks-steer-p* '(:easy 0.0 :normal 0.6 :hard 0.95)
  "A string in a style mode runs to the mode's AS (J5 + SP = AS3, KESSA AS2) instead of the generic continue rolls (one roll per string).")
(defparameter *iks-read-p* '(:easy 1.0 :normal 1.0 :hard 1.0)
  "A steered string still takes the AS read when he is seen in an NS (AS beats NS; it writes AS1 / AS2: pointer 3 lost). One roll per link.")
(defparameter *iks-kessa-read-min* '(:easy 1 :normal 1 :hard 2)
  "KESSA: a steered string takes the AS read (*IKS-READ-P*) only when the AS it would start is at least this (1: always, as v0; 2: never
AS1, so the read never writes pointer 1). Round 1's b3_a1 (1 -> 2, HARD 100 seeds a seat: kessa 131 -> 143 of 200); grafted by round 2's
b0_a0 / b3_a0 and here (b1_a1).")
(defparameter *iks-kessa-as* '(5 3)
  "KESSA: the attack presses a steered string runs to before its SP, (not-red red) by his Reishi at the string's first link (3: J1–J3 /
NS1a SA J2 J3 + SP = AS2, +79 at 4.8 m, K3 / K6, a red pointer-2 Kikon takes 4; 5: AS3, pointer 3 for the NS3a whiff punish and the
5-Konpaku Soul Break). Was 3 always: KESSA then sat at pointer 2, which has no fast punisher (b1_a0; b3_a0 chose 5 too).")
(defparameter *iks-kikon-p* '(:easy 0.0 :normal 0.6 :hard 0.95)
  "A style mode's SP held into a Kikon when he is red and IKS-KIKON-VALUE is :ko or :even (one roll per SP); never
when he is not red (a non-red Kenpachi cancels the follow-up: E12 / E15).")
(defparameter *iks-generic-kikon* '(:easy nil :normal nil :hard t)
  "A :generic episode's SP (the shipped CPU's, CAI-SP) takes the style's Kikon rule (IKS-SP-FRAMES): never held against a non-red
Kenpachi (he cancels it: E12 / E15, and the follow-up is a lost pointer-3 situation), against red by IKS-KIKON-VALUE. Off below HARD so NORMAL stays the shipped CPU (b2_a0, 2026-11-06).")
(defparameter *iks-kikon-costly-p* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "Against red, an SP whose Kikon takes less than the Soul Break it would cash and does not K.O. him (pointer 1 / 3: 1 Konpaku, 2 in
KESSA): held anyway with this chance (one roll per SP). The Kikon is a pointer-3 success, the Soul Break below 5 a failure, but the
Kikon refills his Reishi with fewer Konpaku taken (b2_a0, 2026-11-06).")
(defparameter *iks-finish-steer* t
  "Against red, a style mode's string runs to the finisher (IKS-FINISH-TARGET) whatever its steer roll: AS2 held when its red Kikon
(3, KESSA 4) K.O.s him, AS3 tapped when its Soul Break takes 5 (his Konpaku >= 5) (b2_a0, 2026-11-06).")
(defparameter *iks-awaken-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  ":kessa mode: awaken once the gauge is full and he is not attacking within reach (one roll per neutral episode).")
(defparameter *iks-awaken-modes* '(:space :whiff :ptr3 :kessa)
  "The style modes whose episode takes the awaken roll (*IKS-AWAKEN-P*) once the gauge is full (v0: :kessa only; b2_a0, 2026-11-06:
every style mode, so the full gauge is not left waiting for a :kessa episode).")
(defparameter *iks-kessa-chain-band* nil
  "KESSA pointer 1, a :kessa episode: the chains (NS1) from this band (K5, R8 3.4 hits, R9 3.8 misses); NIL: hover in *IKS-HOVER-P1* and
wait for his whiff. v0 (2.8 3.4) -> NIL (round 2, b1_a0): the chains lost their first hits 7 hers / 13 his, 10 / 37 before the
sealed-form changes, against this Kenpachi's read and dodge.")
(defparameter *iks-kessa-lunge-band* '(5.05 5.5)
  "KESSA pointer 3, the modes of *IKS-KESSA-SPACE-MODES*: NS3a then its SA's 3 m lunge from this band (m, the projected distance,
IKS-PROJ). The SA starts on NS3a's f18 where NS3a started, so the hit counts as one from >= 4 m; it lands from 4.2 to 5.6 m (round 2
b0_a0's trials X1-X5.8), beyond his back Step's *KK-STEP-MAX* 5.0. Round 2's b0_a0 (3.6-4.3 -> 5.05-5.5), :space only as in b3_a0.")
(defparameter *iks-kessa-space-modes* '(:easy nil :normal nil :hard (:space))
  "By difficulty, the style modes whose KESSA pointer-3 neutral is the far k-lunge (*IKS-KESSA-LUNGE-BAND*). Round 2's b3_a0: all four
modes 0.5632 against :space only 0.7271 (20 seeds a seat). HARD only.")
(defparameter *iks-kessa-near-band* '(3.6 4.3)
  "KESSA pointer 3, a :kessa episode: NS3a then its SA from this band (v0's k-lunge band, R27: hits from 4.2 m; kept by b3_a0).")
(defparameter *iks-k-sa-reach* 5.7
  "KESSA NS3a's SA is pressed in its gap while the distance is under this (m): the SA's 2.6 m arc + 3.0 m slide lands from 5.6 m
(trial X5.6). Was 4.6 (round 2, b0_a0; kept by b3_a0).")
(defparameter *iks-k-sa-perceived* t
  "The k-lunge's SA reach tests (*IKS-K-SA-REACH*, *IKS-K-SA-MIN*) read the perceived distance the style is given, not her true
FIGHTER-DIST (the rule: the opponent only through the SNAP and that distance). Round 3, b2_a0's fix, grafted by b0_a1.")
(defparameter *iks-k-sa-dodge-stop* t
  "KESSA pointer 3: the k-lunge's SA is not pressed while his perceived state is a Hoho or a Step (his dodge of the NS3a: KK-READ's
Hoho puts him 1.6 m behind her, the back Step 2.5 m away); the NS3a ends there and the neutral's timed Hoho takes over (round 3, b2_a0's
located bug: 21 SAs after a dodge, his hit first 8 times, hers 2). Grafted by b0_a1: the shut-gauge lunge's KESSA form is this k-lunge.")
(defparameter *iks-k-sa-min* 2.0
  "KESSA NS3a's SA (the k-lunge) is pressed only from this distance (m) on: under it he has Hohoed through her clone and the SA lunges
past him (round 3, b3_a0: SAs under 2.0 m, first hit hers 15 / his 15 / none 31; from 2.0 m on 26 / 9). Grafted by b0_a1.")
(defparameter *iks-lead-vmax* 0.07
  "IKS-PROJ: the perceived distance's change a step is clamped to this (m; a walk is 0.06-0.07 a step) before it is projected over
her perception delay.")

(defparameter *iks-burst-no-hoho* '(:easy nil :normal nil :hard t)
  "While her Burst's invulnerability runs (FIGHTER-INVULN, her own state), the generic Hoho roll is off (BRAIN-HOHO-ROLL 1). A located
bug (round 2, b1_a0): the Burst ends his move and pushes him 5 m off, but her SNAP is 8 f old and still shows his attack live in
reach, so the generic CPU's Hoho fired about 10 f after the Burst and put her 1.6 m behind a free Kenpachi, who J1'd her (6 of the
first 8 Bursts of the baseline's seat-1 log). Off below HARD (NORMAL stays the shipped CPU).")

(defparameter *iks-break-p* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "In his combo (her :stun / :air past *BURST-MIN-HITS*, no Kikon lock, after her perception delay, as the generic burst roll): break
out, one roll per combo: the awakening when its gauge is full (AWAKEN-STATE-P: no flash-step needed, it repels him as a Burst does, heals
20 % and enters KESSA: the KESSA 強攻 entry), else the Burst once the flash-step allows it (*FS-BURST*). The generic CPU rolls its Burst
once per combo, on the first eligible step, even when the flash-step is short then (the roll is spent); his flash-step gain from damage
(*FS-TAKEN*) often fills it later in the same combo. Every combo of his ends in a knockdown, and each knockdown starts his meaty J1
loop (KK-MEATY-STEP: J1 on her first free frame, unescapable on wake-up), 40 % of his damage in the baseline's logs. Round 2, b1_a0:
the last file without it (the neutral awakening back), 40 seeds a seat, HARD raw 0.5596 / 53 of 80 against 0.5691 / 54 with it.
Round 2, b1_a1: HARD 1.0 -> 0 (the generic CPU's Burst roll again). On b3_a0's pieces it is neutral: seeds 1-40 a seat, HARD raw
0.773 (79/80, kessa 43/80) with it in both forms, 0.777 (77/80, kessa 50/78) without; in the sealed form only 0.755; on the final file
seeds 1-20 0.8366 with it against 0.8387 without.")
(defparameter *iks-break-awaken* nil
  "The breaker (*IKS-BREAK-P*) spends a full awakening gauge to break his combo (and the neutral awakening of *IKS-AWAKEN-MODES* waits
for it). T -> NIL (round 2, b1_a1, on b3_a0's pieces, paired seeds 1-20 a seat: 0.7354 / 38 of 40 -> 0.7637 / 40 of 40): the awakening is
neutral again, at a free moment in every style mode (b2_a0's rule), so KESSA starts with the wake-up Hoho, the follow-up and the timed
Hoho in hand rather than in his combo.")

(defparameter *iks-hoho-p* '(:easy 0.0 :normal 0.0 :hard 0.9)
  "A style mode in neutral, in her forms *IKS-HOHO-FORMS*: Hoho his perceived attack (NA / NS / SA / AS) coming in reach when its first
active frame, as seen, is *IKS-HOHO-LEAD* away (one roll per his move start), with flash-step to spare (AI-HOHO-SPARE-P): most are
perfect Hohos (her counter 60 lands in his whiffed move's recovery: a 揮空反擊 success), then the follow-up (*IKS-HOHO-FOLLOW*). b3_a1's
KESSA Hoho (round 1, KESSA only, NORMAL 0.1), extended to the sealed form (b3_a1's named follow-up); NORMAL 0 here so NORMAL stays the
shipped CPU. Round 2, b1_a0: 40 seeds a seat, HARD raw 0.4692 (38/80, whiff 0.702) -> 0.5691 (54/80, whiff 0.807).")
(defparameter *iks-hoho-forms* '(:base :kessa) "Her forms that take the timed Hoho (*IKS-HOHO-P*).")
(defparameter *iks-untimed-hoho* t
  "In a style mode in *IKS-HOHO-FORMS* where the timed Hoho runs: the generic CPU's untimed Hoho roll (*CAI-HOHO-P*, pressed as soon
as his attack is live in reach, mostly not perfect) still runs too. NIL: only the timed one (round 2 b1_a0, 40 seeds a seat, HARD raw
0.5691 / 54 of 80 with it, 0.584 / 58 without). NIL -> T (round 2, b1_a1): with b3_a0's any-perfect follow-up its perfect Hohos feed
the follow-up too, and b3_a0 measured it off as a loss twice (v5a, v9); here, paired seeds 1-20 a seat, NIL 0.7273 (37/40), T 0.7354
(38/40).")
(defparameter *iks-hoho-lead* '(1 6)
  "Frames (lo hi) from now to his perceived move's first active frame (SNAP-LEAD-SEEN) in which the timed Hoho is pressed: inside
*PERFECT-LEAD* 12 and the Hoho's iframes f1-14 (b3_a1's window, chosen at 100 seeds a seat in KESSA: (1 6) over (1 10) (2 8) (3 8)
(5 11)).")
(defparameter *iks-hoho-slide* t
  "The timed Hoho's reach test adds his move's slide to its reach: his Shikai NS1a TOSSHIN (reach 2.6 + slide 3.0) lunges from 3.6-5.6
m and was never Hoho'd there (round 2, b3_a0: NIL -> T, paired 20 seeds a seat 0.5264 -> 0.5814).")
(defparameter *iks-hoho-follow* 64
  "Frames after her Hoho in which the follow-up may start (his recovery or reeling, seen). 40 -> 64 (round 2, b3_a0): a perfect Hoho's
counter lands at about +32 with 36 f of hitstun and the SNAP shows it 8 f later, so at 40 the window closed as his reeling came into
view (21 follow-ups after 132 counters in KESSA, 20 seeds a seat).")
(defparameter *iks-follow-any-perfect* '(:easy nil :normal nil :hard t)
  "The follow-up (IKS-HOHO-FOLLOW) also runs after a perfect Hoho the style did not press (the generic CPU's untimed one, the wake-up
Hoho), read from her own fighter's PERFECT flag while she is in the Hoho. Round 2, b3_a0 (20 seeds a seat 0.687 -> 0.7246). HARD only.")
(defparameter *iks-wake-hoho-p* '(:easy 0.0 :normal 0.0 :hard 0.9)
  "On her first free frame after a wake-up, him within *IKS-WAKE-HOHO-NEAR*: Hoho at once (one roll per wake-up), against his meaty J1.
His J1 still lands on that frame mostly, but the Hoho is perfect, so his inputs lock 40 f and his string stops at the J1 (round 2,
b3_a0: the meaty loop 89k -> 43k; paired 20 seeds a seat 0.4223 -> 0.5264).")
(defparameter *iks-wake-hoho-near* 2.2 "The wake-up Hoho's distance (m): his sealed J1 reaches 1.8 m, his meaty chase waits at 1.4.")
(defparameter *iks-wake-hoho-forms* '(:base :kessa) "Her forms in which the wake-up Hoho is rolled.")
(defparameter *iks-meaty-p* '(:easy 0.0 :normal 0.0 :hard 0.9)
  "His knockdown, seen (one roll as he goes down): stay in and press J1 so its first active frame lands on his first free frame (his
wake-up is invulnerable, the frame after it is not, and he cannot act before it: his own meaty J1 on her, K1, is the loop she could not
escape). Then the string runs to AS3 as the follow-up's (pointer 3 kept; his knockdown again). Round 2, b1_a1: new. After her AS3's
knockdown (+46 at 1.8 m) the patient form walked back to its hover, into his Shikai lunge's 5.6 m, and his first move on waking opened
the largest share of his combos left (b1_a0 + b3_a0's pieces + *IKS-P2-WAIT*, 20 seeds a seat: KE-S-N1A after her AS3C, 26 combos).")
(defparameter *iks-meaty-forms* '(:base :kessa) "Her forms that take the meaty J1 (*IKS-MEATY-P*).")
(defparameter *iks-meaty-lead* 0
  "The meaty J1 is pressed when his perceived frames to his first free one are her J1's startup + this (0: its first active frame on
it), as his KK-MEATY-STEP.")
(defparameter *iks-meaty-near* 1.4 "The meaty walks in to this distance (m) while he is down (her sealed J1 reaches 2.3 m, KESSA's 1.9).")
(defparameter *iks-meaty-space-skip* t
  "T: a KESSA pointer-3 episode of a mode in *IKS-KESSA-SPACE-MODES* skips the meaty and plays its far k-lunge (the spacing theme's one
working source: KESSA pointer 3 held 31 of the 35 spacing successes before the meaty, 20 seeds a seat).")
(defparameter *iks-meaty-far* 3.0 "The meaty is rolled only when he goes down within this distance (m); farther, the style plays on.")
(defparameter *iks-hoho-j-reach* 1.5 "The follow-up: J1 from within this (m), walking in first (b3_a1).")
(defparameter *iks-gap-p* '(:easy 0.0 :normal 0.0 :hard 0.9)
  "間合い管理, the shut-gauge lunge (round 3, b0_a0): one roll per neutral episode (any style mode, both forms, pointer 3). While his Hoho
is shut (IKS-HIS-HOHO-SHUT-P: his flash-step gauge, drawn on the HUD as GAUGES-RED-P's bar is, under one Hoho outside a Burst, or his
Hoho seen within its lockout) she dashes out to *IKS-GAP-WAIT*, stands, and as he walks in lunges once his read of it comes beyond his
back Step (IKS-GAP). His dodge (KK-READ) picks its answer as he perceives her start: the Hoho only if it is open then, else the back
Step only within *KK-STEP-MAX* 5.0 m; beyond it, with the Hoho shut, her lunge has no answer. The located cause of the sealed lunge's
losses (round 2 b1_a0: 12 hers / 52 his first hits, his Hoho / back Step through it). NORMAL 0: NORMAL stays the shipped CPU.")
(defparameter *iks-gap-band* '(:base (5.25 5.1 18) :kessa (5.25 5.6 28))
  "The shut-gauge lunge by her form: (lo hi hit-frame). Seen walking in C a step, she starts when his read distance (her perceived D
less 2 C x delay: his position as he perceives her start, against her position at that start) is over LO (his back Step answers
within 5.0: at 5.03 his reads came at 5.0, so 5.25) and the true distance (D less C x delay) within HI, her reach against a standing
target, plus his approach over HIT-FRAME (he walks into the lunge). Sealed NS3a hits from 5.1 m, misses at 5.2 (trials S5.1 / S5.2,
round 3), first hit f18; KESSA NS3a + its SA lands to 5.6 (round 2 b0_a0's X5.6), the SA's hit about f28.")
(defparameter *iks-gap-cmin* 0.05
  "The shut-gauge lunge starts only while he is seen walking in at least this fast (m a step, IKS-CLOSING): her SNAP is 8 frames old,
and a walk he began inside those frames reads as standing (round 3, b0_a0's first try: lunges from a perceived 5.05-5.1 m met his read
at 3.8-3.9 m, his back Step). Seen walking in, he keeps walking into the lunge after his read.")
(defparameter *iks-gap-wait* 6.5
  "The shut-gauge lunge: she backs off to this distance (m, perceived) and stands, so his walk-in is seen before he reaches the band
(seen walking in at 0.07 m a step, the band is a perceived 6.15-6.9 m sealed, 6.15-8.1 in KESSA).")
(defparameter *iks-gap-dash-over* 0.3
  "The shut-gauge lunge backs off by a dash to *IKS-GAP-WAIT* plus this (m): a walk back never opens the gap, he follows at her pace
(round 3 b0_a0's second try: 150 frames at a perceived 3.6-3.9 m, him walking in behind her).")
(defparameter *iks-gap-max* 150
  "The shut-gauge lunge: frames of one neutral episode it may spend backing off and waiting (no stalling: then the patient play).")
(defparameter *iks-gap-fs* 96.0
  "His Hoho counts as shut while his flash-step is under this (a Hoho costs *FS-HOHO* 100; he refills 9 a second, about 3 over the
frames until he perceives her start).")
(defparameter *iks-gap-lockout* 48
  "His Hoho counts as shut this many frames from the start of his last Hoho seen (*HOHO-LOCKOUT* 60 less his perception delay 8 and a
margin).")
(defparameter *iks-gap-dash-need* 90
  "The shut-gauge lunge dashes out only while his Hoho stays shut at least this many more frames (IKS-HIS-SHUT-LEFT: his flash-step's
climb back to *IKS-GAP-FS* at *FS-REGEN*, or his lockout's end); the lunge itself still fires on any shut. Round 3 b0_a1: of 161 spacing
situations with a dash, 122 saw no lunge (15 ok); most dashes came at a flash-step of 91-95 (reopened within 0.3 s) or on the lockout
alone (48 f, shorter than the dash), and the dash carried her across 4-5 m for nothing.")
(defparameter *iks-gap-dash-dt* 1
  "Frames before the next own decision after the shut-gauge lunge's dash-out (NIL: the generic cadence, *CAI-THINK* + up to 12). The
lunge is the same plan's next press: with the generic cadence (22-34 frames at HARD, counted only once she stands) he walked through
the 0.55 m lunge band (8 frames at his 0.07 m a step) before she could press, she found him inside it and dashed out again (round 3
b0_a1: 417 dash-outs and 105 lunges in 40 HARD matches, runs of three dashes at a perceived 6.3 m). The lunge still waits until she
stands (FIGHTER-STATE :idle): out of her own dash-out's run its carry is away from him.")
(defparameter *iks-gap-dash-his-forms* '(:base (:base :nozarashi :bankai :bankai-2) :kessa (:base :bankai :bankai-2))
  "By her form, his forms the shut-gauge lunge dashes out against. His Shikai lunge KE-S-N1A (2.6 + 3.0 m slide) catches the dash's step
from 5.6 m; in KESSA that damage is the KESSA ledger's (round 3 b0_a1, paired 20 seeds a seat: dashing against his Shikai in both forms
spacing 0.237, kessa 0.725; in neither 0.170, 0.925).")

(defstruct (ikst (:constructor make-ikst ()))
  "Ichigo's KI style state (BRAIN-STYLE)."
  (mode :generic)                       ; this neutral episode's mode
  (ep-t 0 :type fixnum)                 ; frames in this episode
  (last-st nil)                         ; her state at the previous call
  (last-reishi 0 :type fixnum)          ; her Reishi then (a hit starts a new episode)
  (dt 0 :type fixnum)                   ; frames to the next own decision
  (retreat nil)                         ; this episode's retreat roll was made (T) / it said go (:go)
  (awaken nil)                          ; this episode's awaken roll: NIL unmade, :go, :no
  (pkey -1 :type fixnum) (punish nil)   ; his move start the punish roll is for; :go / :no / :done
  (ckey -1 :type fixnum)                ; his move start the whiff-confirm roll was made for
  (pend nil) (pend-until 0 :type fixnum) ; a confirm walking in first: its punisher entry, the last tick to press it
  (rkey -1 :type fixnum)                ; his move start the retreat roll was re-armed for (*IKS-RETREAT-REARM*)
  (plan nil)                            ; what the move she started is for: :shot :lunge :k-lunge, NIL
  (skey -1 :type fixnum) (steer nil)    ; the string's first link start; the press count it runs to (NIL: generic)
  (brk nil)                             ; this combo's breaker roll: NIL unmade, :go, :no
  (hkey -1 :type fixnum) (hoho nil)     ; his move start the timed Hoho roll is for; its result (T: Hoho it)
  (hoho-t -1 :type fixnum)              ; the tick of her last timed Hoho (-1: none, or its follow-up done)
  (mode-mv :generic)                    ; the mode of the episode her move in progress started from
  (last-d 0f0)                          ; the perceived distance at the previous call (IKS-PROJ)
  (down nil) (meaty nil)                ; his knockdown seen (its roll made); the meaty roll's result (T: go)
  (gap nil) (gap-t 0 :type fixnum)      ; this episode's shut-gauge lunge roll: NIL unmade, :go, :no; frames spent on it
  (his-hoho -999 :type fixnum))
(inline-readers ikst)         ; the start tick of his last Hoho seen (IKS-HIS-HOHO-SHUT-P)

(defun iks-pick (plist r)
  "The key of weight plist PLIST that roll R in [0,1) falls on (weights normalised)."
  (let ((sum (loop for (nil w) on plist by #'cddr sum w)) (acc 0.0))
    (loop for (k w) on plist by #'cddr
          do (incf acc (/ w sum))
          when (< r acc) return k
          finally (return (car (last plist 2))))))

(defun iks-form-get (table o)
  "TABLE's entry for opponent O's form (his visible form), else :nozarashi's."
  (or (getf table (fighter-form (fighter o))) (getf table :nozarashi)))

(defun iks-log (e st action d)
  (clog "~a ki-style ~(~a~) ~(~a~) d ~,1f ptr ~d form ~(~a~)" (side-name e) (ikst-mode st) action d (fighter-ptr (fighter e))
        (fighter-form (fighter e))))

(defun iks-kikon-value (f profile)
  "Against red, what holding the SP of pointer PROFILE is worth against cashing its Soul Break: :ko (the red Kikon takes his last
Konpaku), :tap (the Soul Break takes 5: a pointer-3 kill with >= 5 left), :even (the Kikon takes what the Soul Break would: pointer 2),
:costly (it takes less and does not K.O.). His Konpaku pips and red are HUD facts (as GAUGES-RED-P); the counts are core.lisp's."
  (let* ((k (gauges-konpaku (gauges (fighter-opp f)))) (base (kit-kikon-konpaku (fighter-kit f)))
         (kn (core-kikon-count base profile t)) (sb (min k (core-soul-break-count base profile))))
    (cond ((>= kn k) :ko) ((>= sb 5) :tap) ((>= kn sb) :even) (t :costly))))

(defun iks-sp-frames (b f profile)
  "Frames to hold this SP (one roll per SP): never into a Kikon when he is not red (he cancels it: E12 / E15); against red by
IKS-KIKON-VALUE: held at :ko / :even (*IKS-KIKON-P*), tapped at :tap, :costly with *IKS-KIKON-COSTLY-P*. Held = 40, else a tap."
  (if (and (gauges-red-p (gauges (fighter-opp f)))
           (case (iks-kikon-value f profile)
             ((:ko :even) (brain-roll b *iks-kikon-p*))
             (:costly (brain-roll b *iks-kikon-costly-p*))
             (t nil)))
      40 1))

(defparameter *iks-finish-even* t
  "Against red with no K.O. and no 5-Konpaku Soul Break in reach (his Konpaku 4, the Shikai): the string still runs to AS2 held, a
red Kikon of 3 (a pointer-3 success) instead of AS3's capped Soul Break of 4 (a failure, but the K.O.) (b2_a0, 2026-11-06).")

(defun iks-finish-target (f)
  "Against red (*IKS-FINISH-STEER*): the press count a string runs to before its SP: 3 (AS2, held) when AS2's red Kikon K.O.s him, 5
(AS3, tapped) when AS3's Soul Break takes 5; else NIL (the string's own steer)."
  (when (and *iks-finish-steer* (gauges-red-p (gauges (fighter-opp f))))
    (let ((v2 (iks-kikon-value f 2)))
      (cond ((eq v2 :ko) 3)
            ((eq (iks-kikon-value f 3) :tap) 5)
            ((and *iks-finish-even* (eq v2 :even)) 3)))))

(defun iks-sp (e b f st action d &optional plan)
  "Press SP from neutral (the pointer's NS), tagged with PLAN (a :shot's charges are taps: a hold would let their gaps pass)."
  (setf (ikst-plan st) plan (brain-own-key b) -1)
  (iks-log e st action d)
  (cai-press b :quick (if (member plan '(:shot :g-sa)) 1 (iks-sp-frames b f (fighter-ptr f))) t)
  t)

(defun iks-j (e b st action d)
  "Press J from neutral (a string's J1)."
  (setf (ikst-plan st) nil (brain-own-key b) -1)
  (iks-log e st action d)
  (cai-press b :quick 1)
  t)

(defun iks-walk (e b vp d lo hi)
  "Walk toward the band LO..HI (strafing inside it) this step; T (decided)."
  (when (<= (decf (brain-strafe-t b)) 0) (funcall (ai-step e :strafe) e b))
  (funcall (ai-step e :walk) e b vp d lo hi)
  t)

(defun iks-new-episode-p (e st)
  "Does a new neutral episode start (she was not neutral at the last call, or she was hit since)?"
  (or (not (member (ikst-last-st st) '(:idle :run))) (< (gauges-reishi (gauges e)) (ikst-last-reishi st))))

(defun iks-punish (e b f st s d o)
  "The whiff punish (every style mode): his perceived move started out of his reach -> NS1a (pointer 1) / NS3a (3) at once against a
J, after *IKS-NS-WAIT* against an NS. One roll per his move start. T when pressed."
  (let ((oc (cai-class-of o s)))
    (or (when (and (member oc '(:na :ns)) (/= (fighter-ptr f) 2))
          (unless (= (ikst-pkey st) (snap-start s))
            (setf (ikst-pkey st) (snap-start s)
                  (ikst-punish st) (let ((reach (getf (iks-form-get *iks-his-reach* o) oc)))
                                     (if (and reach (> d reach) (brain-roll b *iks-punish-p*)) :go :no))))
          (when (and (eq (ikst-punish st) :go)
                     (if (eq oc :na)
                         (<= d (nth (1- (fighter-ptr f)) *iks-punish-reach*))   ; (his J's whiff: only within her punisher's reach)
                         (and (>= (- *match-tick* (snap-start s)) (brain-chance b *iks-ns-wait*))   ; (his NS's slide brings him in: M20)
                              (or (not *iks-punish-ns-reach*) (<= d (nth (1- (fighter-ptr f)) *iks-punish-reach*))))))
            (setf (ikst-punish st) :done)
            (iks-sp e b f st (if (eq oc :na) :punish-j :punish-ns) d (and (= (fighter-ptr f) 3) :lunge))))
        (iks-confirm e b f st s d oc))))

(defun iks-confirm (e b f st s d oc)
  "The whiff confirm (b1_a0): his perceived move (NA / NS / SA, not a parry) is past its active frames with no contact and still
recovering; once per his move start roll *IKS-CONFIRM-P*, then press the fastest of *IKS-PUNISHERS* that reaches D and lands inside
his recovery less the perception delay. T when pressed."
  (when (and (member oc '(:na :ns :sa)) (not (and (= (ikst-pkey st) (snap-start s)) (eq (ikst-punish st) :done)))
             (/= (ikst-ckey st) (snap-start s))
             (snap-recovering-p s) (null (snap-contact s)) (not (member :parry (snap-flags s))))
    (setf (ikst-ckey st) (snap-start s))
    (let ((left (+ (- (snap-left s) (brain-delay b)) *iks-confirm-slack*)) (ptr (fighter-ptr f)) (pick nil) (pick-t 0) (pick-w 0))
      (dolist (p (getf *iks-punishers* (if (eq (fighter-form f) :kessa) :kessa :base)))
        (destructuring-bind (what hit reach plan) p
          (declare (ignore plan))
          (let* ((walk (max 0 (ceiling (- d (- reach 0.1)) *iks-confirm-walk*))) (tot (+ hit 1 walk)))
            (when (and (<= tot left) (case what (:j t) (:ns1 (= ptr 1)) (:ns2 (= ptr 2)) (:ns3 (= ptr 3)))
                       (or (null pick) (< tot pick-t)))
              (setf pick p pick-t tot pick-w walk)))))
      (when (and pick (brain-roll b *iks-confirm-p*))
        (setf (ikst-pkey st) (snap-start s) (ikst-punish st) :done)
        (if (plusp pick-w)
            (progn (setf (ikst-pend st) pick (ikst-pend-until st) (+ *match-tick* pick-w 2))
                   (iks-log e st :confirm-walk d)
                   (iks-pend-step e b f st d))
            (iks-confirm-press e b f st d pick))))))

(defun iks-confirm-press (e b f st d pick)
  "Press the confirm's punisher PICK (a *IKS-PUNISHERS* entry). T."
  (setf (ikst-pend st) nil)
  (if (eq (first pick) :j)
      (iks-j e b st :confirm-j d)
      (iks-sp e b f st :confirm-sp d (fourth pick))))

(defun iks-pend-step (e b f st d)
  "A confirm walking in: press once inside the punisher's reach, walk on until the last tick, then drop it. T while it decides."
  (let ((pick (ikst-pend st)))
    (cond ((null pick) nil)
          ((<= d (- (third pick) 0.1)) (iks-confirm-press e b f st d pick))
          ((> *match-tick* (ikst-pend-until st)) (setf (ikst-pend st) nil))
          (t (funcall (ai-step e :walk) e b (pilot-vpad (pilot e)) d 0.0 (- (third pick) 0.2)) t))))

(defun iks-timed-hoho (e b st s d)
  "Hoho his perceived attack in reach, timed into the perfect-Hoho window (*IKS-HOHO-LEAD*). One roll per his move start. T when
pressed (b3_a1's IKS-KESSA-HOHO)."
  (when (and (member (cai-class-of (fighter-opp (fighter e)) s) '(:na :ns :sa :as)) (eq (snap-phase s) :main) (snap-live-p s)
             (or (snap-near-p s e d 1.0)
                 (and *iks-hoho-slide* (snap-move s) (< d (+ (snap-reach s) (mv-slide (snap-move s)) 1.0)))))
    (unless (= (ikst-hkey st) (snap-start s))
      (setf (ikst-hkey st) (snap-start s) (ikst-hoho st) (brain-roll b *iks-hoho-p*)))
    (let ((lead (snap-lead-seen s b)) (g (gauges e)))
      (when (and (ikst-hoho st) (<= (first *iks-hoho-lead*) lead (second *iks-hoho-lead*)) (hoho-open-p e)
                 (ai-hoho-spare-p (gauges-fs g) (gauges-reishi g) (gauges-reishi-max g)))
        (setf (ikst-hoho st) nil (ikst-hoho-t st) *match-tick*)
        (iks-log e st :hoho d)
        (ai-press b :step 1 :modded t :act :hoho)
        t))))

(defun iks-hoho-follow (e b st s d vp)
  "Just after her timed Hoho: J1 on his seen recovery / reeling from behind him (walk in to *IKS-HOHO-J-REACH* first). T when decided."
  (when (and (>= (ikst-hoho-t st) 0) (<= (- *match-tick* (ikst-hoho-t st)) *iks-hoho-follow*))
    (cond ((not (snap-punishable-p s)) nil)
          ((<= d *iks-hoho-j-reach*) (setf (ikst-hoho-t st) -1 (ikst-mode-mv st) :kessa) (iks-j e b st :hoho-j d))
          ((< d 3.0) (iks-walk e b vp d 0.0 *iks-hoho-j-reach*)))))

(defun iks-proj (b st d)
  "The perceived distance D projected over her perception delay by its change since the last call (clamped to *IKS-LEAD-VMAX* a step).
Only perceived distances are used (b0_a0)."
  (let ((v (max (- *iks-lead-vmax*) (min *iks-lead-vmax* (- d (ikst-last-d st))))))
    (+ d (* v (brain-delay b)))))

(defun iks-his-hoho-shut-p (o st)
  "Is opponent O's Hoho shut: his flash-step (HUD) under *IKS-GAP-FS*, or his last Hoho seen started within *IKS-GAP-LOCKOUT*?"
  (let ((g (gauges o)))
    (or (and (< (gauges-fs g) *iks-gap-fs*) (not (gauges-burst g)))   ; (a Burst's end gives the gauge back: B0 BURST END, then his Hoho)
        (< (- *match-tick* (ikst-his-hoho st)) *iks-gap-lockout*))))

(defun iks-his-shut-left (o st)
  "Frames his Hoho stays shut (IKS-HIS-HOHO-SHUT-P) at the least: the longer of his flash-step's climb to *IKS-GAP-FS* (0 in a Burst)
and his lockout's rest."
  (let ((g (gauges o)))
    (max (if (gauges-burst g) 0 (/ (- *iks-gap-fs* (gauges-fs g)) (/ *fs-regen* 60.0)))
         (- *iks-gap-lockout* (- *match-tick* (ikst-his-hoho st))))))

(defun iks-closing (e b d)
  "His perceived approach speed (m a step, toward her: positive), from the SNAP she sees now and the one a step older (both from her
brain's ring, so a held press in between does not blank it), measured from her own position now (her own walk is not in it), clamped
to -0.1..0.12."
  (let* ((ring (brain-ring b)) (n (length ring)) (q (svref ring (mod (- (brain-head b) (brain-delay b) 2) n))) (p (pos-of e)))
    (and q (< (+ (brain-delay b) 2) n)
         (max -0.1 (min 0.12 (- (sqrt (+ (expt (- (snap-x q) (aref p 0)) 2) (expt (- (snap-z q) (aref p 2)) 2))) d))))))

(defun iks-gap (e b f st s d vp)
  "The shut-gauge lunge (*IKS-GAP-P*): at pointer 3, his Hoho shut, the episode's roll said yes, for *IKS-GAP-MAX* frames. Her perceived D
is to his position BRAIN-DELAY steps ago; seen walking in C a step (*IKS-GAP-CMIN*), the true distance is D - C*delay and his read of
her start (another delay later) D - 2C*delay. So: back off to *IKS-GAP-WAIT* and stand; as he walks in, NS3a (KESSA: NS3a then its SA)
once his read comes beyond his back Step and the lunge still reaches him walking in (*IKS-GAP-BAND*). T when decided."
  (when (and (= (fighter-ptr f) 3) (iks-his-hoho-shut-p (fighter-opp f) st)
             (progn (unless (ikst-gap st) (setf (ikst-gap st) (if (brain-roll b *iks-gap-p*) :go :no) (ikst-gap-t st) 0))
                    (eq (ikst-gap st) :go))
             (<= (incf (ikst-gap-t st)) *iks-gap-max*))
    (let* ((kessa (eq (fighter-form f) :kessa)) (c0 (iks-closing e b d)) (c (or c0 0.0)) (dl (brain-delay b))
           (walking (and c0 (>= c *iks-gap-cmin*))))
      (destructuring-bind (lo hi hitf) (getf *iks-gap-band* (if kessa :kessa :base))
        (let ((plo (+ lo (* 2 c dl))) (phi (+ hi (* c (+ hitf dl)))))
          (cond ((and walking (member (snap-state s) '(:idle :run)) (< plo d) (<= d phi) (<= (ikst-dt st) 0)
                      (eq (fighter-state f) :idle))            ; (not out of her own dash-out's run: its carry is away from him)
                 (iks-sp e b f st :gap-lunge d (if kessa :k-lunge :lunge)))
                ((eq (snap-state s) :move) nil)                ; (his move live: no dash, the Hoho / punish / confirm keep it)
                ((< d (if walking plo *iks-gap-wait*))         ; (he follows a walk back at her pace: dash out, then stand)
                 (when (or (>= d *iks-gap-wait*)               ; (a shut about to reopen, or his form's lunge on the step: no dash,
                           (and (>= (iks-his-shut-left (fighter-opp f) st) *iks-gap-dash-need*)   ;  the patient play keeps the step)
                                (member (fighter-form (fighter (fighter-opp f)))
                                        (getf *iks-gap-dash-his-forms* (if kessa :kessa :base)))))
                   (iks-log e st :gap-dash d)
                   (ai-dash b -1 (+ *iks-gap-wait* *iks-gap-dash-over*))
                   (when *iks-gap-dash-dt* (setf (ikst-dt st) *iks-gap-dash-dt*))   ; (the lunge is this plan's own next press)
                   t))
                (t t)))))))                                   ; (out there: stand and let him come)

(defun iks-wake (e b f st d)
  "Her first free frame after a wake-up with him near (*IKS-WAKE-HOHO-NEAR*): the Hoho (one roll per wake-up, b3_a0). T when pressed."
  (when (and (<= d *iks-wake-hoho-near*) (member (fighter-form f) *iks-wake-hoho-forms*) (hoho-open-p e)
             (brain-roll b *iks-wake-hoho-p*))
    (iks-log e st :wake-hoho d)
    (ai-press b :step 1 :modded t :act :hoho)
    t))

(defun iks-meaty (e b f kit st s d)
  "His knockdown, the roll said yes: in to *IKS-MEATY-NEAR*, and J1 to land on his first free frame (as his KK-MEATY-STEP). T while it
decides."
  (when (and (ikst-meaty st) (member (snap-state s) '(:air :down :wakeup))
             (not (and *iks-meaty-space-skip* (eq (fighter-form f) :kessa) (= (fighter-ptr f) 3)
                       (member (ikst-mode st) (brain-chance b *iks-kessa-space-modes*)))))
    (let* ((q (kit-command-move kit :q)) (rf *reaction-frames*) (sf (+ (snap-sf s) (brain-delay b)))
           (left (case (snap-state s)
                   (:down (- (+ (getf rf :down 30) (getf rf :wakeup 30)) sf))
                   (:wakeup (- (getf rf :wakeup 30) sf))
                   (t 999))))
      (cond ((> d *iks-meaty-far*) (setf (ikst-meaty st) nil))   ; (he flew off: the style plays on)
            ((and q (<= left (+ (mv-s q) *iks-meaty-lead*)))
             (setf (ikst-meaty st) nil)
             (if (<= d (+ (mv-reach q) (mv-slide q)))
                 (progn (setf (ikst-mode-mv st) :kessa) (iks-j e b st :meaty-j d))
                 nil))
            ((> d *iks-meaty-near*) (vpad-stick! (pilot-vpad (pilot e)) 0f0 1f0) t)
            (t (vpad-stick! (pilot-vpad (pilot e)) 0f0 0f0) t)))))

(defun iks-pointer-2 (e b f st s d vp)
  "Pointer 2 (either form): the Getsuga from *IKS-GETSUGA-MIN*, a J string inside her J reach, no charge in between: back dash
(one roll per episode) or hover back. T when decided, NIL to hand over (the generic shoots from 3.6–6.6 m against a walk-in)."
  (cond ((and (getf *iks-p2-wait* (brain-difficulty b)) (> d *iks-j-reach*)
              (not (member (fighter-form (fighter (fighter-opp f))) *iks-getsuga-his-forms*)))   ; his released form: no Getsuga, wait
         (destructuring-bind (hlo hhi) (iks-form-get *iks-hover* (fighter-opp f)) (iks-walk e b vp d hlo hhi)))
        ((>= d *iks-getsuga-min*)
         (when (<= (ikst-dt st) 0)
           (setf (ikst-dt st) *iks-shot-gap*)
           (iks-sp e b f st :getsuga d :shot))
         t)
        ((<= d *iks-j-reach*)
         (if (<= (ikst-dt st) 0) (iks-j e b st :p2-j d) (iks-walk e b vp d 0.0 *iks-j-reach*)))
        (t (when (and *iks-retreat-rearm* (eq (snap-state s) :move) (/= (ikst-rkey st) (snap-start s)))   ; his move: a new roll
             (setf (ikst-rkey st) (snap-start s) (ikst-retreat st) nil))
           (unless (ikst-retreat st)
             (setf (ikst-retreat st) (if (brain-roll b *iks-retreat-p*) :go t)))
           (cond ((eq (ikst-retreat st) :go)
                  (setf (ikst-retreat st) t)
                  (iks-log e st :retreat d)
                  (ai-dash b -1 *iks-retreat-to*)
                  t)
                 ((< d *iks-ns2-min*) (iks-walk e b vp d *iks-ns2-min* *iks-getsuga-min*))   ; never charge in his face
                 (t nil)))))

(defun iks-neutral (e b f kit s d)
  "A style mode's neutral step. T when decided."
  (let* ((st (brain-style b)) (o (fighter-opp f)) (vp (pilot-vpad (pilot e))) (mode (ikst-mode st))
         (kessa (eq (fighter-form f) :kessa)) (ptr (fighter-ptr f)) (calm (member (snap-state s) '(:idle :run)))
         (patient (and (getf *iks-patient-p* (brain-difficulty b)) (member (fighter-form f) *iks-patient-forms*))))
    (declare (ignorable kit))
    (decf (ikst-dt st))
    (when (and (not *iks-untimed-hoho*) (member (fighter-form f) *iks-hoho-forms*) (plusp (brain-chance b *iks-hoho-p*)))
      (setf (brain-hoho-roll b) 1f0))                  ; (the generic's untimed Hoho off: only the timed one)
    (cond
      ((and (member (fighter-form f) *iks-hoho-forms*) (iks-timed-hoho e b st s d)))
      ((and (ikst-pend st) (iks-pend-step e b f st d)))
      ((iks-punish e b f st s d o))
      ;; his attack live and in reach: the generic's Hoho roll (the identical test) takes the step
      ((and (eq (snap-state s) :move) (plusp (snap-left s)) (< d (+ (snap-reach s) 1.0)) (hoho-open-p e)
            (< (brain-hoho-roll b) (brain-chance b *cai-hoho-p*)))
       nil)
      ;; KESSA: awaken once full at a free moment
      ((and (member mode *iks-awaken-modes*) (not (and *iks-break-awaken* (plusp (brain-chance b *iks-break-p*))))
            (gauges-awakened-ok-p e) (or calm (> d (+ (snap-reach s) 1.5)))
            (progn (unless (ikst-awaken st) (setf (ikst-awaken st) (if (brain-roll b *iks-awaken-p*) :go :no)))
                   (eq (ikst-awaken st) :go)))
       (setf (ikst-awaken st) :no)
       (iks-log e st :awaken d)
       (ai-press b :awaken 1 :modded t)
       t)
      ((= ptr 2) (iks-pointer-2 e b f st s d vp))               ; (before the wait's end: never a charge in his face)
      ((iks-gap e b f st s d vp))                               ; (pointer 3, his Hoho shut: the lunge beyond his back Step)
      ((and (> (ikst-ep-t st) (brain-chance b *iks-wait-max*)) (not patient)) nil)   ; waited long enough: the generic plays on
      ((and kessa (eq mode :kessa) (/= ptr 3) (null *iks-kessa-chain-band*))   ; (no chains: wait for his whiff)
       (if (< d 1.7) nil
           (destructuring-bind (hlo hhi) (iks-hover-band b o mode *iks-hover-p1*) (iks-walk e b vp d hlo hhi))))
      ((and kessa (= ptr 3) (member mode (brain-chance b *iks-kessa-space-modes*)))   ; KESSA pointer 3: the k-lunge beyond his back Step
       (destructuring-bind (clo chi) *iks-kessa-lunge-band*
         (if (and calm (<= clo (iks-proj b st d) chi) (<= (ikst-dt st) 0))
             (iks-sp e b f st :k-lunge d :k-lunge)
             (iks-walk e b vp d clo chi))))
      ((and kessa (eq mode :kessa))
       (destructuring-bind (clo chi) (if (= ptr 3) *iks-kessa-near-band* *iks-kessa-chain-band*)
         (cond ((and calm (<= clo d chi) (<= (ikst-dt st) 0))
                (iks-sp e b f st (if (= ptr 3) :k-lunge :k-chains) d (and (= ptr 3) :k-lunge)))
               ((> d 7.0) nil)
               (t (iks-walk e b vp d clo chi)))))
      ((and (eq mode :ptr3) (not patient)) nil)                ; neutral as the generic; the steering is in the move
      ((and (eq mode :kessa) (not kessa) (not patient)) nil)   ; (until full: as the generic)
      ((> d 7.0) nil)                                          ; the generic dashes in to 4.5 m
      ((and (eq mode :space) (= ptr 3) (or *iks-patient-lunge* (not patient)))
       (destructuring-bind (llo lhi) (iks-form-get *iks-lunge-band* o)
         (cond ((and calm (<= llo d lhi) (<= (ikst-dt st) 0)) (iks-sp e b f st :lunge d :lunge))
               ((< d 1.7) nil)                                 ; point-blank: the generic's J
               (t (iks-walk e b vp d llo lhi)))))
      ((and (eq mode :space) (= ptr 1) *iks-walkin-band* (not patient) (member (snap-state s) '(:idle :run))
            (<= (first *iks-walkin-band*) d (second *iks-walkin-band*)) (<= (ikst-dt st) 0))
       (iks-sp e b f st :walk-in d))
      ((or patient (member mode '(:space :whiff)))
       (if (< d 1.7) nil
           (destructuring-bind (hlo hhi) (iks-hover-band b o mode (if (= ptr 1) *iks-hover-p1* *iks-hover*)) (iks-walk e b vp d hlo hhi))))
      (t nil))))

(defun iks-move (e b f kit s d)
  "A style mode's step inside her own move (decides once per move, as CAI-MOVE-STEP: BRAIN-DECIDED). T when decided."
  (let* ((st (brain-style b)) (mv (fighter-move f)) (cls (fighter-cls f)) (o (fighter-opp f)) (oc (cai-class-of o s))
         (kessa (eq (fighter-form f) :kessa)))
    (when (and mv cls (/= (brain-decided b) (fighter-cls-t f)) (not (eq (ikst-mode-mv st) :generic)))
      (case cls
        ((:na :sa)
         (when (and (<= (fighter-presses f) 1) (/= (ikst-skey st) (fighter-cls-t f)))   ; a string's first link: its steer roll
           (setf (ikst-skey st) (fighter-cls-t f)
                 (ikst-steer st) (and (brain-roll b *iks-steer-p*)
                                      (if (and kessa (eq (ikst-mode-mv st) :kessa))
                                          (if (gauges-red-p (gauges o)) (second *iks-kessa-as*) (first *iks-kessa-as*))
                                          5))))
         (let ((to (or (iks-finish-target f) (ikst-steer st))))
          (when (and to (eq (fighter-contact f) :hit) (not (fighter-as-done f)))
           (setf (brain-decided b) (fighter-cls-t f))
           (cond ((or (>= (fighter-presses f) to) (>= (fighter-presses f) 5)
                      (and (eq oc :ns) (or (not kessa) (>= (core-next-as f) (getf *iks-kessa-read-min* (brain-difficulty b) 1)))
                           (brain-roll b *iks-read-p*)))
                  (let ((as (core-next-as f)))
                    (when (>= (fighter-presses f) 5) (clog "~a ki-style ~(~a~) as~d" (side-name e) (ikst-mode-mv st) as))
                    (cai-press b :quick (iks-sp-frames b f as) t)))
                 (t (cai-press b :quick 1)))
           t)))
        (:ns
         (when (>= (fighter-sf f) (mv-s mv))
           (cond ((and (getf *iks-ns-stop* (brain-difficulty b)) (plusp (length (mv-hits mv))) (plusp (mv-reach mv))
                       (null (fighter-contact f)) (mv-ns-next kit mv))   ; its own NS out, no contact yet: wait; a whiff stops here
                  (when (>= (fighter-sf f) (+ (mv-s mv) (mv-a mv)))
                    (setf (brain-decided b) (fighter-cls-t f))
                    (clog "~a ki-style ~(~a~) ns-stop ~(~a~)" (side-name e) (ikst-mode-mv st) (mv-name mv)))
                  t)
                 ((and (eq (ikst-plan st) :shot) (mv-ns-next kit mv) (zerop (length (mv-hits mv))))   ; the Getsuga's charges: on
                  (setf (brain-decided b) (fighter-cls-t f))
                  (cai-press b :quick 1 t)
                  t)
                 ((and (eq (ikst-plan st) :k-lunge) (eq mv (kit-core-move kit :ns 3)) *iks-k-sa-dodge-stop*
                       (member (snap-state s) '(:hoho :step)))   ; his dodge seen: no SA into it, NS3a ends here (b2_a0)
                  (setf (brain-decided b) (fighter-cls-t f) (ikst-plan st) nil)
                  (clog "~a ki-style kessa k-sa-stop ~(~a~) d ~,1f" (side-name e) (snap-state s) d)
                  t)
                 ((and (eq (ikst-plan st) :k-lunge) (eq mv (kit-core-move kit :ns 3))
                       (< (if *iks-k-sa-perceived* d (fighter-dist f)) *iks-k-sa-reach*)
                       (>= (if *iks-k-sa-perceived* d (fighter-dist f)) *iks-k-sa-min*))   ; KESSA NS3a > SA
                  (setf (brain-decided b) (fighter-cls-t f) (ikst-skey st) -1)
                  (clog "~a ki-style kessa k-sa d ~,1f" (side-name e) d)
                  (cai-press b :quick 1)
                  t)
                 ((and (eq (ikst-plan st) :g-sa) (eq mv (kit-core-move kit :ns 2)))   ; the confirm's NS2a > its gap's SA
                  (setf (brain-decided b) (fighter-cls-t f) (ikst-skey st) -1 (ikst-plan st) nil)
                  (cai-press b :quick 1)
                  t)
                 ((and (eq (fighter-contact f) :hit) (kit-sa-move kit)                     ; a landed NS1a / NS3a: the SA, a string
                       (or (eq mv (kit-core-move kit :ns 1)) (eq mv (kit-core-move kit :ns 3))))
                  (setf (brain-decided b) (fighter-cls-t f) (ikst-skey st) -1)
                  (cai-press b :quick 1)
                  t))))
        (:as                                                  ; every segment of the AS (AS3c's kill is the 5-Konpaku one)
         (when (and (>= (fighter-sf f) (mv-s mv)) (mv-ns-next kit mv) (not (vpad-down (pilot-vpad (pilot e)) :quick)))
           (setf (brain-decided b) (fighter-cls-t f))
           (cai-press b :quick 1 t)
           t))))))

(defun iks-generic (e b f kit s d)
  "A style episode's step left to the generic CPU (CAI-NEUTRAL / CAI-MOVE-STEP), with the style's Kikon rule on the SP it presses:
from neutral the pointer's NS (not pointer 2's charge: a hold would let its gaps pass), in a string the AS (profile CORE-NEXT-AS).
Also a :generic episode's steps at *IKS-GENERIC-KIKON*. NS / AS segment presses stay as they are. T (decided)."
  (let ((neutral (member (fighter-state f) '(:idle :run))))
    (if neutral (cai-neutral e b f kit s d) (cai-move-step e b f kit s))
    (when (and (eq (brain-press b) :quick) (brain-press-mod b) (eq (brain-act b) :quick) (plusp (brain-press-left b))
               (if neutral (/= (fighter-ptr f) 2) (member (fighter-cls f) '(:na :sa))))
      (setf (brain-press-left b)
            (iks-sp-frames b f (if neutral (fighter-ptr f) (core-next-as f)))))
    t))

(defun iks-break (e b f st)
  "In his combo: the awakening (a full gauge, *IKS-BREAK-AWAKEN*) or the Burst breaks out (*IKS-BREAK-P*, one roll per combo). T when
pressed."
  (let ((g (gauges e)))
    (when (and (zerop (fighter-kikon-lock f)) (>= (fighter-combo-hits f) *burst-min-hits*) (>= (brain-burst-t b) (brain-delay b)))
      (let ((aw (and *iks-break-awaken* (not (getf (kit-core (fighter-kit f)) :no-awaken)) (not (gauges-awakened g))
                     (>= (gauges-awaken g) *awaken-max*)))
            (bu (burst-ok-p e)))
        (when (and (or aw bu) (null (ikst-brk st)))
          (setf (ikst-brk st) (if (brain-roll b *iks-break-p*) :go :no)))
        (when (and (eq (ikst-brk st) :go) (or aw bu))
          (setf (ikst-brk st) :no (brain-burst-rolled b) t)
          (clog "~a ki-style break ~a hits ~d" (side-name e) (if aw "awaken" "burst") (fighter-combo-hits f))
          (if aw (ai-press b :awaken 1 :modded t) (cai-press b :awaken 1))
          t)))))

(defun ichigo-ki-style (e b f kit s d)
  "Ichigo's style against Kenpachi (CAI-DEFSTYLE): the episode's mode, then the neutral or move step. T when it decided."
  (let ((st (or (brain-style b) (setf (brain-style b) (make-ikst)))) (state (fighter-state f)))
    (if (member (snap-state s) '(:air :down :wakeup))           ; his knockdown: the meaty's roll, once as he goes down
        (unless (ikst-down st)
          (setf (ikst-down st) t
                (ikst-meaty st) (and (<= d *iks-meaty-far*) (member (fighter-form f) *iks-meaty-forms*) (brain-roll b *iks-meaty-p*)))
          (when (ikst-meaty st) (clog "~a ki-style meaty armed d ~,1f" (side-name e) d)))
        (setf (ikst-down st) nil (ikst-meaty st) nil))
    (when (eq (snap-state s) :hoho)                     ; (his Hoho seen: its start tick, for IKS-HIS-HOHO-SHUT-P)
      (setf (ikst-his-hoho st) (- *match-tick* (snap-sf s) (brain-delay b))))
    (when (and (member state '(:idle :run)) (plusp (fighter-invuln f)) (getf *iks-burst-no-hoho* (brain-difficulty b)))
      (setf (brain-hoho-roll b) 1f0))                    ; (after her Burst: the stale SNAP's attack is not Hohoed)
    (prog1
        (case state
          ((:idle :run)
           (when (iks-new-episode-p e st)
             (setf (ikst-mode st) (iks-pick (brain-chance b *iks-mix*) (sim-rnd01))
                   (ikst-mode-mv st) (ikst-mode st) (ikst-plan st) nil
                   (ikst-ep-t st) 0 (ikst-pend st) nil (ikst-retreat st) nil (ikst-awaken st) nil (ikst-dt st) 0
                   (ikst-gap st) nil))
           (incf (ikst-ep-t st))
           (cond ((and (eq (ikst-last-st st) :wakeup) (iks-wake e b f st d)))
                 ((iks-hoho-follow e b st s d (pilot-vpad (pilot e))))
                 ((iks-meaty e b f kit st s d))   ; (after her timed Hoho, whatever the new episode's mode)
                 ((eq (ikst-mode st) :generic)
                  (and (getf *iks-generic-kikon* (brain-difficulty b)) (iks-generic e b f kit s d)))
                 (t (or (iks-neutral e b f kit s d) (iks-generic e b f kit s d)))))
          (:move (if (eq (ikst-mode-mv st) :generic)
                     (and (getf *iks-generic-kikon* (brain-difficulty b)) (iks-generic e b f kit s d))
                     (or (iks-move e b f kit s d) (iks-generic e b f kit s d))))
          ((:stun :air) (iks-break e b f st))
          (:hoho (when (and (getf *iks-follow-any-perfect* (brain-difficulty b)) (fighter-perfect f))   ; (any perfect Hoho: the follow-up's clock)
                   (setf (ikst-hoho-t st) (- *match-tick* (fighter-sf f))))
                 nil)
          (t nil))
      (unless (member state '(:stun :air)) (setf (ikst-brk st) nil))
      (when (and (member state '(:idle :run)) (> (brain-press-left b) 0) (<= (ikst-dt st) 0))
        (setf (ikst-dt st) (+ (getf *cai-think* (brain-difficulty b) 22) (floor (* 12 (sim-rnd01))))))
      (setf (ikst-last-st st) state (ikst-last-reishi st) (gauges-reishi (gauges e)) (ikst-last-d st) d))))

(cai-defstyle :ichigo :kenpachi 'ichigo-ki-style)

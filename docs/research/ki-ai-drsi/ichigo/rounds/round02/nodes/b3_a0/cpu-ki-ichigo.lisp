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
;;;; Round 2 (b3_a0, against the round-2 Kenpachi): the timed Hoho (IKS-KESSA-HOHO, b3_a1's, both forms, his slide in its reach) and
;;;; its J1 follow-up after any perfect Hoho, the wake-up Hoho against his meaty J1 (IKS-WAKE), b3_a1's read floor in KESSA, and b0_a0's
;;;; far k-lunge for :space in KESSA pointer 3.
;;;; Rolls: the mode once per neutral episode, the punish once per his move start (SNAP-START), the steer / read / Kikon once per own
;;;; string or move; never per step. The opponent is read through the perceived SNAP S and distance D; his form (a visible fact, as
;;;; GAUGES-RED-P is) picks the band table. Every knob below is a plist by difficulty (EASY <= NORMAL <= HARD for the style chances);
;;;; the dream-rsi search tunes only these.
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
(defparameter *iks-kessa-read-min* '(:easy 1 :normal 1 :hard 2)
  "KESSA: a steered string takes the AS read (*IKS-READ-P*) only when the AS it would start is at least this (1: always, as the v0;
2: never AS1, so the read never writes pointer 1; 4: never). b3_a1: in KESSA pointer 1 lost the ledger against every form of his while
pointer 3 won it, and the k-lunge's SA read into AS1; 1 -> 2, HARD 100 seeds a seat: kessa 131 -> 143 of 200, raw 0.663 -> 0.671.")
;; The timed Hoho (round 1's b3_a1, KESSA only; round 2's b3_a0: both forms, the slide, the follow-up's window, any perfect Hoho, the
;; wake-up Hoho). The shipped CPU's Hoho (*CAI-HOHO-P*, an untimed roll as soon as his attack is live in reach) retimed into the
;; perfect-Hoho window (*PERFECT-LEAD*: the counter strike and his 40 f lock), then a J1 follow-up from behind him. Against the round-2
;; Kenpachi (round 2's b3_a0, 20 seeds a seat on the baseline + b3_a1's Hoho): his meaty J1 on her wake-up opened 393 of his combos (89k),
;; his Shikai lunge TOSSHIN (reach 2.6 + slide 3.0) 202 in KESSA (48k of the 139k she took there).
(defparameter *iks-kessa-hoho-p* '(:easy 0.0 :normal 0.0 :hard 0.9)
  "In her forms *IKS-HOHO-FORMS* (b3_a1: KESSA only), a style mode, neutral: Hoho his perceived attack (NA / NS / SA / AS) coming in
reach (+ its slide, *IKS-HOHO-SLIDE*) when its first active frame, as seen, is *IKS-KESSA-HOHO-LEAD* away (one roll per his move start),
with flash-step to spare (AI-HOHO-SPARE-P). NORMAL 0.1 -> 0 (round 2, b3_a0: NORMAL's share read 13 of 80 with it, the band's top 11).")
(defparameter *iks-kessa-hoho-lead* '(1 6)
  "Frames (lo hi) from now to his perceived move's first active frame (SNAP-LEAD-SEEN) in which the timed Hoho is pressed: inside
*PERFECT-LEAD* 12 and the Hoho's iframes f1-14. b3_a1, HARD 100 seeds a seat, raw / kessa of 200: (1 6) 0.711 / 163, (1 10) 0.701 /
163, (2 8) 0.693 / 152, (3 8) 0.693 / 151, (5 11) 0.689 / 143 (no Hoho: 0.671 / 143). At lead 1 some hits land on the press frame,
yet the early window still wins: more of his moves are answered at all.")
(defparameter *iks-hoho-slide* t
  "The timed Hoho's reach test adds his move's slide to its reach (b3_a1's test, SNAP-NEAR-P, took the reach alone: his Shikai NS1a
TOSSHIN, reach 2.6 + slide 3.0, lunges from 3.6-5.6 m and was never Hoho'd there; in KESSA it opened 202 of his combos, 48k of the
139k she took, 20 seeds a seat; KYORAN's NS (1.8 + 3.0) the same). Round 2, b3_a0: NIL -> T, paired 20 seeds a seat 0.5264 -> 0.5814
(HARD 20 -> 24 of 40).")
(defparameter *iks-hoho-forms* '(:kessa :base)
  "Her forms in which the timed Hoho (IKS-KESSA-HOHO) runs (b3_a1: KESSA only). Round 2, b3_a0: (:kessa) -> (:kessa :base); 20 seeds a
seat 0.5814 -> 0.6481; the ablation on the final file, 40 seeds a seat: (:kessa) 0.6981 (HARD 63/80, whiff 0.669) against 0.7151 (65/80,
whiff 0.711).")
(defparameter *iks-follow-any-perfect* '(:easy nil :normal nil :hard t)
  "Round 2, b3_a0 (20 seeds a seat 0.687 -> 0.7246, kessa 0.75 -> 0.85). The follow-up (IKS-HOHO-FOLLOW) also runs after a perfect Hoho the style did not press (the generic CPU's untimed one, the wake-up
Hoho): her own fighter's PERFECT flag, read while she is in the Hoho. By difficulty: HARD only, so EASY / NORMAL keep the shipped
CPU's Hoho as it was.")
(defparameter *iks-hoho-follow* 64
  "Frames after her Hoho in which the follow-up may start (his recovery or reeling, seen). 40 -> 64 (b3_a0 round 2): a perfect Hoho's
counter strike lands at about +32 (*HOHO-COUNTER-STRIKE* 14 + hitstop) with 36 f of hitstun, and the SNAP shows it 8 f later, so at 40
the window closed as his reeling came into view: 21 follow-ups after 132 counters in KESSA (20 seeds a seat).")
(defparameter *iks-hoho-j-reach* 1.5 "The follow-up: J1 from within this (m; KESSA J1 1.56 m), walking in first.")
(defparameter *iks-wake-hoho-p* '(:easy 0.0 :normal 0.0 :hard 0.9)
  "On her first free frame after a wake-up, him within *IKS-WAKE-HOHO-NEAR*: Hoho at once (one roll per wake-up), against his meaty J1
(his J1 timed onto that frame: the SNAP is too late to see it, so this is a guess from the distance alone). Round 2, b3_a0: new. His J1
still lands on that frame in most cases (the Hoho's iframes start at f1), but the Hoho is perfect, so his inputs lock 40 f and his string
stops at the J1: of 145 such wake-ups (40 HARD matches) one more hit of his followed within 60 f. The meaty loop took 89k -> 43k; paired 20
seeds a seat 0.4223 -> 0.5264 (HARD 12 -> 20 of 40). Spare-checked (AI-HOHO-SPARE-P): 0.5248, rejected.")
(defparameter *iks-wake-hoho-near* 2.2 "The wake-up Hoho's distance (m): his sealed J1 reaches 1.8 m, his meaty chase waits at 1.4.")
(defparameter *iks-wake-hoho-forms* '(:base :kessa) "Her forms in which the wake-up Hoho is rolled.")
(defparameter *iks-ns-wait* '(:easy 32 :normal 32 :hard 32)
  "Frames after his whiffing NS starts before the punish is pressed: earlier runs into his next segment (U6), f32 lands (U7).")
(defparameter *iks-hover* '(:base (3.7 4.2) :nozarashi (4.9 5.3))
  "The :whiff / :space hover band (m) by his form: just outside his NS reach, inside NS3a's 5.0 m.")
(defparameter *iks-hover-p1* '(:base (3.4 3.8) :nozarashi (4.9 5.3))
  "The :whiff / :space hover band (m) under pointer 1: her J-whiff punisher (NS1a) reaches only 3.4 m (*IKS-PUNISH-REACH*), so v0's
3.7-4.2 never let her punish his J whiff; 3.4-3.8 stays past his sealed NS1a (3.3 m). b0_a0 2026-11-06: new (v0 used *IKS-HOVER*).")
(defparameter *iks-lunge-band* '(:base (4.0 5.0) :nozarashi (4.8 5.0))
  "Pointer 3: NS3a's lunge from this band (m) when he is not attacking (R5 / R25: only her NS3a reaches 4–5 m sealed; his Shikai
NS1a reaches 4.6, R15).")
(defparameter *iks-walkin-band* '(2.9 3.4)
  "Pointer 1, :space: NS1a when he walks into this band (T14 / T15: her NS1a at 3.4 m catches his walk-in).")
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
(defparameter *iks-j-reach* 2.3 "Her J1's reach (m): pointer 2 inside it opens a J string instead of a charge (A13 2.4 hits, R6 2.6 misses).")
(defparameter *iks-shot-gap* 80 "Steps before the next decision after a Getsuga (as *CAI-RANGED-GAP*: the wave is not spammed).")
(defparameter *iks-steer-p* '(:easy 0.0 :normal 0.6 :hard 0.95)
  "A string in a style mode runs to the mode's AS (J5 + SP = AS3, KESSA AS2) instead of the generic continue rolls (one roll per string).")
(defparameter *iks-read-p* '(:easy 1.0 :normal 1.0 :hard 1.0)
  "A steered string still takes the AS read when he is seen in an NS (AS beats NS; it writes AS1 / AS2: pointer 3 lost). One roll per link.")
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
(defparameter *iks-kessa-chain-band* '(2.8 3.4) "KESSA pointer 1: the chains (NS1) from this band (K5, R8 3.4 hits, R9 3.8 misses).")
(defparameter *iks-kessa-lunge-band* '(5.05 5.5)
  "KESSA pointer 3: NS3a then its SA's 3 m lunge from this band (m, the projected distance, IKS-PROJ). The SA starts on NS3a's f18
where NS3a started (she does not move in it), so the hit counts as one from >= 4 m; it lands from 4.2 (R27) to 5.6 m and misses at 5.8
(round-2 b0_a0 trials X1-X5.8 against a standing Kenpachi). His back Step through her clone (KK-READ, *KK-STEP-MAX* 5.0) is rolled only
when his perceived distance falls under 5.0 (about 35 of 195 k-lunges in the logs, mostly as he walks in fast); 3.6-4.3 -> 5.05-5.5 (round 2, b0_a0: at 3.6-4.3, 91 of 256 KESSA NS3a starts met his back Step and 71 his Hoho,
10 seeds a seat; the SA from 3.6 also started under 4 m, so a landed lunge was no spacing hit).")
(defparameter *iks-kessa-space-modes* '(:easy nil :normal nil :hard (:space))
  "By difficulty, the style modes whose KESSA pointer-3 neutral is the far k-lunge (*IKS-KESSA-LUNGE-BAND*): wait in the band, lunge as
he walks in. Round 2's b0_a0 found that :space in KESSA ran the sealed form's NS3a lunge branch, whose plan (:lunge) never pressed the
SA after KESSA's hitless NS3a (a clone from 4-5 m and nothing else), and gave the far band to all four modes. Round 2's b3_a0 (paired,
20 seeds a seat, on its timed-Hoho file): all four modes 0.5632 (HARD 20/40, kessa 0.575, spacing 0.181) against :space only 0.7271
(33/40, kessa 0.80, spacing 0.160); without the band 0.7246 (spacing 0.087). HARD only: NORMAL and EASY keep v0's play.")
(defparameter *iks-kessa-near-band* '(3.6 4.3)
  "KESSA pointer 3, a :kessa episode: NS3a then its SA from this band (v0's k-lunge band, R27: hits from 4.2 m). Kept by round 2's
b3_a0 for :kessa (the far band in every mode lost the ledger: see *IKS-KESSA-SPACE-MODES*).")
(defparameter *iks-k-sa-reach* 5.7
  "KESSA NS3a's SA is pressed in its gap while the distance is under this (m): the SA's 2.6 m arc + 3.0 m slide lands from 5.6 m
(trial X5.6), not 5.8. Was 4.6 (round 2, b0_a0).")
(defparameter *iks-lead-vmax* 0.07
  "IKS-PROJ: the perceived distance's change a step is clamped to this (m; a walk is 0.06-0.07 a step) before it is projected over
her perception delay (a dash would throw the projection far off).")

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
  (mode-mv :generic)                    ; the mode of the episode her move in progress started from
  (last-d 0f0)                          ; the perceived distance at the previous call (IKS-PROJ)
  (hkey -1 :type fixnum) (hoho nil)     ; his move start the KESSA Hoho roll is for; its result (T: Hoho it)
  (hoho-t -1 :type fixnum))             ; the tick of her last KESSA Hoho (-1: none, or its follow-up done)

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
                         (>= (- *match-tick* (snap-start s)) (brain-chance b *iks-ns-wait*))))   ; (his NS's slide brings him in: M20)
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

(defun iks-proj (b st d)
  "The perceived distance D projected over her perception delay by its change since the last call (clamped to *IKS-LEAD-VMAX* a step):
about where he is now if he keeps walking. Only perceived distances are used."
  (let ((v (max (- *iks-lead-vmax*) (min *iks-lead-vmax* (- d (ikst-last-d st))))))
    (+ d (* v (brain-delay b)))))

(defun iks-kessa-hoho (e b st s d)
  "The timed Hoho (in *IKS-HOHO-FORMS*): Hoho his perceived attack in reach (+ its slide), timed into the perfect-Hoho window
(*IKS-KESSA-HOHO-LEAD*). One roll per his move start. T when pressed."
  (when (and (member (cai-class-of (fighter-opp (fighter e)) s) '(:na :ns :sa :as)) (eq (snap-phase s) :main) (snap-live-p s)
             (or (snap-near-p s e d 1.0)
                 (and *iks-hoho-slide* (snap-move s) (< d (+ (snap-reach s) (mv-slide (snap-move s)) 1.0)))))
    (unless (= (ikst-hkey st) (snap-start s))
      (setf (ikst-hkey st) (snap-start s) (ikst-hoho st) (brain-roll b *iks-kessa-hoho-p*)))
    (let ((lead (snap-lead-seen s b)) (g (gauges e)))
      (when (and (ikst-hoho st) (<= (first *iks-kessa-hoho-lead*) lead (second *iks-kessa-hoho-lead*)) (hoho-open-p e)
                 (ai-hoho-spare-p (gauges-fs g) (gauges-reishi g) (gauges-reishi-max g)))
        (setf (ikst-hoho st) nil (ikst-hoho-t st) *match-tick*)
        (iks-log e st :hoho d)
        (ai-press b :step 1 :modded t :act :hoho)
        t))))

(defun iks-hoho-follow (e b st s d vp)
  "Just after her Hoho (the timed one, or any perfect one at *IKS-FOLLOW-ANY-PERFECT*): J1 on his seen recovery / reeling from behind him (walk in to *IKS-HOHO-J-REACH* first). T when decided."
  (when (and (>= (ikst-hoho-t st) 0) (<= (- *match-tick* (ikst-hoho-t st)) *iks-hoho-follow*))
    (cond ((not (snap-punishable-p s)) nil)
          ((<= d *iks-hoho-j-reach*) (setf (ikst-hoho-t st) -1 (ikst-mode-mv st) :kessa) (iks-j e b st :hoho-j d))
          ((< d 3.0) (iks-walk e b vp d 0.0 *iks-hoho-j-reach*)))))

(defun iks-pointer-2 (e b f st s d vp)
  "Pointer 2 (either form): the Getsuga from *IKS-GETSUGA-MIN*, a J string inside her J reach, no charge in between: back dash
(one roll per episode) or hover back. T when decided, NIL to hand over (the generic shoots from 3.6–6.6 m against a walk-in)."
  (cond ((>= d *iks-getsuga-min*)
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
         (kessa (eq (fighter-form f) :kessa)) (ptr (fighter-ptr f)) (calm (member (snap-state s) '(:idle :run))))
    (declare (ignorable kit))
    (decf (ikst-dt st))
    (cond
      ((and (ikst-pend st) (iks-pend-step e b f st d)))
      ((iks-punish e b f st s d o))
      ((and (member (fighter-form f) *iks-hoho-forms*) (iks-kessa-hoho e b st s d)))
      ;; his attack live and in reach: the generic's Hoho roll (the identical test) takes the step
      ((and (eq (snap-state s) :move) (plusp (snap-left s)) (< d (+ (snap-reach s) 1.0)) (hoho-open-p e)
            (< (brain-hoho-roll b) (brain-chance b *cai-hoho-p*)))
       nil)
      ;; KESSA: awaken once full at a free moment
      ((and (member mode *iks-awaken-modes*) (gauges-awakened-ok-p e) (or calm (> d (+ (snap-reach s) 1.5)))
            (progn (unless (ikst-awaken st) (setf (ikst-awaken st) (if (brain-roll b *iks-awaken-p*) :go :no)))
                   (eq (ikst-awaken st) :go)))
       (setf (ikst-awaken st) :no)
       (iks-log e st :awaken d)
       (ai-press b :awaken 1 :modded t)
       t)
      ((= ptr 2) (iks-pointer-2 e b f st s d vp))               ; (before the wait's end: never a charge in his face)
      ((> (ikst-ep-t st) (brain-chance b *iks-wait-max*)) nil)   ; waited long enough: the generic plays on
      ((and kessa (= ptr 3) (member mode (brain-chance b *iks-kessa-space-modes*)))   ; KESSA pointer 3: the k-lunge from beyond his back Step
       (destructuring-bind (clo chi) *iks-kessa-lunge-band*
         (if (and calm (<= clo (iks-proj b st d) chi) (<= (ikst-dt st) 0))
             (iks-sp e b f st :k-lunge d :k-lunge)
             (iks-walk e b vp d clo chi))))                    ; (from afar too: the generic's dash to 4.5 m overshoots the band)
      ((and kessa (eq mode :kessa))
       (destructuring-bind (clo chi) (if (= ptr 3) *iks-kessa-near-band* *iks-kessa-chain-band*)
         (cond ((and calm (<= clo d chi) (<= (ikst-dt st) 0))
                (iks-sp e b f st (if (= ptr 3) :k-lunge :k-chains) d (and (= ptr 3) :k-lunge)))
               ((> d 7.0) nil)
               (t (iks-walk e b vp d clo chi)))))
      ((eq mode :ptr3) nil)                                    ; neutral as the generic; the steering is in the move
      ((and (eq mode :kessa) (not kessa)) nil)                 ; (until full: as the generic)
      ((> d 7.0) nil)                                          ; the generic dashes in to 4.5 m
      ((and (eq mode :space) (= ptr 3))
       (destructuring-bind (llo lhi) (iks-form-get *iks-lunge-band* o)
         (cond ((and calm (<= llo d lhi) (<= (ikst-dt st) 0)) (iks-sp e b f st :lunge d :lunge))
               ((< d 1.7) nil)                                 ; point-blank: the generic's J
               (t (iks-walk e b vp d llo lhi)))))
      ((and (eq mode :space) (= ptr 1) (member (snap-state s) '(:idle :run))
            (<= (first *iks-walkin-band*) d (second *iks-walkin-band*)) (<= (ikst-dt st) 0))
       (iks-sp e b f st :walk-in d))
      ((member mode '(:space :whiff))
       (if (< d 1.7) nil
           (destructuring-bind (hlo hhi) (iks-form-get (if (= ptr 1) *iks-hover-p1* *iks-hover*) o) (iks-walk e b vp d hlo hhi))))
      (t nil))))

(defun iks-move (e b f kit s)
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
           (cond ((and (eq (ikst-plan st) :shot) (mv-ns-next kit mv) (zerop (length (mv-hits mv))))   ; the Getsuga's charges: on
                  (setf (brain-decided b) (fighter-cls-t f))
                  (cai-press b :quick 1 t)
                  t)
                 ((and (eq (ikst-plan st) :k-lunge) (eq mv (kit-core-move kit :ns 3)) (< (fighter-dist f) *iks-k-sa-reach*))   ; KESSA NS3a > SA
                  (setf (brain-decided b) (fighter-cls-t f) (ikst-skey st) -1)
                  (clog "~a ki-style kessa k-sa d ~,1f" (side-name e) (fighter-dist f))
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

(defun iks-wake (e b f st d)
  "Her first free frame after a wake-up with him near (*IKS-WAKE-HOHO-NEAR*), where his meaty J1 lands: the Hoho (one roll per
wake-up, *IKS-WAKE-HOHO-P*). T when pressed."
  (when (and (<= d *iks-wake-hoho-near*) (member (fighter-form f) *iks-wake-hoho-forms*) (hoho-open-p e)
             (brain-roll b *iks-wake-hoho-p*))
    (iks-log e st :wake-hoho d)
    (ai-press b :step 1 :modded t :act :hoho)
    t))

(defun ichigo-ki-style (e b f kit s d)
  "Ichigo's style against Kenpachi (CAI-DEFSTYLE): the episode's mode, then the neutral or move step. T when it decided."
  (let ((st (or (brain-style b) (setf (brain-style b) (make-ikst)))) (state (fighter-state f)))
    (prog1
        (case state
          ((:idle :run)
           (when (iks-new-episode-p e st)
             (setf (ikst-mode st) (iks-pick (brain-chance b *iks-mix*) (sim-rnd01))
                   (ikst-mode-mv st) (ikst-mode st) (ikst-plan st) nil
                   (ikst-ep-t st) 0 (ikst-pend st) nil (ikst-retreat st) nil (ikst-awaken st) nil (ikst-dt st) 0))
           (incf (ikst-ep-t st))
           (cond ((and (eq (ikst-last-st st) :wakeup) (iks-wake e b f st d)))
                 ((iks-hoho-follow e b st s d (pilot-vpad (pilot e))))   ; (after her KESSA Hoho, whatever the new episode's mode)
                 ((eq (ikst-mode st) :generic)
                  (and (getf *iks-generic-kikon* (brain-difficulty b)) (iks-generic e b f kit s d)))
                 (t (or (iks-neutral e b f kit s d) (iks-generic e b f kit s d)))))
          (:move (if (eq (ikst-mode-mv st) :generic)
                     (and (getf *iks-generic-kikon* (brain-difficulty b)) (iks-generic e b f kit s d))
                     (or (iks-move e b f kit s) (iks-generic e b f kit s d))))
          (:hoho (when (and (getf *iks-follow-any-perfect* (brain-difficulty b)) (fighter-perfect f))   ; (any perfect Hoho of hers: the follow-up's clock)
                   (setf (ikst-hoho-t st) (- *match-tick* (fighter-sf f))))
                 nil)
          (t nil))
      (when (and (member state '(:idle :run)) (> (brain-press-left b) 0) (<= (ikst-dt st) 0))
        (setf (ikst-dt st) (+ (getf *cai-think* (brain-difficulty b) 22) (floor (* 12 (sim-rnd01))))))
      (setf (ikst-last-st st) state (ikst-last-reishi st) (gauges-reishi (gauges e)) (ikst-last-d st) d))))

(cai-defstyle :ichigo :kenpachi 'ichigo-ki-style)

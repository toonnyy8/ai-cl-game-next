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
;;;;                        from 4.2 m, strings to AS2 (+79)
;;;; Every style mode shares: no NS2 charge inside *IKS-NS2-MIN* (pointer 2: back off and shoot the Getsuga from *IKS-GETSUGA-MIN*,
;;;; where his run-in loses: R17 / R18), the whiff punish, the SA after a landed NS1a / NS3a, all segments of an AS, and the Kikon
;;;; held only when he is red and the SP's Konpaku profile is in *IKS-KIKON-PROFILES* (pointer 2 against red: 3, E14; pointer 1 / 3
;;;; take 1 and refill his Reishi, throwing away a 3 / 5 Konpaku Soul Break).
;;;; Rolls: the mode once per neutral episode, the punish once per his move start (SNAP-START), the steer / read / Kikon once per own
;;;; string or move; never per step. The opponent is read through the perceived SNAP S and distance D; his form (a visible fact, as
;;;; GAUGES-RED-P is) picks the band table. Every knob below is a plist by difficulty (EASY <= NORMAL <= HARD for the style chances);
;;;; the dream-rsi search tunes only these.
(in-package :duel)

(defparameter *iks-mix* '(:easy (:generic 1.0)
                          :normal (:generic 0.88 :space 0.03 :whiff 0.03 :ptr3 0.03 :kessa 0.03)
                          :hard (:generic 0.04 :space 0.32 :whiff 0.24 :ptr3 0.24 :kessa 0.16))
  "The mode of a neutral episode, weights by difficulty (normalised): :generic leaves the episode to the shipped CPU. NORMAL stays
near the shipped CPU (its win share is the evaluator's NORMAL band); HARD is where the styles live (the user, 2026-11-06).")
(defparameter *iks-punish-p* '(:easy 0.0 :normal 0.5 :hard 0.9)
  "In a style mode: punish a perceived move of his that starts out of his reach (one roll per his move start).")
(defparameter *iks-his-reach* '(:base (:na 2.7 :ns 3.65) :nozarashi (:na 3.2 :ns 4.8))
  "His reach (m, centre to centre) by his form, J (NA) and NS: a move he starts beyond it whiffs (sealed J1 hits 2.4 / misses 2.7,
NS1a 3.3 / 3.6, NS3b 3.6 / 4.0; Shikai J1 3.0, NS1a 4.6: catalogue's range band). Another form: :nozarashi's.")
(defparameter *iks-punish-reach* '(3.4 0.0 5.0)
  "Her punisher's reach (m) by pointer against his J whiff: NS1a 3.4 (M29 at 3.2), none under 2 (a charge), NS3a 5.0 (R5).")
(defparameter *iks-ns-wait* '(:easy 32 :normal 32 :hard 32)
  "Frames after his whiffing NS starts before the punish is pressed: earlier runs into his next segment (U6), f32 lands (U7).")
(defparameter *iks-hover* '(:base (3.7 4.2) :nozarashi (4.9 5.3))
  "The :whiff / :space hover band (m) by his form: just outside his NS reach, inside NS3a's 5.0 m.")
(defparameter *iks-hover-p1* '(:base (3.4 3.8) :nozarashi (4.9 5.3))
  "The :whiff / :space hover band (m) under pointer 1: her J-whiff punisher (NS1a) reaches only 3.4 m (*IKS-PUNISH-REACH*), so v0's
3.7-4.2 never let her punish his J whiff; 3.4-3.8 stays past his sealed NS1a (3.3 m). b0_a0 2026-11-06: new (v0 used *IKS-HOVER*).")
(defparameter *iks-lunge-band* '(:base (4.7 5.0) :nozarashi (4.8 5.0))
  "Pointer 3: NS3a's lunge from this band (m, the distance as *IKS-LEAD* projects it) when he is not attacking (R5 / R25: only her
NS3a reaches 4–5 m sealed; his Shikai NS1a reaches 4.6, R15). b0_a1 2026-11-06: base 4.0 -> 4.7. A lunge decided at 4.0-4.2 m
started at 3.56 m (her own step before the move's start, measured in the native sim): inside his NS3b's 3.6 m and his J1's cancel
(U3), and not a hit from the 4-5 m band. From 4.7-5.0 it starts at 4.0 m or more, where only her NS3a reaches (R4 4.6 / R5 5.0 hit).")
(defparameter *iks-lead* '(:easy 0.0 :normal 1.0 :hard 1.0)
  "The lunge band (*IKS-LUNGE-BAND*) tests the perceived distance D plus its change between two consecutive calls (clamped to
*IKS-LEAD-VMAX*) times the brain's perception delay times this: where he is now if he keeps walking (0: v0's stale D, 8 frames old at
HARD). Only perceived distances are used. b0_a1 2026-11-06: new.")
(defparameter *iks-lunge-approach* t
  "Pointer 3, sealed form, an episode whose *IKS-ANY-LUNGE-P* roll said go: from beyond *IKS-LUNGE-BAND* she walks in to it (the round
start's 8 m included) instead of the generic CPU's dash to 4.5 m, where his J1 cancels her NS3a and his AS1 lands (U3). b0_a1
2026-11-06: new.")
(defparameter *iks-gap-episode* 30
  "A call more than this many steps after the last one (a new round at 8 m, after a cinematic) starts a new neutral episode, with a
fresh mode roll. NIL: never (v0 / b0_a0: her Reishi refills at a round's start, so the last round's episode went on, its wait long
over, and the generic CPU dashed in from 8 m). Her own dash (the pointer-2 back dash holds Step up to 70 steps) does not count. b0_a1
2026-11-06: new.")
(defparameter *iks-lead-vmax* 0.07
  "The per-step distance change *IKS-LEAD* projects is clamped to this (m/step, about a walk): a dash, a Hoho or a knockback would
throw the projection meters off. b0_a1 2026-11-06: new.")
(defparameter *iks-any-lunge-p* '(:easy 0.0 :normal 0.5 :hard 0.95)
  "Pointer 3 in the sealed form, any style mode (not only :space): NS3a's lunge when the projected distance is in *IKS-LUNGE-BAND*
and he is not attacking (one roll per neutral episode). b0_a1 2026-11-06: new (v0 / b0_a0 lunged only in :space: :whiff / :ptr3 /
:kessa episodes let him walk through 4-5 m into the brawl range).")
(defparameter *iks-walkin-band* '(2.9 3.4)
  "Pointer 1, :space: NS1a when he walks into this band (T14 / T15: her NS1a at 3.4 m catches his walk-in).")
(defparameter *iks-wait-max* '(:easy 0 :normal 90 :hard 150)
  "Frames a style mode may hover / back off in one neutral episode before it hands the episode to the generic CPU (no stalling).")
(defparameter *iks-ns2-min* 3.6 "Pointer 2: no NS2 charge inside this distance (M13 / M14: his J1 > AS1 or NS1a punishes the charge).")
(defparameter *iks-getsuga-min* 7.5 "Pointer 2: the Getsuga from this distance on (R17 / R18 / M16: his run-in loses).")
(defparameter *iks-retreat-to* 8.2 "Pointer 2: the back dash's target distance (m) to get the Getsuga's range.")
(defparameter *iks-retreat-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Pointer 2 out of J reach and inside the Getsuga's range: back dash to *IKS-RETREAT-TO* (one roll per neutral episode).")
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
(defparameter *iks-kessa-as* 3
  "KESSA: the attack presses a steered string runs to before its SP (3: J1–J3 / NS1a SA J2 J3 + SP = AS2, +79 at 4.8 m, K3 / K6; 5: AS3).")
(defparameter *iks-kikon-p* '(:easy 0.0 :normal 0.6 :hard 0.95)
  "A style mode's SP held into a Kikon when he is red and the SP's Konpaku profile is in *IKS-KIKON-PROFILES* (one roll per SP); never
when he is not red (a non-red Kenpachi cancels the follow-up: E12 / E15).")
(defparameter *iks-kikon-profiles* '(2)
  "The SP pointers (CORE-NEXT-AS in a string, the pointer from neutral) whose red Kikon is held: 2 takes 3 Konpaku against red (E14);
1 and 3 take 1 and refill his Reishi.")
(defparameter *iks-awaken-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  ":kessa mode: awaken once the gauge is full and he is not attacking within reach (one roll per neutral episode).")
(defparameter *iks-kessa-chain-band* '(2.8 3.4) "KESSA pointer 1: the chains (NS1) from this band (K5, R8 3.4 hits, R9 3.8 misses).")
(defparameter *iks-kessa-lunge-band* '(3.6 4.3) "KESSA pointer 3: NS3a then its SA's 3 m lunge from this band (R27: hits from 4.2 m).")

(defstruct (ikst (:constructor make-ikst ()))
  "Ichigo's KI style state (BRAIN-STYLE)."
  (mode :generic)                       ; this neutral episode's mode
  (ep-t 0 :type fixnum)                 ; frames in this episode
  (last-st nil)                         ; her state at the previous call
  (last-reishi 0 :type fixnum)          ; her Reishi then (a hit starts a new episode)
  (dt 0 :type fixnum)                   ; frames to the next own decision
  (retreat nil)                         ; this episode's retreat roll was made (T) / it said go (:go)
  (rkey -1 :type fixnum)                ; his move start the retreat roll was re-armed for (*IKS-RETREAT-REARM*)
  (awaken nil)                          ; this episode's awaken roll: NIL unmade, :go, :no
  (pkey -1 :type fixnum) (punish nil)   ; his move start the punish roll is for; :go / :no / :done
  (plan nil)                            ; what the move she started is for: :shot :lunge :k-lunge, NIL
  (skey -1 :type fixnum) (steer nil)    ; the string's first link start; the press count it runs to (NIL: generic)
  (mode-mv :generic)                    ; the mode of the episode her move in progress started from
  (lunge nil)                           ; this episode's any-mode lunge roll: NIL unmade, :go, :no
  (dprev 0f0 :type single-float) (dtick -1 :type fixnum)   ; the perceived distance at the last call, and its tick
  (dnow 0f0 :type single-float))        ; the projected distance this step (*IKS-LEAD*)

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

(defun iks-in-lunge-band-p (st d o)
  "Pointer 3's lunge band (*IKS-LUNGE-BAND* by his form): the projected distance inside it and the perceived D not under it (he
walking in reads farther than he is, never nearer)."
  (destructuring-bind (llo lhi) (iks-form-get *iks-lunge-band* o)
    (and (<= llo (ikst-dnow st) lhi) (<= llo d (+ lhi 0.6)))))

(defun iks-log (e st action d)
  (clog "~a ki-style ~(~a~) ~(~a~) d ~,1f ptr ~d form ~(~a~)" (side-name e) (ikst-mode st) action d (fighter-ptr (fighter e))
        (fighter-form (fighter e))))

(defun iks-sp-frames (b f profile)
  "Frames to hold this SP: 40 (into a Kikon) when he is red, PROFILE is held and the roll says so, else a tap."
  (if (and (gauges-red-p (gauges (fighter-opp f))) (member profile *iks-kikon-profiles*)
           (brain-roll b *iks-kikon-p*))
      40 1))

(defun iks-sp (e b f st action d &optional plan)
  "Press SP from neutral (the pointer's NS), tagged with PLAN (a :shot's charges are taps: a hold would let their gaps pass)."
  (setf (ikst-plan st) plan (brain-own-key b) -1)
  (iks-log e st action d)
  (cai-press b :quick (if (eq plan :shot) 1 (iks-sp-frames b f (fighter-ptr f))) t)
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

(defun iks-new-episode-p (e b st gap)
  "Does a new neutral episode start (she was not neutral at the last call, or she was hit since, or GAP steps passed since the last
call: a round's start or a cinematic, not her own dash)?"
  (or (not (member (ikst-last-st st) '(:idle :run))) (< (gauges-reishi (gauges e)) (ikst-last-reishi st))
      (and *iks-gap-episode* (or (minusp gap) (> gap *iks-gap-episode*)) (not (eq (brain-act b) :dash)))))

(defun iks-punish (e b f st s d o)
  "The whiff punish (every style mode): his perceived move started out of his reach -> NS1a (pointer 1) / NS3a (3) at once against a
J, after *IKS-NS-WAIT* against an NS. One roll per his move start. T when pressed."
  (let ((oc (cai-class-of o s)))
    (when (and (member oc '(:na :ns)) (/= (fighter-ptr f) 2))
      (unless (= (ikst-pkey st) (snap-start s))
        (setf (ikst-pkey st) (snap-start s)
              (ikst-punish st) (let ((reach (getf (iks-form-get *iks-his-reach* o) oc)))
                                 (if (and reach (> d reach) (brain-roll b *iks-punish-p*)) :go :no))))
      (when (and (eq (ikst-punish st) :go)
                 (if (eq oc :na)
                     (<= d (nth (1- (fighter-ptr f)) *iks-punish-reach*))   ; (his J's whiff: only within her punisher's reach)
                     (>= (- *match-tick* (snap-start s)) (brain-chance b *iks-ns-wait*))))   ; (his NS's slide brings him in: M20)
        (setf (ikst-punish st) :done)
        (iks-sp e b f st (if (eq oc :na) :punish-j :punish-ns) d (and (= (fighter-ptr f) 3) :lunge))))))

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
      ((iks-punish e b f st s d o))
      ;; his attack live and in reach: the generic's Hoho roll (the identical test) takes the step
      ((and (eq (snap-state s) :move) (plusp (snap-left s)) (< d (+ (snap-reach s) 1.0)) (hoho-open-p e)
            (< (brain-hoho-roll b) (brain-chance b *cai-hoho-p*)))
       nil)
      ;; KESSA: awaken once full at a free moment
      ((and (eq mode :kessa) (gauges-awakened-ok-p e) (or calm (> d (+ (snap-reach s) 1.5)))
            (progn (unless (ikst-awaken st) (setf (ikst-awaken st) (if (brain-roll b *iks-awaken-p*) :go :no)))
                   (eq (ikst-awaken st) :go)))
       (setf (ikst-awaken st) :no)
       (iks-log e st :awaken d)
       (ai-press b :awaken 1 :modded t)
       t)
      ((= ptr 2) (iks-pointer-2 e b f st s d vp))               ; (before the wait's end: never a charge in his face)
      ;; pointer 3, sealed form, any style mode: the 4-5 m lunge as he walks through the band (one roll an episode)
      ;; and from beyond the band she walks in to it (not the generic's dash to 4.5 m, inside his J1's cancel after her slide)
      ((and (= ptr 3) (not kessa)
            (progn (unless (ikst-lunge st) (setf (ikst-lunge st) (if (brain-roll b *iks-any-lunge-p*) :go :no)))
                   (eq (ikst-lunge st) :go))
            (cond ((and calm (<= (ikst-dt st) 0) (iks-in-lunge-band-p st d o)) (iks-sp e b f st :lunge d :lunge))
                  ((and *iks-lunge-approach* (> d (second (iks-form-get *iks-lunge-band* o))))
                   (destructuring-bind (llo lhi) (iks-form-get *iks-lunge-band* o) (iks-walk e b vp d llo lhi)))
                  (t nil))))   ; (NIL: the clauses below take the step)
      ((> (ikst-ep-t st) (brain-chance b *iks-wait-max*)) nil)   ; waited long enough: the generic plays on
      ((and kessa (eq mode :kessa))
       (destructuring-bind (clo chi) (if (= ptr 3) *iks-kessa-lunge-band* *iks-kessa-chain-band*)
         (cond ((and calm (<= clo d chi) (<= (ikst-dt st) 0))
                (iks-sp e b f st (if (= ptr 3) :k-lunge :k-chains) d (and (= ptr 3) :k-lunge)))
               ((> d 7.0) nil)
               (t (iks-walk e b vp d clo chi)))))
      ((eq mode :ptr3) nil)                                    ; neutral as the generic; the steering is in the move
      ((and (eq mode :kessa) (not kessa)) nil)                 ; (until full: as the generic)
      ((> d 7.0) nil)                                          ; the generic dashes in to 4.5 m
      ((and (eq mode :space) (= ptr 3))
       (destructuring-bind (llo lhi) (iks-form-get *iks-lunge-band* o)
         (cond ((and calm (iks-in-lunge-band-p st d o) (<= (ikst-dt st) 0)) (iks-sp e b f st :lunge d :lunge))
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
                                      (if (and kessa (eq (ikst-mode-mv st) :kessa)) *iks-kessa-as* 5))))
         (when (and (ikst-steer st) (eq (fighter-contact f) :hit) (not (fighter-as-done f)))
           (setf (brain-decided b) (fighter-cls-t f))
           (cond ((or (>= (fighter-presses f) (ikst-steer st)) (>= (fighter-presses f) 5)
                      (and (eq oc :ns) (brain-roll b *iks-read-p*)))
                  (let ((as (core-next-as f)))
                    (when (>= (fighter-presses f) 5) (clog "~a ki-style ~(~a~) as~d" (side-name e) (ikst-mode-mv st) as))
                    (cai-press b :quick (iks-sp-frames b f as) t)))
                 (t (cai-press b :quick 1)))
           t))
        (:ns
         (when (>= (fighter-sf f) (mv-s mv))
           (cond ((and (eq (ikst-plan st) :shot) (mv-ns-next kit mv) (zerop (length (mv-hits mv))))   ; the Getsuga's charges: on
                  (setf (brain-decided b) (fighter-cls-t f))
                  (cai-press b :quick 1 t)
                  t)
                 ((and (eq (ikst-plan st) :k-lunge) (eq mv (kit-core-move kit :ns 3)) (< (fighter-dist f) 4.6))   ; KESSA NS3a > SA
                  (setf (brain-decided b) (fighter-cls-t f) (ikst-skey st) -1)
                  (clog "~a ki-style kessa k-sa d ~,1f" (side-name e) (fighter-dist f))
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
NS / AS segment presses stay as they are. T (decided)."
  (let ((neutral (member (fighter-state f) '(:idle :run))))
    (if neutral (cai-neutral e b f kit s d) (cai-move-step e b f kit s))
    (when (and (eq (brain-press b) :quick) (brain-press-mod b) (eq (brain-act b) :quick) (plusp (brain-press-left b))
               (if neutral (/= (fighter-ptr f) 2) (member (fighter-cls f) '(:na :sa))))
      (setf (brain-press-left b) (iks-sp-frames b f (if neutral (fighter-ptr f) (core-next-as f)))))
    t))

(defun ichigo-ki-style (e b f kit s d)
  "Ichigo's style against Kenpachi (CAI-DEFSTYLE): the episode's mode, then the neutral or move step. T when it decided."
  (let* ((st (or (brain-style b) (setf (brain-style b) (make-ikst)))) (state (fighter-state f)) (df (float d 0f0))
         (gap (- *match-tick* (ikst-dtick st))))
    (setf (ikst-dnow st) (if (= (ikst-dtick st) (1- *match-tick*))   ; (consecutive calls only; her own walk is projected too)
                             (+ df (* (max (- *iks-lead-vmax*) (min *iks-lead-vmax* (- df (ikst-dprev st))))
                                      (float (* (brain-delay b) (brain-chance b *iks-lead*)) 0f0)))
                             df)
          (ikst-dprev st) df (ikst-dtick st) *match-tick*)
    (prog1
        (case state
          ((:idle :run)
           (when (iks-new-episode-p e b st gap)
             (setf (ikst-mode st) (iks-pick (brain-chance b *iks-mix*) (sim-rnd01))
                   (ikst-mode-mv st) (ikst-mode st) (ikst-plan st) nil
                   (ikst-ep-t st) 0 (ikst-retreat st) nil (ikst-awaken st) nil (ikst-lunge st) nil (ikst-dt st) 0))
           (incf (ikst-ep-t st))
           (unless (eq (ikst-mode st) :generic)
             (or (iks-neutral e b f kit s d) (iks-generic e b f kit s d))))
          (:move (unless (eq (ikst-mode-mv st) :generic)
                   (or (iks-move e b f kit s) (iks-generic e b f kit s d))))
          (t nil))
      (when (and (member state '(:idle :run)) (> (brain-press-left b) 0) (<= (ikst-dt st) 0))
        (setf (ikst-dt st) (+ (getf *cai-think* (brain-difficulty b) 22) (floor (* 12 (sim-rnd01))))))
      (setf (ikst-last-st st) state (ikst-last-reishi st) (gauges-reishi (gauges e))))))

(cai-defstyle :ichigo :kenpachi 'ichigo-ki-style)

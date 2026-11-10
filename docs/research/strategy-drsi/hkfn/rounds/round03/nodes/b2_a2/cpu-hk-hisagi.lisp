;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. The search's starting program: his merged style (cpu-hisagi-range.lisp) unchanged.
;;;;
;;;; Cell b2_a1 (round 3): b2_a0 + a fourth rule, hkd-step: HOHO THROUGH HIS SLOW MOVE START (a perfect Hoho onto a move whose hit is still
;;;; frames away when it is seen; the merged style's pf J1 cashes the 40 frame lock).
;;;; Cell b2_a0 (round 3): b0_a2 + a third rule, hks-step: ANSWER KENPACHI'S STEP-IN. His KI code hops in from 2.2-4.4 m and cuts J1 out of the
;;;; hop (the hit lands on hop frame 19). Once the hop is seen closing in (by frame 3), a free Hisagi with a Hoho open plans one Hoho so that its
;;;; invulnerable frames cover that hit (perfect: counter 60 and a 40 frame lock); the merged style's pf J1 then follows.
;;;; Cell b0_a2 (round 2): b0_a0 below + the Reishi pot (round 1 b3_a2) as a second rule.
;;;; Cell b0_a0 (round 2), on round 1's b2_a0. The one job: ANSWER HIS OWN WAKE-UP BY READING WHAT KENPACHI WHIFFED INTO IT. Kenpachi's
;;;; code presses a long move (his NS1a / N2A, a J1) into a knockdown of Hisagi's, so on Hisagi's first free frame two thirds of the time
;;;; he is still in that move's recovery, a metre away. The shared CPU spends the frame on the wake-up Hoho: invulnerable, but it ends with
;;;; Kenpachi free and a hoho-end J1 timed onto it (the live KH's bait, 60 % of the Hohos), and it costs a third of the flash-step gauge.
;;;; On that frame, a Kenpachi perceived recovering is (1) hit by J1 (else the pointer's NS) when the move fits his remaining recovery
;;;; (round 1's b2_a0), else (2) answered with a short Guard instead of the Hoho (this cell). Every other first free frame is left to the
;;;; generic CPU (the Hoho vs a meaty J1 is right), and the rest of the match is his merged style, unchanged.
(in-package :duel)

(defparameter *hkw-p* '(:easy 0.3 :normal 0.6 :hard 1.0)
  "Per first free frame after a knockdown (one roll): punish the recovering opponent in reach with J1 / the pointer's NS rather than
leave the frame to the generic wake-up Hoho. New 2026-11-10, cell b2_a0.")
(defparameter *hkw-margin* 0.3 "The move must reach the opponent's distance less this (m): reach + slide - margin >= the distance.")
(defparameter *hkw-lead* 0
  "The opponent's recovery (perceived frames left, less the perception delay) must outlast the move's startup by this many frames.")

(defparameter *hkw-guard-d* 1.6
  "When he is recovering but no move of his fits the recovery: Guard (mc-press, 20 frames) instead of the generic wake-up Hoho, with the
opponent within this many metres (NIL: no guard). The Hoho is invulnerable but ends with Kenpachi free and a hoho-end J1 timed onto it
(*KK-HEND-P*); guarding through the recovery keeps the flash-step (a Hoho is 100 of 300) and takes the next move on the guard. New
2026-11-10, cell b0_a0 (round 2): live KH 0.185 -> 0.27 (dev 300) and 0.175 -> 0.23 (seeds 600), 100 seeds a seat; 12 frames 0.22, 36 frames 0.185.")

(defparameter *hkb-below* 0.8
  "Own Reishi fraction at or below which a free WHITE Burst (P, idle / run, flash-step up) is worth its flash-step. Cell b3_a2 (round 1).")
(defparameter *hkb-range* 4.0
  "Kenpachi, as seen, at least this far (m) and not mid-move before the Reishi pot is drunk.")
(defparameter *hkb-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Chance to drink when it is open (one roll per episode, re-armed when the condition ends).")

(defparameter *hks-p* '(:easy 0.3 :normal 0.6 :hard 1.0)
  "Per Step of Kenpachi's seen coming at him (one roll): Hoho timed onto the J1 he cuts out of it. New 2026-11-10, cell b2_a0 (round 3).")
(defparameter *hks-band* 4.4
  "The Step is answered when Kenpachi is seen within this (m): his KI code steps in from 2.2-4.4 m (*KK-STEP-IN-BAND*) and cuts J1 out of the hop where it reaches.")
(defparameter *hks-hit* 19
  "The frame of his Step at which the J1 cut out of it first hits (the Step's J cancel pressed at frame 10, the J1 starts at 13, startup 6: seen in the logs).")
(defparameter *hks-lead* 8
  "The Hoho is pressed this many frames before that hit (its invulnerable frames 1-14 cover it; a hit within *PERFECT-LEAD* 12 of the press is perfect: counter and a 40 frame lock).")
(defparameter *hks-see* 3 "The Step is judged at this perceived frame: it has shown whether it closes in or hops back.")
(defparameter *hks-close* 0.4 "A Step comes at Hisagi when the distance is this much (m) shorter than before it (a back hop opens it).")

(defparameter *hkd-p* '(:easy 0.3 :normal 0.6 :hard 1.0)
  "Per Kenpachi's move start he can reach Hisagi with (one roll): a Hoho whose invulnerable frames cover the hit. New 2026-11-10, cell b2_a1 (round 3).")
(defparameter *hkd-min-left* 4
  "The move's hit must still be this many frames away as seen (less the perception delay): his J1 (startup 6) is over before HARD's 8 frame delay lets Hisagi see it.")
(defparameter *hkd-lead* 8 "The Hoho is pressed this many frames before the hit (its invulnerable frames 1-14; within *PERFECT-LEAD* 12 is perfect).")
(defparameter *hkd-margin* 0.5 "The move is answered when its reach + slide + this (m) reaches the distance.")

(defparameter *hkp-p* '(:easy 0.3 :normal 0.6 :hard 1.0)
  "Per stand-off episode (Kenpachi seen idle inside the poke band while Hisagi is free): one pointer-NS poke at him. New 2026-11-10, cell b2_a2 (round 3).")
(defparameter *hkp-min* 3.0 "The stand-off poke band, near edge (m): outside the dead zone of the NS, beyond the KI code's meaty distance 2.25-2.4.")
(defparameter *hkp-max* 3.8 "The stand-off poke band, far edge (m).")
(defparameter *hkp-idle* 24 "Kenpachi must have been seen idle this many frames (not about to step or press) before the poke.")

(defstruct (hks (:include hms) (:constructor make-hks ()))
  (hk-sw nil)                   ; Kenpachi was seen in a Step at the last step (the roll is made once per Step)
  (hk-d 9.0)                    ; the distance (m) at his last step with Kenpachi outside a Step
  (hk-at -1 :type fixnum)       ; the tick the Step answer's Hoho is pressed (-1: none planned)
  (hk-was :idle)                ; his own state at the last step
  (hk-armed t)                  ; the Reishi pot: NIL after a roll in this episode
  (hk-ev -1 :type fixnum)       ; the tick of the move start last rolled on (hkd)
  (hk-dat -1 :type fixnum)      ; the tick the move answer's Hoho is pressed (-1: none planned)
  (hk-idle 0 :type fixnum)      ; the frames Kenpachi has been seen idle inside the poke band (hkp); -1: rolled this episode
  (hk-tick 0 :type fixnum))     ; *MATCH-TICK* at the last call (a lower one: a new match)
(inline-readers hks)

(defun hkw-fits-p (mv s b d)
  "Does MV, started now, reach the opponent at D (not inside its dead zone) and land before his perceived recovery ends?"
  (and mv (plusp (mv-reach mv)) (<= (+ (mv-min-reach mv) 0.1) d (- (strat-reach mv) *hkw-margin*))
       (>= (snap-left-seen s b) (+ (mv-s mv) *hkw-lead*))))

(defun hkw-step (e b f kit s d st)
  "His first free frame after a knockdown: J1 (else the pointer's NS) onto a recovering opponent in reach. T when it pressed."
  (let ((fs (fighter-state f)) (was (hks-hk-was st)))
    (when (and (member was '(:air :down :wakeup)) (member fs '(:idle :run))
               (snap-recovering-p s))
      (let ((q (kit-command-move kit :q e)) (ns (kit-core-move kit :ns (mc-ptr f))))
        (let ((how (cond ((hkw-fits-p q s b d) :j1) ((hkw-fits-p ns s b d) :ns))))
          (when (and (not how) *hkw-guard-d* (< d *hkw-guard-d*) (brain-roll b *hkw-p*))
            (clog "~a hk guard at ~,1f left ~a" (side-name e) d (snap-left-seen s b))
            (mc-press b :guard)
            (return-from hkw-step t))
          (when (and how (brain-roll b *hkw-p*))
            (clog "~a hk punish ~a at ~,1f" (side-name e) how d)
            (if (eq how :j1) (progn (setf (brain-own-key b) -1) (cai-press b :quick 1)) (hr-sp b f s))
            (hr-taken b f)
            t))))))

(defun hkb-step (e b s d st)
  "The Reishi pot: one roll per episode (Reishi down, flash-step up), Kenpachi far and not mid-move: a free WHITE Burst. T when pressed."
  (if (not (and (eq (burst-ok-p e) :white) (<= (reishi-frac (gauges e)) *hkb-below*)))
      (progn (setf (hks-hk-armed st) t) nil)
      (when (and (hks-hk-armed st) (>= d *hkb-range*) (not (member (snap-state s) '(:move :cine :intro))))
        (setf (hks-hk-armed st) nil)
        (when (brain-roll b *hkb-p*)
          (cai-press b :awaken 1)
          t))))

(defun hks-step (e b f s d st)
  "Kenpachi's Step-in: once it is seen closing in, plan a Hoho onto the J1 he cuts out of it; press it on time. T while it holds the step."
  (let ((free (member (fighter-state f) '(:idle :run))))
    (cond ((not (eq (snap-state s) :step))
           (setf (hks-hk-sw st) nil (hks-hk-at st) -1 (hks-hk-d st) d)
           nil)
          (t
           (when (and (not (hks-hk-sw st)) (>= (snap-sf s) *hks-see*))
             (setf (hks-hk-sw st) t)
             (when (and free (<= d *hks-band*) (<= d (- (hks-hk-d st) *hks-close*)) (hoho-open-p e) (brain-roll b *hks-p*))
               (setf (hks-hk-at st) (+ *match-tick* (max 0 (- *hks-hit* *hks-lead* (snap-sf s) (brain-delay b)))))
               (clog "~a hk step plan at ~,1f (was ~,1f) for ~d" (side-name e) d (hks-hk-d st) (hks-hk-at st))))
          (let ((at (hks-hk-at st)))
            (when (and free (>= at 0))
              (cond ((< *match-tick* at) (vpad-stick! (pilot-vpad (pilot e)) 0f0 0f0) t)
                    (t (setf (hks-hk-at st) -1)
                       (when (<= *match-tick* (+ at 3))
                         (clog "~a hk step hoho at ~,1f" (side-name e) d)
                         (ai-press b :step 1 :modded t :act :hoho)
                         t)))))))))

(defun hkd-step (e b f s d st)
  "Kenpachi starts a move that reaches Hisagi and hits some frames on: one roll, a Hoho timed onto the hit. T while it holds the step."
  (let ((free (member (fighter-state f) '(:idle :run))))
    (when (and free (eq (snap-state s) :move) (snap-move s) (/= (snap-start s) (hks-hk-ev st)))
      (setf (hks-hk-ev st) (snap-start s))
      (let ((left (snap-lead-seen s b)))
        (when (and (>= left *hkd-min-left*) (<= d (+ (strat-reach (snap-move s)) *hkd-margin*)) (hoho-open-p e)
                   (brain-roll b *hkd-p*))
          (setf (hks-hk-dat st) (+ *match-tick* (max 0 (- left *hkd-lead*))))
          (clog "~a hk move plan at ~,1f left ~d" (side-name e) d left))))
    (let ((at (hks-hk-dat st)))
      (when (and free (>= at 0))
        (cond ((< *match-tick* at) (vpad-stick! (pilot-vpad (pilot e)) 0f0 0f0) t)
              (t (setf (hks-hk-dat st) -1)
                 (when (<= *match-tick* (+ at 3))
                   (clog "~a hk move hoho at ~,1f" (side-name e) d)
                   (ai-press b :step 1 :modded t :act :hoho)
                   t)))))))

(defun hkp-step (e b f kit s d st)
  "Kenpachi stands idle at the stand-off, outside the dead zone: one roll, a pointer-NS poke at him (he is not moving, nothing to dodge). T when pressed."
  (declare (ignorable kit))
  (cond ((not (and (eq (snap-state s) :idle) (<= *hkp-min* d *hkp-max*) (member (fighter-state f) '(:idle :run))))
         (setf (hks-hk-idle st) 0) nil)
        ((< (hks-hk-idle st) 0) nil)
        ((< (incf (hks-hk-idle st)) *hkp-idle*) nil)
        (t (setf (hks-hk-idle st) -1)
           (when (brain-roll b *hkp-p*)
             (clog "~a hk stand-off poke at ~,1f" (side-name e) d)
             (hr-sp b f s) (hr-taken b f) t))))

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (not (hks-p st)) (< *match-tick* (hks-hk-tick st)))
      (setf st (make-hks) (brain-style b) st))
    (setf (hks-hk-tick st) *match-tick*)
    (prog1 (or (hkw-step e b f kit s d st) (hkb-step e b s d st) (hks-step e b f s d st) (hkd-step e b f s d st) (hkp-step e b f kit s d st)
               (hisagi-merged-style e b f kit s d))
      (setf (hks-hk-was st) (fighter-state f)))))

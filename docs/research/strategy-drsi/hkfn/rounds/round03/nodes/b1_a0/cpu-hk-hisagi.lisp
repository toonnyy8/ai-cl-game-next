;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. The search's starting program: his merged style (cpu-hisagi-range.lisp) unchanged.
;;;;
;;;; Cell b1_a0 (round 3): b0_a2 + the range-control kite (round 1 b1_a1: back-step off a closing Kenpachi, then an NS poke) as a third rule.
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

(defparameter *hkk-p* '(:easy 0.25 :normal 0.6 :hard 1.0)
  "Kite: per approach event (Kenpachi perceived closing inside *HKK-NEAR* while Hisagi is free in the Shikai): back-step. 2026-11-10, b1_a0.")
(defparameter *hkk-near* 3.3
  "Kite: the perceived distance (m) under which a closing Kenpachi starts the event (his J1 reaches ~2 m + a slide; the view is 8-24 frames old).")
(defparameter *hkk-near-bankai* 4.2
  "Kite in the Bankai's ranged mode: the closing start distance (m); the range style owns everything inside 3.4 m, so this stretches its early back Step out to 4.2.")
(defparameter *hkk-far* 2.0 "Kite: not inside this (m): too late to back off, the merged style decides.")
(defparameter *hkk-poke-min* 2.9 "Kite: after the back-step the NS poke starts from this far (m) or more.")
(defparameter *hkk-poke-max* 6.0 "Kite: ... and from at most this far (m).")
(defparameter *hkk-window* 50 "Kite: frames after the back-step during which the poke may still follow.")

(defstruct (hks (:include hms) (:constructor make-hks ()))
  (hk-was :idle)                ; his own state at the last step
  (hk-armed t)                  ; the Reishi pot: NIL after a roll in this episode
  (hk-tick 0 :type fixnum)      ; *MATCH-TICK* at the last call (a lower one: a new match)
  (k-on nil)                    ; the kite: inside an approach event
  (k-go nil)                    ; its roll said yes
  (k-at -999 :type fixnum)      ; the tick of the back-step press
  (k-pd 99.0 :type single-float)) ; the perceived distance at the last free step
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

(defun hkk-step (e b f kit s d st &aux (bk (eq (fighter-form f) :bankai)) (near (if bk *hkk-near-bankai* *hkk-near*)))
  "Shikai kite. T when it pressed."
  (declare (ignorable kit))
  (let* ((v (if (> (hks-k-pd st) 50.0) 0.0 (max 0.0 (- (hks-k-pd st) d))))
         (closing (> v 0.004))
         (ss (snap-state s))
         (reel (member ss '(:stun :air :down :wakeup :cine :intro))))
    (setf (hks-k-pd st) (f32 d))
    (cond (reel (setf (hks-k-on st) nil) nil)
          ;; the poke after the back-step
          ((and (hks-k-go st) (< 0 (- *match-tick* (hks-k-at st)) *hkk-window*))
           (cond ((and (<= *hkk-poke-min* d *hkk-poke-max*) (not (eq ss :move)))
                  (setf (hks-k-go st) nil) (clog "~a hk kite poke at ~,1f" (side-name e) d)
                  (hr-sp b f s) (hr-taken b f) t)
                 (t nil)))
          ((>= d near) (setf (hks-k-on st) nil (hks-k-go st) nil) nil)
          ((and (not (hks-k-on st)) closing (>= d *hkk-far*))
           (setf (hks-k-on st) t (hks-k-go st) (brain-roll b *hkk-p*))
           (when (hks-k-go st)
             (setf (hks-k-at st) *match-tick*)
             (clog "~a hk kite back-step at ~,1f" (side-name e) d)
             (mc-press b :step-out) (hr-taken b f) t)))))

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (not (hks-p st)) (< *match-tick* (hks-hk-tick st)))
      (setf st (make-hks) (brain-style b) st))
    (setf (hks-hk-tick st) *match-tick*)
    (prog1 (or (hkw-step e b f kit s d st) (hkb-step e b s d st)
               (and (member (fighter-state f) '(:idle :run)) (hkk-step e b f kit s d st))
               (hisagi-merged-style e b f kit s d))
      (setf (hks-hk-was st) (fighter-state f)))))

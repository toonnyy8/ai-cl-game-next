;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. The search's starting program: his merged style (cpu-hisagi-range.lisp) unchanged.
;;;;
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

(defstruct (hks (:include hms) (:constructor make-hks ()))
  (hk-was :idle)                ; his own state at the last step
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

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (not (hks-p st)) (< *match-tick* (hks-hk-tick st)))
      (setf st (make-hks) (brain-style b) st))
    (setf (hks-hk-tick st) *match-tick*)
    (prog1 (or (hkw-step e b f kit s d st)
               (hisagi-merged-style e b f kit s d))
      (setf (hks-hk-was st) (fighter-state f)))))

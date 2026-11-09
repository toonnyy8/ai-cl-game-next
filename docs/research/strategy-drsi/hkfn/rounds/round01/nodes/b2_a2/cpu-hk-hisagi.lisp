;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. The search's starting program: his merged style (cpu-hisagi-range.lisp) unchanged.
;;;;
;;;; Cell b2_a0 (round 1). The one job: PUNISH THE MOVE KENPACHI WHIFFED INTO HIS WAKE-UP. Kenpachi's code presses into a knockdown of
;;;; Hisagi's on a known clock (the NS1a / J1 that lands on the wake-up's invulnerable frames, the meaty J1): in the logs two thirds of
;;;; Hisagi's first free frames find Kenpachi still in the recovery of such a move, a metre away. Hisagi's shared CPU spends that frame on
;;;; the wake-up Hoho (invulnerable, but it ends with Kenpachi free again). The Hoho gives nothing to a recovering opponent that he
;;;; could take: so on the first free frame after a knockdown, a Kenpachi perceived recovering whose recovery outlasts the move's
;;;; startup, in reach of J1 (else the pointer's NS), is hit by that move. Every other first free frame is left to the generic CPU
;;;; (the Hoho vs a meaty J1 is right), and the rest of the match is his merged style, unchanged.
(in-package :duel)

(defparameter *hkw-p* '(:easy 0.3 :normal 0.6 :hard 1.0)
  "Per first free frame after a knockdown (one roll): punish the recovering opponent in reach with J1 / the pointer's NS rather than
leave the frame to the generic wake-up Hoho. New 2026-11-10, cell b2_a0.")
(defparameter *hkw-margin* 0.3 "The move must reach the opponent's distance less this (m): reach + slide - margin >= the distance.")
(defparameter *hkw-lead* 0
  "The opponent's recovery (perceived frames left, less the perception delay) must outlast the move's startup by this many frames.")

(defparameter *hkw-any-p* '(:easy 0.3 :normal 0.6 :hard 1.0)
  "Per recovery of Kenpachi's seen outside the wake-up (one roll per recovery event): punish it with J1 / the pointer's NS if it fits.
New 2026-11-10, cell b2_a1.")
(defparameter *hkw-any-lead* 0 "Frames the recovery must outlast the move's startup by outside the wake-up.")

(defparameter *hkd-brawl-p* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "Kenpachi's KI code (which Hisagi plays outside the ranged mode) answers a move start of the opponent's with a J1 / NS1a race on this
chance (its *KK-BRAWL-P*: 0 / 0.1 / 0.6 there), else it dodges (Hoho, or the back Step): in this style the race is off, so a Kenpachi move
start is dodged (one roll per his move start, *KK-DODGE-P* / *KK-STEP-P*) and the whiff punished (HKW-ANY-STEP). New 2026-11-10, cell b2_a2.")

(defstruct (hks (:include hms) (:constructor make-hks ()))
  (hk-rec nil)                  ; inside a recovery of his already judged (rolled)
  (hk-go nil)                   ; ... and the roll said yes
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
    (setf (hks-hk-was st) fs)
    (when (and (member was '(:air :down :wakeup)) (member fs '(:idle :run)) (snap-recovering-p s))
      (let ((q (kit-command-move kit :q e)) (ns (kit-core-move kit :ns (mc-ptr f))))
        (let ((how (cond ((hkw-fits-p q s b d) :j1) ((hkw-fits-p ns s b d) :ns))))
          (when (and how (brain-roll b *hkw-p*))
            (clog "~a hk punish ~a at ~,1f" (side-name e) how d)
            (if (eq how :j1) (progn (setf (brain-own-key b) -1) (cai-press b :quick 1)) (hr-sp b f s))
            (hr-taken b f)
            t))))))

(defun hkw-any-step (e b f kit s d st)
  "Free in the neutral: Kenpachi recovering from a move, in reach of J1 / the NS, outlasting its startup: hit him. T when it pressed."
  (if (and (member (fighter-state f) '(:idle :run)) (snap-recovering-p s))
      (progn
        (unless (hks-hk-rec st) (setf (hks-hk-rec st) t (hks-hk-go st) (brain-roll b *hkw-any-p*)))
        (when (hks-hk-go st)
          (let* ((q (kit-command-move kit :q e)) (ns (kit-core-move kit :ns (mc-ptr f)))
                 (how (cond ((and (hkw-fits-p q s b d) (>= (snap-left-seen s b) (+ (mv-s q) *hkw-any-lead*))) :j1)
                            ((and (hkw-fits-p ns s b d) (>= (snap-left-seen s b) (+ (mv-s ns) *hkw-any-lead*))) :ns))))
            (when how
              (setf (hks-hk-go st) nil)
              (clog "~a hk whiff punish ~a at ~,1f" (side-name e) how d)
              (if (eq how :j1) (progn (setf (brain-own-key b) -1) (cai-press b :quick 1)) (hr-sp b f s))
              (hr-taken b f)
              t))))
      (progn (setf (hks-hk-rec st) nil) nil)))

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (not (hks-p st)) (< *match-tick* (hks-hk-tick st)))
      (setf st (make-hks) (brain-style b) st))
    (setf (hks-hk-tick st) *match-tick*)
    (or (hkw-step e b f kit s d st)
        (and (not (eq (fighter-form f) :bankai)) (hkw-any-step e b f kit s d st))
        (let ((*kk-brawl-p* *hkd-brawl-p*)) (hisagi-merged-style e b f kit s d)))))

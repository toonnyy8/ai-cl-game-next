;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. The search's starting program: his merged style (cpu-hisagi-range.lisp) unchanged.
;;;; Cell b1_a0 (round 1): one job, KITING in the Shikai. When Kenpachi walks in to the edge of his reach, Hisagi backs off by a Step
;;;; (once per approach, one roll) and then pokes with his pointer's NS from the new distance; everything else is the merged style.
(in-package :duel)

(defparameter *hkk-p* '(:easy 0.25 :normal 0.6 :hard 1.0)
  "Kite: per approach event (Kenpachi perceived closing inside *HKK-NEAR* while Hisagi is free in the Shikai): back-step. 2026-11-10, b1_a0.")
(defparameter *hkk-near* 3.3
  "Kite: the perceived distance (m) under which a closing Kenpachi starts the event (his J1 reaches ~2 m + a slide; the view is 8-24 frames old).")
(defparameter *hkk-near-bankai* 4.2
  "Kite in the Bankai's ranged mode: the closing start distance (m); the range style owns everything inside 3.4 m, so this stretches its early back Step out to 4.2.")
(defparameter *hkk-stand* 2.9
  "Kite: also start the event on a Kenpachi perceived :idle (standing off, not closing) inside this distance (m); 0 = closing only. Cell b1_a2.")
(defparameter *hkk-zone* '(3.6 5.5)
  "Zone poke: a closing Kenpachi perceived in this band (m) while Hisagi is free and no kite event runs: the pointer's NS once per approach (one roll, *HKK-ZP*). Cell b1_a2.")
(defparameter *hkk-zp* (quote (:easy 0.0 :normal 0.0 :hard 0.0)) "Zone poke: the roll per approach event.")
(defparameter *hkk-far* 2.0 "Kite: not inside this (m): too late to back off, the merged style decides.")
(defparameter *hkk-poke-min* 2.9 "Kite: after the back-step the NS poke starts from this far (m) or more.")
(defparameter *hkk-poke-max* 6.0 "Kite: ... and from at most this far (m).")
(defparameter *hkk-window* 50 "Kite: frames after the back-step during which the poke may still follow.")

(defstruct (hks (:include hms) (:constructor make-hks ()))
  (k-on nil)                    ; inside an approach event
  (z-on nil)                    ; the zone-poke event (one roll per approach)
  (k-go nil)                    ; its roll said yes
  (k-at -999 :type fixnum)      ; the tick of the back-step press
  (k-pd 99.0 :type single-float); the perceived distance at the last free step
  (k-tick 0 :type fixnum))      ; *MATCH-TICK* at the last call (a lower one: a new match)
(inline-readers hks)

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
          ((>= d near)
           (setf (hks-k-on st) nil (hks-k-go st) nil)
           (cond ((not (and closing (<= (first *hkk-zone*) d (second *hkk-zone*)))) (when (> d (second *hkk-zone*)) (setf (hks-z-on st) nil)) nil)
                 ((hks-z-on st) nil)
                 (t (setf (hks-z-on st) t)
                    (when (and (brain-roll b *hkk-zp*) (not (eq ss :move)))
                      (clog "~a hk zone poke at ~,1f" (side-name e) d)
                      (hr-sp b f s) (hr-taken b f) t))))
          ((and (not (hks-k-on st)) (>= d *hkk-far*)
                (or closing (and (eq ss :idle) (< d *hkk-stand*))))
           (setf (hks-k-on st) t (hks-k-go st) (brain-roll b *hkk-p*))
           (when (hks-k-go st)
             (setf (hks-k-at st) *match-tick*)
             (clog "~a hk kite back-step at ~,1f" (side-name e) d)
             (mc-press b :step-out) (hr-taken b f) t)))))

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (not (hks-p st)) (< *match-tick* (hks-k-tick st)))
      (setf st (make-hks) (brain-style b) st))
    (setf (hks-k-tick st) *match-tick*)
    (or (and (member (fighter-state f) '(:idle :run))
             (hkk-step e b f kit s d st))
        (hisagi-merged-style e b f kit s d))))

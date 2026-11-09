;;;; cpu-kh-ken.lisp — Kenpachi's style CPU against Hisagi (DUEL_AI_STRATEGY §8.19 round 5, step 5). KEN-KH-STYLE is a strategy's :fn (§9),
;;;; run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off by
;;;; default: only a strategy that names it plays it (the §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/khfn/. Cell b0_a0 (round 1): his KI style CPU (cpu-ki-ken.lisp) plus the wake-up bait.
(in-package :duel)

(defparameter *khf-bait-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Wake-up bait: per knockdown of Hisagi's (one roll as he goes down): do not press the meaty J1 of the KI code; stand at *KHF-BAIT-D* and
wait. Hisagi's wake-up Hoho (his CPU presses it on his first free frame whenever Kenpachi is seen within 2.4 m) turns the meaty J1 into a
perfect Hoho (his counter 60, Kenpachi locked 40 frames, his J1 J2 AS1 follow): 6 of 6 meaty J1s in seed 301 (HARD, live table). Standing
still gives the Hoho nothing to read; the KI code's hoho-end J1 (KKS-PLAN :hend) then lands on him as he reappears. New 2026-11-09, b0_a0.")
(defparameter *khf-bait-d* 2.3 "Wake-up bait: the distance (m) held while he is down (inside his wake-up Hoho trigger, 2.4 m, so it is spent on nothing).")
(defparameter *khf-bait-after* 4
  "Wake-up bait: frames added to the brain's perception delay after the last perceived down / wake-up step during which Kenpachi still
holds (his first free frame and Hoho press are not in the SNAP yet; a move started then runs into the Hoho).")

(defstruct (khs (:include kks) (:constructor make-khs ()))
  (hw :idle)                    ; Hisagi's perceived state at the last step
  (bait nil)                    ; this knockdown's roll said yes
  (last -999 :type fixnum))     ; the last tick the SNAP showed him down / waking up
(inline-readers khs)

(defun khf-bait-step (e b f s d st)
  "Hisagi down or just up with the bait roll yes: hold at *KHF-BAIT-D*. T when it decided."
  (let ((ss (snap-state s)) (now *match-tick*))
    (when (and (member ss '(:air :down :wakeup)) (not (member (khs-hw st) '(:air :down :wakeup))))
      (setf (khs-bait st) (brain-roll b *khf-bait-p*))
      (when (khs-bait st) (clog "~a khf bait armed" (side-name e))))
    (setf (khs-hw st) ss)
    (when (member ss '(:down :wakeup)) (setf (khs-last st) now))
    (when (and (khs-bait st) (member (fighter-state f) '(:idle :run)) (null (kks-plan st)))
      (cond ((or (member ss '(:down :wakeup))
                 (and (not (eq ss :hoho)) (<= (- now (khs-last st)) (+ (brain-delay b) *khf-bait-after*))))
             (cond ((> d (+ *khf-bait-d* 0.15)) (kk-stick e 1)) ((< d (- *khf-bait-d* 0.3)) (kk-stick e -1)) (t (kk-stick e 0)))
             t)
            (t (setf (khs-bait st) nil) nil)))))

(defun ken-kh-style (e b f kit s d)
  "Kenpachi's style against Hisagi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (null st) (not (khs-p st)) (< *match-tick* (kks-tick st)))
      (setf st (make-khs) (brain-style b) st))
    (cond ((khf-bait-step e b f s d st) (setf (kks-tick st) *match-tick*) t)
          ((khs-bait st) (let ((*kk-meaty-p* '(:easy 0.0 :normal 0.0 :hard 0.0))) (ken-ki-style e b f kit s d)))
          (t (ken-ki-style e b f kit s d)))))

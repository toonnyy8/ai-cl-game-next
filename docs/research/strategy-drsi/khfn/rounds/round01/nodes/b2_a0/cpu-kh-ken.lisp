;;;; cpu-kh-ken.lisp — Kenpachi's style CPU against Hisagi (DUEL_AI_STRATEGY §8.19 round 5, step 5). KEN-KH-STYLE is a strategy's :fn (§9),
;;;; run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off by
;;;; default: only a strategy that names it plays it (the §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/khfn/. The search's starting program: his KI style CPU (cpu-ki-ken.lisp) unchanged.
;;;;
;;;; Cell b2_a0 (round 1): 追擊 WHIFF PUNISH. Hisagi's ranged Bankai throws long, committed chains (TABA / TATAKI / ŌMEGURI S 30, NAGE,
;;;; KUBIKAKE S 24) and his WA / push moves end in a long recovery. Whenever the perceived Hisagi is in the recovery of a move that did not
;;;; hit (a whiff, or a block), KH-PUNISH answers it: the move he reaches with in the frames that are left (J1 or the pointer's NS), else
;;;; walks in so that J1 lands inside the recovery. One roll per Hisagi move (by difficulty). Everything else is ken-ki-style's.
(in-package :duel)

(defparameter *kh-punish-p* '(:easy 0.3 :normal 0.7 :hard 1.0)
  "Per Hisagi move that ends in a recovery without having hit (or blocked): take the punish (J1 / NS in reach, else the walk in). 2026-11-09,
cell b2_a0.")
(defparameter *kh-ns-p* '(:easy 0.0 :normal 0.3 :hard 0.6)
  "A punish inside the NS's reach and startup: the pointer's NS (more damage) rather than J1, one roll per punish. Never in a Bankai (an
NS costs Reishi there).")
(defparameter *kh-margin* 0.35 "The punish's reach margin (m): a J1 / NS starts when the target is within its reach + slide less this.")
(defparameter *kh-slack* 3 "Frames kept in hand: a punish needs the opponent's remaining recovery to exceed the move's startup + the walk + this.")
(defparameter *kh-walk-max* 0.0 "The farthest (m) a punish walks in from (the walk-in is off at 0: only a J1 / NS already in reach).")

(defvar *kh-states* (make-hash-table :test 'eq) "Per brain: the punish's state (a KHS), reset when *MATCH-TICK* goes back.")
(defvar *kh-last* 0 "*MATCH-TICK* at the last call (a lower one: a new match, the table starts over).")

(defstruct (khs (:constructor make-khs ()))
  (ev -2 :type fixnum)          ; the Hisagi move start (SNAP-START) the punish roll was made for
  (go nil))                     ; its roll said yes
(inline-readers khs)

(defun kh-state (b)
  (when (< *match-tick* *kh-last*) (clrhash *kh-states*))
  (setf *kh-last* *match-tick*)
  (or (gethash b *kh-states*) (setf (gethash b *kh-states*) (make-khs))))

(defun kh-reach (mv)
  "MV's reach + slide less *KH-MARGIN* (m): the farthest it starts from; 0 when it reaches nothing."
  (if (and mv (plusp (mv-reach mv))) (- (+ (mv-reach mv) (max 0.0 (mv-slide mv))) *kh-margin*) 0.0))

(defun kh-punish (e b f kit s d st)
  "Hisagi seen in the recovery of a move that missed or was blocked: J1 / the pointer's NS where it reaches inside the frames left, else the
walk in. T when it decided."
  (let ((mv (snap-move s)))
    (when (and mv (eq (snap-state s) :move) (eq (snap-phase s) :main) (not (eq (snap-contact s) :hit))
               (>= (snap-sf s) (snap-active-end s)) (<= d (max *kh-walk-max* 3.0)))
      (unless (= (snap-start s) (khs-ev st))                  ; (one roll a Hisagi move)
        (setf (khs-ev st) (snap-start s) (khs-go st) (brain-roll b *kh-punish-p*)))
      (when (khs-go st)
        (let* ((q (kit-command-move kit :q)) (ns (kit-core-move kit :ns (fighter-ptr f)))
               (rem (- (snap-left s) (brain-delay b)))          ; (his recovery left, now)
               (v (/ (kit-walk kit) 60.0))
               (bank (member (fighter-form f) '(:bankai :bankai-2)))
               (walk (lambda (mvv) (if (> d (kh-reach mvv)) (/ (- d (kh-reach mvv)) v) 0.0))))
          (flet ((ok (mvv) (and mvv (plusp (kh-reach mvv)) (> rem (+ (mv-s mvv) (funcall walk mvv) *kh-slack*)))))
            (cond ((and ns (not bank) (ok ns) (<= d (kh-reach ns)) (brain-roll b *kh-ns-p*))
                   (setf (khs-go st) nil (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01))
                   (clog "~a kh punish NS at ~,1f rem ~d" (side-name e) d rem)
                   (cai-sp b f s 1 t) (kk-stick e 0) t)
                  ((and (ok q) (<= d (kh-reach q)))
                   (setf (khs-go st) nil (brain-own-key b) -1)
                   (clog "~a kh punish J1 at ~,1f rem ~d" (side-name e) d rem)
                   (cai-press b :quick 1) (kk-stick e 0) t)
                  ((and (ok q) (<= d *kh-walk-max*)) (kk-stick e 1) t)                   ; (in: J1 lands inside his recovery)
                  (t nil))))))))

(defun ken-kh-style (e b f kit s d)
  "Kenpachi's style against Hisagi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (kh-state b)))
    (or (and (member (fighter-state f) '(:idle :run)) (kh-punish e b f kit s d st))
        (ken-ki-style e b f kit s d))))

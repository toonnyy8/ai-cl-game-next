;;;; cpu-kh-ken.lisp — Kenpachi's style CPU against Hisagi (DUEL_AI_STRATEGY §8.19 round 5, step 5). KEN-KH-STYLE is a strategy's :fn (§9),
;;;; run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off by
;;;; default: only a strategy that names it plays it (the §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/khfn/. Cell b1_a0: one code per form (Ichigo's KI code while sealed, his own once released).
(in-package :duel)

(defvar *khk-store* (make-hash-table :test 'eq) "Per brain: (KKS . IKST), the two codes' own match state (they cannot share BRAIN-STYLE).")
(defvar *khk-tick* 0 "The last MATCH-TICK seen by KEN-KH-STYLE (the store is cleared when it goes back: a new match).")

(defparameter *khk-sealed-forms* '(:base)
  "Kenpachi's forms in which Ichigo's KI code plays (the others play his own KI code). Step 4: Ichigo's code took 0.95 of the live table's
judgements in his base form and none released.")

(defun khk-run (b fn slot e f kit s d)
  "Run FN with BRAIN-STYLE swapped to this brain's SLOT (:kks or :iks) state, and keep what it leaves there."
  (let ((cell (or (gethash b *khk-store*) (setf (gethash b *khk-store*) (cons nil nil)))))
    (setf (brain-style b) (if (eq slot :kks) (car cell) (cdr cell)))
    (prog1 (funcall fn e b f kit s d)
      (if (eq slot :kks) (setf (car cell) (brain-style b)) (setf (cdr cell) (brain-style b))))))

(defparameter *khk-stale* '(:easy 2700 :normal 2100 :hard 1500)
  "Frames (by difficulty) with no Konpaku change on either side before the sealed form's patient code (Ichigo's KI code: it waits at its
hover band for the other to come) hands the step to his own engaging KI code until something lands. Written 2026-11-09 (b1_a0): two waiting
codes met at 3-4 m and drew 24 of 24 time-outs against Hisagi driven by Ichigo's code.")

(defvar *khk-seen* nil "(MATCH-TICK of the last Konpaku change . the two Konpaku then), the stalemate clock; reset with the store.")

(defun khk-stale-p (e b f)
  "T when neither side's Konpaku has changed for *KHK-STALE* frames (the clock restarts at every change)."
  (let ((k0 (gauges-konpaku (gauges e))) (k1 (gauges-konpaku (gauges (fighter-opp f)))))
    (unless (and *khk-seen* (= k0 (second *khk-seen*)) (= k1 (third *khk-seen*)))
      (setf *khk-seen* (list *match-tick* k0 k1)))
    (> (- *match-tick* (first *khk-seen*)) (getf *khk-stale* (brain-difficulty b) 600))))

(defun ken-kh-style (e b f kit s d)
  "Kenpachi's style against Hisagi: T when it decided this step, NIL for the MCTS / the generic core CPU. Sealed: Ichigo's KI code, unless the
match has stood still (*KHK-STALE*); released: his own KI code."
  (when (< *match-tick* *khk-tick*) (clrhash *khk-store*) (setf *khk-seen* nil))
  (setf *khk-tick* *match-tick*)
  (let ((stale (khk-stale-p e b f)))
    (if (and (member (fighter-form f) *khk-sealed-forms*) (not stale))
        (khk-run b 'ichigo-ki-style :iks e f kit s d)
        (khk-run b 'ken-ki-style :kks e f kit s d))))

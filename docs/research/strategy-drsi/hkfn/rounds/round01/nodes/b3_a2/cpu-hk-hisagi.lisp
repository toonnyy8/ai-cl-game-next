;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. Cell b3_a2 (round 1): ONE JOB, the Reishi pot: about half of the matches against Kenpachi's bait end on
;;;; the clock at 9 - 9 Konpaku, decided by Reishi % (Kenpachi near 1300, Hisagi chipped to 100-1200). A free WHITE Burst (P while idle / run, flash-step
;;;; >= *fs-burst*) regenerates ~70 Reishi a second; the shared CPU only bursts out of combos, so this style drinks it when Reishi is down.
(in-package :duel)

(defparameter *hkb-below* 0.8
  "Own Reishi fraction at or below which a free WHITE Burst is worth its flash-step.")
(defparameter *hkb-range* 4.0
  "Kenpachi, as seen, at least this far (m) and not mid-move: the 20 invulnerable frames then the drain are not walked into.")
(defparameter *hkb-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Chance to drink when it is open (one roll per episode: flash-step up, Reishi down, safe; a new episode after the burst).")

(defstruct (hkb (:include hms) (:constructor make-hkb ()))
  (armed t)                     ; NIL after a roll in this episode (re-armed when the condition ends)
  (tick 0 :type fixnum))        ; *MATCH-TICK* at the last call (a lower one: a new match)
(inline-readers hkb)

(defun hkb-open-p (e)
  "Is a WHITE Burst allowed and Reishi down?"
  (and (eq (burst-ok-p e) :white) (<= (reishi-frac (gauges e)) *hkb-below*)))

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (let ((x (brain-style b))) (if (and (hkb-p x) (>= *match-tick* (hkb-tick x))) x (setf (brain-style b) (make-hkb))))))
    (setf (hkb-tick st) *match-tick*)
    (if (not (hkb-open-p e))
        (setf (hkb-armed st) t)
        (when (and (hkb-armed st) (>= d *hkb-range*) (not (member (snap-state s) '(:move :cine :intro))))
          (setf (hkb-armed st) nil)
          (when (brain-roll b *hkb-p*)
            (cai-press b :awaken 1)
            (return-from hisagi-hk-style t))))
    (hisagi-merged-style e b f kit s d)))

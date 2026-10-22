;;;; rogue-rules.lisp — DANGAI 斷界行 (docs/duel/DUEL_ROGUE.md) as pure rules: the run's layout, the ramp per step, the
;;;; rest doors, the doors between steps, a rest's carry. Plain CL over endless-rules.lisp, host-tested
;;;; (tests/duel-rules/rogue.lisp); the mode (the doors screen, the record) is rogue.lisp over endless.lisp.
;;;; No character names in here.
(in-package :duel)

(defparameter *rogue-steps* 10 "A run: steps 1-10, the boss at 10; after it the continuation (DUEL_ROGUE §2).")
(defparameter *rogue-boss-row* '(10 2 100 t 150)
  "The boss's ramp row: two steps over any floor (HARD), awakened at FIGHT, Reishi 150 % (DUEL_ROGUE §5, R4).")
(defparameter *rogue-rest-from* 4 "The first step that may offer a rest door (DUEL_ROGUE §3).")
(defparameter *rogue-rest-max* 2 "A run offers at most this many rest doors (DUEL_ROGUE §3).")
(defparameter *rogue-rest-konpaku* 3 "A rest door: Konpaku + this, at most *KONPAKU-MAX* (DUEL_ROGUE §3).")

(defun rogue-step-kind (step)
  "STEP's kind (1-based): :boss at *ROGUE-STEPS*, :elite every third step (3 6 9, and on in the continuation), :normal."
  (cond ((= step *rogue-steps*) :boss) ((zerop (mod step 3)) :elite) (t :normal)))

(defun rogue-ramp (step)
  "STEP's ramp row (stage steps awaken awakened reishi-%): a normal step ENDLESS's own; an elite the row two stages on with
one more difficulty step (at most 2); the boss *ROGUE-BOSS-ROW*."
  (case (rogue-step-kind step)
    (:boss *rogue-boss-row*)
    (:elite (let ((r (copy-list (endless-ramp (+ step 2))))) (setf (second r) (min 2 (1+ (second r)))) r))
    (t (endless-ramp step))))

(defun rogue-lcg-at (seed step salt)
  "The doors' own draw for (SEED, STEP, SALT): ENDLESS-LCG, never SIM-RND (how a fight goes never changes the doors)."
  (endless-lcg (endless-lcg (+ (* seed 7919) (* step 104729) (* salt 15485863) 3))))

(defun rogue-rest-steps (seed)
  "The steps of run SEED whose second door is a rest: normal steps from *ROGUE-REST-FROM* before the boss, a 1-in-3 draw
each, at most *ROGUE-REST-MAX* (pure in SEED, so the doors replay)."
  (let ((out nil))
    (loop for st from *rogue-rest-from* below *rogue-steps*
          when (and (eq (rogue-step-kind st) :normal) (< (length out) *rogue-rest-max*)
                    (zerop (mod (floor (rogue-lcg-at seed st 1) 65536) 3)))
            do (push st out))
    (nreverse out)))

(defun rogue-doors (seed step prev roster)
  "The doors before STEP (2 on) of run SEED, PREV the last opponent fought: plists (:kind :fight :opponent c) or
(:kind :rest). Two doors with two different opponents, neither PREV while ROSTER allows (one door when only one is
left); the boss step one door; on a rest step (ROGUE-REST-STEPS) the second door is the rest."
  (let* ((pool (or (remove prev roster) roster)) (n (length pool))
         (x (rogue-lcg-at seed step 2)) (i (mod (floor x 65536) n))
         (j (mod (+ i 1 (mod (floor (endless-lcg x) 65536) (max 1 (1- n)))) n))
         (a (list :kind :fight :opponent (nth i pool))))
    (cond ((eq (rogue-step-kind step) :boss) (list a))
          ((member step (rogue-rest-steps seed)) (list a (list :kind :rest)))
          ((= n 1) (list a))
          (t (list a (list :kind :fight :opponent (nth j pool)))))))

(defun rogue-rest (carry)
  "CARRY (ENDLESS-CARRY's plist) after a rest door: Konpaku + *ROGUE-REST-KONPAKU*, at most *KONPAKU-MAX*."
  (let ((c (copy-list carry)))
    (setf (getf c :konpaku) (min *konpaku-max* (+ (getf c :konpaku) *rogue-rest-konpaku*)))
    c))

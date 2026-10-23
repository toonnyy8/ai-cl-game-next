;;;; run-mods.lisp — DANGAI's run modifier table (docs/duel/DUEL_ROGUE.md §4.4): the held rewards folded into one plist
;;;; (*RUN-MODS*) that applies to one fighter (*RUN-MODS-WHO*, P1), read at the rule points through RMOD and its two
;;;; shorthands; the pure helpers the rule points share (the damage multipliers, the Konpaku a soul break takes) and the
;;;; per-fighter run state (RMST). Plain CL, host-tested (tests/duel-rules/runmods.lisp). With *RUN-MODS* NIL every
;;;; reader returns its DEFAULT (RMOD-X / RMOD-PLUS return their X itself): no float operation, no draw, no consing.
;;;; The rule points: combat.lisp (APPLY-HIT, SETTLE-KONPAKU, AWAKEN!, GAUGE-SYSTEM), fighter.lisp (HOHO-READY-P,
;;;; START-HOHO, START-MOVE, GUARD-HELD-P, DEFENDER-STATE, KIT-COMMAND-OK-P), ai.lisp (AI-KIKON-FUTILE-P).
(in-package :duel)

(defvar *run-mods* nil
  "The run modifier plist of the DANGAI stage being fought (DUEL_ROGUE §4.4: :dmg 1.2 :kikon-past 1 ...), NIL outside one
(every rule point then reads its old value). Set with *RUN-MODS-WHO* at each stage start by the run layer.")
(defvar *run-mods-who* nil "The fighter entity *RUN-MODS* applies to (P1), or NIL.")
(defvar *run-mods-test* nil
  "Debug 84400-84499 (debug.lisp RUN-MODS-DEBUG): a test plist START-MATCH installs on every match's P1 (NIL = none).")

(defun rmod (e key default)
  "KEY of the run modifier table for fighter E: DEFAULT unless a run is active (*RUN-MODS*) and E is *RUN-MODS-WHO*."
  (if (and *run-mods* (eql e *run-mods-who*)) (getf *run-mods* key default) default))

(defun rmod-x (e key x)
  "X times E's multiplier KEY, or X itself (the same object: no float operation) when E has none."
  (let ((m (rmod e key nil))) (if m (* x m) x)))

(defun rmod-plus (e key x)
  "X plus E's count / fraction KEY, or X itself when E has none."
  (let ((n (rmod e key nil))) (if n (+ x n) x)))

(defun run-mods-on-p (e) "Does the run modifier table apply to fighter E now?" (and *run-mods* (eql e *run-mods-who*)))

;;; ---------------------------------------------------------------- pure helpers (host-tested)
(defparameter *run-regen-delay* 180 "§4.4 :regen: frames unhit before the Reishi regen starts (回生: 3 s).")
(defparameter *run-ender-window* 60 "§4.4 :ender-sp-dmg: an SP started within this many frames of a link-3 ender's hit (卍禍).")
(defparameter *run-perfect-window* 120 "§4.4 :perfect-taken: frames after a perfect Hoho the damage taken is cut (鬼道).")
(defun run-dmg-mult (mods &key red ender sp ender-sp post-burst)
  "The multiplier on a hit the table's holder deals (§4.4): :dmg, x :red-dmg while RED, x :ender-dmg on a link-3 ENDER,
x :sp-dmg on an SP, x :ender-sp-dmg on an SP started off an ender (ENDER-SP), x :post-burst-dmg on the first hit after
a Hoho / Burst (POST-BURST). Stacked multiplicatively; 1.0 for an empty MODS."
  (* (getf mods :dmg 1.0)
     (if red (getf mods :red-dmg 1.0) 1.0)
     (if ender (getf mods :ender-dmg 1.0) 1.0)
     (if sp (getf mods :sp-dmg 1.0) 1.0)
     (if (and sp ender-sp) (getf mods :ender-sp-dmg 1.0) 1.0)
     (if post-burst (getf mods :post-burst-dmg 1.0) 1.0)))

(defun run-taken-mult (mods &key breaker awake perfect)
  "The multiplier on a hit the table's holder takes (§4.4): x :breaker-taken from a Breaker window (BREAKER), x
:awake-taken while awakened (AWAKE), x :perfect-taken within 120 f of his perfect Hoho (PERFECT). 1.0 for an empty MODS."
  (* (if breaker (getf mods :breaker-taken 1.0) 1.0)
     (if awake (getf mods :awake-taken 1.0) 1.0)
     (if perfect (getf mods :perfect-taken 1.0) 1.0)))

(defun run-konpaku-result (konpaku count soul-break plus past)
  "KIKON-RESULT with the table's counts (§4.2 \"Konpaku taken, with 6 and 25\"): COUNT (+ *SOUL-BREAK-EXTRA* on a
SOUL-BREAK) + PLUS, then the per-event cap (*KIKON-MAX-EVENT* / *SOUL-BREAK-MAX-EVENT*), then + PAST past the cap, at
most KONPAKU. PLUS = PAST = 0 is KIKON-RESULT exactly. Values: konpaku-left lost ko-p."
  (let* ((lost (min konpaku (+ past (min (if soul-break *soul-break-max-event* *kikon-max-event*)
                                         (+ count (if soul-break *soul-break-extra* 0) plus)))))
         (left (- konpaku lost)))
    (values left lost (<= left 0))))

(defun run-regen-heal (unhit max frac)
  "Reishi the :regen key (FRAC of MAX a second) pays on a frame UNHIT frames after the last hit taken: nothing before
*RUN-REGEN-DELAY*, then the whole points crossed on that frame (BURST-HEAL's spread: a whole second pays exactly the rate)."
  (let ((n (- unhit *run-regen-delay*)))
    (if (plusp n) (burst-heal n (round (* frac max))) 0)))

(defparameter *run-mods-tests*
  '((:dmg 1.5) (:ender-dmg 2.0) (:red-dmg 2.0) (:post-burst-dmg 2.0) (:post-burst-fs 0.5) (:sp-dmg 2.0) (:ender-sp-dmg 2.0)
    (:guard-drain 2.0) (:kikon-plus 1) (:sb-plus 1) (:kikon-past 2) (:sb-past 2) (:kikon-guard t) (:kikon-seal t) (:revive 1)
    (:armor-on-soul-loss 3) (:armor-on-awaken 3) (:red-armor 2) (:red-no-guard t) (:chip-taken 0.5) (:breaker-taken 0.5)
    (:awake-taken 0.5) (:perfect-taken 0.4) (:perfect-fs 0.25) (:perfect-reiatsu 0.5) (:regen 0.05) (:fs-regen 2.0)
    (:hoho-cost 0.5) (:reiatsu-regen 2.0) (:gg-regen 2.0) (:awaken-heal 0.2))
  "Debug 84400+k (debug.lisp RUN-MODS-DEBUG): the k-th rule-point key of DUEL_ROGUE §4.4 (its table's order, :perfect-fs and :perfect-reiatsu two
keys) with a test value, as a one-key plist on P1 (RUN-MODS-DEBUG). Values are tests, not the rewards' (the multipliers
x2 / x0.5 to show in a log).")

;;; ---------------------------------------------------------------- per-fighter run state
(defstruct rmst
  "One fighter's DANGAI run state (FIGHTER-RM, made on first use while the table applies to him: a fresh fighter every
match, so every field resets per match). Frame counters count sim frames (GAUGE-SYSTEM: not in a cinematic or hitstop)."
  (post-burst nil)        ; a Hoho / Burst started: his next hit that lands is the first after it (:post-burst-dmg / -fs)
  (ender-left 0)          ; frames left of the window after his link-3 ender hit (:ender-sp-dmg)
  (ender-sp nil)          ; the SP he is in started inside that window
  (perfect-left 0)        ; frames left after his perfect Hoho (:perfect-taken)
  (unhit 0)               ; frames since he last lost Reishi to the opponent (:regen)
  (armor-t 0)             ; frames left of a timed armour hit (:armor-on-soul-loss, :armor-on-awaken)
  (red-cd 0)              ; frames until the red armour hit is back (:red-armor; 0 = up while he is red)
  (revived nil)           ; :revive was used this match (once a stage)
  (frames 0))             ; sim frames he has run under the table (its periodic "duel runmod state" line)

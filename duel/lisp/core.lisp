;;;; core.lisp — SOUL DUEL's core system (docs/duel/DUEL_CORE.md; the user's note DUEL_CORE_DOC.zh-TW.md): the attack / SP
;;;; triangle, as plain CL (host-tested, tests/duel-rules/triangle.lisp). Two buttons decide a fight: ATTACK (J) and SP
;;;; (Mod + J). Classes of a move:
;;;;   :na  attack from neutral (a string NA1 -> NA2 -> NA3, each link needs a hit or a cancel)
;;;;   :ns  SP from neutral: a rhythm of segments that continue whether or not they connect; the segment is picked by the pointer
;;;;   :as  SP after an attack hit: the combo's last strike, writes the pointer (a turn move: super armour)
;;;;   :sa  an attack pressed in an NS gap (a turn move: super armour)
;;;; CORE-VERDICT is the note's table; the Kikon / Soul Break counts are the pointer's profiles (DUEL_CORE.md §3).
(in-package :duel)

(defparameter *core-classes* '(:na :ns :as :sa)
  "The classes of a move the triangle judges (a move of none is judged as before: a clean hit).")

(defun core-verdict (att def &key simul att-t def-t)
  "What the hit of a move of class ATT does to a defender who is inside the startup or active frames of a move of class DEF
(the note's table, 判定表): :HIT it lands; :CANCEL no damage, both go on (the attacker's chain opens as if it hit); :ABSORB
the defender's super armour takes it (nothing happens, the defender goes on). SIMUL: the defender's own hit lands in the
same step: same-class ties cancel (「先打到的贏，如果同時打中就相消」). ATT-T / DEF-T: the frames the two moves started on
(AS against SA: the later start wins, the same frame cancels). A DEF of NIL (not in a classed move) is a clean hit."
  (cond ((null def) :hit)
        ((null att) :hit)
        (t (ecase att
             (:na (ecase def (:na (if simul :cancel :hit)) (:ns :cancel) (:as :cancel) (:sa :absorb)))
             (:ns (ecase def (:na :cancel) (:ns (if simul :cancel :hit)) (:as :absorb) (:sa :cancel)))
             (:as (ecase def (:na :cancel) (:ns :hit) ((:as :sa) (core-later att-t def-t))))
             (:sa (ecase def (:na :hit) (:ns :cancel) ((:as :sa) (core-later att-t def-t))))))))

(defun core-later (att-t def-t)
  "Two turn moves: the one that started later wins (:HIT when the attacker's move did, :ABSORB when the defender's), the
same frame (or an unknown start) cancels."
  (cond ((or (null att-t) (null def-t) (= att-t def-t)) :cancel)
        ((> att-t def-t) :hit)
        (t :absorb)))

(defun core-bounces-p (att def)
  "Does a cancel of class ATT against DEF end both moves and push the fighters apart? Only a same-class tie does (the note's
rule 1: NA against NS cancel and each goes on with its sequence; NA against NA, NS against NS end in neutral)."
  (eq att def))

;;; ---------------------------------------------------------------- the sequence (what a press means)
(defun core-press-class (context button landed)
  "The class of the move a press starts. CONTEXT: where the fighter is: :NEUTRAL, :NA (inside an NA string link), :NS (inside
an NS segment), :SA (inside the SA), :AS (the combo is over: nothing starts). BUTTON :ATTACK or :SP. LANDED: the move he is in
has hit (or been cancelled: treated as a hit). The note's rules: an attack continues only after a hit; an SP after an
attack hit is AS (rule 4, and inside an NS sequence rule 5); an SP inside an NS segment continues it hit or not (rule 2); an
attack inside an NS segment is SA. Returns :NA :NS :AS :SA, :NA-CONT / :NS-CONT (a link / a segment of the same class), or NIL."
  (ecase context
    (:neutral (ecase button (:attack :na) (:sp :ns)))
    (:na (and landed (ecase button (:attack :na-cont) (:sp :as))))
    (:ns (ecase button (:attack :sa) (:sp :ns-cont)))
    (:sa (and landed (ecase button (:attack nil) (:sp :as))))
    (:as nil)))

(defun core-class-after (class)
  "The CONTEXT a move of CLASS leaves (CORE-PRESS-CLASS's first argument)."
  (ecase class ((:na :na-cont) :na) ((:ns :ns-cont) :ns) (:sa :sa) (:as :as)))

(defparameter *core-pointer-max* 3 "The pointer runs 1 .. this: the NA link an AS followed.")

(defun core-clamp-pointer (n) "N clamped to 1 .. *CORE-POINTER-MAX*." (max 1 (min *core-pointer-max* n)))

(defun core-as-pointer (presses)
  "The pointer an AS writes: the number of attack presses since neutral (NA1 / NA2 / NA3 -> 1 / 2 / 3; the SA counts as one),
clamped."
  (core-clamp-pointer presses))

;;; ---------------------------------------------------------------- the pointer's Kikon / Soul Break profiles
(defparameter *core-kikon-max* 4 "Konpaku one Kikon takes at most (the old *KIKON-MAX-EVENT*).")
(defparameter *core-soul-break-max* 5 "Konpaku one Soul Break takes at most (the old *SOUL-BREAK-MAX-EVENT*).")

(defun core-kikon-count (base pointer red)
  "Konpaku a Kikon of a fighter whose form is worth BASE takes, struck by an SP of POINTER's style (DUEL_CORE.md §3). 1: the
heavy-damage style, one less (at least 1). 2: red and zero are the same line: against a RED victim the Kikon takes what a Soul
Break would (BASE + 1). 3: the finisher style, one less."
  (ecase (core-clamp-pointer pointer)
    (1 (min *core-kikon-max* (max 1 (1- base))))
    (2 (if red (min *core-soul-break-max* (1+ base)) (min *core-kikon-max* base)))
    (3 (min *core-kikon-max* (max 1 (1- base))))))

(defun core-soul-break-count (base pointer)
  "Konpaku a Soul Break takes: BASE + 1 (the old rule), + 2 more for the finisher style (POINTER 3), at most 5."
  (min *core-soul-break-max* (+ base 1 (if (= (core-clamp-pointer pointer) 3) 2 0))))

(defun core-kikon-cancel-p (victim-red victim-attacks)
  "Is the Kikon's follow-up strike cancelled? Only by the victim's attack (both bounce to neutral, DUEL_CORE.md §4), never
when he is RED (the must-hit line)."
  (and victim-attacks (not victim-red)))

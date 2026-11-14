;;;; core.lisp — SOUL DUEL's core system (docs/duel/DUEL_CORE.md; the user's note DUEL_CORE_DOC.zh-TW.md): the attack / SP
;;;; triangle, as plain CL (host-tested, tests/duel-rules/triangle.lisp). Two buttons decide a fight: ATTACK (J) and SP
;;;; (Mod + J). Classes of a move:
;;;;   :na  attack from neutral (a string NA1 -> NA2 -> NA3, each link needs a hit or a cancel)
;;;;   :ns  SP from neutral: a rhythm of segments that continue whether or not they connect; the segment is picked by the pointer
;;;;   :as  SP after an attack hit: the combo's last strike, writes the pointer (a turn move: super armour)
;;;;   :sa  an attack pressed in an NS gap (a turn move: super armour)
;;;; CORE-VERDICT is the note's table; the Kikon / Soul Break counts are the pointer's profiles (DUEL_CORE.md §3).
(in-package :duel)


(defun core-verdict (att def &key simul att-t def-t)
  "What the hit of a move of class ATT does to a defender who is inside the startup or active frames of a move of class DEF
(the note's table, 判定表): :HIT it lands; :CANCEL no damage, both go on (both moves count as landed:
their chains open, DUEL_CORE §2.1); :ABSORB
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


(defun core-cancel-land-sf (land-sf sf first-hit)
  "A fighter's FIGHTER-LAND-SF (his cancel windows open from it, CANCEL-OPEN-P) after a cross-class cancel he took part in, either side
(DUEL_CORE §2.1): one already set (>= 0) is kept; else his move frame SF, but not before his move's first hit frame FIRST-HIT (MV-FIRST-HIT:
S for a move with no hit window). The side whose hit was judged is on that hit's frame (SF); the other is often still in his startup,
and a real hit never opens his AS / SP / Hoho / guard cancels before his own hit frame, so neither does a cancel."
  (if (>= land-sf 0) land-sf (max sf first-hit)))

(defun core-cancelled-p (xch cls-t)
  "Has the move in play (started on tick CLS-T) taken part in a cancel? An exchange (FIGHTER-XCH, -1 when none) opened on or after its
start: a cancel opens one on both sides (CORE-XCH-OPEN!). A whiff or a real hit opens none."
  (>= xch cls-t 0))

(defun core-sa-open-p (sf s a cancelled)
  "May an NS segment's SA start at move frame SF (S / A: the segment's startup / active frames)? Once its active frames are over, or at
once from the frame the segment took part in a cancel (CANCELLED, CORE-CANCELLED-P): the cancel's out (the user, 2026-11-14:
「我發現劍八的壓制能力異常強大，跟其他角色相消後換攻擊時必勝」, 「好 1+2」; DUEL_CORE §2.1.2). Before it the NS side was locked to its
segment's active end while the J side's AS started at once (the later start wins: CORE-LATER), so the J side always had the free turn."
  (or cancelled (>= sf (+ s a))))


;;; ---------------------------------------------------------------- the sequence (what a press means)
;;; (*CORE-POINTER-MAX*, *CORE-KIKON-MAX* and *CORE-SOUL-BREAK-MAX* are shared knobs: tuning.lisp, the core system's block)

(defun core-clamp-pointer (n) "N clamped to 1 .. *CORE-POINTER-MAX*." (max 1 (min *core-pointer-max* n)))

(defun core-as-pointer (presses &optional by-press)
  "The pointer an AS writes: the number of attack presses since neutral (NA1 / NA2 / NA3 -> 1 / 2 / 3; the SA counts as one),
clamped; with BY-PRESS (a kit's :core :as-by-press, the pointer after press 1, 2 ...) that list's entry, its last past its end
(Ichigo's five J, the user 2026-10-28: 「J1, J2 對應指針一 / J3, J4 對應指針二 / J5 對應指針三」: (1 1 2 2 3))."
  (if by-press
      (nth (1- (max 1 (min (length by-press) presses))) by-press)
      (core-clamp-pointer presses)))

;;; ---------------------------------------------------------------- the pointer's Kikon / Soul Break profiles
(defun core-kikon-count (base pointer red)
  "Konpaku a Kikon of a fighter whose form is worth BASE takes, struck by an SP of POINTER's style (DUEL_CORE.md §3). 1: the
heavy-damage style, one less (at least 1). 2: red and zero are the same line: against a RED victim the Kikon takes what a Soul
Break would (BASE + 1). 3: the finisher style, one less."
  (ecase (core-clamp-pointer pointer)
    (1 (min *core-kikon-max* (max 1 (1- base))))
    ((2 4) (if red (min *core-soul-break-max* (1+ base)) (min *core-kikon-max* base)))
    (3 (min *core-kikon-max* (max 1 (1- base))))))

(defun core-soul-break-count (base pointer)
  "Konpaku a Soul Break takes: BASE + 1 (the old rule), + 2 more for the finisher style (POINTER 3), at most 5."
  (min *core-soul-break-max* (+ base 1 (if (= (core-clamp-pointer pointer) 3) 2 0))))

(defun core-kikon-ptr (cls sp-ptr ptr)
  "The pointer whose style the SP in play has: in an NS / AS (CLS) the one it started under (SP-PTR: an AS's is the pointer before
its write, DUEL_CORE §4), else his pointer PTR (the next SP's). (core-sim.lisp CORE-KONPAKU-RESULT's Soul Break, webhud AT-STAKE.)"
  (if (member cls '(:ns :as)) sp-ptr ptr))

(defun core-kikon-stake (konpaku base cls sp-ptr ptr red &optional fixed)
  "Of KONPAKU flames, how many a core Kikon would take if it struck now (the plate's red hint, webhud AT-STAKE; R15d, 2026-11-14:
it showed the form's BASE and ignored the pointer): FIXED (the count his SP's hit fixed, FIGHTER-KIKON-N, while its follow-up runs),
else CORE-KIKON-COUNT of BASE, the pointer of the SP in play (CORE-KIKON-PTR) and RED (the victim's); capped only by what is left,
as CORE-KONPAKU-RESULT settles it."
  (min konpaku (or fixed (core-kikon-count base (core-kikon-ptr cls sp-ptr ptr) red))))


;;;; fuzzy.lisp — the CPU's fuzzy reactive layer (docs/duel/DUEL_AI_MCTS.md stage 1; the user, 2026-11-08: 「將核心的 AI 系統全置換成
;;;; MCTS + fuzzy + 學習型 AI」, fuzzy: 「兩者都用」). Plain CL, host-tested (tests/duel-rules/fuzzy.lisp).
;;;;
;;;; A rule base is a list of rules (ANTECEDENTS OUTPUT [:MUST]): ANTECEDENTS a list of (FEATURE SET), all must hold (AND = min of the
;;;; memberships); OUTPUT the chance the rule asks for. The answer is the rules' outputs averaged by their strengths (a zero-order Sugeno
;;;; inference, as the FightingICE fuzzy agent whose memberships were its chances: docs/research/ai-mcts-fuzzy-learning/report.md §2.2),
;;;; DEFAULT when no rule fires; a :MUST rule that holds at least half way answers alone (the rank step: one decisive rule is not averaged away
;;;; by weak ones). The sets' breakpoints are resolved onto their symbols at load; only + - x / (nothing the native sim and wasm may round
;;;; apart). Features are a plist the CPU fills with what it sees (core-ai.lisp); sets are trapezoids
;;;; (A B C D) in *FZ-SETS*. The answer is a chance, rolled once per event as every CPU chance (AI v2), and scaled by difficulty: a :SKILL
;;;; chance (a read, a Hoho, a hold) x *FZ-SKILL*, a :CHOICE (one option or another, both fine) pulled toward 1/2 as the skill falls. The
;;;; outputs are the HARD player's; the learning stages (DUEL_AI_MCTS §2.3-2.4) tune them.
(in-package :duel)

(defparameter *fz-skill* '(:easy 0.3 :normal 0.62 :hard 1.0) "A difficulty's share of the rules' chances (:SKILL), or of their lean (:CHOICE).")

(defparameter *fz-sets*
  '((:yes 0.5 1 1 1.5) (:no -0.5 0 0 0.5)                          ; crisp cues (0 / 1)
    (:near -1 0 1.6 2.4) (:mid 1.6 2.4 3.2 4.2) (:far 3.2 4.2 99 99)  ; distance (m)
    (:inside -99 -99 -0.2 0.3) (:edge -0.2 0.3 0.8 1.2)              ; distance beyond his reach (m)
    (:soon -1 0 8 14) (:late 8 14 99 99)                              ; frames until his hit window opens
    (:early -1 0 0.3 0.6) (:deep 0.3 0.6 1 2)                         ; how far into the string (presses / its length)
    (:behind -99 -99 -1 0) (:even -1 0 0 1) (:ahead 0 1 99 99)        ; my Konpaku minus his
    (:few -1 0 2 4) (:many 2 4 99 99)                                 ; combo hits on me
    ;; strategies' cues (strategy.lisp): a distance over a reach, a fraction, a state class (0-4)
    (:in -99 -99 0.8 1.0) (:reach 0.8 1.0 1.2 1.5) (:out 1.2 1.5 2.0 2.6) (:afar 2.0 2.6 99 99)
    (:low -1 0 0.25 0.5) (:high 0.5 0.75 1 2)
    (:free -0.5 0 0 0.5) (:startup 0.5 1 1 1.5) (:active 1.5 2 2 2.5) (:evade 2.5 3 3 3.5) (:down 3.5 4 4 4.5)
    (:busy 0.5 1 99 99)                                               ; his state class not free (a Q selector's rules, strategy.lisp)
    ;; a Q selector's extra cues (DUEL_AI_STRATEGY §8.19, strategy-glue.lisp STRAT-XFEATS): an index (form, previous arm) as points beside :no (0) / :yes (1)
    (:k2 1.5 2 2 2.5) (:k3 2.5 3 3 3.5) (:p2up 1.5 2 99 99)
    ;; the distance in metres: close inside 2.9 (J1's / every ranged volume's 3.0 m dead zone, the ranged rule's close), gone by 3.4 (its
    ;; closing-in edge); far from 4.5 (where NS1a WA's hit puts him) to 6.0 (the 3-6 m bands of RANSA / OGI)
    (:m-close -99 -99 2.9 3.4) (:m-mid 2.9 3.4 4.5 6.0) (:m-far 4.5 6.0 99 99)
    (:g-low -99 -99 0.2 0.3) (:g-high 0.2 0.3 99 99)                  ; the DRIVE / SUBLIMATION fraction about the switch's 0.25
    (:w-near -99 -99 2.0 3.0) (:w-open 2.0 3.0 99 99))                ; metres to the arena's wall (the ranged rule's cornered: 2.0)
  "The fuzzy sets: name -> trapezoid (A B C D): 0 below A and above D, 1 from B to C.")

(dolist (e *fz-sets*) (setf (get (first e) 'fz-trap) (coerce (rest e) 'simple-vector)))   ; (resolved once: no ASSOC per membership)

(defun fz-mu (x set)
  "X's membership in SET (a name in *FZ-SETS*)."
  (let* ((v (get set 'fz-trap)) (a (svref v 0)) (b (svref v 1)) (c (svref v 2)) (d (svref v 3)))
    (cond ((or (< x a) (> x d)) 0.0)
          ((< x b) (/ (- x a) (float (- b a))))
          ((<= x c) 1.0)
          (t (/ (- d x) (float (- d c)))))))

(defun fz-infer (rules feats &optional (default 0.0))
  "RULES' answer for the feature plist FEATS (a cue missing reads 0): a :MUST rule holding at least half way alone, else the outputs averaged
by the rules' strengths, DEFAULT if none fires."
  (let ((num 0.0) (den 0.0))
    (dolist (r rules (if (plusp den) (/ num den) default))
      (let ((w (loop for (f set) in (first r) minimize (fz-mu (plist-get feats f 0) set))))
        (when (and (eq (third r) :must) (>= w 0.5)) (return (second r)))
        (incf num (* w (second r))) (incf den w)))))

(defun fz-scale (p dif kind)
  "Chance P of the HARD player at difficulty DIF: :SKILL x the skill, :CHOICE pulled toward 1/2."
  (let ((s (getf *fz-skill* dif 0.62)))
    (if (eq kind :skill) (* p s) (+ 0.5 (* (- p 0.5) s)))))

(defun fz-chance (rules feats dif kind &optional (default 0.0))
  "RULES' chance for FEATS at difficulty DIF (KIND :SKILL or :CHOICE)."
  (fz-scale (fz-infer rules feats default) dif kind))

;;; ---------------------------------------------------------------- the rule bases (outputs: the HARD player's chances)
(defparameter *fz-as-now*
  '((((:ons :yes)) 1.0)                       ; he is in an NS: AS beats it (the read)
    (((:ons :no) (:ored :yes)) 0.8)           ; red: end in the AS, a Kikon may follow
    (((:ons :no) (:press :early) (:ored :no)) 0.15)   ; early in the string: go on
    (((:ons :no) (:press :deep) (:ored :no)) 0.5))
  "My NA / SA landed: end the combo in the AS now (else the next link). :CHOICE.")
(defparameter *fz-ns-turn*
  '((((:ona :yes) (:d :near)) 0.85 :must)     ; his NA comes at my NS's gap: the SA beats it
    (((:ona :yes) (:d :mid)) 0.5)
    (((:ownsa :yes) (:d :near) (:ona :no)) 0.5)
    (((:ona :no) (:ownsa :no)) 0.0))
  "In my NS segment's gap: turn into the SA. :SKILL.")
(defparameter *fz-ns-cont*
  '((((:hit :yes)) 0.9) (((:hit :no) (:d :near)) 0.8) (((:hit :no) (:d :mid)) 0.6) (((:hit :no) (:d :far)) 0.35))
  "In my NS (or AS) segment's gap: go on to the next segment. :CHOICE.")
(defparameter *fz-kikon*
  '((((:ored :yes)) 0.9) (((:ored :no) (:lead :behind)) 0.45) (((:ored :no) (:lead :even)) 0.35) (((:ored :no) (:lead :ahead)) 0.25))
  "An SP press: hold it into a Kikon. :SKILL.")
(defparameter *fz-hoho*
  '((((:margin :inside) (:frames :soon)) 0.3) (((:margin :inside) (:frames :late)) 0.15) (((:margin :edge)) 0.1))
  "His attack comes at me while I am free: Hoho out (one roll per attack). :SKILL.")
(defparameter *fz-cancel* '((((:red :no)) 0.95)) "His Kikon follow-up on me: an attack to cancel it (me red: none, the must-hit line). :SKILL.")
(defparameter *fz-burst*
  '((((:hits :many) (:red :no)) 0.5) (((:red :yes)) 0.9) (((:hits :few) (:red :no)) 0.2))
  "Reeling in his combo: Burst out (one roll per combo). :SKILL.")

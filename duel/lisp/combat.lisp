;;;; combat.lisp — what happens when fighters touch (design-v1 §1, §3, §4): HIT-SYSTEM (clash check,
;;;; then COLLECT every fighter's and hazard's hits, then APPLY them all: a trade is a trade, no side
;;;; goes first; then settle the souls they broke), APPLY-HIT (the triangle, damage, reactions, chip,
;;;; gauges, hitstop; the Kikon rush's strike becomes the Kikon here; the parry), DEAL-DAMAGE and the step's hit queues
;;;; (*KIKONS*, *SOUL-BREAKS*, *PENDING*), a delayed hit, the perfect-Hoho test. The gauges, bursts and forms are gauges.lisp's,
;;;; the souls' settling and the reset round.lisp's (split 2026-11-14, REFACTOR_2026-11 R15b). (The retired kits' ward, pierce,
;;;; drink, cut, cold, frost and the Hellfire meter left 2026-11-12.) Decisions are rules.lisp's; effects are EMITted for feedback.lisp.
(in-package :duel)

;;; ---------------------------------------------------------------- the step's hit queues
(defvar *blow-aways* 0 "Blow-aways (the hidden stun past a tolerance) this match: the gate rows' count.")
(defvar *kikons* nil
  "(attacker victim move) of every Kikon rush strike confirmed during this step's HIT-SYSTEM
(KIKON-CONFIRM-P): settled with the Soul Breaks at its end (SETTLE-SOULS).")

(defvar *soul-breaks* nil
  "(attacker . victim) of every Reishi that reached 0 during this step's HIT-SYSTEM: settled together
at its end (SETTLE-SOULS), so a lethal trade breaks both souls and no side goes first.")

;;; ---------------------------------------------------------------- damage
(defun delay-hit (att def dmg n react stun sx sz kb later mv red)
  "A hit whose damage and reaction come LATER frames after it (a move's :params :dmg-at, its move frame: 千切's cuts bursting,
DUEL_KEN_V3 §30; the user, 2026-11-04: 「命中判定給 12f，但實際扣血留到斬痕爆開」): DEF held where he stands (a stagger, no push)
until then, a look-only hazard (:fx) of ATT carrying the rest (DELAY-HIT-HOOK; cleared with every hazard by a reset)."
  (let ((later (max 1 later)))
    (set-reaction def :stagger (+ later *delay-hit-hold*) sx sz 0.0)
    (spawn-hazard :fx att :x sx :z sz :life (1+ later) :delay later :hook 'delay-hit-hook
                          :data (list def dmg n react stun sx sz kb mv red))))
(defun delay-hit-hook (h hz event &rest args)
  "A DELAY-HIT's hazard: on the step its delay runs out, DEF takes the damage and the hit's own reaction; or, the attacker still in MV
with its SP held since the segment began (a core SP's Kikon hold), the Kikon's knockback and his dash-in start now, not at the hit
(the user, 2026-11-05: 「千切的毀魂技彈飛與接續必須要等到傷害爆開後才開始運作」, DUEL_KEN_V3 §30.6): the hold already outlasted any confirm."
  (declare (ignore h args))
  (when (and (eq event :step) (= (hazard-delay hz) 1))   ; (the generic step counts it to 0 after this)
    (destructuring-bind (def dmg n react stun sx sz kb mv red) (hazard-data hz)
      (let* ((att (hazard-owner hz)) (fa (fighter att))
             (kikon (and (eq (fighter-state fa) :move) (eq (fighter-move fa) mv) (core-kikon-p fa mv)
                         (eq (fighter-sp-held fa) t) (core-held-p att))))
        (when (entity-alive-p def)
          (clog "~a delayed hit on ~a ~d~:[~; (Kikon hold)~]" (side-name att) (side-name def) dmg kikon)
          (unless (deal-damage att def dmg n)
            (if kikon
                (progn (set-reaction def :stagger (kikon-follow-stun red (mv-s mv)) sx sz *kikon-follow-kb*)
                       (core-set-kikon-n! att red)
                       (setf (fighter-kikon-undo fa) nil (fighter-phase fa) :follow (fighter-hold fa) 0 (fighter-follow fa) t
                             (fighter-kikon-lock (fighter def)) (if red 2 1))
                       (clog "~a KIKON FOLLOW-UP on ~a~:[~; (red)~]" (side-name att) (side-name def) red))
                (set-reaction def react stun sx sz kb)))))))
  nil)

(defun deal-damage (att def dmg &optional (n 1))
  "DEF loses DMG Reishi (ATT dealt it); N the hit's combo index (both sides' gains
x COMBO-GAIN-MULT: GAIN-GAUGES). Reishi at 0 is an automatic Soul
Break, settled at the end of the step (*SOUL-BREAKS*): returns T then. In a bind (BIND-OF) the loss is grey: Reishi
floors at 0 with no Soul Break, the nominal DMG goes to the binder's :bind-damage (the pool's drain) and to ATT's grey
count (DEALT-REAL)."
  (let* ((ga (gauges att)) (gd (gauges def)) (bd (bind-of def)) (h (bind-hook bd :bind-damage)))
    (setf (gauges-reishi gd) (max 0 (- (gauges-reishi gd) dmg)))
    (incf (gauges-dealt ga) dmg)
    (when bd (incf (gauges-grey ga) dmg))
    (when h (funcall h bd att def dmg))
    (incf (fighter-combo-dmg (fighter def)) dmg)
    (gain-gauges att dmg 0 n)
    (gain-gauges def 0 dmg n)
    (when (and (not bd) (soul-break-p (gauges-reishi gd)))
      (queue-soul-break! att def)
      t)))

(defun queue-soul-break! (att def)
  "DEF's soul breaks (by ATT), settled with the step's others (SETTLE-SOULS: in the order queued, the first's attacker
picks the cinematic); once per victim. (A bind's drained end queues its own: DUEL_HISAGI §17.3 B7.)"
  (unless (rassoc def *soul-breaks*) (push (cons att def) *soul-breaks*)))

(defun queue-kikon! (att def mv)
  "ATT's Kikon on DEF (move MV: its :cine and :callout) confirmed (APPLY-HIT), settled with the step's Soul Breaks
(SETTLE-SOULS: in the order queued, the first picks the cinematic); once per victim."
  (unless (find def *kikons* :key #'second) (push (list att def mv) *kikons*)))

(defun take-broken-souls ()
  "The step's two soul queues emptied for SETTLE-SOULS: BROKEN-SOULS of *KIKONS* and *SOUL-BREAKS* (values kikons
soul-breaks), both queues set to NIL. Nothing else reads or clears them in the step."
  (multiple-value-bind (kk sb) (broken-souls *kikons* *soul-breaks*)
    (setf *kikons* nil *soul-breaks* nil)
    (values kk sb)))

(defun respect (e)
  "The opponent outplayed E (his counter-hit, perfect Hoho, parry or Burst against E): E's :respect-callout
(Nozarashi: \"OMOSHIREE!\", a callout only: no meter)."
  (let ((c (kit-respect-callout (kit-of e)))) (when c (callout e c))))

;;; ---------------------------------------------------------------- one hit
(defun apply-hit (att def hw sx sz &key mv hazard def-state (bonus 0) crush x z red)
  "Apply hit HW of ATT (a fighter) to DEF, coming from (SX SZ) (the attacker or the HAZARD: guard
facing and push direction). MV, BONUS (damage added: the stance's stored) and CRUSH: ATT's move
and its state when the hit was collected (in a trade the first hit applied may already have put ATT
in hitstun). DEF-STATE and RED: DEF's triangle state and red-ness when collected. X Z: where to show
it. Sets the global hitstop (sim timing). A ranged hit (a HAZARD, or a window flagged :ranged beyond its move's
:melee-range) can't be parried. A :ranged-ward move's ranged hit (Hisagi's windmill) and what a :parry-block parry can't
catch (KESSA) are blocked from every side with no blockstun (what he does goes on: super armour). A Kikon rush strike (MV of kind :kikon) is guardable like any
hit; one that hits with ATT still holding the button that started it (KIKON-OUTCOME) knocks DEF back into
a short stagger and ATT's rush dashes in after him to the follow-up strike (phase :follow), whose hit is the
Kikon (no damage, queued in *KIKONS* for SETTLE-SOULS): a guard held during the dash blocks it unless DEF
is RED (KIKON-FOLLOW-UNGUARDABLE-P). A window flagged :flat deals exactly its damage: no form or taken multiplier, no
combo scaling, no counter bonus (Lille II's materialised traces, DUEL_LILLE_V2 decision V9j). Returns RESOLVE-CONTACT's
result (NIL = no effect)."
  (let* ((fa (fighter att)) (fd (fighter def)) (flags (hw-flags hw))
         (p (pos-of def))
         (d2 (+ (expt (- (aref p 0) sx) 2) (expt (- (aref p 2) sz) 2)))   ; DEF's distance (squared) from the attacker
         ;; ranged: not the attacker's own blade (a projectile, a line, a cone); a :ranged window with a :melee-range
         ;; (the Meteor, the cash-out, Buttagiru, Nadegiri) is the blade within it: one window, one hit
         (ranged (ranged-hit-p hazard flags (and mv (getf (mv-params mv) :melee-range)) d2))
         (rward (and ranged (eq (fighter-state fd) :move) (member :ranged-ward (mv-flags (fighter-move fd)))   ; a :ranged-ward
                     (ranged-ward-p t ranged def-state (can-guard-p (gauges-gg (gauges def)) (gauges-guardless (gauges def))))))
         (def-state (if rward :guard def-state))        ;  move (Hisagi's windmill): this hit is guarded from every side
         (ward (or (and (eq def-state :parry) (passive-p def :parry-block))   ; a :parry-block parry blocks what it can't catch
                   rward))
         (own (and mv (eq (fighter-move fa) mv)))
         (wave (and hazard (core-wave-strike att hazard)))   ; a core SP's wave: its follow-up strike (CORE-WAVE-STRIKE)
         (rush (or (and mv (or (eq (mv-kind mv) :kikon) (and own (not hazard) (core-kikon-p fa mv))))       ; the attacker is still in that move
                   (and wave t)))
         (fstrike (and rush own (fighter-follow fa)))   ; the dash-in's strike: the Kikon if it hits
         (res (resolve-contact def-state
                               :breaker (member :breaker flags)
                               :guard-crush (or (member :guard-crush flags) crush
                                                (let ((r (and mv (getf (mv-params mv) :crush-range))))   ; NOMIHOSE: near only
                                                  (and r (< d2 (* r r)))))
                               :in-front (in-front-p (yaw-of def) (aref p 0) (aref p 2) sx sz *guard-arc*)
                               :unguardable (or (member :unguardable flags) (and fstrike (kikon-follow-unguardable-p red)))
                               :hazard ranged :ward ward :rend (member :rend flags)))
         (flat (member :flat flags))                    ; a :flat window deals its damage as written (Lille II's traces)
                                                        ; (:unscaled: no combo scaling, the rest as usual: Lille's awakened KL)
         (atk (if flat
                  '(:mult 1.0)
                  (kit-atk-mods (kit-of att) (- *konpaku-max* (gauges-konpaku (gauges att)))
                                (hit-px (core-charge-mult fa mv own hazard)   ; a charged SA's string (core-sim.lisp)
                                        (sub-of att)                          ; SUBLIMATION / DRIVE
                                        (let ((h (kit-hook (kit-of att) :dmg-mult)))   ; a kit's distance x (Hisagi's tip / close-in)
                                          (if h (funcall h att def hw mv hazard d2) 1.0))
                                        (cond (hazard (hazard-sp-scale hazard))   ; an SP segment short of its cost (DUEL_SP §3); a hazard:
                                              (own (sp-scale (fighter-sp-paid fa) (fighter-sp-cost fa)))   ;  frozen when fired (Q8, S5)
                                              (t 1.0)))
                                (and mv (getf (mv-params mv) :form-mult)))))   ; (a move's own form x: the owl's stance K / KL)
         (dmods (if flat '(:mult 1.0) (sub-taken-mods (kit-def-mods (kit-of def)) (sub-of def))))
         (x (or x (aref p 0))) (z (or z (aref p 2))) (y (+ (aref p 1) 1.1))
         (base (+ (hw-dmg hw) bonus))
         (outcome (and rush (kikon-outcome (if (and mv (eq (mv-kind mv) :kikon)) (vpad-down (pilot-vpad (pilot att)) :kikon) (and (eq (fighter-sp-held fa) t) (core-held-p att)))
                                           res fstrike)))
         (follow (and (eq outcome :follow)               ; knocked back, then the rusher dashes in to the follow-up (a :dmg-at
                      (not (and own (not hazard) mv (getf (mv-params mv) :dmg-at) (not fstrike))))))   ; hit: once its damage lands, DELAY-HIT)
    (when (eq outcome :kikon)
      (setf res :kikon)
      (queue-kikon! att def mv))
    (when res
      (let ((first (and own (eq (contact-of res) :hit) (first-land-p (fighter-contact fa) (fighter-hits fa)))))   ; its first real hit
        (when own                                       ; only a real hit counts as one (CONTACT-OF)
          (setf (fighter-contact fa) (if (eq (contact-of res) :hit) :hit (or (fighter-contact fa) :block)))
          (when (< (fighter-land-sf fa) 0) (setf (fighter-land-sf fa) (fighter-sf fa))))
        (clog "~a ~a -> ~a ~a ~d" (side-name att) (if mv (mv-name mv) (if hazard (hazard-kind hazard) :counter))
              (side-name def) res base)
        (when (and hazard (eq (contact-of res) :hit)) (setf (fighter-hz-hit fa) t))   ; (his move's :r-cancel-from; ponytail:
                                                        ;  any hazard of his counts, scope it to the spawning move if one needs)
        (when (eq res :counter) (respect def))
        (ecase res
          (:kikon nil)                                  ; settled at the end of the step (SETTLE-SOULS)
          ((:hit :counter)
           (multiple-value-bind (react hits launches air)
               (combo-step (if follow :stagger (hw-react hw)) (eq (fighter-state fd) :air) (fighter-combo-hits fd)
                           (fighter-combo-launches fd) (fighter-combo-air fd))
             (setf (fighter-combo-hits fd) hits (fighter-combo-launches fd) launches (fighter-combo-air fd) air)
             ;; the hidden stun (every connected hit, hazards and clones too); past his tolerance this hit blows him away:
             ;; a knockdown sliding ~5 m, the gauge back to 0. A Kikon rush's strike never does (its Kikon / follow-up
             ;; resolves first), nor a Soul Break's hit (DEAL-DAMAGE: no reaction)
             (let* ((gd (gauges def))
                    (st (stun-add (gauges-stun gd) (if follow :stagger (hw-react hw)) (and mv (member (mv-kind mv) '(:sp :kikon)))))
                    (blow (and *stun-blow-away* (not rush) (not (eq (gauges-burst (gauges att)) :orange))   ; (off since 2026-10-10)
                               (stun-over-p st (stun-tolerance-of (kit-of def)))))
                    (react (if blow :knockdown react))
                    (dmg (let ((d (hit-damage base atk dmods
                                              (if (or flat (member :unscaled flags)   ; (an SP's hit or hazard: unscaled)
                                                      (if hazard (hazard-sp hazard) (and mv (sp-move-p (kit-of att) mv)))
                                                      (let ((h (kit-hook (kit-of att) :unscaled))) (and h (funcall h att))))   ; (Hisagi's tip)
                                                  1 (max 1 (- hits (fighter-combo-from fd))))
                                              (and (not flat) (eq res :counter)) (eq (gauges-burst (gauges att)) :orange))))   ; :spare: never the last point
                           (if (member :spare flags) (min d (max 0 (1- (gauges-reishi (gauges def))))) d)))
                    (stun (cond (follow (kikon-follow-stun red (mv-s (or wave mv))))
                                ((and (hw-stun hw) (eq react (hw-react hw))) (hw-stun hw))   ; (a bind in a combo: a flinch)
                                (t (hitstun react (eq res :counter))))))
               (setf (gauges-stun gd) (if blow 0f0 (f32 st)) (gauges-stun-idle gd) 0)
               (clog "~a dealt ~d: ~(~a~) stun ~d" (side-name att) dmg react stun)   ; (the scaled hit's reaction = the full one's: DUEL_SP S2)
               (if ranged (incf (gauges-taken-ranged (gauges def)) dmg) (incf (gauges-taken-melee (gauges def)) dmg))
               (setf (gauges-best-combo (gauges att)) (max hits (gauges-best-combo (gauges att))))
               (when (and own (not hazard) (> dmg 0)) (sp-atk-hit! att fa))   ; a J / SA hit window that dealt damage: +10 / +15 (DUEL_SP §5)
               (hitstop (hw-hs hw))
               (emit :hit att def x y z (hw-hs hw) (eq res :counter) dmg
                     (cond ((member :ice flags) :ice) ((eq react :bind) :bind) ((member :blade flags) :flash)
                           ((member :thread flags) :quick) (hazard :fire)
                           (mv (mv-kind mv)) (t :counter)))
               (if (and own (not hazard) (not follow) (getf (mv-params mv) :dmg-at))   ; a :dmg-at move (千切): the hit holds him,
                   (delay-hit att def dmg (max 1 (- hits (fighter-combo-from fd)))   ;  the damage and its
                              react stun sx sz (hw-kb hw) (- (getf (mv-params mv) :dmg-at) (fighter-sf fa)) mv red)  ;  reaction later
               (unless (deal-damage att def dmg (max 1 (- hits (fighter-combo-from fd))))   ; (a broken
                                                        ;  soul crumples in its cinematic)
                 (if blow
                     (progn (set-reaction def react stun sx sz *stun-blow-kb*)   ; the blow-away
                            (incf *blow-aways*)
                            (clog "~a BLOWN AWAY by ~a (stun tolerance ~,1f, combo hit ~d)" (side-name def) (side-name att)
                                  (stun-tolerance-of (kit-of def)) hits))
                     (progn (if (and follow (or own wave) (or wave (core-kikon-p fa mv)) (plusp *core-kikon-confirm*))
                                (if (member (hw-react hw) '(:knockdown :launch))   ; a knockdown / launch waits for the confirm on his
                                    (set-reaction def :stagger (+ *core-kikon-confirm* *kikon-air-hold*) sx sz 0.0)   ; feet (down by the
                                    (set-reaction def (hw-react hw) (or (hw-stun hw) (hitstun (hw-react hw) (eq res :counter))) sx sz (hw-kb hw)))   ; strike: no Kikon, DUEL_KEN_V3 §39)
                                (set-reaction def react stun sx sz (if follow *kikon-follow-kb* (hw-kb hw))))   ; (a core SP held: an
                                                        ; ordinary hit until the hold is confirmed, CORE-KIKON-KNOCK!)
                            (when (and own (not hazard) (member :ender (mv-flags mv)) (member (mv-kind mv) '(:quick :flash)))
                              (ender-push att def mv))                       ; J3 / K3: out of J1 / K1's reach at once
                            (when (and own (not hazard) (not (fighter-chained fa))   ; a string's opener (J1 / K1) hit:
                                       (string-opener-p (kit-of att) mv att))         ; the attacker dashes in to (not :no-close)
                              (let ((pull (- (sqrt d2) *string-pull-to*)))         ; point-blank, so the string's links
                                (when (> pull 0.01)                                ; reach him (the user 2026-10-02:
                                  (set-slide att pull *string-pull-frames* (- (aref p 0) sx) (- (aref p 2) sz)))))))))   ; no chase)
               (when (and (eq (kit-class (fighter-kit fa) mv) :as) (not hazard)) (core-on-hit! att def mv 1.0 hw))
               (when (and follow wave) (core-wave-follow! att wave))   ; a wave's: he flash-steps in to its strike
               (when (and follow (or own wave))           ; the rush dashes in, then strikes again (KIKON-RUSH-STEP)
                 (setf (fighter-kikon-undo fa)            ; a core SP's: a let-go in the confirm makes this hit an ordinary
                       (and (or wave (core-kikon-p fa mv))   ;  one (CORE-KIKON-UNDO!), its cues wait for the hitstop's end
                            (let ((r (hw-react hw))) (list def r (or (hw-stun hw) (hitstun r (eq res :counter))) sx sz (hw-kb hw) (and wave t)
                                                           react stun))))   ; (the Kikon's reel, for CORE-KIKON-KNOCK!)
                 (when (fighter-kikon-undo fa) (core-set-kikon-n! att red))
                 (setf (fighter-phase fa) :follow (fighter-hold fa) 0 (fighter-follow fa) t
                       (fighter-kikon-lock fd) (if red 2 1))   ; (2026-10-24: guard only, or nothing when red; KIKON-LOCK-P)
                 (unless (fighter-kikon-undo fa) (core-follow-cues att def))   ; (a core SP's: CORE-FOLLOW-STEP)
                 (clog "~a KIKON FOLLOW-UP on ~a~:[~; (red)~]" (side-name att) (side-name def) red)))))
          (:armored                                     ; a move's armour (one hit spent)
           (when (and (eq def-state :armor) (plusp (fighter-armor-left fd))) (decf (fighter-armor-left fd)))   ; (a kit's
                                                        ;  :armor hook pays its own price: its :struck)
           (hitstop *hitstop-block*)
           (emit :armored def x y z)
           (deal-damage att def (hit-damage base atk dmods 1 nil)))
          (:parried                                     ; the attacker staggers, the parry counters (its :land string)
           (hitstop *hitstop-breaker*)
           (respect att)
           (set-reaction att :stagger *parry-stun* (aref p 0) (aref p 2) *parry-slide*)
           (setf (fighter-armor-left fa) 0)
           (let ((h (kit-hook (kit-of def) :parried))) (when (and h (not (siphon-of def))) (funcall h def att)))   ; its own catch
           (emit :parried att def x y z)
           (let ((c (and (fighter-move fd) (kit-next (kit-of def) (mv-name (fighter-move fd)) :land))))
             (when c (core-start! def c nil))))         ; (an NS segment's catch, Kenpachi's tame -> thrust, pays as any segment: DUEL_SP §3)
          (:absorbed
           (let ((dmg (hit-damage base atk dmods 1 nil)))
             (setf (fighter-stored fd) (stance-store (fighter-stored fd) dmg))
             (hitstop *hitstop-block*)
             (emit :absorbed def x y z)
             (deal-damage att def dmg)))
          (:blocked                                     ; blockstun, chip, the guard gauge (at 0: GUARD CRUSH); a
                                                        ; ward (WARD above): no blockstun
           (let* ((adv (- (if (and mv (integerp (mv-adv-block mv))) (mv-adv-block mv) 0)   ; (the attacker's advantage: a blocked
                          (if (and mv (eq (mv-kind mv) :quick)) *quick-block-adv* 0)))   ;  J's defender is free sooner)
                  (stun (if mv (blockstun (mv-total mv) (fighter-sf fa) adv) *hazard-blockstun*))
                  (v (or (hw-guard hw) *gg-hazard*))
                  (chip (chip-damage base (hw-chip hw) (gauges-reishi (gauges def)))))
             (cond ((drain-guard def v)
                    (set-reaction def :guard-break *guard-crush-stun* sx sz *block-pushback*)
                    (hitstop *hitstop-breaker*)
                    (emit :guard-crush att def x y z)
                    (clog "~a GUARD CRUSH" (side-name def)))
                   (ward                                ; super armour: no blockstun, what he does goes on
                    (set-slide def *block-pushback* 6 (- (aref p 0) sx) (- (aref p 2) sz))
                    (when rward (setf (fighter-ward-until fd) (+ *match-tick* *hitstop-block* stun)))   ; the windmill: a guard's wait (+ its hitstop)
                    (hitstop *hitstop-block*)
                    (emit :blocked att def x y z))
                   (t (set-blockstun def stun sx sz)
                      (hitstop *hitstop-block*)
                      (emit :blocked att def x y z)))
             (when (plusp chip) (deal-damage att def chip))))
          (:guard-break
           (drain-guard def *gg-breaker* :breaker)
           (set-reaction def :guard-break *guard-break-stun* sx sz *guard-break-kb*)
           (hitstop *hitstop-breaker*)
           (emit :guard-break att def x y z))
          (:stance-break
           (set-reaction def :crumple *stance-break-stun* sx sz *stance-break-kb*)
           (hitstop *hitstop-breaker*)
           (emit :stance-break att def x y z)))
        (let ((h (kit-hook (kit-of att) :hit))) (when h (funcall h att def res hw mv hazard ranged)))   ; a character's
        (let ((h (kit-hook (kit-of def) :struck))) (when h (funcall h def att res hw mv hazard ranged)))   ; own hit rules
        (when (member res '(:hit :counter)) (core-break! att def))   ; a real hit in an exchange after a cancel: the breakthrough (DUEL_SP §6;
                                                        ;  after the hit's own steal, CORE-ON-HIT! / a clone's :hit hook: Q10)
        (when (and first (mv-on-land mv) (not *cine*)) (funcall (mv-on-land mv) att)))
      res)))

;;; ---------------------------------------------------------------- the system
(defstruct pending
  "One hit collected this step, with what it needs of the attacker as he was then (they are applied
after all are collected). I: the move's window index; HAZARD: the hazard dealing it (NIL = melee);
STATE RED: the defender's triangle state and red-ness; MV BONUS CRUSH: the attacker's move, stored
damage, guard crush."
  att def hw (i 0) (sx 0f0) (sz 0f0) hazard state red mv (bonus 0) crush)
(inline-readers pending)

(defvar *pending* nil "Hits collected this step, applied together.")

(defun collect-melee (e f)
  "E's move windows open this frame that touch the opponent (each window hits once), and a perfect
Hoho's counter strike on its frame (it always connects)."
  (let ((mv (fighter-move f)) (o (fighter-opp f)) (p (pos-of e)))
    (when (entity-alive-p o)
      (when (and (eq (fighter-state f) :hoho) (fighter-perfect f) (= (fighter-sf f) *hoho-counter-strike*))
        (push (make-pending :att e :def o :hw *perfect-hw* :sx (aref p 0) :sz (aref p 2) :state (defender-state o))
              *pending*))
      (when (and (eq (fighter-state f) :move) (eq (fighter-phase f) :main))
        (let* ((sf (fighter-sf f)) (q (pos-of o)) (yaw (yaw-of e)) (go (gauges o))
               (fx (f32 (fwd-x yaw))) (fz (f32 (fwd-z yaw))) (ob (model-body (model o))))
          (loop for w across (mv-hits mv) for i from 0
                when (and (<= (hw-from w) sf) (< sf (hw-to w)) (not (logbitp i (fighter-hits f)))
                          (let ((mn (hw-min w)))         ; a :min-reach dead zone (not a Kikon's follow-up strike; his kit's
                            (when mn                     ;  :min-reach hook may lift it: Hisagi's cancel unlock, DUEL_HISAGI §29)
                              (let ((h (kit-hook (fighter-kit f) :min-reach))) (when h (setf mn (funcall h e mn)))))
                            (or (null mn) (fighter-follow f) (>= (hypot (- (aref q 0) (aref p 0)) (- (aref q 2) (aref p 2))) mn)))
                          (window-touches-p w e (aref p 0) (aref p 1) (aref p 2) fx fz (aref q 0) (aref q 1) (aref q 2)
                                            (body-hurt-r ob) (body-hurt-h ob)))   ; (its volumes, or its :seg-fn capsule)
                  do (push (make-pending :att e :def o :hw w :i i :sx (aref p 0) :sz (aref p 2)
                                         :state (defender-state o) :mv mv
                                         :red (gauges-red-p go)
                                         :bonus (fighter-dmg-bonus f) :crush (fighter-crush f))
                           *pending*)))))))

(defun cut-hazards (e f)
  "Nozarashi (:projectile-cut): an open window of E's move judges each opponent hazard it touches by the triangle (DUEL_SP §6, S5, Q9),
as the hazard's own hit on him would be (CORE-VERDICT of its class against his window's): his class beats it (:absorb) or either side
has no class: it is cut, nothing more; a cancel: CORE-HAZARD-NOHIT! (the owner refunded, an exchange) and it is gone; the wave's class
wins (:hit): it flies on."
  (let ((mv (fighter-move f)))
    (when (and (passive-p e :projectile-cut) (eq (fighter-state f) :move) (eq (fighter-phase f) :main))
      (let* ((sf (fighter-sf f)) (p (pos-of e)) (yaw (yaw-of e)) (fx (f32 (fwd-x yaw))) (fz (f32 (fwd-z yaw))))
        (loop for w across (mv-hits mv)
              when (and (<= (hw-from w) sf) (< sf (hw-to w)))
                do (do-entities (h (hz hazard))
                     (when (and (not (eql (hazard-owner hz) e)) (member (hazard-kind hz) '(:wave :fireball :bind))
                                (<= (hazard-delay hz) 0)
                                (loop for v in (hw-vols w)
                                      thereis (vol-hit-p v (aref p 0) (aref p 1) (aref p 2) fx fz
                                                         (hazard-x hz) 0f0 (hazard-z hz) (f32 (max 0.5 (hazard-size hz)))
                                                         1.8f0 0f0)))
                       (let* ((wc (hazard-cls hz)) (bc (core-window-class f))
                              (v (if (and wc bc) (core-verdict wc bc :att-t (hazard-sp-src hz) :def-t (fighter-cls-t f)) :absorb)))
                         (clog "~a blade x ~a's ~(~a ~a~): ~(~a~)" (side-name e) (side-name (hazard-owner hz)) (hazard-kind hz) wc
                               (case v (:hit "passes") (t v)))
                         (unless (eq v :hit)                     ; (the wave wins: not cut)
                           (core-hazard-nohit! hz e v)
                           (destroy-entity h))))))))))

(defun clash! (a b)
  "Breaker vs Breaker: both pushed *CLASH-PUSH* apart and stunned *CLASH-STUN*, no damage."
  (let* ((p (pos-of a)) (q (pos-of b)))
    (set-reaction a :clash *clash-stun* (aref q 0) (aref q 2) (* 0.5 *clash-push*))
    (set-reaction b :clash *clash-stun* (aref p 0) (aref p 2) (* 0.5 *clash-push*))
    (hitstop *hitstop-breaker*)
    (emit :clash (* 0.5 (+ (aref p 0) (aref q 0))) 1.2 (* 0.5 (+ (aref p 2) (aref q 2))))
    (clog "CLASH")))

(defun hit-system ()
  "Clash first; then collect every melee and hazard hit of this step; then apply them all; then
settle the souls they broke (the bind's drained check first: BIND-STEP! :hits), handed to round.lisp as values
(TAKE-BROKEN-SOULS: a delayed hit's Soul Break, queued during HAZARD-SYSTEM, waits in *SOUL-BREAKS* until here)."
  (let ((a nil) (b nil))
    (do-entities (e (f fighter)) (if a (setf b e) (setf a e)))
    (when (and a b)
      (let ((pa (breaker-phase a)) (pb (breaker-phase b)))
        (when (and pa pb (breaker-clash-p pa pb (fighter-dist (fighter a))))
          (clash! a b))))
    (hit-apply)
    (bind-step! a :hits))
  (multiple-value-bind (kk sb) (take-broken-souls) (settle-souls kk sb)))

(defun hit-apply ()
  "Every hit of this step (HIT-SYSTEM): Nozarashi's cuts, then the melee and hazard hits collected, then applied together."
  (do-entities (e (f fighter)) (cut-hazards e f))
  (do-entities (e (f fighter)) (collect-melee e f))
  (collect-hazard-hits)
  (let* ((hits (nreverse *pending*))
         (verdicts (core-verdicts hits)))
    (setf *pending* nil)
    (dolist (h hits)
      (let* ((hz (pending-hazard h)) (fa (fighter (pending-att h))) (mv (pending-mv h))
             (verdict (pop verdicts))                    ; the core triangle's (core-sim.lisp): a cancel / absorb deals nothing
             (res (if (eq verdict :hit)
                      (apply-hit (pending-att h) (pending-def h) (pending-hw h) (pending-sx h) (pending-sz h)
                                 :mv mv :hazard hz :def-state (pending-state h) :red (pending-red h)
                                 :bonus (pending-bonus h) :crush (pending-crush h))
                      (progn (core-nohit! h verdict) verdict))))
        (when res
          (cond (hz (hazard-connected hz))
                ((and mv (eq mv (fighter-move fa)))   ; (an on-land hook may have started the next move)
                 (setf (fighter-hits fa) (logior (fighter-hits fa) (ash 1 (pending-i h)))))))))))

;;; ---------------------------------------------------------------- perfect Hoho
(defun perfect-now-p (e)
  "Would a Hoho started now by E be PERFECT? An opponent hit volume (move or hazard) active now or
within *PERFECT-LEAD* frames overlaps E's hurt cylinder grown by *PERFECT-INFLATE* (rules.lisp), or
his Breaker / Kikon rush dash is within 0.5 m of its trigger range."
  (let* ((o (opp-of e)) (fo (fighter o)) (mv (fighter-move fo)) (p (pos-of e)) (q (pos-of o))
         (b (model-body (model e))) (yaw (yaw-of o)))
    (or (and (eq (fighter-state fo) :move) (eq (fighter-phase fo) :main)
             (loop for w across (mv-hits mv)
                   thereis (if (hw-seg w)                       ; a :seg-fn window: its capsule now, the cylinder grown
                               (and (threat-window-p (fighter-sf fo) (hw-from w) (hw-to w))
                                    (window-touches-p w o 0f0 0f0 0f0 0f0 0f0 (aref p 0) (aref p 1) (aref p 2)
                                                      (+ (body-hurt-r b) *perfect-inflate*) (+ (body-hurt-h b) *perfect-inflate*)))
                               (perfect-hoho-p (fighter-sf fo) (hw-from w) (hw-to w) (hw-vols w)
                                               (aref q 0) (aref q 1) (aref q 2) (f32 (fwd-x yaw)) (f32 (fwd-z yaw))
                                               (aref p 0) (aref p 1) (aref p 2) (body-hurt-r b) (body-hurt-h b)))))
        (and (eq (fighter-state fo) :move) (eq (fighter-phase fo) :dash)      ; a Breaker / Kikon rush about to strike
             (<= (fighter-dist fo) (+ (if (eq (mv-kind mv) :kikon) *kikon-trigger* *breaker-trigger*) 0.5)))
        (hazard-threat-p o e))))


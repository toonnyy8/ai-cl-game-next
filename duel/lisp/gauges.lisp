;;;; gauges.lisp — the fighters' gauges and what writes them outside a hit's own rules (split from combat.lisp, 2026-11-14,
;;;; REFACTOR_2026-11 R15b): the gains (PAY-GAUGES, GAIN-GAUGES, SP-ATK-HIT!, the siphon), heals and the awakening gauge's fill,
;;;; the guard gauge's drain, the bind's readers (a bind changes how Reishi and Konpaku are written: DEAL-DAMAGE, HEAL!,
;;;; SETTLE-KONPAKU), Burst Reverse, forms / awakening / Kenpachi's Bankai, and GAUGE-SYSTEM (regen, GUARD HOLD, burns, form
;;;; timers, EVOLUTION). Decisions are rules.lisp's; effects are EMITted for feedback.lisp. Loaded before combat.lisp (the hits)
;;;; and round.lisp (Kikon, Soul Break, the reset).
(in-package :duel)

;;; ---------------------------------------------------------------- gains, heals, the bind
(defun siphon-of (e)
  "The fighter taking E's gains now, or NIL: the opponent's kit's :siphon hook (o e) is true while something of his drains
E (a zone he stands in). Asked at every gain, so it ends the frame the zone ends or E leaves it. Siphoned, E gains nothing
from a hit, a block, a parry or his own blade (GAIN-GAUGES, SP-ATK-HIT!, the parry's
refill, SETTLE-KONPAKU's Fighting Spirit); his flash-step gains go to that fighter, the rest is lost."
  (let* ((o (opp-of e)) (h (and (entity-alive-p o) (kit-hook (kit-of o) :siphon))))
    (and h (funcall h o e) o)))

;;; The bind (docs/duel/DUEL_HISAGI.md §17.3-§17.4, shared hook 5): one fighter's kit binds both (Hisagi's bind mode).
;;; Every reader below asks BIND-OF; with no kit holding a :bind hook each returns what the code did before. The bind's
;;; own state, pool, snapshot and ends live in the binder's file, behind his kit hooks (binder first in every call):
;;;   :bind (x)              true while X binds (BIND-OF)
;;;   :bind-damage (b a d n) A dealt D N (nominal) inside the bind (DEAL-DAMAGE): the pool's drain
;;;   :bind-heal (b e n)     E was healed N for real (HEAL!): his snapshot follows
;;;   :bind-step (b phase)   :release after both fighters stepped (FIGHTER-SYSTEM, where a Burst is applied), :hits after
;;;                          the step's hits before SETTLE-SOULS (HIT-SYSTEM: the drained check; it may queue Soul Breaks)
;;;   :bind-resolve (b)      time-up: the bind resolved as drained before the winner is read (flow.lisp TIME-UP)
;;;   :bind-snapshot (b e)   E's Reishi and Konpaku at the bind's start (the HUD's grey band and grey souls)
(defun bind-of (e)
  "The binder while E is in a bind (E himself or his opponent: the kit hook :bind (x) of X's form is true while X binds),
else NIL."
  (flet ((binds (x) (let ((h (and (entity-alive-p x) (kit-hook (kit-of x) :bind)))) (and h (funcall h x) x))))
    (or (binds e) (binds (opp-of e)))))

(defun bind-hook (b point) "Binder B's kit hook POINT, or NIL (no binder, or no such hook)." (and b (kit-hook (kit-of b) point)))

(defun bind-step! (e phase)
  "One of the bind's two fixed points of the step (PHASE :release / :hits: the binder's :bind-step); nothing unbound."
  (let* ((b (and e (bind-of e))) (h (bind-hook b :bind-step))) (when h (funcall h b phase))))

(defun bind-resolve! (e)
  "Time-up while E is in a bind: the binder's :bind-resolve (the bind ends as drained first, DUEL_HISAGI §17.3 B10)."
  (let* ((b (and e (entity-alive-p e) (bind-of e))) (h (bind-hook b :bind-resolve))) (when h (funcall h b))))

(defun bind-snapshot-of (e)
  "E's Reishi and Konpaku when the bind he is in started (the binder's :bind-snapshot), else NIL NIL."
  (let* ((b (bind-of e)) (h (bind-hook b :bind-snapshot))) (if h (funcall h b e) (values nil nil))))

(defun bind-grey-frac (e)
  "The grey band's end on E's Reishi bar (hud.lisp: his Reishi at a bind's start, a fraction of max), else 0. A soul he lost
inside the bind (a Kikon refilled the bar: his Konpaku below the snapshot's) makes the whole bar grey up to its max (the
user, 2026-10-19: 「如果在捆綁的狀態下受到毀魂技攻擊，那下一條血量的灰血就會失效」, DUEL_HISAGI §25.7)."
  (multiple-value-bind (r0 k0) (bind-snapshot-of e)
    (cond ((null r0) 0f0)
          ((< (gauges-konpaku (gauges e)) k0) 1f0)
          (t (f32 (/ r0 (float (gauges-reishi-max (gauges e)))))))))

(defun bind-grey-souls (e)
  "E's grey souls drawn up to (hud.lisp: his Konpaku at a bind's start), else 0 (none)."
  (multiple-value-bind (r0 k0) (bind-snapshot-of e) (declare (ignore r0)) (or k0 0)))

(defun heal! (e n)
  "E's Reishi + N, at most his max (an awakening's heal, WHITE's and the awakening's regen). In a bind the heal is real:
his snapshot follows (the binder's :bind-heal), so a release keeps it (B6)."
  (let ((g (gauges e)))
    (setf (gauges-reishi g) (min (gauges-reishi-max g) (+ (gauges-reishi g) n)))
    (let* ((b (bind-of e)) (h (bind-hook b :bind-heal))) (when h (funcall h b e n)))))

(defun dealt-real (e)
  "The damage E dealt this match that counts (the learner's): GAUGES-DEALT without the grey part a bind holds
(GAUGES-GREY: dealt inside a bind; the binder's end clears it when the grey turns real, a release leaves it out)."
  (let ((g (gauges e))) (- (gauges-dealt g) (gauges-grey g))))

(defun awaken-fill! (g x &optional (xs 0.0))
  "X more awakening for G's owner (XS of it from attacking): the awakening gauge by X, then SUBLIMATION, or SPIRIT DRIVE once awakened,
by XS only (AWAKEN-OVERFLOW). Latches GAUGES-AW-FULL once the awakening gauge is full (an awakened fighter counts)."
  (multiple-value-bind (aw sub drive) (awaken-overflow (gauges-awakened g) (gauges-awaken g) (gauges-sub g) (gauges-drive g) x xs)
    (setf (gauges-awaken g) (f32 aw) (gauges-sub g) (f32 sub) (gauges-drive g) (f32 drive))
    (when (or (gauges-awakened g) (>= aw *awaken-max*)) (setf (gauges-aw-full g) t))))

(defun aw-full-p (g)
  "Has G's awakening gauge been full this match (DUEL_SP §3 「量表滿過就能開」)? The latch, or an awakened fighter, or a gauge set full
directly (PRACTICE's rows, the debug scenes write the gauge without AWAKEN-FILL!)."
  (or (gauges-aw-full g) (gauges-awakened g) (>= (gauges-awaken g) *awaken-max*)))

(defun sub-of (e)
  "E's SUBLIMATION / SPIRIT DRIVE bonus fraction 0..1 (SUB-FRAC)."
  (let ((g (gauges e))) (sub-frac (gauges-awakened g) (gauges-sub g) (gauges-sub-s g) (gauges-drive g))))

(defun sub-speed-mult (e)
  "Walk / run speed x (1 + *SUB-SPEED* x SUB-OF)."
  (+ 1.0 (* *sub-speed* (sub-of e))))

(defun pay-gauges (e fs)
  "E gains FS flash-step (kept at its max; nothing during a burst: BURST-FS-GAIN; x (1 + *SUB-FS* x SUB-OF)). (Its Reiatsu
half left with the gauge, 2026-11-13, REFACTOR_2026-11 R6.)"
  (let ((g (gauges e)))
    (setf (gauges-fs g) (f32 (gauge-add (gauges-fs g) (fs-gain fs (gauges-burst g) (sub-of e)) *fs-max*)))))

(defun sp-atk-hit! (att fa)
  "ATT's J / SA hit window just dealt damage (APPLY-HIT): the flash-step it earns, SP-ATK-GAIN of his move's class x his kit's :sp-gain-mult
hook (Hisagi's Bankai tip / spread route, DUEL_SP §8.6 A1 playtest), through PAY-GAUGES (nothing in a burst, x SUBLIMATION; Q2, Q18). Once per
damaging hit window (the user's Q3 change: a multi-hit SA pays per hit); NS / AS / Kikon segments earn nothing. Logs `SP hit gain` with what
was actually added."
  (let ((g (sp-atk-gain (fighter-cls fa) nil)))
    (when (> g 0.0)
      (let* ((h (kit-hook (kit-of att) :sp-gain-mult)) (fs0 (gauges-fs (gauges att))))
        (pay-gauges att (if h (* g (funcall h att)) g))
        (clog "~a SP hit gain ~,1f (fs ~,1f)" (side-name att) (- (gauges-fs (gauges att)) fs0) (gauges-fs (gauges att)))))))

(defun gain-gauges (e dealt taken &optional (n 1))
  "Flash-step and Fighting Spirit for dealing DEALT / taking TAKEN damage at the combo's Nth hit (HIT-GAINS; siphoned:
SIPHON-OF)."
  (let ((g (gauges e)) (to (siphon-of e)))
    (multiple-value-bind (fs aw sfs) (hit-gains dealt taken to (burst-gain-mult (gauges-burst g)) n)
      (pay-gauges e fs)
      (when to (pay-gauges to sfs))
      (awaken-fill! g aw (if to 0.0 (sub-attack-gain dealt 0 (burst-gain-mult (gauges-burst g))))))))

;;; ---------------------------------------------------------------- the guard gauge
(defun drain-guard (e v &optional (why :block))
  "E's guard gauge loses V (its regen waits *GG-DELAY* again). At 0 he is guardless until it is full (CAN-GUARD-P).
T when this drain emptied it."
  (let ((g (gauges e)))
    (multiple-value-bind (n crushed) (gg-drain (gauges-gg g) v)
      (setf (gauges-gg g) (f32 n) (gauges-gg-idle g) 0)
      (when (and crushed (not (gauges-guardless g)))
        (setf (gauges-guardless g) t)
        (clog "~a GUARDLESS ~a" (side-name e) why))
      crushed)))

;;; ---------------------------------------------------------------- Burst Reverse
(defun burst-mode-of (e)
  "The burst mode E's state gives a press now (rules BURST-MODE), or NIL. ORANGE: his move's own hit landed and its
cancel window is open; or his L / O (a :sig or :kikon move, hazards included) has the opponent in hitstun or blockstun
right now (a blocked L / O counts too); or, free or in any move, while the opponent reels (hitstun / airborne) from one of
his hazards (KESSA's clones hitting while his own swing missed, a zone: the user 2026-09-30); free, that replaces WHITE."
  (let* ((f (fighter e)) (mv (fighter-move f)) (st (fighter-state f)) (o (fighter-opp f))
         (os (and o (entity-alive-p o) (fighter-state (fighter o)))))
    (if (and (member st '(:idle :guard :run)) (member os '(:stun :air)) (zerop (fighter-lock f)))
        :orange
        (burst-mode st (plusp (fighter-lock f)) (fighter-combo-hits f)
                    (and (eq st :move) mv (eq (fighter-phase f) :main)
                         (if (member (mv-kind mv) '(:sig :kikon))
                             (member os '(:stun :guard-hit :air))
                             (or (member os '(:stun :air))   ; he reels from my hazard / clone though this move missed
                                 (cancel-open-p (fighter-sf f) (fighter-land-sf f) (mv-total mv) (eq (fighter-contact f) :hit)))))))))

(defun burst-ok-p (e)
  "May E burst now (rules BURST-ALLOWED-P): the mode (:white :blue :orange) or NIL."
  (let ((m (burst-mode-of e)) (g (gauges e)))
    (and (burst-allowed-p m (gauges-fs g) (gauges-burst g)) m)))

(defun repel! (e)
  "E breaks free (a Burst Reverse, an awakening): neutral at once (on the ground), invulnerable *BURST-INVULN* f, his
combo over; the opponent's move / Hoho / step / run ends and he slides *BURST-PUSH* away, not stunned."
  (let* ((f (fighter e)) (mo (motion e)) (o (fighter-opp f)) (p (pos-of e)) (q (pos-of o)))
    (setf (aref p 1) 0f0 (motion-grounded mo) t (motion-kb-left mo) 0)
    (to-idle e 0)
    (setf (fighter-invuln f) *burst-invuln*)
    (when (member (state-of o) '(:move :hoho :step :run))
      (to-idle o 0)
      (setf (model-alpha (model o)) 1f0))
    (set-slide o *burst-push* *burst-push-frames* (- (aref q 0) (aref p 0)) (- (aref q 2) (aref p 2)))
    (respect o)))

(defun burst! (e mode)
  "A burst of MODE starts (FIGHTER-SYSTEM applies it once both fighters have stepped; docs/duel/DUEL_DESIGN.md \"Burst
modes\"): nothing spent, the flash-step drains from now (GAUGE-SYSTEM). BLUE breaks free (REPEL!); ORANGE cancels his
move's recovery, the next move started within *CHAIN-WINDOW* f has its startup cut (START-MOVE). A short global hitstop."
  (let ((o (opp-of e)) (g (gauges e)) (f (fighter e)))
    (setf (gauges-burst g) mode (gauges-burst-t g) 0 (gauges-fs-idle g) 0 (gauges-burn g) (f32 (burst-budget mode)))
    (case mode
      (:blue (repel! e))
      (:orange (to-idle e 0) (setf (fighter-chain f) *chain-window*)
       (setf (fighter-combo-from (fighter o)) (fighter-combo-hits (fighter o)))))   ; (his combo's scaling starts over)
    (hitstop *burst-hitstop*)
    (emit :burst e o mode)
    (clog "~a BURST ~a fs ~,1f" (side-name e) mode (gauges-fs g))))

(defun burst-end! (e)
  "E's burst ends (its flash-step ran out, or a Kikon / Soul Break reset): the regen delay restarts."
  (let ((g (gauges e)))
    (when (gauges-burst g)
      (clog "~a BURST END ~a fs ~,1f" (side-name e) (gauges-burst g) (gauges-fs g))
      (setf (gauges-burst g) nil (gauges-burst-t g) 0 (gauges-burn g) 0f0 (gauges-fs-idle g) 0 (fighter-chain (fighter e)) 0)
      (emit :burst-end e))))

(defun white-regen! (e g n)
  "WHITE's regen on E's frame N (1-based): Reishi (HEAL!) and (not yet awakened) the awakening gauge G."
  (heal! e (burst-heal n *white-reishi*))
  (awaken-fill! g (/ *white-awaken* 60.0) (/ *white-awaken* 60.0)))   ; a Burst counts as attacking (DUEL_SUBLIMATION §18)

(defun burst-step (e g)
  "A running burst, one frame: the flash-step drains (BURST-BURN), WHITE's regen (WHITE-REGEN!); when the gauge or the burst's budget
(BLUE: one cell) is spent it ends."
  (let ((n (incf (gauges-burst-t g))))
    (multiple-value-bind (fs burn) (burst-burn (gauges-fs g) (gauges-burn g))
      (setf (gauges-fs g) (f32 fs) (gauges-burn g) (f32 burn)))
    (when (eq (gauges-burst g) :white) (white-regen! e g n))
    (when (or (<= (gauges-fs g) 0.0) (<= (gauges-burn g) 0.0)) (burst-end! e))))

(defun awake-regen-frames ()
  "How long the awakening's regen runs: as long as a burst from a full flash-step gauge (*FS-MAX* / *BURST-DRAIN*)."
  (round (* 60 (/ *fs-max* *burst-drain*))))

(defun start-awake-regen! (g)
  "An awakening (or Kenpachi's Bankai) starts WHITE's regen for AWAKE-REGEN-FRAMES, on its own clock: it overlaps a burst
and spends no flash-step (the user 2026-09-30)."
  (setf (gauges-awake-regen g) (awake-regen-frames) (gauges-awake-t g) 0))

;;; ---------------------------------------------------------------- forms, awakening
(defun set-form (e form)
  "E's character changes to FORM: the old form's exit hook, the new kit, its timer, look and entry hook."
  (let* ((f (fighter e)) (g (gauges e)) (old (fighter-kit f)) (new (find-kit (fighter-character f) form)))
    (when (and (kit-exit-hook old) (not (eq old new))) (funcall (kit-exit-hook old) e))
    (setf (fighter-kit f) new (fighter-form f) form (gauges-burn-step g) 0
          (gauges-form-left g) (if (kit-duration new) (seconds->frames (kit-duration new)) 0))
    (let ((n (length (getf (kit-core new) :ns))))       ; the core system: the pointer within the form's NS (Hisagi's Bankai has two)
      (when (plusp n) (setf (fighter-ptr f) (min (fighter-ptr f) n))))
    (refresh-look e)
    (when (kit-enter-hook new) (funcall (kit-enter-hook new) e))
    (emit :form e form)
    (clog "~a form ~a" (side-name e) form)))

(defun awaken! (e)
  "Awakening (once per match): E breaks free as a Burst does (REPEL!), the kit's awakened form, *AWAKEN-HEAL* of max Reishi, then the
form's :cine if it has one (both fighters idle after it). The guard gauge is left as it is."
  (let* ((g (gauges e)) (o (opp-of e)))
    (repel! e)                                          ; the moment breaks his attack, as a Burst (the user 2026-09-29)
    (start-awake-regen! g)                              ; then WHITE's regen for a full burst's time (the user 2026-09-30)
    (setf (gauges-sub-s g) (f32 (/ (gauges-sub g) *sub-max*)))   ; SUBLIMATION freezes (kept x *SUB-KEEP*), SPIRIT DRIVE takes over
    (setf (gauges-awakened g) t (gauges-awaken g) 0f0 (gauges-evolution g) nil)
    (set-form e (kit-awaken-form (kit-of e)))
    (let ((st (getf (kit-meter (kit-of e)) :start)))    ; NOME starts at 10
      (when st (setf (gauges-meter g) (f32 st) (gauges-meter-idle g) 0)))
    (heal! e (round (* *awaken-heal* (gauges-reishi-max g))))
    (emit :awaken e)
    (if (kit-cine (kit-of e))
        (start-cine (kit-cine (kit-of e)) e o :after (lambda () (to-idle e 0) (to-idle o 0)))
        (to-idle e 0))))

;;; ---------------------------------------------------------------- Kenpachi's Bankai (DUEL_KEN_V3 §26)
(defun bankai! (e form &optional (restore t) (cine t))
  "The Bankai: E into FORM, his Reishi refilled and, since 2026-10-31, his Konpaku KEPT (the user: 「改成不扣」; before: set to 1, the decisions of
2026-09-28: all his remaining souls for one full bar); the guard gauge and flash-step as
they are; then the form's :cine (both fighters idle after it). FORM: the target. RESTORE NIL (Kenpachi V3's Bankai off the Shikai's
J7, a special form, not an awakening: the user, 2026-11-04, 「進入卍解不回復狀態，劍八的卍解算特殊形態，不計入覺醒」, DUEL_KEN_V3 §26.3): no
awakening regen and no Reishi refill. CINE NIL: no cinematic, straight to idle in the form (Kenpachi V3's Bankai burst AS: the user,
2026-11-05, 「卍解的瞬間不再接入特寫」, DUEL_KEN_V3 §32)."
  (let* ((g (gauges e)) (o (opp-of e)) (keep t)   ; his Konpaku kept (the user 2026-10-31: 「改成不扣」, DUEL_SUBLIMATION §3)
         (lost (if keep 0 (- (gauges-konpaku g) 1))))
    (repel! e)                                          ; the second awakening breaks his attack too
    (when restore (start-awake-regen! g))
    (set-form e form)
    (setf (gauges-konpaku g) (if keep (gauges-konpaku g) 1))
    (when restore (setf (gauges-reishi g) (gauges-reishi-max g)))
    (refresh-look e)
    (when (plusp lost) (emit :konpaku e lost))
    (emit :bankai e)
    (clog "~a BANKAI (konpaku kept, -~d)" (side-name e) lost)
    (if (and cine (kit-cine (kit-of e)))
        (start-cine (kit-cine (kit-of e)) e o :after (lambda () (to-idle e 0) (to-idle o 0)))
        (to-idle e 0))))

;;; ---------------------------------------------------------------- gauges per step
(defun gauge-system ()
  "Regen (flash-step and the guard gauge after their delays: a full guard gauge ends
guardless), timed forms (burn, drain, end), EVOLUTION. GUARD HOLD: one guarding test (:guard / :guard-hit, not guardless)
gates both the guard gauge's refill and its delay counter (frozen)."
  (do-entities (e (f fighter) (g gauges))
    (let* ((kit (fighter-kit f))
           (guarding (and (member (fighter-state f) '(:guard :guard-hit)) (not (gauges-guardless g)))))
      (if (gauges-burst g)
          (burst-step e g)                               ; a burst: the gauge drains, no regen
          (setf (gauges-fs g) (f32 (fs-regen (gauges-fs g) (gauges-fs-idle g)))
                (gauges-fs-idle g) (min 9999 (1+ (gauges-fs-idle g)))))
      (when (plusp (gauges-awake-regen g))                ; the awakening's regen (overlaps a burst)
        (decf (gauges-awake-regen g))
        (white-regen! e g (incf (gauges-awake-t g))))
      (setf (gauges-gg g) (f32 (gg-regen (gauges-gg g) (gauges-gg-idle g) (gauges-guardless g) guarding
                                         (eq (gauges-burst g) :blue) (kit-gg-regen kit))))
      (setf (gauges-gg-idle g) (gg-idle-next (gauges-gg-idle g) guarding))
      (setf (gauges-stun g) (f32 (stun-decay (gauges-stun g) (gauges-stun-idle g)))   ; the hidden stun's decay
            (gauges-stun-idle g) (min 9999 (1+ (gauges-stun-idle g))))
      (when (and (gauges-guardless g) (>= (gauges-gg g) *gg-max*))
        (setf (gauges-guardless g) nil)
        (emit :guard-back e)
        (clog "~a GUARD BACK" (side-name e)))
      (when (> (fighter-combo-dmg f) 0)                  ; the combo's damage shows until he is up again
        (unless (member (fighter-state f) '(:stun :air :down :wakeup :guard-hit)) (setf (fighter-combo-dmg f) 0)))
      (when (plusp (gauges-form-left g))
        (let ((burn (kit-burn kit)))
          (when (plusp burn)
            (setf (gauges-reishi g) (burn (gauges-reishi g) (burn-amount (gauges-reishi-max g) burn (gauges-burn-step g)))))
          (incf (gauges-burn-step g))
          (when (zerop (decf (gauges-form-left g)))
            (set-form e (kit-inherit kit)))))
      (let ((h (kit-hook kit :tick))) (when h (funcall h e f g)))   ; the form's own per-step mechanics (a meter, a cut)
      (when (and (not (gauges-awakened g)) (not (gauges-evolution g)) (>= (gauges-awaken g) *awaken-max*))
        (setf (gauges-evolution g) t)
        (when (minusp (gauges-evo-t g)) (setf (gauges-evo-t g) *match-tick*))
        (emit :evolution e)
        (clog "~a EVOLUTION" (side-name e))))))

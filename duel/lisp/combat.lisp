;;;; combat.lisp — what happens when fighters touch (design-v1 §1, §3, §4): HIT-SYSTEM (clash check,
;;;; then COLLECT every fighter's and hazard's hits, then APPLY them all: a trade is a trade, no side
;;;; goes first; then settle the souls they broke), APPLY-HIT (the triangle, damage, reactions, chip,
;;;; gauges, hitstop, KOSEI; the Kikon rush's strike becomes the Kikon here; the Bankai stances: East's pierce, West's ward
;;;; (360 deg, no blockstun, a crush / Guard Break drops him to East), the parry and its refill), Kikon / Soul Break / awakening
;;;; / form changes (all settled here, at connect time; cinema.lisp only presents them), the perfect-Hoho test and GAUGE-SYSTEM (regen, GUARD HOLD, burns,
;;;; form timers, Hellfire, EVOLUTION). Decisions are rules.lisp's; effects are EMITted for feedback.lisp.
(in-package :duel)

;;; ---------------------------------------------------------------- damage and gauges
(defvar *blow-aways* 0 "Blow-aways (the hidden stun past a tolerance) this match: the gate rows' count.")
(defvar *kikons* nil
  "(attacker victim move) of every Kikon rush strike confirmed during this step's HIT-SYSTEM
(KIKON-CONFIRM-P): settled with the Soul Breaks at its end (SETTLE-SOULS).")

(defvar *soul-breaks* nil
  "(attacker . victim) of every Reishi that reached 0 during this step's HIT-SYSTEM: settled together
at its end (SETTLE-SOULS), so a lethal trade breaks both souls and no side goes first.")

(defun gg-cap (e) "E's guard-gauge max: *GG-MAX*, x a DANGAI reward's :gg-max (DUEL_ROGUE §4.4) on the run's fighter." (rmod-x e :gg-max *gg-max*))

(defun siphon-of (e)
  "The fighter taking E's gains now, or NIL: the opponent's kit's :siphon hook (o e) is true while something of his drains
E (a zone he stands in). Asked at every gain, so it ends the frame the zone ends or E leaves it. Siphoned, E gains nothing
from a hit, a block, a parry or his own blade (GAIN-GAUGES, KOSEI!, NOME-GAIN!, ADD-METER, COLD-ADD!, the parry's
refill, SETTLE-KONPAKU's Fighting Spirit); his Reiatsu and flash-step gains go to that fighter, the rest is lost."
  (let* ((o (opp-of e)) (h (and (entity-alive-p o) (kit-hook (kit-of o) :siphon))))
    (and h (funcall h o e) o)))

;;; The bind (docs/duel/DUEL_HISAGI.md §17.3-§17.4, shared hook 5): one fighter's kit binds both (Hisagi's bind mode).
;;; Every reader below asks BIND-OF; with no kit holding a :bind hook each returns what the code did before. The bind's
;;; own state, pool, snapshot and ends live in the binder's file, behind his kit hooks (binder first in every call):
;;;   :bind (x)              true while X binds (BIND-OF)
;;;   :bind-damage (b a d n) A dealt D N (nominal) inside the bind (DEAL-DAMAGE): the pool's drain
;;;   :bind-pool (b &optional n)  the shared Reiatsu (REIATSU-OF), after spending N of it (REIATSU-SPEND!)
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

(defun reiatsu-of (e)
  "The Reiatsu E has to spend: his gauge, or in a bind the shared pool (the binder's :bind-pool)."
  (let* ((b (bind-of e)) (h (bind-hook b :bind-pool))) (if h (funcall h b) (gauges-reiatsu (gauges e)))))

(defun reiatsu-spend! (e bars)
  "E spends BARS of Reiatsu (an SP's cost): from his gauge, or in a bind from the shared pool."
  (let* ((b (bind-of e)) (h (bind-hook b :bind-pool)) (g (gauges e)))
    (if h
        (funcall h b (* bars *reiatsu-bar*))
        (setf (gauges-reiatsu g) (f32 (spend-bars (gauges-reiatsu g) bars))))))

(defun reiatsu-gain! (e n)
  "E's Reiatsu + N (kept in 0 .. *REIATSU-MAX*): every gain goes through here (hits, KOSEI, the regen, BLUE's bar, WHITE's,
the Kikon refund, the reset's, a kit's own). In a bind every gain is frozen (DUEL_HISAGI §17.3 B4)."
  (unless (bind-of e)
    (let ((g (gauges e))) (setf (gauges-reiatsu g) (f32 (gauge-add (gauges-reiatsu g) n *reiatsu-max*))))))

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

(defun awaken-fill! (g x)
  "X more awakening for G's owner: the awakening gauge, then SUBLIMATION, or SPIRIT DRIVE once awakened (AWAKEN-OVERFLOW)."
  (multiple-value-bind (aw sub drive) (awaken-overflow (gauges-awakened g) (gauges-awaken g) (gauges-sub g) (gauges-drive g) x)
    (setf (gauges-awaken g) (f32 aw) (gauges-sub g) (f32 sub) (gauges-drive g) (f32 drive))))

(defun sub-of (e)
  "E's SUBLIMATION / SPIRIT DRIVE bonus fraction 0..1 (SUB-FRAC)."
  (let ((g (gauges e))) (sub-frac (gauges-awakened g) (gauges-sub g) (gauges-sub-s g) (gauges-drive g))))

(defun sub-speed-mult (e)
  "Walk / run speed x (1 + *SUB-SPEED* x SUB-OF)."
  (+ 1.0 (* *sub-speed* (sub-of e))))

(defun drive-full-p (e)
  "Is E's SPIRIT DRIVE full (awakened, the gauge at *DRIVE-MAX*)? Opens Kenpachi's Bankai."
  (let ((g (gauges e))) (and (gauges-awakened g) (>= (gauges-drive g) *drive-max*))))

(defun pay-gauges (e r fs)
  "E gains R Reiatsu (REIATSU-GAIN!) and FS flash-step (each kept at its max; no flash-step during a burst: BURST-FS-GAIN; the
flash-step x (1 + *SUB-FS* x SUB-OF))."
  (let ((g (gauges e)))
    (reiatsu-gain! e r)
    (setf (gauges-fs g) (f32 (gauge-add (gauges-fs g) (* (burst-fs-gain fs (gauges-burst g)) (+ 1.0 (* *sub-fs* (sub-of e)))) *fs-max*)))))

(defun gain-gauges (e dealt taken &optional (rbase 0) (n 1))
  "Reiatsu, flash-step and Fighting Spirit for dealing DEALT / taking TAKEN damage, RBASE the hit's Reiatsu at the combo's
Nth hit (HIT-GAINS; siphoned: SIPHON-OF)."
  (let ((g (gauges e)) (to (siphon-of e)))
    (multiple-value-bind (r fs aw sr sfs) (hit-gains dealt taken to (burst-gain-mult (gauges-burst g)) rbase n)
      (pay-gauges e r fs)
      (when to (pay-gauges to sr sfs))
      (awaken-fill! g aw))))

(defun hit-rbase (mv hazard base)
  "The Reiatsu a hit of MV (or HAZARD: its move's at its spawn) with BASE damage pays its attacker before the combo bonus
(HIT-REIATSU-BASE; no damage: none)."
  (cond ((<= base 0) 0)
        (hazard (hazard-rbase hazard))
        (mv (hit-reiatsu-base (mv-kind mv) (getf (mv-params mv) :reiatsu)))
        (t *reiatsu-kind-other*)))

(defun deal-damage (att def dmg &optional (rbase 0) (n 1))
  "DEF loses DMG Reishi (ATT dealt it; a CPU attacker's anti-stall heat resets); RBASE the hit's Reiatsu for ATT, N its
combo index (both sides' gains x COMBO-GAIN-MULT: GAIN-GAUGES; chip, a drink: RBASE 0). Reishi at 0 is an automatic Soul
Break, settled at the end of the step (*SOUL-BREAKS*): returns T then. In a bind (BIND-OF) the loss is grey: Reishi
floors at 0 with no Soul Break, the nominal DMG goes to the binder's :bind-damage (the pool's drain) and to ATT's grey
count (DEALT-REAL)."
  (let* ((ga (gauges att)) (gd (gauges def)) (b (brain att)) (bd (bind-of def)) (h (bind-hook bd :bind-damage)))
    (setf (gauges-reishi gd) (max 0 (- (gauges-reishi gd) dmg)))
    (when (and *run-mods* (plusp dmg) (run-mods-on-p def)) (setf (rmst-unhit (rm-of def)) 0))   ; DANGAI's :regen waits
    (incf (gauges-dealt ga) dmg)
    (when bd (incf (gauges-grey ga) dmg))
    (when h (funcall h bd att def dmg))
    (when b (setf (brain-heat b) 0f0))
    (incf (fighter-combo-dmg (fighter def)) dmg)
    (gain-gauges att dmg 0 rbase n)
    (gain-gauges def 0 dmg 0 n)
    (nome-gain! att dmg 0 0)
    (nome-gain! def 0 dmg 0)
    (when (and (not bd) (soul-break-p (gauges-reishi gd)))
      (queue-soul-break! att def)
      t)))

(defun queue-soul-break! (att def)
  "DEF's soul breaks (by ATT), settled with the step's others (SETTLE-SOULS: in the order queued, the first's attacker
picks the cinematic); once per victim. (A bind's drained end queues its own: DUEL_HISAGI §17.3 B7.)"
  (unless (rassoc def *soul-breaks*) (push (cons att def) *soul-breaks*)))

(defun nome-gain! (e dealt taken drunk)
  "NOME (a form with :meter-gain: Nozarashi's cups) for DEALT / TAKEN / DRUNK points; a gain restarts RYOTE's
drain delay."
  (let ((mg (kit-meter-gain (kit-of e))))
    (when (and mg (not (siphon-of e)))
      (let ((n (nome-gain dealt taken drunk mg)) (g (gauges e)))
        (when (plusp n)
          (setf (gauges-meter g) (f32 (gauge-add (gauges-meter g) n (getf (kit-meter (kit-of e)) :max 100.0)))
                (gauges-meter-idle g) 0))))))

(defun respect (e)
  "The opponent outplayed E (his counter-hit, perfect Hoho, parry or Burst against E): E's :respect-callout
(Nozarashi: \"OMOSHIREE!\", a callout only: no meter)."
  (let ((c (kit-respect-callout (kit-of e)))) (when c (callout e c))))

(defun add-meter (e amount)
  "The kit meter (Inferno) of E's form, if it has one and isn't running as a timer."
  (let ((g (gauges e)) (m (kit-meter (kit-of e))))
    (when (and m (plusp amount) (zerop (gauges-form-left g)) (not (siphon-of e)))
      (setf (gauges-meter g) (f32 (gauge-add (gauges-meter g) amount (getf m :max)))))))

(defun kosei! (att g x y z)
  "KOSEI (docs/duel/DUEL_STRINGS.md §5): a contact of ATT's own melee hit window worth G points (KOSEI-BASE x the combo
bonus, since 2026-10-26; before: its guard value) pays him Reiatsu and
flash-step, x KOSEI-MULT of his guard gauge (x1 full .. x3 empty); the :kosei event (the HUD's mote from X Y Z). Siphoned
(SIPHON-OF), it pays the siphoning side."
  (let ((to (or (siphon-of att) att)))
    (multiple-value-bind (r fs m) (kosei-gain g (gauges-gg (gauges att)))
      (pay-gauges to (* r (burst-gain-mult (gauges-burst (gauges att)))) fs)   ; ORANGE: x1.5 Reiatsu
      (emit :kosei to m x y z))))

;;; ---------------------------------------------------------------- DANGAI's run modifiers on a hit (run-mods.lisp, DUEL_ROGUE §4.4)
(defun run-atk-mods (att atk mv hazard)
  "ATK (APPLY-HIT's attacker plist) with the run table's damage multiplier for ATT (RUN-DMG-MULT): :dmg, :red-dmg while he
is red, :ender-dmg on a J3 / K3 (an :ender of kind :quick / :flash), :sp-dmg on an SP (its hazards: while he is still in
it), :ender-sp-dmg on an SP started off an ender's hit, :post-burst-dmg on the first hit after his Hoho / Burst. ATK
itself when it is x1."
  (let* ((st (rm-of att)) (sm (or mv (and hazard (current-move (fighter att)))))
         (m (run-dmg-mult *run-mods* :red (gauges-red-p (gauges att))
                                     :ender (and mv (member :ender (mv-flags mv)) (member (mv-kind mv) '(:quick :flash)) t)
                                     :sp (and sm (eq (mv-kind sm) :sp)) :ender-sp (rmst-ender-sp st)
                                     :post-burst (rmst-post-burst st))))
    (if (= m 1.0)
        atk
        (progn (log-msg "duel runmod dmg x~,3f ~(~a~)" m (cond (mv (mv-name mv)) (hazard (hazard-kind hazard)) (t :counter)))
               (list* :mult (* (getf atk :mult 1.0) m) atk)))))

(defun run-def-mods (def dmods flags)
  "DMODS (APPLY-HIT's defender plist) with the run table's taken multiplier for DEF (RUN-TAKEN-MULT): :breaker-taken from a
:breaker window (FLAGS), :awake-taken while awakened, :perfect-taken inside the window after his perfect Hoho. DMODS
itself when it is x1."
  (let ((m (run-taken-mult *run-mods* :breaker (and (member :breaker flags) t) :awake (gauges-awakened (gauges def))
                                      :perfect (plusp (rmst-perfect-left (rm-of def))))))
    (if (= m 1.0)
        dmods
        (progn (log-msg "duel runmod taken x~,3f" m)
               (list* :mult (* (getf dmods :mult 1.0) m) dmods)))))

(defun run-hit-landed! (att res mv own)
  "ATT's hit landed as RES (APPLY-HIT): a real hit spends his post-Hoho / Burst first hit (:post-burst-fs of max back),
and his own J3 / K3's opens the :ender-sp-dmg window."
  (when (and (run-mods-on-p att) (member res '(:hit :counter)))
    (let ((st (rm-of att)) (g (gauges att)))
      (when (rmst-post-burst st)
        (setf (rmst-post-burst st) nil)
        (let ((fs (rmod att :post-burst-fs nil)))
          (when fs
            (setf (gauges-fs g) (f32 (gauge-add (gauges-fs g) (* fs *fs-max*) *fs-max*)))
            (log-msg "duel runmod post-burst-fs ~,1f" (gauges-fs g)))))
      (when (and own mv (member :ender (mv-flags mv)) (member (mv-kind mv) '(:quick :flash)))
        (setf (rmst-ender-left st) *run-ender-window*)))))

(defun run-revive! (def)
  "DEF's Konpaku ran out: his :revive (once a match, a stage) brings this many back (NIL: none, or used)."
  (let ((n (rmod def :revive nil)))
    (when (and n (plusp n) (not (rmst-revived (rm-of def))))
      (setf (rmst-revived (rm-of def)) t)
      (log-msg "duel runmod revive ~d" n)
      n)))

(defun run-mods-step! (e g)
  "One sim frame of E's run state (GAUGE-SYSTEM, gauges G): its windows and armour count down, :red-armor's refill, and
:regen (Reishi, of max a second, after *RUN-REGEN-DELAY* frames unhit, not while red)."
  (when (run-mods-on-p e)
    (let ((st (rm-of e)))
      (when (plusp (rmst-ender-left st)) (decf (rmst-ender-left st)))
      (when (plusp (rmst-perfect-left st)) (decf (rmst-perfect-left st)))
      (when (plusp (rmst-armor-t st)) (decf (rmst-armor-t st)))
      (when (plusp (rmst-red-cd st)) (decf (rmst-red-cd st)))
      (setf (rmst-unhit st) (min 99999 (1+ (rmst-unhit st))))
      (when (zerop (mod (incf (rmst-frames st)) 600))
        (log-msg "duel runmod state f ~d reishi ~d fs ~,1f reiatsu ~,1f gg ~,1f unhit ~d armor ~d red-cd ~d"
                 (rmst-frames st) (gauges-reishi g) (gauges-fs g) (gauges-reiatsu g) (gauges-gg g) (rmst-unhit st)
                 (rmst-armor-t st) (rmst-red-cd st)))
      (let ((r (rmod e :regen nil)))
        (when (and r (not (gauges-red-p g)))
          (let ((n (run-regen-heal (rmst-unhit st) (gauges-reishi-max g) r)))
            (when (plusp n) (heal! e n))
            (when (= (rmst-unhit st) (+ 60 *run-regen-delay*)) (log-msg "duel runmod regen 1 s reishi ~d" (gauges-reishi g)))))))))

;;; ---------------------------------------------------------------- one hit
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

(defun ward-drop (e)
  "E's ward is broken (a GUARD CRUSH or a Guard Break): Bankai West drops to his kit's :drop-to form (East), the garb
blown off (the :ward-crush event); a kit with a :crush-hook calls it instead (Rukia's CRACK)."
  (when (passive-p e :ward)
    (let ((h (kit-crush-hook (kit-of e))))
      (if h
          (funcall h e)
          (progn (set-form e (kit-drop-to (kit-of e))) (emit :ward-crush e))))
    (clog "~a WARD BROKEN" (side-name e))))

(defun cold-add! (e n)
  "E's cold gauge (a :temp kit meter) changes by N (a blocked melee hit cools her, a real hit warms her), clamped to
0 .. *COLD-MAX*; the band follows once she is free (rukia-meter.lisp RUKIA-COLD-STEP)."
  (when (and (getf (kit-meter (kit-of e)) :temp) (or (<= n 0) (not (siphon-of e))))   ; (siphoned: no cooling)
    (let ((g (gauges e)))
      (setf (gauges-meter g) (f32 (max 0.0 (min *cold-max* (+ (gauges-meter g) n))))))))

(defun scorch (att def &optional (n *scorch*))
  "DEF's :scorch (Bankai West): a melee hit his parry caught burns ATT N (a burn: never kills, no gauges, no heat
reset)."
  (when (and (passive-p def :scorch) (plusp n))
    (let ((g (gauges att))) (setf (gauges-reishi g) (burn (gauges-reishi g) n)))
    (emit :scorch att)
    (clog "~a scorched ~d" (side-name att) n)))

(defun freeze-touch! (e att)
  "E's absolute zero (passive :freeze-touch, once per zero window): the melee hit her ward just blocked freezes ATT, a
:bind hazard at his feet a frame later (unguardable, no damage, *FREEZE-TOUCH* frames: an opener that books 2 combo hits,
so he may Burst)."
  (let ((q (pos-of att)))
    (setf (gauges-froze (gauges e)) t)
    (spawn-hazard :freeze e :x (aref q 0) :z (aref q 2) :size 0.7 :y 2.2 :delay 1 :life 2
                          :hw (make-hitwin :dmg 0 :react :bind :stun *freeze-touch* :hs *hitstop-heavy* :frost *freeze-touch*
                                           :flags '(:unguardable :ice)))
    (emit :sfx :freeze e)
    (clog "~a FREEZE-TOUCH ~a" (side-name e) (side-name att))))

(defun apply-hit (att def hw sx sz &key mv hazard def-state (bonus 0) crush x z red)
  "Apply hit HW of ATT (a fighter) to DEF, coming from (SX SZ) (the attacker or the HAZARD: guard
facing and push direction). MV, BONUS (damage added: the stance's stored) and CRUSH: ATT's move
and its state when the hit was collected (in a trade the first hit applied may already have put ATT
in hitstun). DEF-STATE and RED: DEF's triangle state and red-ness when collected. X Z: where to show
it. Sets the global hitstop (sim timing). A ranged hit (a HAZARD, or a window flagged :ranged beyond its move's
:melee-range) can't be parried. A defender with the :ward (Bankai West) blocks from every side with no blockstun (what
he does goes on: super armour); a crush or a Guard Break drops him to East (WARD-DROP). An attacker with :pierce
(Bankai East) deals x(1 + k) (PIERCE-RATE of his guard gauge, x the move's :pierce-mult), and a block lets k x the
damage through as chip (on top of a DRINK's taken half). A Kikon rush strike (MV of kind :kikon) is guardable like any
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
         (optic (optic-p (passive-p def :ward) (passive-p def :optic) ranged))   ; Rukia's absolute zero: ranged hits pass
         (def-state (if (and optic (eq def-state :guard)) :neutral def-state))
         (rward (and ranged (eq (fighter-state fd) :move) (member :ranged-ward (mv-flags (fighter-move fd)))   ; a :ranged-ward
                     (ranged-ward-p t ranged def-state (can-guard-p (gauges-gg (gauges def)) (gauges-guardless (gauges def))))))
         (def-state (if rward :guard def-state))        ;  move (Hisagi's windmill): this hit is guarded from every side
         (ward (and (or (passive-p def :ward)           ; Bankai West's ward; a :parry-block parry blocks what it can't catch
                        (and (eq def-state :parry) (passive-p def :parry-block))
                        rward)
                    (not optic)))
         (k (if (passive-p att :pierce)                 ; Bankai East's pierce
                (pierce-rate (gauges-gg (gauges att)) (or (and mv (getf (mv-params mv) :pierce-mult)) 1.0))
                0.0))
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
                                (let ((px (* (if (eq res :blocked) 1.0 (+ 1.0 k)) (if (and own (fighter-assisted fa)) *assist-mult* 1.0)   ; ASSIST
                                             (core-charge-mult fa mv own hazard)
                                             (+ 1.0 (* *sub-dmg* (sub-of att)))))   ; a charged SA's string (core-sim.lisp); SUBLIMATION / DRIVE
                                      (h (kit-hook (kit-of att) :dmg-mult)))   ; a kit's distance x (Hisagi's tip / close-in)
                                  (if h (* px (funcall h att def hw mv hazard d2)) px))
                                (and mv (getf (mv-params mv) :form-mult)))))   ; (a move's own form x: the owl's stance K / KL)
         (dmods (if (or optic flat) '(:mult 1.0) (sub-taken-mods (kit-def-mods (kit-of def)) (sub-of def))))   ; (a ranged hit through Rukia's ward: x1.0 taken)
         (atk (if (and *run-mods* (run-mods-on-p att)) (run-atk-mods att atk mv hazard) atk))     ; DANGAI's run table
         (dmods (if (and *run-mods* (run-mods-on-p def)) (run-def-mods def dmods flags) dmods))
         (x (or x (aref p 0))) (z (or z (aref p 2))) (y (+ (aref p 1) 1.1))
         (base (+ (hw-dmg hw) bonus))
         (outcome (and rush (kikon-outcome (if (and mv (eq (mv-kind mv) :kikon)) (vpad-down (pilot-vpad (pilot att)) :kikon) (and (eq (fighter-sp-held fa) t) (core-held-p att)))
                                           res fstrike)))
         (follow (eq outcome :follow)))                 ; knocked back, then the rusher dashes in to the follow-up
    (when (eq outcome :kikon)
      (if (rmod def :kikon-guard nil)                   ; DANGAI's :kikon-guard: the Kikon guarded, nothing lost
          (setf res :kikon-guarded)
          (progn (setf res :kikon)
                 (unless (find def *kikons* :key #'second) (push (list att def mv) *kikons*)))))
    (when res
      (let ((first (and own (not (eq (fighter-contact fa) :hit)) (eq (contact-of res) :hit))))   ; its first real hit
        (when own                                       ; only a real hit counts as one (CONTACT-OF)
          (setf (fighter-contact fa) (if (eq (contact-of res) :hit) :hit (or (fighter-contact fa) :block)))
          (when (< (fighter-land-sf fa) 0) (setf (fighter-land-sf fa) (fighter-sf fa))))
        (clog "~a ~a -> ~a ~a ~d" (side-name att) (if mv (mv-name mv) (if hazard (hazard-kind hazard) :counter))
              (side-name def) res base)
        (when (eq (contact-of res) :hit) (close-rifts def))   ; a rift closes if its owner is hit before it cuts
        (when (and hazard (eq (contact-of res) :hit)) (setf (fighter-hz-hit fa) t))   ; (his move's :r-cancel-from; ponytail:
                                                        ;  any hazard of his counts, scope it to the spawning move if one needs)
        (when (and own (not ranged) (not (member res '(:parried :kikon))))   ; KOSEI: his own blade touched him
          (kosei! att (* (kosei-base (mv-kind mv) (getf (mv-params mv) :kosei))   ; its kind's points x the combo bonus
                         (combo-gain-mult (if (eq (contact-of res) :hit)            ;  (this hit's index; a block 1)
                                              (- (1+ (fighter-combo-hits fd)) (fighter-combo-from fd))
                                              1)))
                  x y z))
        (when (eq res :counter) (respect def) (incf (gauges-counters (gauges att))))
        (when *run-mods* (run-hit-landed! att res mv own))
        (ecase res
          (:kikon nil)                                  ; settled at the end of the step (SETTLE-SOULS)
          (:kikon-guarded                               ; DANGAI's :kikon-guard: a block with no drain, no chip
           (set-blockstun def (blockstun (mv-total mv) (fighter-sf fa) 0) sx sz 0)
           (hitstop *hitstop-block*)
           (emit :blocked att def x y z)
           (log-msg "duel runmod kikon-guard side ~d" (fighter-side fd)))
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
                                (t (hitstun react (eq res :counter)))))
                    (frost (max (hw-frost hw) (kit-frost-touch (kit-of att)))))
               (setf (gauges-stun gd) (if blow 0f0 (f32 st)) (gauges-stun-idle gd) 0)
               (when (plusp frost) (setf (fighter-frost fd) (frost-next (fighter-frost fd) frost)))   ; Rukia's ice
               (if ranged (incf (gauges-taken-ranged (gauges def)) dmg) (incf (gauges-taken-melee (gauges def)) dmg))
               (cold-add! def (- (* *ru-hit-warm* dmg)))  ; Rukia: a real hit warms her
               (setf (gauges-best-combo (gauges att)) (max hits (gauges-best-combo (gauges att))))
               (add-meter att (hw-meter hw))
               (hitstop (hw-hs hw))
               (emit :hit att def x y z (hw-hs hw) (eq res :counter) dmg
                     (cond ((member :ice flags) :ice) ((eq react :bind) :bind) ((member :blade flags) :flash)
                           ((member :thread flags) :quick) (hazard :fire)
                           (mv (mv-kind mv)) (t :counter)))
               (unless (deal-damage att def dmg (hit-rbase mv hazard base) (max 1 (- hits (fighter-combo-from fd))))   ; (a broken
                                                        ;  soul crumples in its cinematic)
                 (if blow
                     (progn (set-reaction def react stun sx sz *stun-blow-kb*)   ; the blow-away
                            (incf *blow-aways*)
                            (clog "~a BLOWN AWAY by ~a (stun tolerance ~,1f, combo hit ~d)" (side-name def) (side-name att)
                                  (stun-tolerance-of (kit-of def)) hits))
                     (progn (set-reaction def react stun sx sz (if follow *kikon-follow-kb* (hw-kb hw)))
                            (when (and own (not hazard) (member :ender (mv-flags mv)) (member (mv-kind mv) '(:quick :flash)))
                              (ender-push att def mv))                       ; J3 / K3: out of J1 / K1's reach at once
                            (when (and own (not hazard) (not (fighter-chained fa))   ; a string's opener (J1 / K1) hit:
                                       (string-opener-p (kit-of att) mv att))         ; the attacker dashes in to (not :no-close)
                              (let ((pull (- (sqrt d2) *string-pull-to*)))         ; point-blank, so the string's links
                                (when (> pull 0.01)                                ; reach him (the user 2026-10-02:
                                  (set-slide att pull *string-pull-frames* (- (aref p 0) sx) (- (aref p 2) sz))))))))   ; no chase)
               (when (and (eq (kit-class (fighter-kit fa) mv) :as) (not hazard)) (core-on-hit! att def mv))
               (when (and follow wave) (core-wave-follow! att wave))   ; a wave's: he flash-steps in to its strike
               (when (and follow (or own wave))           ; the rush dashes in, then strikes again (KIKON-RUSH-STEP)
                 (setf (fighter-kikon-undo fa)            ; a core SP's: a let-go in the confirm makes this hit an ordinary
                       (and (or wave (core-kikon-p fa mv))   ;  one (CORE-KIKON-UNDO!), its cues wait for the hitstop's end
                            (let ((r (hw-react hw))) (list def r (or (hw-stun hw) (hitstun r (eq res :counter))) sx sz (hw-kb hw) (and wave t)))))
                 (when (fighter-kikon-undo fa) (core-set-kikon-n! att red))
                 (setf (fighter-phase fa) :follow (fighter-hold fa) 0 (fighter-follow fa) t
                       (fighter-kikon-lock fd) (if red 2 1))   ; (2026-10-24: guard only, or nothing when red; KIKON-LOCK-P)
                 (unless (fighter-kikon-undo fa) (core-follow-cues att def))   ; (a core SP's: CORE-FOLLOW-STEP)
                 (clog "~a KIKON FOLLOW-UP on ~a~:[~; (red)~]" (side-name att) (side-name def) red)))))
          (:armored                                     ; a move's armour (one hit spent)
           (if (and *run-mods* (eq def-state :armor) (run-armor-p def)   ; DANGAI's run armour, unless his move's own took it
                    (not (and (eq (fighter-state fd) :move) (own-armor-p def fd (fighter-move fd)))))
               (run-armor-spend! def)
               (when (and (eq def-state :armor) (plusp (fighter-armor-left fd))) (decf (fighter-armor-left fd))))   ; (a kit's
                                                        ;  :armor hook pays its own price: its :struck)
           (hitstop *hitstop-block*)
           (emit :armored def x y z)
           (deal-damage att def (hit-damage base atk dmods 1 nil) (hit-rbase mv hazard base)))
          (:parried                                     ; the attacker staggers, the parry counters (its :land string)
           (hitstop *hitstop-breaker*)
           (respect att)
           (set-reaction att :stagger *parry-stun* (aref p 0) (aref p 2) *parry-slide*)
           (setf (fighter-armor-left fa) 0)
           (scorch att def)
           (when (and (passive-p def :ward) (not (siphon-of def)))   ; West's GOKUI GAESHI: the catch refills his guard gauge
             (setf (gauges-gg (gauges def)) (f32 (gg-cap def)) (gauges-gg-idle (gauges def)) 0))
           (let ((h (kit-hook (kit-of def) :parried))) (when (and h (not (siphon-of def))) (funcall h def att)))   ; its own catch
           (emit :parried att def x y z)
           (let ((c (and (fighter-move fd) (kit-next (kit-of def) (mv-name (fighter-move fd)) :land))))
             (when c (start-move def c))))
          (:absorbed
           (let ((dmg (hit-damage base atk dmods 1 nil)))
             (setf (fighter-stored fd) (stance-store (fighter-stored fd) dmg))
             (hitstop *hitstop-block*)
             (emit :absorbed def x y z)
             (deal-damage att def dmg (hit-rbase mv hazard base))
             (nome-gain! def 0 0 dmg)))                 ; the stance drinks what it absorbs (NOME)
          (:blocked                                     ; blockstun, chip, the guard gauge (at 0: GUARD CRUSH);
                                                        ; DRINK (NOMIHOSE's U): half the hit taken for real, half drunk;
                                                        ; the ward (Bankai West): x*WARD-MULT* of the gauge, no blockstun;
                                                        ; East's pierce: k x the hit goes through (chip)
           (let* ((drink (passive-p def :drink))
                  (catch (and ranged (not (member :uncatchable flags))      ; a :shield move's catch (an :uncatchable
                              (fighter-move fd) (getf (mv-params (fighter-move fd)) :catch)))   ; window goes through it)
                  (adv (let ((a (if (and mv (integerp (mv-adv-block mv))) (mv-adv-block mv) 0)))
                         (- (if (and drink mv) (drink-adv a) a)          ; (the attacker's advantage: a blocked J's
                            (if (and mv (eq (mv-kind mv) :quick)) *quick-block-adv* 0))))   ; defender is free sooner)
                  (stun (if mv (blockstun (mv-total mv) (fighter-sf fa) adv) *hazard-blockstun*))
                  (v (rmod-x att :guard-drain                     ; (DANGAI's :guard-drain)
                             (let* ((v0 (or (hw-guard hw) *gg-hazard*)) (v1 (if (and mv (passive-p att :cut)) (cut-value v0 (mv-kind mv)) v0)))
                               (if (and ward (passive-p def :ward))
                                   (* (if (passive-p def :intangible) *mujittai-mult* *ward-mult*) v1)   ; (an intangible ward's own)
                                   v1))))
                  (pierce (and (plusp k) k))
                  (intangible (and ward (passive-p def :ward) (passive-p def :intangible)))   ; it passes through him
                  (chip (let ((c (if (or catch (passive-p def :chipless) intangible)   ; Rukia awakened, an intangible ward: no chip
                                     0
                                     (chip-damage base (if drink pierce (or (hw-chip hw) (and mv (kit-blade-chip (kit-of att))) pierce))
                                                  (gauges-reishi (gauges def)))))
                              (m (rmod def :chip-taken nil)))      ; (DANGAI's :chip-taken)
                          (if m (round (* c m)) c))))
             (cond (catch (funcall catch def base) (hitstop *hitstop-block*) (emit :blocked att def x y z))   ; no gauge, no stun
                   ((drain-guard def v)
                    (ward-drop def)
                    (set-reaction def :guard-break *guard-crush-stun* sx sz *block-pushback*)
                    (hitstop *hitstop-breaker*)
                    (emit :guard-crush att def x y z)
                    (clog "~a GUARD CRUSH~:[~; (drinking)~]" (side-name def) drink))
                   (ward                                ; super armour: no blockstun, what he does goes on
                    (unless intangible (set-slide def *block-pushback* 6 (- (aref p 0) sx) (- (aref p 2) sz)))   ; (no push)
                    (setf (fighter-warded fd) *match-tick*)
                    (when rward (setf (fighter-ward-until fd) (+ *match-tick* *hitstop-block* stun)))   ; the windmill: a guard's wait (+ its hitstop)
                    (when (and (passive-p def :freeze-touch) (not ranged) (not (gauges-froze (gauges def))))
                      (freeze-touch! def att))           ; Rukia's absolute zero: whatever touches her freezes
                    (hitstop *hitstop-block*)
                    (emit :blocked att def x y z))
                   (t (set-blockstun def stun sx sz adv (and drink (kit-drink-clip (kit-of def))))
                      (hitstop *hitstop-block*)
                      (emit (if drink :drink :blocked) att def x y z)))
             (when drink                                ; the drink: real damage (it may Soul Break him), NOME
               (multiple-value-bind (taken drunk) (drink-split (hit-damage base atk dmods 1 nil))
                 (deal-damage att def taken)
                 (nome-gain! def 0 0 drunk)
                 (clog "~a DRINK ~d (+~d drunk)" (side-name def) taken drunk)))
             (when (and *run-mods* (or (run-mods-on-p att) (run-mods-on-p def)))
               (log-msg "duel runmod block side ~d drain ~,1f chip ~d" (fighter-side fd) v chip))
             (when (plusp chip) (deal-damage att def chip))
             (when (and mv (not ranged)) (cold-add! def (* *ru-block-cool* (or (hw-guard hw) 0))))   ; Rukia: a blocked blade cools her
             (when (and hazard (plusp (hw-meter hw))) (add-meter att *meter-on-block*))))
          (:guard-break
           (drain-guard def *gg-breaker* :breaker)
           (ward-drop def)                              ; a Breaker blows West's ward off: East
           (set-reaction def :guard-break *guard-break-stun* sx sz *guard-break-kb*)
           (hitstop *hitstop-breaker*)
           (emit :guard-break att def x y z))
          (:stance-break
           (set-reaction def :crumple *stance-break-stun* sx sz *stance-break-kb*)
           (hitstop *hitstop-breaker*)
           (emit :stance-break att def x y z)))
        (let ((h (kit-hook (kit-of att) :hit))) (when h (funcall h att def res hw mv hazard ranged)))   ; a character's
        (let ((h (kit-hook (kit-of def) :struck))) (when h (funcall h def att res hw mv hazard ranged)))   ; own hit rules
        (when (and first (mv-on-land mv) (not *cine*)) (funcall (mv-on-land mv) att)))
      res)))

;;; ---------------------------------------------------------------- the system
(defstruct pending
  "One hit collected this step, with what it needs of the attacker as he was then (they are applied
after all are collected). I: the move's window index; HAZARD: the hazard dealing it (NIL = melee);
STATE RED: the defender's triangle state and red-ness; MV BONUS CRUSH: the attacker's move, stored
damage, guard crush."
  att def hw (i 0) (sx 0f0) (sz 0f0) hazard state red mv (bonus 0) crush)

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
                          (let ((mn (hw-min w)))         ; a :min-reach dead zone (not a Kikon's follow-up strike)
                            (or (null mn) (fighter-follow f) (>= (hypot (- (aref q 0) (aref p 0)) (- (aref q 2) (aref p 2))) mn)))
                          (window-touches-p w e (aref p 0) (aref p 1) (aref p 2) fx fz (aref q 0) (aref q 1) (aref q 2)
                                            (body-hurt-r ob) (body-hurt-h ob)))   ; (its volumes, or its :seg-fn capsule)
                  do (push (make-pending :att e :def o :hw w :i i :sx (aref p 0) :sz (aref p 2)
                                         :state (defender-state o) :mv mv
                                         :red (or (gauges-red-p go) (plusp (fighter-seal (fighter o))))   ; (a sealing bind: as red)
                                         :bonus (fighter-dmg-bonus f) :crush (fighter-crush f))
                           *pending*)))))))

(defun cut-hazards (e f)
  "Nozarashi (:projectile-cut): an open window of E's move destroys the opponent's hazards it touches."
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
                       (emit :hazard-cut (hazard-x hz) (f32 (+ 1.0 (hazard-y hz))) (hazard-z hz))
                       (clog "~a cuts ~a" (side-name e) (hazard-kind hz))
                       (destroy-entity h))))))))

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
settle the souls they broke (the bind's drained check first: BIND-STEP! :hits)."
  (let ((a nil) (b nil))
    (do-entities (e (f fighter)) (if a (setf b e) (setf a e)))
    (when (and a b)
      (let ((pa (breaker-phase a)) (pb (breaker-phase b)))
        (when (and pa pb (breaker-clash-p pa pb (fighter-dist (fighter a))))
          (clash! a b))))
    (hit-apply)
    (bind-step! a :hits))
  (settle-souls))

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
    (setf (gauges-burst g) mode (gauges-burst-t g) 0 (gauges-fs-idle g) 0)
    (when *run-mods* (run-post-burst! e))
    (case mode
      (:blue (repel! e)                                   ; + one Reiatsu bar, as RoS does (the user 2026-09-30)
       (reiatsu-gain! e *reiatsu-bar*))
      (:orange (to-idle e 0) (setf (fighter-chain f) *chain-window*)
       (setf (fighter-combo-from (fighter o)) (fighter-combo-hits (fighter o)))))   ; (his combo's scaling starts over)
    (hitstop *burst-hitstop*)
    (emit :burst e o mode)
    (clog "~a BURST ~a fs ~,1f" (side-name e) mode (gauges-fs g))))

(defun burst-end! (e)
  "E's burst ends (its flash-step ran out, or a Kikon / Soul Break reset): the regen delay restarts."
  (let ((g (gauges e)))
    (when (gauges-burst g)
      (clog "~a BURST END ~a" (side-name e) (gauges-burst g))
      (setf (gauges-burst g) nil (gauges-burst-t g) 0 (gauges-fs-idle g) 0 (fighter-chain (fighter e)) 0)
      (emit :burst-end e))))

(defun white-regen! (e g n)
  "WHITE's regen on E's frame N (1-based): Reishi (HEAL!), Reiatsu (REIATSU-GAIN!) and (not yet awakened) the awakening
gauge G."
  (heal! e (burst-heal n *white-reishi*))
  (reiatsu-gain! e (/ *white-reiatsu* 60.0))
  (awaken-fill! g (/ *white-awaken* 60.0)))

(defun burst-step (e g)
  "A running burst, one frame: the flash-step drains (BURST-DRAIN), WHITE's regen (WHITE-REGEN!); at 0 it ends."
  (let ((n (incf (gauges-burst-t g))))
    (setf (gauges-fs g) (f32 (burst-drain (gauges-fs g))))
    (when (eq (gauges-burst g) :white) (white-regen! e g n))
    (when (<= (gauges-fs g) 0.0) (burst-end! e))))

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
  (let* ((f (fighter e)) (g (gauges e)) (old (fighter-kit f)) (new (fighter-find-kit e form)))
    (when (and (kit-exit-hook old) (not (eq old new))) (funcall (kit-exit-hook old) e))
    (setf (fighter-kit f) new (fighter-form f) form (gauges-burn-step g) 0
          (gauges-form-left g) (if (kit-duration new) (seconds->frames (kit-duration new)) 0)
          (gauges-form-total g) (gauges-form-left g))
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
    (heal! e (round (* (rmod-plus e :awaken-heal *awaken-heal*) (gauges-reishi-max g))))   ; (DANGAI's :awaken-heal)
    (when *run-mods*                                    ; (its armour counts once the cinematic is over: GAUGE-SYSTEM)
      (run-armor-give! e :armor-on-awaken)
      (when (run-mods-on-p e) (log-msg "duel runmod awaken reishi ~d of ~d" (gauges-reishi g) (gauges-reishi-max g))))
    (emit :awaken e)
    (if (kit-cine (kit-of e))
        (start-cine (kit-cine (kit-of e)) e o :after (lambda () (to-idle e 0) (to-idle o 0)))
        (to-idle e 0))))

;;; ---------------------------------------------------------------- Kenpachi's Bankai: the arm meter (docs/duel/DUEL_KEN_BANKAI.md)
(defun bankai! (e &optional (form (kit-bankai-form (kit-of e))))
  "The Bankai (P in cup 3, red, free: rules BANKAI-ALLOWED-P): the kit's :bankai-form, its arm meter full (the kit meter
holds the pips, the crack clock at 0), his Reishi refilled and, since 2026-10-31, his Konpaku KEPT (the user: 「改成不扣」; before: set to 1, the decisions of
2026-09-28: all his remaining souls for one full bar); the guard gauge, Reiatsu and flash-step as
they are; then the form's :cine (both fighters idle after it). FORM: the target (DANGAI's 隨時卍解 card names it from a cup
without one, and keeps his Konpaku: ken-meter.lisp KEN-CARD-BANKAI, DUEL_ROGUE §4.3)."
  (let* ((g (gauges e)) (o (opp-of e)) (keep t)   ; his Konpaku kept (the user 2026-10-31: 「改成不扣」, DUEL_SUBLIMATION §3; DANGAI's 隨時卍解 always did)
         (lost (if keep 0 (- (gauges-konpaku g) 1))))
    (repel! e)                                          ; the second awakening breaks his attack too
    (start-awake-regen! g)
    (set-form e form)
    (when (kit-pips (kit-of e))                         ; the arm meter, full (a form without :pips has none)
      (setf (gauges-meter g) (f32 (getf (kit-pips (kit-of e)) :n)) (gauges-meter-idle g) 0 (gauges-arm-pending g) nil
            (gauges-arm-owed g) nil))
    (setf (gauges-konpaku g) (if keep (gauges-konpaku g) 1) (gauges-reishi g) (gauges-reishi-max g))
    (refresh-look e)
    (when (plusp lost) (emit :konpaku e lost))
    (emit :bankai e)
    (clog "~a BANKAI (konpaku kept, -~d)" (side-name e) lost)
    (if (kit-cine (kit-of e))
        (start-cine (kit-cine (kit-of e)) e o :after (lambda () (to-idle e 0) (to-idle o 0)))
        (to-idle e 0))))

(defun arm-spend! (e mv)
  "A pip command starts MV (or a J / K string's pip is charged as it ends: MV the move running then, NIL none): one pip of
the arm spent, the crack clock restarted, *ARM-SELF* burnt
(BURN: never below 1). The last one: the burst is pending until MV is over (ken-meter.lisp KEN-ARM-STEP). The DANGAI
boss (*RUN-BOSS*) never spends one (DUEL_ROGUE §5: ken-meter.lisp KEN-BOSS), nor P1 holding the 無手臂限制 card (§4.3)."
  (let ((g (gauges e)))
    (when (or (eq e *run-boss*) (rmod e :no-arm nil))   ; (the boss, DANGAI's 無手臂限制 card)
      (log-msg "duel ~:[runmod no-arm~;boss kenpachi~] pip kept ~a" (eq e *run-boss*) (if mv (mv-name mv) ""))
      (return-from arm-spend! nil))
    (multiple-value-bind (n ok) (pip-spend (round (gauges-meter g)))
      (when ok
        (setf (gauges-meter g) (f32 n) (gauges-meter-idle g) 0 (gauges-reishi g) (burn (gauges-reishi g) *arm-self*))
        (when (zerop n) (setf (gauges-arm-pending g) (or mv :none)))
        (refresh-look e)
        (emit :arm-spend e n)
        (clog "~a UDE -~a ~d left" (side-name e) (if mv (mv-name mv) "") n)))))

(defun arm-burst! (e)
  "The arm bursts (the pending burst fired: rules BURST-DUE-P): the kit's :pips :to form (片腕), *ARM-BURST-SELF* burnt
and a self-inflicted *ARM-BURST-STUN* crumple in place (hits on him during it are ordinary hits)."
  (let ((g (gauges e)) (p (pos-of e)))
    (setf (gauges-arm-pending g) nil (gauges-arm-owed g) nil)
    (set-form e (getf (kit-pips (kit-of e)) :to))
    (setf (gauges-meter g) 0f0 (gauges-meter-idle g) 0 (gauges-reishi g) (burn (gauges-reishi g) *arm-burst-self*))
    (set-reaction e :crumple *arm-burst-stun* (aref p 0) (aref p 2) 0.0)
    (callout e "GOMEN NE, KEN-CHAN")
    (emit :arm-burst e)
    (clog "~a ARM BURST r~d" (side-name e) (gauges-reishi g))))

;;; ---------------------------------------------------------------- Kikon, Soul Break, reset
(defun bankai-ok-p (e)
  "The form's own condition on its :bankai-form (its kit's :bankai-ok, a function of E: e.g. a beheading and a free state;
the CPU's Bankai reflex reads the same), T without one (Kenpachi's cup 3). Never in a bind (BIND-OF: it rewrites his
Konpaku and Reishi, which a release would half undo; DUEL_HISAGI §17.3 B11)."
  (let ((h (kit-bankai-ok (kit-of e)))) (and (not (bind-of e)) (or (null h) (and (funcall h e) t)))))

(defun bankai-ready-p (e)
  "May E enter his form's :bankai-form now (P: rules BANKAI-ALLOWED-P, free with <= *BANKAI-KONPAKU* Konpaku, and the
kit's :bankai-ok: BANKAI-OK-P)? (The HUD's P BANKAI prompt, the phone's AWAKEN chip.)"
  (let ((f (fighter e)))
    (and (kit-bankai-form (fighter-kit f))
         (bankai-allowed-p (awaken-state-p e f) (drive-full-p e))
         (bankai-ok-p e))))

(defun kikon-worth (e)
  "Konpaku E's Kikon would take now: a running rush's worth (fixed at its start), else the kit's :kikon-worth hook (E) (a
worth that follows the fighter's state), else the kit's :kikon-konpaku. (The red Konpaku hint: hud.lisp AT-STAKE; a Soul Break takes this + 1: SETTLE-KONPAKU.)"
  (let* ((f (fighter e)) (mv (fighter-move f)) (h (kit-hook (kit-of e) :kikon-worth)))
    (cond ((and mv (eq (fighter-state f) :move) (eq (mv-kind mv) :kikon)) (fighter-kikon-n f))
          (h (funcall h e))
          (t (kit-kikon-konpaku (kit-of e))))))

(defun kikon-ready-p (e)
  "Is E's opponent red: would E's Kikon rush, connecting now with the button held, be the Kikon?
(The HUD's HOLD O prompt, the CPU's rush.)"
  (let ((go (gauges (opp-of e)))) (gauges-red-p go)))

(defun settle-konpaku (att def soul-break)
  "Konpaku at connect time (KIKON-RESULT): DEF loses the Kikon's count (ATT's rush's, read when it started:
FIGHTER-KIKON-N), or on a Soul Break ATT's KIKON-WORTH now + 1 (at most *SOUL-BREAK-MAX-EVENT*: KESSA's follows his
clones, 3 clones 4 + 1 = 5, the user 2026-09-30); his Reishi refills.
Then DEF's kit's :settled hook (def lost left): what his form does with the souls he has left (a beheading).
Returns T when DEF is out of Konpaku; never in a bind (BIND-OF: grey souls, the Konpaku floors at 0, no K.O.)."
  (let ((gd (gauges def)) (bound (bind-of def)))
    (multiple-value-bind (left lost ko)
        (let ((n (if soul-break (kikon-worth att) (fighter-kikon-n (fighter att)))))
          (cond ((kit-core (kit-of att))                ; the core system's counts (core.lisp): the style of the SP in play
                 (core-konpaku-result (gauges-konpaku gd) att soul-break))
                ((and *run-mods* (run-mods-on-p att))   ; DANGAI's counts: before the cap, past it
                 (run-konpaku-result (gauges-konpaku gd) n soul-break (rmod att (if soul-break :sb-plus :kikon-plus) 0)
                                     (rmod att (if soul-break :sb-past :kikon-past) 0)))
                (t (kikon-result (gauges-konpaku gd) n soul-break))))
      (when *run-mods*
        (when (or (run-mods-on-p att) (run-mods-on-p def))
          (log-msg "duel runmod konpaku side ~d ~:[kikon~;soul-break~] lost ~d left ~d" (fighter-side (fighter def)) soul-break lost left))
        (let ((r (and ko (not bound) (run-revive! def))))   ; :revive: the fight goes on
          (when r (setf left r ko nil)))
        (when (plusp lost) (run-armor-give! def :armor-on-soul-loss)))
      (setf (gauges-konpaku gd) left (gauges-reishi gd) (gauges-reishi-max gd))
      (let ((h (kit-hook (kit-of def) :settled))) (when h (funcall h def lost left)))
      (unless (siphon-of def)
        (awaken-fill! gd (awakening-gain 0 0 lost)))
      (incf (gauges-kikons (gauges att)))
      (emit :konpaku def lost)
      (clog "~a ~a on ~a: -~d konpaku, ~d left (~a)" (side-name att) (if soul-break "SOUL BREAK" "KIKON") (side-name def) lost left
            (fighter-form (fighter att)))
      (and ko (not bound)))))

(defun settle-souls ()
  "The souls broken during this step's HIT-SYSTEM, settled together so no side goes first: every
confirmed Kikon (*KIKONS*: the Kikon count) and every Reishi that reached 0 (*SOUL-BREAKS*: the
count + 1; a Kikon's victim has no Soul Break on top, the Kikon refills his Reishi). Then one
cinematic (the first Kikon's move :cine, else the first Soul Break's attacker's Kikon cinematic: KIT-KIKON-CINE),
then the reset, or the finish (a draw when both souls ran out). The hazards still out are cleared first: the reset clears them anyway,
and frozen through the cinematic their looks would hang in its shots."
  (let* ((kk (reverse *kikons*))
         (sb (and *soul-breaks*                     ; (a loop, not REMOVE-IF's closure: no consing on a quiet step)
                  (loop for s in (reverse *soul-breaks*) unless (find (cdr s) kk :key #'second) collect s))))
    (setf *kikons* nil *soul-breaks* nil)
    (when (or kk sb)
      (do-entities (e (f fighter)) (burst-end! e))   ; the reset ends every burst, before the Kikon's refund
      (dolist (att (remove-duplicates (append (mapcar #'first kk) (mapcar #'car sb))))   ; a Kikon that connected, or
        (let ((g (gauges att)))                         ; a Soul Break (the user 2026-09-30): a flash-step bar and a Reiatsu bar back
          (setf (gauges-fs g) (f32 (kikon-refund (gauges-fs g) (gauges-reiatsu g))))   ; (its Reiatsu: REIATSU-GAIN!)
          (reiatsu-gain! att *kikon-reiatsu-refund*)))
      (let ((kos (append (loop for (att def nil) in kk when (settle-konpaku att def nil) collect def)
                         (loop for (att . def) in sb when (settle-konpaku att def t) collect def)))
            (a (if kk (first (first kk)) (car (first sb))))
            (v (if kk (second (first kk)) (cdr (first sb)))))
        (loop for (att def mv) in kk
              do (when (mv-callout mv) (callout att (mv-callout mv)))
                 (emit :kikon att def))
        (loop for (att . def) in sb do (emit :soul-break att def))
        (clear-hazards)
        (cine-stage a v)                                ; (both set down mid-stage for its shots, given back at its end)
        (start-cine (if kk (or (mv-cine (third (first kk))) (core-kikon-cine a) (kit-kikon-cine (kit-of a))) (core-soul-break-cine a)) a v
                    :after (lambda () (cond ((null kos) (reset-round a v))
                                            ((rest kos) (match-over nil))
                                            (t (match-over (opp-of (first kos)))))))))))

(defun reset-round (a v)
  "After a Kikon / Soul Break (§1): both placed *RESET-DISTANCE* apart facing, *RESET-NEUTRAL* frames
of neutral, P1 on the left of the view again, hazards cleared, the guard gauges full (and guardless cleared) for
everyone, the hidden stun cleared, the forms kept, flash-step and Reiatsu kept, the kit's :reset-reiatsu (Kenpachi), the
kit's :reset hook (e) (Hisagi's sickle)."
  (let ((p (pos-of a)) (q (pos-of v)))
    (multiple-value-bind (ax az bx bz) (reset-placement (aref p 0) (aref p 2) (aref q 0) (aref q 2))
      (v3-set! p (f32 ax) 0f0 (f32 az)) (v3-set! q (f32 bx) 0f0 (f32 bz))))
  (face-each-other a v)
  (if (zerop (fighter-side (fighter a))) (view-step a v t) (view-step v a t))
  (clear-hazards)
  (dolist (e (list a v))
    (let ((f (fighter e)) (g (gauges e)) (mo (motion e)))
      (setf (motion-grounded mo) t (motion-kb-left mo) 0 (fighter-lock f) *reset-neutral* (fighter-combo-dmg f) 0)
      (reiatsu-gain! e (kit-reset-reiatsu (kit-of e)))
      (setf (gauges-gg g) (f32 (gg-cap e)) (gauges-gg-idle g) 0 (gauges-guardless g) nil (gauges-stun g) 0f0)
      (let ((rf (kit-reset-form (kit-of e))))          ; Rukia: absolute zero never carries over the reset (-18, C 0)
        (when rf (set-form e rf) (setf (gauges-meter g) 0f0 (gauges-meter-idle g) 0)))
      (fill (motion-vel mo) 0f0)
      (vpad-clear! (pilot-vpad (pilot e)))
      (let ((b (brain e))) (when b (setf (brain-press-left b) 0)))   ; a CPU lets go of what it held (a rush's O)
      (let ((h (kit-hook (kit-of e) :reset))) (when h (funcall h e)))   ; the form's own reset (Hisagi's sickle back in hand)
      (to-idle e 0)))
  (emit :reset))

;;; ---------------------------------------------------------------- gauges per step
(defun gauge-system ()
  "Regen (Reiatsu; flash-step and the guard gauge after their delays: a full guard gauge ends
guardless), timed forms (burn, drain, end), the meter's full form (Hellfire), EVOLUTION. GUARD HOLD: one
guarding test (:guard / :guard-hit, or Bankai West's ward, not guardless) gates both the guard gauge's refill and its
delay counter (frozen): West never refills."
  (do-entities (e (f fighter) (g gauges))
    (let* ((kit (fighter-kit f))
           (guarding (and (or (member (fighter-state f) '(:guard :guard-hit)) (passive-p e :ward)) (not (gauges-guardless g)))))
      (reiatsu-gain! e (rmod-x e :reiatsu-regen (reiatsu-gain 0 1)))   ; (DANGAI's :reiatsu-regen, :fs-regen, :gg-regen)
      (if (gauges-burst g)
          (burst-step e g)                               ; a burst: the gauge drains, no regen
          (setf (gauges-fs g) (f32 (fs-regen (gauges-fs g) (gauges-fs-idle g) (rmod-x e :fs-regen *fs-regen*)))
                (gauges-fs-idle g) (min 9999 (1+ (gauges-fs-idle g)))))
      (when (plusp (gauges-awake-regen g))                ; the awakening's regen (overlaps a burst)
        (decf (gauges-awake-regen g))
        (white-regen! e g (incf (gauges-awake-t g))))
      (setf (gauges-gg g) (f32 (gg-regen (gauges-gg g) (gauges-gg-idle g) (gauges-guardless g) guarding
                                         (eq (gauges-burst g) :blue) (rmod-x e :gg-regen (kit-gg-regen kit)) (gg-cap e))))
      (setf (gauges-gg-idle g) (gg-idle-next (gauges-gg-idle g) guarding))
      (setf (gauges-stun g) (f32 (stun-decay (gauges-stun g) (gauges-stun-idle g)))   ; the hidden stun's decay
            (gauges-stun-idle g) (min 9999 (1+ (gauges-stun-idle g))))
      (when (and (gauges-guardless g) (>= (gauges-gg g) (gg-cap e)))
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
      (when *run-mods* (run-mods-step! e g))            ; DANGAI's run state (windows, armour, :regen)
      (let ((m (kit-meter kit)))
        (when (and m (zerop (gauges-form-left g)) (>= (gauges-meter g) (getf m :max)) (getf m :full-form))
          (setf (gauges-meter g) 0f0)                    ; the bar now shows the form's timer
          (set-form e (getf m :full-form))
          (emit :hellfire e)))
      (when (and (not (gauges-awakened g)) (not (gauges-evolution g)) (>= (gauges-awaken g) *awaken-max*))
        (setf (gauges-evolution g) t)
        (when (minusp (gauges-evo-t g)) (setf (gauges-evo-t g) *match-tick*))
        (emit :evolution e)
        (clog "~a EVOLUTION" (side-name e))))))

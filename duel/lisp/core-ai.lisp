;;;; core-ai.lisp — the core system's CPU (docs/duel/DUEL_CORE.md §5): a generic player of the triangle for every kit with a :core.
;;;; It perceives the opponent through the same delayed SNAP ring as the old CPU (cpu-perceive.lisp BRAIN-PERCEIVE), walks to a range, starts
;;;; an NA or an NS, and its depth is the READ: when what he is doing is beaten by a turn (an NS against my NA link: AS; an NA
;;;; against my NS segment: SA), it turns with a chance by difficulty. Every chance is rolled once per event (his move's start, my
;;;; move's start), never per step. The old kit-specific tables are not read.
(in-package :duel)

(defparameter *cai-think* '(:easy 34 :normal 22 :hard 12)
  "Frames between neutral decisions per difficulty (a base; up to 12 more are added by a roll).")
(defparameter *cai-range* '(1.7 3.0) "The range (m) the core CPU walks to before it starts a move.")
(defparameter *cai-ns-near* 0.45 "Chance an in-range neutral decision is an NS rather than an NA at 1.7 m or less.")
(defparameter *cai-ns-far* 0.8 "... and beyond 1.7 m (the NS reaches further).")
(defparameter *cai-turn-p* '(:easy 0.2 :normal 0.5 :hard 0.8)
  "The read: switch to the turn move that beats what he is doing (AS against his NS, SA against his NA).")
(defparameter *cai-cont-p* '(:easy 0.55 :normal 0.7 :hard 0.85)
  "Go on: the next NA link after a hit, the next NS segment.")
(defparameter *cai-hoho-p* '(:easy 0.05 :normal 0.12 :hard 0.25) "Hoho out of an attack coming at him (one roll per attack).")
(defparameter *cai-ranged-p* 0.5 "Per decision, while walking in from a ranged NS's band (the kit's :core :ns-range): shoot it (Ichigo's Getsuga; the user, 2026-10-27).")
(defparameter *cai-ranged-gap* 80 "Steps to wait before the next decision after such a shot (a wave is not spammed).")
(defparameter *cai-awaken-p* 0.02 "Awaken, per decision, once the gauge is full.")

;;; Matchup style CPUs (DUEL_MATCHUP_AI, the user 2026-11-06): a style function for one character against one opponent runs before
;;; the generic decision on every step the CPU is free to press; it returns T when it decided this step (pressed, or chose to wait),
;;; NIL to leave the step to the generic CPU. No entry: the generic CPU as before (every other pairing).
(defparameter *cai-styles* nil "(own-character (opp-character fn ...) ...): a matchup's style function, FN (e b f kit s d) -> T if it decided.")
(defun cai-defstyle (own opp fn)
  "Register FN as OWN's style against OPP (a load-time call in the style's file)."
  (setf (getf (getf *cai-styles* own) opp) fn))
(defun cai-style-fn (f)
  "F's style function against his opponent, or NIL (no consing: plists)."
  (and *cai-styles* (getf (getf *cai-styles* (kit-character (fighter-kit f))) (kit-character (fighter-kit (fighter (fighter-opp f)))))))   ; (FIGHTER-OPP is his entity)

(defun cai-class-of (o s)
  "The triangle class of the move the perceived SNAP S shows fighter O in (:na :ns :as :sa), or NIL."
  (and (eq (snap-state s) :move) (snap-move s) (kit-class (kit-of o) (snap-move s))))

(defun cai-press (b button frames &optional modded)
  "Hold BUTTON for FRAMES steps (with :MOD when MODDED)."
  (ai-press b button frames :modded modded))

(defun cai-fz (b rules kind &rest feats)
  "RULES' chance (fuzzy.lisp) at brain B's difficulty for the cue plist FEATS (KIND :SKILL or :CHOICE), times the active strategy's scale
for it (strategy.lisp: :HOHO :TURN :CONT :KIKON)."
  (let ((p (fz-chance rules feats (brain-difficulty b) kind)))
    (if (brain-now b)
        (strat-scale (brain-now b) (cond ((eq rules *fz-hoho*) :hoho) ((or (eq rules *fz-as-now*) (eq rules *fz-ns-turn*)) :turn)
                           ((eq rules *fz-ns-cont*) :cont) ((eq rules *fz-kikon*) :kikon) (t :other))
                     p)
        p)))

(defun cai-fz-roll (b rules kind &rest feats)
  "One roll of RULES' chance (no SIM-RND01 drawn at 0 or 1, as BRAIN-ROLL)."
  (let ((p (apply #'cai-fz b rules kind feats))) (cond ((<= p 0) nil) ((>= p 1) t) (t (< (sim-rnd01) p)))))
(defun cai-bit (x) "1 when X, else 0 (a crisp fuzzy cue)." (if x 1 0))

(defun cai-own-rolls (b f)
  "The rolls of his own move: made once when it starts (its CLS-T), kept until the next one starts."
  (unless (= (brain-own-key b) (fighter-cls-t f))
    (setf (brain-own-key b) (fighter-cls-t f) (brain-r-turn b) (sim-rnd01) (brain-r-cont b) (sim-rnd01) (brain-r-kikon b) (sim-rnd01))))

(defun cai-sp (b f s &optional (frames 1) no-kikon)
  "Press SP (Mod + attack): held into a Kikon when this SP's roll says so (against a red opponent more likely), else a tap; NO-KIKON
(the SP about to start holds into none: Hisagi's Bankai AS3, :params :no-kikon) a tap, so its segments go on (CAI-MOVE-STEP)."
  (let* ((o (fighter-opp f)) (red (gauges-red-p (gauges o)))
         (want (and (not no-kikon)
                    (< (brain-r-kikon b) (cai-fz b *fz-kikon* :skill :ored (cai-bit red)
                                                 :lead (- (gauges-konpaku (gauges (fighter-opp (fighter o)))) (gauges-konpaku (gauges o))))))))
    (declare (ignorable s))
    (cai-press b :quick (if want 40 frames) t)))

(defparameter *cai-dswitch-dif* '(:easy 0.3 :normal 0.6 :hard 1.0)
  "A strategy's :DSWITCH (the chance of the DRIVE switch per NS gap, its HARD value) times this per difficulty. New 2026-11-09 (the user:
「記得將消耗 drive 量表來臨時切換 NS 的戰術也安排到策略中」, DUEL_AI_STRATEGY §8.16).")
(defparameter *cai-dswitch-slack* 0.4
  "m added to a switch target's opener reach + slide for the band rule (the reaches are centre to centre, before the victim's body).")

(defun mv-min-reach (mv &optional e)
  "MV's first window's dead zone (m, :min-reach), 0 without one; with E (the fighter who would play it) the one his kit's :min-reach hook
gives now (Hisagi's cancel unlock: 0 inside the route out of a cancel, DUEL_HISAGI §29)."
  (let* ((h (mv-hits mv)) (mn (and (plusp (length h)) (hw-min (svref h 0))))
         (hk (and mn e (kit-hook (kit-of e) :min-reach))))
    (or (if hk (funcall hk e mn) mn) 0.0)))

(defun cai-switch-press (e b f to)
  "Press SP with the stick sideways toward pointer TO: the human's own switch (CORE-MOVE-SP! -> CORE-SWITCH-TARGET, its gauge and its
rules); the act :SWITCH marks the press (CORE-BRAIN-STEP writes the stick). The CPU's gate is CAI-DSWITCH's / the strategy's own
check of CORE-SWITCH-OPEN-P; the sim's legality reads only the vpad and the gauges."
  (ai-press b :quick 1 :modded t :act :switch)
  (setf (brain-strafe b) (f32 (strat-switch-dir (fighter-ptr f) to (length (getf (kit-core (fighter-kit f)) :ns)))))
  (clog "~a cpu switch ~d -> ~d" (side-name e) (fighter-ptr f) to)
  (cai-switch-count f))

(defun cai-switch-target (e b f kit d)
  "The pointer the active strategy's switch goes to from F's (E's) NS gap at distance D (its :DSWITCH-MAP for his form and pointer, else
STRAT-SWITCH-TO's band rule), or NIL."
  (let* ((n (length (getf (kit-core kit) :ns)))
         (row (find-if (lambda (r) (and (eq (first r) (fighter-form f)) (eql (second r) (fighter-ptr f)))) (getf (car (brain-now b)) :dswitch-map))))
    (strat-switch-to (fighter-ptr f) n d
                     (loop for p from 1 to n collect (let ((mv (kit-core-move kit :ns p))) (and mv (list (mv-min-reach mv e) (+ (strat-reach mv) *cai-dswitch-slack*)))))
                     (third row))))

(defun cai-dswitch (e b f kit)
  "In an NS segment's gap (once per segment, CAI-MOVE-STEP): the active strategy's :DSWITCH, one roll when the switch is open and a target
reaches. T when it pressed. No :DSWITCH (every shipped CPU): no roll, NIL."
  (let ((p (strat-out (brain-now b) :dswitch nil)))
    (when (and p (plusp p) (core-switch-open-p e f))
      (let ((to (cai-switch-target e b f kit (fighter-dist f))))
        (when (and to (< (sim-rnd01) (* p (brain-chance b *cai-dswitch-dif*))))
          (cai-switch-press e b f to)
          t)))))

(defun cai-next-ok-p (e kit mv)
  "Would an SP pressed now in NS segment MV start the next one (DUEL_SP §3, S7)? KIT-SP-START-P, the test CORE-START! refuses by, over
E's OWN gauge read live (GAUGES-FS, the burst: his HUD shows it); only the opponent is perceived late (BRAIN-PERCEIVE's SNAP ring).
Refused (a later NS segment at 0 outside a burst): logs `cpu holds <seg>` and NIL, so the caller skips the press (asked last, after
the press's own roll). No next segment: NIL."
  (let ((nx (mv-ns-next kit mv)) (g (gauges e)))
    (cond ((null nx) nil)
          ((kit-sp-start-p kit nx (gauges-fs g) (gauges-burst g)) t)
          (t (clog "~a cpu holds ~a (fs ~,1f)" (side-name e) (mv-name nx) (gauges-fs g)) nil))))

(defun cai-hoho-hold-p (e b f kit)
  "Is brain B's pending press an SP that would resume F's Hoho'd NS route (pressed in the Hoho, or neutral in its resume window:
fighter.lisp HOHO-RESUME!, DUEL_CORE §8) into a segment the sim refuses? Asked through CAI-NEXT-OK-P (which logs `cpu holds`), so the
press is dropped as S7 drops the NS gap's (DUEL_SP S7's gap, closed by REFACTOR_2026-11 R15d, 2026-11-14). A switched-off brain's press
(written by a script: trial.lisp, the practice dummy) is left as it is."
  (let ((from (fighter-hoho-from f)))
    (and from (not (brain-off b)) (> (brain-press-left b) 0) (eq (brain-press b) :quick) (brain-press-mod b)
         (eq (fighter-hoho-cls f) :ns) (or (eq (fighter-state f) :hoho) (plusp (fighter-hoho-left f)))
         (not (cai-next-ok-p e kit from)))))

(defun cai-move-step (e b f kit s)
  "Inside his own move: continue, turn or end it (once per move)."
  (declare (ignorable e))
  (let* ((mv (fighter-move f)) (cls (fighter-cls f)) (oc (cai-class-of (fighter-opp f) s)))
    (cai-own-rolls b f)
    (when (and mv cls (/= (brain-decided b) (fighter-cls-t f)))
      (case cls
        ((:na :sa)
         (when (eq (fighter-contact f) :hit)                  ; landed (or cancelled: it counts as a hit)
           (setf (brain-decided b) (fighter-cls-t f))
           (if (and (not (fighter-as-done f))
                    (let ((len (length (getf (kit-core kit) :as-by-press '(1 2 3)))))
                      (or (>= (fighter-presses f) len)                                                  ; (the string's end)
                          (eql 3 (getf (mv-params mv) :as-ptr))                                         ; (§28.20's gathered J3)
                          (< (brain-r-cont b) (cai-fz b *fz-as-now* :choice :ons (cai-bit (eq oc :ns))   ; the fuzzy layer
                                                      :ored (cai-bit (gauges-red-p (gauges (fighter-opp f))))
                                                      :press (/ (fighter-presses f) (float len)))))))
               (cai-sp b f s 1 (let ((as (kit-core-move kit :as (core-next-as f))))
                                 (and as (getf (mv-params as) :no-kikon))))
               (cai-press b :quick 1))))
        (:ns
         (when (>= (fighter-sf f) (mv-s mv))                   ; the segment is out: now is the gap to read
           (setf (brain-decided b) (fighter-cls-t f))
           (cond ((cai-dswitch e b f kit))                                                     ; a strategy's DRIVE switch (§8.16)
                 ((and (getf (mv-params mv) :charge-sa) (mv-sa-move kit mv) (< (fighter-dist f) 2.6)   ; a charge segment (Kenpachi's kamae): cash it in
                       (or (null (mv-ns-next kit mv)) (< (brain-r-turn b) 0.5)))                       ; at the last one, else half the time
                  (cai-press b :quick 1))
                 ((and (kit-sa-move kit)                                                   ; the read, or a segment's own SA in reach
                       (< (brain-r-turn b) (cai-fz b *fz-ns-turn* :skill :ona (cai-bit (eq oc :na)) :d (fighter-dist f)
                                                   :ownsa (cai-bit (mv-sa-move kit mv)))))
                  (cai-press b :quick 1))
                 ((and (mv-ns-next kit mv)
                       (< (brain-r-cont b) (cai-fz b *fz-ns-cont* :choice :hit (cai-bit (fighter-contact f)) :d (fighter-dist f)))
                       (cai-next-ok-p e kit mv))                       ; (refused at 0: no press, the route ends here, S7)
                  (cai-press b :quick 1 t)))))
        (:as                                                   ; the AS's next segment (AS n has n), unless he holds for the Kikon
         (when (and (>= (fighter-sf f) (mv-s mv)) (mv-ns-next kit mv))
           (setf (brain-decided b) (fighter-cls-t f))
           (when (and (not (vpad-down (pilot-vpad (pilot e)) :quick))
                      (< (brain-r-cont b) (cai-fz b *fz-ns-cont* :choice :hit (cai-bit (fighter-contact f)) :d (fighter-dist f))))
             (cai-press b :quick 1 t))))))))

;;; ---------------------------------------------------------------- the exchange after a cancel, the clash (DUEL_AI_STRATEGY §11.18)
;;; One place for every CPU (CORE-BRAIN-STEP runs these before a strategy's style, the MCTS and the generic CPU): the cancel's answers
;;; and the neutral throw that seeks a cancel. The choices are xch-ai.lisp's (pure), the knobs tuning.lisp's.
(defun cai-xch-new (b f)
  "His move in play just took part in a cancel (XCH-SIDE; keyed by the exchange's tick and the move's start, so an SA the cancel fired,
stamped with its tick, is not taken for a new one): the event's rolls, once, and a press still held (an SP's Kikon hold) let go: the
cancelled move holds into no Kikon. The J side's answer is picked in CAI-XCH-STEP (it reads the distance and the Hoho's readiness)."
  (when (and (eq (fighter-state f) :move) (not (and (= (brain-xmove b) (fighter-cls-t f)) (= (brain-xkey b) (fighter-xch f))))
             (xch-side (fighter-cls f) (fighter-contact f) (fighter-xch f) (fighter-cls-t f)))
    (setf (brain-xkey b) (fighter-xch f) (brain-xmove b) (fighter-cls-t f) (brain-xdone b) nil (brain-xpick b) :roll
          (brain-press-left b) 0)))

(defun cai-xch-step (e b f kit s d)
  "Play the cancel his move in play took part in (CAI-XCH-NEW): T while it owns the step, so no style, MCTS or generic move step presses
under it (a real hit's route stays theirs). J side: one roll picks the AS, the next J or a Hoho out (*CAI-XCH-J*, XCH-J-ANSWER: the AS and
J only while the AS reaches him, the Hoho only when ready; none: he holds), pressed once his cancel windows are open. NS side: rolled once
(*CAI-XCH-NS-HOHO-P*, *CAI-XCH-SA-P*, *CAI-XCH-CARRY-P*): when the segment's own hit was the cancel's (his J was in its startup and will
land on her recovery), a Hoho out (its perfect Hoho over his J or AS counters); watching, a J on the step his AS or new J link is seen to start, or at once while his J is still
coming when the segment's own hit was the cancel's (XCH-TURN-SEEN-P: the perceived SNAP, never his true state), starts the SA; nothing seen
by the segment's active end, the next segment or the route's end."
  (let ((mv (fighter-move f)))
    (when (and mv (eq (fighter-state f) :move) (= (brain-xmove b) (fighter-cls-t f)) (= (brain-xkey b) (fighter-xch f)))
      (when (eq (brain-xpick b) :roll)                       ; (the event's rolls, made on its first step)
        (if (eq (fighter-cls f) :ns)
            (setf (brain-xpick b) (cond ((and (plusp (fighter-hits f)) (hoho-ready-p e) (brain-roll b *cai-xch-ns-hoho-p*)) :hoho)
                                        ((brain-roll b *cai-xch-sa-p*) :watch))
                  (brain-xcarry b) (brain-roll b *cai-xch-carry-p*))
            (let ((as (kit-core-move kit :as (core-next-as f))))
              (setf (brain-xpick b) (xch-j-answer (sim-rnd01) (brain-chance b *cai-xch-j*)
                                                  (and as (not (fighter-as-done f)) (<= d (+ (strat-reach as) *cai-clash-margin*)))
                                                  (hoho-ready-p e))))))
      (unless (brain-xdone b)
        (if (eq (fighter-cls f) :ns)
            (cond ((eq (brain-xpick b) :hoho)                                   ; (her own hit was the cancel's: out, his J still coming)
                   (when (cancel-open-p (fighter-sf f) (fighter-land-sf f) (mv-total mv) t)
                     (setf (brain-xdone b) t)
                     (clog "~a cpu xch NS hoho at ~,1f" (side-name e) d)
                     (ai-press b :step 1 :modded t :act :hoho)))
                  ((and (eq (brain-xpick b) :watch) (xch-turn-seen-p (cai-class-of (fighter-opp f) s) (snap-start s) (fighter-xch f) (plusp (fighter-hits f))))
                   (setf (brain-xdone b) t)
                   (clog "~a cpu xch SA on his ~(~a~)" (side-name e) (cai-class-of (fighter-opp f) s))
                   (cai-press b :quick 1))
                  ((and (brain-xcarry b) (>= (fighter-sf f) (+ (mv-s mv) (mv-a mv) -1)))   ; (his turn may still come: the watch goes on)
                   (setf (brain-xcarry b) nil)
                   (when (and (mv-ns-next kit mv) (cai-next-ok-p e kit mv)) (cai-press b :quick 1 t))))
            (when (or (null (brain-xpick b)) (cancel-open-p (fighter-sf f) (fighter-land-sf f) (mv-total mv) t))
              (setf (brain-xdone b) t)
              (clog "~a cpu xch ~(~a~) at ~,1f" (side-name e) (or (brain-xpick b) :hold) d)
              (case (brain-xpick b)
                (:as (let ((as (kit-core-move kit :as (core-next-as f)))) (cai-sp b f s 1 (and as (getf (mv-params as) :no-kikon)))))
                (:j (cai-press b :quick 1))
                (:hoho (ai-press b :step 1 :modded t :act :hoho))))))
      t)))

(defun cai-clash (e b f kit s d)
  "積極相消 (*CAI-CLASH-P*): free, he is seen in a classed melee move (hits, no parry) still live after the CPU's delay and within his reach
+ *CAI-CLASH-MARGIN*: one roll per such move of his (BRAIN-CLASH-KEY), and the CPU throws CLASH-OPENER's move into it (a J into his NS / AS,
its pointer's NS into his NA / SA): whichever hit lands first, a cancel. A plan the MCTS made a reaction ago is dropped. T when it pressed."
  (let* ((mv (snap-move s)) (to (clash-opener (cai-class-of (fighter-opp f) s))))
    (when (and to mv (/= (brain-clash-key b) (snap-start s)) (plusp (length (mv-hits mv))) (plusp (snap-reach s))
               (not (member :parry (snap-flags s))) (>= (- (snap-active-end s) (snap-sf s) (brain-delay b)) 1)
               (snap-near-p s e d *cai-clash-margin*) (or (eq to :na) (kit-core-move kit :ns (fighter-ptr f))))
      (setf (brain-clash-key b) (snap-start s))
      (when (brain-roll b *cai-clash-p*)
        (mc-plan-drop f)
        (clog "~a cpu clash ~(~a~) into his ~(~a~) at ~,1f" (side-name e) to (cai-class-of (fighter-opp f) s) d)
        (setf (brain-own-key b) -1 (brain-r-kikon b) 1f0)        ; (its own rolls made afresh; no Kikon hold on a clash)
        (if (eq to :na) (cai-press b :quick 1) (cai-sp b f s))
        t))))

(defun cai-neutral (e b f kit s d)
  "Free: Hoho out of an attack at him, else walk to the range and now and then start a move."
  (let* ((vp (pilot-vpad (pilot e)))
         (nr (nth (1- (max 1 (min *core-pointer-max* (fighter-ptr f)))) (getf (kit-core kit) :ns-range)))   ; (near far) m of a ranged NS under this pointer (Ichigo's Getsuga)
         (rg (getf (kit-core kit) :range *cai-range*)) (sc (strat-out (brain-now b) :range nil))   ; (a strategy's range scale)
         (lo (if sc (* sc (first rg)) (first rg))) (hi (if sc (* sc (second rg)) (second rg))))
    (when (<= (decf (brain-strafe-t b)) 0) (ai-strafe e b))
    (cond ((and (eq (snap-state s) :move) (plusp (snap-left s)) (< d (+ (snap-reach s) 1.0)) (hoho-ready-p e)
                (< (brain-hoho-roll b) (cai-fz b *fz-hoho* :skill :margin (- d (snap-reach s)) :frames (max 0 (- (snap-s s) (snap-sf s))))))
           (setf (brain-hoho-roll b) 1f0)
           (ai-press b :step 1 :modded t :act :hoho))
          (t (when (> d 7.0) (setf (brain-decide-t b) (min (brain-decide-t b) 1)))
             (ai-walk e b vp d lo hi)
             (when (<= (decf (brain-decide-t b)) 0)
               (setf (brain-decide-t b) (+ (getf *cai-think* (brain-difficulty b) 22) (floor (* 12 (sim-rnd01)))))
               (cond ((> d 7.0) (ai-dash b 1 4.5))
                     ((and (gauges-awakened-ok-p e) (< (sim-rnd01) (strat-scale (brain-now b) :awaken *cai-awaken-p*))) (ai-press b :awaken 1 :modded t))
                     ((and nr (> d (+ hi 0.6)) (<= (first nr) d (second nr)) (< (sim-rnd01) *cai-ranged-p*))   ; a shot from where he would walk in
                      (setf (brain-own-key b) -1 (brain-r-kikon b) 1f0 (brain-decide-t b) *cai-ranged-gap*)
                      (cai-sp b f s))
                     ((<= d (+ hi 0.6))
                      (setf (brain-own-key b) -1)
                      (let ((roll (sim-rnd01)) (ns (kit-core-move kit :ns (fighter-ptr f))))
                        (if (and ns (< roll (strat-out (brain-now b) :ns (if (> d 1.7) *cai-ns-far* *cai-ns-near*))))
                            (progn (setf (brain-r-kikon b) (sim-rnd01)) (cai-sp b f s))
                            (cai-press b :quick 1))))))))))

(defun gauges-awakened-ok-p (e)
  "May E awaken now (the awakening gauge full, not yet awakened, free; a CPU's strategy may hold it, STRAT-HOLD-AWAKEN-P)?"
  (let ((g (gauges e)) (f (fighter e)))
    (and (not (getf (kit-core (fighter-kit f)) :no-awaken)) (not (gauges-awakened g)) (>= (gauges-awaken g) *awaken-max*) (member (fighter-state f) '(:idle :run))
         (not (strat-hold-awaken-p e)))))

(defvar *cai-switch-counts* (make-array 6 :element-type 'fixnum :initial-element 0)
  "A tool's counters (not sim state, never read in play; outside rollouts only): the CPU's DRIVE switches per side (3 each) by its form
index (STRAT-FORM-INDEX: Shikai, ranged mode, bind mode). Reset and printed by tools/simgate/strat-run.lisp STRAT_HRANGE (DUEL_AI_STRATEGY §8.19).")
(defun cai-switch-count (f)
  (unless *in-rollout* (incf (aref *cai-switch-counts* (+ (strat-form-index f) (* 3 (fighter-side f)))))))

(defun core-brain-step (e b)
  "One step of the core CPU: perceive, then hold the press in progress, or decide for the state he is in."
  (let* ((f (fighter e)) (vp (pilot-vpad (pilot e))) (o (fighter-opp f)) (kit (fighter-kit f)))
    (vpad-begin-step! vp)
    (multiple-value-bind (s d) (brain-perceive e b o)
     (when *strat-layer* (strat-layer-step e b f s d))                    ; (the strategy layer's selection, strategy-glue.lisp)
     (let* ((sw (let ((st (brain-strat b))) (and st (or (getf st :switch) (getf st :fq)) st)))   ; (a composite: its active sub, else the lookup's strategy; a Q selector: its arm)
            (cur (if sw
                     (or (strat-switch-step e b f s d sw)
                         (and (not (getf sw :fq))     ; (a Q selector's NIL arm = no strategy at all, its style CPU included: never the lookup, which may be the table itself, DUEL_AI_STRATEGY §8.18)
                              (strat-lookup (fighter-character f) (fighter-character (fighter o)) (brain-difficulty b))))
                     (brain-strat b)))
            (ev (and sw (getf sw :fq) (strat-event-step b s sw)))       ; (the event layer: its arm over the table's pick)
            (now (let ((st (or ev cur))) (and st (cons st (strat-feats e f s d))))))   ; (its strategy, DUEL_AI_STRATEGY)
      (setf (brain-now b) now)                                             ; (read by STRAT-OUT's callers this step; NIL again below)
      (vpad-stick! vp 0f0 0f0)
      (ai-event-rolls b s)
      (if (and (member (fighter-state f) '(:stun :air)) (>= (fighter-combo-hits f) *burst-min-hits*))
          (incf (brain-burst-t b))
          (setf (brain-burst-t b) 0 (brain-burst-rolled b) nil))
      (when (and (eq (brain-act b) :dash) (> (brain-press-left b) 0)
                 (if (> (brain-dash b) 0) (<= d (brain-dash-to b)) (>= d (brain-dash-to b))))
        (setf (brain-press-left b) 0 (brain-decide-t b) 1))
      (when (and (eq (fighter-state f) :move) (eq (fighter-phase f) :follow) (eq (brain-press b) :quick) (plusp (brain-press-left b)))   ; held at the hit: on
        (setf (brain-press-left b) (max (brain-press-left b) (- (1+ *core-kikon-confirm*) (fighter-hold f)))))   ; through the confirm
      (unless (or (brain-off b) (> (fighter-lock f) 0) (eq (fighter-state f) :cine))
        (cai-xch-new b f)                                                  ; (a cancel his move just took part in: its key, §11.18)
        (cond ((> (brain-press-left b) 0) (decf (brain-press-left b)))
              ((cai-xch-step e b f kit s d))                                   ; the exchange after a cancel: every CPU's one answer (§11.18)
              ((and (member (fighter-state f) '(:idle :run)) (cai-clash e b f kit s d)))   ; 積極相消: a classed move into his (§11.18)
              ((let ((fn (and now (getf (car now) :fn))))      ; a strategy's own tactics first (DUEL_AI_STRATEGY §9)
                 (and fn (if ev (strat-event-call fn e b f kit s d) (funcall fn e b f kit s d)))))
              ((mc-neutral e b f kit s d))                                     ; free: the in-game MCTS (cpu-mcts.lisp, DUEL_AI_TEACHER §9)
              ((let ((st (and (not (strat-layer-p f)) (not cur) (not ev) (cai-style-fn f)))) (and st (funcall st e b f kit s d))))   ; a matchup style decided (DUEL_MATCHUP_AI; under the strategy layer only as its strategy; not while a strategy is active: a composite's sub, the lookup's)
              (t (case (fighter-state f)
                   ((:idle :run) (cai-neutral e b f kit s d))
                   (:move (cai-move-step e b f kit s))
                   (:stun
                    (cond ((and (= (fighter-kikon-lock f) 1) (= (fighter-sf f) 1)
                                (< (brain-guard-roll b) (cai-fz b *fz-cancel* :skill :red (cai-bit (gauges-red-p (gauges e))))))
                           (cai-press b :quick 1))
                          ((and (zerop (fighter-kikon-lock f)) (>= (brain-burst-t b) (brain-delay b)) (not (brain-burst-rolled b)))
                           (setf (brain-burst-rolled b) t)
                           (when (and (cai-fz-roll b *fz-burst* :skill :hits (fighter-combo-hits f) :red (cai-bit (gauges-red-p (gauges e)))) (burst-ok-p e))
                             (cai-press b :awaken 1)))))
                   (:air
                    (when (and (zerop (fighter-kikon-lock f)) (>= (brain-burst-t b) (brain-delay b)) (not (brain-burst-rolled b)))
                      (setf (brain-burst-rolled b) t)
                      (when (and (cai-fz-roll b *fz-burst* :skill :hits (fighter-combo-hits f) :red (cai-bit (gauges-red-p (gauges e)))) (burst-ok-p e))
                             (cai-press b :awaken 1))))))))
      (setf (brain-now b) nil)))                                         ; (its step is over: a step-end snapshot holds NIL, as the special did)
    (setf (brain-was b) (fighter-state f))
    (when (cai-hoho-hold-p e b f kit) (setf (brain-press-left b) 0))   ; (an SP the Hoho's resume would have refused: dropped, R15d)
    (loop for a across *vpad-actions*
          do (vpad-set! vp a (or (and (> (brain-press-left b) 0) (eq a (brain-press b)))
                                 (and (eq a :mod) (> (brain-press-left b) 0) (brain-press-mod b)))))
    (when (> (brain-press-left b) 0)
      (case (brain-act b)
        ((:side-step :switch) (vpad-stick! vp (brain-strafe b) 0f0))   ; (:switch: a strategy's DRIVE switch, CAI-SWITCH-PRESS)
        (:dash (vpad-stick! vp 0f0 (brain-dash b)))))))

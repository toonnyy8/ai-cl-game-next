;;;; core-ai.lisp — the core system's CPU (docs/duel/DUEL_CORE.md §5): a generic player of the triangle for every kit with a :core.
;;;; It perceives the opponent through the same delayed SNAP ring as the old CPU (ai.lisp BRAIN-PERCEIVE), walks to a range, starts
;;;; an NA or an NS, and its depth is the READ: when what he is doing is beaten by a turn (an NS against my NA link: AS; an NA
;;;; against my NS segment: SA), it turns with a chance by difficulty. Every chance is rolled once per event (his move's start, my
;;;; move's start), never per step. The old kit-specific tables are not read. The learner, ASSIST and the rest are frozen.
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
    (if *strat-now*
        (strat-scale (cond ((eq rules *fz-hoho*) :hoho) ((or (eq rules *fz-as-now*) (eq rules *fz-ns-turn*)) :turn)
                           ((eq rules *fz-ns-cont*) :cont) ((eq rules *fz-kikon*) :kikon) (t :other))
                     p)
        p)))

(defun strat-reach (mv) "MV's reach plus its forward slide (m), 1 when there is no move." (if mv (+ (mv-reach mv) (max 0.0 (mv-slide mv))) 1.0))

(defun strat-feats (e f s d)
  "The strategies' cues for E (fighter F) seeing SNAP S at distance D (DUEL_AI_STRATEGY §2): relative to the kits, so a strategy runs
for anyone."
  (let* ((kit (fighter-kit f)) (o (fighter-opp f)) (okit (fighter-kit (fighter o))) (g (gauges e)) (go (gauges o))
         (rj (strat-reach (kit-command-move kit :q e))) (rn (strat-reach (kit-core-move kit :ns (mc-ptr f))))
         (ro (strat-reach (kit-command-move okit :q o))))
    (list :dj (/ d (max 0.5 rj)) :dn (/ d (max 0.5 rn)) :do (/ d (max 0.5 ro))
          :lead (- (gauges-konpaku g) (gauges-konpaku go))
          :mr (/ (gauges-reishi g) (float (gauges-reishi-max g))) :or (/ (gauges-reishi go) (float (gauges-reishi-max go)))
          :ored (cai-bit (gauges-red-p go)) :hoho (cai-bit (hoho-open-p e))
          :ost (case (snap-state s) ((:idle :run :guard) 0) (:move (if (and (snap-move s) (< (snap-sf s) (snap-s s))) 1 2)) ((:step :hoho) 3) (t 4))
          :wave (cai-bit (nth (1- (mc-ptr f)) (getf (kit-core kit) :ns-range))) :awk (cai-bit (gauges-awakened g)))))
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
           (cond ((and (getf (mv-params mv) :charge-sa) (mv-sa-move kit mv) (< (fighter-dist f) 2.6)   ; a charge segment (Kenpachi's kamae): cash it in
                       (or (null (mv-ns-next kit mv)) (< (brain-r-turn b) 0.5)))                       ; at the last one, else half the time
                  (cai-press b :quick 1))
                 ((and (kit-sa-move kit)                                                   ; the read, or a segment's own SA in reach
                       (< (brain-r-turn b) (cai-fz b *fz-ns-turn* :skill :ona (cai-bit (eq oc :na)) :d (fighter-dist f)
                                                   :ownsa (cai-bit (mv-sa-move kit mv)))))
                  (cai-press b :quick 1))
                 ((and (mv-ns-next kit mv)
                       (< (brain-r-cont b) (cai-fz b *fz-ns-cont* :choice :hit (cai-bit (fighter-contact f)) :d (fighter-dist f))))
                  (cai-press b :quick 1 t)))))
        (:as                                                   ; the AS's next segment (AS n has n), unless he holds for the Kikon
         (when (and (>= (fighter-sf f) (mv-s mv)) (mv-ns-next kit mv))
           (setf (brain-decided b) (fighter-cls-t f))
           (when (and (not (vpad-down (pilot-vpad (pilot e)) :quick))
                      (< (brain-r-cont b) (cai-fz b *fz-ns-cont* :choice :hit (cai-bit (fighter-contact f)) :d (fighter-dist f))))
             (cai-press b :quick 1 t))))))))

(defun cai-neutral (e b f kit s d)
  "Free: Hoho out of an attack at him, else walk to the range and now and then start a move."
  (let* ((vp (pilot-vpad (pilot e)))
         (nr (nth (1- (max 1 (min *core-pointer-max* (fighter-ptr f)))) (getf (kit-core kit) :ns-range)))   ; (near far) m of a ranged NS under this pointer (Ichigo's Getsuga)
         (rg (getf (kit-core kit) :range *cai-range*)) (sc (strat-out :range nil))   ; (a strategy's range scale)
         (lo (if sc (* sc (first rg)) (first rg))) (hi (if sc (* sc (second rg)) (second rg))))
    (when (<= (decf (brain-strafe-t b)) 0) (funcall (ai-step e :strafe) e b))
    (cond ((and (eq (snap-state s) :move) (plusp (snap-left s)) (< d (+ (snap-reach s) 1.0)) (hoho-open-p e)
                (< (brain-hoho-roll b) (cai-fz b *fz-hoho* :skill :margin (- d (snap-reach s)) :frames (max 0 (- (snap-s s) (snap-sf s))))))
           (setf (brain-hoho-roll b) 1f0)
           (ai-press b :step 1 :modded t :act :hoho))
          (t (when (> d 7.0) (setf (brain-decide-t b) (min (brain-decide-t b) 1)))
             (funcall (ai-step e :walk) e b vp d lo hi)
             (when (<= (decf (brain-decide-t b)) 0)
               (setf (brain-decide-t b) (+ (getf *cai-think* (brain-difficulty b) 22) (floor (* 12 (sim-rnd01)))))
               (cond ((> d 7.0) (ai-dash b 1 4.5))
                     ((and (gauges-awakened-ok-p e) (< (sim-rnd01) (strat-scale :awaken *cai-awaken-p*))) (ai-press b :awaken 1 :modded t))
                     ((and nr (> d (+ hi 0.6)) (<= (first nr) d (second nr)) (< (sim-rnd01) *cai-ranged-p*))   ; a shot from where he would walk in
                      (setf (brain-own-key b) -1 (brain-r-kikon b) 1f0 (brain-decide-t b) *cai-ranged-gap*)
                      (cai-sp b f s))
                     ((<= d (+ hi 0.6))
                      (setf (brain-own-key b) -1)
                      (let ((roll (sim-rnd01)) (ns (kit-core-move kit :ns (fighter-ptr f))))
                        (if (and ns (< roll (strat-out :ns (if (> d 1.7) *cai-ns-far* *cai-ns-near*))))
                            (progn (setf (brain-r-kikon b) (sim-rnd01)) (cai-sp b f s))
                            (cai-press b :quick 1))))))))))

(defun gauges-awakened-ok-p (e)
  "May E awaken now (the awakening gauge full, not yet awakened, free)?"
  (let ((g (gauges e)) (f (fighter e)))
    (and (not (getf (kit-core (fighter-kit f)) :no-awaken)) (not (gauges-awakened g)) (>= (gauges-awaken g) *awaken-max*) (member (fighter-state f) '(:idle :run)))))

(defvar *in-rollout*)                                    ; (cpu-mcts.lisp gives it its value)
(defun strat-switch-step (e b f s d sw)
  "The active sub-strategy of the composite SW (strategy.lisp) for brain B: judged on the match's first step and every *STRAT-SWITCH-PERIOD*
steps in neutral, else held (no random draw). Outside rollouts it counts the judgements and each entry's wins (BRAIN-SW-N / -WON)."
  (when (or (< (brain-sw-t b) 0)
            (and (member (fighter-state f) '(:idle :run)) (>= (- *match-tick* (brain-sw-t b)) *strat-switch-period*)))
    (setf (brain-sw-t b) *match-tick*)
    (multiple-value-bind (sub i) (strat-judge sw (strat-feats e f s d))
      (let* ((x (if sub (getf sub :fn) (cai-style-fn f))) (fn (if (and x (symbolp x)) (symbol-function x) x)))
        (when (and fn (not (eq fn (brain-sw-fn b))))      ; (another style function takes over: its own state, not the last one's struct)
          (when (brain-sw-fn b) (setf (brain-style b) nil))
          (setf (brain-sw-fn b) fn)))
      (setf (brain-sw-sub b) sub)
      (unless *in-rollout*
        (let ((won (or (brain-sw-won b) (setf (brain-sw-won b) (make-array 8 :initial-element 0)))))
          (incf (brain-sw-n b))
          (when (>= i 0) (incf (svref won i)))))))
  (brain-sw-sub b))

(defun core-brain-step (e b)
  "One step of the core CPU: perceive, then hold the press in progress, or decide for the state he is in."
  (let* ((f (fighter e)) (vp (pilot-vpad (pilot e))) (o (fighter-opp f)) (kit (fighter-kit f)))
    (vpad-begin-step! vp)
    (multiple-value-bind (s d) (brain-perceive e b o)
     (when *strat-layer* (strat-layer-step e b f s d))                    ; (the strategy layer's selection, cpu-mcts.lisp)
     (let* ((sw (let ((st (brain-strat b))) (and st (getf st :switch) st)))     ; (a composite: its active sub, else the lookup's strategy)
            (cur (if sw
                     (or (strat-switch-step e b f s d sw)
                         (strat-lookup (fighter-character f) (fighter-character (fighter o)) (brain-difficulty b)))
                     (brain-strat b)))
            (*strat-now* (and cur (cons cur (strat-feats e f s d)))))   ; (its strategy, DUEL_AI_STRATEGY)
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
        (cond ((> (brain-press-left b) 0) (decf (brain-press-left b)))
              ((let ((fn (and *strat-now* (getf (car *strat-now*) :fn))))      ; a strategy's own tactics first (DUEL_AI_STRATEGY §9)
                 (and fn (funcall fn e b f kit s d))))
              ((mc-neutral e b f kit s d))                                     ; free: the in-game MCTS (cpu-mcts.lisp, DUEL_AI_TEACHER §9)
              ((let ((st (and (not (strat-layer-p f)) (not (brain-sw-sub b)) (cai-style-fn f)))) (and st (funcall st e b f kit s d))))   ; a matchup style decided (DUEL_MATCHUP_AI; under the strategy layer only as its strategy; not while a composite's sub is active)
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
                             (cai-press b :awaken 1))))))))))
    (setf (brain-was b) (fighter-state f))
    (loop for a across *vpad-actions*
          do (vpad-set! vp a (or (and (> (brain-press-left b) 0) (eq a (brain-press b)))
                                 (and (eq a :mod) (> (brain-press-left b) 0) (brain-press-mod b)))))
    (when (> (brain-press-left b) 0)
      (case (brain-act b)
        (:side-step (vpad-stick! vp (brain-strafe b) 0f0))
        (:dash (vpad-stick! vp 0f0 (brain-dash b)))))))

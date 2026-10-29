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
(defparameter *cai-cancel-p* '(:easy 0.35 :normal 0.7 :hard 0.95) "An attack to cancel the Kikon follow-up (one roll).")
(defparameter *cai-kikon-p* '(:easy 0.1 :normal 0.2 :hard 0.35) "Hold the SP into a Kikon (one roll per SP).")
(defparameter *cai-ranged-p* 0.5 "Per decision, while walking in from a ranged NS's band (the kit's :core :ns-range): shoot it (Ichigo's Getsuga; the user, 2026-10-27).")
(defparameter *cai-ranged-gap* 80 "Steps to wait before the next decision after such a shot (a wave is not spammed).")
(defparameter *cai-awaken-p* 0.02 "Awaken, per decision, once the gauge is full.")

(defun cai-class-of (o s)
  "The triangle class of the move the perceived SNAP S shows fighter O in (:na :ns :as :sa), or NIL."
  (and (eq (snap-state s) :move) (snap-move s) (kit-class (kit-of o) (snap-move s))))

(defun cai-press (b button frames &optional modded)
  "Hold BUTTON for FRAMES steps (with :MOD when MODDED)."
  (ai-press b button frames :modded modded))

(defun cai-own-rolls (b f)
  "The rolls of his own move: made once when it starts (its CLS-T), kept until the next one starts."
  (unless (= (brain-own-key b) (fighter-cls-t f))
    (setf (brain-own-key b) (fighter-cls-t f) (brain-r-turn b) (sim-rnd01) (brain-r-cont b) (sim-rnd01) (brain-r-kikon b) (sim-rnd01))))

(defun cai-sp (b f s &optional (frames 1) no-kikon)
  "Press SP (Mod + attack): held into a Kikon when this SP's roll says so (against a red opponent more likely), else a tap; NO-KIKON
(the SP about to start holds into none: Hisagi's Bankai AS3, :params :no-kikon) a tap, so its segments go on (CAI-MOVE-STEP)."
  (let* ((o (fighter-opp f)) (red (gauges-red-p (gauges o)))
         (want (and (not no-kikon)
                    (< (brain-r-kikon b) (if red (max 0.6 (brain-chance b *cai-kikon-p*)) (brain-chance b *cai-kikon-p*))))))
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
                    (or (eq oc :ns) (>= (fighter-presses f) (length (getf (kit-core kit) :as-by-press '(1 2 3))))   ; (the string's end)
                        (eql 3 (getf (mv-params mv) :as-ptr))                                              ; (§28.20's gathered J3)
                        (>= (brain-r-cont b) (brain-chance b *cai-cont-p*))))
               (cai-sp b f s 1 (let ((as (kit-core-move kit :as (core-next-as f))))
                                 (and as (getf (mv-params as) :no-kikon))))
               (cai-press b :quick 1))))
        (:ns
         (when (>= (fighter-sf f) (mv-s mv))                   ; the segment is out: now is the gap to read
           (setf (brain-decided b) (fighter-cls-t f))
           (cond ((and (kit-sa-move kit) (< (brain-r-turn b) (brain-chance b *cai-turn-p*))
                       (or (eq oc :na) (and (mv-sa-move kit mv) (< (fighter-dist f) 2.6))))   ; the read, or a segment's own SA in reach
                  (cai-press b :quick 1))
                 ((and (mv-ns-next kit mv) (< (brain-r-cont b) (brain-chance b *cai-cont-p*))) (cai-press b :quick 1 t)))))
        (:as                                                   ; the AS's next segment (AS n has n), unless he holds for the Kikon
         (when (and (>= (fighter-sf f) (mv-s mv)) (mv-ns-next kit mv))
           (setf (brain-decided b) (fighter-cls-t f))
           (when (and (not (vpad-down (pilot-vpad (pilot e)) :quick)) (< (brain-r-cont b) (brain-chance b *cai-cont-p*)))
             (cai-press b :quick 1 t))))))))

(defun cai-neutral (e b f kit s d)
  "Free: Hoho out of an attack at him, else walk to the range and now and then start a move."
  (let* ((vp (pilot-vpad (pilot e)))
         (nr (nth (1- (max 1 (min 3 (fighter-ptr f)))) (getf (kit-core kit) :ns-range)))   ; (near far) m of a ranged NS under this pointer (Ichigo's Getsuga)
         (rg (getf (kit-core kit) :range *cai-range*)) (lo (first rg)) (hi (second rg)))
    (when (<= (decf (brain-strafe-t b)) 0) (funcall (ai-step e :strafe) e b))
    (cond ((and (eq (snap-state s) :move) (plusp (snap-left s)) (< d (+ (snap-reach s) 1.0)) (hoho-open-p e)
                (< (brain-hoho-roll b) (brain-chance b *cai-hoho-p*)))
           (setf (brain-hoho-roll b) 1f0)
           (ai-press b :step 1 :modded t :act :hoho))
          (t (when (> d 7.0) (setf (brain-decide-t b) (min (brain-decide-t b) 1)))
             (funcall (ai-step e :walk) e b vp d lo hi)
             (when (<= (decf (brain-decide-t b)) 0)
               (setf (brain-decide-t b) (+ (getf *cai-think* (brain-difficulty b) 22) (floor (* 12 (sim-rnd01)))))
               (cond ((> d 7.0) (ai-dash b 1 4.5))
                     ((and (gauges-awakened-ok-p e) (< (sim-rnd01) *cai-awaken-p*)) (ai-press b :awaken 1 :modded t))
                     ((and nr (> d (+ hi 0.6)) (<= (first nr) d (second nr)) (< (sim-rnd01) *cai-ranged-p*))   ; a shot from where he would walk in
                      (setf (brain-own-key b) -1 (brain-r-kikon b) 1f0 (brain-decide-t b) *cai-ranged-gap*)
                      (cai-sp b f s))
                     ((<= d (+ hi 0.6))
                      (setf (brain-own-key b) -1)
                      (let ((roll (sim-rnd01)) (ns (kit-core-move kit :ns (fighter-ptr f))))
                        (if (and ns (< roll (if (> d 1.7) *cai-ns-far* *cai-ns-near*)))
                            (progn (setf (brain-r-kikon b) (sim-rnd01)) (cai-sp b f s))
                            (cai-press b :quick 1))))))))))

(defun gauges-awakened-ok-p (e)
  "May E awaken now (the awakening gauge full, not yet awakened, free)?"
  (let ((g (gauges e)) (f (fighter e)))
    (and (not (getf (kit-core (fighter-kit f)) :no-awaken)) (not (gauges-awakened g)) (>= (gauges-awaken g) *awaken-max*) (member (fighter-state f) '(:idle :run)))))

(defun core-brain-step (e b)
  "One step of the core CPU: perceive, then hold the press in progress, or decide for the state he is in."
  (let* ((f (fighter e)) (vp (pilot-vpad (pilot e))) (o (fighter-opp f)) (kit (fighter-kit f)))
    (vpad-begin-step! vp)
    (multiple-value-bind (s d) (brain-perceive e b o)
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
              (t (case (fighter-state f)
                   ((:idle :run) (cai-neutral e b f kit s d))
                   (:move (cai-move-step e b f kit s))
                   (:stun
                    (cond ((and (= (fighter-kikon-lock f) 1) (= (fighter-sf f) 1) (< (brain-guard-roll b) (brain-chance b *cai-cancel-p*)))
                           (cai-press b :quick 1))
                          ((and (zerop (fighter-kikon-lock f)) (>= (brain-burst-t b) (brain-delay b)) (not (brain-burst-rolled b)))
                           (setf (brain-burst-rolled b) t)
                           (when (and (brain-roll b *ai-burst-p*) (burst-ok-p e)) (cai-press b :awaken 1)))))
                   (:air
                    (when (and (zerop (fighter-kikon-lock f)) (>= (brain-burst-t b) (brain-delay b)) (not (brain-burst-rolled b)))
                      (setf (brain-burst-rolled b) t)
                      (when (and (brain-roll b *ai-burst-p*) (burst-ok-p e)) (cai-press b :awaken 1)))))))))
    (setf (brain-was b) (fighter-state f))
    (loop for a across *vpad-actions*
          do (vpad-set! vp a (or (and (> (brain-press-left b) 0) (eq a (brain-press b)))
                                 (and (eq a :mod) (> (brain-press-left b) 0) (brain-press-mod b)))))
    (when (> (brain-press-left b) 0)
      (case (brain-act b)
        (:side-step (vpad-stick! vp (brain-strafe b) 0f0))
        (:dash (vpad-stick! vp 0f0 (brain-dash b)))))))

;;;; hazards.lisp — every hit that isn't a fighter's melee is one HAZARD entity (design-v1 §12):
;;;;   :wave      a moving oriented box (WIDTH wide) that hits once (Ichigo's Getsuga; drawn by its :look function)
;;;;   :line      a ground line cut / crack: a look only (Kenpachi's floor splits)
;;;;   :fx        a look only drawn by its :look function (SPAWN-LOOK), or a character's own hazard (its HOOK: Ichigo's
;;;;              clones and their strikes, a :dmg-at hit's delay)
;;;; (The retired kits' fireball, pillars, South's bind and hands, Rukia's ice and NOMIHOSE's rift left with them, 2026-11-12.)
;;;; HAZARD-SYSTEM moves them (sim steps, SIM randomness only), COLLECT-HAZARD-HITS hands their hits to
;;;; combat.lisp's HIT-SYSTEM (applied with the fighters' hits), HAZARD-DRAW shows them (vfx.lisp
;;;; looks, real time). Hazards of one kind never hit their owner.
(in-package :duel)

(defun spawn-hazard (kind owner &key (x 0.0) (y 0.0) (z 0.0) (yaw 0.0) (speed 0.0) (size 0.5)
                                  (life 60) (delay 0) (hits 1) hw look src hook data
                                  (sp (let ((f (and owner (fighter owner))))   ; (an SP's: its owner's move now)
                                        (and f (fighter-move f) (sp-move-p (fighter-kit f) (fighter-move f)) t)))
                                  (sp-mv (let* ((f (and hw owner (fighter owner))) (mv (and f (fighter-move f))))   ; (a wave's Kikon)
                                           (and mv (core-kikon-p f mv) (getf (mv-params mv) :kikon-strike) mv))))
  "A new hazard of KIND for fighter OWNER. LIFE / DELAY in frames; HW = the HITWIN it deals (NIL = look only). SRC: its
hit comes from the owner's position. HOOK: a
character's function (h hz event &rest args) called with :step (each step, first: T skips the generic step) and :touches
(the volume test of a kind this file doesn't know); DATA: what it keeps. SP: its hits
ignore the combo scaling (default: spawned while its owner plays an SP, SP-MOVE-P). Its hits pay the owner the Reiatsu of
the owner's move now (HIT-RBASE; none: *REIATSU-KIND-OTHER*)."
  (spawn-entity (make-hazard :kind kind :owner owner :x (f32 x) :y (f32 y) :z (f32 z) :px (f32 x) :pz (f32 z)
                             :yaw (f32 yaw) :speed (f32 speed) :size (f32 size)
                             :life life :delay delay :hits-left (if hw hits 0) :hw hw :look look :src src
                             :hook hook :data data :sp sp
                             :sp-mv sp-mv
                             :rbase (f32 (let* ((f (and hw owner (fighter owner))) (mv (and f (fighter-move f))))
                                           (if mv (hit-reiatsu-base (mv-kind mv) (getf (mv-params mv) :reiatsu)) *reiatsu-kind-other*))))))

(defun spawn-look (e look &key (x (aref (pos-of e) 0)) (z (aref (pos-of e) 2)) (yaw 0.0) (size 1.0) (life 30) (delay 0) data)
  "A look-only hazard (kind :fx) of fighter E at X Z (default: E's feet) drawn by the function LOOK (the character's art
file): no hit, no sim effect but its entity."
  (spawn-hazard :fx e :x x :z z :yaw yaw :size size :life life :delay delay :look look :data data))

(defun spawn-ground-line (e size life look)
  "A look-only :line hazard of fighter E from his feet along his facing, SIZE m long, LIFE frames, drawn as LOOK."
  (let ((p (pos-of e))) (spawn-hazard :line e :x (aref p 0) :z (aref p 2) :yaw (yaw-of e) :size size :life life :look look)))

(defun clear-hazards ()
  (do-entities (h hazard) (destroy-entity h)))

(defun hazard-target (hz)
  "The fighter a hazard of HZ's owner can hit (his opponent), or NIL."
  (let ((o (hazard-owner hz))) (and (entity-alive-p o) (fighter-opp (fighter o)))))

;;; ---------------------------------------------------------------- per step
(defun hazard-step (h hz)
  (let ((k (hazard-hook hz))) (when (and k (funcall k h hz :step)) (return-from hazard-step nil)))
  (when (> (hazard-delay hz) 0)
    (decf (hazard-delay hz))
    (return-from hazard-step nil))
  (incf (hazard-age hz))
  (when (> (hazard-rehit hz) 0) (decf (hazard-rehit hz)))
  (setf (hazard-px hz) (hazard-x hz) (hazard-pz hz) (hazard-z hz))
  (when (eq (hazard-kind hz) :wave)
    (let ((d (* (hazard-speed hz) +step+)))
      (setf (hazard-x hz) (f32 (+ (hazard-x hz) (* d (fwd-x (hazard-yaw hz)))))
            (hazard-z hz) (f32 (+ (hazard-z hz) (* d (fwd-z (hazard-yaw hz))))))
      (when (> (+ (expt (hazard-x hz) 2) (expt (hazard-z hz) 2)) (expt (+ *arena-radius* 2.0) 2))
        (setf (hazard-age hz) (hazard-life hz)))))
  (when (>= (hazard-age hz) (hazard-life hz)) (destroy-entity h)))

(defun hazard-system ()
  "Move / age every hazard one fixed step."
  (do-entities (h (hz hazard)) (hazard-step h hz)))

;;; ---------------------------------------------------------------- volumes
(defun hazard-active-p (hz)
  (and (hazard-hw hz) (> (hazard-hits-left hz) 0) (<= (hazard-rehit hz) 0) (<= (hazard-delay hz) 0)))

(defun hazard-touches-p (hz tx ty tz tr th)
  "Does HZ's world volume touch the hurt cylinder at (TX TY TZ), radius TR, height TH?"
  (let ((x (hazard-x hz)) (y (hazard-y hz)) (z (hazard-z hz)) (s (hazard-size hz)) (tr (f32 tr)) (th (f32 th)))
    (case (hazard-kind hz)
      (:wave (obox-cyl-hit-p x 1f0 z (hazard-yaw hz) s (f32 (first *wave-box*)) (f32 (second *wave-box*)) tx ty tz tr th))
      (t (let ((k (hazard-hook hz))) (and k (funcall k nil hz :touches tx ty tz tr th)))))))

(defun collect-hazard-hits ()
  "Hand every active hazard's contact with its target to the HIT-SYSTEM's pending list."
  (do-entities (h (hz hazard))
    (when (hazard-active-p hz)
      (let ((tg (hazard-target hz)))
        (when (entity-alive-p tg)
          (let ((q (pos-of tg)) (b (model-body (model tg))))
            (when (hazard-touches-p hz (aref q 0) (aref q 1) (aref q 2) (body-hurt-r b) (body-hurt-h b))
              (push (make-pending :att (hazard-owner hz) :def tg :hw (hazard-hw hz)
                                  :sx (if (hazard-src hz) (aref (pos-of (hazard-owner hz)) 0) (hazard-x hz))
                                  :sz (if (hazard-src hz) (aref (pos-of (hazard-owner hz)) 2) (hazard-z hz))
                                  :hazard hz :state (defender-state tg))
                    *pending*))))))))

(defun hazard-connected (hz)
  "HZ's hit took effect: one hit fewer (a wave is spent), a multi-hit one waits before hitting again."
  (decf (hazard-hits-left hz))
  (setf (hazard-rehit hz) *hazard-rehit*)
  (when (and (<= (hazard-hits-left hz) 0) (eq (hazard-kind hz) :wave))
    (setf (hazard-life hz) (hazard-age hz))))            ; gone at the next step (its look fades)

(defun hazard-threat-p (owner victim)
  "Perfect Hoho vs hazards: one of OWNER's hazards is active (or becomes so within *PERFECT-LEAD*
frames) and touches VICTIM's hurt cylinder grown by *PERFECT-INFLATE*."
  (let ((q (pos-of victim)) (b (model-body (model victim))) (found nil))
    (do-entities (h (hz hazard))
      (when (and (not found) (eql (hazard-owner hz) owner) (hazard-hw hz) (> (hazard-hits-left hz) 0)
                 (<= (hazard-delay hz) *perfect-lead*)
                 (hazard-touches-p hz (aref q 0) (aref q 1) (aref q 2)
                                   (+ (body-hurt-r b) *perfect-inflate*) (+ (body-hurt-h b) *perfect-inflate*)))
        (setf found t)))
    found))

;;; ---------------------------------------------------------------- draw (real time)
(defun hazard-draw (rdt)
  "Every hazard's look this frame."
  (do-entities (h (hz hazard))
    (if (and (hazard-look hz) (not (keywordp (hazard-look hz))))   ; a draw function (a wave's, a look's): it draws its tell too
        (funcall (hazard-look hz) hz (f32 rdt))
    (when (<= (hazard-delay hz) 0)
      (let ((x (hazard-x hz)) (z (hazard-z hz)) (age (/ (hazard-age hz) 60.0)) (life (/ (hazard-life hz) 60.0)))
        (case (hazard-kind hz)
          (:line (let ((l (hazard-size hz)) (yaw (hazard-yaw hz)))
                   (vfx-line-cut x z (+ x (* l (fwd-x yaw))) (+ z (* l (fwd-z yaw))) age life (hazard-look hz) :dt rdt)))
          (:wave nil)))))))   ; (a wave draws by its :look function)

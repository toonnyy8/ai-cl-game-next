;;;; feedback.lisp — FEEDBACK-SYSTEM: the rules decide, events report, this shows (design-v1 §10–§11).
;;;; Fighters, combat and hazards EMIT small events; once per step (last system) this takes them all
;;;; and plays the sounds, sparks (vfx.lisp), shake, callouts and big words. Everything here is
;;;; cosmetic (RND01, real time): nothing the sim reads is decided here (hitstop is combat.lisp's).
;;;;
;;;; Events (positions captured when they happen):
;;;;   (:swing e kind)  (:super e)  (:breaker e) (:breaker-end e)  (:rush e) (:rush-dash e) (:kikon-follow att def)  (:step e)
;;;;   (:hit att def x y z hitstop counter-p dmg kind)  (the attacker's kit hook :hit-fx sees it after the spark)  (:blocked att def x y z)  (:armored def x y z)
;;;;   (:absorbed def x y z)  (:guard-crush att def x y z) (:guard-back e)  (:guard-break att def x y z)  (:stance-break att def x y z)  (:clash x y z)
;;;;   (:parried att def x y z)  (:scorch att)  (:ward-crush e)  (:refused e cmd)  (:kosei att m x y z)
;;;;   (:hazard-cut x y z)  (:hoho-out e x z) (:hoho-in e x z) (:perfect e victim)  (:burst e attacker mode) (:burst-end e)
;;;;   (:launch e) (:land e)
;;;;   (:konpaku victim lost) (:kikon att victim) (:soul-break att victim)  (:awaken e) (:form e form)
;;;;   (:evolution e) (:hellfire e)  (:skeleton-rise x z)  (:sfx key e)  (:reset)
;;;;   (:ken-bk-burst e kind)   Kenpachi's special AS: 千切's beats (:chigiri-draw / -still / -quake / :chigiri), TATE-GOTO's split
;;;;   (:ground-scar x z yaw ds r)   Kenpachi's floor cracks (Buttagiru, 斬壞's J5, TATE-GOTO): GROUND-SCAR
;;;;   (:rung e up-p) (:drink att def x y z) (:rift-cut owner x z hx hz yaw) (:rift-close x z)   Nozarashi's NOME ladder
;;;;   (:bankai e)   Kenpachi's Bankai
(in-package :duel)

(defun sfx-on (key e &key (gain 1.0) (pitch 1.0))
  (let ((p (pos-of e))) (sfx-at key (aref p 0) (+ (aref p 1) 1.0) (aref p 2) :gain gain :pitch pitch)))

(defun hit-dir (att def)
  "Values dx dz: unit direction from ATT to DEF."
  (let* ((p (pos-of att)) (q (pos-of def)) (dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2)))
         (d (max 0.01 (hypot dx dz))))
    (values (/ dx d) (/ dz d))))

(defvar *hums* (make-array 2 :initial-element -1) "Breaker hum loop voice per side.")
(declaim (type f32vec *fb-v*))
(defvar *fb-v* (make-f32 3) "A world point (the scorched hand).")

(defun stop-hum (e)
  (let ((i (fighter-side (fighter e))))
    (when (>= (svref *hums* i) 0) (stop-loop (svref *hums* i) 0.1) (setf (svref *hums* i) -1))))

(defun show-hit (att def x y z hs counter dmg kind)
  "A hit (docs/style/STYLE_STORM_DESIGN.md §4.3): the drawn spark; a heavy hit also holds the attacker's pose 3 f
and smears the victim along the hit; a counter turns the frame to a manga page for 2 f (red stays)."
  (multiple-value-bind (dx dz) (hit-dir att def)
    (let ((look (cond (counter :counter) ((eq kind :breaker) :breaker) ((eq kind :fire) :fire) ((eq kind :bind) :cut)
                      ((eq kind :quick) :cut) (t :heavy))))
      (vfx-hit x y z look :dx dx :dz dz)
      (when (member look '(:heavy :counter :breaker))
        (hold-pose att 3) (smear def dx dz))
      (sfx-at (cond ((eq kind :breaker) :punch) ((eq kind :fire) :explode) ((eq kind :bind) :bones) ((eq kind :ice) :freeze)
                    ((eq kind :quick) :cut) (t :cut-heavy))
              x y z :gain (if (eq kind :quick) 0.8 1.0))))
  (setf (model-flash (model def)) (max 0.06 (/ hs 60.0)))
  (cond ((>= dmg 150) (shake 0.22 0.3)) ((>= dmg 60) (shake 0.09 0.18)) (t (shake 0.03 0.1)))
  (cond ((eq kind :fire) (stage-mark :scorch x z 0.8))           ; the page keeps the fight (Phase 6): fire scorches,
        ((or (>= dmg 150) (eq kind :breaker))                      ; a heavy blow cracks the stone and throws chips
         (stage-mark :crack x z 0.9) (stage-debris x z 3)))
  (when counter
    (impact-frame :manga 2)
    (announce "COUNTER" :color '(0.82 0.06 0.11 1) :secs 0.6 :small t)))

(defun ground-scar (x z yaw ds r)
  "Crack marks R m wide at DS metres ahead of (X Z) along YAW, that stay for the round, and chips thrown up (stage.lisp
STAGE-MARK / STAGE-DEBRIS; Phase 6 destruction). Shown here, never from the sim: a rollout's events are dropped, so a CPU's
search leaves no crack on the live stage (REFACTOR_2026-11 §11.5.2 C)."
  (dolist (d ds)
    (let ((mx (+ x (* d (fwd-x yaw)))) (mz (+ z (* d (fwd-z yaw)))))
      (stage-mark :crack mx mz r) (stage-debris mx mz 3))))

(defun feedback-system ()
  "Show every event emitted since the last call, oldest first."
  (do-events (kind)
    (:swing (e k)
      (unless (eq k :quick) (smear e (fwd-x (yaw-of e)) (fwd-z (yaw-of e))))   ; a heavy swing starts
      (sfx-on (if (eq k :quick) :whoosh-light (or (kit-swing-sfx (kit-of e)) :whoosh-heavy)) e :gain 0.7))
    (:super args (let ((e (first args)))
                   (setf (model-super (model e)) (/ *super-flash* 60.0)) (sfx-on :whoosh-heavy e :pitch 0.7)))
    (:breaker args (let ((e (first args)))
                     (stop-hum e)
                     (setf (svref *hums* (fighter-side (fighter e))) (start-loop :breaker-hum :gain 0.7))))
    (:breaker-end args (stop-hum (first args)))
    (:rush args (let* ((e (first args)) (p (pos-of e)))       ; the Kikon rush starts: a red ring at his feet
                  (vfx-kikon-rush (aref p 0) (aref p 2))
                  (smear e (fwd-x (yaw-of e)) (fwd-z (yaw-of e)))
                  (setf (model-super (model e)) 0.12)
                  (sfx-on :whoosh-heavy e :pitch 0.6)))
    (:rush-dash args (let* ((e (first args)) (mv (fighter-move (fighter e))) (p (pos-of e)))   ; a rush module takes off
                       (when mv
                         (let ((sfx (getf (mv-params mv) :sfx)) (look (getf (mv-params mv) :look)))
                           (when sfx (sfx-on sfx e))
                           (vfx-rush-dash (aref p 0) (aref p 2) (fwd-x (yaw-of e)) (fwd-z (yaw-of e)) look)
                           (when (eq look :flash-step) (start-ghost e))))))
    (:kikon-follow (att def)   ; the strike hit, O held: he dashes in (not red: guard it!)
      (declare (ignore def))
      (let ((p (pos-of att))) (vfx-kikon-rush (aref p 0) (aref p 2)))
      (sfx-on :whoosh-heavy att :pitch 0.6)
      (focus-lines 10)
      (announce "KIKON" :sub (if (kikon-ready-p att) nil "GUARD IT!") :color '(0.82 0.06 0.11 1) :secs 0.6 :small t))
    (:hit args (apply #'show-hit args)
      (let ((h (kit-hook (kit-of (first args)) :hit-fx)))   ; a kit's own mark on its hit (Hisagi's chain tip)
        (when h (apply h args))))
    (:blocked (att def x y z)
      (multiple-value-bind (dx dz) (hit-dir att def)
        (vfx-hit x y z :guard :dx dx :dz dz)
        (when (passive-p att :pierce)                ; East's pierce: a white spark out of his back
          (vfx-hit (+ x (* 0.7 dx)) y (+ z (* 0.7 dz)) :cut :dx dx :dz dz)))
      (sfx-at :clang x y z))
    (:armored (def x y z)     ; the owner's spot colour: REIATSU (+ his absorb sound)
      (vfx-hit x y z :reiatsu) (sfx-at :cut x y z :gain 0.7)
      (let ((k (kit-absorb-sfx (kit-of def)))) (when k (sfx-on k def :gain 0.8))))
    (:parried (att def x y z)   ; a parry caught it: an ember star, a 1 f negative frame
      (multiple-value-bind (dx dz) (hit-dir att def) (vfx-ember x y z :dx (- dx) :dz (- dz) :scale 1.3))
      (sfx-at :clang x y z) (sfx-at :sizzle x y z) (shake 0.12 0.2) (impact-frame :negative 1)
      (announce "PARRY" :color '(1 0.55 0.2 1) :secs 0.7 :small t))
    (:refused args (sfx-on :clang (first args) :gain 0.35 :pitch 1.6)      ; still cooling: a dud tick
                   (when (eq (second args) :sp) (webhud-refused! (first args))))   ; an SP segment refused: the HUD's cue (DUEL_SP §8.4 S8)
    (:absorbed (def x y z)
      (vfx-hit x y z :guard) (sfx-at :cut x y z :gain 0.7)
      (let ((k (kit-absorb-sfx (kit-of def)))) (when (and k (< (rnd01) 0.5)) (sfx-on k def :gain 0.8))))
    (:guard-crush (att def x y z)        ; the guard gauge ran out on a block
      (multiple-value-bind (dx dz) (hit-dir att def) (vfx-hit x y z :guard-crush :dx dx :dz dz))
      (sfx-at :guard-break x y z :pitch 1.2) (sfx-at :clang x y z :pitch 0.8)
      (shake 0.15 0.25) (impact-frame :negative 1)
      (announce "GUARD CRUSH" :color '(0.78 0.83 0.89 1) :secs 1.0))
    (:guard-back args (let ((e (first args)))                           ; full again: he can guard
                        (sfx-on :clang e :gain 0.5 :pitch 1.4)
                        (announce "GUARD" :color '(0.78 0.83 0.89 1) :secs 0.7 :side (fighter-side (fighter e)))))
    (:guard-break (att def x y z)
      (multiple-value-bind (dx dz) (hit-dir att def) (vfx-hit x y z :guard-break :dx dx :dz dz))
      (sfx-at :guard-break x y z) (shake 0.2 0.3) (ui-flash 1 1 1 0.9 50.0)      ; a 1 f white flash
      (stage-mark :crack x z 1.1) (stage-debris x z 4)
      (announce "GUARD BREAK" :color '(1 1 1 1) :secs 1.0))
    (:stance-break (att def x y z)
      (multiple-value-bind (dx dz) (hit-dir att def) (vfx-hit x y z :guard-break :dx dx :dz dz))
      (sfx-at :guard-break x y z)
      (announce "BROKEN" :color '(1 1 1 1) :secs 0.9 :small t))
    (:clash (x y z)
      (vfx-hit x y z :clash) (sfx-at :clash x y z) (shake 0.25 0.3) (stage-mark :crack x z 1.2) (stage-debris x z 4)
      (impact-frame :negative 2) (focus-lines 20 x y z)
      (announce "CLASH" :color '(1 1 1 1) :secs 0.9))
    (:hazard-cut (x y z) (vfx-hit x y z :heavy) (sfx-at :cut-heavy x y z))
    (:step args (let* ((e (first args)) (p (pos-of e)) (v (motion-kb (motion e))) (vx (aref v 0)) (vz (aref v 2))
                       (l (hypot vx vz)))
                  (multiple-value-bind (dx dz) (if (> l 1e-4) (values (/ vx l) (/ vz l)) (values (fwd-x (yaw-of e)) (fwd-z (yaw-of e))))
                    (vfx-step-dust (aref p 0) (aref p 2) (- dx) (- dz)) (smear e dx dz))
                  (sfx-on :step e :gain 0.6)
                  ;; the oni's back leap roars (DUEL_KEN_REWORK §8.4): the shout face through the leap, a low growl
                  (when (eq (clip-name (anim-clip (model-anim (model e)))) :ke-b-step-b)
                    (face-beat e :shout 0.4) (sfx-on :oni-roar e))))
    (:hoho-out (e x z)
      (vfx-hoho x 1.0 z nil :dx (fwd-x (yaw-of e)) :dz (fwd-z (yaw-of e)))
      (start-ghost e)
      (sfx-on :hoho-out e))
    (:hoho-in (e x z)
      (vfx-hoho x 1.0 z t :dx (fwd-x (yaw-of e)) :dz (fwd-z (yaw-of e))) (sfx-on :hoho-in e))
    (:perfect _ (play-sfx :perfect) (setf *punch-t* 0.5)
              (announce "PERFECT" :color '(1 1 1 1) :secs 0.9))
    (:burst args (let* ((e (first args)) (m (third args)) (p (pos-of e)) (x (aref p 0)) (z (aref p 2)))   ; the stamp mono
                   (vfx-burst x (aref p 1) z)                                                  ; (STEEL), the word in
                   (sfx-on :clash e :pitch (if (eq m :white) 0.9 0.7)) (sfx-on :hoho-in e)    ; the burst's colour
                   (shake 0.15 0.25)
                   (announce (burst-name m) :color (burst-color m) :secs 1.0 :small t)))
    (:burst-end args (sfx-on :hoho-out (first args) :gain 0.5 :pitch 0.8))
    (:launch args (sfx-on :launch (first args) :gain 0.8))
    (:land args (let ((e (first args))) (sfx-on :land e)
                  (let ((p (pos-of e))) (vfx-shockwave (aref p 0) (aref p 2) 1.2 0.3 :pal +pal-dust+)
                    (stage-mark :crack (aref p 0) (aref p 2) 0.6) (stage-debris (aref p 0) (aref p 2) 2 0.6))))
    (:konpaku (v lost) (pips-shatter v lost))
    (:kikon (att v)
      (declare (ignore v))
      (play-sfx :bell)
      (setf (model-super (model att)) 0.15))
    (:soul-break _ nil)                                   ; the cinematic says it
    (:awaken args (let ((e (first args))) (sfx-on :awaken-boom e)))
    (:form (e form)
      (declare (ignore form))
      (when (kit-callout (kit-of e)) (announce (kit-callout (kit-of e)) :color '(1 0.5 0.15 1) :secs 1.0 :small t)))
    (:evolution args (let ((e (first args))) (play-sfx :evolution)
                       (announce "EVOLUTION" :color '(1 0.85 0.3 1) :secs 1.0 :small t :side (fighter-side (fighter e)))))
    (:hellfire args (let* ((e (first args)) (p (pos-of e)))
                      (vfx-shockwave (aref p 0) (aref p 2) 6.0 0.5 :rgb '(1.0 0.5 0.15)) (shake 0.2 0.4)
                      (stage-mark :scorch (aref p 0) (aref p 2) 2.0)))
    (:sfx (key e) (sfx-on key e))
    (:ground-scar (x z yaw ds r) (ground-scar x z yaw ds r))
    (:reset _ (play-sfx :bell :gain 0.6) (stage-clear-marks))   ; a new round: a clean page
    (:rung (e up)               ; a cup up (or down) the NOME ladder
      (let ((form (fighter-form (fighter e))) (side (fighter-side (fighter e))))
        (cond ((not up)
               (let ((p (pos-of e))) (vfx-smoke-puffs (aref p 0) 1.2 (aref p 2) 2))
               (when (eq form :nozarashi) (callout e "TSUMANNEE...")))
              ((eq form :nomihose)              ; drink it dry: a negative, then a manga page (yellow kept);
               (impact-frame :negative 1) (setf *impact-next* '(:manga . 12))   ; the grin, head thrown back
               (face-beat e :shout 0.9 t)
               (sfx-on :awaken-boom e) (sfx-on :tier-up e) (shake 0.2 0.3)
               (announce "NOMIHOSE!" :color '(1 0.85 0.25 1) :secs 1.0 :small t :side side))
              (t (sfx-on :tier-up e)
                 (announce "RYOTE" :color '(1 0.85 0.25 1) :secs 0.8 :small t :side side)))))
    (:drink (att def x y z)     ; the hit star reversed: flecks sucked into the cleaver
      (multiple-value-bind (dx dz) (hit-dir att def) (vfx-hit x y z :reiatsu :dx (- dx) :dz (- dz)))
      (sfx-on :gulp def)
      (when (< (rnd01) 0.33) (sfx-on :laugh def :gain 0.7)))
    (:rift-cut (o x z hx hz yaw)  ; the white hit and the ink gash left along the rift
      (declare (ignore o))
      (vfx-hit x 1.15 z :heavy) (vfx-rift-gash hx hz (fwd-x yaw) (fwd-z yaw))
      (sfx-at :rift-cut x 1.15 z) (shake 0.08 0.15))
    (:rift-close (x z) (vfx-smoke-puffs x 1.15 z 1))
    (:ken-bk-burst (e kind)      ; Kenpachi's special AS: 千切's cuts bursting round him / TATE-GOTO's split (DUEL_KEN_V3 §30)
      (let ((p (pos-of e)) (yaw (yaw-of e)))
        (case kind
          (:bankai (vfx-ken-bk-burst (aref p 0) (aref p 2) :chigiri)   ; (§32)
                   (vfx-shockwave (aref p 0) (aref p 2) 7.0 0.6 :pal +pal-blood+) (impact-frame :red 6)
                   (sfx-on :awaken-boom e) (sfx-on :oni-roar e) (sfx-on :explode e :gain 0.7) (shake 0.45 0.6))
          (:chigiri-draw (impact-frame :negative 1) (sfx-on :rift-open e))   ; (§30.3: each beat its own grade)
          (:chigiri-still (impact-frame :manga *chigiri-still-frames*))      ; ink and paper but the red, through the still charge
          (:chigiri-quake (sfx-on :awaken-rise e) (sfx-on :rift-open e :gain 1.2) (shake 0.15 0.12))
          (:chigiri (vfx-ken-bk-burst (aref p 0) (aref p 2) kind) (impact-frame :red 10)   ; red and ink, then the colour back
                    (sfx-on :oni-roar e) (sfx-on :konpaku-shatter e) (sfx-on :rift-cut e) (shake 0.35 0.5))
          (:tategoto-cut (vfx-ken-tategoto-cut (+ (aref p 0) (* 2.2 (fwd-x yaw))) (+ (aref p 2) (* 2.2 (fwd-z yaw))))
                         (sfx-on :rift-cut e) (sfx-on :kikon-slash e :gain 0.8) (shake 0.35 0.45))
          (t
            (progn (vfx-ken-bk-burst (+ (aref p 0) (* 2.2 (fwd-x yaw))) (+ (aref p 2) (* 2.2 (fwd-z yaw))) kind)
                   (sfx-on :ground-crack e) (sfx-on :kikon-slash e :gain 0.7) (sfx-on :rift-open e) (shake 0.3 0.4))))))
    (:bankai _ nil)))                                      ; the cinematic says it

;;;; look.lisp — the answer key's look data (docs/bevy/plans/2026-11-26-m0-extractor-oracle.md Task 8), read from the native image:
;;;;   env LD_PRELOAD=build/simgate/muslm.so $ECL_HOST --norc --load tools/port/oracle/look.lisp -- build/simgate/duel.fas sound OUT-DIR
;;;;   env LD_PRELOAD=build/simgate/muslm.so $ECL_HOST --norc --load tools/port/oracle/look.lisp -- build/simgate/duel.fas fk OUT-DIR [SHARD NSHARDS]
;;;; (tools/port/oracle/gen.py look runs both.)
;;;;
;;;; sound: OUT-DIR/<key>.f32 for every *AU-DEFS* entry, raw little-endian f32, 48 kHz mono. Rendered in definition order, first thing
;;;;   after the image loads (no SG-INIT, nothing else calls AU-RND before: the noise stream is the C global au_rng from its seed
;;;;   0x9E3779B9, tools/simgate/stubs.c), through AUDIO-INIT-SOUND's sequence (engine/lisp/audio.lisp): funcall the sound's function,
;;;;   AU-SANITIZE!, AU-FINISH! unless it loops, AU-NORMALIZE! to its peak. (The native stubs' au_open fails, so the image never
;;;;   synthesizes on its own.) "sound OUT-DIR after-init" runs SG-INIT first (the page's order: the :load steps, then the sounds), a
;;;;   check that the :load steps draw nothing from au_rng. One stdout line per
;;;;   sound: "sound <key> <samples> <loop T/NIL> <peak> <bad>" (bad = NaN / Inf samples AU-SANITIZE! zeroed).
;;;;
;;;; fk: OUT-DIR/<clip>.json for every clip (the clip's name in lower case, as clips.json keys it), after SG-INIT. The FK is the engine's
;;;;   own, the path tests/duel-rules/art.lisp's reach test takes: CLIP-SAMPLE! the clip at t, POSE-FK! at the origin facing yaw 0 (-Z)
;;;;   with the body's scale, hunch and rig proportions, JOINT-POINT! for the held weapon (draw.lisp's BODY-WEAPON-TIP / -BASE: the
;;;;   :weapon-r joint's local (0 0 -len) and (0 0 -base)). Draw-time looks on top of it are not in it: a kit's :pose hook, the
;;;;   two-handed grip (GRIP-STEP), the beat pose, the lift, a cinematic's scale, the crossfade between clips.
;;;;   Frames: t_i = i / 60 (single-float (/ (float i 1f0) 60f0)), i = 0 .. N, N = (floor (+ (* dur 60) 0.001)) (a loop's t = dur wraps
;;;;   to its start, a one-shot's clamps: CLIP-SAMPLE!).
;;;;   Who plays a clip (each such form gets its weapon's tip and base; each distinct rig among their bodies gets the joint matrices):
;;;;   Sampled under the game's *KEY-EASE* 1 (ease-out cubic between keys; START-GAME sets it during SG-INIT; the reach test's host load
;;;;   keeps the engine default 0, smoothstep), written as "key_ease".
;;;;     "kit"    the forms whose KIT-CLIPS (moves through :clip-map, stance, intro / win, entry, run, :look-clips), core :stances or
;;;;              body's BODY-CLIPS (a variant's own walk / guard, played in place of a shared clip) name it;
;;;;     else by its name's prefix: "prefix" ya- / ke- / ic- / hs- -> every form of that character (its cinematics, victim poses,
;;;;              hook-started clips); "shared" sh- -> every form whose body does not play its own version instead (BODY-CLIPS);
;;;;              sk- -> no form (Yamamoto's 南 dead, a look body). A heuristic: a victim clip is played on the opponent's body, so a
;;;;              clip no kit names gets the joints of every body's rig (standard, Kenpachi's, Yamamoto's, the skeleton's).
;;;;   File (keys sorted; floats shortest round-trip single-floats):
;;;;     {"clip", "dur", "loop", "fps": 60, "frames": N+1, "t": [t_0 ..], "key_ease": 1,
;;;;      "joint_names": the 21 joints in rig order (engine/lisp/anim.lisp *RIG*),
;;;;      "rigs": [{"bodies": [...], "scale", "hunch" (rad), "props": the MAKE-RIG-PROPORTIONS vector (64 f32) or null,
;;;;                "joints": per frame 21 x 16 f32: joint j's world matrix at [16 j, 16 j + 16), the engine's layout (column-major:
;;;;                          a point p maps to m[0..2] px + m[4..6] py + m[8..10] pz + m[12..14])}],
;;;;      "forms": [{"form": "character/form", "body", "rig": index into rigs, "by": "kit" | "prefix" | "shared",
;;;;                 "weapon", "weapon_len", "weapon_base", "tip": per frame [x y z], "base": per frame [x y z]}]}
(load (merge-pathnames "../../simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)
(load (merge-pathnames "../extract/json.lisp" (directory-namestring *load-truename*)) :verbose nil)

(defparameter *lk-args* (rest cl-user::*sg-args*))
(defparameter *lk-out* (let ((d (second *lk-args*))) (if (char= (char d (1- (length d))) #\/) d (concatenate 'string d "/"))))
(ensure-directories-exist *lk-out*)
(defun lk-name (k) (string-downcase (symbol-name k)))

;;; ---------------------------------------------------------------- sound
(defun lk-write-f32 (path buf)
  (let ((bytes (make-array (* 4 (length buf)) :element-type '(unsigned-byte 8))))
    (dotimes (i (length buf))
      (let ((b (si:single-float-bits (aref buf i))))
        (dotimes (k 4) (setf (aref bytes (+ (* 4 i) k)) (ldb (byte 8 (* 8 k)) b)))))
    (with-open-file (o path :direction :output :if-exists :supersede :element-type '(unsigned-byte 8))
      (write-sequence bytes o))))

(defun lk-sounds ()
  (dolist (d engine::*au-defs*)
    (destructuring-bind (key peak loop fn) d
      (let* ((buf (funcall fn)) (bad (engine::au-sanitize! buf)))
        (unless loop (engine::au-finish! buf))
        (engine::au-normalize! buf peak)
        (lk-write-f32 (format nil "~a~a.f32" *lk-out* (lk-name key)) buf)
        (format t "sound ~a ~d ~a ~a ~d~%" (lk-name key) (length buf) loop peak bad))))
  (format t "look sound: ~d sounds~%" (length engine::*au-defs*)))

;;; ---------------------------------------------------------------- fk
(defun lk-forms ()
  "((character form kit) ...) for every live form, in roster then definition order."
  (loop for c in *roster* append (loop for (f . k) in (reverse (gethash c *kits*)) collect (list c f k))))

(defun lk-body-plays (k)
  "The clips a form's body plays in place of a shared one (BODY-CLIPS values) and the shared ones it replaces."
  (let ((bc (body-clips (find-body (kit-body k)))))
    (values (loop for (nil v) on bc by #'cddr collect v) (loop for (s) on bc by #'cddr collect s))))

(defun lk-players (clip forms)
  "((character form kit by) ...) that play CLIP (the file header's rule)."
  (or (loop for (c f k) in forms
            when (or (member clip (kit-clips k)) (member clip (getf (kit-core k) :stances)) (member clip (lk-body-plays k)))
              collect (list c f k "kit"))
      (let* ((n (symbol-name clip)) (p (subseq n 0 (position #\- n)))
             (ch (cdr (assoc p '(("YA" . :yamamoto) ("KE" . :kenpachi) ("IC" . :ichigo) ("HS" . :hisagi)) :test #'string=))))
        (cond (ch (loop for (c f k) in forms when (eq c ch) collect (list c f k "prefix")))
              ((string= p "SH") (loop for (c f k) in forms
                                      unless (member clip (nth-value 1 (lk-body-plays k))) collect (list c f k "shared")))
              ((string= p "SK") nil)
              (t (error "clip ~s: no form plays it and its prefix names no one" clip))))))

(defun lk-rig-key (b) (list (body-scale b) (body-hunch b) (and (body-props b) (coerce (body-props b) 'list))))

(defun lk-clip (clip forms)
  (let* ((cl (find-clip clip)) (dur (clip-dur cl)) (n (floor (+ (* dur 60f0) 0.001f0)))
         (ts (loop for i from 0 to n collect (/ (float i 1f0) 60f0)))
         (players (lk-players clip forms))
         (bodies (if (equal (fourth (first players)) "kit")
                     (remove-duplicates (mapcar (lambda (p) (kit-body (third p))) players) :from-end t)
                     (sort (loop for b being the hash-keys of *bodies* collect b) #'string< :key #'symbol-name)))
         (rigs nil)                                   ; ((key bodies) ...) in first-seen order
         (pose (make-f32 +pose-n+)) (jm (make-f32 (* 16 +nj+))) (v (make-f32 3)) (wj (joint-index :weapon-r)))
    (dolist (bn bodies)
      (let* ((key (lk-rig-key (find-body bn))) (r (assoc key rigs :test #'equal)))
        (if r (setf (cdr r) (append (cdr r) (list bn))) (setf rigs (append rigs (list (list key bn)))))))
    (flet ((rig-of (bn) (position (lk-rig-key (find-body bn)) rigs :key #'first :test #'equal))
           (pose-at (b tm)
             (clip-sample! pose cl tm)
             (pose-fk! jm pose 0f0 0f0 0f0 0f0 (body-scale b) (body-hunch b) (body-props b))))
      (let ((rig-objs
              (loop for (nil . bns) in rigs
                    collect (let ((b (find-body (first bns))))
                              (cl-user::json-object
                               (list :bodies bns :scale (body-scale b) :hunch (body-hunch b) :props (body-props b)
                                     :joints (loop for tm in ts collect (progn (pose-at b tm) (copy-seq jm))))))))
            (form-objs
              (loop for (c f k by) in players
                    collect (let* ((b (find-body (kit-body k))) (w (and (kit-weapon k) (find-weapon (kit-weapon k)))) tips bases)
                              (when w
                                (dolist (tm ts)
                                  (pose-at b tm)
                                  (funcall #'joint-point! v jm wj 0f0 0f0 (- (weapon-len w)))
                                  (push (coerce v 'list) tips)
                                  (funcall #'joint-point! v jm wj 0f0 0f0 (- (weapon-base w)))
                                  (push (coerce v 'list) bases)))
                              (cl-user::json-object
                               (list :form (format nil "~a/~a" (lk-name c) (lk-name f)) :body (kit-body k) :rig (rig-of (kit-body k))
                                     :by by :weapon (kit-weapon k) :weapon_len (and w (weapon-len w)) :weapon_base (and w (weapon-base w))
                                     :tip (cl-user::json-array (nreverse tips)) :base (cl-user::json-array (nreverse bases))))))))
        (with-open-file (o (format nil "~a~a.json" *lk-out* (lk-name clip)) :direction :output :if-exists :supersede)
          (cl-user::extract-json
           (cl-user::json-object
            (list :clip (lk-name clip) :dur dur :loop (and (clip-loop cl) t) :fps 60 :frames (length ts) :t (cl-user::json-array ts)
                  :key_ease *key-ease*
                  :joint_names (cl-user::json-array (mapcar (lambda (j) (lk-name (first j))) engine::*rig*))
                  :rigs (cl-user::json-array rig-objs) :forms (cl-user::json-array form-objs)))
           o))
        (format t "fk ~a ~d frames ~d rigs ~d forms~%" (lk-name clip) (length ts) (length rigs) (length players))))))

(defun lk-fk (shard nshards)
  (cl-user::sg-init)
  (unless (= *key-ease* 1) (error "*key-ease* ~d after SG-INIT: START-GAME sets the game's 1" *key-ease*))
  (let ((forms (lk-forms)) (k 0))
    (loop for clip in (list-clips) for i from 0
          when (= (mod i nshards) shard) do (lk-clip clip forms) (incf k))
    (format t "look fk: ~d clips (shard ~d of ~d)~%" k shard nshards)))

(let ((mode (first *lk-args*)))
  (cond ((string= mode "sound") (when (equal (third *lk-args*) "after-init") (cl-user::sg-init)) (lk-sounds))   ; (after-init: a check only)
        ((string= mode "fk") (lk-fk (parse-integer (or (third *lk-args*) "0")) (parse-integer (or (fourth *lk-args*) "1"))))
        (t (format t "look.lisp: mode sound | fk~%") (ext:quit 2))))
(ext:quit 0)

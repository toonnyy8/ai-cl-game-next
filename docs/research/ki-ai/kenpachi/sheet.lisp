;;;; sheet.lisp — Kenpachi's data sheet for the KI style search (docs/duel/DUEL_MATCHUP_AI.md, step 1), generated from the kit
;;;; data on the host, the way tests/duel-rules-test.lisp loads it (plain CL, no engine, no build):
;;;;   $ECL_HOST --norc --load docs/research/ki-ai/kenpachi/sheet.lisp | grep -v "^;;; Loading" > docs/research/ki-ai/kenpachi/sheet-data.md
;;;; Walks each form's :core (NS chains by :ns-next, each segment's SA, the AS entries and their chains) and its J string
;;;; (:commands :q, then :strings :q); never the kit's whole move table (it still holds the old unreachable grid / K / SP moves).
(dolist (f '("package" "math" "hitvol" "input"))
  (load (merge-pathnames (format nil "../../../../engine/lisp/~a.lisp" f) *load-truename*) :verbose nil))
(defpackage :duel (:use :cl :engine))
(defmacro duel::defcine (&rest r) (declare (ignore r)) nil)
(defmacro engine:defcomponent (name &rest slots) `(defstruct (,name (:copier nil) (:predicate nil)) ,@slots))
(let ((*standard-output* (make-broadcast-stream)))
  (dolist (f '("tuning" "rules" "core" "learn" "kit" "yama" "ken" "rukia-ai" "rukia" "ichigo" "endless-rules" "rogue-rules" "run-mods"
               "senjumaru" "barro" "barro-ai" "hisagi" "hisagi-ai"))
    (load (merge-pathnames (format nil "../../../../duel/lisp/~a.lisp" f) *load-truename*))))
(in-package :duel)
(setf *print-pretty* nil)

(defparameter *taken* (list :base *ichigo-taken* :kessa *kessa-taken*) "Ichigo's damage-taken x by form.")

(defun spec (mv k) (getf (mv-spec mv) k))
(defun dealt (kit dmg taken)
  "One unscaled hit of base DMG from KIT on Ichigo (x TAKEN): base x the form's x *CORE-DAMAGE* x the kit's :core :mult (KIT-ATK-MODS)."
  (round (* dmg (getf (kit-atk-mods kit 0) :mult) taken)))
(defun hits-of (mv)
  "MV's hit windows: ((from to dmg react kb) ...)."
  (loop for w across (mv-hits mv) collect (list (hw-from w) (hw-to w) (hw-dmg w) (hw-react w) (hw-kb w))))
(defun adv-hit (mv)
  "Frame math: the victim's stun for the last hit's reaction minus the frames the move has left after that hit lands on its first
active frame (hitstop freezes both); a knockdown / launch: KD / LAUNCH."
  (let* ((h (car (last (hits-of mv)))) (react (fourth h)) (st (getf *reaction-frames* react 0)))
    (cond ((null h) "—")
          ((member react '(:knockdown :launch)) (if (eq react :launch) "LAUNCH" "KD"))
          (t (format nil "~@d" (- st (- (mv-total mv) (first h))))))))
(defun pstr (mv)
  "The :params a strategy reads (the rest are presentation)."
  (let ((p (mv-params mv)) (out nil))
    (loop for (k v) on p by #'cddr
          unless (member k '(:window))
            do (push (format nil "~(~a~)~@[ ~(~a~)~]" k (if (eq v t) nil v)) out))
    (when (getf p :window) (push (format nil "parry ~{~d~^–~}" (getf p :window)) out))
    (format nil "~{~a~^, ~}" (reverse out))))

(defun row (kit cls mv &optional note)
  (let* ((h (hits-of mv)) (hs (kit-hs-dmg kit)))
    (format t "| ~(~a~) | ~a | ~d/~d/~d (~d) | ~{~a~^ + ~} | ~{~a~^ + ~} | ~{~(~a~)~^, ~} | ~,1f m / ~a° | ~a | ~a | ~a | ~a |~%"
            (mv-name mv) cls (mv-s mv) (mv-a mv) (mv-r mv) (mv-total mv)
            (or (mapcar (lambda (x) (format nil "~d~@[ (f~d)~]" (third x) (and (cdr h) (first x)))) h) '("—"))
            (or (mapcar (lambda (x) (format nil "~d/~d" (dealt kit (third x) (getf *taken* :base)) (dealt kit (third x) (getf *taken* :kessa)))) h) '("—"))
            (or (mapcar (lambda (x) (if (plusp (fifth x)) (format nil "~(~a~) kb ~,1f" (fourth x) (fifth x)) (fourth x))) h) '("—"))
            (mv-reach mv) (or (spec mv :arc) "—")
            (adv-hit mv) (or (mv-adv-block mv) "—")
            (format nil "~@[slide ~,1f ~]~@[armour ~d ~]~@[hs ~a ~]~@[~{~(~a~)~^ ~}~]"
                    (and (plusp (mv-slide mv)) (mv-slide mv)) (and (plusp (mv-armor-hits mv)) (mv-armor-hits mv))
                    (and hs h (format nil "~{~d~^/~}" (mapcar (lambda (x) (hs-by-damage (third x) hs)) h)))
                    (mv-flags mv))
            (concatenate 'string (pstr mv) (if note (format nil "~:[~;; ~]~a" (mv-params mv) note) "")))))

(defun header ()
  (format t "| move | class | S/A/R (total) | base dmg | dealt vs Ichigo Shikai / KESSA | on hit | reach / arc | adv on hit (frame math) | adv on block (data) | slide, armour, hitstop, flags | params |~%")
  (format t "|---|---|---|---|---|---|---|---|---|---|---|~%"))

(defun chain (kit start)
  "START and its :ns-next successors."
  (loop for m = (gethash start (kit-moves kit)) then (mv-ns-next kit m) while m collect m))

(defun form-sheet (form title)
  (let* ((kit (find-kit :kenpachi form)) (core (kit-core kit)) (seen nil))
    (format t "~%## ~a (`~(~s~)`)~%~%" title form)
    (format t "Form x ~,2f, :core :mult ~,2f, *CORE-DAMAGE* ~,2f: a hit deals base x ~,3f (x Ichigo's taken: Shikai ~,2f, KESSA ~,2f, and x the combo scale from hit 4 on, SP / AS hits unscaled). Kikon Konpaku base ~d; :hs-dmg ~a; :as-by-press ~a; :as-writes ~a.~%~%"
            (kit-mult kit) (getf core :mult 1.0) *core-damage* (getf (kit-atk-mods kit 0) :mult)
            (getf *taken* :base) (getf *taken* :kessa) (kit-kikon-konpaku kit) (kit-hs-dmg kit)
            (getf core :as-by-press) (getf core :as-writes '(1 2 3)))
    (header)
    ;; the J string
    (loop for mv = (kit-command-move kit :q) then (kit-next kit (mv-name mv) :q) for i from 1 while mv
          do (row kit (format nil "NA J~d" i) mv) (push mv seen))
    ;; the NS chains, their SAs
    (loop for n in (getf core :ns) for p from 1
          do (loop for mv in (chain kit n) for c across "abcde"
                   do (row kit (format nil "NS~d~c" p c) mv) (push mv seen)
                      (let ((sa (mv-sa-move kit mv))) (when (and sa (not (member sa seen))) (row kit (format nil "SA (ptr ~d)" p) sa) (push sa seen))))
             (let ((land (kit-next kit n :land))) (when land (format t "| | | | | | | | | | | `~(~a~)`'s catch (:land) starts `~(~a~)` |~%" n (mv-name land)))))
    (let ((sa (kit-sa-move kit))) (unless (member sa seen) (row kit "SA (kit)" sa) (push sa seen)))
    ;; the AS entries
    (loop for a in (getf core :as) for i from 1
          do (loop for mv in (chain kit a) for c across "abcde"
                   unless (member mv seen)
                     do (row kit (format nil "AS entry ~d~c" i c) mv) (push mv seen)))))

(format t "# Kenpachi data sheet: generated rows~%~%")
(format t "Generated by `sheet.lisp` from the kit data (`duel/lisp/ken.lisp`, `tuning.lisp`). Frames at 60 Hz; S = startup (the hit lands on frame S),
A active, R recovery. \"dealt\": one hit with no combo scaling, rounded. \"adv on hit\": frame math (*REACTION-FRAMES*: flinch 18, stagger 26,
crumple 40) for a hit on its first active frame, the catalogue measures the real value. \"adv on block\": the data's :adv-block (the core CPU never
guards). Hitstop: the kit's :hs-dmg of the base damage.~%")
(form-sheet :base "Sealed form (the katana)")
(form-sheet :nozarashi "Shikai Nozarashi")
(form-sheet :bankai "Bankai KYORAN (from Shikai pointer 1)")
(form-sheet :bankai-2 "Bankai ZANKAI (from Shikai pointer 2)")
(format t "~%## Kikon Konpaku by pointer (CORE-KIKON-COUNT: base by form, the struck SP's pointer, red = the victim under 30 % Reishi)~%~%")
(format t "| form | base | ptr 1 | ptr 1 red | ptr 2 | ptr 2 red | ptr 3 | ptr 3 red | Soul Break ptr 1 / 2 / 3 |~%|---|---|---|---|---|---|---|---|---|~%")
(dolist (form '(:base :nozarashi :bankai :bankai-2))
  (let ((b (kit-kikon-konpaku (find-kit :kenpachi form))))
    (format t "| ~(~a~) | ~d | ~{~d~^ | ~} | ~{~d~^ / ~} |~%" form b
            (loop for p from 1 to 3 append (list (core-kikon-count b p nil) (core-kikon-count b p t)))
            (loop for p from 1 to 3 collect (core-soul-break-count b p)))))
(finish-output)
(ext:quit 0)

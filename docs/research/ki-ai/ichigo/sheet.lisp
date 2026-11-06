;;;; sheet.lisp — a core-system fighter's data sheet per form, printed as Markdown from the kit (the KI matchup search, step 1:
;;;; skill duel-character-cpu "The order for a style search"; docs/duel/DUEL_MATCHUP_AI.md). Host only, no build:
;;;;   $ECL_HOST --norc --load docs/research/ki-ai/ichigo/sheet.lisp -- ichigo base kessa > docs/research/ki-ai/ichigo/sheet.md
;;;; The core moves come from the kit's :core (core-segments of each :ns / :as, the SA, the segments' own SAs, the waves'
;;;; :kikon-strike) and the NA string from the :q command along the kit's :q strings. Frame math as written in the kit
;;;; (rules.lisp HITSTUN); the sim decides (catalogue.md).
(dolist (f '("package" "math" "hitvol" "input"))
  (load (merge-pathnames (format nil "../../../../engine/lisp/~a.lisp" f) *load-truename*)))
(defpackage :duel (:use :cl :engine))
(defmacro duel::defcine (&rest r) (declare (ignore r)) nil)
(defmacro engine:defcomponent (name &rest slots) `(defstruct (,name (:copier nil) (:predicate nil)) ,@slots))
(dolist (f '("tuning" "rules" "core" "learn" "kit" "yama" "ken" "rukia-ai" "rukia" "ichigo" "endless-rules" "rogue-rules" "run-mods"
             "senjumaru" "barro" "barro-ai" "hisagi" "hisagi-ai"))
  (load (merge-pathnames (format nil "../../../../duel/lisp/~a.lisp" f) *load-truename*)))
(in-package :duel)
(setf *print-pretty* nil)

(defun sh-hw0 (mv) (and (plusp (length (mv-hits mv))) (svref (mv-hits mv) 0)))
(defun sh-stun (hw) (or (hw-stun hw) (hitstun (hw-react hw))))
(defun sh-down-p (react) (member react '(:knockdown :launch)))
(defun sh-hit-adv (mv)
  "His stun - the attacker's frames left after the first hit window lands, nothing following (NIL: he is down / no hit)."
  (let ((w (sh-hw0 mv)))
    (and w (not (sh-down-p (hw-react w))) (- (sh-stun w) (- (mv-total mv) (hw-from w))))))
(defun sh-vol (mv)
  (let* ((w (sh-hw0 mv)) (v (and w (first (hw-vols w)))))
    (cond ((null v) (if (and w (hw-seg w)) "seg" "—"))
          ((= (aref v 0) 1f0) (format nil "line ~,1f–~,1f r~,2f" (aref v 1) (aref v 2) (aref v 4)))
          (t (format nil "arc ~,2f m ~d°" (aref v 1) (round (* 2 (aref v 2) 57.29578)))))))
(defun sh-wave (mv)
  "A move that fires a wave (its :params :speed / :range / :dmg, a hazard): its row note."
  (let ((p (mv-params mv)))
    (when (getf p :speed)
      (format nil "WAVE ~d dmg, ~(~a~), ~,1f m wide, ~d m/s over ~d m~@[, Kikon strike `~(~a~)`~]"
              (getf p :dmg) (getf p :react) (getf p :width) (round (getf p :speed)) (round (getf p :range)) (getf p :kikon-strike)))))
(defun sh-params (mv)
  (let ((p (mv-params mv)))
    (format nil "~{~a~^ ~}"
            (loop for (k v) on p by #'cddr
                  unless (member k '(:look :width :speed :range :dmg :react :kb :guard :kikon-strike))
                    collect (format nil "~(~s~) ~(~a~)" k v)))))
(defun sh-frames (mv)
  (loop for (fr fn) in (mv-on-frame mv) collect (format nil "f~d ~(~a~)" fr fn)))

(defun sh-row (kit tag mv)
  (let* ((w (sh-hw0 mv)) (m (* (kit-mult kit) (getf (kit-core kit) :mult 1.0))))
    (format t "| ~a | `~(~a~)` | ~(~a~) | ~d/~d/~d~@[ e~d~] | ~d | ~a | ~a | ~a | ~a | ~a | ~a | ~a | ~a |~%"
            tag (mv-name mv) (or (kit-class kit mv) "—") (mv-s mv) (mv-a mv) (mv-r mv) (and (plusp (mv-enter mv)) (mv-enter mv))
            (recovery-frames (mv-r mv) nil (and (plusp (mv-whiff mv)) (mv-whiff mv)) (mv-kind mv))
            (if w (format nil "~{~a~^ ~}" (loop for h across (mv-hits mv) collect (format nil "~d–~d:~d" (hw-from h) (1- (hw-to h)) (hw-dmg h))))
                (or (sh-wave mv) "none"))
            (if w (format nil "~d" (round (* m (loop for h across (mv-hits mv) sum (hw-dmg h))))) (if (sh-wave mv) (format nil "~d (wave)" (round (* m (getf (mv-params mv) :dmg)))) "—"))
            (if w (format nil "~(~a~) ~a~@[ kb ~,1f~]" (hw-react w) (if (sh-down-p (hw-react w)) "down" (sh-stun w)) (and (plusp (hw-kb w)) (hw-kb w))) "—")
            (or (sh-hit-adv mv) "—") (or (mv-adv-block mv) "—")
            (format nil "~a~@[ slide ~,1f~]" (sh-vol mv) (and (plusp (mv-slide mv)) (mv-slide mv)))
            (if (member (kit-class kit mv) '(:as :sa)) (format nil "f~d–~d" *armor-from* (1- (mv-s mv))) (if (plusp (mv-armor-hits mv)) (mv-armor-hits mv) "—"))
            (format nil "~a~{ ~a~}" (sh-params mv) (sh-frames mv)))))

(defun sh-na-string (kit)
  (let ((j1 (getf (kit-commands kit) :q)))
    (loop for n = j1 then (loop for (from cmd to) in (kit-strings kit) when (and (eq from n) (eq cmd :q)) return to)
          while n collect n)))

(defun sh-form (ch form)
  (let* ((kit (find-kit ch form)) (core (kit-core kit)) (seen nil))
    (format t "## ~a ~(~a~)~%~%" (kit-name kit) form)
    (format t "| | |~%|---|---|~%| walk / run | ~,1f / ~,1f m/s |~%| Reishi | ~d |~%| x dealt (kit) / core :mult / taken | ~,2f / ~,2f / ~,2f |~%"
            (kit-walk kit) (kit-run kit) (kit-reishi kit) (kit-mult kit) (getf core :mult 1.0) (kit-taken kit))
    (format t "| stun tolerance | ~a |~%| Kikon Konpaku (base) | ~d |~%| awakening | ~:[into ~(~a~)~;this is it~*~] |~%"
            (or (kit-stun-tolerance kit) *stun-tolerance*) (kit-kikon-konpaku kit) (kit-awakening kit) (kit-awaken-form kit))
    (format t "| :as-by-press | ~(~a~) |~%| :ns-range (CPU) | ~(~a~) |~%| stances by pointer | ~(~{~a~^ / ~}~) |~%| Kikon cinematics by pointer | ~(~{~a~^ / ~}~) |~%~%"
            (getf core :as-by-press) (getf core :ns-range) (getf core :stances) (getf core :kikon-cines))
    (format t "| Tag | Move | class | S/A/R | whiff R | hits (frame: base dmg) | dmg x mult | reaction / stun | hit adv | block adv | volume | super armour | params, on-frame |~%|---|---|---|---|---|---|---|---|---|---|---|---|---|~%")
    (flet ((row (tag name) (let ((mv (and name (kit-move kit name))))
                             (when (and mv (not (member mv seen))) (push mv seen) (sh-row kit tag mv)))))
      (loop for n in (sh-na-string kit) for i from 1 do (row (format nil "J~d (NA)" i) n))
      (loop for n in (getf core :ns) for p from 1
            do (loop for m in (core-segments n) for c across "abcdef"
                     do (row (format nil "NS~d~c" p c) m)
                        (let ((sa (getf (mv-params (kit-move kit m)) :sa))) (when sa (row (format nil "SA in NS~d~c's gap" p c) sa)))
                        (let ((ks (getf (mv-params (kit-move kit m)) :kikon-strike))) (when ks (row (format nil "NS~d~c wave Kikon strike" p c) ks)))))
      (row "SA (the kit's)" (getf core :sa))
      (loop for n in (getf core :as) for p from 1
            do (loop for m in (core-segments n) for c across "abcdef"
                     do (row (format nil "AS~d~c" p c) m)
                        (let ((ks (getf (mv-params (kit-move kit m)) :kikon-strike))) (when ks (row (format nil "AS~d~c wave Kikon strike" p c) ks)))))
      (when (getf core :ns)   ; Ichigo's KESSA: the clones' own moves (NS3's free swings and X; the clone hooks scale them)
        (when (and (kit-awakening kit) (eq (kit-character kit) :ichigo)) (dolist (c (quote (:ic-c-light :ic-c-xa :ic-c-xb))) (let ((mv (ignore-errors (find-move c)))) (when mv (sh-row kit "clone (x0.7 / replay x0.1)" mv)))))))
    (format t "~%Kikon / Soul Break Konpaku by pointer (CORE-KIKON-COUNT / CORE-SOUL-BREAK-COUNT, base ~d):~%~%| pointer | Kikon (not red) | Kikon (red) | Soul Break |~%|---|---|---|---|~%"
            (kit-kikon-konpaku kit))
    (loop for p from 1 to 3 do (format t "| ~d | ~d | ~d | ~d |~%" p (core-kikon-count (kit-kikon-konpaku kit) p nil)
                                       (core-kikon-count (kit-kikon-konpaku kit) p t) (core-soul-break-count (kit-kikon-konpaku kit) p)))
    (terpri)))

(let* ((a (mapcar (lambda (s) (intern (string-upcase s) :keyword)) (rest (member "--" ext:*command-args* :test #'string=))))
       (ch (or (first a) :ichigo)) (forms (or (rest a) '(:base :kessa))))
  (format t "<!-- generated by docs/research/ki-ai/ichigo/sheet.lisp -- ~(~a~{ ~a~}~) -->~%~%" ch forms)
  (dolist (form forms) (sh-form ch form))
  (format t "Turn moves (AS / SA) carry super armour from move frame ~d to the end of their startup (DUEL_CORE §2). Dmg x mult = base x kit x core :mult, before combo scaling and the SUBLIMATION factor: the sim's real damage is in catalogue.md.~%~%" *armor-from*)
  (format t "Shared: hitstun by reaction ~(~s~); Kikon follow-up: knockback ~,1f m, reel ~d f, the strike ~d f after a non-red victim could act (KIKON-FOLLOW-WAIT = ~d - S); the hold confirmed ~d f after the hitstop (keyboard / CPU); flash step max ~d, Hoho costs ~d.~%"
          *reaction-frames* *kikon-follow-kb* *kikon-follow-stun* *kikon-follow-gap* (+ *kikon-follow-stun* 1 *kikon-follow-gap*)
          *core-kikon-confirm* (round *fs-max*) (round *fs-hoho*)))
(ext:quit 0)

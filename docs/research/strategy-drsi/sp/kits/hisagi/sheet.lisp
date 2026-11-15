;;;; sheet.lisp — a core-system fighter's data sheet per form, as Markdown tables generated from the kit (PLAN4 step 1, the order of
;;;; DEVLOG §369 / skill duel-character-cpu "The order for a style search"). Host only, no build (the rules test's load list):
;;;;   $ECL_HOST --norc --load docs/research/strategy-drsi/sp/kits/hisagi/sheet.lisp -- hisagi base bankai bankai-bind > .../sheet-data.md
;;;;   (any character: -- kenpachi base nozarashi / -- ichigo base kessa, for the opponents' rows, opp-sheets.md)
;;;; Regenerates docs/research/ki-ai/ichigo/sheet.lisp (2026-11-06, before the SP system) for the SP system: SP cost (KIT-SP-COST), the
;;;; effective startup of a link (S - :enter), every hit window (frame, damage, reaction, stun, dead zone :min-reach, :seg-fn, steal),
;;;; hit / block advantage by frame math, whiff recovery, slide, :on-land pushes. The sim decides: catalogue.md.
(dolist (f '("package" "math" "hitvol" "input" "fuzzy" "layout" "debug-ranges"))
  (load (merge-pathnames (format nil "../../../../../../engine/lisp/~a.lisp" f) *load-truename*) :verbose nil))
(defpackage :duel (:use :cl :engine))
(defmacro duel::defcine (&rest r) (declare (ignore r)) nil)
(defmacro engine:defcomponent (name &rest slots) `(defstruct (,name (:copier nil) (:predicate nil)) ,@slots))
(let ((*standard-output* (make-broadcast-stream)))
  (dolist (f '("tuning" "rules" "core" "sp" "fuzzy" "strategy" "kit" "ken" "ichigo" "hisagi"))
    (load (merge-pathnames (format nil "../../../../../../duel/lisp/~a.lisp" f) *load-truename*) :verbose nil)))
(in-package :duel)
(setf *print-pretty* nil)

(defun sh-stun (hw) (or (hw-stun hw) (hitstun (hw-react hw))))
(defun sh-down-p (react) (member react '(:knockdown :launch)))
(defun sh-s (mv) "Frames from the move's start to its first hit (a link starts at its :enter)." (- (mv-first-hit mv) (mv-enter mv)))
(defun sh-adv (mv hw)
  "Frame math for a hit of window HW on its first frame, nothing following: his stun - the attacker's frames left (S+A+R - from);
DOWN for a knockdown / launch (the wake-up is his: *REACTION-FRAMES* :down 30 + :wakeup 30)."
  (if (sh-down-p (hw-react hw)) "down" (- (sh-stun hw) (- (mv-total mv) (hw-from hw)))))
(defun sh-vol (hw)
  (let ((v (first (hw-vols hw))))
    (cond ((hw-seg hw) (format nil "chain to him (~(~a~))" (hw-seg hw)))
          ((null v) "—")
          ((= (aref v 0) 1f0) (format nil "line ~,2f m r~,2f" (aref v 2) (aref v 4)))
          ((= (aref v 0) 0f0) (format nil "arc ~,2f m ~d°" (aref v 1) (round (* 2 (aref v 2) 57.29578))))
          (t "sph"))))
(defun sh-win (hw)
  (format nil "f~d-~d ~d ~(~a~)~:[ ~d~;~*~]~@[ min ~,1f~]~@[ steal ~d~]~@[ kb ~,1f~]"
          (hw-from hw) (1- (hw-to hw)) (hw-dmg hw) (hw-react hw) (sh-down-p (hw-react hw)) (sh-stun hw)
          (hw-min hw) (hw-steal hw) (and (plusp (hw-kb hw)) (hw-kb hw))))
(defun sh-params (mv)
  (let ((p (mv-params mv)))
    (format nil "~{~a~^ ~}"
            (loop for (k v) on p by #'cddr
                  unless (member k '(:look-as :melee-range :ns-next))
                    collect (format nil "~(~s~)~@[ ~(~a~)~]" k (if (eq v t) nil v))))))

(defun sh-row (kit tag mv)
  (let* ((hits (coerce (mv-hits mv) 'list)) (m (getf (kit-atk-mods kit 0) :mult)) (cost (kit-sp-cost kit mv))
         (h0 (first hits)) (hl (car (last hits))))
    (format t "| ~a | `~(~a~)` | ~(~a~) | ~d/~d/~d~@[ e~d~] | ~d | ~d | ~{~a~^; ~} | ~a | ~a | ~a | ~a | ~a | ~a | ~a |~%"
            tag (mv-name mv) (or (kit-class kit mv) "—") (mv-s mv) (mv-a mv) (mv-r mv) (and (plusp (mv-enter mv)) (mv-enter mv))
            (sh-s mv)
            (recovery-frames (mv-r mv) nil (and (plusp (mv-whiff mv)) (mv-whiff mv)) (mv-kind mv))
            (or (mapcar #'sh-win hits) '("none"))
            (if hits (round (* m (loop for w in hits sum (hw-dmg w)))) "—")
            (if hl (sh-adv mv hl) "—") (or (mv-adv-block mv) "—")
            (if h0 (format nil "~a~@[ (reach ~,2f)~]" (sh-vol h0) (and (not (hw-seg h0)) (mv-reach mv))) "—")
            (format nil "~@[slide ~,1f~]~@[ on-land ~(~a~)~]~@[ on-frame ~(~a~)~]"
                    (and (plusp (mv-slide mv)) (mv-slide mv)) (mv-on-land mv)
                    (and (mv-on-frame mv) (mapcar (lambda (x) (format nil "f~d ~a" (first x) (second x))) (mv-on-frame mv))))
            (if cost (round cost) "free")
            (format nil "~@[~{~(~a~)~^ ~} ~]~a" (mv-flags mv) (sh-params mv)))))

(defun sh-na-string (kit)
  (let ((j1 (getf (kit-commands kit) :q)))
    (loop for n = j1 then (loop for (from cmd to) in (kit-strings kit) when (and (eq from n) (eq cmd :q)) return to)
          while n collect n)))

(defun sh-form (ch form)
  (let* ((kit (find-kit ch form)) (core (kit-core kit)) (seen nil))
    (format t "## ~a ~(~a~)~:[~; (awakened)~]~%~%" (kit-name kit) form (kit-awakening kit))
    (format t "| | |~%|---|---|~%| walk / run | ~,1f / ~,1f m/s |~%| dealt x (kit x *core-damage* x :core :mult) / taken | ~,3f (~,2f x ~,2f x ~,2f) / ~,2f |~%"
            (kit-walk kit) (kit-run kit) (getf (kit-atk-mods kit 0) :mult) (kit-mult kit) *core-damage* (getf core :mult 1.0) (kit-taken kit))
    (format t "| Kikon Konpaku base | ~d |~%| awakening | ~:[into ~(~a~)~;this is it~*~] |~%| :as-by-press / :as-writes | ~(~a~) / ~(~a~) |~%"
            (kit-kikon-konpaku kit) (kit-awakening kit) (kit-awaken-form kit) (getf core :as-by-press) (getf core :as-writes '(1 2 3)))
    (format t "| CPU reads (:ns-range / :range) | ~(~a~) / ~(~a~) |~%| push reach (K ender) | ~a |~%~%"
            (getf core :ns-range) (getf core :range) (kit-push-reach kit))
    (format t "| Tag | Move | class | S/A/R (e = enter) | S eff | whiff R | hit windows (frame dmg reaction stun, min = dead zone m) | dmg x mult | hit adv (last window) | block adv | first volume | motion | SP cost | flags, params |~%")
    (format t "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|~%")
    (flet ((row (tag name) (let ((mv (and name (gethash name (kit-moves kit)))))
                             (when (and mv (not (member mv seen))) (push mv seen) (sh-row kit tag mv)))))
      (loop for n in (sh-na-string kit) for i from 1 do (row (format nil "J~d (NA)" i) n))
      (loop for (from cmd to) in (kit-strings kit)   ; links off the string (the gathered J2 / J3, the SA's J2)
            when (eq cmd :q) do (row (format nil "J link (from `~(~a~)`)" from) from) (row (format nil "J link after `~(~a~)`" from) to))
      (loop for n in (getf core :ns) for p from 1
            do (loop for m in (core-segments n) for c across "abcdef"
                     do (row (format nil "NS~d~c" p c) m)
                        (let ((sa (getf (mv-params (kit-move kit m)) :sa))) (when sa (row (format nil "SA in NS~d~c's gap" p c) sa)))))
      (row "SA (the kit's)" (getf core :sa))
      (loop for n in (getf core :as) for p from 1
            do (loop for m in (core-segments n) for c across "abcdef" do (row (format nil "AS~d~c" p c) m))))
    (format t "~%Kikon / Soul Break Konpaku by pointer (base ~d): ~{~a~^; ~}.~%~%" (kit-kikon-konpaku kit)
            (loop for p from 1 to (min 3 (length (getf core :ns)))
                  collect (format nil "ptr ~d Kikon ~d (red ~d), Soul Break ~d" p (core-kikon-count (kit-kikon-konpaku kit) p nil)
                                  (core-kikon-count (kit-kikon-konpaku kit) p t) (core-soul-break-count (kit-kikon-konpaku kit) p))))))

(let* ((a (mapcar (lambda (s) (intern (string-upcase s) :keyword)) (rest (member "--" ext:*command-args* :test #'string=))))
       (ch (or (first a) :hisagi)) (forms (or (rest a) '(:base :bankai :bankai-bind))))
  (format t "<!-- generated by docs/research/strategy-drsi/sp/kits/hisagi/sheet.lisp -- ~(~a~{ ~a~}~) -->~%~%" ch forms)
  (dolist (form forms) (sh-form ch form))
  (format t "Shared rules (tuning.lisp): stun by reaction ~(~s~); hitstop J ~d / other ~d; whiff R = R + ~d, + ~(~s~) by kind; a block adds ~(~s~); a J link opens on a hit from S+A (on a block only the last ~d f of R).~%~%"
          *reaction-frames* *hitstop-light* *hitstop-heavy* *whiff-extra* *whiff-add* *block-add* *chain-lead*)
  (format t "Turn moves (AS / SA) carry super armour from move frame ~d to the end of their startup (DUEL_CORE §2). Combo scaling: hits 1-~d full, then -~,2f a hit, floor ~,2f; SP and the ranged tip hits unscaled. SP: cost = dmg x ~,1f rounded to 5, ~d-~d; fs max ~d, Hoho ~d (lockout ~d f), J hit +~d, SA hit +~d, an ATK in a cancel +~d, breakthrough takes all above ~d (gain x~,1f). Step ~,1f m / ~d f (iframes ~(~a~)); Hoho ~d f (iframes ~(~a~)), reappears ~,1f m behind.~%"
          *armor-from* *combo-full-hits* *combo-decay* *combo-floor* *sp-cost-rate* (round *sp-cost-min*) (round *sp-cost-max*)
          (round *fs-max*) (round *fs-hoho*) *hoho-lockout* (round *sp-gain-j*) (round *sp-gain-sa*) (round *sp-gain-cancel*)
          (round *fs-cell*) *sp-break-gain* *step-distance* *step-frames* *step-iframes* *hoho-frames* *hoho-iframes* *hoho-distance*))
(ext:quit 0)

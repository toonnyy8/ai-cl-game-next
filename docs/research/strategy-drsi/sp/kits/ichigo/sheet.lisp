;;;; sheet.lisp — a core-system fighter's data sheet per form, printed as Markdown from the kit (PLAN4's kit study, step 1: skill
;;;; duel-character-cpu "The order for a style search"; regenerates docs/research/ki-ai/ichigo/sheet.lisp of 2026-11-06 for the SP system).
;;;; Host only, no build; any core kit and forms:
;;;;   $ECL_HOST --norc --load docs/research/strategy-drsi/sp/kits/ichigo/sheet.lisp -- ichigo base kessa
;;;; The core moves come from the kit's :core (core-segments of each :ns / :as, the SA, the segments' own SAs, the waves' :kikon-strike),
;;;; the NA string from the :q command along the kit's :q strings. Frame math as written in the kit (rules.lisp HITSTUN); the sim decides
;;;; (catalogue.md).
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

(defun sh-hw0 (mv) (and (plusp (length (mv-hits mv))) (svref (mv-hits mv) 0)))
(defun sh-hwl (mv) (and (plusp (length (mv-hits mv))) (svref (mv-hits mv) (1- (length (mv-hits mv))))))
(defun sh-stun (hw) (or (hw-stun hw) (hitstun (hw-react hw))))
(defun sh-down-p (react) (member react '(:knockdown :launch)))
(defun sh-hit-adv (mv)
  "His stun - the attacker's frames left after the LAST hit window lands, nothing following (NIL: he is down / no hit). Hitstop freezes both."
  (let ((w (sh-hwl mv)))
    (and w (not (sh-down-p (hw-react w))) (- (sh-stun w) (- (mv-total mv) (hw-from w))))))
(defun sh-reach (mv)
  "The volume's far edge (m, from his centre) and the min reach: arc r, capsule b; NIL for a :seg-fn / no window."
  (let* ((w (sh-hw0 mv)) (v (and w (first (hw-vols w)))))
    (cond ((null v) nil)
          ((= (aref v 0) 1f0) (aref v 2))
          ((= (aref v 0) 0f0) (aref v 1))
          (t nil))))
(defun sh-vol (mv)
  (let* ((w (sh-hw0 mv)) (v (and w (first (hw-vols w)))))
    (cond ((null v) (if (and w (hw-seg w)) "seg-fn (chain)" "—"))
          ((= (aref v 0) 1f0) (format nil "line ~,1f–~,1f r~,2f" (aref v 1) (aref v 2) (aref v 4)))
          ((= (aref v 0) 0f0) (format nil "arc ~,2f m ~d°" (aref v 1) (round (* 2 (aref v 2) 57.29578))))
          (t (format nil "vol ~d" (round (aref v 0)))))))
(defun sh-eff (mv)
  "Touch distance (centre to centre) without the slide: far edge + a 0.35 m hurt radius; with the slide added."
  (let ((r (sh-reach mv)))
    (if r (format nil "~,2f~@[ / ~,2f~]" (+ r 0.35) (and (plusp (mv-slide mv)) (+ r 0.35 (mv-slide mv)))) "—")))
(defun sh-wave (mv)
  (let ((p (mv-params mv)))
    (when (getf p :speed)
      (format nil "WAVE ~d ~(~a~), ~,1f m wide, ~d m/s over ~d m~@[, Kikon strike `~(~a~)`~]"
              (getf p :dmg) (getf p :react) (getf p :width) (round (getf p :speed)) (round (getf p :range)) (getf p :kikon-strike)))))
(defun sh-params (mv)
  (let ((p (mv-params mv)))
    (format nil "~{~a~^ ~}"
            (loop for (k v) on p by #'cddr
                  unless (member k '(:look :width :speed :range :dmg :react :kb :guard :kikon-strike :ns-next :sa))
                    collect (format nil "~(~s~) ~(~a~)" k v)))))
(defun sh-frames (mv) (loop for (fr fn) in (mv-on-frame mv) collect (format nil "f~d ~(~a~)" fr fn)))
(defun sh-mult (kit) "Base -> dealt, before his taken x: kit x core :mult x *CORE-DAMAGE* (0.42: every core kit, KIT-ATK-MODS)." (* (kit-mult kit) (getf (kit-core kit) :mult 1.0) (if (kit-core kit) *core-damage* 1.0)))

(defun sh-row (kit tag mv)
  (let* ((w (sh-hw0 mv)) (wl (sh-hwl mv)) (m (sh-mult kit)) (cost (kit-sp-cost kit mv))
         (steal (or (and w (hw-steal w)) (getf (mv-params mv) :steal-fs))))
    (format t "| ~a | `~(~a~)` | ~(~a~) | ~d/~d/~d~@[ (enters f~d)~] | ~d / ~d | ~a | ~a | ~a | ~a | ~a | ~a | ~a | ~a | ~a | ~a | ~a |~%"
            tag (mv-name mv) (or (kit-class kit mv) "—") (- (mv-s mv) (mv-enter mv)) (mv-a mv) (mv-r mv) (and (plusp (mv-enter mv)) (mv-enter mv))
            (- (mv-total mv) (mv-enter mv))
            (- (+ (mv-s mv) (mv-a mv) (recovery-frames (mv-r mv) nil (and (plusp (mv-whiff mv)) (mv-whiff mv)) (mv-kind mv))) (mv-enter mv))
            (if w (format nil "~{~a~^ ~}" (loop for h across (mv-hits mv) collect (format nil "~d–~d:~d" (hw-from h) (1- (hw-to h)) (hw-dmg h))))
                (or (sh-wave mv) "none"))
            (if w (format nil "~d" (round (* m (loop for h across (mv-hits mv) sum (hw-dmg h)))))
                (if (sh-wave mv) (format nil "~d (wave)" (round (* m (getf (mv-params mv) :dmg)))) "—"))
            (if w (format nil "~(~a~) ~a~@[ kb ~,1f~]" (hw-react wl) (if (sh-down-p (hw-react wl)) "down" (sh-stun wl)) (and (plusp (hw-kb wl)) (hw-kb wl))) "—")
            (or (sh-hit-adv mv) "—") (or (mv-adv-block mv) "—")
            (format nil "~a~@[ min ~,1f~]" (sh-vol mv) (and w (hw-min w)))
            (sh-eff mv) (if (plusp (mv-slide mv)) (format nil "~,1f" (mv-slide mv)) "—")
            (if (member (kit-class kit mv) '(:as :sa)) (format nil "f~d–~d" *armor-from* (1- (mv-s mv))) (if (plusp (mv-armor-hits mv)) (mv-armor-hits mv) "—"))
            (if cost (round cost) "—") (or steal "—")
            (format nil "~a~{ ~a~}" (sh-params mv) (sh-frames mv)))))

(defun sh-na-string (kit)
  (let ((j1 (getf (kit-commands kit) :q)))
    (loop for n = j1 then (loop for (from cmd to) in (kit-strings kit) when (and (eq from n) (eq cmd :q)) return to)
          while n collect n)))

(defun sh-route-cost (kit name)
  (round (loop for m in (core-segments name) for mv = (kit-move kit m) sum (or (kit-sp-cost kit mv) 0))))

(defun sh-form (ch form)
  (let* ((kit (find-kit ch form)) (core (kit-core kit)) (seen nil))
    (format t "## ~a ~(~a~)~%~%" (kit-name kit) form)
    (format t "| | |~%|---|---|~%| walk / run | ~,1f / ~,1f m/s |~%| Reishi | ~d |~%| x dealt (kit) / core :mult / taken | ~,2f / ~,2f / ~,2f |~%"
            (kit-walk kit) (kit-run kit) (kit-reishi kit) (kit-mult kit) (getf core :mult 1.0) (kit-taken kit))
    (format t "| stun tolerance | ~a |~%| Kikon Konpaku (base) | ~d |~%| awakening | ~:[into ~(~a~)~;this is it~*~] |~%| passives | ~(~a~) |~%"
            (or (kit-stun-tolerance kit) *stun-tolerance*) (kit-kikon-konpaku kit) (kit-awakening kit) (kit-awaken-form kit) (kit-passives kit))
    (format t "| :as-by-press | ~(~a~) |~%| :ns-range (CPU) | ~(~a~) |~%| stances by pointer | ~(~{~a~^ / ~}~) |~%| Kikon cinematics by pointer | ~(~{~a~^ / ~}~) |~%"
            (getf core :as-by-press) (getf core :ns-range) (getf core :stances) (getf core :kikon-cines))
    (format t "| SP route totals NS1 / NS2 / NS3 | ~{~d~^ / ~} |~%| SP route totals AS1 / AS2 / AS3 | ~{~d~^ / ~} |~%~%"
            (mapcar (lambda (n) (sh-route-cost kit n)) (getf core :ns)) (mapcar (lambda (n) (sh-route-cost kit n)) (getf core :as)))
    (format t "| Tag | Move | class | S/A/R | total hit / whiff | hits (frame: base dmg) | dmg x mult | last reaction / stun | hit adv | block adv | volume | touch d (/ + slide) | slide | super armour | SP cost | steal | params, on-frame |~%|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|~%")
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
      (when (and (kit-awakening kit) (eq (kit-character kit) :ichigo))   ; KESSA's clone cuts (NS3 / AS3 summons; x0.7, a replay x0.1)
        (dolist (c '(:ic-c-light :ic-c-xa :ic-c-xb))
          (let ((mv (ignore-errors (find-move c)))) (when mv (sh-row kit "clone cut" mv))))))
    (format t "~%Kikon / Soul Break Konpaku by pointer (CORE-KIKON-COUNT / CORE-SOUL-BREAK-COUNT, base ~d):~%~%| pointer | Kikon (not red) | Kikon (red) | Soul Break |~%|---|---|---|---|~%"
            (kit-kikon-konpaku kit))
    (loop for p from 1 to 3 do (format t "| ~d | ~d | ~d | ~d |~%" p (core-kikon-count (kit-kikon-konpaku kit) p nil)
                                       (core-kikon-count (kit-kikon-konpaku kit) p t) (core-soul-break-count (kit-kikon-konpaku kit) p)))
    (terpri)))

(let* ((a (mapcar (lambda (s) (intern (string-upcase s) :keyword)) (rest (member "--" ext:*command-args* :test #'string=))))
       (ch (or (first a) :ichigo)) (forms (or (rest a) '(:base :kessa))))
  (format t "<!-- generated by docs/research/strategy-drsi/sp/kits/ichigo/sheet.lisp -- ~(~a~{ ~a~}~) -->~%~%" ch forms)
  (dolist (form forms) (sh-form ch form))
  (format t "Columns: S = startup from the move's entry frame (a string link may enter its clip late, (enters f6): its hit frames stay in clip frames); total = S + A + R from the entry frame (a hit / a whiff: R + `*whiff-extra*` + kind's `*whiff-add*`); hit adv = the last window's stun - the frames he has left after it (nothing following, hitstop freezes both); touch d = the volume's far edge + 0.35 m (the default hurt radius), then + the move's slide; super armour = a turn move (AS / SA) from move frame ~d to the end of its startup (DUEL_CORE §2). Dmg x mult = base x kit x core :mult x `*core-damage*` (~,2f), before his taken x, combo scaling, the SP shortfall scale and SUBLIMATION (the sim's damage: catalogue.md).~%~%" *armor-from* *core-damage*)
  (format t "## Shared rules (tuning.lisp, read at generation)~%~%| Rule | Value |~%|---|---|~%")
  (format t "| hitstun by reaction | ~(~s~) |~%| counter-hit stun | +~d |~%| hitstop light / heavy / block | ~d / ~d / ~d |~%" *reaction-frames* *counter-stun* *hitstop-light* *hitstop-heavy* *hitstop-block*)
  (format t "| whiff recovery | R + ~d, + ~(~s~) by kind |~%| input buffer | ~d f |~%" *whiff-extra* *whiff-add* *input-buffer*)
  (format t "| Step | ~,1f m over ~d f, invulnerable f~{~d~^–~}, J cancels it from f~d |~%" *step-distance* *step-frames* *step-iframes* *step-j-cancel*)
  (format t "| Hoho | ~d SP (flash step), ~d f, invulnerable f~{~d~^–~}, reappears f~d ~,1f m behind him; perfect = counter swing f~d, strike f~d; lockout ~d f; resumes a combo within ~d f; never while an exchange is open (DUEL_CORE §2.1.2) |~%"
          (round *fs-hoho*) *hoho-frames* *hoho-iframes* *hoho-appear* *hoho-distance* *hoho-counter-pose* *hoho-counter-strike* *hoho-lockout* *hoho-resume-frames*)
  (format t "| flash-step (SP) gauge | 0–~d, cells of ~d; regen ~,1f/s after ~d f only below one cell; taken x~,3f of damage |~%" (round *fs-max*) (round *fs-cell*) *fs-regen* *fs-delay* *fs-taken*)
  (format t "| SP gains | J hit +~d, SA hit +~d, J / SA in a cancel +~d; NS / AS / Kikon 0 |~%| SP cost rule | dmg x ~,1f rounded to 5, ~d–~d; paid at the segment start; refunded if the segment takes part in a cancel; short: damage x (0.5 + 0.5 paid / cost); a later NS segment refused at 0 (NSa and every AS start at 0) |~%"
          (round *sp-gain-j*) (round *sp-gain-sa*) (round *sp-gain-cancel*) *sp-cost-rate* (round *sp-cost-min*) (round *sp-cost-max*))
  (format t "| breakthrough | the first real hit in an exchange takes ~d % of the victim's SP above ~d, the attacker gains ~d % of it |~%| AS1 steal | per hit, may take the last cell, attacker gains ~d % |~%"
          (round (* 100 *sp-break-share*)) (round *fs-cell*) (round (* 100 *sp-break-gain*)) (round (* 100 *steal-fs-gain*)))
  (format t "| Burst | needs ~d SP; WHITE (neutral) / BLUE (reeling after hit ~d) / ORANGE (in a move that hit); push ~,1f m, invulnerable ~d f; drain ~d/s (BLUE burns one cell); SP attacks free while it runs; ORANGE cuts the next move's startup by ~d % for ~d f |~%"
          (round *fs-burst*) *burst-min-hits* *burst-push* *burst-invuln* (round *burst-drain*) (round (* 100 *chain-cut*)) *chain-window*)
  (format t "| awakening | gauge ~d: x~,3f dealt, x~,3f taken, ~,1f a Konpaku lost; heals ~d % Reishi |~%" (round *awaken-max*) *awaken-dealt* *awaken-taken* *awaken-per-konpaku* (round (* 100 *awaken-heal*)))
  (format t "| Kikon follow-up | hold confirmed ~d f after the hitstop; knockback ~,1f m, reel ~d f, the strike ~d f after a non-red victim could act; a non-red victim's attack cancels it |~%"
          *core-kikon-confirm* *kikon-follow-kb* *kikon-follow-stun* *kikon-follow-gap*)
  (format t "| pointer | 1–~d, Kikon max ~d, Soul Break max ~d |~%| arena radius | ~,1f m |~%" *core-pointer-max* *core-kikon-max* *core-soul-break-max* *arena-radius*))
(ext:quit 0)

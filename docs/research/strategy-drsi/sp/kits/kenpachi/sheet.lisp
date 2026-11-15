;;;; sheet.lisp — Kenpachi's data sheet for PLAN4's kit study (docs/research/strategy-drsi/sp/PLAN4.md "The arms come from each
;;;; fighter's kit", step 1), generated from the kit data on the host, the way tests/duel-rules-test.lisp loads it (plain CL, no engine):
;;;;   $ECL_HOST --norc --load docs/research/strategy-drsi/sp/kits/kenpachi/sheet.lisp | grep -v "^;;; Loading"   (pasted under sheet.md's line)
;;;;   ... sheet.lisp -- opp | grep -v "^;;; Loading" > docs/research/strategy-drsi/sp/kits/kenpachi/opp-data.md   (Ichigo's / Hisagi's rows)
;;;; Regenerated from docs/research/ki-ai/kenpachi/sheet.lisp (2026-11-06, before the SP system): walks each form's :core (the J string from
;;;; :commands :q through :strings, each pointer's NS chain by :ns-next, each segment's SA, the AS entries and their chains), never the
;;;; kit's whole move table (the base still holds the old unreachable grid / K / SP moves). New columns: hit windows, dealt per victim
;;;; form, the far edge and dead zone, the whiff recovery, the SP cost (KIT-SP-COST, DUEL_SP §4).
(dolist (f '("package" "math" "hitvol" "input" "fuzzy" "layout" "debug-ranges"))
  (load (merge-pathnames (format nil "../../../../../../engine/lisp/~a.lisp" f) *load-truename*) :verbose nil))
(defpackage :duel (:use :cl :engine))
(defmacro duel::defcine (&rest r) (declare (ignore r)) nil)
(defmacro engine:defcomponent (name &rest slots) `(defstruct (,name (:copier nil) (:predicate nil)) ,@slots))
(let ((*standard-output* (make-broadcast-stream)))
  (dolist (f '("tuning" "rules" "core" "sp" "fuzzy" "strategy" "kit" "ken" "ichigo" "hisagi"))
    (load (merge-pathnames (format nil "../../../../../../duel/lisp/~a.lisp" f) *load-truename*))))
(in-package :duel)
(setf *print-pretty* nil)

(defparameter *victims* '((:ichigo :base "I") (:ichigo :kessa "IK") (:hisagi :base "H") (:hisagi :bankai "Hr") (:hisagi :bankai-bind "Hb"))
  "The victim forms a hit's dealt column is computed for (their :taken).")
(defparameter *kenpachi-forms* '((:base "Sealed form (the katana)") (:nozarashi "Shikai NOZARASHI")
                                 (:bankai "Bankai KYORAN (from Shikai pointer 1)") (:bankai-2 "Bankai ZANKAI (from Shikai pointer 2)")))
(defparameter *opp-forms* '((:ichigo :base "Ichigo, Shikai") (:ichigo :kessa "Ichigo, KESSA (Bankai)")
                            (:hisagi :base "Hisagi, Shikai") (:hisagi :bankai "Hisagi, Bankai ranged") (:hisagi :bankai-bind "Hisagi, Bankai bind")))

(defun spec (mv k) (getf (mv-spec mv) k))
(defun dealt (kit dmg taken) "One unscaled hit of base DMG from KIT on a victim taking x TAKEN (KIT-ATK-MODS :mult: form x core-damage x :core :mult)."
  (round (* dmg (getf (kit-atk-mods kit 0) :mult) taken)))
(defun hits-of (mv) (loop for w across (mv-hits mv) collect w))
(defun adv-hit (mv)
  "Frame math: the victim's stun for the last hit's reaction minus the frames the move has left after that hit's first active frame
(hitstop freezes both); a knockdown / launch: KD / LAUNCH (the catalogue measures it)."
  (let* ((h (car (last (hits-of mv)))))
    (if (null h) "—"
        (let ((react (hw-react h)))
          (if (member react '(:knockdown :launch)) (if (eq react :launch) "LAUNCH" "KD")
              (format nil "~@d" (- (or (hw-stun h) (getf *reaction-frames* react 0)) (- (mv-total mv) (hw-from h)))))))))
(defun pstr (mv)
  "The :params a strategy reads."
  (let ((p (mv-params mv)) (out nil))
    (loop for (k v) on p by #'cddr unless (member k '(:window)) do (push (format nil "~(~a~)~@[ ~(~a~)~]" k (if (eq v t) nil v)) out))
    (when (getf p :window) (push (format nil "parry ~{~d~^–~}" (getf p :window)) out))
    (format nil "~{~a~^, ~}" (reverse out))))
(defun wins (mv)
  "Each hit window: from-to dmg react (kb)."
  (or (loop for w in (hits-of mv)
            collect (format nil "~d-~d ~d ~(~a~)~@[ kb~,1f~]~@[ min~,1f~]" (hw-from w) (hw-to w) (hw-dmg w) (hw-react w)
                            (and (plusp (hw-kb w)) (hw-kb w)) (hw-min w)))
      '("— (no hit)")))

(defun row (kit cls mv)
  (let* ((h (hits-of mv)) (tot (reduce #'+ h :key #'hw-dmg)) (cost (kit-sp-cost kit mv)))
    (format t "| ~(~a~) | ~a | ~d/~d/~d (~d; whiff R ~d) | ~{~a~^; ~} | ~{~a~^ / ~} | ~,2f / ~,2f m, ~a° | ~,1f | ~a | ~a | ~a | ~a | ~a |~%"
            (mv-name mv) cls (mv-s mv) (mv-a mv) (mv-r mv) (mv-total mv) (mv-whiff mv)
            (wins mv)
            (loop for (c f) in *victims* collect (dealt kit tot (kit-taken (find-kit c f))))
            (mv-reach mv) (move-edge mv) (or (spec mv :arc) (if (spec mv :vol) (format nil "vol ~(~a~)" (first (spec mv :vol))) "90"))
            (mv-slide mv)
            (adv-hit mv) (or (mv-adv-block mv) "—")
            (format nil "~@[armour ~d ~]~@[hs ~{~d~^/~} ~]~@[~{~(~a~)~^ ~}~]"
                    (and (plusp (mv-armor-hits mv)) (mv-armor-hits mv))
                    (and h (mapcar #'hw-hs h)) (mv-flags mv))
            (if cost (round cost) "—")
            (pstr mv))))

(defun header ()
  (format t "| move | class | S/A/R (total; whiff R) | hit windows (from-to base react) | dealt (sum, unscaled) vs ~{~a~^ / ~} | reach / edge, arc | slide | adv on hit (math) | adv on block | armour, hitstop, flags | SP cost | params |~%"
          (mapcar #'third *victims*))
  (format t "|---|---|---|---|---|---|---|---|---|---|---|---|~%"))

(defun chain (kit start) (loop for m = (gethash start (kit-moves kit)) then (mv-ns-next kit m) while m collect m))

(defun form-sheet (char form title)
  (let* ((kit (find-kit char form)) (core (kit-core kit)) (seen nil))
    (format t "~%## ~a (`~(~s ~s~)`)~%~%" title char form)
    (format t "Form x ~,2f, :core :mult ~,2f, *CORE-DAMAGE* ~,2f: a hit deals base x ~,3f (x the victim's :taken, x the combo scale from hit 4, SP hits unscaled). Taken x ~,2f; walk ~,1f / run ~,1f m/s; stun tolerance ~a; Kikon Konpaku base ~d; :hs-dmg ~a; :as-by-press ~a; :as-writes ~a; :sp-cost-mult ~a; passives ~(~a~).~%~%"
            (kit-mult kit) (getf core :mult 1.0) *core-damage* (getf (kit-atk-mods kit 0) :mult) (kit-taken kit)
            (kit-walk kit) (kit-run kit) (kit-stun-tolerance kit) (kit-kikon-konpaku kit) (kit-hs-dmg kit)
            (getf core :as-by-press '(1 2 3)) (getf core :as-writes '(1 2 3)) (getf core :sp-cost-mult 1.0) (kit-passives kit))
    (header)
    (loop for mv = (kit-command-move kit :q) then (kit-next kit (mv-name mv) :q) for i from 1 while (and mv (not (member mv seen)))
          do (row kit (format nil "NA J~d" i) mv) (push mv seen))
    (loop for n in (getf core :ns) for p from 1
          do (loop for mv in (chain kit n) for c across "abcdefg"
                   do (row kit (format nil "NS~d~c" p c) mv) (push mv seen)
                      (let ((sa (mv-sa-move kit mv))) (when (and sa (not (member sa seen))) (row kit (format nil "SA (ptr ~d)" p) sa) (push sa seen))))
             (let ((land (kit-next kit n :land))) (when land (format t "| | | | | | | | | | | | `~(~a~)`'s catch (:land) starts `~(~a~)` |~%" n (mv-name land)))))
    (let ((sa (kit-sa-move kit))) (when (and sa (not (member sa seen))) (row kit "SA (kit)" sa) (push sa seen)))
    (loop for a in (getf core :as) for i from 1
          do (loop for mv in (chain kit a) for c across "abcdefg"
                   unless (member mv seen)
                     do (row kit (format nil "AS entry ~d~c" i c) mv) (push mv seen)))))

(if (equal (car (last ext:*command-args*)) "opp")
    (progn
      (format t "# Opponents' rows (Ichigo, Hisagi) for Kenpachi's matchup tables~%~%Generated by `sheet.lisp -- opp` from the kits (same columns as `sheet-data.md`; the dealt column is these attackers' hits on each victim form, Kenpachi's forms take x 1.0). Their own studies hold their full sheets.~%")
      (loop for (c f title) in *opp-forms* do (form-sheet c f title)))
    (progn
      (format t "# Kenpachi data sheet: generated rows~%~%Generated by `sheet.lisp` from the kit data (`duel/lisp/ken.lisp`, `tuning.lisp`, `sp.lisp`). Frames at 60 Hz; S = startup (the hit lands on frame S),
A active, R recovery; whiff R = recovery after a whiff. \"dealt\": the move's summed base damage x the form's multipliers x the victim form's :taken, no combo scaling.
\"adv on hit\": frame math (*REACTION-FRAMES*: flinch 18, stagger 26, crumple 40) for the last hit on its first active frame; the catalogue measures the real value.
\"adv on block\": the data's :adv-block (a core kit never guards: unread). edge = reach + a capsule's radius (MOVE-EDGE). SP cost: KIT-SP-COST (DUEL_SP §4, x the form's :sp-cost-mult).~%")
      (loop for (f title) in *kenpachi-forms* do (form-sheet :kenpachi f title))
      (format t "~%## Kikon Konpaku by pointer (CORE-KIKON-COUNT: base by form, the struck SP's pointer, red = the victim under 30 % Reishi)~%~%")
      (format t "| form | base | ptr 1 | ptr 1 red | ptr 2 | ptr 2 red | ptr 3 | ptr 3 red | Soul Break ptr 1 / 2 / 3 |~%|---|---|---|---|---|---|---|---|---|~%")
      (dolist (form '(:base :nozarashi :bankai :bankai-2))
        (let ((b (kit-kikon-konpaku (find-kit :kenpachi form))))
          (format t "| ~(~a~) | ~d | ~{~d~^ | ~} | ~{~d~^ / ~} |~%" form b
                  (loop for p from 1 to 3 append (list (core-kikon-count b p nil) (core-kikon-count b p t)))
                  (loop for p from 1 to 3 collect (core-soul-break-count b p)))))
      (format t "~%## Shared movement and resource rules (tuning.lisp)~%~%")
      (format t "| rule | value |~%|---|---|~%")
      (format t "| Step | ~,1f m over ~d f, invulnerable ~{~d~^-~}, J cancel from f~d |~%" *step-distance* *step-frames* *step-iframes* *step-j-cancel*)
      (format t "| Hoho | ~d flash-step, ~d f, invulnerable ~{~d~^-~}, reappears ~,1f m behind him on f~d, lockout ~d f; perfect = his hit volume within ~d f: counter ~d dmg, stun ~d, his input locked ~d f; refused while an exchange is undecided (DUEL_CORE §2.1.2) |~%"
              (round *fs-hoho*) *hoho-frames* *hoho-iframes* *hoho-distance* *hoho-appear* *hoho-lockout* *perfect-lead* *perfect-counter-damage* *perfect-counter-stun* *perfect-lock*)
      (format t "| Flash-step gauge | 0-~d (cells of ~d), regen ~,1f / s after ~d f only below one cell; a J hit +10, an SA hit +15, a J / SA in a cancel +30 (DUEL_SP §5); a breakthrough takes ~d % above the last cell, gains ~d % |~%"
              (round *fs-max*) (round *fs-cell*) *fs-regen* *fs-delay* (round (* 100 *sp-break-share*)) (round (* 100 *sp-break-gain*)))
      (format t "| Burst | needs ~d flash-step; pushes the attacker ~,1f m over ~d f, invulnerable ~d f; drains ~d / s; SP attacks free during it |~%"
              (round *fs-burst*) *burst-push* *burst-push-frames* *burst-invuln* (round *burst-drain*))
      (format t "| Combo scale | hits 1-~d full, then -~d % a hit, floor ~d % (SP / AS hits unscaled); ~d launch, ~d air hits a combo |~%"
              *combo-full-hits* (round (* 100 *combo-decay*)) (round (* 100 *combo-floor*)) *combo-launches* *combo-air-hits*)
      (format t "| Kikon | hold the SP from its segment's start to its hit + ~d f confirm; the victim is knocked ~,1f m, the strike follows |~%" *core-kikon-confirm* *kikon-follow-kb*)
      (format t "| Awakening | gauge ~d: +~,3f / dealt, +~,3f / taken, +~,1f / Konpaku lost; heals ~d % Reishi; once a match |~%"
              (round *awaken-max*) *awaken-dealt* *awaken-taken* *awaken-per-konpaku* (round (* 100 *awaken-heal*)))
      (format t "| Kenpachi | walk ~,1f, run ~,1f m/s; stun tolerance 26; the Bankai's NS / AS segments burn ~d of his own Reishi (floor 1) |~%"
              *walk-kenpachi* *run-kenpachi* *ken-bk-cost*)))
(finish-output)
(ext:quit 0)

;;;; duel-rules-test.lisp — checks SOUL DUEL's pure rules (duel/lisp/rules.lisp) and its kit data
;;;; (kit.lisp + yama.lisp + ken.lisp) on the host, no browser, no build; the checks are in tests/duel-rules/*.lisp:
;;;;   $ECL_HOST --norc --load tests/duel-rules-test.lisp
;;;; The files are plain Common Lisp over the engine's plain-CL math, hit volumes and vpad, so they
;;;; load here after engine/lisp/{package,math,hitvol,input}.lisp.
(dolist (f '("package" "math" "hitvol" "input"))
  (load (merge-pathnames (format nil "../engine/lisp/~a.lisp" f) *load-truename*)))
(defpackage :duel (:use :cl :engine))
;; the character files also hold their hook functions and cinematics: those need the engine, so the
;; host skips the cinematics (a no-op DEFCINE) and never calls a hook; their state components (DEFCOMPONENT) are
;; plain structs here (no entities: the tests make them with MAKE-...)
(defmacro duel::defcine (&rest r) (declare (ignore r)) nil)
(defmacro engine:defcomponent (name &rest slots) `(defstruct (,name (:copier nil) (:predicate nil)) ,@slots))
(dolist (f '("tuning" "rules" "learn" "kit" "yama" "ken" "rukia" "ichigo" "endless-rules" "rogue-rules" "run-mods" "senjumaru" "barro" "barro-ai" "hisagi" "hisagi-ai"))
  (load (merge-pathnames (format nil "../duel/lisp/~a.lisp" f) *load-truename*)))
;; the checks live in tests/duel-rules/*.lisp, loaded in order into this one image (CHECK, *CHECKS* and the shared helpers are in core)
(dolist (f '("core" "yama" "ken" "rukia" "senjumaru" "art" "systems" "barro" "sim" "hisagi" "rogue" "runmods"))
  (load (merge-pathnames (format nil "duel-rules/~a.lisp" f) *load-truename*)))
(in-package :duel)

(format t "duel-rules-test: ~d checks, ~a~%" *checks*
        (if (zerop *fails*) "ALL PASS" (format nil "~d FAILED" *fails*)))
(ext:quit (if (zerop *fails*) 0 1))

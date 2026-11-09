;;;; check.lisp — the library refactor's proof (DUEL_AI_STRATEGY §10): the inline library (OLD, e.g. `git show <commit>:duel/lisp/strategy.lisp`)
;;;; and the unit library (duel/lisp/strategy.lisp) expanded give the same strategies, entry by entry:
;;;;   - every entry: the same :ID, in the same order;
;;;;   - a plain strategy: the same keys with EQUAL values (its :P priors included: the strategy layer reads them);
;;;;   - a Q table: :RULES EQUAL (every antecedent and q), :GROUPS and its other keys EQUAL, the same FQ-CHECKSUM (a player's saved online copy
;;;;     stays valid), and each arm the same behaviour: the same keys and EQUAL values but :ID, :APPLY and :BASE's :P (a strategy-layer prior:
;;;;     STRAT-PRIOR reads it only on library entries, never on a table's arms);
;;;;   - a composite: the same antecedents and each sub the same behaviour as above.
;;;; usage (repo root): $ECL_HOST --norc --load docs/research/strategy-drsi/fq/switch/library/check.lisp -- OLD.lisp
(dolist (f '("package" "math" "hitvol" "input")) (load (format nil "engine/lisp/~a.lisp" f)))
(defpackage :duel (:use :cl :engine))
(in-package :duel)
(load "duel/lisp/tuning.lisp") (load "duel/lisp/fuzzy.lisp")
(load (second (member "--" ext:*command-args* :test #'string=)))
(defparameter *old-library* (copy-tree *strat-library*))
(load "duel/lisp/strategy.lisp")
(defvar *bad* 0)
(defun bad (fmt &rest args) (incf *bad*) (apply #'format t (concatenate 'string "check: " fmt "~%") args))
(defun pkeys (pl) (loop for (k) on pl by #'cddr collect k))
(defun same-plist (a b skip)
  "A and B the same plist but for the keys in SKIP, values EQUAL (:BASE without :P when :P is in SKIP)."
  (let ((ka (sort (set-difference (pkeys a) skip) #'string< :key #'symbol-name))
        (kb (sort (set-difference (pkeys b) skip) #'string< :key #'symbol-name)))
    (and (equal ka kb)
         (every (lambda (k)
                  (if (and (eq k :base) (member :p skip))
                      (equal (loop for (x y) on (getf a k) by #'cddr unless (eq x :p) append (list x y))
                             (loop for (x y) on (getf b k) by #'cddr unless (eq x :p) append (list x y)))
                      (equal (getf a k) (getf b k))))
                ka))))
(defun same-arm (a b)
  (or (and (null a) (null b))
      (and a b (let ((a2 (if (and (getf a :base) (null (loop for (x) on (getf a :base) by #'cddr unless (eq x :p) collect x))) (loop for (k v) on a by #'cddr unless (eq k :base) append (list k v)) a))
                     (b2 (if (and (getf b :base) (null (loop for (x) on (getf b :base) by #'cddr unless (eq x :p) collect x))) (loop for (k v) on b by #'cddr unless (eq k :base) append (list k v)) b)))
                 (same-plist a2 b2 '(:id :apply :p))))))
(unless (= (length *old-library*) (length *strat-library*)) (bad "~d entries, was ~d" (length *strat-library*) (length *old-library*)))
(loop for o in *old-library* for n in *strat-library*
      for id = (getf o :id)
      do (cond ((not (eq id (getf n :id))) (bad "entry ~s became ~s" id (getf n :id)))
               ((getf o :fq)
                (let ((fo (getf o :fq)) (fn (getf n :fq)))
                  (unless (equal (getf fo :rules) (getf fn :rules)) (bad "~s: rules differ" id))
                  (unless (= (fq-checksum fo) (fq-checksum fn)) (bad "~s: checksum ~d, was ~d" id (fq-checksum fn) (fq-checksum fo)))
                  (unless (same-plist fo fn '(:arms :rules)) (bad "~s: table keys differ ~s / ~s" id (pkeys fo) (pkeys fn)))
                  (unless (= (length (getf fo :arms)) (length (getf fn :arms))) (bad "~s: arm count" id))
                  (loop for a in (getf fo :arms) for b in (getf fn :arms) for k from 0
                        unless (same-arm a b) do (bad "~s: arm ~d ~s plays differently from ~s" id k (getf b :id) (getf a :id)))
                  (unless (same-plist o n '(:fq)) (bad "~s: entry keys differ" id))))
               ((getf o :switch)
                (loop for a in (getf o :switch) for b in (getf n :switch)
                      unless (and (equal (car a) (car b)) (same-arm (cdr a) (cdr b))) do (bad "~s: a :switch entry differs" id))
                (unless (same-arm (getf o :else) (getf n :else)) (bad "~s: :else differs" id))
                (unless (same-plist o n '(:switch :else)) (bad "~s: composite keys differ" id)))
               (t (unless (same-plist o n '()) (bad "~s: strategy differs ~s / ~s" id o n)))))
(format t "check: ~d entries, ~d tables, ~d problems; checksums ~{~a~^ ~}~%" (length *strat-library*)
        (count-if (lambda (e) (getf e :fq)) *strat-library*) *bad*
        (loop for e in *strat-library* when (getf e :fq) collect (format nil "~(~a~)=~d" (getf e :id) (fq-checksum (getf e :fq)))))
(ext:quit (if (zerop *bad*) 0 1))

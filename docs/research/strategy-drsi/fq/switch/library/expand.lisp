(defun strat-unit-find (id units)
  "The unit ID in UNITS (a list of plists keyed :ID), or an error naming it."
  (or (find id units :key (lambda (u) (getf u :id))) (error "strategy library: no unit ~s" id)))

(defun strat-compose (u)
  "U (a strategy or an arm plist) with its :STYLE and :DATA units expanded (the header above); U itself when it names neither."
  (if (not (or (getf u :style) (getf u :data)))
      u
      (let* ((style (and (getf u :style) (strat-unit-find (getf u :style) *strat-styles*)))
             (data (mapcar (lambda (d) (strat-unit-find d *strat-data*)) (getf u :data)))
             (out (list :id (getf u :id)))
             (base (append (loop for d in data append (getf d :base)) (getf u :base)))
             (rules (append (loop for d in data append (getf d :rules)) (getf u :rules))))
        (flet ((add (pl)
                 (loop for (k v) on pl by #'cddr
                       unless (or (member k '(:id :style :data :base :rules)) (loop for (kk) on out by #'cddr thereis (eq kk k)))
                         do (setf out (append out (list k v))))))
          (add u) (add style) (dolist (d data) (add d)))
        (append out (and base (list :base base)) (and rules (list :rules rules))))))

(defparameter *strat-units-expanded* (mapcar #'strat-compose *strat-units*)
  "*STRAT-UNITS* expanded once: every table naming an arm shares its plist (none is written to; the online learner plays a copy).")

(defun strat-arm (a)
  "A table's or a composite's arm A: NIL stays NIL, an arm id its expanded unit, an inline plist itself (composed)."
  (cond ((null a) nil)
        ((keywordp a) (strat-unit-find a *strat-units-expanded*))
        (t (strat-compose a))))

(defun strat-expand (st)
  "One *STRAT-LIBRARY* entry ST in the runtime's form (the header above): a Q table's arms and rules, a composite's subs, a strategy's units."
  (let ((fq (getf st :fq)))
    (cond (fq
           (let* ((rb (and (getf fq :rule-base) (strat-unit-find (getf fq :rule-base) *strat-rule-bases*)))
                  (arms (mapcar #'strat-arm (getf fq :arms)))
                  (rules (if rb
                             (progn (assert (= (length (getf rb :antes)) (length (getf fq :q))))
                                    (mapcar (lambda (ante q) (assert (= (length q) (length arms))) (cons ante q)) (getf rb :antes) (getf fq :q)))
                             (getf fq :rules)))
                  (groups (or (getf fq :groups) (and rb (getf rb :groups))))
                  (out (append (list :arms arms :rules rules) (and groups (list :groups groups)))))
             (assert (= (length arms) (length (remove-duplicates arms :test #'eq))))   ; (an arm twice: STRAT-SWITCH-STEP's :PREV would see the first)
             (loop for (k v) on fq by #'cddr
                   unless (member k '(:arms :rules :groups :rule-base :q)) do (setf out (append out (list k v))))
             (loop for (k v) on st by #'cddr append (list k (if (eq k :fq) out v)))))
          ((getf st :switch)
           (loop for (k v) on st by #'cddr
                 append (list k (case k
                                  (:switch (mapcar (lambda (en) (cons (car en) (strat-arm (cdr en)))) v))
                                  (:else (strat-arm v))
                                  (t v)))))
          (t (strat-compose st)))))

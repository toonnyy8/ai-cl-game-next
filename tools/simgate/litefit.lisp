;;;; litefit.lisp — the light model against the full sim, offline (docs/duel/DUEL_AI_MCTS.md §9): reads TEACH_DUMP files (teacher.lisp: per
;;;; decision point the light model's whole start as integers and the full sim's ten action values), puts each start back into the light
;;;; model's arrays and searches it again under each variant (a plist of special bindings), and prints per variant the regret of the light
;;;; pick (the full sim's best minus its value of the light model's best) against a uniform pick's, and how often the best agrees. Seconds a
;;;; variant, no full sim. Env: LITEFIT_N (rollouts a point, default 400), LITEFIT_VARIANTS (a list of binding plists; default one: as is).
;;;; Usage: ecl-host --norc --load tools/simgate/litefit.lisp -- <duel.fas> <dump>...
(load (merge-pathnames "prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)   ; tools/simgate/prelude.lisp: *SG-ARGS*, the fas, CL-USER::SG-INIT, CL-USER::SG-QUEUE
(in-package :duel)

(defun lf-ints (str) (with-input-from-string (in str) (loop for x = (read in nil) while x collect x)))
(defun lf-fill (v list) (loop for x in list for i from 0 do (setf (aref v i) x)) v)

(defun lf-point (line)
  "One dump line -> (difficulty opp-character values-list loader): LOADER puts the start back into the light model's arrays."
  (let* ((parts (let ((l nil) (s 0)) (loop for i = (position #\| line :start s) do (push (subseq line s i) l) (if i (setf s (1+ i)) (return)))
                  (nreverse l)))
         (head (let ((l nil) (st 0) (str (string-trim " " (first parts))))   ; (split on spaces: the records' commas are no Lisp)
                 (loop for i = (position #\Space str :start st) do (push (subseq str st i) l) (if i (setf st (1+ i)) (return)))
                 (remove "" (nreverse l) :test #'string=)))
         (dif (read-from-string (first head))) (ochar (read-from-string (third head))) (slots (nthcdr 5 head)))
    (destructuring-bind (i0 i1 g v0 v1 legal w full) (mapcar #'lf-ints (rest parts))
      (list dif ochar full
            (lambda ()
              (loop for sl in slots for k from 0
                    do (setf (svref *mc-slots* k)
                             (if (string= (string sl) "-") nil
                                 (lf-fill (mc-fv +r-n+) (mapcar #'parse-integer (uiop-split (string sl)))))))
              (lf-fill (svref *mc-i* 0) i0) (lf-fill (svref *mc-i* 1) i1) (lf-fill *mc-g* g)
              (lf-fill (svref *mc-vals* 0) v0) (lf-fill (svref *mc-vals* 1) v1)
              (lf-fill *mc-legal* (subseq legal 0 10)) (lf-fill *mc-legal2* (subseq legal 10 20)) (lf-fill *mc-w* w))))))

(defun uiop-split (s) (let ((l nil) (st 0)) (loop for i = (position #\, s :start st) do (push (subseq s st i) l) (if i (setf st (1+ i)) (return))) (nreverse l)))

(defparameter *lf-n* (parse-integer (or (ext:getenv "LITEFIT_N") "400")))
(defparameter *lf-variants* (let ((v (ext:getenv "LITEFIT_VARIANTS"))) (if v (read-from-string v) '(nil))))

(let ((points (loop for f in (rest cl-user::*sg-args*)
                    nconc (with-open-file (in f) (loop for l = (read-line in nil) while l collect (lf-point l))))))
  (format t "litefit ~d points, ~d rollouts each~%" (length points) *lf-n*)
  (loop for vars in *lf-variants* for k from 0
        do (progv (loop for (v nil) on vars by #'cddr collect v) (loop for (nil x) on vars by #'cddr collect x)
             (let ((reg (make-hash-table)) (uni (make-hash-table)) (agree (make-hash-table)) (cnt (make-hash-table)))
               (dolist (p points)
                 (destructuring-bind (dif ochar full load) p
                   (declare (ignorable ochar))
                   (funcall load)
                   (let ((*mc-select* (getf *mc-select-by* dif :tree)))
                     (mc-seed 12345) (mc-search *lf-n*))
                   (let* ((legal (loop for a below 10 when (mc-mean a) collect a))
                          (fl (mapcar (lambda (a) (nth a full)) legal)))
                     (when (>= (length legal) 2)
                       (let* ((best (reduce #'max fl)) (la (loop with b = nil with bv = nil for a in legal for m = (mc-mean a)
                                                                 when (or (null bv) (> m bv)) do (setf b a bv m) finally (return b))))
                         (incf (gethash dif reg 0) (- best (nth la full)))
                         (incf (gethash dif uni 0) (- best (/ (reduce #'+ fl) (length fl))))
                         (when (= (nth la full) best) (incf (gethash dif agree 0)))
                         (incf (gethash dif cnt 0)))))))
               (maphash (lambda (dif n)
                          (format t "variant ~d ~s ~a: ~d points, regret ~,4f (uniform ~,4f), best agrees ~,0f %~%" k vars dif n
                                  (/ (gethash dif reg) n) (/ (gethash dif uni) n) (/ (* 100.0 (gethash dif agree 0)) n)))
                        cnt)))))
(finish-output)
(ext:quit 0)

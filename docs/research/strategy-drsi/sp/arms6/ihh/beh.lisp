;;;; beh.lisp — batch p10-ih-ichigo's behaviour runner (arms6/ih-human.md; tool side only, no game code changed): the Ichigo / Hisagi
;;;; pairing gate with STRAT_DIF_P<n> per seat (as probe.lisp), the combat log on (for the CPU's own tags: `ki-style`, `cpu clash`, `cpu
;;;; finish`), and its own lines for beh.py:
;;;;   "bo <seed> <tick> <victim P> <hitter move> <hitter form> <victim doing> <dist>"  a combo opened (either side)
;;;;   "bh <seed> <tick> <victim P> <hitter move> <hitter form> <dist>"                 every hit (combo-hits up)
;;;;   "bs <seed> <tick> <P> <class> <into> <dist> <his form>"                          a move started out of a free state (into: his move live)
;;;;   "bf <seed> <P of Hisagi> <frames by his form and band ...>"                      per match, the distance by his form
;;;; Env: STRAT_DIF_P1 / P2 (easy | normal | hard), BEH_ICHIGO = a table file Ichigo plays at every tier (default the lookup), BEH_HISAGI =
;;;; lookup (default) | none (no strategy: the generic core CPU) | arm:<id> (that arm played whole, with the IH unit :d-x-ih-h laid under
;;;; it as his table lays it) | file:<path>.
;;;; Usage: ecl --norc --load docs/research/strategy-drsi/sp/arms6/ihh/beh.lisp -- build/simgate/duel.fas 30000+s0 31100+n 81022 200370
(load (merge-pathnames "../../../../../../tools/simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)

;;; BEH_SET=*knob*=value;... binds DUEL knobs at load (a tool-side override, never a source edit), as probe.lisp's PROBE_SET.
(let ((l (ext:getenv "BEH_SET")))
  (when (and l (plusp (length l)))
    (loop for start = 0 then (1+ p) for p = (position #\; l :start start)
          do (let* ((kv (subseq l start p)) (q (position #\= kv)))
               (setf (symbol-value (intern (string-upcase (subseq kv 0 q)) :duel)) (let ((*read-eval* nil)) (read-from-string (subseq kv (1+ q)))))
               (format t "beh set ~a~%" kv))
          while p)))

(defvar *bh-match* -1)
(defvar *bh-prev* (list nil nil))   ; per side: (state combo-hits doing cls-t)
(defvar *bh-f* (make-array 6 :initial-element 0))   ; his form frames: base, base in 3.1-6.0, bankai, bankai in 3.4-6.2, bind, bind in 3.1-6.0
(defvar *bh-hs* nil "Hisagi's side index this match, or NIL.")

(defun bh-flush ()
  (when (and (>= *bh-match* 0) *bh-hs*)
    (format t "bf ~d P~d~{ ~d~}~%" *bh-match* (1+ *bh-hs*) (coerce *bh-f* 'list)))
  (fill *bh-f* 0)
  (setf *bh-prev* (list nil nil)))

(defun bh-doing (e)
  "What E is doing as he is hit: free, the startup / active / recovery of a move by class, or his state."
  (let* ((f (fighter e)) (st (fighter-state f)) (mv (fighter-move f)))
    (cond ((member st '(:idle :run)) :free)
          ((and (eq st :move) mv)
           (intern (format nil "~a-~a" (or (fighter-cls f) :x)
                           (cond ((< (fighter-sf f) (mv-s mv)) "UP") ((< (fighter-sf f) (+ (mv-s mv) (mv-a mv))) "ACT") (t "REC"))) :keyword))
          (t st))))

(defun bh-strat (spec)
  "BEH_HISAGI / BEH_ICHIGO's strategy: :lookup, :none, or a plist."
  (cond ((or (null spec) (zerop (length spec)) (string= spec "lookup")) :lookup)
        ((string= spec "none") :none)
        ((eql 0 (search "arm:" spec))
         (strat-with (strat-arm (intern (string-upcase (subseq spec 4)) :keyword)) '(:d-x-ih-h)))
        ((eql 0 (search "file:" spec)) (cl-user::sg-read-strat (subseq spec 5)))
        (t (cl-user::sg-read-strat spec))))

(defvar *bh-specs* (list :ichigo (bh-strat (ext:getenv "BEH_ICHIGO")) :hisagi (bh-strat (ext:getenv "BEH_HISAGI"))))

(defun bh-hook ()
  (when (and (battle-p) (/= *bh-match* *match-seed*))
    (bh-flush)
    (setf *bh-match* *match-seed* *bh-hs* nil)
    (do-sides (e)
      (let* ((f (fighter e)) (b (brain e)) (ch (fighter-character f))
             (dv (ext:getenv (if (zerop (fighter-side f)) "STRAT_DIF_P1" "STRAT_DIF_P2"))))
        (when (eq ch :hisagi) (setf *bh-hs* (fighter-side f)))
        (when (and b dv (plusp (length dv)))
          (let ((dif (intern (string-upcase dv) :keyword)))
            (setf (brain-difficulty b) dif (brain-delay b) (getf *ai-delay* dif 14))
            (brain-set-strat! b (strat-lookup ch (fighter-character (fighter (fighter-opp f))) dif))))
        (let ((sp (getf *bh-specs* ch)))
          (when (and b sp (not (eq sp :lookup)))
            (brain-set-strat! b (if (eq sp :none) nil sp))
            (format t "beh P~d ~(~a~) ~a~%" (1+ (fighter-side f)) ch (if (eq sp :none) "none" (getf sp :id))))))))
  (when (and (battle-p) (eq *flow* :battle))
    (setf *combat-log* t)
    (let ((now (list nil nil)))
      (do-sides (e)
        (let ((f (fighter e)))
          (setf (nth (fighter-side f) now) (list (fighter-state f) (fighter-combo-hits f) (bh-doing e) (fighter-cls-t f)))))
      (when *bh-hs*
        (let* ((h (if (zerop *bh-hs*) *p1* *p2*)) (fh (fighter h)) (d (fighter-dist fh))
               (k (case (fighter-form fh) (:base 0) (:bankai 2) (t 4))))
          (incf (svref *bh-f* k))
          (when (if (= k 2) (<= 3.4 d 6.2) (<= 3.1 d 6.0)) (incf (svref *bh-f* (1+ k))))))
      (let ((p *bh-prev*))
        (when (and (first p) (second p))
          (do-sides (e)
            (let* ((f (fighter e)) (side (fighter-side f)) (o (fighter-opp f)) (fo (fighter o)) (os (fighter-side fo))
                   (me0 (nth side p)) (me1 (nth side now)) (op0 (nth os p)) (d (fighter-dist f)))
              ;; my move out of a free state (into: his move live, startup or active)
              (when (and (eq (first me1) :move) (member (first me0) '(:idle :run)))
                (format t "bs ~d ~d P~d ~(~a~) ~a ~,2f ~(~a~) ~a~%" *match-seed* *match-tick* (1+ side) (or (fighter-cls f) :x)
                        (if (member (third op0) '(:na-up :na-act :ns-up :ns-act :sa-up :sa-act :as-up :as-act)) 1 0) d (fighter-form fo)
                        (if (fighter-move f) (mv-name (fighter-move f)) "NONE")))
              ;; my combo-hits up: he hit me (his move now)
              (when (> (second me1) (second me0))
                (let ((mv (fighter-move fo)))
                  (format t "bh ~d ~d P~d ~a ~(~a~) ~,2f~%" *match-seed* *match-tick* (1+ side) (if mv (mv-name mv) "NONE") (fighter-form fo) d)
                  (when (zerop (second me0))
                    (format t "bo ~d ~d P~d ~a ~(~a~) ~(~a~) ~,2f~%" *match-seed* *match-tick* (1+ side) (if mv (mv-name mv) "NONE")
                            (fighter-form fo) (third me0) d))))))))
      (setf *bh-prev* now))))

(cl-user::sg-init)
(setf *step-hook* #'bh-hook)
(cl-user::sg-queue)
(engine::%frame)
(unless (loop repeat 4000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(bh-flush)
(finish-output)
(ext:quit 0)

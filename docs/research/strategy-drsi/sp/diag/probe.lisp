;;;; probe.lisp — diagnosis runner (tool side only; no game code changed): the pairing gate with STRAT_DIF_P<n> = easy | normal | hard |
;;;; masher per seat (as strat-run.lisp), the combat log kept on, and per match and side one counter line:
;;;;   "pstat <seed> P<n> st <state>:<steps> ... open <combos he started> hits <hits landed> first <neutral first moves> firstwin <first
;;;;    moves whose next opener was his> dmg <Reishi he took off> ticks <match ticks>"
;;;; PROBE_SET=*knob*=value[,...] binds DUEL knobs at load (a tool-side override, never a source edit), as strat-run's STRAT_SET.
;;;; Usage: ecl --norc --load docs/research/strategy-drsi/sp/diag/probe.lisp -- build/simgate/duel.fas 30000+s0 31100+n 81022 2001cc
(load (merge-pathnames "../../../../../tools/simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)

(let ((l (ext:getenv "PROBE_SET")))
  (when (and l (plusp (length l)))
    (loop for start = 0 then (1+ p) for p = (position #\; l :start start)
          do (let* ((kv (subseq l start p)) (q (position #\= kv)))
               (setf (symbol-value (intern (string-upcase (subseq kv 0 q)) :duel)) (let ((*read-eval* nil)) (read-from-string (subseq kv (1+ q)))))
               (format t "probe set ~a~%" kv))
          while p)))

;;; PROBE_LIFT=to=from:knob,knob;... (after PROBE_SET; all-tiers-table.md): each per-difficulty plist knob's TO value becomes its FROM
;;; value (a copy of the list, never the literal). A knob is *name* or a group: @eyes @cai @style @mc (below).
(defparameter *pr-groups*
  '((:eyes *ai-delay*)
    (:cai *fz-skill* *cai-think* *cai-turn-p* *cai-cont-p* *cai-hoho-p* *cai-clash-p* *cai-clash-delay* *cai-xch-j* *cai-xch-sa-p*
     *cai-xch-carry-p* *cai-awaken-break-p* *cai-awaken-kikon-p* *cai-dswitch-dif* *strat-lambda*)
    (:style *hb-awaken-p* *hb-jclash-p* *hb-poke-p* *hb-react-p* *hb-step-p* *hkb-p* *hkk-p* *hkw-p* *hr-home-p* *hr-p* *hr-taba-p* *ihx-p* *iks-awaken-p* *iks-bait-modes* *iks-break-p* *iks-burst-no-hoho*
     *iks-confirm-p* *iks-follow-any-perfect* *iks-gap-p* *iks-generic-kikon* *iks-hoho-p* *iks-kessa-read-min* *iks-kessa-space-modes*
     *iks-kikon-costly-p* *iks-kikon-p* *iks-meaty-p* *iks-mix* *iks-ns-stop* *iks-ns-wait* *iks-p2-wait* *iks-patient-p* *iks-punish-p*
     *iks-read-p* *iks-retreat-p* *iks-steer-p* *iks-wait-max* *iks-wake-hoho-p* *ikw-roll-p* *ir2-oki-p* *ir2-roll-p* *khf-bait-p*
     *kk-as-on-p* *kk-as-read-p* *kk-awaken-p* *kk-bankai-p* *kk-bk-ns-p* *kk-brawl-p* *kk-cine-wait* *kk-climb-p* *kk-dodge-p* *kk-hend-p*
     *kk-hoho-in-p* *kk-kikon-ptr-p* *kk-kikon-red-p* *kk-l3-sa-p* *kk-link-p* *kk-lunge-p* *kk-meaty-p* *kk-ns-safe-p* *kk-ns-stop-p*
     *kk-pf-p* *kk-reach-p* *kk-step-in-p* *kk-step-p* *kk-wake-hoho-p* *kk-wave-p* *kso-stale*)
    (:mc *mc-budget* *mc-iters* *mc-opp-delay* *mc-react-p* *mc-select-by* *mc-sure* *mc-tau*)
    (:clash *cai-clash-p* *cai-clash-delay*)))
;;; @style-k / @style-i / @style-h: one character's style knobs (@style's names by prefix: Kenpachi kk kso khf, Ichigo iks ikw ir2, Hisagi hb hk hr ihx)
(dolist (g '((:style-k "*KK-" "*KSO-" "*KHF-") (:style-i "*IKS-" "*IKW-" "*IR2-") (:style-h "*HB-" "*HK" "*HR-" "*IHX-")))
  (push (cons (car g) (remove-if-not (lambda (s) (some (lambda (p) (eql 0 (search p (symbol-name s)))) (cdr g)))
                                     (cdr (assoc :style *pr-groups*))))
        *pr-groups*))
(let ((l (ext:getenv "PROBE_LIFT")))
  (when (and l (plusp (length l)))
    (loop for start = 0 then (1+ p) for p = (position #\; l :start start)
          do (let* ((g (subseq l start p)) (eq1 (position #\= g)) (co (position #\: g))
                    (to (intern (string-upcase (subseq g 0 eq1)) :keyword)) (from (intern (string-upcase (subseq g (1+ eq1) co)) :keyword)))
               (loop for s0 = (1+ co) then (1+ q) for q = (position #\, g :start s0)
                     do (let ((name (string-upcase (subseq g s0 q))))
                          (dolist (sym (if (char= (char name 0) #\@)
                                           (cdr (assoc (intern (subseq name 1) :keyword) *pr-groups*))
                                           (list (intern name :duel))))
                            (let ((v (copy-list (symbol-value sym))))
                              (setf (getf v to) (getf v from) (symbol-value sym) v))))
                     while q)
               (format t "probe lift ~a~%" g))
          while p)))

(defvar *pr-match* -1)
(defvar *pr-st* (list (make-hash-table) (make-hash-table)))
(defvar *pr-c* (make-array '(2 8) :initial-element 0))   ; per side: open hits first firstwin dmg
(defvar *pr-prev* (list nil nil))                         ; per side: (state combo-hits reishi cls-t)
(defvar *pr-on* (list (make-hash-table) (make-hash-table)) "Per side: the combos he opened, by what his victim was doing the step before.")
(defvar *pr-k* (list (make-hash-table :test 'equal) (make-hash-table :test 'equal)) "Per side: starts / hits / damage by the game's class.")
(defvar *pr-first* nil "The side that last made the first move out of a both-free stretch, or NIL (credited at the next opener).")

(defun pr-flush ()
  (when (>= *pr-match* 0)
    (dotimes (side 2)
      (format t "pstat ~d P~d st~{ ~(~a~):~d~} on~{ ~(~a~):~d~} k~{ ~(~a~):~d~} deaf ~d hold ~d open ~d hits ~d first ~d firstwin ~d dmg ~d ticks ~d~%" *pr-match* (1+ side)
              (let (l) (maphash (lambda (k v) (push v l) (push k l)) (nth side *pr-st*)) l)
              (let (l) (maphash (lambda (k v) (push v l) (push k l)) (nth side *pr-on*)) l)
              (let (l) (maphash (lambda (k v) (push (round v) l) (push k l)) (nth side *pr-k*)) l) (aref *pr-c* side 6) (aref *pr-c* side 7)
              (aref *pr-c* side 0) (aref *pr-c* side 1) (aref *pr-c* side 2) (aref *pr-c* side 3) (aref *pr-c* side 4) (aref *pr-c* side 5))))
  (dolist (h *pr-st*) (clrhash h))
  (dolist (h *pr-on*) (clrhash h))
  (dolist (h *pr-k*) (clrhash h))
  (dotimes (i 2) (dotimes (j 8) (setf (aref *pr-c* i j) 0)))
  (setf *pr-prev* (list nil nil) *pr-first* nil))

(defun pr-cls (e)
  "E's move class as the game has it (:na :ns :as :sa), else the move's kind, else his state."
  (let* ((f (fighter e)) (mv (fighter-move f)))
    (if (and (eq (fighter-state f) :move) mv) (or (fighter-cls f) (mv-kind mv) :x) (fighter-state f))))
(defun pr-k (side what cls n) (incf (gethash (format nil "~a-~a" what cls) (nth side *pr-k*) 0) n))
(defun pr-free-p (st) (member st '(:idle :run :walk)))
(defun pr-doing (e)
  "What E is doing, for the opener's victim: deaf (free, his CPU holding no button: the MCTS's hold, its wait / walk), free, the
startup / active / recovery of a move by class, or his state."
  (let* ((f (fighter e)) (b (brain e)) (st (fighter-state f)) (mv (fighter-move f)))
    (cond ((pr-free-p st) (if (and b (not (brain-masher b)) (plusp (brain-press-left b)) (eq (brain-press b) :none))
                               (if (plusp (aref *mc-plan* (* 5 (fighter-side f)))) :deaf :deafact) :free))
          ((and (eq st :move) mv)
           (intern (format nil "~a-~a" (or (fighter-cls f) :x)
                           (cond ((< (fighter-sf f) (mv-s mv)) "UP") ((< (fighter-sf f) (+ (mv-s mv) (mv-a mv))) "ACT") (t "REC"))) :keyword))
          (t st))))

(defun pr-hook ()
  (when (and (battle-p) (/= *pr-match* *match-seed*))
    (pr-flush)
    (setf *pr-match* *match-seed*)
    (do-sides (e)
      (let ((b (brain e)) (dv (ext:getenv (if (zerop (fighter-side (fighter e))) "STRAT_DIF_P1" "STRAT_DIF_P2"))))
        (cond ((and b (equal dv "masher"))
               (setf (brain-masher b) t (brain-m-left b) 0 (brain-press-left b) 0))
              ((and b dv (plusp (length dv)))
               (let ((dif (intern (string-upcase dv) :keyword)))
                 (setf (brain-difficulty b) dif (brain-delay b) (getf *ai-delay* dif 14))
                 (brain-set-strat! b (strat-lookup (fighter-character (fighter e)) (fighter-character (fighter (fighter-opp (fighter e)))) dif))
                 ;; STRAT_<CHARACTER>=file (arms6/ih.md): that character's table from a file at every tier, as strat-run.lisp reads it
                 (let ((p (ext:getenv (format nil "STRAT_~a" (fighter-character (fighter e))))))
                   (when (and p (plusp (length p))) (brain-set-strat! b (cl-user::sg-read-strat p))))))))))
  (when (and (battle-p) (eq *flow* :battle))
    (setf *combat-log* t (aref *pr-c* 0 5) *match-tick* (aref *pr-c* 1 5) *match-tick*)
    (let ((now (list nil nil)))
      (do-sides (e)
        (let* ((f (fighter e)) (side (fighter-side f)) (g (gauges e)))
          (incf (gethash (fighter-state f) (nth side *pr-st*) 0))
          (setf (nth side now) (list (fighter-state f) (fighter-combo-hits f) (gauges-reishi g) (pr-doing e) (pr-cls e) (fighter-cls-t f)))
          (when (member (fourth (nth side now)) '(:deaf :deafact)) (incf (aref *pr-c* side 6)))
          (when (eq (fourth (nth side now)) :deaf) (incf (aref *pr-c* side 7)))))
      (let ((p *pr-prev*))
        (when (and (first p) (second p))
          (dotimes (side 2)
            (let* ((o (- 1 side)) (me0 (nth side p)) (me1 (nth side now)) (op0 (nth o p)) (op1 (nth o now)))
              ;; his combo-hits up: I landed hits; from 0: I opened a combo
              (when (and (eq (first me1) :move) (or (not (eq (first me0) :move)) (/= (sixth me1) (sixth me0))))
                (pr-k side "start" (fifth me1) 1))
              (when (< (third op1) (third op0)) (pr-k side "dmg" (fifth me1) (- (third op0) (third op1))))
              (when (> (second op1) (second op0))
                (incf (aref *pr-c* side 1) (- (second op1) (second op0)))
                (pr-k side "hit" (fifth me1) (- (second op1) (second op0)))
                (when (zerop (second op0))
                  (incf (aref *pr-c* side 0))
                  (incf (gethash (fourth op0) (nth side *pr-on*) 0))
                  (when *pr-first* (when (= *pr-first* side) (incf (aref *pr-c* side 3))) (setf *pr-first* nil))))
              (when (< (third op1) (third op0)) (incf (aref *pr-c* side 4) (round (- (third op0) (third op1)))))
              ;; the first move out of a both-free step
              (when (and (pr-free-p (first me0)) (pr-free-p (first op0)) (eq (first me1) :move) (pr-free-p (first op1)))
                (incf (aref *pr-c* side 2)) (setf *pr-first* side))))))
      (setf *pr-prev* now))))

(cl-user::sg-init)
(setf *step-hook* #'pr-hook)
(cl-user::sg-queue)
(engine::%frame)
(unless (loop repeat 2000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(pr-flush)
(finish-output)
(ext:quit 0)

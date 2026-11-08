;;;; strat-desc.lisp — strat-run.lisp (copied loader: STRAT_<CHARACTER> / STRAT_P1 / STRAT_P2 env, a character given a strategy plays
;;;; without his matchup style CPU) plus a per-step observer of BEHAVIOUR DESCRIPTORS (docs/duel/DUEL_AI_STRATEGY.md §4, §8.2; tools/strategy-eval.py).
;;;; Extra env: DESC_GENERIC=<character>[,<character>] unregisters those characters' matchup styles (a generic opponent, as run-situ.lisp's SITU_GENERIC).
;;;; The observer reads the state only (it sets *STEP-HOOK*, which strat-run's hook is chained into) and prints, when a match ends, one line per side:
;;;;   desc P1 kenpachi <seed> secs=.. in=.. reach=.. out=.. afar=.. dist=.. na=.. ns=.. as=.. sa=.. atk=.. hoho=.. perf=.. wp=.. punished=.. kik=.. wav=..
;;;; in/reach/out/afar: share of the side's FREE time (idle / run / guard) by the distance over its own J1 reach (best fuzzy set of fuzzy.lisp's :in
;;;; :reach :out :afar); dist: mean distance (m) over the match; na ns as sa: attack starts per minute by triangle class (kit-class), atk their sum;
;;;; hoho: Hoho per minute; perf: share of them perfect; wp: whiff punishes per minute (this side hit the opponent while he was in a move's recovery,
;;;; i.e. in :main past startup + active); punished: the same against this side; kik: Kikon holds entered (phase :follow) per minute; wav: damaging
;;;; hazards (waves) this side's first-seen per minute. Usage: ecl-host --norc --load tools/simgate/strat-desc.lisp -- <duel.fas> <cmd>...
(defparameter cl-user::*sg-args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*sg-args*) :verbose nil)
(in-package :duel)

(defun sr-read (path) (and path (plusp (length path)) (with-open-file (in path) (let ((*read-eval* nil)) (read in)))))
(defvar *sr-files* (make-hash-table :test 'equal))
(defun sr-strat (env) (let ((p (ext:getenv env))) (and p (plusp (length p)) (or (gethash p *sr-files*) (setf (gethash p *sr-files*) (sr-read p))))))
(defvar *sr-match* -1)
(defun sr-hook ()
  (when (and (battle-p) (/= *sr-match* *match-seed*))
    (setf *sr-match* *match-seed*)
    (do-sides (e)
      (let* ((f (fighter e)) (b (brain e)) (ch (fighter-character f))
             (st (or (sr-strat (if (zerop (fighter-side f)) "STRAT_P1" "STRAT_P2")) (sr-strat (format nil "STRAT_~:@(~a~)" ch)))))
        (when (and b st)
          (setf (brain-strat b) st)
          (remf *cai-styles* ch)
          (format t "strat P~d ~a~%" (1+ (fighter-side f)) (getf st :id)))))))

(defstruct (sd-side (:conc-name sdd-)) (band (make-array 4 :initial-element 0)) (free 0) (dsum 0d0) (cnt (make-array 8 :initial-element 0))
  (pstate nil) (precov nil) (pphase nil) (pend nil) (hoho-chk nil))
;; cnt: 0 na 1 ns 2 as 3 sa 4 hoho 5 perfect 6 whiff punishes made 7 punished   (kik, wav in the two extra slots below)
(defvar *sd* nil) (defvar *sd-n* 0) (defvar *sd-tick* -1) (defvar *sd-cls* (list -1 -1)) (defvar *sd-kik* (list 0 0)) (defvar *sd-wav* (list 0 0))
(defvar *sd-seen* (make-hash-table :test 'eql))
(defvar *sd-chars* nil)

(defun sd-dist (a b) (let ((p (pos-of a)) (q (pos-of b))) (sqrt (+ (expt (- (aref p 0) (aref q 0)) 2) (expt (- (aref p 2) (aref q 2)) 2)))))
(defun sd-recov-p (f)
  (let ((mv (fighter-move f)))
    (and mv (eq (fighter-state f) :move) (eq (fighter-phase f) :main) (>= (fighter-sf f) (+ (mv-s mv) (mv-a mv))))))
(defun sd-band (x)
  (let ((best 0) (bm -1.0))
    (loop for s in '(:in :reach :out :afar) for i from 0 do (let ((m (fz-mu x s))) (when (> m bm) (setf bm m best i))))
    best))

(defun sd-flush ()
  (when *sd*
    (let ((secs (/ *sd-n* 60.0)) (min (max 1e-6 (/ *sd-n* 3600.0))))
      (loop for e in (list *p1* *p2*) for s in *sd* for i from 0
            do (let* ((c (sdd-cnt s)) (fr (max 1 (sdd-free s))) (hoho (aref c 4)) (atk (+ (aref c 0) (aref c 1) (aref c 2) (aref c 3))))
                 (format t "desc P~d ~(~a~) ~d secs=~,1f in=~,3f reach=~,3f out=~,3f afar=~,3f dist=~,2f na=~,2f ns=~,2f as=~,2f sa=~,2f atk=~,2f hoho=~,2f perf=~,3f wp=~,2f punished=~,2f kik=~,2f wav=~,2f~%"
                         (1+ i) (nth i *sd-chars*) *match-seed* secs
                         (/ (aref (sdd-band s) 0) fr 1.0) (/ (aref (sdd-band s) 1) fr 1.0) (/ (aref (sdd-band s) 2) fr 1.0) (/ (aref (sdd-band s) 3) fr 1.0)
                         (/ (sdd-dsum s) (max 1 *sd-n*)) (/ (aref c 0) min) (/ (aref c 1) min) (/ (aref c 2) min) (/ (aref c 3) min) (/ atk min)
                         (/ hoho min) (if (plusp hoho) (/ (aref c 5) (float hoho)) 0.0) (/ (aref c 6) min) (/ (aref c 7) min)
                         (/ (nth i *sd-kik*) min) (/ (nth i *sd-wav*) min))))
      (setf *sd* nil))))

(defun sd-step ()
  (sr-hook)
  (unless (and (eq *flow* :battle) *p1* *p2* (entity-alive-p *p1*) (entity-alive-p *p2*))
    (sd-flush) (return-from sd-step))
  (when (< *match-tick* *sd-tick*) (sd-flush))   ; a new match
  (unless *sd*
    (setf *sd* (list (make-sd-side) (make-sd-side)) *sd-kik* (list 0 0) *sd-wav* (list 0 0) *sd-cls* (list -1 -1) *sd-n* 0
          *sd-chars* (list (fighter-character (fighter *p1*)) (fighter-character (fighter *p2*))))
    (clrhash *sd-seen*))
  (setf *sd-tick* *match-tick*)
  (when (or (eq (fighter-state (fighter *p1*)) :cine) (eq (fighter-state (fighter *p2*)) :cine)) (return-from sd-step))   ; (cinematics are not play)
  (incf *sd-n*)
  (let ((d (sd-dist *p1* *p2*)))
    (loop with old = (mapcar (lambda (s) (cons (sdd-pstate s) (sdd-precov s))) *sd*)
          for e in (list *p1* *p2*) for o in (list *p2* *p1*) for s in *sd* for i from 0
          do (let* ((f (fighter e)) (of (fighter o)) (os (nth (- 1 i) *sd*)) (st (fighter-state f)) (c (sdd-cnt s)))
               (incf (sdd-dsum s) d)
               (when (member st '(:idle :run :guard))
                 (incf (sdd-free s))
                 (incf (aref (sdd-band s) (sd-band (/ d (max 0.5 (strat-reach (kit-command-move (fighter-kit f) :q e))))))))
               ;; attack starts: a new move class stamp (fighter-cls-t) while in a move
               (when (and (eq st :move) (fighter-cls f) (/= (fighter-cls-t f) (nth i *sd-cls*)))
                 (setf (nth i *sd-cls*) (fighter-cls-t f))
                 (case (fighter-cls f) (:na (incf (aref c 0))) (:ns (incf (aref c 1))) (:as (incf (aref c 2))) (:sa (incf (aref c 3)))))
               ;; Hoho: entering :hoho; perfect read on its first step
               (when (and (eq st :hoho) (not (eq (sdd-pstate s) :hoho)))
                 (incf (aref c 4)) (when (fighter-perfect f) (incf (aref c 5))))
               ;; Kikon: entering the :follow phase of a move
               (when (and (eq st :move) (eq (fighter-phase f) :follow) (not (eq (sdd-pphase s) :follow))) (incf (nth i *sd-kik*)))
               ;; whiff punish: this side's opponent was just hit (entered :stun / :air) while in a move's recovery a step ago
               (when (and (member (fighter-state of) '(:stun :air)) (not (member (car (nth (- 1 i) old)) '(:stun :air)) ) (cdr (nth (- 1 i) old)))
                 (incf (aref c 6)) (incf (aref (sdd-cnt os) 7)))
               (setf (sdd-pstate s) st (sdd-pphase s) (and (eq st :move) (fighter-phase f)) (sdd-precov s) (sd-recov-p f))))
    ;; waves: damaging hazards first seen this step, by owner
    (do-entities (h (hz hazard))
      (when (and (hazard-hw hz) (not (gethash h *sd-seen*)))
        (setf (gethash h *sd-seen*) t)
        (cond ((eql (hazard-owner hz) *p1*) (incf (first *sd-wav*))) ((eql (hazard-owner hz) *p2*) (incf (second *sd-wav*))))))))

(let ((g (ext:getenv "DESC_GENERIC")))
  (when (and g (plusp (length g)))
    (loop with start = 0 for comma = (position #\, g :start start)
          do (remf *cai-styles* (intern (string-upcase (subseq g start comma)) :keyword))
             (if comma (setf start (1+ comma)) (return)))))
(loop for r = (engine::%init-step) until (eql r 0) when (eql r 2) do (ext:quit 2))
(setf *step-hook* #'sd-step)
(dolist (c (rest cl-user::*sg-args*)) (engine::simgate-cmd (parse-integer c)))
(engine::%frame)
(unless (loop repeat 2000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(sd-flush)
(finish-output)
(ext:quit 0)

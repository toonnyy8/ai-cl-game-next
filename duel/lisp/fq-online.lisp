;;;; fq-online.lisp — the online fuzzy Q against a human (DUEL_AI_STRATEGY §8.14; the user, 2026-11-09: 「對玩家的線上學習」): which CPU
;;;; learns (FQ-ATTACH!), its record (FQ-NOTE, FQ-EXPLORE), the TD updates at the match's end and the player's copy on the page
;;;; (FQ-MATCH-END, FQ-TABLE), RESET LEARNING (FQ-RESET-ALL). The pure part (FQ-TD-UPDATE!, FQ-TRANSITIONS, the codec) is
;;;; strategy.lisp. Out of ai-learn.lisp on 2026-11-13 (REFACTOR_2026-11 R4): the old learner it shared the file with (learn.lisp's
;;;; n-gram model and bandit, the LRN learner, the ASSIST's learner) left main with the frozen modes, branch `frozen-modes`.
(in-package :duel)

(defvar *learn-debug-off* nil
  "A debug command ran: no CPU learns any more (DEBUG-COMMAND sets it; debug 2504 clears it to play as in a VS CPU match).")

;;; ---------------------------------------------------------------- the online fuzzy Q against a human (DUEL_AI_STRATEGY §8.14)
;;; A CPU whose lookup strategy is a Q selector (:FQ) played whole (its difficulty's *STRAT-TABLE-CHANCE* 1: HARD, §11.17) and whose
;;; opponent is a human (no brain), in VS CPU with LEARNING CPU on and no debug command run, plays the player's own copy of the table (FQ-ATTACH!); STRAT-SWITCH-STEP records each judgement outside rollouts (FQ-NOTE);
;;; at the match's end FQ-MATCH-END applies the TD updates (strategy.lisp FQ-TD-UPDATE!) and saves the copy. CPU vs CPU never learns.
(defconstant +pg-fq+ 40000 "Page get / set 40000 + 1000 (10 me + vs): CPU ME's online table against VS (count; + 1 + j entry j; pwa.js soulduel.fq.<me>.<vs>).")
(defvar *fq-tables* nil "Per (me . vs) roster indices: (strategy . matches), the player's copy of the offline Q selector, loaded from the page on first use.")
(defvar *fq-learn-force* nil "NIL in the game; a tool's T: every Q-selector CPU learns, whoever its opponent (tools/simgate/strat-run.lisp STRAT_FQLEARN).")

(defun fq-page-base (me vs) (+ +pg-fq+ (* 1000 (+ (* 10 me) vs))))

(defun fq-table (me vs lib)
  "The player's copy of LIB (the lookup's Q selector strategy) for roster indices ME / VS: (strategy . matches), in memory, else the page's when it
was saved from this same offline table, else a fresh copy."
  (let ((key (cons me vs)))
    (or (cdr (assoc key *fq-tables* :test #'equal))
        (let* ((base (fq-page-base me vs)) (n (min 999 (max 0 (page-get base))))
               (codes (loop for j from 1 to n collect (page-get (+ base j)))))
          (multiple-value-bind (fq m) (fq-decode codes (getf lib :fq))
            (let ((cell (cons (if fq (list* :fq fq (loop for (k v) on lib by #'cddr unless (eq k :fq) append (list k v))) (copy-tree lib))
                              (or m 0))))
              (log-msg "duel fq load ~d ~d ~a matches ~d checksum ~d" me vs (if fq "page" "fresh") (cdr cell) (fq-checksum (getf lib :fq)))
              (push (cons key cell) *fq-tables*)
              cell))))))

(defun fq-reset-all ()
  "RESET LEARNING (SETTINGS): forget every online table, in memory and on the page (length 0 = an empty table, which loads as fresh)."
  (setf *fq-tables* nil)
  (dolist (me (playable-roster))
    (dolist (vs (playable-roster))
      (page-set (fq-page-base (position me *roster*) (position vs *roster*)) 0)))
  (log-msg "duel fq reset"))

(defun fq-attach! (e)
  "CPU E learns this match when its strategy is a Q selector played whole (table chance 1: HARD, DUEL_AI_STRATEGY §11.17) and it faces a human (VS CPU, LEARNING CPU on, no debug command; or a tool's
*FQ-LEARN-FORCE*): its brain plays the player's copy and keeps the match's record (BRAIN-FQL: me vs offline-table records)."
  (let* ((b (brain e)) (f (fighter e)) (lib (brain-strat b)) (o (fighter-opp f)))
    (when (and lib (getf lib :fq)
               ;; (a table played whole: NORMAL's windows would credit arms it never played, and its copy shares HARD's page slot; §11.17)
               (>= (brain-chance b *strat-table-chance*) 1.0)
               (or *fq-learn-force* (and (eq *mode* :vs-cpu) (null (brain o)) (zerop (setting :learn)) (not *learn-debug-off*))))
      (let ((me (position (fighter-character f) *roster*)) (vs (position (fighter-character (fighter o)) *roster*)))
        (setf (brain-strat b) (car (fq-table me vs lib))
              (brain-fql b) (list me vs (getf lib :fq) nil))))))

(defun fq-explore (e sw sub i)
  "A learning CPU E's judgement (SUB, arm I) of the Q selector SW, or the other arm with chance *FQ-ONLINE-EPS* (two arms; FQ-U01: no draw)."
  (let ((arms (getf (getf sw :fq) :arms)))
    (if (and (plusp *fq-online-eps*) (= 2 (length arms))
             (< (fq-u01 *match-seed* *match-tick* (fighter-side (fighter e))) *fq-online-eps*))
        (values (nth (- 1 i) arms) (- 1 i))
        (values sub i))))

(defun fq-note (e b feats arm)
  "Record a judgement of CPU E (brain B, learning): the firing vector for FEATS, the ARM played, my health balance."
  (let ((l (brain-fql b)))
    (push (list (strat-fq-fire (getf (brain-strat b) :fq) feats) arm (- (mc-full-health e) (mc-full-health (fighter-opp (fighter e)))))
          (fourth l))))

(defun fq-match-end ()
  "The match is over: every learning CPU's copy takes the TD updates of its record (in order), then is saved to the page."
  (do-sides (e)
    (let* ((b (brain e)) (l (and b (brain-fql b))))
      (when l
        (destructuring-bind (me vs base recs) l
          (let* ((side (fighter-side (fighter e))) (cell (cdr (assoc (cons me vs) *fq-tables* :test #'equal))) (fq (getf (car cell) :fq))
                 (h (- (mc-full-health e) (mc-full-health (fighter-opp (fighter e)))))
                 (won (cond ((eql *winner* side) 1.0) ((eql *winner* :draw) 0.0) (t -1.0))))
            (setf (brain-fql b) nil)
            (when recs
              (fq-td-update! fq base (fq-transitions (reverse recs) h won (getf fq :scale *fq-online-scale*))   ; (a table's own window: :GAMMA / :SCALE, §8.19)
                             :gamma (getf fq :gamma *fq-online-gamma*))
              (incf (cdr cell))
              (let ((codes (fq-encode fq base (cdr cell))) (pg (fq-page-base me vs)))
                (loop for c in codes for j from 1 do (page-set (+ pg j) c))
                (page-set pg (length codes)))
              (log-msg "duel fq learn ~d ~d matches ~d judgements ~d moved ~d flips ~d" me vs (cdr cell) (length recs)
                       (loop for r in (getf fq :rules) for r0 in (getf base :rules) count (not (equal (rest r) (rest r0))))
                       (loop for r in (getf fq :rules) for r0 in (getf base :rules)
                             count (/= (position (reduce #'max (rest r)) (rest r)) (position (reduce #'max (rest r0)) (rest r0))))))))))))

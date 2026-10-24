;;;; gate.lisp — the seed gates' machinery (docs/duel/DUEL_GAMEPLAY.md "Gate policy"; tools/simgate.py drives it natively):
;;;; the determinism hash line, the gate's pacing companions (Rukia's bands, Kenpachi's cups; the other characters keep
;;;; theirs in their own files), seeded CPU vs CPU, the seed gate and its pairings (ROSTER-PAIRS), the learning gate (its
;;;; habit knobs *HABITS* / *DUMB-P2*; the scripted players themselves, which the sim calls, are scripted.lisp).
;;;; The debug commands that start them are dispatched in debug.lisp (DEBUG-COMMAND). Out of debug.lisp 2026-10-21.
(in-package :duel)

(defvar *turbo* nil "Debug 2102: fast-forward (many steps per frame, scene not drawn).")
(defvar *gate-log* nil "Debug 2114+p: the seed gate keeps the combat log and logs a pace line every 60 ticks.")

(defun state-hash-line ()
  "The determinism hash: positions quantized to cm, facing to 0.01 rad, every gauge (f flash-step,
g guard gauge, ! = guardless, m the kit meter: Inferno / NOME), n the Konpaku the last Kikon rush was worth."
  (with-output-to-string (s)
    (format s "duel hash t=~d" *match-tick*)
    (dolist (e (list *p1* *p2*))
      (let ((p (pos-of e)) (g (gauges e)) (f (fighter e)))
        (format s " | ~d ~d ~d ~d ~a ~a r~d k~d a~d f~d g~d~:[~;!~] w~d m~d~@[ u~d~]~:[~;*~] n~d~@[ fr~d~]~@[ sl~d~]~@[ h~d~]~@[ ~a~]" (round (* 100 (aref p 0))) (round (* 100 (aref p 1)))
                (round (* 100 (aref p 2))) (round (* 100 (yaw-of e))) (fighter-state f) (fighter-form f)
                (gauges-reishi g) (gauges-konpaku g) (round (gauges-reiatsu g)) (round (gauges-fs g)) (round (gauges-gg g))
                (gauges-guardless g) (round (gauges-awaken g))
                (round (gauges-meter g)) (and (or (kit-pips (fighter-kit f)) (getf (kit-meter (fighter-kit f)) :temp))   ; the arm's
                                              (gauges-meter-idle g))                            ; crack clock / Rukia's warm clock,
                (gauges-arm-pending g)                                                          ; * = its burst pending
                (fighter-kikon-n f) (and (plusp (fighter-frost f)) (fighter-frost f))           ; fr = frost left (Rukia's ice)
                (and (plusp (fighter-layers f)) (+ (* 1000 (fighter-layers f)) (fighter-thaw f)))   ; sl = her 霜の層 on him
                (and (brain e) (floor (brain-heat (brain e))))
                (let ((h (kit-hook (fighter-kit f) :hash))) (and h (funcall h e))))))   ; a kit's own state (Hisagi's sickle)
    (format s " | cd ~{~d~^.~} ~{~d~^.~} | haz ~d" (coerce (fighter-cd (fighter *p1*)) 'list) (coerce (fighter-cd (fighter *p2*)) 'list)
            (let ((n 0)) (do-entities (h hazard) (incf n)) n))))

(defvar *band-acc* (vector (make-array 18 :element-type 'fixnum :initial-element 0)
                           (make-array 18 :element-type 'fixnum :initial-element 0))
  "Per side, the cold bands' pacing (debug only: never read by the sim): frames, damage dealt and taken per band (-18
-50 zero: 0-2, 3-5, 6-8), zero visits (9), exits by CRACK (10) and by spending / warming (11), bracing frames (12),
freeze-touches (13), the last dealt / taken totals (14 15), the last band (16: -1 none) and freeze-touch flag (17).")

(defun band-acc-reset ()
  (dotimes (i 2) (let ((a (svref *band-acc* i))) (fill a 0) (setf (aref a 16) -1))))

(defun band-acc-step ()
  "Per battle step outside cinematics: every awakened Rukia side's band bookkeeping (BAND-ACC-LINE logs it)."
  (when (and (eq *flow* :battle) (not *cine*) (entity-alive-p *p1*) (entity-alive-p *p2*))
    (dolist (e (list *p1* *p2*))
      (let* ((f (fighter e)) (a (svref *band-acc* (fighter-side f))) (g (gauges e)) (go (gauges (opp-of e)))
             (b (position (fighter-form f) '(:m18 :m50 :zero))) (last (aref a 16))
             (d (- (gauges-dealt g) (aref a 14))) (tk (- (gauges-dealt go) (aref a 15))))
        (setf (aref a 14) (gauges-dealt g) (aref a 15) (gauges-dealt go))
        (when b
          (incf (aref a b)) (incf (aref a (+ 3 b)) d) (incf (aref a (+ 6 b)) tk)
          (when (and (= b 2) (/= last 2)) (incf (aref a 9)))
          (when (and (= last 2) (/= b 2)) (incf (aref a (if (and (= b 0) (plusp (gauges-meter-idle g))) 10 11))))
          (when (and (= b 2) (vpad-down (pilot-vpad (pilot e)) :guard)) (incf (aref a 12)))
          (when (and (gauges-froze g) (zerop (aref a 17))) (incf (aref a 13))))
        (setf (aref a 16) (or b -1) (aref a 17) (if (gauges-froze g) 1 0))))))

(defun band-acc-line ()
  "The gate row's companion: a \"duel band\" line per side that was awakened Rukia."
  (dotimes (i 2)
    (let ((a (svref *band-acc* i)))
      (when (plusp (+ (aref a 0) (aref a 1) (aref a 2)))
        (log-msg "duel band seed ~d P~d vs ~a frames ~d ~d ~d dealt ~d ~d ~d taken ~d ~d ~d visits ~d crack ~d exit ~d brace ~d ft ~d"
                 *match-seed* (1+ i) (fighter-character (fighter (if (zerop i) *p2* *p1*)))
                 (aref a 0) (aref a 1) (aref a 2) (aref a 3) (aref a 4) (aref a 5) (aref a 6) (aref a 7) (aref a 8)
                 (aref a 9) (aref a 10) (aref a 11) (aref a 12) (aref a 13))))))

(defvar *cup-acc* (vector (make-array 15 :element-type 'fixnum :initial-element 0)
                          (make-array 15 :element-type 'fixnum :initial-element 0))
  "Per side, Kenpachi's NOME cups (debug only: never read by the sim): frames in KATATE / RYOTE / NOMIHOSE / BANKAI /
KATAUDE (0-4), rung changes 1->2 (5), 2->3 (6), 3->2 (7), 2->1 (8), 3->1 (9: the cash-out), frames at > 4.2 m in cup 2
/ 3 (10 11), frames guarding (or drinking) in cup 2 / 3 (12 13), the last form (14: -1 none).")

(defun cup-acc-reset ()
  (dotimes (i 2) (let ((a (svref *cup-acc* i))) (fill a 0) (setf (aref a 14) -1))))

(defun cup-acc-step ()
  "Per battle step outside cinematics: every Kenpachi side's cup bookkeeping (CUP-ACC-LINE logs it)."
  (when (and (eq *flow* :battle) (not *cine*) (entity-alive-p *p1*) (entity-alive-p *p2*))
    (dolist (e (list *p1* *p2*))
      (let* ((f (fighter e)) (a (svref *cup-acc* (fighter-side f)))
             (c (and (eq (fighter-character f) :kenpachi)
                     (position (fighter-form f) '(:nozarashi :ryote :nomihose :bankai :kataude))))
             (last (aref a 14)))
        (when c
          (incf (aref a c))
          (let ((k (cond ((and (= last 0) (= c 1)) 5) ((and (= last 1) (= c 2)) 6) ((and (= last 2) (= c 1)) 7)
                         ((and (= last 1) (= c 0)) 8) ((and (= last 2) (= c 0)) 9))))
            (when k (incf (aref a k))))
          (when (<= 1 c 2)
            (when (> (fighter-dist f) 4.2) (incf (aref a (+ 9 c))))
            (when (member (fighter-state f) '(:guard :guard-hit)) (incf (aref a (+ 11 c))))))
        (setf (aref a 14) (or c -1))))))

(defun cup-acc-line ()
  "The gate row's companion: a \"duel cups\" line per side that was awakened Kenpachi."
  (dotimes (i 2)
    (let ((a (svref *cup-acc* i)))
      (when (plusp (+ (aref a 0) (aref a 1) (aref a 2) (aref a 3) (aref a 4)))
        (log-msg "duel cups seed ~d P~d vs ~a frames ~{~d~^ ~} up12 ~d up23 ~d dn32 ~d dn21 ~d cash ~d far ~d ~d guard ~d ~d"
                 *match-seed* (1+ i) (fighter-character (fighter (if (zerop i) *p2* *p1*)))
                 (coerce (subseq a 0 5) 'list) (aref a 5) (aref a 6) (aref a 7) (aref a 8) (aref a 9)
                 (aref a 10) (aref a 11) (aref a 12) (aref a 13))))))

(defun hash-log ()
  (when *pacing-log* (band-acc-step) (cup-acc-step))   ; (the gate's lines only: off in play)
  (when (and (eq *flow* :battle) (plusp *match-tick*) (zerop (mod *match-tick* 600)))
    (log-msg "~a" (state-hash-line)))
  (when (and *gate-log* (eq *flow* :battle) (plusp *match-tick*) (zerop (mod *match-tick* 60)))   ; pace.py reads these
    (log-msg "pace t=~d~{ ~a~}" *match-tick*
             (loop for e in (list *p1* *p2*) for g = (gauges e)
                   collect (format nil "| ~a m~d r~d g~d~:[~;!~] k~d w~d" (fighter-form (fighter e)) (round (gauges-meter g))
                                   (gauges-reishi g) (round (gauges-gg g)) (gauges-guardless g) (gauges-konpaku g)
                                   (round (gauges-awaken g)))))))

(defvar *gate-difficulty* :normal "Debug 81020+i: the gates' CPU difficulty (0 EASY 1 NORMAL 2 HARD; ASSIST's gate).")

(defun start-cvc (seed pair)
  "Seeded CPU vs CPU (*GATE-DIFFICULTY*, NORMAL): PAIR = (c1 c2), or NIL to draw both from SEED."
  (setf *match-seed* seed *mode* :cpu-cpu *difficulty* *gate-difficulty* *blow-aways* 0)
  (band-acc-reset) (cup-acc-reset) (pacing-reset)
  (setf *pacing-log* t)                                 ; (the pacing lines: PACE, BAND- / CUP-ACC-STEP)
  (sim-rnd-seed seed)
  (setf *picks* (or pair (let ((r (playable-roster)))   ; (the retired out: 2026-10-12)
                           (list (nth (floor (* (length r) (sim-rnd01))) r) (nth (floor (* (length r) (sim-rnd01))) r)))))
  (start-match))

(defvar *gate* nil "Seed gate: (seed pair) matches still to run.")
(defvar *gate-results* nil "(pair secs ko-p) of the finished gate matches.")
(defparameter *pairs-0* '((:yamamoto :yamamoto) (:yamamoto :kenpachi) (:kenpachi :kenpachi)
                          (:rukia :yamamoto) (:rukia :kenpachi) (:rukia :rukia)
                          (:ichigo :yamamoto) (:ichigo :kenpachi) (:ichigo :rukia) (:ichigo :ichigo)
                          (:senjumaru :yamamoto) (:senjumaru :kenpachi) (:senjumaru :rukia) (:senjumaru :senjumaru)
                          (:senjumaru :ichigo))
  "The first five characters' fifteen pairings in their historical order (pairing k 0-14; YK has P1 Yamamoto, and SS comes
before SI: Senjumaru's pairings were gated before Ichigo joined).")

(defun roster-pairs ()
  "Every seed-gate pairing: *PAIRS-0*, then for each later roster character i (index 5 on) its pairings with every earlier
character (P1 i), then its mirror, in roster order (pairing k = the position here: tools/simgate.py builds the same list)."
  (append *pairs-0*
          (loop for i from 5 below (length *roster*) for c = (nth i *roster*)
                append (loop for j from 0 to i collect (list c (nth j *roster*))))))

(defparameter *pairs* (roster-pairs) "ROSTER-PAIRS (refreshed by START-GATE, whatever the kit files' load order).")

(defun char-pairs (i)
  "Roster character I's pairings, in *PAIRS* order: those with I and no later character (Rukia's RY RK RR, Senjumaru's SY SK
SR SS SI; a new character's: its pairings with every earlier character and its mirror)."
  (remove-if-not (lambda (pair) (= i (max (position (first pair) *roster*) (position (second pair) *roster*)))) *pairs*))

(defvar *gate-seed0* 0 "Debug 30000+k: the seed gate plays seeds k+1 .. k+N (the 60-seed A/B in three runs).")
(defvar *gate-seeds* 20 "Debug 31100+n: seeds per pairing N (the quick pass plays 10; the user 2026-09-29: two-stage gates).")
(defun start-gate (p)
  "The seed gate of P: 0-2 pairing p, 3 every pairing, 4 Rukia's three (= 102), 5 RY and RK, 10+k pairing k alone,
100+i roster character i's pairings (CHAR-PAIRS: 104 Senjumaru's five). A pairing that doesn't exist: a log line, no gate."
  (setf *pairs* (roster-pairs))
  (let ((pairs (cond ((= p 3) (remove-if (lambda (pr) (or (member (first pr) *retired*) (member (second pr) *retired*)))
                                         *pairs*))   ; (every pairing: the retired's out, 2026-10-12) ((= p 4) (char-pairs 2)) ((= p 5) (subseq *pairs* 3 5))
                     ((>= p 100) (and (< (- p 100) (length *roster*)) (char-pairs (- p 100))))
                     (t (let ((k (if (< p 10) p (- p 10))))   ; (10+k: pairing k alone)
                          (and (< k (length *pairs*)) (list (nth k *pairs*))))))))
    (unless pairs
      (return-from start-gate (log-msg "duel gate: no pairing for ~d (~d pairings)" p (length *pairs*))))
    (setf *turbo* t *skip-cines* nil *combat-log* nil *gate-log* nil *gate-results* nil
          *gate* (loop for pair in pairs
                       append (loop for seed from (1+ *gate-seed0*) to (+ *gate-seed0* *gate-seeds*) collect (list seed pair)))))
  (gate-update))

(defvar *gate-busy* nil "A gate match is running.")
(defvar *learn-gate* nil "The learning gate running (START-LEARN-GATE): (habit learn-p).")

(defun gate-update ()
  "Per frame: record a finished gate match, start the next, summarise at the end."
  (when (and *gate-busy* (eq *flow* :results))
    (push (list *picks* (/ (match-play-ticks) 60.0)          ; (the length without the cinematics: MATCH-PLAY-TICKS)
                (or (zerop (gauges-konpaku (gauges *p1*))) (zerop (gauges-konpaku (gauges *p2*)))))
          *gate-results*)
    (log-msg "duel gate row seed ~d ~a ~a secs ~,1f winner ~a forms ~a ~a blow ~d" *match-seed* (first *picks*) (second *picks*)
             (/ (match-play-ticks) 60.0) (case *winner* (0 "P1") (1 "P2") (t "DRAW"))
             (fighter-form (fighter *p1*)) (fighter-form (fighter *p2*)) *blow-aways*)   ; (the gamble A/B reads the final forms)
    (log-msg "duel evo seed ~d P1 ~,1f P2 ~,1f secs ~,1f" *match-seed*   ; the first EVOLUTION per side (-1: none)
             (/ (gauges-evo-t (gauges *p1*)) 60.0) (/ (gauges-evo-t (gauges *p2*)) 60.0) (/ (match-play-ticks) 60.0))
    (band-acc-line) (cup-acc-line)
    (senju-acc-line) (ichigo-acc-line) (barro-acc-line) (hisagi-acc-line) (rukia-acc-line)
    (when *learn-gate* (learn-gate-line))
    (setf *gate-busy* nil))
  (unless *gate-busy*
    (cond (*gate* (destructuring-bind (seed pair) (pop *gate*) (start-cvc seed pair)) (setf *gate-busy* t)
                  (when *learn-gate* (learn-gate-setup)))
          (*gate-results*
           (dolist (pair *pairs*)
             (let* ((rs (remove pair *gate-results* :key #'first :test-not #'equal))
                    (secs (sort (mapcar #'second rs) #'<)))
               (when secs
                 (log-msg "duel gate ~a ~a: ~d matches, KOs ~d, median ~,1f s, min ~,1f, max ~,1f | ~{~,0f~^ ~}"
                          (first pair) (second pair) (length secs) (count-if #'third rs)
                          (nth (floor (length secs) 2) secs) (first secs) (car (last secs)) secs))))
           (setf *gate-results* nil *turbo* nil *learn-gate* nil)))))

;;; ---------------------------------------------------------------- the learning CPU's gate (docs/duel/DUEL_LEARNING.md)
(defvar *dumb-p2* nil "Debug 81040+i: P2 of the learning gate is a button-masher too (ASSIST's anti-mash check).")
(defparameter *habits* #(nil :wake-j :block-guard :grab :hoho :burst :dumb)
  "The scripted players (debug 200000+): 0 a plain CPU, 1 J on every wake-up, 2 guard after every block, 3 grab-happy
(the Breaker at every close neutral decision), 4 Hoho-happy (Hoho at neutral decisions and into every committed move),
5 burst-happy (BLUE at every chance: AI-BURST-ROLL's chance 1), 6 the button-masher (DUMB-STEP: ASSIST's gate). (7-9, the
habits against the old Lille, went with him: 2026-10-13.)")

(defun start-learn-gate (h c1 c2 on)
  "200000 + 1000 H + 100 C1 + 10 C2 + ON: seeds *GATE-SEED0* + 1 .. + *GATE-SEEDS* back to back, P1 (roster C1) a CPU with
habit H (*HABITS*), P2 (roster C2) the CPU, learning when ON (its table fresh at the start, kept in memory across the
matches; 4: model + bandit without its character's own situations, LRN-KIT, DUEL_LILLE §24.9); a \"duel learn row\" per
match."
  (fill *learn-tables* nil)
  (let ((pair (list (nth c1 *roster*) (nth c2 *roster*))))
    (setf *turbo* t *skip-cines* nil *combat-log* nil *gate-log* nil *gate-results* nil *gate-busy* nil
          *gate* (loop for seed from (1+ *gate-seed0*) to (+ *gate-seed0* *gate-seeds*) collect (list seed pair))
          *learn-gate* (list (svref *habits* h) (plusp on) on)
          *learn-use* (case on (2 '(:model)) (3 '(:bandit)) (t '(:model :bandit)))))   ; (4: no kit situations)
  (gate-update))

(defun learn-gate-setup ()
  "A learning-gate match began: P1's habit, P2's learner."
  (setf (brain-habit (brain *p1*)) (first *learn-gate*))
  (when (eq (first *learn-gate*) :dumb) (setf (brain-delay (brain *p1*)) *dumb-delay*))
  (when *dumb-p2* (setf (brain-habit (brain *p2*)) :dumb (brain-delay (brain *p2*)) *dumb-delay*))
  (when (second *learn-gate*)
    (learn-attach! *p2*)
    (when (eql (third *learn-gate*) 4) (setf (lrn-kit (brain-learn (brain *p2*))) nil))))   ; (the kit situations' A/B)

(defun learn-gate-line ()
  "The learning gate's row: the result, damage, P2's counter-hits, its reads (and those that paid), p_exploit, the form."
  (let* ((l (brain-learn (brain *p2*))) (tab (and l (lrn-tab l))))
    (log-msg "duel learn row seed ~d habit ~a ~a ~a learn ~:[off~;on~] winner ~a dealt ~d ~d counters ~d ~d reads ~d paid ~d pexp ~,2f form ~,2f~@[ model~{ ~a~}~]~@[ by~{ ~{~(~a~)~* ~d/~d~}~}~]~@[ kit~{ ~a~}~]"
             *match-seed* (first *learn-gate*) (first *picks*) (second *picks*) l (case *winner* (0 "P1") (1 "P2") (t "DRAW"))
             (gauges-dealt (gauges *p1*)) (gauges-dealt (gauges *p2*)) (gauges-counters (gauges *p1*)) (gauges-counters (gauges *p2*))
             (if l (lrn-reads l) 0) (if l (lrn-paid l) 0) (if tab (learn-p-exploit (ltab-form tab)) 0.0) (if tab (ltab-form tab) 0.0)
             (and tab (loop for k across *learn-situations* for i from 0    ; the model's prediction per situation
                            collect (multiple-value-bind (act p n) (learn-predict tab i)
                                      (format nil "~(~a~)=~:[-~;~:*~(~a~)~]~,2f/~,1f" k (and act (aref *learn-actions* act)) p n))))
             (and l (mapcar (lambda (x) (list (first x) nil (second x) (third x))) (lrn-stats l)))
             (and tab (lrn-kit l)                                  ; its character's own situations' predictions (§24.9)
                  (loop for k across (getf (lrn-kit l) :situations) for i from 0
                        collect (multiple-value-bind (act p n) (learn-kit-predict tab i)
                                  (format nil "~(~a~)=~:[-~;~:*~(~a~)~]~,2f/~,1f" k (and act (aref (getf (lrn-kit l) :actions) act)) p n)))))))

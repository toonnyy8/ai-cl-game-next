;;;; practice.lisp — PRACTICE's sim side (REFACTOR_2026-11 §11.5.7 item 7, R15c, 2026-11-14): its options in one record (*PRACTICE*, a
;;;; PRACTICE-OPTS: the pause menu's rows and the P1 AWAKEN latch), the dummy's input (P2's BRAIN presses: the guard, GUARD ALL's cancel
;;;; with a :core kit, COUNTER), the refill (PRACTICE-REFILL: pure, the values the rows and options give one side's gauges) and the P1
;;;; AWAKEN row. PRACTICE-STEP is the one place that writes them, each sim frame of a PRACTICE battle (flow.lisp MATCH-SYSTEM); the
;;;; screens (flow.lisp: the pause rows PAUSE-LABEL / PAUSE-DO, RESET POSITION, a K.O.) read and write the record. Nothing here is saved
;;;; (control.lisp *SETTINGS* has no PRACTICE row): the options last until the page reloads, across matches and resets.
;;;; The dummy's pure rules (DUMMY-GUARD-LEFT, DUMMY-COUNTER-NOW-P, DUMMY-CANCEL-PRESS, PRACTICE-REISHI) are control.lisp's.
(in-package :duel)

(defparameter *dummies* '((:stand . "STAND") (:guard-all . "GUARD ALL") (:guard-hit . "GUARD AFTER HIT") (:cpu . "CPU"))
  "The DUMMY option: stands, guards everything, guards after a hit lands (control.lisp DUMMY-GUARD-LEFT), the CPU at
the chosen difficulty.")
(defparameter *practice-fs-levels* '("KEEP" "FULL" "ONE CELL" "EMPTY")
  "PRACTICE's FLASH STEP row (DUEL_SP §8.4 S9): KEEP (normal play) / FULL (*FS-MAX*) / ONE CELL (*FS-CELL*) / EMPTY (0), both sides.")
;; PRACTICE's P1 AWAKEN (the user, 2026-10-31: 「練習模式的數值調控增加覺醒量表等級」): the stage of P1's awakening gauge, SUBLIMATION and SPIRIT DRIVE
(defparameter *practice-aw-levels*
  '(("0" :gauge 0) ("50" :gauge 50) ("FULL" :gauge 100) ("SUBLIMATION 50" :sub 50) ("SUBLIMATION FULL" :sub 100) ("DRIVE 50" :drive 50) ("DRIVE FULL" :drive 100))
  "(label kind value): :gauge the awakening gauge at VALUE (%); :sub the gauge full and SUBLIMATION at VALUE; :drive SPIRIT DRIVE at VALUE once he is awakened
(awaken him with the gauge full first: it is set full until he is).")

(defstruct (practice-opts (:conc-name po-) (:copier nil) (:predicate nil))
  "PRACTICE's options, one record (*PRACTICE*). Not a component: SPAWN-PAIR clears the entities at every start and RESET POSITION, and
the options outlive both."
  (dummy :stand)                  ; DUMMY: a key of *DUMMIES*
  (counter nil)                   ; COUNTER: J1 (T: the dummy hits back with J1 as each hit / block reaction ends, any DUMMY but CPU;
                                  ; control.lisp DUMMY-COUNTER-NOW-P) / OFF
  (refill t)                      ; HP REFILL: AUTO (T: the dummy's Reishi at its row again once a combo on it ends) / OFF
  (inf nil)                       ; GAUGES: INFINITE (T: P1's Reishi at its P1 HP row; guard, flash step, Awakening full) / NORMAL
  (fs 0 :type fixnum)             ; FLASH STEP: the index in *PRACTICE-FS-LEVELS*; not KEEP: both sides' flash-step held at that value
                                  ; (after INFINITE, so it overrides the flash-step INFINITE sets for P1); a running burst is left to drain
  (rows (vector 100 *konpaku-max* 100 *konpaku-max*))   ; P1 HP (%), P1 KONPAKU, DUMMY HP (%), DUMMY KONPAKU: what RESET POSITION and
                                  ; the refills restore (full by default: the rows only change what "full" means); index side * 2 (+ 1 Konpaku)
  (aw 0 :type fixnum)             ; P1 AWAKEN: the index in *PRACTICE-AW-LEVELS*
  (aw-done t))                    ; has that level been applied to P1 (a :drive level waits until he is awakened)?
(inline-readers practice-opts)
(defvar *practice* (make-practice-opts) "PRACTICE's options (the pause menu's rows; PRACTICE-STEP's input).")

(defun practice-fs-value (o)
  "The flash-step the FLASH STEP row of options O holds both sides at, or NIL (KEEP)."
  (case (po-fs o) (1 *fs-max*) (2 *fs-cell*) (3 0f0)))

(defun practice-refill (o side g state)
  "PRACTICE's refill, pure: what options O give the gauges G of side SIDE (0 P1, 1 the dummy; G only read) with the fighter in STATE.
Values, each NIL = left as it is: Reishi, Konpaku, the guard gauge (non-NIL also clears GUARDLESS), flash-step, the awakening gauge,
SUBLIMATION, SPIRIT DRIVE. The dummy: Konpaku at its DUMMY KONPAKU row always (no match end after a Kikon), Reishi at its DUMMY HP row
with HP REFILL AUTO once it is out of its hit / block reactions. P1 with GAUGES INFINITE: Reishi at his P1 HP row, the guard gauge, the
flash-step (not in a burst: it burns down first, the user 2026-09-30), SPIRIT DRIVE once awakened (DUEL_SUBLIMATION §17.4), else the
awakening gauge and SUBLIMATION full. Then FLASH STEP not KEEP, both sides and not in a burst: the flash-step at its value (it wins).
The knobs come back as they are (no float arithmetic: PRACTICE-STEP stays allocation-free)."
  (let* ((rows (po-rows o)) (burst (gauges-burst g))
         (hp (practice-reishi (gauges-reishi-max g) (svref rows (* 2 side))))
         (fv (practice-fs-value o))
         (inf (and (= side 0) (po-inf o)))
         (aw (and inf (gauges-awakened g))))
    (values (cond ((= side 1) (and (po-refill o) (not (member state '(:stun :air :down :wakeup :guard-hit))) hp))
                  (inf hp))
            (and (= side 1) (svref rows 3))
            (and inf *gg-max*)
            (cond (burst nil) (fv (f32 fv)) (inf *fs-max*))
            (and inf (not aw) *awaken-max*)
            (and inf (not aw) *sub-max*)
            (and aw *drive-max*))))

(defun practice-refill! (e state)
  "Write PRACTICE-REFILL's values for fighter E (in STATE) into its gauges."
  (let ((g (gauges e)))
    (multiple-value-bind (reishi konpaku gg fs awaken sub drive) (practice-refill *practice* (fighter-side (fighter e)) g state)
      (when reishi (setf (gauges-reishi g) reishi))
      (when konpaku (setf (gauges-konpaku g) konpaku))
      (when gg (setf (gauges-gg g) gg (gauges-guardless g) nil))
      (when fs (setf (gauges-fs g) fs))
      (when awaken (setf (gauges-awaken g) awaken))
      (when sub (setf (gauges-sub g) sub))
      (when drive (setf (gauges-drive g) drive)))))

(defun practice-aw-apply! ()
  "P1's awakening gauge, SUBLIMATION and SPIRIT DRIVE to the P1 AWAKEN row (a row changed, RESET POSITION). A fighter already awakened keeps the gauge as it is
for the pre-awakening levels; a :drive level takes effect as soon as he is awakened."
  (destructuring-bind (label kind v) (nth (po-aw *practice*) *practice-aw-levels*)
    (declare (ignore label))
    (let ((g (gauges *p1*)) (o *practice*))
      (case kind
        (:gauge (unless (gauges-awakened g) (setf (gauges-awaken g) (f32 (* v 0.01 *awaken-max*)) (gauges-sub g) 0f0 (gauges-aw-full g) nil)) (setf (po-aw-done o) t))   ; (a row below full clears the switch's latch too)
        (:sub (unless (gauges-awakened g) (setf (gauges-awaken g) *awaken-max* (gauges-sub g) (f32 (* v 0.01 *sub-max*)))) (setf (po-aw-done o) t))
        (:drive (if (gauges-awakened g)
                    (setf (gauges-drive g) (f32 (* v 0.01 *drive-max*)) (po-aw-done o) t)
                    (progn (setf (gauges-awaken g) *awaken-max*) (setf (po-aw-done o) nil)))))
      (log-msg "duel practice awaken level ~a: awaken ~,0f sub ~,0f drive ~,0f awakened ~a" (first (nth (po-aw o) *practice-aw-levels*))
               (gauges-awaken g) (gauges-sub g) (gauges-drive g) (and (gauges-awakened g) t)))))

(defun practice-hp (e) "E's Reishi at its practice HP row." (practice-reishi (gauges-reishi-max (gauges e)) (svref (po-rows *practice*) (* 2 (fighter-side (fighter e))))))
(defun practice-set! (e)
  "E's Reishi and Konpaku to its practice rows (a row changed, RESET POSITION, a K.O.)."
  (setf (gauges-reishi (gauges e)) (practice-hp e)
        (gauges-konpaku (gauges e)) (svref (po-rows *practice*) (1+ (* 2 (fighter-side (fighter e)))))))

(defun practice-dummy! ()
  "P2's brain for the DUMMY option: the CPU, or switched off holding nothing (PRACTICE-STEP holds its guard)."
  (let ((b (brain *p2*)))
    (setf (brain-off b) (not (eq (po-dummy *practice*) :cpu)) (brain-press-left b) 0 (brain-act b) nil)))

(defun dummy-starts (f)
  "What a press could start for the PRACTICE dummy's fighter F now, as DUMMY-CANCEL-PRESS takes them: (PRESS CLASS D-MIN D-MAX LEN HF).
Free: J (NA1) and SP (its pointer's NS) on the next step. In a move whose latch is empty: in an NS segment the next segment (SP) and the
SA (J); in an AS segment the next one; in an NA link or the SA that touched him (its chain open) the next J link: each starts when the
current move's active frames end, until its recovery does. (No AS: the dummy's own attack seldom lands first.)
Known (left for a later batch, R15c 2026-11-14): the free SP is offered without the SP-START-P check the real press goes through."
  (let ((kit (fighter-kit f)) (mv (fighter-move f)) (sf (fighter-sf f)))
    (flet ((opt (press m dmin dmax)
             (when m
               (list press (kit-class kit m) dmin dmax (- (+ (mv-s m) (mv-a m)) (mv-enter m))
                     (if (plusp (length (mv-hits m))) (- (mv-first-hit m) (mv-enter m)) 999)))))   ; (no melee hit of its own: never in his window)
      (cond ((and (member (fighter-state f) '(:idle :run)) (zerop (fighter-lock f)) (zerop (fighter-guard-exit f)))
             (remove nil (list (opt :j (kit-move kit (getf (kit-commands kit) :q)) 1 most-positive-fixnum)
                               (opt :sp (kit-core-move kit :ns (fighter-ptr f)) 1 most-positive-fixnum))))
            ((and (eq (fighter-state f) :move) (eq (fighter-phase f) :main) (null (fighter-queued f)))
             (let ((dmin (max 1 (- (+ (mv-s mv) (mv-a mv)) sf))) (dmax (- (mv-total mv) sf 1))
                   (nx (mv-ns-next kit mv)))
               (when (<= dmin dmax)
                 (case (fighter-cls f)
                   (:ns (remove nil (list (and nx (core-seg-ok-p f nx) (opt :sp nx dmin dmax))
                                          (opt :j (or (fighter-csa f) (mv-sa-move kit mv) (kit-sa-move kit)) dmin dmax))))
                   (:as (and nx (list (opt :sp nx dmin dmax))))
                   ((:na :sa) (and (eq (fighter-contact f) :hit) (list (opt :j (kit-next kit (mv-name mv) :q) dmin dmax))))))))))))

(defun dummy-wave-threat (e o)
  "The soonest of O's classed waves to reach E standing (WAVE-ARRIVAL): values its frames and class, or NIL (GUARD ALL, DUEL_SP §6, S5)."
  (let ((best nil) (cls nil) (q (pos-of e)) (r (body-hurt-r (model-body (model e)))))
    (do-entities (h (hz hazard))
      (when (and (eql (hazard-owner hz) o) (eq (hazard-kind hz) :wave) (hazard-cls hz) (hazard-active-p hz))
        (let ((k (wave-arrival (- (aref q 0) (hazard-x hz)) (- (aref q 2) (hazard-z hz)) (hazard-yaw hz) (* (hazard-speed hz) +step+)
                               (hazard-size hz) (second *wave-box*) r (- (hazard-life hz) (hazard-age hz)))))
          (when (and k (or (null best) (< k best))) (setf best k cls (hazard-cls hz))))))
    (values best cls)))

(defun dummy-cancel-input (f pf)
  "GUARD ALL with a :core dummy (fighter F) against the player's fighter PF: this frame's press (DUMMY-CANCEL-PRESS: :J, :SP or NIL).
His hit counts only from a move's main phase (not a Kikon's follow-up) within its reach + slide + *DUMMY-CANCEL-REACH* (a swing at the air
is no threat), or one of his classed waves on its way (DUMMY-WAVE-THREAT, the sooner of the two; DUEL_SP §6, S5: the dummy tries to cancel waves too)."
  (let* ((pm (fighter-move pf)) (psf (fighter-sf pf))
         (h (and (eq (fighter-state pf) :move) (eq (fighter-phase pf) :main)
                 (<= (fighter-dist f) (+ (mv-reach pm) (mv-slide pm) *dummy-cancel-reach*))   ; ponytail: one slack; a chase / dash table if a move outruns it
                 (next-window-lead pm psf (fighter-hits pf))))
         (own (core-window-class f))
         (own-left (if own (- (+ (mv-s (fighter-move f)) (mv-a (fighter-move f))) (fighter-sf f)) 0)))
    (multiple-value-bind (wk wc) (dummy-wave-threat *p2* *p1*)
      (cond ((and wk (or (null h) (< wk h))) (dummy-cancel-press wk 0 wc own own-left (dummy-starts f)))
            (h (dummy-cancel-press h (max 0 (- (+ (mv-s pm) (mv-a pm)) psf h)) (fighter-cls pf) own own-left (dummy-starts f)))))))

(defun dummy-press! (f b)
  "The dummy's (fighter F, brain B) press this frame for the DUMMY and COUNTER options (none with DUMMY CPU: its brain plays): GUARD ALL with
a :core kit its cancelling press (DUMMY-CANCEL-INPUT) or nothing (a core kit has no guard), else the guard DUMMY-GUARD-LEFT holds; COUNTER
J1 as a reaction ends (BRAIN-STEP writes it, the guard let go)."
  (let ((dummy (po-dummy *practice*)))
    (unless (eq dummy :cpu)
      (let ((cancel (and (eq dummy :guard-all) (kit-core (fighter-kit f)) (dummy-cancel-input f (fighter *p1*)))))
        (cond (cancel (setf (brain-press b) :quick (brain-press-mod b) (eq cancel :sp) (brain-press-left b) 1))   ; J or SP, one step
              ((and (eq dummy :guard-all) (kit-core (fighter-kit f))) (setf (brain-press-left b) 0))           ; (a core kit: no guard)
              (t (setf (brain-press b) :guard (brain-press-mod b) nil
                       (brain-press-left b) (dummy-guard-left dummy (fighter-state f) (brain-press-left b)))))
        (when (and (po-counter *practice*) (not cancel) (dummy-counter-now-p (fighter-state f) (fighter-sf f) (fighter-stun f) (fighter-glock f)))
          (setf (brain-press b) :quick (brain-press-mod b) nil (brain-press-left b) 1))))))

(defun practice-step ()
  "PRACTICE, each sim frame (flow.lisp MATCH-SYSTEM): the dummy's press (DUMMY-PRESS!), its refill (PRACTICE-REFILL!), P1's AWAKEN row
while a :drive level waits for his awakening, then P1's refill (GAUGES INFINITE, FLASH STEP). The order is the old one: the dummy's
gauges, the AWAKEN row, P1's (the AWAKEN row writes P1's gauges only)."
  (let ((f (fighter *p2*)))
    (dummy-press! f (brain *p2*))
    (practice-refill! *p2* (fighter-state f)))
  (unless (po-aw-done *practice*) (practice-aw-apply!))   ; a :drive level, once he is awakened
  (practice-refill! *p1* (fighter-state (fighter *p1*))))

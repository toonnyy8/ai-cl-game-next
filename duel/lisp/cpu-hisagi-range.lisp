;;;; cpu-hisagi-range.lisp — Hisagi's distance control in the Bankai's ranged mode, a strategy's code (docs/duel/DUEL_AI_STRATEGY.md §8.16).
;;;; The user, 2026-11-09: 「檜佐木要注意控制距離，尤其是卍解後遠距模式的近身戰非常不利，需要主動後撤或是利用 NS1a 與 NS2b 來拉開與對手的距離。」
;;;; and 「記得將消耗 drive 量表來臨時切換 NS 的戰術也安排到策略中」.
;;;; HISAGI-RANGE-STYLE is a strategy's :FN (library :h1-range, seed s8-hisagi-range.lisp), never a registered matchup style: it runs first
;;;; on every step the CPU is free to press (CORE-BRAIN-STEP) and returns T only where it steers; everywhere else NIL, so the MCTS and the
;;;; generic core CPU decide (the Shikai, the bind mode, the ranged mode at range, every move but WA / TABA, stun, air, Step), under the
;;;; strategy's data in every form: :DSWITCH (CAI-DSWITCH's band rule, the Shikai's NS1 > NS3a map) and its :DN rules (no NS out of reach).
;;;;   close   free in the ranged mode, the opponent perceived inside J1's dead zone (every 散 volume's 3 m; NS1a 環 WA reaches 0-3 m), or
;;;;           inside 3.4 m while he closes in (then the back Step only):
;;;;           one roll per close event (*HR-P*): his attack starting at him: the back Step (invulnerable 3-9, the ranged Step lands in a
;;;;           tip band, HS-STEP-DIST); pointer 1: NS1a WA (a hit pushes him to 4.5 m); pointer 2 at 2.5-2.9 m: NS2a TABA, then NS2b
;;;;           TATAKI in its gap (push to 3.5 m), one roll (*HR-TABA-P*); else the back Step; cornered at the arena's edge: WA, else a
;;;;           side Step.
;;;;   WA gap  a hit: the DRIVE switch to pointer 2's TABA (the user's route, DUEL_SUBLIMATION §17.7: 「卍解也能直接用 NS1a 控制距離再
;;;;           切換成 NS2 的聚拉高輸出」) when the strategy's :DSWITCH roll says so and the gauge allows, else NS1b ŌGI (3-6 m, he is at
;;;;           4.5); a whiff with him still close: the route stops (the next free step is a close event again).
;;;;   home    a ranged J string's J2 landing ends in AS1 (*HR-HOME-P*; pointer 1: WA stays his NS, pointer 2's damage by the switch).
;;;;   TABA gap  him inside 2.9 m: NS2b TATAKI (the push); 2.5-4.5 m: J, the gathered SA (TABA > SA > J2, §17.7's 150); else stop.
;;;; Every roll once per event (sim-rnd01, by difficulty); the state in BRAIN-STYLE.
(in-package :duel)

(defvar *mc-plan*)                                       ; (cpu-mcts.lisp gives it its value)

(defparameter *hr-p* '(:easy 0.25 :normal 0.6 :hard 1.0)
  "Per close event (the opponent perceived inside *HR-CLOSE* while he is free in the ranged mode; a new one each time he is free again):
take it (the back Step, WA, TABA). Else the MCTS / generic CPU decides that event. 2026-11-09, mine (DUEL_AI_STRATEGY §8.16).")
(defparameter *hr-close* 2.9
  "Close (m, perceived): inside J1's / every 散 volume's 3.0 m dead zone and WA's 3.0 m reach, less 0.1 (his view is 8-24 frames old).")
(defparameter *hr-near* 3.4
  "Closing in (m, perceived): while the opponent's perceived distance falls (he walks or runs in) the close rule starts here already, with
the back Step only (WA reaches 3.0): his view is 8-24 frames old, and in scene 83802 he started J1 at a perceived 3.4 m against a real 2.4 m
(J1's dead zone 3.0: a whiff, then Kenpachi's 65 + 30 + 90). 2026-11-09, mine.")
(defparameter *hr-wa-pred* 2.8
  "Closing in (*HR-NEAR*), pointer 1: WA when his distance predicted at WA's hit (the perceived one less his closing speed x (the brain's
delay + WA's 14 frames)) is within this (m; WA reaches 3.0), else the back Step.")
(defparameter *hr-taba-p* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "Pointer 2, per close event at *HR-TABA-BAND*: NS2a TABA (S 30), then NS2b TATAKI in its gap (the push), rather than the back Step. 0.5
at HARD -> 0 (scene 83808: TABA from 2.7 m, Kenpachi's J1 cancelled it and his AS1 hit 90 one frame before TATAKI's start; NS2b stays
TABA's follow-up wherever TABA starts: the switch route, the MCTS's). 2026-11-09, mine.")
(defparameter *hr-taba-band* '(2.5 2.9) "Where a neutral TABA hits (its dead zone 2.5 m) and TATAKI (0-3 m) follows.")
(defparameter *hr-edge* 2.0
  "Cornered: within this (m) of the arena's wall with the back Step pointing outward (the hop would gain nothing): WA, else a side Step.")
(defparameter *hr-home-p* '(:easy 0.0 :normal 0.4 :hard 0.7)
  "Pointer home: in the ranged mode, per J string whose J2 lands: the SP there (AS1 RANSA, 3-6 m, writes pointer 1), so WA (NS1a, the
close push) stays his NS and pointer 2's damage comes through the DRIVE switch; the rest of the strings run on (J3 > AS2, J5 > AS3's bind).
In the scenes the shipped string ran J1-J3 into AS2 (pointer 2), after which a close opponent left him only the back Step. 2026-11-09, mine.")
(defparameter *hr-sa-band* '(2.5 4.5) "The TABA gap's gathered SA (2.5-4.5 m, 90 deg).")

(defvar *hr-counts* (make-array 16 :element-type 'fixnum :initial-element 0)
  "A tool's counters (not sim state, never read in play; outside rollouts only), per side 8: close events, taken, WA, TABA, back Steps,
side Steps, switches, TATAKI. Reset and printed by tools/simgate/strat-run.lisp STRAT_HRANGE.")
(defun hr-count (f i) (unless *in-rollout* (incf (aref *hr-counts* (+ i (* 8 (fighter-side f)))))))

(defstruct (hrs (:constructor make-hrs ()))
  (on nil)                      ; inside a close event
  (go nil)                      ; its roll said yes
  (taba nil)                    ; its TABA roll said yes (pointer 2)
  (seg -1 :type fixnum)         ; the WA / TABA segment (its CLS-T) the gap was decided for
  (hk -1 :type fixnum)          ; the J2 (its CLS-T) the pointer-home roll was made for
  (pd 99.0 :type single-float)  ; the perceived distance at his last free step (closing in: it falls)
  (tick 0 :type fixnum))        ; *MATCH-TICK* at his last call (a lower one: a new match)
(inline-readers hrs)

(defun hr-cornered-p (e)
  "Would E's back Step run into the wall (within *HR-EDGE* of it, the opponent between him and the centre)?"
  (let* ((p (pos-of e)) (q (pos-of (opp-of e))) (x (aref p 0)) (z (aref p 2)))
    (and (> (+ (* x x) (* z z)) (expt (- *arena-radius* *hr-edge*) 2))
         (plusp (+ (* x (- x (aref q 0))) (* z (- z (aref q 2))))))))

(defun hr-taken (b f)
  "He pressed: the MCTS plan made a reaction time ago is dropped (its job ends), the event is over."
  (setf (aref *mc-plan* (* 5 (fighter-side f))) 0)
  (setf (brain-decide-t b) (max (brain-decide-t b) 2)))

(defun hr-sp (b f s)
  "Start his pointer's NS (a tap: no Kikon hold), as the generic neutral does."
  (setf (brain-own-key b) -1 (brain-r-kikon b) 1f0)
  (cai-sp b f s))

(defun hr-close (e b f s d st)
  "Free in the ranged mode: the close rule. T when it pressed."
  (let* ((v (if (> (hrs-pd st) 50.0) 0.0 (max 0.0 (- (hrs-pd st) d))))   ; (his perceived closing speed, m a step; none on his first free step)
         (closing (> v 0.004))
         (near (and (not (< d *hr-close*)) closing (< d *hr-near*)))
         (cine (member (snap-state s) '(:cine :intro)))
         (close (or near (< d *hr-close*))))
    (setf (hrs-pd st) (f32 d))
    (cond ((or cine (>= d *hr-near*)) (setf (hrs-on st) nil) nil)   ; (the event ends out of *HR-NEAR*: no re-roll as he wavers)
          ((not (or close (hrs-on st))) nil)
          (t (unless (hrs-on st)
               (setf (hrs-on st) t (hrs-go st) (brain-roll b *hr-p*) (hrs-taba st) (brain-roll b *hr-taba-p*))
               (hr-count f 0)
               (when (hrs-go st) (hr-count f 1)))
             (when (and (hrs-go st) close)
               (let* ((reel (member (snap-state s) '(:stun :air :down :wakeup)))
                      (attack (and (eq (snap-state s) :move) (snap-move s) (< (snap-sf s) (+ (snap-s s) 2)) (< d (+ (snap-reach s) 0.5))))
                      (corner (hr-cornered-p e)) (ptr (fighter-ptr f)))
                 (cond ((and attack (not corner))
                        (hr-count f 4) (clog "~a hr back-step (his attack) at ~,1f" (side-name e) d) (mc-press b :step-out))
                       ((and (= ptr 1) (not reel) (or (not near) (<= (- d (* v (+ (brain-delay b) 14))) *hr-wa-pred*)))   ; (WA S 14: where he will be)
                        (hr-count f 2) (clog "~a hr WA at ~,1f" (side-name e) d) (hr-sp b f s))
                       ((and (= ptr 2) (not reel) (not near) (hrs-taba st) (<= (first *hr-taba-band*) d (second *hr-taba-band*)))
                        (hr-count f 3) (clog "~a hr TABA at ~,1f" (side-name e) d) (hr-sp b f s))
                       ((not corner) (hr-count f 4) (clog "~a hr back-step at ~,1f" (side-name e) d) (mc-press b :step-out))
                       (t (hr-count f 5) (clog "~a hr side-step at ~,1f" (side-name e) d) (mc-press b :step-side)))
                 (hr-taken b f)
                 t))))))

(defun hr-gap (e b f kit st)
  "In his own WA (NS1a) / TABA (NS2a) segment: wait for its active frames (the contact known), then the route (see the header). T while
it owns the segment's decision (the generic CAI-MOVE-STEP is kept off it: BRAIN-DECIDED), NIL for any other move."
  (let* ((mv (fighter-move f)) (name (and mv (mv-name mv))) (sf (fighter-sf f)))
    (when (and (member name '(:hs-r-n1a :hs-r-n2a)) (eq (fighter-cls f) :ns) (>= sf (mv-s mv)) (/= (hrs-seg st) (fighter-cls-t f)))
      (setf (brain-decided b) (fighter-cls-t f))           ; (the generic CPU keeps off this segment)
      (when (>= sf (+ (mv-s mv) (mv-a mv)))
        (setf (hrs-seg st) (fighter-cls-t f))
        (let ((d (fighter-dist f)) (hit (eq (fighter-contact f) :hit)))
          (if (eq name :hs-r-n1a)
              (let ((p (strat-out :dswitch nil)))
                (cond ((and hit p (plusp p) (core-switch-open-p e f) (kit-core-move kit :ns 2)
                            (< (sim-rnd01) (* p (brain-chance b *cai-dswitch-dif*))))
                       (hr-count f 6) (cai-switch-press e b f 2))
                      ((and (not hit) (< d 3.0)) (clog "~a hr WA whiffed at ~,1f: stop" (side-name e) d))
                      ((brain-roll b *cai-cont-p*) (cai-press b :quick 1 t))))     ; (ŌGI: he is at 4.5 m, or he backed off)
              (cond ((< d *hr-close*) (hr-count f 7) (cai-press b :quick 1 t))     ; (TATAKI: the push to 3.5 m)
                    ((<= (first *hr-sa-band*) d (second *hr-sa-band*)) (cai-press b :quick 1))   ; (the gathered SA)
                    (t nil)))))
      t)))

(defun hr-home (e b f s st)
  "In his ranged J string: J2 landed, the SP (AS1, pointer 1), one roll per string (else the generic CPU's link). T when it pressed."
  (when (and (eq (fighter-cls f) :na) (eq (fighter-contact f) :hit) (= (fighter-presses f) 2)
             (not (fighter-as-done f)) (/= (brain-decided b) (fighter-cls-t f)) (/= (hrs-hk st) (fighter-cls-t f)))
    (setf (hrs-hk st) (fighter-cls-t f))
    (when (brain-roll b *hr-home-p*)
      (setf (brain-decided b) (fighter-cls-t f))         ; (the generic CPU's AS / link roll for this link is taken)
      (clog "~a hr home: AS1" (side-name e))
      (cai-sp b f s)
      t)))

(defun hisagi-range-style (e b f kit s d)
  "Hisagi's distance control in the Bankai's ranged mode (the file header): T when it decided this step, NIL for the MCTS / generic CPU."
  (let ((st (brain-style b)))
    (when (or (not (hrs-p st)) (< *match-tick* (hrs-tick st))) (setf st (make-hrs) (brain-style b) st))
    (setf (hrs-tick st) *match-tick*)
    (if (not (eq (fighter-form f) :bankai))
        (progn (setf (hrs-on st) nil) nil)
        (case (fighter-state f)
          ((:idle :run) (hr-close e b f s d st))
          (:move (setf (hrs-on st) nil (hrs-pd st) 99f0) (or (hr-home e b f s st) (hr-gap e b f kit st)))
          (t (setf (hrs-on st) nil (hrs-pd st) 99f0) nil)))))

;;; ---------------------------------------------------------------- the merged style (DUEL_AI_STRATEGY §8.17)
;;; The user, 2026-11-09, on the second search's results: 「合併兩種風格」: one style that plays HISAGI-RANGE-STYLE in the Bankai's ranged mode
;;; and Kenpachi's KI style (cpu-ki-ken.lisp KEN-KI-STYLE) elsewhere (the Shikai, the bind mode). Each keeps its own state (BRAIN-STYLE holds
;;; an HMS with both), so a form change resumes the other's where it stopped. The strategy's key :KEN-RANGED (T) also lets Kenpachi's style
;;; decide in the ranged mode where the distance rule leaves the step (it runs first there, so the rule still owns every close event).
;;; The strategy key :SHIKAI-DSWITCH (DUEL_AI_STRATEGY §8.19 round 3; the user, 2026-11-09: 「寫，量過再決定上線」): outside the ranged mode,
;;; in his own NS segment's gap, the strategy's DRIVE switch (CAI-DSWITCH: its :DSWITCH roll, :DSWITCH-MAP, the gauge's rules) gets the gap
;;; first, once per segment; KEN-KI-STYLE decides those gaps itself, so without it CAI-DSWITCH is never reached in the Shikai. Off without the key.
(defstruct (hms (:constructor make-hms ()))
  (range nil)                   ; HISAGI-RANGE-STYLE's state
  (ken nil)                     ; KEN-KI-STYLE's state
  (dseg -1 :type fixnum))       ; the NS segment (its CLS-T) the Shikai's switch roll was made for
(inline-readers hms)

(defun hms-shikai-switch (e b f kit st)
  "In his own NS segment's gap, once per segment: the strategy's DRIVE switch (CAI-DSWITCH). T when it pressed."
  (let ((mv (fighter-move f)))
    (when (and mv (eq (fighter-state f) :move) (eq (fighter-cls f) :ns) (>= (fighter-sf f) (mv-s mv)) (/= (hms-dseg st) (fighter-cls-t f)))
      (setf (hms-dseg st) (fighter-cls-t f))
      (when (cai-dswitch e b f kit)
        (setf (brain-decided b) (fighter-cls-t f))
        t))))

(defun hisagi-merged-style (e b f kit s d)
  "The merged style (the header above): HISAGI-RANGE-STYLE in the ranged mode (:bankai), KEN-KI-STYLE elsewhere. T when it decided."
  (let* ((st (let ((x (brain-style b))) (if (hms-p x) x (setf (brain-style b) (make-hms)))))
         (ranged (eq (fighter-form f) :bankai))
         (r nil))
    (when ranged
      (setf (brain-style b) (hms-range st))
      (setf r (hisagi-range-style e b f kit s d) (hms-range st) (brain-style b)))
    (when (and (not r) (not ranged) (getf (car *strat-now*) :shikai-dswitch))   ; (the Shikai's DRIVE switch, off without the key)
      (setf r (hms-shikai-switch e b f kit st)))
    (when (and (not r) (or (not ranged) (getf (car *strat-now*) :ken-ranged)))
      (setf (brain-style b) (hms-ken st))
      (setf r (ken-ki-style e b f kit s d) (hms-ken st) (brain-style b)))
    (setf (brain-style b) st)
    r))

;;; ---------------------------------------------------------------- the check scenes (debug 83800-83808, DUEL_GAMEPLAY "Debug commands")
(defun hisagi-range-scene (k)
  "83800+k: P1 a HARD CPU Hisagi in the Bankai's ranged mode playing the library's :h1-range, P2 a HARD CPU Kenpachi. 0 pointer 1, DRIVE
60, Kenpachi idle 2.0 m off (his CPU off: WA, then the switch); 1 as 0, DRIVE 20 (no switch); 2 pointer 2, Kenpachi walks in from 2.0 m
(his CPU after 1.2 m); 3 pointer 1, DRIVE 60, Kenpachi 1.8 m off starting J1; 4 as 0 with no strategy (the shipped CPU); 5 as 0, the
strategy without :DSWITCH; 6 / 7 the Shikai, pointer 1, SUBLIMATION 60 / 20, 4.5 m from an idle Kenpachi (his CPU off), P1's NS1 started
(the generic :DSWITCH-MAP route NS1 > NS3a); 8 pointer 1, DRIVE 60, Kenpachi walks in from 5 m; 9 / 10 (DUEL_AI_STRATEGY §8.19 round 3) as 6
with the merged style (:DSWITCH 1.0, the Shikai's map) with / without :SHIKAI-DSWITCH."
  (let* ((lib (find :h1-range *strat-library* :key (lambda (x) (getf x :id))))
         (strat (case k (4 nil) (5 (list* :base (list :dswitch 0.0) lib))
                      (9 '(:id :scene-sdswitch :fn hisagi-merged-style :ken-ranged t :shikai-dswitch t :base (:dswitch 1.0) :dswitch-map ((:base 1 3))))
                      (10 '(:id :scene-nosdswitch :fn hisagi-merged-style :ken-ranged t :base (:dswitch 1.0) :dswitch-map ((:base 1 3))))
                      (t lib)))
         (shikai (member k '(6 7 9 10))))
    (ensure-battle :hisagi :kenpachi :cpu t)
    (place *p1* *p2* (case k (3 1.8) ((6 7 9 10) 4.5) (8 5.0) (t 2.0)))
    (hs-reset *p1*)
    (full-gauges! *p1*) (full-gauges! *p2*)
    (dolist (e (list *p1* *p2*)) (setf (brain-difficulty (brain e)) :hard (brain-delay (brain e)) (getf *ai-delay* :hard) (brain-off (brain e)) nil))
    (when (member k '(0 1 4 5 6 7 9 10)) (setf (brain-off (brain *p2*)) t))
    (if shikai
        (progn (unless (eq (fighter-form (fighter *p1*)) :base) (set-form *p1* :base) (setf (gauges-awakened (gauges *p1*)) nil))
               (setf (gauges-sub (gauges *p1*)) (if (= k 7) 20f0 60f0)))
        (progn (hs-awaken-now! *p1*) (setf (gauges-drive (gauges *p1*)) (if (= k 1) 20f0 60f0))))
    (setf (fighter-ptr (fighter *p1*)) (if (= k 2) 2 1) (brain-strat (brain *p1*)) strat (brain-strat (brain *p2*)) nil (brain-style (brain *p1*)) nil)
    (case k
      (3 (force-cmd *p2* :q))
      ((6 7 9 10) (core-sp-start! *p1* (fighter *p1*)))
      ((2 8) (let ((b2 (brain *p2*)))                       ; (he walks in: the dash act's stick toward P1, let go at 1.2 m)
               (ai-press b2 :none 200 :act :dash)
               (setf (brain-dash b2) 1f0 (brain-dash-to b2) 1.2f0))))
    (log-msg "duel hrange scene ~d ptr ~d drive ~,0f sub ~,0f strat ~a" k (fighter-ptr (fighter *p1*)) (gauges-drive (gauges *p1*))
             (gauges-sub (gauges *p1*)) (and strat (getf strat :id)))))

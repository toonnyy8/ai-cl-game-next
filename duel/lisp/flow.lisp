;;;; flow.lisp — the screens (design-v1 §6): TITLE → MODE (VS CPU / PRACTICE / VS PLAYER / CPU VS CPU /
;;;; SETTINGS / CONTROLS / MANUAL (the page's manual.html, onehand.lisp OPEN-MANUAL); the frozen ENDLESS / DANGAI left main on 2026-11-13,
;;;; branch `frozen-modes`, REFACTOR_2026-11 R4) → SELECT (P1, then P2 / the CPU, then difficulty and, VS CPU / PRACTICE, the camera; both models on the
;;;; plaza) → INTRO → BATTLE (pause: RESUME / RESTART / CHARACTER SELECT / TITLE, VS CPU also CAMERA; PRACTICE: RESUME /
;;;; RESET POSITION / DUMMY / COUNTER / HP REFILL / GAUGES / FLASH STEP / P1 AWAKEN / P1 HP / P1 KONPAKU / DUMMY HP / DUMMY KONPAKU / CHARACTER SELECT /
;;;; TITLE / CAMERA) → FINISH (K.O. / TIME) → RESULTS
;;;; (REMATCH / SELECT / TITLE). SETTINGS (2026-09-28): ONE-HAND MODE (AUTO / ON / OFF), HAND, TAP SPLIT, SENSITIVITY,
;;;; CAMERA, LEARNING CPU (control.lisp *SETTINGS*, saved by onehand.lisp), then RESET LEARNING (fq-online.lisp FQ-RESET-ALL). VS CPU and PRACTICE are one-handed (the thumb deck,
;;;; onehand.lisp) whenever ONE-HAND MODE is in effect there (ONE-HAND-EFFECTIVE-P); there is no separate one-hand entry.
;;;; PRACTICE: P1 against a dummy (P2's brain: switched off and guarding by DUMMY-GUARD-LEFT, or the CPU), no timer and
;;;; no match end (practice.lisp PRACTICE-STEP refills the dummy to its HP / KONPAKU rows; a K.O. is a reset to both sides' rows);
;;;; its options are one record there (*PRACTICE*), which the pause rows here read and write. Menus read the devices directly (either
;;;; player's keys / pads); fighters only ever read their vpad. MATCH-SYSTEM (the timer, time-up; PRACTICE-STEP) is
;;;; the last sim system; the KO comes from a Kikon / Soul Break (combat.lisp AFTER-KIKON → MATCH-OVER).
;;;; Log: "duel -> STATE" per change, "duel setting ..." / "duel practice ..." per option change.
(in-package :duel)

(defparameter *difficulties* '(:easy :normal :hard))

(defvar *flow* :title "Screen: :title :mode :settings :controls :select :intro :battle :finish :results")
(defvar *ft* 0.0 "Real seconds on the current screen.")
(defvar *menu* 0)
(defvar *paused* nil)
(defvar *mode* :vs-cpu "Match mode: :vs-cpu :practice :vs-player :cpu-cpu")
(defun vs-cpu-p () "A human P1 against the CPU: VS CPU or PRACTICE (the camera option, the one-hand deck)." (member *mode* '(:vs-cpu :practice)))
(defvar *picks* (list :ichigo :kenpachi) "Characters of P1 and P2 (kit.lisp *ROSTER*): Ichigo, Kenpachi (the first two of PLAYABLE-ROSTER since the core system, 2026-10-27; Yamamoto was P1 before and is retired now: cycling from a character outside the list failed).")
(defvar *difficulty* :normal)
(defvar *cam-behind* t "The CAMERA setting of VS CPU / PRACTICE: BEHIND (P1's shoulder, the default) or SIDE (the pair camera).")
(defvar *select-phase* 0 "SELECT: 0 P1 picks, 1 P2 picks, 2 difficulty.")
(defvar *p1* nil) (defvar *p2* nil)
(defvar *timer* 0 "Match frames left.")
(defun match-frames-left () "Frames left on the match timer (the CPU's last-minute rules)." *timer*)
(defun match-play-ticks ()
  "The match's length in frames without its cinematics: the frames its timer ran (MAIN's step stops it while a cinematic
plays). The gate's and the results screen's match length (the user, 2026-10-08: 「毀魂技演出不計入對戰時長」, every
cinematic; *MATCH-TICK* still counts every step: the hash, the logs, the CPU's clocks)."
  (play-ticks *match-seconds* *timer*))
(defvar *winner* nil "0, 1 or :draw once the match is over.")
(defvar *match-seed* 1 "SIM-RND-SEED of the current match (seeded CPU matches: the debug command's).")
(defvar *konpaku-start* *konpaku-max* "Debug 2101: start the match with fewer Konpaku (smoke runs).")

(defvar *music* nil "Key of the loop that PLAY-MUSIC started last.")
(defun play-music (key &optional (fade 0.3))
  "Switch the music to loop KEY (nothing if it is already the one playing)."
  (unless (and (eq key *music*) (music-playing-p))
    (music-stop fade) (music-play key) (setf *music* key)))

(defun set-flow (st)
  (setf *flow* st *ft* 0.0 *menu* 0)
  (log-msg "duel -> ~a" st))

(defun go-mode (&optional (row 0))
  "The MODE screen, the cursor on ROW (VS CPU, row 0, is preselected everywhere; back from SETTINGS / CONTROLS: theirs)."
  (set-flow :mode)
  (setf *menu* row))

(defun set-cam-behind (on)
  "Set the CAMERA option. Humans steer by the behind view only in VS CPU / PRACTICE (fighter.lisp *VIEW-BEHIND*), and
always behind when one-handed (the portrait camera; the setting is kept); VS PLAYER and CPU VS CPU keep the pair camera."
  (setf *cam-behind* on *view-behind* (and (or on *one-hand*) (vs-cpu-p) t) *cam-cut* t))

(defun camera-label () (if *cam-behind* "CAMERA  BEHIND" "CAMERA  SIDE"))

(defun toggle-cam ()
  "The CAMERA option flips (pause menu, select screen, SETTINGS, debug 2109); saved as the CAMERA setting."
  (set-setting :camera (if *cam-behind* 1 0))
  (log-msg "duel camera ~a" (camera-label)))

(defun battle-p () (member *flow* '(:intro :battle :finish)))
(defun sim-running-p () (and (battle-p) (not *paused*)))

;;; ---------------------------------------------------------------- menu input (devices, per frame)
(defun any-pad-pressed (b) (loop for i below 4 thereis (pad-pressed b i)))
(defvar *ui-press* 0 "This frame's presses from the Lisp menus' and pause's pointer (webui.lisp WEBUI-COMMANDS, webhud.lisp WEBHUD-COMMANDS), bits: 1 up 2 down 4 left 8 right 16
confirm 32 back; cleared after FLOW-UPDATE. The menus read them as they read the keys.")
(defun ui-press-p (bit) (logtest *ui-press* bit))
(defun menu-up-p () (or (key-pressed :w) (key-pressed :up) (any-pad-pressed :dpad-up) (ui-press-p 1)))
(defun menu-down-p () (or (key-pressed :s) (key-pressed :down) (any-pad-pressed :dpad-down) (ui-press-p 2)))
(defun menu-left-p () (or (key-pressed :a) (key-pressed :left) (any-pad-pressed :dpad-left) (ui-press-p 4)))
(defun menu-right-p () (or (key-pressed :d) (key-pressed :right) (any-pad-pressed :dpad-right) (ui-press-p 8)))
(defun confirm-p () (or (key-pressed :return) (key-pressed :j) (key-pressed :kp-1) (key-pressed :kp-enter) (any-pad-pressed :a) (ui-press-p 16)))
(defun back-p () (or (key-pressed :escape) (key-pressed :k) (key-pressed :kp-2) (any-pad-pressed :b) *back-press* (ui-press-p 32)))
(defun pause-p () (or (key-pressed :escape) (any-pad-pressed :start) *back-press*))   ; + the browser's back (onehand.lisp)

(defun menu-nav (n)
  "Up / down move the cursor over N items; returns the index on confirm (the Lisp menus' rows send their taps as presses: webui.lisp)."
  (when (menu-up-p) (setf *menu* (mod (1- *menu*) n)) (play-sfx :select))
  (when (menu-down-p) (setf *menu* (mod (1+ *menu*) n)) (play-sfx :select))
  (when (confirm-p) (play-sfx :confirm) *menu*))

;;; ---------------------------------------------------------------- scenes
(defun cycle (item list dir)
  "The element DIR places after ITEM in LIST (a wrap); ITEM not in LIST (a retired character): the first."
  (nth (mod (+ (or (position item list) (if (plusp dir) -1 0)) dir) (length list)) list))

(defun spawn-pair (&key cpu1 cpu2)
  "A fresh plaza with the two picked fighters 8 m apart, facing."
  (clear-entities)
  (take-events)
  (fx-clear) (time-reset) (stage-clear-cracks)
  (let* ((c1 (first *picks*)) (c2 (second *picks*)) (h (/ *reset-distance* 2.0)))
    (setf *p1* (spawn-fighter 0 c1 (- h) 0.0 (deg -90) :cpu cpu1 :difficulty *difficulty*)
          *p2* (spawn-fighter 1 c2 h 0.0 (deg 90) :cpu cpu2 :difficulty *difficulty* :mirror (eq c1 c2)))
    (setf (fighter-opp (fighter *p1*)) *p2* (fighter-opp (fighter *p2*)) *p1*)
    (face-each-other *p1* *p2*)))

(defun go-title ()
  (setf *paused* nil)
  (abort-cine)
  (spawn-pair)
  (do-sides (e) (setf (fighter-state (fighter e)) :intro))
  (play-music :music-title)
  (set-flow :title))

(defun go-select ()
  (setf *paused* nil *select-phase* 0)
  (abort-cine)
  (spawn-pair)
  (do-sides (e) (setf (fighter-state (fighter e)) :intro))
  (play-music :music-title)
  (set-flow :select))

(defun new-seed ()
  "A fresh match seed from the clock (menu matches vary; debug seeds replay)."
  (setf *match-seed* (mod (floor (now-ms)) 100000)))

(defun start-match ()
  "Spawn the fighters for *MODE* / *PICKS*, seed the sim stream, play the intro."
  (setf *paused* nil *winner* nil *match-tick* 0 *timer* (* 60 *match-seconds*)
        *pending* nil *soul-breaks* nil)          ; nothing of the last match may leak in
  (reset-slow-clock)
  (mc-full-reset)                                         ; (no plan or job of the last match)
  (abort-cine)
  (clear-words)
  (sim-rnd-seed *match-seed*)
  (set-cam-behind *cam-behind*)
  (spawn-pair :cpu1 (eq *mode* :cpu-cpu) :cpu2 (not (eq *mode* :vs-player)))
  (when (member *mode* '(:vs-cpu :cpu-cpu))                ; (a CPU's strategy from the lookup, DUEL_AI_STRATEGY §8.6)
    (do-sides (e) (let ((b (brain e)) (f (fighter e)))
                    (when b (setf (brain-strat b) (strat-lookup (fighter-character f) (fighter-character (fighter (fighter-opp f)))
                                                                (brain-difficulty b))))))
    (do-sides (e) (when (brain e) (fq-attach! e))))       ; (a Q selector facing a human plays the player's copy, DUEL_AI_STRATEGY §8.14)
  (do-sides (e)
    (setf (gauges-konpaku (gauges e)) *konpaku-start*)
    (setf (fighter-state (fighter e)) :intro))
  (when (eq *mode* :practice) (practice-dummy!) (practice-set! *p1*) (practice-set! *p2*))
  (play-music :music 0.2)
  (log-msg "duel match seed ~d ~a ~a vs ~a ~a" *match-seed* *mode* (first *picks*) (second *picks*) *difficulty*)
  (debug-knobs-line)                                      ; (a rule knob a debug command changed: named, never silent)
  (set-flow :intro)
  (start-cine 'intro-cine *p1* *p2* :after #'begin-battle))

(defun begin-battle ()
  "The intro ended: FIGHT (P1 on the left of the view; END-CINE already forgot the presses made
during the intro, e.g. the menu's confirm)."
  (do-sides (e) (refresh-look e) (to-idle e 0))
  (setf *match-tick* 0)
  (view-step *p1* *p2* t)
  (duel-camera *p1* *p2* 0.0 :snap t)
  (set-flow :battle))

(defun match-over (winner)
  "A Kikon / Soul Break took the last Konpaku: FINISH (K.O.), then RESULTS. WINNER: the fighter who
won, NIL = a draw (a lethal trade took both souls' last Konpaku). PRACTICE has no match end: the round resets with
both fighters' Konpaku and Reishi at their practice rows (PRACTICE-SET!)."
  (when (eq *mode* :practice)
    (practice-set! *p1*) (practice-set! *p2*)
    (log-msg "duel practice K.O. -> reset")
    (return-from match-over (reset-round *p1* *p2*)))
  (let* ((w (cond ((null winner) :draw) ((eql winner *p1*) 0) (t 1)))
         (we (if (eql w 1) *p2* *p1*)) (le (if (eql w 1) *p1* *p2*)))
    (setf *winner* w)
    (set-flow :finish)
    (start-cine 'ko-cine we le :after #'go-results)))

(defun time-up ()
  "The bell: a bind still up resolves as drained first (BIND-RESOLVE!, DUEL_HISAGI §17.3 B10), then the winner (Konpaku,
then Reishi %)."
  (bind-resolve! *p1*)
  (let* ((g1 (gauges *p1*)) (g2 (gauges *p2*))
         (w (time-up-winner (gauges-konpaku g1) (gauges-reishi g1) (gauges-reishi-max g1)
                            (gauges-konpaku g2) (gauges-reishi g2) (gauges-reishi-max g2))))
    (setf *winner* w)
    (set-flow :finish)
    (start-cine 'time-cine (if (eql w 1) *p2* *p1*) (if (eql w 1) *p1* *p2*) :after #'go-results)))

(defun go-results ()
  (when *in-rollout* (return-from go-results))            ; (a rollout's K.O.: it stops at :finish; no music, no learner, no results)
  (fq-match-end)
  (let* ((g1 (gauges *p1*)) (g2 (gauges *p2*)))
    (set-flow :results)
    (log-msg "duel -> RESULTS winner ~a konpaku ~d-~d ticks ~d secs ~,1f"
             (case *winner* (0 "P1") (1 "P2") (t "DRAW")) (gauges-konpaku g1) (gauges-konpaku g2)
             *match-tick* (/ *match-tick* 60.0))
    (mc-full-log) (strat-log))
  (dolist (e (list *p1* *p2*))
    (let ((f (fighter e)) (won (eql *winner* (fighter-side (fighter e)))))
      (setf (fighter-state f) (if won :win :lose))
      (refresh-look e)
      (play-clip e (if won (or (kit-win (fighter-kit f)) (kit-stance (fighter-kit f))) :sh-lose) :blend 8)))
  (face-each-other *p1* *p2*)
  (music-stop 1.0) (setf *music* nil))

(defun match-system ()
  "The match timer (sim frames) and time-up; PRACTICE: no timer, PRACTICE-STEP instead."
  (when (eq *flow* :battle)
    (cond ((eq *mode* :practice) (practice-step))
          ((<= (decf *timer*) 0) (time-up)))))

;;; ---------------------------------------------------------------- PRACTICE (P1 against a dummy; its sim side: practice.lisp)
(defun practice-reset ()
  "RESET POSITION: a fresh pair at the start (full resources, first forms), straight into the fight (no intro)."
  (setf *paused* nil *pending* nil *soul-breaks* nil)
  (abort-cine)
  (clear-words)
  (spawn-pair :cpu2 t)
  (practice-dummy!)
  (practice-set! *p1*) (practice-set! *p2*) (practice-aw-apply!)
  (log-msg "duel practice reset")
  (begin-battle))

;;; ---------------------------------------------------------------- per-frame flow
(defun select-rows ()
  "SELECT's last page's rows: the difficulty, VS CPU's camera."
  (append '(:difficulty)
          (and (vs-cpu-p) (not *one-hand*) '(:camera))))

(defun select-respawn ()
  "SELECT: the plaza again with the picks (a pick changed)."
  (spawn-pair) (do-sides (e) (setf (fighter-state (fighter e)) :intro)))

(defun select-update ()
  "SELECT: P1 picks, then P2 / the CPU, then the CPU difficulty (either player's keys, like every menu; the Lisp menus' pointer sends
the same presses, webui.lisp)."
  (let ((side (min 1 *select-phase*)))
    (case *select-phase*
      ((0 1)
       (when (or (menu-left-p) (menu-right-p))
         (setf (nth side *picks*) (cycle (nth side *picks*) (playable-roster) (if (menu-left-p) -1 1)))
         (play-sfx :select) (select-respawn))
       (when (confirm-p)
         (play-sfx :confirm)
         (let ((e (if (zerop side) *p1* *p2*)))
           (play-clip e (or (kit-intro (kit-of e)) (kit-stance (kit-of e))) :blend 4))
         (setf *select-phase* (if (and (= *select-phase* 1) (eq *mode* :vs-player)) 3 (1+ *select-phase*))
               *menu* 0)))
      (2 (let* ((rows (select-rows)) (n (length rows)) (row (nth (mod *menu* n) rows)) (dir (if (menu-left-p) -1 1)))
           ;; the difficulty, VS CPU's camera
           (when (and (> n 1) (menu-up-p)) (setf *menu* (mod (1- *menu*) n)) (play-sfx :select))
           (when (and (> n 1) (menu-down-p)) (setf *menu* (mod (1+ *menu*) n)) (play-sfx :select))
           (when (or (menu-left-p) (menu-right-p))
             (case row
               (:camera (toggle-cam))
               (t (setf *difficulty* (cycle *difficulty* *difficulties* dir))))
             (play-sfx :select)))
         (when (confirm-p) (play-sfx :confirm) (setf *select-phase* 3))))
    (when (>= *select-phase* 3) (new-seed) (start-match))
    (when (back-p)
      (play-sfx :back)
      (if (zerop *select-phase*) (go-mode) (decf *select-phase*)))))

(defparameter *mode-rows* '((:vs-cpu "VS CPU") (:practice "PRACTICE") (:vs-player "VS PLAYER") (:cpu-cpu "CPU VS CPU")
                            (:settings "SETTINGS") (:controls "CONTROLS") (:manual "MANUAL"))
  "MODE's rows. ENDLESS and DANGAI, hidden since the HTML menus (frozen with the core system; the user, 2026-10-28: 「隱藏」, DUEL_WEBUI
§1), left main on 2026-11-13 (REFACTOR_2026-11 R4, branch `frozen-modes`).")
(defun mode-row (key) "MODE's row of KEY." (position key *mode-rows* :key #'first))

(defparameter *settings-hidden* '(:tap-split :auto-guard :auto-combo :auto-break)
  "SETTINGS rows not shown since the HTML menus (TAP SPLIT unused, ASSIST frozen with the core system; the user,
2026-10-28: 「隱藏」, DUEL_WEBUI §1; ASSIST itself left main on 2026-11-13, REFACTOR_2026-11 R4: its three rows stay as placeholders,
read by nothing). LEARNING CPU shows again, with RESET LEARNING after the rows (the user, 2026-11-09: 「Show it and add a reset
(Recommended)」, DUEL_AI_STRATEGY §8.14). *SETTINGS* keeps its order (the page saves rows by it).")
(defun settings-shown () "The SETTINGS rows shown, in order." (remove-if (lambda (r) (member (first r) *settings-hidden*)) *settings*))
(defun settings-step (i dir)
  "Move shown SETTINGS row I's option by DIR (it wraps)."
  (let ((row (nth i (settings-shown)))) (set-setting (first row) (mod (+ (setting (first row)) dir) (length (third row))))))

(defvar *bind-col* 0 "CONTROLS: the column, 0 P1 KEY, 1 P1 PAD, 2 P2 KEY, 3 P2 PAD.")
(defvar *capture* nil "CONTROLS: waiting for the key / pad button of the selected cell.")
(defun controls-update ()
  "CONTROLS (the user, 2026-10-01: keyboard and pad rebinding): up / down a row, left / right a column, confirm waits
for the new key (a KEY column) or button (a PAD column: that player's pad) and binds it (REBIND: a swap if taken), saved
at once; Escape / Start cancels the wait. Then RESET DEFAULTS and BACK."
  (let ((n (length *bind-actions*)))
    (cond (*capture*
           (let ((side (floor *bind-col* 2)) (dev (if (evenp *bind-col*) :key :pad)))
             (if (or (key-pressed :escape) (any-pad-pressed :start) *back-press*)
                 (progn (setf *capture* nil) (play-sfx :back))
                 (let ((name (if (eq dev :key)
                                 (find-if #'key-pressed *bind-keys*)
                                 (find-if (lambda (b) (pad-pressed b side)) *bind-pads*))))
                   (when name
                     (setf *capture* nil)
                     (rebind *bind-pair* side (nth *menu* *bind-actions*) dev name)
                     (save-bindings)
                     (play-sfx :confirm)
                     (log-msg "duel bind P~d ~a ~a ~a" (1+ side) (nth *menu* *bind-actions*) dev name))))))
          (t (let ((i (menu-nav (+ 2 n))))
               (when (and (< *menu* n) (or (menu-left-p) (menu-right-p)))
                 (setf *bind-col* (mod (+ *bind-col* (if (menu-left-p) -1 1)) 4)) (play-sfx :select))
               (cond ((eql i (1+ n)) (go-mode (mode-row :controls)))
                     ((eql i n) (reset-bindings *bind-pair*) (save-bindings) (log-msg "duel bind reset"))
                     (i (setf *capture* t)))
               (when (back-p) (play-sfx :back) (go-mode (mode-row :controls))))))))

(defun pause-keys ()
  "The pause menu's rows: PRACTICE's options replace RESTART; VS CPU / PRACTICE with two hands add the CAMERA toggle."
  (append (case *mode* (:practice '(:resume :reset :dummy :counter :refill :gauges :fs :p1-aw :p1-hp :p1-kon :dm-hp :dm-kon))
                (t '(:resume :restart)))
          '(:select :title)
          (when (and (vs-cpu-p) (not *one-hand*)) '(:camera))))
(defun pause-label (k)
  (case k
    (:resume "RESUME") (:restart "RESTART") (:select "CHARACTER SELECT") (:title "TITLE") (:camera (camera-label))
    (:reset "RESET POSITION") (:dummy (format nil "DUMMY  ~a" (cdr (assoc (po-dummy *practice*) *dummies*))))
    (:counter (if (po-counter *practice*) "COUNTER  J1" "COUNTER  OFF"))
    (:refill (if (po-refill *practice*) "HP REFILL  AUTO" "HP REFILL  OFF")) (:gauges (if (po-inf *practice*) "GAUGES  INFINITE" "GAUGES  NORMAL"))
    (:fs (format nil "FLASH STEP  ~a" (nth (po-fs *practice*) *practice-fs-levels*)))
    (:p1-aw (format nil "P1 AWAKEN  ~a" (first (nth (po-aw *practice*) *practice-aw-levels*))))
    ((:p1-hp :p1-kon :dm-hp :dm-kon)
     (let ((i (position k '(:p1-hp :p1-kon :dm-hp :dm-kon))))
       (format nil "~a ~a  ~d~:[~;%~]" (if (< i 2) "P1" "DUMMY") (if (evenp i) "HP" "KONPAKU") (svref (po-rows *practice*) i) (evenp i))))))
(defparameter *practice-option-keys* '(:dummy :counter :refill :gauges :fs :p1-aw :p1-hp :p1-kon :dm-hp :dm-kon) "PRACTICE's option rows.")
(defun pause-items () (mapcar #'pause-label (pause-keys)))
(defvar *pause-dirty* t "A pause row's label may have changed (PAUSE-DO): the model's pause rows are written again (webhud.lisp).")
(defun pause-do (k dir)
  "Pause row K chosen (DIR 1), or an option row moved by left / right (DIR -1 / 1); PRACTICE's rows write *PRACTICE* (practice.lisp)."
  (case k
    (:resume (setf *paused* nil)) (:restart (start-match)) (:select (go-select)) (:title (go-title)) (:camera (toggle-cam))
    (:reset (practice-reset))
    (:dummy (setf (po-dummy *practice*) (cycle (po-dummy *practice*) (mapcar #'car *dummies*) dir)) (practice-dummy!))
    (:counter (setf (po-counter *practice*) (not (po-counter *practice*))))
    (:refill (setf (po-refill *practice*) (not (po-refill *practice*)))) (:gauges (setf (po-inf *practice*) (not (po-inf *practice*))))
    (:fs (setf (po-fs *practice*) (mod (+ (po-fs *practice*) (if (and dir (minusp dir)) -1 1)) (length *practice-fs-levels*))))
    (:p1-aw (setf (po-aw *practice*) (mod (+ (po-aw *practice*) (if (and dir (minusp dir)) -1 1)) (length *practice-aw-levels*))) (practice-aw-apply!))
    ((:p1-hp :p1-kon :dm-hp :dm-kon)                      ; the new value in force at once
     (let* ((i (position k '(:p1-hp :p1-kon :dm-hp :dm-kon))) (rows (po-rows *practice*)) (v (svref rows i)))
       (setf (svref rows i) (if (evenp i) (cycle v *practice-hp* dir) (konpaku-step v dir *konpaku-max*)))
       (practice-set! (if (< i 2) *p1* *p2*)))))
  (setf *pause-dirty* t)
  (when (member k *practice-option-keys*) (log-msg "duel practice ~a" (pause-label k))))
(defun option-dir () "Left / right this frame: -1 / 1, else NIL (an option row's value)." (cond ((menu-left-p) -1) ((menu-right-p) 1)))

(defun flow-update (rdt)
  "Menus, pause and screen timers (once per frame, real time). The Lisp menus and pause: their pointer presses first
(WEBUI-COMMANDS, WEBHUD-COMMANDS), their models last (WEBUI-SYNC, WEBHUD-SYNC)."
  (unless *paused* (incf *ft* rdt))
  (webui-commands)
  (webhud-commands)                                      ; (the Lisp HUD's pause rows, webhud.lisp)
  (flow-screens)
  (webui-sync)
  (webhud-sync)
  (setf *ui-press* 0))

(defun flow-screens ()
  "FLOW-UPDATE's screen by screen part."
  (case *flow*
    (:title (when (and (> *ft* 0.3) (or (confirm-p) (key-pressed :space) (any-pad-pressed :start)))
              (play-sfx :confirm) (go-mode)))
    (:mode (let* ((i (menu-nav (length *mode-rows*))) (k (and i (first (nth i *mode-rows*)))))
             (case k
               ((:vs-cpu :practice :vs-player :cpu-cpu)
                (setf *mode* k                                                     ; VS CPU / PRACTICE: one-handed
                      *one-hand* (and (member k '(:vs-cpu :practice)) (one-hand-effective-p) t))   ; when the setting is
                (go-select))                                                       ; in effect
               (:settings (set-flow :settings))
               (:controls (set-flow :controls))
               (:manual (open-manual))))
           (when (back-p) (play-sfx :back) (go-title)))
    (:settings (let* ((n (length (settings-shown))) (i (menu-nav (+ n 2))) (d (option-dir)))   ; confirm / a tap: the next option
                 (cond ((eql i (1+ n)) (go-mode (mode-row :settings)))                     ; BACK
                       ((eql i n) (fq-reset-all) (play-sfx :confirm))                      ; RESET LEARNING
                       (i (settings-step i 1))
                       ((and d (< *menu* n)) (play-sfx :select) (settings-step *menu* d))))
               (when (back-p) (play-sfx :back) (go-mode (mode-row :settings))))
    (:controls (if (one-hand-offered-p)                  ; a phone: the gestures page
                   (when (or (back-p) (confirm-p)) (play-sfx :back) (go-mode (mode-row :controls)))
                   (controls-update)))
    (:select (select-update))
    ((:intro :finish) (when (and *cine* (or (pause-p) (confirm-p) (tap-p))) (skip-cine)))
    (:battle
     (cond (*paused*
            (if (pause-p)
                (setf *paused* nil)
                (let* ((keys (pause-keys)) (i (menu-nav (length keys))) (d (option-dir)) (k (nth (or i *menu*) keys)))
                  (cond (i (pause-do k 1))
                        ((and d (member k (cons :camera *practice-option-keys*))) (play-sfx :select) (pause-do k d))))))
           ;; battle cinematics (awakening, Kikon, Soul Break) can't be skipped (the user's decision
           ;; 2026-09-28): Start pauses them like play, a tap does nothing
           ((or (pause-p) (focus-lost-p) (touch-pause-p)
                (and *one-hand* (not (portrait-p))))              ; ONE-HAND turned to landscape: ROTATE TO PORTRAIT
            (setf *paused* t *menu* 0) (play-sfx :select))))
    (:results (when (> *ft* 2.5)                         ; a masher doesn't skip the results
                (case (menu-nav 3)
                  (0 (new-seed) (start-match))
                  (1 (go-select))
                  (2 (go-title)))))))

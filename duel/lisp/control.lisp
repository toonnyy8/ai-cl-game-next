;;;; control.lisp — SOUL DUEL's controls (design-v1 §2) on the engine's virtual controller (the
;;;; vpad, engine/lisp/input.lisp): the nine buttons, the command table and both players' device
;;;; bindings, all data. Fighter code reads only vpads; devices, the CPU brain and test scripts
;;;; write them the same way, once per fixed step (VPAD-SET!, VPAD-STICK!), so a replay or a CPU
;;;; press is indistinguishable from a key.
;;;;   (new-vpad &key reader)                a vpad with these buttons (:MOD = the Reiatsu modifier)
;;;;   (vpad-command vp *commands* allowed)  buttons + modifier -> one command keyword
;;;;   (vpad-command-pressed-p vp button mod)   is one *COMMANDS* entry's button buffered?
;;;; Also the SETTINGS rows (*SETTINGS*, ONE-HAND-ON-P) and the PRACTICE dummy's guard rule (DUMMY-GUARD-LEFT; GUARD ALL with a :core
;;;; dummy: DUMMY-CANCEL-PRESS).
;;;; Plain CL, host-tested (tests/duel-control-test.lisp).
(in-package :duel)

(defparameter *vpad-actions*
  #(:mod :quick :flash :sig :guard :breaker :kikon :step :awaken)
  "Every vpad button. :MOD is the modifier: a button pressed while :MOD is down, or in the same
step, is modified.")

(defun new-vpad (&key reader)
  "A SOUL DUEL vpad: *VPAD-ACTIONS*, :MOD as the modifier, presses buffered *INPUT-BUFFER* steps."
  (make-vpad :actions *vpad-actions* :modifier :mod :buffer *input-buffer* :reader reader))

;;; ---------------------------------------------------------------- commands
(defparameter *commands*
  '((:awaken  :awaken  t)
    (:hoho    :step    t)
    (:burst   :awaken  nil)
    (:step    :step    nil)
    (:sp      :quick   t)
    (:q       :quick   nil))
  "Command table, HIGHEST PRIORITY FIRST: (command button mod), MOD = T needs the press modified
(pressed with :MOD down), NIL needs it unmodified. The core system's three keys (docs/duel/DUEL_CORE.md, the user 2026-10-27):
J attack / Mod+J SP, Space Step / Mod+Space Hoho, P Burst / Mod+P awaken. The modified buttons come before the plain ones.
The old K / L / U / I / O commands are gone from the table (their code stays in the frozen characters' files). Fighter code
walks it with VPAD-COMMAND-PRESSED-P (fighter.lisp COMMAND!), so a refused command doesn't hide the ones below it.")

;;; ---------------------------------------------------------------- devices (bindings as data)
;;; Binding plists for VPAD-READ! (engine): action -> list of inputs, an input (device name ...) =
;;; all names down together (a chord). :key names are engine key keywords, :pad names pad buttons;
;;; the DOWN-P function fighter.lisp passes knows which pad slot belongs to the player.
(defparameter *p1-default-bindings*
  '(:up ((:key :w) (:pad :dpad-up)) :down ((:key :s) (:pad :dpad-down))
    :left ((:key :a) (:pad :dpad-left)) :right ((:key :d) (:pad :dpad-right))
    :quick ((:key :j) (:pad :x) (:touch :quick)) :flash nil :sig nil :guard nil :breaker nil :kikon nil
    :step ((:key :space) (:pad :a) (:touch :step)) :mod ((:key :lshift) (:pad :lt) (:touch :mod))
    :awaken ((:key :p) (:pad :y) (:pad :back) (:touch :awaken)))
  "Player 1: left keyboard + pad 0 (design-v1 §2) + the ONE-HAND thumb deck ((:touch name): onehand.lisp
TOUCH-BUTTON; its drag stick is added like pad 0's). Menus read the devices directly (flow.lisp). The defaults: the
live *P1-BINDINGS* is a copy CONTROLS rebinds.")

(defparameter *p2-default-bindings*
  '(:up ((:key :up) (:pad :dpad-up)) :down ((:key :down) (:pad :dpad-down))
    :left ((:key :left) (:pad :dpad-left)) :right ((:key :right) (:pad :dpad-right))
    :quick ((:key :kp-1) (:pad :x)) :flash nil :sig nil :guard nil :breaker nil :kikon nil
    :step ((:key :kp-0) (:pad :a)) :mod ((:key :kp-enter) (:pad :lt))
    :awaken ((:key :kp-plus) (:pad :y) (:pad :back)))
  "Player 2: arrows + numpad + pad 1 (design-v1 §2). The defaults of *P2-BINDINGS*.")

;;; ---------------------------------------------------------------- CONTROLS: rebinding (the user, 2026-10-01)
;;; Keyboard and pad only (the touch deck is the gestures'). Each player's binding of an action on a device is its first
;;; one-name input of that device ((:key :j), (:pad :x)); chords ((:pad :ls :rs)) and touch inputs stay as they are.
(defvar *p1-bindings* (copy-tree *p1-default-bindings*) "Player 1's live bindings (CONTROLS changes them in place).")
(defvar *p2-bindings* (copy-tree *p2-default-bindings*) "Player 2's live bindings.")
(defvar *bind-pair* (vector *p1-bindings* *p2-bindings*) "Both players' live bindings (REBIND's PAIR).")
(defparameter *bind-actions* '(:up :down :left :right :quick :step :mod :awaken)
  "The CONTROLS rows, in order (the page saves them by this index).")
(defparameter *bind-row-names*
  '("MOVE UP" "MOVE DOWN" "MOVE LEFT" "MOVE RIGHT" "ATTACK  J" "STEP  SPACE" "FUNCTION  SHIFT" "BURST  P")
  "Each *BIND-ACTIONS* row's label (the button's name in the manual after it).")
(defparameter *bind-keys*
  (append (loop for c across "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" collect (intern (string c) :keyword))
          '(:space :return :tab :backspace :minus :equals :lbracket :rbracket :semicolon :quote :grave :comma :period :slash
            :backslash :capslock :insert :home :pageup :delete :end :pagedown :up :down :left :right
            :kp-0 :kp-1 :kp-2 :kp-3 :kp-4 :kp-5 :kp-6 :kp-7 :kp-8 :kp-9 :kp-divide :kp-multiply :kp-minus :kp-plus
            :kp-enter :kp-period :lshift :rshift :lctrl :rctrl :lalt :ralt :f1 :f2 :f3 :f4 :f5 :f6 :f7 :f8 :f9 :f10 :f11 :f12))
  "Keys CONTROLS may bind (engine *SCANCODES* names, no alias; Escape is the pause and the cancel).")
(defparameter *bind-pads* '(:a :b :x :y :lb :rb :lt :rt :ls :rs :back :dpad-up :dpad-down :dpad-left :dpad-right)
  "Pad buttons CONTROLS may bind (Start is the pause and the cancel).")
(defparameter *bind-labels*
  '(:lshift "SHIFT" :rshift "RSHIFT" :lctrl "CTRL" :rctrl "RCTRL" :lalt "ALT" :ralt "RALT" :return "ENTER"
    :kp-enter "KP ENTER" :kp-plus "KP +" :kp-minus "KP -" :kp-multiply "KP *" :kp-divide "KP /" :kp-period "KP ."
    :lbracket "[" :rbracket "]" :semicolon ";" :quote "'" :grave "`" :comma "," :period "." :slash "/" :backslash "\\"
    :minus "-" :equals "=" :dpad-up "D-UP" :dpad-down "D-DOWN" :dpad-left "D-LEFT" :dpad-right "D-RIGHT")
  "Screen names that differ from the keyword's own.")

(defun bind-label (name)
  "How a bound key / pad button NAME reads on screen: SHIFT, KP1, D-UP, J ..., \"-\" for none."
  (cond ((null name) "-")
        ((getf *bind-labels* name))
        ((and (> (length (symbol-name name)) 3) (string= "KP-" (symbol-name name) :end2 3)) (remove #\- (symbol-name name)))
        (t (symbol-name name))))

(defun binding-input (bindings action device)
  "ACTION's first one-name input of DEVICE in BINDINGS (a list (device name)), or NIL."
  (find-if (lambda (in) (and (eq (first in) device) (null (cddr in)))) (getf bindings action)))
(defun binding-name (bindings action device) "ACTION's bound name on DEVICE (:key / :pad), or NIL." (second (binding-input bindings action device)))

(defvar *prompt-cache* (make-array 4 :initial-element nil)
  "KEY-PROMPT's texts per side x device (:key, :pad), rebuilt after a rebind (NIL).")

(defun rebind (pair side action device name)
  "SIDE's (0 / 1, PAIR: the two players' bindings) ACTION on DEVICE becomes NAME. An action already on NAME takes ACTION's
old one (a swap, never two actions on one key): on the keyboard over both players' (one keyboard), on a pad over this
player's (his own pad). Changes PAIR's plists in place; T when something changed."
  (let* ((b (svref pair side)) (in (binding-input b action device)) (old (second in)))
    (when (and in (not (eql old name)))
      (dolist (s (if (eq device :key) '(0 1) (list side)))
        (dolist (a *bind-actions*)
          (let ((other (binding-input (svref pair s) a device)))
            (when (and other (eql (second other) name) (not (and (= s side) (eq a action))))
              (setf (second other) old)))))
      (setf (second in) name)
      (fill *prompt-cache* nil)
      t)))

(defun reset-bindings (pair)
  "Every CONTROLS binding of PAIR back to the defaults."
  (loop for b across pair for d in (list *p1-default-bindings* *p2-default-bindings*)
        do (dolist (a *bind-actions*)
             (dolist (dev '(:key :pad))
               (let ((in (binding-input b a dev))) (when in (setf (second in) (binding-name d a dev)))))))
  (fill *prompt-cache* nil))

(defun bind-code (side action device pair)
  "What the page saves for SIDE's ACTION on DEVICE: 0 = the default, else 1 + the name's place in *BIND-KEYS* /
*BIND-PADS*."
  (let ((n (binding-name (svref pair side) action device))
        (d (binding-name (if (zerop side) *p1-default-bindings* *p2-default-bindings*) action device)))
    (if (eql n d) 0 (1+ (or (position n (if (eq device :key) *bind-keys* *bind-pads*)) -1)))))
(defun bind-from-code (code device)
  "The name a saved CODE stands for on DEVICE (NIL: the default, or a code out of range)."
  (and (plusp code) (nth (1- code) (if (eq device :key) *bind-keys* *bind-pads*))))

(defun key-prompt (pair side device kind)
  "The HUD's prompt KIND (:chain :burst :kikon; the Lisp HUD's prompt keys :sp-keys :p-key :awaken-keys) for SIDE pressing on DEVICE (:key / :pad), from his bindings (cached)."
  (let ((i (+ (* 2 side) (if (eq device :pad) 1 0))))
    (getf (or (svref *prompt-cache* i)
              (setf (svref *prompt-cache* i)
                    (flet ((n (a) (bind-label (binding-name (svref pair side) a device))))
                      (list :chain (format nil "~a+~a  SP" (n :mod) (n :quick))
                            :burst (format nil "~a  BURST" (n :awaken))
                            :kikon (format nil "HOLD ~a  KIKON" (n :quick))
                            :sp-keys (format nil "~a + ~a" (n :mod) (n :quick))   ; the Lisp HUD's prompt keys (webhud.lisp)
                            :p-key (n :awaken)
                            :awaken-keys (format nil "~a + ~a" (n :mod) (n :awaken))))))
          kind)))

;;; ---------------------------------------------------------------- SETTINGS (the 2026-09-28 SETTINGS screen)
;;; The rows as data: flow.lisp shows and changes them, onehand.lisp puts them into effect and saves each one
;;; through the page (duel/web/pwa.js: localStorage "soulduel.<name>", the page value = option index + 1, 0 = never
;;; saved or storage blocked -> the default). The page names the rows in this order.
(defparameter *settings*
  '((:one-hand "ONE-HAND" ("AUTO" "ON" "OFF") 0 nil "AUTO: ON FOR A TOUCH PHONE HELD UPRIGHT")
    (:hand "HAND" ("LEFT" "RIGHT") 1 nil "THE THUMB DECK'S SIDE")   ; LEFT on the left (the user, 2026-11-02; RIGHT LEFT before)
    (:tap-split "TAP SPLIT" ("40%" "45%" "50%" "55%" "60%") 2 (0.4 0.45 0.5 0.55 0.6) "UNUSED: A TAP IS THE ATTACK EVERYWHERE")
    (:flick "SENSITIVITY" ("1" "2" "3" "4" "5") 2 (40 34 28 23 18) "HIGHER: A SHORTER FLICK")
    (:camera "CAMERA" ("BEHIND" "SIDE") 0 nil "VS CPU AND PRACTICE, TWO HANDS")
    (:learn "LEARNING CPU" ("ON" "OFF") 0 nil "VS CPU HARD: THE CPU LEARNS YOUR HABITS")
    (:hint "PERFECT HINT" ("OFF" "ON") 0 nil "HOHO! OVER YOU WHEN A HOHO NOW IS PERFECT")   ; the user 2026-10-01
    (:auto-guard "AUTO GUARD" ("OFF" "HOLD U" "ALWAYS") 0 nil "A HIT COMING: PARRY OR HOHO FOR YOU (NEVER PERFECT, x0.8)")
    (:auto-combo "AUTO COMBO" ("OFF" "ON") 0 nil "J AFTER A HIT: THE CPU PICKS THE NEXT MOVE (x0.8)")
    (:auto-break "AUTO BREAK" ("OFF" "ON") 0 nil "J INTO A LONG GUARD: A BREAKER (x0.8)")   ; ASSIST, the user 2026-10-01
    (:volume "VOLUME" ("0" "1" "2" "3" "4" "5") 5 (0.0 0.1 0.25 0.45 0.7 1.0) "MUSIC AND SOUND, 0 = MUTE"))   ; the user, 2026-10-30
  "SETTINGS rows: (key label option-labels default-index values note). VALUES (else the labels) are what the options
mean: TAP SPLIT the recogniser's tap-split, SENSITIVITY its flick-min in CSS px (28 = the design's §3.8 default), VOLUME the
master gain (steps by ear, louder at the top; 5 = 1.0, the level before the row). The page saves rows by their place: a row is only
ever appended (or dropped from the end: HUD, 2026-11-11, DUEL_LISP_HUD §16).")

(defvar *setting-ix* (coerce (mapcar #'fourth *settings*) 'simple-vector) "Each row's chosen option index.")

(defun setting-pos (key) (position key *settings* :key #'first))
(defun setting (key) "KEY's chosen option index." (svref *setting-ix* (setting-pos key)))
(defun setting-value (key) "What KEY's chosen option means (its VALUES entry, else its label)."
  (let ((row (nth (setting-pos key) *settings*))) (nth (setting key) (or (fifth row) (third row)))))
(defun setting-from-page (key v)
  "The option index a page value V stands for: V - 1 when it names an option of KEY, else KEY's default."
  (let ((row (nth (setting-pos key) *settings*)))
    (if (< 0 v (1+ (length (third row)))) (1- v) (fourth row))))

(defun one-hand-on-p (choice coarse portrait)
  "Is a VS CPU / PRACTICE match one-handed, for ONE-HAND MODE option CHOICE (0 AUTO, 1 ON, 2 OFF), a touch-first
device (COARSE) and a PORTRAIT window? Only where one-hand is offered (coarse or portrait: a landscape desktop never);
AUTO: a touch-first device held in portrait (the old ONE-HAND VS CPU preselection)."
  (and (or coarse portrait) (case choice (0 (and coarse portrait)) (1 t)) t))

;;; ---------------------------------------------------------------- ONE-HAND: what an up-flick is (onehand.lisp ONEHAND-FRAME)
(defun up-flick-hoho-p (state step-branch perfect)
  "Is any one-hand up-flick a Hoho now, no rest needed (the recogniser's UP-HOHO; else it is a Step, the dash)? While P1
attacks (his STATE :move; the user 2026-09-30: no dash there), unless his move takes Step itself (STEP-BRANCH: its
:flags has :step-branch, a stance whose Step is a follow-up: there the flick read as a Hoho that never came, the user
2026-10-06, decision 24 of docs/duel/DUEL_LILLE.md), or whenever a Hoho now would be PERFECT (the user 2026-10-01)."
  (and (or (and (eq state :move) (not step-branch)) perfect) t))

(defun rv-buttons (down hold tap)
  "爆's vpad buttons (onehand.lisp TOUCH-BUTTON; the user, 2026-10-28: 「把覺醒鍵整合進爆氣中，改由長按覺醒」). DOWN: the chip is
down (past its hold); HOLD: its press has the awakening's hold (300 ms, the awakening ready; NIL: none, not ready); TAP: it was
let go before its hold (the recogniser's chip tap). Values: :MOD, :AWAKEN down. Not ready: P on the press (the Burst); ready: P alone on a quick lift (the
Burst), Mod + P once held through the hold (the awakening)."
  (values (and down hold t) (and (or down tap) t)))

;;; ---------------------------------------------------------------- the PRACTICE dummy (flow.lisp PRACTICE-STEP)
(defparameter *dummy-guard-hold* 60 "PRACTICE, GUARD AFTER HIT: frames the dummy keeps its guard once it is free again.")

(defun dummy-guard-left (dummy state left)
  "Frames the PRACTICE dummy goes on holding guard, for its DUMMY option, its fighter STATE and LEFT (frames still
held). :GUARD-ALL always; :GUARD-HIT from a hit landing on it (a hit state) or a blocked one, until *DUMMY-GUARD-HOLD*
frames after that (a string's first hit lands, the rest is blocked unless it combos); :STAND / :CPU never (the CPU
guards by itself). (A :core dummy never guards: its GUARD ALL is DUMMY-CANCEL-PRESS, flow.lisp PRACTICE-STEP.)"
  (case dummy
    (:guard-all 999)
    (:guard-hit (if (member state '(:stun :air :down :wakeup :guard-hit)) *dummy-guard-hold* (max 0 (1- left))))
    (t 0)))

(defun dummy-counter-now-p (state sf stun glock)
  "PRACTICE's COUNTER (the user 2026-10-25: 「幫我將練習模式的假人新增一個受傷後反擊的功能」; 「固定 J1」, 「被打中或擋下後都反擊」):
does the dummy press J1 at the end of this step? On the last step of a hit / block reaction STATE (its SF of STUN frames:
the next step frees it, STUN-STEP; a wake-up's *REACTION-FRAMES*, AIR-STEP), not while a guard lock (GLOCK) still holds its
blockstun. Pressed with Guard let go, the reaction ends in neutral, not back in a guard (*GUARD-EXIT*), and the buffered
press starts J1 on its first free frame."
  (case state
    ((:stun :guard-hit) (and (>= (1+ sf) stun) (not (and (eq state :guard-hit) glock)) t))
    (:wakeup (>= (1+ sf) (getf *reaction-frames* :wakeup)))))

;;; GUARD ALL with a :core dummy (the user, 2026-11-12: 「練習模式 DUMMY 的「GUARD ALL」會自動使出能跟對手相消的攻擊」, DUEL_CORE §9): a core
;;; kit never guards, so the dummy answers each incoming hit with a press that puts it inside the startup / active frames of a move the
;;; triangle cancels that hit with (core.lisp CORE-VERDICT): only presses a player could make, nothing when no hit is coming.
(defparameter *dummy-cancel-lead* 2
  "GUARD ALL (a :core dummy): its cancelling move starts at least this many frames before the player's hit is due (a hit landing a frame or
two late, a chase, stays inside its window). New 2026-11-12 (the lead's default).")
(defparameter *dummy-cancel-reach* 1.0
  "GUARD ALL (a :core dummy): a player's hit counts as coming only within its move's reach + slide + this many metres (a swing at the air
draws no answer; flow.lisp DUMMY-CANCEL-INPUT). New 2026-11-12 (the lead's default).")

(defun dummy-cancel-press (hit-in gap p-cls own-cls own-left starts)
  "GUARD ALL with a :core dummy: the press (:J, :SP or NIL) the dummy makes at the end of this sim frame so the player's next hit lands on it
inside a move the triangle cancels it with. HIT-IN: frames until his next unused hit window opens (1 = the next frame), NIL: no hit coming
(idle, recovery, every window spent, out of reach, a move that hits by a hazard alone: nothing cancels a hazard). GAP: frames his classed
window lasts after that hit frame (his move is still in startup / active then, so the dummy's own hit landing in it cancels too). P-CLS:
his move's class. OWN-CLS / OWN-LEFT: the class of the dummy's window now (NIL: none) and the frames it still lasts. STARTS: what a press
could start now, each (PRESS CLASS D-MIN D-MAX LEN HF): it starts D-MIN frames on (1 from neutral; a latched segment, SA or link when the
current move's active frames end), D-MAX the latest it still could (a latch closes with the recovery), LEN its startup + active frames,
HF the frames from its start to its own first hit. Rules: only a class the table cancels his with (NA, SA -> NS; NS -> NA, SA; AS -> NA;
never his own class, whose tie only cancels on the same frame); nothing while its own window already covers the hit; a non-turn move
(NA / NS) over a turn move; pressed as late as it still works: it starts *DUMMY-CANCEL-LEAD* frames before the hit, or on the latest frame that lets its own hit
land inside his window too (his move cancelled even if his hit whiffs: a dead zone, a step out of reach), or on its latch's last frame."
  (flet ((cancels-p (c) (and p-cls c (eq (core-verdict p-cls c :att-t 0 :def-t 1) :cancel))))   ; (the dummy's move starts later)
    (when (and hit-in (not (and (cancels-p own-cls) (< hit-in own-left))))
      (let ((best nil) (best-turn t))
        (loop for o in starts
              do (destructuring-bind (press cls dmin dmax len hf) o
                   (let* ((r (- hit-in dmin))                                ; its frame (from its start) at his hit, pressed now
                          (dbl (+ (- hf gap) 1))                             ; the least R whose own hit lands inside his window
                          (turn (member cls '(:as :sa))))
                     (when (and (cancels-p cls) (<= 0 r) (< r len) (or (<= r *dummy-cancel-lead*) (= r dbl) (>= dmin dmax))
                                (or (null best) (and best-turn (not turn))))
                       (setf best press best-turn turn)))))
        best))))

;;; PRACTICE's HP / KONPAKU rows (the user's request 2026-09-28): the values RESET POSITION and every refill restore
(defparameter *practice-hp* '(100 75 50 25 10) "The P1 HP / DUMMY HP steps, % of the fighter's Reishi maximum.")
(defun practice-reishi (reishi-max pct) "Reishi for PCT % of REISHI-MAX (never 0: 0 would be a Soul Break)." (max 1 (ceiling (* reishi-max pct) 100)))
(defun konpaku-step (k dir kmax) "The P1 / DUMMY KONPAKU row moved by DIR: 1 .. KMAX, wrapping." (1+ (mod (+ (1- k) dir) kmax)))

;;; the HUD's Konpaku at stake (the user's request 2026-09-28: the flames a Kikon would take now, in red)
(defun konpaku-at-stake (konpaku count)
  "How many of KONPAKU flames a Kikon worth COUNT (the attacker's current form's :kikon-konpaku) would take if it landed
now: the settle's own rule (rules.lisp KIKON-RESULT: at most *KIKON-MAX-EVENT*, at most what is left). The HP-0 Soul
Break's + 1 is not shown."
  (multiple-value-bind (left lost) (kikon-result konpaku count nil)   ; (not NTH-VALUE: ECL conses its value list, 24 B a call)
    (declare (ignore left))
    lost))

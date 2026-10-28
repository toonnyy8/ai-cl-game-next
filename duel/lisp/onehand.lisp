;;;; onehand.lisp — 片手 ONE-HAND, the portrait one-thumb mode (docs/duel/DUEL_MOBILE_DESIGN.md, P0 + the PWA shell).
;;;; The engine's recogniser (engine/lisp/touch.lisp) turns the thumb into gestures; this file lays out the
;;;; flow pad and the chips, maps gestures to P1's vpad buttons (TOUCH-BUTTON, read through the (:touch ...)
;;;; bindings of control.lisp: fighters, rules and the AI never see touch), draws the deck, and talks to the
;;;; page (duel/web/pwa.js: coarse pointer, back gesture, wake lock, the saved SETTINGS). Since 2026-09-28 one-hand is a
;;;; setting (ONE-HAND MODE AUTO / ON / OFF, control.lisp *SETTINGS*): VS CPU and PRACTICE use the deck wherever it is
;;;; in effect (ONE-HAND-EFFECTIVE-P); SET-SETTING / APPLY-SETTINGS put HAND, TAP SPLIT, SENSITIVITY and CAMERA in force.
;;;;   per frame: ONEHAND-FRAME (before the flow)      per vpad read: TOUCH-READ-BEGIN (P1-READER)
;;;;   drawing:   HUD-DECK (battle), HUD-GESTURES (the static card that replaces CONTROLS)
(in-package :duel)

;; *TOUCH* *ONE-HAND* *HAND* *COARSE* *BACK-PRESS*: components.lisp (read by fighter.lisp and flow.lisp)
(defvar *touch-burst* nil "This vpad read: the live flick is a burst (down, P1 in hit / stun / air: BLUE; his move's hit
landed: ORANGE).")
(defvar *deck-key* (list 0 0 0 nil nil 0 0 0 nil) "Window w, h, density, hand, one-hand, safe top / bottom, UI scale, the U chip of the
last TOUCH-LAYOUT!.")
(defvar *wake* nil "Wake lock requested (battle).")
(defparameter *glyph-names* #("" "Q" "STEP" "F" "HOHO" "" "DASH" "BURST")
  "TOUCH-GLYPH kinds (7: the duel's Burst). 5, the rest, is no longer named GUARD (the user, 2026-10-28: 「請將長按時是防禦的手勢偵測給移除」):
there is no guard; the rest stays only as the hold a Hoho's up-flick starts from and the thumb an SP's Kikon keeps down.")
(defvar *glyph-seen* -1f4 "TOUCH-GLYPH-T last logged.")

;;; page services (pf_page_get / pf_page_set, duel/web/pwa.js)
(defconstant +pg-coarse+ 0) (defconstant +pg-back+ 1) (defconstant +pg-safe-top+ 3) (defconstant +pg-safe-bottom+ 4)
(defconstant +ps-wake+ 0) (defconstant +ps-manual+ 1 "Page set 1: open the manual page (manual.html) in this window.")
(defconstant +pg-setting+ 10 "Page get / set 10 + i: SETTINGS row i (control.lisp *SETTINGS* order), option index + 1.")
(defconstant +pg-bind+ 20000 "Page get / set 20000 + 100 side + i: that player's key for *BIND-ACTIONS* row i, + 50: his pad
button (control.lisp BIND-CODE: 0 the default).")

(defun open-manual ()
  "MODE's MANUAL row: the page opens manual.html in the same window (an installed app stays in its window; the
manual's back link returns). Without the page service (the native gate) nothing happens."
  (log-msg "duel manual")
  (page-set +ps-manual+ 1))

(defun portrait-p () (> (window-height) (window-width)))
(defun one-hand-offered-p ()
  "ONE-HAND is listed when the window is portrait or the device is touch-first (a landscape desktop window
never offers it: the deck needs portrait)."
  (or *coarse* (portrait-p)))
(defun one-hand-effective-p ()
  "Would VS CPU / PRACTICE be one-handed here and now (the ONE-HAND MODE setting, control.lisp ONE-HAND-ON-P)?"
  (one-hand-on-p (setting :one-hand) *coarse* (portrait-p)))

;;; ---------------------------------------------------------------- the deck (design §3.3)
;;; The core system (2026-10-27, docs/duel/DUEL_CORE.md): SP and the attack are the pad's two tap zones again (high = SP, low = the attack;
;;; the user 「請將 SP 跟攻擊鍵改成用原本 F/Q tap-split 的形式表示」); only chips 6 (pause) and 7 (爆 RV: P, the Burst; held 0.3 s while
;;; the awakening is ready, Mod + P, the awakening) are live; 0 O, 1 L, 2 I, 3 SP1, 4 SP2 and 5 (the old AWAKEN chip, folded into 爆
;;; on 2026-10-28) sit off screen (their slots stay: the touch recogniser's chip indices).
;;; The battle screens (the user, 2026-10-28, DUEL_WEBUI §6-§7: 「善哉！！幫我把整套接進遊戲中」): the chips' spots and the tap zones'
;;; line are the approved draft v4's, in its unit U = 2.36 % of the window's width (CSS px): the deck is the window's lower
;;; *DECK-FRAC*; the line runs from *DECK-SPLIT*'s first height (of the deck's, at its far edge) to its second (at the thumb's edge);
;;; 爆 sits in the SP side 3 U in from the thumb's edge, 22 % down the deck; 止 (pause) above the player's own plate, on the thumb's
;;; side (37 % + 17 U up). The flow pad (where a gesture may start) keeps the playtest's size (2026-09-27: the whole thumb area, 460
;;; CSS px): above the deck it is all SP (the line's far end extended). The page (duel/web/hud.js) draws all of it where Lisp
;;; publishes it (DUEL_WEBUI §7), so what is drawn is what is hit.
(defparameter *chip-spots*
  '((-9999 9999 0 "") (-9999 9999 0 "") (-9999 9999 0 "") (-9999 9999 0 "") (-9999 9999 0 "") (-9999 9999 0 "") (6.7 :pause 3.1 "II")
    (6.7 :rv 3.7 "RV"))
  "Per chip: x from the thumb-side edge, its place (y from the bottom, CSS px; :PAUSE above the player's plate, :RV in the
deck's SP side) and radius (both in U for the placed ones), label. Before 2026-10-28: AWAKEN (270 396 26), pause (32 -200 22:
under the portrait HUD's top block), RV (170 472 22), in CSS px.")
(defparameter *deck-frac* 0.37 "The deck's share of the window's height, from the bottom (the battle screens' draft, DUEL_WEBUI §6).")
(defparameter *deck-split* '(0.20 0.82)
  "The tap zones' line: its height as a fraction of the deck's at the far edge, then at the thumb's edge; SP above, the attack
below (the user, 2026-10-28: 「SP 跟 ATK 沿著目前大約『覺』的位置往斜上方畫界分割」 (v2: 0.20 / 0.986), then 「分割起始點在往上一些」
(v3: the near end 0.986 -> 0.82)). Before: the pad's level middle (the recogniser's TAP-SPLIT 0.5). One source: the recogniser
hit-tests it (TOUCH-SPLIT!) and the page draws it (DUEL_WEBUI §7, set 30134 / 30135).")
(defparameter *chip-holds* '(0 0 0 0 0 300 0 0) "Each chip's hold, ms (爆's is set every frame: RV-READY-P, ONEHAND-FRAME).")
(defparameter *u-chip-holds* '(0 0 0 0 0 0 0 0) "... with the AWAKEN chip as U (U-CHIP-P): a tap.")

(defun deck-layout ()
  "Values: pad (x0 y0 x1 y1), chips ((cx cy r) ...) and the deck (x0 y0 x1 y1, *DECK-FRAC* of the window from its bottom), window
px, for the current window and *HAND*. P2 (safe-area insets): the pad keeps 16 CSS px over the home indicator (no change on
today's phones: 50 >= 34 + 16). The chips are placed in the draft's unit (*CHIP-SPOTS*), not moved by the insets."
  (let* ((d (pixel-density)) (w (/ (window-width) d)) (h (/ (window-height) d)) (left (eq *hand* :left))
         (u (* 0.0236 w)) (dh (* *deck-frac* h)) (dt (- h dh)))
    (flet ((x (from-right) (* d (if left from-right (- w from-right)))) (px (v) (* d v)))
      (values (list (if left (px 32) (px 16)) (px (- h 460)) (if left (px (- w 16)) (px (- w 32))) (px (- h (max 50 (+ *safe-bot* 16)))))
              (loop for (cx cy r) in *chip-spots*
                    collect (case cy
                              (:pause (list (x (* cx u)) (px (- h dh (* (+ 17 r) u))) (px (* r u))))   ; 止: its bottom 17 U over the deck
                              (:rv (list (x (* cx u)) (px (+ dt (* 0.22 dh) (* r u))) (px (* r u))))  ; 爆: its top 22 % down the deck
                              (t (list (x cx) (px (- h cy)) (px r)))))
              (list 0 (px dt) (px w) (px h))))))

(declaim (type f32vec *deck* *deck-rect*))
(defvar *deck* (make-f32 (+ 4 (* 3 8))) "The laid-out deck in window px: pad x0 y0 x1 y1, then cx cy r per chip.")
(defvar *deck-rect* (make-f32 4) "The deck the tap zones' line spans (x0 y0 x1 y1, window px; DECK-LAYOUT).")

(defun deck-split-ends ()
  "The tap zones' line's heights (fractions of the deck's) at its left and right edge, by *HAND* (the thumb's edge is the right
one for the right hand)."
  (if (eq *hand* :left) (values (second *deck-split*) (first *deck-split*)) (values (first *deck-split*) (second *deck-split*))))

(defun deck-update ()
  "Re-lay the deck when the window, the density, the hand or the mode changed (conses: not every frame).
Outside ONE-HAND there is no pad and no chip: a stray finger only makes menu taps."
  (let ((k *deck-key*) (w (window-width)) (h (window-height)) (d (pixel-density)) (s (ui-scale))
        (st (page-get +pg-safe-top+)) (sb (page-get +pg-safe-bottom+)) (u (u-chip-p)))
    (unless (and (= (first k) w) (= (second k) h) (= (third k) d) (eq (fourth k) *hand*) (eq (fifth k) *one-hand*)
                 (= (sixth k) st) (= (seventh k) sb) (= (eighth k) s) (eq (ninth k) u))
      (setf (first k) w (second k) h (third k) d (fourth k) *hand* (fifth k) *one-hand* (sixth k) st (seventh k) sb (eighth k) s
            (ninth k) u *safe-top* st *safe-bot* sb)
      (multiple-value-bind (pad chips deck) (deck-layout)
        (replace *deck* (mapcar #'f32 (append pad (reduce #'append chips))))
        (replace *deck-rect* (mapcar #'f32 deck))
        ;; the portrait frame: under P2's HUD block down to *PT-FRAME-BOTTOM* (over P1's block); the blocks' edges
        (let ((hb (/ (portrait-hud-bottom s) h)) (pt (/ (portrait-p1-top s h) h)))
          (setf (aref *band* 0) (f32 (+ hb 0.03)) (aref *band* 1) (f32 (min *pt-frame-bottom* (- pt 0.03)))
                (aref *band* 2) (f32 hb) (aref *band* 3) (f32 pt)))
        (if *one-hand*
            (multiple-value-bind (fl fr) (deck-split-ends)
              (touch-layout! *touch* d pad chips (if u *u-chip-holds* *chip-holds*))
              (apply #'touch-split! *touch* (append deck (list fl fr))))
            (progn (touch-layout! *touch* d '(0 0 -1 -1) nil)
                   (touch-split! *touch* 0 0 0 0 0 0))))
      ;; G7: the scene near 1.6 MP on a phone (the UI stays native)
      (setf *scene-scale-cap* (if (or *coarse* *one-hand*) (f32 (min 1.0 (sqrt (/ 1.6e6 (max 1 (* w h)))))) 1f0)))))

(defun onehand-init ()
  "Once, at start: ask the page for the device kind and the saved SETTINGS (a missing or blocked storage answers 0:
the defaults)."
  (setf *coarse* (plusp (page-get +pg-coarse+)))
  (loop for (key) in *settings* for i from 0
        do (setf (svref *setting-ix* i) (setting-from-page key (page-get (+ +pg-setting+ i)))))
  (apply-settings)
  (load-bindings)
  (when *coarse* (setf *auto-render-scale* t))
  (log-msg "duel page: coarse ~a hand ~a settings ~a" *coarse* *hand* (coerce *setting-ix* 'list)))

(defun apply-settings ()
  "Put the SETTINGS in force: HAND, the recogniser's tap split and flick distance, the CAMERA option."
  (let ((cfg (touch-cfg *touch*)))
    (setf *hand* (if (= 1 (setting :hand)) :left :right)
          (gc-tap-split cfg) (f32 (setting-value :tap-split))
          (gc-flick-min cfg) (f32 (setting-value :flick))))
  (set-cam-behind (zerop (setting :camera))))

(defun bind-page-key (side i device) (+ +pg-bind+ (* 100 side) i (if (eq device :pad) 50 0)))
(defun load-bindings ()
  "CONTROLS: the saved keys and pad buttons (a code out of range or 0: the default), applied as rebinds in row order."
  (dotimes (side 2)
    (loop for a in *bind-actions* for i from 0
          do (dolist (dev '(:key :pad))
               (let ((n (bind-from-code (page-get (bind-page-key side i dev)) dev)))
                 (when n (rebind *bind-pair* side a dev n)))))))
(defun save-bindings ()
  "CONTROLS: every binding of both players to the page (0 where it is the default)."
  (dotimes (side 2)
    (loop for a in *bind-actions* for i from 0
          do (dolist (dev '(:key :pad)) (page-set (bind-page-key side i dev) (bind-code side a dev *bind-pair*))))))

(defun set-setting (key i)
  "SETTINGS row KEY to option I: in force now and saved by the page."
  (setf (svref *setting-ix* (setting-pos key)) i)
  (apply-settings)
  (page-set (+ +pg-setting+ (setting-pos key)) (1+ i))
  (log-msg "duel setting ~a ~a" key (nth i (third (assoc key *settings*)))))

(defun perfect-up-p (e st)
  "Would a Hoho by E (in state ST) started now be PERFECT? Then a one-hand up-flick is one, rested or not, where it
would be a Step (the user 2026-10-01: the perfect timing is too hard to hit from a rest on a phone), and PERFECT HINT
shows it (hud.lisp HUD-HINT). Free states that take a Hoho, the Hoho affordable (TRY-COMMAND's rule), PERFECT-NOW-P."
  (let ((f (fighter e)))
    (and (member st '(:idle :guard :run)) (battle-p) (not (kit-rooted (fighter-kit f)))
         (hoho-ready-p e)
         (perfect-now-p e))))

(defun awaken-hold-ready-p (e)
  "Would a Mod + P of E do something now (TRY-COMMAND's :awaken, without calling it): the awakening (its gauge full, unused) or
the Bankai (BANKAI-READY-P) from a state that allows it (AWAKEN-STATE-P), in a form ported to the core system. Then 爆 is a
hold (RV-READY-P). (A form's :p hook is left out: Kenpachi's is DANGAI's frozen card, NIL outside it, and Hisagi's FREE sits in
his Bankai, a :no-awaken form.)"
  (let* ((f (fighter e)) (kit (fighter-kit f)) (g (gauges e)))
    (and (not (getf (kit-core kit) :no-awaken)) (awaken-state-p e f)
         (or (awaken-allowed-p t (gauges-awaken g) (gauges-awakened g))
             (and (kit-bankai-form kit) (bankai-allowed-p t (gauges-konpaku g)) (bankai-ok-p e)))
         t)))

(defun rv-ready-p ()
  "爆 (chip 7) is the awakening's hold now (the user, 2026-10-28: 「把覺醒鍵整合進爆氣中，改由長按覺醒」): not ready, the Burst
fires on the press (no wait); ready, a lift before 300 ms is the Burst, a hold of it the awakening (TOUCH-BUTTON)."
  (and *one-hand* *p1* (entity-alive-p *p1*) (fighter *p1*) (awaken-hold-ready-p *p1*)))

(defun rv-holding-p ()
  "爆 is pressed, its awakening hold under way (not yet the awakening): the page fills its REIATSU ring."
  (let ((tr *touch*))
    (and (>= (aref (touch-chip-slot tr) 7) 0) (> (aref (touch-chip-hold tr) 7) 0f0) (not (touch-chip-down-p tr 7)))))

(defun onehand-frame ()
  "Every frame, before the flow: the page (back gesture, wake lock), the text floor, the deck, then this
frame's finger events."
  (setf *back-press* (plusp (page-get +pg-back+))
        *ui-min-css* (if (portrait-p) 11 0))
  (let ((wake (and *coarse* (battle-p) t)))
    (unless (eq wake *wake*) (setf *wake* wake) (page-set +ps-wake+ (if wake 1 0))))
  (deck-update)
  (let ((st (and *one-hand* *p1* (entity-alive-p *p1*) (state-of *p1*))))
    (setf (touch-rest-up-ok *touch*) (and (member st '(:idle :guard)) t)   ; a rested up-flick is a Hoho from neutral / guard,
          (touch-up-hoho *touch*)                            ; any up-flick while attacking (but a stance's Step: 2026-10-06)
          (up-flick-hoho-p st (and (eq st :move) (member :step-branch (mv-flags (fighter-move (fighter *p1*)))) t)
                           (perfect-up-p *p1* st))   ; or when it would be a perfect Hoho (the user 2026-10-01)
          (touch-press-tap *touch*) (eq st :move)))   ; in his own move a tap fires on the press (still 40 ms: no flick), held on
                                                       ; it is the Kikon's hold; in neutral, on the lift, as a drag / Step / Hoho
                                                       ; starts there too (the user, 2026-10-28, option 1 of three: 「1」)
  (when *one-hand* (touch-chip-hold! *touch* 7 (if (rv-ready-p) 300f0 0f0)))   ; 爆: the 0.3 s hold while the awakening is ready
  (touch-poll *touch*)
  (unless (sim-running-p) (touch-take! *touch*))            ; menus / pause: no gesture pulse waits for the match
  (let ((g (touch-glyph-t *touch*)))                        ; the combat log names each recognised gesture
    (when (and *combat-log* (/= g *glyph-seen*))
      (setf *glyph-seen* g)
      (when (plusp (length (svref *glyph-names* (touch-glyph *touch*))))   ; (the unnamed rest: no line)
        (clog "P1 gesture ~a" (svref *glyph-names* (touch-glyph *touch*)))))))


(defun tap-p () "A tap ended this frame (menus)." (touch-tapped-p *touch*))
(defun touch-tap-zones-p () "Menus note their rows as tap targets (a touch device, or a portrait window)." (one-hand-offered-p))

;;; ---------------------------------------------------------------- touch -> vpad (G3)
(defun touch-read-begin ()
  "Start of P1's vpad read: this read's pulses (TOUCH-TAKE!) and whether a down-flick is a Burst."
  (let ((tr *touch*))
    (touch-take! tr)
    (setf *touch-burst* (and (touch-pulse-p tr +tp-flick+) (touch-flick-down-p tr) *p1*
                             (or (member (state-of *p1*) '(:stun :air)) (eq (burst-ok-p *p1*) :orange)) t))
    (when *touch-burst*                                   ; the contact is spent: no stick, no Step held after a Burst (the
      (touch-spend! tr)                                   ; thumb running on past the run ring held Step: ORANGE's freed
      (setf (touch-glyph tr) 7))))                        ; recovery back-stepped; the user 2026-09-30)

(defun u-chip-p ()
  "P1's form has a :u hook (its U is a move, not a guard: a parry): a resting thumb does nothing and the spent
AWAKEN chip is U (the user's default, DUEL_MOBILE_DESIGN §15.1)."
  (and *one-hand* *p1* (entity-alive-p *p1*) (fighter *p1*) (kit-hook (kit-of *p1*) :u) t))

(defun touch-button (name)
  "Is vpad button NAME down from the thumb deck (design §3.2 / §3.4; the core system, 2026-10-27: a tap = the attack, the SP
zone's tap = Mod + the attack, a down-flick while stunned = the Burst (P), a rested up-flick = Hoho (Mod + Step), a flick = Step)?
爆 (chip 7, 2026-10-28): P on the press while the awakening is not ready; while it is (its hold 300 ms, RV-READY-P), P for one
read on a lift before the hold (TOUCH-CHIP-TAP-P: the Burst), Mod + P once held (the awakening; the old AWAKEN chip 5's)."
  (let* ((tr *touch*) (burst *touch-burst*))
    (flet ((chip (i) (touch-chip-down-p tr i)) (pulse (b) (touch-pulse-p tr b)))
      (case name
        (:quick (or (pulse +tp-tap+) (pulse +tp-tap-hi+)))          ; the pad's two tap zones (the old F / Q split): low = the
        (:mod (or (pulse +tp-hoho+) (pulse +tp-tap-hi+)              ; attack, high = SP (Mod + the attack), 2026-10-27
                  (rv-buttons (chip 7) (> (aref (touch-chip-hold tr) 7) 0f0) (touch-chip-tap-p tr 7))))   ; 爆 held through its hold
        (:step (and (not burst) (or (pulse +tp-flick+) (pulse +tp-hoho+) (touch-step-held-p tr))))
        (:awaken (or burst (nth-value 1 (rv-buttons (chip 7) (> (aref (touch-chip-hold tr) 7) 0f0) (touch-chip-tap-p tr 7)))))))))

(defun touch-pause-p () "The pause chip was touched this frame." (and *one-hand* (touch-chip-hit-p *touch* 6)))

;;; ---------------------------------------------------------------- menus (G9)
(defvar *menu-rows* (make-array 16 :initial-element nil) "HUD-MENU's rows last drawn: #(x0 y0 x1 y1) each, NIL after.")
(defun note-menu-row (i x0 y0 x1 y1)
  (when (< i 15)
    (let ((r (or (svref *menu-rows* i) (setf (svref *menu-rows* i) (make-array 4)))))
      (setf (svref r 0) x0 (svref r 1) y0 (svref r 2) x1 (svref r 3) y1)
      (setf (svref *menu-rows* (1+ i)) nil))))
(defun tapped-row (n)
  "The menu row (< N) a tap landed on this frame, or NIL."
  (when (tap-p)
    (let ((x (touch-tap-x *touch*)) (y (touch-tap-y *touch*)))
      (loop for i below n for r = (svref *menu-rows* i) while r
            when (and (<= (svref r 0) x (svref r 2)) (<= (svref r 1) y (svref r 3))) do (return i)))))
(defun tap-third ()
  "A tap this frame: -1 left third of the screen, 1 right third, 0 the middle; NIL without a tap."
  (when (tap-p)
    (let ((u (/ (touch-tap-x *touch*) (max 1 (window-width))))) (cond ((< u 0.33) -1) ((> u 0.67) 1) (t 0)))))

;;; ---------------------------------------------------------------- drawing
;; (%RING %ARC %DISC: engine/lisp/ui.lisp)

(defparameter *c-chip* '(1 1 1 0.9))

(defparameter *chip-labels* (coerce (mapcar #'fourth *chip-spots*) 'simple-vector))

(defun-fast hud-deck (s)
  "The thumb deck (the engine's, when the page draws no battle screens: WEBHUD-P): the flow pad's outline and its slanted tap
split (SP above, ATK below), the chips (lit while held; RV while a burst or the awakening is possible, its REIATSU ring while
the awakening is: the old AWAKEN chip folded into it 2026-10-28),
the ink ring under the thumb, and the recognised gesture's glyph at the thumb for 0.3 s (the misread teacher).
(A DEFUN-FAST since 2026-10-26, ~2 KB a frame before: the floats unboxed, the generic code's operations.)"
  (declare (fixnum s))
  (let* ((tr *touch*) (d (touch-dpx tr)) (dk *deck*) (web (webhud-p))   ; the page draws the deck: only the stick's ring and a form's
         (u (u-chip-p))                                  ; a :u form: the chip is U                          ; :deck hook stay
         (pk (and *p1* (kit-hook (kit-of *p1*) :p)))      ; a :p form: the chip is its P, labelled by :p-label
         (pl (and pk (let ((h (kit-hook (kit-of *p1*) :p-label))) (and h (funcall h *p1*))))))
    (declare (single-float d) (type f32vec dk))
    (unless web
    (%houtline (aref dk 0) (aref dk 1) (- (aref dk 2) (aref dk 0)) (- (aref dk 3) (aref dk 1)) 1f0 1f0 1f0 0.12f0)
    (let* ((dr *deck-rect*) (left (eq *hand* :left))     ; the tap zones' slanted line (*DECK-SPLIT*), named at the far edge
           (x0 (aref dr 0)) (x1 (aref dr 2)) (y0 (aref dr 1)) (dh (- (aref dr 3) y0))
           (fl (if left (f32 (second *deck-split*)) (f32 (first *deck-split*))))
           (fr (if left (f32 (first *deck-split*)) (f32 (second *deck-split*))))
           (yl (+ y0 (* fl dh))) (yr (+ y0 (* fr dh))) (y (if left yr yl)) (t2 (f-max 1f0 d))
           (x (if left (- x1 (* 6f0 d)) (+ x0 (* 6f0 d)))) (al (if left :right :left))
           (fs (%hround (* 1.5f0 (i->f s)))))           ; (HUD-TEXT rounds its (* 1.5 S))
      (declare (type f32vec dr) (single-float x0 x1 y0 dh fl fr yl yr y t2 x) (fixnum fs))
      (%hq x0 yl x1 yr x1 (+ yr t2) x0 (+ yl t2) 1f0 1f0 1f0 0.18f0)
      (%hud-text "SP" x (- y (i->f (* 13 s))) fs '(1 1 1 0.4) :align al :shadow nil)       ; the tap zones (the core system, 2026-10-27)
      (%hud-text "ATK" x (+ y (i->f (* 3 s))) fs '(1 1 1 0.4) :align al :shadow nil))
    (dotimes (i 8)
      (unless (or (member i '(0 1 2 4 5)) (and (= i 7) (not (and *p1* (or (burst-ok-p *p1*) (rv-ready-p))))))   ; RV: while a burst or the awakening is possible
        (let ((on (touch-chip-down-p tr i)) (cx (aref dk (+ 4 (* 3 i)))) (cy (aref dk (+ 5 (* 3 i)))) (r (aref dk (+ 6 (* 3 i)))))
          (declare (single-float cx cy r))
          (%disc cx cy r 0.05 0.04 0.07 (if on 0.85 0.45))
          (%ring cx cy r (* 2f0 d) 1.0 (if on 0.85 0.55) (if on 0.4 0.3) (if on 1.0 0.7))
          (when (and (= i 7) (rv-ready-p)) (%ring cx cy (* 1.25f0 r) (* 2f0 d) 1.0 0.85 0.23 (if (rv-holding-p) 1.0 0.5)))   ; 爆's REIATSU ring
          (when (= i 1)                                  ; a refused L (cooling, cold, its kit's refusal): the chip flashes
            (let ((fl (- 1f0 (* 4f0 (- (fx-clock) (aref *refused-t* 0))))))
              (declare (single-float fl))
              (when (> fl 0f0) (%disc cx cy r 1.0 1.0 1.0 (* 0.7f0 fl)) (%ring cx cy (* 1.15f0 r) (* 3f0 d) 1.0 1.0 1.0 fl))))
          (%hud-text (cond ((and u (= i 5)) "U") ((and pl (= i 5)) pl) (t (svref *chip-labels* i))) cx (- cy (* 3.5f0 (i->f s))) s
                     *c-chip* :align :center :shadow nil)))))
    (when (touch-active-p tr)                              ; the floating stick: an ink ring at its origin
      (%ring (touch-ox tr) (touch-oy tr) (* d 48f0) (* 2f0 d) 1.0 1.0 1.0 (if (touch-resting-p tr) 0.35 0.6))
      (let ((h (and *p1* (kit-hook (kit-of *p1*) :deck)))) (when h (funcall h *p1* (touch-ox tr) (touch-oy tr) d)))   ; a form's own ring
      (let ((m (and *p1* (kit-meter (kit-of *p1*)))))      ; Rukia: resting cools her: the frost arc = C / 200 (the two
        (when (getf m :temp)                                 ; bars round the ring, a notch at the half), grey in the THAW
          (let* ((g (gauges *p1*)) (k (/ (gauges-meter g) *cold-max*)) (lock (plusp (gauges-meter-idle g)))   ; lock;
                 (zero (eq (fighter-form (fighter *p1*)) :zero)) (r (* d 52f0)))                       ; white ring at zero
            (declare (single-float r))
            (when zero (%ring (touch-ox tr) (touch-oy tr) r (* 3f0 d) 1.0 1.0 1.0 0.35))
            (if lock
                (%arc (touch-ox tr) (touch-oy tr) r (* 3f0 d) k 0.55 0.56 0.6 0.8)
                (%arc (touch-ox tr) (touch-oy tr) r (* 3f0 d) k 0.92 0.96 1.0 (if zero (+ 0.6 (* 0.4 (hud-pulse 3.0))) 0.9)))
            (%hrect (- (touch-ox tr) d) (+ (touch-oy tr) r) (* 2f0 d) (* 3f0 d) 1f0 1f0 1f0 0.8f0))))) ; the half: bar 1 full
    (let ((age (- (* 1000f0 (elapsed-time)) (touch-glyph-t tr))))
      (when (and (not web) (< age 300) (plusp (length (the simple-string (svref *glyph-names* (touch-glyph tr))))))   ; (the rest: no glyph)
        (hud-text (svref *glyph-names* (touch-glyph tr)) (touch-glyph-x tr) (- (touch-glyph-y tr) (* 60 d)) (* 2 s)
                  '(1 0.85 0.4 1) :align :center)))))

(defparameter *gesture-card*
  '(("TAP LOW HALF" "ATTACK  (J)  TAPS = STRING") ("TAP HIGH HALF" "SP  (SHIFT+J)")
    ("SP, THEN HOLD STILL" "HOLD THE PAD WHILE THE SP HITS = KIKON")
    ("DRAG" "MOVE  (FAR = RUN)") ("FLICK UP" "DASH  (KEEP GOING = RUN)") ("FLICK DOWN / SIDE" "STEP BACK / SIDESTEP")
    ("HOLD, THEN FLICK UP" "HOHO")
    ("FLICK DOWN WHEN HIT" "BURST  (OR THE RV CHIP)") ("RV HELD 0.3 S, WHEN READY" "AWAKEN") ("II / BACK" "PAUSE"))
  "The static gesture card (ONE-HAND's CONTROLS).")

(defun hud-gestures (w h s)
  (ui-rect 0 0 w h '(0 0 0 0.75))
  (ui-big-text "ONE HAND" (floor w 2) (* 0.08 h) (* 3 s) *white* '(0.7 0.25 0.05 1) s)
  (let ((sc (fit-scale "FLICK DOWN WHEN HIT" s (* 0.9 w))))
    (loop for (a b) in *gesture-card* for i from 0
          for y = (+ (* 0.18 h) (* i (max (* 22 sc) (* 0.058 h)))) do   ; a tall screen: the rows spread down
            (ui-text a (floor w 2) y :scale sc :align :center :color *ember*)
            (ui-text b (floor w 2) (+ y (* 9 sc)) :scale (max 1 (fit-scale b sc (* 0.95 w))) :align :center :color *white*)))
  (ui-text "TAP TO GO BACK" (floor w 2) (* 0.94 h) :scale s :align :center :color *dim* :shadow t))

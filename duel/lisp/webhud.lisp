;;;; webhud.lisp — the page's battle screens (docs/duel/DUEL_WEBUI.md §6-§7, the user 2026-10-28: 「善哉！！幫我把整套接進遊戲中」):
;;;; the battle HUD (the two plates, the timer, the combo, the callout, the prompt), the phone's deck (the tap zones' line, 爆 and 止
;;;; where Lisp's touch hit areas are, the touch feedback as events), the pause menu, the intro and the finish. Lisp decides and
;;;; publishes (the block 30100+, set on a change: WEBHUD-SYNC); the page (duel/web/hud.js) only draws, and queues its pause rows'
;;;; presses (get 30101: WEBHUD-COMMANDS). Without the page (the native gate, an old page: get 30100 = 0) nothing here runs and the
;;;; engine draws all of it (hud.lisp, hud-screens.lisp, onehand.lisp HUD-DECK). Cosmetic and outside the sim step.
;;;; Consing: WEBHUD-SYNC runs every frame of a battle: integers only (WEBHUD-PUT compares a fixnum array), strings by EQ then
;;;; STRING= (sent only on a change: PAGE-SET-STR), the floats in DEFUN-FAST sides (%HROUND).
(in-package :duel)

(defconstant +pg-hud+ 30100 "Page get / set 30100 + k: the battle screens' block (DUEL_WEBUI §7).")
(defvar *webhud* :unknown "Does the page draw the battle screens (page get 30100)? Asked once.")
(defun webhud-p ()
  "Does the page draw the battle screens (hud.js loaded)? A cached old page without it: the engine draws them."
  (when (eq *webhud* :unknown) (setf *webhud* (= 1 (page-get +pg-hud+))))
  *webhud*)

(declaim (type (simple-array fixnum (*)) *hud-sent*))
(defvar *hud-sent* (make-array 200 :element-type 'fixnum :initial-element -1) "The value last set at +PG-HUD+ + i.")
(defvar *hud-strs* (make-array 64 :initial-element nil) "The string last set at +PG-HUD+ + 120 + i.")
(defmacro webhud-put (i v)
  "Set +PG-HUD+ + I to V (fixnum forms) on the page, when it changed (0 B)."
  `(let ((i ,i) (v ,v))
     (declare (fixnum i v))
     (unless (= v (aref *hud-sent* i)) (setf (aref *hud-sent* i) v) (page-set (+ +pg-hud+ i) v))))
(defun webhud-put-str (i s)
  "Set the string +PG-HUD+ + 120 + I to S (NIL: \"\") when it changed: EQ, then STRING= (0 B unless sent)."
  (let ((old (svref *hud-strs* i)) (s (or s "")))
    (unless (or (eq s old) (and old (string= s old)))
      (page-set-str (+ +pg-hud+ 120 i) s))
    (setf (svref *hud-strs* i) s)))

;;; ---------------------------------------------------------------- what the engine leaves to the page
(defun webhud-cine-p (c)
  "Is cinematic C one whose 2D layer (letterbox, title) the page draws: the intro, the K.O., TIME?"
  (and c (member (cine-name c) '(intro-cine ko-cine time-cine)) t))
(defvar *web-caption* nil "The last title of a cinematic the page drew (WEBHUD-CINE-P): its slice-out is the page's too.")

;;; ---------------------------------------------------------------- per side
(declaim (type (simple-array fixnum (*)) *web-seen*) (type f32vec *web-seen-f*))
(defvar *web-seen* (make-array 8 :element-type 'fixnum :initial-element 0)
  "Per side: [side] the callout's frames left last frame, [2 + side] the callout serial, [4 + side] the combo serial,
[6 + side] the combo's hits last frame.")
(defvar *web-callout* (vector nil nil) "Per side: the callout string last seen.")
(defvar *web-seen-f* (make-f32 2) "[0] TOUCH-GLYPH-T last published, [1] its serial (as a float count).")

(defun webhud-tag (e kit)
  "Side E's status tag (ASCII; the page puts it in kanji): his kit's :hud-tag hook (Hisagi's sickle, KESSA's clones), else the
kit meter's label (NOME / UDE), else NIL."
  (let ((h (kit-hook kit :hud-tag)) (meter (svref (kit-hud kit) 1)))
    (cond (h (funcall h e))
          ((getf meter :label) (funcall (getf meter :label) (gauges e) kit))
          (t (getf meter :name)))))

(defun-fast webhud-side (e o)
  "Side E's plate values at offset O (DUEL_WEBUI §7: 50 + 30 side): roster index + 1, Reishi ‰, red, Konpaku, the souls at
stake, flash step ‰, awakening ‰ and its state, the pointer, the combo E deals (the victim's), the callout serial, the kit meter,
the finish's best combo / Kikons, human 1."
  (declare (fixnum o))
  (let* ((f (fighter e)) (g (gauges e)) (kit (fighter-kit f)) (side (fighter-side f)) (seen *web-seen*)
         (op (fighter-opp f)) (of (and op (fighter op)))
         (rmax (max 1 (the fixnum (gauges-reishi-max g)))) (reishi (gauges-reishi g))
         (fs (the single-float (gauges-fs g))) (aw (the single-float (gauges-awaken g)))
         (core (and *core-on* (kit-core kit) t)))
    (declare (fixnum side rmax reishi) (single-float fs aw) (type (simple-array fixnum (*)) seen) (type gauges g))   ; (G typed: its float slots read unboxed)
    (webhud-put o (1+ (the fixnum (or (position (kit-character kit) *roster*) -1))))
    (webhud-put (+ o 1) (truncate (* 1000 (max 0 reishi)) rmax))
    (webhud-put (+ o 2) (if (gauges-red-p g) 1 0))
    (webhud-put (+ o 3) (gauges-konpaku g))
    (webhud-put (+ o 4) (the fixnum (at-stake e)))
    (webhud-put (+ o 6) (%hround (/ (* 1000f0 fs) (the single-float *fs-max*))))
    (webhud-put (+ o 7) (if (gauges-awakened g) 1000 (%hround (/ (* 1000f0 aw) (the single-float *awaken-max*)))))
    (webhud-put (+ o 8) (cond ((or (gauges-awakened g) (kit-awakening kit)) 2)
                              ((and (not (getf (kit-core kit) :no-awaken)) (>= aw (the single-float *awaken-max*))) 1)
                              (t 0)))
    (webhud-put (+ o 9) (if core (core-clamp-pointer (fighter-ptr f)) 0))
    ;; the combo E deals: the victim's hits (shown from the second, PRACTICE's from the first, with damage: hud.lisp's rule)
    (when of
      (let ((hits (fighter-combo-hits of)) (dmg (fighter-combo-dmg of)))
        (declare (fixnum hits dmg))
        (when (and (/= hits (aref seen (+ 6 side))) (> hits (if (eq *mode* :practice) 0 1)) (plusp dmg))
          (webhud-put (+ o 10) hits) (webhud-put (+ o 11) dmg)
          (webhud-put (+ o 12) (%hround (* 1000f0 (the single-float (f32 (combo-scale (max 1 (- hits (fighter-combo-from of)))))))))
          (setf (aref seen (+ 4 side)) (logand 1023 (1+ (aref seen (+ 4 side)))))
          (webhud-put (+ o 13) (aref seen (+ 4 side))))
        (setf (aref seen (+ 6 side)) hits)))
    ;; the callout: a new string, or its frames reset (SIDE-CAP's rule)
    (let ((str (fighter-callout f)) (ct (fighter-callout-t f)))
      (declare (fixnum ct))
      (when (and str (> ct 0) (or (not (eq str (svref *web-callout* side))) (> ct (aref seen side))))
        (webhud-put-str (+ 2 (* 4 side)) str)
        (setf (aref seen (+ 2 side)) (logand 1023 (1+ (aref seen (+ 2 side)))))
        (webhud-put (+ o 14) (aref seen (+ 2 side))))
      (setf (svref *web-callout* side) str (aref seen side) ct))
    (let ((meter (svref (kit-hud kit) 1)))
      (webhud-put (+ o 15) (if meter (%hround (the single-float (gauges-meter g))) 0))
      (webhud-put (+ o 16) (let ((mx (getf meter :max 0)))
                             (cond ((typep mx 'fixnum) mx) ((typep mx 'single-float) (%hround (the single-float mx))) (t 0)))))
    (webhud-put (+ o 17) (gauges-best-combo g))
    (webhud-put (+ o 18) (gauges-kikons g))
    (webhud-put (+ o 19) (if (cpu-p e) 0 1))
    (webhud-put-str (* 4 side) (svref (kit-hud kit) 0))
    (webhud-put-str (+ 1 (* 4 side)) (webhud-tag e kit))
    nil))

;;; ---------------------------------------------------------------- the prompt: what a press can do now
(defun webhud-prompt (e)
  "The prompt for human E (DUEL_WEBUI §7, set 30102 / 30103 and the strings 128 / 129). Values: kind (0 none, 1 the Kikon's
hold (arg: its confirm frames left), 2 SP -> AS n off a landed attack (arg n), 3 a Burst (1 BLUE, 2 ORANGE), 4 the awakening or
the Bankai ready), its arg, the key string (NIL on the phone), the AS's romaji."
  (let* ((f (fighter e)) (side (fighter-side f)) (kit (fighter-kit f)) (mv (fighter-move f))
         (dev (if (pad-connected-p side) :pad :key)) (touch (and *one-hand* (zerop side))))
    (flet ((key (k) (and (not touch) (key-prompt *bind-pair* side dev k))))
      (cond ((and mv (eq (fighter-state f) :move) (eq (fighter-phase f) :follow) (eq (fighter-sp-held f) t)
                  (<= (fighter-hold f) *core-kikon-confirm*))
             (values 1 (- *core-kikon-confirm* (fighter-hold f)) (key :sp-keys) nil))
            ((and mv *core-on* (kit-core kit) (eq (fighter-state f) :move) (member (fighter-cls f) '(:na :sa))
                  (eq (fighter-contact f) :hit) (not (fighter-as-done f))
                  (cancel-open-p (fighter-sf f) (fighter-land-sf f) (mv-total mv) t))
             (let* ((n (core-next-as f))
                    (as (kit-core-move kit :as n)))
               (values 2 n (key :sp-keys) (and as (mv-callout as)))))
            ((member (burst-ok-p e) '(:blue :orange))
             (values 3 (if (eq (burst-ok-p e) :orange) 2 1) (key :p-key) nil))
            ((awaken-hold-ready-p e) (values 4 0 (key :awaken-keys) nil))
            (t (values 0 0 nil nil))))))

;;; ---------------------------------------------------------------- the deck's geometry and events (one hand)
(defun-fast webhud-deck ()
  "The deck's spots in permille of the window (30130-30141: the deck rect, the line's ends, 爆 and 止), the touch feedback (the
last recognised gesture as an event: 30105 serial, its kind, where, its stroke; the Kikon hold ring under a thumb held in the SP
zone during an NS / AS: 30111-30113), 爆's state bits (30104: 1 ready, 2 its hold under way, 4 pressed, 8 a burst possible; your
running burst 16 WHITE, 32 BLUE, 64 ORANGE: the ink in the seal takes its colour, draft C)."
  (let* ((wf (i->f (max 1 (the fixnum (window-width))))) (hf (i->f (max 1 (the fixnum (window-height)))))
         (dk *deck*) (dr *deck-rect*) (tr *touch*) (sf *web-seen-f*) (left (eq *hand* :left)))
    (declare (single-float wf hf) (type f32vec dk dr sf))
    (macrolet ((px (x) `(%hround (/ (* 1000f0 (the single-float ,x)) wf))) (py (y) `(%hround (/ (* 1000f0 (the single-float ,y)) hf))))
      (webhud-put 30 (px (aref dr 0))) (webhud-put 31 (py (aref dr 1))) (webhud-put 32 (px (aref dr 2))) (webhud-put 33 (py (aref dr 3)))
      (webhud-put 34 (%hround (* 1000f0 (aref *deck-split-at* 0))))
      (webhud-put 35 (%hround (* 1000f0 (aref *deck-split-at* 1))))
      (webhud-put 36 (px (aref dk (+ 4 21)))) (webhud-put 37 (py (aref dk (+ 5 21)))) (webhud-put 38 (px (aref dk (+ 6 21))))   ; chip 7
      (webhud-put 39 (px (aref dk (+ 4 18)))) (webhud-put 40 (py (aref dk (+ 5 18)))) (webhud-put 41 (px (aref dk (+ 6 18))))   ; chip 6
      (webhud-put 42 (if left 1 0))
      (let ((gt (touch-glyph-t tr)) (k (touch-glyph tr)))
        (declare (single-float gt) (fixnum k))
        (when (and (/= gt (aref sf 0)) (/= k 5))          ; (5, the rest: no event)
          (setf (aref sf 1) (if (> (aref sf 1) 1000f0) 1f0 (+ 1f0 (aref sf 1))))
          (webhud-put 6 k) (webhud-put 7 (px (touch-glyph-x tr))) (webhud-put 8 (py (touch-glyph-y tr)))
          (webhud-put 9 (px (touch-fx tr))) (webhud-put 10 (py (touch-fy tr)))
          (webhud-put 5 (%hround (aref sf 1))))
        (setf (aref sf 0) gt))
      (let ((ring (and *p1* (entity-alive-p *p1*) (core-touch-sp-p) (eq (fighter-state (fighter *p1*)) :move)
                       (member (fighter-cls (fighter *p1*)) '(:ns :as)) t)))
        (webhud-put 11 (if ring 1 0))
        (when ring (webhud-put 12 (px (touch-ox tr))) (webhud-put 13 (py (touch-oy tr))))))
    (webhud-put 4 (logior (if (rv-ready-p) 1 0) (if (rv-holding-p) 2 0) (if (>= (aref (touch-chip-slot tr) 7) 0) 4 0)
                          (if (and *p1* (entity-alive-p *p1*) (burst-ok-p *p1*)) 8 0)
                          (case (and *p1* (entity-alive-p *p1*) (gauges-burst (gauges *p1*))) (:white 16) (:blue 32) (:orange 64) (t 0))))
    nil))

;;; ---------------------------------------------------------------- the pause rows, the intro, the finish
(defvar *web-paused* nil "Was the pause up last frame (the rows are sent when it opens and after PAUSE-DO: *PAUSE-DIRTY*).")

(defun webhud-pause ()
  "The pause rows (strings 130 + i, their count 30118, the cursor 30117), sent when the pause opens or a row changed."
  (when (or (not *web-paused*) *pause-dirty*)
    (setf *pause-dirty* nil)
    (let ((items (pause-items)))
      (loop for it in items for i from 0 below 20 do (webhud-put-str (+ 10 i) it))
      (webhud-put 18 (min 20 (length items)))
      (webhud-put 19 (logand 1023 (1+ (aref *hud-sent* 19))))))
  (webhud-put 17 *menu*)
  (setf (svref *menu-rows* 0) nil))                      ; the engine's rows are not drawn: no tap lands on a stale one

(defun webhud-intro-phase ()
  "The intro's phase (30114): 1 P1's name, 2 P2's, 3 READY, 4 斬 (the FIGHT! beat, frame 250), 0 none."
  (let ((c *cine*))
    (if (and c (eq (cine-name c) 'intro-cine))
        (let ((cf (cine-cf c))) (cond ((< cf 120) 1) ((< cf 225) 2) ((< cf 250) 3) (t 4)))
        0)))

;;; ---------------------------------------------------------------- every frame
(defun webhud-sync ()
  "Show the page this frame's battle (FLOW-UPDATE, after WEBUI-SYNC). Layer bits (30100): 1 a battle (intro / fight / finish), 2 a
cinematic (the plates hidden), 4 paused, 8 the phone's deck, 16 PRACTICE (no timer), 32 the cinematic's 2D layer is the page's
(the intro, the K.O., TIME), 64 ONE-HAND turned to landscape (the pause asks to rotate). The title of such a cinematic: its
reading and its line (strings 30 / 31; the kanji are the page's)."
  (when (webhud-p)
    (let* ((battle (and (battle-p) *p1* *p2* (entity-alive-p *p1*) (entity-alive-p *p2*) t))
           (paused (and battle *paused* (eq *flow* :battle) t))
           (web-cine (webhud-cine-p *cine*)))
      (webhud-put 0 (if battle
                        (logior 1 (if *cine* 2 0) (if paused 4 0)
                                (if (and *one-hand* (portrait-p) (eq *flow* :battle)) 8 0)
                                (if (eq *mode* :practice) 16 0) (if web-cine 32 0) (if (and *one-hand* (not (portrait-p))) 64 0))
                        0))
      (when battle
        (when (and web-cine *caption*)
          (unless (eq *caption* *web-caption*)
            (webhud-put-str 30 (bcap-reading *caption*)) (webhud-put-str 31 (bcap-sub *caption*)))
          (setf *web-caption* *caption*))
        (webhud-put 1 (if (eq *mode* :practice) -1 (min 999 (ceiling (max 0 *timer*) 60))))
        (webhud-side *p1* 50)
        (webhud-side *p2* 80)
        (let ((h (cond ((not (cpu-p *p1*)) *p1*) ((not (cpu-p *p2*)) *p2*))))
          (if (and h (eq *flow* :battle) (not *cine*) (not paused))
              (multiple-value-bind (kind arg keys as) (webhud-prompt h)
                (webhud-put 2 kind) (webhud-put 3 arg) (webhud-put-str 8 keys) (webhud-put-str 9 as))
              (webhud-put 2 0)))
        (when *one-hand* (webhud-deck))
        (webhud-put 14 (webhud-intro-phase))
        (let* ((c *cine*) (ko (and c (eq (cine-name c) 'ko-cine))) (tm (and c (eq (cine-name c) 'time-cine))))
          (webhud-put 15 (cond (ko 1) ((and tm (member *winner* '(0 1))) 2) (tm 3) (t 0)))   ; 決着 K.O. / 時間切れ / a draw
          (webhud-put 16 (cond ((member *winner* '(0 1)) *winner*)                         ; the winner: the K.O.'s first actor
                               ((and ko (fighter (cine-a c))) (fighter-side (fighter (cine-a c))))   ; (debug 2208's has no *WINNER*)
                               (t 2))))
        (when paused (webhud-pause)))
      (setf *web-paused* paused))))

(defun webhud-commands ()
  "This frame's pause presses from the page (get 30101, a queue): 7 x 100000 + CMD x 1000 + ARG, 1 a row under the pointer
(the cursor), 2 confirm, 4 left, 5 right (as the menus' commands, WEBUI-COMMANDS); dropped unless the pause is up. One press
(2-5) a frame."
  (when (webhud-p)
    (loop repeat 8
          for c = (page-get (+ +pg-hud+ 1))
          while (plusp c)
          do (multiple-value-bind (from rest) (floor c 100000)
               (multiple-value-bind (cmd arg) (floor rest 1000)
                 (when (and (= from 7) *paused* (eq *flow* :battle))
                   (case cmd
                     (1 (setf *menu* arg))
                     (2 (setf *ui-press* (logior *ui-press* 16)))
                     (4 (setf *ui-press* (logior *ui-press* 4)))
                     (5 (setf *ui-press* (logior *ui-press* 8)))))
                 (when (<= 2 cmd 5) (return)))))))

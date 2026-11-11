;;;; webui.lisp — the page's HTML menus (docs/duel/DUEL_WEBUI.md): what Lisp shows them and what their pointer presses do.
;;;; The flow (flow.lisp) owns every decision; the page (duel/web/menu.js) draws TITLE / MODE / SETTINGS / CONTROLS / SELECT /
;;;; RESULTS from the values WEBUI-SYNC sets (the block +PG-UI+, only on a change) and queues its rows' presses as commands
;;;; WEBUI-COMMANDS turns into this frame's presses (*UI-PRESS*) or direct choices. Without the page (the native gate, an old
;;;; page) nothing here runs and the engine draws the menus as before (HUD-DRAW). Cosmetic and outside the sim step.
(in-package :duel)

(defconstant +pg-ui+ 30000 "Page get / set 30000 + k: the HTML menus' block (DUEL_WEBUI §3).")
(defvar *webui* :unknown "Does the page have the HTML menus (page get 30000)? Asked once.")
(defun webui-p ()
  "Are the page's HTML menus on?"
  (when (eq *webui* :unknown) (setf *webui* (= 1 (page-get +pg-ui+))))
  *webui*)

(defun webui-screen ()
  "The screen code the page shows for *FLOW* (DUEL_WEBUI §3, set 30000): 0 none (battle, cinematics, the frozen ENDLESS /
DANGAI screens, which the engine still draws)."
  (if (eq *mode* :endless)
      (case *flow* (:title 1) (:mode 2) (:settings 3) (:controls 4) (t 0))
      (case *flow* (:title 1) (:mode 2) (:settings 3) (:controls 4) (:select 5) (:results 6) (t 0))))

;;; Who draws the menus (DUEL_LISP_HUD §4.6, phases 5-6): the page (menu.js) under the renderer :HTML, Lisp (lhud-menu*.lisp)
;;; under :LISP (*HUD-RENDERER*, webhud.lisp: one switch for the battle screens and the menus). The model below (*UI-SENT*) is
;;; kept for both; only the page's renderer is sent it.
(declaim (special *hud-renderer*))                       ; (webhud.lisp's)
(defun lhud-menus-p () "Does Lisp draw the menus (renderer :LISP)?" (eq *hud-renderer* :lisp))
(defun menu-page-draws-p () "Does the page draw the menus (it has menu.js and the renderer is :HTML)?" (and (webui-p) (not (lhud-menus-p))))
(defun webui-on-screen-p ()
  "Is this screen drawn by the page or by the Lisp menus (HUD-DRAW's canvas menus leave it out; FLOW's raw tap readers too)?"
  (and (or (webui-p) (lhud-menus-p)) (plusp (webui-screen))))

(defvar *ui-sent* (make-array 64 :element-type 'fixnum :initial-element -1)
  "The menus' model (DUEL_WEBUI §3: V k = +PG-UI+ + k), read by both renderers: the value last set at +PG-UI+ + i.")
(declaim (type (simple-array fixnum (*)) *ui-sent*))
(defun ui-put (i v)
  "Set the model's V I to V, and on the page when the page draws the menus, when it changed."
  (declare (fixnum i v))
  (unless (= v (aref *ui-sent* i))
    (setf (aref *ui-sent* i) v)
    (when (menu-page-draws-p) (page-set (+ +pg-ui+ i) v))))

;;; ---------------------------------------------------------------- the renderer's switch and the HUD row (control.lisp :HUD)
(defvar *ui-rend* :none "The renderer WEBUI-SYNC last saw: a change hides the page's menus (to :LISP) or re-sends them (to :HTML).")
(defvar *hud-row-seen* nil "(option . renderer) WEBUI-SYNC last reconciled for SETTINGS' HUD row, NIL before the first frame.")
(defun webui-renderer-sync ()
  "SETTINGS' HUD row and the renderer kept equal, each edge-triggered: the row changed (either menu) -> SET-HUD-RENDERER at once; the
renderer changed elsewhere (the URL flag ?hud=lisp at startup, debug 2517) -> the row shows it, not saved (the main session,
2026-11-11, DUEL_LISP_HUD §7: the URL flag wins for that run). Then a renderer change: to :LISP the page's menus are hidden once
(30000 = 0), to :HTML every value is sent again."
  (let ((s (setting :hud)) (seen *hud-row-seen*))
    (flet ((show-renderer () (setf (svref *setting-ix* (setting-pos :hud)) (if (lhud-menus-p) 1 0))))
      (cond ((and (null seen) (= s 1)) (set-hud-renderer :lisp))   ; (the saved LISP)
            ((null seen) (show-renderer))                         ; (the URL flag, or HTML)
            ((/= s (car seen)) (set-hud-renderer (if (= s 1) :lisp :html)))
            ((not (eq *hud-renderer* (cdr seen))) (show-renderer))))
    (if seen
        (setf (car seen) (setting :hud) (cdr seen) *hud-renderer*)
        (setf *hud-row-seen* (cons (setting :hud) *hud-renderer*))))
  (unless (eq *ui-rend* *hud-renderer*)
    (setf *ui-rend* *hud-renderer*)
    (if (lhud-menus-p)
        (when (webui-p) (page-set +pg-ui+ 0))
        (fill *ui-sent* -1))))

;;; ---------------------------------------------------------------- the Lisp menus' command queue (lhud-menu.lisp's pointer)
(declaim (type (simple-array fixnum (*)) *ui-queue*))
(defvar *ui-queue* (make-array 17 :element-type 'fixnum :initial-element 0)
  "The Lisp menus' pointer commands in the page's encoding (SCREEN x 100000 + CMD x 1000 + ARG), drained by WEBUI-COMMANDS as the
page's get 30001 is: [16] the count, [0..15] the commands in order.")
(defun ui-send (cmd arg)
  "Queue command CMD with ARG from the screen the Lisp menus show (menu.js's send; dropped when 16 wait)."
  (declare (fixnum cmd arg))
  (let ((q *ui-queue*) (scr (aref *ui-sent* 0)))
    (when (and (plusp scr) (< (aref q 16) 16))
      (setf (aref q (aref q 16)) (+ (* scr 100000) (* cmd 1000) arg))
      (incf (aref q 16)))))
(defun ui-queue-pop ()
  "The next queued Lisp command, 0 = none."
  (let ((q *ui-queue*))
    (if (zerop (aref q 16)) 0
        (prog1 (aref q 0) (replace q q :start1 0 :start2 1 :end2 (aref q 16)) (decf (aref q 16))))))

(defun ui-roster-ix (c) "C's roster index (0 when none)." (or (position c *roster*) 0))

(declaim (special *scene-transparent*))   ; (draw.lisp's)
(defun webui-sync ()
  "Show the page this frame's state (FLOW-UPDATE, after the screens). SELECT draws the fighters alone over the page's cards
(the user, 2026-10-28: 「選角畫面現在會在廣場上畫出雙方的 3D 模型時，將人物以外的背景設為透明」)."
  (when (or (webui-p) (lhud-menus-p))
    (webui-renderer-sync)
    (let ((scr (webui-screen)))
      (ui-put 0 scr)
      (setf *scene-transparent* (= scr 5))
      (when (plusp scr)
        (ui-put 1 *menu*)
        (ui-put 3 (ui-roster-ix (first *picks*))) (ui-put 4 (ui-roster-ix (second *picks*)))   ; (RESULTS' names too)
        (ui-put 11 (if (case *flow* (:title (> *ft* 0.3)) (:results (> *ft* 2.5)) (t t)) 1 0))
        (case *flow*
          (:select
           (ui-put 2 *select-phase*)
           (ui-put 5 (or (position *difficulty* *difficulties*) 1))
           (ui-put 6 (or (position *mode* '(:vs-cpu :practice :vs-player :cpu-cpu)) 0))
           (ui-put 7 (if *cam-behind* 1 0))
           (ui-put 8 (let ((rows (select-rows))) (+ (if (member :difficulty rows) 1 0) (if (member :camera rows) 2 0)))))
          (:settings
           (loop for row in (settings-shown) for i from 0 below 10 do (ui-put (+ 40 i) (setting (first row)))))
          (:controls
           (ui-put 9 (+ *bind-col* (if *capture* 10 0))) (ui-put 10 (if (one-hand-offered-p) 1 0))
           (let ((side (floor *bind-col* 2)) (dev (if (evenp *bind-col*) :key :pad)))
             (loop for a in *bind-actions* for i from 0
                   do (ui-put (+ 50 i) (1+ (or (position (binding-name (svref *bind-pair* side) a dev)
                                                         (if (eq dev :key) *bind-keys* *bind-pads*))
                                                -1))))))
          (:results
           (ui-put 20 (case *winner* (0 0) (1 1) (t 2)))
           (ui-put 21 (round (match-play-ticks) 60))
           (flet ((side (e o)
                    (when (and e (entity-alive-p e))
                      (let ((g (gauges e)))
                        (ui-put o (round (gauges-dealt g))) (ui-put (+ o 1) (round (gauges-kikons g)))
                        (ui-put (+ o 2) (round (gauges-perfects g))) (ui-put (+ o 3) (round (gauges-best-combo g)))
                        (ui-put (+ o 4) (round (gauges-konpaku g)))))))
             (side *p1* 22) (side *p2* 27))))))))

(defun webui-command (cmd arg)
  "One pointer command from either renderer (the page's or the Lisp menus' queue), on this screen: 1 cursor, 2 confirm, 3 back,
4 left, 5 right, 6 SELECT's pick, 7 a SETTINGS row's option, 8 CONTROLS' column."
  (case cmd
    (1 (setf *menu* arg))
    (2 (setf *ui-press* (logior *ui-press* 16)))
    (3 (setf *ui-press* (logior *ui-press* 32)))
    (4 (setf *ui-press* (logior *ui-press* 4)))
    (5 (setf *ui-press* (logior *ui-press* 8)))
    (6 (let ((c (nth arg *roster*)))
         (when (and c (< *select-phase* 2) (member c (playable-roster))
                    (not (eq c (nth (min 1 *select-phase*) *picks*))))
           (setf (nth (min 1 *select-phase*) *picks*) c)
           (play-sfx :select) (select-respawn))))
    (7 (multiple-value-bind (r o) (floor arg 10)
         (let ((row (nth r (settings-shown))))
           (when (and row (< o (length (third row))))
             (setf *menu* r) (play-sfx :select) (set-setting (first row) o)))))
    (8 (when (and (< arg 4) (not *capture*)) (setf *bind-col* arg) (play-sfx :select)))))

(defun webui-commands ()
  "This frame's pointer presses: the page's queue (get 30001) when it draws the menus, else the Lisp menus' (*UI-QUEUE*): SCREEN x
100000 + CMD x 1000 + ARG; one sent from another screen than this one is dropped (a quick double click). One press (2-5) a frame:
the rest wait for the next (two rights are two steps)."
  (when (or (webui-p) (lhud-menus-p))
    (let ((scr (webui-screen)) (page (menu-page-draws-p)))
      (loop repeat 8
            for c = (if page (page-get (+ +pg-ui+ 1)) (ui-queue-pop))
            while (plusp c)
            do (multiple-value-bind (from rest) (floor c 100000)
                 (multiple-value-bind (cmd arg) (floor rest 1000)
                   (when (and (= from scr) (plusp scr)) (webui-command cmd arg))
                   (when (<= 2 cmd 5) (return))))))))

(defun select-spot (k)
  "SELECT's model spot, permille of the window (K 0 x, 1 y): where the camera frames the fighter being picked (camera.lisp
:SELECT-WEB). The page measures it (get 30002 / 30003) under :HTML; the Lisp layout gives it under :LISP (LM-SELECT-SPOT)."
  (if (lhud-menus-p) (lm-select-spot k) (page-get (+ +pg-ui+ 2 k))))

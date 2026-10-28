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

(defun webui-on-screen-p () "Is the page drawing this screen (HUD-DRAW leaves it out)?" (and (webui-p) (plusp (webui-screen))))

(defvar *ui-sent* (make-array 64 :element-type 'fixnum :initial-element -1) "The value last set at +PG-UI+ + i.")
(defun ui-put (i v)
  "Set +PG-UI+ + I to V on the page, when it changed."
  (declare (fixnum i v))
  (unless (= v (aref *ui-sent* i))
    (setf (aref *ui-sent* i) v)
    (page-set (+ +pg-ui+ i) v)))

(defun ui-roster-ix (c) "C's roster index (0 when none)." (or (position c *roster*) 0))

(declaim (special *scene-transparent*))   ; (draw.lisp's)
(defun webui-sync ()
  "Show the page this frame's state (FLOW-UPDATE, after the screens). SELECT draws the fighters alone over the page's cards
(the user, 2026-10-28: 「選角畫面現在會在廣場上畫出雙方的 3D 模型時，將人物以外的背景設為透明」)."
  (when (webui-p)
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

(defun webui-commands ()
  "This frame's presses from the page (get 30001, a queue): SCREEN x 100000 + CMD x 1000 + ARG; one sent from another screen
than this one is dropped (a quick double click). 1 cursor, 2 confirm, 3 back, 4 left, 5 right, 6 SELECT's pick, 7 a SETTINGS
row's option, 8 CONTROLS' column. One press (2-5) a frame: the rest wait for the next (two rights are two steps)."
  (when (webui-p)
    (let ((scr (webui-screen)))
      (loop repeat 8
            for c = (page-get (+ +pg-ui+ 1))
            while (plusp c)
            do (multiple-value-bind (from rest) (floor c 100000)
                 (multiple-value-bind (cmd arg) (floor rest 1000)
                   (when (and (= from scr) (plusp scr))
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
                   (when (<= 2 cmd 5) (return))))))))

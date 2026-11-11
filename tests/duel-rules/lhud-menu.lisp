;; ================================================================ the Lisp menus: tables and layout (DUEL_LISP_HUD §15)
;; lhud-menu-data.lisp (menu.js's tables as Lisp) against the model's rows, and lhud-menu-geom.lisp's boxes against Chrome's
;; getBoundingClientRect of the HTML menus (build/lhud/p56/dom.py: 1280 x 720 and 390 x 844, CSS px, base d337a824; SETTINGS'
;; compacted rows against the HTML after the same change).
(in-package :duel)
(load (merge-pathnames "../../duel/lisp/lhud-charset.lisp" *load-truename*))
(load (merge-pathnames "../../duel/lisp/lhud-menu-data.lisp" *load-truename*))
(load (merge-pathnames "../../duel/lisp/lhud-menu-geom.lisp" *load-truename*))

;; tables: the rows the model counts
(check (= (length *lm-modes*) 7))                                                  ; MODE's seven rows (flow.lisp *MODE-ROWS*)
(check (equal (map 'list #'first *lm-modes*) '("VS CPU" "PRACTICE" "VS PLAYER" "CPU VS CPU" "SETTINGS" "CONTROLS" "MANUAL")))
(check (= (length *lm-settings*) 8))                                               ; SETTINGS-SHOWN: 7 + the HUD row
(check (equal (first (aref *lm-settings* 7)) "HUD"))
(check (equal (coerce (second (aref *lm-settings* 7)) 'list) '("HTML" "LISP")))
(check (equal (map 'list (lambda (r) (length (second r))) *lm-settings*) '(3 2 5 2 2 2 6 2)))   ; options per row (control.lisp)
(check (= (length *lm-binds*) 10))                                                 ; *BIND-ACTIONS* + RESET DEFAULTS + BACK
(check (equal (lm-bind-name 10 nil) "J"))
(check (equal (lm-bind-name 37 nil) "SPACE"))
(check (equal (lm-bind-name 1 t) "A"))
(check (equal (lm-bind-name 0 nil) "—"))
(check (equal (lm-card-name 3) "ICHIGO"))
(check (equal (lm-card-name 0) "—"))                                               ; a retired roster index: the dash, as menu.js
(check (equal (lm-sel-title 1 1) "CHOOSE THE DUMMY"))
(check (equal (cdr (aref *lm-screens* 3)) "SETTINGS"))

;; layout: CSS px against the HTML's boxes
(defun lmg-at (cw ch fn &rest args)
  (let ((g (make-f32 32))) (lm-content! g cw ch 0.0 0.0 0.0 0.0) (apply fn g cw ch args) g))
(defmacro near (a b) `(< (abs (- ,a ,b)) 0.2))
(let ((g (lmg-at 1280.0 720.0 #'lm-title-geom!)))                                  ; TITLE, desktop
  (check (and (near (aref g 0) 16) (near (aref g 1) 64) (near (aref g 2) 1264) (near (aref g 3) 660)))
  (check (and (near (aref g 4) 217.6) (near (aref g 5) 114.5)))                    ; .wordmark
  (check (and (near (aref g 6) 331.2) (near (aref g 7) 932.8) (near (aref g 8) 112.2)))   ; .big-kanji
  (check (and (near (aref g 9) 1098.4) (near (aref g 10) 424.6)))                  ; .t-vert (its centre)
  (check (and (near (aref g 11) 544.8) (near (aref g 12) 591.6))))                 ; .t-sub, .press
(let ((g (lmg-at 390.0 844.0 #'lm-title-geom!)))                                    ; TITLE, a phone
  (check (and (near (aref g 4) 120.9) (near (aref g 5) 415.7)))
  (check (and (near (aref g 6) 388.24) (near (aref g 7) -14.24) (near (aref g 8) 67.52) (< (aref g 9) 0)))
  (check (and (near (aref g 11) 666.3) (near (aref g 12) 713.1))))
(let ((g (lmg-at 1280.0 720.0 #'lm-mode-geom! 2 1)))                                ; MODE, desktop (a two-line paragraph, one row of tags)
  (check (and (near (aref g 4) 158.4) (near (aref g 5) 16) (near (aref g 6) 209.9)))
  (check (and (near (aref g 7) 212.8) (near (aref g 8) 257.7) (near (aref g 9) 349.9) (near (aref g 10) 208.5)))
  (check (and (near (aref g 11) 680.2) (near (aref g 12) 98.1) (near (aref g 13) 583.8) (near (aref g 14) 73.7))))
(let ((g (lmg-at 390.0 844.0 #'lm-mode-geom! 2 2)))                                 ; MODE, a phone (the tags wrap)
  (check (and (near (aref g 4) 76) (near (aref g 6) 263.6)))
  (check (and (near (aref g 7) 106) (near (aref g 8) 251.1) (near (aref g 9) 268) (near (aref g 10) 170.9)))
  (check (and (near (aref g 11) 16) (near (aref g 12) 440.1) (near (aref g 14) 47.4))))
;; SETTINGS' rows uncompacted = the HTML before the HUD row (1280 x 720, d337a824): 85.2 (focused, help shown) 66 63 66 66 66 63, then
;; the HUD row 66, RESET LEARNING 57, BACK 51; compacted (desktop <= 820 tall: padding 10) and narrow (padding 9)
(check (every (lambda (a b) (near a b)) (loop for i below 10 collect (lm-set-row-h i 0.0 (if (= i 0) 1.0 0.0))) '(85.2 66 63 66 66 66 63 66 57 51)))
(check (every (lambda (a b) (near a b)) (loop for i below 10 collect (lm-set-row-h i 0.5 0.0)) '(58 58 55 58 58 58 55 58 49 43)))
(check (every (lambda (a b) (near a b)) (loop for i below 10 collect (lm-set-row-h i 1.0 0.0)) '(56 56 53 56 56 56 53 56 44 38)))
(let* ((h (make-f32 16)) (g (progn (setf (aref h 0) 1.0) (lmg-at 1280.0 720.0 #'lm-set-geom! h))))   ; desktop 720: compacted, fits
  (check (near (aref g 11) 0.5))
  (check (<= (+ (aref g 25) (lm-set-row-h 9 0.5 0.0)) 660.0))                     ; BACK ends inside the content box
  (check (and (near (aref g 4) 606.2) (near (aref g 5) 657.8))))
(let* ((h (make-f32 16)) (g (lmg-at 1440.0 900.0 #'lm-set-geom! h)))                ; 1440 x 900: the CSS as it was
  (check (near (aref g 11) 0.0))
  (check (<= (+ (aref g 25) 51.0) 840.0)))
(let* ((h (make-f32 16)) (g (progn (setf (aref h 0) 1.0) (lmg-at 390.0 844.0 #'lm-set-geom! h))))     ; a phone: the title over the list
  (check (near (aref g 11) 1.0))
  (check (near (+ (aref g 25) 38.0) 784.0))                                       ; bottom-aligned
  (check (>= (aref g 8) 64.0)))
(let ((g (lmg-at 1280.0 720.0 #'lm-ctl-geom! 0)))                                   ; CONTROLS, desktop
  (check (and (near (aref g 4) 606.2) (near (aref g 5) 657.8) (near (aref g 6) 85) (near (aref g 11) 1.0)))
  (check (near (aref g 8) 223.3)))
(let ((g (lmg-at 390.0 844.0 #'lm-ctl-geom! 1)))                                    ; CONTROLS, the phone's gestures card
  (check (and (near (aref g 6) 573) (near (aref g 8) 467.5) (near (aref g 11) (/ 358 560.0)))))
(let* ((w (make-f32 3)))
  (setf (aref w 0) 1.0 (aref w 1) 4.0 (aref w 2) 1.0)                             ; SELECT, a phone, phase 0 (Ichigo focused)
  (let ((g (lmg-at 390.0 844.0 #'lm-select-geom! w 0)))
    (check (and (near (aref g 9) 196) (near (aref g 15) 84.3) (near (aref g 11) 290.3) (near (aref g 17) 337.3) (near (aref g 13) 637.7))))
  (setf (aref w 0) 4.0 (aref w 1) 1.0)                                             ; the last page (Kenpachi focused, the foot wraps)
  (let ((g (lmg-at 390.0 844.0 #'lm-select-geom! w 1)))
    (check (and (near (aref g 9) 196) (near (aref g 15) 294.7) (near (aref g 11) 500.7) (near (aref g 17) 73.7) (near (aref g 7) 676))))
  (setf (aref w 0) 1.0 (aref w 1) 2.6)                                             ; desktop, phase 0
  (let ((g (lmg-at 1280.0 720.0 #'lm-select-geom! w 0)))
    (check (and (near (aref g 5) 145.2) (near (aref g 6) 598) (near (aref g 8) 16) (near (aref g 14) 266.96) (near (aref g 16) 694.1)))))

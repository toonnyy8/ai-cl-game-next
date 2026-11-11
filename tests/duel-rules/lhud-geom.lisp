;; ================================================================ the Lisp HUD's handheld screen: tables and geometry (DUEL_LISP_HUD §13)
;; lhud-data.lisp (hud.js FIGHTERS / MOVES / tagHTML as Lisp tables) and lhud-geom.lisp (the deck's line, your plate's rotation, the
;; stance ring, the deck's bottom) from the model's permille numbers, against the numbers hud.js computes for the same model.
(in-package :duel)

;; tables
(check (equal (first (lhud-fighter 4)) "ICHIGO"))                                   ; roster 3 + 1
(check (equal (second (lhud-fighter 2)) "更木"))
(check (equal (lhud-fighter 6) nil))                                                ; index 5: the old Lille's empty slot
(check (equal (lhud-fighter 0) nil))
(check (equal (lhud-label-name "SHIKAI") "SHIKAI"))
(check (equal (lhud-label-form "ICHIGO  KESSA") "KESSA"))
(check (equal (lhud-label-form "ICHIGO") ""))
(check (equal (mapcar #'first (lhud-seals (lhud-fighter 2) "" nil)) '("拖" "肩" "構")))          ; sealed Kenpachi
(check (equal (mapcar #'first (lhud-seals (lhud-fighter 2) "SHIKAI" nil)) '("旋" "墜")))
(check (equal (mapcar #'first (lhud-seals (lhud-fighter 4) "KESSA" "BUNSHIN x2")) '("鎖" "月" "影")))
(check (equal (mapcar #'first (lhud-seals (lhud-fighter 8) "FUSHI NO KOJO" "BIND")) '("鎌" "絞")))   ; Hisagi's Bankai: form + tag
(check (equal (mapcar #'first (lhud-seals (lhud-fighter 1) "" nil)) '("一" "二" "三")))           ; no seals of his own: PTR0
(check (equal (second (first (lhud-seals (lhud-fighter 4) "" nil))) "重 · CLEAVER"))
(check (equal (lhud-move-kanji "Getsuga Tensho") "月牙天衝"))
(check (equal (lhud-move-kanji "NOTHING") nil))
(check (equal (lhud-tag-segments "ICHIGO  KESSA" "BUNSHIN x3") '(("KESSA" . nil) (" · " . t) ("分身" . nil) (" · " . t) ("×3" . nil))))
(check (equal (lhud-tag-segments "HISAGI" "KAZESHINI OUT") '(("風死" . nil) (" · " . t) ("THROWN" . nil))))
(check (equal (lhud-tag-segments "KENPACHI  SHIKAI" "KAIHO") '(("SHIKAI" . nil))))             ; a kit strip's kind: no tag text
(check (equal (lhud-tag-segments "KENPACHI" nil) nil))
(check (equal (lhud-tag-segments "X" "kosei x2.4") '(("KOSEI X2.4" . nil))))
(check (~= (lhud-kit-kind "UDE") 2 1e-3))
(check (~= (lhud-kit-kind "BUNSHIN x1") 0 1e-3))

;; the overlays' tables (DUEL_LISP_HUD §14): the intro's column and line, the pause rows as hud.js splits them
(check (equal (lhud-full-name (lhud-fighter 2) "KENPACHI") "更木剣八"))
(check (equal (lhud-full-name nil "ABC  FORM") "ABC"))
(check (equal (lhud-cry-line "ZANGETSU") "斬月 · ZANGETSU"))
(check (equal (lhud-cry-line "OTHER") "OTHER"))
(check (equal (lhud-cry-line nil) ""))
(check (equal (multiple-value-list (lhud-pause-row "RESUME")) '("RESUME" nil "繼續")))
(check (equal (multiple-value-list (lhud-pause-row "DUMMY  STAND")) '("DUMMY" "STAND" nil)))
(check (equal (multiple-value-list (lhud-pause-row "P1 HP  100%")) '("P1 HP" "100%" nil)))
(check (equal (multiple-value-list (lhud-pause-row "CAMERA  SIDE  X")) '("CAMERA" "SIDE X" nil)))
(check (equal (multiple-value-list (lhud-pause-row "CHARACTER SELECT")) '("CHARACTER SELECT" nil "換角色")))

;; geometry: 453 x 823 CSS at dpr 3, the model of the user's screenshot (V30-V35 = 0 630 1000 1000 -124 448, V36-38 = 842 847 87)
(let ((g (make-f32 8)) (w (* 3f0 453)) (h (* 3f0 823)))
  ;; hud.js: w = 453, h = 823 * .37 = 304.51, rise = (44.8 - -12.4) / 100 * h = 174.18, len = hypot = 485.33, ang = atan2 = .36712
  (lhud-deck-line! g w h 0 630 1000 1000 -124 448 nil)
  (check (~= (/ (aref g 0) 3) 0f0 1e-3))
  (check (~= (/ (aref g 1) 3) (+ (* 823 0.63) (* 304.51 -0.124)) 0.01))          ; fy = 518.49 - 37.76 = 480.73
  (check (~= (/ (aref g 2) 3) 485.33 0.05))
  (check (~= (aref g 3) 0.36712 1e-4))
  (check (~= (/ (aref g 7) 3) 304.51 0.01))
  (lhud-deck-line! g w h 0 630 1000 1000 -124 448 t)                         ; the left hand: the far point at the right, the angle negated
  (check (~= (/ (aref g 0) 3) 453f0 1e-3))
  (check (~= (aref g 3) -0.36712 1e-4))
  ;; the stance ring: R = 6.2u = 6.2 x .0236 x 453 = 66.28 CSS px around 爆 (381.43, 697.08): 304 deg up-left, 270 left, 202 below
  (lhud-seal-ring! g 381.43f0 697.08f0 66.285f0 nil)
  (check (~= (aref g 0) (- 381.43 (* 66.285 (sin (* 56 (/ pi 180))))) 0.01))    ; sin 304 = -sin 56
  (check (~= (aref g 1) (- 697.08 (* 66.285 (cos (* 56 (/ pi 180))))) 0.01))
  (check (~= (aref g 2) (- 381.43 66.285) 0.01))
  (check (~= (aref g 3) 697.08 0.01))
  (check (equal (> (aref g 7) 697.08) t))                                           ; 202 deg: below the middle
  (lhud-seal-ring! g 381.43f0 697.08f0 66.285f0 t)
  (check (~= (aref g 2) (+ 381.43 66.285) 0.01))                                 ; mirrored: 270 -> 90, to the right
  (check (~= (lhud-deck-bottom 823f0 630 t) 518.49 0.01))
  (check (~= (lhud-deck-bottom 823f0 630 nil) (* 0.96 823) 0.01)))

;; the BLUE burst's burning span inside the flash step's cells (DUEL_DESIGN "BLUE burns one cell"): LO = gauge - burn left, in cells
(check (~= (lhud-cell-burn 2f0 2 1f0) 0f0 1e-5))      ; 300 burning 100: the third cell, all of it
(check (~= (lhud-cell-burn 2f0 1 1f0) 1f0 1e-5))      ; the second cell is not (span empty: start = fill)
(check (~= (lhud-cell-burn 1.3f0 1 1f0) 0.3f0 1e-5))  ; 230 burning 100: 130..230 = the second cell from .3 ...
(check (~= (lhud-cell-burn 1.3f0 2 0.766667f0) 0f0 1e-5)) ; ... and the third (fill .77) from 0
(check (~= (lhud-cell-burn 1.3f0 0 1f0) 1f0 1e-5))
(check (~= (lhud-cell-burn 2.5f0 2 0.4f0) 0.4f0 1e-5)) ; burn 0 (lo = gauge): nothing

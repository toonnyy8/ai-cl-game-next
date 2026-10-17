;;;; hisagi-art.lisp — HISAGI SHUHEI as art data, the functional batch B2a (docs/duel/DUEL_HISAGI.md §11; the motion style,
;;;; §11.2, is a later batch): his body (TYBW: the sleeveless shihakusho, the white sash, a choker and two armbands, the
;;;; lieutenant's badge on the left arm, short messy black hair, three scars down over the right eye, the 69 and the blue
;;;; stripe on the left cheek), Kazeshini (a spiked rod with two scythe blades, one inverted, on a short hand chain: the
;;;; right hand's is the held weapon, the left hand's the thrown one, drawn by HISAGI-DRAW), one clip per move at the move's
;;;; frames, the chain and the sickle's flight (drawn to the sim's points: the thrown sickle's tip at the hit volume's end,
;;;; *HS-STRIKE-REACH*; the pulls' chain along HS-CHAIN-SEG's segment), the windmill, the lightning, the HUD's sickle icon,
;;;; his glyphs' name and a placeholder Kikon cinematic (the storyboard's, §11.5, is a later batch).
(in-package :duel)
(declaim (special *p1* *p2*))

;;; ---------------------------------------------------------------- body
;; 1.81 m (scale 1.0), lean (width 0.94); the hurt cylinder r 0.36 / h 1.8 (§8.1). One black mass (the sleeveless top, the
;; hakama), the white under-collar and sash; bare arms with black bands above the elbows; the face's marks are flat
;; shapes on the skin (the scars a dark line each, the 69 two ink glyph strokes, the stripe a muted blue bar)
(defbody :hisagi (:scale 1.0 :width 0.94 :hunch 0 :hurt-r 0.36 :hurt-h 1.8
                  :girth ((:head 1.16 1.16 1.16))
                  :palette ((:skin #xD6B49A) (:black #x16161E) (:hair #x141418) (:white #xECECE8) (:eye #xF2F0EC)
                            (:pupil #x3A3A40) (:lid #x141016) (:mouth #x7A3A3C) (:scar #x6A3A36) (:mark #x101014)
                            (:stripe #x34507E) (:band #x0E0E12) (:sash #xE8E6DE) (:badge #xE0DED6) (:tabi #xE8E8E4)
                            (:sole #x262833) (:fold #x3A3A46) (:brow #x1A1418))
                  :rim (#xFFD8B8 0.14))
  (:pelvis (:box 0.35 0.18 0.24 :c :black)
           (:box 0.36 0.05 0.25 :at (0 0.075 0) :c :sash)                                        ; the white sash
           (:cyl 0.22 0.48 :top 0.165 :seg 8 :at (0 -0.22 0) :c :black)                          ; the hakama
           (:box 0.004 0.34 0.004 :at (0.06 -0.26 0.19) :rot (0 0 -4) :c :fold))
  (:spine (:bevel 0.34 0.25 0.23 0.04 :at (0 0.11 0) :c :black))
  (:chest (:bevel 0.42 0.3 0.26 0.05 :at (0 0.11 0) :c :black)
          (:box 0.016 0.18 0.01 :at (0.032 0.185 0.135) :rot (0 0 -24) :c :white)                ; the white under-collar V
          (:box 0.016 0.18 0.01 :at (-0.032 0.185 0.135) :rot (0 0 24) :c :white)
          (:box 0.05 0.12 0.012 :at (0 0.19 0.133) :c :skin)
          (:box 0.005 0.17 0.004 :at (0.08 0.07 0.137) :rot (0 0 -10) :c :fold))
  (:neck (:cyl 0.04 0.17 :at (0 0.06 0) :c :skin)
         (:cyl 0.046 0.03 :seg 10 :at (0 0.07 0) :c :band))                                       ; the choker
  (:head (:sphere 0.066 :stretch 0.02 :at (0 0.14 -0.012) :seg 12 :c :skin)
         (:bevel 0.104 0.074 0.078 0.02 :at (0 0.126 0.022) :c :skin)
         (:bevel 0.05 0.074 0.066 0.014 :at (0.022 0.078 0.022) :rot (0 0 -20) :c :skin)
         (:bevel 0.05 0.074 0.066 0.014 :at (-0.022 0.078 0.022) :rot (0 0 20) :c :skin)
         (:wedge 0.012 0.022 0.013 :at (0 0.1 0.064) :rot (180 0 0) :c :skin)
         (:box 0.024 0.012 0.003 :at (0.027 0.12 0.0615) :c :eye) (:box 0.024 0.012 0.003 :at (-0.027 0.12 0.0615) :c :eye)
         (:box 0.01 0.012 0.003 :at (0.026 0.12 0.0622) :c :pupil) (:box 0.01 0.012 0.003 :at (-0.026 0.12 0.0622) :c :pupil)
         (:box 0.03 0.006 0.004 :at (0.027 0.131 0.0618) :rot (0 0 -6) :c :brow)
         (:box 0.03 0.006 0.004 :at (-0.027 0.131 0.0618) :rot (0 0 6) :c :brow)
         (:box 0.022 0.004 0.003 :at (0 0.083 0.064) :c :mouth)
         ;; the three scars down over his right eye (+x), from the brow to the cheek
         (:box 0.003 0.07 0.003 :at (0.018 0.115 0.0645) :rot (0 0 -6) :c :scar)
         (:box 0.003 0.075 0.003 :at (0.027 0.113 0.0645) :rot (0 0 -6) :c :scar)
         (:box 0.003 0.07 0.003 :at (0.036 0.111 0.064) :rot (0 0 -6) :c :scar)
         ;; the 69 on the left cheek, under the blue stripe across the cheek and the bridge of the nose
         (:box 0.006 0.016 0.003 :at (-0.042 0.092 0.061) :c :mark) (:box 0.008 0.006 0.003 :at (-0.039 0.087 0.061) :c :mark)
         (:box 0.006 0.016 0.003 :at (-0.03 0.094 0.061) :c :mark) (:box 0.008 0.006 0.003 :at (-0.033 0.099 0.061) :c :mark)
         (:box 0.066 0.007 0.003 :at (-0.022 0.106 0.0625) :c :stripe)
         ;; the hair: short and messy, black, the fringe down to the brows, tufts over the ears
         (:sphere 0.072 :stretch 0.01 :at (0 0.158 -0.016) :seg 10 :c :hair)
         (:cone 0.03 0.09 :at (0.05 0.17 -0.04) :rot (0 30 -70) :seg 4 :c :hair)
         (:cone 0.03 0.09 :at (-0.05 0.17 -0.04) :rot (0 30 70) :seg 4 :c :hair)
         (:cone 0.03 0.09 :at (0 0.19 -0.06) :rot (0 80 0) :seg 4 :c :hair)
         (:cone 0.026 0.08 :at (0.035 0.135 -0.07) :rot (0 100 -30) :seg 4 :c :hair)
         (:cone 0.026 0.08 :at (-0.035 0.135 -0.07) :rot (0 100 30) :seg 4 :c :hair)
         (:cone 0.022 0.07 :at (0.03 0.168 0.05) :rot (0 196 12) :seg 4 :c :hair)                 ; the fringe
         (:cone 0.022 0.075 :at (-0.016 0.17 0.054) :rot (0 196 -8) :seg 4 :c :hair)
         (:cone 0.02 0.06 :at (0.006 0.162 0.058) :rot (0 190 2) :seg 4 :c :hair)
         (:cone 0.024 0.06 :at (0.07 0.12 0.0) :rot (0 0 -160) :seg 4 :c :hair)                   ; over the ears
         (:cone 0.024 0.06 :at (-0.07 0.12 0.0) :rot (0 0 160) :seg 4 :c :hair))
  (:shoulder-r (:bevel 0.1 0.05 0.16 0.02 :at (0.02 -0.01 0) :rot (0 0 -20) :c :black))            ; (sleeveless: the top's edge)
  (:shoulder-l (:bevel 0.1 0.05 0.16 0.02 :at (-0.02 -0.01 0) :rot (0 0 20) :c :black))
  (:upper-arm-r (:box 0.085 0.3 0.09 :at (0 -0.15 0) :c :skin)
                (:box 0.095 0.04 0.1 :at (0 -0.2 0) :c :band))                                    ; the armband
  (:upper-arm-l (:box 0.085 0.3 0.09 :at (0 -0.15 0) :c :skin)
                (:box 0.095 0.04 0.1 :at (0 -0.2 0) :c :band)
                (:box 0.006 0.07 0.05 :at (-0.047 -0.09 0) :c :badge))                            ; the lieutenant's badge
  (:lower-arm-r (:box 0.075 0.25 0.075 :at (0 -0.125 0) :c :skin))
  (:lower-arm-l (:box 0.075 0.25 0.075 :at (0 -0.125 0) :c :skin))
  (:hand-r (:bevel 0.06 0.08 0.06 0.016 :at (0 -0.04 0) :c :skin))
  (:hand-l (:bevel 0.06 0.08 0.06 0.016 :at (0 -0.04 0) :c :skin))
  (:thigh-r (:cyl 0.11 0.44 :top 0.1 :seg 10 :at (0 -0.21 0) :c :black))
  (:thigh-l (:cyl 0.11 0.44 :top 0.1 :seg 10 :at (0 -0.21 0) :c :black))
  (:shin-r (:cyl 0.12 0.3 :top 0.105 :seg 10 :at (0 -0.1 0) :c :black) (:box 0.075 0.12 0.085 :at (0 -0.37 0) :c :tabi))
  (:shin-l (:cyl 0.12 0.3 :top 0.105 :seg 10 :at (0 -0.1 0) :c :black) (:box 0.075 0.12 0.085 :at (0 -0.37 0) :c :tabi))
  (:foot-r (:bevel 0.085 0.055 0.21 0.02 :at (0 -0.02 0.05) :c :tabi) (:box 0.095 0.02 0.23 :at (0 -0.05 0.05) :c :sole))
  (:foot-l (:bevel 0.085 0.055 0.21 0.02 :at (0 -0.02 0.05) :c :tabi) (:box 0.095 0.02 0.23 :at (0 -0.05 0.05) :c :sole)))

;;; ---------------------------------------------------------------- Kazeshini
;; One sickle (the right hand's held weapon; the left hand's drawn by HISAGI-DRAW with the same mesh): 0.75 m from the fist
;; to the far blade's point: two links of the short hand chain (y 0-0.18), the spiked rod (y 0.18-0.62), the scythe blade
;; at its top curving toward the edge side (+Z) up to the point (y 0.75), the inverted one lower curving back (-Z)
(defweapon :kazeshini (:length 0.75 :base 0.2)
  (:solid (mbc mb #x2A2A30)                                                                ; the chain links
          (with-xform (mb (xform :y 0.045)) (mb-box mb 0.012 0.07 0.035))
          (with-xform (mb (xform :y 0.12 :yaw 1.57)) (mb-box mb 0.012 0.07 0.035))
          (mbc mb #x121216)                                                                ; the rod and its spikes
          (with-xform (mb (xform :y 0.4)) (mb-box mb 0.03 0.44 0.03))
          (loop for y in '(0.26 0.36 0.46 0.56)
                do (with-xform (mb (xform :y y :x 0.022 :roll -0.6)) (mb-box mb 0.012 0.04 0.012))
                   (with-xform (mb (xform :y y :x -0.022 :roll 0.6)) (mb-box mb 0.012 0.04 0.012)))
          (mbc mb #x18181C)                                                                ; the top blade (+Z), to the point
          (with-xform (mb (xform :y 0.62 :z 0.05 :pitch 0.5)) (mb-box mb 0.01 0.05 0.11))
          (with-xform (mb (xform :y 0.69 :z 0.09 :pitch 1.1)) (mb-box mb 0.01 0.04 0.1))
          (with-xform (mb (xform :y 0.735 :z 0.06 :pitch 1.9)) (mb-box mb 0.01 0.035 0.06))
          (with-xform (mb (xform :y 0.3 :z -0.05 :pitch -2.6)) (mb-box mb 0.01 0.05 0.11))    ; the inverted blade (-Z)
          (with-xform (mb (xform :y 0.24 :z -0.09 :pitch -2.0)) (mb-box mb 0.01 0.04 0.09))
          (mbc mb #xC8CCD4)                                                                ; the white edges
          (with-xform (mb (xform :y 0.64 :z 0.1 :pitch 0.5)) (mb-box mb 0.012 0.012 0.1))
          (with-xform (mb (xform :y 0.28 :z -0.1 :pitch -2.6)) (mb-box mb 0.012 0.012 0.1))))

(defparameter *hs-strike-reach* '((:hs-nage :sickle 6.3) (:hs-maki :sickle 3.55) (:hs-kari :sickle 2.8))
  "Clip -> what strikes, and its drawn reach (m, the hit volume's far edge: line end + radius, or the arc's): the left
sickle thrown on its chain, drawn by HISAGI-DRAW with its point there on the hit frames (*HS-FLIGHTS*); the host FK test
reads these (as Senjumaru's *SJ-STRIKE-REACH*).")
(defparameter *hs-flights* '((:hs-k1 6.3 t) (:hs-k2s 3.55 t) (:hs-k3 2.8 nil) (:hs-shibari 4.85 nil) (:hs-raiden 6.8 nil)
                             (:hs-kikon 8.0 nil))
  "Move -> how far the left sickle's point flies out on its hit frames (m: the volume's far edge, as *HS-STRIKE-REACH*) and
whether it stays out (a throw: then at the anchor).")

;;; ---------------------------------------------------------------- poses (his rig notes)
;;; The right hand's sickle is the J's: a horizontal cut is the arm held out (side ~88) swept by its flex (0 = to his
;;; right, 60 = ahead-right, 90 = ahead, 120 = ahead-left) with the hand at flex -90, the rod on the arm's line (tip
;;; 1.54 / 1.45 / 1.35 / 1.23 m out: the J volumes' 1.4 within 0.15). The left hand throws (its sickle drawn by the look).
(defpose :hs-stance ()                                 ; upright, the arms loose and wide, the sickles low, the chain slack
  (:root :u -0.03) (:pelvis :twist -10) (:spine :flex 4) (:chest :twist -4) (:neck :twist 8) (:head :flex 2)
  (:arm-r :flex 22 :side 22 :twist 4) (:elbow-r :flex 36) (:hand-r :flex -40)
  (:arm-l :flex 14 :side 26 :twist -6) (:elbow-l :flex 30) (:hand-l :flex -30)
  (:thigh-l :flex 18 :side 8) (:knee-l :flex 20) (:thigh-r :flex -10 :side 10) (:knee-r :flex 16))
(defclip :hs-stance (2.0 :loop t :base :hs-stance)
  (0) (1.0 (:root :u -0.045) (:chest :flex 3) (:elbow-l :flex 34) (:hand-r :flex -46)))

;; J1 旋 SEN: wound to his right, one flat whirl right to left at chest height, a short step (the move's slide)
(defpose :hs-q1-hit (:base :hs-stance)
  (:root :f 0.06 :u -0.08 :yaw 4) (:chest :twist 6) (:spine :flex 8)
  (:arm-r :flex 60 :side 88 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90 :twist 0)
  (:arm-l :flex 10 :side 40) (:elbow-l :flex 40)
  (:thigh-r :flex 30) (:knee-r :flex 30) (:thigh-l :flex -14) (:knee-l :flex 14))
(defstrike :hs-q1 (8 3 12 :base :hs-stance)
  (0)
  (4 (:root :u -0.06 :yaw 18) (:chest :twist 26) (:arm-r :flex -10 :side 88) (:elbow-r :flex 10) (:hand-r :flex -90)
     (:arm-l :flex 20 :side 30) (:elbow-l :flex 50))
  (:s :snap :hs-q1-hit)
  (:a (:root :yaw -8) (:chest :twist -14) (:arm-r :flex 112 :side 86))
  (17 (:root :u -0.05 :yaw -4) (:chest :twist -8) (:arm-r :flex 70 :side 40) (:elbow-r :flex 40) (:hand-r :flex -60))
  (:end :hs-stance))

;; J2 返旋 KAESHI-SEN: the wrist turned at his left, the return whirl rising across to his right
(defpose :hs-q2-hit (:base :hs-stance)
  (:root :f 0.06 :u -0.06 :yaw -6) (:chest :twist -20) (:spine :flex 6)
  (:arm-r :flex 80 :side 60 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90 :twist 0)
  (:thigh-l :flex 26) (:knee-l :flex 28) (:thigh-r :flex -12) (:knee-r :flex 14))
(defstrike :hs-q2 (8 3 13 :base :hs-stance)
  (0 :hs-q1-hit (:arm-r :flex 112 :side 86) (:chest :twist -14))
  (4 (:root :u -0.08 :yaw 10) (:chest :twist 24) (:arm-r :flex 130 :side 60) (:elbow-r :flex 20) (:hand-r :flex -80))
  (:s :snap :hs-q2-hit)
  (:a (:chest :twist -30) (:arm-r :flex 30 :side 95) (:hand-r :flex -85))
  (18 (:root :u -0.05) (:chest :twist -10) (:arm-r :flex 30 :side 40) (:elbow-r :flex 40) (:hand-r :flex -60))
  (:end :hs-stance))

;; J3 輪 RIN: a full turn to his right (a key every 90°), the arm out flat, the sickle whirled all the way round (200°)
(defpose :hs-spin-hit (:base :hs-stance)
  (:root :yaw -360 :u -0.06) (:pelvis :twist 6) (:chest :twist -4)
  (:arm-r :flex 40 :side 88 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90 :twist 0)
  (:arm-l :flex 10 :side 60) (:elbow-l :flex 20)
  (:thigh-l :flex 20 :side 8) (:knee-l :flex 24) (:thigh-r :flex 10 :side 14) (:knee-r :flex 26))
(defstrike :hs-spin (9 3 18 :base :hs-stance)
  (0)
  (2 (:root :u -0.1 :yaw 24) (:chest :twist 20) (:knees :flex 32) (:arm-r :flex 20 :side 70) (:hand-r :flex -80))   ; wound
  (4 (:root :u -0.09 :yaw -60) (:pelvis :side 6) (:arm-r :flex 40 :side 88) (:hand-r :flex -90))
  (6 (:root :u -0.08 :yaw -150) (:pelvis :side 8))
  (8 (:root :u -0.07 :yaw -250) (:pelvis :side 4))
  (:s :snap :hs-spin-hit)
  (:a (:root :yaw -390) (:chest :twist -10))
  (22 (:root :yaw -376 :u -0.06) (:chest :twist -4) (:arm-r :flex 50 :side 40) (:elbow-r :flex 40) (:hand-r :flex -60))
  (:end :hs-stance (:root :yaw -360)))

;; K1 投 NAGE: the left sickle whirled overhead (held: the tell), the throw from the shoulder, the body thrown after it
(defpose :hs-nage-hit (:base :hs-stance)
  (:root :f 0.18 :u -0.12 :yaw -10) (:spine :flex 14) (:chest :twist -18)
  (:arm-l :flex 88 :side 6 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -10)
  (:arm-r :flex -20 :side 30) (:elbow-r :flex 40) (:hand-r :flex -40)
  (:thigh-l :flex 44) (:knee-l :flex 44) (:thigh-r :flex -24) (:knee-r :flex 14))
(defstrike :hs-nage (18 4 22 :base :hs-stance)
  (0)
  (4 (:root :u -0.04) (:chest :twist 10) (:arm-l :flex 160 :side 20 :twist 40) (:elbow-l :flex 30))       ; overhead
  (8 (:arm-l :flex 168 :side -10 :twist -40) (:elbow-l :flex 20))
  (12 (:arm-l :flex 160 :side 20 :twist 40) (:elbow-l :flex 30))
  (15 (:root :u -0.06 :yaw 14) (:chest :twist 24) (:arm-l :flex 150 :side 30) (:elbow-l :flex 50) (:spine :flex -4))   ; cocked
  (:s :snap :hs-nage-hit)
  (:a (:root :f 0.22) (:arm-l :flex 84))
  (34 (:root :f 0.1 :u -0.06) (:spine :flex 8) (:chest :twist -8) (:arm-l :flex 50 :side 20) (:elbow-l :flex 30))
  (:end :hs-stance))

;; K2 引 HIKI: dropped low, the chain hauled back past his hip with the left hand: the sickle comes in from behind him
(defpose :hs-hiki-hit (:base :hs-stance)
  (:root :f -0.1 :u -0.22 :yaw 12) (:spine :flex 20) (:chest :twist 20)
  (:arm-l :flex -40 :side 30) (:elbow-l :flex 30) (:hand-l :flex 20)
  (:arm-r :flex 60 :side 30) (:elbow-r :flex 30) (:hand-r :flex -60)
  (:thigh-l :flex 60 :side 10) (:knee-l :flex 70) (:thigh-r :flex 10 :side 14) (:knee-r :flex 60))
(defstrike :hs-hiki (20 4 24 :base :hs-stance)
  (0 :hs-nage-hit)
  (6 :hs-nage-hit (:arm-l :flex 80))
  (14 (:root :u -0.16) (:spine :flex 16) (:arm-l :flex 70 :side 10) (:elbow-l :flex 10) (:knees :flex 50))   ; the hand set
  (:s :snap :hs-hiki-hit)
  (:a (:arm-l :flex -50) (:chest :twist 26))
  (38 (:root :u -0.08) (:spine :flex 8) (:chest :twist 6) (:arm-l :flex 10 :side 30) (:elbow-l :flex 30) (:knees :flex 24))
  (:end :hs-stance))

;; K2s 巻 MAKI: the left arm flung round flat, the chain wrapped round him at 3.2 m
(defpose :hs-maki-hit (:base :hs-stance)
  (:root :f 0.08 :u -0.08 :yaw -20) (:chest :twist -26) (:spine :flex 6)
  (:arm-l :flex 70 :side 88 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -30)
  (:arm-r :flex 20 :side 50) (:elbow-r :flex 50)
  (:thigh-r :flex 30) (:knee-r :flex 32) (:thigh-l :flex -16) (:knee-l :flex 14))
(defstrike :hs-maki (20 4 24 :base :hs-stance)
  (0 :hs-q1-hit)
  (6 :hs-q1-hit)
  (12 (:root :yaw 20) (:chest :twist 30) (:arm-l :flex -20 :side 88) (:elbow-l :flex 10))            ; wound to his left
  (17 (:root :yaw 10) (:chest :twist 20) (:arm-l :flex 20 :side 88))
  (:s :snap :hs-maki-hit)
  (:a (:root :yaw -30) (:chest :twist -34) (:arm-l :flex 110 :side 80))
  (36 (:root :u -0.05 :yaw -10) (:chest :twist -10) (:arm-l :flex 30 :side 30) (:elbow-l :flex 30))
  (:end :hs-stance))

;; K3 刈落 KARI-OTOSHI: the left sickle swung up over his head on its chain and brought down onto him (2.8 m), both
;; arms following through low
(defpose :hs-kari-hit (:base :hs-stance)
  (:root :f 0.16 :u -0.2) (:spine :flex 26) (:chest :twist -6)
  (:arm-l :flex 70 :side 10) (:elbow-l :flex 0) (:hand-l :flex -20)
  (:arm-r :flex 50 :side 20) (:elbow-r :flex 20) (:hand-r :flex -50)
  (:thigh-l :flex 50) (:knee-l :flex 54) (:thigh-r :flex -20) (:knee-r :flex 30))
(defstrike :hs-kari (22 5 34 :base :hs-stance)
  (0 :hs-hiki-hit)
  (8 :hs-hiki-hit)
  (14 (:root :u -0.02) (:spine :flex -10) (:chest :twist 0) (:arm-l :flex 175 :side 10) (:elbow-l :flex 10)
      (:arm-r :flex 150 :side 10) (:elbow-r :flex 30) (:knees :flex 10))                               ; overhead
  (19 (:spine :flex -14) (:arm-l :flex 178 :side -6))
  (:s :snap :hs-kari-hit)
  (:a (:root :u -0.22) (:spine :flex 30))
  (46 (:root :f 0.06 :u -0.1) (:spine :flex 10) (:arm-l :flex 30 :side 20) (:elbow-l :flex 30) (:arm-r :flex 30 :side 20))
  (:end :hs-stance))

;; K3 解 HODOKI: a full turn the other way unwinding the chain off him, the left hand hauling it in: the hit from behind
(defpose :hs-hodoki-hit (:base :hs-stance)
  (:root :yaw 360 :u -0.14) (:spine :flex 14) (:chest :twist 16)
  (:arm-l :flex -30 :side 40) (:elbow-l :flex 40) (:hand-l :flex 20)
  (:arm-r :flex 40 :side 40) (:elbow-r :flex 30)
  (:thigh-l :flex 40) (:knee-l :flex 50) (:thigh-r :flex 0) (:knee-r :flex 40))
(defstrike :hs-hodoki (22 5 34 :base :hs-stance)
  (0 :hs-maki-hit)
  (8 :hs-maki-hit)
  (12 (:root :yaw 60 :u -0.1) (:chest :twist -10))
  (15 (:root :yaw 150) (:arm-l :flex 60 :side 70))
  (18 (:root :yaw 240) (:arm-l :flex 40 :side 60))
  (20 (:root :yaw 310))
  (:s :snap :hs-hodoki-hit)
  (:a (:root :yaw 380) (:arm-l :flex -45))
  (46 (:root :yaw 366 :u -0.06) (:spine :flex 6) (:arm-l :flex 10 :side 30) (:elbow-l :flex 30))
  (:end :hs-stance (:root :yaw 360)))

;; 戻 MODOSHI: the chain hauled in hand over hand, the sickle caught in the left fist
(defstrike :hs-modoshi (6 0 6 :base :hs-stance)
  (0 (:arm-l :flex 60 :side 10) (:elbow-l :flex 10))
  (3 (:arm-l :flex 20 :side 20) (:elbow-l :flex 70) (:arm-r :flex 40 :side 10) (:elbow-r :flex 60))
  (:s :snap (:arm-l :flex 0 :side 30) (:elbow-l :flex 60) (:hand-l :flex -20))
  (:end :hs-stance))

;; L 風車 KAZAGURUMA: the left arm up, the chain whirled overhead (HISAGI-DRAW draws the circle), the right sickle at
;; the guard; held, then lowered
(defpose :hs-kaza-up (:base :hs-stance)
  (:root :u -0.1) (:spine :flex 2) (:arm-l :flex 168 :side 8 :twist 30) (:elbow-l :flex 14) (:hand-l :flex -20)
  (:arm-r :flex 60 :side 10) (:elbow-r :flex 70) (:hand-r :flex -50)
  (:thighs :flex 22 :side 10) (:knees :flex 28))
(defstrike :hs-kaza (6 60 14 :base :hs-stance)
  (0)
  (:s :snap :hs-kaza-up)
  (36 :hs-kaza-up (:root :u -0.11) (:arm-l :twist -20))
  (:a :hs-kaza-up)
  (:end :hs-stance))

;; Shift+K 綴雷電 TSUZURI RAIDEN: the left sickle sent out on its chain, the lightning run down it (the look), the right
;; hand's two fingers raised (the kido)
(defpose :hs-raiden-hit (:base :hs-stance)
  (:root :f 0.1 :u -0.1) (:spine :flex 8) (:chest :twist -14)
  (:arm-l :flex 90 :side 4) (:elbow-l :flex 0) (:hand-l :flex 0)
  (:arm-r :flex 100 :side 20) (:elbow-r :flex 110) (:hand-r :flex -20)
  (:thigh-l :flex 36) (:knee-l :flex 38) (:thigh-r :flex -18) (:knee-r :flex 16))
(defstrike :hs-raiden (20 3 24 :base :hs-stance)
  (0)
  (8 (:root :u -0.06) (:arm-r :flex 120 :side 10) (:elbow-r :flex 120) (:arm-l :flex 30 :side 40) (:elbow-l :flex 60))
  (16 (:root :yaw 12) (:chest :twist 16) (:arm-l :flex 140 :side 30) (:elbow-l :flex 40))
  (:s :snap :hs-raiden-hit)
  (:a :hs-raiden-hit (:root :f 0.12))
  (36 (:root :u -0.05) (:arm-l :flex 40 :side 20) (:elbow-l :flex 30) (:arm-r :flex 40 :side 20) (:elbow-r :flex 50))
  (:end :hs-stance))

;; Shift+L 縛 SHIBARI: the chain thrown round his whole body (f16), hauled tight overhead, the slam down (f46)
(defpose :hs-shibari-throw (:base :hs-stance)
  (:root :f 0.12 :u -0.1) (:spine :flex 10) (:chest :twist -16)
  (:arm-l :flex 86 :side 20) (:elbow-l :flex 0) (:arm-r :flex 30 :side 30) (:elbow-r :flex 40)
  (:thigh-l :flex 40) (:knee-l :flex 40) (:thigh-r :flex -20) (:knee-r :flex 16))
(defpose :hs-shibari-haul (:base :hs-stance)
  (:root :f -0.05 :u -0.04) (:spine :flex -12) (:chest :twist 10)
  (:arm-l :flex 170 :side 10) (:elbow-l :flex 30) (:arm-r :flex 160 :side 10) (:elbow-r :flex 40)
  (:thigh-l :flex 10) (:knee-l :flex 12))
(defpose :hs-shibari-slam (:base :hs-stance)
  (:root :f 0.1 :u -0.3) (:spine :flex 34)
  (:arm-l :flex 40 :side 10) (:elbow-l :flex 0) (:arm-r :flex 40 :side 10) (:elbow-r :flex 10)
  (:thigh-l :flex 66) (:knee-l :flex 80) (:thigh-r :flex 0) (:knee-r :flex 66))
(defstrike :hs-shibari (16 34 26 :base :hs-stance)
  (0)
  (10 (:root :yaw 16) (:chest :twist 22) (:arm-l :flex 150 :side 40) (:elbow-l :flex 40))
  (:s :snap :hs-shibari-throw)
  (24 :hs-shibari-throw)
  (36 :hs-shibari-haul)
  (44 :hs-shibari-haul (:spine :flex -16))
  (46 :snap :hs-shibari-slam)
  (:a :hs-shibari-slam)
  (64 (:root :u -0.12) (:spine :flex 14) (:arm-l :flex 30 :side 20) (:arm-r :flex 30 :side 20))
  (:end :hs-stance))

;; I: the Breaker's dash (low, the chain trailing) and 首掛け KUBIKAKE: the chain hooked round his neck from the left, the
;; right sickle driven in low
(defclip :hs-breaker (0.4 :loop t :base :hs-stance)
  (0 (:root :u -0.16) (:spine :flex 26) (:arm-l :flex -40 :side 30) (:arm-r :flex -30 :side 30) (:knees :flex 40))
  (0.2 (:root :u -0.13) (:spine :flex 24) (:arm-l :flex -30 :side 34) (:arm-r :flex -40 :side 26) (:knees :flex 44)))
(defpose :hs-kubikake-hit (:base :hs-stance)
  (:root :f 0.12 :u -0.12 :yaw -14) (:spine :flex 14) (:chest :twist -20)
  (:arm-l :flex 100 :side 70) (:elbow-l :flex 60) (:hand-l :flex -20)
  (:arm-r :flex 60 :side 10) (:elbow-r :flex 20) (:hand-r :flex -50)
  (:thigh-l :flex 40) (:knee-l :flex 44) (:thigh-r :flex -20) (:knee-r :flex 16))
(defstrike :hs-kubikake (8 4 18 :base :hs-stance)
  (0 (:root :u -0.14) (:spine :flex 22) (:arm-l :flex 40 :side 60) (:arm-r :flex 10 :side 30))
  (5 (:root :yaw 10) (:chest :twist 16) (:arm-l :flex 140 :side 70) (:elbow-l :flex 40))
  (:s :snap :hs-kubikake-hit)
  (:a (:arm-l :flex 60 :side 40) (:elbow-l :flex 90) (:chest :twist -26))   ; the yank
  (22 (:root :u -0.08) (:spine :flex 10) (:chest :twist -8) (:arm-l :flex 20 :side 30) (:elbow-l :flex 40))
  (:end :hs-stance))

;; O 刈 KARI: the aim (the aura: the sickle swung at his side) and the strike: the sickle sent down the lane (7 m)
(defclip :hs-kari-aim (0.5 :loop t :base :hs-stance)
  (0 (:root :u -0.08) (:chest :twist 14) (:arm-l :flex 40 :side 70 :twist 30) (:elbow-l :flex 20))
  (0.25 (:root :u -0.09) (:chest :twist 16) (:arm-l :flex 60 :side 74 :twist -30) (:elbow-l :flex 10)))
(defstrike :hs-kari-o (20 2 30 :base :hs-stance)
  (0 (:root :u -0.08) (:chest :twist 14) (:arm-l :flex 40 :side 70) (:elbow-l :flex 20))
  (14 (:root :yaw 16) (:chest :twist 26) (:arm-l :flex 150 :side 30) (:elbow-l :flex 40))
  (:s :snap :hs-nage-hit)
  (:a :hs-nage-hit (:root :f 0.24))
  (36 (:root :u -0.06) (:spine :flex 8) (:arm-l :flex 50 :side 20) (:elbow-l :flex 30))
  (:end :hs-stance))

;; intro: the right sickle drawn up across his face (canon Ep219: 「怖いか？」), held, then lowered; win: the half-step back
(defclip :hs-intro (2.0 :base :hs-stance)
  (0)
  (0.4 (:arm-r :flex 130 :side -20 :twist 0) (:elbow-r :flex 110) (:hand-r :flex -10) (:head :flex 6))
  (1.4 (:arm-r :flex 132 :side -22) (:elbow-r :flex 112) (:head :flex 8))
  (2.0 :hs-stance))
(defclip :hs-win (2.0 :base :hs-stance)
  (0)
  (0.5 (:root :f -0.18 :u -0.02) (:thigh-r :flex -24) (:thigh-l :flex 10) (:arm-r :flex 10 :side 10) (:elbow-r :flex 20)
       (:arm-l :flex 6 :side 12) (:elbow-l :flex 16) (:head :flex 10))
  (2.0 (:root :f -0.2) (:thigh-r :flex -22) (:arm-r :flex 8) (:head :flex 12)))

;;; ---------------------------------------------------------------- looks (cosmetic; the sim's points, 0 B a frame)
;; (every float crosses a call through these f32vecs: a float argument boxes; 0 B a frame, debug 83901)
(declaim (type f32vec *hs-v* *hs-w* *hs-q* *hs-a* *hs-m* *hs-m2*))
(defvar *hs-v* (make-f32 3) "The left sickle's grip (world).")
(defvar *hs-w* (make-f32 3) "A chain end (world).")
(defvar *hs-q* (make-f32 3) "A point (world).")
(defvar *hs-a* (make-f32 4) "HISAGI-DRAW's floats: [0] his facing yaw, [1] the flight's reach (m), [2] scratch.")
(defvar *hs-m* (m4) "The left sickle's world matrix.")
(defvar *hs-m2* (m4) "A joint's matrix (scratch).")

(defun-fast vfx-hs-chain (a b sag k)
  "Kazeshini's chain from point A to point B (f32vecs), sagging SAG m at its middle: ink links turned alternately, a steel
glint every other one, presence K (SAG and K: literals)."
  (declare (type f32vec a b) (single-float sag k))
  (let* ((x0 (aref a 0)) (y0 (aref a 1)) (z0 (aref a 2)) (dx (- (aref b 0) x0)) (dy (- (aref b 1) y0)) (dz (- (aref b 2) z0))
         (l (f-max 0.01f0 (f-hypot dx dy dz))) (ux (/ dx l)) (uy (/ dy l)) (uz (/ dz l))
         (n (min 48 (max 2 (f->i (/ l 0.12f0))))) (dr (drawing-no)))
    (declare (single-float x0 y0 z0 dx dy dz l ux uy uz dr) (fixnum n))
    (dotimes (i n)
      (let* ((u (/ (+ 0.5f0 (i->f i)) (i->f n))) (s (* 4f0 sag u (- 1f0 u)))
             (px (+ x0 (* u dx))) (py (- (+ y0 (* u dy)) s)) (pz (+ z0 (* u dz))))
        (declare (single-float u s px py pz))
        (fx-shard px py pz ux uy uz 0.13f0 (if (evenp i) 0.04f0 0.018f0) 0.03f0 (+ (i->f i) 700f0 dr) +pal-ink+ k)
        (when (evenp i) (fx-shard px py pz ux uy uz 0.06f0 0.01f0 0.03f0 (+ (i->f i) 760f0) +pal-steel+ k :push 0.14f0)))))
  nil)

(defun-fast %hs-point (out code jm pos fa anchor vpos)
  "OUT := one of the left sickle's points: CODE 0 the left fist (:weapon-l), 1 the thrown grip (FA[1] - the sickle's length
along his facing FA[0], 1.1 m up: its point at FA[1]), 2 the anchor (hooked: the victim's chest when he is within
*HS-HOOK-R* of it, else on the ground), 3 the windmill's circle (1.9 m round him, 1.7 m up, the fx clock), 4 the sim hand
(HS-HAND's point: the pulls' chain end)."
  (declare (type f32vec out jm pos fa anchor vpos) (fixnum code))
  (let* ((yaw (aref fa 0)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))))
    (declare (single-float yaw fx fz))
    (case code
      (0 (joint-point! out jm (ji :weapon-l) 0f0 0f0 0f0))
      (1 (let ((d (- (aref fa 1) 0.75f0)))
           (declare (single-float d))
           (setf (aref out 0) (+ (aref pos 0) (* d fx)) (aref out 1) 1.1f0 (aref out 2) (+ (aref pos 2) (* d fz)))))
      (2 (let* ((ax (aref anchor 0)) (az (aref anchor 1)) (hx (- (aref vpos 0) ax)) (hz (- (aref vpos 2) az))
                (hr (the single-float *hs-hook-r*)))
           (declare (single-float ax az hx hz hr))
           (if (< (+ (* hx hx) (* hz hz)) (* hr hr))
               (setf (aref out 0) (aref vpos 0) (aref out 1) (+ (aref vpos 1) 1.1f0) (aref out 2) (aref vpos 2))
               (setf (aref out 0) ax (aref out 1) 0.06f0 (aref out 2) az))))
      (3 (let ((a (* 12f0 (fx-clock))))
           (declare (single-float a))
           (setf (aref out 0) (+ (aref pos 0) (* 1.9f0 (f-sin a))) (aref out 1) 1.7f0 (aref out 2) (+ (aref pos 2) (* 1.9f0 (f-cos a))))))
      (t (setf (aref out 0) (+ (aref pos 0) (* (the single-float *hs-hand-ahead*) fx))
               (aref out 1) (+ (aref pos 1) (the single-float *hs-hand-up*))
               (aref out 2) (+ (aref pos 2) (* (the single-float *hs-hand-ahead*) fz))))))
  nil)

(defun-fast %hs-place! (m v fa spin)
  "M := the flying sickle's world matrix: its grip at V, turned to his facing FA[0], its blade pitched forward (SPIN 0)
or tumbling with the fx clock (SPIN 1). M4-EULER!'s layout, inline (its float arguments would box)."
  (declare (type f32vec m v fa) (fixnum spin))
  (let* ((yaw (aref fa 0)) (pitch (if (= spin 0) -1.5708f0 (* 9f0 (fx-clock))))
         (cy (f-cos yaw)) (sy (f-sin yaw)) (cp (f-cos pitch)) (sp (f-sin pitch)))
    (declare (single-float yaw pitch cy sy cp sp))
    (setf (aref m 0) cy (aref m 1) 0f0 (aref m 2) (- sy) (aref m 3) 0f0
          (aref m 4) (* sy sp) (aref m 5) cp (aref m 6) (* cy sp) (aref m 7) 0f0
          (aref m 8) (* sy cp) (aref m 9) (- sp) (aref m 10) (* cy cp) (aref m 11) 0f0
          (aref m 12) (aref v 0) (aref m 13) (aref v 1) (aref m 14) (aref v 2) (aref m 15) 1f0))
  nil)

(defun-fast %hs-draw (jm pos fa anchor vpos a b n d tint lightning)
  "The left sickle and the chain: in the left fist (A = B = 0: the chain slack between the fists), else at the point
between codes A and B at N / D (%HS-POINT), its point out along his facing, the chain to it from the right fist; the
pulls (B 4) draw the chain along HS-CHAIN-SEG's segment (anchor to the sim hand). LIGHTNING 1: TSUZURI RAIDEN's bolt along
his 6.5 m line."
  (declare (type f32vec jm pos fa anchor vpos) (fixnum a b n d lightning))
  (let ((v *hs-v*) (w *hs-w*) (q *hs-q*) (m *hs-m*) (m2 *hs-m2*))
    (declare (type f32vec v w q m m2))
    (joint-point! w jm (ji :weapon-r) 0f0 0f0 0f0)                    ; the right fist: the chain's end there
    (if (and (= a 0) (= b 0))
        (let ((j (* 16 (ji :weapon-l))))
          (replace m2 jm :start2 j :end2 (+ j 16))
          (m4-mul! m m2 *weapon-m*)
          (draw-weapon :kazeshini m :tint tint)
          (joint-point! v jm (ji :weapon-l) 0f0 0f0 0f0)
          (vfx-hs-chain w v 0.25f0 0.9f0))
        (let ((u (f-clamp (/ (i->f n) (i->f (max 1 d))) 0f0 1f0)))
          (declare (single-float u))
          (%hs-point v a jm pos fa anchor vpos)
          (%hs-point q b jm pos fa anchor vpos)
          (dotimes (i 3) (setf (aref v i) (+ (aref v i) (* u (- (aref q i) (aref v i))))))
          (%hs-place! m v fa (if (= a b) 0 1))
          (draw-weapon :kazeshini m :tint tint)
          (if (= a b) (vfx-hs-chain w v 0.12f0 0.9f0) (vfx-hs-chain w v 0.04f0 0.9f0))
          (when (= b 4)                                               ; the pull: the chain taut along the sim's segment
            (setf (aref v 0) (aref anchor 0) (aref v 1) (the single-float *hs-anchor-up*) (aref v 2) (aref anchor 1))
            (%hs-point q 4 jm pos fa anchor vpos)
            (vfx-hs-chain v q 0f0 0.7f0))))
    (when (= lightning 1)
      (let* ((yaw (aref fa 0)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (dr (drawing-no 24f0)))
        (declare (single-float yaw fx fz dr))
        (dotimes (i 13)
          (let* ((s (+ 0.5f0 (* 0.5f0 (i->f i)))) (jig (* 0.12f0 (f-sin (+ dr (* 2.3f0 (i->f i))))))
                 (px (+ (aref pos 0) (* s fx) (* jig fz))) (pz (- (+ (aref pos 2) (* s fz)) (* jig fx))))
            (declare (single-float s jig px pz))
            (fx-shard px 1.1f0 pz fx 0f0 fz 0.55f0 0.05f0 0.12f0 (+ (i->f i) 800f0 dr) +pal-jade+ 0.95f0 :push 0.12f0)
            (fx-shard px 1.1f0 pz fx 0f0 fz 0.5f0 0.016f0 0.08f0 (+ (i->f i) 840f0 dr) +pal-hit+ 0.95f0 :push 0.16f0))))))
  nil)

(defun hs-flight-codes (st name sf s a)
  "The left sickle's draw codes for move NAME at move frame SF (S, A its frames; *HS-FLIGHTS*' moves): values A B N D."
  (let* ((fl (assoc name *hs-flights*)) (end (+ s a)) (throw (third fl)))
    (cond ((< sf (- s 4)) (values 0 0 0 1))
          ((< sf s) (values 0 1 (- sf (- s 4)) 4))
          ((and throw (hss-anchored st)) (values 2 2 0 1))
          ((< sf end) (values 1 1 0 1))
          (throw (values 2 2 0 1))
          ((< (- sf end) 6) (values 1 0 (- sf end) 6))
          (t (values 0 0 0 1)))))

(defun hisagi-draw (e rdt)
  "His :draw hook (on the posed body): the left sickle (in his fist, flying, out at the anchor, returning), the chain, the
windmill, the lightning. A look: every point is the sim's (the anchor, *HS-FLIGHTS*' reach, HS-CHAIN-SEG's ends)."
  (declare (ignore rdt))
  (let* ((f (fighter e)) (m (model e)) (st (hs e)) (mv (and (eq (fighter-state f) :move) (eq (fighter-phase f) :main) (fighter-move f)))
         (name (and mv (mv-name mv))) (sf (fighter-sf f)) (o (opp-of e)) (fa *hs-a*) (bolt 0))
    (when (and (> (model-alpha m) 0.5) (entity-alive-p o))
      (setf (aref fa 0) (yaw-of e))
      (multiple-value-bind (a b n d)
          (cond ((and mv (assoc name *hs-flights*))
                 (setf (aref fa 1) (second (assoc name *hs-flights*))
                       bolt (if (and (eq name :hs-raiden) (< (- (mv-s mv) 3) sf (+ (mv-s mv) (mv-a mv) 5))) 1 0))
                 (hs-flight-codes st name sf (mv-s mv) (mv-a mv)))
                ((and mv (member name *hs-pulls*))
                 (if (< sf (mv-s mv)) (values 2 2 0 1) (values 2 4 (- sf (mv-s mv)) (+ (mv-a mv) 2))))
                ((eq name :hs-modoshi) (values 2 0 sf 6))
                ((and (eq name :hs-kaza) (<= (mv-s mv) sf) (< sf (+ (mv-s mv) (mv-a mv)))) (values 3 3 0 1))
                ((eq (hss-state st) :ret) (values 2 0 (- *hs-return-frames* (hss-ret-t st)) *hs-return-frames*))
                ((eq (hss-state st) :out) (values 2 2 0 1))
                (t (values 0 0 0 1)))
        (%hs-draw (model-joints m) (pos-of e) fa (hss-anchor st) (pos-of o) a b n d (model-tint m) bolt)))))

(defun hisagi-look-cons-check ()
  "Debug 83901 (P1 Hisagi): bytes consed by 10 calls of HISAGI-DRAW in the stance, out at the anchor, in NAGE's hit frame,
in HIKI's and in the windmill: each must be 0."
  (let* ((e *p1*) (f (fighter e)) (st (hs e)) (state (fighter-state f)) (mv (fighter-move f)) (ph (fighter-phase f))
         (sf (fighter-sf f)) (s0 (hss-state st)))
    (flet ((bytes () (let ((c0 (cons-bytes))) (dotimes (i 10) (hisagi-draw e 0.016)) (- (cons-bytes) c0)))
           (at (name frame) (setf (fighter-state f) :move (fighter-move f) (find-move name) (fighter-phase f) :main
                                  (fighter-sf f) frame)))
      (let* ((idle (bytes))
             (out (progn (setf (hss-state st) :out) (bytes)))
             (nage (progn (at :hs-k1 18) (bytes)))
             (hiki (progn (at :hs-k2 21) (bytes)))
             (kaza (progn (at :hs-kaza 20) (bytes))))
        (setf (fighter-state f) state (fighter-move f) mv (fighter-phase f) ph (fighter-sf f) sf (hss-state st) s0)
        (log-msg "duel hisagi look consing (10 calls, B): stance ~d, out ~d, NAGE ~d, HIKI ~d, windmill ~d" idle out nage hiki kaza)))))
(pushnew '(83901 83901 hisagi-art-debug) *char-debug* :test #'equal)
(defun hisagi-art-debug (c) (declare (ignore c)) (hisagi-look-cons-check))

;;; ---------------------------------------------------------------- the HUD: the sickle icon (the kit meter's :draw / :label, :deck)
(defun hs-hud-label (g kit) "The portrait label." (declare (ignore g kit)) "KAZESHINI")
(defun hs-hud-meter (e kit x y w h right tm lx ly ls)
  "His kit-meter row: the sickle icon by his Reiatsu (§8.3): lit white in hand, a dark outline OUT, half lit RETURNING; the
label KAZESHINI IN / OUT."
  (declare (ignore kit tm))
  (let* ((s (hss-state (hs e))) (hh (* 2.4 h)) (iw (* 0.9 hh)) (ix (if right (- (+ x w) iw) x)) (iy (- (+ y (* 0.5 h)) (* 0.5 hh))))
    (ui-rect ix iy iw hh '(0.1 0.1 0.12 0.8))
    (case s
      (:in (ui-rect (+ ix 2) (+ iy 2) (- iw 4) (- hh 4) '(0.93 0.93 0.9 1.0)))
      (:ret (ui-rect (+ ix 2) (+ iy (* 0.5 hh)) (- iw 4) (- (* 0.5 hh) 2) '(0.93 0.93 0.9 0.8)))
      (t (ui-rect (+ ix 2) (+ iy 2) (- iw 4) (- hh 4) '(0.3 0.3 0.34 0.7))))
    (when lx
      (hud-text (case s (:in "KAZESHINI IN") (:ret "KAZESHINI ...") (t "KAZESHINI OUT")) lx ly ls '(0.93 0.93 0.9 1.0)
                :align (if right :right :left)))))
(setf (kit-meter (find-kit :hisagi :base)) (list :name "KAZESHINI" :max 1 :draw 'hs-hud-meter :label 'hs-hud-label))
(defun hs-deck (e cx cy d)
  "His :deck hook (one hand): a dot above the thumb, lit while the sickle is in hand."
  (let ((r (* d 52.0)))
    (ui-rect (- cx (* 3 d)) (- cy r (* 3 d)) (* 6 d) (* 6 d)
             (if (eq (hss-state (hs e)) :in) '(0.93 0.93 0.9 1.0) '(0.3 0.3 0.32 0.6)))))

;;; ---------------------------------------------------------------- name, cinematic (a placeholder: the §11.5 storyboard later)
(setf *brush-names* (append (remove :hisagi *brush-names* :key #'first) '((:hisagi "檜佐木修兵" "HISAGI SHUHEI"))))

(defcine hs-kikon-cine (a v :len 120 :hold 60)
  "刈れ、風死 (the Shikai Kikon, a placeholder for §11.5's storyboard): beat 0, the throw held; low and close, the 刈 / 風死
stamp, silence; on him, the sickle's cut; the shatter: a negative, a manga page; a wide."
  (at 0 (face-each-other a v 3.0)
      (cine-clip a :hs-kari-o :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 8) (impact-frame :negative 2) (play-sfx :chain-snap))
  (at 8 (shot-on a 30 3.4 1.0 :look 1.1 :off -0.7) (lens 50 -6) (silence 30)
      (caption "刈" :kanji2 "風死" :reading "KARE, KAZESHINI" :side 1))
  (at 50 (shot-on v 150 4.0 0.6 :look 1.2) (lens 60) (play-sfx :whoosh-heavy))
  (at 70 (impact-frame :negative 2) (cine-shatter v 2) (play-sfx :konpaku-shatter) (shake 0.2 0.3))
  (at 72 (impact-frame :manga 10))
  (at 96 (shot-pair a v 1 7.0 2.2) (lens 50) (caption-exit)))

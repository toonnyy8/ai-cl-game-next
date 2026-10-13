;;;; yama-art.lisp — YAMAMOTO GENRYUSAI (TYBW) as art data: his body, his three weapons (the cane
;;;; he leans on, Ryujin Jakka, the charred Bankai blade Zanka no Tachi), the charred :skeleton of
;;;; Bankai South, and every :ya-* / :sk-* pose and clip (design §5.1). Attack clips use DEFSTRIKE,
;;;; so each reaches its hit pose at frame S and is back in :ya-stance at S+A+R. Pose to pose (style §2.6,
;;;; *key-ease* 1): a wind-up held a few frames, a :snap into the named hit pose :ya-*-hit at :s (the blade
;;;; where the move's hit volume is), a small overshoot held through :a, a half-way recovery, the stance.
;;;; Look: 1.68 m, hunched, bald + X scar, long white brows, waist-length beard tied with a purple
;;;; cord, black shihakusho + white captain's haori (一 on the back), no left forearm (empty sleeve).
(in-package :duel)

;;; ---------------------------------------------------------------- body
;; Proportions (user review 1: realistic, not chibi): a narrow head (the girth factors), a lean chest,
;; arms to mid-thigh (:props :arms, the arm shapes as long), bigger hands, a slighter hunch.
(defbody :yamamoto (:scale 0.95 :width 1.05 :hunch 14 :hurt-r 0.36 :hurt-h 1.65
                    :props (:arms 1.12)
                    :girth ((:chest 0.86 1.0 0.92) (:spine 0.86 1.0 0.92) (:pelvis 0.9 1.0 0.95)
                            (:upper-arm-r 0.9 1.12 0.9) (:upper-arm-l 0.9 1.12 0.9) (:lower-arm-r 0.9 1.12 0.9)
                            (:hand-r 1.2 1.3 1.2))
                    ;; v4 notan palette (docs/style/STYLE_STORM_DESIGN.md §2.5): a solid black robe, a V4 white
                    ;; haori whose shadow turns cold grey-blue, muted skin (the only warm non-spot colour)
                    :palette ((:skin #xD8B4A0) (:black #x16161E) (:white #xF0F0EC) (:beard #xECECEA)
                              (:cord #x4A3A6A) (:scar #x7A4A3C) (:obi #xC8CCD6) (:tabi #xE8E8E4)
                              (:sole #x262833) (:mouth #x3A1E1A) (:lid #x1E1818) (:fold #xD8DCE4))
                    :rim (#xFFB070 0.22))
  (:pelvis (:box 0.34 0.18 0.24 :c :black)
           (:box 0.35 0.07 0.25 :at (0 0.06 0) :c :obi)
           (:box 0.42 0.74 0.025 :at (0 -0.3 -0.14) :rot (0 -5 0) :c :white)          ; haori back
           (:box 0.025 0.74 0.28 :at (0.215 -0.3 0) :rot (0 0 4) :c :white)            ; sides
           (:box 0.025 0.74 0.28 :at (-0.215 -0.3 0) :rot (0 0 -4) :c :white)
           (:box 0.12 0.74 0.025 :at (0.16 -0.3 0.135) :rot (0 5 0) :c :white)         ; open front
           (:box 0.12 0.74 0.025 :at (-0.16 -0.3 0.135) :rot (0 5 0) :c :white))
  ;; the haori over the torso: one rounded white shell, the black robe at its open front
  (:spine (:bevel 0.46 0.25 0.28 0.04 :at (0 0.11 -0.005) :c :white)
          (:box 0.12 0.25 0.02 :at (0 0.11 0.15) :c :black))
  (:chest (:bevel 0.5 0.3 0.29 0.05 :at (0 0.11 -0.005) :c :white)
          (:box 0.13 0.3 0.02 :at (0 0.11 0.15) :c :black)
          (:box 0.025 0.2 0.01 :at (0.035 0.15 0.162) :rot (0 0 -22) :c :obi)         ; under-collar V
          (:box 0.025 0.2 0.01 :at (-0.035 0.15 0.162) :rot (0 0 22) :c :obi)
          (:box 0.2 0.035 0.01 :at (0 0.17 -0.157) :c :black))                         ; 一 on the back
  (:neck (:cyl 0.065 0.1 :at (0 0.04 0) :c :skin))
  ;; head in metres (not girth-scaled; x and z sizes x the body :width 1.05): a bald skull sphere, a
  ;; flat-fronted face (front at z 0.08) with the flat face shapes (tag :face-neutral), the long beard
  (:head (:sphere 0.0743 :stretch 0.05 :at (0 0.135 -0.008) :seg 12 :c :skin)             ; bald skull
         (:bevel 0.108 0.13 0.076 0.018 :at (0 0.1 0.042) :c :skin)                         ; face
         (:box 0.021 0.055 0.032 :at (0.078 0.115 -0.005) :c :skin) (:box 0.021 0.055 0.032 :at (-0.078 0.115 -0.005) :c :skin)
         (:wedge 0.028 0.05 0.029 :at (0 0.1 0.095) :rot (180 0 0) :c :skin)               ; nose
         (:box 0.036 0.008 0.008 :at (0 0.19 0.066) :rot (0 -24 38) :c :scar)              ; X scar
         (:box 0.036 0.008 0.008 :at (0 0.19 0.066) :rot (0 -24 -38) :c :scar)
         ;; eyes: narrow old man's slits, drooping at the outer ends, under the long brows
         (:box 0.03 0.006 0.004 :at (0.03 0.128 0.082) :rot (0 0 -8) :c :lid :tag :face-neutral)
         (:box 0.03 0.006 0.004 :at (-0.03 0.128 0.082) :rot (0 0 8) :c :lid :tag :face-neutral)
         (:box 0.022 0.004 0.004 :at (0.032 0.118 0.0815) :rot (0 0 6) :c :scar :tag :face-neutral)   ; lower lids
         (:box 0.022 0.004 0.004 :at (-0.032 0.118 0.0815) :rot (0 0 -6) :c :scar :tag :face-neutral)
         (:box 0.064 0.022 0.026 :at (0.035 0.143 0.087) :rot (0 0 -14) :c :beard :tag :face-neutral)   ; long brows
         (:box 0.064 0.022 0.026 :at (-0.035 0.143 0.087) :rot (0 0 14) :c :beard :tag :face-neutral)
         ;; :face-shout, the glare: eyes wide open (whites framed by ink lids, small hard pupils), the brows
         ;; thrown up, inner ends down; the mouth open between the moustache halves (a dark block, teeth)
         (:box 0.034 0.024 0.003 :at (0.03 0.126 0.0815) :c :white :tag :face-shout)
         (:box 0.034 0.024 0.003 :at (-0.03 0.126 0.0815) :c :white :tag :face-shout)
         (:box 0.007 0.007 0.003 :at (0.027 0.125 0.0835) :c :lid :tag :face-shout)                  ; pupils
         (:box 0.007 0.007 0.003 :at (-0.027 0.125 0.0835) :c :lid :tag :face-shout)
         (:box 0.038 0.005 0.004 :at (0.03 0.1395 0.0835) :rot (0 0 8) :c :lid :tag :face-shout)     ; upper lids
         (:box 0.038 0.005 0.004 :at (-0.03 0.1395 0.0835) :rot (0 0 -8) :c :lid :tag :face-shout)
         (:box 0.03 0.004 0.004 :at (0.031 0.1135 0.0835) :c :lid :tag :face-shout)                  ; lower lids
         (:box 0.03 0.004 0.004 :at (-0.031 0.1135 0.0835) :c :lid :tag :face-shout)
         (:box 0.066 0.022 0.026 :at (0.037 0.165 0.087) :rot (0 0 18) :c :beard :tag :face-shout)   ; brows
         (:box 0.066 0.022 0.026 :at (-0.037 0.165 0.087) :rot (0 0 -18) :c :beard :tag :face-shout)
         (:box 0.066 0.048 0.019 :at (0 0.048 0.1085) :c :mouth :tag :face-shout)                   ; open mouth (Phase 6: bolder)
         (:box 0.054 0.009 0.003 :at (0 0.0665 0.1195) :c :white :tag :face-shout)                   ; upper teeth
         (:box 0.042 0.007 0.003 :at (0 0.0295 0.1195) :c :white :tag :face-shout)                   ; lower teeth
         ;; :face-hurt: eyes squeezed shut (> < ink strokes, crow's feet), the brows pushed up at their inner
         ;; ends, a grimace (clenched teeth: the clench and two tooth gaps in ink)
         (:box 0.028 0.005 0.004 :at (0.03 0.131 0.0825) :rot (0 0 14) :c :lid :tag :face-hurt)
         (:box 0.028 0.005 0.004 :at (0.03 0.125 0.0825) :rot (0 0 -14) :c :lid :tag :face-hurt)
         (:box 0.028 0.005 0.004 :at (-0.03 0.131 0.0825) :rot (0 0 -14) :c :lid :tag :face-hurt)
         (:box 0.028 0.005 0.004 :at (-0.03 0.125 0.0825) :rot (0 0 14) :c :lid :tag :face-hurt)
         (:box 0.012 0.003 0.004 :at (0.05 0.133 0.0815) :rot (0 0 28) :c :lid :tag :face-hurt)      ; crow's feet
         (:box 0.012 0.003 0.004 :at (0.05 0.122 0.0815) :rot (0 0 -28) :c :lid :tag :face-hurt)
         (:box 0.012 0.003 0.004 :at (-0.05 0.133 0.0815) :rot (0 0 -28) :c :lid :tag :face-hurt)
         (:box 0.012 0.003 0.004 :at (-0.05 0.122 0.0815) :rot (0 0 28) :c :lid :tag :face-hurt)
         (:box 0.064 0.022 0.026 :at (0.035 0.15 0.087) :rot (0 0 -26) :c :beard :tag :face-hurt)    ; brows up-inward
         (:box 0.064 0.022 0.026 :at (-0.035 0.15 0.087) :rot (0 0 26) :c :beard :tag :face-hurt)
         (:box 0.068 0.032 0.019 :at (0 0.047 0.1085) :c :mouth :tag :face-hurt)                     ; grimace (Phase 6: wider)
         (:box 0.06 0.021 0.003 :at (0 0.047 0.1195) :c :white :tag :face-hurt)                      ; clenched teeth
         (:box 0.06 0.003 0.003 :at (0 0.047 0.1215) :c :lid :tag :face-hurt)
         (:box 0.0025 0.017 0.003 :at (0.012 0.047 0.1215) :c :lid :tag :face-hurt)
         (:box 0.0025 0.017 0.003 :at (-0.012 0.047 0.1215) :c :lid :tag :face-hurt)
         (:box 0.022 0.1 0.024 :at (0.068 0.1 0.084) :rot (0 0 12) :c :beard)              ; ... hanging past the eyes
         (:box 0.022 0.1 0.024 :at (-0.068 0.1 0.084) :rot (0 0 -12) :c :beard)
         (:bevel 0.152 0.11 0.105 0.016 :at (0 0.04 0.0467) :c :beard)                     ; jaw + moustache
         (:box 0.038 0.12 0.024 :at (0.048 0.02 0.102) :rot (0 0 -10) :c :beard)
         (:box 0.038 0.12 0.024 :at (-0.048 0.02 0.102) :rot (0 0 10) :c :beard)
         (:box 0.145 0.26 0.073 :at (0 -0.1 0.1105) :rot (0 8 0) :c :beard)               ; the long beard
         (:box 0.0025 0.17 0.006 :at (-0.03 -0.12 0.151) :rot (0 8 3) :c :lid)             ; ink strands (ink on white)
         (:box 0.0025 0.2 0.006 :at (0.006 -0.13 0.151) :rot (0 8 -1) :c :lid)
         (:box 0.0025 0.12 0.006 :at (0.036 -0.09 0.151) :rot (0 8 -4) :c :lid)
         (:box 0.004 0.05 0.006 :at (0.022 0.072 0.104) :rot (0 0 -55) :c :lid)            ; the moustache's parting
         (:box 0.004 0.05 0.006 :at (-0.022 0.072 0.104) :rot (0 0 55) :c :lid)
         (:box 0.107 0.22 0.057 :at (0 -0.3 0.153) :rot (0 8 0) :c :beard)
         (:box 0.118 0.04 0.069 :at (0 -0.33 0.153) :rot (0 8 0) :c :cord)
         (:cone 0.051 0.18 :at (0 -0.49 0.17) :rot (0 172 0) :seg 5 :c :beard))
  (:shoulder-r (:bevel 0.13 0.06 0.2 0.02 :at (0.02 -0.02 0) :rot (0 0 -24) :c :white))
  (:shoulder-l (:bevel 0.13 0.06 0.2 0.02 :at (-0.02 -0.02 0) :rot (0 0 24) :c :white))
  (:upper-arm-r (:box 0.14 0.31 0.15 :at (0 -0.15 0) :c :white))
  (:upper-arm-l (:box 0.13 0.31 0.14 :at (0 -0.15 0) :c :white)
                (:box 0.11 0.3 0.07 :at (0 -0.42 0.02) :rot (0 8 0) :c :white))      ; empty sleeve
  (:lower-arm-r (:box 0.16 0.21 0.18 :at (0 -0.1 0) :c :white)
                (:box 0.04 0.2 0.2 :at (0 -0.16 -0.06) :rot (0 -10 0) :c :white)              ; hanging sleeve
                (:box 0.13 0.04 0.15 :at (0 -0.21 0) :c :black)
                (:box 0.13 0.005 0.004 :at (0 -0.196 0.081) :c :fold)
                (:box 0.07 0.08 0.07 :at (0 -0.23 0) :c :skin))
  (:hand-r (:bevel 0.075 0.09 0.075 0.02 :at (0 -0.045 0) :c :skin))
  (:thigh-r (:cyl 0.096 0.46 :top 0.09 :seg 10 :at (0 -0.22 0) :c :black)
           (:box 0.005 0.3 0.004 :at (0.035 -0.2 0.118) :rot (0 -3 -4) :c :fold))
  (:thigh-l (:cyl 0.096 0.46 :top 0.09 :seg 10 :at (0 -0.22 0) :c :black)
           (:box 0.005 0.26 0.004 :at (-0.03 -0.24 0.118) :rot (0 -3 5) :c :fold))
  (:shin-r (:cyl 0.12 0.3 :top 0.1 :seg 10 :at (0 -0.1 0) :c :black)
          (:box 0.005 0.22 0.004 :at (0.02 -0.12 0.123) :rot (0 -5 -6) :c :fold) (:cyl 0.13 0.08 :top 0.12 :seg 10 :at (0 -0.27 0) :c :black)
          (:box 0.08 0.12 0.09 :at (0 -0.37 0) :c :tabi))
  (:shin-l (:cyl 0.12 0.3 :top 0.1 :seg 10 :at (0 -0.1 0) :c :black) (:cyl 0.13 0.08 :top 0.12 :seg 10 :at (0 -0.27 0) :c :black)
          (:box 0.08 0.12 0.09 :at (0 -0.37 0) :c :tabi))
  (:foot-r (:bevel 0.09 0.06 0.22 0.02 :at (0 -0.02 0.06) :c :tabi) (:box 0.1 0.02 0.24 :at (0 -0.055 0.06) :c :sole))
  (:foot-l (:bevel 0.09 0.06 0.22 0.02 :at (0 -0.02 0.06) :c :tabi) (:box 0.1 0.02 0.24 :at (0 -0.055 0.06) :c :sole)))

;;; ---------------------------------------------------------------- weapons
(defweapon :ya-cane (:length 0.86 :base 0.1)          ; the shikomizue: Ryujin Jakka sheathed in a cane
  (:solid (mbc mb #x3A3430)                           ; dark wood, desaturated (colour is spot-only)
          (with-xform (mb (xform :y 0.4)) (mb-cylinder mb 0.018 0.92 :segments 6))
          (mbc mb #x26221E)
          (with-xform (mb (xform :y -0.06)) (mb-cylinder mb 0.02 0.14 :segments 6))
          (with-xform (mb (xform :y 0.855)) (mb-cylinder mb 0.02 0.03 :segments 6))))

(defweapon :ryujin-jakka (:length 0.95)
  (:solid :ink 0 (mb-blade mb :length 0.9 :width 0.036 :blade-color '(0.76 0.78 0.82) :edge-color '(1.0 0.93 0.85) :hilt nil))
  (:solid (mb-blade mb :width 0.036 :guard-color '(0.44 0.42 0.38) :handle-color '(0.08 0.06 0.07) :wrap-color '(0.3 0.25 0.4) :blade nil))
  (:glow 1.2 #xFF7A2A (with-xform (mb (xform :y 0.45 :z 0.017)) (mb-box mb 0.003 0.8 0.004))))

(defweapon :zanka (:length 0.95)
  (:solid :ink 0 (mb-blade mb :length 0.9 :width 0.04 :curve 0.004 :blade-color '(0.07 0.055 0.055)
                              :edge-color '(0.3 0.07 0.03) :hilt nil))
  (:solid (mb-blade mb :width 0.04 :guard-color '(0.16 0.12 0.1) :handle-color '(0.05 0.04 0.04) :wrap-color '(0.18 0.08 0.06)
                       :blade nil))
  (:glow 3.5 #xFF5A14 (with-xform (mb (xform :y 0.46 :z 0.02)) (mb-box mb 0.005 0.86 0.006))
                      (with-xform (mb (xform :y 0.3 :z 0.0 :roll 0.5)) (mb-box mb 0.009 0.07 0.004))
                      (with-xform (mb (xform :y 0.62 :z 0.004 :roll -0.4)) (mb-box mb 0.009 0.08 0.004))))

;;; ---------------------------------------------------------------- the charred skeleton (Bankai South)
(defbody :skeleton (:scale 1.0 :width 1.0 :hunch 20 :hurt-r 0.3 :hurt-h 1.7
                    :palette ((:bone #xD2CEC4) (:ash #x4A4E5C) (:ember #xFF5A1A))   ; pale bone, charred bands: they read on the V2 plaza
                    :rim (#xFF6A2A 0.35))
  (:pelvis (:bevel 0.26 0.1 0.12 0.02 :c :ash))
  (:spine (:box 0.05 0.24 0.05 :at (0 0.11 -0.04) :c :bone)
          (:glow 2.0 (:box 0.02 0.18 0.02 :at (0 0.11 -0.01) :c :ember)))
  (:chest (:box 0.06 0.24 0.06 :at (0 0.1 -0.06) :c :bone)
          (:box 0.3 0.035 0.18 :at (0 0.04 0) :c :ash) (:box 0.34 0.035 0.2 :at (0 0.1 0) :c :bone)
          (:box 0.32 0.035 0.19 :at (0 0.16 0) :c :ash) (:box 0.26 0.035 0.16 :at (0 0.21 0) :c :bone)
          (:glow 2.5 (:box 0.2 0.1 0.12 :at (0 0.12 0) :c :ember)))
  (:neck (:box 0.04 0.1 0.04 :at (0 0.04 0) :c :bone))
  (:head (:bevel 0.17 0.17 0.2 0.04 :at (0 0.13 0) :c :ash)
         (:box 0.12 0.06 0.1 :at (0 0.03 0.04) :c :bone)
         (:glow 4.0 (:box 0.04 0.035 0.01 :at (0.04 0.13 0.1) :c :ember))
         (:glow 4.0 (:box 0.04 0.035 0.01 :at (-0.04 0.13 0.1) :c :ember)))
  (:shoulder-r (:box 0.14 0.04 0.05 :at (0.04 0 0) :c :bone))
  (:shoulder-l (:box 0.14 0.04 0.05 :at (-0.04 0 0) :c :bone))
  (:upper-arm-r (:box 0.045 0.3 0.045 :at (0 -0.15 0) :c :bone))
  (:upper-arm-l (:box 0.045 0.3 0.045 :at (0 -0.15 0) :c :bone))
  (:lower-arm-r (:box 0.04 0.27 0.04 :at (0 -0.135 0) :c :ash))
  (:lower-arm-l (:box 0.04 0.27 0.04 :at (0 -0.135 0) :c :ash))
  (:hand-r (:box 0.07 0.1 0.03 :at (0 -0.05 0) :c :bone) (:cone 0.03 0.08 :at (0 -0.13 0) :rot (0 180 0) :seg 4 :c :bone))
  (:hand-l (:box 0.07 0.1 0.03 :at (0 -0.05 0) :c :bone) (:cone 0.03 0.08 :at (0 -0.13 0) :rot (0 180 0) :seg 4 :c :bone))
  (:thigh-r (:box 0.05 0.44 0.05 :at (0 -0.22 0) :c :bone))
  (:thigh-l (:box 0.05 0.44 0.05 :at (0 -0.22 0) :c :bone))
  (:shin-r (:box 0.045 0.43 0.045 :at (0 -0.215 0) :c :ash))
  (:shin-l (:box 0.045 0.43 0.045 :at (0 -0.215 0) :c :ash))
  (:foot-r (:box 0.07 0.04 0.18 :at (0 -0.03 0.05) :c :bone))
  (:foot-l (:box 0.07 0.04 0.18 :at (0 -0.03 0.05) :c :bone)))

;;; ---------------------------------------------------------------- poses
(defpose :ya-stance ()
  (:root :u -0.04) (:pelvis :twist 10) (:spine :flex 8) (:chest :twist -8) (:neck :flex -16) (:head :flex -16)
  (:arm-r :flex 22 :side 22) (:elbow-r :flex 40) (:hand-r :flex -30)
  (:arm-l :flex 4 :side 10) (:elbow-l :flex 0)
  (:thigh-r :flex -8 :side 8) (:thigh-l :flex 18 :side 6) (:knee-r :flex 18) (:knee-l :flex 22))

(defclip :ya-stance (2.4 :loop t :base :ya-stance)
  (0) (1.2 (:chest :flex 3) (:root :u -0.05)))

;;; ---------------------------------------------------------------- shikai kit (§5.1 table)
;;; Blade directions reuse RAVEN's solved hand values (same rig): diagonal = rb-slash,
;;; horizontal R->L = h1, backhand = h2, overhead = h3, rising = rising-crow, thrust = crimson-lance.
(defpose :ya-q1-hit (:base :ya-stance)
  (:chest :twist -25) (:arm-r :flex 150 :side 30) (:elbow-r :flex 30) (:hand-r :twist -15 :flex -15) (:spine :flex 2)
  (:arm-r :flex 40 :side -10) (:elbow-r :flex 10) (:hand-r :twist -15 :flex -75) (:chest :twist 35) (:spine :flex 22)
  (:root :f 0.65))
(defstrike :ya-q1 (9 3 12 :base :ya-stance)            ; flame cut: diagonal down
  (0)
  (4 (:chest :twist -30) (:arm-r :flex 155 :side 32) (:elbow-r :flex 35) (:hand-r :twist -15 :flex -10) (:spine :flex 0)
     (:root :u -0.06) (:knees :flex 26) (:head :flex -22))
  (7 (:chest :twist -34) (:arm-r :flex 160) (:spine :flex -2))
  (:s :snap :ya-q1-hit (:thigh-l :flex 32) (:knee-l :flex 32) (:head :flex -24))
  (10 (:chest :twist 43) (:arm-r :flex 32 :side -16) (:hand-r :flex -80) (:spine :flex 25) (:root :f 0.68))
  (:a (:chest :twist 40) (:arm-r :flex 34 :side -13) (:hand-r :flex -77) (:spine :flex 24) (:root :f 0.67))
  (17 (:chest :twist 14) (:arm-r :flex 30 :side 6) (:elbow-r :flex 28) (:hand-r :flex -45) (:spine :flex 14)
      (:root :f 0.31 :u -0.05) (:thigh-l :flex 24) (:knee-l :flex 26))
  (:end :ya-stance))
(defpose :ya-q2-hit (:base :ya-stance)
  (:chest :twist 55) (:spine :side 8) (:arm-r :side -15 :flex 75) (:elbow-r :flex 15) (:hand-r :twist 55 :flex -80)
  (:chest :twist -55) (:arm-r :side 60 :flex 30) (:elbow-r :flex 95) (:hand-r :twist 5 :flex -45) (:spine :side 0)
  (:root :f 0.42))
(defstrike :ya-q2 (8 3 13 :base :ya-stance)            ; backhand
  (0)
  (4 (:chest :twist 60) (:spine :side 9 :flex 12) (:arm-r :side -18 :flex 78) (:elbow-r :flex 15)
     (:hand-r :twist 55 :flex -80) (:root :u -0.06) (:head :flex -20))
  (6 (:chest :twist 64) (:arm-r :side -21))
  (:s :snap :ya-q2-hit (:thigh-r :flex -18) (:head :flex -18))
  (9 (:chest :twist -66) (:arm-r :side 66 :flex 24) (:root :f 0.44))
  (:a (:chest :twist -62) (:arm-r :side 64 :flex 25) (:root :f 0.43))
  (17 (:chest :twist -24) (:arm-r :side 45 :flex 30) (:elbow-r :flex 25) (:hand-r :flex -55) (:root :f 0.26 :u -0.05)
      (:thigh-r :flex -10))
  (:end :ya-stance))
(defpose :ya-q3-hit (:base :ya-stance)
  (:root :u 0.03) (:arm-r :flex 175 :side 10) (:elbow-r :flex 25) (:hand-r :twist 0 :flex -50) (:spine :flex -8)
  (:chest :twist 0) (:head :flex -20)
  (:root :u -0.2 :f 0.3) (:spine :flex 40) (:arm-r :flex 25 :side 10) (:elbow-r :flex 0) (:hand-r :twist -10 :flex -35)
  (:knees :flex 55) (:thigh-l :flex 55) (:head :flex -30))
(defstrike :ya-q3 (12 4 22 :base :ya-stance)           ; flame burst: one-handed overhead chop
  (0)
  (6 (:root :u 0.04) (:arm-r :flex 178 :side 10) (:elbow-r :flex 30) (:hand-r :twist 0 :flex -55) (:spine :flex -12)
     (:chest :twist 0) (:head :flex -24) (:thigh-l :flex 26))
  (10 (:root :u 0.05) (:arm-r :flex 182) (:elbow-r :flex 33) (:spine :flex -14))
  (:s :snap :ya-q3-hit)
  (13 (:spine :flex 46) (:root :u -0.24) (:arm-r :flex 20) (:hand-r :flex -30))
  (:a (:spine :flex 43) (:root :u -0.22) (:arm-r :flex 23) (:hand-r :flex -33))
  (26 (:spine :flex 26) (:root :u -0.13 :f 0.14) (:arm-r :flex 32 :side 16) (:elbow-r :flex 22) (:hand-r :flex -40)
      (:knees :flex 38) (:thigh-l :flex 36) (:head :flex -22))
  (:end :ya-stance))
(defpose :ya-f1-hit (:base :ya-stance)
  (:chest :twist -65) (:spine :side -10) (:arm-r :side 90 :flex 0) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -90)
  (:thigh-r :flex -25) (:root :u -0.08)
  (:chest :twist 75) (:arm-r :flex 80 :side 10) (:hand-r :twist 5 :flex -85) (:root :f 0.4 :u -0.12) (:spine :side 0)
  (:thigh-l :flex 45) (:knee-l :flex 50))
(defstrike :ya-f1 (18 4 20 :base :ya-stance)           ; flame sweep: wide horizontal with a step
  (0)
  (9 (:chest :twist -62) (:spine :side -9 :flex 12) (:arm-r :side 88 :flex 0) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -90)
     (:thigh-r :flex -25) (:root :u -0.08) (:head :flex -20))
  (15 (:chest :twist -71) (:spine :side -12) (:arm-r :side 93) (:root :u -0.1))
  (:s :snap :ya-f1-hit (:head :flex -20))
  (19 (:chest :twist 89) (:arm-r :flex 74 :side -14) (:hand-r :flex -88) (:root :f 0.44))
  (:a (:chest :twist 85) (:arm-r :flex 75 :side -10) (:hand-r :flex -85) (:root :f 0.42))
  (31 (:chest :twist 34) (:arm-r :flex 45 :side 15) (:elbow-r :flex 25) (:hand-r :flex -60) (:root :f 0.2 :u -0.08)
      (:thigh-l :flex 30) (:knee-l :flex 34) (:thigh-r :flex -14))
  (:end :ya-stance))
(defpose :ya-f2-hit (:base :ya-stance)
  (:root :u -0.25) (:arm-r :flex -30 :side 20) (:elbow-r :flex 10) (:hand-r :twist 155 :flex 15) (:knees :flex 55)
  (:spine :flex 25)
  (:root :u 0.08) (:arm-r :flex 170 :side 10) (:hand-r :twist -155 :flex 15) (:spine :flex -20) (:knees :flex 10)
  (:head :flex -30))
(defstrike :ya-f2 (22 5 28 :base :ya-stance)           ; rising blaze: launcher
  (0)
  (10 (:root :u -0.23) (:arm-r :flex -27 :side 20) (:elbow-r :flex 12) (:hand-r :twist 155 :flex 15) (:knees :flex 52)
      (:spine :flex 24) (:head :flex -8))
  (19 (:root :u -0.27) (:arm-r :flex -34) (:knees :flex 58) (:spine :flex 27))
  (:s :snap :ya-f2-hit)
  (24 (:arm-r :flex 180) (:root :u 0.12) (:spine :flex -24) (:head :flex -34))
  (:a (:arm-r :flex 176) (:root :u 0.1) (:spine :flex -21) (:head :flex -31))
  (40 (:root :u 0.0) (:arm-r :flex 105 :side 15) (:elbow-r :flex 25) (:hand-r :twist -70 :flex -15) (:spine :flex 0)
      (:knees :flex 18) (:head :flex -22))
  (:end :ya-stance))
;; J3 SODEBI (docs/duel/DUEL_STRINGS.md §3.1; pulled in close, §13): the one-armed silhouette: the blade kept low behind him, he whips the empty left
;; sleeve (burning: main.lisp SLEEVE-FIRE) across the face, left to right, the body turning into it
(defpose :ya-sleeve-hit (:base :ya-stance)
  (:root :f 0.54 :u -0.06) (:pelvis :twist -18) (:chest :twist -48) (:spine :flex 14 :side -6) (:head :flex -18 :twist 12)
  (:arm-l :flex 105 :side -35) (:elbow-l :flex 10)
  (:arm-r :flex -12 :side 34) (:elbow-r :flex 30) (:hand-r :twist 20 :flex -30)
  (:thigh-l :flex 38 :side 6) (:knee-l :flex 36) (:thigh-r :flex -22 :side 8) (:knee-r :flex 16))
(defstrike :ya-sleeve (9 3 18 :base :ya-stance)        ; J3 SODEBI: the burning empty sleeve
  (0)
  (4 (:chest :twist 42) (:pelvis :twist 16) (:spine :flex 6 :side 8) (:arm-l :side 75 :flex -18) (:elbow-l :flex 5)
     (:arm-r :flex 4 :side 30) (:elbow-r :flex 36) (:hand-r :twist 20 :flex -32) (:root :u -0.07) (:head :flex -20 :twist -10))
  (7 (:chest :twist 48) (:arm-l :side 82 :flex -22) (:spine :side 10))                    ; wound up, held
  (:s :snap :ya-sleeve-hit)
  (10 (:chest :twist -56) (:arm-l :flex 112 :side -45) (:root :f 0.56))
  (:a (:chest :twist -53) (:arm-l :flex 109 :side -41) (:root :f 0.55))
  (21 (:chest :twist -20) (:arm-l :flex 40 :side 5) (:elbow-l :flex 5) (:spine :flex 10 :side 0) (:root :f 0.34 :u -0.05)
      (:arm-r :flex 16 :side 24) (:thigh-l :flex 24) (:knee-l :flex 26))
  (:end :ya-stance))
;; the Signature: three extremes (the cuts f16 and f28, the chop that launches the wave f40), each snapped
(defpose :ya-sig-hit1 (:base :ya-stance)
  (:chest :twist -60) (:arm-r :side 90 :flex 0) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -90) (:root :u -0.06)
  (:chest :twist 60) (:arm-r :flex 80 :side 10) (:hand-r :twist 5 :flex -85) (:root :f 0.2))
(defpose :ya-sig-hit2 (:base :ya-sig-hit1)
  (:chest :twist 60) (:arm-r :side -15 :flex 75) (:elbow-r :flex 15) (:hand-r :twist 55 :flex -80)
  (:chest :twist -55) (:arm-r :side 90 :flex 30) (:hand-r :twist 5 :flex -70) (:root :f 0.3))
(defpose :ya-sig-hit3 (:base :ya-sig-hit2)
  (:root :u 0.03) (:chest :twist 0) (:arm-r :flex 178 :side 5) (:elbow-r :flex 20) (:hand-r :twist 0 :flex -50)
  (:spine :flex -12) (:head :flex -25)
  (:root :u -0.22 :f 0.45) (:spine :flex 42) (:arm-r :flex 20 :side 5) (:elbow-r :flex 0) (:hand-r :twist -10 :flex -35)
  (:knees :flex 55) (:thigh-l :flex 55) (:head :flex -32))
(defstrike :ya-sig (16 24 26 :base :ya-stance)         ; flame slash wave: hits f16, f28, wave launched f40
  (0)
  (7 (:chest :twist -58) (:spine :side -9) (:arm-r :side 88 :flex 0) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -90)
     (:root :u -0.07) (:head :flex -20))
  (13 (:chest :twist -66) (:spine :side -11) (:arm-r :side 93) (:root :u -0.08))
  (16 :snap :ya-sig-hit1 (:thigh-l :flex 30) (:knee-l :flex 34))
  (18 (:chest :twist 66) (:arm-r :flex 76 :side 3) (:root :f 0.23))
  (22 (:chest :twist 62) (:arm-r :side -16 :flex 75) (:elbow-r :flex 15) (:hand-r :twist 55 :flex -80) (:root :f 0.22))
  (25 (:chest :twist 66) (:arm-r :side -19))
  (28 :snap :ya-sig-hit2 (:thigh-l :flex 30) (:knee-l :flex 34) (:thigh-r :flex -16))
  (30 (:chest :twist -61) (:arm-r :side 96 :flex 26) (:root :f 0.33))
  (34 (:root :u 0.03 :f 0.33) (:chest :twist 0) (:arm-r :flex 176 :side 5) (:elbow-r :flex 20) (:hand-r :twist 0 :flex -50)
      (:spine :flex -12) (:head :flex -25) (:thigh-r :flex -8))
  (37 (:root :u 0.05) (:arm-r :flex 181) (:elbow-r :flex 23) (:spine :flex -14) (:head :flex -27))
  (40 :snap :ya-sig-hit3)
  (42 (:spine :flex 46) (:root :u -0.24 :f 0.48) (:arm-r :flex 16) (:hand-r :flex -31))
  (46 (:spine :flex 44) (:root :u -0.22 :f 0.46) (:arm-r :flex 19) (:hand-r :flex -34))
  (56 (:spine :flex 24) (:root :u -0.12 :f 0.2) (:arm-r :flex 30 :side 15) (:elbow-r :flex 22) (:hand-r :flex -40)
      (:knees :flex 36) (:thigh-l :flex 34) (:head :flex -22))
  (:end :ya-stance))
(defclip :ya-shiranui (0.5 :loop t :base :ya-stance)   ; charging: blade drawn back at the hip
  (0 (:root :u -0.16) (:knees :flex 45) (:chest :twist -45) (:spine :flex 15) (:arm-r :flex -25 :side 35) (:elbow-r :flex 95)
     (:hand-r :twist 150 :flex 20) (:head :twist 25 :flex -20))
  (0.25 (:root :u -0.18) (:chest :twist -48) (:arm-r :side 37)))
(defpose :ya-throw-hit (:base :ya-stance)
  (:root :u -0.16) (:knees :flex 45) (:chest :twist -45) (:spine :flex 15) (:arm-r :flex -25 :side 35) (:elbow-r :flex 95)
  (:hand-r :twist 150 :flex 20) (:head :twist 25 :flex -20)
  (:arm-r :flex 90 :side 5) (:elbow-r :flex 0) (:hand-r :twist -35 :flex -85) (:chest :twist 25) (:root :f 0.35 :u -0.12)
  (:thigh-l :flex 55) (:knee-l :flex 40) (:thigh-r :flex -25) (:head :twist 0 :flex -15))
(defstrike :ya-shiranui-throw (6 2 20 :base :ya-stance)  ; flings the fireball forward
  (0 (:root :u -0.16) (:knees :flex 45) (:chest :twist -45) (:spine :flex 15) (:arm-r :flex -25 :side 35) (:elbow-r :flex 95)
     (:hand-r :twist 150 :flex 20) (:head :twist 25 :flex -20))
  (3 (:root :u -0.19) (:knees :flex 50) (:chest :twist -53) (:arm-r :flex -30 :side 40) (:head :twist 28))
  (:s :snap :ya-throw-hit)
  (7 (:chest :twist 33) (:arm-r :flex 94) (:root :f 0.39) (:spine :flex 18))
  (:a (:chest :twist 29) (:arm-r :flex 92) (:root :f 0.37) (:spine :flex 17))
  (17 (:chest :twist 8) (:arm-r :flex 50 :side 12) (:elbow-r :flex 25) (:hand-r :twist -15 :flex -55) (:root :f 0.15 :u -0.08)
      (:spine :flex 12) (:thigh-l :flex 32) (:knee-l :flex 30) (:thigh-r :flex -14) (:knee-r :flex 24))
  (:end :ya-stance))
(defpose :ya-taimatsu-hit (:base :ya-stance)
  (:root :u -0.2) (:chest :twist 50) (:arm-r :side -20 :flex 40) (:elbow-r :flex 15) (:hand-r :twist 55 :flex -80)
  (:knees :flex 50) (:spine :flex 22)
  (:root :u 0.0 :f 0.3) (:chest :twist -40) (:arm-r :side 70 :flex 110) (:hand-r :twist 5 :flex -70) (:spine :flex -10)
  (:knees :flex 20) (:head :flex -25))
(defstrike :ya-taimatsu (16 8 24 :base :ya-stance)     ; Taimatsu: a torch-sweep upward, cone of fire
  (0)
  (8 (:root :u -0.2) (:chest :twist 50) (:arm-r :side -20 :flex 40) (:elbow-r :flex 15) (:hand-r :twist 55 :flex -80)
     (:knees :flex 50) (:spine :flex 22) (:head :flex -10))
  (13 (:root :u -0.23) (:chest :twist 57) (:arm-r :side -24 :flex 36) (:knees :flex 55) (:spine :flex 25))
  (:s :snap :ya-taimatsu-hit (:thigh-r :flex -20))
  (18 (:chest :twist -52) (:arm-r :side 83 :flex 118) (:spine :flex -13) (:root :u 0.02 :f 0.33) (:head :flex -28))
  (:a (:chest :twist -48) (:arm-r :side 80 :flex 115) (:spine :flex -11) (:root :u 0.01 :f 0.31) (:head :flex -26))
  (36 (:chest :twist -18) (:arm-r :side 35 :flex 60) (:elbow-r :flex 25) (:hand-r :flex -50) (:spine :flex 2)
      (:root :u -0.03 :f 0.12) (:knees :flex 22) (:head :flex -20))
  (:end :ya-stance))
(defpose :ya-nadegiri-hit (:base :ya-stance)
  (:root :u -0.3) (:knees :flex 60) (:thighs :flex 45) (:spine :flex 25) (:chest :twist 60) (:arm-r :side -10 :flex 60)
  (:elbow-r :flex 20) (:hand-r :twist 55 :flex -80)
  (:root :u -0.33) (:chest :twist 68)
  (:chest :twist -75) (:arm-r :side 90 :flex 30) (:hand-r :twist 5 :flex -70) (:root :u -0.15 :f 0.8) (:spine :flex 10)
  (:thigh-l :flex 60) (:knee-l :flex 50) (:thigh-r :flex -20) (:knee-r :flex 30))
(defstrike :ya-nadegiri (20 4 30 :base :ya-stance)     ; Nadegiri: one crouched, killing horizontal stroke
  (0)
  (10 (:root :u -0.3) (:knees :flex 60) (:thighs :flex 45) (:spine :flex 25) (:chest :twist 60) (:arm-r :side -10 :flex 60)
      (:elbow-r :flex 20) (:hand-r :twist 55 :flex -80) (:head :flex -8))
  (17 (:root :u -0.33) (:chest :twist 68) (:knees :flex 63) (:spine :flex 27) (:arm-r :side -13))
  (:s :snap :ya-nadegiri-hit (:head :flex -12))
  (22 (:chest :twist -84) (:arm-r :side 97 :flex 27) (:root :f 0.86) (:spine :flex 12))
  (:a (:chest :twist -79) (:arm-r :side 94 :flex 28) (:root :f 0.83) (:spine :flex 11))
  (40 (:chest :twist -78) (:arm-r :side 92))
  (47 (:chest :twist -35) (:arm-r :side 45 :flex 35) (:elbow-r :flex 25) (:hand-r :flex -55) (:root :u -0.08 :f 0.35)
      (:spine :flex 12) (:thigh-l :flex 32) (:knee-l :flex 34) (:thigh-r :flex -10) (:knee-r :flex 24))
  (:end :ya-stance))
;; O, ENJO: the blade points along the lane (f4, the walls start rising), held, then swept down (f20)
(defpose :ya-enjo-hit (:base :ya-stance)
  (:chest :twist -10) (:arm-r :flex 88 :side 0) (:elbow-r :flex 0) (:hand-r :twist 0 :flex -88) (:spine :flex 6)
  (:root :u -0.05) (:head :flex -10)
  (:chest :twist -12) (:arm-r :flex 120 :side 5) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -60) (:spine :flex -4)
  (:root :u 0.02)
  (:root :u -0.2 :f 0.2) (:spine :flex 38) (:arm-r :flex 25 :side 10) (:elbow-r :flex 0) (:hand-r :twist -10 :flex -35)
  (:knees :flex 50) (:thigh-l :flex 50) (:head :flex -25))
(defstrike :ya-enjo (20 2 30 :base :ya-stance)
  (0)
  (4 (:chest :twist -10) (:arm-r :flex 88 :side 0) (:elbow-r :flex 0) (:hand-r :twist 0 :flex -88) (:spine :flex 6)
     (:root :u -0.05) (:head :flex -10))
  (11 (:chest :twist -11) (:arm-r :flex 90) (:root :u -0.06))
  (15 (:chest :twist -12) (:arm-r :flex 120 :side 5) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -60) (:spine :flex -4)
      (:root :u 0.02) (:head :flex -18))
  (17 (:arm-r :flex 126) (:elbow-r :flex 13) (:spine :flex -7) (:root :u 0.04) (:head :flex -22))
  (:s :snap :ya-enjo-hit)
  (21 (:spine :flex 42) (:root :u -0.23) (:arm-r :flex 21) (:hand-r :flex -31))
  (:a (:spine :flex 40) (:root :u -0.22) (:arm-r :flex 24) (:hand-r :flex -34))
  (36 (:spine :flex 24) (:root :u -0.12 :f 0.1) (:arm-r :flex 30 :side 14) (:elbow-r :flex 22) (:hand-r :flex -40)
      (:knees :flex 34) (:thigh-l :flex 32) (:head :flex -20))
  (:end :ya-stance))
(defclip :ya-breaker (0.4 :loop t :base :ya-stance)    ; Breaker aura dash: hunched charge, blade trailing
  (0 (:spine :flex 30) (:head :flex -30) (:arm-r :flex -35 :side 30) (:elbow-r :flex 20) (:hand-r :twist 150 :flex 10)
     (:thigh-r :flex 45) (:knee-r :flex 20) (:thigh-l :flex -30) (:knee-l :flex 45) (:root :u -0.1))
  (0.2 (:spine :flex 30) (:head :flex -30) (:thigh-l :flex 45) (:knee-l :flex 20) (:thigh-r :flex -30) (:knee-r :flex 45)
       (:root :u -0.06)))
(defpose :ya-ikkotsu-hit (:base :ya-stance)
  (:root :u -0.1) (:chest :twist -40) (:arm-r :flex 10 :side 15) (:elbow-r :flex 120) (:hand-r :flex 0 :twist 0)
  (:arm-r :flex 90 :side 0) (:elbow-r :flex 0) (:hand-r :flex 0 :twist 0) (:chest :twist 35) (:spine :flex 15)
  (:root :f 0.0 :u -0.15) (:thigh-l :flex 50) (:knee-l :flex 45) (:thigh-r :flex -20))
(defstrike :ya-ikkotsu (8 4 18 :base :ya-stance)       ; Ikkotsu: sword planted (draw it with DRAW-PLANTED-WEAPON), one punch
  (0 (:root :u -0.1) (:chest :twist -40) (:arm-r :flex 10 :side 15) (:elbow-r :flex 120) (:hand-r :flex 0 :twist 0))
  (5 (:root :u -0.14) (:chest :twist -48) (:arm-r :flex 6 :side 18) (:elbow-r :flex 126) (:spine :flex 12) (:knees :flex 30))
  (:s :snap :ya-ikkotsu-hit)
  (9 (:chest :twist 42) (:root :f 0.03) (:spine :flex 18) (:arm-r :flex 93))
  (:a (:chest :twist 38) (:root :f 0.02) (:spine :flex 16) (:arm-r :flex 91))
  (24 (:arm-r :flex 45 :side 10) (:elbow-r :flex 20) (:hand-r :flex -20) (:chest :twist 5) (:spine :flex 30) (:root :u -0.2))
  (:end :ya-stance))
(defclip :ya-kikon (1.8 :base :ya-stance)              ; Jokaku Enjo: raise the blade, sweep, the fire dome detonates
  (0)
  (0.3 (:arm-r :flex 100 :side 0) (:elbow-r :flex 70) (:hand-r :twist 90 :flex -10) (:spine :flex 0) (:head :flex -10))
  (0.9 (:arm-r :flex 105) (:root :u 0.02))
  (1.2 (:chest :twist -40) (:arm-r :side 70 :flex 90) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -80))
  (1.3 :snap (:chest :twist 40) (:arm-r :side -10 :flex 40) (:hand-r :twist -15 :flex -75) (:spine :flex 22) (:root :u -0.15))
  (1.8 :ya-stance))

;;; ---------------------------------------------------------------- intro / win / Hellfire
(defpose :ya-lean (:base :ya-stance)                   ; leaning on the cane, planted in front
  (:root :u -0.02) (:pelvis :twist 0) (:chest :twist 0) (:spine :flex 14) (:head :flex -6)
  (:arm-r :flex 40 :side 8) (:elbow-r :flex 35) (:hand-r :twist 150 :flex 10)
  (:thigh-r :flex 0 :side 6) (:thigh-l :flex 0 :side 6) (:knees :flex 8))
(defclip :ya-intro (2.0 :base :ya-lean)                ; weapon :ya-cane until 1.35 s, then :ryujin-jakka
  (0) (1.1 (:head :flex -12))
  (1.3 (:chest :twist -30) (:arm-r :flex 60 :side 40) (:elbow-r :flex 60) (:hand-r :twist 0 :flex -40))
  (1.45 :snap (:chest :twist 20) (:arm-r :side 70 :flex 60) (:elbow-r :flex 10) (:hand-r :twist 5 :flex -80) (:root :u -0.06))
  (2.0 :ya-stance))
(defclip :ya-win (2.0 :base :ya-stance)                ; blade raised upright before the face, then lowered; holds
  (0)
  (0.6 (:arm-r :flex 70 :side -10) (:elbow-r :flex 90) (:hand-r :twist 90 :flex -10) (:spine :flex 0) (:head :flex 0))
  (1.3 (:arm-r :flex 72))
  (1.8 :ya-lean (:arm-r :flex 35 :side 10) (:elbow-r :flex 20) (:hand-r :twist 150 :flex 10) (:head :flex -4))
  (2.0 :ya-lean (:arm-r :flex 35 :side 10) (:elbow-r :flex 20) (:hand-r :twist 150 :flex 10) (:head :flex -4)))
(defclip :ya-hellfire (1.0 :base :ya-stance)           ; Hellfire entry: crouch, then flare out
  (0)
  (0.25 (:root :u -0.2) (:knees :flex 55) (:spine :flex 30) (:arm-r :flex 20 :side 10) (:elbow-r :flex 60) (:head :flex 10))
  (0.4 :snap (:root :u 0.0) (:spine :flex -12) (:head :flex -30) (:arm-r :side 80 :flex 20) (:elbow-r :flex 10)
       (:hand-r :twist 0 :flex -90) (:arm-l :side 45))
  (0.75 (:spine :flex -10) (:arm-r :side 82))
  (1.0 :ya-stance))

;;; ---------------------------------------------------------------- Bankai (Zanka no Tachi) kit
(defclip :ya-bankai (2.2 :base :ya-stance)             ; the blade raised: every fire drawn into it; then ready
  (0)
  (0.4 (:arm-r :flex 175 :side 5) (:elbow-r :flex 5) (:hand-r :twist 0 :flex -10) (:spine :flex -8) (:head :flex -30)
       (:root :u 0.02))
  (1.4 (:arm-r :flex 178) (:head :flex -32))
  (1.7 (:arm-r :flex 60 :side 10) (:elbow-r :flex 20) (:hand-r :twist 5 :flex -80) (:spine :flex 12) (:head :flex -12))
  (2.2 :ya-stance))
;; The Bankai's own clips (docs/duel/DUEL_YAMA_TYBW.md §3.2's right column; motion bars docs/research/yamamoto-rework/
;; motion-refs.md §5.3-§5.5): East / West / South / North each at its own move's frames, never a Shikai clip. One arm
;; (the right); planes and hands, none shared: E1 J1 horizontal R->L forehand, E2 J2 rising L->R backhand, E3 J3 rising
;; thrust (point), E4 K1 diagonal down R->L forehand, E5 K2 vertical up (forehand), E6 K3 vertical down, E7 L the level
;; lunge thrust (point), E8 SP1 diagonal down L->R backhand, B1 SP2 point-down plant, B2 O rising R->L pass (forehand,
;; the body travelling), W1 L no swing, W2 SP1 no swing, W3 the counter horizontal L->R backhand at the chest. Turns are
;; root yaw (+ = to his left) with a pelvis roll; every hit pose is on S, and where the move's volume is a line ahead (a
;; :cap) the blade crosses his centre line there. The tips at S are the volumes' edges (yama.lisp).
(defpose :ya-e-stance ()                               ; East / West idle: the Bankai straightens him; the blade hangs low,
  (:root :u -0.02) (:pelvis :twist 6) (:spine :flex -4) (:chest :twist -4 :flex -4) (:neck :flex -4) (:head :flex -4)
  (:arm-r :flex 16 :side 14) (:elbow-r :flex 18) (:hand-r :twist 0 :flex -80)                 ; point down-forward
  (:arm-l :flex 2 :side 8) (:elbow-l :flex 0)
  (:thigh-r :flex -4 :side 8) (:thigh-l :flex 10 :side 6) (:knee-r :flex 8) (:knee-l :flex 12))
(defclip :ya-e-stance (2.4 :loop t :base :ya-e-stance)
  (0) (1.2 (:chest :flex -7) (:root :u -0.03) (:hand-r :flex -77)))

;; E1 J1 HIZASHI: a deep fencer's lunge (the right foot far forward, the rear leg straight), a level cut at face height
;; right to left; at S the blade crosses his centre line 1.5 m ahead (tip ahead 1.52)
(defpose :ya-e-q1-hit (:base :ya-e-stance)
  (:root :yaw 14 :f 0.1 :u -0.24) (:pelvis :twist 0 :side -6) (:spine :flex 14) (:chest :twist -6 :flex 0)
  (:neck :flex 0) (:head :flex 6 :twist -10) (:arm-l :flex -30 :side 30)
  (:thigh-r :flex 70 :side 4) (:knee-r :flex 76) (:thigh-l :flex -40 :side 6) (:knee-l :flex 6)
  (:arm-r :flex 130 :side -30) (:elbow-r :flex 60) (:hand-r :twist 150 :flex 10))
(defstrike :ya-e-q1 (8 3 12 :base :ya-e-stance)
  (0)
  (4 (:root :yaw -14 :f -0.04 :u -0.1) (:pelvis :side 4) (:spine :flex 2) (:chest :twist -28) (:head :twist 18)   ; drawn
     (:arm-r :flex 120 :side 60) (:elbow-r :flex 70) (:hand-r :twist 205 :flex -105)            ; back right, level
     (:thigh-r :flex 30) (:knee-r :flex 45) (:thigh-l :flex 0) (:knee-l :flex 18))
  (6 (:root :yaw -18) (:chest :twist -32) (:arm-r :side 64))                                    ; held: the front knee up
  (7 (:root :yaw 0 :f 0.04 :u -0.18) (:pelvis :side 0) (:spine :flex 8) (:chest :twist -18) (:head :twist 4)   ; level,
     (:arm-r :flex 126 :side 20) (:elbow-r :flex 66) (:hand-r :twist 230 :flex -20)            ; out to his right
     (:thigh-r :flex 55) (:knee-r :flex 60) (:thigh-l :flex -20) (:knee-l :flex 10))
  (:s :snap :ya-e-q1-hit)
  (9 (:root :yaw 22 :f 0.12) (:chest :twist 10) (:head :twist -18) (:arm-l :flex -34 :side 34)  ; on through, left
     (:arm-r :flex 120 :side -50) (:elbow-r :flex 40) (:hand-r :twist 145 :flex -10))
  (:a (:root :yaw 21) (:chest :twist 8))
  (16 (:root :yaw 8 :f 0.05 :u -0.12) (:pelvis :side -2) (:spine :flex 6) (:chest :twist 0) (:head :twist -4)
      (:arm-r :flex 60 :side 10) (:elbow-r :flex 30) (:hand-r :twist 60 :flex -60) (:arm-l :flex -10 :side 14)
      (:thigh-r :flex 34) (:knee-r :flex 38) (:thigh-l :flex -16) (:knee-l :flex 10))
  (:end :ya-e-stance))

;; E2 J2 ZANSHO: from the lunge, a rising backhand low left -> high right; he stands as it rises (the rear foot drawn up)
(defpose :ya-e-q2-hit (:base :ya-e-stance)
  (:root :yaw -6 :f 0.12 :u -0.06) (:pelvis :side 4) (:spine :flex 4) (:chest :twist -10) (:head :twist 6)
  (:arm-r :flex 86 :side 0) (:elbow-r :flex 14) (:hand-r :twist 20 :flex -60) (:arm-l :flex 10 :side 30)
  (:thigh-r :flex 30 :side 4) (:knee-r :flex 32) (:thigh-l :flex 6 :side 6) (:knee-l :flex 24))
(defstrike :ya-e-q2 (7 3 13 :base :ya-e-stance)
  (0 (:root :yaw 20 :f 0.08 :u -0.2) (:pelvis :side -5) (:spine :flex 12) (:chest :twist 30)    ; still in the lunge,
     (:arm-r :flex 40 :side -30) (:elbow-r :flex 30) (:hand-r :twist 10 :flex -110)             ; the blade low at
     (:thigh-r :flex 60 :side 4) (:knee-r :flex 64) (:thigh-l :flex -34 :side 6) (:knee-l :flex 8) ; his left
     (:arm-l :flex -20 :side 20))
  (4 (:chest :twist 38) (:root :yaw 24 :u -0.22) (:arm-r :side -36))                             ; loaded
  (:s :snap :ya-e-q2-hit)
  (9 (:root :yaw -14 :u -0.02) (:spine :flex 0) (:chest :twist -34) (:arm-r :flex 140 :side 60) (:elbow-r :flex 10)
     (:hand-r :twist -125 :flex 45) (:thigh-r :flex 22) (:knee-r :flex 24) (:thigh-l :flex 8) (:knee-l :flex 20)
     (:arm-l :flex 10 :side 40))                                                                ; high right
  (:a (:root :yaw -13) (:arm-r :flex 138))
  (16 (:root :yaw -4 :f 0.05 :u -0.04) (:chest :twist -12) (:arm-r :flex 70 :side 30) (:elbow-r :flex 30)
      (:hand-r :twist -40 :flex -50) (:arm-l :flex 4 :side 16) (:thigh-r :flex 10) (:knee-r :flex 14))
  (:end :ya-e-stance))

;; E3 J3 SENKO (the ender): an underhand rising thrust from a dropped knee, the point travelling up ~27 deg into the body
(defpose :ya-e-q3-hit (:base :ya-e-stance)
  (:root :yaw 16 :f 0.24 :u -0.36) (:pelvis :side -4) (:spine :flex 20) (:chest :twist 6) (:head :flex -6)
  (:arm-r :flex 74 :side 6) (:elbow-r :flex 6) (:hand-r :twist -30 :flex -20) (:arm-l :flex -40 :side 30)
  (:thigh-r :flex 80 :side 4) (:knee-r :flex 92) (:thigh-l :flex -6 :side 6) (:knee-l :flex 84))
(defstrike :ya-e-q3 (8 3 18 :base :ya-e-stance)
  (0)
  (4 (:root :yaw 10 :u -0.3) (:pelvis :side 4) (:spine :flex 16) (:chest :twist -20)            ; sunk, the blade drawn
     (:arm-r :flex -10 :side 20) (:elbow-r :flex 100) (:hand-r :twist -15 :flex -45)            ; back low at the hip,
     (:thigh-r :flex 72 :side 4) (:knee-r :flex 96) (:thigh-l :flex -10 :side 6) (:knee-l :flex 90) ; point up-forward;
     (:arm-l :flex 30 :side 20))                                                                ; the knee dropped
  (6 (:root :u -0.34) (:chest :twist -24) (:arm-r :flex -14))
  (:s :snap :ya-e-q3-hit)
  (10 (:root :f 0.27 :u -0.34) (:arm-r :flex 80) (:hand-r :flex -16) (:chest :twist 8))
  (:a (:root :f 0.26) (:arm-r :flex 78))
  (21 (:root :yaw 8 :f 0.12 :u -0.16) (:spine :flex 10) (:chest :twist 0) (:arm-r :flex 40 :side 12) (:elbow-r :flex 30)
      (:hand-r :twist -10 :flex -60) (:arm-l :flex -10 :side 14)
      (:thigh-r :flex 40) (:knee-r :flex 46) (:thigh-l :flex -2) (:knee-l :flex 36))
  (:end :ya-e-stance))

;; E4 K1 KAGERO: one-armed, a diagonal from over the right shoulder down to his low left; the body turns and steps behind
;; it (the move's slide); at S the blade crosses his centre line going down
(defpose :ya-e-f1-hit (:base :ya-e-stance)
  (:root :yaw 10 :f 0.35 :u -0.2) (:pelvis :side -6) (:spine :flex 22) (:chest :twist -18) (:head :flex 4)
  (:arm-r :flex 110 :side 30) (:elbow-r :flex 10) (:hand-r :twist 165 :flex 65) (:arm-l :flex -30 :side 30)
  (:thigh-r :flex 66 :side 4) (:knee-r :flex 70) (:thigh-l :flex -36 :side 6) (:knee-l :flex 6))
(defstrike :ya-e-f1 (16 4 20 :base :ya-e-stance)
  (0)
  (3 (:root :yaw -8) (:chest :twist -12) (:arm-r :flex 90 :side 50) (:elbow-r :flex 40) (:hand-r :twist -120 :flex -40))  ; up
  (6 (:root :yaw -20 :u -0.04) (:pelvis :side 6) (:spine :flex -6) (:chest :twist -25) (:head :twist 14)   ; over the
     (:arm-r :flex 160 :side 40) (:elbow-r :flex 70) (:hand-r :twist -65 :flex -40)             ; right shoulder,
     (:arm-l :flex 40 :side 10) (:thigh-r :flex 10) (:knee-r :flex 20) (:thigh-l :flex 6) (:knee-l :flex 16)) ; point back up
  (11 (:root :yaw -24 :u -0.02) (:arm-r :flex 168) (:spine :flex -8) (:pelvis :side 8))         ; the tell, held
  (14 (:root :yaw -22 :u -0.06) (:arm-r :flex 166) (:thigh-r :flex 30) (:knee-r :flex 40))       ; the front knee up
  (:s :snap :ya-e-f1-hit)
  (18 (:root :yaw 30 :f 0.38 :u -0.24) (:pelvis :side -8) (:spine :flex 32) (:chest :twist 30)  ; down to the low left
      (:arm-r :flex 60 :side -30) (:hand-r :twist -10 :flex -80) (:arm-l :flex -40 :side 34)
      (:thigh-r :flex 70) (:knee-r :flex 76) (:thigh-l :flex -38))
  (:a (:root :yaw 29) (:spine :flex 31))
  (31 (:root :yaw 10 :f 0.16 :u -0.12) (:pelvis :side -2) (:spine :flex 10) (:chest :twist 6) (:head :twist 0)
      (:arm-r :flex 40 :side 0) (:elbow-r :flex 26) (:hand-r :twist 0 :flex -70) (:arm-l :flex -10 :side 14)
      (:thigh-r :flex 36) (:knee-r :flex 40) (:thigh-l :flex -16) (:knee-l :flex 10))
  (:end :ya-e-stance))

;; E5 K2 NISSHO, the sunrise: the blade from the ground behind him swung up through vertical in front, the body rising
;; with it onto the toes (a step in: the move's slide); at S the blade is level ahead at the chest, rising
(defpose :ya-e-f2-hit (:base :ya-e-stance)
  (:root :yaw 5 :f 0.3 :u -0.08) (:spine :flex 6) (:chest :twist 0) (:head :flex -6)
  (:arm-r :flex 95 :side 6) (:elbow-r :flex 4) (:hand-r :twist -15 :flex -75) (:arm-l :flex -20 :side 30)
  (:thigh-r :flex 46) (:knee-r :flex 44) (:thigh-l :flex -24) (:knee-l :flex 14))
(defstrike :ya-e-f2 (19 4 24 :base :ya-e-stance)
  (0)
  (8 (:root :yaw -20 :u -0.3) (:pelvis :side 6) (:spine :flex 30) (:chest :twist -20) (:head :flex -14)   ; crouched,
     (:arm-r :flex -30 :side 20) (:elbow-r :flex 10) (:hand-r :twist -5 :flex -75)              ; the tip on the plaza
     (:thigh-r :flex 50) (:knee-r :flex 80) (:thigh-l :flex 60) (:knee-l :flex 84) (:arm-l :flex 40 :side 20)) ; behind
  (15 (:root :yaw -24 :u -0.33) (:spine :flex 33) (:arm-r :flex -34))                           ; held: the tell
  (:s :snap :ya-e-f2-hit)
  (21 (:root :yaw 5 :f 0.32 :u 0.0) (:spine :flex -12) (:head :flex -16) (:arm-r :flex 175) (:hand-r :twist -5 :flex -95)
      (:thigh-r :flex 30) (:knee-r :flex 20) (:thigh-l :flex -24) (:knee-l :flex 6) (:arm-l :flex -20 :side 40))  ; vertical
  (:a (:root :u 0.0) (:arm-r :flex 172))
  (35 (:root :yaw 2 :f 0.14 :u -0.04) (:spine :flex 0) (:head :flex -6) (:arm-r :flex 90 :side 14) (:elbow-r :flex 30)
      (:hand-r :twist -10 :flex -80) (:arm-l :flex -4 :side 16) (:thigh-r :flex 16) (:knee-r :flex 16) (:thigh-l :flex -8))
  (:end :ya-e-stance))

;; E6 K3 RAKUJITSU (the ender), the setting sun: the blade straight up in the one hand, held (the tell), then dropped in a
;; vertical arc with a step (the move's slide); level ahead at S, its tip on the plaza two frames later (main.lisp
;; MOVE-BEATS: the embers and the scorch there)
(defpose :ya-e-drop-hit (:base :ya-e-stance)
  (:root :f 0.3 :u -0.15) (:spine :flex 22) (:head :flex 0)
  (:arm-r :flex 122 :side -4) (:elbow-r :flex 0) (:hand-r :twist 0 :flex -100)
  (:thigh-r :flex 60) (:knee-r :flex 66) (:thigh-l :flex -30) (:knee-l :flex 10) (:arm-l :flex -20 :side 24))
(defstrike :ya-e-drop (21 5 34 :base :ya-e-stance)
  (0)
  (8 (:root :u 0.0) (:spine :flex -10) (:head :flex -12) (:arm-r :flex 175 :side 4) (:elbow-r :flex 6)    ; straight up
     (:hand-r :twist -5 :flex -95) (:thigh-l :flex 20) (:knee-l :flex 20) (:arm-l :flex 10 :side 16))
  (17 (:root :u 0.01) (:arm-r :flex 180) (:spine :flex -13) (:head :flex -14))                  ; held: the tell
  (19 (:root :u -0.02 :f 0.06) (:thigh-r :flex 30) (:knee-r :flex 30))                          ; the front foot lifts
  (:s :snap :ya-e-drop-hit)
  (23 (:root :f 0.34 :u -0.24) (:spine :flex 40) (:arm-r :flex 80) (:hand-r :flex -65)          ; the plaza
      (:thigh-r :flex 70) (:knee-r :flex 80) (:knee-l :flex 14))
  (:a (:root :u -0.23) (:spine :flex 39))
  (44 (:spine :flex 34) (:root :u -0.2 :f 0.32))                                                ; zanshin
  (52 (:spine :flex 12) (:root :u -0.08 :f 0.14) (:arm-r :flex 40 :side 12) (:elbow-r :flex 24) (:hand-r :flex -75)
      (:thigh-r :flex 26) (:knee-r :flex 30) (:thigh-l :flex -10) (:knee-l :flex 10))
  (:end :ya-e-stance))

;; E7 L KYOKKO: the longest lunge in the game (the move's 1.6 m slide), the body near horizontal, the point level at the
;; chest, the free sleeve flung back; the edge line flares on f1 (yama.lisp YAMA-KYOKKO-FLARE)
(defpose :ya-e-kyokko-hit (:base :ya-e-stance)
  (:root :f 0.6 :u -0.34) (:spine :flex 46) (:chest :twist 0) (:head :flex -40)
  (:arm-r :flex 160 :side 4) (:elbow-r :flex 0) (:hand-r :twist -10 :flex -105)
  (:arm-l :flex -70 :side 20) (:thigh-r :flex 80) (:knee-r :flex 80) (:thigh-l :flex -50) (:knee-l :flex 0))
(defstrike :ya-e-kyokko (15 3 26 :base :ya-e-stance)
  (0)
  (6 (:root :yaw -20 :u -0.12) (:pelvis :side 5) (:spine :flex 8) (:chest :twist -10) (:head :twist 16)   ; chambered:
     (:arm-r :flex 0 :side 60) (:elbow-r :flex 120) (:hand-r :twist -10 :flex -95)              ; the hilt at his right
     (:arm-l :flex 50 :side 10) (:thighs :flex 30) (:knees :flex 40))                           ; side, the point at him
  (12 (:root :yaw -24 :u -0.16) (:arm-r :side 64) (:elbow-r :flex 126) (:knees :flex 46))
  (:s :snap :ya-e-kyokko-hit)
  (17 (:root :f 0.62) (:spine :flex 48))
  (:a (:root :f 0.61))
  (30 (:root :f 0.4 :u -0.24) (:spine :flex 30) (:head :flex -24) (:arm-r :flex 90) (:hand-r :flex -90)
      (:arm-l :flex -30 :side 16) (:thigh-r :flex 60) (:knee-r :flex 64) (:thigh-l :flex -30) (:knee-l :flex 8))
  (:end :ya-e-stance))

;; E8 SP1 KYOKUJITSUJIN: the blade raised high over the left shoulder, angled, then one backhand diagonal down to his low
;; right (S18: it crosses his centre line), ending with only the tip touching the plaza ahead (f20: the heat sheet runs
;; from there)
(defpose :ya-kyoku-hit (:base :ya-e-stance)
  (:root :yaw 6 :f 0.25 :u -0.15) (:pelvis :side 4) (:chest :twist 10) (:spine :flex 24)
  (:arm-r :flex 104 :side -24) (:elbow-r :flex 10) (:hand-r :twist -10 :flex -100)
  (:thigh-r :flex 60) (:knee-r :flex 66) (:thigh-l :flex -30) (:knee-l :flex 10) (:arm-l :flex -20 :side 24))
(defpose :ya-kyoku-bite (:base :ya-kyoku-hit)
  (:root :yaw -6 :f 0.3 :u -0.25) (:pelvis :side 6) (:chest :twist -6) (:spine :flex 34)
  (:arm-r :flex 86 :side -6) (:elbow-r :flex 4) (:hand-r :twist -10 :flex -90)
  (:thigh-r :flex 70) (:knee-r :flex 80) (:knee-l :flex 16))
(defstrike :ya-kyoku (18 5 26 :base :ya-e-stance)
  (0)
  (8 (:root :yaw 20) (:pelvis :side -5) (:chest :twist 35) (:spine :flex -6) (:head :twist -12)   ; over the left
     (:arm-r :flex 140 :side 20) (:elbow-r :flex 60) (:hand-r :twist 35 :flex -110)             ; shoulder, angled
     (:thigh-l :flex 22) (:knee-l :flex 22))
  (15 (:root :yaw 24 :u 0.01) (:chest :twist 38) (:arm-r :flex 145) (:spine :flex -8))         ; held
  (:s :snap :ya-kyoku-hit)
  (20 :snap :ya-kyoku-bite)
  (22 (:root :u -0.27) (:spine :flex 36))
  (32 (:root :u -0.25) (:spine :flex 34))
  (40 (:root :yaw -2 :f 0.14 :u -0.12) (:spine :flex 14) (:chest :twist 0) (:arm-r :flex 40 :side 12) (:elbow-r :flex 24)
      (:hand-r :twist 0 :flex -70) (:thigh-r :flex 30) (:knee-r :flex 34) (:thigh-l :flex -12) (:knee-l :flex 10))
  (:end :ya-e-stance))

;; B1 SP2 MINAMI (South): the blade lifted upright before his face, point down, the hilt at the chin (the incantation, the
;; tell), then driven straight down into the plaza (S20) in a half kneel; the skeleton hands claw out under the opponent
(defpose :ya-kaka-hit (:base :ya-e-stance)
  (:root :u -0.36) (:spine :flex 22) (:chest :twist 14) (:head :flex 6)
  (:arm-r :flex 112 :side -24) (:elbow-r :flex 16) (:hand-r :twist -150 :flex 0)
  (:thigh-r :flex -6) (:knee-r :flex 100) (:thigh-l :flex 84) (:knee-l :flex 88) (:arm-l :flex 10 :side 20))
(defstrike :ya-kaka (20 1 34 :base :ya-e-stance)
  (0)
  (9 (:root :u 0.02) (:spine :flex -6) (:chest :twist 20) (:head :flex 4)                         ; upright before the
     (:arm-r :flex 70 :side -40) (:elbow-r :flex 110) (:hand-r :twist -140 :flex -80))          ; face, point down
  (16 (:root :u 0.04) (:arm-r :flex 74) (:spine :flex -8) (:head :flex 2))                      ; held: the words
  (:s :snap :ya-kaka-hit)
  (:a (:root :u -0.37) (:spine :flex 23))
  (30 (:root :u -0.36) (:spine :flex 22))
  (45 (:root :u -0.33) (:spine :flex 20))
  (:end :ya-e-stance))

;; B2 O KITA: TENCHI in play (after the :sh-run flash step): the flame gathered on the blade trailing low behind him, one
;; huge passing cut rising from his low right across to his high left with the body travelling through it (the cine's
;; :ya-tenchi is the slow horizontal version)
(defpose :ya-e-tenchi-hit (:base :ya-e-stance)
  (:root :yaw 8 :f 0.62 :u -0.28) (:pelvis :side -6) (:spine :flex 20) (:chest :twist 4) (:head :flex -4)
  (:arm-r :flex 110 :side 10) (:elbow-r :flex 0) (:hand-r :twist -15 :flex -60)
  (:arm-l :flex -60 :side 30) (:thigh-r :flex 76) (:knee-r :flex 80) (:thigh-l :flex -44) (:knee-l :flex 4))
(defstrike :ya-e-tenchi (6 2 26 :base :ya-e-stance)
  (0 (:root :yaw -15 :u -0.15) (:spine :flex 30) (:head :flex -16) (:arm-r :flex -40 :side 30) (:elbow-r :flex 10)
     (:hand-r :twist 5 :flex -75) (:arm-l :flex 40) (:thigh-r :flex 40) (:knee-r :flex 50) (:thigh-l :flex -20) (:knee-l :flex 30))
  (3 (:root :yaw -20 :u -0.2) (:arm-r :flex -46) (:spine :flex 34))                              ; trailing low behind
  (5 (:root :yaw -8 :f 0.3 :u -0.24) (:spine :flex 26) (:arm-r :flex 40 :side 30) (:elbow-r :flex 4)  ; low right
     (:hand-r :twist -50 :flex -80) (:thigh-r :flex 60) (:knee-r :flex 66) (:thigh-l :flex -30) (:knee-l :flex 10))
  (:s :snap :ya-e-tenchi-hit)
  (8 (:root :yaw 35 :f 0.62 :u -0.26) (:spine :flex 10) (:chest :twist 40) (:arm-r :flex 150 :side -40)   ; high left
     (:hand-r :twist 40 :flex -90) (:arm-l :flex -60 :side 34))
  (20 (:root :yaw 30 :f 0.6 :u -0.27) (:chest :twist 34) (:arm-r :flex 144))                    ; held
  (:end :ya-e-stance))

;; W1 L SHONETSU JIGOKU: no swing. The arms open (the blade out low to his right, the empty sleeve flaring left), head
;; back, chest out, the feet sunk apart: the garb flares up over the startup (the tell), the pillars erupt at S
(defpose :ya-shonetsu-hit (:base :ya-e-stance)
  (:root :u -0.08) (:spine :flex -18) (:neck :flex -12) (:head :flex -16)
  (:arm-r :flex 20 :side 74) (:elbow-r :flex 10) (:hand-r :twist 10 :flex -110)
  (:arm-l :flex 14 :side 88) (:thighs :side 14) (:knees :flex 20))
(defstrike :ya-shonetsu (16 0 24 :base :ya-e-stance)
  (0)
  (6 (:root :u -0.1) (:spine :flex 6) (:head :flex 4) (:arm-r :flex 10 :side 24) (:hand-r :flex -70) (:arm-l :side 20)
     (:knees :flex 26))   ; in
  (12 (:root :u -0.12) (:spine :flex 10) (:head :flex 8) (:arm-r :side 30) (:arm-l :side 26) (:knees :flex 30))         ; drawn
  (:s :snap :ya-shonetsu-hit)
  (22 (:root :u -0.09) (:arm-r :side 76) (:arm-l :side 90))
  (32 (:root :u -0.05) (:spine :flex -6) (:head :flex -6) (:arm-r :flex 18 :side 30) (:arm-l :flex 4 :side 30)
      (:thighs :side 10) (:knees :flex 14))
  (:end :ya-e-stance))

;; W2 SP1 GOKUI GAESHI: he stands still, chin up, the blade low: what hits him is erased on his body (no blade parry)
(defpose :ya-w-parry-hit (:base :ya-e-stance)
  (:spine :flex -8) (:chest :flex -6) (:neck :flex -8) (:head :flex -12)
  (:arm-r :flex 8 :side 16) (:elbow-r :flex 10) (:hand-r :twist 10 :flex -68))
(defstrike :ya-w-parry (2 24 20 :base :ya-e-stance)
  (0)
  (:s :snap :ya-w-parry-hit)
  (14 (:chest :flex -7) (:root :u 0.01))
  (:a (:chest :flex -6) (:root :u 0.0))
  (36 (:spine :flex -6) (:neck :flex -6) (:head :flex -8))
  (:end :ya-e-stance))

;; W3 the counter: out of the stillness a short backhand left -> right at the chest with one step (the move's slide),
;; crossing ahead at S, then rooted again
(defpose :ya-w-counter-hit (:base :ya-w-parry-hit)
  (:root :yaw -4 :f 0.35 :u -0.12) (:pelvis :side 4) (:chest :twist 4 :flex 0) (:spine :flex 12) (:neck :flex 0)
  (:head :flex -4) (:arm-r :flex 95 :side 10) (:elbow-r :flex 4) (:hand-r :twist 0 :flex -75) (:arm-l :flex 10 :side 40)
  (:thigh-r :flex 50) (:knee-r :flex 56) (:thigh-l :flex -26) (:knee-l :flex 10))
(defstrike :ya-w-counter (6 3 24 :base :ya-e-stance)
  (0 :ya-w-parry-hit)
  (3 (:root :yaw 10 :u -0.08) (:pelvis :side -4) (:chest :twist 35) (:arm-r :flex 50 :side -40) (:elbow-r :flex 60)  ; across
     (:hand-r :twist 145 :flex -30) (:arm-l :flex 20 :side 20) (:thigh-r :flex 20) (:knee-r :flex 26))   ; to his left hip
  (4 (:root :yaw 12) (:chest :twist 38))
  (:s :snap :ya-w-counter-hit)
  (8 (:root :yaw -25 :f 0.38) (:chest :twist -30) (:spine :flex 10) (:arm-r :flex 95 :side 70) (:hand-r :twist -25 :flex -115)
     (:arm-l :flex 10 :side 46))                                                                ; out to his right
  (:a (:root :yaw -24) (:chest :twist -28))
  (21 (:root :yaw -8 :f 0.14 :u -0.06) (:pelvis :side 0) (:chest :twist -8) (:spine :flex 2) (:arm-r :flex 40 :side 30)
      (:elbow-r :flex 20) (:hand-r :twist -10 :flex -75) (:arm-l :flex 4 :side 16)
      (:thigh-r :flex 18) (:knee-r :flex 22) (:thigh-l :flex -6) (:knee-l :flex 10))
  (:end :ya-e-stance))
(defclip :ya-tenchi (1.3 :base :ya-stance)             ; North: Tenchi Kaijin, one slash (the cinematic's; in play :ya-e-tenchi)
  (0)
  (0.25 (:root :u -0.2) (:chest :twist -70) (:arm-r :side 90 :flex 10) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -90)
        (:knees :flex 45) (:spine :flex 20))
  (0.3 :snap (:chest :twist 70) (:arm-r :flex 60 :side -20) (:hand-r :twist -25 :flex -60) (:root :f 0.8 :u -0.3)
       (:spine :flex 35) (:thigh-l :flex 60) (:knee-l :flex 60) (:thigh-r :flex -25))
  (0.9 (:chest :twist 72) (:root :f 0.8 :u -0.28))
  (1.3 :ya-stance))

;;; ---------------------------------------------------------------- South's hands (Kaka Jumanokushi Daisojin)
(defpose :sk-crouch ()
  (:root :u -0.2) (:spine :flex 25) (:head :flex -20) (:arms :flex 50 :side 25) (:elbows :flex 60)
  (:thighs :flex 30) (:knees :flex 50))
(defclip :sk-grab (1.53 :base :sk-crouch)              ; South: the hips under the plaza, the arms claw out (8 f), clench on
  (0 (:root :u -2.3) (:arms :flex 170 :side 15) (:elbows :flex 10) (:spine :flex -5) (:head :flex -40))  ; the ankles, hold,
  (0.13 :snap (:root :u -1.3) (:arms :flex 150 :side 25) (:elbows :flex 25) (:spine :flex 10) (:head :flex -20))   ; crumble
  (0.25 (:root :u -1.28) (:arms :flex 118 :side 30) (:elbows :flex 70) (:spine :flex 25))
  (1.13 (:root :u -1.3) (:arms :flex 122 :side 28) (:elbows :flex 65) (:spine :flex 22))
  (1.53 (:root :u -2.3) (:arms :flex 90 :side 20) (:elbows :flex 30) (:spine :flex 40)))

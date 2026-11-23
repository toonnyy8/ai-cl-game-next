;;;; yama-art.lisp — YAMAMOTO GENRYUSAI (TYBW) as art data: his body, his three weapons (the cane
;;;; he leans on, Ryujin Jakka, the charred Bankai blade Zanka no Tachi), the charred :skeleton of
;;;; Bankai South, and every :ya-* / :sk-* pose and clip (design §5.1). Attack clips use DEFSTRIKE,
;;;; so each reaches its hit pose at frame S and is back in :ya-stance at S+A+R. Pose to pose (style §2.6,
;;;; *key-ease* 1): a wind-up held a few frames, a :snap into the named hit pose :ya-*-hit at :s (the blade
;;;; where the move's hit volume is), a small overshoot held through :a, a half-way recovery, the stance.
;;;; Look: 1.68 m, hunched, bald + X scar, long white brows, waist-length beard bound by a purple cord lattice,
;;;; black shihakusho + the white captain's haori draped as a cape (一 in a rhombus on the back), no left forearm (empty
;;;; sleeve); Hellfire bared to the waist, the Bankai in the burnt TYBW robe (the body section).
(in-package :duel)

;;; ---------------------------------------------------------------- body
;; Proportions (user review 1: realistic, not chibi): a narrow head (the girth factors), a lean chest,
;; arms to mid-thigh (:props :arms, the arm shapes as long), bigger hands, a slighter hunch.
;; The TYBW look (docs/duel/DUEL_YAMA_TYBW.md §3.1; canon: docs/research/yamamoto-rework/canon-looks.md §1-§4): the
;; captain's haori DRAPED over both shoulders as a cape (tag :haori: the shoulder pads, the upper back and lapels on the
;; chest, its empty sleeves hanging at the sides, the lower cape on the pelvis down to the shins, lined in deep purple
;; #441F58, 一 in a rhombus on the back, slits at the hem's sides), the black kosode under it (tag :kosode: the torso and
;; both sleeves); a beard bound by a lattice of cord crossings, brows hanging to the jaw, the X scar on the right of the
;; crown. Three costumes of one rig (BODY-VARIANT, the hurt cylinder shared): this one (Shikai), :YAMAMOTO-BARE (Hellfire:
;; the kit hides :haori and :kosode) and :YAMAMOTO-TYBW (the Bankai: the kit hides :haori). The lower cape swings on the
;; pelvis matrix (yama.lisp YAMA-POSE, a look: the sim never reads a joint).
(defbody :yamamoto (:scale 0.95 :width 1.05 :hunch 14 :hurt-r 0.36 :hurt-h 1.65
                    :props (:arms 1.12)
                    :girth ((:chest 0.86 1.0 0.92) (:spine 0.86 1.0 0.92) (:pelvis 0.9 1.0 0.95)
                            (:upper-arm-r 0.9 1.12 0.9) (:upper-arm-l 0.9 1.12 0.9) (:lower-arm-r 0.9 1.12 0.9)
                            (:hand-r 1.2 1.3 1.2))
                    ;; v4 notan palette (docs/style/STYLE_STORM_DESIGN.md §2.5): a solid black robe, a V4 white
                    ;; haori whose shadow turns cold grey-blue, muted skin (the only warm non-spot colour); the haori's
                    ;; lining sampled from the official RoS art (canon-looks §1)
                    :palette ((:skin #xD8B4A0) (:black #x16161E) (:white #xF0F0EC) (:beard #xECECEA)
                              (:cord #x4A3A6A) (:scar #x7A4A3C) (:obi #xC8CCD6) (:tabi #xE8E8E4)
                              (:sole #x262833) (:mouth #x3A1E1A) (:lid #x1E1818) (:fold #xD8DCE4) (:lining #x441F58))
                    :rim (#xFFB070 0.22))
  ;; the hips and the obi; the lower cape (sizes before the pelvis girth 0.9 / 0.95): its back flaring behind, the two
  ;; sides, the open front (a white edge with the purple lining turned out inside it), every panel lined; two slits and a
  ;; dot cut in each side near the hem (black)
  (:pelvis (:box 0.34 0.18 0.24 :c :black)
           (:box 0.35 0.07 0.25 :at (0 0.06 0) :c :obi)
           (:box 0.7 1.02 0.03 :at (0 -0.35 -0.26) :rot (0 -9 0) :c :white :tag :haori)                 ; back
           (:box 0.66 0.98 0.012 :at (0 -0.35 -0.24) :rot (0 -9 0) :c :lining :tag :haori)
           (:box 0.03 0.98 0.4 :at (0.35 -0.37 -0.03) :rot (0 0 6) :c :white :tag :haori)               ; sides
           (:box 0.03 0.98 0.4 :at (-0.35 -0.37 -0.03) :rot (0 0 -6) :c :white :tag :haori)
           (:box 0.012 0.94 0.38 :at (0.33 -0.37 -0.03) :rot (0 0 6) :c :lining :tag :haori)
           (:box 0.012 0.94 0.38 :at (-0.33 -0.37 -0.03) :rot (0 0 -6) :c :lining :tag :haori)
           (:box 0.1 0.98 0.03 :at (0.33 -0.37 0.18) :rot (0 0 6) :c :white :tag :haori)                ; open front
           (:box 0.1 0.98 0.03 :at (-0.33 -0.37 0.18) :rot (0 0 -6) :c :white :tag :haori)
           (:box 0.08 0.94 0.02 :at (0.255 -0.37 0.17) :rot (0 0 6) :c :lining :tag :haori)
           (:box 0.08 0.94 0.02 :at (-0.255 -0.37 0.17) :rot (0 0 -6) :c :lining :tag :haori)
           (:box 0.014 0.17 0.026 :at (0.405 -0.7 0.09) :rot (0 0 6) :c :black :tag :haori)            ; slits, dot
           (:box 0.014 0.09 0.022 :at (0.41 -0.76 0.0) :rot (0 0 6) :c :black :tag :haori)
           (:box 0.014 0.032 0.032 :at (0.39 -0.55 0.11) :rot (0 0 6) :c :black :tag :haori)
           (:box 0.014 0.17 0.026 :at (-0.405 -0.7 0.09) :rot (0 0 -6) :c :black :tag :haori)
           (:box 0.014 0.09 0.022 :at (-0.41 -0.76 0.0) :rot (0 0 -6) :c :black :tag :haori)
           (:box 0.014 0.032 0.032 :at (-0.39 -0.55 0.11) :rot (0 0 -6) :c :black :tag :haori))
  ;; the kosode's waist; the kosode over the chest (the white under-collar V)
  (:spine (:bevel 0.46 0.25 0.28 0.04 :at (0 0.11 -0.005) :c :black :tag :kosode))
  (:chest (:bevel 0.5 0.3 0.29 0.05 :at (0 0.11 -0.005) :c :black :tag :kosode)
          (:box 0.025 0.2 0.01 :at (0.035 0.15 0.162) :rot (0 0 -22) :c :obi :tag :kosode)          ; under-collar V
          (:box 0.025 0.2 0.01 :at (-0.035 0.15 0.162) :rot (0 0 22) :c :obi :tag :kosode)
          ;; the haori on the shoulders (sizes before the chest girth 0.86 / 0.92): the pads sloping off them, the upper
          ;; back down past the waist, the lapels at the open front (their lining turned out), the empty sleeves hanging
          ;; wide at his sides (white, the purple opening at the front)
          (:bevel 0.32 0.08 0.38 0.03 :at (0.21 0.205 -0.01) :rot (0 0 -14) :c :white :tag :haori)
          (:bevel 0.32 0.08 0.38 0.03 :at (-0.21 0.205 -0.01) :rot (0 0 14) :c :white :tag :haori)
          (:box 0.72 0.56 0.03 :at (0 -0.06 -0.185) :c :white :tag :haori)
          (:box 0.13 0.54 0.03 :at (0.27 -0.05 0.175) :c :white :tag :haori)
          (:box 0.13 0.54 0.03 :at (-0.27 -0.05 0.175) :c :white :tag :haori)
          (:box 0.04 0.54 0.035 :at (0.19 -0.05 0.178) :c :lining :tag :haori)
          (:box 0.04 0.54 0.035 :at (-0.19 -0.05 0.178) :c :lining :tag :haori)
          (:bevel 0.14 0.62 0.42 0.03 :at (0.4 -0.13 0.07) :rot (0 20 7) :c :white :tag :haori)       ; (pitched against
          (:bevel 0.14 0.62 0.42 0.03 :at (-0.4 -0.13 0.07) :rot (0 20 -7) :c :white :tag :haori)     ;  his hunch: they hang)
          (:box 0.1 0.56 0.02 :at (0.405 -0.075 0.279) :rot (0 20 7) :c :lining :tag :haori)
          (:box 0.1 0.56 0.02 :at (-0.405 -0.075 0.279) :rot (0 20 -7) :c :lining :tag :haori)
          ;; 一 in a rhombus between the shoulder blades (ink on the white back)
          (:box 0.125 0.016 0.006 :at (0.046 0.13 -0.205) :rot (0 0 -45) :c :black :tag :haori)
          (:box 0.125 0.016 0.006 :at (-0.046 0.13 -0.205) :rot (0 0 45) :c :black :tag :haori)
          (:box 0.125 0.016 0.006 :at (0.046 0.04 -0.205) :rot (0 0 45) :c :black :tag :haori)
          (:box 0.125 0.016 0.006 :at (-0.046 0.04 -0.205) :rot (0 0 -45) :c :black :tag :haori)
          (:box 0.085 0.018 0.006 :at (0 0.085 -0.205) :c :black :tag :haori))
  (:neck (:cyl 0.065 0.1 :at (0 0.04 0) :c :skin))
  ;; head in metres (not girth-scaled; x and z sizes x the body :width 1.05): a bald skull sphere, a
  ;; flat-fronted face (front at z 0.08) with the flat face shapes (tag :face-neutral), the long beard
  (:head (:sphere 0.0743 :stretch 0.05 :at (0 0.135 -0.008) :seg 12 :c :skin)             ; bald skull
         (:bevel 0.108 0.13 0.076 0.018 :at (0 0.1 0.042) :c :skin)                         ; face
         (:box 0.021 0.055 0.032 :at (0.078 0.115 -0.005) :c :skin) (:box 0.021 0.055 0.032 :at (-0.078 0.115 -0.005) :c :skin)
         (:wedge 0.028 0.05 0.029 :at (0 0.1 0.095) :rot (180 0 0) :c :skin)               ; nose
         (:box 0.06 0.009 0.01 :at (0.034 0.2 0.05) :rot (-28 -32 36) :c :scar)            ; the X scar, crown right
         (:box 0.06 0.009 0.01 :at (0.034 0.2 0.05) :rot (-28 -32 -36) :c :scar)
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
         (:box 0.024 0.19 0.024 :at (0.086 0.055 0.07) :rot (0 0 7) :c :beard)             ; ... hanging down to the jaw
         (:box 0.024 0.19 0.024 :at (-0.086 0.055 0.07) :rot (0 0 -7) :c :beard)
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
         (:cone 0.051 0.18 :at (0 -0.49 0.17) :rot (0 172 0) :seg 5 :c :beard)
         ;; the binding: two purple cords crossing down the beard's front, five X crossings (a lattice of diamonds)
         (:box 0.17 0.008 0.008 :at (0 0.0 0.142) :rot (0 8 33) :c :cord) (:box 0.17 0.008 0.008 :at (0 0.0 0.142) :rot (0 8 -33) :c :cord)
         (:box 0.17 0.008 0.008 :at (0 -0.09 0.155) :rot (0 8 33) :c :cord) (:box 0.17 0.008 0.008 :at (0 -0.09 0.155) :rot (0 8 -33) :c :cord)
         (:box 0.17 0.008 0.008 :at (0 -0.18 0.167) :rot (0 8 33) :c :cord) (:box 0.17 0.008 0.008 :at (0 -0.18 0.167) :rot (0 8 -33) :c :cord)
         (:box 0.135 0.008 0.008 :at (0 -0.265 0.186) :rot (0 8 37) :c :cord) (:box 0.135 0.008 0.008 :at (0 -0.265 0.186) :rot (0 8 -37) :c :cord)
         (:box 0.135 0.008 0.008 :at (0 -0.345 0.197) :rot (0 8 37) :c :cord) (:box 0.135 0.008 0.008 :at (0 -0.345 0.197) :rot (0 8 -37) :c :cord))
  ;; the kosode's shoulders and sleeves (black); the right sleeve hangs wide under the forearm, the left one is empty
  (:shoulder-r (:bevel 0.13 0.06 0.2 0.02 :at (0.02 -0.02 0) :rot (0 0 -24) :c :black :tag :kosode))
  (:shoulder-l (:bevel 0.13 0.06 0.2 0.02 :at (-0.02 -0.02 0) :rot (0 0 24) :c :black :tag :kosode))
  (:upper-arm-r (:box 0.14 0.31 0.15 :at (0 -0.15 0) :c :black :tag :kosode))
  (:upper-arm-l (:box 0.13 0.31 0.14 :at (0 -0.15 0) :c :black :tag :kosode)
                (:box 0.11 0.3 0.07 :at (0 -0.42 0.02) :rot (0 8 0) :c :black :tag :kosode))      ; empty sleeve
  (:lower-arm-r (:box 0.16 0.21 0.18 :at (0 -0.1 0) :c :black :tag :kosode)
                (:box 0.04 0.2 0.2 :at (0 -0.16 -0.06) :rot (0 -10 0) :c :black :tag :kosode)    ; hanging sleeve
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

;; Hellfire (GOKUEN, canon's "serious" state, ch. 155 / 394; the kit hides :haori and :kosode): bared to the waist, the
;; kosode top folded down over the obi, its two black sleeves hanging behind the hips (on the pelvis: they swing with the
;; lower cape's lag, YAMA-POSE); a lean, wiry torso (no broader than the robed one) with ink lines for the collarbones,
;; pectorals and the belly; the left arm ends above the elbow; 16 thin scars across chest, belly and arms, 12 of them
;; glowing (emissive parts, one mesh each: kept to 12), 4 healed (ink-brown). Art S4 (DUEL_YAMA_CORE §25): the 12 burn by heat: the mesh
;; glows a dull ember red (the floor: heat 25 and under), and YAMA-SCAR-GLOW (yama-look.lisp) draws an additive fire hairline over each
;; from *YA-SCARS*, full at heat 100, gone by 25, a pulse in the last 10 (they were a fixed glow 2.4 in #FF5A3C, the anime's flare).
(defparameter *ya-scars*
  '((:spine 0.08 0.15 0.135 0.14 30) (:spine -0.06 0.09 0.135 0.16 -20)
    (:chest 0.1 0.17 0.15 0.2 -35) (:chest -0.12 0.13 0.15 0.18 40) (:chest 0.04 0.1 0.152 0.22 -15)
    (:chest -0.03 0.21 0.145 0.12 70) (:chest 0.15 0.04 0.13 0.12 25) (:chest -0.15 0.03 0.13 0.13 -50)
    (:chest 0.08 0.12 -0.145 0.22 30)                                                             ; (on the back)
    (:upper-arm-r 0.0 -0.1 0.06 0.1 35) (:upper-arm-r 0.0 -0.2 0.06 0.09 -40) (:lower-arm-r 0.0 -0.06 0.053 0.08 50))
  "爆炎's 12 glowing scars: (part x y z length angle), a box LENGTH long at (X Y Z) of PART, turned ANGLE deg about its z (the surface's
normal is z's sign). The body's glow parts and YAMA-SCAR-GLOW's hairlines both read it.")
(defparameter *ya-bare-parts*
  (flet ((scars (part) (loop for (p x y z len a) in *ya-scars* when (eq p part)              ; 12 glow (the dull floor)
                             collect `(:glow 0.9 (:box ,len 0.007 0.006 :at (,x ,y ,z) :rot (0 0 ,a) :c :scar-glow))))
         (old (x y z len a) `(:box ,len 0.007 0.006 :at (,x ,y ,z) :rot (0 0 ,a) :c :scar)))                    ; 4 healed
    `((:pelvis (:bevel 0.42 0.1 0.31 0.04 :at (0 0.14 -0.01) :c :black)                            ; the top, folded down
               (:box 0.4 0.03 0.3 :at (0 0.19 -0.01) :c :black)
               (:box 0.17 0.46 0.06 :at (0.15 -0.15 -0.2) :rot (0 -12 10) :c :black)                 ; its sleeves, behind
               (:box 0.17 0.46 0.06 :at (-0.15 -0.15 -0.2) :rot (0 -12 -10) :c :black)
               (:box 0.15 0.02 0.05 :at (0.19 -0.38 -0.25) :rot (0 -12 10) :c :obi)                  ; their white cuffs
               (:box 0.15 0.02 0.05 :at (-0.19 -0.38 -0.25) :rot (0 -12 -10) :c :obi))
      (:spine (:bevel 0.42 0.25 0.25 0.05 :at (0 0.11 -0.005) :c :skin)
              (:box 0.006 0.2 0.006 :at (0 0.12 0.132) :c :lid)                                      ; the belly's lines
              (:box 0.13 0.006 0.006 :at (0 0.07 0.132) :c :lid) (:box 0.14 0.006 0.006 :at (0 0.13 0.132) :c :lid)
              (:box 0.15 0.006 0.006 :at (0 0.19 0.13) :c :lid)
              ,@(scars :spine) ,(old 0.03 0.04 0.135 0.12 -60)
              ,(old 0.17 0.11 0.06 0.1 75))
      (:chest (:bevel 0.48 0.3 0.27 0.06 :at (0 0.11 -0.005) :c :skin)
              (:box 0.16 0.006 0.006 :at (0.1 0.07 0.148) :rot (0 0 10) :c :lid)                    ; pectorals
              (:box 0.16 0.006 0.006 :at (-0.1 0.07 0.148) :rot (0 0 -10) :c :lid)
              (:box 0.13 0.006 0.006 :at (0.1 0.235 0.125) :rot (0 0 -10) :c :lid)                  ; collarbones
              (:box 0.13 0.006 0.006 :at (-0.1 0.235 0.125) :rot (0 0 10) :c :lid)
              ,@(scars :chest) ,(old -0.08 0.05 -0.145 0.2 -25))                                        ; (one of each on the back)
      (:shoulder-r (:bevel 0.12 0.07 0.14 0.03 :at (0.02 -0.02 0) :rot (0 0 -24) :c :skin))
      (:shoulder-l (:bevel 0.12 0.07 0.14 0.03 :at (-0.02 -0.02 0) :rot (0 0 24) :c :skin))
      (:upper-arm-r (:box 0.105 0.31 0.115 :at (0 -0.15 0) :c :skin) ,@(scars :upper-arm-r))
      (:upper-arm-l (:box 0.1 0.2 0.11 :at (0 -0.1 0) :c :skin) (:sphere 0.055 :at (0 -0.2 0) :seg 8 :c :skin)   ; the stump
                    ,(old 0.0 -0.08 0.058 0.09 -30))
      (:lower-arm-r (:box 0.095 0.24 0.1 :at (0 -0.12 0) :c :skin) (:box 0.006 0.17 0.006 :at (0.02 -0.12 0.052) :c :scar)
                    ,@(scars :lower-arm-r)))))
(body-variant :yamamoto-bare :yamamoto :palette '((:scar-glow #xA8301E)) :parts *ya-bare-parts*)   ; (the dull ember floor; art S4)

;; The Bankai (TYBW battle dress, canon-looks §3; the kit hides :haori): the black robe only, its edges burnt to tatters:
;; 6 triangles at the right sleeve's end, 5 at the empty left sleeve's, 6 round each hakama hem.
(defparameter *ya-tybw-parts*
  (flet ((tat (x y z r h) `(:cone ,r ,h :at (,x ,y ,z) :rot (0 180 0) :seg 3 :c :black)))
    `((:lower-arm-r ,(tat 0.05 -0.2 0.06 0.036 0.12) ,(tat -0.05 -0.2 0.05 0.034 0.15) ,(tat 0.03 -0.23 -0.04 0.036 0.13)
                    ,(tat -0.02 -0.25 -0.1 0.034 0.16) ,(tat 0.02 -0.25 -0.15 0.036 0.12) ,(tat 0.06 -0.2 -0.02 0.03 0.1))
      (:upper-arm-l ,(tat 0.04 -0.565 0.04 0.034 0.13) ,(tat -0.03 -0.565 0.03 0.034 0.16) ,(tat 0.0 -0.565 0.0 0.03 0.11)
                    ,(tat 0.04 -0.56 -0.01 0.03 0.14) ,(tat -0.04 -0.56 -0.005 0.034 0.1))
      ,@(loop for leg in '(:shin-r :shin-l)
              collect (cons leg (loop for k below 6 for a = (* k (/ pi 3)) for h in '(0.11 0.15 0.1 0.14 0.12 0.16)
                                      collect (tat (float (* 0.12 (cos a)) 1f0) -0.3 (float (* 0.12 (sin a)) 1f0) 0.05 h)))))))
(body-variant :yamamoto-tybw :yamamoto :parts *ya-tybw-parts*)

;;; ---------------------------------------------------------------- looks on the posed body (yama.lisp :hooks :pose / :draw)
;;; The lower haori (Shikai) and the folded kosode's sleeves (Hellfire) hang on the pelvis joint (yama-art.lisp): YAMA-POSE
;;; swings that joint's matrix about the obi by a lag spring per side (cosmetic secondary motion, DUEL_YAMA_TYBW §3.1): the
;;; hem trails his travel (forward and sideways) and his turns, overshoots once when he stops, and breathes a little while
;;; he stands. YAMA-DRAW steps the spring on the effect seconds (0 while paused) from the obi's world point and the pelvis
;;; heading YAMA-POSE recorded this frame, and draws Bankai East's smoke thread. A look: nothing here is read by the sim,
;;; no random number, 0 B a frame (debug 2328's `vfx consing` line).
(declaim (type f32vec *ya-hem* *ya-tip* *ya-base*))
(defvar *ya-hem* (make-f32 32)
  "The hem spring per side (16 floats each; hem-spring.lisp %YA-HEM-POSE / %YA-HEM-STEP, the layout in its comment). Back from
before R15a (2026-11), which dropped it from hem-spring.lisp while no kit used it.")
(defvar *ya-tip* (make-f32 3) "YAMA-DRAW's blade tip.")
(defvar *ya-base* (make-f32 3) "YAMA-DRAW's blade base (北's burn, art K3).")
(declaim (type f32vec *ya-rdt*))
(defvar *ya-rdt* (make-f32 1) "This frame's effect seconds, kept by YAMA-DRAW for the Kikon cinematics' looks (yama-cine.lisp, art K4): read
there, never passed as a boxed argument.")

(defvar *ya-footprints* nil "Debug 87481: YAMA-DRAW outlines his fire hazards' sim footprints on the floor (art S1's top-down stills).")

(defun-fast %ya-smoke (x y z)
  "Bankai East's blade (canon: a thin white thread of smoke rises straight up from the charred tip in every Bankai
still): a 7-segment SMOKE ribbon 1.1 m up from (X Y Z), widening as it rises, its lean and sway wobbling slowly."
  (declare (single-float x y z))
  (let* ((c (fx-clock)) (d3 (drawing-no 8f0)) (sd (- -11f0 (i->f (mod (f->i d3) 3))))
         (lean (* 0.09f0 (f-sin (* 0.7f0 c)))) (lz (* 0.05f0 (f-sin (+ 1.1f0 (* 0.53f0 c))))))
    (declare (single-float c d3 sd lean lz))
    (toon-ribbon (x y z) (lean 1.1f0 lz) (0.011f0 0.03f0) :heat (0.9f0 0.25f0) :seed sd :wob 0.12f0 :pal +pal-smoke+
                 :k 0.85f0 :ph (* 2.2f0 c) :sway 0.07f0 :segs 7))
  nil)

(defun yama-pose (e m)
  "KIT-HOOK :pose: the hem's swing on the posed joints (%YA-HEM-POSE; none in the Bankai's robe)."
  (let ((f (fighter e)))
    (%ya-hem-pose (model-joints m) *ya-hem* (* 16 (fighter-side f))
                  (if (eq (kit-form (fighter-kit f)) :bankai) 0 1))))

(defun yama-draw (e rdt)
  "KIT-HOOK :draw: step the hem spring; a new frame for the dead (YA-DEAD-RESET: the hazards draw after the fighters); the Bankai moves'
own looks (yama-look.lisp YAMA-BK-MOVES, art K1), 西's flame on a charged swing (YAMA-WEST-FLAME, art C, §34) and 天地灰尽's burn on the
gather (%YA-BLADE-BURN, art K3), its white band and the victim's cinders (YAMA-AS4-LOOK, art D: they outlast the move); out of a move, the pointer stances'
looks (YAMA-STANCE-LOOK, art K2); under 西 the garb as the form's aura (YAMA-GARB-AT, J2 §28.4); Bankai East's smoke thread from the drawn blade's tip (not while it stands in the plaza). The Shikai and
爆炎 (art S1): Ryujin Jakka's fire on the drawn blade (YAMA-BLADE-FIRE, SL0; not on the intro's cane, not in 撫斬's stance), J3's burning
pommel and the moves' own looks (YAMA-SK-MOVES: NADEGIRI's hairline and seam, TAIMATSU's halo, AS1's burst), by the tier of the heat his
segment paid (YA-SK-TIER); out of a move, pointer 1's and 2's stance looks (YAMA-STANCE-FIRE, art S3) by the heat his next segment would pay.
爆炎 (art S4): the scars by heat (YAMA-SCAR-GLOW), no SL0 while IKKOTSU's blade stands planted, the entry pose's fire (YAMA-BLAZE-IN-LOOK),
IKKOTSU's fist (%YA-FIST-FIRE), NS2b's ring closing before its dome (YAMA-RING-CLOSE). Art S5: no SL0 / stance fire while he is the
attacker of a Shikai Kikon cinematic (YAMA-S5-CINE-P): its look draws the blade per beat."
  (let* ((f (fighter e)) (m (model e)) (mv (current-move f)))
    (%ya-hem-step *ya-hem* (* 16 (fighter-side f)) (f32 rdt))
    (setf (aref *ya-rdt* 0) (f32 rdt))                  ; (the K4 cinematics' looks read it)
    (yama-lean-draw (model-joints m) (fighter-side f))   ; the garb's trailing spring, every frame in any form (§29.1)
    (ya-dead-reset)
    (when (and (eq (kit-form (fighter-kit f)) :bankai)                           ; 西's form aura, 殘日獄衣 at K 1 (J2, §28.4),
               (or (eql (fighter-ptr f) 2)                                       ;  under 西, a temporary switch's 西 NS (FIGHTER-TMP,
                   (and (eql (fighter-tmp f) 2) (eq (fighter-state f) :move))    ;  in a move: it is left stale after) or a garb level
                   (let ((s (yss e))) (and s (plusp (yss-garb s)))))             ;  held to his neutral (the user 2026-11-23, §43)
               (> (model-alpha m) 0.5) (not (eql e *aura-off*))                 ;  every frame under 西 but while a flare draws
               (not (let ((c *cine*)) (and c (eq (cine-name c) 'yama-nishi-cine)))))      ;  but while the 西 Kikon draws its own (§39: a
                                                                                          ;  flare no longer replaces it: no size pulse)
      (yama-garb-at (model-joints m) f (let ((s (yss e))) (if s (yss-garb s) 0))))   ; (its size by 西's charge or garb level: YAMA-GARB-K)
    (when (and mv (eq (kit-form (fighter-kit f)) :bankai))
      (let ((c (yama-bk-code mv)))
        (when (> c 0) (yama-bk-moves (pos-of e) (yaw-of e) c (fighter-sf f) (f32 rdt) mv   ; (NS1c: its volume in play; AS1: the charge's level,
                                     (let ((cm (fighter-charge-mult f))) (cond ((>= cm 1.65f0) 2) ((>= cm 1.35f0) 1) (t 0))))))   ;  YA-CHARGE-LEVEL's, inline)
      (yama-west-flame e f m mv)                          ; 西's flame on a charged swing (art batch C, §34)
      (when (and (eq (mv-name mv) :ya-e-as4) (eq (fighter-phase f) :main) (<= (fighter-sf f) 10) (model-weapon m))   ; 天地灰尽's burn (art K3; AS4's
        (body-weapon-tip (model-body m) (model-weapon m) (model-joints m) *ya-tip*)                                    ;  last since §31, at
        (body-weapon-base (model-body m) (model-weapon m) (model-joints m) *ya-base*)                                  ;  its S10 since art D:
        (%ya-blade-burn *ya-tip* *ya-base* (* 2 (fighter-sf f)))))                                                     ;  x2, gone on S)
    (yama-as4-look e f)                                 ; 天地灰尽's white band and the victim's cinders, past the move (art batch D)
    (when (and (null mv) (eq (kit-form (fighter-kit f)) :bankai) (> (model-alpha m) 0.5))   ; 南's cracks (art K2)
      (yama-stance-look (pos-of e) (yaw-of e) (model-anim m)))
    (unless (eq (kit-form (fighter-kit f)) :bankai)   ; the Shikai / 爆炎 (art S1, DUEL_YAMA_CORE §22): SL0 the blade's fire, SL7-SL9
      (let* ((main (and mv (eq (fighter-phase f) :main))) (ti (ya-sk-tier e f mv)) (jm (model-joints m))
             (blaze (eq (kit-form (fighter-kit f)) :blaze)) (c (anim-clip (model-anim m))))
        (when (and blaze (> (model-alpha m) 0.5))         ; 爆炎's scars by heat (art S4)
          (yama-scar-glow jm (gauges-meter (gauges e))))
        (when (and (eq (model-weapon m) :ryujin-jakka) (> (model-alpha m) 0.5)   ; (not the intro's cane; not 撫斬's stance: no fire at all;
                   (not (and (null mv) c (eq (clip-name c) :ya-st-cane)))       ;  not in an empty hand: IKKOTSU's blade stands planted)
                   (not (planted-spot e f mv))
                   (not (yama-s5-cine-p e)))                   ; (art S5: the Kikon cinematic's look draws the blade's fire per beat)
          (joint-point! *ya-tip* jm (ji :weapon-r) 0f0 0f0 -0.95f0)    ; (:ryujin-jakka's length / blade base, yama-art.lisp DEFWEAPON)
          (joint-point! *ya-base* jm (ji :weapon-r) 0f0 0f0 -0.25f0)
          (yama-blade-fire *ya-tip* *ya-base*
                           (+ (if blaze 10 0) (cond ((not (and main (<= (fighter-sf f) (+ (mv-s mv) (mv-a mv))))) 0)
                                                    ((eq (fighter-cls f) :ns) 2) (t 1)))
                           ti (f32 rdt))
          (when (and (null mv) c (member (clip-name c) '(:ya-shiranui :ya-st-enjo)))   ; the stances' fire (art S3): 不知火's corkscrew,
            (yama-stance-fire *ya-tip* *ya-base* (if (eq (clip-name c) :ya-shiranui) 1 2) (ya-stance-tier e blaze)))   ;  城郭炎上's drip
          (when (and main (eq (mv-name mv) :ya-blaze-in))   ; 爆炎's entry: the fire down the edge, the ring running out (art S4)
            (yama-blaze-in-look *ya-tip* *ya-base* (fighter-sf f)))
          (when (and main (eq (mv-name mv) :ya-j3) (<= 7 (fighter-sf f) 12))   ; SL9: TSUKABI's burning pommel (S-2 to S+A)
            (joint-point! *ya-tip* jm (ji :weapon-r) 0f0 0f0 0.285f0)
            (%ya-pommel-fire *ya-tip*)))
        (when (and (null mv) c (eq (clip-name c) :ya-st-cane) (eq (model-weapon m) :ryujin-jakka) (> (model-alpha m) 0.5)   ; 撫斬's stance
                   (not (planted-spot e f mv)) (not (yama-s5-cine-p e)))   ;  (J3, §28.5): no fire, the EMBER line down the blade
          (joint-point! *ya-tip* jm (ji :weapon-r) 0f0 0f0 -0.95f0)
          (joint-point! *ya-base* jm (ji :weapon-r) 0f0 0f0 -0.25f0)
          (yama-stance-fire *ya-tip* *ya-base* 3 0))
        (when main
          (let ((code (yama-sk-code mv)))
            (when (> code 0) (yama-sk-moves (pos-of e) (yaw-of e) code (fighter-sf f) ti)))
          (case (mv-name mv)                              ; 爆炎 (art S4): IKKOTSU's fist, NS2b's ring closing before its dome
            (:ya-b-j3 (when (<= 9 (fighter-sf f) 13)
                        (joint-point! *ya-tip* jm (ji :hand-r) 0f0 0f0 0f0)
                        (%ya-fist-fire *ya-tip* (yaw-of e) (fighter-sf f))))
            (:ya-b-n2b (when (<= 12 (fighter-sf f) 15) (yama-ring-close e (fighter-sf f))))))))
    (when *ya-footprints* (yama-footprints e))           ; (debug 87481: the sim footprints outlined, art S1's top-down stills)
    (when (and (eq (kit-form (fighter-kit f)) :bankai) (model-weapon m) (> (model-alpha m) 0.5)
               (not (planted-spot e f mv)))                 ; (no smoke from a blade left in the plaza)
      (let ((tp *ya-tip*))
        (body-weapon-tip (model-body m) (model-weapon m) (model-joints m) tp)
        (%ya-smoke (aref tp 0) (aref tp 1) (aref tp 2))))))

;; the intro's name column (brush.lisp *BRUSH-NAMES*, CINE-NAME; his entry left with the retired kits, back with his core kit)
(setf *brush-names* (append (remove :yamamoto *brush-names* :key #'first) '((:yamamoto "山本元柳斎重國" "YAMAMOTO GENRYUSAI SHIGEKUNI"))))

;;; ---------------------------------------------------------------- weapons
(defweapon :ya-cane (:length 0.86 :base 0.1)          ; the shikomizue: Ryujin Jakka sheathed in a cane
  (:solid (mbc mb #x3A3430)                           ; dark wood, desaturated (colour is spot-only)
          (mb-at (mb :y 0.4) (mb-cylinder mb 0.018 0.92 :segments 6))
          (mbc mb #x26221E)
          (mb-at (mb :y -0.06) (mb-cylinder mb 0.02 0.14 :segments 6))
          (mb-at (mb :y 0.855) (mb-cylinder mb 0.02 0.03 :segments 6))))

(defweapon :ryujin-jakka (:length 0.95)
  (:solid :ink 0 (mb-blade mb :length 0.9 :width 0.036 :blade-color '(0.76 0.78 0.82) :edge-color '(1.0 0.93 0.85) :hilt nil))
  (:solid (mb-blade mb :width 0.036 :guard-color '(0.44 0.42 0.38) :handle-color '(0.08 0.06 0.07) :wrap-color '(0.3 0.25 0.4) :blade nil))
  (:glow 1.2 #xFF7A2A (mb-at (mb :y 0.45 :z 0.017) (mb-box mb 0.003 0.8 0.004))))

(defweapon :zanka (:length 0.95)
  (:solid :ink 0 (mb-blade mb :length 0.9 :width 0.04 :curve 0.004 :blade-color '(0.07 0.055 0.055)
                              :edge-color '(0.3 0.07 0.03) :hilt nil))
  (:solid (mb-blade mb :width 0.04 :guard-color '(0.16 0.12 0.1) :handle-color '(0.05 0.04 0.04) :wrap-color '(0.18 0.08 0.06)
                       :blade nil))
  (:glow 3.5 #xFF5A14 (mb-at (mb :y 0.46 :z 0.02) (mb-box mb 0.005 0.86 0.006))
                      (mb-at (mb :y 0.3 :z 0.0 :roll 0.5) (mb-box mb 0.009 0.07 0.004))
                      (mb-at (mb :y 0.62 :z 0.004 :roll -0.4) (mb-box mb 0.009 0.08 0.004))))

;;; ---------------------------------------------------------------- the charred skeleton (Bankai South)
;; The dead of 南 (DUEL_YAMA_CORE §15.4 D1, the user 2026-11-20: 「焦黑骷髏配上紅色高光」): black charred bones, the skull plain, and only
;; thin red highlights (the bone edges, the eye sockets, the cracks), never a red fill, so a skeleton still reads as charcoal from the
;; arena camera (art K1, §16: the chest's red fill box and the orange spine glow became hairline strips). Drawn by yama-look.lisp's YA-DEAD.
(defbody :skeleton (:scale 1.0 :width 1.0 :hunch 20 :hurt-r 0.3 :hurt-h 1.7
                    :palette ((:bone #x2E2826) (:ash #x171315) (:ember #xD8141C))   ; charcoal bone, near-black bands, the red
                    :rim (#xD8141C 0.35))
  (:pelvis (:bevel 0.26 0.1 0.12 0.02 :c :ash))
  (:spine (:box 0.05 0.24 0.05 :at (0 0.11 -0.04) :c :bone)
          (:glow 2.0 (:box 0.008 0.2 0.008 :at (0 0.11 -0.012) :c :ember)))                  ; a crack down the spine
  (:chest (:box 0.06 0.24 0.06 :at (0 0.1 -0.06) :c :bone)
          (:box 0.3 0.035 0.18 :at (0 0.04 0) :c :ash) (:box 0.34 0.035 0.2 :at (0 0.1 0) :c :bone)
          (:box 0.32 0.035 0.19 :at (0 0.16 0) :c :ash) (:box 0.26 0.035 0.16 :at (0 0.21 0) :c :bone)
          (:glow 2.5 (:box 0.3 0.007 0.007 :at (0 0.12 0.102) :c :ember))                     ; the ribs' front edges: hairlines
          (:glow 2.5 (:box 0.24 0.007 0.007 :at (0 0.23 0.082) :c :ember)))
  (:neck (:box 0.04 0.1 0.04 :at (0 0.04 0) :c :bone))
  (:head (:bevel 0.17 0.17 0.2 0.04 :at (0 0.13 0) :c :ash)
         (:box 0.12 0.06 0.1 :at (0 0.03 0.04) :c :bone)
         (:glow 4.0 (:box 0.04 0.035 0.01 :at (0.04 0.13 0.1) :c :ember))                     ; the eye sockets
         (:glow 4.0 (:box 0.04 0.035 0.01 :at (-0.04 0.13 0.1) :c :ember))
         (:glow 2.5 (:box 0.007 0.09 0.007 :at (0.03 0.2 0.09) :rot (0 0 25) :c :ember)))      ; a crack over the brow
  (:shoulder-r (:box 0.14 0.04 0.05 :at (0.04 0 0) :c :bone))
  (:shoulder-l (:box 0.14 0.04 0.05 :at (-0.04 0 0) :c :bone))
  (:upper-arm-r (:box 0.045 0.3 0.045 :at (0 -0.15 0) :c :bone) (:glow 2.0 (:box 0.007 0.26 0.007 :at (0.024 -0.15 0.024) :c :ember)))
  (:upper-arm-l (:box 0.045 0.3 0.045 :at (0 -0.15 0) :c :bone) (:glow 2.0 (:box 0.007 0.26 0.007 :at (-0.024 -0.15 0.024) :c :ember)))
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
(defpose :ya-stance ()                                 ; the old man's slouch, the point resting on the plaza ahead like
  (:root :u -0.04) (:pelvis :twist 10) (:spine :flex 12) (:chest :twist -8) (:neck :flex -18) (:head :flex -14)   ; his cane
  (:arm-r :flex 23 :side -8) (:elbow-r :flex 32) (:hand-r :twist -2 :flex -82)
  (:arm-l :flex 4 :side 10) (:elbow-l :flex 0)
  (:thigh-r :flex -8 :side 8) (:thigh-l :flex 18 :side 6) (:knee-r :flex 18) (:knee-l :flex 22))

(defclip :ya-stance (2.4 :loop t :base :ya-stance)
  (0) (1.2 (:chest :flex 3) (:root :u -0.05)))

;;; ---------------------------------------------------------------- shikai kit (DUEL_YAMA_TYBW §3.2, motion-refs §5.1)
;;; One arc plane and hand set a strike: J1 S1 the diagonal down (forehand), J2 S2 the diagonal up (backhand), J3 S3 the
;;; sleeve (left), K1 S4 horizontal at the waist (forehand), K2 S5 vertical up, K3 S6 a full turn into the vertical drop, L S7
;;; the overhead semicircle / the backhand down / the point driven down, SP1 S8 the level thrust, SP2 S9 the rising fan
;;; out of a spin, Hellfire SP2 H1 the backhand draw-cut at the neck, I S10 the fist, O S11 the held point and its flick.
;;; Turns are root yaw (+ = his left) with a pelvis roll; a key about every 90 degrees of a spin; the hit pose on S. The
;;; K / L reach is the flame (DRAW-FIGHTER's fire sheet), the J reach the blade (the FK test, +-0.15 m).
;; S1 J1 HISEN's hit pose (the old :YA-Q1's, kept by :YA-HISEN; its clip left with art S3, when NS3b got its own): the wrist snapped
;; down-left across him, the head up (the eyes open)
(defpose :ya-q1-hit (:base :ya-stance)
  (:chest :twist -2) (:spine :flex 16) (:root :u -0.06) (:neck :flex -20) (:head :flex -26)
  (:arm-r :flex 29 :side 120 :twist -28) (:elbow-r :flex 62) (:hand-r :twist 18 :flex -70))
;; The core kit's J1 HISEN (art S2, DUEL_YAMA_CORE §21.3 / §23): its own clip at the move's S14, the opener's held tell. The charge f1-9 a key a frame, the arm's side and the wrist leading, the flex and the elbow lagging (eased:
;; ease-out cubic moves fastest on a segment's first frame), to the wrist cocked high right with the feet still; held f10-12 (a 1 deg
;; tremble); released f13-14 into the kept hit pose (:YA-Q1-HIT, the tip 1.39 m). On through f15 (:YA-HISEN-THRU: AS1's first frame) to
;; S+A f17 (:YA-HISEN-A = J2's first frame, the same numbers). Starts from three stances: the move's :blend 4
(defpose :ya-hisen-a (:base :ya-q1-hit)                     ; (S+A: J2 starts here; :YA-Q2's frame 0)
  (:chest :twist 9) (:arm-r :flex 79 :side 34 :twist 41) (:elbow-r :flex 18) (:hand-r :twist 5 :flex -79))
(defpose :ya-hisen-thru (:base :ya-hisen-a)                 ; (S+1: AS1 starts here)
  (:chest :twist 10) (:spine :flex 18) (:root :u -0.07) (:arm-r :flex 81 :side 36))
(defstrike :ya-hisen (14 3 12 :base :ya-stance)
  (0)
  (1 (:arm-r :flex 25 :side -4) (:elbow-r :flex 33) (:hand-r :twist -5 :flex -80))                                 ; the charge
  (2 (:root :u -0.041) (:chest :twist -9) (:arm-r :flex 28 :side 2 :twist -1) (:elbow-r :flex 35) (:hand-r :twist -9 :flex -77))
  (3 (:root :u -0.042) (:head :flex -15) (:arm-r :flex 32 :side 10 :twist -2) (:elbow-r :flex 38) (:hand-r :twist -14 :flex -73))
  (4 (:root :u -0.043) (:chest :twist -10) (:head :flex -16) (:arm-r :flex 40 :side 19 :twist -3) (:elbow-r :flex 42)
     (:hand-r :twist -21 :flex -68))
  (5 (:root :u -0.045) (:chest :twist -12) (:spine :flex 11) (:head :flex -17) (:arm-r :flex 52 :side 30 :twist -5) (:elbow-r :flex 50)
     (:hand-r :twist -28 :flex -62))
  (6 (:root :u -0.048) (:chest :twist -13) (:head :flex -18) (:arm-r :flex 69 :side 41 :twist -8) (:elbow-r :flex 60)
     (:hand-r :twist -36 :flex -56))
  (7 (:root :u -0.051) (:chest :twist -15) (:head :flex -20) (:arm-r :flex 93 :side 52 :twist -11) (:elbow-r :flex 76)
     (:hand-r :twist -44 :flex -50))
  (8 (:root :u -0.055) (:chest :twist -18) (:spine :flex 10) (:head :flex -22) (:arm-r :flex 129 :side 62 :twist -15) (:elbow-r :flex 98)
     (:hand-r :twist -51 :flex -45))
  (9 (:root :u -0.06) (:chest :twist -21) (:head :flex -24) (:arm-r :flex 175 :side 72 :twist -20) (:elbow-r :flex 127)   ; cocked
     (:hand-r :twist -58 :flex -40))                                                                                       ;  high right
  (10 (:chest :twist -22) (:arm-r :side 73))                                                                ; held, trembling
  (11 (:chest :twist -21) (:arm-r :flex 174 :side 71) (:root :u -0.065))
  (12 (:chest :twist -22) (:arm-r :flex 176 :side 73))
  (13 :snap (:chest :twist -17) (:spine :flex 11) (:neck :flex -18) (:head :flex -24)                      ; released
      (:arm-r :flex 169 :side 84 :twist -40) (:elbow-r :flex 133) (:hand-r :twist -59 :flex -54))
  (:s :snap :ya-q1-hit)
  (15 :ya-hisen-thru)
  (:a :ya-hisen-a)
  (23 (:chest :twist 0) (:spine :flex 14) (:root :u -0.05) (:arm-r :flex 50 :side 10 :twist 15) (:elbow-r :flex 25)
      (:hand-r :twist 2 :flex -80) (:head :flex -18))
  (:end :ya-stance))
;; S2 J2 KAESHIBI: the return flick, low left to high right, the elbow leading the backhand; still no step
(defpose :ya-q2-coil (:base :ya-stance)
  (:chest :twist 22) (:spine :flex 14 :side 4) (:root :u -0.06) (:neck :flex -18) (:head :flex -20)
  (:arm-r :flex 15 :side -12 :twist 3) (:elbow-r :flex 80) (:hand-r :twist 15 :flex -110))
(defpose :ya-q2-hit (:base :ya-stance)
  (:chest :twist -15) (:spine :flex 10) (:root :u -0.03) (:neck :flex -20) (:head :flex -26)
  (:arm-r :flex 55 :side -35 :twist -20) (:elbow-r :flex 17) (:hand-r :twist 40 :flex -26))
(defstrike :ya-q2 (8 3 13 :base :ya-stance)
  (0 :ya-q1-hit (:chest :twist 9) (:arm-r :flex 79 :side 34 :twist 41) (:elbow-r :flex 18) (:hand-r :twist 5 :flex -79))
  (4 :ya-q2-coil)
  (6 :ya-q2-coil (:chest :twist 20) (:arm-r :flex 35 :side -5) (:elbow-r :flex 86))   ; the elbow leads, the blade lags
  (:s :snap :ya-q2-hit)
  (9 (:chest :twist -28) (:spine :flex 8) (:root :u -0.02) (:head :flex -24)
     (:arm-r :flex 79 :side -2 :twist -39) (:elbow-r :flex 7) (:hand-r :twist 20 :flex -20))
  (:a (:chest :twist -27) (:arm-r :flex 77))
  (17 (:chest :twist -14) (:spine :flex 11) (:root :u -0.04) (:arm-r :flex 50 :side -5 :twist -10) (:elbow-r :flex 25)
      (:hand-r :twist 8 :flex -55) (:head :flex -18))
  (:end :ya-stance))
(defpose :ya-q2-a (:base :ya-q2-hit)                        ; J2's S+A (f11) as :YA-Q2 draws it: J3 starts here (art S2)
  (:chest :twist -27) (:spine :flex 8) (:root :u -0.02) (:head :flex -24)
  (:arm-r :flex 77 :side -2 :twist -39) (:elbow-r :flex 7) (:hand-r :twist 20 :flex -20))
;; S3 J3 TSUKABI 柄火 (the user, 2026-10-14: 「右手刀柄回擊」, DUEL_YAMA_TYBW §8): no left forearm in TYBW, so the right hand
;; drives the hilt: the grip drawn back past the right shoulder, the blade laid back along the forearm (the point behind and
;; low), then the hips and chest turn in and the pommel is punched up into the face (S, the burning pommel: DRAW-FIGHTER),
;; the empty left sleeve thrown back. Art S2 (DUEL_YAMA_CORE §23): frame 0 is J2's S+A (:YA-Q2-A, where the string's link lands: it was
;; the stance, a 1.81 m jump of the tip), and the hit pose leads with the pommel (the wrist turned over, the blade laid back under the
;; forearm, the tip 0.33 m ahead): the pommel 1.40 m ahead at the face's height, on the move's 1.4 m volume (it was 1.12, the tip leading)
(defpose :ya-tsuka-wind (:base :ya-stance)
  (:root :yaw -12 :u -0.08) (:pelvis :twist -10 :side 4) (:chest :twist -28) (:spine :flex 12 :side 4)
  (:head :flex -14 :twist 14)
  (:arm-r :flex -20 :side 25) (:elbow-r :flex 95) (:hand-r :flex -150)
  (:arm-l :flex 35 :side 15) (:elbow-l :flex 5)
  (:thigh-r :flex 18) (:knee-r :flex 24) (:thigh-l :flex 6) (:knee-l :flex 14))
(defpose :ya-tsuka-hit (:base :ya-stance)
  (:root :f 0.33 :u -0.06 :yaw 4) (:pelvis :twist 10 :side -4) (:chest :twist 20) (:spine :flex 10)
  (:head :flex -18 :twist -6)
  (:arm-r :flex 130.5 :side -30) (:elbow-r :flex 5.5) (:hand-r :twist 166.5 :flex -83.5 :side -19.5)
  (:arm-l :flex -25 :side 30) (:elbow-l :flex 10)
  (:thigh-l :flex 38 :side 6) (:knee-l :flex 36) (:thigh-r :flex -22 :side 8) (:knee-r :flex 16))
(defstrike :ya-tsuka (9 3 18 :base :ya-stance)
  (0 :ya-q2-a)
  (1 (:root :yaw -2.64 :u -0.033) (:pelvis :twist 5.6 :side 1) (:spine :flex 9 :side 1) (:neck :flex -19.6) (:head :flex -22 :twist 3) (:arm-r :flex 55.7 :side 4 :twist -30.4) (:elbow-r :flex 26.4) (:hand-r :twist 15 :flex -48.6) (:arm-l :flex 11 :side 11) (:elbow-l :flex 1) (:thigh-r :flex -2.3) (:knee-r :flex 19.3) (:thigh-l :flex 15.4) (:knee-l :flex 20))
  (2 (:root :yaw -6.24 :u -0.051) (:pelvis :twist -0.4 :side 2) (:chest :twist -27.5) (:spine :flex 10 :side 2) (:neck :flex -19) (:head :flex -19 :twist 7.3) (:arm-r :flex 26.6 :side 12 :twist -18.7) (:elbow-r :flex 53) (:hand-r :twist 8.6 :flex -87.6) (:arm-l :flex 20 :side 12.6) (:elbow-l :flex 2.6) (:thigh-r :flex 5.5) (:knee-r :flex 21) (:thigh-l :flex 12) (:knee-l :flex 18))
  (3 (:root :yaw -9.6 :u -0.068) (:pelvis :twist -6 :side 3) (:chest :twist -28) (:spine :flex 11 :side 3) (:neck :flex -18.4) (:head :flex -16 :twist 11) (:arm-r :flex -0.6 :side 19.6 :twist -8) (:elbow-r :flex 77.4) (:hand-r :twist 2.4 :flex -124) (:arm-l :flex 29 :side 14) (:elbow-l :flex 4) (:thigh-r :flex 13) (:knee-r :flex 23) (:thigh-l :flex 8.4) (:knee-l :flex 15.6))
  (4 :ya-tsuka-wind)
  (7 :ya-tsuka-wind (:root :yaw -16 :u -0.1) (:chest :twist -34) (:elbow-r :flex 105))   ; wound up, held
  (:s :snap :ya-tsuka-hit)
  (:a :ya-tsuka-hit (:root :f 0.32) (:arm-r :flex 132))
  (21 (:root :yaw 2 :f 0.2 :u -0.05) (:pelvis :twist 4) (:chest :twist 8) (:spine :flex 10)
      (:arm-r :flex 40 :side 10) (:elbow-r :flex 50) (:hand-r :twist 60 :flex -108 :side -8)
      (:arm-l :flex -5 :side 18) (:thigh-l :flex 22) (:knee-l :flex 24))
  (:end :ya-stance))
;; Pointer 1's stance 不知火 (kit :core :stances; DUEL_YAMA_CORE §21.3, art S2): sunk and side-on, the hilt drawn back at his right hip 0.4 m
;; out from the body, the blade level along the lane (the tip 0.9 m ahead at the hip's height); 4 keys, a slow breath (the tip moves
;; under 3 cm: NS1a starts from the pose)
(defpose :ya-st-shiranui (:base :ya-stance)
  (:root :yaw -25 :u -0.14) (:pelvis :twist 0) (:knees :flex 40) (:thighs :flex 30) (:chest :twist -20) (:spine :flex 10)
  (:head :twist 22 :flex -12) (:arm-r :flex 4 :side 40 :twist 26) (:elbow-r :flex 95) (:hand-r :twist -10 :flex -46.5 :side -8.5))
(defclip :ya-shiranui (2.4 :loop t :base :ya-st-shiranui)
  (0) (0.6 (:root :u -0.15) (:knees :flex 41)) (1.2 (:root :u -0.145) (:chest :twist -21) (:knees :flex 40.5))
  (1.8 (:root :u -0.15) (:knees :flex 41) (:chest :twist -20.5)))
;; Pointer 1 不知火 SHIRANUI, art S2 (DUEL_YAMA_CORE §21.3 / §23): each segment on its own clip at its move's S, frame 0 the pose its link
;; lands on (an attack starts with no blend): NS1a from pointer 1's stance (:YA-ST-SHIRANUI), NS1b from NS1a's S+A (:YA-N1A-LAND), NS1c
;; from NS1b's S+A (:YA-N1B-TOP), AS1 from J1's S+1 (:YA-HISEN-THRU). No root-yaw turn: the whirl is the wrist's.
;; NS1a (S22), the point thrown: the spiral gathers f1-14 (a key a frame, eased; the wrist circles the point 1.5 turns, growing then
;; closing, as the hilt is drawn back to the ribs), the coil held and trembling f15-19, the level thrust released f20-21, the arm locked on
;; S (the tip 2.04 m ahead, 1.15 m up: the spiral leaves 1 m ahead), held out to S+A (:YA-N1A-LAND = NS1b's first frame)
(defpose :ya-n1a-coil (:base :ya-st-shiranui)               ; the hilt drawn back past the ribs, the point still on the lane
  (:root :yaw -32 :u -0.17) (:knees :flex 46) (:chest :twist -32) (:head :twist 28)
  (:arm-r :flex -16 :side 77.5 :twist 43.5) (:elbow-r :flex 104.5) (:hand-r :twist -7 :flex -1.5 :side -12))
(defpose :ya-n1a-hit (:base :ya-stance)                     ; the level thrust, the arm locked (the old SHIRANUI throw's pose)
  (:root :yaw 10 :f 0.3 :u -0.1) (:chest :twist 15) (:spine :flex 12) (:head :flex -18)
  (:thigh-l :flex 50) (:knee-l :flex 40) (:thigh-r :flex -25)
  (:arm-r :flex 121 :side -50 :twist 18) (:elbow-r :flex 14) (:hand-r :twist -7 :flex -92))
(defpose :ya-n1a-land (:base :ya-n1a-hit) (:root :f 0.32))  ; (S+A: NS1b starts here)
(defstrike :ya-n1a (22 2 24 :base :ya-stance)
  (0 :ya-st-shiranui)
  (1 (:root :yaw -25.07) (:arm-r :side 40.4) (:hand-r :flex -43.6 :side -9))
  (2 (:root :yaw -25.14 :u -0.141) (:arm-r :flex 3.6 :side 41 :twist 26.4) (:hand-r :flex -38 :side -13.4))
  (3 (:root :yaw -25.28) (:chest :twist -20.5) (:arm-r :flex 3 :side 41.5 :twist 26.7) (:elbow-r :flex 95.4) (:hand-r :flex -34.6 :side -21.5))
  (4 (:root :yaw -25.42 :u -0.142) (:knees :flex 40.4) (:chest :twist -20.7) (:head :twist 22.4) (:arm-r :side 42 :twist 27) (:elbow-r :flex 95.6) (:hand-r :flex -37.7 :side -30))
  (5 (:root :yaw -25.63 :u -0.143) (:knees :flex 40.5) (:chest :twist -21) (:head :twist 22.5) (:arm-r :flex 2 :side 43.4 :twist 27.6) (:elbow-r :flex 96) (:hand-r :twist -9.7 :flex -46 :side -34.4))
  (6 (:root :yaw -25.91 :u -0.144) (:knees :flex 41) (:chest :twist -21.6) (:head :twist 23) (:arm-r :flex 1.4 :side 45 :twist 28.3) (:hand-r :twist -9.6 :flex -54.4 :side -32))
  (7 (:root :yaw -26.26 :u -0.145) (:chest :twist -22) (:arm-r :flex 0.4 :side 47 :twist 29) (:elbow-r :flex 96.7) (:hand-r :twist -9.5 :flex -56.4 :side -23.5))
  (8 (:root :yaw -26.68 :u -0.147) (:knees :flex 41.4) (:chest :twist -23) (:head :twist 23.4) (:arm-r :flex -1 :side 49 :twist 30) (:elbow-r :flex 97.3) (:hand-r :twist -9.3 :flex -49.4 :side -14.6))
  (9 (:root :yaw -27.17 :u -0.149) (:knees :flex 42) (:chest :twist -23.7) (:head :twist 24) (:arm-r :flex -2 :side 51.6 :twist 31.4) (:elbow-r :flex 98) (:hand-r :twist -9 :flex -36 :side -10))
  (10 (:root :yaw -27.8 :u -0.152) (:knees :flex 42.4) (:chest :twist -25) (:head :twist 24.4) (:arm-r :flex -4 :side 55 :twist 33) (:elbow-r :flex 99) (:hand-r :flex -22.4 :side -11))
  (11 (:root :yaw -28.57 :u -0.155) (:knees :flex 43) (:chest :twist -26) (:head :twist 25) (:arm-r :flex -6 :side 59 :twist 35) (:elbow-r :flex 100) (:hand-r :twist -8.5 :flex -13.4 :side -15.4))
  (12 (:root :yaw -29.48 :u -0.159) (:knees :flex 44) (:chest :twist -27.7) (:head :twist 26) (:arm-r :flex -9 :side 64 :twist 37) (:elbow-r :flex 101) (:hand-r :twist -8 :flex -10 :side -18.4))
  (13 (:root :yaw -30.6 :u -0.164) (:knees :flex 45) (:chest :twist -29.6) (:head :twist 27) (:arm-r :flex -12 :side 70 :twist 40) (:elbow-r :flex 102.6) (:hand-r :twist -7.6 :flex -8 :side -17))
  (14 (:root :yaw -32 :u -0.17) (:knees :flex 46) (:chest :twist -32) (:head :twist 28) (:arm-r :flex -16 :side 77.5 :twist 43.5) (:elbow-r :flex 104.5) (:hand-r :twist -7 :flex -1.5 :side -12))
  (15 :ya-n1a-coil (:arm-r :side 78.5) (:root :u -0.175))                                     ; the coil held, trembling
  (16 :ya-n1a-coil (:arm-r :side 77) (:hand-r :twist -8))
  (17 :ya-n1a-coil (:arm-r :side 79) (:root :u -0.18))
  (18 :ya-n1a-coil (:arm-r :side 77.5) (:hand-r :twist -6))
  (19 :ya-n1a-coil (:arm-r :side 79) (:root :u -0.18))
  (20 :snap (:root :yaw -21.5 :f 0.075 :u -0.153) (:chest :twist -20) (:head :twist 21 :flex -13.5) (:spine :flex 10.5) (:arm-r :flex 18 :side 45.6 :twist 37) (:elbow-r :flex 82) (:hand-r :twist -7 :flex -24 :side -9))
  (21 :snap (:root :yaw -6.8 :f 0.18 :u -0.128) (:chest :twist -4) (:head :twist 11 :flex -15.6) (:spine :flex 11) (:arm-r :flex 66 :side 1 :twist 28) (:elbow-r :flex 50) (:hand-r :twist -7 :flex -56 :side -5))
  (:s :snap :ya-n1a-hit)
  (:a :ya-n1a-land)
  (36 (:root :yaw 4 :f 0.14 :u -0.07) (:chest :twist 4) (:spine :flex 12) (:thigh-l :flex 30) (:knee-l :flex 30)
      (:thigh-r :flex -14) (:arm-r :flex 60 :side -10 :twist 5) (:elbow-r :flex 25) (:hand-r :twist 0 :flex -80))
  (:end :ya-stance))
;; NS1b (S16, the old K2 SHOEN re-keyed; was S22 at x1.375), the lift: out of the thrust the point dropped onto the plaza ahead (f8),
;; held there f9-12 (the tell: the fire answers 4-7 m away), then lifted straight up through level (f14) onto his toes, the blade
;; overhead on S, held up through the active window to S+A (:YA-N1B-TOP = NS1c's first frame)
(defpose :ya-f2-low (:base :ya-stance)
  (:root :yaw -8 :u -0.22) (:knees :flex 55) (:thighs :flex 40) (:spine :flex 30) (:chest :twist -5)
  (:arm-r :flex 45 :side 10) (:elbow-r :flex 41) (:hand-r :twist 0 :flex -71))
(defpose :ya-f2-hit (:base :ya-stance)
  (:root :u 0.05) (:knees :flex 5) (:thighs :flex 4) (:spine :flex -5) (:head :flex -30)
  (:arm-r :flex 59 :side -1 :twist 13) (:elbow-r :flex 23) (:hand-r :twist -12 :flex -29))
(defpose :ya-n1b-plaza (:base :ya-f2-low)                   ; crouched, the point on the plaza 1.16 m ahead
  (:root :yaw -4 :f 0.2 :u -0.2) (:arm-r :flex 22 :side -10.5) (:elbow-r :flex 43) (:hand-r :twist 8.5 :flex -54))
(defpose :ya-n1b-hit (:base :ya-f2-hit)                     ; on his toes, the blade straight up (the tip 2.78 m up)
  (:root :u 0.08) (:spine :flex -12) (:head :flex -34) (:arm-r :flex 136 :side -10 :twist -15) (:elbow-r :flex 12) (:hand-r :twist 20 :flex -60))
(defpose :ya-n1b-top (:base :ya-n1b-hit) (:arm-r :flex 138) (:root :u 0.07))   ; (S+A: NS1c starts here)
(defstrike :ya-f2 (16 13 20 :base :ya-stance)
  (0 :ya-n1a-land)
  (8 :ya-n1b-plaza)                                                                             ; the point dropped
  (10 :ya-n1b-plaza (:root :u -0.205))                                                          ; held: the tell
  (12 :ya-n1b-plaza (:hand-r :flex -53))
  (13 :snap :ya-f2-low (:root :yaw -4 :f 0.18 :u -0.12) (:knees :flex 35) (:spine :flex 15) (:arm-r :flex 52) (:hand-r :flex -50))
  (14 :snap :ya-f2-hit (:root :f 0.16))                                                         ; through level
  (15 :snap :ya-n1b-hit (:root :f 0.15 :u 0.04) (:arm-r :flex 105))
  (:s :snap :ya-n1b-hit (:root :f 0.14))
  (22 :ya-n1b-hit (:root :f 0.12 :u 0.075) (:arm-r :flex 137))
  (:a :ya-n1b-top)
  (40 (:root :u -0.02 :f 0.04) (:spine :flex 4) (:knees :flex 14) (:head :flex -22)
      (:arm-r :flex 80 :side 0 :twist 0) (:elbow-r :flex 30) (:hand-r :twist 5 :flex -60))
  (:end :ya-stance))
;; NS1c (S18), the whirl: from the blade overhead the forearm stays upright and the wrist turns the level blade once round over his head,
;; a key every 90 deg (ahead f3, his left f6, behind f9, his right f12: linear between, an even whirl), held high at his right f13-15,
;; flung forward and down f16-17 as the torso turns in, the tip 1.65 m ahead on S (the tornado leaves)
(defpose :ya-n1c-hit (:base :ya-stance)
  (:root :yaw 8 :f 0.25 :u -0.14) (:pelvis :side -4) (:chest :twist 22) (:spine :flex 20) (:head :flex -24)
  (:thigh-l :flex 48) (:knee-l :flex 44) (:thigh-r :flex -22)
  (:arm-r :flex 32.5 :side 18.5 :twist -18) (:elbow-r :flex 60) (:hand-r :twist -17 :flex -47))
(defstrike :ya-n1c (18 2 30 :base :ya-stance)
  (0 :ya-n1b-top)
  (3 :snap (:arm-r :flex 168 :side -6 :twist 0) (:elbow-r :flex 6) (:hand-r :twist 20 :flex -22.5 :side 30.5))
  (4.5 :snap (:hand-r :twist 51.5 :flex -11.5 :side 26.5))
  (6 :snap (:hand-r :twist 67.5 :flex -74 :side 11.5))
  (7.5 :snap (:hand-r :twist 51.5 :flex -134.5 :side 21))
  (9 :snap (:hand-r :twist 34.5 :flex -140.5 :side 46.5))
  (10.5 :snap (:hand-r :twist 34.5 :flex -117 :side 71.5))
  (12 :snap (:hand-r :twist 50.5 :flex -74 :side 95.5))
  (13 (:hand-r :side 97) (:root :u 0.075))                                                      ; held at his right, trembling
  (14 (:hand-r :side 94.5 :flex -73))
  (15 (:hand-r :side 96.5 :flex -75) (:root :u 0.07))
  (16 :snap (:root :yaw 1.6 :f 0.05 :u 0.028) (:pelvis :side -1) (:chest :twist -2) (:spine :flex -5.6) (:head :flex -32) (:thigh-l :flex 13) (:knee-l :flex 13) (:thigh-r :flex -1) (:knee-r :flex 7.6) (:arm-r :flex 141 :side -1 :twist -3.6) (:elbow-r :flex 17) (:hand-r :twist 37 :flex -68.6 :side 76.4))
  (17 :snap (:root :yaw 4.8 :f 0.15 :u -0.056) (:pelvis :side -2.4) (:chest :twist 10) (:spine :flex 7) (:head :flex -28) (:thigh-l :flex 30.4) (:knee-l :flex 28.4) (:thigh-r :flex -11.6) (:knee-r :flex 13) (:arm-r :flex 86.7 :side 8.7 :twist -11) (:elbow-r :flex 38.4) (:hand-r :twist 10 :flex -58 :side 38))
  (:s :snap :ya-n1c-hit)
  (:a :ya-n1c-hit (:root :f 0.26 :u -0.15) (:spine :flex 21))
  (36 (:root :yaw 4 :f 0.14 :u -0.08) (:pelvis :side -1) (:chest :twist 8) (:spine :flex 12) (:thigh-l :flex 28) (:knee-l :flex 30)
      (:thigh-r :flex -12) (:arm-r :flex 40 :side 4 :twist -5) (:elbow-r :flex 35) (:hand-r :twist -5 :flex -75))
  (:end :ya-stance))
;; AS1 (S10), the point point-blank: from J1's S+1 the hilt pulled back to the ribs (f1-6 a key a frame), held f7-8, a short corkscrew
;; thrust (the wrist rolls 70 deg as it goes), the tip 1.60 m ahead on S: the move's 1.6 m arc (it was 2.04, the old throw at x0.2)
(defpose :ya-as1-coil (:base :ya-hisen-thru)
  (:root :yaw -14 :f 0.02 :u -0.1) (:chest :twist -22) (:spine :flex 12) (:head :flex -20 :twist 12)
  (:arm-r :flex -38 :side 53.5 :twist 43.5) (:elbow-r :flex 119.5) (:hand-r :twist -9.5 :flex -27 :side 0))
(defpose :ya-as1-hit (:base :ya-n1a-hit)
  (:root :yaw 15 :f -0.15 :u -0.1) (:chest :twist 10) (:arm-r :flex 110 :side -54.5 :twist 18) (:elbow-r :flex 25) (:hand-r :twist -7 :flex -92.5))
(defstrike :ya-as1 (10 3 24 :base :ya-stance)
  (0 :ya-hisen-thru)
  (1 (:root :yaw -1.12 :f 0.002 :u -0.072) (:chest :twist 7.4) (:spine :flex 17.5) (:head :flex -25.5 :twist 1) (:arm-r :flex 71.5 :side 37.4) (:elbow-r :flex 26) (:hand-r :twist 4 :flex -75))
  (2 (:root :yaw -2.8 :f 0.004 :u -0.076) (:chest :twist 3.6) (:spine :flex 17) (:head :flex -25 :twist 2.4) (:arm-r :flex 57 :side 39.5 :twist 41.5) (:elbow-r :flex 38.3) (:hand-r :twist 2 :flex -68.6))
  (3 (:root :yaw -5.04 :f 0.007 :u -0.081) (:chest :twist -1.5) (:spine :flex 16) (:head :flex -24 :twist 4.3) (:arm-r :flex 38 :side 42.3 :twist 42) (:elbow-r :flex 54.5) (:hand-r :twist 0 :flex -60.3))
  (4 (:root :yaw -7.7 :f 0.011 :u -0.087) (:chest :twist -7.6) (:spine :flex 14.7) (:head :flex -22.7 :twist 6.6) (:arm-r :flex 15.5 :side 45.6 :twist 42.4) (:elbow-r :flex 74) (:hand-r :twist -3 :flex -50.4))
  (5 (:root :yaw -10.64 :f 0.015 :u -0.093) (:chest :twist -14.3) (:spine :flex 13.4) (:head :flex -21.4 :twist 9) (:arm-r :flex -9.4 :side 49.3 :twist 43) (:elbow-r :flex 95) (:hand-r :twist -6 :flex -39.5))
  (6 (:root :yaw -14 :f 0.02 :u -0.1) (:chest :twist -22) (:spine :flex 12) (:head :flex -20 :twist 12) (:arm-r :flex -38 :side 53.5 :twist 43.5) (:elbow-r :flex 119.5) (:hand-r :twist -9.5 :flex -27))
  (7 (:arm-r :side 54.5) (:root :u -0.105))                                                   ; held
  (8 (:arm-r :side 53) (:hand-r :twist -11))
  (9 :snap (:root :yaw -0.95 :f -0.056 :u -0.1) (:chest :twist -7.6) (:spine :flex 12) (:head :flex -19 :twist 6.6) (:arm-r :flex 28.6 :side 5 :twist 32) (:elbow-r :flex 77) (:hand-r :twist -38.4 :flex -56.5 :side 0))
  (:s :snap :ya-as1-hit)
  (:a :ya-as1-hit (:root :u -0.105) (:arm-r :flex 109))
  (25 (:root :yaw 4 :f 0.0 :u -0.07) (:chest :twist 4) (:spine :flex 12) (:thigh-l :flex 30) (:knee-l :flex 30)
      (:thigh-r :flex -14) (:arm-r :flex 50 :side -10 :twist 5) (:elbow-r :flex 25) (:hand-r :twist 0 :flex -80))
  (:end :ya-stance))
(defpose :ya-lean (:base :ya-stance)                   ; leaning on the cane, planted in front
  (:root :u -0.02) (:pelvis :twist 0) (:chest :twist 0) (:spine :flex 14) (:head :flex -6)
  (:arm-r :flex 40 :side 8) (:elbow-r :flex 35) (:hand-r :twist 150 :flex 10)
  (:thigh-r :flex 0 :side 6) (:thigh-l :flex 0 :side 6) (:knees :flex 8))
(defpose :ya-enjo-point (:base :ya-stance)                 ; the blade pointed at arm's length down the lane (the old O ENJO's; stance 2's base)
  (:root :yaw 20 :u -0.04) (:chest :twist 15) (:spine :flex 8) (:head :flex -24)
  (:arm-r :flex 127 :side -57 :twist -4) (:elbow-r :flex 4) (:hand-r :twist -6 :flex -78))
;; the core kit's pointer stances 2 and 3 (DUEL_YAMA_CORE §21.3, art S2; pointer 1's :YA-SHIRANUI is with its segments): 2 城郭炎上
;; upright, the arm locked out at shoulder height, the blade level at the foe (the hand 1.33 m up, the tip 1.70 m ahead); 3 撫斬 upright,
;; the head bowed (the eyes shut), the hand on the hilt of the blade stood point-down at his right front (the tip on the plaza 0.28 m
;; right, 0.22 m ahead: his body hides a centred blade from the behind camera), no fire (YAMA-DRAW); only the head breathes, so the
;; point stays on the plaza. 4 keys each, 2.4 s loops
(defpose :ya-st-jokaku (:base :ya-enjo-point)
  (:root :yaw 12 :u -0.02) (:chest :twist 10) (:spine :flex 2) (:neck :flex -8) (:head :flex -10)
  (:arm-r :flex 116 :side -49.5 :twist -4) (:elbow-r :flex 4) (:hand-r :twist -6 :flex -82.5))
(defclip :ya-st-enjo (2.4 :loop t :base :ya-st-jokaku)
  (0) (0.6 (:root :u -0.03) (:arm-r :flex 115.5)) (1.2 (:root :u -0.035) (:chest :flex -2) (:arm-r :flex 115))
  (1.8 (:root :u -0.025) (:arm-r :flex 115.5)))
(defpose :ya-st-nade (:base :ya-lean)                        ; (J3, §28.5: the blade slanted out, the point 0.50 m right / 0.32 ahead,
  (:root :u -0.01) (:spine :flex 6) (:neck :flex -10) (:head :flex -26)   ;  was 0.28 / 0.22: past the haori's edge from behind; hand :side 33.5, was 13.5)
  (:arm-r :flex -14.5 :side 22 :twist 5) (:elbow-r :flex 84.5) (:hand-r :twist 150 :flex 39.5 :side 33.5))
(defclip :ya-st-cane (2.4 :loop t :base :ya-st-nade)
  (0) (0.6 (:head :flex -27)) (1.2 (:neck :flex -11) (:head :flex -28)) (1.8 (:head :flex -27)))
;; Pointer 2 城郭炎上 JOKAKU ENJO, art S3 (DUEL_YAMA_CORE §21.3 / §24): each segment on its own clip at its move's S, frame 0 the pose its link
;; lands on: NS2a from pointer 2's stance (:YA-ST-JOKAKU), NS2b from NS2a's S+A (:YA-N2A-SWEEP), NS2c from NS2b's S+A (:YA-N2B-LAND), AS2a
;; from J2's S+1 (:YA-Q2-THRU), AS2b from AS2a's S+A (:YA-AS2A-LAND) on NS2c's poses. One arm, no root-yaw turn.
;; NS2a (S20, the opener's tell; its own clip since art batch B, DUEL_YAMA_CORE §34: the melee flame slash of §30.1, reach 2.4, arc 120;
;; it played the old stream's spear clip :YA-ENJO, its tip 1.89 m): a level sweep R -> L at the waist. From stance 2 the blade is drawn back
;; to his right f1-12 (eased: barely moving to f6, gathering to f12), held f13-17 low behind his right hip, the chest wound right, the
;; weight back (the coil trembles); the hips lead on f18, the blade sweeps through his front on a long lunge (f19 linear), level on S with
;; the tip 2.41 m out at the waist's height, dead ahead (the FK test: the volume's 2.4 m), and on to his left front on S+A (-41 deg); the
;; follow-through drags it round to his left, low, and the weight settles back. The lunge is drawn (the move has no :slide): the root's
;; 0.62 m is cosmetic, NS2b draws him back over 4 f. The flame fan along the blade's path is YAMA-SK-MOVES code 9 (SL4b)
(defpose :ya-n2a-hit (:base :ya-st-jokaku)                  ; (the old spear's lock-out: NS2c's hit pose is built on it)
  (:root :yaw 14 :f 0.15 :u -0.07) (:chest :twist 18) (:spine :flex 6) (:head :flex -14) (:thigh-l :flex 38) (:knee-l :flex 34) (:thigh-r :flex -16)
  (:arm-r :flex 133 :side -51.5 :twist -17.5) (:elbow-r :flex 1.5) (:hand-r :twist -6.5 :flex -83 :side 0))
(defpose :ya-n2a-land (:base :ya-n2a-hit) (:root :f 0.16 :u -0.075) (:arm-r :flex 131))   ; (the point ahead: NS2b's circle starts here)
(defpose :ya-n2a-coil (:base :ya-stance)                    ; the blade drawn back level at his right, the point 0.4 m behind him
  (:root :yaw -25 :u -0.14 :f -0.05) (:chest :twist -40) (:spine :flex 14) (:head :flex -20 :twist 16)   ; (NS3b's wind-up, wound further)
  (:arm-r :flex 24 :side 33.5 :twist -1) (:elbow-r :flex 84) (:hand-r :flex -142.5 :twist -41 :side 10.5)
  (:thigh-r :flex 30) (:knee-r :flex 40) (:thigh-l :flex -5) (:knee-l :flex 15))
(defpose :ya-n2a-slash (:base :ya-n2a-hit)                  ; S: lunged, leaning in, the arm and the blade one line at the waist
  (:root :f 0.62 :u -0.17) (:spine :flex 24) (:chest :twist 30) (:thigh-l :flex 64) (:knee-l :flex 52) (:thigh-r :flex -36) (:knee-r :flex 12)
  (:arm-r :flex 152))
(defpose :ya-n2a-sweep (:base :ya-n2a-slash)                ; S+A: swept on to his left front (NS2b starts here)
  (:root :yaw 40 :f 0.5) (:chest :twist 55) (:arm-r :side -60) (:hand-r :side -35))
(defstrike :ya-n2a (20 2 22 :base :ya-stance)
  (0 :ya-st-jokaku)
  (6 :ya-st-jokaku (:root :yaw 6 :u -0.05) (:chest :twist 0) (:arm-r :flex 100 :side -20 :twist -10) (:elbow-r :flex 20)   ; barely moving
        (:hand-r :flex -90))
  (12 :ya-n2a-coil)                                                                                  ; drawn back, gathering
  (13 :ya-n2a-coil (:root :u -0.145) (:hand-r :flex -144))                                          ; held, trembling
  (14 :ya-n2a-coil (:chest :twist -41.5) (:hand-r :twist -43))
  (15 :ya-n2a-coil (:root :u -0.145) (:hand-r :flex -141))
  (16 :ya-n2a-coil (:chest :twist -41) (:hand-r :twist -39.5))
  (17 :ya-n2a-coil)
  (18 :snap :ya-n2a-coil (:root :yaw -8 :f 0.12 :u -0.15) (:chest :twist -26) (:pelvis :side -2) (:thigh-l :flex 28) (:knee-l :flex 30)   ; the hips lead
        (:thigh-r :flex 6) (:knee-r :flex 26))
  (19 :snap :ya-n2a-slash (:root :yaw -4 :f 0.4 :u -0.16) (:spine :flex 20) (:chest :twist 8) (:hand-r :side 30))           ; the sweep, level
  (:s :snap :ya-n2a-slash)
  (:a :ya-n2a-sweep)
  (30 :ya-n2a-sweep (:root :f 0.42 :u -0.13) (:chest :twist 60) (:spine :flex 20) (:arm-r :flex 120) (:hand-r :side -55))   ; dragged round, low
  (:end :ya-stance))
;; NS2b (S16), the point draws: the wrist draws one circle with the point f4-13 (r 0.25 m at the tip: the hand's flex and side in quadrature,
;; +-15 deg, a key every 45 deg, linear; no twist), a stop on S, the point dipped at the ring's spot. Frame 0 is NS2a's S+A (the slash swept
;; to his left front, lunged, art batch B): the point brought back ahead and the lunge drawn back over f1-4
(defpose :ya-n2b-hit (:base :ya-n2a-land) (:root :u -0.08) (:hand-r :flex -90))
(defpose :ya-n2b-land (:base :ya-n2b-hit) (:arm-r :flex 130) (:hand-r :flex -91))   ; (S+A: NS2c starts here)
(defstrike :ya-n2b (16 2 20 :base :ya-stance)
  (0 :ya-n2a-sweep)
  (4 :ya-n2a-land (:root :u -0.08) (:hand-r :flex -83))                                       ; the circle
  (5.125 :snap (:hand-r :flex -72.4 :side -4.4))
  (6.25 :snap (:hand-r :flex -68.0 :side -15.0))
  (7.375 :snap (:hand-r :flex -72.4 :side -25.6))
  (8.5 :snap (:hand-r :flex -83.0 :side -30.0))
  (9.625 :snap (:hand-r :flex -93.6 :side -25.6))
  (10.75 :snap (:hand-r :flex -98.0 :side -15.0))
  (11.875 :snap (:hand-r :flex -93.6 :side -4.4))
  (13 :snap (:hand-r :flex -83.0 :side 0.0))
  (14 (:hand-r :flex -86) (:arm-r :flex 130.5))
  (:s :snap :ya-n2b-hit)
  (:a :ya-n2b-land)
  (28 (:root :yaw 8 :f 0.08 :u -0.05) (:chest :twist 4) (:spine :flex 10) (:thigh-l :flex 20) (:knee-l :flex 22) (:thigh-r :flex -8)
      (:arm-r :flex 70 :side -20 :twist 0) (:elbow-r :flex 22) (:hand-r :twist 0 :flex -80))
  (:end :ya-stance))
;; NS2c (S18; F11: the only tell, no ground sign), the call: the blade raised point-up overhead f1-8 (a key a frame), held f9-14 (fire
;; climbing it, a tremble), chopped down to the level point on S (f15-17 faster each frame); AS2b plays the same poses from AS2a's S+A
(defpose :ya-n2c-up (:base :ya-n1b-hit) (:root :f 0.08 :u 0.02) (:spine :flex -6) (:head :flex -32))
(defpose :ya-n2c-hit (:base :ya-n2a-hit) (:root :yaw 8 :f 0.1 :u -0.09) (:thigh-l :flex 28) (:knee-l :flex 26) (:thigh-r :flex -10) (:hand-r :flex -86))
(defpose :ya-n2c-land (:base :ya-n2c-hit) (:root :u -0.095) (:arm-r :flex 131))
(defstrike :ya-n2c (18 2 30 :base :ya-stance)
  (0 :ya-n2b-land)
  (1 (:root :u -0.072 :f 0.153 :yaw 12.8) (:spine :flex 5.0) (:chest :twist 15.9) (:neck :flex -8.8) (:head :flex -15.5)
        (:arm-r :flex 130.5 :twist -17.3 :side -48.1) (:elbow-r :flex 2.4) (:hand-r :flex -88.4 :twist -4.3) (:thigh-r :flex -14.4)
        (:knee-r :flex 16.9) (:thigh-l :flex 35.2) (:knee-l :flex 31.6))
  (2 (:root :u -0.06 :f 0.144 :yaw 11.2) (:spine :flex 3.6) (:chest :twist 12.7) (:neck :flex -10.0) (:head :flex -17.7)
        (:arm-r :flex 131.2 :twist -17.0 :side -43.1) (:elbow-r :flex 3.6) (:hand-r :flex -84.7 :twist -1.1) (:thigh-r :flex -11.9)
        (:knee-r :flex 15.4) (:thigh-l :flex 31.1) (:knee-l :flex 28.1))
  (3 (:root :u -0.046 :f 0.132 :yaw 9.2) (:spine :flex 1.9) (:chest :twist 9.1) (:neck :flex -11.4) (:head :flex -20.2)
        (:arm-r :flex 132.1 :twist -16.6 :side -37.2) (:elbow-r :flex 5.1) (:hand-r :flex -80.3 :twist 2.6) (:thigh-r :flex -9.1) (:knee-r :flex 13.5)
        (:thigh-l :flex 26.3) (:knee-l :flex 24.0))
  (4 (:root :u -0.03 :f 0.12 :yaw 7.0) (:spine :flex 0.0) (:chest :twist 5.0) (:neck :flex -13.0) (:head :flex -23.0)
        (:arm-r :flex 133.0 :twist -16.2 :side -30.7) (:elbow-r :flex 6.8) (:hand-r :flex -75.5 :twist 6.8) (:thigh-r :flex -6.0) (:knee-r :flex 11.5)
        (:thigh-l :flex 21.0) (:knee-l :flex 19.5))
  (5 (:root :u -0.014 :f 0.108 :yaw 4.8) (:spine :flex -1.9) (:chest :twist 0.9) (:neck :flex -14.6) (:head :flex -25.8)
        (:arm-r :flex 133.9 :twist -15.9 :side -24.3) (:elbow-r :flex 8.4) (:hand-r :flex -70.7 :twist 10.9) (:thigh-r :flex -2.9) (:knee-r :flex 9.5)
        (:thigh-l :flex 15.7) (:knee-l :flex 15.0))
  (6 (:root :u 0.0 :f 0.096 :yaw 2.8) (:spine :flex -3.6) (:chest :twist -2.7) (:neck :flex -16.0) (:head :flex -28.3)
        (:arm-r :flex 134.8 :twist -15.5 :side -18.4) (:elbow-r :flex 9.9) (:hand-r :flex -66.3 :twist 14.6) (:thigh-r :flex -0.1) (:knee-r :flex 7.6)
        (:thigh-l :flex 10.9) (:knee-l :flex 10.9))
  (7 (:root :u 0.012 :f 0.087 :yaw 1.2) (:spine :flex -5.0) (:chest :twist -5.9) (:neck :flex -17.2) (:head :flex -30.5)
        (:arm-r :flex 135.5 :twist -15.2 :side -13.4) (:elbow-r :flex 11.1) (:hand-r :flex -62.6 :twist 17.8) (:thigh-r :flex 2.4) (:knee-r :flex 6.1)
        (:thigh-l :flex 6.8) (:knee-l :flex 7.4))
  (8 (:root :u 0.02 :f 0.08 :yaw 0.0) (:spine :flex -6.0) (:chest :twist -8.0) (:neck :flex -18.0) (:head :flex -32.0)
        (:arm-r :flex 136.0 :twist -15.0 :side -10.0) (:elbow-r :flex 12.0) (:hand-r :flex -60.0 :twist 20.0) (:thigh-r :flex 4.0) (:knee-r :flex 5.0)
        (:thigh-l :flex 4.0) (:knee-l :flex 5.0))
  (9 :ya-n2c-up (:arm-r :flex 137) (:root :u 0.025))                                          ; held, fire climbing it
  (10 :ya-n2c-up (:arm-r :flex 135.5))
  (11 :ya-n2c-up (:arm-r :flex 137) (:root :u 0.025))
  (12 :ya-n2c-up (:arm-r :flex 135.5) (:hand-r :flex -61))
  (13 :ya-n2c-up (:arm-r :flex 137))
  (14 :ya-n2c-up (:arm-r :flex 136))
  (15 :ya-n2c-up (:arm-r :flex 137) (:root :u 0.025))
  (16 :snap :ya-n2c-up (:root :u -0.013 :f 0.086 :yaw 2.4) (:spine :flex -2.4) (:chest :twist -0.2) (:neck :flex -15.0) (:head :flex -26.6)
        (:arm-r :flex 135.1 :twist -15.7 :side -22.4) (:elbow-r :flex 8.8) (:hand-r :flex -67.8 :twist 12.0) (:thigh-r :flex -0.2) (:knee-r :flex 8.9)
        (:thigh-l :flex 11.2) (:knee-l :flex 11.3))
  (17 :snap :ya-n2c-up (:root :u -0.057 :f 0.094 :yaw 5.6) (:spine :flex 2.4) (:chest :twist 10.2) (:neck :flex -11.0) (:head :flex -19.4)
        (:arm-r :flex 133.9 :twist -16.8 :side -39.0) (:elbow-r :flex 4.7) (:hand-r :flex -78.2 :twist 1.4) (:thigh-r :flex -5.8) (:knee-r :flex 14.1)
        (:thigh-l :flex 20.8) (:knee-l :flex 19.7))
  (:s :snap :ya-n2c-hit)
  (:a :ya-n2c-land)
  (34 (:root :yaw 6 :f 0.06 :u -0.05) (:chest :twist 4) (:spine :flex 10) (:thigh-l :flex 18) (:knee-l :flex 20) (:thigh-r :flex -6)
      (:arm-r :flex 70 :side -20 :twist 0) (:elbow-r :flex 22) (:hand-r :twist 0 :flex -80))
  (:end :ya-stance))
;; AS2a (S12), the flick: from J2's S+1 (high right) the point brought level to his right f1-6, held f7-9, flicked level R->L across his
;; chest on a short lunge (the tip 1.90 m out on S, 1.80 m at his left front on S+2: the move's 2.0 m arc 120): the tip draws the ring
(defpose :ya-q2-thru (:base :ya-q2-hit)                     ; J2's S+1 (f9) as :YA-Q2 draws it: AS2a starts here
  (:chest :twist -28) (:spine :flex 8) (:root :u -0.02) (:head :flex -24) (:arm-r :flex 79 :side -2 :twist -39) (:elbow-r :flex 7) (:hand-r :twist 20 :flex -20))
(defpose :ya-as2a-cock (:base :ya-stance)
  (:root :u -0.06) (:chest :twist -25) (:spine :flex 10) (:head :flex -20) (:arm-r :flex 53 :side 76.5 :twist -29.5) (:elbow-r :flex 20.5) (:hand-r :flex -90 :twist -18 :side 0))
(defpose :ya-as2a-hit (:base :ya-stance)
  (:root :yaw 6 :f 0.2 :u -0.08) (:chest :twist 15) (:spine :flex 10) (:head :flex -20) (:thigh-l :flex 35) (:knee-l :flex 32) (:thigh-r :flex -16)
  (:arm-r :flex 120 :side -44.5 :twist 7.5) (:elbow-r :flex 0) (:hand-r :flex -88.5 :twist 7.5 :side 0))
(defpose :ya-as2a-thru (:base :ya-as2a-hit) (:chest :twist 25) (:arm-r :flex 108 :side -16 :twist 40.5) (:hand-r :flex -78 :twist 10 :side -1.5))
(defpose :ya-as2a-land (:base :ya-as2a-thru) (:chest :twist 27) (:arm-r :flex 104 :side -12))   ; (S+A: AS2b starts here)
(defstrike :ya-as2a (12 3 16 :base :ya-stance)
  (0 :ya-q2-thru)
  (1 (:root :u -0.023) (:spine :flex 8.1) (:chest :twist -27.8) (:neck :flex -19.9) (:head :flex -23.7) (:arm-r :flex 77.1 :twist -38.3 :side 3.8)
        (:elbow-r :flex 8.0) (:hand-r :flex -25.2 :twist 17.2))
  (2 (:root :u -0.03) (:spine :flex 8.5) (:chest :twist -27.2) (:neck :flex -19.5) (:head :flex -23.0) (:arm-r :flex 72.3 :twist -36.5 :side 18.4)
        (:elbow-r :flex 10.5) (:hand-r :flex -38.1 :twist 10.1))
  (3 (:root :u -0.04) (:spine :flex 9.0) (:chest :twist -26.5) (:neck :flex -19.0) (:head :flex -22.0) (:arm-r :flex 66.0 :twist -34.2 :side 37.3)
        (:elbow-r :flex 13.8) (:hand-r :flex -55.0 :twist 1.0))
  (4 (:root :u -0.05) (:spine :flex 9.5) (:chest :twist -25.8) (:neck :flex -18.5) (:head :flex -21.0) (:arm-r :flex 59.7 :twist -32.0 :side 56.1)
        (:elbow-r :flex 17.0) (:hand-r :flex -71.9 :twist -8.1))
  (5 (:root :u -0.057) (:spine :flex 9.9) (:chest :twist -25.2) (:neck :flex -18.1) (:head :flex -20.3) (:arm-r :flex 54.9 :twist -30.2 :side 70.7)
        (:elbow-r :flex 19.5) (:hand-r :flex -84.8 :twist -15.2))
  (6 (:root :u -0.06) (:spine :flex 10.0) (:chest :twist -25.0) (:neck :flex -18.0) (:head :flex -20.0) (:arm-r :flex 53.0 :twist -29.5 :side 76.5)
        (:elbow-r :flex 20.5) (:hand-r :flex -90.0 :twist -18.0))
  (7 :ya-as2a-cock (:arm-r :side 77.5))                                                         ; held
  (8 :ya-as2a-cock (:arm-r :side 76) (:root :u -0.065))
  (9 :ya-as2a-cock (:arm-r :side 77))
  (10 :snap :ya-as2a-cock (:root :u -0.065 :f 0.05 :yaw 1.5) (:chest :twist -15.0) (:arm-r :flex 69.8 :twist -20.2 :side 46.2) (:elbow-r :flex 15.4)
        (:hand-r :flex -89.6 :twist -11.6) (:thigh-r :flex -10.0) (:thigh-l :flex 22.2) (:knee-l :flex 24.5))
  (11 :snap :ya-as2a-cock (:root :u -0.072 :f 0.124 :yaw 3.7) (:chest :twist -0.2) (:arm-r :flex 94.5 :twist -6.6 :side 1.5) (:elbow-r :flex 7.8)
        (:hand-r :flex -89.1 :twist -2.2) (:thigh-r :flex -13.0) (:thigh-l :flex 28.5) (:knee-l :flex 28.2))
  (:s :snap :ya-as2a-hit)
  (13 :snap :ya-as2a-hit (:chest :twist 20.0) (:arm-r :flex 114.0 :twist 24.0 :side -30.2) (:hand-r :flex -83.3 :twist 8.7 :side -0.8))
  (14 :snap :ya-as2a-thru)
  (:a :ya-as2a-land)
  (24 (:root :yaw 4 :f 0.1 :u -0.05) (:chest :twist 8) (:spine :flex 10) (:thigh-l :flex 18) (:knee-l :flex 20) (:thigh-r :flex -6)
      (:arm-r :flex 60 :side -10 :twist 10) (:elbow-r :flex 22) (:hand-r :twist 0 :flex -80))
  (:end :ya-stance))
(defstrike :ya-as2b (18 2 30 :base :ya-stance)
  (0 :ya-as2a-land)
  (1 (:root :u -0.072 :f 0.19 :yaw 5.5) (:spine :flex 8.7) (:chest :twist 24.1) (:head :flex -21.0) (:arm-r :flex 106.6 :twist 35.9 :side -11.8)
        (:elbow-r :flex 1.0) (:hand-r :flex -76.5 :twist 10.8 :side -1.4) (:thigh-r :flex -14.4) (:knee-r :flex 16.9) (:thigh-l :flex 32.4)
        (:knee-l :flex 29.8))
  (2 (:root :u -0.06 :f 0.176 :yaw 4.8) (:spine :flex 6.8) (:chest :twist 19.9) (:head :flex -22.4) (:arm-r :flex 110.5 :twist 29.2 :side -11.6)
        (:elbow-r :flex 2.4) (:hand-r :flex -74.3 :twist 12.0 :side -1.2) (:thigh-r :flex -11.9) (:knee-r :flex 15.4) (:thigh-l :flex 28.7)
        (:knee-l :flex 26.5))
  (3 (:root :u -0.046 :f 0.159 :yaw 3.9) (:spine :flex 4.5) (:chest :twist 15.0) (:head :flex -24.1) (:arm-r :flex 115.0 :twist 21.4 :side -11.3)
        (:elbow-r :flex 4.1) (:hand-r :flex -71.8 :twist 13.4 :side -1.0) (:thigh-r :flex -9.1) (:knee-r :flex 13.5) (:thigh-l :flex 24.3)
        (:knee-l :flex 22.7))
  (4 (:root :u -0.03 :f 0.14 :yaw 3.0) (:spine :flex 2.0) (:chest :twist 9.5) (:head :flex -26.0) (:arm-r :flex 120.0 :twist 12.7 :side -11.0)
        (:elbow-r :flex 6.0) (:hand-r :flex -69.0 :twist 15.0 :side -0.8) (:thigh-r :flex -6.0) (:knee-r :flex 11.5) (:thigh-l :flex 19.5)
        (:knee-l :flex 18.5))
  (5 (:root :u -0.014 :f 0.121 :yaw 2.1) (:spine :flex -0.5) (:chest :twist 4.0) (:head :flex -27.9) (:arm-r :flex 125.0 :twist 4.1 :side -10.7)
        (:elbow-r :flex 7.9) (:hand-r :flex -66.2 :twist 16.6 :side -0.5) (:thigh-r :flex -2.9) (:knee-r :flex 9.5) (:thigh-l :flex 14.7)
        (:knee-l :flex 14.3))
  (6 (:root :u 0.0 :f 0.104 :yaw 1.2) (:spine :flex -2.8) (:chest :twist -0.9) (:head :flex -29.6) (:arm-r :flex 129.5 :twist -3.7 :side -10.4)
        (:elbow-r :flex 9.6) (:hand-r :flex -63.7 :twist 18.0 :side -0.3) (:thigh-r :flex -0.1) (:knee-r :flex 7.6) (:thigh-l :flex 10.3)
        (:knee-l :flex 10.5))
  (7 (:root :u 0.012 :f 0.09 :yaw 0.5) (:spine :flex -4.7) (:chest :twist -5.1) (:head :flex -31.0) (:arm-r :flex 133.4 :twist -10.4 :side -10.2)
        (:elbow-r :flex 11.0) (:hand-r :flex -61.5 :twist 19.2 :side -0.1) (:thigh-r :flex 2.4) (:knee-r :flex 6.1) (:thigh-l :flex 6.6)
        (:knee-l :flex 7.2))
  (8 (:root :u 0.02 :f 0.08 :yaw 0.0) (:spine :flex -6.0) (:chest :twist -8.0) (:head :flex -32.0) (:arm-r :flex 136.0 :twist -15.0 :side -10.0)
        (:elbow-r :flex 12.0) (:hand-r :flex -60.0 :twist 20.0 :side 0.0) (:thigh-r :flex 4.0) (:knee-r :flex 5.0) (:thigh-l :flex 4.0)
        (:knee-l :flex 5.0))
  (9 :ya-n2c-up (:arm-r :flex 137) (:root :u 0.025))                                          ; held, fire climbing it
  (10 :ya-n2c-up (:arm-r :flex 135.5))
  (11 :ya-n2c-up (:arm-r :flex 137) (:root :u 0.025))
  (12 :ya-n2c-up (:arm-r :flex 135.5) (:hand-r :flex -61))
  (13 :ya-n2c-up (:arm-r :flex 137))
  (14 :ya-n2c-up (:arm-r :flex 136))
  (15 :ya-n2c-up (:arm-r :flex 137) (:root :u 0.025))
  (16 :snap :ya-n2c-up (:root :u -0.013 :f 0.086 :yaw 2.4) (:spine :flex -2.4) (:chest :twist -0.2) (:neck :flex -15.0) (:head :flex -26.6)
        (:arm-r :flex 135.1 :twist -15.7 :side -22.4) (:elbow-r :flex 8.8) (:hand-r :flex -67.8 :twist 12.0) (:thigh-r :flex -0.2) (:knee-r :flex 8.9)
        (:thigh-l :flex 11.2) (:knee-l :flex 11.3))
  (17 :snap :ya-n2c-up (:root :u -0.057 :f 0.094 :yaw 5.6) (:spine :flex 2.4) (:chest :twist 10.2) (:neck :flex -11.0) (:head :flex -19.4)
        (:arm-r :flex 133.9 :twist -16.8 :side -39.0) (:elbow-r :flex 4.7) (:hand-r :flex -78.2 :twist 1.4) (:thigh-r :flex -5.8) (:knee-r :flex 14.1)
        (:thigh-l :flex 20.8) (:knee-l :flex 19.7))
  (:s :snap :ya-n2c-hit)
  (:a :ya-n2c-land)
  (34 (:root :yaw 6 :f 0.06 :u -0.05) (:chest :twist 4) (:spine :flex 10) (:thigh-l :flex 18) (:knee-l :flex 20) (:thigh-r :flex -6)
      (:arm-r :flex 70 :side -20 :twist 0) (:elbow-r :flex 22) (:hand-r :twist 0 :flex -80))
  (:end :ya-stance))
;; 爆炎 NS2b (S16; batch J3, DUEL_YAMA_CORE §28.5): its own clip (it played NS2c's at x18/16). "The ring closes at once" (§21.4): from
;; 爆炎 NS2a's landing (:YA-N2A-SWEEP, as the Shikai's NS2b; the point back ahead on :YA-N2A-LAND by f2) the wrist flicks one circle with the point f2-6 (a key a frame: the ring
;; YAMA-RING-CLOSE draws f12-15), the blade swept up point-up overhead f7-11 (NS2c's rise, twice as fast), held f11-13 trembling, chopped
;; down f14-15 (NS2c's two snaps) to the level point on S (:YA-N2C-HIT: the dome stands); S+A is ENNETSU's frame 0 exactly (link jump 0)
(defstrike :ya-b-n2b (16 2 20 :base :ya-stance)
  (0 :ya-n2a-sweep)                                                                           ; (NS2a's S+A since art batch B: the point
  (2 :ya-n2a-land (:root :u -0.08) (:hand-r :flex -83 :side 0))                               ;  back ahead f1-2) the circle, a key a frame
  (3 (:hand-r :flex -68 :side -15))
  (4 (:hand-r :flex -83 :side -30))
  (5 (:hand-r :flex -98 :side -15))
  (6 (:hand-r :flex -83 :side 0) (:arm-r :flex 130.5))
  (8 :ya-n2b-land (:root :u -0.046 :f 0.132 :yaw 9.2) (:spine :flex 1.9) (:chest :twist 9.1) (:neck :flex -11.4) (:head :flex -20.2)   ; (NS2c's f3)
        (:arm-r :flex 132.1 :twist -16.6 :side -37.2) (:elbow-r :flex 5.1) (:hand-r :flex -80.3 :twist 2.6) (:thigh-r :flex -9.1) (:knee-r :flex 13.5)
        (:thigh-l :flex 26.3) (:knee-l :flex 24.0))
  (10 (:root :u 0.0 :f 0.096 :yaw 2.8) (:spine :flex -3.6) (:chest :twist -2.7) (:neck :flex -16.0) (:head :flex -28.3)                 ; (NS2c's f6)
        (:arm-r :flex 134.8 :twist -15.5 :side -18.4) (:elbow-r :flex 9.9) (:hand-r :flex -66.3 :twist 14.6) (:thigh-r :flex -0.1) (:knee-r :flex 7.6)
        (:thigh-l :flex 10.9) (:knee-l :flex 10.9))
  (11 :ya-n2c-up (:arm-r :flex 137) (:root :u 0.025))                                          ; overhead, held, trembling
  (12 :ya-n2c-up (:arm-r :flex 135.5) (:hand-r :flex -61))
  (13 :ya-n2c-up (:arm-r :flex 137) (:root :u 0.025))
  (14 :snap :ya-n2c-up (:root :u -0.013 :f 0.086 :yaw 2.4) (:spine :flex -2.4) (:chest :twist -0.2) (:neck :flex -15.0) (:head :flex -26.6)
        (:arm-r :flex 135.1 :twist -15.7 :side -22.4) (:elbow-r :flex 8.8) (:hand-r :flex -67.8 :twist 12.0) (:thigh-r :flex -0.2) (:knee-r :flex 8.9)
        (:thigh-l :flex 11.2) (:knee-l :flex 11.3))
  (15 :snap :ya-n2c-up (:root :u -0.057 :f 0.094 :yaw 5.6) (:spine :flex 2.4) (:chest :twist 10.2) (:neck :flex -11.0) (:head :flex -19.4)
        (:arm-r :flex 133.9 :twist -16.8 :side -39.0) (:elbow-r :flex 4.7) (:hand-r :flex -78.2 :twist 1.4) (:thigh-r :flex -5.8) (:knee-r :flex 14.1)
        (:thigh-l :flex 20.8) (:knee-l :flex 19.7))
  (:s :snap :ya-n2c-hit)
  (:a :ya-n2c-land (:root :u -0.093 :f 0.098 :yaw 7.9) (:spine :flex 6.2) (:chest :twist 17.3) (:arm-r :flex 127.8 :twist -16.6 :side -49.8)   ; (= :YA-B-N2C's
     (:elbow-r :flex 2.6) (:hand-r :flex -85.7 :twist -6.2) (:thigh-r :flex -9.8) (:thigh-l :flex 27.5) (:knee-l :flex 25.7))                ;  frame 0)
  (30 (:root :yaw 6 :f 0.06 :u -0.05) (:chest :twist 4) (:spine :flex 10) (:thigh-l :flex 18) (:knee-l :flex 20) (:thigh-r :flex -6)
      (:arm-r :flex 70 :side -20 :twist 0) (:elbow-r :flex 22) (:hand-r :twist 0 :flex -80))
  (:end :ya-stance))
;; 爆炎 NS2c ENNETSU JIGOKU (S18; art S4, DUEL_YAMA_CORE §21.4 / §25): its own clip (it played NS2a's :YA-ENJO at x1.11, which ended at f40
;; of the 50 f move and held the stance pose). Frame 0 is 爆炎 NS2b's landing (NS2c's clip at x18/16 drawn at its f18: :YA-N2C's f20.25,
;; sampled); the arm drops and draws the hilt back to his right hip, the point hanging toward the plaza (f1-10, :YA-B-N2C-COCK), held f11-15;
;; the point driven down into the plaza at his right front on S (:YA-B-N2C-HIT: the tip 1.08 m ahead, on the floor), left in it while the
;; rows of pillars run (to f30), drawn out into the stance
(defpose :ya-b-n2c-cock (:base :ya-stance)                   ; the hilt drawn back at his right hip, the point hanging down-forward
  (:root :u -0.06 :yaw -8) (:spine :flex 8) (:chest :twist -24) (:neck :flex -16) (:head :flex -20 :twist 10) (:knees :flex 20)
  (:arm-r :flex -19 :side 26.5 :twist -7) (:elbow-r :flex 99.5) (:hand-r :flex -117 :twist 36.5 :side -0.5))
(defpose :ya-b-n2c-hit (:base :ya-stance)                    ; crouched over it, the point in the plaza 1.08 m ahead
  (:root :f 0.12 :u -0.2 :yaw 4) (:spine :flex 30) (:chest :twist 8) (:neck :flex -20) (:head :flex -30) (:knees :flex 44) (:thigh-l :flex 52)
  (:thigh-r :flex 20) (:arm-r :flex 110 :side -40.5 :twist -41.5) (:elbow-r :flex 53) (:hand-r :flex -131.5 :twist -40 :side 16))
(defstrike :ya-b-n2c (18 2 30 :base :ya-stance)
  (0 :ya-n2c-land (:root :u -0.093 :f 0.098 :yaw 7.9) (:spine :flex 6.2) (:chest :twist 17.3) (:arm-r :flex 127.8 :twist -16.6 :side -49.8)
     (:elbow-r :flex 2.6) (:hand-r :flex -85.7 :twist -6.2) (:thigh-r :flex -9.8) (:thigh-l :flex 27.5) (:knee-l :flex 25.7))
  (1 (:root :u -0.092 :f 0.094 :yaw 7.3) (:spine :flex 6.3) (:chest :twist 15.6) (:neck :flex -8.3) (:head :flex -14.2 :twist 0.4) (:arm-r :flex 121.8 :twist -16.2 :side -46.7) (:elbow-r :flex 6.5) (:hand-r :flex -87.0 :twist -4.5) (:thigh-r :flex -9.7) (:knee-r :flex 18.1) (:thigh-l :flex 27.1) (:knee-l :flex 25.5))
  (2 (:root :u -0.089 :f 0.087 :yaw 6.2) (:spine :flex 6.4) (:chest :twist 12.9) (:neck :flex -8.9) (:head :flex -14.6 :twist 1.1) (:arm-r :flex 112.0 :twist -15.6 :side -41.6) (:elbow-r :flex 13.0) (:hand-r :flex -89.1 :twist -1.6) (:thigh-r :flex -9.6) (:knee-r :flex 18.2) (:thigh-l :flex 26.5) (:knee-l :flex 25.1))
  (3 (:root :u -0.087 :f 0.079 :yaw 4.9) (:spine :flex 6.5) (:chest :twist 9.5) (:neck :flex -9.5) (:head :flex -15.1 :twist 1.9) (:arm-r :flex 100.0 :twist -14.8 :side -35.3) (:elbow-r :flex 21.0) (:hand-r :flex -91.6 :twist 1.9) (:thigh-r :flex -9.5) (:knee-r :flex 18.4) (:thigh-l :flex 25.7) (:knee-l :flex 24.6))
  (4 (:root :u -0.084 :f 0.07 :yaw 3.4) (:spine :flex 6.7) (:chest :twist 5.6) (:neck :flex -10.3) (:head :flex -15.7 :twist 2.8) (:arm-r :flex 86.2 :twist -13.9 :side -28.2) (:elbow-r :flex 30.1) (:hand-r :flex -94.6 :twist 5.9) (:thigh-r :flex -9.3) (:knee-r :flex 18.6) (:thigh-l :flex 24.8) (:knee-l :flex 24.1))
  (5 (:root :u -0.08 :f 0.06 :yaw 1.7) (:spine :flex 6.9) (:chest :twist 1.3) (:neck :flex -11.1) (:head :flex -16.3 :twist 3.9) (:arm-r :flex 70.9 :twist -12.9 :side -20.2) (:elbow-r :flex 40.1) (:hand-r :flex -97.8 :twist 10.3 :side -0.2) (:thigh-r :flex -9.1) (:knee-r :flex 18.8) (:thigh-l :flex 23.8) (:knee-l :flex 23.5))
  (6 (:root :u -0.076 :f 0.049 :yaw -0.1) (:spine :flex 7.1) (:chest :twist -3.4) (:neck :flex -12.0) (:head :flex -17.0 :twist 5.0) (:arm-r :flex 54.4 :twist -11.8 :side -11.6) (:elbow-r :flex 51.0) (:hand-r :flex -101.3 :twist 15.1 :side -0.3) (:thigh-r :flex -8.9) (:knee-r :flex 19.0) (:thigh-l :flex 22.8) (:knee-l :flex 22.9))
  (7 (:root :u -0.073 :f 0.038 :yaw -1.8) (:spine :flex 7.3) (:chest :twist -8.0) (:neck :flex -12.9) (:head :flex -17.7 :twist 6.1) (:arm-r :flex 37.9 :twist -10.7 :side -3.1) (:elbow-r :flex 62.0) (:hand-r :flex -104.9 :twist 20.0 :side -0.3) (:thigh-r :flex -8.7) (:knee-r :flex 19.2) (:thigh-l :flex 21.7) (:knee-l :flex 22.2))
  (8 (:root :u -0.069 :f 0.028 :yaw -3.5) (:spine :flex 7.5) (:chest :twist -12.3) (:neck :flex -13.7) (:head :flex -18.3 :twist 7.2) (:arm-r :flex 22.6 :twist -9.7 :side 4.9) (:elbow-r :flex 72.0) (:hand-r :flex -108.1 :twist 24.4 :side -0.4) (:thigh-r :flex -8.5) (:knee-r :flex 19.4) (:thigh-l :flex 20.7) (:knee-l :flex 21.6))
  (9 (:root :u -0.066 :f 0.019 :yaw -5.0) (:spine :flex 7.7) (:chest :twist -16.2) (:neck :flex -14.5) (:head :flex -18.9 :twist 8.1) (:arm-r :flex 8.8 :twist -8.8 :side 12.0) (:elbow-r :flex 81.1) (:hand-r :flex -111.1 :twist 28.4) (:thigh-r :flex -8.3) (:knee-r :flex 19.6) (:thigh-l :flex 19.8) (:knee-l :flex 21.1))
  (10 (:root :u -0.064 :f 0.011 :yaw -6.3) (:spine :flex 7.8) (:chest :twist -19.6) (:neck :flex -15.1) (:head :flex -19.4 :twist 8.9) (:arm-r :flex -3.2 :twist -8.0 :side 18.3) (:elbow-r :flex 89.1) (:hand-r :flex -113.6 :twist 31.9) (:thigh-r :flex -8.2) (:knee-r :flex 19.8) (:thigh-l :flex 19.0) (:knee-l :flex 20.6))
  (11 (:root :u -0.061 :f 0.004 :yaw -7.4) (:spine :flex 7.9) (:chest :twist -22.3) (:neck :flex -15.7) (:head :flex -19.8 :twist 9.6) (:arm-r :flex -13.0 :twist -7.4 :side 23.4) (:elbow-r :flex 95.6) (:hand-r :flex -115.7 :twist 34.8) (:thigh-r :flex -8.1) (:knee-r :flex 19.9) (:thigh-l :flex 18.4) (:knee-l :flex 20.2))
  (12 :ya-b-n2c-cock)                                                                         ; drawn back, the point hanging
  (13 :ya-b-n2c-cock (:root :u -0.065) (:hand-r :flex -118))                                ; held
  (15 :ya-b-n2c-cock (:root :u -0.062) (:hand-r :flex -116))
  (16 :snap :ya-b-n2c-cock (:root :u -0.077 :f 0.014 :yaw -6.6) (:spine :flex 10.6) (:chest :twist -20.2) (:neck :flex -16.5) (:head :flex -21.2 :twist 8.8) (:arm-r :flex -3.5 :twist -11.1 :side 18.5) (:elbow-r :flex 93.9) (:hand-r :flex -118.7 :twist 27.3 :side 1.5) (:thigh-r :flex -4.6) (:knee-r :flex 22.9) (:thigh-l :flex 22.1) (:knee-l :flex 22.9))
  (17 :snap :ya-b-n2c-cock (:root :u -0.123 :f 0.054 :yaw -2.6) (:spine :flex 17.9) (:chest :twist -9.6) (:neck :flex -17.8) (:head :flex -24.5 :twist 5.5) (:arm-r :flex 39.0 :twist -22.5 :side -3.7) (:elbow-r :flex 78.6) (:hand-r :flex -123.5 :twist 2.1 :side 6.9) (:thigh-r :flex 4.6) (:knee-r :flex 30.8) (:thigh-l :flex 33.3) (:knee-l :flex 30.8))
  (:s :snap :ya-b-n2c-hit)                                                                    ; driven into the plaza
  (:a :ya-b-n2c-hit (:root :u -0.21))
  (30 :ya-b-n2c-hit (:root :u -0.2) (:head :flex -24))                                       ; left in it while the rows run
  (40 (:root :yaw 2 :f 0.06 :u -0.1) (:spine :flex 18) (:chest :twist 2) (:head :flex -20) (:knees :flex 24) (:thigh-l :flex 30) (:thigh-r :flex 6)
      (:arm-r :flex 50 :side -10 :twist -16) (:elbow-r :flex 50) (:hand-r :flex -100 :twist -10 :side 6))   ; drawn out
  (:end :ya-stance))
;; Pointer 3 撫斬 NADEGIRI, art S3: NS3a from pointer 3's stance (:YA-ST-NADE), NS3b from NS3a's S+A (:YA-N3A-LAND), NS3c from NS3b's S+A
;; (:YA-N3B-LAND), AS3a from J3's S+1 (:YA-TSUKA-THRU), AS3b from AS3a's S+A (:YA-AS3A-LAND), AS3c from AS3b's S+A (:YA-AS3B-LAND) on NS3c's
;; poses. The slides (NS3a 1.0 m, NS3b 2.0 m) are the sim's: the drawn root moves 0.1 m at most, the legs make the step.
;; NS3a (S18, the opener's tell), Onibi's jab: the blade pulled up out of the plaza and levelled low at his right hip f1-12 (a key a frame),
;; held f13-15, a low rising jab of the point on S (the tip 1.68 m ahead, 1.14 m up)
(defpose :ya-n3a-low (:base :ya-stance)
  (:root :u -0.12) (:knees :flex 38) (:thighs :flex 28) (:chest :twist -14) (:spine :flex 16) (:head :flex -20)
  (:arm-r :flex -40 :side 10.5 :twist -4.5) (:elbow-r :flex 92) (:hand-r :flex -22.5 :twist -2.5 :side -27.5))
(defpose :ya-n3a-hit (:base :ya-stance)
  (:root :yaw 6 :f 0.1 :u -0.14) (:chest :twist 12) (:spine :flex 20) (:head :flex -22) (:thigh-l :flex 48) (:knee-l :flex 44) (:thigh-r :flex -24) (:knee-r :flex 18)
  (:arm-r :flex 80.5 :side -60 :twist -0.5) (:elbow-r :flex 35) (:hand-r :flex -53 :twist 27 :side 0.5))
(defpose :ya-n3a-land (:base :ya-n3a-hit) (:arm-r :flex 82) (:hand-r :flex -50))   ; (S+A: NS3b starts here)
;; (J3, §28.5: f1-4's hand :side eased 27.5 / 19.6 / 11.2 / 3.4, was 11.5 / 8.6 / 5.2 / 1.4, out of stance 3's slanted blade, side 33.5)
(defstrike :ya-n3a (18 3 18 :base :ya-stance)
  (0 :ya-st-nade)
  (1 (:root :u -0.015) (:pelvis :twist 0.5) (:spine :flex 6.5) (:chest :twist -0.7) (:neck :flex -10.4) (:head :flex -25.7)
        (:arm-r :flex -15.7 :twist 4.5 :side 21.4) (:elbow-r :flex 84.9) (:hand-r :flex 36.5 :twist 142.6 :side 27.5) (:thigh-r :flex 1.4 :side 6.1)
        (:knee-r :flex 9.5) (:thigh-l :flex 1.4) (:knee-l :flex 9.5))
  (2 (:root :u -0.023) (:pelvis :twist 1.2) (:spine :flex 7.2) (:chest :twist -1.7) (:neck :flex -11.0) (:head :flex -25.3)
        (:arm-r :flex -17.6 :twist 3.9 :side 20.6) (:elbow-r :flex 85.4) (:hand-r :flex 32.1 :twist 131.7 :side 19.6) (:thigh-r :flex 3.4 :side 6.2)
        (:knee-r :flex 11.6) (:thigh-l :flex 3.4) (:knee-l :flex 11.6))
  (3 (:root :u -0.032) (:pelvis :twist 2.0) (:spine :flex 8.0) (:chest :twist -2.8) (:neck :flex -11.6) (:head :flex -24.8)
        (:arm-r :flex -19.7 :twist 3.1 :side 19.7) (:elbow-r :flex 86.0) (:hand-r :flex 26.9 :twist 119.0 :side 11.2) (:thigh-r :flex 5.7 :side 6.4)
        (:knee-r :flex 14.1) (:thigh-l :flex 5.7) (:knee-l :flex 14.1))
  (4 (:root :u -0.042) (:pelvis :twist 3.0) (:spine :flex 9.0) (:chest :twist -4.1) (:neck :flex -12.4) (:head :flex -24.2)
        (:arm-r :flex -22.0 :twist 2.2 :side 18.6) (:elbow-r :flex 86.7) (:hand-r :flex 21.2 :twist 105.0 :side 3.4) (:thigh-r :flex 8.3 :side 6.6)
        (:knee-r :flex 16.9) (:thigh-l :flex 8.3) (:knee-l :flex 16.9))
  (5 (:root :u -0.053) (:pelvis :twist 3.9) (:spine :flex 9.9) (:chest :twist -5.5) (:neck :flex -13.2) (:head :flex -23.6)
        (:arm-r :flex -24.6 :twist 1.3 :side 17.5) (:elbow-r :flex 87.5) (:hand-r :flex 15.0 :twist 89.8 :side -2.7) (:thigh-r :flex 11.0 :side 6.8)
        (:knee-r :flex 19.8) (:thigh-l :flex 11.0) (:knee-l :flex 19.8))
  (6 (:root :u -0.065) (:pelvis :twist 5.0) (:spine :flex 11.0) (:chest :twist -7.0) (:neck :flex -14.0) (:head :flex -23.0)
        (:arm-r :flex -27.2 :twist 0.2 :side 16.2) (:elbow-r :flex 88.2) (:hand-r :flex 8.5 :twist 73.8 :side -7.0) (:thigh-r :flex 14.0 :side 7.0)
        (:knee-r :flex 23.0) (:thigh-l :flex 14.0) (:knee-l :flex 23.0))
  (7 (:root :u -0.077) (:pelvis :twist 6.1) (:spine :flex 12.1) (:chest :twist -8.5) (:neck :flex -14.8) (:head :flex -22.4)
        (:arm-r :flex -29.9 :twist -0.8 :side 15.0) (:elbow-r :flex 89.0) (:hand-r :flex 2.0 :twist 57.7 :side -11.3) (:thigh-r :flex 17.0 :side 7.2)
        (:knee-r :flex 26.2) (:thigh-l :flex 17.0) (:knee-l :flex 26.2))
  (8 (:root :u -0.088) (:pelvis :twist 7.0) (:spine :flex 13.0) (:chest :twist -9.9) (:neck :flex -15.6) (:head :flex -21.8)
        (:arm-r :flex -32.5 :twist -1.7 :side 13.9) (:elbow-r :flex 89.8) (:hand-r :flex -4.2 :twist 42.5 :side -15.4) (:thigh-r :flex 19.7 :side 7.4)
        (:knee-r :flex 29.1) (:thigh-l :flex 19.7) (:knee-l :flex 29.1))
  (9 (:root :u -0.098) (:pelvis :twist 8.0) (:spine :flex 14.0) (:chest :twist -11.2) (:neck :flex -16.4) (:head :flex -21.2)
        (:arm-r :flex -34.8 :twist -2.6 :side 12.8) (:elbow-r :flex 90.5) (:hand-r :flex -9.9 :twist 28.5 :side -19.2) (:thigh-r :flex 22.3 :side 7.6)
        (:knee-r :flex 31.9) (:thigh-l :flex 22.3) (:knee-l :flex 31.9))
  (10 (:root :u -0.107) (:pelvis :twist 8.8) (:spine :flex 14.8) (:chest :twist -12.3) (:neck :flex -17.0) (:head :flex -20.7)
        (:arm-r :flex -36.9 :twist -3.4 :side 11.9) (:elbow-r :flex 91.1) (:hand-r :flex -15.1 :twist 15.8 :side -22.6)
        (:thigh-r :flex 24.6 :side 7.8) (:knee-r :flex 34.4) (:thigh-l :flex 24.6) (:knee-l :flex 34.4))
  (11 (:root :u -0.115) (:pelvis :twist 9.5) (:spine :flex 15.5) (:chest :twist -13.3) (:neck :flex -17.6) (:head :flex -20.3)
        (:arm-r :flex -38.8 :twist -4.0 :side 11.1) (:elbow-r :flex 91.6) (:hand-r :flex -19.5 :twist 4.9 :side -25.5) (:thigh-r :flex 26.6 :side 7.9)
        (:knee-r :flex 36.5) (:thigh-l :flex 26.6) (:knee-l :flex 36.5))
  (12 (:root :u -0.12) (:pelvis :twist 10.0) (:spine :flex 16.0) (:chest :twist -14.0) (:neck :flex -18.0) (:head :flex -20.0)
        (:arm-r :flex -40.0 :twist -4.5 :side 10.5) (:elbow-r :flex 92.0) (:hand-r :flex -22.5 :twist -2.5 :side -27.5)
        (:thigh-r :flex 28.0 :side 8.0) (:knee-r :flex 38.0) (:thigh-l :flex 28.0) (:knee-l :flex 38.0))
  (13 :ya-n3a-low (:root :u -0.125) (:arm-r :side 11))                                        ; held, levelled low
  (14 :ya-n3a-low (:arm-r :side 10) (:hand-r :flex -23))
  (15 :ya-n3a-low (:root :u -0.125) (:arm-r :side 11))
  (16 :ya-n3a-low (:arm-r :side 10) (:hand-r :flex -23))
  (17 :snap :ya-n3a-low (:root :u -0.129 :f 0.045 :yaw 2.7) (:spine :flex 17.8) (:chest :twist -2.3) (:head :flex -20.9)
        (:arm-r :flex 14.2 :twist -2.7 :side -21.2) (:elbow-r :flex 66.3) (:hand-r :flex -36.2 :twist 10.8 :side -14.9) (:thigh-r :flex 4.6)
        (:knee-r :flex 29.0) (:thigh-l :flex 37.0) (:knee-l :flex 40.7))
  (:s :snap :ya-n3a-hit)
  (20 :ya-n3a-hit (:arm-r :flex 81.5))
  (:a :ya-n3a-land)
  (30 (:root :yaw 4 :f 0.06 :u -0.08) (:chest :twist 4) (:spine :flex 14) (:thigh-l :flex 26) (:knee-l :flex 26) (:thigh-r :flex -10)
        (:knee-r :flex 18)
      (:arm-r :flex 50 :side -20 :twist 0) (:elbow-r :flex 30) (:hand-r :twist 0 :flex -75))
  (:end :ya-stance))
;; NS3b (S12), the closing step: the blade drawn to his right at the waist f1-8, a level cut R->L at the waist on the step (the tip 1.65 m
;; ahead on S, 1.60 m at his left front on S+2), carried on to his left
(defpose :ya-n3b-wind (:base :ya-stance)
  (:root :yaw -6 :u -0.1) (:chest :twist -32) (:spine :flex 14) (:head :flex -20 :twist 16)
  (:arm-r :flex 24 :side 33.5 :twist -1) (:elbow-r :flex 84) (:hand-r :flex -142.5 :twist -41 :side 10.5))
(defpose :ya-n3b-hit (:base :ya-stance)
  (:root :yaw 4 :f 0.12 :u -0.12) (:chest :twist 6) (:spine :flex 16) (:head :flex -20) (:thigh-l :flex 46) (:knee-l :flex 40) (:thigh-r :flex -24)
  (:arm-r :flex 45.5 :side 60 :twist -40) (:elbow-r :flex 35) (:hand-r :flex -51 :twist 8 :side 2.5))
(defpose :ya-n3b-thru (:base :ya-n3b-hit) (:chest :twist 24) (:arm-r :flex 86 :side -16.5 :twist 16) (:elbow-r :flex 17.5) (:hand-r :flex -76.5 :twist 14 :side -16))
(defpose :ya-n3b-land (:base :ya-n3b-hit)                   ; (S+A: NADEGIRI starts here)
  (:chest :twist 30) (:arm-r :flex 45.5 :side -61 :twist -19) (:elbow-r :flex 50) (:hand-r :flex -125 :twist 27 :side -16.5))
(defstrike :ya-n3b (12 3 18 :base :ya-stance)
  (0 :ya-n3a-land)
  (1 (:root :u -0.138 :f 0.096 :yaw 5.5) (:spine :flex 19.7) (:chest :twist 10.1) (:head :flex -21.9 :twist 0.7) (:arm-r :flex 79.5 :side -56.0)
        (:elbow-r :flex 37.1) (:hand-r :flex -54.0 :twist 24.1 :side 0.9) (:thigh-r :flex -23.3) (:thigh-l :flex 46.7) (:knee-l :flex 43.1))
  (2 (:root :u -0.134 :f 0.084 :yaw 4.1) (:spine :flex 19.1) (:chest :twist 5.1) (:head :flex -21.7 :twist 2.5)
        (:arm-r :flex 72.9 :twist -0.6 :side -45.4) (:elbow-r :flex 42.7) (:hand-r :flex -64.5 :twist 16.4 :side 2.1) (:thigh-r :flex -21.5)
        (:thigh-l :flex 43.3) (:knee-l :flex 40.6))
  (3 (:root :u -0.127 :f 0.068 :yaw 2.2) (:spine :flex 18.1) (:chest :twist -1.9) (:head :flex -21.4 :twist 5.1)
        (:arm-r :flex 63.6 :twist -0.7 :side -30.4) (:elbow-r :flex 50.5) (:hand-r :flex -79.3 :twist 5.5 :side 3.7) (:thigh-r :flex -18.9)
        (:thigh-l :flex 38.5) (:knee-l :flex 37.0))
  (4 (:root :u -0.12 :f 0.05 :yaw 0.0) (:spine :flex 17.0) (:chest :twist -10.0) (:head :flex -21.0 :twist 8.0)
        (:arm-r :flex 53.0 :twist -0.8 :side -13.2) (:elbow-r :flex 59.5) (:hand-r :flex -96.3 :twist -7.0 :side 5.5) (:thigh-r :flex -16.0)
        (:thigh-l :flex 33.0) (:knee-l :flex 33.0))
  (5 (:root :u -0.113 :f 0.032 :yaw -2.2) (:spine :flex 15.9) (:chest :twist -18.1) (:head :flex -20.6 :twist 10.9)
        (:arm-r :flex 42.4 :twist -0.8 :side 3.9) (:elbow-r :flex 68.5) (:hand-r :flex -113.2 :twist -19.5 :side 7.3) (:thigh-r :flex -13.1)
        (:thigh-l :flex 27.5) (:knee-l :flex 29.0))
  (6 (:root :u -0.106 :f 0.016 :yaw -4.1) (:spine :flex 14.9) (:chest :twist -25.1) (:head :flex -20.3 :twist 13.5)
        (:arm-r :flex 33.1 :twist -0.9 :side 18.9) (:elbow-r :flex 76.3) (:hand-r :flex -128.0 :twist -30.4 :side 8.9) (:thigh-r :flex -10.5)
        (:thigh-l :flex 22.7) (:knee-l :flex 25.4))
  (7 (:root :u -0.102 :f 0.004 :yaw -5.5) (:spine :flex 14.3) (:chest :twist -30.1) (:head :flex -20.1 :twist 15.3)
        (:arm-r :flex 26.5 :twist -1.0 :side 29.5) (:elbow-r :flex 81.9) (:hand-r :flex -138.5 :twist -38.1 :side 10.1) (:thigh-r :flex -8.7)
        (:thigh-l :flex 19.3) (:knee-l :flex 22.9))
  (8 (:root :u -0.1 :f 0.0 :yaw -6.0) (:spine :flex 14.0) (:chest :twist -32.0) (:head :flex -20.0 :twist 16.0) (:arm-r :flex 24.0 :side 33.5)
        (:elbow-r :flex 84.0) (:hand-r :flex -142.5 :twist -41.0 :side 10.5) (:thigh-r :flex -8.0) (:thigh-l :flex 18.0) (:knee-l :flex 22.0))
  (9 :ya-n3b-wind (:chest :twist -33))                                                          ; held
  (10 :snap :ya-n3b-wind (:root :u -0.105 :f 0.03 :yaw -3.5) (:spine :flex 14.5) (:chest :twist -22.5) (:head :twist 12.0)
        (:arm-r :flex 29.4 :twist -10.8 :side 40.1) (:elbow-r :flex 71.8) (:hand-r :flex -119.6 :twist -28.8 :side 8.5) (:thigh-r :flex -12.0)
        (:thigh-l :flex 25.0) (:knee-l :flex 26.5))
  (11 :snap :ya-n3b-wind (:root :u -0.112 :f 0.074 :yaw 0.2) (:spine :flex 15.2) (:chest :twist -8.4) (:head :twist 6.1)
        (:arm-r :flex 37.3 :twist -25.2 :side 49.9) (:elbow-r :flex 53.6) (:hand-r :flex -85.8 :twist -10.6 :side 5.5) (:thigh-r :flex -17.9)
        (:thigh-l :flex 35.4) (:knee-l :flex 33.2))
  (:s :snap :ya-n3b-hit)
  (13 :snap :ya-n3b-hit (:chest :twist 15.0) (:arm-r :flex 65.7 :twist -12.0 :side 21.7) (:elbow-r :flex 26.2)
        (:hand-r :flex -63.7 :twist 11.0 :side -6.7))
  (14 :snap :ya-n3b-thru)
  (:a :ya-n3b-land)
  (24 (:root :yaw 2 :f 0.06 :u -0.08) (:chest :twist 10) (:spine :flex 14) (:thigh-l :flex 24) (:knee-l :flex 24) (:thigh-r :flex -10)
      (:arm-r :flex 40 :side -20 :twist 0) (:elbow-r :flex 40) (:hand-r :twist 10 :flex -85))
  (:end :ya-stance))
;; NS3c NADEGIRI (S14; canon ch. 338), the pivot, purest: the blade settles at his left hip, the eyes shut (f1-6), still f7-9, a 1 deg
;; tremble f10-12; the snap L->R at the neck f13-14 (two drawings: the hit on S on a 0.3 m drawn lunge, the tip 1.94 m: SL7's seam carries
;; the rest of the 2.4 m), on through S+A; then stillness: the blade lowered over 20 f, the chest (-46 deg) and the head turned away to his
;; right, held; no root yaw (it was a 185 deg turn). AS3c plays the same poses from AS3b's S+A
(defpose :ya-nadegiri-draw (:base :ya-stance)
  (:root :u -0.1) (:pelvis :twist 14) (:chest :twist 28) (:knees :flex 34) (:spine :flex 16) (:neck :flex -20) (:head :flex -28)
  (:arm-r :flex 31.5 :side 8.5 :twist 74) (:elbow-r :flex 70.5) (:hand-r :flex -90 :twist 38.5 :side 0))
(defpose :ya-nadegiri-hit (:base :ya-stance)
  (:root :f 0.3 :u -0.1) (:chest :twist -5) (:knees :flex 30) (:spine :flex 10) (:head :flex -26) (:thigh-l :flex 40) (:knee-l :flex 36) (:thigh-r :flex -18)
  (:arm-r :flex 123 :side -9.5 :twist -24.5) (:elbow-r :flex 3.5) (:hand-r :flex -94 :twist -0.5 :side 0))
(defpose :ya-nadegiri-thru (:base :ya-nadegiri-hit) (:chest :twist -22) (:arm-r :flex 126 :side -36.5 :twist 37) (:elbow-r :flex 0) (:hand-r :flex -96.5 :twist -25.5 :side -8.5))
(defpose :ya-nadegiri-low (:base :ya-stance)
  (:root :f 0.2 :u -0.06) (:pelvis :twist -10) (:chest :twist -46) (:knees :flex 22) (:spine :flex 10) (:neck :flex -10) (:head :flex -16 :twist -30)
  (:thigh-l :flex 30) (:knee-l :flex 30) (:thigh-r :flex -12) (:arm-r :flex 27.5 :side 17.5 :twist -13.5) (:elbow-r :flex 0) (:hand-r :flex -85.5 :twist -13.5 :side 0.5))
(defstrike :ya-nadegiri (14 4 34 :base :ya-stance)
  (0 :ya-n3b-land)
  (1 (:root :u -0.119 :f 0.111 :yaw 3.7) (:pelvis :twist 10.3) (:chest :twist 29.9) (:neck :flex -18.1) (:head :flex -20.6)
        (:arm-r :flex 44.5 :twist -12.1 :side -55.9) (:elbow-r :flex 51.5) (:hand-r :flex -122.4 :twist 27.9 :side -15.3) (:thigh-r :flex -22.8)
        (:knee-r :flex 19.2) (:thigh-l :flex 43.9) (:knee-l :flex 39.6))
  (2 (:root :u -0.115 :f 0.089 :yaw 3.0) (:pelvis :twist 11.0) (:chest :twist 29.5) (:neck :flex -18.5) (:head :flex -22.1)
        (:arm-r :flex 41.9 :twist 5.1 :side -43.0) (:elbow-r :flex 55.3) (:hand-r :flex -115.9 :twist 30.0 :side -12.2) (:thigh-r :flex -19.9)
        (:knee-r :flex 22.1) (:thigh-l :flex 38.7) (:knee-l :flex 38.4))
  (3 (:root :u -0.11 :f 0.06 :yaw 2.0) (:pelvis :twist 12.0) (:chest :twist 29.0) (:neck :flex -19.0) (:head :flex -24.0)
        (:arm-r :flex 38.5 :twist 27.5 :side -26.3) (:elbow-r :flex 60.3) (:hand-r :flex -107.5 :twist 32.7 :side -8.3) (:thigh-r :flex -16.0)
        (:knee-r :flex 26.0) (:thigh-l :flex 32.0) (:knee-l :flex 37.0))
  (4 (:root :u -0.105 :f 0.031 :yaw 1.0) (:pelvis :twist 13.0) (:chest :twist 28.5) (:neck :flex -19.5) (:head :flex -25.9)
        (:arm-r :flex 35.1 :twist 49.9 :side -9.5) (:elbow-r :flex 65.2) (:hand-r :flex -99.1 :twist 35.5 :side -4.3) (:thigh-r :flex -12.1)
        (:knee-r :flex 29.9) (:thigh-l :flex 25.3) (:knee-l :flex 35.6))
  (5 (:root :u -0.101 :f 0.009 :yaw 0.3) (:pelvis :twist 13.7) (:chest :twist 28.1) (:neck :flex -19.9) (:head :flex -27.4)
        (:arm-r :flex 32.5 :twist 67.1 :side 3.4) (:elbow-r :flex 69.0) (:hand-r :flex -92.6 :twist 37.6 :side -1.2) (:thigh-r :flex -9.2)
        (:knee-r :flex 32.8) (:thigh-l :flex 20.1) (:knee-l :flex 34.4))
  (6 (:root :u -0.1 :f 0.0 :yaw 0.0) (:pelvis :twist 14.0) (:chest :twist 28.0) (:neck :flex -20.0) (:head :flex -28.0)
        (:arm-r :flex 31.5 :twist 74.0 :side 8.5) (:elbow-r :flex 70.5) (:hand-r :flex -90.0 :twist 38.5 :side 0.0) (:thigh-r :flex -8.0)
        (:knee-r :flex 34.0) (:thigh-l :flex 18.0) (:knee-l :flex 34.0))
  (9 :ya-nadegiri-draw)                                                                       ; still, the eyes shut
  (10 :ya-nadegiri-draw (:hand-r :flex -91))                                                  ; a 1 deg tremble
  (11 :ya-nadegiri-draw (:hand-r :flex -89))
  (12 :ya-nadegiri-draw)
  (13 :snap :ya-nadegiri-draw (:root :f 0.135) (:pelvis :twist 12.2) (:spine :flex 13.3) (:chest :twist 13.2) (:neck :flex -19.1) (:head :flex -27.1)
        (:arm-r :flex 72.7 :twist 29.7 :side 0.4) (:elbow-r :flex 40.3) (:hand-r :flex -91.8 :twist 21.0) (:thigh-r :flex -12.5) (:knee-r :flex 32.2)
        (:thigh-l :flex 27.9) (:knee-l :flex 34.9))
  (:s :snap :ya-nadegiri-hit)
  (15 :snap :ya-nadegiri-hit (:chest :twist -12.6) (:arm-r :flex 124.3 :twist 3.2 :side -21.6) (:elbow-r :flex 1.9)
        (:hand-r :flex -95.1 :twist -11.7 :side -3.8))
  (16 :snap :ya-nadegiri-thru)
  (:a :ya-nadegiri-thru (:arm-r :flex 124) (:hand-r :flex -95))
  (19 (:root :f 0.299) (:pelvis :twist 9.9) (:chest :twist -22.2) (:neck :flex -17.9) (:head :flex -25.9 :twist -0.2)
        (:arm-r :flex 123.3 :twist 36.6 :side -36.1) (:hand-r :flex -94.9 :twist -25.4 :side -8.4) (:knee-r :flex 29.9) (:thigh-l :flex 39.9))
  (20 (:root :u -0.099 :f 0.297) (:pelvis :twist 9.4) (:chest :twist -22.7) (:neck :flex -17.8) (:head :flex -25.7 :twist -0.8)
        (:arm-r :flex 121.3 :twist 35.6 :side -35.0) (:hand-r :flex -94.7 :twist -25.2 :side -8.2) (:thigh-r :flex -17.8) (:knee-r :flex 29.8)
        (:thigh-l :flex 39.7) (:knee-l :flex 35.8))
  (21 (:root :u -0.098 :f 0.294) (:pelvis :twist 8.8) (:chest :twist -23.5) (:neck :flex -17.5) (:head :flex -25.4 :twist -1.8)
        (:arm-r :flex 118.1 :twist 33.9 :side -33.2) (:hand-r :flex -94.4 :twist -24.8 :side -8.0) (:thigh-r :flex -17.6) (:knee-r :flex 29.5)
        (:thigh-l :flex 39.4) (:knee-l :flex 35.6))
  (22 (:root :u -0.096 :f 0.29) (:pelvis :twist 7.9) (:chest :twist -24.5) (:neck :flex -17.2) (:head :flex -25.0 :twist -3.1)
        (:arm-r :flex 114.0 :twist 31.7 :side -30.9) (:hand-r :flex -94.0 :twist -24.3 :side -7.6) (:thigh-r :flex -17.4) (:knee-r :flex 29.2)
        (:thigh-l :flex 39.0) (:knee-l :flex 35.4))
  (23 (:root :u -0.094 :f 0.284) (:pelvis :twist 6.9) (:chest :twist -25.8) (:neck :flex -16.8) (:head :flex -24.4 :twist -4.7)
        (:arm-r :flex 108.9 :twist 29.1 :side -28.1) (:hand-r :flex -93.5 :twist -23.6 :side -7.1) (:thigh-r :flex -17.1) (:knee-r :flex 28.8)
        (:thigh-l :flex 38.4) (:knee-l :flex 35.1))
  (24 (:root :u -0.091 :f 0.278) (:pelvis :twist 5.7) (:chest :twist -27.2) (:neck :flex -16.3) (:head :flex -23.8 :twist -6.5)
        (:arm-r :flex 103.2 :twist 26.1 :side -24.8) (:hand-r :flex -92.9 :twist -22.9 :side -6.6) (:thigh-r :flex -16.7) (:knee-r :flex 28.3)
        (:thigh-l :flex 37.8) (:knee-l :flex 34.7))
  (25 (:root :u -0.089 :f 0.272) (:pelvis :twist 4.4) (:chest :twist -28.8) (:neck :flex -15.7) (:head :flex -23.2 :twist -8.5)
        (:arm-r :flex 96.8 :twist 22.8 :side -21.3) (:hand-r :flex -92.3 :twist -22.1 :side -6.0) (:thigh-r :flex -16.3) (:knee-r :flex 27.7)
        (:thigh-l :flex 37.2) (:knee-l :flex 34.3))
  (26 (:root :u -0.086 :f 0.265) (:pelvis :twist 3.0) (:chest :twist -30.4) (:neck :flex -15.2) (:head :flex -22.5 :twist -10.6)
        (:arm-r :flex 90.0 :twist 19.2 :side -17.5) (:hand-r :flex -91.7 :twist -21.3 :side -5.3) (:thigh-r :flex -15.9) (:knee-r :flex 27.2)
        (:thigh-l :flex 36.5) (:knee-l :flex 33.9))
  (27 (:root :u -0.083 :f 0.257) (:pelvis :twist 1.5) (:chest :twist -32.2) (:neck :flex -14.6) (:head :flex -21.7 :twist -12.8)
        (:arm-r :flex 83.0 :twist 15.5 :side -13.5) (:hand-r :flex -91.0 :twist -20.4 :side -4.7) (:thigh-r :flex -15.4) (:knee-r :flex 26.6)
        (:thigh-l :flex 35.7) (:knee-l :flex 33.4))
  (28 (:root :u -0.08 :f 0.25) (:pelvis :twist 0.0) (:chest :twist -34.0) (:neck :flex -14.0) (:head :flex -21.0 :twist -15.0)
        (:arm-r :flex 75.7 :twist 11.8 :side -9.5) (:hand-r :flex -90.3 :twist -19.5 :side -4.0) (:thigh-r :flex -15.0) (:knee-r :flex 26.0)
        (:thigh-l :flex 35.0) (:knee-l :flex 33.0))
  (29 (:root :u -0.077 :f 0.243) (:pelvis :twist -1.5) (:chest :twist -35.8) (:neck :flex -13.4) (:head :flex -20.3 :twist -17.2)
        (:arm-r :flex 68.5 :twist 8.0 :side -5.5) (:hand-r :flex -89.5 :twist -18.6 :side -3.3) (:thigh-r :flex -14.6) (:knee-r :flex 25.4)
        (:thigh-l :flex 34.3) (:knee-l :flex 32.6))
  (30 (:root :u -0.074 :f 0.235) (:pelvis :twist -3.0) (:chest :twist -37.6) (:neck :flex -12.8) (:head :flex -19.5 :twist -19.4)
        (:arm-r :flex 61.5 :twist 4.3 :side -1.5) (:hand-r :flex -88.8 :twist -17.7 :side -2.7) (:thigh-r :flex -14.1) (:knee-r :flex 24.8)
        (:thigh-l :flex 33.5) (:knee-l :flex 32.1))
  (31 (:root :u -0.071 :f 0.228) (:pelvis :twist -4.4) (:chest :twist -39.2) (:neck :flex -12.3) (:head :flex -18.8 :twist -21.5)
        (:arm-r :flex 54.7 :twist 0.7 :side 2.3) (:hand-r :flex -88.2 :twist -16.9 :side -2.0) (:thigh-r :flex -13.7) (:knee-r :flex 24.3)
        (:thigh-l :flex 32.8) (:knee-l :flex 31.7))
  (32 (:root :u -0.069 :f 0.222) (:pelvis :twist -5.7) (:chest :twist -40.8) (:neck :flex -11.7) (:head :flex -18.2 :twist -23.5)
        (:arm-r :flex 48.3 :twist -2.6 :side 5.8) (:hand-r :flex -87.6 :twist -16.1 :side -1.4) (:thigh-r :flex -13.3) (:knee-r :flex 23.7)
        (:thigh-l :flex 32.2) (:knee-l :flex 31.3))
  (33 (:root :u -0.066 :f 0.216) (:pelvis :twist -6.9) (:chest :twist -42.2) (:neck :flex -11.2) (:head :flex -17.6 :twist -25.3)
        (:arm-r :flex 42.6 :twist -5.6 :side 9.1) (:hand-r :flex -87.0 :twist -15.4 :side -0.9) (:thigh-r :flex -12.9) (:knee-r :flex 23.3)
        (:thigh-l :flex 31.6) (:knee-l :flex 30.9))
  (34 (:root :u -0.064 :f 0.21) (:pelvis :twist -7.9) (:chest :twist -43.5) (:neck :flex -10.8) (:head :flex -17.0 :twist -26.9)
        (:arm-r :flex 37.5 :twist -8.2 :side 11.9) (:hand-r :flex -86.5 :twist -14.7 :side -0.4) (:thigh-r :flex -12.6) (:knee-r :flex 22.8)
        (:thigh-l :flex 31.0) (:knee-l :flex 30.6))
  (35 (:root :u -0.062 :f 0.206) (:pelvis :twist -8.8) (:chest :twist -44.5) (:neck :flex -10.5) (:head :flex -16.6 :twist -28.2)
        (:arm-r :flex 33.4 :twist -10.4 :side 14.2) (:hand-r :flex -86.1 :twist -14.2 :side 0.0) (:thigh-r :flex -12.4) (:knee-r :flex 22.5)
        (:thigh-l :flex 30.6) (:knee-l :flex 30.4))
  (36 (:root :u -0.061 :f 0.203) (:pelvis :twist -9.4) (:chest :twist -45.3) (:neck :flex -10.2) (:head :flex -16.3 :twist -29.2)
        (:arm-r :flex 30.2 :twist -12.1 :side 16.0) (:hand-r :flex -85.8 :twist -13.8 :side 0.2) (:thigh-r :flex -12.2) (:knee-r :flex 22.2)
        (:thigh-l :flex 30.3) (:knee-l :flex 30.2))
  (37 (:root :u -0.06 :f 0.201) (:pelvis :twist -9.9) (:chest :twist -45.8) (:neck :flex -10.1) (:head :flex -16.1 :twist -29.8)
        (:arm-r :flex 28.2 :twist -13.1 :side 17.1) (:hand-r :flex -85.6 :twist -13.6 :side 0.4) (:thigh-r :flex -12.0) (:knee-r :flex 22.1)
        (:thigh-l :flex 30.1) (:knee-l :flex 30.0))
  (38 (:root :f 0.2) (:pelvis :twist -10.0) (:chest :twist -46.0) (:neck :flex -10.0) (:head :flex -16.0 :twist -30.0)
        (:arm-r :flex 27.5 :twist -13.5 :side 17.5) (:hand-r :flex -85.5 :twist -13.5 :side 0.5) (:knee-r :flex 22.0) (:thigh-l :flex 30.0))
  (44 :ya-nadegiri-low (:root :u -0.065))                                                      ; held, his back to the cut
  (:end :ya-stance))
;; 爆炎 NS3c, the true NADEGIRI (S14 A4 R60; art S4, DUEL_YAMA_CORE §21.4 / §25): its own clip (it played the Shikai's NADEGIRI, whose 52 f
;; left the 78 f move holding the stance pose for its last 26 f). The Shikai's cut, the same keys to S+A (frame 0 NS3b's S+A), then RoS's
;; "huge opening" drawn: the blade lowered over 40 f (f19-58, the Shikai's curve at half speed) with the chest (-46 deg) and the head turned
;; away to his right, no root yaw, and held still to the move's end (f78; TO-IDLE's blend takes him back to the stance)
(defstrike :ya-b-n3c (14 4 60 :base :ya-stance)
  (0 :ya-n3b-land)
  (1 (:root :u -0.119 :f 0.111 :yaw 3.7) (:pelvis :twist 10.3) (:chest :twist 29.9) (:neck :flex -18.1) (:head :flex -20.6)
        (:arm-r :flex 44.5 :twist -12.1 :side -55.9) (:elbow-r :flex 51.5) (:hand-r :flex -122.4 :twist 27.9 :side -15.3) (:thigh-r :flex -22.8)
        (:knee-r :flex 19.2) (:thigh-l :flex 43.9) (:knee-l :flex 39.6))
  (2 (:root :u -0.115 :f 0.089 :yaw 3.0) (:pelvis :twist 11.0) (:chest :twist 29.5) (:neck :flex -18.5) (:head :flex -22.1)
        (:arm-r :flex 41.9 :twist 5.1 :side -43.0) (:elbow-r :flex 55.3) (:hand-r :flex -115.9 :twist 30.0 :side -12.2) (:thigh-r :flex -19.9)
        (:knee-r :flex 22.1) (:thigh-l :flex 38.7) (:knee-l :flex 38.4))
  (3 (:root :u -0.11 :f 0.06 :yaw 2.0) (:pelvis :twist 12.0) (:chest :twist 29.0) (:neck :flex -19.0) (:head :flex -24.0)
        (:arm-r :flex 38.5 :twist 27.5 :side -26.3) (:elbow-r :flex 60.3) (:hand-r :flex -107.5 :twist 32.7 :side -8.3) (:thigh-r :flex -16.0)
        (:knee-r :flex 26.0) (:thigh-l :flex 32.0) (:knee-l :flex 37.0))
  (4 (:root :u -0.105 :f 0.031 :yaw 1.0) (:pelvis :twist 13.0) (:chest :twist 28.5) (:neck :flex -19.5) (:head :flex -25.9)
        (:arm-r :flex 35.1 :twist 49.9 :side -9.5) (:elbow-r :flex 65.2) (:hand-r :flex -99.1 :twist 35.5 :side -4.3) (:thigh-r :flex -12.1)
        (:knee-r :flex 29.9) (:thigh-l :flex 25.3) (:knee-l :flex 35.6))
  (5 (:root :u -0.101 :f 0.009 :yaw 0.3) (:pelvis :twist 13.7) (:chest :twist 28.1) (:neck :flex -19.9) (:head :flex -27.4)
        (:arm-r :flex 32.5 :twist 67.1 :side 3.4) (:elbow-r :flex 69.0) (:hand-r :flex -92.6 :twist 37.6 :side -1.2) (:thigh-r :flex -9.2)
        (:knee-r :flex 32.8) (:thigh-l :flex 20.1) (:knee-l :flex 34.4))
  (6 (:root :u -0.1 :f 0.0 :yaw 0.0) (:pelvis :twist 14.0) (:chest :twist 28.0) (:neck :flex -20.0) (:head :flex -28.0)
        (:arm-r :flex 31.5 :twist 74.0 :side 8.5) (:elbow-r :flex 70.5) (:hand-r :flex -90.0 :twist 38.5 :side 0.0) (:thigh-r :flex -8.0)
        (:knee-r :flex 34.0) (:thigh-l :flex 18.0) (:knee-l :flex 34.0))
  (9 :ya-nadegiri-draw)                                                                       ; still, the eyes shut
  (10 :ya-nadegiri-draw (:hand-r :flex -91))                                                  ; a 1 deg tremble
  (11 :ya-nadegiri-draw (:hand-r :flex -89))
  (12 :ya-nadegiri-draw)
  (13 :snap :ya-nadegiri-draw (:root :f 0.135) (:pelvis :twist 12.2) (:spine :flex 13.3) (:chest :twist 13.2) (:neck :flex -19.1) (:head :flex -27.1)
        (:arm-r :flex 72.7 :twist 29.7 :side 0.4) (:elbow-r :flex 40.3) (:hand-r :flex -91.8 :twist 21.0) (:thigh-r :flex -12.5) (:knee-r :flex 32.2)
        (:thigh-l :flex 27.9) (:knee-l :flex 34.9))
  (:s :snap :ya-nadegiri-hit)
  (15 :snap :ya-nadegiri-hit (:chest :twist -12.6) (:arm-r :flex 124.3 :twist 3.2 :side -21.6) (:elbow-r :flex 1.9)
        (:hand-r :flex -95.1 :twist -11.7 :side -3.8))
  (16 :snap :ya-nadegiri-thru)
  (:a :ya-nadegiri-thru (:arm-r :flex 124) (:hand-r :flex -95))
  (19 (:head :twist -0.1) (:arm-r :flex 123.8 :twist 36.9 :side -36.4))
  (20 (:root :f 0.299) (:pelvis :twist 9.9) (:chest :twist -22.2) (:head :flex -25.9 :twist -0.2) (:arm-r :flex 123.3 :twist 36.6 :side -36.1) (:hand-r :twist -25.4) (:thigh-l :flex 39.9))
  (21 (:root :f 0.298) (:pelvis :twist 9.7) (:chest :twist -22.4) (:neck :flex -17.9) (:head :flex -25.8 :twist -0.5) (:arm-r :flex 122.5 :twist 36.2 :side -35.6) (:hand-r :flex -94.8 :twist -25.3 :side -8.4) (:thigh-r :flex -17.9) (:knee-r :flex 29.9) (:thigh-l :flex 39.8) (:knee-l :flex 35.9))
  (22 (:root :f 0.297) (:pelvis :twist 9.4) (:chest :twist -22.7) (:neck :flex -17.8) (:head :flex -25.7 :twist -0.8) (:arm-r :flex 121.3 :twist 35.6 :side -35.0) (:hand-r :flex -94.7 :twist -25.2 :side -8.2) (:thigh-r :flex -17.8) (:knee-r :flex 29.8) (:thigh-l :flex 39.7) (:knee-l :flex 35.8))
  (23 (:root :u -0.098 :f 0.296) (:pelvis :twist 9.1) (:chest :twist -23.0) (:neck :flex -17.7) (:head :flex -25.6 :twist -1.3) (:arm-r :flex 119.9 :twist 34.8 :side -34.2) (:hand-r :flex -94.6 :twist -25.0 :side -8.1) (:thigh-r :flex -17.7) (:knee-r :flex 29.7) (:thigh-l :flex 39.6) (:knee-l :flex 35.7))
  (24 (:root :u -0.098 :f 0.294) (:pelvis :twist 8.8) (:chest :twist -23.5) (:neck :flex -17.5) (:head :flex -25.4 :twist -1.8) (:arm-r :flex 118.1 :twist 33.9 :side -33.2) (:hand-r :flex -94.4 :twist -24.8 :side -8.0) (:thigh-r :flex -17.6) (:knee-r :flex 29.5) (:thigh-l :flex 39.4) (:knee-l :flex 35.6))
  (25 (:root :u -0.097 :f 0.292) (:pelvis :twist 8.4) (:chest :twist -23.9) (:neck :flex -17.4) (:head :flex -25.2 :twist -2.4) (:arm-r :flex 116.2 :twist 32.9 :side -32.1) (:hand-r :flex -94.2 :twist -24.5 :side -7.8) (:thigh-r :flex -17.5) (:knee-r :flex 29.4) (:thigh-l :flex 39.2) (:knee-l :flex 35.5))
  (26 (:root :u -0.096 :f 0.29) (:pelvis :twist 7.9) (:chest :twist -24.5) (:neck :flex -17.2) (:head :flex -25.0 :twist -3.1) (:arm-r :flex 114.0 :twist 31.7 :side -30.9) (:hand-r :flex -94.0 :twist -24.3 :side -7.6) (:thigh-r :flex -17.4) (:knee-r :flex 29.2) (:thigh-l :flex 39.0) (:knee-l :flex 35.4))
  (27 (:root :u -0.095 :f 0.287) (:pelvis :twist 7.4) (:chest :twist -25.1) (:neck :flex -17.0) (:head :flex -24.7 :twist -3.9) (:arm-r :flex 111.5 :twist 30.5 :side -29.5) (:hand-r :flex -93.8 :twist -24.0 :side -7.3) (:thigh-r :flex -17.2) (:knee-r :flex 29.0) (:thigh-l :flex 38.7) (:knee-l :flex 35.2))
  (28 (:root :u -0.094 :f 0.284) (:pelvis :twist 6.9) (:chest :twist -25.8) (:neck :flex -16.8) (:head :flex -24.4 :twist -4.7) (:arm-r :flex 108.9 :twist 29.1 :side -28.1) (:hand-r :flex -93.5 :twist -23.6 :side -7.1) (:thigh-r :flex -17.1) (:knee-r :flex 28.8) (:thigh-l :flex 38.4) (:knee-l :flex 35.1))
  (29 (:root :u -0.093 :f 0.281) (:pelvis :twist 6.3) (:chest :twist -26.4) (:neck :flex -16.5) (:head :flex -24.1 :twist -5.6) (:arm-r :flex 106.1 :twist 27.6 :side -26.5) (:hand-r :flex -93.2 :twist -23.3 :side -6.8) (:thigh-r :flex -16.9) (:knee-r :flex 28.5) (:thigh-l :flex 38.1) (:knee-l :flex 34.9))
  (30 (:root :u -0.091 :f 0.278) (:pelvis :twist 5.7) (:chest :twist -27.2) (:neck :flex -16.3) (:head :flex -23.8 :twist -6.5) (:arm-r :flex 103.2 :twist 26.1 :side -24.8) (:hand-r :flex -92.9 :twist -22.9 :side -6.6) (:thigh-r :flex -16.7) (:knee-r :flex 28.3) (:thigh-l :flex 37.8) (:knee-l :flex 34.7))
  (31 (:root :u -0.09 :f 0.275) (:pelvis :twist 5.0) (:chest :twist -28.0) (:neck :flex -16.0) (:head :flex -23.5 :twist -7.4) (:arm-r :flex 100.0 :twist 24.5 :side -23.1) (:hand-r :flex -92.6 :twist -22.5 :side -6.3) (:thigh-r :flex -16.5) (:knee-r :flex 28.0) (:thigh-l :flex 37.5) (:knee-l :flex 34.5))
  (32 (:root :u -0.089 :f 0.272) (:pelvis :twist 4.4) (:chest :twist -28.8) (:neck :flex -15.7) (:head :flex -23.2 :twist -8.5) (:arm-r :flex 96.8 :twist 22.8 :side -21.3) (:hand-r :flex -92.3 :twist -22.1 :side -6.0) (:thigh-r :flex -16.3) (:knee-r :flex 27.7) (:thigh-l :flex 37.2) (:knee-l :flex 34.3))
  (33 (:root :u -0.087 :f 0.268) (:pelvis :twist 3.7) (:chest :twist -29.6) (:neck :flex -15.5) (:head :flex -22.8 :twist -9.5) (:arm-r :flex 93.5 :twist 21.0 :side -19.4) (:hand-r :flex -92.0 :twist -21.7 :side -5.7) (:thigh-r :flex -16.1) (:knee-r :flex 27.5) (:thigh-l :flex 36.8) (:knee-l :flex 34.1))
  (34 (:root :u -0.086 :f 0.265) (:pelvis :twist 3.0) (:chest :twist -30.4) (:neck :flex -15.2) (:head :flex -22.5 :twist -10.6) (:arm-r :flex 90.0 :twist 19.2 :side -17.5) (:hand-r :flex -91.7 :twist -21.3 :side -5.3) (:thigh-r :flex -15.9) (:knee-r :flex 27.2) (:thigh-l :flex 36.5) (:knee-l :flex 33.9))
  (35 (:root :u -0.084 :f 0.261) (:pelvis :twist 2.2) (:chest :twist -31.3) (:neck :flex -14.9) (:head :flex -22.1 :twist -11.7) (:arm-r :flex 86.5 :twist 17.4 :side -15.5) (:hand-r :flex -91.3 :twist -20.8 :side -5.0) (:thigh-r :flex -15.7) (:knee-r :flex 26.9) (:thigh-l :flex 36.1) (:knee-l :flex 33.7))
  (36 (:root :u -0.083 :f 0.257) (:pelvis :twist 1.5) (:chest :twist -32.2) (:neck :flex -14.6) (:head :flex -21.7 :twist -12.8) (:arm-r :flex 83.0 :twist 15.5 :side -13.5) (:hand-r :flex -91.0 :twist -20.4 :side -4.7) (:thigh-r :flex -15.4) (:knee-r :flex 26.6) (:thigh-l :flex 35.7) (:knee-l :flex 33.4))
  (37 (:root :u -0.081 :f 0.254) (:pelvis :twist 0.7) (:chest :twist -33.1) (:neck :flex -14.3) (:head :flex -21.4 :twist -13.9) (:arm-r :flex 79.4 :twist 13.6 :side -11.5) (:hand-r :flex -90.6 :twist -19.9 :side -4.3) (:thigh-r :flex -15.2) (:knee-r :flex 26.3) (:thigh-l :flex 35.4) (:knee-l :flex 33.2))
  (38 (:root :u -0.08 :f 0.25) (:pelvis :twist 0.0) (:chest :twist -34.0) (:neck :flex -14.0) (:head :flex -21.0 :twist -15.0) (:arm-r :flex 75.7 :twist 11.8 :side -9.5) (:hand-r :flex -90.3 :twist -19.5 :side -4.0) (:thigh-r :flex -15.0) (:knee-r :flex 26.0) (:thigh-l :flex 35.0) (:knee-l :flex 33.0))
  (39 (:root :u -0.079 :f 0.246) (:pelvis :twist -0.7) (:chest :twist -34.9) (:neck :flex -13.7) (:head :flex -20.6 :twist -16.1) (:arm-r :flex 72.1 :twist 9.9 :side -7.5) (:hand-r :flex -89.9 :twist -19.1 :side -3.7) (:thigh-r :flex -14.8) (:knee-r :flex 25.7) (:thigh-l :flex 34.6) (:knee-l :flex 32.8))
  (40 (:root :u -0.077 :f 0.243) (:pelvis :twist -1.5) (:chest :twist -35.8) (:neck :flex -13.4) (:head :flex -20.3 :twist -17.2) (:arm-r :flex 68.5 :twist 8.0 :side -5.5) (:hand-r :flex -89.5 :twist -18.6 :side -3.3) (:thigh-r :flex -14.6) (:knee-r :flex 25.4) (:thigh-l :flex 34.3) (:knee-l :flex 32.6))
  (41 (:root :u -0.076 :f 0.239) (:pelvis :twist -2.2) (:chest :twist -36.7) (:neck :flex -13.1) (:head :flex -19.9 :twist -18.3) (:arm-r :flex 65.0 :twist 6.1 :side -3.5) (:hand-r :flex -89.2 :twist -18.2 :side -3.0) (:thigh-r :flex -14.3) (:knee-r :flex 25.1) (:thigh-l :flex 33.9) (:knee-l :flex 32.3))
  (42 (:root :u -0.074 :f 0.235) (:pelvis :twist -3.0) (:chest :twist -37.6) (:neck :flex -12.8) (:head :flex -19.5 :twist -19.4) (:arm-r :flex 61.5 :twist 4.3 :side -1.5) (:hand-r :flex -88.8 :twist -17.7 :side -2.7) (:thigh-r :flex -14.1) (:knee-r :flex 24.8) (:thigh-l :flex 33.5) (:knee-l :flex 32.1))
  (43 (:root :u -0.073 :f 0.232) (:pelvis :twist -3.7) (:chest :twist -38.4) (:neck :flex -12.5) (:head :flex -19.2 :twist -20.5) (:arm-r :flex 58.0 :twist 2.5 :side 0.4) (:hand-r :flex -88.5 :twist -17.3 :side -2.3) (:thigh-r :flex -13.9) (:knee-r :flex 24.5) (:thigh-l :flex 33.2) (:knee-l :flex 31.9))
  (44 (:root :u -0.071 :f 0.228) (:pelvis :twist -4.4) (:chest :twist -39.2) (:neck :flex -12.3) (:head :flex -18.8 :twist -21.5) (:arm-r :flex 54.7 :twist 0.7 :side 2.3) (:hand-r :flex -88.2 :twist -16.9 :side -2.0) (:thigh-r :flex -13.7) (:knee-r :flex 24.3) (:thigh-l :flex 32.8) (:knee-l :flex 31.7))
  (45 (:root :u -0.07 :f 0.225) (:pelvis :twist -5.0) (:chest :twist -40.0) (:neck :flex -12.0) (:head :flex -18.5 :twist -22.6) (:arm-r :flex 51.5 :twist -1.0 :side 4.1) (:hand-r :flex -87.9 :twist -16.5 :side -1.7) (:thigh-r :flex -13.5) (:knee-r :flex 24.0) (:thigh-l :flex 32.5) (:knee-l :flex 31.5))
  (46 (:root :u -0.069 :f 0.222) (:pelvis :twist -5.7) (:chest :twist -40.8) (:neck :flex -11.7) (:head :flex -18.2 :twist -23.5) (:arm-r :flex 48.3 :twist -2.6 :side 5.8) (:hand-r :flex -87.6 :twist -16.1 :side -1.4) (:thigh-r :flex -13.3) (:knee-r :flex 23.7) (:thigh-l :flex 32.2) (:knee-l :flex 31.3))
  (47 (:root :u -0.067 :f 0.219) (:pelvis :twist -6.3) (:chest :twist -41.6) (:neck :flex -11.5) (:head :flex -17.9 :twist -24.4) (:arm-r :flex 45.4 :twist -4.1 :side 7.5) (:hand-r :flex -87.3 :twist -15.7 :side -1.2) (:thigh-r :flex -13.1) (:knee-r :flex 23.5) (:thigh-l :flex 31.9) (:knee-l :flex 31.1))
  (48 (:root :u -0.066 :f 0.216) (:pelvis :twist -6.9) (:chest :twist -42.2) (:neck :flex -11.2) (:head :flex -17.6 :twist -25.3) (:arm-r :flex 42.6 :twist -5.6 :side 9.1) (:hand-r :flex -87.0 :twist -15.4 :side -0.9) (:thigh-r :flex -12.9) (:knee-r :flex 23.3) (:thigh-l :flex 31.6) (:knee-l :flex 30.9))
  (49 (:root :u -0.065 :f 0.213) (:pelvis :twist -7.4) (:chest :twist -42.9) (:neck :flex -11.0) (:head :flex -17.3 :twist -26.1) (:arm-r :flex 40.0 :twist -7.0 :side 10.5) (:hand-r :flex -86.7 :twist -15.0 :side -0.7) (:thigh-r :flex -12.8) (:knee-r :flex 23.0) (:thigh-l :flex 31.3) (:knee-l :flex 30.8))
  (50 (:root :u -0.064 :f 0.21) (:pelvis :twist -7.9) (:chest :twist -43.5) (:neck :flex -10.8) (:head :flex -17.0 :twist -26.9) (:arm-r :flex 37.5 :twist -8.2 :side 11.9) (:hand-r :flex -86.5 :twist -14.7 :side -0.4) (:thigh-r :flex -12.6) (:knee-r :flex 22.8) (:thigh-l :flex 31.0) (:knee-l :flex 30.6))
  (51 (:root :u -0.063 :f 0.208) (:pelvis :twist -8.4) (:chest :twist -44.1) (:neck :flex -10.6) (:head :flex -16.8 :twist -27.6) (:arm-r :flex 35.3 :twist -9.4 :side 13.1) (:hand-r :flex -86.3 :twist -14.5 :side -0.2) (:thigh-r :flex -12.5) (:knee-r :flex 22.6) (:thigh-l :flex 30.8) (:knee-l :flex 30.5))
  (52 (:root :u -0.062 :f 0.206) (:pelvis :twist -8.8) (:chest :twist -44.5) (:neck :flex -10.5) (:head :flex -16.6 :twist -28.2) (:arm-r :flex 33.4 :twist -10.4 :side 14.2) (:hand-r :flex -86.1 :twist -14.2 :side 0.0) (:thigh-r :flex -12.4) (:knee-r :flex 22.5) (:thigh-l :flex 30.6) (:knee-l :flex 30.4))
  (53 (:root :u -0.062 :f 0.204) (:pelvis :twist -9.1) (:chest :twist -45.0) (:neck :flex -10.3) (:head :flex -16.4 :twist -28.7) (:arm-r :flex 31.6 :twist -11.3 :side 15.2) (:hand-r :flex -85.9 :twist -14.0 :side 0.1) (:thigh-r :flex -12.3) (:knee-r :flex 22.3) (:thigh-l :flex 30.4) (:knee-l :flex 30.3))
  (54 (:root :u -0.061 :f 0.203) (:pelvis :twist -9.4) (:chest :twist -45.3) (:neck :flex -10.2) (:head :flex -16.3 :twist -29.2) (:arm-r :flex 30.2 :twist -12.1 :side 16.0) (:hand-r :flex -85.8 :twist -13.8 :side 0.2) (:thigh-r :flex -12.2) (:knee-r :flex 22.2) (:thigh-l :flex 30.3) (:knee-l :flex 30.2))
  (55 (:root :f 0.202) (:pelvis :twist -9.7) (:chest :twist -45.6) (:neck :flex -10.1) (:head :flex -16.2 :twist -29.5) (:arm-r :flex 29.0 :twist -12.7 :side 16.6) (:hand-r :flex -85.7 :twist -13.7 :side 0.4) (:thigh-r :flex -12.1) (:knee-r :flex 22.1) (:thigh-l :flex 30.2) (:knee-l :flex 30.1))
  (56 (:root :f 0.201) (:pelvis :twist -9.9) (:chest :twist -45.8) (:neck :flex -10.1) (:head :flex -16.1 :twist -29.8) (:arm-r :flex 28.2 :twist -13.1 :side 17.1) (:hand-r :flex -85.6 :twist -13.6 :side 0.4) (:thigh-r :flex -12.0) (:knee-r :flex 22.1) (:thigh-l :flex 30.1) (:knee-l :flex 30.0))
  (57 (:root :f 0.2) (:pelvis :twist -10.0) (:chest :twist -46.0) (:head :flex -16.0 :twist -29.9) (:arm-r :flex 27.7 :twist -13.4 :side 17.4) (:hand-r :twist -13.5) (:thigh-l :flex 30.0))
  (58 (:head :twist -30.0) (:arm-r :flex 27.5 :twist -13.5 :side 17.5))
  (66 :ya-nadegiri-low (:root :u -0.065))                                                      ; held, his back to the cut
  (72 :ya-nadegiri-low (:root :u -0.066) (:head :flex -15.5 :twist -30.5))
  (:end :ya-nadegiri-low (:root :u -0.065)))
;; AS3a (S8), the back cut: from J3's S+1 (the pommel forward, the blade laid back under the forearm) the reverse-gripped blade cocked out
;; off the little finger to his left front (the tip 1.77 m out on S), then the hilt pulled back across him R->L: the edge cuts on the pull
(defpose :ya-tsuka-thru (:base :ya-tsuka-hit) (:root :f 0.323) (:arm-r :flex 131.6))   ; J3's S+1 (f10) as :YA-TSUKA draws it
(defpose :ya-as3a-hit (:base :ya-tsuka-hit)
  (:root :f 0.3) (:chest :twist 14) (:arm-r :flex 117 :side -29.5 :twist -18.5) (:elbow-r :flex 24) (:hand-r :twist 175 :flex 33.5 :side -22))
(defpose :ya-as3a-pull (:base :ya-as3a-hit) (:root :f 0.28) (:chest :twist 26) (:arm-r :flex 83 :side 10 :twist -0.5) (:elbow-r :flex 73.5) (:hand-r :twist 175.5 :flex 35 :side -18))
(defpose :ya-as3a-land (:base :ya-as3a-pull) (:root :f 0.27) (:arm-r :flex 80) (:elbow-r :flex 76))   ; (S+A: AS3b starts here)
(defstrike :ya-as3a (8 3 14 :base :ya-stance)
  (0 :ya-tsuka-thru)
  (1 (:root :f 0.322) (:chest :twist 19.8) (:arm-r :flex 131.0 :twist -0.7) (:elbow-r :flex 6.2) (:hand-r :flex -78.8 :twist 166.8 :side -19.6))
  (2 (:root :f 0.321) (:chest :twist 19.4) (:arm-r :flex 130.1 :twist -1.8) (:elbow-r :flex 7.3) (:hand-r :flex -71.8 :twist 167.4 :side -19.8))
  (3 (:root :f 0.319) (:chest :twist 18.9) (:arm-r :flex 128.8 :twist -3.5) (:elbow-r :flex 9.0) (:hand-r :flex -61.3 :twist 168.1 :side -20.0))
  (4 (:root :f 0.316) (:chest :twist 18.1) (:arm-r :flex 127.1 :twist -5.7 :side -29.8) (:elbow-r :flex 11.2)
        (:hand-r :flex -47.2 :twist 169.1 :side -20.3))
  (5 (:root :f 0.313) (:chest :twist 17.3) (:arm-r :flex 125.0 :twist -8.3 :side -29.8) (:elbow-r :flex 13.8)
        (:hand-r :flex -30.9 :twist 170.3 :side -20.6))
  (6 :snap :ya-tsuka-thru (:root :f 0.308) (:chest :twist 16.2) (:arm-r :flex 122.3 :twist -11.8 :side -29.7) (:elbow-r :flex 17.3)
        (:hand-r :flex -8.6 :twist 171.9 :side -21.1))
  (7 :snap :ya-tsuka-thru (:root :f 0.304) (:chest :twist 15.0) (:arm-r :flex 119.3 :twist -15.5 :side -29.6) (:elbow-r :flex 21.0)
        (:hand-r :flex 14.8 :twist 173.6 :side -21.6))
  (:s :snap :ya-as3a-hit)
  (9 :snap :ya-as3a-hit (:root :f 0.29) (:chest :twist 20.0) (:arm-r :flex 100.0 :twist -9.5 :side -9.7) (:elbow-r :flex 48.8)
        (:hand-r :flex 34.2 :twist 175.3 :side -20.0))
  (10 :snap :ya-as3a-pull)
  (:a :ya-as3a-land)
  (19 (:root :f 0.12 :u -0.04) (:chest :twist 10) (:arm-r :flex 50 :side 0 :twist 0) (:elbow-r :flex 40) (:hand-r :twist 60 :flex -100 :side 0))
  (:end :ya-stance))
;; AS3b (S10), the turning cut: the blade flipped forward and dropped low at his right front f1-6, held f7, a rising cut to his high left as
;; the chest turns (the tip 1.91 m out on S), on up to his high left
(defpose :ya-as3b-low (:base :ya-stance)
  (:root :yaw -6 :f 0.15 :u -0.14) (:chest :twist -26) (:spine :flex 20) (:knees :flex 40) (:head :flex -22)
  (:arm-r :flex 60.5 :side 2 :twist -22.5) (:elbow-r :flex 11.5) (:hand-r :flex -64 :twist 0 :side 0))
(defpose :ya-as3b-hit (:base :ya-stance)
  (:root :yaw 4 :f 0.3 :u -0.06) (:chest :twist 20) (:spine :flex 8) (:head :flex -28) (:thigh-l :flex 36) (:knee-l :flex 30) (:thigh-r :flex -16)
  (:arm-r :flex 127 :side -12 :twist 24) (:elbow-r :flex 0) (:hand-r :flex -88.5 :twist 7 :side 0))
(defpose :ya-as3b-land (:base :ya-stance)                   ; (S+A: AS3c starts here)
  (:root :yaw 4 :f 0.2 :u -0.02) (:chest :twist 32) (:spine :flex 2) (:head :flex -30) (:thigh-l :flex 30) (:knee-l :flex 26)
  (:arm-r :flex 135 :side 25.5 :twist 14) (:elbow-r :flex 19) (:hand-r :flex -105.5 :twist -18.5 :side -29.5))
(defstrike :ya-as3b (10 3 16 :base :ya-stance)
  (0 :ya-as3a-land)
  (1 (:root :u -0.066 :f 0.261 :yaw 3.3) (:pelvis :side -3.7) (:spine :flex 10.7) (:chest :twist 22.1) (:head :flex -18.3 :twist -5.6)
        (:arm-r :flex 78.6 :twist -2.1 :side 9.4) (:elbow-r :flex 71.2) (:hand-r :flex 27.7 :twist 162.5 :side -16.7) (:arm-l :flex -22.9 :side 28.5)
        (:elbow-l :flex 9.3) (:thigh-r :flex -21.0) (:knee-r :flex 17.8) (:thigh-l :flex 36.5) (:knee-l :flex 36.3))
  (2 (:root :u -0.081 :f 0.239 :yaw 1.4) (:pelvis :side -3.0) (:spine :flex 12.6) (:chest :twist 12.5) (:head :flex -19.0 :twist -4.4)
        (:arm-r :flex 74.9 :twist -6.2 :side 7.9) (:elbow-r :flex 59.3) (:hand-r :flex 9.3 :twist 130.0 :side -13.3) (:arm-l :flex -17.5 :side 24.8)
        (:elbow-l :flex 7.4) (:thigh-r :flex -18.4) (:knee-r :flex 22.2) (:thigh-l :flex 32.8) (:knee-l :flex 37.0))
  (3 (:root :u -0.1 :f 0.21 :yaw -1.0) (:pelvis :side -2.0) (:spine :flex 15.0) (:chest :twist 0.0) (:head :flex -20.0 :twist -3.0)
        (:arm-r :flex 70.3 :twist -11.5 :side 6.0) (:elbow-r :flex 43.7) (:hand-r :flex -14.5 :twist 87.8 :side -9.0) (:arm-l :flex -10.5 :side 20.0)
        (:elbow-l :flex 5.0) (:thigh-r :flex -15.0) (:knee-r :flex 28.0) (:thigh-l :flex 28.0) (:knee-l :flex 38.0))
  (4 (:root :u -0.119 :f 0.181 :yaw -3.4) (:pelvis :side -1.0) (:spine :flex 17.4) (:chest :twist -12.5) (:head :flex -21.0 :twist -1.6)
        (:arm-r :flex 65.6 :twist -16.8 :side 4.1) (:elbow-r :flex 28.2) (:hand-r :flex -38.3 :twist 45.5 :side -4.7) (:arm-l :flex -3.5 :side 15.2)
        (:elbow-l :flex 2.6) (:thigh-r :flex -11.6) (:knee-r :flex 33.8) (:thigh-l :flex 23.2) (:knee-l :flex 39.0))
  (5 (:root :u -0.134 :f 0.159 :yaw -5.3) (:pelvis :side -0.3) (:spine :flex 19.3) (:chest :twist -22.1) (:head :flex -21.7 :twist -0.4)
        (:arm-r :flex 61.9 :twist -20.9 :side 2.6) (:elbow-r :flex 16.3) (:hand-r :flex -56.7 :twist 13.0 :side -1.3) (:arm-l :flex 1.9 :side 11.5)
        (:elbow-l :flex 0.7) (:thigh-r :flex -9.0) (:knee-r :flex 38.2) (:thigh-l :flex 19.5) (:knee-l :flex 39.7))
  (6 (:root :u -0.14 :f 0.15 :yaw -6.0) (:pelvis :side 0.0) (:spine :flex 20.0) (:chest :twist -26.0) (:head :flex -22.0 :twist 0.0)
        (:arm-r :flex 60.5 :twist -22.5 :side 2.0) (:elbow-r :flex 11.5) (:hand-r :flex -64.0 :twist 0.0 :side 0.0) (:arm-l :flex 4.0 :side 10.0)
        (:elbow-l :flex 0.0) (:thigh-r :flex -8.0) (:knee-r :flex 40.0) (:thigh-l :flex 18.0) (:knee-l :flex 40.0))
  (7 :ya-as3b-low (:root :u -0.145))                                                          ; held
  (8 :snap :ya-as3b-low (:root :u -0.12 :f 0.188 :yaw -3.5) (:spine :flex 17.0) (:chest :twist -14.5) (:head :flex -23.5)
        (:arm-r :flex 77.1 :twist -10.9 :side -1.5) (:elbow-r :flex 8.6) (:hand-r :flex -70.1 :twist 1.7) (:thigh-r :flex -10.0) (:knee-r :flex 34.5)
        (:thigh-l :flex 22.5) (:knee-l :flex 37.5))
  (9 :snap :ya-as3b-low (:root :u -0.09 :f 0.243 :yaw 0.2) (:spine :flex 12.6) (:chest :twist 2.5) (:head :flex -25.7)
        (:arm-r :flex 101.7 :twist 6.3 :side -6.7) (:elbow-r :flex 4.4) (:hand-r :flex -79.2 :twist 4.3) (:thigh-r :flex -13.0) (:knee-r :flex 26.4)
        (:thigh-l :flex 29.2) (:knee-l :flex 33.8))
  (:s :snap :ya-as3b-hit)
  (11 :snap :ya-as3b-hit (:root :u -0.044 :f 0.26) (:spine :flex 5.6) (:chest :twist 24.8) (:head :flex -28.8)
        (:arm-r :flex 130.2 :twist 20.0 :side 3.0) (:elbow-r :flex 7.6) (:hand-r :flex -95.3 :twist -3.2 :side -11.8) (:thigh-r :flex -12.8)
        (:thigh-l :flex 33.6) (:knee-l :flex 28.4))
  (12 :snap :ya-as3b-hit (:root :u -0.028 :f 0.22) (:spine :flex 3.2) (:chest :twist 29.6) (:head :flex -29.6)
        (:arm-r :flex 133.4 :twist 16.0 :side 18.0) (:elbow-r :flex 15.2) (:hand-r :flex -102.1 :twist -13.4 :side -23.6) (:thigh-r :flex -9.6)
        (:thigh-l :flex 31.2) (:knee-l :flex 26.8))
  (:a :ya-as3b-land)
  (22 (:root :yaw 2 :f 0.1 :u -0.04) (:chest :twist 12) (:spine :flex 10) (:thigh-l :flex 18) (:knee-l :flex 18)
      (:arm-r :flex 70 :side 0 :twist 0) (:elbow-r :flex 30) (:hand-r :twist 0 :flex -80 :side 0))
  (:end :ya-stance))
(defstrike :ya-as3c (14 4 34 :base :ya-stance)
  (0 :ya-as3b-land)
  (1 (:root :u -0.026 :f 0.185 :yaw 3.7) (:pelvis :twist 10.3) (:spine :flex 3.0) (:chest :twist 31.7) (:neck :flex -18.1) (:head :flex -29.9)
        (:arm-r :flex 127.3 :twist 18.4 :side 24.2) (:elbow-r :flex 22.8) (:hand-r :flex -104.4 :twist -14.3 :side -27.3) (:knee-r :flex 19.2)
        (:thigh-l :flex 29.1) (:knee-l :flex 26.6))
  (2 (:root :u -0.041 :f 0.148 :yaw 3.0) (:pelvis :twist 11.0) (:spine :flex 5.6) (:chest :twist 31.0) (:neck :flex -18.5) (:head :flex -29.5)
        (:arm-r :flex 108.2 :twist 29.6 :side 21.1) (:elbow-r :flex 32.4) (:hand-r :flex -101.5 :twist -3.7 :side -21.9) (:knee-r :flex 22.1)
        (:thigh-l :flex 26.9) (:knee-l :flex 28.1))
  (3 (:root :u -0.06 :f 0.1 :yaw 2.0) (:pelvis :twist 12.0) (:spine :flex 9.0) (:chest :twist 30.0) (:neck :flex -19.0) (:head :flex -29.0)
        (:arm-r :flex 83.3 :twist 44.0 :side 17.0) (:elbow-r :flex 44.8) (:hand-r :flex -97.7 :twist 10.0 :side -14.8) (:knee-r :flex 26.0)
        (:thigh-l :flex 24.0) (:knee-l :flex 30.0))
  (4 (:root :u -0.079 :f 0.052 :yaw 1.0) (:pelvis :twist 13.0) (:spine :flex 12.4) (:chest :twist 29.0) (:neck :flex -19.5) (:head :flex -28.5)
        (:arm-r :flex 58.3 :twist 58.4 :side 12.9) (:elbow-r :flex 57.1) (:hand-r :flex -94.0 :twist 23.7 :side -7.6) (:knee-r :flex 29.9)
        (:thigh-l :flex 21.1) (:knee-l :flex 31.9))
  (5 (:root :u -0.094 :f 0.015 :yaw 0.3) (:pelvis :twist 13.7) (:spine :flex 15.0) (:chest :twist 28.3) (:neck :flex -19.9) (:head :flex -28.1)
        (:arm-r :flex 39.2 :twist 69.6 :side 9.8) (:elbow-r :flex 66.7) (:hand-r :flex -91.1 :twist 34.3 :side -2.2) (:knee-r :flex 32.8)
        (:thigh-l :flex 18.9) (:knee-l :flex 33.4))
  (6 (:root :u -0.1 :f 0.0 :yaw 0.0) (:pelvis :twist 14.0) (:spine :flex 16.0) (:chest :twist 28.0) (:neck :flex -20.0) (:head :flex -28.0)
        (:arm-r :flex 31.5 :twist 74.0 :side 8.5) (:elbow-r :flex 70.5) (:hand-r :flex -90.0 :twist 38.5 :side 0.0) (:knee-r :flex 34.0)
        (:thigh-l :flex 18.0) (:knee-l :flex 34.0))
  (9 :ya-nadegiri-draw)                                                                       ; still, the eyes shut
  (10 :ya-nadegiri-draw (:hand-r :flex -91))                                                  ; a 1 deg tremble
  (11 :ya-nadegiri-draw (:hand-r :flex -89))
  (12 :ya-nadegiri-draw)
  (13 :snap :ya-nadegiri-draw (:root :f 0.135) (:pelvis :twist 12.2) (:spine :flex 13.3) (:chest :twist 13.2) (:neck :flex -19.1) (:head :flex -27.1)
        (:arm-r :flex 72.7 :twist 29.7 :side 0.4) (:elbow-r :flex 40.3) (:hand-r :flex -91.8 :twist 21.0) (:thigh-r :flex -12.5) (:knee-r :flex 32.2)
        (:thigh-l :flex 27.9) (:knee-l :flex 34.9))
  (:s :snap :ya-nadegiri-hit)
  (15 :snap :ya-nadegiri-hit (:chest :twist -12.6) (:arm-r :flex 124.3 :twist 3.2 :side -21.6) (:elbow-r :flex 1.9)
        (:hand-r :flex -95.1 :twist -11.7 :side -3.8))
  (16 :snap :ya-nadegiri-thru)
  (:a :ya-nadegiri-thru (:arm-r :flex 124) (:hand-r :flex -95))
  (19 (:root :f 0.299) (:pelvis :twist 9.9) (:chest :twist -22.2) (:neck :flex -17.9) (:head :flex -25.9 :twist -0.2)
        (:arm-r :flex 123.3 :twist 36.6 :side -36.1) (:hand-r :flex -94.9 :twist -25.4 :side -8.4) (:knee-r :flex 29.9) (:thigh-l :flex 39.9))
  (20 (:root :u -0.099 :f 0.297) (:pelvis :twist 9.4) (:chest :twist -22.7) (:neck :flex -17.8) (:head :flex -25.7 :twist -0.8)
        (:arm-r :flex 121.3 :twist 35.6 :side -35.0) (:hand-r :flex -94.7 :twist -25.2 :side -8.2) (:thigh-r :flex -17.8) (:knee-r :flex 29.8)
        (:thigh-l :flex 39.7) (:knee-l :flex 35.8))
  (21 (:root :u -0.098 :f 0.294) (:pelvis :twist 8.8) (:chest :twist -23.5) (:neck :flex -17.5) (:head :flex -25.4 :twist -1.8)
        (:arm-r :flex 118.1 :twist 33.9 :side -33.2) (:hand-r :flex -94.4 :twist -24.8 :side -8.0) (:thigh-r :flex -17.6) (:knee-r :flex 29.5)
        (:thigh-l :flex 39.4) (:knee-l :flex 35.6))
  (22 (:root :u -0.096 :f 0.29) (:pelvis :twist 7.9) (:chest :twist -24.5) (:neck :flex -17.2) (:head :flex -25.0 :twist -3.1)
        (:arm-r :flex 114.0 :twist 31.7 :side -30.9) (:hand-r :flex -94.0 :twist -24.3 :side -7.6) (:thigh-r :flex -17.4) (:knee-r :flex 29.2)
        (:thigh-l :flex 39.0) (:knee-l :flex 35.4))
  (23 (:root :u -0.094 :f 0.284) (:pelvis :twist 6.9) (:chest :twist -25.8) (:neck :flex -16.8) (:head :flex -24.4 :twist -4.7)
        (:arm-r :flex 108.9 :twist 29.1 :side -28.1) (:hand-r :flex -93.5 :twist -23.6 :side -7.1) (:thigh-r :flex -17.1) (:knee-r :flex 28.8)
        (:thigh-l :flex 38.4) (:knee-l :flex 35.1))
  (24 (:root :u -0.091 :f 0.278) (:pelvis :twist 5.7) (:chest :twist -27.2) (:neck :flex -16.3) (:head :flex -23.8 :twist -6.5)
        (:arm-r :flex 103.2 :twist 26.1 :side -24.8) (:hand-r :flex -92.9 :twist -22.9 :side -6.6) (:thigh-r :flex -16.7) (:knee-r :flex 28.3)
        (:thigh-l :flex 37.8) (:knee-l :flex 34.7))
  (25 (:root :u -0.089 :f 0.272) (:pelvis :twist 4.4) (:chest :twist -28.8) (:neck :flex -15.7) (:head :flex -23.2 :twist -8.5)
        (:arm-r :flex 96.8 :twist 22.8 :side -21.3) (:hand-r :flex -92.3 :twist -22.1 :side -6.0) (:thigh-r :flex -16.3) (:knee-r :flex 27.7)
        (:thigh-l :flex 37.2) (:knee-l :flex 34.3))
  (26 (:root :u -0.086 :f 0.265) (:pelvis :twist 3.0) (:chest :twist -30.4) (:neck :flex -15.2) (:head :flex -22.5 :twist -10.6)
        (:arm-r :flex 90.0 :twist 19.2 :side -17.5) (:hand-r :flex -91.7 :twist -21.3 :side -5.3) (:thigh-r :flex -15.9) (:knee-r :flex 27.2)
        (:thigh-l :flex 36.5) (:knee-l :flex 33.9))
  (27 (:root :u -0.083 :f 0.257) (:pelvis :twist 1.5) (:chest :twist -32.2) (:neck :flex -14.6) (:head :flex -21.7 :twist -12.8)
        (:arm-r :flex 83.0 :twist 15.5 :side -13.5) (:hand-r :flex -91.0 :twist -20.4 :side -4.7) (:thigh-r :flex -15.4) (:knee-r :flex 26.6)
        (:thigh-l :flex 35.7) (:knee-l :flex 33.4))
  (28 (:root :u -0.08 :f 0.25) (:pelvis :twist 0.0) (:chest :twist -34.0) (:neck :flex -14.0) (:head :flex -21.0 :twist -15.0)
        (:arm-r :flex 75.7 :twist 11.8 :side -9.5) (:hand-r :flex -90.3 :twist -19.5 :side -4.0) (:thigh-r :flex -15.0) (:knee-r :flex 26.0)
        (:thigh-l :flex 35.0) (:knee-l :flex 33.0))
  (29 (:root :u -0.077 :f 0.243) (:pelvis :twist -1.5) (:chest :twist -35.8) (:neck :flex -13.4) (:head :flex -20.3 :twist -17.2)
        (:arm-r :flex 68.5 :twist 8.0 :side -5.5) (:hand-r :flex -89.5 :twist -18.6 :side -3.3) (:thigh-r :flex -14.6) (:knee-r :flex 25.4)
        (:thigh-l :flex 34.3) (:knee-l :flex 32.6))
  (30 (:root :u -0.074 :f 0.235) (:pelvis :twist -3.0) (:chest :twist -37.6) (:neck :flex -12.8) (:head :flex -19.5 :twist -19.4)
        (:arm-r :flex 61.5 :twist 4.3 :side -1.5) (:hand-r :flex -88.8 :twist -17.7 :side -2.7) (:thigh-r :flex -14.1) (:knee-r :flex 24.8)
        (:thigh-l :flex 33.5) (:knee-l :flex 32.1))
  (31 (:root :u -0.071 :f 0.228) (:pelvis :twist -4.4) (:chest :twist -39.2) (:neck :flex -12.3) (:head :flex -18.8 :twist -21.5)
        (:arm-r :flex 54.7 :twist 0.7 :side 2.3) (:hand-r :flex -88.2 :twist -16.9 :side -2.0) (:thigh-r :flex -13.7) (:knee-r :flex 24.3)
        (:thigh-l :flex 32.8) (:knee-l :flex 31.7))
  (32 (:root :u -0.069 :f 0.222) (:pelvis :twist -5.7) (:chest :twist -40.8) (:neck :flex -11.7) (:head :flex -18.2 :twist -23.5)
        (:arm-r :flex 48.3 :twist -2.6 :side 5.8) (:hand-r :flex -87.6 :twist -16.1 :side -1.4) (:thigh-r :flex -13.3) (:knee-r :flex 23.7)
        (:thigh-l :flex 32.2) (:knee-l :flex 31.3))
  (33 (:root :u -0.066 :f 0.216) (:pelvis :twist -6.9) (:chest :twist -42.2) (:neck :flex -11.2) (:head :flex -17.6 :twist -25.3)
        (:arm-r :flex 42.6 :twist -5.6 :side 9.1) (:hand-r :flex -87.0 :twist -15.4 :side -0.9) (:thigh-r :flex -12.9) (:knee-r :flex 23.3)
        (:thigh-l :flex 31.6) (:knee-l :flex 30.9))
  (34 (:root :u -0.064 :f 0.21) (:pelvis :twist -7.9) (:chest :twist -43.5) (:neck :flex -10.8) (:head :flex -17.0 :twist -26.9)
        (:arm-r :flex 37.5 :twist -8.2 :side 11.9) (:hand-r :flex -86.5 :twist -14.7 :side -0.4) (:thigh-r :flex -12.6) (:knee-r :flex 22.8)
        (:thigh-l :flex 31.0) (:knee-l :flex 30.6))
  (35 (:root :u -0.062 :f 0.206) (:pelvis :twist -8.8) (:chest :twist -44.5) (:neck :flex -10.5) (:head :flex -16.6 :twist -28.2)
        (:arm-r :flex 33.4 :twist -10.4 :side 14.2) (:hand-r :flex -86.1 :twist -14.2 :side 0.0) (:thigh-r :flex -12.4) (:knee-r :flex 22.5)
        (:thigh-l :flex 30.6) (:knee-l :flex 30.4))
  (36 (:root :u -0.061 :f 0.203) (:pelvis :twist -9.4) (:chest :twist -45.3) (:neck :flex -10.2) (:head :flex -16.3 :twist -29.2)
        (:arm-r :flex 30.2 :twist -12.1 :side 16.0) (:hand-r :flex -85.8 :twist -13.8 :side 0.2) (:thigh-r :flex -12.2) (:knee-r :flex 22.2)
        (:thigh-l :flex 30.3) (:knee-l :flex 30.2))
  (37 (:root :u -0.06 :f 0.201) (:pelvis :twist -9.9) (:chest :twist -45.8) (:neck :flex -10.1) (:head :flex -16.1 :twist -29.8)
        (:arm-r :flex 28.2 :twist -13.1 :side 17.1) (:hand-r :flex -85.6 :twist -13.6 :side 0.4) (:thigh-r :flex -12.0) (:knee-r :flex 22.1)
        (:thigh-l :flex 30.1) (:knee-l :flex 30.0))
  (38 (:root :f 0.2) (:pelvis :twist -10.0) (:chest :twist -46.0) (:neck :flex -10.0) (:head :flex -16.0 :twist -30.0)
        (:arm-r :flex 27.5 :twist -13.5 :side 17.5) (:hand-r :flex -85.5 :twist -13.5 :side 0.5) (:knee-r :flex 22.0) (:thigh-l :flex 30.0))
  (44 :ya-nadegiri-low (:root :u -0.065))                                                      ; held, his back to the cut
  (:end :ya-stance))
;; SA TAIMATSU (S16 A8; canon Taimatsu226.gif), art S3: the eye-open tell (the head up, f3); the blade carried once round him low, his
;; right, behind (the hand behind his back), his left (a key every 60 deg, linear: the order SL8's halo ignites in), the chest turning with
;; it, rising into the fan across the front on S, held; no root yaw (it was a 360 deg turn)
(defpose :ya-taimatsu-hit (:base :ya-stance)
  (:root :u 0.02) (:chest :twist 10) (:spine :flex 4) (:head :flex -28) (:arm-r :flex 73 :side -10) (:elbow-r :flex 5) (:hand-r :twist 0 :flex -29))
(defstrike :ya-taimatsu (16 8 24 :base :ya-stance)
  (0)
  (3 (:root :u -0.02) (:spine :flex 6) (:neck :flex -22) (:head :flex -30))            ; the tell: he straightens, eyes open
  (5 :snap :ya-stance (:root :u -0.1) (:knees :flex 32) (:spine :flex 12) (:chest :twist -8) (:neck :flex -20) (:head :flex -28)   ; his right front
     (:arm-r :flex 37 :side 10.5 :twist -25.5) (:elbow-r :flex 4.5) (:hand-r :flex -42.5 :twist 0 :side 2))
  (7 :snap :ya-stance (:root :u -0.11) (:knees :flex 34) (:spine :flex 14) (:chest :twist -20) (:neck :flex -20) (:head :flex -28)  ; his right
     (:arm-r :flex 16 :side 17 :twist -42) (:elbow-r :flex 5) (:hand-r :flex -54 :twist -19 :side 0.5))
  (9 :snap :ya-stance (:root :u -0.12) (:knees :flex 35) (:spine :flex 16) (:chest :twist -35) (:neck :flex -20) (:head :flex -28)  ; behind, right
     (:arm-r :flex -2 :side 16.5 :twist -18.5) (:elbow-r :flex 0) (:hand-r :flex -99.5 :twist -15.5 :side 1))
  (11 :snap :ya-stance (:root :u -0.12) (:knees :flex 35) (:spine :flex 16) (:chest :twist -40) (:neck :flex -20) (:head :flex -28) ; behind (the hand
      (:arm-r :flex -27.5 :side -2 :twist 60.5) (:elbow-r :flex 11.5) (:hand-r :flex -87 :twist 18.5 :side -3))                        ;  behind his back)
  (13 :snap :ya-stance (:root :u -0.11) (:knees :flex 34) (:spine :flex 14) (:chest :twist -20) (:neck :flex -20) (:head :flex -28) ; his left
      (:arm-r :flex -25.5 :side -44 :twist 26.5) (:elbow-r :flex 16.5) (:hand-r :flex -65 :twist 27.5 :side 16))
  (15 :snap :ya-stance (:root :u -0.06) (:knees :flex 26) (:spine :flex 10) (:chest :twist 15) (:neck :flex -20) (:head :flex -28) ; his left front,
      (:arm-r :flex 9 :side -52 :twist 16) (:elbow-r :flex 50.5) (:hand-r :flex -54 :twist 4.5 :side 3))                               ;  rising
  (:s :snap :ya-taimatsu-hit)
  (19 (:root :u 0.03) (:chest :twist 25) (:spine :flex 0) (:head :flex -30)
      (:arm-r :flex 95 :side -7 :twist 13) (:elbow-r :flex 20) (:hand-r :twist 19 :flex -56))
  (:a (:chest :twist 27) (:arm-r :flex 97))
  (36 (:root :u -0.02) (:chest :twist 5) (:spine :flex 8) (:head :flex -20)
      (:arm-r :flex 50 :side -5 :twist 5) (:elbow-r :flex 25) (:hand-r :twist 5 :flex -65))
  (:end :ya-stance))
;; The Kikon strikes (NS / AS, art S3): J1 HISEN's poses with a 0.25 m drawn lunge from the held tell into S (J1's tip 1.39 m on the
;; strikes' 1.6 m: the tip 1.64 m)
(defstrike :ya-strike (14 3 12 :base :ya-stance)
  (0)
  (1 (:arm-r :flex 25 :side -4) (:elbow-r :flex 33) (:hand-r :twist -5 :flex -80))
  (2 (:root :u -0.041) (:chest :twist -9) (:arm-r :flex 28 :side 2 :twist -1) (:elbow-r :flex 35) (:hand-r :twist -9 :flex -77))
  (3 (:root :u -0.042) (:head :flex -15) (:arm-r :flex 32 :side 10 :twist -2) (:elbow-r :flex 38) (:hand-r :twist -14 :flex -73))
  (4 (:root :u -0.043) (:chest :twist -10) (:head :flex -16) (:arm-r :flex 40 :side 19 :twist -3) (:elbow-r :flex 42)
     (:hand-r :twist -21 :flex -68))
  (5 (:root :u -0.045) (:chest :twist -12) (:spine :flex 11) (:head :flex -17) (:arm-r :flex 52 :side 30 :twist -5) (:elbow-r :flex 50)
     (:hand-r :twist -28 :flex -62))
  (6 (:root :u -0.048) (:chest :twist -13) (:head :flex -18) (:arm-r :flex 69 :side 41 :twist -8) (:elbow-r :flex 60)
     (:hand-r :twist -36 :flex -56))
  (7 (:root :u -0.051) (:chest :twist -15) (:head :flex -20) (:arm-r :flex 93 :side 52 :twist -11) (:elbow-r :flex 76)
     (:hand-r :twist -44 :flex -50))
  (8 (:root :u -0.055) (:chest :twist -18) (:spine :flex 10) (:head :flex -22) (:arm-r :flex 129 :side 62 :twist -15) (:elbow-r :flex 98)
     (:hand-r :twist -51 :flex -45))
  (9 (:root :u -0.06 :f 0.02) (:chest :twist -21) (:head :flex -24) (:arm-r :flex 175 :side 72 :twist -20) (:elbow-r :flex 127)   ; cocked
     (:hand-r :twist -58 :flex -40))
  (10 (:root :f 0.04) (:chest :twist -22) (:arm-r :side 73))                                                ; held, leaning in
  (11 (:root :f 0.06 :u -0.065) (:chest :twist -21) (:arm-r :flex 174 :side 71))
  (12 (:root :f 0.08) (:chest :twist -22) (:arm-r :flex 176 :side 73))
  (13 :snap (:root :f 0.17) (:chest :twist -17) (:spine :flex 11) (:neck :flex -18) (:head :flex -24)       ; released into the lunge
      (:arm-r :flex 169 :side 84 :twist -40) (:elbow-r :flex 133) (:hand-r :twist -59 :flex -54))
  (:s :snap :ya-q1-hit (:root :f 0.25))
  (15 :ya-hisen-thru (:root :f 0.25))
  (:a :ya-hisen-a (:root :f 0.24))
  (23 (:chest :twist 0) (:spine :flex 14) (:root :u -0.05 :f 0.1) (:arm-r :flex 50 :side 10 :twist 15) (:elbow-r :flex 25)
      (:hand-r :twist 2 :flex -80) (:head :flex -18))
  (:end :ya-stance))
(defclip :ya-breaker (0.4 :loop t :base :ya-stance)    ; Breaker aura dash: hunched charge, blade trailing
  (0 (:spine :flex 30) (:head :flex -30) (:arm-r :flex -35 :side 30) (:elbow-r :flex 20) (:hand-r :twist 150 :flex 10)
     (:thigh-r :flex 45) (:knee-r :flex 20) (:thigh-l :flex -30) (:knee-l :flex 45) (:root :u -0.1))
  (0.2 (:spine :flex 30) (:head :flex -30) (:thigh-l :flex 45) (:knee-l :flex 20) (:thigh-r :flex -30) (:knee-r :flex 45)
       (:root :u -0.06)))
;; 爆炎 J3 IKKOTSU (canon ch. 394; art S4, DUEL_YAMA_CORE §21.4 / §25): at the move's S9 (it struck at S8, F10). Frame 0 is J2's S+A
;; (:YA-Q2-A, where the string's link lands); the blade is planted point-down at his right on f2 (:YA-IKKOTSU-PLANT, *YA-PLANTS*' spot:
;; the grip 0.76 m up, 0.5 m right, 0.14 m ahead, by FK) and the hand lets go; the fist drawn back to the ribs (f3-6), held and wound (f7-8);
;; one step in on the left foot and the fist straight out at shoulder height on S (:YA-IKKOTSU-HIT: the wrist 1.35 m ahead at 1.33 m up, on
;; the 1.40 m volume; it was 1.21); held through S+A, drawn back, the hand on the hilt again on f24, the blade drawn out into the stance
(defpose :ya-ikkotsu-plant (:base :ya-stance)                ; the hand on the planted hilt (FK: the grip 0.75 m up, 0.50 right, 0.14 ahead)
  (:root :u -0.1 :yaw -6) (:spine :flex 12) (:chest :twist -12) (:head :flex -10)
  (:arm-r :flex 20 :side 27 :twist -16) (:elbow-r :flex 27) (:hand-r :flex -126 :twist 15 :side -16))
(defpose :ya-ikkotsu-chamber (:base :ya-stance)              ; the fist drawn back to the ribs, the body turned away
  (:root :yaw -20 :u -0.12) (:chest :twist -30) (:spine :flex 12) (:head :flex -22) (:thigh-l :flex 30) (:knee-l :flex 45)
  (:arm-r :flex -39.5 :side 19.5 :twist 0) (:elbow-r :flex 136) (:hand-r :flex 0 :twist 0 :side 0))
(defpose :ya-ikkotsu-hit (:base :ya-stance)                  ; stepped in, the fist out at shoulder height
  (:root :yaw 10 :f 0.52 :u -0.16) (:pelvis :side -4 :twist 14) (:chest :twist 30.5) (:spine :flex 11.5) (:neck :flex -20) (:head :flex -24)
  (:thigh-l :flex 58) (:knee-l :flex 52) (:thigh-r :flex -32) (:knee-r :flex 4)
  (:arm-r :flex 157 :side -41 :twist 0) (:elbow-r :flex 4.5) (:hand-r :flex 0 :twist 0 :side 0))
(defstrike :ya-ikkotsu (9 3 18 :base :ya-stance)
  (0 :ya-q2-a)
  (2 :snap :ya-ikkotsu-plant)                                                                 ; planted
  (3 :ya-ikkotsu-plant (:arm-r :flex 4 :side 24 :twist -8) (:elbow-r :flex 70) (:hand-r :flex -40 :twist 6 :side -6))   ; let go
  (6 :ya-ikkotsu-chamber)                                                                     ; drawn back
  (7 :ya-ikkotsu-chamber (:root :yaw -21 :u -0.125) (:chest :twist -32))                     ; held, wound
  (8 :ya-ikkotsu-chamber (:root :yaw -22 :u -0.13) (:chest :twist -33))
  (:s :snap :ya-ikkotsu-hit)
  (10 :ya-ikkotsu-hit (:root :f 0.53) (:chest :twist 32))
  (:a :ya-ikkotsu-hit (:chest :twist 31))
  (18 (:root :yaw 2 :f 0.24 :u -0.12) (:pelvis :side -2 :twist 6) (:chest :twist 4) (:spine :flex 12) (:head :flex -16)
      (:thigh-l :flex 34) (:knee-l :flex 34) (:thigh-r :flex -14) (:knee-r :flex 14)
      (:arm-r :flex 60 :side 10 :twist -8) (:elbow-r :flex 60) (:hand-r :flex -60 :twist 8 :side -8))
  (24 :ya-ikkotsu-plant)                                                                      ; back on the hilt
  (:end :ya-stance))
(defclip :ya-kikon (1.8 :base :ya-stance)              ; Jokaku Enjo: raise the blade, sweep, the fire dome detonates
  (0)
  (0.3 (:arm-r :flex 100 :side 0) (:elbow-r :flex 70) (:hand-r :twist 90 :flex -10) (:spine :flex 0) (:head :flex -10))
  (0.9 (:arm-r :flex 105) (:root :u 0.02))
  (1.2 (:chest :twist -40) (:arm-r :side 70 :flex 90) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -80))
  (1.3 :snap (:chest :twist 40) (:arm-r :side -10 :flex 40) (:hand-r :twist -15 :flex -75) (:spine :flex 22) (:root :u -0.15))
  (1.8 :ya-stance))

;;; ---------------------------------------------------------------- intro / win / Hellfire
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
;; 爆炎's entry pose (Ennetsu Jigoku's opening, canon ch. 393; art S4, DUEL_YAMA_CORE §21.4 / §25): its own 24 f clip on the move's frames
;; (it played the old 60 f :YA-HELLFIRE, a 360 deg root turn, at x2.5). No turn: the point lowered to the plaza at his right (f0-6), held
;; there while the fire runs down the edge into the floor and a ring runs out (f7-16: YAMA-SK-MOVES code 6), then he straightens, chest
;; out, chin up, the arm flung wide (f17-23). The move's :blend 4 takes it from any stance
(defpose :ya-hellfire-point (:base :ya-stance)
  (:root :u -0.1) (:knees :flex 30) (:chest :twist -10) (:spine :flex 14)
  (:arm-r :flex 1 :side 25 :twist 23) (:elbow-r :flex 1) (:hand-r :twist 0 :flex -34))
(defpose :ya-blaze-up (:base :ya-stance)                     ; straightened: the chest out, the chin up, the arm and blade flung wide
  (:root :u 0.0) (:knees :flex 10) (:spine :flex -12) (:neck :flex -10) (:head :flex -30) (:chest :twist 0)
  (:arm-r :flex 20 :side 80 :twist 0) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -90) (:arm-l :side 45))
(defstrike :ya-blaze-in (23 1 0 :base :ya-stance)
  (0)
  (3 :ya-hellfire-point (:root :u -0.07) (:knees :flex 20) (:arm-r :flex 12 :side 18 :twist 10) (:elbow-r :flex 16) (:hand-r :flex -60))
  (6 :ya-hellfire-point)                                                                      ; the point in the plaza
  (11 :ya-hellfire-point (:root :u -0.11) (:head :flex -16))                                 ; the fire runs down into the floor
  (16 :ya-hellfire-point (:root :u -0.105) (:head :flex -12) (:hand-r :flex -36))           ; the ring runs out
  (18 :snap :ya-hellfire-point (:root :u -0.05) (:knees :flex 18) (:spine :flex 4) (:arm-r :flex 10 :side 50) (:hand-r :flex -60))
  (20 :snap :ya-blaze-up)                                                                     ; straightened
  (:s :ya-blaze-up (:spine :flex -10) (:arm-l :side 47))
  (:end :ya-blaze-up (:spine :flex -10) (:arm-l :side 47)))

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
;; The three pointer stances (kit :core :stances; DUEL_YAMA_CORE §15.2.2, art K2 §17), each read apart from the behind camera by where the
;; blade is: 東 level across his chest, its tip out past his left side; 西 low at his right, point down, the arms open (and L8's low
;; garb: yama-look.lisp YAMA-STANCE-LOOK); 南 vertical, point down, 0.25 m right of his face, the elbow winged high (faint ember cracks
;; at his feet). :YA-E-STANCE stays the form's idle (the walk, the blends, every strike's base).
(defpose :ya-st-higashi (:base :ya-e-stance)          ; 東 the naming pose: upright, the fist toward the foe at chest height
  (:root :u -0.01) (:spine :flex -6) (:chest :twist 4 :flex -6) (:neck :flex -2) (:head :flex 0)
  (:arm-r :flex 72 :side -6) (:elbow-r :flex 26) (:hand-r :twist 90 :flex -12)                 ; the blade level across
  (:arm-l :flex 2 :side 8))
(defclip :ya-st-higashi (2.4 :loop t :base :ya-st-higashi)
  (0) (1.2 (:chest :flex -8) (:root :u -0.02) (:hand-r :flex -10)))
(defpose :ya-st-nishi (:base :ya-e-stance)            ; 西 the furnace: feet apart and sunk, chest out, chin up, arms open low
  (:root :u -0.1) (:spine :flex -12) (:chest :flex -6) (:neck :flex -10) (:head :flex -14) (:thighs :side 14) (:knees :flex 20)
  (:arm-r :flex 10 :side 53) (:elbow-r :flex 15) (:hand-r :twist 30 :flex -100)              ; the blade low right, point down
  (:arm-l :flex 10 :side 45))
(defclip :ya-st-nishi (2.4 :loop t :base :ya-st-nishi)   ; (4 keys: the feet sink, the chest swells, the arms open as the garb
  (0)                                                    ;  breathes: YAMA-STANCE-LOOK reads this clip's phase)
  (0.6 (:root :u -0.13) (:knees :flex 24) (:arm-r :side 56) (:arm-l :side 49))
  (1.2 (:root :u -0.12) (:spine :flex -15) (:head :flex -17) (:knees :flex 23) (:arm-r :side 58) (:arm-l :side 52))
  (1.8 (:root :u -0.11) (:spine :flex -13) (:head :flex -15) (:knees :flex 21) (:arm-r :side 55) (:arm-l :side 48)))
(defpose :ya-st-minami (:base :ya-e-stance)           ; 南 the plant, held: the hilt at the chin, the elbow winged high
  (:root :u 0.0) (:spine :flex -4) (:chest :twist 0) (:head :flex 6)
  (:arm-r :flex 0 :side 130) (:elbow-r :flex 140) (:hand-r :twist 50 :flex -60))             ; the blade vertical, point down
(defclip :ya-st-minami (2.4 :loop t :base :ya-st-minami)
  (0) (1.2 (:root :u 0.01) (:head :flex 8) (:arm-r :side 128)))

;; E1 J1 HIZASHI: a deep fencer's lunge (the right foot far forward, the rear leg straight), a level cut at face height
;; right to left; at S the blade crosses his centre line 1.5 m ahead (tip ahead 1.52). Art K2 (DUEL_YAMA_CORE §17): keyed at the move's
;; S14 (the opener's held tell, no :clip-s stretch): the charge f0-9 (drawn back right, level; small keys first: ease-out cubic moves
;; fastest on a segment's first frame), held f10-12 (a 1-2 deg tremble), released f13-14; on through (f15 = where an AS starts: AS1's f0)
;; and down to his low left by S+A (f17 = where J2 starts: J2's f0, :YA-E-Q2-FROM)
(defpose :ya-e-q1-hit (:base :ya-e-stance)
  (:root :yaw 14 :f 0.1 :u -0.24) (:pelvis :twist 0 :side -6) (:spine :flex 14) (:chest :twist -6 :flex 0)
  (:neck :flex 0) (:head :flex 6 :twist -10) (:arm-l :flex -30 :side 30)
  (:thigh-r :flex 70 :side 4) (:knee-r :flex 76) (:thigh-l :flex -40 :side 6) (:knee-l :flex 6)
  (:arm-r :flex 130 :side -30) (:elbow-r :flex 60) (:hand-r :twist 150 :flex 10))
(defpose :ya-e-q1-thru (:base :ya-e-q1-hit)                ; on through to his left, chest high (S+1: an AS starts here)
  (:root :yaw 22 :f 0.12) (:chest :twist 10) (:head :twist -18) (:arm-l :flex -34 :side 34)
  (:arm-r :flex 120 :side -50) (:elbow-r :flex 40) (:hand-r :twist 145 :flex -10))
;; J2's first frame (S+A of J1: the string's link lands there): still in the lunge, the blade carried down low at his left
(defpose :ya-e-q2-from (:base :ya-e-stance)
  (:root :yaw 20 :f 0.08 :u -0.2) (:pelvis :side -5) (:spine :flex 12) (:chest :twist 30)
  (:arm-r :flex 40 :side -30) (:elbow-r :flex 30) (:hand-r :twist 10 :flex -110)
  (:thigh-r :flex 60 :side 4) (:knee-r :flex 64) (:thigh-l :flex -34 :side 6) (:knee-l :flex 8)
  (:arm-l :flex -20 :side 20))
(defstrike :ya-e-q1 (14 3 12 :base :ya-e-stance)
  (0)
  (1 (:arm-r :flex 18 :side 15) (:elbow-r :flex 19) (:hand-r :twist 4) (:thigh-r :flex -3) (:knee-r :flex 9))   ; the charge:
  (2 (:root :yaw -1) (:chest :twist -5) (:head :twist 1) (:arm-r :flex 21 :side 16) (:elbow-r :flex 21)            ;  a key a
     (:hand-r :twist 10 :flex -81) (:thigh-r :flex -2) (:knee-r :flex 10))                                           ;  frame,
  (3 (:root :u -0.03) (:spine :flex -3) (:chest :twist -6) (:head :twist 2) (:arm-r :flex 26 :side 19) (:elbow-r :flex 23)   ;  2 5
     (:hand-r :twist 20 :flex -82) (:thigh-r :flex -1) (:knee-r :flex 12) (:thigh-l :flex 9) (:knee-l :flex 13))   ;  10 17 27
  (4 (:root :yaw -2 :f -0.01) (:pelvis :side 1) (:chest :twist -8) (:head :twist 3) (:arm-r :flex 34 :side 22)     ;  40 56 76 %
     (:elbow-r :flex 27) (:hand-r :twist 42 :flex -84) (:thigh-r :flex 2) (:knee-r :flex 14) (:thigh-l :flex 8))   ;  of the way:
  (5 (:root :yaw -4 :u -0.04) (:spine :flex -2) (:chest :twist -10) (:head :twist 5) (:arm-r :flex 44 :side 26)    ;  barely
     (:elbow-r :flex 32) (:hand-r :twist 68 :flex -87) (:thigh-r :flex 5) (:knee-r :flex 18) (:thigh-l :flex 7) (:knee-l :flex 14))   ; moving
  (6 (:root :yaw -6 :f -0.02 :u -0.05) (:pelvis :side 2) (:chest :twist -14) (:head :twist 7) (:arm-r :flex 58 :side 32)   ; at first,
     (:elbow-r :flex 39) (:hand-r :twist 100 :flex -90) (:thigh-r :flex 10) (:knee-r :flex 23) (:thigh-l :flex 6))   ;  then
  (7 (:root :yaw -8 :u -0.06) (:spine :flex -1) (:chest :twist -17) (:head :twist 10) (:arm-r :flex 74 :side 40)   ;  gathering
     (:elbow-r :flex 47) (:hand-r :twist 138 :flex -94) (:thigh-r :flex 15) (:knee-r :flex 29) (:thigh-l :flex 4) (:knee-l :flex 15))
  (8 (:root :yaw -11 :f -0.03 :u -0.08) (:pelvis :side 3) (:spine :flex 1) (:chest :twist -22) (:head :twist 14)
     (:arm-r :flex 95 :side 49) (:elbow-r :flex 58) (:hand-r :twist 176 :flex -99) (:thigh-r :flex 22) (:knee-r :flex 36)
     (:thigh-l :flex 2) (:knee-l :flex 17))
  (9 (:root :yaw -14 :f -0.04 :u -0.1) (:pelvis :side 4) (:spine :flex 2) (:chest :twist -28) (:head :twist 18)   ; drawn
     (:arm-r :flex 120 :side 60) (:elbow-r :flex 70) (:hand-r :twist 205 :flex -105)            ; back right, level
     (:thigh-r :flex 30) (:knee-r :flex 45) (:thigh-l :flex 0) (:knee-l :flex 18))
  (10 (:root :yaw -17) (:chest :twist -31) (:arm-r :side 63))                                   ; held: the front knee up,
  (11 (:root :yaw -16 :u -0.11) (:chest :twist -30) (:arm-r :side 61))                          ;  the arm trembling
  (12 (:root :yaw -18 :u -0.1) (:chest :twist -32) (:arm-r :side 64))
  (13 :snap (:root :yaw 0 :f 0.04 :u -0.18) (:pelvis :side 0) (:spine :flex 8) (:chest :twist -18) (:head :twist 4)   ; level,
      (:arm-r :flex 126 :side 20) (:elbow-r :flex 66) (:hand-r :twist 230 :flex -20)           ; out to his right
      (:thigh-r :flex 55) (:knee-r :flex 60) (:thigh-l :flex -20) (:knee-l :flex 10))
  (:s :snap :ya-e-q1-hit)
  (15 :snap :ya-e-q1-thru)
  (:a :ya-e-q2-from)
  (22 (:root :yaw 8 :f 0.05 :u -0.12) (:pelvis :side -2) (:spine :flex 6) (:chest :twist 0) (:head :twist -4)
      (:arm-r :flex 30 :side 10) (:elbow-r :flex 26) (:hand-r :twist 4 :flex -78) (:arm-l :flex -10 :side 14)
      (:thigh-r :flex 34) (:knee-r :flex 38) (:thigh-l :flex -16) (:knee-l :flex 10))
  (:end :ya-e-stance))

;; E2 J2 ZANSHO: from the lunge, a rising backhand low left -> high right; he stands as it rises (the rear foot drawn up). Art K2: its
;; first frame named (:YA-E-Q2-FROM, J1's S+A: the same numbers), its S+A pose named (:YA-E-Q2-TOP: J3's first frame)
(defpose :ya-e-q2-hit (:base :ya-e-stance)
  (:root :yaw -6 :f 0.12 :u -0.06) (:pelvis :side 4) (:spine :flex 4) (:chest :twist -10) (:head :twist 6)
  (:arm-r :flex 86 :side 0) (:elbow-r :flex 14) (:hand-r :twist 20 :flex -60) (:arm-l :flex 10 :side 30)
  (:thigh-r :flex 30 :side 4) (:knee-r :flex 32) (:thigh-l :flex 6 :side 6) (:knee-l :flex 24))
(defpose :ya-e-q2-top (:base :ya-e-q2-hit)                 ; high right (J2's S+A: J3 starts here)
  (:root :yaw -13 :u -0.02) (:spine :flex 0) (:chest :twist -34) (:arm-r :flex 138 :side 60) (:elbow-r :flex 10)
  (:hand-r :twist -125 :flex 45) (:thigh-r :flex 22) (:knee-r :flex 24) (:thigh-l :flex 8) (:knee-l :flex 20)
  (:arm-l :flex 10 :side 40))
(defstrike :ya-e-q2 (7 3 13 :base :ya-e-stance)
  (0 :ya-e-q2-from)                                                                             ; still in the lunge
  (4 (:chest :twist 38) (:root :yaw 24 :u -0.22) (:arm-r :side -36))                             ; loaded
  (:s :snap :ya-e-q2-hit)
  (9 (:root :yaw -14 :u -0.02) (:spine :flex 0) (:chest :twist -34) (:arm-r :flex 140 :side 60) (:elbow-r :flex 10)
     (:hand-r :twist -125 :flex 45) (:thigh-r :flex 22) (:knee-r :flex 24) (:thigh-l :flex 8) (:knee-l :flex 20)
     (:arm-l :flex 10 :side 40))                                                                ; high right
  (:a :ya-e-q2-top)
  (16 (:root :yaw -4 :f 0.05 :u -0.04) (:chest :twist -12) (:arm-r :flex 70 :side 30) (:elbow-r :flex 30)
      (:hand-r :twist -40 :flex -50) (:arm-l :flex 4 :side 16) (:thigh-r :flex 10) (:knee-r :flex 14))
  (:end :ya-e-stance))

;; E3 J3 SENKO (the ender): an underhand rising thrust from a dropped knee, the point travelling up ~27 deg into the body. Art K2: its
;; first frame is J2's S+A pose (the link lands there; it was the stance, a 2 m jump of the tip)
(defpose :ya-e-q3-hit (:base :ya-e-stance)
  (:root :yaw 16 :f 0.24 :u -0.36) (:pelvis :side -4) (:spine :flex 20) (:chest :twist 6) (:head :flex -6)
  (:arm-r :flex 74 :side 6) (:elbow-r :flex 6) (:hand-r :twist -30 :flex -20) (:arm-l :flex -40 :side 30)
  (:thigh-r :flex 80 :side 4) (:knee-r :flex 92) (:thigh-l :flex -6 :side 6) (:knee-l :flex 84))
(defstrike :ya-e-q3 (8 3 18 :base :ya-e-stance)
  (0 :ya-e-q2-top)
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
;; Where an AS lands after J2 / J3 (art K3: their S+1, f8 / f9, as the trials' logs put it; J1's is :YA-E-Q1-THRU): the poses those clips
;; draw on that frame (sampled from the clips, absolute), so AS2a / AS3a start where the link lands
(defpose :ya-e-q2-thru ()
  (:root :u -0.04 :f 0.12 :yaw -10.0) (:pelvis :twist 6.0 :side 4.0) (:spine :flex 2.0) (:chest :flex -4.0 :twist -22.0) (:neck :flex -4.0)
  (:head :flex -4.0 :twist 6.0) (:upper-arm-r :flex 113.0 :side 30.0) (:lower-arm-r :flex 12.0) (:hand-r :flex -7.5 :twist -52.5)
  (:upper-arm-l :flex 10.0 :side 35.0) (:thigh-r :flex 26.0 :side 4.0) (:shin-r :flex 28.0) (:thigh-l :flex 7.0 :side 6.0) (:shin-l :flex 22.0))
(defpose :ya-e-q3-thru ()
  (:root :u -0.35 :f 0.255 :yaw 16.0) (:pelvis :twist 6.0 :side -4.0) (:spine :flex 20.0) (:chest :flex -4.0 :twist 7.0) (:neck :flex -4.0)
  (:head :flex -6.0) (:upper-arm-r :flex 77.0 :side 6.0) (:lower-arm-r :flex 6.0) (:hand-r :flex -18.0 :twist -30.0)
  (:upper-arm-l :flex -40.0 :side 30.0) (:thigh-r :flex 80.0 :side 4.0) (:shin-r :flex 92.0) (:thigh-l :flex -6.0 :side 6.0) (:shin-l :flex 84.0))

;; E-J4 the stepping kesa cut (art batch D, DUEL_YAMA_CORE §34: the user's 「踏步袈裟斬」; was E-J1's clip at :clip-s 14): the fourth shape of
;; the string (J1 the level lunge, J2 the rising backhand, J3 the dropped-knee thrust), the one diagonal down. Frame 0 is J3's S+A (f11: the
;; link lands there; :YA-E-Q3-LAND, J3's :a key, the same numbers). Out of the dropped knee he rises and carries the blade up over his
;; right shoulder (f0-5, small keys first), holds it with the front foot lifted (f6-7: the step's tell), steps in and cuts down across his
;; body from the right shoulder to his low left (f8 released, S9: the blade crosses his centre line going down, the tip 1.52 m ahead), the
;; body dropping into a deep low stance by S+A (f12, the weight on the front knee), held, then a slow heavy rise (f22-32). S+1 (f10) is
;; where AS4 starts (:YA-E-Q4-THRU)
(defpose :ya-e-q3-land ()
  (:root :u -0.34 :f 0.26 :yaw 16.0) (:pelvis :twist 6.0 :side -4.0) (:spine :flex 20.0) (:chest :flex -4.0 :twist 8.0) (:neck :flex -4.0)
  (:head :flex -6.0) (:upper-arm-r :flex 78.0 :side 6.0) (:lower-arm-r :flex 6.0) (:hand-r :flex -16.0 :twist -30.0)
  (:upper-arm-l :flex -40.0 :side 30.0) (:thigh-r :flex 80.0 :side 4.0) (:shin-r :flex 92.0) (:thigh-l :flex -6.0 :side 6.0) (:shin-l :flex 84.0))
(defpose :ya-e-q4-up (:base :ya-e-stance)                   ; over the right shoulder, the point back and up (the f6-7 hold)
  (:root :yaw -20 :f 0.04 :u -0.06) (:pelvis :side 6) (:spine :flex -6) (:chest :twist -25) (:head :twist 14)
  (:arm-r :flex 160 :side 40) (:elbow-r :flex 70) (:hand-r :twist -65 :flex -40) (:arm-l :flex 40 :side 10)
  (:thigh-r :flex 34) (:knee-r :flex 44) (:thigh-l :flex 6) (:knee-l :flex 16))
(defpose :ya-e-q4-hit (:base :ya-e-stance)                  ; the blade sloping down from his high right (the hand 0.37 1.32 0.79) to
  (:root :yaw 8 :f 0.1 :u -0.16) (:pelvis :side -6) (:spine :flex 12) (:chest :twist -14) (:head :flex 6 :twist -4)   ;  the tip on
  (:arm-r :flex 122 :side -30.5 :twist 14) (:elbow-r :flex 22) (:hand-r :twist 152.5 :flex 20) (:arm-l :flex -40 :side 30)   ;  his centre
  (:thigh-r :flex 56 :side 4) (:knee-r :flex 60) (:thigh-l :flex -36 :side 6) (:knee-l :flex 10))   ;  line (FK: 0.00 0.95 1.52)
(defpose :ya-e-q4-low (:base :ya-e-q4-hit)                  ; down at his low left, the body sunk on the front knee (S+A)
  (:root :yaw 24 :f 0.12 :u -0.4) (:pelvis :side -8) (:spine :flex 34) (:chest :twist 24)
  (:arm-r :flex 20 :side -27.5 :twist 0) (:elbow-r :flex 8) (:hand-r :twist 13 :flex -13.5) (:arm-l :flex -44 :side 34)   ; (the tip -0.99 0.12 0.45)
  (:thigh-r :flex 84) (:knee-r :flex 100) (:thigh-l :flex -40) (:knee-l :flex 14))
(defpose :ya-e-q4-thru (:base :ya-e-q4-hit)                 ; on down across him (S+1: AS4 starts here; the tip -0.70 0.50 1.20)
  (:root :yaw 16 :f 0.11 :u -0.38) (:spine :flex 28) (:chest :twist 4) (:arm-r :flex 141 :side -15.5 :twist 0) (:elbow-r :flex 6)
  (:hand-r :twist 153.5 :flex 8.5) (:thigh-r :flex 72) (:knee-r :flex 80))
(defstrike :ya-e-q4 (9 3 20 :base :ya-e-stance)
  (0 :ya-e-q3-land)
  (1 (:root :u -0.33 :f 0.25 :yaw 14) (:spine :flex 18) (:arm-r :flex 84 :side 8) (:elbow-r :flex 12) (:hand-r :twist -34 :flex -18))
  (3 (:root :u -0.26 :f 0.2 :yaw 6) (:pelvis :side -1) (:spine :flex 12) (:chest :twist -4) (:head :twist 4)
     (:arm-r :flex 108 :side 18) (:elbow-r :flex 34) (:hand-r :twist -48 :flex -28) (:arm-l :flex -10 :side 22)
     (:thigh-r :flex 60) (:knee-r :flex 70) (:thigh-l :flex 0) (:knee-l :flex 50))
  (6 :ya-e-q4-up)
  (7 (:root :yaw -22 :u -0.05) (:arm-r :flex 163) (:spine :flex -7) (:thigh-r :flex 38) (:knee-r :flex 48))   ; held, the front foot up
  (8 :snap (:root :yaw -8 :f 0.08 :u -0.16) (:pelvis :side 0) (:spine :flex 8) (:chest :twist -22) (:head :twist 6)   ; released
     (:arm-r :flex 150 :side 30) (:elbow-r :flex 30) (:hand-r :twist -150 :flex 20) (:arm-l :flex 0 :side 22)
     (:thigh-r :flex 56) (:knee-r :flex 60) (:thigh-l :flex -20) (:knee-l :flex 10))
  (:s :snap :ya-e-q4-hit)
  (10 :ya-e-q4-thru)
  (:a :ya-e-q4-low)
  (22 (:root :yaw 22 :u -0.38) (:spine :flex 32) (:chest :twist 20))                           ; held, the weight on it
  (26 (:root :yaw 10 :f 0.06 :u -0.2) (:pelvis :side -3) (:spine :flex 16) (:chest :twist 6) (:arm-r :flex 30 :side -6)   ; the slow
      (:elbow-r :flex 14) (:hand-r :twist 6 :flex -45) (:thigh-r :flex 40) (:knee-r :flex 48) (:thigh-l :flex -16) (:knee-l :flex 10))   ;  rise
  (:end :ya-e-stance))

;; AS4 天地灰尽 (art batch D, DUEL_YAMA_CORE §31 / §34; one cut since §40, the user: 「AS4 請改成只有一刀「帶有斬穿空間特效」的斬擊」; the ash
;; grip / cut / line segments and their clips left with it): frame 0 the pose J4 > AS4 lands on (J4's S+1, f10: :YA-E-Q4-THRU). Ch. 509:
;; the blade carried from his low left round to low behind his right (the only fire: the edge burns, %YA-BLADE-BURN, f0-10), the whole
;; body wound down onto it, held and trembling f5-8 (the tell: all his flame into the edge), released on f9, then one diagonal from his low
;; right behind to his high left in front, the body thrown after it (the tip 2.4 m on S; the white band, the victim's ash and the screen
;; split along the cut, YAMA-AS4-LOOK); the follow-through carries him onto the toes of the front foot, turned past the cut, held there
;; to f26 while the world comes back together, then a slow rise. No slide: the lunge is drawn, 0.9 m.
(defpose :ya-e-as4-hit (:base :ya-e-stance)                ; (FK: the tip 0.00 1.35 2.40, rising to his high left)
  (:root :yaw 6 :f 0.9 :u -0.22) (:pelvis :side -6) (:spine :flex 18) (:chest :twist 6) (:head :flex 2)
  (:arm-r :flex 104.5 :side 11.5) (:elbow-r :flex 4) (:hand-r :twist -28 :flex -50) (:arm-l :flex -40 :side 30)
  (:thigh-r :flex 72 :side 4) (:knee-r :flex 76) (:thigh-l :flex -40 :side 6) (:knee-l :flex 6))
(defpose :ya-e-as4-top (:base :ya-e-as4-hit)               ; through to his high left, on the toes of the front foot (S+A)
  (:root :yaw 22 :f 0.92 :u -0.08) (:spine :flex 4) (:chest :twist 24) (:head :flex -14 :twist -10)
  (:arm-r :flex 120.5 :side 39 :twist 36.5) (:elbow-r :flex 8.5) (:hand-r :twist -7.5 :flex -61.5)   ; (the tip -1.47 1.94 1.10)
  (:thigh-r :flex 60) (:knee-r :flex 50) (:thigh-l :flex -44) (:knee-l :flex 2))
(defpose :ya-e-as4-coil (:base :ya-e-stance)               ; wound down onto the blade low behind his right (the tell, f5-8)
  (:root :yaw -30 :f 0.42 :u -0.42) (:pelvis :side 7) (:spine :flex 26) (:chest :twist -46) (:head :flex 6 :twist 16)
  (:arm-r :flex -20 :side 28 :twist -7.5) (:elbow-r :flex 2) (:hand-r :twist -6 :flex -80) (:arm-l :flex 26 :side 18) (:elbow-l :flex 30)
  (:thigh-r :flex 66) (:knee-r :flex 88) (:thigh-l :flex -8) (:knee-l :flex 46))
(defstrike :ya-e-as4 (10 2 30 :base :ya-e-stance)
  (0 :ya-e-q4-thru)
  (2 (:root :yaw -6 :f 0.3 :u -0.34) (:pelvis :side 3) (:spine :flex 26) (:chest :twist -12) (:head :twist 8)   ; the blade swept
     (:arm-r :flex 40 :side 20 :twist -4) (:elbow-r :flex 10) (:hand-r :twist -4 :flex -60) (:arm-l :flex 10 :side 20)  ;  round low
     (:thigh-r :flex 64) (:knee-r :flex 76) (:thigh-l :flex -12) (:knee-l :flex 30))
  (5 :ya-e-as4-coil)
  (6 (:root :yaw -31 :u -0.43) (:chest :twist -47) (:arm-r :flex -21))                                             ; held,
  (7 (:root :yaw -30 :u -0.42) (:chest :twist -45) (:arm-r :flex -19))                                             ;  trembling
  (8 (:root :yaw -32 :u -0.44) (:chest :twist -48) (:arm-r :flex -22))
  (9 :snap (:root :yaw -8 :f 0.72 :u -0.28) (:spine :flex 20) (:chest :twist -12) (:arm-r :flex 30 :side 30 :twist 0) (:elbow-r :flex 6)   ; released
     (:hand-r :twist -24 :flex -46) (:arm-l :flex -20 :side 26) (:elbow-l :flex 10) (:thigh-r :flex 68) (:knee-r :flex 72) (:thigh-l :flex -34) (:knee-l :flex 8))
  (:s :snap :ya-e-as4-hit)
  (11 (:root :yaw 16 :f 0.92 :u -0.14) (:spine :flex 10) (:chest :twist 16) (:arm-r :flex 97 :side 29.5 :twist 12) (:elbow-r :flex 5) (:hand-r :twist -32.5 :flex -35.5))
  (:a :ya-e-as4-top)
  (16 (:root :yaw 30 :f 0.95 :u -0.06) (:spine :flex 0) (:chest :twist 34) (:head :flex -16 :twist -18) (:arm-r :flex 128 :side 46))   ; past
  (26 (:root :yaw 28 :f 0.93 :u -0.08) (:chest :twist 32) (:arm-r :flex 126))                                    ;  the cut, held
  (36 (:root :yaw 8 :f 0.4 :u -0.08) (:spine :flex 6) (:chest :twist 6) (:head :flex 0 :twist 0) (:arm-r :flex 70 :side 10 :twist 0)
      (:elbow-r :flex 26) (:hand-r :twist -10 :flex -70) (:thigh-r :flex 30) (:knee-r :flex 30) (:thigh-l :flex -14) (:knee-l :flex 10))
  (:end :ya-e-stance))

;; E5 K2 NISSHO, the sunrise: the blade from the ground behind him swung up through vertical in front, the body rising
;; with it onto the toes (a step in: the move's slide); at S the blade is level ahead at the chest, rising
(defpose :ya-e-f2-hit (:base :ya-e-stance)
  (:root :yaw 5 :f 0.3 :u -0.08) (:spine :flex 6) (:chest :twist 0) (:head :flex -6)
  (:arm-r :flex 95 :side 6) (:elbow-r :flex 4) (:hand-r :twist -15 :flex -75) (:arm-l :flex -20 :side 30)
  (:thigh-r :flex 46) (:knee-r :flex 44) (:thigh-l :flex -24) (:knee-l :flex 14))
(defpose :ya-e-f2-top (:base :ya-e-f2-hit)                 ; the blade straight up, on his toes (S+A: NS1c starts here)
  (:root :yaw 5 :f 0.32 :u 0.0) (:spine :flex -12) (:head :flex -16) (:arm-r :flex 172) (:hand-r :twist -5 :flex -95)
  (:thigh-r :flex 30) (:knee-r :flex 20) (:thigh-l :flex -24) (:knee-l :flex 6) (:arm-l :flex -20 :side 40))

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
(defpose :ya-e-kyokko-land (:base :ya-e-kyokko-hit)        ; the lunge held out (S+A: NS1b starts here)
  (:root :f 0.61) (:spine :flex 48))
;; Art K2 (DUEL_YAMA_CORE §17): at the move's S20 (was this clip's S15 at x0.75). Frame 0 is pointer 1's stance (:YA-ST-HIGASHI: NS1
;; starts only from it, and an attack starts with no blend); the charge f0-11 draws the hilt back to his right hip (small keys first),
;; chambered and held f12-17 (the point at him, trembling), released f18-19 into the lunge on S
(defstrike :ya-e-kyokko (20 3 26 :base :ya-e-stance)
  (0 :ya-st-higashi)
  (1 (:arm-r :flex 71 :side -5) (:elbow-r :flex 27) (:hand-r :twist 89 :flex -13))
  (2 (:root :yaw -1) (:arm-r :flex 70 :side -4) (:elbow-r :flex 29) (:hand-r :twist 87 :flex -14) (:arm-l :flex 3)   ; the charge,
     (:thigh-r :flex -3) (:thigh-l :flex 11) (:knee-r :flex 9) (:knee-l :flex 13))                                   ;  a key a frame
  (3 (:root :u -0.02) (:spine :flex -5) (:chest :twist 3) (:head :twist 1) (:arm-r :flex 68 :side -2) (:elbow-r :flex 32)   ;  (3 6 10
     (:hand-r :twist 84 :flex -17) (:arm-l :flex 5) (:thigh-r :flex -2) (:knee-r :flex 10) (:knee-l :flex 14))     ;  15 21 29 38
  (4 (:root :yaw -2) (:head :twist 2) (:arm-r :flex 65 :side 1) (:elbow-r :flex 35) (:hand-r :twist 80 :flex -20)   ;  49 62 79 %
     (:arm-l :flex 7) (:thigh-r :flex -1) (:thigh-l :flex 12) (:knee-r :flex 11) (:knee-l :flex 15))                ;  of the way):
  (5 (:root :yaw -3 :u -0.03) (:pelvis :side 1) (:spine :flex -4) (:chest :twist 2) (:arm-r :flex 61 :side 4)       ;  the fist
     (:elbow-r :flex 40) (:hand-r :twist 75 :flex -24) (:arm-l :flex 9) (:thigh-r :flex 1) (:thigh-l :flex 13) (:knee-r :flex 13) (:knee-l :flex 16))
  (6 (:root :yaw -4) (:spine :flex -3) (:chest :twist 1) (:head :twist 3) (:arm-r :flex 57 :side 8) (:elbow-r :flex 46)   ;  drawn
     (:hand-r :twist 69 :flex -29) (:arm-l :flex 12) (:thigh-r :flex 3) (:thigh-l :flex 14) (:knee-r :flex 15) (:knee-l :flex 18))   ; back
  (7 (:root :yaw -6 :u -0.04) (:spine :flex -2) (:chest :twist 0) (:head :twist 5) (:arm-r :flex 51 :side 13) (:elbow-r :flex 53)   ;  to
     (:hand-r :twist 61 :flex -36) (:arm-l :flex 16 :side 9) (:thigh-r :flex 6) (:thigh-l :flex 16) (:knee-r :flex 17) (:knee-l :flex 20))   ; the
  (8 (:root :yaw -8 :u -0.05) (:pelvis :side 2) (:spine :flex -1) (:chest :twist -1) (:head :twist 6) (:arm-r :flex 45 :side 19)   ;  hip
     (:elbow-r :flex 62) (:hand-r :twist 52 :flex -44) (:arm-l :flex 20) (:thigh-r :flex 9) (:thigh-l :flex 18) (:knee-r :flex 20) (:knee-l :flex 23))
  (9 (:root :yaw -10 :u -0.06) (:spine :flex 1) (:chest :twist -3) (:head :twist 8) (:arm-r :flex 37 :side 26) (:elbow-r :flex 72)
     (:hand-r :twist 41 :flex -53) (:arm-l :flex 26) (:thigh-r :flex 13) (:thigh-l :flex 20) (:knee-r :flex 24) (:knee-l :flex 26))
  (10 (:root :yaw -12 :u -0.08) (:pelvis :side 3) (:spine :flex 3) (:chest :twist -5) (:head :twist 10) (:arm-r :flex 27 :side 35)
      (:elbow-r :flex 84) (:hand-r :twist 28 :flex -63) (:arm-l :flex 32) (:thigh-r :flex 17) (:thigh-l :flex 22) (:knee-r :flex 28) (:knee-l :flex 29))
  (11 (:root :yaw -16 :u -0.1) (:pelvis :side 4) (:spine :flex 5) (:chest :twist -7) (:head :twist 13) (:arm-r :flex 15 :side 46)
      (:elbow-r :flex 100) (:hand-r :twist 11 :flex -78) (:arm-l :flex 40 :side 10) (:thigh-r :flex 23) (:thigh-l :flex 26) (:knee-r :flex 33) (:knee-l :flex 34))
  (12 (:root :yaw -20 :u -0.12) (:pelvis :side 5) (:spine :flex 8) (:chest :twist -10) (:head :twist 16)   ; chambered:
      (:arm-r :flex 0 :side 60) (:elbow-r :flex 120) (:hand-r :twist -10 :flex -95)             ; the hilt at his right
      (:arm-l :flex 50 :side 10) (:thighs :flex 30) (:knees :flex 40))                          ; side, the point at him
  (14 (:root :yaw -22 :u -0.14) (:arm-r :side 62) (:elbow-r :flex 123) (:knees :flex 43))      ; held, sinking,
  (15 (:root :yaw -23 :u -0.15) (:arm-r :side 64) (:elbow-r :flex 125) (:knees :flex 45))      ;  trembling
  (16 (:root :yaw -22 :u -0.15) (:arm-r :side 62) (:elbow-r :flex 124) (:knees :flex 45))
  (17 (:root :yaw -24 :u -0.16) (:arm-r :side 64) (:elbow-r :flex 126) (:knees :flex 46))
  (18 :snap (:root :yaw -8 :f 0.32 :u -0.28) (:spine :flex 32) (:chest :twist -2) (:head :twist 5 :flex -28)   ; released
      (:arm-r :flex 104 :side 24) (:elbow-r :flex 40) (:hand-r :flex -103)
      (:arm-l :flex -24 :side 17) (:thigh-r :flex 66) (:knee-r :flex 68) (:thigh-l :flex -34) (:knee-l :flex 8))
  (19 :snap (:root :yaw -3 :f 0.44 :u -0.31) (:spine :flex 38) (:chest :twist 0) (:head :twist 2 :flex -34)
      (:arm-r :flex 130 :side 12) (:elbow-r :flex 18) (:hand-r :twist -10 :flex -104)
      (:arm-l :flex -46 :side 18) (:thigh-r :flex 74) (:knee-r :flex 76) (:thigh-l :flex -42) (:knee-l :flex 4))
  (:s :snap :ya-e-kyokko-hit)
  (22 (:root :f 0.62) (:spine :flex 48))
  (:a :ya-e-kyokko-land)
  (35 (:root :f 0.4 :u -0.24) (:spine :flex 30) (:head :flex -24) (:arm-r :flex 90) (:hand-r :flex -90)
      (:arm-l :flex -30 :side 16) (:thigh-r :flex 60) (:knee-r :flex 64) (:thigh-l :flex -30) (:knee-l :flex 8))
  (:end :ya-e-stance))

;; Art K2 (DUEL_YAMA_CORE §17): NS1b at its own S14 (was this clip's S19 at x1.36); frame 0 is KYOKKO's landing (the NS link lands at
;; NS1a's S+A: :YA-E-KYOKKO-LAND). Out of the lunge he sinks and lowers the point onto the plaza ahead (f9; swung back behind him from
;; the lunge, the blade went through the floor), holds it there (the tell, f9-12), then the rise through level (S) to vertical
(defstrike :ya-e-f2 (14 4 24 :base :ya-e-stance)
  (0 :ya-e-kyokko-land)
  (4 (:root :yaw -6 :f 0.48 :u -0.28) (:spine :flex 38) (:head :flex -26) (:chest :twist -6)     ; out of the lunge, the
     (:arm-r :flex 50 :side 20) (:elbow-r :flex 20) (:hand-r :twist 0 :flex -20)                ;  point lowering
     (:arm-l :flex -40 :side 18) (:thigh-l :flex -30) (:knee-l :flex 30))
  (9 (:root :yaw -12 :f 0.34 :u -0.32) (:pelvis :side 6) (:spine :flex 34) (:chest :twist -14) (:head :flex -14)   ; crouched,
     (:hand-r :twist 30 :flex -38) (:arm-l :flex 30 :side 20)                                   ;  the tip on the plaza
     (:thigh-r :flex 56) (:knee-r :flex 80) (:thigh-l :flex 40) (:knee-l :flex 80))             ;  ahead
  (11 (:root :yaw -13 :u -0.33) (:spine :flex 35) (:hand-r :flex -37))                          ; held: the tell
  (12 (:root :yaw -12 :u -0.33) (:spine :flex 35) (:hand-r :flex -37))
  (13 :snap (:root :yaw -2 :f 0.32 :u -0.16) (:spine :flex 16) (:chest :twist -4)               ; up
      (:arm-r :flex 72 :side 10) (:elbow-r :flex 8) (:hand-r :twist 0 :flex -55))
  (:s :snap :ya-e-f2-hit)
  (16 (:root :yaw 5 :f 0.32 :u 0.0) (:spine :flex -12) (:head :flex -16) (:arm-r :flex 175) (:hand-r :twist -5 :flex -95)
      (:thigh-r :flex 30) (:knee-r :flex 20) (:thigh-l :flex -24) (:knee-l :flex 6) (:arm-l :flex -20 :side 40))  ; vertical
  (:a :ya-e-f2-top)
  (30 (:root :yaw 2 :f 0.14 :u -0.04) (:spine :flex 0) (:head :flex -6) (:arm-r :flex 90 :side 14) (:elbow-r :flex 30)
      (:hand-r :twist -10 :flex -80) (:arm-l :flex -4 :side 16) (:thigh-r :flex 16) (:knee-r :flex 16) (:thigh-l :flex -8))
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
  (:arm-r :flex 90 :side -6) (:elbow-r :flex 4) (:hand-r :twist -10 :flex -95)
  (:thigh-r :flex 70) (:knee-r :flex 80) (:knee-l :flex 16))
;; Art K2 (DUEL_YAMA_CORE §17): frame 0 is NS1b's S+A pose (the blade straight up: the link lands there; it was the stance), and only
;; the tip touches the plaza from f20 (it sank 8 cm into it: the wrist keeps it on the floor as he sinks)
(defstrike :ya-kyoku (18 5 26 :base :ya-e-stance)
  (0 :ya-e-f2-top)
  (8 (:root :yaw 20 :f 0.12 :u 0.0) (:pelvis :side -5) (:chest :twist 35) (:spine :flex -6) (:head :twist -12 :flex -4)   ; over
     (:arm-r :flex 140 :side 20) (:elbow-r :flex 60) (:hand-r :twist 35 :flex -110)             ; the left shoulder,
     (:thigh-r :flex -4) (:knee-r :flex 8) (:thigh-l :flex 22) (:knee-l :flex 22) (:arm-l :flex 2 :side 8))   ; angled
  (15 (:root :yaw 24 :u 0.01) (:chest :twist 38) (:arm-r :flex 145) (:spine :flex -8))         ; held
  (:s :snap :ya-kyoku-hit)
  (20 :snap :ya-kyoku-bite)
  (22 (:root :u -0.27) (:spine :flex 36) (:arm-r :flex 94))
  (32 (:root :u -0.25) (:spine :flex 34) (:arm-r :flex 92))
  (40 (:root :yaw -2 :f 0.14 :u -0.12) (:spine :flex 14) (:chest :twist 0) (:arm-r :flex 40 :side 12) (:elbow-r :flex 24)
      (:hand-r :twist 0 :flex -70) (:thigh-r :flex 30) (:knee-r :flex 34) (:thigh-l :flex -12) (:knee-l :flex 10))
  (:end :ya-e-stance))
;; AS1 the tip-tap, point-blank (art K2, DUEL_YAMA_CORE §15.2.2 / §17; was ya-kyoku at x1.8): no body swing. From J1's S+1 (where the AS
;; starts: :YA-E-Q1-THRU) the wrist brings the point back over the centre and lifts it to his shoulder's height (f7), held a frame, then
;; drops it straight onto the plaza on S10, the tip 1.55 m ahead: the far end of L6's notch (0.2-1.6 m), the arc's 1.6
(defpose :ya-e-as1-hit (:base :ya-e-stance)
  (:root :yaw 4 :f 0.2 :u -0.18) (:spine :flex 30) (:chest :twist 4) (:head :flex 8) (:arm-l :flex -10 :side 22)
  (:thigh-r :flex 48) (:knee-r :flex 54) (:thigh-l :flex -22) (:knee-l :flex 14)
  (:arm-r :flex 80 :side 30) (:elbow-r :flex 4) (:hand-r :twist -5 :flex -85))
(defstrike :ya-e-as1 (10 3 24 :base :ya-e-stance)
  (0 :ya-e-q1-thru)
  (3 (:root :yaw 12 :f 0.1 :u -0.18) (:chest :twist 2) (:head :twist -8) (:arm-l :flex -20 :side 24)   ; the wrist turns
     (:arm-r :flex 80 :side -10) (:elbow-r :flex 36) (:hand-r :twist 60 :flex -16))             ;  the point back over
  (7 (:root :yaw -2 :f 0.06 :u -0.08) (:pelvis :side 0) (:spine :flex 8) (:chest :twist -4) (:head :twist 0 :flex 4)   ; up to
     (:thigh-r :flex 30) (:knee-r :flex 34) (:thigh-l :flex -14) (:knee-l :flex 10) (:arm-l :flex -10 :side 20)   ; his shoulder
     (:arm-r :flex 55 :side 8) (:elbow-r :flex 34) (:hand-r :twist -5 :flex -20))
  (8 (:hand-r :flex -18) (:root :u -0.09))                                                      ; held
  (9 :snap (:root :f 0.13 :u -0.13) (:spine :flex 19) (:arm-r :flex 67 :side 19) (:elbow-r :flex 18) (:hand-r :flex -55))   ; dropped
  (:s :snap :ya-e-as1-hit)
  (11 (:root :u -0.19) (:spine :flex 31))
  (:a (:root :u -0.19) (:spine :flex 31))
  (25 (:root :yaw 2 :f 0.1 :u -0.1) (:spine :flex 12) (:head :flex 0) (:arm-r :flex 40 :side 16) (:elbow-r :flex 20)
      (:hand-r :twist 0 :flex -80) (:arm-l :flex 2 :side 10) (:thigh-r :flex 24) (:knee-r :flex 28) (:thigh-l :flex -10) (:knee-l :flex 10))
  (:end :ya-e-stance))

;; B1 南 (South), art K3 (DUEL_YAMA_CORE §15.2.2 / §18): six clips, one a segment, none sharing a body line. NS3a the plant (S22): from 南's
;; stance the blade brought upright before his face, point down, the hilt at the chin (the incantation, the tell, held f6-18, trembling
;; f16-18), then driven straight down into the plaza in a half kneel on S; held kneeling through the hands' 17 f delay (:YA-KAKA-A = f39,
;; NS3b's first frame)
(defpose :ya-kaka-up (:base :ya-st-minami)                ; upright before the face, point down, the hilt at the chin
  (:root :u 0.03) (:spine :flex -6) (:chest :twist 12) (:head :flex 4) (:arm-r :flex 6 :side 112) (:elbow-r :flex 138) (:hand-r :twist 62 :flex -66))
(defpose :ya-kaka-hit (:base :ya-e-stance)
  (:root :u -0.36) (:spine :flex 22) (:chest :twist 14) (:head :flex 6)
  (:arm-r :flex 112 :side -24) (:elbow-r :flex 16) (:hand-r :twist -150 :flex 0)
  (:thigh-r :flex -6) (:knee-r :flex 100) (:thigh-l :flex 84) (:knee-l :flex 88) (:arm-l :flex 10 :side 20))
(defpose :ya-kaka-a (:base :ya-kaka-hit)                  ; kneeling on, the head bowed (S+A: NS3b starts here)
  (:root :u -0.37) (:spine :flex 24) (:head :flex 10))
(defstrike :ya-kaka (22 17 20 :base :ya-e-stance)
  (0 :ya-st-minami)
  (1 :ya-st-minami (:root :u 0.003) (:chest :twist 1) (:arm-r :side 129) (:hand-r :twist 51 :flex -60))   ; the rise to the
  (2 (:root :u 0.008) (:spine :flex -4.3) (:chest :twist 2) (:arm-r :flex 0.4 :side 127) (:elbow-r :flex 139.8) (:hand-r :twist 52 :flex -61))   ; face,
  (3 (:root :u 0.013) (:spine :flex -4.6) (:chest :twist 3.5) (:arm-r :flex 1 :side 124) (:elbow-r :flex 139.5) (:hand-r :twist 54 :flex -62))   ;  a key a
  (4 (:root :u 0.02) (:spine :flex -5) (:chest :twist 6) (:head :flex 5) (:arm-r :flex 2.5 :side 120) (:elbow-r :flex 139) (:hand-r :twist 57 :flex -63))   ; frame
  (5 (:root :u 0.026) (:spine :flex -5.6) (:chest :twist 9) (:arm-r :flex 4.4 :side 116) (:elbow-r :flex 138.5) (:hand-r :twist 60 :flex -65))
  (6 :ya-kaka-up)                                                                                 ; held: the words
  (12 :ya-kaka-up (:root :u 0.035) (:spine :flex -6.5) (:head :flex 3))
  (16 :ya-kaka-up (:root :u 0.04) (:spine :flex -7) (:head :flex 2) (:arm-r :side 113))        ; trembling,
  (17 (:arm-r :side 110.5) (:hand-r :flex -67))                                                  ;  3 frames
  (18 (:root :u 0.045) (:arm-r :side 113.5) (:hand-r :flex -65))
  (19 :snap (:root :u 0.05) (:spine :flex -9) (:head :flex 0) (:arm-r :flex 10 :side 114) (:elbow-r :flex 134))   ; the lift
  (20 :snap (:root :u -0.1) (:spine :flex 4) (:chest :twist 13) (:head :flex 4) (:arm-r :flex 60 :side 30) (:elbow-r :flex 70)   ; driven
     (:hand-r :twist -40 :flex -40) (:thigh-l :flex 40) (:knee-l :flex 44) (:knee-r :flex 50))                        ;  down
  (21 :snap (:root :u -0.3) (:spine :flex 16) (:arm-r :flex 100 :side -14) (:elbow-r :flex 26) (:hand-r :twist -130 :flex -10)
      (:thigh-r :flex -4) (:knee-r :flex 88) (:thigh-l :flex 76) (:knee-l :flex 80))
  (:s :snap :ya-kaka-hit)
  (24 (:root :u -0.38) (:spine :flex 23))
  (30 (:root :u -0.36) (:spine :flex 23) (:head :flex 8))
  (:a :ya-kaka-a)
  (50 (:root :u -0.2) (:spine :flex 12) (:head :flex 0) (:arm-r :flex 70 :side 0) (:elbow-r :flex 30) (:hand-r :twist -40 :flex -70)
      (:thigh-r :flex 10) (:knee-r :flex 40) (:thigh-l :flex 40) (:knee-l :flex 44))
  (:end :ya-e-stance))
;; NS3b the swarm's "go" (S16): still kneeling, the hand twists the planted hilt and levers it forward (the point stays in the plaza), the
;; head lifts on S; S+A (:YA-E-MINAMI-B-A, f18) is NS3c's first frame
(defpose :ya-e-minami-b-hit (:base :ya-kaka-a)             ; kneeling up straight, the head lifted, the hilt drawn back over the point
  (:root :u -0.36) (:spine :flex 4) (:chest :twist 6 :flex -6) (:neck :flex -8) (:head :flex -22)   ;  (FK: the point stays where
  (:arm-r :flex 82.8 :side -23.3) (:elbow-r :flex 11.1) (:hand-r :twist -150.4 :flex 19.4))         ;  it went in, within 0.05 m)
(defpose :ya-e-minami-b-a (:base :ya-e-minami-b-hit)
  (:spine :flex 5) (:head :flex -24))
(defstrike :ya-e-minami-b (16 2 22 :base :ya-e-stance)
  (0 :ya-kaka-a)
  (5 (:hand-r :twist -149.5) (:head :flex 12) (:spine :flex 26))                                  ; bowed lower, the hilt
  (10 (:hand-r :twist -149) (:spine :flex 27) (:head :flex 13))                                   ;  twisted in the hand
  (13 (:root :u -0.375) (:spine :flex 27.5) (:head :flex 13))                                     ; held
  (14 (:spine :flex 27))
  (15 :snap (:spine :flex 14) (:head :flex -6) (:arm-r :flex 98 :side -24) (:elbow-r :flex 13) (:hand-r :flex 9))   ; levered
  (:s :snap :ya-e-minami-b-hit)                                                                   ; "go": up, the head lifted
  (:a :ya-e-minami-b-a)
  (30 (:root :u -0.24) (:spine :flex 12) (:head :flex -4) (:arm-r :flex 80 :side 0) (:elbow-r :flex 24) (:hand-r :twist -40 :flex -70)
      (:thigh-r :flex 10) (:knee-r :flex 44) (:thigh-l :flex 40) (:knee-l :flex 46))
  (:end :ya-e-stance))
;; NS3c the cut and the topple (S18; §38, the user 2026-11-22: 「NSc 的斷塔傾倒增加一個山本將塔斬斷的動作」; until then he rose, ripping
;; the blade up out of the plaza to overhead): from NSb's kneel (f0 = :YA-E-MINAMI-B-A) the blade ripped out and drawn back low to his
;; right, coiled f6-8 (held), then one low forehand sweep right to left on a 0.42 m lunge, crouched, the tip a hand above the plaza
;; crossing his centre line 1.74 m ahead on +YA-TOWER-CUT+ (f11: through the tower 1.5 m ahead, at its break), rising through his
;; left and up over his left shoulder by S (the topple; the tip 2.5 m up). Motion refs (docs/research/yamamoto-rework/motion-refs.md):
;; E1's level forehand R->L (ch. 507's lunge), S4's waist-high sweep with the torso turning, the charred blade one-handed.
(defpose :ya-e-minami-c-cut (:base :ya-e-stance)
  (:root :yaw 0 :f 0.42 :u -0.3) (:pelvis :side -4) (:spine :flex 26) (:chest :twist 0) (:head :flex 10)
  (:arm-r :flex 55 :side 15) (:elbow-r :flex 4) (:hand-r :twist 0 :flex -17) (:arm-l :flex -30 :side 34)
  (:thigh-r :flex 72 :side 4) (:knee-r :flex 80) (:thigh-l :flex -40 :side 6) (:knee-l :flex 14))
(defpose :ya-e-minami-c-hit (:base :ya-e-minami-c-cut)
  (:root :yaw 24 :f 0.35 :u -0.1) (:pelvis :side -2) (:spine :flex 4) (:chest :twist 30) (:head :flex -10 :twist -14)
  (:arm-r :flex 140 :side -20 :twist 20) (:elbow-r :flex 10) (:hand-r :twist 10 :flex -40) (:arm-l :flex -36 :side 36)
  (:thigh-r :flex 56) (:knee-r :flex 48) (:thigh-l :flex -38) (:knee-l :flex 4))
(defstrike :ya-e-minami-c (18 2 30 :base :ya-e-stance)
  (0 :ya-e-minami-b-a)
  (3 (:root :yaw -12 :f 0.05 :u -0.34) (:spine :flex 20) (:chest :twist -20) (:head :flex 0 :twist 10)
     (:arm-r :flex 40 :side 30) (:elbow-r :flex 10) (:hand-r :twist -20 :flex -48) (:arm-l :flex 10 :side 20)
     (:thigh-r :flex 60 :side 4) (:knee-r :flex 84) (:thigh-l :flex -10) (:knee-l :flex 40))
  (6 (:root :yaw -28 :f 0.08 :u -0.36) (:spine :flex 22) (:chest :twist -42) (:head :twist 18)
     (:arm-r :flex 6 :side 38) (:elbow-r :flex 4) (:hand-r :twist -24 :flex -42) (:arm-l :flex 20 :side 22))
  (8 (:root :yaw -27 :u -0.37) (:chest :twist -41) (:arm-r :side 39))
  (9 :snap (:root :yaw -22 :f 0.25 :u -0.33) (:spine :flex 24) (:chest :twist -34) (:head :twist 10)
     (:arm-r :flex 26 :side 34) (:hand-r :twist -14 :flex -36) (:arm-l :flex -10 :side 28)
     (:thigh-r :flex 68) (:knee-r :flex 82) (:thigh-l :flex -30) (:knee-l :flex 20))
  (10 :snap (:root :yaw -12 :f 0.38 :u -0.31) (:chest :twist -18) (:head :twist 4) (:arm-r :flex 44 :side 26) (:hand-r :twist -6 :flex -23))
  (11 :snap :ya-e-minami-c-cut)
  (12 :snap (:root :yaw 14 :f 0.46 :u -0.28) (:spine :flex 24) (:chest :twist 20) (:head :twist -6)
      (:arm-r :flex 62 :side -6) (:hand-r :twist 6 :flex -22))
  (13 :snap (:root :yaw 22 :f 0.45 :u -0.25) (:chest :twist 34) (:head :twist -10) (:arm-r :flex 74 :side -22) (:hand-r :twist 10 :flex -20))
  (15 (:root :yaw 24 :f 0.42 :u -0.18) (:spine :flex 14) (:chest :twist 34) (:arm-r :flex 110 :side -26 :twist 14) (:hand-r :flex -30))
  (:s :snap :ya-e-minami-c-hit)
  (:a (:root :u -0.09) (:arm-r :flex 142))
  (32 (:root :yaw 10 :f 0.2 :u -0.06) (:spine :flex 4) (:chest :twist 6) (:head :flex 0 :twist 0)
      (:arm-r :flex 50 :side 20 :twist 0) (:elbow-r :flex 20) (:hand-r :twist 0 :flex -80) (:arm-l :flex 6 :side 16)
      (:thigh-r :flex 20) (:knee-r :flex 24) (:thigh-l :flex -6) (:knee-l :flex 10))
  (44 (:root :yaw 2 :f 0.04 :u -0.03) (:chest :twist -2))
  (:end :ya-e-stance))
;; AS3a the hands (S10): from J3's dropped knee (:YA-E-Q3-THRU) a reverse stab into the plaza by the front foot, the blade upright in the
;; plaza on S and held (:YA-E-AS3A-A, f13 = AS3b's first frame: the planted spot of YAMA-PLANTED, so the blade stays where it went in)
(defpose :ya-e-as3a-hit (:base :ya-e-q3-thru)
  (:root :u -0.36 :f 0.22 :yaw 6) (:spine :flex 2.7) (:chest :twist -12.8) (:head :flex 4)   ; (solved by FK: the grip 0.74 m up at
  (:upper-arm-r :flex 72.4 :side 1.4) (:lower-arm-r :flex 10) (:hand-r :twist 0.1 :flex -171))  ;  0.2 right, 0.79 ahead, the point in)
(defpose :ya-e-as3a-a (:base :ya-e-as3a-hit)
  (:root :u -0.365) (:spine :flex 3.2))
(defstrike :ya-e-as3a (10 3 16 :base :ya-e-stance)
  (0 :ya-e-q3-thru)
  (3 (:root :u -0.33 :yaw 12) (:upper-arm-r :flex 70 :side 30) (:lower-arm-r :flex 50) (:hand-r :twist 0 :flex -60))   ; drawn back,
  (6 (:root :u -0.3 :yaw 8) (:spine :flex 16) (:upper-arm-r :flex 100 :side 24) (:lower-arm-r :flex 60) (:hand-r :flex -100))   ;  raised,
  (7 (:root :u -0.29) (:upper-arm-r :flex 102))                                                   ;  point down
  (8 (:root :u -0.3) (:upper-arm-r :flex 101))                                                    ; held
  (9 :snap (:root :u -0.34) (:spine :flex 22) (:upper-arm-r :flex 70 :side 23) (:lower-arm-r :flex 30) (:hand-r :flex -96))   ; driven
  (:s :snap :ya-e-as3a-hit)
  (:a :ya-e-as3a-a)
  (22 (:root :u -0.24 :f 0.16 :yaw 4) (:spine :flex 16) (:upper-arm-r :flex 50 :side 16) (:lower-arm-r :flex 24) (:hand-r :flex -80)
      (:thigh-r :flex 50) (:shin-r :flex 56) (:thigh-l :flex -4) (:shin-l :flex 40))
  (:end :ya-e-stance))
;; AS3b the swarm, by hand (S10): the hand leaves the planted hilt (YAMA-PLANTED: the blade stays in the plaza f0-23) and sweeps low, palm
;; forward on S; S+A (:YA-E-AS3B-A, f12) is AS3c's first frame; it comes back to the hilt by f24
(defpose :ya-e-as3b-hit (:base :ya-e-as3a-a)
  (:root :yaw -8) (:spine :flex 24) (:chest :twist 16) (:head :flex -6)
  (:upper-arm-r :flex 56 :side -14) (:lower-arm-r :flex 4) (:hand-r :twist 0 :flex 70))
(defpose :ya-e-as3b-a (:base :ya-e-as3b-hit)
  (:root :yaw -10) (:chest :twist 20) (:upper-arm-r :side -22))
(defstrike :ya-e-as3b (10 2 18 :base :ya-e-stance)
  (0 :ya-e-as3a-a)
  (3 (:root :yaw 8) (:chest :twist -14) (:upper-arm-r :flex 10 :side 30) (:lower-arm-r :flex 40) (:hand-r :flex 20))   ; let go, drawn
  (7 (:root :yaw 10 :u -0.38) (:chest :twist -18) (:upper-arm-r :flex 0 :side 32))                                    ;  back low
  (8 (:root :yaw 11) (:chest :twist -19))                                                                            ; held
  (9 :snap (:root :yaw 0) (:chest :twist 0) (:upper-arm-r :flex 40 :side 10) (:lower-arm-r :flex 10) (:hand-r :flex 50))   ; the sweep
  (:s :snap :ya-e-as3b-hit)
  (:a :ya-e-as3b-a)
  (24 :ya-e-as3a-a)                                                                                                  ; back on the hilt
  (:end :ya-e-stance))
;; AS3c the pile (S12): the hand back on the hilt by f6 (planted until then), he stands and draws the blade out low, and looks away as it
;; lands on S (canon: the back turned)
(defpose :ya-e-as3c-hit (:base :ya-e-stance)
  (:root :u -0.04 :f 0.1 :yaw -14) (:spine :flex 4) (:chest :twist -26) (:neck :flex -4) (:head :flex -6 :twist -50)
  (:arm-r :flex 14 :side 46) (:elbow-r :flex 12) (:hand-r :twist 20 :flex -100) (:arm-l :flex 4 :side 14)
  (:thigh-r :flex 10 :side 8) (:knee-r :flex 14) (:thigh-l :flex -6 :side 6) (:knee-l :flex 10))
(defstrike :ya-e-as3c (12 3 30 :base :ya-e-stance)
  (0 :ya-e-as3b-a)
  (6 :snap :ya-e-as3a-a)                                                                          ; the hand on the hilt
  (9 (:root :u -0.2 :f 0.16 :yaw -4) (:spine :flex 14) (:chest :twist -10) (:head :twist -16)    ; standing, drawing
     (:upper-arm-r :flex 30 :side 40) (:lower-arm-r :flex 14) (:hand-r :twist 10 :flex -96)      ;  it out low
     (:thigh-r :flex 30) (:shin-r :flex 40) (:thigh-l :flex 10) (:shin-l :flex 30))
  (11 (:root :u -0.07 :yaw -12) (:chest :twist -22) (:head :twist -40))
  (:s :snap :ya-e-as3c-hit)
  (:a (:head :twist -54) (:chest :twist -28))
  (34 (:head :twist -46) (:chest :twist -24))
  (:end :ya-e-stance))

;; B2 O KITA: TENCHI in play (after the :sh-run flash step): the flame gathered on the blade trailing low behind him, one
;; huge passing cut rising from his low right across to his high left with the body travelling through it (the cine's
;; :ya-tenchi is the slow horizontal version)
(defpose :ya-e-tenchi-hit (:base :ya-e-stance)
  (:root :yaw 8 :f 0.62 :u -0.28) (:pelvis :side -6) (:spine :flex 20) (:chest :twist 4) (:head :flex -4)
  (:arm-r :flex 110 :side 10) (:elbow-r :flex 0) (:hand-r :twist -15 :flex -60)
  (:arm-l :flex -60 :side 30) (:thigh-r :flex 76) (:knee-r :flex 80) (:thigh-l :flex -44) (:knee-l :flex 4))
;; Art K3 (DUEL_YAMA_CORE §15.2.2 / §18): re-authored at the move's S24 (was S6 stretched x4). Frame 0 is the form's idle (北 starts from any
;; pointer's stance: the move's :blend 4 fades in). The gather f0-15: the blade drawn down and back until it trails low behind him (the only
;; time it burns: YAMA-BK-MOVES 9), the body sinking, a key a frame (small first); the coil held f16-20, trembling; the release f21-23;
;; the passing cut on S, the body through it
(defpose :ya-e-tenchi-coil (:base :ya-e-stance)          ; trailing low behind, coiled
  (:root :yaw -20 :u -0.2) (:spine :flex 34) (:head :flex -16) (:arm-r :flex -46 :side 30) (:elbow-r :flex 10)
  (:hand-r :twist 5 :flex -48) (:arm-l :flex 40) (:thigh-r :flex 40) (:knee-r :flex 50) (:thigh-l :flex -20) (:knee-l :flex 30))
(defstrike :ya-e-tenchi (24 2 30 :base :ya-e-stance)
  (0)                                                     ; the gather: a key a frame, eased in to f8 (the blade swung out
                                                          ;  over the plaza), on to the coil by f16
  (1 (:hand-r :flex -79.1 :twist 0.1) (:head :flex -4.2) (:lower-arm-r :flex 17.7) (:root :u -0.023 :yaw -0.3) (:shin-l :flex 12.3) (:shin-r :flex 8.6) (:spine :flex -3.4) (:thigh-l :flex 9.6) (:thigh-r :flex -3.4) (:upper-arm-l :flex 2.6) (:upper-arm-r :flex 15.1 :side 14.4))
  (2 (:hand-r :flex -77.2 :twist 0.2) (:head :flex -4.6) (:lower-arm-r :flex 16.9) (:root :u -0.029 :yaw -0.9) (:shin-l :flex 12.9) (:shin-r :flex 10) (:spine :flex -2.2) (:thigh-l :flex 8.6) (:thigh-r :flex -1.9) (:upper-arm-l :flex 3.8) (:upper-arm-r :flex 13.1 :side 15.3))
  (3 (:hand-r :flex -74.3 :twist 0.5) (:head :flex -5.1) (:lower-arm-r :flex 15.7) (:root :u -0.037 :yaw -1.9) (:shin-l :flex 13.7) (:shin-r :flex 12) (:spine :flex -0.4) (:thigh-l :flex 7.2) (:thigh-r :flex 0.2) (:upper-arm-l :flex 5.6) (:upper-arm-r :flex 10.1 :side 16.6))
  (4 (:hand-r :flex -70.8 :twist 0.8) (:head :flex -5.8) (:lower-arm-r :flex 14.3) (:root :u -0.048 :yaw -3.1) (:shin-l :flex 14.8) (:shin-r :flex 14.5) (:spine :flex 1.8) (:thigh-l :flex 5.4) (:thigh-r :flex 2.8) (:upper-arm-l :flex 7.8) (:upper-arm-r :flex 6.5 :side 18.3))
  (5 (:hand-r :flex -66.5 :twist 1.1) (:head :flex -6.7) (:lower-arm-r :flex 12.6) (:root :u -0.06 :yaw -4.5) (:shin-l :flex 16) (:shin-r :flex 17.4) (:spine :flex 4.5) (:thigh-l :flex 3.3) (:thigh-r :flex 5.9) (:upper-arm-l :flex 10.5) (:upper-arm-r :flex 2.1 :side 20.3))
  (6 (:hand-r :flex -61.6 :twist 1.5) (:head :flex -7.7) (:lower-arm-r :flex 10.6) (:root :u -0.075 :yaw -6.1) (:shin-l :flex 17.5) (:shin-r :flex 20.9) (:spine :flex 7.7) (:thigh-l :flex 0.8) (:thigh-r :flex 9.5) (:upper-arm-l :flex 13.7) (:upper-arm-r :flex -3 :side 22.6))
  (7 (:hand-r :flex -56.1 :twist 2) (:head :flex -8.8) (:lower-arm-r :flex 8.4) (:root :u -0.092 :yaw -8) (:shin-l :flex 19.2) (:shin-r :flex 24.7) (:spine :flex 11.1) (:thigh-l :flex -2) (:thigh-r :flex 13.5) (:upper-arm-l :flex 17.1) (:upper-arm-r :flex -8.7 :side 25.2))
  (8 (:hand-r :flex -50 :twist 2.5) (:head :flex -10) (:lower-arm-r :flex 6) (:root :u -0.11 :yaw -10) (:shin-l :flex 21) (:shin-r :flex 29) (:spine :flex 15) (:thigh-l :flex -5) (:thigh-r :flex 18) (:upper-arm-l :flex 21) (:upper-arm-r :flex -15 :side 28))
  (9 (:hand-r :flex -49.8 :twist 2.8) (:head :flex -10.8) (:lower-arm-r :flex 6.5) (:root :u -0.121 :yaw -11.2) (:shin-l :flex 22.1) (:shin-r :flex 31.6) (:spine :flex 17.4) (:thigh-l :flex -6.9) (:thigh-r :flex 20.8) (:upper-arm-l :flex 23.4) (:upper-arm-r :flex -18.9 :side 28.2))
  (10 (:hand-r :flex -49.5 :twist 3.1) (:head :flex -11.5) (:lower-arm-r :flex 7) (:root :u -0.133 :yaw -12.5) (:shin-l :flex 23.2) (:shin-r :flex 34.2) (:spine :flex 19.8) (:thigh-l :flex -8.8) (:thigh-r :flex 23.5) (:upper-arm-l :flex 25.8) (:upper-arm-r :flex -22.8 :side 28.5))
  (11 (:hand-r :flex -49.2 :twist 3.4) (:head :flex -12.2) (:lower-arm-r :flex 7.5) (:root :u -0.144 :yaw -13.8) (:shin-l :flex 24.4) (:shin-r :flex 36.9) (:spine :flex 22.1) (:thigh-l :flex -10.6) (:thigh-r :flex 26.2) (:upper-arm-l :flex 28.1) (:upper-arm-r :flex -26.6 :side 28.8))
  (12 (:hand-r :flex -49 :twist 3.8) (:head :flex -13) (:lower-arm-r :flex 8) (:root :u -0.155 :yaw -15) (:shin-l :flex 25.5) (:shin-r :flex 39.5) (:spine :flex 24.5) (:thigh-l :flex -12.5) (:thigh-r :flex 29) (:upper-arm-l :flex 30.5) (:upper-arm-r :flex -30.5 :side 29))
  (13 (:hand-r :flex -48.8 :twist 4.1) (:head :flex -13.8) (:lower-arm-r :flex 8.5) (:root :u -0.166 :yaw -16.2) (:shin-l :flex 26.6) (:shin-r :flex 42.1) (:spine :flex 26.9) (:thigh-l :flex -14.4) (:thigh-r :flex 31.8) (:upper-arm-l :flex 32.9) (:upper-arm-r :flex -34.4 :side 29.2))
  (14 (:hand-r :flex -48.5 :twist 4.4) (:head :flex -14.5) (:lower-arm-r :flex 9) (:root :u -0.177 :yaw -17.5) (:shin-l :flex 27.8) (:shin-r :flex 44.8) (:spine :flex 29.2) (:thigh-l :flex -16.2) (:thigh-r :flex 34.5) (:upper-arm-l :flex 35.2) (:upper-arm-r :flex -38.2 :side 29.5))
  (15 (:hand-r :flex -48.2 :twist 4.7) (:head :flex -15.2) (:lower-arm-r :flex 9.5) (:root :u -0.189 :yaw -18.8) (:shin-l :flex 28.9) (:shin-r :flex 47.4) (:spine :flex 31.6) (:thigh-l :flex -18.1) (:thigh-r :flex 37.2) (:upper-arm-l :flex 37.6) (:upper-arm-r :flex -42.1 :side 29.8))
  (16 :ya-e-tenchi-coil)
  (17 (:root :yaw -21 :u -0.21) (:arm-r :flex -48))                                             ; held, trembling
  (18 (:root :yaw -20 :u -0.2) (:arm-r :flex -46.5))
  (19 (:root :yaw -21.5 :u -0.21) (:arm-r :flex -48.5))
  (20 (:root :yaw -21 :u -0.215) (:arm-r :flex -47))
  (21 :snap (:root :yaw -16 :f 0.12 :u -0.23) (:spine :flex 32) (:arm-r :flex -10 :side 34) (:hand-r :twist -20 :flex -78)   ; released
     (:thigh-r :flex 50) (:knee-r :flex 58) (:thigh-l :flex -26) (:knee-l :flex 20))
  (23 :snap (:root :yaw -8 :f 0.3 :u -0.24) (:spine :flex 26) (:arm-r :flex 40 :side 30) (:elbow-r :flex 4)   ; low right
     (:hand-r :twist -50 :flex -80) (:thigh-r :flex 60) (:knee-r :flex 66) (:thigh-l :flex -30) (:knee-l :flex 10))
  (:s :snap :ya-e-tenchi-hit)
  (:a (:root :yaw 35 :f 0.62 :u -0.26) (:spine :flex 10) (:chest :twist 40) (:arm-r :flex 150 :side -40)   ; high left
      (:hand-r :twist 40 :flex -90) (:arm-l :flex -60 :side 34))
  (40 (:root :yaw 30 :f 0.6 :u -0.27) (:chest :twist 34) (:arm-r :flex 144))                    ; held
  (:end :ya-e-stance))

;; W1 L SHONETSU JIGOKU: no swing. The arms open (the blade out low to his right, the empty sleeve flaring left), head
;; back, chest out, the feet sunk apart: the garb flares up over the startup (the tell), the pillars erupt at S
(defpose :ya-shonetsu-hit (:base :ya-e-stance)
  (:root :u -0.08) (:spine :flex -18) (:neck :flex -12) (:head :flex -16)
  (:arm-r :flex 20 :side 74) (:elbow-r :flex 10) (:hand-r :twist 10 :flex -110)
  (:arm-l :flex 14 :side 88) (:thighs :side 14) (:knees :flex 20))
;; Art K3 (DUEL_YAMA_CORE §15.2.2 / §18): at the move's frames (S16 A12, the clip had A 0), frame 0 is 西's stance (NS2 starts only from
;; it); drawn in f0-12, held to f15, the arms open on S; the second chest pulse on f26 (the second hit, L8's second flare); S+A
;; (:YA-SHONETSU-A, f28) is NS2b's first frame
(defpose :ya-shonetsu-a (:base :ya-shonetsu-hit)          ; the second pulse settling (S+A: NS2b starts here)
  (:root :u -0.07) (:spine :flex -20) (:neck :flex -13) (:head :flex -18) (:arm-r :side 80) (:arm-l :side 94))
(defstrike :ya-shonetsu (16 12 24 :base :ya-e-stance)
  (0 :ya-st-nishi)
  (6 (:root :u -0.1) (:spine :flex 6) (:neck :flex -2) (:head :flex 4) (:arm-r :flex 10 :side 24) (:hand-r :flex -42) (:arm-l :side 20)
     (:knees :flex 26))   ; in
  (12 (:root :u -0.12) (:spine :flex 10) (:head :flex 8) (:arm-r :side 30) (:arm-l :side 26) (:knees :flex 30))         ; drawn
  (14 (:root :u -0.13) (:spine :flex 11) (:arm-r :side 29))                                                              ; held
  (15 (:root :u -0.125) (:spine :flex 10.5) (:arm-r :side 30.5))
  (:s :snap :ya-shonetsu-hit)
  (22 (:root :u -0.09) (:arm-r :side 76) (:arm-l :side 90))
  (25 (:root :u -0.11) (:spine :flex -10) (:neck :flex -6) (:head :flex -8) (:arm-r :side 66) (:arm-l :side 78))         ; the breath in
  (26 :snap (:root :u -0.05) (:spine :flex -22) (:neck :flex -14) (:head :flex -20) (:arm-r :side 82) (:arm-l :side 96))   ; the pulse
  (:a :ya-shonetsu-a)
  (42 (:root :u -0.06) (:spine :flex -8) (:neck :flex -6) (:head :flex -8) (:arm-r :flex 16 :side 44) (:arm-l :flex 6 :side 36)
      (:thighs :side 12) (:knees :flex 16))
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

;; 西 (West), art K3 (DUEL_YAMA_CORE §15.2.2 / §18). NS2b, the second charge (S14): rooted since §39 (the user, 2026-11-22: 「為什麼西的 NS
;; 會位移」 -> NSa / NSb charge in place; until then two dragging steps carried by a 1.5 m slide). From SHONETSU's open arms he sinks into a
;; wide planted stance and gathers (f4-9), a held tremble (f12-13), then the chest rises and the arms throw open low on S as the garb grows
;; to its level-2 size; S+A (:YA-E-ADVANCE-A, f17) is NS2c's first frame. He takes a hit without a flinch (the armour f6-S): nothing reacts
(defpose :ya-e-advance-hit (:base :ya-st-nishi)
  (:root :u -0.12) (:spine :flex -16) (:neck :flex -12) (:head :flex -18)
  (:thigh-l :flex 6 :side 14) (:knee-l :flex 18) (:thigh-r :flex 6 :side 14) (:knee-r :flex 18)
  (:arm-r :flex 12 :side 62) (:arm-l :flex 12 :side 56))
(defpose :ya-e-advance-a (:base :ya-e-advance-hit)
  (:root :u -0.11) (:spine :flex -15) (:arm-r :side 60) (:arm-l :side 54))
(defstrike :ya-e-advance (14 3 20 :base :ya-e-stance)
  (0 :ya-shonetsu-a)
  (4 (:root :u -0.10) (:spine :flex -8) (:neck :flex -6) (:head :flex -8) (:thigh-l :flex 14 :side 14) (:knee-l :flex 26)   ; sinks,
     (:thigh-r :flex 14 :side 14) (:knee-r :flex 26) (:arm-r :side 48) (:arm-l :side 40))                                  ;  gathers
  (9 (:root :u -0.15) (:spine :flex -6) (:thigh-l :flex 22) (:knee-l :flex 36) (:thigh-r :flex 22) (:knee-r :flex 36)
     (:arm-r :side 42) (:arm-l :side 36))                                                                                    ; held low
  (12 (:root :u -0.155) (:spine :flex -6.5) (:arm-r :side 43))                                                              ; the
  (13 (:root :u -0.15) (:spine :flex -6) (:arm-r :side 42))                                                                 ;  tremble
  (:s :snap :ya-e-advance-hit)
  (:a :ya-e-advance-a)
  (26 (:root :u -0.09) (:spine :flex -12) (:head :flex -14) (:thigh-l :flex 6) (:knee-l :flex 16) (:thigh-r :flex 6) (:knee-r :flex 16)
      (:arm-r :flex 10 :side 54) (:arm-l :flex 10 :side 46))
  (:end :ya-e-stance))
;; NS2c the counter-cut (S12, ZANJITSU GOKUI): still f0-7 (taking it, the chin up), then a rising forehand from the low carry at his right
;; up across to his high left with one step (the move's slide); at S the blade crosses ahead, rising
(defpose :ya-e-gokui-hit (:base :ya-e-stance)
  (:root :yaw 8 :f 0.4 :u -0.14) (:pelvis :side -4) (:spine :flex 12) (:chest :twist 6) (:neck :flex 0) (:head :flex -6)
  (:arm-r :flex 100 :side 0) (:elbow-r :flex 4) (:hand-r :twist 20 :flex -70) (:arm-l :flex 10 :side 40)
  (:thigh-r :flex 52) (:knee-r :flex 56) (:thigh-l :flex -28) (:knee-l :flex 10))
(defstrike :ya-e-gokui-cut (12 3 24 :base :ya-e-stance)
  (0 :ya-e-advance-a)
  (4 (:root :u -0.12) (:spine :flex -14))                                                        ; still: taking it
  (7 (:root :u -0.125) (:spine :flex -15) (:head :flex -19))
  (9 :snap (:root :yaw -12 :u -0.16) (:pelvis :side 4) (:spine :flex 4) (:chest :twist -20) (:neck :flex 0) (:head :flex -6)   ; the
     (:arm-r :flex 20 :side 50) (:elbow-r :flex 10) (:hand-r :twist 40 :flex -60) (:arm-l :flex 10 :side 30)                    ;  low carry
     (:thigh-l :flex 4 :side 6) (:knee-l :flex 16) (:thigh-r :flex 10 :side 6) (:knee-r :flex 24))
  (11 :snap (:root :yaw -2 :f 0.25 :u -0.15) (:chest :twist -6) (:arm-r :flex 70 :side 25) (:hand-r :twist 30 :flex -64)   ; rising
      (:thigh-r :flex 40) (:knee-r :flex 44) (:thigh-l :flex -16) (:knee-l :flex 10))
  (:s :snap :ya-e-gokui-hit)
  (14 (:root :yaw 22 :f 0.42 :u -0.13) (:chest :twist 30) (:spine :flex 8) (:arm-r :flex 150 :side -40) (:elbow-r :flex 10)   ; high left
      (:hand-r :twist 40 :flex -80))
  (:a (:root :yaw 21) (:chest :twist 28))
  (30 (:root :yaw 8 :f 0.16 :u -0.08) (:pelvis :side 0) (:chest :twist 4) (:spine :flex 2) (:arm-r :flex 40 :side 30) (:elbow-r :flex 20)
      (:hand-r :twist 0 :flex -80) (:arm-l :flex 4 :side 20) (:thigh-r :flex 18) (:knee-r :flex 22) (:thigh-l :flex -6) (:knee-l :flex 10))
  (:end :ya-e-stance))
;; AS2a the grab (S12): one arm, so the blade goes into the plaza first. From J2's S+1 (:YA-E-Q2-THRU, where the AS lands) the blade comes
;; down and is planted point-down at his right (f4: :YA-E-PLANT-R, YAMA-PLANTED's spot, drawn there f4-25); the right hand, free, is drawn
;; back, held, and shoots to his collar on S (the hand at the move's 1.6 m); S+A (:YA-E-GRAB-A, f15: holding him) is AS2b's first frame;
;; unthrown, the hand goes back to the hilt by f26
(defpose :ya-e-plant-r (:base :ya-e-stance)               ; the hand on the planted hilt, the blade upright in the plaza at his right
  (:root :yaw -6 :u -0.1) (:spine :flex 11) (:chest :twist -12) (:head :flex 4)
  (:arm-r :flex 28.3 :side 28) (:elbow-r :flex 10) (:hand-r :twist 29.5 :flex -117.4))   ; (solved by FK: grip 0.74 m up at 0.5 right, 0.14 ahead)
(defpose :ya-e-grab-hit (:base :ya-e-stance)
  (:root :yaw 4 :f 0.88 :u -0.2) (:pelvis :side -4) (:spine :flex 12) (:chest :twist 6) (:head :flex -12)   ; (FK: the hand 1.33 m up,
  (:arm-r :flex 124 :side 2) (:elbow-r :flex 4) (:hand-r :twist 0 :flex 20) (:arm-l :flex -34 :side 26)      ;  1.6 m ahead)
  (:thigh-r :flex 70 :side 4) (:knee-r :flex 70) (:thigh-l :flex -46 :side 6) (:knee-l :flex 4))
(defpose :ya-e-grab-a (:base :ya-e-grab-hit)               ; the collar held (S+A: AS2b starts here)
  (:root :f 0.87 :u -0.19) (:hand-r :flex 32))
(defstrike :ya-e-grab (12 3 16 :base :ya-e-stance)
  (0 :ya-e-q2-thru)
  (2 (:root :yaw -4 :u -0.08) (:chest :twist -14) (:arm-r :flex 60 :side 32) (:elbow-r :flex 20) (:hand-r :twist 0 :flex -84))   ; down
  (4 :snap :ya-e-plant-r)                                                                         ; planted
  (6 (:root :yaw -14 :u -0.18) (:chest :twist -26) (:spine :flex 16) (:arm-r :flex -14 :side 22) (:elbow-r :flex 96)   ; let go, the
     (:hand-r :twist 0 :flex 30) (:thigh-r :flex 30) (:knee-r :flex 40))                                                ;  hand drawn back
  (9 (:root :yaw -16 :u -0.19) (:chest :twist -28) (:arm-r :flex -16))                           ; held
  (10 (:root :yaw -15 :u -0.2) (:chest :twist -29) (:arm-r :flex -15))
  (11 :snap (:root :yaw -2 :f 0.45 :u -0.2) (:chest :twist -4) (:spine :flex 22) (:arm-r :flex 80 :side 10) (:elbow-r :flex 30)   ; shot
      (:hand-r :flex 10) (:thigh-r :flex 50) (:knee-r :flex 54) (:thigh-l :flex -30) (:knee-l :flex 8))                           ;  out
  (:s :snap :ya-e-grab-hit)
  (:a :ya-e-grab-a)
  (20 (:root :yaw -2 :f 0.4 :u -0.16) (:spine :flex 18) (:arm-r :flex 50 :side 24) (:elbow-r :flex 30) (:hand-r :flex -40))   ; let go,
  (26 :ya-e-plant-r)                                                                              ;  back to the hilt
  (:end :ya-e-stance))
;; AS2b the throw (S12): the arm locked out holding him (planted blade f0-29), sinking as the garb builds, then the hand driven up and
;; opened (the flare L8 on S throws him); the hand back on the hilt by f30, the blade drawn out low into the stance
(defpose :ya-e-throw-hit (:base :ya-e-grab-a)
  (:root :yaw 2 :f 0.6 :u -0.04) (:spine :flex -10) (:chest :twist 0) (:head :flex -22)
  (:arm-r :flex 155 :side 10) (:elbow-r :flex 6) (:hand-r :twist 0 :flex 50)
  (:thigh-r :flex 40) (:knee-r :flex 30) (:thigh-l :flex -30) (:knee-l :flex 6))
(defstrike :ya-e-throw (12 3 24 :base :ya-e-stance)
  (0 :ya-e-grab-a)
  (4 (:root :u -0.19) (:spine :flex 20) (:head :flex -14))                                       ; holding, sinking
  (9 (:root :u -0.24) (:spine :flex 12) (:head :flex -18) (:arm-r :flex 102))                     ; the garb builds
  (10 (:root :u -0.245) (:spine :flex 11.5))                                                     ; held
  (11 :snap (:root :u -0.12) (:spine :flex 0) (:arm-r :flex 132) (:hand-r :flex 40))             ; driven up
  (:s :snap :ya-e-throw-hit)                                                                      ; opened: the flare
  (:a (:root :u -0.03) (:arm-r :flex 158) (:hand-r :flex 56))
  (22 (:root :yaw 0 :f 0.3 :u -0.1) (:spine :flex 8) (:head :flex -8) (:arm-r :flex 60 :side 24) (:elbow-r :flex 30) (:hand-r :flex -30))
  (30 :ya-e-plant-r)                                                                              ; back on the hilt
  (34 :ya-st-nishi)                                                                               ; drawn out low
  (:end :ya-e-stance))
(defclip :ya-tenchi (1.3 :base :ya-stance)            ; North: Tenchi Kaijin, one slash (the cinematic's; in play :ya-e-tenchi)
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
;; the swarm (art K1, L2): prone, the hips low, the arms reaching forward in turn and dragging the body (a 0.6 s loop; YA-DEAD samples it on
;; twos). A look clip for the dead, not a strike.
(defpose :sk-prone ()
  (:root :pitch 78 :u -0.78) (:spine :flex -10) (:neck :flex -30) (:head :flex -40)
  (:arms :flex 150 :side 20) (:elbows :flex 30) (:thighs :flex -6 :side 10) (:knees :flex 20))
(defclip :sk-crawl (0.6 :loop t :base :sk-prone)
  (0 (:arm-r :flex 172 :side 14) (:elbow-r :flex 6) (:arm-l :flex 110 :side 30) (:elbow-l :flex 70) (:chest :twist 10))
  (0.3 (:arm-r :flex 110 :side 30) (:elbow-r :flex 70) (:arm-l :flex 172 :side 14) (:elbow-l :flex 6) (:chest :twist -10))
  (0.6 (:arm-r :flex 172 :side 14) (:elbow-r :flex 6) (:arm-l :flex 110 :side 30) (:elbow-l :flex 70) (:chest :twist 10)))

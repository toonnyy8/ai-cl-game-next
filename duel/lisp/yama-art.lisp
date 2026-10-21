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
;; glowing red-orange (the anime's flare, #FF5A3C; emissive parts, one mesh each: kept to 12), 4 healed (ink-brown).
(defparameter *ya-bare-parts*
  (flet ((scar (x y z len a) `(:glow 2.4 (:box ,len 0.007 0.006 :at (,x ,y ,z) :rot (0 0 ,a) :c :scar-glow)))   ; 12 glow
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
              ,(scar 0.08 0.15 0.135 0.14 30) ,(scar -0.06 0.09 0.135 0.16 -20) ,(old 0.03 0.04 0.135 0.12 -60)
              ,(old 0.17 0.11 0.06 0.1 75))
      (:chest (:bevel 0.48 0.3 0.27 0.06 :at (0 0.11 -0.005) :c :skin)
              (:box 0.16 0.006 0.006 :at (0.1 0.07 0.148) :rot (0 0 10) :c :lid)                    ; pectorals
              (:box 0.16 0.006 0.006 :at (-0.1 0.07 0.148) :rot (0 0 -10) :c :lid)
              (:box 0.13 0.006 0.006 :at (0.1 0.235 0.125) :rot (0 0 -10) :c :lid)                  ; collarbones
              (:box 0.13 0.006 0.006 :at (-0.1 0.235 0.125) :rot (0 0 10) :c :lid)
              ,(scar 0.1 0.17 0.15 0.2 -35) ,(scar -0.12 0.13 0.15 0.18 40) ,(scar 0.04 0.1 0.152 0.22 -15)
              ,(scar -0.03 0.21 0.145 0.12 70) ,(scar 0.15 0.04 0.13 0.12 25) ,(scar -0.15 0.03 0.13 0.13 -50)
              ,(scar 0.08 0.12 -0.145 0.22 30) ,(old -0.08 0.05 -0.145 0.2 -25))                     ; (two on the back)
      (:shoulder-r (:bevel 0.12 0.07 0.14 0.03 :at (0.02 -0.02 0) :rot (0 0 -24) :c :skin))
      (:shoulder-l (:bevel 0.12 0.07 0.14 0.03 :at (-0.02 -0.02 0) :rot (0 0 24) :c :skin))
      (:upper-arm-r (:box 0.105 0.31 0.115 :at (0 -0.15 0) :c :skin) ,(scar 0.0 -0.1 0.06 0.1 35) ,(scar 0.0 -0.2 0.06 0.09 -40))
      (:upper-arm-l (:box 0.1 0.2 0.11 :at (0 -0.1 0) :c :skin) (:sphere 0.055 :at (0 -0.2 0) :seg 8 :c :skin)   ; the stump
                    ,(old 0.0 -0.08 0.058 0.09 -30))
      (:lower-arm-r (:box 0.095 0.24 0.1 :at (0 -0.12 0) :c :skin) (:box 0.006 0.17 0.006 :at (0.02 -0.12 0.052) :c :scar)
                    ,(scar 0.0 -0.06 0.053 0.08 50)))))
(body-variant :yamamoto-bare :yamamoto :palette '((:scar-glow #xFF5A3C)) :parts *ya-bare-parts*)

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
(defparameter *ya-hem-k* 60.0 "The hem spring's stiffness (1/s^2, ~1.2 Hz). New 2026-10-13 (DUEL_YAMA_TYBW §3.1, the lead's look).")
(defparameter *ya-hem-c* 4.6 "Its damping (1/s): ~0.3 of critical, so the hem overshoots once when he stops.")
(defparameter *ya-hem-drag* 0.03 "The hem's trail per m/s of the obi's travel (rad): a run (~8 m/s) ~14 deg.")
(defparameter *ya-hem-turn* 0.05 "Its yaw lag per rad/s of the pelvis's turn (rad).")
(defparameter *ya-hem-max* 0.42 "The swing's cap (rad, ~24 deg) back / forward and sideways; the yaw lag's is 0.3.")
(declaim (type f32vec *ya-hem* *ya-hem-m* *ya-tip*))
(defvar *ya-hem* (make-f32 32)
  "The hem spring per side (16 floats each): [0..2] the obi's world point at the last step, [3] the pelvis heading then,
[4 5] the back swing (rad) and its rate, [6 7] the side swing and rate, [8 9] the yaw lag and rate, [10] 1 once primed,
[11..13] the obi's point this frame, [14] the heading this frame (YAMA-POSE).")
(defvar *ya-hem-m* (make-f32 16) "YAMA-POSE's scratch matrix: the swing about the obi.")
(defvar *ya-tip* (make-f32 3) "YAMA-DRAW's blade tip.")

(defun-fast %ya-hem-pose (jm st o on)
  "Record the obi's world point and the pelvis heading in ST (the side's offset O); when ON is 1, swing the pelvis matrix
(JM 0..15) about the obi (its local (0 0.06 0)) by ST's angles plus a slow breath."
  (declare (type f32vec jm st) (fixnum o on))
  (setf (aref st (+ o 11)) (+ (* 0.06f0 (aref jm 4)) (aref jm 12))
        (aref st (+ o 12)) (+ (* 0.06f0 (aref jm 5)) (aref jm 13))
        (aref st (+ o 13)) (+ (* 0.06f0 (aref jm 6)) (aref jm 14))
        (aref st (+ o 14)) (f-atan2 (aref jm 8) (aref jm 10)))
  (when (= on 1)
    (let* ((c (fx-clock)) (r *ya-hem-m*) (yl (aref st (+ o 8)))
           (back (+ (aref st (+ o 4)) (* 0.02f0 (f-sin (* 1.3f0 c)))))
           (side (+ (aref st (+ o 6)) (* 0.012f0 (f-sin (* 0.9f0 c))))))
      (declare (single-float c yl back side) (type f32vec r))
      ;; Ry(yaw lag) Rx(-back: the hem's foot goes behind him, +z) Rz(side: its foot to his right), about the obi
      (%euler! r 0 0f0 0f0 0f0 yl (- back) side 1f0)
      (setf (aref r 12) (* -0.06f0 (aref r 4)) (aref r 13) (- 0.06f0 (* 0.06f0 (aref r 5))) (aref r 14) (* -0.06f0 (aref r 6)))
      (m4-mul! jm jm r)))
  nil)

(defmacro %ya-spring (st i tgt dt)
  "Step the angle ST[I] (its rate ST[I+1]) toward TGT over DT s (semi-implicit Euler), capped at *YA-HEM-MAX*."
  `(let* ((%a (aref ,st ,i)) (%r (+ (aref ,st (+ ,i 1))
                                   (* ,dt (- (* (the single-float (f32 *ya-hem-k*)) (- ,tgt %a))
                                             (* (the single-float (f32 *ya-hem-c*)) (aref ,st (+ ,i 1))))))))
     (declare (single-float %a %r))
     (setf (aref ,st (+ ,i 1)) %r
           (aref ,st ,i) (f-clamp (+ %a (* ,dt %r)) (- (the single-float (f32 *ya-hem-max*))) (the single-float (f32 *ya-hem-max*))))))

(defun-fast %ya-hem-step (st o dt)
  "Step side O's hem spring in ST by DT effect seconds (substeps of <= 1/60 s): targets from the obi's travel (the hem
trails it) and the pelvis's turn (it lags); a jump over 1.5 m (a reset, a cinematic's placing) re-primes it."
  (declare (type f32vec st) (fixnum o) (single-float dt))
  (when (> dt 0f0)
    (let* ((x (aref st (+ o 11))) (y (aref st (+ o 12))) (z (aref st (+ o 13))) (h (aref st (+ o 14)))
           (dx (- x (aref st o))) (dy (- y (aref st (+ o 1)))) (dz (- z (aref st (+ o 2))))
           (dh (- h (aref st (+ o 3)))))
      (declare (single-float x y z h dx dy dz dh))
      (when (> dh 3.1415927f0) (decf dh 6.2831855f0))
      (when (< dh -3.1415927f0) (incf dh 6.2831855f0))
      (if (or (< (aref st (+ o 10)) 0.5f0) (> (f-hypot dx dy dz) 1.5f0))
          (progn (setf (aref st (+ o 10)) 1f0)
                 (loop for i fixnum from (+ o 4) below (+ o 10) do (setf (aref st i) 0f0)))
          (let* ((bx (f-sin h)) (bz (f-cos h))           ; the pelvis's back (its local +z) on the ground
                 (vf (/ (- (+ (* dx bx) (* dz bz))) dt)) (vr (/ (- (* dx bz) (* dz bx)) dt)) (w (/ dh dt))
                 (drag (the single-float (f32 *ya-hem-drag*))) (mx (the single-float (f32 *ya-hem-max*)))
                 (tb (f-clamp (* drag vf) (- mx) mx)) (ts (f-clamp (* (- drag) vr) (- mx) mx))
                 (ty (f-clamp (* (- (the single-float (f32 *ya-hem-turn*))) w) -0.3f0 0.3f0))
                 (n (max 1 (min 4 (f->i (+ 0.999f0 (* 60f0 dt)))))) (sdt (/ dt (i->f n))))
            (declare (single-float bx bz vf vr w drag mx tb ts ty sdt) (fixnum n))
            (dotimes (k n)
              (%ya-spring st (+ o 4) tb sdt) (%ya-spring st (+ o 6) ts sdt) (%ya-spring st (+ o 8) ty sdt))))
      (setf (aref st o) x (aref st (+ o 1)) y (aref st (+ o 2)) z (aref st (+ o 3)) h)))
  nil)

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
                  (if (member (kit-form (fighter-kit f)) '(:bankai-east :bankai-west)) 0 1))))

(defun yama-draw (e rdt)
  "KIT-HOOK :draw: step the hem spring; Bankai East's smoke thread from the drawn blade's tip."
  (let* ((f (fighter e)) (m (model e)) (mv (current-move f)))
    (%ya-hem-step *ya-hem* (* 16 (fighter-side f)) (f32 rdt))
    (when (and (eq (kit-form (fighter-kit f)) :bankai-east) (model-weapon m) (> (model-alpha m) 0.5)
               (not (and mv (mv-planted mv) (eq (fighter-phase f) :main))))
      (let ((tp *ya-tip*))
        (body-weapon-tip (model-body m) (model-weapon m) (model-joints m) tp)
        (%ya-smoke (aref tp 0) (aref tp 1) (aref tp 2))))))

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
;; S1 J1 HISEN, the unmovable pivot: the feet stay; a small cock of the wrist high right, one snap down-left across him; the
;; head comes up on S (the eyes open)
(defpose :ya-q1-hit (:base :ya-stance)
  (:chest :twist -2) (:spine :flex 16) (:root :u -0.06) (:neck :flex -20) (:head :flex -26)
  (:arm-r :flex 29 :side 120 :twist -28) (:elbow-r :flex 62) (:hand-r :twist 18 :flex -70))
(defstrike :ya-q1 (9 3 12 :base :ya-stance)
  (0)
  (4 (:chest :twist -18) (:spine :flex 10) (:neck :flex -18) (:head :flex -22)
     (:arm-r :flex 171 :side 69 :twist -20) (:elbow-r :flex 127) (:hand-r :twist -58 :flex -40))
  (7 (:chest :twist -21) (:arm-r :flex 175 :side 72) (:head :flex -24))
  (8 :snap (:chest :twist -12) (:spine :flex 12) (:neck :flex -19) (:head :flex -24)             ; passing high right, ahead
     (:arm-r :flex 159 :side 100 :twist -70) (:elbow-r :flex 142) (:hand-r :twist -60 :flex -75))
  (:s :snap :ya-q1-hit)
  (10 (:chest :twist 10) (:spine :flex 18) (:root :u -0.07) (:arm-r :flex 81 :side 36 :twist 41) (:elbow-r :flex 18)
      (:hand-r :twist 5 :flex -79))
  (:a (:chest :twist 9) (:spine :flex 17) (:arm-r :flex 79 :side 34))
  (18 (:chest :twist 0) (:spine :flex 14) (:root :u -0.05) (:arm-r :flex 50 :side 10 :twist 15) (:elbow-r :flex 25)
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
;; S3 J3 TSUKABI 柄火 (the user, 2026-10-14: 「右手刀柄回擊」, DUEL_YAMA_TYBW §8): no left forearm in TYBW, so the right hand
;; drives the hilt: the grip drawn back past the right shoulder, the blade laid back along the forearm (the point behind and
;; low), then the hips and chest turn in and the pommel is punched up into the face (S, the burning pommel: DRAW-FIGHTER),
;; the empty left sleeve thrown back
(defpose :ya-tsuka-wind (:base :ya-stance)
  (:root :yaw -12 :u -0.08) (:pelvis :twist -10 :side 4) (:chest :twist -28) (:spine :flex 12 :side 4)
  (:head :flex -14 :twist 14)
  (:arm-r :flex -20 :side 25) (:elbow-r :flex 95) (:hand-r :flex -150)
  (:arm-l :flex 35 :side 15) (:elbow-l :flex 5)
  (:thigh-r :flex 18) (:knee-r :flex 24) (:thigh-l :flex 6) (:knee-l :flex 14))
(defpose :ya-tsuka-hit (:base :ya-stance)
  (:root :f 0.55 :u -0.06 :yaw 4) (:pelvis :twist 10 :side -4) (:chest :twist 20) (:spine :flex 10)
  (:head :flex -18 :twist -6)
  (:arm-r :flex 100 :side -5) (:elbow-r :flex 20) (:hand-r :flex -150)
  (:arm-l :flex -25 :side 30) (:elbow-l :flex 10)
  (:thigh-l :flex 38 :side 6) (:knee-l :flex 36) (:thigh-r :flex -22 :side 8) (:knee-r :flex 16))
(defstrike :ya-tsuka (9 3 18 :base :ya-stance)
  (0)
  (4 :ya-tsuka-wind)
  (7 :ya-tsuka-wind (:root :yaw -16 :u -0.1) (:chest :twist -34) (:elbow-r :flex 105))   ; wound up, held
  (:s :snap :ya-tsuka-hit)
  (:a :ya-tsuka-hit (:root :f 0.54) (:arm-r :flex 104))
  (21 (:root :yaw 2 :f 0.3 :u -0.05) (:pelvis :twist 4) (:chest :twist 8) (:spine :flex 10)
      (:arm-r :flex 40 :side 10) (:elbow-r :flex 50) (:hand-r :flex -108)
      (:arm-l :flex -5 :side 18) (:thigh-l :flex 22) (:knee-l :flex 24))
  (:end :ya-stance))
;; S4 K1 HOMURA-NAGI, the flame wave: the whole body turns away right (root yaw -42), steps in on the left foot and sweeps the
;; blade at the waist right to left through the front (S), the turn carried on to +45 (the fire sheet to the volume's edge)
(defpose :ya-f1-wind (:base :ya-stance)
  (:root :yaw -35 :u -0.08) (:pelvis :side 4) (:chest :twist -35) (:spine :flex 12 :side -6) (:head :twist 20)
  (:arm-r :flex -16 :side 17 :twist 9) (:elbow-r :flex 100) (:hand-r :twist -70 :flex -104))
(defpose :ya-f1-hit (:base :ya-stance)
  (:root :yaw 5 :f 0.38 :u -0.14) (:pelvis :side -4) (:chest :twist 10) (:spine :flex 18)
  (:arm-r :flex 74 :side -6 :twist -20) (:elbow-r :flex 55) (:hand-r :twist 5 :flex -93)
  (:thigh-l :flex 50) (:knee-l :flex 45) (:thigh-r :flex -25) (:knee-r :flex 20))
(defstrike :ya-f1 (18 4 20 :base :ya-stance)
  (0)
  (7 :ya-f1-wind)
  (13 :ya-f1-wind (:root :yaw -42 :u -0.12) (:chest :twist -40) (:thigh-l :flex 34) (:knee-l :flex 50))   ; the step lifts
  (16 (:root :yaw -20 :f 0.2 :u -0.12) (:pelvis :side 0) (:chest :twist -25) (:spine :flex 14) (:head :twist 8)
      (:arm-r :flex 35 :side 43 :twist 5) (:elbow-r :flex 28) (:hand-r :twist -46 :flex -96))
  (:s :snap :ya-f1-hit)
  (20 (:root :yaw 35 :f 0.4 :u -0.13) (:chest :twist 30) (:spine :flex 16) (:head :twist -10)
      (:arm-r :flex 38 :side 3 :twist -30) (:elbow-r :flex 78) (:hand-r :twist 16 :flex -82))
  (:a (:root :yaw 45 :f 0.4 :u -0.12) (:chest :twist 35) (:spine :flex 14) (:head :twist -14)
      (:arm-r :flex 48 :side -27 :twist -49) (:elbow-r :flex 82) (:hand-r :twist 51 :flex -100))
  (32 (:root :yaw 18 :f 0.18 :u -0.07) (:pelvis :side -1) (:chest :twist 12) (:spine :flex 12) (:head :twist -4)
      (:arm-r :flex 40 :side 0 :twist -15) (:elbow-r :flex 45) (:hand-r :twist 10 :flex -85)
      (:thigh-l :flex 30) (:knee-l :flex 32) (:thigh-r :flex -14) (:knee-r :flex 18))
  (:end :ya-stance))
;; S5 K2 SHOEN: the point dragged along the plaza from behind him to the front in a deep crouch (f6-f18: the link enters at
;; f8), then raised straight up through the front as he rises onto his toes: S crossing ahead at 45 degrees, overhead after
(defpose :ya-f2-low (:base :ya-stance)
  (:root :yaw -8 :u -0.22) (:knees :flex 55) (:thighs :flex 40) (:spine :flex 30) (:chest :twist -5)
  (:arm-r :flex 45 :side 10) (:elbow-r :flex 41) (:hand-r :twist 0 :flex -71))
(defpose :ya-f2-hit (:base :ya-stance)
  (:root :u 0.05) (:knees :flex 5) (:thighs :flex 4) (:spine :flex -5) (:head :flex -30)
  (:arm-r :flex 59 :side -1 :twist 13) (:elbow-r :flex 23) (:hand-r :twist -12 :flex -29))
(defstrike :ya-f2 (22 4 24 :base :ya-stance)
  (0)
  (6 (:root :yaw -20 :u -0.14) (:knees :flex 40) (:spine :flex 25) (:chest :twist -15)
     (:arm-r :flex 29 :side -17 :twist -70) (:elbow-r :flex 12) (:hand-r :twist -34 :flex -51))
  (10 (:root :yaw -16 :u -0.2) (:knees :flex 52) (:thighs :flex 30) (:spine :flex 27) (:chest :twist -13))
  (14 :ya-f2-low (:root :yaw -12) (:chest :twist -10) (:spine :flex 28)
      (:arm-r :flex -2 :side 21 :twist 3) (:elbow-r :flex 48) (:hand-r :twist -1 :flex -42))
  (18 :ya-f2-low)
  (20 :ya-f2-low (:root :yaw -4 :u -0.12) (:knees :flex 35) (:spine :flex 15) (:arm-r :flex 52) (:hand-r :flex -50))
  (:s :snap :ya-f2-hit)
  (24 (:root :u 0.08) (:spine :flex -12) (:head :flex -34)
      (:arm-r :flex 136 :side -10 :twist -15) (:elbow-r :flex 12) (:hand-r :twist 20 :flex -60))
  (:a (:arm-r :flex 138) (:root :u 0.07))
  (38 (:root :u -0.02) (:spine :flex 4) (:knees :flex 14) (:head :flex -22)
      (:arm-r :flex 80 :side 0 :twist 0) (:elbow-r :flex 30) (:hand-r :twist 5 :flex -60))
  (:end :ya-stance))
;; S6 K3 ENBAKU, the hammer (canon ch. 506, "a spinning vertical slash"): the blade cocked over the shoulder, one full turn
;; to his right (root yaw -360, a key every 90 degrees, rising), then the one vertical drop to the plaza ahead on S; the
;; recovery stays at -360 (= 0) and ends in the stance
(defpose :ya-f3-cock (:base :ya-stance)
  (:root :u -0.08) (:chest :twist -15) (:spine :flex 10)
  (:arm-r :flex 114 :side 44 :twist -32) (:elbow-r :flex 116) (:hand-r :twist -21 :flex -57))
(defpose :ya-f3-hit (:base :ya-stance)
  (:root :yaw -360 :u -0.2 :f 0.3) (:pelvis :side -5) (:spine :flex 40) (:knees :flex 50) (:thigh-l :flex 50) (:head :flex -32)
  (:arm-r :flex 63 :side -11 :twist 6) (:elbow-r :flex 20) (:hand-r :twist 0 :flex -55))
(defstrike :ya-f3 (22 5 34 :base :ya-stance)
  (0)
  (5 :ya-f3-cock)
  (8 :ya-f3-cock (:root :yaw -15) (:pelvis :side 4))
  (11 :ya-f3-cock (:root :yaw -105 :u -0.06) (:pelvis :side 6))
  (14 :ya-f3-cock (:root :yaw -195 :u -0.03) (:pelvis :side 4) (:spine :flex 4))
  (17 :ya-f3-cock (:root :yaw -285 :u 0.01) (:pelvis :side 2) (:spine :flex -2) (:arm-r :flex 140) (:elbow-r :flex 80))
  (20 (:root :yaw -350 :u 0.05) (:pelvis :side 0) (:chest :twist 0) (:spine :flex -10) (:head :flex -30)
      (:arm-r :flex 135 :side 6 :twist 13) (:elbow-r :flex 28) (:hand-r :twist -19 :flex -35))
  (:s :snap :ya-f3-hit)
  (24 (:root :u -0.23) (:spine :flex 44) (:arm-r :flex 58))
  (:a (:root :u -0.22) (:spine :flex 42) (:arm-r :flex 60))
  (44 (:root :yaw -360 :u -0.1 :f 0.12) (:pelvis :side -2) (:spine :flex 24) (:knees :flex 32) (:thigh-l :flex 30)
      (:head :flex -22) (:arm-r :flex 40 :side 0 :twist 0) (:elbow-r :flex 30) (:hand-r :twist 0 :flex -75))
  (:end :ya-stance (:root :yaw -360)))
;; S7 L RYUJIN JAKKA, the halo (canon 339Taimatsu2's arch, RoS Enro no Hitonade): three beats of its own. Cut 1 (f16) the
;; blade drawn round over his head in a semicircle, right -> overhead -> left, crossing above the front; cut 2 (f28) a
;; backhand down from high left to low right; f40 the point driven down into the plaza: the wave leaves (YAMA-FIRE-WAVE)
;; (keys solved in a chain, each from the last, so the blade travels the arc it names between them)
(defpose :ya-sig-hit1 (:base :ya-stance)
  (:chest :twist 15) (:spine :flex 6) (:head :flex -28)
  (:arm-r :flex 50 :side 123 :twist -46) (:elbow-r :flex 72) (:hand-r :twist -49 :flex -110))
(defpose :ya-sig-hit2 (:base :ya-stance)
  (:root :yaw -6) (:chest :twist -15) (:spine :flex 14)
  (:arm-r :flex 63 :side 43 :twist 10) (:elbow-r :flex 62) (:hand-r :twist -14 :flex -109))
(defpose :ya-sig-hit3 (:base :ya-stance)
  (:root :u -0.28 :f 0.25) (:spine :flex 38) (:knees :flex 58) (:thigh-l :flex 58) (:head :flex -30)
  (:arm-r :flex 135 :side -16 :twist 92) (:elbow-r :flex 63) (:hand-r :twist 80 :flex 70))
(defstrike :ya-sig (16 24 26 :base :ya-stance)
  (0)
  (6 (:root :yaw -12 :u -0.04) (:chest :twist -25) (:spine :flex 10 :side -5)                  ; out to his right
     (:arm-r :flex 58 :side 54 :twist -6) (:elbow-r :flex 1) (:hand-r :twist -68 :flex -109))
  (9 (:root :yaw -8 :u -0.01) (:chest :twist -18) (:spine :flex 7 :side -3)                     ; rising
     (:arm-r :flex 30 :side 83 :twist -13) (:elbow-r :flex 12) (:hand-r :twist -84 :flex -110))
  (12 (:root :yaw -2 :u 0.02) (:chest :twist -5) (:spine :flex 4 :side 0) (:head :flex -28)     ; over his head
      (:arm-r :flex 45 :side 103 :twist -21) (:elbow-r :flex 58) (:hand-r :twist -92 :flex -110))
  (16 :snap :ya-sig-hit1)                                                                         ; cut 1, across the top
  (19 (:root :yaw 8) (:chest :twist 25) (:spine :flex 8 :side 4)                                 ; on round to his left
      (:arm-r :flex 93 :side 99 :twist -33) (:elbow-r :flex 88) (:hand-r :twist -28 :flex -110))
  (23 (:root :yaw 12) (:chest :twist 30) (:spine :flex 10 :side 5)                                ; cocked high left
      (:arm-r :flex 122 :side 102 :twist -30) (:elbow-r :flex 103) (:hand-r :twist -19 :flex -107))
  (26 (:root :yaw 14) (:chest :twist 33) (:arm-r :flex 126) (:elbow-r :flex 106))
  (28 :snap :ya-sig-hit2)                                                                         ; cut 2, the backhand down
  (30 (:root :yaw -14) (:chest :twist -28) (:spine :flex 16)                                      ; to low right
      (:arm-r :flex 47 :side 11 :twist 20) (:elbow-r :flex 51) (:hand-r :twist -12 :flex -110))
  (32 (:root :yaw -9 :u 0.0) (:chest :twist -16) (:spine :flex 10) (:head :flex -24)            ; the point turned down
      (:arm-r :flex 136 :side -4 :twist 63) (:elbow-r :flex 76) (:hand-r :twist 62 :flex 70))
  (34 (:root :yaw -4 :u 0.02) (:chest :twist -5) (:spine :flex 4) (:head :flex -26)              ; raised, the point down
      (:arm-r :flex 171 :side -24 :twist 83) (:elbow-r :flex 54) (:hand-r :twist 42 :flex 68))
  (37 (:root :yaw 0 :u 0.05) (:chest :twist 0) (:spine :flex 0)                                   ; up on his toes
      (:arm-r :flex 177 :side -16 :twist 92) (:elbow-r :flex 34) (:hand-r :twist 40 :flex 70))
  (39 :snap (:root :u -0.08 :f 0.12) (:spine :flex 18) (:knees :flex 30) (:thigh-l :flex 30) (:head :flex -28)
      (:arm-r :flex 135 :side -16 :twist 92) (:elbow-r :flex 63) (:hand-r :twist 80 :flex 70))
  (40 :snap :ya-sig-hit3)                                                                         ; driven into the plaza
  (42 (:root :u -0.3 :f 0.26) (:spine :flex 40))
  (46 (:root :u -0.28 :f 0.25) (:spine :flex 39))
  (56 (:root :u -0.1 :f 0.1) (:spine :flex 22) (:knees :flex 30) (:thigh-l :flex 30) (:head :flex -20)
      (:arm-r :flex 25 :side -10 :twist 10) (:elbow-r :flex 25) (:hand-r :twist -5 :flex -75))
  (:end :ya-stance))
;; S8 SHIRANUI: the charge draws the blade back level at his ribs (the tornado spins at the point: VFX-CHARGE), the throw a
;; level thrust with the arm locked (on S, the move's f2, the fireball leaves)
(defpose :ya-shiranui-coil (:base :ya-stance)
  (:root :yaw -25 :u -0.14) (:knees :flex 40) (:chest :twist -25) (:spine :flex 14) (:head :twist 25 :flex -20)
  (:arm-r :flex -37 :side 51 :twist 14) (:elbow-r :flex 133) (:hand-r :twist 0 :flex -44))
(defclip :ya-shiranui (0.5 :loop t :base :ya-shiranui-coil)
  (0) (0.25 (:root :yaw -28 :u -0.16) (:chest :twist -28) (:knees :flex 44)))
(defpose :ya-throw-hit (:base :ya-stance)
  (:root :yaw 10 :f 0.3 :u -0.1) (:chest :twist 15) (:spine :flex 12) (:head :flex -18)
  (:thigh-l :flex 50) (:knee-l :flex 40) (:thigh-r :flex -25)
  (:arm-r :flex 121 :side -50 :twist 18) (:elbow-r :flex 14) (:hand-r :twist -7 :flex -92))
(defstrike :ya-shiranui-throw (2 1 20 :base :ya-stance)
  (0 :ya-shiranui-coil)
  (:s :snap :ya-throw-hit)
  (:a (:root :f 0.32))
  (13 (:root :yaw 4 :f 0.14 :u -0.07) (:chest :twist 4) (:spine :flex 12) (:thigh-l :flex 30) (:knee-l :flex 30)
      (:thigh-r :flex -14) (:arm-r :flex 60 :side -10 :twist 5) (:elbow-r :flex 25) (:hand-r :twist 0 :flex -80))
  (:end :ya-stance))
;; S9 TAIMATSU: the eye-open tell (the head up, f3), one full turn to his left low (a key every 90 degrees), the blade
;; trailing low on his right, rising into the fan of fire across the front on S, held
(defpose :ya-taimatsu-low (:base :ya-stance)
  (:root :u -0.12) (:knees :flex 35) (:spine :flex 18) (:chest :twist -15) (:head :flex -24)
  (:arm-r :flex 42 :side -14 :twist -101) (:elbow-r :flex 16) (:hand-r :twist -28 :flex -31))
(defpose :ya-taimatsu-hit (:base :ya-stance)
  (:root :yaw 360 :u 0.02) (:chest :twist 10) (:spine :flex 4) (:head :flex -28)
  (:arm-r :flex 73 :side -10) (:elbow-r :flex 5) (:hand-r :twist 0 :flex -29))
(defstrike :ya-taimatsu (16 8 24 :base :ya-stance)
  (0)
  (3 (:root :u -0.02) (:spine :flex 6) (:neck :flex -22) (:head :flex -30))            ; the tell: he straightens, eyes open
  (6 :ya-taimatsu-low)
  (8 :ya-taimatsu-low (:root :yaw 90) (:pelvis :side -5))
  (11 :ya-taimatsu-low (:root :yaw 180) (:pelvis :side -6))
  (14 :ya-taimatsu-low (:root :yaw 270 :u -0.08) (:pelvis :side -4) (:arm-r :flex 50))
  (:s :snap :ya-taimatsu-hit)
  (19 (:root :u 0.03) (:chest :twist 25) (:spine :flex 0) (:head :flex -30)
      (:arm-r :flex 95 :side -7 :twist 13) (:elbow-r :flex 20) (:hand-r :twist 19 :flex -56))
  (:a (:chest :twist 27) (:arm-r :flex 97))
  (36 (:root :u -0.02) (:chest :twist 5) (:spine :flex 8) (:head :flex -20)
      (:arm-r :flex 50 :side -5 :twist 5) (:elbow-r :flex 25) (:hand-r :twist 5 :flex -65))
  (:end :ya-stance (:root :yaw 360)))
;; H1 NADEGIRI (Hellfire; canon ch. 338, HitotsumeNadegiri.gif): the tell (still, the eyes open), the blade drawn to his left
;; hip, then an almost unseen draw-cut left to right at the neck crossing ahead on S (two drawings), the body carried on
;; round until his back is turned (yaw -185), the blade lowered slowly from behind; he turns back to the stance (-360)
(defpose :ya-nadegiri-draw (:base :ya-stance)
  (:root :yaw 25 :u -0.12) (:chest :twist 25) (:knees :flex 35) (:spine :flex 18) (:head :flex -28)
  (:arm-r :flex 20 :side -1 :twist 52) (:elbow-r :flex 52) (:hand-r :twist 33 :flex -82))
(defpose :ya-nadegiri-hit (:base :ya-stance)
  (:root :yaw 5 :f 0.2 :u -0.1) (:chest :twist -5) (:knees :flex 30) (:spine :flex 12) (:head :flex -28)
  (:arm-r :flex 128 :side -21 :twist -9) (:elbow-r :flex 0) (:hand-r :twist 2 :flex -97))
(defstrike :ya-nadegiri (20 4 30 :base :ya-stance)
  (0)
  (4 (:spine :flex 8) (:neck :flex -22) (:head :flex -30))                               ; the tell: the eyes open
  (10 :ya-nadegiri-draw)
  (17 :ya-nadegiri-draw (:root :u -0.15) (:knees :flex 40))
  (19 (:root :yaw 15) (:chest :twist 15) (:spine :flex 16)
      (:arm-r :flex 95 :side -27 :twist 23) (:elbow-r :flex 49) (:hand-r :twist 31 :flex -109))
  (:s :snap :ya-nadegiri-hit)
  (21 (:root :yaw -25) (:chest :twist -30) (:spine :flex 10)
      (:arm-r :flex 135 :side -22 :twist -13) (:elbow-r :flex 0) (:hand-r :twist -23 :flex -109))
  (:a (:root :yaw -60) (:chest :twist -32))
  (32 (:root :yaw -150 :f 0.15 :u -0.06) (:chest :twist -15) (:spine :flex 10) (:knees :flex 22)
      (:arm-r :flex 40 :side 60 :twist 0) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -70))
  (44 (:root :yaw -185 :f 0.1 :u -0.04) (:chest :twist -8) (:head :flex -16)               ; his back turned, the blade lowered
      (:arm-r :flex -11 :side 23 :twist 21) (:elbow-r :flex 0) (:hand-r :twist 0 :flex -29))
  (50 (:root :yaw -280 :f 0.04))
  (:end :ya-stance (:root :yaw -360)))
;; O, ENJO (S11; canon 316Jokaku Enjo): the blade pointed at arm's length down the lane (f4, the walls start rising), held,
;; then a small flick of the wrist (S, the walls burst) -- not a chop
(defpose :ya-enjo-point (:base :ya-stance)
  (:root :yaw 20 :u -0.04) (:chest :twist 15) (:spine :flex 8) (:head :flex -24)
  (:arm-r :flex 127 :side -57 :twist -4) (:elbow-r :flex 4) (:hand-r :twist -6 :flex -78))
(defstrike :ya-enjo (20 2 30 :base :ya-stance)
  (0)
  (4 :ya-enjo-point)
  (17 :ya-enjo-point (:root :u -0.05) (:arm-r :flex 128))
  (19 :ya-enjo-point (:hand-r :side -12))                                                ; the wrist cocks up
  (:s :snap :ya-enjo-point (:root :u -0.08) (:hand-r :side 20 :flex -95))                  ; the flick
  (:a :ya-enjo-point (:root :u -0.08) (:hand-r :side 22 :flex -96))
  (36 (:root :yaw 8 :u -0.05) (:chest :twist 0) (:spine :flex 10)
      (:arm-r :flex 50 :side -15 :twist 0) (:elbow-r :flex 25) (:hand-r :twist 0 :flex -80))
  (:end :ya-stance))
(defclip :ya-breaker (0.4 :loop t :base :ya-stance)    ; Breaker aura dash: hunched charge, blade trailing
  (0 (:spine :flex 30) (:head :flex -30) (:arm-r :flex -35 :side 30) (:elbow-r :flex 20) (:hand-r :twist 150 :flex 10)
     (:thigh-r :flex 45) (:knee-r :flex 20) (:thigh-l :flex -30) (:knee-l :flex 45) (:root :u -0.1))
  (0.2 (:spine :flex 30) (:head :flex -30) (:thigh-l :flex 45) (:knee-l :flex 20) (:thigh-r :flex -30) (:knee-r :flex 45)
       (:root :u -0.06)))
;; S10 IKKOTSU (canon ch. 394): the blade planted (DRAW-PLANTED-WEAPON), one step in on the left foot, the right fist driven
;; straight out at shoulder height, the body turned in behind it (the fist at the 1.35 m volume's edge)
(defpose :ya-ikkotsu-chamber (:base :ya-stance)
  (:root :yaw -20 :u -0.1) (:chest :twist -25) (:spine :flex 10) (:head :flex -22)
  (:arm-r :flex 10 :side 15) (:elbow-r :flex 120) (:hand-r :flex 0 :twist 0))
(defpose :ya-ikkotsu-hit (:base :ya-stance)
  (:root :yaw 12 :f 0.32 :u -0.12) (:pelvis :side -4) (:chest :twist 22) (:spine :flex 14) (:head :flex -24)
  (:thigh-l :flex 45) (:knee-l :flex 40) (:thigh-r :flex -22)
  (:arm-r :flex 139 :side -47) (:elbow-r :flex 9) (:hand-r :flex 0 :twist 0))
(defstrike :ya-ikkotsu (8 4 18 :base :ya-stance)       ; Ikkotsu: sword planted (draw it with DRAW-PLANTED-WEAPON), one punch
  (0 :ya-ikkotsu-chamber)
  (5 :ya-ikkotsu-chamber (:root :yaw -28 :u -0.14) (:chest :twist -32) (:spine :flex 12) (:thigh-l :flex 30) (:knee-l :flex 50))
  (:s :snap :ya-ikkotsu-hit)
  (9 (:root :yaw 15 :f 0.34) (:chest :twist 25))
  (:a (:root :yaw 14 :f 0.33) (:chest :twist 24))
  (22 (:root :yaw 2 :f 0.12 :u -0.1) (:pelvis :side 0) (:chest :twist 0) (:spine :flex 22)
      (:arm-r :flex 45 :side 10) (:elbow-r :flex 40) (:hand-r :flex -20) (:thigh-l :flex 28) (:knee-l :flex 30) (:thigh-r :flex -10))
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
;; S12 the Hellfire entry (Ennetsu Jigoku, canon ch. 393): the point lowered to the plaza at his right side and drawn round
;; in one circle step (root yaw, a key every 90 degrees: the fire runs down the edge into the ground), then he straightens
;; and flares out
(defpose :ya-hellfire-point (:base :ya-stance)
  (:root :u -0.1) (:knees :flex 30) (:chest :twist -10) (:spine :flex 14)
  (:arm-r :flex 1 :side 25 :twist 23) (:elbow-r :flex 1) (:hand-r :twist 0 :flex -34))
(defclip :ya-hellfire (1.0 :base :ya-stance)
  (0)
  (0.12 :ya-hellfire-point)
  (0.27 :ya-hellfire-point (:root :yaw -90) (:pelvis :side 4))
  (0.42 :ya-hellfire-point (:root :yaw -180) (:pelvis :side 5))
  (0.57 :ya-hellfire-point (:root :yaw -270) (:pelvis :side 4))
  (0.7 :ya-hellfire-point (:root :yaw -360))
  (0.8 :snap (:root :yaw -360 :u 0.0) (:knees :flex 10) (:spine :flex -12) (:head :flex -30) (:chest :twist 0)
       (:arm-r :flex 20 :side 80 :twist 0) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -90) (:arm-l :side 45))
  (0.9 (:spine :flex -10) (:arm-l :side 47))
  (1.0 :ya-stance (:root :yaw -360)))

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

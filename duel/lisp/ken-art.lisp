;;;; ken-art.lisp — ZARAKI KENPACHI (TYBW) as art data: his body, his notched katana and the true
;;;; Shikai NOZARASHI (a giant cleaver), and every :ke-* pose and clip (design §5.2). Attack clips
;;;; use DEFSTRIKE, so each reaches its hit pose at frame S and is back in his stance at S+A+R.
;;;; Look: 2.02 m, broad, long loose black spiky hair (no bells), both eyes open (no eyepatch in any
;;;; form: the user's decision 2026-09-26, kept 2026-10-08; canon TYBW still wears a strapless patch, DUEL_KEN_REWORK §3), scar down the left side of the face, a grin, sleeveless tattered white haori over the black shihakusho, bare muscular arms.
(in-package :duel)

;;; ---------------------------------------------------------------- body
;; Proportions (user review 1: realistic, not chibi; TYBW's ~8 heads): a small narrow head and hair (the
;; girth factors), a broad but not boxy chest, long legs and arms (:props, the limb shapes as long), big hands.
(defbody :kenpachi (:scale 1.07 :width 1.18 :hunch 0 :hurt-r 0.45 :hurt-h 2.0
                    :girth ((:neck 0.85 1.3 0.85) (:chest 0.8 1.0 0.9) (:spine 0.8 1.0 0.9) (:pelvis 0.82 1.0 0.9)
                            (:shoulder-r 0.85 0.85 0.85) (:shoulder-l 0.85 0.85 0.85)
                            (:upper-arm-r 0.95 1.1 0.95) (:upper-arm-l 0.95 1.1 0.95)
                            (:lower-arm-r 0.95 1.1 0.95) (:lower-arm-l 0.95 1.1 0.95)
                            (:hand-r 1.2 1.25 1.2) (:hand-l 1.2 1.25 1.2)
                            (:thigh-r 0.95 1.1 0.95) (:thigh-l 0.95 1.1 0.95) (:shin-r 0.95 1.1 0.95) (:shin-l 0.95 1.1 0.95))
                    ;; v4 notan palette (docs/style/STYLE_STORM_DESIGN.md §2.5): black robe and solid black hair,
                    ;; the tattered haori V4 white, muted skin
                    :palette ((:skin #xCFA48C) (:skin-d #xB08C78) (:black #x16161E) (:white #xE8E8E4)
                              (:hair #x0C0C12) (:scar #x5A3430) (:teeth #xECECE8)
                              (:eye #x0C0C12) (:pupil #x0C0C12) (:crease #x7A5448) (:fold #xD8DCE4) (:obi #xDEDED8) (:tabi #xE8E8E4) (:sole #x262833))
                    :rim (#xFFE070 0.2)
                    :props (:shoulders 1.08 :arms 1.1 :legs 1.1))  ; the bare arms hang clear of the haori
  (:pelvis (:box 0.34 0.18 0.24 :c :black)
           (:box 0.35 0.07 0.25 :at (0 0.06 0) :c :obi)
           ;; the tattered haori hem: strips of different lengths
           (:box 0.15 0.62 0.02 :at (-0.14 -0.26 -0.14) :rot (0 -4 0) :c :white :tag :haori)
           (:box 0.14 0.76 0.02 :at (0.0 -0.33 -0.145) :rot (0 -4 0) :c :white :tag :haori)
           (:box 0.15 0.56 0.02 :at (0.14 -0.23 -0.14) :rot (0 -4 0) :c :white :tag :haori)
           (:box 0.02 0.5 0.13 :at (0.215 -0.2 -0.06) :rot (0 0 4) :c :white :tag :haori)
           (:box 0.02 0.66 0.12 :at (0.215 -0.28 0.06) :rot (0 0 4) :c :white :tag :haori)
           (:box 0.02 0.58 0.13 :at (-0.215 -0.24 -0.06) :rot (0 0 -4) :c :white :tag :haori)
           (:box 0.02 0.46 0.12 :at (-0.215 -0.18 0.06) :rot (0 0 -4) :c :white :tag :haori)
           (:box 0.1 0.64 0.02 :at (0.17 -0.27 0.135) :rot (0 4 0) :c :white :tag :haori)
           (:box 0.1 0.52 0.02 :at (-0.17 -0.21 0.135) :rot (0 4 0) :c :white :tag :haori)
           ;; the sawtooth hem (DUEL_KEN_REWORK §5.1, 「羽織與腰帶」): a white diamond behind each strip's foot, its lower half a
           ;; tooth; round holes punched near the hem
           (:box 0.05 0.05 0.02 :at (-0.178 -0.57 -0.158) :rot (0 -4 45) :c :white :tag :haori)
           (:box 0.05 0.05 0.02 :at (-0.103 -0.57 -0.158) :rot (0 -4 45) :c :white :tag :haori)
           (:box 0.047 0.047 0.02 :at (-0.035 -0.709 -0.168) :rot (0 -4 45) :c :white :tag :haori)
           (:box 0.047 0.047 0.02 :at (0.035 -0.709 -0.168) :rot (0 -4 45) :c :white :tag :haori)
           (:box 0.05 0.05 0.02 :at (0.103 -0.51 -0.156) :rot (0 -4 45) :c :white :tag :haori)
           (:box 0.05 0.05 0.02 :at (0.177 -0.51 -0.156) :rot (0 -4 45) :c :white :tag :haori)
           (:box 0.02 0.044 0.044 :at (0.228 -0.45 -0.092) :rot (0 45 0) :c :white :tag :haori)
           (:box 0.02 0.044 0.044 :at (0.228 -0.45 -0.027) :rot (0 45 0) :c :white :tag :haori)
           (:box 0.02 0.081 0.081 :at (0.234 -0.609 0.06) :rot (0 45 0) :c :white :tag :haori)
           (:box 0.02 0.044 0.044 :at (-0.231 -0.53 -0.092) :rot (0 45 0) :c :white :tag :haori)
           (:box 0.02 0.044 0.044 :at (-0.231 -0.53 -0.027) :rot (0 45 0) :c :white :tag :haori)
           (:box 0.02 0.081 0.081 :at (-0.227 -0.41 0.06) :rot (0 45 0) :c :white :tag :haori)
           (:box 0.067 0.067 0.02 :at (0.17 -0.589 0.153) :rot (0 4 45) :c :white :tag :haori)
           (:box 0.067 0.067 0.02 :at (-0.17 -0.47 0.149) :rot (0 4 45) :c :white :tag :haori)
           (:cyl 0.017 0.004 :at (-0.015 -0.539 -0.173) :rot (0 86 0) :seg 8 :c :black :ink 0 :tag :haori)
           (:cyl 0.017 0.004 :at (0.16 -0.409 -0.166) :rot (0 86 0) :seg 8 :c :black :ink 0 :tag :haori)
           (:cyl 0.017 0.004 :at (-0.12 -0.449 -0.166) :rot (0 86 0) :seg 8 :c :black :ink 0 :tag :haori)
           (:cyl 0.015 0.004 :at (0.244 -0.509 0.06) :rot (0 0 94) :seg 8 :c :black :ink 0 :tag :haori)
           ;; the white obi tied in a bow at the front: the knot, two loops, two tails
           (:box 0.045 0.04 0.03 :at (0 0.06 0.135) :c :obi)
           (:box 0.075 0.042 0.02 :at (0.055 0.068 0.135) :rot (0 0 -18) :c :obi)
           (:box 0.075 0.042 0.02 :at (-0.055 0.068 0.135) :rot (0 0 18) :c :obi)
           (:box 0.032 0.12 0.015 :at (0.022 -0.02 0.14) :rot (0 0 -12) :c :obi)
           (:box 0.032 0.1 0.015 :at (-0.024 -0.01 0.14) :rot (0 0 14) :c :obi))
  ;; the haori over the torso: one rounded white shell, the black robe and the bare chest at its open front
  (:spine (:bevel 0.44 0.25 0.27 0.04 :at (0 0.11 -0.005) :c :white :tag :haori)
          ;; the 11th Division's mark on the back: 十一 stacked in a diamond (ink strokes), below the mane
          (:box 0.1 0.008 0.004 :at (0.035 0.09 -0.163) :rot (0 0 -45) :c :black :ink 0 :tag :haori)
          (:box 0.1 0.008 0.004 :at (-0.035 0.09 -0.163) :rot (0 0 45) :c :black :ink 0 :tag :haori)
          (:box 0.1 0.008 0.004 :at (0.035 0.02 -0.163) :rot (0 0 45) :c :black :ink 0 :tag :haori)
          (:box 0.1 0.008 0.004 :at (-0.035 0.02 -0.163) :rot (0 0 -45) :c :black :ink 0 :tag :haori)
          (:box 0.007 0.04 0.004 :at (0 0.073 -0.163) :c :black :ink 0 :tag :haori)
          (:box 0.042 0.007 0.004 :at (0 0.075 -0.163) :c :black :ink 0 :tag :haori)
          (:box 0.046 0.007 0.004 :at (0 0.035 -0.163) :c :black :ink 0 :tag :haori)
          (:box 0.14 0.25 0.02 :at (0 0.11 0.155) :c :black :tag :haori))
  (:chest (:bevel 0.5 0.33 0.29 0.05 :at (0 0.105 -0.005) :c :white :tag :haori)
          (:box 0.15 0.3 0.02 :at (0 0.1 0.156) :c :skin :tag :haori)                                ; the bare chest in the open collar ...
          (:box 0.05 0.33 0.02 :at (0.045 0.1 0.163) :rot (0 0 -14) :c :black :tag :haori)          ; ... between the robe's lapels
          (:box 0.05 0.33 0.02 :at (-0.045 0.1 0.163) :rot (0 0 14) :c :black :tag :haori))
  (:neck (:cyl 0.075 0.1 :at (0 0.04 0) :c :skin))
  ;; head in metres (not girth-scaled; x and z sizes x the body :width 1.18): a skull sphere under the hair,
  ;; a flat-fronted face (front at z 0.073) carrying the flat face shapes, one set per expression (tags :face-neutral,
  ;; :face-shout, :face-hurt: DRAW-BODY :face shows one); the scar and the face box are shared
  (:head (:sphere 0.061 :stretch 0.04 :at (0 0.13 -0.012) :seg 10 :c :skin)                ; skull
         (:bevel 0.1 0.15 0.076 0.018 :at (0 0.085 0.028) :c :skin)                         ; face, jaw
         (:bevel 0.07 0.03 0.06 0.01 :at (0 0.012 0.036) :c :skin)                          ; chin
         (:box 0.016 0.04 0.025 :at (0.064 0.105 0.0) :c :skin) (:box 0.016 0.04 0.025 :at (-0.064 0.105 0.0) :c :skin)
         (:wedge 0.024 0.042 0.03 :at (0 0.097 0.086) :rot (180 0 0) :c :skin)            ; nose
         ;; the left eye (his left = -x): narrow, small pupil, a heavy slanted lid and brow
         (:box 0.024 0.011 0.004 :at (-0.028 0.118 0.075) :c :teeth :tag :face-neutral)
         (:box 0.008 0.011 0.005 :at (-0.024 0.118 0.0755) :c :pupil :tag :face-neutral)
         (:box 0.035 0.006 0.005 :at (-0.028 0.125 0.0756) :rot (0 0 -10) :c :eye :tag :face-neutral)
         (:box 0.04 0.009 0.006 :at (-0.03 0.141 0.0757) :rot (0 0 -16) :c :eye :tag :face-neutral)
         ;; the right eye
         (:box 0.024 0.011 0.004 :at (0.028 0.118 0.075) :c :teeth :tag :face-neutral)
         (:box 0.008 0.011 0.005 :at (0.024 0.118 0.0755) :c :pupil :tag :face-neutral)
         (:box 0.035 0.006 0.005 :at (0.028 0.125 0.0756) :rot (0 0 10) :c :eye :tag :face-neutral)
         (:box 0.04 0.009 0.006 :at (0.03 0.141 0.0757) :rot (0 0 16) :c :eye :tag :face-neutral)
         (:box 0.006 0.12 0.004 :at (-0.037 0.108 0.0765) :rot (0 0 8) :c :scar)                ; scar through the left eye
         ;; the grin: a wide dark mouth, a row of teeth, corners pulled up
         (:box 0.06 0.02 0.004 :at (0 0.043 0.074) :c :eye :tag :face-neutral)
         (:box 0.054 0.009 0.004 :at (0 0.047 0.0746) :c :teeth :tag :face-neutral)
         (:box 0.014 0.006 0.004 :at (0.034 0.05 0.0746) :rot (0 0 32) :c :eye :tag :face-neutral)
         (:box 0.014 0.006 0.004 :at (-0.034 0.05 0.0746) :rot (0 0 -32) :c :eye :tag :face-neutral)
         ;; :face-shout, the berserker's roar / maniac laugh: eyes wide with pin pupils under a hard lid line, brows
         ;; high and hooked, the grin at full: a wide open dark mouth, both rows of teeth, corners up, cheek creases
         (:box 0.026 0.017 0.004 :at (-0.028 0.119 0.075) :c :teeth :tag :face-shout)
         (:box 0.005 0.006 0.005 :at (-0.026 0.119 0.0755) :c :pupil :tag :face-shout)
         (:box 0.032 0.004 0.004 :at (-0.028 0.1285 0.0757) :rot (0 0 -6) :c :eye :tag :face-shout)
         (:box 0.04 0.008 0.006 :at (-0.03 0.149 0.0757) :rot (0 0 -22) :c :eye :tag :face-shout)
         (:box 0.016 0.007 0.006 :at (-0.054 0.151 0.0762) :rot (0 0 50) :c :eye :tag :face-shout)
         (:box 0.026 0.017 0.004 :at (0.028 0.119 0.075) :c :teeth :tag :face-shout)
         (:box 0.005 0.006 0.005 :at (0.026 0.119 0.0755) :c :pupil :tag :face-shout)
         (:box 0.032 0.004 0.004 :at (0.028 0.1285 0.0757) :rot (0 0 6) :c :eye :tag :face-shout)
         (:box 0.04 0.008 0.006 :at (0.03 0.149 0.0757) :rot (0 0 22) :c :eye :tag :face-shout)
         (:box 0.016 0.007 0.006 :at (0.054 0.151 0.0762) :rot (0 0 -50) :c :eye :tag :face-shout)
         (:box 0.08 0.054 0.004 :at (0 0.041 0.074) :c :eye :tag :face-shout)                   ; the open mouth (Phase 6: bolder)
         (:box 0.07 0.01 0.004 :at (0 0.0625 0.0746) :c :teeth :tag :face-shout)                 ; upper teeth
         (:box 0.058 0.009 0.004 :at (0 0.0195 0.0746) :c :teeth :tag :face-shout)               ; lower teeth
         (:box 0.02 0.008 0.004 :at (0.048 0.069 0.0748) :rot (0 0 38) :c :eye :tag :face-shout) ; corners pulled up
         (:box 0.02 0.008 0.004 :at (-0.048 0.069 0.0748) :rot (0 0 -38) :c :eye :tag :face-shout)
         (:box 0.004 0.036 0.004 :at (0.037 0.083 0.0745) :rot (0 0 40) :c :crease :tag :face-shout)
         (:box 0.004 0.036 0.004 :at (-0.037 0.083 0.0745) :rot (0 0 -40) :c :crease :tag :face-shout)
         ;; :face-hurt, a grimacing grin: the left (scar) eye open, the right squeezed shut, brows knotted with two
         ;; creases between them, clenched teeth bared (the clench line and tooth gaps in ink), one corner up
         (:box 0.024 0.008 0.004 :at (-0.028 0.117 0.075) :c :teeth :tag :face-hurt)
         (:box 0.007 0.008 0.005 :at (-0.025 0.117 0.0755) :c :pupil :tag :face-hurt)
         (:box 0.034 0.007 0.005 :at (-0.028 0.1225 0.0758) :rot (0 0 -18) :c :eye :tag :face-hurt)
         (:box 0.022 0.003 0.004 :at (0.028 0.1155 0.075) :c :teeth :tag :face-hurt)
         (:box 0.034 0.009 0.005 :at (0.028 0.1195 0.0758) :rot (0 0 20) :c :eye :tag :face-hurt)
         (:box 0.026 0.003 0.004 :at (0.029 0.1105 0.0757) :rot (0 0 -8) :c :eye :tag :face-hurt)
         (:box 0.036 0.009 0.006 :at (-0.025 0.137 0.0757) :rot (0 0 -26) :c :eye :tag :face-hurt)
         (:box 0.036 0.009 0.006 :at (0.025 0.134 0.0757) :rot (0 0 28) :c :eye :tag :face-hurt)
         (:box 0.003 0.014 0.004 :at (-0.005 0.141 0.0757) :rot (0 0 -8) :c :crease :tag :face-hurt)
         (:box 0.003 0.014 0.004 :at (0.005 0.141 0.0757) :rot (0 0 8) :c :crease :tag :face-hurt)
         (:box 0.066 0.024 0.004 :at (0 0.043 0.074) :c :eye :tag :face-hurt)                   ; the bared mouth
         (:box 0.058 0.009 0.004 :at (0 0.0475 0.0746) :c :teeth :tag :face-hurt)                ; upper teeth
         (:box 0.056 0.008 0.004 :at (0 0.0375 0.0746) :c :teeth :tag :face-hurt)                ; lower teeth
         (:box 0.002 0.017 0.004 :at (-0.017 0.043 0.0752) :c :eye :tag :face-hurt)              ; tooth gaps
         (:box 0.002 0.017 0.004 :at (0 0.043 0.0752) :c :eye :tag :face-hurt)
         (:box 0.002 0.017 0.004 :at (0.017 0.043 0.0752) :c :eye :tag :face-hurt)
         (:box 0.018 0.007 0.004 :at (0.041 0.051 0.0748) :rot (0 0 32) :c :eye :tag :face-hurt) ; right corner up
         (:box 0.016 0.007 0.004 :at (-0.04 0.038 0.0748) :rot (0 0 22) :c :eye :tag :face-hurt) ; left corner dragged down
         (:box 0.004 0.03 0.004 :at (0.035 0.08 0.0745) :rot (0 0 36) :c :crease :tag :face-hurt)
         ;; TYBW hair (DUEL_KEN_REWORK §5.1, the user 2026-10-08: 「頭髮：刺狀頭頂＋長鬃髮」): a cap over the skull, an upswept
         ;; spiky crown (up, back and out), a back sheet and ragged ends hanging to mid-back, strands over the shoulders, the
         ;; side locks; no fringe, no bells
         (:sphere 0.0695 :stretch 0.03 :at (0 0.15 -0.024) :seg 10 :c :hair)
         (:box 0.2 0.44 0.04 :at (0 -0.03 -0.15) :rot (0 -18 0) :c :hair)
         (:cone 0.0413 0.324 :at (0.0805 0.045 -0.008) :rot (0 172 -14) :seg 4 :c :hair)      ; side locks
         (:cone 0.0413 0.324 :at (-0.0805 0.045 -0.008) :rot (0 172 14) :seg 4 :c :hair)
         (:cone 0.032 0.17 :at (0.057 0.281 -0.012) :rot (0 19 -18) :seg 4 :c :hair) ; crown, front
         (:cone 0.036 0.2 :at (0.106 0.264 -0.074) :rot (0 31 -31) :seg 4 :c :hair) ; crown, side
         (:cone 0.038 0.21 :at (0.052 0.273 -0.133) :rot (0 45 -12) :seg 4 :c :hair) ; crown, back
         (:cone 0.036 0.19 :at (0.136 0.186 -0.133) :rot (0 58 -44) :seg 4 :c :hair) ; behind the ears
         (:cone 0.032 0.17 :at (-0.057 0.281 -0.012) :rot (0 19 18) :seg 4 :c :hair)
         (:cone 0.036 0.2 :at (-0.106 0.264 -0.074) :rot (0 31 31) :seg 4 :c :hair)
         (:cone 0.038 0.21 :at (-0.052 0.273 -0.133) :rot (0 45 12) :seg 4 :c :hair)
         (:cone 0.036 0.19 :at (-0.136 0.186 -0.133) :rot (0 58 44) :seg 4 :c :hair)
         (:cone 0.04 0.22 :at (0.000 0.306 -0.083) :rot (0 29 -0) :seg 4 :c :hair) ; crown, top
         (:cone 0.05 0.26 :at (-0.091 -0.294 -0.200) :rot (0 162 3) :seg 4 :c :hair)
         (:cone 0.05 0.32 :at (-0.049 -0.352 -0.209) :rot (0 162 1) :seg 4 :c :hair)
         (:cone 0.05 0.36 :at (0.000 -0.371 -0.215) :rot (0 162 -0) :seg 4 :c :hair)
         (:cone 0.05 0.3 :at (0.049 -0.343 -0.206) :rot (0 162 -1) :seg 4 :c :hair)
         (:cone 0.05 0.24 :at (0.091 -0.284 -0.197) :rot (0 162 -3) :seg 4 :c :hair)
         (:cone 0.034 0.38 :at (0.141 -0.103 -0.068) :rot (0 174 -14) :seg 4 :c :hair) ; over the shoulders
         (:cone 0.034 0.38 :at (-0.141 -0.103 -0.068) :rot (0 174 14) :seg 4 :c :hair)
         ;; (no fringe: its two strands are gone, the user 2026-10-09: 「那兩根瀏海直接刪除」)
         ;; white highlight strokes on the black hair (Kubo's white-on-black)
         (:box 0.006 0.05 0.004 :at (0.028 0.215 0.036) :rot (0 -48 -12) :c :fold)
         (:box 0.006 0.04 0.004 :at (-0.034 0.21 0.034) :rot (0 -48 16) :c :fold)
         (:box 0.006 0.14 0.004 :at (0.035 -0.02 -0.136) :rot (0 -8 3) :c :fold)
         (:box 0.006 0.11 0.004 :at (-0.045 -0.05 -0.136) :rot (0 -8 -4) :c :fold))
;; the arms (DUEL_KEN_V3 §10, §17; the user 2026-11-03: 「劍八的封印跟常態應該是要穿著長袖的死霸裝配上短袖的白色羽織，卍解才剩下變成短袖的
;; 死霸裝」, then 「劍八是無袖羽織，而不是你製作的短袖羽織，然後長袖的死霸裝是像一護的那種寬鬆袖口設計。此外，目前手彎曲的時候手肘會透過衣服」):
;; the haori sleeveless (only its shoulder over the black), the shihakushō's black sleeves to the wrist widening into a loose square
;; cuff like Ichigo's (the forearm's :sleeve-long, which the Bankai hides: short sleeves), a black ball at the elbow so a bent arm
;; shows cloth, not skin, between the two sleeve pieces; the skin arm stays under them. The loose sleeve ends a little below the
;; elbow, the forearm bare (「劍八的寬鬆長袖實際的長度也只比手肘稍長一些，目前的袖長過長了」, DUEL_KEN_V3 §18: the cuff 0.2 -> 0.09 m down
;; the forearm, 0.27 long)
  (:shoulder-r (:sphere 0.09 :at (0.06 -0.03 0) :c :black)
               (:box 0.1 0.04 0.27 :at (-0.01 0.05 0) :rot (0 0 -10) :c :white :tag :haori))
  (:shoulder-l (:sphere 0.09 :at (-0.06 -0.03 0) :c :black)
               (:box 0.1 0.04 0.27 :at (0.01 0.05 0) :rot (0 0 10) :c :white :tag :haori))
  (:upper-arm-r (:cyl 0.05 0.3 :top 0.056 :seg 8 :at (0 -0.15 0) :c :skin)
                (:cyl 0.08 0.3 :top 0.084 :seg 8 :at (0 -0.15 0) :c :black))                         ; the black sleeve
  (:upper-arm-l (:cyl 0.05 0.3 :top 0.056 :seg 8 :at (0 -0.15 0) :c :skin)
                (:cyl 0.08 0.3 :top 0.084 :seg 8 :at (0 -0.15 0) :c :black))
  (:lower-arm-r (:cyl 0.036 0.27 :top 0.048 :seg 8 :at (0 -0.125 0) :c :skin) (:sphere 0.045 :at (0 0 0) :c :skin)
                (:sphere 0.082 :at (0 0 0) :c :black :tag :sleeve-long)                               ; the elbow, covered
                (:cyl 0.1 0.07 :top 0.085 :seg 8 :at (0 -0.035 0) :c :black :tag :sleeve-long)       ; the sleeve, widening ...
                (:box 0.21 0.05 0.22 :at (0 -0.09 0) :rot (0 0 -8) :c :black :tag :sleeve-long))     ; ... into the loose cuff
  (:lower-arm-l (:cyl 0.036 0.27 :top 0.048 :seg 8 :at (0 -0.125 0) :c :skin) (:sphere 0.045 :at (0 0 0) :c :skin)
                (:sphere 0.082 :at (0 0 0) :c :black :tag :sleeve-long)
                (:cyl 0.1 0.07 :top 0.085 :seg 8 :at (0 -0.035 0) :c :black :tag :sleeve-long)
                (:box 0.21 0.05 0.22 :at (0 -0.09 0) :rot (0 0 8) :c :black :tag :sleeve-long))
  (:hand-r (:bevel 0.075 0.1 0.08 0.02 :at (0 -0.045 0) :c :skin))
  (:hand-l (:bevel 0.075 0.1 0.08 0.02 :at (0 -0.045 0) :c :skin))
  (:thigh-r (:cyl 0.092 0.46 :top 0.088 :seg 10 :at (0 -0.22 0) :c :black))
  (:thigh-l (:cyl 0.092 0.46 :top 0.088 :seg 10 :at (0 -0.22 0) :c :black))
  (:shin-r (:cyl 0.11 0.34 :top 0.094 :seg 10 :at (0 -0.15 0) :c :black)
          (:box 0.005 0.2 0.004 :at (0.03 -0.16 0.125) :rot (0 -4 -5) :c :fold) (:box 0.085 0.12 0.09 :at (0 -0.37 0) :c :tabi))
  (:shin-l (:cyl 0.11 0.34 :top 0.094 :seg 10 :at (0 -0.15 0) :c :black)
          (:box 0.005 0.22 0.004 :at (-0.02 -0.15 0.125) :rot (0 -4 4) :c :fold) (:box 0.085 0.12 0.09 :at (0 -0.37 0) :c :tabi))
  (:foot-r (:bevel 0.09 0.06 0.23 0.02 :at (0 -0.02 0.06) :c :tabi) (:box 0.1 0.02 0.25 :at (0 -0.055 0.06) :c :sole))
  (:foot-l (:bevel 0.09 0.06 0.23 0.02 :at (0 -0.02 0.06) :c :tabi) (:box 0.1 0.02 0.25 :at (0 -0.055 0.06) :c :sole)))

;; cup 3 NOMIHOSE (DUEL_KEN_REWORK §6.2): the hair lifted by the reiatsu: 8 more spikes standing up and out off the crown,
;; the sides and the mane (a look; the same rig and hurt cylinder)
(body-variant :kenpachi-nomi :kenpachi
  :parts '((:head (:cone 0.036 0.24 :at (0.113 0.276 -0.036) :rot (0 9 -26) :seg 4 :c :hair)
                 (:cone 0.04 0.26 :at (0.177 0.198 -0.109) :rot (0 27 -48) :seg 4 :c :hair)
                 (:cone 0.045 0.3 :at (0.169 0.055 -0.219) :rot (0 61 -41) :seg 4 :c :hair)
                 (:cone 0.036 0.24 :at (-0.113 0.276 -0.036) :rot (0 9 26) :seg 4 :c :hair)
                 (:cone 0.04 0.26 :at (-0.177 0.198 -0.109) :rot (0 27 48) :seg 4 :c :hair)
                 (:cone 0.045 0.3 :at (-0.169 0.055 -0.219) :rot (0 61 41) :seg 4 :c :hair)
                 (:cone 0.035 0.24 :at (0.000 0.319 0.032) :rot (0 -6 -0) :seg 4 :c :hair)
                 (:cone 0.05 0.34 :at (0.000 0.137 -0.296) :rot (0 59 -0) :seg 4 :c :hair))))

;; the Bankai's oni (docs/duel/DUEL_KEN_BANKAI.md §12; DUEL_KEN_REWORK §8: the anime's look, the user's figure references,
;; 2026-10-09): crimson all over; the anime's small skin-red horns over the eyes, the brow slit, a comma over each eye, the
;; eye masks, tear streaks and tiger stripes (cheeks, jaw, neck); blank white eyes; the hair wilder (cup 3's lifted spikes);
;; the haori gone (its parts carry :tag :haori, the kits hide it): the bare torso under a black sleeveless vest with white
;; lining at the armholes and the open front and a ragged hem, the white obi, the baggy black hakama with ragged cuffs,
;; bare feet; four BLOOD cracks on the right forearm (:crack-1 .. :crack-4, one per spent pip) and its wreck (:arm-wreck)
(body-variant :kenpachi-oni :kenpachi
  :palette '((:skin #xA23440) (:skin-d #x7E2632) (:pupil #xF4F2EA) (:horn #x8E2C38) (:mark #x121216) (:crease #x4A1018)
            (:tabi #xA23440) (:sole #x5A1822) (:lining #xE4E4E0)
            (:blood #xD0101C) (:wound #x5A1418) (:split #x101018))
  ;; his own prowl, guard and back leap for the shared clips (the feral pass, 2026-09-28; the leap §8.4): art only
  :clips '(:sh-guard :ke-b-guard :sh-guard-hit :ke-b-guard-hit :sh-walk-f :ke-b-walk-f :sh-walk-b :ke-b-walk-b
           :sh-strafe-r :ke-b-strafe-r :sh-strafe-l :ke-b-strafe-l :sh-step-b :ke-b-step-b)
  :parts '((:head (:cone 0.016 0.06 :at (0.034 0.222 0.064) :rot (0 -12 -14) :seg 6 :c :horn)   ; the horns (the anime's: small cones)
                 (:cone 0.016 0.06 :at (-0.034 0.222 0.064) :rot (0 -12 14) :seg 6 :c :horn)
                 (:box 0.006 0.045 0.004 :at (0 0.162 0.0768) :c :mark)                          ; the slit between the brows
                 (:box 0.016 0.006 0.004 :at (0.03 0.153 0.0768) :rot (0 0 -30) :c :mark)       ; a comma over each eye
                 (:box 0.016 0.006 0.004 :at (-0.03 0.153 0.0768) :rot (0 0 30) :c :mark)
                 (:box 0.042 0.016 0.003 :at (0.028 0.118 0.0745) :c :mark)                       ; the eye masks
                 (:box 0.042 0.016 0.003 :at (-0.028 0.118 0.0745) :c :mark)
                 (:box 0.006 0.034 0.004 :at (0.034 0.094 0.0768) :rot (0 0 10) :c :mark)        ; the tear streaks
                 (:box 0.006 0.034 0.004 :at (-0.034 0.094 0.0768) :rot (0 0 -10) :c :mark)
                 (:box 0.03 0.005 0.004 :at (0.05 0.078 0.0745) :rot (0 0 28) :c :mark)          ; tiger stripes on the cheeks
                 (:box 0.03 0.005 0.004 :at (-0.05 0.078 0.0745) :rot (0 0 -28) :c :mark)
                 (:box 0.026 0.005 0.004 :at (0.052 0.06 0.0745) :rot (0 0 18) :c :mark)
                 (:box 0.026 0.005 0.004 :at (-0.052 0.06 0.0745) :rot (0 0 -18) :c :mark)
                 (:box 0.004 0.03 0.03 :at (0.074 0.09 0.03) :rot (25 0 0) :c :mark)              ; ... and on the jaw's sides
                 (:box 0.004 0.03 0.03 :at (-0.074 0.09 0.03) :rot (-25 0 0) :c :mark)
                 (:cone 0.036 0.24 :at (0.113 0.276 -0.036) :rot (0 9 -26) :seg 4 :c :hair)
                 (:cone 0.04 0.26 :at (0.177 0.198 -0.109) :rot (0 27 -48) :seg 4 :c :hair)
                 (:cone 0.045 0.3 :at (0.169 0.055 -0.219) :rot (0 61 -41) :seg 4 :c :hair)
                 (:cone 0.036 0.24 :at (-0.113 0.276 -0.036) :rot (0 9 26) :seg 4 :c :hair)
                 (:cone 0.04 0.26 :at (-0.177 0.198 -0.109) :rot (0 27 48) :seg 4 :c :hair)
                 (:cone 0.045 0.3 :at (-0.169 0.055 -0.219) :rot (0 61 41) :seg 4 :c :hair)
                 (:cone 0.035 0.24 :at (0.000 0.319 0.032) :rot (0 -6 -0) :seg 4 :c :hair)
                 (:cone 0.05 0.34 :at (0.000 0.137 -0.296) :rot (0 59 -0) :seg 4 :c :hair))
          (:neck (:box 0.004 0.03 0.03 :at (0.07 0.05 0.03) :rot (30 0 0) :c :mark) (:box 0.004 0.03 0.03 :at (-0.07 0.05 0.03) :rot (-30 0 0) :c :mark))
          ;; the bare torso and the vest
          (:chest (:bevel 0.46 0.31 0.27 0.05 :at (0 0.105 0.0) :c :skin)
                  (:box 0.004 0.13 0.004 :at (0 0.07 0.137) :c :crease)
                  (:box 0.09 0.004 0.004 :at (0.05 0.135 0.137) :rot (0 0 -8) :c :crease)
                  (:box 0.09 0.004 0.004 :at (-0.05 0.135 0.137) :rot (0 0 8) :c :crease)
                  (:bevel 0.5 0.34 0.13 0.03 :at (0 0.105 -0.085) :c :black)                 ; the vest's back
                  (:box 0.1 0.34 0.2 :at (0.2 0.105 0.02) :c :black)                          ; its sides
                  (:box 0.1 0.34 0.2 :at (-0.2 0.105 0.02) :c :black)
                  (:box 0.022 0.34 0.022 :at (0.158 0.105 0.12) :c :lining)                   ; the lining at the open front
                  (:box 0.022 0.34 0.022 :at (-0.158 0.105 0.12) :c :lining))
          (:spine (:bevel 0.42 0.24 0.25 0.04 :at (0 0.11 0.0) :c :skin)
                  (:box 0.11 0.004 0.004 :at (0 0.15 0.127) :c :crease)                       ; the abs
                  (:box 0.11 0.004 0.004 :at (0 0.09 0.127) :c :crease)
                  (:box 0.004 0.14 0.004 :at (0 0.11 0.127) :c :crease)
                  (:bevel 0.46 0.25 0.12 0.03 :at (0 0.11 -0.08) :c :black)
                  (:box 0.1 0.25 0.19 :at (0.19 0.11 0.02) :c :black)
                  (:box 0.1 0.25 0.19 :at (-0.19 0.11 0.02) :c :black)
                  (:box 0.022 0.25 0.022 :at (0.148 0.11 0.115) :c :lining)
                  (:box 0.022 0.25 0.022 :at (-0.148 0.11 0.115) :c :lining))
          ;; the vest's ragged hem over the hips
          (:pelvis (:box 0.16 0.22 0.02 :at (-0.12 -0.06 -0.14) :c :black) (:box 0.15 0.3 0.02 :at (0.02 -0.1 -0.145) :c :black)
                   (:box 0.15 0.18 0.02 :at (0.15 -0.04 -0.14) :c :black)
                   (:box 0.02 0.2 0.18 :at (0.215 -0.05 0.0) :c :black) (:box 0.02 0.26 0.16 :at (-0.215 -0.08 0.0) :c :black)
                   (:box 0.075 0.075 0.02 :at (-0.12 -0.17 -0.138) :rot (0 0 45) :c :black)
                   (:box 0.07 0.07 0.02 :at (0.02 -0.25 -0.143) :rot (0 0 45) :c :black)
                   (:box 0.075 0.075 0.02 :at (0.15 -0.13 -0.138) :rot (0 0 45) :c :black))
          (:shoulder-r (:box 0.13 0.05 0.29 :at (-0.01 0.05 0) :rot (0 0 -10) :c :black) (:box 0.02 0.06 0.29 :at (0.06 0.03 0) :rot (0 0 -10) :c :lining))
          (:shoulder-l (:box 0.13 0.05 0.29 :at (0.01 0.05 0) :rot (0 0 10) :c :black) (:box 0.02 0.06 0.29 :at (-0.06 0.03 0) :rot (0 0 10) :c :lining))
          ;; the hakama's ragged cuffs, flared
          (:shin-r (:cyl 0.15 0.12 :top 0.115 :seg 10 :at (0 -0.27 0) :c :black)
                   (:box 0.07 0.07 0.02 :at (0.06 -0.33 0.12) :rot (0 0 45) :c :black) (:box 0.07 0.07 0.02 :at (-0.06 -0.34 -0.1) :rot (0 0 45) :c :black))
          (:shin-l (:cyl 0.15 0.12 :top 0.115 :seg 10 :at (0 -0.27 0) :c :black)
                   (:box 0.07 0.07 0.02 :at (-0.06 -0.33 0.12) :rot (0 0 45) :c :black) (:box 0.07 0.07 0.02 :at (0.06 -0.34 -0.1) :rot (0 0 45) :c :black))
          (:lower-arm-r (:glow 1.6 (:box 0.006 0.075 0.004 :at (0.0 -0.06 0.052) :rot (0 0 25) :c :blood) :crack-1)
                        (:glow 1.6 (:box 0.004 0.075 0.006 :at (0.052 -0.1 0.012) :rot (0 0 -20) :c :blood) :crack-2)
                        (:glow 1.6 (:box 0.006 0.075 0.004 :at (-0.01 -0.15 0.05) :rot (0 0 -30) :c :blood) :crack-3)
                        (:glow 1.6 (:box 0.004 0.075 0.006 :at (0.05 -0.19 -0.01) :rot (0 0 15) :c :blood) :crack-4)
                        (:wedge 0.035 0.07 0.02 :at (0.03 -0.07 0.045) :rot (0 0 30) :c :skin-d :tag :arm-wreck)
                        (:wedge 0.03 0.06 0.02 :at (-0.03 -0.16 0.045) :rot (0 0 -25) :c :skin-d :tag :arm-wreck)
                        (:box 0.014 0.12 0.008 :at (0.004 -0.12 0.052) :rot (0 0 10) :c :wound :tag :arm-wreck)
                        (:box 0.008 0.1 0.012 :at (0.054 -0.15 0.0) :rot (0 0 -12) :c :wound :tag :arm-wreck)
                        (:box 0.004 0.13 0.006 :at (-0.02 -0.1 0.056) :rot (0 0 -18) :c :split :tag :arm-wreck)
                        (:box 0.006 0.11 0.004 :at (0.056 -0.08 0.02) :rot (0 0 8) :c :split :tag :arm-wreck))))

;;; ---------------------------------------------------------------- weapons
(defweapon :ken-katana (:length 1.08)                  ; battered, notched, chipped
  ;; the hilt (DUEL_KEN_REWORK §5.1, 「封印刀的刀鍔與柄」): a grey collar, a long spindle tsuba (16 x 5 cm, pointed along the
  ;; edge and the spine) with teeth round its rim in dark iron, a white bandage-wrapped grip with diagonal seams, a grey cap
  (:solid (mbc mb #x8A8A90)
          (mb-at (mb :y 0.025) (mb-box mb 0.013 0.04 0.041))
          (mbc mb #x4A4542)
          (mb-at (mb :y -0.004 :sx 0.31) (mb-cylinder mb 0.08 0.015 :segments 4))
          (loop for (x z) in '((0.0063 0.06) (0.0125 0.04) (0.0188 0.02) (0.0063 -0.06) (0.0125 -0.04) (0.0188 -0.02)
                               (-0.0063 0.06) (-0.0125 0.04) (-0.0188 0.02) (-0.0063 -0.06) (-0.0125 -0.04) (-0.0188 -0.02))
                do (mb-at (mb :x x :y -0.004 :z z :yaw (atan (* -0.025 (signum z)) (* 0.08 (signum x)))
                                          :roll (* -0.5 pi))
                     (mb-cone mb 0.007 0.03 :segments 4)))
          (mbc mb #xE6E4DC)
          (mb-at (mb :y -0.17) (mb-bevel-box mb 0.03 0.31 0.038 0.006))
          (mbc mb #x9A988E)
          (loop for i below 6 do (mb-at (mb :y (- -0.045 (* i 0.05)) :roll 0.35) (mb-box mb 0.034 0.005 0.04)))
          (mbc mb #x8A8A90)
          (mb-at (mb :y -0.33) (mb-bevel-box mb 0.034 0.018 0.042 0.004)))
  (:solid :ink 0 (mb-blade mb :length 1.02 :width 0.036 :curve 0.018 :blade-color '(0.55 0.57 0.6) :edge-color '(0.78 0.8 0.82)
                              :hilt nil)
          (mbc mb #x2A2A2E)                              ; chips: dark notches bitten out of the edge
          (loop for (y d) in '((0.22 0.012) (0.37 0.008) (0.55 0.014) (0.71 0.009) (0.86 0.011))
                do (mb-at (mb :y y :z (- 0.016 (* 0.018 (/ y 1.02) (/ y 1.02))) :roll 0.6)
                     (mb-box mb 0.012 d d)))))

;; NOZARASHI (DUEL_KEN_REWORK §6.1; the user 2026-10-08: 「改成原作形狀，大小貼合現有判定」, then 2026-10-09 a model sheet to
;; follow, the cgtrader "Nozarashi from Bleach" preview): the war cleaver at the old length (the hit reaches are the sim's),
;; traced off that sheet (2.31 m from butt to end, the grip 0.69 m up the haft so the left fist has its 0.14-0.62 m of
;; handle): the white-wrapped haft with a black butt; the head on the edge side (+Z) only, its spine just above the haft
;; line, a raked point overhanging back beside the hand with a round notch under it, the cutting edge a long convex curve
;; rising to 0.6 m at the square far end; near-black, the edge's pale band (2/3 of the sheet's) in slanted light and grey
;; stripes with a ragged inner line; a khaki box cap over the whole far end with a stepped foot and a groove; a black
;; slanted bar from the haft to the head; a dark green tassel from the cap's spine corner, its strands fanning out
(defun ke-mb-prism (mb profile x0 x1)
  "A prism of the convex PROFILE ((y z) ...) between the planes x = X0 and X1 (a blade's faces and its rim)."
  (let* ((n (length profile))
         (cy (/ (loop for (y nil) in profile sum y) n)) (cz (/ (loop for (nil z) in profile sum z) n))
         (c (list (* 0.5 (+ x0 x1)) cy cz))
         (f0 (loop for (y z) in profile collect (v3 x0 y z))) (f1 (loop for (y z) in profile collect (v3 x1 y z))))
    (mb-poly-out mb f0 :center c)
    (mb-poly-out mb f1 :center c)
    (loop for i below n for j = (mod (1+ i) n)
          do (mb-poly-out mb (list (nth i f0) (nth j f0) (nth j f1) (nth i f1)) :center c))))

(defmacro with-ke-tilt ((mb) &body body)
  "Run BODY (Nozarashi's head and what rides on it) turned 10 degrees about the black bar's joint with the head, (y z) =
(0.4 0.08): the far end down toward the haft line, seen with the haft on the left and the edge up (the user 2026-10-09:
「以黑色斜槓跟刀身的連接點為基準，將刀身順時針轉 10 度」); the bar and the haft stay. Since 2026-11-03 (「從 5 開始的刀身結構
逆時針轉 5 度，並向下移動 0.05 m」, DUEL_KEN_V3 §7.2): 5 degrees net, and 0.05 m down (away from the edge); and scaled
*KE-NOZ-SCALE* about the joint (「將刀身放大 1.5 倍」, §7.3)."
  `(mb-at (,mb :y 0.4 :z 0.03 :pitch -0.08726646 :s *ke-noz-scale*)
     (mb-at (,mb :y -0.4 :z -0.08) ,@body)))

;; Nozarashi's haft (the user 2026-11-03: 「1 加長」, no figure given: mine, knobs): 1.3 times, lengthened downward (0.76 -> 0.99 m,
;; the Bankai's own figure), and the sag at the butt
(defparameter *ke-noz-haft* 1.3 "Nozarashi's haft length / the first 0.76 m (DUEL_KEN_V3 §7.1, 2026-11-03: 1.0 -> 1.3).")
(defparameter *ke-noz-scale* 1.5 "Nozarashi's head (from the point to the cap and tassel) scaled about the bar's joint (DUEL_KEN_V3 §7.3, 2026-11-03: 1.0 -> 1.5); drawn only, the weapon's :length (the reach the sim and the FK test use) stays 1.62.")
(defparameter *ke-noz-band* 1.5 "The edge's pale band depth into the blade (DUEL_KEN_V3 §7.3, 2026-11-03: 1.0 -> 1.5, about half the blade's width).")
(defparameter *ke-haft-sag* 0.06 "How far the haft's butt end sags away from the edge, m (DUEL_KEN_V3 §7.1, 2026-11-03: 0 -> 0.06).")

;; the head widened toward the edge (the user 2026-11-03, DUEL_KEN_V3 §7: 「請從 5 開始將刀加寬，從刀尖到護套的加寬程度分別約
;; 由 1.3 到 1.1 倍」): z pushed away from the spine line by K, 1.3 at the point's end (y -0.183) down to 1.1 at the cap's foot
;; (y 1.425), linear, then held (§7.4–§7.5 tried 0.88 there, §7.6 back to 1.1); the spine line (0.07 at y 0.3, 0.086 at 1.62) stays, so the bar's joint and the blade's length
;; (the reach) do not move. Drawn only.
(defparameter *ke-noz-k-cap* 1.1 "The widening factor at the cap's end (DUEL_KEN_V3 §7.4–§7.6, 2026-11-03: 1.1 -> 0.88 -> 1.1, back: 「抱歉，回到縮減前的版本」).")

(defparameter *ke-noz-mid* 1.1 "The widening at the head's middle on top of KE-NOZ-K, falling to 1 at the point's end and the cap's foot (DUEL_KEN_V3 §7.7, 2026-11-03: 1.0 -> 1.2 -> 1.1, 「改成 1.1 倍」).")
(defparameter *ke-noz-k-end* 1.425 "Where the taper reaches *KE-NOZ-K-CAP*, y along the head: the cap's foot (DUEL_KEN_V3 §7.5–§7.6, 2026-11-03: 1.425 -> 0.72 -> 1.425, back).")

(defun ke-noz-k (y)
  "The widening factor at Y along Nozarashi's head: 1.3 at the point's end, linear to *KE-NOZ-K-CAP* at *KE-NOZ-K-END*, held."
  (let ((k (+ 1.3 (* (- y -0.183) (/ (- *ke-noz-k-cap* 1.3) (- *ke-noz-k-end* -0.183))))))
    (* (max (min 1.3 *ke-noz-k-cap*) (min (max 1.3 *ke-noz-k-cap*) k))
       ;; the middle widened (「將中段加寬 1.2 倍」, §7.7): a sine bump, *KE-NOZ-MID* halfway from the point's end to the cap's foot, 1 at both
       (let ((u (max 0.0 (min 1.0 (/ (- y -0.183) (- 1.425 -0.183))))))
         (+ 1.0 (* (- *ke-noz-mid* 1.0) (sin (* 3.1415927 u))))))))

(defun ke-noz-widen (y z)
  "Z on Nozarashi's head at Y, widened about the spine line by KE-NOZ-K."
  (let ((s (+ 0.07 (* (- y 0.3) (/ 0.016 1.32)))))
    (+ s (* (- z s) (ke-noz-k y)))))

;; Nozarashi's head up to END along the blade (1.62: whole; the Bankai's broken cleaver cuts it short): the black bar; the
;; body, the point, the pale band and its chips (turned: WITH-KE-TILT, widened: KE-NOZ-WIDEN), each profile clipped at the plane
;; y = END; then the haft and the butt
(defun ke-mb-noz-head (mb end &optional (haft 1.0))
  "Nozarashi's head cut at END up the blade; the haft HAFT times its length, lengthened downward (the top kept at 0.08)."
  (flet ((prism (profile x0 x1 &optional wide)
           (let ((pts (loop with out = nil
                            for ((y0 z0) (y1 z1)) on (append profile (list (first profile)))
                            while y1
                            do (when (<= y0 end) (push (list y0 z0) out))
                               (when (or (and (< y0 end) (> y1 end)) (and (> y0 end) (< y1 end)))
                                 (push (list end (+ z0 (* (- z1 z0) (/ (- end y0) (- y1 y0))))) out))
                            finally (return (nreverse out)))))
             (when wide (setf pts (loop for (y z) in pts collect (list y (ke-noz-widen y z)))))
             (when (>= (length pts) 3) (ke-mb-prism mb pts x0 x1)))))
    (mbc mb #x1C1C20)
    (prism '((0.07 -0.025) (0.4 0.045) (0.4 0.115) (0.07 0.025)) -0.022 0.022)   ; the black slanted bar: haft to head
    (with-ke-tilt (mb)                                   ; the head, turned about the bar's joint
    ;; the body, then the point (two convex prisms)
    (prism '((0.3 0.07) (1.62 0.086) (1.62 0.611) (1.426 0.605) (1.069 0.596) (0.771 0.575) (0.532 0.545)
             (0.323 0.462) (0.174 0.387))
           -0.021 0.021 t)
    (prism '((0.174 0.387) (-0.034 0.283) (-0.183 0.209) (0.01 0.185) (0.26 0.17)) -0.018 0.018 t)   ; (its back on the body's)
    ;; the edge's pale band, both faces: light and grey stripes, the inner line ragged (each stripe its own depth)
    (loop for ((y0 z0 d0) (y1 z1 d1)) on '((-0.183 0.209 0.02) (-0.034 0.283 0.06) (0.115 0.358 0.107) (0.323 0.462 0.133)
                                            (0.532 0.545 0.16) (0.771 0.575 0.14) (1.069 0.596 0.167) (1.426 0.605 0.147))
          for k from 0
          while y1
          do (mbc mb (if (evenp k) #xE2E4E8 #x9EA0A8))
             (setf d0 (* d0 *ke-noz-band*) d1 (* d1 *ke-noz-band*))   ; (deeper into the blade, §7.3)
             (prism (list (list y0 z0) (list y1 z1) (list (+ y1 (* 0.4 d1)) (- z1 d1)) (list (+ y0 (* 0.4 d0)) (- z0 d0)))
                    -0.023 0.023 t))
    (mbc mb #x1C1C20)                                    ; chips bitten out of the edge
    (loop for (y z) in '((0.22 0.415) (0.65 0.562) (1.0 0.594) (1.3 0.603))
          when (< y (- end 0.05))
            do (mb-at (mb :y y :z (ke-noz-widen y z) :roll 0.6) (mb-box mb 0.05 0.03 0.03))))
    ;; the haft sags away from the edge toward the butt (the user 2026-11-03, DUEL_KEN_V3 §7.1: 「1 加長並做出些微弧度向下彎」):
    ;; z = -*KE-HAFT-SAG* x (u / len)^2, u the distance below its top (0.08), drawn as 8 straight pieces along that curve
    (let* ((len (* 0.76 haft)) (drop (- len 0.76)))
      (flet ((sag (y) (let ((u (/ (- 0.08 y) len))) (- (* *ke-haft-sag* u u))))
             (tilt (y) (atan (/ (* 2 *ke-haft-sag* (- 0.08 y)) (* len len)))))
        (mbc mb #xECECE8)                                ; the long white-wrapped haft
        (loop with n = 8 for i below n                   ; (it stops short of the head: the bar joins them)
              for y = (- 0.08 (* (+ i 0.5) (/ len n)))
              do (mb-at (mb :y y :z (sag y) :pitch (tilt y)) (mb-box mb 0.05 (* 1.02 (/ len n) (/ 1 (cos (tilt y)))) 0.05)))
        (mbc mb #x6A6A70)
        (loop for i below (round (* 8 haft))
              for y = (- 0.03 (* i 0.085))
              do (mb-at (mb :y y :z (sag y) :pitch (tilt y)) (mb-at (mb :roll 0.6) (mb-box mb 0.054 0.006 0.054))))
        (mbc mb #x16161A)                                ; the black butt
        (let ((y (- -0.67 drop)))
          (mb-at (mb :y y :z (sag y) :pitch (tilt y)) (mb-bevel-box mb 0.058 0.06 0.058 0.008)))))))

;; where the right hand holds the haft (the user 2026-11-03: 「始解握住刀柄的位置應該要在介於靠近白色上緣 1/5~2/5 的位置」,
;; DUEL_KEN_V3 §12): a fraction of the white haft from its top (0.08, the bar's end); the whole weapon slides up the hand that far
(defparameter *ke-noz-grip* 0.3 "Nozarashi's grip: the fraction of the white haft below its top where the right hand holds (DUEL_KEN_V3 §12, 2026-11-03: 0.08 -> 0.3, the middle of 1/5-2/5).")
(defun ke-noz-grip-y () "How far the weapon slides out of the hand for *KE-NOZ-GRIP*, m (0.22)." (- (* *ke-noz-grip* 0.76 *ke-noz-haft*) 0.08))

(defweapon :nozarashi (:length 2.52 :base 0.42)         ; the haft below the grip, the head above it; :length the drawn far end
                                                        ; (1.62 -> 2.3, the head x1.5: DUEL_KEN_V3 §7.8; -> 2.52, + KE-NOZ-GRIP-Y
                                                        ; 0.22, §12; literal: the host FK test reads it unevaluated), the reach follows it
  (:solid (mb-at (mb :y (ke-noz-grip-y))
          (ke-mb-noz-head mb 1.62 *ke-noz-haft*)
          (with-ke-tilt (mb)                             ; the cap and the tassel ride on the turned head
          (mbc mb #x9C9478)                              ; the khaki cap over the far end, its stepped foot
          (mb-at (mb :y 1.525 :z (ke-noz-widen 1.525 0.348)) (mb-bevel-box mb 0.07 0.2 (* 0.56 (ke-noz-k 1.525)) 0.012))   ; (with the head)
          (mb-at (mb :y 1.39 :z (ke-noz-widen 1.39 0.14)) (mb-bevel-box mb 0.06 0.09 0.13 0.01))
          (mbc mb #x6E6852)                              ; its groove
          (mb-at (mb :y 1.455 :z (ke-noz-widen 1.455 0.36)) (mb-box mb 0.074 0.018 (* 0.46 (ke-noz-k 1.455))))
          (mbc mb #x2F4A35)                              ; the tassel (candidate B, the user 2026-10-09: 「調整始解的流蘇成 B
          (mb-at (mb :y 1.54 :z 0.06) (mb-box mb 0.035 0.06 0.045))   ; 選項」): a dark green knot at the cap's
          ;; (spine corner) the strands: each a cone whose point sits in the knot, its base fanning out away from the blade
          ;; (each turned about the knot, not its middle: the head up, the tail spread; the user: 「當時流蘇的頭尾掛反了」)
          (loop for (ax ay) in '((0.0 0.0) (0.22 0.1) (-0.22 0.1) (0.14 -0.18) (-0.14 -0.18) (0.0 0.24))
                do (let* ((n (sqrt (+ (* ax ax) (* ay ay) 1.0))) (ux (/ (- ax) n)) (uy (/ (- ay) n)) (uz (/ 1.0 n)) (h 0.42))
                     (mb-at (mb :x (* -0.5 h ux) :y (- 1.51 (* 0.5 h uy)) :z (- 0.04 (* 0.5 h uz))
                                            :pitch (atan uz uy) :roll (asin (- ux)))
                       (mb-cone mb 0.026 h :segments 4))))))))

;; the Bankai's broken cleaver (DUEL_KEN_REWORK §8; the user 2026-10-09: 「卍解刀身直接沿用始解刀身，然後將我打 X 的地方移除
;;變成斷刀」): Nozarashi's own head, haft and colours, snapped at 0.9 m up the blade: the cap, the tassel and the far
;; 0.72 m gone, the end cut square and chipped; its haft 1.3 times as long, lengthened downward (the user: 「將刀柄向下
;; 伸長，使其變成原本的 1.3 倍」).
;; Its own builder since 2026-11-04 (the user: 「請先確保改動卍解不會影響到始解武器造型」, DUEL_KEN_V3 §22): a copy of Nozarashi's
;; (WITH-KE-TILT, KE-NOZ-K / -WIDEN, KE-MB-NOZ-HEAD) with its own knobs *KE-BK-*, at the values it had that day, so a change to the
;; Bankai's cleaver never moves the Shikai's and the reverse (until then it shared them, and took the Shikai's §7 reshaping).
(defparameter *ke-bk-haft* 1.69 "The broken cleaver's haft / 0.76 m (its own copy of *KE-NOZ-HAFT*, 2026-11-04; 1.3 -> 1.69, x1.3, the user
the same day: 「幫我將刀柄加長 1.3 倍」, longer downward: 0.99 -> 1.28 m).")
(defparameter *ke-bk-grip* 0.5 "Where the right hand holds its haft: the fraction of the white haft below its top (0.08), as *KE-NOZ-GRIP* (2026-11-04, the
user: 「角色持握 0.5 的位置」; 0 before: the hand at the haft's top).")
(defun ke-bk-grip-y () "How far the broken cleaver slides out of the hand for *KE-BK-GRIP*, m (0.56)." (- (* *ke-bk-grip* 0.76 *ke-bk-haft*) 0.08))
(defparameter *ke-bk-size* 0.9 "The whole broken cleaver (haft, bar, head) scaled about the hand (2026-11-04, the user: 「整體縮小成 0.8 倍，刀身額外再
縮小成 0.8 倍」, then 「兩個倍率都從 0.8 改成 0.9」; 1 before).")
(defparameter *ke-bk-scale* 0.6075 "Its head scaled about the bar's joint (copy of *KE-NOZ-SCALE*, 2026-11-04; 1.5 -> 0.45, x0.3, the user the same day:
「刀身縮小至 0.3 倍」; -> 0.675, x1.5: 「刀身放大 1.5 倍」; -> 0.54, x0.8: 「刀身額外再縮小成 0.8 倍」, on top of *KE-BK-SIZE*; -> 0.6075, x0.9: 「兩個倍率都從 0.8 改成 0.9」); the black bar
and the haft keep their size.")
(defparameter *ke-bk-bar* 0.75 "The black slanted bar's length (haft to head) / Nozarashi's 0.34 m, its slant kept, the head moved down with its
joint (2026-11-04, the user: 「斜槓連接處縮短成 0.75」; 1 before).")
(defun ke-bk-joint-y () "The bar's joint with the head, y (0.4 at *KE-BK-BAR* 1)." (+ 0.07 (* 0.33 *ke-bk-bar*)))
(defun ke-bk-joint-z () "... and z (0.08 at 1)." (* 0.08 *ke-bk-bar*))
(defparameter *ke-bk-band* 1.5 "Its edge band depth (copy of *KE-NOZ-BAND*, 2026-11-04).")
(defparameter *ke-bk-sag* 0.06 "Its haft's sag at the butt, m (copy of *KE-HAFT-SAG*, 2026-11-04).")
(defparameter *ke-bk-width* 0.64 "The broken cleaver's edge stands this far from its spine all along, parallel (2026-11-04, the user: 「修改刀身形狀，使刀刃
與刀脊平行」: the width it had at the break, where the copied Nozarashi taper had widened it from 0.32 at the foot; *KE-BK-K-CAP* /
-MID / -K-END and its widening gone).")
(defmacro with-ke-bk-tilt ((mb) &body body)
  "WITH-KE-TILT for the broken cleaver: BODY turned *KE-BK-PITCH* about the bar's joint, 0.05 m down, scaled *KE-BK-SCALE*; the joint
where the *KE-BK-BAR* bar ends."
  `(mb-at (,mb :y (ke-bk-joint-y) :z (- (ke-bk-joint-z) 0.05) :pitch *ke-bk-pitch* :s *ke-bk-scale*)
     (mb-at (,mb :y -0.4 :z -0.08) ,@body)))

(defun ke-bk-spine (y) "The spine line's z at Y on the broken cleaver's head: 0.07, straight (Nozarashi's rose 0.016 over its 1.32 m; flat since
2026-11-04, parallel to the haft)." (declare (ignore y)) 0.07)
(defparameter *ke-bk-hook* 0.5 "How far the beak's point droops below the edge line, x its scaled droop (2026-11-04, the user: 「減少刀尖下彎的程度」; 1 before:
0.24 m at the point -> 0.12; 0 a moment for 「幫我改成跟刀柄平行」, which meant the edge: 「刀尖依舊輕微下彎，刀刃則改成與刀柄平行」, back to 0.5).")
(defparameter *ke-bk-pitch* 0.0 "The head's turn about the bar's joint, radians (Nozarashi's -0.0873, 5 degrees, copied; 0 the same day, 「刀刃則改成與刀柄平行」:
the edge and the spine parallel to the haft).")
(defun ke-bk-edge (y) "The parallel edge's z at Y (*KE-BK-WIDTH* out from the spine)." (+ (ke-bk-spine y) *ke-bk-width*))
(defun ke-bk-beak (y z)
  "Z of a point (Y Z) of Nozarashi's beak (the point at the blade's foot) on the broken cleaver: scaled out from the spine to meet the
parallel edge at y 0.174; below that (the point's side) pulled toward the edge line, *KE-BK-HOOK* of its droop left."
  (let ((zs (+ (ke-bk-spine y) (* (- z (ke-bk-spine y)) (/ *ke-bk-width* (- 0.387 (ke-bk-spine 0.174)))))))
    (if (< y 0.174) (- (ke-bk-edge y) (* (- (ke-bk-edge y) zs) *ke-bk-hook*)) zs)))

(defun ke-mb-bk-head (mb end &optional (haft 1.0))
  "KE-MB-NOZ-HEAD for the broken cleaver: the head cut at END up the blade, the haft HAFT times 0.76 m, longer downward."
  (flet ((prism (profile x0 x1)
           (let ((pts (loop with out = nil
                            for ((y0 z0) (y1 z1)) on (append profile (list (first profile)))
                            while y1
                            do (when (<= y0 end) (push (list y0 z0) out))
                               (when (or (and (< y0 end) (> y1 end)) (and (> y0 end) (< y1 end)))
                                 (push (list end (+ z0 (* (- z1 z0) (/ (- end y0) (- y1 y0))))) out))
                            finally (return (nreverse out)))))
             (when (>= (length pts) 3) (ke-mb-prism mb pts x0 x1)))))
    (mbc mb #x1C1C20)
    (let ((y (ke-bk-joint-y)) (z (ke-bk-joint-z)))       ; the black slanted bar: haft to head, *KE-BK-BAR* long
      (prism (list '(0.07 -0.025) (list y (- z 0.035)) (list y (+ z 0.035)) '(0.07 0.025)) -0.022 0.022))
    (with-ke-bk-tilt (mb)                                   ; the head, turned about the bar's joint
    ;; the body, then the point (two convex prisms)
    (prism (list (list 0.3 (ke-bk-spine 0.3)) (list 1.62 (ke-bk-spine 1.62)) (list 1.62 (ke-bk-edge 1.62)) (list 0.174 (ke-bk-edge 0.174)))
           -0.021 0.021)                                ; (the body: spine and edge parallel)
    (prism (mapcar (lambda (p) (list (first p) (ke-bk-beak (first p) (second p))))
                   '((0.174 0.387) (-0.034 0.283) (-0.183 0.209) (0.01 0.185) (0.26 0.17)))
           -0.018 0.018)                                ; (the beak, its back on the body's)
    ;; the edge's pale band, both faces: light and grey stripes, the inner line ragged (each stripe its own depth)
    (loop for ((y0 z0 d0) (y1 z1 d1)) on '((-0.183 0.209 0.02) (-0.034 0.283 0.06) (0.115 0.358 0.107) (0.323 0.462 0.133)
                                            (0.532 0.545 0.16) (0.771 0.575 0.14) (1.069 0.596 0.167) (1.426 0.605 0.147))
          for k from 0
          while y1
          do (mbc mb (if (evenp k) #xE2E4E8 #x9EA0A8))
             (setf d0 (* d0 *ke-bk-band*) d1 (* d1 *ke-bk-band*))   ; (deeper into the blade, §7.3)
             (setf z0 (if (< y0 0.174) (ke-bk-beak y0 z0) (ke-bk-edge y0)) z1 (if (< y1 0.174) (ke-bk-beak y1 z1) (ke-bk-edge y1)))   ; (on the edge)
             (prism (list (list y0 z0) (list y1 z1) (list (+ y1 (* 0.4 d1)) (- z1 d1)) (list (+ y0 (* 0.4 d0)) (- z0 d0)))
                    -0.023 0.023))
    (mbc mb #x1C1C20)                                    ; chips bitten out of the edge
    (loop for (y z) in '((0.22 0.415) (0.65 0.562) (1.0 0.594) (1.3 0.603))
          when (< y (- end 0.05))
            do (mb-at (mb :y y :z (ke-bk-edge y) :roll 0.6) (mb-box mb 0.05 0.03 0.03))))
    ;; the haft sags away from the edge toward the butt: z = -*KE-BK-SAG* x (u / len)^2, 8 straight pieces
    (let* ((len (* 0.76 haft)) (drop (- len 0.76)))
      (flet ((sag (y) (let ((u (/ (- 0.08 y) len))) (- (* *ke-bk-sag* u u))))
             (tilt (y) (atan (/ (* 2 *ke-bk-sag* (- 0.08 y)) (* len len)))))
        (mbc mb #xECECE8)                                ; the long white-wrapped haft
        (loop with n = 8 for i below n                   ; (it stops short of the head: the bar joins them)
              for y = (- 0.08 (* (+ i 0.5) (/ len n)))
              do (mb-at (mb :y y :z (sag y) :pitch (tilt y)) (mb-box mb 0.05 (* 1.02 (/ len n) (/ 1 (cos (tilt y)))) 0.05)))
        (mbc mb #x6A6A70)
        (loop for i below (round (* 8 haft))
              for y = (- 0.03 (* i 0.085))
              do (mb-at (mb :y y :z (sag y) :pitch (tilt y)) (mb-at (mb :roll 0.6) (mb-box mb 0.054 0.006 0.054))))
        (mbc mb #x16161A)                                ; the black butt
        (let ((y (- -0.67 drop)))
          (mb-at (mb :y y :z (sag y) :pitch (tilt y)) (mb-bevel-box mb 0.058 0.06 0.058 0.008)))))))

(defweapon :ke-broken (:length 1.06 :base 0.63)         ; :length the drawn far end ((the break 0.62 up the head frame + KE-BK-GRIP-Y 0.56)
                                                        ; x *KE-BK-SIZE* 0.9; literal: the host FK test reads it unevaluated), :base
                                                        ; the head's foot (the trail's start)
  (:solid (mb-at (mb :s *ke-bk-size*) (mb-at (mb :y (ke-bk-grip-y))   ; all of it x0.9 about the hand (§25), held halfway down the haft (§23)
          (ke-mb-bk-head mb 0.9 *ke-bk-haft*)            ; the haft 1.69 times Nozarashi's first, longer below (0.76 -> 1.28 m)
          (with-ke-bk-tilt (mb)
            (mbc mb #x1C1C20)                            ; the square break, chipped
            (loop for (z r) in '((0.13 0.5) (0.3 -0.4) (0.46 0.7))
                  do (mb-at (mb :y 0.9 :z z :roll r) (mb-box mb 0.05 0.045 0.05))))))))

;;; ---------------------------------------------------------------- poses
(defpose :ke-stance ()
  (:root :u -0.06) (:pelvis :twist 18) (:spine :flex 10) (:chest :twist -12) (:head :flex -6 :twist -6)
  (:arm-r :flex 30 :side 30) (:elbow-r :flex 45) (:hand-r :flex -55)
  (:arm-l :flex 10 :side 22) (:elbow-l :flex 30)
  (:thigh-r :flex -12 :side 12) (:thigh-l :flex 25 :side 8) (:knee-r :flex 25) (:knee-l :flex 30))

;; the idle (DUEL_KEN_REWORK §5.2): the blade hanging from the loose right hand, the tip trailing near the floor behind him,
;; the free left hand half open; the strikes still start from the pose (the blend takes the blade up)
(defclip :ke-stance (2.0 :loop t :base :ke-stance)
  (0 (:arm-r :flex -12 :side 14) (:elbow-r :flex 12) (:hand-r :flex -115 :twist 0) (:arm-l :flex 8 :side 26) (:elbow-l :flex 25))
  (1.0 (:chest :flex 3) (:root :u -0.07) (:arm-r :flex -14 :side 15) (:hand-r :flex -112)))

;;; ---------------------------------------------------------------- base kit (§5.2 table)
;;; One-handed wild swings; the left hand joins the grip only for the two-handed Flash cuts.
;; the base strikes (DUEL_KEN_REWORK §5.2, the user 2026-10-08: each its own arc, the whole body behind it; frame data,
;; reaches and hit volumes unchanged). J1 ARAGIRI: the lunging hack: cocked behind the head, weight back, then down from
;; the right shoulder to the left hip as the right foot lunges; ends low and open
(defstrike :ke-q1 (7 3 12 :base :ke-stance)
  (0)
  (3 (:pelvis :twist 30) (:chest :twist -45) (:spine :flex -6) (:arm-r :flex 165 :side 50) (:elbow-r :flex 75)
     (:hand-r :twist -15 :flex -30) (:arm-l :flex 40 :side 30) (:elbow-l :flex 40) (:root :u -0.02 :f -0.05) (:head :twist 12))
  (5 (:chest :twist -50) (:arm-r :flex 170 :side 52) (:elbow-r :flex 85) (:root :f -0.07))                   ; held
  (:s :snap (:pelvis :twist -10) (:chest :twist 40) (:spine :flex 28) (:arm-r :flex 45 :side -15) (:elbow-r :flex 8)
      (:hand-r :twist -15 :flex -80) (:arm-l :flex -25 :side 35) (:elbow-l :flex 20) (:root :f 0.38 :u -0.12)
      (:thigh-r :flex 55 :side 6) (:knee-r :flex 50) (:thigh-l :flex -18) (:knee-l :flex 30) (:head :twist -8))
  (:a (:chest :twist 52) (:arm-r :flex 28 :side -32) (:spine :flex 32) (:root :f 0.41 :u -0.14))              ; overshoot
  (15 (:chest :twist 48) (:arm-r :flex 30 :side -28) (:spine :flex 28) (:root :f 0.25 :u -0.11))
  (:end :ke-stance))
;; J2 KAESHIGIRI: the sloppy backhand: coiled low on the left, then a rising reverse diagonal out to the right as the hips
;; unwind, the free hand flung out for balance; it follows through up and out
(defstrike :ke-q2 (7 3 13 :base :ke-stance)
  (0)
  (3 (:pelvis :twist -25) (:chest :twist 58) (:spine :flex 18 :side 8) (:arm-r :flex 15 :side -35) (:elbow-r :flex 25)
     (:hand-r :twist 55 :flex -60) (:arm-l :flex 20 :side 20) (:root :u -0.1) (:knees :flex 45) (:head :twist -12))
  (5 (:chest :twist 64) (:arm-r :flex 10 :side -40) (:root :u -0.12))                                        ; held
  (:s :snap (:pelvis :twist 15) (:chest :twist -45) (:spine :flex 4 :side -6) (:arm-r :flex 50 :side 60) (:elbow-r :flex 80)
      (:hand-r :twist 5 :flex -30) (:arm-l :flex 30 :side 75) (:elbow-l :flex 10) (:root :f 0.45 :u -0.04)
      (:thigh-l :flex 38) (:knee-l :flex 38) (:knee-r :flex 20) (:head :twist 10))
  (:a (:chest :twist -58) (:arm-r :flex 105 :side 70) (:spine :flex -4) (:root :f 0.48 :u 0.0))               ; up and out
  (16 (:chest :twist -52) (:arm-r :flex 98 :side 66) (:root :f 0.3))
  (:end :ke-stance))
(defstrike :ke-q3 (11 4 22 :base :ke-stance)           ; spinning cut
  (0)
  (5 (:root :u -0.12 :yaw 0) (:knees :flex 40) (:chest :twist -20) (:arm-r :side 85 :flex 0) (:elbow-r :flex 5)
     (:hand-r :twist -5 :flex -90) (:arm-l :side 60 :flex 10))
  (8 (:root :u -0.16 :yaw -12) (:knees :flex 48) (:chest :twist -28))             ; coiled: held, a little further
  (:s :snap (:root :yaw 360 :u -0.1 :f 0.35) (:chest :twist 30) (:knees :flex 40))
  (:a (:root :yaw 386 :u -0.12 :f 0.38) (:chest :twist 36))                         ; overshoot
  (22 (:root :yaw 374 :u -0.1 :f 0.36) (:chest :twist 32))
  (:end :ke-stance (:root :yaw 360)))
;; J3 KENKA-GERI (docs/duel/DUEL_STRINGS.md §3.3): no school: the rear knee chambered and held, a flat front kick to the gut,
;; leaning back, the sword thrown out wide the other way
(defstrike :ke-kick (8 3 18 :base :ke-stance)          ; J3 KENKA-GERI: the street fighter's front kick
  (0)
  (3 (:root :u 0.02 :f -0.05) (:spine :flex -6) (:chest :twist -10) (:thigh-r :flex 58 :side 4) (:knee-r :flex 96)
     (:thigh-l :flex 12) (:knee-l :flex 20) (:arm-r :flex 38 :side 58) (:elbow-r :flex 22) (:hand-r :flex -40)
     (:arm-l :flex 30 :side 12) (:elbow-l :flex 60) (:head :flex -4))                                ; chambered, held
  (6 (:thigh-r :flex 64) (:knee-r :flex 102) (:spine :flex -9) (:root :f -0.07))
  (:s :snap (:root :f 0.44 :u 0.0) (:spine :flex -18) (:chest :twist 12) (:thigh-r :flex 92 :side 0) (:knee-r :flex 45)
      (:thigh-l :flex -6) (:knee-l :flex 14) (:arm-r :flex 30 :side 95) (:elbow-r :flex 5) (:hand-r :flex -20)
      (:arm-l :flex 40 :side 30) (:elbow-l :flex 40) (:head :flex 6 :twist 6))
  (:a (:root :f 0.47) (:spine :flex -21) (:thigh-r :flex 96) (:knee-r :flex 44))                       ; overshoot
  (18 (:root :f 0.25) (:thigh-r :flex 72) (:knee-r :flex 60) (:spine :flex -13))
  (24 (:root :f 0.23 :u -0.05) (:thigh-r :flex 8) (:knee-r :flex 30) (:spine :flex 4) (:arm-r :flex 32 :side 40) (:elbow-r :flex 40))
  (:end :ke-stance))
;; K1 OBURI: the shoulder-launch chop: the blade up onto the right shoulder, up on the toes and held, then one vertical
;; stroke as he drops into bent knees; the blade bites the floor (one hand: the left thrown back)
(defstrike :ke-f1 (16 4 20 :base :ke-stance)
  (0)
  (6 (:arm-r :flex 110 :side 25 :twist 0) (:elbow-r :flex 130) (:hand-r :twist 0 :flex -90) (:chest :twist -10) (:root :u 0.02))
  (9 (:root :u 0.07 :f -0.05) (:spine :flex -12) (:chest :twist -15) (:arm-r :flex 150 :side 20) (:elbow-r :flex 120)
     (:hand-r :flex -80) (:arm-l :flex 60 :side 30) (:elbow-l :flex 30) (:head :flex -10) (:thigh-r :flex -5) (:knees :flex 8))
  (13 (:root :u 0.09 :f -0.06) (:spine :flex -16) (:arm-r :flex 160 :side 15) (:elbow-r :flex 110))           ; held at the top
  (:s :snap (:root :u -0.3 :f 0.55) (:spine :flex 42) (:chest :twist 10) (:arm-r :flex 75 :side 0) (:elbow-r :flex 0)
      (:hand-r :twist 0 :flex -40) (:arm-l :flex -30 :side 40) (:elbow-l :flex 10) (:thigh-r :flex 60) (:knee-r :flex 70)
      (:thigh-l :flex -10) (:knee-l :flex 60) (:head :flex -15))
  (:a (:spine :flex 50) (:arm-r :flex 40) (:hand-r :flex -55) (:root :u -0.34 :f 0.58))                       ; into the floor
  (28 (:spine :flex 46) (:arm-r :flex 42) (:root :u -0.32 :f 0.56))
  (:end :ke-stance))
;; K2 KIRIAGE: the drag-up launcher: turned, the tip dropped to the floor behind him and dragged as he steps in, then the
;; rising cut in front as the whole body stands up onto the toes
(defstrike :ke-f2 (20 5 28 :base :ke-stance)
  (0)
  (8 (:pelvis :twist 0) (:chest :twist -15) (:spine :flex 30) (:root :u -0.25 :f -0.05) (:knees :flex 55)
     (:arm-r :flex -45 :side 15) (:elbow-r :flex 5) (:hand-r :twist 0 :flex -30) (:arm-l :flex 45 :side 25) (:elbow-l :flex 40)
     (:head :flex -20))                                                                                        ; the tip on the floor behind
  (16 (:root :u -0.3 :f 0.2) (:chest :twist -10) (:spine :flex 34) (:arm-r :flex -50 :side 16) (:thigh-r :flex 30)
      (:thigh-l :flex -20))                                                                                    ; held: stepping in, scraping
  (:s :snap (:pelvis :twist 0) (:root :u 0.05 :f 0.5) (:arm-r :flex 70 :side 5) (:elbow-r :flex 5) (:hand-r :twist 0 :flex -45)
      (:arm-l :flex -20 :side 40) (:spine :flex -10) (:knees :flex 15) (:thigh-r :flex 20) (:thigh-l :flex -10) (:head :flex -15)
      (:chest :twist -10))
  (:a (:arm-r :flex 165) (:hand-r :flex -30) (:spine :flex -26) (:root :u 0.16 :f 0.52) (:head :flex -28))                        ; up on the toes
  (36 (:arm-r :flex 160) (:spine :flex -22) (:root :u 0.1 :f 0.5))
  (:end :ke-stance))
(defclip :ke-stance-hold (1.0 :loop t :base :ke-stance) ; "Kitte miro yo": arms flung wide (blend 6 f in)
  (0 (:root :u -0.02) (:pelvis :twist 0) (:chest :twist 0) (:spine :flex -12) (:head :flex -12 :twist 0)
     (:arms :side 78 :flex 15) (:elbows :flex 15) (:hand-r :twist 0 :flex -90) (:thigh-r :flex -5 :side 14) (:thigh-l :flex 5 :side 14)
     (:knees :flex 20))
  (0.5 (:spine :flex -14) (:arms :side 80) (:root :u -0.03)))
(defstrike :ke-stance-cut (8 4 24 :base :ke-stance)    ; the stance released: a huge cross-body cut
  (0 (:root :u -0.02) (:pelvis :twist 0) (:chest :twist -20) (:spine :flex -12) (:arms :side 78 :flex 15) (:elbows :flex 15)
     (:hand-r :twist 0 :flex -90))
  (4 (:chest :twist -32) (:spine :flex -15) (:arm-r :side 88) (:root :u -0.05))    ; wound further, held
  (6 (:chest :twist -35) (:spine :flex -16) (:root :u -0.06))
  (:s :snap (:chest :twist 75) (:arm-r :flex 80 :side 10) (:hand-r :twist 5 :flex -85) (:root :f 0.55 :u -0.17) (:spine :flex 22)
      (:thigh-l :flex 52) (:knee-l :flex 57) (:arm-l :side 40 :flex 20))
  (:a (:chest :twist 90) (:arm-r :flex 72 :side -14) (:spine :flex 25) (:root :f 0.6 :u -0.19))   ; overshoot
  (20 (:chest :twist 84) (:arm-r :flex 75 :side -10) (:spine :flex 22) (:root :f 0.57 :u -0.17))
  (:end :ke-stance))
;; SP1 BUTTAGIRU: the leap overhead hack, one hand: knees tucked, the blade cocked behind his head, the left arm out, then
;; a one-handed vertical drop that cracks the floor
(defstrike :ke-buttagiru (22 4 26 :base :ke-stance)
  (0)
  (6 (:root :u -0.3) (:knees :flex 80) (:thighs :flex 60) (:spine :flex 30) (:arm-r :flex 30 :side 30) (:elbow-r :flex 60)
     (:arm-l :flex 30 :side 30) (:elbow-l :flex 40))
  (12 (:root :u 0.6) (:thighs :flex 70) (:knees :flex 100) (:arm-r :flex 170 :side 30) (:elbow-r :flex 100) (:hand-r :twist 0 :flex -40)
      (:arm-l :flex 70 :side 70) (:elbow-l :flex 10) (:spine :flex -22) (:head :flex -15))
  (17 (:root :u 0.75) (:spine :flex -27) (:elbow-r :flex 115) (:head :flex -18))
  (19 (:root :u 0.76) (:spine :flex -29))                                                                      ; hang at the apex
  (:s :snap (:root :u -0.37 :f 0.42) (:spine :flex 55) (:arm-r :flex 25 :side 0) (:elbow-r :flex 0) (:hand-r :twist 0 :flex -40)
      (:arm-l :flex -35 :side 45) (:elbow-l :flex 10) (:knees :flex 92) (:thighs :flex 71) (:head :flex -30))
  (:a (:spine :flex 60) (:root :u -0.4 :f 0.44))                                                              ; overshoot
  (34 (:spine :flex 56) (:root :u -0.37 :f 0.42))
  (:end :ke-stance))
(defclip :ke-charge (0.4 :loop t :base :ke-stance)     ; SP2 dash: blade low and back, charging
  (0 (:spine :flex 28) (:head :flex -25) (:chest :twist -20) (:arm-r :flex -40 :side 35) (:elbow-r :flex 15) (:hand-r :twist 150 :flex 10)
     (:thigh-r :flex 55) (:knee-r :flex 25) (:thigh-l :flex -35) (:knee-l :flex 50) (:root :u -0.1))
  (0.2 (:thigh-l :flex 55) (:knee-l :flex 25) (:thigh-r :flex -35) (:knee-r :flex 50) (:root :u -0.05)))
(defstrike :ke-flurry (4 36 24 :base :ke-stance)       ; cuts at f4 10 16 22 28, launcher at f40
  (0 (:chest :twist -30) (:arm-r :flex 150 :side 35) (:elbow-r :flex 30) (:hand-r :twist -15 :flex -15))
  (4 :snap (:arm-r :flex 40 :side -10) (:elbow-r :flex 10) (:hand-r :twist -15 :flex -75) (:chest :twist 40) (:spine :flex 20))
  (6 (:chest :twist 46) (:arm-r :flex 34 :side -14) (:spine :flex 22))              ; each cut held 2 f past its extreme
  (10 :snap (:chest :twist -55) (:arm-r :side 90 :flex 30) (:hand-r :twist 5 :flex -70) (:spine :flex 10))
  (12 (:chest :twist -61) (:arm-r :side 95 :flex 27) (:spine :flex 11))
  (16 :snap (:chest :twist 50) (:arm-r :flex 60 :side -15) (:hand-r :twist -15 :flex -75) (:spine :flex 22))
  (18 (:chest :twist 56) (:arm-r :flex 54 :side -19) (:spine :flex 24))
  (22 :snap (:chest :twist -60) (:arm-r :side 95 :flex 40) (:hand-r :twist 5 :flex -70) (:spine :flex 12))
  (24 (:chest :twist -66) (:arm-r :side 100 :flex 37) (:spine :flex 13))
  (28 :snap (:chest :twist 55) (:arm-r :flex 45 :side -20) (:hand-r :twist -15 :flex -75) (:spine :flex 25))
  (30 (:chest :twist 60) (:arm-r :flex 40 :side -23) (:spine :flex 27))
  (34 (:root :u -0.3) (:arm-r :flex -30 :side 20) (:hand-r :twist 155 :flex 15) (:knees :flex 60) (:spine :flex 30) (:chest :twist 20))
  (37 (:root :u -0.34) (:arm-r :flex -34 :side 22) (:knees :flex 64) (:spine :flex 33) (:chest :twist 24))
  (40 :snap (:root :u 0.12) (:arm-r :flex 172 :side 5) (:hand-r :twist -155 :flex 15) (:spine :flex -22) (:knees :flex 10)
      (:head :flex -25) (:chest :twist 0))
  (46 (:arm-r :flex 178) (:spine :flex -27) (:root :u 0.16))                         ; overshoot
  (52 (:arm-r :flex 176) (:spine :flex -23) (:root :u 0.12))
  (:end :ke-stance))
(defclip :ke-breaker (0.4 :loop t :base :ke-stance)    ; Breaker aura dash: shoulder first
  (0 (:spine :flex 25) (:chest :twist 45) (:head :twist -35 :flex -15) (:arm-l :flex 20 :side 10) (:elbow-l :flex 90)
     (:arm-r :flex -20 :side 25) (:hand-r :twist 150 :flex 10)
     (:thigh-r :flex 50) (:knee-r :flex 25) (:thigh-l :flex -30) (:knee-l :flex 50) (:root :u -0.1))
  (0.2 (:thigh-l :flex 50) (:knee-l :flex 25) (:thigh-r :flex -30) (:knee-r :flex 50) (:root :u -0.05)))
(defstrike :ke-shoulder (8 4 18 :base :ke-stance)      ; shoulder charge
  (0 (:spine :flex 25) (:chest :twist 45) (:head :twist -35 :flex -15) (:arm-l :flex 20 :side 10) (:elbow-l :flex 90) (:root :u -0.1))
  (3 (:spine :flex 30) (:chest :twist 55) (:root :u -0.15 :f -0.08) (:thigh-r :flex 10) (:knees :flex 40))   ; coiled back, held
  (5 (:spine :flex 32) (:chest :twist 58) (:root :u -0.16 :f -0.1))
  (:s :snap (:spine :flex 12) (:chest :twist 70) (:shoulder-l :flex 20) (:arm-l :flex 10 :side 30) (:elbow-l :flex 100)
      (:root :f 0.7 :u -0.18) (:thigh-l :flex 58) (:knee-l :flex 45) (:thigh-r :flex -28) (:knee-r :flex 20) (:head :twist -40))
  (:a (:spine :flex 8) (:chest :twist 76) (:root :f 0.78 :u -0.2) (:thigh-r :flex -32))     ; overshoot
  (18 (:spine :flex 11) (:chest :twist 72) (:root :f 0.74 :u -0.18))
  (:end :ke-stance))
(defclip :ke-kikon (1.9 :base :ke-stance)              ; three reckless cuts, laughing; the last goes through
  (0)
  (0.25 (:chest :twist -30) (:arm-r :flex 155 :side 35) (:elbow-r :flex 30) (:hand-r :twist -15 :flex -15))
  (0.35 :snap (:arm-r :flex 40 :side -10) (:elbow-r :flex 10) (:hand-r :twist -15 :flex -75) (:chest :twist 40) (:spine :flex 22)
        (:root :f 0.3))
  (0.65 (:chest :twist 60) (:arm-r :side -15 :flex 75) (:elbow-r :flex 15) (:hand-r :twist 55 :flex -80) (:spine :flex 10))
  (0.75 :snap (:chest :twist -60) (:arm-r :side 90 :flex 30) (:hand-r :twist 5 :flex -70) (:root :f 0.5))
  (1.05 (:root :u 0.05 :f 0.5) (:arms :flex 176 :side 5) (:elbows :flex 20) (:hand-r :twist 0 :flex -50) (:spine :flex -15)
        (:chest :twist 0) (:head :flex -30))
  (1.2 :snap (:root :u -0.35 :f 1.4) (:spine :flex 58) (:arms :flex 20 :side 0) (:elbows :flex 5) (:hand-r :twist -10 :flex -35)
       (:knees :flex 85) (:thighs :flex 65) (:head :flex -35))
  (1.5 (:root :u -0.2 :f 1.4) (:spine :flex -15) (:head :flex -40) (:arm-l :side 40 :flex 10) (:knees :flex 40) (:thighs :flex 30))
  (1.9 :ke-stance (:root :f 1.4)))

;;; ---------------------------------------------------------------- intro / win
(defpose :ke-shoulder-rest (:base :ke-stance)          ; the blade resting on his right shoulder, blade pointing back
  (:pelvis :twist 10) (:chest :twist -5) (:spine :flex 2) (:head :flex -10 :twist 10)
  (:arm-r :flex 110 :side 25 :twist 0) (:elbow-r :flex 130) (:hand-r :twist 0 :flex -90)
  (:arm-l :flex 5 :side 18) (:elbow-l :flex 20))
;; the run set (every form: the blade on his shoulder, TYBW's walk-in): forward run, back-skate, side slides
(defrun :ke-shoulder-rest :ke-run :ke-skate-b :ke-slide-r :ke-slide-l)
(defclip :ke-intro (2.0 :base :ke-shoulder-rest)       ; grin, sword on the shoulder, a laugh, then ready
  (0) (0.7 (:head :flex -30) (:spine :flex -8)) (0.9 (:head :flex -25)) (1.1 (:head :flex -32)) (1.4 (:head :flex -12))
  (2.0 :ke-stance))
(defclip :ke-win (2.0 :base :ke-shoulder-rest)         ; laughing, holds
  (0) (0.5 (:head :flex -35) (:spine :flex -12) (:arm-l :flex 10 :side 30)) (0.8 (:head :flex -28)) (1.1 (:head :flex -36))
  (1.6 (:head :flex -20) (:spine :flex -4)) (2.0 (:head :flex -20) (:spine :flex -4)))

;;; ---------------------------------------------------------------- awakening: NOME, NOZARASHI
(defpose :ke-n-stance (:base :ke-stance)               ; Nozarashi: the cleaver across the right shoulder
  (:pelvis :twist 15) (:chest :twist -8) (:spine :flex 6) (:head :flex -8)
  (:arm-r :flex 95 :side 30) (:elbow-r :flex 120) (:hand-r :twist 0 :flex -85)
  (:arm-l :flex 15 :side 22) (:elbow-l :flex 25))
;; the NOME release (the awakening's first beat): head down, the grin, then head thrown back and the left arm flung
;; wide as the reiatsu bursts (0.3 s; the cinematic plays it at 2/3 speed: the burst on its frame 26)
(defclip :ke-release (0.5 :base :ke-stance)
  (0)
  (0.2 (:head :flex 22 :twist 6) (:spine :flex 16) (:chest :twist 8) (:arm-l :flex 30 :side 10) (:elbow-l :flex 70))
  (0.3 :snap (:arm-l :flex 110 :side 70) (:elbow-l :flex 10) (:head :flex -25 :twist -10) (:spine :flex -15) (:chest :twist -15))
  (0.5 (:arm-l :flex 90 :side 75) (:head :flex -30) (:spine :flex -18)))
(defclip :ke-nome (0.7 :base :ke-stance)               ; "Nome": blade up (weapon -> :nozarashi at 0.35 s), then down
  (0 (:arm-l :flex 90 :side 75) (:head :flex -30) (:spine :flex -18))
  (0.3 (:arm-r :flex 170 :side 10) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -10) (:arm-l :flex 40 :side 30) (:head :flex -30))
  (0.45 (:arm-r :flex 172))
  (0.7 :ke-n-stance))
;; O in Nozarashi, LEAP CLEAVE: 8 f of crouch, then airborne, the cleaver raised over the head (held while
;; the leap lasts; the strike is :ke-stance-cut)
(defclip :ke-n-leap (0.7 :base :ke-n-stance)
  (0)
  (0.13 (:root :u -0.35) (:knees :flex 85) (:thighs :flex 65) (:spine :flex 32) (:arms :flex 35) (:elbows :flex 60))
  (0.25 (:root :u 0.1) (:thighs :flex 55) (:knees :flex 90) (:arms :flex 175 :side 8) (:elbows :flex 25)
        (:hand-r :twist 0 :flex -50) (:spine :flex -18) (:head :flex -18))
  (0.7 (:root :u 0.1) (:thighs :flex 50) (:knees :flex 85) (:arms :flex 178 :side 6) (:spine :flex -22)))
;; KATATE's rest (DUEL_KEN_REWORK §6.2): the cleaver's haft on the right shoulder, the fist in front of the chest, the head
;; up behind him (the canon carry); the idle and every KATATE strike start and end here
(defpose :ke-k-rest (:base :ke-n-stance)
  (:arm-r :flex 35 :side 25 :twist 0) (:elbow-r :flex 110) (:hand-r :flex 25 :twist 0) (:arm-l :flex 10 :side 25) (:elbow-l :flex 30))
(defclip :ke-n-stance (2.0 :loop t :base :ke-k-rest)
  (0) (1.0 (:chest :flex 3) (:root :u -0.07) (:arm-r :flex 33)))
;; Nozarashi v2, the cups read from the grip: cup 1 one hand (:ke-n-stance); cups 2 and 3 two-handed jodan, the
;; cleaver raised over the right shoulder in both hands, the green tassel hanging
(defpose :ke-r-stance (:base :ke-n-stance)
  (:pelvis :twist 10) (:chest :twist -4) (:spine :flex 4) (:head :flex -4)
  (:arm-r :flex 106 :side 17 :twist -5) (:elbow-r :flex 99) (:hand-r :twist -9 :flex -55)     ; the fists above the brow,
  (:arm-l :flex 118 :side 37 :twist 41) (:elbow-l :flex 43) (:hand-l :flex -30)                ; the left on the handle's end
  (:thigh-r :flex -10 :side 10) (:thigh-l :flex 22 :side 8) (:knee-r :flex 22) (:knee-l :flex 28))
(defclip :ke-r-stance (2.0 :loop t :base :ke-r-stance)
  (0) (1.0 (:chest :flex 3) (:root :u -0.06)))
;; DRINK (cup 3's U): a drunk hit, the head thrown back, the chest open (a variant of the stance's hold)
(defclip :ke-drink (0.3 :base :ke-r-stance)
  (0 :snap (:head :flex -32) (:spine :flex -14) (:chest :twist 6) (:root :u -0.03))
  (0.3 (:head :flex -20) (:spine :flex -8)))
;; the RYOTE kendo set (cup 2, DUEL_DESIGN §6.2; cup 3 has its own since DUEL_KEN_REWORK §6.2), from jodan and back to it
;; (the front foot lifted and stamped down on the cut, fumikomi, §6.2): kamae -> a big anticipation
;; held a few frames -> a :snap into the cut on frame S -> zanshin held through S+A with a small overshoot -> settle.
;; Both fists stay on the long handle: the left arm of every key was solved onto the handle (the right fist at the
;; collar, the left 0.16-0.42 down the handle); the right arm is posed and the wrist aims the blade. Phase 6: the draw
;; holds the left fist on the handle between the keys too (body.lisp GRIP-LEFT!, these clips registered below).
(defstrike :ke-r-q1 (10 3 12 :base :ke-r-stance)       ; MEN: the straight overhead, stepping in, down the centre line
  (0)
  (4 (:root :f -0.06 :u 0.03) (:spine :flex -8) (:head :flex -6) (:chest :twist -4)        ; furikaburi: the cleaver
     (:arm-r :flex 165 :side 12 :twist 23) (:elbow-r :flex 75) (:hand-r :flex -47 :twist -8) ; dropped behind the back
     (:arm-l :flex 157 :side 8 :twist 42) (:elbow-l :flex 65))
  (7 (:root :f -0.08 :u 0.05) (:spine :flex -11) (:head :flex -8))
  (8 (:thigh-l :flex 58 :side 6) (:knee-l :flex 80))                                         ; fumikomi: the front foot up
  (:s :snap (:root :f 0.04 :u -0.1) (:spine :flex 14) (:head :flex 4) (:chest :twist 0) (:pelvis :twist 0)
      (:thigh-l :flex 48 :side 6) (:knee-l :flex 42) (:thigh-r :flex -32 :side 8) (:knee-r :flex 14)
      (:arm-r :flex 94 :side -12 :twist 11) (:elbow-r :flex 8) (:hand-r :flex -125 :twist 0)
      (:arm-l :flex 38 :side -61 :twist 71) (:elbow-l :flex 47))
  (:a (:root :f 0.07 :u -0.13) (:spine :flex 18) (:thigh-l :flex 52) (:knee-l :flex 48) (:thigh-r :flex -34) (:knee-r :flex 16)
      (:arm-r :flex 86 :side -12 :twist 11) (:elbow-r :flex 6) (:hand-r :flex -125 :twist -1)
      (:arm-l :flex 38 :side -55 :twist 64) (:elbow-l :flex 40))
  (18 (:root :f 0.06 :u -0.11) (:spine :flex 15) (:head :flex 0))                            ; zanshin
  (21 (:root :f 0.03 :u -0.05) (:spine :flex 8) (:arm-r :flex 55 :side -10 :twist -3) (:elbow-r :flex 95) (:hand-r :flex -67 :twist 10) (:arm-l :flex 32 :side -52 :twist 55) (:elbow-l :flex 39))          ; lifted back to jodan
  (:end :ke-r-stance))
(defstrike :ke-r-q3 (14 4 22 :base :ke-r-stance)       ; KESA: the diagonal, shoulder to hip
  (0)
  (6 (:root :u -0.06 :f -0.04) (:pelvis :twist 20) (:chest :twist -35) (:spine :flex -4) (:head :flex -4 :twist 20)
     (:arm-r :flex 150 :side 35 :twist -48) (:elbow-r :flex 70) (:hand-r :flex -47 :twist -7)
     (:arm-l :flex 133 :side -1 :twist 48) (:elbow-l :flex 71))
  (10 (:root :u -0.08 :f -0.06) (:chest :twist -40) (:spine :flex -6))
  (12 (:thigh-l :flex 58 :side 8) (:knee-l :flex 80))                                        ; fumikomi
  (:s :snap (:root :f 0.03 :u -0.14) (:pelvis :twist -10) (:chest :twist 35) (:spine :flex 20) (:head :flex 0 :twist -15)
      (:thigh-l :flex 46 :side 8) (:knee-l :flex 45) (:thigh-r :flex -25 :side 10) (:knee-r :flex 18)
      (:arm-r :flex 10 :side -25 :twist -9) (:elbow-r :flex 140) (:hand-r :flex -180 :twist 4)
      (:arm-l :flex 29 :side -16 :twist 56) (:elbow-l :flex 54))
  (:a (:root :f 0.06 :u -0.16) (:pelvis :twist -14) (:chest :twist 44) (:spine :flex 24) (:head :twist -18)
      (:thigh-l :flex 50) (:knee-l :flex 50) (:thigh-r :flex -26) (:knee-r :flex 20))
  (27 (:root :f 0.05 :u -0.14) (:chest :twist 41) (:spine :flex 21))
  (33 (:root :f 0.02 :u -0.06) (:chest :twist 10) (:pelvis :twist 0) (:spine :flex 8) (:head :twist 0) (:arm-r :flex 55 :side -10 :twist -3) (:elbow-r :flex 95) (:hand-r :flex -67 :twist 10) (:arm-l :flex 32 :side -52 :twist 55) (:elbow-l :flex 39))
  (:end :ke-r-stance))
(defstrike :ke-r-f1 (19 4 20 :base :ke-r-stance)       ; DO: the wide body cut, from waki-gamae, stepping through
  (0)
  (1 (:pelvis :twist 16) (:chest :twist -17) (:arm-r :flex 67 :twist -2 :side 15) (:elbow-r :flex 110) (:hand-r :flex -4 :twist -16) (:arm-l :flex 51 :twist 90 :side -96) (:elbow-l :flex 28))   ; (in-between: the left fist on the handle)
  (3 (:chest :twist -21) (:pelvis :twist 18) (:arm-r :flex 50 :side 7 :twist -1) (:elbow-r :flex 112) (:hand-r :flex 18 :twist -16) (:arm-l :flex 45 :side -94 :twist 60) (:elbow-l :flex 21))
  (4 (:pelvis :twist 21) (:spine :flex 6) (:chest :twist -37) (:head :flex -3 :twist 14) (:arm-r :flex 35 :twist -44 :side 11) (:elbow-r :flex 116) (:hand-r :flex -71 :twist -29) (:arm-l :flex 36 :twist 41 :side -62) (:elbow-l :flex 4) (:knee-r :flex 31) (:knee-l :flex 34) (:root :u -0.09 :f -0.02))   ; (in-between: the left fist on the handle)
  (8 (:root :u -0.12 :f -0.05) (:pelvis :twist 25) (:chest :twist -52) (:spine :flex 8) (:head :flex -2 :twist 35) (:knees :flex 40)
     (:arm-r :flex 20 :side 23 :twist -90) (:elbow-r :flex 68) (:hand-r :flex -108 :twist -42)
     (:arm-l :flex 27 :side -72 :twist 21) (:elbow-l :flex 15))
  (14 (:root :u -0.15 :f -0.08) (:chest :twist -56) (:pelvis :twist 28) (:knees :flex 44) (:arm-l :flex 28 :side -72 :twist 24) (:elbow-l :flex 14))
  (17 (:thigh-l :flex 62 :side 8) (:knee-l :flex 85) (:arm-l :flex 28 :side -72 :twist 24) (:elbow-l :flex 14))                                        ; fumikomi
  (:s :snap (:root :f 0.6 :u -0.2) (:pelvis :twist -20) (:chest :twist 55) (:spine :flex 22) (:head :flex 0 :twist -30)
      (:thigh-l :flex 55 :side 8) (:knee-l :flex 55) (:thigh-r :flex -30 :side 12) (:knee-r :flex 25)
      (:arm-r :flex 70 :side -35 :twist -26) (:elbow-r :flex 8) (:hand-r :flex -92 :twist 22)
      (:arm-l :flex 33 :side -32 :twist 60) (:elbow-l :flex 56))
  (:a (:root :f 0.66 :u -0.22) (:pelvis :twist -25) (:chest :twist 65) (:spine :flex 25) (:head :twist -35)
      (:thigh-l :flex 58) (:knee-l :flex 58) (:thigh-r :flex -32) (:knee-r :flex 26)
      (:arm-r :flex 65 :side -40 :twist -16) (:hand-r :flex -111 :twist 16) (:arm-l :flex 41 :side -31 :twist 74) (:elbow-l :flex 57))
  (32 (:root :f 0.63 :u -0.2) (:chest :twist 62) (:spine :flex 22) (:arm-l :flex 41 :side -31 :twist 74) (:elbow-l :flex 57))
  (37 (:root :f 0.3 :u -0.08) (:chest :twist 17) (:pelvis :twist 0) (:spine :flex 8) (:head :twist 0) (:arm-r :flex 55 :side -11 :twist -3) (:elbow-r :flex 97) (:hand-r :flex -69 :twist 10) (:arm-l :flex 36 :side -72 :twist 38) (:elbow-l :flex 16))
  (38 (:pelvis :twist 4) (:spine :flex 6) (:chest :twist 7) (:head :flex -2 :twist -3) (:arm-r :flex 79 :twist -4 :side 5) (:elbow-r :flex 99) (:hand-r :flex -67 :twist -3) (:arm-l :flex 39 :twist 49 :side -83) (:elbow-l :flex 24) (:thigh-r :flex -23 :side 11) (:knee-r :flex 24) (:thigh-l :flex 43) (:knee-l :flex 45) (:root :u -0.07 :f 0.17))   ; (in-between: the left fist on the handle)
  (39 (:pelvis :twist 7) (:spine :flex 5) (:chest :twist 2) (:head :flex -3 :twist -4) (:arm-r :flex 92 :twist -4 :side 11) (:hand-r :flex -61 :twist -6) (:arm-l :flex 46 :twist 84 :side -88) (:elbow-l :flex 34) (:thigh-r :flex -17 :side 11) (:knee-r :flex 23) (:thigh-l :flex 33) (:knee-l :flex 37) (:root :u -0.07 :f 0.09))   ; (in-between: the left fist on the handle)
  (40 (:pelvis :twist 9) (:spine :flex 4) (:chest :twist -1) (:head :flex -4 :twist -5) (:arm-r :flex 100 :twist -5 :side 14) (:hand-r :flex -58 :twist -8) (:arm-l :flex 128 :twist 68 :side 27) (:elbow-l :flex 52) (:thigh-r :flex -13 :side 10) (:knee-r :flex 22) (:thigh-l :flex 27) (:knee-l :flex 32) (:root :u -0.06 :f 0.04))   ; (in-between: the left fist on the handle)
  (:end :ke-r-stance))
(defstrike :ke-r-f2 (21 5 28 :base :ke-r-stance)       ; KABUTO-WARI: scoop low, rise huge on the toes, crash (launch)
  (0)
  (3 (:root :u -0.12) (:spine :flex 12) (:chest :twist -15) (:pelvis :twist 12) (:knees :flex 45) (:arm-r :flex 50 :side 0 :twist -1) (:elbow-r :flex 110) (:hand-r :flex 18 :twist -14) (:arm-l :flex 43 :side -73 :twist 62) (:elbow-l :flex 47))
  (6 (:root :u -0.28 :f -0.05) (:spine :flex 26) (:head :flex -20) (:knees :flex 70) (:thighs :flex 45) (:chest :twist -25)
     (:pelvis :twist 15) (:arm-r :flex 10 :side 10 :twist -90) (:elbow-r :flex 20) (:hand-r :flex -82 :twist -41)
     (:arm-l :flex 20 :side -38 :twist 47) (:elbow-l :flex 42))
  (10 (:root :u 0.05) (:spine :flex 0) (:head :flex -20) (:chest :twist -8) (:pelvis :twist 5) (:knees :flex 25) (:thighs :flex 15)
      (:arm-r :flex 120 :side 20 :twist 2) (:elbow-r :flex 80) (:hand-r :flex -89 :twist -21) (:arm-l :flex 109 :side 11 :twist 48) (:elbow-l :flex 85))
  (13 (:root :u 0.3 :f 0.0) (:spine :flex -16) (:head :flex -22) (:chest :twist 0) (:pelvis :twist 0)
      (:thigh-l :flex 20) (:knee-l :flex 10) (:thigh-r :flex -8) (:knee-r :flex 6)
      (:arm-r :flex 178 :side 8 :twist 0) (:elbow-r :flex 10) (:hand-r :flex -93 :twist -8)
      (:arm-l :flex 163 :side 23 :twist 51) (:elbow-l :flex 45))
  (17 (:root :u 0.36) (:spine :flex -20) (:head :flex -26))
  (:s :snap (:root :u -0.3 :f 0.5) (:spine :flex 40) (:head :flex -30)
      (:thigh-l :flex 66 :side 8) (:knee-l :flex 80) (:thigh-r :flex -20 :side 10) (:knee-r :flex 45)
      (:arm-r :flex 64 :side -10 :twist 11) (:elbow-r :flex 5) (:hand-r :flex -49 :twist -5)
      (:arm-l :flex 29 :side -42 :twist 47) (:elbow-l :flex 17))
  (:a (:root :u -0.33 :f 0.52) (:spine :flex 44) (:head :flex -32) (:thigh-l :flex 68) (:knee-l :flex 84) (:knee-r :flex 48)
      (:arm-r :flex 58) (:hand-r :flex -44 :twist -6) (:arm-l :flex 25 :side -39 :twist 45) (:elbow-l :flex 15))
  (38 (:root :u -0.3 :f 0.5) (:spine :flex 40) (:head :flex -28))
  (46 (:root :u -0.08 :f 0.2) (:spine :flex 10) (:head :flex -8) (:thigh-l :flex 35) (:knee-l :flex 35) (:thigh-r :flex -12)
      (:knee-r :flex 25) (:arm-r :flex 55 :side -10 :twist -3) (:elbow-r :flex 95) (:hand-r :flex -67 :twist 10) (:arm-l :flex 32 :side -52 :twist 55) (:elbow-l :flex 39))
  (:end :ke-r-stance))
;; J2 KOTE (docs/duel/DUEL_STRINGS.md §3.4): the only small motion in the set: a short lift from jodan, the wrists snap the
;; cleaver down to forearm height, a half step in
(defstrike :ke-r-kote (9 3 13 :base :ke-r-stance)      ; J2 KOTE: the small wrist snap
  (0)
  (4 (:root :f -0.03 :u 0.02) (:spine :flex -4) (:arm-r :flex 132 :side 12 :twist 15) (:elbow-r :flex 70) (:hand-r :flex -40 :twist -6)
     (:arm-l :flex 128 :side 14 :twist 40) (:elbow-l :flex 60))
  (7 (:root :f -0.04 :u 0.03) (:arm-r :flex 136) (:hand-r :flex -36) (:thigh-l :flex 50 :side 6) (:knee-l :flex 70))                              ; the lift, held
  (:s :snap (:root :f 0.03 :u -0.07) (:spine :flex 10) (:chest :twist -4) (:pelvis :twist 4)
      (:thigh-l :flex 36 :side 6) (:knee-l :flex 32) (:thigh-r :flex -22 :side 8) (:knee-r :flex 12)
      (:arm-r :flex 10 :side -10 :twist 11) (:elbow-r :flex 120) (:hand-r :flex -170 :twist 0)
      (:arm-l :flex 36 :side -58 :twist 68) (:elbow-l :flex 45))
  (:a (:root :f 0.05 :u -0.08) (:spine :flex 12))
  (18 (:root :f 0.04 :u -0.06) (:spine :flex 9))
  (22 (:root :f 0.02 :u -0.03) (:spine :flex 5) (:arm-r :flex 55 :side -10 :twist -3) (:elbow-r :flex 95) (:hand-r :flex -67 :twist 10)
      (:arm-l :flex 32 :side -52 :twist 55) (:elbow-l :flex 39))
  (:end :ke-r-stance))
;; K2 MOROTE-ZUKI (§3.4): both hands draw the cleaver back to the right hip, held, then drive it straight out, the back
;; foot sliding; held 4 f fully extended
(defstrike :ke-r-tsuki (21 4 24 :base :ke-r-stance)    ; K2 MOROTE-ZUKI: the two-handed thrust
  (0)
  (8 (:root :u -0.12 :f -0.1) (:pelvis :twist 22) (:chest :twist -28) (:spine :flex 10) (:head :flex -4 :twist 20) (:knees :flex 40)
     (:arm-r :flex 28 :side 14 :twist -30) (:elbow-r :flex 105) (:hand-r :flex -72 :twist -30)
     (:arm-l :flex 38 :side -40 :twist 50) (:elbow-l :flex 70))
  (17 (:root :u -0.15 :f -0.13) (:chest :twist -33) (:knees :flex 44) (:arm-r :flex 24) (:elbow-r :flex 112))   ; drawn back, held
  (:s :snap (:root :f 0.72 :u -0.16) (:pelvis :twist -6) (:chest :twist 6) (:spine :flex 18) (:head :flex 0 :twist 0)
      (:thigh-l :flex 56 :side 6) (:knee-l :flex 52) (:thigh-r :flex -42 :side 8) (:knee-r :flex 8)
      (:arm-r :flex 88 :side -6 :twist 10) (:elbow-r :flex 4) (:hand-r :flex -86 :twist -20)
      (:arm-l :flex 60 :side -40 :twist 70) (:elbow-l :flex 30))
  (:a (:root :f 0.78 :u -0.18) (:spine :flex 20) (:arm-r :flex 90) (:elbow-r :flex 2))
  (29 (:root :f 0.77 :u -0.18) (:spine :flex 20))                                                   ; held extended
  (38 (:root :f 0.45 :u -0.1) (:spine :flex 12) (:thigh-r :flex -24) (:knee-r :flex 14))
  (43 (:root :f 0.2 :u -0.05) (:spine :flex 6) (:arm-r :flex 55 :side -10 :twist -3) (:elbow-r :flex 95) (:hand-r :flex -67 :twist 10)
      (:arm-l :flex 32 :side -52 :twist 55) (:elbow-l :flex 39))
  (:end :ke-r-stance))
(defstrike :ke-n-f1 (20 4 22 :base :ke-r-stance)       ; KUKAN-GIRI: a flat cut at chest height, left to right; its
  (0)                                                   ; chord is the rift (f20)
  (3 (:chest :twist 15) (:pelvis :twist -5) (:arm-r :flex 70 :side -30 :twist 90) (:elbow-r :flex 90) (:hand-r :flex -62 :twist -54) (:arm-l :flex 31 :side 27 :twist 58) (:elbow-l :flex 85))
  (8 (:root :u -0.1 :f -0.04) (:pelvis :twist -15) (:chest :twist 45) (:spine :flex 6) (:head :flex -4 :twist -30) (:knees :flex 38)
     (:arm-r :flex 30 :side -50 :twist 42) (:elbow-r :flex 80) (:hand-r :flex -6 :twist 90)
     (:arm-l :flex 57 :side -17 :twist 53) (:elbow-l :flex 68))
  (15 (:root :u -0.13 :f -0.07) (:chest :twist 52) (:pelvis :twist -18) (:knees :flex 42))
  (:s :snap (:root :f 0.45 :u -0.14) (:pelvis :twist 20) (:chest :twist -45) (:spine :flex 12) (:head :flex 0 :twist 25)
      (:thigh-l :flex 48 :side 8) (:knee-l :flex 44) (:thigh-r :flex -28 :side 12) (:knee-r :flex 18)
      (:arm-r :flex 70 :side 30 :twist 34) (:elbow-r :flex 8) (:hand-r :flex -99 :twist -27)
      (:arm-l :flex 28 :side -55 :twist 52) (:elbow-l :flex 28))
  (:a (:root :f 0.5 :u -0.15) (:pelvis :twist 24) (:chest :twist -55) (:spine :flex 14) (:head :twist 30)
      (:thigh-l :flex 50) (:knee-l :flex 46) (:thigh-r :flex -30) (:knee-r :flex 20)
      (:arm-r :flex 66 :side 38 :twist 18) (:hand-r :flex -102 :twist -30) (:arm-l :flex 28 :side -57 :twist 48) (:elbow-l :flex 23))
  (34 (:root :f 0.48 :u -0.13) (:chest :twist -51) (:spine :flex 12))
  (40 (:root :f 0.2 :u -0.05) (:chest :twist -10) (:pelvis :twist 5) (:spine :flex 6) (:head :twist 0) (:arm-r :flex 55 :side -10 :twist -3) (:elbow-r :flex 95) (:hand-r :flex -67 :twist 10) (:arm-l :flex 32 :side -52 :twist 55) (:elbow-l :flex 39))
  (:end :ke-r-stance))
(setf *grip-clips* '(:ke-r-stance :ke-drink :ke-r-q1 :ke-r-q3 :ke-r-f1 :ke-r-f2 :ke-n-f1 :ke-r-kote :ke-r-tsuki))
(defstrike :ke-meteor (26 4 30 :base :ke-n-stance)     ; "Split the meteor": the huge two-handed cleave
  (0)
  (16 (:root :u 0.05) (:arm-r :flex 180 :side 5) (:arm-l :flex 165 :side 37 :twist 4) (:elbows :flex 30) (:elbow-l :flex 13)
      (:hand-r :twist 0 :flex -50) (:spine :flex -22) (:head :flex -20) (:chest :twist 0) (:pelvis :twist 0))
  (22 (:root :u 0.1 :f -0.05) (:spine :flex -27) (:head :flex -25))                  ; raised to the sky, held
  (:s :snap (:root :u -0.44 :f 0.42) (:spine :flex 62) (:arm-r :flex 20 :side 0) (:arm-l :flex -7 :side -36 :twist 0)
      (:elbows :flex 5) (:elbow-l :flex 0) (:hand-r :twist -10 :flex -35) (:knees :flex 92) (:thighs :flex 70) (:head :flex -35))
  (:a (:spine :flex 66) (:root :u -0.47 :f 0.44))                                     ; overshoot
  (44 (:root :u -0.41 :f 0.4) (:spine :flex 58))
  (:end :ke-n-stance))
(defclip :ke-kikon-n (1.5 :base :ke-n-stance)          ; the sky split: one colossal cleave
  (0)
  (0.35 (:root :u -0.2) (:chest :twist -80) (:arms :side 80 :flex 30) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -90)
        (:arm-l :side 20 :flex 60) (:knees :flex 50) (:spine :flex 15))
  (0.42 :snap (:chest :twist 80) (:arm-r :flex 80 :side 5) (:arm-l :flex 75 :side -5) (:hand-r :twist 5 :flex -85)
        (:root :f 0.6 :u -0.3) (:thigh-l :flex 55) (:knee-l :flex 60) (:spine :flex 25))
  (1.0 (:chest :twist 88))
  (1.5 :ke-n-stance))

;;; ---------------------------------------------------------------- KATATE's own strikes (DUEL_KEN_REWORK §6.2)
;;; Cup 1 plays the base moves (+2 f, reach x1.3) through the kit's :clip-map on these: one hand, the cleaver's weight
;;; leads and the man follows. Authored at the base clips' S/A/R (the derived move plays them at S/(S+2)).
(defstrike :ke-k-q1 (7 3 12 :base :ke-k-rest)          ; J1: the shoulder-roll drop: heaved off the shoulder, it rolls
  (0)                                                   ; over and down in front and drags him a step
  (3 (:root :f -0.05 :u 0.03) (:spine :flex -10) (:chest :twist -15) (:arm-r :flex 70 :side 20) (:elbow-r :flex 90)
     (:hand-r :flex 0 :twist 0) (:arm-l :flex 40 :side 35) (:elbow-l :flex 30) (:head :flex -10))
  (5 (:root :f -0.07 :u 0.04) (:spine :flex -13) (:arm-r :flex 80))                                            ; held
  (:s :snap (:root :f 0.35 :u -0.15) (:spine :flex 34) (:chest :twist 10) (:arm-r :flex 50 :side 5) (:elbow-r :flex 5)
      (:hand-r :flex -75) (:arm-l :flex -20 :side 40) (:elbow-l :flex 15) (:thigh-r :flex 50) (:knee-r :flex 55)
      (:thigh-l :flex -20) (:knee-l :flex 40) (:head :flex -10))
  (:a (:root :f 0.45 :u -0.2) (:spine :flex 40) (:arm-r :flex 40) (:hand-r :flex -85))                        ; carried on
  (15 (:root :f 0.4 :u -0.18) (:spine :flex 36))
  (:end :ke-k-rest))
(defstrike :ke-k-q2 (7 3 13 :base :ke-k-rest)          ; J2: the mowing sweep: flat and low, right to left, the
  (0)                                                   ; cleaver dragging him round after it
  (3 (:pelvis :twist 30) (:chest :twist -50) (:spine :flex 10) (:arm-r :flex 30 :side 75) (:elbow-r :flex 15)
     (:hand-r :twist 180 :flex 0) (:arm-l :flex 30 :side 20) (:elbow-l :flex 30) (:knees :flex 35) (:root :u -0.08))
  (5 (:chest :twist -58) (:arm-r :side 82))                                                                   ; held
  (:s :snap (:pelvis :twist -20) (:chest :twist 80) (:spine :flex 14) (:arm-r :flex 70 :side -10) (:elbow-r :flex 60)
      (:hand-r :twist 180 :flex 0) (:arm-l :flex 10 :side 60) (:root :f 0.2 :u -0.1) (:thigh-l :flex 40) (:knee-l :flex 40))
  (:a (:pelvis :twist -35) (:chest :twist 95) (:arm-r :flex 65 :side -25) (:root :f 0.25 :yaw 25))
  (16 (:chest :twist 85) (:root :f 0.2 :yaw 20))
  (:end :ke-k-rest))
(defstrike :ke-k-f1 (16 4 20 :base :ke-k-rest)         ; K1: the flat smack: a club, not a cut: swung up over the left
  (0)                                                   ; shoulder, held, then a lunging backhand diagonal, flat first
  (6 (:root :u -0.05 :f -0.08) (:pelvis :twist -20) (:chest :twist 45) (:spine :flex -5) (:arm-r :flex 150 :side -20)
     (:elbow-r :flex 70) (:hand-r :flex -30 :twist 0) (:arm-l :flex 20 :side 50) (:elbow-l :flex 30) (:head :twist -20))
  (13 (:root :u -0.03 :f -0.12) (:chest :twist 52) (:spine :flex -8))                                          ; held
  (:s :snap (:root :f 0.9 :u -0.15) (:pelvis :twist 20) (:chest :twist -30) (:spine :flex 22) (:arm-r :flex 75 :side 40)
      (:elbow-r :flex 5) (:hand-r :flex -60 :twist 0) (:arm-l :flex -10 :side 40) (:elbow-l :flex 20) (:head :twist 15)
      (:thigh-l :flex 50) (:knee-l :flex 45) (:thigh-r :flex -35) (:knee-r :flex 15))
  (:a (:root :f 0.98 :u -0.17) (:chest :twist -42) (:spine :flex 26) (:arm-r :flex 60 :side 60))
  (28 (:root :f 0.9 :u -0.15) (:chest :twist -38) (:spine :flex 22))
  (:end :ke-k-rest))
(defstrike :ke-k-f2 (20 5 28 :base :ke-k-rest)         ; K2: the heave-up: the head dragged low behind him, then a
  (0)                                                   ; one-handed scoop up in front, leaning back against its weight
  (8 (:pelvis :twist 20) (:chest :twist -20) (:spine :flex 35) (:root :u -0.3) (:knees :flex 60) (:arm-r :flex -40 :side 20)
     (:elbow-r :flex 5) (:hand-r :twist 0 :flex -60) (:arm-l :flex 30 :side 30) (:elbow-l :flex 30) (:head :flex -20))
  (16 (:root :u -0.34 :f 0.15) (:spine :flex 38) (:arm-r :flex -48))                                          ; held
  (:s :snap (:pelvis :twist 0) (:chest :twist 0) (:spine :flex -20) (:root :u 0.02 :f 0.45) (:knees :flex 20)
      (:arm-r :flex 70 :side 5) (:elbow-r :flex 5) (:hand-r :flex -90) (:arm-l :flex 20 :side 60) (:head :flex -20)
      (:thigh-r :flex 25) (:thigh-l :flex -10))
  (:a (:arm-r :flex 150) (:hand-r :flex -50) (:spine :flex -30) (:root :u 0.06 :f 0.42) (:head :flex -30))
  (36 (:arm-r :flex 140) (:spine :flex -26))
  (:end :ke-k-rest))
(defstrike :ke-k-spin (11 4 22 :base :ke-k-rest)       ; K3 BUNMAWASHI: the arm locked out, the cleaver's weight carries
  (0)                                                   ; him round once and a bit
  (5 (:root :u -0.12) (:knees :flex 40) (:chest :twist -25) (:arm-r :side 85 :flex 0) (:elbow-r :flex 5)
     (:hand-r :twist -5 :flex -90) (:arm-l :side 30 :flex 30) (:elbow-l :flex 60))
  (8 (:root :u -0.16 :yaw -15) (:knees :flex 48) (:chest :twist -32))                                         ; coiled, held
  (:s :snap (:root :yaw 360 :u -0.1 :f 0.35) (:chest :twist 30) (:knees :flex 40) (:spine :flex 10))
  (:a (:root :yaw 410 :u -0.14 :f 0.42) (:chest :twist 40) (:spine :flex 14))                                ; dragged on
  (22 (:root :yaw 395 :u -0.1 :f 0.4) (:chest :twist 34))
  (:end :ke-k-rest (:root :yaw 360)))
(defstrike :ke-k-meteor (26 4 30 :base :ke-k-rest)     ; SP1 "Split the meteor", one hand: the leap, the cleaver cocked
  (0)                                                   ; over the right shoulder, the top-down split, back onto it
  (8 (:root :u -0.3) (:knees :flex 80) (:thighs :flex 60) (:spine :flex 28) (:arm-l :flex 30 :side 30))
  (16 (:root :u 0.6) (:thighs :flex 60) (:knees :flex 90) (:arm-r :flex 170 :side 25) (:elbow-r :flex 100)
      (:hand-r :flex -20 :twist 0) (:arm-l :flex 80 :side 70) (:elbow-l :flex 10) (:spine :flex -25) (:head :flex -20))
  (22 (:root :u 0.75) (:spine :flex -30) (:elbow-r :flex 110))                                                ; held, high
  (:s :snap (:root :u -0.44 :f 0.42) (:spine :flex 60) (:arm-r :flex 25 :side 0) (:elbow-r :flex 0) (:hand-r :flex -40 :twist 0)
      (:arm-l :flex -35 :side 45) (:elbow-l :flex 10) (:knees :flex 92) (:thighs :flex 70) (:head :flex -35))
  (:a (:spine :flex 64) (:root :u -0.47 :f 0.44))
  (44 (:root :u -0.41 :f 0.4) (:spine :flex 58))
  (:end :ke-k-rest))

;;; ---------------------------------------------------------------- NOMIHOSE's own strikes (DUEL_KEN_REWORK §6.2)
;;; Cup 3, drained to the dregs (the user: 「三杯也改用一套自己的獨立動作」): RYOTE's moves through the kit's :clip-map on
;;; these, at those clips' S/A/R. Two hands, every cut overcommitted, the body low and bestial; the left fist held on the
;;; haft by GRIP-LEFT! (registered below) except in the drink. Every key's left arm is solved onto the handle (0.16-0.45 m
;;; down from the right fist) IN FRONT of the torso: below the shoulders no point of the arm behind the frontal plane of
;;; the torso segment at its height (+0.04 m; the elbow 0; at his side -0.10), none inside the torso (2392's GRIP-FRONT
;;; rows); where the handle sat behind him the grip moved forward (the stance's right fist 0.45 m ahead of the chest, was
;;; 0.08; the K1 wind-up's grip beside the left hip), never the arm round his back. Keys marked "in-between" hold it there
;;; between keys (DUEL_KEN_REWORK §6.2.1 and §6.2.2, 2026-10-21: 「改完之後手反而會跑到背後欸」: below the shoulders worst
;;; -349 mm -> -131 mm at his side, no sample behind the back plane, the IK gap <= 27 mm).
(defpose :ke-x-stance (:base :ke-r-stance)             ; gedan, hunched, wide: both fists low in front of the belly, the right
                                                       ; one ahead, the cleaver's tip down on the floor before him
  (:root :u -0.1) (:pelvis :twist 20) (:chest :twist -22) (:spine :flex 22) (:head :flex -18)
  (:arm-r :flex 38 :side 3 :twist -18) (:elbow-r :flex 15) (:hand-r :flex -80 :twist -6)
  (:arm-l :flex 26 :side -48 :twist -31) (:elbow-l :flex -1)
  (:thigh-r :flex -18 :side 16) (:thigh-l :flex 32 :side 14) (:knee-r :flex 35) (:knee-l :flex 45))
(defclip :ke-x-stance (1.6 :loop t :base :ke-x-stance)
  (0) (0.8 (:chest :flex 4) (:root :u -0.13) (:head :flex -14) (:arm-l :flex 26 :side -48 :twist -27) (:elbow-l :flex -1)))
(defstrike :ke-x-q1 (10 3 12 :base :ke-x-stance)       ; J1: the ground-shaker: up from behind over the head in both hands,
  (0)                                                   ; then everything behind one vertical; it buries in the floor
  (1 (:pelvis :twist 10) (:spine :flex 4) (:chest :twist -11) (:head :flex -17) (:arm-r :flex 104 :twist -9 :side 6) (:elbow-r :flex 41) (:hand-r :flex -64 :twist -3) (:arm-l :flex 42 :twist -26 :side -100) (:elbow-l :flex 16) (:root :u -0.03 :f -0.04))   ; (in-between: the left fist on the handle, the arm in front)
  (5 (:root :u 0.05 :f -0.08) (:spine :flex -14) (:chest :twist 1) (:pelvis :twist 0) (:head :flex -15)
     (:arm-r :flex 174 :side 10 :twist 0) (:elbow-r :flex 68) (:hand-r :flex -48 :twist 1) (:arm-l :flex -6 :side -143 :twist -48) (:elbow-l :flex -1))
  (8 (:root :u 0.08 :f -0.1) (:spine :flex -18) (:arm-l :flex -6 :side -143 :twist -51) (:elbow-l :flex -1))                                                              ; held, high
  (9 :snap (:spine :flex 16) (:head :flex -20) (:arm-r :flex 122 :twist -6 :side 8) (:elbow-r :flex 36) (:hand-r :flex -59 :twist 0) (:arm-l :flex 46 :twist -59 :side -107) (:elbow-l :flex 12) (:thigh-r :flex -22) (:knee-r :flex 37) (:thigh-l :flex 46) (:knee-l :flex 58) (:root :u -0.10 :f 0.10))   ; (in-between: the left fist on the handle, the arm in front)
  (:s :snap (:root :u -0.28 :f 0.3) (:spine :flex 50) (:head :flex -25) (:arm-r :flex 70 :side -5 :twist 0) (:elbow-r :flex 5)
      (:hand-r :flex -70 :twist 1) (:arm-l :flex 26 :side -79 :twist -57) (:elbow-l :flex 40)
      (:thigh-l :flex 60) (:knee-l :flex 70) (:thigh-r :flex -25) (:knee-r :flex 40))
  (:a (:root :u -0.32 :f 0.32) (:spine :flex 55) (:hand-r :flex -78) (:arm-l :flex 25 :side -79 :twist -45) (:elbow-l :flex 39))
  (20 (:root :u -0.3 :f 0.3) (:spine :flex 52) (:arm-l :flex 25 :side -79 :twist -45) (:elbow-l :flex 39))
  (:end :ke-x-stance))
(defstrike :ke-x-kote (9 3 13 :base :ke-x-stance)      ; J2: a short brutal hack off the shoulder, elbows bent, a lurch
  (0)
  (1 (:spine :flex 14) (:chest :twist -21) (:arm-r :flex 92 :twist -6 :side 21) (:elbow-r :flex 67) (:hand-r :flex -62 :twist -8) (:arm-l :flex 50 :twist 17 :side -95) (:elbow-l :flex 4) (:root :u -0.07))   ; (in-between: the left fist on the handle, the arm in front)
  (4 (:root :u -0.04) (:spine :flex 8) (:chest :twist -20) (:arm-r :flex 120 :side 30 :twist 0) (:elbow-r :flex 100) (:hand-r :flex -30 :twist 0)
     (:arm-l :flex 23 :side -125 :twist 52) (:elbow-l :flex 57))
  (7 (:chest :twist -24) (:arm-r :flex 125) (:arm-l :flex 20 :side -125 :twist 59) (:elbow-l :flex 61))                                                                  ; held
  (8 :snap (:spine :flex 19) (:chest :twist -7) (:arm-r :flex 77 :side 17) (:elbow-r :flex 92) (:hand-r :flex -90) (:arm-l :flex 25 :twist 52 :side -61) (:elbow-l :flex 49) (:thigh-l :flex 39) (:knee-l :flex 48) (:root :u -0.08 :f 0.13))   ; (in-between: the left fist on the handle, the arm in front)
  (:s :snap (:root :f 0.25 :u -0.12) (:spine :flex 30) (:chest :twist 10) (:arm-r :flex 30 :side 5) (:elbow-r :flex 85)
      (:hand-r :flex -150) (:arm-l :flex 30 :side -40 :twist 82) (:elbow-l :flex 68) (:thigh-l :flex 45) (:knee-l :flex 50))
  (:a (:root :f 0.28 :u -0.14) (:spine :flex 33) (:arm-l :flex 30 :side -40 :twist 82) (:elbow-l :flex 68))
  (18 (:root :f 0.25 :u -0.12) (:spine :flex 30) (:arm-l :flex 30 :side -40 :twist 82) (:elbow-l :flex 68))
  (:end :ke-x-stance))
(defstrike :ke-x-q3 (14 4 22 :base :ke-x-stance)       ; J3: the shoulder-to-floor diagonal, overcommitted: it turns him
  (0)                                                   ; half round and he ends crouched
  (6 (:pelvis :twist 25) (:chest :twist -45) (:spine :flex -6) (:root :u 0.0) (:arm-r :flex 155 :side 45 :twist 0) (:elbow-r :flex 70)
     (:hand-r :flex -40 :twist 0) (:arm-l :flex 20 :side -137 :twist 50) (:elbow-l :flex 75) (:head :twist 20))
  (10 (:chest :twist -52) (:root :u 0.03) (:arm-l :flex 20 :side -137 :twist 50) (:elbow-l :flex 75))                                                                    ; held
  (12 :snap (:pelvis :twist 0) (:spine :flex 14) (:chest :twist -4) (:head :twist 2) (:arm-r :flex 88 :side 8) (:elbow-r :flex 75) (:hand-r :flex -100) (:arm-l :flex 25 :twist 61 :side -60) (:elbow-l :flex 63) (:thigh-r :flex -19) (:knee-r :flex 42) (:thigh-l :flex 46) (:knee-l :flex 58) (:root :u -0.11 :f 0.13 :yaw 15))   ; (in-between: the left fist on the handle, the arm in front)
  (13 :snap (:pelvis :twist -13) (:spine :flex 25) (:chest :twist 21) (:head :twist -7) (:arm-r :flex 54 :side -11) (:elbow-r :flex 77) (:hand-r :flex -130) (:arm-l :flex 27 :twist 67 :side -48) (:elbow-l :flex 68) (:thigh-r :flex -19) (:knee-r :flex 46) (:thigh-l :flex 53) (:knee-l :flex 64) (:root :u -0.18 :f 0.19 :yaw 23))   ; (in-between: the left fist on the handle, the arm in front)
  (:s :snap (:pelvis :twist -25) (:chest :twist 45) (:spine :flex 35) (:root :f 0.25 :u -0.25 :yaw 30) (:arm-r :flex 21 :side -30)
      (:elbow-r :flex 80) (:hand-r :flex -160) (:arm-l :flex 27 :side -63 :twist 101) (:elbow-l :flex 74) (:head :twist -15)
      (:thigh-l :flex 60) (:knee-l :flex 70) (:thigh-r :flex -20) (:knee-r :flex 50))
  (:a (:root :f 0.3 :u -0.32 :yaw 70) (:chest :twist 55) (:spine :flex 40) (:arm-l :flex 41 :side -49 :twist 105) (:elbow-l :flex 83) (:arm-r :flex 20))                                  ; turned on
  (28 (:root :f 0.28 :u -0.3 :yaw 60) (:spine :flex 38) (:arm-l :flex 41 :side -49 :twist 105) (:elbow-l :flex 83))
  (:end :ke-x-stance))
(defstrike :ke-x-f1 (20 4 22 :base :ke-x-stance)       ; K1 KUKAN-GIRI: one huge rising diagonal, low left to high right;
  (0)                                                   ; its chord hangs in the air (the rift, f20)
  (1 (:pelvis :twist 7) (:spine :flex 23) (:chest :twist 2) (:head :twist -12) (:arm-r :flex 29 :twist -12 :side -11) (:elbow-r :flex 20) (:hand-r :flex -67 :twist -4) (:arm-l :flex 25 :twist 100 :side -12) (:elbow-l :flex 54) (:knee-r :flex 40) (:knee-l :flex 47) (:root :u -0.13 :f -0.02))   ; (in-between: the left fist on the handle, the arm in front)
  (2 (:pelvis :twist -3) (:spine :flex 24) (:chest :twist 18) (:head :twist -17) (:arm-r :flex 23 :twist -6 :side -22) (:elbow-r :flex 28) (:hand-r :flex -60 :twist -4) (:arm-l :flex 30 :twist 102 :side 2) (:elbow-l :flex 64) (:knee-r :flex 44) (:knee-l :flex 48) (:root :u -0.16 :f -0.03))   ; (in-between: the left fist on the handle, the arm in front)
  (3 (:pelvis :twist -10) (:spine :flex 24) (:chest :twist 36) (:head :twist -20) (:arm-r :flex 25 :twist -5 :side -30) (:elbow-r :flex 26) (:hand-r :flex -49 :twist -5) (:arm-l :flex 36 :twist 100 :side 17) (:elbow-l :flex 76) (:knee-r :flex 47) (:knee-l :flex 49) (:root :u -0.18 :f -0.04))   ; (in-between: the left fist on the handle, the arm in front)
  (5 (:pelvis :twist -19) (:spine :flex 25) (:chest :twist 49) (:head :twist -25) (:arm-r :flex 19 :twist 0 :side -39) (:elbow-r :flex 30) (:hand-r :flex -50 :twist 1) (:arm-l :flex 46 :twist 108 :side 29) (:elbow-l :flex 92) (:knee-r :flex 50) (:knee-l :flex 50) (:root :u -0.20 :f -0.05))   ; (in-between: the left fist on the handle, the arm in front)
  (6 (:pelvis :twist -19) (:spine :flex 25) (:chest :twist 50) (:head :twist -25) (:arm-r :flex 19 :twist 0 :side -39) (:elbow-r :flex 30) (:hand-r :flex -50 :twist 1) (:arm-l :flex 45 :twist 106 :side 31) (:elbow-l :flex 93) (:knee-r :flex 50) (:knee-l :flex 50) (:root :u -0.20 :f -0.05))   ; (in-between: the left fist on the handle, the arm in front)
  (8 (:root :u -0.2 :f -0.05) (:pelvis :twist -20) (:chest :twist 51) (:spine :flex 25) (:head :twist -25) (:knees :flex 50)
     (:arm-r :flex 19 :side -40 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -50 :twist 1) (:arm-l :flex 45 :side 32 :twist 105) (:elbow-l :flex 94))
  (16 (:root :u -0.24 :f -0.08) (:chest :twist 53) (:knees :flex 55) (:arm-l :flex 46 :side 29 :twist 108) (:elbow-l :flex 92) (:arm-r :flex 20) (:hand-r :flex -49 :twist 4) (:elbow-r :flex 27))                                         ; held, low
  (17 :snap (:pelvis :twist -9) (:spine :flex 16) (:chest :twist 24) (:head :twist -13) (:arm-r :flex 28 :twist -2 :side -29) (:elbow-r :flex 24) (:hand-r :flex -53 :twist 5) (:arm-l :flex 28 :twist 89 :side 10) (:elbow-l :flex 70) (:thigh-r :flex -20) (:knee-r :flex 45) (:thigh-l :flex 34) (:knee-l :flex 49) (:root :u -0.18 :f 0.06))   ; (in-between: the left fist on the handle, the arm in front)
  (18 :snap (:pelvis :twist 2) (:spine :flex 7) (:chest :twist 2) (:head :twist 0) (:arm-r :flex 51 :twist -2 :side 1) (:elbow-r :flex 16) (:hand-r :flex -65 :twist 0) (:arm-l :flex 24 :twist 99 :side -42) (:elbow-l :flex 21) (:thigh-r :flex -22) (:knee-r :flex 35) (:thigh-l :flex 36) (:knee-l :flex 43) (:root :u -0.12 :f 0.21))   ; (in-between: the left fist on the handle, the arm in front)
  (:s :snap (:root :f 0.5 :u 0.0) (:pelvis :twist 25) (:chest :twist -50) (:spine :flex -10) (:head :twist 25)
      (:arm-r :flex 85 :side 45 :twist 0) (:elbow-r :flex 5) (:hand-r :flex -90) (:arm-l :flex 35 :side -54 :twist 97) (:elbow-l :flex 56)
      (:thigh-l :flex 40) (:knee-l :flex 30) (:thigh-r :flex -25) (:knee-r :flex 15))
  (:a (:root :f 0.55 :u 0.04) (:chest :twist -60) (:spine :flex -14) (:arm-r :flex 120) (:hand-r :flex -60) (:arm-l :flex 48 :side -64 :twist 82) (:elbow-l :flex 46))
  (34 (:root :f 0.52 :u 0.0) (:chest :twist -55) (:arm-l :flex 48 :side -64 :twist 80) (:elbow-l :flex 46))
  (:end :ke-x-stance))
(defstrike :ke-x-tsuki (21 4 24 :base :ke-x-stance)    ; K2: the battering ram: the cleaver level at the hip in both hands,
  (0)                                                   ; the capped end first, the whole body charging behind it
  (8 (:root :u -0.15 :f -0.12) (:pelvis :twist 15) (:chest :twist -10) (:spine :flex 25) (:knees :flex 50)
     (:arm-r :flex 23 :side 7 :twist 0) (:elbow-r :flex 88) (:hand-r :flex -72 :twist -8) (:arm-l :flex 26 :side -55 :twist -31) (:elbow-l :flex 6))
  (17 (:root :u -0.18 :f -0.16) (:spine :flex 28) (:knees :flex 55) (:arm-l :flex 26 :side -55 :twist -31) (:elbow-l :flex 6))                                          ; held, coiled
  (:s :snap (:root :f 0.9 :u -0.15) (:pelvis :twist 0) (:chest :twist 0) (:spine :flex 30) (:arm-r :flex 75 :side 0)
      (:elbow-r :flex 15) (:hand-r :flex -75) (:arm-l :flex 39 :side -70 :twist -15) (:elbow-l :flex 13)
      (:thigh-l :flex 60) (:knee-l :flex 55) (:thigh-r :flex -45) (:knee-r :flex 10))
  (:a (:root :f 0.98 :u -0.17) (:spine :flex 33) (:arm-l :flex 39 :side -70 :twist -14) (:elbow-l :flex 13))
  (29 (:root :f 0.95 :u -0.16) (:arm-l :flex 39 :side -70 :twist -14) (:elbow-l :flex 13))                                                                               ; held out
  (:end :ke-x-stance))
(defstrike :ke-x-f2 (21 5 28 :base :ke-x-stance)       ; K3 KABUTO-WARI: the full-length bisector: crouch, a leap with the
  (0)                                                   ; cleaver overhead, one cut from above his head to the floor
  (6 (:root :u -0.32) (:knees :flex 75) (:thighs :flex 55) (:spine :flex 30) (:arm-r :flex 37 :side -17 :twist 0) (:arm-l :flex 26 :side -53 :twist -98) (:chest :twist -25) (:elbow-r :flex 22) (:hand-r :flex -51 :twist 8) (:elbow-l :flex 34))
  (7 (:spine :flex 0) (:chest :twist -24) (:head :flex -21) (:arm-r :flex 123 :twist -7 :side 1) (:hand-r :flex -58 :twist 4) (:arm-l :flex 45 :twist -83 :side -98) (:elbow-l :flex 9) (:thigh-r :flex 52) (:knee-r :flex 66) (:thigh-l :flex 52) (:knee-l :flex 66) (:root :u 0.11 :f 0.05))   ; (in-between: the left fist on the handle, the arm in front)
  (8 (:spine :flex -4) (:chest :twist -25) (:head :flex -21) (:arm-r :flex 134 :twist -4 :side 2) (:elbow-r :flex 24) (:hand-r :flex -59 :twist 3) (:arm-l :flex 44 :twist -87 :side -100) (:elbow-l :flex 4) (:thigh-r :flex 52) (:knee-r :flex 65) (:thigh-l :flex 52) (:knee-l :flex 65) (:root :u 0.17 :f 0.06))   ; (in-between: the left fist on the handle, the arm in front)
  (13 (:root :u 0.45 :f 0.1) (:spine :flex -24) (:head :flex -22) (:knees :flex 60) (:thighs :flex 50) (:arm-r :flex 178 :side 8 :twist 0)
      (:elbow-r :flex 40) (:hand-r :flex -60 :twist 0) (:arm-l :flex 26 :side -124 :twist -81) (:elbow-l :flex -17) (:chest :twist -25))
  (17 (:root :u 0.55 :f 0.15) (:spine :flex -30) (:head :flex -26) (:arm-l :flex 27 :side -125 :twist -75) (:elbow-l :flex -17))                                            ; held, high
  (19 :snap (:spine :flex 12) (:chest :twist -22) (:head :flex -28) (:arm-r :flex 132 :twist -7 :side 6) (:elbow-r :flex 17) (:hand-r :flex -47 :twist -6) (:arm-l :flex 48 :twist -83 :side -117) (:elbow-l :flex 3) (:thigh-r :flex 17) (:thigh-l :flex 60) (:knee-l :flex 75) (:root :u 0.09 :f 0.32))   ; (in-between: the left fist on the handle, the arm in front)
  (20 :snap (:spine :flex 34) (:chest :twist -21) (:head :flex -29) (:arm-r :flex 106 :twist -5 :side -10) (:elbow-r :flex 5) (:hand-r :flex -39 :twist -3) (:arm-l :twist -75 :side -66) (:elbow-l :flex 13) (:thigh-r :flex 1) (:thigh-l :flex 65) (:knee-l :flex 83) (:root :u -0.15 :f 0.41))   ; (in-between: the left fist on the handle, the arm in front)
  (:s :snap (:root :u -0.38 :f 0.5) (:spine :flex 55) (:head :flex -30) (:arm-r :flex 80 :side -15 :twist 0) (:elbow-r :flex -5)
      (:hand-r :flex -30 :twist 0) (:arm-l :flex 33 :side -44 :twist -91) (:elbow-l :flex 12)
      (:thigh-l :flex 70) (:knee-l :flex 90) (:thigh-r :flex -15) (:knee-r :flex 60) (:chest :twist -20))
  (:a (:root :u -0.42 :f 0.52) (:spine :flex 60) (:arm-l :flex 33 :side -44 :twist -93) (:elbow-l :flex 12))
  (40 (:root :u -0.4 :f 0.5) (:spine :flex 57) (:arm-l :flex 33 :side -44 :twist -93) (:elbow-l :flex 12))                                                               ; crouched, held
  (41 (:spine :flex 46) (:chest :twist -21) (:head :flex -27) (:arm-r :flex 66 :twist -6 :side -9) (:elbow-r :flex 1) (:hand-r :flex -47 :twist -2) (:arm-l :flex 30 :twist 0 :side -48) (:elbow-l :flex 17) (:thigh-r :flex -16) (:knee-r :flex 52) (:thigh-l :flex 58) (:knee-l :flex 75) (:root :u -0.30 :f 0.33))   ; (in-between: the left fist on the handle, the arm in front)
  (42 (:spine :flex 44) (:chest :twist -21) (:head :flex -26) (:arm-r :flex 64 :twist -7 :side -8) (:elbow-r :flex 2) (:hand-r :flex -49 :twist -2) (:arm-l :flex 30 :twist -8 :side -48) (:elbow-l :flex 17) (:thigh-r :flex -16) (:knee-r :flex 51) (:thigh-l :flex 56) (:knee-l :flex 73) (:root :u -0.29 :f 0.31))   ; (in-between: the left fist on the handle, the arm in front)
  (:end :ke-x-stance))
(defstrike :ke-x-meteor (26 4 30 :base :ke-x-stance)   ; Shift+K NOMIHOSE: the meteor at full power: higher, arched back,
  (0)                                                   ; both hands, then down through everything
  (8 (:root :u -0.35) (:knees :flex 85) (:thighs :flex 65) (:spine :flex 32) (:chest :twist -15) (:arm-r :flex 30 :side -5 :twist -13) (:elbow-r :flex 15) (:hand-r :flex -55 :twist -13) (:arm-l :flex 22 :side -35 :twist -33) (:elbow-l :flex -2))
  (9 (:spine :flex 10) (:chest :twist -25) (:head :flex -22) (:arm-r :flex 79 :twist -7 :side -2) (:elbow-r :flex 26) (:hand-r :flex -60 :twist -8) (:arm-l :flex 47 :twist -35 :side -67) (:elbow-l :flex 3) (:thigh-r :flex 60) (:knee-r :flex 83) (:thigh-l :flex 60) (:knee-l :flex 83) (:root :u 0.05))   ; (in-between: the left fist on the handle, the arm in front)
  (16 (:root :u 0.85) (:thighs :flex 50) (:knees :flex 80) (:arm-r :flex 182 :side 5 :twist 0) (:elbow-r :flex 49) (:hand-r :flex -62 :twist -1)
      (:arm-l :flex 20 :side -134 :twist -56) (:elbow-l :flex -6) (:spine :flex -35) (:head :flex -30) (:chest :twist -38))
  (22 (:root :u 1.0) (:spine :flex -40) (:head :flex -32) (:arm-l :flex 18 :side -134 :twist -67) (:elbow-l :flex -5))                                                    ; arched, held
  (25 :snap (:spine :flex 38) (:chest :twist -39) (:head :flex -34) (:arm-r :flex 81 :twist -2 :side -2) (:elbow-r :flex 19) (:hand-r :flex -65) (:arm-l :flex 42 :twist -64 :side -72) (:elbow-l :flex 9) (:thigh-r :flex 66) (:knee-r :flex 91) (:thigh-l :flex 66) (:knee-l :flex 91) (:root :u -0.09 :f 0.34))   ; (in-between: the left fist on the handle, the arm in front)
  (:s :snap (:root :u -0.46 :f 0.45) (:spine :flex 64) (:arm-r :flex 47 :side -5 :twist -3) (:elbow-r :flex 9) (:hand-r :flex -66 :twist -1)
      (:arm-l :flex 28 :side -46 :twist -62) (:elbow-l :flex 3) (:knees :flex 95) (:thighs :flex 72) (:head :flex -35) (:chest :twist -40))
  (27 (:spine :flex 67) (:arm-r :flex 50 :side -3) (:elbow-r :flex 6) (:hand-r :flex -63) (:arm-l :twist -55 :flex 28 :side -46) (:elbow-l :flex 1) (:root :u -0.49 :f 0.47))   ; (in-between: the left fist on the handle, the arm in front)
  (28 (:spine :flex 68) (:arm-r :flex 50 :side -3) (:elbow-r :flex 5) (:hand-r :flex -63) (:arm-l :twist -51 :flex 28 :side -46) (:elbow-l :flex 1) (:root :u -0.50 :f 0.47))   ; (in-between: the left fist on the handle, the arm in front)
  (29 (:elbow-r :flex 4) (:arm-l :twist -46) (:elbow-l :flex 0))   ; (in-between: the left fist on the handle, the arm in front)
  (:a (:spine :flex 68) (:root :u -0.5 :f 0.47) (:arm-l :flex 28 :side -46 :twist -47) (:elbow-l :flex 1) (:chest :twist -40) (:arm-r :flex 50 :side -3 :twist -3) (:elbow-r :flex 4) (:hand-r :flex -63))
  (44 (:root :u -0.44 :f 0.44) (:spine :flex 62) (:arm-l :flex 26 :side -39 :twist -24) (:elbow-l :flex 2) (:chest :twist -37) (:arm-r :flex 46 :side -7 :twist -8) (:elbow-r :flex -2) (:hand-r :flex -50 :twist -2))
  (:end :ke-x-stance))
(defclip :ke-x-drink (0.3 :base :ke-x-stance)           ; U DRINK: the head thrown back roaring, arms wide, the cleaver
  (0 :snap (:head :flex -40) (:spine :flex -16) (:chest :twist 0) (:root :u -0.02) (:arm-r :flex 40 :side 80) (:elbow-r :flex 10)
     (:hand-r :twist -90 :flex 0) (:arm-l :flex 40 :side 80 :twist 0) (:elbow-l :flex 10))   ; raised high on the right
  (0.3 (:head :flex -30) (:spine :flex -10)))
(setf *grip-clips* (append *grip-clips* '(:ke-x-stance :ke-x-q1 :ke-x-kote :ke-x-q3 :ke-x-f1 :ke-x-tsuki :ke-x-f2 :ke-x-meteor)))

;;; ---------------------------------------------------------------- the Bankai (docs/duel/DUEL_KEN_BANKAI.md §12): the oni
;; The feral pass (the user's request 2026-09-28, 「更野性」): a beast, not a swordsman. A deep forward-leaning crouch on
;; bent, splayed legs, the back rounded and the shoulders hunched over it, the head low and thrust forward, the eyes up;
;; the arms hang loose and wide, the left hand a claw, the broken cleaver dragged low behind him in the right. His strikes
;; lunge from the crouch. Art only: the moves' S / A / R, reach and hit volumes are unchanged.
(defpose :ke-b-stance (:base :ke-stance)
  (:root :u -0.3 :f 0.04) (:pelvis :twist 16) (:spine :flex 40) (:chest :flex 16 :twist -10) (:neck :flex 8)
  (:head :flex -58 :twist -6)
  (:arm-r :flex -16 :side 30 :twist 0) (:elbow-r :flex 22) (:hand-r :flex -100 :twist 10)
  (:arm-l :flex 40 :side 42) (:elbow-l :flex 60) (:hand-l :flex 45)
  (:thigh-r :flex -12 :side 22) (:knee-r :flex 60) (:thigh-l :flex 62 :side 22) (:knee-l :flex 84))
;; the idle: the back heaves (breath through the teeth), the claw flexing, the blade tip scraping
(defclip :ke-b-stance (0.8 :loop t :base :ke-b-stance)
  (0) (0.4 (:chest :flex 24) (:spine :flex 38) (:root :u -0.33) (:head :flex -62) (:hand-l :flex 60) (:elbow-l :flex 70)
           (:hand-r :flex -96)))
;; the V3 Bankai's two stances (DUEL_KEN_V3 §27; the user's figures in .refs/kenpachi-v3/, §5.4): 狂嵐 (from pointer 1) the long haft
;; on the right shoulder, the head up behind his left, legs splayed wide and deep, the left claw hanging by the knee
;; (bankai-p2-shoulder-figure.png; the arm by FK: the grip (0.34 1.34 0.31) r u f, the head up to 1.86 m behind him, the edge up);
;; 斬壞 (from pointer 2) the beast crouch, both arms out wide, the head trailing low out to his right, the butt up behind the
;; right shoulder (bankai-p1-low-figure.png; the grip (0.61 0.86 0.14), the edge forward)
(defpose :ke-b-kr-stance (:base :ke-stance)
  (:root :u -0.36 :f 0.02) (:pelvis :twist 6) (:spine :flex 22 :twist 0) (:chest :flex 6 :twist -8) (:neck :flex 4) (:head :flex -30 :twist 4)
  (:arm-r :flex 92 :side -32 :twist 1) (:elbow-r :flex 151) (:hand-r :flex -52 :twist 30 :side -4)
  (:arm-l :flex 6 :side 34 :twist 0) (:elbow-l :flex 36) (:hand-l :flex 50)
  (:thigh-l :flex 48 :side 36) (:knee-l :flex 82) (:thigh-r :flex 40 :side 38) (:knee-r :flex 78))
(defclip :ke-b-kr-stance (1.0 :loop t :base :ke-b-kr-stance)
  (0) (0.5 (:root :u -0.38) (:chest :flex 9) (:hand-l :flex 60)))                      ; the shoulders rolling, the claw flexing
(defpose :ke-b-zh-stance (:base :ke-stance)
  (:root :u -0.34 :f 0.04) (:pelvis :twist 10) (:spine :flex 38) (:chest :flex 14 :twist -6) (:neck :flex 8) (:head :flex -56 :twist -4)
  (:arm-r :flex -16 :side 55 :twist 30) (:elbow-r :flex 61) (:hand-r :flex 132 :twist -94 :side -41)
  (:arm-l :flex 24 :side 66 :twist 0) (:elbow-l :flex 64) (:hand-l :flex 50)
  (:thigh-r :flex 20 :side 30) (:knee-r :flex 70) (:thigh-l :flex 56 :side 26) (:knee-l :flex 84))
(defclip :ke-b-zh-stance (0.8 :loop t :base :ke-b-zh-stance)
  (0) (0.4 (:chest :flex 22) (:spine :flex 36) (:root :u -0.37) (:head :flex -60) (:hand-l :flex 62) (:elbow-l :flex 72)))   ; heaving
;;; 狂嵐's J1-J5 (DUEL_KEN_V3 §28): one hand, fast, the haft flourished; each link one arc, its frame 0 the pose the link before
;;; lands in (:ke-kr-aN). Arms solved by FK on the host: the tip (1.06 m past the grip) 1.85-1.94 m out on the hit frame
;;; against the 1.8 m volume. J1 off the shoulder, high right -> low left; J2 the backhand rising, low left -> high right;
;;; J3 the haft twirled once at his right side, then flat at the waist, right -> left; J4 dropped into a crouch, the backhand
;;; at the shins, left -> right; J5 one full turn to his left, the head carried over the shoulder, the big diagonal down.
;;; A full turn of the wrist (J3) or the root (J5) is rewound on a key 0.001 s after it, the same orientation, so nothing
;;; unwinds through the next key or the next clip.
(defpose :ke-kr-c1 (:base :ke-b-kr-stance)              ; cocked: flipped up over the right shoulder, the head up behind
  (:root :u -0.3 :f -0.04) (:pelvis :twist 22) (:spine :flex 10 :side 0) (:chest :flex 0 :twist -40) (:head :flex -20 :twist 10)
  (:arm-r :flex 101 :side -17 :twist -2) (:elbow-r :flex 110) (:hand-r :flex -79 :twist -23 :side -3)
  (:arm-l :flex 55 :side 35 :twist 0) (:elbow-l :flex 40) (:hand-l :flex 10)
  (:thigh-l :flex 45 :side 34) (:knee-l :flex 70) (:thigh-r :flex 30 :side 36) (:knee-r :flex 66))
(defpose :ke-kr-h1 (:base :ke-b-kr-stance)              ; J1's hit: through the front, down to his left, the right foot in
  (:root :u -0.2 :f 0.3) (:pelvis :twist -8) (:spine :flex 22 :side 0) (:chest :flex 0 :twist 22) (:head :flex -12 :twist -6)
  (:arm-r :flex 49 :side -35 :twist 4) (:elbow-r :flex 99) (:hand-r :flex -153 :twist -1 :side 0)
  (:arm-l :flex -20 :side 60 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-r :flex 50 :side 20) (:knee-r :flex 55) (:thigh-l :flex -15 :side 25) (:knee-l :flex 30))
(defpose :ke-kr-a1 (:base :ke-b-kr-stance)              ; J1 landed: the head low by his left foot, the chest turned after it
  (:root :u -0.22 :f 0.32) (:pelvis :twist -12) (:spine :flex 32 :side 0) (:chest :flex 0 :twist 45) (:head :flex -14 :twist -10)
  (:arm-r :flex 17 :side -40 :twist 4) (:elbow-r :flex 50) (:hand-r :flex -66 :twist -20 :side 1)
  (:arm-l :flex -25 :side 55 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-r :flex 50 :side 20) (:knee-r :flex 55) (:thigh-l :flex -15 :side 25) (:knee-l :flex 30))
(defpose :ke-kr-h2 (:base :ke-b-kr-stance)              ; J2's hit: rising through the front to his right, the free arm flung
  (:root :u -0.16 :f 0.22) (:pelvis :twist 12) (:spine :flex 10 :side -6) (:chest :flex 0 :twist -22) (:head :flex -8 :twist 8)
  (:arm-r :flex 113 :side 105 :twist 21) (:elbow-r :flex 30) (:hand-r :flex -168 :twist -1 :side -8)
  (:arm-l :flex 20 :side 70 :twist 0) (:elbow-l :flex 15) (:hand-l :flex 10)
  (:thigh-l :flex 40 :side 20) (:knee-l :flex 40) (:thigh-r :flex -10 :side 25) (:knee-r :flex 25))
(defpose :ke-kr-a2 (:base :ke-b-kr-stance)              ; J2 landed: the head up high to his right, risen on the left foot
  (:root :u -0.15 :f 0.26) (:pelvis :twist 18) (:spine :flex 4 :side -8) (:chest :flex 0 :twist -40) (:head :flex -12 :twist 12)
  (:arm-r :flex 59 :side -40 :twist 0) (:elbow-r :flex 119) (:hand-r :flex -120 :twist 28 :side 1)
  (:arm-l :flex 30 :side 80 :twist 0) (:elbow-l :flex 10) (:hand-l :flex 10)
  (:thigh-l :flex 40 :side 20) (:knee-l :flex 40) (:thigh-r :flex -12 :side 25) (:knee-r :flex 22))
(defpose :ke-kr-c3 (:base :ke-b-kr-stance)              ; J3 cocked: the head laid out flat to his right, behind
  (:root :u -0.2 :f 0.08) (:pelvis :twist 22) (:spine :flex 12 :side 4) (:chest :flex 0 :twist -48) (:head :flex -10 :twist 18)
  (:arm-r :flex 26 :side 5 :twist -15) (:elbow-r :flex 56) (:hand-r :flex 13 :twist -92 :side -10)
  (:arm-l :flex 50 :side 25 :twist 0) (:elbow-l :flex 50) (:hand-l :flex 10)
  (:thigh-l :flex 35 :side 26) (:knee-l :flex 45) (:thigh-r :flex -5 :side 30) (:knee-r :flex 38))
(defpose :ke-kr-h3 (:base :ke-b-kr-stance)              ; J3's hit: flat at the waist, through the front to his left
  (:root :u -0.22 :f 0.3) (:pelvis :twist -12) (:spine :flex 16 :side 0) (:chest :flex 0 :twist 28) (:head :flex -8 :twist -10)
  (:arm-r :flex 44 :side -40 :twist -29) (:elbow-r :flex 93) (:hand-r :flex -152 :twist 37 :side 6)
  (:arm-l :flex 0 :side 65 :twist 0) (:elbow-l :flex 15) (:hand-l :flex 10)
  (:thigh-r :flex 50 :side 18) (:knee-r :flex 50) (:thigh-l :flex -20 :side 25) (:knee-l :flex 25))
(defpose :ke-kr-a3 (:base :ke-b-kr-stance)              ; J3 landed: swept round to his left, the weight carrying him on
  (:root :u -0.24 :f 0.38 :yaw 18) (:pelvis :twist -20) (:spine :flex 18 :side 0) (:chest :flex 0 :twist 50) (:head :flex -8 :twist -18)
  (:arm-r :flex 4 :side -40 :twist -14) (:elbow-r :flex 93) (:hand-r :flex -131 :twist 47 :side 8)
  (:arm-l :flex -10 :side 70 :twist 0) (:elbow-l :flex 15) (:hand-l :flex 10)
  (:thigh-r :flex 55 :side 18) (:knee-r :flex 55) (:thigh-l :flex -22 :side 25) (:knee-l :flex 24))
(defpose :ke-kr-c4 (:base :ke-b-kr-stance)              ; J4 cocked: dropped into the crouch, the head low out to his left
  (:root :u -0.44 :f 0.12) (:pelvis :twist -14) (:spine :flex 40 :side 4) (:chest :flex 6 :twist 40) (:head :flex -34 :twist -10)
  (:arm-r :flex 119 :side 104 :twist 24) (:elbow-r :flex 49) (:hand-r :flex -109 :twist -7 :side -3)
  (:arm-l :flex 40 :side 30 :twist 0) (:elbow-l :flex 50) (:hand-l :flex 30)
  (:thigh-l :flex 70 :side 30) (:knee-l :flex 100) (:thigh-r :flex 16 :side 44) (:knee-r :flex 56))
(defpose :ke-kr-h4 (:base :ke-b-kr-stance)              ; J4's hit: the backhand at the shins, through the front to his right
  (:root :u -0.44 :f 0.1) (:pelvis :twist 14) (:spine :flex 40 :side -4) (:chest :flex 6 :twist -26) (:head :flex -34 :twist 8)
  (:arm-r :flex 114 :side 91 :twist -10) (:elbow-r :flex 13) (:hand-r :flex -142 :twist -29 :side 11)
  (:arm-l :flex 10 :side 60 :twist 0) (:elbow-l :flex 30) (:hand-l :flex 30)
  (:thigh-l :flex 70 :side 30) (:knee-l :flex 100) (:thigh-r :flex 16 :side 44) (:knee-r :flex 56))
(defpose :ke-kr-a4 (:base :ke-b-kr-stance)              ; J4 landed: the head low out to his right, still crouched
  (:root :u -0.44 :f 0.12 :yaw -14) (:pelvis :twist 20) (:spine :flex 40 :side -6) (:chest :flex 6 :twist -45) (:head :flex -34 :twist 12)
  (:arm-r :flex 38 :side -1 :twist 11) (:elbow-r :flex 53) (:hand-r :flex -132 :twist -61 :side -4)
  (:arm-l :flex 0 :side 70 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 30)
  (:thigh-l :flex 70 :side 30) (:knee-l :flex 100) (:thigh-r :flex 16 :side 44) (:knee-r :flex 56))
(defpose :ke-kr-h5 (:base :ke-b-kr-stance)              ; J5's hit: the big diagonal, the lunge at its deepest
  (:root :u -0.3 :f 0.4) (:pelvis :twist -10) (:spine :flex 30 :side 0) (:chest :flex 0 :twist 26) (:head :flex -16 :twist -6)
  (:arm-r :flex 41 :side -33 :twist 4) (:elbow-r :flex 120) (:hand-r :flex -165 :twist -7 :side 1)
  (:arm-l :flex -30 :side 55 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-r :flex 60 :side 18) (:knee-r :flex 70) (:thigh-l :flex -22 :side 25) (:knee-l :flex 30))
(defpose :ke-kr-a5 (:base :ke-b-kr-stance)              ; J5 landed: folded over the lunge, the head on the floor to his left
  (:root :u -0.34 :f 0.44) (:pelvis :twist -14) (:spine :flex 40 :side 0) (:chest :flex 0 :twist 34) (:head :flex -22 :twist -8)
  (:arm-r :flex 23 :side -16 :twist 0) (:elbow-r :flex 70) (:hand-r :flex -102 :twist 11 :side 0)
  (:arm-l :flex -35 :side 55 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-r :flex 64 :side 18) (:knee-r :flex 78) (:thigh-l :flex -22 :side 25) (:knee-l :flex 30))
(defstrike :ke-kr-cut1 (7 3 11 :base :ke-b-kr-stance)
  (0 :ke-b-kr-stance)
  (4 :ke-kr-c1)
  (5 (:root :u -0.31 :f -0.05) (:chest :twist -43) (:arm-r :flex 104))                            ; cocked, held
  (:s :snap :ke-kr-h1)
  (:a :ke-kr-a1)
  (15 (:root :f 0.3) (:chest :twist 40))
  (:end :ke-b-kr-stance))
(defstrike :ke-kr-cut2 (7 3 12 :base :ke-b-kr-stance)
  (0 :ke-kr-a1)
  (3 (:root :u -0.26 :f 0.26) (:spine :flex 34 :side 6) (:chest :twist 58) (:hand-r :twist 60))    ; coiled lower, the wrist turned
  (5 (:root :u -0.27) (:chest :twist 61))                                                          ; held
  (:s :snap :ke-kr-h2)
  (:a :ke-kr-a2)
  (16 (:root :f 0.24) (:chest :twist -36))
  (:end :ke-b-kr-stance))
(defstrike :ke-kr-cut3 (8 3 12 :base :ke-b-kr-stance)
  (0 :ke-kr-a2)
  (1 (:arm-r :flex 80 :side 20) (:elbow-r :flex 60) (:hand-r :side 91) (:root :u -0.17))         ; the twirl out front: a key every 90 deg
  (2 (:hand-r :side 181) (:chest :twist -44))
  (3 (:hand-r :side 271) (:root :u -0.2))
  (4 (:hand-r :side 361) (:chest :twist -46))
  (4.001 (:hand-r :side 1))                                                                        ; (the same orientation)
  (6 :ke-kr-c3)
  (7 (:root :u -0.21) (:chest :twist -51))                                                         ; held
  (:s :snap :ke-kr-h3)
  (:a :ke-kr-a3)
  (17 (:root :yaw 22) (:chest :twist 54))
  (:end :ke-b-kr-stance))
(defstrike :ke-kr-cut4 (8 3 13 :base :ke-b-kr-stance)
  (0 :ke-kr-a3)
  (3 :ke-kr-c4)
  (6 (:root :u -0.46) (:chest :twist 43))                                                          ; coiled, held
  (:s :snap :ke-kr-h4)
  (9 (:root :yaw -6) (:pelvis :twist 18) (:chest :twist -38))                                       ; carried round on the hips
  (:a :ke-kr-a4)
  (18 (:root :yaw -16) (:chest :twist -48))
  (:end :ke-b-kr-stance))
(defstrike :ke-kr-cut5 (10 4 18 :base :ke-b-kr-stance)
  (0 :ke-kr-a4)
  (2 :ke-kr-c1 (:root :u -0.2 :f 0.1 :yaw 80))                                                    ; risen, the head flung up, turning left
  (4 (:root :yaw 170 :u -0.16) (:chest :twist -30))                                               ; his back to the foe
  (6 (:root :yaw 260 :u -0.2) (:chest :twist -38))
  (8 (:root :yaw 325 :u -0.28 :f 0.0) (:chest :twist -46) (:arm-r :flex 108))                     ; round, cocked
  (9 (:root :yaw 330 :u -0.29) (:chest :twist -48))                                               ; held
  (:s :snap :ke-kr-h5 (:root :yaw 360))
  (10.001 (:root :yaw 0))                                                                          ; (the same facing)
  (:a :ke-kr-a5)
  (22 (:root :yaw 12) (:chest :twist 40))
  (:end :ke-b-kr-stance))
;;; 斬壞's J1-J5 (DUEL_KEN_V3 §28): heavy, the head dragged, 由緩至急 in each link: a slow charge (a small first key, then
;;; the coil), a held tremble, the release in the last 2 frames, the hit, the weight dragging back. Tip 1.93-1.98 m out on
;;; the hit frame against the 1.9 m volume (FK). J1 dragged off the floor, low right -> high left; J2 hoisted overhead from
;;; there, chopped down the centre; J3 the head dragged flat along the floor, right -> left (the 140 deg volume); J4 the
;;; backhand dragged up, low left -> high right; J5 both hands, wound behind the right shoulder, slammed into the floor.
(defpose :ke-zh-c1 (:base :ke-b-zh-stance)              ; J1 coiled: the head dragged back on the floor behind his right foot
  (:root :u -0.42 :f -0.04) (:pelvis :twist 18) (:spine :flex 40 :side 0) (:chest :flex 10 :twist -36) (:head :flex -50 :twist 12)
  (:arm-r :flex 23 :side 40 :twist 6) (:elbow-r :flex 0) (:hand-r :flex 56 :twist 95 :side 42)
  (:arm-l :flex 40 :side 60 :twist 0) (:elbow-l :flex 50) (:hand-l :flex 50)
  (:thigh-r :flex 40 :side 34) (:knee-r :flex 84) (:thigh-l :flex 56 :side 30) (:knee-l :flex 96))
(defpose :ke-zh-h1 (:base :ke-b-zh-stance)              ; J1's hit: ripped up through the front to his left
  (:root :u -0.24 :f 0.36) (:pelvis :twist -14) (:spine :flex 26 :side 0) (:chest :flex 0 :twist 26) (:head :flex -22 :twist -8)
  (:arm-r :flex 43 :side -42 :twist -26) (:elbow-r :flex 91) (:hand-r :flex 172 :twist 71 :side 28)
  (:arm-l :flex 10 :side 75 :twist 0) (:elbow-l :flex 30) (:hand-l :flex 40)
  (:thigh-r :flex 50 :side 22) (:knee-r :flex 60) (:thigh-l :flex -14 :side 28) (:knee-l :flex 34))
(defpose :ke-zh-a1 (:base :ke-b-zh-stance)              ; J1 landed: the head up high to his left
  (:root :u -0.26 :f 0.38) (:pelvis :twist -18) (:spine :flex 14 :side 6) (:chest :flex 0 :twist 42) (:head :flex -14 :twist -14)
  (:arm-r :flex 145 :side 81 :twist 2) (:elbow-r :flex 61) (:hand-r :flex 181 :twist -50 :side -4)
  (:arm-l :flex -10 :side 70 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 40)
  (:thigh-r :flex 50 :side 22) (:knee-r :flex 60) (:thigh-l :flex -14 :side 28) (:knee-l :flex 34))
(defpose :ke-zh-c2 (:base :ke-b-zh-stance)              ; J2 coiled: hoisted straight up, the head hanging behind, arched back
  (:root :u -0.1 :f 0.12) (:pelvis :twist 0) (:spine :flex -14 :side 0) (:chest :flex 0 :twist -6) (:head :flex -12 :twist 0)
  (:arm-r :flex 115 :side 10 :twist 1) (:elbow-r :flex 89) (:hand-r :flex -64 :twist -13 :side 1)
  (:arm-l :flex 130 :side 40 :twist 0) (:elbow-l :flex 30) (:hand-l :flex 30)
  (:thigh-r :flex 24 :side 20) (:knee-r :flex 30) (:thigh-l :flex 10 :side 24) (:knee-l :flex 24))
(defpose :ke-zh-h2 (:base :ke-b-zh-stance)              ; J2's hit: down the centre line, the right foot in
  (:root :u -0.29 :f 0.42) (:pelvis :twist 0) (:spine :flex 40 :side 0) (:chest :flex 0 :twist 4) (:head :flex -26 :twist 0)
  (:arm-r :flex 61 :side 6 :twist 6) (:elbow-r :flex 122) (:hand-r :flex -173 :twist -4 :side 6)
  (:arm-l :flex -20 :side 50 :twist 0) (:elbow-l :flex 25) (:hand-l :flex 40)
  (:thigh-r :flex 50 :side 22) (:knee-r :flex 60) (:thigh-l :flex -14 :side 28) (:knee-l :flex 34))
(defpose :ke-zh-a2 (:base :ke-b-zh-stance)              ; J2 landed: folded over it, the head on the floor ahead
  (:root :u -0.32 :f 0.44) (:pelvis :twist 0) (:spine :flex 52 :side 0) (:chest :flex 0 :twist 4) (:head :flex -32 :twist 0)
  (:arm-r :flex 17 :side -15 :twist 1) (:elbow-r :flex 111) (:hand-r :flex -114 :twist 6 :side 1)
  (:arm-l :flex -30 :side 50 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 40)
  (:thigh-r :flex 50 :side 22) (:knee-r :flex 60) (:thigh-l :flex -14 :side 28) (:knee-l :flex 34))
(defpose :ke-zh-c3 (:base :ke-b-zh-stance)              ; J3 coiled: squatted, the head dragged out on the floor to his right
  (:root :u -0.44 :f 0.2) (:pelvis :twist 20) (:spine :flex 46 :side -4) (:chest :flex 6 :twist -40) (:head :flex -40 :twist 14)
  (:arm-r :flex 21 :side 28 :twist 32) (:elbow-r :flex 27) (:hand-r :flex 114 :twist -94 :side -28)
  (:arm-l :flex 30 :side 50 :twist 0) (:elbow-l :flex 50) (:hand-l :flex 50)
  (:thigh-r :flex 40 :side 34) (:knee-r :flex 84) (:thigh-l :flex 56 :side 30) (:knee-l :flex 96))
(defpose :ke-zh-h3 (:base :ke-b-zh-stance)              ; J3's hit: the head along the floor through the front
  (:root :u -0.44 :f 0.32) (:pelvis :twist -6) (:spine :flex 46 :side 0) (:chest :flex 6 :twist 12) (:head :flex -40 :twist -4)
  (:arm-r :flex 60 :side -41 :twist -13) (:elbow-r :flex 80) (:hand-r :flex -142 :twist 46 :side 10)
  (:arm-l :flex 0 :side 70 :twist 0) (:elbow-l :flex 30) (:hand-l :flex 50)
  (:thigh-r :flex 40 :side 34) (:knee-r :flex 84) (:thigh-l :flex 56 :side 30) (:knee-l :flex 96))
(defpose :ke-zh-a3 (:base :ke-b-zh-stance)              ; J3 landed: swept on round to his left, still on the floor
  (:root :u -0.44 :f 0.32 :yaw 16) (:pelvis :twist -20) (:spine :flex 46 :side 4) (:chest :flex 6 :twist 44) (:head :flex -40 :twist -14)
  (:arm-r :flex 24 :side -33 :twist 0) (:elbow-r :flex 71) (:hand-r :flex -110 :twist 26 :side 0)
  (:arm-l :flex -10 :side 70 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 50)
  (:thigh-r :flex 40 :side 34) (:knee-r :flex 84) (:thigh-l :flex 56 :side 30) (:knee-l :flex 96))
(defpose :ke-zh-c4 (:base :ke-b-zh-stance)              ; J4 coiled: the head dragged on behind his left, wound round
  (:root :u -0.44 :f 0.2 :yaw 18) (:pelvis :twist -22) (:spine :flex 46 :side 6) (:chest :flex 6 :twist 52) (:head :flex -40 :twist -16)
  (:arm-r :flex 101 :side 104 :twist 35) (:elbow-r :flex 69) (:hand-r :flex -135 :twist -13 :side -10)
  (:arm-l :flex 30 :side 40 :twist 0) (:elbow-l :flex 50) (:hand-l :flex 50)
  (:thigh-r :flex 40 :side 34) (:knee-r :flex 84) (:thigh-l :flex 56 :side 30) (:knee-l :flex 96))
(defpose :ke-zh-h4 (:base :ke-b-zh-stance)              ; J4's hit: dragged up through the front to his right, the left foot in
  (:root :u -0.24 :f 0.34) (:pelvis :twist 12) (:spine :flex 16 :side -6) (:chest :flex 0 :twist -22) (:head :flex -14 :twist 8)
  (:arm-r :flex 112 :side 104 :twist 16) (:elbow-r :flex 31) (:hand-r :flex -174 :twist -15 :side -7)
  (:arm-l :flex 20 :side 75 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 40)
  (:thigh-l :flex 48 :side 22) (:knee-l :flex 58) (:thigh-r :flex -12 :side 28) (:knee-r :flex 32))
(defpose :ke-zh-a4 (:base :ke-b-zh-stance)              ; J4 landed: the head up high to his right
  (:root :u -0.24 :f 0.34) (:pelvis :twist 18) (:spine :flex 6 :side -8) (:chest :flex 0 :twist -40) (:head :flex -12 :twist 12)
  (:arm-r :flex 86 :side -40 :twist -2) (:elbow-r :flex 127) (:hand-r :flex -151 :twist 22 :side -1)
  (:arm-l :flex 30 :side 80 :twist 0) (:elbow-l :flex 15) (:hand-l :flex 40)
  (:thigh-l :flex 48 :side 22) (:knee-l :flex 58) (:thigh-r :flex -12 :side 28) (:knee-r :flex 32))
(defpose :ke-zh-c5 (:base :ke-b-zh-stance)              ; J5 coiled: both hands up over the right shoulder, the head hanging down his back
  (:root :u -0.2 :f -0.04) (:pelvis :twist 14) (:spine :flex -16 :side 0) (:chest :flex 0 :twist -24) (:head :flex -10 :twist 8)
  (:arm-r :flex 113 :side 15 :twist -3) (:elbow-r :flex 62) (:hand-r :flex 31 :twist -18 :side 6)
  (:arm-l :flex 156 :side 45 :twist 0) (:elbow-l :flex 0) (:hand-l :flex 20)
  (:thigh-r :flex 28 :side 26) (:knee-r :flex 46) (:thigh-l :flex 18 :side 28) (:knee-l :flex 42))
(defpose :ke-zh-h5 (:base :ke-b-zh-stance)              ; J5's hit: slammed into the floor ahead, the deepest lunge
  (:root :u -0.36 :f 0.5) (:pelvis :twist 0) (:spine :flex 50 :side 0) (:chest :flex 0 :twist 0) (:head :flex -30 :twist 0)
  (:arm-r :flex 50 :side -4 :twist 14) (:elbow-r :flex 116) (:hand-r :flex -155 :twist -4 :side 4)
  (:arm-l :flex 127 :side 83 :twist 0) (:elbow-l :flex 0) (:hand-l :flex 20)
  (:thigh-r :flex 66 :side 16) (:knee-r :flex 86) (:thigh-l :flex -20 :side 22) (:knee-l :flex 36))
(defpose :ke-zh-a5 (:base :ke-b-zh-stance)              ; J5 landed: folded over the head buried in the floor
  (:root :u -0.38 :f 0.52) (:pelvis :twist 0) (:spine :flex 58 :side 0) (:chest :flex 0 :twist 0) (:head :flex -34 :twist 0)
  (:arm-r :flex 61 :side 100 :twist 0) (:elbow-r :flex 113) (:hand-r :flex -169 :twist -16 :side -1)
  (:arm-l :flex 122 :side 83 :twist 0) (:elbow-l :flex 0) (:hand-l :flex 20)
  (:thigh-r :flex 70 :side 16) (:knee-r :flex 94) (:thigh-l :flex -20 :side 22) (:knee-l :flex 40))
(defstrike :ke-zh-cut1 (9 3 12 :base :ke-b-zh-stance)
  (0 :ke-b-zh-stance)
  (1 (:root :u -0.35) (:chest :twist -8) (:arm-r :side 52))                                        ; the charge: barely moving
  (6 :snap :ke-zh-c1)                                                                              ; gathering (linear: no ease-out burst)
  (7 (:root :u -0.43) (:chest :twist -38) (:hand-r :flex 58))                                      ; held, trembling
  (:s :snap :ke-zh-h1)                                                                             ; the release, 2 frames
  (10 (:root :f 0.38) (:chest :twist 30))                                                          ; past it
  (:a :ke-zh-a1)
  (18 (:root :u -0.27 :f 0.36) (:chest :twist 38))
  (:end :ke-b-zh-stance))
(defstrike :ke-zh-cut2 (10 3 13 :base :ke-b-zh-stance)
  (0 :ke-zh-a1)
  (3 (:root :u -0.22) (:chest :twist 30) (:arm-r :flex 150))                                       ; the charge: barely moving
  (7 :snap :ke-zh-c2)                                                                              ; gathering
  (8 (:root :u -0.11) (:spine :flex -16) (:arm-r :flex 117))                                       ; held, trembling
  (:s :snap :ke-zh-h2)                                                                             ; the release, 2 frames
  (11 (:root :u -0.31) (:spine :flex 44))                                                          ; past it
  (:a :ke-zh-a2)
  (19 (:root :u -0.31) (:spine :flex 48))
  (:end :ke-b-zh-stance))
(defstrike :ke-zh-cut3 (10 4 16 :base :ke-b-zh-stance)
  (0 :ke-zh-a2)
  (3 (:root :u -0.3 :f 0.36) (:chest :twist -8) (:arm-r :side 0))                                 ; the charge: barely moving
  (7 :snap :ke-zh-c3)                                                                              ; gathering
  (8 (:root :u -0.45) (:chest :twist -42) (:arm-r :side 30))                                       ; held, trembling
  (:s :snap :ke-zh-h3)                                                                             ; the release, 2 frames
  (:a :ke-zh-a3)
  (22 (:root :yaw 20) (:chest :twist 48))
  (:end :ke-b-zh-stance))
(defstrike :ke-zh-cut4 (11 3 16 :base :ke-b-zh-stance)
  (0 :ke-zh-a3)
  (3 (:root :yaw 17) (:chest :twist 46) (:arm-r :flex 50 :side 40))                                ; the charge: barely moving
  (8 :snap :ke-zh-c4)                                                                              ; gathering
  (9 (:root :u -0.45) (:chest :twist 54) (:arm-r :side 106))                                       ; held, trembling
  (:s :snap :ke-zh-h4)                                                                             ; the release, 2 frames
  (12 (:root :u -0.23) (:chest :twist -30))                                                        ; past it
  (:a :ke-zh-a4)
  (21 (:root :u -0.25) (:chest :twist -36))
  (:end :ke-b-zh-stance))
(defstrike :ke-zh-cut5 (13 4 20 :base :ke-b-zh-stance)
  (0 :ke-zh-a4)
  (3 (:root :u -0.24 :f 0.28) (:chest :twist -36) (:arm-l :flex 70 :side 50) (:elbow-l :flex 30))  ; the charge: the left hand coming
  (9 :snap :ke-zh-c5)                                                                              ; gathering
  (10 (:root :u -0.22) (:spine :flex -18) (:chest :twist -26))                                     ; held, trembling
  (11 (:root :u -0.22) (:spine :flex -18) (:chest :twist -27))
  (:s :snap :ke-zh-h5)                                                                             ; the release, 2 frames
  (14 (:root :u -0.39) (:spine :flex 54))                                                          ; the jolt into the floor
  (:a :ke-zh-a5)
  (27 (:root :u -0.37) (:spine :flex 56))
  (:end :ke-b-zh-stance))
(pushnew :ke-zh-cut5 *grip-clips*)                      ; (J5 two-handed: the left fist on the handle, GRIP-LEFT!)
;;; 狂嵐's NS a-d and the AS finisher (DUEL_KEN_V3 §29): planes the J string doesn't use. a the tell (crouched, the head trailing
;;; on the floor behind his right, held), the rising cut low right -> high left on the 3 m lunge; b one full turn to his right,
;;; the arm straight out, a flat circle at the shoulder; c crouched, one full turn to his left at the knees; d the haft spun
;;; flat over his head like a propeller, then the cross: overhead right steep down to his left, high left down to his right;
;;; the finisher a leap, one turn in the air, the vertical chop down the centre on landing. Arms by FK; frame 0 of b / c / d
;;; is the segment before's landing (an NS links on as soon as its active frames end); a and the finisher blend in (:blend 3).
;;; The full turns (root yaw, the wrist's twist) are rewound 0.001 s after, the same orientation.
(defpose :ke-kr-na-c (:base :ke-b-kr-stance)            ; NS a's tell: squatted, the head on the floor behind his right
  (:root :u -0.4 :f -0.06) (:pelvis :twist 20) (:spine :flex 50 :side 0) (:chest :flex 8 :twist -34) (:head :flex -46 :twist 10)
  (:arm-r :flex 23 :side 26 :twist 30) (:elbow-r :flex 0) (:hand-r :flex 79 :twist 94 :side 38)
  (:arm-l :flex 50 :side 40 :twist 0) (:elbow-l :flex 60) (:hand-l :flex 50)
  (:thigh-l :flex 70 :side 30) (:knee-l :flex 104) (:thigh-r :flex 20 :side 40) (:knee-r :flex 80))
(defpose :ke-kr-na-h (:base :ke-b-kr-stance)            ; its hit: rising through the front to his left, lunged
  (:root :u -0.22 :f 0.4) (:pelvis :twist -14) (:spine :flex 18 :side 0) (:chest :flex 0 :twist 30) (:head :flex -12 :twist -8)
  (:arm-r :flex 30 :side -43 :twist -14) (:elbow-r :flex 70) (:hand-r :flex 184 :twist 91 :side 35)
  (:arm-l :flex -30 :side 50 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-r :flex 55 :side 18) (:knee-r :flex 60) (:thigh-l :flex -20 :side 25) (:knee-l :flex 30))
(defpose :ke-kr-na-a (:base :ke-b-kr-stance)            ; landed: the head up high to his left
  (:root :u -0.23 :f 0.42) (:pelvis :twist -18) (:spine :flex 4 :side 6) (:chest :flex 0 :twist 48) (:head :flex -10 :twist -12)
  (:arm-r :flex 141 :side 70 :twist 0) (:elbow-r :flex 56) (:hand-r :flex 259 :twist -39 :side 0)
  (:arm-l :flex -30 :side 60 :twist 0) (:elbow-l :flex 15) (:hand-l :flex 10)
  (:thigh-r :flex 55 :side 18) (:knee-r :flex 55) (:thigh-l :flex -20 :side 25) (:knee-l :flex 28))
(defpose :ke-kr-nb-w (:base :ke-b-kr-stance)            ; NS b wound: turned to his left, the arm across, the head back
  (:root :u -0.3 :f 0.1 :yaw 30) (:pelvis :twist -16) (:spine :flex 16 :side 0) (:chest :flex 0 :twist 40) (:head :flex -14 :twist -20)
  (:arm-r :flex 16 :side -43 :twist 19) (:elbow-r :flex 100) (:hand-r :flex -172 :twist 40 :side 17)
  (:arm-l :flex 10 :side 40 :twist 0) (:elbow-l :flex 40) (:hand-l :flex 10)
  (:thigh-l :flex 40 :side 30) (:knee-l :flex 60) (:thigh-r :flex 30 :side 34) (:knee-r :flex 60))
(defpose :ke-kr-nb-s (:base :ke-b-kr-stance)            ; the spin: the arm straight out at the shoulder, the blade on from it
  (:root :u -0.2 :f 0.06) (:pelvis :twist 0) (:spine :flex 12 :side -4) (:chest :flex 0 :twist -10) (:head :flex -12 :twist 0)
  (:arm-r :flex -21 :side 94 :twist -6) (:elbow-r :flex 81) (:hand-r :flex -123 :twist 1 :side 3)
  (:arm-l :flex 30 :side 75 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-l :flex 30 :side 30) (:knee-l :flex 50) (:thigh-r :flex 30 :side 30) (:knee-r :flex 50))
(defpose :ke-kr-nb-a (:base :ke-kr-nb-s)                ; landed: round, settling
  (:root :u -0.22) (:spine :flex 16) (:chest :twist -24))
(defpose :ke-kr-nc-w (:base :ke-b-kr-stance)            ; NS c wound: dropped, turned to his right, the head low behind
  (:root :u -0.44 :f 0.04 :yaw -30) (:pelvis :twist 18) (:spine :flex 40 :side 0) (:chest :flex 6 :twist -40) (:head :flex -36 :twist 14)
  (:arm-r :flex 37 :side 20 :twist -11) (:elbow-r :flex 10) (:hand-r :flex -114 :twist -30 :side 6)
  (:arm-l :flex 40 :side 40 :twist 0) (:elbow-l :flex 50) (:hand-l :flex 30)
  (:thigh-l :flex 70 :side 30) (:knee-l :flex 100) (:thigh-r :flex 20 :side 42) (:knee-r :flex 64))
(defpose :ke-kr-nc-s (:base :ke-b-kr-stance)            ; the low spin: squatted, the blade out at the knees
  (:root :u -0.44 :f 0.06) (:pelvis :twist 0) (:spine :flex 42 :side 4) (:chest :flex 6 :twist 0) (:head :flex -38 :twist 0)
  (:arm-r :flex 4 :side 51 :twist 4) (:elbow-r :flex 25) (:hand-r :flex -238 :twist -93 :side -32)
  (:arm-l :flex 20 :side 60 :twist 0) (:elbow-l :flex 40) (:hand-l :flex 30)
  (:thigh-l :flex 74 :side 32) (:knee-l :flex 104) (:thigh-r :flex 20 :side 46) (:knee-r :flex 62))
(defpose :ke-kr-nc-a (:base :ke-kr-nc-s)                ; landed: carried on round to his left
  (:root :yaw 16) (:chest :twist 20))
(defpose :ke-kr-nd-p (:base :ke-b-kr-stance)            ; NS d's propeller: risen, the arm up, the blade flat over his head
  (:root :u -0.2 :f 0.1) (:pelvis :twist 0) (:spine :flex 0 :side 0) (:chest :flex 0 :twist 0) (:head :flex -14 :twist 0)
  (:arm-r :flex 165 :side 10 :twist 0) (:elbow-r :flex 10) (:hand-r :flex 0 :twist 0 :side 0)
  (:arm-l :flex 20 :side 70 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-l :flex 30 :side 26) (:knee-l :flex 40) (:thigh-r :flex 20 :side 28) (:knee-r :flex 40))
(defpose :ke-kr-nd-c1 (:base :ke-b-kr-stance)           ; the cross, cocked: overhead right, the head up behind
  (:root :u -0.16 :f 0.1) (:pelvis :twist 16) (:spine :flex 4 :side 0) (:chest :flex 0 :twist -26) (:head :flex -14 :twist 8)
  (:arm-r :flex 143 :side -3 :twist -4) (:elbow-r :flex 92) (:hand-r :flex -94 :twist -22 :side 1)
  (:arm-l :flex 40 :side 40 :twist 0) (:elbow-l :flex 40) (:hand-l :flex 10)
  (:thigh-l :flex 30 :side 26) (:knee-l :flex 40) (:thigh-r :flex 20 :side 28) (:knee-r :flex 40))
(defpose :ke-kr-nd-d1 (:base :ke-b-kr-stance)           ; the first cut's hit: steep down through the front to his left
  (:root :u -0.24 :f 0.34) (:pelvis :twist -6) (:spine :flex 26 :side 0) (:chest :flex 0 :twist 16) (:head :flex -14 :twist -4)
  (:arm-r :flex 43 :side -17 :twist 12) (:elbow-r :flex 139) (:hand-r :flex -172 :twist -1 :side 4)
  (:arm-l :flex -10 :side 55 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-r :flex 50 :side 20) (:knee-r :flex 55) (:thigh-l :flex -15 :side 25) (:knee-l :flex 30))
(defpose :ke-kr-nd-c2 (:base :ke-b-kr-stance)           ; re-cocked: the backhand up over his left shoulder
  (:root :u -0.2 :f 0.3) (:pelvis :twist -14) (:spine :flex 8 :side 4) (:chest :flex 0 :twist 30) (:head :flex -12 :twist -10)
  (:arm-r :flex 172 :side 49 :twist 23) (:elbow-r :flex 35) (:hand-r :flex -85 :twist -18 :side 2)
  (:arm-l :flex -10 :side 60 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-r :flex 50 :side 20) (:knee-r :flex 55) (:thigh-l :flex -15 :side 25) (:knee-l :flex 30))
(defpose :ke-kr-nd-d2 (:base :ke-b-kr-stance)           ; the second cut's hit: down through the front to his right, the left foot in
  (:root :u -0.26 :f 0.38) (:pelvis :twist 6) (:spine :flex 28 :side 0) (:chest :flex 0 :twist -14) (:head :flex -14 :twist 4)
  (:arm-r :flex 45 :side 18 :twist 6) (:elbow-r :flex 147) (:hand-r :flex -179 :twist -13 :side 2)
  (:arm-l :flex 10 :side 60 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-l :flex 50 :side 20) (:knee-l :flex 55) (:thigh-r :flex -15 :side 25) (:knee-r :flex 30))
(defpose :ke-kr-nd-a (:base :ke-b-kr-stance)            ; landed: the head low out to his right
  (:root :u -0.3 :f 0.4) (:pelvis :twist 10) (:spine :flex 36 :side 0) (:chest :flex 0 :twist -30) (:head :flex -18 :twist 8)
  (:arm-r :flex 16 :side 7 :twist 0) (:elbow-r :flex 48) (:hand-r :flex -77 :twist -9 :side 0)
  (:arm-l :flex 10 :side 60 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-l :flex 50 :side 20) (:knee-l :flex 55) (:thigh-r :flex -15 :side 25) (:knee-r :flex 30))
(defpose :ke-kr-fin-up (:base :ke-b-kr-stance)          ; the finisher in the air: tucked, the head up behind his head
  (:root :u 0.2 :f 0.1) (:pelvis :twist 0) (:spine :flex -10 :side 0) (:chest :flex 0 :twist -6) (:head :flex -10 :twist 0)
  (:arm-r :flex 141 :side 10 :twist 1) (:elbow-r :flex 74) (:hand-r :flex -71 :twist -17 :side 1)
  (:arm-l :flex 60 :side 50 :twist 0) (:elbow-l :flex 40) (:hand-l :flex 10)
  (:thigh-l :flex 80 :side 20) (:knee-l :flex 110) (:thigh-r :flex 60 :side 20) (:knee-r :flex 110))
(defpose :ke-kr-fin-h (:base :ke-b-kr-stance)           ; its hit: landed, chopped straight down the centre
  (:root :u -0.3 :f 0.4) (:pelvis :twist 0) (:spine :flex 36 :side 0) (:chest :flex 0 :twist 0) (:head :flex -22 :twist 0)
  (:arm-r :flex 59 :side 7 :twist 7) (:elbow-r :flex 150) (:hand-r :flex -193 :twist -8 :side 8)
  (:arm-l :flex -20 :side 50 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-r :flex 60 :side 18) (:knee-r :flex 72) (:thigh-l :flex -18 :side 25) (:knee-l :flex 34))
(defpose :ke-kr-fin-a (:base :ke-b-kr-stance)           ; landed: folded over the head on the floor ahead
  (:root :u -0.4 :f 0.44) (:pelvis :twist 0) (:spine :flex 50 :side 0) (:chest :flex 0 :twist 0) (:head :flex -28 :twist 0)
  (:arm-r :flex 29 :side -39 :twist -1) (:elbow-r :flex 102) (:hand-r :flex -121 :twist 19 :side 0)
  (:arm-l :flex -30 :side 50 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-r :flex 70 :side 18) (:knee-r :flex 90) (:thigh-l :flex -18 :side 25) (:knee-l :flex 44))
(defstrike :ke-kr-ns-a (14 4 20 :base :ke-b-kr-stance)
  (0 :ke-b-kr-stance)
  (2 (:root :u -0.38 :f -0.02) (:spine :flex 36) (:chest :twist -22)
     (:arm-r :flex -11 :side 92 :twist 34) (:elbow-r :flex 130) (:hand-r :flex -17 :twist 92 :side -18))   ; the head lowered behind
  (4 :ke-kr-na-c)                                                                                  ; dropped into the tell
  (12 (:root :u -0.42 :f -0.08) (:chest :twist -37) (:arm-r :flex 21))                             ; held
  (:s :snap :ke-kr-na-h)
  (17 (:root :f 0.42) (:chest :twist 38))
  (:a :ke-kr-na-a)
  (18.001 (:hand-r :flex -101))                                                                    ; (the same orientation)
  (28 (:root :u -0.18) (:chest :twist 50))
  (:end :ke-b-kr-stance))
(defstrike :ke-kr-ns-b (10 4 18 :base :ke-b-kr-stance)
  (0 :ke-kr-na-a (:hand-r :flex -101))
  (3 :ke-kr-nb-w)                                                                                  ; wound to his left
  (4 (:root :yaw -5) (:arm-r :flex 22 :side 99 :twist -7) (:elbow-r :flex 121) (:hand-r :flex -167 :twist -10 :side 2))   ; out in front
  (5 :snap :ke-kr-nb-s (:root :yaw -50))                                                          ; out, turning right: a key every 90 deg
  (7 :snap (:root :yaw -140))
  (9 :snap (:root :yaw -230))
  (:s :snap (:root :yaw -275))
  (12 :snap (:root :yaw -320))
  (:a :snap (:root :yaw -360))
  (14.001 (:root :yaw 0))                                                                          ; (the same facing)
  (20 :ke-kr-nb-a)
  (:end :ke-b-kr-stance))
(defstrike :ke-kr-ns-c (10 4 18 :base :ke-b-kr-stance)
  (0 :ke-kr-nb-a)
  (3 :ke-kr-nc-w)                                                                                  ; dropped, wound to his right
  (5 :snap :ke-kr-nc-s (:root :yaw 50))                                                           ; turning left at the knees
  (7 :snap (:root :yaw 140))
  (9 :snap (:root :yaw 230))
  (:s :snap (:root :yaw 275))
  (12 :snap (:root :yaw 320))
  (:a :snap (:root :yaw 360))
  (14.001 (:root :yaw 0))                                                                          ; (the same facing)
  (20 :ke-kr-nc-a)
  (20.001 (:hand-r :flex 122))                                                                     ; (the same orientation)
  (:end :ke-b-kr-stance))
(defstrike :ke-kr-ns-d (8 8 14 :base :ke-b-kr-stance)
  (0 :ke-kr-nc-a (:hand-r :flex 122))
  (2 :ke-kr-nd-p)                                                                                 ; risen, the arm up: the propeller
  (3 :snap (:hand-r :twist 90))
  (4 :snap (:hand-r :twist 180))
  (5 :snap (:hand-r :twist 270))
  (6 :snap (:hand-r :twist 360))
  (6.001 (:hand-r :twist 0))                                                                       ; (the same orientation)
  (7 :ke-kr-nd-c1)                                                                                 ; cocked overhead right
  (:s :snap :ke-kr-nd-d1)                                                                          ; the first cut (hits 8-10)
  (10 :ke-kr-a1)                                                                                   ; down to his left
  (12 :ke-kr-nd-c2)                                                                                ; the backhand re-cocked
  (13 :snap :ke-kr-nd-d2)                                                                          ; the second (hits 13-15)
  (:a :ke-kr-nd-a)
  (24 (:root :u -0.28) (:chest :twist -36))
  (:end :ke-b-kr-stance))
(defstrike :ke-kr-fin (12 4 22 :base :ke-b-kr-stance)
  (0 :ke-b-kr-stance)
  (2 (:root :u -0.38 :f -0.02) (:spine :flex 36) (:chest :twist -22)
     (:arm-r :flex -11 :side 92 :twist 34) (:elbow-r :flex 130) (:hand-r :flex -17 :twist 92 :side -18))
  (3 :ke-kr-na-c)                                                                                  ; squatted to leap
  (5 :snap :ke-kr-fin-up (:root :u 0.05))                                                         ; off the floor, turning left
  (7 :snap (:root :yaw 90 :u 0.2))
  (9 :snap (:root :yaw 180 :u 0.28))
  (10 :snap (:root :yaw 270 :u 0.25))
  (11 :snap (:root :yaw 330 :u 0.15))
  (:s :snap :ke-kr-fin-h (:root :yaw 360))                                                        ; landed: the chop
  (12.001 (:root :yaw 0))                                                                          ; (the same facing)
  (14 (:root :u -0.34 :f 0.42) (:spine :flex 46))                                                  ; the jolt
  (:a :ke-kr-fin-a)
  (28 (:root :u -0.39) (:spine :flex 48))
  (:end :ke-b-kr-stance))
;;; 斬壞's NS a-d and the AS finisher (DUEL_KEN_V3 §29), each 由緩至急 as the J string (a charge barely moving, the coil :snap,
;;; a trembling hold, the release in the last 2 frames, an overshoot, the weight dragging back). a the head carried on the
;;; right shoulder, squatted; a hop and the one-hand slam, the body falling after it; b the head dragged back along the
;;; floor to his feet, then straight up the centre; c both hands, wound far to his right, the flat sweep at the chest
;;; through to his left; d one full turn to his right (the charge), the backhand raised over his left shoulder, the heavy
;;; diagonal down to his right; the finisher both hands, wound low behind his left with the head on the floor, the whole
;;; body rising through to his right. c and the finisher two-handed (GRIP-LEFT!).
(defpose :ke-zh-na-c (:base :ke-b-zh-stance)            ; NS a coiled: squatted, the head on the right shoulder
  (:root :u -0.5 :f 0.0) (:pelvis :twist 14) (:spine :flex 40 :side 0) (:chest :flex 10 :twist -20) (:head :flex -44 :twist 6)
  (:arm-r :flex 26 :side -16 :twist -10) (:elbow-r :flex 152) (:hand-r :flex 22 :twist -30 :side 0)
  (:arm-l :flex 30 :side 60 :twist 0) (:elbow-l :flex 60) (:hand-l :flex 50)
  (:thigh-r :flex 50 :side 32) (:knee-r :flex 100) (:thigh-l :flex 60 :side 30) (:knee-l :flex 104))
(defpose :ke-zh-na-u (:base :ke-b-zh-stance)            ; the hop: risen off the floor, hoisted overhead
  (:root :u -0.06 :f 0.24) (:pelvis :twist 4) (:spine :flex -12 :side 0) (:chest :flex 0 :twist -8) (:head :flex -12 :twist 0)
  (:arm-r :flex 144 :side 7 :twist 0) (:elbow-r :flex 62) (:hand-r :flex -70 :twist -12 :side 0)
  (:arm-l :flex 60 :side 60 :twist 0) (:elbow-l :flex 30) (:hand-l :flex 30)
  (:thigh-r :flex 50 :side 20) (:knee-r :flex 80) (:thigh-l :flex 10 :side 22) (:knee-l :flex 40))
(defpose :ke-zh-na-h (:base :ke-b-zh-stance)            ; its hit: slammed down ahead, one hand, falling forward
  (:root :u -0.28 :f 0.48) (:pelvis :twist 0) (:spine :flex 50 :side 0) (:chest :flex 0 :twist 4) (:head :flex -30 :twist 0)
  (:arm-r :flex 52 :side 4 :twist 4) (:elbow-r :flex 150) (:hand-r :flex -179 :twist -7 :side 3)
  (:arm-l :flex -30 :side 50 :twist 0) (:elbow-l :flex 25) (:hand-l :flex 40)
  (:thigh-r :flex 62 :side 18) (:knee-r :flex 80) (:thigh-l :flex -20 :side 24) (:knee-l :flex 36))
(defpose :ke-zh-na-a (:base :ke-b-zh-stance)            ; landed: folded over, the head in the floor ahead
  (:root :u -0.38 :f 0.52) (:pelvis :twist 0) (:spine :flex 62 :side 0) (:chest :flex 4 :twist 4) (:head :flex -36 :twist 0)
  (:arm-r :flex 32 :side -40 :twist -2) (:elbow-r :flex 115) (:hand-r :flex -122 :twist 24 :side 0)
  (:arm-l :flex -40 :side 50 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 40)
  (:thigh-r :flex 72 :side 16) (:knee-r :flex 98) (:thigh-l :flex -20 :side 22) (:knee-l :flex 42))
(defpose :ke-zh-nb-c (:base :ke-b-zh-stance)            ; NS b coiled: the head dragged back to his feet, squatted over it
  (:root :u -0.47 :f 0.25) (:pelvis :twist 8) (:spine :flex 56 :side 0) (:chest :flex 10 :twist -6) (:head :flex -46 :twist 0)
  (:arm-r :flex 15 :side -15 :twist 0) (:elbow-r :flex 110) (:hand-r :flex -82 :twist 12 :side 1)
  (:arm-l :flex 30 :side 60 :twist 0) (:elbow-l :flex 60) (:hand-l :flex 50)
  (:thigh-r :flex 50 :side 32) (:knee-r :flex 100) (:thigh-l :flex 60 :side 30) (:knee-l :flex 104))
(defpose :ke-zh-nb-h (:base :ke-b-zh-stance)            ; its hit: straight up the centre
  (:root :u -0.29 :f 0.4) (:pelvis :twist 0) (:spine :flex 12 :side 0) (:chest :flex 0 :twist -4) (:head :flex -16 :twist 0)
  (:arm-r :flex 71 :side 102 :twist 18) (:elbow-r :flex 85) (:hand-r :flex -192 :twist -42 :side -26)
  (:arm-l :flex -20 :side 60 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 40)
  (:thigh-r :flex 50 :side 22) (:knee-r :flex 60) (:thigh-l :flex -14 :side 28) (:knee-l :flex 34))
(defpose :ke-zh-nb-a (:base :ke-b-zh-stance)            ; landed: the head straight up over him
  (:root :u -0.3 :f 0.42) (:pelvis :twist 0) (:spine :flex -6 :side 0) (:chest :flex 0 :twist -4) (:head :flex -10 :twist 0)
  (:arm-r :flex 142 :side 7 :twist 0) (:elbow-r :flex 88) (:hand-r :flex -129 :twist -5 :side 0)
  (:arm-l :flex -20 :side 60 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 40)
  (:thigh-r :flex 50 :side 22) (:knee-r :flex 56) (:thigh-l :flex -14 :side 28) (:knee-l :flex 30))
(defpose :ke-zh-nc-c (:base :ke-b-zh-stance)            ; NS c coiled: both hands, wound far to his right at the chest
  (:root :u -0.4 :f 0.06 :yaw -24) (:pelvis :twist 20) (:spine :flex 30 :side -4) (:chest :flex 6 :twist -50) (:head :flex -34 :twist 20)
  (:arm-r :flex 5 :side -18 :twist 4) (:elbow-r :flex 135) (:hand-r :flex -21 :twist -91 :side -6)
  (:arm-l :flex 76 :side 88 :twist 0) (:elbow-l :flex 116) (:hand-l :flex 20)
  (:thigh-r :flex 30 :side 34) (:knee-r :flex 76) (:thigh-l :flex 56 :side 30) (:knee-l :flex 90))
(defpose :ke-zh-nc-h (:base :ke-b-zh-stance)            ; its hit: flat through the front at the chest
  (:root :u -0.3 :f 0.46) (:pelvis :twist -10) (:spine :flex 28 :side 0) (:chest :flex 0 :twist 16) (:head :flex -22 :twist -6)
  (:arm-r :flex 25 :side -43 :twist 10) (:elbow-r :flex 114) (:hand-r :flex -143 :twist 35 :side 22)
  (:arm-l :flex 145 :side 110 :twist 0) (:elbow-l :flex 54) (:hand-l :flex 20)
  (:thigh-r :flex 56 :side 20) (:knee-r :flex 66) (:thigh-l :flex -16 :side 28) (:knee-l :flex 34))
(defpose :ke-zh-nc-a (:base :ke-b-zh-stance)            ; landed: swept on round to his left
  (:root :u -0.32 :f 0.46 :yaw 20) (:pelvis :twist -22) (:spine :flex 26 :side 4) (:chest :flex 0 :twist 50) (:head :flex -20 :twist -16)
  (:arm-r :flex 122 :side 101 :twist 9) (:elbow-r :flex 65) (:hand-r :flex -120 :twist -13 :side -5)
  (:arm-l :flex 112 :side 105 :twist 0) (:elbow-l :flex 87) (:hand-l :flex 20)
  (:thigh-r :flex 56 :side 20) (:knee-r :flex 66) (:thigh-l :flex -16 :side 28) (:knee-l :flex 34))
(defpose :ke-zh-nd-c (:base :ke-b-zh-stance)            ; NS d coiled: the backhand raised high over his left shoulder
  (:root :u -0.3 :f 0.1) (:pelvis :twist -14) (:spine :flex 10 :side 6) (:chest :flex 0 :twist 34) (:head :flex -16 :twist -14)
  (:arm-r :flex 171 :side 52 :twist 23) (:elbow-r :flex 22) (:hand-r :flex -81 :twist -12 :side 4)
  (:arm-l :flex 30 :side 60 :twist 0) (:elbow-l :flex 40) (:hand-l :flex 40)
  (:thigh-r :flex 30 :side 30) (:knee-r :flex 60) (:thigh-l :flex 40 :side 26) (:knee-l :flex 64))
(defpose :ke-zh-nd-h (:base :ke-b-zh-stance)            ; its hit: the diagonal down through the front to his right, the left foot in
  (:root :u -0.34 :f 0.48) (:pelvis :twist 10) (:spine :flex 34 :side 0) (:chest :flex 0 :twist -16) (:head :flex -24 :twist 6)
  (:arm-r :flex 60 :side 22 :twist -2) (:elbow-r :flex 133) (:hand-r :flex -184 :twist -10 :side -2)
  (:arm-l :flex 10 :side 70 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 40)
  (:thigh-l :flex 56 :side 20) (:knee-l :flex 70) (:thigh-r :flex -16 :side 28) (:knee-r :flex 34))
(defpose :ke-zh-nd-a (:base :ke-b-zh-stance)            ; landed: folded, the head low out to his right
  (:root :u -0.4 :f 0.5) (:pelvis :twist 16) (:spine :flex 48 :side 0) (:chest :flex 4 :twist -34) (:head :flex -30 :twist 10)
  (:arm-r :flex 23 :side 9 :twist 0) (:elbow-r :flex 28) (:hand-r :flex -56 :twist -9 :side 0)
  (:arm-l :flex 10 :side 70 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 40)
  (:thigh-l :flex 60 :side 20) (:knee-l :flex 80) (:thigh-r :flex -16 :side 28) (:knee-r :flex 38))
(defpose :ke-zh-fin-c (:base :ke-b-zh-stance)           ; the finisher coiled: both hands low behind his left, the head on the floor
  (:root :u -0.43 :f 0.0 :yaw 30) (:pelvis :twist -20) (:spine :flex 44 :side 6) (:chest :flex 8 :twist 50) (:head :flex -40 :twist -18)
  (:arm-r :flex 28 :side -41 :twist 27) (:elbow-r :flex 37) (:hand-r :flex 228 :twist -13 :side -15)
  (:arm-l :flex 0 :side -75 :twist 0) (:elbow-l :flex 79) (:hand-l :flex 20)
  (:thigh-r :flex 56 :side 30) (:knee-r :flex 100) (:thigh-l :flex 30 :side 36) (:knee-l :flex 76))
(defpose :ke-zh-fin-w (:base :ke-b-zh-stance)           ; its charge: the head dragged round the front on the floor
  (:root :u -0.42 :f 0.02 :yaw 15) (:pelvis :twist -5) (:spine :flex 42 :side 2) (:chest :flex 8 :twist 20) (:head :flex -40 :twist -6)
  (:arm-r :flex 36 :side -42 :twist -22) (:elbow-r :flex 115) (:hand-r :flex 216 :twist 35 :side 15)
  (:arm-l :flex 30 :side 40 :twist 0) (:elbow-l :flex 60) (:hand-l :flex 20)
  (:thigh-r :flex 40 :side 32) (:knee-r :flex 90) (:thigh-l :flex 44 :side 32) (:knee-l :flex 90))
(defpose :ke-zh-fin-h (:base :ke-b-zh-stance)           ; its hit: the whole body rising through the front to his right
  (:root :u -0.22 :f 0.5) (:pelvis :twist 12) (:spine :flex 16 :side -6) (:chest :flex 0 :twist -20) (:head :flex -16 :twist 8)
  (:arm-r :flex 87 :side 99 :twist 1) (:elbow-r :flex 66) (:hand-r :flex 162 :twist -32 :side -9)
  (:arm-l :flex 1 :side -32 :twist 0) (:elbow-l :flex 93) (:hand-l :flex 20)
  (:thigh-l :flex 52 :side 22) (:knee-l :flex 60) (:thigh-r :flex -14 :side 28) (:knee-r :flex 32))
(defpose :ke-zh-fin-a (:base :ke-b-zh-stance)           ; landed: risen high, the head up over his right
  (:root :u -0.14 :f 0.5) (:pelvis :twist 18) (:spine :flex -6 :side -12) (:chest :flex 0 :twist -40) (:head :flex -10 :twist 12)
  (:arm-r :flex 152 :side -33 :twist 0) (:elbow-r :flex 55) (:hand-r :flex 247 :twist -2 :side 0)
  (:arm-l :flex 141 :side 60 :twist 0) (:elbow-l :flex 47) (:hand-l :flex 20)
  (:thigh-l :flex 30 :side 22) (:knee-l :flex 30) (:thigh-r :flex -14 :side 28) (:knee-r :flex 20))
(defstrike :ke-zh-ns-a (16 5 24 :base :ke-b-zh-stance)
  (0 :ke-b-zh-stance)
  (2 (:root :u -0.36) (:chest :twist -8) (:arm-r :flex 0))                                         ; the charge: barely moving
  (6 :snap (:root :u -0.42) (:arm-r :flex -20 :side 31 :twist -14) (:elbow-r :flex 119) (:hand-r :flex 40 :twist -79 :side 9))   ; up his right side
  (10 :snap :ke-zh-na-c)                                                                           ; gathering: onto the shoulder
  (11 (:root :u -0.51) (:chest :twist -21))                                                        ; held, trembling
  (12 (:root :u -0.5) (:chest :twist -20))
  (13 (:root :u -0.52) (:chest :twist -22))
  (14 :snap :ke-zh-na-u)                                                                           ; the hop, hoisted
  (:s :snap :ke-zh-na-h)                                                                           ; the slam
  (18 (:root :u -0.36) (:spine :flex 58))                                                          ; falling after it
  (:a :ke-zh-na-a)
  (32 (:root :u -0.37) (:spine :flex 60))
  (38 (:root :u -0.32 :f 0.45) (:spine :flex 50) (:chest :twist -6) (:thigh-l :flex 20 :side 24) (:knee-l :flex 60)
      (:arm-r :flex -13 :side 31 :twist 0) (:elbow-r :flex 92) (:hand-r :flex -78 :twist -31 :side 0))   ; dragged out to his right

  (:end :ke-b-zh-stance))
(defstrike :ke-zh-ns-b (12 4 20 :base :ke-b-zh-stance)
  (0 :ke-zh-na-a)
  (2 (:root :u -0.33 :f 0.48) (:spine :flex 61) (:thigh-l :flex 10 :side 24) (:knee-l :flex 60))     ; the charge: the drag starts
  (8 :snap :ke-zh-nb-c)                                                                            ; dragged back to his feet
  (9 (:root :u -0.48) (:spine :flex 57))                                                           ; held, trembling
  (10 (:root :u -0.47) (:spine :flex 55))
  (:s :snap :ke-zh-nb-h)                                                                           ; the release: straight up
  (13 (:root :u -0.22) (:spine :flex 6))                                                           ; past it
  (:a :ke-zh-nb-a)
  (26 (:root :u -0.28))
  (29 (:arm-r :flex 23 :side 9 :twist 0) (:elbow-r :flex 28) (:hand-r :flex -56 :twist -9 :side 0))   ; dragged out to his right

  (:end :ke-b-zh-stance))
(defstrike :ke-zh-ns-c (14 4 20 :base :ke-b-zh-stance)
  (0 :ke-zh-nb-a)
  (2 (:root :u -0.31) (:chest :twist -10) (:arm-r :side 20))                                        ; the charge: barely moving
  (10 :snap :ke-zh-nc-c)                                                                           ; gathering: wound to his right
  (11 (:root :u -0.41 :yaw -25) (:chest :twist -52))                                               ; held, trembling
  (12 (:root :u -0.4 :yaw -24) (:chest :twist -51))
  (:s :snap :ke-zh-nc-h)                                                                           ; the release: the sweep
  (15 (:root :f 0.47) (:chest :twist 28))                                                          ; past it
  (:a :ke-zh-nc-a)
  (28 (:root :yaw 22) (:chest :twist 54))
  (31 (:arm-r :flex 23 :side 9 :twist 0) (:elbow-r :flex 28) (:hand-r :flex -56 :twist -9 :side 0))   ; dragged out to his right

  (:end :ke-b-zh-stance))
(defstrike :ke-zh-ns-d (16 5 26 :base :ke-b-zh-stance)
  (0 :ke-zh-nc-a)
  (4 (:root :yaw 0) (:chest :twist 44))                                                            ; the charge: the turn starts
  (8 :snap :ke-zh-nd-c (:root :yaw -90))                                                           ; turning right, raised: a key every 90-100 deg
  (11 :snap (:root :yaw -190))
  (13 :snap (:root :yaw -290))
  (14 (:root :yaw -297 :u -0.32))                                                                  ; held, trembling
  (15 (:root :yaw -300 :u -0.31))
  (:s :snap :ke-zh-nd-h (:root :yaw -360))                                                         ; the release: the diagonal
  (16.001 (:root :yaw 0))                                                                          ; (the same facing)
  (18 (:root :u -0.38) (:spine :flex 42))                                                          ; the jolt
  (:a :ke-zh-nd-a)
  (34 (:root :u -0.39) (:spine :flex 50))
  (:end :ke-b-zh-stance))
(defstrike :ke-zh-fin (16 5 26 :base :ke-b-zh-stance)
  (0 :ke-b-zh-stance)
  (3 (:root :u -0.37 :yaw 4) (:chest :twist 4))                                                    ; the charge: barely moving
  (5 :snap (:root :yaw 8 :u -0.38) (:arm-r :flex 28 :side 61 :twist 21) (:elbow-r :flex 45) (:hand-r :flex 89 :twist -94 :side -36))
  (7 :snap :ke-zh-fin-w)                                                                           ; the head dragged round the front
  (11 :snap :ke-zh-fin-c)                                                                          ; gathering: wound low behind his left
  (12 (:root :u -0.44 :yaw 31) (:chest :twist 52))                                                 ; held, trembling
  (13 (:root :u -0.43 :yaw 30) (:chest :twist 51))
  (14 (:root :u -0.44 :yaw 31) (:chest :twist 52))
  (:s :snap :ke-zh-fin-h)                                                                          ; the release, 2 frames
  (17 (:root :u -0.16) (:chest :twist -28) (:arm-r :flex 101 :side -39 :twist -1) (:elbow-r :flex 102) (:hand-r :flex 232 :twist 14 :side -1))   ; past it
  (:a :ke-zh-fin-a)
  (34 (:root :u -0.16))
  (39 (:root :u -0.24 :f 0.4) (:spine :flex 20) (:chest :twist -24)
      (:arm-r :flex -9 :side 47 :twist 0) (:elbow-r :flex 82) (:hand-r :flex 264 :twist -14 :side 0))   ; down to his right
  (:end :ke-b-zh-stance))
(pushnew :ke-zh-ns-c *grip-clips*)                      ; (NS c and the finisher two-handed: GRIP-LEFT!)
(pushnew :ke-zh-fin *grip-clips*)
;;; The two special AS (DUEL_KEN_V3 §30), after J5 (frame 0 its landing). 千切 CHIGIRI (狂嵐): the iai (drawn back to his right
;;; hip, squatted, held), the draw (one turn to his left in 2 frames, the arm flung out: the hit on 12), through to his left,
;;; risen into the roar (arched back, the head thrown back, the arms flung wide) while the cuts open round him (KEN-CHIGIRI-LOOK),
;;; the burst on 26, where the damage lands (:dmg-at, DELAY-HIT). TATE-GOTO (斬壞, two-handed): the head hoisted out of the floor
;;; and overhead (由緩至急: barely moving, then gathering, squatted and trembling), the leap, the chop straight down the centre on 20,
;;; the head pressed into the floor; the space split from the sky down before him (KEN-TATEGOTO-LOOK) and the floor 6 m.
(defpose :ke-kr-ch-c (:base :ke-b-kr-stance)            ; 千切's iai: drawn back to his right hip, squatted, the left hand out
  (:root :u -0.46 :f 0.05 :yaw -20) (:pelvis :twist 25) (:spine :flex 40 :side 0) (:chest :flex 8 :twist -45) (:head :flex -40 :twist 14)
  (:arm-r :flex 18 :side -5 :twist -31) (:elbow-r :flex 0) (:hand-r :flex 94 :twist -93 :side -31)
  (:arm-l :flex 60 :side 20 :twist 0) (:elbow-l :flex 30) (:hand-l :flex 10)
  (:thigh-l :flex 70 :side 30) (:knee-l :flex 104) (:thigh-r :flex 25 :side 42) (:knee-r :flex 80))
(defpose :ke-kr-ch-f (:base :ke-b-kr-stance)            ; through to his left, the blade level behind
  (:root :u -0.3 :f 0.12 :yaw 60) (:pelvis :twist -16) (:spine :flex 16 :side 0) (:chest :flex 0 :twist 45) (:head :flex -14 :twist -14)
  (:arm-r :flex 160 :side 99 :twist 5) (:elbow-r :flex 0) (:hand-r :flex 296 :twist 0 :side 2)
  (:arm-l :flex 20 :side 70 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-l :flex 40 :side 30) (:knee-l :flex 60) (:thigh-r :flex 30 :side 34) (:knee-r :flex 60))
(defpose :ke-kr-ch-r (:base :ke-b-kr-stance)            ; the roar: arched back, the head thrown back, the arms flung wide
  (:root :u -0.22 :f 0.1) (:pelvis :twist 0) (:spine :flex -18 :side 0) (:chest :flex -6 :twist 0) (:head :flex -50 :twist 0)
  (:arm-r :flex -6 :side 62 :twist 0) (:elbow-r :flex 35) (:hand-r :flex 233 :twist 34 :side 0)
  (:arm-l :flex 90 :side 80 :twist 0) (:elbow-l :flex 20) (:hand-l :flex 10)
  (:thigh-l :flex 30 :side 34) (:knee-l :flex 44) (:thigh-r :flex 30 :side 34) (:knee-r :flex 44))
(defstrike :ke-kr-chigiri (12 4 30 :base :ke-b-kr-stance)
  (0 :ke-kr-a5)
  (3 (:root :u -0.34 :f 0.3) (:chest :twist 10) (:arm-r :flex 40))                                ; gathering
  (8 :ke-kr-ch-c)                                                                                  ; the iai
  (10 (:root :u -0.47) (:chest :twist -47))                                                        ; held, trembling
  (11 (:root :u -0.46) (:chest :twist -46))
  (:s :snap :ke-kr-nb-s (:root :u -0.28 :f 0.1 :yaw 80) (:hand-r :flex 237))                       ; the draw: one turn in 2 frames
  (13 :snap (:root :yaw 260))
  (14 :snap (:root :yaw 440))
  (14.001 (:root :yaw 80))                                                                         ; (the same facing)
  (16 :ke-kr-ch-f)                                                                                 ; through to his left
  (20 (:root :u -0.27 :yaw 40) (:chest :twist 36))
  (23 :ke-kr-ch-r)                                                                                 ; the roar
  (27 (:root :u -0.21) (:spine :flex -22) (:head :flex -54))                                       ; the burst, held
  (34 (:root :u -0.22) (:spine :flex -16) (:head :flex -46))
  (34.001 (:hand-r :flex -127))                                                                    ; (the same orientation)
  (:end :ke-b-kr-stance))
(defpose :ke-zh-tg-c (:base :ke-b-zh-stance)            ; TATE-GOTO coiled: both hands overhead, the head hanging down his back
  (:root :u -0.41 :f 0.05) (:pelvis :twist 0) (:spine :flex -12 :side 0) (:chest :flex 0 :twist 0) (:head :flex -20 :twist 0)
  (:arm-r :flex 165 :side 12 :twist -2) (:elbow-r :flex 6) (:hand-r :flex 27 :twist 4 :side 4)
  (:arm-l :flex 149 :side 25 :twist 0) (:elbow-l :flex 0) (:hand-l :flex 20)
  (:thigh-r :flex 60 :side 26) (:knee-r :flex 100) (:thigh-l :flex 60 :side 26) (:knee-l :flex 100))
(defpose :ke-zh-tg-h (:base :ke-b-zh-stance)            ; its hit: landed, chopped straight down the centre
  (:root :u -0.3 :f 0.6) (:pelvis :twist 0) (:spine :flex 50 :side 0) (:chest :flex 0 :twist 0) (:head :flex -30 :twist 0)
  (:arm-r :flex 37 :side -2 :twist 12) (:elbow-r :flex 148) (:hand-r :flex -158 :twist -8 :side 2)
  (:arm-l :flex 162 :side 108 :twist 0) (:elbow-l :flex 53) (:hand-l :flex 20)
  (:thigh-r :flex 66 :side 16) (:knee-r :flex 86) (:thigh-l :flex -20 :side 22) (:knee-l :flex 36))
(defpose :ke-zh-tg-a (:base :ke-b-zh-stance)            ; landed: the head pressed into the floor ahead
  (:root :u -0.36 :f 0.62) (:pelvis :twist 0) (:spine :flex 58 :side 0) (:chest :flex 0 :twist 0) (:head :flex -34 :twist 0)
  (:arm-r :flex 16 :side -23 :twist 1) (:elbow-r :flex 102) (:hand-r :flex -101 :twist 14 :side 0)
  (:arm-l :flex 152 :side 127 :twist 0) (:elbow-l :flex 31) (:hand-l :flex 20)
  (:thigh-r :flex 70 :side 16) (:knee-r :flex 94) (:thigh-l :flex -20 :side 22) (:knee-l :flex 40))
(defstrike :ke-zh-tategoto (20 4 30 :base :ke-b-zh-stance)
  (0 :ke-zh-a5)
  (3 (:root :u -0.32) (:spine :flex 56))                                                           ; the charge: barely moving
  (14 :snap :ke-zh-tg-c)                                                                           ; hoisted out of the floor, overhead
  (15 (:root :u -0.42) (:spine :flex -13))                                                         ; held, trembling
  (16 (:root :u -0.41) (:spine :flex -12))
  (17 (:root :u -0.42) (:spine :flex -14))
  (18 :snap (:root :u 0.05 :f 0.25) (:spine :flex -16) (:thigh-r :flex 40) (:knee-r :flex 60) (:thigh-l :flex 30) (:knee-l :flex 50))   ; the leap
  (19 (:root :u 0.12 :f 0.4) (:spine :flex -8))                                                    ; the top
  (:s :snap :ke-zh-tg-h)                                                                           ; straight down the centre
  (21 (:root :u -0.36) (:spine :flex 56))                                                          ; the jolt
  (:a :ke-zh-tg-a)
  (40 (:root :u -0.35) (:spine :flex 58))
  (:end :ke-b-zh-stance))
(pushnew :ke-zh-tategoto *grip-clips*)                  ; (two-handed: GRIP-LEFT!)
(defparameter *chigiri-cuts* 9 "千切's cuts opening in the air round him, one a frame after the draw (KEN-CHIGIRI-LOOK).")
(defparameter *chigiri-burst* 14 "The look's age (frames after the draw) the cuts burst on: move frame 26, its :dmg-at.")
(defun ken-chigiri-look (hz rdt)
  "千切's look (a look hazard spawned at the draw, at his feet): the draw's white ring for 3 frames; then *CHIGIRI-CUTS* thin slits
opening one a frame within 2.4 m of him (a white core in a BLOOD lens, trembling on twos, each its own tilt); at *CHIGIRI-BURST*
all of them flare wide white for 3 frames and are gone (the burst's shards and ring: VFX-KEN-BK-BURST)."
  (declare (ignore rdt))
  (let* ((age (hazard-age hz)) (x (hazard-x hz)) (z (hazard-z hz)) (dr (drawing-no)))
    (when (< age 3)                                     ; the draw: a ring of four smears at 1.35 m
      (dotimes (i 4)
        (let* ((a0 (* i 1.5708)) (a1 (+ a0 1.5708)) (am (+ a0 0.785)) (r 2.0))
          (fx-crescent (f32 (+ x (* r (cos a0)))) 1.35f0 (f32 (+ z (* r (sin a0)))) (f32 (+ x (* r (cos a1)))) 1.35f0 (f32 (+ z (* r (sin a1))))
                       (f32 (+ x (* 1.45 r (cos am)))) 1.35f0 (f32 (+ z (* 1.45 r (sin am)))) (f32 (- 0.16 (* 0.05 age))) :lens 0.06f0 (f32 (+ 40 i))
                       +pal-hit+ 0.95f0 :push 0.2f0))))
    (when (< age (+ *chigiri-burst* 3))
      (dotimes (i *chigiri-cuts*)
        (when (>= age (1+ i))
          (let* ((a (* 6.2832 (hash01 (f32 i) 1.7f0))) (d (+ 0.7 (* 1.7 (hash01 (f32 i) 2.9f0))))
                 (y (+ 0.5 (* 1.8 (hash01 (f32 i) 4.3f0)))) (b (* 6.2832 (hash01 (f32 i) 5.1f0)))
                 (tilt (- (* 1.6 (hash01 (f32 i) 6.7f0)) 0.8)) (l (+ 0.55 (* 0.5 (hash01 (f32 i) 8.3f0))))
                 (cx (+ x (* d (cos a)))) (cz (+ z (* d (sin a))))
                 (dx (* l (cos b) (cos tilt))) (dz (* l (sin b) (cos tilt))) (dy (* l (sin tilt)))
                 (tr (* 0.02 (- (hash01 dr (f32 i)) 0.5)))
                 (burst (>= age *chigiri-burst*)))
            (fx-crescent (f32 (- cx dx)) (f32 (+ tr (- y dy))) (f32 (- cz dz)) (f32 (+ cx dx)) (f32 (+ tr y dy)) (f32 (+ cz dz))
                         (f32 cx) (f32 (+ tr y)) (f32 cz) (if burst 0.42f0 0.07f0) :lens 0.06f0 (f32 (+ 20 i)) +pal-blood+ 0.95f0 :push 0.2f0)
            (fx-crescent (f32 (- cx dx)) (f32 (+ tr (- y dy))) (f32 (- cz dz)) (f32 (+ cx dx)) (f32 (+ tr y dy)) (f32 (+ cz dz))
                         (f32 cx) (f32 (+ tr y)) (f32 cz) (if burst 0.26f0 0.02f0) :lens 0.04f0 (f32 (+ 30 i)) +pal-hit+ 0.98f0 :push 0.24f0)))))
    nil))
(defun ken-tategoto-look (hz rdt)
  "TATE-GOTO's look (a look hazard at the cut, before him): the space split from the sky to the floor, a vertical lens 7 m tall:
wide and white for 3 frames, then a BLOOD slit with a white core narrowing shut over the rest of its life."
  (declare (ignore rdt))
  (let* ((age (hazard-age hz)) (life (hazard-life hz)) (x (hazard-x hz)) (z (hazard-z hz))
         (k (max 0.0 (- 1.0 (/ (max 0 (- age 3)) (float (max 1 (- life 3)))))))
         (w (if (< age 3) 0.2 (* 0.09 k))))
    (when (> w 0.005)
      (fx-crescent (f32 x) 7.0f0 (f32 z) (f32 x) 0.0f0 (f32 z) (f32 x) 3.5f0 (f32 z) (f32 w) :lens 0.05f0 61f0
                   (if (< age 3) +pal-hit+ +pal-blood+) 0.95f0 :push 0.3f0)
      (fx-crescent (f32 x) 7.0f0 (f32 z) (f32 x) 0.0f0 (f32 z) (f32 x) 3.5f0 (f32 z) (f32 (* 0.35 w)) :lens 0.03f0 62f0 +pal-hit+ 0.98f0 :push 0.34f0))
    nil))
(defun vfx-ken-bk-burst (x z kind)
  "The special AS's burst (feedback :ken-bk-burst): 千切 (KIND :chigiri) the space shattering round (x z): white and BLOOD shards
flung out, a white ring, a light; TATE-GOTO (:tategoto) the split's flash: shards along the cut, a DUST ring."
  (with-floats (x z)
    (let ((n (if (eq kind :chigiri) 28 12)))
      (dotimes (i n)
        (let* ((a (rnd-range 0f0 6.2832f0)) (sp (rnd-range 3f0 7f0)) (r (rnd-range 0.6f0 2.4f0)))
          (declare (single-float a sp r))
          (%t-shard (+ x (* r (f-cos a))) (rnd-range 0.4f0 2.4f0) (+ z (* r (f-sin a))) (* sp (f-cos a)) (rnd-range 0.5f0 4f0) (* sp (f-sin a))
                    (rnd-range 0.5f0 0.9f0) (rnd-range 0.12f0 0.26f0) 7f0 (if (zerop (mod i 3)) +pal-blood+ +pal-hit+))))
      (vfx-shockwave x z (if (eq kind :chigiri) 4.5 3.0) 0.5 :pal (if (eq kind :chigiri) +pal-hit+ +pal-dust+))
      (flash-light x 1.4 z 1.0 0.95 0.9))
    nil))
;; guard: crouched lower still behind the raised left forearm, the broken blade turned flat across the body
(defpose :ke-b-guard (:base :ke-b-stance)
  (:root :u -0.34) (:spine :flex 34) (:chest :flex 12 :twist -18) (:head :flex -44)
  (:arm-r :flex 62 :side 18 :twist 20) (:elbow-r :flex 76) (:hand-r :twist 60 :flex -70)
  (:arm-l :flex 82 :side 12) (:elbow-l :flex 118) (:hand-l :flex 30)
  (:thigh-r :flex -6 :side 24) (:knee-r :flex 66) (:thigh-l :flex 60 :side 24) (:knee-l :flex 88))
(defclip :ke-b-guard (0.6 :loop t :base :ke-b-guard) (0) (0.3 (:root :u -0.37) (:chest :flex 16)))
(defclip :ke-b-guard-hit (0.2 :base :ke-b-guard)
  (0) (0.05 :snap (:spine :flex 24) (:root :f -0.14 :u -0.3) (:head :flex -30)) (0.2 :ke-b-guard))
;; the prowl and the run: the shared leg cycles laid under the crouch (deeper hips and knees, the back rounded more)
(defun oni-keys (keys &key (du -0.28) (dthigh 38) (dknee 60) (dspine 18) (dhead -18))
  "KEYS (DEFCLIP key lists of the shared walk / run legs) sunk into the oni's crouch: every :root :u, thigh and knee
flex and the spine / head flex shifted by these."
  (flet ((shift (spec)
           (destructuring-bind (group &rest cv) spec
             (cons group (loop for (ch v) on cv by #'cddr
                               append (list ch (+ v (cond ((and (eq group :root) (eq ch :u)) du)
                                                          ((not (eq ch :flex)) 0)
                                                          ((member group '(:thigh-r :thigh-l :thighs)) dthigh)
                                                          ((member group '(:knee-r :knee-l :knees)) dknee)
                                                          ((eq group :spine) dspine)
                                                          ((eq group :head) dhead)
                                                          (t 0)))))))))
    (loop for (tm . specs) in keys collect (cons tm (mapcar #'shift specs)))))
(defparameter *oni-walk*
  '((:ke-b-walk-f 0.9 ((0 (:thigh-r :flex 25) (:knee-r :flex 10) (:thigh-l :flex -15) (:knee-l :flex 20))
                       (0.225 (:root :u -0.03) (:thigh-r :flex 0) (:knee-r :flex 20) (:thigh-l :flex 5) (:knee-l :flex 55))
                       (0.45 (:root :u -0.05) (:thigh-l :flex 25) (:knee-l :flex 10) (:thigh-r :flex -15) (:knee-r :flex 20))
                       (0.675 (:root :u -0.03) (:thigh-l :flex 0) (:knee-l :flex 20) (:thigh-r :flex 5) (:knee-r :flex 55))))
    (:ke-b-walk-b 0.9 ((0 (:thigh-r :flex -15) (:knee-r :flex 20) (:thigh-l :flex 25) (:knee-l :flex 10))
                       (0.225 (:root :u -0.03) (:thigh-r :flex 5) (:knee-r :flex 55) (:thigh-l :flex 0) (:knee-l :flex 20))
                       (0.45 (:root :u -0.05) (:thigh-l :flex -15) (:knee-l :flex 20) (:thigh-r :flex 25) (:knee-r :flex 10))
                       (0.675 (:root :u -0.03) (:thigh-l :flex 5) (:knee-l :flex 55) (:thigh-r :flex 0) (:knee-r :flex 20))))
    (:ke-b-strafe-r 0.8 ((0 (:thigh-r :side 22 :flex 5) (:thigh-l :side -2 :flex 20) (:knee-l :flex 25) (:knee-r :flex 10))
                         (0.2 (:root :u -0.04) (:thigh-r :side 8) (:knee-r :flex 45) (:thigh-l :side 5))
                         (0.4 (:thigh-r :side 4) (:thigh-l :side 18 :flex 10) (:knee-l :flex 20))
                         (0.6 (:root :u -0.04) (:thigh-l :side 5) (:knee-l :flex 45) (:thigh-r :side 10))))
    (:ke-b-strafe-l 0.8 ((0 (:thigh-l :side 22 :flex 30) (:thigh-r :side -2 :flex 0) (:knee-r :flex 25) (:knee-l :flex 10))
                         (0.2 (:root :u -0.04) (:thigh-l :side 8) (:knee-l :flex 45) (:thigh-r :side 12))
                         (0.4 (:thigh-l :side 4) (:thigh-r :side 22 :flex -5) (:knee-r :flex 20))
                         (0.6 (:root :u -0.04) (:thigh-r :side 8) (:knee-r :flex 45) (:thigh-l :side 10)))))
  "The oni's prowl: the shared walk / strafe legs (body.lisp), each clip (name seconds keys) sunk by ONI-KEYS.")
;; the prowl's upper body (DUEL_KEN_REWORK §8.4, the user 2026-10-09: 「做卍解的潛行走路和咆哮後跳」): a stalking beast, not
;; a man walking crouched: the shoulders roll with the steps (8 degrees: more swings the trailing blade about), the left
;; claw paws forward with the opposite foot and drags back, the head stays low and sways, the broken blade scrapes along
;; behind; one list of four keys per clip, laid on the sunk legs key for key (the same times)
(defparameter *oni-prowl*
  '((:ke-b-walk-f ((:chest :flex 18 :twist -18) (:arm-l :flex 74 :side 28) (:elbow-l :flex 34) (:hand-l :flex 64)
                   (:arm-r :flex -16 :side 30) (:hand-r :flex -106) (:head :flex -60 :twist 8))
                  ((:chest :flex 24 :twist -14) (:arm-l :flex 50 :side 40) (:elbow-l :flex 62) (:hand-l :flex 42)
                   (:arm-r :flex -16 :side 30) (:hand-r :flex -98) (:head :flex -66 :twist 0))
                  ((:chest :flex 18 :twist -10) (:arm-l :flex 20 :side 46) (:elbow-l :flex 82) (:hand-l :flex 30)
                   (:arm-r :flex -16 :side 30) (:hand-r :flex -106) (:head :flex -60 :twist -8))
                  ((:chest :flex 24 :twist -14) (:arm-l :flex 44 :side 42) (:elbow-l :flex 66) (:hand-l :flex 52)
                   (:arm-r :flex -16 :side 30) (:hand-r :flex -98) (:head :flex -66 :twist 0)))
    (:ke-b-walk-b ((:chest :flex 14 :twist -18) (:arm-l :flex 66 :side 34) (:elbow-l :flex 44) (:hand-l :flex 60)
                   (:head :flex -54 :twist 4))
                  ((:chest :flex 18 :twist -12) (:arm-l :flex 58 :side 38) (:elbow-l :flex 54) (:hand-l :flex 46)
                   (:head :flex -58))
                  ((:chest :flex 14 :twist -6) (:arm-l :flex 52 :side 42) (:elbow-l :flex 60) (:hand-l :flex 60)
                   (:head :flex -54 :twist -4))
                  ((:chest :flex 18 :twist -12) (:arm-l :flex 58 :side 38) (:elbow-l :flex 54) (:hand-l :flex 46)
                   (:head :flex -58)))
    (:ke-b-strafe-r ((:chest :flex 18 :twist -14) (:arm-l :flex 56 :side 48) (:elbow-l :flex 50) (:hand-l :flex 60)
                     (:head :flex -60 :twist -10))
                    ((:chest :flex 22 :twist -8) (:arm-l :flex 48 :side 40) (:elbow-l :flex 62) (:head :flex -64 :twist -10))
                    ((:chest :flex 18 :twist -14) (:arm-l :flex 56 :side 48) (:elbow-l :flex 50) (:hand-l :flex 60)
                     (:head :flex -60 :twist -10))
                    ((:chest :flex 22 :twist -8) (:arm-l :flex 48 :side 40) (:elbow-l :flex 62) (:head :flex -64 :twist -10)))
    (:ke-b-strafe-l ((:chest :flex 18 :twist -4) (:arm-l :flex 60 :side 30) (:elbow-l :flex 46) (:hand-l :flex 60)
                     (:head :flex -60 :twist 10))
                    ((:chest :flex 22 :twist -12) (:arm-l :flex 50 :side 38) (:elbow-l :flex 60) (:head :flex -64 :twist 10))
                    ((:chest :flex 18 :twist -4) (:arm-l :flex 60 :side 30) (:elbow-l :flex 46) (:hand-l :flex 60)
                     (:head :flex -60 :twist 10))
                    ((:chest :flex 22 :twist -12) (:arm-l :flex 50 :side 38) (:elbow-l :flex 60) (:head :flex -64 :twist 10))))
  "The oni's prowl above the hips: per clip, four key spec lists (absolute values, after ONI-KEYS's shift) for its keys.")
(loop for (name dur keys) in *oni-walk*
      do (build-clip name dur t :ke-b-stance
                     (loop for (tm . specs) in (oni-keys keys)
                           for upper in (rest (assoc name *oni-prowl*))
                           collect (list* tm (append specs upper)))))
;; the roaring back leap (the Step back's art, 0.4 s like :sh-step-b; §8.4): sunk deep, then flung up and back, the back
;; arched, the head thrown back roaring (the shout face and the roar: feedback.lisp's :step), the arms flung wide, the
;; legs tucked; down on all fours, the left claw on the floor, and back into the crouch
(defclip :ke-b-step-b (0.4 :base :ke-b-stance)
  (0 (:root :u -0.38) (:spine :flex 48) (:head :flex -62) (:knee-r :flex 74) (:knee-l :flex 96))
  (0.07 :snap (:root :u 0.1 :f -0.08) (:spine :flex 2) (:chest :flex -16 :twist -4) (:neck :flex -6) (:head :flex -22)
        (:arm-l :flex 30 :side 82) (:elbow-l :flex 30) (:hand-l :flex 70) (:arm-r :flex 6 :side 62) (:elbow-r :flex 18)
        (:thigh-r :flex 44 :side 20) (:knee-r :flex 86) (:thigh-l :flex 62 :side 20) (:knee-l :flex 104))
  (0.18 (:root :u 0.06 :f -0.12) (:spine :flex 8) (:chest :flex -10 :twist -4) (:head :flex -26)
        (:arm-l :flex 36 :side 74) (:elbow-l :flex 36) (:hand-l :flex 66) (:arm-r :flex 2 :side 56) (:elbow-r :flex 20)
        (:thigh-r :flex 50 :side 20) (:knee-r :flex 92) (:thigh-l :flex 66 :side 20) (:knee-l :flex 108))
  (0.28 :snap (:root :u -0.42 :f -0.04) (:spine :flex 54) (:chest :flex 22) (:head :flex -64)
        (:arm-l :flex 80 :side 24) (:elbow-l :flex 10) (:hand-l :flex 20) (:arm-r :flex -20 :side 34)
        (:thigh-r :flex -10 :side 26) (:knee-r :flex 72) (:thigh-l :flex 72 :side 26) (:knee-l :flex 102))
  (0.4 :ke-b-stance))
;; the run: on the shoulder-rest set the blade rides his shoulder; the oni runs bent double, the blade trailing
(loop for name in '(:ke-b-run :ke-b-skate-b :ke-b-slide-r :ke-b-slide-l)
      for keys in (list *run-keys* *skate-keys* *slide-r-keys* *slide-l-keys*)
      do (build-clip name 0.5 t :ke-b-stance (oni-keys keys :du -0.2 :dthigh 22 :dknee 40 :dspine 22 :dhead -22)))
(defstrike :ke-b-fist (9 3 18 :base :ke-b-stance)      ; SP2's NAGURI-TOBASHI: the left uppercut to the chin (the punch
  (0)                                                   ; that sent Gerard flying, DUEL_KEN_REWORK §8), rising with it
  (4 (:chest :twist 30 :flex 24) (:spine :flex 54) (:arm-l :flex -10 :side 30) (:elbow-l :flex 100) (:hand-l :flex 0)
     (:root :u -0.46 :f -0.08) (:head :twist 10 :flex -66) (:knees :flex 100) (:thighs :flex 74))   ; sunk, the fist low
  (7 (:root :u -0.48 :f -0.1) (:spine :flex 56))                                               ; held
  (:s :snap (:chest :twist -30 :flex -6) (:spine :flex 4) (:arm-l :flex 150 :side 10) (:elbow-l :flex 40) (:hand-l :flex 0)
      (:root :f 0.5 :u 0.0) (:head :flex -20 :twist -6) (:thigh-l :flex 40) (:knee-l :flex 30) (:thigh-r :flex -20) (:knee-r :flex 15)
      (:arm-r :flex -40 :side 60) (:hand-r :flex -90))
  (:a (:arm-l :flex 165) (:root :f 0.54 :u 0.06) (:spine :flex 0))                             ; up on the toes
  (20 (:arm-l :flex 140) (:root :f 0.5 :u -0.1) (:spine :flex 20))
  (:end :ke-b-stance))
;; J3 GENKOTSU alone (the J cut, docs/duel/DUEL_STRINGS.md §13): the same hook thrown from where he stands, close (SP2's punch
;; keeps the long spring above)
(defstrike :ke-b-hook (9 3 18 :base :ke-b-stance)
  (0)
  (4 (:chest :twist 40 :flex 20) (:spine :flex 46) (:arm-l :flex 30 :side 70) (:elbow-l :flex 115) (:hand-l :flex 0)
     (:root :u -0.36 :f -0.1) (:head :twist 14 :flex -60) (:knee-l :flex 92) (:thigh-l :flex 66))    ; coiled lower
  (7 (:chest :twist 46) (:root :u -0.37 :f -0.12))                                                  ; held
  (:s :snap (:chest :twist -52 :flex 8) (:spine :flex 30) (:arm-l :flex 94 :side 6) (:elbow-l :flex 40) (:hand-l :flex 0)
      (:root :f 0.0 :u -0.2) (:thigh-l :flex 58) (:knee-l :flex 52) (:thigh-r :flex -34) (:knee-r :flex 24)
      (:arm-r :flex -40 :side 75) (:hand-r :flex -90) (:head :twist -10 :flex -40))
  (:a (:chest :twist -60) (:root :f 0.03))                                                           ; overshoot, held
  (20 (:chest :twist -52) (:root :f 0.02 :u -0.24) (:arm-l :flex 80) (:elbow-l :flex 44) (:spine :flex 36))
  (:end :ke-b-stance))
;; L KAMICHIGIRI: down on all fours-low, a lunge, the left claw clamps the arm, the head drives in, the tearing jerk back
(defstrike :ke-b-bite (10 3 28 :base :ke-b-stance)
  (0)
  (5 (:root :u -0.44 :f -0.08) (:spine :flex 56) (:chest :flex 18) (:head :flex -66) (:knees :flex 96) (:thigh-l :flex 74)
     (:arm-l :flex 60 :side 30) (:elbow-l :flex 40) (:hand-l :flex 50))
  (8 (:root :u -0.46 :f -0.12) (:spine :flex 58))                                                   ; coiled, held
  (:s :snap (:root :f 0.78 :u -0.26) (:spine :flex 50) (:chest :flex 10) (:head :flex -10) (:arm-l :flex 100 :side 8)
      (:elbow-l :flex 20) (:hand-l :flex 55) (:thigh-l :flex 66) (:knee-l :flex 62) (:thigh-r :flex -34) (:knee-r :flex 22))
  (:a (:root :f 0.82) (:head :flex 4))                                                               ; the teeth in
  (18 (:root :f 0.6 :u -0.2) (:spine :flex 18) (:chest :twist 45) (:head :flex -48 :twist 35) (:arm-l :flex 70 :side 30)
      (:elbow-l :flex 62))                                                                      ; wrenched sideways and back: torn off
  (27 (:root :f 0.5 :u -0.26) (:head :flex -52) (:spine :flex 30))
  (:end :ke-b-stance))
;; O MAPPUTATSU's rush (the aura / dash; the strike is :ke-stance-cut): he drops almost to all fours, the claw on the
;; ground, then springs, the broken cleaver swung up one-handed over his head, the claw reaching ahead
(defclip :ke-b-leap (0.7 :base :ke-b-stance)
  (0)
  (0.13 (:root :u -0.5) (:knees :flex 104) (:thighs :flex 80) (:spine :flex 62) (:chest :flex 20) (:head :flex -70)
        (:arm-l :flex 70 :side 20) (:elbow-l :flex 20) (:hand-l :flex 60) (:arm-r :flex -40 :side 40) (:hand-r :flex -95))
  (0.25 (:root :u 0.05) (:thighs :flex 60) (:knees :flex 96) (:spine :flex 10) (:chest :flex 0) (:head :flex -30)
        (:arm-r :flex 185 :side 20) (:elbow-r :flex 30) (:hand-r :twist 0 :flex -60) (:arm-l :flex 110 :side 30) (:elbow-l :flex 30))
  (0.7 (:root :u 0.05) (:thighs :flex 55) (:knees :flex 90) (:arm-r :flex 188 :side 18) (:spine :flex 4)))
;; the MAPPUTATSU cinematic (ken-oni-kikon-cine plays it at 25/68 speed: the snap at 0.42 lands on its frame 68): the
;; wind-up is the beast rearing: sunk into the crouch, then up on his toes, back arched, the cleaver swung high over
;; his head in the right, the left claw thrust out, the jaw open; then one vertical crash, lunging through
(defclip :ke-b-kikon (1.5 :base :ke-b-stance)
  (0)
  (0.15 (:root :u -0.46) (:spine :flex 58) (:chest :flex 20) (:head :flex -68) (:knees :flex 100) (:thighs :flex 76)
        (:arm-r :flex -45 :side 36) (:hand-r :flex -95) (:arm-l :flex 50 :side 50) (:elbow-l :flex 40))
  (0.35 (:root :u -0.1 :f -0.1) (:spine :flex -16) (:chest :flex -10 :twist -20) (:head :flex -22)
        (:arm-r :flex 195 :side 24) (:elbow-r :flex 36) (:hand-r :twist 0 :flex -70)
        (:arm-l :flex 95 :side 40) (:elbow-l :flex 10) (:hand-l :flex 60)
        (:thigh-r :flex -20 :side 16) (:knee-r :flex 40) (:thigh-l :flex 50 :side 16) (:knee-l :flex 60))
  (0.42 :snap (:root :u -0.42 :f 0.8) (:spine :flex 66) (:chest :flex 16 :twist 10) (:head :flex -60)
        (:arm-r :flex 30 :side 8) (:elbow-r :flex 5) (:hand-r :twist -10 :flex -110) (:arm-l :flex 40 :side 60) (:elbow-l :flex 30)
        (:thigh-l :flex 78) (:knee-l :flex 84) (:thigh-r :flex -28) (:knee-r :flex 40))
  (1.0 (:root :u -0.4 :f 0.8) (:spine :flex 62))
  (1.5 :ke-b-stance (:root :f 0.8)))
;;; ---------------------------------------------------------------- the Bankai's own strikes (DUEL_KEN_REWORK §8)
;;; The moves it borrowed (J1 / J2 the base Q1 / Q2, K1 / K2 the base F1 / F2, K3 RYOTE's KABUTO-WARI, TATE-GOTO the meteor,
;;; MAPPUTATSU the stance's cut) play these through the kit's :clip-map, at those clips' S/A/R: low, from the crouch,
;;; the head down, the cleaver in the right hand, the left a claw.
(defstrike :ke-b-q1 (7 3 12 :base :ke-b-stance)        ; J1: a beast's hack, forehand, short off the right shoulder
  (0)
  (3 (:arm-r :flex 140 :side 40) (:elbow-r :flex 80) (:hand-r :flex -40 :twist 0) (:chest :twist -30 :flex 10)
     (:root :u -0.34 :f -0.04) (:head :flex -60 :twist 10))
  (5 (:arm-r :flex 148) (:chest :twist -34))                                                   ; held
  (:s :snap (:arm-r :flex 50 :side 10) (:elbow-r :flex 20) (:hand-r :flex -40) (:chest :twist 30 :flex 20) (:spine :flex 46)
      (:root :f 0.3 :u -0.36) (:head :flex -62 :twist -8) (:arm-l :flex 20 :side 60) (:elbow-l :flex 50))
  (:a (:arm-r :flex 36 :side 0) (:chest :twist 38) (:root :f 0.33 :u -0.38))
  (15 (:chest :twist 32) (:root :f 0.26 :u -0.35))
  (:end :ke-b-stance))
(defstrike :ke-b-q2 (7 3 13 :base :ke-b-stance)        ; J2: the backhand hack, low, out to the right
  (0)
  (3 (:arm-r :flex 70 :side -30) (:elbow-r :flex 80) (:hand-r :flex -60 :twist 0) (:chest :twist 40 :flex 18)
     (:root :u -0.36) (:head :flex -60 :twist -14) (:arm-l :flex 10 :side 50))
  (5 (:chest :twist 46) (:arm-r :side -36))                                                    ; held
  (:s :snap (:arm-r :flex 50 :side 55) (:elbow-r :flex 50) (:hand-r :flex 0) (:chest :twist -36 :flex 14) (:spine :flex 42)
      (:root :f 0.32 :u -0.34) (:head :flex -58 :twist 10) (:arm-l :flex 40 :side 30) (:elbow-l :flex 70))
  (:a (:arm-r :side 66) (:chest :twist -44) (:root :f 0.35))
  (16 (:chest :twist -38) (:root :f 0.28))
  (:end :ke-b-stance))
(defstrike :ke-b-f1 (16 4 20 :base :ke-b-stance)       ; K1 ONATA: sprung out of the crouch, a hatchet chop from overhead
  (0)
  (6 (:root :u -0.5) (:knees :flex 104) (:thighs :flex 80) (:spine :flex 60) (:head :flex -70) (:arm-r :flex -40 :side 40)
     (:hand-r :flex -95) (:arm-l :flex 60 :side 30) (:elbow-l :flex 30))                        ; sunk to the floor
  (12 (:root :u 0.1 :f 0.1) (:spine :flex -12) (:chest :flex -8) (:head :flex -30) (:knees :flex 50) (:thighs :flex 40)
      (:arm-r :flex 185 :side 15) (:elbow-r :flex 60) (:hand-r :flex -50 :twist 0) (:arm-l :flex 100 :side 40) (:elbow-l :flex 20))
  (14 (:root :u 0.14 :f 0.12) (:spine :flex -16))                                              ; up, held
  (:s :snap (:root :u -0.4 :f 0.8) (:spine :flex 58) (:chest :flex 16) (:head :flex -55) (:arm-r :flex 60 :side 5)
      (:elbow-r :flex 5) (:hand-r :flex 0) (:arm-l :flex 40 :side 60) (:elbow-l :flex 30)
      (:thigh-l :flex 76) (:knee-l :flex 84) (:thigh-r :flex -24) (:knee-r :flex 40))
  (:a (:root :u -0.44 :f 0.84) (:spine :flex 62) (:arm-r :flex 44) (:hand-r :flex -30))
  (28 (:root :u -0.42 :f 0.8) (:spine :flex 58))
  (:end :ke-b-stance))
(defstrike :ke-b-f2 (20 5 28 :base :ke-b-stance)       ; K2 EGURI-AGE: the blade laid on the floor ahead, then gouged up
  (0)
  (8 (:root :u -0.5 :f 0.05) (:spine :flex 62) (:head :flex -66) (:knees :flex 100) (:thighs :flex 76)
     (:arm-r :flex 40 :side 20) (:elbow-r :flex 10) (:hand-r :flex -150 :twist 0) (:arm-l :flex 60 :side 30) (:elbow-l :flex 40))
  (16 (:root :u -0.52 :f 0.2) (:spine :flex 64))                                               ; scraping, held
  (:s :snap (:root :u -0.15 :f 0.5) (:spine :flex 20) (:chest :flex -6) (:head :flex -30) (:knees :flex 50) (:thighs :flex 40)
      (:arm-r :flex 85 :side 5) (:elbow-r :flex 5) (:hand-r :flex -80) (:arm-l :flex 20 :side 60))
  (:a (:arm-r :flex 150) (:hand-r :flex -40) (:root :u -0.08 :f 0.52) (:spine :flex 8))
  (36 (:arm-r :flex 140) (:root :u -0.12 :f 0.5) (:spine :flex 12))
  (:end :ke-b-stance))
(defstrike :ke-b-f3 (21 5 28 :base :ke-b-stance)       ; K3: a leap, the cleaver cocked over the left shoulder, the cleave
  (0)                                                   ; down through the guard and shield both, to the right
  (6 (:root :u -0.48) (:knees :flex 100) (:thighs :flex 76) (:spine :flex 60) (:head :flex -68) (:arm-r :flex 60 :side -40)
     (:elbow-r :flex 90) (:hand-r :flex -40))
  (13 (:root :u 0.45 :f 0.2) (:spine :flex -10) (:chest :twist 40) (:head :flex -30 :twist -20) (:knees :flex 70) (:thighs :flex 50)
      (:arm-r :flex 160 :side -30) (:elbow-r :flex 70) (:hand-r :flex -40 :twist 0) (:arm-l :flex 70 :side 60) (:elbow-l :flex 20))
  (17 (:root :u 0.52 :f 0.25) (:chest :twist 46))                                              ; high, held
  (:s :snap (:root :u -0.36 :f 0.6) (:chest :twist -35 :flex 18) (:spine :flex 52) (:head :flex -55 :twist 10)
      (:arm-r :flex 60 :side 45) (:elbow-r :flex 5) (:hand-r :flex 0) (:arm-l :flex 20 :side 40)
      (:thigh-l :flex 70) (:knee-l :flex 80) (:thigh-r :flex -22) (:knee-r :flex 40))
  (:a (:root :u -0.4 :f 0.62) (:chest :twist -45) (:arm-r :side 60))
  (40 (:root :u -0.38 :f 0.6) (:chest :twist -40))
  (:end :ke-b-stance))
(defstrike :ke-b-split (26 4 30 :base :ke-b-stance)    ; SP1 TATE-GOTO: higher, both hands over the right shoulder, the
  (0)                                                   ; diagonal down through the guard
  (8 (:root :u -0.5) (:knees :flex 104) (:thighs :flex 80) (:spine :flex 62) (:head :flex -70))
  (16 (:root :u 0.75 :f 0.15) (:spine :flex -24) (:chest :twist -30) (:head :flex -30) (:knees :flex 80) (:thighs :flex 60)
      (:arm-r :flex 175 :side 35) (:elbow-r :flex 70) (:hand-r :flex -40 :twist 0) (:arm-l :flex 160 :side 0 :twist 40) (:elbow-l :flex 70))
  (22 (:root :u 0.85 :f 0.2) (:spine :flex -28) (:chest :twist -36))                           ; arched, held
  (:s :snap (:root :u -0.42 :f 0.5) (:chest :twist 30 :flex 18) (:spine :flex 60) (:head :flex -58) (:arm-r :flex 40 :side -20)
      (:elbow-r :flex 5) (:hand-r :flex -50) (:arm-l :flex 30 :side -40 :twist 60) (:elbow-l :flex 30)
      (:thigh-l :flex 76) (:knee-l :flex 86) (:thigh-r :flex -24) (:knee-r :flex 44))
  (:a (:root :u -0.46 :f 0.52) (:spine :flex 64) (:chest :twist 36))
  (44 (:root :u -0.42 :f 0.5) (:spine :flex 60))
  (:end :ke-b-stance))
(defstrike :ke-b-cut (8 4 24 :base :ke-b-stance)       ; O MAPPUTATSU's strike: from the leap's raised cleaver, one
  (0 (:root :u 0.05) (:arm-r :flex 188 :side 18) (:elbow-r :flex 30) (:hand-r :twist 0 :flex -60) (:spine :flex 4)   ; vertical
     (:knees :flex 90) (:thighs :flex 55) (:arm-l :flex 110 :side 30) (:elbow-l :flex 30))     ; through him, to the floor
  (5 (:root :u 0.1) (:spine :flex -10) (:arm-r :flex 195))                                     ; held at the top
  (:s :snap (:root :u -0.44 :f 0.6) (:spine :flex 64) (:chest :flex 16) (:head :flex -58) (:arm-r :flex 30 :side 5) (:elbow-r :flex 5)
      (:hand-r :flex -80) (:arm-l :flex 40 :side 60) (:elbow-l :flex 30) (:thigh-l :flex 78) (:knee-l :flex 86) (:thigh-r :flex -26) (:knee-r :flex 42))
  (:a (:root :u -0.48 :f 0.62) (:spine :flex 68) (:hand-r :flex -95))
  (24 (:root :u -0.45 :f 0.6) (:spine :flex 64))
  (:end :ke-b-stance))
(setf *grip-clips* (append *grip-clips* '(:ke-b-split)))
;;; ---------------------------------------------------------------- KATAUDE, bare-handed (DUEL_KEN_REWORK §8)
;;; After the burst (the user 2026-10-09: 「改成空手（照原作）」): no blade; the burst right arm hangs; the left fist, a grab
;;; and the legs. The base moves (at x0.7 reach) play these through the kit's :clip-map, at the base clips' S/A/R.
(defpose :ke-a-stance (:base :ke-b-stance)              ; the oni's crouch, the ruined right arm hanging, the left claw up
  (:arm-r :flex -4 :side 12 :twist 0) (:elbow-r :flex 14) (:hand-r :flex 10 :twist 0)
  (:arm-l :flex 50 :side 34) (:elbow-l :flex 72) (:hand-l :flex 40))
(defclip :ke-a-stance (0.8 :loop t :base :ke-a-stance)
  (0) (0.4 (:chest :flex 24) (:spine :flex 38) (:root :u -0.33) (:head :flex -62) (:hand-l :flex 55) (:elbow-l :flex 80)))
(defstrike :ke-a-q1 (7 3 12 :base :ke-a-stance)        ; J1: a lunging left hook
  (0)
  (3 (:chest :twist 36 :flex 20) (:arm-l :flex 40 :side 70) (:elbow-l :flex 110) (:root :u -0.36 :f -0.06) (:head :flex -60))
  (5 (:chest :twist 42))
  (:s :snap (:chest :twist -40 :flex 10) (:spine :flex 34) (:arm-l :flex 90 :side 10) (:elbow-l :flex 40) (:hand-l :flex 0)
      (:root :f 0.45 :u -0.24) (:thigh-l :flex 58) (:knee-l :flex 52) (:thigh-r :flex -30) (:knee-r :flex 24))
  (:a (:chest :twist -48) (:root :f 0.48))
  (15 (:chest :twist -40) (:root :f 0.4 :u -0.28))
  (:end :ke-a-stance))
(defstrike :ke-a-q2 (7 3 13 :base :ke-a-stance)        ; J2: the backfist, swung out across
  (0)
  (3 (:chest :twist -30 :flex 18) (:arm-l :flex 60 :side -20) (:elbow-l :flex 120) (:root :u -0.34) (:head :flex -58))
  (5 (:chest :twist -36))
  (:s :snap (:chest :twist 30 :flex 12) (:spine :flex 36) (:arm-l :flex 80 :side 60) (:elbow-l :flex 20) (:hand-l :flex 0)
      (:root :f 0.6 :u -0.26) (:thigh-l :flex 50) (:knee-l :flex 50))
  (:a (:chest :twist 38) (:arm-l :side 70) (:root :f 0.63))
  (16 (:chest :twist 32) (:root :f 0.55))
  (:end :ke-a-stance))
(defstrike :ke-a-f1 (16 4 20 :base :ke-a-stance)       ; K1: the overhand haymaker, the whole body thrown after it
  (0)
  (8 (:root :u -0.46 :f -0.1) (:spine :flex 56) (:chest :twist 40) (:arm-l :flex 150 :side 50) (:elbow-l :flex 90) (:head :flex -64)
     (:knees :flex 96) (:thighs :flex 72))
  (13 (:root :u -0.48 :f -0.12) (:chest :twist 46))                                            ; coiled, held
  (:s :snap (:root :f 0.9 :u -0.3) (:chest :twist -40 :flex 20) (:spine :flex 50) (:arm-l :flex 85 :side 0) (:elbow-l :flex 10)
      (:hand-l :flex 0) (:head :flex -50) (:thigh-l :flex 70) (:knee-l :flex 70) (:thigh-r :flex -30) (:knee-r :flex 30))
  (:a (:root :f 0.96 :u -0.34) (:chest :twist -48) (:spine :flex 56))
  (28 (:root :f 0.9 :u -0.32) (:chest :twist -42))
  (:end :ke-a-stance))
(defstrike :ke-a-f2 (20 5 28 :base :ke-a-stance)       ; K2: the foot catch: dropped to the floor, the left hand shoots
  (0)                                                   ; out low and grabs, then heaves up and over
  (8 (:root :u -0.55 :f 0.0) (:spine :flex 66) (:head :flex -68) (:knees :flex 106) (:thighs :flex 82) (:arm-l :flex 20 :side 30)
     (:elbow-l :flex 60))
  (16 (:root :u -0.57 :f 0.1) (:spine :flex 68))                                               ; down, held
  (:s :snap (:root :u -0.45 :f 0.7) (:spine :flex 62) (:arm-l :flex 60 :side 5) (:elbow-l :flex 5) (:hand-l :flex 60)
      (:head :flex -40) (:thigh-l :flex 80) (:knee-l :flex 96) (:thigh-r :flex -20) (:knee-r :flex 70))
  (:a (:root :u -0.2 :f 0.6) (:spine :flex 10) (:arm-l :flex 160 :side 20) (:elbow-l :flex 30) (:head :flex -20))   ; heaved over
  (36 (:root :u -0.25 :f 0.5) (:spine :flex 20) (:arm-l :flex 150))
  (:end :ke-a-stance))
(defstrike :ke-a-spin (11 4 22 :base :ke-a-stance)     ; K3 BUNMAWASHI: a spinning sweep, the right leg out low
  (0)
  (5 (:root :u -0.44) (:knees :flex 96) (:thighs :flex 70) (:chest :twist -30) (:arm-l :flex 40 :side 60))
  (8 (:root :u -0.46 :yaw -15))                                                                ; coiled, held
  (:s :snap (:root :yaw 360 :u -0.5 :f 0.3) (:spine :flex 40) (:thigh-r :flex 70 :side 30) (:knee-r :flex 5) (:thigh-l :flex 80)
      (:knee-l :flex 110) (:arm-l :flex 10 :side 40))
  (:a (:root :yaw 400 :u -0.5 :f 0.34))
  (22 (:root :yaw 385 :u -0.46 :f 0.32) (:thigh-r :flex 40 :side 20) (:knee-r :flex 40))
  (:end :ke-a-stance (:root :yaw 360)))
(defstrike :ke-a-haymaker (8 4 24 :base :ke-a-stance)  ; the stance's release and O's strike: the left haymaker from wide
  (0 (:chest :twist 40) (:arm-l :flex 40 :side 90) (:elbow-l :flex 30) (:root :u -0.3))
  (4 (:chest :twist 48) (:arm-l :side 96))
  (:s :snap (:chest :twist -50 :flex 16) (:spine :flex 40) (:arm-l :flex 90 :side 0) (:elbow-l :flex 20) (:hand-l :flex 0)
      (:root :f 0.6 :u -0.24) (:thigh-l :flex 60) (:knee-l :flex 60) (:thigh-r :flex -30))
  (:a (:chest :twist -60) (:root :f 0.66))
  (20 (:chest :twist -54) (:root :f 0.6))
  (:end :ke-a-stance))
(defstrike :ke-a-stomp (22 4 26 :base :ke-a-stance)    ; SP1's leap: up, the knees tucked, down onto the right heel
  (0)
  (6 (:root :u -0.5) (:knees :flex 104) (:thighs :flex 80) (:spine :flex 60))
  (12 (:root :u 0.6) (:thighs :flex 80) (:knees :flex 110) (:spine :flex 10) (:arm-l :flex 120 :side 60) (:head :flex -30))
  (19 (:root :u 0.76) (:thigh-r :flex 90) (:knee-r :flex 40))                                  ; the heel raised, held
  (:s :snap (:root :u -0.2 :f 0.42) (:thigh-r :flex 30) (:knee-r :flex 5) (:thigh-l :flex 70) (:knee-l :flex 100) (:spine :flex 30)
      (:arm-l :flex 40 :side 70) (:head :flex -50))
  (:a (:root :u -0.26 :f 0.44))
  (34 (:root :u -0.3 :f 0.42) (:spine :flex 34))
  (:end :ke-a-stance))
(defstrike :ke-a-flurry (4 36 24 :base :ke-a-stance)   ; SP2's flurry: left fists at f4 10 16 22 28, the uppercut at f40
  (0 (:chest :twist 30) (:arm-l :flex 40 :side 60) (:elbow-l :flex 110))
  (4 :snap (:chest :twist -30) (:arm-l :flex 90 :side 10) (:elbow-l :flex 20) (:root :f 0.2))
  (7 (:chest :twist 20) (:arm-l :flex 60 :side 50) (:elbow-l :flex 100))
  (10 :snap (:chest :twist -36) (:arm-l :flex 95 :side 0) (:elbow-l :flex 15) (:root :f 0.3))
  (13 (:chest :twist 24) (:arm-l :flex 60 :side 50) (:elbow-l :flex 100))
  (16 :snap (:chest :twist -30) (:arm-l :flex 85 :side 15) (:elbow-l :flex 25) (:root :f 0.4))
  (19 (:chest :twist 20) (:arm-l :flex 60 :side 50) (:elbow-l :flex 100))
  (22 :snap (:chest :twist -36) (:arm-l :flex 95 :side 0) (:elbow-l :flex 15) (:root :f 0.5))
  (25 (:chest :twist 24) (:arm-l :flex 60 :side 50) (:elbow-l :flex 100))
  (28 :snap (:chest :twist -32) (:arm-l :flex 90 :side 10) (:elbow-l :flex 20) (:root :f 0.6))
  (34 (:root :u -0.46 :f 0.6) (:spine :flex 56) (:arm-l :flex -10 :side 30) (:elbow-l :flex 100) (:knees :flex 100))
  (40 :snap (:root :u 0.0 :f 0.8) (:spine :flex 4) (:arm-l :flex 160 :side 10) (:elbow-l :flex 30))
  (46 (:arm-l :flex 168) (:root :u 0.05 :f 0.82))
  (:end :ke-a-stance))

;; the Bankai's burst (ken-bankai-cine f58): he rises out of the crouch, head thrown back, arms flung wide and low, claws
;; open, the knees still bent; then the roar comes forward at the opponent (the close-up on the face at f78)
(defclip :ke-b-roar (1.0 :base :ke-b-stance)
  (0 (:root :u -0.44) (:spine :flex 60) (:head :flex -70) (:knees :flex 100) (:thighs :flex 74))
  (0.12 :snap (:root :u -0.2) (:spine :flex -10) (:chest :flex -14) (:neck :flex -10) (:head :flex -34)
        (:arm-l :flex 20 :side 88) (:elbow-l :flex 30) (:hand-l :flex 60) (:arm-r :flex -10 :side 70) (:hand-r :flex -95)
        (:thigh-r :flex -6 :side 24) (:knee-r :flex 50) (:thigh-l :flex 44 :side 24) (:knee-l :flex 64))
  (0.3 (:spine :flex 14) (:chest :flex 4) (:neck :flex 0) (:head :flex -30) (:arm-l :side 92) (:arm-r :side 74))  ; at them
  (1.0 (:spine :flex 16) (:chest :flex 6) (:head :flex -32) (:root :u -0.22)))

;;; ---------------------------------------------------------------- the core system's stances and charges (DUEL_KEN_CORE)
;;; One rest per SP pointer (kit :core :stances), so the opponent reads the next NS before it starts: 1 the chain (leaning in, the
;;; blade carried low and forward), 2 the rush (hunched, the blade resting on the shoulder, weight on the front foot), 3 the kamae
;;; (upright, the blade at the centre line in both hands).
(defpose :ke-st-chain (:base :ke-stance)
  (:root :f 0.08 :u -0.1) (:spine :flex 14) (:chest :twist -8) (:head :flex -10)
  (:arm-r :flex 38 :side 18) (:elbow-r :flex 38) (:hand-r :flex -80)
  (:arm-l :flex 24 :side 24) (:elbow-l :flex 40)
  (:thigh-l :flex 34 :side 8) (:knee-l :flex 40) (:thigh-r :flex -16 :side 12) (:knee-r :flex 24))
(defclip :ke-st-chain (1.6 :loop t :base :ke-st-chain)
  (0) (0.8 (:chest :flex 3) (:root :u -0.11)))
(defpose :ke-st-rush (:base :ke-stance)
  (:root :f 0.12 :u -0.16) (:spine :flex 22) (:chest :twist 6) (:head :flex -18 :twist 4)
  (:arm-r :flex 112 :side 22) (:elbow-r :flex 118) (:hand-r :flex -40)
  (:arm-l :flex -10 :side 34) (:elbow-l :flex 24)
  (:thigh-l :flex 42 :side 8) (:knee-l :flex 52) (:thigh-r :flex -22 :side 14) (:knee-r :flex 30))
(defclip :ke-st-rush (1.4 :loop t :base :ke-st-rush)
  (0) (0.7 (:chest :flex 4) (:root :u -0.17)))
(defpose :ke-st-kamae (:base :ke-stance)
  (:root :u -0.04) (:pelvis :twist 8) (:spine :flex -2) (:chest :twist -4) (:head :flex 2 :twist 0)
  (:arm-r :flex 70 :side 8) (:elbow-r :flex 62) (:hand-r :flex -70)
  (:arm-l :flex 66 :side 10) (:elbow-l :flex 70) (:hand-l :flex -30)
  (:thigh-l :flex 20 :side 8) (:knee-l :flex 24) (:thigh-r :flex -10 :side 10) (:knee-r :flex 16))
(defclip :ke-st-kamae (2.0 :loop t :base :ke-st-kamae)
  (0) (1.0 (:chest :flex 2) (:root :u -0.05)))
;; NS3's three charges (the kendo kamae gathering reiatsu, each higher than the last; they hit nothing)
(defstrike :ke-chg1 (20 0 14 :base :ke-st-kamae)
  (0)
  (10 (:root :u -0.1) (:knees :flex 36) (:arm-r :flex 78 :side 6) (:elbow-r :flex 70))
  (:s (:root :u -0.1) (:knees :flex 38) (:arm-r :flex 80 :side 6) (:elbow-r :flex 72))
  (:end :ke-st-kamae))
(defstrike :ke-chg2 (16 0 14 :base :ke-st-kamae)
  (0)
  (8 (:root :u -0.08) (:arm-r :flex 120 :side 14) (:elbow-r :flex 90) (:arm-l :flex 112 :side 18) (:elbow-l :flex 84) (:knees :flex 30))
  (:s (:root :u -0.1) (:arm-r :flex 126 :side 16) (:elbow-r :flex 92) (:arm-l :flex 118 :side 20) (:elbow-l :flex 86) (:knees :flex 36))
  (:end :ke-st-kamae))
(defstrike :ke-chg3 (16 0 20 :base :ke-st-kamae)
  (0)
  (8 (:root :u 0.02) (:arm-r :flex 160 :side 20) (:elbow-r :flex 100) (:arm-l :flex 150 :side 24) (:elbow-l :flex 96) (:spine :flex -10) (:head :flex -12))
  (:s (:root :u 0.03) (:arm-r :flex 168 :side 22) (:elbow-r :flex 104) (:arm-l :flex 156 :side 26) (:elbow-l :flex 98) (:spine :flex -14) (:head :flex -16))
  (:end :ke-st-kamae))

;;; ---------------------------------------------------------------- pointer 2's own strikes (DUEL_KEN_CORE §6: 蠻力肩撞與橫掃)
;; NS2a: a low shoulder charge. The wind-up crouches and coils the chest back, the blade trailing; the strike drives the lead shoulder in
(defstrike :ke-rush-a (22 4 26 :base :ke-st-rush)
  (0)
  (8 (:root :u -0.3 :f -0.06) (:knees :flex 70) (:thighs :flex 48) (:spine :flex 34) (:chest :twist -48) (:pelvis :twist -18)
     (:arm-r :flex -30 :side 36) (:elbow-r :flex 14) (:arm-l :flex 60 :side 20) (:elbow-l :flex 60) (:head :flex -20))
  (16 (:root :u -0.34 :f -0.1) (:chest :twist -58) (:spine :flex 38))                                              ; held, coiled
  (:s :snap (:root :u -0.22 :f 0.62) (:spine :flex 42) (:chest :twist 52) (:pelvis :twist 24) (:arm-l :flex 82 :side 6) (:elbow-l :flex 96)
      (:arm-r :flex -36 :side 40) (:thigh-r :flex 58) (:knee-r :flex 62) (:thigh-l :flex -14) (:knee-l :flex 36) (:head :flex -26))
  (:a (:root :f 0.7 :u -0.24) (:chest :twist 58) (:spine :flex 46))
  (34 (:root :f 0.64 :u -0.22) (:chest :twist 52))
  (:end :ke-stance))
;; NS2b: the sweep: the blade dragged low behind, then one wide flat backhand across the whole front
(defstrike :ke-sweep (14 3 18 :base :ke-st-rush)
  (0)
  (6 (:root :u -0.2) (:knees :flex 50) (:spine :flex 20) (:chest :twist 62) (:pelvis :twist 30) (:arm-r :flex 10 :side 76) (:elbow-r :flex 8)
     (:hand-r :flex -60) (:arm-l :flex 10 :side 52) (:head :twist 18))
  (10 (:chest :twist 70) (:arm-r :side 84))                                                                          ; held, wound
  (:s :snap (:root :u -0.16 :f 0.3) (:chest :twist -66) (:pelvis :twist -28) (:arm-r :flex 74 :side 40) (:elbow-r :flex 4)
      (:arm-l :flex 20 :side 70) (:spine :flex 26) (:thigh-r :flex 30) (:knee-r :flex 36) (:head :twist -16))
  (:a (:chest :twist -76) (:arm-r :side 30) (:root :f 0.36))
  (24 (:chest :twist -70) (:root :f 0.3))
  (:end :ke-stance))
;; AS2a: the grab and smash: the left hand takes the head, the right pommel / fist hammers down
(defstrike :ke-smash (16 4 20 :base :ke-st-rush)
  (0)
  (6 (:root :f 0.1 :u -0.12) (:spine :flex 22) (:arm-l :flex 100 :side 12) (:elbow-l :flex 24) (:hand-l :flex -20)
     (:arm-r :flex 150 :side 24) (:elbow-r :flex 110))
  (11 (:arm-r :flex 170 :side 20) (:elbow-r :flex 120) (:spine :flex 4) (:root :u -0.06))                           ; the fist held high
  (:s :snap (:root :f 0.36 :u -0.28) (:spine :flex 50) (:arm-r :flex 40 :side 4) (:elbow-r :flex 20) (:arm-l :flex 96 :side 10)
      (:elbow-l :flex 20) (:head :flex -30) (:knees :flex 56))
  (:a (:spine :flex 56) (:root :f 0.4 :u -0.3))
  (28 (:spine :flex 52))
  (:end :ke-stance))

;;; ---------------------------------------------------------------- KATATE's core set (DUEL_KEN_KATATE): the free left hand
;;; One rest per pointer, on KATATE's own rest (:ke-k-rest: the cleaver's haft on the right shoulder): what the left hand does tells the
;;; next NS: 1 open and loose (the chain), 2 a fist forward, hunched (the rush), 3 a raised guard hand, upright (the kamae).
(defpose :ke-kt-st-chain (:base :ke-k-rest)
  (:root :f 0.06 :u -0.08) (:spine :flex 12) (:chest :twist -6) (:head :flex -8)
  (:arm-l :flex 24 :side 30) (:elbow-l :flex 36) (:hand-l :flex 20)
  (:thigh-l :flex 30 :side 8) (:knee-l :flex 36) (:thigh-r :flex -14 :side 12) (:knee-r :flex 22))
(defclip :ke-kt-st-chain (1.6 :loop t :base :ke-kt-st-chain)
  (0) (0.8 (:chest :flex 3) (:root :u -0.09)))
(defpose :ke-kt-st-rush (:base :ke-k-rest)
  (:root :f 0.1 :u -0.14) (:spine :flex 20) (:chest :twist 8) (:head :flex -16)
  (:arm-l :flex 62 :side 14) (:elbow-l :flex 95) (:hand-l :flex -20)
  (:thigh-l :flex 40 :side 8) (:knee-l :flex 48) (:thigh-r :flex -20 :side 14) (:knee-r :flex 28))
(defclip :ke-kt-st-rush (1.4 :loop t :base :ke-kt-st-rush)
  (0) (0.7 (:chest :flex 4) (:root :u -0.15)))
(defpose :ke-kt-st-kamae (:base :ke-k-rest)
  (:root :u -0.04) (:pelvis :twist 8) (:spine :flex -2) (:chest :twist -4) (:head :flex 2)
  (:arm-l :flex 80 :side 18) (:elbow-l :flex 70) (:hand-l :flex -30)
  (:thigh-l :flex 20 :side 8) (:knee-l :flex 24) (:thigh-r :flex -10 :side 10) (:knee-r :flex 16))
(defclip :ke-kt-st-kamae (2.0 :loop t :base :ke-kt-st-kamae)
  (0) (1.0 (:chest :flex 2) (:root :u -0.05)))
;; the SA: a left jab (the cleaver stays on the shoulder)
(defstrike :ke-kt-jab (7 3 12 :base :ke-k-rest)
  (0)
  (3 (:root :f 0.04 :u -0.04) (:chest :twist 14) (:spine :flex 6) (:arm-l :flex 40 :side 20) (:elbow-l :flex 110) (:hand-l :flex -10))   ; the fist cocked
  (:s :snap (:root :f 0.22 :u -0.06) (:chest :twist -22) (:pelvis :twist -10) (:arm-l :flex 82 :side 6) (:elbow-l :flex 4) (:hand-l :flex -20)
      (:thigh-r :flex 30) (:knee-r :flex 30))
  (:a (:root :f 0.28) (:chest :twist -26) (:arm-l :flex 86))
  (:end :ke-k-rest))
;; the V3 Shikai's two stances (DUEL_KEN_V3 §5, §14; the user's pictures in .refs/kenpachi-v3/): pointer 1 the statue: the cleaver
;; slung, the hilt low at his right hip, the butt out to his right, the blade up behind his head toward his left, half-crouched and
;; leaning in, the left arm out (「斜扛大刀，身體半蹲前傾，呈現衝刺預備」; the right arm solved by FK for the grip at (0.42 1.0 0.12)
;; and the blade along (-0.48 0.70 -0.53), r u f: behind his back, the spine 0.3 m behind the shoulders and the flat clear of the
;; head; before, (0.34 0.98 0.18) along (-0.51 0.77 -0.38) ran the haft through his right chest and the flat through his head, the
;; user 2026-11-03: 「刀都劈開自己了」, DUEL_KEN_V3 §17); pointer 2 the manga panel: the blade's back on the right shoulder, the hilt at him,
;; standing easy (「將刀背扛在單肩上，刀柄對準前方，輕鬆站立」; KATATE's shoulder rest, upright)
(defpose :ke-s-sling (:base :ke-k-rest)       ; (the old stance: pointer 1's moves key from it, §18)
  (:root :u -0.18 :f 0.04) (:pelvis :twist 12) (:spine :flex 22) (:chest :twist -10) (:head :flex -16 :twist -8)
  (:arm-r :flex -34 :side 16 :twist -7) (:elbow-r :flex 84) (:hand-r :flex 95 :twist 8 :side -1)
  (:arm-l :flex 34 :side 52 :twist 0) (:elbow-l :flex 36) (:hand-l :flex -10)
  (:thigh-l :flex 44 :side 14) (:knee-l :flex 58) (:thigh-r :flex -12 :side 18) (:knee-r :flex 38))
;; the stance itself, re-posed to the statue (the user 2026-11-03, after 「你再跟我好好形容一遍這個站姿長什麼樣子？」 and 「很好，請以此觀察
;;結果進行修改」, DUEL_KEN_V3 §18), restarted from a copy of pointer 2's (「我們用指針二的副本開始修改，讓他變成我期望的指針一站姿」):
;; pointer 2's shoulder rest written out in full (:ke-k-rest's arms included), changed step by step: 1. leaning in, half
;; crouched (「身體前傾，腿部呈現半蹲姿態」: the spine 0 -> 22, the head -16 to keep the eyes on him, the hips 0.18 m lower, both
;; knees bent 58-64, the feet kept on the floor); 2. 「改成握住刀柄 1/2 處，手臂從面向前方改成向外轉動 45°」: the hand, the hilt and the blade
;; turned 45 degrees out about the shoulder (the hilt to his front right, the blade back over his left; solved by FK: the grip
;; (0.20 1.27 0.58) -> (0.50 1.27 0.54) r u f; the half-way grip undone in step 7); 3. 「兩個指針的刀身以刀刃為尖端、刀脊為中心向外偏轉 15°」, then 「再向外偏轉 5°」 twice: the weapon rolled 25 degrees about its
;; spine, the edge out (:weapon-r :side, the roll about the blade's own axis; the moves key from the sling, unrolled); 4. 「繼續修改
;; 指針 1，請將左肩往前傾斜，右肩後拉使大刀與人物面向的方向呈現 90°」: the chest turned 56 degrees to his right (spine twist -26, chest -4 ->
;; -30), the left shoulder 0.36 m ahead of the right, the blade at 90 degrees to his facing (was 130, FK), the head turned back 45 to
;; face the opponent; 5. 「身體再更往前傾，下盤配合些微下蹲，右膝打開、右腳往外跨一小步。左手幫我調整合適的姿勢」: the spine 22 -> 32, the hips
;; 0.06 m lower (the left knee 64 -> 74), the right foot 0.14 m further out on the floor with the knee opened outside it (FK), the head
;; -29 / 42 to keep the same view, the right ankle levelling the sole (the toes 30 degrees out); the left arm hanging loose ahead of
;; the left knee, a little out, the elbow soft (56); 6. 「右膝太開了，往前收一點」: the right knee 0.1 m forward and 0.05 in (now over
;; the foot, not outside it), the foot where it was; 7. 「刀柄握回原本 0.3 處」: the stance holds the haft where every move does
;; (*KE-NOZ-GRIP*), the slide of step 2 removed; then the whole weapon pushed 0.07 m off the back of his head (the nearest point 0.16
;; -> 0.22 m from the head's centre: no graze; the blade 86.6 degrees to his facing; the arm by FK)
(defpose :ke-s-st-1 (:base :ke-k-rest)
  (:root :u -0.24 :f 0.04) (:pelvis :twist 8) (:spine :flex 32 :twist -26) (:chest :twist -30) (:head :flex -29 :twist 42)
  (:arm-r :flex 22 :side 34 :twist -52) (:elbow-r :flex 98) (:hand-r :flex 26 :twist -10 :side -6) (:weapon-r :side 25)
  (:arm-l :flex -16 :side 50 :twist -5) (:elbow-l :flex 56) (:hand-l :flex 0)
  (:thigh-l :flex 50 :side 10) (:knee-l :flex 74) (:thigh-r :flex 7 :side 45 :twist -45) (:knee-r :flex 65)
  (:foot-r :flex -34 :twist 26 :side -29))                                               ; (the sole flat, the toes 30 out)
(defclip :ke-s-st-1 (1.2 :loop t :base :ke-s-st-1)
  (0) (0.6 (:root :u -0.26 :f 0.05) (:spine :flex 34)))                                 ; coiled, breathing low
;; pointer 2's moves key from the old shoulder rest (:ke-s-shoulder); the stance itself: the blade rolled 25 degrees out about its
;; spine too (the user 2026-11-04, DUEL_KEN_V3 §18), and the hand lifted 0.06 m, the blade's direction kept, so the haft rests on the
;; haori's shoulder (0.01 m over it) instead of 0.05 m into it (「我發現指針 2 的刀柄似乎沉入肩膀中了？」, §18; the arm by FK)
(defpose :ke-s-shoulder (:base :ke-k-rest)
  (:root :u -0.02) (:pelvis :twist 8) (:spine :flex 0) (:chest :twist -4) (:head :flex 2)
  (:arm-l :flex 4 :side 16) (:elbow-l :flex 14) (:hand-l :flex 0)
  (:thigh-l :flex 8 :side 6) (:knee-l :flex 8) (:thigh-r :flex -4 :side 8) (:knee-r :flex 6))
(defpose :ke-s-st-2 (:base :ke-s-shoulder)
  (:arm-r :flex 43 :side 26 :twist -4) (:elbow-r :flex 109) (:hand-r :flex 18 :twist -2 :side -3) (:weapon-r :side 25))
(defclip :ke-s-st-2 (2.4 :loop t :base :ke-s-st-2)
  (0) (1.2 (:chest :flex 2) (:root :u -0.03)))                                           ; easy
;; the V3 Shikai's P2 L0 second segment (DUEL_KEN_V3 §12; the user 2026-11-03: 「我看不出 柄擊 與 上翹 的動作差異」, both played the
;; left jab above): the hilt flicked up, the right hand sunk low and the butt swung up through his front, the body rising with it
(defstrike :ke-s-flick (10 3 16 :base :ke-k-rest)
  (0)
  (6 (:root :u -0.16 :f 0.04) (:knees :flex 44) (:spine :flex 22) (:chest :twist 24) (:head :flex -10)
     (:arm-r :flex 4 :side 18) (:elbow-r :flex 112) (:hand-r :flex 20) (:arm-l :flex 20 :side 30))           ; sunk, the butt down
  (8 (:root :u -0.17) (:chest :twist 27) (:arm-r :flex 0))                                                    ; held
  (:s :snap (:root :u 0.04 :f 0.3) (:knees :flex 10) (:spine :flex -8) (:chest :twist -22) (:pelvis :twist -10) (:head :flex 8)
      (:arm-r :flex 100 :side 22) (:elbow-r :flex 104) (:hand-r :flex 34) (:arm-l :flex 10 :side 40))         ; the butt swept up
  (:a (:root :u 0.06 :f 0.34) (:arm-r :flex 108))                                                             ; (the blade dips behind)
  (:end :ke-k-rest))
;; the V3 Shikai's pointer-2 clips (DUEL_KEN_V3 §15)
;; NS2a TSUKA-UCHI: the right hand draws the hilt back along the shoulder (the butt 0.3 m in), held, then shoves it straight out,
;; the butt end at his face (1.4 m), the blade riding the shoulder all the way (the flick, unlike it, sinks and swings it up)
(defstrike :ke-s-jab (14 3 16 :base :ke-s-shoulder)
  (0 :ke-s-st-2)
  (6 :ke-s-shoulder (:root :f -0.06 :u -0.08) (:pelvis :twist 16) (:chest :twist -22) (:spine :flex -4) (:head :flex -4) (:knees :flex 20)
     (:arm-r :flex 22 :side -27 :twist 0) (:elbow-r :flex 140) (:hand-r :flex 5 :twist 0 :side 0)
     (:arm-l :flex 50 :side 24) (:elbow-l :flex 60) (:hand-l :flex -10))
  (11 (:root :f -0.08 :u -0.09) (:pelvis :twist 18) (:chest :twist -25) (:elbow-r :flex 142))
  (:s :snap (:root :f 0.12 :u -0.08) (:pelvis :twist -10) (:chest :twist 22) (:spine :flex 8) (:head :flex 0)
      (:thigh-l :flex 40 :side 6) (:knee-l :flex 40) (:thigh-r :flex -24 :side 8) (:knee-r :flex 14)
      (:arm-r :flex 39 :side -20 :twist -1) (:elbow-r :flex 108) (:hand-r :flex 32 :twist 14 :side 0)
      (:arm-l :flex -10 :side 30) (:elbow-l :flex 30))
  (:a (:root :f 0.14) (:chest :twist 24) (:arm-r :flex 41))
  (26 (:root :f 0.08 :u -0.05) (:chest :twist 10) (:pelvis :twist -4) (:spine :flex 4))
  (:end :ke-s-st-2))
;; NS2c: both hands on the hilt, square to him (no twist), raised over the head with the blade hanging down his back, the front foot
;; lifted and held, then one great overhead cut straight down onto him (the tip ends on the floor 2.9 m out); the arms solved by FK
;; (grip, blade and edge targets, the blade's flat kept out of the body: DUEL_KEN_V3 §17, the user 2026-11-03: 「應該是要雙手握刀、正對對手
;; 向下劈斬」)
(defstrike :ke-s-p2c (16 5 24 :base :ke-s-shoulder)
  (0 :ke-s-st-2)
  (7 :ke-s-shoulder (:root :u 0.04 :f -0.06) (:pelvis :twist 0) (:chest :twist 0) (:spine :flex -10) (:head :flex -10)
     (:arm-r :flex 80 :side 11 :twist 0) (:elbow-r :flex 148) (:hand-r :flex -84 :twist -7 :side 1) (:arm-l :flex 120 :side 94 :twist 0) (:elbow-l :flex 34))
  (12 (:root :u 0.08 :f -0.1) (:spine :flex -16) (:head :flex -12) (:thigh-l :flex 58 :side 6) (:knee-l :flex 80)
      (:arm-r :flex 83 :side 10 :twist 0) (:elbow-r :flex 142) (:hand-r :flex -47 :twist 1 :side 4) (:arm-l :flex 120 :side 74 :twist -5) (:elbow-l :flex 31))
  (14 (:root :u 0.075) (:spine :flex -15) (:hand-r :flex -44))                                                    ; held, trembling
  (15 :snap (:root :u 0.02 :f 0.02) (:spine :flex -4) (:head :flex -12) (:thigh-l :flex 52 :side 6) (:knee-l :flex 60)
      (:arm-r :flex 96 :side 16 :twist 1) (:elbow-r :flex 109) (:hand-r :flex -127 :twist -10 :side 6) (:arm-l :flex 130 :side 91 :twist 2) (:elbow-l :flex 48))   ; (overhead)
  (:s :snap (:root :u -0.08 :f 0.06) (:spine :flex 16) (:head :flex -14)
      (:thigh-l :flex 44 :side 6) (:knee-l :flex 40) (:thigh-r :flex -26 :side 8) (:knee-r :flex 12)
      (:arm-r :flex 35 :side 3 :twist 10) (:elbow-r :flex 133) (:hand-r :flex -171 :twist -7 :side 7) (:arm-l :flex 153 :side 91 :twist 1) (:elbow-l :flex 68))
  (:a (:root :u -0.18 :f 0.08) (:spine :flex 30) (:head :flex -20) (:thigh-l :flex 54 :side 6) (:knee-l :flex 58) (:thigh-r :flex -28 :side 8) (:knee-r :flex 26)
      (:arm-r :flex 15 :side -2 :twist 8) (:elbow-r :flex 111) (:hand-r :flex -121 :twist -5 :side 1) (:arm-l :flex 150 :side 100 :twist 11) (:elbow-l :flex 71))
  (32 (:root :u -0.17 :f 0.08) (:spine :flex 28))                                                                 ; buried, held
  (39 (:root :u -0.06 :f 0.04) (:spine :flex 8) (:head :flex -4) (:thigh-l :flex 20) (:knee-l :flex 20) (:thigh-r :flex -8) (:knee-r :flex 10)
      (:arm-r :flex 50 :side 5 :twist 4) (:elbow-r :flex 125) (:hand-r :flex -90 :twist -4 :side 0) (:arm-l :flex 120 :side 85 :twist 4) (:elbow-l :flex 50))
  (:end :ke-s-st-2))
;; NS2d: off the shoulder to his right, both hands low by the right hip, coiled, then one wide flat mow right to left (the right arm
;; turned in 16 and bent 7-12 from the hit through the carry so the haft stays in the left arm's reach: the fist was up to 0.185 m
;; off it, §21)
(defstrike :ke-s-p2d (14 4 20 :base :ke-s-shoulder)
  (0 :ke-s-st-2)
  (3 :ke-s-shoulder (:root :u -0.09 :f -0.02 :yaw -8) (:pelvis :twist 21) (:spine :flex 6) (:chest :twist -37) (:head :flex -3 :twist 14) (:knee-r :flex 31) (:knee-l :flex 34)
     (:arm-r :flex 21 :side 4 :twist -19) (:elbow-r :flex 115) (:hand-r :flex -36 :twist -56 :side 7) (:arm-l :flex 46 :side -55 :twist 20) (:elbow-l :flex 9))
  (6 (:root :u -0.12 :f -0.05 :yaw -16) (:pelvis :twist 25) (:chest :twist -52) (:spine :flex 8) (:head :flex -2 :twist 35) (:knees :flex 40)
     (:arm-r :flex -3 :side 24 :twist -16) (:elbow-r :flex 82) (:hand-r :flex -173 :twist -61 :side 8) (:arm-l :flex 25 :side -53 :twist 9) (:elbow-l :flex 20))
  (10 (:root :u -0.15 :f -0.08 :yaw -20) (:chest :twist -56) (:pelvis :twist 28) (:knees :flex 44)
      (:arm-r :flex -8 :side 21 :twist -15) (:elbow-r :flex 86) (:hand-r :flex -162 :twist -59 :side 6) (:arm-l :flex 19 :side -50 :twist 10) (:elbow-l :flex 23))
  (12 (:chest :twist -58) (:thigh-l :flex 62 :side 8) (:knee-l :flex 85))                                         ; coiled, held
  (13 :snap (:root :f 0.0 :u -0.16 :yaw -15) (:pelvis :twist 5) (:chest :twist -30) (:spine :flex 10) (:head :flex 0 :twist 10)
      (:thigh-l :flex 58 :side 8) (:knee-l :flex 70) (:thigh-r :flex -20 :side 12) (:knee-r :flex 30)
      (:arm-r :flex -10 :side -20 :twist 30) (:elbow-r :flex 110) (:hand-r :flex -60 :twist -60 :side 0))         ; (out flat to his right)
  (:s :snap (:root :f 0.12 :u -0.16 :yaw -10) (:pelvis :twist -15) (:chest :twist 0) (:spine :flex 12) (:head :flex 0 :twist -10)
      (:thigh-l :flex 52 :side 8) (:knee-l :flex 50) (:thigh-r :flex -28 :side 12) (:knee-r :flex 22)
      (:arm-r :flex 15 :side -36 :twist -65) (:elbow-r :flex 92) (:hand-r :flex -180 :twist 60 :side 0) (:arm-l :flex -9 :side -58 :twist 35) (:elbow-l :flex 22))
  (:a (:root :f 0.18 :u -0.18 :yaw 0) (:pelvis :twist -18) (:chest :twist 57) (:spine :flex 14) (:head :twist -30)
      (:thigh-l :flex 55) (:knee-l :flex 54) (:thigh-r :flex -30) (:knee-r :flex 24)
      (:arm-r :flex 5 :side -37 :twist -78) (:elbow-r :flex 72) (:arm-l :flex -4 :side -61 :twist 42) (:elbow-l :flex 19))
  (28 (:root :f 0.16 :u -0.16) (:chest :twist 66) (:spine :flex 13))                                              ; carried round
  (33 (:root :u -0.06 :f 0.04) (:pelvis :twist 0) (:chest :twist 4) (:spine :flex 8) (:head :flex -2 :twist 0)
      (:thigh-l :flex 20) (:knee-l :flex 20) (:thigh-r :flex -8) (:knee-r :flex 10)
      (:arm-r :flex 36 :side 0 :twist -3) (:elbow-r :flex 126) (:hand-r :flex -48 :twist -2 :side 0) (:arm-l :flex 34 :side -68 :twist -16) (:elbow-l :flex 14))
  (:end :ke-s-st-2))
;; NS2e: he turns his back into it (yaw -100, the blade cocked high over the right shoulder, held), then unwinds round into one
;; descending cut, straight ahead at the hit and dragged low to his left (the body carried 80 deg, never round)
(defstrike :ke-s-p2e (18 5 28 :base :ke-s-shoulder)
  (0 :ke-s-st-2)
  (6 :ke-s-shoulder (:root :yaw -50 :u -0.04) (:pelvis :twist 20) (:chest :twist -30) (:spine :flex -4) (:head :twist 40) (:knees :flex 24)
     (:arm-r :flex 102 :side 6 :twist -4) (:elbow-r :flex 101) (:hand-r :flex -112 :twist -23 :side 3) (:arm-l :flex -3 :side -100 :twist 8) (:elbow-l :flex 88))
  (13 (:root :yaw -100 :u -0.08 :f -0.05) (:pelvis :twist 25) (:chest :twist -42) (:spine :flex -8) (:head :twist 70 :flex -6) (:knees :flex 34)
      (:arm-r :flex 131 :side 4 :twist -3) (:elbow-r :flex 55) (:hand-r :flex -134 :twist -16 :side 2) (:arm-l :flex -25 :side -111 :twist 22) (:elbow-l :flex 81))
  (16 (:root :yaw -104 :u -0.09) (:chest :twist -45) (:hand-r :flex -137))                                       ; his back to him, held
  (17 :snap (:root :yaw -45 :u -0.12 :f 0.1) (:pelvis :twist 0) (:chest :twist -10) (:spine :flex 10) (:head :twist 20)
      (:arm-r :flex 77 :side -26 :twist -2) (:elbow-r :flex 128) (:hand-r :flex -148 :twist -42 :side 5) (:arm-l :flex 0 :side -59 :twist 50) (:elbow-l :flex 109))
  (:s :snap (:root :f 0.2 :u -0.2 :yaw -40) (:pelvis :twist -10) (:chest :twist 10) (:spine :flex 22) (:head :twist -15 :flex 0)
      (:thigh-l :flex 56 :side 0) (:knee-l :flex 62) (:thigh-r :flex -22 :side 0) (:knee-r :flex 44)
      (:arm-r :flex 120 :side 0 :twist 30) (:elbow-r :flex 85) (:hand-r :flex -180 :twist 60 :side 0) (:arm-l :flex -13 :side -106 :twist 46) (:elbow-l :flex 41))
  (:a (:root :f 0.25 :u -0.26 :yaw 40) (:pelvis :twist -24) (:chest :twist 50) (:spine :flex 30)
      (:thigh-l :flex 60) (:knee-l :flex 70) (:thigh-r :flex -22) (:knee-r :flex 48)
      (:arm-r :flex 20 :side -20 :twist -60) (:elbow-r :flex 35) (:hand-r :flex -120 :twist 60) (:arm-l :flex -8 :side -40 :twist 40) (:elbow-l :flex 22))
  (36 (:root :f 0.22 :u -0.24 :yaw 40) (:spine :flex 28))                                                         ; dragged low, held
  (44 (:root :u -0.06 :f 0.04 :yaw 10) (:pelvis :twist 0) (:chest :twist 4) (:spine :flex 8) (:head :twist 0)
      (:thigh-l :flex 20 :side 6) (:knee-l :flex 20) (:thigh-r :flex -8 :side 8) (:knee-r :flex 10)
      (:arm-r :flex 36 :side 0 :twist -3) (:elbow-r :flex 126) (:hand-r :flex -48 :twist -2 :side 0) (:arm-l :flex 34 :side -68 :twist -16) (:elbow-l :flex 14))
  (:end :ke-s-st-2))
;; the burst to pointer 1, ZANGAESHI (one hand): the shoulder heaves the blade up off it, cocked high over the right shoulder, then one
;; huge diagonal down to his left that drags him round, the blade carried low behind and swung up his back into the stance (:ke-s-st-1)
(defstrike :ke-s-zangaeshi (14 5 26 :base :ke-s-shoulder)
  (0 :ke-s-st-2)
  (5 :ke-s-shoulder (:root :u 0.03 :yaw -20) (:pelvis :twist 14) (:chest :twist -24) (:spine :flex -8) (:head :flex -6 :twist 15)
     (:arm-r :flex 64 :side -10 :twist 0) (:elbow-r :flex 121) (:hand-r :flex -65 :twist -4 :side 0) (:arm-l :flex 50 :side 30) (:elbow-l :flex 30))
  (10 (:root :u 0.0 :f -0.06 :yaw -38) (:pelvis :twist 22) (:chest :twist -36) (:spine :flex -12) (:head :twist 25)
      (:arm-r :flex 101 :side -5 :twist 0) (:elbow-r :flex 89) (:hand-r :flex -99 :twist -9 :side 0) (:arm-l :flex 80 :side 24) (:elbow-l :flex 12))
  (12 (:root :yaw -40) (:chest :twist -38) (:spine :flex -13))                                                    ; cocked, held
  (:s :snap (:root :f 0.25 :u -0.18 :yaw -35) (:pelvis :twist -14) (:chest :twist 32) (:spine :flex 24) (:head :twist -10 :flex -6)
      (:thigh-l :flex 52 :side 8) (:knee-l :flex 50) (:thigh-r :flex -30 :side 12) (:knee-r :flex 20)
      (:arm-r :flex 120 :side 20 :twist 30) (:elbow-r :flex 85) (:hand-r :flex -180 :twist 60 :side 0) (:arm-l :flex -30 :side 50) (:elbow-l :flex 20))
  (16 :snap (:root :f 0.28 :u -0.2 :yaw -18) (:pelvis :twist -19) (:chest :twist 40) (:spine :flex 26)
      (:arm-r :flex 50 :side 40 :twist -30) (:elbow-r :flex 110))                                                 ; (kept low through him)
  (:a (:root :f 0.3 :u -0.22 :yaw 0) (:pelvis :twist -24) (:chest :twist 48) (:spine :flex 28)
      (:arm-r :flex 20 :side -40 :twist -60) (:elbow-r :flex 85) (:hand-r :flex -180 :twist 30))
  (30 (:root :f 0.3 :u -0.2 :yaw 10) (:pelvis :twist -28) (:chest :twist 55) (:spine :flex 26)
      (:arm-r :flex 11 :side -44 :twist 0) (:elbow-r :flex 6) (:hand-r :flex -127 :twist 5 :side -1))             ; dragged round, low behind
  (38 (:root :u -0.24 :f 0.08 :yaw 0) (:pelvis :twist 8) (:spine :flex 32 :twist -26) (:chest :twist -30) (:head :flex -29 :twist 42)
      (:thigh-l :flex 50 :side 10) (:knee-l :flex 74) (:thigh-r :flex 7 :side 45 :twist -45) (:knee-r :flex 65) (:foot-r :flex -34 :twist 26 :side -29)
      (:arm-r :flex 22 :side 34 :twist -52) (:elbow-r :flex 98) (:hand-r :flex 26 :twist -10 :side -6) (:weapon-r :side 25) (:arm-l :flex -16 :side 50 :twist -5) (:elbow-l :flex 56))   ; into the stance (§18)
  (:end :ke-s-st-1))
;; the special AS INSEKI-GIRI: both hands, a crouch, the leap with the hilt raised (the blade down his back), arched at the top,
;; then down like a falling meteor, the tip into the floor 3 m out
(defstrike :ke-s-meteor (20 4 30 :base :ke-s-shoulder)
  (0 :ke-s-st-2)
  (6 :ke-s-shoulder (:root :u -0.3) (:knees :flex 80) (:thighs :flex 60) (:spine :flex 28) (:head :flex -14)
     (:arm-r :flex 51 :side 22 :twist 0) (:elbow-r :flex 142) (:hand-r :flex 3 :twist 11 :side 0) (:arm-l :flex 46 :side -116 :twist 0) (:elbow-l :flex -4))
  (9 (:root :u 0.15) (:thighs :flex 40) (:knees :flex 50) (:spine :flex 4) (:head :flex -18)
     (:arm-r :flex 66 :side 20 :twist 0) (:elbow-r :flex 125) (:hand-r :flex -4 :twist 9 :side 0) (:arm-l :flex 48 :side -119 :twist 0) (:elbow-l :flex 0))
  (13 (:root :u 0.7) (:thighs :flex 55) (:knees :flex 85) (:spine :flex -26) (:head :flex -26) (:chest :twist -10)
      (:arm-r :flex 87 :side 37 :twist 1) (:elbow-r :flex 78) (:hand-r :flex 25 :twist 0 :side 0) (:arm-l :flex 119 :side 39 :twist 0) (:elbow-l :flex 0))
  (17 (:root :u 0.85) (:spine :flex -34) (:head :flex -30) (:arm-r :flex 87 :side 45) (:elbow-r :flex 79) (:hand-r :flex 27 :twist 3)
      (:arm-l :flex 117 :side 35))                                                                                ; arched at the top, held
  (19 :snap (:root :u 0.1 :f 0.3) (:spine :flex 20) (:head :flex -30) (:thighs :flex 66) (:knees :flex 91) (:chest :twist 0)
      (:arm-r :flex 138 :side 19 :twist -1) (:elbow-r :flex 98) (:hand-r :flex -180 :twist -22 :side 4) (:arm-l :flex -18 :side -107 :twist -30) (:elbow-l :flex 0))
  (:s :snap (:root :u -0.24 :f 0.12) (:spine :flex 26) (:knees :flex 80) (:thighs :flex 64) (:head :flex -24)
      (:arm-r :flex 110 :side -10 :twist 20) (:elbow-r :flex 65) (:hand-r :flex -180 :twist 20 :side 0) (:arm-l :flex 5 :side -126 :twist -30) (:elbow-l :flex 0))
  (:a (:root :u -0.3 :f 0.15) (:spine :flex 32) (:knees :flex 85) (:thighs :flex 68) (:head :flex -26)
      (:arm-r :flex 90 :side 10 :twist 0) (:elbow-r :flex 95) (:hand-r :flex -180 :twist 20) (:arm-l :flex -9 :side -116 :twist -26) (:elbow-l :flex 26))
  (38 (:root :u -0.28 :f 0.14) (:spine :flex 30))                                                                 ; landed, held
  (46 (:root :u -0.06 :f 0.04) (:spine :flex 8) (:head :flex -2) (:thighs :flex 10) (:knees :flex 14)
      (:arm-r :flex 36 :side 0 :twist -3) (:elbow-r :flex 126) (:hand-r :flex -48 :twist -2 :side 0) (:arm-l :flex 34 :side -68 :twist -16) (:elbow-l :flex 14))
  (:end :ke-s-st-2))
(dolist (c '(:ke-s-p2c :ke-s-p2d :ke-s-p2e :ke-s-meteor)) (pushnew c *grip-clips*))   ; (two hands: GRIP-LEFT!)
;; the V3 Shikai's pointer-1 clips (DUEL_KEN_V3 §15): 「突進迴旋」 from the sling (:ke-s-st-1), each at its move's S / A / R (:clip-s = the
;; startup). The rhythm 由緩至急: an eased charge, a held coil that trembles (keys a frame apart), the release in the last 2-3 f, the
;; impact on S, a slow drag back. No full root turn inside a clip: a spin is the root and chest turned up to ~130 deg with the cleaver
;; carried round him by the arm (a key every frame through the fast part), a whirl the right arm's twist overhead. The arm keys were
;; solved by FK on the host for the tip on the hit volume (the blade reaches 2.7 m past the fist at his scale, so every hit slants it
;; 30-45 deg off level: a level blade would pass the volume's far edge).
;; NS1a TOSSHIN the lunge cut (S16 A4 R22; the sim slides him 3.0 m through the startup): the crouch sinks and holds (the tell), then
;; driving low, the cleaver drops off his back, drags low behind his right hip, swings through low and rips up in a rising diagonal,
;; right hip to over his left shoulder (the tip ends near the sling)
(defstrike :ke-s-p1a (16 4 22 :base :ke-s-sling)
  (0 :ke-s-st-1)
  (4 :ke-s-sling (:root :u -0.27 :f 0.06) (:spine :flex 29) (:head :flex -20) (:chest :twist -13) (:pelvis :twist 14)
     (:thigh-l :flex 54) (:knee-l :flex 74) (:knee-r :flex 50) (:arm-l :flex 46 :side 42) (:elbow-l :flex 32))
  (8 (:root :u -0.32 :f 0.08) (:spine :flex 33) (:chest :twist -16) (:pelvis :twist 16) (:thigh-l :flex 60) (:knee-l :flex 82)
     (:knee-r :flex 58) (:arm-l :flex 58 :side 30))                                                              ; sunk: the tell
  (9 :snap (:root :u -0.31) (:spine :flex 32))
  (10 :snap (:root :u -0.33) (:spine :flex 34))
  (11 :snap (:root :u -0.32) (:spine :flex 33))                                                                ; held, trembling
  (12 :snap (:root :u -0.31 :f 0.09 :yaw 0) (:pelvis :twist 20.5) (:spine :flex 33.5 :side 0) (:chest :twist -20.5) (:head :flex -20 :twist 1) (:thigh-l :flex 61 :side 12) (:knee-l :flex 76) (:thigh-r :flex -20 :side 16) (:knee-r :flex 49) (:arm-l :flex 59 :side 25) (:elbow-l :flex 31)
     (:arm-r :flex 6 :side 53 :twist 75) (:elbow-r :flex 72) (:hand-r :flex 94 :twist 50 :side 13))
  (13 :snap (:root :u -0.3 :f 0.1 :yaw 0) (:pelvis :twist 25) (:spine :flex 34 :side 0) (:chest :twist -25) (:head :flex -20 :twist 10) (:thigh-l :flex 62 :side 10) (:knee-l :flex 70) (:thigh-r :flex -28 :side 14) (:knee-r :flex 40) (:arm-l :flex 60 :side 20) (:elbow-l :flex 30)
     (:arm-r :flex 0 :side 33 :twist 82) (:elbow-r :flex 24) (:hand-r :flex 41 :twist 104 :side 36))
  (14 :snap (:root :u -0.29 :f 0.15 :yaw 0) (:pelvis :twist 16.5) (:spine :flex 32 :side 0) (:chest :twist -12.5) (:head :flex -18 :twist 5) (:thigh-l :flex 62 :side 10) (:knee-l :flex 68) (:thigh-r :flex -30 :side 14) (:knee-r :flex 35) (:arm-l :flex 52.5 :side 27.5) (:elbow-l :flex 27.5)
     (:arm-r :flex -16 :side -21 :twist -20) (:elbow-r :flex 2) (:hand-r :flex -20 :twist -54 :side 32))
  (15 :snap (:root :u -0.27 :f 0.2 :yaw 0) (:pelvis :twist 8) (:spine :flex 30 :side 0) (:chest :twist 0) (:head :flex -16 :twist 0) (:thigh-l :flex 62 :side 10) (:knee-l :flex 66) (:thigh-r :flex -32 :side 14) (:knee-r :flex 30) (:arm-l :flex 45 :side 35) (:elbow-l :flex 25)
     (:arm-r :flex -6 :side -9 :twist -7) (:elbow-r :flex 12) (:hand-r :flex 1 :twist -34 :side 29))
  (16 :snap (:root :u -0.24 :f 0.28 :yaw 0) (:pelvis :twist -10) (:spine :flex 26 :side 0) (:chest :twist 25) (:head :flex -14 :twist -10) (:thigh-l :flex 60 :side 10) (:knee-l :flex 62) (:thigh-r :flex -34 :side 14) (:knee-r :flex 22) (:arm-l :flex 30 :side 50) (:elbow-l :flex 20)
     (:arm-r :flex -17 :side 0 :twist 33) (:elbow-r :flex 23) (:hand-r :flex 42 :twist -17 :side 20))
  (17 :snap (:root :u -0.22 :f 0.29 :yaw 0) (:pelvis :twist -12) (:spine :flex 23 :side 0) (:chest :twist 28.25) (:head :flex -15 :twist -11) (:thigh-l :flex 59.5 :side 10) (:knee-l :flex 61) (:thigh-r :flex -34 :side 14) (:knee-r :flex 21.5) (:arm-l :flex 25 :side 52.5) (:elbow-l :flex 18.75)
     (:arm-r :flex -14 :side 13 :twist 54) (:elbow-r :flex 73) (:hand-r :flex 0 :twist -6 :side 25))
  (18 (:root :u -0.2 :f 0.3 :yaw 0) (:pelvis :twist -14) (:spine :flex 20 :side 0) (:chest :twist 31.5) (:head :flex -16 :twist -12) (:thigh-l :flex 59 :side 10) (:knee-l :flex 60) (:thigh-r :flex -34 :side 14) (:knee-r :flex 21) (:arm-l :flex 20 :side 55) (:elbow-l :flex 17.5)
     (:arm-r :flex 5 :side -7 :twist 61) (:elbow-r :flex 67) (:hand-r :flex -16 :twist -3 :side 9))
  (20 (:root :u -0.16 :f 0.32 :yaw 0) (:pelvis :twist -18) (:spine :flex 14 :side 0) (:chest :twist 38) (:head :flex -18 :twist -14) (:thigh-l :flex 58 :side 10) (:knee-l :flex 58) (:thigh-r :flex -34 :side 14) (:knee-r :flex 20) (:arm-l :flex 10 :side 60) (:elbow-l :flex 15)
     (:arm-r :flex 11 :side -39 :twist 36) (:elbow-r :flex 69) (:hand-r :flex -50 :twist 12 :side -29))
  (30 (:root :u -0.18 :f 0.26) (:spine :flex 16) (:chest :twist 30))
  (:end :ke-s-st-1))
;; NS1b the spin-through sweep (S12 A4 R20, 360 deg): wound to his right, the cleaver out low behind; turning left, the blade slanted
;; down off the cocked wrist mows the floor through his right, his front, his left and on behind (a forehand, right to left, low)
(defstrike :ke-s-p1b (12 4 20 :base :ke-s-sling)
  (0 (:root :u -0.16 :f 0.32 :yaw 0)   ; NS1a's S+A pose (a link starts there, blend 0)
     (:pelvis :twist -18) (:spine :flex 14 :side 0) (:chest :twist 38) (:head :flex -18 :twist -14) (:thigh-l :flex 58 :side 10) (:knee-l :flex 58) (:thigh-r :flex -34 :side 14) (:knee-r :flex 20) (:arm-l :flex 10 :side 60) (:elbow-l :flex 15) (:arm-r :flex 11 :side -39 :twist 36) (:elbow-r :flex 69) (:hand-r :flex -50 :twist 12 :side -29))
  (6 (:root :u -0.22 :f 0 :yaw -45) (:pelvis :twist 20) (:spine :flex 24 :side 0) (:chest :twist -30) (:head :flex -14 :twist 40) (:thigh-l :flex 40 :side 14) (:knee-l :flex 55) (:thigh-r :flex -10 :side 18) (:knee-r :flex 45) (:arm-l :flex 50 :side 30) (:elbow-l :flex 30)
     (:arm-r :flex -18 :side -12 :twist 48) (:elbow-r :flex 73) (:hand-r :flex 97 :twist -34 :side -26))
  (8 :snap (:root :yaw -47 :u -0.23))
  (9 :snap (:root :yaw -46 :u -0.22))                                                                          ; held
  (10 :snap (:root :u -0.17 :f 0.1 :yaw -8.33) (:pelvis :twist 6.67) (:spine :flex 21.33 :side 5.33) (:chest :twist -3.33) (:head :flex -14 :twist 6.67) (:thigh-l :flex 46.67 :side 14) (:knee-l :flex 51.67) (:thigh-r :flex -20 :side 18) (:knee-r :flex 35) (:arm-l :flex 36.67 :side 56.67) (:elbow-l :flex 23.33)
     (:arm-r :flex -19 :side -23 :twist 19) (:elbow-r :flex 69) (:hand-r :flex 95 :twist -46 :side -27))
  (11 :snap (:root :u -0.16 :f 0.12 :yaw 0.83) (:pelvis :twist 3.33) (:spine :flex 20.67 :side 6.67) (:chest :twist 3.33) (:head :flex -14 :twist -1.67) (:thigh-l :flex 48.33 :side 14) (:knee-l :flex 50.83) (:thigh-r :flex -22.5 :side 18) (:knee-r :flex 32.5) (:arm-l :flex 33.33 :side 63.33) (:elbow-l :flex 21.67)
     (:arm-r :flex -11 :side -13 :twist 49) (:elbow-r :flex 65) (:hand-r :flex 91 :twist -47 :side -26))
  (12 :snap (:root :u -0.15 :f 0.15 :yaw 10) (:pelvis :twist 0) (:spine :flex 20 :side 8) (:chest :twist 10) (:head :flex -14 :twist -10) (:thigh-l :flex 50 :side 14) (:knee-l :flex 50) (:thigh-r :flex -25 :side 18) (:knee-r :flex 30) (:arm-l :flex 30 :side 70) (:elbow-l :flex 20)
     (:arm-r :flex -5 :side -12 :twist 74) (:elbow-r :flex 63) (:hand-r :flex 87 :twist -49 :side -30))
  (13 :snap (:root :u -0.15 :f 0.17 :yaw 27.5) (:pelvis :twist -3.75) (:spine :flex 19.5 :side 8.5) (:chest :twist 15) (:head :flex -13.5 :twist -22.5) (:thigh-l :flex 49.5 :side 14) (:knee-l :flex 49) (:thigh-r :flex -25.75 :side 18) (:knee-r :flex 29.5) (:arm-l :flex 28.75 :side 71.25) (:elbow-l :flex 20)
     (:arm-r :flex -7 :side -8 :twist 86) (:elbow-r :flex 70) (:hand-r :flex 74 :twist -59 :side -32))
  (14 :snap (:root :u -0.15 :f 0.18 :yaw 45) (:pelvis :twist -7.5) (:spine :flex 19 :side 9) (:chest :twist 20) (:head :flex -13 :twist -35) (:thigh-l :flex 49 :side 14) (:knee-l :flex 48) (:thigh-r :flex -26.5 :side 18) (:knee-r :flex 29) (:arm-l :flex 27.5 :side 72.5) (:elbow-l :flex 20)
     (:arm-r :flex -16 :side -16 :twist 89) (:elbow-r :flex 68) (:hand-r :flex 40 :twist -71 :side -33))
  (15 :snap (:root :u -0.14 :f 0.2 :yaw 62.5) (:pelvis :twist -11.25) (:spine :flex 18.5 :side 9.5) (:chest :twist 25) (:head :flex -12.5 :twist -47.5) (:thigh-l :flex 48.5 :side 14) (:knee-l :flex 47) (:thigh-r :flex -27.25 :side 18) (:knee-r :flex 28.5) (:arm-l :flex 26.25 :side 73.75) (:elbow-l :flex 20)
     (:arm-r :flex -22 :side -15 :twist 89) (:elbow-r :flex 64) (:hand-r :flex 5 :twist -73 :side -37))
  (16 :snap (:root :u -0.14 :f 0.22 :yaw 80) (:pelvis :twist -15) (:spine :flex 18 :side 10) (:chest :twist 30) (:head :flex -12 :twist -60) (:thigh-l :flex 48 :side 14) (:knee-l :flex 46) (:thigh-r :flex -28 :side 18) (:knee-r :flex 28) (:arm-l :flex 25 :side 75) (:elbow-l :flex 20)
     (:arm-r :flex -20 :side 7 :twist 87) (:elbow-r :flex 72) (:hand-r :flex -39 :twist -56 :side -32))
  (24 (:root :yaw 70 :u -0.16) (:spine :flex 20))
  (:end :ke-s-st-1))
;; NS1c the reverse spin (S12 A4 R20, 360 deg): the other way and the other height: coiled left and low, the fist at his left knee, the
;; blade trailing low; a backhand that rises as he turns right, up onto his toes, the tip climbing from the floor to over his head
(defstrike :ke-s-p1c (12 4 20 :base :ke-s-sling)
  (0 (:root :u -0.14 :f 0.22 :yaw 80)   ; NS1b's S+A pose (a link starts there, blend 0)
     (:pelvis :twist -15) (:spine :flex 18 :side 10) (:chest :twist 30) (:head :flex -12 :twist -60) (:thigh-l :flex 48 :side 14) (:knee-l :flex 46) (:thigh-r :flex -28 :side 18) (:knee-r :flex 28) (:arm-l :flex 25 :side 75) (:elbow-l :flex 20) (:arm-r :flex -20 :side 7 :twist 87) (:elbow-r :flex 72) (:hand-r :flex -39 :twist -56 :side -32))
  (6 (:root :u -0.32 :f 0.0 :yaw 45) (:pelvis :twist -10) (:spine :flex 30 :side 0) (:chest :twist 30) (:head :flex -12 :twist -40)
     (:thigh-l :flex 55 :side 14) (:knee-l :flex 70) (:thigh-r :flex -15 :side 18) (:knee-r :flex 55) (:arm-l :flex 20 :side 40) (:elbow-l :flex 40)
     (:arm-r :flex -3 :side -1 :twist 35) (:elbow-r :flex 45) (:hand-r :flex -61 :twist 43 :side 9))           ; coiled low, left
  (8 :snap (:root :yaw 47 :u -0.33))
  (9 :snap (:root :yaw 46 :u -0.32))                                                                           ; held
  (10.5 :snap (:root :u -0.25 :f 0.08 :yaw 20) (:pelvis :twist -5) (:spine :flex 24 :side -4) (:chest :twist 15) (:head :twist -20)
        (:thigh-l :flex 50) (:knee-l :flex 55) (:thigh-r :flex -20) (:knee-r :flex 40) (:arm-l :flex 18 :side 55) (:elbow-l :flex 30)
        (:arm-r :flex -8 :side -42 :twist -28) (:elbow-r :flex 7) (:hand-r :flex -54 :twist 33 :side -33))       ; low at his left
  (:s :snap (:root :u -0.12 :f 0.15 :yaw 0) (:pelvis :twist 0) (:spine :flex 16 :side -10) (:chest :twist 0) (:head :twist 0)
      (:thigh-l :flex 45) (:knee-l :flex 45) (:thigh-r :flex -25) (:knee-r :flex 25) (:arm-l :flex 15 :side 65) (:elbow-l :flex 20)
      (:arm-r :flex 0 :side -40 :twist -30) (:elbow-r :flex 71) (:hand-r :flex -42 :twist 53 :side -23))         ; rising through
  (14 :snap (:root :u 0.0 :f 0.2 :yaw -40) (:pelvis :twist 10) (:spine :flex 10 :side -12) (:chest :twist -20) (:head :flex -16 :twist 30)
      (:thigh-l :flex 35) (:knee-l :flex 30) (:knee-r :flex 15) (:arm-l :side 70)
      (:arm-r :flex 17 :side -42 :twist -59) (:elbow-r :flex 72) (:hand-r :flex -27 :twist 46 :side -31))        ; his right, high
  (:a (:root :u 0.06 :f 0.22 :yaw -75) (:pelvis :twist 15) (:spine :flex 6 :side -14) (:chest :twist -30) (:head :flex -18 :twist 50)
      (:thigh-l :flex 30) (:knee-l :flex 25) (:thigh-r :flex -22) (:knee-r :flex 12) (:arm-l :side 75)
      (:arm-r :flex 41 :side -25 :twist -72) (:elbow-r :flex 66) (:hand-r :flex -23 :twist 45 :side -34))        ; on his toes, flung up
  (24 (:root :yaw -65 :u 0.02) (:spine :flex 10))
  (:end :ke-s-st-1))
;; NS1d the one-hand sword dance (S10 A8 R16; hits f10-12, f16-18): the fist cocked out right, the blade up behind; a figure eight,
;; two steep cuts that each end at the floor: up over his right and down to his left (f10), back and up his left side, over and down
;; to his right (f16)
(defstrike :ke-s-p1d (10 8 16 :base :ke-s-sling)
  (0 (:root :u 0.06 :f 0.22 :yaw -75)   ; NS1c's S+A pose (a link starts there, blend 0)
     (:pelvis :twist 15) (:spine :flex 6 :side -14) (:chest :twist -30) (:head :flex -18 :twist 50) (:thigh-l :flex 30 :side 14) (:knee-l :flex 25) (:thigh-r :flex -22 :side 18) (:knee-r :flex 12) (:arm-l :flex 15 :side 75) (:elbow-l :flex 20) (:arm-r :flex 41 :side -25 :twist -72) (:elbow-r :flex 66) (:hand-r :flex -23 :twist 45 :side -34))
  (4 (:root :u -0.12 :f 0.05 :yaw -10) (:pelvis :twist 15) (:spine :flex 14 :side 0) (:chest :twist -25) (:head :flex -10 :twist 15) (:thigh-l :flex 40 :side 14) (:knee-l :flex 50) (:thigh-r :flex -14 :side 18) (:knee-r :flex 32) (:arm-l :flex 40 :side 45) (:elbow-l :flex 50)
     (:arm-r :flex -16 :side 51 :twist -45) (:elbow-r :flex 68) (:hand-r :flex 92 :twist -61 :side -30))
  (6 :snap (:root :u -0.13) (:chest :twist -27))
  (7 :snap (:root :u -0.12) (:chest :twist -26))                                                              ; held
  (8 :snap (:root :u -0.15 :f 0.08 :yaw -5) (:pelvis :twist 8.33) (:spine :flex 18 :side 0) (:chest :twist -10.67) (:head :flex -11.33 :twist 6.67) (:thigh-l :flex 44 :side 14) (:knee-l :flex 52) (:thigh-r :flex -17.33 :side 18) (:knee-r :flex 31.33) (:arm-l :flex 36.67 :side 50) (:elbow-l :flex 43.33)
     (:arm-r :flex -16 :side 49 :twist -7) (:elbow-r :flex 1) (:hand-r :flex 91 :twist -60 :side -4))
  (9 :snap (:root :u -0.17 :f 0.12 :yaw 0) (:pelvis :twist 1.67) (:spine :flex 22 :side 0) (:chest :twist 4.67) (:head :flex -12.67 :twist -1.67) (:thigh-l :flex 48 :side 14) (:knee-l :flex 54) (:thigh-r :flex -20.67 :side 18) (:knee-r :flex 30.67) (:arm-l :flex 33.33 :side 55) (:elbow-l :flex 36.67)
     (:arm-r :flex -22 :side 34 :twist 8) (:elbow-r :flex -2) (:hand-r :flex 87 :twist -29 :side -5))
  (10 :snap (:root :u -0.2 :f 0.15 :yaw 5) (:pelvis :twist -5) (:spine :flex 26 :side 0) (:chest :twist 20) (:head :flex -14 :twist -10) (:thigh-l :flex 52 :side 14) (:knee-l :flex 56) (:thigh-r :flex -24 :side 18) (:knee-r :flex 30) (:arm-l :flex 30 :side 60) (:elbow-l :flex 30)
     (:arm-r :flex -23 :side 25 :twist 49) (:elbow-r :flex -4) (:hand-r :flex 50 :twist -20 :side -15))
  (11 :snap (:root :u -0.21 :f 0.16 :yaw 7.5) (:pelvis :twist -7.5) (:spine :flex 28 :side 2) (:chest :twist 24) (:head :flex -15 :twist -12.5) (:thigh-l :flex 53 :side 14) (:knee-l :flex 58) (:thigh-r :flex -25 :side 18) (:knee-r :flex 30) (:arm-l :flex 27.5 :side 62.5) (:elbow-l :flex 27.5)
     (:arm-r :flex -15 :side 15 :twist 65) (:elbow-r :flex 3) (:hand-r :flex 43 :twist -17 :side -32))
  (12 :snap (:root :u -0.22 :f 0.18 :yaw 10) (:pelvis :twist -10) (:spine :flex 30 :side 4) (:chest :twist 28) (:head :flex -16 :twist -15) (:thigh-l :flex 54 :side 14) (:knee-l :flex 60) (:thigh-r :flex -26 :side 18) (:knee-r :flex 30) (:arm-l :flex 25 :side 65) (:elbow-l :flex 25)
     (:arm-r :flex -9 :side 4 :twist 77) (:elbow-r :flex -3) (:hand-r :flex 43 :twist -26 :side -29))
  (13 :snap (:root :u -0.19 :f 0.18 :yaw 5) (:pelvis :twist -5) (:spine :flex 24 :side 2) (:chest :twist 19) (:head :flex -14 :twist -7.5) (:thigh-l :flex 52 :side 14) (:knee-l :flex 56) (:thigh-r :flex -25 :side 18) (:knee-r :flex 29) (:arm-l :flex 30 :side 60) (:elbow-l :flex 32.5)
     (:arm-r :flex 3 :side 16 :twist 82) (:elbow-r :flex 1) (:hand-r :flex 15 :twist 23 :side -11))
  (14 :snap (:root :u -0.16 :f 0.18 :yaw 0) (:pelvis :twist 0) (:spine :flex 18 :side 0) (:chest :twist 10) (:head :flex -12 :twist 0) (:thigh-l :flex 50 :side 14) (:knee-l :flex 52) (:thigh-r :flex -24 :side 18) (:knee-r :flex 28) (:arm-l :flex 35 :side 55) (:elbow-l :flex 40)
     (:arm-r :flex 175 :side 101 :twist 14) (:elbow-r :flex 73) (:hand-r :flex 14 :twist -96 :side -31))
  (15 :snap (:root :u -0.18 :f 0.2 :yaw -2.5) (:pelvis :twist 2.5) (:spine :flex 22 :side 0) (:chest :twist -2.5) (:head :flex -13 :twist 5) (:thigh-l :flex 52 :side 14) (:knee-l :flex 54) (:thigh-r :flex -25 :side 18) (:knee-r :flex 29) (:arm-l :flex 32.5 :side 57.5) (:elbow-l :flex 35)
     (:arm-r :flex 174 :side 105 :twist 29) (:elbow-r :flex 72) (:hand-r :flex -29 :twist -102 :side 10))
  (16 :snap (:root :u -0.2 :f 0.22 :yaw -5) (:pelvis :twist 5) (:spine :flex 26 :side 0) (:chest :twist -15) (:head :flex -14 :twist 10) (:thigh-l :flex 54 :side 14) (:knee-l :flex 56) (:thigh-r :flex -26 :side 18) (:knee-r :flex 30) (:arm-l :flex 30 :side 60) (:elbow-l :flex 30)
     (:arm-r :flex -27 :side -31 :twist 53) (:elbow-r :flex 4) (:hand-r :flex 64 :twist -19 :side -30))
  (17 :snap (:root :u -0.21 :f 0.23 :yaw -8.5) (:pelvis :twist 8.5) (:spine :flex 28 :side -2) (:chest :twist -20) (:head :flex -15 :twist 14) (:thigh-l :flex 55 :side 14) (:knee-l :flex 58) (:thigh-r :flex -27 :side 18) (:knee-r :flex 30) (:arm-l :flex 27.5 :side 62.5) (:elbow-l :flex 27.5)
     (:arm-r :flex -22 :side -36 :twist 38) (:elbow-r :flex -1) (:hand-r :flex 65 :twist -20 :side -27))
  (18 :snap (:root :u -0.22 :f 0.24 :yaw -12) (:pelvis :twist 12) (:spine :flex 30 :side -4) (:chest :twist -25) (:head :flex -16 :twist 18) (:thigh-l :flex 56 :side 14) (:knee-l :flex 60) (:thigh-r :flex -28 :side 18) (:knee-r :flex 30) (:arm-l :flex 25 :side 65) (:elbow-l :flex 25)
     (:arm-r :flex -20 :side -38 :twist 29) (:elbow-r :flex -1) (:hand-r :flex 65 :twist -21 :side -25))
  (22 (:root :u -0.21 :f 0.22) (:spine :flex 28))
  (:end :ke-s-st-1))
;; NS1e the spinning leap cut (S14 A4 R24; the sim carries him 2.0 m): a deep crouch (held), he springs and the cleaver goes up and
;; whirls once flat round over his head at the top of the leap (the arm's twist; behind, left, front, right, behind), then over the
;; top and down on him as he lands in a deep crouch (crumple)
(defstrike :ke-s-p1e (14 4 24 :base :ke-s-sling)
  (0 (:root :u -0.22 :f 0.24 :yaw -12)   ; NS1d's S+A pose (a link starts there, blend 0)
     (:pelvis :twist 12) (:spine :flex 30 :side -4) (:chest :twist -25) (:head :flex -16 :twist 18) (:thigh-l :flex 56 :side 14) (:knee-l :flex 60) (:thigh-r :flex -28 :side 18) (:knee-r :flex 30) (:arm-l :flex 25 :side 65) (:elbow-l :flex 25) (:arm-r :flex -20 :side -38 :twist 29) (:elbow-r :flex -1) (:hand-r :flex 65 :twist -21 :side -25))
  (3 (:root :u -0.38 :f 0.0 :yaw 10) (:pelvis :twist 15) (:spine :flex 36) (:chest :twist -15) (:head :flex -24 :twist -5)
     (:thigh-l :flex 70) (:knee-l :flex 95) (:thigh-r :flex -5) (:knee-r :flex 80) (:arm-l :flex 40 :side 40) (:elbow-l :flex 30)
     (:arm-r :flex -20) (:elbow-r :flex 95))                                                                    ; crouched, still slung
  (4 :snap (:root :u -0.4) (:spine :flex 37))
  (5 :snap (:root :u -0.39) (:spine :flex 36))                                                                 ; held
  (7 (:root :u 0.3 :f 0.12 :yaw 20) (:pelvis :twist 10) (:spine :flex -12 :side 12) (:chest :twist 0) (:head :flex -16 :twist -15)
     (:thigh-l :flex 40) (:knee-l :flex 50) (:thigh-r :flex 10) (:knee-r :flex 40) (:arm-l :flex 70 :side 80) (:elbow-l :flex 20)
     (:arm-r :flex 160 :side -12 :twist -90) (:elbow-r :flex 52) (:hand-r :flex -25 :twist 0 :side 0))           ; sprung, up at his right
  (8.5 :snap (:root :u 0.55 :f 0.18 :yaw 5) (:spine :flex -15 :side 15) (:head :twist 0) (:thigh-l :flex 70) (:knee-l :flex 100)
       (:thigh-r :flex 50) (:knee-r :flex 100) (:arm-r :flex 165 :side -15 :twist 0) (:elbow-r :flex 50))       ; behind
  (10 :snap (:root :u 0.7 :f 0.22 :yaw -10) (:arm-r :twist 90))                                                ; left
  (11 :snap (:root :u 0.78 :yaw -20) (:arm-r :twist 180) (:thigh-l :flex 75) (:knee-l :flex 110) (:thigh-r :flex 60) (:knee-r :flex 110))   ; front
  (12 :snap (:root :u 0.8 :f 0.25 :yaw -30) (:pelvis :twist 15) (:head :flex -24 :twist 15) (:arm-r :twist 270))   ; right
  (12.5 :snap (:root :u 0.78) (:arm-r :twist 360))                                                             ; behind
  (12.501 (:arm-r :twist 0))                                                                                    ; (the same pose)
  (13 :snap (:root :u 0.3 :f 0.32 :yaw -10) (:pelvis :twist 5) (:spine :flex 10 :side 0) (:chest :twist 0) (:head :flex -26 :twist 5) (:thigh-l :flex 76 :side 14) (:knee-l :flex 95) (:thigh-r :flex 30 :side 18) (:knee-r :flex 95) (:arm-l :flex 20 :side 60) (:elbow-l :flex 20)
     (:arm-r :flex -17 :side 85 :twist 21) (:elbow-r :flex 71) (:hand-r :flex 58 :twist -83 :side 29))
  (14 :snap (:root :u -0.32 :f 0.4 :yaw 10) (:pelvis :twist -5) (:spine :flex 40 :side 0) (:chest :twist 10) (:head :flex -30 :twist -5) (:thigh-l :flex 75 :side 14) (:knee-l :flex 85) (:thigh-r :flex -10 :side 18) (:knee-r :flex 70) (:arm-l :flex -20 :side 50) (:elbow-l :flex 15)
     (:arm-r :flex -34 :side 61 :twist -5) (:elbow-r :flex -11) (:hand-r :flex 42 :twist -33 :side 32))
  (15 :snap (:root :u -0.33 :f 0.4 :yaw 10.5) (:pelvis :twist -5.25) (:spine :flex 41 :side 0) (:chest :twist 10.5) (:head :flex -30.5 :twist -5) (:thigh-l :flex 75.75 :side 14) (:knee-l :flex 86.25) (:thigh-r :flex -10 :side 18) (:knee-r :flex 71) (:arm-l :flex -21.25 :side 50) (:elbow-l :flex 15)
     (:arm-r :flex -33 :side 47 :twist -13) (:elbow-r :flex -7) (:hand-r :flex 44 :twist -29 :side 31))
  (18 (:root :u -0.36 :f 0.42 :yaw 12) (:pelvis :twist -6) (:spine :flex 44 :side 0) (:chest :twist 12) (:head :flex -32 :twist -5) (:thigh-l :flex 78 :side 14) (:knee-l :flex 90) (:thigh-r :flex -10 :side 18) (:knee-r :flex 74) (:arm-l :flex -25 :side 50) (:elbow-l :flex 15)
     (:arm-r :flex -34 :side 25 :twist -22) (:elbow-r :flex -7) (:hand-r :flex 53 :twist -27 :side 30))
  (30 (:root :u -0.32 :f 0.38) (:spine :flex 40))
  (:end :ke-s-st-1))
;; TOSSHIN-ISSEN, the burst to pointer 2 (S12 A5 R26; the sim carries him 3.5 m, through him): one short drop, the fist at his left knee
;; and the cleaver trailing low on his left (a draw), then one flat-slanted backhand flash left to right as he passes, turned away with
;; it; then the arm lifts the blade up from behind his right side onto the right shoulder: pointer 2's stance (:ke-s-st-2)
(defstrike :ke-s-issen (12 5 26 :base :ke-s-sling)
  (0 :ke-s-st-1)
  ;; f1-f3: the draw out of the stance solved for the most even turn of the blade (its edge turns 119 in 4 frames: up to 53 a frame,
  ;; 100 before as the channels ran straight; the blade itself up to 34, 80 before; §21)
  (1 :ke-s-sling (:root :u -0.27 :f 0.043 :yaw 5) (:pelvis :twist 10) (:spine :flex 33 :side 0 :twist -20) (:chest :twist -14) (:head :flex -27 :twist 20)
     (:thigh-l :flex 54 :side 10) (:knee-l :flex 77) (:thigh-r :flex -1 :side 38 :twist -34) (:knee-r :flex 64) (:foot-r :flex -26 :twist 20 :side -22) (:arm-l :flex 0 :side 42 :twist -4) (:elbow-l :flex 52) (:hand-l :flex -2)
     (:arm-r :flex 20 :side 69 :twist -21) (:elbow-r :flex 73) (:hand-r :flex 12 :twist 7 :side 7) (:weapon-r :side 19))
  (2 :ke-s-sling (:root :u -0.3 :f 0.045 :yaw 10) (:pelvis :twist 12) (:spine :flex 34 :side 0 :twist -13) (:chest :twist 2) (:head :flex -26 :twist -2)
     (:thigh-l :flex 58 :side 11) (:knee-l :flex 80) (:thigh-r :flex -9 :side 30 :twist -22) (:knee-r :flex 62) (:foot-r :flex -17 :twist 13 :side -14) (:arm-l :flex 17 :side 35 :twist -2) (:elbow-l :flex 48) (:hand-l :flex -5)
     (:arm-r :flex 16 :side 62 :twist 6) (:elbow-r :flex 50) (:hand-r :flex -1 :twist 24 :side 0) (:weapon-r :side 12))
  (3 :ke-s-sling (:root :u -0.33 :f 0.048 :yaw 15) (:pelvis :twist 13) (:spine :flex 35 :side 0 :twist -6) (:chest :twist 19) (:head :flex -24 :twist -23)
     (:thigh-l :flex 61 :side 12) (:knee-l :flex 82) (:thigh-r :flex -17 :side 23 :twist -11) (:knee-r :flex 61) (:foot-r :flex -8 :twist 6 :side -7) (:arm-l :flex 34 :side 28 :twist -1) (:elbow-l :flex 44) (:hand-l :flex -8)
     (:arm-r :flex 11 :side 36 :twist 50) (:elbow-r :flex 23) (:hand-r :flex -14 :twist 10 :side -2) (:weapon-r :side 6))
  (4 :ke-s-sling (:root :u -0.36 :f 0.05 :yaw 20) (:pelvis :twist 15) (:spine :flex 36 :side 0) (:chest :twist 35) (:head :flex -22 :twist -45)
     (:thigh-l :flex 65 :side 12) (:knee-l :flex 85) (:thigh-r :flex -25 :side 16) (:knee-r :flex 60) (:arm-l :flex 50 :side 20) (:elbow-l :flex 40)
     (:arm-r :flex 13 :side -17 :twist 63) (:elbow-r :flex -2) (:hand-r :flex -28 :twist -5 :side -27))         ; the draw, low
  (7 :snap (:root :u -0.37) (:chest :twist 37))
  (8 :snap (:root :u -0.36) (:chest :twist 36))                                                                ; held
  (10 :snap (:root :u -0.34 :f 0.15 :yaw 10) (:pelvis :twist 10) (:spine :flex 34 :side 0) (:chest :twist 25) (:head :flex -20 :twist -30) (:thigh-l :flex 66 :side 12) (:knee-l :flex 80) (:thigh-r :flex -30 :side 16) (:knee-r :flex 50) (:arm-l :flex 40 :side 35) (:elbow-l :flex 30)
     (:arm-r :flex -11 :side -40 :twist 35) (:elbow-r :flex 11) (:hand-r :flex 2 :twist -11 :side -24))
  (11 :snap (:root :u -0.32 :f 0.22 :yaw 0) (:pelvis :twist 5) (:spine :flex 32 :side -2) (:chest :twist 12.5) (:head :flex -19 :twist -15) (:thigh-l :flex 66 :side 12) (:knee-l :flex 78) (:thigh-r :flex -32 :side 16) (:knee-r :flex 45) (:arm-l :flex 32.5 :side 47.5) (:elbow-l :flex 25)
     (:arm-r :flex -20 :side -35 :twist 13) (:elbow-r :flex -2) (:hand-r :flex 22 :twist 14 :side -25))
  (12 :snap (:root :u -0.3 :f 0.3 :yaw -10) (:pelvis :twist 0) (:spine :flex 30 :side -4) (:chest :twist 0) (:head :flex -18 :twist 0) (:thigh-l :flex 66 :side 12) (:knee-l :flex 76) (:thigh-r :flex -34 :side 16) (:knee-r :flex 40) (:arm-l :flex 25 :side 60) (:elbow-l :flex 20)
     (:arm-r :flex -26 :side -30 :twist 15) (:elbow-r :flex -3) (:hand-r :flex 45 :twist -1 :side -13))
  (13 :snap (:root :u -0.29 :f 0.32 :yaw -27.5) (:pelvis :twist -5) (:spine :flex 29 :side -6) (:chest :twist -12.5) (:head :flex -17 :twist 20) (:thigh-l :flex 65 :side 12) (:knee-l :flex 74) (:thigh-r :flex -34 :side 16) (:knee-r :flex 38) (:arm-l :flex 22.5 :side 65) (:elbow-l :flex 20)
     (:arm-r :flex -25 :side -18 :twist 23) (:elbow-r :flex -2) (:hand-r :flex 42 :twist 3 :side -22))
  (14 :snap (:root :u -0.28 :f 0.35 :yaw -45) (:pelvis :twist -10) (:spine :flex 28 :side -8) (:chest :twist -25) (:head :flex -16 :twist 40) (:thigh-l :flex 64 :side 12) (:knee-l :flex 72) (:thigh-r :flex -34 :side 16) (:knee-r :flex 36) (:arm-l :flex 20 :side 70) (:elbow-l :flex 20)
     (:arm-r :flex -22 :side -7 :twist 30) (:elbow-r :flex -2) (:hand-r :flex 36 :twist 1 :side -17))
  (15 :snap (:root :u -0.27 :f 0.36 :yaw -62.5) (:pelvis :twist -12.5) (:spine :flex 27 :side -9) (:chest :twist -27.5) (:head :flex -16 :twist 50) (:thigh-l :flex 63 :side 12) (:knee-l :flex 71) (:thigh-r :flex -33 :side 16) (:knee-r :flex 35) (:arm-l :flex 20 :side 72.5) (:elbow-l :flex 20)
     (:arm-r :flex -24 :side 3 :twist 22) (:elbow-r :flex -2) (:hand-r :flex 39 :twist 8 :side -24))
  (16 (:root :u -0.26 :f 0.38 :yaw -80) (:pelvis :twist -15) (:spine :flex 26 :side -10) (:chest :twist -30) (:head :flex -16 :twist 60) (:thigh-l :flex 62 :side 12) (:knee-l :flex 70) (:thigh-r :flex -32 :side 16) (:knee-r :flex 34) (:arm-l :flex 20 :side 75) (:elbow-l :flex 20)
     (:arm-r :flex -22 :side 4 :twist -4) (:elbow-r :flex -2) (:hand-r :flex 35 :twist 2 :side -6))
  (:a (:root :yaw -84))
  (25 (:root :u -0.16 :f 0.3 :yaw -45) (:pelvis :twist -8) (:spine :flex 14 :side -6) (:chest :twist -15) (:head :flex -12 :twist 30)
      (:thigh-l :flex 50) (:knee-l :flex 56) (:thigh-r :flex -28) (:knee-r :flex 30) (:arm-l :flex 20 :side 50) (:elbow-l :flex 30)
      (:arm-r :flex 44 :side -27 :twist 4) (:elbow-r :flex 73) (:hand-r :flex -5 :twist -9 :side 26))            ; lifted up behind
  (34 :ke-s-st-2 (:root :f 0.12 :yaw -8) (:arm-r :flex 40) (:elbow-r :flex 104))                              ; onto the shoulder
  (:end :ke-s-st-2))
;; DAISHARIN the full wheel, pointer 1's special AS (S12 A14 R26; hits f12-14, f18-20, f24-26 launching; 360 deg): the cleaver lifted
;; off the back and whirled flat round him over his head (the right arm up, its twist carrying the blade: back f9, left, front at
;; f12 / 18 / 24, right; three turns, faster after the first), the body rising through it, the third turn climbing as he springs onto
;; his toes (the launch); slowed, then lowered into the sling. (At f31 the arm's twist drops 1080 deg between two keys 0.001 f apart:
;; the same pose, so the recovery doesn't unwind three turns.)
(defstrike :ke-s-wheel (12 14 26 :base :ke-s-sling)
  (0 :ke-s-st-1)
  (4 :ke-s-sling (:root :u -0.24) (:spine :flex 10 :side 6) (:chest :twist 0) (:head :flex -14 :twist 0) (:arm-l :flex 50 :side 70) (:elbow-l :flex 20)
     (:arm-r :flex 90 :side 10 :twist -120) (:elbow-r :flex 70) (:hand-r :flex 0 :twist 0 :side 0)
     (:thigh-l :flex 50) (:knee-l :flex 70) (:knee-r :flex 52))                                                ; lifted off the back
  (7 (:root :u -0.26) (:spine :flex -12 :side 12) (:arm-l :flex 70 :side 80)
     (:arm-r :flex 165 :side -15 :twist -90) (:elbow-r :flex 50) (:hand-r :flex -25))                         ; overhead, at his right
  (9 :snap (:arm-r :twist 0) (:spine :flex -15 :side 15))                                                     ; behind
  (10.5 :snap (:arm-r :twist 90))                                                                              ; left
  (:s :snap (:root :u -0.16) (:arm-r :twist 180) (:thigh-l :flex 46) (:knee-l :flex 60) (:knee-r :flex 46))   ; front: cut 1
  (13.5 :snap (:arm-r :twist 270))
  (15 :snap (:arm-r :twist 360) (:root :yaw -8))
  (16.5 :snap (:arm-r :twist 450))
  (18 :snap (:root :u -0.08 :yaw 0) (:arm-r :twist 540) (:thigh-l :flex 40) (:knee-l :flex 48) (:knee-r :flex 38))   ; cut 2
  (19.5 :snap (:arm-r :twist 630))
  (21 :snap (:arm-r :twist 720) (:root :yaw -8))
  (22.5 :snap (:root :u 0.05 :yaw -4) (:arm-r :twist 810) (:hand-r :flex -35) (:thigh-l :flex 34) (:knee-l :flex 36) (:knee-r :flex 26))
  (24 :snap (:root :u 0.18 :yaw 0) (:arm-r :twist 900) (:hand-r :flex -45) (:spine :flex -18))                ; cut 3, climbing
  (25.5 :snap (:root :u 0.28) (:arm-r :twist 990) (:hand-r :flex -55) (:thigh-l :flex 40) (:knee-l :flex 60) (:thigh-r :flex 20) (:knee-r :flex 60))
  (:a :snap (:root :u 0.3) (:arm-r :twist 1020) (:spine :flex -20))                                           ; sprung
  (28 :snap (:root :u 0.3) (:arm-r :twist 1110) (:hand-r :flex -60))
  (31 (:root :u 0.06) (:arm-r :twist 1170) (:hand-r :flex -40) (:spine :flex -6 :side 8)
      (:thigh-l :flex 48) (:knee-l :flex 62) (:thigh-r :flex -12) (:knee-r :flex 44))                         ; down, slowed
  (31.001 (:arm-r :twist 90))                                                                                  ; (the same pose)
  (40 (:root :u -0.16) (:spine :flex 18 :side 0) (:arm-l :flex 40 :side 55) (:elbow-l :flex 34)
      (:arm-r :flex 40 :side 10 :twist 30) (:elbow-r :flex 85) (:hand-r :flex 40 :twist 15))                   ; lowered
  (:end :ke-s-st-1))
;; NS2b: the clamp and slam: the left hand takes the head and drives it down
(defstrike :ke-kt-slam (14 3 18 :base :ke-k-rest)
  (0)
  (5 (:root :f 0.1 :u -0.1) (:spine :flex 14) (:chest :twist 10) (:arm-l :flex 100 :side 10) (:elbow-l :flex 30) (:hand-l :flex -20))   ; the hand reaches
  (10 (:root :f 0.2 :u -0.12) (:arm-l :flex 112))                                                                                      ; clamped
  (:s :snap (:root :f 0.3 :u -0.3) (:spine :flex 48) (:arm-l :flex 60 :side 6) (:elbow-l :flex 20) (:head :flex -30) (:knees :flex 50))
  (:a (:spine :flex 54) (:root :u -0.32 :f 0.34))
  (22 (:spine :flex 50) (:root :u -0.3 :f 0.32))
  (:end :ke-k-rest))
;; NS3's three charges, one-handed: the left fist clenches and rises, each higher than the last (they hit nothing)
(defstrike :ke-kt-chg1 (20 0 14 :base :ke-kt-st-kamae)
  (0)
  (10 (:root :u -0.1) (:knees :flex 36) (:arm-l :flex 90 :side 16) (:elbow-l :flex 80))
  (:s (:root :u -0.1) (:knees :flex 38) (:arm-l :flex 92 :side 16) (:elbow-l :flex 82))
  (:end :ke-kt-st-kamae))
(defstrike :ke-kt-chg2 (16 0 14 :base :ke-kt-st-kamae)
  (0)
  (8 (:root :u -0.08) (:arm-l :flex 124 :side 20) (:elbow-l :flex 90) (:arm-r :flex 48) (:knees :flex 30))
  (:s (:root :u -0.1) (:arm-l :flex 130 :side 22) (:elbow-l :flex 92) (:arm-r :flex 52) (:knees :flex 36))
  (:end :ke-kt-st-kamae))
(defstrike :ke-kt-chg3 (16 0 20 :base :ke-kt-st-kamae)
  (0)
  (8 (:root :u 0.02) (:arm-l :flex 158 :side 24) (:elbow-l :flex 100) (:arm-r :flex 62) (:spine :flex -10) (:head :flex -12))
  (:s (:root :u 0.03) (:arm-l :flex 166 :side 26) (:elbow-l :flex 104) (:arm-r :flex 66) (:spine :flex -14) (:head :flex -16))
  (:end :ke-kt-st-kamae))

;;; ---------------------------------------------------------------- the V3 Shikai's J string and SA (DUEL_KEN_V3 §15)
;;; One hand, the cleaver's weight leading: each link one beat, its own arc, off the slung stance (:ke-s-st-1). A link starts with no
;;; blend, so each link's frame 0 is the pose its predecessor lands in (:ke-s-cutN-a, held a few frames). Hit poses solved by FK on the
;;; host: the 2.52 m blade against the 2.4 m volume reads only steep (the hand high and the tip at the far edge low, or the hand low and
;;; the tip high), so the 2.4 m links cut on diagonals; the follow-through turns the chest (the tip's radial stays put).
(defpose :ke-s-cut1-a (:base :ke-s-sling)               ; J1 landed: down and across to his left, the chest turned after it
  (:root :u -0.16 :f 0.3) (:pelvis :twist -12) (:spine :flex 32 :side 0) (:chest :twist 45) (:head :flex -12 :twist -10)
  (:arm-r :flex 122 :side -5 :twist 0) (:elbow-r :flex 90) (:hand-r :flex 108 :twist 10 :side 4) (:arm-l :flex -25 :side 50) (:elbow-l :flex 20)
  (:thigh-r :flex 48 :side 10) (:knee-r :flex 50) (:thigh-l :flex -16 :side 10) (:knee-l :flex 26))
;; J1: the diagonal off the sling: the hilt flung up over the right shoulder, then down from high right to low left as the right
;; foot lunges
(defstrike :ke-s-cut1 (9 3 12 :base :ke-s-sling)
  (0 :ke-s-st-1)
  (3 :ke-s-sling (:root :u -0.2 :f -0.02) (:pelvis :twist 20) (:spine :flex 16) (:chest :twist -28) (:head :twist 8)
     (:arm-r :flex 105 :side 40 :twist 0) (:elbow-r :flex 105) (:hand-r :flex -20 :twist -10 :side 0) (:arm-l :flex 40 :side 45) (:elbow-l :flex 40))
  (6 (:root :u -0.16 :f -0.06) (:pelvis :twist 26) (:spine :flex 8) (:chest :twist -44) (:arm-r :flex 165 :side 48) (:elbow-r :flex 80)
     (:hand-r :flex -35 :twist -15))
  (7 (:root :f -0.07) (:chest :twist -47) (:arm-r :flex 170 :side 50))                                       ; cocked, held
  (8 (:root :u -0.14 :f 0.1) (:pelvis :twist 10) (:spine :flex 18) (:chest :twist -10) (:arm-r :flex 170 :side 25) (:elbow-r :flex 50)
     (:hand-r :flex -117 :twist -15 :side 21))                                                                ; over the top
  (:s :snap (:root :u -0.12 :f 0.25) (:pelvis :twist -8) (:spine :flex 26 :side 0) (:chest :twist 22) (:head :flex -8 :twist -6)
      (:arm-r :flex 134 :side -1 :twist 1) (:elbow-r :flex 100) (:hand-r :flex 96 :twist 14 :side 0) (:arm-l :flex -15 :side 45) (:elbow-l :flex 20)
      (:thigh-r :flex 48 :side 10) (:knee-r :flex 48) (:thigh-l :flex -16 :side 10) (:knee-l :flex 24))
  (:a :ke-s-cut1-a)
  (16 (:root :u -0.15 :f 0.27) (:spine :flex 30) (:chest :twist 42))
  (:end :ke-s-st-1))
(defpose :ke-s-cut2-a (:base :ke-s-sling)               ; J2 landed: the blade up and out to his right, the hips unwound
  (:root :u -0.06 :f 0.24) (:pelvis :twist 18) (:spine :flex 6 :side -8) (:chest :twist -42) (:head :flex -10 :twist 12)
  (:arm-r :flex 70 :side 10 :twist 0) (:elbow-r :flex 8) (:hand-r :flex 30 :twist 13 :side 0) (:arm-l :flex 30 :side 80) (:elbow-l :flex 10)
  (:thigh-l :flex 40 :side 10) (:knee-l :flex 40) (:thigh-r :flex -12 :side 14) (:knee-r :flex 22))
;; J2: the backhand rising cut: coiled low on the left, the blade trailing behind him, then up from low left to high right, the free
;; hand flung out
(defstrike :ke-s-cut2 (9 3 13 :base :ke-s-sling)
  (0 :ke-s-cut1-a)
  (3 (:root :u -0.22 :f 0.22) (:pelvis :twist -20) (:spine :flex 26 :side 8) (:chest :twist 58) (:head :flex -10 :twist -12)
     (:arm-r :flex 20 :side -50 :twist 0) (:elbow-r :flex 30) (:hand-r :flex 216 :twist -2 :side 2) (:arm-l :flex 10 :side 40) (:elbow-l :flex 30)
     (:thigh-l :flex 30 :side 10) (:knee-l :flex 45) (:thigh-r :flex 10 :side 12) (:knee-r :flex 45))
  (8 (:root :u -0.24) (:chest :twist 62) (:arm-r :side -54))                                                  ; coiled, held
  (:s :snap (:root :u -0.1 :f 0.12) (:pelvis :twist 12) (:spine :flex 12 :side -6) (:chest :twist -20) (:head :flex -6 :twist 8)
      (:arm-r :flex 15 :side -41 :twist 0) (:elbow-r :flex 4) (:hand-r :flex 35 :twist 13 :side 0) (:arm-l :flex 20 :side 70) (:elbow-l :flex 15)
      (:thigh-l :flex 40 :side 10) (:knee-l :flex 40) (:thigh-r :flex -10 :side 14) (:knee-r :flex 25))
  (:a :ke-s-cut2-a)
  (17 (:root :f 0.22) (:chest :twist -38) (:arm-r :flex 66))
  (:end :ke-s-st-1))
(defpose :ke-s-cut3-a (:base :ke-s-sling)               ; J3 landed: swept round to his left, the arm still locked out
  (:root :u -0.14 :f 0.4 :yaw 22) (:pelvis :twist -25) (:spine :flex 20 :side 0) (:chest :twist 55) (:head :flex -6 :twist -20)
  (:arm-r :flex 96 :side -20 :twist 0) (:elbow-r :flex 8) (:hand-r :flex -92 :twist 3 :side 0) (:arm-l :flex -10 :side 70) (:elbow-l :flex 15)
  (:thigh-r :flex 55 :side 8) (:knee-r :flex 58) (:thigh-l :flex -25 :side 10) (:knee-l :flex 22))
;; J3: the big flat cleave that ends the string: dragged back out to his right, the arm locked, then one flat sweep across at chest
;; height on a long lunge; the weight carries him round after it
(defstrike :ke-s-cut3 (11 4 18 :base :ke-s-sling)
  (0 :ke-s-cut2-a)
  (2 (:root :u -0.12 :f 0.15) (:pelvis :twist 22) (:spine :flex 10 :side 0) (:chest :twist -35)
     (:arm-r :flex 80 :side 50 :twist 0) (:elbow-r :flex 12) (:hand-r :flex -7 :twist -105 :side 33))          ; tipped back
  (4 (:root :u -0.18 :f 0.05 :yaw 0) (:pelvis :twist 25) (:spine :flex 14 :side 6) (:chest :twist -50) (:head :flex -8 :twist 20)
     (:arm-r :flex 75 :side 85 :twist 0) (:elbow-r :flex 15) (:hand-r :flex -6 :twist -199 :side -35) (:arm-l :flex 50 :side 20) (:elbow-l :flex 50)
     (:thigh-l :flex 30 :side 10) (:knee-l :flex 40) (:thigh-r :flex -10 :side 12) (:knee-r :flex 35))
  (8 (:root :u -0.2 :f 0.0) (:chest :twist -58) (:arm-r :side 92))                                             ; dragged back, held
  (10 (:root :u -0.19) (:chest :twist -55))
  (:s :snap (:root :u -0.12 :f 0.38) (:pelvis :twist -15) (:spine :flex 18 :side 0) (:chest :twist 30) (:head :flex -6 :twist -10)
      (:arm-r :flex 98 :side -8 :twist 0) (:elbow-r :flex 10) (:hand-r :flex -92 :twist 3 :side 0) (:arm-l :flex 0 :side 60) (:elbow-l :flex 15)
      (:thigh-r :flex 55 :side 8) (:knee-r :flex 55) (:thigh-l :flex -25 :side 10) (:knee-l :flex 20))
  (:a :ke-s-cut3-a)
  (22 (:root :yaw 26 :f 0.36) (:chest :twist 58))
  (:end :ke-s-st-1))
(defpose :ke-s-cut4-a (:base :ke-s-sling)               ; J4 landed: crouched over the blade, bitten into the floor ahead
  (:root :u -0.3 :f 0.22) (:pelvis :twist 0) (:spine :flex 44 :side 0) (:chest :twist 0) (:head :flex -24 :twist 0)
  (:arm-r :flex 160 :side 14 :twist 2) (:elbow-r :flex 92) (:hand-r :flex 97 :twist 7 :side 0) (:arm-l :flex -25 :side 45) (:elbow-l :flex 25)
  (:thigh-r :flex 48 :side 10) (:knee-r :flex 68) (:thigh-l :flex 32 :side 12) (:knee-l :flex 60))
;; J4 (the special string, L3): the downward chop: heaved straight up overhead, up on the toes, then dropped through the centre line
(defstrike :ke-s-cut4 (9 3 12 :base :ke-s-sling)
  (0 :ke-s-cut3-a)
  (3 (:root :u -0.04 :f 0.3 :yaw 0) (:pelvis :twist 0) (:spine :flex -6 :side 0) (:chest :twist 0) (:head :flex -16 :twist 0)
     (:arm-r :flex 185 :side 15 :twist 0) (:elbow-r :flex 70) (:hand-r :flex -30 :twist 0 :side 0) (:arm-l :flex 110 :side 35) (:elbow-l :flex 30)
     (:thigh-r :flex 15 :side 10) (:knee-r :flex 15) (:thigh-l :flex 5 :side 10) (:knee-l :flex 12))
  (6 (:root :u 0.03) (:spine :flex -12) (:arm-r :flex 195) (:elbow-r :flex 82))                                  ; up, held
  (8 (:root :u -0.05 :f 0.25) (:spine :flex 10) (:arm-r :flex 175 :side 10) (:elbow-r :flex 40) (:hand-r :flex -137 :twist -4 :side 13))   ; over
  (:s :snap (:root :u -0.2 :f 0.2) (:pelvis :twist 0) (:spine :flex 28 :side 0) (:chest :twist 0) (:head :flex -20 :twist 0)
      (:arm-r :flex 166 :side 5 :twist 5) (:elbow-r :flex 71) (:hand-r :flex 99 :twist 10 :side 1) (:arm-l :flex -20 :side 40) (:elbow-l :flex 25)
      (:thigh-r :flex 45 :side 10) (:knee-r :flex 62) (:thigh-l :flex 30 :side 12) (:knee-l :flex 55))
  (:a :ke-s-cut4-a)
  (15 (:root :u -0.29) (:spine :flex 42))
  (:end :ke-s-st-1))
(defpose :ke-s-cut5-a (:base :ke-s-sling)               ; J5 landed: risen onto the front foot, the blade up over his head
  (:root :u 0.0 :f 0.45) (:pelvis :twist 20) (:spine :flex -12 :side 0) (:chest :twist -20) (:head :flex -20 :twist 0)
  (:arm-r :flex 112 :side 2 :twist 0) (:elbow-r :flex 85) (:hand-r :flex -97 :twist -12 :side 0) (:arm-l :flex 0 :side 85) (:elbow-l :flex 10)
  (:thigh-l :flex 45 :side 8) (:knee-l :flex 30) (:thigh-r :flex -30 :side 12) (:knee-r :flex 10))
;; J5: the rising backhand with a step: the blade dragged along the floor ahead to his left, then the left foot strides in and it
;; rips straight up the centre
(defstrike :ke-s-cut5 (9 3 13 :base :ke-s-sling)
  (0 :ke-s-cut4-a)
  (2 (:root :u -0.31 :f 0.21) (:pelvis :twist -10) (:spine :flex 40 :side 3) (:chest :twist 18)
     (:arm-r :flex 95 :side -15 :twist 0) (:elbow-r :flex 55) (:hand-r :flex 213 :twist 3 :side -19))           ; dragged left on the floor
  (3 (:root :u -0.32 :f 0.2) (:pelvis :twist -20) (:spine :flex 36 :side 6) (:chest :twist 35) (:head :flex -14 :twist -10)
     (:arm-r :flex 30 :side -35 :twist 0) (:elbow-r :flex 25) (:hand-r :flex 285 :twist 19 :side -3) (:arm-l :flex 20 :side 40) (:elbow-l :flex 30)
     (:thigh-l :flex 20 :side 8) (:knee-l :flex 50) (:thigh-r :flex 20 :side 12) (:knee-r :flex 55))
  (8 (:root :u -0.28 :f 0.28) (:chest :twist 40) (:thigh-l :flex 36) (:knee-l :flex 48))                        ; the step, held low
  (:s :snap (:root :u -0.06 :f 0.4) (:pelvis :twist 15) (:spine :flex -5 :side 0) (:chest :twist -10) (:head :flex -10 :twist 0)
      (:arm-r :flex 3 :side -25 :twist 0) (:elbow-r :flex 26) (:hand-r :flex 18 :twist 6 :side 0) (:arm-l :flex 10 :side 80) (:elbow-l :flex 10)
      (:thigh-l :flex 50 :side 8) (:knee-l :flex 45) (:thigh-r :flex -25 :side 12) (:knee-r :flex 15))
  (:a :ke-s-cut5-a)
  (16 (:root :u -0.02) (:spine :flex -10))
  (:end :ke-s-st-1))
(defpose :ke-s-cut6-a (:base :ke-s-sling)               ; J6 landed: the shoulder through, the blade gone on round to his left
  (:root :u -0.16 :f 0.35 :yaw 14) (:pelvis :twist -15) (:spine :flex 24 :side 8) (:chest :twist 40) (:head :flex -10 :twist -16)
  (:arm-r :flex -55 :side 50 :twist 0) (:elbow-r :flex 30) (:hand-r :flex 70 :twist 3 :side 0) (:arm-l :flex 20 :side 25) (:elbow-l :flex 70)
  (:thigh-r :flex 45 :side 10) (:knee-r :flex 48) (:thigh-l :flex -15 :side 10) (:knee-l :flex 25))
;; J6: the shoulder-driven hack: the blade dropped flat behind the right shoulder, then the shoulder rams in and hacks it round flat
(defstrike :ke-s-cut6 (10 3 12 :base :ke-s-sling)
  (0 :ke-s-cut5-a)
  (4 (:root :u -0.16 :f 0.1) (:pelvis :twist 20) (:spine :flex 10 :side -6) (:chest :twist -45) (:head :flex -8 :twist 16)
     (:arm-r :flex 30 :side 95 :twist 0) (:elbow-r :flex 110) (:hand-r :flex 94 :twist 5 :side 5) (:arm-l :flex 40 :side 30) (:elbow-l :flex 60)
     (:thigh-r :flex 0 :side 10) (:knee-r :flex 35) (:thigh-l :flex 20 :side 10) (:knee-l :flex 40))
  (9 (:root :u -0.18) (:chest :twist -52) (:arm-r :side 100))                                                     ; cocked, held
  (:s :snap (:root :u -0.14 :f 0.3) (:pelvis :twist -10) (:spine :flex 20 :side 8) (:chest :twist 8) (:head :flex -10 :twist -10)
      (:arm-r :flex -61 :side 55 :twist 0) (:elbow-r :flex 16) (:hand-r :flex 63 :twist 3 :side 0) (:arm-l :flex 15 :side 30) (:elbow-l :flex 60)
      (:thigh-r :flex 45 :side 10) (:knee-r :flex 45) (:thigh-l :flex -15 :side 10) (:knee-l :flex 25))
  (:a :ke-s-cut6-a)
  (16 (:root :yaw 12) (:chest :twist 36))
  (:end :ke-s-st-1))
(defpose :ke-s-cut7-a (:base :ke-s-sling)               ; J7 landed: folded over the blade, buried in the floor
  (:root :u -0.44 :f 0.52) (:pelvis :twist 0) (:spine :flex 60 :side 0) (:chest :twist 0) (:head :flex -34 :twist 0)
  (:arm-r :flex 77 :side 42 :twist 1) (:elbow-r :flex 74) (:hand-r :flex -115 :twist -25 :side 0) (:arm-l :flex -35 :side 55) (:elbow-l :flex 20)
  (:thigh-r :flex 72 :side 10) (:knee-r :flex 95) (:thigh-l :flex 30 :side 12) (:knee-l :flex 85))
;; J7: the slam that builds into the Bankai: heaved up over his head with both arms flung high, risen on the toes, held, then the
;; whole body dropped after it into the floor
(defstrike :ke-s-cut7 (12 4 18 :base :ke-s-sling)
  (0 :ke-s-cut6-a)
  (5 (:root :u 0.08 :f 0.2 :yaw 0) (:pelvis :twist 0) (:spine :flex -18 :side 0) (:chest :twist 0) (:head :flex -25 :twist 0)
     (:arm-r :flex 200 :side 20 :twist 0) (:elbow-r :flex 60) (:hand-r :flex -40 :twist 0 :side 0) (:arm-l :flex 150 :side 40) (:elbow-l :flex 20)
     (:thigh-r :flex 10 :side 10) (:knee-r :flex 5) (:thigh-l :flex 5 :side 10) (:knee-l :flex 5))
  (9 (:root :u 0.12) (:spine :flex -22) (:arm-r :flex 205))                                                        ; up, held
  (10 (:root :u 0.11) (:arm-r :flex 203))
  (:s :snap (:root :u -0.4 :f 0.5) (:pelvis :twist 0) (:spine :flex 55 :side 0) (:chest :twist 0) (:head :flex -30 :twist 0)
      (:arm-r :flex 73 :side 56 :twist 2) (:elbow-r :flex 74) (:hand-r :flex -120 :twist -31 :side 0) (:arm-l :flex -30 :side 50) (:elbow-l :flex 20)
      (:thigh-r :flex 70 :side 10) (:knee-r :flex 90) (:thigh-l :flex 30 :side 12) (:knee-l :flex 80))
  (:a :ke-s-cut7-a)
  (22 (:root :u -0.43) (:spine :flex 58))
  (:end :ke-s-st-1))
(defpose :ke-s-cut-sa-a (:base :ke-s-sling)             ; the SA landed: the wrist snapped through, the blade out to his right
  (:root :u -0.08 :f 0.2) (:pelvis :twist -10) (:spine :flex 16 :side 4) (:chest :twist -40) (:head :flex -8 :twist -6)
  (:arm-r :flex -55 :side -47 :twist 11) (:elbow-r :flex 43) (:hand-r :flex 60 :twist -48 :side 0) (:arm-l :flex 0 :side 70) (:elbow-l :flex 20)
  (:thigh-r :flex 42 :side 10) (:knee-r :flex 44) (:thigh-l :flex -18 :side 10) (:knee-l :flex 22))
;; the SA (one hand in an NS gap): the quick snap: the hilt drawn across to his left shoulder, then a flat backhand flicked out to the
;; right as he steps in
(defstrike :ke-s-cut-sa (8 3 12 :base :ke-s-sling)
  (0 :ke-s-st-1)
  (3 :ke-s-sling (:root :u -0.18 :f 0.05) (:pelvis :twist 25) (:spine :flex 20 :side 4) (:chest :twist 45) (:head :flex -10 :twist -10)
     (:arm-r :flex 40 :side -60 :twist 0) (:elbow-r :flex 90) (:hand-r :flex -7 :twist 153 :side -34) (:arm-l :flex 20 :side 40) (:elbow-l :flex 30))
  (7 (:root :u -0.19) (:chest :twist 48))                                                                         ; drawn, held
  (:s :snap (:root :u -0.1 :f 0.14) (:pelvis :twist 15) (:spine :flex 14 :side -4) (:chest :twist -25) (:head :flex -8 :twist 10)
      (:arm-r :flex -61 :side -50 :twist 18) (:elbow-r :flex 30) (:hand-r :flex 28 :twist -20 :side -4) (:arm-l :flex 10 :side 60) (:elbow-l :flex 20)
      (:thigh-r :flex 40 :side 10) (:knee-r :flex 42) (:thigh-l :flex -18 :side 10) (:knee-l :flex 22))
  (:a :ke-s-cut-sa-a)
  (14 (:root :f 0.18) (:chest :twist -36))
  (:end :ke-s-st-1))

;;; ---------------------------------------------------------------- RYOTE's stances (DUEL_KEN_RYOTE): the kendo kamae by pointer
;;; Each on the jodan rest (:ke-r-stance) so the opponent reads the next NS: 1 chudan (the blade level at his throat), 2 hasso (the blade
;;; cocked back by the shoulder, leaning in), 3 jodan (the blade high over the brow, upright).
(defpose :ke-r-st-chain (:base :ke-r-stance)
  (:root :f 0.06 :u -0.08) (:spine :flex 10) (:head :flex -8)
  (:arm-r :flex 70 :side 14 :twist -5) (:elbow-r :flex 80) (:hand-r :flex -40)
  (:arm-l :flex 82 :side 30 :twist 41) (:elbow-l :flex 52)
  (:thigh-l :flex 30 :side 8) (:knee-l :flex 36) (:thigh-r :flex -14 :side 12) (:knee-r :flex 24))
(defclip :ke-r-st-chain (1.6 :loop t :base :ke-r-st-chain)
  (0) (0.8 (:chest :flex 3) (:root :u -0.09)))
(defpose :ke-r-st-rush (:base :ke-r-stance)
  (:root :f 0.1 :u -0.14) (:spine :flex 20) (:head :flex -16)
  (:arm-r :flex 124 :side 24 :twist -5) (:elbow-r :flex 112) (:hand-r :flex -50)
  (:arm-l :flex 126 :side 40 :twist 41) (:elbow-l :flex 60)
  (:thigh-l :flex 42 :side 8) (:knee-l :flex 50) (:thigh-r :flex -20 :side 14) (:knee-r :flex 28))
(defclip :ke-r-st-rush (1.4 :loop t :base :ke-r-st-rush)
  (0) (0.7 (:chest :flex 4) (:root :u -0.15)))
(defpose :ke-r-st-kamae (:base :ke-r-stance)
  (:root :u -0.03) (:spine :flex -4) (:head :flex 2)
  (:arm-r :flex 150 :side 18 :twist -5) (:elbow-r :flex 100) (:hand-r :flex -60)
  (:arm-l :flex 152 :side 34 :twist 41) (:elbow-l :flex 62)
  (:thigh-l :flex 18 :side 8) (:knee-l :flex 22) (:thigh-r :flex -8 :side 10) (:knee-r :flex 14))
(defclip :ke-r-st-kamae (2.0 :loop t :base :ke-r-st-kamae)
  (0) (1.0 (:chest :flex 2) (:root :u -0.04)))

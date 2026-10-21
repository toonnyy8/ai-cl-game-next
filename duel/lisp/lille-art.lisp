;;;; lille-art.lisp — LILLE BARRO as art data (docs/duel/DUEL_LILLE.md §3, §9, §10, §12 Art; the model sheet
;;;; docs/research/tybw-characters/notes/lille_barro_model_sheet.md): his four bodies (:lille 182 cm, dark skin #7A6155, all
;;;; in white with the green fur bicorne / stole / panel, the left eye shut under the ring-of-four-arcs mark; :lille-jilliel,
;;;; the holed cream column floating, its face in a round window, its arms hidden in it (the rig's hands are the front wing
;;;; pair's tips); :lille-jilliel-kin, that column on two ㄇ-shaped legs; and :lille-shin, the owl on KIN's model: the column
;;;; in white, the ㄇ legs, long arms and an extra cosmetic pair, a segmented S-neck to a tiny barn-owl face),
;;;; Diagramm (2.4 m: the barrel through a fur sleeve, the plank across the rear, the muzzle cross), the props of his looks
;;;; (the wing blades with their three oval holes, the halos, the open eye, the reticle, the trumpet), every :lb-* pose and
;;;; clip, his draw hook (Jilliel's eight wing blades in two fans / folded in MUJITTAI, the owl's eight gold wings, all of
;;;; them translucent glass in a translucent rim, each blade three jointed segments; the ㄇ legs' shanks and struts; the owl's extra arms; the halos, the aim line
;;;; and its reticle, the eye opening, the trumpet, the reflect), his hazards' look, his HUD meter
;;;; (the eye pips, the halo icon), his one-hand ring, his sounds and brush glyphs, and the cinematics' looks.
;;;; Batch 1 built the functional art (the strikes put the plank (J1 / J2 / the Breaker), the muzzle (J3, K) or the wing /
;;;; arm tips (Jilliel, the owl) where the moves' volumes end: *LB-STRIKE-POINTS*; the host FK test checks them); batch 3b
;;;; (2026-10-06) the look. Everything here is cosmetic: the sim never reads it. The jade is an ink tone and the owl's gold
;;;; is Senjumaru's muted #B89A5A (decision 11): the three spot hues stay FIRE, REIATSU and BLOOD.
(in-package :duel)

;;; ---------------------------------------------------------------- bodies
;; 182 cm (scale 1.0), long-limbed, the anime head x1.2; the hurt cylinder r 0.38 / h 1.80 in every form (the cap, the wings,
;; the halos and the neck add none: a fairness floor)
(defbody :lille (:scale 1.0 :width 1.04 :hunch 0 :hurt-r 0.38 :hurt-h 1.8
                 :girth ((:head 1.2 1.2 1.2))
                 :palette ((:white #xECECE8) (:green #x434D3B) (:green-d #x2A3124) (:skin #x7A6155) (:hair #xD8D2C0)
                           (:button #xBCC1CC) (:black #x16161E) (:eye #xF2F0EC) (:pupil #x2A3124) (:brow #x2A2420)
                           (:mouth #x4A2E2A) (:lid #x2A2420))
                 :rim (#xFFE8C8 0.14))
  ;; white trousers, the buttoned green front panel with its notched point
  (:pelvis (:box 0.34 0.2 0.24 :c :white)
           (:box 0.1 0.24 0.02 :at (0 -0.1 0.125) :c :green)
           (:box 0.07 0.07 0.02 :at (0 -0.22 0.125) :rot (0 0 45) :c :green)
           (:box 0.02 0.02 0.01 :at (0.04 -0.04 0.137) :c :button) (:box 0.02 0.02 0.01 :at (-0.04 -0.04 0.137) :c :button)
           (:box 0.02 0.02 0.01 :at (0.04 -0.12 0.137) :c :button) (:box 0.02 0.02 0.01 :at (-0.04 -0.12 0.137) :c :button))
  ;; the wide white waist band, three buttons on his right
  (:spine (:bevel 0.32 0.24 0.22 0.04 :at (0 0.1 0) :c :white)
          (:box 0.34 0.12 0.24 :at (0 0.02 0) :c :white)
          (:box 0.02 0.02 0.01 :at (0.1 0.09 0.122) :c :button) (:box 0.02 0.02 0.01 :at (0.1 0.05 0.122) :c :button)
          (:box 0.02 0.02 0.01 :at (0.1 0.01 0.122) :c :button))
  ;; the white shirt, a V of skin, the long green fur stole from the neck down the right chest (three grey buttons on its
  ;; inner edge, jagged fur on its outer one), ringing the back of the collar
  (:chest (:bevel 0.42 0.3 0.26 0.05 :at (0 0.11 0) :c :white)
          (:box 0.07 0.1 0.01 :at (0 0.22 0.13) :c :skin)
          (:bevel 0.15 0.52 0.08 0.03 :at (0.105 0.05 0.12) :rot (0 0 -5) :c :green)
          (:box 0.02 0.46 0.02 :at (0.17 0.05 0.155) :rot (0 0 -5) :c :green-d)
          (:cone 0.022 0.06 :at (0.19 0.2 0.12) :rot (0 0 -100) :seg 4 :c :green)
          (:cone 0.022 0.06 :at (0.195 0.06 0.12) :rot (0 0 -95) :seg 4 :c :green)
          (:cone 0.022 0.06 :at (0.19 -0.08 0.12) :rot (0 0 -105) :seg 4 :c :green)
          (:cone 0.03 0.07 :at (0.11 -0.22 0.12) :rot (0 0 180) :seg 4 :c :green)                   ; its tail
          (:box 0.025 0.025 0.012 :at (0.045 0.18 0.162) :c :button) (:box 0.025 0.025 0.012 :at (0.047 0.06 0.162) :c :button)
          (:box 0.025 0.025 0.012 :at (0.049 -0.06 0.162) :c :button)
          (:bevel 0.32 0.07 0.09 0.025 :at (0 0.27 -0.08) :c :green))           ; the stole rings the back of the collar
  (:neck (:cyl 0.05 0.14 :at (0 0.06 0) :c :skin)
         (:bevel 0.1 0.08 0.08 0.025 :at (0.06 0.06 -0.02) :rot (0 0 -20) :c :green))     ; the stole round his neck
  ;; the head (x1.2): the right eye open, the left shut under the mark (a ring broken into four arcs, four ticks pointing
  ;; in at the diagonals: an X with its centre open); the green fur bicorne worn crosswise: a fur rim low on the brow, a
  ;; dome, two fur ridges left and right rising to their points at the front, the white crown between them (a stripe
  ;; from the brow over the top), a steel emblem disc on each side; cream sideburns
  (:head (:sphere 0.072 :stretch 0.02 :at (0 0.13 -0.01) :seg 12 :c :skin)
         (:bevel 0.1 0.08 0.08 0.02 :at (0 0.1 0.02) :c :skin)
         (:box 0.024 0.01 0.003 :at (0.028 0.125 0.062) :c :eye)
         (:box 0.011 0.01 0.003 :at (0.026 0.125 0.0635) :c :pupil)
         (:box 0.026 0.004 0.003 :at (0.028 0.142 0.0625) :c :brow)
         (:box 0.026 0.004 0.003 :at (-0.028 0.124 0.0625) :c :lid)                 ; the shut left eye
         (:box 0.022 0.004 0.003 :at (-0.028 0.146 0.0625) :c :brow)
         (:box 0.0085 0.0028 0.002 :at (-0.0116 0.1196 0.0636) :rot (0 0 75) :c :black)      ; the mark: four arcs
         (:box 0.0085 0.0028 0.002 :at (-0.0116 0.1284 0.0636) :rot (0 0 105) :c :black)
         (:box 0.0085 0.0028 0.002 :at (-0.0236 0.1404 0.0636) :rot (0 0 165) :c :black)
         (:box 0.0085 0.0028 0.002 :at (-0.0324 0.1404 0.0636) :rot (0 0 195) :c :black)
         (:box 0.0085 0.0028 0.002 :at (-0.0444 0.1284 0.0636) :rot (0 0 255) :c :black)
         (:box 0.0085 0.0028 0.002 :at (-0.0444 0.1196 0.0636) :rot (0 0 285) :c :black)
         (:box 0.0085 0.0028 0.002 :at (-0.0324 0.1076 0.0636) :rot (0 0 345) :c :black)
         (:box 0.0085 0.0028 0.002 :at (-0.0236 0.1076 0.0636) :rot (0 0 375) :c :black)
         (:box 0.009 0.0026 0.002 :at (-0.0156 0.1364 0.0636) :rot (0 0 45) :c :black)        ; ... and four inward ticks
         (:box 0.009 0.0026 0.002 :at (-0.0404 0.1364 0.0636) :rot (0 0 135) :c :black)
         (:box 0.009 0.0026 0.002 :at (-0.0404 0.1116 0.0636) :rot (0 0 225) :c :black)
         (:box 0.009 0.0026 0.002 :at (-0.0156 0.1116 0.0636) :rot (0 0 315) :c :black)
         (:box 0.016 0.003 0.003 :at (0 0.075 0.058) :c :mouth)
         (:box 0.018 0.05 0.03 :at (0.068 0.12 0.0) :c :hair) (:box 0.018 0.05 0.03 :at (-0.068 0.12 0.0) :c :hair)
         (:box 0.11 0.02 0.04 :at (0 0.11 -0.07) :c :hair)                                    ; the cream undercut at the nape
         (:cyl 0.088 0.055 :at (0 0.172 -0.012) :seg 14 :c :green)                           ; the fur rim, low on the brow
         (:sphere 0.08 :at (0 0.205 -0.015) :seg 12 :c :green)                               ; the dome
         (:sphere 0.044 :stretch 0.065 :at (0.05 0.245 -0.01) :rot (0 105 0) :seg 10 :c :green)   ; the two ridges, the
         (:sphere 0.044 :stretch 0.065 :at (-0.05 0.245 -0.01) :rot (0 105 0) :seg 10 :c :green) ; front ends raised
         (:sphere 0.038 :stretch 0.03 :at (0.056 0.282 0.045) :rot (0 -20 -14) :seg 10 :c :green)  ; the points, left and
         (:sphere 0.038 :stretch 0.03 :at (-0.056 0.282 0.045) :rot (0 -20 14) :seg 10 :c :green)  ; right: rounded lobes
         (:bevel 0.03 0.04 0.2 0.012 :at (0 0.252 -0.012) :c :white)                       ; the white crown between them
         (:bevel 0.03 0.07 0.014 0.006 :at (0 0.224 0.086) :c :white)                      ; its stripe down the front
         (:cone 0.016 0.035 :at (0.075 0.16 0.07) :rot (0 0 -150) :seg 4 :c :green-d)       ; jagged fur on the rim
         (:cone 0.016 0.035 :at (-0.075 0.16 0.07) :rot (0 0 150) :seg 4 :c :green-d)
         (:cone 0.016 0.035 :at (0.09 0.16 -0.04) :rot (0 0 -120) :seg 4 :c :green-d)
         (:cone 0.016 0.035 :at (-0.09 0.16 -0.04) :rot (0 0 120) :seg 4 :c :green-d)
         (:cyl 0.022 0.012 :at (0.094 0.215 -0.01) :rot (0 0 90) :seg 10 :c :button)        ; the emblem discs
         (:cyl 0.022 0.012 :at (-0.094 0.215 -0.01) :rot (0 0 90) :seg 10 :c :button))
  (:shoulder-r (:bevel 0.17 0.1 0.22 0.035 :at (0.03 0 0) :c :green)                         ; the stole's fur mass
               (:cone 0.025 0.06 :at (0.13 -0.02 0) :rot (0 0 -95) :seg 4 :c :green)
               (:cone 0.025 0.06 :at (0.1 -0.03 0.08) :rot (0 0 -110) :seg 4 :c :green))
  (:shoulder-l (:sphere 0.06 :at (0.0 -0.01 0) :c :skin))
  (:upper-arm-r (:cyl 0.055 0.3 :top 0.05 :at (0 -0.15 0) :c :white))             ; the white right sleeve
  (:upper-arm-l (:cyl 0.052 0.3 :top 0.045 :at (0 -0.15 0) :c :skin))             ; the bare left arm
  (:lower-arm-r (:cyl 0.045 0.27 :top 0.04 :at (0 -0.13 0) :c :white) (:cyl 0.056 0.06 :top 0.05 :at (0 -0.24 0) :c :white))
  (:lower-arm-l (:cyl 0.044 0.27 :top 0.038 :at (0 -0.13 0) :c :skin) (:cyl 0.056 0.06 :top 0.05 :at (0 -0.24 0) :c :white))
  (:hand-r (:bevel 0.07 0.09 0.04 0.012 :at (0 -0.04 0) :c :white))
  (:hand-l (:bevel 0.07 0.09 0.04 0.012 :at (0 -0.04 0) :c :white))
  (:thigh-r (:cyl 0.09 0.44 :top 0.075 :seg 10 :at (0 -0.21 0) :c :white))
  (:thigh-l (:cyl 0.09 0.44 :top 0.075 :seg 10 :at (0 -0.21 0) :c :white))
  (:shin-r (:cyl 0.07 0.43 :top 0.065 :seg 10 :at (0 -0.2 0) :c :white))
  (:shin-l (:cyl 0.07 0.43 :top 0.065 :seg 10 :at (0 -0.2 0) :c :white))
  (:foot-r (:bevel 0.08 0.06 0.22 0.02 :at (0 -0.03 0.05) :c :white))
  (:foot-l (:bevel 0.08 0.06 0.22 0.02 :at (0 -0.03 0.05) :c :white)))

;; 神の裁き JILLIEL: the slender holed cream column (no legs drawn: the rig's legs carry nothing), widest at the top, ending in
;; two prongs; round holes pierce it (four near the top, six near the bottom); its face shows in a round window near the
;; top (the mouth covered), two horn points at the top corners. No arms (decision 19, 2026-10-06): the rig's arms (x2.6
;; long) are hidden in the column and drawn as nothing; his eight wing blades are drawn by his :draw hook (LILLE-DRAW: two
;; fans of four rooted behind the column's top; the front pair runs from its root to the rig's hands, so a J / K strikes
;; with a wing tip at the hand; folded in MUJITTAI) with the wide halo. Muted jade (decision 11).
(defbody :lille-jilliel (:scale 1.0 :width 1.0 :hunch 0 :hurt-r 0.38 :hurt-h 1.8 :props (:arms 2.6)
                         :palette ((:cream #xEDE6CC) (:cream-d #xD9D0B2) (:jade #x6E9A80) (:jade-d #x4E6E5C) (:hole #x2A2A30)
                                   (:core #x9CC4AC) (:lining #x15130F) (:nose #x6B5348) (:ridge #x4A3A31) (:band #xCFC6B0) (:skin #x7A6155) (:eye #xF2F0EC) (:pupil #x2A3124))
                         :rim (#xFFE8C8 0.14))
  (:pelvis (:cyl 0.15 0.7 :top 0.13 :seg 12 :at (0 -0.3 0) :c :cream)
           (:cone 0.075 0.32 :at (0.085 -0.8 0) :rot (0 0 172) :seg 6 :c :cream)        ; the two prongs
           (:cone 0.075 0.32 :at (-0.085 -0.8 0) :rot (0 0 188) :seg 6 :c :cream)
           (:cyl 0.15 0.05 :top 0.15 :seg 12 :at (0 -0.66 0) :c :cream-d)
           (:cyl 0.03 0.012 :at (0.05 -0.15 0.138) :rot (0 90 0) :seg 10 :c :hole)      ; six holes near the bottom
           (:cyl 0.03 0.012 :at (-0.06 -0.3 0.14) :rot (0 90 0) :seg 10 :c :hole)
           (:cyl 0.03 0.012 :at (0.045 -0.46 0.143) :rot (0 90 0) :seg 10 :c :hole)
           (:cyl 0.028 0.012 :at (-0.04 -0.58 0.145) :rot (0 90 0) :seg 10 :c :hole)
           (:cyl 0.03 0.012 :at (0.142 -0.36 0) :rot (0 0 90) :seg 10 :c :hole)
           (:cyl 0.03 0.012 :at (-0.143 -0.42 0) :rot (0 0 90) :seg 10 :c :hole)
           (:cyl 0.03 0.012 :at (0.02 -0.28 -0.142) :rot (0 90 0) :seg 10 :c :hole))
  (:spine (:cyl 0.13 0.3 :top 0.15 :seg 12 :at (0 0.1 0) :c :cream)
          (:cyl 0.026 0.012 :at (-0.05 0.12 0.138) :rot (0 90 0) :seg 10 :c :hole))
  (:chest (:cyl 0.16 0.42 :top 0.19 :seg 12 :at (0 0.14 0) :c :cream)
          (:cyl 0.032 0.012 :at (0.07 0.24 0.178) :rot (0 90 0) :seg 10 :c :hole)       ; four holes near the top
          (:cyl 0.032 0.012 :at (-0.075 0.2 0.176) :rot (0 90 0) :seg 10 :c :hole)
          (:cyl 0.03 0.012 :at (0.0 0.06 0.17) :rot (0 90 0) :seg 10 :c :hole)
          (:cyl 0.03 0.012 :at (0.168 0.16 0.0) :rot (0 0 90) :seg 10 :c :hole)
          (:cyl 0.03 0.012 :at (-0.17 0.12 0.0) :rot (0 0 90) :seg 10 :c :hole)
          (:cyl 0.03 0.012 :at (0.05 0.2 -0.18) :rot (0 90 0) :seg 10 :c :hole)
          (:sphere 0.09 :stretch 0.04 :at (0 0.3 -0.13) :rot (0 0 90) :seg 10 :c :cream-d))   ; the wings' root, behind the top
  (:neck (:cyl 0.13 0.15 :seg 12 :at (0 0.06 0) :c :cream :tag :jl-head))
  ;; the top of the column (decision 57, 2026-10-08): a collar round the head, its rim cut on a slant (low at the front,
  ;; at the chin; high behind, a little over the crown), black inside; the head brown, narrow (x0.8), cut by two pale rings
  ;; through its centre tilted 15 deg to each side (their rims the crown's bands, crossing on top), both eyes open, a darker
  ;; nose a trapezoid in profile (narrow at the top), a white cylinder over the face's lower half, the chin on a round knob
  ;; (tagged: the revival's headless column hides the head, keeps the collar)
  ;; (the collar's outside on the column's top radius, 0.19 m; the head the base form's size, set 3 cm into the collar: the
  ;; user, 2026-10-08)
  (:head (:sphere 0.086 :at (0 0.14 0) :seg 16 :squash (0.8 1 1) :c :skin :tag :jl-head)        ; the base form's head size
         (:cyl 0.0885 0.017 :at (0 0.14 0) :rot (15 0 90) :seg 24 :squash (0.8 1 1) :c :band :tag :jl-head)        ; two rings through his centre,
         (:cyl 0.0885 0.017 :at (0 0.14 0) :rot (-15 0 90) :seg 24 :squash (0.8 1 1) :c :band :tag :jl-head)       ;  their rims the crown's pale bands
         (:box 0.018 0.008 0.003 :at (0.019 0.155 0.083) :c :eye :tag :jl-head)                    ; both eyes open
         (:box 0.018 0.008 0.003 :at (-0.019 0.155 0.083) :c :eye :tag :jl-head)
         (:box 0.008 0.008 0.003 :at (0.019 0.155 0.085) :c :pupil :tag :jl-head)
         (:box 0.008 0.008 0.003 :at (-0.019 0.155 0.085) :c :pupil :tag :jl-head)
         (:wedge 0.018 0.044 0.016 :at (0 0.128 0.105) :rot (180 0 0) :c :nose :ink 0.6 :tag :jl-head)   ; (the slope ...
         (:box 0.018 0.044 0.024 :at (0 0.128 0.085) :c :nose :ink 0.6 :tag :jl-head)                    ;  on a flat: a trapezoid, the nose)
         (:sphere 0.032 :at (0 0.052 0.072) :seg 10 :c :cream :tag :jl-head)                   ; the chin knob
         (:cyl 0.084 0.06 :at (0 0.08 0) :seg 18 :squash (0.8 1 1) :c :cream :tag :jl-head)   ; the white cylinder over the face's lower half
         (:box 0.05 0.080 0.024 :at (0.0000 0.0000 0.1780) :rot (-0.0 0 0) :c :cream)
         (:box 0.046 0.072 0.01 :at (0.0000 -0.0040 0.1630) :rot (-0.0 0 0) :c :lining)
         (:box 0.05 0.084 0.024 :at (0.0461 0.0021 0.1719) :rot (-15.0 0 0) :c :cream)
         (:box 0.046 0.076 0.01 :at (0.0422 -0.0019 0.1574) :rot (-15.0 0 0) :c :lining)
         (:box 0.05 0.097 0.024 :at (0.0890 0.0084 0.1542) :rot (-30.0 0 0) :c :cream)
         (:box 0.046 0.089 0.01 :at (0.0815 0.0044 0.1412) :rot (-30.0 0 0) :c :lining)
         (:box 0.05 0.117 0.024 :at (0.1259 0.0183 0.1259) :rot (-45.0 0 0) :c :cream)
         (:box 0.046 0.109 0.01 :at (0.1153 0.0143 0.1153) :rot (-45.0 0 0) :c :lining)
         (:box 0.05 0.142 0.024 :at (0.1542 0.0312 0.0890) :rot (-60.0 0 0) :c :cream)
         (:box 0.046 0.134 0.01 :at (0.1412 0.0272 0.0815) :rot (-60.0 0 0) :c :lining)
         (:box 0.05 0.173 0.024 :at (0.1719 0.0463 0.0461) :rot (-75.0 0 0) :c :cream)
         (:box 0.046 0.165 0.01 :at (0.1574 0.0423 0.0422) :rot (-75.0 0 0) :c :lining)
         (:box 0.05 0.205 0.024 :at (0.1780 0.0625 0.0000) :rot (-90.0 0 0) :c :cream)
         (:box 0.046 0.197 0.01 :at (0.1630 0.0585 0.0000) :rot (-90.0 0 0) :c :lining)
         (:box 0.05 0.237 0.024 :at (0.1719 0.0787 -0.0461) :rot (-105.0 0 0) :c :cream)
         (:box 0.046 0.229 0.01 :at (0.1574 0.0747 -0.0422) :rot (-105.0 0 0) :c :lining)
         (:box 0.05 0.267 0.024 :at (0.1542 0.0937 -0.0890) :rot (-120.0 0 0) :c :cream)
         (:box 0.046 0.259 0.01 :at (0.1412 0.0897 -0.0815) :rot (-120.0 0 0) :c :lining)
         (:box 0.05 0.293 0.024 :at (0.1259 0.1067 -0.1259) :rot (-135.0 0 0) :c :cream)
         (:box 0.046 0.285 0.01 :at (0.1153 0.1027 -0.1153) :rot (-135.0 0 0) :c :lining)
         (:box 0.05 0.313 0.024 :at (0.0890 0.1166 -0.1542) :rot (-150.0 0 0) :c :cream)
         (:box 0.046 0.305 0.01 :at (0.0815 0.1126 -0.1412) :rot (-150.0 0 0) :c :lining)
         (:box 0.05 0.326 0.024 :at (0.0461 0.1229 -0.1719) :rot (-165.0 0 0) :c :cream)
         (:box 0.046 0.318 0.01 :at (0.0422 0.1189 -0.1574) :rot (-165.0 0 0) :c :lining)
         (:box 0.05 0.330 0.024 :at (0.0000 0.1250 -0.1780) :rot (-180.0 0 0) :c :cream)
         (:box 0.046 0.322 0.01 :at (0.0000 0.1210 -0.1630) :rot (-180.0 0 0) :c :lining)
         (:box 0.05 0.326 0.024 :at (-0.0461 0.1229 -0.1719) :rot (-195.0 0 0) :c :cream)
         (:box 0.046 0.318 0.01 :at (-0.0422 0.1189 -0.1574) :rot (-195.0 0 0) :c :lining)
         (:box 0.05 0.313 0.024 :at (-0.0890 0.1166 -0.1542) :rot (-210.0 0 0) :c :cream)
         (:box 0.046 0.305 0.01 :at (-0.0815 0.1126 -0.1412) :rot (-210.0 0 0) :c :lining)
         (:box 0.05 0.293 0.024 :at (-0.1259 0.1067 -0.1259) :rot (-225.0 0 0) :c :cream)
         (:box 0.046 0.285 0.01 :at (-0.1153 0.1027 -0.1153) :rot (-225.0 0 0) :c :lining)
         (:box 0.05 0.268 0.024 :at (-0.1542 0.0938 -0.0890) :rot (-240.0 0 0) :c :cream)
         (:box 0.046 0.260 0.01 :at (-0.1412 0.0898 -0.0815) :rot (-240.0 0 0) :c :lining)
         (:box 0.05 0.237 0.024 :at (-0.1719 0.0787 -0.0461) :rot (-255.0 0 0) :c :cream)
         (:box 0.046 0.229 0.01 :at (-0.1574 0.0747 -0.0422) :rot (-255.0 0 0) :c :lining)
         (:box 0.05 0.205 0.024 :at (-0.1780 0.0625 -0.0000) :rot (-270.0 0 0) :c :cream)
         (:box 0.046 0.197 0.01 :at (-0.1630 0.0585 -0.0000) :rot (-270.0 0 0) :c :lining)
         (:box 0.05 0.173 0.024 :at (-0.1719 0.0463 0.0461) :rot (-285.0 0 0) :c :cream)
         (:box 0.046 0.165 0.01 :at (-0.1574 0.0423 0.0422) :rot (-285.0 0 0) :c :lining)
         (:box 0.05 0.142 0.024 :at (-0.1542 0.0312 0.0890) :rot (-300.0 0 0) :c :cream)
         (:box 0.046 0.134 0.01 :at (-0.1412 0.0272 0.0815) :rot (-300.0 0 0) :c :lining)
         (:box 0.05 0.117 0.024 :at (-0.1259 0.0183 0.1259) :rot (-315.0 0 0) :c :cream)
         (:box 0.046 0.109 0.01 :at (-0.1153 0.0143 0.1153) :rot (-315.0 0 0) :c :lining)
         (:box 0.05 0.097 0.024 :at (-0.0890 0.0084 0.1542) :rot (-330.0 0 0) :c :cream)
         (:box 0.046 0.089 0.01 :at (-0.0815 0.0044 0.1412) :rot (-330.0 0 0) :c :lining)
         (:box 0.05 0.084 0.024 :at (-0.0461 0.0021 0.1719) :rot (-345.0 0 0) :c :cream)
         (:box 0.046 0.076 0.01 :at (-0.0422 -0.0019 0.1574) :rot (-345.0 0 0) :c :lining)))

;; JILLIEL 近 KIN (decision 18, §22.2): the same column from the hips up on two long thin cream legs: the column's lower half
;; becomes a short rounded hip mass. The legs are ㄇ-shaped (decision 26, 2026-10-06: 「近戰與梟頭的腿部是從分岔點向後延伸出垂直
;; 支架，在末端才以折角往下延伸，呈現出 ㄇ 字型」): a thigh down to the fork (here: the thigh and the fork's knob), then the
;; front shank straight down from the fork, a strut running back from it and, at its end, the corner and the rear shank
;; down; LILLE-DRAW draws the shanks and the strut in the thigh's frame, each shank's tip on the floor (they stretch or
;; shrink a little with the clips' float, so the feet stay down). Arms hidden and wings drawn as :lille-jilliel.
(defbody :lille-jilliel-kin (:scale 1.0 :width 1.0 :hunch 0 :hurt-r 0.38 :hurt-h 1.8 :props (:arms 2.6)
                             :palette ((:cream #xEDE6CC) (:cream-d #xD9D0B2) (:hole #x2A2A30) (:lining #x15130F) (:nose #x6B5348) (:ridge #x4A3A31) (:band #xCFC6B0) (:skin #x7A6155) (:eye #xF2F0EC)
                                       (:pupil #x2A3124))
                             :rim (#xFFE8C8 0.14))
  (:pelvis (:cyl 0.15 0.26 :top 0.13 :seg 12 :at (0 -0.08 0) :c :cream)
           (:sphere 0.15 :stretch -0.03 :at (0 -0.2 0) :seg 12 :c :cream)                ; the rounded hip mass
           (:cyl 0.03 0.012 :at (0.05 -0.1 0.138) :rot (0 90 0) :seg 10 :c :hole)
           (:cyl 0.028 0.012 :at (-0.06 -0.2 0.135) :rot (0 90 0) :seg 10 :c :hole)
           (:cyl 0.03 0.012 :at (0.142 -0.12 0) :rot (0 0 90) :seg 10 :c :hole)
           (:cyl 0.03 0.012 :at (-0.143 -0.16 0) :rot (0 0 90) :seg 10 :c :hole))
  (:spine (:cyl 0.13 0.3 :top 0.15 :seg 12 :at (0 0.1 0) :c :cream)
          (:cyl 0.026 0.012 :at (-0.05 0.12 0.138) :rot (0 90 0) :seg 10 :c :hole))
  (:chest (:cyl 0.16 0.42 :top 0.19 :seg 12 :at (0 0.14 0) :c :cream)
          (:cyl 0.032 0.012 :at (0.07 0.24 0.178) :rot (0 90 0) :seg 10 :c :hole)
          (:cyl 0.032 0.012 :at (-0.075 0.2 0.176) :rot (0 90 0) :seg 10 :c :hole)
          (:cyl 0.03 0.012 :at (0.0 0.06 0.17) :rot (0 90 0) :seg 10 :c :hole)
          (:cyl 0.03 0.012 :at (0.168 0.16 0.0) :rot (0 0 90) :seg 10 :c :hole)
          (:cyl 0.03 0.012 :at (-0.17 0.12 0.0) :rot (0 0 90) :seg 10 :c :hole)
          (:cyl 0.03 0.012 :at (0.05 0.2 -0.18) :rot (0 90 0) :seg 10 :c :hole)
          (:sphere 0.09 :stretch 0.04 :at (0 0.3 -0.13) :rot (0 0 90) :seg 10 :c :cream-d))
  (:neck (:cyl 0.13 0.15 :seg 12 :at (0 0.06 0) :c :cream :tag :jl-head))
  ;; the top of the column (decision 57, 2026-10-08): a collar round the head, its rim cut on a slant (low at the front,
  ;; at the chin; high behind, a little over the crown), black inside; the head brown, narrow (x0.8), cut by two pale rings
  ;; through its centre tilted 15 deg to each side (their rims the crown's bands, crossing on top), both eyes open, a darker
  ;; nose a trapezoid in profile (narrow at the top), a white cylinder over the face's lower half, the chin on a round knob
  ;; (tagged: the revival's headless column hides the head, keeps the collar)
  ;; (the collar's outside on the column's top radius, 0.19 m; the head the base form's size, set 3 cm into the collar: the
  ;; user, 2026-10-08)
  (:head (:sphere 0.086 :at (0 0.14 0) :seg 16 :squash (0.8 1 1) :c :skin :tag :jl-head)        ; the base form's head size
         (:cyl 0.0885 0.017 :at (0 0.14 0) :rot (15 0 90) :seg 24 :squash (0.8 1 1) :c :band :tag :jl-head)        ; two rings through his centre,
         (:cyl 0.0885 0.017 :at (0 0.14 0) :rot (-15 0 90) :seg 24 :squash (0.8 1 1) :c :band :tag :jl-head)       ;  their rims the crown's pale bands
         (:box 0.018 0.008 0.003 :at (0.019 0.155 0.083) :c :eye :tag :jl-head)                    ; both eyes open
         (:box 0.018 0.008 0.003 :at (-0.019 0.155 0.083) :c :eye :tag :jl-head)
         (:box 0.008 0.008 0.003 :at (0.019 0.155 0.085) :c :pupil :tag :jl-head)
         (:box 0.008 0.008 0.003 :at (-0.019 0.155 0.085) :c :pupil :tag :jl-head)
         (:wedge 0.018 0.044 0.016 :at (0 0.128 0.105) :rot (180 0 0) :c :nose :ink 0.6 :tag :jl-head)   ; (the slope ...
         (:box 0.018 0.044 0.024 :at (0 0.128 0.085) :c :nose :ink 0.6 :tag :jl-head)                    ;  on a flat: a trapezoid, the nose)
         (:sphere 0.032 :at (0 0.052 0.072) :seg 10 :c :cream :tag :jl-head)                   ; the chin knob
         (:cyl 0.084 0.06 :at (0 0.08 0) :seg 18 :squash (0.8 1 1) :c :cream :tag :jl-head)   ; the white cylinder over the face's lower half
         (:box 0.05 0.080 0.024 :at (0.0000 0.0000 0.1780) :rot (-0.0 0 0) :c :cream)
         (:box 0.046 0.072 0.01 :at (0.0000 -0.0040 0.1630) :rot (-0.0 0 0) :c :lining)
         (:box 0.05 0.084 0.024 :at (0.0461 0.0021 0.1719) :rot (-15.0 0 0) :c :cream)
         (:box 0.046 0.076 0.01 :at (0.0422 -0.0019 0.1574) :rot (-15.0 0 0) :c :lining)
         (:box 0.05 0.097 0.024 :at (0.0890 0.0084 0.1542) :rot (-30.0 0 0) :c :cream)
         (:box 0.046 0.089 0.01 :at (0.0815 0.0044 0.1412) :rot (-30.0 0 0) :c :lining)
         (:box 0.05 0.117 0.024 :at (0.1259 0.0183 0.1259) :rot (-45.0 0 0) :c :cream)
         (:box 0.046 0.109 0.01 :at (0.1153 0.0143 0.1153) :rot (-45.0 0 0) :c :lining)
         (:box 0.05 0.142 0.024 :at (0.1542 0.0312 0.0890) :rot (-60.0 0 0) :c :cream)
         (:box 0.046 0.134 0.01 :at (0.1412 0.0272 0.0815) :rot (-60.0 0 0) :c :lining)
         (:box 0.05 0.173 0.024 :at (0.1719 0.0463 0.0461) :rot (-75.0 0 0) :c :cream)
         (:box 0.046 0.165 0.01 :at (0.1574 0.0423 0.0422) :rot (-75.0 0 0) :c :lining)
         (:box 0.05 0.205 0.024 :at (0.1780 0.0625 0.0000) :rot (-90.0 0 0) :c :cream)
         (:box 0.046 0.197 0.01 :at (0.1630 0.0585 0.0000) :rot (-90.0 0 0) :c :lining)
         (:box 0.05 0.237 0.024 :at (0.1719 0.0787 -0.0461) :rot (-105.0 0 0) :c :cream)
         (:box 0.046 0.229 0.01 :at (0.1574 0.0747 -0.0422) :rot (-105.0 0 0) :c :lining)
         (:box 0.05 0.267 0.024 :at (0.1542 0.0937 -0.0890) :rot (-120.0 0 0) :c :cream)
         (:box 0.046 0.259 0.01 :at (0.1412 0.0897 -0.0815) :rot (-120.0 0 0) :c :lining)
         (:box 0.05 0.293 0.024 :at (0.1259 0.1067 -0.1259) :rot (-135.0 0 0) :c :cream)
         (:box 0.046 0.285 0.01 :at (0.1153 0.1027 -0.1153) :rot (-135.0 0 0) :c :lining)
         (:box 0.05 0.313 0.024 :at (0.0890 0.1166 -0.1542) :rot (-150.0 0 0) :c :cream)
         (:box 0.046 0.305 0.01 :at (0.0815 0.1126 -0.1412) :rot (-150.0 0 0) :c :lining)
         (:box 0.05 0.326 0.024 :at (0.0461 0.1229 -0.1719) :rot (-165.0 0 0) :c :cream)
         (:box 0.046 0.318 0.01 :at (0.0422 0.1189 -0.1574) :rot (-165.0 0 0) :c :lining)
         (:box 0.05 0.330 0.024 :at (0.0000 0.1250 -0.1780) :rot (-180.0 0 0) :c :cream)
         (:box 0.046 0.322 0.01 :at (0.0000 0.1210 -0.1630) :rot (-180.0 0 0) :c :lining)
         (:box 0.05 0.326 0.024 :at (-0.0461 0.1229 -0.1719) :rot (-195.0 0 0) :c :cream)
         (:box 0.046 0.318 0.01 :at (-0.0422 0.1189 -0.1574) :rot (-195.0 0 0) :c :lining)
         (:box 0.05 0.313 0.024 :at (-0.0890 0.1166 -0.1542) :rot (-210.0 0 0) :c :cream)
         (:box 0.046 0.305 0.01 :at (-0.0815 0.1126 -0.1412) :rot (-210.0 0 0) :c :lining)
         (:box 0.05 0.293 0.024 :at (-0.1259 0.1067 -0.1259) :rot (-225.0 0 0) :c :cream)
         (:box 0.046 0.285 0.01 :at (-0.1153 0.1027 -0.1153) :rot (-225.0 0 0) :c :lining)
         (:box 0.05 0.268 0.024 :at (-0.1542 0.0938 -0.0890) :rot (-240.0 0 0) :c :cream)
         (:box 0.046 0.260 0.01 :at (-0.1412 0.0898 -0.0815) :rot (-240.0 0 0) :c :lining)
         (:box 0.05 0.237 0.024 :at (-0.1719 0.0787 -0.0461) :rot (-255.0 0 0) :c :cream)
         (:box 0.046 0.229 0.01 :at (-0.1574 0.0747 -0.0422) :rot (-255.0 0 0) :c :lining)
         (:box 0.05 0.205 0.024 :at (-0.1780 0.0625 -0.0000) :rot (-270.0 0 0) :c :cream)
         (:box 0.046 0.197 0.01 :at (-0.1630 0.0585 -0.0000) :rot (-270.0 0 0) :c :lining)
         (:box 0.05 0.173 0.024 :at (-0.1719 0.0463 0.0461) :rot (-285.0 0 0) :c :cream)
         (:box 0.046 0.165 0.01 :at (-0.1574 0.0423 0.0422) :rot (-285.0 0 0) :c :lining)
         (:box 0.05 0.142 0.024 :at (-0.1542 0.0312 0.0890) :rot (-300.0 0 0) :c :cream)
         (:box 0.046 0.134 0.01 :at (-0.1412 0.0272 0.0815) :rot (-300.0 0 0) :c :lining)
         (:box 0.05 0.117 0.024 :at (-0.1259 0.0183 0.1259) :rot (-315.0 0 0) :c :cream)
         (:box 0.046 0.109 0.01 :at (-0.1153 0.0143 0.1153) :rot (-315.0 0 0) :c :lining)
         (:box 0.05 0.097 0.024 :at (-0.0890 0.0084 0.1542) :rot (-330.0 0 0) :c :cream)
         (:box 0.046 0.089 0.01 :at (-0.0815 0.0044 0.1412) :rot (-330.0 0 0) :c :lining)
         (:box 0.05 0.084 0.024 :at (-0.0461 0.0021 0.1719) :rot (-345.0 0 0) :c :cream)
         (:box 0.046 0.076 0.01 :at (-0.0422 -0.0019 0.1574) :rot (-345.0 0 0) :c :lining))
  ;; the thighs (0.44 m) to the fork's knob; the ㄇ below it is LILLE-DRAW's (%LB-LEGS)
  (:thigh-r (:cyl 0.042 0.46 :top 0.055 :seg 8 :at (0 -0.22 0) :c :cream) (:sphere 0.05 :seg 8 :at (0 -0.44 0) :c :cream-d))
  (:thigh-l (:cyl 0.042 0.46 :top 0.055 :seg 8 :at (0 -0.22 0) :c :cream) (:sphere 0.05 :seg 8 :at (0 -0.44 0) :c :cream-d)))

;; 真の姿 the owl, built on KIN's model (decision 27, 2026-10-06: 「梟頭型態的建模在原作中會呈現以目前的近戰型態為基礎，並將頭部換成
;; 長頸梟頭與增加額外的手臂」): KIN's column (the rounded hip mass, the column widening to its top, its holes quiet in a cold
;; shade) in the owl's white (the sheet's §5.4: white, gold only on the wings, the halo and the glow), the ribbon tendrils
;; trailing from the hips, the ㄇ legs (the thighs here, the shanks and the strut drawn by LILLE-DRAW as KIN's), a shaggy fur
;; ruff on the column's top and, in place of Jilliel's face, the segmented S-neck (belly plates in front, a fur crest behind)
;; to a tiny barn-owl face (a pale round facial disc, two big dark eyes, a small hooked beak, the hair swept back into the
;; neck fur). Its long thin arms (x2.2) are the rig's: the claws are the hands (the strike points). They are decision 27's
;; "extra arms" (KIN has none drawn; a second cosmetic pair was cut, the user 2026-10-06: 「梟頭狀態多了一組手臂」); LILLE-DRAW
;; adds the eight gold wings and the small spiked halo (it cracks when Trompete is sealed).
(defbody :lille-shin (:scale 1.0 :width 1.0 :hunch 0 :hurt-r 0.38 :hurt-h 1.8 :props (:arms 2.2 :legs 1.5)
                      :palette ((:white #xECECE8) (:shade #xBCC1CC) (:fur #xD8DCE4) (:face #xF0ECE4) (:gold #xB89A5A)
                                (:gold-l #xC2A866) (:ink #x16161E) (:hole #x2A2A30) (:beak #x8C8E96))
                      :rim (#xFFE8C8 0.14))
  (:pelvis (:cyl 0.15 0.26 :top 0.13 :seg 12 :at (0 -0.08 0) :c :white)
           (:sphere 0.15 :stretch -0.03 :at (0 -0.2 0) :seg 12 :c :white)                ; the rounded hip mass
           (:cyl 0.03 0.012 :at (0.05 -0.1 0.138) :rot (0 90 0) :seg 10 :c :shade)
           (:cyl 0.028 0.012 :at (-0.06 -0.2 0.135) :rot (0 90 0) :seg 10 :c :shade)
           (:cyl 0.03 0.012 :at (0.142 -0.12 0) :rot (0 0 90) :seg 10 :c :shade)
           (:cyl 0.03 0.012 :at (-0.143 -0.16 0) :rot (0 0 90) :seg 10 :c :shade)
           (:box 0.02 0.55 0.004 :at (0.1 -0.3 -0.3) :rot (0 30 0) :c :fur)                  ; ribbon tendrils
           (:box 0.02 0.55 0.004 :at (-0.1 -0.3 -0.3) :rot (0 30 0) :c :fur)
           (:box 0.02 0.45 0.004 :at (0 -0.26 -0.32) :rot (0 36 0) :c :fur))
  (:spine (:cyl 0.13 0.3 :top 0.15 :seg 12 :at (0 0.1 0) :c :white)
          (:cyl 0.026 0.012 :at (-0.05 0.12 0.138) :rot (0 90 0) :seg 10 :c :shade))
  (:chest (:cyl 0.16 0.42 :top 0.19 :seg 12 :at (0 0.14 0) :c :white)
          (:cyl 0.032 0.012 :at (0.07 0.2 0.172) :rot (0 90 0) :seg 10 :c :shade)
          (:cyl 0.032 0.012 :at (-0.075 0.16 0.17) :rot (0 90 0) :seg 10 :c :shade)
          (:cyl 0.03 0.012 :at (0.0 0.04 0.168) :rot (0 90 0) :seg 10 :c :shade)
          (:cyl 0.03 0.012 :at (0.05 0.2 -0.18) :rot (0 90 0) :seg 10 :c :shade)
          (:sphere 0.2 :stretch -0.06 :at (0 0.36 -0.01) :seg 10 :c :fur)                 ; the fur ruff, shaggy, on the top
          (:cone 0.06 0.14 :at (0.2 0.37 0) :rot (0 0 -80) :seg 4 :c :fur) (:cone 0.06 0.14 :at (-0.2 0.37 0) :rot (0 0 80) :seg 4 :c :fur)
          (:cone 0.06 0.14 :at (0.14 0.39 0.14) :rot (0 -40 -50) :seg 4 :c :fur) (:cone 0.06 0.14 :at (-0.14 0.39 0.14) :rot (0 -40 50) :seg 4 :c :fur)
          (:cone 0.06 0.14 :at (0.12 0.39 -0.16) :rot (0 40 -50) :seg 4 :c :fur) (:cone 0.06 0.14 :at (-0.12 0.39 -0.16) :rot (0 40 50) :seg 4 :c :fur)
          (:cone 0.06 0.14 :at (0 0.39 0.19) :rot (0 -70 0) :seg 4 :c :fur) (:cone 0.06 0.14 :at (0 0.39 -0.2) :rot (0 70 0) :seg 4 :c :fur)
          (:sphere 0.09 :stretch 0.04 :at (0 0.3 -0.13) :rot (0 0 90) :seg 10 :c :fur))   ; the wings' root, behind the top
  (:neck (:cyl 0.05 0.16 :at (0 0.06 0) :seg 8 :c :white))
  ;; the S-neck (five segments rising back, then forward and over), then the face
  (:head (:cyl 0.046 0.186 :top 0.041 :at (0 0.075 -0.035) :rot (0 25.0 0) :seg 8 :c :white)
         (:box 0.05 0.012 0.02 :at (0 0.092 0.0) :rot (0 25.0 0) :c :shade)
         (:box 0.016 0.149 0.03 :at (0 0.056 -0.077) :rot (0 25.0 0) :c :fur)
         (:cyl 0.042 0.181 :top 0.038 :at (0 0.23 -0.08) :rot (0 7.1 0) :seg 8 :c :white)
         (:box 0.05 0.012 0.02 :at (0 0.234 -0.045) :rot (0 7.1 0) :c :shade)
         (:box 0.016 0.145 0.03 :at (0 0.225 -0.122) :rot (0 7.1 0) :c :fur)
         (:cyl 0.038 0.178 :top 0.034 :at (0 0.385 -0.065) :rot (0 -18.4 0) :seg 8 :c :white)
         (:box 0.05 0.012 0.02 :at (0 0.375 -0.034) :rot (0 -18.4 0) :c :shade)
         (:box 0.016 0.142 0.03 :at (0 0.397 -0.101) :rot (0 -18.4 0) :c :fur)
         (:cyl 0.034 0.169 :top 0.031 :at (0 0.515 0.01) :rot (0 -42.3 0) :seg 8 :c :white)
         (:box 0.05 0.012 0.02 :at (0 0.496 0.031) :rot (0 -42.3 0) :c :shade)
         (:box 0.016 0.134 0.03 :at (0 0.538 -0.015) :rot (0 -42.3 0) :c :fur)
         (:cyl 0.031 0.141 :top 0.028 :at (0 0.595 0.115) :rot (0 -65.6 0) :seg 8 :c :white)
         (:box 0.05 0.012 0.02 :at (0 0.571 0.126) :rot (0 -65.6 0) :c :shade)
         (:box 0.016 0.109 0.03 :at (0 0.623 0.102) :rot (0 -65.6 0) :c :fur)
         ;; the tiny barn-owl face, looking ahead from the top of the hook
         (:sphere 0.068 :at (0 0.62 0.2) :seg 10 :c :white)                                 ; the skull
         (:box 0.05 0.03 0.1 :at (0 0.665 0.15) :rot (0 -20 0) :c :fur)                      ; the hair swept back
         (:cyl 0.084 0.016 :at (0 0.615 0.252) :rot (0 90 0) :seg 14 :c :shade)              ; the disc's dark rim
         (:cyl 0.076 0.02 :at (0 0.615 0.262) :rot (0 90 0) :seg 14 :c :face)                ; the pale facial disc
         (:box 0.012 0.07 0.01 :at (0 0.625 0.274) :c :fur)                                  ; the heart's middle ridge
         (:sphere 0.022 :at (0.033 0.628 0.27) :seg 8 :c :ink) (:sphere 0.022 :at (-0.033 0.628 0.27) :seg 8 :c :ink)
         (:box 0.008 0.008 0.004 :at (0.028 0.636 0.291) :c :face :ink 0) (:box 0.008 0.008 0.004 :at (-0.038 0.636 0.291) :c :face :ink 0)
         (:cone 0.013 0.045 :at (0 0.585 0.282) :rot (0 200 0) :seg 4 :c :beak))           ; the small hooked beak
  (:shoulder-r (:sphere 0.055 :c :white))
  (:shoulder-l (:sphere 0.055 :c :white))
  (:upper-arm-r (:cyl 0.032 0.66 :top 0.027 :seg 8 :at (0 -0.33 0) :c :white))
  (:upper-arm-l (:cyl 0.032 0.66 :top 0.027 :seg 8 :at (0 -0.33 0) :c :white))
  (:lower-arm-r (:cyl 0.027 0.6 :top 0.022 :seg 8 :at (0 -0.3 0) :c :white))
  (:lower-arm-l (:cyl 0.027 0.6 :top 0.022 :seg 8 :at (0 -0.3 0) :c :white))
  (:hand-r (:box 0.05 0.12 0.02 :at (0 -0.06 0) :c :white) (:box 0.008 0.1 0.008 :at (0.015 -0.16 0) :c :shade)
           (:box 0.008 0.09 0.008 :at (-0.012 -0.15 0) :c :shade))
  (:hand-l (:box 0.05 0.12 0.02 :at (0 -0.06 0) :c :white) (:box 0.008 0.1 0.008 :at (-0.015 -0.16 0) :c :shade)
           (:box 0.008 0.09 0.008 :at (0.012 -0.15 0) :c :shade))
  ;; the thighs (0.44 m, KIN's) to the fork's knob; the ㄇ below it is LILLE-DRAW's (%LB-LEGS)
  (:thigh-r (:cyl 0.04 0.46 :top 0.05 :seg 8 :at (0 -0.22 0) :c :white) (:sphere 0.048 :seg 8 :at (0 -0.44 0) :c :shade))
  (:thigh-l (:cyl 0.04 0.46 :top 0.05 :seg 8 :at (0 -0.22 0) :c :white) (:sphere 0.048 :seg 8 :at (0 -0.44 0) :c :shade)))

;;; ---------------------------------------------------------------- Diagramm and the props
;; ディアグラム DIAGRAMM: 2.4 m. The grip at the sleeve's rear: the barrel runs 1.75 m to the muzzle cross (the weapon's
;; length: the tip the FK test measures), 0.65 m back to the tall black plank across the rear (the butt, measured at a
;; negative weapon-length point, *LB-BUTT*); the green fur sleeve over the barrel's rear part (two dark ports, jagged fur
;; at its ends), a dial knob on the plank
(defparameter *lb-butt* 0.6 "Diagramm: the plank's strike point, metres behind the grip (the weapon frame's -Y; the FK test).")
(defweapon :diagramm (:length 1.75 :base 0.3)
  (:solid (mbc mb #x16161E)
          (with-xform (mb (xform :y 0.55)) (mb-cylinder mb 0.024 2.4 :segments 6))           ; the barrel, -0.65 .. 1.75
          (with-xform (mb (xform :y 1.72)) (mb-box mb 0.2 0.07 0.05) (mb-box mb 0.05 0.07 0.2))   ; the muzzle cross
          (with-xform (mb (xform :y -0.6 :z 0.15)) (mb-box mb 0.035 0.1 1.2))                 ; the plank, across the rear
          (with-xform (mb (xform :y -0.62 :z -0.38)) (mb-box mb 0.12 0.08 0.04))              ; its two lower plates
          (mbc mb #xBCC1CC) (with-xform (mb (xform :y -0.56 :z 0.42 :x 0.03)) (mb-cylinder mb 0.03 0.02 :segments 8)))
  (:solid (mbc mb #x434D3B) (with-xform (mb (xform :y 0.2)) (mb-cylinder mb 0.1 0.6 :segments 8))      ; the fur sleeve
          (with-xform (mb (xform :y 0.5 :x 0.1 :roll -1.4)) (mb-cone mb 0.03 0.06 :segments 4))      ; jagged fur
          (with-xform (mb (xform :y -0.09 :x -0.1 :roll 1.6)) (mb-cone mb 0.03 0.06 :segments 4))
          (mbc mb #x2A3124) (with-xform (mb (xform :y 0.3 :z 0.1)) (mb-box mb 0.03 0.03 0.012))
          (with-xform (mb (xform :y 0.1 :z 0.1)) (mb-box mb 0.03 0.03 0.012))))

;;; the props' mesh helpers (load time only: they allocate)
(defun lb-plate (mb pts th &optional (z0 0.0))
  "A flat plate: the convex polygon PTS ((x y) ...) in the XY plane, TH thick round Z0: both faces and the rim."
  (let* ((n (length pts)) (cx (/ (reduce #'+ pts :key #'first) n)) (cy (/ (reduce #'+ pts :key #'second) n))
         (c (list cx cy z0)) (h (* 0.5 th))
         (f (mapcar (lambda (p) (v3 (first p) (second p) (+ z0 h))) pts))
         (b (mapcar (lambda (p) (v3 (first p) (second p) (- z0 h))) pts)))
    (mb-poly-out mb f :center c) (mb-poly-out mb b :center c)
    (dotimes (i n)
      (let ((j (mod (1+ i) n))) (mb-poly-out mb (list (nth i f) (nth j f) (nth j b) (nth i b)) :center c)))))

(defun lb-oval (mb cx cy rx ry th &optional (n 12))
  "An oval plate at (CX CY) in the XY plane, radii RX RY, TH thick."
  (lb-plate mb (loop for i below n collect (let ((a (* 2 pi (/ i n)))) (list (+ cx (* rx (cos a))) (+ cy (* ry (sin a)))))) th))

(defun lb-ring (mb r0 r1 th &key (n 24) (from 0) (to n) (y 0.0))
  "A flat ring (an annulus prism) in the XZ plane at height Y, radii R0..R1, TH thick, segments FROM..TO of N."
  (loop for i from from below to
        do (let* ((a0 (* 2 pi (/ i n))) (a1 (* 2 pi (/ (1+ i) n))) (h (* 0.5 th))
                  (p (lambda (r a yy) (v3 (* r (cos a)) yy (* r (sin a)))))
                  (c (list (* 0.5 (+ r0 r1) (cos (* 0.5 (+ a0 a1)))) y (* 0.5 (+ r0 r1) (sin (* 0.5 (+ a0 a1)))))))
             (flet ((q (ra aa rb ab y0 y1) (mb-poly-out mb (list (funcall p ra aa y0) (funcall p rb ab y0) (funcall p rb ab y1)
                                                                 (funcall p ra aa y1)) :center c)))
               (q r0 a0 r0 a1 (- y h) (+ y h)) (q r1 a0 r1 a1 (- y h) (+ y h))
               (mb-poly-out mb (list (funcall p r0 a0 (+ y h)) (funcall p r1 a0 (+ y h)) (funcall p r1 a1 (+ y h))
                                     (funcall p r0 a1 (+ y h))) :center c)
               (mb-poly-out mb (list (funcall p r0 a0 (- y h)) (funcall p r1 a0 (- y h)) (funcall p r1 a1 (- y h))
                                     (funcall p r0 a1 (- y h))) :center c)))))

;; a wing blade (decision 19: the refs' leaf), unit length along +Y from its root to its point, the flat face along Z: narrow
;; at the root, widest at the middle, a long point; its centreline bows toward +X (the trailing edge, torn into four teeth,
;; and the tip comes back onto the root-tip chord: a drawn tip is exactly where the frame puts it); three oval holes along it
;; (the 24 muzzles). Translucent since decision 27 (2026-10-06: 「把翅膀調整成半透明以免遮擋視線」): two meshes per look, the
;; GLASS (the leaf's two faces with the holes cut through, drawn see-through) and the RIM (a dark band round the outline, the
;; teeth and a ring round each hole: what keeps it reading as a holed blade; see-through as well since decision 32).
;; Jointed since decision 32 (2026-10-06: 「每片翅膀改成中間加 2 節可以彎折的連接觸」): the blade is cut at 1/3 and 2/3 of its
;; length into three SEGMENTS (root, middle, tip), each its own mesh in its own frame: segment I is the leaf's part from
;; I/3 to (I+1)/3, moved down by I/3 so its joint (the pivot, on the root-tip chord: x 0) is its origin; LILLE-DRAW chains
;; the three frames (each bends at its pivot). One hole and one or two teeth per segment; a cross band at each cut and a
;; pin at each pivot (the joint). Load time only.
(defparameter *lb-wing-bow* 0.07 "The blade's centreline bow at its middle (unit length).")
(defparameter *lb-wing-stations* '((0.0 0.03 0.03) (0.08 0.06 0.07) (0.2 0.1 0.12) (0.35 0.125 0.15) (0.5 0.13 0.155)
                                   (0.65 0.115 0.14) (0.8 0.08 0.1) (0.91 0.042 0.05) (1.0 0.0 0.0))
  "The blade's outline: y, the leading (-x) and the trailing (+x) half-widths off the bowed centreline.")
(defparameter *lb-wing-teeth* '(0.19 0.40 0.53 0.71)
  "Where the trailing edge's teeth start (unit length; each spans y-0.03..y+0.11, inside one segment; were 0.3 / 0.47 / 0.63
/ 0.77 before the joints, decision 32).")
(defparameter *lb-wing-holes* '((0.2 0.045 0.065) (0.5 0.05 0.075) (0.79 0.038 0.052))
  "y rx ry (unit length), on the centreline: one per segment (were 0.36 / 0.55 / 0.73 before the joints, decision 32).")
(defparameter *lb-wing-band* 0.016 "The rim's band round the outline and the holes (unit length).")
(defparameter *lb-wing-cuts* '(0.0 0.33333334 0.6666667 1.0) "The segments' ends (unit length): the joints at 1/3 and 2/3.")
(defun lb-wing-c (y) (* *lb-wing-bow* 4 y (- 1 y)))
(defun lb-wing-half (y col)
  "The half-width at Y off the centreline: COL 1 the leading side, 2 the trailing side (the stations interpolated)."
  (let ((lo (find-if (lambda (r) (>= (first r) y)) *lb-wing-stations*))
        (hi (find-if (lambda (r) (<= (first r) y)) *lb-wing-stations* :from-end t)))
    (if (or (eq lo hi) (= (first lo) (first hi))) (nth col lo)
        (+ (nth col hi) (* (- y (first hi)) (/ (- (nth col lo) (nth col hi)) (- (first lo) (first hi))))))))
(defun lb-wing-edge (y) "The trailing edge's x at Y." (+ (lb-wing-c y) (lb-wing-half y 2)))
(defun lb-wing-lead (y) "The leading edge's x at Y." (- (lb-wing-c y) (lb-wing-half y 1)))
(defun lb-wing-hole-x (y) "A hole's centre x at Y." (+ 0.01 (lb-wing-c y)))
(defun lb-wing-ys (ya yb)
  "The glass's rows from YA to YB: every 0.025, the stations, finer through each hole (its ends exact, so a row is in or
out), and the segment's ends."
  (sort (remove-duplicates
         (remove-if-not (lambda (y) (<= (- ya 1e-5) y (+ yb 1e-5)))
                        (append (list ya yb) (loop for i to 40 collect (/ i 40.0)) (mapcar #'first *lb-wing-stations*)
                                (loop for (y nil ry) in *lb-wing-holes* append (loop for i to 12 collect (+ (- y ry) (* (/ i 12.0) 2 ry))))))
         :test (lambda (a b) (< (abs (- a b)) 1e-4)))
        #'<))
(defun lb-wing-seg (seg) "Segment SEG's ends (values ya yb)." (values (nth seg *lb-wing-cuts*) (nth (1+ seg) *lb-wing-cuts*)))
(defun lb-shift (pts y0) "PTS ((x y) ...) moved down by Y0 (into a segment's frame)." (mapcar (lambda (p) (list (first p) (- (second p) y0))) pts))
(defun lb-face (mb pts z up)
  "One face of the glass: the convex polygon PTS ((x y) ...) at Z, facing +Z when UP else -Z (no rim: a single layer)."
  (let ((pts (remove-duplicates pts :test (lambda (a b) (< (+ (abs (- (first a) (first b))) (abs (- (second a) (second b)))) 1e-5)))))
    (when (>= (length pts) 3)
      (let ((cx (/ (reduce #'+ pts :key #'first) (length pts))) (cy (/ (reduce #'+ pts :key #'second) (length pts))))
        (mb-poly-out mb (mapcar (lambda (p) (v3 (first p) (second p) z)) pts) :center (list cx cy (if up (- z 1) (+ z 1))))))))
(defun lb-wing-glass (mb body seg)
  "Segment SEG of the see-through leaf: both faces, row by row, its hole cut through (a row inside a hole splits in two)."
  (mbc mb body)
  (multiple-value-bind (ya yb) (lb-wing-seg seg)
    (let ((h 0.008))
      (loop for (y0 y1) on (lb-wing-ys ya yb) while y1
            do (let* ((ym (* 0.5 (+ y0 y1)))
                      (hole (find-if (lambda (hh) (< (abs (- ym (first hh))) (third hh))) *lb-wing-holes*))
                      (spans
                        (if hole
                            (destructuring-bind (hy rx ry) hole
                              (flet ((hw (y) (* rx (sqrt (max 0.0 (- 1 (expt (/ (- y hy) ry) 2)))))))
                                (list (list (list (lb-wing-lead y0) y0) (list (- (lb-wing-hole-x y0) (hw y0)) y0)
                                            (list (- (lb-wing-hole-x y1) (hw y1)) y1) (list (lb-wing-lead y1) y1))
                                      (list (list (+ (lb-wing-hole-x y0) (hw y0)) y0) (list (lb-wing-edge y0) y0)
                                            (list (lb-wing-edge y1) y1) (list (+ (lb-wing-hole-x y1) (hw y1)) y1)))))
                            (list (list (list (lb-wing-lead y0) y0) (list (lb-wing-edge y0) y0)
                                        (list (lb-wing-edge y1) y1) (list (lb-wing-lead y1) y1))))))
                 (dolist (q spans) (let ((q (lb-shift q ya))) (lb-face mb q h t) (lb-face mb q (- h) nil))))))))
(defun lb-wing-rim (mb dark hole-fill seg)
  "Segment SEG's rim: a band inside the outline (leading and trailing edges), its teeth on the trailing edge, a ring round
its hole, a cross band at each cut and a pin at the pivot it hangs from (the joints); HOLE-FILL (a colour, NIJUSHI-KO's
tell) fills the hole with light."
  (mbc mb dark)
  (multiple-value-bind (ya yb) (lb-wing-seg seg)
    (let ((bw *lb-wing-band*) (th 0.024))
      (flet ((plate (pts &optional (th th)) (lb-plate mb (lb-shift pts ya) th)))
        (loop for (y0 y1) on (lb-wing-ys ya yb) while y1
              do (flet ((w (y) (min bw (* 0.5 (+ (lb-wing-half y 1) (lb-wing-half y 2)))))
                        (band (x0 x1 d0 d1)
                          (let ((q (remove-duplicates (list (list x0 y0) (list (+ x0 d0) y0) (list (+ x1 d1) y1) (list x1 y1))
                                                      :test (lambda (a b) (< (+ (abs (- (first a) (first b))) (abs (- (second a) (second b)))) 1e-5)))))
                            (when (>= (length q) 3) (plate q)))))
                   (band (lb-wing-lead y0) (lb-wing-lead y1) (w y0) (w y1))
                   (band (lb-wing-edge y0) (lb-wing-edge y1) (- (w y0)) (- (w y1)))))
        (dolist (y *lb-wing-teeth*)
          (when (<= ya y yb)
            (let ((e0 (lb-wing-edge y)) (e1 (lb-wing-edge (+ y 0.11))))
              (plate (list (list (- e0 0.02) y) (list (- e1 0.02) (+ y 0.11)) (list (+ e0 0.07) (- y 0.03)))))))
        (dolist (yc (list ya yb))                         ; the joints: a cross band inside each cut (not the root, not the point)
          (when (< 0.01 yc 0.99)
            (let ((y1 (if (= yc ya) (+ yc (* 1.4 bw)) (- yc (* 1.4 bw)))))
              (plate (list (list (lb-wing-lead yc) yc) (list (lb-wing-edge yc) yc) (list (lb-wing-edge y1) y1) (list (lb-wing-lead y1) y1))))))
        (when (> ya 0.01)                                 ; ... and the pin at the pivot this segment hangs from
          (lb-oval mb 0.0 0.0 0.024 0.024 0.04 12))
        (dolist (hh *lb-wing-holes*)
          (destructuring-bind (y rx ry) hh
            (when (< ya y yb)
              (let ((x (lb-wing-hole-x y)) (n 16))
                (dotimes (i n)
                  (let ((a0 (* 2 pi (/ i n))) (a1 (* 2 pi (/ (1+ i) n))))
                    (flet ((pt (a r) (list (+ x (* (+ rx r) (cos a))) (+ y (* (+ ry r) (sin a))))))
                      (plate (list (pt a0 0) (pt a0 (* 0.8 bw)) (pt a1 (* 0.8 bw)) (pt a1 0))))))
                (when hole-fill
                  (mbc mb hole-fill) (lb-oval mb x (- y ya) rx ry 0.02 16) (mbc mb dark))))))))))
;; per look, three glass segments and three rim segments (I = 0 root, 1 middle, 2 tip)
(defweapon :lb-wing-0 (:length 1.0) (:solid :ink 0 (lb-wing-glass mb #x6E9A80 0)))   ; Jilliel's glass (muted jade)
(defweapon :lb-wing-1 (:length 1.0) (:solid :ink 0 (lb-wing-glass mb #x6E9A80 1)))
(defweapon :lb-wing-2 (:length 1.0) (:solid :ink 0 (lb-wing-glass mb #x6E9A80 2)))
(defweapon :lb-wing-rim-0 (:length 1.0) (:solid :ink 0 (lb-wing-rim mb #x2F4A3C nil 0)))   ; ... its rim (the outline, teeth,
(defweapon :lb-wing-rim-1 (:length 1.0) (:solid :ink 0 (lb-wing-rim mb #x2F4A3C nil 1)))   ;  hole rings and joints)
(defweapon :lb-wing-rim-2 (:length 1.0) (:solid :ink 0 (lb-wing-rim mb #x2F4A3C nil 2)))
(defweapon :lb-wing-lit-0 (:length 1.0) (:solid :ink 0 (lb-wing-rim mb #x2F4A3C #xEAF4EE 0)))   ; NIJUSHI-KO's tell: the
(defweapon :lb-wing-lit-1 (:length 1.0) (:solid :ink 0 (lb-wing-rim mb #x2F4A3C #xEAF4EE 1)))   ;  rim with the holes lit
(defweapon :lb-wing-lit-2 (:length 1.0) (:solid :ink 0 (lb-wing-rim mb #x2F4A3C #xEAF4EE 2)))
(defweapon :lb-wing-gold-0 (:length 1.0) (:solid :ink 0 (lb-wing-glass mb #xB89A5A 0)))   ; the owl's glass (#B89A5A,
(defweapon :lb-wing-gold-1 (:length 1.0) (:solid :ink 0 (lb-wing-glass mb #xB89A5A 1)))   ;  decision 11)
(defweapon :lb-wing-gold-2 (:length 1.0) (:solid :ink 0 (lb-wing-glass mb #xB89A5A 2)))
(defweapon :lb-wing-gold-rim-0 (:length 1.0) (:solid :ink 0 (lb-wing-rim mb #x8A7038 nil 0)))   ; ... its rim (a darker
(defweapon :lb-wing-gold-rim-1 (:length 1.0) (:solid :ink 0 (lb-wing-rim mb #x8A7038 nil 1)))   ;  step of the same hue)
(defweapon :lb-wing-gold-rim-2 (:length 1.0) (:solid :ink 0 (lb-wing-rim mb #x8A7038 nil 2)))
;; the ㄇ legs' props (decision 26), drawn by LILLE-DRAW from the fork at the thigh's end: a shank (unit length along +Y, its
;; root at the origin, tapering to a point; drawn at its length so its tip meets the floor) and the strut (unit along +Y, the
;; corner's knob at its end; drawn at 0.52 m), cream (KIN) or white (the owl)
(defun lb-shank (mb c) (mbc mb c) (with-xform (mb (xform :y 0.5)) (mb-cylinder mb 0.048 1.0 :segments 8 :top-radius 0.006 :smooth t)))
(defun lb-strut (mb c d)
  (mbc mb c) (with-xform (mb (xform :y 0.5)) (mb-cylinder mb 0.08 1.0 :segments 8 :top-radius 0.074 :smooth t))
  (mbc mb d) (with-xform (mb (xform :y 1.0)) (mb-sphere mb 0.11 :segments 8 :rings 5 :smooth t)))
(defweapon :lb-shank-cream (:length 1.0) (:solid (lb-shank mb #xEDE6CC)))
(defweapon :lb-shank-white (:length 1.0) (:solid (lb-shank mb #xECECE8)))
(defweapon :lb-strut-cream (:length 1.0) (:solid (lb-strut mb #xEDE6CC #xD9D0B2)))
(defweapon :lb-strut-white (:length 1.0) (:solid (lb-strut mb #xECECE8 #xBCC1CC)))
;; the halos, unit radius: Jilliel's wide thin flat ring; the owl's small ring with six spikes; the owl's broken one
(defweapon :lb-halo (:length 1.0) (:solid (mbc mb #x9CC4AC) (lb-ring mb 0.9 1.0 0.03 :n 32)))
(defun lb-spikes (mb n &key (skip nil))
  (dotimes (i n)
    (unless (member i skip)
      (let ((a (* 2 pi (/ i n))))
        (with-xform (mb (xform :x (* 0.95 (cos a)) :z (* 0.95 (sin a)) :y 0.18 :yaw (- (/ pi 2) a) :pitch 0.0 :roll -0.25))
          (mb-cone mb 0.09 0.38 :segments 4))))))
(defweapon :lb-halo-gold (:length 1.0) (:solid (mbc mb #xB89A5A) (lb-ring mb 0.82 1.0 0.1 :n 24) (mbc mb #xC2A866) (lb-spikes mb 6)))
(defweapon :lb-halo-broken (:length 1.0)              ; sealed: a piece out, an arc dropped and tilted, a spike lying
  (:solid (mbc mb #x8C7440) (lb-ring mb 0.82 1.0 0.1 :n 24 :from 0 :to 6) (lb-ring mb 0.82 1.0 0.1 :n 24 :from 16 :to 24)
          (with-xform (mb (xform :y -0.16 :x 0.1 :roll 0.28 :pitch 0.12)) (lb-ring mb 0.82 1.0 0.1 :n 24 :from 8 :to 14))
          (mbc mb #x9A8456) (lb-spikes mb 6 :skip '(2 3))
          (with-xform (mb (xform :x 0.2 :y -0.3 :z 0.5 :roll 1.3)) (mb-cone mb 0.09 0.38 :segments 4))))
;; the left eye opened (the base form), in the head joint's frame (the body's x1.2 head girth applied): the eye white, a
;; jade iris, the mark recoloured jade and flaring into four long strokes along its X
(defparameter *lb-eye-at* '(-0.0336 0.1488 -0.0763) "The left eye's centre in the head joint frame (x right, y up, z back).")
(defweapon :lb-eye-open (:length 0.1)
  (:solid :ink 0
          (destructuring-bind (x y z) *lb-eye-at*
            (mbc mb #xF2F0EC) (with-xform (mb (xform :x x :y y :z (- z 0.0012))) (mb-box mb 0.031 0.013 0.003))
            (mbc mb #x6E9A80) (with-xform (mb (xform :x (+ x 0.001) :y y :z (- z 0.0022))) (mb-box mb 0.014 0.013 0.003))
            (mbc mb #x16161E) (with-xform (mb (xform :x (+ x 0.001) :y y :z (- z 0.003))) (mb-box mb 0.006 0.008 0.003))
            (with-xform (mb (xform :x x :y (+ y 0.0085) :z (- z 0.0026))) (mb-box mb 0.032 0.0035 0.003))
            (mbc mb #x9CC4AC)
            (dolist (a '(0 90 180 270))
              (dolist (d '(-15 15))
                (let ((tt (* (/ pi 180) (+ a d))))
                  (with-xform (mb (xform :x (+ x (* 0.0204 (cos tt))) :y (+ y (* 0.0204 (sin tt))) :z (- z 0.0034)
                                         :roll (+ tt (/ pi 2))))
                    (mb-box mb 0.0104 0.0036 0.002)))))
            (mbc mb #xEAF4EE)
            (dolist (a '(45 135 225 315))
              (let ((tt (* (/ pi 180) a)))
                (with-xform (mb (xform :x (+ x (* 0.045 (cos tt))) :y (+ y (* 0.045 (sin tt))) :z (- z 0.004) :roll tt))
                  (mb-box mb 0.058 0.004 0.002)))))))
;; the reticle (the eye mark, the motif: DUEL_LILLE §3): four arcs and four inward ticks, unit radius, flat in XZ
(defun lb-reticle-mesh (mb)
  (dolist (k '(0 6 12 18)) (lb-ring mb 0.84 1.0 0.03 :n 24 :from (- k 2) :to (+ k 2)))
  (dolist (a '(0.7854 2.3562 3.927 5.4978))
    (with-xform (mb (xform :x (* 0.76 (cos a)) :z (* 0.76 (sin a)) :yaw (- a))) (mb-box mb 0.4 0.03 0.11))))
(defweapon :lb-reticle-grey (:length 1.0) (:solid :ink 0 (mbc mb #xE4E6EA) (lb-reticle-mesh mb)))
(defweapon :lb-reticle-jade (:length 1.0) (:solid :ink 0 (mbc mb #xB4DCC4) (lb-reticle-mesh mb)))
;; the looks' line props, unit along +Y (a floor line: X across, Z its thickness)
(defweapon :lb-line (:length 1.0) (:solid :ink 0 (mbc mb #x3A3E48) (with-xform (mb (xform :y 0.5)) (mb-box mb 1.0 1.0 1.0))))
(defweapon :lb-line-jade (:length 1.0) (:solid :ink 0 (mbc mb #x7FAE92) (with-xform (mb (xform :y 0.5)) (mb-box mb 1.0 1.0 1.0))))
(defweapon :lb-line-grey (:length 1.0) (:solid :ink 0 (mbc mb #xB4B8C0) (with-xform (mb (xform :y 0.5)) (mb-box mb 1.0 1.0 1.0))))
(defweapon :lb-line-gold (:length 1.0) (:solid :ink 0 (mbc mb #xCDB070) (with-xform (mb (xform :y 0.5)) (mb-box mb 1.0 1.0 1.0))))   ; the owl's traces
;; 神の喇叭 the trumpet, unit length along +Y from the mouthpiece to the bell: a long plain gold horn (no valves) flaring to
;; a wide bell whose ring is joined to an outer ring by four struts (the reticle again), a plume of five curved feather
;; blades rising (+X) near the mouthpiece
(defweapon :lb-trumpet (:length 1.0)
  (:solid (mbc mb #xB89A5A)
          (with-xform (mb (xform :y 0.4)) (mb-cylinder mb 0.022 0.8 :segments 8 :top-radius 0.05))
          (with-xform (mb (xform :y 0.875)) (mb-cylinder mb 0.05 0.15 :segments 12 :top-radius 0.17))
          (with-xform (mb (xform :y 0.955)) (mb-cylinder mb 0.17 0.02 :segments 16 :top-radius 0.19))
          (with-xform (mb (xform :y 0.0)) (mb-cylinder mb 0.035 0.04 :segments 8 :top-radius 0.02))
          (mbc mb #xC2A866) (lb-ring mb 0.24 0.27 0.02 :n 20 :y 0.975)
          (with-xform (mb (xform :x 0.215 :y 0.968)) (mb-box mb 0.06 0.014 0.016))
          (with-xform (mb (xform :x -0.215 :y 0.968)) (mb-box mb 0.06 0.014 0.016))
          (with-xform (mb (xform :z 0.215 :y 0.968)) (mb-box mb 0.016 0.014 0.06))
          (with-xform (mb (xform :z -0.215 :y 0.968)) (mb-box mb 0.016 0.014 0.06))
          (loop for y in '(0.12 0.17 0.22 0.27 0.32) for r in '(0.2 0.4 0.62 0.84 1.05) for c in '(#xC2A866 #xF2E6C0 #xC2A866 #xF2E6C0 #xC2A866)
                do (mbc mb c) (with-xform (mb (xform :y y :roll r)) (lb-plate mb '((0 -0.02) (0.4 0.06) (0.44 0.12) (0 0.02)) 0.014))))
  (:solid :ink 0 (mbc mb #xF2E6C0) (with-xform (mb (xform :y 0.958)) (mb-cylinder mb 0.15 0.012 :segments 16))))
;; the reflect's mirror: a flat white hexagon on its edge (Hakkyoken's look, a generic reflector)

;;; ---------------------------------------------------------------- the strike points (the host FK test)
(defparameter *lb-strike-points*
  '((:lb-q1 :weapon) (:lb-q2 :weapon) (:lb-butt :weapon)                 ; the plank (*LB-BUTT* behind the grip)
    (:lb-w-q1 :hand-r) (:lb-w-q2 :hand-l) (:lb-w-q3 :hand-r) (:lb-w-f1 :hand-r) (:lb-w-f2 :hand-l) (:lb-w-f3 :hand-r)
    (:lb-w-ram :hand-r)                                                  ; the front wings' tips (the rig's hands)
    (:lb-e-q1 :hand-r) (:lb-e-q2 :hand-l) (:lb-e-q3 :hand-r) (:lb-e-f1 :hand-r) (:lb-e-f2 :hand-l) (:lb-e-f3 :hand-r)   ; EN's casts
    (:lb-o-q1 :hand-r) (:lb-o-q2 :hand-l) (:lb-o-q3 :hand-r) (:lb-o-f1 :hand-r) (:lb-o-f2 :hand-l) (:lb-o-f3 :hand-r)
    (:lb-o-stamp :hand-r)                                                ; the owl's long arms (its claws)
    (:lb-oe-q1 :hand-r) (:lb-oe-q2 :hand-l) (:lb-oe-q3 :hand-r) (:lb-oe-f1 :hand-r) (:lb-oe-f2 :hand-l) (:lb-oe-f3 :hand-r))   ; its EN casts
  "Clip -> what strikes in it when it isn't Diagramm's muzzle (the weapon tip): :weapon = the plank, *LB-BUTT* behind the
grip; a joint = that joint (the wing blades and the owl's arms end at the rig's hands). The host FK test reads it.")


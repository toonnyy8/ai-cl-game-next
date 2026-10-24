;;;; rukia-art.lisp — KUCHIKI RUKIA (TYBW) as art data: her bodies (the TYBW look rebuild, 2026-10-24: :rukia-core, the
;;;; 13th Division lieutenant's shihakusho :rukia (the short left sleeve with the plaque, the tekko, the scabbard, the hakama),
;;;; :rukia-zero (absolute zero: white hair and irises, the ice ornament) and :rukia-bankai (白霞罸 in the cinematic only: the
;;;; white kimono; both white ones with ice-blue keylines and brows), her four blades (the sealed :ru-katana, the white Sode no
;;;; Shirayuki, -50's rimed :ru-rime, the ice :ru-ice), the moving cloth (RUKIA-LOOK-DRAW: the hakama's bell, the hanging
;;;; sleeves, the ribbons), every :ru-* pose and clip (docs/duel/DUEL_RUKIA.md §10), her ice looks (the hazards' draw
;;;; functions, the auras, frost on a victim, the cinematics' frost discs, pillar and dust) and the model sheets (debug 85500+).
;;;; Attack clips use DEFSTRIKE (the hit pose at frame S, back in the stance at S+A+R). Ice is mono: white cores and the
;;;; SOUL glass palette, never STEEL (the guard's) and no spot hue of her own (docs/style/STYLE_STORM_DESIGN.md §A.2).
(in-package :duel)

;;; ---------------------------------------------------------------- body
;; 1.44 m (scale 0.80; ~1.50 m to the crown with the x1.3 head), slight (width 0.92). The hurt cylinder is r 0.34 /
;; h 1.50 (a fairness floor, not her true 0.30 / 1.44: arcs built against the men's bodies don't pass over her).
;; The TYBW look rebuild (DUEL_RUKIA_TYBW §2, docs/research/rukia-rework/canon-looks.md §5; presentation only) splits it in
;; three: :RUKIA-CORE (the torso, head, hands and legs every look shares), :RUKIA (the lieutenant's shihakusho on the core:
;; the short puffed left sleeve with the plaque, white tekko, a hanging right sleeve, the white sash, the scabbard at the
;; left hip, the hakama's wide legs) and :RUKIA-BANKAI (the 白霞罸 kimono on the core). The parts that move (the hakama's
;; bell of gores, the hanging sleeves, the ribbons) are drawn by RUKIA-LOOK-DRAW, her forms' :draw hook (below).
(defbody :rukia-core (:scale 0.8 :width 0.92 :hunch 0 :hurt-r 0.34 :hurt-h 1.5
                 :girth ((:chest 0.84 1.0 0.86) (:spine 0.78 1.0 0.82) (:pelvis 0.9 1.0 0.9)
                         (:shoulder-r 0.8 0.8 0.8) (:shoulder-l 0.8 0.8 0.8)
                         (:upper-arm-r 0.82 1.0 0.82) (:upper-arm-l 0.82 1.0 0.82) (:lower-arm-r 0.82 1.0 0.82)
                         (:lower-arm-l 0.82 1.0 0.82) (:hand-r 0.9 0.9 0.9) (:hand-l 0.9 0.9 0.9)
                         (:thigh-r 0.9 1.0 0.9) (:thigh-l 0.9 1.0 0.9) (:shin-r 0.9 1.0 0.9) (:shin-l 0.9 1.0 0.9)
                         ;; playtest 1 (2026-09-28): an anime head, x1.3 about the head joint (the neck's top): ~7
                         ;; heads tall (was ~8.7; Yamamoto ~7.8, Kenpachi ~8). The crown variants' parts scale too. Art only
                         (:head 1.3 1.3 1.3))
                 ;; the look rebuild (2026-10-24): the irises lighter toward the manga's lavender (#5A5070 -> #7A7096, S 0.25),
                 ;; the sash white (#C8CCD6 -> #E2E4E8); the plaque a muted tan under S 0.3 (#B4A486: canon's gold-tan
                 ;; #C4A465 kept off the spot hues, the mono ice palette stands)
                 :palette ((:skin #xDCC0AE) (:black #x16161E) (:hair #x0C0C12) (:white #xECECE8) (:badge #x101018)
                           (:pupil #x7A7096) (:core #x16121C) (:shine #xFFFFFF) (:eye #xF2F0EC) (:lid #x141016)
                           (:mouth #x7A3A3C) (:fold #xD8DCE4) (:obi #xE2E4E8) (:tabi #xE8E8E4) (:sole #x262833)
                           (:ice #xE6ECF4) (:blood #xD0101C) (:brow #x0C0C12) (:clench #x141016) (:plaque #xB4A486))
                 :rim (#xD8E4FF 0.18))
  (:pelvis (:box 0.34 0.18 0.24 :c :black))
  (:spine (:bevel 0.34 0.25 0.23 0.04 :at (0 0.11 0) :c :black))
  (:chest (:bevel 0.4 0.28 0.25 0.05 :at (0 0.11 0) :c :black))
  (:neck (:cyl 0.034 0.17 :at (0 0.06 0) :c :skin))
  ;; the head (metres before the :girth x1.3; x sizes x the body width): a small skull, a flat-fronted face narrowing
  ;; in a V to a small chin, large eyes (a heavy lash line, violet-grey irises under S 0.3, a catch-light), a small nose
  ;; and mouth; the short black bob hugging the head with pointed locks, the strand between the eyes, white highlight
  ;; strokes on the crown
  (:head (:sphere 0.064 :stretch 0.02 :at (0 0.14 -0.012) :seg 12 :c :skin)                        ; skull
         (:bevel 0.104 0.07 0.076 0.02 :at (0 0.127 0.023) :c :skin)                                ; brow and cheeks
         (:bevel 0.05 0.072 0.066 0.014 :at (0.021 0.08 0.024) :rot (0 0 -24) :c :skin)            ; the jaw in a V
         (:bevel 0.05 0.072 0.066 0.014 :at (-0.021 0.08 0.024) :rot (0 0 24) :c :skin)
         (:wedge 0.012 0.018 0.012 :at (0 0.097 0.064) :rot (180 0 0) :c :skin)                    ; nose
         ;; :face-neutral: wide eyes, level brows, a small closed mouth
         (:box 0.028 0.021 0.003 :at (0.027 0.117 0.0615) :c :eye :tag :face-neutral)
         (:box 0.028 0.021 0.003 :at (-0.027 0.117 0.0615) :c :eye :tag :face-neutral)
         (:box 0.016 0.021 0.003 :at (0.024 0.116 0.0622) :c :pupil :tag :face-neutral)
         (:box 0.016 0.021 0.003 :at (-0.024 0.116 0.0622) :c :pupil :tag :face-neutral)
         (:box 0.007 0.011 0.003 :at (0.024 0.115 0.0629) :c :core :tag :face-neutral)
         (:box 0.007 0.011 0.003 :at (-0.024 0.115 0.0629) :c :core :tag :face-neutral)
         (:box 0.005 0.005 0.003 :at (0.028 0.121 0.0636) :c :shine :tag :face-neutral)
         (:box 0.005 0.005 0.003 :at (-0.02 0.121 0.0636) :c :shine :tag :face-neutral)
         (:box 0.036 0.0065 0.003 :at (0.027 0.128 0.0638) :rot (0 0 -6) :c :lid :tag :face-neutral)   ; lash lines
         (:box 0.036 0.0065 0.003 :at (-0.027 0.128 0.0638) :rot (0 0 6) :c :lid :tag :face-neutral)
         (:box 0.011 0.004 0.003 :at (0.046 0.124 0.0638) :rot (0 0 -35) :c :lid :tag :face-neutral)   ; their flicks
         (:box 0.011 0.004 0.003 :at (-0.046 0.124 0.0638) :rot (0 0 35) :c :lid :tag :face-neutral)
         (:box 0.026 0.0035 0.003 :at (0.028 0.145 0.0625) :rot (0 0 -6) :c :brow :tag :face-neutral)  ; brows
         (:box 0.026 0.0035 0.003 :at (-0.028 0.145 0.0625) :rot (0 0 6) :c :brow :tag :face-neutral)
         (:box 0.016 0.003 0.003 :at (0 0.07 0.0585) :c :mouth :tag :face-neutral)
         ;; :face-shout: the eyes narrowed and hard, the lash lines and brows down at the middle, the mouth open
         (:box 0.028 0.015 0.003 :at (0.027 0.115 0.0615) :c :eye :tag :face-shout)
         (:box 0.028 0.015 0.003 :at (-0.027 0.115 0.0615) :c :eye :tag :face-shout)
         (:box 0.014 0.015 0.003 :at (0.023 0.115 0.0622) :c :pupil :tag :face-shout)
         (:box 0.014 0.015 0.003 :at (-0.023 0.115 0.0622) :c :pupil :tag :face-shout)
         (:box 0.006 0.009 0.003 :at (0.023 0.115 0.0629) :c :core :tag :face-shout)
         (:box 0.006 0.009 0.003 :at (-0.023 0.115 0.0629) :c :core :tag :face-shout)
         (:box 0.036 0.007 0.003 :at (0.027 0.1235 0.0638) :rot (0 0 10) :c :lid :tag :face-shout)
         (:box 0.036 0.007 0.003 :at (-0.027 0.1235 0.0638) :rot (0 0 -10) :c :lid :tag :face-shout)
         (:box 0.028 0.005 0.003 :at (0.028 0.138 0.0625) :rot (0 0 18) :c :brow :tag :face-shout)
         (:box 0.028 0.005 0.003 :at (-0.028 0.138 0.0625) :rot (0 0 -18) :c :brow :tag :face-shout)
         (:box 0.024 0.018 0.003 :at (0 0.067 0.0585) :c :mouth :tag :face-shout)
         (:box 0.02 0.004 0.003 :at (0 0.0735 0.0592) :c :eye :tag :face-shout)                         ; upper teeth
         ;; :face-hurt: eyes squeezed shut (> <), the brows up at the middle, a clenched grimace
         (:box 0.026 0.0045 0.003 :at (0.027 0.121 0.0625) :rot (0 0 14) :c :lid :tag :face-hurt)
         (:box 0.026 0.0045 0.003 :at (0.027 0.113 0.0625) :rot (0 0 -14) :c :lid :tag :face-hurt)
         (:box 0.026 0.0045 0.003 :at (-0.027 0.121 0.0625) :rot (0 0 -14) :c :lid :tag :face-hurt)
         (:box 0.026 0.0045 0.003 :at (-0.027 0.113 0.0625) :rot (0 0 14) :c :lid :tag :face-hurt)
         (:box 0.028 0.004 0.003 :at (0.028 0.141 0.0625) :rot (0 0 -18) :c :brow :tag :face-hurt)
         (:box 0.028 0.004 0.003 :at (-0.028 0.141 0.0625) :rot (0 0 18) :c :brow :tag :face-hurt)
         (:box 0.026 0.011 0.003 :at (0 0.068 0.0585) :c :mouth :tag :face-hurt)
         (:box 0.022 0.005 0.003 :at (0 0.068 0.0592) :c :eye :tag :face-hurt)
         (:box 0.022 0.0012 0.003 :at (0 0.068 0.0598) :c :clench :tag :face-hurt)                     ; the clench (dark in every look)
         ;; the bob: a cap over the skull, the back to the nape, side sheets over the ears, pointed jaw-length locks
         ;; flaring out a little at the tips, the fringe of pointed locks and the strand between the eyes
         (:sphere 0.074 :stretch 0.02 :at (0 0.15 -0.018) :seg 12 :c :hair)
         (:bevel 0.15 0.11 0.08 0.03 :at (0 0.1 -0.052) :c :hair)                                   ; the back, to the nape
         (:bevel 0.03 0.11 0.1 0.012 :at (0.064 0.108 -0.004) :rot (0 0 -4) :c :hair)              ; over the ears
         (:bevel 0.03 0.11 0.1 0.012 :at (-0.064 0.108 -0.004) :rot (0 0 4) :c :hair)
         (:cone 0.024 0.078 :at (0.066 0.04 0.03) :rot (0 180 -10) :seg 4 :c :hair)                 ; jaw-length locks
         (:cone 0.024 0.078 :at (-0.066 0.04 0.03) :rot (0 180 10) :seg 4 :c :hair)
         (:cone 0.026 0.07 :at (0.07 0.046 -0.02) :rot (0 180 -14) :seg 4 :c :hair)
         (:cone 0.026 0.07 :at (-0.07 0.046 -0.02) :rot (0 180 14) :seg 4 :c :hair)
         (:cone 0.028 0.06 :at (0.04 0.05 -0.07) :rot (0 190 -8) :seg 4 :c :hair)                   ; the nape's points
         (:cone 0.028 0.06 :at (-0.04 0.05 -0.07) :rot (0 190 8) :seg 4 :c :hair)
         (:bevel 0.108 0.028 0.036 0.012 :at (0 0.178 0.047) :rot (0 -24 0) :c :hair)              ; the fringe ...
         (:cone 0.02 0.056 :at (0.036 0.158 0.062) :rot (0 186 8) :seg 4 :c :hair)                  ; ... its locks
         (:cone 0.018 0.05 :at (0.013 0.162 0.066) :rot (0 186 2) :seg 4 :c :hair)
         (:cone 0.018 0.05 :at (-0.016 0.162 0.066) :rot (0 186 -4) :seg 4 :c :hair)
         (:cone 0.02 0.056 :at (-0.04 0.158 0.062) :rot (0 186 -10) :seg 4 :c :hair)
         (:cone 0.008 0.064 :at (0.005 0.134 0.068) :rot (0 184 -4) :seg 4 :c :hair)                ; the strand between the eyes
         (:box 0.006 0.028 0.003 :at (-0.039 0.206 0.029) :rot (222 -36 0) :c :fold)               ; white highlight strokes
         (:box 0.006 0.024 0.003 :at (-0.017 0.21 0.039) :rot (198 -40 0) :c :fold)
         (:box 0.006 0.028 0.003 :at (0.023 0.208 0.038) :rot (156 -38 0) :c :fold)
         (:box 0.006 0.05 0.003 :at (0.031 0.199 -0.077) :rot (30 -30 0) :c :fold)
         ;; the ice rims of -50 (:ice-trim, hidden elsewhere): icicles on the locks' tips
         (:cone 0.012 0.03 :at (0.071 0.008 0.03) :rot (0 180 -10) :seg 4 :c :ice :tag :ice-trim)
         (:cone 0.012 0.03 :at (-0.071 0.008 0.03) :rot (0 180 10) :seg 4 :c :ice :tag :ice-trim)
         (:cone 0.012 0.028 :at (0.077 0.016 -0.02) :rot (0 180 -14) :seg 4 :c :ice :tag :ice-trim)
         (:cone 0.012 0.028 :at (-0.077 0.016 -0.02) :rot (0 180 14) :seg 4 :c :ice :tag :ice-trim))
  ;; the hands; CRACK (:hand-crack): a BLOOD hairline zigzag across the right one's back (the outside, +x, on the grip,
  ;; just proud of the tekko)
  (:hand-r (:bevel 0.056 0.076 0.056 0.016 :at (0 -0.038 0) :c :skin)
           (:glow 1.8 (:box 0.004 0.026 0.005 :at (0.0322 -0.022 0.012) :rot (0 32 0) :c :blood) :hand-crack)
           (:glow 1.8 (:box 0.004 0.026 0.005 :at (0.0322 -0.042 0.004) :rot (0 -40 0) :c :blood) :hand-crack)
           (:glow 1.8 (:box 0.004 0.022 0.005 :at (0.0322 -0.06 0.01) :rot (0 24 0) :c :blood) :hand-crack))
  (:hand-l (:bevel 0.056 0.076 0.056 0.016 :at (0 -0.038 0) :c :skin))
  (:thigh-r (:cyl 0.1 0.44 :top 0.09 :seg 10 :at (0 -0.21 0) :c :black))
  (:thigh-l (:cyl 0.1 0.44 :top 0.09 :seg 10 :at (0 -0.21 0) :c :black))
  (:shin-r (:cyl 0.1 0.34 :top 0.09 :seg 10 :at (0 -0.15 0) :c :black) (:box 0.07 0.12 0.08 :at (0 -0.37 0) :c :tabi))
  (:shin-l (:cyl 0.1 0.34 :top 0.09 :seg 10 :at (0 -0.15 0) :c :black) (:box 0.07 0.12 0.08 :at (0 -0.37 0) :c :tabi))
  (:foot-r (:bevel 0.08 0.055 0.2 0.02 :at (0 -0.02 0.05) :c :tabi) (:box 0.09 0.02 0.22 :at (0 -0.05 0.05) :c :sole))
  (:foot-l (:bevel 0.08 0.055 0.2 0.02 :at (0 -0.02 0.05) :c :tabi) (:box 0.09 0.02 0.22 :at (0 -0.05 0.05) :c :sole)))

;; The lieutenant's shihakusho (canon-looks §2.1, ch. 459; gaps #2-#6, #8): the collar and white under-collar; the left
;; sleeve cut short to a puffed cap over the upper arm, the division plaque (tan, 十三 in ink) on the white under-sleeve
;; below it, the white tekko from the knuckles to above the elbow; the right sleeve on the forearm (its hanging panel is
;; RUKIA-LOOK-DRAW's) with the tekko's cuff at the wrist; the white sash, its knot at the front; the black scabbard thrust
;; through it at the left hip, its end down behind her; the hakama's wide legs (its bell of gores is the draw hook's).
;; -50's ice rims (:ice-trim) on the collar, the hems and the locks.
(defparameter *ru-glove*
  '(:box 0.062 0.042 0.062 :at (0 -0.022 0) :c :white)
  "The tekko over the back of the hand and the palm (fingerless: the fingers stay skin).")
(body-variant :rukia :rukia-core
  :parts `((:pelvis (:box 0.35 0.045 0.25 :at (0 0.075 0) :c :obi)                                ; the sash
                    (:box 0.05 0.03 0.02 :at (0.07 0.074 0.13) :rot (0 0 -12) :c :obi)             ; its knot
                    (:box 0.012 0.05 0.012 :at (0.08 0.045 0.132) :rot (0 0 -8) :c :obi)
                    (:box 0.036 0.036 0.62 :at (-0.165 0.0 -0.17) :rot (-8 24 0) :c :black)        ; the scabbard
                    (:box 0.042 0.042 0.03 :at (-0.158 0.07 0.12) :rot (-8 24 0) :c :sole))        ; its mouth
           (:chest (:box 0.16 0.07 0.04 :at (0 0.262 -0.05) :rot (0 -8 0) :c :black)              ; the collar round the neck
                   (:box 0.035 0.07 0.11 :at (0.066 0.258 0.0) :rot (0 0 -8) :c :black)
                   (:box 0.035 0.07 0.11 :at (-0.066 0.258 0.0) :rot (0 0 8) :c :black)
                   (:box 0.016 0.17 0.01 :at (0.032 0.182 0.13) :rot (0 0 -24) :c :white)          ; the white under-collar V
                   (:box 0.016 0.17 0.01 :at (-0.032 0.182 0.13) :rot (0 0 24) :c :white)
                   (:box 0.005 0.16 0.004 :at (0.07 0.07 0.132) :rot (0 0 -10) :c :fold)            ; a fold highlight
                   (:box 0.02 0.08 0.012 :at (0.04 0.2 0.132) :rot (0 0 -24) :c :ice :tag :ice-trim) ; -50: frost on the collar
                   (:box 0.02 0.08 0.012 :at (-0.04 0.2 0.132) :rot (0 0 24) :c :ice :tag :ice-trim))
           (:shoulder-r (:bevel 0.11 0.06 0.17 0.02 :at (0.02 -0.02 0) :rot (0 0 -20) :c :black))
           (:shoulder-l (:bevel 0.11 0.06 0.17 0.02 :at (-0.02 -0.02 0) :rot (0 0 20) :c :black))
           (:upper-arm-r (:box 0.12 0.3 0.13 :at (0 -0.15 0) :c :black))
           ;; the left sleeve is the right one's loose long sleeve pulled up and held by the armband (the user, 2026-10-24,
           ;; DUEL_RUKIA_TYBW §7.1): the gathered fabric above the band, the band with the plaque, the sleeve's loose mouth
           ;; flaring below it round the upper arm, the white under-sleeve showing beneath
           (:upper-arm-l (:bevel 0.15 0.12 0.16 0.04 :at (0 -0.04 0) :c :black)                   ; the gathered sleeve
                         (:box 0.13 0.04 0.14 :at (0 -0.112 0) :c :white)                         ; the armband holding it
                         (:box 0.006 0.036 0.046 :at (-0.066 -0.112 0.004) :c :plaque)             ; the plaque on its outside,
                         (:box 0.003 0.026 0.004 :at (-0.0695 -0.112 0.004) :c :badge)             ;  十三 in ink
                         (:box 0.003 0.004 0.03 :at (-0.0695 -0.104 0.004) :c :badge)
                         (:box 0.003 0.004 0.022 :at (-0.0695 -0.12 0.004) :c :badge)
                         (:cyl 0.145 0.115 :top 0.07 :seg 10 :at (0 -0.188 0) :c :black)             ; the loose mouth below the band
                         (:box 0.096 0.1 0.104 :at (0 -0.25 0) :c :white)                         ; the under-sleeve / tekko
                         (:cyl 0.149 0.01 :seg 10 :at (0 -0.245 0) :c :ice :tag :ice-trim))        ; -50: the mouth's frosted hem
           (:lower-arm-r (:box 0.13 0.2 0.14 :at (0 -0.1 0) :c :black)                             ; the sleeve on the forearm
                         (:box 0.135 0.01 0.145 :at (0 -0.2 0) :c :ice :tag :ice-trim)              ; the frosted hem
                         (:box 0.088 0.08 0.094 :at (0 -0.228 0) :c :white))                       ; the tekko's cuff
           (:lower-arm-l (:box 0.088 0.27 0.094 :at (0 -0.135 0) :c :white))                       ; the bare tekko
           (:hand-r ,*ru-glove*)
           (:hand-l ,*ru-glove*)
           (:thigh-r (:cyl 0.13 0.44 :top 0.12 :seg 10 :at (0 -0.21 0) :c :black)                 ; the hakama's legs
                     (:box 0.005 0.26 0.004 :at (0.03 -0.2 0.136) :rot (0 -3 -4) :c :fold))
           (:thigh-l (:cyl 0.13 0.44 :top 0.12 :seg 10 :at (0 -0.21 0) :c :black))
           (:shin-r (:cyl 0.2 0.36 :top 0.13 :seg 12 :at (0 -0.16 0) :c :black)                   ; ... wide at the ankle
                    (:cyl 0.206 0.012 :seg 12 :at (0 -0.336 0) :c :ice :tag :ice-trim))
           (:shin-l (:cyl 0.2 0.36 :top 0.13 :seg 12 :at (0 -0.16 0) :c :black)
                    (:cyl 0.206 0.012 :seg 12 :at (0 -0.336 0) :c :ice :tag :ice-trim))))

;; the ice ornament (absolute zero and the Bankai; gaps #12, #17): canon's spray of ice feathers on the LEFT side of her head
;; sweeping back (ch. 570, Ep385), wrapping round behind it (the wiki's "half crown ... around the back of her head"), a
;; small boss at its root and a short tassel; past the head's outline from every side
(defparameter *ru-crown*
  '((:sphere 0.02 :at (-0.07 0.17 -0.035) :seg 6 :c :ice)
    (:cone 0.016 0.16 :at (-0.115 0.215 -0.06) :rot (0 30 50) :seg 4 :c :ice)
    (:cone 0.014 0.14 :at (-0.12 0.18 -0.07) :rot (0 40 62) :seg 4 :c :ice)
    (:cone 0.012 0.12 :at (-0.115 0.14 -0.07) :rot (0 52 86) :seg 4 :c :ice)
    (:cone 0.011 0.1 :at (-0.1 0.105 -0.06) :rot (0 62 108) :seg 4 :c :ice)
    (:cone 0.014 0.13 :at (-0.095 0.24 -0.07) :rot (0 34 34) :seg 4 :c :ice)
    (:cone 0.012 0.11 :at (-0.04 0.22 -0.11) :rot (0 62 14) :seg 4 :c :ice)
    (:cone 0.01 0.09 :at (0.0 0.19 -0.12) :rot (0 80 0) :seg 4 :c :ice)
    (:box 0.006 0.07 0.006 :at (-0.085 0.115 -0.03) :rot (0 0 6) :c :ice)))

;; absolute zero (-273.15 C, the canon Bankai colouring on her own clothes): white hair and irises, the skin cold-shifted,
;; the ice ornament, crystals on the shoulders
(defparameter *ru-ice-ink* '((t . #x7F97B4))
  "The white Rukia's keyline (absolute zero, the Bankai; the user's decision 2026-09-28): ice blue on every shape instead of
the ink (the style's ICE keyline, docs/style/STYLE_STORM_DESIGN.md §2.4).")

(body-variant :rukia-zero :rukia :ink *ru-ice-ink* :clips '(:ru-q1 :ru-q1-z :ru-thrust :ru-thrust-z)
  :palette '((:hair #xE4E8EE) (:pupil #xDDE4EE) (:core #x9AA8BE) (:skin #xD6CCCA) (:fold #x9AA8BE) (:brow #xCFE3F2)
             (:lid #xCFE3F2))                   ; the lashes the brows' pale ice (playtest 2, 2026-09-28)
  :parts `((:head ,@*ru-crown*)
           (:shoulder-r (:cone 0.016 0.06 :at (0.05 0.04 0.01) :rot (0 0 -24) :seg 4 :c :ice)
                        (:cone 0.012 0.045 :at (0.02 0.04 -0.03) :rot (0 16 -8) :seg 4 :c :ice))
           (:shoulder-l (:cone 0.016 0.06 :at (-0.05 0.04 0.01) :rot (0 0 24) :seg 4 :c :ice)
                        (:cone 0.012 0.045 :at (-0.02 0.04 -0.03) :rot (0 16 8) :seg 4 :c :ice))))

;; 白霞罸 (the cinematic only, ch. 570 pp6-7, Ep385; gaps #13-#18) on the core: the white kimono (black -> white; its
;; ankle-length skirt is the draw hook's bell, its knee-long hanging sleeves the hook's panels, the ribbons from her back
;; the hook's chains), lined edges in the cold shade; the collar a tall ring of four stacked ice bands to the jaw; tiered ice
;; plates rising up and out off each shoulder; a flat six-point ice snowflake on the chest with a short tassel; the sash and
;; the four ribbon loops tied at her back; the ice ornament, white hair
(body-variant :rukia-bankai :rukia-core :ink *ru-ice-ink*
  :palette '((:black #xEEEEEA) (:hair #xE4E8EE) (:pupil #xDDE4EE) (:core #x9AA8BE) (:skin #xD6CCCA) (:fold #x9AA8BE)
             (:obi #x9AA8BE) (:brow #xCFE3F2) (:lid #xCFE3F2))
  :parts `((:pelvis (:box 0.35 0.05 0.25 :at (0 0.075 0) :c :obi)                                ; the sash
                    (:bevel 0.2 0.1 0.03 0.01 :at (0.1 0.1 -0.17) :rot (0 30 -30) :c :ice)         ; the ribbon loops
                    (:bevel 0.2 0.1 0.03 0.01 :at (-0.1 0.1 -0.17) :rot (0 30 30) :c :ice)
                    (:bevel 0.17 0.09 0.03 0.01 :at (0.09 0.0 -0.16) :rot (0 20 40) :c :ice)
                    (:bevel 0.17 0.09 0.03 0.01 :at (-0.09 0.0 -0.16) :rot (0 20 -40) :c :ice)
                    (:sphere 0.035 :at (0 0.07 -0.15) :seg 6 :c :ice))                             ; the knot
           (:chest (:box 0.016 0.2 0.01 :at (0.03 0.17 0.13) :rot (0 0 -24) :c :fold)              ; the lined collar's V
                   (:box 0.016 0.2 0.01 :at (-0.03 0.17 0.13) :rot (0 0 24) :c :fold)
                   (:cyl 0.08 0.034 :top 0.086 :seg 12 :at (0 0.245 -0.012) :c :ice)               ; the stacked ice collar
                   (:cyl 0.088 0.034 :top 0.096 :seg 12 :at (0 0.276 -0.016) :c :ice)
                   (:cyl 0.098 0.034 :top 0.106 :seg 12 :at (0 0.307 -0.02) :c :ice)
                   (:cyl 0.108 0.03 :top 0.116 :seg 12 :at (0 0.336 -0.026) :c :ice)
                   (:box 0.012 0.11 0.006 :at (0 0.12 0.142) :c :ice)                              ; the snowflake (three bars
                   (:box 0.012 0.11 0.006 :at (0 0.12 0.142) :rot (0 0 60) :c :ice)                ;  crossed) ...
                   (:box 0.012 0.11 0.006 :at (0 0.12 0.142) :rot (0 0 -60) :c :ice)
                   (:cyl 0.016 0.012 :seg 6 :at (0 0.12 0.146) :rot (0 90 0) :c :ice)
                   (:box 0.006 0.07 0.006 :at (0 0.04 0.146) :c :ice))                             ; ... its tassel
           (:head ,@*ru-crown*)
           (:shoulder-r (:bevel 0.11 0.06 0.17 0.02 :at (0.02 -0.02 0) :rot (0 0 -20) :c :black)
                        (:bevel 0.17 0.014 0.19 0.004 :at (0.05 0.035 0) :rot (0 0 14) :c :ice)    ; the tiered plates
                        (:bevel 0.14 0.014 0.16 0.004 :at (0.06 0.065 0) :rot (0 0 26) :c :ice)
                        (:bevel 0.1 0.014 0.12 0.004 :at (0.07 0.095 0) :rot (0 0 38) :c :ice))
           (:shoulder-l (:bevel 0.11 0.06 0.17 0.02 :at (-0.02 -0.02 0) :rot (0 0 20) :c :black)
                        (:bevel 0.17 0.014 0.19 0.004 :at (-0.05 0.035 0) :rot (0 0 -14) :c :ice)
                        (:bevel 0.14 0.014 0.16 0.004 :at (-0.06 0.065 0) :rot (0 0 -26) :c :ice)
                        (:bevel 0.1 0.014 0.12 0.004 :at (-0.07 0.095 0) :rot (0 0 -38) :c :ice))
           (:upper-arm-r (:box 0.13 0.3 0.14 :at (0 -0.15 0) :c :black))
           (:upper-arm-l (:box 0.13 0.3 0.14 :at (0 -0.15 0) :c :black))
           (:lower-arm-r (:box 0.15 0.2 0.16 :at (0 -0.1 0) :c :black))
           (:lower-arm-l (:box 0.15 0.2 0.16 :at (0 -0.1 0) :c :black))))

;;; ---------------------------------------------------------------- weapons
(defun ru-snow-guard (mb r c)
  "The hollow snowflake guard in the weapon frame (the XZ plane at the grip; canon-looks §1, gap #7): a round ring of
radius R (14 segments), six thin spokes in to a hub round the blade, in colour C."
  (mbc mb c)
  (dotimes (i 14)
    (let ((a (* i (/ pi 7))))
      (mb-at (mb :x (* r (cos a)) :z (* r (sin a)) :yaw (- (+ a (/ pi 2))))    ; a segment of the ring
        (mb-box mb (* 1.2 (/ (* 2 pi r) 14)) 0.012 0.008))))
  (dotimes (i 6)
    (let ((b (+ (* i (/ pi 3)) (/ pi 6))))
      (mb-at (mb :x (* 0.6 r (cos b)) :z (* 0.6 r (sin b)) :yaw (- b))          ; a spoke
        (mb-box mb (* 0.8 r) 0.008 0.005))))
  (mb-cylinder mb 0.016 0.014 :segments 8))                                    ; the hub

(defun ru-ribbon-tie (mb y)
  "The ribbon's tie at the pommel (weapon frame Y): a knot and two short ends; the ribbon itself is RUKIA-LOOK-DRAW's
chain, hung from just below it (*RU-POMMEL*)."
  (mb-at (mb :y y) (mb-box mb 0.022 0.016 0.022))
  (mb-at (mb :y (- y 0.02) :x 0.008 :roll 0.3) (mb-box mb 0.004 0.03 0.016))
  (mb-at (mb :y (- y 0.02) :x -0.008 :roll -0.3) (mb-box mb 0.004 0.03 0.016)))

(defweapon :ru-katana (:length 0.86)                   ; sealed: a plain katana (the intro only)
  (:solid (mb-blade mb :width 0.03 :guard-color '(0.3 0.3 0.32) :handle-color '(0.08 0.07 0.08) :wrap-color '(0.2 0.2 0.24) :blade nil))
  (:solid :ink 0 (mb-blade mb :length 0.8 :width 0.03 :curve 0.012 :blade-color '(0.6 0.62 0.66) :edge-color '(0.86 0.88 0.9) :hilt nil)))

;; Sode no Shirayuki: blade, hilt and guard pure white; the guard a hollow round ring with a snowflake of spokes; the
;; long white ribbon from the pommel (its tie here, the ribbon RUKIA-LOOK-DRAW's chain)
(defweapon :sode-no-shirayuki (:length 0.9)
  (:solid :ink 0 (mb-blade mb :length 0.84 :width 0.032 :curve 0.01 :blade-color '(0.94 0.95 0.97) :edge-color '(1.0 1.0 1.0) :hilt nil))
  (:solid (mbc mb #xECEEF2)                            ; the white hilt, its wrap in the cold shade, the pommel cap
          (mb-at (mb :y -0.1) (mb-bevel-box mb 0.026 0.2 0.032 0.006))
          (mb-at (mb :y 0.02) (mb-box mb 0.014 0.03 0.036))
          (mb-at (mb :y -0.206) (mb-bevel-box mb 0.03 0.016 0.036 0.004))
          (mbc mb #x9AA8BE)
          (loop for i below 4 do (mb-at (mb :y (- -0.035 (* i 0.045)) :roll 0.785) (mb-box mb 0.02 0.02 0.034)))
          (ru-snow-guard mb 0.042 #xF4F6F8))
  (:solid :ink 0.6 (mbc mb #xF4F6F8) (ru-ribbon-tie mb -0.222)))

;; -50 C: Sode no Shirayuki rimed: the white blade with an ice edge grown along it, the guard frosted
(defweapon :ru-rime (:length 1.0)
  (:solid :ink 0 (mb-blade mb :length 0.9 :width 0.036 :curve 0.01 :blade-color '(0.9 0.93 0.97) :edge-color '(0.78 0.86 0.96) :hilt nil))
  (:solid (mbc mb #xECEEF2)
          (mb-at (mb :y -0.1) (mb-bevel-box mb 0.026 0.2 0.032 0.006))
          (mb-at (mb :y 0.02) (mb-box mb 0.014 0.03 0.036))
          (mb-at (mb :y -0.206) (mb-bevel-box mb 0.03 0.016 0.036 0.004))
          (mbc mb #x9AA8BE)
          (loop for i below 4 do (mb-at (mb :y (- -0.035 (* i 0.045)) :roll 0.785) (mb-box mb 0.02 0.02 0.034)))
          (ru-snow-guard mb 0.046 #xE6ECF4))
  (:solid :ink 0.6 (mbc mb #xE6ECF4)                   ; ice crystals along the back of the blade, the ribbon's tie
          (loop for i below 4 do (mb-at (mb :y (+ 0.2 (* i 0.17)) :z -0.02 :pitch 0.5) (mb-cone mb 0.008 0.05 :segments 4)))
          (ru-ribbon-tie mb -0.222)))

;; the Bankai's ice blade (the 白霞罸 cinematic, and absolute zero in play): pale ice, a white core line, the snowflake ring in ice, an ice hilt
(defweapon :ru-ice (:length 1.0)
  (:solid :ink 0 (mb-blade mb :length 0.96 :width 0.04 :curve 0.008 :blade-color '(0.86 0.9 0.95) :edge-color '(1.0 1.0 1.0) :hilt nil))
  (:solid (mbc mb #xE6ECF4)
          (mb-at (mb :y -0.1) (mb-bevel-box mb 0.028 0.2 0.034 0.006))
          (mb-at (mb :y -0.215) (mb-cone mb 0.02 0.05 :segments 4))
          (ru-snow-guard mb 0.05 #xE6ECF4))
  (:solid :ink 0.6 (mbc mb #xE6ECF4) (ru-ribbon-tie mb -0.244)))

;;; ---------------------------------------------------------------- moving cloth (RUKIA-LOOK-DRAW: her forms' :draw hook)
;;; The TYBW look rebuild's secondary motion on the posed body (DUEL_RUKIA_TYBW §2; canon-looks §5 gaps #1, #4, #5, #15, #16).
;;; A look: the sim never reads it, no random number, 0 B a frame (debug 85900's consing line). Stepped on the effect
;;; seconds (none while paused, slowed with CINE-SLOW) and re-primed after a jump of 1.5 m (a reset, a cinematic's placing).
;;;  - The hakama's bell: *RU-GORES* gores hinged round the waist under the sash, each opened by the hem spring Yamamoto's
;;;    hem uses (yama-art.lisp %YA-HEM-POSE / %YA-HEM-STEP, its *YA-HEM-* knobs): the bell trails her travel and her turns,
;;;    overshoots once when she stops, and every gore flares out by *RU-GORE-FLARE* per radian of the spring's yaw lag, so a
;;;    turn opens the bell all round (canon: the hakama billows into a bell in her turns; it reads from the behind camera).
;;;    The 白霞罸 kimono is the same bell, ankle-long and white. Gores only turn about their hinge: nothing is scaled.
;;;  - The hanging sleeves: a panel under the forearm (the shihakusho's right one; both, knee-long, in the Bankai), its
;;;    foot a damped pendulum from the forearm's middle: it hangs straight down and swings behind a cut.
;;;  - The ribbons: Sode no Shirayuki's from the pommel (canon >= 6 m, a loop wider than she is tall in every turn; drawn
;;;    *RU-RIBBON-SEGS* x *RU-RIBBON-SEG*) and the Bankai's three from the bow at her back: verlet chains (gravity, drag, the
;;;    plaza a floor with friction), each drawn as one camera-facing SOUL-glass strip (flat white, one shaded edge). It lies on
;;;    the plaza behind her when she stands, loops round her in a turn and streams behind a dash. The colder bands stiffen
;;;    it (DUEL_RUKIA §2: -18 hangs straight; -50 and zero frozen): more drag, a straightening pull, a shorter drawn length.
(defparameter *ru-gores* 8 "The hakama's gores (the bell's panels). New 2026-10-24 (the look rebuild, the lead's).")
(defparameter *ru-gore-flare* 1.6
  "Every gore's outward swing per radian of the hem spring's yaw lag (*YA-HEM-TURN* x the turn rate, capped 0.3): a fast
turn opens the bell ~27 degrees past its rest. New 2026-10-24.")
(defparameter *ru-ribbon-segs* 10 "Sode no Shirayuki's ribbon: its chain's segments (all simulated; the colder bands draw fewer).")
(defparameter *ru-ribbon-seg* 0.18 "... each this long (m): 1.8 m in all (canon >= 6 m, trimmed: lying behind her it stays short
of the behind camera, so it never runs across the screen).")
(defparameter *ru-ribbon-w* 0.022 "The ribbon's half width (m; canon: about the blade's width, flat, no fringe).")
(defparameter *ru-ribbon-bands*
  '((0 0.02 0.0 10) (1 0.12 0.04 8) (2 0.3 0.25 6) (3 0.3 0.25 6))
  "Per band (0 the Shikai, 1 -18, 2 -50, 3 zero / the Bankai): (band drag stiffness drawn-segments). Drag = the velocity
lost a 1/60 s step; stiffness = the pull of each point onto the line of the two before it (0 a free cloth).")

(defconstant +ru-side+ 340 "*RU-CLOTH*'s floats per side.")
(defconstant +ru-sword+ 16 "The sword ribbon's chain header (then 17 points of 6 floats).")
(defconstant +ru-bk+ 120 "The Bankai ribbons' first chain header (three chains of 11 points, 67 floats apart).")
(defconstant +ru-pend+ 322 "The hanging sleeves' pendulums (right, left; 7 floats each: x y z, last x y z, primed).")
(declaim (type f32vec *ru-cloth* *ru-cp* *ru-m*))
(defvar *ru-cloth* (make-f32 (* 2 +ru-side+))
  "Per side: [0..15] the hem spring (%YA-HEM-POSE / -STEP's layout), [16..] the sword ribbon's chain (a header: 1 once
primed; per point x y z and its last x y z), [120..] the Bankai's three ribbon chains, [322..] the sleeves' pendulums.")
(defvar *ru-cp* (make-f32 16) "The cloth's parameters for one call (every float crosses a call through here: 0 B).")
(defvar *ru-m* (m4) "A cloth part's world matrix.")

(defun ru-slab (mb w0 w1 h d)
  "A trapezoid slab hanging from its top edge at the origin: W0 wide there, W1 at its foot H below (along -Y), D thick."
  (let ((a (* 0.5 w0)) (b (* 0.5 w1)) (z (* 0.5 d)) (c (list 0 (* -0.5 h) 0)))
    (flet ((q (&rest pts) (mb-poly-out mb pts :center c)))
      (q (v3 (- a) 0 z) (v3 a 0 z) (v3 b (- h) z) (v3 (- b) (- h) z))
      (q (v3 (- a) 0 (- z)) (v3 a 0 (- z)) (v3 b (- h) (- z)) (v3 (- b) (- h) (- z)))
      (q (v3 (- a) 0 z) (v3 a 0 z) (v3 a 0 (- z)) (v3 (- a) 0 (- z)))
      (q (v3 (- b) (- h) z) (v3 b (- h) z) (v3 b (- h) (- z)) (v3 (- b) (- h) (- z)))
      (q (v3 a 0 z) (v3 b (- h) z) (v3 b (- h) (- z)) (v3 a 0 (- z)))
      (q (v3 (- a) 0 z) (v3 (- b) (- h) z) (v3 (- b) (- h) (- z)) (v3 (- a) 0 (- z))))))

;; the cloth parts as weapons (DRAW-WEAPON at a computed matrix; rig metres: the joints carry her 0.8 scale), the black
;; ones with the black cloth's grey keyline, the Bankai's white ones with her ice keyline
(defweapon :ru-gore (:length 0.56 :ink-color #x4A5062) (:solid (mbc mb #x16161E) (ru-slab mb 0.12 0.3 0.56 0.024)))
(defweapon :ru-gore-rime (:length 0.56 :ink-color #x4A5062)            ; -50: the frosted hem
  (:solid (mbc mb #x16161E) (ru-slab mb 0.12 0.3 0.56 0.024)
          (mbc mb #xE6ECF4) (mb-at (mb :y -0.552) (mb-box mb 0.3 0.016 0.034))))
(defweapon :ru-gore-ice (:length 0.56 :ink-color #x7F97B4)              ; absolute zero: the white Rukia's ice keyline
  (:solid (mbc mb #x16161E) (ru-slab mb 0.12 0.3 0.56 0.024)))
(defweapon :ru-bk-gore (:length 0.9 :ink-color #x7F97B4) (:solid (mbc mb #xEEEEEA) (ru-slab mb 0.12 0.25 0.9 0.022)))
(defweapon :ru-sleeve (:length 0.26 :ink-color #x4A5062)
  (:solid (mbc mb #x16161E) (mb-at (mb :y -0.13) (mb-bevel-box mb 0.24 0.26 0.032 0.012))))
(defweapon :ru-sleeve-rime (:length 0.26 :ink-color #x4A5062)
  (:solid (mbc mb #x16161E) (mb-at (mb :y -0.13) (mb-bevel-box mb 0.24 0.26 0.032 0.012))
          (mbc mb #xE6ECF4) (mb-at (mb :y -0.256) (mb-box mb 0.24 0.014 0.04))))
(defweapon :ru-sleeve-ice (:length 0.26 :ink-color #x7F97B4)
  (:solid (mbc mb #x16161E) (mb-at (mb :y -0.13) (mb-bevel-box mb 0.24 0.26 0.032 0.012))))
(defweapon :ru-bk-sleeve (:length 0.56 :ink-color #x7F97B4)
  (:solid (mbc mb #xEEEEEA) (mb-at (mb :y -0.28) (mb-bevel-box mb 0.27 0.56 0.03 0.012))
          (mbc mb #x9AA8BE) (mb-at (mb :y -0.55) (mb-box mb 0.272 0.012 0.034))))   ; the lined hem

(defun-fast %ru-gore-m! (jm st o i cp out)
  "OUT = gore I's world matrix: the pelvis (JM 0..15) turned by the yaw lag ST[O+8] and I's place round the waist, its
hinge CP[2] m out at CP[1] up (rig m), swung out by CP[3] + CP[4] x |lag| + the bell's tilt (ST[O+4] back, ST[O+6] to
her right) on its bearing, 0 .. 1.15 rad. CP[0] the gores."
  (declare (type f32vec jm st cp out) (fixnum o i))
  (let* ((lag (aref st (+ o 8))) (a (+ lag (* (/ 6.2831855f0 (aref cp 0)) (i->f i)))) (sa (f-sin a)) (ca (f-cos a))
         (phi (f-clamp (+ (aref cp 3) (* (aref cp 4) (f-abs lag)) (* (aref st (+ o 6)) sa) (* (aref st (+ o 4)) ca)) 0f0 1.15f0))
         (sp (f-sin phi)) (cp2 (f-cos phi)) (hy (aref cp 1)) (hr (aref cp 2)))
    (declare (single-float lag a sa ca phi sp cp2 hy hr))
    (dotimes (k 3)                                     ; (the pelvis's local +Z is her back)
      (let* ((xp (aref jm k)) (yp (aref jm (+ 4 k))) (zp (aref jm (+ 8 k)))
             (r (+ (* sa xp) (* ca zp))) (tg (- (* ca xp) (* sa zp))))
        (declare (single-float xp yp zp r tg))
        (setf (aref out k) tg
              (aref out (+ 4 k)) (- (* cp2 yp) (* sp r))
              (aref out (+ 8 k)) (+ (* sp yp) (* cp2 r))
              (aref out (+ 12 k)) (+ (aref jm (+ 12 k)) (* hy yp) (* hr r)))))
    (setf (aref out 3) 0f0 (aref out 7) 0f0 (aref out 11) 0f0 (aref out 15) 1f0))
  nil)

(defmacro %ru-steps ((ns sdt) dt &body body)
  "Run BODY in substeps of <= 1/60 s over DT (NS of SDT each; none when DT is 0)."
  `(when (> ,dt 0f0)
     (let* ((,ns (max 1 (min 4 (f->i (+ 0.999f0 (* 60f0 ,dt)))))) (,sdt (/ ,dt (i->f ,ns))))
       (declare (fixnum ,ns) (single-float ,sdt) (ignorable ,sdt))
       ,@body)))

(defun-fast %ru-pend! (jm st o j cp out)
  "Step the hanging sleeve at ST[O..O+6] under joint J (a forearm) and set OUT to its panel's matrix. CP: [0] the panel's
drop (rig m), [1] dt, [2] its middle's place along the bone (rig m from the elbow), [3] the velocity kept a 1/60 s step.
The panel's foot is a damped pendulum CP[0] from the forearm's middle: OUT's -Y is the hang (to the foot), its X the
forearm made square to it (a forearm along the hang: the joint's own X), origin the middle; a rotation (nothing scaled)."
  (declare (type f32vec jm st cp out) (fixnum o j))
  (let* ((jo (* 16 j)) (ax (aref jm (+ jo 4))) (ay (aref jm (+ jo 5))) (az (aref jm (+ jo 6)))
         (s (f-max 1f-5 (f-hypot ax ay az))) (h (aref cp 2)) (len (* s (aref cp 0))) (dt (aref cp 1)) (keep (aref cp 3))
         (mx (- (aref jm (+ jo 12)) (* h ax))) (my (- (aref jm (+ jo 13)) (* h ay))) (mz (- (aref jm (+ jo 14)) (* h az))))
    (declare (single-float ax ay az s h len dt keep mx my mz) (fixnum jo))
    (macrolet ((con ()                                 ; the foot back to LEN from the middle
                 `(let* ((dx (- (aref st o) mx)) (dy (- (aref st (+ o 1)) my)) (dz (- (aref st (+ o 2)) mz))
                         (l (f-max 1f-5 (f-hypot dx dy dz))))
                    (declare (single-float dx dy dz l))
                    (setf (aref st o) (+ mx (* len (/ dx l))) (aref st (+ o 1)) (+ my (* len (/ dy l)))
                          (aref st (+ o 2)) (+ mz (* len (/ dz l)))))))
      (when (or (< (aref st (+ o 6)) 0.5f0)
                (> (f-hypot (- (aref st o) mx) (- (aref st (+ o 1)) my) (- (aref st (+ o 2)) mz)) (* 3f0 len)))
        (setf (aref st (+ o 6)) 1f0 (aref st o) mx (aref st (+ o 1)) (- my len) (aref st (+ o 2)) mz
              (aref st (+ o 3)) mx (aref st (+ o 4)) (- my len) (aref st (+ o 5)) mz))
      (%ru-steps (ns sdt) dt
        (let ((gy (* 9.8f0 sdt sdt)))
          (declare (single-float gy))
          (dotimes (k ns)
            (dotimes (c 3)
              (let* ((x (aref st (+ o c))) (v (* keep (- x (aref st (+ o 3 c))))))
                (declare (single-float x v))
                (setf (aref st (+ o 3 c)) x (aref st (+ o c)) (+ x v))))
            (decf (aref st (+ o 1)) gy)
            (con))))
      (con))
    (let* ((dx (/ (- (aref st o) mx) len)) (dy (/ (- (aref st (+ o 1)) my) len)) (dz (/ (- (aref st (+ o 2)) mz) len))
           (ux (/ ax s)) (uy (/ ay s)) (uz (/ az s)) (da (+ (* ux dx) (* uy dy) (* uz dz))) (l 0f0))
      (declare (single-float dx dy dz ux uy uz da l))
      (setf ux (- ux (* da dx)) uy (- uy (* da dy)) uz (- uz (* da dz)) l (f-hypot ux uy uz))
      (if (< l 0.2f0)                                  ; (the forearm along the hang: its joint's X)
          (let ((bx (aref jm jo)) (by (aref jm (+ jo 1))) (bz (aref jm (+ jo 2))))
            (declare (single-float bx by bz))
            (setf da (/ (+ (* bx dx) (* by dy) (* bz dz)) s) ux (- (/ bx s) (* da dx)) uy (- (/ by s) (* da dy))
                  uz (- (/ bz s) (* da dz)) l (f-max 1f-5 (f-hypot ux uy uz)))))
      (setf ux (/ ux l) uy (/ uy l) uz (/ uz l))
      (let ((zx (- (* uz dy) (* uy dz))) (zy (- (* ux dz) (* uz dx))) (zz (- (* uy dx) (* ux dy))))   ; X x Y = u x (-d)
        (declare (single-float zx zy zz))
        (setf (aref out 0) (* s ux) (aref out 1) (* s uy) (aref out 2) (* s uz) (aref out 3) 0f0
              (aref out 4) (* (- s) dx) (aref out 5) (* (- s) dy) (aref out 6) (* (- s) dz) (aref out 7) 0f0
              (aref out 8) (* s zx) (aref out 9) (* s zy) (aref out 10) (* s zz) (aref out 11) 0f0
              (aref out 12) mx (aref out 13) my (aref out 14) mz (aref out 15) 1f0))))
  nil)

(defun-fast %ru-chain! (st o n cp)
  "Step chain O's N segments (header ST[O]: 1 once primed; point i at O+1+6i: x y z, then its last x y z; point 0 the pin)
by CP: [0] the segment (m), [1] dt, [2] drag, [3] stiffness, [4..6] the pin now, [7 8] her back on the plaza (x z: the
prime's trail), [9] the floor's height. The pin moves along its path over the substeps; three passes of the segments'
lengths (and the straightening pull) each substep; the plaza takes half the speed of a point lying on it."
  (declare (type f32vec st cp) (fixnum o n))
  (let* ((seg (aref cp 0)) (dt (aref cp 1)) (drag (aref cp 2)) (stiff (aref cp 3))
         (qx (aref cp 4)) (qy (aref cp 5)) (qz (aref cp 6)) (g0 (aref cp 9)) (p0 (+ o 1)))
    (declare (single-float seg dt drag stiff qx qy qz g0) (fixnum p0))
    (when (or (< (aref st o) 0.5f0)
              (> (f-hypot (- qx (aref st p0)) (- qy (aref st (+ p0 1))) (- qz (aref st (+ p0 2)))) 1.5f0))
      (setf (aref st o) 1f0)                           ; prime: straight down to the plaza, then along it behind her
      (let ((drop (f-max 0f0 (- qy g0))))
        (declare (single-float drop))
        (dotimes (i (1+ n))
          (let* ((d (* seg (i->f i))) (k (+ p0 (* 6 i))) (tr (f-max 0f0 (- d drop))))
            (declare (single-float d tr) (fixnum k))
            (setf (aref st k) (+ qx (* tr (aref cp 7))) (aref st (+ k 1)) (f-max g0 (- qy d)) (aref st (+ k 2)) (+ qz (* tr (aref cp 8)))
                  (aref st (+ k 3)) (aref st k) (aref st (+ k 4)) (aref st (+ k 1)) (aref st (+ k 5)) (aref st (+ k 2)))))))
    (%ru-steps (ns sdt) dt
      (let ((gy (* 9.8f0 sdt sdt)) (keep (- 1f0 drag))
            (ox (aref st (+ p0 3))) (oy (aref st (+ p0 4))) (oz (aref st (+ p0 5))))
        (declare (single-float gy keep ox oy oz))
        (dotimes (s ns)
          (let ((u (/ (i->f (1+ s)) (i->f ns))))
            (declare (single-float u))
            (setf (aref st p0) (+ ox (* u (- qx ox))) (aref st (+ p0 1)) (+ oy (* u (- qy oy))) (aref st (+ p0 2)) (+ oz (* u (- qz oz)))))
          (loop for i fixnum from 1 to n
                do (let ((k (+ p0 (* 6 i))))
                     (declare (fixnum k))
                     (dotimes (c 3)
                       (let* ((x (aref st (+ k c))) (v (* keep (- x (aref st (+ k 3 c))))))
                         (declare (single-float x v))
                         (setf (aref st (+ k 3 c)) x (aref st (+ k c)) (+ x v))))
                     (decf (aref st (+ k 1)) gy)
                     (when (< (aref st (+ k 1)) g0)          ; on the plaza: it keeps half its sliding speed
                       (setf (aref st (+ k 1)) g0
                             (aref st (+ k 3)) (- (aref st k) (* 0.5f0 (- (aref st k) (aref st (+ k 3)))))
                             (aref st (+ k 5)) (- (aref st (+ k 2)) (* 0.5f0 (- (aref st (+ k 2)) (aref st (+ k 5)))))))))
          (dotimes (it 3)
            (loop for i fixnum from 1 to n
                  do (let* ((a (+ p0 (* 6 (1- i)))) (b (+ a 6))
                            (dx (- (aref st b) (aref st a))) (dy (- (aref st (+ b 1)) (aref st (+ a 1))))
                            (dz (- (aref st (+ b 2)) (aref st (+ a 2)))) (l (f-max 1f-5 (f-hypot dx dy dz)))
                            (c (/ (- l seg) l)) (wa (if (= i 1) 0f0 0.5f0)) (wb (- 1f0 wa)))
                       (declare (fixnum a b) (single-float dx dy dz l c wa wb))
                       (setf (aref st a) (+ (aref st a) (* wa c dx)) (aref st (+ a 1)) (+ (aref st (+ a 1)) (* wa c dy))
                             (aref st (+ a 2)) (+ (aref st (+ a 2)) (* wa c dz))
                             (aref st b) (- (aref st b) (* wb c dx)) (aref st (+ b 1)) (- (aref st (+ b 1)) (* wb c dy))
                             (aref st (+ b 2)) (- (aref st (+ b 2)) (* wb c dz)))
                       (when (and (> stiff 0f0) (>= i 2))   ; straighten: onto the line of the two before it
                         (let ((z (- a 6)))
                           (declare (fixnum z))
                           (dotimes (q 3)
                             (setf (aref st (+ b q))
                                   (+ (aref st (+ b q))
                                      (* stiff (- (- (* 2f0 (aref st (+ a q))) (aref st (+ z q))) (aref st (+ b q))))))))))))
          (loop for i fixnum from 1 to n
                do (let ((k (+ p0 (* 6 i) 1))) (declare (fixnum k)) (setf (aref st k) (f-max g0 (aref st k))))))
        (setf (aref st (+ p0 3)) qx (aref st (+ p0 4)) qy (aref st (+ p0 5)) qz))))
  nil)

(defun-fast %ru-chain-draw (st o m cp)
  "Draw chain O's first M segments as one camera-facing toon strip: CP [10] the half width (m), [11] its TOON-A, [12] its
seed (an along shape), [13] its heat (the core's place: constant along it, so nothing erodes)."
  (declare (type f32vec st cp) (fixnum o m))
  (let* ((p0 (+ o 1)) (w (aref cp 10)) (pk (aref cp 11)) (sd (aref cp 12)) (ht (aref cp 13)) (eye (camera-eye *camera*))
         (ex (aref eye 0)) (ey (aref eye 1)) (ez (aref eye 2))
         (lx 0f0) (ly 0f0) (lz 0f0) (qx 0f0) (qy 0f0) (qz 0f0))
    (declare (fixnum p0) (single-float w pk sd ht ex ey ez lx ly lz qx qy qz) (type f32vec eye))
    (with-fx-verts (dd oo :toon (* 6 m))
      (dotimes (i (1+ m))
        (let* ((k (+ p0 (* 6 i))) (ka (+ p0 (* 6 (max 0 (1- i))))) (kb (+ p0 (* 6 (min m (1+ i)))))
               (x (aref st k)) (y (aref st (+ k 1))) (z (aref st (+ k 2)))
               (tx (- (aref st kb) (aref st ka))) (ty (- (aref st (+ kb 1)) (aref st (+ ka 1))))
               (tz (- (aref st (+ kb 2)) (aref st (+ ka 2))))
               (vx (- ex x)) (vy (- ey y)) (vz (- ez z))
               (sx (- (* ty vz) (* tz vy))) (sy (- (* tz vx) (* tx vz))) (sz (- (* tx vy) (* ty vx)))
               (f (/ w (f-max 1f-6 (f-hypot sx sy sz))))
               (ax (- x (* f sx))) (ay (- y (* f sy))) (az (- z (* f sz)))
               (bx (+ x (* f sx))) (by (+ y (* f sy))) (bz (+ z (* f sz))))
          (declare (fixnum k ka kb) (single-float x y z tx ty tz vx vy vz sx sy sz f ax ay az bx by bz))
          (when (> i 0)
            (vtx lx ly lz -1f0 0f0 ht sd 0f0 pk) (vtx qx qy qz 1f0 0f0 ht sd 0f0 pk) (vtx bx by bz 1f0 0f0 ht sd 0f0 pk)
            (vtx lx ly lz -1f0 0f0 ht sd 0f0 pk) (vtx bx by bz 1f0 0f0 ht sd 0f0 pk) (vtx ax ay az -1f0 0f0 ht sd 0f0 pk))
          (setf lx ax ly ay lz az qx bx qy by qz bz)))))
  nil)

(defun-fast %ru-pin! (jm j lx ly lz cp)
  "CP[4..6] = joint J's local point (LX LY LZ: rig m, single-float forms; a macro-free inline sum), CP[7 8] = where a primed
chain lies on the plaza: behind her and out to her right (the pelvis's local +Z + 0.8 +X, made unit: off the behind camera's
line), CP[9] the floor."
  (declare (type f32vec jm cp) (fixnum j) (single-float lx ly lz))
  (let ((o (* 16 j)) (bx (+ (aref jm 8) (* 0.8f0 (aref jm 0)))) (bz (+ (aref jm 10) (* 0.8f0 (aref jm 2)))))
    (declare (fixnum o) (single-float bx bz))
    (dotimes (i 3)
      (setf (aref cp (+ 4 i)) (+ (aref jm (+ o 12 i)) (* lx (aref jm (+ o i))) (* ly (aref jm (+ o 4 i))) (* lz (aref jm (+ o 8 i))))))
    (let ((l (f-max 1f-5 (f-hypot bx bz)))) (declare (single-float l)) (setf (aref cp 7) (/ bx l) (aref cp 8) (/ bz l)))
    (setf (aref cp 9) 0.02f0))
  nil)

(defun ru-band (f)
  "The cloth's band for fighter F: 0 the Shikai, 1 -18, 2 -50, 3 absolute zero."
  (case (kit-form (fighter-kit f)) (:m18 1) (:m50 2) (:zero 3) (t 0)))

;; the parameters of each piece into *RU-CP* (floats set here, inside DEFUN-FAST: a float in a plain function boxes)
(defun-fast %ru-dt! (cp dt) (declare (type f32vec cp) (single-float dt)) (setf (aref cp 15) dt) nil)
(defun-fast %ru-gore-cp! (cp bk)
  "CP for %RU-GORE-M!: the gores, the hinge 0.03 below the pelvis joint (the sash's foot), the waist 0.15 m, the rest flare
(the hakama's bell 0.3 rad, the Bankai's kimono 0.1), *RU-GORE-FLARE*. BK 1: the Bankai's."
  (declare (type f32vec cp) (fixnum bk))
  (setf (aref cp 0) (i->f *ru-gores*) (aref cp 1) -0.03f0 (aref cp 2) 0.15f0 (aref cp 3) (if (= bk 1) 0.1f0 0.3f0)
        (aref cp 4) (the single-float (f32 *ru-gore-flare*)))
  nil)
(defun-fast %ru-sleeve-cp! (cp bk)
  "CP for %RU-PEND!: the panel's drop (the Bankai's knee-long 0.56 rig m, the shihakusho's 0.26), its middle 0.12 m down the
forearm, 0.92 of the velocity kept a step; the effect seconds."
  (declare (type f32vec cp) (fixnum bk))
  (setf (aref cp 0) (if (= bk 1) 0.56f0 0.26f0) (aref cp 1) (aref cp 15) (aref cp 2) 0.12f0 (aref cp 3) 0.92f0)
  nil)
(defun-fast %ru-ribbon-cp! (cp band side)
  "CP for %RU-CHAIN! / %RU-CHAIN-DRAW, the sword's ribbon in BAND (*RU-RIBBON-BANDS*; the Bankai's three: band 4), drawn for
SIDE (its seed); the floor and the pin come from %RU-PIN!. Its drawn segments are RU-RIBBON-DRAWN's."
  (declare (type f32vec cp) (fixnum band side))
  (let ((b (assoc (min band 3) *ru-ribbon-bands*)))
    (setf (aref cp 1) (aref cp 15) (aref cp 11) (toon-a +pal-soul+ 0.95f0) (aref cp 13) 0.6f0)
    (if (= band 4)
        (setf (aref cp 0) 0.2f0 (aref cp 2) 0.03f0 (aref cp 3) 0f0 (aref cp 10) 0.03f0 (aref cp 12) (- -43f0 (i->f side)))
        (setf (aref cp 0) (the single-float (f32 *ru-ribbon-seg*)) (aref cp 2) (the single-float (f32 (second b)))
              (aref cp 3) (the single-float (f32 (third b))) (aref cp 10) (the single-float (f32 *ru-ribbon-w*))
              (aref cp 12) (- -40f0 (i->f side)))))
  nil)
(defun ru-ribbon-drawn (band) "The sword ribbon's drawn segments in BAND (*RU-RIBBON-BANDS*)." (fourth (assoc band *ru-ribbon-bands*)))

;;; ---------------------------------------------------------------- 霜の穂先 (frost points: the Shikai's K reach, DUEL_RUKIA_TYBW §13.2)
;;; Her K volumes reach 2.5-3.1 m and her blade ~1.7 m (§13.1): each Shikai K carries a solid piece of ice past the point,
;;; growing over the startup's last frames and shattering into snow after the hit (K1 a spike along the thrust, K2 a curved
;;; sheet trailing the cut, K3 a column dropped with the blade). Drawn by RUKIA-LOOK-DRAW (%RU-FROST!) off the drawn blade;
;;; the FK test (tests/duel-rules/art.lisp) reads the same table: the tip of the ice is the striking point, within 0.15 m
;;; of the volume's far edge. A look: the sim reads none of it. 0 B a frame.
(defparameter *ru-frost-points* '((:ru-s-k1 1.15 :ru-frost-spike) (:ru-s-k2 1.3 :ru-frost-sheet) (:ru-s-k3 1.4 :ru-frost-column)
                                  (:ru-18-k1 1.5 :ru-frost-bloom :palm) (:ru-18-k2 1.2 :ru-frost-sleeve)
                                  (:ru-18-k3 1.8 :ru-frost-flower :flat))
  "霜の穂先: clip -> metres of ice past the blade's tip along its axis, and its mesh (the user 2026-10-24: 「霜の穂先」,
DUEL_RUKIA_TYBW §13.7; sized to the volumes: K1 2.85 (3.10 before §14), K2 2.50, K3 3.05 m). A fourth :palm: the ice
grows off her left palm (the wrist, :hand-l) along the forearm instead; :flat: the same along the plaza (the forearm's
level heading). -18's own (§13.4, its K reach kept: K1 2.35, K2 2.50, K3 2.40 m): TOSHU's frost bloom off the palm, K2's
frost sheet off the sleeve's cut, HYOKA's ice flower run out from the palm on the plaza.")
(defparameter *ru-frost-grow* 6 "霜の穂先: it grows over the startup's last this many frames (a look; new 2026-10-24).")
(defparameter *ru-frost-shatter* 6 "... and shatters into snow over this many frames after the active ones (a look; new 2026-10-24).")
(defweapon :ru-frost-spike (:length 1.0 :ink-color #x7F97B4)   ; K1: a four-sided spike along the thrust, two crystals off its root
  (:solid (mbc mb #xE6ECF4) (mb-at (mb :y 0.5) (mb-cone mb 0.05 1.0 :segments 4))
          (mbc mb #xF8FAFC)
          (mb-at (mb :y 0.12 :x 0.035 :roll -0.6) (mb-cone mb 0.02 0.16 :segments 4))
          (mb-at (mb :y 0.22 :x -0.03 :roll 0.7) (mb-cone mb 0.016 0.12 :segments 4))))
(defweapon :ru-frost-sheet (:length 1.0 :ink-color #x7F97B4)   ; K2: a broad curved sheet, its point swept back off the cut
  (:solid :ink 0.7 (mb-blade mb :length 0.917 :width 0.15 :thickness 0.014 :curve 0.16 :segments 6 :hilt nil
                             :blade-color '(0.9 0.93 0.97) :edge-color '(1.0 1.0 1.0))))
(defweapon :ru-frost-column (:length 1.0 :ink-color #x7F97B4)  ; K3: a hexagonal column with a pointed end, shards off its sides
  (:solid (mbc mb #xE6ECF4) (mb-at (mb :y 0.42) (mb-prism mb 0.075 0.84 6))
          (mb-at (mb :y 0.92) (mb-cone mb 0.075 0.16 :segments 6))
          (mbc mb #xF8FAFC)
          (mb-at (mb :y 0.3 :x 0.07 :roll -0.5) (mb-cone mb 0.026 0.2 :segments 4))
          (mb-at (mb :y 0.55 :x -0.07 :roll 0.5) (mb-cone mb 0.022 0.16 :segments 4))))
(defweapon :ru-frost-bloom (:length 1.0 :ink-color #x7F97B4)   ; -18 K1: frost blooming off the palm, crystals splayed round a core
  (:solid (mbc mb #xE6ECF4) (mb-at (mb :y 0.5) (mb-cone mb 0.07 1.0 :segments 5))
          (mbc mb #xF8FAFC)
          (mb-at (mb :y 0.3 :x 0.07 :roll -0.35) (mb-cone mb 0.04 0.6 :segments 4))
          (mb-at (mb :y 0.24 :x -0.07 :roll 0.4) (mb-cone mb 0.035 0.48 :segments 4))
          (mb-at (mb :y 0.2 :z 0.07 :pitch 0.4) (mb-cone mb 0.03 0.4 :segments 4))
          (mb-at (mb :y 0.16 :z -0.06 :pitch -0.45) (mb-cone mb 0.03 0.32 :segments 4))))
(defweapon :ru-frost-sleeve (:length 1.0 :ink-color #x7F97B4)  ; -18 K2: a wide frost sheet thrown off the sleeve's cut, jagged
  (:solid :ink 0.7 (mb-blade mb :length 0.94 :width 0.24 :thickness 0.012 :curve 0.24 :segments 6 :hilt nil
                             :blade-color '(0.9 0.93 0.97) :edge-color '(1.0 1.0 1.0))
          (mbc mb #xF8FAFC)
          (mb-at (mb :y 0.34 :x 0.12 :roll -0.9) (mb-cone mb 0.025 0.22 :segments 4))
          (mb-at (mb :y 0.62 :x 0.1 :roll -0.8) (mb-cone mb 0.02 0.18 :segments 4))))
(defweapon :ru-frost-flower (:length 1.0 :ink-color #x7F97B4)  ; -18 K3: ice run out along the plaza (+Z up), the flower at its end
  (:solid (mbc mb #xE6ECF4) (mb-at (mb :y 0.42 :z 0.02 :roll 0.5) (mb-prism mb 0.05 0.84 3))
          (mbc mb #xF8FAFC)
          (mb-at (mb :y 0.25 :z 0.06 :pitch 1.2) (mb-cone mb 0.03 0.14 :segments 4))
          (mb-at (mb :y 0.55 :z 0.07 :pitch 1.0) (mb-cone mb 0.035 0.18 :segments 4))
          (mbc mb #xE6ECF4)
          (mb-at (mb :y 0.92 :z 0.12 :pitch 1.57) (mb-cone mb 0.05 0.3 :segments 5))           ; the flower: a core and
          (mb-at (mb :y 0.92 :x 0.08 :z 0.08 :pitch 1.57 :roll -0.6) (mb-cone mb 0.04 0.22 :segments 4))   ; five petals
          (mb-at (mb :y 0.92 :x -0.08 :z 0.08 :pitch 1.57 :roll 0.6) (mb-cone mb 0.04 0.22 :segments 4))
          (mb-at (mb :y 0.96 :z 0.08 :pitch 1.0) (mb-cone mb 0.04 0.22 :segments 4))
          (mb-at (mb :y 0.88 :z 0.08 :pitch 2.1) (mb-cone mb 0.04 0.2 :segments 4))))
(defvar *ru-frost-m* (m4) "霜の穂先's world matrix (the weapon frame at the blade's tip, its +Y the ice's length).")

(defun-fast %ru-frost! (jm an fr wp cp rim tint flash)
  "The frost point FR (a *RU-FROST-POINTS* entry) of the clip AN plays, off the blade of weapon WP posed in JM: its length
grows 0 -> FR's metres over the last *RU-FROST-GROW* startup frames, holds through the active ones, then the piece is gone
and its snow and shards fall from where it stood over *RU-FROST-SHATTER* frames. CP[15] the frame's seconds. 0 B."
  (declare (type f32vec jm cp))
  (let* ((c (anim-clip an)) (tf (* 60f0 (the single-float (anim-time an))))
         (s (* 60f0 (the single-float (clip-mark c :s)))) (a (* 60f0 (the single-float (clip-mark c :a))))
         (gr (i->f (the fixnum *ru-frost-grow*))) (sh (i->f (the fixnum *ru-frost-shatter*)))
         (lmax (the single-float (second fr))) (dt (aref cp 15)) (m *ru-frost-m*) (o (* 16 (ji :weapon-r))))
    (declare (single-float tf s a gr sh lmax dt) (type f32vec m) (fixnum o))
    (when (and (> tf (- s gr)) (< tf (+ a sh)))
      (let ((l (if (< tf s) (* lmax (/ (- tf (- s gr)) gr)) lmax)) (mode (fourth fr)))
        (declare (single-float l))
        (if mode
            ;; off the palm (-18): the frame at the wrist, its +Y the forearm's heading (:flat: level, +Z up), stretched
            (let* ((oe (* 16 (ji :lower-arm-l))) (oh (* 16 (ji :hand-l)))
                   (sc (f-max 1f-5 (f-hypot (aref jm oe) (aref jm (+ oe 1)) (aref jm (+ oe 2)))))
                   (dx (- (aref jm (+ oh 12)) (aref jm (+ oe 12))))
                   (dy (if (eq mode :flat) 0f0 (- (aref jm (+ oh 13)) (aref jm (+ oe 13)))))
                   (dz (- (aref jm (+ oh 14)) (aref jm (+ oe 14))))
                   (n (/ l (f-max 1f-5 (f-hypot dx dy dz)))))
              (declare (fixnum oe oh) (single-float sc dx dy dz n))
              (replace m jm :start2 oe :end2 (+ oe 16))
              (dotimes (i 3) (setf (aref m (+ 12 i)) (aref jm (+ oh 12 i)) (aref m i) (- (aref m i))))   ; (180 deg about Z)
              (setf (aref m 4) (* n dx) (aref m 5) (* n dy) (aref m 6) (* n dz))
              (when (eq mode :flat)
                (let ((q (/ sc (f-max 1f-5 (f-hypot dx 0f0 dz)))))
                  (declare (single-float q))
                  (setf (aref m 0) (* q (- dz)) (aref m 1) 0f0 (aref m 2) (* q dx)
                        (aref m 8) 0f0 (aref m 9) sc (aref m 10) 0f0
                        (aref m 13) (f-min (aref m 13) 0.02f0)))))   ; (on the plaza under the palm)
            (let ((wl (the single-float (weapon-len wp))) (sc 0f0))
              (declare (single-float wl sc))
              (replace m jm :start2 o :end2 (+ o 16))
              (m4-mul! m m *weapon-m*)
              (setf sc (f-max 1f-5 (f-hypot (aref m 4) (aref m 5) (aref m 6))))
              (dotimes (i 3)                             ; the frame moved to the tip, its +Y stretched to the ice's length
                (setf (aref m (+ 12 i)) (+ (aref m (+ 12 i)) (* wl (aref m (+ 4 i))))
                      (aref m (+ 4 i)) (* (/ l sc) (aref m (+ 4 i)))))))
        (if (< tf a)
            (draw-weapon (third fr) m :rim rim :tint tint :flash flash)
            ;; shattered: snow and shards from along where it stood, thrown out and falling
            (let ((x (aref m 12)) (y (aref m 13)) (z (aref m 14)) (ux (aref m 4)) (uy (aref m 5)) (uz (aref m 6)))
              (declare (single-float x y z ux uy uz))
              (dotimes (i (n-of 500f0 dt))
                (let ((u (rnd-range 0f0 1f0)))
                  (declare (single-float u))
                  (%t-shard (+ x (* u ux)) (+ y (* u uy)) (+ z (* u uz)) (rnd-range -1.6f0 1.6f0) (rnd-range 0.2f0 2.2f0)
                            (rnd-range -1.6f0 1.6f0) (rnd-range 0.3f0 0.6f0) (rnd-range 0.04f0 0.09f0) 6f0 +pal-soul+)))
              (dotimes (i (n-of 400f0 dt))
                (let ((u (rnd-range 0f0 1f0)))
                  (declare (single-float u))
                  (%t-blob (+ x (* u ux)) (+ y (* u uy)) (+ z (* u uz)) (rnd-range -0.5f0 0.5f0) (rnd-range -0.1f0 0.4f0)
                           (rnd-range -0.5f0 0.5f0) (rnd-range 0.6f0 1.1f0) (rnd-range 0.02f0 0.045f0) -0.2f0 0.2f0 +pal-hit+)))))))
    nil))

(declaim (special *super-rim*))                         ; (draw.lisp's, loaded later)
(defun rukia-look-draw (e rdt)
  "KIT-HOOK :draw (her every form; rukia-meter.lisp registers it on each): the moving cloth on the posed body (above):
the bell of gores, the hanging sleeves, the ribbons, the Shikai K's 霜の穂先 (%RU-FROST!); the 白霞罸 costume's when the drawn
body is :RUKIA-BANKAI. Nothing
while her body isn't drawn (a vanishing Hoho, ENBU's flash step)."
  (let* ((m (model e)) (f (fighter e)) (mv (current-move f)))
    (when (and (>= (model-alpha m) 0.999)
               (not (and mv (eq (mv-kind mv) :kikon) (eq (getf (mv-params mv) :look) :flash-step) (rush-dashing-p f))))
      (let* ((jm (model-joints m)) (st *ru-cloth*) (cp *ru-cp*) (side (fighter-side f)) (o (* +ru-side+ side))
             (bk (if (eq (model-body m) (find-body :rukia-bankai)) 1 0)) (band (ru-band f)) (tint (model-tint m))
             (rim (if (> (model-super m) 0) *super-rim* (or (model-rim m) (body-rim (model-body m)))))
             (fl (> (model-flash m) 0)) (w (model-weapon m)))
        (declare (fixnum side o bk band))
        (let ((dt (if (typep rdt 'single-float) rdt (f32 rdt))))   ; (the boxed float passed on as it came: 0 B)
          (%ru-dt! cp dt)
          ;; the bell: the hem spring (Yamamoto's), then the gores
          (%ya-hem-pose jm st o 0)
          (%ya-hem-step st o dt))
        (%ru-gore-cp! cp bk)
        (let ((key (cond ((= bk 1) :ru-bk-gore) ((= band 2) :ru-gore-rime) ((= band 3) :ru-gore-ice) (t :ru-gore))))
          (dotimes (i *ru-gores*)
            (%ru-gore-m! jm st o i cp *ru-m*)
            (draw-weapon key *ru-m* :rim rim :tint tint :flash (if fl 0.45 0.0))))
        ;; the hanging sleeves (the Bankai's both, knee-long)
        (%ru-sleeve-cp! cp bk)
        (%ru-pend! jm st (+ o +ru-pend+) (ji :lower-arm-r) cp *ru-m*)
        (draw-weapon (cond ((= bk 1) :ru-bk-sleeve) ((= band 2) :ru-sleeve-rime) ((= band 3) :ru-sleeve-ice) (t :ru-sleeve)) *ru-m* :rim rim :tint tint
                     :flash (if fl 0.45 0.0))
        (when (= bk 1)
          (%ru-pend! jm st (+ o +ru-pend+ 7) (ji :lower-arm-l) cp *ru-m*)
          (draw-weapon :ru-bk-sleeve *ru-m* :rim rim :tint tint :flash (if fl 0.45 0.0)))
        ;; 霜の穂先: the Shikai's K ice off the point (*RU-FROST-POINTS*)
        (let* ((an (model-anim m)) (c (anim-clip an)) (fr (and w c (assoc (clip-name c) *ru-frost-points*))))
          (when fr (%ru-frost! jm an fr (find-weapon w) cp rim tint (if fl 0.45 0.0))))
        ;; the ribbons: the sword's (a white blade drawn in her hand), the Bankai's three from her back
        (when (and (member w '(:sode-no-shirayuki :ru-rime :ru-ice))
                   (not (and mv (mv-planted mv) (eq (fighter-phase f) :main))))
          (%ru-ribbon-cp! cp (if (= bk 1) 3 band) side)
          (if (eq w :ru-ice) (%ru-pin! jm (ji :weapon-r) 0f0 0f0 0.258f0 cp) (%ru-pin! jm (ji :weapon-r) 0f0 0f0 0.235f0 cp))
          (%ru-chain! st (+ o +ru-sword+) *ru-ribbon-segs* cp)
          (%ru-chain-draw st (+ o +ru-sword+) (ru-ribbon-drawn (if (= bk 1) 3 band)) cp))
        (when (= bk 1)
          (%ru-ribbon-cp! cp 4 side)
          (%ru-pin! jm (ji :pelvis) -0.07f0 0.08f0 0.15f0 cp)
          (%ru-chain! st (+ o +ru-bk+) 10 cp) (%ru-chain-draw st (+ o +ru-bk+) 10 cp)
          (%ru-pin! jm (ji :pelvis) 0f0 0.05f0 0.16f0 cp)
          (%ru-chain! st (+ o +ru-bk+ 67) 10 cp) (%ru-chain-draw st (+ o +ru-bk+ 67) 10 cp)
          (%ru-pin! jm (ji :pelvis) 0.07f0 0.08f0 0.15f0 cp)
          (%ru-chain! st (+ o +ru-bk+ 134) 10 cp) (%ru-chain-draw st (+ o +ru-bk+ 134) 10 cp))))))

(defun rukia-look-cons-check ()
  "Debug 85900 (P1 Rukia, e.g. after 85507): bytes consed by 10 calls of RUKIA-LOOK-DRAW in each look (the Shikai, -18,
-50, zero, the Bankai costume), standing and in the form's J (its first link's hit frame); then the Shikai's and -18's K
霜の穂先 (each K's clip at its S and just after its active frames). Each must be 0. (The probe queues its 1220 calls'
meshes in one frame: the first 1000, Bankai costume calls, let the draw queue grow to hold them all.)"
  (let* ((e *p1*) (f (fighter e)) (m (model e)) (b0 (model-body m)) (w0 (model-weapon m)) (k0 (fighter-kit f))
         (st (fighter-state f)) (mv (fighter-move f)) (ph (fighter-phase f)) (sf (fighter-sf f)) (out nil))
    (setf (model-body m) (find-body :rukia-bankai) (model-weapon m) :ru-ice)
    (dotimes (i 1000) (rukia-look-draw e 0.016))         ; (warm: this frame's draw queue grows once to hold the probe's meshes)
    (flet ((bytes () (let ((c0 (cons-bytes))) (dotimes (i 10) (rukia-look-draw e 0.016)) (- (cons-bytes) c0))))
      (dolist (look '((:base :rukia :sode-no-shirayuki) (:m18 :rukia :sode-no-shirayuki) (:m50 :rukia :ru-rime)
                      (:zero :rukia-zero :ru-ice) (:zero :rukia-bankai :ru-ice)))
        (setf (fighter-kit f) (fighter-find-kit e (first look)) (model-body m) (find-body (second look))
              (model-weapon m) (third look) (fighter-state f) :idle)
        (push (bytes) out)
        (setf (fighter-state f) :move (fighter-move f) (kit-command-move (fighter-kit f) :q) (fighter-phase f) :main (fighter-sf f) (mv-s (fighter-move f)))
        (push (bytes) out))
      ;; the Shikai's and -18's K 霜の穂先 (%RU-FROST!: drawn off the model's clip): each K's clip at its S (the ice) and after its
      ;; active frames (the shatter)
      (let* ((an (model-anim m)) (c0 (anim-clip an)) (t0 (anim-time an)) (fr nil))
        (setf (fighter-kit f) k0 (model-body m) (find-body :rukia) (model-weapon m) :sode-no-shirayuki (fighter-state f) :idle)
        (dolist (p *ru-frost-points*)
          (anim-play an (first p) :blend 0 :time (clip-mark (first p) :s)) (push (bytes) fr)
          (anim-play an (first p) :blend 0 :time (+ (clip-mark (first p) :a) 0.05)) (push (bytes) fr))
        (when c0 (anim-play an (clip-name c0) :blend 0 :time t0))
        (push (reverse fr) out)))
    (setf (fighter-kit f) k0 (model-body m) b0 (model-weapon m) w0
          (fighter-state f) st (fighter-move f) mv (fighter-phase f) ph (fighter-sf f) sf)
    (log-msg "duel rukia look consing (10 calls, B; standing / J1 hit): base ~{~d~^ / ~} | -18 ~{~d~^ / ~} | -50 ~{~d~^ / ~} | zero ~{~d~^ / ~} | bankai ~{~d~^ / ~} | frost Shikai K1-K3, -18 K1-K3 (ice / shatter) ~{~d~^ / ~}"
             (subseq (reverse out) 0 2) (subseq (reverse out) 2 4) (subseq (reverse out) 4 6) (subseq (reverse out) 6 8)
             (subseq (reverse out) 8 10) (first out))))

;;; ---------------------------------------------------------------- poses
;;; Her rig notes: the right side leads (a fencer's stance: the right foot forward, the body turned left, the head turned
;;; back to him); the blade is one-handed and runs on from the arm (hand flex ~ -90); a horizontal cut is the arm held out
;;; (side ~88) swept by its flex (0 = to her right, 90 = ahead, 130 = ahead-left); the free left arm dances (out and back
;;; in the cuts, forward in the kido and the bare-hand links). Hit poses (DEFSTRIKE :s) put the blade or the palm where
;;; the move's volume is (rukia.lisp: its reach, arc and line).
(defpose :ru-stance ()                                 ; Shikai: light on the balls of the feet, the white blade low forward
  (:root :u -0.045) (:pelvis :twist 28) (:spine :flex 8) (:chest :twist 6) (:neck :twist -14) (:head :flex -6 :twist -16)
  (:arm-r :flex 34 :side 14) (:elbow-r :flex 22) (:hand-r :twist -10 :flex -66)
  (:arm-l :flex 34 :side 40) (:elbow-l :flex 70) (:hand-l :flex -20)
  (:thigh-r :flex 24 :side 6) (:thigh-l :flex -14 :side 10) (:knee-r :flex 22) (:knee-l :flex 18))

(defclip :ru-stance (1.8 :loop t :base :ru-stance)    ; a light bounce; the point breathes
  (0) (0.9 (:root :u -0.058) (:chest :flex 2) (:hand-r :flex -62) (:elbow-l :flex 74)))

(defpose :ru-cold-stance ()                            ; the cold body: lower and stiller, the blade reversed back along the
  (:root :u -0.1) (:pelvis :twist 18) (:spine :flex 12) (:chest :twist -16) (:neck :twist 8) (:head :flex -8 :twist -2)
  (:arm-r :flex -12 :side 24) (:elbow-r :flex 30) (:hand-r :twist 160 :flex 20)                  ; forearm, the bare left
  (:arm-l :flex 58 :side 10) (:elbow-l :flex 30) (:hand-l :flex -40)                             ; palm open ahead
  (:thigh-r :flex 30 :side 8) (:thigh-l :flex -18 :side 12) (:knee-r :flex 38) (:knee-l :flex 16))

(defclip :ru-cold-stance (2.6 :loop t :base :ru-cold-stance)
  (0) (1.3 (:root :u -0.107) (:elbow-l :flex 33)))

(defpose :ru-zero-pose ()                              ; absolute zero: still, upright, the point down, the head a little bowed
  (:root :u -0.015) (:pelvis :twist 10) (:spine :flex 2) (:chest :twist -4) (:neck :twist -4) (:head :flex 12)
  (:arm-r :flex 14 :side 12) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -80)
  (:arm-l :flex 6 :side 8) (:elbow-l :flex 14) (:hand-l :flex -10)
  (:thigh-r :flex 6 :side 5) (:thigh-l :flex -2 :side 6) (:knee-r :flex 6) (:knee-l :flex 4))

(defclip :ru-zero (4.0 :loop t :base :ru-zero-pose) (0) (2.0 (:root :u -0.02) (:head :flex 13)))

;;; ---------------------------------------------------------------- the Shikai grid (§3.2)
(defpose :ru-q1-hit (:base :ru-stance)                 ; J1 HATSUSHIMO: the flat one-handed cut through, the left arm flung back
  (:root :f 0.32 :u -0.13 :yaw 4) (:pelvis :twist 24) (:spine :flex 10) (:chest :twist 12) (:neck :twist -10) (:head :twist -10)
  (:arm-r :side 88 :flex 94) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -86)
  (:arm-l :flex -30 :side 62) (:elbow-l :flex 20) (:hand-l :flex -30)
  (:thigh-r :flex 46 :side 4) (:knee-r :flex 46) (:thigh-l :flex -26) (:knee-l :flex 20))
(defstrike :ru-q1 (7 3 12 :base :ru-stance)
  (0)
  (3 (:root :u -0.07 :yaw -10) (:chest :twist -34) (:neck :twist 10) (:head :twist -6) (:arm-r :side 88 :flex -12) (:elbow-r :flex 16)
     (:hand-r :twist 0 :flex -84) (:arm-l :flex 40 :side 30) (:elbow-l :flex 60) (:knee-r :flex 30))
  (:s :snap :ru-q1-hit)
  (8 (:chest :twist 18) (:arm-r :flex 100) (:root :f 0.34))
  (:a (:chest :twist 16) (:arm-r :flex 98) (:root :f 0.34))
  (16 (:chest :twist 14) (:arm-r :side 50 :flex 70) (:elbow-r :flex 20) (:hand-r :flex -70) (:root :f 0.1 :u -0.1 :yaw 2)
      (:arm-l :flex 10 :side 50) (:elbow-l :flex 50))
  (:end :ru-stance))

(defpose :ru-q2-hit (:base :ru-stance)                 ; J2 KAZAHANA: the wrist turned over, the backhand back along the line
  (:root :f 0.02 :u -0.11 :yaw -6) (:pelvis :twist 24) (:spine :flex 8 :side 6) (:chest :twist -14) (:neck :twist 0) (:head :twist -4)
  (:arm-r :side 88 :flex 42) (:elbow-r :flex 20 :twist 160) (:hand-r :twist 0 :flex -86)
  (:arm-l :flex 50 :side 56) (:elbow-l :flex 30) (:hand-l :flex -30)
  (:thigh-r :flex 38) (:knee-r :flex 40) (:thigh-l :flex -22) (:knee-l :flex 22))
(defstrike :ru-q2 (7 3 13 :base :ru-stance)
  (0)
  (3 (:root :u -0.08 :yaw 8) (:chest :twist 26) (:neck :twist -20) (:head :twist -16) (:arm-r :side 88 :flex 128) (:elbow-r :flex 20 :twist 160)
     (:hand-r :twist 0 :flex -80) (:arm-l :flex -20 :side 50) (:elbow-l :flex 30))
  (:s :snap :ru-q2-hit)
  (8 (:chest :twist -18) (:arm-r :flex 36) (:root :f 0.04))
  (:a (:chest :twist -17) (:arm-r :flex 38) (:root :f 0.03))
  (17 (:chest :twist -4) (:arm-r :side 40 :flex 40) (:elbow-r :flex 24 :twist 40) (:hand-r :twist 0 :flex -60) (:root :f 0.02 :u -0.07)
      (:arm-l :flex 30 :side 44) (:elbow-l :flex 60))
  (:end :ru-stance))

(defstrike :ru-spin (8 3 18 :base :ru-stance)          ; J3 MAI-SODE: the pirouette on the ball of the foot, the blade and the
  (0)                                                  ; left arm out wide, the rear leg drawn up: "the dance"
  (4 (:root :u -0.1 :yaw -16) (:knees :flex 36) (:chest :twist -30) (:neck :twist 14) (:arm-r :side 88 :flex -6) (:elbow-r :flex 4)
     (:hand-r :twist 0 :flex -88) (:arm-l :side 70 :flex 30) (:elbow-l :flex 20) (:head :flex -4))
  (6 (:root :u -0.12 :yaw -26) (:chest :twist -36))
  (:s :snap (:root :yaw 360 :u -0.01 :f 0.22) (:pelvis :twist 20) (:chest :twist 10) (:neck :twist -10) (:head :twist -10 :flex 4)
      (:arm-r :side 88 :flex 26) (:elbow-r :flex 10) (:hand-r :flex -88) (:arm-l :side 86 :flex 24) (:elbow-l :flex 10)
      (:thigh-r :flex 6) (:knee-r :flex 8) (:thigh-l :flex 26 :side 14) (:knee-l :flex 84))
  (:a (:root :yaw 382 :u -0.02 :f 0.24) (:chest :twist 14))
  (22 (:root :yaw 372 :u -0.07 :f 0.2) (:chest :twist 10) (:arm-r :side 50 :flex 30) (:elbow-r :flex 24) (:hand-r :flex -60)
      (:arm-l :side 50 :flex 40) (:elbow-l :flex 40) (:thigh-l :flex -6) (:knee-l :flex 24) (:thigh-r :flex 20) (:knee-r :flex 24))
  (:end :ru-stance (:root :yaw 360)))

(defpose :ru-thrust-hit (:base :ru-stance)             ; K1 SHIMO-TSUKI: the fencer's lunge, the rear arm flung up behind
  (:root :f 0.46 :u -0.2 :yaw -4) (:pelvis :twist 18) (:spine :flex 12) (:chest :twist 6) (:neck :twist -26) (:head :flex -8 :twist -20)
  (:arm-r :flex 98 :side 2) (:elbow-r :flex 0) (:hand-r :twist -20 :flex -88)
  (:arm-l :flex -50 :side 50) (:elbow-l :flex 30) (:hand-l :flex -40)
  (:thigh-r :flex 66 :side 4) (:knee-r :flex 64) (:thigh-l :flex -34 :side 8) (:knee-l :flex 6))
(defstrike :ru-thrust (17 4 20 :base :ru-stance)
  (0)
  (6 (:root :u -0.09 :f -0.04) (:chest :twist -20) (:neck :twist 6) (:arm-r :flex 10 :side 10) (:elbow-r :flex 120)
     (:hand-r :twist -10 :flex -70) (:arm-l :flex 56 :side 20) (:elbow-l :flex 20) (:knees :flex 32))
  (14 (:root :u -0.11 :f -0.06) (:chest :twist -24) (:arm-r :flex 6) (:elbow-r :flex 126) (:arm-l :flex 60))
  (:s :snap :ru-thrust-hit)
  (18 (:root :f 0.5) (:arm-r :flex 100))
  (:a (:root :f 0.49) (:arm-r :flex 99))
  (32 (:root :f 0.26 :u -0.12) (:arm-r :flex 50 :side 12) (:elbow-r :flex 24) (:hand-r :twist -10 :flex -66) (:thigh-r :flex 40)
      (:knee-r :flex 40) (:arm-l :flex 10 :side 40) (:elbow-l :flex 50))
  (:end :ru-stance))

(defpose :ru-ring-hit (:base :ru-stance)               ; K2 HYORIN: out of the turn, the blade swept up before her
  (:root :u 0.02 :f 0.18) (:pelvis :twist 18) (:spine :flex -10) (:chest :twist 14) (:neck :twist -12) (:head :flex -20 :twist -10)
  (:arm-r :flex 124 :side 12) (:elbow-r :flex 4) (:hand-r :twist -10 :flex -84)
  (:arm-l :flex 10 :side 76) (:elbow-l :flex 10)
  (:thigh-r :flex 22) (:knee-r :flex 16) (:thigh-l :flex -10) (:knee-l :flex 4))
(defstrike :ru-ring (21 4 24 :base :ru-stance)
  (0)
  (10 (:root :u -0.15 :yaw -120) (:pelvis :twist 10) (:chest :twist -10) (:spine :flex 26) (:neck :twist 24) (:head :flex 6 :twist 30)
      (:arm-r :flex -24 :side 30) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -70) (:arm-l :flex 40 :side 40) (:elbow-l :flex 40)
      (:knees :flex 52) (:thighs :flex 30))
  (18 (:root :u -0.17 :yaw -136) (:spine :flex 28) (:arm-r :flex -30) (:knees :flex 56))
  (:s :snap :ru-ring-hit)
  (23 (:arm-r :flex 132) (:root :u 0.03))
  (:a (:arm-r :flex 130) (:root :u 0.03))
  (38 (:root :u -0.04 :f 0.1) (:spine :flex 4) (:arm-r :flex 90 :side 16) (:elbow-r :flex 20) (:hand-r :flex -66) (:head :flex -8)
      (:arm-l :flex 30 :side 50) (:elbow-l :flex 50) (:knees :flex 22))
  (:end :ru-stance))

(defpose :ru-drop-hit (:base :ru-stance)               ; K3 NADARE: both hands, dropped from high through him, a deep step
  (:root :u -0.2 :f 0.36 :yaw -2) (:pelvis :twist 10) (:spine :flex 30) (:chest :twist 0) (:neck :twist -6) (:head :flex -20 :twist -6)
  (:arm-r :flex 96 :side 0) (:elbow-r :flex 6) (:hand-r :twist -10 :flex -72)
  (:arm-l :flex 94 :side -12) (:elbow-l :flex 16) (:hand-l :flex -30)
  (:thigh-r :flex 58 :side 6) (:knee-r :flex 60) (:thigh-l :flex -24 :side 8) (:knee-l :flex 24))
(defstrike :ru-drop (21 5 34 :base :ru-stance)
  (0)
  (8 (:root :u 0.03) (:pelvis :twist 14) (:chest :twist 0) (:neck :twist -6) (:arm-r :flex 176 :side 6) (:elbow-r :flex 12)
     (:hand-r :twist -5 :flex -40) (:arm-l :flex 168 :side -14) (:elbow-l :flex 24) (:spine :flex -12) (:head :flex -30)
     (:thigh-r :flex 14) (:knee-r :flex 12) (:thigh-l :flex -6) (:knee-l :flex 8))
  (17 (:root :u 0.04) (:arm-r :flex 180) (:arm-l :flex 172) (:spine :flex -15))
  (:s :snap :ru-drop-hit)
  (23 (:spine :flex 38) (:root :u -0.24 :f 0.38) (:arm-r :flex 52) (:arm-l :flex 50))
  (:a (:spine :flex 36) (:root :u -0.23 :f 0.38) (:arm-r :flex 54) (:arm-l :flex 52))
  (44 (:spine :flex 30) (:root :u -0.2 :f 0.34))
  (52 (:spine :flex 12) (:root :u -0.09 :f 0.14) (:arm-r :flex 40 :side 14) (:elbow-r :flex 24) (:hand-r :flex -64)
      (:arm-l :flex 30 :side 30) (:elbow-l :flex 60) (:thigh-r :flex 34) (:knee-r :flex 32) (:head :flex -10))
  (:end :ru-stance))
(pushnew :ru-drop *grip-clips*)                        ; the two-handed drop: the left fist held on the handle

;;; ---------------------------------------------------------------- the rest of the Shikai (§3.3)
(defstrike :ru-tsukishiro (10 0 26 :base :ru-stance)   ; L TSUKISHIRO: low, the point on the plaza drawn round in one sweep,
  (0)                                                  ; the body turning with it, the left arm out for the balance
  (4 (:root :u -0.16 :yaw -10) (:knees :flex 52) (:thighs :flex 20) (:spine :flex 24) (:chest :twist -20) (:neck :twist 10)
     (:head :flex 16) (:arm-r :side 44 :flex 30) (:elbow-r :flex 4) (:hand-r :twist 0 :flex -86) (:arm-l :side 70 :flex 10)
     (:elbow-l :flex 20))
  (:s :snap (:root :u -0.2 :yaw 150) (:arm-r :side 46 :flex 34) (:spine :flex 26) (:knees :flex 56))
  (24 (:root :u -0.19 :yaw 350) (:arm-r :side 44 :flex 36))
  (32 (:root :u -0.1 :yaw 360) (:spine :flex 10) (:arm-r :side 30 :flex 30) (:elbow-r :flex 26) (:hand-r :flex -60) (:knees :flex 30)
      (:thighs :flex 10))
  (:end :ru-stance (:root :yaw 360)))

(defpose :ru-stab-pose (:base :ru-stance)              ; SP1's hold (and HYOSHIN): the point driven into the plaza before her
  (:root :u -0.2) (:pelvis :twist 16) (:knees :flex 64) (:thighs :flex 40) (:spine :flex 36) (:chest :twist 0) (:neck :twist -6)
  (:head :flex 14) (:arm-r :flex 56 :side 6) (:elbow-r :flex 30) (:hand-r :twist 160 :flex 10)
  (:arm-l :flex 16 :side 46) (:elbow-l :flex 30) (:hand-l :flex -30))
(defclip :ru-stab (0.27 :loop t :base :ru-stab-pose)   ; stab, lift, stab: one stab per 16 f
  (0 :snap (:arm-r :flex 50) (:root :u -0.21))
  (0.1 (:arm-r :flex 72) (:elbow-r :flex 44) (:root :u -0.18))
  (0.2 (:arm-r :flex 64) (:root :u -0.19)))

(defpose :ru-hakuren-hit (:base :ru-stab-pose)         ; SP1 release: the blade swept up out of the plaza, the cold off the tip
  (:root :u -0.02 :f 0.2) (:knees :flex 22) (:thighs :flex 10) (:spine :flex -8) (:arm-r :flex 126 :side 12) (:elbow-r :flex 4)
  (:hand-r :twist -10 :flex -84) (:head :flex -16) (:arm-l :side 70 :flex -10) (:elbow-l :flex 10))
(defstrike :ru-hakuren (6 1 24 :base :ru-stance)
  (0 :ru-stab-pose)
  (:s :snap :ru-hakuren-hit)
  (:a (:arm-r :flex 130))
  (20 (:arm-r :flex 100 :side 18) (:elbow-r :flex 20) (:hand-r :flex -60) (:spine :flex 4) (:knees :flex 26) (:root :u -0.06 :f 0.1))
  (:end :ru-stance))

(defpose :ru-shirafune-hit (:base :ru-thrust-hit)      ; SP2 SHIRAFUNE: the deepest one-handed thrust, the rear leg straight
  (:root :f 0.66 :u -0.27) (:spine :flex 16) (:chest :twist 8) (:thigh-r :flex 78) (:knee-r :flex 80) (:thigh-l :flex -44)
  (:knee-l :flex 2) (:arm-r :flex 102) (:arm-l :flex -60 :side 40))
(defstrike :ru-shirafune (16 4 28 :base :ru-stance)
  (0)
  (7 (:root :u -0.12 :f -0.06) (:chest :twist -26) (:neck :twist 10) (:arm-r :flex 6 :side 10) (:elbow-r :flex 124)
     (:hand-r :twist -10 :flex -70) (:arm-l :flex 60 :side 16) (:elbow-l :flex 16) (:knees :flex 40))
  (13 (:root :u -0.14 :f -0.08) (:chest :twist -30) (:arm-r :flex 2) (:elbow-r :flex 130))
  (:s :snap :ru-shirafune-hit)
  (:a (:root :f 0.7) (:arm-r :flex 103))
  (36 (:root :f 0.5 :u -0.22))
  (44 (:root :f 0.2 :u -0.1) (:arm-r :flex 44 :side 14) (:elbow-r :flex 26) (:hand-r :twist -10 :flex -64) (:thigh-r :flex 36)
      (:knee-r :flex 36) (:thigh-l :flex -18) (:knee-l :flex 18) (:arm-l :flex 20 :side 40) (:elbow-l :flex 50))
  (:end :ru-stance))

(defclip :ru-breaker (0.4 :loop t :base :ru-stance)    ; the Breaker's dash: low, the blade trailing behind, the left hand ahead
  (0 (:root :u -0.1) (:pelvis :twist 10) (:spine :flex 34) (:chest :twist -6) (:neck :twist 0) (:head :flex -28 :twist 0)
     (:arm-r :flex -40 :side 26) (:elbow-r :flex 16) (:hand-r :twist 0 :flex -100)
     (:arm-l :flex 64 :side 10) (:elbow-l :flex 36)
     (:thigh-r :flex 45) (:knee-r :flex 20) (:thigh-l :flex -30) (:knee-l :flex 45))
  (0.2 (:root :u -0.06) (:thigh-l :flex 45) (:knee-l :flex 20) (:thigh-r :flex -30) (:knee-r :flex 45)))

(defpose :ru-hainawa-hit (:base :ru-stance)            ; I HAINAWA: the left hand snaps forward, two fingers pointed; the blade
  (:root :f 0.34 :u -0.12) (:pelvis :twist 0) (:spine :flex 10) (:chest :twist -26) (:neck :twist 14) (:head :flex -6 :twist 12)
  (:arm-l :flex 96 :side 2) (:elbow-l :flex 0) (:hand-l :flex -80)                             ; held back behind her
  (:arm-r :flex -34 :side 30) (:elbow-r :flex 20) (:hand-r :twist 0 :flex -96)
  (:thigh-r :flex 44) (:knee-r :flex 42) (:thigh-l :flex -20) (:knee-l :flex 16))
(defstrike :ru-hainawa (8 4 18 :base :ru-stance)
  (0 (:arm-l :flex 30 :side 20) (:elbow-l :flex 110) (:chest :twist 16) (:root :u -0.1))
  (5 (:arm-l :flex 26) (:elbow-l :flex 122) (:chest :twist 20) (:root :u -0.11))
  (:s :snap :ru-hainawa-hit)
  (:a (:root :f 0.36) (:arm-l :flex 97))
  (24 (:arm-l :flex 44 :side 26) (:elbow-l :flex 50) (:chest :twist -4) (:root :f 0.14 :u -0.08))
  (:end :ru-stance))

;;; ---------------------------------------------------------------- cinematics / intro / win (§5, §6)
(defclip :ru-kikon (2.0 :base :ru-stance)              ; ENBU's Kikon: the pirouette ending; held as a dancer (the card's
  (0 (:root :yaw 384 :u -0.02 :f 0.3) (:pelvis :twist 20) (:chest :twist 14) (:neck :twist -10) (:head :twist -10)   ; silhouette:
     (:arm-r :side 88 :flex 30) (:elbow-r :flex 0) (:hand-r :twist 0 :flex -88)                ; the blade out, the left arm
     (:arm-l :side 86 :flex 24) (:elbow-l :flex 10) (:thigh-l :flex 26 :side 14) (:knee-l :flex 84)      ; up, a foot drawn up)
     (:thigh-r :flex 6) (:knee-r :flex 8))
  (0.2 (:root :yaw 366) (:arm-l :side 150 :flex 16) (:elbow-l :flex 36) (:hand-l :flex -20) (:head :flex -8))
  (0.95 (:root :yaw 362 :u -0.03) (:arm-l :side 154) (:head :flex -10))
  (1.2 (:root :u -0.16 :yaw 360 :f 0.2) (:knees :flex 56) (:thighs :flex 22) (:spine :flex 24) (:chest :twist -20)   ; then low,
       (:neck :twist 10) (:head :flex 16) (:arm-r :side 44 :flex 30) (:hand-r :flex -86) (:arm-l :side 70 :flex 10)  ; the point
       (:elbow-l :flex 20) (:thigh-l :flex 20 :side 8) (:knee-l :flex 56))                     ; on the plaza drawn round
  (1.7 (:root :u -0.17 :yaw 700 :f 0.2) (:arm-r :flex 30))
  (2.0 (:root :u -0.06 :yaw 720 :f 0.1) (:knees :flex 20) (:thighs :flex 6) (:spine :flex 6) (:chest :twist 0) (:head :flex 0)
       (:arm-r :side 20 :flex 16) (:elbow-r :flex 10) (:hand-r :flex -70) (:arm-l :side 14 :flex 10) (:elbow-l :flex 20)
       (:thigh-l :flex -8) (:knee-l :flex 14)))

(defclip :ru-intro (2.0 :base :ru-stance)              ; the sealed katana held out before her and turned counter-clockwise
  (0 (:root :u -0.01) (:pelvis :twist 16) (:chest :twist 4) (:neck :twist -10) (:head :flex -4 :twist -10)   ; (her view) a full
     (:arm-r :flex 60 :side 6) (:elbow-r :flex 30) (:hand-r :twist 0 :flex -20) (:arm-l :flex 10 :side 12)    ; turn; white at the
     (:elbow-l :flex 20) (:thigh-r :flex 10) (:thigh-l :flex -6) (:knees :flex 6))                           ; release (f70)
  (0.35 (:arm-r :flex 84 :side 4) (:elbow-r :flex 6) (:hand-r :twist 0 :flex 0))
  (0.55 (:hand-r :twist 90))
  (0.75 (:hand-r :twist 180))
  (0.95 (:hand-r :twist 270))
  (1.12 (:hand-r :twist 350))
  (1.17 :snap (:arm-r :flex 70 :side 20) (:hand-r :twist 360 :flex -80) (:chest :twist 14) (:head :flex -8)
        (:arm-l :flex 20 :side 40) (:elbow-l :flex 40))
  (1.5 (:arm-r :flex 50 :side 16) (:hand-r :twist 356 :flex -70))
  (2.0 :ru-stance (:hand-r :twist 350)))

(defclip :ru-win (2.0 :base :ru-stance)                ; a flick of the blade, then lowered at her side, turned half away
  (0)
  (0.25 (:arm-r :side 60 :flex 30) (:elbow-r :flex 4) (:hand-r :flex -86) (:chest :twist -10))
  (0.4 :snap (:arm-r :side 30 :flex -10) (:hand-r :flex -80) (:chest :twist 4))
  (0.9 (:root :u -0.005 :yaw 20) (:pelvis :twist 10) (:spine :flex 2) (:chest :twist 0) (:neck :twist -10) (:head :flex 6 :twist -20)
       (:arm-r :flex 12 :side 14) (:elbow-r :flex 6) (:hand-r :twist 0 :flex -84) (:arm-l :flex 30 :side 6) (:elbow-l :flex 96)
       (:hand-l :flex -10) (:thigh-r :flex 4) (:thigh-l :flex -4) (:knees :flex 4))
  (2.0 (:root :u -0.005 :yaw 20) (:head :flex 8 :twist -22)))

(defclip :ru-hand (2.0 :base :ru-zero-pose)            ; 白霞罸's last shot: her right hand on the hilt before her, the back of
  (0 (:arm-r :flex 60 :side -20) (:elbow-r :flex 90) (:hand-r :twist -175 :flex 20) (:head :flex 24) (:spine :flex 6))  ; the fist
  (0.6 (:arm-r :flex 56) (:elbow-r :flex 86) (:hand-r :flex 16))                                  ; (the crack) turned to the
  (2.0 (:arm-r :flex 34 :side -10) (:elbow-r :flex 60) (:hand-r :twist -170 :flex -10) (:head :flex 20)))   ; lens; lowered

(defclip :ru-awaken (2.0 :base :ru-zero-pose)          ; 絶対零度: the blade lowered, point down, the head bowing, the eyes closing
  (0 (:head :flex 0) (:arm-r :flex 30 :side 14) (:hand-r :flex -60))
  (0.6 (:head :flex 12) (:root :u -0.02) (:arm-r :flex 16) (:hand-r :flex -76) (:arm-l :flex 24 :side 4) (:elbow-l :flex 80))
  (2.0 (:head :flex 16) (:root :u -0.025) (:arm-r :flex 14) (:hand-r :flex -80) (:arm-l :flex 26 :side 4) (:elbow-l :flex 84)))

;;; ---------------------------------------------------------------- the awakened moves (§4.2; the user's decision: 2 new links)
(defpose :ru-palm-hit (:base :ru-cold-stance)          ; K1 TOSHU: the bare left palm driven out, catching; the blade kept back
  (:root :f 0.44 :u -0.16) (:pelvis :twist -4) (:spine :flex 12) (:chest :twist -30) (:neck :twist 18) (:head :flex -6 :twist 14)
  (:arm-l :flex 98 :side 0) (:elbow-l :flex 2) (:hand-l :flex -70)
  (:arm-r :flex -26 :side 30) (:elbow-r :flex 30) (:hand-r :twist 160 :flex 20)
  (:thigh-r :flex 50) (:knee-r :flex 48) (:thigh-l :flex -26) (:knee-l :flex 12))
(defstrike :ru-palm (17 4 20 :base :ru-cold-stance)
  (0)
  (8 (:arm-l :flex 34 :side 30) (:elbow-l :flex 110) (:hand-l :flex -20) (:chest :twist 14) (:neck :twist -8) (:root :u -0.16)
     (:knees :flex 42))
  (15 (:arm-l :flex 30) (:elbow-l :flex 120) (:chest :twist 18) (:root :u -0.17))
  (:s :snap :ru-palm-hit)
  (:a (:root :f 0.46) (:arm-l :flex 99))
  (32 (:root :f 0.24 :u -0.11) (:arm-l :flex 60 :side 10) (:elbow-l :flex 30) (:chest :twist -20) (:thigh-r :flex 36) (:knee-r :flex 40))
  (:end :ru-cold-stance))

(defpose :ru-flower-hit (:base :ru-cold-stance)        ; K3 HYOKA: down on one knee, the palm driven flat into the plaza
  (:root :u -0.5 :f 0.26) (:pelvis :twist 0) (:spine :flex 46) (:chest :twist -16) (:neck :twist 10) (:head :flex -16 :twist 6)
  (:arm-l :flex 36 :side 4) (:elbow-l :flex 0) (:hand-l :flex 50)
  (:arm-r :flex -30 :side 40) (:elbow-r :flex 26) (:hand-r :twist 160 :flex 20)
  (:thigh-r :flex 74) (:knee-r :flex 116) (:thigh-l :flex -4 :side 12) (:knee-l :flex 100))
(defstrike :ru-flower (21 5 34 :base :ru-cold-stance)
  (0)
  (8 (:root :u 0.02) (:arm-l :flex 160 :side 10) (:elbow-l :flex 16) (:hand-l :flex -30) (:spine :flex -8) (:chest :twist 10)
     (:head :flex -24) (:thigh-r :flex 20) (:knee-r :flex 16) (:thigh-l :flex -10) (:knee-l :flex 10))
  (17 (:root :u 0.03) (:arm-l :flex 168) (:spine :flex -11))
  (:s :snap :ru-flower-hit)
  (:a (:root :u -0.51) (:spine :flex 48))
  (46 (:root :u -0.49 :f 0.26))
  (54 (:root :u -0.2 :f 0.12) (:spine :flex 22) (:arm-l :flex 44 :side 10) (:elbow-l :flex 30) (:hand-l :flex -30) (:thigh-r :flex 50)
      (:knee-r :flex 60) (:thigh-l :flex -10) (:knee-l :flex 50))
  (:end :ru-cold-stance))

(defstrike :ru-reido (6 0 26 :base :ru-zero-pose)      ; REIDO TOKETSU: the eyes open, the left palm swept out low, a burst
  (0)
  (3 (:arm-l :flex 40 :side -24) (:elbow-l :flex 50) (:root :u -0.05) (:chest :twist 20))
  (:s :snap (:arm-l :flex 24 :side 58) (:elbow-l :flex 0) (:hand-l :flex -40) (:root :u -0.08) (:knees :flex 28) (:thighs :flex 12)
      (:spine :flex 14) (:chest :twist -16) (:neck :twist 8) (:head :flex -6) (:hand-r :flex -60))
  (18 (:arm-l :flex 22 :side 56) (:root :u -0.075))
  (:end :ru-cold-stance))

(defpose :ru-hakka-hit (:base :ru-cold-stance)         ; HAKKA: the blade levelled at him, the cold running off the tip
  (:root :u -0.1 :f 0.22) (:pelvis :twist 14) (:spine :flex 6) (:chest :twist 2) (:neck :twist -20) (:head :flex -8 :twist -16)
  (:arm-r :flex 98 :side 2) (:elbow-r :flex 0) (:hand-r :twist 0 :flex -88)
  (:arm-l :flex 20 :side 40) (:elbow-l :flex 40) (:hand-l :flex -30)
  (:thigh-r :flex 36) (:knee-r :flex 40))
(defstrike :ru-hakka (20 3 30 :base :ru-cold-stance)
  (0)
  (4 (:root :u 0.0) (:pelvis :twist 14) (:chest :twist 0) (:neck :twist -6) (:arm-r :flex 176 :side 4) (:elbow-r :flex 4)
     (:hand-r :twist 0 :flex -86) (:spine :flex -8) (:head :flex -26) (:arm-l :flex 10 :side 20) (:elbow-l :flex 20)
     (:thigh-r :flex 10) (:knee-r :flex 10) (:thigh-l :flex -6) (:knee-l :flex 8))
  (16 (:arm-r :flex 180) (:root :u 0.01))
  (:s :snap :ru-hakka-hit)
  (:a (:root :f 0.24))
  (40 (:root :f 0.18 :u -0.1) (:arm-r :flex 60 :side 10) (:elbow-r :flex 20) (:hand-r :twist 60 :flex -40))
  (:end :ru-cold-stance))

;;; ---------------------------------------------------------------- the colder bands' motions (key edits, §4.2 / §4.3)
;; -50 C: TOSHU with the blade driven in beside the palm; MAI-SODE two-handed and low; HYOKA with both palms; the quake
;; with both hands on the hilt. Zero: J1 and the thrust with the feet pinned (rooted: the ice reaches, she doesn't step)
(defpose :ru-palm-50-hit (:base :ru-palm-hit)
  (:arm-r :flex 70 :side 10) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -80) (:chest :twist -20) (:root :u -0.2))
(defstrike :ru-palm-50 (17 4 20 :base :ru-cold-stance)
  (0)
  (8 (:arm-l :flex 34 :side 30) (:elbow-l :flex 110) (:arm-r :flex 20 :side 20) (:elbow-r :flex 90) (:chest :twist 14)
     (:root :u -0.18) (:knees :flex 46))
  (15 (:arm-l :flex 30) (:elbow-l :flex 120) (:arm-r :flex 16) (:chest :twist 18) (:root :u -0.19))
  (:s :snap :ru-palm-50-hit)
  (:a (:root :f 0.46) (:arm-l :flex 99) (:arm-r :flex 72))
  (32 (:root :f 0.24 :u -0.12) (:arm-l :flex 60 :side 10) (:elbow-l :flex 30) (:arm-r :flex 20 :side 24) (:elbow-r :flex 30)
      (:chest :twist -20) (:thigh-r :flex 36) (:knee-r :flex 40))
  (:end :ru-cold-stance))

(defstrike :ru-spin-50 (8 3 18 :base :ru-cold-stance)   ; MAI-SODE at -50: both hands on the hilt, low and heavy
  (0)
  (4 (:root :u -0.18 :yaw -16) (:knees :flex 50) (:chest :twist -30) (:neck :twist 14) (:arm-r :side 70 :flex 10) (:elbow-r :flex 20)
     (:hand-r :twist 0 :flex -88) (:arm-l :side 50 :flex 40) (:elbow-l :flex 60))
  (6 (:root :u -0.2 :yaw -26) (:chest :twist -36))
  (:s :snap (:root :yaw 360 :u -0.14 :f 0.3) (:pelvis :twist 20) (:chest :twist 10) (:neck :twist -10) (:head :twist -10 :flex 4)
      (:arm-r :side 80 :flex 30) (:elbow-r :flex 10) (:hand-r :flex -88) (:arm-l :side 60 :flex 48) (:elbow-l :flex 56)
      (:thigh-r :flex 30) (:knee-r :flex 40) (:thigh-l :flex -10 :side 14) (:knee-l :flex 30))
  (:a (:root :yaw 378 :u -0.15 :f 0.32) (:chest :twist 14))
  (22 (:root :yaw 370 :u -0.12 :f 0.28) (:chest :twist 8) (:arm-r :side 44 :flex 30) (:elbow-r :flex 30) (:hand-r :flex -60)
      (:arm-l :side 40 :flex 40) (:elbow-l :flex 50))
  (:end :ru-cold-stance (:root :yaw 360)))

(defpose :ru-flower-50-hit (:base :ru-flower-hit)
  (:arm-r :flex 36 :side -4) (:elbow-r :flex 0) (:hand-r :twist 0 :flex 50) (:chest :twist 0) (:spine :flex 52))
(defstrike :ru-flower-50 (21 5 34 :base :ru-cold-stance)   ; HYOKA at -50: both palms driven down
  (0)
  (8 (:root :u 0.02) (:arm-l :flex 160 :side 10) (:elbow-l :flex 16) (:arm-r :flex 160 :side -10) (:elbow-r :flex 16)
     (:hand-r :twist 0) (:spine :flex -8) (:head :flex -24) (:thigh-r :flex 20) (:knee-r :flex 16) (:thigh-l :flex -10) (:knee-l :flex 10))
  (17 (:root :u 0.03) (:arm-l :flex 168) (:arm-r :flex 168) (:spine :flex -11))
  (:s :snap :ru-flower-50-hit)
  (:a (:root :u -0.51) (:spine :flex 54))
  (46 (:root :u -0.49 :f 0.26))
  (54 (:root :u -0.2 :f 0.12) (:spine :flex 22) (:arm-l :flex 44 :side 10) (:elbow-l :flex 30) (:arm-r :flex -20 :side 36)
      (:elbow-r :flex 26) (:hand-r :twist 160 :flex 20) (:thigh-r :flex 50) (:knee-r :flex 60) (:thigh-l :flex -10) (:knee-l :flex 50))
  (:end :ru-cold-stance))

(defpose :ru-stab-2h-pose (:base :ru-stab-pose)        ; HYOSHIN: both hands on the hilt, driving the blade into the plaza
  (:arm-l :flex 60 :side -10) (:elbow-l :flex 34) (:hand-l :flex 0) (:chest :twist -8) (:root :u -0.24) (:spine :flex 42))
(defclip :ru-stab-2h (0.4 :base :ru-stab-2h-pose)
  (0 :snap (:arm-r :flex 70) (:arm-l :flex 74) (:root :u -0.14) (:spine :flex 20))
  (0.2 :snap (:arm-r :flex 50) (:arm-l :flex 56) (:root :u -0.26) (:spine :flex 44))
  (0.4 (:root :u -0.24)))

(defstrike :ru-q1-z (7 3 12 :base :ru-zero-pose)        ; J1 at zero: the flat cut from where she stands (feet pinned)
  (0)
  (3 (:chest :twist -34) (:arm-r :side 88 :flex -12) (:elbow-r :flex 16) (:hand-r :twist 0 :flex -84) (:arm-l :flex 30 :side 30))
  (:s :snap :ru-q1-hit (:root :f 0.0 :u -0.05) (:thigh-r :flex 14) (:knee-r :flex 16) (:thigh-l :flex -8) (:knee-l :flex 8))
  (:a (:chest :twist 16) (:arm-r :flex 98) (:root :f 0.0 :u -0.05))
  (16 (:chest :twist 8) (:arm-r :side 40 :flex 50) (:elbow-r :flex 20) (:hand-r :flex -70) (:root :f 0.0 :u -0.03))
  (:end :ru-zero-pose))

(defstrike :ru-thrust-z (17 4 20 :base :ru-zero-pose)   ; K1 at zero: the thrust from a planted stance, the ice does the reaching
  (0)
  (8 (:chest :twist -20) (:arm-r :flex 10 :side 10) (:elbow-r :flex 120) (:hand-r :twist -10 :flex -70) (:root :u -0.06))
  (14 (:chest :twist -24) (:arm-r :flex 6) (:elbow-r :flex 126) (:root :u -0.07))
  (:s :snap :ru-thrust-hit (:root :f 0.06 :u -0.08) (:thigh-r :flex 20) (:knee-r :flex 22) (:thigh-l :flex -10) (:knee-l :flex 6))
  (:a (:arm-r :flex 99) (:root :f 0.06 :u -0.08))
  (32 (:root :f 0.02 :u -0.04) (:arm-r :flex 40 :side 12) (:elbow-r :flex 24) (:hand-r :twist -10 :flex -70))
  (:end :ru-zero-pose))

;;; ---------------------------------------------------------------- the Shikai's own clips (DUEL_RUKIA_TYBW §13.3)
;;; 「原作舉止＋日本舞踊」 (§2, §13.7): J = 回り (turns), K = 剣舞 (the sword dance, two-handed, each cut ending held), the canon
;;; gestures for SP2 / O / I. Played by the Shikai only, through the :base kit's :clip-map (rukia.lisp *RU-SHIKAI-CLIPS*: the
;;; bands keep today's clips) and its :look-clips / :run-clips. Every strike: a tell inside the startup, the hit pose on S,
;;; an impact hold through A, a follow-through and a settle key in the recovery; turns keyed about every 90 deg with root
;;; yaw + a pelvis roll (:pelvis :side). Each K's 霜の穂先 (*RU-FROST-POINTS*) is drawn past the tip by RUKIA-FROST-DRAW.
(defpose :ru-s-stance ()                               ; 構え: hips low, knees close, the blade one-handed level at chest
  (:root :u -0.08) (:pelvis :twist 20) (:spine :flex 6) (:chest :twist -6) (:neck :twist -6) (:head :flex -4 :twist -10)   ; height
  (:arm-r :flex 62 :side 20) (:elbow-r :flex 34) (:hand-r :twist -10 :flex -90)                   ; at him, the left hand at
  (:arm-l :flex 34 :side 18) (:elbow-l :flex 116) (:hand-l :flex -10)                             ; the chest
  (:thigh-r :flex 26 :side 2) (:thigh-l :flex -10 :side 3) (:knee-r :flex 30) (:knee-l :flex 26))
(defclip :ru-s-stance (2.4 :loop t :base :ru-s-stance) ; no bounce: the hips sink 1 cm with the breath
  (0) (1.2 (:root :u -0.09)))

;; 摺り足: the walk glides, the head never bobs (the root's height fixed), the feet barely lift; the stance's arms
(defclip :ru-s-walk-f (0.9 :loop t :base :ru-s-stance)
  (0 (:thigh-r :flex 34) (:knee-r :flex 30) (:thigh-l :flex -2) (:knee-l :flex 26))
  (0.225 (:thigh-r :flex 22) (:knee-r :flex 34) (:thigh-l :flex 8) (:knee-l :flex 34))
  (0.45 (:thigh-l :flex 14) (:knee-l :flex 26) (:thigh-r :flex 14) (:knee-r :flex 30))
  (0.675 (:thigh-r :flex 22) (:knee-r :flex 34) (:thigh-l :flex 4) (:knee-l :flex 30)))
(defclip :ru-s-walk-b (0.9 :loop t :base :ru-s-stance)
  (0 (:thigh-r :flex 16) (:knee-r :flex 30) (:thigh-l :flex -16) (:knee-l :flex 24))
  (0.225 (:thigh-r :flex 22) (:knee-r :flex 34) (:thigh-l :flex -6) (:knee-l :flex 32))
  (0.45 (:thigh-r :flex 30) (:knee-r :flex 30) (:thigh-l :flex -2) (:knee-l :flex 24))
  (0.675 (:thigh-r :flex 22) (:knee-r :flex 34) (:thigh-l :flex -8) (:knee-l :flex 32)))
(defclip :ru-s-strafe-r (0.8 :loop t :base :ru-s-stance)
  (0 (:thigh-r :side 12) (:thigh-l :side 0))
  (0.2 (:thigh-r :side 7) (:knee-r :flex 36) (:thigh-l :side 5))
  (0.4 (:thigh-r :side 2) (:thigh-l :side 8))
  (0.6 (:thigh-r :side 7) (:knee-l :flex 32) (:thigh-l :side 4)))
(defclip :ru-s-strafe-l (0.8 :loop t :base :ru-s-stance)
  (0 (:thigh-l :side 12) (:thigh-r :side -2))
  (0.2 (:thigh-l :side 7) (:knee-l :flex 32) (:thigh-r :side 4))
  (0.4 (:thigh-l :side 2) (:thigh-r :side 8))
  (0.6 (:thigh-l :side 7) (:knee-r :flex 36) (:thigh-r :side 4)))

;; the run (canon Ep411): crouched, body low and forward, the blade trailing level behind her, the left hand forward
(defpose :ru-s-run-pose (:base :ru-s-stance)
  (:pelvis :twist 10) (:chest :twist -4) (:neck :twist -6) (:head :twist -4)
  (:arm-r :flex -46 :side 22) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -94)
  (:arm-l :flex 50 :side 14) (:elbow-l :flex 60) (:hand-l :flex -20))
(defclip :ru-s-run (0.5 :loop t :base :ru-s-run-pose)
  (0 (:root :u -0.15) (:spine :flex 30) (:head :flex -22) (:thigh-r :flex 50) (:knee-r :flex 20) (:thigh-l :flex -28) (:knee-l :flex 56))
  (0.125 (:root :u -0.1) (:thigh-r :flex 16) (:knee-r :flex 36) (:thigh-l :flex 12) (:knee-l :flex 96))
  (0.25 (:root :u -0.15) (:thigh-l :flex 50) (:knee-l :flex 20) (:thigh-r :flex -28) (:knee-r :flex 56))
  (0.375 (:root :u -0.1) (:thigh-l :flex 16) (:knee-l :flex 36) (:thigh-r :flex 12) (:knee-r :flex 96)))

;; J1 回り (H-> B1): a quarter turn to her left on the ball of the right foot, hips low; the blade flat across at chest
;; height, the left hand kept at the chest
(defpose :ru-s-j1-hit (:base :ru-s-stance)
  (:root :yaw 14 :f 0.3 :u -0.12) (:pelvis :twist 18 :side -6) (:spine :flex 8) (:chest :twist -4) (:neck :twist -6) (:head :twist -6)
  (:arm-r :side 88 :flex 78) (:elbow-r :flex 6) (:hand-r :twist 0 :flex -88)
  (:arm-l :flex 40 :side 14) (:elbow-l :flex 120) (:hand-l :flex -10)
  (:thigh-r :flex 40 :side 2) (:knee-r :flex 42) (:thigh-l :flex -14 :side 4) (:knee-l :flex 30))
(defstrike :ru-s-j1 (7 3 12 :base :ru-s-stance)
  (0)
  (3 (:root :yaw -40 :u -0.12 :f 0.06) (:pelvis :side 4) (:chest :twist -16) (:neck :twist 14) (:head :twist 8)    ; the tell: coiled
     (:arm-r :side 86 :flex 8) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -86) (:knee-r :flex 38) (:knee-l :flex 32))  ; right, blade back
  (5 (:root :yaw -44 :u -0.125 :f 0.1) (:arm-r :flex 4))                                         ; (held: moving)
  (:s :snap :ru-s-j1-hit)
  (9 (:root :yaw 40 :f 0.34) (:pelvis :side -8) (:arm-r :flex 98))                              ; through
  (:a (:root :yaw 48 :f 0.34) (:arm-r :flex 102))                                               ; the impact held
  (15 (:root :yaw 40 :f 0.24 :u -0.11) (:pelvis :side -3) (:arm-r :side 60 :flex 90) (:elbow-r :flex 20) (:hand-r :flex -76))   ; settle
  (:end :ru-s-stance))

;; J2 回り back (up-right B1b): a quarter turn back to her right; the wrist turned over: a rising backhand from her left
;; hip to above her right shoulder
(defpose :ru-s-j2-hit (:base :ru-s-stance)
  (:root :yaw -12 :f 0.22 :u -0.1) (:pelvis :twist 22 :side 6) (:spine :flex 4) (:chest :twist 8) (:neck :twist -14) (:head :flex -10 :twist -10)
  (:arm-r :side 84 :flex 70) (:elbow-r :flex 8 :twist 160) (:hand-r :twist 0 :flex -86)
  (:arm-l :flex 30 :side 30) (:elbow-l :flex 110) (:hand-l :flex -10)
  (:thigh-r :flex 32 :side 4) (:knee-r :flex 34) (:thigh-l :flex -16 :side 6) (:knee-l :flex 26))
(defstrike :ru-s-j2 (7 3 13 :base :ru-s-stance)
  (0)
  (3 (:root :yaw 38 :u -0.13 :f 0.04) (:pelvis :side -4) (:chest :twist 22) (:neck :twist -20) (:head :twist -14 :flex 6)   ; the tell:
     (:arm-r :side -40 :flex 20) (:elbow-r :flex 30 :twist 160) (:hand-r :twist 0 :flex -80) (:knees :flex 36))   ; the blade at her left hip
  (5 (:root :yaw 42 :u -0.135) (:arm-r :side -42 :flex 18))
  (:s :snap :ru-s-j2-hit)
  (9 (:root :yaw -34 :f 0.24) (:arm-r :side 108 :flex 40) (:pelvis :side 8))
  (:a (:root :yaw -42 :f 0.24) (:arm-r :side 118 :flex 30))                                      ; above the right shoulder
  (16 (:root :yaw -36 :f 0.2 :u -0.09) (:pelvis :side 3) (:arm-r :side 90 :flex 40) (:elbow-r :flex 20 :twist 100) (:hand-r :flex -70))
  (:end :ru-s-stance))

;; J3 回り, the finale (counter-clockwise B1): a full turn to her left keyed every 90 deg, the arms out in a T, the rear leg
;; drawn up; a small 決まり, the head last
(defpose :ru-s-j3-hit (:base :ru-s-stance)
  (:root :yaw 350 :u -0.02 :f 0.38) (:pelvis :twist 18 :side -6) (:spine :flex 2) (:chest :twist 4) (:neck :twist -10) (:head :twist -10 :flex 4)
  (:arm-r :side 88 :flex 80) (:elbow-r :flex 4) (:hand-r :twist 0 :flex -88) (:arm-l :side 86 :flex 10) (:elbow-l :flex 8) (:hand-l :flex -10)
  (:thigh-r :flex 8) (:knee-r :flex 10) (:thigh-l :flex 28 :side 14) (:knee-l :flex 86))
(defstrike :ru-s-j3 (8 3 18 :base :ru-s-stance)
  (0)
  (3 (:root :yaw -40 :u -0.13) (:pelvis :side 6) (:chest :twist -26) (:neck :twist 16) (:knees :flex 40)      ; the tell: coiled
     (:arm-r :side 70 :flex 30) (:elbow-r :flex 14) (:hand-r :twist 0 :flex -86) (:arm-l :flex 40 :side 30) (:elbow-l :flex 90))
  (4 (:root :yaw 40 :u -0.08) (:pelvis :side -4) (:chest :twist -6) (:arm-r :side 84 :flex 50) (:arm-l :side 70 :flex 20) (:elbow-l :flex 40))
  (5 (:root :yaw 130 :u -0.04) (:pelvis :side -8) (:arm-r :side 88 :flex 70) (:arm-l :side 86 :flex 10) (:elbow-l :flex 10)
     (:thigh-l :flex 20 :side 10) (:knee-l :flex 70))
  (6 (:root :yaw 220 :u -0.02) (:pelvis :side -8))
  (7 (:root :yaw 300 :u -0.02 :f 0.3) (:pelvis :side -7))
  (:s :snap :ru-s-j3-hit)
  (10 (:root :yaw 384 :f 0.4) (:pelvis :side -4))
  (:a (:root :yaw 388 :u -0.03 :f 0.4))
  (18 (:root :yaw 372 :u -0.1 :f 0.3) (:pelvis :side 0) (:chest :twist 8) (:neck :twist -4) (:head :twist -4 :flex 10)   ; 決まり: down,
      (:arm-r :side 50 :flex 40) (:elbow-r :flex 20) (:hand-r :flex -70) (:arm-l :side 50 :flex 30) (:elbow-l :flex 40)   ; the arms
      (:thigh-l :flex -8 :side 4) (:knee-l :flex 28) (:thigh-r :flex 26) (:knee-r :flex 32))                        ; low, held
  (23 (:root :yaw 368 :u -0.1 :f 0.26) (:head :twist -16 :flex -2))                            ; the head last
  (:end :ru-s-stance (:root :yaw 360)))

;; K1 剣舞・摺り足 (T-hi B2): from the two-hand high guard (the hilt at her right temple) a 0.5 m glide and a two-hand thrust
;; at the head line; the frost spike off the point
(defpose :ru-s-guard-hi (:base :ru-s-stance)           ; the high guard: the hilt raised at her right brow, the point at him
  (:root :u -0.11) (:pelvis :twist 22) (:spine :flex 4) (:chest :twist -10) (:neck :twist -4) (:head :flex -4 :twist -8)
  (:arm-r :flex 140 :side 2) (:elbow-r :flex 2) (:hand-r :twist -10 :flex -130)
  (:arm-l :flex 136 :side -14) (:elbow-l :flex 12) (:hand-l :flex -10)
  (:thigh-r :flex 30 :side 2) (:knee-r :flex 36) (:thigh-l :flex -12 :side 4) (:knee-l :flex 30))
(defpose :ru-s-k1-hit (:base :ru-s-stance)
  (:root :f 0.5 :u -0.16) (:pelvis :twist 14) (:spine :flex 10) (:chest :twist -4) (:neck :twist -12) (:head :flex -10 :twist -10)
  (:arm-r :flex 110 :side 4) (:elbow-r :flex 4) (:hand-r :twist -10 :flex -102)
  (:arm-l :flex 110 :side -12) (:elbow-l :flex 14) (:hand-l :flex -20)
  (:thigh-r :flex 56 :side 4) (:knee-r :flex 58) (:thigh-l :flex -30 :side 6) (:knee-l :flex 10))
(defstrike :ru-s-k1 (17 4 20 :base :ru-s-stance)
  (0)
  (6 :ru-s-guard-hi)                                                                             ; the guard raised
  (11 (:root :u -0.13 :f 0.06) (:arm-r :flex 143) (:hand-r :flex -133))                         ; the tell: held, sunk
  (15 (:root :u -0.14 :f 0.34) (:arm-r :flex 141) (:hand-r :flex -131))                         ; the glide
  (:s :snap :ru-s-k1-hit)
  (19 (:root :f 0.54) (:arm-r :flex 108))
  (:a (:root :f 0.53) (:arm-r :flex 109))
  (30 (:root :f 0.3 :u -0.13) (:arm-r :flex 80 :side 10) (:elbow-r :flex 30) (:hand-r :flex -76) (:arm-l :flex 70) (:elbow-l :flex 60)
      (:thigh-r :flex 40) (:knee-r :flex 44) (:thigh-l :flex -18) (:knee-l :flex 22))           ; the glide back
  (36 (:root :f 0.08 :u -0.1))                                                                    ; settle
  (:end :ru-s-stance))
(pushnew :ru-s-k1 *grip-clips*)

;; K2 剣舞 (H<- B2): the hips turn out of the thrust: a two-hand cut across the waist, left to right, the sleeves flaring,
;; the weight back; the frost sheet trails the cut
(defpose :ru-s-k2-hit (:base :ru-s-stance)
  (:root :yaw -8 :f -0.06 :u -0.13) (:pelvis :twist 10 :side 6) (:spine :flex 6) (:chest :twist -10) (:neck :twist -2) (:head :flex -8 :twist -4)
  (:arm-r :side 70 :flex 76) (:elbow-r :flex 6) (:hand-r :twist 0 :flex -88)
  (:arm-l :side 30 :flex 80) (:elbow-l :flex 30) (:hand-l :flex -20)
  (:thigh-r :flex 20 :side 4) (:knee-r :flex 30) (:thigh-l :flex -30 :side 8) (:knee-l :flex 46))   ; the weight back on the left
(defstrike :ru-s-k2 (21 4 24 :base :ru-s-stance)
  (0)
  (9 (:root :yaw 50 :u -0.12 :f 0.1) (:pelvis :side -4) (:chest :twist 20) (:neck :twist -24) (:head :twist -20)   ; the tell: the hips
     (:arm-r :side -20 :flex 50) (:elbow-r :flex 40) (:hand-r :twist 0 :flex -70) (:arm-l :side 10 :flex 40) (:elbow-l :flex 60)   ; out,
     (:knees :flex 40))                                                                          ; the blade drawn to her left hip
  (17 (:root :yaw 58 :u -0.14 :f 0.06) (:arm-r :side -26))                                      ; (held: moving)
  (:s :snap :ru-s-k2-hit)
  (23 (:root :yaw -38) (:pelvis :side 8) (:arm-r :flex 88))
  (:a (:root :yaw -46) (:pelvis :side 7) (:arm-r :flex 92))
  (36 (:root :yaw -30 :f -0.1 :u -0.12) (:pelvis :side 3) (:arm-r :side 50 :flex 70) (:elbow-r :flex 20) (:hand-r :flex -76))
  (42 (:root :yaw -10 :f -0.04 :u -0.1) (:pelvis :side 0))                                      ; settle
  (:end :ru-s-stance))
(pushnew :ru-s-k2 *grip-clips*)

;; K3 剣舞 -> 見得 (V-down B2): a step in, the blade raised straight overhead (canon), held 3 f, dropped with an ice column;
;; the low finish held 12+ f, the head last
(defpose :ru-s-k3-hit (:base :ru-s-stance)
  (:root :u -0.22 :f 0.42) (:pelvis :twist 12) (:spine :flex 26) (:chest :twist -2) (:neck :twist -8) (:head :flex -14 :twist -8)
  (:arm-r :flex 104 :side 2) (:elbow-r :flex 4) (:hand-r :twist -10 :flex -86)
  (:arm-l :flex 102 :side -12) (:elbow-l :flex 14) (:hand-l :flex -20)
  (:thigh-r :flex 60 :side 6) (:knee-r :flex 64) (:thigh-l :flex -26 :side 8) (:knee-l :flex 22))
(defstrike :ru-s-k3 (21 5 34 :base :ru-s-stance)
  (0)
  (10 (:root :u -0.04 :f 0.12) (:pelvis :twist 16) (:spine :flex -6) (:chest :twist 0) (:head :flex -24)     ; the step in, the blade
      (:arm-r :flex 160 :side 8) (:elbow-r :flex 20) (:hand-r :twist -6 :flex -70) (:arm-l :flex 154 :side -12) (:elbow-l :flex 30)
      (:thigh-r :flex 20) (:knee-r :flex 16) (:thigh-l :flex -8) (:knee-l :flex 10))
  (15 (:root :u 0.02 :f 0.16) (:spine :flex -12) (:arm-r :flex 178) (:arm-l :flex 172) (:hand-r :flex -96))   ; straight overhead
  (18 (:root :u 0.03 :f 0.17) (:spine :flex -13) (:arm-r :flex 180) (:hand-r :flex -98))         ; held 3 f
  (:s :snap :ru-s-k3-hit)
  (23 (:root :u -0.24 :f 0.44) (:spine :flex 30) (:arm-r :flex 98) (:arm-l :flex 96))           ; the impact held (the column
  (:a (:root :u -0.25 :f 0.44) (:spine :flex 31) (:arm-r :flex 95) (:arm-l :flex 93))            ;  whole), then
  (30 (:root :u -0.28 :f 0.44) (:spine :flex 36) (:arm-r :flex 78) (:arm-l :flex 76))           ; down: the low finish
  (42 (:root :u -0.27 :f 0.43) (:spine :flex 35) (:head :flex -20))                              ; 見得: held
  (46 (:head :flex -4 :twist -16))                                                                ; the head last
  (52 (:root :u -0.12 :f 0.2) (:spine :flex 14) (:arm-r :flex 50 :side 12) (:elbow-r :flex 24) (:hand-r :flex -70)
      (:arm-l :flex 40 :side 20) (:elbow-l :flex 70) (:thigh-r :flex 36) (:knee-r :flex 40) (:head :flex -6 :twist -14))
  (:end :ru-s-stance))
(pushnew :ru-s-k3 *grip-clips*)

;; SP2 参の舞・白刀 (T B1, canon ch. 268): the right arm rises from low and drives straight at his face, the ice growing in
;; three steps (RUKIA-BLADE-LOOK); the recovery a small ヒラキ: both arms opening as she gives back, then returning
(defpose :ru-s-shirafune-hit (:base :ru-s-stance)
  (:root :f 0.62 :u -0.18) (:pelvis :twist 16) (:spine :flex 6) (:chest :twist 4) (:neck :twist -18) (:head :flex -6 :twist -14)
  (:arm-r :flex 110 :side 2) (:elbow-r :flex 0) (:hand-r :twist -10 :flex -102)
  (:arm-l :flex -40 :side 40) (:elbow-l :flex 20) (:hand-l :flex -30)
  (:thigh-r :flex 70 :side 4) (:knee-r :flex 72) (:thigh-l :flex -38 :side 6) (:knee-l :flex 4))
(defstrike :ru-s-shirafune (16 4 28 :base :ru-s-stance)
  (0)
  (6 (:root :u -0.14 :f -0.04) (:chest :twist -14) (:arm-r :flex 10 :side 14) (:elbow-r :flex 20) (:hand-r :twist -10 :flex -80)   ; low:
     (:arm-l :flex 50 :side 10) (:elbow-l :flex 90) (:knees :flex 40))                              ; the point down at her side
  (13 (:root :u -0.15 :f 0.04) (:arm-r :flex 50) (:elbow-r :flex 30))                            ; rising
  (:s :snap :ru-s-shirafune-hit)
  (:a (:root :f 0.66) (:arm-r :flex 111))
  (30 (:root :f 0.5 :u -0.16) (:arm-r :flex 106))
  (38 (:root :f 0.36 :u -0.08) (:spine :flex 4) (:arm-r :side 60 :flex 50) (:elbow-r :flex 10) (:hand-r :flex -80)   ; ヒラキ: given
      (:arm-l :side 60 :flex 30) (:elbow-l :flex 14) (:thigh-r :flex 30) (:knee-r :flex 30) (:thigh-l :flex -10) (:knee-l :flex 14))  ; back, opened
  (44 (:root :f 0.34 :u -0.08))                                                                  ; (held)
  (:end :ru-s-stance))

;; O 円舞 ENBU: the flash step's own run (crouched, the blade trailing level) and its strike: a turn to her right with the
;; blade raised overhead in both hands, descending in a spiral to the waist (clockwise B2)
(defclip :ru-s-enbu-run (0.3 :loop t :base :ru-s-run-pose)
  (0 (:root :u -0.24) (:spine :flex 40) (:head :flex -32) (:arm-r :flex -58) (:arm-l :flex 30 :side 20) (:elbow-l :flex 40)
     (:thigh-r :flex 64) (:knee-r :flex 30) (:thigh-l :flex -30) (:knee-l :flex 70))
  (0.15 (:root :u -0.2) (:thigh-l :flex 64) (:knee-l :flex 30) (:thigh-r :flex -30) (:knee-r :flex 70)))
(defpose :ru-s-enbu-hit (:base :ru-s-stance)
  (:root :yaw -350 :u -0.14 :f 0.2) (:pelvis :twist 20 :side 6) (:spine :flex 10) (:chest :twist 0) (:neck :twist -10) (:head :flex -6 :twist -10)
  (:arm-r :side 60 :flex 84) (:elbow-r :flex 6) (:hand-r :twist 0 :flex -88)
  (:arm-l :side 20 :flex 84) (:elbow-l :flex 24) (:hand-l :flex -20)
  (:thigh-r :flex 36) (:knee-r :flex 40) (:thigh-l :flex -20 :side 6) (:knee-l :flex 36))
(defstrike :ru-s-enbu (8 3 24 :base :ru-s-stance)
  (0 (:root :u 0.0) (:spine :flex -8) (:arm-r :flex 170 :side 10) (:elbow-r :flex 20) (:hand-r :twist 0 :flex -86)   ; raised overhead,
     (:arm-l :flex 164 :side -10) (:elbow-l :flex 30) (:head :flex -20))                          ; both hands
  (2 (:root :yaw -90 :u -0.02) (:pelvis :side 6) (:arm-r :flex 158) (:hand-r :flex -80) (:arm-l :flex 152))
  (4 (:root :yaw -180 :u -0.05) (:pelvis :side 8) (:spine :flex 0) (:arm-r :flex 136 :side 30) (:hand-r :flex -60) (:arm-l :flex 130))
  (6 (:root :yaw -270 :u -0.1) (:pelvis :side 8) (:spine :flex 6) (:arm-r :flex 108 :side 46) (:hand-r :flex -78) (:arm-l :flex 104))
  (:s :snap :ru-s-enbu-hit)
  (10 (:root :yaw -400 :f 0.22) (:pelvis :side 6))
  (:a (:root :yaw -408 :f 0.22))
  (22 (:root :yaw -390 :u -0.12 :f 0.16) (:pelvis :side 2) (:arm-r :side 40 :flex 60) (:elbow-r :flex 20) (:hand-r :flex -72)
      (:arm-l :side 20 :flex 50) (:elbow-l :flex 60))
  (:end :ru-s-stance (:root :yaw -360)))
(pushnew :ru-s-enbu *grip-clips*)

;; I 這縄 HAINAWA (up-right pt F2, canon ch. 266; 仕舞 サシ): a low dash, then the left arm rises from her side to point
;; forward-high, two fingers; the blade held low and back, point down
(defclip :ru-s-breaker (0.4 :loop t :base :ru-s-stance)
  (0 (:root :u -0.16) (:pelvis :twist 10) (:spine :flex 34) (:chest :twist -10) (:neck :twist 0) (:head :flex -28 :twist 0)
     (:arm-r :flex -36 :side 24) (:elbow-r :flex 14) (:hand-r :twist 0 :flex -110)
     (:arm-l :flex -8 :side 16) (:elbow-l :flex 10) (:hand-l :flex -10)
     (:thigh-r :flex 50) (:knee-r :flex 24) (:thigh-l :flex -30) (:knee-l :flex 50))
  (0.2 (:root :u -0.12) (:thigh-l :flex 50) (:knee-l :flex 24) (:thigh-r :flex -30) (:knee-r :flex 50)))
(defpose :ru-s-hainawa-hit (:base :ru-s-stance)
  (:root :f 0.86 :u -0.16) (:pelvis :twist -6) (:spine :flex 10) (:chest :twist -36) (:neck :twist 16) (:head :flex -10 :twist 12)
  (:arm-l :flex 106 :side 2) (:elbow-l :flex 0) (:hand-l :flex -6)
  (:arm-r :flex -34 :side 26) (:elbow-r :flex 14) (:hand-r :twist 0 :flex -110)
  (:thigh-r :flex 50) (:knee-r :flex 50) (:thigh-l :flex -26) (:knee-l :flex 14))
(defstrike :ru-s-hainawa (8 4 18 :base :ru-s-stance)
  (0 (:root :u -0.15 :f 0.1) (:spine :flex 22) (:chest :twist 10) (:arm-l :flex -6 :side 20) (:elbow-l :flex 10)
     (:arm-r :flex -34 :side 24) (:elbow-r :flex 14) (:hand-r :twist 0 :flex -110) (:knees :flex 44))
  (5 (:root :u -0.16 :f 0.3) (:chest :twist -4) (:arm-l :flex 40 :side 60) (:elbow-l :flex 6))   ; rising from her side
  (:s :snap :ru-s-hainawa-hit)
  (10 (:root :f 0.9) (:arm-l :flex 110))
  (:a (:root :f 0.89) (:arm-l :flex 109))
  (22 (:root :f 0.44 :u -0.11) (:chest :twist -10) (:arm-l :flex 60 :side 30) (:elbow-l :flex 50))
  (:end :ru-s-stance))

;;; ---------------------------------------------------------------- the new Shikai's bursts and kido (DUEL_RUKIA_TYBW §13.3)
;;; Presentation only (the user 2026-10-24, §13.7): each move's frame data and volume as built, the clips at speed 1 (S on
;;; the move's S). The bursts start where their link's hit ends (S + A), so frame 0 is that link's finish as §13.3 draws
;;; it; J's are the 回り's finishes (the sleeve, the fan, the stamp), K's the sword dance's ends (the flick, the plant, the
;;; canon wave); the kido are the canon gestures. Turns key every 90 deg (:snap keys run at an even speed through them),
;;; ⟲ = +yaw. The drawn point falls short of every volume (the rules test's "Rukia burst reach"): the frost, the snow ring,
;;; the pebbles, the icicles and the wave carry the rest.
(defstrike :ru-s-shimochiri (10 3 22 :base :ru-s-stance)   ; 霜散 J1+L 袖返し: the left sleeve flung round her as she hops back
  (0 (:root :u -0.1) (:chest :twist 16) (:arm-r :side 88 :flex 100) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -86)   ; (J1's
     (:arm-l :flex 40 :side 30) (:elbow-l :flex 100) (:hand-l :flex -20))                       ;  cut through, left hand at the chest)
  (4 (:root :u -0.17 :yaw 24) (:chest :twist 30) (:spine :flex 16) (:neck :twist -24) (:head :twist -20)   ; the coil: the left
     (:arm-l :flex 76 :side -24) (:elbow-l :flex 116) (:arm-r :side 50 :flex 70) (:elbow-r :flex 40) (:hand-r :flex -80)   ; sleeve
     (:knees :flex 50) (:thighs :flex 32))                                                     ; gathered across her, sinking
  (8 (:root :u -0.23 :yaw 36) (:chest :twist 34) (:knees :flex 60) (:thighs :flex 40) (:arm-l :flex 80 :side -30))
  (:s :snap (:root :u 0.02 :yaw -90) (:pelvis :twist 10) (:spine :flex 4 :side -10) (:chest :twist -6) (:neck :twist 0)   ; the
      (:head :twist 0 :flex -4) (:arm-l :side 98 :flex 14) (:elbow-l :flex 6) (:hand-l :flex -10)   ; release ⟳ and the take-off:
      (:arm-r :side 92 :flex -4) (:elbow-r :flex 4) (:hand-r :flex -88)                         ; the sleeve leads, the blade
      (:thigh-r :flex 34 :side 6) (:knee-r :flex 70) (:thigh-l :flex 14 :side 10) (:knee-l :flex 80))   ; the other arm (a T)
  (12 :snap (:root :u 0.13 :yaw -180) (:spine :side -12))
  (15 :snap (:root :u 0.2 :yaw -270) (:spine :side -8) (:knee-r :flex 84) (:knee-l :flex 90))   ; the apex (the sim's hop back)
  (18 :snap (:root :u 0.1 :yaw -360) (:spine :side -2) (:arm-l :side 90 :flex 30) (:arm-r :side 70 :flex 10)
      (:thigh-r :flex 30) (:knee-r :flex 40) (:thigh-l :flex 4) (:knee-l :flex 30))
  (21 (:root :u -0.25 :yaw -366) (:spine :flex 22 :side 0) (:chest :twist -14) (:neck :twist 10) (:head :flex 8 :twist 6)   ; the
      (:arm-l :flex 118 :side 24) (:elbow-l :flex 0) (:hand-l :flex -10)                       ; landing, low: the 決まり, the
      (:arm-r :flex -34 :side 34) (:elbow-r :flex 10) (:hand-r :flex -96)                      ; left hand pointing forward-high,
      (:thigh-r :flex 56 :side 14) (:knee-r :flex 70) (:thigh-l :flex -20 :side 16) (:knee-l :flex 50))   ; the blade low behind
  (26 (:root :u -0.24 :yaw -364) (:head :flex -6 :twist -14))                                  ; held; the head arrives last
  (30 (:root :u -0.22 :yaw -362) (:head :flex -8 :twist -16))
  (:end :ru-s-stance (:root :yaw -360)))

(defstrike :ru-s-setsuen (10 3 22 :base :ru-s-stance)    ; 雪煙 J2+L 扇の手: the blade raised overhead and spun flat on the
  (0 (:root :u -0.11) (:chest :twist -14) (:arm-r :side 70 :flex 120) (:elbow-r :flex 20) (:hand-r :twist 0 :flex -80)   ; wrist
     (:arm-l :flex 50 :side 56) (:elbow-l :flex 30) (:hand-l :flex -30))   ; (J2's backhand finished above the right shoulder)
  (5 (:root :u -0.04) (:spine :flex -4) (:chest :twist -4) (:neck :twist -6) (:head :flex -18 :twist -8)   ; rising, the blade
     (:arm-r :side 12 :flex 168 :twist 0) (:elbow-r :flex 6) (:hand-r :flex 0)                 ; lifted overhead, flat,
     (:arm-l :flex 40 :side 30) (:elbow-l :flex 110) (:hand-l :flex -20) (:knees :flex 14) (:thighs :flex 6))   ; the left hand in
  (8 (:root :u -0.08) (:arm-r :twist -50) (:knees :flex 24) (:thighs :flex 12))               ; a dip, the wrist cocked back
  (:s :snap (:root :u -0.02 :yaw 10) (:arm-r :twist 90))                                        ; 要返し: spun round, flat
  (11 :snap (:arm-r :twist 180))
  (12 :snap (:arm-r :twist 270) (:root :yaw 16))
  (13 :snap (:arm-r :twist 360))
  (15 :snap (:arm-r :twist 450) (:root :yaw 20))
  (17 :snap (:arm-r :twist 540))
  (20 :snap (:arm-r :twist 630) (:root :yaw 16))
  (24 (:arm-r :twist 720) (:root :u -0.03 :yaw 10))                                            ; slowing to a stop
  (24.02 :snap (:arm-r :twist 0))                                                              ; (720 = 0: no unwinding later)
  (29 (:root :u -0.1 :yaw 2) (:spine :flex 10) (:chest :twist 10) (:head :flex 0 :twist -14)   ; lowered to the 決まり: the
      (:arm-r :side 70 :flex 40 :twist 0) (:elbow-r :flex 10) (:hand-r :flex -84)            ; blade out at her right, the
      (:arm-l :side 64 :flex 20) (:elbow-l :flex 20) (:knees :flex 30) (:thighs :flex 16))       ; left arm opened
  (:end :ru-s-stance))

(defpose :ru-s-sojin-hit (:base :ru-s-stance)            ; 霜陣's stab: the point driven down into the plaza at her feet
  (:root :u -0.24) (:pelvis :twist 14) (:spine :flex 38) (:chest :twist 0) (:neck :twist -6) (:head :flex 16)
  (:arm-r :flex 66 :side 6) (:elbow-r :flex 22) (:hand-r :twist 0 :flex 235)
  (:arm-l :flex 10 :side 56) (:elbow-l :flex 20) (:hand-l :flex -30)
  (:thigh-r :flex 44) (:knee-r :flex 64) (:thigh-l :flex 32) (:knee-l :flex 60))
(defstrike :ru-s-sojin (10 3 22 :base :ru-s-stance)      ; 霜陣 J3+L 足拍子 + 突き: one stamp, one stab point-down at her feet
  (0 (:root :u -0.07) (:arm-r :side 60 :flex 30) (:elbow-r :flex 20) (:hand-r :flex -70) (:arm-l :side 60 :flex 40)   ; (J3's
     (:elbow-l :flex 40))                                                                       ;  small 決まり, arms out)
  (3 (:root :u 0.0) (:spine :flex -4) (:pelvis :twist 10) (:chest :twist 0) (:head :flex 4)    ; the grip turned over, the point
     (:arm-r :flex 74 :side 8) (:elbow-r :flex 60) (:hand-r :twist 0 :flex 120) (:arm-l :side 44 :flex 16)   ; down before her;
     (:thigh-r :flex 64) (:knee-r :flex 86) (:thigh-l :flex -4) (:knee-l :flex 8))             ; the right knee up (足拍子)
  (7 (:root :u 0.01) (:arm-r :flex 96) (:elbow-r :flex 74) (:hand-r :flex 100) (:thigh-r :flex 76) (:knee-r :flex 96))   ; the tell
  (8 :snap (:root :u -0.12) (:thigh-r :flex 30) (:knee-r :flex 40) (:thigh-l :flex 14) (:knee-l :flex 30)   ; the stamp
     (:arm-r :flex 84) (:elbow-r :flex 60))
  (:s :snap :ru-s-sojin-hit)                                                                   ; the stab
  (:a (:root :u -0.26) (:spine :flex 40))
  (20 (:root :u -0.25) (:spine :flex 39) (:head :flex 12))                                     ; the impact hold
  (26 (:root :u -0.14) (:spine :flex 20) (:arm-r :flex 80) (:elbow-r :flex 50) (:hand-r :flex 150) (:head :flex 4))   ; drawn out
  (30 (:root :u -0.08) (:spine :flex 10) (:arm-r :flex 40 :side 14) (:elbow-r :flex 24) (:hand-r :twist 0 :flex -66)   ; turned
      (:arm-l :flex 30 :side 40) (:elbow-l :flex 60) (:knees :flex 26) (:thighs :flex 14))     ; back over: the settle
  (:end :ru-s-stance))

(defstrike :ru-s-hyoreki (12 4 26 :base :ru-s-stance)    ; 氷礫 K1+L 剣舞 (返し): out of the thrust the point flicked up
  (0 (:root :f 0.45 :u -0.14) (:pelvis :twist 14) (:spine :flex 10) (:chest :twist 0) (:neck :twist -20) (:head :twist -16)   ; (K1's
     (:arm-r :flex 100 :side 0) (:elbow-r :flex 4) (:hand-r :twist -10 :flex -84)             ;  two-hand thrust at the head
     (:arm-l :flex 96 :side -14) (:elbow-l :flex 14) (:hand-l :flex -30)                       ;  line, at the end of its glide)
     (:thigh-r :flex 52 :side 4) (:knee-r :flex 52) (:thigh-l :flex -28 :side 8) (:knee-l :flex 10))
  (4 (:root :f 0.42 :u -0.18) (:arm-l :flex 40 :side 30) (:elbow-l :flex 110) (:hand-l :flex -20)   ; the left hand off the hilt,
     (:arm-r :flex 84) (:elbow-r :flex 10) (:hand-r :flex -100) (:knee-r :flex 60) (:thigh-r :flex 58))   ; the point dipping
  (10 (:root :f 0.4 :u -0.21) (:arm-r :flex 76) (:elbow-r :flex 16) (:hand-r :flex -112) (:chest :twist 6))   ; lowest: the tell
  (:s :snap (:root :f 0.5 :u -0.15) (:chest :twist -10) (:arm-r :flex 100) (:elbow-r :flex 0) (:hand-r :flex -86)   ; the flick:
      (:arm-l :flex -40 :side 50) (:elbow-l :flex 30) (:hand-l :flex -40))                     ; level at him, rising
  (14 :snap (:arm-r :flex 110) (:hand-r :flex -56))                                            ; the point thrown up
  (:a (:arm-r :flex 120) (:hand-r :flex -36) (:root :f 0.5 :u -0.13))                          ; 60 deg up: the pebbles off it
  (24 (:arm-r :flex 126) (:hand-r :flex -30) (:root :f 0.46 :u -0.12) (:head :flex -10))        ; held
  (32 (:root :f 0.24 :u -0.1) (:arm-r :flex 60 :side 12) (:elbow-r :flex 20) (:hand-r :twist -10 :flex -70) (:head :flex -4)
      (:arm-l :flex 10 :side 40) (:elbow-l :flex 50) (:thigh-r :flex 36) (:knee-r :flex 38) (:thigh-l :flex -16) (:knee-l :flex 16))
  (:end :ru-s-stance))                                                                           ; (the glide recovered)

(defpose :ru-s-tsurara-hit (:base :ru-s-stance)          ; 氷柱's plant: reversed, both hands on the hilt, driven into the plaza
  (:root :u -0.26 :f 0.1) (:pelvis :twist 6) (:spine :flex 34) (:chest :twist -4) (:neck :twist -4) (:head :flex 8)
  (:arm-r :flex 70 :side 4) (:elbow-r :flex 10) (:hand-r :twist 0 :flex 240)
  (:arm-l :flex 72 :side -8) (:elbow-l :flex 14) (:hand-l :flex 0)
  (:thigh-r :flex 56 :side 10) (:knee-r :flex 74) (:thigh-l :flex 40 :side 12) (:knee-l :flex 76))
(defstrike :ru-s-tsurara (12 4 26 :base :ru-s-stance)    ; 氷柱 K2+L 剣舞 (突き立て): the blade reversed, driven into the plaza
  (0 (:root :u -0.1 :f 0.1) (:pelvis :twist 10) (:chest :twist -30) (:neck :twist 10) (:spine :flex 14)   ; (K2's two-hand
     (:arm-r :side 70 :flex 40) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -86)               ;  cut finished at her right,
     (:arm-l :flex 60 :side -20) (:elbow-l :flex 30) (:thigh-r :flex 20) (:knee-r :flex 30)   ;  the weight back)
     (:thigh-l :flex -10) (:knee-l :flex 30))
  (5 (:root :u -0.02 :f 0.1) (:chest :twist -4) (:neck :twist -6) (:spine :flex -4) (:head :flex -10)   ; turned over and lifted:
     (:arm-r :flex 100 :side 6) (:elbow-r :flex 40) (:hand-r :twist 0 :flex 150)               ; both fists before her chest,
     (:arm-l :flex 98 :side -14) (:elbow-l :flex 40) (:knees :flex 16) (:thighs :flex 8))       ; the point down before her
  (10 (:root :u 0.03 :f 0.1) (:spine :flex -8) (:arm-r :flex 124) (:elbow-r :flex 30) (:hand-r :flex 115) (:arm-l :flex 122)
      (:elbow-l :flex 30) (:head :flex -14) (:knees :flex 8) (:thighs :flex 4))                 ; raised, on the toes: the tell
  (:s :snap :ru-s-tsurara-hit)                                                                 ; driven down in both hands
  (:a (:root :u -0.28) (:spine :flex 36))
  (24 (:root :u -0.27) (:spine :flex 35) (:head :flex 4))                                      ; the impact hold
  (30 (:root :u -0.14 :f 0.08) (:spine :flex 18) (:arm-r :flex 86) (:elbow-r :flex 40) (:hand-r :flex 170) (:arm-l :flex 86)
      (:elbow-l :flex 40) (:knees :flex 40) (:thighs :flex 24))                                 ; drawn out
  (36 (:root :u -0.08 :f 0.04) (:spine :flex 10) (:arm-r :flex 40 :side 14) (:elbow-r :flex 24) (:hand-r :twist 0 :flex -66)
      (:arm-l :flex 30 :side 20) (:elbow-l :flex 60) (:knees :flex 26) (:thighs :flex 14))
  (:end :ru-s-stance))
(pushnew :ru-s-tsurara *grip-clips*)                   ; (both hands on the hilt)

(defpose :ru-s-hakuren-hit (:base :ru-s-stance)          ; 白漣's release: swept up and forward out of the plaza, both hands
  (:root :u -0.04 :f 0.3) (:pelvis :twist 10) (:spine :flex -6) (:chest :twist -10) (:neck :twist -6) (:head :flex -16 :twist -6)
  (:arm-r :flex 112 :side 8) (:elbow-r :flex 4) (:hand-r :twist -10 :flex -84)
  (:arm-l :flex 108 :side -10) (:elbow-l :flex 14) (:hand-l :flex -30)
  (:thigh-r :flex 34 :side 6) (:knee-r :flex 30) (:thigh-l :flex -22 :side 8) (:knee-l :flex 8))
(defstrike :ru-s-hakuren (12 4 26 :base :ru-s-stance)    ; 白漣 K3+L canon 次の舞: from K3's low finish the blade swept up-forward
  (0 (:root :u -0.22 :f 0.36) (:pelvis :twist 10) (:spine :flex 32) (:chest :twist 0) (:neck :twist -6) (:head :flex -16)   ; (K3's
     (:arm-r :flex 56 :side 0) (:elbow-r :flex 6) (:hand-r :twist -10 :flex -72)               ;  low finish: both hands, the
     (:arm-l :flex 54 :side -12) (:elbow-l :flex 16) (:hand-l :flex -30)                       ;  blade dropped through, deep)
     (:thigh-r :flex 58 :side 6) (:knee-r :flex 60) (:thigh-l :flex -24 :side 8) (:knee-l :flex 24))
  (6 (:root :u -0.28 :f 0.34) (:spine :flex 40) (:chest :twist 22) (:neck :twist -18) (:arm-r :flex 46 :side -6)   ; the point
     (:hand-r :flex -56) (:arm-l :flex 30 :side -16) (:knee-r :flex 70) (:thigh-r :flex 64))   ; down on the plaza at her left
  (10 (:root :u -0.29 :f 0.33) (:spine :flex 42) (:chest :twist 26) (:arm-r :flex 44))         ; held: the cold gathering at the tip
  (:s :snap :ru-s-hakuren-hit)                                                                 ; swept up: the wave goes
  (:a (:arm-r :flex 124) (:arm-l :flex 120) (:root :u 0.0 :f 0.3))
  (22 (:arm-r :flex 140) (:arm-l :flex 136) (:root :u 0.01 :f 0.28) (:spine :flex -10) (:head :flex -20))   ; the follow-through
  (30 (:root :u -0.08 :f 0.2) (:spine :flex 6) (:chest :twist 0) (:arm-r :flex 96) (:hand-r :flex -88)   ; levelled at him (canon:
      (:arm-l :flex 92) (:head :flex -6) (:thigh-r :flex 40) (:knee-r :flex 40))               ;  "simply levels" it): held
  (36 (:root :u -0.08 :f 0.16))
  (:end :ru-s-stance))
(pushnew :ru-s-hakuren *grip-clips*)

(defpose :ru-s-byakurai-tell (:base :ru-s-stance)        ; 白雷's tell (and 月白's frame 0): the left arm drawn back to the
  (:root :u -0.08) (:pelvis :twist 34) (:chest :twist 26) (:neck :twist -34) (:head :twist -26)   ; right shoulder, the blade
  (:arm-l :flex 4 :side -94) (:elbow-l :flex 24) (:hand-l :flex -30)                            ; low back at her right
  (:arm-r :flex -20 :side 30) (:elbow-r :flex 16) (:hand-r :twist 0 :flex -128)
  (:thigh-r :flex 30) (:knee-r :flex 34) (:thigh-l :flex -16) (:knee-l :flex 22))
(defpose :ru-s-byakurai-hit (:base :ru-s-byakurai-tell)   ; ... then shot straight at him, one finger
  (:root :f 0.12 :u -0.1) (:pelvis :twist 4) (:chest :twist -26) (:neck :twist 10) (:head :twist 12 :flex -4)
  (:arm-l :flex 92 :side 0) (:elbow-l :flex 0) (:hand-l :flex -4)
  (:thigh-r :flex 40) (:knee-r :flex 42) (:thigh-l :flex -22) (:knee-l :flex 10))
(defstrike :ru-s-byakurai (12 3 28 :base :ru-s-stance)   ; L tap 破道の四 白雷 [T / F]
  (0)
  (5 :ru-s-byakurai-tell (:arm-l :flex 16 :side -80) (:elbow-l :flex 40))
  (11 :ru-s-byakurai-tell)                                                                     ; held (L held here: 月白)
  (:s :snap :ru-s-byakurai-hit)                                                                ; the line
  (:a (:root :f 0.13) (:arm-l :flex 93))
  (22 (:root :f 0.08) (:arm-l :flex 100) (:elbow-l :flex 10) (:hand-l :flex -12))              ; the impact hold, the kick
  (32 (:root :f 0.04 :u -0.07) (:chest :twist 0) (:arm-l :flex 50 :side 30) (:elbow-l :flex 70) (:hand-l :flex -20))
  (:end :ru-s-stance))

(defpose :ru-s-tsukishiro-low (:base :ru-s-byakurai-tell)   ; 月白's circle: the deep crouch, the reversed point on the plaza
  (:root :u -0.32) (:pelvis :twist 20) (:spine :flex 30) (:chest :twist 4) (:neck :twist -10) (:head :twist -8 :flex 18)
  (:arm-r :flex 30 :side 64) (:elbow-r :flex 6) (:hand-r :twist 160 :flex 62)
  (:arm-l :flex 40 :side 30) (:elbow-l :flex 110) (:hand-l :flex -20)
  (:thigh-r :flex 54 :side 22) (:knee-r :flex 90) (:thigh-l :flex 44 :side 22) (:knee-l :flex 88))
(defstrike :ru-s-tsukishiro (12 0 36 :base :ru-s-stance)   ; L held 初の舞・月白 canon: reversed, the deep crouch, the circle ⟲
  (0 :ru-s-byakurai-tell)                                                                      ; (from 白雷's tell)
  (4 (:root :u -0.16) (:pelvis :twist 20) (:chest :twist 4) (:neck :twist -10) (:head :twist -8 :flex 8)   ; the blade reversed
     (:arm-r :flex 24 :side 40) (:elbow-r :flex 30) (:hand-r :twist 160 :flex 10)              ; (it glows), the left hand
     (:arm-l :flex 40 :side 30) (:elbow-l :flex 110) (:hand-l :flex -20) (:knees :flex 50) (:thighs :flex 30))   ; at the chest
  (8 :ru-s-tsukishiro-low)                                                                    ; the deep crouch, knees wide,
  (:s :snap (:root :u -0.33 :yaw 90))                                                          ; the tip on the plaza: drawn round
  (16 :snap (:root :yaw 180))
  (20 :snap (:root :yaw 270))
  (24 (:root :u -0.32 :yaw 360))                                                               ; the circle closed
  (30 (:root :u -0.04 :yaw 360) (:spine :flex 4) (:head :flex 4 :twist -6) (:pelvis :twist 10) (:chest :twist 0)   ; rising, upright,
      (:arm-r :flex -10 :side 16) (:elbow-r :flex 10) (:hand-r :twist 160 :flex 10)             ; the point down behind her
      (:arm-l :flex 30 :side 10) (:elbow-l :flex 96) (:knees :flex 10) (:thighs :flex 4) (:thigh-r :side 4) (:thigh-l :side 6))
  (33 :snap (:root :yaw 450))
  (36 (:root :yaw 540) (:head :twist 30))                                                       ; turned away as the pillar rises
  (42 (:root :yaw 542) (:head :twist 36 :flex 6))                                               ; held, looking back over the shoulder
  (45 :snap (:root :yaw 630) (:head :twist 0))
  (:end :ru-s-stance (:root :yaw 720)))

(defpose :ru-s-kido-pose (:base :ru-s-stance)            ; SP1's gather (its 16 f hold): the left palm cocked by her ear, the
  (:root :u -0.1) (:pelvis :twist 20) (:chest :twist 10) (:neck :twist -16) (:head :twist -12)   ; blade upright before her
  (:arm-l :flex 60 :side 50) (:elbow-l :flex 130) (:hand-l :flex -60)                            ; right shoulder
  (:arm-r :flex 40 :side 10) (:elbow-r :flex 100) (:hand-r :twist 0 :flex -10)
  (:thigh-r :flex 30) (:knee-r :flex 36) (:thigh-l :flex -16) (:knee-l :flex 24))
(defclip :ru-s-kido (16 :fps 60 :base :ru-s-stance)      ; SOKATSUI's hold (<= 16 f; RIKUJOKORO after it): gathered, then still
  (0) (6 :ru-s-kido-pose) (16 :ru-s-kido-pose (:root :u -0.11)))

(defpose :ru-s-sokatsui-hit (:base :ru-s-kido-pose)    ; 蒼火墜: the left palm driven at his face, the right hand on its wrist
  (:root :f 0.24 :u -0.1) (:pelvis :twist 6) (:spine :flex 6) (:chest :twist -20) (:neck :twist 12) (:head :twist 10 :flex -6)
  (:arm-l :flex 112 :side 0) (:elbow-l :flex 0) (:hand-l :flex -80)
  (:arm-r :flex 24 :side -105) (:elbow-r :flex 46) (:hand-r :twist 70 :flex 100)
  (:thigh-r :flex 48) (:knee-r :flex 50) (:thigh-l :flex -30) (:knee-l :flex 6))
(defstrike :ru-s-sokatsui (14 4 26 :base :ru-s-stance)   ; SP1 tap 破道の三十三 蒼火墜 canon (ch. 266) [T-hi / P]: from the gather
  (0 :ru-s-kido-pose (:root :u -0.11))
  (8 (:root :u -0.15) (:chest :twist 26) (:arm-l :flex 44 :side 62) (:elbow-l :flex 140) (:arm-r :flex 56 :side -10)   ; wound
     (:elbow-r :flex 110) (:knees :flex 44))                                                    ; back, the right hand crossing
  (12 (:root :u -0.16) (:chest :twist 28))                                                     ; held: the tell
  (:s :snap :ru-s-sokatsui-hit)                                                                ; the fire
  (:a (:root :f 0.25) (:arm-l :flex 113))
  (26 (:root :f 0.16) (:arm-l :flex 118) (:elbow-l :flex 14))                                   ; the impact hold, the kick back
  (34 (:root :f 0.06 :u -0.07) (:chest :twist 0) (:arm-l :flex 50 :side 30) (:elbow-l :flex 70) (:hand-l :flex -20)
      (:arm-r :flex 40 :side 14) (:elbow-r :flex 24) (:hand-r :twist 0 :flex -66))
  (:end :ru-s-stance))

(defpose :ru-s-rikujo-pose (:base :ru-s-kido-pose)     ; 六杖光牢's hold: two fingers raised straight overhead, tall, the
  (:root :u -0.02) (:pelvis :twist 12) (:spine :flex -6) (:chest :twist 0) (:neck :twist -4) (:head :flex -16 :twist -4)   ; blade
  (:arm-l :flex 178 :side 6) (:elbow-l :flex 0) (:hand-l :flex -4)                             ; point-down at her side
  (:arm-r :flex 6 :side 14) (:elbow-r :flex 10) (:hand-r :twist 160 :flex 10)
  (:thigh-r :flex 10) (:knee-r :flex 10) (:thigh-l :flex -6) (:knee-l :flex 8))
(defclip :ru-s-rikujo (66 :fps 60 :base :ru-s-stance)    ; SP1 held: RIKUJOKORO's hold (<= 56 f, then its last key held):
  (0 :ru-s-kido-pose (:root :u -0.11))                 ; raised, then a slow breath (no bounce, the hand never moves)
  (8 :ru-s-rikujo-pose)
  (24 (:root :u -0.03) (:head :flex -17))
  (40 (:root :u -0.015) (:head :flex -15))
  (56 (:root :u -0.03) (:head :flex -17))
  (66 (:root :u -0.02) (:head :flex -16)))
(defstrike :ru-s-rikujo-cast (16 0 26 :base :ru-s-stance)   ; ... let go: the ring marked at f2, the arm dropped to point at him
  (0 :ru-s-rikujo-pose)                                                                        ; as the rods shut (f16)
  (6 (:root :u 0.0) (:head :flex -20) (:spine :flex -8))                                       ; a breath higher: the tell
  (12 (:root :u 0.0) (:head :flex -20))
  (:s :snap (:root :u -0.1 :f 0.1) (:spine :flex 8) (:chest :twist -20) (:neck :twist 10) (:head :flex -4 :twist 10)   ; dropped
      (:arm-l :flex 84 :side 0) (:elbow-l :flex 0) (:hand-l :flex -4) (:knees :flex 26) (:thighs :flex 14))
  (28 (:root :u -0.11 :f 0.1) (:arm-l :flex 82))                                                ; held: the rods
  (34 (:root :u -0.07 :f 0.04) (:chest :twist 0) (:arm-l :flex 50 :side 30) (:elbow-l :flex 70) (:hand-l :flex -20)
      (:arm-r :flex 30 :side 14) (:elbow-r :flex 24) (:hand-r :twist 0 :flex -66))
  (:end :ru-s-stance))

;;; ---------------------------------------------------------------- -18 C's own clips (DUEL_RUKIA_TYBW §13.4)
;;; 摺り足 for J (the glide: the root level, no step), 袖・素手 for K (the sleeve and the bare left palm), the canon gestures
;;; for L / SP / O / I (docs/research/rukia-rework/style-refs.md §3.2). Played by -18 only, through the :m18 kit's :clip-map
;;; (rukia.lisp *RU-18-CLIPS*; -50 and zero set it back) and its :look-clips / :run-clips. Every strike: a tell inside the
;;; startup, the hit pose on S, an impact hold through A, a follow-through and a settle key in the recovery; turns keyed
;;; about every 90 deg with root yaw + a pelvis roll. Each K's 霜の穂先 (*RU-FROST-POINTS*: the palm's bloom, the sleeve's
;;; sheet, the ice flower) carries its reach past the palm or the point.
(defpose :ru-18-stance ()                              ; the canon catch: the left arm forward-high, the palm open to him; the
  (:root :u -0.13) (:pelvis :twist 22) (:spine :flex 10) (:chest :twist -18) (:neck :twist 12) (:head :flex -6 :twist 6)   ; blade
  (:arm-r :flex -40 :side 30) (:elbow-r :flex 12) (:hand-r :twist 0 :flex -100)                   ; low and back in the right
  (:arm-l :flex 112 :side 8) (:elbow-l :flex 14) (:hand-l :flex -64)                              ; hand; the hips lower than
  (:thigh-r :flex 34 :side 4) (:knee-r :flex 44) (:thigh-l :flex -14 :side 6) (:knee-l :flex 36)) ; the Shikai's
(defclip :ru-18-stance (2.6 :loop t :base :ru-18-stance)   ; still: the hips sink 1 cm with the breath, the palm never moves
  (0) (1.3 (:root :u -0.14) (:elbow-l :flex 16)))

;; 摺り足: the walk glides at the stance's height (no bob), the feet barely lift; the stance's arms (the palm held out)
(defclip :ru-18-walk-f (1.0 :loop t :base :ru-18-stance)
  (0 (:thigh-r :flex 42) (:knee-r :flex 44) (:thigh-l :flex -6) (:knee-l :flex 36))
  (0.25 (:thigh-r :flex 30) (:knee-r :flex 48) (:thigh-l :flex 4) (:knee-l :flex 44))
  (0.5 (:thigh-l :flex 12) (:knee-l :flex 36) (:thigh-r :flex 22) (:knee-r :flex 44))
  (0.75 (:thigh-r :flex 30) (:knee-r :flex 48) (:thigh-l :flex 0) (:knee-l :flex 40)))
(defclip :ru-18-walk-b (1.0 :loop t :base :ru-18-stance)
  (0 (:thigh-r :flex 24) (:knee-r :flex 44) (:thigh-l :flex -20) (:knee-l :flex 34))
  (0.25 (:thigh-r :flex 30) (:knee-r :flex 48) (:thigh-l :flex -10) (:knee-l :flex 42))
  (0.5 (:thigh-r :flex 38) (:knee-r :flex 44) (:thigh-l :flex -6) (:knee-l :flex 34))
  (0.75 (:thigh-r :flex 30) (:knee-r :flex 48) (:thigh-l :flex -12) (:knee-l :flex 42)))
(defclip :ru-18-strafe-r (0.9 :loop t :base :ru-18-stance)
  (0 (:thigh-r :side 14) (:thigh-l :side 2))
  (0.225 (:thigh-r :side 9) (:knee-r :flex 48) (:thigh-l :side 7))
  (0.45 (:thigh-r :side 4) (:thigh-l :side 10))
  (0.675 (:thigh-r :side 9) (:knee-l :flex 42) (:thigh-l :side 6)))
(defclip :ru-18-strafe-l (0.9 :loop t :base :ru-18-stance)
  (0 (:thigh-l :side 14) (:thigh-r :side 0))
  (0.225 (:thigh-l :side 9) (:knee-l :flex 42) (:thigh-r :side 6))
  (0.45 (:thigh-l :side 4) (:thigh-r :side 10))
  (0.675 (:thigh-l :side 9) (:knee-r :flex 48) (:thigh-r :side 6)))

;; the run: crouched lower than the Shikai's, the blade trailing low behind, the bare left palm forward
(defpose :ru-18-run-pose (:base :ru-18-stance)
  (:pelvis :twist 10) (:chest :twist -10) (:neck :twist 4) (:head :twist 2)
  (:arm-r :flex -50 :side 20) (:elbow-r :flex 8) (:hand-r :twist 0 :flex -70)
  (:arm-l :flex 70 :side 10) (:elbow-l :flex 30) (:hand-l :flex -50))
(defclip :ru-18-run (0.5 :loop t :base :ru-18-run-pose)
  (0 (:root :u -0.2) (:spine :flex 34) (:head :flex -26) (:thigh-r :flex 54) (:knee-r :flex 26) (:thigh-l :flex -26) (:knee-l :flex 60))
  (0.125 (:root :u -0.16) (:thigh-r :flex 20) (:knee-r :flex 40) (:thigh-l :flex 14) (:knee-l :flex 96))
  (0.25 (:root :u -0.2) (:thigh-l :flex 54) (:knee-l :flex 26) (:thigh-r :flex -26) (:knee-r :flex 60))
  (0.375 (:root :u -0.16) (:thigh-l :flex 20) (:knee-l :flex 40) (:thigh-r :flex 14) (:knee-r :flex 96)))

;; J1 摺り足 (down-right B1, his view): a 0.3 m glide, no step, the body level; a short cut from her right shoulder down
;; across her front
(defpose :ru-18-j1-hit (:base :ru-18-stance)
  (:root :yaw 10 :f 0.3) (:pelvis :side -4) (:chest :twist -6) (:neck :twist 4)
  (:arm-r :side 84 :flex 80) (:elbow-r :flex 6) (:hand-r :twist 12 :flex -92)
  (:arm-l :flex 70 :side 20) (:elbow-l :flex 60) (:hand-l :flex -40))
(defstrike :ru-18-j1 (7 3 12 :base :ru-18-stance)
  (0)
  (3 (:root :yaw -22 :f 0.08) (:pelvis :side 4) (:chest :twist 4) (:neck :twist 18)                ; the tell: the blade up
     (:arm-r :side 120 :flex 10) (:elbow-r :flex 50) (:hand-r :twist -70 :flex -70))                ; at her right shoulder
  (5 (:root :yaw -24 :f 0.16) (:arm-r :side 124))                                                 ; (held: gliding)
  (:s :snap :ru-18-j1-hit)
  (9 (:root :yaw 22 :f 0.32) (:pelvis :side -6) (:arm-r :side 66 :flex 108) (:hand-r :twist 35))   ; down across
  (:a (:root :yaw 26 :f 0.32) (:arm-r :side 55 :flex 125) (:hand-r :twist 50))                    ; the impact held: low left
  (16 (:root :yaw 14 :f 0.2) (:pelvis :side -2) (:arm-r :side 40 :flex 90) (:elbow-r :flex 20) (:hand-r :twist 30 :flex -80))   ; settle
  (:end :ru-18-stance))

;; J2 摺り足 (up-left B1b, his view): the glide goes on; a short backhand up from her left knee, the wrist turned over, to
;; above her right shoulder
(defpose :ru-18-j2-hit (:base :ru-18-stance)
  (:root :yaw -8 :f 0.24) (:pelvis :side 4) (:chest :twist -10)
  (:arm-r :side 40 :flex 92) (:elbow-r :flex 6 :twist 160) (:hand-r :twist 0 :flex -88)
  (:arm-l :flex 60 :side 24) (:elbow-l :flex 70) (:hand-l :flex -40))
(defstrike :ru-18-j2 (7 3 13 :base :ru-18-stance)
  (0)
  (3 (:root :yaw 26 :f 0.06) (:pelvis :side -4) (:chest :twist -26) (:neck :twist 18)              ; the tell: the blade low at
     (:arm-r :side -24 :flex 30) (:elbow-r :flex 30 :twist 160) (:hand-r :twist 0 :flex -80))       ; her left knee, wrist over
  (5 (:root :yaw 28 :f 0.12) (:arm-r :side -26 :flex 26))                                         ; (held: gliding)
  (:s :snap :ru-18-j2-hit)
  (9 (:root :yaw -26 :f 0.26) (:pelvis :side 6) (:arm-r :side 105 :flex 50) (:hand-r :twist 20 :flex -84))   ; up across
  (:a (:root :yaw -30 :f 0.26) (:arm-r :side 125 :flex 20) (:elbow-r :flex 16) (:hand-r :twist 40 :flex -80))   ; above the right
  (16 (:root :yaw -18 :f 0.16) (:pelvis :side 2) (:arm-r :side 80 :flex 30) (:elbow-r :flex 20 :twist 80) (:hand-r :twist 0 :flex -70))   ; shoulder
  (:end :ru-18-stance))

;; J3 摺り足, the finale: the pass (H<- B1, his view): a fast glide across his line to her left, the blade cut flat at chest
;; height as she passes, ending side-on, her back half turned, still; then the glide back into the stance
(defpose :ru-18-j3-hit (:base :ru-18-stance)
  (:root :r -0.4 :yaw -12 :f 0.2 :u -0.15) (:pelvis :side 6) (:chest :twist -4) (:neck :twist 8)
  (:arm-r :side 88 :flex 92) (:elbow-r :flex 4) (:hand-r :twist 0 :flex -88)
  (:arm-l :flex 30 :side 50) (:elbow-l :flex 30) (:hand-l :flex -20))
(defstrike :ru-18-j3 (8 3 18 :base :ru-18-stance)
  (0)
  (3 (:root :yaw 40 :u -0.15) (:pelvis :side -4) (:chest :twist -24) (:neck :twist -10)             ; the tell: turned left, the
     (:arm-r :side 88 :flex 140) (:elbow-r :flex 30) (:hand-r :twist 0 :flex -80))                  ; blade drawn across to her left
  (5 (:root :r -0.16 :yaw 26 :f 0.08) (:arm-r :flex 132))                                         ; the glide starts
  (:s :snap :ru-18-j3-hit)
  (10 (:root :r -0.56 :yaw -56 :f 0.22) (:pelvis :side 8) (:arm-r :flex 40))                      ; past him, the blade through
  (:a (:root :r -0.6 :yaw -70 :f 0.22) (:arm-r :flex 30))
  (17 (:root :r -0.62 :yaw -96 :f 0.2 :u -0.16) (:pelvis :side 2) (:chest :twist 0) (:neck :twist 30) (:head :twist 30)   ; side-on,
      (:arm-r :side 30 :flex -20) (:elbow-r :flex 10) (:hand-r :flex -70) (:arm-l :flex 20 :side 20) (:elbow-l :flex 40))  ; still
  (23 (:root :r -0.6 :yaw -98 :f 0.2 :u -0.16) (:head :twist 34))                                 ; (held)
  (26 (:root :r -0.3 :yaw -50 :f 0.1))                                                            ; the glide back
  (:end :ru-18-stance))

;; K1 TOSHU 袖・素手 (T / P): the left palm drawn back to her shoulder (the tell), then driven out forward-high, open to him,
;; the right sleeve swung back as the counterweight; the frost bloom off the palm (*RU-FROST-POINTS*)
(defpose :ru-18-k1-hit (:base :ru-18-stance)
  (:root :yaw 6 :f 0.44 :u -0.16) (:pelvis :twist 6) (:spine :flex 12) (:chest :twist -12) (:neck :twist 22) (:head :twist 16)
  (:arm-l :flex 112 :side 0) (:elbow-l :flex 0) (:hand-l :flex -70)
  (:arm-r :flex -56 :side 34) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -60)
  (:thigh-r :flex 52) (:knee-r :flex 50) (:thigh-l :flex -28) (:knee-l :flex 16))
(defstrike :ru-18-k1 (17 4 20 :base :ru-18-stance)
  (0)
  (7 (:root :yaw 24 :u -0.16) (:chest :twist 10) (:neck :twist -6) (:head :twist -6)               ; the tell: the palm drawn
     (:arm-l :flex 50 :side 50) (:elbow-l :flex 124) (:hand-l :flex -60)                            ; back to her left shoulder,
     (:arm-r :flex -10 :side 44) (:hand-r :flex -80) (:knees :flex 50))                              ; coiled, sunk
  (14 (:root :yaw 28 :u -0.17 :f 0.06) (:elbow-l :flex 128))                                      ; (held: moving)
  (:s :snap :ru-18-k1-hit)
  (19 (:root :yaw 2 :f 0.47) (:arm-l :flex 114))
  (:a (:root :yaw 2 :f 0.47) (:arm-l :flex 113))                                                  ; the impact held
  (30 (:root :yaw 0 :f 0.26 :u -0.14) (:arm-l :flex 100 :side 6) (:elbow-l :flex 16) (:arm-r :flex -40))   ; settle
  (36 (:root :f 0.06))
  (:end :ru-18-stance))

;; K2 袖 (H-> S + B1, his view): wound to her right, the sleeve flung across first (the elbow leading, the wrist and the
;; blade trailing under it), then the blade low across her front; the frost sheet off the cut
(defpose :ru-18-k2-hit (:base :ru-18-stance)
  (:root :yaw 0 :f 0.16 :u -0.2) (:pelvis :side -4) (:spine :flex 16) (:chest :twist -4)
  (:arm-r :side 70 :flex 96) (:elbow-r :flex 6) (:hand-r :twist 0 :flex -96)
  (:arm-l :flex 40 :side 50) (:elbow-l :flex 30) (:hand-l :flex -30)
  (:thigh-r :flex 46) (:knee-r :flex 56) (:thigh-l :flex -24) (:knee-l :flex 36))
(defstrike :ru-18-k2 (21 4 24 :base :ru-18-stance)
  (0)
  (9 (:root :yaw -46 :u -0.15) (:pelvis :side 4) (:chest :twist 16) (:neck :twist 30) (:head :twist 20)   ; the tell: wound to
     (:arm-r :side 88 :flex -10) (:elbow-r :flex 20) (:hand-r :twist 0 :flex -88)                         ; her right, the
     (:arm-l :flex 60 :side -10) (:elbow-l :flex 100))                                                    ; blade out back
  (16 (:root :yaw -50 :u -0.16) (:arm-r :flex -14))                                                     ; (held: moving)
  (19 (:root :yaw -24 :u -0.18 :f 0.08) (:arm-r :side 80 :flex 40) (:elbow-r :flex 60) (:hand-r :flex -40))   ; the sleeve first
  (:s :snap :ru-18-k2-hit)
  (23 (:root :yaw 16 :f 0.18) (:pelvis :side -6) (:arm-r :flex 124))                              ; low across
  (:a (:root :yaw 22 :f 0.18) (:arm-r :flex 130))
  (36 (:root :yaw 12 :f 0.12 :u -0.17) (:pelvis :side -2) (:arm-r :side 72 :flex 112) (:elbow-r :flex 20) (:hand-r :twist 30 :flex -80))
  (43 (:root :yaw 4 :f 0.04) (:arm-r :side 70 :flex 30) (:hand-r :twist 0 :flex -90))            ; settle: the blade back round
  (:end :ru-18-stance))

;; K3 HYOKA 袖・素手 -> 見得 (V-down / P): the palm raised overhead as she rises (the tell), then down on one knee, the palm
;; laid flat on the plaza, the sleeve pooling; the ice flower runs out along the plaza; held, the head up last
(defpose :ru-18-k3-hit (:base :ru-18-stance)
  (:root :u -0.54 :f 0.26) (:pelvis :twist 0) (:spine :flex 32) (:chest :twist -4) (:neck :twist 10) (:head :flex 18 :twist 6)
  (:arm-l :flex 62 :side 4) (:elbow-l :flex 0) (:hand-l :flex 50)
  (:arm-r :flex -40 :side 34) (:elbow-r :flex 16) (:hand-r :twist 0 :flex -104)
  (:thigh-r :flex 74) (:knee-r :flex 116) (:thigh-l :flex -4 :side 12) (:knee-l :flex 100))
(defstrike :ru-18-k3 (21 5 34 :base :ru-18-stance)
  (0)
  (9 (:root :u 0.0 :f 0.06) (:spine :flex -8) (:chest :twist 8) (:head :flex -24)                  ; the tell: risen, the palm
     (:arm-l :flex 164 :side 10) (:elbow-l :flex 14) (:hand-l :flex -30)                            ; raised overhead
     (:arm-r :flex 10 :side 50) (:thigh-r :flex 20) (:knee-r :flex 16) (:thigh-l :flex -10) (:knee-l :flex 10))
  (17 (:root :u 0.02 :f 0.08) (:arm-l :flex 170) (:spine :flex -11))                             ; (held: moving)
  (:s :snap :ru-18-k3-hit)
  (:a (:root :u -0.55) (:spine :flex 33))                                                         ; the impact held
  (42 (:root :u -0.54 :f 0.26) (:head :flex 20))                                                   ; 見得: held, the head down
  (47 (:head :flex -14 :twist 10))                                                                ; the head up last
  (52 (:root :u -0.52))
  (56 (:root :u -0.22 :f 0.12) (:spine :flex 22) (:arm-l :flex 70 :side 10) (:elbow-l :flex 30) (:hand-l :flex -40)
      (:thigh-r :flex 50) (:knee-r :flex 60) (:thigh-l :flex -12) (:knee-l :flex 50) (:head :flex -8))
  (:end :ru-18-stance))

;; L SHIMOBASHIRA 巫女舞 (stab + counter-clockwise / B1r): the blade reversed, point down, tapped into the plaza at her feet
;; while she turns a half circle on the spot (her right quarter to her left quarter): the ring of pillars on S
(defpose :ru-18-tap (:base :ru-18-stance)            ; the reversed point tapped into the plaza at her feet
  (:root :u -0.22) (:spine :flex 24) (:chest :twist 0) (:neck :twist 0) (:head :flex 18 :twist 0)
  (:arm-r :flex 40 :side 12) (:elbow-r :flex 40) (:hand-r :twist 160 :flex 10)
  (:arm-l :flex 30 :side 60) (:elbow-l :flex 30) (:hand-l :flex -30)
  (:thigh-r :flex 46) (:knee-r :flex 60) (:thigh-l :flex 40) (:knee-l :flex 60))
(defstrike :ru-18-shimobashira (12 0 22 :base :ru-18-stance)
  (0)
  (3 :ru-18-tap (:root :yaw -50 :u -0.16) (:arm-r :flex 70) (:elbow-r :flex 70) (:pelvis :side 4))   ; reversed, turning right
  (5 :snap :ru-18-tap (:root :yaw -90) (:pelvis :side 6))                                            ; tap 1
  (7 :ru-18-tap (:root :yaw -40 :u -0.18) (:arm-r :flex 60) (:elbow-r :flex 60))                    ; lifted, turning back
  (9 :snap :ru-18-tap (:root :yaw 0) (:pelvis :side 0))                                              ; tap 2
  (10 :ru-18-tap (:root :yaw 45 :u -0.18) (:arm-r :flex 58) (:elbow-r :flex 58) (:pelvis :side -4))
  (:s :snap :ru-18-tap (:root :yaw 90 :u -0.24) (:pelvis :side -6) (:spine :flex 28))               ; tap 3: the pillars
  (18 :ru-18-tap (:root :yaw 92 :u -0.24) (:spine :flex 28))                                        ; held
  (26 (:root :yaw 44 :u -0.16) (:pelvis :side -2) (:arm-r :flex 30 :side 20) (:elbow-r :flex 20) (:hand-r :twist 80 :flex -20)
      (:spine :flex 14) (:head :flex 0))
  (30 (:root :yaw 10 :u -0.14))
  (:end :ru-18-stance))

;; SP1 HAKUREN canon 白漣 (摺り足): the hold (<= 64 f, one stab per 16 f, the CHARGE's spikes in a half circle before her,
;; her left to her right, RUKIA-SPIKE): one-hand reversed stabs at each spike, a sideways glide between them; then held
(defpose :ru-18-stab (:base :ru-18-stance)           ; a one-hand reversed stab into the plaza before her
  (:root :u -0.22) (:spine :flex 30) (:chest :twist 0) (:neck :twist -4) (:head :flex 16 :twist 0)
  (:arm-r :flex 52 :side 8) (:elbow-r :flex 26) (:hand-r :twist 160 :flex 10)
  (:arm-l :flex 20 :side 50) (:elbow-l :flex 30) (:hand-l :flex -30)
  (:thigh-r :flex 56) (:knee-r :flex 62) (:thigh-l :flex -10) (:knee-l :flex 50))
(defpose :ru-18-stab-up (:base :ru-18-stab)          ; ... lifted out between the stabs
  (:root :u -0.15) (:spine :flex 16) (:arm-r :flex 86) (:elbow-r :flex 64) (:head :flex 6)
  (:thigh-r :flex 40) (:knee-r :flex 46) (:knee-l :flex 40))
(defclip :ru-18-hakuren-hold (64 :fps 60 :base :ru-18-stance)
  (0)
  (8 :ru-18-stab-up (:root :yaw 40 :r -0.24))
  (16 :snap :ru-18-stab (:root :yaw 45 :r -0.26))                ; stab 1
  (23 :ru-18-stab-up (:root :yaw 28 :r -0.14))                   ; lifted, gliding to her right
  (32 :snap :ru-18-stab (:root :yaw 15 :r -0.08))                ; stab 2
  (39 :ru-18-stab-up (:root :yaw -2 :r 0.02))
  (48 :snap :ru-18-stab (:root :yaw -15 :r 0.08))                ; stab 3
  (55 :ru-18-stab-up (:root :yaw -32 :r 0.18))
  (64 :snap :ru-18-stab (:root :yaw -45 :r 0.26)))               ; stab 4 (held)
;; ... released: the blade swept up and forward out of the last stab (frame 0 the middle stab: a release after any stab
;; turns <= 60 deg into it)
(defstrike :ru-18-hakuren (6 1 24 :base :ru-18-stance)
  (0 :ru-18-stab (:root :yaw -15 :r 0.08))
  (3 (:root :yaw -8 :r 0.06 :u -0.14) (:spine :flex 10) (:arm-r :flex 90 :side 10) (:elbow-r :flex 20) (:hand-r :twist 60 :flex -40))
  (:s :snap (:root :yaw 0 :r 0.02 :u -0.04 :f 0.2) (:spine :flex -8) (:head :flex -16) (:arm-r :flex 130 :side 12) (:elbow-r :flex 4)
      (:hand-r :twist -10 :flex -84) (:arm-l :side 70 :flex -10) (:elbow-l :flex 10) (:thigh-r :flex 30) (:knee-r :flex 24))
  (:a (:arm-r :flex 132))
  (20 (:root :u -0.1 :f 0.1) (:arm-r :flex 90 :side 18) (:elbow-r :flex 20) (:hand-r :flex -60) (:spine :flex 6) (:head :flex -4))
  (:end :ru-18-stance))

;; SP2 SHIRAFUNE canon 白刀 (T / B1): the glide in first (摺り足, level), the blade drawn back low at her hip and the palm
;; aimed, then the one-arm thrust at his chest; the ice runs on to 5 m (RUKIA-BLADE-LOOK)
(defpose :ru-18-shirafune-hit (:base :ru-18-stance)
  (:root :f 0.66 :u -0.2) (:pelvis :twist 14) (:spine :flex 10) (:chest :twist 6) (:neck :twist -16) (:head :twist -12)
  (:arm-r :flex 94 :side 2) (:elbow-r :flex 0) (:hand-r :twist -10 :flex -96)
  (:arm-l :flex -30 :side 40) (:elbow-l :flex 20) (:hand-l :flex -30)
  (:thigh-r :flex 70) (:knee-r :flex 72) (:thigh-l :flex -36) (:knee-l :flex 6))
(defstrike :ru-18-shirafune (16 4 28 :base :ru-18-stance)
  (0)
  (6 (:root :f 0.18 :u -0.15) (:chest :twist -20) (:arm-r :flex 10 :side 16) (:elbow-r :flex 100) (:hand-r :twist -10 :flex -80)   ; the
     (:arm-l :flex 96 :side 6) (:elbow-l :flex 10))                                                                            ; glide
  (13 (:root :f 0.42 :u -0.16) (:chest :twist -26) (:arm-r :flex -6) (:elbow-r :flex 120))       ; the tell: drawn back, gliding
  (:s :snap :ru-18-shirafune-hit)
  (:a (:root :f 0.7) (:arm-r :flex 95))
  (30 (:root :f 0.56 :u -0.19))
  (40 (:root :f 0.2 :u -0.14) (:arm-r :flex 40 :side 14) (:elbow-r :flex 26) (:hand-r :flex -70) (:arm-l :flex 70 :side 10)
      (:elbow-l :flex 30) (:thigh-r :flex 40) (:knee-r :flex 46) (:thigh-l :flex -14) (:knee-l :flex 34))   ; the glide back
  (:end :ru-18-stance))

;; O HAKKA NO TOGAME canon battle stance (up + level / B1): the blade raised overhead one-handed, held while the pillar
;; rises at her (f4), then levelled at him (S), the cold off the tip
(defpose :ru-18-hakka-hit (:base :ru-18-stance)
  (:root :f 0.22 :u -0.14) (:pelvis :twist 16) (:spine :flex 6) (:chest :twist 4) (:neck :twist -20) (:head :flex -6 :twist -16)
  (:arm-r :flex 96 :side 2) (:elbow-r :flex 0) (:hand-r :twist 0 :flex -88)
  (:arm-l :flex -10 :side 44) (:elbow-l :flex 30) (:hand-l :flex -30)
  (:thigh-r :flex 44) (:knee-r :flex 48))
(defstrike :ru-18-hakka (20 3 30 :base :ru-18-stance)
  (0)
  (4 (:root :u -0.02) (:pelvis :twist 14) (:spine :flex -8) (:chest :twist 0) (:neck :twist -6) (:head :flex -24 :twist -4)   ; raised
     (:arm-r :flex 176 :side 6) (:elbow-r :flex 4) (:hand-r :twist 0 :flex -86) (:arm-l :flex 40 :side 30) (:elbow-l :flex 30)
     (:thigh-r :flex 14) (:knee-r :flex 14) (:thigh-l :flex -6) (:knee-l :flex 10))
  (10 (:arm-r :flex 179) (:root :u -0.01) (:arm-l :flex 20 :side 34))                            ; held
  (17 (:arm-r :flex 180) (:root :u 0.0))
  (:s :snap :ru-18-hakka-hit)
  (:a (:root :f 0.24))
  (40 (:root :f 0.16 :u -0.13) (:arm-r :flex 60 :side 10) (:elbow-r :flex 20) (:hand-r :flex -60))
  (:end :ru-18-stance))

;; I HAINAWA サシ (low; pt up / P): the Breaker's strike: from the dash, two fingers flicked from her left hip out and up at
;; him, the blade kept low and back
(defpose :ru-18-hainawa-hit (:base :ru-18-stance)
  (:root :f 0.86 :u -0.16) (:pelvis :twist -6) (:spine :flex 10) (:chest :twist -34) (:neck :twist 18) (:head :flex -8 :twist 12)
  (:arm-l :flex 116 :side 2) (:elbow-l :flex 0) (:hand-l :flex -6)
  (:thigh-r :flex 50) (:knee-r :flex 50) (:thigh-l :flex -26) (:knee-l :flex 16))
(defstrike :ru-18-hainawa (8 4 18 :base :ru-18-stance)
  (0 (:root :u -0.17 :f 0.12) (:spine :flex 22) (:chest :twist 10) (:arm-l :flex -10 :side 20) (:elbow-l :flex 30)   ; the fingers
     (:hand-l :flex -10) (:knees :flex 50))                                                                         ; at her hip
  (5 (:root :u -0.17 :f 0.4) (:chest :twist -6) (:arm-l :flex 40 :side 40) (:elbow-l :flex 10))   ; flicked out
  (:s :snap :ru-18-hainawa-hit)
  (10 (:root :f 0.9) (:arm-l :flex 119))
  (:a (:root :f 0.89) (:arm-l :flex 118))
  (22 (:root :f 0.44 :u -0.14) (:chest :twist -24) (:arm-l :flex 90 :side 10) (:elbow-l :flex 30))
  (:end :ru-18-stance))

;;; ---------------------------------------------------------------- ice looks (cosmetic: RND01, the fx clock)
(defun-fast vfx-ru-ring (x z r grow k)
  "A white ring of radius R on the plaza (x z) drawn round in GROW (0..1 of its circle: the blade tip's sweep) with ink
ticks, presence K: TSUKISHIRO's circle, the tell."
  (with-floats (x z r grow k)
    (let* ((dr (drawing-no)) (sd (i->f (mod (f->i dr) 5))) (n (f->i (* 32f0 (f-clamp grow 0f0 1f0)))))
      (declare (single-float dr sd) (fixnum n))
      (when (>= n 32) (%tring x 0.01f0 z r 0.06f0 +pal-hit+ k sd 32))
      (when (and (> n 0) (< n 32))                       ; the arc being drawn
        (dotimes (i n)
          (let* ((a0 (* 0.19635f0 (i->f i))) (a1 (+ a0 0.19635f0)))
            (declare (single-float a0 a1))
            (toon-ground-seg (+ x (* r (f-cos a0))) (+ z (* r (f-sin a0))) (+ x (* r (f-cos a1))) (+ z (* r (f-sin a1)))
                             0.02f0 0.06f0 1f0 1f0 (+ sd 3f0) 0.12f0 (toon-a +pal-hit+ k)))))
      (dotimes (i 8)                                      ; ink ticks round it
        (let* ((a (* 0.7854f0 (i->f i))) (c (f-cos a)) (s (f-sin a)))
          (declare (single-float a c s))
          (when (< (i->f i) (* 8f0 grow))
            (toon-ground-seg (+ x (* (- r 0.2f0) c)) (+ z (* (- r 0.2f0) s)) (+ x (* (+ r 0.15f0) c)) (+ z (* (+ r 0.15f0) s))
                             0.025f0 0.02f0 1f0 1f0 (+ 9f0 (i->f i)) 0.1f0 (toon-a +pal-ink+ k))))))
    nil))

(defun-fast vfx-ru-pillar (x z r height age dt)
  "A pillar of white light and ice HEIGHT m tall rising from the plaza (x z), radius R: SOUL-glass tongues over white
cores, rising over its first 0.15 s, shards thrown out, ice motes (TSUKISHIRO, 白霞罸's pillar, a victim encased)."
  (with-floats (x z r height age dt)
    (let* ((rise (f-clamp (/ age 0.15f0) 0f0 1f0)) (h (* height rise)) (dr (drawing-no)) (k (f-clamp (- 1.4f0 (* 0.8f0 age)) 0.1f0 0.98f0)))
      (declare (single-float rise h dr k))
      (when (> h 0.05f0)
        (dotimes (i 7)
          (let* ((f (i->f i)) (a (+ (* 0.8976f0 f) (* 0.3f0 (hash01 f 2.1f0)))) (rr (* r 0.6f0))
                 (hh (* h (+ 0.75f0 (* 0.35f0 (hash01 (+ f dr) 4.3f0))))) (sd (- -1f0 (+ f (* 3f0 (i->f (mod (f->i dr) 4)))))))
            (declare (single-float f a rr hh sd))
            (toon-ribbon ((+ x (* rr (f-cos a))) 0f0 (+ z (* rr (f-sin a)))) (0f0 hh 0f0) ((* 0.35f0 r) 0.05f0) :heat (1f0 0.3f0) :seed sd :wob 0.15f0
                         :pal +pal-soul+ :k k :ph (+ f dr) :sway 0.05f0 :segs 5)))
        (toon-ribbon (x 0f0 z) (0f0 (* 1.1f0 h) 0f0) ((* 0.22f0 r) 0.02f0) :heat (1f0 0.5f0) :seed -3f0 :wob 0.1f0 :pal +pal-hit+ :k k :ph dr
                     :sway 0.02f0 :segs 4)
        (%tring x 0f0 z r 0.08f0 +pal-soul+ k (i->f (mod (f->i dr) 5)) 24))
      (dotimes (i (n-of (* 30f0 k) dt))
        (%t-blob (+ x (rnd-range (- r) r)) (rnd-range 0.2f0 h) (+ z (rnd-range (- r) r)) 0f0 (rnd-range 0.5f0 1.5f0) 0f0
                 (rnd-range 0.5f0 0.9f0) (rnd-range 0.02f0 0.05f0) 0f0 0.1f0 +pal-hit+))
      (when (< age 0.1f0)
        (dotimes (i (n-of 120f0 dt))
          (let ((a (rnd-range 0f0 6.2832f0)) (sp (rnd-range 2f0 5f0)))
            (declare (single-float a sp))
            (%t-shard x (rnd-range 0.2f0 1.5f0) z (* sp (f-cos a)) (rnd-range 1f0 4f0) (* sp (f-sin a)) (rnd-range 0.5f0 0.9f0)
                      (rnd-range 0.08f0 0.16f0) 6f0 +pal-soul+))))
      (%light x 1.5f0 z 0.85f0 0.9f0 1f0 5f0 (* 1.6f0 k) 6))
    nil))

(defun-fast vfx-ru-lake (x z r y k)
  "A flat, lake-like disc of frost of radius R at height Y over (x z): a white rim, SOUL-glass rings inside, ink cracks
(the plaza whitening under her; 白霞罸's two lakes, plaza and sky)."
  (with-floats (x z r y k)
    (when (> r 0.05f0)
      (let* ((dr (drawing-no)) (sd (i->f (mod (f->i dr) 5))))
        (declare (single-float dr sd))
        (%tring x y z r 0.08f0 +pal-hit+ k sd 32)
        (%tring x y z (* 0.72f0 r) 0.12f0 +pal-soul+ (* 0.8f0 k) (+ sd 1f0) 32)
        (%tring x y z (* 0.42f0 r) 0.1f0 +pal-soul+ (* 0.6f0 k) (+ sd 2f0) 24)
        (dotimes (i 6)
          (let* ((a (+ (* 1.0472f0 (i->f i)) (hash01 (i->f i) 5.5f0))) (c (f-cos a)) (s (f-sin a)))
            (declare (single-float a c s))
            (toon-ground-seg (+ x (* 0.2f0 r c)) (+ z (* 0.2f0 r s)) (+ x (* 0.95f0 r c)) (+ z (* 0.95f0 r s)) (+ y 0.01f0)
                             0.025f0 1f0 0.3f0 (+ 20f0 (i->f i)) 0.2f0 (toon-a +pal-ink+ (* 0.7f0 k)))))))
    nil))

(defun-fast vfx-ru-sheet (x0 z0 x1 z1 age life)
  "The cold running off the blade's tip along the ground from (x0 z0) toward (x1 z1): a white sheet racing out in 0.15 s,
SOUL-glass edges, eroding over LIFE (HAKKA's lane, the Hakuren-like wave of 白霞罸)."
  (with-floats (x0 z0 x1 z1 age life)
    (let* ((dx (- x1 x0)) (dz (- z1 z0)) (l (f-max 0.01f0 (f-hypot dx dz))) (ux (/ dx l)) (uz (/ dz l))
           (run (f-clamp (/ age 0.15f0) 0f0 1f0)) (k (f-clamp (* 0.98f0 (- 1f0 (/ age (f-max life 0.01f0)))) 0f0 0.98f0))
           (dr (drawing-no)) (sd (i->f (mod (f->i dr) 5))) (e (* run l)))
      (declare (single-float dx dz l ux uz run k dr sd e))
      (when (> k 0.02f0)
        (toon-ground-seg (+ x0 (* 0.5f0 ux)) (+ z0 (* 0.5f0 uz)) (+ x0 (* 0.5f0 ux) (* e ux)) (+ z0 (* 0.5f0 uz) (* e uz)) 0.03f0 0.9f0 1f0 0.4f0 (+ sd 30f0)
                         0.25f0 (toon-a +pal-soul+ k))
        (toon-ground-seg (+ x0 (* 0.5f0 ux)) (+ z0 (* 0.5f0 uz)) (+ x0 (* 0.5f0 ux) (* e ux)) (+ z0 (* 0.5f0 uz) (* e uz)) 0.035f0 0.35f0 1f0 0.6f0 (+ sd 34f0)
                         0.12f0 (toon-a +pal-hit+ k))
        (dotimes (i 5)                                   ; ice spikes standing along it
          (let* ((u (* (+ 0.15f0 (* 0.18f0 (i->f i))) e)))
            (declare (single-float u))
            (toon-ribbon ((+ x0 (* u ux)) 0f0 (+ z0 (* u uz))) (0f0 (* 0.9f0 k (+ 0.6f0 (hash01 (i->f i) 3.3f0))) 0f0) (0.12f0 0.01f0)
                         :heat (1f0 0.3f0) :seed (- -5f0 (i->f i)) :wob 0.1f0 :pal +pal-soul+ :k k :ph (i->f i) :segs 3)))))
    nil))

(defun-fast vfx-ru-dust (x y z)
  "A figure weathering into ice dust (x y z = the feet): SOUL-glass shards peeling off the whole body and drifting up and
away, white flakes (TENCHI's ash crumble, re-coloured). One-shot."
  (with-floats (x y z)
    (dotimes (i 48)
      (%t-shard (+ x (rnd-range -0.3f0 0.3f0)) (+ y (rnd-range 0.1f0 1.8f0)) (+ z (rnd-range -0.3f0 0.3f0))
                (rnd-range -1.2f0 1.2f0) (rnd-range 0.4f0 1.6f0) (rnd-range -1.2f0 1.2f0) (rnd-range 1.2f0 2.2f0)
                (rnd-range 0.05f0 0.12f0) -0.3f0 +pal-soul+))
    (dotimes (i 20)
      (%t-blob (+ x (rnd-range -0.3f0 0.3f0)) (+ y (rnd-range 0.2f0 1.7f0)) (+ z (rnd-range -0.3f0 0.3f0)) (rnd-range -0.6f0 0.6f0)
               (rnd-range 0.4f0 1.2f0) (rnd-range -0.6f0 0.6f0) (rnd-range 1f0 1.8f0) (rnd-range 0.03f0 0.06f0) -0.2f0 0.1f0 +pal-hit+))
    nil))

(defun-fast vfx-ru-crust (x y z dt)
  "A victim frozen solid: white ice crystals round his body (x y z = the body's middle), on twos."
  (declare (ignore dt))
  (with-floats (x y z)
    (let* ((dr (drawing-no)))
      (declare (single-float dr))
      (dotimes (i 9)
        (let* ((f (i->f i)) (a (* 0.698f0 f)) (h (+ -0.7f0 (* 1.6f0 (hash01 f 1.9f0)))))
          (declare (single-float f a h))
          (fx-shard (+ x (* 0.32f0 (f-cos a))) (+ y h) (+ z (* 0.32f0 (f-sin a))) (* 0.3f0 (f-cos a)) 0.9f0 (* 0.3f0 (f-sin a))
                    (+ 0.25f0 (* 0.15f0 (hash01 (+ f dr) 2.2f0))) 0.06f0 0.1f0 (+ f 40f0) +pal-soul+ 0.9f0))))
    nil))

(defun-fast vfx-ru-breath (x y z yaw)
  "One white breath puff from her mouth (x y z), drifting forward along YAW. One-shot."
  (with-floats (x y z yaw)
    (let ((fx (- (f-sin yaw))) (fz (- (f-cos yaw))))
      (declare (single-float fx fz))
      (dotimes (i 4)
        (%t-blob (+ x (* 0.1f0 fx)) y (+ z (* 0.1f0 fz)) (* fx (rnd-range 0.3f0 0.6f0)) (rnd-range 0.05f0 0.2f0)
                 (* fz (rnd-range 0.3f0 0.6f0)) (rnd-range 0.4f0 0.7f0) (rnd-range 0.015f0 0.03f0) -0.05f0 0.2f0 +pal-hit+)))
    nil))

(defun-fast vfx-frost (x z k dt)
  "Frost on a fighter's feet and shins (x z; K 0..1: its time left): SOUL-glass shards crusting them, a white ring (the
status is read on the model, not the HUD)."
  (with-floats (x z k dt)
    (let* ((dr (drawing-no)) (kk (f-clamp (+ 0.3f0 k) 0.3f0 0.95f0)))
      (declare (single-float dr kk))
      (%tring x 0f0 z 0.42f0 0.05f0 +pal-soul+ kk (i->f (mod (f->i dr) 5)) 16)
      (dotimes (i 6)
        (let* ((f (i->f i)) (a (+ (* 1.0472f0 f) 0.3f0)))
          (declare (single-float f a))
          (fx-shard (+ x (* 0.2f0 (f-cos a))) (+ 0.12f0 (* 0.25f0 (hash01 f 3.1f0))) (+ z (* 0.2f0 (f-sin a)))
                    (* 0.4f0 (f-cos a)) 0.9f0 (* 0.4f0 (f-sin a)) 0.18f0 0.045f0 0.1f0 (+ f 60f0) +pal-soul+ kk)))
      (dotimes (i (n-of 4f0 dt))
        (%t-blob (+ x (rnd-range -0.3f0 0.3f0)) 0.2f0 (+ z (rnd-range -0.3f0 0.3f0)) 0f0 (rnd-range 0.2f0 0.5f0) 0f0
                 (rnd-range 0.5f0 0.8f0) (rnd-range 0.02f0 0.035f0) 0f0 0.1f0 +pal-hit+)))
    nil))

;;; the hazards' draw functions (HAZARD-DRAW: (fn hazard rdt); a :fx hazard is a look only)
(defun rukia-ring-look (hz rdt)
  "TSUKISHIRO: the white ring while it waits (the tell: it pulses faster as it nears), then the pillar."
  (let ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)))
    (if (> (hazard-delay hz) 0)
        (vfx-ru-ring x z r (min 1.0 (/ (- 25 (hazard-delay hz)) 6.0)) (if (evenp (floor (hazard-delay hz) (if (< (hazard-delay hz) 10) 2 4))) 0.95 0.6))
        (progn (vfx-ru-ring x z r 1.0 (max 0.05 (- 0.95 (/ (hazard-age hz) 36.0))))
               (vfx-ru-pillar x z r 4.5 (/ (hazard-age hz) 60.0) rdt)))))

(defun rukia-spike-look (hz rdt)
  "HAKUREN's stab: an ice spike standing in the plaza, then crumbling."
  (declare (ignore rdt))
  (let* ((age (/ (hazard-age hz) 60.0)) (k (max 0.02 (- 0.95 (* 0.9 (/ (hazard-age hz) (max 1 (hazard-life hz)))))))
         (h (* (hazard-size hz) (min 1.0 (/ age 0.06)))))
    (with-floats (h k)
      (let ((x (hazard-x hz)) (z (hazard-z hz)))
        (toon-ribbon (x 0f0 z) (0.05f0 h 0f0) (0.09f0 0.005f0) :heat (1f0 0.3f0) :seed -7f0 :wob 0.1f0 :pal +pal-soul+ :k k :segs 3)
        (toon-ribbon (x 0f0 z) (0.02f0 (* 0.7f0 h) 0f0) (0.03f0 0.002f0) :heat (1f0 0.5f0) :seed -8f0 :wob 0.05f0 :pal +pal-hit+ :k k :segs 2)))))

(defun rukia-wave-look (hz rdt)
  "HAKUREN's wave: an avalanche of cold rolling along the ground, as wide as its hit box: a white crest over SOUL glass."
  (when (and (<= (hazard-delay hz) 0) (< (hazard-age hz) (hazard-life hz)))
    (let* ((x (hazard-x hz)) (z (hazard-z hz)) (yaw (hazard-yaw hz)) (hw (hazard-size hz))
           (px (- (fwd-z yaw))) (pz (fwd-x yaw)) (fx (fwd-x yaw)) (fz (fwd-z yaw)) (dr (drawing-no)))
      (with-floats (x z hw px pz fx fz dr)
        (dotimes (i 7)
          (let* ((u (- (* (/ (i->f i) 6f0) 2f0) 1f0)) (bx (+ x (* u hw px))) (bz (+ z (* u hw pz)))
                 (hh (* (+ 0.8f0 (* 0.6f0 (hash01 (+ (i->f i) dr) 1.7f0))) (- 1.2f0 (* 0.5f0 (f-abs u))))))
            (declare (single-float u bx bz hh))
            (toon-ribbon (bx 0f0 bz) ((* 0.3f0 fx) hh (* 0.3f0 fz)) (0.32f0 0.05f0) :heat (1f0 0.3f0) :seed (- -11f0 (i->f i)) :wob 0.2f0
                         :pal +pal-soul+ :k 0.9f0 :ph (+ (i->f i) dr) :sway 0.05f0 :segs 4)
            (toon-ribbon (bx 0.05f0 bz) ((* 0.3f0 fx) (* 0.6f0 hh) (* 0.3f0 fz)) (0.12f0 0.02f0) :heat (1f0 0.5f0) :seed (- -21f0 (i->f i)) :wob 0.1f0
                         :pal +pal-hit+ :k 0.9f0 :ph (+ (i->f i) dr) :sway 0.03f0 :segs 3)))
        (toon-ground-seg (- x (* 1.2f0 fx)) (- z (* 1.2f0 fz)) x z 0.02f0 hw 0.4f0 1f0 (+ 50f0 dr) 0.2f0 (toon-a +pal-soul+ 0.8f0))
        (dotimes (i (n-of 40f0 (f32 rdt)))
          (%t-blob (+ x (* (rnd-range -1f0 1f0) hw px)) (rnd-range 0.1f0 1f0) (+ z (* (rnd-range -1f0 1f0) hw pz))
                   (rnd-range -0.5f0 0.5f0) (rnd-range 0.3f0 1.2f0) (rnd-range -0.5f0 0.5f0) (rnd-range 0.4f0 0.7f0)
                   (rnd-range 0.04f0 0.08f0) -0.1f0 0.2f0 +pal-hit+))))))

(defun rukia-blade-look (hz rdt)
  "SHIRAFUNE: the ice blade grown off the point along the thrust (SIZE m), in three stepped drawings, then gone."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (yaw (hazard-yaw hz)) (l (hazard-size hz)) (age (hazard-age hz))
         (grow (min 1.0 (/ (1+ (floor age 2)) 3.0))) (k (max 0.02 (- 0.95 (* 0.06 (max 0 (- age 6))))))
         (x1 (+ x (* grow l (fwd-x yaw)))) (z1 (+ z (* grow l (fwd-z yaw)))))
    (with-floats (x z x1 z1 k)
      (fx-crescent x 1.1f0 z x1 1.1f0 z1 (* 0.5f0 (+ x x1)) 1.12f0 (* 0.5f0 (+ z z1)) 0.07f0 :lens 0.05f0 71f0 +pal-soul+ k :push 0.2f0)
      (fx-crescent x 1.1f0 z x1 1.1f0 z1 (* 0.5f0 (+ x x1)) 1.12f0 (* 0.5f0 (+ z z1)) 0.025f0 :lens 0.03f0 72f0 +pal-hit+ k :push 0.24f0))))

(defun rukia-burst-look (hz rdt)
  "A burst of cold (NADARE's snow, REIDO's release, the entry to zero): a white ring out to SIZE m, SOUL-glass shards."
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (age (/ (hazard-age hz) 60.0))
         (k (max 0.02 (- 0.95 (/ (hazard-age hz) (max 1.0 (float (hazard-life hz))))))))
    (with-floats (x z r age k rdt)
      (%tring x 0f0 z (* r (f-min 1f0 (* 6f0 age))) 0.08f0 +pal-hit+ k 3f0 24)
      (%tring x 0f0 z (* 0.7f0 r (f-min 1f0 (* 6f0 age))) 0.06f0 +pal-soul+ k 4f0 24)
      (when (< age 0.05f0)
        (dotimes (i (n-of 400f0 rdt))
          (let ((a (rnd-range 0f0 6.2832f0)) (sp (rnd-range 2f0 5f0)))
            (declare (single-float a sp))
            (%t-shard x (rnd-range 0.2f0 1.2f0) z (* sp (f-cos a)) (rnd-range 1f0 3f0) (* sp (f-sin a)) (rnd-range 0.4f0 0.8f0)
                      (rnd-range 0.06f0 0.12f0) 6f0 +pal-soul+)))))))

(defun rukia-flower-look (hz rdt)
  "HYOKA: the ice flower bursting at his feet: six SOUL-glass petals standing out of the plaza round a white core."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (age (hazard-age hz))
         (g (min 1.0 (/ age 5.0))) (k (max 0.02 (- 0.95 (* 0.025 (max 0 (- age 12)))))))
    (with-floats (x z r g k)
      (dotimes (i 6)
        (let* ((a (* 1.0472f0 (i->f i))) (c (f-cos a)) (s (f-sin a)))
          (declare (single-float a c s))
          (toon-ribbon ((+ x (* 0.15f0 r c)) 0f0 (+ z (* 0.15f0 r s))) ((* 0.8f0 r g c) (* 1.3f0 g) (* 0.8f0 r g s)) (0.16f0 0.01f0) :heat (1f0 0.3f0)
                       :seed (- -31f0 (i->f i)) :wob 0.1f0 :pal +pal-soul+ :k k :ph (i->f i) :segs 3)))
      (toon-ribbon (x 0f0 z) (0f0 (* 1.6f0 g) 0f0) (0.1f0 0.005f0) :heat (1f0 0.5f0) :seed -38f0 :wob 0.05f0 :pal +pal-hit+ :k k :segs 3)
      (%tring x 0f0 z r 0.06f0 +pal-soul+ k 7f0 24))))

(defun rukia-quake-look (hz rdt)
  "HYOSHIN: frost cracks radiating from her (the tell, while it waits), then the quake: a white ring out to SIZE m."
  (let ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)))
    (with-floats (x z r)
      (let ((grow (if (> (hazard-delay hz) 0) (f-min 1f0 (/ (i->f (- 15 (hazard-delay hz))) 14f0)) 1f0))
            (k (if (> (hazard-delay hz) 0) 0.9f0 (f-max 0.02f0 (- 0.95f0 (/ (i->f (hazard-age hz)) 30f0))))))
        (declare (single-float grow k))
        (dotimes (i 7)
          (let* ((a (+ (* 0.8976f0 (i->f i)) (hash01 (i->f i) 8.1f0))) (c (f-cos a)) (s (f-sin a)) (rr (* r grow (+ 0.7f0 (* 0.3f0 (hash01 (i->f i) 2.7f0))))))
            (declare (single-float a c s rr))
            (toon-ground-seg (+ x (* 0.3f0 c)) (+ z (* 0.3f0 s)) (+ x (* rr c)) (+ z (* rr s)) 0.02f0 0.04f0 1f0 0.3f0
                             (+ 80f0 (i->f i)) 0.2f0 (toon-a +pal-soul+ k))))
        (when (<= (hazard-delay hz) 0)
          (%tring x 0f0 z (* r (f-min 1f0 (/ (i->f (hazard-age hz)) 6f0))) 0.1f0 +pal-hit+ k 5f0 32)
          (when (< (hazard-age hz) 3)
            (dotimes (i (n-of 300f0 (f32 rdt)))
              (let ((a (rnd-range 0f0 6.2832f0)) (d (rnd-range 0.5f0 r)))
                (declare (single-float a d))
                (%t-shard (+ x (* d (f-cos a))) 0.1f0 (+ z (* d (f-sin a))) 0f0 (rnd-range 2f0 5f0) 0f0 (rnd-range 0.4f0 0.7f0)
                          (rnd-range 0.08f0 0.16f0) 9f0 +pal-soul+)))))))))

(defun rukia-pillar-look (hz rdt)
  "HAKKA f4: the white pillar of cold at her."
  (vfx-ru-pillar (hazard-x hz) (hazard-z hz) (hazard-size hz) 2.4 (/ (hazard-age hz) 60.0) rdt))

(defun rukia-sheet-look (hz rdt)
  "HAKKA f20: the cold running off the tip along the lane (SIZE m)."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (yaw (hazard-yaw hz)) (l (hazard-size hz)))
    (vfx-ru-sheet x z (+ x (* l (fwd-x yaw))) (+ z (* l (fwd-z yaw))) (/ (hazard-age hz) 60.0) (/ (hazard-life hz) 60.0))))

;;; the auras (DRAW-AURA's kinds are VFX-AURA's; a symbol that names a function draws with it: (fn x y z h k dt))
(defun rukia-field-ring (x y z field k)
  "The cold field 寒域 (the band's :field radius): a thin dim white ring on the plaza round her."
  (let ((r (getf field :r)))
    (with-floats (x y z r k)
      (%tring x (+ y 0.01f0) z r 0.05f0 +pal-hit+ (* 0.6f0 k) 6f0 48))))

(defun rukia-aura-cold (x y z h k dt)
  "-18 C: frost motes at her feet, a white breath puff every 40 f, the field's ring."
  (rukia-field-ring x y z *ru-field-m18* k)
  (with-floats (x y z h k dt)
    (dotimes (i (n-of (* 5f0 k) dt))
      (%t-blob (+ x (rnd-range -0.35f0 0.35f0)) (+ y 0.05f0) (+ z (rnd-range -0.35f0 0.35f0)) 0f0 (rnd-range 0.2f0 0.5f0) 0f0
               (rnd-range 0.6f0 1f0) (rnd-range 0.015f0 0.03f0) 0f0 0.1f0 +pal-hit+))
    (when (< (f-mod (fx-clock) 0.667f0) dt)
      (vfx-ru-breath x (+ y (* 0.92f0 h)) z 0f0))))

(defun rukia-aura-frost (x y z h k dt)
  "-50 C: the plaza whitening in a 1 m disc under her, low white mist, rising motes, the field's ring."
  (rukia-field-ring x y z *ru-field-m50* k)
  (with-floats (x y z h k dt)
    (vfx-ru-lake x z 1.0f0 (+ y 0.01f0) (* 0.8f0 k))
    (dotimes (i (n-of (* 10f0 k) dt))
      (%t-blob (+ x (rnd-range -0.5f0 0.5f0)) (+ y 0.05f0) (+ z (rnd-range -0.5f0 0.5f0)) (rnd-range -0.2f0 0.2f0) (rnd-range 0.1f0 0.3f0)
               (rnd-range -0.2f0 0.2f0) (rnd-range 0.8f0 1.3f0) (rnd-range 0.06f0 0.1f0) -0.05f0 0.2f0 +pal-hit+))
    (dotimes (i (n-of (* 6f0 k) dt))
      (%t-blob (+ x (rnd-range -0.4f0 0.4f0)) (+ y (* h (rnd-range 0.1f0 0.8f0))) (+ z (rnd-range -0.4f0 0.4f0)) 0f0
               (rnd-range 0.5f0 1f0) 0f0 (rnd-range 0.5f0 0.8f0) (rnd-range 0.015f0 0.03f0) 0f0 0.1f0 +pal-hit+))))

(defun rukia-aura-zero (x y z h k dt)
  "Absolute zero: a thin white ring at her feet and still motes (no breath), the field's ring (5.5 m: REIDO's reach)."
  (declare (ignore h))
  (rukia-field-ring x y z *ru-field-zero* k)
  (with-floats (x y z k dt)
    (%tring x y z 0.85f0 0.03f0 +pal-hit+ (* 0.95f0 k) 2f0 32)
    (vfx-ru-lake x z 1.4f0 (+ y 0.01f0) (* 0.6f0 k))
    (dotimes (i (n-of (* 3f0 k) dt))
      (%t-blob (+ x (rnd-range -0.6f0 0.6f0)) (+ y (rnd-range 0.2f0 1.4f0)) (+ z (rnd-range -0.6f0 0.6f0)) 0f0 0.02f0 0f0
               (rnd-range 1f0 1.5f0) (rnd-range 0.015f0 0.025f0) 0f0 0.05f0 +pal-hit+))))

;;; ---------------------------------------------------------------- the Shikai's 霜の層 and new moves (DUEL_RUKIA_TYBW §4.4,
;;; 2026-10-24; minimal looks until the motion / look pass: the crust by layers, the burst shards (RUKIA-BURST-LOOK), the
;;; 霜陣 circle, BYAKURAI's beam, SOKATSUI's blue fire, RIKUJOKORO's six rods). Cosmetic: RND01, the fx clock; 0 B a frame.
(defun-fast vfx-ru-layers (x z h n dt)
  "霜の層 on a fighter's body (x z his feet, H his height, N 1-3 layers): an ice crust of SOUL-glass shards up the legs, to
the feet (1), the knees (2), the waist (3: brittle, a white breath now and then); a white ring at his feet."
  (with-floats (x z h n dt)
    (let* ((dr (drawing-no)) (top (* h (if (< n 1.5f0) 0.14f0 (if (< n 2.5f0) 0.34f0 0.56f0)))) (k (+ 0.5f0 (* 0.15f0 n))))
      (declare (single-float dr top k))
      (%tring x 0f0 z (+ 0.38f0 (* 0.04f0 n)) 0.05f0 +pal-soul+ k (i->f (mod (f->i dr) 5)) 16)
      (dotimes (i 9)
        (let* ((f (i->f i)) (a (+ (* 0.698f0 f) 0.2f0)) (u (hash01 f 4.7f0)) (y (+ 0.06f0 (* top u))))
          (declare (single-float f a u y))
          (when (< (* 3f0 f) (* 9f0 n))                    ; (more shards the more layers)
            (fx-shard (+ x (* 0.22f0 (f-cos a))) y (+ z (* 0.22f0 (f-sin a))) (* 0.35f0 (f-cos a)) 0.94f0 (* 0.35f0 (f-sin a))
                      (+ 0.14f0 (* 0.08f0 (hash01 (+ f dr) 2.9f0))) 0.04f0 0.1f0 (+ f 70f0) +pal-soul+ k))))
      (when (and (> n 2.5f0) (< (f-mod (fx-clock) 0.8f0) dt))   ; brittle: a white breath
        (vfx-ru-breath x (* 0.92f0 h) z 0f0))
      (dotimes (i (n-of (* 2f0 n) dt))
        (%t-blob (+ x (rnd-range -0.3f0 0.3f0)) (rnd-range 0.1f0 top) (+ z (rnd-range -0.3f0 0.3f0)) 0f0 (rnd-range 0.1f0 0.3f0) 0f0
                 (rnd-range 0.5f0 0.8f0) (rnd-range 0.015f0 0.03f0) 0f0 0.1f0 +pal-hit+)))
    nil))

(defun-fast vfx-ru-sojin (x z r left)
  "霜陣 SOJIN's frost circle (x z, radius R; LEFT frames of it to go): VFX-RU-LAKE's rings and cracks, fading over its
last second (inlined: 0 B)."
  (with-floats (x z r)
    (let* ((k (f-min 0.85f0 (/ (i->f left) 60f0))) (dr (drawing-no)) (sd (i->f (mod (f->i dr) 5))))
      (declare (single-float k dr sd))
      (%tring x 0.02f0 z r 0.08f0 +pal-hit+ k sd 32)
      (%tring x 0.02f0 z (* 0.72f0 r) 0.12f0 +pal-soul+ (* 0.8f0 k) (+ sd 1f0) 32)
      (dotimes (i 6)
        (let* ((a (+ (* 1.0472f0 (i->f i)) (hash01 (i->f i) 5.5f0))) (c (f-cos a)) (s (f-sin a)))
          (declare (single-float a c s))
          (toon-ground-seg (+ x (* 0.2f0 r c)) (+ z (* 0.2f0 r s)) (+ x (* 0.95f0 r c)) (+ z (* 0.95f0 r s)) 0.03f0
                           0.025f0 1f0 0.3f0 (+ 20f0 (i->f i)) 0.2f0 (toon-a +pal-ink+ (* 0.7f0 k))))))
    nil))

(defun rukia-sojin-look (hz rdt)
  "霜陣 SOJIN: the frost circle round where she burst him (SIZE m), fading out over its last second."
  (declare (ignore rdt))
  (vfx-ru-sojin (hazard-x hz) (hazard-z hz) (hazard-size hz) (- (hazard-life hz) (hazard-age hz))))

(defun-fast vfx-ru-beam (x z yaw l age)
  "破道の四 白雷 BYAKURAI: a straight white beam at chest height from 0.5 m to L m along YAW, a jagged second stroke; AGE
frames old (bright for 4, gone in 8 more)."
  (with-floats (x z yaw l)
    (let* ((k (if (< age 4) 0.95f0 (f-max 0.02f0 (- 0.95f0 (* 0.11f0 (i->f (- age 4)))))))
           (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (dr (drawing-no)) (j (* 0.06f0 (- (hash01 dr 1.3f0) 0.5f0)))
           (x0 (+ x (* 0.5f0 fx))) (z0 (+ z (* 0.5f0 fz))) (x1 (+ x (* l fx))) (z1 (+ z (* l fz))))
      (declare (single-float k fx fz dr j x0 z0 x1 z1))
      (fx-crescent x0 1.1f0 z0 x1 1.1f0 z1 (+ (* 0.5f0 (+ x0 x1)) (* j fz 4f0)) (+ 1.12f0 j) (- (* 0.5f0 (+ z0 z1)) (* j fx 4f0))
                   0.05f0 :lens 0.08f0 81f0 +pal-hit+ k :push 0.25f0)
      (fx-crescent x0 1.1f0 z0 x1 1.1f0 z1 (* 0.5f0 (+ x0 x1)) 1.1f0 (* 0.5f0 (+ z0 z1)) 0.11f0 :lens 0.05f0 82f0 +pal-soul+ (* 0.7f0 k) :push 0.2f0)
      (%light x1 1.1f0 z1 0.9f0 0.95f0 1f0 3f0 (* 1.4f0 k) 6))
    nil))

(defun rukia-beam-look (hz rdt)
  "BYAKURAI's beam (a look: SIZE m along its yaw), bright for 4 frames, then gone in 8."
  (declare (ignore rdt))
  (vfx-ru-beam (hazard-x hz) (hazard-z hz) (hazard-yaw hz) (hazard-size hz) (hazard-age hz)))

(defun-fast vfx-ru-fire (x z yaw l fage life)
  "破道の三十三 蒼火墜 SOKATSUI: blue fire rolling out of her palms over a 40 deg cone to L m (FAGE frames of LIFE): SOUL-glass
tongues over white cores, racing out in 0.12 s, fading over its life."
  (with-floats (x z yaw l)
    (let* ((age (/ (i->f fage) 60f0)) (k (f-max 0.02f0 (- 0.95f0 (/ (i->f fage) (i->f (max 1 life))))))
           (run (* l (f-clamp (/ age 0.12f0) 0.15f0 1f0))) (dr (drawing-no)))
      (declare (single-float age k run dr))
      (dotimes (i 7)
        (let* ((f (i->f i)) (a (+ yaw (* 0.1164f0 (- f 3f0)))) (u (* run (+ 0.35f0 (* 0.65f0 (hash01 (+ f dr) 5.1f0)))))
               (bx (- x (* u (f-sin a)))) (bz (- z (* u (f-cos a)))) (hh (+ 0.5f0 (* 0.5f0 (hash01 f 2.3f0)))))
          (declare (single-float f a u bx bz hh))
          (toon-ribbon (bx 0.6f0 bz) ((* -0.3f0 (f-sin a)) hh (* -0.3f0 (f-cos a))) (0.3f0 0.04f0) :heat (1f0 0.3f0) :seed (- -41f0 f)
                       :wob 0.25f0 :pal +pal-soul+ :k k :ph (+ f dr) :sway 0.08f0 :segs 4)
          (toon-ribbon (bx 0.7f0 bz) ((* -0.2f0 (f-sin a)) (* 0.6f0 hh) (* -0.2f0 (f-cos a))) (0.12f0 0.02f0) :heat (1f0 0.5f0)
                       :seed (- -51f0 f) :wob 0.15f0 :pal +pal-hit+ :k k :ph (+ f dr) :sway 0.05f0 :segs 3)))
      (%light (- x (* 0.5f0 run (f-sin yaw))) 1f0 (- z (* 0.5f0 run (f-cos yaw))) 0.6f0 0.75f0 1f0 4f0 (* 1.5f0 k) 6))
    nil))

(defun rukia-fire-look (hz rdt)
  "SOKATSUI's fire (a look: SIZE m along its yaw), fading over its life."
  (declare (ignore rdt))
  (vfx-ru-fire (hazard-x hz) (hazard-z hz) (hazard-yaw hz) (hazard-size hz) (hazard-age hz) (hazard-life hz)))

(defun-fast vfx-ru-rods (x z r delay fade)
  "縛道の六十一 六杖光牢 RIKUJOKORO at (x z), radius R: six marks of light on the plaza round him while the bind waits
(DELAY frames left: pulsing), then six rods of light driven in at his middle, full while he is bound and fading over 12 f
from the frame he is free (FADE frames since; < 0 while bound; the user 2026-10-24: the rods last until his stun ends)."
  (with-floats (x z r)
    (let* ((dr (drawing-no)) (shut (if (> delay 0) 0f0 1f0))
           (k (cond ((> delay 0) (if (evenp (floor delay 3)) 0.95f0 0.55f0))
                    ((< fade 0) 0.95f0)
                    (t (f-max 0.02f0 (- 0.95f0 (/ (i->f fade) 12f0)))))))
      (declare (single-float dr shut k))
      (dotimes (i 6)
        (let* ((a (* 1.0472f0 (i->f i))) (c (f-cos a)) (s (f-sin a)))
          (declare (single-float a c s))
          (if (< shut 0.5f0)
              (toon-ground-seg (+ x (* (+ r 0.25f0) c)) (+ z (* (+ r 0.25f0) s)) (+ x (* (- r 0.35f0) c)) (+ z (* (- r 0.35f0) s))
                               0.02f0 0.05f0 1f0 0.4f0 (+ 90f0 (i->f i)) 0.1f0 (toon-a +pal-hit+ k))
              (let ((ox (+ x (* 1.1f0 r c))) (oz (+ z (* 1.1f0 r s))))
                (declare (single-float ox oz))
                (toon-ribbon (ox 1.6f0 oz) ((* -0.9f0 r c) -0.55f0 (* -0.9f0 r s)) (0.06f0 0.03f0) :heat (1f0 0.6f0) :seed (- -61f0 (i->f i))
                             :wob 0.04f0 :pal +pal-hit+ :k k :ph (+ (i->f i) dr) :segs 3)))))
      (when (> shut 0.5f0) (%light x 1f0 z 1f0 0.95f0 0.8f0 3f0 (* 1.2f0 k) 6)))
    nil))

(defun rukia-rods-look (hz rdt)
  "RIKUJOKORO: the six marks at the cast point while the bind waits (pulsing as it nears), then the rods holding him
until his stun ends, drawn on him wherever he is (the user 2026-10-24: 「六丈光牢的特效要黏在對手身上」, §12.1; a bind that
missed shuts on its empty ring). DATA, a look's own note the sim never reads: the victim, the bind's frames, the age he was
seen free, :hit / :miss (his seal at the first shut frame: RUKIA-HIT set it)."
  (declare (ignore rdt))
  (let* ((dt (hazard-data hz)) (v (first dt)) (age (hazard-age hz)) (shut (<= (hazard-delay hz) 0)))
    (when (and shut (null (fourth dt)))
      (setf (fourth dt) (if (and v (entity-alive-p v) (plusp (fighter-seal (fighter v)))) :hit :miss)))
    (when (and shut (null (third dt))
               (or (eq (fourth dt) :miss) (>= age (second dt)) (not (entity-alive-p v)) (not (eq (fighter-state (fighter v)) :stun))))
      (setf (third dt) age))                            ; (free now: the rods fade from here)
    (let ((on (and shut (eq (fourth dt) :hit) (entity-alive-p v))))
      (vfx-ru-rods (if on (aref (pos-of v) 0) (hazard-x hz)) (if on (aref (pos-of v) 2) (hazard-z hz)) (hazard-size hz)
                   (hazard-delay hz) (if (third dt) (- age (third dt)) -1)))))

;;; ---------------------------------------------------------------- the model sheets (debug 85500-85999: stills, a look)
;; 85500+10l+s: P1 Rukia in look L (0 the Shikai, 1 -18, 2 -50, 3 -273, 4 the 白霞罸 costume: zero's form drawn in the
;; :rukia-bankai body), 8 m from an idle Kenpachi. Shots s 0-5 alone on a card (white behind the black looks, black behind the
;; white ones) held 4 s in a cinematic shot (*RU-LOOK-SHOTS*): 0 the front, 1 her left side (the badge), 2 the back, 3
;; three-quarters from her left front, 4 the face, 5 the blade held out to her right; 6 the J3 pirouette seen from behind
;; (the cloth in a turn, the clip played at its own speed); 7 the match (the behind camera) 4 m from him, standing; 8 the
;; match while she walks in toward him. 85900: the look's consing line (RUKIA-LOOK-CONS-CHECK). DUEL_GAMEPLAY "Debug commands".
(defpose :ru-look-weapon (:base :ru-stance)            ; the blade held out flat to her right, the ribbon hanging off the pommel
  (:arm-r :flex 0 :side 86 :twist 90) (:elbow-r :flex 4) (:hand-r :flex -90 :twist 0))
(defclip :ru-look-weapon (1.0 :loop t :base :ru-look-weapon) (0))
(defparameter *ru-look-shots*
  '((0 4.0 0.9 0.78 35 0.0) (90 4.0 0.9 0.78 35 0.0) (180 4.0 0.9 0.78 35 0.0) (35 4.0 0.9 0.78 35 0.0)
    (0 0.75 1.36 1.34 35 0.0) (0 2.2 1.1 1.1 40 1.0) (180 4.4 1.7 0.8 45 0.0))
  "85500+10l+s: (angle around her facing, distance, eye height, look height, lens, aim off to the shot's left).")
(defparameter *ru-look-weapon-tall* '(0 6.0 1.1 1.0 32 1.6)
  "Shot 5 on a tall screen: SHOT-ON halves the aim there, so farther and aimed further left (the blade in the frame).")
(defvar *ru-look-k* 0 "The model sheet's look (85500+10l).")
(defvar *ru-look-s* 0 "The model sheet's shot (85500+10l+s).")
(defun ru-look-clip (a)
  "The model sheet's clip for A: the blade held out (shot 5), the pirouette (6), else the form's stance (zero's in the costume)."
  (case *ru-look-s* (5 :ru-look-weapon) (6 :ru-spin) (t (if (= *ru-look-k* 4) :ru-zero (kit-stance (kit-of a))))))
(defcine ru-look-cine (a v :len 240 :hold 60)
  "The model sheet's held shot *RU-LOOK-S* (*RU-LOOK-SHOTS*) of A alone on a card, 4 s; then the match again."
  (at 0 (destructuring-bind (ang dist h look fov off)
            (if (and (= *ru-look-s* 5) (portrait-p)) *ru-look-weapon-tall* (nth *ru-look-s* *ru-look-shots*))
          (when (= *ru-look-k* 4) (setf (model-body (model a)) (find-body :rukia-bankai) (model-weapon (model a)) :ru-ice))
          (card (if (>= *ru-look-k* 3) :black :white) a) (cine-clip a (ru-look-clip a) :blend 0)
          (shot-on a ang dist h :look look :off off) (lens fov))))
(defun rukia-look-scene (c)
  "85500+10l+s: the model sheet (RU-LOOK-CINE, s < 7) or the match (7, 8) of P1 Rukia in look L."
  (let* ((k (min 4 (floor (- c 85500) 10))) (s (min 8 (mod (- c 85500) 10))))
    (setf *cine-hold* nil *ru-look-k* k *ru-look-s* s)
    (abort-cine)
    (ensure-battle :rukia :kenpachi)
    (when (brain *p2*) (setf (brain-off (brain *p2*)) t))
    (place *p1* *p2* (if (>= s 7) 4.0 8.0))
    (full-gauges! *p1*) (full-gauges! *p2*)
    (let ((g (gauges *p1*)) (cold (nth k '(0.0 30.0 120.0 200.0 200.0))))
      (when (plusp cold)                                ; (the band the cold asks for, as 67000+k)
        (setf (gauges-meter g) (f32 cold))
        (force-form *p1* (temp-band (gauges-meter g) :m18))))
    (when (and (= k 4) (>= s 7))
      (setf (model-body (model *p1*)) (find-body :rukia-bankai) (model-weapon (model *p1*)) :ru-ice))
    (when (< s 7) (start-cine 'ru-look-cine *p1* *p2*))))
(defun rukia-look-debug (c)
  (if (= c 85900) (rukia-look-cons-check) (rukia-look-scene c)))
(pushnew '(85500 85999 rukia-look-debug) *char-debug* :test #'equal)

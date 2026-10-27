;;;; ichigo-art.lisp — KUROSAKI ICHIGO (TYBW) as art data (docs/duel/DUEL_ICHIGO.md §2, §10, v2 "built"): his body (a
;;;; substitute Shinigami's black shihakusho, the sleeves ending just past the elbow, the orange spiky head, the
;;;; half-Hollow's flat white horn on the left; the KESSA parts tagged :kessa per the figures: the hair split black on his
;;;; left, the left half-face black, the second horn, the robe open on a dark red disc, blood coils, bare feet, torn hems;
;;;; the Shikai's own parts tagged :shikai), his weapons (the long cleaver :zangetsu-long, KESSA's white pointless slab
;;;; :tensa; the hiltless short blade is a body part in the left fist) and every :ic-* pose and clip. His looks, sounds and
;;;; cinematics (the Cero Getsuga, 千影, 漆黒の月牙天衝, the awakening) are ichigo-look.lisp's, loaded right after this file
;;;; (BLOOD in KESSA's coils and rims, docs/style/STYLE_STORM_DESIGN.md §A.2).
(in-package :duel)
(declaim (special *ic-pose-ang*))                     ; (ichigo.lisp's)

;;; ---------------------------------------------------------------- body
;; 1.80 m (scale 1.0), lean (width 0.96); the hurt cylinder r 0.38 / h 1.80. One black mass (the robe and the hakama),
;; white in the under-collar and the tabi; the orange head the only warm thing on the plaza (muted, S <= 0.45: not a
;; spot hue). An anime head x1.2 about the neck's top (~7.4 heads). Both forms: the sleeves end just past the elbow, a
;; flared cuff with a white lining, the forearms bare (v2 §1). KESSA (:kessa, v2 §5.9, the figures): the hair split black
;; on his left, the left half of the face black with a red eye, a second flat white horn, the robe open to the navel on a
;; dark red disc and black lines, a ragged white band at the waist, torn sleeve and hakama hems, dark maroon coils at the
;; neck, wrists and ankles, bare feet (the Shikai's tabi tagged :shikai)
(defbody :ichigo (:scale 1.0 :width 0.96 :hunch 0 :hurt-r 0.38 :hurt-h 1.8
                  :girth ((:chest 0.98 1.0 0.95) (:spine 0.92 1.0 0.92) (:head 1.2 1.2 1.2))
                  :palette ((:skin #xD8B8A0) (:black #x16161E) (:hair #xB8733E) (:hair-l #xD89A66) (:white #xECECE8)
                            (:pupil #x5A3A22) (:core #x1A1210) (:shine #xFFFFFF) (:eye #xF2F0EC) (:lid #x141016)
                            (:mouth #x7A3A3C) (:fold #x3A3A46) (:tabi #xE8E8E4) (:sole #x262833) (:brow #x6A3A1C)
                            (:horn #xE8E4D8) (:mark #xF0EEE8) (:chain #x24242C) (:blood #xD0101C) (:blade #x121216)
                            (:edge #xC8CCD4) (:wrap #x2A2A30) (:clench #x141016) (:hair-k #x1A1418) (:coil #x6E1418)
                            (:mask #x0E0C10) (:cloak #xF0EEE8) (:scale #x6E1A1C) (:scale-d #x461013) (:wrap-w #xD8D6CC))
                  :rim (#xFFD8B8 0.14))
  (:pelvis (:box 0.36 0.18 0.25 :c :black)
           (:box 0.37 0.04 0.26 :at (0 0.075 0) :c :black)                                       ; the black sash
           (:cyl 0.23 0.48 :top 0.17 :seg 8 :at (0 -0.22 0) :c :black)                          ; the hakama
           (:box 0.004 0.34 0.004 :at (0.06 -0.26 0.19) :rot (0 0 -4) :c :fold)                 ; a pleat
           ;; KESSA: the white under-kimono torn out under the black at the waist
           (:wedge 0.07 0.07 0.012 :at (0.1 0.035 0.13) :rot (0 180 0) :c :white :tag :kessa)
           (:wedge 0.05 0.09 0.012 :at (-0.02 0.03 0.132) :rot (0 180 8) :c :white :tag :kessa)
           (:wedge 0.06 0.06 0.012 :at (-0.12 0.04 0.12) :rot (0 180 -6) :c :white :tag :kessa)
           ;; the Shikai's TYBW dress (DUEL_ICHIGO_TYBW §3.1): the white cloak's tied band over the sash, its knot and two
           ;; ends at the front; the red-scaled plate at the right hip (outside the cloak)
           (:box 0.385 0.05 0.275 :at (0 0.07 0) :c :cloak :tag :shikai)
           (:sphere 0.036 :at (0.01 0.065 0.15) :seg 8 :c :cloak :tag :shikai)
           (:box 0.05 0.2 0.012 :at (0.03 -0.05 0.155) :rot (0 0 -9) :c :cloak :tag :shikai)
           (:box 0.045 0.15 0.012 :at (-0.02 -0.03 0.15) :rot (0 0 12) :c :cloak :tag :shikai)
           (:bevel 0.025 0.21 0.13 0.008 :at (0.262 -0.06 0.03) :rot (0 0 9) :c :white :tag :shikai)
           (:box 0.006 0.075 0.1 :at (0.272 -0.015 0.03) :rot (0 0 9) :c :scale :tag :shikai)
           (:box 0.006 0.075 0.1 :at (0.285 -0.1 0.03) :rot (0 0 9) :c :scale :tag :shikai)
           (:box 0.007 0.006 0.1 :at (0.273 -0.01 0.03) :rot (0 0 9) :c :scale-d :tag :shikai)
           (:box 0.007 0.006 0.1 :at (0.286 -0.095 0.03) :rot (0 0 9) :c :scale-d :tag :shikai))
  ;; the Shikai's white waist cloak (canon-looks §2: tied round the waist, open at the front, hanging to the knees on both
  ;; sides and behind, the hem torn, black slash marks): 12 thin facets round the sash from 46 deg off the front (+x his
  ;; right), flared 9 deg, their lengths ragged, a torn tooth under each, 6 slashes. It hangs on the pelvis, which ICHIGO-CLOAK-POSE
  ;; swings about the obi (the cloak's spring: the hakama goes along, like cloth)
  #.(flet ((f (v) (float (/ (round (* v 1000)) 1000) 1f0)))
      (cons :pelvis
            (loop for a in '(46 72 98 124 150 174 -46 -72 -98 -124 -150 -174)
                  for bot in '(-0.44 -0.53 -0.49 -0.56 -0.5 -0.54 -0.48 -0.55 -0.47 -0.53 -0.49 -0.52)
                  for tooth in '(0.07 0.1 0.08 0.11 0.09 0.08 0.09 0.08 0.11 0.07 0.1 0.09)
                  for slash in '(nil 35 nil -30 nil 25 nil -35 nil 30 nil nil)
                  for r = (* a (/ pi 180)) for len = (- 0.06 bot) for yc = (/ (+ 0.06 bot) 2)
                  for rx = (+ 0.205 (* 0.16 (/ len 2))) for rz = (+ 0.16 (* 0.16 (/ len 2)))
                  for x = (* rx (sin r)) for z = (* rz (cos r))
                  for n = (atan (/ (sin r) rx) (/ (cos r) rz)) for nd = (* n (/ 180 pi))
                  for bx = (+ x (* 0.045 (sin n))) for bz = (+ z (* 0.045 (cos n)))   ; the hem's (flared) point
                  append `((:box 0.125 ,(f len) 0.012 :at (,(f x) ,(f yc) ,(f z)) :rot (,(f (- nd)) 9 0) :c :cloak :tag :shikai)
                           (:wedge 0.012 ,(f tooth) 0.07 :at (,(f bx) ,(f (- bot (/ tooth 2) -0.01)) ,(f bz))
                                   :rot (,(f (- 90 nd)) 0 180) :c :cloak :tag :shikai)
                           ,@(when slash
                               `((:box 0.026 0.17 0.004 :at (,(f (+ x (* 0.012 (sin n)))) ,(f (+ yc -0.06)) ,(f (+ z (* 0.012 (cos n)))))
                                       :rot (,(f (- nd)) 9 ,slash) :c :black :tag :shikai)))))))
  (:spine (:bevel 0.36 0.25 0.24 0.04 :at (0 0.11 0) :c :black)
          ;; KESSA: the robe open to the navel: the abdomen, the black lines down it
          (:box 0.08 0.2 0.004 :at (0 0.12 0.121) :c :skin :tag :kessa)
          (:box 0.007 0.18 0.003 :at (0 0.12 0.1235) :c :black :tag :kessa)
          (:box 0.005 0.06 0.003 :at (0.018 0.16 0.1235) :rot (0 0 -40) :c :black :tag :kessa)
          (:box 0.005 0.06 0.003 :at (-0.018 0.16 0.1235) :rot (0 0 40) :c :black :tag :kessa)
          (:box 0.005 0.05 0.003 :at (0.016 0.08 0.1235) :rot (0 0 -30) :c :black :tag :kessa)
          (:box 0.005 0.05 0.003 :at (-0.016 0.08 0.1235) :rot (0 0 30) :c :black :tag :kessa))
  (:chest (:bevel 0.44 0.3 0.27 0.05 :at (0 0.11 0) :c :black)
          (:box 0.17 0.07 0.04 :at (0 0.27 -0.05) :rot (0 -8 0) :c :black)                        ; the collar
          (:box 0.018 0.18 0.01 :at (0.034 0.185 0.14) :rot (0 0 -24) :c :white :tag :shikai)     ; the white under-collar V
          (:box 0.018 0.18 0.01 :at (-0.034 0.185 0.14) :rot (0 0 24) :c :white :tag :shikai)
          (:box 0.05 0.12 0.012 :at (0 0.19 0.138) :c :skin :tag :shikai)                         ; the chest in the V
          (:box 0.005 0.17 0.004 :at (0.08 0.07 0.142) :rot (0 0 -10) :c :fold)
          ;; the Shikai's white X: two flat 0.07 m bands from each shoulder to the other hip, crossing on the sternum
          ;; (front and back, and over the shoulders)
          (:box 0.07 0.5 0.012 :at (0 0.105 0.146) :rot (0 0 50) :c :white :tag :shikai)
          (:box 0.07 0.5 0.012 :at (0 0.105 0.146) :rot (0 0 -50) :c :white :tag :shikai)
          (:box 0.07 0.5 0.012 :at (0 0.105 -0.146) :rot (0 0 50) :c :white :tag :shikai)
          (:box 0.07 0.5 0.012 :at (0 0.105 -0.146) :rot (0 0 -50) :c :white :tag :shikai)
          (:box 0.075 0.012 0.3 :at (0.175 0.265 0) :rot (0 0 -12) :c :white :tag :shikai)
          (:box 0.075 0.012 0.3 :at (-0.175 0.265 0) :rot (0 0 12) :c :white :tag :shikai)
          ;; KESSA: the V open to the navel, the white edges wide; the dark red disc on the sternum, the lines from it
          (:box 0.02 0.3 0.01 :at (0.06 0.11 0.14) :rot (0 0 -8) :c :white :tag :kessa)
          (:box 0.02 0.3 0.01 :at (-0.06 0.11 0.14) :rot (0 0 8) :c :white :tag :kessa)
          (:box 0.1 0.3 0.006 :at (0 0.11 0.137) :c :skin :tag :kessa)
          (:cyl 0.034 0.006 :seg 12 :at (0 0.17 0.141) :rot (0 90 0) :c :coil :tag :kessa)
          (:box 0.007 0.14 0.003 :at (0 0.07 0.1415) :c :black :tag :kessa)
          (:box 0.005 0.07 0.003 :at (0.026 0.11 0.1415) :rot (0 0 -35) :c :black :tag :kessa)
          (:box 0.005 0.07 0.003 :at (-0.026 0.11 0.1415) :rot (0 0 35) :c :black :tag :kessa)
          ;; KESSA: the coiled blood mass at the neck (dark maroon, BLOOD glints)
          (:sphere 0.03 :at (0.075 0.27 0.05) :c :coil :tag :kessa) (:sphere 0.028 :at (-0.075 0.27 0.05) :c :coil :tag :kessa)
          (:sphere 0.026 :at (0.045 0.28 0.1) :c :coil :tag :kessa) (:sphere 0.026 :at (-0.045 0.28 0.1) :c :coil :tag :kessa)
          (:sphere 0.03 :at (0.09 0.28 -0.02) :c :coil :tag :kessa) (:sphere 0.03 :at (-0.09 0.28 -0.02) :c :coil :tag :kessa)
          (:sphere 0.028 :at (0 0.29 -0.07) :c :coil :tag :kessa)
          (:glow 1.5 (:box 0.012 0.008 0.014 :at (0.045 0.285 0.124) :c :blood) :kessa)
          (:glow 1.5 (:box 0.012 0.008 0.014 :at (-0.075 0.28 0.078) :c :blood) :kessa))
  (:neck (:cyl 0.04 0.17 :at (0 0.06 0) :c :skin))
  ;; the head: a long face, the scowl (the brows drawn down at the middle in every expression), brown eyes; the spiky
  ;; orange hair in cones standing up and back, the fringe falling over the brow; the half-Hollow's flat white horn on the
  ;; left (both forms), the right one KESSA's; KESSA's left half: the hair black, the face black, a red eye
  (:head (:sphere 0.066 :stretch 0.02 :at (0 0.14 -0.012) :seg 12 :c :skin)
         (:bevel 0.106 0.074 0.078 0.02 :at (0 0.126 0.022) :c :skin)
         (:bevel 0.052 0.076 0.068 0.014 :at (0.022 0.078 0.022) :rot (0 0 -20) :c :skin)
         (:bevel 0.052 0.076 0.068 0.014 :at (-0.022 0.078 0.022) :rot (0 0 20) :c :skin)
         (:wedge 0.012 0.022 0.013 :at (0 0.1 0.064) :rot (180 0 0) :c :skin)
         ;; :face-neutral: the scowl
         (:box 0.026 0.014 0.003 :at (0.027 0.119 0.0615) :c :eye :tag :face-neutral)
         (:box 0.026 0.014 0.003 :at (-0.027 0.119 0.0615) :c :eye :tag :face-neutral)
         (:box 0.012 0.014 0.003 :at (0.024 0.119 0.0622) :c :pupil :tag :face-neutral)
         (:box 0.012 0.014 0.003 :at (-0.024 0.119 0.0622) :c :pupil :tag :face-neutral)
         (:box 0.005 0.007 0.003 :at (0.024 0.119 0.0629) :c :core :tag :face-neutral)
         (:box 0.005 0.007 0.003 :at (-0.024 0.119 0.0629) :c :core :tag :face-neutral)
         (:box 0.03 0.0045 0.003 :at (0.027 0.127 0.0636) :rot (0 0 8) :c :lid :tag :face-neutral)
         (:box 0.03 0.0045 0.003 :at (-0.027 0.127 0.0636) :rot (0 0 -8) :c :lid :tag :face-neutral)
         (:box 0.032 0.006 0.003 :at (0.029 0.139 0.0625) :rot (0 0 14) :c :brow :tag :face-neutral)
         (:box 0.032 0.006 0.003 :at (-0.029 0.139 0.0625) :rot (0 0 -14) :c :brow :tag :face-neutral)
         (:box 0.022 0.003 0.003 :at (0 0.071 0.0585) :c :mouth :tag :face-neutral)
         ;; :face-shout
         (:box 0.026 0.012 0.003 :at (0.027 0.118 0.0615) :c :eye :tag :face-shout)
         (:box 0.026 0.012 0.003 :at (-0.027 0.118 0.0615) :c :eye :tag :face-shout)
         (:box 0.011 0.012 0.003 :at (0.023 0.118 0.0622) :c :pupil :tag :face-shout)
         (:box 0.011 0.012 0.003 :at (-0.023 0.118 0.0622) :c :pupil :tag :face-shout)
         (:box 0.034 0.007 0.003 :at (0.028 0.134 0.0625) :rot (0 0 22) :c :brow :tag :face-shout)
         (:box 0.034 0.007 0.003 :at (-0.028 0.134 0.0625) :rot (0 0 -22) :c :brow :tag :face-shout)
         (:box 0.03 0.02 0.003 :at (0 0.068 0.0585) :c :mouth :tag :face-shout)
         (:box 0.026 0.004 0.003 :at (0 0.0755 0.0592) :c :eye :tag :face-shout)
         ;; :face-hurt
         (:box 0.026 0.0045 0.003 :at (0.027 0.121 0.0625) :rot (0 0 14) :c :lid :tag :face-hurt)
         (:box 0.026 0.0045 0.003 :at (0.027 0.114 0.0625) :rot (0 0 -14) :c :lid :tag :face-hurt)
         (:box 0.026 0.0045 0.003 :at (-0.027 0.121 0.0625) :rot (0 0 -14) :c :lid :tag :face-hurt)
         (:box 0.026 0.0045 0.003 :at (-0.027 0.114 0.0625) :rot (0 0 14) :c :lid :tag :face-hurt)
         (:box 0.03 0.005 0.003 :at (0.028 0.138 0.0625) :rot (0 0 -16) :c :brow :tag :face-hurt)
         (:box 0.03 0.005 0.003 :at (-0.028 0.138 0.0625) :rot (0 0 16) :c :brow :tag :face-hurt)
         (:box 0.028 0.011 0.003 :at (0 0.069 0.0585) :c :mouth :tag :face-hurt)
         (:box 0.024 0.005 0.003 :at (0 0.069 0.0592) :c :eye :tag :face-hurt)
         (:box 0.024 0.0012 0.003 :at (0 0.069 0.0598) :c :clench :tag :face-hurt)
         ;; the hair: a cap, the back, and the spikes (the left side's orange ones :shikai, KESSA's black ones beside)
         (:sphere 0.074 :stretch 0.02 :at (0 0.152 -0.016) :seg 12 :c :hair)
         (:sphere 0.071 :stretch 0.02 :at (-0.013 0.153 -0.018) :seg 12 :c :hair-k :tag :kessa)   ; the cap's left half
         (:bevel 0.14 0.1 0.08 0.03 :at (0 0.11 -0.05) :c :hair)
         (:bevel 0.075 0.1 0.084 0.03 :at (-0.034 0.11 -0.052) :c :hair-k :tag :kessa)
         (:bevel 0.028 0.09 0.09 0.012 :at (0.064 0.12 -0.006) :rot (0 0 -6) :c :hair)
         (:bevel 0.028 0.09 0.09 0.012 :at (-0.064 0.12 -0.006) :rot (0 0 6) :c :hair :tag :shikai)
         (:bevel 0.028 0.09 0.09 0.012 :at (-0.064 0.12 -0.006) :rot (0 0 6) :c :hair-k :tag :kessa)
         (:cone 0.036 0.11 :at (0 0.21 -0.02) :rot (0 35 0) :seg 4 :c :hair)
         (:cone 0.034 0.1 :at (0.042 0.2 0.0) :rot (0 20 -38) :seg 4 :c :hair)
         (:cone 0.034 0.1 :at (-0.042 0.2 0.0) :rot (0 20 38) :seg 4 :c :hair :tag :shikai)
         (:cone 0.034 0.1 :at (-0.042 0.2 0.0) :rot (0 20 38) :seg 4 :c :hair-k :tag :kessa)
         (:cone 0.03 0.1 :at (0.062 0.165 -0.03) :rot (0 30 -70) :seg 4 :c :hair)
         (:cone 0.03 0.1 :at (-0.062 0.165 -0.03) :rot (0 30 70) :seg 4 :c :hair :tag :shikai)
         (:cone 0.03 0.1 :at (-0.062 0.165 -0.03) :rot (0 30 70) :seg 4 :c :hair-k :tag :kessa)
         (:cone 0.032 0.1 :at (0 0.17 -0.065) :rot (0 80 0) :seg 4 :c :hair)
         (:cone 0.028 0.09 :at (0.04 0.13 -0.072) :rot (0 100 -30) :seg 4 :c :hair)
         (:cone 0.028 0.09 :at (-0.04 0.13 -0.072) :rot (0 100 30) :seg 4 :c :hair :tag :shikai)
         (:cone 0.028 0.09 :at (-0.04 0.13 -0.072) :rot (0 100 30) :seg 4 :c :hair-k :tag :kessa)
         (:cone 0.024 0.08 :at (0.03 0.175 0.052) :rot (0 196 12) :seg 4 :c :hair)             ; the fringe
         (:cone 0.024 0.085 :at (-0.018 0.178 0.056) :rot (0 196 -8) :seg 4 :c :hair :tag :shikai)
         (:cone 0.024 0.085 :at (-0.018 0.178 0.056) :rot (0 196 -8) :seg 4 :c :hair-k :tag :kessa)
         (:cone 0.02 0.07 :at (0.004 0.168 0.062) :rot (0 190 2) :seg 4 :c :hair)
         (:box 0.006 0.04 0.003 :at (0.02 0.215 0.02) :rot (200 -30 0) :c :hair-l)             ; the lighter strokes
         (:box 0.006 0.034 0.003 :at (-0.03 0.2 0.04) :rot (200 30 0) :c :hair-l :tag :shikai)
         ;; the half-Hollow's horn: a flat white blade from the left temple, swept sideways and back (both forms);
         ;; KESSA's second on the right
         (:box 0.012 0.03 0.2 :at (-0.137 0.2 -0.064) :rot (-50 10 0) :c :horn)
         (:wedge 0.012 0.03 0.05 :at (-0.232 0.214 -0.145) :rot (-50 10 -90) :c :horn)
         (:box 0.012 0.03 0.2 :at (0.137 0.2 -0.064) :rot (50 10 0) :c :horn :tag :kessa)
         (:wedge 0.012 0.03 0.05 :at (0.232 0.214 -0.145) :rot (50 10 90) :c :horn :tag :kessa)
         ;; KESSA's left half-face: black from the brow to the jaw, the eye's pupil BLOOD
         (:box 0.052 0.1 0.001 :at (-0.027 0.108 0.0609) :c :mask :tag :kessa)
         (:box 0.008 0.01 0.003 :at (-0.024 0.119 0.0633) :c :blood :tag :kessa)
         ;; the manga's white half-Hollow marking (the awakening cinematic's first beat only)
         (:box 0.004 0.04 0.003 :at (-0.036 0.1 0.064) :rot (0 0 -12) :c :mark :tag :mark)
         (:box 0.004 0.03 0.003 :at (-0.046 0.13 0.058) :rot (0 0 20) :c :mark :tag :mark))
  (:shoulder-r (:bevel 0.12 0.06 0.18 0.02 :at (0.02 -0.02 0) :rot (0 0 -20) :c :black))
  (:shoulder-l (:bevel 0.12 0.06 0.18 0.02 :at (-0.02 -0.02 0) :rot (0 0 20) :c :black)
              ;; the Shikai's white pauldron: a shell over the shoulder, its first red-scale panel (the other two on the arm)
              (:bevel 0.17 0.035 0.23 0.012 :at (-0.035 0.025 0) :rot (0 0 22) :c :white :tag :shikai)
              (:box 0.1 0.006 0.13 :at (-0.042 0.045 0) :rot (0 0 22) :c :scale :tag :shikai)
              (:box 0.1 0.007 0.006 :at (-0.042 0.047 0.02) :rot (0 0 22) :c :scale-d :tag :shikai)
              (:box 0.1 0.007 0.006 :at (-0.042 0.047 -0.025) :rot (0 0 22) :c :scale-d :tag :shikai))
  (:upper-arm-r (:box 0.13 0.3 0.14 :at (0 -0.15 0) :c :black))
  (:upper-arm-l (:box 0.13 0.3 0.14 :at (0 -0.15 0) :c :black)
                ;; the pauldron's lower plate down the outside of the arm, two more red-scale panels
                (:bevel 0.022 0.17 0.16 0.006 :at (-0.075 -0.075 0) :c :white :tag :shikai)
                (:box 0.006 0.06 0.12 :at (-0.088 -0.04 0) :c :scale :tag :shikai)
                (:box 0.006 0.06 0.12 :at (-0.088 -0.11 0) :c :scale :tag :shikai)
                (:box 0.007 0.006 0.12 :at (-0.089 -0.035 0) :c :scale-d :tag :shikai)
                (:box 0.007 0.006 0.12 :at (-0.089 -0.105 0) :c :scale-d :tag :shikai))
  ;; the forearm: the sleeve's flared cuff just past the elbow, its white lining, then bare skin; KESSA's cuff torn
  ;; (three teeth, a gap in the lining) and the blood coils at the wrist
  (:lower-arm-r (:box 0.2 0.07 0.21 :at (0 -0.03 0) :rot (0 0 -8) :c :black)
                (:box 0.19 0.012 0.2 :at (0 -0.068 0) :c :white :tag :shikai)
                (:box 0.19 0.012 0.12 :at (0 -0.068 -0.04) :c :white :tag :kessa)
                (:wedge 0.05 0.06 0.012 :at (0.06 -0.09 0.1) :rot (0 180 0) :c :black :tag :kessa)
                (:wedge 0.04 0.05 0.012 :at (-0.07 -0.085 0.06) :rot (90 180 0) :c :black :tag :kessa)
                (:wedge 0.05 0.06 0.012 :at (0.02 -0.09 -0.1) :rot (180 180 0) :c :black :tag :kessa)
                (:box 0.07 0.17 0.07 :at (0 -0.15 0) :c :skin)
                (:box 0.055 0.08 0.055 :at (0 -0.23 0) :c :skin)
                (:box 0.072 0.04 0.072 :at (0 -0.205 0) :c :black :tag :shikai)                       ; the black wristband
                (:sphere 0.022 :at (0.03 -0.21 0.02) :c :coil :tag :kessa) (:sphere 0.022 :at (-0.03 -0.21 0.02) :c :coil :tag :kessa)
                (:sphere 0.022 :at (0.03 -0.22 -0.025) :c :coil :tag :kessa) (:sphere 0.022 :at (-0.03 -0.2 -0.025) :c :coil :tag :kessa)
                (:sphere 0.018 :at (0.0 -0.24 0.035) :c :coil :tag :kessa)
                (:glow 1.5 (:box 0.01 0.008 0.012 :at (0.03 -0.215 0.042) :c :blood) :kessa))
  (:lower-arm-l (:box 0.2 0.07 0.21 :at (0 -0.03 0) :rot (0 0 8) :c :black)
                (:box 0.19 0.012 0.2 :at (0 -0.068 0) :c :white :tag :shikai)
                (:box 0.19 0.012 0.12 :at (0 -0.068 0.04) :c :white :tag :kessa)
                (:wedge 0.05 0.06 0.012 :at (-0.06 -0.09 0.1) :rot (0 180 0) :c :black :tag :kessa)
                (:wedge 0.04 0.05 0.012 :at (0.07 -0.085 -0.06) :rot (90 180 0) :c :black :tag :kessa)
                (:wedge 0.05 0.06 0.012 :at (-0.02 -0.09 -0.1) :rot (180 180 0) :c :black :tag :kessa)
                (:box 0.07 0.17 0.07 :at (0 -0.15 0) :c :skin)
                (:box 0.055 0.08 0.055 :at (0 -0.23 0) :c :skin)
                (:box 0.072 0.04 0.072 :at (0 -0.205 0) :c :black :tag :shikai)
                (:sphere 0.022 :at (-0.03 -0.21 0.02) :c :coil :tag :kessa) (:sphere 0.022 :at (0.03 -0.21 0.02) :c :coil :tag :kessa)
                (:sphere 0.022 :at (-0.03 -0.22 -0.025) :c :coil :tag :kessa) (:sphere 0.022 :at (0.03 -0.2 -0.025) :c :coil :tag :kessa)
                (:sphere 0.018 :at (0.0 -0.24 0.035) :c :coil :tag :kessa)
                (:glow 1.5 (:box 0.01 0.008 0.012 :at (-0.03 -0.215 0.042) :c :blood) :kessa))
  (:hand-r (:bevel 0.06 0.08 0.06 0.016 :at (0 -0.04 0) :c :skin))
  (:hand-l (:bevel 0.06 0.08 0.06 0.016 :at (0 -0.04 0) :c :skin))
  ;; the Shikai's short blade in the left fist, a FORWARD grip (DUEL_ICHIGO_TYBW §3.1, the batches' contract): a straight
  ;; black slab 0.13 wide along the :weapon-l joint's -Y from y -0.05 to the point at y -0.90, z 0; the spine (a thick
  ;; ridge, so it never vanishes edge-on) in line with the fist at z 0, the slab out to the edge at the joint's +Z (the
  ;; :at fwd -0.13 side, a white line), its end clipped from the edge up to the point on the spine; the handle a closed
  ;; loop of the blade's frame round the fist, the bar through the fist wrapped white (canon's trench-knife frame, RoS)
  (:weapon-l (:box 0.034 0.75 0.13 :at (0 -0.425 -0.065) :c :blade :tag :shikai)                ; the slab, y -0.05 .. -0.8
             (:wedge 0.034 0.1 0.13 :at (0 -0.85 -0.065) :rot (0 0 180) :c :blade :tag :shikai)  ; the clipped end
             (:box 0.06 0.83 0.024 :at (0 -0.465 0) :c :blade :tag :shikai)                     ; the spine ridge
             (:box 0.04 0.75 0.014 :at (0 -0.425 -0.128) :c :edge :tag :shikai)                 ; the white edge
             (:box 0.04 0.164 0.014 :at (0 -0.85 -0.07) :rot (0 52.4 0) :c :edge :tag :shikai)  ; ... up the clip
             (:box 0.036 0.19 0.028 :at (0 0.03 0.05) :c :blade :tag :shikai)                   ; the loop round the fist
             (:box 0.036 0.19 0.028 :at (0 0.03 -0.1) :c :blade :tag :shikai)
             (:box 0.036 0.03 0.178 :at (0 0.125 -0.025) :c :blade :tag :shikai)
             (:box 0.03 0.17 0.03 :at (0 0.035 0) :c :wrap-w :tag :shikai)                      ; the wrapped bar
             (:box 0.034 0.012 0.034 :at (0 0.1 0) :rot (0 0 30) :c :wrap :tag :shikai)
             (:box 0.034 0.012 0.034 :at (0 -0.03 0) :rot (0 0 -30) :c :wrap :tag :shikai))
  (:thigh-r (:cyl 0.11 0.44 :top 0.1 :seg 10 :at (0 -0.21 0) :c :black))
  (:thigh-l (:cyl 0.11 0.44 :top 0.1 :seg 10 :at (0 -0.21 0) :c :black))
  ;; the shins: the Shikai's tabi; KESSA barefoot, the hakama's hem torn, the blood coils at the ankle
  (:shin-r (:cyl 0.13 0.3 :top 0.11 :seg 10 :at (0 -0.1 0) :c :black) (:cyl 0.13 0.08 :top 0.12 :seg 10 :at (0 -0.27 0) :c :black)
           (:box 0.075 0.12 0.085 :at (0 -0.37 0) :c :tabi :tag :shikai)
           (:box 0.07 0.12 0.075 :at (0 -0.37 0) :c :skin :tag :kessa)
           (:wedge 0.06 0.07 0.012 :at (0.05 -0.33 0.1) :rot (0 180 0) :c :black :tag :kessa)
           (:wedge 0.05 0.06 0.012 :at (-0.08 -0.33 0.02) :rot (90 180 0) :c :black :tag :kessa)
           (:wedge 0.06 0.07 0.012 :at (0.0 -0.33 -0.11) :rot (180 180 0) :c :black :tag :kessa)
           (:sphere 0.03 :at (0.04 -0.38 0.03) :c :coil :tag :kessa) (:sphere 0.03 :at (-0.04 -0.38 0.03) :c :coil :tag :kessa)
           (:sphere 0.028 :at (0.03 -0.385 -0.035) :c :coil :tag :kessa) (:sphere 0.028 :at (-0.035 -0.375 -0.03) :c :coil :tag :kessa)
           (:glow 1.5 (:box 0.012 0.008 0.014 :at (0.04 -0.375 0.058) :c :blood) :kessa))
  (:shin-l (:cyl 0.13 0.3 :top 0.11 :seg 10 :at (0 -0.1 0) :c :black) (:cyl 0.13 0.08 :top 0.12 :seg 10 :at (0 -0.27 0) :c :black)
           (:box 0.075 0.12 0.085 :at (0 -0.37 0) :c :tabi :tag :shikai)
           (:box 0.07 0.12 0.075 :at (0 -0.37 0) :c :skin :tag :kessa)
           (:wedge 0.06 0.07 0.012 :at (-0.05 -0.33 0.1) :rot (0 180 0) :c :black :tag :kessa)
           (:wedge 0.05 0.06 0.012 :at (0.08 -0.33 0.02) :rot (90 180 0) :c :black :tag :kessa)
           (:wedge 0.06 0.07 0.012 :at (0.0 -0.33 -0.11) :rot (180 180 0) :c :black :tag :kessa)
           (:sphere 0.03 :at (-0.04 -0.38 0.03) :c :coil :tag :kessa) (:sphere 0.03 :at (0.04 -0.38 0.03) :c :coil :tag :kessa)
           (:sphere 0.028 :at (-0.03 -0.385 -0.035) :c :coil :tag :kessa) (:sphere 0.028 :at (0.035 -0.375 -0.03) :c :coil :tag :kessa)
           (:glow 1.5 (:box 0.012 0.008 0.014 :at (-0.04 -0.375 0.058) :c :blood) :kessa))
  (:foot-r (:bevel 0.085 0.055 0.21 0.02 :at (0 -0.02 0.05) :c :tabi :tag :shikai) (:box 0.095 0.02 0.23 :at (0 -0.05 0.05) :c :sole :tag :shikai)
           (:bevel 0.08 0.045 0.2 0.02 :at (0 -0.035 0.05) :c :skin :tag :kessa))
  (:foot-l (:bevel 0.085 0.055 0.21 0.02 :at (0 -0.02 0.05) :c :tabi :tag :shikai) (:box 0.095 0.02 0.23 :at (0 -0.05 0.05) :c :sole :tag :shikai)
           (:bevel 0.08 0.045 0.2 0.02 :at (0 -0.035 0.05) :c :skin :tag :kessa)))

;;; ---------------------------------------------------------------- weapons
;; Zangetsu, the long blade (DUEL_ICHIGO_TYBW §3.1; canon-looks §1, RoS): ink black, 1.55 m from the fist to the point (the
;; reach unchanged), a khyber profile: the spine straight (z -0.06), the blade 0.18 m wide at the root widening to 0.26 m
;; at y 1.25, then the edge sweeping up into a curved point on the spine; a slender slit along the spine from the root to
;; mid-blade (y 0.08-0.72), a stepped spur on the spine side at the root, a thin white edge; the 0.28 m off-white wrapped
;; grip with its loose cloth end. SLAB builds a flat profile (stations (y z-spine z-edge), TH thick) span by span.
(defweapon :zangetsu-long (:length 1.55 :base 0.4)
  (:solid (flet ((slab (st th)
                   (let ((h (* 0.5 th)) (n (length st)))
                     (loop for (a b) on st while b for i from 1
                           do (destructuring-bind ((y0 p0 q0) (y1 p1 q1)) (list a b)
                                (flet ((v (x y z) (v3 (float x 1f0) (float y 1f0) (float z 1f0))))
                                  (let ((a0 (v (- h) y0 p0)) (a1 (v (- h) y0 q0)) (a2 (v (- h) y1 q1)) (a3 (v (- h) y1 p1))
                                        (b0 (v h y0 p0)) (b1 (v h y0 q0)) (b2 (v h y1 q1)) (b3 (v h y1 p1))
                                        (c (list 0 (* 0.5 (+ y0 y1)) (* 0.25 (+ p0 q0 p1 q1)))))
                                    (mb-poly-out mb (list a0 a1 a2 a3) :center c) (mb-poly-out mb (list b0 b1 b2 b3) :center c)
                                    (mb-poly-out mb (list a0 a3 b3 b0) :center c) (mb-poly-out mb (list a1 a2 b2 b1) :center c)
                                    (when (= i 1) (mb-poly-out mb (list a0 a1 b1 b0) :center c))
                                    (when (= i (1- n)) (mb-poly-out mb (list a3 a2 b2 b3) :center c)))))))))
            (mbc mb #x121216)
            (slab '((0.0 -0.06 0.12) (0.08 -0.06 0.124)) 0.03)                                 ; the root
            (slab '((0.08 -0.06 -0.035) (0.72 -0.06 -0.035)) 0.03)                             ; the spine beside the slit
            (slab '((0.08 -0.005 0.124) (0.4 -0.005 0.14) (0.72 -0.005 0.158)) 0.03)           ; ... and the blade
            (slab '((0.72 -0.06 0.158) (1.0 -0.06 0.18) (1.25 -0.06 0.2) (1.36 -0.06 0.19) (1.44 -0.06 0.15)
                    (1.5 -0.06 0.08) (1.535 -0.06 0.0) (1.55 -0.06 -0.052)) 0.03)              ; widening, the swept point
            (mb-at (mb :y 0.05 :z -0.08) (mb-box mb 0.03 0.1 0.04))                ; the stepped spur
            (mb-at (mb :y 0.025 :z -0.11) (mb-box mb 0.03 0.05 0.02))
            (mbc mb #xC8CCD4)                                                                   ; the white edge
            (slab '((0.0 0.104 0.122) (0.4 0.124 0.142) (0.72 0.142 0.16) (1.0 0.164 0.182) (1.25 0.184 0.202)
                    (1.36 0.174 0.192) (1.44 0.134 0.152) (1.5 0.064 0.082) (1.535 -0.016 0.002)) 0.034))
          (mbc mb #xD8D6CC)                                                                     ; the wrapped grip
          (mb-at (mb :y -0.14) (mb-box mb 0.045 0.28 0.045))
          (mbc mb #x2A2A30)
          (loop for i below 4 do (mb-at (mb :y (- -0.03 (* i 0.07)) :roll 0.785) (mb-box mb 0.032 0.032 0.052)))
          (mbc mb #xD8D6CC)
          (mb-at (mb :y -0.34 :z -0.02 :pitch 0.3) (mb-box mb 0.035 0.16 0.012))))  ; the loose cloth end

;; Tensa Zangetsu, KESSA's (v2 §5.8, the figures): a long straight white slab, no point and no guard: 0.025 thick x 0.17
;; wide x 1.55 long, a cold-grey hairline on the edge side, a jagged black line down the flat's middle (both faces, 5
;; segments zig-zagging), the end cut square with a 45-degree notch at the edge-side corner; a white hilt with a faint
;; diamond wrap straight into the blade
(defweapon :tensa (:length 1.62 :base 0.12)
  (:solid (mbc mb #xECECEA)
          (mb-at (mb :y 0.78) (mb-box mb 0.025 1.52 0.17))                          ; the slab, y 0.02-1.54
          (mb-at (mb :y 1.555 :z -0.025) (mb-box mb 0.025 0.03 0.12))                ; the square end, short
          (mb-at (mb :y 1.546 :z 0.05 :pitch 0.785) (mb-box mb 0.025 0.03 0.03))     ; ... the notch's chamfer
          (mbc mb #xB8BCC4)                                                                     ; the edge's hairline
          (mb-at (mb :y 0.78 :z 0.086) (mb-box mb 0.027 1.5 0.008))
          (mbc mb #x101014)                                                                     ; the jagged black line
          (loop for (y l z r) in '((0.24 0.22 0.004 0.12) (0.45 0.2 -0.012 -0.1) (0.66 0.24 0.01 0.14) (0.88 0.2 -0.008 -0.12)
                                   (1.07 0.18 0.006 0.1))
                for w in '(0.02 0.032 0.026 0.035 0.022)
                do (mb-at (mb :y y :z z :pitch r) (mb-box mb 0.029 l w)))
          (mbc mb #xE4E2DA)                                                                     ; the white hilt
          (mb-at (mb :y -0.11) (mb-box mb 0.04 0.22 0.04))
          (mbc mb #x8A8C94)
          (loop for i below 3 do (mb-at (mb :y (- -0.04 (* i 0.065)) :pitch 0.785) (mb-box mb 0.042 0.004 0.052)))))

;;; ---------------------------------------------------------------- poses (his rig notes)
;;; The right hand holds the long blade (the K links, L, the cross's right half), the left the short one (the J links);
;;; a horizontal cut is an arm held out (side ~88) swept by its flex (0 = to its own side, 90 = ahead, 130 = across);
;;; the cleaver runs on from the arm at hand flex ~ -86. The Shikai's short blade is held FORWARD (DUEL_ICHIGO_TYBW §3.1):
;;; it runs down the :weapon-l joint's -Y, so at hand flex 0 it carries on the forearm's line (its tip at y -0.90; the FK
;;; test's striker for the J's), hand flex + turns it toward the arm's sweep, twist spins its edge. Between strikes the
;;; cleaver rests on the right shoulder and the short blade aims at him (Musashi's "the long cuts, the short controls",
;;; §3.2); every hit pose was solved by numbers on the rig's FK (the tip at the volume's edge), not from strips.
;;; KESSA's one blade is in the right hand; the left throws the chains.
(defpose :ic-stance ()                                 ; Shikai: the cleaver on the right shoulder, the short blade aimed
  (:root :u -0.057) (:pelvis :twist -18) (:spine :flex 8) (:chest :twist -6) (:neck :twist 16) (:head :flex -4 :twist 6)  ; at
  (:arm-r :flex 37 :side 15 :twist 3) (:elbow-r :flex 144) (:hand-r :flex -22 :twist -29)                       ; his face
  (:arm-l :flex 17 :side 31 :twist -22) (:elbow-l :flex 80) (:hand-l :flex 10 :twist 0)                         ; at chest
  (:thigh-l :flex 30 :side 8) (:knee-l :flex 30) (:thigh-r :flex -14 :side 10) (:knee-r :flex 26))              ; height
(defclip :ic-stance (1.6 :loop t :base :ic-stance)     ; breathing: the chest and the cleaver's rest rise and settle
  (0) (0.8 (:root :u -0.072) (:chest :flex 3) (:elbow-r :flex 140) (:elbow-l :flex 84) (:hand-l :flex 6)))

(defpose :ic-k-stance ()                               ; KESSA: upright and still, Tensa hanging point-down across his
  (:root :u -0.03) (:pelvis :twist 14) (:spine :flex 4) (:chest :twist -4) (:neck :twist -8) (:head :flex 4 :twist -6)   ; legs,
  (:arm-r :flex -19 :side 25 :twist 23) (:elbow-r :flex 48) (:hand-r :twist 0 :flex -46)   ; its end just off the plaza (ep. 45
                                                                                         ; still; the tip 0.07 m up, 1.3 ahead)
  (:arm-l :flex 8 :side 20) (:elbow-l :flex 24) (:hand-l :flex -10)
  (:thigh-r :flex 8 :side 6) (:thigh-l :flex -4 :side 8) (:knee-r :flex 10) (:knee-l :flex 8))
(defclip :ic-k-stance (2.4 :loop t :base :ic-k-stance)
  (0) (1.2 (:root :u -0.04) (:head :flex 6) (:elbow-l :flex 28)))

;;; ---------------------------------------------------------------- the Shikai grid (DUEL_ICHIGO_TYBW §3.2)
;;; Plane and hand: J1 horizontal L, J2 rising L, J2s a thrust L, J3 a spin both, K1 horizontal R, K2 rising on his right
;;; R, K3 vertical down R; every K coils inside its startup (T1), carries past the target and settles (T4); the short blade
;;; aims while the cleaver winds up (T10)
;; J1 KOKIBA: the short blade swept level from his left to his right at chest height, a step in (the move's slide); at S
;; it points ahead, the tip on the volume's edge (1.40 m)
(defpose :ic-q1-hit (:base :ic-stance)
  (:root :f 0.12 :u -0.126 :yaw -6) (:pelvis :twist -10) (:spine :flex 10) (:chest :twist -12) (:neck :twist 14) (:head :twist 4)
  (:arm-l :flex -15 :side 69 :twist -14) (:elbow-l :flex 100) (:hand-l :flex 9 :twist 0)
  (:thigh-l :flex 46 :side 4) (:knee-l :flex 46) (:thigh-r :flex -24 :side 8) (:knee-r :flex 22))
(defstrike :ic-q1 (7 3 12 :base :ic-stance)
  (0)
  (3 (:root :u -0.1 :yaw 10) (:chest :twist 12) (:neck :twist 2) (:arm-l :flex -40 :side 75 :twist -14) (:elbow-l :flex 60)   ; drawn
     (:hand-l :flex -30) (:knees :flex 36))                                                                             ; to his left
  (:s :snap :ic-q1-hit)
  (9 (:root :yaw -14) (:chest :twist -24) (:arm-l :flex 20 :side 70) (:elbow-l :flex 108) (:hand-l :flex 30))   ; on, to his right
  (:a (:root :yaw -15) (:chest :twist -25))
  (16 (:root :f 0.05 :u -0.09 :yaw -4) (:chest :twist -8) (:arm-l :flex 14 :side 40 :twist -18) (:elbow-l :flex 90) (:hand-l :flex 10)
      (:thigh-l :flex 36) (:knee-l :flex 36))
  (:end :ic-stance))

;; J2 KAESHI: the wrist turned, a rising backhand from his low right up to his high left
(defpose :ic-q2-hit (:base :ic-stance)
  (:root :f 0.12 :u -0.095 :yaw 6) (:pelvis :twist 10) (:spine :flex 8) (:chest :twist 10) (:neck :twist -2) (:head :twist -6)
  (:arm-l :flex 33 :side -38 :twist 36) (:elbow-l :flex 49) (:hand-l :flex 29 :twist 0)
  (:thigh-l :flex 40 :side 4) (:knee-l :flex 40) (:thigh-r :flex -22 :side 8) (:knee-r :flex 22))
(defstrike :ic-q2 (7 3 13 :base :ic-stance)
  (0)
  (3 (:root :u -0.12 :yaw -8) (:chest :twist -16) (:neck :twist 24) (:arm-l :flex 20 :side -50 :twist 30) (:elbow-l :flex 30)   ; low,
     (:hand-l :flex -40) (:knees :flex 38))                                                                                   ; right
  (:s :snap :ic-q2-hit)
  (9 (:root :yaw 12 :u -0.07) (:chest :twist 18) (:arm-l :flex 90 :side -20) (:elbow-l :flex 30) (:hand-l :flex 40))   ; up, left
  (:a (:root :yaw 13) (:chest :twist 19))
  (17 (:root :f 0.05 :u -0.08 :yaw 4) (:chest :twist 0) (:arm-l :flex 40 :side 10 :twist 0) (:elbow-l :flex 70) (:hand-l :flex 14))
  (:end :ic-stance))

;; J3 SOSEN-GIRI: a full turn to his right with a key every 90 degrees, a pelvis roll into it; the cleaver swung off his
;; shoulder high (its tip on the 1.44 m edge at S), the short blade low
(defpose :ic-spin-hit (:base :ic-stance)
  (:root :yaw -360 :f 0.05 :u -0.026) (:pelvis :twist 10) (:spine :flex 4) (:chest :twist -6) (:neck :twist 6)
  (:arm-l :flex 14 :side 11 :twist -40) (:elbow-l :flex 49) (:hand-l :flex 0 :twist 0)
  (:arm-r :flex 84 :side -41 :twist 20) (:elbow-r :flex 84) (:hand-r :flex -110 :twist 4)
  (:thigh-l :flex 20 :side 8) (:knee-l :flex 24) (:thigh-r :flex 10 :side 14) (:knee-r :flex 30))
(defstrike :ic-spin (8 3 18 :base :ic-stance)
  (0)
  (2 (:root :u -0.12 :yaw 20) (:chest :twist 24) (:knees :flex 40) (:arm-l :flex 30 :side 50) (:elbow-l :flex 40))   ; wound
  (4 (:root :u -0.1 :yaw -80) (:pelvis :side 8) (:chest :twist 10) (:arm-r :flex 120 :side 30 :twist 0) (:elbow-r :flex 50)
     (:hand-r :flex -80 :twist 0) (:arm-l :flex 20 :side 40) (:elbow-l :flex 40) (:hand-l :flex 0))   ; off the shoulder
  (5 (:root :u -0.07 :yaw -170) (:pelvis :side 10) (:chest :twist 0))
  (6 (:root :u -0.05 :yaw -260) (:pelvis :side 8) (:chest :twist -4) (:arm-r :flex 100 :side -10) (:elbow-r :flex 70))
  (7 (:root :yaw -330) (:pelvis :side 4))
  (:s :snap :ic-spin-hit)
  (10 (:root :yaw -382 :u -0.05 :f 0.07) (:chest :twist -12) (:arm-r :side -42))
  (:a (:root :yaw -384) (:chest :twist -13))
  (20 (:root :yaw -370 :u -0.08 :f 0.04) (:chest :twist -6) (:arm-r :flex 60 :side 0 :twist 0) (:elbow-r :flex 110) (:hand-r :flex -50)
      (:arm-l :flex 20 :side 30) (:elbow-l :flex 60))
  (:end :ic-stance (:root :yaw -360)))

;; K1 OKIBA (canon Ep396): the cleaver off the shoulder and wound back to his right while the short blade aims (T10), the
;; coil held (T1), a waist-high sweep right to left with a deep step, the free hand flung back, carried past him (T4)
(defpose :ic-f1-hit (:base :ic-stance)
  (:root :f 0.52 :u -0.174 :yaw 8) (:pelvis :twist 8) (:spine :flex 14) (:chest :twist 20) (:neck :twist -18) (:head :twist -14)
  (:arm-r :flex 72 :side 24 :twist -26) (:elbow-r :flex 0) (:hand-r :flex -57 :twist 0)
  (:arm-l :flex -36 :side 71 :twist 41) (:elbow-l :flex 24) (:hand-l :flex -35 :twist 0)
  (:thigh-r :flex 62 :side 4) (:knee-r :flex 62) (:thigh-l :flex -32 :side 8) (:knee-l :flex 10))
(defstrike :ic-f1 (16 4 20 :base :ic-stance)
  (0)
  (5 (:root :u -0.1 :yaw -14) (:chest :twist -30) (:neck :twist 40) (:arm-r :flex -20 :side 80 :twist 0) (:elbow-r :flex 30)
     (:hand-r :flex -80 :twist 0))                                                       ; off the shoulder, back to his right
  (11 (:root :u -0.11 :yaw -20) (:chest :twist -36) (:neck :twist 44) (:arm-r :flex -34) (:knees :flex 40))   ; the coil
  (14 (:root :u -0.115 :yaw -22) (:arm-r :flex -38))                                                          ; held
  (:s :snap :ic-f1-hit)
  (18 (:root :yaw 16 :f 0.54) (:chest :twist 34) (:arm-r :flex 80 :side -10) (:hand-r :flex -40))   ; carried on, left
  (:a (:root :yaw 17) (:chest :twist 35))
  (30 (:root :f 0.25 :u -0.12 :yaw 6) (:chest :twist 10) (:neck :twist 0) (:arm-r :flex 50 :side 20 :twist -10) (:elbow-r :flex 30)
      (:hand-r :flex -50) (:arm-l :flex 0 :side 40 :twist 0) (:elbow-l :flex 60) (:hand-l :flex 0)
      (:thigh-r :flex 40) (:knee-r :flex 40))                                              ; the settle
  (35 (:root :f 0.1 :u -0.08 :yaw 2) (:arm-r :flex 40 :side 15 :twist 0) (:elbow-r :flex 120) (:hand-r :flex -30))   ; to the shoulder
  (:end :ic-stance))

;; K2 SHOGA (ch. 614): the cleaver's point dragged along the plaza behind him (its first 6 frames are skipped in a link,
;; :enter 6), a crouched coil, the rising cut on his right with the arm fully out: the hit ahead ~30 degrees up, a held
;; top, back over onto the shoulder
(defpose :ic-f2-drag (:base :ic-stance)
  (:root :f 0.05 :u -0.086) (:pelvis :twist 10) (:spine :flex 30) (:chest :twist -6) (:neck :twist 0) (:head :flex -16)
  (:arm-r :flex -61 :side 37 :twist 24) (:elbow-r :flex 50) (:hand-r :flex -86 :twist 17)
  (:thigh-r :flex 20 :side 10) (:knee-r :flex 50) (:thigh-l :flex 36 :side 8) (:knee-l :flex 50))
(defpose :ic-f2-hit (:base :ic-stance)
  (:root :f 0.6 :u -0.109) (:pelvis :twist 14) (:spine :flex -4) (:chest :twist 10) (:neck :twist -10) (:head :flex -14)
  (:arm-r :flex 103 :side -50 :twist 42) (:elbow-r :flex 15) (:hand-r :flex -85 :twist -15)
  (:arm-l :flex -79 :side 100 :twist 33) (:elbow-l :flex 76) (:hand-l :flex 40 :twist 0)
  (:thigh-r :flex 50 :side 4) (:knee-r :flex 44) (:thigh-l :flex -24 :side 8) (:knee-l :flex 10))
(defstrike :ic-f2 (20 4 24 :base :ic-stance)
  (0)
  (4 (:root :u -0.07) (:spine :flex 14) (:arm-r :flex 60 :side 50 :twist 0) (:elbow-r :flex 60) (:hand-r :flex -30 :twist 0))
  (6 (:root :u -0.08) (:spine :flex 22) (:arm-r :flex -20 :side 60) (:elbow-r :flex 20) (:hand-r :flex -86))   ; swung down
  (8 :ic-f2-drag)                                                                        ; the point on the plaza, behind
  (13 :ic-f2-drag (:root :f 0.2 :u -0.09))                            ; dragged
  (17 :ic-f2-drag (:root :f 0.3 :u -0.13) (:spine :flex 36) (:knees :flex 56))                   ; the coil
  (18 (:root :f 0.4) (:spine :flex 26) (:arm-r :flex -10 :side 65 :twist 0) (:elbow-r :flex 10) (:hand-r :flex -86 :twist 0))   ; swung out
  (19 (:root :f 0.5 :u -0.12) (:spine :flex 14) (:arm-r :flex 40 :side 55))                                  ; and up, on his right
  (:s :snap :ic-f2-hit)
  (22 (:root :u -0.06) (:arm-r :flex 130) (:hand-r :flex -80))                            ; up, the held top
  (:a (:root :u -0.06) (:arm-r :flex 132))
  (34 (:root :f 0.3 :u -0.1) (:spine :flex 4) (:arm-r :flex 120 :side 0 :twist 0) (:elbow-r :flex 70) (:hand-r :flex -40 :twist 0)
      (:arm-l :flex 0 :side 40 :twist 0) (:elbow-l :flex 60) (:hand-l :flex 10))
  (40 (:root :f 0.1 :u -0.07) (:arm-r :flex 50 :side 15) (:elbow-r :flex 135) (:hand-r :flex -25))   ; onto the shoulder
  (:end :ic-stance))

;; K3 RAKUGA (ch. 660, Ep409): one hand. The cleaver raised (frames 0-7 are skipped in play, :enter 7), a crouched coil
;; (T1), a hop, the vertical drop into the plaza at the volume's end (2.35 m), the short blade flung back, a landing
;; crouch. The fighter really slides 1.0 m over frames 8-20 (:slide 1.6, MAIN-PHASE-STEP's even speed): the clip's root
;; :f is the hop MINUS that slide (back while he coils, ahead as he flies), so the drawn body travels ~1.3 m with no
;; snap back; it ends on the idle at root 0
(defpose :ic-drop-hit (:base :ic-stance)
  (:root :f 0.3 :u -0.238) (:pelvis :twist 6) (:spine :flex 39) (:chest :twist 4) (:neck :twist -4) (:head :flex -24)
  (:arm-r :flex 74 :side -20 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -57 :twist 0)
  (:arm-l :flex -53 :side 46 :twist 5) (:elbow-l :flex 23) (:hand-l :flex -26 :twist 0)
  (:thigh-r :flex 70 :side 6) (:knee-r :flex 72) (:thigh-l :flex -20 :side 8) (:knee-l :flex 40))
(defstrike :ic-drop (21 5 34 :base :ic-stance)
  (0)
  (4 (:arm-r :flex 120 :side 20 :twist 0) (:elbow-r :flex 100) (:hand-r :flex -30 :twist 0))
  (7 (:root :u -0.04) (:spine :flex 0) (:arm-r :flex 165 :side 10) (:elbow-r :flex 40) (:hand-r :flex -40))   ; overhead
  (11 (:root :f -0.18 :u -0.15) (:spine :flex 14) (:arm-r :flex 175) (:elbow-r :flex 60) (:knees :flex 50) (:thighs :flex 20))  ; coil
  (15 (:root :f 0.09 :u 0.22) (:spine :flex -6) (:head :flex -16) (:arm-r :flex 185) (:elbow-r :flex 70) (:hand-r :flex -30)
      (:arm-l :flex -40 :side 50 :twist 0) (:elbow-l :flex 30) (:hand-l :flex -20)
      (:thigh-r :flex 60) (:knee-r :flex 90) (:thigh-l :flex 30) (:knee-l :flex 80))                     ; the hop's top
  (19 (:root :f 0.32 :u -0.12) (:spine :flex 20) (:arm-r :flex 140) (:elbow-r :flex 10) (:hand-r :flex -60)
      (:thigh-r :flex 64) (:knee-r :flex 66) (:thigh-l :flex -10) (:knee-l :flex 36))                     ; over the top
  (:s :snap :ic-drop-hit)
  (23 :ic-drop-hit (:root :u -0.25) (:spine :flex 41))
  (:a :ic-drop-hit (:root :u -0.245) (:spine :flex 40))
  (40 (:root :f 0.2 :u -0.15) (:spine :flex 22) (:head :flex -10) (:arm-r :flex 60) (:elbow-r :flex 20) (:hand-r :flex -40)
      (:arm-l :flex -10 :side 40) (:elbow-l :flex 50))                                    ; the settle
  (50 (:root :f 0.06 :u -0.08) (:spine :flex 10) (:arm-r :flex 40 :side 15 :twist 0) (:elbow-r :flex 130) (:hand-r :flex -25))
  (:end :ic-stance))

;; K2s KOGA (after J1; its own clip, played at x0.7 from :enter 6, the hit pose on clip frame 14): both blades crossed low
;; before him, a crouched coil, a rising X that opens upward (the cleaver's tip toward the 2.70 m edge), the arms flung up
(defpose :ic-cross-hit (:base :ic-stance)
  (:root :f 0.6 :u -0.142) (:pelvis :twist 0) (:spine :flex 4) (:chest :twist 0) (:neck :twist 0) (:head :flex -12)
  (:arm-r :flex 116 :side 31 :twist 38) (:elbow-r :flex 0) (:hand-r :flex -82 :twist 1)
  (:arm-l :flex 51 :side 66 :twist -15) (:elbow-l :flex 87) (:hand-l :flex -1 :twist 0)
  (:thigh-r :flex 52 :side 4) (:knee-r :flex 54) (:thigh-l :flex -26 :side 8) (:knee-l :flex 14))
(defstrike :ic-cross (14 3 17 :base :ic-stance)
  (0)
  (4 (:root :f 0.1 :u -0.07) (:spine :flex 20) (:chest :twist 0) (:arm-r :flex 35 :side -34 :twist -10) (:elbow-r :flex 24)   ; crossed
     (:hand-r :flex -110 :twist 38) (:arm-l :flex 41 :side -10 :twist 22) (:elbow-l :flex 35) (:hand-l :flex 4) (:knees :flex 44))  ; low
  (10 (:root :f 0.2 :u -0.12) (:spine :flex 26) (:knees :flex 54) (:arm-r :flex 40) (:arm-l :flex 46))   ; the coil
  (:s :snap :ic-cross-hit)
  (16 (:root :u -0.08) (:spine :flex -6) (:arm-r :flex 160 :side 50) (:arm-l :flex 160 :side 60) (:elbow-l :flex 30))   ; opened
  (:a (:root :u -0.08) (:arm-r :flex 162) (:arm-l :flex 162))                                                     ; upward
  (25 (:root :f 0.3 :u -0.1) (:spine :flex 4) (:arm-r :flex 110 :side 20 :twist 0) (:elbow-r :flex 70) (:hand-r :flex -40)
      (:arm-l :flex 40 :side 30 :twist 0) (:elbow-l :flex 70) (:hand-l :flex 10))
  (29 (:root :f 0.1 :u -0.07) (:arm-r :flex 50 :side 15) (:elbow-r :flex 135) (:hand-r :flex -25))
  (:end :ic-stance))

;; J2s KAESHI-KIBA (after K1; docs/duel/DUEL_STRINGS.md §13's close J): the cleaver still held out across from K1's
;; sweep, the short blade thrust under it (an X from behind), its tip on the 1.40 m edge
(defpose :ic-cross-j-hit (:base :ic-stance)
  (:root :f 0.15 :u -0.126) (:pelvis :twist -6) (:spine :flex 14) (:chest :twist -4) (:neck :twist 6)
  (:arm-l :flex 19 :side 21 :twist 5) (:elbow-l :flex 70) (:hand-l :flex 24 :twist 0)
  (:arm-r :flex 60 :side 61 :twist 6) (:elbow-r :flex 72) (:hand-r :flex -60 :twist 10)
  (:thigh-l :flex 46 :side 4) (:knee-l :flex 48) (:thigh-r :flex -24 :side 8) (:knee-r :flex 24))
(defstrike :ic-cross-j (7 3 13 :base :ic-stance)
  (0 :ic-cross-j-hit (:root :f 0.1 :u -0.1) (:arm-l :flex -20 :side 30 :twist 0) (:elbow-l :flex 110) (:hand-l :flex 0))   ; chambered
  (4 (:root :f 0.05 :u -0.15) (:chest :twist 8) (:arm-l :flex -30) (:elbow-l :flex 120) (:knees :flex 44))
  (:s :snap :ic-cross-j-hit)
  (:a (:root :f 0.17) (:arm-l :flex 21))
  (14 (:root :f 0.1 :u -0.1) (:arm-l :flex 10 :side 30) (:elbow-l :flex 80) (:arm-r :flex 50 :side 30) (:elbow-r :flex 110)
      (:hand-r :flex -40))
  (:end :ic-stance))

;;; ---------------------------------------------------------------- the stance 月待 TSUKIMACHI (v2 §2)
(defpose :ic-tsuki (:base :ic-stance)                  ; side-on (RoS 朔望): the short blade aimed level at his face, the
  (:root :u -0.094) (:pelvis :twist -40) (:spine :flex 8) (:chest :twist -24) (:neck :twist 40) (:head :flex -4 :twist 22)  ; cleaver
  (:arm-l :flex -16 :side 80 :twist -29) (:elbow-l :flex 83) (:hand-l :flex -29 :twist 0)                     ; cocked high
  (:arm-r :flex 129 :side 20 :twist -34) (:elbow-r :flex 71) (:hand-r :flex -56 :twist -36)                    ; behind the
  (:thigh-l :flex 34 :side 10) (:knee-l :flex 18) (:thigh-r :flex -22 :side 14) (:knee-r :flex 46))           ; shoulder
(defclip :ic-tsuki (1.2 :loop t :base :ic-tsuki)
  (0) (0.6 (:root :u -0.105) (:chest :flex 2) (:elbow-r :flex 76)))

;; RANGETSU: the lunge (the move's slide), four cuts alternating the blades on the hit frames 8 / 11 / 14 / 17: the short
;; blade down to his right, the cleaver's rising backhand (on the 2.40 m edge), the short blade level to his left, both
;; blades level together for the stagger (the cleaver on the edge); the short blade's cuts stay short (the crescent edge)
(defpose :ic-rangetsu-a (:base :ic-tsuki)              ; 1: the short blade down to his right, the cleaver swung low across
  (:root :f 0.4 :u -0.166) (:pelvis :twist -6) (:chest :twist -16) (:neck :twist 10) (:head :twist 6)
  (:arm-l :flex 3 :side -60 :twist 0) (:elbow-l :flex 109) (:hand-l :flex -19 :twist 0)
  (:arm-r :flex 22 :side 67 :twist -19) (:elbow-r :flex 121) (:hand-r :flex -33 :twist 46)
  (:thigh-l :flex 52) (:knee-l :flex 50) (:thigh-r :flex -30) (:knee-r :flex 20))
(defpose :ic-rangetsu-b (:base :ic-rangetsu-a)         ; 2: the cleaver's backhand up to his right
  (:root :f 0.42) (:pelvis :twist -20) (:chest :twist -20) (:neck :twist 20)
  (:arm-r :flex 21 :side -60 :twist 39) (:elbow-r :flex 47) (:hand-r :flex -67 :twist -5)
  (:arm-l :flex -30 :side 40 :twist 0) (:elbow-l :flex 90) (:hand-l :flex 0))
(defpose :ic-rangetsu-c (:base :ic-rangetsu-a)         ; 3: the short blade level to his left, the cleaver high
  (:root :f 0.44) (:pelvis :twist 0) (:chest :twist 10) (:neck :twist 0)
  (:arm-l :flex -7 :side -60 :twist 13) (:elbow-l :flex 102) (:hand-l :flex 4 :twist 0)
  (:arm-r :flex 150 :side 60 :twist 0) (:elbow-r :flex 40) (:hand-r :flex -60 :twist 0))
(defpose :ic-rangetsu-d (:base :ic-rangetsu-a)         ; 4: both blades level together, right to left
  (:root :f 0.46) (:pelvis :twist 10) (:chest :twist 20) (:neck :twist -10)
  (:arm-l :flex 15 :side -45 :twist -7) (:elbow-l :flex 86) (:hand-l :flex 12 :twist 0)
  (:arm-r :flex 13 :side 94 :twist 10) (:elbow-r :flex 91) (:hand-r :flex -106 :twist -19))
(defstrike :ic-rangetsu (8 12 18 :base :ic-tsuki)
  (0)
  (5 (:root :f 0.2 :u -0.15) (:pelvis :twist -50) (:chest :twist -30) (:arm-l :flex -30 :side 70) (:elbow-l :flex 110))   ; coiled
  (:s :snap :ic-rangetsu-a)
  (11 :snap :ic-rangetsu-b)
  (13 :ic-rangetsu-b (:arm-l :flex 60 :side -60 :twist 0) (:elbow-l :flex 40) (:hand-l :flex 40)   ; the short blade cocked right,
      (:arm-r :flex 120 :side 40 :twist 0) (:elbow-r :flex 40))                                    ; the cleaver going high
  (14 :snap :ic-rangetsu-c)
  (16 :ic-rangetsu-c (:arm-r :flex 40 :side 90) (:elbow-r :flex 60) (:hand-r :flex -90) (:chest :twist -10)   ; both cocked
      (:arm-l :flex 50 :side -60) (:elbow-l :flex 60))                                                       ; right
  (17 :snap :ic-rangetsu-d)
  (:a :ic-rangetsu-d (:root :yaw 12) (:chest :twist 34) (:arm-r :side 70) (:arm-l :side -30))   ; carried on, left
  (28 (:root :f 0.2 :u -0.1 :yaw 4) (:pelvis :twist -20) (:chest :twist 0) (:arm-r :flex 60 :side 20 :twist 0) (:elbow-r :flex 100)
      (:hand-r :flex -40 :twist 0) (:arm-l :flex 10 :side 30) (:elbow-l :flex 80) (:hand-l :flex 10))
  (:end :ic-stance))

;; TSUKI-OTOSHI: the pounce (the move's slide): a coil, a leap with both blades raised overhead, slammed down parallel
;; into the plaza ahead (the cleaver on the 2.60 m edge); both hands, vertical (K3 is the cleaver alone)
(defpose :ic-otoshi-up (:base :ic-tsuki)               ; leapt, both blades raised overhead ...
  (:root :u 0.25 :f 0.3) (:pelvis :twist 8) (:spine :flex -14) (:chest :twist 0) (:neck :twist 0) (:head :flex -24 :twist 0)
  (:arm-r :flex 175 :side 15 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -40 :twist 0)
  (:arm-l :flex 172 :side 15 :twist 0) (:elbow-l :flex 30) (:hand-l :flex 50 :twist 0)
  (:thigh-r :flex 60) (:knee-r :flex 90) (:thigh-l :flex 40) (:knee-l :flex 80))
(defpose :ic-otoshi-hit (:base :ic-stance)             ; ... slammed down together
  (:root :f 0.5 :u -0.238) (:pelvis :twist 6) (:spine :flex 40) (:chest :twist 0) (:neck :twist 0) (:head :flex -24)
  (:arm-r :flex 70 :side 12 :twist 0) (:elbow-r :flex 27) (:hand-r :flex -81 :twist -9)
  (:arm-l :flex 65 :side -5 :twist 10) (:elbow-l :flex 12) (:hand-l :flex 16 :twist 0)
  (:thigh-r :flex 70) (:knee-r :flex 70) (:thigh-l :flex -20) (:knee-l :flex 40))
(defstrike :ic-tsuki-otoshi (18 4 30 :base :ic-tsuki)
  (0)
  (5 (:root :u -0.19 :f 0.1) (:knees :flex 60) (:thighs :flex 40) (:arm-r :flex 110) (:elbow-r :flex 50) (:arm-l :flex 60))  ; coil
  (10 :ic-otoshi-up)
  (15 :ic-otoshi-up (:root :u 0.16 :f 0.42) (:arm-r :flex 180) (:arm-l :flex 178))
  (:s :snap :ic-otoshi-hit)
  (:a :ic-otoshi-hit (:root :u -0.25))
  (34 (:root :f 0.3 :u -0.17) (:spine :flex 24) (:arm-r :flex 60) (:elbow-r :flex 40) (:hand-r :flex -50) (:arm-l :flex 40)
      (:elbow-l :flex 40))
  (44 (:root :f 0.1 :u -0.08) (:spine :flex 10) (:arm-r :flex 40 :side 15 :twist 0) (:elbow-r :flex 130) (:hand-r :flex -25))
  (:end :ic-stance))

;;; ---------------------------------------------------------------- the rest of the Shikai (§3.2)
;; L GETSUGA TENSHO: from the shoulder the cleaver cocked high behind his right shoulder (the short blade aiming), the
;; tell held, a one-armed diagonal fling down to his left (the classic swing; the crescent leaves at S)
(defpose :ic-getsuga-hit (:base :ic-stance)
  (:root :f 0.3 :u -0.156 :yaw 8) (:pelvis :twist 4) (:spine :flex 4) (:chest :twist 24) (:neck :twist -20) (:head :flex -8 :twist -16)
  (:arm-r :flex -14 :side 120 :twist -8) (:elbow-r :flex 6) (:hand-r :flex -48 :twist -3)
  (:arm-l :flex 72 :side -57 :twist -50) (:elbow-l :flex 101) (:hand-l :flex 17 :twist 0)
  (:thigh-r :flex 50 :side 10) (:knee-r :flex 52) (:thigh-l :flex -30 :side 8) (:knee-l :flex 10))
(defstrike :ic-getsuga (14 0 24 :base :ic-stance)
  (0)
  (6 (:root :u -0.09 :yaw -16) (:spine :flex 14) (:chest :twist -30) (:neck :twist 40)
     (:arm-r :flex 129 :side 20 :twist -34) (:elbow-r :flex 71) (:hand-r :flex -56 :twist -36) (:knees :flex 40))   ; cocked
  (11 (:root :u -0.1 :yaw -18) (:chest :twist -36) (:arm-r :flex 140))                                          ; the tell
  (:s :snap :ic-getsuga-hit)
  (18 (:root :yaw 14) (:chest :twist 34) (:arm-r :flex 60 :side 30 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -60))   ; down,
  (28 (:root :f 0.2 :u -0.12 :yaw 4) (:chest :twist 10) (:arm-r :flex 50 :side 20) (:elbow-r :flex 60) (:hand-r :flex -40)   ; left
      (:arm-l :flex 10 :side 30 :twist 0) (:elbow-l :flex 70) (:hand-l :flex 10))
  (33 (:root :f 0.08 :u -0.08) (:arm-r :flex 40 :side 15) (:elbow-r :flex 130) (:hand-r :flex -25))
  (:end :ic-stance))

;;; ---------------------------------------------------------------- the core system's tells and stances (DUEL_CORE §9, 2026-10-27)
;;; The first strike of an NA string and of every NS is slow to start and starts with a held, exaggerated coil (the user:
;;; 「起手都要有足夠明顯的前搖讓人能看穿並抵消」); each SP pointer also rests in its own stance, so the NS to come reads from afar.
;; NA1: KOKIBA with a long coil, the short blade drawn far back to his left and held
(defstrike :ic-na1 (14 3 12 :base :ic-stance)
  (0)
  (5 (:root :u -0.11 :yaw 14) (:chest :twist 20) (:neck :twist 2) (:arm-l :flex -40 :side 78 :twist -14) (:elbow-l :flex 56)
     (:hand-l :flex -34) (:knees :flex 40))
  (11 (:root :u -0.13 :yaw 24) (:chest :twist 32) (:arm-l :flex -52 :side 86 :twist -14) (:elbow-l :flex 48) (:hand-l :flex -42)
      (:knees :flex 50))                                                                  ; the tell, held
  (:s :snap :ic-q1-hit)
  (16 (:root :yaw -14) (:chest :twist -24) (:arm-l :flex 20 :side 70) (:elbow-l :flex 108) (:hand-l :flex 30))
  (:a (:root :yaw -15) (:chest :twist -25))
  (23 (:root :f 0.05 :u -0.09 :yaw -4) (:chest :twist -8) (:arm-l :flex 14 :side 40 :twist -18) (:elbow-l :flex 90) (:hand-l :flex 10)
      (:thigh-l :flex 36) (:knee-l :flex 36))
  (:end :ic-stance))

;; NS1 (pointer 1, the heavy one): the cleaver lifted straight overhead and held there, the back arched; then K1's cut
(defstrike :ic-ns1 (22 4 20 :base :ic-stance)
  (0)
  (8 (:root :u -0.12) (:arm-r :flex 150 :side 20) (:elbow-r :flex 50) (:hand-r :flex -50) (:knees :flex 44) (:chest :twist -10))
  (16 (:root :u -0.1 :yaw -10) (:arm-r :flex 176 :side 14) (:elbow-r :flex 26) (:hand-r :flex -40) (:spine :flex -10)
      (:chest :twist -20) (:knees :flex 46))                                                  ; held overhead: the tell
  (:s :snap :ic-f1-hit)
  (24 (:root :yaw 16 :f 0.54) (:chest :twist 34) (:arm-r :flex 80 :side -10) (:hand-r :flex -40))
  (:a (:root :yaw 17) (:chest :twist 35))
  (36 (:root :f 0.25 :u -0.12 :yaw 6) (:chest :twist 10) (:neck :twist 0) (:arm-r :flex 50 :side 20 :twist -10) (:elbow-r :flex 30)
      (:hand-r :flex -50) (:arm-l :flex 0 :side 40 :twist 0) (:elbow-l :flex 60) (:hand-l :flex 0)
      (:thigh-r :flex 40) (:knee-r :flex 40))
  (41 (:root :f 0.1 :u -0.08 :yaw 2) (:arm-r :flex 40 :side 15 :twist 0) (:elbow-r :flex 120) (:hand-r :flex -30))
  (:end :ic-stance))

;; NS3 (pointer 3, RANGETSU): a deep crouch with both blades drawn back, held; then the lunge's four cuts (RANGETSU's poses)
(defstrike :ic-ns3 (18 12 18 :base :ic-tsuki)
  (0)
  (8 (:root :f 0.1 :u -0.2) (:pelvis :twist -50) (:chest :twist -30) (:arm-l :flex -30 :side 70) (:elbow-l :flex 110)
     (:thigh-l :flex 52) (:knee-l :flex 60) (:thigh-r :flex -20) (:knee-r :flex 50))
  (14 (:root :f 0.22 :u -0.26) (:pelvis :twist -56) (:chest :twist -36) (:arm-l :flex -40 :side 76) (:elbow-l :flex 112)
      (:thigh-l :flex 62) (:knee-l :flex 74))                                               ; the tell: low and coiled
  (:s :snap :ic-rangetsu-a)
  (21 :snap :ic-rangetsu-b)
  (23 :ic-rangetsu-b (:arm-l :flex 60 :side -60 :twist 0) (:elbow-l :flex 40) (:hand-l :flex 40)
      (:arm-r :flex 120 :side 40 :twist 0) (:elbow-r :flex 40))
  (24 :snap :ic-rangetsu-c)
  (26 :ic-rangetsu-c (:arm-r :flex 40 :side 90) (:elbow-r :flex 60) (:hand-r :flex -90) (:chest :twist -10)
      (:arm-l :flex 50 :side -60) (:elbow-l :flex 60))
  (27 :snap :ic-rangetsu-d)
  (:a :ic-rangetsu-d (:root :yaw 12) (:chest :twist 34) (:arm-r :side 70) (:arm-l :side -30))
  (38 (:root :f 0.2 :u -0.1 :yaw 4) (:pelvis :twist -20) (:chest :twist 0) (:arm-r :flex 60 :side 20 :twist 0) (:elbow-r :flex 100)
      (:hand-r :flex -40 :twist 0) (:arm-l :flex 10 :side 30) (:elbow-l :flex 80) (:hand-l :flex 10))
  (:end :ic-stance))

;; the three rests, one per SP pointer (kit :core :stances): 1 upright, the cleaver planted point-down in front, 2 side-on with the
;; cleaver cocked behind the shoulder (the old 月待 :ic-tsuki), 3 a low crouch leaning in, both blades trailing behind
(defpose :ic-st-heavy (:base :ic-stance)              ; square to him, upright, the cleaver planted point-down in front
  (:root :u -0.05) (:pelvis :twist 0) (:spine :flex 4) (:chest :twist 0) (:neck :twist 0) (:head :flex 4 :twist 0)
  (:arm-r :flex -10 :side 48 :twist 23) (:elbow-r :flex 40) (:hand-r :flex -46 :twist 0)
  (:arm-l :flex 8 :side 20 :twist 0) (:elbow-l :flex 24) (:hand-l :flex -10 :twist 0)
  (:thigh-l :flex 8 :side 12) (:knee-l :flex 12) (:thigh-r :flex 8 :side 12) (:knee-r :flex 12))
(defclip :ic-st-heavy (1.8 :loop t :base :ic-st-heavy)
  (0) (0.9 (:root :u -0.065) (:chest :flex 3) (:elbow-l :flex 28)))
(defpose :ic-st-rush (:base :ic-stance)
  (:root :f 0.18 :u -0.24 :yaw -8) (:pelvis :twist 12) (:spine :flex 30) (:chest :twist 10) (:neck :twist -4) (:head :flex -22 :twist -6)
  (:arm-r :flex -40 :side 40 :twist 0) (:elbow-r :flex 20) (:hand-r :flex -70 :twist 0)
  (:arm-l :flex -34 :side 30 :twist 0) (:elbow-l :flex 24) (:hand-l :flex 30 :twist 0)
  (:thigh-l :flex 62 :side 8) (:knee-l :flex 70) (:thigh-r :flex -26 :side 10) (:knee-r :flex 34))
(defclip :ic-st-rush (1.0 :loop t :base :ic-st-rush)
  (0) (0.5 (:root :u -0.26) (:spine :flex 34) (:head :flex -26)))


;; SP1 JUJISHO (ch. 583, Ep387 / Ep394): the blades crossed low before him, the arms flung wide; the short blade sweeps
;; level (the first crescent, f12) while the cleaver goes up overhead; the cleaver comes down at f20
(defpose :ic-juji-level (:base :ic-stance)
  (:root :f 0.15 :u -0.101) (:pelvis :twist -4) (:spine :flex 14) (:chest :twist -10) (:head :flex 0)
  (:arm-l :flex 20 :side 90 :twist -14) (:elbow-l :flex 45) (:hand-l :flex 30 :twist 0)
  (:arm-r :flex 177 :side -10 :twist 1) (:elbow-r :flex 36) (:hand-r :flex -51 :twist -19)
  (:thigh-l :flex 40) (:knee-l :flex 44) (:thigh-r :flex -20) (:knee-r :flex 30))
(defpose :ic-juji-down (:base :ic-stance)
  (:root :f 0.3 :u -0.133) (:pelvis :twist 4) (:spine :flex 22) (:chest :twist 6) (:head :flex -10)
  (:arm-l :flex -17 :side 51 :twist -41) (:elbow-l :flex 110) (:hand-l :flex -34 :twist 0)
  (:arm-r :flex 42 :side -22 :twist -1) (:elbow-r :flex 60) (:hand-r :flex -82 :twist 1)
  (:thigh-r :flex 50) (:knee-r :flex 52) (:thigh-l :flex -26) (:knee-l :flex 12))
(defstrike :ic-juji (20 0 26 :base :ic-stance)
  (0)
  (5 (:root :u -0.1) (:spine :flex 22) (:chest :twist 0) (:arm-r :flex 38 :side -34 :twist -10) (:elbow-r :flex 24)   ; crossed
     (:hand-r :flex -110 :twist 38) (:arm-l :flex 44 :side -10 :twist 22) (:elbow-l :flex 35) (:hand-l :flex 4) (:knees :flex 40))   ; low
  (7 (:arm-r :flex 30 :side 55 :twist 0) (:elbow-r :flex 10) (:hand-r :flex 0 :twist 0) (:arm-l :flex 60 :side 50 :twist 0) (:elbow-l :flex 10)
     (:hand-l :flex 0 :twist 0))
  (9 (:root :u -0.14) (:spine :flex 10) (:arm-r :flex 20 :side 90) (:elbow-r :flex 0) (:hand-r :flex -80)       ; flung wide
     (:arm-l :flex -10 :side 90) (:elbow-l :flex 10) (:hand-l :flex -20))
  (12 :snap :ic-juji-level)
  (16 :ic-juji-level (:arm-r :flex 185) (:elbow-r :flex 50) (:arm-l :flex 0))                    ; held overhead
  (18 :ic-juji-level (:root :u -0.12) (:arm-r :flex 188) (:arm-l :flex -10))
  (:s :snap :ic-juji-down)
  (26 :ic-juji-down (:arm-r :flex 30) (:hand-r :flex -70))
  (36 (:root :f 0.15 :u -0.1) (:spine :flex 10) (:arm-r :flex 40 :side 10) (:elbow-r :flex 70) (:hand-r :flex -40)
      (:arm-l :flex 10 :side 40 :twist 0) (:elbow-l :flex 70) (:hand-l :flex 10))
  (:end :ic-stance))

;; NS2's charges (the Getsuga gathering, a crescent glow on the blade: ICHIGO-CHARGE-LOOK): 1 the short blade drawn back low by his hip,
;; the edge up, held (the tell); 2 both blades raised as JUJISHO raises them, held
(defstrike :ic-chg1 (20 0 14 :base :ic-tsuki)
  (0)
  (7 (:root :u -0.12) (:chest :twist -14) (:arm-l :flex -40 :side 34 :twist -20) (:elbow-l :flex 64) (:hand-l :flex 34) (:knees :flex 44))
  (14 (:root :u -0.14) (:chest :twist -18) (:arm-l :flex -48 :side 30 :twist -20) (:elbow-l :flex 60) (:hand-l :flex 40) (:knees :flex 50))
  (:s (:root :u -0.14) (:chest :twist -18) (:arm-l :flex -48 :side 30 :twist -20) (:elbow-l :flex 60) (:hand-l :flex 40) (:knees :flex 50))
  (:end :ic-tsuki))
(defstrike :ic-chg2 (16 0 14 :base :ic-tsuki)
  (0)
  (6 :ic-juji-level)
  (12 :ic-juji-level (:arm-r :flex 185) (:elbow-r :flex 50) (:arm-l :flex 0))
  (:s :ic-juji-level (:root :u -0.12) (:arm-r :flex 188) (:arm-l :flex -10))
  (:end :ic-tsuki))


;; SP2 SOGA (Ep394): the flash-step lunge (the move's 5 m slide) flown near level, the cleaver high behind, the short
;; blade low ahead (T13); both blades raised and brought down in a descending X (the cleaver on the 2.60 m edge), the
;; arms ending flung open (T11)
(defpose :ic-soga-fly (:base :ic-stance)
  (:root :f 0.3 :u 0.12 :pitch 50) (:pelvis :twist 0) (:spine :flex 6) (:chest :twist 0) (:neck :twist 0) (:head :flex -40 :twist 0)
  (:arm-r :flex 200 :side -60 :twist -29) (:elbow-r :flex 89) (:hand-r :flex -94 :twist 10)
  (:arm-l :flex 124 :side 8 :twist -2) (:elbow-l :flex 1) (:hand-l :flex 9 :twist 0)
  (:thigh-r :flex -20 :side 6) (:knee-r :flex 40) (:thigh-l :flex -40 :side 6) (:knee-l :flex 20))
(defpose :ic-soga-hit (:base :ic-stance)
  (:root :f 0.45 :pitch 8 :u -0.192) (:pelvis :twist 0) (:spine :flex 22) (:chest :twist 0) (:neck :twist 0) (:head :flex -16 :twist 0)
  (:arm-r :flex 104 :side 27 :twist -33) (:elbow-r :flex 25) (:hand-r :flex -110 :twist 24)
  (:arm-l :flex 15 :side -8 :twist 35) (:elbow-l :flex 113) (:hand-l :flex -21 :twist 0)
  (:thigh-r :flex 64 :side 4) (:knee-r :flex 66) (:thigh-l :flex -30 :side 8) (:knee-l :flex 20))
(defstrike :ic-soga (18 4 26 :base :ic-stance)
  (0)
  (3 (:root :u -0.14) (:spine :flex 20) (:knees :flex 50) (:thighs :flex 20))           ; the launch
  (6 :ic-soga-fly)
  (13 :ic-soga-fly (:root :f 0.35 :pitch 46))
  (16 :ic-soga-fly (:root :f 0.4 :u -0.02 :pitch 20) (:arm-r :flex 175) (:arm-l :flex 160 :side 40) (:elbow-l :flex 20)   ; both
      (:thigh-r :flex 40) (:knee-r :flex 50) (:thigh-l :flex -10) (:knee-l :flex 30))                                 ; raised
  (:s :snap :ic-soga-hit)
  (20 :ic-soga-hit (:arm-r :flex 95 :side 10) (:arm-l :flex 10 :side -20))                   ; through, crossing
  (21 (:arm-r :flex 70 :side 50 :twist 0) (:hand-r :flex -70 :twist 0) (:arm-l :flex 60 :side 50 :twist 0) (:elbow-l :flex 30))
  (:a (:root :u -0.16 :pitch 0) (:spine :flex 10) (:arm-r :flex 30 :side 90 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -80 :twist 0)
      (:arm-l :flex 30 :side 90 :twist 0) (:elbow-l :flex 0) (:hand-l :flex 0))          ; flung open
  (34 (:root :f 0.3 :u -0.14) (:arm-r :flex 30 :side 80) (:arm-l :flex 30 :side 80))
  (42 (:root :f 0.1 :u -0.08) (:spine :flex 8) (:arm-r :flex 40 :side 15) (:elbow-r :flex 130) (:hand-r :flex -25)
      (:arm-l :flex 17 :side 31) (:elbow-l :flex 80) (:hand-l :flex 10))
  (:end :ic-stance))

;; O, the JUJI rush's strike (after the flash step, :sh-run): the blades crossed before him, pulled in, scissored open
;; outward level (the cleaver on the 2.60 m edge)
(defpose :ic-juji-x-hit (:base :ic-stance)
  (:root :f 0.3 :u -0.13) (:pelvis :twist 0) (:spine :flex 12) (:chest :twist 0) (:neck :twist 0) (:head :flex -6 :twist 0)
  (:arm-r :flex 113 :side -53 :twist -3) (:elbow-r :flex 1) (:hand-r :flex -89 :twist -4)
  (:arm-l :flex 83 :side -60 :twist -6) (:elbow-l :flex 66) (:hand-l :flex -25 :twist 0)
  (:thigh-r :flex 50 :side 6) (:knee-r :flex 52) (:thigh-l :flex -24 :side 10) (:knee-l :flex 14))
(defstrike :ic-juji-x (7 3 24 :base :ic-stance)
  (0 :ic-juji-x-hit (:root :f 0.1 :u -0.14) (:arm-r :flex 90 :side -30 :twist 0) (:elbow-r :flex 80) (:hand-r :flex -40)   ; crossed
     (:arm-l :flex 90 :side -30 :twist 0) (:elbow-l :flex 80) (:hand-l :flex 30))
  (4 (:root :u -0.18) (:spine :flex 18) (:elbow-r :flex 100) (:elbow-l :flex 100))     ; pulled in
  (:s :snap :ic-juji-x-hit)
  (9 (:arm-r :flex 60 :side 80) (:elbow-r :flex 0) (:hand-r :flex -86) (:arm-l :flex 50 :side 80) (:elbow-l :flex 10) (:hand-l :flex 0))
  (:a (:arm-r :flex 58) (:arm-l :flex 48))
  (22 (:root :f 0.15 :u -0.1) (:spine :flex 8) (:arm-r :flex 50 :side 30) (:elbow-r :flex 90) (:hand-r :flex -40)
      (:arm-l :flex 20 :side 40) (:elbow-l :flex 70) (:hand-l :flex 10))
  (:end :ic-stance))

(defclip :ic-breaker (0.4 :loop t :base :ic-stance)    ; the Breaker's dash: low, both blades trailing
  (0 (:root :u -0.12) (:pelvis :twist 8) (:spine :flex 36) (:chest :twist 0) (:neck :twist 0) (:head :flex -28 :twist 0)
     (:arm-r :flex -46 :side 30 :twist 0) (:elbow-r :flex 16) (:hand-r :flex -90 :twist 0)
     (:arm-l :flex -46 :side 30 :twist 0) (:elbow-l :flex 16) (:hand-l :flex 20 :twist 0)
     (:thigh-r :flex 45) (:knee-r :flex 20) (:thigh-l :flex -30) (:knee-l :flex 45))
  (0.2 (:root :u -0.08) (:thigh-l :flex 45) (:knee-l :flex 20) (:thigh-r :flex -30) (:knee-r :flex 45)))

;; I MINEUCHI (Monster Hunter's guard tackle, T7): the cleaver brought down before him on its flat, the left forearm braced
;; on its spine, pulled in, shoved forward like a shield (the Breaker's grab is close: short of its 1.35 m edge)
(defpose :ic-mine-hit (:base :ic-stance)
  (:root :f 0.35 :u -0.126) (:pelvis :twist 0) (:spine :flex 10) (:chest :twist 0) (:neck :twist 0) (:head :flex -6 :twist 0)
  (:arm-r :flex 72 :side 27 :twist 71) (:elbow-r :flex 31) (:hand-r :flex -110 :twist -114)
  (:arm-l :flex 104 :side 18 :twist -2) (:elbow-l :flex 54) (:hand-l :flex 70 :twist 0)
  (:thigh-r :flex 50 :side 10) (:knee-r :flex 50) (:thigh-l :flex -24 :side 8) (:knee-l :flex 14))
(defstrike :ic-mine (8 4 18 :base :ic-stance)
  (0)
  (4 :ic-mine-hit (:root :f 0.0 :u -0.12) (:chest :twist -10) (:arm-r :flex 50) (:elbow-r :flex 70) (:arm-l :flex 90) (:elbow-l :flex 80)
     (:thigh-r :flex 30) (:knee-r :flex 44) (:thigh-l :flex 0) (:knee-l :flex 30))     ; pulled in, on its flat
  (:s :snap :ic-mine-hit)
  (:a :ic-mine-hit (:root :f 0.38))
  (20 (:root :f 0.15 :u -0.1) (:arm-r :flex 50 :side 20 :twist 0) (:elbow-r :flex 90) (:hand-r :flex -40 :twist 0)
      (:arm-l :flex 30 :side 30) (:elbow-l :flex 70))
  (:end :ic-stance))

(defclip :ic-intro (2.0 :base :ic-stance)              ; both blades brought out from behind, crossed, then down
  (0 (:root :u -0.02) (:pelvis :twist 10) (:chest :twist 0) (:head :flex 10) (:arm-r :flex 160 :side 10) (:elbow-r :flex 120)
     (:hand-r :flex -20) (:arm-l :flex 160 :side 10) (:elbow-l :flex 120) (:hand-l :flex -20))
  (0.5 (:head :flex 0) (:arm-r :flex 150 :side 30) (:elbow-r :flex 60) (:arm-l :flex 150 :side 30) (:elbow-l :flex 60))
  (0.9 :snap (:root :u -0.1 :f 0.1) (:spine :flex 16) (:arm-r :side 30 :flex 80) (:elbow-r :flex 4) (:hand-r :twist -40 :flex -80)
       (:arm-l :side 30 :flex 80) (:elbow-l :flex 4) (:hand-l :twist -40 :flex -80) (:knees :flex 30))
  (1.4 (:root :u -0.1 :f 0.1))
  (2.0 :ic-stance))

(defclip :ic-win (2.0 :base :ic-stance)                ; the cleaver swung onto his shoulder, the short blade lowered
  (0)
  (0.4 :snap (:arm-r :side 30 :flex 150) (:elbow-r :flex 120) (:hand-r :flex -10) (:chest :twist 10))
  (0.9 (:root :u -0.01 :yaw -16) (:pelvis :twist 8) (:spine :flex 2) (:chest :twist 4) (:neck :twist 14) (:head :flex 4 :twist 18)
       (:arm-r :side 40 :flex 140) (:elbow-r :flex 130) (:hand-r :flex 0) (:arm-l :flex 6 :side 12) (:elbow-l :flex 10) (:hand-l :flex -80)
       (:thigh-r :flex 4) (:thigh-l :flex -4) (:knees :flex 4))
  (2.0 (:root :u -0.01 :yaw -16) (:head :flex 6 :twist 20)))

(defclip :ic-cero-raise (1.0 :base :ic-stance)         ; the Cero Kikon's raise: the cleaver overhead one-handed, the arm
  (0)                                                  ; straight, the blade 35 deg past vertical, up and forward
  (0.2 (:root :u -0.1) (:pelvis :twist 14) (:spine :flex -8) (:chest :twist 16) (:neck :twist -10) (:head :flex -22 :twist -8)
       (:arm-r :flex 158 :side 8) (:elbow-r :flex 2) (:hand-r :twist 0 :flex -64)
       (:arm-l :flex 24 :side 36) (:elbow-l :flex 30) (:hand-l :flex -40)
       (:thigh-r :flex -18 :side 10) (:knee-r :flex 30) (:thigh-l :flex 30 :side 8) (:knee-l :flex 28))
  (1.0 (:root :u -0.11) (:pelvis :twist 14) (:spine :flex -9) (:chest :twist 16) (:neck :twist -10) (:head :flex -24 :twist -8)
       (:arm-r :flex 160 :side 8) (:elbow-r :flex 2) (:hand-r :twist 0 :flex -64)
       (:arm-l :flex 24 :side 36) (:elbow-l :flex 30) (:hand-l :flex -40)
       (:thigh-r :flex -18 :side 10) (:knee-r :flex 30) (:thigh-l :flex 30 :side 8) (:knee-l :flex 28)))

(defclip :ic-awaken (2.8 :base :ic-stance)             ; the awakening: head down, the blades lowered, the short blade brought
  (0 (:root :u -0.02) (:spine :flex 16) (:head :flex 30) (:arm-r :flex 45 :side 14) (:elbow-r :flex 10) (:hand-r :flex -80)   ; into
     (:arm-l :flex 10 :side 14) (:elbow-l :flex 10) (:hand-l :flex -80) (:knees :flex 8))                                      ; the
  (0.9 (:head :flex 26) (:arm-r :flex 60 :side 0) (:elbow-r :flex 40) (:hand-r :twist -90 :flex -20)                            ; long
       (:arm-l :flex 60 :side -10) (:elbow-l :flex 50) (:hand-l :twist 90 :flex -60))                                           ; one's
  (1.1 :snap (:arm-l :flex 62 :side -18) (:elbow-l :flex 60))                                                                  ; hole
  (1.8 (:spine :flex -6) (:chest :flex -10) (:head :flex -20) (:arm-r :flex 20 :side 20) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -80)
       (:arm-l :flex 20 :side 60) (:elbow-l :flex 10) (:hand-l :flex 0))
  (2.8 (:spine :flex -8) (:head :flex -22) (:arm-l :side 64)))

;;; ---------------------------------------------------------------- KESSA's own motions (DUEL_ICHIGO_TYBW §3.2, right column)
;;; One slab, no point: cuts only. J one-handed, K two-handed (the left fist on the handle: *GRIP-CLIPS*), each strike its
;;; own plane and hand set (J1 diagonal-down, J2 diagonal-up, J3 a level spin, K1 horizontal, K2 diagonal-up two-handed,
;;; K3 vertical-down two-handed, 残月返し vertical-down one-handed after the grab, KAGE-UCHI diagonal-down ↙). Each clip at
;;; its move's own frames, starting and ending on :ic-k-stance; a K's anticipation coil inside its startup (after its
;;; :enter), overshoot and settle in the recovery. Hit poses solved from the drawn tip (the tip report, ±0.15 m of the
;;; volume's edge: J 1.56 / 1.68, K 2.90, K3's line ends 2.55 since its step, the counter 3.00, KAGE-UCHI 2.80); the long
;;; versions :ic-k-cut / :ic-k-wrap are the clones' light links (2.4 / 2.8 m)
;; J1 板薙 ITA-NAGI: cocked over the left shoulder, a one-hand chop ↘ down across him to his right, the slab steep at the
;; hit, a step in
(defpose :ic-k-jab-hit (:base :ic-k-stance)
  (:root :f -0.05 :u -0.12 :yaw -8) (:pelvis :twist 4) (:spine :flex 14) (:chest :twist -10) (:neck :twist 10) (:head :flex -6)
  (:arm-r :flex 137 :side 45 :twist -90) (:elbow-r :flex 14) (:hand-r :twist -90 :flex -153)
  (:arm-l :flex -16 :side 36) (:elbow-l :flex 34) (:hand-l :flex -20)
  (:thigh-r :flex 34 :side 4) (:knee-r :flex 38) (:thigh-l :flex -20) (:knee-l :flex 18))
(defstrike :ic-k-jab (8 3 12 :base :ic-k-stance)
  (0)
  (3 (:root :u -0.1 :yaw 14) (:pelvis :twist 24) (:spine :flex 2) (:chest :twist 30) (:neck :twist -18) (:knees :flex 22)
     (:arm-r :flex 158 :side 58 :twist -84) (:elbow-r :flex 30) (:hand-r :twist 7 :flex -126)            ; over the left shoulder
     (:arm-l :flex 24 :side 30) (:elbow-l :flex 40))
  (6 (:root :u -0.11) (:arm-r :flex 166 :side 10 :twist -81) (:elbow-r :flex 10) (:hand-r :twist -20 :flex -79))   ; up, left
  (:s :snap :ic-k-jab-hit)
  (:a (:chest :twist -18) (:arm-r :flex 125 :side 57) (:elbow-r :flex 7) (:hand-r :twist -81))                ; down-right
  (14 (:root :u -0.14) (:chest :twist -24) (:arm-r :flex 21 :side 9 :twist -22) (:elbow-r :flex 86) (:hand-r :twist -36 :flex -139))
  (18 (:root :f -0.03 :u -0.07 :yaw -3) (:spine :flex 6) (:chest :twist -8) (:thigh-r :flex 14) (:knee-r :flex 18)    ; settle
      (:arm-r :flex 0 :side 28 :twist 10) (:elbow-r :flex 50) (:hand-r :twist 0 :flex -55))
  (:end :ic-k-stance))
;; the clones' light 影薙 KAGE-NAGI: the same chop at arm's length, a lunge (2.4 m)
(defpose :ic-k-cut-hit (:base :ic-k-jab-hit)
  (:root :f 0.3 :u -0.14) (:spine :flex 16) (:arm-r :flex 114 :side 10 :twist -34) (:elbow-r :flex 10) (:hand-r :twist -39 :flex -126)
  (:thigh-r :flex 44) (:knee-r :flex 46) (:thigh-l :flex -26) (:knee-l :flex 14))
(defstrike :ic-k-cut (8 3 12 :base :ic-k-stance)
  (0)
  (3 (:root :u -0.1 :yaw 14) (:pelvis :twist 24) (:spine :flex 2) (:chest :twist 30) (:neck :twist -18) (:knees :flex 22)
     (:arm-r :flex 158 :side 58 :twist -84) (:elbow-r :flex 30) (:hand-r :twist 7 :flex -126) (:arm-l :flex 24 :side 30) (:elbow-l :flex 40))
  (6 (:root :u -0.11 :f 0.1) (:arm-r :flex 166 :side 10 :twist -81) (:elbow-r :flex 10) (:hand-r :twist -20 :flex -79))
  (:s :snap :ic-k-cut-hit)
  (:a (:chest :twist -18) (:arm-r :flex 63 :side 23 :twist -6) (:elbow-r :flex 37) (:hand-r :twist -20 :flex -136))
  (14 (:root :f 0.24 :u -0.15) (:chest :twist -24) (:arm-r :flex 21 :side 9 :twist -22) (:elbow-r :flex 86) (:hand-r :twist -36 :flex -139))
  (18 (:root :f 0.08 :u -0.08 :yaw -3) (:spine :flex 6) (:chest :twist -8) (:thigh-r :flex 14) (:knee-r :flex 18)
      (:arm-r :flex 0 :side 28 :twist 10) (:elbow-r :flex 50) (:hand-r :twist 0 :flex -55))
  (:end :ic-k-stance))

;; J2 返板 KAESHI-ITA: the slab dragged low across to his left, the flat turned, a one-hand rising backhand ↗, the slab's
;; weight carrying it high to his right
(defpose :ic-k-back-hit (:base :ic-k-stance)
  (:root :f 0.0 :u -0.1 :yaw 8) (:pelvis :twist 22) (:spine :flex 6) (:chest :twist -18) (:neck :twist 14)
  (:arm-r :flex 22 :side -9 :twist -1) (:elbow-r :flex 46) (:hand-r :twist -18 :flex -9)
  (:arm-l :flex 20 :side 40) (:elbow-l :flex 30) (:hand-l :flex -20)
  (:thigh-r :flex 30) (:knee-r :flex 34) (:thigh-l :flex -18) (:knee-l :flex 16))
(defstrike :ic-k-back (8 3 13 :base :ic-k-stance)
  (0)
  (3 (:root :u -0.12 :yaw -10) (:pelvis :twist 28) (:spine :flex 14) (:chest :twist 34) (:neck :twist -20) (:knees :flex 26)
     (:arm-r :flex 32 :side -9 :twist 67) (:elbow-r :flex 46) (:hand-r :twist 40 :flex -89))           ; low across, to his left
  (6 (:arm-r :flex 29 :side 6 :twist 44) (:elbow-r :flex 43) (:hand-r :twist 18 :flex -77))           ; the flat turned, rising
  (:s :snap :ic-k-back-hit)
  (:a (:root :u -0.06) (:chest :twist -26) (:arm-r :flex 22 :side 46 :twist -26) (:elbow-r :flex 97) (:hand-r :twist -45 :flex -85))
  (15 (:root :u -0.04) (:spine :flex 0) (:chest :twist -30) (:arm-r :flex 26 :side 85 :twist -66) (:elbow-r :flex 93)   ; high right
      (:hand-r :twist -36 :flex -116))
  (19 (:root :u -0.07) (:spine :flex 4) (:chest :twist -10) (:thigh-r :flex 14) (:knee-r :flex 18)                     ; settle
      (:arm-r :flex 0 :side 30 :twist 10) (:elbow-r :flex 52) (:hand-r :twist 0 :flex -55))
  (:end :ic-k-stance))

;; J3 板旋 ITA-SEN: wound right, a full turn to his left (a key every 90°, root yaw + the pelvis), the slab level and held
;; close, whipped across the front on S (the long version, the clones' light 3, at arm's length with a lunge)
(defpose :ic-k-wrap-j-hit (:base :ic-k-stance)
  (:root :yaw 360 :f -0.08 :u -0.06) (:pelvis :twist 10) (:chest :twist 12) (:neck :twist -6)
  (:arm-r :flex -3 :side 52 :twist -5) (:elbow-r :flex 82) (:hand-r :twist 15 :flex -57)
  (:arm-l :side 70 :flex 20) (:elbow-l :flex 10)
  (:thigh-r :flex 10 :side 14) (:knee-r :flex 30) (:thigh-l :flex 20) (:knee-l :flex 24))
(defpose :ic-k-wrap-hit (:base :ic-k-wrap-j-hit)
  (:root :f 0.55) (:spine :flex 10) (:arm-r :flex 83 :side -39 :twist -7) (:elbow-r :flex 1) (:hand-r :twist 12 :flex -83)
  (:thigh-r :flex 30) (:knee-r :flex 36) (:thigh-l :flex -14) (:knee-l :flex 24))
(defstrike :ic-k-wrap-j (9 3 18 :base :ic-k-stance)
  (0)
  (2 (:root :yaw -22 :u -0.09) (:pelvis :twist 0) (:chest :twist -28) (:neck :twist 16) (:knees :flex 26)    ; wound right
     (:arm-r :flex -10 :side 76 :twist 0) (:elbow-r :flex 12) (:hand-r :twist 0 :flex -86) (:arm-l :side 50 :flex 40) (:elbow-l :flex 30))
  (4 (:root :yaw 68 :u -0.1) (:pelvis :twist 6 :side 4) (:chest :twist -30))                              ; 90
  (6 (:root :yaw 158 :u -0.09) (:pelvis :side 6) (:chest :twist -24))                                    ; 180: his back
  (8 (:root :yaw 250 :u -0.08) (:pelvis :side 4) (:chest :twist -14) (:arm-r :flex 0 :side 80))           ; 270
  (:s :snap :ic-k-wrap-j-hit)
  (:a (:root :yaw 384) (:chest :twist 20) (:arm-r :flex 8) (:elbow-r :flex 90))
  (18 (:root :yaw 392 :u -0.08) (:chest :twist 26) (:arm-r :flex 20 :side 60) (:elbow-r :flex 96) (:hand-r :flex -60))
  (24 (:root :yaw 372 :u -0.05) (:chest :twist 6) (:arm-r :flex -10 :side 30 :twist 10) (:elbow-r :flex 50) (:hand-r :twist 0 :flex -50))
  (:end :ic-k-stance (:root :yaw 360)))
(defstrike :ic-k-wrap (9 3 18 :base :ic-k-stance)
  (0)
  (2 (:root :yaw -22 :u -0.09) (:pelvis :twist 0) (:chest :twist -28) (:neck :twist 16) (:knees :flex 26)
     (:arm-r :flex -10 :side 76 :twist 0) (:elbow-r :flex 12) (:hand-r :twist 0 :flex -86) (:arm-l :side 50 :flex 40) (:elbow-l :flex 30))
  (4 (:root :yaw 68 :u -0.1 :f 0.1) (:pelvis :twist 6 :side 4) (:chest :twist -30))
  (6 (:root :yaw 158 :u -0.09 :f 0.25) (:pelvis :side 6) (:chest :twist -24))
  (8 (:root :yaw 250 :u -0.08 :f 0.4) (:pelvis :side 4) (:chest :twist -14) (:arm-r :flex 0 :side 85))
  (:s :snap :ic-k-wrap-hit)
  (:a (:root :yaw 384) (:chest :twist 20) (:arm-r :flex 100 :side -30))
  (18 (:root :yaw 392 :u -0.08 :f 0.4) (:chest :twist 26) (:arm-r :flex 110 :side 0) (:elbow-r :flex 30) (:hand-r :flex -70))
  (24 (:root :yaw 372 :u -0.05 :f 0.15) (:chest :twist 6) (:arm-r :flex -10 :side 30 :twist 10) (:elbow-r :flex 50) (:hand-r :twist 0 :flex -50))
  (:end :ic-k-stance (:root :yaw 360)))

;; K1 大板 OITA: both hands, a full-body bat swing L -> R: the slab coiled behind the left shoulder (held: the tell), a
;; deep step with the right foot, the slab level through the front on S, carried past him to the right, settled low
(defpose :ic-k-f1-hit (:base :ic-k-stance)
  (:root :f 0.62 :u -0.2 :yaw -4) (:pelvis :twist 4) (:spine :flex 22) (:chest :twist 14) (:neck :twist -10)
  (:arm-r :flex 116 :side 58 :twist -82) (:elbow-r :flex 6) (:hand-r :twist -11 :flex -88)
  (:arm-l :flex 78 :side 45 :twist 23) (:elbow-l :flex 92) (:hand-l :flex -29)
  (:thigh-r :flex 58 :side 4) (:knee-r :flex 60) (:thigh-l :flex -30 :side 8) (:knee-l :flex 10))
(defstrike :ic-k-f1 (18 4 20 :base :ic-k-stance)
  (0)
  (6 (:root :u -0.1 :yaw 10) (:pelvis :twist 20) (:chest :twist 24) (:spine :flex 6) (:knees :flex 24)          ; gathered
     (:arm-r :flex 28 :side 23 :twist 13) (:elbow-r :flex 129) (:hand-r :twist 24 :flex -93)
     (:arm-l :flex 145 :side 91 :twist 47) (:elbow-l :flex 37) (:hand-l :flex -37))
  (12 (:root :u -0.16 :yaw 24 :f -0.05) (:pelvis :twist 30) (:spine :flex 4) (:chest :twist 42) (:neck :twist -30)      ; coiled
      (:head :twist -20) (:thigh-r :flex 30 :side 6) (:knee-r :flex 56) (:thigh-l :flex -8) (:knee-l :flex 38)
      (:arm-r :flex 101 :side 52 :twist -8) (:elbow-r :flex 90) (:hand-r :twist 31 :flex -125)
      (:arm-l :flex 125 :side 39 :twist 47) (:elbow-l :flex 77) (:hand-l :flex -97))
  (15 (:root :u -0.19 :yaw 28) (:chest :twist 46) (:knee-r :flex 60)                                               ; deeper
      (:arm-r :flex 111 :side 60 :twist -32) (:elbow-r :flex 68) (:hand-r :twist 39 :flex -129)
      (:arm-l :flex 126 :side 43 :twist 33) (:elbow-l :flex 63))
  (16 (:root :u -0.18 :yaw 14 :f 0.2) (:pelvis :twist 18) (:chest :twist 34) (:spine :flex 12) (:neck :twist -16) (:head :twist -8)
      (:thigh-r :flex 40 :side 4) (:knee-r :flex 44) (:thigh-l :flex -20) (:knee-l :flex 20)                       ; released
      (:arm-r :flex 83 :side 10 :twist -70) (:elbow-r :flex 20) (:hand-r :twist 23 :flex -122)
      (:arm-l :flex 137 :side 90 :twist 35) (:elbow-l :flex 22) (:hand-l :flex -29))
  (:s :snap :ic-k-f1-hit)
  (:a (:root :yaw -12) (:chest :twist -10) (:arm-r :flex 91 :side 65 :twist -81) (:elbow-r :flex 11) (:hand-r :twist -18 :flex -78)
      (:arm-l :flex 108 :side 82) (:elbow-l :flex 48))
  (27 (:root :f 0.4 :u -0.18 :yaw -22) (:pelvis :twist -6) (:chest :twist -36) (:spine :flex 16) (:thigh-r :flex 50)        ; carried
      (:knee-r :flex 54) (:thigh-l :flex -26) (:knee-l :flex 14)                                                            ; past him
      (:arm-r :flex 56 :side 11 :twist -79) (:elbow-r :flex 33) (:hand-r :twist -2 :flex -71)
      (:arm-l :flex 138 :side 115) (:elbow-l :flex 17))
  (33 (:root :f 0.2 :u -0.12 :yaw -10) (:pelvis :twist 6) (:chest :twist -18) (:spine :flex 10) (:thigh-r :flex 30)        ; settle
      (:knee-r :flex 32) (:thigh-l :flex -14) (:knee-l :flex 16)
      (:arm-r :flex 24 :side 16 :twist -59) (:elbow-r :flex 42) (:hand-r :twist 12 :flex -90)
      (:arm-l :flex 160 :side 116) (:elbow-l :flex 17))
  (:end :ic-k-stance))

;; K2 昇板 SHO-ITA: both hands, the slab's end dragged along the plaza behind him to his left (the move enters at f6),
;; then a rising diagonal ↗ with the arms out, held high at the top
(defpose :ic-k-f2-hit (:base :ic-k-stance)
  (:root :f 0.55 :u -0.16) (:pelvis :twist 10) (:spine :flex 10) (:chest :twist -10) (:neck :twist 8) (:head :flex -14)
  (:arm-r :flex 100 :side -40 :twist -16) (:elbow-r :flex 7) (:hand-r :twist 3 :flex -81)
  (:arm-l :flex 127 :side 86 :twist 6) (:elbow-l :flex 21) (:hand-l :flex -20)
  (:thigh-r :flex 44) (:knee-r :flex 40) (:thigh-l :flex -24) (:knee-l :flex 10))
(defstrike :ic-k-f2 (20 4 24 :base :ic-k-stance)
  (0)
  (3 (:root :u -0.1 :yaw 10) (:knees :flex 22) (:arm-r :flex 10 :side 14 :twist 23) (:elbow-r :flex 80) (:hand-r :flex -70))
  (6 (:root :u -0.2 :yaw 22) (:pelvis :twist 30) (:spine :flex 22) (:chest :twist 36) (:neck :twist -24) (:knees :flex 70)    ; the
     (:thigh-r :flex 34) (:thigh-l :flex 26)                                                                               ; end
     (:arm-r :flex 26 :side -9 :twist 23) (:elbow-r :flex 64) (:hand-r :twist 34 :flex -119)                                ; behind
     (:arm-l :flex 129 :side 116 :twist 7) (:elbow-l :flex 46) (:hand-l :flex -21))
  (12 (:root :u -0.22 :yaw 18) (:pelvis :twist 28) (:chest :twist 30) (:neck :twist -20)                                   ; dragged
      (:arm-r :flex 50 :side -4 :twist 0) (:elbow-r :flex 29) (:hand-r :twist 42 :flex -106)
      (:arm-l :flex 142 :side 114 :twist 6) (:elbow-l :flex 14) (:hand-l :flex -20))
  (17 (:root :u -0.24 :yaw 10 :f 0.15) (:pelvis :twist 22) (:chest :twist 18) (:spine :flex 28) (:thigh-r :flex 36) (:thigh-l :flex 28)
      (:knees :flex 76)
      (:arm-r :flex 57 :side -14 :twist -11) (:elbow-r :flex 29) (:hand-r :twist 28 :flex -84)                             ; rising
      (:arm-l :flex 138 :side 119))
  (:s :snap :ic-k-f2-hit)
  (:a (:root :u -0.1) (:spine :flex 2) (:chest :twist -18)
      (:arm-r :flex 110 :side -14 :twist 7) (:elbow-r :flex 65) (:hand-r :twist -10 :flex -119)
      (:arm-l :flex 128 :side 64 :twist 2) (:elbow-l :flex 51))
  (30 (:root :f 0.45 :u -0.08) (:spine :flex -6) (:chest :twist -20) (:head :flex -20)                                     ; held high
      (:arm-r :flex 170 :side -9 :twist 4) (:elbow-r :flex 10) (:hand-r :twist -2 :flex -107)
      (:arm-l :flex 171 :side 51) (:elbow-l :flex 11))
  (38 (:root :f 0.2 :u -0.1) (:spine :flex 6) (:chest :twist -8) (:head :flex -6) (:thigh-r :flex 24) (:knee-r :flex 24)     ; settle
      (:thigh-l :flex -12) (:knee-l :flex 12)
      (:arm-r :flex 60 :side 20 :twist 0) (:elbow-r :flex 40) (:hand-r :twist 0 :flex -70)
      (:arm-l :flex 120 :side 100) (:elbow-l :flex 30))
  (:end :ic-k-stance))

;; K3 天鎖落 TENSA-OTOSHI: both hands, the slab lifted level overhead (the Berserk wind-up; the move enters at f7), held
;; through a step with the right foot (the move's real :slide 1.0: the clip draws the stride, not the travel), turned
;; up behind his head, then the vertical drop: level ahead at S (the line's end), down to just off the plaza, held
(defpose :ic-k-f3-hit (:base :ic-k-stance)
  (:root :f 0.25 :u -0.24) (:pelvis :twist 8) (:spine :flex 34) (:chest :twist 0) (:neck :twist -4) (:head :flex -20)
  (:arm-r :flex 137 :side 19 :twist 22) (:elbow-r :flex 20) (:hand-r :twist -8 :flex -140)
  (:arm-l :flex 111 :side 43 :twist -5) (:elbow-l :flex 90) (:hand-l :flex -25)
  (:thigh-r :flex 58 :side 6) (:knee-r :flex 62) (:thigh-l :flex -26 :side 8) (:knee-l :flex 26))
(defstrike :ic-k-f3 (21 5 34 :base :ic-k-stance)
  (0)
  (7 (:root :u -0.06) (:pelvis :twist 10) (:spine :flex 0) (:chest :twist 6) (:head :flex -10)                          ; lifted
     (:arm-r :flex 89 :side -7 :twist 22) (:elbow-r :flex 98) (:hand-r :twist 64 :flex -137)
     (:arm-l :flex 152 :side 69 :twist -14) (:elbow-l :flex 10) (:hand-l :flex -25))
  (11 (:root :u 0.02) (:spine :flex -8) (:chest :twist 0) (:head :flex -24) (:thigh-r :flex 8)                           ; level
      (:arm-r :flex 169 :side 11 :twist 30) (:elbow-r :flex 8) (:hand-r :twist 64 :flex -34)                            ; overhead
      (:arm-l :flex 168 :side 40 :twist -14) (:elbow-l :flex 14))
  (15 (:root :u -0.04) (:spine :flex -10) (:knees :flex 20) (:thigh-r :flex 30 :side 6) (:knee-r :flex 46) (:thigh-l :flex -10)   ; held,
      (:arm-r :flex 167 :side 12 :twist 29) (:elbow-r :flex 7) (:hand-r :twist 62 :flex -26)                                 ; sinking,
      (:arm-l :flex 165 :side 40) (:elbow-l :flex 16))                                                                       ; stepping
  (18 (:root :u -0.02 :f 0.05) (:spine :flex -14) (:head :flex -28) (:thigh-r :flex 46) (:knee-r :flex 50) (:thigh-l :flex -18)
      (:knee-l :flex 14) (:arm-r :flex 168 :side 15 :twist 12) (:elbow-r :flex 20) (:hand-r :twist -13 :flex -64)     ; up behind
      (:arm-l :flex 136 :side 41) (:elbow-l :flex 58))                                                                ; his head
  (20 (:root :u -0.08 :f 0.12) (:spine :flex 4) (:head :flex -20) (:thigh-r :flex 50) (:knee-r :flex 52) (:thigh-l :flex -20)
      (:knee-l :flex 16) (:arm-r :flex 178 :side 10 :twist 12) (:elbow-r :flex 4) (:hand-r :twist -8 :flex -131)        ; over
      (:arm-l :flex 153 :side 43 :twist -7) (:elbow-l :flex 68))
  (:s :snap :ic-k-f3-hit)
  (23 (:root :u -0.27) (:spine :flex 40) (:arm-r :flex 99 :side 27 :twist 20) (:elbow-r :flex 46) (:hand-r :twist -15 :flex -141)
      (:arm-l :flex 87 :side 71 :twist -5) (:elbow-l :flex 96) (:hand-l :flex -26))
  (:a (:root :u -0.28) (:spine :flex 42) (:arm-r :flex 73 :side 62 :twist -19) (:elbow-r :flex 87) (:hand-r :twist -9 :flex -158)
      (:arm-l :flex 101 :side 72 :twist 6))                                                                               ; landed
  (34 (:root :u -0.27) (:spine :flex 41))                                                                                 ; held
  (44 (:root :f 0.12 :u -0.14) (:spine :flex 18) (:chest :twist -4) (:thigh-r :flex 34) (:knee-r :flex 36) (:thigh-l :flex -12)
      (:knee-l :flex 16) (:arm-r :flex 13 :side 51 :twist 30) (:elbow-r :flex 111) (:hand-r :twist -19 :flex -140)
      (:arm-l :flex 133 :side 93 :twist 23) (:elbow-l :flex 77))
  (52 (:root :f 0.04 :u -0.07) (:spine :flex 8) (:thigh-r :flex 16) (:knee-r :flex 18)                                  ; settle
      (:arm-r :flex -5 :side 30 :twist 25) (:elbow-r :flex 60) (:hand-r :twist 0 :flex -60)
      (:arm-l :flex 120 :side 100) (:elbow-l :flex 40))
  (:end :ic-k-stance))
(pushnew :ic-k-f1 *grip-clips*)                       ; (the K's: the left fist on the handle, GRIP-LEFT!)
(pushnew :ic-k-f2 *grip-clips*)
(pushnew :ic-k-f3 *grip-clips*)

(defpose :ic-k-parry-up (:base :ic-k-stance)         ; L KUSARI-TATE: the slab raised vertical before him, the flat out, the
  (:root :u -0.1) (:pelvis :twist 6) (:spine :flex 6) (:chest :twist 4) (:head :flex 4)            ; left palm on the flat
  (:arm-r :flex 46 :side -16 :twist 0) (:elbow-r :flex 88) (:hand-r :twist 0 :flex 70)
  (:arm-l :flex 58 :side -8) (:elbow-l :flex 84) (:hand-l :flex 10)
  (:thigh-r :flex 22 :side 8) (:knee-r :flex 30) (:thigh-l :flex 6 :side 8) (:knee-l :flex 28))
(defstrike :ic-k-parry (2 24 18 :base :ic-k-stance)
  (0 (:root :u -0.05) (:arm-r :flex 30 :side 16 :twist 0) (:elbow-r :flex 40))
  (:s :snap :ic-k-parry-up)
  (14 :ic-k-parry-up (:root :u -0.11))
  (:a :ic-k-parry-up (:root :u -0.1) (:arm-r :flex 60))
  (:end :ic-k-stance))

;; 残月返し ZANGETSU-GAESHI (the parry's counter): the left hand grabs his wrist ahead (the pull to 1.6 m is the move's),
;; the slab flung up over the right shoulder, the one-hand vertical drop as the grab hauls him in
(defpose :ic-k-gaeshi-hit (:base :ic-k-stance)
  (:root :f 0.5 :u -0.18) (:pelvis :twist 10) (:spine :flex 32) (:chest :twist 6) (:neck :twist -6) (:head :flex -16)
  (:arm-r :flex 132 :side -22 :twist -49) (:elbow-r :flex 0) (:hand-r :twist -12 :flex -93)
  (:arm-l :flex -67 :side 24 :twist 7) (:elbow-l :flex 97) (:hand-l :flex -10)
  (:thigh-r :flex 54 :side 6) (:knee-r :flex 58) (:thigh-l :flex -26 :side 8) (:knee-l :flex 20))
(defstrike :ic-k-gaeshi (6 3 22 :base :ic-k-stance)
  (0)
  (2 (:root :u -0.06 :f 0.1) (:pelvis :twist 18) (:spine :flex 8) (:chest :twist -16)                                   ; the grab
     (:arm-r :flex 190 :side -2 :twist -33) (:elbow-r :flex 52) (:hand-r :twist 21 :flex -115)
     (:arm-l :flex 63 :side -40 :twist 14) (:elbow-l :flex 23) (:hand-l :flex -11))
  (4 (:root :u -0.04 :f 0.15) (:chest :twist -8) (:spine :flex 0) (:head :flex -10)                                     ; hauled,
     (:arm-r :flex 189 :side -7 :twist -65) (:elbow-r :flex 0) (:hand-r :twist -9 :flex -102)                           ; the slab up
     (:arm-l :flex 3 :side -4 :twist 9) (:elbow-l :flex 82))
  (:s :snap :ic-k-gaeshi-hit)
  (:a (:root :u -0.2) (:spine :flex 36) (:arm-r :flex 100 :side -4 :twist -59) (:elbow-r :flex 27) (:hand-r :twist -11 :flex -104)
      (:arm-l :flex -57 :side 23 :twist 9) (:elbow-l :flex 79))
  (14 (:root :f 0.45 :u -0.22) (:spine :flex 36) (:chest :twist 2) (:head :flex -12) (:knee-r :flex 60) (:knee-l :flex 24)
      (:hand-r :flex -96) (:arm-l :flex -48 :side 24) (:elbow-l :flex 56))
  (22 (:root :f 0.15 :u -0.1) (:spine :flex 12) (:chest :twist -4) (:thigh-r :flex 26) (:knee-r :flex 28) (:thigh-l :flex -10)
      (:knee-l :flex 14) (:arm-r :flex 0 :side 28 :twist 10) (:elbow-r :flex 55) (:hand-r :twist 0 :flex -55)
      (:arm-l :flex -10 :side 30) (:elbow-l :flex 50))
  (:end :ic-k-stance))

;; KUSARI-BIKI: the chain cast from the left fist (the arm thrown at him on S, the chain reaching out), then a lean
;; back, both feet braced, the fist reeling him in to the hip; the slab held low at his right hip
(defpose :ic-k-yank-hit (:base :ic-k-stance)
  (:root :f 0.12 :u -0.1 :yaw 8) (:pelvis :twist 0) (:spine :flex 14) (:chest :twist -26) (:neck :twist 20) (:head :flex -4 :twist 14)
  (:arm-l :flex 92 :side 8) (:elbow-l :flex 2) (:hand-l :flex -6)
  (:arm-r :flex -10 :side 32 :twist 23) (:elbow-r :flex 74) (:hand-r :flex -36)
  (:thigh-l :flex 36 :side 4) (:knee-l :flex 34) (:thigh-r :flex -18) (:knee-r :flex 18))
(defstrike :ic-k-yank (16 3 24 :base :ic-k-stance)
  (0)
  (5 (:root :u -0.06 :yaw -12) (:pelvis :twist 24) (:chest :twist 32) (:neck :twist -24) (:head :twist -16)          ; cocked back
     (:arm-l :flex -40 :side 46) (:elbow-l :flex 96) (:hand-l :flex -10) (:knees :flex 16))
  (11 (:root :u -0.08 :yaw -14) (:chest :twist 36) (:arm-l :flex -46) (:elbow-l :flex 104))                            ; held
  (14 (:root :u -0.1 :yaw 4 :f 0.08) (:pelvis :twist 6) (:spine :flex 10) (:chest :twist -14) (:neck :twist 14)           ; thrown
      (:arm-l :flex 70 :side 14) (:elbow-l :flex 24) (:thigh-l :flex 30) (:knee-l :flex 30) (:thigh-r :flex -14) (:knee-r :flex 16)
      (:arm-r :flex -10 :side 32 :twist 23) (:elbow-r :flex 74) (:hand-r :flex -36))
  (:s :snap :ic-k-yank-hit)
  (:a (:arm-l :flex 90))
  (24 (:root :f -0.12 :u -0.17 :yaw 4) (:pelvis :twist 12) (:spine :flex -14) (:chest :twist 22) (:neck :twist -8) (:head :flex 6)   ; lean
      (:arm-l :flex 14 :side 30) (:elbow-l :flex 104) (:hand-l :flex -20)                                                              ; back,
      (:thigh-l :flex 38 :side 14) (:knee-l :flex 22) (:thigh-r :flex -20 :side 14) (:knee-r :flex 14)                                  ; braced
      (:arm-r :flex 6 :side 34 :twist 23) (:elbow-r :flex 62) (:hand-r :flex -46))
  (31 (:root :f -0.14 :u -0.18) (:spine :flex -16) (:chest :twist 28) (:arm-l :flex -12 :side 32) (:elbow-l :flex 112))      ; reeling
  (37 (:root :f -0.05 :u -0.08) (:spine :flex 0) (:chest :twist 6) (:arm-l :flex 4 :side 24) (:elbow-l :flex 40)
      (:thigh-l :flex 10) (:knee-l :flex 12) (:thigh-r :flex -6) (:knee-r :flex 14))
  (:end :ic-k-stance))

(defstrike :ic-k-zanzo (12 0 16 :base :ic-k-stance)    ; SP2 残像: the slab swept flat before his face, then down to his side
  (0)
  (5 (:root :u -0.06) (:chest :twist -30) (:head :flex -6)                                     ; level before his face
     (:arm-r :flex 84 :side 70 :twist 6) (:elbow-r :flex 97) (:hand-r :twist 12 :flex -75))
  (:s :snap (:root :u -0.12) (:chest :twist 30) (:arm-l :flex 10 :side 30) (:knees :flex 26)     ; swept out to his right
      (:arm-r :flex 10 :side 85 :twist 0) (:elbow-r :flex 10) (:hand-r :twist 0 :flex -90))
  (20 (:chest :twist 20) (:arm-r :flex 0 :side 30 :twist 10) (:elbow-r :flex 50) (:hand-r :twist 0 :flex -55))   ; down
  (:end :ic-k-stance))

;; KAGE-UCHI 影討 (O's strike, after the flash step): a leap, the slab cocked high over the right shoulder, a one-hand
;; diagonal ↙ through him on S as he comes down, landing in a crouch with the slab low to his left
(defpose :ic-k-uchi-hit (:base :ic-k-stance)
  (:root :f 0.5 :u 0.08) (:pelvis :twist 12) (:spine :flex 20) (:chest :twist 14) (:neck :twist -10) (:head :flex -10)
  (:arm-r :flex 111 :side 5 :twist 42) (:elbow-r :flex 0) (:hand-r :twist 7 :flex -107)
  (:arm-l :flex -20 :side 40) (:elbow-l :flex 40)
  (:thigh-r :flex 40 :side 6) (:knee-r :flex 50) (:thigh-l :flex 10) (:knee-l :flex 40))
(defstrike :ic-k-uchi (7 3 24 :base :ic-k-stance)
  (0)
  (2 (:root :u 0.18 :f 0.1) (:pelvis :twist 16) (:spine :flex -6) (:chest :twist -20) (:thigh-r :flex 50) (:knee-r :flex 80)   ; leapt,
     (:thigh-l :flex 30) (:knee-l :flex 70) (:arm-r :flex 154 :side -39 :twist 27) (:elbow-r :flex 92) (:hand-r :twist -7 :flex -127)  ; cocked
     (:arm-l :flex 30 :side 50) (:elbow-l :flex 30))
  (5 (:root :u 0.26 :f 0.3) (:spine :flex 0) (:chest :twist -10) (:arm-r :flex 180 :side -17 :twist 10) (:elbow-r :flex 45)   ; the top
     (:hand-r :twist 0 :flex -143))
  (:s :snap :ic-k-uchi-hit)
  (:a (:root :u -0.18) (:spine :flex 28) (:chest :twist 22) (:thigh-r :flex 50) (:knee-r :flex 60) (:thigh-l :flex -10)          ; landed
      (:knee-l :flex 30) (:arm-r :flex 88 :side 88 :twist 42) (:elbow-r :flex 70) (:hand-r :twist -1 :flex -150))
  (16 (:root :f 0.45 :u -0.24) (:pelvis :twist 14) (:spine :flex 30) (:chest :twist 30) (:knee-r :flex 64) (:knee-l :flex 34)
      (:arm-r :flex 127 :side 114 :twist 22) (:elbow-r :flex 52) (:hand-r :twist 3 :flex -150))                                  ; low left
  (24 (:root :f 0.2 :u -0.1) (:spine :flex 10) (:chest :twist 8) (:thigh-r :flex 24) (:knee-r :flex 26) (:thigh-l :flex 0) (:knee-l :flex 14)
      (:arm-r :flex 0 :side 28 :twist 10) (:elbow-r :flex 55) (:hand-r :twist 0 :flex -55) (:arm-l :flex 0 :side 24) (:elbow-l :flex 30))
  (:end :ic-k-stance))

;; NS3's (the clones' rush, DUEL_CORE §6): the command gesture (the left hand thrown forward, the slab swept out low to his right), and
;; the X: a two-handed diagonal cut from over his right shoulder down across to his left (both hands on the hilt, turned alike, so its
;; mirror :ic-k-xb is the same cut from over his left shoulder: the user, 2026-10-27: 「X 劈砍時用兩手持刀，就不會有鏡像的姿勢問題了」)
(defstrike :ic-k-summon (14 0 16 :base :ic-k-stance)
  (0)
  (6 (:root :u -0.08 :yaw -6) (:chest :twist -10) (:arm-l :flex 80 :side 14 :twist 0) (:elbow-l :flex 8) (:hand-l :flex 10)
     (:arm-r :flex -24 :side 46 :twist 20) (:elbow-r :flex 20) (:hand-r :flex -40) (:knees :flex 26))
  (:s (:root :u -0.1 :yaw -8) (:chest :twist -12) (:arm-l :flex 86 :side 10 :twist 0) (:elbow-l :flex 4) (:hand-l :flex 14)
      (:arm-r :flex -30 :side 50 :twist 20) (:elbow-r :flex 16) (:hand-r :flex -40) (:knees :flex 30))
  (:end :ic-k-stance))
(defpose :ic-k-xa-up (:base :ic-k-stance)                 ; both hands on the hilt over his right shoulder, the slab back
  (:root :u -0.08 :yaw -14) (:pelvis :twist -16) (:spine :flex 0) (:chest :twist -28) (:neck :twist 24) (:head :flex -6)
  (:arm-r :flex 158 :side 28 :twist 0) (:elbow-r :flex 70) (:hand-r :flex -60 :twist 0)
  (:arm-l :flex 150 :side -18 :twist 0) (:elbow-l :flex 64) (:hand-l :flex -60 :twist 0)
  (:thigh-r :flex 20 :side 8) (:knee-r :flex 24) (:thigh-l :flex -6 :side 8) (:knee-l :flex 14))
(defpose :ic-k-xa-hit (:base :ic-k-stance)                ; ... down across him to his low left, both arms long
  (:root :f 0.2 :u -0.16 :yaw 14) (:pelvis :twist 16) (:spine :flex 18) (:chest :twist 26) (:neck :twist -18) (:head :flex -8)
  (:arm-r :flex 62 :side -26 :twist 0) (:elbow-r :flex 8) (:hand-r :flex -100 :twist 0)
  (:arm-l :flex 56 :side 22 :twist 0) (:elbow-l :flex 14) (:hand-l :flex -100 :twist 0)
  (:thigh-l :flex 40 :side 6) (:knee-l :flex 44) (:thigh-r :flex -22 :side 8) (:knee-r :flex 18))
(defstrike :ic-k-xa (8 3 16 :base :ic-k-stance)
  (0)
  (4 :ic-k-xa-up)
  (6 :ic-k-xa-up (:arm-r :flex 168) (:arm-l :flex 160) (:chest :twist -32))
  (:s :snap :ic-k-xa-hit)
  (:a :ic-k-xa-hit (:arm-r :flex 40) (:arm-l :flex 34) (:chest :twist 32))
  (20 (:root :u -0.1) (:chest :twist 10) (:arm-r :flex 20 :side 10) (:elbow-r :flex 40) (:hand-r :flex -60)
      (:arm-l :flex 20 :side 20) (:elbow-l :flex 40) (:hand-l :flex -40))
  (:end :ic-k-stance))
(defclip-mirror :ic-k-xb :ic-k-xa)

;; KESSA's blood chains and charges (DUEL_CORE §6, 2026-10-28; the chain itself is drawn by ICHIGO-CHAIN-LASH from the left fist):
;; pointer 1's rest, the left hand open low before him (the chains circle him: ICHIGO-CHAIN-REST); NS1's three lashes, the left arm
;; flung across from his left, back from his right, and down from overhead; NS2's two charges, the slab drawn low behind him, then
;; raised overhead in both hands
(defpose :ic-k-st-chain (:base :ic-k-stance)
  (:root :u -0.06) (:pelvis :twist 8) (:spine :flex 6) (:chest :twist -6) (:neck :twist -4) (:head :flex 2)
  (:arm-l :flex 34 :side 34 :twist 0) (:elbow-l :flex 30) (:hand-l :flex 20)
  (:arm-r :flex -14 :side 30 :twist 23) (:elbow-r :flex 40) (:hand-r :flex -46))
(defclip :ic-k-st-chain (2.0 :loop t :base :ic-k-st-chain)
  (0) (1.0 (:root :u -0.075) (:arm-l :flex 40 :side 30) (:elbow-l :flex 26)))
(defstrike :ic-k-lash-a (22 4 18 :base :ic-k-stance)
  (0)
  (8 (:root :u -0.08 :yaw 16) (:chest :twist 30) (:arm-l :flex -20 :side 80 :twist 0) (:elbow-l :flex 60) (:hand-l :flex 10) (:knees :flex 24))
  (17 (:root :u -0.1 :yaw 22) (:chest :twist 38) (:arm-l :flex -30 :side 88) (:elbow-l :flex 70) (:knees :flex 32))   ; the tell: wound
  (:s (:root :u -0.1 :yaw -6) (:chest :twist -10) (:arm-l :flex 80 :side 30 :twist 0) (:elbow-l :flex 10) (:hand-l :flex 0))
  (:a (:root :u -0.1 :yaw -18) (:chest :twist -30) (:arm-l :flex 70 :side -20) (:elbow-l :flex 10))
  (36 (:root :u -0.07 :yaw -6) (:chest :twist -10) (:arm-l :flex 30 :side 30) (:elbow-l :flex 40))
  (:end :ic-k-stance))
(defstrike :ic-k-lash-b (14 4 18 :base :ic-k-stance)
  (0)
  (6 (:root :u -0.08 :yaw -18) (:chest :twist -30) (:arm-l :flex 60 :side -30 :twist 0) (:elbow-l :flex 50) (:hand-l :flex -10))
  (:s (:root :u -0.1 :yaw 4) (:chest :twist 8) (:arm-l :flex 90 :side 30) (:elbow-l :flex 6))
  (:a (:root :u -0.08 :yaw 16) (:chest :twist 26) (:arm-l :flex 110 :side 70) (:elbow-l :flex 10))
  (28 (:root :u -0.07 :yaw 6) (:chest :twist 8) (:arm-l :flex 30 :side 34) (:elbow-l :flex 40))
  (:end :ic-k-stance))
(defstrike :ic-k-lash-c (18 5 26 :base :ic-k-stance)
  (0)
  (8 (:root :u -0.04) (:spine :flex -8) (:arm-l :flex 160 :side 20 :twist 0) (:elbow-l :flex 40) (:knees :flex 14))
  (14 (:root :u -0.02) (:spine :flex -14) (:arm-l :flex 176 :side 14) (:elbow-l :flex 20))                 ; raised: the tell
  (:s (:root :u -0.18 :f 0.12) (:spine :flex 26) (:arm-l :flex 60 :side 10) (:elbow-l :flex 6) (:knees :flex 40))   ; slammed
  (:a (:root :u -0.2 :f 0.12) (:spine :flex 30) (:arm-l :flex 40))
  (40 (:root :u -0.08) (:spine :flex 8) (:arm-l :flex 24 :side 30) (:elbow-l :flex 40))
  (:end :ic-k-stance))
;; AS1's whip: the left arm flung out four times, across from his left, back from his right, across again, then down from overhead
(defstrike :ic-k-whip (12 18 20 :base :ic-k-stance)
  (0)
  (6 (:root :u -0.08 :yaw 14) (:chest :twist 26) (:arm-l :flex -20 :side 80) (:elbow-l :flex 60) (:knees :flex 24))
  (:s (:root :u -0.1 :yaw -10) (:chest :twist -18) (:arm-l :flex 80 :side 20) (:elbow-l :flex 10))
  (16 (:root :u -0.1 :yaw 12) (:chest :twist 22) (:arm-l :flex 100 :side 70) (:elbow-l :flex 10))
  (20 (:root :u -0.1 :yaw -12) (:chest :twist -20) (:arm-l :flex 80 :side 10) (:elbow-l :flex 10))
  (23 (:root :u -0.04) (:spine :flex -10) (:arm-l :flex 172 :side 14) (:elbow-l :flex 20))
  (26 (:root :u -0.18 :f 0.1) (:spine :flex 24) (:arm-l :flex 60 :side 10) (:elbow-l :flex 6) (:knees :flex 36))
  (:a (:root :u -0.18 :f 0.1) (:spine :flex 26) (:arm-l :flex 44))
  (44 (:root :u -0.08) (:spine :flex 6) (:arm-l :flex 24 :side 30) (:elbow-l :flex 40))
  (:end :ic-k-stance))
(defstrike :ic-k-chg1 (20 0 14 :base :ic-k-stance)
  (0)
  (8 (:root :u -0.12 :yaw -10) (:chest :twist -20) (:arm-r :flex -40 :side 40 :twist 20) (:elbow-r :flex 20) (:hand-r :flex -60) (:knees :flex 40))
  (:s (:root :u -0.15 :yaw -14) (:chest :twist -26) (:arm-r :flex -50 :side 44 :twist 20) (:elbow-r :flex 16) (:hand-r :flex -64) (:knees :flex 48))
  (:end :ic-k-stance))
(defstrike :ic-k-chg2 (16 0 14 :base :ic-k-stance)
  (0)
  (7 (:root :u -0.08) (:spine :flex -6) (:arm-r :flex 168 :side 14 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -40)
     (:arm-l :flex 160 :side -10) (:elbow-l :flex 34) (:hand-l :flex -40))
  (:s (:root :u -0.1) (:spine :flex -8) (:arm-r :flex 176 :side 10) (:elbow-r :flex 20) (:hand-r :flex -36)
      (:arm-l :flex 168 :side -14) (:elbow-l :flex 24) (:hand-l :flex -36))
  (:end :ic-k-stance))

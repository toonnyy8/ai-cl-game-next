;;;; hisagi-art.lisp — HISAGI SHUHEI as art data (docs/duel/DUEL_HISAGI.md §11, §21): the Shikai's own clips (batch B3a,
;;;; §21.4: the approved slot plan §21.3, drawn to the current volumes; their :pose hook HS-POSE and HISAGI-DRAW's
;;;; let-outs); B2a's functional clips stay for the Bankai's forms (their motion-style pass is later): his body (TYBW: the sleeveless shihakusho, the white sash, a choker and two armbands, the
;;;; lieutenant's badge on the left arm, short messy black hair, three scars down over the right eye, the 69 and the blue
;;;; stripe on the left cheek; redone to canon, DUEL_HISAGI §21 "Look as built"), Kazeshini (a 0.97 m black rod with a
;;;; crescent of two blades, one inverted, the chain from butt to butt: the right hand's is the held weapon, the left
;;;; hand's the thrown one, drawn by HISAGI-DRAW), the model-sheet scenes (83980-83985), one clip per move at the move's
;;;; frames, the chain and the sickle's flight (drawn to the sim's points: the thrown sickle's tip at the hit volume's end,
;;;; *HS-STRIKE-REACH*; the pulls' chain along HS-CHAIN-SEG's segment), the windmill, the lightning, the HUD's sickle icon,
;;;; his glyphs' name and a placeholder Kikon cinematic (the storyboard's, §11.5, is a later batch).
(in-package :duel)
(declaim (special *p1* *p2*))

;;; ---------------------------------------------------------------- body
;; The Shikai look to canon (DUEL_HISAGI §21 "Look as built"; motion-refs §4.2, notes §3): 1.81 m (scale 1.0), lean (width
;; 0.94), the hurt cylinder r 0.36 / h 1.8 (§8.1). TYBW: the messy black fringe over the brows and down to the ears; three
;; parallel scars from the brow down over the right eye (+x); the blue stripe across the bridge of the nose to the left
;; cheek's edge, the 69 under its end; a black choker with white studs; studded black bands on both upper arms, the 九
;; badge tied with white cloth above the left one; the sleeveless black top (a white trim round the arm holes, the deep V
;; of the white under-collar); the white sash, its knot and hanging ends at his right front (as every image draws it),
;; the empty blue-black scabbard of the sealed sword kept in it at the left hip; wide black hakama with pleats; white tabi
;; on straw waraji
(defbody :hisagi (:scale 1.0 :width 0.94 :hunch 0 :hurt-r 0.36 :hurt-h 1.8
                  :girth ((:head 1.16 1.16 1.16))
                  :palette ((:skin #xD6B49A) (:black #x16161E) (:hair #x141418) (:white #xECECE8) (:eye #xF2F0EC)
                            (:pupil #x3A3A40) (:lid #x141016) (:mouth #x7A3A3C) (:scar #x6A3A36) (:mark #x101014)
                            (:stripe #x3F6EA8) (:band #x0E0E12) (:sash #xE8E6DE) (:badge #xC2B48C) (:tabi #xE8E8E4)
                            (:sole #xA8916A) (:fold #x3A3A46) (:brow #x1A1418) (:scab #x1E2A48) (:stud #xE4E4DE))
                  :rim (#xFFD8B8 0.14))
  (:pelvis (:box 0.35 0.18 0.24 :c :black)
           (:box 0.36 0.07 0.25 :at (0 0.07 0) :c :sash)                                         ; the white sash
           (:box 0.05 0.05 0.03 :at (0.075 0.07 0.13) :c :sash)                                  ; its knot (his right front)
           (:box 0.032 0.16 0.012 :at (0.066 -0.04 0.172) :rot (0 0 6) :c :sash)                 ; the hanging ends
           (:box 0.028 0.13 0.012 :at (0.098 -0.03 0.168) :rot (0 0 -14) :c :sash)
           (:cyl 0.22 0.48 :top 0.165 :seg 8 :at (0 -0.22 0) :c :black)                          ; the hakama
           (:box 0.004 0.34 0.004 :at (0.06 -0.26 0.19) :rot (0 0 -4) :c :fold)                  ; its pleats
           (:box 0.004 0.32 0.004 :at (-0.07 -0.27 0.19) :rot (0 0 5) :c :fold)
           (:box 0.004 0.3 0.004 :at (0.0 -0.28 -0.2) :c :fold)
           ;; the empty scabbard thrust through the sash at the left hip: the mouth ahead, the end down, back and out
           (:box 0.04 0.72 0.028 :at (-0.215 -0.225 0.05) :rot (0 -12 -14) :c :scab)
           (:box 0.046 0.03 0.034 :at (-0.13 0.11 0.122) :rot (0 -12 -14) :c :band))
  (:spine (:bevel 0.34 0.25 0.23 0.04 :at (0 0.11 0) :c :black))
  (:chest (:bevel 0.42 0.3 0.26 0.05 :at (0 0.11 0) :c :black)
          (:box 0.018 0.2 0.01 :at (0.034 0.175 0.135) :rot (0 0 -24) :c :white)                ; the white under-collar V
          (:box 0.018 0.2 0.01 :at (-0.034 0.175 0.135) :rot (0 0 24) :c :white)
          (:box 0.05 0.15 0.012 :at (0 0.18 0.133) :c :skin)                                    ; (deep: the chest shows)
          (:box 0.005 0.17 0.004 :at (0.08 0.07 0.137) :rot (0 0 -10) :c :fold))
  (:neck (:cyl 0.04 0.17 :at (0 0.06 0) :c :skin)
         (:cyl 0.047 0.03 :seg 10 :at (0 0.07 0) :c :band)                                       ; the choker, its studs
         (:box 0.008 0.016 0.004 :at (0 0.07 0.048) :c :stud)
         (:box 0.008 0.016 0.004 :at (0.031 0.07 0.037) :rot (40 0 0) :c :stud)
         (:box 0.008 0.016 0.004 :at (-0.031 0.07 0.037) :rot (-40 0 0) :c :stud)
         (:box 0.008 0.016 0.004 :at (0.047 0.07 0.008) :rot (80 0 0) :c :stud)
         (:box 0.008 0.016 0.004 :at (-0.047 0.07 0.008) :rot (-80 0 0) :c :stud))
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
         ;; the three scars, parallel, from the brow straight down over his right eye (+x) to the cheek
         (:box 0.003 0.075 0.003 :at (0.017 0.124 0.0645) :rot (0 0 -4) :c :scar)
         (:box 0.003 0.078 0.003 :at (0.027 0.123 0.0645) :rot (0 0 -4) :c :scar)
         (:box 0.003 0.075 0.003 :at (0.037 0.122 0.0645) :rot (0 0 -4) :c :scar)
         ;; the blue stripe from his right eye's inner corner across the bridge of the nose to the left cheek's edge (and
         ;; round it), the 69 under its end (blue, as the TYBW anime and RoS draw it)
         (:box 0.066 0.013 0.003 :at (-0.02 0.1085 0.0628) :c :stripe)
         (:box 0.003 0.013 0.03 :at (-0.0535 0.1085 0.044) :c :stripe)
         (:box 0.0025 0.012 0.002 :at (-0.025 0.097 0.0625) :c :stripe)                          ; 6
         (:box 0.008 0.0025 0.002 :at (-0.029 0.0915 0.0625) :c :stripe)
         (:box 0.0025 0.006 0.002 :at (-0.033 0.094 0.0625) :c :stripe)
         (:box 0.008 0.0025 0.002 :at (-0.029 0.097 0.0625) :c :stripe)
         (:box 0.006 0.0025 0.002 :at (-0.028 0.1025 0.0625) :c :stripe)
         (:box 0.0025 0.012 0.002 :at (-0.045 0.097 0.0625) :c :stripe)                          ; 9
         (:box 0.008 0.0025 0.002 :at (-0.041 0.1025 0.0625) :c :stripe)
         (:box 0.0025 0.006 0.002 :at (-0.037 0.1 0.0625) :c :stripe)
         (:box 0.008 0.0025 0.002 :at (-0.041 0.097 0.0625) :c :stripe)
         (:box 0.006 0.0025 0.002 :at (-0.042 0.0915 0.0625) :c :stripe)
         ;; the hair (TYBW: grown out): the cap, spikes up and back, a ragged fringe over the brows (one strand down the
         ;; bridge of the nose), locks over the ears to the ear lobes, the nape
         (:sphere 0.074 :stretch 0.012 :at (0 0.158 -0.018) :seg 10 :c :hair)
         (:cone 0.03 0.09 :at (0.05 0.17 -0.04) :rot (0 30 -70) :seg 4 :c :hair)
         (:cone 0.03 0.09 :at (-0.05 0.17 -0.04) :rot (0 30 70) :seg 4 :c :hair)
         (:cone 0.03 0.1 :at (0 0.2 -0.05) :rot (0 70 0) :seg 4 :c :hair)
         (:cone 0.026 0.07 :at (0.032 0.195 -0.03) :rot (0 40 -40) :seg 4 :c :hair)
         (:cone 0.026 0.07 :at (-0.03 0.198 -0.035) :rot (0 45 35) :seg 4 :c :hair)
         (:cone 0.026 0.08 :at (0.035 0.135 -0.07) :rot (0 110 -30) :seg 4 :c :hair)
         (:cone 0.026 0.08 :at (-0.035 0.135 -0.07) :rot (0 110 30) :seg 4 :c :hair)
         (:cone 0.024 0.08 :at (-0.042 0.165 0.06) :rot (0 192 -14) :seg 4 :c :hair)             ; the fringe
         (:cone 0.024 0.085 :at (-0.018 0.163 0.062) :rot (0 194 -6) :seg 4 :c :hair)
         (:cone 0.02 0.1 :at (0.004 0.158 0.064) :rot (0 190 2) :seg 4 :c :hair)
         (:cone 0.024 0.085 :at (0.024 0.164 0.062) :rot (0 194 8) :seg 4 :c :hair)
         (:cone 0.024 0.09 :at (0.046 0.158 0.058) :rot (0 190 16) :seg 4 :c :hair)
         (:cone 0.026 0.085 :at (0.071 0.128 0.0) :rot (0 180 -8) :seg 4 :c :hair)               ; over the ears
         (:cone 0.026 0.085 :at (-0.071 0.128 0.0) :rot (0 180 8) :seg 4 :c :hair)
         (:cone 0.022 0.07 :at (0.066 0.12 0.03) :rot (0 186 -4) :seg 4 :c :hair)
         (:cone 0.022 0.07 :at (-0.066 0.12 0.03) :rot (0 186 4) :seg 4 :c :hair)
         (:cone 0.03 0.1 :at (0.03 0.11 -0.072) :rot (0 160 -6) :seg 4 :c :hair)                 ; the nape
         (:cone 0.03 0.1 :at (-0.03 0.11 -0.072) :rot (0 160 6) :seg 4 :c :hair))
  (:shoulder-r (:bevel 0.1 0.05 0.16 0.02 :at (0.02 -0.01 0) :rot (0 0 -20) :c :black)            ; (sleeveless: the top's edge)
               (:box 0.014 0.06 0.168 :at (0.072 -0.035 0) :rot (0 0 -20) :c :white))             ; the arm hole's trim
  (:shoulder-l (:bevel 0.1 0.05 0.16 0.02 :at (-0.02 -0.01 0) :rot (0 0 20) :c :black)
               (:box 0.014 0.06 0.168 :at (-0.072 -0.035 0) :rot (0 0 20) :c :white))
  (:upper-arm-r (:box 0.085 0.3 0.09 :at (0 -0.15 0) :c :skin)
                (:box 0.095 0.035 0.1 :at (0 -0.17 0) :c :band)                                   ; the studded band
                (:box 0.004 0.012 0.012 :at (0.049 -0.17 0) :c :stud)
                (:box 0.004 0.012 0.012 :at (0.049 -0.17 0.03) :c :stud)
                (:box 0.004 0.012 0.012 :at (0.049 -0.17 -0.03) :c :stud)
                (:box 0.012 0.012 0.004 :at (0.02 -0.17 0.051) :c :stud)
                (:box 0.012 0.012 0.004 :at (0.02 -0.17 -0.051) :c :stud))
  (:upper-arm-l (:box 0.085 0.3 0.09 :at (0 -0.15 0) :c :skin)
                (:box 0.095 0.035 0.1 :at (0 -0.2 0) :c :band)
                (:box 0.004 0.012 0.012 :at (-0.049 -0.2 0) :c :stud)
                (:box 0.004 0.012 0.012 :at (-0.049 -0.2 0.03) :c :stud)
                (:box 0.004 0.012 0.012 :at (-0.049 -0.2 -0.03) :c :stud)
                (:box 0.012 0.012 0.004 :at (-0.02 -0.2 0.051) :c :stud)
                (:box 0.012 0.012 0.004 :at (-0.02 -0.2 -0.051) :c :stud)
                ;; the lieutenant's badge, a shield with 九 tied on with white cloth (TYBW anime, RoS)
                (:box 0.093 0.05 0.098 :at (0 -0.09 0) :c :white)
                (:box 0.006 0.06 0.056 :at (-0.05 -0.085 0) :c :badge)
                (:box 0.006 0.028 0.028 :at (-0.05 -0.115 0) :rot (0 45 0) :c :badge)
                (:box 0.002 0.003 0.028 :at (-0.0535 -0.07 0) :c :mark)                           ; 九
                (:box 0.002 0.03 0.004 :at (-0.0535 -0.085 0.007) :rot (0 -20 0) :c :mark)
                (:box 0.002 0.026 0.004 :at (-0.0535 -0.083 -0.006) :c :mark)
                (:box 0.002 0.003 0.012 :at (-0.0535 -0.096 -0.012) :c :mark))
  (:lower-arm-r (:box 0.075 0.25 0.075 :at (0 -0.125 0) :c :skin))
  (:lower-arm-l (:box 0.075 0.25 0.075 :at (0 -0.125 0) :c :skin))
  (:hand-r (:bevel 0.06 0.08 0.06 0.016 :at (0 -0.04 0) :c :skin))
  (:hand-l (:bevel 0.06 0.08 0.06 0.016 :at (0 -0.04 0) :c :skin))
  (:thigh-r (:cyl 0.11 0.44 :top 0.1 :seg 10 :at (0 -0.21 0) :c :black))
  (:thigh-l (:cyl 0.11 0.44 :top 0.1 :seg 10 :at (0 -0.21 0) :c :black))
  (:shin-r (:cyl 0.12 0.3 :top 0.105 :seg 10 :at (0 -0.1 0) :c :black) (:box 0.075 0.12 0.085 :at (0 -0.37 0) :c :tabi))
  (:shin-l (:cyl 0.12 0.3 :top 0.105 :seg 10 :at (0 -0.1 0) :c :black) (:box 0.075 0.12 0.085 :at (0 -0.37 0) :c :tabi))
  (:foot-r (:bevel 0.085 0.055 0.21 0.02 :at (0 -0.02 0.05) :c :tabi) (:box 0.095 0.02 0.23 :at (0 -0.05 0.05) :c :sole)
           (:box 0.012 0.008 0.11 :at (0 0.008 0.09) :c :sole))
  (:foot-l (:bevel 0.085 0.055 0.21 0.02 :at (0 -0.02 0.05) :c :tabi) (:box 0.095 0.02 0.23 :at (0 -0.05 0.05) :c :sole)
           (:box 0.012 0.008 0.11 :at (0 0.008 0.09) :c :sole)))

;;; ---------------------------------------------------------------- Kazeshini
;; Each of the two weapons (the right hand's held one, the left hand's drawn by HISAGI-DRAW with the same mesh), to canon
;; (motion-refs §4.1, `324` / `325Hisagis_Shikai_Kazeshini`): a thin black rod 0.97 m long, held overhand near its butt
;; (the stance grip: the rear fifth), its forked butt (where the chain fixes) 0.22 m behind the fist, its point 0.75 m
;; ahead (the length the FK test reads: unchanged); two long crescent blades leaving it 0.5 m up on opposite sides, one on
;; each face of the rod, hooked in OPPOSITE directions (the user, 2026-10-17: 「鐮刀兩側的新月彎鉤應該要是相反方向，一個朝內一個
;; 朝外」): the edge-side one curls back toward him, the other forward, away from him (an S / pinwheel through the rod, point
;; symmetric about the crossing; tip to tip 0.92 m), each with its white-silver edge on its outer curve and a black spine.
;; No Reiatsu on the weapon at rest (canon: it glows only in the release and the effects)
(defparameter *hs-crescent* '((0.5 0.0) (0.4835 0.2415) (0.32 0.42))
  "Kazeshini's inward blade in the weapon frame ((y z): along the rod, toward the edge side): the root at the crossing on
the rod, a point on its curve, its tip (curled back toward the butt); the outward blade is it turned 180 degrees about the
crossing (its tip at y 0.68: ahead, still behind the rod's point at 0.75).")

(defun hs-mb-crescent (mb blade x0 x1 band)
  "One Kazeshini blade, BLADE 1 the inward one (*HS-CRESCENT*), 2 the outward one (1 turned 180 degrees about the
crossing), between the planes x = X0 and X1: the arc of the circle through its root, mid point and tip, 0.075 m wide at
the root, pointed at the tip, widening away from the circle's centre (its outer curve); BAND NIL its black spine (the
inner 60 %), T its white edge (the outer 40 %). Segments as KE-MB-PRISM quads."
  (let* ((pts (if (= blade 1)
                  *hs-crescent*
                  (destructuring-bind (cy cz) (first *hs-crescent*)
                    (loop for (y z) in *hs-crescent* collect (list (- (* 2 cy) y) (- (* 2 cz) z)))))))
    (destructuring-bind ((cy cz) (ay az) (by bz)) pts
      (let* ((d (* 2 (+ (* cy (- az bz)) (* ay (- bz cz)) (* by (- cz az)))))   ; the circle through the three
             (oy (/ (+ (* (+ (* cy cy) (* cz cz)) (- az bz)) (* (+ (* ay ay) (* az az)) (- bz cz)) (* (+ (* by by) (* bz bz)) (- cz az))) d))
             (oz (/ (+ (* (+ (* cy cy) (* cz cz)) (- by ay)) (* (+ (* ay ay) (* az az)) (- cy by)) (* (+ (* by by) (* bz bz)) (- ay cy))) d))
             (r (sqrt (+ (expt (- cy oy) 2) (expt (- cz oz) 2))))
             (a0 (atan (- cz oz) (- cy oy)))
             (a1 (atan (- bz oz) (- by oy)))
             (da (let ((x (- a1 a0))) (- x (* 2 pi (round x (* 2 pi))))))
             (n 12))
        (flet ((pt (i f) (let* ((u (/ i n)) (a (+ a0 (* u da))) (w (max 0.003 (* 0.075 (expt (- 1 u) 0.7)))) (rr (+ r (* f w))))
                           (list (+ oy (* rr (cos a))) (+ oz (* rr (sin a)))))))
          (dotimes (i n)
            (let ((f0 (if band 0.6 0.0)) (f1 (if band 1.0 0.6)))
              (ke-mb-prism mb (list (pt i f0) (pt (1+ i) f0) (pt (1+ i) f1) (pt i f1)) x0 x1))))))))

(defweapon :kazeshini (:length 0.75 :base 0.2)
  (:solid (mbc mb #x121216)                                                                ; the rod, its point, the fork
          (mb-tube mb 0 -0.16 0 0 0.64 0 0.012 :sides 6)
          (with-xform (mb (xform :y 0.695)) (mb-cone mb 0.012 0.11 :segments 6))
          (mb-tube mb 0 -0.16 0 0.022 -0.215 0 0.008 :sides 4)
          (mb-tube mb 0 -0.16 0 -0.022 -0.215 0 0.008 :sides 4)
          (mb-tube mb -0.024 -0.222 0 0.024 -0.222 0 0.006 :sides 4)
          (mbc mb #x2A2A30)                                                                ; the chain's first link
          (with-xform (mb (xform :y -0.25 :yaw 1.57)) (mb-box mb 0.01 0.05 0.03))
          (mbc mb #x18181C)                                                                ; the blades' spines
          (hs-mb-crescent mb 1 0.0 0.008 nil)
          (hs-mb-crescent mb 2 -0.008 0.0 nil))
  (:solid (mbc mb #xD4D8E0)                                                                ; their white-silver edges
          (hs-mb-crescent mb 1 0.001 0.007 t)
          (hs-mb-crescent mb 2 -0.007 -0.001 t)))

;; the sealed sword (the intro's prop, the kit's :intro-weapon: drawn up across his face, tossed up, it splits into Kazeshini):
;; a plain katana, black-wrapped, as long as the empty scabbard at his hip (0.72 m)
(defweapon :hs-sealed (:length 0.72)
  (:solid (mb-blade mb :width 0.028 :guard-color '(0.16 0.16 0.18) :handle-color '(0.07 0.07 0.08) :wrap-color '(0.16 0.16 0.2) :blade nil))
  (:solid :ink 0 (mb-blade mb :length 0.66 :width 0.028 :curve 0.012 :blade-color '(0.6 0.62 0.66) :edge-color '(0.86 0.88 0.9) :hilt nil)))

(defparameter *hs-strike-reach* '((:hs-nage :sickle 6.3) (:hs-kari :sickle 2.8)
                                  (:hs-s-nage :sickle 6.3) (:hs-s-maki :sickle 3.55) (:hs-s-kari :sickle 2.8)   ; (the Shikai's
                                  (:hs-s-kaeshi :sickle 1.4) (:hs-s-rin :sickle 1.4)                          ;  clips, §21.4)
                                  (:hs-r-q1 :sickle 4.0) (:hs-r-q2 :sickle 4.0) (:hs-r-spin :sickle 4.4))   ; (B2b: the Bankai's ranged J)
  "Clip -> what strikes, and its drawn reach (m, the hit volume's far edge: line end + radius, or the arc's): the left
sickle thrown on its chain, drawn by HISAGI-DRAW with its point there on the hit frames (*HS-FLIGHTS*), or a sickle let out
on its chain to there (*HS-LETOUT*: J2, J3, KARI-OTOSHI's two at the fan's edges); the host FK test reads these (as
Senjumaru's *SJ-STRIKE-REACH*).")
(defparameter *hs-flights* '((:hs-k1 6.3 t) (:hs-k2s 3.55 t) (:hs-shibari 4.85 nil) (:hs-raiden 6.8 nil)
                             (:hs-kikon 8.0 nil)
                             (:hs-r-j1 4.0 nil) (:hs-r-j2 4.0 nil) (:hs-r-j2s 4.0 nil) (:hs-r-j3 4.4 nil))   ; (B2b)
  "Move -> how far the left sickle's point flies out on its hit frames (m: the volume's far edge, as *HS-STRIKE-REACH*) and
whether it stays out (a throw: then at the anchor). (KARI-OTOSHI's two sickles: *HS-LETOUT*, the Shikai's clip, §21.4.)")

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

;; The Bankai's ranged J (B2b, functional only: the Bankai's look waits for its motion-style pass, DUEL_HISAGI §20): the
;; left sickle thrown out on its chain to the arc's edge on the hit frames (*HS-FLIGHTS*), at the moves' own frames
(defstrike :hs-r-q1 (12 3 12 :base :hs-stance) (0) (:s :snap :hs-nage-hit) (:a (:arm-l :flex 84)) (:end :hs-stance))
(defstrike :hs-r-q2 (11 3 13 :base :hs-stance) (0) (:s :snap :hs-nage-hit) (:a (:arm-l :flex 84)) (:end :hs-stance))
(defstrike :hs-r-spin (13 3 18 :base :hs-stance) (0) (:s :snap :hs-spin-hit) (:a (:root :yaw -390)) (:end :hs-stance (:root :yaw -360)))

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

;;; ---------------------------------------------------------------- the Shikai's clips (DUEL_HISAGI §21.3-§21.4)
;;; The approved slot plan (the user, 2026-10-17: 「可以」; motion-refs §3.1), drawn to the current hit volumes: each slot its
;;; own clip at its move's frames (the base kit's :clip-map, hisagi.lisp *HS-SHIKAI-CLIPS*; the Bankai's forms keep B2a's
;;; above). Archetypes: kusarigama (J, NAGE, HIKI, MODOSHI), rope dart (MAKI, HODOKI, the windmill), Blades of Chaos
;;; (KARI-OTOSHI, SHIBARI, the O), canon manner (stance, intro, win). The J strings hold the right rod short, near the
;;; blades (*HS-GRIP*); a sickle let out on its chain (*HS-LETOUT*) is drawn with its point at the strike's volume edge on
;;; its hit frames, and its clip is in *HS-STRIKE-REACH* (the FK test reads that reach).
(defparameter *hs-grip* '((:hs-s-sen 0.25) (:hs-s-kaeshi 0.25) (:hs-s-kaeshi-1h 0.25))
  "Clip -> the J strings' short grip (the user, 2026-10-17: 「握在靠刀的那端」, DUEL_HISAGI §21): the drawn right rod slid
this far back through his fist (m), so he holds it just behind the blades' crossing; its point (the FK test's tip) is
0.75 - this ahead of the fist, its butt 0.22 + this behind. HS-POSE eases it in and out (4 m/s); the FK test reads it.")
(defparameter *hs-letout*
  '((:hs-s-kaeshi :l 3 8 11 18 1.4 nil nil 0)       ; J2: the left sickle flung out on the arm's rising line
    (:hs-s-rin :r 2 6 12 22 1.4 nil nil 0)          ; J3: both whirled out round him
    (:hs-s-rin :l 2 6 12 22 1.4 nil nil 0)
    (:hs-s-kari :r 10 22 30 46 2.8 0.3 -60 1.8)     ; KARI-OTOSHI: over his head and down to the fan's edges
    (:hs-s-kari :l 10 22 30 46 2.8 0.3 60 1.8)
    (:hs-s-intro :r 70 82 82 96 0.3 2.9 0 0)        ; the intro: tossed up, split, caught
    (:hs-s-intro :l 70 84 84 98 0.5 2.6 25 0))
  "Clip -> a sickle let out of the fist on its chain: (clip side f0 f1 f2 f3 r h az bulge): it leaves the fist at clip
frame F0, is out from F1 to F2 with its point R m from his feet (horizontally), back in the fist at F3; along the fist's
bearing from his feet (AZ NIL) or AZ degrees off his facing (+ his left); H m up (NIL: on the arm's line); BULGE m higher
midway out (an overhead swing; a third of it coming back). HS-POSE moves the right one (its :weapon-r joint), HISAGI-DRAW
draws the left one; both the chain from the fist.")

;; the stance (canon reveal, softened): weight on the back foot, upright; the right rod low-forward at the hip, its point
;; down-forward, the blades by the right shin; the left rod at the left hip, point down; the chain in one loop between
(defpose :hs-s-stance ()
  (:root :u -0.05 :f -0.03) (:pelvis :twist -8) (:spine :flex 3) (:chest :twist -2) (:neck :twist 6) (:head :flex 2)
  (:arm-r :flex 16 :side 16 :twist 6) (:elbow-r :flex 32) (:hand-r :flex -100)
  (:arm-l :flex 6 :side 18 :twist -6) (:elbow-l :flex 22) (:hand-l :flex -100)
  (:thigh-l :flex 22 :side 10) (:knee-l :flex 10) (:thigh-r :flex -12 :side 12) (:knee-r :flex 26))
(defclip :hs-s-stance (2.0 :loop t :base :hs-s-stance)
  (0) (1.0 (:root :u -0.065) (:chest :flex 2) (:hand-r :flex -94) (:elbow-l :flex 26) (:hand-l :flex -96)))
;; the walk: the shared legs under his stance's arms (the chain loop dragging)
(defclip :hs-s-walk-f (0.9 :loop t :base :hs-s-stance)
  (0 (:thigh-r :flex 25) (:knee-r :flex 10) (:thigh-l :flex -15) (:knee-l :flex 20) (:arm-r :flex 10) (:arm-l :flex 12))
  (0.225 (:root :u -0.03) (:thigh-r :flex 0) (:knee-r :flex 20) (:thigh-l :flex 5) (:knee-l :flex 55))
  (0.45 (:root :u -0.05) (:thigh-l :flex 25) (:knee-l :flex 10) (:thigh-r :flex -15) (:knee-r :flex 20) (:arm-r :flex 20) (:arm-l :flex 2))
  (0.675 (:root :u -0.03) (:thigh-l :flex 0) (:knee-l :flex 20) (:thigh-r :flex 5) (:knee-r :flex 55)))
(defclip :hs-s-walk-b (0.9 :loop t :base :hs-s-stance)
  (0 (:spine :flex 2) (:thigh-r :flex -15) (:knee-r :flex 20) (:thigh-l :flex 25) (:knee-l :flex 10))
  (0.225 (:root :u -0.03) (:thigh-r :flex 5) (:knee-r :flex 55) (:thigh-l :flex 0) (:knee-l :flex 20))
  (0.45 (:root :u -0.05) (:thigh-l :flex -15) (:knee-l :flex 20) (:thigh-r :flex 25) (:knee-r :flex 10))
  (0.675 (:root :u -0.03) (:thigh-l :flex 5) (:knee-l :flex 55) (:thigh-r :flex 0) (:knee-r :flex 20)))
(defclip :hs-s-strafe-r (0.8 :loop t :base :hs-s-stance)
  (0 (:thigh-r :side 22 :flex 5) (:thigh-l :side -2) (:knee-l :flex 25))
  (0.2 (:root :u -0.04) (:thigh-r :side 8) (:knee-r :flex 45) (:thigh-l :side 5))
  (0.4 (:thigh-r :side 4) (:thigh-l :side 18 :flex 10) (:knee-l :flex 20))
  (0.6 (:root :u -0.04) (:thigh-l :side 5) (:knee-l :flex 45) (:thigh-r :side 10)))
(defclip :hs-s-strafe-l (0.8 :loop t :base :hs-s-stance)
  (0 (:thigh-l :side 22 :flex 30) (:thigh-r :side -2) (:knee-r :flex 25))
  (0.2 (:root :u -0.04) (:thigh-l :side 8) (:knee-l :flex 45) (:thigh-r :side 12))
  (0.4 (:thigh-l :side 4) (:thigh-r :side 22 :flex -5) (:knee-r :flex 20))
  (0.6 (:root :u -0.04) (:thigh-r :side 8) (:knee-r :flex 45) (:thigh-l :side 10)))
;; the run: leaning in, both rods held back low and level behind the hips, the chain trailing (D)
(defpose :hs-s-run-arms (:base :hs-s-stance)
  (:arm-r :flex -46 :side 18 :twist 0) (:elbow-r :flex 12) (:hand-r :flex -118)
  (:arm-l :flex -46 :side 18 :twist 0) (:elbow-l :flex 12) (:hand-l :flex -118) (:chest :twist 0) (:pelvis :twist 0))
(defrun :hs-s-run-arms :hs-s-run :hs-s-skate-b :hs-s-slide-r :hs-s-slide-l)

;; J1 旋 SEN (8/3/12, the slide 0.3): wound to his right, a skid in, the right sickle hooked flat right to left at chest
;; height (held short, near the blades); the left one back at the hip, the guard head
(defpose :hs-s-sen-hit (:base :hs-s-stance)
  (:root :f 0.12 :u -0.1 :yaw 8) (:pelvis :twist 0) (:spine :flex 10) (:chest :twist 10)
  (:arm-r :flex 58 :side 86 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -90 :twist 0)
  (:arm-l :flex -24 :side 22 :twist 0) (:elbow-l :flex 44) (:hand-l :flex -64)
  (:thigh-l :flex 40 :side 8) (:knee-l :flex 34) (:thigh-r :flex -24 :side 10) (:knee-r :flex 18))
(defstrike :hs-s-sen (8 3 12 :base :hs-s-stance)
  (0)
  (4 (:root :u -0.08 :yaw -16) (:chest :twist -30) (:spine :flex 6) (:arm-r :flex -24 :side 78) (:elbow-r :flex 34)
     (:hand-r :flex -90) (:arm-l :flex -10 :side 24) (:elbow-l :flex 40) (:knees :flex 24))                ; wound (the tell)
  (:s :snap :hs-s-sen-hit)
  (:a (:root :yaw 14 :f 0.14) (:chest :twist 24) (:arm-r :flex 108 :side 84))                           ; through, R to L
  (17 (:root :u -0.07 :yaw 8 :f 0.06) (:chest :twist 12) (:arm-r :flex 80 :side 44) (:elbow-r :flex 40) (:hand-r :flex -70))
  (:end :hs-s-stance))

;; J2 返旋 KAESHI-SEN (8/3/13): the hips turn back; the left sickle flung out on its chain from the left knee rising across
;; to over the right shoulder (the second head, let out to the volume's 1.4 m); the right rod drawn back to the shoulder
(defpose :hs-s-kaeshi-hit (:base :hs-s-stance)
  (:root :f 0.08 :u -0.08 :yaw -10) (:spine :flex 6) (:chest :twist -20)
  (:arm-l :flex 104 :side -14 :twist 0) (:elbow-l :flex 2) (:hand-l :flex -90)
  (:arm-r :flex 110 :side 34 :twist 0) (:elbow-r :flex 120) (:hand-r :flex -40)
  (:thigh-l :flex 30 :side 8) (:knee-l :flex 30) (:thigh-r :flex -16 :side 10) (:knee-r :flex 20))
(defstrike :hs-s-kaeshi (8 3 13 :base :hs-s-stance)
  (0 :hs-s-sen-hit (:root :yaw 14) (:chest :twist 24) (:arm-r :flex 108 :side 84))
  (4 (:root :u -0.11 :yaw 14 :f 0.04) (:chest :twist 30) (:spine :flex 12) (:arm-l :flex 4 :side 34 :twist 0)
     (:elbow-l :flex 4) (:hand-l :flex -90) (:arm-r :flex 120 :side 40) (:elbow-r :flex 100) (:hand-r :flex -50)
     (:knees :flex 30))                                                                                 ; the left hand low
  (:s :snap :hs-s-kaeshi-hit)
  (:a (:root :yaw -16) (:chest :twist -30) (:arm-l :flex 138 :side -30))                               ; up over his right
  (18 (:root :u -0.06 :yaw -6) (:chest :twist -10) (:arm-l :flex 60 :side 20) (:elbow-l :flex 30) (:arm-r :flex 50 :side 24)
      (:elbow-r :flex 50) (:hand-r :flex -80))
  (:end :hs-s-stance))

;; J3 輪 RIN (9/3/18): both sickles let out on the chain and whirled flat round him at the waist in a full turn to his
;; left on the left foot (a key every ~90 degrees); at S the right one sweeps across his front (the 200 degree arc), the
;; left one behind him; ends square, the chain slack
(defpose :hs-s-rin-hit (:base :hs-s-stance)
  (:root :yaw 330 :u -0.08) (:pelvis :twist 0) (:spine :flex 6) (:chest :twist 6)
  (:arm-r :flex 50 :side 74 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -90 :twist 0)
  (:arm-l :flex -40 :side 74 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -90 :twist 0)
  (:thigh-l :flex 22 :side 8) (:knee-l :flex 28) (:thigh-r :flex 6 :side 16) (:knee-r :flex 30))
(defstrike :hs-s-rin (9 3 18 :base :hs-s-stance)
  (0 :hs-s-kaeshi-hit (:root :yaw -16) (:chest :twist -30) (:arm-l :flex 138 :side -30))
  (2 (:root :u -0.12 :yaw -30) (:chest :twist -30) (:knees :flex 34) (:arm-r :flex -10 :side 70) (:elbow-r :flex 20)
     (:arm-l :flex 60 :side 60) (:elbow-l :flex 10))                                                    ; wound right
  (4 (:root :u -0.1 :yaw 60) (:chest :twist -6) (:arm-r :flex 30 :side 74) (:elbow-r :flex 4) (:arm-l :flex -30 :side 74)
     (:elbow-l :flex 4) (:hands :flex -90))
  (6 (:root :u -0.09 :yaw 150) (:pelvis :side 6))
  (8 (:root :u -0.08 :yaw 245) (:pelvis :side 4))
  (:s :snap :hs-s-rin-hit)
  (:a (:root :yaw 400) (:chest :twist 14))
  (20 (:root :yaw 372 :u -0.06) (:chest :twist 4) (:arm-r :flex 30 :side 40) (:elbow-r :flex 30) (:arm-l :flex 4 :side 34)
      (:elbow-l :flex 30))
  (:end :hs-s-stance (:root :yaw 360)))

;; KAESHI-SEN-1H (8/3/13; NAGE's J, the out graph's J2): the left sickle is out, so its own clip: the right rod turned
;; over in his fist (the forearm rolled half a turn: the other hook leading; Isshin-ryu's reversed grip), a backhand rising from his right hip across to over the
;; left shoulder; the left fist holding the chain at the hip
(defpose :hs-s-kaeshi-1h-hit (:base :hs-s-stance)
  (:root :f 0.16 :u -0.09 :yaw 6) (:spine :flex 6) (:chest :twist 12)
  (:arm-r :flex 70 :side 80 :twist 0) (:elbow-r :flex 6 :twist 180) (:hand-r :flex -90 :twist 0)
  (:arm-l :flex -14 :side 22) (:elbow-l :flex 50) (:hand-l :flex -40)
  (:thigh-l :flex 34 :side 8) (:knee-l :flex 30) (:thigh-r :flex -20 :side 10) (:knee-r :flex 20))
(defstrike :hs-s-kaeshi-1h (8 3 13 :base :hs-s-stance)
  (0)
  (4 (:root :u -0.13 :yaw -18) (:chest :twist -26) (:spine :flex 14) (:arm-r :flex 4 :side 40 :twist 0) (:elbow-r :flex 16 :twist 180)
     (:hand-r :flex -90 :twist 0) (:arm-l :flex -10 :side 22) (:elbow-l :flex 44) (:knees :flex 36))  ; low at his right hip
  (:s :snap :hs-s-kaeshi-1h-hit)
  (:a (:root :yaw 16) (:chest :twist 26) (:arm-r :flex 146 :side 6) (:elbow-r :flex 12))              ; over the left shoulder
  (18 (:root :u -0.06 :yaw 6) (:chest :twist 10) (:arm-r :flex 70 :side 30) (:elbow-r :flex 50 :twist 60) (:hand-r :flex -70))
  (:end :hs-s-stance))

;; RIN-1H (9/3/18): a pivot turn to his left through 200 degrees, the right sickle swung out at arm's length (the stance
;; grip); the chain from the left fist to the anchor sweeping the floor behind him
(defpose :hs-s-rin-1h-hit (:base :hs-s-stance)
  (:root :yaw 0 :u -0.1) (:pelvis :twist 0) (:spine :flex 8) (:chest :twist 4)
  (:arm-r :flex 56 :side 84 :twist 0) (:elbow-r :flex 26) (:hand-r :flex -90 :twist 0)
  (:arm-l :flex -20 :side 30) (:elbow-l :flex 40) (:hand-l :flex -40)
  (:thigh-l :flex 30 :side 10) (:knee-l :flex 34) (:thigh-r :flex -6 :side 14) (:knee-r :flex 30))
(defstrike :hs-s-rin-1h (9 3 18 :base :hs-s-stance)
  (0)
  (3 (:root :u -0.12 :yaw -70) (:chest :twist -24) (:arm-r :flex -16 :side 80) (:elbow-r :flex 30) (:hand-r :flex -90)
     (:knees :flex 32))                                                                                 ; wound right
  (6 (:root :u -0.11 :yaw -36) (:chest :twist -8) (:arm-r :flex 20 :side 84) (:elbow-r :flex 26))
  (:s :snap :hs-s-rin-1h-hit)
  (:a (:root :yaw 50) (:chest :twist 16) (:arm-r :flex 104 :side 84))
  (16 (:root :yaw 100 :u -0.08) (:chest :twist 20) (:arm-r :flex 120 :side 60) (:elbow-r :flex 40))  ; 200 degrees round
  (24 (:root :yaw 40 :u -0.06) (:chest :twist 6) (:arm-r :flex 60 :side 30) (:elbow-r :flex 40) (:hand-r :flex -70))
  (:end :hs-s-stance))

;; K1 投 NAGE (18/4/22): the tell, the left sickle swung once in a vertical wheel at his left side (forward, over, back,
;; down: a key every 90 degrees); a step through and the cast from the hip along the line, the left arm out at chest
;; height, the sickle a flat spinning disc at 1.1 m; the right rod pulled back to the right hip
(defpose :hs-s-nage-hit (:base :hs-s-stance)
  (:root :f 0.18 :u -0.12 :yaw -10) (:pelvis :twist 0) (:spine :flex 12) (:chest :twist -20)
  (:arm-l :flex 88 :side 6 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -20)
  (:arm-r :flex -34 :side 26) (:elbow-r :flex 50) (:hand-r :flex -80)
  (:thigh-l :flex 46 :side 8) (:knee-l :flex 44) (:thigh-r :flex -26 :side 10) (:knee-r :flex 14))
(defstrike :hs-s-nage (18 4 22 :base :hs-s-stance)
  (0)
  (3 (:root :u -0.06) (:arm-l :flex 90 :side 14 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -60))      ; forward
  (6 (:root :u -0.04) (:arm-l :flex 180 :side 12) (:elbow-l :flex 8))                                  ; over
  (6 (:arm-l :flex -180))                                     ; (the same turn written the other way: no wrap in a blend)
  (9 (:root :u -0.06) (:chest :twist 10) (:arm-l :flex -90 :side 12) (:elbow-l :flex 10))             ; back
  (12 (:root :u -0.08) (:chest :twist 16) (:arm-l :flex -20 :side 14) (:elbow-l :flex 12))             ; down
  (15 (:root :u -0.13 :yaw 16 :f 0.04) (:chest :twist 26) (:spine :flex 4) (:arm-l :flex -44 :side 20) (:elbow-l :flex 16)
      (:arm-r :flex -10 :side 24) (:thigh-r :flex 6) (:knee-r :flex 30) (:thigh-l :flex 20) (:knee-l :flex 20))   ; cocked
  (:s :snap :hs-s-nage-hit)
  (:a (:root :f 0.22) (:arm-l :flex 84))
  (32 (:root :f 0.1 :u -0.07) (:spine :flex 8) (:chest :twist -8) (:arm-l :flex 52 :side 20) (:elbow-l :flex 24))
  (:end :hs-s-stance))

;; K2 引 HIKI (S 20 from its link frame 6): the drop and pull (ch. 325): his right arm points at the foe (the chain runs
;; over it: the sim hand's point), he sinks and leans back, the left hand hauling the chain down past his hip; the
;; sickle comes back along the chain into the foe's back
(defpose :hs-s-hiki-hit (:base :hs-s-stance)
  (:root :f -0.1 :u -0.22 :yaw -4) (:pelvis :twist 0) (:spine :flex -6) (:chest :twist 6)
  (:arm-r :flex 82 :side 6 :twist 0) (:elbow-r :flex 6) (:hand-r :flex -80)
  (:arm-l :flex -48 :side 20) (:elbow-l :flex 14) (:hand-l :flex -50)
  (:thigh-l :flex 54 :side 10) (:knee-l :flex 74) (:thigh-r :flex 6 :side 14) (:knee-r :flex 64))
(defstrike :hs-s-hiki (20 4 24 :base :hs-s-stance)
  (0 :hs-s-nage-hit (:arm-l :flex 84))
  (6 :hs-s-nage-hit (:arm-l :flex 78))
  (12 (:root :f 0.08 :u -0.1 :yaw -2) (:chest :twist -4) (:spine :flex 8) (:arm-l :flex 72 :side 4) (:elbow-l :flex 20)
      (:arm-r :flex 70 :side 10) (:elbow-r :flex 20) (:hand-r :flex -70))                              ; both on the chain
  (16 (:root :f 0.04 :u -0.06) (:spine :flex 2) (:arm-l :flex 66 :side 6) (:elbow-l :flex 34))       ; the hand set
  (:s :snap :hs-s-hiki-hit)
  (:a (:root :u -0.24) (:arm-l :flex -58) (:chest :twist 10))
  (36 (:root :u -0.1 :f -0.04) (:spine :flex 4) (:chest :twist 4) (:arm-l :flex 4 :side 24) (:elbow-l :flex 30)
      (:arm-r :flex 40 :side 20) (:elbow-r :flex 30) (:knees :flex 30))
  (:end :hs-s-stance))

;; K2s 巻 MAKI (S 20 from its link frame 6): the elbow shoot: the chain wound once round his left forearm to shorten it,
;; wound to his left, the sickle released sideways in a curling left-to-right arc that wraps round the foe
(defpose :hs-s-maki-hit (:base :hs-s-stance)
  (:root :f 0.1 :u -0.1 :yaw -14) (:spine :flex 8) (:chest :twist -22)
  (:arm-l :flex 74 :side 60 :twist 0) (:elbow-l :flex 30) (:hand-l :flex -30)
  (:arm-r :flex 30 :side 40) (:elbow-r :flex 60) (:hand-r :flex -70)
  (:thigh-r :flex 30 :side 10) (:knee-r :flex 32) (:thigh-l :flex -14 :side 8) (:knee-l :flex 16))
(defstrike :hs-s-maki (20 4 24 :base :hs-s-stance)
  (0 :hs-s-sen-hit (:root :yaw 14) (:chest :twist 24) (:arm-r :flex 108 :side 84))
  (6 :hs-s-sen-hit (:root :yaw 14) (:chest :twist 24) (:arm-r :flex 104 :side 80))
  (11 (:root :yaw 10 :u -0.08) (:chest :twist 16) (:arm-r :flex 50 :side 40) (:elbow-r :flex 60) (:arm-l :flex 50 :side 24)
      (:elbow-l :flex 120) (:hand-l :flex -10 :twist 60))                                              ; the chain wound
  (16 (:root :yaw 22 :u -0.12) (:chest :twist 32) (:arm-l :flex 20 :side 84 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -40)
      (:knees :flex 30))                                                                                ; wound to his left
  (:s :snap :hs-s-maki-hit)
  (:a (:root :yaw -26) (:chest :twist -32) (:arm-l :flex 104 :side 40) (:elbow-l :flex 20))           ; across, L to R
  (36 (:root :u -0.06 :yaw -8) (:chest :twist -8) (:arm-l :flex 40 :side 30) (:elbow-l :flex 34))
  (:end :hs-s-stance))

;; K3 刈落 KARI-OTOSHI (S 22 from its link frame 8): a hop, both sickles let out and swung up over his head together and
;; brought down in front, parting to the 120 degree fan's edges at 2.8 m (*HS-LETOUT*); he lands bent over them; held
(defpose :hs-s-kari-hit (:base :hs-s-stance)
  (:root :f 0.14 :u -0.26) (:pelvis :twist 0) (:spine :flex 32) (:chest :twist 0) (:head :flex -14)
  (:arm-r :flex 66 :side 30 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -60)
  (:arm-l :flex 66 :side 30 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -60)
  (:thigh-l :flex 56 :side 12) (:knee-l :flex 70) (:thigh-r :flex -10 :side 14) (:knee-r :flex 50))
(defstrike :hs-s-kari (22 5 34 :base :hs-s-stance)
  (0 :hs-s-kaeshi-hit (:root :yaw -16) (:chest :twist -30) (:arm-l :flex 138 :side -30))
  (8 :hs-s-kaeshi-hit (:root :yaw -12) (:chest :twist -24) (:arm-l :flex 128 :side -24))
  (12 (:root :u -0.2 :yaw 0) (:chest :twist 0) (:spine :flex 22) (:arms :flex 20 :side 20) (:elbows :flex 30) (:hands :flex -60)
      (:knees :flex 60) (:thighs :flex 40))                                                             ; the crouch (tell)
  (16 (:root :u 0.12) (:spine :flex -10) (:arms :flex 170 :side 12) (:elbows :flex 10) (:knees :flex 20) (:thighs :flex 20))
  (19 (:root :u 0.16) (:spine :flex -16) (:head :flex 8) (:arms :flex 186 :side 14) (:elbows :flex 14))    ; the hop's top
  (:s :snap :hs-s-kari-hit)
  (:a :hs-s-kari-hit (:root :u -0.28) (:spine :flex 36))
  (40 :hs-s-kari-hit (:root :u -0.27) (:spine :flex 34))                                                  ; the long hold
  (50 (:root :f 0.06 :u -0.1) (:spine :flex 10) (:arms :flex 30 :side 24) (:elbows :flex 30) (:hands :flex -80))
  (:end :hs-s-stance))

;; K3 解 HODOKI (S 22 from its link frame 8): he turns inside the chain, his back to the foe, the chain thrown over his
;; right shoulder and heaved with both hands: the wrap unwinds off him and the sickle rips back along it (HS-CHAIN-SEG);
;; then round to face him again
(defpose :hs-s-hodoki-hit (:base :hs-s-stance)
  (:root :yaw -180 :u -0.16 :f 0.04) (:pelvis :twist 0) (:spine :flex 30) (:chest :twist -10) (:head :flex -10)
  (:arm-l :flex 150 :side -14 :twist 0) (:elbow-l :flex 74) (:hand-l :flex -30)
  (:arm-r :flex 146 :side 18 :twist 0) (:elbow-r :flex 80) (:hand-r :flex -40)
  (:thigh-l :flex 40 :side 10) (:knee-l :flex 50) (:thigh-r :flex -10 :side 12) (:knee-r :flex 40))
(defstrike :hs-s-hodoki (22 5 34 :base :hs-s-stance)
  (0 :hs-s-maki-hit (:root :yaw -26) (:chest :twist -32) (:arm-l :flex 104 :side 40))
  (8 :hs-s-maki-hit (:root :yaw -24) (:chest :twist -28) (:arm-l :flex 100 :side 40))
  (12 (:root :yaw -70 :u -0.1) (:chest :twist -14) (:arm-l :flex 120 :side 10) (:elbow-l :flex 40) (:arm-r :flex 60 :side 30))
  (15 (:root :yaw -120 :u -0.12) (:arm-l :flex 150 :side -10) (:elbow-l :flex 60) (:arm-r :flex 120 :side 20) (:elbow-r :flex 60))
  (18 (:root :yaw -160 :u -0.08) (:spine :flex 4) (:arm-l :flex 168 :side -16) (:elbow-l :flex 50) (:arm-r :flex 160 :side 16)
      (:elbow-r :flex 50))                                                                               ; over the shoulder
  (:s :snap :hs-s-hodoki-hit)
  (:a (:spine :flex 40) (:arm-l :flex 80 :side -10) (:elbow-l :flex 50) (:arm-r :flex 76 :side 14) (:elbow-r :flex 50))   ; heaved
  (36 (:root :yaw -270 :u -0.1) (:spine :flex 14) (:chest :twist 0) (:arm-l :flex 30 :side 30) (:elbow-l :flex 40)
      (:arm-r :flex 40 :side 30) (:elbow-r :flex 40))
  (46 (:root :yaw -350 :u -0.06) (:spine :flex 6))
  (:end :hs-s-stance (:root :yaw -360)))

;; 戻 MODOSHI (6/0/6): two hand-over-hand pulls, left then right; the sickle home and caught in the left fist on f6 with a
;; short twirl
(defstrike :hs-s-modoshi (6 0 6 :base :hs-s-stance)
  (0 (:arm-l :flex 64 :side 10) (:elbow-l :flex 10) (:arm-r :flex 30 :side 20) (:elbow-r :flex 40))
  (2 (:arm-l :flex -10 :side 24) (:elbow-l :flex 40) (:arm-r :flex 66 :side 6) (:elbow-r :flex 10) (:root :u -0.07))   ; left
  (4 (:arm-l :flex 56 :side 10) (:elbow-l :flex 14) (:arm-r :flex -6 :side 24) (:elbow-r :flex 40))   ; right
  (:s :snap (:arm-l :flex 30 :side 24) (:elbow-l :flex 50) (:hand-l :flex -40 :twist 70) (:arm-r :flex 20 :side 20))   ; caught
  (9 (:hand-l :flex -80 :twist -20) (:elbow-l :flex 34))
  (:end :hs-s-stance))

;; L 風車 KAZAGURUMA (6/60/14): in (the left sickle let out low and swung round: the push at the waist, f6-9), lifted into
;; the fan (the left arm up, the sickle circling flat above his head: the wrist's circle a key every 3 f, a turn in 12;
;; the right rod raised across his face, the guard), out (lowered, caught). The circle is HISAGI-DRAW's (%HS-KAZA-POINT)
(defpose :hs-s-kaza-up (:base :hs-s-stance)
  (:root :u -0.1) (:spine :flex 0) (:chest :twist 0) (:pelvis :twist 0)
  (:arm-l :flex 172 :side 10 :twist 0) (:elbow-l :flex 14) (:hand-l :flex -20)
  (:arm-r :flex 118 :side -16 :twist 0) (:elbow-r :flex 116) (:hand-r :flex -16)
  (:thighs :flex 20 :side 12) (:knees :flex 26))
(defstrike :hs-s-kaza (6 60 14 :base :hs-s-stance)
  (0)
  (3 (:root :u -0.12) (:chest :twist 20) (:arm-l :flex 30 :side 64) (:elbow-l :flex 10) (:knees :flex 30))     ; let out
  (:s :snap (:root :u -0.14) (:chest :twist -10) (:arm-l :flex 70 :side 76) (:elbow-l :flex 6) (:arm-r :flex 60 :side 20)
      (:elbow-r :flex 80) (:knees :flex 34) (:thighs :flex 24))                                                ; the push
  (9 (:root :u -0.14) (:chest :twist -20) (:arm-l :flex 100 :side 60))
  (16 :hs-s-kaza-up)
  (19 :hs-s-kaza-up (:arm-l :side 22 :twist 20)) (22 :hs-s-kaza-up (:arm-l :side 4 :twist -10))
  (25 :hs-s-kaza-up (:arm-l :side -6 :twist -20)) (28 :hs-s-kaza-up)
  (31 :hs-s-kaza-up (:arm-l :side 22 :twist 20)) (34 :hs-s-kaza-up (:arm-l :side 4 :twist -10))
  (37 :hs-s-kaza-up (:arm-l :side -6 :twist -20)) (40 :hs-s-kaza-up)
  (43 :hs-s-kaza-up (:arm-l :side 22 :twist 20)) (46 :hs-s-kaza-up (:arm-l :side 4 :twist -10))
  (49 :hs-s-kaza-up (:arm-l :side -6 :twist -20)) (52 :hs-s-kaza-up)
  (55 :hs-s-kaza-up (:arm-l :side 22 :twist 20)) (58 :hs-s-kaza-up (:arm-l :side 4 :twist -10))
  (61 :hs-s-kaza-up (:arm-l :side -6 :twist -20)) (64 :hs-s-kaza-up)
  (:a :hs-s-kaza-up (:arm-l :side 22 :twist 20))
  (72 (:root :u -0.08) (:arm-l :flex 70 :side 30) (:elbow-l :flex 30) (:arm-r :flex 40 :side 20) (:elbow-r :flex 50))   ; out
  (:end :hs-s-stance))

;; Shift+K 綴雷電 TSUZURI RAIDEN (20/3/24, ch. 337): an overhand cast from above the left shoulder (not NAGE's hip cast),
;; then the left fist high on the taut chain, the right hand's two fingers on it; the lightning down the chain (the look)
(defpose :hs-s-raiden-hit (:base :hs-s-stance)
  (:root :f 0.1 :u -0.1 :yaw -6) (:pelvis :twist 0) (:spine :flex 10) (:chest :twist -16)
  (:arm-l :flex 104 :side 4 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -20)
  (:arm-r :flex 74 :side -6 :twist 0) (:elbow-r :flex 46) (:hand-r :flex -14)
  (:thigh-l :flex 36 :side 8) (:knee-l :flex 38) (:thigh-r :flex -18 :side 10) (:knee-r :flex 16))
(defstrike :hs-s-raiden (20 3 24 :base :hs-s-stance)
  (0)
  (8 (:root :u -0.06 :yaw 8) (:chest :twist 14) (:arm-l :flex 150 :side 30 :twist 0) (:elbow-l :flex 70) (:hand-l :flex -40)
     (:arm-r :flex 50 :side 10) (:elbow-r :flex 90) (:hand-r :flex -20))                       ; up over the left shoulder
  (15 (:root :u -0.08 :yaw 14) (:chest :twist 24) (:spine :flex -4) (:arm-l :flex 170 :side 26) (:elbow-l :flex 100))   ; cocked
  (:s :snap :hs-s-raiden-hit)
  (:a :hs-s-raiden-hit (:root :f 0.12))
  (36 (:root :u -0.05) (:arm-l :flex 50 :side 20) (:elbow-l :flex 30) (:arm-r :flex 40 :side 20) (:elbow-r :flex 50))
  (:end :hs-s-stance))

;; Shift+L 縛 SHIBARI (16/34/26; the bind f16-19, the slam f46-49; vs Ayon, ch. 336-337, Ep225): the lasso (the chain
;; circled flat over his head once, cast so it winds round the foe's body: HISAGI-DRAW's wrap), then the canon heave
;; (the user's pick, §21: 「B 給 SP2 全身縛」): he turns his back, the chain over his right shoulder, the right arm raised
;; gripping it, the back bent forward, the foe hauled up and over and slammed (f46); round again
(defpose :hs-s-shibari-throw (:base :hs-s-stance)
  (:root :f 0.12 :u -0.1 :yaw -8) (:spine :flex 10) (:chest :twist -16) (:pelvis :twist 0)
  (:arm-l :flex 92 :side 8 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -20) (:arm-r :flex 30 :side 30) (:elbow-r :flex 50)
  (:thigh-l :flex 40 :side 8) (:knee-l :flex 40) (:thigh-r :flex -20 :side 10) (:knee-r :flex 16))
(defpose :hs-s-shibari-haul (:base :hs-s-stance)
  (:root :yaw -160 :u -0.06) (:spine :flex 6) (:chest :twist -10) (:pelvis :twist 0)
  (:arm-r :flex 168 :side 20 :twist 0) (:elbow-r :flex 50) (:hand-r :flex -20)
  (:arm-l :flex 130 :side -20 :twist 0) (:elbow-l :flex 70) (:hand-l :flex -30)
  (:thigh-l :flex 20 :side 10) (:knee-l :flex 24) (:thigh-r :flex -6 :side 12) (:knee-r :flex 30))
(defpose :hs-s-shibari-slam (:base :hs-s-stance)
  (:root :yaw -170 :u -0.3 :f 0.06) (:spine :flex 52) (:head :flex -16) (:chest :twist -6) (:pelvis :twist 0)
  (:arm-r :flex 70 :side 18 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -40)
  (:arm-l :flex 64 :side -10 :twist 0) (:elbow-l :flex 34) (:hand-l :flex -40)
  (:thigh-l :flex 60 :side 12) (:knee-l :flex 80) (:thigh-r :flex 0 :side 14) (:knee-r :flex 66))
(defstrike :hs-s-shibari (16 34 26 :base :hs-s-stance)
  (0)
  (4 (:root :u -0.06) (:arm-l :flex 166 :side 14 :twist 0) (:elbow-l :flex 20) (:chest :twist 6))             ; the lasso
  (7 (:arm-l :flex 160 :side -8 :twist 30) (:chest :twist 12))
  (10 (:arm-l :flex 168 :side 20 :twist -20) (:chest :twist 18))
  (13 (:root :yaw 12 :u -0.08) (:chest :twist 24) (:arm-l :flex 150 :side 34) (:elbow-l :flex 30))            ; cocked
  (:s :snap :hs-s-shibari-throw)
  (26 :hs-s-shibari-throw (:arm-l :flex 84) (:arm-r :flex 60 :side 10) (:elbow-r :flex 30))                     ; taut
  (32 (:root :yaw -90 :u -0.06) (:spine :flex 2) (:arm-r :flex 120 :side 20) (:elbow-r :flex 60) (:arm-l :flex 110 :side 0)
      (:elbow-l :flex 60))                                                                                        ; turning
  (38 :hs-s-shibari-haul)
  (44 :hs-s-shibari-haul (:spine :flex 26) (:arm-r :flex 150) (:arm-l :flex 116))                                ; the heave
  (46 :snap :hs-s-shibari-slam)
  (:a :hs-s-shibari-slam (:spine :flex 48))
  (60 (:root :yaw -270 :u -0.12) (:spine :flex 14) (:arm-l :flex 30 :side 20) (:arm-r :flex 30 :side 20) (:elbows :flex 30))
  (70 (:root :yaw -350 :u -0.06) (:spine :flex 6))
  (:end :hs-s-stance (:root :yaw -360)))

;; I: the Breaker's dash (low, both rods held back, the chain trailing) and 首掛 KUBIKAKE as the user decided (§21.3: a
;; front garrote, a push-down and the pin; no throw: the heave is SP2's): the short chain between the rods thrown over
;; his head from the front and drawn round his neck (HISAGI-DRAW: the slack through it), pulled down, then the pin
;; (down on the right knee, the left hand at his throat, the right sickle raised point down)
(defclip :hs-s-breaker (0.4 :loop t :base :hs-s-run-arms)
  (0 (:root :u -0.18) (:spine :flex 30) (:head :flex -16) (:thigh-r :flex 45) (:knee-r :flex 30) (:thigh-l :flex -26) (:knee-l :flex 60))
  (0.2 (:root :u -0.14) (:spine :flex 28) (:head :flex -16) (:thigh-l :flex 45) (:knee-l :flex 30) (:thigh-r :flex -26) (:knee-r :flex 60)))
(defpose :hs-s-kubikake-hit (:base :hs-s-stance)
  (:root :f 0.1 :u -0.1) (:pelvis :twist 0) (:spine :flex 12) (:chest :twist 0)
  (:arm-r :flex 92 :side 16 :twist 0) (:elbow-r :flex 60) (:hand-r :flex 10)
  (:arm-l :flex 92 :side 16 :twist 0) (:elbow-l :flex 60) (:hand-l :flex 10)
  (:thigh-l :flex 40 :side 10) (:knee-l :flex 40) (:thigh-r :flex -20 :side 10) (:knee-r :flex 16))
(defstrike :hs-s-kubikake (8 4 18 :base :hs-s-stance)
  (0 :hs-s-run-arms (:root :u -0.16) (:spine :flex 26) (:knees :flex 40))
  (4 (:root :u -0.04) (:spine :flex 0) (:arm-r :flex 150 :side 24) (:elbow-r :flex 20) (:hand-r :flex 0)
     (:arm-l :flex 150 :side 24) (:elbow-l :flex 20) (:hand-l :flex 0))                              ; over his head
  (:s :snap :hs-s-kubikake-hit)
  (:a (:root :u -0.26) (:spine :flex 34) (:arms :flex 50 :side 14) (:elbows :flex 50))                   ; pulled down
  (16 (:root :u -0.42 :f 0.12) (:spine :flex 28) (:thigh-r :flex 30 :side 10) (:knee-r :flex 120) (:thigh-l :flex 70)
      (:knee-l :flex 80) (:arm-l :flex 50 :side 6) (:elbow-l :flex 30) (:hand-l :flex -20)
      (:arm-r :flex 126 :side 14) (:elbow-r :flex 64) (:hand-r :flex 44))                                  ; the pin
  (24 (:root :u -0.42 :f 0.12) (:spine :flex 26) (:thigh-r :flex 30 :side 10) (:knee-r :flex 120) (:thigh-l :flex 70)
      (:knee-l :flex 80) (:arm-l :flex 50 :side 6) (:elbow-l :flex 30) (:hand-l :flex -20)
      (:arm-r :flex 122 :side 14) (:elbow-r :flex 60) (:hand-r :flex 44))
  (:end :hs-s-stance))

;; O 刈 KARI: the aura (the overhead whirl, the blade passing before his face: 「怖いか？」, ch. 325 / Ep219) and the strike
;; (20/2/30): the fan let go flat, a sidearm release, the sickle skimming the 7 m lane as a wide spinning disc (the flight's
;; look); the follow-up (the generic dash) is drawn hooked in him, the chain taut, then the same release as a close cut
(defpose :hs-s-kari-aim (:base :hs-s-stance)
  (:root :u -0.08) (:pelvis :twist 0) (:chest :twist 6)
  (:arm-l :flex 168 :side 12 :twist 0) (:elbow-l :flex 16) (:hand-l :flex -20)
  (:arm-r :flex 70 :side 20) (:elbow-r :flex 70) (:hand-r :flex -60))
(defclip :hs-s-kari-aim (0.5 :loop t :base :hs-s-kari-aim)
  (0) (0.125 (:arm-l :flex 150 :side -34 :twist 30) (:elbow-l :flex 30) (:head :flex 4))        ; across his face
  (0.25 (:arm-l :flex 124 :side 6 :twist 0) (:elbow-l :flex 20))
  (0.375 (:arm-l :flex 160 :side 44 :twist -30) (:elbow-l :flex 10)))
(defpose :hs-s-kari-o-hit (:base :hs-s-stance)
  (:root :f 0.16 :u -0.14 :yaw -14) (:pelvis :twist 0) (:spine :flex 14) (:chest :twist -24)
  (:arm-l :flex 84 :side 56 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -20)
  (:arm-r :flex -20 :side 30) (:elbow-r :flex 50) (:hand-r :flex -70)
  (:thigh-l :flex 44 :side 10) (:knee-l :flex 46) (:thigh-r :flex -24 :side 12) (:knee-r :flex 16))
(defstrike :hs-s-kari-o (20 2 30 :base :hs-s-stance)
  (0 :hs-s-kari-aim)
  (6 :hs-s-kari-aim (:arm-l :flex 150 :side -34) (:elbow-l :flex 30))
  (11 (:root :u -0.1 :yaw 6) (:chest :twist 14) (:arm-l :flex 100 :side 70) (:elbow-l :flex 10))       ; the whirl let down
  (16 (:root :u -0.14 :yaw 18) (:chest :twist 30) (:arm-l :flex -14 :side 80) (:elbow-l :flex 10) (:knees :flex 34))   ; wound
  (:s :snap :hs-s-kari-o-hit)
  (:a (:root :f 0.22) (:arm-l :flex 102 :side 34))
  (36 (:root :f 0.1 :u -0.07) (:spine :flex 8) (:chest :twist -8) (:arm-l :flex 50 :side 24) (:elbow-l :flex 30))
  (:end :hs-s-stance))

;; intro: the sealed sword (:hs-sealed, the kit's :intro-weapon to f70) drawn up across his face (Ep219), held: 「刈れ」;
;; tossed up spinning, it splits into the two sickles on the chain (*HS-LETOUT*: both up over him), caught; the stance
(defclip :hs-s-intro (2.0 :base :hs-s-stance)
  (0 (:arm-r :flex 20 :side 14) (:elbow-r :flex 20) (:hand-r :flex -100))
  (0.4 (:arm-r :flex 130 :side -20 :twist 0) (:elbow-r :flex 112) (:hand-r :flex -10) (:head :flex 8) (:root :u -0.06))
  (1.0 (:arm-r :flex 132 :side -22) (:elbow-r :flex 114) (:hand-r :flex -10) (:head :flex 10) (:root :u -0.07))
  (1.12 (:arm-r :flex 168 :side 10) (:elbow-r :flex 10) (:hand-r :flex -40) (:head :flex -20) (:arm-l :flex 40 :side 30))   ; the toss
  (1.45 (:arm-r :flex 150 :side 20) (:elbow-r :flex 20) (:arm-l :flex 150 :side 24) (:elbow-l :flex 20) (:head :flex -30))
  (1.65 (:arm-r :flex 40 :side 20) (:elbow-r :flex 30) (:arm-l :flex 30 :side 24) (:elbow-l :flex 30) (:head :flex 0)
        (:root :u -0.1))                                                                                   ; caught
  (2.0 :hs-s-stance))
;; win: the chain slack, a half-step back, he looks at the blade in his hand (ch. 325)
(defclip :hs-s-win (2.0 :base :hs-s-stance)
  (0)
  (0.5 (:root :f -0.2 :u -0.03) (:thigh-r :flex -24) (:thigh-l :flex 12) (:knee-l :flex 6)
       (:arm-r :flex 64 :side 6 :twist 0) (:elbow-r :flex 96) (:hand-r :flex -40) (:head :flex 18) (:neck :twist 0)
       (:arm-l :flex 4 :side 14) (:elbow-l :flex 16))
  (2.0 (:root :f -0.21 :u -0.035) (:thigh-r :flex -22) (:arm-r :flex 66 :side 6) (:elbow-r :flex 98) (:head :flex 20)))

;;; ---------------------------------------------------------------- looks (cosmetic; the sim's points, 0 B a frame)
;; (every float crosses a call through these f32vecs: a float argument boxes; 0 B a frame, debug 83901)
(declaim (type f32vec *hs-v* *hs-w* *hs-q* *hs-a* *hs-m* *hs-m2* *hs-ml* *hs-lo* *hs-pt* *hs-grip-v*))
(defvar *hs-v* (make-f32 3) "The left sickle's grip (world).")
(defvar *hs-w* (make-f32 3) "A chain end (world).")
(defvar *hs-q* (make-f32 3) "A point (world).")
(defvar *hs-a* (make-f32 4) "HISAGI-DRAW's floats: [0] his facing yaw, [1] the flight's reach (m), [2] scratch, [3] the
Shikai's looks (1: the chain through the left fist, the flat spinning disc; 0: B2a's, the Bankai's forms).")
(defvar *hs-m* (m4) "The left sickle's world matrix.")
(defvar *hs-m2* (m4) "A joint's matrix (scratch).")
(defvar *hs-ml* (m4) "The let-out left sickle's world matrix (%HS-LETOUT!).")
(defvar *hs-lo* (make-f32 16)
  "The let-outs (%HS-LETOUT!): [0] the right one's u (0 in the fist .. 1 out; HS-POSE, read by the draw hook of the same
fighter right after), [1-3] its fist, [4-6] its butt; [8] the left one's u, [9-11] its fist, [12-14] its butt.")
(defvar *hs-pt* (make-f32 3) "The left sickle's point the draw hook placed (%HS-POINT code 5: the windmill, SHIBARI's wrap).")
(defvar *hs-grip-v* (make-f32 3) "[0-1] each side's drawn grip slide (m, HS-POSE eases it to its clip's *HS-GRIP*); [2] the
last draw's effect seconds (HISAGI-DRAW keeps it for the next pose: the pose hook has no dt).")

(defparameter *hs-letout-v*
  (loop for (clip side f0 f1 f2 f3 r h az bulge) in *hs-letout*
        collect (list* clip side (coerce (mapcar #'f32 (list f0 f1 f2 f3 r (or h 0) (or az 0) bulge (if az 1 0) (if h 1 0)))
                                         'f32vec)))
  "*HS-LETOUT* as (clip side . f32vec): f0 f1 f2 f3 r h az bulge az-p h-p.")
(defun hs-letout-of (name side)
  "The let-out entry (an f32vec) of clip NAME's SIDE (:r / :l), or NIL. 0 B."
  (loop for x in *hs-letout-v* when (and (eq (first x) name) (eq (second x) side)) return (cddr x)))

(defun-fast %hs-letout! (m jm wj upper pos yaw kv fr out o)
  "M := a let-out sickle's weapon matrix (KV its *HS-LETOUT-V* entry at clip frame FR, FR an f32vec [0]): WJ its weapon
joint as the clip posed it (the fist; the held rod along its -Z), UPPER the shoulder (the arm's line), POS his feet, YAW
(an f32vec [0]) his facing. OUT[O] := u (smoothstep: 0 in the fist .. 1 out at R m from his feet), OUT[O+1..3] := the fist
(the chain's near end), OUT[O+4..6] := the sickle's butt (its far end). Its point: from the held point (u 0) to R m out
along the fist's bearing from his feet (or AZ degrees off his facing), H m up (or on the arm's line), BULGE m higher
midway (a third of it coming back); the rod pointing away from the fist, the blades 35 degrees off flat. 0 B."
  (declare (type f32vec m jm pos yaw kv fr out) (fixnum wj upper o))
  (let* ((f (aref fr 0)) (f0 (aref kv 0)) (f1 (aref kv 1)) (f2 (aref kv 2)) (f3 (aref kv 3))
         (x (cond ((or (< f f0) (>= f f3)) 0f0)
                  ((< f f1) (/ (- f f0) (f-max 1f0 (- f1 f0))))
                  ((< f f2) 1f0)
                  (t (- 1f0 (/ (- f f2) (f-max 1f0 (- f3 f2)))))))
         (u (* x x (- 3f0 (* 2f0 x))))
         (wo (* 16 wj)) (so (* 16 upper))
         (fx (aref jm (+ wo 12))) (fy (aref jm (+ wo 13))) (fz (aref jm (+ wo 14)))
         (dhx (- (aref jm (+ wo 8)))) (dhy (- (aref jm (+ wo 9)))) (dhz (- (aref jm (+ wo 10))))
         (px (aref pos 0)) (pz (aref pos 2)) (dx (- fx px)) (dz (- fz pz)) (rf (f-hypot dx dz))
         (a (+ (aref yaw 0) (* 0.017453292f0 (aref kv 6))))
         (bx (cond ((> (aref kv 8) 0.5f0) (- (f-sin a))) ((> rf 0.05f0) (/ dx rf)) (t (- (f-sin (aref yaw 0))))))
         (bz (cond ((> (aref kv 8) 0.5f0) (- (f-cos a))) ((> rf 0.05f0) (/ dz rf)) (t (- (f-cos (aref yaw 0))))))
         (r (aref kv 4))
         (sh (f-hypot (- fx (aref jm (+ so 12))) (- fz (aref jm (+ so 14)))))
         (slope (f-clamp (/ (- fy (aref jm (+ so 13))) (f-max 0.05f0 sh)) -0.8f0 0.8f0))
         (ty (if (> (aref kv 9) 0.5f0) (aref kv 5) (+ fy (* slope (- r rf)))))
         (lift (* (aref kv 7) (f-sin (* 3.1415927f0 u)) (if (>= f f2) 0.33f0 1f0)))
         (k (* 0.75f0 (- 1f0 u)))
         (qx (+ fx (* u (- (+ px (* r bx)) fx)) (* k dhx)))
         (qy (+ fy (* u (- ty fy)) lift (* k dhy)))
         (qz (+ fz (* u (- (+ pz (* r bz)) fz)) (* k dhz)))
         (ex (- qx fx)) (ey (- qy fy)) (ez (- qz fz)) (el (f-hypot ex ey ez))
         (yx (if (> el 0.05f0) (/ ex el) dhx)) (yy (if (> el 0.05f0) (/ ey el) dhy)) (yz (if (> el 0.05f0) (/ ez el) dhz))
         (zl (f-hypot yz yx))
         (hx (if (> zl 0.05f0) (/ (- yz) zl) (f-cos (aref yaw 0)))) (hz (if (> zl 0.05f0) (/ yx zl) (- (f-sin (aref yaw 0)))))
         (z0x (* 0.82f0 hx)) (z0y 0.57f0) (z0z (* 0.82f0 hz))      ; (the blades tilted 35 degrees off flat: they read
         (dot (+ (* z0x yx) (* z0y yy) (* z0z yz)))                  ;  from a level camera and from above)
         (z1x (- z0x (* dot yx))) (z1y (- z0y (* dot yy))) (z1z (- z0z (* dot yz)))
         (zn (f-max 0.001f0 (f-hypot z1x z1y z1z)))
         (zx (/ z1x zn)) (zy (/ z1y zn)) (zz (/ z1z zn))
         (xx (- (* yy zz) (* yz zy))) (xy (- (* yz zx) (* yx zz))) (xz (- (* yx zy) (* yy zx)))
         (ox (- qx (* 0.75f0 yx))) (oy (- qy (* 0.75f0 yy))) (oz (- qz (* 0.75f0 yz))))
    (declare (single-float f f0 f1 f2 f3 x u fx fy fz dhx dhy dhz px pz dx dz rf a bx bz r sh slope ty lift k qx qy qz
                           ex ey ez el yx yy yz zl hx hz z0x z0y z0z dot z1x z1y z1z zn zx zy zz xx xy xz ox oy oz)
             (fixnum wo so))
    (setf (aref m 0) xx (aref m 1) xy (aref m 2) xz (aref m 3) 0f0
          (aref m 4) yx (aref m 5) yy (aref m 6) yz (aref m 7) 0f0
          (aref m 8) zx (aref m 9) zy (aref m 10) zz (aref m 11) 0f0
          (aref m 12) ox (aref m 13) oy (aref m 14) oz (aref m 15) 1f0
          (aref out o) u (aref out (+ o 1)) fx (aref out (+ o 2)) fy (aref out (+ o 3)) fz
          (aref out (+ o 4)) (- ox (* 0.22f0 yx)) (aref out (+ o 5)) (- oy (* 0.22f0 yy)) (aref out (+ o 6)) (- oz (* 0.22f0 yz))))
  nil)

(declaim (type f32vec *hs-fr* *hs-yaw*))
(defvar *hs-fr* (make-f32 1) "The clip frame %HS-LETOUT! reads.")
(defvar *hs-yaw* (make-f32 1) "His facing for %HS-LETOUT!.")
(defun-fast hs-pose (e m)
  "His kit's :pose hook (draw.lisp DRAW-FIGHTER, right after the FK; the FK origin in *POSE-AT*): the J strings' short grip
(*HS-GRIP*: the right rod slid back through his fist, eased at 4 m/s) and the right sickle let out on its chain
(*HS-LETOUT*: its :weapon-r joint moved where it flies, so the body draw puts it there). Other clips: nothing. A look. 0 B."
  (let* ((an (model-anim m)) (c (anim-clip an)) (name (if c (clip-name c) nil)) (jm (model-joints m)) (gv *hs-grip-v*)
         (side (if (eq e *p1*) 0 1)) (g (assoc name *hs-grip*))
         (target (if g (the single-float (second g)) 0f0)) (cur (aref gv side)) (step (* 4f0 (aref gv 2)))
         (o (* 16 (ji :weapon-r))) (kv (hs-letout-of name :r)))
    (declare (type f32vec jm gv) (fixnum side o) (single-float target cur step))
    (setf cur (cond ((<= step 0f0) target)                 ; (frozen effects, a still: the clip's grip at once)
                     ((< cur target) (f-min target (+ cur step))) (t (f-max target (- cur step))))
          (aref gv side) cur
          (aref *hs-lo* 0) 0f0)
    (when (> cur 0f0)
      (dotimes (i 3) (setf (aref jm (+ o 12 i)) (+ (aref jm (+ o 12 i)) (* cur (aref jm (+ o 8 i)))))))
    (when kv
      (let ((p *pose-at*) (fr *hs-fr*) (yw *hs-yaw*) (w *hs-m2*) (lo *hs-lo*))
        (declare (type f32vec p fr yw w lo))
        (setf (aref fr 0) (* 60f0 (the single-float (anim-time an))) (aref yw 0) (aref p 3))
        (%hs-letout! w jm (ji :weapon-r) (ji :upper-arm-r) p yw (the f32vec kv) fr lo 0)
        (when (> (aref lo 0) 0f0)                       ; the joint's axes from the weapon frame's (*WEAPON-M*'s inverse)
          (dotimes (i 3)
            (setf (aref jm (+ o i)) (- (aref w i)) (aref jm (+ o 4 i)) (- (aref w (+ 8 i)))
                  (aref jm (+ o 8 i)) (- (aref w (+ 4 i))) (aref jm (+ o 12 i)) (aref w (+ 12 i))))))))
  nil)

(declaim (fixnum *hs-chain-black*))
(defvar *hs-chain-black* 0
  "1 while the Bankai's chains are drawn (%HS-ORB-DRAW): VFX-HS-CHAIN's links are solid black kites in the alpha batch
(%HS-BLACK-KITE: no toon INK palette's white edge or core, no steel glint). The user, 2026-10-18: 「我希望鎖鏈是黑色的」.")
(defmacro %hs-black-kite (x y z ux uy uz len w)
  "A solid black camera-facing kite centred at (X Y Z) along the unit (UX UY UZ), LEN long (0.6 ahead), half-width W,
pushed 0.1 m toward the eye (FX-SHARD's shape without its palette): the alpha batch at uv 0 is opaque, unshaded. 0 B."
  `(let* ((%e (camera-eye *camera*)) (%x ,x) (%y ,y) (%z ,z) (%ux ,ux) (%uy ,uy) (%uz ,uz)
          (%dx (- (aref %e 0) %x)) (%dy (- (aref %e 1) %y)) (%dz (- (aref %e 2) %z))
          (%d (f-max 1f-3 (f-hypot %dx %dy %dz))) (%p (f-min 0.1f0 (* 0.5f0 %d))) (%sc (/ (- %d %p) %d))
          (%x (+ %x (* %p (/ %dx %d)))) (%y (+ %y (* %p (/ %dy %d)))) (%z (+ %z (* %p (/ %dz %d))))
          (%sx (- (* %uy %dz) (* %uz %dy))) (%sy (- (* %uz %dx) (* %ux %dz))) (%sz (- (* %ux %dy) (* %uy %dx)))
          (%w (/ (* ,w %sc) (f-max 1f-5 (f-hypot %sx %sy %sz)))) (%f (* 0.6f0 ,len %sc)) (%b (* 0.4f0 ,len %sc)))
     (declare (type f32vec %e) (single-float %x %y %z %ux %uy %uz %dx %dy %dz %d %p %sc %sx %sy %sz %w %f %b))
     (with-fx-verts (%v %o :alpha 6)
       (vtx (+ %x (* %f %ux)) (+ %y (* %f %uy)) (+ %z (* %f %uz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
       (vtx (+ %x (* %w %sx)) (+ %y (* %w %sy)) (+ %z (* %w %sz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
       (vtx (- %x (* %b %ux)) (- %y (* %b %uy)) (- %z (* %b %uz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
       (vtx (+ %x (* %f %ux)) (+ %y (* %f %uy)) (+ %z (* %f %uz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
       (vtx (- %x (* %b %ux)) (- %y (* %b %uy)) (- %z (* %b %uz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
       (vtx (- %x (* %w %sx)) (- %y (* %w %sy)) (- %z (* %w %sz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0))))

(defun-fast vfx-hs-chain (a b sag k)
  "Kazeshini's chain from point A to point B (f32vecs), sagging SAG m at its middle (a parabola; SAG < 0: -SAG m of slack
beyond the straight span, the sag that length gives, its lowest link kept 3 cm off the floor): ink links along the curve
turned alternately, a steel glint every other one, presence K (SAG and K: literals)."
  (declare (type f32vec a b) (single-float sag k))
  (let* ((x0 (aref a 0)) (y0 (aref a 1)) (z0 (aref a 2)) (dx (- (aref b 0) x0)) (dy (- (aref b 1) y0)) (dz (- (aref b 2) z0))
         (l (f-max 0.01f0 (f-hypot dx dy dz)))
         (sag (if (< sag 0f0)                                          ; (arc ~ span + 8 s^2 / 3 span)
                  (f-min (f-sqrt (* 0.375f0 l (- sag))) (f-max 0f0 (- (* 0.5f0 (+ y0 (aref b 1))) 0.03f0)))
                  sag))
         (n (min 48 (max 2 (f->i (/ (+ l (/ (* 2.67f0 sag sag) l)) 0.12f0))))) (dr (drawing-no)))
    (declare (single-float x0 y0 z0 dx dy dz l sag dr) (fixnum n))
    (dotimes (i n)
      (let* ((u (/ (+ 0.5f0 (i->f i)) (i->f n))) (s (* 4f0 sag u (- 1f0 u)))
             (px (+ x0 (* u dx))) (py (- (+ y0 (* u dy)) s)) (pz (+ z0 (* u dz)))
             (ty (- dy (* 4f0 sag (- 1f0 (* 2f0 u))))) (tl (f-max 0.001f0 (f-hypot dx ty dz)))
             (ux (/ dx tl)) (uy (/ ty tl)) (uz (/ dz tl)))
        (declare (single-float u s px py pz ty tl ux uy uz))
        (if (= *hs-chain-black* 1)
            (%hs-black-kite px py pz ux uy uz 0.13f0 (if (evenp i) 0.028f0 0.013f0))   ; (x0.7: solid black reads heavier)
            (progn
              (fx-shard px py pz ux uy uz 0.13f0 (if (evenp i) 0.04f0 0.018f0) 0.03f0 (+ (i->f i) 700f0 dr) +pal-ink+ k)
              (when (evenp i) (fx-shard px py pz ux uy uz 0.06f0 0.01f0 0.03f0 (+ (i->f i) 760f0) +pal-steel+ k :push 0.14f0)))))))
  nil)

(defun-fast %hs-coil (c)
  "SHIBARI's wrap: three turns of chain round the victim's body, centred at C (an f32vec: his feet), 0.42 m round, at
0.8 / 1.05 / 1.3 m (eight chords each, VFX-HS-CHAIN). 0 B."
  (declare (type f32vec c))
  (let ((a *hs-w*) (b *hs-q*))
    (declare (type f32vec a b))
    (dotimes (ring 3)
      (dotimes (i 8)
        (let* ((h (+ 0.8f0 (* 0.25f0 (i->f ring)))) (a0 (* 0.7853982f0 (+ (i->f i) (* 0.33f0 (i->f ring)))))
               (a1 (+ a0 0.7853982f0)))
          (declare (single-float h a0 a1))
          (setf (aref a 0) (+ (aref c 0) (* 0.42f0 (f-sin a0))) (aref a 1) (+ h (* 0.04f0 (i->f i)))
                (aref a 2) (+ (aref c 2) (* 0.42f0 (f-cos a0)))
                (aref b 0) (+ (aref c 0) (* 0.42f0 (f-sin a1))) (aref b 1) (+ h (* 0.04f0 (i->f (1+ i))))
                (aref b 2) (+ (aref c 2) (* 0.42f0 (f-cos a1))))
          (vfx-hs-chain a b 0f0 0.9f0)))))
  nil)

(defun-fast %hs-point (out code jm pos fa anchor vpos)
  "OUT := one of the left sickle's points: CODE 0 the left fist (:weapon-l), 1 the thrown grip (FA[1] - the sickle's length
along his facing FA[0], 1.1 m up: its point at FA[1]), 2 the anchor (hooked: the victim's chest when he is within
*HS-HOOK-R* of it, else on the ground), 3 the windmill's circle (1.9 m round him, 1.7 m up, the fx clock), 4 the sim hand
(HS-HAND's point: the pulls' chain end), 5 the grip under the point the draw hook placed (*HS-PT*: the Shikai's windmill,
SHIBARI's wrap)."
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
      (5 (let ((p *hs-pt*)) (declare (type f32vec p)) (replace out p)))
      (t (setf (aref out 0) (+ (aref pos 0) (* (the single-float *hs-hand-ahead*) fx))
               (aref out 1) (+ (aref pos 1) (the single-float *hs-hand-up*))
               (aref out 2) (+ (aref pos 2) (* (the single-float *hs-hand-ahead*) fz))))))
  nil)

(defun-fast %hs-place! (m v fa spin)
  "M := the flying sickle's world matrix: its grip at V, turned to his facing FA[0], its blade pitched forward (SPIN 0),
tumbling with the fx clock (SPIN 1), or spun flat about its blades' crossing (SPIN 2: the Shikai's thrown disc, the
crossing 0.6 m short of V's point, so its far edge stays within 0.15 m of it). M4-EULER!'s layout, inline (its float
arguments would box)."
  (declare (type f32vec m v fa) (fixnum spin))
  (if (= spin 2)
      (let* ((a (+ (aref fa 0) (* 25f0 (fx-clock)))) (yx (- (f-sin a))) (yz (- (f-cos a)))
             (fx (- (f-sin (aref fa 0)))) (fz (- (f-cos (aref fa 0))))
             (cx (+ (aref v 0) (* 0.15f0 fx))) (cz (+ (aref v 2) (* 0.15f0 fz))))   ; (V's point 0.75 ahead: the crossing 0.6)
        (declare (single-float a yx yz fx fz cx cz))
        (setf (aref m 0) 0f0 (aref m 1) -1f0 (aref m 2) 0f0 (aref m 3) 0f0
              (aref m 4) yx (aref m 5) 0f0 (aref m 6) yz (aref m 7) 0f0
              (aref m 8) (- yz) (aref m 9) 0f0 (aref m 10) yx (aref m 11) 0f0
              (aref m 12) (- cx (* 0.5f0 yx)) (aref m 13) (aref v 1) (aref m 14) (- cz (* 0.5f0 yz)) (aref m 15) 1f0))
      (let* ((yaw (aref fa 0)) (pitch (if (= spin 0) -1.5708f0 (* 9f0 (fx-clock))))
             (cy (f-cos yaw)) (sy (f-sin yaw)) (cp (f-cos pitch)) (sp (f-sin pitch)))
        (declare (single-float yaw pitch cy sy cp sp))
        (setf (aref m 0) cy (aref m 1) 0f0 (aref m 2) (- sy) (aref m 3) 0f0
              (aref m 4) (* sy sp) (aref m 5) cp (aref m 6) (* cy sp) (aref m 7) 0f0
              (aref m 8) (* sy cp) (aref m 9) (- sp) (aref m 10) (* cy cp) (aref m 11) 0f0
              (aref m 12) (aref v 0) (aref m 13) (aref v 1) (aref m 14) (aref v 2) (aref m 15) 1f0)))
  nil)

(defun-fast %hs-draw (jm pos fa anchor vpos a b n d tint lightning lo)
  "The left sickle and the chain: in the left fist (A = B = 0: the chain slack between the fists), else at the point
between codes A and B at N / D (%HS-POINT), its point out along his facing, the chain to it from the right fist; the
pulls (B 4) draw the chain along HS-CHAIN-SEG's segment (anchor to the sim hand). LIGHTNING 1: TSUZURI RAIDEN's bolt along
his 6.5 m line. LO, the Shikai's looks (bits; 0: B2a's, the Bankai's): 1 the right sickle let out (HS-POSE: the chain from
its butt to the right fist), 2 the left one (*HS-ML*, *HS-LO* [8-14]), 4 the chain from the right rod through the left fist
to the out sickle (the thrower's hand), 64 the flat spinning disc (a flight), 8 the garrote (the slack through the victim's neck), 16 the
pull's tail (the sim hand to the left fist), 32 SHIBARI's wrap round the victim, 128 MAKI's curl (the flight bowed 1.1 m
out to his left midway: the left-to-right wrap)."
  (declare (type f32vec jm pos fa anchor vpos) (fixnum a b n d lightning lo))
  (let ((v *hs-v*) (w *hs-w*) (q *hs-q*) (m *hs-m*) (m2 *hs-m2*) (l *hs-lo*))
    (declare (type f32vec v w q m m2 l))
    (joint-point! w jm (ji :weapon-r) 0f0 0f0 0.22f0)                 ; the right rod's forked butt: the chain fixes there
    (when (logtest lo 1)                                              ; let out: butt -> right fist; the slack from the fist
      (setf (aref q 0) (aref l 1) (aref q 1) (aref l 2) (aref q 2) (aref l 3))
      (vfx-hs-chain w q 0.06f0 0.9f0)
      (replace w q))
    (if (and (= a 0) (= b 0))
        (progn
          (if (logtest lo 2)
              (progn (draw-weapon :kazeshini *hs-ml* :tint tint)
                     (setf (aref v 0) (aref l 9) (aref v 1) (aref l 10) (aref v 2) (aref l 11)
                           (aref q 0) (aref l 12) (aref q 1) (aref l 13) (aref q 2) (aref l 14))
                     (vfx-hs-chain v q 0.06f0 0.9f0))                 ; (V: the left fist, the middle's far end)
              (let ((j (* 16 (ji :weapon-l))))
                (replace m2 jm :start2 j :end2 (+ j 16))
                (m4-mul! m m2 *weapon-m*)
                (draw-weapon :kazeshini m :tint tint)
                (joint-point! v jm (ji :weapon-l) 0f0 0f0 0.22f0)))   ; butt to butt, 1.2 m of slack (§11.1)
          (cond ((logtest lo 8)                                       ; the garrote: through his neck
                 (setf (aref q 0) (aref vpos 0) (aref q 1) (+ (aref vpos 1) 1.45f0) (aref q 2) (aref vpos 2))
                 (vfx-hs-chain w q 0.02f0 0.9f0) (vfx-hs-chain q v 0.02f0 0.9f0))
                ((logtest lo 3) (vfx-hs-chain w v -0.5f0 0.9f0))
                (t (vfx-hs-chain w v -1.2f0 0.9f0))))
        (let ((u (f-clamp (/ (i->f n) (i->f (max 1 d))) 0f0 1f0)))
          (declare (single-float u))
          (%hs-point v a jm pos fa anchor vpos)
          (%hs-point q b jm pos fa anchor vpos)
          (dotimes (i 3) (setf (aref v i) (+ (aref v i) (* u (- (aref q i) (aref v i))))))
          (when (logtest lo 128)                                      ; MAKI's curl: out to his left midway, in from there
            (let ((k (* 1.1f0 (f-sin (* 3.1415927f0 u)))) (yaw (aref fa 0)))
              (declare (single-float k yaw))
              (setf (aref v 0) (- (aref v 0) (* k (f-cos yaw))) (aref v 2) (+ (aref v 2) (* k (f-sin yaw))))))
          (%hs-place! m v fa (cond ((and (logtest lo 64) (/= a 2) (/= b 2) (/= b 4)) 2) ((= a b) 0) (t 1)))
          (draw-weapon :kazeshini m :tint tint)
          (if (and (logtest lo 64) (/= a 2) (/= b 2) (/= b 4))         ; (the disc: its butt where it spins)
              (dotimes (i 3) (setf (aref v i) (+ (aref m (+ 12 i)) (* -0.22f0 (aref m (+ 4 i))))))
              (dotimes (i 3) (setf (aref v i) (- (aref v i) (* 0.22f0 (aref m (+ 4 i)))))))   ; (its butt: the rod is M's +Y)
          (if (logtest lo 4)                                          ; the thrower's hand: right rod -> left fist -> sickle
              (progn (joint-point! q jm (ji :weapon-l) 0f0 0f0 0f0)
                     (vfx-hs-chain w q -0.4f0 0.9f0)
                     (if (= a b) (vfx-hs-chain q v 0.12f0 0.9f0) (vfx-hs-chain q v 0.04f0 0.9f0)))
              (if (= a b) (vfx-hs-chain w v 0.12f0 0.9f0) (vfx-hs-chain w v 0.04f0 0.9f0)))
          (when (= b 4)                                               ; the pull: the chain taut along the sim's segment
            (setf (aref v 0) (aref anchor 0) (aref v 1) (the single-float *hs-anchor-up*) (aref v 2) (aref anchor 1))
            (%hs-point q 4 jm pos fa anchor vpos)
            (vfx-hs-chain v q 0f0 0.7f0)
            (when (logtest lo 16)                                     ; (and on, over his guiding arm, to the hauling fist)
              (joint-point! v jm (ji :weapon-l) 0f0 0f0 0f0)
              (vfx-hs-chain q v 0.05f0 0.8f0)))
          (when (logtest lo 32) (%hs-coil vpos))))
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

(defun-fast %hs-kaza-point (out pos fa sf)
  "OUT := the Shikai windmill's sickle grip at move frame SF (KAZAGURUMA S 6, A 60, R 14), its point R m out: let out low and
swung round (f0-6), the push at the waist 2.0 m round him (the volume's r: f6-9), lifted to circle flat above his head
1.6 m round, 2.3 m up (f10-16 on), one turn in 12 f (counter-clockwise from above); FA[0] := its bearing (the sickle drawn
pointing out, %HS-PLACE! spin 0). 0 B."
  (declare (type f32vec out pos fa) (fixnum sf))
  (let* ((f (i->f sf)) (k (f-clamp (/ (- f 9f0) 7f0) 0f0 1f0)) (e (* k k (- 3f0 (* 2f0 k))))
         (r (if (< f 6f0) (+ 0.8f0 (* 1.2f0 (/ f 6f0))) (- 2.0f0 (* 0.4f0 e))))
         (h (+ 0.95f0 (* 1.35f0 e))) (a (+ (aref fa 0) 1.5707964f0 (* 0.5235988f0 f))) (g (- r 0.75f0)))
    (declare (single-float f k e r h a g))
    (setf (aref fa 0) a
          (aref out 0) (+ (aref pos 0) (* g (- (f-sin a)))) (aref out 1) h (aref out 2) (+ (aref pos 2) (* g (- (f-cos a))))))
  nil)

(declaim (type f32vec *hs-g*))
(defvar *hs-g* (make-f32 4) "HISAGI-DRAW's readings (%HS-GEO!): [0] the opponent's distance, [1] how far ahead of him he is.")
(defun-fast %hs-geo! (an p q fa tr shikai rdt)
  "HISAGI-DRAW's float work (a plain DEFUN's arithmetic and float reads box): his facing (TR his transform) into FA[0] and
*HS-YAW*, FA[3] := SHIKAI (1 / 0), RDT (the draw's effect seconds) kept for the next pose (HS-POSE), his clip frame into
*HS-FR*, the opponent's distance and how far ahead he stands into *HS-G*, his chest (1.1 m up) into *HS-PT*;
the flags (a fixnum): 1 the right let-out is out, 2 the opponent 0.5-5.5 m ahead, 4 within 1.8 m, 8 the clip frame < 24. 0 B."
  (declare (type f32vec p q fa) (fixnum shikai))
  (let* ((g *hs-g*) (pt *hs-pt*) (dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2)))
         (yaw (the single-float (transform-yaw tr))))
    (declare (type f32vec g pt) (single-float dx dz yaw))
    (setf (aref fa 0) yaw (aref fa 3) (if (= shikai 1) 1f0 0f0)
          (aref *hs-grip-v* 2) (if (typep rdt 'single-float) (the single-float rdt) 0.0167f0)
          (aref *hs-fr* 0) (* 60f0 (the single-float (anim-time an))) (aref *hs-yaw* 0) yaw
          (aref g 0) (f-hypot dx dz) (aref g 1) (- (* dx (- (f-sin yaw))) (* dz (f-cos yaw)))
          (aref pt 0) (aref q 0) (aref pt 1) (+ (aref q 1) 1.1f0) (aref pt 2) (aref q 2))
    (logior (if (> (aref *hs-lo* 0) 0f0) 1 0) (if (< 0.5f0 (aref g 1) 5.5f0) 2 0) (if (< (aref g 0) 1.8f0) 4 0)
            (if (< (aref *hs-fr* 0) 24f0) 8 0))))
(defun-fast %hs-left-out-p () "The left let-out is out (*HS-LO* [8] > 0): 1 / 0. 0 B." (if (> (aref *hs-lo* 8) 0f0) 1 0))

;;; ---------------------------------------------------------------- the Bankai 風死絞縄's look (DUEL_HISAGI §21.6)
;; Presentation only (motion-refs §4.3; `BBSHisagi_s_Bankai`, `Hisagi_s_Bankai_CFYOW`): both modes wear the Shikai's body
;; with his own chain coiled round the neck and the right upper arm and forearm (:HISAGI-BANKAI, a BODY-VARIANT: the same
;; rig and hurt cylinder), keep the Shikai's Kazeshini in both hands (the user, 2026-10-17: 「不是 卍解的刀造型跟始解一樣」),
;; and HISAGI-DRAW adds (%HS-ORB-DRAW) the jet-black orb of chains high overhead (out of the match camera's frame), a
;; curtain of chains hanging from it at his left and right down to waist-to-floor height, a bundle of four chains twisted
;; together from it down to his neck (and its slack tail), a pale light patch under it (canon's inverted shadow) and, in a
;; bind, the same bundle tied round the opponent's neck (the noose). The orb sits off to his right (the bundles lean off
;; the line between the two fighters from the behind camera): over his right shoulder in the ranged mode, over the pair's
;; midpoint in the bind. (The user, 2026-10-17: 「鎖鏈球可以高到超出鏡頭，自身周遭有許多從鎖鏈球垂下來的鎖鏈，其中有數條鎖鏈捆成束後捆在
;; 自己（與對手）的脖子上」.)
(defun hs-coil-parts (r y0 y1 turns n)
  "N chain links on a helix of radius R round the joint's up axis from Y0 to Y1 (TURNS turns), alternately flat on the
coil and edge-on, every fourth a steel glint: shape specs for BODY-VARIANT."
  (loop for i below n
        for u = (/ (+ i 0.5) n) for a = (* 2 pi turns u) for flat = (evenp i)
        collect (list :box 0.034 (if flat 0.02 0.007) (if flat 0.007 0.018)
                      :at (list (* r (sin a)) (+ y0 (* u (- y1 y0))) (* r (cos a)))
                      :rot (list (- (* (/ 180 pi) a)) 0 0) :c (if (zerop (mod i 4)) :link :chain))))

(body-variant :hisagi-bankai :hisagi
  :palette '((:chain #x1A1A20) (:link #x5A5A66))
  :parts (list (cons :neck (hs-coil-parts 0.062 0.0 0.125 3 33))
               (cons :upper-arm-r (hs-coil-parts 0.066 -0.04 -0.27 3.5 40))
               (cons :lower-arm-r (hs-coil-parts 0.057 -0.02 -0.235 4 40))))

(defun hs-mb-orb (mb)
  "The orb (motion-refs §4.3: \"a jet-black orb made of chains\"): a black core 0.8 m round wound with eleven loops of
chain 0.84-0.92 m round in planes tilted the golden angle apart (a tangle), 28 links a loop, alternately flat and
edge-on, every third a steel glint."
  (mbc mb #x09090C)
  (mb-sphere mb 0.8 :segments 16 :rings 12)
  (dotimes (k 11)
    (let ((r (+ 0.84 (* 0.008 (mod (* k 7) 11)))))
      (with-xform (mb (xform :yaw (* k 2.39996) :pitch (acos (- 1 (/ (* 2 (+ k 0.5)) 11)))))
        (dotimes (i 28)
          (mbc mb (if (zerop (mod i 3)) #x3C3C46 #x16161C))
          (with-xform (mb (xform :yaw (* 2 pi (/ i 28))))
            (with-xform (mb (xform :z r))
              (mb-box mb 0.1 (if (evenp i) 0.05 0.018) (if (evenp i) 0.018 0.045)))))))))

(defweapon :hs-orb (:length 0.9)
  (:solid (hs-mb-orb mb)))

(declaim (type f32vec *hs-orb-v* *hs-om* *hs-oc* *hs-b0* *hs-b1*))
(defvar *hs-orb-v* (make-f32 8)
  "Each side's orb centre as last drawn ([0-2] P1's, [3-5] P2's) and [6-7] whether it has one (1: eased from there).")
(defvar *hs-om* (m4) "The orb's world matrix.")
(defvar *hs-oc* (make-f32 3) "The orb's centre this frame.")
(defvar *hs-b0* (make-f32 3) "A bundle segment's near end (%HS-BUNDLE).")
(defvar *hs-b1* (make-f32 3) "A bundle segment's far end (%HS-BUNDLE).")
(defparameter *hs-orb-scale* 1.7
  "The orb's drawn size: its mesh (a 0.8 m core, chain loops to ~0.95 m) x 1.7, so ~1.6 m round (Brave Souls draws it
larger than him; DUEL_HISAGI §21.6: the lead's proposal, 2026-10-17; canon gives no size).")
(defparameter *hs-orb-h* 8.0
  "The orb's centre height (m), both modes: overhead and out of the 2 m / 6 m behind camera's frame (the user, 2026-10-17:
「鎖鏈球可以高到超出鏡頭」); its chains come down into the frame.")
(defparameter *hs-orb-side* 1.5 "How far to his right the orb hangs (m), both modes: the neck bundles lean off the line
between the fighters from the behind camera.")
(defparameter *hs-orb-back* 0.5 "How far behind him the orb hangs in the ranged mode (m); a bind puts it over the midpoint.")
(defparameter *hs-curtain*
  '((70.0 1.5 0.95) (100.0 1.7 0.45) (125.0 1.45 0.75) (150.0 1.65 0.3) (210.0 1.6 0.6) (235.0 1.45 0.9) (260.0 1.7 0.35)
    (290.0 1.5 0.8))
  "The chains hanging from the orb round him (the user, 2026-10-17: 「自身周遭有許多從鎖鏈球垂下來的鎖鏈」; 「攻擊可以從周遭垂下來的鎖鏈
或自己頸部的鎖鏈發動」): (bearing in degrees from his facing, counter-clockwise from above; distance from his feet, m; the
free end's height, m). Two curtains, at his left and his right: none ahead (the opponent) and none behind (the behind
camera's line), every end 1.45-1.7 m from him at 0.3-0.95 m up (waist to floor: a clip can snap one out level).")
(declaim (type f32vec *hs-curtain-v*))
(defvar *hs-curtain-v* (coerce (mapcar #'f32 (apply #'append *hs-curtain*)) 'f32vec) "*HS-CURTAIN* flat, as floats.")

(defun-fast %hs-bundle (top bot n tw r0 r1)
  "N chains twisted round each other from TOP down to BOT (f32vecs): a helix of TW turns, its radius R0 at the bottom
(tight round a neck) to R1 at the top (fanning out under the orb, growing as u^3), 14 straight pieces a chain, each drawn
by VFX-HS-CHAIN (R0 R1 TW: f32vec-free single floats, literals at the call). 0 B."
  (declare (type f32vec top bot) (fixnum n) (single-float tw r0 r1))
  (let* ((p *hs-b0*) (q *hs-b1*)
         (dx (- (aref top 0) (aref bot 0))) (dy (- (aref top 1) (aref bot 1))) (dz (- (aref top 2) (aref bot 2)))
         (l (f-max 0.1f0 (f-hypot dx dy dz))) (ux (/ dx l)) (uy (/ dy l)) (uz (/ dz l))
         (hl (f-hypot ux uz)) (ax (if (> hl 0.01f0) (/ uz hl) 1f0)) (az (if (> hl 0.01f0) (/ (- ux) hl) 0f0))
         (bx (* uy az)) (by (- (* uz ax) (* ux az))) (bz (- (* uy ax))))      ; (A horizontal, B = U x A)
    (declare (type f32vec p q) (single-float dx dy dz l ux uy uz hl ax az bx by bz))
    (dotimes (c n)
      (dotimes (i 15)
        (let* ((u (/ (i->f i) 14f0)) (ph (+ (* 6.2831855f0 tw u) (/ (* 6.2831855f0 (i->f c)) (i->f n))))
               (r (+ r0 (* (- r1 r0) u u u))) (cp (* r (f-cos ph))) (sp (* r (f-sin ph))))
          (declare (single-float u ph r cp sp))
          (setf (aref q 0) (+ (aref bot 0) (* u dx) (* cp ax) (* sp bx))
                (aref q 1) (+ (aref bot 1) (* u dy) (* sp by))
                (aref q 2) (+ (aref bot 2) (* u dz) (* cp az) (* sp bz)))
          (when (> i 0) (vfx-hs-chain p q 0f0 0.9f0))
          (replace p q)))))
  nil)

(defun-fast %hs-tie (top jm)
  "A neck bundle (§21.6): four chains twisted together (%HS-BUNDLE) from TOP (an f32vec: the orb's bottom) down to a knot
0.24 m above and 0.2 m behind the neck joint of the joints JM (clear of the head), then each of the four from the knot to
one side of the neck (the noose's tie). Uses *HS-W* and *HS-Q*. 0 B."
  (declare (type f32vec top jm))
  (let ((w *hs-w*) (q *hs-q*))
    (declare (type f32vec w q))
    (joint-point! w jm (ji :neck) 0f0 0.24f0 0.2f0)
    (%hs-bundle top w 4 3.0f0 0.05f0 0.45f0)
    (joint-point! q jm (ji :neck) 0.075f0 0.07f0 0f0) (vfx-hs-chain w q 0.03f0 0.9f0)
    (joint-point! q jm (ji :neck) -0.075f0 0.07f0 0f0) (vfx-hs-chain w q 0.03f0 0.9f0)
    (joint-point! q jm (ji :neck) 0f0 0.07f0 0.075f0) (vfx-hs-chain w q 0.02f0 0.9f0)
    (joint-point! q jm (ji :neck) 0f0 0.07f0 -0.075f0) (vfx-hs-chain w q 0.03f0 0.9f0)))

(defun-fast %hs-orb-draw (jm pos fa opos ojm side bound tint)
  "The Bankai's orb (DUEL_HISAGI §21.6), drawn by HISAGI-DRAW in both modes: its centre *HS-ORB-H* up and *HS-ORB-SIDE* to
his right, *HS-ORB-BACK* behind him (BOUND 1, a bind: over the pair's midpoint), eased there at 2.5 /s (placed at once on
a still or a jump > 8 m; SIDE 0 / 1 his slot in *HS-ORB-V*), swaying, turning slowly, *HS-ORB-SCALE* x its mesh; the pale
light patch under it (the inverted shadow); the curtain of chains hanging from it round him (*HS-CURTAIN*, moving with
him); the bundle of four chains twisted together from it down to the back of his neck (JM his joints, POS his feet, FA[0]
his facing) and its slack tail down his back; in a bind the same bundle to the opponent's neck (OPOS, OJM), tied twice
round it. TINT: his body's (the mirror's P2). 0 B."
  (declare (type f32vec jm pos fa opos ojm) (fixnum side bound))
  (let* ((ov *hs-orb-v*) (c *hs-oc*) (m *hs-om*) (v *hs-v*) (w *hs-w*) (q *hs-q*)
         (tm (fx-clock)) (yaw (aref fa 0)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw)))
         (sd (the single-float *hs-orb-side*)) (bk (the single-float *hs-orb-back*)) (sc (the single-float *hs-orb-scale*))
         (tx (if (= bound 1) (+ (* 0.5f0 (+ (aref pos 0) (aref opos 0))) (* sd rx)) (+ (aref pos 0) (* sd rx) (- (* bk fx)))))
         (tz (if (= bound 1) (+ (* 0.5f0 (+ (aref pos 2) (aref opos 2))) (* sd rz)) (+ (aref pos 2) (* sd rz) (- (* bk fz)))))
         (tx (+ tx (* 0.1f0 (f-sin (+ (* 0.6f0 tm) (* 2f0 (i->f side)))))))
         (ty (+ (the single-float *hs-orb-h*) (* 0.08f0 (f-sin (* 0.9f0 tm)))))
         (o (* 3 side)) (dt (aref *hs-grip-v* 2))
         (ex (- tx (aref ov o))) (ey (- ty (aref ov (+ o 1)))) (ez (- tz (aref ov (+ o 2))))
         (k (if (or (<= dt 0f0) (< (aref ov (+ 6 side)) 0.5f0) (> (+ (* ex ex) (* ey ey) (* ez ez)) 64f0)) 1f0
                (f-min 1f0 (* 2.5f0 dt))))
         (s (* 0.25f0 tm)) (cs (* sc (f-cos s))) (ss (* sc (f-sin s))) (bot 0f0))
    (declare (type f32vec ov c m v w q) (fixnum o)
             (single-float tm yaw fx fz rx rz sd bk sc tx tz ty dt ex ey ez k s cs ss bot))
    (setf (aref ov o) (+ (aref ov o) (* k ex)) (aref ov (+ o 1)) (+ (aref ov (+ o 1)) (* k ey))
          (aref ov (+ o 2)) (+ (aref ov (+ o 2)) (* k ez)) (aref ov (+ 6 side)) 1f0
          (aref c 0) (aref ov o) (aref c 1) (aref ov (+ o 1)) (aref c 2) (aref ov (+ o 2))
          bot (- (aref c 1) (* 0.75f0 sc)))
    (setf (aref m 0) cs (aref m 1) 0f0 (aref m 2) (- ss) (aref m 3) 0f0
          (aref m 4) 0f0 (aref m 5) sc (aref m 6) 0f0 (aref m 7) 0f0
          (aref m 8) ss (aref m 9) 0f0 (aref m 10) cs (aref m 11) 0f0
          (aref m 12) (aref c 0) (aref m 13) (aref c 1) (aref m 14) (aref c 2) (aref m 15) 1f0)
    (draw-weapon :hs-orb m :tint tint)
    (setf *hs-chain-black* 1)
    ;; the inverted shadow: a pale patch on the ground under it
    (%sector-verts :add 20 (aref c 0) 0f0 (aref c 2) 0f0 (* 1.1f0 sc) 0f0 3.1415927f0 0.2f0 0.21f0 0.2f0 0.5f0)
    (let ((cv *hs-curtain-v*))                                          ; the curtain round him
      (declare (type f32vec cv))
      (dotimes (j (floor (length cv) 3))
        (let* ((b (aref cv (* 3 j))) (y (aref cv (+ 2 (* 3 j))))
               (a (+ yaw (* 0.017453292f0 b))) (r (aref cv (+ 1 (* 3 j))))
               (gx (+ (aref pos 0) (* r (- (f-sin a))))) (gz (+ (aref pos 2) (* r (- (f-cos a)))))
               (sw (* 0.05f0 (f-sin (+ (* 1.1f0 tm) b)))))
          (declare (single-float b y a r gx gz sw))
          (setf (aref w 0) (+ gx sw) (aref w 1) y (aref w 2) gz
                (aref v 0) (+ (aref c 0) (* 0.6f0 (- gx (aref c 0)))) (aref v 1) bot
                (aref v 2) (+ (aref c 2) (* 0.6f0 (- gz (aref c 2)))))
          (dotimes (i 3) (setf (aref q i) (* 0.5f0 (+ (aref v i) (aref w i)))))   ; (two pieces: VFX-HS-CHAIN's 48 links
          (vfx-hs-chain v q 0f0 0.9f0) (vfx-hs-chain q w 0f0 0.9f0))))          ;  span ~5.8 m)
    ;; his neck bundle: four chains twisted from the orb down behind his head, tied round his neck; its slack tail
    (setf (aref v 0) (aref c 0) (aref v 1) bot (aref v 2) (aref c 2))
    (%hs-tie v jm)
    (joint-point! w jm (ji :neck) 0f0 0.07f0 0.06f0)
    (joint-point! v jm (ji :spine) 0.12f0 -0.05f0 0.2f0)
    (vfx-hs-chain w v 0.15f0 0.9f0)
    (when (= bound 1)                                                  ; the noose: the same bundle round his neck
      (setf (aref v 0) (aref c 0) (aref v 1) bot (aref v 2) (aref c 2))
      (%hs-tie v ojm)
      (joint-point! w ojm (ji :neck) 0f0 0.07f0 0f0)
      (dotimes (i 20)
        (let* ((a (* 0.62831855f0 (i->f i))) (ca (f-cos a)) (sa (f-sin a)) (y (if (< i 10) -0.015f0 0.02f0)))
          (declare (single-float a ca sa y))
          (%hs-black-kite (+ (aref w 0) (* 0.085f0 ca)) (+ (aref w 1) y) (+ (aref w 2) (* 0.085f0 sa)) (- sa) 0f0 ca
                          0.075f0 (if (evenp i) 0.026f0 0.012f0))))))
  (setf *hs-chain-black* 0)
  nil)

(defun hisagi-draw (e rdt)
  "His :draw hook (on the posed body): the left sickle (in his fist, flying, out at the anchor, returning, let out on its
chain), the chain, the windmill, the lightning. A look: every point is the sim's (the anchor, *HS-FLIGHTS*' reach,
HS-CHAIN-SEG's ends) or the clip's let-out (*HS-LETOUT*, at the strike's volume edge on its hit frames). The Shikai's looks
(DUEL_HISAGI §21.4) only in his base form; the Bankai's forms as B2a drew them (their clips wait for their pass) with the
Shikai's Kazeshini (the user: the same blades), plus the orb, its rope and a bind's noose (%HS-ORB-DRAW, §21.6). Nothing while the sealed sword is in
hand (the intro)."
  (let* ((f (fighter e)) (m (model e)) (st (hs e)) (mv (and (eq (fighter-state f) :move) (eq (fighter-phase f) :main) (fighter-move f)))
         (name (and mv (mv-name mv))) (sf (fighter-sf f)) (o (opp-of e)) (fa *hs-a*) (bolt 0)
         (shikai (eq (fighter-form f) :base)) (lo 0) (geo 0) (an (model-anim m)) (c (anim-clip an)) (cn (and c (clip-name c))))
    (when (and (> (model-alpha m) 0.5) (entity-alive-p o) (eq (model-weapon m) :kazeshini))
      (setf geo (%hs-geo! an (pos-of e) (pos-of o) fa (transform e) (if shikai 1 0) rdt))
      (when shikai
        (when (logtest geo 1) (setf lo 1))
        (let ((kv (hs-letout-of cn :l)))
          (when kv
            (%hs-letout! *hs-ml* (model-joints m) (ji :weapon-l) (ji :upper-arm-l) (pos-of e) *hs-yaw* kv *hs-fr* *hs-lo* 8)
            (when (= 1 (%hs-left-out-p)) (setf lo (logior lo 2))))))
      (multiple-value-bind (a b n d)
          (cond ((and shikai (eq (fighter-state f) :move) (eq (fighter-phase f) :follow))   ; the O's zip: hooked in him
                 (setf lo (logior lo 4)) (values 5 5 0 1))
                ((and shikai (fighter-follow f) (eq name :hs-kikon)) (values 0 0 0 1))   ; (the follow-up: a close cut)
                ((and shikai (eq name :hs-kaza))                       ; the windmill (S 6, A 60, R 14)
                 (let ((top (+ (mv-s mv) (mv-a mv))))
                   (%hs-kaza-point *hs-pt* (pos-of e) fa (min sf top))
                   (setf lo (logior lo 4))
                   (if (< sf top) (values 5 5 0 1) (values 5 0 (- sf top) (mv-r mv)))))
                ((and shikai (eq name :hs-shibari) (<= (- (mv-s mv) 4) sf) (< sf 52))   ; SHIBARI: cast, wrapped, heaved
                 (setf (aref fa 1) 4.85 lo (logior lo 4))
                 (if (and (fighter-contact f) (logtest geo 2)) (setf lo (logior lo 32)) (setf lo (logior lo 64)))
                 (cond ((< sf (mv-s mv)) (values 0 1 (- sf (- (mv-s mv) 4)) 4))
                       ((logtest lo 32) (values 5 5 0 1))
                       ((< sf 50) (values 1 1 0 1))
                       (t (values 1 0 (- sf 50) 2))))
                ((and mv (assoc name *hs-flights*))
                 (setf (aref fa 1) (second (assoc name *hs-flights*))
                       bolt (if (and (eq name :hs-raiden) (< (- (mv-s mv) 3) sf (+ (mv-s mv) (mv-a mv) 5))) 1 0))
                 (when shikai (setf lo (logior lo (if (eq name :hs-k2s) 196 68))))
                 (hs-flight-codes st name sf (mv-s mv) (mv-a mv)))
                ((and mv (member name *hs-pulls*))
                 (when shikai (setf lo (logior lo 16)))
                 (if (< sf (mv-s mv)) (values 2 2 0 1) (values 2 4 (- sf (mv-s mv)) (+ (mv-a mv) 2))))
                ((eq name :hs-modoshi) (when shikai (setf lo (logior lo 4))) (values 2 0 sf 6))
                ((and (not shikai) (eq name :hs-kaza) (<= (mv-s mv) sf) (< sf (+ (mv-s mv) (mv-a mv)))) (values 3 3 0 1))
                ((eq (hss-state st) :ret) (when shikai (setf lo (logior lo 4)))
                 (values 2 0 (- *hs-return-frames* (hss-ret-t st)) *hs-return-frames*))
                ((eq (hss-state st) :out) (when shikai (setf lo (logior lo 4))) (values 2 2 0 1))
                (t (when (and shikai (eq cn :hs-s-kubikake) (logtest geo 8) (logtest geo 4))
                     (setf lo (logior lo 8)))                          ; (KUBIKAKE: the slack round his neck)
                   (values 0 0 0 1)))
        (setf *hs-chain-black* (if shikai 0 1))                        ; (the Bankai's chains black: the user, 2026-10-18)
        (%hs-draw (model-joints m) (pos-of e) fa (hss-anchor st) (pos-of o) a b n d (model-tint m) bolt lo))
      (unless shikai                                                   ; the Bankai: the orb, the rope, the noose (§21.6)
        (%hs-orb-draw (model-joints m) (pos-of e) fa (pos-of o) (model-joints (model o)) (if (eq e *p1*) 0 1)
                      (if (hss-bound st) 1 0) (model-tint m))))))

(defun hisagi-look-cons-check ()
  "Debug 83901 (P1 Hisagi): bytes consed by 10 calls of his :pose hook and HISAGI-DRAW in the stance, out at the anchor, in
NAGE's hit frame, in HIKI's, in the windmill, and (the Shikai's clips, §21.4) J1's short grip, J3's two let out, KARI-OTOSHI's,
SHIBARI's wrap and KUBIKAKE's garrote, and the Bankai's look (§21.6: the orb, the rope) in the stance and
with the noose of a bind: each must be 0."
  (let* ((e *p1*) (f (fighter e)) (st (hs e)) (m (model e)) (an (model-anim m)) (c0 (anim-clip an)) (t0 (anim-time an))
         (state (fighter-state f)) (mv (fighter-move f)) (ph (fighter-phase f)) (sf (fighter-sf f)) (s0 (hss-state st))
         (ct (fighter-contact f)) (p (pos-of e)))
    (setf (aref *pose-at* 0) (aref p 0) (aref *pose-at* 1) (aref p 1) (aref *pose-at* 2) (aref p 2) (aref *pose-at* 3) (yaw-of e))
    (flet ((bytes () (let ((c0 (cons-bytes))) (dotimes (i 10) (hs-pose e m) (hisagi-draw e 0.016)) (- (cons-bytes) c0)))
           (at (name frame &optional clip) (setf (fighter-state f) :move (fighter-move f) (find-move name) (fighter-phase f) :main
                                                 (fighter-sf f) frame)
             (when clip (setf (anim-clip an) (find-clip clip) (anim-time an) (/ frame 60f0)))))
      (let* ((idle (bytes))
             (out (progn (setf (hss-state st) :out) (bytes)))
             (nage (progn (at :hs-k1 18 :hs-s-nage) (bytes)))
             (hiki (progn (at :hs-k2 21 :hs-s-hiki) (bytes)))
             (kaza (progn (at :hs-kaza 20 :hs-s-kaza) (bytes)))
             (grip (progn (setf (hss-state st) :in) (at :hs-j1 9 :hs-s-sen) (bytes)))
             (rin (progn (at :hs-j3 10 :hs-s-rin) (bytes)))
             (kari (progn (at :hs-k3 24 :hs-s-kari) (bytes)))
             (shibari (progn (at :hs-shibari 30 :hs-s-shibari) (setf (fighter-contact f) :hit) (bytes)))
             (kubi (progn (setf (fighter-contact f) ct) (at :hs-breaker 9 :hs-s-kubikake) (bytes)))
             (fm (fighter-form f)) (b0 (hss-bound st))
             (bankai (progn (setf (fighter-state f) :idle (fighter-move f) nil (fighter-form f) :bankai
                                  (anim-clip an) (find-clip :hs-stance))
                            (bytes)))
             (bind (progn (setf (hss-bound st) t) (bytes))))
        (setf (fighter-state f) state (fighter-move f) mv (fighter-phase f) ph (fighter-sf f) sf (hss-state st) s0
              (fighter-contact f) ct (anim-clip an) c0 (anim-time an) t0 (fighter-form f) fm
              (hss-bound st) b0)
        (log-msg "duel hisagi look consing (10 calls, B): stance ~d, out ~d, NAGE ~d, HIKI ~d, windmill ~d, J1 grip ~d, J3 ~d, ~
KARI-OTOSHI ~d, SHIBARI ~d, KUBIKAKE ~d, Bankai ~d, bind ~d" idle out nage hiki kaza grip rin kari shibari kubi bankai bind)))))
(pushnew '(83901 83901 hisagi-art-debug) *char-debug* :test #'equal)
(defun hisagi-art-debug (c) (declare (ignore c)) (hisagi-look-cons-check))

;;; ---------------------------------------------------------------- the clip strips (debug 83910-83964: stills, a look)
;; 83910+k picks strip slot k (*HS-STRIPS*); 83940 + 3 i + v shows its frame i of 8 (DUEL_GAMEPLAY: 0, S/3, 2S/3, S-2, S,
;; S+A, mid-recovery, end; a loop's 8 even steps) from view v (0 his right side, 1 the front, 33 degrees to his left; 2 the
;; match's behind camera, the sim frozen); 83964 lets go. He is P1 in his Shikai on a white card (views 0-1), the sim his
;; move at that frame (the draw hook's sickles and chain), a held cinematic shot; Kenpachi stands DIST m ahead (unseen
;; on the card).
(defparameter *hs-strips*
  '((:hs-s-stance nil 3.0) (:hs-s-walk-f nil 3.0) (:hs-s-run nil 3.0) (:hs-s-sen :hs-j1 2.0) (:hs-s-kaeshi :hs-j2 2.0)
    (:hs-s-rin :hs-j3 2.0) (:hs-s-kaeshi-1h :hs-j2-1h 2.0 :out) (:hs-s-rin-1h :hs-j3-1h 2.0 :out) (:hs-s-nage :hs-k1 6.0)
    (:hs-s-hiki :hs-k2 1.6 :hooked) (:hs-s-maki :hs-k2s 3.0) (:hs-s-kari :hs-k3 2.5) (:hs-s-hodoki :hs-k3h 2.0 :hooked)
    (:hs-s-modoshi :hs-modoshi 3.0 :out) (:hs-s-kaza :hs-kaza 3.0) (:hs-s-raiden :hs-raiden 6.0)
    (:hs-s-shibari :hs-shibari 3.0 :wrapped) (:hs-s-breaker nil 3.0) (:hs-s-kubikake :hs-breaker 1.0) (:hs-s-kari-aim nil 7.0)
    (:hs-s-kari-o :hs-kikon 7.0) (:hs-s-intro nil 3.0) (:hs-s-win nil 3.0))
  "83910+k: (clip move dist [sickle]): the clip, the move its frames are (NIL: idle), Kenpachi's distance, the sickle's
state (:out anchored 4 m ahead on the floor, :hooked anchored in him, :wrapped SHIBARI's contact).")
(defvar *hs-strip-k* 0 "The strip slot (83910+k).")
(defvar *hs-strip-fv* '(0 0) "The strip's frame and view (83940+3i+v).")
(defun hs-strip-frames (clip)
  "A clip's eight strip frames: a strike's 0, S/3, 2S/3, S-2, S, S+A, mid-recovery, end; else eight even steps."
  (let* ((c (find-clip clip)) (end (round (* 60 (clip-dur c)))) (s (clip-mark c :s)) (a (clip-mark c :a)))
    (if s
        (let* ((s (round (* 60 s))) (a (round (* 60 a))))
          (list 0 (round s 3) (round (* 2 s) 3) (max 0 (- s 2)) s a (+ a (round (- end a) 2)) end))
        (loop for k below 8 collect (round (* k (if (clip-loop c) (* 7/8 end) end)) 7)))))
(defun hs-strip-pose (a v)
  "Frame 0 of HS-STRIP-CINE: A in the strip slot's move at its frame (the sim state the draw hook reads), the clip there."
  (destructuring-bind (clip move dist &optional sickle) (nth *hs-strip-k* *hs-strips*)
    (declare (ignore dist))
    (let* ((f (fighter a)) (st (hs a)) (fr (nth (first *hs-strip-fv*) (hs-strip-frames clip))) (mv (and move (find-move move))))
      (setf (hss-state st) :in (fighter-contact f) nil)
      (when mv (setf (fighter-state f) :move (fighter-move f) mv (fighter-phase f) :main (fighter-sf f) fr))
      (case sickle
        (:out (let ((p (pos-of a)))
                (multiple-value-bind (x z) (hs-anchor-point (aref p 0) (aref p 2) (yaw-of a) 4.0) (hs-anchor! a x z))
                (setf (hss-state st) :out)))
        (:hooked (let ((q (pos-of v))) (hs-anchor! a (aref q 0) (aref q 2)) (setf (hss-state st) :out)))
        (:wrapped (setf (fighter-contact f) :hit)))
      (setf (model-weapon (model a)) (if (and (eq clip :hs-s-intro) (< fr 70)) :hs-sealed :kazeshini))
      (play-clip a clip :blend 0 :time (/ fr 60.0))
      (setf (anim-blend (model-anim (model a))) 0f0))))
(defcine hs-strip-cine (a v :len 240 :hold 0)
  "The strip still (83940+3i+v, views 0-1): A alone on a white card at the slot's frame, held."
  (at 0 (card :white a) (hs-strip-pose a v)
      (destructuring-bind (clip move dist &optional sickle) (nth *hs-strip-k* *hs-strips*)
        (declare (ignore clip sickle))
        (let ((far (member move '(:hs-k1 :hs-raiden :hs-kikon :hs-k2s :hs-shibari :hs-k2 :hs-k3h :hs-modoshi))))
          (if (= (second *hs-strip-fv*) 0)
              (shot-on a -90 (if far 9.5 5.2) 1.2 :look 1.0 :ahead (if far (min 3.2 (* 0.5 dist)) 0.6))
              (shot-on a 33 (if far 8.0 4.8) 1.4 :look 1.0 :ahead (if far 1.6 0.3)))
          (lens 40)))))
(defun hisagi-strip (c)
  "83910+k: the strip slot; 83940+3i+v: its frame i from view v (HS-STRIP-CINE; v 2 the match camera, frozen); 83964 lets go."
  (cond ((< c 83940) (setf *hs-strip-k* (min (- c 83910) (1- (length *hs-strips*)))))
        ((= c 83964) (abort-cine) (setf *cine-hold* nil *hitstop* 0))
        (t (multiple-value-bind (i v) (floor (- c 83940) 3)
             (setf *hs-strip-fv* (list (min i 7) v))
             (abort-cine) (setf *cine-hold* nil)
             (ensure-battle :hisagi :kenpachi)
             (when (brain *p2*) (setf (brain-off (brain *p2*)) t))
             (force-form *p1* :base)
             (place *p1* *p2* (third (nth *hs-strip-k* *hs-strips*)))
             (full-gauges! *p1*) (full-gauges! *p2*)
             (if (< v 2)
                 (progn (setf *cine-hold* t) (start-cine 'hs-strip-cine *p1* *p2*))
                 (progn (hs-strip-pose *p1* *p2*) (hitstop 100000)))))))
(pushnew '(83910 83964 hisagi-strip) *char-debug* :test #'equal)

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
;; (B2b: the Bankai's two modes show no sickle row: a meter of their own with no :draw, so the HUD neither inherits the
;; Shikai's, which overlapped the awakened forms' L COOLDOWN row, nor draws one; no sim reads it: no :start / :full-form)
(dolist (f '(:bankai :bankai-bind)) (setf (kit-meter (find-kit :hisagi f)) (list :name "FUSHI NO KOJO" :max 1)))
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

;;; ---------------------------------------------------------------- the model sheet (debug 83980-83985: stills, a look)
;; Him alone on a white card (CARD, as Kenpachi's black robe) in the stance, the camera a cinematic shot: the front, his
;; left side (the badge), the back, three-quarters from his left front, the face, and Kazeshini held out to his right
;; (the weapon close-up). The match frames are 83000 / 83001 (the behind camera, 2 / 6 m from Kenpachi).
(defpose :hs-look-weapon (:base :hs-stance)            ; the right rod held out flat to his right, the left one hanging
  (:arm-r :flex 0 :side 86 :twist 90) (:elbow-r :flex 4) (:hand-r :flex -90 :twist 0))
(defclip :hs-look-weapon (1.0 :loop t :base :hs-look-weapon) (0))
(defparameter *hs-look-shots*
  '((0 4.6 1.0 0.92 35 0.0 :hs-stance) (90 4.6 1.0 0.92 35 0.0 :hs-stance) (180 4.6 1.0 0.92 35 0.0 :hs-stance)
    (35 4.6 1.0 0.92 35 0.0 :hs-stance) (0 0.85 1.66 1.64 35 0.0 :hs-stance) (0 2.0 1.3 1.3 40 1.0 :hs-look-weapon))
  "83980+k: (angle around his facing, distance, eye height, look height, lens, aim off to the shot's left, clip).")
(defparameter *hs-look-weapon-tall* '(0 5.5 1.3 1.2 30 2.2 :hs-look-weapon)
  "83985 on a tall screen: SHOT-ON halves the aim there (a quarter up close), so farther and aimed further left.")
(defvar *hs-look-k* 0 "The model sheet's shot (83980+k).")
(defcine hs-look-cine (a v :len 240 :hold 60)
  "The model sheet's held shot *HS-LOOK-K* (*HS-LOOK-SHOTS*) of A alone on a white card, 4 s; then the match again."
  (at 0 (destructuring-bind (ang dist h look fov off clip)
            (if (and (= *hs-look-k* 5) (portrait-p)) *hs-look-weapon-tall* (nth *hs-look-k* *hs-look-shots*))
          (card :white a) (cine-clip a clip :blend 0) (shot-on a ang dist h :look look :off off) (lens fov))))
(defun hisagi-look-scene (k)
  "83980+k: P1 Hisagi 8 m from an idle Kenpachi, the model sheet's shot K (HS-LOOK-CINE)."
  (setf *cine-hold* nil *hs-look-k* (min k (1- (length *hs-look-shots*))))
  (ensure-battle :hisagi :kenpachi)
  (place *p1* *p2* 8.0)
  (start-cine 'hs-look-cine *p1* *p2*))
(pushnew '(83980 83985 hisagi-look-debug) *char-debug* :test #'equal)
(defun hisagi-look-debug (c) (hisagi-look-scene (- c 83980)))

;;; ---------------------------------------------------------------- the Bankai's model sheet (debug 83986-83994: stills, a look)
;; 83986+k, k 0-5: him awakened (the ranged mode) alone on a white card, 8 m from an idle Kenpachi, held 4 s in a cinematic
;; shot (*HS-BK-LOOK-SHOTS*): the front, his left side, the back, three-quarters from his left front, Kazeshini held out
;; to his right, and a wide shot up at the orb, its curtain and his neck bundle; 83992 / 83993 the match (the behind camera) in the
;; ranged mode 2 / 6 m from Kenpachi; 83994 a bind 2 m from him (no damage dealt: the noose, the orb over the pair).
(defparameter *hs-bk-look-shots*
  '((0 4.6 1.0 0.92 35 0.0 :hs-stance) (90 4.6 1.0 0.92 35 0.0 :hs-stance) (180 4.6 1.0 0.92 35 0.0 :hs-stance)
    (35 4.6 1.0 0.92 35 0.0 :hs-stance) (0 2.0 1.3 1.3 40 1.0 :hs-look-weapon) (-30 19.0 2.0 4.6 50 -1.5 :hs-stance))
  "83986+k: (angle around his facing, distance, eye height, look height, lens, aim off to the shot's left, clip).")
(defvar *hs-bk-look-k* 0 "The Bankai sheet's shot (83986+k).")
(defcine hs-bk-look-cine (a v :len 240 :hold 60)
  "The Bankai sheet's held shot *HS-BK-LOOK-K* (*HS-BK-LOOK-SHOTS*) of A alone on a white card, 4 s; then the match again."
  (at 0 (destructuring-bind (ang dist h look fov off clip)
            (if (and (= *hs-bk-look-k* 4) (portrait-p)) *hs-look-weapon-tall* (nth *hs-bk-look-k* *hs-bk-look-shots*))
          (card :white a) (cine-clip a clip :blend 0) (shot-on a ang dist h :look look :off off) (lens fov))))
(defun hisagi-bankai-look (c)
  "83986+k: the Bankai's model sheet shot k (0-5, HS-BK-LOOK-CINE), 6 / 7 the ranged mode 2 / 6 m from Kenpachi in the
match, 8 a bind 2 m from him; P1 Hisagi awakened (HS-AWAKEN-NOW!), P2's CPU off."
  (let ((k (- c 83986)))
    (setf *cine-hold* nil)
    (abort-cine)
    (ensure-battle :hisagi :kenpachi)
    (when (brain *p2*) (setf (brain-off (brain *p2*)) t))
    (place *p1* *p2* (case k (6 2.0) (7 6.0) (8 2.0) (t 8.0)))
    (hs-reset *p1*)
    (full-gauges! *p1*) (full-gauges! *p2*)
    (hs-awaken-now! *p1*)
    (cond ((< k 6) (setf *hs-bk-look-k* k) (start-cine 'hs-bk-look-cine *p1* *p2*))
          ((= k 8) (hs-bind-start! *p1*) (set-form *p1* :bankai-bind)))))
(pushnew '(83986 83994 hisagi-bankai-look) *char-debug* :test #'equal)

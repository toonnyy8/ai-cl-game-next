;;;; hisagi-art.lisp — HISAGI SHUHEI as art data (docs/duel/DUEL_HISAGI.md §11, §21): the Shikai's own clips (batch B3a,
;;;; §21.4: the approved slot plan §21.3, drawn to the current volumes; their :pose hook HS-POSE and HISAGI-DRAW's
;;;; let-outs) and the Bankai's (batch B3b, §21.8: both modes, exaggerated windups, the chain strikes); his body (TYBW:
;;;; the sleeveless shihakusho, the white sash, a choker and two armbands, the
;;;; lieutenant's badge on the left arm, short messy black hair, three scars down over the right eye, the 69 and the blue
;;;; stripe on the left cheek; redone to canon, DUEL_HISAGI §21 "Look as built"), Kazeshini (a 0.97 m black rod with a
;;;; crescent of two blades, one inverted, the chain from butt to butt: the right hand's is the held weapon, the left
;;;; hand's the thrown one, drawn by HISAGI-DRAW), the model-sheet scenes (83980-83985), one clip per move at the move's
;;;; frames, the chain and the sickle's flight (drawn to the sim's points: the thrown sickle's tip at the hit volume's end,
;;;; *HS-STRIKE-REACH*; the pulls' chain along HS-CHAIN-SEG's segment), the windmill, the lightning, the HUD's sickle icon,
;;;; his glyphs' name and his four cinematics (batch B5, §22.7: the awakening, the Shikai Kikon 刈れ, KOSA, KOSHU).
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

(defparameter *hs-strike-reach* '((:hs-s-nage :sickle 6.0) (:hs-s-maki :sickle 3.55) (:hs-s-kari :sickle 2.8)   ; (the Shikai's
                                  (:hs-s-kaeshi :sickle 1.4) (:hs-s-rin :sickle 1.4)                          ;  clips, §21.4;
                                  (:hs-s-nagi :sickle 6.0) (:hs-s-tobi-kaeshi :sickle 1.4) (:hs-s-tobi-rin :sickle 1.4)   ;  A1, §24.1)
                                  (:hs-k-saben :sickle 6.0) (:hs-k-kaeshi :sickle 6.0) (:hs-k-sensa :sickle 6.0)  ; (the Bankai's,
                                                                                ;  §21.8; B4a: the annuli's 4.5 / 5.0, the K placed, §22.2: the
                                  (:hs-kb-kaeshi :sickle 1.5) (:hs-kb-hikigiri :sickle 2.95)                    ;  ranged mode,
                                  (:hs-kb-makigiri :chain 2.8) (:hs-kb-shibori :chain 2.95)                     ;  the bind's)
                                  (:hs-k-hosoku :chain 4.0) (:hs-k-s-k2 :chain 4.0) (:hs-k-s-k3 :chain 4.0)    ; (A2, §24.2: the
                                  (:hs-k-g-k2 :chain 4.0) (:hs-k-g-j2 :chain 6.0) (:hs-k-g-k3 :chain 4.0)     ;  ranged route
                                  (:hs-k-g-j3 :chain 6.0)                                                     ;  links, *HS-LASHES*; §25.3: J 6, K 4)
                                  (:hs-k-saharai :chain 3.0) (:hs-kb-kojo :sickle 3.0) (:hs-kb-kaibaku :sickle 3.0))   ; (A3, §24.3)
  "Clip -> what strikes, and its drawn reach (m, the hit volume's far edge: line end + radius, or the arc's): the left
sickle thrown on its chain, drawn by HISAGI-DRAW with its point there on the hit frames (*HS-FLIGHTS*), a sickle let out
on its chain to there (*HS-LETOUT*: J2, J3, KARI-OTOSHI's two at the fan's edges; the Bankai's hand chains), or the Bankai's
chain strike's free end (*HS-BK-CHAINS*: from a hanging chain, the neck bundle or the orb; *HS-LASHES*: the ranged route
links' lashes, the first hit window's edge, gathered K2's second 8.5 m); the host FK test reads these
(as Senjumaru's *SJ-STRIKE-REACH*), and a host check ties them to those tables.")
(defparameter *hs-flights* '((:hs-k2s 3.55 t) (:hs-shibari 4.85 nil) (:hs-raiden 6.8 nil) (:hs-kikon 8.0 nil))
  "Move -> how far the left sickle's point flies out on its hit frames (m: the volume's far edge, as *HS-STRIKE-REACH*) and
whether it stays out (a throw: then at the anchor). (KARI-OTOSHI's two sickles: *HS-LETOUT*, the Shikai's clip, §21.4;
since A1, DUEL_HISAGI §24.1, K1 NAGI's sweep too: a let-out swept across the arc.)")

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

;; B2a's O 刈 KARI strike: the throw from the shoulder down the lane; played by nothing since B5 (the Shikai's :clip-map
;; names it for :hs-kikon's :clip-2; every move plays its form's own clip since §21.4 / §21.8)
(defpose :hs-nage-hit (:base :hs-stance)
  (:root :f 0.18 :u -0.12 :yaw -10) (:spine :flex 14) (:chest :twist -18)
  (:arm-l :flex 88 :side 6 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -10)
  (:arm-r :flex -20 :side 30) (:elbow-r :flex 40) (:hand-r :flex -40)
  (:thigh-l :flex 44) (:knee-l :flex 44) (:thigh-r :flex -24) (:knee-r :flex 14))
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
(defparameter *hs-grip* '((:hs-s-sen 0.25) (:hs-s-kaeshi 0.25) (:hs-s-kaeshi-1h 0.25) (:hs-s-tobi-kaeshi 0.25))
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
    (:hs-s-intro :l 70 84 84 98 0.5 2.6 25 0)
    (:hs-s-nagi :l 9 16 24 36 6.0 1.0 (160 75 -75) 0)   ; A1 (§24.1): K1 薙, flung out behind him, swept L -> R at 6.0 x the
                                                        ;  charge (the hit frames f18-21 at +38 / +19 / 0 / -19: inside +-45)
    (:hs-s-tobi-kaeshi :l 9 14 17 24 1.4 nil nil 0)     ; J2K: J2's let-out, 6 f later (out in the leap's fall)
    (:hs-s-tobi-rin :r 8 12 17 27 1.4 nil nil 0)        ; J3K: J3's two, out from the leap's top
    (:hs-s-tobi-rin :l 8 12 17 27 1.4 nil nil 0)
    (:hs-k-saben :r 9 12 16 24 6.0 1.2 nil 0)       ; the Bankai (§21.8): J1 鎖鞭, the right crescent cracked out (§25.3: 6.0)
    (:hs-k-kaeshi :l 8 11 15 23 6.0 1.2 nil 0)      ; J2 返鞭, the left lashed back (6.0)
    (:hs-k-sensa :r 10 13 17 26 6.0 1.0 nil 0)      ; J3 旋鎖, both at full chain round the half turn (6.0)
    (:hs-k-sensa :l 10 13 17 26 6.0 1.0 nil 0)
    (:hs-kb-kaeshi :l 5 8 11 18 1.5 nil nil 0)      ; the bind's J2 返弦, the left rising on a short chain
    (:hs-kb-hikigiri :r 15 18 23 32 2.95 1.1 0 0)   ; K1 引斬, the right hooked out along the line
    (:hs-kb-raiden :l 11 14 18 30 4.3 1.1 0 0)      ; SP1, the left down the line (the bolt along it)
    (:hs-kb-kojo :r 27 30 34 46 3.0 0.7 nil 0.6)    ; A3 (§24.3): L 絞縄 KOJO (S 30), the wide reap, flung from overhead
    (:hs-kb-kaibaku :r 15 18 22 34 3.0 1.0 (-120 -50 50) 0))   ; SP2 解縛擊 (S 18), a flat sweep R -> L at 3.0 m (the hit
                                                        ;  frames f18-21 at -50 / -25 / 0 / +25: inside +-70)
  "Clip -> a sickle let out of the fist on its chain: (clip side f0 f1 f2 f3 r h az bulge): it leaves the fist at clip
frame F0, is out from F1 to F2 with its point R m from his feet (horizontally), back in the fist at F3; along the fist's
bearing from his feet (AZ NIL) or AZ degrees off his facing (+ his left); H m up (NIL: on the arm's line); BULGE m higher
midway out (an overhead swing; a third of it coming back). AZ a list (A0 A1 A2): a sweep, the bearing A0 at F0 turning to
A1 at F1 (it spirals out) and on to A2 at F2 (linear), A2 coming back (K1 NAGI, A1). HS-POSE moves the right one (its
:weapon-r joint), HISAGI-DRAW draws the left one; both the chain from the fist.")
(defparameter *hs-foe-paths*
  '((:hs-s-noko (6 9 10 9 1) (9 16 9 9 3) (16 20 9 6 3) (20 24 6 6 3) (24 30 6 7 3) (30 38 7 7 1) (38 48 7 0 1))
    (:hs-s-tsui (8 18 6 8 1) (18 20 8 8 1) (20 22 8 6 4) (22 32 6 6 4) (32 46 6 0 1)))
  "A1 (DUEL_HISAGI §24.1): the Shikai K links placed on the victim (K2 鋸 NOKO, K3 墜 TSUI; HS-FOE-SEG): clip -> the left
sickle's path, segments (f0 f1 a b spin): on clip frames F0 <= f < F1 it moves from point A to point B (%HS-POINT's codes:
0 his left fist, 6 the victim's centre (HS-FOE-SEG's far end), 7 3.0 m above him, 8 3.8 m above him (the sky: the top of the match camera's frame over him), 9 the saw's
wheel round the left fist, 10 K1's sweep end: 6.0 m x the charge, 40 degrees to his right), placed by %HS-PLACE! SPIN (1
tumbling, 3 the upright saw, 4 point down); outside every segment it is in his fist. On every hit frame it is at 6 (the
host checks). NOKO: reeled in off K1's sweep (off J1, K2J: from the fist), spun up on the wheel, flung along the line at
him (S 20), the saw grinding there through A, hauled up over him, back; TSUI: hauled from him up into the sky, held, yanked
down point first onto him (S 22), held in him, hauled back.")

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

;;; A1 (DUEL_HISAGI §24, §24.1; the user, 2026-10-18: 「可以，照這個順序開始畫」): the S1 / S2 K string and the leap J drawn,
;;; each windup big and held near its peak (§21.7: 「動作要配合誇張而明顯的前搖」), the hit pose snapped in on S, an impact hold.
;; K1 薙 NAGI (18/4/22): coiled far to his left on the back foot, the left arm flung back, the right pointing at the foe
;; (held f9-15); the sickle flung out behind him at f9 spirals round his left side out to the arc's 6.0 m (x the charge)
;; and is swept left to right across his front by the chain (*HS-LETOUT*'s sweep, f16-24), the arm leading it through;
;; the follow-through across his body, then the haul back hand to chest (f24-36)
(defpose :hs-s-nagi-hit (:base :hs-s-stance)
  (:root :f 0.16 :u -0.14 :yaw -12) (:pelvis :twist -6) (:spine :flex 12) (:chest :twist -24)
  (:arm-l :flex 84 :side 42 :twist 0) (:elbow-l :flex 2) (:hand-l :flex -20)
  (:arm-r :flex -30 :side 26) (:elbow-r :flex 50) (:hand-r :flex -80)
  (:thigh-l :flex 46 :side 8) (:knee-l :flex 44) (:thigh-r :flex -28 :side 10) (:knee-r :flex 12))
(defstrike :hs-s-nagi (18 4 22 :base :hs-s-stance)
  (0)
  (4 (:root :u -0.08 :yaw 20) (:chest :twist 20) (:arm-l :flex -30 :side 40 :twist 0) (:elbow-l :flex 20)
     (:arm-r :flex 60 :side 10) (:elbow-r :flex 16) (:hand-r :flex -80))
  (9 (:root :u -0.25 :yaw 40 :f -0.08) (:pelvis :twist 10) (:spine :flex -10) (:chest :twist 40) (:neck :twist -24)
     (:arm-l :flex -70 :side 70) (:elbow-l :flex 6) (:hand-l :flex -30) (:arm-r :flex 80 :side 4) (:elbow-r :flex 8)
     (:thigh-l :flex 16 :side 12) (:knee-l :flex 30) (:thigh-r :flex -26 :side 12) (:knee-r :flex 64))       ; coiled (the tell)
  (14 (:root :u -0.28 :yaw 46 :f -0.09) (:pelvis :twist 12) (:spine :flex -12) (:chest :twist 44) (:neck :twist -28)
      (:arm-l :flex -76 :side 74) (:elbow-l :flex 4) (:hand-l :flex -30) (:arm-r :flex 82 :side 2) (:elbow-r :flex 6)
      (:thigh-l :flex 18 :side 12) (:knee-l :flex 32) (:thigh-r :flex -28 :side 12) (:knee-r :flex 70))      ; held
  (16 (:root :u -0.18 :yaw 30 :f -0.02) (:chest :twist 30) (:neck :twist -16) (:arm-l :flex -20 :side 84) (:elbow-l :flex 4))
  (:s :snap :hs-s-nagi-hit)
  (:a (:root :yaw -30 :f 0.2) (:chest :twist -40) (:arm-l :flex 116 :side -20))                            ; across, L to R
  (30 (:root :u -0.1 :yaw -24 :f 0.1) (:chest :twist -30) (:spine :flex 8) (:arm-l :flex 60 :side -10) (:elbow-l :flex 60)
      (:arm-r :flex 30 :side 20) (:elbow-r :flex 40))                                                       ; the haul
  (36 (:root :u -0.07 :yaw -8) (:chest :twist -8) (:arm-l :flex 20 :side 20) (:elbow-l :flex 40))         ; caught
  (:end :hs-s-stance))

;; K2 鋸 NOKO (S 20 from its link frame 6): the chain yanked back to the hip (the reel in), the sickle spun up on a short
;; chain in an upright wheel at his left fist (*HS-FOE-PATHS* code 9, faster each turn) while he sinks and coils, the arm
;; cocked high, then flung along the line at the victim (f16-20): the saw grinds in him (S, A); both hands haul it up over
;; him (f24-30), held up, lowered back
(defpose :hs-s-noko-hit (:base :hs-s-stance)
  (:root :f 0.14 :u -0.16 :yaw -8) (:pelvis :twist 0) (:spine :flex 14) (:chest :twist -16)
  (:arm-l :flex 90 :side 6 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -10)
  (:arm-r :flex -30 :side 24) (:elbow-r :flex 40) (:hand-r :flex -80)
  (:thigh-l :flex 48 :side 8) (:knee-l :flex 46) (:thigh-r :flex -26 :side 10) (:knee-r :flex 14))
(defpose :hs-s-noko-haul (:base :hs-s-stance)
  (:root :u -0.08 :f -0.04) (:pelvis :twist 0) (:spine :flex -14) (:chest :twist -4) (:head :flex -10)
  (:arm-l :flex 160 :side 10 :twist 0) (:elbow-l :flex 30) (:hand-l :flex -20)
  (:arm-r :flex 150 :side 16 :twist 0) (:elbow-r :flex 50) (:hand-r :flex -20)
  (:thigh-l :flex 26 :side 10) (:knee-l :flex 24) (:thigh-r :flex -8 :side 12) (:knee-r :flex 30))
(defstrike :hs-s-noko (20 4 24 :base :hs-s-stance)
  (0)
  (6 (:root :u -0.12 :yaw 14) (:spine :flex -6) (:chest :twist 18) (:arm-l :flex -20 :side 30 :twist 0) (:elbow-l :flex 70)
     (:hand-l :flex -40) (:arm-r :flex 60 :side 20) (:elbow-r :flex 40))                                 ; yanked in
  (9 (:root :u -0.16 :yaw 18) (:chest :twist 22) (:arm-l :flex 60 :side 50) (:elbow-l :flex 20) (:hand-l :flex -20)
     (:knees :flex 36))                                                                                   ; the wheel
  (11 (:arm-l :flex 70 :side 56) (:elbow-l :flex 16)) (13 (:root :u -0.19) (:arm-l :flex 56 :side 48) (:elbow-l :flex 24))
  (15 (:root :u -0.21 :yaw 22) (:chest :twist 28) (:arm-l :flex 72 :side 56) (:elbow-l :flex 14) (:knees :flex 42))   ; held
  (17 (:root :u -0.18 :yaw 20) (:spine :flex -10) (:chest :twist 26) (:arm-l :flex 124 :side 40) (:elbow-l :flex 30))  ; cocked
  (:s :snap :hs-s-noko-hit)
  (:a :hs-s-noko-hit (:root :f 0.18) (:arm-l :flex 92))
  (27 :hs-s-noko-haul)                                                                                    ; hauled up
  (32 :hs-s-noko-haul (:root :u -0.05) (:arm-l :flex 166) (:arm-r :flex 158))
  (40 (:root :u -0.06) (:arm-l :flex 60 :side 20) (:elbow-l :flex 40) (:arm-r :flex 40 :side 20) (:elbow-r :flex 50))
  (:end :hs-s-stance))

;; K3 墜 TSUI (S 22 from its link frame 8): the chain hauled hand over hand (the sickle up off the victim into the sky,
;; *HS-FOE-PATHS*), then both arms straight up gripping it, arched back on his toes, looking up (held f18-20: the tell);
;; yanked down on S, the sickle plunging point first into the victim; he ends folded in a deep squat (held to f34);
;; then hauls it back
(defpose :hs-s-tsui-up (:base :hs-s-stance)
  (:root :u 0.06) (:pelvis :twist 0) (:spine :flex -22) (:chest :twist 0) (:head :flex -20)
  (:arm-l :flex 178 :side 8 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -20)
  (:arm-r :flex 178 :side 8 :twist 0) (:elbow-r :flex 10) (:hand-r :flex -20)
  (:thigh-l :flex 6 :side 6) (:knee-l :flex 6) (:thigh-r :flex -4 :side 6) (:knee-r :flex 6))
(defpose :hs-s-tsui-hit (:base :hs-s-stance)
  (:root :f 0.04 :u -0.32) (:pelvis :twist 0) (:spine :flex 40) (:chest :twist 0) (:head :flex 10)
  (:arm-l :flex -10 :side 20 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -60)
  (:arm-r :flex -10 :side 20 :twist 0) (:elbow-r :flex 40) (:hand-r :flex -60)
  (:thigh-l :flex 60 :side 12) (:knee-l :flex 90) (:thigh-r :flex 10 :side 14) (:knee-r :flex 80))
(defstrike :hs-s-tsui (22 5 34 :base :hs-s-stance)
  (0 :hs-s-noko-haul)
  (8 :hs-s-noko-haul)
  (12 (:root :u -0.06) (:spine :flex -10) (:arm-l :flex 176 :side 6) (:elbow-l :flex 20) (:arm-r :flex 120 :side 20)
      (:elbow-r :flex 90) (:head :flex -10))                                                             ; hand over hand
  (15 (:arm-r :flex 176 :side 6) (:elbow-r :flex 20) (:arm-l :flex 130 :side 14) (:elbow-l :flex 80) (:spine :flex -16))
  (18 :hs-s-tsui-up)                                                                                     ; up (the tell)
  (20 :hs-s-tsui-up (:spine :flex -26) (:head :flex -24) (:root :u 0.08))                               ; held
  (:s :snap :hs-s-tsui-hit)
  (:a :hs-s-tsui-hit (:root :u -0.34) (:spine :flex 44))
  (34 :hs-s-tsui-hit (:root :u -0.33) (:spine :flex 42))                                                 ; the impact hold
  (44 (:root :u -0.12) (:spine :flex 12) (:arm-l :flex 40 :side 20) (:elbow-l :flex 60) (:arm-r :flex 30 :side 20)
      (:elbow-r :flex 50) (:knees :flex 30))                                                              ; hauled back
  (:end :hs-s-stance))

;; S2's leap J (KJJ's J2K, KKJ's J3K: S 14; the sim carries him in, HS-LEAP-TICK, so no :root :f): a deep crouch (the
;; tell, f3-5), the spring, tucked at the top (f9-10), then J2's / J3's own strike on landing (S 14)
(defstrike :hs-s-tobi-kaeshi (14 3 13 :base :hs-s-stance)
  (0)
  (3 (:root :u -0.32) (:spine :flex 26) (:head :flex -16) (:arms :flex -50 :side 20) (:elbows :flex 20) (:hands :flex -100)
     (:thighs :flex 70) (:knees :flex 100))                                                                 ; the crouch
  (5 (:root :u -0.36) (:spine :flex 30) (:head :flex -18) (:arms :flex -56 :side 20) (:elbows :flex 20) (:hands :flex -100)
     (:thighs :flex 76) (:knees :flex 108))                                                                 ; held
  (7 (:root :u 0.25) (:spine :flex -6) (:head :flex 0) (:arms :flex 120 :side 30) (:elbows :flex 30) (:thighs :flex -10)
     (:knees :flex 10))                                                                                     ; the spring
  (10 (:root :u 0.75 :yaw 14) (:spine :flex 10) (:chest :twist 30) (:arm-l :flex 4 :side 34 :twist 0) (:elbow-l :flex 4)
      (:hand-l :flex -90) (:arm-r :flex 120 :side 40) (:elbow-r :flex 100) (:hand-r :flex -50) (:thighs :flex 70)
      (:knees :flex 110))                                                                                   ; tucked, wound
  (12 (:root :u 0.3 :yaw 14) (:spine :flex 12) (:chest :twist 30) (:arm-l :flex 4 :side 34) (:arm-r :flex 120 :side 40)
      (:elbow-r :flex 100) (:thigh-l :flex 40) (:knee-l :flex 30) (:thigh-r :flex -10) (:knee-r :flex 20))   ; the fall
  (:s :snap :hs-s-kaeshi-hit)
  (:a (:root :yaw -16) (:chest :twist -30) (:arm-l :flex 138 :side -30))
  (24 (:root :u -0.06 :yaw -6) (:chest :twist -10) (:arm-l :flex 60 :side 20) (:elbow-l :flex 30) (:arm-r :flex 50 :side 24)
      (:elbow-r :flex 50) (:hand-r :flex -80))
  (:end :hs-s-stance))
(defstrike :hs-s-tobi-rin (14 3 18 :base :hs-s-stance)
  (0)
  (3 (:root :u -0.32 :yaw -30) (:spine :flex 26) (:chest :twist -30) (:head :flex -16) (:arm-r :flex -10 :side 70)
     (:elbow-r :flex 20) (:arm-l :flex 60 :side 60) (:elbow-l :flex 10) (:thighs :flex 70) (:knees :flex 100))   ; wound right
  (5 (:root :u -0.36 :yaw -36) (:spine :flex 30) (:chest :twist -34) (:head :flex -18) (:arm-r :flex -14 :side 70)
     (:thighs :flex 76) (:knees :flex 108))                                                                 ; held
  (7 (:root :u 0.3 :yaw -40) (:spine :flex -6) (:head :flex 0) (:thighs :flex -10) (:knees :flex 10))      ; the spring
  (9 (:root :u 0.75 :yaw 40) (:spine :flex 6) (:chest :twist -6) (:arm-r :flex 30 :side 74) (:elbow-r :flex 4)
     (:arm-l :flex -30 :side 74) (:elbow-l :flex 4) (:hands :flex -90) (:thighs :flex 70) (:knees :flex 110))   ; turning, tucked
  (10 (:root :u 0.72 :yaw 120)) (11 (:root :u 0.55 :yaw 200))
  (12 (:root :u 0.32 :yaw 270) (:thigh-l :flex 30) (:knee-l :flex 30) (:thigh-r :flex 6) (:knee-r :flex 30))
  (13 (:root :u 0.08 :yaw 300))
  (:s :snap :hs-s-rin-hit)
  (:a (:root :yaw 400) (:chest :twist 14))
  (25 (:root :yaw 372 :u -0.06) (:chest :twist 4) (:arm-r :flex 30 :side 40) (:elbow-r :flex 30) (:arm-l :flex 4 :side 34)
      (:elbow-l :flex 30))
  (:end :hs-s-stance (:root :yaw 360)))

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

;;; ---------------------------------------------------------------- the Bankai's clips (DUEL_HISAGI §21.7-§21.8)
;;; The approved slot plan (the user, 2026-10-18: 「可以，記得動作要配合誇張而明顯的前搖，來呈現出充滿張力的打擊感」; motion-refs
;;; §3.2-§3.3 with its revision), drawn to the current hit volumes: each move of both modes its own clip at its move's
;;; frames (prefix :hs-k- the ranged mode, :hs-kb- the bind; the moves name them, hisagi.lisp; the shared Breaker through
;;; the kits' :clip-map). Every windup fills the move's startup: a big readable pose reached early and held near its peak
;;; (the arm drawn far back, the body coiled away from the line, the crescent raised high), then the hit pose snapped in
;;; on S (:snap, no ease), an overshoot through the active frames and a held follow-through. What strikes: the crescents
;;; let out on their hand chains (*HS-LETOUT*) or a chain strike (*HS-BK-CHAINS*: a hanging chain hauled up taut in the
;;; windup and snapped out, the neck bundle lifted and whipped, chains dropped from the orb), its free end at the
;;; volume's edge on the hit frames (*HS-STRIKE-REACH* for the J / K links' FK test; the bind's J1 / J3 are the held rod).
;; the idle (CFYOW, motion-refs §3.2): standing straight and still, the arms hanging, the crescents point-down
(defpose :hs-k-stance ()
  (:root :u -0.02) (:pelvis :twist -4) (:spine :flex 2) (:chest :twist 0) (:neck :twist 0) (:head :flex 8)
  (:arm-r :flex 6 :side 14 :twist 0) (:elbow-r :flex 12) (:hand-r :flex -82)
  (:arm-l :flex 6 :side 14 :twist 0) (:elbow-l :flex 12) (:hand-l :flex -82)
  (:thigh-l :flex 3 :side 7) (:knee-l :flex 6) (:thigh-r :flex -3 :side 7) (:knee-r :flex 6))
(defclip :hs-k-stance (3.0 :loop t :base :hs-k-stance)
  (0) (1.5 (:root :u -0.03) (:chest :flex 1) (:head :flex 9)))
;; the walk: unhurried, the shared legs under the hanging arms; the run: the arms back, the chains streaming
(defclip :hs-k-walk-f (1.1 :loop t :base :hs-k-stance)
  (0 (:thigh-r :flex 22) (:knee-r :flex 10) (:thigh-l :flex -12) (:knee-l :flex 18) (:arm-r :flex 2) (:arm-l :flex 10))
  (0.275 (:root :u -0.03) (:thigh-r :flex 0) (:knee-r :flex 18) (:thigh-l :flex 4) (:knee-l :flex 48))
  (0.55 (:root :u -0.04) (:thigh-l :flex 22) (:knee-l :flex 10) (:thigh-r :flex -12) (:knee-r :flex 18) (:arm-r :flex 10) (:arm-l :flex 2))
  (0.825 (:root :u -0.03) (:thigh-l :flex 0) (:knee-l :flex 18) (:thigh-r :flex 4) (:knee-r :flex 48)))
(defclip :hs-k-walk-b (1.1 :loop t :base :hs-k-stance)
  (0 (:thigh-r :flex -12) (:knee-r :flex 18) (:thigh-l :flex 22) (:knee-l :flex 10))
  (0.275 (:root :u -0.03) (:thigh-r :flex 4) (:knee-r :flex 48) (:thigh-l :flex 0) (:knee-l :flex 18))
  (0.55 (:root :u -0.04) (:thigh-l :flex -12) (:knee-l :flex 18) (:thigh-r :flex 22) (:knee-r :flex 10))
  (0.825 (:root :u -0.03) (:thigh-l :flex 4) (:knee-l :flex 48) (:thigh-r :flex 0) (:knee-r :flex 18)))
(defclip :hs-k-strafe-r (0.9 :loop t :base :hs-k-stance)
  (0 (:thigh-r :side 20 :flex 5) (:thigh-l :side -2) (:knee-l :flex 22))
  (0.225 (:root :u -0.03) (:thigh-r :side 8) (:knee-r :flex 40) (:thigh-l :side 5))
  (0.45 (:thigh-r :side 4) (:thigh-l :side 16 :flex 10) (:knee-l :flex 18))
  (0.675 (:root :u -0.03) (:thigh-l :side 5) (:knee-l :flex 40) (:thigh-r :side 10)))
(defclip :hs-k-strafe-l (0.9 :loop t :base :hs-k-stance)
  (0 (:thigh-l :side 20 :flex 26) (:thigh-r :side -2) (:knee-r :flex 22))
  (0.225 (:root :u -0.03) (:thigh-l :side 8) (:knee-l :flex 40) (:thigh-r :side 12))
  (0.45 (:thigh-l :side 4) (:thigh-r :side 20 :flex -5) (:knee-r :flex 18))
  (0.675 (:root :u -0.03) (:thigh-r :side 8) (:knee-r :flex 40) (:thigh-l :side 10)))
(defpose :hs-k-run-arms (:base :hs-k-stance)
  (:arm-r :flex -56 :side 20 :twist 0) (:elbow-r :flex 10) (:hand-r :flex -122)
  (:arm-l :flex -56 :side 20 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -122) (:head :flex 0))
(defrun :hs-k-run-arms :hs-k-run :hs-k-skate-b :hs-k-slide-r :hs-k-slide-l)

;; J1 鎖鞭 SABEN (12/3/12, 4.0 m arc 100): coiled to his right on the back foot, the right arm drawn far back (held f5-10);
;; the crescent cracked out on its chain to 4 m and lashed right to left at chest height
(defpose :hs-k-saben-up (:base :hs-k-stance)
  (:root :u -0.14 :f -0.08 :yaw -30) (:pelvis :twist -12) (:spine :flex -8) (:chest :twist -44) (:neck :twist 20) (:head :flex 0)
  (:arm-r :flex -58 :side 74 :twist 0) (:elbow-r :flex 48) (:hand-r :flex -90)
  (:arm-l :flex 50 :side 24 :twist 0) (:elbow-l :flex 70) (:hand-l :flex -60)
  (:thigh-r :flex -24 :side 10) (:knee-r :flex 44) (:thigh-l :flex 30 :side 8) (:knee-l :flex 20))
(defpose :hs-k-saben-hit (:base :hs-k-stance)
  (:root :f 0.16 :u -0.12 :yaw 10) (:spine :flex 14) (:chest :twist 18) (:head :flex 0)
  (:arm-r :flex 62 :side 88 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex -34 :side 30 :twist 0) (:elbow-l :flex 36) (:hand-l :flex -70)
  (:thigh-l :flex 46 :side 8) (:knee-l :flex 42) (:thigh-r :flex -28 :side 10) (:knee-r :flex 14))
(defstrike :hs-k-saben (12 3 12 :base :hs-k-stance)
  (0)
  (5 :hs-k-saben-up)
  (10 :hs-k-saben-up (:root :yaw -34) (:chest :twist -48) (:arm-r :flex -64))                     ; held at the peak
  (:s :snap :hs-k-saben-hit)
  (:a :hs-k-saben-hit (:root :yaw 26) (:chest :twist 36) (:arm-r :flex 122 :side 84))             ; through, R to L
  (21 :hs-k-saben-hit (:root :yaw 22 :u -0.1) (:chest :twist 30) (:arm-r :flex 114 :side 78) (:elbow-r :flex 12))
  (:end :hs-k-stance))

;; J2 返鞭 KAESHI-BEN (11/3/13): the mirror: coiled to his left, the left arm drawn far back; lashed back left to right
(defpose :hs-k-kaeshi-up (:base :hs-k-stance)
  (:root :u -0.14 :f -0.06 :yaw 30) (:pelvis :twist 12) (:spine :flex -8) (:chest :twist 44) (:neck :twist -20) (:head :flex 0)
  (:arm-l :flex -58 :side 74 :twist 0) (:elbow-l :flex 48) (:hand-l :flex -90)
  (:arm-r :flex 50 :side 24 :twist 0) (:elbow-r :flex 70) (:hand-r :flex -60)
  (:thigh-l :flex -24 :side 10) (:knee-l :flex 44) (:thigh-r :flex 30 :side 8) (:knee-r :flex 20))
(defpose :hs-k-kaeshi-hit (:base :hs-k-stance)
  (:root :f 0.16 :u -0.12 :yaw -10) (:spine :flex 14) (:chest :twist -18) (:head :flex 0)
  (:arm-l :flex 62 :side 88 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -90)
  (:arm-r :flex -34 :side 30 :twist 0) (:elbow-r :flex 36) (:hand-r :flex -70)
  (:thigh-r :flex 46 :side 8) (:knee-r :flex 42) (:thigh-l :flex -28 :side 10) (:knee-l :flex 14))
(defstrike :hs-k-kaeshi (11 3 13 :base :hs-k-stance)
  (0 :hs-k-saben-hit (:root :yaw 22 :u -0.1) (:chest :twist 30) (:arm-r :flex 114 :side 78) (:elbow-r :flex 12))
  (5 :hs-k-kaeshi-up)
  (9 :hs-k-kaeshi-up (:root :yaw 34) (:chest :twist 48) (:arm-l :flex -64))
  (:s :snap :hs-k-kaeshi-hit)
  (:a :hs-k-kaeshi-hit (:root :yaw -26) (:chest :twist -36) (:arm-l :flex 122 :side 84))
  (20 :hs-k-kaeshi-hit (:root :yaw -22 :u -0.1) (:chest :twist -30) (:arm-l :flex 114 :side 78) (:elbow-l :flex 12))
  (:end :hs-k-stance))

;; J3 旋鎖 SENSA (13/3/18, 4.4 m arc 180; ender): coiled deep to his right, crouched, both arms wound back (held f5-10); the
;; half-turn cyclone: unwound to his left with both crescents at full chain sweeping the front half, a hanging chain at his
;; right swept round with them (*HS-BK-CHAINS*); held facing his left, then square
(defpose :hs-k-sensa-up (:base :hs-k-stance)
  (:root :u -0.2 :yaw -80) (:pelvis :twist -10) (:spine :flex 16) (:chest :twist -40) (:neck :twist 30) (:head :flex 0)
  (:arm-r :flex -46 :side 76 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -90)
  (:arm-l :flex 120 :side 64 :twist 0) (:elbow-l :flex 30) (:hand-l :flex -90)
  (:thigh-l :flex 46 :side 10) (:knee-l :flex 56) (:thigh-r :flex 6 :side 14) (:knee-r :flex 50))
(defpose :hs-k-sensa-hit (:base :hs-k-stance)
  (:root :u -0.1 :yaw -20) (:pelvis :twist 0) (:spine :flex 6) (:chest :twist 10) (:head :flex 0)
  (:arm-r :flex 40 :side 86 :twist 0) (:elbow-r :flex 2) (:hand-r :flex -90)
  (:arm-l :flex 40 :side 86 :twist 0) (:elbow-l :flex 2) (:hand-l :flex -90)
  (:thigh-l :flex 24 :side 10) (:knee-l :flex 30) (:thigh-r :flex 4 :side 16) (:knee-r :flex 30))
(defstrike :hs-k-sensa (13 3 18 :base :hs-k-stance)
  (0 :hs-k-kaeshi-hit (:root :yaw -22 :u -0.1) (:chest :twist -30) (:arm-l :flex 114 :side 78) (:elbow-l :flex 12))
  (5 :hs-k-sensa-up)
  (10 :hs-k-sensa-up (:root :yaw -88 :u -0.22) (:chest :twist -44))
  (:s :snap :hs-k-sensa-hit)
  (:a :hs-k-sensa-hit (:root :yaw 56) (:chest :twist 24) (:arm-l :flex 70))
  (22 :hs-k-sensa-hit (:root :yaw 84 :u -0.08) (:chest :twist 20) (:arm-r :flex 60 :side 70) (:arm-l :flex 70 :side 60))
  (:end :hs-k-stance))

;; (B3b's K1 墜鎖 TSUISA, K2 薙鎖 NAGISA and K3 落鎖 RAKUSA clips: no move's since B4a's placed K and B4c's routes; deleted
;; by batch A2, §24.2, when the route links got their own clips)

;; L 鎖払 SAHARAI (10/4/32, r 3.0 360; redrawn by batch A3, §24.3, for B4d's S 10 / R 32): the wrap, the arms crossed tight
;; over his chest, curled, the curtain drawn in tight round his body (reached by f4, held to f9); the burst: the arms flung
;; wide, arched, every hanging chain lashed out to 3 m in a ring (*HS-LASHES*), held to f18 as they fall to the floor; the
;; recovery: both fists hauled in to his chest, leaning back, the chains dragged in along the floor and lifted back into
;; the curtain (f26-44), him settling into the stance
(defpose :hs-k-saharai-up (:base :hs-k-stance)
  (:root :u -0.22) (:spine :flex 26) (:chest :twist 0) (:head :flex 20)
  (:arm-r :flex 70 :side -36 :twist 0) (:elbow-r :flex 120) (:hand-r :flex -60)
  (:arm-l :flex 76 :side -36 :twist 0) (:elbow-l :flex 120) (:hand-l :flex -60)
  (:thighs :flex 40 :side 8) (:knees :flex 56))
(defpose :hs-k-saharai-hit (:base :hs-k-stance)
  (:root :u -0.06) (:spine :flex -12) (:head :flex -10)
  (:arm-r :flex 10 :side 92 :twist 0) (:elbow-r :flex 2) (:hand-r :flex -90)
  (:arm-l :flex 10 :side 92 :twist 0) (:elbow-l :flex 2) (:hand-l :flex -90)
  (:thigh-l :flex 16 :side 22) (:knee-l :flex 16) (:thigh-r :flex -6 :side 22) (:knee-r :flex 16))
(defpose :hs-k-saharai-haul (:base :hs-k-stance)     ; the recovery: both fists hauled in to his chest, leaning back
  (:root :u -0.14 :f -0.08) (:spine :flex -12) (:head :flex 6)
  (:arm-r :flex 46 :side 30 :twist 0) (:elbow-r :flex 104) (:hand-r :flex -40)
  (:arm-l :flex 46 :side 30 :twist 0) (:elbow-l :flex 104) (:hand-l :flex -40)
  (:thigh-l :flex 30 :side 12) (:knee-l :flex 34) (:thigh-r :flex -16 :side 14) (:knee-r :flex 26))
(defstrike :hs-k-saharai (10 4 32 :base :hs-k-stance)
  (0)
  (4 :hs-k-saharai-up)
  (9 :hs-k-saharai-up (:root :u -0.26) (:spine :flex 32))                                  ; wound tight (held)
  (:s :snap :hs-k-saharai-hit)
  (12 :hs-k-saharai-hit (:spine :flex -18) (:arm-r :flex -10 :side 104) (:arm-l :flex -10 :side 104))
  (:a :hs-k-saharai-hit (:spine :flex -16) (:arm-r :flex -8 :side 100) (:arm-l :flex -8 :side 100))
  (18 :hs-k-saharai-hit (:spine :flex -14) (:arm-r :flex -4 :side 96) (:arm-l :flex -4 :side 96))   ; the impact hold
  (26 :hs-k-saharai-haul)                                                                   ; hauled in
  (32 :hs-k-saharai-haul (:root :u -0.12 :f -0.1) (:spine :flex -14) (:elbow-r :flex 112) (:elbow-l :flex 112))
  (38 :hs-k-stance (:root :u -0.08) (:spine :flex 2) (:elbows :flex 50))                    ; settling
  (:end :hs-k-stance))

;; Shift+K 綴雷電 TSUZURI RAIDEN (20/3/24, the 9 m line): the right crescent raised high, two fingers of the left on the neck
;; bundle, drawn back, the bundle lifted over him (held f7-17); the right arm thrust along the line: the bundle lances
;; down it with the bolt (*HS-BK-CHAINS*, the lightning along the line)
(defpose :hs-k-raiden-up (:base :hs-k-stance)
  (:root :u -0.06 :f -0.08 :yaw -14) (:spine :flex -14) (:chest :twist -22) (:head :flex -6)
  (:arm-r :flex 168 :side 26 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -40)
  (:arm-l :flex 128 :side -16 :twist 0) (:elbow-l :flex 146) (:hand-l :flex -10)
  (:thigh-r :flex -20 :side 8) (:knee-r :flex 30) (:thigh-l :flex 26 :side 8) (:knee-l :flex 16))
(defpose :hs-k-raiden-hit (:base :hs-k-stance)
  (:root :f 0.14 :u -0.12 :yaw 6) (:spine :flex 12) (:chest :twist 10) (:head :flex 0)
  (:arm-r :flex 90 :side 4 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex 128 :side -16 :twist 0) (:elbow-l :flex 146) (:hand-l :flex -10)
  (:thigh-l :flex 40 :side 8) (:knee-l :flex 40) (:thigh-r :flex -22 :side 10) (:knee-r :flex 16))
(defstrike :hs-k-raiden (20 3 24 :base :hs-k-stance)
  (0)
  (7 :hs-k-raiden-up)
  (17 :hs-k-raiden-up (:spine :flex -18) (:arm-r :flex 176))
  (:s :snap :hs-k-raiden-hit)
  (:a :hs-k-raiden-hit (:root :f 0.18) (:arm-r :flex 94))
  (35 :hs-k-raiden-hit (:root :f 0.17))
  (:end :hs-k-stance))

;; Shift+L 鎖雨 KUSARI-AME (30/14/30, the 10 m lane, windows f30 / f40): both arms raised to the orb, arched far back, the
;; face up (held f8-27); swept down along the lane: the first rain of chains; up again and down: the second (f40)
(defpose :hs-k-ame-up (:base :hs-k-stance)
  (:root :u 0.02 :f -0.1) (:spine :flex -24) (:chest :twist -6) (:head :flex -34)
  (:arm-r :flex 172 :side 30 :twist 0) (:elbow-r :flex 8) (:hand-r :flex -30)
  (:arm-l :flex 172 :side 30 :twist 0) (:elbow-l :flex 8) (:hand-l :flex -30)
  (:thigh-r :flex -16 :side 10) (:knee-r :flex 12) (:thigh-l :flex 18 :side 10) (:knee-l :flex 8))
(defpose :hs-k-ame-hit (:base :hs-k-stance)
  (:root :f 0.12 :u -0.22) (:spine :flex 24) (:head :flex -10)
  (:arms :flex 84 :side 26) (:elbows :flex 4) (:hands :flex -90)
  (:thigh-l :flex 44 :side 10) (:knee-l :flex 46) (:thigh-r :flex -20 :side 12) (:knee-r :flex 24))
(defstrike :hs-k-ame (30 14 30 :base :hs-k-stance)
  (0)
  (8 :hs-k-ame-up)
  (27 :hs-k-ame-up (:spine :flex -28) (:arm-r :flex 180) (:arm-l :flex 180))
  (:s :snap :hs-k-ame-hit)
  (34 :hs-k-ame-hit (:spine :flex 28))
  (38 :hs-k-ame-up (:root :u -0.04) (:spine :flex -14))                                               ; the second beat
  (40 :snap :hs-k-ame-hit (:root :u -0.26) (:spine :flex 30))
  (:a :hs-k-ame-hit (:root :u -0.27) (:spine :flex 32))
  (60 :hs-k-ame-hit (:root :u -0.26) (:spine :flex 30))
  (:end :hs-k-stance))

;; O 降鎖 KOSA: the aim (the right crescent pointed down the lane, the left hand on the neck bundle) and the strike
;; (20/2/30, the 9 m lane): coiled back, the left hand heaving the neck bundle up over his head (held f7-17); the whip:
;; the bundle snapped down the lane (*HS-BK-CHAINS*)
(defpose :hs-k-kosa-aim (:base :hs-k-stance)
  (:root :u -0.08) (:spine :flex 4) (:chest :twist -8) (:head :flex 0)
  (:arm-r :flex 88 :side 8 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -90)
  (:arm-l :flex 140 :side -12 :twist 0) (:elbow-l :flex 140) (:hand-l :flex -10))
(defclip :hs-k-kosa-aim (0.5 :loop t :base :hs-k-kosa-aim)
  (0) (0.25 (:root :u -0.1) (:chest :twist -10) (:arm-r :flex 92)))
(defpose :hs-k-kosa-up (:base :hs-k-stance)
  (:root :u -0.04 :f -0.1 :yaw -16) (:spine :flex -20) (:chest :twist -26) (:head :flex -16)
  (:arm-r :flex 150 :side 40 :twist 0) (:elbow-r :flex 60) (:hand-r :flex -40)
  (:arm-l :flex 168 :side 4 :twist 0) (:elbow-l :flex 50) (:hand-l :flex -20)
  (:thigh-r :flex -22 :side 8) (:knee-r :flex 26) (:thigh-l :flex 24 :side 8) (:knee-l :flex 14))
(defpose :hs-k-kosa-hit (:base :hs-k-stance)
  (:root :f 0.2 :u -0.2 :yaw 6) (:spine :flex 28) (:chest :twist 12) (:head :flex 0)
  (:arm-r :flex 86 :side 4 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex 50 :side 20 :twist 0) (:elbow-l :flex 20) (:hand-l :flex -60)
  (:thigh-l :flex 50 :side 8) (:knee-l :flex 50) (:thigh-r :flex -28 :side 10) (:knee-r :flex 16))
(defstrike :hs-k-kosa (20 2 30 :base :hs-k-stance)
  (0 :hs-k-kosa-aim)
  (7 :hs-k-kosa-up)
  (17 :hs-k-kosa-up (:spine :flex -24) (:arm-l :flex 176))
  (:s :snap :hs-k-kosa-hit)
  (:a :hs-k-kosa-hit (:root :u -0.24) (:spine :flex 32))
  (34 :hs-k-kosa-hit (:root :u -0.22) (:spine :flex 30))
  (:end :hs-k-stance))

;; I: the Breaker's dash (low, the arms back, the chains streaming) and its strike (8/4/18): the chained right forearm
;; cocked high behind his head, then brought down as a hammer-fist (motion-refs §3.2; both modes, the kits' :clip-map)
(defclip :hs-k-breaker (0.4 :loop t :base :hs-k-run-arms)
  (0 (:root :u -0.2) (:spine :flex 32) (:head :flex -18) (:thigh-r :flex 46) (:knee-r :flex 30) (:thigh-l :flex -28) (:knee-l :flex 60))
  (0.2 (:root :u -0.16) (:spine :flex 30) (:head :flex -18) (:thigh-l :flex 46) (:knee-l :flex 30) (:thigh-r :flex -28) (:knee-r :flex 60)))
(defpose :hs-k-hammer-up (:base :hs-k-stance)
  (:root :u -0.04 :f -0.04 :yaw -10) (:spine :flex -16) (:chest :twist -20) (:head :flex -6)
  (:arm-r :flex 172 :side 24 :twist 0) (:elbow-r :flex 110) (:hand-r :flex -20)
  (:arm-l :flex 70 :side 10 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -60)
  (:thigh-r :flex -18 :side 8) (:knee-r :flex 24) (:thigh-l :flex 26 :side 8) (:knee-l :flex 16))
(defpose :hs-k-hammer-hit (:base :hs-k-stance)
  (:root :f 0.12 :u -0.24 :yaw 6) (:spine :flex 32) (:chest :twist 10) (:head :flex 0)
  (:arm-r :flex 66 :side 10 :twist 0) (:elbow-r :flex 26) (:hand-r :flex 30)
  (:arm-l :flex -20 :side 24 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -60)
  (:thigh-l :flex 50 :side 8) (:knee-l :flex 56) (:thigh-r :flex -24 :side 10) (:knee-r :flex 20))
(defstrike :hs-k-hammer (8 4 18 :base :hs-k-stance)
  (0 :hs-k-run-arms (:root :u -0.16) (:spine :flex 26) (:knees :flex 40))
  (4 :hs-k-hammer-up)
  (6 :hs-k-hammer-up (:spine :flex -18) (:arm-r :flex 178))
  (:s :snap :hs-k-hammer-hit)
  (:a :hs-k-hammer-hit (:root :u -0.28) (:spine :flex 36) (:arm-r :flex 50))
  (22 :hs-k-hammer-hit (:root :u -0.27) (:spine :flex 34) (:arm-r :flex 52))
  (:end :hs-k-stance))

;; P 首掛 KUBIKAKE (24/4/30, the 7 m line): the left arm up whirling the hanging chain at his left front round over his
;; head (the wrist's circle keyed every 3 f), coiled back, then cocked (f21); the cast along the line, the noose's end on
;; the line's edge (a hit: hooked round his neck through the yank); the haul back
(defpose :hs-k-kubi-whirl (:base :hs-k-stance)
  (:root :u -0.08 :f -0.06 :yaw 14) (:spine :flex -10) (:chest :twist 18) (:head :flex -8)
  (:arm-l :flex 170 :side 14 :twist 0) (:elbow-l :flex 20) (:hand-l :flex -30)
  (:arm-r :flex -30 :side 30 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -90)
  (:thigh-r :flex -20 :side 8) (:knee-r :flex 24) (:thigh-l :flex 24 :side 8) (:knee-l :flex 14))
(defpose :hs-k-kubi-hit (:base :hs-k-stance)
  (:root :f 0.18 :u -0.14 :yaw -14) (:spine :flex 16) (:chest :twist -22) (:head :flex 0)
  (:arm-l :flex 92 :side 4 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -60)
  (:arm-r :flex -40 :side 26 :twist 0) (:elbow-r :flex 40) (:hand-r :flex -80)
  (:thigh-l :flex 46 :side 8) (:knee-l :flex 44) (:thigh-r :flex -26 :side 10) (:knee-r :flex 14))
(defstrike :hs-k-kubikake (24 4 30 :base :hs-k-stance)
  (0)
  (5 :hs-k-kubi-whirl)
  (8 :hs-k-kubi-whirl (:arm-l :side 30 :twist 24))
  (11 :hs-k-kubi-whirl (:arm-l :side 0 :twist -20))
  (14 :hs-k-kubi-whirl (:chest :twist 24) (:arm-l :side 30 :twist 24))
  (17 :hs-k-kubi-whirl (:root :yaw 20) (:chest :twist 28) (:arm-l :side 0 :twist -20))
  (21 :hs-k-kubi-whirl (:root :yaw 24) (:spine :flex -14) (:chest :twist 32) (:arm-l :flex 150 :side 40) (:elbow-l :flex 70))   ; cocked
  (:s :snap :hs-k-kubi-hit)
  (:a :hs-k-kubi-hit (:root :f 0.22) (:arm-l :flex 86))
  (34 :hs-k-kubi-hit (:root :f 0.12 :u -0.12) (:spine :flex 8) (:chest :twist -6) (:arm-l :flex 44 :side 20) (:elbow-l :flex 100))   ; the haul
  (44 :hs-k-kubi-hit (:root :f 0.08 :u -0.1) (:spine :flex 6) (:chest :twist -4) (:arm-l :flex 36 :side 20) (:elbow-l :flex 110))
  (:end :hs-k-stance))

;;; The ranged route links (batch A2, DUEL_HISAGI §24.2; the routes §22.4 / §22.6): each its own clip at its move's frames
;;; (the moves' :clip-s = their S). He signals, the orb's chains strike (*HS-LASHES*: lagging, tapered lashes from the orb
;;; with a trail, the spread links' thin hanging chains, the gathered links' one bundle of all eight); the windups are big
;;; and held (the user, 2026-10-18: 「動作要配合誇張而明顯的前搖」), the gathered ones longer and heavier.
;; K1 綁束 HOSOKU (16/4/22, the annulus 1.0-4.0 m, 360 deg, §25.3; the gathered opener): the stir: the right arm up over his head
;; circling (a key every 3 f: the orb winding, the curtain drawn in and up round him), coiled to his right on the back foot
;; (held f6-14); the fling on S: unwound to his left with the spin, the arms flung wide, every hanging chain whirled out to
;; 4.0 m round him (a key each 90 deg, f16-19); the haul: his fists brought in, the chains wound in and bound into one
;; bundle at his right front (f21-26), the right fist low on it
(defpose :hs-k-hosoku-up (:base :hs-k-stance)
  (:root :u -0.16 :f -0.06 :yaw -36) (:pelvis :twist -10) (:spine :flex 8) (:chest :twist -34) (:neck :twist 24) (:head :flex -12)
  (:arm-r :flex 168 :side 22 :twist 0) (:elbow-r :flex 64) (:hand-r :flex -30)
  (:arm-l :flex 46 :side -28 :twist 0) (:elbow-l :flex 96) (:hand-l :flex -50)
  (:thigh-r :flex -18 :side 10) (:knee-r :flex 46) (:thigh-l :flex 34 :side 10) (:knee-l :flex 30))
(defpose :hs-k-hosoku-hit (:base :hs-k-stance)
  (:root :u -0.26 :yaw 30) (:pelvis :twist 8) (:spine :flex 18) (:chest :twist 26) (:neck :twist -10) (:head :flex 0)
  (:arm-r :flex 20 :side 96 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -90)
  (:arm-l :flex 20 :side 96 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -90)
  (:thigh-l :flex 40 :side 16) (:knee-l :flex 50) (:thigh-r :flex 0 :side 18) (:knee-r :flex 44))
(defpose :hs-k-hosoku-bind (:base :hs-k-stance)       ; bound: the right fist low ahead on the bundle, the left at his chest
  (:root :u -0.12 :yaw -8) (:spine :flex 12) (:chest :twist -8) (:head :flex 4)
  (:arm-r :flex 40 :side 34 :twist 0) (:elbow-r :flex 36) (:hand-r :flex -70)
  (:arm-l :flex 70 :side -10 :twist 0) (:elbow-l :flex 110) (:hand-l :flex -40)
  (:thigh-l :flex 22 :side 8) (:knee-l :flex 26) (:thigh-r :flex -8 :side 10) (:knee-r :flex 24))
(defstrike :hs-k-hosoku (16 4 22 :base :hs-k-stance)
  (0)
  (6 :hs-k-hosoku-up)
  (9 :hs-k-hosoku-up (:arm-r :side 40 :twist 30) (:elbow-r :flex 50))
  (12 :hs-k-hosoku-up (:arm-r :side 6 :twist -24) (:elbow-r :flex 72))
  (14 :hs-k-hosoku-up (:root :yaw -44 :u -0.18) (:chest :twist -42) (:arm-r :flex 174 :side 30 :twist 20))      ; cocked
  (:s :snap :hs-k-hosoku-hit)
  (17 :hs-k-hosoku-hit (:root :yaw 54) (:chest :twist 36))
  (18 :hs-k-hosoku-hit (:root :yaw 72) (:chest :twist 40) (:arm-r :side 100) (:arm-l :side 100))
  (:a :hs-k-hosoku-hit (:root :yaw 80 :u -0.24) (:chest :twist 42))
  (26 :hs-k-hosoku-bind (:root :yaw 20))
  (34 :hs-k-hosoku-bind)
  (:end :hs-k-stance))

;; spread K2 散鞭 (21/4/24, link f6; a 60 deg fan to 4.0 m, §25.3): the whip-crack: the right arm swung up and far back over his
;; shoulder, arched back, coiled to his right, the left hand pointing (held f10-18), four hanging chains hauled up high
;; behind him; cracked down on S: the arm flung down ahead, pitched over the front knee, the four whipping the ground in a
;; fan at 6 m and lying there (to f30)
(defpose :hs-k-sk2-up (:base :hs-k-stance)
  (:root :u -0.04 :f -0.1 :yaw -22) (:spine :flex -22) (:chest :twist -26) (:head :flex -14)
  (:arm-r :flex 160 :side 34 :twist 0) (:elbow-r :flex 96) (:hand-r :flex -20)
  (:arm-l :flex 74 :side 10 :twist 0) (:elbow-l :flex 16) (:hand-l :flex -70)
  (:thigh-r :flex -24 :side 8) (:knee-r :flex 30) (:thigh-l :flex 26 :side 8) (:knee-l :flex 14))
(defpose :hs-k-sk2-hit (:base :hs-k-stance)
  (:root :f 0.18 :u -0.26 :yaw 8) (:spine :flex 34) (:chest :twist 12) (:head :flex -10)
  (:arm-r :flex 70 :side 6 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex -30 :side 30 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -70)
  (:thigh-l :flex 54 :side 8) (:knee-l :flex 56) (:thigh-r :flex -30 :side 10) (:knee-r :flex 18))
(defstrike :hs-k-s-k2 (21 4 24 :base :hs-k-stance)
  (0 :hs-k-saben-hit (:root :yaw 22 :u -0.1) (:chest :twist 30) (:arm-r :flex 114 :side 78) (:elbow-r :flex 12))
  (6 :hs-k-saben-hit (:root :yaw 20 :u -0.1) (:chest :twist 28) (:arm-r :flex 110 :side 76) (:elbow-r :flex 14))
  (10 :hs-k-sk2-up)
  (18 :hs-k-sk2-up (:root :yaw -26) (:spine :flex -26) (:arm-r :flex 166 :side 38))                            ; held
  (:s :snap :hs-k-sk2-hit)
  (:a :hs-k-sk2-hit (:root :u -0.3) (:spine :flex 40) (:arm-r :flex 56))
  (30 :hs-k-sk2-hit (:root :u -0.28) (:spine :flex 38) (:arm-r :flex 58))
  (:end :hs-k-stance))

;; spread K3 散撃 (21/5/34, link f6; a 160 deg fan to 4.0 m, §25.3; ender): the curtain drawn back: both arms flung back and wide,
;; the chest thrown out, arched, every hanging chain hauled back high behind him (held f9-19); the fling on S: both arms
;; swept forward and out together, a lunge onto the front foot, all eight lashed forward in a fan (a third of a frame
;; apart), settling to the floor
(defpose :hs-k-sk3-up (:base :hs-k-stance)
  (:root :u -0.1 :f -0.1) (:spine :flex -24) (:chest :twist 0) (:head :flex -18)
  (:arms :flex -52 :side 64) (:elbows :flex 12) (:hands :flex -80)
  (:thigh-l :flex 20 :side 14) (:knee-l :flex 22) (:thigh-r :flex -16 :side 14) (:knee-r :flex 30))
(defpose :hs-k-sk3-hit (:base :hs-k-stance)
  (:root :f 0.2 :u -0.24) (:spine :flex 28) (:head :flex -6)
  (:arms :flex 86 :side 52) (:elbows :flex 2) (:hands :flex -90)
  (:thigh-l :flex 54 :side 12) (:knee-l :flex 54) (:thigh-r :flex -28 :side 12) (:knee-r :flex 16))
(defstrike :hs-k-s-k3 (21 5 34 :base :hs-k-stance)
  (0 :hs-k-sk2-hit (:root :u -0.28) (:spine :flex 38) (:arm-r :flex 58))
  (6 :hs-k-sk2-hit (:root :u -0.27) (:spine :flex 36) (:arm-r :flex 60))
  (9 :hs-k-sk3-up)
  (19 :hs-k-sk3-up (:spine :flex -28) (:arms :flex -58 :side 68))                                                  ; held
  (:s :snap :hs-k-sk3-hit)
  (:a :hs-k-sk3-hit (:root :u -0.28) (:spine :flex 32) (:arms :flex 80 :side 60))
  (36 :hs-k-sk3-hit (:root :u -0.26) (:spine :flex 30) (:arms :flex 76 :side 58))
  (:end :hs-k-stance))

;; gathered K2 束打 SOKUDA (27/10/24, link f6; hit 1 f27 and hit 2 f33 on 1.0-4.0 m, §25.3): the heave: both fists up
;; over his right shoulder, sunk on the back leg, arched and coiled, the bundle hauled up high behind him (held f16-24);
;; the U on S: both arms brought down over his head, bent double, the bundle arcing over and slammed onto the ground ahead
;; (held to f30); the L at f33: a shove forward off the front foot, its tail lashed on along the ground to 8 m, left lying
;; flat ahead
(defpose :hs-k-gk2-up (:base :hs-k-stance)
  (:root :u -0.2 :f -0.14 :yaw -30) (:pelvis :twist -10) (:spine :flex -22) (:chest :twist -40) (:neck :twist 20) (:head :flex -16)
  (:arm-r :flex 164 :side 44 :twist 0) (:elbow-r :flex 92) (:hand-r :flex -30)
  (:arm-l :flex 154 :side -12 :twist 0) (:elbow-l :flex 112) (:hand-l :flex -30)
  (:thigh-r :flex -26 :side 10) (:knee-r :flex 52) (:thigh-l :flex 30 :side 10) (:knee-l :flex 24))
(defpose :hs-k-gk2-hit (:base :hs-k-stance)
  (:root :f 0.16 :u -0.36 :yaw 4) (:spine :flex 44) (:chest :twist 6) (:head :flex -14)
  (:arms :flex 62 :side 12) (:elbows :flex 6) (:hands :flex -80)
  (:thigh-l :flex 62 :side 12) (:knee-l :flex 76) (:thigh-r :flex -10 :side 14) (:knee-r :flex 52))
(defpose :hs-k-gk2-shove (:base :hs-k-stance)
  (:root :f 0.3 :u -0.3 :yaw 0) (:spine :flex 30) (:chest :twist 0) (:head :flex -4)
  (:arms :flex 88 :side 10) (:elbows :flex 0) (:hands :flex -90)
  (:thigh-l :flex 58 :side 10) (:knee-l :flex 50) (:thigh-r :flex -34 :side 12) (:knee-r :flex 16))
(defstrike :hs-k-g-k2 (27 10 24 :base :hs-k-stance)
  (0 :hs-k-hosoku-bind)
  (6 :hs-k-hosoku-bind (:root :u -0.14))
  (16 :hs-k-gk2-up)
  (24 :hs-k-gk2-up (:root :u -0.22 :yaw -34) (:spine :flex -26) (:arm-r :flex 170) (:arm-l :flex 160))           ; held
  (:s :snap :hs-k-gk2-hit)
  (30 :hs-k-gk2-hit (:root :u -0.38) (:spine :flex 46))
  (33 :snap :hs-k-gk2-shove)
  (:a :hs-k-gk2-shove (:root :f 0.32))
  (48 :hs-k-gk2-shove (:root :f 0.3 :u -0.28) (:spine :flex 28))
  (:end :hs-k-stance))

;; gathered K3 束旋 SOKUSEN (27/5/34, link f6; the annulus 1.0-4.0 m, 360 deg, §25.3; ender): the haul: leaning back, the bundle
;; dragged in off the floor hand over hand (f10 / f15), then swung round to his right and wound up, crouched (held f20-26);
;; the spin on S: the whole body turned with it, arms flung out, the bundle whirled round him at 6 m (a key each 90 deg,
;; f27-31), let fly through and settled
(defpose :hs-k-gk3-haul (:base :hs-k-stance)
  (:root :u -0.2 :f -0.14) (:spine :flex -16) (:chest :twist 0) (:head :flex -6)
  (:arm-r :flex 40 :side 20 :twist 0) (:elbow-r :flex 100) (:hand-r :flex -60)
  (:arm-l :flex 70 :side 6 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -70)
  (:thigh-l :flex 36 :side 10) (:knee-l :flex 30) (:thigh-r :flex -14 :side 12) (:knee-r :flex 40))
(defpose :hs-k-gk3-up (:base :hs-k-stance)
  (:root :u -0.3 :yaw -70) (:pelvis :twist -12) (:spine :flex 22) (:chest :twist -40) (:neck :twist 30) (:head :flex 0)
  (:arm-r :flex -34 :side 62 :twist 0) (:elbow-r :flex 20) (:hand-r :flex -90)
  (:arm-l :flex 60 :side -20 :twist 0) (:elbow-l :flex 60) (:hand-l :flex -70)
  (:thigh-l :flex 50 :side 12) (:knee-l :flex 66) (:thigh-r :flex 8 :side 16) (:knee-r :flex 56))
(defpose :hs-k-gk3-hit (:base :hs-k-stance)
  (:root :u -0.2 :yaw 10) (:pelvis :twist 6) (:spine :flex 10) (:chest :twist 20) (:head :flex 0)
  (:arm-r :flex 30 :side 94 :twist 0) (:elbow-r :flex 2) (:hand-r :flex -90)
  (:arm-l :flex 20 :side 90 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -90)
  (:thigh-l :flex 30 :side 16) (:knee-l :flex 40) (:thigh-r :flex 4 :side 18) (:knee-r :flex 38))
(defstrike :hs-k-g-k3 (27 5 34 :base :hs-k-stance)
  (0 :hs-k-gk2-shove (:root :f 0.3 :u -0.28) (:spine :flex 28))
  (6 :hs-k-gk2-shove (:root :f 0.28 :u -0.28) (:spine :flex 26))
  (10 :hs-k-gk3-haul)
  (15 :hs-k-gk3-haul (:arm-r :flex 70 :side 6) (:elbow-r :flex 40) (:arm-l :flex 40 :side 20) (:elbow-l :flex 100))
  (20 :hs-k-gk3-up)
  (26 :hs-k-gk3-up (:root :yaw -80 :u -0.32) (:chest :twist -46))                                                 ; held
  (:s :snap :hs-k-gk3-hit)
  (29 :hs-k-gk3-hit (:root :yaw 60) (:chest :twist 30))
  (31 :hs-k-gk3-hit (:root :yaw 104) (:chest :twist 36) (:arm-r :side 100) (:arm-l :side 98))
  (:a :hs-k-gk3-hit (:root :yaw 112 :u -0.22) (:chest :twist 38))
  (44 :hs-k-gk3-hit (:root :yaw 70 :u -0.16) (:spine :flex 6) (:arm-r :flex 10 :side 60) (:arm-l :flex 10 :side 60))
  (:end :hs-k-stance))

;; gathered J2 束鞭 SOKUBEN (16/3/13; the line 3.0-6.0 m at the chest, §25.3): the bundle cocked back by his right hip, the right
;; fist drawn back low, coiled, the weight back (held f6-14); the lash on S: the fist punched straight ahead in a lunge, the
;; bundle straight out down the line at chest height, a wave running out along it
(defpose :hs-k-gj2-up (:base :hs-k-stance)
  (:root :u -0.16 :f -0.08 :yaw -30) (:spine :flex 6) (:chest :twist -36) (:neck :twist 24) (:head :flex 0)
  (:arm-r :flex -52 :side 34 :twist 0) (:elbow-r :flex 86) (:hand-r :flex -40)
  (:arm-l :flex 78 :side 10 :twist 0) (:elbow-l :flex 20) (:hand-l :flex -70)
  (:thigh-r :flex -22 :side 10) (:knee-r :flex 40) (:thigh-l :flex 30 :side 8) (:knee-l :flex 22))
(defpose :hs-k-gj2-hit (:base :hs-k-stance)
  (:root :f 0.22 :u -0.16 :yaw 14) (:spine :flex 16) (:chest :twist 24) (:head :flex 0)
  (:arm-r :flex 86 :side 4 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex -36 :side 28 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -70)
  (:thigh-l :flex 48 :side 8) (:knee-l :flex 44) (:thigh-r :flex -30 :side 10) (:knee-r :flex 14))
(defstrike :hs-k-g-j2 (16 3 13 :base :hs-k-stance)
  (0 :hs-k-hosoku-bind)
  (6 :hs-k-gj2-up)
  (14 :hs-k-gj2-up (:root :yaw -34 :f -0.1) (:chest :twist -40) (:arm-r :flex -58))                               ; held
  (:s :snap :hs-k-gj2-hit)
  (:a :hs-k-gj2-hit (:root :f 0.26))
  (24 :hs-k-gj2-hit (:root :f 0.22 :u -0.14) (:arm-r :flex 80))
  (:end :hs-k-stance))

;; gathered J3 束薙 SOKUTEI (16/3/18, the annulus 3.0-6.0 m, 180 deg, §25.3; ender): wound up low to his right, both fists swung
;; down by his right knee, crouched and coiled (held f5-14), the bundle drawn back round behind his right; the sweep on S:
;; unwound to his left, the arms swept flat across, the bundle swept flat through the front half at 6 m (f16-18)
(defpose :hs-k-gj3-up (:base :hs-k-stance)
  (:root :u -0.3 :yaw -60) (:pelvis :twist -12) (:spine :flex 26) (:chest :twist -40) (:neck :twist 34) (:head :flex 0)
  (:arm-r :flex 10 :side 40 :twist 0) (:elbow-r :flex 20) (:hand-r :flex -80)
  (:arm-l :flex 50 :side -30 :twist 0) (:elbow-l :flex 30) (:hand-l :flex -80)
  (:thigh-l :flex 50 :side 12) (:knee-l :flex 68) (:thigh-r :flex 6 :side 16) (:knee-r :flex 58))
(defpose :hs-k-gj3-hit (:base :hs-k-stance)
  (:root :u -0.22 :yaw 30) (:pelvis :twist 10) (:spine :flex 14) (:chest :twist 30) (:head :flex 0)
  (:arm-r :flex 70 :side 70 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -90)
  (:arm-l :flex -10 :side 60 :twist 0) (:elbow-l :flex 20) (:hand-l :flex -80)
  (:thigh-l :flex 36 :side 14) (:knee-l :flex 44) (:thigh-r :flex 0 :side 18) (:knee-r :flex 40))
(defstrike :hs-k-g-j3 (16 3 18 :base :hs-k-stance)
  (0 :hs-k-gk2-shove (:root :f 0.28 :u -0.28) (:spine :flex 26))
  (5 :hs-k-gj3-up)
  (14 :hs-k-gj3-up (:root :yaw -68 :u -0.32) (:chest :twist -46))                                                   ; held
  (:s :snap :hs-k-gj3-hit)
  (17 :hs-k-gj3-hit (:root :yaw 56) (:chest :twist 38))
  (:a :hs-k-gj3-hit (:root :yaw 76) (:chest :twist 42) (:arm-r :flex 110 :side 70))
  (26 :hs-k-gj3-hit (:root :yaw 66 :u -0.18) (:chest :twist 36) (:arm-r :flex 100 :side 66))
  (:end :hs-k-stance))

;;; The bind mode (§17.3; motion-refs §3.3): melee, both necks noosed to the orb
;; the bind's stance and walk (§22.1, batch A2: 「the crescents gripped, a low forward stance, the noose taut」): sunk low
;; over bent knees, leaning in, both crescents gripped up ahead of him (the right at his chest, the left low), his left
;; fist on a chain run taut to the opponent's noose (HISAGI-DRAW, *HS-KB-GRIP-CLIPS*); the walk keeps the crouch
(defpose :hs-kb-stance (:base :hs-k-stance)
  (:root :u -0.2 :f 0.02) (:pelvis :twist -8) (:spine :flex 20) (:chest :twist -6) (:neck :twist 4) (:head :flex -12)
  (:arm-r :flex 58 :side 26 :twist 0) (:elbow-r :flex 84) (:hand-r :flex -30)
  (:arm-l :flex 50 :side 14 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -60)
  (:thigh-l :flex 40 :side 12) (:knee-l :flex 52) (:thigh-r :flex 6 :side 14) (:knee-r :flex 44))
(defclip :hs-kb-stance (2.0 :loop t :base :hs-kb-stance)
  (0) (1.0 (:root :u -0.22) (:spine :flex 22) (:elbow-r :flex 88) (:hand-l :flex -64)))
(defclip :hs-kb-walk-f (0.9 :loop t :base :hs-kb-stance)
  (0 (:thigh-r :flex 46) (:knee-r :flex 40) (:thigh-l :flex 14) (:knee-l :flex 52))
  (0.225 (:root :u -0.23) (:thigh-r :flex 28) (:knee-r :flex 46) (:thigh-l :flex 30) (:knee-l :flex 80))
  (0.45 (:root :u -0.24) (:thigh-l :flex 46) (:knee-l :flex 40) (:thigh-r :flex 14) (:knee-r :flex 52))
  (0.675 (:root :u -0.23) (:thigh-l :flex 28) (:knee-l :flex 46) (:thigh-r :flex 30) (:knee-r :flex 80)))
(defclip :hs-kb-walk-b (0.9 :loop t :base :hs-kb-stance)
  (0 (:thigh-r :flex 14) (:knee-r :flex 52) (:thigh-l :flex 46) (:knee-l :flex 40))
  (0.225 (:root :u -0.23) (:thigh-r :flex 30) (:knee-r :flex 80) (:thigh-l :flex 28) (:knee-l :flex 46))
  (0.45 (:root :u -0.24) (:thigh-l :flex 14) (:knee-l :flex 52) (:thigh-r :flex 46) (:knee-r :flex 40))
  (0.675 (:root :u -0.23) (:thigh-l :flex 30) (:knee-l :flex 80) (:thigh-r :flex 28) (:knee-r :flex 46)))
(defclip :hs-kb-strafe-r (0.8 :loop t :base :hs-kb-stance)
  (0 (:thigh-r :side 28) (:thigh-l :side 4) (:knee-l :flex 60))
  (0.2 (:root :u -0.23) (:thigh-r :side 16) (:knee-r :flex 66) (:thigh-l :side 10))
  (0.4 (:thigh-r :side 10) (:thigh-l :side 24) (:knee-l :flex 50))
  (0.6 (:root :u -0.23) (:thigh-l :side 12) (:knee-l :flex 66) (:thigh-r :side 18)))
(defclip :hs-kb-strafe-l (0.8 :loop t :base :hs-kb-stance)
  (0 (:thigh-l :side 28) (:thigh-r :side 4) (:knee-r :flex 56))
  (0.2 (:root :u -0.23) (:thigh-l :side 16) (:knee-l :flex 66) (:thigh-r :side 18))
  (0.4 (:thigh-l :side 12) (:thigh-r :side 26) (:knee-r :flex 48))
  (0.6 (:root :u -0.23) (:thigh-r :side 14) (:knee-r :flex 66) (:thigh-l :side 18)))
;; J1 弦 GEN (8/3/12, 1.5 m arc 110): coiled to his right, the right arm drawn far back (held f4-6); the right crescent
;; hooked flat right to left at the neck line (the held rod: the FK test's tip)
(defpose :hs-kb-gen-up (:base :hs-k-stance)
  (:root :u -0.12 :f -0.04 :yaw -28) (:spine :flex 4) (:chest :twist -42) (:neck :twist 20) (:head :flex 0)
  (:arm-r :flex -34 :side 84 :twist 0) (:elbow-r :flex 34) (:hand-r :flex -90)
  (:arm-l :flex 40 :side 30 :twist 0) (:elbow-l :flex 64) (:hand-l :flex -60)
  (:thigh-r :flex -16 :side 10) (:knee-r :flex 40) (:thigh-l :flex 30 :side 8) (:knee-l :flex 24))
(defpose :hs-kb-gen-hit (:base :hs-k-stance)
  (:root :f 0.08 :u -0.08 :yaw 6) (:spine :flex 8) (:chest :twist 8) (:head :flex 0)
  (:arm-r :flex 60 :side 88 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90 :twist 0)
  (:arm-l :flex -10 :side 36 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -70)
  (:thigh-l :flex 36 :side 8) (:knee-l :flex 34) (:thigh-r :flex -20 :side 10) (:knee-r :flex 16))
(defstrike :hs-kb-gen (8 3 12 :base :hs-k-stance)
  (0)
  (4 :hs-kb-gen-up)
  (6 :hs-kb-gen-up (:root :yaw -32) (:chest :twist -46) (:arm-r :flex -40))
  (:s :snap :hs-kb-gen-hit)
  (:a :hs-kb-gen-hit (:root :yaw 22) (:chest :twist 30) (:arm-r :flex 118 :side 86))
  (17 :hs-kb-gen-hit (:root :yaw 18 :u -0.07) (:chest :twist 26) (:arm-r :flex 110 :side 80) (:elbow-r :flex 14))
  (:end :hs-k-stance))

;; J2 返弦 KAESHI-GEN (8/3/13): wound to his left, crouched, the left crescent low at his left knee (held f4-6); the rising
;; backhand to over his right shoulder, the crescent let out on a short chain (1.5 m)
(defpose :hs-kb-kaeshi-up (:base :hs-k-stance)
  (:root :u -0.16 :yaw 22) (:spine :flex 16) (:chest :twist 36) (:head :flex 0)
  (:arm-l :flex 4 :side 30 :twist 0) (:elbow-l :flex 6) (:hand-l :flex -90)
  (:arm-r :flex 110 :side 40 :twist 0) (:elbow-r :flex 110) (:hand-r :flex -50)
  (:thigh-l :flex 40 :side 10) (:knee-l :flex 50) (:thigh-r :flex -10 :side 12) (:knee-r :flex 40))
(defpose :hs-kb-kaeshi-hit (:base :hs-k-stance)
  (:root :f 0.08 :u -0.08 :yaw -10) (:spine :flex 4) (:chest :twist -20) (:head :flex 0)
  (:arm-l :flex 104 :side -14 :twist 0) (:elbow-l :flex 2) (:hand-l :flex -90)
  (:arm-r :flex 40 :side 34 :twist 0) (:elbow-r :flex 60) (:hand-r :flex -70)
  (:thigh-l :flex 30 :side 8) (:knee-l :flex 30) (:thigh-r :flex -16 :side 10) (:knee-r :flex 20))
(defstrike :hs-kb-kaeshi (8 3 13 :base :hs-k-stance)
  (0 :hs-kb-gen-hit (:root :yaw 18 :u -0.07) (:chest :twist 26) (:arm-r :flex 110 :side 80) (:elbow-r :flex 14))
  (4 :hs-kb-kaeshi-up)
  (6 :hs-kb-kaeshi-up (:root :yaw 26 :u -0.18) (:chest :twist 40))
  (:s :snap :hs-kb-kaeshi-hit)
  (:a :hs-kb-kaeshi-hit (:root :yaw -18) (:chest :twist -30) (:arm-l :flex 140 :side -30))
  (18 :hs-kb-kaeshi-hit (:root :yaw -16 :u -0.07) (:chest :twist -26) (:arm-l :flex 132 :side -26))
  (:end :hs-k-stance))

;; J3 双弦 SOGEN (9/3/18, 1.5 m arc 200; ender): both crescents crossed high in front, hunched (held f4-7); scissored
;; outward wide (the held right rod: the FK test's tip)
(defpose :hs-kb-sogen-up (:base :hs-k-stance)
  (:root :u -0.16) (:spine :flex 22) (:head :flex 10)
  (:arm-r :flex 110 :side -34 :twist 0) (:elbow-r :flex 40) (:hand-r :flex -60)
  (:arm-l :flex 110 :side -34 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -60)
  (:thighs :flex 34 :side 10) (:knees :flex 46))
(defpose :hs-kb-sogen-hit (:base :hs-k-stance)
  (:root :f 0.1 :u -0.1) (:spine :flex 4) (:head :flex 0)
  (:arm-r :flex 30 :side 88 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex 30 :side 88 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -90)
  (:thigh-l :flex 30 :side 10) (:knee-l :flex 30) (:thigh-r :flex -14 :side 12) (:knee-r :flex 20))
(defstrike :hs-kb-sogen (9 3 18 :base :hs-k-stance)
  (0 :hs-kb-kaeshi-hit (:root :yaw -16 :u -0.07) (:chest :twist -26) (:arm-l :flex 132 :side -26))
  (4 :hs-kb-sogen-up)
  (7 :hs-kb-sogen-up (:root :u -0.18) (:spine :flex 26))
  (:s :snap :hs-kb-sogen-hit)
  (:a :hs-kb-sogen-hit (:spine :flex -6) (:arm-r :flex -4 :side 92) (:arm-l :flex -4 :side 92))
  (22 :hs-kb-sogen-hit (:spine :flex -4) (:arm-r :flex 0 :side 90) (:arm-l :flex 0 :side 90))
  (:end :hs-k-stance))

;; K1 引斬 HIKIGIRI (18/4/20, the 2.6 m line): the right crescent drawn back high over his right shoulder, coiled, the left
;; hand reaching up the noose chain (held f6-15); the pull-cut: the left yanked to his chest, the right crescent hooked out
;; along the line on its chain
(defpose :hs-kb-hiki-up (:base :hs-k-stance)
  (:root :u -0.1 :f -0.08 :yaw -24) (:spine :flex -12) (:chest :twist -36) (:head :flex -8)
  (:arm-r :flex 150 :side 56 :twist 0) (:elbow-r :flex 90) (:hand-r :flex -40)
  (:arm-l :flex 150 :side 8 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -20)
  (:thigh-r :flex -22 :side 8) (:knee-r :flex 30) (:thigh-l :flex 28 :side 8) (:knee-l :flex 14))
(defpose :hs-kb-hiki-hit (:base :hs-k-stance)
  (:root :f 0.14 :u -0.12 :yaw 10) (:spine :flex 14) (:chest :twist 16) (:head :flex 0)
  (:arm-r :flex 90 :side 6 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex 30 :side 30 :twist 0) (:elbow-l :flex 124) (:hand-l :flex -20)
  (:thigh-l :flex 44 :side 8) (:knee-l :flex 42) (:thigh-r :flex -26 :side 10) (:knee-r :flex 14))
(defstrike :hs-kb-hikigiri (18 4 20 :base :hs-k-stance)
  (0)
  (6 :hs-kb-hiki-up)
  (15 :hs-kb-hiki-up (:root :yaw -28) (:chest :twist -40) (:arm-r :flex 156))
  (:s :snap :hs-kb-hiki-hit)
  (:a :hs-kb-hiki-hit (:root :f 0.18) (:arm-r :flex 86))
  (32 :hs-kb-hiki-hit (:root :f 0.16))
  (:end :hs-k-stance))

;; K2 巻斬 MAKIGIRI (20/4/24, link f6; 2.8 m arc 140; the revision: from a hanging chain): coiled to his left, the left arm
;; flung up and back hauling the hanging chain behind his left (held f12-18); flung across left to right at chest height
(defpose :hs-kb-maki-up (:base :hs-k-stance)
  (:root :u -0.16 :yaw 42) (:spine :flex 12) (:chest :twist 40) (:neck :twist -30) (:head :flex 0)
  (:arm-l :flex -40 :side 120 :twist 0) (:elbow-l :flex 24) (:hand-l :flex -60)
  (:arm-r :flex 70 :side -10 :twist 0) (:elbow-r :flex 100) (:hand-r :flex -50)
  (:thigh-r :flex 44 :side 10) (:knee-r :flex 56) (:thigh-l :flex -4 :side 14) (:knee-l :flex 44))
(defpose :hs-kb-maki-hit (:base :hs-k-stance)
  (:root :f 0.1 :u -0.14 :yaw -16) (:spine :flex 14) (:chest :twist -30) (:head :flex 0)
  (:arm-l :flex 110 :side 84 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -90)
  (:arm-r :flex -30 :side 30 :twist 0) (:elbow-r :flex 40) (:hand-r :flex -70)
  (:thigh-l :flex 40 :side 10) (:knee-l :flex 50) (:thigh-r :flex -16 :side 12) (:knee-r :flex 30))
(defstrike :hs-kb-makigiri (20 4 24 :base :hs-k-stance)
  (0 :hs-kb-hiki-hit (:root :f 0.16))
  (6 :hs-kb-hiki-hit (:root :f 0.15))
  (12 :hs-kb-maki-up)
  (18 :hs-kb-maki-up (:root :yaw 48) (:chest :twist 46))
  (:s :snap :hs-kb-maki-hit)
  (:a :hs-kb-maki-hit (:root :yaw -32) (:chest :twist -44) (:arm-l :flex 150 :side 80))
  (34 :hs-kb-maki-hit (:root :yaw -28 :u -0.12) (:chest :twist -40) (:arm-l :flex 144 :side 76))
  (:end :hs-k-stance))

;; K3 絞 SHIBORI (22/5/34, link f8; 3.0 m arc 120; ender): the canon gesture, the right crescent raised straight up, the
;; left hand high on the noose (held f14-20); the left hauls down hard, bent: two chains drop out of the orb and cinch
(defpose :hs-kb-shibori-up (:base :hs-k-stance)
  (:root :u 0.04 :f -0.04) (:spine :flex -16) (:chest :twist -8) (:head :flex -16)
  (:arm-r :flex 178 :side 8 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -40)
  (:arm-l :flex 158 :side 14 :twist 0) (:elbow-l :flex 16) (:hand-l :flex -20)
  (:thigh-r :flex -14 :side 8) (:knee-r :flex 8) (:thigh-l :flex 16 :side 8) (:knee-l :flex 6))
(defpose :hs-kb-shibori-hit (:base :hs-k-stance)
  (:root :u -0.3 :f 0.06) (:spine :flex 30) (:head :flex -10)
  (:arm-r :flex 150 :side 20 :twist 0) (:elbow-r :flex 20) (:hand-r :flex -40)
  (:arm-l :flex 6 :side 24 :twist 0) (:elbow-l :flex 80) (:hand-l :flex -20)
  (:thigh-l :flex 56 :side 12) (:knee-l :flex 72) (:thigh-r :flex -8 :side 14) (:knee-r :flex 56))
(defstrike :hs-kb-shibori (22 5 34 :base :hs-k-stance)
  (0 :hs-kb-maki-hit (:root :yaw -28 :u -0.12) (:chest :twist -40) (:arm-l :flex 144 :side 76))
  (8 :hs-kb-maki-hit (:root :yaw -26 :u -0.12) (:chest :twist -38) (:arm-l :flex 140 :side 74))
  (14 :hs-kb-shibori-up)
  (20 :hs-kb-shibori-up (:root :u 0.05) (:spine :flex -20) (:arm-r :flex 184))
  (:s :snap :hs-kb-shibori-hit)
  (:a :hs-kb-shibori-hit (:root :u -0.33) (:spine :flex 34))
  (46 :hs-kb-shibori-hit (:root :u -0.32) (:spine :flex 32))
  (:end :hs-k-stance))

;; the hauls (B3b's L 引寄 HIKIYOSE, its clip gone since batch A3: its pull is KOJO's): both hands reaching high up the
;; noose chain, leaning in; the heave down to his chest, leaning far back (hand over hand through KOJO's drag)
(defpose :hs-kb-yose-up (:base :hs-k-stance)
  (:root :u 0.02 :f 0.06) (:spine :flex 14) (:head :flex -20)
  (:arm-r :flex 156 :side 6 :twist 0) (:elbow-r :flex 10) (:hand-r :flex -20)
  (:arm-l :flex 146 :side 6 :twist 0) (:elbow-l :flex 14) (:hand-l :flex -20)
  (:thigh-l :flex 30 :side 8) (:knee-l :flex 10) (:thigh-r :flex -16 :side 8) (:knee-r :flex 10))
(defpose :hs-kb-yose-haul (:base :hs-k-stance)
  (:root :u -0.2 :f -0.12) (:spine :flex -22) (:head :flex 4)
  (:arm-r :flex 40 :side 24 :twist 0) (:elbow-r :flex 120) (:hand-r :flex -20)
  (:arm-l :flex 70 :side 14 :twist 0) (:elbow-l :flex 90) (:hand-l :flex -20)
  (:thigh-l :flex 40 :side 10) (:knee-l :flex 50) (:thigh-r :flex -24 :side 10) (:knee-r :flex 30))

;; Shift+K 綴雷電 (14/3/24, the 4 m line): the right fist raised (two fingers), the left crescent drawn back low, coiled
;; (held f5-12); the left crescent thrown down the line on its chain, the bolt along it, the fist still raised
(defpose :hs-kb-raiden-up (:base :hs-k-stance)
  (:root :u -0.1 :f -0.06 :yaw 16) (:spine :flex -12) (:chest :twist 22) (:head :flex -8)
  (:arm-r :flex 172 :side 10 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -20)
  (:arm-l :flex -50 :side 36 :twist 0) (:elbow-l :flex 20) (:hand-l :flex -90)
  (:thigh-r :flex 24 :side 8) (:knee-r :flex 16) (:thigh-l :flex -22 :side 8) (:knee-l :flex 30))
(defpose :hs-kb-raiden-hit (:base :hs-k-stance)
  (:root :f 0.14 :u -0.12 :yaw -6) (:spine :flex 10) (:chest :twist -12) (:head :flex 0)
  (:arm-r :flex 166 :side 10 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -20)
  (:arm-l :flex 90 :side 4 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -90)
  (:thigh-r :flex 42 :side 8) (:knee-r :flex 40) (:thigh-l :flex -24 :side 10) (:knee-l :flex 14))
(defstrike :hs-kb-raiden (14 3 24 :base :hs-k-stance)
  (0)
  (5 :hs-kb-raiden-up)
  (12 :hs-kb-raiden-up (:spine :flex -16) (:arm-l :flex -58))
  (:s :snap :hs-kb-raiden-hit)
  (:a :hs-kb-raiden-hit (:root :f 0.18))
  (30 :hs-kb-raiden-hit (:root :f 0.17))
  (:end :hs-k-stance))

;; L 絞縄 KOJO (30/4/36, 3.0 m arc 160; drawn by batch A3, §24.3, the user 2026-10-18: 「增加拉近對手前的動作識別度與前搖時間，
;; 並減少攻擊效果的前搖。核心邏輯是對手在遠處時就知道要被拉近該準備防禦」): the 20 f tell before the pull, both hands up the
;; noose chain (f4), then the heave: hauled up over his head, arched far back on the back leg, the chain from his left fist
;; to the opponent's noose pulled taut and trembling (*HS-KB-GRIPS*; held f9-19); the yank down to his chest on f20 (the
;; drag, HS-PULL-GO), hand over hand while the right crescent is raised high (f24-29); the wide downward reap on S, the
;; crescent let out to 3 m from overhead (*HS-LETOUT*), the impact held to f46
(defpose :hs-kb-kojo-heave (:base :hs-k-stance)
  (:root :u -0.16 :f -0.1) (:spine :flex -28) (:chest :twist -6) (:head :flex -16)
  (:arm-r :flex 165 :side 18 :twist 0) (:elbow-r :flex 40) (:hand-r :flex -20)
  (:arm-l :flex 160 :side 14 :twist 0) (:elbow-l :flex 46) (:hand-l :flex -20)
  (:thigh-l :flex 36 :side 10) (:knee-l :flex 12) (:thigh-r :flex -24 :side 12) (:knee-r :flex 52))
(defpose :hs-kb-kojo-up (:base :hs-k-stance)
  (:root :u -0.06 :f -0.04 :yaw -14) (:spine :flex 8) (:chest :twist -24) (:neck :twist 10) (:head :flex 14)
  (:arm-r :flex 176 :side 40 :twist 0) (:elbow-r :flex 20) (:hand-r :flex -40)
  (:arm-l :flex 120 :side -26 :twist 0) (:elbow-l :flex 150) (:hand-l :flex -10)
  (:thigh-r :flex -16 :side 8) (:knee-r :flex 30) (:thigh-l :flex 24 :side 8) (:knee-l :flex 22))
(defpose :hs-kb-kojo-hit (:base :hs-k-stance)
  (:root :f 0.14 :u -0.22 :yaw 10) (:spine :flex 26) (:chest :twist 20) (:head :flex 0)
  (:arm-r :flex 84 :side 40 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex 40 :side 30 :twist 0) (:elbow-l :flex 60) (:hand-l :flex -40)
  (:thigh-l :flex 46 :side 8) (:knee-l :flex 50) (:thigh-r :flex -26 :side 10) (:knee-r :flex 20))
(defstrike :hs-kb-kojo (30 4 36 :base :hs-k-stance)
  (0 :hs-kb-stance)
  (4 :hs-kb-yose-up)                                                                  ; both hands up the chain
  (9 :hs-kb-kojo-heave)                                                               ; the heave (the tell)
  (14 :hs-kb-kojo-heave (:root :u -0.2) (:spine :flex -32) (:arm-r :flex 172) (:arm-l :flex 168))   ; straining (held)
  (19 :hs-kb-kojo-heave (:root :u -0.22) (:spine :flex -34) (:arm-r :flex 176) (:arm-l :flex 172))
  (21 :snap :hs-kb-yose-haul)                                                         ; the yank (the drag from f20)
  (24 :hs-kb-yose-haul (:arm-l :flex 140 :side 6) (:elbow-l :flex 20) (:arm-r :flex 120 :side 30))   ; hand over hand
  (27 :hs-kb-kojo-up (:arm-l :flex 50 :side 20) (:elbow-l :flex 100) (:hand-l :flex -30))   ; hauled, the blade raised
  (29 :hs-kb-kojo-up (:arm-l :flex 40 :side 24) (:elbow-l :flex 110) (:spine :flex 4) (:arm-r :flex 184 :side 44))
  (:s :snap :hs-kb-kojo-hit)
  (:a :hs-kb-kojo-hit (:spine :flex 32) (:chest :twist 30) (:arm-r :flex 124 :side 0))
  (46 :hs-kb-kojo-hit (:spine :flex 30) (:chest :twist 28) (:arm-r :flex 118 :side 4))   ; the impact hold
  (56 :hs-kb-stance (:root :u -0.16) (:spine :flex 16))
  (:end :hs-kb-stance))

;; SP2 解縛擊 KAIBAKU-GEKI (18/4/28, 3.0 m arc 140; drawn by batch A3, §24.3): the noose chain gripped in his left fist and
;; hauled up off the necks (f5), coiled hard to his right, the right crescent cocked far back low behind his hip, sunk
;; (held f11-16); on S the release: the left arm flung up and out, the noose thrown off the opponent's neck and reeled
;; up into the orb (%HS-ORB-DRAW's code 3), and the right crescent let out in a flat sweep right to left at 3 m
;; (*HS-LETOUT*), unwound, the impact held to f32
(defpose :hs-kb-kaibaku-up (:base :hs-k-stance)
  (:root :u -0.2 :f -0.04 :yaw -34) (:pelvis :twist -12) (:spine :flex 10) (:chest :twist -40) (:neck :twist 30) (:head :flex -6)
  (:arm-r :flex -40 :side 60 :twist 0) (:elbow-r :flex 20) (:hand-r :flex -90)
  (:arm-l :flex 150 :side 30 :twist 0) (:elbow-l :flex 30) (:hand-l :flex -30)
  (:thigh-r :flex -20 :side 12) (:knee-r :flex 50) (:thigh-l :flex 40 :side 10) (:knee-l :flex 40))
(defpose :hs-kb-kaibaku-hit (:base :hs-k-stance)
  (:root :f 0.1 :u -0.14 :yaw 20) (:pelvis :twist 8) (:spine :flex 12) (:chest :twist 24) (:neck :twist -10) (:head :flex 0)
  (:arm-r :flex 60 :side 88 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex 160 :side 60 :twist 0) (:elbow-l :flex 10) (:hand-l :flex 20)
  (:thigh-l :flex 50 :side 10) (:knee-l :flex 50) (:thigh-r :flex -26 :side 12) (:knee-r :flex 20))
(defstrike :hs-kb-kaibaku (18 4 28 :base :hs-k-stance)
  (0 :hs-kb-stance)
  (5 :hs-kb-kaibaku-up (:root :yaw -20) (:chest :twist -24) (:arm-l :flex 110 :side 20))   ; gripped, hauled
  (11 :hs-kb-kaibaku-up)                                                                   ; coiled (held)
  (16 :hs-kb-kaibaku-up (:root :yaw -42 :u -0.22) (:chest :twist -46) (:arm-l :flex 160 :side 34))   ; cocked
  (:s :snap :hs-kb-kaibaku-hit)                                                            ; thrown off, the sweep
  (20 :hs-kb-kaibaku-hit (:root :yaw 34) (:chest :twist 34) (:arm-r :flex 110))
  (:a :hs-kb-kaibaku-hit (:root :yaw 46) (:chest :twist 40) (:arm-r :flex 130))
  (32 :hs-kb-kaibaku-hit (:root :yaw 44 :u -0.16) (:chest :twist 38) (:arm-r :flex 126) (:arm-l :flex 120))   ; held
  (40 :hs-k-stance (:root :u -0.1) (:spine :flex 8))
  (:end :hs-k-stance))

;; O 絞首 KOSHU: the zip along the noose chain (the aura and the dash: low, both hands forward on the chain) and the
;; strike (8/3/24, 2.0 m): both fists high, the chain taut between them over his head (held f4-6); drawn down and back
;; across his throat (the garrote: HISAGI-DRAW's slack through his neck within 1.8 m)
(defpose :hs-kb-koshu-run (:base :hs-k-stance)
  (:root :u -0.2) (:spine :flex 34) (:head :flex -24)
  (:arm-r :flex 120 :side 10 :twist 0) (:elbow-r :flex 20) (:hand-r :flex -40)
  (:arm-l :flex 110 :side 10 :twist 0) (:elbow-l :flex 24) (:hand-l :flex -40)
  (:thigh-l :flex 50 :side 8) (:knee-l :flex 60) (:thigh-r :flex -40 :side 8) (:knee-r :flex 40))
(defclip :hs-kb-koshu-run (0.4 :loop t :base :hs-kb-koshu-run)
  (0) (0.2 (:root :u -0.18) (:spine :flex 32)))
(defpose :hs-kb-koshu-up (:base :hs-k-stance)
  (:root :u -0.02) (:spine :flex -12) (:head :flex -10)
  (:arm-r :flex 164 :side 34 :twist 0) (:elbow-r :flex 20) (:hand-r :flex -30)
  (:arm-l :flex 164 :side 34 :twist 0) (:elbow-l :flex 20) (:hand-l :flex -30)
  (:thigh-l :flex 20 :side 10) (:knee-l :flex 14) (:thigh-r :flex -10 :side 10) (:knee-r :flex 14))
(defpose :hs-kb-koshu-hit (:base :hs-k-stance)
  (:root :f -0.1 :u -0.22) (:spine :flex -22) (:head :flex 6)
  (:arm-r :flex 50 :side 34 :twist 0) (:elbow-r :flex 110) (:hand-r :flex -30)
  (:arm-l :flex 50 :side 34 :twist 0) (:elbow-l :flex 110) (:hand-l :flex -30)
  (:thigh-l :flex 40 :side 10) (:knee-l :flex 50) (:thigh-r :flex -26 :side 10) (:knee-r :flex 30))
(defstrike :hs-kb-koshu (8 3 24 :base :hs-k-stance)
  (0 :hs-kb-koshu-run)
  (4 :hs-kb-koshu-up)
  (6 :hs-kb-koshu-up (:spine :flex -16) (:arm-r :flex 172) (:arm-l :flex 172))
  (:s :snap :hs-kb-koshu-hit)
  (:a :hs-kb-koshu-hit (:root :u -0.24) (:spine :flex -26))
  (26 :hs-kb-koshu-hit (:root :u -0.23) (:spine :flex -24))
  (:end :hs-k-stance))

;; P 解縛 KAIBAKU -> UNWIND (20 f, no hit): the chains go slack and fall off both necks (HISAGI-DRAW: the noose's ring
;; sliding down him), the crescents lowered to point down again
(defstrike :hs-kb-unwind (20 0 0 :base :hs-k-stance)
  (0 (:root :u -0.1) (:spine :flex -10) (:head :flex -14) (:arms :flex 60 :side 40) (:elbows :flex 30) (:hands :flex -60))
  (8 (:root :u -0.06) (:spine :flex -4) (:head :flex 0) (:arms :flex 30 :side 30) (:elbows :flex 20) (:hands :flex -70))
  (:end :hs-k-stance))

(defparameter *hs-bk-chains*
  '((:hs-k-sensa 6 2 13 16 20 28 5.9 0.8 -100 40 0.6 0)        ; J3: the hanging chain at his right swept round (§25.3: 5.9)
    ;; (B4a, §22.2: TSUISA's lance, NAGISA's reap, RAKUSA's line drops removed; B4c's route links play those clips as
    ;; stand-ins, their chains drawn by B4b)
    ;; (A3, §24.3: L SAHARAI's ring is a lash now, *HS-LASHES*)
    (:hs-k-raiden 8 0 20 23 30 38 9.3 1.1 0 0 0 4)           ; SP1: the neck bundle down the line (the bolt along it)
    (:hs-k-ame 9 0 30 34 38 46 1.8 0.05 12 12 0 0)             ; SP2: the first rain (f30) ...
    (:hs-k-ame 9 0 30 34 38 46 4.2 0.05 -6 -6 0 0)
    (:hs-k-ame 9 0 30 34 38 46 6.6 0.05 5 5 0 0)
    (:hs-k-ame 9 0 30 34 38 46 9.0 0.05 -3 -3 0 0)
    (:hs-k-ame 9 0 30 34 38 46 10.9 0.05 2 2 0 0)
    (:hs-k-ame 9 0 40 44 48 58 3.0 0.05 -12 -12 0 0)           ; ... and the second (f40)
    (:hs-k-ame 9 0 40 44 48 58 5.4 0.05 6 6 0 0)
    (:hs-k-ame 9 0 40 44 48 58 7.8 0.05 -4 -4 0 0)
    (:hs-k-ame 9 0 40 44 48 58 10.2 0.05 3 3 0 0)
    (:hs-k-ame 9 0 40 44 48 58 10.9 0.05 -2 -2 0 0)
    (:hs-k-kosa 8 0 20 22 28 38 10.0 1.2 0 0 0 8)            ; O: the neck bundle whipped down the lane
    (:hs-k-kubikake 0 2 24 28 36 50 7.35 1.1 0 0 0 3)          ; P: the left front one whirled overhead, cast (hooked)
    (:hs-kb-makigiri 2 6 20 24 30 40 2.8 0.95 70 -70 0 8)    ; the bind's K2: a left one flung across at the chest
    (:hs-kb-shibori 9 8 22 27 40 52 2.95 0.05 22 22 0 0)       ; K3: two dropped out of the orb, cinching
    (:hs-kb-shibori 9 8 22 27 40 52 2.95 0.05 -22 -22 0 0))
  "The Bankai's chain strikes (DUEL_HISAGI §21.8; a look): (clip src f0 f1 f2 f3 f4 r h az0 az1 lift flags). SRC: 0-7 the
hanging chain *HS-CURTAIN* [src] (its free end hauled up LIFT m and drawn in, taut, from clip frame F0 on, held near the
peak until S), 8 the neck bundle (lifted LIFT m), 9 a chain dropped out of the orb (falling in the last 3 frames before
F1). From F1 (the move's S) its free end is R m from his feet at H m up, AZ0 degrees off his facing (+ his left), swept to
AZ1 by F2, held to F3, home by F4 (a hanging chain hangs to its rest end and then runs level to the free end). FLAGS: 1
hooked in the victim's neck on a hit, 2 whirled overhead in the windup (0.9 m round, 2.6 m up), 4 / 8 hauled up into his
right / left fist in the windup (LIFT unused). The free end at the hit volume's edge on the hit frames (*HS-STRIKE-REACH*
for the links).")
(defparameter *hs-bk-chains-v*
  (let ((out nil))
    (dolist (x *hs-bk-chains* out)
      (let ((cell (assoc (first x) out)) (v (coerce (mapcar #'f32 (rest x)) 'f32vec)))
        (if cell (setf (cdr cell) (append (cdr cell) (list v))) (setf out (append out (list (list (first x) v))))))))
  "*HS-BK-CHAINS* by clip: (clip f32vec ...), each src f0 f1 f2 f3 f4 r h az0 az1 lift flags.")
(defparameter *hs-bolts* '((:hs-s-raiden 6.5) (:hs-k-raiden 9.3) (:hs-kb-raiden 4.3))
  "Clip -> TSUZURI RAIDEN's bolt along his line (m: from 0.5 to about this, the volume's far edge; the Shikai's 6.5).")
(defparameter *hs-lashes*
  '((:hs-k-hosoku 255 0 1.0 2 30                    ; K1 綁束: all eight hauled in and up, whirled out to 4.0 m round him
     (6 0.8 2.4 0 45 0) (13 0.6 2.8 40 45 0.2) (15 0.9 2.2 70 45 0)          ;  (the orb winding), the spin a key each 90 deg
     (16 4.0 1.0 100 45 0.6) (17 4.0 1.0 190 45 0.4) (18 4.0 1.0 280 45 0.3) (19 4.0 1.0 370 45 0.2)
     (21 3.0 1.1 430 45 0.2) (25 1.6 1.0 470 45 0))                             ;  wound in: the bundle (*HS-BUNDLED*)
    (:hs-k-s-k2 102 0.34 0.8 7 42                   ; spread K2: hanging chains 1 2 5 6 hauled up behind him, over the top,
     (10 1.5 2.8 140 27 0) (17 1.7 3.6 145 27 0.3) (19 0.6 4.6 150 27 0)        ;  whipped onto the ground in a 60 deg fan
     (20 2.2 3.4 30 -20 1.0) (21 4.0 0.05 30 -20 0.8) (24 4.0 0.05 30 -20 -0.6) (30 3.8 0.05 30 -20 -0.8))
    (:hs-k-s-k3 255 0.45 0.85 7 50                  ; spread K3: all eight drawn back high behind him, lashed forward in a
     (9 1.7 2.6 110 20 0) (18 2.0 3.0 112 20 0.3) (20 2.2 2.8 114 20 0)       ;  160 deg fan (a third of a frame apart)
     (21 4.0 0.9 80 -22.857 0.6) (25 4.0 0.8 80 -22.857 0.2) (34 3.6 0.25 80 -22.857 -0.6))
    (:hs-k-g-k2 256 0 1.0 6 58                      ; gathered K2: the bundle heaved up behind him, over: the U onto 4.0 m,
     (9 1.2 2.2 -60 0 0) (16 1.4 4.4 -150 0 0.4) (24 1.6 4.8 -158 0 0.5)       ;  then its tail lashed flat along the ground at
     (26 0.6 5.4 -20 0 0) (27 4.0 0.25 0 0 2.4) (30 4.0 0.2 0 0 1.4)           ;  4.0 m (the L; §25.3: K 1-4 m), left lying
     (31 3.6 0.12 0 0 -0.4) (33 4.0 0.1 0 0 -1.6) (36 4.0 0.1 0 0 -1.8) (46 3.9 0.05 0 0 -2.0))   ;  flat ahead
    (:hs-k-g-k3 256 0 1.0 5 58                      ; gathered K3: the lying bundle hauled in and round to his right, whirled
     (6 3.9 0.05 0 0 -2.0) (14 4.0 0.15 -10 0 -1.2) (20 4.0 0.4 -60 0 -0.4)    ;  round him at 4.0 m (a key each 90 deg)
     (25 4.0 0.6 -100 0 0) (26 4.0 0.7 -110 0 0) (27 4.0 0.8 -20 0 0.3) (28 4.0 0.8 70 0 0.3) (29 4.0 0.8 160 0 0.3)
     (30 4.0 0.8 250 0 0.3) (31 4.0 0.8 340 0 0.3) (34 3.8 0.6 380 0 0) (42 3.4 0.3 400 0 -0.4))
    (:hs-k-g-j2 256 0 1.0 1 30                      ; gathered J2: the bundle cocked back by his right hip, lashed straight
     (5 1.0 1.2 -120 0 0) (13 1.5 1.5 -140 0 0.2) (15 1.2 1.6 -100 0 0)        ;  down the line at the chest, a wave along it
     (16 6.0 1.0 0 0 0.6) (17 6.0 1.0 0 0 -0.4) (18 6.0 1.0 0 0 0.25) (20 5.8 0.9 0 0 -0.15))
    (:hs-k-g-j3 256 0 1.0 1 36                      ; gathered J3: the bundle drawn round behind his right, swept flat
     (5 2.0 0.9 -100 0 0) (13 2.6 0.9 -135 0 0.2) (15 2.8 0.9 -140 0 0)        ;  through the front half at 6.0 m
     (16 6.0 0.8 -90 0 0.3) (17 6.0 0.8 0 0 0.3) (18 6.0 0.8 90 0 0.3) (20 5.6 0.7 130 0 0) (24 5.4 0.5 140 0 -0.3))
    (:hs-k-saharai 255 0.2 0.9 0 44                 ; A3 (§24.3): L SAHARAI, all eight wrapped in tight round him, lashed out
     (4 0.7 1.5 20 45 0) (9 0.55 1.3 35 45 0.2)                                ;  in a ring to 3.0 m on S (f10-13), fallen to
     (10 3.0 1.0 60 45 0.7) (11 3.0 0.95 75 45 0.5) (13 3.0 0.85 95 45 0.3)    ;  the floor (the impact hold), dragged in along
     (14 3.0 0.7 100 45 0.1) (18 2.9 0.1 108 45 -0.4) (26 2.4 0.05 112 45 -0.6) ;  it as he hauls, lifted back into the curtain
     (34 1.6 0.4 116 45 -0.2)))                                                 ;  by f44
  "The ranged route links' lashes (batch A2, DUEL_HISAGI §24.2; a look): (clip mask ds w f0 f1 key ...). MASK: the
hanging chains used (bits 0-7, *HS-CURTAIN*; their rank in the mask spreads them) or 256 the bundle (all eight bound
together, *HS-BUNDLED*). A key (f r h az dz bend): at clip frame F the chain of rank k has its free end R m from his feet
at H m up, AZ + k DZ degrees off his facing (+ his left; the short way round between keys), its middle lifted BEND m
(< 0: laid along the floor); eased between keys 4 f or more apart, linear nearer; the chain of rank k DS k frames late;
from its rest (the carousel's) from F0 to the first key and back from the last to F1; W its width x. Each is drawn from
the orb by %HS-CURTAIN-DRAW as a cubic down past him and out to its end, lagging behind its motion, tapered, with a trail;
its end on the keys at the hit volume's far edge on the hit frames (*HS-STRIKE-REACH*, the host checks).")
(defun hs-lash-vec (x)
  "A *HS-LASHES* entry as its f32vec: mask ds w f0 f1 n, then n keys of six."
  (destructuring-bind (mask ds w f0 f1 &rest keys) x
    (coerce (mapcar #'f32 (append (list mask ds w f0 f1 (length keys)) (apply #'append keys))) 'f32vec)))
(defparameter *hs-lashes-v*
  (let ((out nil))
    (dolist (x *hs-lashes* out)
      (let ((cell (assoc (first x) out)) (v (hs-lash-vec (rest x))))
        (if cell (setf (cdr cell) (append (cdr cell) (list v))) (setf out (append out (list (list (first x) v))))))))
  "*HS-LASHES* by clip: (clip f32vec ...).")
(defparameter *hs-bundled* '((:hs-k-hosoku 21 26) (:hs-k-g-k2 -2 -1) (:hs-k-g-k3 -2 -1) (:hs-k-g-j2 -2 -1) (:hs-k-g-j3 -2 -1))
  "Clip -> the clip frames over which the eight hanging chains are bound into one bundle (0 -> 1; bound after; the gathered
links bound throughout): K1 綁束 binds them, the gathered links strike with the bundle (the user, 2026-10-18: 「K1 將垂降的
鎖鏈在身旁旋轉並捆成一束」, DUEL_HISAGI §22.4). Out of these clips the bundle comes apart into the curtain over 0.25 s.")
(defparameter *hs-bundled-v* (mapcar (lambda (x) (cons (first x) (coerce (mapcar #'f32 (rest x)) 'f32vec))) *hs-bundled*)
  "*HS-BUNDLED* as (clip . f32vec).")
(defparameter *hs-bundle-rest* '(-35.0 1.25 0.9)
  "Where the bundle's free end hangs (degrees off his facing, m from his feet, m up): at his right front, by his right fist.")
(defparameter *hs-spins*
  '((:hs-k-saben 5 12 20 0.5) (:hs-k-kaeshi 5 11 19 -0.5) (:hs-k-sensa 5 13 24 1.0) (:hs-k-saharai 3 10 24 1.0)
    (:hs-k-raiden 7 20 30 0.5) (:hs-k-ame 8 30 50 1.0) (:hs-k-kosa 7 20 30 0.5) (:hs-k-kubikake 5 24 34 1.0)
    (:hs-k-hosoku 6 16 26 1.0) (:hs-k-s-k2 9 21 30 0.5) (:hs-k-s-k3 8 21 32 0.75) (:hs-k-g-k2 8 27 40 0.75)
    (:hs-k-g-k3 6 27 36 1.0) (:hs-k-g-j2 3 16 22 0.5) (:hs-k-g-j3 4 16 22 0.75))
  "The carousel's jerk (batch A2, DUEL_HISAGI §24.2; the user, 2026-10-18: §22.1's 旋鎖陣, 「遠程攻擊有效利用鎖鏈球拉動垂鏈迴轉
對遠程進行抽打」): the ranged mode's strike clip -> (f0 f1 f2 turns): the orb (and the hanging chains round him) spun TURNS
turns (+ counter-clockwise from above) on top of its slow turn, winding up from clip frame F0, fastest at F1 (S), done by F2.")
(defparameter *hs-spins-v* (mapcar (lambda (x) (cons (first x) (coerce (mapcar #'f32 (rest x)) 'f32vec))) *hs-spins*)
  "*HS-SPINS* as (clip . f32vec).")
(defparameter *hs-car-w* 0.25 "The orb's slow turn at rest (rad/s, counter-clockwise from above): the hanging chains orbit
him with it (§22.1, batch A2; the orb's own 0.25 of §21.6).")
(defparameter *hs-kb-grips* '((:hs-kb-stance 9999 0) (:hs-kb-walk-f 9999 0) (:hs-kb-walk-b 9999 0) (:hs-kb-strafe-r 9999 0)
                               (:hs-kb-strafe-l 9999 0) (:hs-kb-kojo 30 9) (:hs-kb-kaibaku 18 5))
  "The bind's clips in which his left fist holds a chain run to the opponent's noose (§22.1: 「the noose taut」): (clip F1
FT): held to clip frame F1; slack (sagging) until FT, then taut, trembling from FT on when FT > 0 (batch A3, §24.3: L
KOJO's heave, f9-19, held through its drag to S; SP2 KAIBAKU-GEKI's haul, thrown off on its S).")
(defparameter *hs-kb-grips-v* (mapcar (lambda (x) (cons (first x) (coerce (mapcar #'f32 (rest x)) 'f32vec))) *hs-kb-grips*)
  "*HS-KB-GRIPS* as (clip . f32vec).")

;;; ---------------------------------------------------------------- looks (cosmetic; the sim's points, 0 B a frame)
;; (every float crosses a call through these f32vecs: a float argument boxes; 0 B a frame, debug 83901)
(declaim (type f32vec *hs-v* *hs-w* *hs-q* *hs-a* *hs-m* *hs-m2* *hs-ml* *hs-lo* *hs-pt* *hs-grip-v*))
(defvar *hs-v* (make-f32 3) "The left sickle's grip (world).")
(defvar *hs-w* (make-f32 3) "A chain end (world).")
(defvar *hs-q* (make-f32 3) "A point (world).")
(defvar *hs-a* (make-f32 4) "HISAGI-DRAW's floats: [0] his facing yaw, [1] the flight's reach (m), [2] the bolt's length
(*HS-BOLTS*), [3] the Shikai's looks (1: the chain through the left fist, the flat spinning disc; 0: the Bankai's forms).")
(defvar *hs-m* (m4) "The left sickle's world matrix.")
(defvar *hs-m2* (m4) "A joint's matrix (scratch).")
(defvar *hs-ml* (m4) "The let-out left sickle's world matrix (%HS-LETOUT!).")
(defvar *hs-lo* (make-f32 16)
  "The let-outs (%HS-LETOUT!): [0] the right one's u (0 in the fist .. 1 out; HS-POSE, read by the draw hook of the same
fighter right after), [1-3] its fist, [4-6] its butt, [7] its point's distance from his feet (m, the tip table); [8] the
left one's u, [9-11] its fist, [12-14] its butt, [15] its point's distance.")
(defvar *hs-pt* (make-f32 3) "The left sickle's point the draw hook placed (%HS-POINT code 5: the windmill, SHIBARI's wrap).")
(declaim (type f32vec *hs-foe-d*))
(defvar *hs-foe-d* (make-f32 1)
  "A1 (DUEL_HISAGI §24.1): [0] how far (m, on the ground) the last draw placed the left sickle off the victim's feet on an
*HS-FOE-PATHS* path (-1: none; debug 83902).")
(defvar *hs-grip-v* (make-f32 3) "[0-1] each side's drawn grip slide (m, HS-POSE eases it to its clip's *HS-GRIP*); [2] the
last draw's effect seconds (HISAGI-DRAW keeps it for the next pose: the pose hook has no dt).")

(declaim (type f32vec *hs-ks*))
(defvar *hs-ks* (let ((v (make-f32 3))) (setf (aref v 0) 1f0 (aref v 1) (f32 (mv-reach (find-move :hs-k1))) (aref v 2) (f32 *hs-charge-step*)) v)
  "S1 (DUEL_HISAGI §23.1): [0] the drawn fighter's charge x (%HS-KS!: the windmill's disc, the K string's strikes), [1] K1
NAGE's line at x1 (its flight grows by it: HS-SCALED-TIP), [2] *HS-CHARGE-STEP*.")
(defun-fast %hs-ks! (n)
  "*HS-KS* [0] := the reach x of a charge of N frames (HS-CHARGE-SCALE's, in f32). 0 B."
  (declare (fixnum n))
  (let ((n (min n *hs-charge-max*))) (declare (fixnum n)) (setf (aref *hs-ks* 0) (+ 1f0 (* (aref *hs-ks* 2) (i->f n)))))
  nil)
(defun-fast %hs-fa-ks! (fa)
  "FA [1] (a flight's drawn reach) grown by the charge: + K1's line x (x - 1) (HS-SCALED-TIP; x1 elsewhere). 0 B."
  (declare (type f32vec fa))
  (setf (aref fa 1) (+ (aref fa 1) (* (aref *hs-ks* 1) (- (aref *hs-ks* 0) 1f0))))
  nil)

(defparameter *hs-letout-v*
  (loop for (clip side f0 f1 f2 f3 r h az bulge) in *hs-letout*
        for sw = (consp az) for a1 = (if sw (second az) az)
        collect (list* clip side (coerce (mapcar #'f32 (list f0 f1 f2 f3 r (or h 0) (or a1 0) bulge (if az 1 0) (if h 1 0)
                                                             (if sw (first az) 0) (if sw (third az) 0) (if sw 1 0)))
                                         'f32vec)))
  "*HS-LETOUT* as (clip side . f32vec): f0 f1 f2 f3 r h az bulge az-p h-p, then a sweep's a0 a2 sweep-p (az its a1).")
(defun hs-letout-of (name side)
  "The let-out entry (an f32vec) of clip NAME's SIDE (:r / :l), or NIL. 0 B."
  (loop for x in *hs-letout-v* when (and (eq (first x) name) (eq (second x) side)) return (cddr x)))

(defun-fast %hs-letout! (m jm wj upper pos yaw kv fr out o)
  "M := a let-out sickle's weapon matrix (KV its *HS-LETOUT-V* entry at clip frame FR, FR an f32vec [0]): WJ its weapon
joint as the clip posed it (the fist; the held rod along its -Z), UPPER the shoulder (the arm's line), POS his feet, YAW
(an f32vec [0]) his facing. OUT[O] := u (smoothstep: 0 in the fist .. 1 out at R m from his feet), OUT[O+1..3] := the fist
(the chain's near end), OUT[O+4..6] := the sickle's butt (its far end). Its point: from the held point (u 0) to R m out
along the fist's bearing from his feet (or AZ degrees off his facing, or a sweep's), H m up (or on the arm's line), BULGE m higher
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
         (az (cond ((< (aref kv 12) 0.5f0) (aref kv 6))      ; (A1: a sweep, a0 -> a1 out to F1, -> a2 by F2)
                   ((< f f1) (+ (aref kv 10) (* x (- (aref kv 6) (aref kv 10)))))
                   ((< f f2) (+ (aref kv 6) (* (/ (- f f1) (f-max 1f0 (- f2 f1))) (- (aref kv 11) (aref kv 6)))))
                   (t (aref kv 11))))
         (a (+ (aref yaw 0) (* 0.017453292f0 az)))
         (bx (cond ((> (aref kv 8) 0.5f0) (- (f-sin a))) ((> rf 0.05f0) (/ dx rf)) (t (- (f-sin (aref yaw 0))))))
         (bz (cond ((> (aref kv 8) 0.5f0) (- (f-cos a))) ((> rf 0.05f0) (/ dz rf)) (t (- (f-cos (aref yaw 0))))))
         (r (* (aref kv 4) (aref *hs-ks* 0)))         ; (S1: KARI-OTOSHI's arc at the charge, x1 elsewhere)
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
    (declare (single-float f f0 f1 f2 f3 x u fx fy fz dhx dhy dhz px pz dx dz rf az a bx bz r sh slope ty lift k qx qy qz
                           ex ey ez el yx yy yz zl hx hz z0x z0y z0z dot z1x z1y z1z zn zx zy zz xx xy xz ox oy oz)
             (fixnum wo so))
    (setf (aref m 0) xx (aref m 1) xy (aref m 2) xz (aref m 3) 0f0
          (aref m 4) yx (aref m 5) yy (aref m 6) yz (aref m 7) 0f0
          (aref m 8) zx (aref m 9) zy (aref m 10) zz (aref m 11) 0f0
          (aref m 12) ox (aref m 13) oy (aref m 14) oz (aref m 15) 1f0
          (aref out o) u (aref out (+ o 1)) fx (aref out (+ o 2)) fy (aref out (+ o 3)) fz
          (aref out (+ o 4)) (- ox (* 0.22f0 yx)) (aref out (+ o 5)) (- oy (* 0.22f0 yy)) (aref out (+ o 6)) (- oz (* 0.22f0 yz))
          (aref out (+ o 7)) (f-hypot (- qx px) (- qz pz))))
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
    (%hs-ks! (hss-charge (hs e)))
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
(declaim (fixnum *hs-chain-ink*))
(defvar *hs-chain-ink* 0
  "1 while P2's Hisagi is drawn (HISAGI-DRAW): %HS-BLACK-KITE draws the original ink link instead (the toon INK palette:
its white edge), so a mirror's two sets of chains read apart. The user, 2026-10-18: 「始解的鎖鏈也同樣改成黑色，而 P2 的鎖鏈則
改成原本的白色」.")
(defmacro %hs-black-kite (x y z ux uy uz len w)
  "A solid black camera-facing kite centred at (X Y Z) along the unit (UX UY UZ), LEN long (0.6 ahead), half-width W,
pushed 0.1 m toward the eye (FX-SHARD's shape without its palette): the alpha batch at uv 0 is opaque, unshaded. While
*HS-CHAIN-INK* is 1 (P2) the original ink link instead (FX-SHARD, +PAL-INK+, W / 0.7: the width the black ones lost). 0 B."
  `(let* ((%x0 ,x) (%y0 ,y) (%z0 ,z) (%ux ,ux) (%uy ,uy) (%uz ,uz) (%len ,len) (%w0 ,w))
     (declare (single-float %x0 %y0 %z0 %ux %uy %uz %len %w0))
     (if (= *hs-chain-ink* 1)
         (fx-shard %x0 %y0 %z0 %ux %uy %uz %len (* 1.43f0 %w0) 0.03f0 (+ 700f0 (* 100f0 %w0)) +pal-ink+ 0.9f0)
         (let* ((%e (camera-eye *camera*)) (%x %x0) (%y %y0) (%z %z0)
                (%dx (- (aref %e 0) %x)) (%dy (- (aref %e 1) %y)) (%dz (- (aref %e 2) %z))
                (%d (f-max 1f-3 (f-hypot %dx %dy %dz))) (%p (f-min 0.1f0 (* 0.5f0 %d))) (%sc (/ (- %d %p) %d))
                (%x (+ %x (* %p (/ %dx %d)))) (%y (+ %y (* %p (/ %dy %d)))) (%z (+ %z (* %p (/ %dz %d))))
                (%sx (- (* %uy %dz) (* %uz %dy))) (%sy (- (* %uz %dx) (* %ux %dz))) (%sz (- (* %ux %dy) (* %uy %dx)))
                (%w (/ (* %w0 %sc) (f-max 1f-5 (f-hypot %sx %sy %sz)))) (%f (* 0.6f0 %len %sc)) (%b (* 0.4f0 %len %sc)))
           (declare (type f32vec %e) (single-float %x %y %z %dx %dy %dz %d %p %sc %sx %sy %sz %w %f %b))
           (with-fx-verts (%v %o :alpha 6)
             (vtx (+ %x (* %f %ux)) (+ %y (* %f %uy)) (+ %z (* %f %uz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
             (vtx (+ %x (* %w %sx)) (+ %y (* %w %sy)) (+ %z (* %w %sz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
             (vtx (- %x (* %b %ux)) (- %y (* %b %uy)) (- %z (* %b %uz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
             (vtx (+ %x (* %f %ux)) (+ %y (* %f %uy)) (+ %z (* %f %uz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
             (vtx (- %x (* %b %ux)) (- %y (* %b %uy)) (- %z (* %b %uz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
             (vtx (- %x (* %w %sx)) (- %y (* %w %sy)) (- %z (* %w %sz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0))))))

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
SHIBARI's wrap); A1's (*HS-FOE-PATHS*): 6 the victim's centre (*HS-ANCHOR-UP* over his feet: HS-FOE-SEG's end), 7 / 8 3.0 /
3.8 m over his feet, 9 the saw's wheel (0.8 m round the left fist, upright in his facing's plane, by the clip frame), 10 K1's
sweep end (6.0 m x the charge, 40 degrees to his right, 1.0 m up)."
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
      ((6 7 8) (let ((h (case code (6 (the single-float *hs-anchor-up*)) (7 3.0f0) (t 3.8f0))))
                 (declare (single-float h))
                 (setf (aref out 0) (aref vpos 0) (aref out 1) (+ (aref vpos 1) h) (aref out 2) (aref vpos 2))))
      (9 (let* ((fr (aref *hs-fr* 0)) (g (- fr 8f0)) (th (- 1.5707964f0 (* 0.1f0 g g))))   ; (spun up: faster each turn,
           (declare (single-float fr g th))                                                 ;  rolling forward)
           (joint-point! out jm (ji :weapon-l) 0f0 0f0 0f0)
           (setf (aref out 0) (+ (aref out 0) (* 0.8f0 (f-cos th) fx)) (aref out 1) (+ (aref out 1) (* 0.8f0 (f-sin th)))
                 (aref out 2) (+ (aref out 2) (* 0.8f0 (f-cos th) fz)))))
      (10 (let* ((r (* 6f0 (aref *hs-ks* 0))) (a (- yaw 0.6981317f0)))
            (declare (single-float r a))
            (setf (aref out 0) (- (aref pos 0) (* r (f-sin a))) (aref out 1) 1.0f0 (aref out 2) (- (aref pos 2) (* r (f-cos a))))))
      (t (setf (aref out 0) (+ (aref pos 0) (* (the single-float *hs-hand-ahead*) fx))
               (aref out 1) (+ (aref pos 1) (the single-float *hs-hand-up*))
               (aref out 2) (+ (aref pos 2) (* (the single-float *hs-hand-ahead*) fz))))))
  nil)

(defun-fast %hs-place! (m v fa spin)
  "M := the flying sickle's world matrix: its grip at V, turned to his facing FA[0], its blade pitched forward (SPIN 0),
tumbling with the fx clock (SPIN 1), or spun flat about its blades' crossing (SPIN 2: the Shikai's thrown disc, the
crossing 0.6 m short of V's point, so its far edge stays within 0.15 m of it); A1's: SPIN 3 the upright saw (its blades'
crossing at V), 4 point down (its point at V). M4-EULER!'s layout, inline (its float
arguments would box)."
  (declare (type f32vec m v fa) (fixnum spin))
  (when (>= spin 3)                                                   ; A1: 3 the upright saw (its crossing at V, spun
    (let* ((fx (- (f-sin (aref fa 0)))) (fz (- (f-cos (aref fa 0))))  ;  rolling forward in his facing's plane, its top
           (a (* -30f0 (fx-clock))) (c (if (= spin 3) (f-cos a) 0f0))  ;  leant 30 degrees to his left so it reads as a
           (s (if (= spin 3) (f-sin a) -1f0))                          ;  disc from behind), 4 point down (its point at
           (kr (if (= spin 3) 0.5f0 0f0)) (ku (if (= spin 3) 0.8660254f0 1f0))   ;  V: the plunge); its plane's up
           (ux (* kr fz)) (uz (* (- kr) fx)))                          ;  U' = (KR fz, KU, -KR fx)
      (declare (single-float fx fz a c s kr ku ux uz))
      (setf (aref m 0) (* (- ku) fz) (aref m 1) kr (aref m 2) (* ku fx) (aref m 3) 0f0   ; (X = F x U')
            (aref m 4) (+ (* c fx) (* s ux)) (aref m 5) (* s ku) (aref m 6) (+ (* c fz) (* s uz)) (aref m 7) 0f0
            (aref m 8) (- (* c ux) (* s fx)) (aref m 9) (* c ku) (aref m 10) (- (* c uz) (* s fz)) (aref m 11) 0f0
            (aref m 15) 1f0)
      (let ((k (if (= spin 3) 0.5f0 0.75f0)))                         ; (the crossing 0.5 up the rod, the point 0.75)
        (declare (single-float k))
        (dotimes (i 3) (setf (aref m (+ 12 i)) (- (aref v i) (* k (aref m (+ 4 i))))))))
    (return-from %hs-place! nil))
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
his line, 0.5 m to FA[2] (*HS-BOLTS*). LO, the Shikai's looks (bits; 0: B2a's, the Bankai's): 1 the right sickle let out (HS-POSE: the chain from
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
                     (if (> (aref l 15) 5.5f0)                        ; (V: the left fist, the middle's far end;
                         (%hs-chain2 v q)                              ;  A1: K1's sweep taut, in two pieces)
                         (vfx-hs-chain v q 0.06f0 0.9f0)))
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
        (let* ((u (f-clamp (/ (i->f n) (i->f (max 1 d))) 0f0 1f0)) (ov (logand 7 (ash lo -8)))   ; (A1: a path's spin)
               (spin (cond ((> ov 0) ov) ((and (logtest lo 64) (/= a 2) (/= b 2) (/= b 4)) 2) ((= a b) 0) (t 1))))
          (declare (single-float u) (fixnum ov spin))
          (%hs-point v a jm pos fa anchor vpos)
          (%hs-point q b jm pos fa anchor vpos)
          (dotimes (i 3) (setf (aref v i) (+ (aref v i) (* u (- (aref q i) (aref v i))))))
          (setf (aref *hs-foe-d* 0)                                   ; (A1: how far it is placed off the victim, 83902)
                (if (> ov 0) (f-hypot (- (aref v 0) (aref vpos 0)) (- (aref v 2) (aref vpos 2))) -1f0))
          (when (logtest lo 128)                                      ; MAKI's curl: out to his left midway, in from there
            (let ((k (* 1.1f0 (f-sin (* 3.1415927f0 u)))) (yaw (aref fa 0)))
              (declare (single-float k yaw))
              (setf (aref v 0) (- (aref v 0) (* k (f-cos yaw))) (aref v 2) (+ (aref v 2) (* k (f-sin yaw))))))
          (%hs-place! m v fa spin)
          (draw-weapon :kazeshini m :tint tint)
          (when (= spin 3)                                            ; (A1: the saw's spin, three ink smears trailing
            (let ((dr (drawing-no)))                                  ;  its blades round V in its plane: M's Y and Z)
              (declare (single-float dr))
              (dotimes (j 3)
                (let* ((h (* 2.0943951f0 (i->f j))) (tq (+ h 1.5707964f0)) (mq (+ h 0.7853982f0))
                       (ch (* 0.55f0 (f-cos h))) (sh (* 0.55f0 (f-sin h))) (ct (* 0.55f0 (f-cos tq))) (st (* 0.55f0 (f-sin tq)))
                       (cm (* 0.7778f0 (f-cos mq))) (sm (* 0.7778f0 (f-sin mq))))
                  (declare (single-float h tq mq ch sh ct st cm sm))
                  (fx-crescent (+ (aref v 0) (* ct (aref m 4)) (* st (aref m 8))) (+ (aref v 1) (* ct (aref m 5)) (* st (aref m 9)))
                               (+ (aref v 2) (* ct (aref m 6)) (* st (aref m 10)))
                               (+ (aref v 0) (* ch (aref m 4)) (* sh (aref m 8))) (+ (aref v 1) (* ch (aref m 5)) (* sh (aref m 9)))
                               (+ (aref v 2) (* ch (aref m 6)) (* sh (aref m 10)))
                               (+ (aref v 0) (* cm (aref m 4)) (* sm (aref m 8))) (+ (aref v 1) (* cm (aref m 5)) (* sm (aref m 9)))
                               (+ (aref v 2) (* cm (aref m 6)) (* sm (aref m 10)))
                               0.06f0 :comet 0.03f0 (+ 900f0 dr (i->f j)) +pal-ink+ 0.85f0 :push 0.2f0)))))
          (if (>= spin 2)                                             ; (the disc, the saw, the plunge: its butt off M)
              (dotimes (i 3) (setf (aref v i) (+ (aref m (+ 12 i)) (* -0.22f0 (aref m (+ 4 i))))))
              (dotimes (i 3) (setf (aref v i) (- (aref v i) (* 0.22f0 (aref m (+ 4 i)))))))   ; (its butt: the rod is M's +Y)
          (if (logtest lo 4)                                          ; the thrower's hand: right rod -> left fist -> sickle
              (progn (joint-point! q jm (ji :weapon-l) 0f0 0f0 0f0)
                     (vfx-hs-chain w q -0.4f0 0.9f0)
                     (cond ((> ov 0) (%hs-chain2 q v))                ; (A1's paths: taut)
                           ((= a b) (vfx-hs-chain q v 0.12f0 0.9f0)) (t (vfx-hs-chain q v 0.04f0 0.9f0))))
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
      (let* ((yaw (aref fa 0)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (dr (drawing-no 24f0))
             (nb (1+ (f->i (* 2f0 (- (aref fa 2) 0.5f0))))))
        (declare (single-float yaw fx fz dr) (fixnum nb))
        (dotimes (i nb)
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
         (r (* (aref *hs-ks* 0) (if (< f 6f0) (+ 0.8f0 (* 1.2f0 (/ f 6f0))) (- 2.0f0 (* 0.4f0 e)))))   ; (S1: grows with the charge)
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
the flags (a fixnum): 1 the right let-out is out, 2 the opponent 0.5-5.5 m ahead, 4 within 1.8 m, 8 the clip frame < 24,
16 within 2.1 m. 0 B."
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
            (if (< (aref *hs-fr* 0) 24f0) 8 0) (if (< (aref g 0) 2.1f0) 16 0))))
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
(declaim (type f32vec *hs-cl*))
(defvar *hs-cl* (make-f32 5)
  "The B5 cinematics' hold on the orb's look (DUEL_HISAGI §22.7; HISAGI-DRAW fills it every call, %HS-CINE-LOOK! inside his
own cinematics): [0] the orb's growth 0-1 (its size, the light patch), [1] the curtain's drop 0-1 (each hanging chain's
length from the orb), [2] the neck bundle's descent 0-1 (below 1 it hangs that share of the way down, untied, no tail),
[3] metres added to the orb's height, [4] 1: the orb placed at once (no easing). The match: 1 1 1 0 0.")
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

(declaim (type f32vec *hs-e* *hs-kn* *hs-mid* *hs-tipv*))
(defvar *hs-e* (make-f32 3) "A Bankai chain strike's free end (%HS-BK-STRIKE).")
(defvar *hs-kn* (make-f32 3) "A Bankai chain strike's top, then its knee (%HS-BK-STRIKE).")
(defvar *hs-mid* (make-f32 3) "%HS-CHAIN2's midpoint.")
(defvar *hs-tipv* (make-f32 2)
  "The last Bankai draw's farthest chain-strike free end on its strike / hold frames: [0] its distance from his feet, [1]
how far along his facing (m; HISAGI-DRAW zeroes it; the tip table, debug 83902).")
(defun-fast %hs-chain2 (a b)
  "A taut chain from A to B (f32vecs), in two pieces past 5 m (VFX-HS-CHAIN's 48 links span ~5.8 m). 0 B."
  (declare (type f32vec a b))
  (let ((m *hs-mid*))
    (declare (type f32vec m))
    (if (> (f-hypot (- (aref b 0) (aref a 0)) (- (aref b 1) (aref a 1)) (- (aref b 2) (aref a 2))) 5f0)
        (progn (dotimes (i 3) (setf (aref m i) (* 0.5f0 (+ (aref a i) (aref b i)))))
               (vfx-hs-chain a m 0f0 0.9f0) (vfx-hs-chain m b 0f0 0.9f0))
        (vfx-hs-chain a b 0f0 0.9f0)))
  nil)

(defun-fast %hs-bk-mask (ks)
  "The hanging chains (bits 0-7) and the neck bundle's tail (bit 8) the chain strikes KS use at the clip frame *HS-FR*. 0 B."
  (let ((mask 0) (f (aref *hs-fr* 0)))
    (declare (fixnum mask) (single-float f))
    (dolist (x ks mask)
      (let ((kv x))
        (declare (type f32vec kv))
        (when (and (>= f (aref kv 1)) (< f (aref kv 5))) (setf mask (logior mask (ash 1 (f->i (aref kv 0))))))))))

;;; The carousel, the lashes, the bundle (batch A2, DUEL_HISAGI §24.2; a look, 0 B a frame)
(declaim (type f32vec *hs-car* *hs-cz* *hs-lt* *hs-lt2* *hs-rp* *hs-fr2* *hs-bundle-rest-v*))
(defvar *hs-car* (make-f32 10)
  "The carousel (§22.1's 旋鎖陣): [0-1] each side's orb phase (rad), [2-3] each side's last jerk (%HS-CAR!), [4-5] each
side's bundle weight, [6] this draw's phase (the orb's turn, the hanging chains' bearing), [7] this draw's bundle weight
(0 the eight hanging chains apart .. 1 bound into one bundle), [8] the orb's underside height this draw.")
(defvar *hs-car-clip* (make-array 2 :initial-element nil)
  "Each side's clip at the last draw: a strike's jerk is banked into the phase when the clip changes (no jump when a link
cuts it short).")
(defvar *hs-cz* (make-f32 (* 9 14))
  "Each chain's cubic this draw (%HS-CURVE!): the eight hanging chains then the bundle (8), each p0 p1 p2 p3 (12 floats),
its taper (its lash weight) and its width x.")
(defvar *hs-lt* (make-f32 8) "%HS-LASH-TIP!'s end: [0-2] the free end (world), [3] the bend, [4] the lash weight, [5] r, [6] az.")
(defvar *hs-lt2* (make-f32 8) "%HS-LASH-TIP!'s end at an earlier frame (the lag, the trail).")
(defvar *hs-rp* (make-f32 4) "%HS-REST-POLAR!: [0] r, [1] h, [2] az (degrees off his facing), [3] the sway (m).")
(defvar *hs-fr2* (make-f32 1) "An earlier clip frame for %HS-LASH-TIP!.")
(defvar *hs-bundle-rest-v* (coerce (mapcar #'f32 *hs-bundle-rest*) 'f32vec) "*HS-BUNDLE-REST* as floats.")
(defmacro %hs-wrap180 (x)
  "X (degrees) into -180 .. 180."
  `(let ((%a ,x)) (declare (single-float %a))
     (loop while (> %a 180f0) do (decf %a 360f0))
     (loop while (< %a -180f0) do (incf %a 360f0))
     %a))

(defun-fast %hs-car! (an side sv bv)
  "The carousel for the fighter on SIDE (0 / 1) at his clip frame *HS-FR* (AN his anim): the orb's phase turned *HS-CAR-W*
x the draw's effect seconds plus his strike clip's jerk (SV its *HS-SPINS-V* f32vec or NIL: TURNS turns, eased in from F0,
fastest at F1, out by F2; banked into the phase when his clip changes) -> *HS-CAR* [6]; the bundle weight (BV its
*HS-BUNDLED-V* ramp or NIL; coming apart at 4 /s out of it, at once on a still) -> [7]. 0 B."
  (declare (fixnum side))
  (let* ((cv *hs-car*) (f (aref *hs-fr* 0)) (dt (aref *hs-grip-v* 2)) (c (anim-clip an)) (cc *hs-car-clip*)
         (off 0f0) (tb 0f0))
    (declare (type f32vec cv) (type simple-vector cc) (single-float f dt off tb))
    (when sv
      (let* ((v sv) (f0 (aref v 0)) (f1 (aref v 1)) (f2 (aref v 2))
             (e (cond ((<= f f0) 0f0)
                      ((< f f1) (let ((x (/ (- f f0) (f-max 1f0 (- f1 f0))))) (declare (single-float x)) (* 0.35f0 x x)))
                      ((< f f2) (let ((y (- 1f0 (/ (- f f1) (f-max 1f0 (- f2 f1)))))) (declare (single-float y))
                                  (- 1f0 (* 0.65f0 y y))))
                      (t 1f0))))
        (declare (type f32vec v) (single-float f0 f1 f2 e))
        (setf off (* 6.2831855f0 (aref v 3) e))))
    (when bv
      (let ((v bv)) (declare (type f32vec v))
        (setf tb (f-clamp (/ (- f (aref v 0)) (f-max 0.5f0 (- (aref v 1) (aref v 0)))) 0f0 1f0))))
    (unless (eq c (svref cc side))
      (setf (aref cv side) (+ (aref cv side) (aref cv (+ 2 side))) (svref cc side) c))
    (setf (aref cv side) (f-mod (+ (aref cv side) (* (the single-float *hs-car-w*) (f-max 0f0 dt))) 6.2831855f0)
          (aref cv (+ 2 side)) off
          (aref cv 6) (+ (aref cv side) off)
          (aref cv (+ 4 side)) (if (> dt 0f0) (f-max tb (- (aref cv (+ 4 side)) (* 4f0 dt))) tb)
          (aref cv 7) (aref cv (+ 4 side))))
  nil)

(defun-fast %hs-rest-polar! (rp j)
  "RP := hanging chain J's rest (0-7: *HS-CURTAIN* turned by the carousel's phase *HS-CAR* [6], lifted 2.4 m and drawn in
where it passes ahead of him or behind him, so that none hangs between the fighters or before the behind camera; §21.6)
or the bundle's (8: *HS-BUNDLE-REST*, swaying): [0] r, [1] h, [2] az (degrees off his facing), [3] its sway (m). 0 B."
  (declare (type f32vec rp) (fixnum j))
  (let ((tm (fx-clock)))
    (declare (single-float tm))
    (if (< j 8)
        (let* ((cv *hs-curtain-v*) (b (aref cv (* 3 j))) (az (+ b (* 57.29578f0 (aref *hs-car* 6))))
               (s (f-abs (f-sin (* 0.017453292f0 az))))
               (x (f-clamp (/ (- s 0.3f0) 0.4f0) 0f0 1f0)) (wf (- 1f0 (* x x (- 3f0 (* 2f0 x))))))
          (declare (type f32vec cv) (single-float b az s x wf))
          (setf (aref rp 0) (* (aref cv (+ 1 (* 3 j))) (- 1f0 (* 0.35f0 wf)))
                (aref rp 1) (+ (aref cv (+ 2 (* 3 j))) (* 2.4f0 wf))
                (aref rp 2) az
                (aref rp 3) (* 0.05f0 (f-sin (+ (* 1.1f0 tm) b)))))
        (let ((br *hs-bundle-rest-v*))
          (declare (type f32vec br))
          (setf (aref rp 0) (aref br 1) (aref rp 1) (aref br 2) (aref rp 2) (+ (aref br 0) (* 4f0 (f-sin (* 0.7f0 tm))))
                (aref rp 3) 0f0))))
  nil)

(defun-fast %hs-lash-of (lk j)
  "The *HS-LASHES-V* entry of LK (his clip's) that moves chain J (0-7, 8 the bundle) at the clip frame *HS-FR*, or NIL."
  (declare (fixnum j))
  (let ((f (aref *hs-fr* 0)) (out nil))
    (declare (single-float f))
    (dolist (x lk out)
      (let ((kv x))
        (declare (type f32vec kv))
        (when (and (null out) (logbitp j (f->i (aref kv 0))) (>= f (aref kv 3)) (< f (aref kv 4))) (setf out kv))))))

(defun-fast %hs-lash-tip! (out kv fr rank j pos fa)
  "OUT := the free end of chain J (rank RANK in the entry KV, *HS-LASHES-V*) at the clip frame FR[0] less RANK x its
stagger: the keys' r h az bend (eased between keys 4 f or more apart, linear nearer, az the short way round), blended
from its rest (%HS-REST-POLAR!) before the first key and back to it after the last: [0-2] the end (world, from his feet
POS along FA[0] his facing), [3] the bend, [4] the lash weight (0 at rest .. 1 on the keys), [5] r, [6] az (deg). 0 B."
  (declare (type f32vec out kv fr pos fa) (fixnum rank j))
  (let* ((rk (i->f rank)) (f (- (aref fr 0) (* rk (aref kv 1))))
         (fs (aref kv 3)) (fe (aref kv 4)) (n (f->i (aref kv 5))) (kl (+ 6 (* 6 (1- n))))
         (rp *hs-rp*) (r 0f0) (h 0f0) (az 0f0) (bd 0f0) (lw 1f0))
    (declare (single-float rk f fs fe r h az bd lw) (fixnum n kl) (type f32vec rp))
    (%hs-rest-polar! rp j)
    (cond ((< f (aref kv 6))                                           ; from rest to the first key
           (let* ((x (f-clamp (/ (- f fs) (f-max 1f0 (- (aref kv 6) fs))) 0f0 1f0)) (u (* x x (- 3f0 (* 2f0 x))))
                  (a1 (+ (aref kv 9) (* rk (aref kv 10)))))
             (declare (single-float x u a1))
             (setf r (+ (aref rp 0) (* u (- (aref kv 7) (aref rp 0)))) h (+ (aref rp 1) (* u (- (aref kv 8) (aref rp 1))))
                   az (+ (aref rp 2) (* u (%hs-wrap180 (- a1 (aref rp 2))))) bd (* u (aref kv 11)) lw u)))
          ((>= f (aref kv kl))                                         ; from the last key back to rest
           (let* ((x (f-clamp (/ (- f (aref kv kl)) (f-max 1f0 (- fe (aref kv kl)))) 0f0 1f0)) (u (* x x (- 3f0 (* 2f0 x))))
                  (a1 (+ (aref kv (+ kl 3)) (* rk (aref kv (+ kl 4))))))
             (declare (single-float x u a1))
             (setf r (+ (aref kv (+ kl 1)) (* u (- (aref rp 0) (aref kv (+ kl 1)))))
                   h (+ (aref kv (+ kl 2)) (* u (- (aref rp 1) (aref kv (+ kl 2)))))
                   az (+ a1 (* u (%hs-wrap180 (- (aref rp 2) a1)))) bd (* (- 1f0 u) (aref kv (+ kl 5))) lw (- 1f0 u))))
          (t (let ((i 6))                                               ; between two keys
               (declare (fixnum i))
               (loop while (and (< (+ i 6) kl) (>= f (aref kv (+ i 6)))) do (incf i 6))
               (let* ((f0 (aref kv i)) (f1 (aref kv (+ i 6))) (x (/ (- f f0) (f-max 0.001f0 (- f1 f0))))
                      (u (if (>= (- f1 f0) 4f0) (* x x (- 3f0 (* 2f0 x))) x))
                      (a0 (+ (aref kv (+ i 3)) (* rk (aref kv (+ i 4))))) (a1 (+ (aref kv (+ i 9)) (* rk (aref kv (+ i 10))))))
                 (declare (single-float f0 f1 x u a0 a1))
                 (setf r (+ (aref kv (+ i 1)) (* u (- (aref kv (+ i 7)) (aref kv (+ i 1)))))
                       h (+ (aref kv (+ i 2)) (* u (- (aref kv (+ i 8)) (aref kv (+ i 2)))))
                       az (+ a0 (* u (%hs-wrap180 (- a1 a0))))
                       bd (+ (aref kv (+ i 5)) (* u (- (aref kv (+ i 11)) (aref kv (+ i 5)))))
                       lw 1f0)))))
    (let ((a (+ (aref fa 0) (* 0.017453292f0 az))))
      (declare (single-float a))
      (setf (aref out 0) (+ (aref pos 0) (* r (- (f-sin a)))) (aref out 1) h (aref out 2) (+ (aref pos 2) (* r (- (f-cos a))))
            (aref out 3) bd (aref out 4) lw (aref out 5) r (aref out 6) az)))
  nil)

(defun-fast %hs-curve! (cz o tp e e2 pos)
  "CZ[O..O+11] := a chain's cubic from TP (its top under the orb) to E (its free end, as *HS-LT*: [3] the bend, [4] the
lash weight): at rest a straight line; lashing (weight 1) down from the orb past a knee near him (0.3 of the way out, 0.9 m
over its height, lower by a negative bend), then out to the end, its middle lifted by the bend and dragged back toward E2 (the end two frames
earlier: the lag, at most 1.8 m), no point under the floor; CZ[O+12] := the lash weight (its taper). 0 B."
  (declare (type f32vec cz tp e e2 pos) (fixnum o))
  (let* ((lw (aref e 4)) (ex (aref e 0)) (ey (aref e 1)) (ez (aref e 2)) (tx (aref tp 0)) (ty (aref tp 1)) (tz (aref tp 2))
         (lx (* 0.45f0 (- (aref e2 0) ex))) (ly (* 0.45f0 (- (aref e2 1) ey))) (lz (* 0.45f0 (- (aref e2 2) ez)))
         (ll (f-hypot lx ly lz)) (lk (if (> ll 1.8f0) (/ 1.8f0 ll) 1f0))
         (kx (+ (aref pos 0) (* 0.3f0 (- ex (aref pos 0))))) (kz (+ (aref pos 2) (* 0.3f0 (- ez (aref pos 2)))))
         (ky (f-max 1.3f0 (+ ey 0.5f0)))
         (s1x (+ tx (* 0.333f0 (- ex tx)))) (s1y (+ ty (* 0.333f0 (- ey ty)))) (s1z (+ tz (* 0.333f0 (- ez tz))))
         (s2x (+ tx (* 0.667f0 (- ex tx)))) (s2y (+ ty (* 0.667f0 (- ey ty)))) (s2z (+ tz (* 0.667f0 (- ez tz))))
         (q2x (+ (* 0.5f0 (+ kx ex)) (* lk lx))) (q2y (+ (* 0.5f0 (+ ky ey)) (aref e 3) (* lk ly)))
         (q2z (+ (* 0.5f0 (+ kz ez)) (* lk lz))))
    (declare (single-float lw ex ey ez tx ty tz lx ly lz ll lk kx kz ky s1x s1y s1z s2x s2y s2z q2x q2y q2z))
    (setf (aref cz o) tx (aref cz (+ o 1)) ty (aref cz (+ o 2)) tz
          (aref cz (+ o 3)) (+ s1x (* lw (- kx s1x)))                   ; (a chain laid on the floor: its knee lower)
          (aref cz (+ o 4)) (f-max 0f0 (+ s1y (* lw (- (+ ky 0.9f0 (f-min 0f0 (aref e 3))) s1y))))
          (aref cz (+ o 5)) (+ s1z (* lw (- kz s1z)))
          (aref cz (+ o 6)) (+ s2x (* lw (- q2x s2x))) (aref cz (+ o 7)) (f-max 0f0 (+ s2y (* lw (- q2y s2y))))
          (aref cz (+ o 8)) (+ s2z (* lw (- q2z s2z)))
          (aref cz (+ o 9)) ex (aref cz (+ o 10)) ey (aref cz (+ o 11)) ez
          (aref cz (+ o 12)) lw))
  nil)

(defun-fast %hs-cubic-chain (cz o j)
  "Draw hanging chain J's cubic CZ[O..] (%HS-CURVE!) link by link in black (%HS-BLACK-KITE), tapered toward its free end
by its lash weight, its width x CZ[O+13]; with the bundle weight *HS-CAR* [7] it is drawn that far onto the bundle's
cubic (CZ[112..]: the eight twisted round it, 4 turns, tight below, fanning out under the orb). 0 B."
  (declare (type f32vec cz) (fixnum o j))
  (let* ((bw (aref *hs-car* 7)) (ob 112) (cw (- 1f0 bw))
         (len (+ (* cw (+ (f-hypot (- (aref cz (+ o 3)) (aref cz o)) (- (aref cz (+ o 4)) (aref cz (+ o 1))) (- (aref cz (+ o 5)) (aref cz (+ o 2))))
                          (f-hypot (- (aref cz (+ o 6)) (aref cz (+ o 3))) (- (aref cz (+ o 7)) (aref cz (+ o 4))) (- (aref cz (+ o 8)) (aref cz (+ o 5))))
                          (f-hypot (- (aref cz (+ o 9)) (aref cz (+ o 6))) (- (aref cz (+ o 10)) (aref cz (+ o 7))) (- (aref cz (+ o 11)) (aref cz (+ o 8))))))
                 (* bw (+ (f-hypot (- (aref cz (+ ob 3)) (aref cz ob)) (- (aref cz (+ ob 4)) (aref cz (+ ob 1))) (- (aref cz (+ ob 5)) (aref cz (+ ob 2))))
                          (f-hypot (- (aref cz (+ ob 6)) (aref cz (+ ob 3))) (- (aref cz (+ ob 7)) (aref cz (+ ob 4))) (- (aref cz (+ ob 8)) (aref cz (+ ob 5))))
                          (f-hypot (- (aref cz (+ ob 9)) (aref cz (+ ob 6))) (- (aref cz (+ ob 10)) (aref cz (+ ob 7))) (- (aref cz (+ ob 11)) (aref cz (+ ob 8))))))))
         (n (min 120 (max 2 (f->i (/ len 0.12f0)))))
         (tp (+ (* cw (aref cz (+ o 12))) (* bw (aref cz (+ ob 12))))) (wx (aref cz (+ o 13))) (jp (* 0.7853982f0 (i->f j))))
    (declare (single-float bw cw len tp wx jp) (fixnum ob n))
    (dotimes (i n)
      (let* ((u (/ (+ 0.5f0 (i->f i)) (i->f n))) (v (- 1f0 u))
             (a (* v v v)) (b (* 3f0 v v u)) (c (* 3f0 v u u)) (d (* u u u))
             (da (* 3f0 v v)) (db (* 6f0 v u)) (dc (* 3f0 u u)))
        (declare (single-float u v a b c d da db dc))
        (macrolet ((bz (o k) `(+ (* a (aref cz (+ ,o ,k))) (* b (aref cz (+ ,o 3 ,k))) (* c (aref cz (+ ,o 6 ,k)))
                                 (* d (aref cz (+ ,o 9 ,k)))))
                   (bt (o k) `(+ (* da (- (aref cz (+ ,o 3 ,k)) (aref cz (+ ,o ,k))))
                                 (* db (- (aref cz (+ ,o 6 ,k)) (aref cz (+ ,o 3 ,k))))
                                 (* dc (- (aref cz (+ ,o 9 ,k)) (aref cz (+ ,o 6 ,k)))))))
          (let* ((px (bz o 0)) (py (bz o 1)) (pz (bz o 2)) (tx (bt o 0)) (ty (bt o 1)) (tz (bt o 2)))
            (declare (single-float px py pz tx ty tz))
            (when (> bw 0.001f0)                                           ; onto the bundle, twisted round it
              (let* ((bx (bz ob 0)) (by (bz ob 1)) (bzz (bz ob 2)) (gx (bt ob 0)) (gy (bt ob 1)) (gz (bt ob 2))
                     (gl (f-max 1f-4 (f-hypot gx gy gz))) (hl (f-hypot gx gz))
                     (n1x (if (> hl 1f-3) (/ (- gz) hl) 1f0)) (n1z (if (> hl 1f-3) (/ gx hl) 0f0))
                     (n2x (/ (* gy n1z) gl)) (n2y (/ (- (* gz n1x) (* gx n1z)) gl)) (n2z (/ (- (* gy n1x)) gl))
                     (rr (+ 0.05f0 (* 0.45f0 v v v v))) (ph (+ (* 25.132741f0 u) jp))
                     (ox (* rr (+ (* (f-cos ph) n1x) (* (f-sin ph) n2x)))) (oy (* rr (f-sin ph) n2y))
                     (oz (* rr (+ (* (f-cos ph) n1z) (* (f-sin ph) n2z)))))
                (declare (single-float bx by bzz gx gy gz gl hl n1x n1z n2x n2y n2z rr ph ox oy oz))
                (setf px (+ (* cw px) (* bw (+ bx ox))) py (+ (* cw py) (* bw (+ by oy))) pz (+ (* cw pz) (* bw (+ bzz oz)))
                      tx (+ (* cw tx) (* bw gx)) ty (+ (* cw ty) (* bw gy)) tz (+ (* cw tz) (* bw gz)))))
            (let ((tl (f-max 1f-4 (f-hypot tx ty tz))))
              (declare (single-float tl))
              (%hs-black-kite px (f-max 0.03f0 py) pz (/ tx tl) (/ ty tl) (/ tz tl) 0.13f0
                              (* (if (evenp i) 0.028f0 0.013f0) wx (- 1f0 (* 0.55f0 tp u))))))))))
  nil)

(defun-fast %hs-trail (kv rank j pos fa)
  "A lash's trail: chain J's free end (rank RANK in KV) back over the last 2 frames (*HS-LT* at the frame, *HS-LT2* at
each quarter frame back), a tapered black ribbon, when it moves faster than 1.2 m a frame (a strike, not a haul; the
bundle's twice as wide). 0 B."
  (declare (type f32vec kv pos fa) (fixnum rank j))
  (let* ((e *hs-lt*) (e2 *hs-lt2*) (fr2 *hs-fr2*) (q *hs-mid*) (f (aref *hs-fr* 0)) (w0 (if (= j 8) 0.06f0 0.03f0)))
    (declare (type f32vec e e2 fr2 q) (single-float f w0))
    (setf (aref fr2 0) (- f 1f0))
    (%hs-lash-tip! e2 kv fr2 rank j pos fa)
    (when (and (> (aref e 4) 0.5f0)
               (> (f-hypot (- (aref e 0) (aref e2 0)) (- (aref e 1) (aref e2 1)) (- (aref e 2) (aref e2 2))) 1.2f0))
      (setf (aref q 0) (aref e 0) (aref q 1) (aref e 1) (aref q 2) (aref e 2))
      (loop for k from 1 to 8
            do (setf (aref fr2 0) (- f (* 0.25f0 (i->f k))))
               (%hs-lash-tip! e2 kv fr2 rank j pos fa)
               (let* ((dx (- (aref q 0) (aref e2 0))) (dy (- (aref q 1) (aref e2 1))) (dz (- (aref q 2) (aref e2 2)))
                      (l (f-max 1f-3 (f-hypot dx dy dz))))
                 (declare (single-float dx dy dz l))
                 (%hs-black-kite (* 0.5f0 (+ (aref q 0) (aref e2 0))) (f-max 0.03f0 (* 0.5f0 (+ (aref q 1) (aref e2 1))))
                                 (* 0.5f0 (+ (aref q 2) (aref e2 2))) (/ dx l) (/ dy l) (/ dz l) (* 1.15f0 l)
                                 (* w0 (- 1f0 (/ (i->f k) 9f0))))
                 (setf (aref q 0) (aref e2 0) (aref q 1) (aref e2 1) (aref q 2) (aref e2 2))))))
  nil)

(defun-fast %hs-curtain-draw (pos fa c lk mask)
  "The hanging chains round him (§21.6) on the carousel, lashing and bound (batch A2, §24.2): each of the eight
*HS-CURTAIN* chains not in MASK (a §21.8 chain strike draws that one: %HS-BK-STRIKE) from its top under the orb (C its
centre) to its free end, at rest where the carousel has it (%HS-REST-POLAR!; a cinematic's drop *HS-CL* [1]) or lashing
on its entry of LK (his clip's *HS-LASHES-V*: %HS-LASH-TIP!, the lag, the trail), bound into one bundle by the weight
*HS-CAR* [7] (whose own entry, 256, moves it). POS his feet, FA[0] his facing. Its farthest free end on the keys into
*HS-TIPV*. 0 B."
  (declare (type f32vec pos fa c) (fixnum mask))
  (let* ((cz *hs-cz*) (e *hs-lt*) (e2 *hs-lt2*) (tp *hs-q*) (rp *hs-rp*) (fr *hs-fr*) (fr2 *hs-fr2*) (tv *hs-tipv*)
         (bot (aref *hs-car* 8)) (cl1 (aref *hs-cl* 1)) (bw (aref *hs-car* 7)) (yaw (aref fa 0)))
    (declare (type f32vec cz e e2 tp rp fr fr2 tv) (single-float bot cl1 bw yaw))
    (dotimes (jj 9)
      (let* ((j (if (= jj 0) 8 (1- jj))) (kv (%hs-lash-of lk j)) (o (* 14 j)))
        (declare (fixnum j o))
        (when (or (< j 8) kv (> bw 0.001f0))
          (%hs-rest-polar! rp j)
          (let* ((a (+ yaw (* 0.017453292f0 (aref rp 2)))) (r (aref rp 0))
                 (gx (+ (aref pos 0) (* r (- (f-sin a))))) (gz (+ (aref pos 2) (* r (- (f-cos a))))))
            (declare (single-float a r gx gz))
            (if (= j 8)
                (setf (aref tp 0) (aref c 0) (aref tp 1) bot (aref tp 2) (aref c 2))
                (setf (aref tp 0) (+ (aref c 0) (* 0.6f0 (- gx (aref c 0)))) (aref tp 1) bot
                      (aref tp 2) (+ (aref c 2) (* 0.6f0 (- gz (aref c 2))))))
            (if kv
                (let* ((kv kv) (rank (if (= j 8) 0 (logcount (logand (f->i (aref kv 0)) (1- (ash 1 j)))))))
                  (declare (type f32vec kv) (fixnum rank))   ; (bound, not a free declaration: a typed aref, 0 B)
                  (setf (aref fr2 0) (- (aref fr 0) 2f0))
                  (%hs-lash-tip! e2 kv fr2 rank j pos fa)
                  (%hs-lash-tip! e kv fr rank j pos fa)
                  (setf (aref cz (+ o 13)) (aref kv 2))
                  (when (>= (aref e 4) 0.99f0)
                    (setf (aref tv 0) (f-max (aref tv 0) (aref e 5))
                          (aref tv 1) (f-max (aref tv 1) (* (aref e 5) (f-cos (* 0.017453292f0 (aref e 6)))))))
                  (%hs-curve! cz o tp e e2 pos)
                  (%hs-trail kv rank j pos fa))
                (progn
                  (setf (aref e 0) (+ gx (aref rp 3)) (aref e 1) (aref rp 1) (aref e 2) gz (aref e 3) 0f0 (aref e 4) 0f0
                        (aref cz (+ o 13)) 1f0)
                  (when (< cl1 1f0)                                     ; (a cinematic's drop: that share of its length)
                    (dotimes (i 3) (setf (aref e i) (+ (aref tp i) (* cl1 (- (aref e i) (aref tp i)))))))
                  (%hs-curve! cz o tp e e tp)))))))
    (dotimes (j 8)
      (unless (logbitp j mask) (%hs-cubic-chain cz (* 14 j) j))))
  nil)

(defun-fast %hs-bk-strike (kv pos fa c jm ojm hk)
  "One Bankai chain strike (*HS-BK-CHAINS*: KV its f32vec) at the clip frame *HS-FR*, drawn black: the hanging chain from
the orb's underside (C its centre) to its free end, the neck bundle's tail from the back of his neck (JM his joints, over
his right shoulder once out), or a chain dropped out of the orb; the free end hauled up taut (or whirled) in the windup,
snapped out on S to its strike point (R m along AZ off his facing FA[0] from his feet POS, H m up; swept, held, home),
hooked in the victim's neck (OJM) on a hit when HK is 1 and the strike hooks. Its farthest end on the strike / hold
frames into *HS-TIPV*. 0 B."
  (declare (type f32vec kv pos fa c jm ojm) (fixnum hk))
  (let* ((f (aref *hs-fr* 0)) (f0 (aref kv 1)) (f1 (aref kv 2)) (f2 (aref kv 3)) (f3 (aref kv 4)) (f4 (aref kv 5)))
    (declare (single-float f f0 f1 f2 f3 f4))
    (when (and (>= f f0) (< f f4))
      (let* ((src (f->i (aref kv 0))) (fl (f->i (aref kv 11))) (e *hs-e*) (kn *hs-kn*) (q *hs-q*) (tp *hs-tipv*)
             (yaw (aref fa 0)) (px (aref pos 0)) (pz (aref pos 2)) (r (aref kv 6)) (h (aref kv 7))
             (k (f-clamp (/ (- f f1) (f-max 1f0 (- f2 f1))) 0f0 1f0))
             (a (+ yaw (* 0.017453292f0 (+ (aref kv 8) (* k (- (aref kv 9) (aref kv 8)))))))
             (tx (+ px (* r (- (f-sin a))))) (tz (+ pz (* r (- (f-cos a)))))
             (bot (- (aref c 1) (* 0.75f0 (the single-float *hs-orb-scale*))))
             (rx tx) (ry 7f0) (rz tz) (ax tx) (ay 7f0) (az tz))
        (declare (fixnum src fl) (type f32vec e kn q tp) (single-float yaw px pz r h k a tx tz bot rx ry rz ax ay az))
        (cond ((< src 8)                                               ; a hanging chain: its rest end (on the
               (let* ((rp *hs-rp*) (cr (progn (%hs-rest-polar! rp src) (aref rp 0)))   ;  carousel, A2), its top
                      (ca (+ yaw (* 0.017453292f0 (aref rp 2))))
                      (gx (+ px (* cr (- (f-sin ca))))) (gz (+ pz (* cr (- (f-cos ca))))))
                 (declare (type f32vec rp) (single-float cr ca gx gz))
                 (setf rx (+ gx (aref rp 3)) ry (aref rp 1) rz gz
                       ax (+ (aref c 0) (* 0.6f0 (- gx (aref c 0)))) ay bot az (+ (aref c 2) (* 0.6f0 (- gz (aref c 2)))))))
              ((= src 8)                                               ; the neck bundle's tail
               (joint-point! kn jm (ji :neck) 0f0 0.07f0 0.06f0)
               (setf ax (aref kn 0) ay (aref kn 1) az (aref kn 2))
               (joint-point! kn jm (ji :spine) 0.12f0 -0.05f0 0.2f0)
               (setf rx (aref kn 0) ry (aref kn 1) rz (aref kn 2))))
        (if (< f f1)
            (let* ((x (f-clamp (/ (- f f0) (f-max 1f0 (* 0.6f0 (- f1 f0)))) 0f0 1f0)) (u (* x x (- 3f0 (* 2f0 x)))))
              (declare (single-float x u))
              (cond ((= src 9)                                         ; dropped: falling in the last 3 frames
                     (setf (aref e 0) tx (aref e 1) (+ 7f0 (* (f-clamp (/ (- f (- f1 3f0)) 3f0) 0f0 1f0) (- h 7f0)))
                           (aref e 2) tz))
                    ((logtest fl 2)                                    ; whirled overhead
                     (let ((wa (+ yaw (* 0.45f0 f))))
                       (declare (single-float wa))
                       (setf (aref e 0) (+ rx (* u (- (+ px (* 0.9f0 (- (f-sin wa)))) rx)))
                             (aref e 1) (+ ry (* u (- 2.6f0 ry)))
                             (aref e 2) (+ rz (* u (- (+ pz (* 0.9f0 (- (f-cos wa)))) rz))))))
                    ((logtest fl 12)                                   ; hauled up into his fist
                     (joint-point! q jm (if (logtest fl 4) (ji :weapon-r) (ji :weapon-l)) 0f0 0f0 0f0)
                     (setf (aref e 0) (+ rx (* u (- (aref q 0) rx))) (aref e 1) (+ ry (* u (- (aref q 1) ry)))
                           (aref e 2) (+ rz (* u (- (aref q 2) rz)))))
                    (t (setf (aref e 0) (+ rx (* u 0.35f0 (- px rx)))   ; hauled up taut, a tremble at the peak
                             (aref e 1) (+ ry (* u (aref kv 10)) (* 0.03f0 u (f-sin (* 2.7f0 f))))
                             (aref e 2) (+ rz (* u 0.35f0 (- pz rz)))))))
            (progn
              (if (and (= hk 1) (logtest fl 1))                        ; out: on the strike point, or hooked in him
                  (joint-point! e ojm (ji :neck) 0f0 0.07f0 0f0)
                  (setf (aref e 0) tx (aref e 1) h (aref e 2) tz))
              (if (>= f f3)                                            ; home
                  (let* ((x (f-clamp (/ (- f f3) (f-max 1f0 (- f4 f3))) 0f0 1f0)) (u (* x x (- 3f0 (* 2f0 x)))))
                    (declare (single-float x u))
                    (setf (aref e 0) (+ (aref e 0) (* u (- rx (aref e 0)))) (aref e 1) (+ (aref e 1) (* u (- ry (aref e 1))))
                          (aref e 2) (+ (aref e 2) (* u (- rz (aref e 2))))))
                  (let ((dx (- (aref e 0) px)) (dz (- (aref e 2) pz)))
                    (declare (single-float dx dz))
                    (setf (aref tp 0) (f-max (aref tp 0) (f-hypot dx dz))
                          (aref tp 1) (f-max (aref tp 1) (- (* dx (- (f-sin yaw))) (* dz (f-cos yaw)))))))))
        (setf (aref kn 0) ax (aref kn 1) ay (aref kn 2) az)
        (cond ((= src 9) (when (< (aref e 1) 6.9f0) (%hs-chain2 kn e)))
              ((< f f1) (%hs-chain2 kn e))
              ((= src 8)                                               ; over his right shoulder, then out
               (joint-point! q jm (ji :upper-arm-r) 0f0 0.1f0 0f0)
               (%hs-chain2 kn q) (%hs-chain2 q e))
              (t (setf (aref q 0) rx (aref q 1) (aref e 1) (aref q 2) rz) ; hanging to its rest end, then level out
                 (%hs-chain2 kn q) (%hs-chain2 q e))))))
  nil)

(declaim (type f32vec *hs-gc0* *hs-gc1*))
(defvar *hs-gc0* (make-f32 3) "%HS-GRIP-CHAIN's piece start (scratch).")
(defvar *hs-gc1* (make-f32 3) "%HS-GRIP-CHAIN's piece end (scratch).")
(defun-fast %hs-grip-chain (a b gv)
  "The bind's held chain from his fist A to the opponent's noose B (f32vecs; GV his clip's *HS-KB-GRIPS-V* entry) at the
clip frame *HS-FR*, black: nothing from F1 on; four pieces along a parabola, sagging 0.5 m eased out to taut by FT, then
taut with a tremble (2-4 cm, fast) while FT > 0. 0 B."
  (declare (type f32vec a b gv))
  (let* ((f (aref *hs-fr* 0)) (f1 (aref gv 0)) (ft (aref gv 1)) (g *hs-gc0*) (h *hs-gc1*)
         (x (if (> ft 0f0) (f-clamp (- 1f0 (/ f ft)) 0f0 1f0) 0f0)) (sag (* 0.5f0 x x))
         (tr (if (and (> ft 0f0) (>= f ft)) (* 0.03f0 (f-sin (* 2.9f0 f))) 0f0)))
    (declare (type f32vec g h) (single-float f f1 ft x sag tr))
    (when (< f f1)
      (if (and (<= sag 0f0) (= tr 0f0))
          (%hs-chain2 a b)
          (progn
            (dotimes (i 3) (setf (aref g i) (aref a i)))
            (dotimes (k 4)
              (let* ((u (* 0.25f0 (i->f (1+ k)))) (s (+ (* 4f0 sag u (- 1f0 u)) (* tr (f-sin (* 3.1415927f0 u))))))
                (declare (single-float u s))
                (setf (aref h 0) (+ (aref a 0) (* u (- (aref b 0) (aref a 0))))
                      (aref h 1) (- (+ (aref a 1) (* u (- (aref b 1) (aref a 1)))) s)
                      (aref h 2) (+ (aref a 2) (* u (- (aref b 2) (aref a 2)))))
                (vfx-hs-chain g h 0f0 0.9f0)
                (dotimes (i 3) (setf (aref g i) (aref h i)))))))))
  nil)

(defun-fast %hs-orb-draw (jm pos fa opos ojm side bound tint ks hk lk gp)
  "The Bankai's orb (DUEL_HISAGI §21.6), drawn by HISAGI-DRAW in both modes: its centre *HS-ORB-H* up and *HS-ORB-SIDE* to
his right, *HS-ORB-BACK* behind him (BOUND 1, a bind: over the pair's midpoint), eased there at 2.5 /s (placed at once on
a still or a jump > 8 m; SIDE 0 / 1 his slot in *HS-ORB-V*), swaying, turning slowly, *HS-ORB-SCALE* x its mesh; the pale
light patch under it (the inverted shadow); the curtain of chains hanging from it round him (*HS-CURTAIN*, moving with
him); the bundle of four chains twisted together from it down to the back of his neck (JM his joints, POS his feet, FA[0]
his facing) and its slack tail down his back; in a bind the same bundle to the opponent's neck (OPOS, OJM), tied twice
round it (BOUND 2, UNWIND: that ring sliding down him, slack). KS: his clip's chain strikes (*HS-BK-CHAINS-V*, §21.8):
each hanging chain or the tail one uses is drawn by %HS-BK-STRIKE instead (HK 1: his move hit). TINT: his body's (the
mirror's P2). Batch A2 (§24.2): the orb turns with the carousel's phase (%HS-CAR!, jerked on each strike), the hanging
chains orbit with it and lash or bind into the bundle on LK (his clip's *HS-LASHES-V*: %HS-CURTAIN-DRAW); GP in a bind
(his clip's *HS-KB-GRIPS-V* or NIL): his left fist holds a chain to the opponent's noose (%HS-GRIP-CHAIN). BOUND 3 (batch
A3, §24.3: KAIBAKU-GEKI from its S): the noose thrown off the opponent's neck and reeled up into the orb. 0 B."
  (declare (type f32vec jm pos fa opos ojm) (fixnum side bound))
  (let* ((ov *hs-orb-v*) (c *hs-oc*) (m *hs-om*) (v *hs-v*) (w *hs-w*) (q *hs-q*)
         (tm (fx-clock)) (yaw (aref fa 0)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw)))
         (cl *hs-cl*) (gr (aref cl 0))                                  ; (the B5 cinematics' hold: *HS-CL*)
         (sd (the single-float *hs-orb-side*)) (bk (the single-float *hs-orb-back*))
         (sc (* (f-max 0.05f0 gr) (the single-float *hs-orb-scale*)))
         (tx (if (= bound 1) (+ (* 0.5f0 (+ (aref pos 0) (aref opos 0))) (* sd rx)) (+ (aref pos 0) (* sd rx) (- (* bk fx)))))
         (tz (if (= bound 1) (+ (* 0.5f0 (+ (aref pos 2) (aref opos 2))) (* sd rz)) (+ (aref pos 2) (* sd rz) (- (* bk fz)))))
         (tx (+ tx (* 0.1f0 (f-sin (+ (* 0.6f0 tm) (* 2f0 (i->f side)))))))
         (ty (+ (the single-float *hs-orb-h*) (aref cl 3) (* 0.08f0 (f-sin (* 0.9f0 tm)))))
         (o (* 3 side)) (dt (aref *hs-grip-v* 2))
         (ex (- tx (aref ov o))) (ey (- ty (aref ov (+ o 1)))) (ez (- tz (aref ov (+ o 2))))
         (k (if (or (<= dt 0f0) (< (aref ov (+ 6 side)) 0.5f0) (> (+ (* ex ex) (* ey ey) (* ez ez)) 64f0) (> (aref cl 4) 0.5f0)) 1f0
                (f-min 1f0 (* 2.5f0 dt))))
         (s (aref *hs-car* 6)) (cs (* sc (f-cos s))) (ss (* sc (f-sin s))) (bot 0f0) (mask 0))   ; (the carousel, A2)
    (declare (type f32vec ov c m v w q cl) (fixnum o mask)
             (single-float tm gr yaw fx fz rx rz sd bk sc tx tz ty dt ex ey ez k s cs ss bot))
    (setf (aref ov o) (+ (aref ov o) (* k ex)) (aref ov (+ o 1)) (+ (aref ov (+ o 1)) (* k ey))
          (aref ov (+ o 2)) (+ (aref ov (+ o 2)) (* k ez)) (aref ov (+ 6 side)) 1f0
          (aref c 0) (aref ov o) (aref c 1) (aref ov (+ o 1)) (aref c 2) (aref ov (+ o 2))
          bot (- (aref c 1) (* 0.75f0 sc)) (aref *hs-car* 8) bot)
    (setf (aref m 0) cs (aref m 1) 0f0 (aref m 2) (- ss) (aref m 3) 0f0
          (aref m 4) 0f0 (aref m 5) sc (aref m 6) 0f0 (aref m 7) 0f0
          (aref m 8) ss (aref m 9) 0f0 (aref m 10) cs (aref m 11) 0f0
          (aref m 12) (aref c 0) (aref m 13) (aref c 1) (aref m 14) (aref c 2) (aref m 15) 1f0)
    (draw-weapon :hs-orb m :tint tint)
    (setf *hs-chain-black* 1 mask (%hs-bk-mask ks))
    ;; the inverted shadow: a pale patch on the ground under it
    (%sector-verts :add 20 (aref c 0) 0f0 (aref c 2) 0f0 (* 1.1f0 sc) 0f0 3.1415927f0 (* 0.2f0 gr) (* 0.21f0 gr) (* 0.2f0 gr)
                   0.5f0)
    (%hs-curtain-draw pos fa c lk mask)                                 ; the curtain round him (the carousel, A2)
    ;; his neck bundle: four chains twisted from the orb down behind his head, tied round his neck; its slack tail
    (setf (aref v 0) (aref c 0) (aref v 1) bot (aref v 2) (aref c 2))
    (if (< (aref cl 2) 1f0)                                             ; (a cinematic's descent: untied, partway down)
        (progn (joint-point! w jm (ji :neck) 0f0 0.24f0 0.2f0)
               (dotimes (i 3) (setf (aref w i) (+ (aref v i) (* (aref cl 2) (- (aref w i) (aref v i))))))
               (when (> (aref cl 2) 0.02f0) (%hs-bundle v w 4 3.0f0 0.05f0 0.45f0)))
        (%hs-tie v jm))
    (unless (or (logtest mask 256) (< (aref cl 2) 1f0))
      (joint-point! w jm (ji :neck) 0f0 0.07f0 0.06f0)
      (joint-point! v jm (ji :spine) 0.12f0 -0.05f0 0.2f0)
      (vfx-hs-chain w v 0.15f0 0.9f0))
    (dolist (x ks) (%hs-bk-strike x pos fa c jm ojm hk))                ; his chain strikes (§21.8)
    (when (= bound 2)                                                  ; UNWIND: the noose's ring slides off him, slack
      (let ((u (f-clamp (/ (aref *hs-fr* 0) 20f0) 0f0 1f0)))
        (declare (single-float u))
        (joint-point! w ojm (ji :neck) 0f0 0.07f0 0f0)
        (dotimes (i 20)
          (let* ((a (* 0.62831855f0 (i->f i))) (ca (f-cos a)) (sa (f-sin a)) (rr (+ 0.085f0 (* 0.3f0 u)))
                 (y (- (if (< i 10) -0.015f0 0.02f0) (* 1.4f0 u u))))
            (declare (single-float a ca sa rr y))
            (%hs-black-kite (+ (aref w 0) (* rr ca)) (+ (aref w 1) y) (+ (aref w 2) (* rr sa)) (- sa) 0f0 ca
                            0.075f0 (if (evenp i) 0.026f0 0.012f0))))))
    (when (= bound 1)                                                  ; the noose: the same bundle round his neck
      (setf (aref v 0) (aref c 0) (aref v 1) bot (aref v 2) (aref c 2))
      (%hs-tie v ojm)
      (joint-point! w ojm (ji :neck) 0f0 0.07f0 0f0)
      (dotimes (i 20)
        (let* ((a (* 0.62831855f0 (i->f i))) (ca (f-cos a)) (sa (f-sin a)) (y (if (< i 10) -0.015f0 0.02f0)))
          (declare (single-float a ca sa y))
          (%hs-black-kite (+ (aref w 0) (* 0.085f0 ca)) (+ (aref w 1) y) (+ (aref w 2) (* 0.085f0 sa)) (- sa) 0f0 ca
                          0.075f0 (if (evenp i) 0.026f0 0.012f0))))
      (when gp                                                         ; (A2: the bind's stance; A3: KOJO, KAIBAKU)
        (joint-point! w jm (ji :weapon-l) 0f0 0f0 0f0)
        (joint-point! q ojm (ji :neck) 0f0 0.24f0 0.2f0)
        (%hs-grip-chain w q gp)))
    (when (= bound 3)                                                  ; (A3: KAIBAKU-GEKI) thrown off, reeled up
      (let* ((u (f-clamp (/ (- (aref *hs-fr* 0) 18f0) 12f0) 0f0 1f0)) (k (* u u)) (rr (+ 0.085f0 (* 0.4f0 u))))   ; (its S 18)
        (declare (single-float u k rr))
        (when (< u 1f0)
          (setf (aref v 0) (aref c 0) (aref v 1) bot (aref v 2) (aref c 2))
          (joint-point! w ojm (ji :neck) 0f0 0.07f0 0f0)
          (setf (aref w 0) (+ (aref w 0) (* k (- (aref v 0) (aref w 0))) (* 1.2f0 u (- 1f0 u) rx))   ; (flung out to his right,
                (aref w 1) (+ (aref w 1) (* k (- (aref v 1) (aref w 1))) (* 1.6f0 u (- 1f0 u)))      ;  up, into the orb)
                (aref w 2) (+ (aref w 2) (* k (- (aref v 2) (aref w 2))) (* 1.2f0 u (- 1f0 u) rz)))
          (dotimes (i 20)
            (let* ((a (* 0.31415927f0 (i->f i))) (ca (f-cos a)) (sa (f-sin a)))
              (declare (single-float a ca sa))
              (%hs-black-kite (+ (aref w 0) (* rr ca)) (+ (aref w 1) (* 0.3f0 rr sa)) (+ (aref w 2) (* rr sa)) (- sa) 0f0 ca
                              (* 0.08f0 (+ 1f0 (* 3f0 u))) (if (evenp i) 0.026f0 0.012f0))))
          (%hs-bundle v w 4 3.0f0 0.05f0 0.45f0)))))
  (setf *hs-chain-black* 0)
  nil)


(defun hisagi-draw (e rdt)
  "His :draw hook (on the posed body): the left sickle (in his fist, flying, out at the anchor, returning, let out on its
chain), the chain, the windmill, the lightning. A look: every point is the sim's (the anchor, *HS-FLIGHTS*' reach,
HS-CHAIN-SEG's ends) or the clip's let-out (*HS-LETOUT*, at the strike's volume edge on its hit frames). The Shikai's looks
(DUEL_HISAGI §21.4) only in his base form; the Bankai's forms (§21.6, §21.8): the crescents in hand or let out on their hand
chains, the bolt (*HS-BOLTS*), KOSHU's garrote, plus the orb, its curtain, the neck bundle, a bind's noose and the chain
strikes (%HS-ORB-DRAW). Nothing while the sealed sword is in hand (the intro). In his own cinematics (B5, HS-CINE-OF) the
script's frame drives the rest (%HS-CINE-LOOK!: the awakening's Shikai look and the orb forming, KOSA's curtain hauled up,
KOSHU's noose and sinking orb, the Shikai Kikon's sickle flight HS-KARE-CODES)."
  (let* ((f (fighter e)) (m (model e)) (st (hs e)) (mv (and (eq (fighter-state f) :move) (eq (fighter-phase f) :main) (fighter-move f)))
         (name (and mv (mv-name mv))) (sf (fighter-sf f)) (o (opp-of e)) (fa *hs-a*) (bolt 0)
         (ck (hs-cine-of e)) (cf (if (> ck 0) (cine-cf *cine*) 0)) (cfl (%hs-cine-look! ck cf))
         (shikai (or (eq (fighter-form f) :base) (logtest cfl 1))) (lo 0) (geo 0) (an (model-anim m)) (c (anim-clip an))
         (cn (and c (clip-name c))))
    (when (and (> (model-alpha m) 0.5) (entity-alive-p o) (eq (model-weapon m) :kazeshini))
      (%hs-ks! (hss-charge st))                                       ; (S1: the charge's x for the windmill / K string)
      (setf geo (%hs-geo! an (pos-of e) (pos-of o) fa (transform e) (if shikai 1 0) rdt))
      (when (logtest geo 1) (setf lo 1))
      (let ((kv (hs-letout-of cn :l)))
        (if kv
            (progn
              (%hs-letout! *hs-ml* (model-joints m) (ji :weapon-l) (ji :upper-arm-l) (pos-of e) *hs-yaw* kv *hs-fr* *hs-lo* 8)
              (when (= 1 (%hs-left-out-p)) (setf lo (logior lo 2))))
            (setf (aref *hs-lo* 8) 0f0)))
      (let ((bl (and mv (assoc cn *hs-bolts*))))                        ; TSUZURI RAIDEN's bolt, every form's
        (setf (aref fa 2) (if bl (second bl) 6.5)
              bolt (if (and bl (< (- (mv-s mv) 3) sf (+ (mv-s mv) (mv-a mv) 5))) 1 0)))
      (multiple-value-bind (a b n d)
          (cond ((= ck 1) (values 0 0 0 1))                            ; (the awakening: the sickle in his fist)
                ((= ck 2)                                              ; (the Shikai Kikon's throw, return, KUBIKAKE)
                 (multiple-value-bind (a b n d l)
                     (hs-kare-codes cf fa (if (and (eq cn :hs-s-kubikake) (logtest geo 8) (logtest geo 4) (< cf 98)) 1 0))
                   (setf lo (logior lo l))
                   (values a b n d)))
                ((and shikai (eq (fighter-state f) :move) (eq (fighter-phase f) :follow))   ; the O's zip: hooked in him
                 (setf lo (logior lo 4)) (values 5 5 0 1))
                ((and shikai (fighter-follow f) (eq name :hs-kikon)) (values 0 0 0 1))   ; (the follow-up: a close cut)
                ((and shikai (member name *hs-kazas*))                 ; the windmill (S 6, A 60, R 14)
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
                ((and shikai mv (assoc cn *hs-foe-paths*))             ; A1: NOKO / TSUI placed on the victim (§24.1)
                 (let ((g (loop for g in (cdr (assoc cn *hs-foe-paths*)) when (and (<= (first g) sf) (< sf (second g))) return g)))
                   (if g
                       (destructuring-bind (f0 f1 a b sp) g
                         (setf lo (logior lo 4 (* 256 sp)))
                         (values (if (and (= a 10) (eq name :hs-k2j)) 0 a) b (- sf f0) (- f1 f0)))   ; (K2J: off J1, from the fist)
                       (values 0 0 0 1))))
                ((and mv (assoc name *hs-flights*))
                 (setf (aref fa 1) (second (assoc name *hs-flights*)))
                 (%hs-fa-ks! fa)                                       ; (S1: NAGE at the charge's reach)
                 (when shikai (setf lo (logior lo (if (eq name :hs-k2s) 196 68))))
                 (hs-flight-codes st name sf (mv-s mv) (mv-a mv)))
                ((and mv (member name *hs-pulls*))
                 (when shikai (setf lo (logior lo 16)))
                 (if (< sf (mv-s mv)) (values 2 2 0 1) (values 2 4 (- sf (mv-s mv)) (+ (mv-a mv) 2))))
                ((eq name :hs-modoshi) (when shikai (setf lo (logior lo 4))) (values 2 0 sf 6))
                ((eq (hss-state st) :ret) (when shikai (setf lo (logior lo 4)))
                 (values 2 0 (- *hs-return-frames* (hss-ret-t st)) *hs-return-frames*))
                ((eq (hss-state st) :out) (when shikai (setf lo (logior lo 4))) (values 2 2 0 1))
                (t (when (or (and (eq cn :hs-s-kubikake) (logtest geo 8) (logtest geo 4))
                             (and mv (eq cn :hs-kb-koshu) (>= sf (mv-s mv)) (logtest geo 16))
                             (and (= ck 4) (eq cn :hs-kb-koshu) (logtest geo 16) (= 1 (%hs-fr-from 8))))   ; (KOSHU's)
                     (setf lo (logior lo 8)))                          ; (KUBIKAKE's, KOSHU's garrote: through his neck)
                   (values 0 0 0 1)))
        (setf *hs-chain-black* 1 *hs-chain-ink* (if (eq e *p1*) 0 1))  ; (black, both forms; P2 the original ink: the user, 2026-10-18)
        (%hs-draw (model-joints m) (pos-of e) fa (hss-anchor st) (pos-of o) a b n d (model-tint m) bolt lo))
      (unless (or shikai (logtest cfl 2))                              ; the Bankai: the orb, its chains, the noose (§21.6)
        (setf (aref *hs-tipv* 0) 0f0 (aref *hs-tipv* 1) 0f0)            ; (and the chain strikes, §21.8)
        (%hs-car! an (if (eq e *p1*) 0 1) (cdr (assoc cn *hs-spins-v*)) (cdr (assoc cn *hs-bundled-v*)))   ; (A2: the carousel)
        (%hs-orb-draw (model-joints m) (pos-of e) fa (pos-of o) (model-joints (model o)) (if (eq e *p1*) 0 1)
                      (cond ((and mv (eq name :hs-b-sp2) (>= sf (mv-s mv))) 3)   ; (A3: KAIBAKU-GEKI's release)
                            ((or (hss-bound st) (logtest cfl 4)) 1) ((eq cn :hs-kb-unwind) 2) (t 0)) (model-tint m)
                      (cdr (assoc cn *hs-bk-chains-v*)) (if (and mv (eq (fighter-contact f) :hit)) 1 0)
                      (cdr (assoc cn *hs-lashes-v*)) (and (hss-bound st) (cdr (assoc cn *hs-kb-grips-v*))))))))

(defun hisagi-look-cons-check ()
  "Debug 83901 (P1 Hisagi): bytes consed by 10 calls of his :pose hook and HISAGI-DRAW in the stance, out at the anchor, in
K1 NAGI's hit frame, in K2 NOKO's (A1, §24.1: also its wheel, K3 TSUI's plunge and its sky, the leap J3K), in the windmill,
and (the Shikai's clips, §21.4) J1's short grip, J3's two let out, KARI-OTOSHI's,
SHIBARI's wrap and KUBIKAKE's garrote, and the Bankai's look (§21.6: the orb, the rope) in the stance and
with the noose of a bind, and the Bankai's clips (§21.8): J3's two let out and its swept chain, TSUISA's lance (hooked),
KUBIKAKE's whirl, SAHARAI's ring, SP1's bundle and bolt, SP2's rain, KOSA's whip, the bind's MAKIGIRI, SHIBORI's drops, KOSHU's
garrote, UNWIND's ring (B4a's marks gone), and batch A2's (§24.2): the route links' lashes, trails and the bundle (K1
HOSOKU's spin and binding, spread K2 / K3, gathered K2 SOKUDA's U and L, K3 SOKUSEN, J2 SOKUBEN, J3 SOKUTEI), the bind's
stance with the noose held taut, and batch A3's (§24.3): SAHARAI's ring lash in its recovery, KOJO's heave (the held chain
trembling) and its reap, KAIBAKU-GEKI's haul and its throw-off (the noose reeled up): each must be 0."
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
             (nage (progn (at :hs-k1 18 :hs-s-nagi) (bytes)))                     ; (A1, §24.1: K1's sweep, K2's
             (hiki (progn (at :hs-k2 21 :hs-s-noko) (bytes)))                     ;  saw on him, its wheel, K3's
             (a1 (list (progn (at :hs-k2 12 :hs-s-noko) (bytes)) (progn (at :hs-k3 23 :hs-s-tsui) (bytes))   ;  plunge,
                       (progn (at :hs-k3 19 :hs-s-tsui) (bytes)) (progn (at :hs-j3k 15 :hs-s-tobi-rin) (bytes))))   ;  the sky, the leap J3)
             (kaza (progn (at :hs-kaza 20 :hs-s-kaza) (bytes)))
             (grip (progn (setf (hss-state st) :in) (at :hs-j1 9 :hs-s-sen) (bytes)))
             (rin (progn (at :hs-j3 10 :hs-s-rin) (bytes)))
             (kari (progn (at :hs-k3 24 :hs-s-kari) (bytes)))
             (ch (prog1 (progn (setf (hss-charge st) 40 (hss-kstr st) t)          ; (S1: a charge of x1.4)
                               (list (progn (at :hs-kaza-j 30 :hs-s-kaza) (bytes))
                                     (progn (at :hs-k1 19 :hs-s-nagi) (setf (fighter-move f) (hs-scaled :hs-k1 40)) (bytes))
                                     (progn (at :hs-k3 24 :hs-s-tsui) (setf (fighter-move f) (hs-scaled :hs-k3 40)) (bytes))))
                   (setf (hss-charge st) 0 (hss-kstr st) nil)))
             (shibari (progn (at :hs-shibari 30 :hs-s-shibari) (setf (fighter-contact f) :hit) (bytes)))
             (kubi (progn (setf (fighter-contact f) ct) (at :hs-breaker 9 :hs-s-kubikake) (bytes)))
             (fm (fighter-form f)) (b0 (hss-bound st))
             (bankai (progn (setf (fighter-state f) :idle (fighter-move f) nil (fighter-form f) :bankai
                                  (anim-clip an) (find-clip :hs-k-stance))
                            (bytes)))
             (bind (progn (setf (hss-bound st) t) (bytes)))
             (bk (progn (setf (hss-bound st) nil)
                        (list (progn (at :hs-r-j3 14 :hs-k-sensa) (bytes))
                              (progn (at :hs-r-k2 28 :hs-k-g-k2) (setf (fighter-contact f) :hit) (bytes))
                              (progn (setf (fighter-contact f) ct) (at :hs-r-kubikake 12 :hs-k-kubikake) (bytes))
                              (progn (at :hs-r-l 15 :hs-k-saharai) (bytes))
                              (progn (at :hs-r-sp1 21 :hs-k-raiden) (bytes))
                              (progn (at :hs-r-sp2 31 :hs-k-ame) (bytes))
                              (progn (at :hs-r-kikon 21 :hs-k-kosa) (bytes))
                              (progn (at :hs-r-l 26 :hs-k-saharai) (bytes)))))            ; (A3: its recovery)
             (a2 (list (progn (at :hs-r-k1 17 :hs-k-hosoku) (bytes))           ; (A2, §24.2: the route links, the bundle)
                       (progn (at :hs-r-k1 24 :hs-k-hosoku) (bytes))
                       (progn (at :hs-r-k2s 21 :hs-k-s-k2) (bytes))
                       (progn (at :hs-r-k3 22 :hs-k-s-k3) (bytes))
                       (progn (at :hs-r-k2 34 :hs-k-g-k2) (bytes))
                       (progn (at :hs-r-k3g 28 :hs-k-g-k3) (bytes))
                       (progn (at :hs-r-j2s 16 :hs-k-g-j2) (bytes))
                       (progn (at :hs-r-j3g 17 :hs-k-g-j3) (bytes))))
             (bb (progn (setf (hss-bound st) t (fighter-form f) :bankai-bind)
                        (list (progn (at :hs-b-k2 21 :hs-kb-makigiri) (bytes))
                              (progn (at :hs-b-k3 23 :hs-kb-shibori) (bytes))
                              (progn (at :hs-b-sp1 15 :hs-kb-raiden) (bytes))
                              (progn (at :hs-b-kikon 9 :hs-kb-koshu) (bytes))
                              (progn (at :hs-b-l 12 :hs-kb-kojo) (bytes))                 ; (A3: KOJO's heave, the reap,
                              (progn (at :hs-b-l 31 :hs-kb-kojo) (bytes))                 ;  KAIBAKU-GEKI's haul, the
                              (progn (at :hs-b-sp2 10 :hs-kb-kaibaku) (bytes))            ;  throw-off)
                              (progn (at :hs-b-sp2 22 :hs-kb-kaibaku) (bytes))
                              (progn (setf (fighter-state f) :idle (fighter-move f) nil (anim-clip an) (find-clip :hs-kb-stance))
                                     (bytes))                                  ; (A2: the stance, the noose held taut)
                              (progn (setf (hss-bound st) nil) (at :hs-b-unwind 10 :hs-kb-unwind) (bytes))))))
        (setf (fighter-state f) state (fighter-move f) mv (fighter-phase f) ph (fighter-sf f) sf (hss-state st) s0
              (fighter-contact f) ct (anim-clip an) c0 (anim-time an) t0 (fighter-form f) fm
              (hss-bound st) b0)
        (log-msg "duel hisagi look consing (10 calls, B): stance ~d, out ~d, NAGI ~d, NOKO ~d, A1's wheel ~d, TSUI ~d, sky ~d, J3K ~d, ~
windmill ~d, J1 grip ~d, J3 ~d, KARI-OTOSHI ~d, S1's charge x1.4: windmill ~d, NAGI ~d, TSUI ~d; SHIBARI ~d, KUBIKAKE ~d, Bankai ~d, bind ~d; the Bankai's clips: J3 ~d, SOKUDA ~d, KUBIKAKE ~d, SAHARAI ~d, ~
SP1 ~d, SP2 ~d, KOSA ~d, SAHARAI's recovery ~d; the route links (A2): HOSOKU ~d, its bundle ~d, spread K2 ~d, K3 ~d, SOKUDA's L ~d, SOKUSEN ~d, SOKUBEN ~d, ~
SOKUTEI ~d; the bind's MAKIGIRI ~d, SHIBORI ~d, SP1 ~d, KOSHU ~d, KOJO's heave ~d, its reap ~d, KAIBAKU's haul ~d, its throw-off ~d, ~
stance ~d, UNWIND ~d"
                 idle out nage hiki (nth 0 a1) (nth 1 a1) (nth 2 a1) (nth 3 a1) kaza grip rin kari (nth 0 ch) (nth 1 ch) (nth 2 ch) shibari kubi bankai bind
                 (nth 0 bk) (nth 1 bk) (nth 2 bk) (nth 3 bk) (nth 4 bk) (nth 5 bk) (nth 6 bk) (nth 7 bk)
                 (nth 0 a2) (nth 1 a2) (nth 2 a2) (nth 3 a2) (nth 4 a2) (nth 5 a2) (nth 6 a2) (nth 7 a2)
                 (nth 0 bb) (nth 1 bb) (nth 2 bb) (nth 3 bb) (nth 4 bb) (nth 5 bb) (nth 6 bb) (nth 7 bb) (nth 8 bb)
                 (nth 9 bb))))))
(defparameter *hs-tip-moves*
  '((:bankai :hs-r-j1) (:bankai :hs-r-j2) (:bankai :hs-r-j3) (:bankai :hs-r-k1) (:bankai :hs-r-k2s) (:bankai :hs-r-k3)
    (:bankai :hs-r-k2) (:bankai :hs-r-j2s) (:bankai :hs-r-k3g) (:bankai :hs-r-j3g)
    (:bankai :hs-r-l) (:bankai :hs-r-sp1) (:bankai :hs-r-sp2) (:bankai :hs-r-kikon) (:bankai :hs-r-kubikake)
    (:bankai :hs-breaker) (:bankai-bind :hs-b-j1) (:bankai-bind :hs-b-j2) (:bankai-bind :hs-b-j3) (:bankai-bind :hs-b-k1)
    (:bankai-bind :hs-b-k2) (:bankai-bind :hs-b-k3) (:bankai-bind :hs-b-sp1) (:bankai-bind :hs-b-sp2) (:bankai-bind :hs-b-l)
    (:bankai-bind :hs-b-kikon))
  "Debug 83902's moves: (form move), every Bankai move with a hit window of volumes (B4c: the ranged route links too, on
their own clips since batch A2, §24.2).")
(defun hisagi-tip-check ()
  "Debug 83902 (P1 Hisagi 3 m from an idle Kenpachi; DUEL_HISAGI §21.8): for every move of *HS-TIP-MOVES*, on each of its
hit frames, the body posed by its form's clip (the FK and HS-POSE, as DRAW-FIGHTER) and HISAGI-DRAW run, what strikes
measured from his feet: a chain strike's free end (*HS-TIPV*), else a let-out crescent's point (*HS-LO*), else the held
right rod's point; along his facing for a line, from him for an arc. One `duel hisagi tip` line a move, with the volume's
far edge. A debug measurement (it conses)."
  (ensure-battle :hisagi :kenpachi)
  (when (brain *p2*) (setf (brain-off (brain *p2*)) t))
  (place *p1* *p2* 3.0)
  (hs-reset *p1*)
  (hs-awaken-now! *p1*)
  (let* ((e *p1*) (f (fighter e)) (m (model e)) (an (model-anim m)) (b (model-body m)) (p (pos-of e)) (st (hs e))
         (v (make-f32 3)) (jm (model-joints m)) (yaw (yaw-of e)) (lo *hs-lo*) (tp *hs-tipv*))
    (dolist (fm *hs-tip-moves*)
      (destructuring-bind (form name) fm
        (let* ((kit (find-kit :hisagi form)) (mv (find-move name))
               (clip (kit-move-clip kit (if (member (mv-kind mv) '(:kikon :breaker)) (mv-clip-2 mv) (mv-clip mv))))
               (vol (first (hw-vols (svref (mv-hits mv) 0)))) (cap (> (aref vol 0) 0.5))
               (tips nil))
          (setf (fighter-form f) form (hss-bound st) (eq form :bankai-bind) (fighter-state f) :move (fighter-move f) mv
                (fighter-phase f) :main (fighter-contact f) nil)
          (loop for w across (mv-hits mv)
                do (loop for sf from (hw-from w) below (hw-to w)
                         do (setf (fighter-sf f) sf (anim-clip an) (find-clip clip) (anim-time an) (/ sf 60f0) (anim-blend an) 0f0
                                  (aref *pose-at* 0) (aref p 0) (aref *pose-at* 1) (aref p 1) (aref *pose-at* 2) (aref p 2)
                                  (aref *pose-at* 3) yaw)
                            (pose-fk! jm (anim-eval an) (aref p 0) (aref p 1) (aref p 2) yaw (body-scale b) (body-hunch b)
                                      (body-props b))
                            (hs-pose e m) (hisagi-draw e 0.016)
                            (push (cond ((or (> (aref tp 0) 0) (> (aref lo 0) 0.99) (> (aref lo 8) 0.99))
                                         (max (aref tp (if cap 1 0)) (if (> (aref lo 0) 0.99) (aref lo 7) 0)
                                              (if (> (aref lo 8) 0.99) (aref lo 15) 0)))
                                        (t (joint-point! v jm (ji :weapon-r) 0f0 0f0 -0.75f0)
                                           (let ((dx (- (aref v 0) (aref p 0))) (dz (- (aref v 2) (aref p 2))))
                                             (if cap (- (* dx (- (sin yaw))) (* dz (cos yaw))) (sqrt (+ (* dx dx) (* dz dz)))))))
                                  tips)))
          (log-msg "duel hisagi tip ~(~a ~a ~a~): ~{~,2f~^ ~} | edge ~{~,2f~^ / ~} (~a)" form name clip (reverse tips)
                   (loop for w across (mv-hits mv)                      ; (each window's: A2's gathered K2 has two)
                         collect (let ((v (first (hw-vols w)))) (if cap (+ (aref v 2) (aref v 4)) (aref v 1))))
                   (if cap "line" "arc")))))
    ;; A1 (§24.1): the Shikai's K string and leap J: K1's sweep at x1 / x1.6 and the leaps against their arcs' r; K2 / K2J
    ;; / K3 (a :seg-fn window: placed on the victim) as how far the drawn sickle sits off his feet (0 wanted)
    (setf (fighter-form f) :base (hss-bound st) nil)
    (dolist (row '((:hs-k1 0) (:hs-k1 60) (:hs-j2k 0) (:hs-j3k 0) (:hs-k2 0) (:hs-k2j 0) (:hs-k3 0)))
      (destructuring-bind (name n) row
        (let* ((mv (hs-scaled name n)) (clip (mv-clip mv)) (hw (svref (mv-hits mv) 0)) (seg (hw-seg hw)) (tips nil))
          (setf (hss-charge st) n (hss-kstr st) (> n 0) (fighter-state f) :move (fighter-move f) mv (fighter-phase f) :main
                (fighter-contact f) nil)
          (loop for sf from (hw-from hw) below (hw-to hw)
                do (setf (fighter-sf f) sf (anim-clip an) (find-clip clip) (anim-time an) (/ sf 60f0) (anim-blend an) 0f0
                         (aref *pose-at* 0) (aref p 0) (aref *pose-at* 1) (aref p 1) (aref *pose-at* 2) (aref p 2)
                         (aref *pose-at* 3) yaw)
                   (pose-fk! jm (anim-eval an) (aref p 0) (aref p 1) (aref p 2) yaw (body-scale b) (body-hunch b) (body-props b))
                   (hs-pose e m) (hisagi-draw e 0.016)
                   (push (cond (seg (aref *hs-foe-d* 0))
                               ((or (> (aref lo 0) 0.99) (> (aref lo 8) 0.99))
                                (max (if (> (aref lo 0) 0.99) (aref lo 7) 0) (if (> (aref lo 8) 0.99) (aref lo 15) 0)))
                               (t (joint-point! v jm (ji :weapon-r) 0f0 0f0 -0.75f0)
                                  (sqrt (+ (expt (- (aref v 0) (aref p 0)) 2) (expt (- (aref v 2) (aref p 2)) 2)))))
                         tips))
          (log-msg "duel hisagi tip base ~(~a~) x~,2f ~(~a~): ~{~,2f~^ ~} | ~a" name (hs-charge-scale n) clip (reverse tips)
                   (if seg "off the victim (0 wanted)" (format nil "edge ~,2f (arc)" (aref (first (hw-vols hw)) 1)))))))
    (setf (hss-charge st) 0 (hss-kstr st) nil)
    (setf (fighter-form f) :bankai (hss-bound st) nil (fighter-contact f) nil)
    (to-idle e 0)))
(pushnew '(83901 83902 hisagi-art-debug) *char-debug* :test #'equal)
(defun hisagi-art-debug (c) (if (= c 83902) (hisagi-tip-check) (hisagi-look-cons-check)))

;;; ---------------------------------------------------------------- the clip strips (debug 83910-83964, 83500-83549: stills)
;; 83910+k picks strip slot k (*HS-STRIPS*; 83500+k the Bankai's, *HS-BK-STRIPS*, §21.8); 83940 + 3 i + v shows its frame i of 8 (DUEL_GAMEPLAY: 0, S/3, 2S/3, S-2, S,
;; S+A, mid-recovery, end; a loop's 8 even steps) from view v (0 his right side, 1 the front, 33 degrees to his left; 2 the
;; match's behind camera, the sim frozen); 83964 lets go. He is P1 in his Shikai on a white card (views 0-1), the sim his
;; move at that frame (the draw hook's sickles and chain), a held cinematic shot; Kenpachi stands DIST m ahead (unseen
;; on the card).
(defparameter *hs-bk-strips*
  '((:hs-k-stance nil 3.0 nil :bankai) (:hs-k-walk-f nil 3.0 nil :bankai) (:hs-k-run nil 3.0 nil :bankai)
    (:hs-k-saben :hs-r-j1 4.0 nil :bankai) (:hs-k-kaeshi :hs-r-j2 4.0 nil :bankai) (:hs-k-sensa :hs-r-j3 4.0 nil :bankai)
    (:hs-k-saharai :hs-r-l 2.5 nil :bankai) (:hs-k-raiden :hs-r-sp1 8.0 nil :bankai) (:hs-k-ame :hs-r-sp2 8.0 nil :bankai)
    (:hs-k-kosa-aim nil 8.0 nil :bankai) (:hs-k-kosa :hs-r-kikon 8.0 nil :bankai) (:hs-k-breaker nil 3.0 nil :bankai)
    (:hs-k-hammer :hs-breaker 1.0 nil :bankai) (:hs-k-kubikake :hs-r-kubikake 6.0 nil :bankai)
    (:hs-kb-gen :hs-b-j1 1.5 nil :bind) (:hs-kb-kaeshi :hs-b-j2 1.5 nil :bind) (:hs-kb-sogen :hs-b-j3 1.5 nil :bind)
    (:hs-kb-hikigiri :hs-b-k1 2.5 nil :bind) (:hs-kb-makigiri :hs-b-k2 2.5 nil :bind) (:hs-kb-shibori :hs-b-k3 2.8 nil :bind)
    (:hs-kb-kaibaku :hs-b-sp2 2.5 nil :bind) (:hs-kb-raiden :hs-b-sp1 3.5 nil :bind) (:hs-kb-kojo :hs-b-l 2.5 nil :bind)
    (:hs-kb-koshu-run nil 4.0 nil :bind) (:hs-kb-koshu :hs-b-kikon 1.2 nil :bind) (:hs-kb-unwind :hs-b-unwind 2.0 nil :unwind)
    (:hs-k-hosoku :hs-r-k1 3.5 nil :bankai) (:hs-k-s-k2 :hs-r-k2s 5.0 nil :bankai) (:hs-k-s-k3 :hs-r-k3 5.0 nil :bankai)
    (:hs-k-g-k2 :hs-r-k2 5.0 nil :bankai) (:hs-k-g-k3 :hs-r-k3g 5.0 nil :bankai) (:hs-k-g-j2 :hs-r-j2s 4.0 nil :bankai)
    (:hs-k-g-j3 :hs-r-j3g 4.0 nil :bankai) (:hs-kb-stance nil 1.5 nil :bind))
  "83500+k (DUEL_HISAGI §21.8): the Bankai's strip slots, as *HS-STRIPS* plus the form: :bankai the ranged mode, :bind a
bind (the noose), :unwind the bind mode just ended (UNWIND's ring). Batch A2 (§24.2): 26-32 the ranged route links (K1
HOSOKU, spread K2 / K3, gathered K2 / K3G / J2s / J3G), 33 the bind's stance. Batch A3 (§24.3): 20 SP2 KAIBAKU-GEKI's own
clip (HIKIYOSE's, its stand-in, gone), 22 KOJO's and 6 SAHARAI's redrawn.")
(defparameter *hs-strips*
  '((:hs-s-stance nil 3.0) (:hs-s-walk-f nil 3.0) (:hs-s-run nil 3.0) (:hs-s-sen :hs-j1 2.0) (:hs-s-kaeshi :hs-j2 2.0)
    (:hs-s-rin :hs-j3 2.0) (:hs-s-kaeshi-1h :hs-j2-1h 2.0 :out) (:hs-s-rin-1h :hs-j3-1h 2.0 :out) (:hs-s-nage :hs-k1 6.0)
    (:hs-s-hiki :hs-k2 1.6 :hooked) (:hs-s-maki :hs-k2s 3.0) (:hs-s-kari :hs-k3 2.5) (:hs-s-hodoki :hs-k3h 2.0 :hooked)
    (:hs-s-modoshi :hs-modoshi 3.0 :out) (:hs-s-kaza :hs-kaza 3.0) (:hs-s-raiden :hs-raiden 6.0)
    (:hs-s-shibari :hs-shibari 3.0 :wrapped) (:hs-s-breaker nil 3.0) (:hs-s-kubikake :hs-breaker 1.0) (:hs-s-kari-aim nil 7.0)
    (:hs-s-kari-o :hs-kikon 7.0) (:hs-s-intro nil 3.0) (:hs-s-win nil 3.0)
    (:hs-s-nagi :hs-k1 5.0) (:hs-s-noko :hs-k2 4.0) (:hs-s-tsui :hs-k3 4.0) (:hs-s-tobi-kaeshi :hs-j2k 1.0)   ; (A1, §24.1:
    (:hs-s-tobi-rin :hs-j3k 1.0))                                                                       ;  slots 23-27)
  "83910+k: (clip move dist [sickle]): the clip, the move its frames are (NIL: idle), Kenpachi's distance, the sickle's
state (:out anchored 4 m ahead on the floor, :hooked anchored in him, :wrapped SHIBARI's contact).")
(defvar *hs-strip-k* 0 "The strip slot (83910+k, 83500+k).")
(defvar *hs-strip-tab* *hs-strips* "The strip slots in use: *HS-STRIPS* (83910+k) or *HS-BK-STRIPS* (83500+k).")
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
  (destructuring-bind (clip move dist &optional sickle form) (nth *hs-strip-k* *hs-strip-tab*)
    (declare (ignore dist form))
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
      (destructuring-bind (clip move dist &optional sickle form) (nth *hs-strip-k* *hs-strip-tab*)
        (declare (ignore clip sickle))
        (let ((far (member move '(:hs-k1 :hs-raiden :hs-kikon :hs-k2s :hs-shibari :hs-k2 :hs-k3h :hs-modoshi :hs-k3)))
              (wide (and form (>= dist 4.0))))                         ; (the Bankai's long reach)
          (cond (wide (if (= (second *hs-strip-fv*) 0)
                          (shot-on a -90 12.0 1.6 :look 1.2 :ahead (min 4.6 (* 0.55 dist)))
                          (shot-on a 33 11.0 1.8 :look 1.2 :ahead 2.4)))
                ((= (second *hs-strip-fv*) 0)
                 (shot-on a -90 (if far 9.5 5.2) 1.2 :look 1.0 :ahead (if far (min 3.2 (* 0.5 dist)) 0.6)))
                (t (shot-on a 33 (if far 8.0 4.8) 1.4 :look 1.0 :ahead (if far 1.6 0.3))))
          (lens 40)))))
(defun hisagi-strip (c)
  "83910+k: the strip slot (83500+k: the Bankai's, *HS-BK-STRIPS*); 83940+3i+v: its frame i from view v (HS-STRIP-CINE; v 2
the match camera, frozen); 83964 lets go."
  (cond ((< c 83600) (setf *hs-strip-tab* *hs-bk-strips* *hs-strip-k* (min (- c 83500) (1- (length *hs-bk-strips*)))))
        ((< c 83940) (setf *hs-strip-tab* *hs-strips* *hs-strip-k* (min (- c 83910) (1- (length *hs-strips*)))))
        ((= c 83964) (abort-cine) (setf *cine-hold* nil *hitstop* 0))
        (t (multiple-value-bind (i v) (floor (- c 83940) 3)
             (setf *hs-strip-fv* (list (min i 7) v))
             (abort-cine) (setf *cine-hold* nil)
             (ensure-battle :hisagi :kenpachi)
             (when (brain *p2*) (setf (brain-off (brain *p2*)) t))
             (setf (hss-bound (hs *p1*)) nil)
             (force-form *p1* :base)
             (place *p1* *p2* (third (nth *hs-strip-k* *hs-strip-tab*)))
             (full-gauges! *p1*) (full-gauges! *p2*)
             (let ((form (fifth (nth *hs-strip-k* *hs-strip-tab*))))     ; (the Bankai's: awakened, a bind)
               (when form (hs-reset *p1*) (hs-awaken-now! *p1*))
               (when (eq form :bind) (hs-bind-start! *p1*))
               (when (member form '(:bind :unwind)) (set-form *p1* :bankai-bind)))
             (if (< v 2)
                 (progn (setf *cine-hold* t) (start-cine 'hs-strip-cine *p1* *p2*))
                 (progn (hs-strip-pose *p1* *p2*) (hitstop 100000)))))))
(pushnew '(83910 83964 hisagi-strip) *char-debug* :test #'equal)
(pushnew '(83500 83549 hisagi-strip) *char-debug* :test #'equal)

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

;;; ---------------------------------------------------------------- name
(setf *brush-names* (append (remove :hisagi *brush-names* :key #'first) '((:hisagi "檜佐木修兵" "HISAGI SHUHEI"))))

;;; ================================================================ the cinematics (batch B5, DUEL_HISAGI §22.5, §22.7)
;;; The user, 2026-10-18: 「覺醒跟毀魂技的動畫的記得要做」. Four scripts, built from §22.5's revised storyboards (the Shikai
;;; Kikon from §11.5's table): the awakening 卍解 風死絞縄 (the :bankai kit's :cine, combat.lisp AWAKEN!), the Shikai Kikon
;;; 刈れ, the ranged mode's 降鎖 KOSA and the bind's 絞首 KOSHU (the moves' :cine; also each form's Soul Break, KIT-KIKON-CINE).
;;; Presentation only: the rules settled the Konpaku before a script starts. The Kikons CINE-PLACE him (his place given
;;; back at the end); the awakening moves no one (its AFTER sends both to idle as every awakening's does). His draw hook
;;; reads the running script's frame (HS-CINE-OF, %HS-CINE-LOOK!, HS-KARE-CODES), so a skipped or aborted script leaves
;;; nothing behind; the scripts' own looks are the DURING functions below (the whirlpool, the black wind, the coils, the
;;; orb gathering, the giant rope, the crack, the rain of chains). Debug 83965-83976 (HISAGI-CINE-DEBUG).

(defun hs-cine-of (e)
  "The B5 cinematic E is the actor A of right now: 1 the awakening, 2 the Shikai Kikon 刈れ, 3 KOSA, 4 KOSHU, else 0."
  (let ((c *cine*))
    (if (and c (eq (cine-a c) e))
        (case (cine-name c) (hs-awaken-cine 1) (hs-kare-cine 2) (hs-kosa-cine 3) (hs-koshu-cine 4) (t 0))
        0)))

(defun-fast %hs-cine-look! (code cf)
  "*HS-CL* for HISAGI-DRAW at cine frame CF of B5 cinematic CODE (HS-CINE-OF; 0: the match's 1 1 1 0 0); returns the flags:
1 the Shikai's look (the awakening before 卍解's coils: the ink chain, no orb), 2 no orb at all (the awakening to f100), 4
the noose drawn whatever the bind (KOSHU). The awakening's orb grows f100-116, its curtain drops f114-126, the neck bundle
comes down f118-130 and ties; KOSA's curtain is hauled up into the orb f28-44 (the rope) and drops back f120-134; KOSHU's
orb sinks 3.4 m f70-86. 0 B."
  (declare (fixnum code cf))
  (let ((cl *hs-cl*) (f (i->f cf)))
    (declare (type f32vec cl) (single-float f))
    (macrolet ((ramp (a b) `(f-clamp (/ (- f ,a) ,(- b a)) 0f0 1f0)))
      (setf (aref cl 0) 1f0 (aref cl 1) 1f0 (aref cl 2) 1f0 (aref cl 3) 0f0 (aref cl 4) (if (= code 0) 0f0 1f0))
      (case code
        (1 (cond ((< cf 70) 3)
                 ((< cf 100) 2)
                 (t (let ((g (ramp 100f0 116f0)))
                      (declare (single-float g))
                      (setf (aref cl 0) (* g g (- 3f0 (* 2f0 g))) (aref cl 1) (ramp 114f0 126f0) (aref cl 2) (ramp 118f0 130f0))
                      0))))
        (3 (setf (aref cl 1) (if (< cf 120) (- 1f0 (ramp 28f0 44f0)) (ramp 120f0 134f0))) 0)
        (4 (setf (aref cl 3) (* -3.4f0 (ramp 70f0 86f0))) 4)
        (t 0)))))

(defun-fast %hs-fr-from (n)
  "1 when the clip frame HISAGI-DRAW read (*HS-FR*) is at least N, else 0. 0 B."
  (declare (fixnum n))
  (if (>= (aref *hs-fr* 0) (i->f n)) 1 0))

(defun-fast hs-kare-codes (cf fa kubi)
  "The left sickle in the Shikai Kikon 刈れ at cine frame CF (HISAGI-DRAW's draw codes A B N D, and LO bits): in his fist,
then thrown at f30 (the strike's S) along his facing as the flat spinning disc on its chain (68: the disc, through the left
fist) past the victim 3 m out to 6 m (f40), drifting to 7 m, pulled back from f58 through his back (f63) into the fist
(f68); KUBI 1 (KUBIKAKE's clip, the victim within 1.8 m, before the slam): the garrote (8). FA[1] := the flight's reach. 0 B."
  (declare (fixnum cf kubi) (type f32vec fa))
  (cond ((< cf 30) (values 0 0 0 1 0))
        ((< cf 40) (setf (aref fa 1) 6.0f0) (values 0 1 (- cf 30) 10 68))
        ((< cf 58) (setf (aref fa 1) (+ 6.0f0 (/ (i->f (- cf 40)) 18f0))) (values 1 1 0 1 68))
        ((< cf 68) (setf (aref fa 1) 7.0f0) (values 1 0 (- cf 58) 10 68))
        (t (values 0 0 0 1 (if (= kubi 1) 8 0)))))

;;; ---------------------------------------------------------------- the scripts' shots and looks
(declaim (type f32vec *hs-c0* *hs-c1* *hs-c2* *hs-cfa* *hs-cm*))
(defvar *hs-c0* (make-f32 3) "A cinematic look's point (scratch).")
(defvar *hs-c1* (make-f32 3) "A cinematic look's point (scratch).")
(defvar *hs-c2* (make-f32 3) "A cinematic look's point (scratch).")
(defvar *hs-cfa* (make-f32 4) "A flying blade's facing for %HS-PLACE! ([0] its yaw).")
(defvar *hs-cm* (m4) "A flying blade's world matrix.")

(defun hs-shot (e ang dist h look &key (ahead 0.0) (right 0.0))
  "SHOT-ON's camera (ANG degrees round fighter E's facing, DIST m out, H high, aimed LOOK m up, AHEAD m in front of him and
RIGHT m to his right) with no subject kept in frame: a tilt that leaves his body (camera.lisp %KEEP-SUBJECT)."
  (setf *cine-close* nil *cine-subject* nil)
  (let* ((p (pos-of e)) (y0 (yaw-of e)) (yaw (+ y0 (deg ang)))
         (tx (+ (aref p 0) (* ahead (fwd-x y0)) (* right (cos y0)))) (tz (+ (aref p 2) (* ahead (fwd-z y0)) (* right (- (sin y0))))))
    (cine-cam (+ tx (* dist (fwd-x yaw))) h (+ tz (* dist (fwd-z yaw))) tx look tz)))

(defun hs-cine-stage (a v gap)
  "A Kikon cinematic's frame 0: A put 3 m in front of V first, where the placeholder cinematic (B2a's HS-KIKON-CINE) left
him for the reset that follows (combat.lisp RESET-ROUND places both from where they stand: the gates' rows stay as they
were), then staged GAP m from V (CINE-PLACE: he is given back the 3 m place however the cinematic ends)."
  (face-each-other a v 3.0)
  (cine-place a v gap))

(defun hs-face (a v)
  "Turn A to face V (a cinematic look; V unturned)."
  (let ((p (pos-of a)) (q (pos-of v)))
    (setf (transform-yaw (transform a)) (f32 (dir-yaw (- (aref q 0) (aref p 0)) (- (aref q 2) (aref p 2)))))))

(defun hs-round (a v d deg)
  "Put A D m from V, DEG degrees round V's facing (0 in front of him, 180 behind his back), facing him (刈れ's flash steps:
CINE-PLACE gives A his place back)."
  (let* ((q (pos-of v)) (p (pos-of a)) (yaw (+ (yaw-of v) (deg deg))))
    (setf (aref p 0) (f32 (+ (aref q 0) (* d (fwd-x yaw)))) (aref p 1) 0f0 (aref p 2) (f32 (+ (aref q 2) (* d (fwd-z yaw)))))
    (hs-face a v)))

(defun hs-cine-hit (v up kind)
  "A hit spark on V, UP m over his feet (a look)."
  (multiple-value-bind (x y z) (actor-point v up) (vfx-hit x y z kind)))

(defun hs-top-shot (v)
  "Steep, nearly top-down on V (刈れ's flash steps): 6.4 m up, 2.0 m off to the side."
  (setf *cine-close* nil *cine-subject* nil)
  (let ((q (pos-of v)) (yaw (yaw-of v)))
    (cine-cam (+ (aref q 0) (* 2.0 (cos yaw))) 6.4 (+ (aref q 2) (* 2.0 (- (sin yaw)))) (aref q 0) 0.6 (aref q 2))))

(defun hs-lane-shot (a v dist h look)
  "Side-on to the A -> V lane (on A's right: the orb's side), DIST m from its middle, H high, aimed LOOK m up: KOSA's long
lens."
  (setf *cine-close* nil *cine-subject* nil)
  (let* ((p (pos-of a)) (q (pos-of v)) (mx (* 0.5 (+ (aref p 0) (aref q 0)))) (mz (* 0.5 (+ (aref p 2) (aref q 2))))
         (yaw (yaw-of a)))
    (cine-cam (+ mx (* dist (cos yaw))) h (+ mz (* dist (- (sin yaw)))) mx look mz)))

(defun-fast %hs-aw-whirl (pos cf)
  "The awakening's whirlpool (f32-70): both Kazeshini flung up over him (POS his feet), tumbling round a rim rising from
2.2 to 3.5 m and widening to 1.25 m, their chain twisting down from each into a funnel above his head and back up: the
Shikai's ink chain. 0 B but the weapon draws."
  (declare (type f32vec pos) (fixnum cf))
  (let* ((u (f-clamp (/ (i->f (- cf 32)) 14f0) 0f0 1f0)) (e (* u u (- 3f0 (* 2f0 u))))
         (h (+ 2.2f0 (* 1.3f0 e))) (r (+ 0.25f0 (* 1.0f0 e))) (th (* 0.26f0 (i->f cf)))
         (x (aref pos 0)) (z (aref pos 2)) (a *hs-c0*) (b *hs-c1*) (fa *hs-cfa*) (m *hs-cm*))
    (declare (single-float u e h r th x z) (type f32vec a b fa m))
    (dotimes (k 2)
      (let ((an (+ th (* 3.1415927f0 (i->f k)))))
        (declare (single-float an))
        (setf (aref a 0) (+ x (* r (f-cos an))) (aref a 1) (+ h (* 0.25f0 (i->f k))) (aref a 2) (+ z (* r (f-sin an)))
              (aref fa 0) (- an))
        (%hs-place! m a fa 1)
        (draw-weapon :kazeshini m)))
    (dotimes (i 29)
      (let* ((s (/ (i->f i) 28f0)) (d (f-abs (- 1f0 (* 2f0 s))))
             (an (+ th (* 3.1415927f0 s) (* 7.853982f0 (- 1f0 d))))
             (rr (+ 0.08f0 (* r d))) (y (+ 2.05f0 (* (- h 2.05f0) d) (* 0.25f0 s))))
        (declare (single-float s d an rr y))
        (setf (aref b 0) (+ x (* rr (f-cos an))) (aref b 1) y (aref b 2) (+ z (* rr (f-sin an))))
        (when (> i 0) (vfx-hs-chain a b 0f0 0.9f0))
        (replace a b))))
  nil)

(defun %hs-aw-wind (pos cf from k0)
  "The black wind round him (POS his feet) from cine frame FROM: 22 dark streaks, spiralling round the whirlpool (K0 0) or
bursting out from him to 8 m and fading (K0 1: 卍解)."
  (let* ((u (min 1.0 (max 0.0 (/ (- cf from) 20.0)))) (x (aref pos 0)) (z (aref pos 2)))
    (dotimes (i 22)
      (let* ((a0 (+ (* i 0.2856) (* 0.13 (mod (* i 7) 5)) (if (= k0 0) (* 0.2 cf) 0.0)))
             (y (+ 0.25 (* 0.42 (mod (* i 3) 7))))
             (r0 (if (= k0 0) (+ 1.6 (* 0.12 (mod i 4))) (+ 0.6 (* 7.0 u))))
             (r1 (if (= k0 0) r0 (+ r0 0.4 (* 1.8 (- 1.0 u)))))
             (a1 (if (= k0 0) (+ a0 0.7) a0)) (al (if (= k0 0) 0.55 (* 0.9 (- 1.0 u)))))
        (fx-line (+ x (* r0 (cos a0))) y (+ z (* r0 (sin a0))) (+ x (* r1 (cos a1))) (+ y (if (= k0 0) 0.35 0.1)) (+ z (* r1 (sin a1)))
                 (if (= k0 0) 0.07 0.14) 0.03 0.03 0.05 al :mode :alpha :end-width 0.015 :end-alpha (* 0.2 al))))))

(defun-fast %hs-coil-run (jm j r ya yb turns n upto)
  "The first UPTO of N links of a coil of chain winding round joint J of the joints JM (radius R, from YA to YB along its
up axis, TURNS turns): solid black (%HS-BLACK-KITE), each along the helix. 0 B but its float arguments."
  (declare (type f32vec jm) (fixnum j n upto) (single-float r ya yb turns))
  (let ((p *hs-c0*) (q *hs-c1*))
    (declare (type f32vec p q))
    (dotimes (i (min n upto))
      (let* ((u0 (/ (+ 0.5f0 (i->f i)) (i->f n))) (u1 (/ (+ 1.5f0 (i->f i)) (i->f n)))
             (a0 (* 6.2831855f0 turns u0)) (a1 (* 6.2831855f0 turns u1)))
        (declare (single-float u0 u1 a0 a1))
        (joint-point! p jm j (* r (f-sin a0)) (+ ya (* u0 (- yb ya))) (* r (f-cos a0)))
        (joint-point! q jm j (* r (f-sin a1)) (+ ya (* u1 (- yb ya))) (* r (f-cos a1)))
        (let* ((dx (- (aref q 0) (aref p 0))) (dy (- (aref q 1) (aref p 1))) (dz (- (aref q 2) (aref p 2)))
               (l (f-max 1f-4 (f-hypot dx dy dz))))
          (declare (single-float dx dy dz l))
          (%hs-black-kite (aref p 0) (aref p 1) (aref p 2) (/ dx l) (/ dy l) (/ dz l) 0.045f0 (if (evenp i) 0.02f0 0.009f0))))))
  nil)

(defun hs-aw-coil (a cf)
  "The awakening's coils winding on (f74-90, then the :hisagi-bankai body's): his chain up the right forearm from the
wrist, the upper arm, then round his neck (the body variant's three coils, 113 links, a little proud of them)."
  (let* ((jm (model-joints (model a))) (n (floor (* 113 (min 1.0 (/ (- cf 74) 15.0))))))
    (%hs-coil-run jm (ji :lower-arm-r) 0.064 -0.235 -0.02 4.0 40 n)
    (%hs-coil-run jm (ji :upper-arm-r) 0.073 -0.27 -0.04 3.5 40 (- n 40))
    (%hs-coil-run jm (ji :neck) 0.069 0.0 0.125 3.0 33 (- n 80))))

(defun hs-aw-gather (cf)
  "The orb forming (f100-116): six black chains spiralling in from 4.6 m round to its centre (*HS-OC*, the draw hook's)."
  (let ((c *hs-oc*) (p *hs-c2*) (u (min 1.0 (/ (- cf 100) 16.0))))
    (setf *hs-chain-black* 1)
    (dotimes (i 6)
      (let ((an (+ (* i 1.0472) (* 0.12 cf))) (rr (+ 0.6 (* 4.0 (- 1.0 u)))))
        (setf (aref p 0) (f32 (+ (aref c 0) (* rr (cos an)))) (aref p 1) (f32 (- (aref c 1) (* 0.45 rr) -0.6))
              (aref p 2) (f32 (+ (aref c 2) (* rr (sin an)))))
        (%hs-chain2 p c)))
    (setf *hs-chain-black* 0)))

(defun hs-aw-tilt (a cf)
  "The awakening's tilt (f100-135): from low behind his left shoulder (the opponent out of the frame), up past the frame's top to the orb forming (f100-112),
held on it, then down with the chains and the bundle to him (f118-132)."
  (let* ((k (cond ((< cf 112) (let ((x (/ (- cf 100) 12.0))) (* x x (- 3 (* 2 x)))))
                  ((< cf 118) 1.0)
                  (t (let ((x (min 1.0 (/ (- cf 118) 14.0)))) (- 1.0 (* x x (- 3 (* 2 x)))))))))
    (hs-shot a 150 6.2 0.8 (+ 1.3 (* 6.9 k)) :right (* 1.5 k))))

(defun hs-kosa-tilt (a cf)
  "KOSA's tilt (f25-60): low behind him, up from his raised crescent to the orb (to f42), held there."
  (let* ((x (min 1.0 (/ (- cf 25) 17.0))) (k (* x x (- 3 (* 2 x)))))
    (hs-shot a 160 3.2 0.5 (+ 2.0 (* 5.6 k)) :right (* 1.4 k) :ahead (* -0.5 k))))

(defun hs-kosa-rope (a v cf)
  "KOSA's giant rope (f25-112): every hanging chain hauled up (the draw hook's curtain) and twisted into one rope of eight
under the orb, lowered (f30-52); swung back over him (f60-68); whipped down to the ground 2 m ahead (f68-76); its end run
along the ground to the victim as a wave of black (f76-90), the ground blackened behind it; on him (to f100), then hauled
back up (f100-112)."
  (let* ((c *hs-oc*) (top *hs-c0*) (b *hs-c1*) (p (pos-of a)) (q (pos-of v))
         (dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2))) (d (max 0.5 (hypot dx dz))) (ux (/ dx d)) (uz (/ dz d)))
    (setf (aref top 0) (aref c 0) (aref top 1) (- (aref c 1) (* 0.75 *hs-orb-scale*)) (aref top 2) (aref c 2))
    (flet ((at (s y) (setf (aref b 0) (f32 (+ (aref p 0) (* s ux))) (aref b 1) (f32 y) (aref b 2) (f32 (+ (aref p 2) (* s uz)))))
           (ease (x) (let ((x (min 1.0 (max 0.0 x)))) (* x x (- 3 (* 2 x))))))
      (cond ((< cf 60) (let ((l (* 5.2 (ease (/ (- cf 30) 22.0)))))
                         (setf (aref b 0) (aref top 0) (aref b 1) (f32 (- (aref top 1) l)) (aref b 2) (aref top 2))))
            ((< cf 68) (let ((k (ease (/ (- cf 60) 8.0)))) (at (* -2.6 k) (- (aref top 1) 5.2 (* -1.6 k)))))
            ((< cf 76) (let ((k (ease (/ (- cf 68) 8.0)))) (at (+ -2.6 (* 4.6 k)) (+ (* (- 1 k) (- (aref top 1) 3.6)) (* k 0.15)))))
            ((< cf 90) (at (+ 2.0 (* (- d 2.0) (ease (/ (- cf 76) 14.0)))) 0.15))
            ((< cf 100) (at d 0.5))
            (t (let ((k (ease (/ (- cf 100) 12.0))))
                 (setf (aref b 0) (f32 (+ (aref q 0) (* k (- (aref top 0) (aref q 0)))))
                       (aref b 1) (f32 (+ 0.5 (* k (- (aref top 1) 0.5))))
                       (aref b 2) (f32 (+ (aref q 2) (* k (- (aref top 2) (aref q 2)))))))))
      (setf *hs-chain-black* 1)
      (when (> (- (aref top 1) (aref b 1)) 0.1) (%hs-bundle top b 8 2.5f0 0.32f0 1.1f0))
      (setf *hs-chain-black* 0)
      (when (and (>= cf 76) (< cf 120))                  ; the wave: the ground blackened along the lane behind its end
        (let* ((s1 (if (< cf 90) (+ 2.0 (* (- d 2.0) (ease (/ (- cf 76) 14.0)))) d))
               (al (if (< cf 100) 0.9 (* 0.9 (- 1.0 (/ (- cf 100) 20.0))))))
          (dotimes (i 3)
            (let ((o (* 0.22 (- i 1))))
              (fx-line (+ (aref p 0) (* 1.2 ux) (* o (- uz))) 0.04 (+ (aref p 2) (* 1.2 uz) (* o ux))
                       (+ (aref p 0) (* s1 ux) (* o (- uz))) 0.04 (+ (aref p 2) (* s1 uz) (* o ux))
                       (if (= i 1) 0.3 0.16) 0.03 0.03 0.05 al :mode :alpha :end-width 0.45)))
          (when (< cf 92)                                ; black spray thrown up at its front
            (dotimes (i 7)
              (let* ((sp (* 0.9 (- i 3))) (hh (+ 0.6 (* 0.5 (mod (* i 5) 3)) (* 0.08 (mod cf 4)))))
                (fx-line (+ (aref p 0) (* s1 ux)) 0.1 (+ (aref p 2) (* s1 uz))
                         (+ (aref p 0) (* (- s1 0.4) ux) (* sp 0.35 (- uz))) hh (+ (aref p 2) (* (- s1 0.4) uz) (* sp 0.35 ux))
                         0.09 0.03 0.03 0.05 0.85 :mode :alpha :end-width 0.01)))))))))

(defun hs-kosa-crack (a v cf)
  "KOSA's crack (f90-150): a jagged black line split along the ground from 1.2 m ahead of him to the victim, fading from
f130."
  (let* ((p (pos-of a)) (q (pos-of v)) (dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2)))
         (d (max 1.5 (hypot dx dz))) (ux (/ dx d)) (uz (/ dz d)) (k (if (< cf 130) 0.95 (* 0.95 (- 1.0 (/ (- cf 130) 20.0)))))
         (n 18) (x0 0.0) (z0 0.0))
    (dotimes (i (1+ n))
      (let* ((s (+ 1.2 (* (- d 1.0) (/ i (float n))))) (o (* 0.16 (sin (* 2.7 i))))
             (x (+ (aref p 0) (* s ux) (* o (- uz)))) (z (+ (aref p 2) (* s uz) (* o ux))))
        (when (> i 0)
          (fx-line x0 0.03 z0 x 0.03 z 0.07 0.02 0.02 0.03 k :mode :alpha)
          (when (zerop (mod i 3))                         ; a branch every third kink
            (fx-line x 0.03 z (+ x (* 0.5 (- uz)) (* 0.2 ux)) 0.03 (+ z (* 0.5 ux) (* 0.2 uz)) 0.04 0.02 0.02 0.03 k
                     :mode :alpha :end-width 0.005)))
        (setf x0 x z0 z)))))

(defun hs-koshu-rain (v cf)
  "KOSHU's rain of chains (f80-150): eight black chains dropped from the sunk orb's underside (*HS-OC*) onto the victim,
one every 2 f, their ends round his body 0.5-1.4 m up; from f96 three turns of chain bind him standing (%HS-COIL)."
  (let ((c *hs-oc*) (top *hs-c0*) (b *hs-c1*) (q (pos-of v)))
    (setf (aref top 0) (aref c 0) (aref top 1) (f32 (- (aref c 1) (* 0.75 *hs-orb-scale*))) (aref top 2) (aref c 2))
    (setf *hs-chain-black* 1)
    (dotimes (i 8)
      (let ((k (min 1.0 (/ (- cf 80 (* 2 i)) 7.0))) (an (* i 0.7854)))
        (when (> k 0.0)
          (setf (aref b 0) (f32 (+ (aref top 0) (* k (- (+ (aref q 0) (* 0.4 (cos an))) (aref top 0)))))
                (aref b 1) (f32 (+ (aref top 1) (* k (- (+ 0.5 (* 0.13 i)) (aref top 1)))))
                (aref b 2) (f32 (+ (aref top 2) (* k (- (+ (aref q 2) (* 0.4 (sin an))) (aref top 2))))))
          (%hs-chain2 top b))))
    (when (>= cf 96) (%hs-coil q))
    (setf *hs-chain-black* 0)))

;;; ---------------------------------------------------------------- the cinematics' clips (his and the victim's)
;; the awakening: head bowed, eyes shut, the rods hanging in front of his thighs, the chain slack between them (CFYOW
;; III ch. 24's stillness before the release)
(defpose :hs-aw-still (:base :hs-s-stance)
  (:root :u -0.03 :f 0.0) (:pelvis :twist 0) (:spine :flex 8) (:chest :twist 0) (:neck :twist 0) (:head :flex 28)
  (:arm-r :flex 22 :side 6 :twist 0) (:elbow-r :flex 26) (:hand-r :flex -96)
  (:arm-l :flex 22 :side 6 :twist 0) (:elbow-l :flex 26) (:hand-l :flex -96)
  (:thigh-l :flex 4 :side 8) (:knee-l :flex 6) (:thigh-r :flex -4 :side 8) (:knee-r :flex 6))
(defclip :hs-aw-still (1.0 :loop t :base :hs-aw-still)
  (0) (0.5 (:root :u -0.04) (:head :flex 30)))
;; both Kazeshini flung up (cine f20 + 12 = f32): sunk low with the rods swung back, then the whole body thrown up, the
;; arms straight overhead, the face up to the whirlpool, held
(defclip :hs-aw-throw (1.3 :base :hs-aw-still)
  (0)
  (0.14 (:root :u -0.26) (:spine :flex 30) (:head :flex 12) (:arms :flex -36 :side 34) (:elbows :flex 30) (:hands :flex -60)
        (:thighs :flex 46) (:knees :flex 60))
  (0.2 :snap (:root :u 0.06) (:spine :flex -24) (:head :flex -44) (:arms :flex 178 :side 16) (:elbows :flex 4)
       (:hands :flex -10) (:thigh-l :flex 4) (:thigh-r :flex -8) (:knees :flex 4))
  (0.36 (:root :u 0.03) (:spine :flex -28) (:head :flex -48) (:arms :flex 170 :side 30) (:elbows :flex 10) (:hands :flex -20))
  (1.3 (:root :u 0.0) (:spine :flex -24) (:head :flex -46) (:arms :flex 160 :side 44) (:elbows :flex 22) (:hands :flex -30)))
;; f70: the blades fall back into his hands (caught low, the knees giving), then the right arm held out and down, his
;; head turned to it, as the chain winds up it; into the CFYOW stance
(defclip :hs-aw-catch (1.0 :base :hs-k-stance)
  (0 (:spine :flex -20) (:head :flex -40) (:arms :flex 160 :side 34) (:elbows :flex 20))
  (0.07 :snap (:root :u -0.16) (:spine :flex 14) (:head :flex 4) (:arms :flex 50 :side 24) (:elbows :flex 50) (:hands :flex -60)
        (:knees :flex 34) (:thighs :flex 20))
  (0.25 (:root :u -0.06) (:spine :flex 6) (:head :flex 26) (:neck :twist -34) (:arm-r :flex 34 :side 44 :twist 0)
        (:elbow-r :flex 46) (:hand-r :flex -40) (:arm-l :flex 8 :side 14) (:elbow-l :flex 12) (:hand-l :flex -82))
  (0.5 (:root :u -0.05) (:spine :flex 5) (:head :flex 28) (:neck :twist -38) (:arm-r :flex 36 :side 46 :twist 0)
       (:elbow-r :flex 50) (:hand-r :flex -36) (:arm-l :flex 8 :side 14) (:elbow-l :flex 12) (:hand-l :flex -82))
  (1.0 :hs-k-stance (:head :flex 12)))
;; f100: the face up to the orb forming, held; down again into the stance with the chains (f118-132)
(defclip :hs-aw-rise (1.2 :base :hs-k-stance)
  (0 (:head :flex 10))
  (0.2 (:spine :flex -8) (:head :flex -40))
  (0.3 (:spine :flex -9) (:head :flex -42))
  (0.6 (:spine :flex 2) (:head :flex 6))
  (1.2 :hs-k-stance))
;; KOSHU: the victim's choke (both hands at his throat, the head back, up on his toes, straining), and Hisagi's: the right
;; crescent straight up, his left hand at his own throat, the head back (the noose bites both: the shared pain), then
;; standing on, hunched a little, shaking (f150)
(defpose :hs-cine-choke-v ()
  (:root :u 0.04) (:spine :flex -14) (:head :flex -36)
  (:arm-r :flex 70 :side -28 :twist 0) (:elbow-r :flex 125) (:hand-r :flex -10)
  (:arm-l :flex 70 :side -28 :twist 0) (:elbow-l :flex 125) (:hand-l :flex -10)
  (:thigh-l :flex 6 :side 6) (:knee-l :flex 10) (:thigh-r :flex -6 :side 6) (:knee-r :flex 8))
(defclip :hs-cine-choke-v (0.2 :loop t :base :hs-cine-choke-v)
  (0) (0.1 (:root :u 0.05) (:spine :flex -18) (:head :flex -40) (:arm-r :flex 74) (:arm-l :flex 66)))
(defpose :hs-cine-raise (:base :hs-k-stance)
  (:root :u -0.04) (:spine :flex -12) (:head :flex -28)
  (:arm-r :flex 176 :side 12 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -10)
  (:arm-l :flex 120 :side -26 :twist 0) (:elbow-l :flex 150) (:hand-l :flex -10)
  (:thigh-l :flex 16 :side 8) (:knee-l :flex 18) (:thigh-r :flex -12 :side 8) (:knee-r :flex 14))
(defclip :hs-cine-raise (0.2 :loop t :base :hs-cine-raise)
  (0) (0.1 (:head :flex -32) (:arm-r :flex 179) (:root :u -0.05)))
(defclip :hs-cine-shake (0.14 :loop t :base :hs-k-stance)
  (0 (:root :u -0.07) (:spine :flex 12) (:head :flex 16) (:arm-l :flex 104 :side -20 :twist 0) (:elbow-l :flex 140)
     (:hand-l :flex -10))
  (0.07 (:root :u -0.08) (:spine :flex 14) (:chest :twist 3) (:head :flex 19) (:arm-l :flex 108 :side -22 :twist 0)
        (:elbow-l :flex 136) (:hand-l :flex -10)))

;;; ---------------------------------------------------------------- the scripts
(defcine hs-awaken-cine (a v :len 168 :hold 150)
  "The awakening 卍解 風死絞縄 (§22.5): 1 close on his face, eyes shut, the chain slack between the two Kazeshini in his
hands, silence; 2 low, looking up: both flung up (f32), their chain twisting into a whirlpool overhead; 3 wide: 卍解, the
black wind bursts out (a negative frame, the shockwave, the stamp); 4 medium: silence, the world greys, the blades fall
back into his hands, his chain winds up his right arm and round his neck; 5 the tilt up past the frame's top to the orb
forming, the black chains dropping round him, the four-chain bundle coming down and tying round his neck, the pale patch;
6 wide, both: the CFYOW stance under the curtain, 風死絞縄 / ふしのこうじょう. Nothing reaches the opponent (the bind starts
only from KUBIKAKE)."
  ;; 1 (0-20) close on the face
  (at 0 (setf (model-body (model a)) (find-body :hisagi) (model-weapon (model a)) :kazeshini)
      (cine-clip a :hs-aw-still :blend 0) (cine-clip v (kit-stance (kit-of v)) :blend 6) (face-beat a :neutral 0.55)
      (hold-pose v 12) (freeze 12) (impact-frame :negative 2) (silence 20)
      (shot-on a 16 1.25 1.62 :look 1.6) (lens 36))
  (during (0 20) (shot-on a 16 (- 1.25 (* 0.18 u)) 1.62 :look 1.6))
  ;; 2 (20-50) low, looking up: both flung up, the whirlpool
  (at 20 (cine-clip a :hs-aw-throw :blend 2) (shot-on a 34 3.1 0.3 :look 2.1) (lens 74) (play-sfx :whoosh-heavy :pitch 0.8))
  (at 32 (setf (model-weapon (model a)) nil) (play-sfx :chain-rattle) (play-sfx :whoosh-heavy :pitch 1.1))
  (at 42 (play-sfx :chain-rattle :pitch 0.8))
  (during (32 70) (%hs-aw-whirl (pos-of a) cf))
  (during (36 50) (%hs-aw-wind (pos-of a) cf 36 0))
  ;; 3 (50-70) wide: 卍解, the black wind, the negative, the shockwave, the stamp
  (at 50 (impact-frame :negative 2) (shot-on a 62 9.5 1.3 :look 2.2 :off -1.4) (lens 50) (shake 0.35 0.5)
      (play-sfx :awaken-boom) (play-sfx :explode :pitch 0.6 :gain 0.6)
      (let ((p (pos-of a))) (vfx-shockwave (aref p 0) (aref p 2) 6.0 0.6 :pal +pal-dust+))
      (caption "卍解" :reading "BANKAI" :side 1))
  (at 52 (impact-frame :manga 6))
  (during (50 70) (%hs-aw-wind (pos-of a) cf 50 1))
  ;; 4 (70-100) medium: silence, the world greys; the blades caught; the coils wind on
  (at 70 (setf (model-weapon (model a)) :kazeshini) (cine-clip a :hs-aw-catch :blend 1) (caption-exit) (silence 30)
      (shot-on a 38 3.3 1.35 :look 1.3) (lens 42) (play-sfx :clang :pitch 0.7))
  (during (70 168) (setf *grade-desat* (min 0.7 (* 0.05 (- cf 70)))))
  (at 74 (play-sfx :chain-rattle :pitch 0.6))
  (during (74 90) (hs-aw-coil a cf))
  (at 90 (setf (model-body (model a)) (find-body :hisagi-bankai)) (play-sfx :chain-snap :pitch 0.8))
  ;; 5 (100-135) the tilt up past the frame's top: the orb forms, the chains drop, the bundle ties his neck
  (at 100 (cine-clip a :hs-aw-rise :blend 6) (lens 54) (play-sfx :awaken-rise :pitch 0.6))
  (during (100 135) (hs-aw-tilt a cf))
  (during (100 116) (setf *hs-chain-ink* (if (eq a *p1*) 0 1)) (hs-aw-gather cf))
  (at 114 (play-sfx :chain-rattle :pitch 0.5))
  (at 130 (play-sfx :chain-snap) (shake 0.15 0.25))
  ;; 6 (135-168) wide, both: the CFYOW stance under the curtain; 風死絞縄
  (at 135 (cine-clip a :hs-k-stance :blend 10) (impact-frame :negative 1)
      (let* ((p (pos-of a)) (q (pos-of v)) (d (hypot (- (aref q 0) (aref p 0)) (- (aref q 2) (aref p 2)))))
        (shot-on a 30 (+ 7.0 (* 0.6 d)) 1.4 :look 2.0 :ahead (* 0.5 d) :off (- (+ 1.0 (* 0.3 d))))) (lens 44)
      (caption "風死絞縄" :kanji2 "ふしのこうじょう" :reading "FUSHI NO KOJO" :sub "BANKAI" :side 1)))

(defcine hs-kare-cine (a v :len 180 :hold 160)
  "The Shikai Kikon 刈れ (§11.5, the Findorr fight, ch. 325): 1 side and low, 3 m apart: the victim reels, Hisagi whirls the
chain overhead, the blade across his face; 2 over his shoulder: the throw, the sickle nicks the victim and flies past; 3
low in front: he drops and pulls, the blade comes back through the victim's back (a white card, his silhouette, 2
drawings); 4 side-on: KUBIKAKE, the chain round his neck, the yank, the slam (dust ring, crack); 5 nearly top-down: flash
steps round him (afterimages), behind him, the reaping cut across: the Konpaku; 6 the white card: the chain slack, the
half-step back, 刈れ / 風死."
  ;; 1 (0-24) side, low, 3 m apart
  (at 0 (hs-cine-stage a v 3.0) (cine-clip a :hs-s-kari-aim :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-pose v 8) (freeze 8) (impact-frame :negative 2) (play-sfx :chain-rattle) (silence 24)
      (shot-on a 90 5.2 1.0 :look 1.3 :ahead 1.5) (lens 38))
  ;; 2 (24-54) over his shoulder: the throw (S at f30), the nick (f34), past him
  (at 24 (cine-clip a :hs-s-kari-o :blend 1 :time (/ 14.0 60.0)) (shot-on a 160 5.3 1.75 :look 1.35 :ahead 3.0) (lens 38))
  (at 30 (play-sfx :whoosh-heavy))
  (at 34 (cine-clip v :sh-flinch :blend 1) (play-sfx :cut) (hs-cine-hit v 1.25 :cut))
  (at 41 (play-sfx :chain-snap :pitch 1.2))
  ;; 3 (54-84) low in front: the pull (S at f60), the blade back through his back (f63): the white card, 2 drawings
  (at 54 (cine-clip a :hs-s-hiki :blend 2 :time (/ 14.0 60.0)) (hs-shot a 62 4.2 0.4 1.0 :ahead 1.5) (lens 60))
  (at 58 (play-sfx :chain-snap))
  (at 63 (card :white v) (silhouette-black v) (cine-clip v :sh-stagger :blend 0) (hold-pose v 4)
      (play-sfx :cut-heavy) (shake 0.2 0.25))
  (at 67 (unsilhouette) (card nil) (hs-cine-hit v 1.2 :heavy))
  ;; 4 (84-120) side-on: KUBIKAKE (S at f90), the yank, the slam (f98)
  (at 84 (face-each-other a v 1.4) (cine-clip a :hs-s-kubikake :blend 1 :time (/ 2.0 60.0))
      (cine-clip v :sh-kikon-victim :blend 3) (shot-pair a v 1 4.4 1.3) (lens 46) (play-sfx :hoho-out))
  (at 90 (play-sfx :chain-snap) (cine-clip v :sh-crumple :blend 1)
      (multiple-value-bind (x y z) (actor-point v 1.45) (focus-lines 8 x y z)))
  (at 98 (cine-clip v :sh-down :blend 3) (impact-frame :negative 2) (shake 0.35 0.4) (play-sfx :ground-crack) (play-sfx :land)
      (let ((q (pos-of v))) (vfx-shockwave (aref q 0) (aref q 2) 2.5 0.5 :pal +pal-dust+)
        (impact-splash (aref q 0) 0.0 (aref q 2) 10 0.07)))
  (at 100 (impact-frame :manga 6))
  ;; 5 (120-156) nearly top-down: the flash steps round him, behind him the reaping cut (S at f142): the Konpaku
  (at 120 (cine-clip v :sh-crumple :blend 6 :time 0.3) (cine-clip a :hs-s-stance :blend 0) (start-ghost a) (hs-round a v 1.6 60)
      (hs-top-shot v) (lens 50) (play-sfx :hoho-out))
  (at 124 (start-ghost a) (hs-round a v 1.6 120) (play-sfx :hoho-out :pitch 1.1))
  (at 128 (start-ghost a) (hs-round a v 1.4 180) (cine-clip a :hs-s-kari :blend 0 :time (/ 8.0 60.0)) (play-sfx :hoho-in))
  (at 136 (silence 6))
  (at 142 (impact-frame :negative 2) (cine-shatter v (fighter-kikon-n (fighter a)))
      (play-sfx :konpaku-shatter) (play-sfx :cut-heavy) (shake 0.3 0.4))
  (at 144 (impact-frame :manga 12))
  ;; 6 (156-180) the white card: the chain slack, the half-step back; 刈れ / 風死
  (at 156 (card :white a) (cine-clip a :hs-s-win :blend 6) (shot-on a 30 5.2 1.1 :look 1.15 :off -1.1) (lens 36)
      (caption "刈れ" :kanji2 "風死" :reading "KARE, KAZESHINI" :sub "KIKON" :side 1 :ink t :hanko t)))

(defcine hs-kosa-cine (a v :len 150 :hold 130)
  "The ranged mode's Kikon 降鎖 KOSA (§22.5): 1 low behind him: one crescent raised, the neck bundle hauled up off his
back; 2 the tilt up: the orb turning, every hanging chain hauled up into one giant twisted rope; 3 side-on, a long lens:
the rope whipped down along the lane, a wave of black down the ground to the victim; 4 on the victim: the impact, the
ground cracked in a line, a white card with his silhouette (2 drawings), the Konpaku; 5 wide: the chains fall back into
the curtain, he lowers the blade, unmoved: 降鎖."
  ;; 1 (0-25) low, behind him: the windup (KOSA's clip slowed, held at its peak f17 from f38)
  (at 0 (hs-cine-stage a v 7.0) (cine-clip a :hs-k-kosa :blend 2 :speed 0.45) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-pose v 10) (freeze 10) (impact-frame :negative 2) (silence 25) (play-sfx :chain-rattle :pitch 0.7)
      (shot-on a 165 3.0 0.5 :look 2.0) (lens 50))
  (at 38 (cine-clip a :hs-k-kosa :blend 0 :time (/ 17.0 60.0) :speed 0.0))
  ;; 2 (25-60) the tilt up: the rope gathered under the orb
  (at 25 (play-sfx :chain-rattle :pitch 0.5) (lens 54))
  (during (25 60) (hs-kosa-tilt a cf))
  (during (25 112) (setf *hs-chain-ink* (if (eq a *p1*) 0 1)) (hs-kosa-rope a v cf))
  (at 44 (play-sfx :chain-rattle :pitch 0.4))
  ;; 3 (60-90) side-on, a long lens: the whip (KOSA's S at f61), the wave down the lane
  (at 58 (cine-clip a :hs-k-kosa :blend 0 :time (/ 17.0 60.0)))
  (at 60 (hs-lane-shot a v 15.5 2.6 3.4) (lens 32) (play-sfx :whoosh-heavy :pitch 0.6))
  (at 74 (play-sfx :chain-snap :pitch 0.6) (play-sfx :ground-crack) (shake 0.25 0.3))
  (at 82 (play-sfx :ground-crack :pitch 0.8))
  ;; 4 (90-120) on the victim: the impact, the crack, the white card (2 drawings), the Konpaku
  (at 90 (shot-on v 35 3.8 0.8 :look 1.1) (lens 48) (impact-frame :negative 2) (cine-clip v :sh-crumple :blend 1)
      (play-sfx :explode :pitch 0.7) (shake 0.4 0.5) (hs-cine-hit v 1.0 :heavy))
  (at 92 (card :white v) (silhouette-black v) (hold-pose v 4))
  (at 96 (unsilhouette) (card nil) (cine-shatter v (fighter-kikon-n (fighter a))) (play-sfx :konpaku-shatter))
  (at 98 (impact-frame :manga 10))
  (during (90 150) (hs-kosa-crack a v cf))
  ;; 5 (120-150) wide: the curtain back, the blade lowered; 降鎖
  (at 120 (cine-clip a :hs-k-stance :blend 14) (shot-on a 125 8.0 1.5 :look 2.4 :off -1.3) (lens 46)
      (caption "降鎖" :reading "KOSA" :sub "FUSHI NO KOJO  KIKON" :side 1 :hanko t)))

(defcine hs-koshu-cine (a v :len 180 :hold 150)
  "The bind's Kikon 絞首 KOSHU (§22.5): 1 he zips along the noose chain (flash steps, afterimages); 2 behind the victim:
the chain drawn across his throat; 3 the orb sinks, chains rain onto him: bound standing; 4 he raises a blade, the noose
tightens on both necks: both choke (the shared pain); 5 the victim drops, the Konpaku; Hisagi stays up, shaking: 絞首."
  ;; 1 (0-30) the zip: hops along the line every 4 f, an afterimage each
  (at 0 (hs-cine-stage a v 6.0) (cine-clip a :hs-kb-koshu-run :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-pose v 6) (impact-frame :negative 2) (play-sfx :hoho-out) (play-sfx :chain-snap) (lens 44))
  (when (and step-p (<= 4 cf 24) (zerop (mod cf 4)))
    (start-ghost a) (face-each-other a v (- 6.0 (* 5.0 (/ (- cf 4) 20.0)))) (play-sfx :hoho-out :pitch (+ 0.9 (* 0.01 cf))))
  (during (0 30) (shot-pair a v -1 7.0 1.4))
  ;; 2 (30-70) behind the victim: the garrote (KOSHU's S at f38)
  (at 30 (hs-round a v 0.75 180) (cine-clip a :hs-kb-koshu :blend 0) (cine-clip v :hs-cine-choke-v :blend 4)
      (shot-on v 32 3.7 1.45 :look 1.4) (lens 46) (play-sfx :hoho-in) (silence 40))
  (at 38 (play-sfx :chain-snap) (shake 0.15 0.2) (face-beat v :hurt 3.0))
  ;; 3 (70-110) the orb sinks; the rain of chains; bound standing
  (at 70 (shot-on v 35 5.8 0.45 :look 2.6) (lens 62) (cine-clip v :sh-bound :blend 6) (play-sfx :chain-rattle :pitch 0.5))
  (during (80 150) (setf *hs-chain-ink* (if (eq a *p1*) 0 1)) (hs-koshu-rain v cf))
  (at 82 (play-sfx :chain-rattle))
  (at 96 (play-sfx :chain-snap) (shake 0.2 0.3))
  ;; 4 (110-150) the blade raised; the noose bites both necks
  (at 110 (cine-clip a :hs-cine-raise :blend 6) (cine-clip v :hs-cine-choke-v :blend 4) (face-beat a :hurt 4.0)
      (shot-on v 68 3.8 1.5 :look 1.6) (lens 46))
  (at 128 (impact-frame :negative 1) (play-sfx :chain-snap :pitch 0.7) (shake 0.25 0.6)
      (multiple-value-bind (x y z) (actor-point v 1.45) (focus-lines 20 x y z)))
  (at 132 (shot-on a 80 1.9 1.6 :look 1.55) (lens 44))
  ;; 5 (150-180) the victim drops; Hisagi stays up, shaking; 絞首
  (at 150 (cine-clip v :sh-crumple :blend 1) (impact-frame :negative 2) (cine-shatter v (fighter-kikon-n (fighter a)))
      (play-sfx :konpaku-shatter) (shake 0.3 0.4) (cine-clip a :hs-cine-shake :blend 6)
      (shot-on a 95 5.6 1.3 :look 1.4 :off -0.9) (lens 46))
  (at 152 (impact-frame :manga 12))
  (at 156 (caption "絞首" :reading "KOSHU" :sub "FUSHI NO KOJO  KIKON" :side 1 :hanko t)))

;;; ---------------------------------------------------------------- the cinematics' stills (debug 83965-83976)
;; 83965+c starts cinematic c from a fresh scene (0 the awakening: P1 Hisagi in his Shikai 6 m from an idle Kenpachi,
;; AWAKEN! itself; 1 刈れ, the Shikai 4 m from him; 2 KOSA, the ranged mode 7.5 m from him; 3 KOSHU, a bind 2 m from him),
;; played through; 83970+b restarts the last one held at its beat b's middle frame (*HS-CINE-BEATS*); 83976 lets go.
(defparameter *hs-cines* '(hs-awaken-cine hs-kare-cine hs-kosa-cine hs-koshu-cine) "83965+c: the cinematic c.")
(defparameter *hs-cine-beats*
  '((10 36 60 85 117 152) (12 40 64 94 140 168) (12 42 75 113 135) (15 50 92 122 165))
  "Each cinematic's beats' middle frames (83970+b; as built, DUEL_HISAGI §22.7).")
(defvar *hs-cine-k* 0 "The cinematic the last 83965+c picked.")
(defun hisagi-cine-scene (c)
  "83965+C's scene and its cinematic (see above)."
  (abort-cine)
  (ensure-battle :hisagi :kenpachi)
  (when (brain *p2*) (setf (brain-off (brain *p2*)) t))
  (setf (hss-bound (hs *p1*)) nil (gauges-awakened (gauges *p1*)) nil)
  (force-form *p1* :base)
  (hs-reset *p1*)
  (place *p1* *p2* (case c (0 6.0) (1 4.0) (2 7.5) (t 2.0)))
  (full-gauges! *p1*) (full-gauges! *p2*)
  (case c
    (0 (awaken! *p1*))
    (1 (start-cine 'hs-kare-cine *p1* *p2*))
    (2 (hs-awaken-now! *p1*) (start-cine 'hs-kosa-cine *p1* *p2*))
    (t (hs-awaken-now! *p1*) (hs-bind-start! *p1*) (set-form *p1* :bankai-bind) (start-cine 'hs-koshu-cine *p1* *p2*))))
(defun hisagi-cine-debug (c)
  "83965-83968: cinematic c played (HISAGI-CINE-SCENE); 83970-83975: the last one held at beat b; 83976 lets go."
  (cond ((< c 83969) (setf *hs-cine-k* (- c 83965) *cine-hold* nil) (hisagi-cine-scene *hs-cine-k*))
        ((< c 83976)
         (let ((f (nth (- c 83970) (nth *hs-cine-k* *hs-cine-beats*))))
           (when f
             (setf *cine-hold* t)
             (hisagi-cine-scene *hs-cine-k*)
             (when *cine* (setf (cine-hold *cine*) f)))))
        (t (abort-cine) (setf *cine-hold* nil))))
(pushnew '(83965 83976 hisagi-cine-debug) *char-debug* :test #'equal)

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

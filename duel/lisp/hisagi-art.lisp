;;;; hisagi-art.lisp — HISAGI SHUHEI as art data (docs/duel/DUEL_HISAGI.md §11, §21): the Shikai's own clips (batch B3a,
;;;; §21.4: the approved slot plan §21.3, drawn to the current volumes; their :pose hook HS-POSE and HISAGI-DRAW's
;;;; let-outs) and the Bankai's (batch B3b, §21.8: both modes, exaggerated windups, the chain strikes); his body (TYBW:
;;;; the sleeveless shihakusho, the white sash, a choker and two armbands, the
;;;; lieutenant's badge on the left arm, short messy black hair, three scars down over the right eye, the 69 and the blue
;;;; stripe on the left cheek; redone to canon, DUEL_HISAGI §21 "Look as built"), Kazeshini (a 0.97 m black rod with a
;;;; crescent of two blades, one inverted, the chain from butt to butt: the right hand's is the held weapon, the left
;;;; hand's the thrown one, drawn by HISAGI-DRAW), one clip per move at the move's frames, and the data the drawn reaches
;;;; come from (the thrown sickle's tip at the hit volume's end, *HS-STRIKE-REACH*; the pulls' chain along HS-CHAIN-SEG's
;;;; segment; the host test reads those tables here).
;;;; The rest of what was one file until 2026-10-21 (refactor round 2) loads right after this one, same prefix:
;;;;   hisagi-draw.lisp   the looks, the chain and the sickle's flight, the windmill, the lightning, HISAGI-DRAW, the HUD's sickle
;;;;                      icon, his glyphs' name
;;;;   hisagi-cine.lisp   his four cinematics (batch B5, §22.7: the awakening, the Shikai Kikon 刈れ, KOSA, KOSHU)
;;;;   hisagi-stills.lisp debug stills and probes (83500-83549, 83901-83994), including the model-sheet scenes (83980-83985)
(in-package :duel)

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
          (mb-at (mb :y 0.695) (mb-cone mb 0.012 0.11 :segments 6))
          (mb-tube mb 0 -0.16 0 0.022 -0.215 0 0.008 :sides 4)
          (mb-tube mb 0 -0.16 0 -0.022 -0.215 0 0.008 :sides 4)
          (mb-tube mb -0.024 -0.222 0 0.024 -0.222 0 0.006 :sides 4)
          (mbc mb #x2A2A30)                                                                ; the chain's first link
          (mb-at (mb :y -0.25 :yaw 1.57) (mb-box mb 0.01 0.05 0.03))
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
                                  (:hs-s-sen :sickle 1.7) (:hs-na1 :sickle 1.7)   ; (§26: NA1's coil, J1's hit)
                                  (:hs-kr-tan :sickle 2.5) (:hs-kr-ren :sickle 1.7) (:hs-kr-sen :sickle 3.0)   ; (§27.5: pointer 2
                                  (:hs-kr-ko :sickle 2.4) (:hs-kr-age :sickle 2.4)                             ;  刈's let-outs)
                                  (:hs-s-kaeshi :sickle 1.7) (:hs-s-rin :sickle 1.7)  ;  clips, §21.4;
                                  (:hs-s-nagi :sickle 6.0) (:hs-s-tobi-kaeshi :sickle 1.7) (:hs-s-tobi-rin :sickle 1.7)   ;  A1, §24.1; §25.9: J 1.7)
                                  (:hs-k-saben :sickle 6.0) (:hs-k-kaeshi :sickle 6.0) (:hs-k-sensa :chain 6.0)   ; (the Bankai's,
                                                                                ;  §28.19: J5's a lash now)
                                                                                ;  §21.8; B4a: the annuli's 4.5 / 5.0, the K placed, §22.2: the
                                  (:hs-kb-kaeshi :sickle 1.5) (:hs-kb-hikigiri :sickle 2.95)                    ;  ranged mode,
                                  (:hs-kb-sengen :sickle 2.2)                                                   ;  §25.10,
                                  (:hs-kb-makigiri :chain 2.8) (:hs-kb-shibori :chain 2.95)                     ;  the bind's)
                                  (:hs-kb-juji :sickle 1.5) (:hs-kb-matoi :sickle 2.95) (:hs-kb-shime :chain 2.8)   ; (batch 2b,
                                  (:hs-kb-tsuri :chain 3.0) (:hs-kb-kagiyose :sickle 6.0) (:hs-kb-kagiyose-giri :sickle 6.0)   ;  §28.12)
                                  (:hs-kb-san :sickle 3.0)                                                      ; (§28.13)
                                  (:hs-k-hosoku :chain 4.5) (:hs-k-s-k2 :chain 4.5) (:hs-k-s-k3 :chain 4.5)    ; (A2, §24.2: the
                                  (:hs-k-g-k2 :chain 4.5) (:hs-k-g-j2 :chain 4.5) (:hs-k-g-k3 :chain 4.5)     ;  ranged route
                                  (:hs-k-g-j3 :chain 4.5)                                                     ;  links, *HS-LASHES*; §25.3 / §25.5: J 6, K 5; §25.34: J 7, K 5.5;
                                                                                ;  §25.35: J 6, K 4.5; §28.11: the gathered J 4.5)
                                  (:hs-k-uchi :chain 6.0) (:hs-k-ogi :chain 6.0) (:hs-k-issei :chain 6.0)       ; (batch 2a, §28.11:
                                  (:hs-k-ransa :chain 6.0) (:hs-k-tataki :chain 3.0) (:hs-k-sweep :chain 4.5)   ;  the core ranged
                                  (:hs-k-jibashiri :chain 4.5)                                                  ;  mode's own clips)
                                  (:hs-k-na3 :chain 6.0) (:hs-k-na4 :chain 6.0) (:hs-k-g-na3 :chain 4.5)        ; (§28.15: the five
                                  (:hs-k-g-na4 :chain 4.5)                                                      ;  J's own J3 / J4)
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
(defparameter *hs-grip* '((:hs-s-sen 0.25) (:hs-na1 0.25) (:hs-s-kaeshi 0.25) (:hs-s-kaeshi-1h 0.25) (:hs-s-tobi-kaeshi 0.25))
  "Clip -> the J strings' short grip (the user, 2026-10-17: 「握在靠刀的那端」, DUEL_HISAGI §21): the drawn right rod slid
this far back through his fist (m), so he holds it just behind the blades' crossing; its point (the FK test's tip) is
0.75 - this ahead of the fist, its butt 0.22 + this behind. HS-POSE eases it in and out (4 m/s); the FK test reads it.")
(defparameter *hs-letout*
  '((:hs-s-sen :r 3 8 11 18 1.7 nil nil 0)          ; J1: the right sickle let out a hand's length on its chain (§25.9)
    (:hs-na1 :r 11 14 17 24 1.7 nil nil 0)          ; NA1 (§26): the same, in the fist through the held coil
    (:hs-kr-tan :r 13 16 19 26 2.5 1.15 (-50 10 30) 0)   ; §27.5 刈: TAN-GARI's cross cut, the right one R -> L, the left
    (:hs-kr-tan :l 13 16 19 26 2.5 1.15 (50 -10 -30) 0)  ;  L -> R, crossed at 2.5 m on the hit frames f16-18 (inside +-55)
    (:hs-kr-ren :l 1 5 7 11 1.2 nil 30 0.6)              ; REN-GARI: the left wheel first (the tell, no hit), then
    (:hs-kr-ren :r 9 12 15 21 1.7 0.9 -8 0.7)            ;  the right one over and down onto him (f12-14)
    (:hs-kr-sen :r 12 16 21 30 3.0 1.05 nil 0)           ; SEN-GARI: both flung out to the 3 m circle, on the fists'
    (:hs-kr-sen :l 12 16 21 30 3.0 1.05 nil 0)           ;  bearings round the spin (f16-18)
    (:hs-kr-ko :r 5 8 11 17 2.4 0.6 (-60 -15 20) 0)      ; KO-GARI: the closing scissor low at his legs, out -> in
    (:hs-kr-ko :l 5 8 11 17 2.4 0.6 (60 15 -20) 0)       ;  (f8-10)
    (:hs-kr-age :r 6 9 11 22 2.4 1.5 8 0.4)              ; KARI-AGE: hooked in at his chest (f9-11), reeled back up to the
    (:hs-kr-age :l 6 9 11 22 2.4 1.5 -8 0.4)             ;  raised fists (h 1.5: on the arms' line they flew 3.5 m up, into the HUD)
    (:hs-s-kaeshi :l 3 8 11 18 1.7 nil nil 0)       ; J2: the left sickle flung out on the arm's rising line
    (:hs-s-rin :r 2 6 12 22 1.7 nil nil 0)          ; J3: both whirled out round him
    (:hs-s-rin :l 2 6 12 22 1.7 nil nil 0)
    (:hs-s-kari :r 10 22 30 46 2.8 0.3 -60 1.8)     ; KARI-OTOSHI: over his head and down to the fan's edges
    (:hs-s-kari :l 10 22 30 46 2.8 0.3 60 1.8)
    (:hs-s-intro :r 70 82 82 96 0.3 2.9 0 0)        ; the intro: tossed up, split, caught
    (:hs-s-intro :l 70 84 84 98 0.5 2.6 25 0)
    (:hs-s-nagi :l 9 16 24 36 6.0 1.0 (160 75 -75) 0)   ; A1 (§24.1): K1 薙, flung out behind him, swept L -> R at 6.0 x the
                                                        ;  charge (the hit frames f18-21 at +38 / +19 / 0 / -19: inside +-45)
    (:hs-s-tobi-kaeshi :l 9 14 17 24 1.7 nil nil 0)     ; J2K: J2's let-out, 6 f later (out in the leap's fall)
    (:hs-s-tobi-rin :r 8 12 17 27 1.7 nil nil 0)        ; J3K: J3's two, out from the leap's top
    (:hs-s-tobi-rin :l 8 12 17 27 1.7 nil nil 0)
    (:hs-k-saben :r 9 12 16 24 6.0 1.2 nil 0)       ; the Bankai (§21.8): J1 鎖鞭, the right crescent cracked out (§25.3: 6.0; §25.34's 7.0, back)
    (:hs-k-kaeshi :r 6 10 13 21 6.0 (2.0 1.8 0.5) (-60 -25 25) 0)   ; §28.19: J2 鋏鞭, both crescents swept in from high on
    (:hs-k-kaeshi :l 6 10 13 21 6.0 (2.0 1.8 0.5) (60 25 -25) 0)    ;  both sides and falling, crossed at him (f11.5: the X;
                                                    ;  the hit frames f10-12 at -+25 / -+8 / +-8, inside +-50; *HS-LO-TRAILS*);
                                                    ;  J5's two let-outs gone (its chains are the drill, *HS-LASHES*)
    (:hs-kb-kaeshi :l 5 8 11 18 1.5 nil nil 0)      ; the bind's J2 返弦, the left rising on a short chain
    (:hs-kb-hikigiri :r 15 18 23 32 2.95 1.1 0 0)   ; K1 引斬, the right hooked out along the line
    (:hs-kb-sengen :r 6 10 13 24 2.2 nil 0 0)       ; Step + J 穿弦 SENGEN (§25.10), the right hurled straight ahead
    (:hs-cine-kg-haul :r -2 0 9999 9999 6.0 1.1 0 0)     ; batch 3b (§28.17): 鉤刈 KAGI-GARI's cinematic clips: the right hooked
    (:hs-cine-kg-cuts :r -2 0 9999 9999 6.0 1.3 -8 0)    ;  in him through the hand-over-hand reel (KAGIYOSE's point) and the
    (:hs-cine-kg-cuts :l 22 25 9999 9999 6.0 1.3 8 0.3)  ;  cuts, the left flung into his other side (f25), both held through
    (:hs-cine-kg-strain :r -2 0 9999 9999 6.0 1.3 -8 0)  ;  the strain and ripped out apart (-8 -> -80 / 8 -> 80 by f5, back in
    (:hs-cine-kg-strain :l -2 0 9999 9999 6.0 1.3 8 0)   ;  the fists by f18); on him by *HS-KB-REELS*
    (:hs-cine-kg-rip :r -2 0 5 18 6.0 1.3 (-8 -8 -80) 0.4)
    (:hs-cine-kg-rip :l -2 0 5 18 6.0 1.3 (8 8 80) 0.4)
    (:hs-kb-raiden :l 11 14 18 30 4.3 1.1 0 0)      ; SP1, the left down the line (the bolt along it)
    (:hs-kb-kojo :r 27 30 34 46 3.0 0.7 nil 0.6)    ; A3 (§24.3): L 絞縄 KOJO (S 30), the wide reap, flung from overhead
    (:hs-kb-kaibaku :r 15 18 22 34 3.0 1.0 (-120 -50 50) 0)   ; SP2 解縛擊 (S 18), a flat sweep R -> L at 3.0 m (the hit
                                                        ;  frames f18-21 at -50 / -25 / 0 / +25: inside +-70)
    (:hs-kb-kagiyose :r 16 18 30 36 6.0 1.1 0 0)          ; batch 2b (§28.12): NS1a KAGIYOSE, the right cast onto him (*HS-KB-REELS*)
    (:hs-kb-kagiyose-giri :l 16 18 26 29 6.0 1.1 0 0)     ; AS1, the left bowled onto him, held through the drag
    (:hs-kb-juji :r 10 14 17 24 1.5 1.0 (-70 -30 30) 0.8) ; NS1c JUJI, over and down, R -> L / L -> R crossing on the hit
    (:hs-kb-juji :l 10 14 17 24 1.5 1.0 (70 30 -30) 0.8)  ;  frames f14-16 (-30 / -10 / +10: inside +-100)
    (:hs-kb-san :r 6 9 12 18 3.0 1.2 (-10 -40 -95) 0.5)   ; §28.13: AS3b SAN, both scattered apart across the front (the
    (:hs-kb-san :l 6 9 12 18 3.0 1.2 (10 40 95) 0.5)      ;  hit frames f9-11 at 40 / 58 / 77 deg: inside +-100)
    (:hs-kb-matoi :l 17 20 32 38 2.95 1.1 (80 2 -4) 0.3)) ; NS2a MATOI, curled round from his left onto the line (f20-23 at
                                                        ;  2 / 1.5 / 1 / 0.5 deg: inside its 0.35 m at 2.95 m, +-6.8; §28.15: was
                                                        ;  5 -> -5, 0.22 m off him at 2.5 m), onto him (his bearing on a hit)
  "Clip -> a sickle let out of the fist on its chain: (clip side f0 f1 f2 f3 r h az bulge): it leaves the fist at clip
frame F0, is out from F1 to F2 with its point R m from his feet (horizontally), back in the fist at F3; along the fist's
bearing from his feet (AZ NIL) or AZ degrees off his facing (+ his left); H m up (NIL: on the arm's line); BULGE m higher
midway out (an overhead swing; a third of it coming back). AZ a list (A0 A1 A2): a sweep, the bearing A0 at F0 turning to
A1 at F1 (it spirals out) and on to A2 at F2 (linear), A2 coming back (K1 NAGI, A1). H a list (H0 H1 H2) the same way
(§28.19: J2's falling X). HS-POSE moves the right one (its
:weapon-r joint), HISAGI-DRAW draws the left one; both the chain from the fist.")
(defparameter *hs-foe-paths*
  '((:hs-s-noko (6 9 10 9 1) (9 16 9 9 3) (16 20 9 6 3) (20 24 6 6 3) (24 30 6 7 3) (30 38 7 7 1) (38 48 7 0 1))
    (:hs-s-tsui (8 18 6 8 1) (18 20 8 8 1) (20 22 8 6 4) (22 32 6 6 4) (32 46 6 0 1))
    (:hs-tsumuji (5 14 0 12 5) (14 30 12 12 5) (30 38 12 0 5)))
  "A1 (DUEL_HISAGI §24.1): the Shikai K links placed on the victim (K2 鋸 NOKO, K3 墜 TSUI; HS-FOE-SEG): clip -> the left
sickle's path, segments (f0 f1 a b spin): on clip frames F0 <= f < F1 it moves from point A to point B (%HS-POINT's codes:
0 his left fist, 6 the victim's centre (HS-FOE-SEG's far end), 7 3.0 m above him, 8 3.8 m above him (the sky: the top of the match camera's frame over him), 9 the saw's
wheel round the left fist, 10 K1's sweep end: 6.0 m x the charge, 40 degrees to his right, 11 HS-CORE-SEG's far end: the
victim's centre, or *HS-CORE-CHAIN* m along the line to him, 12 the orbit round 11, *HS-TSUMUJI-ORBIT* m), placed by
%HS-PLACE! SPIN (1 tumbling, 3 the upright saw, 4 point down, 5 the flat spinning disc, tipped up 22 degrees); outside
every segment it is in his fist. On every hit frame it is at 6 (12 for AS1 TSUMUJI; the host checks). NOKO: reeled in off
K1's sweep (off J1, K2J: from the fist), spun up on the wheel, flung along the line at him (S 20), the saw grinding there
through A, hauled up over him, back; TSUI: hauled from him up into the sky, held, yanked down point first onto him (S 22),
held in him, hauled back; AS1 TSUMUJI (§27.10): thrown flat off the sidearm release (f5), spinning flat round him through
the four cuts (f14-29, at each %HS-TSUMUJI-CUTS arc's head on its hit frame), reeled back to the fist (f30-38).")

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

;;; ---------------------------------------------------------------- the core system's NA1 and pointer stances (DUEL_HISAGI §26)
;; NA1 旋 SEN (14/3/12, the core rebuild's tell, §26.2): J1's cut with a big coil reached early (f5) and held to f13 (the
;; opponent reads it and can cancel it): wound hard to his right, the right sickle swung far back behind his right
;; shoulder, the left hand thrust out at him (the aim), sunk low; snapped in at S 14 to J1's own hit pose and follow-through
;; (the hit frames' geometry = :hs-s-sen's, so the drawn reach stays its 1.7 m: *HS-STRIKE-REACH*, *HS-LETOUT*, *HS-GRIP*)
(defstrike :hs-na1 (14 3 12 :base :hs-s-stance)
  (0)
  (5 (:root :u -0.13 :yaw -30) (:chest :twist -40) (:spine :flex 12) (:neck :twist 30)
     (:arm-r :flex -40 :side 84 :twist 0) (:elbow-r :flex 24) (:hand-r :flex -90)
     (:arm-l :flex 72 :side 10 :twist 0) (:elbow-l :flex 16) (:hand-l :flex -40) (:knees :flex 40))     ; the coil
  (11 (:root :u -0.15 :yaw -34) (:chest :twist -46) (:spine :flex 14) (:neck :twist 34)
      (:arm-r :flex -48 :side 86 :twist 0) (:elbow-r :flex 20) (:hand-r :flex -90)
      (:arm-l :flex 76 :side 8 :twist 0) (:elbow-l :flex 12) (:hand-l :flex -40) (:knees :flex 46))     ; held: the tell
  (:s :snap :hs-s-sen-hit)
  (:a (:root :yaw 14 :f 0.14) (:chest :twist 24) (:arm-r :flex 108 :side 84))                           ; through, R to L
  (23 (:root :u -0.07 :yaw 8 :f 0.06) (:chest :twist 12) (:arm-r :flex 80 :side 44) (:elbow-r :flex 40) (:hand-r :flex -70))
  (:end :hs-s-stance))

;; pointer 2 縛 the bind (motion-refs §1.7, `336Hisagi_and_Izuru_intervene`, `337Kubikake1`): the chain thrown over his left
;; shoulder like a hawser, the left fist clenched on it at his chest, the left sickle hanging down his back on it (HISAGI-DRAW,
;; lo 2048), the left elbow out wide; the right sickle held level behind his right hip, pointing back (neither pointer 1's
;; low-forward rod nor pointer 3's raised one); the left shoulder drawn back, the weight back
(defpose :hs-st-bind (:base :hs-s-stance)
  (:root :u -0.09 :f -0.04 :yaw 12) (:pelvis :twist 4) (:spine :flex 4) (:chest :twist 8) (:neck :twist -12) (:head :flex 4)
  (:arm-l :flex 24 :side 72 :twist 0) (:elbow-l :flex 146) (:hand-l :flex 10)
  (:arm-r :flex -30 :side 40 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -170)
  (:thigh-l :flex 30 :side 12) (:knee-l :flex 26) (:thigh-r :flex -14 :side 14) (:knee-r :flex 30))
(defclip :hs-st-bind (2.0 :loop t :base :hs-st-bind)
  (0) (1.0 (:root :u -0.105) (:chest :flex 3) (:elbow-l :flex 140) (:hand-r :flex -164)))

;; pointer 3 雷 the lightning (Hadō #11 Tsuzuri Raiden down the chain; ch. 337 "one hand high on the taut chain"): the left
;; fist raised high over his head, its sickle pointing up; the right one low out at his right hip; the chain between them
;; drawn taut across his body, small sparks crawling down it (HISAGI-DRAW, lo 4096); square to him, the feet wide
(defpose :hs-st-raiden (:base :hs-s-stance)
  (:root :u -0.1 :f 0.02 :yaw 6) (:pelvis :twist 0) (:spine :flex 4) (:chest :twist 6) (:neck :twist -4) (:head :flex -4)
  (:arm-l :flex 164 :side 18 :twist 0) (:elbow-l :flex 14) (:hand-l :flex -84)
  (:arm-r :flex 14 :side 40 :twist 0) (:elbow-r :flex 12) (:hand-r :flex -110)
  (:thigh-l :flex 30 :side 18) (:knee-l :flex 28) (:thigh-r :flex -10 :side 20) (:knee-r :flex 30))
(defclip :hs-st-raiden (2.0 :loop t :base :hs-st-raiden)
  (0) (1.0 (:root :u -0.115) (:arm-l :flex 160) (:elbow-l :flex 18) (:arm-r :side 42)))

;; §27.6 (the user, 2026-10-28: 「應該是要沿著綑綁的鎖鏈延伸電擊才對，放電也一樣是沿著最初綑綁的鎖鏈炸開電擊」): pointer 3 縛雷's two
;; segments after the bind play his own clips (no throw, no RAIDEN beam); the chain stays wound on the victim from NS3a's
;; cast (HISAGI-DRAW, by the move's name), the lightning drawn along it (%HS-VOLT).
;; NS3b 蓄電 CHIKUDEN (20/4/24, entered at frame 6 as NOKO's link): from the cast's reach he hauls the binding chain in hand
;; over hand (f6-10), then sets pointer 3's stance on it: the left fist high on the taut chain, the right rod low at his
;; right hip (held f15-19: the charge); at S the fist jerks up on the chain (the lightning sent along it into the coil:
;; %HS-VOLT); he holds the taut chain through the gap. The body and the right rod stand still from S-4 to S+A+3 (f16-27)
;; and the rod stays low by his hips: the engine's swing smear on the rod over those frames (and a :flash move's stretch
;; drawing on S) drew a yellow beam up out of a raised right hand
(defpose :hs-chikuden-hold (:base :hs-st-raiden)
  (:root :f 0.0 :u -0.14 :yaw -2) (:spine :flex 2) (:chest :twist -6) (:head :flex -4)
  (:arm-l :flex 164 :side 16 :twist 0) (:elbow-l :flex 12) (:hand-l :flex -84)
  (:arm-r :flex 16 :side 40 :twist 0) (:elbow-r :flex 14) (:hand-r :flex -110)
  (:thigh-l :flex 36 :side 16) (:knee-l :flex 34) (:thigh-r :flex -14 :side 18) (:knee-r :flex 26))
(defpose :hs-chikuden-hit (:base :hs-chikuden-hold)
  (:head :flex -10) (:arm-l :flex 174 :side 18) (:elbow-l :flex 2) (:knee-l :flex 40) (:knee-r :flex 32))
(defstrike :hs-chikuden (20 4 24 :base :hs-st-raiden)
  (0)
  (6 (:root :f 0.08 :u -0.1 :yaw -8) (:spine :flex 10) (:chest :twist -16)
     (:arm-l :flex 94 :side 8 :twist 0) (:elbow-l :flex 2) (:hand-l :flex -20)
     (:arm-r :flex 40 :side 24 :twist 0) (:elbow-r :flex 50) (:hand-r :flex -40)
     (:thigh-l :flex 40 :side 10) (:knee-l :flex 40) (:thigh-r :flex -20 :side 12) (:knee-r :flex 16))   ; the cast's reach
  (10 (:root :f -0.06 :u -0.12 :yaw 0) (:spine :flex -8) (:chest :twist -4)
      (:arm-l :flex 120 :side 12) (:elbow-l :flex 60) (:hand-l :flex -40)
      (:arm-r :flex 100 :side -6) (:elbow-r :flex 40) (:hand-r :flex -20))                                 ; hauled in
  (15 :hs-chikuden-hold)                                                                                   ; up: the fingers on it
  (18 :hs-chikuden-hold (:arm-l :flex 160) (:elbow-l :flex 16))                                           ; held
  (:s :snap :hs-chikuden-hit)
  (:a :hs-chikuden-hit)
  (28 :hs-chikuden-hit)
  (36 :hs-chikuden-hold)                                                                                   ; the gap: held taut
  (:end :hs-st-raiden))
;; 放電 HODEN (10/3/24, the SA in CHIKUDEN's gap): drawn back (f4, the tell: the fist up over his left shoulder, leant back,
;; the right rod kept low at his hip); at S the left fist yanks the chain down to his waist (the burst runs down it and
;; explodes on the victim: %HS-VOLT, %HS-HODEN-BURST); the body and the right rod stand still from S-4 to S+A+3 (f6-16, the
;; swing smear: a right hand raised there drew a yellow beam), then the follow-through pitches him forward
(defpose :hs-hoden-back (:base :hs-st-raiden)
  (:root :f -0.08 :u -0.14 :yaw -6) (:spine :flex -10) (:chest :twist -12) (:head :flex -8)
  (:arm-l :flex 174 :side 26 :twist 0) (:elbow-l :flex 42) (:hand-l :flex -70)
  (:arm-r :flex 16 :side 40 :twist 0) (:elbow-r :flex 14) (:hand-r :flex -110)
  (:thigh-l :flex 30 :side 18) (:knee-l :flex 30) (:thigh-r :flex -10 :side 20) (:knee-r :flex 30))
(defpose :hs-hoden-hit (:base :hs-hoden-back)
  (:head :flex 6) (:arm-l :flex 50 :side 14) (:elbow-l :flex 8) (:hand-l :flex -30)
  (:thigh-l :flex 50 :side 18) (:knee-l :flex 50) (:thigh-r :flex -24 :side 20) (:knee-r :flex 22))
(defstrike :hs-hoden (10 3 24 :base :hs-st-raiden)
  (0 :hs-chikuden-hold)
  (4 :hs-hoden-back)                                                                                       ; drawn back: the tell
  (8 :hs-hoden-back (:arm-l :flex 178) (:elbow-l :flex 48))                                               ; held
  (:s :snap :hs-hoden-hit)
  (:a :hs-hoden-hit)
  (16 :hs-hoden-hit)
  (20 :hs-hoden-hit (:root :f 0.1 :u -0.22 :yaw 4) (:spine :flex 22) (:chest :twist 8))                  ; the follow-through
  (28 (:root :u -0.14) (:spine :flex 8) (:arm-l :flex 90 :side 16) (:elbow-l :flex 20) (:arm-r :flex 20 :side 36)
      (:elbow-r :flex 20))                                                                                 ; the chain let go
  (:end :hs-st-raiden))

;;; ---------------------------------------------------------------- pointer 2 刈 KARI, the short-chain reaping (DUEL_HISAGI §27.3, §27.5)
;; The stance: a reaper's crouch, square and low, the head down; both fists in front of the hips, the elbows out, each sickle
;; reverse-gripped (the rod back along the forearm, its blades trailing past the hip: from behind they fan out on both sides
;; toward the camera), the chain wound twice round each wrist and a short taut span between the fists (HISAGI-DRAW, lo 8192).
;; Neither pointer 1's rod low-forward, nor the hawser over the shoulder, nor the raised fist.
(defpose :hs-st-kari (:base :hs-s-stance)
  (:root :u -0.16 :f 0.0 :yaw 0) (:pelvis :twist 0) (:spine :flex 16) (:chest :twist 0) (:neck :twist 0) (:head :flex -10)
  (:arm-r :flex 10 :side 38 :twist 0) (:elbow-r :flex 96) (:hand-r :flex 104 :twist 0)
  (:arm-l :flex 10 :side 38 :twist 0) (:elbow-l :flex 96) (:hand-l :flex 104 :twist 0)
  (:thigh-l :flex 40 :side 20) (:knee-l :flex 46) (:thigh-r :flex 8 :side 22) (:knee-r :flex 44))
(defclip :hs-st-kari (2.0 :loop t :base :hs-st-kari)
  (0) (1.0 (:root :u -0.175) (:spine :flex 18) (:hand-r :flex 98) (:hand-l :flex 110)))
;; NS2a 短刈 TAN-GARI (16/3/13, the slide 1.0): the tell, both arms crossed high before his face (an X, the blades up behind
;; the fists), sunk on the back foot, held f5-13; snapped into a step, both sickles let out on a hand's span of chain and
;; swept across each other at chest height: the right one right to left, the left one left to right (*HS-LETOUT*'s sweeps,
;; crossing at 2.5 m inside the 110 degree arc); the arms end crossed low at the waist
(defpose :hs-kr-tan-hit (:base :hs-st-kari)
  (:root :f 0.16 :u -0.14 :yaw 0) (:spine :flex 12) (:chest :twist 0) (:head :flex -4)
  (:arm-r :flex 100 :side 62 :twist 0) (:elbow-r :flex 6) (:hand-r :flex -90)
  (:arm-l :flex 100 :side 62 :twist 0) (:elbow-l :flex 6) (:hand-l :flex -90)
  (:thigh-l :flex 52 :side 10) (:knee-l :flex 40) (:thigh-r :flex -22 :side 12) (:knee-r :flex 20))
(defstrike :hs-kr-tan (16 3 13 :base :hs-st-kari)
  (0)
  (5 (:root :u -0.2 :f -0.08) (:spine :flex 6) (:head :flex -2)
     (:arm-r :flex 110 :side -20 :twist 90) (:elbow-r :flex 100) (:hand-r :flex -60)
     (:arm-l :flex 110 :side -20 :twist 90) (:elbow-l :flex 100) (:hand-l :flex -60)
     (:thigh-l :flex 30) (:knee-l :flex 50) (:thigh-r :flex 20) (:knee-r :flex 60))                     ; the X (the tell)
  (13 (:root :u -0.22 :f -0.1) (:spine :flex 4)
      (:arm-r :flex 118 :side -22 :twist 90) (:elbow-r :flex 104) (:arm-l :flex 118 :side -22 :twist 90) (:elbow-l :flex 104)
      (:knee-l :flex 54) (:knee-r :flex 64))                                                             ; held
  (:s :snap :hs-kr-tan-hit)
  (:a (:root :f 0.2) (:arm-r :flex 110 :side 20) (:arm-l :flex 110 :side 20))                         ; through, crossing
  (25 (:root :f 0.1 :u -0.16) (:spine :flex 16) (:arm-r :flex 60 :side -10) (:elbow-r :flex 30) (:hand-r :flex -60)
      (:arm-l :flex 60 :side -10) (:elbow-l :flex 30) (:hand-l :flex -60))                             ; crossed low
  (:end :hs-st-kari))
;; NS2b 連刈 REN-GARI (12/3/12): the two sickles whirled in turn on short chains, each in a vertical wheel at his side: the
;; left one first (f1-11, up over and down at 1.2 m: the tell, no hit), then the right one over and down onto him at S
;; (1.7 m, J1's reach); the body rocks with each, twisting to the side of the wheel
(defpose :hs-kr-ren-hit (:base :hs-st-kari)
  (:root :f 0.1 :u -0.18 :yaw 14) (:spine :flex 22) (:chest :twist 16) (:head :flex -6)
  (:arm-r :flex 70 :side 14 :twist 0) (:elbow-r :flex 10) (:hand-r :flex -80)
  (:arm-l :flex -20 :side 30 :twist 0) (:elbow-l :flex 60) (:hand-l :flex 100)
  (:thigh-l :flex 46 :side 14) (:knee-l :flex 50) (:thigh-r :flex -10 :side 18) (:knee-r :flex 34))
(defstrike :hs-kr-ren (12 3 12 :base :hs-st-kari)
  (0)
  (3 (:root :u -0.14 :yaw -14) (:chest :twist -18) (:spine :flex 10)
     (:arm-l :flex 160 :side 16 :twist 0) (:elbow-l :flex 12) (:hand-l :flex -80))                    ; the left wheel up
  (7 (:root :u -0.2 :yaw -6) (:chest :twist -6) (:spine :flex 20)
     (:arm-l :flex 40 :side 22) (:elbow-l :flex 20) (:hand-l :flex -70)
     (:arm-r :flex 168 :side 20 :twist 0) (:elbow-r :flex 16) (:hand-r :flex -80))                    ; down; the right one up
  (10 (:root :u -0.16 :yaw 0) (:arm-r :flex 150 :side 18) (:arm-l :flex -10 :side 28) (:elbow-l :flex 50) (:hand-l :flex 90))
  (:s :snap :hs-kr-ren-hit)
  (:a (:root :f 0.12) (:arm-r :flex 30 :side 18) (:spine :flex 26))                                 ; down through him
  (21 (:root :u -0.17 :yaw 6) (:chest :twist 6) (:arm-r :flex 20 :side 36) (:elbow-r :flex 70) (:hand-r :flex 60))
  (:end :hs-st-kari))
;; NS2c 旋刈 SEN-GARI (16/3/18, arc 360, the knockdown): wound hard to his right, both arms wrapped (the right across his
;; chest, the left behind), sunk low and held f4-12 (the tell); then a whole-body turn to his left on the left foot (a key
;; every ~90 degrees) with both sickles let out to a 3.0 m circle round him (*HS-LETOUT*, along the fists' bearings: they
;; follow the spin), the arms flung out level; ends square, the chains reeled back in
(defpose :hs-kr-sen-hit (:base :hs-st-kari)
  (:root :yaw 290 :u -0.12) (:pelvis :twist 0) (:spine :flex 8) (:chest :twist 6) (:head :flex 0)
  (:arm-r :flex 20 :side 86 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -90)
  (:arm-l :flex 20 :side 86 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -90)
  (:thigh-l :flex 24 :side 10) (:knee-l :flex 30) (:thigh-r :flex 4 :side 22) (:knee-r :flex 30))
(defstrike :hs-kr-sen (16 3 18 :base :hs-st-kari)
  (0)
  (4 (:root :u -0.2 :yaw -50) (:chest :twist -30) (:spine :flex 18)
     (:arm-r :flex 70 :side -30 :twist 0) (:elbow-r :flex 90) (:hand-r :flex 100)
     (:arm-l :flex -40 :side 30 :twist 0) (:elbow-l :flex 80) (:hand-l :flex 100) (:knees :flex 56))   ; wound right
  (12 (:root :u -0.22 :yaw -60) (:chest :twist -36) (:spine :flex 20)
      (:arm-r :flex 74 :side -34) (:elbow-r :flex 96) (:arm-l :flex -44 :side 32) (:knees :flex 60))   ; held: the tell
  (13 (:root :u -0.16 :yaw 20) (:chest :twist 0) (:spine :flex 12) (:arm-r :flex 30 :side 70) (:elbow-r :flex 20)
      (:hand-r :flex -90) (:arm-l :flex 10 :side 70) (:elbow-l :flex 20) (:hand-l :flex -90))           ; flung out
  (14 (:root :u -0.13 :yaw 110) (:chest :twist 6) (:arms :flex 20 :side 84) (:elbows :flex 6))
  (15 (:root :u -0.12 :yaw 200))
  (:s :snap :hs-kr-sen-hit)
  (:a (:root :yaw 400) (:chest :twist 12))
  (25 (:root :yaw 380 :u -0.14) (:chest :twist 4) (:arms :flex 20 :side 50) (:elbows :flex 40))
  (:end :hs-st-kari (:root :yaw 360)))
;; AS2 交刈 KO-GARI (8/3/13, the slide 1.4; out of a J string, so from pointer 1's stance): the arms flung wide and low
;; behind him (the tell), then scissored in front, the two sickles let out low (0.6 m up) and reaped across each other at
;; his legs (*HS-LETOUT*'s sweeps: out -> in, the closing X, against TAN-GARI's opening one), a lunge
(defpose :hs-kr-ko-hit (:base :hs-s-stance)
  (:root :f 0.18 :u -0.22 :yaw 0) (:pelvis :twist 0) (:spine :flex 30) (:chest :twist 0) (:head :flex -12)
  (:arm-r :flex 60 :side 30 :twist 0) (:elbow-r :flex 6) (:hand-r :flex -80)
  (:arm-l :flex 60 :side 30 :twist 0) (:elbow-l :flex 6) (:hand-l :flex -80)
  (:thigh-l :flex 60 :side 12) (:knee-l :flex 64) (:thigh-r :flex -24 :side 14) (:knee-r :flex 30))
(defstrike :hs-kr-ko (8 3 13 :base :hs-s-stance)
  (0)
  (4 (:root :u -0.16 :f -0.04) (:spine :flex 18) (:chest :twist 0)
     (:arm-r :flex -40 :side 64 :twist 0) (:elbow-r :flex 10) (:hand-r :flex -90)
     (:arm-l :flex -40 :side 64 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -90) (:knees :flex 40))   ; wide and low behind
  (:s :snap :hs-kr-ko-hit)
  (:a (:root :f 0.22) (:arm-r :flex 74 :side -6) (:arm-l :flex 74 :side -6))                           ; crossed
  (19 (:root :f 0.1 :u -0.16) (:spine :flex 18) (:arms :flex 20 :side 34) (:elbows :flex 80) (:hands :flex 90))
  (:end :hs-st-kari))
;; AS2b 刈上 KARI-AGE (9/3/18, the launch): sunk to a squat, both sickles low before his feet (the tell), then the rising
;; reap: up onto his toes, both arms heaved from low to overhead, the two sickles let out to 2.4 m, hooked in at his chest
;; (*HS-LETOUT*, 1.5 m up) and reeled back up to the raised fists as he is launched
(defpose :hs-kr-age-hit (:base :hs-st-kari)
  (:root :f 0.12 :u -0.04) (:pelvis :twist 0) (:spine :flex 2) (:chest :twist 0) (:head :flex 6)
  (:arm-r :flex 92 :side 14 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -90)
  (:arm-l :flex 92 :side 14 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -90)
  (:thigh-l :flex 24 :side 8) (:knee-l :flex 14) (:thigh-r :flex -14 :side 10) (:knee-r :flex 10))
(defstrike :hs-kr-age (9 3 18 :base :hs-st-kari)
  (0 :hs-kr-ko-hit (:arm-r :flex 74 :side -6) (:arm-l :flex 74 :side -6))
  (4 (:root :u -0.3 :f 0.02) (:spine :flex 40) (:head :flex -10)
     (:arm-r :flex 30 :side 12 :twist 0) (:elbow-r :flex 6) (:hand-r :flex -10)
     (:arm-l :flex 30 :side 12 :twist 0) (:elbow-l :flex 6) (:hand-l :flex -10)
     (:thighs :flex 70) (:knees :flex 96))                                                              ; the squat (the blades along the floor)
  (7 (:root :u -0.31) (:spine :flex 42) (:arms :flex 26) (:thighs :flex 72) (:knees :flex 98))           ; held
  (:s :snap :hs-kr-age-hit)
  (:a (:root :u 0.04) (:spine :flex -10) (:head :flex 12) (:arms :flex 160 :side 18))                  ; overhead
  (22 (:root :u -0.1) (:spine :flex 6) (:arms :flex 90 :side 30) (:elbows :flex 50))
  (:end :hs-st-kari))

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

;; AS1 旋風 TSUMUJI (14/16/20, §27.10; the user, 2026-10-29: 「投擲出水平旋轉的鐮刀造成多段切割攻擊的同時，後跳到 NS1 的攻擊範圍」;
;; presentation only, the sim's HS-AS1-HOP carries him back, so no :root :f): a short dip with the left arm wound back and
;; out at shoulder height (f2), whipped flat across his front as he springs back off both feet (the sidearm release, f5:
;; the sickle leaves spinning flat, *HS-FOE-PATHS*), the follow-through across his chest at the top of the leap (f8,
;; tucked, leant back), the legs reaching down (f11), landed and sunk (f13); from S the left fist held out on the taut
;; chain, jerked in a small circle once per cut (f14 / 18 / 22 / 26) to keep the sickle spinning round the victim; the
;; haul back to his chest (f34) and the catch (f38). The right rod stays low behind his right hip from f10 to f34 (the
;; engine's swing smear on it: CHIKUDEN's note)
(defpose :hs-tsumuji-hit (:base :hs-s-stance)
  (:root :u -0.2 :yaw -6) (:pelvis :twist 0) (:spine :flex 12) (:chest :twist -10) (:head :flex 4)
  (:arm-l :flex 84 :side 20 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -10)
  (:arm-r :flex -24 :side 30 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -90)
  (:thigh-l :flex 44 :side 10) (:knee-l :flex 50) (:thigh-r :flex -16 :side 12) (:knee-r :flex 36))
(defstrike :hs-tsumuji (14 16 20 :base :hs-s-stance)
  (0)
  (2 (:root :u -0.22 :yaw 34) (:chest :twist 36) (:spine :flex 10) (:neck :twist -20)
     (:arm-l :flex -60 :side 80 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -30)
     (:arm-r :flex 20 :side 30) (:elbow-r :flex 40) (:thighs :flex 50) (:knees :flex 70))                 ; wound, the dip
  (5 (:root :u 0.15 :yaw -10) (:chest :twist -20) (:spine :flex -8) (:neck :twist 0)
     (:arm-l :flex 86 :side 34 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -20)
     (:arm-r :flex -30 :side 30) (:elbow-r :flex 30) (:thighs :flex 10) (:knees :flex 10))                 ; the release, sprung
  (8 (:root :u 0.5 :yaw -20) (:chest :twist -30) (:spine :flex -12) (:head :flex 6)
     (:arm-l :flex 108 :side -10) (:elbow-l :flex 6) (:arm-r :flex -40 :side 30) (:elbow-r :flex 30)
     (:thighs :flex 60) (:knees :flex 90))                                                                 ; the top, tucked
  (11 (:root :u 0.25 :yaw -12) (:chest :twist -16) (:spine :flex -4) (:arm-l :flex 84 :side 20) (:elbow-l :flex 10)
      (:arm-r :flex -24 :side 30) (:elbow-r :flex 30) (:hand-r :flex -90) (:thighs :flex 30) (:knees :flex 30))   ; reaching down
  (13 :hs-tsumuji-hit (:root :u -0.26) (:spine :flex 16) (:thigh-l :flex 50) (:knee-l :flex 70) (:knee-r :flex 60))   ; landed
  (:s :snap :hs-tsumuji-hit)
  (16 :hs-tsumuji-hit (:arm-l :flex 74 :side 32) (:elbow-l :flex 16))                                     ; the chain worked:
  (18 :hs-tsumuji-hit (:arm-l :flex 90 :side 12))                                                         ;  a jerk a cut
  (20 :hs-tsumuji-hit (:arm-l :flex 74 :side 32) (:elbow-l :flex 16))
  (22 :hs-tsumuji-hit (:arm-l :flex 90 :side 12))
  (24 :hs-tsumuji-hit (:arm-l :flex 74 :side 32) (:elbow-l :flex 16))
  (26 :hs-tsumuji-hit (:arm-l :flex 90 :side 12))
  (:a :hs-tsumuji-hit)
  (34 :hs-tsumuji-hit (:root :u -0.1) (:spine :flex -6) (:chest :twist 10)
      (:arm-l :flex 40 :side 20) (:elbow-l :flex 90) (:hand-l :flex -40))                                 ; hauled back
  (38 (:root :u -0.07) (:spine :flex 4) (:arm-l :flex 20 :side 24) (:elbow-l :flex 60) (:arm-r :flex 0 :side 22)
      (:elbow-r :flex 30))                                                                                ; caught
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

;; §28.19 (batch 4a; the user, 2026-10-29: 「『聚』跟『散』的 J1-J5 單從鎖鏈的揮舞來看完全看不出每段之間的差異，請將鎖鏈的攻擊設計
;; 出更加多樣有特色的動畫」; §28.18's 散 rows: 「散可以」): each spread link its own chain PATH, count and rhythm (J1, the right
;; crescent's flat crack R -> L at the chest, kept): J2 the scissor (two chains crossed in an X), J3 the floor snake (slither,
;; rear up), J4 the overhead whirl flung straight, J5 the drill (six chains twisted into one corkscrew bored ahead). Each at
;; its move's S (speed 1, `:clip-s` = S), frame 0 the previous link's last key, the windup held inside the startup. J2's
;; two crescents are let out from both hands (*HS-LETOUT*, their trails *HS-LO-TRAILS*); J3-J5 strike with hanging-chain
;; lashes (*HS-LASHES*); every free end on the band's far edge (6.0 m) inside +-50 on the hit frames; shaped by *HS-WAVES*
;; (the snake's S, the drill's helix), each path's trail its own (%HS-TRAIL).
;; J2 鋏鞭 HASAMI-BEN (10/3/13): out of J1's follow-through both arms flung up wide and high, arched (the scissor open, held
;; f4-8); on S both slashed down and across, the wrists crossed low in front (the X), then parted out low to his sides:
;; both crescents let out on their hand chains (*HS-LETOUT*), swept in from high on both sides and falling as they cross the
;; front (1.8 -> 0.5 m up, -+25 -> +-25 deg on f10-13): two descending diagonals crossed at him on f11.5, each point's trail
;; an ink stroke (*HS-LO-TRAILS*: the X)
(defpose :hs-k-kaeshi-up (:base :hs-k-stance)
  (:root :u 0.02 :f -0.06) (:spine :flex -12) (:chest :twist 0) (:neck :twist 0) (:head :flex -6)
  (:arm-r :flex 150 :side 64 :twist 0) (:elbow-r :flex 24) (:hand-r :flex -60)
  (:arm-l :flex 150 :side 64 :twist 0) (:elbow-l :flex 24) (:hand-l :flex -60)
  (:thigh-l :flex 10 :side 9) (:knee-l :flex 10) (:thigh-r :flex -8 :side 9) (:knee-r :flex 8))
(defpose :hs-k-kaeshi-hit (:base :hs-k-stance)
  (:root :f 0.12 :u -0.16) (:spine :flex 20) (:chest :twist 0) (:head :flex 4)
  (:arm-r :flex 58 :side -34 :twist 0) (:elbow-r :flex 8) (:hand-r :flex -90)
  (:arm-l :flex 50 :side -42 :twist 0) (:elbow-l :flex 8) (:hand-l :flex -90)
  (:thigh-l :flex 40 :side 9) (:knee-l :flex 44) (:thigh-r :flex -22 :side 10) (:knee-r :flex 24))
(defstrike :hs-k-kaeshi (10 3 13 :base :hs-k-stance)
  (0 :hs-k-saben-hit (:root :yaw 22 :u -0.1) (:chest :twist 30) (:arm-r :flex 114 :side 78) (:elbow-r :flex 12))   ; (J1's end)
  (4 :hs-k-kaeshi-up)
  (8 :hs-k-kaeshi-up (:root :u 0.04) (:spine :flex -16) (:arm-r :flex 158 :side 70) (:arm-l :flex 158 :side 70))   ; held, wider
  (:s :snap :hs-k-kaeshi-hit)
  (:a :hs-k-kaeshi-hit (:root :u -0.2) (:arm-r :flex 34 :side -20) (:arm-l :flex 28 :side -26))          ; through, low
  (19 :hs-k-kaeshi-hit (:root :u -0.12) (:spine :flex 12) (:arm-r :flex 22 :side 54) (:elbow-r :flex 20)   ; parted out low
      (:arm-l :flex 22 :side 54) (:elbow-l :flex 20))
  (:end :hs-k-stance))

;; J3 蛇鞭 JABEN (10/3/13): the floor snake: out of J2's parting he sinks deep, bent over, the left arm reaching forward low
;; over the floor, his body weaving with the chain (f3-8, held deepest on f8); on S the arm whipped up through in front and on
;; overhead as he rises: hanging chain 0 sent along the floor at him (its end crawling 1.8 -> 5.3 m, a lateral S travelling
;; down it, f2-9), reared up into him from below on S (0.08 -> 1.3 m up in a frame: its trail a vertical ribbon; a vertical
;; S along it), climbing to 2.3 m through the hit frames
(defpose :hs-k-na3-up (:base :hs-k-stance)
  (:root :u -0.28 :f 0.04 :yaw 18) (:pelvis :twist 6) (:spine :flex 34) (:chest :twist 16) (:neck :twist -10) (:head :flex -18)
  (:arm-l :flex 38 :side 14 :twist 0) (:elbow-l :flex 8) (:hand-l :flex -40)
  (:arm-r :flex -30 :side 34 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -70)
  (:thigh-l :flex 52 :side 10) (:knee-l :flex 62) (:thigh-r :flex -10 :side 12) (:knee-r :flex 40))
(defpose :hs-k-na3-hit (:base :hs-k-stance)
  (:root :f 0.12 :u -0.06 :yaw -10) (:pelvis :twist -4) (:spine :flex -4) (:chest :twist -20) (:head :flex -6)
  (:arm-l :flex 84 :side 18 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -100)
  (:arm-r :flex -30 :side 34 :twist 0) (:elbow-r :flex 40) (:hand-r :flex -70)
  (:thigh-r :flex 36 :side 8) (:knee-r :flex 30) (:thigh-l :flex -22 :side 10) (:knee-l :flex 12))
(defstrike :hs-k-na3 (10 3 13 :base :hs-k-stance)
  (0 :hs-k-kaeshi-hit (:root :u -0.12) (:spine :flex 12) (:arm-r :flex 22 :side 54) (:elbow-r :flex 20)   ; (J2's end)
     (:arm-l :flex 22 :side 54) (:elbow-l :flex 20))
  (3 :hs-k-na3-up)
  (6 :hs-k-na3-up (:root :yaw 6 :f 0.08) (:chest :twist 2) (:arm-l :flex 34 :side 4))                    ; weaving
  (8 :hs-k-na3-up (:root :u -0.32 :yaw 20) (:chest :twist 20) (:arm-l :flex 30 :side 16))                 ; held, deepest
  (:s :snap :hs-k-na3-hit)
  (:a :hs-k-na3-hit (:root :u 0.0 :yaw -16) (:spine :flex -14) (:arm-l :flex 150 :side 22))              ; through, rising
  (20 :hs-k-na3-hit (:root :u -0.06 :yaw -12) (:spine :flex -8) (:arm-l :flex 132 :side 24) (:elbow-l :flex 20))
  (:end :hs-k-stance))

;; J4 旋投 SENTŌ (10/3/13): the overhead whirl and the fling (motion-refs R3 -> R2): out of J3's rise the right arm goes up,
;; the fist circling over his head (a key every 2 f), the body still beneath it, the left hand low; cocked behind his head
;; on f9, on S thrown down the line, the weight onto the front foot: hanging chain 7 whirled flat round over his head, 1.5
;; turns (1.5 m round, 2.8 m up, 77 deg a frame, f2-9; its trail a disc; two turns would be 103 deg a frame inside the 10 f
;; startup, past a key every 90 deg), its last turn ending ahead of him and released straight at him (f9 -> f10: a straight
;; speed line, bowed by the lag), taut through the hit frames (6.0 m, 1.35 -> 1.1 m up)
(defpose :hs-k-na4-up (:base :hs-k-stance)
  (:root :u -0.06) (:pelvis :twist -4) (:spine :flex -4) (:chest :twist -6) (:neck :twist 6) (:head :flex -10)
  (:arm-r :flex 168 :side 14 :twist 0) (:elbow-r :flex 34) (:hand-r :flex -40)
  (:arm-l :flex 10 :side 36 :twist 0) (:elbow-l :flex 30) (:hand-l :flex -70)
  (:thigh-l :flex 12 :side 10) (:knee-l :flex 18) (:thigh-r :flex -10 :side 12) (:knee-r :flex 14))
(defpose :hs-k-na4-hit (:base :hs-k-stance)
  (:root :f 0.18 :u -0.12 :yaw 8) (:pelvis :twist 4) (:spine :flex 18) (:chest :twist 14) (:head :flex 0)
  (:arm-r :flex 86 :side 10 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex -40 :side 30 :twist 0) (:elbow-l :flex 30) (:hand-l :flex -70)
  (:thigh-l :flex 44 :side 8) (:knee-l :flex 40) (:thigh-r :flex -28 :side 10) (:knee-r :flex 14))
(defstrike :hs-k-na4 (10 3 13 :base :hs-k-stance)
  (0 :hs-k-na3-hit (:root :u -0.06 :yaw -12) (:spine :flex -8) (:arm-l :flex 132 :side 24) (:elbow-l :flex 20))   ; (J3's end)
  (2 :hs-k-na4-up)
  (4 :hs-k-na4-up (:arm-r :flex 160 :side 32) (:elbow-r :flex 44))                                        ; the fist circling
  (6 :hs-k-na4-up (:arm-r :flex 172 :side 2) (:elbow-r :flex 26))                                         ;  over his head
  (8 :hs-k-na4-up (:arm-r :flex 162 :side 30) (:elbow-r :flex 42))
  (9 :hs-k-na4-up (:root :yaw 14) (:chest :twist 16) (:arm-r :flex 178 :side 24) (:elbow-r :flex 78))    ; cocked
  (:s :snap :hs-k-na4-hit)
  (:a :hs-k-na4-hit (:root :f 0.22 :u -0.16) (:spine :flex 22) (:arm-r :flex 70))                         ; through, down
  (20 :hs-k-na4-hit (:root :f 0.12 :u -0.1) (:spine :flex 12) (:arm-r :flex 60 :side 16) (:elbow-r :flex 14))
  (:end :hs-k-stance))

;; J5 旋鎖 SENSA (10/3/18; the ender, its push): the drill: out of J4's throw both fists drawn in together before his chest
;; and wound (a crank: turned to his right, sunk, the fists turning over each other, f3-8, held); on S both arms driven
;; straight out along the line together, lunging, held through the bore and the push, then pulled back: six hanging chains
;; (0 1 2 5 6 7) gathered in before his chest and twisted round each other (*HS-WAVES*: six helices turning, a cone
;; tapering to the point), bored straight out to 6.0 m on S (f9 -> f10: six speed lines), held turning through the hit
;; frames and the push (f10-16), unwound back to the curtain
(defpose :hs-k-sensa-up (:base :hs-k-stance)
  (:root :u -0.2 :f -0.06 :yaw -26) (:pelvis :twist -8) (:spine :flex 14) (:chest :twist -24) (:neck :twist 20) (:head :flex 0)
  (:arm-r :flex 46 :side -10 :twist 0) (:elbow-r :flex 112) (:hand-r :flex -40)
  (:arm-l :flex 52 :side -16 :twist 0) (:elbow-l :flex 104) (:hand-l :flex -40)
  (:thigh-l :flex 40 :side 10) (:knee-l :flex 48) (:thigh-r :flex -8 :side 12) (:knee-r :flex 40))
(defpose :hs-k-sensa-hit (:base :hs-k-stance)
  (:root :f 0.24 :u -0.12 :yaw 0) (:pelvis :twist 0) (:spine :flex 16) (:chest :twist 0) (:head :flex 0)
  (:arm-r :flex 88 :side -6 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex 88 :side -6 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -90)
  (:thigh-l :flex 48 :side 8) (:knee-l :flex 42) (:thigh-r :flex -30 :side 10) (:knee-r :flex 12))
(defstrike :hs-k-sensa (10 3 18 :base :hs-k-stance)
  (0 :hs-k-na4-hit (:root :f 0.12 :u -0.1) (:spine :flex 12) (:arm-r :flex 60 :side 16) (:elbow-r :flex 14))   ; (J4's end)
  (3 :hs-k-sensa-up)
  (6 :hs-k-sensa-up (:root :yaw -32) (:chest :twist -30) (:arm-r :flex 40) (:arm-l :flex 58))            ; the crank turning
  (8 :hs-k-sensa-up (:root :u -0.24 :yaw -36) (:chest :twist -34) (:arm-r :flex 52) (:arm-l :flex 46))   ; held, wound
  (:s :snap :hs-k-sensa-hit)
  (:a :hs-k-sensa-hit (:root :f 0.28))                                                                    ; the bore
  (19 :hs-k-sensa-hit (:root :f 0.2 :u -0.1) (:arm-r :flex 80) (:arm-l :flex 80))                        ; held: the push
  (24 :hs-k-sensa-hit (:root :f 0.08 :u -0.06) (:arm-r :flex 40 :side 14) (:elbow-r :flex 50) (:arm-l :flex 40 :side 14)
      (:elbow-l :flex 50))
  (:end :hs-k-stance))

;; (B3b's K1 墜鎖 TSUISA, K2 薙鎖 NAGISA and K3 落鎖 RAKUSA clips: no move's since B4a's placed K and B4c's routes; deleted
;; by batch A2, §24.2, when the route links got their own clips)

;; L 鎖払 SAHARAI (18/4/32, r 3.0 360; redrawn by batch A3, §24.3, for B4d's S 10 / R 32; the windup redrawn for S 18,
;; §25.7, 「把 L 的前搖加長，並把前搖時蓄力的動作模組做的更容易辨識」): the wrap, the arms crossed tight over his chest, curled
;; (f4); the charge: he sinks lower and curls tighter while the orb spins up two full turns and the curtain whirls ever
;; faster round his body (f4-16, *HS-SPINS*, *HS-LASHES*), a beat's rise on f16-17; the burst: the arms flung wide, arched,
;; every hanging chain lashed out to 3 m in a ring, held to f26 as they fall to the floor; the recovery: both fists hauled
;; in to his chest, leaning back, the chains dragged in along the floor and lifted back into the curtain (f34-52), him
;; settling into the stance
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
(defstrike :hs-k-saharai (18 4 32 :base :hs-k-stance)
  (0)
  (4 :hs-k-saharai-up)                                                                     ; the wrap
  (9 :hs-k-saharai-up (:root :u -0.3) (:spine :flex 34) (:head :flex 24) (:chest :twist -8))   ; the charge: sinking,
  (13 :hs-k-saharai-up (:root :u -0.36) (:spine :flex 42) (:head :flex 28) (:chest :twist 8)   ;  curling tighter, a
      (:elbow-r :flex 132) (:elbow-l :flex 132) (:thighs :flex 52 :side 10) (:knees :flex 72))   ;  shudder side to side
  (16 :hs-k-saharai-up (:root :u -0.38) (:spine :flex 44) (:head :flex 30) (:chest :twist -6)
      (:elbow-r :flex 136) (:elbow-l :flex 136) (:thighs :flex 56 :side 10) (:knees :flex 78))   ; coiled full (held)
  (17 :hs-k-saharai-up (:root :u -0.3) (:spine :flex 36) (:head :flex 22))                  ; the beat's rise
  (:s :snap :hs-k-saharai-hit)
  (20 :hs-k-saharai-hit (:spine :flex -18) (:arm-r :flex -10 :side 104) (:arm-l :flex -10 :side 104))
  (:a :hs-k-saharai-hit (:spine :flex -16) (:arm-r :flex -8 :side 100) (:arm-l :flex -8 :side 100))
  (26 :hs-k-saharai-hit (:spine :flex -14) (:arm-r :flex -4 :side 96) (:arm-l :flex -4 :side 96))   ; the impact hold
  (34 :hs-k-saharai-haul)                                                                   ; hauled in
  (40 :hs-k-saharai-haul (:root :u -0.12 :f -0.1) (:spine :flex -14) (:elbow-r :flex 112) (:elbow-l :flex 112))
  (46 :hs-k-stance (:root :u -0.08) (:spine :flex 2) (:elbows :flex 50))                    ; settling
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
;; K1 綁束 HOSOKU (16/4/22, the annulus 2.0-5.0 m, 360 deg, §25.5; the gathered opener): the stir: the right arm up over his head
;; circling (a key every 3 f: the orb winding, the curtain drawn in and up round him), coiled to his right on the back foot
;; (held f6-14); the fling on S: unwound to his left with the spin, the arms flung wide, every hanging chain whirled out to
;; 5.0 m round him (a key each 90 deg, f16-19); the haul: his fists brought in, the chains wound in and bound into one
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

;; spread K2 散鞭 (21/4/24, link f6; a 60 deg fan to 5.0 m, §25.5): the whip-crack: the right arm swung up and far back over his
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

;; spread K3 散撃 (21/5/34, link f6; a 160 deg fan to 5.0 m, §25.5; ender): the curtain drawn back: both arms flung back and wide,
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

;; gathered K2 束打 SOKUDA (27/10/24, link f6; hit 1 f27 and hit 2 f33 on 2.0-5.0 m, §25.5): the heave: both fists up
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

;; gathered K3 束旋 SOKUSEN (27/5/34, link f6; the annulus 2.0-5.0 m, 360 deg, §25.5; ender): the haul: leaning back, the bundle
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
;; §28.15: the gathered J3 / J4's own (J2s the right fist's straight lash, J5 both arms' flat sweep R -> L; the gathered SA
;; the right underhand flick): the bundle at 4.5 m on the hit frames, inside +-45.
;; gathered J3 束昇 SOKUSHŌ (19/3/16): the left backhand rising diagonal: turned to his right, sunk, the left hand reached
;; across down to the bundle by his right knee, the right fist drawn back low (held f12-17); on S ripped up and across to
;; his upper left as he unwinds: the bundle from low at his right front up through the line to high at his left
;; (-30 -> +35 deg, 0.5 -> 2.3 m up)
(defpose :hs-k-gna3-up (:base :hs-k-stance)
  (:root :u -0.32 :yaw -40) (:pelvis :twist -12) (:spine :flex 30) (:chest :twist -42) (:neck :twist 30) (:head :flex 4)
  (:arm-l :flex 56 :side -42 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -80)
  (:arm-r :flex -34 :side 30 :twist 0) (:elbow-r :flex 50) (:hand-r :flex -60)
  (:thigh-r :flex 46 :side 12) (:knee-r :flex 64) (:thigh-l :flex 4 :side 16) (:knee-l :flex 54))
(defpose :hs-k-gna3-hit (:base :hs-k-stance)
  (:root :f 0.12 :u -0.12 :yaw 14) (:pelvis :twist 6) (:spine :flex 4) (:chest :twist 26) (:head :flex -6)
  (:arm-l :flex 118 :side 52 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -90)
  (:arm-r :flex -20 :side 30 :twist 0) (:elbow-r :flex 50) (:hand-r :flex -60)
  (:thigh-l :flex 40 :side 10) (:knee-l :flex 36) (:thigh-r :flex -24 :side 12) (:knee-r :flex 18))
(defstrike :hs-k-g-na3 (19 3 16 :base :hs-k-stance)
  (0 :hs-k-gj2-hit (:root :f 0.22 :u -0.14) (:arm-r :flex 80))
  (6 :hs-k-stance (:root :u -0.12) (:spine :flex 10))
  (12 :hs-k-gna3-up)
  (17 :hs-k-gna3-up (:root :u -0.36 :yaw -46) (:chest :twist -48) (:arm-l :side -48))                 ; held, deeper
  (:s :snap :hs-k-gna3-hit)
  (:a :hs-k-gna3-hit (:root :u -0.04 :yaw 22) (:spine :flex -10) (:chest :twist 32) (:arm-l :flex 150 :side 60))   ; through, up
  (30 :hs-k-gna3-hit (:root :u -0.1 :yaw 18) (:spine :flex -4) (:arm-l :flex 130 :side 56) (:elbow-l :flex 20))
  (:end :hs-k-stance))
;; gathered J4 束落 SOKURAKU (19/3/16): the right overhead chop: the right arm raised straight up and back, risen and arched,
;; the left hand pointing at him, the bundle hauled up high behind him (held f12-17); on S chopped straight down over his
;; head into a deep squat: the bundle over the top and cracked down on the line (1.6 -> 0.1 m up at 4.5 m, -4 .. 0 deg)
(defpose :hs-k-gna4-up (:base :hs-k-stance)
  (:root :u 0.0 :f -0.08 :yaw -10) (:spine :flex -24) (:chest :twist -10) (:head :flex -16)
  (:arm-r :flex 176 :side 8 :twist 0) (:elbow-r :flex 34) (:hand-r :flex -40)
  (:arm-l :flex 44 :side 8 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -70)
  (:thigh-l :flex 16 :side 8) (:knee-l :flex 8) (:thigh-r :flex -12 :side 8) (:knee-r :flex 10))
(defpose :hs-k-gna4-hit (:base :hs-k-stance)
  (:root :f 0.16 :u -0.38 :yaw 6) (:spine :flex 42) (:chest :twist 8) (:head :flex -10)
  (:arm-r :flex 62 :side 10 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex -20 :side 36 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -60)
  (:thigh-l :flex 60 :side 12) (:knee-l :flex 76) (:thigh-r :flex -10 :side 14) (:knee-r :flex 60))
(defstrike :hs-k-g-na4 (19 3 16 :base :hs-k-stance)
  (0 :hs-k-gna3-hit (:root :u -0.1 :yaw 18) (:spine :flex -4) (:arm-l :flex 130 :side 56) (:elbow-l :flex 20))
  (6 :hs-k-stance (:root :u -0.06))
  (12 :hs-k-gna4-up)
  (17 :hs-k-gna4-up (:spine :flex -30) (:head :flex -20) (:arm-r :flex 186))                          ; held at the top
  (:s :snap :hs-k-gna4-hit)
  (21 :hs-k-gna4-hit (:root :u -0.42) (:spine :flex 46) (:arm-r :flex 50))                            ; the impact hold
  (:a :hs-k-gna4-hit (:root :u -0.4) (:spine :flex 44))
  (30 :hs-k-stance (:root :u -0.18) (:spine :flex 16))
  (:end :hs-k-stance))

;;; Batch 2a (DUEL_HISAGI §28.9 / §28.11, the user's 「可以」 on the plan): the core ranged mode's own clips, each at its move's
;;; frames (the moves' :clip-s their S, speed 1; the first :enter frames never shown), the windups big and held inside the
;;; startups (「記得動作要配合誇張而明顯的前搖」), the drawn tips on the bands' far edges (§28.7: 散 6.0 m, 聚 4.5 m; the close pushes
;;; 3.0 m) on the hit frames (*HS-LASHES*, *HS-BK-CHAINS*). Planes and hands, so no two strikes share both: OGI the right arm
;;; overhead (vertical), ISSEI both arms swept in from behind (level, converging), RANSA a right then a left oblique and both
;;; arms scissored down and out, UCHI a right underhand flick (rising), TATAKI the left arm's vertical wheel at his left
;;; (one hand; TABA is both fists over the right shoulder), the AS2a sweep the right backhand along the floor L -> R (the left
;;; hand planted), JIBASHIRI both fists driven straight down in a kneel, MAKI both hands reeling, KAKE the heave over the
;;; right shoulder, turned away.
;; 聚 stance (pointer 2): sunk, turned to his right, the hanging chains bound into one bundle (*HS-BUNDLED*) run down his
;; right side, the right fist low on it at his hip, the left crossed over gripping it higher (散's stance: upright, the arms
;; hanging, the eight chains loose round him)
(defpose :hs-k-st-shu (:base :hs-k-stance)
  (:root :u -0.16 :yaw -18) (:pelvis :twist -8) (:spine :flex 14) (:chest :twist -14) (:neck :twist 14) (:head :flex 2)
  (:arm-r :flex 22 :side 30 :twist 0) (:elbow-r :flex 44) (:hand-r :flex -60)
  (:arm-l :flex 56 :side -20 :twist 0) (:elbow-l :flex 96) (:hand-l :flex -40)
  (:thigh-l :flex 30 :side 10) (:knee-l :flex 36) (:thigh-r :flex -10 :side 12) (:knee-r :flex 30))
(defclip :hs-k-st-shu (2.0 :loop t :base :hs-k-st-shu)
  (0) (1.0 (:root :u -0.18) (:chest :twist -16) (:spine :flex 15)))
;; SA 打 UCHI (10/3/13; spread 3-6 m 100 deg, the gathered copy 2.5-4.5 m 90 deg at S 13, the same clip at 10/13): the
;; quick flick: the right fist dropped back low by his hip, a dip (f3-8); on S the wrist flicked up and out, the nearest
;; hanging chain (the gathered: the bundle, keyed on the move) snapped out along the line
(defpose :hs-k-uchi-up (:base :hs-k-stance)
  (:root :u -0.12 :f -0.04 :yaw -14) (:spine :flex 10) (:chest :twist -22) (:neck :twist 14)
  (:arm-r :flex -40 :side 30 :twist 0) (:elbow-r :flex 70) (:hand-r :flex -30)
  (:arm-l :flex 30 :side 20 :twist 0) (:elbow-l :flex 50) (:hand-l :flex -60)
  (:thigh-r :flex -16 :side 8) (:knee-r :flex 30) (:thigh-l :flex 24 :side 8) (:knee-l :flex 20))
(defpose :hs-k-uchi-hit (:base :hs-k-stance)
  (:root :f 0.12 :u -0.1 :yaw 10) (:spine :flex 12) (:chest :twist 16) (:head :flex 0)
  (:arm-r :flex 76 :side 18 :twist 0) (:elbow-r :flex 6) (:hand-r :flex -110)
  (:arm-l :flex -20 :side 26 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -70)
  (:thigh-l :flex 40 :side 8) (:knee-l :flex 36) (:thigh-r :flex -24 :side 10) (:knee-r :flex 14))
(defstrike :hs-k-uchi (10 3 13 :base :hs-k-stance)
  (0)
  (4 :hs-k-uchi-up)
  (8 :hs-k-uchi-up (:root :u -0.14 :yaw -18) (:arm-r :flex -46) (:elbow-r :flex 76))              ; held at the bottom
  (:s :snap :hs-k-uchi-hit)
  (:a :hs-k-uchi-hit (:arm-r :flex 98) (:hand-r :flex -80))                                        ; through, rising
  (20 :hs-k-uchi-hit (:root :f 0.1) (:arm-r :flex 90) (:elbow-r :flex 20))
  (:end :hs-k-stance))
;; NS1b 扇 OGI (21/4/24, link f4; 3-6 m, 60 deg): out of WA's haul (its clip's end, f4), the whip-crack: the right arm swung up
;; and far back over his shoulder, arched, coiled to his right, the left hand pointing (held f10-18), four hanging chains
;; hauled up high behind him; cracked down on S over the front knee, the four whipping the ground in a 60 deg fan at 6.0 m
(defstrike :hs-k-ogi (21 4 24 :base :hs-k-stance)
  (0 :hs-k-stance (:root :u -0.08) (:spine :flex 2) (:elbows :flex 50))
  (4 :hs-k-stance (:root :u -0.08) (:spine :flex 2) (:elbows :flex 50))
  (10 :hs-k-sk2-up)
  (18 :hs-k-sk2-up (:root :yaw -26) (:spine :flex -26) (:arm-r :flex 168 :side 38))                     ; held
  (:s :snap :hs-k-sk2-hit)
  (:a :hs-k-sk2-hit (:root :u -0.3) (:spine :flex 40) (:arm-r :flex 56))
  (32 :hs-k-sk2-hit (:root :u -0.28) (:spine :flex 38) (:arm-r :flex 58))
  (:end :hs-k-stance))
;; NS1c 一斉 ISSEI (21/5/34, link f7; 3-6 m, 160 deg, knockdown): the curtain drawn back: both arms flung back and wide, the
;; chest thrown out, arched, all eight hanging chains hauled back high behind him (held f11-19); on S both arms swept in and
;; forward together, a lunge onto the front foot, the eight lashed forward in a 160 deg fan at 6.0 m, settling to the floor
(defstrike :hs-k-issei (21 5 34 :base :hs-k-stance)
  (0)
  (7 :hs-k-stance (:root :u -0.04))
  (11 :hs-k-sk3-up)
  (19 :hs-k-sk3-up (:spine :flex -30) (:arms :flex -60 :side 70))                                       ; held
  (:s :snap :hs-k-sk3-hit)
  (:a :hs-k-sk3-hit (:root :u -0.28) (:spine :flex 32) (:arms :flex 80 :side 60))
  (38 :hs-k-sk3-hit (:root :u -0.26) (:spine :flex 30) (:arms :flex 76 :side 58))
  (:end :hs-k-stance))
;; AS1 乱鎖 RANSA (21/5/34, f6 on; 3-6 m, 160 deg, knockdown): the tell: both arms crossed high over his head, arched back,
;; the hanging chains hauled up overhead (held f12-19); the flurry through the hit window: the right arm's oblique lash high
;; right to low left (S), the left's mirrored (f23), then both arms scissored down and out (f25), each its own chains at
;; 6.0 m in turn
(defpose :hs-k-ransa-up (:base :hs-k-stance)
  (:root :u -0.06 :f -0.1) (:spine :flex -20) (:chest :twist 0) (:head :flex -14)
  (:arm-r :flex 166 :side -22 :twist 0) (:elbow-r :flex 40) (:hand-r :flex -40)
  (:arm-l :flex 166 :side -22 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -40)
  (:thigh-l :flex 20 :side 10) (:knee-l :flex 14) (:thigh-r :flex -16 :side 10) (:knee-r :flex 22))
(defpose :hs-k-ransa-r (:base :hs-k-stance)
  (:root :f 0.12 :u -0.14 :yaw 16) (:spine :flex 22) (:chest :twist 26) (:head :flex -4)
  (:arm-r :flex 104 :side 44 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -90)
  (:arm-l :flex 140 :side 8 :twist 0) (:elbow-l :flex 60) (:hand-l :flex -40)
  (:thigh-l :flex 40 :side 8) (:knee-l :flex 40) (:thigh-r :flex -22 :side 10) (:knee-r :flex 16))
(defpose :hs-k-ransa-l (:base :hs-k-stance)
  (:root :f 0.14 :u -0.16 :yaw -16) (:spine :flex 24) (:chest :twist -26) (:head :flex -4)
  (:arm-l :flex 104 :side 44 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -90)
  (:arm-r :flex -30 :side 34 :twist 0) (:elbow-r :flex 40) (:hand-r :flex -70)
  (:thigh-r :flex 40 :side 8) (:knee-r :flex 40) (:thigh-l :flex -22 :side 10) (:knee-l :flex 16))
(defpose :hs-k-ransa-x (:base :hs-k-stance)
  (:root :f 0.2 :u -0.26) (:spine :flex 32) (:chest :twist 0) (:head :flex -8)
  (:arms :flex 62 :side 70) (:elbows :flex 2) (:hands :flex -90)
  (:thigh-l :flex 52 :side 12) (:knee-l :flex 54) (:thigh-r :flex -28 :side 12) (:knee-r :flex 16))
(defstrike :hs-k-ransa (21 5 34 :base :hs-k-stance)
  (0)
  (6 :hs-k-stance (:root :u -0.04))
  (12 :hs-k-ransa-up)
  (19 :hs-k-ransa-up (:spine :flex -26) (:head :flex -18) (:arm-r :flex 174) (:arm-l :flex 174))       ; held
  (:s :snap :hs-k-ransa-r)
  (22 :hs-k-ransa-r (:root :yaw 24) (:chest :twist 34) (:arm-r :flex 124 :side 30))                    ; through, to his left
  (23 :snap :hs-k-ransa-l)
  (24 :hs-k-ransa-l (:root :yaw -24) (:chest :twist -34) (:arm-l :flex 124 :side 30))
  (25 :snap :hs-k-ransa-x)
  (:a :hs-k-ransa-x (:root :u -0.28) (:spine :flex 36) (:arms :flex 56 :side 76))
  (38 :hs-k-ransa-x (:root :u -0.26) (:spine :flex 34) (:arms :flex 58 :side 74))
  (:end :hs-k-stance))
;; NS2b 叩 TATAKI (30/10/27, link f9; 0-3 m, 90 deg, the push): the left arm's wheel at his left: the bundle swung down and back
;; (f14), up and over his head as he rises on his toes, arched (f20-26, held), then brought over the top and smashed down
;; right in front at 3.0 m as he drops into a deep squat (S); the right fist stays at his chest
(defpose :hs-k-tataki-low (:base :hs-k-stance)
  (:root :u -0.14 :yaw 30) (:spine :flex 16) (:chest :twist 24) (:neck :twist -16) (:head :flex 6)
  (:arm-l :flex -52 :side 22 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -80)
  (:arm-r :flex 60 :side -10 :twist 0) (:elbow-r :flex 110) (:hand-r :flex -40)
  (:thigh-l :flex -16 :side 10) (:knee-l :flex 30) (:thigh-r :flex 30 :side 8) (:knee-r :flex 28))
(defpose :hs-k-tataki-up (:base :hs-k-stance)
  (:root :u 0.04 :f -0.06 :yaw 14) (:spine :flex -20) (:chest :twist 10) (:neck :twist -8) (:head :flex -16)
  (:arm-l :flex 176 :side 12 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -40)
  (:arm-r :flex 60 :side -10 :twist 0) (:elbow-r :flex 110) (:hand-r :flex -40)
  (:thigh-l :flex 14 :side 8) (:knee-l :flex 6) (:thigh-r :flex -14 :side 8) (:knee-r :flex 10))
(defpose :hs-k-tataki-hit (:base :hs-k-stance)
  (:root :f 0.16 :u -0.42 :yaw -4) (:spine :flex 46) (:chest :twist -8) (:head :flex -10)
  (:arm-l :flex 66 :side 6 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -80)
  (:arm-r :flex 40 :side 34 :twist 0) (:elbow-r :flex 90) (:hand-r :flex -40)
  (:thigh-l :flex 66 :side 14) (:knee-l :flex 84) (:thigh-r :flex -8 :side 16) (:knee-r :flex 64))
(defstrike :hs-k-tataki (30 10 27 :base :hs-k-stance)
  (0)
  (9 :hs-k-stance (:root :u -0.06))
  (14 :hs-k-tataki-low)
  (20 :hs-k-tataki-up)
  (26 :hs-k-tataki-up (:spine :flex -26) (:head :flex -20) (:arm-l :flex 190))                          ; held at the top
  (28 :hs-k-tataki-up (:root :u -0.04) (:spine :flex -6) (:arm-l :flex 130))                            ; over
  (:s :snap :hs-k-tataki-hit)
  (34 :hs-k-tataki-hit (:root :u -0.44) (:spine :flex 48) (:arm-l :flex 60))                            ; the impact hold
  (:a :hs-k-tataki-hit (:root :u -0.42) (:spine :flex 44))
  (52 :hs-k-stance (:root :u -0.16) (:spine :flex 14))
  (:end :hs-k-stance))
;; AS2a 叩 (30/10/27, f9 on; 2.5-4.5 m, 90 deg): the low backhand: wound to his left, crouched, the right fist across his body
;; by his left knee, the left hand down to the floor (held f22-28); on S unwound to his right, the right arm swept out low
;; and across, the bundle dragged flat along the floor L -> R through the 90 deg at 4.5 m (f30-33)
(defpose :hs-k-sweep-up (:base :hs-k-stance)
  (:root :u -0.34 :yaw 50) (:pelvis :twist 12) (:spine :flex 30) (:chest :twist 40) (:neck :twist -30) (:head :flex -4)
  (:arm-r :flex 60 :side -34 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -80)
  (:arm-l :flex 40 :side 40 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -60)
  (:thigh-l :flex 56 :side 14) (:knee-l :flex 76) (:thigh-r :flex 4 :side 18) (:knee-r :flex 62))
(defpose :hs-k-sweep-hit (:base :hs-k-stance)
  (:root :u -0.3 :f 0.06 :yaw 12) (:pelvis :twist 4) (:spine :flex 28) (:chest :twist 4) (:neck :twist -6) (:head :flex -4)
  (:arm-r :flex 112 :side 66 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -90)
  (:arm-l :flex 30 :side 46 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -60)
  (:thigh-l :flex 50 :side 14) (:knee-l :flex 64) (:thigh-r :flex 0 :side 18) (:knee-r :flex 56))
(defstrike :hs-k-sweep (30 10 27 :base :hs-k-stance)
  (0)
  (9 :hs-k-stance (:root :u -0.06))
  (16 :hs-k-sweep-up)
  (28 :hs-k-sweep-up (:root :u -0.38 :yaw 56) (:chest :twist 46))                                       ; held
  (:s :snap :hs-k-sweep-hit)
  (33 :hs-k-sweep-hit (:root :yaw -30) (:chest :twist -30) (:arm-r :flex 30 :side 80))                  ; through, to his right
  (:a :hs-k-sweep-hit (:root :yaw -36) (:chest :twist -34) (:arm-r :flex 20 :side 80))
  (54 :hs-k-stance (:root :u -0.14) (:spine :flex 12))
  (:end :hs-k-stance))
;; AS2b 地走 JIBASHIRI (hit 36/4/27, S 30, f12 on; a line to 4.5 m, knockdown): both fists heave the bundle up over his head,
;; risen, arched (held f24-31); driven straight down into the floor at his feet as he drops to one knee (f34), the bundle's
;; end run out along the floor to 4.5 m (S 36) with the crack (HISAGI-DRAW's %HS-CRACK), left lying, hauled back
(defpose :hs-k-jib-up (:base :hs-k-stance)
  (:root :u 0.02 :f -0.06) (:spine :flex -16) (:chest :twist 0) (:head :flex -12)
  (:arms :flex 170 :side 8) (:elbows :flex 30) (:hands :flex -40)
  (:thigh-l :flex 16 :side 8) (:knee-l :flex 8) (:thigh-r :flex -12 :side 8) (:knee-r :flex 10))
(defpose :hs-k-jib-hit (:base :hs-k-stance)
  (:root :f 0.12 :u -0.52) (:spine :flex 50) (:chest :twist 0) (:head :flex -14)
  (:arms :flex 48 :side 8) (:elbows :flex 4) (:hands :flex -90)
  (:thigh-l :flex 80 :side 10) (:knee-l :flex 96) (:thigh-r :flex -14 :side 12) (:knee-r :flex 104))
(defstrike :hs-k-jibashiri (36 4 27 :base :hs-k-stance)
  (0)
  (12 :hs-k-stance (:root :u -0.06))
  (24 :hs-k-jib-up)
  (31 :hs-k-jib-up (:spine :flex -22) (:arms :flex 178))                                                ; held
  (34 :snap :hs-k-jib-hit)                                                                              ; driven in
  (:s :hs-k-jib-hit (:root :u -0.54) (:spine :flex 52))
  (:a :hs-k-jib-hit (:root :u -0.52) (:spine :flex 50))
  (52 :hs-k-stance (:root :u -0.2) (:spine :flex 18))
  (:end :hs-k-stance))
;; AS3b 巻 MAKI (27/10/24, f12 on; the chain to him up to 7 m, HS-R-LINK-SEG): both hands reeling in front of his chest, a key
;; every 3 f (the wind-up); the chain cast at him and spiralled round him on S (two turns rising, two strands, a key every
;; 90 deg; *HS-LK-REACH*: drawn to where he is), held wound, let go in the recovery
(defpose :hs-k-maki-a (:base :hs-k-stance)
  (:root :u -0.16 :f 0.04) (:spine :flex 14) (:chest :twist -6) (:head :flex 0)
  (:arm-r :flex 80 :side 10 :twist 0) (:elbow-r :flex 60) (:hand-r :flex -60)
  (:arm-l :flex 50 :side 16 :twist 0) (:elbow-l :flex 104) (:hand-l :flex -30)
  (:thigh-l :flex 36 :side 10) (:knee-l :flex 36) (:thigh-r :flex -14 :side 12) (:knee-r :flex 26))
(defpose :hs-k-maki-b (:base :hs-k-maki-a)
  (:chest :twist 6) (:arm-r :flex 50 :side 16) (:elbow-r :flex 104) (:arm-l :flex 80 :side 10) (:elbow-l :flex 60))
(defstrike :hs-k-maki (27 10 24 :base :hs-k-stance)
  (0)
  (12 :hs-k-stance (:root :u -0.06))
  (15 :hs-k-maki-a) (18 :hs-k-maki-b) (21 :hs-k-maki-a) (24 :hs-k-maki-b (:root :u -0.2))
  (:s :hs-k-maki-a (:root :u -0.2 :f 0.08) (:arm-r :flex 92))
  (30 :hs-k-maki-b (:root :u -0.2 :f 0.08))
  (33 :hs-k-maki-a (:root :u -0.2 :f 0.08))
  (:a :hs-k-maki-b (:root :u -0.2 :f 0.06))
  (50 :hs-k-stance (:root :u -0.1))
  (:end :hs-k-stance))
;; AS3c 掛 KAKE (24/4/30, f8 on; the chain to him up to 7 m; a hit arms the bind): he turns away to his left, both fists up on
;; the neck bundle's tail at his right shoulder (f8-22); the heave on S: his back to the opponent, bent double into it, the
;; chain yanked taut over his right shoulder to him (hooked round his neck on a hit: *HS-BK-CHAINS* src 8), then turned back
(defpose :hs-k-kake-grip (:base :hs-k-stance)
  (:root :u -0.1 :yaw 60) (:spine :flex 4) (:chest :twist 40) (:neck :twist -40) (:head :flex 0)
  (:arm-r :flex 150 :side -12 :twist 0) (:elbow-r :flex 110) (:hand-r :flex -30)
  (:arm-l :flex 130 :side -40 :twist 0) (:elbow-l :flex 100) (:hand-l :flex -30)
  (:thigh-l :flex 20 :side 10) (:knee-l :flex 20) (:thigh-r :flex -10 :side 10) (:knee-r :flex 16))
(defpose :hs-k-kake-hit (:base :hs-k-stance)
  (:root :u -0.3 :yaw 150) (:spine :flex 50) (:chest :twist 16) (:neck :twist -10) (:head :flex 10)
  (:arm-r :flex 96 :side -4 :twist 0) (:elbow-r :flex 124) (:hand-r :flex -40)
  (:arm-l :flex 80 :side -30 :twist 0) (:elbow-l :flex 110) (:hand-l :flex -40)
  (:thigh-l :flex 54 :side 12) (:knee-l :flex 50) (:thigh-r :flex -20 :side 12) (:knee-r :flex 30))
(defstrike :hs-k-kake (24 4 30 :base :hs-k-stance)
  (0)
  (8 :hs-k-stance (:root :u -0.06))
  (16 :hs-k-kake-grip)
  (22 :hs-k-kake-grip (:root :yaw 76 :u -0.14) (:spine :flex -8) (:arm-r :flex 160) (:arm-l :flex 140))   ; held, coiled
  (:s :snap :hs-k-kake-hit)
  (:a :hs-k-kake-hit (:root :u -0.34) (:spine :flex 56))
  (38 :hs-k-kake-hit (:root :u -0.3 :yaw 140) (:spine :flex 48))
  (48 :hs-k-stance (:root :u -0.14 :yaw 40) (:spine :flex 16))
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

;; Step + J 穿弦 SENGEN (10/3/22, 2.2 m arc 60; §25.10): landing out of the hop he sinks low, the right crescent drawn
;; back by his right hip, the left arm forward to aim (held f4-8); the lunge, the right arm thrown straight at the victim, the
;; crescent let out on its chain to 2.2 m (*HS-LETOUT*), hauled back through the recovery
(defpose :hs-kb-sengen-up (:base :hs-k-stance)
  (:root :u -0.2 :f -0.06 :yaw -24) (:spine :flex 18) (:chest :twist -30) (:neck :twist 18) (:head :flex 4)
  (:arm-r :flex -40 :side 30 :twist 0) (:elbow-r :flex 80) (:hand-r :flex -60)
  (:arm-l :flex 80 :side 10 :twist 0) (:elbow-l :flex 20) (:hand-l :flex -40)
  (:thigh-r :flex -24 :side 10) (:knee-r :flex 50) (:thigh-l :flex 44 :side 8) (:knee-l :flex 56))
(defpose :hs-kb-sengen-hit (:base :hs-k-stance)
  (:root :f 0.16 :u -0.14 :yaw 14) (:spine :flex 14) (:chest :twist 22) (:head :flex 0)
  (:arm-r :flex 88 :side 6 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90 :twist 0)
  (:arm-l :flex 10 :side 40 :twist 0) (:elbow-l :flex 50) (:hand-l :flex -70)
  (:thigh-l :flex 50 :side 8) (:knee-l :flex 40) (:thigh-r :flex -30 :side 10) (:knee-r :flex 10))
(defstrike :hs-kb-sengen (10 3 22 :base :hs-k-stance)
  (0)
  (4 :hs-kb-sengen-up)
  (8 :hs-kb-sengen-up (:root :yaw -28 :u -0.22) (:chest :twist -36) (:arm-r :flex -46))
  (:s :snap :hs-kb-sengen-hit)
  (:a :hs-kb-sengen-hit (:arm-r :flex 92))
  (24 :hs-kb-sengen-hit (:root :f 0.1 :u -0.1 :yaw 8) (:chest :twist 12) (:arm-r :flex 70 :side 20) (:elbow-r :flex 30))
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

;;; The core bind's own clips (batch 2b, DUEL_HISAGI §28.9 / §28.12; the user, 2026-10-29: 「可以」): pointer 1 鎌 KAMA's NS1a
;;; KAGIYOSE, NS1c JŪJI, AS1 KAGIYOSE-GIRI; pointer 2 絞 SHIBORI's stance, NS2a MATOI, NS2b / AS2a SHIME, AS2b TSURI. Each at
;;; its move's frames (its S the hit pose, the windup inside the frames the move plays: from its :enter), its tell big and held
;;; (「記得動作要配合誇張而明顯的前搖」); what strikes on the tables below (*HS-LETOUT*, *HS-BK-CHAINS*, *HS-KB-REELS*, *HS-KB-WRAPS*,
;;; *HS-KB-GRIPS*). A look: the sim never reads them.
;; 絞 stance (pointer 2): sunk as the 鎌 stance but the right fist raised high over his right shoulder, the noose chain wound
;; round it and run taut straight up to the orb (%HS-ORB-DRAW, *HS-KB-GRIPS* flag 2); the left crescent held low behind his
;; left hip, pointing back; no chain in the left fist (the 鎌 stance's), no hawser over the shoulder (the Shikai's 縛)
(defpose :hs-kb-st-shibori (:base :hs-kb-stance)
  (:root :u -0.16 :f -0.02 :yaw 8) (:spine :flex 10) (:chest :twist 10) (:neck :twist -8) (:head :flex -6)
  (:arm-r :flex 165 :side 22 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -20)
  (:arm-l :flex -28 :side 28 :twist 0) (:elbow-l :flex 24) (:hand-l :flex -100))
(defclip :hs-kb-st-shibori (2.0 :loop t :base :hs-kb-st-shibori)
  (0) (1.0 (:root :u -0.18) (:spine :flex 12) (:elbow-r :flex 34) (:hand-l :flex -96)))

;; NS1a 鉤寄 KAGIYOSE (18/4/20; HS-B-HOOK-SEG's chain to him within 6 m, a first hit drags him to 1.5 m over 8 f): R2, the
;; cast and the reel. The javelin tell: the right crescent cocked far back over his right shoulder, coiled to his right, the
;; left arm pointing at him (f8, held to f15); the overhand cast on S, the arm along the line, the crescent let out on its
;; chain onto him (*HS-KB-REELS*: on the victim within 6 m) and hooked; the reel: sunk and leaning back, the right fist
;; hauled to his hip (f26-30) while the crescent stays in him through the drag, back in the fist by f36
(defpose :hs-kb-kagi-up (:base :hs-k-stance)
  (:root :u -0.12 :f -0.1 :yaw -34) (:spine :flex -10) (:chest :twist -40) (:neck :twist 30) (:head :flex -6)
  (:arm-r :flex 164 :side 60 :twist 0) (:elbow-r :flex 70) (:hand-r :flex -30)
  (:arm-l :flex 84 :side 4 :twist 0) (:elbow-l :flex 6) (:hand-l :flex -30)
  (:thigh-r :flex -30 :side 10) (:knee-r :flex 44) (:thigh-l :flex 34 :side 8) (:knee-l :flex 12))
(defpose :hs-kb-kagi-hit (:base :hs-k-stance)
  (:root :f 0.16 :u -0.14 :yaw 14) (:spine :flex 18) (:chest :twist 22) (:head :flex 0)
  (:arm-r :flex 96 :side 4 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -80)
  (:arm-l :flex 20 :side 30 :twist 0) (:elbow-l :flex 90) (:hand-l :flex -40)
  (:thigh-l :flex 52 :side 8) (:knee-l :flex 46) (:thigh-r :flex -30 :side 10) (:knee-r :flex 12))
(defpose :hs-kb-kagi-reel (:base :hs-k-stance)
  (:root :u -0.26 :f -0.12 :yaw -10) (:spine :flex -18) (:chest :twist -14) (:head :flex 8)
  (:arm-r :flex -20 :side 24 :twist 0) (:elbow-r :flex 70) (:hand-r :flex -40)
  (:arm-l :flex 80 :side 10 :twist 0) (:elbow-l :flex 20) (:hand-l :flex -20)
  (:thigh-l :flex 40 :side 10) (:knee-l :flex 30) (:thigh-r :flex -20 :side 12) (:knee-r :flex 60))
(defstrike :hs-kb-kagiyose (18 4 20 :base :hs-k-stance)
  (0 :hs-kb-stance)
  (4 :hs-kb-kagi-up (:root :yaw -20) (:chest :twist -26) (:arm-r :flex 120 :side 70) (:elbow-r :flex 40))   ; rising
  (8 :hs-kb-kagi-up)                                                                    ; cocked (the tell)
  (15 :hs-kb-kagi-up (:root :yaw -38 :u -0.14) (:chest :twist -44) (:arm-r :flex 170) (:elbow-r :flex 80))   ; held, deeper
  (:s :snap :hs-kb-kagi-hit)                                                            ; the cast
  (:a :hs-kb-kagi-hit (:root :f 0.2) (:arm-r :flex 92))
  (26 :hs-kb-kagi-reel)                                                                 ; the reel (the drag)
  (30 :hs-kb-kagi-reel (:root :u -0.24) (:arm-r :flex -26) (:elbow-r :flex 80))
  (36 :hs-kb-stance (:root :u -0.22))
  (:end :hs-kb-stance))

;; AS1 鉤寄斬 KAGIYOSE-GIRI (18/4/20, the same hook and drag): apart from KAGIYOSE by the hand and the height: the LEFT
;; crescent bowled underhand. The pendulum tell: the left arm swung up ahead (f4) then far back low behind his left hip, coiled
;; to his left and sunk, the right crescent cocked at his right side (f9, held to f15); the underhand cast on S, the left
;; crescent let out onto him (*HS-KB-REELS*); the reel: the left fist hauled back past his hip, the right crescent raised high
;; (f25); the right crescent's diagonal cut as he arrives at 1.5 m (f27, a look: the hook is the hit), its follow-through
(defpose :hs-kb-kgg-up (:base :hs-k-stance)
  (:root :u -0.24 :f -0.06 :yaw 30) (:spine :flex 22) (:chest :twist 40) (:neck :twist -30) (:head :flex -4)
  (:arm-l :flex -60 :side 30 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -90)
  (:arm-r :flex 30 :side 50 :twist 0) (:elbow-r :flex 110) (:hand-r :flex -60)
  (:thigh-l :flex -20 :side 10) (:knee-l :flex 60) (:thigh-r :flex 50 :side 10) (:knee-r :flex 70))
(defpose :hs-kb-kgg-hit (:base :hs-k-stance)
  (:root :f 0.14 :u -0.2 :yaw -16) (:spine :flex 20) (:chest :twist -24) (:head :flex 0)
  (:arm-l :flex 88 :side -4 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -70)
  (:arm-r :flex 20 :side 54 :twist 0) (:elbow-r :flex 110) (:hand-r :flex -60)
  (:thigh-l :flex 56 :side 8) (:knee-l :flex 60) (:thigh-r :flex -24 :side 12) (:knee-r :flex 30))
(defpose :hs-kb-kgg-reel (:base :hs-k-stance)
  (:root :u -0.18 :f -0.08 :yaw 10) (:spine :flex -12) (:chest :twist 20) (:head :flex 0)
  (:arm-l :flex -30 :side 20 :twist 0) (:elbow-l :flex 60) (:hand-l :flex -40)
  (:arm-r :flex 170 :side 40 :twist 0) (:elbow-r :flex 50) (:hand-r :flex -40)
  (:thigh-l :flex 30 :side 10) (:knee-l :flex 30) (:thigh-r :flex -20 :side 12) (:knee-r :flex 50))
(defpose :hs-kb-kgg-cut (:base :hs-k-stance)
  (:root :f 0.12 :u -0.2 :yaw 20) (:spine :flex 24) (:chest :twist 30) (:head :flex 0)
  (:arm-r :flex 70 :side -10 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -90)
  (:arm-l :flex 10 :side 30 :twist 0) (:elbow-l :flex 70) (:hand-l :flex -40)
  (:thigh-l :flex 50 :side 8) (:knee-l :flex 50) (:thigh-r :flex -26 :side 12) (:knee-r :flex 24))
(defstrike :hs-kb-kagiyose-giri (18 4 20 :base :hs-k-stance)
  (0 :hs-kb-stance)
  (4 :hs-kb-kgg-up (:root :yaw 10 :u -0.12) (:chest :twist 14) (:arm-l :flex 120 :side 20) (:elbow-l :flex 20))   ; swung up
  (9 :hs-kb-kgg-up)                                                                     ; far back low (the tell)
  (15 :hs-kb-kgg-up (:root :yaw 34 :u -0.26) (:chest :twist 44) (:arm-l :flex -66))     ; held, deeper
  (:s :snap :hs-kb-kgg-hit)                                                             ; the underhand cast
  (:a :hs-kb-kgg-hit (:root :f 0.18) (:arm-l :flex 84))
  (25 :hs-kb-kgg-reel)                                                                  ; reeled, the blade raised
  (27 :snap :hs-kb-kgg-cut)                                                             ; the cut as he arrives
  (32 :hs-kb-kgg-cut (:root :yaw 28) (:chest :twist 38) (:arm-r :flex 40 :side -30))    ; through
  (38 :hs-kb-stance (:root :u -0.22))
  (:end :hs-kb-stance))

;; NS1c 十字 JŪJI (14/3/18, 1.5 m arc 200; knockdown): both crescents raised high and wide over his head, leaning back on the
;; back foot (f5, held to f12); the step in on S and both slashed down across each other, each let out a hand's length on its
;; chain (*HS-LETOUT*: over the top and down to 1.5 m, the right one swept R -> L, the left L -> R, crossing in front on the
;; hit frames); diagonal, so neither J5 SŌGEN's flat scissor nor J1's hook
(defpose :hs-kb-juji-up (:base :hs-k-stance)
  (:root :u -0.04 :f -0.1) (:spine :flex -18) (:head :flex -10)
  (:arm-r :flex 140 :side 72 :twist 0) (:elbow-r :flex 20) (:hand-r :flex -30)
  (:arm-l :flex 140 :side 72 :twist 0) (:elbow-l :flex 20) (:hand-l :flex -30)
  (:thigh-r :flex -24 :side 10) (:knee-r :flex 30) (:thigh-l :flex 20 :side 8) (:knee-l :flex 10))
(defpose :hs-kb-juji-hit (:base :hs-k-stance)
  (:root :f 0.2 :u -0.22) (:spine :flex 26) (:head :flex -6)
  (:arm-r :flex 60 :side -26 :twist 0) (:elbow-r :flex 0) (:hand-r :flex -80)
  (:arm-l :flex 60 :side -26 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -80)
  (:thigh-l :flex 60 :side 8) (:knee-l :flex 70) (:thigh-r :flex -34 :side 10) (:knee-r :flex 20))
(defstrike :hs-kb-juji (14 3 18 :base :hs-k-stance)
  (0 :hs-kb-stance)
  (5 :hs-kb-juji-up)                                                                    ; raised (the tell)
  (12 :hs-kb-juji-up (:root :u 0.0) (:spine :flex -22) (:arm-r :flex 150) (:arm-l :flex 150))   ; held, rising
  (:s :snap :hs-kb-juji-hit)                                                            ; the step, the X
  (:a :hs-kb-juji-hit (:arm-r :flex 40 :side -34) (:arm-l :flex 40 :side -34))
  (24 :hs-kb-juji-hit (:root :u -0.2) (:arm-r :flex 36) (:arm-l :flex 36))
  (:end :hs-kb-stance))

;; NS2a 纏 MATOI (20/4/20, the 2.6 m line; a first hit drags him 1 m in): R4, the whip and the wrap. Coiled to his right, the
;; left fist cocked at his right shoulder for a backhand, sunk (f10, held to f17); on S the backhand flung out ahead-left, the
;; left crescent let out curling round from his left onto the line (*HS-LETOUT*'s sweep 80 -> 5 -> -5: inside the line's 0.35 m
;; on the hit frames) and onto him (*HS-KB-REELS*); on a hit the chain wound round him (*HS-KB-WRAPS*) while the left fist
;; hauls it back to his hip (f28-34: the drag)
(defpose :hs-kb-matoi-up (:base :hs-k-stance)
  (:root :u -0.2 :f -0.04 :yaw -36) (:spine :flex 16) (:chest :twist -44) (:neck :twist 34) (:head :flex -4)
  (:arm-l :flex 100 :side -50 :twist 0) (:elbow-l :flex 120) (:hand-l :flex -40)
  (:arm-r :flex -20 :side 30 :twist 0) (:elbow-r :flex 40) (:hand-r :flex -80)
  (:thigh-r :flex -10 :side 12) (:knee-r :flex 54) (:thigh-l :flex 40 :side 10) (:knee-l :flex 50))
(defpose :hs-kb-matoi-hit (:base :hs-k-stance)
  (:root :f 0.08 :u -0.16 :yaw 24) (:spine :flex 12) (:chest :twist 30) (:neck :twist -10) (:head :flex 0)
  (:arm-l :flex 86 :side 50 :twist 0) (:elbow-l :flex 0) (:hand-l :flex -80)
  (:arm-r :flex -10 :side 30 :twist 0) (:elbow-r :flex 50) (:hand-r :flex -70)
  (:thigh-l :flex 44 :side 10) (:knee-l :flex 44) (:thigh-r :flex -20 :side 12) (:knee-r :flex 30))
(defpose :hs-kb-matoi-haul (:base :hs-k-stance)
  (:root :u -0.24 :f -0.1 :yaw 10) (:spine :flex -16) (:chest :twist 14) (:head :flex 4)
  (:arm-l :flex -30 :side 24 :twist 0) (:elbow-l :flex 70) (:hand-l :flex -40)
  (:arm-r :flex 10 :side 40 :twist 0) (:elbow-r :flex 60) (:hand-r :flex -60)
  (:thigh-l :flex 30 :side 10) (:knee-l :flex 30) (:thigh-r :flex -24 :side 12) (:knee-r :flex 60))
(defstrike :hs-kb-matoi (20 4 20 :base :hs-k-stance)
  (0 :hs-kb-stance)
  (5 :hs-kb-matoi-up (:root :yaw -20 :u -0.18) (:chest :twist -26) (:arm-l :flex 80 :side -20) (:elbow-l :flex 90))
  (10 :hs-kb-matoi-up)                                                                  ; cocked (the tell)
  (17 :hs-kb-matoi-up (:root :yaw -40 :u -0.22) (:chest :twist -48) (:elbow-l :flex 128))   ; held, deeper
  (:s :snap :hs-kb-matoi-hit)                                                           ; the backhand whip
  (:a :hs-kb-matoi-hit (:root :yaw 30) (:chest :twist 36) (:arm-l :flex 96 :side 56))
  (28 :hs-kb-matoi-haul)                                                                ; wound, hauled in
  (34 :hs-kb-matoi-haul (:root :u -0.22) (:arm-l :flex -36))
  (:end :hs-kb-stance))

;; NS2b 締 SHIME / AS2a 締 (20/4/24 from f4, 2.8 m arc 140): R5, the noose cinched. Both fists gathered under his chin on the
;; noose chain, one chain in each (*HS-KB-GRIPS* flag 1), crouched, the elbows in, the slack drawn in and the chains taut by
;; f10 (held, trembling, to f17); on S both fists ripped apart and down to his hips, the chest thrown out: the two chains open
;; into a V from the noose, and two hanging chains whip in from his flanks to close round him (*HS-BK-CHAINS*: 2.8 m, from
;; +-55 to +-25 degrees); held to f34. Neither KAESHI-GAMA's one-chain fling nor SŌGEN's flat arms
(defpose :hs-kb-shime-up (:base :hs-k-stance)
  (:root :u -0.22 :f -0.02) (:spine :flex 22) (:chest :twist 0) (:head :flex -10)
  (:arm-r :flex 70 :side -10 :twist 0) (:elbow-r :flex 120) (:hand-r :flex -40)
  (:arm-l :flex 70 :side -10 :twist 0) (:elbow-l :flex 120) (:hand-l :flex -40)
  (:thighs :flex 40 :side 12) (:knees :flex 60))
(defpose :hs-kb-shime-hit (:base :hs-k-stance)
  (:root :u -0.3 :f 0.02) (:spine :flex -12) (:head :flex -14)
  (:arm-r :flex -18 :side 44 :twist 0) (:elbow-r :flex 46) (:hand-r :flex -40)
  (:arm-l :flex -18 :side 44 :twist 0) (:elbow-l :flex 46) (:hand-l :flex -40)
  (:thigh-l :flex 46 :side 14) (:knee-l :flex 66) (:thigh-r :flex 10 :side 16) (:knee-r :flex 60))
(defstrike :hs-kb-shime (20 4 24 :base :hs-k-stance)
  (0 :hs-kb-stance)
  (4 :hs-kb-stance)                                                                     ; (the moves start here: :enter 4)
  (9 :hs-kb-shime-up)                                                                   ; gathered (the tell)
  (17 :hs-kb-shime-up (:root :u -0.26) (:spine :flex 26) (:elbow-r :flex 128) (:elbow-l :flex 128))   ; held, drawn in
  (:s :snap :hs-kb-shime-hit)                                                           ; ripped apart: the cinch
  (:a :hs-kb-shime-hit (:arm-r :flex -24 :side 50) (:arm-l :flex -24 :side 50))
  (34 :hs-kb-shime-hit (:root :u -0.28))
  (42 :hs-kb-stance (:root :u -0.24))
  (:end :hs-kb-stance))

;; AS2b 吊 TSURI (22/5/34 from f8, 3.0 m arc 120; the launch): R5, the heave over the shoulder. Turned side-on, his right
;; shoulder to him, sunk deep, both fists up at his right shoulder on the line (f12, held to f20); on S he stands and bends
;; forward hard, both fists yanked down before his left hip: the neck bundle's tail thrown out over his right shoulder to the
;; victim's neck (*HS-BK-CHAINS* src 8, hooked in him on a hit: it rises with the launch; 3.0 m on a whiff), bent over to f40
(defpose :hs-kb-tsuri-up (:base :hs-k-stance)
  (:root :u -0.3 :yaw 70) (:spine :flex 18) (:chest :twist 20) (:neck :twist -50) (:head :flex 0)
  (:arm-r :flex 150 :side 10 :twist 0) (:elbow-r :flex 120) (:hand-r :flex -30)
  (:arm-l :flex 120 :side -30 :twist 0) (:elbow-l :flex 110) (:hand-l :flex -30)
  (:thighs :flex 50 :side 14) (:knees :flex 80))
(defpose :hs-kb-tsuri-hit (:base :hs-k-stance)
  (:root :u -0.06 :yaw 80) (:spine :flex 50) (:chest :twist 10) (:neck :twist -50) (:head :flex -30)
  (:arm-r :flex 30 :side -10 :twist 0) (:elbow-r :flex 40) (:hand-r :flex -40)
  (:arm-l :flex 20 :side 10 :twist 0) (:elbow-l :flex 40) (:hand-l :flex -40)
  (:thigh-l :flex 30 :side 10) (:knee-l :flex 20) (:thigh-r :flex -10 :side 12) (:knee-r :flex 10))
(defstrike :hs-kb-tsuri (22 5 34 :base :hs-k-stance)
  (0 :hs-kb-stance)
  (8 :hs-kb-stance)                                                                     ; (the move starts here: :enter 8)
  (12 :hs-kb-tsuri-up)                                                                  ; turned, loaded (the tell)
  (20 :hs-kb-tsuri-up (:root :u -0.34) (:spine :flex 22))                               ; held, deeper
  (:s :snap :hs-kb-tsuri-hit)                                                           ; the heave
  (:a :hs-kb-tsuri-hit (:spine :flex 56))
  (40 :hs-kb-tsuri-hit (:root :u -0.08) (:spine :flex 52))
  (50 :hs-kb-stance (:root :yaw 30 :u -0.2))
  (:end :hs-kb-stance))

;; AS3b 散 SAN (9/3/18, 3.0 m arc 200; DUEL_HISAGI §28.13: the release's middle beat, 解 > 散 > 放): both arms crossed tight over his
;; chest, hunched and sunk (f4, held to f7); on S flung open up and out, both crescents let out to 3.0 m and scattered apart across
;; the front (*HS-LETOUT*: the right 0 -> -40 -> -95, the left mirrored, rising), two hanging chains thrown out with them
;; (*HS-BK-CHAINS*: +-40 -> +-85); neither J5 SŌGEN's flat scissor at 1.5 m nor HANATSU's one-crescent sweep
(defpose :hs-kb-san-up (:base :hs-k-stance)
  (:root :u -0.26 :f -0.04) (:spine :flex 30) (:chest :twist 0) (:head :flex -14)
  (:arm-r :flex 80 :side -40 :twist 0) (:elbow-r :flex 120) (:hand-r :flex -40)
  (:arm-l :flex 80 :side -40 :twist 0) (:elbow-l :flex 120) (:hand-l :flex -40)
  (:thighs :flex 46 :side 12) (:knees :flex 66))
(defpose :hs-kb-san-hit (:base :hs-k-stance)
  (:root :u -0.06 :f 0.06) (:spine :flex -16) (:head :flex -12)
  (:arm-r :flex 130 :side 74 :twist 0) (:elbow-r :flex 6) (:hand-r :flex -60)
  (:arm-l :flex 130 :side 74 :twist 0) (:elbow-l :flex 6) (:hand-l :flex -60)
  (:thigh-l :flex 30 :side 12) (:knee-l :flex 30) (:thigh-r :flex -16 :side 14) (:knee-r :flex 24))
(defstrike :hs-kb-san (9 3 18 :base :hs-k-stance)
  (0 :hs-kb-stance)
  (4 :hs-kb-san-up)                                                                     ; crossed, hunched (the tell)
  (7 :hs-kb-san-up (:root :u -0.3) (:spine :flex 34) (:elbow-r :flex 128) (:elbow-l :flex 128))   ; held, tighter
  (:s :snap :hs-kb-san-hit)                                                             ; flung open: scattered
  (:a :hs-kb-san-hit (:arm-r :flex 140 :side 84) (:arm-l :flex 140 :side 84))
  (20 :hs-kb-san-hit (:root :u -0.1) (:arm-r :flex 120 :side 80) (:arm-l :flex 120 :side 80))
  (:end :hs-kb-stance))

(defparameter *hs-bk-chains*
  '(;; (§28.19: J5 SENSA's swept chain gone: its six chains are the drill, *HS-LASHES*)
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
    (:hs-k-kake 8 10 24 28 36 50 5.0 1.5 0 0 0 9)             ; §28.11 AS3c KAKE: the neck bundle's tail into his left fist, then
                                                              ;  taut over his right shoulder to him (hooked on a hit; *HS-LK-REACH*)
    (:hs-kb-makigiri 2 6 20 24 30 40 2.8 0.95 70 -70 0 8)    ; the bind's K2: a left one flung across at the chest
    (:hs-kb-shibori 9 8 22 27 40 52 2.95 0.05 22 22 0 0)       ; K3: two dropped out of the orb, cinching
    (:hs-kb-shibori 9 8 22 27 40 52 2.95 0.05 -22 -22 0 0)
    (:hs-kb-shime 0 6 20 23 30 40 2.8 1.3 55 25 0.5 0)          ; batch 2b (§28.12): NS2b / AS2a SHIME, two whipped in from his
    (:hs-kb-shime 7 6 20 23 30 40 2.8 1.3 -55 -25 0.5 0)        ;  flanks, closing round him (+-55 -> +-25: inside +-70)
    (:hs-kb-san 1 3 9 12 16 26 3.0 0.9 40 85 0.4 0)            ; §28.13: AS3b SAN, two thrown out with the crescents
    (:hs-kb-san 6 3 9 12 16 26 3.0 0.9 -40 -85 0.4 0)          ;  (+-40 -> +-85: inside +-100)
    (:hs-kb-tsuri 8 10 22 27 40 52 3.0 1.6 0 0 0.6 1))          ; AS2b TSURI: the neck bundle over his shoulder to his neck
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
  '((:hs-k-hosoku 255 0 1.0 2 30                    ; K1 綁束: all eight hauled in and up, whirled out to 4.5 m round him (§25.5: 5.0; §25.34: 5.5; §25.35: 4.5)
     (6 0.8 2.4 0 45 0) (13 0.6 2.8 40 45 0.2) (15 0.9 2.2 70 45 0)          ;  (the orb winding), the spin a key each 90 deg
     (16 4.5 1.0 100 45 0.6) (17 4.5 1.0 190 45 0.4) (18 4.5 1.0 280 45 0.3) (19 4.5 1.0 370 45 0.2)
     (21 3.6 1.1 430 45 0.2) (25 1.6 1.0 470 45 0))                             ;  wound in: the bundle (*HS-BUNDLED*)
    (:hs-k-s-k2 102 0.34 0.8 7 42                   ; spread K2: hanging chains 1 2 5 6 hauled up behind him, over the top,
     (10 1.5 2.8 140 27 0) (17 1.7 3.6 145 27 0.3) (19 0.6 4.6 150 27 0)        ;  whipped onto the ground in a 60 deg fan
     (20 2.6 3.4 30 -20 1.0) (21 4.5 0.05 30 -20 0.8) (24 4.5 0.05 30 -20 -0.6) (30 4.32 0.05 30 -20 -0.8))
    (:hs-k-s-k3 255 0.45 0.85 7 50                  ; spread K3: all eight drawn back high behind him, lashed forward in a
     (9 1.7 2.6 110 20 0) (18 2.0 3.0 112 20 0.3) (20 2.2 2.8 114 20 0)       ;  160 deg fan (a third of a frame apart)
     (21 4.5 0.9 80 -22.857 0.6) (25 4.5 0.8 80 -22.857 0.2) (34 4.14 0.25 80 -22.857 -0.6))
    (:hs-k-g-k2 256 0 1.0 6 58                      ; gathered K2: the bundle heaved up behind him, over: the U onto 4.5 m,
     (9 1.2 2.2 -60 0 0) (16 1.4 4.4 -150 0 0.4) (24 1.6 4.8 -158 0 0.5)       ;  then its tail lashed flat along the ground at
     (26 0.6 5.4 -20 0 0) (27 4.5 0.25 0 0 2.4) (30 4.5 0.2 0 0 1.4)           ;  4.5 m (the L; §25.5: K 2-5 m; §25.35: 2.5-4.5), left lying
     (31 4.14 0.12 0 0 -0.4) (33 4.5 0.1 0 0 -1.6) (36 4.5 0.1 0 0 -1.8) (46 4.41 0.05 0 0 -2.0))   ;  flat ahead
    (:hs-k-g-k3 256 0 1.0 5 58                      ; gathered K3: the lying bundle hauled in and round to his right, whirled
     (6 4.41 0.05 0 0 -2.0) (14 4.5 0.15 -10 0 -1.2) (20 4.5 0.4 -60 0 -0.4)    ;  round him at 4.5 m (a key each 90 deg)
     (25 4.5 0.6 -100 0 0) (26 4.5 0.7 -110 0 0) (27 4.5 0.8 -20 0 0.3) (28 4.5 0.8 70 0 0.3) (29 4.5 0.8 160 0 0.3)
     (30 4.5 0.8 250 0 0.3) (31 4.5 0.8 340 0 0.3) (34 4.32 0.6 380 0 0) (42 3.96 0.3 400 0 -0.4))
    (:hs-k-g-j2 256 0 1.0 1 30                      ; gathered J2: the bundle cocked back by his right hip, lashed straight
     (5 1.0 1.2 -120 0 0) (13 1.5 1.5 -140 0 0.2) (15 1.2 1.6 -100 0 0)        ;  down the line at the chest, a wave along it
     (16 4.5 1.0 0 0 0.6) (17 4.5 1.0 0 0 -0.4) (18 4.5 1.0 0 0 0.25) (20 4.35 0.9 0 0 -0.15))   ; (§28.11: 4.5, was 6.0)
    (:hs-k-g-j3 256 0 1.0 1 36                      ; gathered J3: the bundle drawn round behind his right, swept flat
     (5 2.0 0.9 -100 0 0) (13 2.6 0.9 -135 0 0.2) (15 2.8 0.9 -140 0 0)        ;  through the front at 4.5 m (§28.11: J5's 90 deg
     (16 4.5 0.8 -40 0 0.3) (17 4.5 0.8 5 0 0.3) (18 4.5 0.8 50 0 0.3) (20 4.2 0.7 110 0 0) (24 4.0 0.5 130 0 -0.3))   ;  on the hit frames, was 6.0 m -90..90)
    (:hs-k-saharai 255 0.2 0.9 0 52                 ; A3 (§24.3; §25.7: S 18): L SAHARAI, all eight wrapped in tight round
     (4 0.7 1.5 20 45 0) (8 0.6 1.4 80 45 0.1) (12 0.55 1.3 170 45 0.2)        ;  him and whirled faster and faster (the charge,
     (15 0.5 1.25 280 45 0.25) (17 0.5 1.2 380 45 0.3)                         ;  f4-17), lashed out in a ring to 3.0 m on S
     (18 3.0 1.0 400 45 0.7) (19 3.0 0.95 415 45 0.5) (21 3.0 0.85 435 45 0.3) ;  (f18-21), fallen to the floor (the impact
     (22 3.0 0.7 440 45 0.1) (26 2.9 0.1 448 45 -0.4) (34 2.4 0.05 452 45 -0.6) ;  hold), dragged in along it as he hauls,
     (42 1.6 0.4 456 45 -0.2))                                                  ;  lifted back into the curtain by f52
    ;; batch 2a (§28.11): the core ranged mode's own clips, the tips on the bands' far edges on the hit frames
    (:hs-k-st-shu 256 0 1.1 0 9999                  ; 聚 stance: the bundle run down his right side past the fist, its end on
     (0 0.85 0.12 -60 0 0) (9999 0.85 0.12 -60 0 0))                            ;  the floor by his right foot
    (:hs-k-uchi 128 0 0.9 2 24                      ; SA 打: the front-right hanging chain flicked out along the line to 6.0
     (4 1.3 0.5 -80 0 0) (8 1.0 1.4 -110 0 0.3) (9 3.0 1.5 -40 0 0.6)
     (10 6.0 1.0 4 0 0.6) (11 6.0 0.95 2 0 -0.3) (12 6.0 0.95 0 0 0.2) (13 6.0 0.9 0 0 0) (16 5.6 0.6 0 0 -0.3))
    (:hs-r-sa-g 256 0 1.0 2 24                      ; the gathered SA (keyed on the move, its clip UCHI's at 10/13): the
     (4 1.0 0.6 -70 0 0) (8 0.9 1.6 -110 0 0.3) (9 2.4 1.5 -40 0 0.5)           ;  bundle flicked out to 4.5
     (10 4.5 1.0 4 0 0.5) (11 4.5 0.95 2 0 -0.3) (12 4.5 0.9 0 0 0.2) (13 4.5 0.9 0 0 0) (16 4.2 0.6 0 0 -0.3))
    (:hs-k-ogi 102 0.34 0.8 7 44                    ; NS1b 扇: hanging chains 1 2 5 6 hauled up behind him, over the top,
     (10 1.5 2.8 140 27 0) (17 1.7 3.6 145 27 0.3) (19 0.6 4.6 150 27 0)        ;  whipped onto the ground in a 60 deg fan at 6.0
     (20 3.2 3.4 30 -20 1.0) (21 6.0 0.05 30 -20 0.8) (24 6.0 0.05 30 -20 -0.6) (30 5.76 0.05 30 -20 -0.8))
    (:hs-k-issei 255 0.45 0.85 8 52                 ; NS1c 一斉: all eight drawn back high behind him, lashed forward in a
     (11 1.7 2.6 110 20 0) (18 2.0 3.0 112 20 0.3) (20 2.2 2.8 114 20 0)       ;  160 deg fan at 6.0 (a third of a frame apart)
     (21 6.0 0.9 80 -22.857 0.6) (25 6.0 0.8 80 -22.857 0.2) (34 5.5 0.25 80 -22.857 -0.6))
    (:hs-k-ransa 192 0.3 0.8 6 40                   ; AS1 乱鎖: the right two (6 7) with the right arm, high right to low left
     (12 1.4 2.6 -120 15 0.2) (19 1.6 3.2 -130 15 0.3) (20 3.4 2.6 -60 15 0.6)
     (21 6.0 1.4 -35 15 0.5) (22 6.0 0.5 10 15 0.3) (24 5.8 0.1 30 15 -0.4) (30 5.4 0.05 30 15 -0.7))
    (:hs-k-ransa 6 0.3 0.8 6 42                     ;  the left two (1 2) with the left arm, mirrored (f23)
     (12 1.4 2.6 120 -15 0.2) (19 1.6 3.2 130 -15 0.3) (22 3.4 2.6 60 -15 0.6)
     (23 6.0 1.4 35 -15 0.5) (24 6.0 0.5 -10 -15 0.3) (26 5.8 0.1 -30 -15 -0.4) (32 5.4 0.05 -30 -15 -0.7))
    (:hs-k-ransa 57 0.25 0.9 8 50                   ;  the other four (0 3 4 5) with both arms, a V fan (f25)
     (12 1.6 3.4 160 -106.67 0.2) (24 1.8 3.8 160 -106.67 0.3)
     (25 6.0 0.6 70 -46.67 0.6) (26 6.0 0.3 70 -46.67 0.2) (28 6.0 0.1 70 -46.67 -0.4) (36 5.5 0.05 70 -46.67 -0.7))
    (:hs-k-tataki 256 0 1.0 9 64                    ; NS2b 叩: the bundle wheeled at his left, over the top, smashed at 3.0
     (12 1.0 0.8 60 0 0) (15 1.5 0.5 150 0 0.2) (18 1.3 2.6 170 0 0.4) (22 1.0 4.6 175 0 0.5)
     (26 0.7 5.4 170 0 0.4) (28 1.4 4.6 60 0 0.6) (29 2.4 2.4 10 0 0.6) (30 3.0 0.15 0 0 0.8)
     (32 3.0 0.1 0 0 0.2) (34 3.0 0.1 0 0 -0.4) (40 2.9 0.05 0 0 -0.8) (52 2.2 0.05 0 0 -1.0))
    (:hs-k-sweep 256 0 1.0 9 64                     ; AS2a 叩: the bundle drawn round to his left, swept along the floor
     (12 1.2 0.5 -40 0 0) (18 1.6 0.3 70 0 -0.2) (24 2.0 0.2 120 0 -0.3)        ;  L -> R at 4.5 (f30-33, +45 .. -45)
     (28 2.4 0.2 125 0 -0.3) (29 3.4 0.2 90 0 0.2) (30 4.5 0.15 45 0 0.4) (31 4.5 0.12 15 0 0.3)
     (32 4.5 0.12 -15 0 0.3) (33 4.5 0.15 -45 0 0.2) (35 4.3 0.2 -80 0 0) (42 3.8 0.1 -100 0 -0.4) (52 3.0 0.05 -100 0 -0.6))
    (:hs-k-jibashiri 256 0 1.0 12 66                ; AS2b 地走: the bundle heaved overhead, driven down at his feet (f34),
     (16 1.0 2.4 -40 0 0.2) (24 0.8 4.4 -20 0 0.3) (31 0.6 5.0 -10 0 0.3)       ;  run out along the floor to 4.5 (S 36)
     (33 1.0 1.2 0 0 0.6) (34 1.4 0.05 0 0 0) (35 3.0 0.05 0 0 -0.6) (36 4.5 0.05 0 0 -0.9)
     (40 4.5 0.05 0 0 -1.0) (46 4.3 0.05 0 0 -1.2) (56 3.0 0.1 0 0 -0.6))
    (:hs-k-maki 3 1.5 0.9 12 58                     ; AS3b 巻: hanging chains 0 1 cast at him (5.0 authored: *HS-LK-REACH*
     (14 2.0 1.6 30 0 0.6) (20 3.6 1.4 10 0 0.5) (24 4.5 0.4 0 0 0.3)           ;  puts 5.0 on him), spiralled round him two
     (25 5.0 0.5 5.7 0 0.2) (26 5.5 0.6 0 0 0.2) (27 5.0 0.7 -5.7 0 0.2) (28 4.5 0.8 0 0 0.2)   ;  turns rising (0.5 m round
     (29 5.0 0.95 5.7 0 0.2) (30 5.5 1.1 0 0 0.2) (31 5.0 1.25 -5.7 0 0.2) (32 4.5 1.4 0 0 0.2)  ;  at 5 m), held wound
     (33 5.0 1.4 5.7 0 0.2) (40 5.0 1.3 0 0 0.1) (46 4.6 0.9 0 0 0))
    ;; §28.19 (batch 4a, the 散 J string's chain paths; the user: 「散可以」): spread 6.0 m inside +-50 on the hit frames f10-12
    ;; (J2 鋏鞭's two chains are its crescents' let-outs, *HS-LETOUT*: from both hands)
    (:hs-k-na3 1 0 0.8 0 24                         ; J3 蛇鞭: the front-left one (0) laid on the floor and sent crawling at
     (2 1.8 0.05 28 0 -1.5) (4 2.6 0.05 20 0 -1.5) (6 3.5 0.05 12 0 -1.5)       ;  him (the slither, *HS-WAVES*' lateral S),
     (8 4.5 0.05 6 0 -1.5) (9 5.3 0.08 3 0 -1.2)                                ;  reared up into him from below on S (1.2 m
     (10 6.0 1.3 2 0 0.3) (11 6.0 1.9 1 0 0.3) (12 6.0 2.3 0 0 0.1)              ;  up in a frame: a vertical trail) and on up
     (14 5.8 2.5 0 0 -0.2) (20 5.0 1.2 0 0 -0.5))
    (:hs-k-na4 128 0 0.8 0 26                       ; J4 旋投: the front-right one (7) whirled flat over his head, 1.5 turns
     (2 1.5 2.8 180 0 0.2) (3 1.5 2.85 -102.9 0 0.2) (4 1.5 2.9 -25.7 0 0.2)    ;  counter-clockwise (77 deg a frame, a key each),
     (5 1.5 2.85 51.4 0 0.2) (6 1.5 2.8 128.6 0 0.2) (7 1.5 2.85 -154.3 0 0.2)  ;  ending ahead of him (f9), flung straight at
     (8 1.5 2.9 -77.1 0 0.2) (9 1.6 2.8 0 0 0.2)                                 ;  him (the lag bowing it out), taut on f12
     (10 6.0 1.35 0 0 0.6) (11 6.0 1.2 0 0 0.3) (12 6.0 1.1 0 0 0.05)
     (14 5.7 0.9 0 0 -0.2) (20 4.6 0.3 0 0 -0.5))
    (:hs-k-sensa 231 0.12 0.75 0 30                 ; J5 旋鎖: six (0 1 2 5 6 7) gathered before his chest, twisted (the
     (3 1.0 1.6 -1.5 0.6 0.2) (8 0.9 1.5 -1.5 0.6 0.2) (9 3.2 1.3 -1.5 0.6 0.1) ;  drill, *HS-WAVES*' helix), bored out along the
     (10 6.0 1.15 -1.5 0.6 0) (11 6.0 1.1 -1.5 0.6 0) (12 6.0 1.15 -1.5 0.6 0)  ;  line on S (a rank 0.12 f late), held turning
     (16 6.0 1.05 -1.5 0.6 0) (22 4.6 0.6 -1.5 0.6 -0.3))                       ;  through the push, unwound
    (:hs-k-g-na3 256 0 1.0 3 36                     ; gathered J3 束昇: the bundle drawn back low behind his right, ripped
     (5 1.0 0.6 -60 0 0) (12 1.3 0.2 -110 0 -0.1) (17 1.4 0.15 -120 0 0)        ;  up across the line to high at his left
     (18 2.8 0.5 -60 0 0.4) (19 4.5 0.5 -30 0 0.5) (20 4.5 1.4 5 0 0.4) (21 4.5 2.3 35 0 0.2)
     (23 4.3 2.6 60 0 -0.2) (30 3.6 1.2 70 0 -0.4))
    (:hs-k-g-na4 256 0 1.0 3 36                     ; gathered J4 束落: the bundle hauled up high behind him, over the
     (5 1.0 1.0 -40 0 0) (12 1.2 3.6 -150 0 0.3) (17 1.0 4.6 -165 0 0.4)        ;  top and cracked down on the line
     (18 1.2 5.0 -60 0 0.4) (19 4.5 1.6 -4 0 0.8) (20 4.5 0.4 -2 0 0.3) (21 4.5 0.1 0 0 -0.3)
     (24 4.4 0.05 0 0 -0.6) (32 3.8 0.1 0 0 -0.5)))
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
(defparameter *hs-waves*
  '((:hs-k-na3 1 1 0 2 8 9.5 0.4 0.75 1.1)         ; J3 蛇鞭: the slither, a lateral S travelling down the floor chain
    (:hs-k-na3 1 2 9.5 10 13 17 0.5 0.6 0.9)       ;  the rear: a vertical S up the rising chain
    (:hs-k-sensa 231 3 1 4 18 24 0.38 1.1 -1.0))    ; J5 旋鎖: the drill, six helices turning round its line
  "Batch 4a (DUEL_HISAGI §28.19; a look): a lashing chain's body bent into a path, its free end left on its *HS-LASHES*
key (the drawn reach unchanged): (clip mask kind f0 f1 f2 f3 amp k speed). MASK the hanging chains (bits 0-7); KIND 1 a
lateral S (horizontal, across the chain), 2 a vertical S, 3 a helix (each chain its own phase, 45 deg x its index; a cone
widest near the knee, tapering to the end); AMP m (the helix's radius), eased in from clip frame F0 to F1, held to F2,
out by F3; K waves a metre along it; SPEED rad a frame (the S travels out along it, the helix turns). Drawn by
%HS-CUBIC-CHAIN on the chain's outer 0.7 (from its knee, none at either end).")
(defparameter *hs-waves-v*
  (let ((out nil))
    (dolist (x *hs-waves* out)
      (let ((cell (assoc (first x) out)) (v (coerce (mapcar #'f32 (rest x)) 'f32vec)))
        (if cell (setf (cdr cell) (append (cdr cell) (list v))) (setf out (append out (list (list (first x) v))))))))
  "*HS-WAVES* by clip: (clip f32vec ...), each mask kind f0 f1 f2 f3 amp k speed.")
(defparameter *hs-bundled* '((:hs-k-hosoku 21 26) (:hs-k-g-k2 -2 -1) (:hs-k-g-k3 -2 -1) (:hs-k-g-j2 -2 -1) (:hs-k-g-j3 -2 -1)
                             (:hs-k-st-shu -2 -1) (:hs-r-sa-g -2 -1) (:hs-k-tataki -2 -1) (:hs-k-sweep -2 -1)   ; (§28.11; the
                             (:hs-k-jibashiri -2 -1) (:hs-k-g-na3 -2 -1) (:hs-k-g-na4 -2 -1))   ; (§28.15)                                                           ;  gathered SA by its move)
  "Clip -> the clip frames over which the eight hanging chains are bound into one bundle (0 -> 1; bound after; the gathered
links bound throughout): K1 綁束 binds them, the gathered links strike with the bundle (the user, 2026-10-18: 「K1 將垂降的
鎖鏈在身旁旋轉並捆成一束」, DUEL_HISAGI §22.4). Out of these clips the bundle comes apart into the curtain over 0.25 s.")
(defparameter *hs-bundled-v* (mapcar (lambda (x) (cons (first x) (coerce (mapcar #'f32 (rest x)) 'f32vec))) *hs-bundled*)
  "*HS-BUNDLED* as (clip . f32vec).")
(defparameter *hs-bundle-rest* '(-35.0 1.25 0.9)
  "Where the bundle's free end hangs (degrees off his facing, m from his feet, m up): at his right front, by his right fist.")
(defparameter *hs-spins*
  '((:hs-k-saben 5 12 20 0.5) (:hs-k-kaeshi 4 10 18 -0.5) (:hs-k-sensa 3 10 22 1.0) (:hs-k-saharai 2 18 32 2.0)   ; (§28.19: J2 / J5 at S 10)
    (:hs-k-raiden 7 20 30 0.5) (:hs-k-ame 8 30 50 1.0) (:hs-k-kosa 7 20 30 0.5) (:hs-k-kubikake 5 24 34 1.0)
    (:hs-k-hosoku 6 16 26 1.0) (:hs-k-s-k2 9 21 30 0.5) (:hs-k-s-k3 8 21 32 0.75) (:hs-k-g-k2 8 27 40 0.75)
    (:hs-k-g-k3 6 27 36 1.0) (:hs-k-g-j2 3 16 22 0.5) (:hs-k-g-j3 4 16 22 0.75)
    (:hs-k-uchi 3 10 16 0.4) (:hs-k-ogi 9 21 30 0.5) (:hs-k-issei 8 21 32 0.75) (:hs-k-ransa 8 21 32 1.0)   ; (§28.11)
    (:hs-k-tataki 9 30 40 0.5) (:hs-k-sweep 9 30 40 -0.75) (:hs-k-jibashiri 12 36 46 0.5) (:hs-k-maki 12 27 40 1.5)
    (:hs-k-kake 8 24 34 -0.5)
    (:hs-k-na3 3 10 18 -0.5) (:hs-k-na4 3 10 18 0.5) (:hs-k-g-na3 6 19 28 -0.5) (:hs-k-g-na4 6 19 28 0.5))   ; (§28.15)
  "The carousel's jerk (batch A2, DUEL_HISAGI §24.2; the user, 2026-10-18: §22.1's 旋鎖陣, 「遠程攻擊有效利用鎖鏈球拉動垂鏈迴轉
對遠程進行抽打」): the ranged mode's strike clip -> (f0 f1 f2 turns): the orb (and the hanging chains round him) spun TURNS
turns (+ counter-clockwise from above) on top of its slow turn, winding up from clip frame F0, fastest at F1 (S), done by F2.")
(defparameter *hs-spins-v* (mapcar (lambda (x) (cons (first x) (coerce (mapcar #'f32 (rest x)) 'f32vec))) *hs-spins*)
  "*HS-SPINS* as (clip . f32vec).")
(defparameter *hs-car-w* 0.25 "The orb's slow turn at rest (rad/s, counter-clockwise from above): the hanging chains orbit
him with it (§22.1, batch A2; the orb's own 0.25 of §21.6).")
(defparameter *hs-kb-grips* '((:hs-kb-stance 9999 0) (:hs-kb-walk-f 9999 0) (:hs-kb-walk-b 9999 0) (:hs-kb-strafe-r 9999 0)
                               (:hs-kb-strafe-l 9999 0) (:hs-kb-kojo 30 9) (:hs-kb-kaibaku 18 5)
                               (:hs-kb-st-shibori 0 0 2) (:hs-kb-shime 42 10 1)   ; (batch 2b, §28.12)
                               (:hs-cine-ks-haul 9999 0 2))   ; (batch 3b, §28.17: KŌSHU's haul: the 絞 stance's wound chain, the left fist on the noose)
  "The bind's clips in which his left fist holds a chain run to the opponent's noose (§22.1: 「the noose taut」): (clip F1
FT [FL]): held to clip frame F1; slack (sagging) until FT, then taut, trembling from FT on when FT > 0 (batch A3, §24.3: L
KOJO's heave, f9-19, held through its drag to S; SP2 KAIBAKU-GEKI's haul, thrown off on its S). FL (batch 2b, §28.12; none: 0)
bits: 1 his right fist holds a second chain to the noose the same way (NS2b / AS2a SHIME's two); 2 the 絞 stance: the noose
chain wound round his right fist and run taut straight up to the orb's underside (whatever F1).")
(defparameter *hs-kb-reels* '((:hs-kb-kagiyose 6.0) (:hs-kb-kagiyose-giri 6.0) (:hs-kb-matoi 2.95 :line)
                               (:hs-cine-kg-haul 6.0) (:hs-cine-kg-cuts 6.0) (:hs-cine-kg-strain 6.0) (:hs-cine-kg-rip 6.0))   ; (3b, §28.17)
  "Batch 2b (§28.12): the bind's clips whose let-out lands on the victim: (clip reach [:line]): while out, its point lies at
his distance from Hisagi's feet, at most REACH (its *HS-LETOUT* r: HS-B-HOOK-SEG's *HS-B-HOOK-REACH* 6 m for the hooks,
MATOI's line end 2.6 + its r 0.35), so it follows him through the drag, stops at him on a block and at REACH on a whiff
(HS-KB-LK!). §28.15 (the user, 2026-10-29: 「鉤寄、鉤寄斬、纏甩出去的鐮刀是沿修兵的面向畫的」): and along his bearing, not
Hisagi's facing (the let-out's az then off his bearing); :line (MATOI: a capsule along the facing) only on a hit or a block.")
(defparameter *hs-kb-wraps* '((:hs-kb-matoi 20 32))
  "Batch 2b (§28.12): clip -> (F0 F1): on clip frames F0 <= f < F1, when his move hit, the chain wound three times round the
victim (%HS-COIL) and run taut from his left fist to it (NS2a MATOI: from its S through the drag).")
(defparameter *hs-kb-grips-v* (mapcar (lambda (x) (cons (first x) (coerce (mapcar #'f32 (rest x)) 'f32vec))) *hs-kb-grips*)
  "*HS-KB-GRIPS* as (clip . f32vec).")


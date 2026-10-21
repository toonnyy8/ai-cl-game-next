;;;; lille-clips.lisp — Lille's poses and clips (the :lb-* base form, JILLIEL, the owl): the clip half of lille-art.lisp
;;;; (split out 2026-10-21, refactor round 2). Loads after lille-art.lisp (bodies, props, *LB-STRIKE-POINTS*) and before
;;;; lille-draw.lisp; barro-art.lisp's clips base on these poses. The host FK test reads this file for its DEFPOSE / DEFCLIP /
;;;; DEFSTRIKE forms (docs/duel/DUEL_LILLE_V3.md, the animation inventory).
(in-package :duel)

;;; ---------------------------------------------------------------- poses and clips: the base form
;;; Upright and still, Diagramm levelled at the hip (idle) or shouldered (aim). The J links swing the plank (the rifle
;;; reversed); J3's muzzle-cross pose stays (barro-art.lisp's :br-jab-hit bases on it; the old Lille's J3 / K1-K3 strikes and
;;; his K -> L snap shot went 2026-10-21, refactor round 2).
(defpose :lb-stance ()
  (:root :u -0.03) (:pelvis :twist 12) (:spine :flex 2) (:chest :twist -8) (:neck :twist -4) (:head :twist -4)
  (:arm-r :flex 16 :side 12) (:elbow-r :flex 64) (:hand-r :flex -78)
  (:arm-l :flex 44 :side 4) (:elbow-l :flex 70) (:hand-l :flex -20)
  (:thigh-r :flex -4 :side 4) (:thigh-l :flex 6 :side 4) (:knee-r :flex 6) (:knee-l :flex 8))
(defclip :lb-stance (2.6 :loop t :base :lb-stance)
  (0) (1.3 (:root :u -0.04) (:chest :flex 2) (:elbow-l :flex 74)))

(defpose :lb-aim-pose (:base :lb-stance)              ; shouldered: the cheek on the sleeve, the right eye along the barrel
  (:root :u -0.06) (:pelvis :twist 20) (:chest :twist -14) (:neck :twist -10) (:head :flex 6 :twist 18)
  (:arm-r :flex 60 :side 30) (:elbow-r :flex 110) (:hand-r :flex -170)
  (:arm-l :flex 80 :side 4) (:elbow-l :flex 20) (:hand-l :flex -10)
  (:thigh-r :flex -8 :side 8) (:thigh-l :flex 18 :side 6) (:knees :flex 14))
(defclip :lb-aim (0.6 :loop t :base :lb-aim-pose) (0) (0.3 (:root :u -0.065) (:chest :flex 1)))
(defstrike :lb-fire (4 2 26 :base :lb-aim-pose)       ; the shot: the recoil, the plank drops
  (0)
  (:s :snap (:root :f -0.04) (:head :flex 2))
  (:a (:root :f -0.1) (:arm-r :flex 70 :side 32) (:chest :flex -6))
  (20 (:root :f -0.04) (:arm-r :flex 50) (:elbow-r :flex 90) (:hand-r :flex -140))
  (:end :lb-stance))

;; J1 SHOBI-UCHI: the rifle reversed, the plank swung up from the hip into him
(defpose :lb-q1-hit (:base :lb-stance)
  (:root :f 0.26 :u -0.05) (:pelvis :twist 10) (:chest :twist 10) (:arm-r :flex 82 :side 6) (:elbow-r :flex 8) (:hand-r :flex 90)
  (:arm-l :flex 60 :side 10) (:elbow-l :flex 40) (:thigh-r :flex 20) (:knee-r :flex 18) (:thigh-l :flex -8))
(defstrike :lb-q1 (8 3 12 :base :lb-stance)
  (0)
  (4 (:arm-r :flex 10 :side 16) (:elbow-r :flex 20) (:hand-r :flex 120) (:root :u -0.06) (:chest :twist -6))
  (:s :snap :lb-q1-hit)
  (:a :lb-q1-hit)
  (17 (:root :f 0.1) (:arm-r :flex 50) (:elbow-r :flex 40) (:hand-r :flex 20))
  (:end :lb-stance))
;; J2 KAESHI: the plank's backhand, across him
(defpose :lb-q2-hit (:base :lb-stance)
  (:root :f 0.3 :u -0.05 :yaw -10) (:pelvis :twist -10) (:chest :twist -24) (:arm-r :flex 84 :side 22) (:elbow-r :flex 6)
  (:hand-r :flex 92) (:arm-l :flex 40 :side 20) (:elbow-l :flex 40))
(defstrike :lb-q2 (7 3 13 :base :lb-stance)
  (0 (:arm-r :flex 70 :side 40) (:hand-r :flex 90) (:chest :twist 20))
  (:s :snap :lb-q2-hit)
  (:a :lb-q2-hit)
  (17 (:root :f 0.1) (:chest :twist -6) (:arm-r :flex 40) (:hand-r :flex 0))
  (:end :lb-stance))
;; J3 JUKO-TSUKI's hit pose: the muzzle cross jabbed up into his face, the hand at the hip (:br-jab-hit's base)
(defpose :lb-jab-hit (:base :lb-stance)
  (:root :f 0.0 :u -0.06) (:chest :twist 4) (:arm-r :flex 24 :side 12) (:elbow-r :flex 46) (:hand-r :flex -24)
  (:arm-l :flex 70) (:elbow-l :flex 30) (:thigh-r :flex 16) (:knee-r :flex 14))

;; SP1 SANREN: three snap shots from the shoulder, turning between them
(defstrike :lb-sanren (12 22 24 :base :lb-aim-pose)
  (0)
  (:s :snap (:root :f -0.05))
  (16 (:root :f 0))
  (22 :snap (:root :f -0.05))
  (26 (:root :f 0))
  (32 :snap (:root :f -0.06))
  (:a (:root :f -0.08))
  (:end :lb-stance))
;; SP2 HIRENKYAKU: the back-slide (the body low, the rifle shouldered), then the quick shot
(defstrike :lb-hiren (20 2 22 :base :lb-aim-pose)
  (0 (:root :u -0.2 :pitch 8) (:knees :flex 40) (:thighs :flex 30))
  (14 (:root :u -0.1 :pitch 0) (:knees :flex 20))
  (:s :snap (:root :f -0.05))
  (:a (:root :f -0.1))
  (:end :lb-stance))
;; I: the dash (the rifle levelled), the strike: the plank slammed down
(defclip :lb-breaker (0.4 :loop t :base :lb-stance)
  (0 (:root :u -0.1) (:spine :flex 22) (:arm-r :flex 30 :side 10) (:elbow-r :flex 50) (:hand-r :flex 90)
     (:thigh-r :flex 30) (:knee-r :flex 20) (:thigh-l :flex -20) (:knee-l :flex 30))
  (0.2 (:root :u -0.08) (:thigh-l :flex 30) (:knee-l :flex 20) (:thigh-r :flex -20) (:knee-r :flex 30)))
(defpose :lb-butt-hit (:base :lb-stance)
  (:root :f 0.1 :u -0.1) (:spine :flex 16) (:arm-r :flex 70 :side 6) (:elbow-r :flex 10) (:hand-r :flex 120)
  (:arm-l :flex 70) (:elbow-l :flex 20) (:knees :flex 20))
(defstrike :lb-butt (8 4 18 :base :lb-stance)
  (0 (:arm-r :flex 160 :side 10) (:elbow-r :flex 20) (:hand-r :flex 100) (:spine :flex -8))
  (:s :snap :lb-butt-hit)
  (:a :lb-butt-hit)
  (24 (:spine :flex 6) (:arm-r :flex 40))
  (:end :lb-stance))
;; the intro (the cloak thrown off: the rifle brought up and levelled) and the win (the rifle stood upright beside him)
(defclip :lb-intro (2.0 :base :lb-stance)
  (0 (:arm-r :flex 0 :side 6) (:elbow-r :flex 10) (:hand-r :flex 90) (:head :flex 8))
  (0.8 (:arm-r :flex 0) (:hand-r :flex 90))
  (1.2 :snap :lb-aim-pose)
  (2.0 :lb-aim-pose))
(defclip :lb-win (2.0 :base :lb-stance)
  (0)
  (0.6 (:arm-r :flex 10 :side 14) (:elbow-r :flex 70) (:hand-r :flex 20) (:head :flex 6))
  (2.0 (:arm-r :flex 10 :side 14) (:elbow-r :flex 70) (:hand-r :flex 20) (:head :flex 8 :twist 10)))

;;; ---------------------------------------------------------------- JILLIEL
;;; Floating 0.5 m up (the hurt cylinder stays on the ground). The arms are hidden in the column (decision 19): the rig's
;;; hands are the tips of the front wing pair (LILLE-DRAW draws each from its root behind the column's top to the hand), so
;;; the strikes are the front wings swung forward, their tips at the moves' reach. Idle, the hands sit in the fan (about
;;; -16 degrees, the third pair) and sway out of step (the other six sway on their own phases in the draw hook).
(defpose :lb-w-stance ()
  (:root :u 0) (:spine :flex 0) (:head :flex 4)
  (:arm-r :flex 2 :side 78) (:elbow-r :flex 8) (:arm-l :flex 2 :side 78) (:elbow-l :flex 8)
  (:thighs :flex 0) (:knees :flex 0))
(defclip :lb-w-stance (3.0 :loop t :base :lb-w-stance)
  (0) (0.8 (:root :u 0.03) (:arm-r :side 74) (:arm-l :side 81)) (1.5 (:root :u 0.06) (:arm-r :side 72) (:arm-l :side 77))
  (2.3 (:root :u 0.03) (:arm-r :side 80) (:arm-l :side 73)))
(defpose :lb-w-fold-pose (:base :lb-w-stance)        ; 無実体 MUJITTAI: the wings folded round the column, the front pair
  (:root :u 0.05) (:arm-r :flex 0 :side 30 :twist 45) (:elbow-r :flex 110)   ; crossed low before it
  (:arm-l :flex 0 :side 30 :twist -45) (:elbow-l :flex 110) (:head :flex 10))
(defclip :lb-w-fold (2.0 :loop t :base :lb-w-fold-pose) (0) (1.0 (:root :u 0.1)))
;; Decision 50 (2026-10-07, DUEL_LILLE §23.31: 「全身出招」「每招獨立造型」): every J / K is its own whole-body strike, KIN's
;; (melee, on the ㄇ legs) and EN's (laying lines: casts) apart. Each key's comment gives the wings' aims (azimuth / elevation
;; in degrees, the chest's frame: + = his right / up); the hand is the wing tip, so the hit pose (on S, through S + A) puts
;; it at the move's reach (the host FK test; EN's casts at :reach on S, the line's frame). The chest twist and the root
;; turn add to the arm's aim (+ twist / yaw = turned to his left). The spins (K1 / K2, EN's too) turn the root a full turn:
;; their two keys 0.0001 f apart differ by exactly 360 degrees of root yaw (the same pose: the turn's count is unwound
;; between two frames, never sampled), so the clip starts and ends at yaw 0 with no unwinding turn and no blend.
(defstrike :lb-w-q1 (8 3 12 :base :lb-w-stance)   ; J1 左斬: the right wing cocked high behind, a step in, cut right -> left
  (0)
  ;; R 128/24, L -86/-6
  (5 (:root :f -0.12 :u 0.03 :yaw -8) (:spine :flex -5) (:chest :twist -24) (:arm-r :flex -34.2 :side 119.5)
   (:elbow-r :flex 30) (:arm-l :flex 4 :side 84) (:elbow-l :flex 4) (:thigh-r :flex -14) (:thigh-l :flex 16))
  ;; R 138/30, L -84/-4
  (7 (:root :f -0.14 :u 0.03 :yaw -10) (:spine :flex -6) (:chest :twist -28) (:arm-r :flex -40.1 :side 130.8)
   (:elbow-r :flex 34) (:arm-l :flex 6 :side 86) (:elbow-l :flex 4) (:thigh-r :flex -16) (:thigh-l :flex 18))
  ;; R 34/3, L -102/-10
  (:s :snap (:root :f 0.04 :u -0.04 :yaw 6) (:spine :flex 12) (:chest :twist 16) (:arm-r :flex 55.9 :side 95.4)
   (:elbow-r :flex 22) (:arm-l :flex -11.8 :side 79.8) (:elbow-l :flex 4) (:thigh-r :flex 30) (:thigh-l :flex -18))
  ;; R 14/-4, L -110/-12
  (:a (:root :f 0.06 :u -0.04 :yaw 10) (:spine :flex 13) (:chest :twist 26) (:arm-r :flex 75.5 :side 73.9)
   (:elbow-r :flex 22) (:arm-l :flex -19.5 :side 77.3) (:elbow-l :flex 4) (:thigh-r :flex 30) (:thigh-l :flex -18))
  ;; R -33/-16, L -114/-10
  (15 (:root :f 0.2 :u -0.03 :yaw 12) (:spine :flex 12) (:chest :twist 30) (:arm-r :flex 126.3 :side 117.8)
   (:elbow-r :flex 10) (:arm-l :flex -23.6 :side 79.1) (:elbow-l :flex 4) (:thigh-r :flex 24) (:thigh-l :flex -14))
  (:end :lb-w-stance))
(defstrike :lb-w-q2 (7 3 13 :base :lb-w-stance)   ; J2 右斬: the mirror, the left wing, cut left -> right
  (0)
  ;; R 86/-6, L -128/24
  (4 (:root :f -0.12 :u 0.03 :yaw 8) (:spine :flex -5) (:chest :twist 24) (:arm-r :flex 4 :side 84)
   (:elbow-r :flex 4) (:arm-l :flex -34.2 :side 119.5) (:elbow-l :flex 30) (:thigh-r :flex 16) (:thigh-l :flex -14))
  ;; R 84/-4, L -138/30
  (6 (:root :f -0.14 :u 0.03 :yaw 10) (:spine :flex -6) (:chest :twist 28) (:arm-r :flex 6 :side 86)
   (:elbow-r :flex 4) (:arm-l :flex -40.1 :side 130.8) (:elbow-l :flex 34) (:thigh-r :flex 18) (:thigh-l :flex -16))
  ;; R 102/-10, L -34/3
  (:s :snap (:root :f 0.04 :u -0.04 :yaw -6) (:spine :flex 12) (:chest :twist -16) (:arm-r :flex -11.8 :side 79.8)
   (:elbow-r :flex 4) (:arm-l :flex 55.9 :side 95.4) (:elbow-l :flex 22) (:thigh-r :flex -18) (:thigh-l :flex 30))
  ;; R 110/-12, L -14/-4
  (:a (:root :f 0.06 :u -0.04 :yaw -10) (:spine :flex 13) (:chest :twist -26) (:arm-r :flex -19.5 :side 77.3)
   (:elbow-r :flex 4) (:arm-l :flex 75.5 :side 73.9) (:elbow-l :flex 22) (:thigh-r :flex -18) (:thigh-l :flex 30))
  ;; R 114/-10, L 33/-16
  (14 (:root :f 0.2 :u -0.03 :yaw -12) (:spine :flex 12) (:chest :twist -30) (:arm-r :flex -23.6 :side 79.1)
   (:elbow-r :flex 4) (:arm-l :flex 126.3 :side 117.8) (:elbow-l :flex 10) (:thigh-r :flex -14) (:thigh-l :flex 24))
  (:end :lb-w-stance))
(defstrike :lb-w-q3 (9 3 18 :base :lb-w-stance)   ; J3 十字: both wings raised high and wide, crossed down through the front (an X)
  (0)
  ;; R 50/62, L -50/62
  (6 (:root :f -0.1 :u 0.1 :pitch -6) (:spine :flex -10) (:head :flex -4) (:arm-r :flex 17.6 :side 157.8)
   (:elbow-r :flex 20) (:arm-l :flex 17.6 :side 157.8) (:elbow-l :flex 20) (:thigh-r :flex -10) (:thigh-l :flex 10))
  ;; R 46/70, L -46/70
  (8 (:root :f -0.12 :u 0.12 :pitch -7) (:spine :flex -12) (:head :flex -4) (:arm-r :flex 13.7 :side 165.3)
   (:elbow-r :flex 24) (:arm-l :flex 13.7 :side 165.3) (:elbow-l :flex 24) (:thigh-r :flex -12) (:thigh-l :flex 12))
  (:s :snap (:root :f 0.32 :u -0.05 :pitch 4) (:spine :flex 16) (:arm-r :flex 106.1 :side 120.2) (:elbow-r :flex 4)
   (:arm-l :flex 106.1 :side 120.2) (:elbow-l :flex 4) (:thigh-r :flex 26) (:thigh-l :flex -20))   ; R -14/-8, L 14/-8
  (:a (:root :f 0.26 :u -0.05 :pitch 5) (:spine :flex 18) (:arm-r :flex 129.2 :side 130) (:elbow-r :flex 4)
   (:arm-l :flex 129.2 :side 130) (:elbow-l :flex 4) (:thigh-r :flex 26) (:thigh-l :flex -20))   ; R -32/-24, L 32/-24
  ;; R -55/-42, L 55/-42
  (18 (:root :f 0.2 :u -0.06 :pitch 5) (:spine :flex 20) (:arm-r :flex 154.8 :side 137.7) (:elbow-r :flex 10)
   (:arm-l :flex 154.8 :side 137.7) (:elbow-l :flex 10) (:thigh-r :flex 22) (:thigh-l :flex -16))
  (:end :lb-w-stance))
(defstrike :lb-w-f1 (17 4 21 :base :lb-w-stance)   ; K1 旋: coiled right, one full turn left on the legs, the right wing sweeping through
  (0)
  ;; R 105/10, L -55/20
  (6 (:root :u -0.08 :yaw -50) (:spine :flex 8) (:chest :twist -18) (:arm-r :flex -14.8 :side 100.3)
   (:elbow-r :flex 20) (:arm-l :flex 32.6 :side 114) (:elbow-l :flex 20) (:thigh-r :flex -16) (:thigh-l :flex 18))
  ;; R 108/12, L -52/22
  (8.5 (:root :u -0.08 :yaw -58) (:spine :flex 8) (:chest :twist -22) (:arm-r :flex -17.6 :side 102.6)
   (:elbow-r :flex 22) (:arm-l :flex 34.8 :side 117.1) (:elbow-l :flex 22) (:thigh-r :flex -16) (:thigh-l :flex 18))
  ;; R 108/12, L -52/22
  (8.5001 :snap (:root :u -0.08 :yaw -418) (:spine :flex 8) (:chest :twist -22) (:arm-r :flex -17.6 :side 102.6)
   (:elbow-r :flex 22) (:arm-l :flex 34.8 :side 117.1) (:elbow-l :flex 22) (:thigh-r :flex -16) (:thigh-l :flex 18))
  ;; R 92/0, L -92/0
  (13 :snap (:root :u 0.02 :f 0.2 :yaw -200) (:spine :flex 4) (:chest :twist 0) (:arm-r :flex -2 :side 90)
   (:elbow-r :flex 6) (:arm-l :flex -2 :side 90) (:elbow-l :flex 6) (:thigh-r :flex 6) (:thigh-l :flex -6))
  ;; R 14/0, L -118/8
  (:s :snap (:root :f 0.62 :u -0.04 :yaw -10) (:spine :flex 12) (:chest :twist 10) (:arm-r :flex 76 :side 90)
   (:elbow-r :flex 4) (:arm-l :flex -27.7 :side 99) (:elbow-l :flex 10) (:thigh-r :flex 28) (:thigh-l :flex -20))
  ;; R 7/-3, L -122/6
  (:a (:root :f 0.64 :u -0.04 :yaw 14) (:spine :flex 12) (:chest :twist 18) (:arm-r :flex 82.4 :side 66.7)
   (:elbow-r :flex 4) (:arm-l :flex -31.8 :side 97.1) (:elbow-l :flex 10) (:thigh-r :flex 28) (:thigh-l :flex -20))
  ;; R -24/-14, L -118/0
  (28 (:root :f 0.55 :u -0.03 :yaw 24) (:spine :flex 10) (:chest :twist 22) (:arm-r :flex 117.6 :side 121.5)
   (:elbow-r :flex 10) (:arm-l :flex -28 :side 90) (:elbow-l :flex 10) (:thigh-r :flex 22) (:thigh-l :flex -14))
  (:end :lb-w-stance))
(defstrike :lb-w-f2 (20 4 24 :base :lb-w-stance)   ; K2 逆旋: the counter-spin (entered at f6 in its strings), the left wing
  (0)
  (10 (:root :u -0.08 :yaw 50) (:spine :flex 8) (:chest :twist 18) (:arm-r :flex 32.6 :side 114) (:elbow-r :flex 20)
   (:arm-l :flex -14.8 :side 100.3) (:elbow-l :flex 20) (:thigh-r :flex 18) (:thigh-l :flex -16))   ; R 55/20, L -105/10
  ;; R 52/22, L -108/12
  (12.5 (:root :u -0.08 :yaw 58) (:spine :flex 8) (:chest :twist 22) (:arm-r :flex 34.8 :side 117.1)
   (:elbow-r :flex 22) (:arm-l :flex -17.6 :side 102.6) (:elbow-l :flex 22) (:thigh-r :flex 18) (:thigh-l :flex -16))
  ;; R 52/22, L -108/12
  (12.5001 :snap (:root :u -0.08 :yaw 418) (:spine :flex 8) (:chest :twist 22) (:arm-r :flex 34.8 :side 117.1)
   (:elbow-r :flex 22) (:arm-l :flex -17.6 :side 102.6) (:elbow-l :flex 22) (:thigh-r :flex 18) (:thigh-l :flex -16))
  ;; R 92/0, L -92/0
  (17 :snap (:root :u 0.02 :f 0.2 :yaw 200) (:spine :flex 4) (:chest :twist 0) (:arm-r :flex -2 :side 90)
   (:elbow-r :flex 6) (:arm-l :flex -2 :side 90) (:elbow-l :flex 6) (:thigh-r :flex -6) (:thigh-l :flex 6))
  ;; R 118/8, L -14/0
  (:s :snap (:root :f 0.62 :u -0.04 :yaw 10) (:spine :flex 12) (:chest :twist -10) (:arm-r :flex -27.7 :side 99)
   (:elbow-r :flex 10) (:arm-l :flex 76 :side 90) (:elbow-l :flex 4) (:thigh-r :flex -20) (:thigh-l :flex 28))
  ;; R 122/6, L -7/-3
  (:a (:root :f 0.64 :u -0.04 :yaw -14) (:spine :flex 12) (:chest :twist -18) (:arm-r :flex -31.8 :side 97.1)
   (:elbow-r :flex 10) (:arm-l :flex 82.4 :side 66.7) (:elbow-l :flex 4) (:thigh-r :flex -20) (:thigh-l :flex 28))
  ;; R 118/0, L 24/-14
  (31 (:root :f 0.55 :u -0.03 :yaw -24) (:spine :flex 10) (:chest :twist -22) (:arm-r :flex -28 :side 90)
   (:elbow-r :flex 10) (:arm-l :flex 117.6 :side 121.5) (:elbow-l :flex 10) (:thigh-r :flex -14) (:thigh-l :flex 22))
  (:end :lb-w-stance))
(defstrike :lb-w-f3 (21 5 34 :base :lb-w-stance)   ; K3 昇翼: crouched, both wings swept low behind, a rising cleave into the air, the landing
  (0)
  ;; R 150/-28, L -150/-28
  (13 (:root :u -0.2 :pitch 10 :f -0.05) (:spine :flex 22) (:head :flex 6) (:arm-r :flex -49.9 :side 43.2)
   (:elbow-r :flex 20) (:arm-l :flex -49.9 :side 43.2) (:elbow-l :flex 20) (:thigh-r :flex 28) (:thigh-l :flex 22))
  ;; R 110/-40, L -110/-40
  (18 (:root :u -0.16 :pitch 8 :f 0.1) (:spine :flex 18) (:arm-r :flex -15.2 :side 48.2) (:elbow-r :flex 10)
   (:arm-l :flex -15.2 :side 48.2) (:elbow-l :flex 10) (:thigh-r :flex 26) (:thigh-l :flex 10))
  (:s :snap (:root :f 0.72 :u 0.12 :pitch -2) (:spine :flex 6) (:arm-r :flex 81.8 :side 104.1) (:elbow-r :flex 4)
   (:arm-l :flex 81.8 :side 104.1) (:elbow-l :flex 4) (:thigh-r :flex 22) (:thigh-l :flex -14))   ; R 8/2, L -8/2
  (:a (:root :f 0.7 :u 0.34 :pitch -6) (:spine :flex -4) (:arm-r :flex 47.7 :side 173.4) (:elbow-r :flex 4)
   (:arm-l :flex 47.7 :side 173.4) (:elbow-l :flex 4) (:thigh-r :flex 30) (:thigh-l :flex 10))   ; R 6/42, L -6/42
  ;; R 5/78, L -5/78
  (33 (:root :f 0.55 :u 0.5 :pitch -8) (:spine :flex -10) (:head :flex -6) (:arm-r :flex 12 :side 178.9)
   (:elbow-r :flex 8) (:arm-l :flex 12 :side 178.9) (:elbow-l :flex 8) (:thigh-r :flex 40) (:thigh-l :flex 30))
  (41 :snap (:root :f 0.4 :u -0.16 :pitch 10) (:spine :flex 22) (:arm-r :flex 53.4 :side 33) (:elbow-r :flex 8)
   (:arm-l :flex 53.4 :side 33) (:elbow-l :flex 8) (:thigh-r :flex 26) (:thigh-l :flex -24))   ; R 22/-30, L -22/-30
  (47 (:root :f 0.36 :u -0.12 :pitch 8) (:spine :flex 18) (:arm-r :flex 43 :side 32.6) (:elbow-r :flex 10)
   (:arm-l :flex 43 :side 32.6) (:elbow-l :flex 10) (:thigh-r :flex 24) (:thigh-l :flex -20))   ; R 30/-38, L -30/-38
  (:end :lb-w-stance))
(defstrike :lb-e-q1 (4 3 6 :base :lb-w-stance)   ; EN J1: the right wing raised high, thrown down along the line (the cast)
  (0)
  (2 (:root :u 0.06 :pitch -6) (:spine :flex -8) (:chest :twist -16) (:arm-r :flex -8.5 :side 145.9)
   (:elbow-r :flex 24) (:arm-l :flex -5 :side 84) (:elbow-l :flex 4))   ; R 105/55, L -95/-6
  (3 (:root :u 0.07 :pitch -7) (:spine :flex -9) (:chest :twist -18) (:arm-r :flex -9.8 :side 151.5)
   (:elbow-r :flex 26) (:arm-l :flex -5 :side 84) (:elbow-l :flex 4))   ; R 110/60, L -95/-6
  (:s :snap (:root :f 0.12 :u -0.03 :pitch 6) (:spine :flex 14) (:chest :twist 12) (:arm-r :flex 69.5 :side 60.3)
   (:elbow-r :flex 4) (:arm-l :flex -9.7 :side 75.8) (:elbow-l :flex 4))   ; R 18/-10, L -100/-14
  (:a (:root :f 0.1 :u -0.03 :pitch 6) (:spine :flex 16) (:chest :twist 14) (:arm-r :flex 57.9 :side 3.2)
   (:elbow-r :flex 4) (:arm-l :flex -13.6 :side 75.6) (:elbow-l :flex 4))   ; R 2/-32, L -104/-14
  (10 (:root :f 0.08 :u -0.02 :pitch 4) (:spine :flex 12) (:chest :twist 10) (:arm-r :flex 40.8 :side -18.3)
   (:elbow-r :flex 8) (:arm-l :flex -9.8 :side 77.8) (:elbow-l :flex 4))   ; R -20/-46, L -100/-12
  (:end :lb-w-stance))
(defstrike :lb-e-q2 (4 3 6 :base :lb-w-stance)   ; EN J2: the mirror, the left wing
  (0)
  (2 (:root :u 0.06 :pitch -6) (:spine :flex -8) (:chest :twist 16) (:arm-r :flex -5 :side 84) (:elbow-r :flex 4)
   (:arm-l :flex -8.5 :side 145.9) (:elbow-l :flex 24))   ; R 95/-6, L -105/55
  (3 (:root :u 0.07 :pitch -7) (:spine :flex -9) (:chest :twist 18) (:arm-r :flex -5 :side 84) (:elbow-r :flex 4)
   (:arm-l :flex -9.8 :side 151.5) (:elbow-l :flex 26))   ; R 95/-6, L -110/60
  (:s :snap (:root :f 0.12 :u -0.03 :pitch 6) (:spine :flex 14) (:chest :twist -12) (:arm-r :flex -9.7 :side 75.8)
   (:elbow-r :flex 4) (:arm-l :flex 69.5 :side 60.3) (:elbow-l :flex 4))   ; R 100/-14, L -18/-10
  (:a (:root :f 0.1 :u -0.03 :pitch 6) (:spine :flex 16) (:chest :twist -14) (:arm-r :flex -13.6 :side 75.6)
   (:elbow-r :flex 4) (:arm-l :flex 57.9 :side 3.2) (:elbow-l :flex 4))   ; R 104/-14, L -2/-32
  (10 (:root :f 0.08 :u -0.02 :pitch 4) (:spine :flex 12) (:chest :twist -10) (:arm-r :flex -9.8 :side 77.8)
   (:elbow-r :flex 4) (:arm-l :flex 40.8 :side -18.3) (:elbow-l :flex 8))   ; R 100/-12, L 20/-46
  (:end :lb-w-stance))
(defstrike :lb-e-q3 (5 3 9 :base :lb-w-stance)   ; EN J3: both wings raised, crossed down onto the line
  (0)
  (3 (:root :u 0.08 :pitch -8) (:spine :flex -10) (:arm-r :flex 18.1 :side 161) (:elbow-r :flex 20)
   (:arm-l :flex 18.1 :side 161) (:elbow-l :flex 20))   ; R 45/64, L -45/64
  (4 (:root :u 0.09 :pitch -9) (:spine :flex -11) (:arm-r :flex 14.7 :side 166.3) (:elbow-r :flex 22)
   (:arm-l :flex 14.7 :side 166.3) (:elbow-l :flex 22))   ; R 42/70, L -42/70
  (:s :snap (:root :f 0.4 :u -0.04 :pitch 8) (:spine :flex 16) (:arm-r :flex 104.4 :side 146.8) (:elbow-r :flex 4)
   (:arm-l :flex 104.4 :side 146.8) (:elbow-l :flex 4))   ; R -8/-12, L 8/-12
  (:a (:root :f 0.36 :u -0.04 :pitch 8) (:spine :flex 18) (:arm-r :flex 131.8 :side 147) (:elbow-r :flex 4)
   (:arm-l :flex 131.8 :side 147) (:elbow-l :flex 4))   ; R -26/-34, L 26/-34
  (12 (:root :f 0.08 :u -0.03 :pitch 6) (:spine :flex 14) (:arm-r :flex 149.2 :side 149.9) (:elbow-r :flex 10)
   (:arm-l :flex 149.2 :side 149.9) (:elbow-l :flex 10))   ; R -40/-48, L 40/-48
  (:end :lb-w-stance))
(defstrike :lb-e-f1 (9 4 10 :base :lb-w-stance)   ; EN K1: a whirl, the right wing fanning low across the front (the three lines)
  (0)
  (2 (:root :yaw -50) (:spine :flex 6) (:chest :twist -16) (:arm-r :flex -19.5 :side 102.7) (:elbow-r :flex 20)
   (:arm-l :flex 33.5 :side 109.3) (:elbow-l :flex 20))   ; R 110/12, L -55/16
  (2.5 (:root :yaw -52) (:spine :flex 6) (:chest :twist -17) (:arm-r :flex -21.5 :side 102.9) (:elbow-r :flex 20)
   (:arm-l :flex 34.4 :side 109.5) (:elbow-l :flex 20))   ; R 112/12, L -54/16
  (2.5001 :snap (:root :yaw -412) (:spine :flex 6) (:chest :twist -17) (:arm-r :flex -21.5 :side 102.9)
   (:elbow-r :flex 20) (:arm-l :flex 34.4 :side 109.5) (:elbow-l :flex 20))   ; R 112/12, L -54/16
  (6 :snap (:root :yaw -200) (:spine :flex 4) (:chest :twist 0) (:arm-r :flex -5 :side 86) (:elbow-r :flex 6)
   (:arm-l :flex -5 :side 86) (:elbow-l :flex 6))   ; R 95/-4, L -95/-4
  (:s :snap (:root :f 0.72 :pitch 6 :yaw -8) (:spine :flex 12) (:chest :twist 10) (:arm-r :flex 59 :side 74.3)
   (:elbow-r :flex 4) (:arm-l :flex -29.9 :side 94.6) (:elbow-l :flex 10))   ; R 30/-8, L -120/4
  (:a (:root :f 0.66 :pitch 6 :yaw 10) (:spine :flex 12) (:chest :twist 18) (:arm-r :flex 73.7 :side 10.3)
   (:elbow-r :flex 4) (:arm-l :flex -31.9 :side 94.7) (:elbow-l :flex 10))   ; R 3/-16, L -122/4
  (17 (:root :f 0.4 :pitch 4 :yaw 18) (:spine :flex 10) (:chest :twist 20) (:arm-r :flex 57.9 :side -40.1)
   (:elbow-r :flex 10) (:arm-l :flex -28 :side 90) (:elbow-l :flex 10))   ; R -22/-24, L -118/0
  (:end :lb-w-stance))
(defstrike :lb-e-f2 (10 4 12 :base :lb-w-stance)   ; EN K2: the counter-whirl (entered at f3), the left wing
  (0)
  (3 (:root :yaw 30) (:spine :flex 4) (:chest :twist 10) (:arm-r :flex 33.5 :side 109.3) (:elbow-r :flex 16)
   (:arm-l :flex -9.8 :side 100.2) (:elbow-l :flex 16))   ; R 55/16, L -100/10
  (4 (:root :yaw 50) (:spine :flex 6) (:chest :twist 16) (:arm-r :flex 33.5 :side 109.3) (:elbow-r :flex 20)
   (:arm-l :flex -19.5 :side 102.7) (:elbow-l :flex 20))   ; R 55/16, L -110/12
  (4.5 (:root :yaw 52) (:spine :flex 6) (:chest :twist 17) (:arm-r :flex 34.4 :side 109.5) (:elbow-r :flex 20)
   (:arm-l :flex -21.5 :side 102.9) (:elbow-l :flex 20))   ; R 54/16, L -112/12
  (4.5001 :snap (:root :yaw 412) (:spine :flex 6) (:chest :twist 17) (:arm-r :flex 34.4 :side 109.5)
   (:elbow-r :flex 20) (:arm-l :flex -21.5 :side 102.9) (:elbow-l :flex 20))   ; R 54/16, L -112/12
  (7 :snap (:root :yaw 200) (:spine :flex 4) (:chest :twist 0) (:arm-r :flex -5 :side 86) (:elbow-r :flex 6)
   (:arm-l :flex -5 :side 86) (:elbow-l :flex 6))   ; R 95/-4, L -95/-4
  (:s :snap (:root :f 0.72 :pitch 6 :yaw 8) (:spine :flex 12) (:chest :twist -10) (:arm-r :flex -29.9 :side 94.6)
   (:elbow-r :flex 10) (:arm-l :flex 59 :side 74.3) (:elbow-l :flex 4))   ; R 120/4, L -30/-8
  (:a (:root :f 0.66 :pitch 6 :yaw -10) (:spine :flex 12) (:chest :twist -18) (:arm-r :flex -31.9 :side 94.7)
   (:elbow-r :flex 10) (:arm-l :flex 73.7 :side 10.3) (:elbow-l :flex 4))   ; R 122/4, L -3/-16
  (18 (:root :f 0.4 :pitch 4 :yaw -18) (:spine :flex 10) (:chest :twist -20) (:arm-r :flex -28 :side 90)
   (:elbow-r :flex 10) (:arm-l :flex 57.9 :side -40.1) (:elbow-l :flex 10))   ; R 118/0, L 22/-24
  (:end :lb-w-stance))
(defstrike :lb-e-f3 (11 5 17 :base :lb-w-stance)   ; EN K3: rising, both wings overhead, slammed down onto the line (the landing)
  (0)
  (4 (:root :u 0.08) (:spine :flex -4) (:arm-r :flex 22.5 :side 134.1) (:elbow-r :flex 20)
   (:arm-l :flex 22.5 :side 134.1) (:elbow-l :flex 20))   ; R 60/40, L -60/40
  (8 (:root :u 0.3 :pitch -10) (:spine :flex -10) (:head :flex -8) (:arm-r :flex 10.7 :side 170.9)
   (:elbow-r :flex 20) (:arm-l :flex 10.7 :side 170.9) (:elbow-l :flex 20))   ; R 40/76, L -40/76
  (10 (:root :u 0.34 :pitch -11) (:spine :flex -11) (:head :flex -8) (:arm-r :flex 6.5 :side 175.3)
   (:elbow-r :flex 24) (:arm-l :flex 6.5 :side 175.3) (:elbow-l :flex 24))   ; R 36/82, L -36/82
  (:s :snap (:root :f 0.9 :u -0.1 :pitch 8) (:spine :flex 16) (:arm-r :flex 99.4 :side 211.8) (:elbow-r :flex 4)
   (:arm-l :flex 99.4 :side 211.8) (:elbow-l :flex 4))   ; R 5/-8, L -5/-8
  (:a (:root :f 0.7 :u -0.2 :pitch 10) (:spine :flex 20) (:arm-r :flex 130.2 :side 184.8) (:elbow-r :flex 4)
   (:arm-l :flex 130.2 :side 184.8) (:elbow-l :flex 4))   ; R 4/-40, L -4/-40
  (22 (:root :f 0.5 :u -0.16 :pitch 8) (:spine :flex 16) (:arm-r :flex 132.3 :side 186.6) (:elbow-r :flex 8)
   (:arm-l :flex 132.3 :side 186.6) (:elbow-l :flex 8))   ; R 6/-42, L -6/-42
  (:end :lb-w-stance))
;; Decision 56 (2026-10-08, DUEL_LILLE §23.37; the user: 「Jilliel 的 SP1, SP2 跟毀魂技動畫」 redone 「全改」): his SPs and his
;; Kikon in play, whole-body moves like decision 50's strikes (each key's comment: the front wings' aims, azimuth / elevation
;; in the chest frame, + = his right / up; the chest twist and the root turn add to it, + = turned to his left).
;; - SP1 三連 SANREN: three thrusts, the right wing, the left, both, each straight at him on its shot frame, then kicked back
;;   (the column 0.26-0.5 m back, the tip up) while he turns into the next. KIN's (:lb-w-sanren, the move :lb-sanren's
;;   frames 12 22 24, shots f12 / f22 / f32) plays through the KIN kit's :clip-map (the base form's :lb-sanren is the rifle's);
;;   EN's own (:lb-e-sanren, 6 14 12, its lines f6 / f12 / f18). LILLE-DRAW whips the wings and flashes the firing wing's holes.
;; - SP2 二十四孔 NIJUSHI-KO (:lb-w-nijushi, KIN 40 6 30; EN at :clip-s 40, x2): rising 0.3 m, the front wings out into the
;;   ring's lower places (LILLE-DRAW turns the six table wings into the rest of the ring, the holes to him), the bow drawn
;;   (leaning back, shaking harder each 2 f), the shot on S a 0.6 m recoil with the wings blown back, the recovery.
;; - the Kikon 神の裁き in play: the aura (:lb-w-kikon, 8 f) rises toward the ring, the strike (:lb-w-kikon-fire, 20 3 30)
;;   charges it (shaking), fires the 24 lines on S with the recoil, then the wings close down before him (the verdict).
(defpose :lb-w-ring-in (:base :lb-w-stance)          ; the Kikon's aura end: rising, the front wings swung up and out
  (:root :f -0.02 :u 0.16) (:spine :flex -2) (:head :flex 2) (:arm-r :flex 5.9 :side 98) (:elbow-r :flex 12)   ; R 84/8
  (:arm-l :flex 5.9 :side 98) (:elbow-l :flex 12) (:thigh-r :flex -6) (:thigh-l :flex -6))                     ; L -84/8
;; the Kikon cinematic's (decision 56's storyboard, DUEL_LILLE §23.37): the ring held 0.3 m up, the front wings in its
;; lower places (R 75/-22, L -75/-22; LILLE-DRAW turns the six table wings into the rest), and the verdict: the wings
;; closed down before him (R 26/-66, L -26/-66), the column bowed
(defpose :lb-w-ring-pose (:base :lb-w-stance)
  (:root :f -0.04 :u 0.3 :pitch -1) (:spine :flex -4) (:head :flex 0) (:arm-r :flex 13.9 :side 67.3) (:elbow-r :flex 4)
  (:arm-l :flex 13.9 :side 67.3) (:elbow-l :flex 4) (:thigh-r :flex -6) (:thigh-l :flex -6))
(defpose :lb-w-verdict-pose (:base :lb-w-stance)
  (:root :f -0.1 :u 0.08 :pitch 7) (:spine :flex 16) (:head :flex 16) (:arm-r :flex 21.4 :side 11) (:elbow-r :flex 12)
  (:arm-l :flex 21.4 :side 11) (:elbow-l :flex 12) (:thigh-r :flex -4) (:thigh-l :flex -4))
(defclip :lb-w-judge-volley (0.1 :loop t :base :lb-w-ring-pose)   ; beat 4: the volley's recoils, 6 f a cycle
  (0 (:root :f -0.16 :u 0.32 :pitch -5) (:spine :flex -8)) (0.05 (:root :f -0.27 :u 0.33 :pitch -8) (:spine :flex -12)))
(defstrike :lb-w-sanren (12 22 24 :base :lb-w-stance)
  ;; KIN SP1 三連: thrusts f12 the right wing, f22 the left, f32 both; each kicks the column back
  (0)
  ;; R 135/18, L -95/-8
  (5 (:root :f -0.08 :u -0.02 :yaw -10) (:spine :flex -4) (:chest :twist -20) (:arm-r :flex -42.3 :side 114.7)
   (:elbow-r :flex 30) (:arm-l :flex -5 :side 82) (:elbow-l :flex 8) (:thigh-r :flex -12) (:thigh-l :flex 14))
  ;; R 148/24, L -98/-10
  (9 (:root :f -0.12 :u -0.04 :yaw -14) (:spine :flex -6) (:chest :twist -26) (:arm-r :flex -50.8 :side 130)
   (:elbow-r :flex 36) (:arm-l :flex -7.9 :side 79.9) (:elbow-l :flex 8) (:thigh-r :flex -14) (:thigh-l :flex 16))
  ;; R 30/-2, L -104/-12
  (:s :snap (:root :f 0.14 :u -0.06 :yaw 12) (:spine :flex 10) (:chest :twist 18) (:arm-r :flex 59.9 :side 86)
   (:elbow-r :flex 2) (:arm-l :flex -13.7 :side 77.6) (:elbow-l :flex 6) (:thigh-r :flex 24) (:thigh-l :flex -16))
  ;; R 36/16, L -104/-12
  (14 (:root :f -0.12 :u -0.02 :yaw 10) (:spine :flex -4) (:chest :twist 14) (:head :flex -2) (:arm-r :flex 51 :side 116)
   (:elbow-r :flex 12) (:arm-l :flex -13.7 :side 77.6) (:elbow-l :flex 6) (:thigh-r :flex 16) (:thigh-l :flex -10))
  ;; R 56/8, L -104/-12
  (16 (:root :f -0.14 :u -0.02 :yaw 4) (:spine :flex -4) (:chest :twist 8) (:head :flex 4) (:arm-r :flex 33.6 :side 99.6)
   (:elbow-r :flex 16) (:arm-l :flex -13.7 :side 77.6) (:elbow-l :flex 6) (:thigh-r :flex 10) (:thigh-l :flex -6))
  ;; R 98/-10, L -148/24
  (19 (:root :f -0.12 :u -0.04 :yaw 14) (:spine :flex -6) (:chest :twist 26) (:head :flex 4)
   (:arm-r :flex -7.9 :side 79.9) (:elbow-r :flex 10) (:arm-l :flex -50.8 :side 130) (:elbow-l :flex 36)
   (:thigh-r :flex -14) (:thigh-l :flex 16))
  ;; R 104/-12, L -30/-2
  (22 :snap (:root :f 0.14 :u -0.06 :yaw -12) (:spine :flex 10) (:chest :twist -18) (:head :flex 4)
   (:arm-r :flex -13.7 :side 77.6) (:elbow-r :flex 6) (:arm-l :flex 59.9 :side 86) (:elbow-l :flex 2)
   (:thigh-r :flex -16) (:thigh-l :flex 24))
  ;; R 104/-12, L -36/16
  (24 (:root :f -0.12 :u -0.02 :yaw -10) (:spine :flex -4) (:chest :twist -14) (:head :flex -2)
   (:arm-r :flex -13.7 :side 77.6) (:elbow-r :flex 6) (:arm-l :flex 51 :side 116) (:elbow-l :flex 12)
   (:thigh-r :flex -10) (:thigh-l :flex 16))
  ;; R 104/-12, L -56/8
  (26 (:root :f -0.14 :u -0.02 :yaw -4) (:spine :flex -4) (:chest :twist -8) (:head :flex 4)
   (:arm-r :flex -13.7 :side 77.6) (:elbow-r :flex 6) (:arm-l :flex 33.6 :side 99.6) (:elbow-l :flex 16)
   (:thigh-r :flex -6) (:thigh-l :flex 10))
  ;; R 140/30, L -140/30
  (29 (:root :f -0.18 :u 0.06 :pitch -6 :yaw 0) (:spine :flex -10) (:chest :twist 0) (:head :flex -4)
   (:arm-r :flex -41.6 :side 131.9) (:elbow-r :flex 34) (:arm-l :flex -41.6 :side 131.9) (:elbow-l :flex 34)
   (:thigh-r :flex -10) (:thigh-l :flex 10))
  ;; R 5/-3, L -5/-3
  (32 :snap (:root :f 0.2 :u -0.08 :pitch 4 :yaw 0) (:spine :flex 14) (:chest :twist 0) (:head :flex 4)
   (:arm-r :flex 84.2 :side 59) (:elbow-r :flex 2) (:arm-l :flex 84.2 :side 59) (:elbow-l :flex 2) (:thigh-r :flex 22)
   (:thigh-l :flex -18))
  ;; R 14/20, L -14/20
  (:a (:root :f -0.32 :u -0.02 :pitch -9 :yaw 0) (:spine :flex -12) (:chest :twist 0) (:head :flex -8)
   (:arm-r :flex 65.8 :side 146.4) (:elbow-r :flex 12) (:arm-l :flex 65.8 :side 146.4) (:elbow-l :flex 12)
   (:thigh-r :flex 8) (:thigh-l :flex -6))
  ;; R 32/10, L -32/10
  (40 (:root :f -0.38 :u -0.03 :pitch -6 :yaw 0) (:spine :flex -8) (:chest :twist 0) (:head :flex -2)
   (:arm-r :flex 56.6 :side 108.4) (:elbow-r :flex 16) (:arm-l :flex 56.6 :side 108.4) (:elbow-l :flex 16)
   (:thigh-r :flex 8) (:thigh-l :flex -6))
  ;; R 64/-8, L -64/-8
  (48 (:root :f -0.2 :u -0.02 :pitch -2 :yaw 0) (:spine :flex -2) (:chest :twist 0) (:head :flex 4)
   (:arm-r :flex 25.7 :side 81.1) (:elbow-r :flex 12) (:arm-l :flex 25.7 :side 81.1) (:elbow-l :flex 12)
   (:thigh-r :flex 4) (:thigh-l :flex -2))
  (:end :lb-w-stance))
(defstrike :lb-e-sanren (6 14 12 :base :lb-w-stance)
  ;; EN SP1 三連: the lines f6 the right wing, f12 the left, f18 both, each a thrust and a kick back
  (0)
  ;; R 140/22, L -95/-8
  (3 (:root :f -0.08 :u 0.04 :pitch -4 :yaw -12) (:spine :flex -6) (:chest :twist -22) (:arm-r :flex -45.3 :side 122.2)
   (:elbow-r :flex 32) (:arm-l :flex -5 :side 82) (:elbow-l :flex 8))
  ;; R 30/-2, L -104/-12
  (:s :snap (:root :f 0.14 :u -0.03 :pitch 4 :yaw 12) (:spine :flex 10) (:chest :twist 18) (:arm-r :flex 59.9 :side 86)
   (:elbow-r :flex 2) (:arm-l :flex -13.7 :side 77.6) (:elbow-l :flex 6))
  ;; R 38/16, L -104/-12
  (8 (:root :f -0.14 :u 0.02 :pitch -5 :yaw 10) (:spine :flex -5) (:chest :twist 14) (:head :flex -2)
   (:arm-r :flex 49.2 :side 115) (:elbow-r :flex 12) (:arm-l :flex -13.7 :side 77.6) (:elbow-l :flex 6))
  ;; R 98/-10, L -140/22
  (10 (:root :f -0.1 :u 0.04 :pitch -4 :yaw 12) (:spine :flex -6) (:chest :twist 22) (:head :flex 4)
   (:arm-r :flex -7.9 :side 79.9) (:elbow-r :flex 10) (:arm-l :flex -45.3 :side 122.2) (:elbow-l :flex 32))
  ;; R 104/-12, L -30/-2
  (12 :snap (:root :f 0.14 :u -0.03 :pitch 4 :yaw -12) (:spine :flex 10) (:chest :twist -18) (:head :flex 4)
   (:arm-r :flex -13.7 :side 77.6) (:elbow-r :flex 6) (:arm-l :flex 59.9 :side 86) (:elbow-l :flex 2))
  ;; R 104/-12, L -38/16
  (14 (:root :f -0.14 :u 0.02 :pitch -5 :yaw -10) (:spine :flex -5) (:chest :twist -14) (:head :flex -2)
   (:arm-r :flex -13.7 :side 77.6) (:elbow-r :flex 6) (:arm-l :flex 49.2 :side 115) (:elbow-l :flex 12))
  ;; R 138/30, L -138/30
  (16 (:root :f -0.14 :u 0.08 :pitch -6 :yaw 0) (:spine :flex -10) (:chest :twist 0) (:head :flex -4)
   (:arm-r :flex -40.1 :side 130.8) (:elbow-r :flex 32) (:arm-l :flex -40.1 :side 130.8) (:elbow-l :flex 32))
  ;; R 5/-3, L -5/-3
  (18 :snap (:root :f 0.18 :u -0.04 :pitch 6 :yaw 0) (:spine :flex 14) (:chest :twist 0) (:head :flex 4)
   (:arm-r :flex 84.2 :side 59) (:elbow-r :flex 2) (:arm-l :flex 84.2 :side 59) (:elbow-l :flex 2))
  ;; R 14/20, L -14/20
  (:a (:root :f -0.32 :u 0.05 :pitch -10 :yaw 0) (:spine :flex -12) (:chest :twist 0) (:head :flex -8)
   (:arm-r :flex 65.8 :side 146.4) (:elbow-r :flex 12) (:arm-l :flex 65.8 :side 146.4) (:elbow-l :flex 12))
  ;; R 42/6, L -42/6
  (25 (:root :f -0.3 :u 0.03 :pitch -6 :yaw 0) (:spine :flex -6) (:chest :twist 0) (:head :flex 0)
   (:arm-r :flex 47.7 :side 98.9) (:elbow-r :flex 14) (:arm-l :flex 47.7 :side 98.9) (:elbow-l :flex 14))
  (:end :lb-w-stance))
(defstrike :lb-w-nijushi (40 6 30 :base :lb-w-stance)
  ;; SP2 二十四孔: rising, the wings opened into a ring, the bow drawn (shaking), the recoil, blown back
  (0)
  ;; R 84/8, L -84/8
  (8 (:root :f -0.02 :u 0.16) (:spine :flex -2) (:head :flex 2) (:arm-r :flex 5.9 :side 98) (:elbow-r :flex 12)
   (:arm-l :flex 5.9 :side 98) (:elbow-l :flex 12) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 75/-22, L -75/-22
  (16 (:root :f -0.04 :r 0 :u 0.3 :pitch -1) (:spine :flex -4) (:head :flex 0) (:arm-r :flex 13.9 :side 67.3)
   (:elbow-r :flex 4) (:arm-l :flex 13.9 :side 67.3) (:elbow-l :flex 4) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 75/-22, L -75/-22
  (20 (:root :f -0.06 :r 0.008 :u 0.3 :pitch -2) (:spine :flex -6) (:head :flex 0) (:arm-r :flex 13.9 :side 67.3)
   (:elbow-r :flex 4) (:arm-l :flex 13.9 :side 67.3) (:elbow-l :flex 4) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 75.8/-22.4, L -75.8/-22.4
  (22 (:root :f -0.076 :r -0.008 :u 0.3 :pitch -2.556) (:spine :flex -7) (:head :flex 0) (:arm-r :flex 13.1 :side 66.9)
   (:elbow-r :flex 4.7) (:arm-l :flex 13.1 :side 66.9) (:elbow-l :flex 4.7) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 76.6/-22.9, L -76.6/-22.9
  (24 (:root :f -0.091 :r 0.01 :u 0.3 :pitch -3.111) (:spine :flex -8) (:head :flex 0) (:arm-r :flex 12.4 :side 66.5)
   (:elbow-r :flex 5.3) (:arm-l :flex 12.4 :side 66.5) (:elbow-l :flex 5.3) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 77.3/-23.3, L -77.3/-23.3
  (26 (:root :f -0.107 :r -0.012 :u 0.3 :pitch -3.667) (:spine :flex -9) (:head :flex 0) (:arm-r :flex 11.6 :side 66.1)
   (:elbow-r :flex 6) (:arm-l :flex 11.6 :side 66.1) (:elbow-l :flex 6) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 78.1/-23.8, L -78.1/-23.8
  (28 (:root :f -0.122 :r 0.014 :u 0.3 :pitch -4.222) (:spine :flex -10) (:head :flex 0) (:arm-r :flex 10.9 :side 65.8)
   (:elbow-r :flex 6.7) (:arm-l :flex 10.9 :side 65.8) (:elbow-l :flex 6.7) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 78.9/-24.2, L -78.9/-24.2
  (30 (:root :f -0.138 :r -0.018 :u 0.3 :pitch -4.778) (:spine :flex -11) (:head :flex 0) (:arm-r :flex 10.1 :side 65.4)
   (:elbow-r :flex 7.3) (:arm-l :flex 10.1 :side 65.4) (:elbow-l :flex 7.3) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 79.7/-24.7, L -79.7/-24.7
  (32 (:root :f -0.153 :r 0.022 :u 0.3 :pitch -5.333) (:spine :flex -12) (:head :flex 0) (:arm-r :flex 9.4 :side 65)
   (:elbow-r :flex 8) (:arm-l :flex 9.4 :side 65) (:elbow-l :flex 8) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 80.4/-25.1, L -80.4/-25.1
  (34 (:root :f -0.169 :r -0.027 :u 0.3 :pitch -5.889) (:spine :flex -13) (:head :flex 0) (:arm-r :flex 8.6 :side 64.6)
   (:elbow-r :flex 8.7) (:arm-l :flex 8.6 :side 64.6) (:elbow-l :flex 8.7) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 81.2/-25.6, L -81.2/-25.6
  (36 (:root :f -0.184 :r 0.033 :u 0.3 :pitch -6.444) (:spine :flex -14) (:head :flex 0) (:arm-r :flex 7.9 :side 64.2)
   (:elbow-r :flex 9.3) (:arm-l :flex 7.9 :side 64.2) (:elbow-l :flex 9.3) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 82/-26, L -82/-26
  (38 (:root :f -0.2 :r -0.04 :u 0.3 :pitch -7) (:spine :flex -15) (:head :flex 0) (:arm-r :flex 7.2 :side 63.8)
   (:elbow-r :flex 10) (:arm-l :flex 7.2 :side 63.8) (:elbow-l :flex 10) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 118/-4, L -118/-4
  (:s :snap (:root :f -0.62 :r 0 :u 0.38 :pitch -14) (:spine :flex -20) (:head :flex -10) (:arm-r :flex -27.9 :side 85.5)
   (:elbow-r :flex 22) (:arm-l :flex -27.9 :side 85.5) (:elbow-l :flex 22) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 126/4, L -126/4
  (:a (:root :f -0.7 :r 0 :u 0.4 :pitch -15) (:spine :flex -22) (:head :flex -10) (:arm-r :flex -35.9 :side 94.9)
   (:elbow-r :flex 28) (:arm-l :flex -35.9 :side 94.9) (:elbow-l :flex 28) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 106/-12, L -106/-12
  (56 (:root :f -0.48 :r 0 :u 0.26 :pitch -8) (:spine :flex -10) (:head :flex -4) (:arm-r :flex -15.6 :side 77.5)
   (:elbow-r :flex 16) (:arm-l :flex -15.6 :side 77.5) (:elbow-l :flex 16) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 92/-14, L -92/-14
  (66 (:root :f -0.2 :r 0 :u 0.1 :pitch -3) (:spine :flex -4) (:head :flex 2) (:arm-r :flex -1.9 :side 76)
   (:elbow-r :flex 10) (:arm-l :flex -1.9 :side 76) (:elbow-l :flex 10) (:thigh-r :flex -2) (:thigh-l :flex -2))
  (:end :lb-w-stance))
(defstrike :lb-w-kikon (8 0 0 :base :lb-w-stance)
  ;; Kikon 神の裁き, the aura (8 f): rising, the wings swinging up toward the ring
  (0)
  (:end :lb-w-ring-in))
(defstrike :lb-w-kikon-fire (20 3 30 :base :lb-w-stance)
  ;; Kikon 神の裁き, the strike: the ring charged (shaking), the 24 lines on S with a recoil, the wings closed down (the verdict)
  (0 :lb-w-ring-in)
  ;; R 75/-22, L -75/-22
  (7 (:root :f -0.04 :r 0 :u 0.3 :pitch -1) (:spine :flex -4) (:head :flex 0) (:arm-r :flex 13.9 :side 67.3)
   (:elbow-r :flex 4) (:arm-l :flex 13.9 :side 67.3) (:elbow-l :flex 4))
  ;; R 75/-22, L -75/-22
  (10 (:root :f -0.07 :r 0.012 :u 0.3 :pitch -3) (:spine :flex -7) (:head :flex 0) (:arm-r :flex 13.9 :side 67.3)
   (:elbow-r :flex 4) (:arm-l :flex 13.9 :side 67.3) (:elbow-l :flex 4))
  ;; R 76.2/-22.8, L -76.2/-22.8
  (12 (:root :f -0.095 :r -0.013 :u 0.3 :pitch -3.75) (:spine :flex -8.5) (:head :flex 0) (:arm-r :flex 12.7 :side 66.6)
   (:elbow-r :flex 5) (:arm-l :flex 12.7 :side 66.6) (:elbow-l :flex 5))
  ;; R 77.5/-23.5, L -77.5/-23.5
  (14 (:root :f -0.12 :r 0.018 :u 0.3 :pitch -4.5) (:spine :flex -10) (:head :flex 0) (:arm-r :flex 11.4 :side 66)
   (:elbow-r :flex 6) (:arm-l :flex 11.4 :side 66) (:elbow-l :flex 6))
  ;; R 78.8/-24.2, L -78.8/-24.2
  (16 (:root :f -0.145 :r -0.025 :u 0.3 :pitch -5.25) (:spine :flex -11.5) (:head :flex 0) (:arm-r :flex 10.2 :side 65.3)
   (:elbow-r :flex 7) (:arm-l :flex 10.2 :side 65.3) (:elbow-l :flex 7))
  ;; R 80/-25, L -80/-25
  (18 (:root :f -0.17 :r 0.036 :u 0.3 :pitch -6) (:spine :flex -13) (:head :flex 0) (:arm-r :flex 9.1 :side 64.7)
   (:elbow-r :flex 8) (:arm-l :flex 9.1 :side 64.7) (:elbow-l :flex 8))
  ;; R 118/-4, L -118/-4
  (:s :snap (:root :f -0.55 :r 0 :u 0.36 :pitch -13) (:spine :flex -18) (:head :flex -8) (:arm-r :flex -27.9 :side 85.5)
   (:elbow-r :flex 22) (:arm-l :flex -27.9 :side 85.5) (:elbow-l :flex 22))
  ;; R 124/2, L -124/2
  (:a (:root :f -0.62 :r 0 :u 0.38 :pitch -14) (:spine :flex -20) (:head :flex -8) (:arm-r :flex -34 :side 92.4)
   (:elbow-r :flex 26) (:arm-l :flex -34 :side 92.4) (:elbow-l :flex 26))
  ;; R 28/-62, L -28/-62
  (30 (:root :f -0.36 :r 0 :u 0.16 :pitch 6) (:spine :flex 14) (:head :flex 14) (:arm-r :flex 24.5 :side 14)
   (:elbow-r :flex 12) (:arm-l :flex 24.5 :side 14) (:elbow-l :flex 12))
  ;; R 24/-66, L -24/-66
  (40 (:root :f -0.3 :r 0 :u 0.1 :pitch 7) (:spine :flex 16) (:head :flex 16) (:arm-r :flex 21.8 :side 10.3)
   (:elbow-r :flex 12) (:arm-l :flex 21.8 :side 10.3) (:elbow-l :flex 12))
  (:end :lb-w-stance))
(defstrike :lb-w-judge-open (24 0 64 :base :lb-w-stance)
  ;; the Kikon cinematic, beat 1 (decision 56, Amendment 2): the wings gathered round the column and shaking harder
  ;; (f4-22, a side jolt every 2 f), snapped open into the ring on f24 (S), held; beat 2: the charge's jolts (f60-86)
  (0)
  (4 :lb-w-fold-pose (:root :u 0.06) (:spine :flex 6) (:head :flex 12))
  (6 :lb-w-fold-pose (:root :u 0.06 :r 0.006) (:spine :flex 6) (:head :flex 12))
  (8 :lb-w-fold-pose (:root :u 0.065 :r -0.006) (:spine :flex 6.375) (:head :flex 12))
  (10 :lb-w-fold-pose (:root :u 0.07 :r 0.008) (:spine :flex 6.75) (:head :flex 12))
  (12 :lb-w-fold-pose (:root :u 0.075 :r -0.01) (:spine :flex 7.125) (:head :flex 12))
  (14 :lb-w-fold-pose (:root :u 0.08 :r 0.013) (:spine :flex 7.5) (:head :flex 12))
  (16 :lb-w-fold-pose (:root :u 0.085 :r -0.016) (:spine :flex 7.875) (:head :flex 12))
  (18 :lb-w-fold-pose (:root :u 0.09 :r 0.021) (:spine :flex 8.25) (:head :flex 12))
  (20 :lb-w-fold-pose (:root :u 0.095 :r -0.026) (:spine :flex 8.625) (:head :flex 12))
  (22 :lb-w-fold-pose (:root :u 0.1 :r 0.032) (:spine :flex 9) (:head :flex 12))
  (:s :snap :lb-w-ring-pose)
  (58 :lb-w-ring-pose)
  (60 :lb-w-ring-pose (:root :f -0.04 :r 0.006 :u 0.3 :pitch -1) (:spine :flex -4))
  (62 :lb-w-ring-pose (:root :f -0.049 :r -0.006 :u 0.3 :pitch -1.385) (:spine :flex -4.615))
  (64 :lb-w-ring-pose (:root :f -0.058 :r 0.007 :u 0.3 :pitch -1.769) (:spine :flex -5.231))
  (66 :lb-w-ring-pose (:root :f -0.068 :r -0.007 :u 0.3 :pitch -2.154) (:spine :flex -5.846))
  (68 :lb-w-ring-pose (:root :f -0.077 :r 0.008 :u 0.3 :pitch -2.538) (:spine :flex -6.462))
  (70 :lb-w-ring-pose (:root :f -0.086 :r -0.01 :u 0.3 :pitch -2.923) (:spine :flex -7.077))
  (72 :lb-w-ring-pose (:root :f -0.095 :r 0.011 :u 0.3 :pitch -3.308) (:spine :flex -7.692))
  (74 :lb-w-ring-pose (:root :f -0.105 :r -0.013 :u 0.3 :pitch -3.692) (:spine :flex -8.308))
  (76 :lb-w-ring-pose (:root :f -0.114 :r 0.015 :u 0.3 :pitch -4.077) (:spine :flex -8.923))
  (78 :lb-w-ring-pose (:root :f -0.123 :r -0.018 :u 0.3 :pitch -4.462) (:spine :flex -9.538))
  (80 :lb-w-ring-pose (:root :f -0.132 :r 0.02 :u 0.3 :pitch -4.846) (:spine :flex -10.154))
  (82 :lb-w-ring-pose (:root :f -0.142 :r -0.023 :u 0.3 :pitch -5.231) (:spine :flex -10.769))
  (84 :lb-w-ring-pose (:root :f -0.151 :r 0.026 :u 0.3 :pitch -5.615) (:spine :flex -11.385))
  (86 :lb-w-ring-pose (:root :f -0.16 :r -0.03 :u 0.3 :pitch -6) (:spine :flex -12))
  (:end :lb-w-ring-pose))
(defstrike :lb-w-judge-shot (2 0 14 :base :lb-w-ring-pose)
  ;; the Kikon cinematic, beat 3: a shot's recoil out of the ring, back into it
  ;; R 112/-6, L -112/-6
  (0 (:root :f -0.42 :u 0.34 :pitch -10) (:spine :flex -14) (:head :flex -6) (:arm-r :flex -21.9 :side 83.5)
   (:elbow-r :flex 18) (:arm-l :flex -21.9 :side 83.5) (:elbow-l :flex 18) (:thigh-r :flex -6) (:thigh-l :flex -6))
  ;; R 118/-2, L -118/-2
  (2 (:root :f -0.48 :u 0.35 :pitch -11) (:spine :flex -16) (:head :flex -6) (:arm-r :flex -28 :side 87.7)
   (:elbow-r :flex 22) (:arm-l :flex -28 :side 87.7) (:elbow-l :flex 22) (:thigh-r :flex -6) (:thigh-l :flex -6))
  (:end :lb-w-ring-pose))
(defstrike :lb-w-judge-close (6 0 40 :base :lb-w-ring-pose)
  ;; the Kikon cinematic, beat 6: the verdict, the wings closed down before him (on f6)
  (0)
  ;; R 26/-66, L -26/-66
  (6 :snap (:root :f -0.1 :u 0.08 :pitch 7) (:spine :flex 16) (:head :flex 16) (:arm-r :flex 21.4 :side 11)
   (:elbow-r :flex 12) (:arm-l :flex 21.4 :side 11) (:elbow-l :flex 12) (:thigh-r :flex -4) (:thigh-l :flex -4))
  (:end :lb-w-verdict-pose))
(defclip :lb-w-breaker (0.4 :loop t :base :lb-w-stance)
  (0 (:root :u -0.2 :pitch 14) (:arm-r :flex -30 :side 40) (:arm-l :flex -30 :side 40))
   (0.2 (:root :u -0.16 :pitch 14)))
(defpose :lb-w-ram-hit (:base :lb-w-stance)
  (:root :f 0.0 :u -0.1) (:spine :flex 4) (:arm-r :flex 66 :side 52) (:elbow-r :flex 24) (:arm-l :flex 66 :side 52)
   (:elbow-l :flex 24))
(defstrike :lb-w-ram (8 4 18 :base :lb-w-stance)
  (0 (:arm-r :flex 10 :side 120) (:arm-l :flex 10 :side 120)) (:s :snap :lb-w-ram-hit) (:a :lb-w-ram-hit)
   (:end :lb-w-stance))

;;; ---------------------------------------------------------------- the owl
;;; 近 KIN (decision 38, 2026-10-06: 「近戰模式翼往後收、身體前傾」): on the ㄇ stilts, the column pitched forward (the spine,
;;; so the hips and the legs stay square), the S-neck lowered and thrust forward like a stalking bird, the long arms raised
;;; forward with the claws up (the wings swept back: LILLE-DRAW). The claws (the hands) strike at the moves' reach: the
;;; strike keys set every channel they move themselves, so the stance moves no strike point (FK test).
(defpose :lb-o-stance ()
  (:root :u -0.02) (:spine :flex 22) (:neck :flex 26) (:head :flex 8)
  (:arm-r :flex 58 :side 14) (:elbow-r :flex 70) (:arm-l :flex 58 :side 14) (:elbow-l :flex 70)
  (:thigh-r :flex 0 :side 5) (:thigh-l :flex 0 :side 5) (:knees :flex 0))   ; (the ㄇ legs stand square: decision 26)
(defclip :lb-o-stance (2.4 :loop t :base :lb-o-stance)
  (0) (1.2 (:root :u -0.04) (:spine :flex 24) (:head :flex 14 :twist 10) (:arm-r :flex 64) (:arm-l :flex 52)))
;; Decision 56 (2026-10-08, DUEL_LILLE §23.37: 「猛禽爪擊」「全身出招」): each J / K is a raptor's claw strike of the whole body,
;; a clear wind-up -> strike -> recovery: the ㄇ legs step or lunge (the thighs; the shanks keep their feet on the floor), the
;; column leans and twists, the S-neck (:neck / :head) strikes with it, the hands (:hand-r / -l) open back in the wind-up and
;; hook in the strike. The arms were solved to world targets for the claws (the comment above each key: right / up /
;; forward in m from where he stands, e = the elbow), so the hit pose (S through S + A) puts the striking claw at the move's
;; reach (the host FK test). KIN's EN twins are their own casts below (:lb-oe-q1 ..).
(defstrike :lb-o-q1 (8 3 12 :base :lb-o-stance)   ; J1 右爪撕: reared up, the right claw cocked high, a step in: raked down across, high right -> low left
  (0)
  ;; R (0.45 2.3 0.35) e119, L (-0.1 1.55 0.95) e85
  (3 (:root :f -0.06 :u 0.02 :yaw -6 :pitch -2) (:spine :flex 14) (:chest :twist -14) (:neck :flex 14)
   (:head :flex -4) (:arm-r :flex 88.7 :side -11.4) (:elbow-r :flex 119.2) (:hand-r :flex -20)
   (:arm-l :flex 35.5 :side 53.2) (:elbow-l :flex 85.4) (:hand-l :flex 10) (:thigh-r :flex -6) (:thigh-l :flex 8))
  ;; R (0.62 2.72 -0.05) e79, L (-0.05 1.6 0.85) e89
  (6 (:root :f -0.14 :u 0.04 :yaw -12 :pitch -4) (:spine :flex 8) (:chest :twist -26) (:neck :flex 2)
   (:head :flex -14) (:arm-r :flex 118.3 :side -17.9) (:elbow-r :flex 79.2) (:hand-r :flex -40)
   (:arm-l :flex 17.3 :side 60.3) (:elbow-l :flex 89.3) (:hand-l :flex 10) (:thigh-r :flex -12) (:thigh-l :flex 14))
  ;; R (0.3 1.5 1.66) e71, L (-0.35 1.45 0.4) e148 MISS 0.04
  (:s :snap (:root :f 0.4 :u -0.06 :yaw 6 :pitch 4) (:spine :flex 30) (:chest :twist 14) (:neck :flex 34)
   (:head :flex 12) (:arm-r :flex 93 :side -50.8) (:elbow-r :flex 70.8) (:hand-r :flex 30)
   (:arm-l :flex -44 :side 16.4) (:elbow-l :flex 148.1) (:hand-l :flex 10) (:thigh-r :flex 32) (:thigh-l :flex -20))
  ;; R (-0.12 1.12 1.66) e68, L (-0.45 1.35 0.25) e130
  (:a (:root :f 0.46 :u -0.07 :yaw 12 :pitch 5) (:spine :flex 33) (:chest :twist 24) (:neck :flex 36)
   (:head :flex 14) (:arm-r :flex 84.3 :side -72.9) (:elbow-r :flex 68.5) (:hand-r :flex 50)
   (:arm-l :flex -46.9 :side 17.5) (:elbow-l :flex 130) (:hand-l :flex 10) (:thigh-r :flex 32) (:thigh-l :flex -20))
  ;; R (-0.6 0.72 1.15) e47 MISS 0.04, L (-0.4 1.3 0.3) e134
  (16 (:root :f 0.38 :u -0.08 :yaw 18 :pitch 5) (:spine :flex 34) (:chest :twist 30) (:neck :flex 30)
   (:head :flex 10) (:arm-r :flex 86.6 :side -149.4) (:elbow-r :flex 47.3) (:hand-r :flex 50)
   (:arm-l :flex -33.7 :side -1.1) (:elbow-l :flex 134.5) (:hand-l :flex 10) (:thigh-r :flex 26) (:thigh-l :flex -16))
  (:end :lb-o-stance))
(defstrike :lb-o-q2 (7 3 13 :base :lb-o-stance)   ; J2 左爪撕: the mirror, the left claw, high left -> low right
  (0)
  ;; L (-0.45 2.3 0.35) e119, R (0.1 1.55 0.95) e85
  (3 (:root :f -0.06 :u 0.02 :yaw 6 :pitch -2) (:spine :flex 14) (:chest :twist 14) (:neck :flex 14) (:head :flex -4)
   (:arm-r :flex 35.5 :side 53.2) (:elbow-r :flex 85.4) (:hand-r :flex 10) (:arm-l :flex 88.7 :side -11.4)
   (:elbow-l :flex 119.2) (:hand-l :flex -20) (:thigh-r :flex 8) (:thigh-l :flex -6))
  ;; L (-0.62 2.72 -0.05) e79, R (0.05 1.6 0.85) e89
  (5 (:root :f -0.14 :u 0.04 :yaw 12 :pitch -4) (:spine :flex 8) (:chest :twist 26) (:neck :flex 2) (:head :flex -14)
   (:arm-r :flex 17.3 :side 60.3) (:elbow-r :flex 89.3) (:hand-r :flex 10) (:arm-l :flex 118.3 :side -17.9)
   (:elbow-l :flex 79.2) (:hand-l :flex -40) (:thigh-r :flex 14) (:thigh-l :flex -12))
  ;; L (-0.3 1.5 1.66) e71, R (0.35 1.45 0.4) e148 MISS 0.04
  (:s :snap (:root :f 0.4 :u -0.06 :yaw -6 :pitch 4) (:spine :flex 30) (:chest :twist -14) (:neck :flex 34)
   (:head :flex 12) (:arm-r :flex -44 :side 16.4) (:elbow-r :flex 148.1) (:hand-r :flex 10)
   (:arm-l :flex 93 :side -50.8) (:elbow-l :flex 70.8) (:hand-l :flex 30) (:thigh-r :flex -20) (:thigh-l :flex 32))
  ;; L (0.12 1.12 1.66) e68, R (0.45 1.35 0.25) e130
  (:a (:root :f 0.46 :u -0.07 :yaw -12 :pitch 5) (:spine :flex 33) (:chest :twist -24) (:neck :flex 36)
   (:head :flex 14) (:arm-r :flex -46.9 :side 17.5) (:elbow-r :flex 130) (:hand-r :flex 10)
   (:arm-l :flex 84.3 :side -72.9) (:elbow-l :flex 68.5) (:hand-l :flex 50) (:thigh-r :flex -20) (:thigh-l :flex 32))
  ;; L (0.6 0.72 1.15) e47 MISS 0.04, R (0.4 1.3 0.3) e134
  (15 (:root :f 0.38 :u -0.08 :yaw -18 :pitch 5) (:spine :flex 34) (:chest :twist -30) (:neck :flex 30)
   (:head :flex 10) (:arm-r :flex -33.7 :side -1.1) (:elbow-r :flex 134.5) (:hand-r :flex 10)
   (:arm-l :flex 86.6 :side -149.4) (:elbow-l :flex 47.3) (:hand-l :flex 50) (:thigh-r :flex -16) (:thigh-l :flex 26))
  (:end :lb-o-stance))
(defstrike :lb-o-q3 (9 3 18 :base :lb-o-stance)   ; J3 雙爪剪: both claws spread high and wide, the neck coiled back, then scissored across with a peck
  (0)
  ;; R (0.85 2 0.3) e112, L (-0.85 2 0.3) e112
  (3 (:root :f -0.04 :u 0.04 :pitch -3) (:spine :flex 12) (:neck :flex 4) (:head :flex -10)
   (:arm-r :flex 105 :side -74.2) (:elbow-r :flex 112.2) (:hand-r :flex -20) (:arm-l :flex 105 :side -74.2)
   (:elbow-l :flex 112.2) (:hand-l :flex -20) (:thigh-r :flex -4) (:thigh-l :flex 4))
  ;; R (1.05 2.15 0.2) e87, L (-1.05 2.15 0.2) e87
  (7 (:root :f -0.1 :u 0.07 :pitch -6) (:spine :flex 6) (:neck :flex -12) (:head :flex -22)
   (:arm-r :flex 119.6 :side -74.8) (:elbow-r :flex 86.6) (:hand-r :flex -40) (:arm-l :flex 119.6 :side -74.8)
   (:elbow-l :flex 86.6) (:hand-l :flex -40) (:thigh-r :flex -8) (:thigh-l :flex 8))
  ;; R (-0.08 1.5 1.7) e51, L (0.14 1.62 1.66) e58
  (:s :snap (:root :f 0.42 :u -0.05 :pitch 5) (:spine :flex 30) (:neck :flex 50) (:head :flex 26)
   (:arm-r :flex 39.8 :side -141.6) (:elbow-r :flex 50.7) (:hand-r :flex 30) (:arm-l :flex 29.4 :side -141.9)
   (:elbow-l :flex 58.5) (:hand-l :flex 30) (:thigh-r :flex 28) (:thigh-l :flex -20))
  ;; R (-0.42 1.3 1.62) e32, L (0.42 1.42 1.6) e47
  (:a (:root :f 0.46 :u -0.06 :pitch 6) (:spine :flex 32) (:neck :flex 56) (:head :flex 30)
   (:arm-r :flex 40 :side -111.4) (:elbow-r :flex 32.5) (:hand-r :flex 50) (:arm-l :flex 29.4 :side -117.4)
   (:elbow-l :flex 46.7) (:hand-l :flex 50) (:thigh-r :flex 28) (:thigh-l :flex -20))
  ;; R (-0.75 0.9 1.05) e4 MISS 0.08, L (0.75 1 1.05) e4
  (20 (:root :f 0.36 :u -0.08 :pitch 5) (:spine :flex 34) (:neck :flex 30) (:head :flex 12)
   (:arm-r :flex 38 :side -71.6) (:elbow-r :flex 4) (:hand-r :flex 40) (:arm-l :flex 36.4 :side -75.8)
   (:elbow-l :flex 4) (:hand-l :flex 40) (:thigh-r :flex 22) (:thigh-l :flex -16))
  (:end :lb-o-stance))
(defstrike :lb-o-f1 (17 4 21 :base :lb-o-stance)   ; K1 掠爪: a wing beat, coiled low, a low glide, the right claw hooked wide across (right -> left)
  (0)
  ;; R (0.8 1.45 -0.55) e94, L (-0.15 1.35 0.8) e114 MISS 0.05
  (4 (:root :f -0.1 :u -0.1 :yaw -10 :pitch 4) (:spine :flex 30) (:chest :twist -16) (:neck :flex 20) (:head :flex 0)
   (:arm-r :flex -44.4 :side 55) (:elbow-r :flex 93.6) (:hand-r :flex -20) (:arm-l :flex 60.5 :side -62)
   (:elbow-l :flex 114.2) (:hand-l :flex 10) (:thigh-r :flex -10) (:thigh-l :flex 18))
  ;; R (1.05 1.5 -0.45) e78, L (-0.25 1.3 0.7) e127
  (10 (:root :f -0.16 :u -0.14 :yaw -22 :pitch 6) (:spine :flex 34) (:chest :twist -30) (:neck :flex 16)
   (:head :flex -4) (:arm-r :flex -1 :side 77.4) (:elbow-r :flex 78.4) (:hand-r :flex -40)
   (:arm-l :flex 94.5 :side -83.1) (:elbow-l :flex 127.4) (:hand-l :flex 10) (:thigh-r :flex -16) (:thigh-l :flex 22))
  ;; R (1.2 1.35 0.6) e87, L (-0.35 1.2 0.9) e137
  (14 (:root :f 0.35 :u -0.16 :yaw -14 :pitch 8) (:spine :flex 44) (:chest :twist -24) (:neck :flex 24)
   (:head :flex 6) (:arm-r :flex 8.6 :side 94.6) (:elbow-r :flex 87.3) (:hand-r :flex -20)
   (:arm-l :flex 104.9 :side -102.6) (:elbow-l :flex 136.9) (:hand-l :flex 10) (:thigh-r :flex 6) (:thigh-l :flex -24))
  ;; R (0.55 1.2 2.24) e4, L (-0.45 1.2 1.1) e140 MISS 0.04
  (:s :snap (:root :f 0.75 :u -0.14 :yaw 4 :pitch 8) (:spine :flex 46) (:chest :twist 10) (:neck :flex 34)
   (:head :flex 12) (:arm-r :flex 38.9 :side 137.4) (:elbow-r :flex 4) (:hand-r :flex 40)
   (:arm-l :flex 54.4 :side -139.5) (:elbow-l :flex 139.6) (:hand-l :flex 10) (:thigh-r :flex 30) (:thigh-l :flex -26))
  ;; R (-0.45 1.1 2.22) e40, L (-0.6 1.25 0.9) e141
  (:a (:root :f 0.8 :u -0.14 :yaw 14 :pitch 8) (:spine :flex 46) (:chest :twist 24) (:neck :flex 34) (:head :flex 12)
   (:arm-r :flex 33.1 :side 155.2) (:elbow-r :flex 39.6) (:hand-r :flex 50) (:arm-l :flex 64.5 :side -168.9)
   (:elbow-l :flex 141.1) (:hand-l :flex 10) (:thigh-r :flex 30) (:thigh-l :flex -26))
  ;; R (-1.15 0.95 1.2) e42 MISS 0.04, L (-0.5 1.3 0.5) e138
  (30 (:root :f 0.6 :u -0.1 :yaw 22 :pitch 6) (:spine :flex 40) (:chest :twist 32) (:neck :flex 28) (:head :flex 8)
   (:arm-r :flex 81 :side 100) (:elbow-r :flex 41.8) (:hand-r :flex 40) (:arm-l :flex 87.9 :side -184.4)
   (:elbow-l :flex 137.5) (:hand-l :flex 10) (:thigh-r :flex 22) (:thigh-l :flex -18))
  (:end :lb-o-stance))
(defstrike :lb-o-f2 (20 4 24 :base :lb-o-stance)   ; K2 回爪 (entered at f6): a half turn to the left, unwound, the left claw lashed back the other way (left -> right)
  (0)
  (6 (:root :f 0 :u -0.02 :yaw 0 :pitch 0) (:spine :flex 22) (:chest :twist 0) (:neck :flex 26) (:head :flex 8)
   (:arm-r :flex 58 :twist 0 :side 14) (:elbow-r :flex 70) (:hand-r :flex 0) (:arm-l :flex 58 :twist 0 :side 14)
   (:elbow-l :flex 70) (:hand-l :flex 0) (:thigh-r :flex 0) (:thigh-l :flex 0))
  ;; R (-0.66 1.36 -0.14) e94, L (-0.42 1.27 0.58) e108
  (9 (:root :f 0.1 :u -0.08 :yaw 40 :pitch 4) (:spine :flex 30) (:chest :twist 26) (:neck :flex 20) (:head :flex 0)
   (:arm-r :flex -11.1 :twist 0 :side -65.1) (:elbow-r :flex 93.9) (:hand-r :flex 10)
   (:arm-l :flex 86.5 :twist 0 :side 102) (:elbow-l :flex 108.5) (:hand-l :flex -20) (:thigh-r :flex 14)
   (:thigh-l :flex -12))
  ;; R (-0.02 1.48 -0.63) e94, L (-0.62 1.22 0.02) e109
  (14 (:root :f 0 :u -0.12 :yaw 95 :pitch 6) (:spine :flex 34) (:chest :twist 30) (:neck :flex 14) (:head :flex -6)
   (:arm-r :flex -23 :twist 0 :side -72.6) (:elbow-r :flex 93.5) (:hand-r :flex 10)
   (:arm-l :flex 91.8 :twist 0 :side 99.1) (:elbow-l :flex 108.8) (:hand-l :flex -40) (:thigh-r :flex 20)
   (:thigh-l :flex -16))
  ;; R (0.2 1.3 0.6) e134 MISS 0.04, L (-1.4 1.4 1.2) e34
  (18 (:root :f 0.4 :u -0.1 :yaw 30 :pitch 6) (:spine :flex 40) (:chest :twist 10) (:neck :flex 24) (:head :flex 4)
   (:arm-r :flex -59.4 :twist 0 :side 27.7) (:elbow-r :flex 134.2) (:hand-r :flex 10)
   (:arm-l :flex 41.8 :twist 0 :side 158.2) (:elbow-l :flex 34.2) (:hand-l :flex -20) (:thigh-r :flex -10)
   (:thigh-l :flex 10))
  ;; R (0.45 1.25 1) e139, L (-0.5 1.25 2.24) e4
  (:s :snap (:root :f 0.75 :u -0.1 :yaw -2 :pitch 8) (:spine :flex 44) (:chest :twist -10) (:neck :flex 34)
   (:head :flex 12) (:arm-r :flex -14.1 :twist 0 :side 29.5) (:elbow-r :flex 139.1) (:hand-r :flex 10)
   (:arm-l :flex 43.8 :twist 0 :side 143.4) (:elbow-l :flex 4) (:hand-l :flex 40) (:thigh-r :flex -24)
   (:thigh-l :flex 30))
  ;; R (0.6 1.25 0.9) e137, L (0.45 1.15 2.22) e38
  (:a (:root :f 0.8 :u -0.1 :yaw -14 :pitch 8) (:spine :flex 44) (:chest :twist -24) (:neck :flex 34)
   (:head :flex 12) (:arm-r :flex -8.8 :twist 0 :side 5.8) (:elbow-r :flex 136.7) (:hand-r :flex 10)
   (:arm-l :flex 35.4 :twist 0 :side 153.5) (:elbow-l :flex 38.1) (:hand-l :flex 50) (:thigh-r :flex -24)
   (:thigh-l :flex 30))
  ;; R (0.5 1.3 0.5) e136, L (1.15 0.95 1.2) e37 MISS 0.04
  (33 (:root :f 0.6 :u -0.08 :yaw -22 :pitch 6) (:spine :flex 40) (:chest :twist -30) (:neck :flex 28)
   (:head :flex 8) (:arm-r :flex -29.9 :twist 0 :side -4.5) (:elbow-r :flex 136.1) (:hand-r :flex 10)
   (:arm-l :flex 84.8 :twist 0 :side 100.2) (:elbow-l :flex 36.9) (:hand-l :flex 40) (:thigh-r :flex -18)
   (:thigh-l :flex 22))
  (:end :lb-o-stance))
(defstrike :lb-o-f3 (21 5 34 :base :lb-o-stance)   ; K3 俯衝 (entered at f7): crouched, a leap with the claws and wings raised high, a stoop, both claws down, landed crouched
  (0)
  (7 (:root :f 0 :u -0.02 :pitch 0) (:spine :flex 22) (:neck :flex 26) (:head :flex 8) (:arm-r :flex 58 :side 14)
   (:elbow-r :flex 70) (:hand-r :flex 0) (:arm-l :flex 58 :side 14) (:elbow-l :flex 70) (:hand-l :flex 0)
   (:thigh-r :flex 0 :side 5) (:thigh-l :flex 0 :side 5))
  ;; R (0.45 1 -0.35) e92, L (-0.45 1 -0.35) e92
  (11 (:root :f 0 :u -0.18 :pitch 10) (:spine :flex 34) (:neck :flex 14) (:head :flex 4)
   (:arm-r :flex -44.5 :side 15.3) (:elbow-r :flex 92.2) (:hand-r :flex -20) (:arm-l :flex -44.5 :side 15.3)
   (:elbow-l :flex 92.2) (:hand-l :flex -20) (:thigh-r :flex 26 :side 5) (:thigh-l :flex 22 :side 5))
  ;; R (0.55 2.95 0.1) e104 MISS 0.03, L (-0.55 2.95 0.1) e104 MISS 0.03
  (16 (:root :f 0.3 :u 0.42 :pitch -8) (:spine :flex 4) (:neck :flex 0) (:head :flex -16)
   (:arm-r :flex -56.8 :side 152) (:elbow-r :flex 104.4) (:hand-r :flex -40) (:arm-l :flex -56.8 :side 152)
   (:elbow-l :flex 104.4) (:hand-l :flex -40) (:thigh-r :flex 40 :side 5) (:thigh-l :flex 34 :side 5))
  ;; R (0.35 2.45 1.6) e102, L (-0.35 2.45 1.6) e102
  (18.5 (:root :f 0.6 :u 0.45 :pitch 12) (:spine :flex 30) (:neck :flex 30) (:head :flex 10)
   (:arm-r :flex -18.2 :side 168.7) (:elbow-r :flex 102) (:hand-r :flex -10) (:arm-l :flex -18.2 :side 168.7)
   (:elbow-l :flex 102) (:hand-l :flex -10) (:thigh-r :flex 30 :side 5) (:thigh-l :flex 24 :side 5))
  ;; R (0.24 1.1 2.29) e4 MISS 0.09, L (-0.24 1.15 2.29) e4 MISS 0.06
  (:s :snap (:root :f 0.85 :u 0.2 :pitch 16) (:spine :flex 46) (:neck :flex 44) (:head :flex 16)
   (:arm-r :flex 60.3 :side 177.9) (:elbow-r :flex 4) (:hand-r :flex 40) (:arm-l :flex 58.5 :side 178)
   (:elbow-l :flex 4) (:hand-l :flex 40) (:thigh-r :flex 16 :side 5) (:thigh-l :flex 8 :side 5))
  ;; R (0.3 0.8 2.2) e4, L (-0.3 0.85 2.2) e19
  (:a (:root :f 0.9 :u 0 :pitch 16) (:spine :flex 50) (:neck :flex 44) (:head :flex 18)
   (:arm-r :flex 63.3 :side 171.6) (:elbow-r :flex 4) (:hand-r :flex 50) (:arm-l :flex 54.4 :side 171.9)
   (:elbow-l :flex 19.3) (:hand-l :flex 50) (:thigh-r :flex 14 :side 5) (:thigh-l :flex 6 :side 5))
  ;; R (0.6 0.45 1.6) e21 MISS 0.03, L (-0.6 0.45 1.6) e21 MISS 0.03
  (31 (:root :f 0.75 :u -0.2 :pitch 12) (:spine :flex 44) (:neck :flex 30) (:head :flex 8)
   (:arm-r :flex 99 :side 245.2) (:elbow-r :flex 20.8) (:hand-r :flex 30) (:arm-l :flex 99 :side 245.2)
   (:elbow-l :flex 20.8) (:hand-l :flex 30) (:thigh-r :flex 30 :side 16) (:thigh-l :flex -10 :side 16))
  ;; R (0.55 0.8 1.3) e74, L (-0.55 0.8 1.3) e74
  (42 (:root :f 0.55 :u -0.14 :pitch 8) (:spine :flex 36) (:neck :flex 28) (:head :flex 8)
   (:arm-r :flex 79.8 :side 234) (:elbow-r :flex 73.7) (:hand-r :flex 20) (:arm-l :flex 79.8 :side 234)
   (:elbow-l :flex 73.7) (:hand-l :flex 20) (:thigh-r :flex 22 :side 12) (:thigh-l :flex -6 :side 12))
  (:end :lb-o-stance))
(defstrike :lb-o-chop (16 0 24 :base :lb-o-stance)  ; SABAKI NO KOMYO: the right arm raised high, chopped straight down
  (0) (10 (:arm-r :flex 170 :side 6) (:elbow-r :flex 4) (:head :flex -10))
  (:s :snap (:arm-r :flex 60 :side 4) (:spine :flex 20) (:root :f 0.1))
  (24 (:arm-r :flex 40) (:spine :flex 12))
  (:end :lb-o-stance))
(defstrike :lb-o-trompete (60 30 40 :base :lb-o-stance)   ; TROMPETE: the fist at the beak, the head bent to it
  (0 (:arm-r :flex 120 :side 10) (:elbow-r :flex 150) (:head :flex 24))
  (40 (:arm-r :flex 124) (:spine :flex -6) (:head :flex 28))
  (:s :snap (:root :f -0.08) (:spine :flex -10))
  (:a (:root :f -0.12))
  (:end :lb-o-stance))
(defclip :lb-o-breaker (0.4 :loop t :base :lb-o-stance)
  (0 (:root :u -0.06) (:spine :flex 26) (:arm-r :flex -20) (:arm-l :flex -20) (:thigh-r :flex 30) (:thigh-l :flex -20))
  (0.2 (:thigh-l :flex 30) (:thigh-r :flex -20)))
(defpose :lb-o-stamp-hit (:base :lb-o-stance) (:root :f 0.1 :u -0.04) (:spine :flex 22) (:arm-r :flex 70 :side 10) (:elbow-r :flex 10))
(defstrike :lb-o-stamp (8 4 18 :base :lb-o-stance)
  (0 (:arm-r :flex 160 :side 20)) (:s :snap :lb-o-stamp-hit) (:a :lb-o-stamp-hit) (:end :lb-o-stance))

;;; ---- the owl on Jilliel's system (decision 36, DUEL_LILLE §23.14): functional clips. 遠 EN (decision 38: 「遠程模式翼張開、
;;; 站直」) floats (the kit's :lift, *LB-OWL-LIFT*) bolt upright, the S-neck raised tall, the long arms hanging open at the
;;; sides, the thighs a little forward and the ㄇ legs folded up under the column (LILLE-DRAW tucks them), the eight wings fanned wide
;;; and forward; 近 KIN is the pitched claw stance above (the wings swept back). KIN's arms crossed low before the column
;;; (:lb-o-fold-pose, the old MUJITTAI's: Lille's KIN -> EN turn, barro-art.lisp's :br-o-to-en, starts from it). EN's SP1 裁きの光明: three chops, right, left, both, one a line (f6, f12, f18). TENSHIN: the owl
;;; crouched, the arms swept back, the flash step (in: the wind-up first, the arms raised, 16 f; the cancel enters it at
;;; f14); the form (and its lift) changes inside the dash, so the clip's root height steps by the lift there to hide it.
(defpose :lb-oe-stance (:base :lb-o-stance)
  (:root :u 0.0) (:spine :flex 0) (:neck :flex -6) (:head :flex -4) (:arm-r :flex 10 :side 30) (:elbow-r :flex 8)
  (:arm-l :flex 10 :side 30) (:elbow-l :flex 8) (:thigh-r :flex 12 :side 8) (:thigh-l :flex 12 :side 8))
(defclip :lb-oe-stance (2.6 :loop t :base :lb-oe-stance)
  (0) (1.3 (:root :u 0.06) (:head :flex 0 :twist -8) (:arm-r :side 35) (:arm-l :side 26) (:thighs :flex 8)))
(defpose :lb-o-fold-pose (:base :lb-o-stance)
  (:root :u -0.03) (:spine :flex 26) (:head :flex 14) (:arm-r :flex 34 :side 18 :twist 45) (:elbow-r :flex 118)
  (:arm-l :flex 34 :side 18 :twist -45) (:elbow-l :flex 118))
;; Decision 56: the owl EN's own six casts at EN's frames (KIN's claw clips at :clip-s / S before): upright and afloat, the
;; claws thrown down onto the ground line, the striking claw's tip at the move's :reach on S (the frame the line is laid;
;; the host's cast check). Solved as KIN's above.
(defstrike :lb-oe-q1 (4 3 5 :base :lb-oe-stance)   ; EN J1: upright, the right claw raised high, thrown down onto the line (the cast)
  (0)
  ;; R (0.45 2.65 0.15) e97, L (-0.45 1.3 0.3) e108
  (2 (:root :f 0 :u 0.06 :pitch -5) (:spine :flex -6) (:chest :twist -14) (:neck :flex -10) (:head :flex -8)
   (:arm-r :flex 100.3 :side -9.8) (:elbow-r :flex 96.6) (:hand-r :flex -30) (:arm-l :flex -38.4 :side 22.7)
   (:elbow-l :flex 108.3) (:hand-l :flex 0))
  ;; R (0.5 2.75 0.05) e85, L (-0.45 1.3 0.25) e109
  (3 (:root :f 0 :u 0.07 :pitch -6) (:spine :flex -8) (:chest :twist -18) (:neck :flex -12) (:head :flex -10)
   (:arm-r :flex 108.8 :side -10.9) (:elbow-r :flex 85) (:hand-r :flex -40) (:arm-l :flex -47.1 :side 21.4)
   (:elbow-l :flex 109) (:hand-l :flex 0))
  ;; R (0.15 1.35 1.69) e28, L (-0.5 1.3 0.2) e122
  (:s :snap (:root :f 0.28 :u -0.04 :pitch 8) (:spine :flex 28) (:chest :twist 10) (:neck :flex 20) (:head :flex 10)
   (:arm-r :flex 96.1 :side -19.1) (:elbow-r :flex 28) (:hand-r :flex 40) (:arm-l :flex -45.9 :side 26.5)
   (:elbow-l :flex 122) (:hand-l :flex 0))
  ;; R (0.05 0.95 1.5) e31 MISS 0.06, L (-0.5 1.25 0.2) e118
  (:a (:root :f 0.28 :u -0.05 :pitch 9) (:spine :flex 30) (:chest :twist 14) (:neck :flex 24) (:head :flex 12)
   (:arm-r :flex 80.9 :side -58.1) (:elbow-r :flex 31.4) (:hand-r :flex 50) (:arm-l :flex -39 :side 24)
   (:elbow-l :flex 118.3) (:hand-l :flex 0))
  ;; R (0.1 0.95 1.15) e31, L (-0.45 1.3 0.25) e126
  (10 (:root :f 0.15 :u -0.02 :pitch 5) (:spine :flex 14) (:chest :twist 8) (:neck :flex 8) (:head :flex 4)
   (:arm-r :flex 49.5 :side 1.5) (:elbow-r :flex 30.7) (:hand-r :flex 30) (:arm-l :flex -36.1 :side 22.6)
   (:elbow-l :flex 125.8) (:hand-l :flex 0))
  (:end :lb-oe-stance))
(defstrike :lb-oe-q2 (4 3 5 :base :lb-oe-stance)   ; EN J2: the mirror, the left claw
  (0)
  ;; L (-0.45 2.65 0.15) e97, R (0.45 1.3 0.3) e108
  (2 (:root :f 0 :u 0.06 :pitch -5) (:spine :flex -6) (:chest :twist 14) (:neck :flex -10) (:head :flex -8)
   (:arm-r :flex -38.4 :side 22.7) (:elbow-r :flex 108.3) (:hand-r :flex 0) (:arm-l :flex 100.3 :side -9.8)
   (:elbow-l :flex 96.6) (:hand-l :flex -30))
  ;; L (-0.5 2.75 0.05) e85, R (0.45 1.3 0.25) e109
  (3 (:root :f 0 :u 0.07 :pitch -6) (:spine :flex -8) (:chest :twist 18) (:neck :flex -12) (:head :flex -10)
   (:arm-r :flex -47.1 :side 21.4) (:elbow-r :flex 109) (:hand-r :flex 0) (:arm-l :flex 108.8 :side -10.9)
   (:elbow-l :flex 85) (:hand-l :flex -40))
  ;; L (-0.15 1.35 1.69) e28, R (0.5 1.3 0.2) e122
  (:s :snap (:root :f 0.28 :u -0.04 :pitch 8) (:spine :flex 28) (:chest :twist -10) (:neck :flex 20) (:head :flex 10)
   (:arm-r :flex -45.9 :side 26.5) (:elbow-r :flex 122) (:hand-r :flex 0) (:arm-l :flex 96.1 :side -19.1)
   (:elbow-l :flex 28) (:hand-l :flex 40))
  ;; L (-0.05 0.95 1.5) e31 MISS 0.06, R (0.5 1.25 0.2) e118
  (:a (:root :f 0.28 :u -0.05 :pitch 9) (:spine :flex 30) (:chest :twist -14) (:neck :flex 24) (:head :flex 12)
   (:arm-r :flex -39 :side 24) (:elbow-r :flex 118.3) (:hand-r :flex 0) (:arm-l :flex 80.9 :side -58.1)
   (:elbow-l :flex 31.4) (:hand-l :flex 50))
  ;; L (-0.1 0.95 1.15) e31, R (0.45 1.3 0.25) e126
  (10 (:root :f 0.15 :u -0.02 :pitch 5) (:spine :flex 14) (:chest :twist -8) (:neck :flex 8) (:head :flex 4)
   (:arm-r :flex -36.1 :side 22.6) (:elbow-r :flex 125.8) (:hand-r :flex 0) (:arm-l :flex 49.5 :side 1.5)
   (:elbow-l :flex 30.7) (:hand-l :flex 30))
  (:end :lb-oe-stance))
(defstrike :lb-oe-q3 (5 3 8 :base :lb-oe-stance)   ; EN J3: both claws raised overhead, crossed down onto the line with a peck
  (0)
  ;; R (0.6 2.6 0.2) e97, L (-0.6 2.6 0.2) e97
  (3 (:root :f 0 :u 0.08 :pitch -6) (:spine :flex -8) (:neck :flex -10) (:head :flex -12)
   (:arm-r :flex 100.6 :side -31.8) (:elbow-r :flex 97.3) (:hand-r :flex -30) (:arm-l :flex 100.6 :side -31.8)
   (:elbow-l :flex 97.3) (:hand-l :flex -30))
  ;; R (0.62 2.72 0.1) e87, L (-0.62 2.72 0.1) e87
  (4 (:root :f 0 :u 0.09 :pitch -7) (:spine :flex -10) (:neck :flex -12) (:head :flex -14)
   (:arm-r :flex 110.7 :side -30) (:elbow-r :flex 86.8) (:hand-r :flex -40) (:arm-l :flex 110.7 :side -30)
   (:elbow-l :flex 86.8) (:hand-l :flex -40))
  ;; R (-0.08 1.35 1.69) e9, L (0.12 1.42 1.68) e22
  (:s :snap (:root :f 0.3 :u -0.04 :pitch 9) (:spine :flex 30) (:neck :flex 40) (:head :flex 20)
   (:arm-r :flex 110.2 :side 32.9) (:elbow-r :flex 9.4) (:hand-r :flex 40) (:arm-l :flex 107.9 :side 33.8)
   (:elbow-l :flex 21.9) (:hand-l :flex 40))
  ;; R (-0.3 0.95 1.45) e4 MISS 0.04, L (0.3 1 1.45) e4
  (:a (:root :f 0.3 :u -0.05 :pitch 10) (:spine :flex 32) (:neck :flex 46) (:head :flex 24)
   (:arm-r :flex 112 :side 84.4) (:elbow-r :flex 4) (:hand-r :flex 50) (:arm-l :flex 112.8 :side 80.6)
   (:elbow-l :flex 4) (:hand-l :flex 50))
  ;; R (-0.3 1 1.1) e11, L (0.3 1.05 1.1) e28
  (12 (:root :f 0.15 :u -0.03 :pitch 6) (:spine :flex 16) (:neck :flex 20) (:head :flex 8)
   (:arm-r :flex 117.8 :side 129.2) (:elbow-r :flex 10.8) (:hand-r :flex 30) (:arm-l :flex 109.2 :side 125.9)
   (:elbow-l :flex 27.9) (:hand-l :flex 30))
  (:end :lb-oe-stance))
(defstrike :lb-oe-f1 (9 4 9 :base :lb-oe-stance)   ; EN K1: coiled and risen, the glide, the right claw raked low across the fan of three
  (0)
  ;; R (0.85 2.2 -0.4) e104, L (-0.4 1.4 0.5) e110
  (3 (:root :f 0 :u 0.08 :yaw -14 :pitch -4) (:spine :flex -4) (:chest :twist -20) (:neck :flex -10) (:head :flex -8)
   (:arm-r :flex -30.1 :side 111.3) (:elbow-r :flex 104.5) (:hand-r :flex -30) (:arm-l :flex -36.2 :side 33.1)
   (:elbow-l :flex 109.9) (:hand-l :flex 0))
  ;; R (1.05 2 -0.3) e84, L (-0.4 1.4 0.5) e107
  (6 (:root :f 0 :u 0.12 :yaw -22 :pitch -5) (:spine :flex -6) (:chest :twist -26) (:neck :flex -12)
   (:head :flex -10) (:arm-r :flex 4.5 :side 90) (:elbow-r :flex 83.8) (:hand-r :flex -40)
   (:arm-l :flex -49.1 :side 32.5) (:elbow-l :flex 106.9) (:hand-l :flex 0))
  ;; R (0.7 1.25 2.2) e4, L (-0.45 1.3 0.9) e129
  (:s :snap (:root :f 0.85 :u -0.02 :yaw 0 :pitch 14) (:spine :flex 30) (:chest :twist 6) (:neck :flex 26)
   (:head :flex 12) (:arm-r :flex 53 :side 123.7) (:elbow-r :flex 4) (:hand-r :flex 40) (:arm-l :flex -38.3 :side 25)
   (:elbow-l :flex 129) (:hand-l :flex 0))
  ;; R (-0.7 1.15 2.18) e4, L (-0.55 1.3 0.8) e131
  (:a (:root :f 0.85 :u -0.03 :yaw 14 :pitch 14) (:spine :flex 30) (:chest :twist 22) (:neck :flex 26)
   (:head :flex 12) (:arm-r :flex 69.1 :side 163.3) (:elbow-r :flex 4) (:hand-r :flex 50)
   (:arm-l :flex -29.5 :side 6.3) (:elbow-l :flex 131.3) (:hand-l :flex 0))
  ;; R (-0.9 1.05 1.25) e4 MISS 0.11, L (-0.5 1.3 0.4) e127
  (18 (:root :f 0.4 :u -0.02 :yaw 12 :pitch 8) (:spine :flex 16) (:chest :twist 16) (:neck :flex 12) (:head :flex 4)
   (:arm-r :flex 114.9 :side 124.5) (:elbow-r :flex 4) (:hand-r :flex 30) (:arm-l :flex -30.6 :side 14.6)
   (:elbow-l :flex 127) (:hand-l :flex 0))
  (:end :lb-oe-stance))
(defstrike :lb-oe-f2 (10 4 11 :base :lb-oe-stance)   ; EN K2 (entered at f3): the mirror, the left claw raked back across
  (0)
  (3 (:root :f 0 :u 0 :yaw 0 :pitch 0) (:spine :flex 0) (:chest :twist 0) (:neck :flex -6) (:head :flex -4)
   (:arm-r :flex 10 :side 30) (:elbow-r :flex 8) (:hand-r :flex 0) (:arm-l :flex 10 :side 30) (:elbow-l :flex 8)
   (:hand-l :flex 0))
  ;; L (-0.85 2.2 -0.4) e104, R (0.4 1.4 0.5) e110
  (5 (:root :f 0 :u 0.08 :yaw 14 :pitch -4) (:spine :flex -4) (:chest :twist 20) (:neck :flex -10) (:head :flex -8)
   (:arm-r :flex -36.2 :side 33.1) (:elbow-r :flex 109.9) (:hand-r :flex 0) (:arm-l :flex -30.1 :side 111.3)
   (:elbow-l :flex 104.5) (:hand-l :flex -30))
  ;; L (-1.05 2 -0.3) e84, R (0.4 1.4 0.5) e107
  (7.5 (:root :f 0 :u 0.12 :yaw 22 :pitch -5) (:spine :flex -6) (:chest :twist 26) (:neck :flex -12)
   (:head :flex -10) (:arm-r :flex -49.1 :side 32.5) (:elbow-r :flex 106.9) (:hand-r :flex 0)
   (:arm-l :flex 4.5 :side 90) (:elbow-l :flex 83.8) (:hand-l :flex -40))
  ;; L (-0.7 1.25 2.2) e4, R (0.45 1.3 0.9) e129
  (:s :snap (:root :f 0.85 :u -0.02 :yaw 0 :pitch 14) (:spine :flex 30) (:chest :twist -6) (:neck :flex 26)
   (:head :flex 12) (:arm-r :flex -38.3 :side 25) (:elbow-r :flex 129) (:hand-r :flex 0) (:arm-l :flex 53 :side 123.7)
   (:elbow-l :flex 4) (:hand-l :flex 40))
  ;; L (0.7 1.15 2.18) e4, R (0.55 1.3 0.8) e131
  (:a (:root :f 0.85 :u -0.03 :yaw -14 :pitch 14) (:spine :flex 30) (:chest :twist -22) (:neck :flex 26)
   (:head :flex 12) (:arm-r :flex -29.5 :side 6.3) (:elbow-r :flex 131.3) (:hand-r :flex 0)
   (:arm-l :flex 69.1 :side 163.3) (:elbow-l :flex 4) (:hand-l :flex 50))
  ;; L (0.9 1.05 1.25) e4 MISS 0.11, R (0.5 1.3 0.4) e127
  (20 (:root :f 0.4 :u -0.02 :yaw -12 :pitch 8) (:spine :flex 16) (:chest :twist -16) (:neck :flex 12)
   (:head :flex 4) (:arm-r :flex -30.6 :side 14.6) (:elbow-r :flex 127) (:hand-r :flex 0)
   (:arm-l :flex 114.9 :side 124.5) (:elbow-l :flex 4) (:hand-l :flex 30))
  (:end :lb-oe-stance))
(defstrike :lb-oe-f3 (11 5 16 :base :lb-oe-stance)   ; EN K3 (entered at f4): rising, both claws and the wings raised high, both thrown down onto the line
  (0)
  (4 (:root :f 0 :u 0 :pitch 0) (:spine :flex 0) (:neck :flex -6) (:head :flex -4) (:arm-r :flex 10 :side 30)
   (:elbow-r :flex 8) (:hand-r :flex 0) (:arm-l :flex 10 :side 30) (:elbow-l :flex 8) (:hand-l :flex 0))
  ;; R (0.55 2.7 0.2) e100, L (-0.55 2.7 0.2) e100
  (7 (:root :f 0 :u 0.18 :pitch -6) (:spine :flex -8) (:neck :flex -12) (:head :flex -12)
   (:arm-r :flex 98.4 :side -28.2) (:elbow-r :flex 99.9) (:hand-r :flex -30) (:arm-l :flex 98.4 :side -28.2)
   (:elbow-l :flex 99.9) (:hand-l :flex -30))
  ;; R (0.5 2.98 0.3) e85, L (-0.5 2.98 0.3) e85
  (9.5 (:root :f 0.1 :u 0.32 :pitch -8) (:spine :flex -10) (:neck :flex -14) (:head :flex -14)
   (:arm-r :flex 103.1 :side -22.4) (:elbow-r :flex 84.7) (:hand-r :flex -40) (:arm-l :flex 103.1 :side -22.4)
   (:elbow-l :flex 84.7) (:hand-l :flex -40))
  ;; R (0.2 1.3 2.29) e28, L (-0.2 1.35 2.29) e33
  (:s :snap (:root :f 0.85 :u 0 :pitch 16) (:spine :flex 34) (:neck :flex 36) (:head :flex 16)
   (:arm-r :flex 106.6 :side 1.3) (:elbow-r :flex 27.5) (:hand-r :flex 40) (:arm-l :flex 106.2 :side 1.2)
   (:elbow-l :flex 33.2) (:hand-l :flex 40))
  ;; R (0.25 0.85 2.15) e37, L (-0.25 0.9 2.15) e45
  (:a (:root :f 0.88 :u -0.15 :pitch 16) (:spine :flex 38) (:neck :flex 40) (:head :flex 18)
   (:arm-r :flex 90.2 :side -4.3) (:elbow-r :flex 37.4) (:hand-r :flex 50) (:arm-l :flex 88.6 :side -4.1)
   (:elbow-l :flex 45) (:hand-l :flex 50))
  ;; R (0.4 0.9 1.1) e69, L (-0.4 0.95 1.1) e75
  (24 (:root :f 0.35 :u -0.08 :pitch 8) (:spine :flex 18) (:neck :flex 16) (:head :flex 6)
   (:arm-r :flex 27.5 :side 19) (:elbow-r :flex 68.8) (:hand-r :flex 30) (:arm-l :flex 26 :side 20.6)
   (:elbow-l :flex 75.1) (:hand-l :flex 30))
  (:end :lb-oe-stance))
;;; ---- rework R (decisions 17, 18): base stance + TENSHIN clips
;;; (Functional clips of the rules batch, DUEL_LILLE §22.1 / §22.2; the art batch owns everything above.) The shooting
;;; stance 狙撃構え: Diagramm levelled at the hip, knees bent, the right eye along the barrel; its L fires from there;
;;; the HIRENKYAKU dash crouches low (barro.lisp's :br-kamae / :br-k-dash play them; the old Lille's HOSHA, TAISHA and
;;; TENSHIN clips went with him, 2026-10-13).
(defpose :lb-kamae-pose (:base :lb-aim-pose)          ; low, the rifle levelled from the hip-shoulder, aimed
  (:root :u -0.12) (:pelvis :twist 24) (:chest :twist -16) (:spine :flex 6) (:head :flex 8 :twist 20)
  (:thigh-r :flex -14 :side 10) (:thigh-l :flex 30 :side 8) (:knee-l :flex 34) (:knee-r :flex 22))
(defclip :lb-kamae (0.8 :loop t :base :lb-kamae-pose) (0) (0.4 (:root :u -0.13) (:chest :flex 1)))
;; Step 飛廉脚 HIRENKYAKU: the flash-step dash, crouched low, the rifle kept on the line
(defstrike :lb-k-dash (12 0 0 :base :lb-kamae-pose)
  (0 (:root :u -0.3 :pitch 10) (:knees :flex 50) (:thighs :flex 40))
  (6 (:root :u -0.26 :pitch 6) (:knees :flex 40))
  (12 :lb-kamae-pose))


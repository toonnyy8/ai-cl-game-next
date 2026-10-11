;;;; barro-art.lisp — LILLE BARRO II's own looks (docs/duel/DUEL_LILLE_V2.md §7, §12, §17, §22; version 3: DUEL_LILLE_V3.md).
;;;; His art is Lille's, shared by reference (lille-art.lisp: the bodies, Diagramm, every :lb-* clip, LILLE-DRAW's wings /
;;;; halos / legs, LB-LOOK's lines and beams); this file holds only what is his: the clips Lille never had (the volley
;;;; :br-recall and its strings, the turn, the owl's twins, the stance's swing L1), the draw hook BR-DRAW (his wing count to
;;;; Lille's lit wings, Lille's, then the base stance's aim line, the spends' looks and the volley's) and the special
;;;; resource's HUD row.
;;;; Everything here is cosmetic: the sim never reads it. Loaded after lille-art.lisp (its macros and props) and before
;;;; barro.lisp (whose state and knobs these functions read at draw time).
(in-package :duel)

(declaim (special *br-at* *br-keep-owl*))  ; (*BR-AT* below; *BR-KEEP-OWL* barro.lisp's, loaded after)

;;; ---------------------------------------------------------------- his clips (DUEL_LILLE_V2 §7, §12: the art batch)
;;; The motions Lille never had, timed to barro.lisp's frame data. JILLIEL's on its rig (the front wing pair's tips are the
;;; rig's hands, Lille's convention; the keys' comments give their aims, azimuth / elevation in the chest frame, + = his
;;; right / up, as lille-art.lisp's); the owl's twins (:br-o-*, its claws are the hands) through the owl kits' :clip-map.
;;; - 回収 the recall :br-recall (8 f; its f0 takes the traces back, its f7 starts the string): the wings flung open wide and
;;;   high, the column arched back and rising (f3-f6) while the traces' light flies into him (BR-DRAW), then drawn in round
;;;   the gathered light (f8 = the strings' first frame).
;;; - the derivative strings, every beat a line fired from the wing tips at him (BR-DRAW draws each tip's line and flash):
;;;   :br-rc0 空收 one beat (f6, both wings), :br-rc1 二連 two (f6 the right wing, f16 the left), :br-rc2 四連 four (f6 R,
;;;   f14 L, f22 R, f32 the launch: both wings swept up from low), :br-rc3 裁き five (f6 R, f12 L, f18 R, f24 L, f36 the
;;;   finisher: risen into NIJUSHI-KO's ring over f26-35, the beam on f36 blowing him back). Each beat: cocked (2-3 f),
;;;   snapped at him on its frame, kicked back.
;;; - :br-to-en (12 f, ranged at f11): folded, rising with the wings thrown open, EN's float. The owl's :br-o-to-en steps
;;;   the root down by the owl's lift (*BR-OWL-LIFT* 0.35) on the frame the form turns ranged (f11), as :lb-o-tenshin does
;;;   on Lille's f6 (§17). (The backstep :br-o-backstep went with J3 -> L, decision R3, 2026-10-11.)
(defpose :br-open-pose (:base :lb-w-stance)          ; flung open: R 105/35, L -105/35, the column arched back, rising
  (:root :f -0.06 :u 0.18 :pitch -8) (:spine :flex -12) (:head :flex -10) (:arm-r :flex -14 :side 128) (:elbow-r :flex 8)
  (:arm-l :flex -14 :side 128) (:elbow-l :flex 8) (:thigh-r :flex -8) (:thigh-l :flex -8))
(defpose :br-gather-pose (:base :lb-w-stance)        ; drawn in round the gathered light: R 62/4, L -62/4, bowed over it
  (:root :f 0.02 :u 0.14 :pitch 3) (:spine :flex 8) (:head :flex 8) (:arm-r :flex 28 :side 84) (:elbow-r :flex 34)
  (:arm-l :flex 28 :side 84) (:elbow-l :flex 34) (:thigh-r :flex -4) (:thigh-l :flex -4))
(defpose :br-cock-r (:base :lb-w-stance)             ; R 135/18 (cocked high behind), L -95/-8
  (:root :f -0.08 :u 0.12 :yaw -10) (:spine :flex -4) (:chest :twist -20) (:arm-r :flex -42.3 :side 114.7) (:elbow-r :flex 30)
  (:arm-l :flex -5 :side 82) (:elbow-l :flex 8) (:thigh-r :flex -12) (:thigh-l :flex 14))
(defpose :br-fire-r (:base :lb-w-stance)             ; R 30/-2 (with the turn: at him), L -104/-12
  (:root :f 0.14 :u 0.06 :yaw 12) (:spine :flex 10) (:chest :twist 18) (:arm-r :flex 59.9 :side 86) (:elbow-r :flex 2)
  (:arm-l :flex -13.7 :side 77.6) (:elbow-l :flex 6) (:thigh-r :flex 24) (:thigh-l :flex -16))
(defpose :br-kick-r (:base :lb-w-stance)             ; R 36/16 (kicked up by the shot), L -104/-12
  (:root :f -0.12 :u 0.1 :yaw 10) (:spine :flex -4) (:chest :twist 14) (:head :flex -2) (:arm-r :flex 51 :side 116)
  (:elbow-r :flex 12) (:arm-l :flex -13.7 :side 77.6) (:elbow-l :flex 6) (:thigh-r :flex 16) (:thigh-l :flex -10))
(defpose :br-cock-l (:base :lb-w-stance)             ; the mirrors: L -135/18, R 95/-8
  (:root :f -0.08 :u 0.12 :yaw 10) (:spine :flex -4) (:chest :twist 20) (:arm-l :flex -42.3 :side 114.7) (:elbow-l :flex 30)
  (:arm-r :flex -5 :side 82) (:elbow-r :flex 8) (:thigh-l :flex -12) (:thigh-r :flex 14))
(defpose :br-fire-l (:base :lb-w-stance)
  (:root :f 0.14 :u 0.06 :yaw -12) (:spine :flex 10) (:chest :twist -18) (:arm-l :flex 59.9 :side 86) (:elbow-l :flex 2)
  (:arm-r :flex -13.7 :side 77.6) (:elbow-r :flex 6) (:thigh-l :flex 24) (:thigh-r :flex -16))
(defpose :br-kick-l (:base :lb-w-stance)
  (:root :f -0.12 :u 0.1 :yaw -10) (:spine :flex -4) (:chest :twist -14) (:head :flex -2) (:arm-l :flex 51 :side 116)
  (:elbow-l :flex 12) (:arm-r :flex -13.7 :side 77.6) (:elbow-r :flex 6) (:thigh-l :flex 16) (:thigh-r :flex -10))
(defpose :br-cock-both (:base :lb-w-stance)          ; R 140/30, L -140/30 (both raised behind)
  (:root :f -0.18 :u 0.18 :pitch -6) (:spine :flex -10) (:head :flex -4) (:arm-r :flex -41.6 :side 131.9) (:elbow-r :flex 34)
  (:arm-l :flex -41.6 :side 131.9) (:elbow-l :flex 34) (:thigh-r :flex -10) (:thigh-l :flex 10))
(defpose :br-fire-both (:base :lb-w-stance)          ; R 5/-3, L -5/-3 (both at him)
  (:root :f 0.2 :u 0.02 :pitch 4) (:spine :flex 14) (:head :flex 4) (:arm-r :flex 84.2 :side 59) (:elbow-r :flex 2)
  (:arm-l :flex 84.2 :side 59) (:elbow-l :flex 2) (:thigh-r :flex 22) (:thigh-l :flex -18))
(defpose :br-kick-both (:base :lb-w-stance)          ; R 14/20, L -14/20 (blown up and back)
  (:root :f -0.32 :u 0.08 :pitch -9) (:spine :flex -12) (:head :flex -8) (:arm-r :flex 65.8 :side 146.4) (:elbow-r :flex 12)
  (:arm-l :flex 65.8 :side 146.4) (:elbow-l :flex 12) (:thigh-r :flex 8) (:thigh-l :flex -6))
(defpose :br-settle-both (:base :lb-w-stance)        ; R 42/6, L -42/6
  (:root :f -0.3 :u 0.06 :pitch -6) (:spine :flex -6) (:arm-r :flex 47.7 :side 98.9) (:elbow-r :flex 14)
  (:arm-l :flex 47.7 :side 98.9) (:elbow-l :flex 14))
(defpose :br-low-both (:base :lb-w-stance)           ; the launch's wind-up: crouched, both wings swept low before him
  (:root :f -0.04 :u -0.06 :pitch 8) (:spine :flex 22) (:head :flex 10) (:arm-r :flex 70 :side 22) (:elbow-r :flex 6)
  (:arm-l :flex 70 :side 22) (:elbow-l :flex 6) (:thigh-r :flex 16) (:thigh-l :flex -12))
(defpose :br-launch-both (:base :lb-w-stance)        ; the launch: risen, both wings swept up at him (the tips ahead, high)
  (:root :f 0.16 :u 0.3 :pitch -6) (:spine :flex -8) (:head :flex -10) (:arm-r :flex 80 :side 150) (:elbow-r :flex 2)
  (:arm-l :flex 80 :side 150) (:elbow-l :flex 2) (:thigh-r :flex 10) (:thigh-l :flex -10))
(defpose :br-ring-pose (:base :lb-w-stance)          ; the finisher's ring (NIJUSHI-KO's): R 75/-22, L -75/-22, risen
  (:root :f -0.04 :u 0.34 :pitch -1) (:spine :flex -4) (:arm-r :flex 13.9 :side 67.3) (:elbow-r :flex 4)
  (:arm-l :flex 13.9 :side 67.3) (:elbow-l :flex 4) (:thigh-r :flex -6) (:thigh-l :flex -6))
(defpose :br-blown-pose (:base :lb-w-stance)         ; the beam's recoil: R 118/-4, L -118/-4, blown back
  (:root :f -0.62 :u 0.4 :pitch -14) (:spine :flex -20) (:head :flex -10) (:arm-r :flex -27.9 :side 85.5) (:elbow-r :flex 22)
  (:arm-l :flex -27.9 :side 85.5) (:elbow-l :flex 22) (:thigh-r :flex -6) (:thigh-l :flex -6))

(defstrike :br-recall (8 0 0 :base :lb-w-stance)   ; 回収: flung open (the light flies in), drawn round it
  (0) (3 :br-open-pose) (6 :br-open-pose (:root :u 0.22 :pitch -9) (:arm-r :side 134) (:arm-l :side 134))
  (:end :br-gather-pose))
(defstrike :br-rc0 (6 2 24 :base :lb-w-stance)   ; 空收: one line, both wings
  (0 :br-gather-pose) (3 :br-cock-both) (:s :snap :br-fire-both) (:a :br-kick-both) (20 :br-settle-both)
  (:end :lb-w-stance))
(defstrike :br-rc1 (6 12 24 :base :lb-w-stance)   ; 二連: the right wing f6, the left f16
  (0 :br-gather-pose) (3 :br-cock-r) (:s :snap :br-fire-r) (9 :br-kick-r) (13 :br-cock-l) (16 :snap :br-fire-l)
  (:a :br-kick-l) (30 :br-settle-both) (:end :lb-w-stance))
(defstrike :br-rc2 (6 28 24 :base :lb-w-stance)   ; 四連: R f6, L f14, R f22, the launch f32 (both wings swept up)
  (0 :br-gather-pose) (3 :br-cock-r) (:s :snap :br-fire-r) (9 :br-kick-r) (12 :br-cock-l) (14 :snap :br-fire-l)
  (17 :br-kick-l) (20 :br-cock-r) (22 :snap :br-fire-r) (25 :br-kick-r) (29 :br-low-both) (32 :snap :br-launch-both)
  (:a :br-launch-both (:root :u 0.36 :pitch -9) (:spine :flex -12)) (46 :br-settle-both) (:end :lb-w-stance))
(defstrike :br-rc3 (6 32 26 :base :lb-w-stance)   ; 裁き: R f6, L f12, R f18, L f24, the ring f26-35, the beam f36
  (0 :br-gather-pose) (3 :br-cock-r) (:s :snap :br-fire-r) (8 :br-kick-r) (10 :br-cock-l) (12 :snap :br-fire-l)
  (14 :br-kick-l) (16 :br-cock-r) (18 :snap :br-fire-r) (20 :br-kick-r) (22 :br-cock-l) (24 :snap :br-fire-l)
  (26 :br-kick-l) (31 :br-ring-pose) (35 :br-ring-pose (:root :f -0.12 :u 0.34 :pitch -4) (:spine :flex -10))
  (36 :snap :br-blown-pose) (:a :br-blown-pose (:root :f -0.7 :u 0.42 :pitch -15) (:spine :flex -22))
  (50 :br-settle-both (:root :u 0.2)) (:end :lb-w-stance))
;; 裁き・極 SABAKI KIWAMI (decision V8: the recall at 10+ points, §22): six beats, R f6, L f12, R f18, L f24, R f30, L f36,
;; then risen higher into a bigger NIJUSHI-KO ring (f38-47, every hole lit, shaking harder), the wider beam on f48 blowing
;; him further back; recovery 30 (6 43 30 = 79 f)
(defpose :br-ring-big (:base :lb-w-stance)           ; the bigger ring: R 86/-12, L -86/-12, risen 0.5 m
  (:root :f -0.06 :u 0.5 :pitch -2) (:spine :flex -6) (:head :flex -4) (:arm-r :flex 4 :side 78) (:elbow-r :flex 2)
  (:arm-l :flex 4 :side 78) (:elbow-l :flex 2) (:thigh-r :flex -8) (:thigh-l :flex -8))
(defpose :br-blown-big (:base :lb-w-stance)          ; the wider beam's recoil: R 122/-2, L -122/-2, blown further back
  (:root :f -0.85 :u 0.6 :pitch -18) (:spine :flex -26) (:head :flex -12) (:arm-r :flex -32 :side 88) (:elbow-r :flex 24)
  (:arm-l :flex -32 :side 88) (:elbow-l :flex 24) (:thigh-r :flex -10) (:thigh-l :flex -4))
(defstrike :br-rc4 (6 44 30 :base :lb-w-stance)   ; 裁き・極: R f6, L f12, R f18, L f24, R f30, L f36, the ring f38-47, the beam f48
  (0 :br-gather-pose) (3 :br-cock-r) (:s :snap :br-fire-r) (8 :br-kick-r) (10 :br-cock-l) (12 :snap :br-fire-l)
  (14 :br-kick-l) (16 :br-cock-r) (18 :snap :br-fire-r) (20 :br-kick-r) (22 :br-cock-l) (24 :snap :br-fire-l)
  (26 :br-kick-l) (28 :br-cock-r) (30 :snap :br-fire-r) (32 :br-kick-r) (34 :br-cock-l) (36 :snap :br-fire-l)
  (38 :br-kick-l) (42 :br-ring-big) (47 :br-ring-big (:root :f -0.16 :u 0.56 :pitch -5) (:spine :flex -12))
  (48 :snap :br-blown-big) (:a :br-blown-big (:root :f -0.95 :u 0.62 :pitch -19) (:spine :flex -28))
  (64 :br-settle-both (:root :u 0.24)) (:end :lb-w-stance))
;; (UNUSED since the user's revert the same day, 「L 改回 v9 的不帶傷害 可以直接放」: the ranged L is the V9 lay again; kept for a
;; later swing, its reach host-tested, DUEL_LILLE_V2 §22) the ranged L's swing (decision V8: startup 7, active 3, reach 1.8 m,
;; arc 110; a hit sets the aim point): from EN's float
;; the right wing cocked high behind, swept flat right -> left at chest height, the tip on the 1.8 m arc through f7-9
(defstrike :br-e-swing (7 3 6 :base :lb-w-stance)
  (0)
  (4 (:root :f -0.1 :u 0.04 :yaw -8) (:spine :flex -5) (:chest :twist -24) (:arm-r :flex -34.2 :side 119.5)
   (:elbow-r :flex 28) (:arm-l :flex 4 :side 84) (:elbow-l :flex 4) (:thigh-r :flex -12) (:thigh-l :flex 14))   ; R 128/24
  (6 (:root :f -0.12 :u 0.04 :yaw -10) (:spine :flex -6) (:chest :twist -28) (:arm-r :flex -40.1 :side 130.8)
   (:elbow-r :flex 32) (:arm-l :flex 6 :side 86) (:elbow-l :flex 4) (:thigh-r :flex -14) (:thigh-l :flex 16))   ; R 138/30
  (:s :snap (:root :f 0.22 :u -0.02 :yaw 6) (:spine :flex 12) (:chest :twist 16) (:arm-r :flex 58 :side 93)
   (:elbow-r :flex 4) (:arm-l :flex -11.8 :side 79.8) (:elbow-l :flex 4) (:thigh-r :flex 26) (:thigh-l :flex -16))   ; R 32/2
  (:a (:root :f 0.24 :u -0.02 :yaw 10) (:spine :flex 13) (:chest :twist 26) (:arm-r :flex 77 :side 72)
   (:elbow-r :flex 4) (:arm-l :flex -19.5 :side 77.3) (:elbow-l :flex 4) (:thigh-r :flex 26) (:thigh-l :flex -16))   ; R 12/-4
  (13 (:root :f 0.16 :u 0 :yaw 10) (:spine :flex 10) (:chest :twist 24) (:arm-r :flex 110 :side 100) (:elbow-r :flex 10)
   (:arm-l :flex -16 :side 78) (:elbow-l :flex 4))
  (:end :lb-w-stance))
(defstrike :br-to-en (12 0 0 :base :lb-w-stance)   ; melee -> ranged: folded, rising with the wings thrown open, EN
  (0 :lb-w-fold-pose) (5 (:root :u 0.16 :pitch -4) (:spine :flex -6) (:arm-r :flex 10 :side 60) (:elbow-r :flex 60)
                         (:arm-l :flex 10 :side 60) (:elbow-l :flex 60))
  (9 :br-open-pose (:root :f -0.02 :u 0.12)) (:end :lb-w-stance))

;; the owl's twins (base :lb-o-stance: the claws are the hands; the claw keys are lille-art.lisp's solved ones: J1 / J2's
;; wind-ups and rakes for the single beats, J3's spread and scissor for both, EN K3's raised-and-thrown for the finisher)
(defpose :br-o-open-pose (:base :lb-o-stance)        ; both claws spread high and wide, the neck raised, arched back
  (:root :f -0.1 :u 0.1 :pitch -7) (:spine :flex 4) (:neck :flex -14) (:head :flex -22)
  (:arm-r :flex 119.6 :side -74.8) (:elbow-r :flex 86.6) (:hand-r :flex -40) (:arm-l :flex 119.6 :side -74.8)
  (:elbow-l :flex 86.6) (:hand-l :flex -40) (:thigh-r :flex -8) (:thigh-l :flex 8))
(defpose :br-o-gather-pose (:base :lb-o-stance)      ; the claws drawn in before the chest, hunched over the light
  (:root :u -0.02) (:spine :flex 26) (:neck :flex 30) (:head :flex 12) (:arm-r :flex 50 :side 20) (:elbow-r :flex 104)
  (:hand-r :flex 30) (:arm-l :flex 50 :side 20) (:elbow-l :flex 104) (:hand-l :flex 30))
(defpose :br-o-cock-r (:base :lb-o-stance)           ; R (0.62 2.72 -0.05): J1's wind-up
  (:root :f -0.14 :u 0.04 :yaw -12 :pitch -4) (:spine :flex 8) (:chest :twist -26) (:neck :flex 2) (:head :flex -14)
  (:arm-r :flex 118.3 :side -17.9) (:elbow-r :flex 79.2) (:hand-r :flex -40) (:arm-l :flex 17.3 :side 60.3)
  (:elbow-l :flex 89.3) (:hand-l :flex 10) (:thigh-r :flex -12) (:thigh-l :flex 14))
(defpose :br-o-fire-r (:base :lb-o-stance)           ; R (0.3 1.5 1.66): J1's rake at him
  (:root :f 0.2 :u -0.06 :yaw 6 :pitch 4) (:spine :flex 30) (:chest :twist 14) (:neck :flex 34) (:head :flex 12)
  (:arm-r :flex 93 :side -50.8) (:elbow-r :flex 70.8) (:hand-r :flex 30) (:arm-l :flex -44 :side 16.4)
  (:elbow-l :flex 148.1) (:hand-l :flex 10) (:thigh-r :flex 32) (:thigh-l :flex -20))
(defpose :br-o-kick-r (:base :lb-o-stance)           ; R (-0.12 1.12 1.66): through
  (:root :f 0.1 :u -0.07 :yaw 12 :pitch 5) (:spine :flex 33) (:chest :twist 24) (:neck :flex 36) (:head :flex 14)
  (:arm-r :flex 84.3 :side -72.9) (:elbow-r :flex 68.5) (:hand-r :flex 50) (:arm-l :flex -46.9 :side 17.5)
  (:elbow-l :flex 130) (:hand-l :flex 10) (:thigh-r :flex 32) (:thigh-l :flex -20))
(defpose :br-o-cock-l (:base :lb-o-stance)           ; the mirrors (J2's)
  (:root :f -0.14 :u 0.04 :yaw 12 :pitch -4) (:spine :flex 8) (:chest :twist 26) (:neck :flex 2) (:head :flex -14)
  (:arm-r :flex 17.3 :side 60.3) (:elbow-r :flex 89.3) (:hand-r :flex 10) (:arm-l :flex 118.3 :side -17.9)
  (:elbow-l :flex 79.2) (:hand-l :flex -40) (:thigh-r :flex 14) (:thigh-l :flex -12))
(defpose :br-o-fire-l (:base :lb-o-stance)
  (:root :f 0.2 :u -0.06 :yaw -6 :pitch 4) (:spine :flex 30) (:chest :twist -14) (:neck :flex 34) (:head :flex 12)
  (:arm-r :flex -44 :side 16.4) (:elbow-r :flex 148.1) (:hand-r :flex 10) (:arm-l :flex 93 :side -50.8)
  (:elbow-l :flex 70.8) (:hand-l :flex 30) (:thigh-r :flex -20) (:thigh-l :flex 32))
(defpose :br-o-kick-l (:base :lb-o-stance)
  (:root :f 0.1 :u -0.07 :yaw -12 :pitch 5) (:spine :flex 33) (:chest :twist -24) (:neck :flex 36) (:head :flex 14)
  (:arm-r :flex -46.9 :side 17.5) (:elbow-r :flex 130) (:hand-r :flex 10) (:arm-l :flex 84.3 :side -72.9)
  (:elbow-l :flex 68.5) (:hand-l :flex 50) (:thigh-r :flex -20) (:thigh-l :flex 32))
(defpose :br-o-cock-both (:base :lb-o-stance)        ; J3's spread: R (1.05 2.15 0.2), L mirrored
  (:root :f -0.1 :u 0.07 :pitch -6) (:spine :flex 6) (:neck :flex -12) (:head :flex -22)
  (:arm-r :flex 119.6 :side -74.8) (:elbow-r :flex 86.6) (:hand-r :flex -40) (:arm-l :flex 119.6 :side -74.8)
  (:elbow-l :flex 86.6) (:hand-l :flex -40) (:thigh-r :flex -8) (:thigh-l :flex 8))
(defpose :br-o-fire-both (:base :lb-o-stance)        ; J3's scissor at him: R (-0.08 1.5 1.7), L (0.14 1.62 1.66)
  (:root :f 0.22 :u -0.05 :pitch 5) (:spine :flex 30) (:neck :flex 50) (:head :flex 26)
  (:arm-r :flex 39.8 :side -141.6) (:elbow-r :flex 50.7) (:hand-r :flex 30) (:arm-l :flex 29.4 :side -141.9)
  (:elbow-l :flex 58.5) (:hand-l :flex 30) (:thigh-r :flex 28) (:thigh-l :flex -20))
(defpose :br-o-kick-both (:base :lb-o-stance)        ; blown back, the claws up
  (:root :f -0.2 :u 0.04 :pitch -6) (:spine :flex 10) (:neck :flex 10) (:head :flex -10)
  (:arm-r :flex 98.4 :side -28.2) (:elbow-r :flex 99.9) (:hand-r :flex -30) (:arm-l :flex 98.4 :side -28.2)
  (:elbow-l :flex 99.9) (:hand-l :flex -30) (:thigh-r :flex 6) (:thigh-l :flex -4))
(defpose :br-o-low-both (:base :lb-o-stance)         ; the launch's wind-up: crouched, both claws low before him
  (:root :f 0.1 :u -0.12 :pitch 12) (:spine :flex 38) (:neck :flex 40) (:head :flex 18)
  (:arm-r :flex 90.2 :side -4.3) (:elbow-r :flex 37.4) (:hand-r :flex 50) (:arm-l :flex 88.6 :side -4.1)
  (:elbow-l :flex 45) (:hand-l :flex 50) (:thigh-r :flex 20) (:thigh-l :flex -14))
(defpose :br-o-launch-both (:base :lb-o-stance)      ; the launch: risen, both claws thrown up at him
  (:root :f 0.3 :u 0.16 :pitch -6) (:spine :flex 4) (:neck :flex -6) (:head :flex -14)
  (:arm-r :flex 112 :side -8) (:elbow-r :flex 20) (:hand-r :flex -10) (:arm-l :flex 112 :side -8)
  (:elbow-l :flex 20) (:hand-l :flex -10) (:thigh-r :flex 10) (:thigh-l :flex -10))
(defpose :br-o-raise-both (:base :lb-o-stance)       ; the finisher's wind-up: risen, both claws raised overhead (EN K3's)
  (:root :f 0.1 :u 0.32 :pitch -8) (:spine :flex -10) (:neck :flex -14) (:head :flex -14)
  (:arm-r :flex 103.1 :side -22.4) (:elbow-r :flex 84.7) (:hand-r :flex -40) (:arm-l :flex 103.1 :side -22.4)
  (:elbow-l :flex 84.7) (:hand-l :flex -40))
(defpose :br-o-throw-both (:base :lb-o-stance)       ; the finisher: both claws thrown at him, R (0.2 1.3 2.29)
  (:root :f 0.6 :u 0 :pitch 16) (:spine :flex 34) (:neck :flex 36) (:head :flex 16)
  (:arm-r :flex 106.6 :side 1.3) (:elbow-r :flex 27.5) (:hand-r :flex 40) (:arm-l :flex 106.2 :side 1.2)
  (:elbow-l :flex 33.2) (:hand-l :flex 40))

(defstrike :br-o-recall (8 0 0 :base :lb-o-stance)
  (0) (3 :br-o-open-pose) (6 :br-o-open-pose (:root :u 0.14 :pitch -8)) (:end :br-o-gather-pose))
(defstrike :br-o-rc0 (6 2 24 :base :lb-o-stance)
  (0 :br-o-gather-pose) (3 :br-o-cock-both) (:s :snap :br-o-fire-both) (:a :br-o-fire-both (:root :f 0.26))
  (20 :br-o-kick-both) (:end :lb-o-stance))
(defstrike :br-o-rc1 (6 12 24 :base :lb-o-stance)
  (0 :br-o-gather-pose) (3 :br-o-cock-r) (:s :snap :br-o-fire-r) (9 :br-o-kick-r) (13 :br-o-cock-l) (16 :snap :br-o-fire-l)
  (:a :br-o-kick-l) (30 :br-o-gather-pose) (:end :lb-o-stance))
(defstrike :br-o-rc2 (6 28 24 :base :lb-o-stance)
  (0 :br-o-gather-pose) (3 :br-o-cock-r) (:s :snap :br-o-fire-r) (9 :br-o-kick-r) (12 :br-o-cock-l) (14 :snap :br-o-fire-l)
  (17 :br-o-kick-l) (20 :br-o-cock-r) (22 :snap :br-o-fire-r) (25 :br-o-kick-r) (29 :br-o-low-both)
  (32 :snap :br-o-launch-both) (:a :br-o-launch-both (:root :u 0.2)) (46 :br-o-gather-pose) (:end :lb-o-stance))
(defstrike :br-o-rc3 (6 32 26 :base :lb-o-stance)
  (0 :br-o-gather-pose) (3 :br-o-cock-r) (:s :snap :br-o-fire-r) (8 :br-o-kick-r) (10 :br-o-cock-l) (12 :snap :br-o-fire-l)
  (14 :br-o-kick-l) (16 :br-o-cock-r) (18 :snap :br-o-fire-r) (20 :br-o-kick-r) (22 :br-o-cock-l) (24 :snap :br-o-fire-l)
  (26 :br-o-kick-l) (31 :br-o-raise-both) (35 :br-o-raise-both (:root :u 0.36 :pitch -10))
  (36 :snap :br-o-throw-both) (:a :br-o-throw-both (:root :f 0.64 :u -0.1)) (52 :br-o-gather-pose) (:end :lb-o-stance))
;; 裁き・極 as the owl: six claw throws (R f6 .. L f36), both claws raised high overhead and shaking while the gold blast
;; gathers between them (f38-47), thrown at him on f48 with the Trompete-like blast (BR-DRAW's %BR-KIWAMI-LOOK)
(defstrike :br-o-rc4 (6 44 30 :base :lb-o-stance)
  (0 :br-o-gather-pose) (3 :br-o-cock-r) (:s :snap :br-o-fire-r) (8 :br-o-kick-r) (10 :br-o-cock-l) (12 :snap :br-o-fire-l)
  (14 :br-o-kick-l) (16 :br-o-cock-r) (18 :snap :br-o-fire-r) (20 :br-o-kick-r) (22 :br-o-cock-l) (24 :snap :br-o-fire-l)
  (26 :br-o-kick-l) (28 :br-o-cock-r) (30 :snap :br-o-fire-r) (32 :br-o-kick-r) (34 :br-o-cock-l) (36 :snap :br-o-fire-l)
  (38 :br-o-kick-l) (42 :br-o-raise-both (:root :u 0.4)) (47 :br-o-raise-both (:root :f 0.04 :u 0.46 :pitch -12) (:neck :flex -20))
  (48 :snap :br-o-throw-both) (:a :br-o-throw-both (:root :f 0.7 :u -0.12)) (64 :br-o-gather-pose) (:end :lb-o-stance))
;; the owl EN's ranged L swing (decision V8, as :br-e-swing): reared, the right claw cocked high, raked flat across at him
(defstrike :br-oe-swing (7 3 5 :base :lb-oe-stance)
  (0)
  (3 (:root :f -0.06 :u 0.02 :yaw -6 :pitch -2) (:spine :flex 14) (:chest :twist -14) (:neck :flex 14)
   (:head :flex -4) (:arm-r :flex 88.7 :side -11.4) (:elbow-r :flex 119.2) (:hand-r :flex -20)
   (:arm-l :flex 35.5 :side 53.2) (:elbow-l :flex 85.4) (:hand-l :flex 10))
  (5 (:root :f -0.14 :u 0.04 :yaw -12 :pitch -4) (:spine :flex 8) (:chest :twist -26) (:neck :flex 2)
   (:head :flex -14) (:arm-r :flex 118.3 :side -17.9) (:elbow-r :flex 79.2) (:hand-r :flex -40)
   (:arm-l :flex 17.3 :side 60.3) (:elbow-l :flex 89.3) (:hand-l :flex 10))
  (:s :snap (:root :f 0.5 :u -0.06 :yaw 6 :pitch 4) (:spine :flex 30) (:chest :twist 14) (:neck :flex 34)
   (:head :flex 12) (:arm-r :flex 93 :side -50.8) (:elbow-r :flex 70.8) (:hand-r :flex 30)
   (:arm-l :flex -44 :side 16.4) (:elbow-l :flex 148.1) (:hand-l :flex 10))
  (:a (:root :f 0.56 :u -0.07 :yaw 12 :pitch 5) (:spine :flex 33) (:chest :twist 24) (:neck :flex 36)
   (:head :flex 14) (:arm-r :flex 84.3 :side -72.9) (:elbow-r :flex 68.5) (:hand-r :flex 50)
   (:arm-l :flex -46.9 :side 17.5) (:elbow-l :flex 130) (:hand-l :flex 10))
  (:end :lb-oe-stance))
(defstrike :br-o-to-en (12 0 0 :base :lb-o-stance)   ; KIN -> EN (the form and its lift 0 -> 0.35 at f11)
  (0 :lb-o-fold-pose) (6 (:root :u 0.3 :pitch -6) (:spine :flex 6) (:arm-r :flex -40 :side 40) (:arm-l :flex -40 :side 40))
  (11 (:root :u 0.4 :pitch -6) (:spine :flex 6) (:arm-r :flex -40 :side 40) (:arm-l :flex -40 :side 40))
  (11.5 :snap (:root :u 0.05 :pitch -6) (:spine :flex 6) (:arm-r :flex -40 :side 40) (:arm-l :flex -40 :side 40))
  (:end :lb-oe-stance))
;;; ---------------------------------------------------------------- the base stance's strings (DUEL_LILLE_V3 §8.3, R3)
;;; The stance's three strings and the two routes' follow-ups (barro.lisp *BR-S-SEGS*, BR-DEFSTANCE), each segment its own
;;; clip at its move's frames (S A R, the hits at S + the offsets; played at speed 1), 「架勢中的 JJ / KK / LL 都改成差異明顯的
;;; 數段連擊」, 「最後一段 LL 會依據前面 J/K 有不同的動作模組」. On every hit frame Diagramm's muzzle is on his line (the keys'
;;; comments: the muzzle and the grip in metres, x his right / y up / f ahead, the barrel's azimuth (+ = his right) and
;;; elevation, solved by FK over the rig: the muzzle within 0.1 m of the line at ~2.1 m, level), the recoil right after
;;; (BR-SHOT-FIRE draws the shot from his facing). The openers (L1 / J1 / K1) start from the stance's :lb-kamae-pose; every
;;; later segment from the pose its predecessor holds at its S + A (the link's start). Their ends blend to :lb-stance.
;;; One shot a segment since R7 (DUEL_LILLE_V3 §12, the user 2026-10-11: 「我希望段數跟操作時的點擊次數一致」; 2-4 before):
;;; - L 集 GATHER (L1 L2 L3): shouldered, upright, two hands, an even deliberate beat. L1 squared up, L2 turned side-on (the
;;;   rifleman's profile), L3 a step in and the shot, then Diagramm swung up before him, muzzle high (the pip loaded).
;;; - J 補 REFILL (J1 J2 J3): one hand, from the hip, the free arm out for balance, a small kick. J1 stepped in, J2 hopped to
;;;   his left and low, J3 swayed right shoulder forward, then Diagramm flipped up onto the shoulder.
;;; - K 重 HEAVY (K1 K2 K3): two hands at the waist, wide and low, a big braced recoil that rocks him back. K1 left foot
;;;   forward, K2 switched to the right, K3 the shot blowing him back with Diagramm flung high (the finisher).
;;; - J route's L L (JL1 JL2, one 萬物貫通 line each): J's one-handed lightness. JL1 wound half round and whipped back at
;;;   arm's length, a skip back on the kick; JL2 a hop back, fired from the air at arm's length, landed.
;;; - K route's L L (KL1 KL2): K's two-handed weight. KL1 the knee raised and stamped down into the shot, slid back by it;
;;;   KL2 dropped to the right knee, braced, rocked back on it by the shot.
(defpose :br-pl-aim (:base :lb-aim-pose)   ; L: squared up, shouldered: muzzle (-0.01 1.39 2.10) az -3.1 el -0.1, grip (0.09 1.40 0.35), hand-l (-0.03 1.30 0.59)
  (:root :u -0.05) (:pelvis :twist 8) (:chest :twist -24) (:head :flex 6 :twist 16)
  (:arm-r :flex 56.5 :side -39.4 :twist 63.8) (:elbow-r :flex 82.1) (:hand-r :flex -147.3 :twist -12.1) (:arm-l :flex 68.9 :side -31.0) (:elbow-l :flex 32.0))
(defpose :br-pl-kick (:base :lb-aim-pose)   ; its recoil: muzzle (0.01 1.79 1.93) az -3.2 el 11.9, grip (0.11 1.43 0.22), hand-l (-0.02 1.36 0.50)
  (:root :f -0.07 :u -0.04) (:pelvis :twist 8) (:chest :twist -24 :flex -6) (:head :flex 2 :twist 16)
  (:arm-r :flex 55.1 :side -28.8 :twist 56.8) (:elbow-r :flex 97.2) (:hand-r :flex -151.2 :twist -13.3) (:arm-l :flex 67.0 :side -37.7) (:elbow-l :flex 33.4))
(defpose :br-pl-prof (:base :lb-aim-pose)   ; L2: side-on, shouldered: muzzle (-0.02 1.37 2.13) az -1.9 el 0.1, grip (0.04 1.37 0.38), hand-l (0.12 1.37 0.64)
  (:root :f 0.04 :u -0.09) (:pelvis :twist -14) (:chest :twist -24) (:head :flex 8 :twist 34) (:thigh-l :flex 28 :side 6) (:knee-l :flex 26) (:thigh-r :flex -18 :side 12) (:knee-r :flex 12)
  (:arm-r :flex 40.7 :side -68.5 :twist 94.4) (:elbow-r :flex 61.0) (:hand-r :flex -136.1 :twist -12.8) (:arm-l :flex 80.3 :side -35.4) (:elbow-l :flex 37.9))
(defpose :br-pl-prof-kick (:base :lb-aim-pose)   ; its recoil: muzzle (0.00 1.79 1.95) az -1.9 el 12.0, grip (0.06 1.42 0.24), hand-l (0.12 1.46 0.54)
  (:root :f -0.03 :u -0.08) (:pelvis :twist -14) (:chest :twist -24 :flex -6) (:head :flex 4 :twist 34) (:thigh-l :flex 24 :side 6) (:knee-l :flex 22) (:thigh-r :flex -16 :side 12) (:knee-r :flex 12)
  (:arm-r :flex 42.7 :side -61.6 :twist 89.2) (:elbow-r :flex 78.6) (:hand-r :flex -142.5 :twist -12.8) (:arm-l :flex 80.6 :side -27.6) (:elbow-l :flex 39.1))
(defpose :br-pl-load (:base :lb-aim-pose)   ; L3: loaded, Diagramm swung up: muzzle (0.16 2.84 0.80) az -0.0 el 72.0, grip (0.16 1.18 0.26), hand-l (0.16 1.51 0.37)
  (:root :u -0.02) (:pelvis :twist 10) (:chest :twist -10 :flex -4) (:head :flex -10 :twist 6)
  (:arm-r :flex 9.8 :side 39.6 :twist 40.5) (:elbow-r :flex 116.1) (:hand-r :flex -22.9 :twist -48.6) (:arm-l :flex 118.0 :side 75.0) (:elbow-l :flex 39.9))
(defpose :br-pj-hip (:base :lb-stance)   ; J1: one hand at the hip, stepped in: muzzle (0.09 0.98 2.18) az -7.0 el 0.0, grip (0.30 0.98 0.44), hand-l (-0.58 0.99 -0.12)
  (:root :f 0.08 :u -0.06) (:pelvis :twist 14) (:spine :flex 8) (:chest :twist -2) (:thigh-r :flex 18 :side 6) (:knee-r :flex 24) (:thigh-l :flex -12 :side 6) (:knee-l :flex 16) (:arm-l :flex -24 :side 46) (:elbow-l :flex 34) (:hand-l :flex -10)
  (:arm-r :flex 3.6 :side 16.9 :twist -9.1) (:elbow-r :flex 82.1) (:hand-r :flex -79.5 :twist 1.9))
(defpose :br-pj-kick (:base :lb-stance)   ; its kick: muzzle (0.10 1.27 2.08) az -7.0 el 8.0, grip (0.31 1.03 0.36), hand-l (-0.59 1.08 -0.24)
  (:root :f 0.04 :u -0.02) (:pelvis :twist 14) (:spine :flex 4) (:chest :twist -2) (:thigh-r :flex 16 :side 6) (:knee-r :flex 18) (:thigh-l :flex -10 :side 6) (:knee-l :flex 12) (:arm-l :flex -30 :side 52) (:elbow-l :flex 30) (:hand-l :flex -10)
  (:arm-r :flex -4.8 :side 17.4 :twist -7.6) (:elbow-r :flex 87.6) (:hand-r :flex -72.9 :twist -1.0))
(defpose :br-pj-hop (:base :lb-stance)   ; J2: hopped to his left, low: muzzle (0.03 0.92 2.21) az -3.0 el 0.0, grip (0.12 0.92 0.46), hand-l (-0.87 1.11 0.24)
  (:root :r -0.14 :f 0.04 :u -0.13 :yaw -8) (:pelvis :twist 6) (:spine :flex 14) (:chest :twist 4) (:thigh-l :flex 12 :side 22) (:knee-l :flex 34) (:thigh-r :flex -6 :side 6) (:knee-r :flex 12) (:arm-l :flex 6 :side 74) (:elbow-l :flex 22) (:hand-l :flex -10)
  (:arm-r :flex 21.4 :side 17.8 :twist 8.6) (:elbow-r :flex 80.9) (:hand-r :flex -88.8 :twist -11.6))
(defpose :br-pj-hop-kick (:base :lb-stance)   ; its kick: muzzle (0.04 1.21 2.11) az -3.0 el 8.0, grip (0.13 0.97 0.38), hand-l (-0.91 1.23 0.12)
  (:root :r -0.14 :f 0.0 :u -0.08 :yaw -8) (:pelvis :twist 6) (:spine :flex 10) (:chest :twist 4) (:thigh-l :flex 10 :side 22) (:knee-l :flex 28) (:thigh-r :flex -6 :side 6) (:knee-r :flex 10) (:arm-l :flex 0 :side 80) (:elbow-l :flex 18) (:hand-l :flex -10)
  (:arm-r :flex 13.2 :side 20.1 :twist 10.2) (:elbow-r :flex 83.8) (:hand-r :flex -79.6 :twist -15.2))
(defpose :br-pj-sway-r (:base :lb-stance)   ; J3: swayed, right shoulder forward: muzzle (0.10 1.00 2.21) az -4.0 el 0.0, grip (0.22 1.00 0.46), hand-l (-0.38 1.01 -0.28)
  (:root :r 0.08 :f 0.06 :u -0.07 :yaw 14) (:pelvis :twist 10) (:spine :flex 8 :side -4) (:chest :twist 0) (:thigh-r :flex 20 :side 8) (:knee-r :flex 26) (:thigh-l :flex -12 :side 8) (:knee-l :flex 16) (:arm-l :flex -34 :side 40) (:elbow-l :flex 40) (:hand-l :flex -10)
  (:arm-r :flex 2.6 :side 20.3 :twist 6.0) (:elbow-r :flex 98.3) (:hand-r :flex -99.3 :twist -27.9))
(defpose :br-pj-sway-l (:base :lb-stance)   ; J3: swayed back, left shoulder forward: muzzle (0.07 0.96 2.21) az -3.0 el -0.0, grip (0.16 0.96 0.46), hand-l (-0.73 1.03 0.35)
  (:root :r -0.06 :f 0.06 :u -0.09 :yaw -14) (:pelvis :twist 10) (:spine :flex 10 :side 4) (:chest :twist 0) (:thigh-l :flex 22 :side 8) (:knee-l :flex 28) (:thigh-r :flex -10 :side 8) (:knee-r :flex 14) (:arm-l :flex 10 :side 66) (:elbow-l :flex 24) (:hand-l :flex -10)
  (:arm-r :flex 26.6 :side 7.8 :twist 21.5) (:elbow-r :flex 67.9) (:hand-r :flex -83.7 :twist -15.3))
(defpose :br-pj-shoulder (:base :lb-stance)   ; J3: flipped up onto the shoulder: muzzle (0.10 2.95 0.99) az -10.0 el 62.0, grip (0.24 1.40 0.18), hand-l (-0.37 1.05 0.28)
  (:root :u -0.02) (:pelvis :twist 10) (:spine :flex -2) (:chest :twist -6) (:head :flex -4 :twist -6) (:arm-l :flex 10 :side 20) (:elbow-l :flex 60) (:hand-l :flex -20)
  (:arm-r :flex 31.8 :side 16.0 :twist -11.2) (:elbow-r :flex 153.2) (:hand-r :flex -125.9 :twist -1.0))
(defpose :br-pj-sway-r-k (:base :lb-stance)   ; J3 R kick: muzzle (0.11 1.29 2.11) az -4.0 el 8.0, grip (0.23 1.05 0.38), hand-l (-0.37 1.10 -0.39)
  (:root :r 0.08 :f 0.02 :u -0.03 :yaw 14) (:pelvis :twist 10) (:spine :flex 4 :side -4) (:chest :twist 0) (:thigh-r :flex 18 :side 8) (:knee-r :flex 20) (:thigh-l :flex -10 :side 8) (:knee-l :flex 12) (:arm-l :flex -40 :side 46) (:elbow-l :flex 36) (:hand-l :flex -10)
  (:arm-r :flex -2.6 :side 26.0 :twist 17.0) (:elbow-r :flex 103.3) (:hand-r :flex -95.6 :twist -40.1))
(defpose :br-pj-sway-l-k (:base :lb-stance)   ; J3 L kick: muzzle (0.08 1.25 2.11) az -3.0 el 8.0, grip (0.17 1.01 0.38), hand-l (-0.78 1.13 0.25)
  (:root :r -0.06 :f 0.02 :u -0.05 :yaw -14) (:pelvis :twist 10) (:spine :flex 6 :side 4) (:chest :twist 0) (:thigh-l :flex 20 :side 8) (:knee-l :flex 22) (:thigh-r :flex -8 :side 8) (:knee-r :flex 10) (:arm-l :flex 6 :side 72) (:elbow-l :flex 20) (:hand-l :flex -10)
  (:arm-r :flex 18.2 :side 12.3 :twist 21.1) (:elbow-r :flex 74.9) (:hand-r :flex -77.8 :twist -17.9))
(defpose :br-pk-brace (:base :lb-kamae-pose)   ; K1: braced at the waist, left foot forward: muzzle (0.02 1.01 2.05) az -3.0 el -0.1, grip (0.12 1.01 0.30), hand-l (0.07 0.89 0.62)
  (:root :f 0.06 :u -0.27 :pitch 6) (:pelvis :twist 6) (:spine :flex 10) (:chest :twist -20) (:head :flex 4 :twist 16) (:thigh-l :flex 46 :side 22) (:knee-l :flex 60) (:thigh-r :flex -26 :side 24) (:knee-r :flex 40)
  (:arm-r :flex 30.3 :side 0.2 :twist 49.7) (:elbow-r :flex 132.4) (:hand-r :flex -147.9 :twist -32.0) (:arm-l :flex 51.1 :side -56.6) (:elbow-l :flex 34.8))
(defpose :br-pk-kick (:base :lb-kamae-pose)   ; its recoil, rocked back: muzzle (0.04 1.85 1.69) az -3.1 el 24.0, grip (0.13 1.14 0.09), hand-l (0.03 1.18 0.27)
  (:root :f -0.16 :u -0.2 :pitch -8) (:pelvis :twist 6) (:spine :flex -6) (:chest :twist -14) (:head :flex -4 :twist 14) (:thigh-l :flex 36 :side 22) (:knee-l :flex 44) (:thigh-r :flex -16 :side 24) (:knee-r :flex 30)
  (:arm-r :flex 33.4 :side 2.5 :twist 35.9) (:elbow-r :flex 98.6) (:hand-r :flex -122.9 :twist -22.6) (:arm-l :flex 51.2 :side -49.3) (:elbow-l :flex 29.6))
(defpose :br-pk-brace2 (:base :lb-kamae-pose)   ; K2: the right foot forward, lower: muzzle (0.02 1.01 2.06) az -5.1 el 1.9, grip (0.18 0.95 0.32), hand-l (0.11 0.86 0.61)
  (:root :f 0.1 :u -0.26 :pitch 10) (:pelvis :twist 20) (:spine :flex 14) (:chest :twist -26) (:head :flex 2 :twist 6) (:thigh-r :flex 36 :side 18) (:knee-r :flex 56) (:thigh-l :flex -20 :side 18) (:knee-l :flex 30)
  (:arm-r :flex 6.2 :side 31.5 :twist 40.3) (:elbow-r :flex 145.1) (:hand-r :flex -117.1 :twist -42.3) (:arm-l :flex 38.5 :side -67.5) (:elbow-l :flex 32.1))
(defpose :br-pk-kick2 (:base :lb-kamae-pose)   ; its recoil: muzzle (0.05 1.85 1.68) az -5.1 el 26.0, grip (0.19 1.08 0.11), hand-l (0.07 1.13 0.29)
  (:root :f -0.12 :u -0.18 :pitch -6) (:pelvis :twist 20) (:spine :flex 0) (:chest :twist -20) (:head :flex -4 :twist 6) (:thigh-r :flex 28 :side 18) (:knee-r :flex 40) (:thigh-l :flex -12 :side 18) (:knee-l :flex 20)
  (:arm-r :flex 12.3 :side 22.8 :twist 24.8) (:elbow-r :flex 120.5) (:hand-r :flex -111.4 :twist -27.9) (:arm-l :flex 40.5 :side -62.3) (:elbow-l :flex 28.7))
(defpose :br-pk-blown (:base :lb-kamae-pose)   ; K3's finisher: blown back, Diagramm flung high: muzzle (0.07 2.42 1.33) az -3.2 el 40.2, grip (0.15 1.29 -0.01), hand-l (0.00 1.37 -0.02)
  (:root :f -0.36 :u -0.1 :pitch -14) (:pelvis :twist 6) (:spine :flex -14) (:chest :twist -12) (:head :flex -8 :twist 10) (:thigh-l :flex 34 :side 14) (:knee-l :flex 20) (:thigh-r :flex -8 :side 16) (:knee-r :flex 30)
  (:arm-r :flex 53.4 :side -11.2 :twist 41.7) (:elbow-r :flex 36.4) (:hand-r :flex -81.7 :twist -19.6) (:arm-l :flex 53.7 :side -44.8) (:elbow-l :flex 25.7))
(defpose :br-pjl-wind (:base :lb-stance)   ; JL1: wound half round, Diagramm tucked: muzzle (1.66 1.07 -0.16) az 101.8 el 0.6, grip (-0.05 1.05 0.20), hand-l (-0.42 1.07 -0.33)
  (:root :f -0.02 :u -0.1 :yaw 70) (:pelvis :twist 10) (:spine :flex 10) (:chest :twist 10) (:thigh-r :flex 10 :side 8) (:knee-r :flex 22) (:thigh-l :flex -4 :side 8) (:knee-l :flex 20) (:arm-l :flex 30 :side 30) (:elbow-l :flex 70) (:hand-l :flex -10)
  (:arm-r :flex 14.6 :side -74.4 :twist -83.1) (:elbow-r :flex 127.4) (:hand-r :flex 19.7 :twist -88.8))
(defpose :br-pjl-whip (:base :lb-stance)   ; JL1: whipped back at arm's length: muzzle (0.04 1.16 2.33) az -2.0 el 0.0, grip (0.10 1.16 0.58), hand-l (-0.65 1.29 -0.04)
  (:root :f 0.1 :u -0.08 :yaw -16) (:pelvis :twist 4) (:spine :flex 8 :side -6) (:chest :twist 0) (:thigh-r :flex 30 :side 10) (:knee-r :flex 30) (:thigh-l :flex -18 :side 10) (:knee-l :flex 12) (:arm-l :flex -40 :side 70) (:elbow-l :flex 16) (:hand-l :flex -10)
  (:arm-r :flex 56.5 :side -42.6 :twist 76.0) (:elbow-r :flex 38.4) (:hand-r :flex -105.6 :twist -22.9))
(defpose :br-pjl-skip (:base :lb-stance)   ; its kick: skipped back: muzzle (0.09 1.74 2.08) az -2.0 el 16.1, grip (0.15 1.25 0.40), hand-l (-0.75 1.40 -0.25)
  (:root :f -0.12 :u 0.06 :yaw -10) (:pelvis :twist 4) (:spine :flex -2 :side -4) (:chest :twist 0) (:thigh-r :flex 34 :side 10) (:knee-r :flex 50) (:thigh-l :flex -6 :side 10) (:knee-l :flex 30) (:arm-l :flex -30 :side 76) (:elbow-l :flex 20) (:hand-l :flex -10)
  (:arm-r :flex 65.8 :side -34.7 :twist 63.4) (:elbow-r :flex -0.1) (:hand-r :flex -61.5 :twist -18.8))
(defpose :br-pjl-hop (:base :lb-stance)   ; JL2: in the air, hopping back, arm's length: muzzle (0.08 1.30 2.12) az -3.1 el -5.6, grip (0.18 1.47 0.38), hand-l (-0.77 1.61 -0.25)
  (:root :f -0.16 :u 0.3 :pitch -4) (:pelvis :twist 10) (:spine :flex 4) (:chest :twist -4) (:thigh-r :flex 46 :side 8) (:knee-r :flex 80) (:thigh-l :flex 20 :side 8) (:knee-l :flex 60) (:arm-l :flex -10 :side 80) (:elbow-l :flex 20) (:hand-l :flex -10)
  (:arm-r :flex 68.8 :side 0.2 :twist 16.4) (:elbow-r :flex -0.1) (:hand-r :flex -75.8 :twist -7.0))
(defpose :br-pjl-hop-kick (:base :lb-stance)   ; its kick: muzzle (0.10 1.98 1.95) az -3.1 el 14.3, grip (0.19 1.55 0.26), hand-l (-0.75 1.66 -0.52)
  (:root :f -0.24 :u 0.32 :pitch -8) (:pelvis :twist 10) (:spine :flex -4) (:chest :twist -4) (:thigh-r :flex 40 :side 8) (:knee-r :flex 70) (:thigh-l :flex 16 :side 8) (:knee-l :flex 50) (:arm-l :flex -20 :side 86) (:elbow-l :flex 16) (:hand-l :flex -10)
  (:arm-r :flex 63.6 :side 2.7 :twist 17.3) (:elbow-r :flex -0.1) (:hand-r :flex -63.2 :twist -11.1))
(defpose :br-pkl-load (:base :lb-kamae-pose)   ; KL1: the knee raised, Diagramm drawn back: muzzle (0.08 1.33 1.87) az -3.1 el 6.1, grip (0.17 1.14 0.14), hand-l (0.09 1.15 0.39)
  (:root :f -0.04 :u -0.02 :pitch -2) (:pelvis :twist 10) (:spine :flex 2) (:chest :twist -22) (:head :flex 4 :twist 18) (:thigh-l :flex 72 :side 10) (:knee-l :flex 84) (:thigh-r :flex -4 :side 8) (:knee-r :flex 10)
  (:arm-r :flex 6.3 :side 19.0 :twist 41.9) (:elbow-r :flex 114.9) (:hand-r :flex -109.8 :twist -29.7) (:arm-l :flex 39.3 :side -41.4) (:elbow-l :flex 29.6))
(defpose :br-pkl-shot (:base :lb-kamae-pose)   ; KL1: stamped down, deep and wide: muzzle (0.03 0.95 2.09) az -3.0 el -0.1, grip (0.12 0.95 0.34), hand-l (0.10 0.82 0.68)
  (:root :f 0.12 :u -0.3 :pitch 8) (:pelvis :twist 4) (:spine :flex 12) (:chest :twist -22) (:head :flex 4 :twist 18) (:thigh-l :flex 48 :side 18) (:knee-l :flex 62) (:thigh-r :flex -28 :side 20) (:knee-r :flex 34)
  (:arm-r :flex 27.4 :side 5.6 :twist 56.0) (:elbow-r :flex 134.9) (:hand-r :flex -140.4 :twist -38.3) (:arm-l :flex 51.2 :side -53.6) (:elbow-l :flex 36.3))
(defpose :br-pkl-kick (:base :lb-kamae-pose)   ; its recoil, slid back: muzzle (0.05 2.05 1.54) az -3.1 el 32.1, grip (0.13 1.12 0.06), hand-l (0.02 1.20 0.18)
  (:root :f -0.24 :u -0.22 :pitch -10) (:pelvis :twist 4) (:spine :flex -8) (:chest :twist -16) (:head :flex -6 :twist 16) (:thigh-l :flex 40 :side 18) (:knee-l :flex 40) (:thigh-r :flex -14 :side 20) (:knee-r :flex 28)
  (:arm-r :flex 41.1 :side -5.0 :twist 42.7) (:elbow-r :flex 73.0) (:hand-r :flex -102.0 :twist -22.3) (:arm-l :flex 55.5 :side -41.4) (:elbow-l :flex 28.8))
(defpose :br-pkl-kneel (:base :lb-kamae-pose)   ; KL2: down on the right knee, braced: muzzle (0.02 0.91 2.09) az -3.1 el -0.1, grip (0.11 0.91 0.34), hand-l (0.04 0.81 0.62)
  (:root :f 0.04 :u -0.38 :pitch 6) (:pelvis :twist 8) (:spine :flex 8) (:chest :twist -22) (:head :flex 6 :twist 16) (:thigh-l :flex 82 :side 10) (:knee-l :flex 84) (:thigh-r :flex -4 :side 10) (:knee-r :flex 100)
  (:arm-r :flex 36.8 :side -5.4 :twist 45.3) (:elbow-r :flex 119.8) (:hand-r :flex -144.8 :twist -23.9) (:arm-l :flex 55.6 :side -54.1) (:elbow-l :flex 33.5))
(defpose :br-pkl-rock (:base :lb-kamae-pose)   ; its recoil, rocked back on the knee: muzzle (0.05 2.14 1.46) az -3.1 el 36.0, grip (0.13 1.11 0.04), hand-l (0.01 1.16 0.15)
  (:root :f -0.18 :u -0.34 :pitch -16) (:pelvis :twist 8) (:spine :flex -12) (:chest :twist -14) (:head :flex -8 :twist 12) (:thigh-l :flex 70 :side 10) (:knee-l :flex 64) (:thigh-r :flex -14 :side 10) (:knee-r :flex 96)
  (:arm-r :flex 46.4 :side -4.1 :twist 35.2) (:elbow-r :flex 78.9) (:hand-r :flex -119.4 :twist -18.0) (:arm-l :flex 54.4 :side -51.9) (:elbow-l :flex 28.2))
;; L: GATHER, shouldered (keys: the hit poses' muzzle / az / el in the poses' comments)
(defstrike :br-sk-l1 (8 2 14 :base :lb-kamae-pose)   ; squared up: one shot f8
  (0) (5 :br-pl-aim (:root :u -0.03) (:head :flex 2))
  (:s :br-pl-aim) (:a :snap :br-pl-kick) (16 :br-pl-aim (:root :f -0.03 :u -0.04))
  (:end :lb-stance))
(defstrike :br-sk-l2 (8 2 14 :base :lb-kamae-pose)   ; turned side-on: one shot f8
  (0 :br-pl-kick) (5 :br-pl-prof (:root :u -0.07))
  (:s :br-pl-prof) (:a :snap :br-pl-prof-kick) (16 :br-pl-prof (:root :f 0))
  (:end :lb-stance))
(defstrike :br-sk-l3 (8 2 18 :base :lb-kamae-pose)   ; a step in, one shot f8, Diagramm swung up: loaded
  (0 :br-pl-prof-kick) (5 :br-pl-aim (:root :f 0.12 :u -0.07))
  (:s :br-pl-aim (:root :f 0.12)) (:a :snap :br-pl-kick (:root :f 0.06))
  (16 :br-pl-load (:root :f 0.06)) (22 :br-pl-load (:root :f 0.04) (:head :flex -12))
  (:end :lb-stance))
;; J: REFILL, one hand from the hip, a kick on the shot, back on the line 2 f later
(defstrike :br-sk-j1 (8 2 12 :base :lb-kamae-pose)    ; stepped in: one shot f8
  (0) (4 :br-pj-hip (:root :u -0.1))
  (:s :br-pj-hip) (9 :snap :br-pj-kick) (11 :br-pj-hip) (16 :br-pj-hip (:root :f 0.04 :u -0.04))
  (:end :lb-stance))
(defstrike :br-sk-j2 (8 2 12 :base :lb-kamae-pose)    ; hopped to his left, low: one shot f8
  (0 :br-pj-hip) (3 :br-pj-hop (:root :r -0.08 :u 0.04)) (6 :br-pj-hop (:root :u -0.17))
  (:s :br-pj-hop) (9 :snap :br-pj-hop-kick) (11 :br-pj-hop) (16 :br-pj-hop (:root :r -0.08 :u -0.08))
  (:end :lb-stance))
(defstrike :br-sk-j3 (8 2 14 :base :lb-kamae-pose)   ; swayed, right shoulder forward: one shot f8; flipped up onto the shoulder
  (0 :br-pj-hop) (5 :br-pj-sway-r (:root :u -0.04))
  (:s :br-pj-sway-r) (9 :snap :br-pj-sway-r-k) (11 :br-pj-sway-r) (16 :br-pj-shoulder) (20 :br-pj-shoulder (:head :flex -8))
  (:end :lb-stance))
;; K: HEAVY, two hands at the waist, braced; the shot rocks him back
(defstrike :br-sk-k1 (12 2 18 :base :lb-kamae-pose)  ; left foot forward: one shot f12
  (0) (5 :br-pk-brace (:root :f 0 :u -0.2)) (10 :br-pk-brace (:root :u -0.29))
  (:s :br-pk-brace) (14 :snap :br-pk-kick) (24 :br-pk-brace (:root :f -0.06 :u -0.2))
  (:end :lb-stance))
(defstrike :br-sk-k2 (12 2 18 :base :lb-kamae-pose)  ; switched to the right foot, lower: one shot f12
  (0 :br-pk-kick) (6 :br-pk-brace2 (:root :f 0 :u -0.18)) (10 :br-pk-brace2 (:root :u -0.28))
  (:s :br-pk-brace2) (14 :snap :br-pk-kick2) (24 :br-pk-brace2 (:root :f -0.04 :u -0.18))
  (:end :lb-stance))
(defstrike :br-sk-k3 (12 2 22 :base :lb-kamae-pose)  ; one shot f12 blowing him back, Diagramm flung high (the finisher)
  (0 :br-pk-kick2) (6 :br-pk-brace (:root :u -0.2)) (10 :br-pk-brace (:root :f 0.08 :u -0.31))
  (:s :br-pk-brace (:root :f 0.08 :u -0.31)) (15 :snap :br-pk-blown) (22 :br-pk-blown (:root :f -0.4 :u -0.14))
  (30 :br-pk-brace (:root :f -0.2 :u -0.18))
  (:end :lb-stance))
;; the J route's L L: one hand, light (one line each)
(defstrike :br-sk-jl1 (8 2 14 :base :lb-kamae-pose)   ; wound half round, whipped back at arm's length (f8), skipped back
  (0 :br-pj-sway-l-k) (4 :br-pjl-wind)
  (:s :snap :br-pjl-whip) (10 :snap :br-pjl-skip)
  (15 :br-pjl-skip (:root :f -0.1 :u -0.06) (:knee-r :flex 30) (:thigh-r :flex 20))
  (19 :br-pj-hip (:root :f -0.06))
  (:end :lb-stance))
(defstrike :br-sk-jl2 (8 2 14 :base :lb-kamae-pose)   ; spun round on the spot, Diagramm tucked, out of the spin low at
  (0 :br-pjl-skip) (3 :br-pjl-wind (:root :yaw -70))  ;  arm's length (f8, J2's solved hop pose), the kick
  (6 :br-pjl-wind (:root :yaw -160 :u -0.06))
  (:s :snap :br-pj-hop) (10 :snap :br-pj-hop-kick)
  (16 :br-pj-hop-kick (:root :f -0.12))
  (:end :lb-stance))
(defstrike :br-sk-jl3 (8 2 16 :base :lb-kamae-pose)   ; crouched, a hop back, fired from the air (f8), landed
  (0 :br-pjl-skip) (3 :br-pj-hip (:root :f -0.04 :u -0.2) (:thighs :flex 34) (:knees :flex 52))
  (:s :snap :br-pjl-hop) (10 :snap :br-pjl-hop-kick)
  (15 :br-pj-hip (:root :f -0.24 :u -0.18) (:thighs :flex 32) (:knees :flex 48))
  (20 :br-pj-hip (:root :f -0.12 :u -0.06))
  (:end :lb-stance))
;; the K route's L L: two hands, heavy (one line each)
(defstrike :br-sk-kl1 (10 2 16 :base :lb-kamae-pose)  ; the knee raised, stamped down into the shot (f10), slid back
  (0 :br-pk-kick) (5 :br-pkl-load) (8 :br-pkl-shot (:root :f 0.08 :u -0.24))
  (:s :br-pkl-shot) (12 :snap :br-pkl-kick)
  (20 :br-pkl-kick (:root :f -0.3 :u -0.18))
  (:end :lb-stance))
(defstrike :br-sk-kl2 (10 2 16 :base :lb-kamae-pose)  ; down on the right knee (f10), rocked back on it, kept down
  (0 :br-pkl-kick) (6 :br-pkl-kneel (:root :u -0.32))
  (:s :br-pkl-kneel) (12 :snap :br-pkl-rock)
  (20 :br-pkl-rock (:root :f -0.18))
  (:end :lb-stance))
(defstrike :br-sk-kl3 (10 2 20 :base :lb-kamae-pose)  ; from the knee, the long held aim, the big shot (f10) throws him
  (0 :br-pkl-rock) (6 :br-pkl-kneel (:head :flex 10))   ;  up and back, Diagramm flung high (K3's finisher pose), risen
  (:s :br-pkl-kneel) (12 :snap :br-pk-blown (:root :f -0.36 :u -0.1))
  (22 :br-pk-blown (:root :f -0.46))
  (27 :br-pk-brace (:root :f -0.22 :u -0.2))
  (:end :lb-stance))
;;; ---------------------------------------------------------------- the stance's L L follow-ups (DUEL_LILLE_V3 §8.5)
;;; Decision R3 (the user, 2026-10-11): 「架式 > JJ/KK > LL 中，最後一段 LL 會依據前面 J/K 有不同的動作模組」, three segments
;;; (「每段花 1，共 3」), each one 萬物貫通 line fired on S (barro.lisp's BR-DEFSTANCE; the clips at their moves' own frames,
;;; :clip-s = startup). The L style carried on (「風格延續」: one line a beat, as the L string), the route's own body:
;;; - the J route 疾射 (S 8, A 2, R 14 / 14 / 16): light, on the move, one wing / claw a beat from a slide, both from a
;;;   hop back;
;;; - the K route 重砲 (S 10, A 2, R 16 / 16 / 20): planted and heavy, both at once every beat.
;;; JILLIEL EN fires from the front wings, the owl EN from its claws (the base form's follow-ups are above, solved on
;;; Diagramm's muzzle: JL1 the whip, JL2 the spin, JL3 the hop back; KL1 the stamp, KL2 the kneel, KL3 the finisher from
;;; the knee). The root's side / back offsets are the clip's only: the sim does not move him.
;; JILLIEL EN: 疾射 a single front wing thrust at him from a slide (the right from his right, the left from his left), then
;; both from a hop back; 重砲 both wings at once every beat, planted: swept up from low, slammed down from high, the
;; NIJUSHI-KO ring held and its recoil
(defstrike :br-e-jf1 (8 2 14 :base :lb-w-stance)
  (0) (3 :br-cock-r (:root :r -0.2)) (6 :br-cock-r (:root :r -0.36 :u 0.14))
  (:s :snap :br-fire-r (:root :r -0.4)) (:a :br-kick-r (:root :r -0.4)) (18 :br-settle-both (:root :f -0.1 :r -0.22 :u 0.04))
  (:end :lb-w-stance))
(defstrike :br-e-jf2 (8 2 14 :base :lb-w-stance)
  (0 :lb-w-stance (:root :r -0.2)) (3 :br-cock-l (:root :r 0.14)) (6 :br-cock-l (:root :r 0.36 :u 0.14))
  (:s :snap :br-fire-l (:root :r 0.4)) (:a :br-kick-l (:root :r 0.4)) (18 :br-settle-both (:root :f -0.1 :r 0.22 :u 0.04))
  (:end :lb-w-stance))
(defstrike :br-e-jf3 (8 2 16 :base :lb-w-stance)
  (0 :lb-w-stance (:root :r 0.2)) (3 :br-cock-both (:root :u 0.06)) (6 :br-cock-both (:root :f -0.3 :u 0.3))
  (:s :snap :br-fire-both (:root :f -0.08 :u 0.34)) (:a :br-kick-both (:root :f -0.4 :u 0.3))
  (18 :br-settle-both (:root :f -0.42 :u 0.1)) (:end :lb-w-stance))
(defstrike :br-e-kf1 (10 2 16 :base :lb-w-stance)
  (0) (5 :br-low-both) (9 :br-low-both (:root :f -0.08 :u -0.08))
  (:s :snap :br-fire-both (:root :f 0.1 :u -0.02)) (:a :br-kick-both) (20 :br-settle-both) (:end :lb-w-stance))
(defstrike :br-e-kf2 (10 2 16 :base :lb-w-stance)
  (0) (5 :br-cock-both) (9 :br-cock-both (:root :u 0.22 :pitch -8))
  (:s :snap :br-fire-both (:root :f 0.16 :u -0.04 :pitch 8) (:spine :flex 20)) (:a :br-kick-both (:root :f -0.36))
  (20 :br-settle-both) (:end :lb-w-stance))
(defstrike :br-e-kf3 (10 2 20 :base :lb-w-stance)
  (0) (4 :br-ring-pose (:root :u 0.2)) (9 :br-ring-pose (:root :f -0.1 :u 0.34 :pitch -4) (:spine :flex -10))
  (:s :snap :br-fire-both (:root :f 0.0 :u 0.3)) (:a :br-blown-pose (:root :f -0.56 :u 0.38))
  (24 :br-settle-both (:root :u 0.14)) (:end :lb-w-stance))
;; the owl EN: the same two bodies on its claws (the volley's solved keys)
(defstrike :br-oe-jf1 (8 2 14 :base :lb-oe-stance)
  (0) (3 :br-o-cock-r (:root :r -0.2)) (6 :br-o-cock-r (:root :r -0.34))
  (:s :snap :br-o-fire-r (:root :r -0.38 :f 0.1)) (:a :br-o-kick-r (:root :r -0.38 :f 0.06))
  (18 :lb-oe-stance (:root :r -0.18)) (:end :lb-oe-stance))
(defstrike :br-oe-jf2 (8 2 14 :base :lb-oe-stance)
  (0 :lb-oe-stance (:root :r -0.18)) (3 :br-o-cock-l (:root :r 0.14)) (6 :br-o-cock-l (:root :r 0.34))
  (:s :snap :br-o-fire-l (:root :r 0.38 :f 0.1)) (:a :br-o-kick-l (:root :r 0.38 :f 0.06))
  (18 :lb-oe-stance (:root :r 0.18)) (:end :lb-oe-stance))
(defstrike :br-oe-jf3 (8 2 16 :base :lb-oe-stance)
  (0 :lb-oe-stance (:root :r 0.18)) (3 :br-o-cock-both (:root :u 0.1)) (6 :br-o-cock-both (:root :f -0.3 :u 0.3))
  (:s :snap :br-o-fire-both (:root :f -0.06 :u 0.3)) (:a :br-o-kick-both (:root :f -0.4 :u 0.26))
  (18 :br-o-kick-both (:root :f -0.3 :u 0.1)) (:end :lb-oe-stance))
(defstrike :br-oe-kf1 (10 2 16 :base :lb-oe-stance)
  (0) (5 :br-o-low-both) (9 :br-o-low-both (:root :u -0.16))
  (:s :snap :br-o-launch-both) (:a :br-o-launch-both (:root :f 0.2 :u 0.2)) (20 :br-o-kick-both) (:end :lb-oe-stance))
(defstrike :br-oe-kf2 (10 2 16 :base :lb-oe-stance)
  (0) (5 :br-o-open-pose) (9 :br-o-open-pose (:root :u 0.16 :pitch -9))
  (:s :snap :br-o-throw-both (:root :f 0.3)) (:a :br-o-throw-both (:root :f 0.2 :u 0.04)) (20 :br-o-kick-both)
  (:end :lb-oe-stance))
(defstrike :br-oe-kf3 (10 2 20 :base :lb-oe-stance)
  (0) (4 :br-o-raise-both) (9 :br-o-raise-both (:root :u 0.38 :pitch -10))
  (:s :snap :br-o-throw-both) (:a :br-o-throw-both (:root :f 0.5 :u -0.1)) (24 :br-o-kick-both (:root :f -0.1))
  (:end :lb-oe-stance))
;;; ---------------------------------------------------------------- the stance EN's own strings (DUEL_LILLE_V3 §8, R3; §10, R5)
;;; Decision R3 (the user, 2026-10-11: 「架勢中的 JJ / KK / LL 都改成差異明顯的數段連擊」): the awakened stance's moves
;;; (BR-DEFSTANCE's *BR-S-SEGS*) play clips of their own, each S + A + R long with its :s mark on S; the openers are melee
;;; strikes since R4 (each hit's reach *BR-W-TIPS* = the striking tip's distance ahead on its hit frame, within 0.5 m of his
;;; line: the host FK test, drawn reach = hit reach +-0.15 m). R5 motion modules (the user, 2026-10-11: 「架式 > LL / JJ / KK
;;; 將動作模組差異化，例如像陀螺旋朝前方傾斜轉三圈揮舞光翼、爆炸特效的零距離砲擊，將光翼拉伸如同長鞭一般鞭擊、又如同大刀一般
;;; 遲緩而沈重的揮砍」; the reach 「跟著動作走」; then 「長鞭可以連成大砍刀，砲擊也可以接在近距離毆打後面」: the modules combined
;;; within a string), the front wings (JILLIEL, the rig's hands at :arms 2.6) or the claws (the owl, :arms 2.2 :legs 1.5)
;;; doing them:
;;; - L 陀螺 (L1 / L2 / L3): a spinning top tilted at him, both wings swung out flat: the spin is the pelvis's twist inside the
;;;   root's forward pitch (the axis stays leaning at him while all above the pelvis turns), a wing crossing his line on each
;;;   hit (+90 the right, +270 the left); L1 one turn (upright), L2 one more (leaning lower, the sweep dipped), L3 one and a half,
;;;   spun up and rising (every 6 f); reach the flat wing's tip (~1.8 m). The table wings spin with him (*LB-NO-CONV*).
;;; - J 長鞭 -> 大砍刀 (J1 / J2 / J3, the snake sword): the wings stretched like whips (*BR-W-STRETCH*: JILLIEL's blades
;;;   drawn on past the hands, the owl's gold lashes on from its claws), cracked every 3 f in crossing figure-eights: J1 from
;;;   high outside down across him R L R, J2 from low outside up across him L R L, J3 R L R and then the whips snap rigid,
;;;   shortened and joined into one cleaver, chopped down (the K great blade's pose); reach the stretched tip (~2.8 m, the
;;;   cleaver ~2.4 m).
;;; - K 大刀 -> 近身 -> 零距離砲擊 (K1 / K2 / K3): K1 both wings joined into one great blade (the hands together on his line),
;;;   the long held overhead wind-up, the chop with the whole body, buried low, hauled back up through him (~1.8-2.0 m); K2
;;;   stepped in, beaten with the folded wings, the right clubbed down, the left (~1.3 m); K3 a hook with the left folded
;;;   wing, the right clubbed down, then 零距離砲擊: both tips thrust into him at point blank (~1.2 m), the blast
;;;   (%BR-BLAST-LOOK) between them, blown back.
;;; R6 (§11) made the great blade one wing a chop, grown on the pull (J3's last, K1), and the blast a ball of light; R7
;;; (§12, the user 2026-10-11: 「我希望段數跟操作時的點擊次數一致」) one strike a press: L1 / L2 / L3 one top turn each (the
;;; spin carried across the links), J1 / J2 one whip each, J3 the cleaver (S 14), K1 the great blade (S 16), K2 one
;;; folded-wing blow, K3 the cannon.
;;; Every key starts from a named pose, so a key's overrides never leak into the next. Tips in m (right, up, ahead) are the
;;; host's FK; the arm angles at the hit poses were solved to them.

;; JILLIEL EN's poses (base :lb-w-stance: the front wings' tips are the rig's hands)
;; L 陀螺: the spin is the pelvis's twist (inside the root's forward tilt: the axis leans at him and stays leaning while
;; everything above the pelvis turns); +90 puts the right wing on his line, +270 the left
(defpose :br-en-wind (:base :lb-w-stance)          ; the top wound up: coiled back to the right, the wings drawn in
  (:root :u 0.02 :pitch 4) (:pelvis :twist -40) (:spine :flex 6) (:chest :twist -22) (:head :flex 6)
  (:arm-r :flex 36 :side 54) (:elbow-r :flex 58) (:arm-l :flex 48 :side 36) (:elbow-l :flex 64))
(defpose :br-en-top (:base :lb-w-stance)           ; L1's top: tilted forward, both wings swung out flat
  (:root :f 0.06 :u 0.08 :pitch 14) (:spine :flex 2) (:head :flex -6)
  (:arm-r :flex 0 :side 92) (:elbow-r :flex 2) (:arm-l :flex 0 :side 92) (:elbow-l :flex 2))
(defpose :br-en-top-low (:base :lb-w-stance)       ; L2's: leaning further, sunk, the wings dipped (a lower sweep)
  (:root :f 0.1 :u -0.02 :pitch 19) (:spine :flex 4) (:head :flex -12)
  (:arm-r :flex 0 :side 88) (:elbow-r :flex 2) (:arm-l :flex 0 :side 88) (:elbow-l :flex 2))
(defpose :br-en-top-high (:base :lb-w-stance)      ; L3's: spun up and risen, the tilt less, the wings flat and high
  (:root :f 0.08 :u 0.3 :pitch 10) (:spine :flex 0) (:head :flex -4)
  (:arm-r :flex 0 :side 94) (:elbow-r :flex 0) (:arm-l :flex 0 :side 94) (:elbow-l :flex 0))
;; J 長鞭: the front wings stretched long (*BR-W-STRETCH*), cracked from high: the striking wing thrown down at him, the
;; other cocked overhead for the next
(defpose :br-en-cock (:base :lb-w-stance)          ; both whips raised overhead, the wrists high (the lashes' wind-up)
  (:root :u 0.04 :pitch -4) (:spine :flex -4) (:head :flex -2)
  (:arm-r :flex 152 :side 26) (:elbow-r :flex 34) (:arm-l :flex 152 :side 26) (:elbow-l :flex 34))
(defpose :br-en-crack-r (:base :lb-w-stance)       ; the right whip cracked down on his line, the left cocked high
  (:root :f 0.08 :u -0.02 :pitch 6) (:spine :flex 10) (:chest :twist 8) (:head :flex 4)
  (:arm-r :flex 103.8 :side 1.3) (:elbow-r :flex 0) (:arm-l :flex 150 :side 30) (:elbow-l :flex 36))
(defpose :br-en-crack-l (:base :lb-w-stance)
  (:root :f 0.08 :u -0.02 :pitch 6) (:spine :flex 10) (:chest :twist -8) (:head :flex 4)
  (:arm-l :flex 103.8 :side 1.3) (:elbow-l :flex 0) (:arm-r :flex 150 :side 30) (:elbow-r :flex 36))
;; 大砍刀 (K1's chop, J3's; R6, DUEL_LILLE_V3 §11: 「大砍刀的動作要更緩慢沉重、扭轉身體、砍刀後拉，每次只用一隻光翼
;; 揮砍，揮砍前光翼隨身體的距離伸長放大」): ONE wing a chop, the body wound away from him, the wing pulled back behind the
;; head and grown (*BR-W-STRETCH*, *LB-STRETCH-GROW*: longer and wider with the pull), held, then swung down through his
;; line with the body unwinding after it; the other wing held back
;; 近身 (K2): stepped in, one blow with the folded left wing (elbow bent, ~1.3 m), from a coil
(defpose :br-en-heave-r (:base :lb-w-stance)       ; the right wing pulled back behind the head, the body wound away from him
  (:root :f -0.16 :u 0.06 :yaw -24 :pitch -8) (:pelvis :twist -16) (:spine :flex -10) (:chest :twist -46) (:head :twist 30)
  (:arm-r :flex 215 :side 24) (:elbow-r :flex 10) (:arm-l :flex -30 :side 36) (:elbow-l :flex 20)
  (:thigh-r :flex -14) (:thigh-l :flex 18))
(defpose :br-en-cleave-r (:base :lb-w-stance)      ; ... swung down through his line, the body unwound after it, a step in
  (:root :f 0.15 :u -0.08 :yaw 14 :pitch 14) (:pelvis :twist 10) (:spine :flex 20) (:chest :twist 22) (:head :flex 6)
  (:arm-r :flex 143.7 :side -52.8) (:elbow-r :flex 0) (:arm-l :flex -30 :side 36) (:elbow-l :flex 20)
  (:thigh-r :flex 28) (:thigh-l :flex -20))
(defpose :br-en-cleave-low-r (:base :lb-w-stance)  ; ... and through, down across him to the left, bowed over it
  (:root :f 0.24 :u -0.16 :yaw 20 :pitch 20) (:pelvis :twist 14) (:spine :flex 28) (:chest :twist 34) (:head :flex 10)
  (:arm-r :flex 30 :side -30) (:elbow-r :flex 0) (:arm-l :flex -30 :side 36) (:elbow-l :flex 20)
  (:thigh-r :flex 30) (:thigh-l :flex -22))
(defpose :br-en-bash-cock-l (:base :lb-w-stance)
  (:root :f 0.3 :u 0.06 :yaw 14 :pitch -6) (:spine :flex -6) (:chest :twist 30) (:head :twist -14)
  (:arm-l :flex 150 :side 50) (:elbow-l :flex 110) (:arm-r :flex 50 :side 40) (:elbow-r :flex 90)
  (:thigh-l :flex -10) (:thigh-r :flex 16))
(defpose :br-en-bash-l (:base :lb-w-stance)
  (:root :f 0.32 :u -0.08 :yaw -8 :pitch 12) (:spine :flex 18) (:chest :twist -14) (:head :flex 6)
  (:arm-l :flex 61.8 :side -20) (:elbow-l :flex 117.4) (:arm-r :flex 40 :side 40) (:elbow-r :flex 100)
  (:thigh-l :flex 28) (:thigh-r :flex -20))
(defpose :br-en-cannon-load (:base :lb-w-stance)   ; 零距離砲擊's load: stepped in, both wings drawn back to the chest
  (:root :f 0.26 :u -0.08 :pitch 4) (:spine :flex 8) (:head :flex 4)
  (:arm-r :flex 60 :side 30) (:elbow-r :flex 110) (:arm-l :flex 60 :side 30) (:elbow-l :flex 110)
  (:thigh-r :flex 30) (:thigh-l :flex -20))
(defpose :br-en-cannon (:base :lb-w-stance)        ; ... both tips thrust together into him at point blank: the blast
  (:root :f 0.3 :u -0.06 :pitch 6) (:spine :flex 10) (:head :flex 4)
  (:arm-r :flex 51.2 :side 30) (:elbow-r :flex 113.9) (:arm-l :flex 51.2 :side 30) (:elbow-l :flex 113.9)
  (:thigh-r :flex 32) (:thigh-l :flex -22))
(defpose :br-en-blown (:base :lb-w-stance)         ; ... blown back by it, the wings flung up and open
  (:root :f 0.1 :u 0.12 :pitch -12) (:spine :flex -14) (:head :flex -12)
  (:arm-r :flex 120 :side 50) (:elbow-r :flex 20) (:arm-l :flex 120 :side 50) (:elbow-l :flex 20)
  (:thigh-r :flex -8) (:thigh-l :flex 10))

;; JILLIEL EN's nine openers (the moves :br-e-l1 .. -k3; R7, DUEL_LILLE_V3 §12: one strike a press, S A R from *BR-S-SEGS* /
;; *BR-W-SEGS*; L authored at S 8 and played at 2 / 3). L: the spin (the pelvis's twist, linear :snap keys) carried across the
;; links: each segment's first key is the pose its predecessor holds at its S + A (clip f9.33 at 2 / 3: twist 138 =
;; -222 + 360), one turn to the right wing on his line at S (+90), then wound down to 360, unwound to 0 between two keys
;; 0.0001 f apart (never sampled: the samples fall on thirds of a frame). J1 / J2 one whip each (R, L), J3 / K1 the one-wing
;; great blade (R6), K2 one folded-wing blow, K3 零距離砲擊. Each later segment starts from its predecessor's S + A pose.
(defstrike :br-en-l1 (8 2 14 :base :lb-w-stance)   ; L1 陀螺: wound up, one turn, the right wing across him f8
  (0) (3 :br-en-wind)
  (:s :snap :br-en-top (:pelvis :twist 90)) (:a :snap :br-en-top (:pelvis :twist 162))
  (13 :snap :br-en-top (:root :pitch 10) (:pelvis :twist 250)) (16 :snap :br-en-top (:root :pitch 6 :u 0.04) (:pelvis :twist 320))
  (19 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 352) (:arm-r :side 84) (:arm-l :side 84))
  (21 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 360) (:arm-r :side 82) (:arm-l :side 82))
  (21.0001 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 0) (:arm-r :side 82) (:arm-l :side 82))
  (:end :lb-w-stance))
(defstrike :br-en-l2 (8 2 14 :base :lb-w-stance)   ; L2 陀螺: leaning lower, one more turn, the right wing across him f8
  (0 :br-en-top (:pelvis :twist -222))
  (:s :snap :br-en-top-low (:pelvis :twist 90)) (:a :snap :br-en-top-low (:pelvis :twist 162))
  (13 :snap :br-en-top-low (:pelvis :twist 250)) (16 :snap :br-en-top (:root :pitch 6 :u 0.04) (:pelvis :twist 320))
  (19 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 352) (:arm-r :side 84) (:arm-l :side 84))
  (21 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 360) (:arm-r :side 82) (:arm-l :side 82))
  (21.0001 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 0) (:arm-r :side 82) (:arm-l :side 82))
  (:end :lb-w-stance))
(defstrike :br-en-l3 (8 2 18 :base :lb-w-stance)   ; L3 陀螺: spun up and rising, the right wing across him f8, wound down
  (0 :br-en-top-low (:pelvis :twist -222))
  (:s :snap :br-en-top-high (:root :u 0.16) (:pelvis :twist 90)) (:a :snap :br-en-top-high (:root :u 0.2) (:pelvis :twist 162))
  (14 :snap :br-en-top-high (:root :u 0.24) (:pelvis :twist 270)) (18 :snap :br-en-top (:root :u 0.14) (:pelvis :twist 330))
  (22 :snap :br-en-top (:root :pitch 6 :u 0.04) (:pelvis :twist 355) (:arm-r :side 84) (:arm-l :side 84))
  (24 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 360) (:arm-r :side 82) (:arm-l :side 82))
  (24.0001 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 0) (:arm-r :side 82) (:arm-l :side 82))
  (:end :lb-w-stance))
(defstrike :br-en-j1 (8 2 12 :base :lb-w-stance)   ; J1 長鞭: the right whip cracked from high outside down across him f8
  (0) (4 :br-en-cock) (7 :br-en-cock (:root :pitch -6) (:arm-r :flex 160 :side 56))
  (:s :snap :br-en-crack-r) (:a :br-en-crack-r (:arm-r :flex 64 :side -36) (:arm-l :flex 162 :side 56))
  (16 :br-en-crack-r (:root :f 0 :pitch 2) (:arm-r :flex 40 :side 40) (:elbow-r :flex 20) (:arm-l :flex 40 :side 50))
  (:end :lb-w-stance))
(defstrike :br-en-j2 (8 2 12 :base :lb-w-stance)   ; J2 長鞭: the left whip cracked the same way across him f8 (the figure-eight)
  (0 :br-en-crack-r (:arm-r :flex 64 :side -36) (:arm-l :flex 162 :side 56))
  (4 :br-en-crack-r (:root :pitch -2) (:arm-r :flex 120 :side 40) (:arm-l :flex 166 :side 56))
  (:s :snap :br-en-crack-l) (:a :br-en-crack-l (:arm-l :flex 64 :side -36) (:arm-r :flex 120 :side 40))
  (16 :br-en-crack-l (:root :f 0 :pitch 2) (:arm-l :flex 40 :side 40) (:elbow-l :flex 20) (:arm-r :flex 40 :side 50))
  (:end :lb-w-stance))
(defstrike :br-en-j3 (14 2 14 :base :lb-w-stance)   ; J3 大砍刀: the whips drawn in, wound away, the right wing pulled back and grown, held, chopped down f14
  (0 :br-en-crack-l (:arm-l :flex 64 :side -36) (:arm-r :flex 120 :side 40))
  (4 :br-en-heave-r (:root :f -0.06)) (10 :br-en-heave-r (:root :f -0.2 :u 0.08) (:chest :twist -52) (:arm-r :flex 222))
  (11 :br-en-heave-r (:root :f -0.2 :u 0.08) (:chest :twist -54) (:arm-r :flex 226))
  (:s :snap :br-en-cleave-r) (:a :br-en-cleave-low-r)
  (24 :br-en-cleave-low-r (:root :f 0.08 :u -0.06 :yaw 8 :pitch 10) (:pelvis :twist 4) (:spine :flex 14) (:chest :twist 12)
   (:arm-r :flex 40 :side 20))
  (:end :lb-w-stance))
(defstrike :br-en-k1 (16 2 18 :base :lb-w-stance)   ; K1 大砍刀: wound away, the right wing pulled back and grown, held long, chopped down f16
  (0) (5 :br-en-heave-r) (11 :br-en-heave-r (:root :f -0.2 :u 0.1) (:chest :twist -54) (:arm-r :flex 224))
  (13 :br-en-heave-r (:root :f -0.22 :u 0.12) (:chest :twist -56) (:arm-r :flex 228))
  (:s :snap :br-en-cleave-r) (:a :br-en-cleave-low-r) (22 :br-en-cleave-low-r (:root :u -0.2))
  (30 :br-en-cleave-low-r (:root :f 0.06 :u -0.04 :yaw 4 :pitch 6) (:pelvis :twist 2) (:spine :flex 8) (:chest :twist 6)
   (:arm-r :flex 40 :side 30))
  (:end :lb-w-stance))
(defstrike :br-en-k2 (12 2 18 :base :lb-w-stance)   ; K2 近身: stepped in, the left wing folded, clubbed down on him f12
  (0 :br-en-cleave-low-r) (5 :br-en-bash-cock-l) (10 :br-en-bash-cock-l (:root :u 0.1) (:chest :twist 38))
  (:s :snap :br-en-bash-l) (:a :br-en-bash-l (:root :f 0.36 :u -0.12) (:arm-l :flex 40))
  (24 :br-en-bash-l (:root :f 0.16 :u 0 :pitch 2) (:spine :flex 4) (:chest :twist 0) (:arm-l :flex 40 :side 40) (:elbow-l :flex 60))
  (:end :lb-w-stance))
(defstrike :br-en-k3 (12 2 22 :base :lb-w-stance)   ; K3 零距離砲擊: both wings drawn in, both tips thrust into him point blank f12: the ball of light
  (0 :br-en-bash-l (:root :f 0.36 :u -0.12) (:arm-l :flex 40)) (6 :br-en-cannon-load) (10 :br-en-cannon-load (:root :u -0.1))
  (:s :snap :br-en-cannon) (:a :br-en-cannon (:root :f 0.26)) (18 :br-en-blown)
  (26 :br-en-blown (:root :f 0 :u 0.06 :pitch -4)) (:end :lb-w-stance))
;; the owl EN's poses (base :lb-oe-stance: upright and afloat, the claws are the hands)
(defpose :br-oen-wind (:base :lb-oe-stance)        ; the top wound up: coiled back to the right, the claws drawn in
  (:root :u 0.04 :pitch 4) (:pelvis :twist -40) (:spine :flex 8) (:chest :twist -22) (:neck :flex 6) (:head :flex 4)
  (:arm-r :flex 40 :side 50) (:elbow-r :flex 80) (:hand-r :flex 20) (:arm-l :flex 50 :side 34) (:elbow-l :flex 86)
  (:hand-l :flex 20))
(defpose :br-oen-top (:base :lb-oe-stance)         ; L1's top: tilted forward, both claws swung out flat, the talons open
  (:root :f 0.14 :u 0.08 :pitch 14) (:spine :flex 2) (:neck :flex -4) (:head :flex -8)
  (:arm-r :flex 0 :side 92) (:elbow-r :flex 2) (:hand-r :flex -20) (:arm-l :flex 0 :side 92) (:elbow-l :flex 2)
  (:hand-l :flex -20))
(defpose :br-oen-top-low (:base :lb-oe-stance)     ; L2's: leaning further, sunk, the claws dipped
  (:root :f 0.18 :u -0.02 :pitch 19) (:spine :flex 4) (:neck :flex -10) (:head :flex -12)
  (:arm-r :flex 0 :side 88) (:elbow-r :flex 2) (:hand-r :flex -20) (:arm-l :flex 0 :side 88) (:elbow-l :flex 2)
  (:hand-l :flex -20))
(defpose :br-oen-top-high (:base :lb-oe-stance)    ; L3's: spun up and risen, the claws flat and high
  (:root :f 0.16 :u 0.3 :pitch 10) (:spine :flex 0) (:neck :flex -2) (:head :flex -6)
  (:arm-r :flex 0 :side 94) (:elbow-r :flex 0) (:hand-r :flex -20) (:arm-l :flex 0 :side 94) (:elbow-l :flex 0)
  (:hand-l :flex -20))
(defpose :br-oen-cock (:base :lb-oe-stance)        ; both claws raised overhead with their gold lashes (J's wind-up)
  (:root :u 0.06 :pitch -4) (:spine :flex -4) (:neck :flex -12) (:head :flex -10)
  (:arm-r :flex 150 :side 26) (:elbow-r :flex 30) (:hand-r :flex -30) (:arm-l :flex 150 :side 26) (:elbow-l :flex 30)
  (:hand-l :flex -30))
(defpose :br-oen-crack-r (:base :lb-oe-stance)     ; the right claw's lash cracked down on his line, the left cocked high
  (:root :f 0.1 :u -0.02 :pitch 6) (:spine :flex 12) (:chest :twist 8) (:neck :flex 16) (:head :flex 8)
  (:arm-r :flex 105.3 :side 9.8) (:elbow-r :flex 0) (:hand-r :flex 30) (:arm-l :flex 148 :side 30) (:elbow-l :flex 34)
  (:hand-l :flex -30))
(defpose :br-oen-crack-l (:base :lb-oe-stance)
  (:root :f 0.1 :u -0.02 :pitch 6) (:spine :flex 12) (:chest :twist -8) (:neck :flex 16) (:head :flex 8)
  (:arm-l :flex 105.3 :side 9.8) (:elbow-l :flex 0) (:hand-l :flex 30) (:arm-r :flex 148 :side 30) (:elbow-r :flex 34)
  (:hand-r :flex -30))
(defpose :br-oen-heave-r (:base :lb-oe-stance)     ; the owl: the right claw pulled back behind the head, wound away
  (:root :f -0.16 :u 0.08 :yaw -24 :pitch -8) (:pelvis :twist -16) (:spine :flex -10) (:chest :twist -46) (:neck :flex -10)
  (:head :twist 30) (:arm-r :flex 215 :side 24) (:elbow-r :flex 10) (:hand-r :flex -30) (:arm-l :flex -30 :side 36)
  (:elbow-l :flex 20) (:hand-l :flex 10))
(defpose :br-oen-cleave-r (:base :lb-oe-stance)    ; ... swung down through his line
  (:root :f 0.15 :u -0.08 :yaw 14 :pitch 14) (:pelvis :twist 10) (:spine :flex 22) (:chest :twist 22) (:neck :flex 24)
  (:head :flex 10) (:arm-r :flex 142.4 :side -54.8) (:elbow-r :flex 0) (:hand-r :flex 30) (:arm-l :flex -30 :side 36)
  (:elbow-l :flex 20) (:hand-l :flex 10))
(defpose :br-oen-cleave-low-r (:base :lb-oe-stance)
  (:root :f 0.24 :u -0.16 :yaw 20 :pitch 20) (:pelvis :twist 14) (:spine :flex 30) (:chest :twist 34) (:neck :flex 34)
  (:head :flex 14) (:arm-r :flex 30 :side -30) (:elbow-r :flex 0) (:hand-r :flex 40) (:arm-l :flex -30 :side 36)
  (:elbow-l :flex 20) (:hand-l :flex 10))
(defpose :br-oen-bash-cock-l (:base :lb-oe-stance)
  (:root :f 0.3 :u 0.08 :yaw 14 :pitch -6) (:spine :flex -6) (:chest :twist 30) (:neck :flex -10) (:head :twist -14)
  (:arm-l :flex 150 :side 50) (:elbow-l :flex 110) (:hand-l :flex -30) (:arm-r :flex 50 :side 40) (:elbow-r :flex 90)
  (:hand-r :flex 20))
(defpose :br-oen-bash-l (:base :lb-oe-stance)
  (:root :f 0.32 :u -0.08 :yaw -8 :pitch 12) (:spine :flex 20) (:chest :twist -14) (:neck :flex 24) (:head :flex 10)
  (:arm-l :flex 67 :side -20) (:elbow-l :flex 104.7) (:hand-l :flex 40) (:arm-r :flex 40 :side 40) (:elbow-r :flex 100)
  (:hand-r :flex 20))
(defpose :br-oen-cannon-load (:base :lb-oe-stance) ; 零距離砲擊's load: stepped in, both claws drawn back to the chest
  (:root :f 0.26 :u -0.06 :pitch 4) (:spine :flex 10) (:neck :flex 14) (:head :flex 6)
  (:arm-r :flex 50 :side 30) (:elbow-r :flex 120) (:hand-r :flex 20) (:arm-l :flex 50 :side 30) (:elbow-l :flex 120)
  (:hand-l :flex 20))
(defpose :br-oen-cannon (:base :lb-oe-stance)      ; ... both claws thrust together into him at point blank: the gold blast
  (:root :f 0.3 :u -0.04 :pitch 6) (:spine :flex 12) (:neck :flex 18) (:head :flex 8)
  (:arm-r :flex 49.9 :side 30) (:elbow-r :flex 105.1) (:hand-r :flex 30) (:arm-l :flex 49.9 :side 30) (:elbow-l :flex 105.1)
  (:hand-l :flex 30))
(defpose :br-oen-blown (:base :lb-oe-stance)       ; ... blown back by it, the claws flung up and open
  (:root :f 0.1 :u 0.14 :pitch -12) (:spine :flex -14) (:neck :flex -20) (:head :flex -16)
  (:arm-r :flex 120 :side 50) (:elbow-r :flex 20) (:hand-r :flex -30) (:arm-l :flex 120 :side 50) (:elbow-l :flex 20)
  (:hand-l :flex -30))
;; the owl EN's nine openers (the moves :br-oe-l1 .. -k3; its recovery one frame shorter: R - 1, *BR-OWL-ADV*): JILLIEL's,
;; on its claws (R7, §12: one strike a press)
(defstrike :br-oen-l1 (8 2 13 :base :lb-oe-stance)   ; L1 陀螺: wound up, one turn, the right claw across him f8
  (0) (3 :br-oen-wind)
  (:s :snap :br-oen-top (:pelvis :twist 90)) (:a :snap :br-oen-top (:pelvis :twist 162))
  (13 :snap :br-oen-top (:root :pitch 10) (:pelvis :twist 250)) (16 :snap :br-oen-top (:root :pitch 6 :u 0.04) (:pelvis :twist 320))
  (19 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 352) (:arm-r :side 84) (:arm-l :side 84))
  (21 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 360) (:arm-r :side 82) (:arm-l :side 82))
  (21.0001 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 0) (:arm-r :side 82) (:arm-l :side 82))
  (:end :lb-oe-stance))
(defstrike :br-oen-l2 (8 2 13 :base :lb-oe-stance)   ; L2 陀螺: leaning lower, one more turn, the right claw across him f8
  (0 :br-oen-top (:pelvis :twist -222))
  (:s :snap :br-oen-top-low (:pelvis :twist 90)) (:a :snap :br-oen-top-low (:pelvis :twist 162))
  (13 :snap :br-oen-top-low (:pelvis :twist 250)) (16 :snap :br-oen-top (:root :pitch 6 :u 0.04) (:pelvis :twist 320))
  (19 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 352) (:arm-r :side 84) (:arm-l :side 84))
  (21 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 360) (:arm-r :side 82) (:arm-l :side 82))
  (21.0001 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 0) (:arm-r :side 82) (:arm-l :side 82))
  (:end :lb-oe-stance))
(defstrike :br-oen-l3 (8 2 17 :base :lb-oe-stance)   ; L3 陀螺: spun up and rising, the right claw across him f8, wound down
  (0 :br-oen-top-low (:pelvis :twist -222))
  (:s :snap :br-oen-top-high (:root :u 0.16) (:pelvis :twist 90)) (:a :snap :br-oen-top-high (:root :u 0.2) (:pelvis :twist 162))
  (14 :snap :br-oen-top-high (:root :u 0.24) (:pelvis :twist 270)) (18 :snap :br-oen-top (:root :u 0.14) (:pelvis :twist 330))
  (22 :snap :br-oen-top (:root :pitch 6 :u 0.04) (:pelvis :twist 355) (:arm-r :side 84) (:arm-l :side 84))
  (24 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 360) (:arm-r :side 82) (:arm-l :side 82))
  (24.0001 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 0) (:arm-r :side 82) (:arm-l :side 82))
  (:end :lb-oe-stance))
(defstrike :br-oen-j1 (8 2 11 :base :lb-oe-stance)   ; J1 長鞭: the right claw.s gold lash cracked from high outside down across him f8
  (0) (4 :br-oen-cock) (7 :br-oen-cock (:root :pitch -6) (:arm-r :flex 160 :side 56))
  (:s :snap :br-oen-crack-r) (:a :br-oen-crack-r (:arm-r :flex 64 :side -36) (:arm-l :flex 162 :side 56))
  (16 :br-oen-crack-r (:root :f 0 :pitch 2) (:arm-r :flex 40 :side 40) (:elbow-r :flex 20) (:arm-l :flex 40 :side 50))
  (:end :lb-oe-stance))
(defstrike :br-oen-j2 (8 2 11 :base :lb-oe-stance)   ; J2 長鞭: the left claw.s lash cracked the same way across him f8 (the figure-eight)
  (0 :br-oen-crack-r (:arm-r :flex 64 :side -36) (:arm-l :flex 162 :side 56))
  (4 :br-oen-crack-r (:root :pitch -2) (:arm-r :flex 120 :side 40) (:arm-l :flex 166 :side 56))
  (:s :snap :br-oen-crack-l) (:a :br-oen-crack-l (:arm-l :flex 64 :side -36) (:arm-r :flex 120 :side 40))
  (16 :br-oen-crack-l (:root :f 0 :pitch 2) (:arm-l :flex 40 :side 40) (:elbow-l :flex 20) (:arm-r :flex 40 :side 50))
  (:end :lb-oe-stance))
(defstrike :br-oen-j3 (14 2 13 :base :lb-oe-stance)   ; J3 大砍刀: the whips drawn in, wound away, the right claw pulled back and grown, held, chopped down f14
  (0 :br-oen-crack-l (:arm-l :flex 64 :side -36) (:arm-r :flex 120 :side 40))
  (4 :br-oen-heave-r (:root :f -0.06)) (10 :br-oen-heave-r (:root :f -0.2 :u 0.08) (:chest :twist -52) (:arm-r :flex 222))
  (11 :br-oen-heave-r (:root :f -0.2 :u 0.08) (:chest :twist -54) (:arm-r :flex 226))
  (:s :snap :br-oen-cleave-r) (:a :br-oen-cleave-low-r)
  (24 :br-oen-cleave-low-r (:root :f 0.08 :u -0.06 :yaw 8 :pitch 10) (:pelvis :twist 4) (:spine :flex 14) (:chest :twist 12)
   (:arm-r :flex 40 :side 20))
  (:end :lb-oe-stance))
(defstrike :br-oen-k1 (16 2 17 :base :lb-oe-stance)   ; K1 大砍刀: wound away, the right claw pulled back and grown, held long, chopped down f16
  (0) (5 :br-oen-heave-r) (11 :br-oen-heave-r (:root :f -0.2 :u 0.1) (:chest :twist -54) (:arm-r :flex 224))
  (13 :br-oen-heave-r (:root :f -0.22 :u 0.12) (:chest :twist -56) (:arm-r :flex 228))
  (:s :snap :br-oen-cleave-r) (:a :br-oen-cleave-low-r) (22 :br-oen-cleave-low-r (:root :u -0.2))
  (30 :br-oen-cleave-low-r (:root :f 0.06 :u -0.04 :yaw 4 :pitch 6) (:pelvis :twist 2) (:spine :flex 8) (:chest :twist 6)
   (:arm-r :flex 40 :side 30))
  (:end :lb-oe-stance))
(defstrike :br-oen-k2 (12 2 17 :base :lb-oe-stance)   ; K2 近身: stepped in, the left claw folded, clubbed down on him f12
  (0 :br-oen-cleave-low-r) (5 :br-oen-bash-cock-l) (10 :br-oen-bash-cock-l (:root :u 0.1) (:chest :twist 38))
  (:s :snap :br-oen-bash-l) (:a :br-oen-bash-l (:root :f 0.36 :u -0.12) (:arm-l :flex 40))
  (24 :br-oen-bash-l (:root :f 0.16 :u 0 :pitch 2) (:spine :flex 4) (:chest :twist 0) (:arm-l :flex 40 :side 40) (:elbow-l :flex 60))
  (:end :lb-oe-stance))
(defstrike :br-oen-k3 (12 2 21 :base :lb-oe-stance)   ; K3 零距離砲擊: both claws drawn in, both thrust into him point blank f12: the ball of light
  (0 :br-oen-bash-l (:root :f 0.36 :u -0.12) (:arm-l :flex 40)) (6 :br-oen-cannon-load) (10 :br-oen-cannon-load (:root :u -0.1))
  (:s :snap :br-oen-cannon) (:a :br-oen-cannon (:root :f 0.26)) (18 :br-oen-blown)
  (26 :br-oen-blown (:root :f 0 :u 0.06 :pitch -4)) (:end :lb-oe-stance))
;; the stretch (R5 J 長鞭) and the spins (R5 L 陀螺) to Lille's wing looks (lille-art.lisp: %LB-STRETCH!, %LB-WINGS, %LB-LASHES,
;; %LB-DRIVE!; Lille's own clips are in neither)
(defparameter *br-w-stretch*
  '((:br-en-j1 (0 0 0) (6 1.1 1.0) (8 1.2 1.0) (10 1.1 1.1) (16 0.5 0.4) (22 0 0))   ; (R7, §12: one whip a press)
    (:br-en-j2 (0 1.1 1.1) (8 1.0 1.2) (10 0.8 1.1) (16 0.4 0.5) (22 0 0))
    (:br-en-j3 (0 0.8 1.1) (4 0.9 0.3) (10 1.6 0) (11 1.7 0) (14 0.7 0) (16 0.6 0) (24 0.3 0) (30 0 0))
    (:br-en-k1 (0 0 0) (5 0.8 0) (11 1.5 0) (13 1.6 0) (16 0.5 0) (20 0.4 0) (30 0 0))
    (:br-oen-j1 (0 0 0) (6 1.25 1.15) (8 1.35 1.15) (10 1.25 1.25) (16 0.5 0.4) (21 0 0))
    (:br-oen-j2 (0 1.25 1.25) (8 1.15 1.35) (10 0.9 1.25) (16 0.4 0.5) (21 0 0))
    (:br-oen-j3 (0 0.9 1.25) (4 1.0 0.3) (10 1.8 0) (11 1.9 0) (14 0.8 0) (16 0.7 0) (24 0.3 0) (29 0 0))
    (:br-oen-k1 (0 0 0) (5 0.9 0) (11 1.7 0) (13 1.8 0) (16 0.6 0) (20 0.5 0) (30 0 0)))
  "R5 J 長鞭 (DUEL_LILLE_V3 §10): the whips' stretch by clip, keys (frame right left) in the clip's frames: the metres the
right / left front wing (JILLIEL: its blade on past the hand, along its root -> hand line) or claw's gold lash (the owl: on
from the claw along the forearm) reaches past the rig's hand, linear between keys; grown over the wind-up, the striking
whip the longer, drawn back in over the recovery. R6 大砍刀 (§11): J3's last and K1's two chops swing ONE wing, its stretch
growing with the pull behind him (1.5-1.8 m held), the swing landing with less (0.5-0.8). The host FK test adds it to the
hand: the stretched tip is the strike point (*BR-W-TIPS*).")
(defparameter *br-w-grow* '((:br-en-j3 . 0.5) (:br-oen-j3 . 0.5) (:br-en-k1 . 0.5) (:br-oen-k1 . 0.5))
  "R6 大砍刀 (DUEL_LILLE_V3 §11: 「揮砍前光翼隨身體的距離伸長放大」): the chopping wing's width gain per metre of stretch, so
the pulled-back blade grows wider as well as longer (x 1.75-1.9 at the held wind-up); the whips stay thin.")
(setf *lb-stretch* (loop for (c . keys) in *br-w-stretch* collect (cons c (coerce (mapcar #'f32 (apply #'append keys)) 'f32vec)))
      *lb-stretch-grow* (loop for (c . g) in *br-w-grow* collect (cons c (f32 g)))
      *lb-trail-cut* '((:br-en-k3 . 0) (:br-oen-k3 . 0)))   ; (R6, R7: 零距離砲擊's thrust leaves no streak toward him)
(dolist (c '(:br-en-l1 :br-en-l2 :br-en-l3 :br-oen-l1 :br-oen-l2 :br-oen-l3   ; the spins: the table wings turn with him;
             :br-en-k3 :br-oen-k3))                                          ;  K3: no lines toward him at the blast (R6)
  (pushnew c *lb-no-conv*))

;;; ---------------------------------------------------------------- the draw hook
(defparameter *br-aim-stance* '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re)
  "The base stance's moves: the aim line tracks while one runs ...")
(defparameter *br-aim-locked* '(:br-s-jl1 :br-s-jl2 :br-s-jl3 :br-s-kl1 :br-s-kl2 :br-s-kl3)
  "... and turns jade, locked, through the startup of these shots (the stance's spending 萬物貫通 lines, decision R3).")
(defun-fast %br-aim-look (e f side)
  "The stance's aim line (Lille's %LB-AIM-LOOK on his moves): a thin line on the floor from under the muzzle to the wall,
grey while the stance (:br-kamae / :br-kamae-k / :br-kamae-j / :br-kamae-re) tracks, jade once the shot :br-k-shot locks until it fires; the reticle at
the opponent's distance, turning while it tracks, closing once locked."
  (declare (fixnum side))
  (setf side 0)                                         ; (unused: the slot memory is Lille's HUD tag's, not his)
  (let* ((mv (fighter-move f)) (nm (and mv (eq (fighter-state f) :move) (mv-name mv)))
         (stance (and nm (member nm *br-aim-stance*)))
         (locked (and nm (member nm *br-aim-locked*) (eq (fighter-phase f) :main) (< (fighter-sf f) (mv-s mv)))))
    (when (or stance locked)
      (%lb-load-place! e)
      (let* ((v *lb-v*) (yaw (aref v 27)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw)))
             (x0 (+ (aref v 24) (* 0.5f0 ux))) (z0 (+ (aref v 26) (* 0.5f0 uz)))
             (wall (%lb-wall x0 z0 ux uz)) (dist (the single-float (fighter-dist f)))
             (dq (f-clamp (- dist 0.5f0) 1f0 (f-max 1f0 wall)))
             (rx (+ x0 (* dq ux))) (rz (+ z0 (* dq uz)))
             (r (if locked (- 0.65f0 (* 0.018f0 (i->f (fighter-sf f)))) 1.1f0))
             (tm (fx-clock)))
        (declare (type f32vec v) (single-float yaw ux uz x0 z0 wall dist dq rx rz r tm))
        (%lb-floor-line (if locked 1 0) x0 z0 ux uz wall (if locked 0.06f0 0.035f0))
        (%lb-reticle locked rx rz r (if locked 0.785398f0 (* 1.4f0 tm)))))
    nil))

;;; ---------------------------------------------------------------- the recall and its strings' looks (§12)
(defparameter *br-rc-beats*
  '((:br-rc0 (6 3)) (:br-rc1 (6 1) (16 2)) (:br-rc2 (6 1) (14 2) (22 1) (32 3)) (:br-rc3 (6 1) (12 2) (18 1) (24 2) (36 4))
    (:br-rc4 (6 1) (12 2) (18 1) (24 2) (30 1) (36 2) (48 4)))
  "The recall strings' beats (their moves' line frames, barro.lisp): (frame kind), kind 1 the right wing / claw fires, 2 the
left, 3 both, 4 the finisher (the ring and the beam). The clips (above) and the looks (BR-RC-DRIVE, BR-DRAW) read them.
:br-rc4 (裁き・極, decision V8's 10+ recall, §22) is spec frames until barro.lisp has the move (the host test compares).")
(defparameter *br-finisher* '((:br-rc3 36 10 1.0) (:br-rc4 48 10 1.6))
  "The strings that end in NIJUSHI-KO's ring and beam: (move beam-frame ring-frames scale): the ring rises over the frames
before the beam; SCALE (1 = 裁き's) drives 裁き・極's bigger ring, harder shake, wider and longer beam and blow-back (§22).")
;; 裁き・極's brush callout (decision V8, §22; its 極 baked into glyphs-extra.lisp): barro.lisp's list replaces only the rows it
;; names, so this row stands until it names :br-rc4 itself
(when (boundp '*brush-callouts*)
  (setf *brush-callouts* (append (remove :br-rc4 *brush-callouts* :key #'first) '((:br-rc4 "裁き・極" "SABAKI KIWAMI" nil)))))
(dolist (c '(:br-recall :br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4))   ; the six table wings fan out through the recall and its strings
  (pushnew c *lb-spread-clips*))                             ;  (LILLE-DRAW's spread: an SP's; Lille never plays these clips)

(defun-fast br-rc-beat (nm sf)
  "The latest beat of recall string NM at its frame SF: (+ (* 1000 kind) age), age the frames since it (<= 999), or -1
before the first (or NM not a string). 0 B (a constant list walked)."
  (declare (fixnum sf))
  (let ((best -1))
    (declare (fixnum best))
    (dolist (b (cdr (assoc nm *br-rc-beats*)) best)
      (let ((fr (first b)))
        (declare (fixnum fr))
        (when (<= fr sf) (setf best (+ (* 1000 (the fixnum (second b))) (min 999 (- sf fr)))))))))

(defmacro %br-chain-clock (nm sf)
  "The recall's look clock: its own frame through :br-recall, 7 + the string's frame through :br-rc0..3 (its f7 starts
it), else -1."
  `(let ((%nm ,nm) (%sf ,sf))
     (declare (fixnum %sf))
     (cond ((eq %nm :br-recall) %sf) ((member %nm '(:br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4)) (+ 7 %sf)) (t -1))))

(defun-fast br-rc-drive (f mv)
  "Lille's %LB-SP-DRIVE! for his recall strings (JILLIEL's wings; its clause calls this): each beat kicks the firing wing
(SANREN's whip: a virtual speed back, easing out over *LB-SP-KICK* frames) and flashes its holes; the finisher (:br-rc3's
f36) rises into NIJUSHI-KO's ring over f26-35 (lit, shaking), the beam blows it back. The numbers go out through
*LB-SP-EXT* (ring, cup, shake, speed, flash, lit bits, the striking wings' mask, the other wings' share). T when it set
them. Reads the move's frame only (cosmetic). 0 B."
  (let* ((x *lb-sp-ext*) (sf (fighter-sf f)) (nm (mv-name mv)) (b (br-rc-beat nm sf)) (fin (assoc nm *br-finisher*))
         (bf (if fin (the fixnum (second fin)) 9999)) (rf (if fin (the fixnum (third fin)) 0))
         (sc (if fin (f32 (fourth fin)) 1f0)))
    (declare (type f32vec x) (fixnum sf b bf rf) (single-float sc))
    (when (eq (fighter-phase f) :main)
      (cond ((>= sf (- bf rf))                              ; the finisher: NIJUSHI-KO's ring, its beam (frames; 極 scaled)
             (let ((post (i->f (- sf bf))) (pre (/ (i->f (- sf (- bf rf))) (i->f rf))))
               (declare (single-float post pre))
               (setf (aref x 5) 255f0 (aref x 6) 3f0 (aref x 7) 0.8f0 (aref x 2) 0f0 (aref x 4) 0f0)
               (if (< post 0f0)
                   (setf (aref x 0) (%lb-ss (/ pre 0.35f0))
                         (aref x 1) (- (* 0.35f0 sc) (* 0.25f0 (%lb-ss (/ (- pre 0.4f0) 0.6f0))))
                         (aref x 2) (* sc (the single-float *lb-ring-shake*) (%lb-ss (/ (- pre 0.3f0) 0.7f0)) (+ 0.3f0 (* 0.7f0 pre)))
                         (aref x 3) (* 0.5f0 (the single-float *lb-strike-in*) (%lb-ss (/ (- pre 0.5f0) 0.5f0))))
                   (let ((bl (f-max 0f0 (- 1f0 (/ post (* 10f0 sc))))))
                     (declare (single-float bl))
                     (setf (aref x 0) (- 1f0 (%lb-ss (/ (- post 18f0) 16f0)))
                           (aref x 1) (* -0.85f0 (%lb-ss (/ post 2.5f0)) (- 1f0 (%lb-ss (/ (- post 8f0) 18f0))))
                           (aref x 3) (* sc (the single-float *lb-ring-blow*) bl bl)
                           (aref x 5) (if (< post (* 6f0 sc)) 255f0 0f0) (aref x 4) (f-max 0f0 (- 1f0 (/ post (* 6f0 sc)))))))
               t))
            ((>= b 0)                                         ; a beat: SANREN's kick on the firing wing
             (let ((kind (floor b 1000)) (age (mod b 1000)))
               (declare (fixnum kind age))
               (when (< age (the fixnum *lb-sp-kick*))
                 (let ((u (- 1f0 (/ (i->f age) (i->f (the fixnum *lb-sp-kick*))))))
                   (declare (single-float u))
                   (setf (aref x 0) 0f0 (aref x 1) 0f0 (aref x 2) 0f0
                         (aref x 3) (- (* (the single-float *lb-sp-whip*) u u (if (= kind 3) 1.3f0 1f0)))
                         (aref x 4) (f-max 0f0 (- 1f0 (/ (i->f age) 6f0)))
                         (aref x 5) (case kind (1 16f0) (2 32f0) (t 48f0)) (aref x 6) (i->f (min 3 kind)) (aref x 7) 0.6f0)
                   t))))))))

;; the traces' light flying back (the recall): BR-TRACE-LOOK notes each live trace it draws (*BR-SEEN*), BR-DRAW keeps the
;; last frame's set while he is not recalling (*BR-FLY*) and draws it flying into him through the recall's look clock
(declaim (type f32vec *br-seen* *br-fly*))
(defvar *br-seen* (make-f32 (* 2 65)) "Per side (65 a side): [0] the traces noted this frame, then x z yaw thick per trace (16).")
(defvar *br-fly* (make-f32 (* 2 65)) "Per side: the last frame's traces before the recall (as *BR-SEEN*).")
(defparameter *br-fly-f* 9 "The recall's look: the traces' far ends reach him on this frame of its clock (their near ends at 2/3) ...")
(defparameter *br-gather-f* '(5 15) "... and the light gathered at his chest flares over these frames.")
(declaim (type fixnum *br-art-hold* *br-art-hold-next*))
(defvar *br-art-hold* -1 "Debug 82200+f (art stills): the sim freezes once his look clock (BR-HOLD-CLOCK) reaches f; -1 none.")
(defvar *br-art-hold-next* -1 "... armed by 82200+f, taken by the next scene (82100+k) once it is set up.")

(defun-fast %br-recall-look (e jm side c)
  "The recall's look at its clock C (frames): each trace taken back (*BR-FLY*) a jade line (the owl's gold) whose near end
rushes along the floor and up into his chest by 2/3 of *BR-FLY-F* and whose far end follows from the wall by *BR-FLY-F*,
brightening, a light at its head; then the gathered light flares at his chest (*BR-GATHER-F*, bigger with more traces; a
faint puff for none). 0 B."
  (declare (type f32vec jm) (fixnum side c))
  (setf e nil)                                          ; (unused: the hook's entity, kept for the signature)
  (let* ((v *br-fly*) (o (* 65 side)) (n (min 16 (f->i (aref v o)))) (pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+))
         (ff (i->f (the fixnum *br-fly-f*))) (cf (i->f c)) (b (%lb-ss (/ cf ff))) (a (%lb-ss (/ cf (* 0.667f0 ff))))
         (k (- 1f0 (%lb-ss (/ (- cf (- ff 2f0)) 3f0)))) (p *lb-p*))
    (declare (type f32vec v p) (fixnum o n) (single-float pal ff cf b a k))
    (joint-point! p jm (ji :chest) 0f0 0f0 0f0)
    (let ((cx (aref p 0)) (cy (aref p 1)) (cz (aref p 2)))
      (declare (single-float cx cy cz))
      (when (> k 0.01f0)
        (dotimes (i n)
          (let* ((q (+ o 1 (* 4 i))) (yaw (aref v (+ q 2))) (ux (- (f-sin yaw))) (uz (- (f-cos yaw)))
                 (ox (+ (aref v q) (* 0.6f0 ux))) (oz (+ (aref v (+ q 1)) (* 0.6f0 uz))) (l (%lb-wall ox oz ux uz))
                 (fx0 (+ ox (* l ux))) (fz0 (+ oz (* l uz)))
                 (nx (+ ox (* a (- cx ox)))) (ny (+ 0.05f0 (* a (- cy 0.05f0)))) (nz (+ oz (* a (- cz oz))))
                 (fx (+ fx0 (* b (- cx fx0)))) (fy (+ 0.05f0 (* b (- cy 0.05f0)))) (fz (+ fz0 (* b (- cz fz0))))
                 (w (* (if (> (aref v (+ q 3)) 0.5f0) 0.12f0 0.045f0) (+ 1f0 (* 1.4f0 b)))) (sd (i->f i)))
            (declare (fixnum q) (single-float yaw ux uz ox oz l fx0 fz0 nx ny nz fx fy fz w sd))
            (toon-ribbon (fx fy fz) ((- nx fx) (- ny fy) (- nz fz)) ((* 0.5f0 w) w) :heat (0.8f0 1f0) :seed (- -61f0 sd) :wob 0.04f0
                         :pal pal :k (* 0.95f0 k) :k1 k :segs 3)
            (toon-ribbon (fx fy fz) ((- nx fx) (- ny fy) (- nz fz)) ((* 0.15f0 w) (* 0.35f0 w)) :heat (1f0 1f0) :seed (- -62f0 sd)
                         :wob 0.02f0 :pal +pal-hit+ :k (* 0.9f0 k) :k1 (* 0.9f0 k) :segs 2)
            (when (< a 0.98f0)                              ; the light's head
              (fx-star nx ny nz 0.05f0 0.16f0 6 (+ sd (* 0.3f0 cf)) 0f0 0f0 0.1f0 (+ 63f0 sd) pal (* 0.9f0 k) :push 0.2f0)))))
      (let* ((g0 (i->f (the fixnum (first *br-gather-f*)))) (g1 (i->f (the fixnum (second *br-gather-f*))))
             (u (/ (- cf g0) (- g1 g0))) (s (+ 0.3f0 (* 0.12f0 (i->f n)))))
        (declare (single-float g0 g1 u s))
        (when (< 0f0 u 1f0)
          (let ((kk (* (if (zerop n) 0.5f0 0.95f0) (f-sin (* 3.1415927f0 u)))))
            (declare (single-float kk))
            (fx-star cx cy cz (* 0.15f0 s kk) (* 0.55f0 s kk) 10 (* 2f0 cf 0.1f0) 0f0 0f0 0.15f0 64f0 pal kk :push 0.35f0)
            (fx-star cx cy cz (* 0.06f0 s kk) (* 0.22f0 s kk) 6 (* -3f0 cf 0.1f0) 0f0 0f0 0.05f0 65f0 +pal-hit+ kk :push 0.4f0))))))
  nil)

(defun-fast %br-beat-look (e f jm side mv)
  "A recall string's beat (*BR-RC-BEATS*), its first 5 frames: from each firing wing tip (the claw: the rig's hand) a line
at him (to his chest, the line's height), jade (the owl's gold), thinning, a flash at the tip; the finisher's from both
(wider; 裁き・極's wider still and held 9 frames). 0 B but the opponent's place (one lookup on those frames)."
  (declare (type f32vec jm) (fixnum side))
  (setf e nil)
  (let* ((b (br-rc-beat (mv-name mv) (fighter-sf f))) (kind (if (>= b 0) (floor b 1000) 0)) (age (if (>= b 0) (mod b 1000) 99))
         (big (and (= kind 4) (eq (mv-name mv) :br-rc4))) (life (if big 9 5)))
    (declare (fixnum b kind age life))
    (when (and (eq (fighter-phase f) :main) (< age life))
      (let* ((q (pos-of (fighter-opp f))) (p *lb-p*) (k (- 1f0 (/ (i->f age) (i->f life))))
             (pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+)) (w (* k (if (= kind 4) (if big 0.24f0 0.16f0) 0.06f0)))
             (tx (aref q 0)) (ty 1.2f0) (tz (aref q 2)))
        (declare (type f32vec q p) (single-float k pal w tx ty tz))
        (dotimes (h 2)
          (when (logbitp h (if (= kind 4) 3 kind))
            (joint-point! p jm (if (= h 0) (ji :hand-r) (ji :hand-l)) 0f0 0f0 0f0)
            (let ((hx (aref p 0)) (hy (aref p 1)) (hz (aref p 2)) (sd (i->f (+ h (* 2 kind)))))
              (declare (single-float hx hy hz sd))
              (toon-ribbon (hx hy hz) ((- tx hx) (- ty hy) (- tz hz)) (w (* 0.6f0 w)) :heat (1f0 0.7f0) :seed (- -71f0 sd)
                           :wob 0.02f0 :pal pal :k (* 0.95f0 k) :k1 (* 0.7f0 k) :segs 2)
              (toon-ribbon (hx hy hz) ((- tx hx) (- ty hy) (- tz hz)) ((* 0.35f0 w) (* 0.2f0 w)) :heat (1f0 1f0) :seed (- -72f0 sd)
                           :wob 0f0 :pal +pal-hit+ :k (* 0.9f0 k) :k1 (* 0.6f0 k) :segs 2)
              (fx-star hx hy hz (* 0.05f0 k) (* (if (= kind 4) 0.4f0 0.2f0) k) 6 sd 0f0 0f0 0.1f0 (+ 73f0 sd) pal k :push 0.25f0)))))))
  nil)

;; 裁き・極's own looks (decision V8, §22), over the shared finisher drive (BR-RC-DRIVE's ring at *BR-FINISHER*'s scale):
;; JILLIEL's NIJUSHI-KO ring drawn out as its twenty-four holes round him, bigger than the wings' (lit one after another,
;; all lit and shaking by f44), bursting outward with the beam; the owl's Trompete-like gold blast gathering between its
;; raised claws; then the wider, longer beam along his line to the wall, a floor shock ring under him.
(defparameter *br-kiwami-ring* '(1.0 2.0 0.35)
  "裁き・極's hole ring: its radius grows from the first (m) to the second over the ring's first half; its centre sits the
third (m) behind his chest, in the plane facing the opponent.")
(defparameter *br-kiwami-beam* '(14 0.42 3.0)
  "裁き・極's beam overlay: lasts this many frames from f48, this half-width (m) at its widest (裁き's line overlay 5 f, 0.16),
and runs this far (m) past the opponent (the wall nearer; never on into the front view's camera).")

(defun-fast %br-kiwami-look (f jm side)
  "裁き・極 (the move :br-rc4) at its frame: f38-47 the ring (JILLIEL: 24 holes on a circle facing him, lit in turn,
shaking; the owl: the gold blast gathering between its raised claws), f48 on the beam (*BR-KIWAMI-BEAM*: a wide jade / gold
ribbon from his chest along his line to the wall, its white core, the holes bursting outward, a shock ring on the floor).
Reads *BR-AT* (his place and the opponent's, BR-DRAW's) and the move's frame. 0 B."
  (declare (type f32vec jm) (fixnum side))
  (let* ((at *br-at*) (o (* 8 side)) (sf (fighter-sf f)) (gold (> (lb-fxs side 15) 0.5f0))
         (pal (if gold +pal-gold+ +pal-jade+)) (tm (fx-clock)) (p *lb-p*))
    (declare (type f32vec at p) (fixnum o sf) (single-float pal tm))
    (when (and (> (aref at (+ o 4)) 0.5f0) (<= 38 sf 61))
      (let* ((dx (- (aref at (+ o 2)) (aref at o))) (dz (- (aref at (+ o 3)) (aref at (+ o 1))))
             (dl (f-max 0.01f0 (f-hypot dx dz))) (ux (/ dx dl)) (uz (/ dz dl)) (sx (- uz)) (sz ux)
             (r0 (f32 (first *br-kiwami-ring*))) (r1 (f32 (second *br-kiwami-ring*))) (bk (f32 (third *br-kiwami-ring*))))
        (declare (single-float dx dz dl ux uz sx sz r0 r1 bk))
        (joint-point! p jm (ji :chest) 0f0 0f0 0f0)
        (let ((cx (- (aref p 0) (* bk ux))) (cy (+ (aref p 1) 0.25f0)) (cz (- (aref p 2) (* bk uz))))
          (declare (single-float cx cy cz))
          (if (< sf 48)
              (let* ((u (/ (i->f (- sf 38)) 10f0)) (r (+ r0 (* (- r1 r0) (%lb-ss (/ u 0.5f0)))))
                     (lit (f->i (* 24f0 (%lb-ss (/ u 0.6f0))))) (shk (* 0.06f0 (%lb-ss (/ (- u 0.3f0) 0.7f0)))))
                (declare (single-float u r shk) (fixnum lit))
                (if gold                                ; the owl: the blast gathering between the raised claws
                    (progn
                      (joint-point! p jm (ji :hand-r) 0f0 0f0 0f0)
                      (let ((hx (aref p 0)) (hy (aref p 1)) (hz (aref p 2)))
                        (declare (single-float hx hy hz))
                        (joint-point! p jm (ji :hand-l) 0f0 0f0 0f0)
                        (let* ((mx (* 0.5f0 (+ hx (aref p 0)))) (my (+ 0.1f0 (* 0.5f0 (+ hy (aref p 1)))))
                               (mz (* 0.5f0 (+ hz (aref p 2)))) (j (* shk (f-sin (* 41f0 tm))))
                               (g (+ 0.12f0 (* 0.48f0 (%lb-ss u)))))
                          (declare (single-float mx my mz j g))
                          (fx-disc (+ mx j) my (- mz j) g 0.25f0 131f0 +pal-gold+ 0.95f0 :push 0.3f0)
                          (fx-disc (+ mx j) my (- mz j) (* 0.45f0 g) 0.15f0 132f0 +pal-hit+ 0.98f0 :push 0.4f0)
                          (fx-star (+ mx j) my (- mz j) (* 0.5f0 g) (* 2.2f0 g) 10 (* 2f0 tm) 0f0 0f0 0.15f0 133f0 +pal-gold+
                                   (+ 0.5f0 (* 0.45f0 u)) :push 0.35f0))))
                    (dotimes (i 24)                     ; JILLIEL: the twenty-four holes, lit in turn
                      (when (< i lit)
                        (let* ((a (+ (* 0.2617994f0 (i->f i)) (* shk (f-sin (+ (* 37f0 tm) (* 2.3f0 (i->f i)))))))
                               (ca (f-cos a)) (sa (f-sin a)) (hx (+ cx (* r ca sx))) (hy (+ cy (* r sa))) (hz (+ cz (* r ca sz)))
                               (sd (i->f i)))
                          (declare (single-float a ca sa hx hy hz sd))
                          (fx-star hx hy hz 0.03f0 (+ 0.06f0 (* 0.06f0 u)) 6 (+ sd tm) 0f0 0f0 0.1f0 (+ 134f0 sd) +pal-jade+ 0.95f0
                                   :push 0.25f0)
                          (fx-disc hx hy hz 0.04f0 0.1f0 (+ 160f0 sd) +pal-hit+ 0.95f0 :push 0.3f0)
                          (when (< (1+ i) lit)                ; (the chord to the next lit hole: the ring's line)
                            (let* ((b (+ a 0.2617994f0)) (nx (+ cx (* r (f-cos b) sx))) (ny (+ cy (* r (f-sin b))))
                                   (nz (+ cz (* r (f-cos b) sz))))
                              (declare (single-float b nx ny nz))
                              (toon-ribbon (hx hy hz) ((- nx hx) (- ny hy) (- nz hz)) (0.02f0 0.02f0) :heat (0.8f0 0.8f0)
                                           :seed (- -170f0 sd) :wob 0f0 :pal +pal-jade+ :k 0.85f0 :segs 1))))))))
              (let* ((a (i->f (- sf 48))) (life (i->f (the fixnum (first *br-kiwami-beam*))))
                     (hw (f32 (second *br-kiwami-beam*))) (ex (f32 (third *br-kiwami-beam*)))
                     (k (* (f-min 1f0 (+ 0.5f0 (/ a 4f0))) (- 1f0 (* (/ a life) (/ a life)))))
                     (bx (+ (aref p 0) (* 0.4f0 ux))) (bz (+ (aref p 2) (* 0.4f0 uz)))
                     (len (f-min (+ dl ex) (%lb-wall bx bz ux uz))))
                (declare (single-float a life hw ex k bx bz len))
                (when (and (< a life) (> k 0.02f0))     ; the beam, wider and longer than 裁き's
                  (toon-ribbon (bx 1.2f0 bz) ((* len ux) 0f0 (* len uz)) ((* hw k) (* 0.5f0 hw k)) :heat (1f0 0.8f0)
                               :seed -141f0 :wob 0.03f0 :pal pal :k (* 0.95f0 k) :k1 (* 0.8f0 k) :segs 3)
                  (toon-ribbon (bx 1.2f0 bz) ((* len ux) 0f0 (* len uz)) ((* 0.35f0 hw k) (* 0.25f0 hw k)) :heat (1f0 1f0)
                               :seed -142f0 :wob 0f0 :pal +pal-hit+ :k (* 0.95f0 k) :k1 (* 0.85f0 k) :segs 2)
                  (fx-star bx 1.2f0 bz (* 0.2f0 k) (* 1.4f0 k) 12 (* 0.5f0 a) 0f0 0f0 0.15f0 143f0 +pal-hit+ k :push 0.4f0)
                  (%tring (aref at o) 0f0 (aref at (+ o 1)) (+ 1f0 (* 0.45f0 a)) 0.08f0 pal (* 0.9f0 k) 144f0 32))
                (when (and (not gold) (< a 10f0))       ; the holes burst outward with it
                  (let ((r (+ r1 (* 0.12f0 a))) (kk (- 1f0 (/ a 10f0))))
                    (declare (single-float r kk))
                    (dotimes (i 24)
                      (let* ((an (* 0.2617994f0 (i->f i))) (ca (f-cos an)) (sa (f-sin an)) (sd (i->f i)))
                        (declare (single-float an ca sa sd))
                        (fx-star (+ cx (* r ca sx)) (+ cy (* r sa)) (+ cz (* r ca sz)) 0.03f0 (* 0.12f0 kk) 6 sd 0f0 0f0 0.1f0
                                 (+ 134f0 sd) +pal-jade+ kk :push 0.25f0)))))))))))
  nil)

;; (unused with the swing clips since the revert: no move plays them, so this never draws) the ranged L swing's hit
;; (decision V8: a hit sets the aim point): a light stroke flicked from the swing's tip back over
;; his shoulder onto the new sigil 0.5 m behind him, while the set's flare (%BR-LIVE-LOOK) stamps it in
(defun br-hold-clock (f)
  "The art stills' clock of F's move (debug 82200+f): the recall chain's (%BR-CHAIN-CLOCK), else the move's frame, else -1."
  (let ((mv (and (eq (fighter-state f) :move) (fighter-move f))))
    (if mv (let ((c (%br-chain-clock (mv-name mv) (fighter-sf f)))) (if (>= c 0) c (fighter-sf f))) -1)))


;;; ---------------------------------------------------------------- BR-DRAW
(declaim (type f32vec *br-at*))
(defvar *br-at* (make-f32 16)
  "Per side (8 a side), written by BR-DRAW every frame: [0 1] his x z, [2 3] the opponent's, [4] 1 once written (the volley's
裁き・極 look reads it).")
(defmacro %br-place! (e opp side)
  "*BR-AT* [8 SIDE ..] = E's and OPP's x z, read in a DO-ENTITIES pass over the transforms (a component getter conses
8 B in this build; the pass does not)."
  `(let ((%at *br-at*) (%o (* 8 ,side)) (%e ,e) (%q ,opp))
     (declare (type f32vec %at) (fixnum %o))
     (do-entities (%h (%tr transform))
       (cond ((eql %h %e) (let ((%p (transform-pos %tr)))
                            (declare (type f32vec %p))
                            (setf (aref %at %o) (aref %p 0) (aref %at (+ %o 1)) (aref %p 2) (aref %at (+ %o 4)) 1f0)))
             ((eql %h %q) (let ((%p (transform-pos %tr)))
                            (declare (type f32vec %p))
                            (setf (aref %at (+ %o 2)) (aref %p 0) (aref %at (+ %o 3)) (aref %p 2))))))))

;;; ---------------------------------------------------------------- R5 K3 零距離砲擊 (DUEL_LILLE_V3 §10; R6 §11: a ball of light)
(defparameter *br-blast-moves* '(:br-e-k3 :br-oe-k3)
  "The moves whose last hit is 零距離砲擊 (the awakened stance's K3, R5: 「爆炸特效的零距離砲擊」): the blast at its frame.")
(defparameter *br-blast-life* 18 "零距離砲擊's blast: the frames it lasts from the last hit's first frame ...")
(defparameter *br-blast-r* 0.8 "... its ball's radius at full size (m), x the draw scale.")
(defparameter *br-blast-y* '(1.3 1.65)
  "零距離砲擊's blast: its height above his floor (m; JILLIEL, the owl): where the two tips meet on the hit frame (the clips'
:br-en-cannon / :br-oen-cannon, host FK).")
(defun-fast %br-blast-look (f side mv)
  "零距離砲擊 (MV one of *BR-BLAST-MOVES*): from its last hit's frame for *BR-BLAST-LIFE* frames, a point-blank blast at the
hit's reach (its volume's edge, where the two drawn tips meet on the hit frame: the host FK test) on the line to the
opponent (*BR-AT*), *BR-BLAST-Y* up, held there while he is blown back (R6, §11: 「砲擊不要發射光束，直接在爆炸點炸開光球來表示」:
no beam, no spikes): a white flash ball on the first two frames, then a ball of light swelling, its jade (the owl: gold) shell
in a dark rim round a white core that shrinks away, eroding over its last half, dark smoke puffs rising and thinning,
a new drawing every two frames. Reads the move's frame only (cosmetic; the hit's spark and sound are the combat's). 0 B."
  (declare (fixnum side))
  (let* ((hits (mv-hits mv)) (n (length hits)) (life (the fixnum *br-blast-life*)) (at *br-at*) (o (* 8 side))
         (a (if (and (> n 0) (> (aref at (+ o 4)) 0.5f0))
                (- (the fixnum (fighter-sf f)) (the fixnum (hw-from (aref hits (1- n))))) -1)))
    (declare (fixnum n life o a) (type f32vec at))
    (when (<= 0 a life)
      (let* ((owl (> (lb-fxs side 15) 0.5f0)) (pal (if owl +pal-gold+ +pal-jade+))
             (vol (first (hw-vols (aref hits (1- n))))) (edge (+ (aref (the f32vec vol) 2) (aref (the f32vec vol) 4)))
             (dx (- (aref at (+ o 2)) (aref at o))) (dz (- (aref at (+ o 3)) (aref at (+ o 1))))
             (dl (f-max 0.01f0 (f-hypot dx dz))) (sc (aref *lb-v* 31))
             (x (+ (aref at o) (* edge (/ dx dl))))
             (y (+ (aref *lb-v* 3) (* sc (the single-float (f32 (if owl (second *br-blast-y*) (first *br-blast-y*)))))))
             (z (+ (aref at (+ o 1)) (* edge (/ dz dl))))
             (d (i->f (* 2 (floor a 2))))                 ; (on twos)
             (u (/ d (i->f life))) (r (* sc (the single-float *br-blast-r*)))
             (es (* r (+ 0.55f0 (* 0.6f0 (%lb-ss (* 3f0 u))))))   ; (swells over the first third)
             (k (- 1f0 (%lb-ss (/ (- u 0.45f0) 0.55f0))))         ; (erodes over the last half)
             (sd (+ 410f0 d (* 50f0 (i->f side)))))
        (declare (single-float pal edge dx dz dl sc x y z d u r es k sd))
        (if (< a 2)
            (fx-disc x y z (* 0.5f0 r) 0.05f0 sd +pal-hit+ 0.98f0 :push 0.45f0)   ; (the flash: a white ball)
            (progn                                        ; (the ball of light: no spikes, no line toward him)
              (fx-disc x y z (* 1.08f0 es) 0.06f0 (+ sd 3f0) +pal-ink+ (* 0.6f0 k) :push 0.2f0)   ; (its dark rim)
              (fx-disc x y z es 0.05f0 sd pal k :push 0.3f0)                                ; (the jade / gold shell)
              (let ((cr (* es (- 0.62f0 (* 0.62f0 (%lb-ss (/ u 0.6f0)))))))                 ; (the white core, shrinking)
                (declare (single-float cr))
                (when (> cr 0.02f0) (fx-disc x y z cr 0.04f0 (+ sd 5f0) +pal-hit+ 0.97f0 :push 0.4f0)))
              (when (>= a 6)                              ; the smoke: three puffs rising off it
                (dotimes (j 3)
                  (let* ((fj (i->f j)) (an (+ (* 2.1f0 fj) (* 0.3f0 u))) (rr (* r (+ 0.3f0 (* 0.5f0 u)))))
                    (declare (single-float fj an rr))
                    (fx-disc (+ x (* rr (f-cos an))) (+ y (* r (+ 0.1f0 (* 0.9f0 u))) (* 0.2f0 fj)) (+ z (* rr (f-sin an)))
                             (* r (+ 0.22f0 (* 0.3f0 u))) 0.25f0 (+ sd 20f0 fj) +pal-smoke+ (* 0.8f0 k)))))))))
    nil))

;;; ---------------------------------------------------------------- the special resource's looks (DUEL_LILLE_V3 §4)
;;; The lit wings are LILLE-DRAW's (%LB-WINGS reads the count BR-DRAW puts in *LB-FX* [19]); here the spends. BR-DRAW keeps
;;; last frame's count per side (cosmetic memory, never the sim's hooks) and reads a drop as:
;;; - a spend (one wing: a stance follow-up shot, BR-S-SPEND; or the owl's full volley, BR-RECALL-GO, every wing at once):
;;;   a light burst at each spent blade's tip and its three holes flashing out (jade, the owl's gold), *BR-SPEND-LIFE*;
;;; - the wing armour (two or more at once outside the volley: BARRO-STRUCK's 4, the owl's 2): those blades shatter, a flash
;;;   along each and shards flung out from him and falling (*BR-SHATTER-LIFE*);
;;; - in the base form a 狙擊 pip spent: a small jade glint at Diagramm's muzzle (*BR-PIP-LIFE*).
(defparameter *br-spend-life* 0.25 "A spent wing's light burst at its tip: seconds of the fx clock (held through a hitstop) ...")
(defparameter *br-shatter-life* 0.35 "... the armour's shatter (the shards' flight; the flash along each blade its first third) ...")
(defparameter *br-pip-life* 0.18 "... and a spent pip's glint at Diagramm's muzzle.")
(defparameter *br-shatter-speed* '(2.4 4.2) "The shards' speed, m/s (hashed between the two) ...")
(defparameter *br-shatter-up* 1.6 "... plus this much up (m/s), falling at *BR-SHATTER-FALL* (m/s^2) ...")
(defparameter *br-shatter-fall* 7.0 "... (a little under g: they read as light glass, not stone).")
(defparameter *br-volley-moves* '(:br-recall :br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4)
  "The volley's moves: a drop while one runs is its spend-all (each blade's burst, never the shatter).")
(declaim (type f32vec *br-wl* *br-shards*))
(defvar *br-wl* (make-f32 (* 2 136))
  "Per side (136 a side), the spends' memory: [0] the count seen last frame, [1] its pool (1 the base's pips, 2 the wings, 0
none yet), [2] the fx clock of that draw, [3] the pip glint's start (fx clock); per wing W at 8 + 16 W: [0] its look's
start (fx clock), [1] its look (0 none, 1 the spend's burst, 2 the armour's shatter), [2] 1 = the owl's gold, [3..5] its
tip and [6..14] its three holes at the start (the shards fly from there). Cosmetic memory.")
(defvar *br-shards* (let ((v (make-f32 (* 8 6 4))))
                      (dotimes (n 48 v)
                        (flet ((h (a b) (let ((x (* 43758.547 (sin (+ (* n a) b))))) (- x (floor x)))))
                          (setf (aref v (* 4 n)) (f32 (- (* 2 (h 12.9898 0.7)) 1))   ; the sideways jitter (x his side)
                                (aref v (+ 1 (* 4 n))) (f32 (h 78.233 2.1))           ; the speed share (0..1)
                                (aref v (+ 2 (* 4 n))) (f32 (- (h 39.425 4.3) 0.3))   ; the up share
                                (aref v (+ 3 (* 4 n))) (f32 (+ 0.7 (* 0.6 (h 93.989 5.9))))))))   ; the size
  "The armour's shards, 6 a wing (wing W's shard J at 4 (6 W + J)): hashed once (a fixed pattern): sideways jitter, speed
share, up share, size.")

(defmacro %br-tip! (side i p)
  "P (an f32vec) = SIDE's wing I's tip as last drawn: its third hole (*LB-HOLES*, 0.79 of the blade) carried on along the
blade past it by 0.72 x the second -> third hole (the tip at 1.0). 0 B."
  `(let* ((%h *lb-holes*) (%o (* 3 (+ (* 24 ,side) (* 3 ,i)))) (%p ,p))
     (declare (type f32vec %h %p) (fixnum %o))
     (dotimes (%q 3)
       (setf (aref %p %q) (+ (aref %h (+ %o 6 %q)) (* 0.72f0 (- (aref %h (+ %o 6 %q)) (aref %h (+ %o 3 %q)))))))))

(defun-fast %br-spend-note (f side n pool)
  "BR-DRAW's spend detector, after LILLE-DRAW (so *LB-HOLES* holds this frame's blades): SIDE's special count N in POOL (1
the base's pips, 2 the wings) against last frame's (*BR-WL*); a drop in the same pool, the last draw at most 0.25 s ago,
starts the spent wings' looks (the volley's or one: the burst; two or more otherwise: the armour's shatter) or the pip's
glint. 0 B."
  (declare (fixnum side n pool))
  (let* ((wl *br-wl*) (o (* 136 side)) (tm (fx-clock)) (last (f->i (aref wl o))) (dt (- tm (aref wl (+ o 2)))))
    (declare (type f32vec wl) (fixnum o last) (single-float tm dt))
    (when (and (= pool (f->i (aref wl (+ o 1)))) (< n last) (<= -0.001f0 dt 0.25f0))
      (if (= pool 1)
          (setf (aref wl (+ o 3)) tm)
          (let* ((mv (and (eq (fighter-state f) :move) (fighter-move f)))
                 (volley (and mv (member (mv-name mv) *br-volley-moves*)))
                 (mode (if (and (>= (- last n) 2) (not volley)) 2f0 1f0))
                 (gold (if (> (lb-fxs side 15) 0.5f0) 1f0 0f0)) (p *lb-p*) (h *lb-holes*))
            (declare (type f32vec p h) (single-float mode gold))
            (loop for i of-type fixnum from n below (min 8 last)
                  do (let ((q (+ o 8 (* 16 i))) (ho (* 3 (+ (* 24 side) (* 3 i)))))
                       (declare (fixnum q ho))
                       (%br-tip! side i p)
                       (setf (aref wl q) tm (aref wl (+ q 1)) mode (aref wl (+ q 2)) gold
                             (aref wl (+ q 3)) (aref p 0) (aref wl (+ q 4)) (aref p 1) (aref wl (+ q 5)) (aref p 2))
                       (dotimes (k 9) (setf (aref wl (+ q 6 k)) (aref h (+ ho k)))))))))
    (setf (aref wl o) (i->f n) (aref wl (+ o 1)) (i->f pool) (aref wl (+ o 2)) tm))
  nil)

(defun-fast %br-spend-look (e side)
  "The spent wings' looks (*BR-WL*, noted by %BR-SPEND-NOTE) at the fx clock: the spend's burst at each blade's tip as it
is drawn now (a star, a white core, its three holes flashing out); the armour's shatter (a flash along the blade over its
first third, six shards a blade flung out from him from its holes and tip as they were, falling, shrinking); the pip's
glint at Diagramm's muzzle (the model looked up only while one shows). 0 B but that lookup."
  (declare (fixnum side))
  (let* ((wl *br-wl*) (o (* 136 side)) (tm (fx-clock)) (p *lb-p*) (h *lb-holes*) (at *br-at*) (sv *br-shards*)
         (sl (the single-float *br-spend-life*)) (hl (the single-float *br-shatter-life*)))
    (declare (type f32vec wl p h at sv) (fixnum o) (single-float tm sl hl))
    (dotimes (i 8)
      (let* ((q (+ o 8 (* 16 i))) (mode (f->i (aref wl (+ q 1)))) (age (- tm (aref wl q)))
             (pal (if (> (aref wl (+ q 2)) 0.5f0) +pal-gold+ +pal-jade+)) (sd (i->f (+ i (* 8 side)))))
        (declare (fixnum q mode) (single-float age pal sd))
        (cond ((= mode 0))
              ((or (< age -0.001f0) (> age (if (= mode 1) sl hl))) (setf (aref wl (+ q 1)) 0f0))
              ((= mode 1)                                ; the spend: the light bursting off the tip
               (let* ((u (/ age sl)) (k (- 1f0 (* u u))) (ho (* 3 (+ (* 24 side) (* 3 i)))))
                 (declare (single-float u k) (fixnum ho))
                 (%br-tip! side i p)
                 (fx-star (aref p 0) (aref p 1) (aref p 2) (+ 0.04f0 (* 0.06f0 u)) (+ 0.14f0 (* 0.36f0 (%lb-ss (/ u 0.4f0))))
                          7 (+ sd (* 2f0 u)) 0f0 0f0 0.1f0 (+ 280f0 sd) pal k :push 0.25f0)
                 (fx-star (aref p 0) (aref p 1) (aref p 2) 0.03f0 (* 0.2f0 (- 1f0 u)) 5 (* 1.7f0 sd) 0f0 0f0 0.05f0
                          (+ 290f0 sd) +pal-hit+ k :push 0.3f0)
                 (dotimes (g 3)                          ; its holes flashing out
                   (fx-disc (aref h (+ ho (* 3 g))) (aref h (+ ho (* 3 g) 1)) (aref h (+ ho (* 3 g) 2))
                            (* 0.08f0 (- 1f0 u)) 0.04f0 (+ 300f0 sd (i->f g)) pal (* 0.9f0 k) :push 0.15f0))))
              (t                                         ; the armour: the blade shatters
               (let* ((u (/ age hl)) (k (- 1f0 (* u u u))) (ax (aref at (* 8 side))) (az (aref at (+ (* 8 side) 1)))
                      (sp0 (f32 (first *br-shatter-speed*))) (sp1 (f32 (second *br-shatter-speed*)))
                      (up (the single-float *br-shatter-up*)) (gv (the single-float *br-shatter-fall*)))
                 (declare (single-float u k ax az sp0 sp1 up gv))
                 (when (< u 0.34f0)                      ; the flash along the blade
                   (let ((kf (- 1f0 (/ u 0.34f0))))
                     (declare (single-float kf))
                     (toon-ribbon ((aref wl (+ q 6)) (aref wl (+ q 7)) (aref wl (+ q 8)))
                                  ((- (aref wl (+ q 3)) (aref wl (+ q 6))) (- (aref wl (+ q 4)) (aref wl (+ q 7)))
                                   (- (aref wl (+ q 5)) (aref wl (+ q 8))))
                                  ((* 0.12f0 kf) (* 0.08f0 kf)) :heat (1f0 1f0) :seed (- -300f0 sd) :wob 0.05f0 :pal +pal-hit+
                                  :k kf :k1 (* 0.8f0 kf) :segs 2)
                     (fx-star (aref wl (+ q 9)) (aref wl (+ q 10)) (aref wl (+ q 11)) (* 0.08f0 kf) (+ 0.25f0 (* 0.35f0 u)) 9
                              (* 2.3f0 sd) 0f0 0f0 0.15f0 (+ 310f0 sd) pal kf :push 0.3f0)))
                 (dotimes (j 6)                          ; the shards: from the holes and the tip, outward from him, falling
                   (let* ((r (* 4 (+ (* 6 i) j))) (c (* 0.6f0 (i->f j)))   ; (their start: along holes 0 -> 1 -> 2 -> tip)
                          (seg (min 2 (f->i c))) (fr (- c (i->f seg)))
                          (a0 (+ q 6 (* 3 seg))) (a1 (if (= seg 2) (+ q 3) (+ q 9 (* 3 seg))))
                          (x0 (+ (aref wl a0) (* fr (- (aref wl a1) (aref wl a0)))))
                          (y0 (+ (aref wl (+ a0 1)) (* fr (- (aref wl (+ a1 1)) (aref wl (+ a0 1))))))
                          (z0 (+ (aref wl (+ a0 2)) (* fr (- (aref wl (+ a1 2)) (aref wl (+ a0 2))))))
                          (ox (- x0 ax)) (oz (- z0 az)) (ol (f-max 0.05f0 (f-hypot ox oz))) (ux (/ ox ol)) (uz (/ oz ol))
                          (jt (aref sv r)) (spd (+ sp0 (* (aref sv (+ r 1)) (- sp1 sp0))))
                          (vx (* spd (- ux (* 0.6f0 jt uz)))) (vz (* spd (+ uz (* 0.6f0 jt ux))))
                          (vy (+ up (* spd (aref sv (+ r 2)))))
                          (px (+ x0 (* vx age))) (py (+ y0 (* vy age) (* -0.5f0 gv age age))) (pz (+ z0 (* vz age)))
                          (dvy (- vy (* gv age))) (dl (f-max 1f-3 (f-hypot vx dvy vz))) (sz (aref sv (+ r 3))))
                     (declare (fixnum r seg a0 a1)
                              (single-float c fr x0 y0 z0 ox oz ol ux uz jt spd vx vz vy px py pz dvy dl sz))
                     (when (> py 0.02f0)
                       (fx-shard px py pz (/ vx dl) (/ dvy dl) (/ vz dl) (* 0.2f0 sz (- 1f0 (* 0.5f0 u))) (* 0.045f0 sz k)
                                 0.1f0 (+ 320f0 sd (i->f j)) pal k :push 0.1f0)))))))))
    (let ((age (- tm (aref wl (+ o 3)))) (pl (the single-float *br-pip-life*)))   ; the base's pip glint at the muzzle
      (declare (single-float age pl))
      (when (<= 0f0 age pl)
        (let ((u (/ age pl)))
          (declare (single-float u))
          (joint-point! p (model-joints (model e)) (ji :weapon-r) 0f0 0f0 -1.75f0)
          (fx-star (aref p 0) (aref p 1) (aref p 2) 0.04f0 (+ 0.12f0 (* 0.2f0 (%lb-ss (/ u 0.3f0)))) 6 (* 2f0 u) 0f0 0f0
                   0.08f0 330f0 +pal-jade+ (- 1f0 (* u u)) :push 0.2f0)
          (fx-star (aref p 0) (aref p 1) (aref p 2) 0.02f0 (* 0.1f0 (- 1f0 u)) 4 0.4f0 0f0 0f0 0.05f0 331f0 +pal-hit+
                   (- 1f0 u) :push 0.25f0)))))
  nil)



(defun-fast br-draw (e rdt)
  "His kit's :draw hook: his special count to Lille's wings (*LB-FX* [19]: awakened, the first N blades lit, the rest
dimmed), Lille's (LILLE-DRAW: his forms carry Lille's form names, so the wings, the halos, the legs and the cinematics'
drives come out the same; his volley strings drive its SP looks through BR-RC-DRIVE), then the base stance's aim line
(%BR-AIM-LOOK); his place and the opponent's (%BR-PLACE!); the spends (%BR-SPEND-NOTE against last frame's count: a
wing's burst at its tip, the armour's shatter, a pip's glint at the muzzle; %BR-SPEND-LOOK); the volley's light gathering
(%BR-RECALL-LOOK), each string beat's lines from the wing tips (%BR-BEAT-LOOK) and 裁き・極's ring, blast and beam
(%BR-KIWAMI-LOOK)."
  (declare (single-float rdt))
  (let* ((f (fighter e)) (side (fighter-side f)) (mv (and (eq (fighter-state f) :move) (fighter-move f)))
         (c (if mv (%br-chain-clock (mv-name mv) (fighter-sf f)) -1)) (o (* 65 side))
         (awake (member (fighter-form f) '(:jilliel-kin :jilliel :shin-kin :shin))) (n (br-ammo-look e)))
    (declare (fixnum side c o n))
    (setf (lb-fxs side 19) (if awake (i->f (1+ (min 8 n))) 0f0))
    (lille-draw e rdt)
    (if (eq (fighter-form f) :base)
        (%br-aim-look e f side)
        (%br-place! e (fighter-opp f) side))
    (%br-spend-note f side n (if awake 2 1))
    (%br-spend-look e side)
    (setf (aref *br-fly* o) 0f0)                        ; (no traces to fly back since v3: the gathering only)
    (when (>= c 0)
      (let ((jm (model-joints (model e))))
        (when (<= c 16) (%br-recall-look e jm side c))
        (when (not (eq (mv-name mv) :br-recall)) (%br-beat-look e f jm side mv))
        (when (and (eq (mv-name mv) :br-rc4) (eq (fighter-phase f) :main)) (%br-kiwami-look f jm side))))
    (when (and mv (member (mv-name mv) *br-blast-moves*) (eq (fighter-phase f) :main))   ; R5's 零距離砲擊
      (%br-blast-look f side mv))
    (when (and (>= *br-art-hold* 0) (>= (the fixnum (br-hold-clock f)) *br-art-hold*))   ; (debug stills)
      (setf *br-art-hold* -1)
      (hitstop 100000)))
  nil)

;;; ---------------------------------------------------------------- the art stills (debug 82100-82399, DUEL_GAMEPLAY)
(defun br-art-scene (k)
  "82100+k: Lille II (P1; k + 20: P2, facing the behind camera: the front view) 4 m from an idle Kenpachi, Reiatsu and flash
step full: k 0-4 the owl (kept without a burst) with 0 / 2 / 4 / 6 / 8 wings, the volley started (its string by the
count: 空收 / 二連 / 四連 / 裁き / 裁き・極); 8 / 9 JILLIEL's turn into the stance / its stance's K K -> L L line (KL1); 10 / 11
the owl's; 12 the owl's SP2 on its own (the volley's wind-up); 13 the base stance's SP2 HIRENKYAKU; 14 JILLIEL's SANREN;
15 / 16 / 17 the base stance's L1 / J1 / K1 (3 m out); 18 / 19 JILLIEL's stance L1 / K1 (3 m out); 40-51 the base stance's
L2 L3 J2 J3 K2 K3 JL1 JL2 JL3 KL1 KL2 KL3 (3 m out, started on their own, 3 pips; + 20 the front view). The awakened
stances' moves: BR-ART-STANCE."
  (let* ((front (oddp (floor k 20))) (k (if front (- k 20) k)) (owl (or (<= 0 k 4) (<= 10 k 13))))
    (if front (ensure-battle :kenpachi :barro) (ensure-battle :barro :kenpachi))
    (let* ((b (if front *p2* *p1*)) (o (if front *p1* *p2*)) (g (gauges b)))
      (setf *br-keep-owl* owl)
      (force-form b (cond ((or (<= 15 k 17) (<= 40 k 51)) :base) ((<= 18 k 19) :jilliel) (owl :shin-kin) (t :jilliel-kin)))
      (place *p1* *p2* (if (or (<= 15 k 19) (<= 40 k 51)) 3.0 4.0))
      (setf (gauges-reiatsu g) *reiatsu-max* (gauges-fs g) (f32 *fs-max*)
            (gauges-reishi (gauges o)) (gauges-reishi-max (gauges o)))   ; (no K.O. across a script's scenes)
      (case k
        ((0 1 2 3 4) (br-set-ammo b (nth k '(0 2 4 6 8))) (start-move b (find-move :br-recall)))
        ((8 10) (start-move b (find-move :br-to-en)))
        (9 (start-move b (find-move :br-e-kl1)))
        (11 (start-move b (find-move :br-oe-kl1)))
        (12 (start-move b (find-move :br-recall-s)))
        (13 (force-form b :base) (start-move b (find-move :br-k-hiren)))
        (14 (start-move b (find-move :br-w-sanren)))
        (15 (start-move b (find-move :br-s-l1))) (16 (start-move b (find-move :br-s-j1))) (17 (start-move b (find-move :br-s-k1)))
        (18 (start-move b (find-move :br-e-l1))) (19 (start-move b (find-move :br-e-k1)))
        ((40 41 42 43 44 45 46 47 48 49 50 51)
         (br-set-ammo b 3)
         (start-move b (find-move (nth (- k 40) '(:br-s-l2 :br-s-l3 :br-s-j2 :br-s-j3 :br-s-k2 :br-s-k3 :br-s-jl1 :br-s-jl2
                                                  :br-s-jl3 :br-s-kl1 :br-s-kl2 :br-s-kl3))))))
      (setf *br-art-hold* *br-art-hold-next* *br-art-hold-next* -1))))

(defun br-art-stance (m)
  "82320+m: Lille II (P1) 3 m from an idle Kenpachi, 8 wings, Reiatsu and flash step full, his awakened stance's move
started on its own: m 0-14 JILLIEL EN's (L1 L2 L3 J1 J2 J3 K1 K2 K3 JL1 JL2 JL3 KL1 KL2 KL3, *BR-S-SEGS*' order: the
openers' clips :br-en-*, the follow-ups' :br-e-jf* / -kf*), 20-34 the owl EN's (kept without a burst: :br-oen-*, :br-oe-jf* /
-kf*); 40-54 JILLIEL's again as P2, facing the behind camera (the front view)."
  (let* ((front (>= m 40)) (m (if front (- m 40) m)) (owl (and (not front) (>= m 20)))
         (sn (nth (if owl (- m 20) m) '("L1" "L2" "L3" "J1" "J2" "J3" "K1" "K2" "K3" "JL1" "JL2" "JL3" "KL1" "KL2" "KL3")))
         (mv (and sn (gethash (intern (format nil "~a-~a" (if owl "BR-OE" "BR-E") sn) :keyword) *moves*))))
    (if (null mv)
        (log-msg "duel barro: no stance still ~d" m)
        (progn
          (if front (ensure-battle :kenpachi :barro) (ensure-battle :barro :kenpachi))
          (let* ((b (if front *p2* *p1*)) (o (if front *p1* *p2*)) (g (gauges b)))
            (setf *br-keep-owl* owl)
            (force-form b (if owl :shin :jilliel))
            (place *p1* *p2* 3.0)
            (setf (gauges-reiatsu g) *reiatsu-max* (gauges-fs g) (f32 *fs-max*)
                  (gauges-reishi (gauges o)) (gauges-reishi-max (gauges o)))
            (br-set-ammo b 8)
            (start-move b mv)
            (setf *br-art-hold* *br-art-hold-next* *br-art-hold-next* -1))))))

(defun br-art-cine (f)
  "82300+k: his awakening (Lille's lb-jilliel-cine, his caption) with P1 Lille II 6 m from Kenpachi, held at frame 10 k."
  (unless (and *cine* (eq (cine-name *cine*) 'lb-jilliel-cine))
    (abort-cine) (setf *cine-hold* nil)
    (ensure-battle :barro :kenpachi) (place *p1* *p2* 6.0) (force-form *p1* :jilliel-kin)
    (start-cine 'lb-jilliel-cine *p1* *p2*))
  (when *cine* (setf *cine-hold* t (cine-hold *cine*) f)))

(defun br-art-ammo (k)
  "82380+k: the special resource of the Lille II on the field (P1, else P2) set to K, as a sim spend would (the looks
read the drop: one wing the burst at its tip, two or more the armour's shatter, a pip the muzzle glint)."
  (let ((b (if (and *p1* (eq (kit-character (fighter-kit (fighter *p1*))) :barro)) *p1* *p2*)))
    (when b (br-set-ammo b k))))

(defun barro-art-debug (c)
  "His art stills (barro.lisp registers 82100-82399 ahead of BARRO-DEBUG): 82100+k BR-ART-SCENE k (+ 20 the front view);
82200+f the sim freezes once his look clock reaches f (the volley chain's: the recall's frame, 7 + its string's; else the
move's frame; issue it before the scene), 82299 lets go; 82300+k his awakening held at frame 10 k (BR-ART-CINE);
82320+m his awakened stance's move m on its own (BR-ART-STANCE); 82380+k his special set to k, 0-8 (BR-ART-AMMO: the spend
looks); 82398 the consing probe."
  (let ((n (- c 82100)))
    (cond ((< n 100) (br-art-scene n))
          ((< n 199) (setf *br-art-hold-next* (- n 100)))
          ((= n 199) (setf *br-art-hold* -1 *br-art-hold-next* -1 *hitstop* 0))
          ((< n 219) (br-art-cine (* 10 (- n 200))))
          ((<= 220 n 274) (br-art-stance (- n 220)))
          ((<= 280 n 288) (br-art-ammo (- n 280)))
          ((= n 298) (br-cons-probe))
          (t (log-msg "duel barro: no debug command ~d" c)))))

(defun br-cons-probe ()
  "82398: bytes consed by 10 draws of P1 Lille II's :draw hook (BR-DRAW, LILLE-DRAW's lookups included), of the spends'
note and looks (%BR-SPEND-NOTE / -LOOK: the pip glint's model lookup aside), of his volley look
at its clock 4 and of a string beat's lines (when a string runs), and of 裁き・極's look (while it runs), of 零距離砲擊's
blast (in an awakened K3), and of the whips' stretch and the owl's lashes (R5; a \"barro consing\" line)."
  (let* ((e *p1*) (f (fighter e)) (side (fighter-side f)) (jm (model-joints (model e)))
         (mv (and (eq (fighter-state f) :move) (fighter-move f))))
    (macrolet ((per (form) `(let ((c0 (cons-bytes))) (dotimes (i 10) ,form) (- (cons-bytes) c0))))
      (log-msg "barro consing (10 draws, B): form ~a clock ~d draw ~d (Lille's ~d) spends ~d recall ~d beat (lines drive beat) ~a kiwami ~d blast ~d stretch ~d lashes ~d"
               (fighter-form f) (br-hold-clock f)
               (per (br-draw e 0.016f0)) (per (lille-draw e 0.016f0))
               (per (progn (%br-spend-note f side (br-ammo-look e) 2) (%br-spend-look e side))) (per (%br-recall-look e jm side 4))
               (if (and mv (member (mv-name mv) '(:br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4)))
                   (list (per (%br-beat-look e f jm side mv)) (per (br-rc-drive f mv)) (per (br-rc-beat (mv-name mv) (fighter-sf f))))
                   -1)
               (if (and mv (eq (mv-name mv) :br-rc4)) (per (%br-kiwami-look f jm side)) -1)
               (if (and mv (member (mv-name mv) *br-blast-moves*)) (per (%br-blast-look f side mv)) -1)
               (per (%lb-stretch! (model-anim (model e)))) (per (%lb-lashes jm side))))))

;;; ---------------------------------------------------------------- the HUD: the special resource (DUEL_LILLE_V3 §3.1)
(defparameter *br-sn-strings* #("SN 0" "SN 1" "SN 2" "SN 3") "The base form's label: SN + the 狙擊 pips.")
(defparameter *br-wg-strings* (let ((v (make-array 9))) (dotimes (i 9 v) (setf (svref v i) (format nil "WG ~d" i))))
  "The awakened forms' label: WG + the wings.")

(defun br-hud-label (g kit)
  "The portrait block's label: SN n (the 狙擊 pips) in the base form, WG n (the wings) awakened."
  (let* ((e (lb-side-of g)) (st (brs e)) (n (if st (brs-ammo st) 0)))
    (if (eq (kit-form kit) :base)
        (svref *br-sn-strings* (max 0 (min 3 n)))
        (svref *br-wg-strings* (max 0 (min 8 n))))))

(defun br-hud-meter (e kit x y w h right tm lx ly ls)
  "His kit-meter row (LX LY LS: the landscape label's place, NIL in the portrait slot): the special resource's pips (Lille's
reticle glyph: a filled pip the open jade eye, an empty one the shut white): the base form's three 狙擊 pips, awakened the
eight wings; its label SN n / WG n."
  (let* ((st (brs e)) (v *lb-hud*) (n (if st (brs-ammo st) 0)) (cap (if (eq (kit-form kit) :base) 3 8)))
    (setf (aref v 3) (f32 tm) (aref v 4) (f32 x) (aref v 5) (f32 y) (aref v 6) (f32 w) (aref v 7) (f32 h))
    (let* ((step (/ w cap)) (r (min (* 0.36 step) (max 5.0 (* 2.4 h)))))
      (dotimes (i cap)
        (setf (aref v 0) (f32 (if right (- (+ x w) (* step (+ i 0.5))) (+ x (* step (+ i 0.5)))))
              (aref v 1) (f32 (+ y (* 0.5 h))) (aref v 2) (f32 r))
        (%lb-pip (if (< i n) 1 0))))
    (when lx
      (hud-text (br-hud-label (gauges e) kit) lx ly ls *c-lb-jade* :align (if right :right :left)))))

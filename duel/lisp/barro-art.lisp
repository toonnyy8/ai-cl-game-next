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
;;; ---------------------------------------------------------------- the draw hook
(defparameter *br-aim-stance* '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re)
  "The base stance's moves: the aim line tracks while one runs ...")
(defparameter *br-aim-locked* '(:br-s-kl1 :br-s-jl1)
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
15 / 16 / 17 the base stance's L1 / J1 / K1 (3 m out); 18 / 19 JILLIEL's stance L1 / K1 (3 m out)."
  (let* ((front (oddp (floor k 20))) (k (if front (- k 20) k)) (owl (or (<= 0 k 4) (<= 10 k 13))))
    (if front (ensure-battle :kenpachi :barro) (ensure-battle :barro :kenpachi))
    (let* ((b (if front *p2* *p1*)) (o (if front *p1* *p2*)) (g (gauges b)))
      (setf *br-keep-owl* owl)
      (force-form b (cond ((<= 15 k 17) :base) ((<= 18 k 19) :jilliel) (owl :shin-kin) (t :jilliel-kin)))
      (place *p1* *p2* (if (<= 15 k 19) 3.0 4.0))
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
        (18 (start-move b (find-move :br-e-l1))) (19 (start-move b (find-move :br-e-k1))))
      (setf *br-art-hold* *br-art-hold-next* *br-art-hold-next* -1))))

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
82380+k his special set to k, 0-8 (BR-ART-AMMO: the spend looks); 82398 the consing probe."
  (let ((n (- c 82100)))
    (cond ((< n 100) (br-art-scene n))
          ((< n 199) (setf *br-art-hold-next* (- n 100)))
          ((= n 199) (setf *br-art-hold* -1 *br-art-hold-next* -1 *hitstop* 0))
          ((< n 219) (br-art-cine (* 10 (- n 200))))
          ((<= 280 n 288) (br-art-ammo (- n 280)))
          ((= n 298) (br-cons-probe))
          (t (log-msg "duel barro: no debug command ~d" c)))))

(defun br-cons-probe ()
  "82398: bytes consed by 10 draws of P1 Lille II's :draw hook (BR-DRAW, LILLE-DRAW's lookups included), of the spends'
note and looks (%BR-SPEND-NOTE / -LOOK: the pip glint's model lookup aside), of his volley look
at its clock 4 and of a string beat's lines (when a string runs), and of 裁き・極's look (while it runs), and of his HUD row
(a \"barro consing\" line)."
  (let* ((e *p1*) (f (fighter e)) (side (fighter-side f)) (jm (model-joints (model e)))
         (mv (and (eq (fighter-state f) :move) (fighter-move f))))
    (macrolet ((per (form) `(let ((c0 (cons-bytes))) (dotimes (i 10) ,form) (- (cons-bytes) c0))))
      (log-msg "barro consing (10 draws, B): form ~a clock ~d draw ~d (Lille's ~d) spends ~d recall ~d beat (lines drive beat) ~a kiwami ~d"
               (fighter-form f) (br-hold-clock f)
               (per (br-draw e 0.016f0)) (per (lille-draw e 0.016f0))
               (per (progn (%br-spend-note f side (br-ammo-look e) 2) (%br-spend-look e side))) (per (%br-recall-look e jm side 4))
               (if (and mv (member (mv-name mv) '(:br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4)))
                   (list (per (%br-beat-look e f jm side mv)) (per (br-rc-drive f mv)) (per (br-rc-beat (mv-name mv) (fighter-sf f))))
                   -1)
               (if (and mv (eq (mv-name mv) :br-rc4)) (per (%br-kiwami-look f jm side)) -1)))))

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

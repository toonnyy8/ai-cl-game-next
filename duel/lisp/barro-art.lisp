;;;; barro-art.lisp — LILLE BARRO II's own looks (docs/duel/DUEL_LILLE_V2.md §7, §12, §17, §22; version 3: DUEL_LILLE_V3.md).
;;;; His art is Lille's, shared by reference (lille-art.lisp: the bodies, Diagramm, every :lb-* clip, LILLE-DRAW's wings /
;;;; halos / legs, LB-LOOK's lines and beams); this file holds only what is his: the clips Lille never had (the volley
;;;; :br-recall and its strings, the turn, the owl's twins, the stance's swing L1), the draw hook BR-DRAW (his wing count to
;;;; Lille's lit wings, Lille's, then the base stance's aim line, the spends' looks and the volley's) and the special
;;;; resource's HUD row.
;;;; Everything here is cosmetic: the sim never reads it. Loaded after lille-art.lisp (its macros and props) and before
;;;; barro.lisp (whose state and knobs these functions read at draw time).
(in-package :duel)

(declaim (special *br-at* *br-keep-owl* *br-dash-moves* *br-w-l-levels*))   ; (*BR-AT*, *BR-DASH-MOVES* below; *BR-KEEP-OWL*,
                                                                              ;  *BR-W-L-LEVELS* barro.lisp's, loaded after)

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
;;; - the J route (S 8, A 2, R 14 / 14 / 16): since R9 (DUEL_LILLE_V3 §14) the awakened forms' are the whips (:br-e-jf* /
;;;   :br-oe-jf*, after the openers below);
;;; - the K route 重砲 (S 10, A 2, R 16 / 16 / 20): planted and heavy, both at once every beat (drawn as balls of light
;;;   since R8).
;;; JILLIEL EN fires from the front wings, the owl EN from its claws (the base form's follow-ups are above, solved on
;;; Diagramm's muzzle: JL1 the whip, JL2 the spin, JL3 the hop back; KL1 the stamp, KL2 the kneel, KL3 the finisher from
;;; the knee). The root's side / back offsets are the clip's only: the sim does not move him.
;; JILLIEL EN: 重砲 both wings at once every beat, planted: swept up from low, slammed down from high, the NIJUSHI-KO ring
;; held and its recoil
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
;;; folded-wing blow, K3 the cannon. R9 (§14, the user 2026-10-11: 「架式 J 的蓄力斬合併到架式 K 連打中」, 「原本架式 L 的轉圈
;;; 改到架式 J，而原本架式 J > L 的動作模組改成原本架式 J 的鞭打」, 「架式 L 的動作模組改成八翼往後收、身體前傾高速衝向對手」,
;;; 「拿掉砲擊」): J1 / J2 / J3 the top turns, the J route's L L the whips, K1 the charged slash (R to L), K2 the backhand (his
;;; left to his lower right), K3 the turn round and the overhead split (the blast gone), L1 / L2 / L3 the dash through him
;;; (the sim slides him) and the cuts on him after (%BR-CUTS-LOOK); the swings' in-betweens through their arcs. R10 (§15,
;;; the user 2026-10-11: 「J 陀螺完之後還是射擊不是長鞭呀」, 「K3 會順著劈砍的力道讓身體往右側傾斜並旋轉…」, 「L 衝刺改成只能衝
;;; 一次不能連接，但可以三階段續力…」): the J route's L L whips lash out to him (%BR-WHIP-REACH, no line), K3 tilted to its right
;;; (the pelvis's roll) through one full turn of the root's yaw, the wing straight up at its end, then the split straight down;
;;; L one dash out of a held charge pose (:br-en-lc, the move's :clip; the dash its :clip-2), the levels' tells, streaks and
;;; cuts by level (%BR-CHARGE-LOOK, %BR-DASH-LOOK).
;;; Every key starts from a named pose, so a key's overrides never leak into the next. Tips in m (right, up, ahead) are the
;;; host's FK; the arm angles at the hit poses were solved to them.

;; JILLIEL EN's poses (base :lb-w-stance: the front wings' tips are the rig's hands)
;; 陀螺 (J since R9, L before): the spin is the pelvis's twist (inside the root's forward tilt: the axis leans at him and stays leaning while
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
;; 長鞭 (the J route's L L since R9, J before): the front wings stretched long (*BR-W-STRETCH*), cracked from high: the striking wing thrown down at him, the
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
;; 大砍刀 (K1 K2 K3 since R9: the charged slash, the backhand, the turn and the split; R6, DUEL_LILLE_V3 §11: 「大砍刀的動作要更緩慢沉重、扭轉身體、砍刀後拉，每次只用一隻光翼
;; 揮砍，揮砍前光翼隨身體的距離伸長放大」): ONE wing a chop, the body wound away from him, the wing pulled back behind the
;; head and grown (*BR-W-STRETCH*, *LB-STRETCH-GROW*: longer and wider with the pull), held, then swung down through his
;; line with the body unwinding after it; the other wing held back
;; R9 (§14): K2's backhand from his left down to his lower right; L's dash (crouched, the wings swept back, leaning low)
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
(defpose :br-en-back-up-r (:base :lb-w-stance)     ; K2 (R9): the blade carried up over the left shoulder, wound left
  (:root :f 0.1 :u 0.06 :yaw 16 :pitch -4) (:pelvis :twist 14) (:spine :flex -6) (:chest :twist 36) (:head :twist -20)
  (:arm-r :flex 133.8 :side 34.2) (:elbow-r :flex 10) (:arm-l :flex -30 :side 36) (:elbow-l :flex 20)
  (:thigh-l :flex -10) (:thigh-r :flex 14))
(defpose :br-en-backhand-r (:base :lb-w-stance)    ; ... swung down from his left to his right through his line
  (:root :f 0.2 :u -0.06 :yaw -6 :pitch 12) (:pelvis :twist -8) (:spine :flex 18) (:chest :twist -14) (:head :flex 6)
  (:arm-r :flex 133.2 :side 57.5) (:elbow-r :flex 0) (:arm-l :flex -30 :side 36) (:elbow-l :flex 20)
  (:thigh-r :flex 26) (:thigh-l :flex -18))
(defpose :br-en-backhand-low-r (:base :lb-w-stance)   ; ... and on down to his lower right, the body following
  (:root :f 0.26 :u -0.14 :yaw -16 :pitch 18) (:pelvis :twist -16) (:spine :flex 26) (:chest :twist -34) (:head :flex 10)
  (:arm-r :flex 35 :side 55) (:elbow-r :flex 0) (:arm-l :flex -30 :side 36) (:elbow-l :flex 20)
  (:thigh-r :flex 30) (:thigh-l :flex -22))
(defpose :br-en-dash-load (:base :lb-w-stance)     ; L (R9): crouched to spring, the wings folding back
  (:root :u -0.1 :pitch 18) (:spine :flex 14) (:head :flex -10)
  (:arm-r :flex -40 :side 34) (:elbow-r :flex 40) (:arm-l :flex -40 :side 34) (:elbow-l :flex 40))
(defpose :br-en-dash (:base :lb-w-stance)          ; ... the dash: leaning far forward, low, the wings swept straight back
  (:root :u -0.16 :pitch 40) (:spine :flex 16) (:head :flex -30)
  (:arm-r :flex -72 :side 16) (:elbow-r :flex 6) (:arm-l :flex -72 :side 16) (:elbow-l :flex 6))
(defpose :br-en-dash-stop (:base :lb-w-stance)     ; ... braking past him, rising, the wings opening again
  (:root :f -0.1 :u 0.02 :pitch -10) (:spine :flex -6) (:head :flex 4)
  (:arm-r :flex -20 :side 60) (:elbow-r :flex 20) (:arm-l :flex -20 :side 60) (:elbow-l :flex 20))
(defpose :br-en-charge (:base :lb-w-stance)       ; L 續力 (R10, DUEL_LILLE_V3 §15): lower than the dash's load, leaning in, the wings folded back tight
  (:root :u -0.17 :pitch 26) (:spine :flex 16) (:head :flex -18)
  (:arm-r :flex -58 :side 22) (:elbow-r :flex 28) (:arm-l :flex -58 :side 22) (:elbow-l :flex 28))
(defpose :br-en-roll-r (:base :lb-w-stance)       ; K3 (R10, §15): carried round by K2's chop, the body tilted to its right (the pelvis's roll), the wing flung out
  (:root :r 0.1 :u 0.06) (:pelvis :side -22) (:spine :flex 4 :side -8) (:chest :twist -10) (:head :side 14)
  (:arm-r :flex 70 :side 80) (:elbow-r :flex 0) (:arm-l :flex -20 :side 50) (:elbow-l :flex 30))
(defpose :br-en-split-top (:base :lb-w-stance)    ; ... the turn's end: the wing straight up over him, rising, arched back
  (:root :u 0.18 :pitch -12) (:spine :flex -10) (:head :flex -6)
  (:arm-r :flex 186 :side 4) (:elbow-r :flex 0) (:arm-l :flex -24 :side 40) (:elbow-l :flex 24))
(defpose :br-en-split (:base :lb-w-stance)        ; ... split straight down his line with all his weight, a step in
  (:root :f 0.15 :u -0.1 :pitch 16) (:spine :flex 22) (:head :flex 8)
  (:arm-r :flex 144 :side 9) (:elbow-r :flex 0) (:arm-l :flex -30 :side 36) (:elbow-l :flex 20))
(defpose :br-en-split-low (:base :lb-w-stance)    ; ... and on down to the floor before him, bowed over it
  (:root :f 0.24 :u -0.2 :pitch 24) (:spine :flex 30) (:head :flex 12)
  (:arm-r :flex 30 :side -6) (:elbow-r :flex 0) (:arm-l :flex -30 :side 36) (:elbow-l :flex 20))
;; JILLIEL EN's nine openers (the moves :br-e-l1 .. -k3; R7, DUEL_LILLE_V3 §12: one strike a press, S A R from *BR-S-SEGS* /
;; *BR-W-SEGS*; L authored at S 8 and played at 2 / 3). L: the spin (the pelvis's twist, linear :snap keys) carried across the
;; links: each segment's first key is the pose its predecessor holds at its S + A (clip f9.33 at 2 / 3: twist 138 =
;; -222 + 360), one turn to the right wing on his line at S (+90), then wound down to 360, unwound to 0 between two keys
;; 0.0001 f apart (never sampled: the samples fall on thirds of a frame). J1 / J2 one whip each (R, L), J3 / K1 the one-wing
;; great blade (R6), K2 one folded-wing blow, K3 零距離砲擊. Each later segment starts from its predecessor's S + A pose.
(defstrike :br-en-lc (8 2 30 :base :lb-w-stance)   ; L 續力 (R10, DUEL_LILLE_V3 §15: 「可以三階段續力」): while L is held (the move's :clip; up to 60 f = clip f40 at 2 / 3), the eight wings folding back tight, crouched low, leaning in, breathing (the levels' tells: barro-art.lisp's draw hook)
  (0) (3 :br-en-dash-load) (6 :br-en-charge) (14 :br-en-charge (:root :u -0.19 :pitch 28)) (22 :br-en-charge)
  (30 :br-en-charge (:root :u -0.19 :pitch 28)) (40 :br-en-charge))
(defstrike :br-en-l1 (8 7 9 :base :lb-w-stance)   ; L1 疾走 (R9; R10: the move's :clip-2, out of the charge pose): coiled lower, the dash through him from f8 (the sim slides him), braking past him
  (0 :br-en-charge) (4 :br-en-charge (:root :u -0.22 :pitch 32)) (7 :br-en-dash-load (:root :u -0.16 :pitch 28))
  (:s :snap :br-en-dash) (13 :br-en-dash (:root :pitch 36)) (16 :br-en-dash-stop) (20 :br-en-dash-stop (:root :f 0 :u 0))
  (:end :lb-w-stance))
(defstrike :br-en-j1 (8 2 12 :base :lb-w-stance)   ; J1 陀螺 (R9: the old L's spin): wound up, one turn, the right wing across him f8
  (0) (3 :br-en-wind)
  (:s :snap :br-en-top (:pelvis :twist 90)) (:a :snap :br-en-top (:pelvis :twist 162))
  (13 :snap :br-en-top (:root :pitch 10) (:pelvis :twist 250)) (16 :snap :br-en-top (:root :pitch 6 :u 0.04) (:pelvis :twist 320))
  (19 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 352) (:arm-r :side 84) (:arm-l :side 84))
  (21 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 360) (:arm-r :side 82) (:arm-l :side 82))
  (21.0001 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 0) (:arm-r :side 82) (:arm-l :side 82))
  (:end :lb-w-stance))
(defstrike :br-en-j2 (8 2 12 :base :lb-w-stance)   ; J2 陀螺: leaning lower, one more turn (from J1's S + A twist 162 = -198), the right wing across him f8
  (0 :br-en-top (:pelvis :twist -198))
  (:s :snap :br-en-top-low (:pelvis :twist 90)) (:a :snap :br-en-top-low (:pelvis :twist 162))
  (13 :snap :br-en-top-low (:pelvis :twist 250)) (16 :snap :br-en-top (:root :pitch 6 :u 0.04) (:pelvis :twist 320))
  (19 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 352) (:arm-r :side 84) (:arm-l :side 84))
  (21 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 360) (:arm-r :side 82) (:arm-l :side 82))
  (21.0001 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 0) (:arm-r :side 82) (:arm-l :side 82))
  (:end :lb-w-stance))
(defstrike :br-en-j3 (8 2 14 :base :lb-w-stance)   ; J3 陀螺: spun up and rising, the right wing across him f8, wound down
  (0 :br-en-top-low (:pelvis :twist -198))
  (:s :snap :br-en-top-high (:root :u 0.16) (:pelvis :twist 90)) (:a :snap :br-en-top-high (:root :u 0.2) (:pelvis :twist 162))
  (14 :snap :br-en-top-high (:root :u 0.24) (:pelvis :twist 270)) (18 :snap :br-en-top (:root :u 0.14) (:pelvis :twist 330))
  (20 :snap :br-en-top (:root :pitch 6 :u 0.04) (:pelvis :twist 355) (:arm-r :side 84) (:arm-l :side 84))
  (21 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 360) (:arm-r :side 82) (:arm-l :side 82))
  (21.0001 :snap :br-en-top (:root :pitch 4 :u 0.02) (:pelvis :twist 0) (:arm-r :side 82) (:arm-l :side 82))
  (:end :lb-w-stance))
(defstrike :br-en-k1 (16 2 18 :base :lb-w-stance)   ; K1 Charged Slash (R8; R9 the in-betweens): hauled over the shoulder, stretched tall, the squat f10, sprung f11, the swing through the arc f12-f15, slammed R to L f16, held
  (0) (4 :br-en-heave-r) (8 :br-en-heave-r (:root :f -0.2 :u 0.12 :pitch -10) (:chest :twist -54) (:arm-r :flex 226))
  (10 :br-en-heave-r (:root :f -0.18 :u -0.18 :pitch -4) (:spine :flex 10) (:chest :twist -56) (:arm-r :flex 230))
  (11 :br-en-heave-r (:root :f -0.12 :u 0.12 :pitch -12) (:chest :twist -52) (:arm-r :flex 232))
  (12 :snap :br-en-heave-r (:root :f -0.08 :u 0.12 :pitch -10) (:pelvis :twist -12) (:chest :twist -44) (:arm-r :flex 228 :side 20))
  (13 :snap :br-en-heave-r (:root :f -0.02 :u 0.08 :pitch -4) (:pelvis :twist -6) (:spine :flex -2) (:chest :twist -28)
   (:arm-r :flex 214 :side 10))
  (14 :snap :br-en-cleave-r (:root :f 0.04 :u 0.02 :yaw 2 :pitch 2) (:pelvis :twist 0) (:spine :flex 6) (:chest :twist -8)
   (:arm-r :flex 192 :side -14))
  (15 :snap :br-en-cleave-r (:root :f 0.1 :u -0.04 :yaw 8 :pitch 8) (:pelvis :twist 6) (:spine :flex 13) (:chest :twist 10)
   (:arm-r :flex 168 :side -34))
  (:s :snap :br-en-cleave-r)
  (17 :snap :br-en-cleave-low-r (:root :u -0.16) (:arm-r :flex 96 :side -30))
  (:a :br-en-cleave-low-r (:root :u -0.26) (:arm-r :flex 40 :side -6)) (22 :br-en-cleave-low-r (:root :u -0.26) (:arm-r :flex 38 :side -6))
  (30 :br-en-cleave-low-r (:root :f 0.06 :u -0.04 :yaw 4 :pitch 6) (:pelvis :twist 2) (:spine :flex 8) (:chest :twist 6)
   (:arm-r :flex 40 :side 30))
  (:end :lb-w-stance))
(defstrike :br-en-k2 (12 2 18 :base :lb-w-stance)   ; K2 左往右下揮擊 (R9): carried on from K1, the blade hauled up over his left shoulder, swung down across him from his left to his lower right f12
  (0 :br-en-cleave-low-r (:root :u -0.26) (:arm-r :flex 40 :side -6))
  (4 :br-en-back-up-r (:root :u -0.02)) (7 :br-en-back-up-r (:root :u 0.08 :pitch -6) (:chest :twist 42) (:arm-r :flex 138))
  (9 :snap :br-en-back-up-r (:root :f 0.14 :u 0.04 :yaw 10 :pitch 0) (:pelvis :twist 8) (:chest :twist 26) (:arm-r :flex 136 :side 40))
  (10 :snap :br-en-backhand-r (:root :f 0.16 :u 0 :yaw 4 :pitch 4) (:pelvis :twist 2) (:spine :flex 8) (:chest :twist 10)
   (:arm-r :flex 135 :side 46))
  (11 :snap :br-en-backhand-r (:root :f 0.18 :u -0.03 :yaw -1 :pitch 8) (:pelvis :twist -3) (:spine :flex 13) (:chest :twist -2)
   (:arm-r :flex 134 :side 52))
  (:s :snap :br-en-backhand-r)
  (13 :snap :br-en-backhand-low-r (:root :u -0.08) (:arm-r :flex 90 :side 56))
  (:a :br-en-backhand-low-r) (19 :br-en-backhand-low-r (:root :u -0.18))
  (26 :br-en-backhand-low-r (:root :f 0.08 :u -0.04 :yaw -4 :pitch 6) (:pelvis :twist -2) (:spine :flex 8) (:chest :twist -8)
   (:arm-r :flex 40 :side 40))
  (:end :lb-w-stance))
(defstrike :br-en-k3 (18 2 22 :base :lb-w-stance)   ; K3 (R10, DUEL_LILLE_V3 §15: 「K3 會順著劈砍的力道讓身體往右側傾斜並旋轉、帶著旋轉的力量將右翼帶到正上方後全力下劈」): K2's chop carries him on: the body tilts to its right (the pelvis's roll) and turns one full turn to the right (the root's yaw, f1-f13, linear), the turn bringing the wing up to straight overhead (f13), rising a beat, then the split straight down onto him with all his weight f18
  (0 :br-en-backhand-low-r)
  (2 :snap :br-en-roll-r (:root :yaw -60 :r 0.05 :u 0.02) (:pelvis :side -10) (:spine :side -4) (:arm-r :flex 50 :side 72))
  (5 :snap :br-en-roll-r (:root :yaw -142))
  (8 :snap :br-en-roll-r (:root :yaw -226 :u 0.1) (:pelvis :side -24) (:arm-r :flex 112 :side 58))
  (11 :snap :br-en-roll-r (:root :yaw -310 :r 0.06 :u 0.14) (:pelvis :side -12) (:spine :side -4) (:arm-r :flex 160 :side 24))
  (13 :snap :br-en-split-top (:root :yaw -358 :u 0.16 :pitch -8) (:pelvis :side -2) (:arm-r :flex 182 :side 6))
  (13.0001 :snap :br-en-split-top (:root :yaw 2 :u 0.16 :pitch -8) (:pelvis :side -2) (:arm-r :flex 182 :side 6))
  (15 :br-en-split-top) (16 :snap :br-en-split-top (:root :u 0.14 :pitch -6) (:arm-r :flex 184))
  (17 :snap :br-en-split (:root :f 0.06 :u 0.04 :pitch 4) (:spine :flex 8) (:arm-r :flex 168 :side 6))
  (:s :snap :br-en-split)
  (19 :snap :br-en-split-low (:root :u -0.12) (:arm-r :flex 95))
  (:a :br-en-split-low) (27 :br-en-split-low (:arm-r :flex 28))
  (36 :br-en-split-low (:root :f 0.06 :u -0.04 :pitch 6) (:spine :flex 8) (:arm-r :flex 40 :side 30))
  (:end :lb-w-stance))
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
(defpose :br-oen-back-up-r (:base :lb-oe-stance)
  (:root :f 0.1 :u 0.08 :yaw 16 :pitch -4) (:pelvis :twist 14) (:spine :flex -6) (:chest :twist 36) (:neck :flex -8)
  (:head :twist -20) (:arm-r :flex 135.8 :side 34) (:elbow-r :flex 10) (:hand-r :flex -30) (:arm-l :flex -30 :side 36)
  (:elbow-l :flex 20) (:hand-l :flex 10))
(defpose :br-oen-backhand-r (:base :lb-oe-stance)
  (:root :f 0.2 :u -0.06 :yaw -6 :pitch 12) (:pelvis :twist -8) (:spine :flex 20) (:chest :twist -14) (:neck :flex 22)
  (:head :flex 10) (:arm-r :flex 133 :side 61.1) (:elbow-r :flex 0) (:hand-r :flex 30) (:arm-l :flex -30 :side 36)
  (:elbow-l :flex 20) (:hand-l :flex 10))
(defpose :br-oen-backhand-low-r (:base :lb-oe-stance)
  (:root :f 0.26 :u -0.14 :yaw -16 :pitch 18) (:pelvis :twist -16) (:spine :flex 28) (:chest :twist -34) (:neck :flex 30)
  (:head :flex 12) (:arm-r :flex 35 :side 55) (:elbow-r :flex 0) (:hand-r :flex 40) (:arm-l :flex -30 :side 36)
  (:elbow-l :flex 20) (:hand-l :flex 10))
(defpose :br-oen-dash-load (:base :lb-oe-stance)
  (:root :u -0.1 :pitch 18) (:spine :flex 16) (:neck :flex 10) (:head :flex -10)
  (:arm-r :flex -40 :side 34) (:elbow-r :flex 40) (:hand-r :flex -20) (:arm-l :flex -40 :side 34) (:elbow-l :flex 40)
  (:hand-l :flex -20))
(defpose :br-oen-dash (:base :lb-oe-stance)
  (:root :u -0.16 :pitch 40) (:spine :flex 16) (:neck :flex -10) (:head :flex -24)
  (:arm-r :flex -72 :side 16) (:elbow-r :flex 6) (:hand-r :flex -30) (:arm-l :flex -72 :side 16) (:elbow-l :flex 6)
  (:hand-l :flex -30))
(defpose :br-oen-dash-stop (:base :lb-oe-stance)
  (:root :f -0.1 :u 0.04 :pitch -10) (:spine :flex -6) (:neck :flex -6) (:head :flex 4)
  (:arm-r :flex -20 :side 60) (:elbow-r :flex 20) (:hand-r :flex -10) (:arm-l :flex -20 :side 60) (:elbow-l :flex 20)
  (:hand-l :flex -10))
(defpose :br-oen-charge (:base :lb-oe-stance)      ; L 續力 (R10, §15): the owl's, the arms folded back tight
  (:root :u -0.17 :pitch 26) (:spine :flex 18) (:neck :flex 12) (:head :flex -16)
  (:arm-r :flex -58 :side 22) (:elbow-r :flex 28) (:hand-r :flex -26) (:arm-l :flex -58 :side 22) (:elbow-l :flex 28)
  (:hand-l :flex -26) (:thigh-r :flex 26 :side 8) (:thigh-l :flex 26 :side 8))
(defpose :br-oen-roll-r (:base :lb-oe-stance)      ; K3 (R10, §15): the owl's tilted turn
  (:root :r 0.1 :u 0.06) (:pelvis :side -22) (:spine :flex 4 :side -8) (:chest :twist -10) (:neck :side 6) (:head :side 10)
  (:arm-r :flex 70 :side 80) (:elbow-r :flex 0) (:hand-r :flex 10) (:arm-l :flex -20 :side 50) (:elbow-l :flex 30)
  (:hand-l :flex 10))
(defpose :br-oen-split-top (:base :lb-oe-stance)
  (:root :u 0.18 :pitch -12) (:spine :flex -10) (:neck :flex -10) (:head :flex -6)
  (:arm-r :flex 186 :side 4) (:elbow-r :flex 0) (:hand-r :flex -20) (:arm-l :flex -24 :side 40) (:elbow-l :flex 24)
  (:hand-l :flex 10))
(defpose :br-oen-split (:base :lb-oe-stance)
  (:root :f 0.15 :u -0.1 :pitch 16) (:spine :flex 22) (:neck :flex 24) (:head :flex 10)
  (:arm-r :flex 127.5 :side 8.5) (:elbow-r :flex 0) (:hand-r :flex 30) (:arm-l :flex -30 :side 36) (:elbow-l :flex 20)
  (:hand-l :flex 10))
(defpose :br-oen-split-low (:base :lb-oe-stance)
  (:root :f 0.24 :u -0.2 :pitch 24) (:spine :flex 30) (:neck :flex 34) (:head :flex 14)
  (:arm-r :flex 30 :side -6) (:elbow-r :flex 0) (:hand-r :flex 40) (:arm-l :flex -30 :side 36) (:elbow-l :flex 20)
  (:hand-l :flex 10))
;; the owl EN's nine openers (the moves :br-oe-l1 .. -k3; its recovery one frame shorter: R - 1, *BR-OWL-ADV*): JILLIEL's,
;; on its claws (R7, §12: one strike a press)
(defstrike :br-oen-lc (8 2 30 :base :lb-oe-stance)   ; L 續力 (R10, DUEL_LILLE_V3 §15: 「可以三階段續力」): while L is held (the move's :clip; up to 60 f = clip f40 at 2 / 3), the arms folding back tight, crouched low, leaning in, breathing (the levels' tells: barro-art.lisp's draw hook)
  (0) (3 :br-oen-dash-load) (6 :br-oen-charge) (14 :br-oen-charge (:root :u -0.19 :pitch 28)) (22 :br-oen-charge)
  (30 :br-oen-charge (:root :u -0.19 :pitch 28)) (40 :br-oen-charge))
(defstrike :br-oen-l1 (8 7 8 :base :lb-oe-stance)   ; L1 疾走 (R9; R10: the move's :clip-2, out of the charge pose): coiled lower, the dash through him from f8 (the sim slides him), braking past him
  (0 :br-oen-charge) (4 :br-oen-charge (:root :u -0.22 :pitch 32)) (7 :br-oen-dash-load (:root :u -0.16 :pitch 28))
  (:s :snap :br-oen-dash) (13 :br-oen-dash (:root :pitch 36)) (16 :br-oen-dash-stop) (20 :br-oen-dash-stop (:root :f 0 :u 0))
  (:end :lb-oe-stance))
(defstrike :br-oen-j1 (8 2 11 :base :lb-oe-stance)   ; J1 陀螺 (R9: the old L's spin): wound up, one turn, the right claw across him f8
  (0) (3 :br-oen-wind)
  (:s :snap :br-oen-top (:pelvis :twist 90)) (:a :snap :br-oen-top (:pelvis :twist 162))
  (13 :snap :br-oen-top (:root :pitch 10) (:pelvis :twist 250)) (16 :snap :br-oen-top (:root :pitch 6 :u 0.04) (:pelvis :twist 320))
  (18.5 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 352) (:arm-r :side 84) (:arm-l :side 84))
  (20 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 360) (:arm-r :side 82) (:arm-l :side 82))
  (20.0001 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 0) (:arm-r :side 82) (:arm-l :side 82))
  (:end :lb-oe-stance))
(defstrike :br-oen-j2 (8 2 11 :base :lb-oe-stance)   ; J2 陀螺: leaning lower, one more turn (from J1's S + A twist 162 = -198), the right claw across him f8
  (0 :br-oen-top (:pelvis :twist -198))
  (:s :snap :br-oen-top-low (:pelvis :twist 90)) (:a :snap :br-oen-top-low (:pelvis :twist 162))
  (13 :snap :br-oen-top-low (:pelvis :twist 250)) (16 :snap :br-oen-top (:root :pitch 6 :u 0.04) (:pelvis :twist 320))
  (18.5 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 352) (:arm-r :side 84) (:arm-l :side 84))
  (20 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 360) (:arm-r :side 82) (:arm-l :side 82))
  (20.0001 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 0) (:arm-r :side 82) (:arm-l :side 82))
  (:end :lb-oe-stance))
(defstrike :br-oen-j3 (8 2 13 :base :lb-oe-stance)   ; J3 陀螺: spun up and rising, the right claw across him f8, wound down
  (0 :br-oen-top-low (:pelvis :twist -198))
  (:s :snap :br-oen-top-high (:root :u 0.16) (:pelvis :twist 90)) (:a :snap :br-oen-top-high (:root :u 0.2) (:pelvis :twist 162))
  (14 :snap :br-oen-top-high (:root :u 0.24) (:pelvis :twist 270)) (18 :snap :br-oen-top (:root :u 0.14) (:pelvis :twist 330))
  (20 :snap :br-oen-top (:root :pitch 6 :u 0.04) (:pelvis :twist 355) (:arm-r :side 84) (:arm-l :side 84))
  (21 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 360) (:arm-r :side 82) (:arm-l :side 82))
  (21.0001 :snap :br-oen-top (:root :pitch 4 :u 0.02) (:pelvis :twist 0) (:arm-r :side 82) (:arm-l :side 82))
  (:end :lb-oe-stance))
(defstrike :br-oen-k1 (16 2 17 :base :lb-oe-stance)   ; K1 Charged Slash (R8; R9 the in-betweens): hauled over the shoulder, stretched tall, the squat f10, sprung f11, the swing through the arc f12-f15, slammed R to L f16, held
  (0) (4 :br-oen-heave-r) (8 :br-oen-heave-r (:root :f -0.2 :u 0.12 :pitch -10) (:chest :twist -54) (:arm-r :flex 226))
  (10 :br-oen-heave-r (:root :f -0.18 :u -0.18 :pitch -4) (:spine :flex 10) (:chest :twist -56) (:arm-r :flex 230))
  (11 :br-oen-heave-r (:root :f -0.12 :u 0.12 :pitch -12) (:chest :twist -52) (:arm-r :flex 232))
  (12 :snap :br-oen-heave-r (:root :f -0.08 :u 0.12 :pitch -10) (:pelvis :twist -12) (:chest :twist -44) (:arm-r :flex 228 :side 20))
  (13 :snap :br-oen-heave-r (:root :f -0.02 :u 0.08 :pitch -4) (:pelvis :twist -6) (:spine :flex -2) (:chest :twist -28)
   (:arm-r :flex 214 :side 10))
  (14 :snap :br-oen-cleave-r (:root :f 0.04 :u 0.02 :yaw 2 :pitch 2) (:pelvis :twist 0) (:spine :flex 6) (:chest :twist -8)
   (:arm-r :flex 192 :side -14))
  (15 :snap :br-oen-cleave-r (:root :f 0.1 :u -0.04 :yaw 8 :pitch 8) (:pelvis :twist 6) (:spine :flex 13) (:chest :twist 10)
   (:arm-r :flex 168 :side -34))
  (:s :snap :br-oen-cleave-r)
  (17 :snap :br-oen-cleave-low-r (:root :u -0.16) (:arm-r :flex 96 :side -30))
  (:a :br-oen-cleave-low-r (:root :u -0.26) (:arm-r :flex 40 :side -6)) (22 :br-oen-cleave-low-r (:root :u -0.26) (:arm-r :flex 38 :side -6))
  (30 :br-oen-cleave-low-r (:root :f 0.06 :u -0.04 :yaw 4 :pitch 6) (:pelvis :twist 2) (:spine :flex 8) (:chest :twist 6)
   (:arm-r :flex 40 :side 30))
  (:end :lb-oe-stance))
(defstrike :br-oen-k2 (12 2 17 :base :lb-oe-stance)   ; K2 左往右下揮擊 (R9): carried on from K1, the blade hauled up over his left shoulder, swung down across him from his left to his lower right f12
  (0 :br-oen-cleave-low-r (:root :u -0.26) (:arm-r :flex 40 :side -6))
  (4 :br-oen-back-up-r (:root :u -0.02)) (7 :br-oen-back-up-r (:root :u 0.08 :pitch -6) (:chest :twist 42) (:arm-r :flex 138))
  (9 :snap :br-oen-back-up-r (:root :f 0.14 :u 0.04 :yaw 10 :pitch 0) (:pelvis :twist 8) (:chest :twist 26) (:arm-r :flex 136 :side 40))
  (10 :snap :br-oen-backhand-r (:root :f 0.16 :u 0 :yaw 4 :pitch 4) (:pelvis :twist 2) (:spine :flex 8) (:chest :twist 10)
   (:arm-r :flex 135 :side 46))
  (11 :snap :br-oen-backhand-r (:root :f 0.18 :u -0.03 :yaw -1 :pitch 8) (:pelvis :twist -3) (:spine :flex 13) (:chest :twist -2)
   (:arm-r :flex 134 :side 52))
  (:s :snap :br-oen-backhand-r)
  (13 :snap :br-oen-backhand-low-r (:root :u -0.08) (:arm-r :flex 90 :side 56))
  (:a :br-oen-backhand-low-r) (19 :br-oen-backhand-low-r (:root :u -0.18))
  (26 :br-oen-backhand-low-r (:root :f 0.08 :u -0.04 :yaw -4 :pitch 6) (:pelvis :twist -2) (:spine :flex 8) (:chest :twist -8)
   (:arm-r :flex 40 :side 40))
  (:end :lb-oe-stance))
(defstrike :br-oen-k3 (18 2 21 :base :lb-oe-stance)   ; K3 (R10, DUEL_LILLE_V3 §15: 「K3 會順著劈砍的力道讓身體往右側傾斜並旋轉、帶著旋轉的力量將右翼帶到正上方後全力下劈」): K2's chop carries him on: the body tilts to its right (the pelvis's roll) and turns one full turn to the right (the root's yaw, f1-f13, linear), the turn bringing the claw up to straight overhead (f13), rising a beat, then the split straight down onto him with all his weight f18
  (0 :br-oen-backhand-low-r)
  (2 :snap :br-oen-roll-r (:root :yaw -60 :r 0.05 :u 0.02) (:pelvis :side -10) (:spine :side -4) (:arm-r :flex 50 :side 72))
  (5 :snap :br-oen-roll-r (:root :yaw -142))
  (8 :snap :br-oen-roll-r (:root :yaw -226 :u 0.1) (:pelvis :side -24) (:arm-r :flex 112 :side 58))
  (11 :snap :br-oen-roll-r (:root :yaw -310 :r 0.06 :u 0.14) (:pelvis :side -12) (:spine :side -4) (:arm-r :flex 160 :side 24))
  (13 :snap :br-oen-split-top (:root :yaw -358 :u 0.16 :pitch -8) (:pelvis :side -2) (:arm-r :flex 182 :side 6))
  (13.0001 :snap :br-oen-split-top (:root :yaw 2 :u 0.16 :pitch -8) (:pelvis :side -2) (:arm-r :flex 182 :side 6))
  (15 :br-oen-split-top) (16 :snap :br-oen-split-top (:root :u 0.14 :pitch -6) (:arm-r :flex 184))
  (17 :snap :br-oen-split (:root :f 0.06 :u 0.04 :pitch 4) (:spine :flex 8) (:arm-r :flex 168 :side 6))
  (:s :snap :br-oen-split)
  (19 :snap :br-oen-split-low (:root :u -0.12) (:arm-r :flex 95))
  (:a :br-oen-split-low) (27 :br-oen-split-low (:arm-r :flex 28))
  (36 :br-oen-split-low (:root :f 0.06 :u -0.04 :pitch 6) (:spine :flex 8) (:arm-r :flex 40 :side 30))
  (:end :lb-oe-stance))
;; the J route's L L (R9, DUEL_LILLE_V3 §14: 「原本架式 J > L 的動作模組改成原本架式 J 的鞭打」): the whips, JILLIEL's
;; wings and the owl's gold lashes (the follow-up's hit is its 萬物貫通 line; the tip on his line, the host test)
(defstrike :br-e-jf1 (8 2 14 :base :lb-w-stance)   ; JL1 長鞭 (R9: the old J1 whip): out of the spin, the right whip cracked from high outside down across him f8
  (0 :br-en-top-high (:root :u 0.2) (:pelvis :twist -198)) (2 :snap :br-en-top (:pelvis :twist -60))
  (4 :br-en-cock) (7 :br-en-cock (:root :pitch -6) (:arm-r :flex 160 :side 56))
  (:s :snap :br-en-crack-r) (:a :br-en-crack-r (:arm-r :flex 64 :side -36) (:arm-l :flex 162 :side 56))
  (16 :br-en-crack-r (:root :f 0 :pitch 2) (:arm-r :flex 40 :side 40) (:elbow-r :flex 20) (:arm-l :flex 40 :side 50))
  (:end :lb-w-stance))
(defstrike :br-e-jf2 (8 2 14 :base :lb-w-stance)   ; JL2 長鞭 (the old J2 whip): the left whip cracked the same way across him f8 (the figure-eight)
  (0 :br-en-crack-r (:arm-r :flex 64 :side -36) (:arm-l :flex 162 :side 56))
  (4 :br-en-crack-r (:root :pitch -2) (:arm-r :flex 120 :side 40) (:arm-l :flex 166 :side 56))
  (:s :snap :br-en-crack-l) (:a :br-en-crack-l (:arm-l :flex 64 :side -36) (:arm-r :flex 120 :side 40))
  (16 :br-en-crack-l (:root :f 0 :pitch 2) (:arm-l :flex 40 :side 40) (:elbow-l :flex 20) (:arm-r :flex 40 :side 50))
  (:end :lb-w-stance))
(defstrike :br-e-jf3 (8 2 16 :base :lb-w-stance)   ; JL3 長鞭: the right whip once more, the longest, f8
  (0 :br-en-crack-l (:arm-l :flex 64 :side -36) (:arm-r :flex 120 :side 40))
  (4 :br-en-crack-l (:root :pitch -4) (:arm-l :flex 120 :side 40) (:arm-r :flex 166 :side 56))
  (:s :snap :br-en-crack-r) (:a :br-en-crack-r (:arm-r :flex 64 :side -36) (:arm-l :flex 120 :side 40))
  (18 :br-en-crack-r (:root :f 0 :pitch 2) (:arm-r :flex 40 :side 40) (:elbow-r :flex 20) (:arm-l :flex 40 :side 50))
  (:end :lb-w-stance))
(defstrike :br-oe-jf1 (8 2 13 :base :lb-oe-stance)   ; JL1 長鞭 (R9: the old J1 whip): out of the spin, the right claw.s gold lash cracked from high outside down across him f8
  (0 :br-oen-top-high (:root :u 0.2) (:pelvis :twist -198)) (2 :snap :br-oen-top (:pelvis :twist -60))
  (4 :br-oen-cock) (7 :br-oen-cock (:root :pitch -6) (:arm-r :flex 160 :side 56))
  (:s :snap :br-oen-crack-r) (:a :br-oen-crack-r (:arm-r :flex 64 :side -36) (:arm-l :flex 162 :side 56))
  (16 :br-oen-crack-r (:root :f 0 :pitch 2) (:arm-r :flex 40 :side 40) (:elbow-r :flex 20) (:arm-l :flex 40 :side 50))
  (:end :lb-oe-stance))
(defstrike :br-oe-jf2 (8 2 13 :base :lb-oe-stance)   ; JL2 長鞭 (the old J2 whip): the left claw.s lash cracked the same way across him f8 (the figure-eight)
  (0 :br-oen-crack-r (:arm-r :flex 64 :side -36) (:arm-l :flex 162 :side 56))
  (4 :br-oen-crack-r (:root :pitch -2) (:arm-r :flex 120 :side 40) (:arm-l :flex 166 :side 56))
  (:s :snap :br-oen-crack-l) (:a :br-oen-crack-l (:arm-l :flex 64 :side -36) (:arm-r :flex 120 :side 40))
  (16 :br-oen-crack-l (:root :f 0 :pitch 2) (:arm-l :flex 40 :side 40) (:elbow-l :flex 20) (:arm-r :flex 40 :side 50))
  (:end :lb-oe-stance))
(defstrike :br-oe-jf3 (8 2 15 :base :lb-oe-stance)   ; JL3 長鞭: the right claw.s gold lash once more, the longest, f8
  (0 :br-oen-crack-l (:arm-l :flex 64 :side -36) (:arm-r :flex 120 :side 40))
  (4 :br-oen-crack-l (:root :pitch -4) (:arm-l :flex 120 :side 40) (:arm-r :flex 166 :side 56))
  (:s :snap :br-oen-crack-r) (:a :br-oen-crack-r (:arm-r :flex 64 :side -36) (:arm-l :flex 120 :side 40))
  (18 :br-oen-crack-r (:root :f 0 :pitch 2) (:arm-r :flex 40 :side 40) (:elbow-r :flex 20) (:arm-l :flex 40 :side 50))
  (:end :lb-oe-stance))
;; the stretch (R5 J 長鞭) and the spins (R5 L 陀螺) to Lille's wing looks (lille-art.lisp: %LB-STRETCH!, %LB-WINGS, %LB-LASHES,
;; %LB-DRIVE!; Lille's own clips are in neither)
(defparameter *br-w-stretch*
  '((:br-e-jf1 (0 0 0) (6 1.1 1.0) (8 1.2 1.0) (10 1.1 1.1) (16 0.5 0.4) (24 0 0))   ; (R9, §14: the whips are the J route's L L)
    (:br-e-jf2 (0 1.1 1.1) (8 1.0 1.2) (10 0.8 1.1) (16 0.4 0.5) (24 0 0))
    (:br-e-jf3 (0 0.8 1.1) (4 1.0 0.9) (8 1.3 1.0) (10 1.2 1.0) (18 0.5 0.4) (26 0 0))
    (:br-en-k1 (0 0 0) (4 0.8 0) (8 1.5 0) (10 1.6 0) (11 1.7 0) (13 1.6 0) (15 1.3 0) (16 1.0 0) (17 1.3 0) (22 1.3 0)
               (26 0.5 0) (30 0 0))
    (:br-en-k2 (0 1.2 0) (4 1.3 0) (7 1.6 0) (9 1.5 0) (11 1.2 0) (12 1.0 0) (13 1.3 0) (19 1.2 0) (24 0.5 0) (30 0 0))
    (:br-en-k3 (0 1.0 0) (2 1.1 0) (5 1.3 0) (8 1.5 0) (11 1.7 0) (13 1.8 0) (16 1.8 0) (17 1.5 0) (18 1.15 0) (19 1.4 0)
               (27 1.3 0) (32 0.4 0) (40 0 0))   ; (R10, §15: held long overhead through the turn's end, the split)
    (:br-oe-jf1 (0 0 0) (6 1.25 1.15) (8 1.35 1.15) (10 1.25 1.25) (16 0.5 0.4) (23 0 0))
    (:br-oe-jf2 (0 1.25 1.25) (8 1.15 1.35) (10 0.9 1.25) (16 0.4 0.5) (23 0 0))
    (:br-oe-jf3 (0 0.9 1.25) (4 1.1 1.0) (8 1.45 1.15) (10 1.35 1.15) (18 0.5 0.4) (25 0 0))
    (:br-oen-k1 (0 0 0) (4 0.9 0) (8 1.7 0) (10 1.8 0) (11 1.9 0) (13 1.8 0) (15 1.4 0) (16 1.1 0) (17 1.5 0) (22 1.4 0)
                (26 0.6 0) (30 0 0))
    (:br-oen-k2 (0 1.3 0) (4 1.4 0) (7 1.8 0) (9 1.7 0) (11 1.3 0) (12 1.1 0) (13 1.5 0) (19 1.3 0) (24 0.6 0) (30 0 0))
    (:br-oen-k3 (0 1.1 0) (2 1.2 0) (5 1.4 0) (8 1.6 0) (11 1.8 0) (13 1.9 0) (16 1.9 0) (17 1.6 0) (18 1.2 0) (19 1.5 0)
                (27 1.4 0) (32 0.5 0) (40 0 0)))
  "R5 J 長鞭 (DUEL_LILLE_V3 §10): the whips' stretch by clip, keys (frame right left) in the clip's frames: the metres the
right / left front wing (JILLIEL: its blade on past the hand, along its root -> hand line) or claw's gold lash (the owl: on
from the claw along the forearm) reaches past the rig's hand, linear between keys; grown over the wind-up, the striking
whip the longer, drawn back in over the recovery. R6 大砍刀 (§11): J3's last and K1's two chops swing ONE wing, its stretch
growing with the pull behind him (1.5-1.8 m held), the swing landing with less (0.5-0.8). The host FK test adds it to the
hand: the stretched tip is the strike point (*BR-W-TIPS*).")
(defparameter *br-w-grow* '((:br-en-k1 . 0.5) (:br-oen-k1 . 0.5) (:br-en-k2 . 0.5) (:br-oen-k2 . 0.5) (:br-en-k3 . 0.5)
                              (:br-oen-k3 . 0.5))
  "R6 大砍刀 (DUEL_LILLE_V3 §11: 「揮砍前光翼隨身體的距離伸長放大」): the chopping wing's width gain per metre of stretch, so
the pulled-back blade grows wider as well as longer (x 1.75-1.9 at the held wind-up); the whips stay thin.")
(setf *lb-stretch* (loop for (c . keys) in *br-w-stretch* collect (cons c (coerce (mapcar #'f32 (apply #'append keys)) 'f32vec)))
      *lb-stretch-grow* (loop for (c . g) in *br-w-grow* collect (cons c (f32 g)))
      *lb-trail-cut* nil)                                      ; (R9: K3's blast gone, no cut)
(dolist (c '(:br-en-j1 :br-en-j2 :br-en-j3 :br-oen-j1 :br-oen-j2 :br-oen-j3   ; the spins (J since R9): the table wings turn
             :br-en-lc :br-en-l1 :br-oen-lc :br-oen-l1)) ;  with him; L the dash (R9; R10 its charge): folded back
  (pushnew c *lb-no-conv*))
(dolist (c '(:br-en-lc :br-en-l1 :br-oen-lc :br-oen-l1))   ; R9 (§14): 「八翼往後收」 (R10, §15: held through the charge)
  (pushnew c *lb-sweep-clips*))

;; R8 (DUEL_LILLE_V3 §13, the user 2026-10-11: 「大刀的揮舞動作請對魔物獵人進行調查，身體動作大而誇張，可以進行形變來強化動作
;; 效果」): the great blade's squash and stretch, a look on the posed joints (his kit's :pose hook, BR-DEFORM, right after
;; the body's FK): up x SY and sideways (his right axis) x SX about his feet; his facing axis is never scaled.
(defparameter *br-squash*
  '((:br-en-k1 (0 1 1) (4 1.08 0.95) (8 1.18 0.88) (10 0.84 1.12) (11 1.14 0.9) (13 1.06 0.95) (15 0.95 1.04) (16 0.74 1.3) (21 0.76 1.28) (25 0.94 1.06) (29 1 1))   ; (R9, §14: K is the whole great-sword string)
    (:br-oen-k1 (0 1 1) (4 1.08 0.95) (8 1.18 0.88) (10 0.84 1.12) (11 1.14 0.9) (13 1.06 0.95) (15 0.95 1.04) (16 0.74 1.3) (21 0.76 1.28) (25 0.94 1.06) (29 1 1))
    (:br-en-k2 (0 0.95 1.05) (4 1.04 0.97) (7 1.14 0.9) (9 1.08 0.94) (11 0.96 1.04) (12 0.78 1.25) (17 0.8 1.22) (22 0.96 1.04) (26 1 1))
    (:br-oen-k2 (0 0.95 1.05) (4 1.04 0.97) (7 1.14 0.9) (9 1.08 0.94) (11 0.96 1.04) (12 0.78 1.25) (17 0.8 1.22) (22 0.96 1.04) (26 1 1))
    (:br-en-k3 (0 1 1) (2 0.96 1.04) (5 0.94 1.06) (8 0.96 1.04) (11 1.08 0.94) (13 1.18 0.88) (15 1.22 0.86) (16 1.16 0.9) (17 0.98 1.02) (18 0.72 1.32) (24 0.75 1.3) (30 0.94 1.06) (34 1 1))
    (:br-oen-k3 (0 1 1) (2 0.96 1.04) (5 0.94 1.06) (8 0.96 1.04) (11 1.08 0.94) (13 1.18 0.88) (15 1.22 0.86) (16 1.16 0.9) (17 0.98 1.02) (18 0.72 1.32) (24 0.75 1.3) (30 0.94 1.06) (34 1 1)))
  "R8 (§13): the body's squash and stretch by clip, keys (frame up sideways) in the clip's frames, linear between, held past
the ends: K1 the level-3 Charged Slash (stretched tall while the wing is hauled over the shoulder, the squat tell f10
since R9's in-betweens, sprung up f11, the swing through the arc, squashed wide and low on the slam f16, held a beat); R9
(§14: 「架式 J 的蓄力斬合併到架式 K 連打中」) K2 the backhand (wound up tall, squashed on the hit f12), K3 the turn (stretched
tall as the blade rises over him; R10 §15: a little wide through the tilted turn, tallest held at the top f13-f15, the
split squashed f18). The host FK test scales the tips the same way (the
facing axis untouched: the reach is the unscaled one's).")
(declaim (type list *br-squash-v*))
(defparameter *br-squash-v*
  (loop for (c . keys) in *br-squash* collect (cons c (coerce (mapcar #'f32 (apply #'append keys)) 'f32vec)))
  "*BR-SQUASH* as f32vecs (BR-DEFORM reads them without consing).")
(defmacro %br-charge-depth (f ease)
  "R10 (DUEL_LILLE_V3 §15): how deep F's awakened L charge is coiled, 0..1 (single-float, inline: 0 B): while L is held,
0 at level 1, 0.5 at level 2, 1 at level 3, each level dropped in over 4 frames from its frame held (*BR-W-L-LEVELS*);
after the release the level's (FIGHTER-CHARGE), and with EASE let go over the dash's first 6 frames; 0 for any other move."
  `(let* ((%f ,f) (%mv (and (eq (fighter-state %f) :move) (fighter-move %f))))
     (if (and %mv (member (mv-name %mv) *br-dash-moves*))
         (let* ((%l *br-w-l-levels*) (%a (i->f (the fixnum (first %l)))) (%b (i->f (the fixnum (second %l)))))
           (declare (single-float %a %b))
           (if (eq (fighter-phase %f) :hold)
               (let ((%h (i->f (the fixnum (fighter-hold %f)))))
                 (declare (single-float %h))
                 (+ (* 0.5f0 (%lb-ss (/ (- %h %a) 4f0))) (* 0.5f0 (%lb-ss (/ (- %h %b) 4f0)))))
               (let ((%c (i->f (the fixnum (fighter-charge %f)))))
                 (declare (single-float %c))
                 (* (+ (if (>= %c %a) 0.5f0 0f0) (if (>= %c %b) 0.5f0 0f0))
                    ,(if ease '(- 1f0 (%lb-ss (/ (i->f (the fixnum (fighter-sf %f))) 6f0))) 1f0)))))
         0f0)))
(defun-fast br-deform (e m)
  "His kit's :pose hook (R8, §13; draw.lisp's DRAW-FIGHTER, right after the FK, E's model M, the FK origin in *POSE-AT*):
while his clip is in *BR-SQUASH*, every joint matrix of the posed body is scaled about his feet (the origin), up x SY and
along his right axis x SX (the keys at the clip's frame), so the column, the legs and the front wings / claws (LILLE-DRAW
draws them from these joints) squash and stretch; his facing axis untouched. R10 (§15): the awakened L's charge coils him
lower and wider by its level (%BR-CHARGE-DEPTH: up x 1 - 0.1 d, sideways x 1 + 0.06 d), let go over the dash's load. Any
other clip and move: nothing (bit-identical). Cosmetic. 0 B."
  (let* ((an (model-anim m)) (c (anim-clip an)) (ent (and c (assoc (clip-name c) *br-squash-v*)))
         (dc (%br-charge-depth (fighter e) t)) (sy 1f0) (sx 1f0))
    (declare (single-float dc sy sx))
    (when ent
      (let* ((kv (cdr ent)) (n (floor (length kv) 3)) (fr (* 60f0 (the single-float (anim-time an)))))
        (declare (type f32vec kv) (fixnum n) (single-float fr))
        (cond ((<= fr (aref kv 0)) (setf sy (aref kv 1) sx (aref kv 2)))
              ((>= fr (aref kv (* 3 (1- n)))) (setf sy (aref kv (- (* 3 n) 2)) sx (aref kv (1- (* 3 n)))))
              (t (dotimes (i (1- n))
                   (let* ((o (* 3 i)) (a (aref kv o)) (b (aref kv (+ o 3))))
                     (declare (fixnum o) (single-float a b))
                     (when (and (<= a fr) (< fr b))
                       (let ((u (/ (- fr a) (f-max 1f-5 (- b a)))))
                         (declare (single-float u))
                         (setf sy (+ (aref kv (+ o 1)) (* u (- (aref kv (+ o 4)) (aref kv (+ o 1)))))
                               sx (+ (aref kv (+ o 2)) (* u (- (aref kv (+ o 5)) (aref kv (+ o 2))))))))))))))
    (when (> dc 0f0) (setf sy (* sy (- 1f0 (* 0.1f0 dc))) sx (* sx (+ 1f0 (* 0.06f0 dc)))))
    (unless (and (= sy 1f0) (= sx 1f0))
      (let* ((jm (model-joints m)) (p *pose-at*) (yaw (aref p 3))
             (ox (aref p 0)) (oy (aref p 1)) (oz (aref p 2)) (rx (f-cos yaw)) (rz (- (f-sin yaw))) (k (- sx 1f0)))
        (declare (type f32vec jm p) (single-float yaw ox oy oz rx rz k))
        (dotimes (j +nj+)
          (let ((o (* 16 j)))
            (declare (fixnum o))
            (dotimes (col 4)                           ; the three axes, then the origin (about his feet)
              (let* ((q (+ o (* 4 col))) (org (= col 3))
                     (vx (if org (- (aref jm q) ox) (aref jm q))) (vy (if org (- (aref jm (+ q 1)) oy) (aref jm (+ q 1))))
                     (vz (if org (- (aref jm (+ q 2)) oz) (aref jm (+ q 2))))
                     (d (* k (+ (* vx rx) (* vz rz)))))
                (declare (fixnum q) (single-float vx vy vz d))
                (setf (aref jm q) (+ (if org ox 0f0) vx (* d rx))
                      (aref jm (+ q 1)) (+ (if org oy 0f0) (* sy vy))
                      (aref jm (+ q 2)) (+ (if org oz 0f0) vz (* d rz)))))))))
    nil))

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
(defmacro %br-ball (x y z a life r pal sd)
  "A ball of light at (X Y Z), its frame A (a fixnum, from the shot) of LIFE (a fixnum), full radius R, palette PAL, seed SD
(零距離砲擊's blast, R6, §11: 「砲擊不要發射光束，直接在爆炸點炸開光球來表示」; the awakened K route's L L shots, R8, §13): a white
flash ball on the first two frames, then the ball swelling over its first third, its jade / gold shell in a dark rim round a
white core that shrinks away, eroding over its last half, dark smoke puffs rising and thinning from frame 6, a new drawing
every two frames. Single-float forms (a macro: 0 B)."
  `(let* ((%x ,x) (%y ,y) (%z ,z) (%a ,a) (%life ,life) (%r ,r) (%pal ,pal)
          (%d (i->f (* 2 (floor %a 2))))                 ; (on twos)
          (%u (/ %d (i->f %life)))
          (%es (* %r (+ 0.55f0 (* 0.6f0 (%lb-ss (* 3f0 %u))))))   ; (swells over the first third)
          (%k (- 1f0 (%lb-ss (/ (- %u 0.45f0) 0.55f0))))          ; (erodes over the last half)
          (%sd (+ ,sd %d)))
     (declare (fixnum %a %life) (single-float %x %y %z %r %pal %d %u %es %k %sd))
     (if (< %a 2)
         (fx-disc %x %y %z (* 0.5f0 %r) 0.05f0 %sd +pal-hit+ 0.98f0 :push 0.45f0)   ; (the flash: a white ball)
         (progn                                        ; (the ball of light: no spikes, no line toward him)
           (fx-disc %x %y %z (* 1.08f0 %es) 0.06f0 (+ %sd 3f0) +pal-ink+ (* 0.6f0 %k) :push 0.2f0)   ; (its dark rim)
           (fx-disc %x %y %z %es 0.05f0 %sd %pal %k :push 0.3f0)                               ; (the shell)
           (let ((%cr (* %es (- 0.62f0 (* 0.62f0 (%lb-ss (/ %u 0.6f0)))))))                   ; (the white core)
             (declare (single-float %cr))
             (when (> %cr 0.02f0) (fx-disc %x %y %z %cr 0.04f0 (+ %sd 5f0) +pal-hit+ 0.97f0 :push 0.4f0)))
           (when (>= %a 6)                              ; the smoke: three puffs rising off it
             (dotimes (%j 3)
               (let* ((%fj (i->f %j)) (%an (+ (* 2.1f0 %fj) (* 0.3f0 %u))) (%rr (* %r (+ 0.3f0 (* 0.5f0 %u)))))
                 (declare (single-float %fj %an %rr))
                 (fx-disc (+ %x (* %rr (f-cos %an))) (+ %y (* %r (+ 0.1f0 (* 0.9f0 %u))) (* 0.2f0 %fj)) (+ %z (* %rr (f-sin %an)))
                          (* %r (+ 0.22f0 (* 0.3f0 %u))) 0.25f0 (+ %sd 20f0 %fj) +pal-smoke+ (* 0.8f0 %k)))))))))
(defparameter *br-blast-life* 18
  "A ball of light (%BR-BALL: the awakened K route's L L, R8; K3's 零距離砲擊 until R9 took the blast out, §14): the frames it
lasts from the shot ...")
(defparameter *br-blast-r* 0.8 "... its radius at full size (m), x the draw scale.")

;; R8 (DUEL_LILLE_V3 §13, the user 2026-10-11: 「K 砲擊銜接的 L 也用一樣的砲擊特效炸在不同位置上」): the awakened K route's
;; L L (KL1 KL2 KL3, the 萬物貫通 lines after K3's blast) drawn as K3's balls of light instead of the line (BR-SHOT-FIRE spawns
;; their look as :ball, which LB-LOOK does not draw); the hit is still the line's
(defparameter *br-kl-balls*
  '((:br-e-kl1 0.9 1.9 0.75) (:br-oe-kl1 0.9 2.2 0.75) (:br-e-kl2 -0.9 0.55 0.75) (:br-oe-kl2 -0.9 0.8 0.75)
    (:br-e-kl3 0 1.25 1.15) (:br-oe-kl3 0 1.55 1.15))
  "The balls' places (R8, §13) round the line's point at the opponent's distance (on the line along his facing, even when
he is off it), by move: (move right up radius): KL1 off to his right and high, KL2 the other side and low, KL3 a bigger
one on him; metres (right of the line, above his floor) and the full radius.")
(defun-fast %br-kl-balls (f side mv)
  "The awakened K route's L L shot (a move in *BR-KL-BALLS*) at its frame: from its hit's first frame for *BR-BLAST-LIFE*
frames a ball of light (%BR-BALL) at its place on the line at the opponent's distance (his place and facing: *POSE-AT*,
DRAW-FIGHTER's; the opponent's: *BR-AT*), and a smaller one beside it. Reads the move's frame only. 0 B."
  (declare (fixnum side))
  (let* ((ent (assoc (mv-name mv) *br-kl-balls*)) (hits (mv-hits mv)) (n (length hits)) (life (the fixnum *br-blast-life*))
         (at *br-at*) (o (* 8 side)) (pa *pose-at*)
         (a (if (and ent (> n 0) (> (aref at (+ o 4)) 0.5f0))
                (- (the fixnum (fighter-sf f)) (the fixnum (hw-from (aref hits 0)))) -1)))
    (declare (fixnum n life o a) (type f32vec at pa))
    (when (<= 0 a life)
      (let* ((pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+)) (sc (aref *lb-v* 31))
             (yaw (aref pa 3)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw)))
             (dist (f-max 1f0 (f-hypot (- (aref at (+ o 2)) (aref at o)) (- (aref at (+ o 3)) (aref at (+ o 1))))))
             (lr (the single-float (f32 (second ent)))) (up (the single-float (f32 (third ent))))
             (r (* sc (the single-float (f32 (fourth ent)))))
             (x (+ (aref at o) (* dist ux) (* lr rx))) (y (+ (aref *lb-v* 3) up)) (z (+ (aref at (+ o 1)) (* dist uz) (* lr rz)))
             (sd (+ 470f0 (* 50f0 (i->f side)) (* 7f0 lr))))
        (declare (single-float pal sc yaw ux uz rx rz dist lr up r x y z sd))
        (%br-ball x y z a life r pal sd)
        (when (> a 1)                                   ; (a smaller one beside it, a frame later)
          (%br-ball (- x (* 0.5f0 r rx)) (+ y (* 0.45f0 r)) (- z (* 0.5f0 r rz)) (1- a) life (* 0.45f0 r) pal (+ sd 31f0)))))
    nil))

;; R9 (DUEL_LILLE_V3 §14, the user 2026-10-11: 「架式 L 的動作模組改成八翼往後收、身體前傾高速衝向對手，如果有碰到對手就穿過對
;; 方並造成連續斬擊（類似阿修羅壹霧銀先穿過對手、然後在讓對方受傷的表現）」): the awakened L's dash (the sim slides him through
;; him, barro.lisp BR-W-DASH) streaks, and once he is past, the cuts appear on the one he passed (Zoro's 阿修羅 一霧銀); the
;; cuts outlive the move (the next L press starts at its S + A), so their place and start are kept per side (*BR-CUTS*)
(defparameter *br-dash-moves* '(:br-e-l1 :br-oe-l1)
  "The awakened L dashes (R9; one charged dash since R10, §15): the charge's tells (%BR-CHARGE-LOOK), the streaks and, when
it hit, the cuts after (%BR-DASH-LOOK, %BR-CUTS-LOOK).")
(defparameter *br-dash-frames* 8 "The dash's frames from S (= barro.lisp's *BR-W-DASH-F*): the streaks, then the cuts.")
(defparameter *br-dash-streak* '(1.0 1.5 2.1)
  "The streaks' length x this by the charge level 1 / 2 / 3 (R10, DUEL_LILLE_V3 §15: 「隨著續力階段增加衝刺距離」; level 3 a white
core streak in them as well).")
(defparameter *br-dash-cut-len* '(2.2 2.5 2.8)
  "The cuts on him after the dash (R9; R11, DUEL_LILLE_V3 §16: each a hit of the sim's, barro.lisp BR-W-CUTS' :br-cut
hazards, drawn by BR-CUT-LOOK): this long (m, by the charge level), crossing round his middle.")
(defmacro %br-l-level (held)
  "The awakened L dash's charge level 1-3 for HELD frames (barro.lisp's BR-W-L-LEVEL on *BR-W-L-LEVELS*, inline: 0 B)."
  `(let ((%h ,held) (%l *br-w-l-levels*))
     (declare (fixnum %h))
     (cond ((>= %h (the fixnum (second %l))) 3) ((>= %h (the fixnum (first %l))) 2) (t 1))))
(defun-fast %br-dash-look (f side mv)
  "The awakened L dash (a move in *BR-DASH-MOVES*) at its frame: through the dash (S .. S + *BR-DASH-FRAMES* + 1) five
speed streaks trailing behind him (his drawn place: *POSE-AT*), longer by the charge level (*BR-DASH-STREAK*, R10; level 3
a white core streak too); the cuts after it are the sim's hazards (R11: BR-CUT-LOOK). Reads the move's frame and the frames L was
held (FIGHTER-CHARGE: the level, as BR-W-DASH's) only (cosmetic). 0 B."
  (declare (fixnum side))
  (let* ((sf (fighter-sf f)) (s (mv-s mv)) (dashf (the fixnum *br-dash-frames*)) (pa *pose-at*)
         (pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+))
         (lv (%br-l-level (fighter-charge f))) (sk (the single-float (nth (1- lv) *br-dash-streak*)))
         (yaw (aref pa 3)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw))))
    (declare (fixnum sf s dashf lv) (type f32vec pa) (single-float pal sk yaw ux uz rx rz))
    (when (and (<= s sf) (< sf (+ s dashf 2)))           ; the streaks behind him
      (let ((x (aref pa 0)) (y (aref pa 1)) (z (aref pa 2)))
        (declare (single-float x y z))
        (dotimes (i 5)
          (let* ((fi (i->f i)) (lat (* 0.32f0 (- fi 2f0))) (h (+ y 0.55f0 (* 0.28f0 (f-abs (- fi 2f0)))))
                 (ln (* sk (+ 1.6f0 (* 0.5f0 (hash01 fi 7.3f0)))))
                 (x0 (+ x (* lat rx) (* -0.4f0 ux))) (z0 (+ z (* lat rz) (* -0.4f0 uz))))
            (declare (single-float fi lat h ln x0 z0))
            (%streak x0 h z0 (- x0 (* ln ux)) h (- z0 (* ln uz)) (* 0.05f0 (+ 0.6f0 (* 0.4f0 sk))) pal 0.9f0 (+ 520f0 fi))
            (when (and (= lv 3) (= i 2))               ; (level 3: a white core in the middle one)
              (%streak x0 h z0 (- x0 (* 0.8f0 ln ux)) h (- z0 (* 0.8f0 ln uz)) 0.025f0 +pal-hit+ 0.95f0 526f0))))))
    nil))
(defun-fast br-cut-look (hz rdt)
  "One cut of the awakened L dash on the one he passed (R11, DUEL_LILLE_V3 §16: 「我希望衝刺 L 依據蓄力階段給出多段的斬擊特效
與 combo 計數」): a :br-cut hazard of barro.lisp's BR-W-CUTS (its data: the cut's index I and the charge level), drawn from
its hit (the hazard's delay over) for its life: a crossing pair of jade (the owl: gold) lenses with white cores, *BR-DASH-CUT-LEN*
long by the level, at golden-angle turns cut to cut in the plane square to the dash, each drawn in from one end over 2
frames, held, fading, a spark where it opens: 阿修羅 一霧銀's after-the-fact cuts, one a hit (the combo counts them). 0 B."
  (declare (single-float rdt))
  (when (and (<= (hazard-delay hz) 0) (>= rdt 0f0))
    (let* ((d (hazard-data hz)) (fi (i->f (the fixnum (first d)))) (lv (max 1 (min 3 (the fixnum (second d)))))
           (side (fighter-side (fighter (hazard-owner hz))))
           (pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+))
           (a (i->f (the fixnum (hazard-age hz)))) (life (i->f (the fixnum (hazard-life hz))))
           (yaw (hazard-yaw hz)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw)))
           (half (* 0.5f0 (the single-float (nth (1- lv) *br-dash-cut-len*))))
           (cx (hazard-x hz)) (cz (hazard-z hz)) (cy (+ (aref *lb-v* 3) 1.05f0))
           (k (- 1f0 (%lb-ss (/ (- a (* 0.5f0 life)) (* 0.5f0 life))))) (g (f-min 1f0 (/ (+ a 1f0) 2f0))))
      (declare (fixnum lv side) (single-float fi pal a life yaw ux uz rx rz half cx cy cz k g))
      (dotimes (j 2)                                    ; (the crossing pair: 「交叉斬痕」)
        (let* ((fj (i->f j)) (th (+ 0.4f0 (* 2.39996f0 fi) (* 1.7f0 fj)))   ; (the golden angle: the cuts spread round)
               (dx (* 0.18f0 (- (hash01 fi 3.1f0) 0.5f0))) (dy (* 0.3f0 (- (hash01 (+ fi fj) 5.7f0) 0.5f0)))
               (ca (* half (f-cos th))) (sa (* half (f-sin th)))
               (x0 (+ cx (* dx rx) (- (* ca rx)))) (y0 (+ cy dy (- sa))) (z0 (+ cz (* dx rz) (- (* ca rz))))
               (x1 (+ x0 (* g 2f0 ca rx))) (y1 (+ y0 (* g 2f0 sa))) (z1 (+ z0 (* g 2f0 ca rz)))
               (bx (+ (* 0.5f0 (+ x0 x1)) (* 0.12f0 ux))) (by (* 0.5f0 (+ y0 y1))) (bz (+ (* 0.5f0 (+ z0 z1)) (* 0.12f0 uz)))
               (sd (+ 540f0 (* 9f0 fi) (* 4f0 fj))))
          (declare (single-float fj th dx dy ca sa x0 y0 z0 x1 y1 z1 bx by bz sd))
          (fx-crescent x0 y0 z0 x1 y1 z1 bx by bz 0.09f0 :lens 0.04f0 sd pal k :push 0.3f0)
          (fx-crescent x0 y0 z0 x1 y1 z1 bx by bz 0.035f0 :lens 0.02f0 (+ sd 1f0) +pal-hit+ (* 0.95f0 k) :push 0.35f0)
          (when (< a 2f0)                                ; (the cut's spark where it opens)
            (fx-star x1 y1 z1 0.05f0 0.22f0 6 sd 0f0 0f0 0.08f0 (+ sd 2f0) +pal-hit+ 0.95f0 :push 0.4f0))))))
  nil)

;; R10 (DUEL_LILLE_V3 §15, the user 2026-10-11: 「L 衝刺改成只能衝一次不能連接，但可以三階段續力，隨著續力階段增加衝刺距離與
;; 交叉斬痕（增加傷害）並提昇特殊資源回收量」): while L is held (the move's :hold phase) the charge pose (:br-en-lc), coiled lower
;; by the level (BR-DEFORM, %BR-CHARGE-DEPTH) and its wings swept tighter (*LB-WF* [80]); light gathering into him, more
;; by the level, a glow at his core from level 2 (a white heart in it at 3), and a flash at each level-up (the frames held
;; reach *BR-W-L-LEVELS*' 20 / 40). All read from the frames held (FIGHTER-HOLD), then the frames L was held (FIGHTER-CHARGE).
(defun-fast %br-charge-look (f side mv)
  "The awakened L's charge (a move in *BR-DASH-MOVES*; R10, §15) at the frames held: motes of light spiralling in to him
(4 / 8 / 12 by the level), his core's glow from level 2 (a white heart at 3, flickering on twos), the level-up flash (a
white ball, a star burst: bigger at 3) over 10 frames from the level's frame held; after the release the motes and the
glow fade over the dash's load (8 frames). His drawn place: *POSE-AT*. Cosmetic. 0 B."
  (declare (fixnum side))
  (let* ((hold (eq (fighter-phase f) :hold)) (h (if hold (fighter-hold f) (fighter-charge f)))
         (lvs *br-w-l-levels*) (la (the fixnum (first lvs))) (lb (the fixnum (second lvs))) (lv (%br-l-level h))
         (fade (if hold 1f0 (- 1f0 (%lb-ss (/ (i->f (fighter-sf f)) 8f0)))))
         (pa *pose-at*) (x (aref pa 0)) (y (aref pa 1)) (z (aref pa 2)) (sc (aref *lb-v* 31)) (cy (+ y (* 1.15f0 sc)))
         (pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+)))
    (declare (fixnum h la lb lv) (type f32vec pa) (single-float fade x y z sc cy pal))
    (setf mv nil)                                       ; (unused: the looks' signature)
    (when (> fade 0f0)
      (dotimes (i (* 4 lv))                             ; the motes gathering in
        (let* ((fi (i->f i)) (ph (/ (i->f (mod (+ h (* 7 i)) 18)) 18f0))
               (r (* sc (- 1.5f0 (* 1.3f0 ph)))) (an (+ (* 2.39996f0 fi) (* 0.12f0 (i->f h))))
               (k (* fade (%lb-ss (* 4f0 ph)) (- 1f0 (%lb-ss (/ (- ph 0.8f0) 0.2f0))))))
          (declare (single-float fi ph r an k))
          (fx-star (+ x (* r (f-cos an))) (+ y (* sc (+ 0.3f0 (* 0.9f0 ph) (* 0.4f0 (hash01 fi 2.3f0))))) (+ z (* r (f-sin an)))
                   0.02f0 (* sc 0.08f0) 4 (* 0.5f0 fi) 0f0 0f0 0.05f0 (+ 600f0 fi) pal k :push 0.3f0)))
      (when (>= lv 2)                                   ; his core's glow
        (let ((r (* sc (+ 0.22f0 (* 0.12f0 (i->f (- lv 2))) (* 0.03f0 (i->f (mod (floor h 2) 2)))))))
          (declare (single-float r))
          (fx-disc x cy z r 0.15f0 (+ 620f0 (i->f lv)) pal (* fade 0.8f0) :push 0.35f0)
          (when (= lv 3) (fx-disc x cy z (* 0.5f0 r) 0.1f0 623f0 +pal-hit+ (* fade 0.95f0) :push 0.45f0)))))
    (when hold                                          ; the level-up flash
      (let ((u (cond ((<= la h (+ la 9)) (i->f (- h la))) ((<= lb h (+ lb 9)) (i->f (- h lb))) (t -1f0))))
        (declare (single-float u))
        (when (>= u 0f0)
          (let* ((t1 (/ u 10f0)) (k (- 1f0 t1)) (big (if (>= h lb) 1.35f0 1f0)))
            (declare (single-float t1 k big))
            (when (< u 2f0) (fx-disc x cy z (* sc big 0.4f0) 0.05f0 625f0 +pal-hit+ (- 0.98f0 (* 0.3f0 u)) :push 0.5f0))
            (fx-star x cy z (* sc 0.15f0) (* sc big (+ 0.6f0 (* 1.2f0 (%lb-ss t1)))) (if (>= h lb) 12 8) (* 0.3f0 (i->f h)) 0f0 0f0
                     0.1f0 626f0 pal k :push 0.4f0)
            (fx-star x cy z (* sc 0.08f0) (* sc big (+ 0.3f0 (* 0.8f0 (%lb-ss t1)))) 6 0.2f0 0f0 0f0 0.08f0 627f0 +pal-hit+ k
                     :push 0.45f0)))))
    nil))

;; R10 (DUEL_LILLE_V3 §15, the user 2026-10-11: 「我測試過，J 陀螺完之後還是射擊不是長鞭呀？」): the J route's L L are whips that
;; reach him: no 萬物貫通 line drawn (BR-SHOT-FIRE's look :whip), the striking front wing (the owl: its claw's gold lash)
;; lashing out along his line to the opponent's distance (at most the line's 31 m) on the hit frames and snapping back.
;; Draw-time only (*LB-WF* [81..85] for LILLE-DRAW): the clip's own stretch (*BR-W-STRETCH*) is what the host tip test reads.
(defparameter *br-whips* '((:br-e-jl1 . 0) (:br-e-jl2 . 1) (:br-e-jl3 . 0) (:br-oe-jl1 . 0) (:br-oe-jl2 . 1) (:br-oe-jl3 . 0))
  "R10 (§15): the J route's L L whips by move: the front wing (the claw's lash) that lashes out to him, 0 right 1 left ...")
(defparameter *br-whip-out* 2 "... flying out over this many frames before S ...")
(defparameter *br-whip-on* 3 "... on him this many frames from S (the hit's 2 and one) ...")
(defparameter *br-whip-back* 5.0 "... snapping back in over this many frames ...")
(defparameter *br-whip-max* 31.0 "... reaching at most this far (m: the line's 31 m, barro.lisp *BR-X-LEN*) ...")
(defparameter *br-whip-up* 1.1 "... to this height over his floor (m: the opponent's chest).")
(defparameter *br-whip-w* 0.07 "... JILLIEL's lash drawn along the reaching blade this wide (m; %BR-WHIP-LASH) ...")
(defparameter *br-whip-curl* 0.18 "... bowing by this share of its length off the hit frames (the lash's curve).")
(defun-fast %br-whip-lash (side)
  "After LILLE-DRAW (R10, §15): JILLIEL's whip as a lash, read off LILLE-DRAW's reaching front wing (*LB-WF* [81 82] its
reach, [86..88] its root, [74..79] its tip): a jade comet curve (the owl: gold) from the root to the tip, a white core in
it, bowing up and back by *BR-WHIP-CURL* of its length while it flies out and snaps back, straight on him (the reach 1).
The owl's claws draw their own (%LB-LASHES). Cosmetic. 0 B."
  (declare (fixnum side))
  (let ((w *lb-wf*))
    (declare (type f32vec w))
    (dotimes (g 2)
      (let ((q (aref w (+ 81 g))))
        (declare (single-float q))
        (when (> q 0f0)
          (let* ((to (+ 74 (* 3 g))) (tx (aref w to)) (ty (aref w (+ to 1))) (tz (aref w (+ to 2)))
                 (rx (aref w 86)) (ry (aref w 87)) (rz (aref w 88))
                 (ln (f-hypot (- tx rx) (- ty ry) (- tz rz))) (bow (* (the single-float *br-whip-curl*) ln (- 1f0 (* q q))))
                 (bx (* 0.5f0 (+ tx rx))) (by (+ (* 0.5f0 (+ ty ry)) bow)) (bz (* 0.5f0 (+ tz rz)))
                 (lw (* (aref *lb-v* 31) (the single-float *br-whip-w*)))
                 (pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+)) (sd (+ 650f0 (* 3f0 (i->f (+ g (* 2 side)))))))
            (declare (fixnum to) (single-float tx ty tz rx ry rz ln bow bx by bz lw pal sd))
            (fx-crescent tx ty tz rx ry rz bx by bz lw :comet 0.04f0 sd pal 0.95f0 :push 0.25f0)
            (fx-crescent tx ty tz rx ry rz bx by bz (* 0.4f0 lw) :comet 0.02f0 (+ sd 1f0) +pal-hit+ 0.92f0 :push 0.3f0))))))
  nil)
(defun-fast %br-whip-reach (f side mv)
  "Before LILLE-DRAW (R10, §15): *LB-WF* [80] the wings' sweep tightness while the awakened L charges (1 + 0.25 x
%BR-CHARGE-DEPTH: the eight wings folding tighter by the level), and for a J route L L whip (*BR-WHIPS*) its wing's reach
0..1 ([81 82]: out over *BR-WHIP-OUT* frames to S, held *BR-WHIP-ON*, back over *BR-WHIP-BACK*) toward the point on his
line at the opponent's distance (*BR-AT*, at most *BR-WHIP-MAX*) at *BR-WHIP-UP* ([83..85]); its crack there on S and the
frame after (a white star in a jade / gold one). Zeroed otherwise (Lille never sets them). Reads the move's frame only.
0 B."
  (declare (fixnum side))
  (let ((w *lb-wf*))
    (declare (type f32vec w))
    (setf (aref w 80) 0f0 (aref w 81) 0f0 (aref w 82) 0f0)
    (when mv
      (when (member (mv-name mv) *br-dash-moves*)
        (setf (aref w 80) (+ 1f0 (* 0.25f0 (%br-charge-depth f nil)))))
      (let ((ent (assoc (mv-name mv) *br-whips*)) (at *br-at*) (o (* 8 side)))
        (declare (type f32vec at) (fixnum o))
        (when (and ent (eq (fighter-phase f) :main) (> (aref at (+ o 4)) 0.5f0))
          (let* ((d (- (the fixnum (fighter-sf f)) (the fixnum (mv-s mv)))) (out (the fixnum *br-whip-out*))
                 (on (the fixnum *br-whip-on*)) (back (the single-float *br-whip-back*))
                 (q (cond ((< d (- out)) 0f0) ((< d 0) (%lb-ss (/ (i->f (+ d out 1)) (i->f (1+ out)))))
                          ((< d on) 1f0) (t (- 1f0 (%lb-ss (/ (i->f (- d on -1)) back)))))))
            (declare (fixnum d out on) (single-float back q))
            (when (> q 0f0)
              (let* ((pa *pose-at*) (yaw (aref pa 3)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw)))
                     (dist (f-min (the single-float *br-whip-max*)
                                  (f-max 1f0 (f-hypot (- (aref at (+ o 2)) (aref at o)) (- (aref at (+ o 3)) (aref at (+ o 1)))))))
                     (tx (+ (aref pa 0) (* dist ux))) (ty (+ (aref pa 1) (the single-float *br-whip-up*))) (tz (+ (aref pa 2) (* dist uz))))
                (declare (type f32vec pa) (single-float yaw ux uz dist tx ty tz))
                (setf (aref w (+ 81 (the fixnum (cdr ent)))) q (aref w 83) tx (aref w 84) ty (aref w 85) tz)
                (when (<= 0 d 1)                        ; the crack on him
                  (let ((pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+)) (g (if (= d 0) 1f0 0.6f0)))
                    (declare (single-float pal g))
                    (fx-star tx ty tz 0.05f0 (* g 0.5f0) 8 (i->f d) 0f0 0f0 0.08f0 640f0 pal 0.95f0 :push 0.4f0)
                    (fx-star tx ty tz 0.03f0 (* g 0.3f0) 6 0.4f0 0f0 0f0 0.06f0 641f0 +pal-hit+ 0.98f0 :push 0.45f0)))))))))
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
(%BR-KIWAMI-LOOK); R10 (§15): the whips' reach and the charge's wing sweep handed to LILLE-DRAW (%BR-WHIP-REACH),
JILLIEL's lash after it (%BR-WHIP-LASH), the L charge's tells (%BR-CHARGE-LOOK)."
  (declare (single-float rdt))
  (let* ((f (fighter e)) (side (fighter-side f)) (mv (and (eq (fighter-state f) :move) (fighter-move f)))
         (c (if mv (%br-chain-clock (mv-name mv) (fighter-sf f)) -1)) (o (* 65 side))
         (awake (member (fighter-form f) '(:jilliel-kin :jilliel :shin-kin :shin))) (n (br-ammo-look e)))
    (declare (fixnum side c o n))
    (setf (lb-fxs side 19) (if awake (i->f (1+ (min 8 n))) 0f0))
    (unless (eq (fighter-form f) :base) (%br-place! e (fighter-opp f) side))   ; (before LILLE-DRAW: R10's whips read it)
    (%br-whip-reach f side mv)                          ; (R10, §15: *LB-WF* [80..85] for LILLE-DRAW, zeroed after it)
    (lille-draw e rdt)
    (unless (member (fighter-form f) '(:shin-kin :shin)) (%br-whip-lash side))   ; (the owl's claws: %LB-LASHES)
    (let ((w *lb-wf*)) (setf (aref w 80) 0f0 (aref w 81) 0f0 (aref w 82) 0f0))
    (when (eq (fighter-form f) :base) (%br-aim-look e f side))
    (%br-spend-note f side n (if awake 2 1))
    (%br-spend-look e side)
    (setf (aref *br-fly* o) 0f0)                        ; (no traces to fly back since v3: the gathering only)
    (when (>= c 0)
      (let ((jm (model-joints (model e))))
        (when (<= c 16) (%br-recall-look e jm side c))
        (when (not (eq (mv-name mv) :br-recall)) (%br-beat-look e f jm side mv))
        (when (and (eq (mv-name mv) :br-rc4) (eq (fighter-phase f) :main)) (%br-kiwami-look f jm side))))
    (when (and mv (assoc (mv-name mv) *br-kl-balls*) (eq (fighter-phase f) :main))   ; R8: the K route's L L as balls
      (%br-kl-balls f side mv))
    (when (and mv (member (mv-name mv) *br-dash-moves*))   ; R9: the L dash, the cuts after (R10: its charge first)
      (%br-charge-look f side mv)
      (when (eq (fighter-phase f) :main) (%br-dash-look f side mv)))
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
-kf*); 40-54 JILLIEL's again as P2, facing the behind camera (the front view). Since R10 (one charged L, no L2 / L3) m 1
(21, 41) sets the same scene with no move started, for a script to hold L (the charge) itself; m 15-17 (35-37, 55-57)
JL1-JL3 6 m out (the whips' reach)."
  (let* ((front (>= m 40)) (m (if front (- m 40) m)) (owl (and (not front) (>= m 20)))
         (far (<= 15 (if owl (- m 20) m) 17)) (m (if far (- m 6) m))   ; (R10: the whips at 6 m)
         (sn (nth (if owl (- m 20) m) '("L1" "L2" "L3" "J1" "J2" "J3" "K1" "K2" "K3" "JL1" "JL2" "JL3" "KL1" "KL2" "KL3")))
         (idle (= (if owl (- m 20) m) 1))              ; (R10: L held by the script)
         (mv (and sn (gethash (intern (format nil "~a-~a" (if owl "BR-OE" "BR-E") sn) :keyword) *moves*))))
    (if (and (null mv) (not idle))
        (log-msg "duel barro: no stance still ~d" m)
        (progn
          (if front (ensure-battle :kenpachi :barro) (ensure-battle :barro :kenpachi))
          (let* ((b (if front *p2* *p1*)) (o (if front *p1* *p2*)) (g (gauges b)))
            (setf *br-keep-owl* owl)
            (force-form b (if owl :shin :jilliel))
            (place *p1* *p2* (if far 6.0 3.0))
            (setf (gauges-reiatsu g) *reiatsu-max* (gauges-fs g) (f32 *fs-max*)
                  (gauges-reishi (gauges o)) (gauges-reishi-max (gauges o)))
            (br-set-ammo b 8)
            (when mv (start-move b mv))
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
blast (in an awakened K3), of the whips' stretch and the owl's lashes (R5), of the body's squash (BR-DEFORM, R8) and the
K route's balls (in an awakened KL, R8), the whips' reach and the L charge's tells (R10; a \"barro consing\" line)."
  (let* ((e *p1*) (f (fighter e)) (side (fighter-side f)) (m (model e)) (jm (model-joints m))
         (mv (and (eq (fighter-state f) :move) (fighter-move f))))
    (macrolet ((per (form) `(let ((c0 (cons-bytes))) (dotimes (i 10) ,form) (- (cons-bytes) c0))))
      (log-msg "barro consing (10 draws, B): form ~a clock ~d draw ~d (Lille's ~d) spends ~d recall ~d beat (lines drive beat) ~a kiwami ~d stretch ~d lashes ~d deform ~d kl-balls ~d dash ~d cuts ~d whip ~d charge ~d"
               (fighter-form f) (br-hold-clock f)
               (per (br-draw e 0.016f0)) (per (lille-draw e 0.016f0))
               (per (progn (%br-spend-note f side (br-ammo-look e) 2) (%br-spend-look e side))) (per (%br-recall-look e jm side 4))
               (if (and mv (member (mv-name mv) '(:br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4)))
                   (list (per (%br-beat-look e f jm side mv)) (per (br-rc-drive f mv)) (per (br-rc-beat (mv-name mv) (fighter-sf f))))
                   -1)
               (if (and mv (eq (mv-name mv) :br-rc4)) (per (%br-kiwami-look f jm side)) -1)
               (per (%lb-stretch! (model-anim m))) (per (%lb-lashes jm side)) (per (br-deform e m))
               (if (and mv (assoc (mv-name mv) *br-kl-balls*)) (per (%br-kl-balls f side mv)) -1)
               (if (and mv (member (mv-name mv) *br-dash-moves*)) (per (%br-dash-look f side mv)) -1)
               (let ((h0 nil)) (do-entities (h (hz hazard)) (when (eq (hazard-kind hz) :br-cut) (setf h0 hz)))   ; (R11)
                 (if h0 (per (br-cut-look h0 0.016f0)) -1))
               (per (progn (%br-whip-reach f side mv) (%br-whip-lash side)))
               (if (and mv (member (mv-name mv) *br-dash-moves*)) (per (%br-charge-look f side mv)) -1)))))

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

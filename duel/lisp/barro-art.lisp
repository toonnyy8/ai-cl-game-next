;;;; barro-art.lisp — LILLE BARRO II's own looks (docs/duel/DUEL_LILLE_V2.md §7, §12, §17, §22; version 3: DUEL_LILLE_V3.md).
;;;; His art is Lille's, shared by reference (lille-art.lisp: the bodies, Diagramm, every :lb-* clip, LILLE-DRAW's wings /
;;;; halos / legs, LB-LOOK's lines and beams); this file holds only what is his: the clips Lille never had (the volley
;;;; :br-recall and its strings, the turn, the owl's twins, the stance's swing L1), the draw hook BR-DRAW (his wing count to
;;;; Lille's lit wings, Lille's, then the base stance's aim line, the spends' looks and the volley's) and the special
;;;; resource's HUD row.
;;;; Everything here is cosmetic: the sim never reads it. Loaded after lille-art.lisp (its macros and props) and before
;;;; barro.lisp (whose state and knobs these functions read at draw time).
(in-package :duel)

(declaim (special *br-at* *br-keep-owl* *br-dash-moves* *br-snipe-moves* *br-snipe-kick* *br-w-l-levels*))   ; (*BR-AT*, *BR-DASH-MOVES*,
                                                                              ;  *BR-SNIPE-MOVES* below; *BR-KEEP-OWL*,
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
;;; One shot a segment since R7 (DUEL_LILLE_V3 §12, the user 2026-10-11: 「我希望段數跟操作時的點擊次數一致」; 2-4 before).
;;; Since R15 (§19) the openers are the charged snipe and the melee J / K (below, "R15"); the R3 shots (L 集 GATHER, J 補
;;; REFILL, K 重 HEAVY) are gone, their follow-ups stay:
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
(defpose :br-pj-hip (:base :lb-stance)   ; J1: one hand at the hip, stepped in: muzzle (0.09 0.98 2.18) az -7.0 el 0.0, grip (0.30 0.98 0.44), hand-l (-0.58 0.99 -0.12)
  (:root :f 0.08 :u -0.06) (:pelvis :twist 14) (:spine :flex 8) (:chest :twist -2) (:thigh-r :flex 18 :side 6) (:knee-r :flex 24) (:thigh-l :flex -12 :side 6) (:knee-l :flex 16) (:arm-l :flex -24 :side 46) (:elbow-l :flex 34) (:hand-l :flex -10)
  (:arm-r :flex 3.6 :side 16.9 :twist -9.1) (:elbow-r :flex 82.1) (:hand-r :flex -79.5 :twist 1.9))
(defpose :br-pj-hop (:base :lb-stance)   ; J2: hopped to his left, low: muzzle (0.03 0.92 2.21) az -3.0 el 0.0, grip (0.12 0.92 0.46), hand-l (-0.87 1.11 0.24)
  (:root :r -0.14 :f 0.04 :u -0.13 :yaw -8) (:pelvis :twist 6) (:spine :flex 14) (:chest :twist 4) (:thigh-l :flex 12 :side 22) (:knee-l :flex 34) (:thigh-r :flex -6 :side 6) (:knee-r :flex 12) (:arm-l :flex 6 :side 74) (:elbow-l :flex 22) (:hand-l :flex -10)
  (:arm-r :flex 21.4 :side 17.8 :twist 8.6) (:elbow-r :flex 80.9) (:hand-r :flex -88.8 :twist -11.6))
(defpose :br-pj-hop-kick (:base :lb-stance)   ; its kick: muzzle (0.04 1.21 2.11) az -3.0 el 8.0, grip (0.13 0.97 0.38), hand-l (-0.91 1.23 0.12)
  (:root :r -0.14 :f 0.0 :u -0.08 :yaw -8) (:pelvis :twist 6) (:spine :flex 10) (:chest :twist 4) (:thigh-l :flex 10 :side 22) (:knee-l :flex 28) (:thigh-r :flex -6 :side 6) (:knee-r :flex 10) (:arm-l :flex 0 :side 80) (:elbow-l :flex 18) (:hand-l :flex -10)
  (:arm-r :flex 13.2 :side 20.1 :twist 10.2) (:elbow-r :flex 83.8) (:hand-r :flex -79.6 :twist -15.2))
(defpose :br-pj-shoulder (:base :lb-stance)   ; J3: flipped up onto the shoulder: muzzle (0.10 2.95 0.99) az -10.0 el 62.0, grip (0.24 1.40 0.18), hand-l (-0.37 1.05 0.28)
  (:root :u -0.02) (:pelvis :twist 10) (:spine :flex -2) (:chest :twist -6) (:head :flex -4 :twist -6) (:arm-l :flex 10 :side 20) (:elbow-l :flex 60) (:hand-l :flex -20)
  (:arm-r :flex 31.8 :side 16.0 :twist -11.2) (:elbow-r :flex 153.2) (:hand-r :flex -125.9 :twist -1.0))
(defpose :br-pk-brace (:base :lb-kamae-pose)   ; K1: braced at the waist, left foot forward: muzzle (0.02 1.01 2.05) az -3.0 el -0.1, grip (0.12 1.01 0.30), hand-l (0.07 0.89 0.62)
  (:root :f 0.06 :u -0.27 :pitch 6) (:pelvis :twist 6) (:spine :flex 10) (:chest :twist -20) (:head :flex 4 :twist 16) (:thigh-l :flex 46 :side 22) (:knee-l :flex 60) (:thigh-r :flex -26 :side 24) (:knee-r :flex 40)
  (:arm-r :flex 30.3 :side 0.2 :twist 49.7) (:elbow-r :flex 132.4) (:hand-r :flex -147.9 :twist -32.0) (:arm-l :flex 51.1 :side -56.6) (:elbow-l :flex 34.8))
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
;;; R15 (DUEL_LILLE_V3 §19, the user 2026-10-11: 「用覺醒狀態的系統邏輯與動作模組的設計風格重製常態模式」: 「蓄力狙擊」,
;;; 「槍鬥術」, 「槍身重揮」, the openers 「改成近距離」): the stance's L one charged snipe, its J / K melee strikes in the
;;; awakened forms' style (big body motion, anticipation, squash and stretch: *BR-SQUASH*, smears). The hit poses solved by
;;; FK over the rig (the keys' comments: the muzzle and the grip in metres, x his right / y up / f ahead, the barrel's
;;; azimuth (+ = his right) and elevation): on each hit frame Diagramm's struck point on his line at the move's drawn reach
;;; (barro.lisp *BR-W-TIPS* "BR-S", the host FK test: drawn reach = hit reach).
;;; - L 蓄力狙擊: the charge pose :br-sk-lc while L is held (the move's :clip, up to 60 f at speed 1): shouldered, the aim
;;;   settling, braced lower and wider by the level (BR-DEFORM); the shot :br-sk-l1 (the level 2 / 3 copies' clip; since R16,
;;;   DUEL_LILLE_V3 §20, level 1's own :br-sk-l1s, its :clip-2, with the 16-frame wind-up), its kick and its look by the level
;;;   (%BR-SNIPE-LOOK; the body thrown back by it, BR-DEFORM).
;;; - R16 (§20): the gun-kata re-timed to S 10 with in-betweens, and the base form's attack-state J3 :br-jab (below).
;;; - J 槍鬥術 GUN-KATA, one hand, one point-blank shot a press (the muzzle 1.9 m out, a flash there: %BR-KATA-LOOK): J1 coiled
;;;   left, one full spin right, the rifle flung out at arm's length, out of it into a deep lunge, fired from the hip; J2 a
;;;   half turn on, his back to him, the left leg kicked up, fired behind his back over his shoulder's look; J3 whipped back
;;;   round to the left, crouched wide, his left side to him, fired under his raised left arm, then Diagramm flipped up onto
;;;   his shoulder as he turns back.
;;; - K 槍身重揮 the rifle swung as a club, two hands at the grip (a bat's), the muzzle end striking (2.6 / 2.5 / 2.6 m), the
;;;   great sword's three-blow rhythm: K1 cocked on the right shoulder, laid far back and stretched tall, the squat tell,
;;;   the sweep right -> left (the body turned through it: the muzzle on an arc), squashed on the hit, wrapped round to his
;;;   left; K2 hauled up over the left shoulder, the backhand down across him to his lower right; K3 carried round by it,
;;;   one full turn right, the rifle out and rising, straight up overhead (tallest), arched back a beat, the smash down onto
;;;   him and on into the floor (squashed flattest).
(defpose :br-sj-hip (:base :lb-stance)   ; J1 the spin hip shot: muzzle (0.03 1.12 1.91) az -1.4 el 8.4, grip (0.08 0.86 0.18)
  (:root :f 0.18 :u -0.16 :pitch 8) (:pelvis :twist 22) (:spine :flex 8) (:chest :twist 6) (:neck :twist -12) (:head :twist -12 :flex 4) (:arm-l :flex -50 :side 62) (:elbow-l :flex 16) (:hand-l :flex -10) (:thigh-r :flex 48 :side 8) (:knee-r :flex 64) (:thigh-l :flex -28 :side 10) (:knee-l :flex 18) (:arm-r :flex -36.1 :side -59.6 :twist -57.8) (:elbow-r :flex 91.4) (:hand-r :flex -4.8 :twist 20))
(defpose :br-sj-hip-kick (:base :lb-stance)   ; its kick: muzzle (0.04 1.36 1.81) az -1.1 el 16.8, grip (0.07 0.85 0.14)
  (:root :f 0.12 :u -0.16 :pitch 8) (:pelvis :twist 22) (:spine :flex 8) (:chest :twist 6 :flex -6) (:neck :twist -12) (:head :twist -12 :flex 4) (:arm-l :flex -50 :side 62) (:elbow-l :flex 16) (:hand-l :flex -10) (:thigh-r :flex 48 :side 8) (:knee-r :flex 64) (:thigh-l :flex -28 :side 10) (:knee-l :flex 18) (:arm-r :flex -36.8 :side -60.1 :twist -59.1) (:elbow-r :flex 91.8) (:hand-r :flex -1.2 :twist 20.2))
(defpose :br-sj-back (:base :lb-stance)   ; J2 the back shot: muzzle (-0.02 1.07 1.90) az -3.5 el 4.8, grip (0.09 0.93 0.16)
  (:root :yaw -180 :f -0.06 :u -0.1 :pitch 14) (:pelvis :twist 4) (:spine :flex 10) (:chest :twist -14) (:neck :twist -40 :flex -10) (:head :twist -44 :flex -6) (:arm-l :flex 70 :side 40) (:elbow-l :flex 14) (:hand-l :flex -10) (:thigh-r :flex 10 :side 6) (:knee-r :flex 24) (:thigh-l :flex -44 :side 10) (:knee-l :flex 76) (:arm-r :flex -32.3 :side -59.3 :twist -54.6) (:elbow-r :flex 57.6) (:hand-r :flex 16.4 :twist -119.4))
(defpose :br-sj-back-kick (:base :lb-stance)   ; its kick: muzzle (-0.02 1.30 1.88) az -3.2 el 12.5, grip (0.08 0.92 0.17)
  (:root :yaw -180 :f -0.02 :u -0.1 :pitch 8) (:pelvis :twist 4) (:spine :flex 10) (:chest :twist -14) (:neck :twist -40 :flex -10) (:head :twist -44 :flex -6) (:arm-l :flex 70 :side 40) (:elbow-l :flex 14) (:hand-l :flex -10) (:thigh-r :flex 10 :side 6) (:knee-r :flex 24) (:thigh-l :flex -44 :side 10) (:knee-l :flex 76) (:arm-r :flex -31 :side -58.7 :twist -65.4) (:elbow-r :flex 55) (:hand-r :flex 7.5 :twist -115.1))
(defpose :br-sj-under (:base :lb-stance)   ; J3 under the left arm: muzzle (0.01 1.18 1.91) az -10.7 el -1.0, grip (0.33 1.21 0.19)
  (:root :yaw -90 :u -0.14) (:pelvis :twist 0 :side 6) (:spine :flex 6 :side 4) (:chest :twist 8) (:neck :twist 30) (:head :twist 46 :flex 4) (:arm-l :flex 40 :side 120) (:elbow-l :flex 50) (:hand-l :flex -10) (:thigh-r :flex 4 :side 26) (:knee-r :flex 34) (:thigh-l :flex 6 :side 30) (:knee-l :flex 40) (:arm-r :flex 36.6 :side -47.2 :twist 60.8) (:elbow-r :flex 82.2) (:hand-r :flex -127.8 :twist 48.7))
(defpose :br-sj-under-kick (:base :lb-stance)   ; its kick: muzzle (0.00 1.41 1.89) az -11.9 el 5.3, grip (0.36 1.25 0.18)
  (:root :yaw -90 :u -0.14) (:pelvis :twist 0 :side 6) (:spine :flex 6 :side 10) (:chest :twist 8) (:neck :twist 30) (:head :twist 46 :flex 4) (:arm-l :flex 40 :side 120) (:elbow-l :flex 50) (:hand-l :flex -10) (:thigh-r :flex 4 :side 26) (:knee-r :flex 34) (:thigh-l :flex 6 :side 30) (:knee-l :flex 40) (:arm-r :flex 39 :side -50.5 :twist 52.4) (:elbow-r :flex 90) (:hand-r :flex -127.4 :twist 57.5))
(defpose :br-sk-cock (:base :lb-stance)   ; K1 cocked on his right shoulder: muzzle (0.75 2.66 -1.19) az 164.7 el 46.1, grip (0.43 1.40 -0.02)
  (:root :yaw -18 :f -0.06 :u 0.02) (:pelvis :twist -10) (:spine :flex -4) (:chest :twist -44) (:neck :twist 25) (:head :twist 25 :flex 6) (:thigh-r :flex -14 :side 12) (:knee-r :flex 22) (:thigh-l :flex 26 :side 10) (:knee-l :flex 30) (:arm-r :flex 68 :side 6 :twist 45.7) (:elbow-r :flex 62.8) (:hand-r :flex -134.6 :twist -105.3) (:arm-l :flex 31.5 :side -40.4 :twist 21.1) (:elbow-l :flex 63.5))
(defpose :br-sk-wind (:base :lb-stance)   ; K1 the wind-up, laid back: muzzle (1.13 2.22 -1.53) az 147.7 el 22.2, grip (0.26 1.55 -0.16)
  (:root :yaw -32 :f -0.14 :u 0.06 :pitch -6) (:pelvis :twist -22) (:spine :flex -8) (:chest :twist -58) (:neck :twist 33) (:head :twist 33 :flex 8) (:thigh-r :flex -14 :side 12) (:knee-r :flex 22) (:thigh-l :flex 26 :side 10) (:knee-l :flex 30) (:arm-r :flex 135.7 :side 95.7 :twist -67.4) (:elbow-r :flex 22.9) (:hand-r :flex -114.9 :twist -78.3) (:arm-l :flex 22.1 :side -33.8 :twist -6.3) (:elbow-l :flex 126.4))
(defpose :br-sk-k1-hit (:base :lb-stance)   ; K1 the hit: muzzle (0.00 1.32 2.61) az 3.0 el 2.9, grip (-0.09 1.23 0.87)
  (:root :yaw 8 :f 0.3 :u -0.12 :pitch 10) (:pelvis :twist 14) (:spine :flex 12) (:chest :twist 22) (:neck :twist -13) (:head :twist -13 :flex 2) (:thigh-l :flex 52 :side 12) (:knee-l :flex 60) (:thigh-r :flex -32 :side 14) (:knee-r :flex 22) (:arm-r :flex 62.5 :side 35.7 :twist -32.6) (:elbow-r :flex 110.5) (:hand-r :flex -153.9 :twist -33.9) (:arm-l :flex 8.2 :side -66.9 :twist 51.8) (:elbow-l :flex 73.9))
(defpose :br-sk-k1-sw1 (:base :lb-stance)   ; K1 the swing, the hit turned -110: muzzle (2.20 1.59 -0.62) az 109.7 el 9.9
  (:root :yaw -60.2 :f 0.04 :u -0.1 :pitch 10) (:pelvis :twist -0.3) (:spine :flex 12) (:chest :twist -5.5) (:neck :twist -13) (:head :twist 20 :flex 2) (:thigh-l :flex 52 :side 12) (:knee-l :flex 60) (:thigh-r :flex -32 :side 14) (:knee-r :flex 22) (:arm-r :flex 62.5 :side 35.7 :twist -32.6) (:elbow-r :flex 110.5) (:hand-r :flex -153.9 :twist -33.9) (:arm-l :flex 8.2 :side -66.9 :twist 51.8) (:elbow-l :flex 73.9))
(defpose :br-sk-k1-sw2 (:base :lb-stance)   ; K1 the swing, the hit turned -72: muzzle (2.23 1.46 0.89) az 72.9 el 6.8
  (:root :yaw -36.64 :f 0.14 :u -0.12 :pitch 10) (:pelvis :twist 4.64) (:spine :flex 12) (:chest :twist 4) (:neck :twist -13) (:head :twist 8.6 :flex 2) (:thigh-l :flex 52 :side 12) (:knee-l :flex 60) (:thigh-r :flex -32 :side 14) (:knee-r :flex 22) (:arm-r :flex 62.5 :side 35.7 :twist -32.6) (:elbow-r :flex 110.5) (:hand-r :flex -153.9 :twist -33.9) (:arm-l :flex 8.2 :side -66.9 :twist 51.8) (:elbow-l :flex 73.9))
(defpose :br-sk-k1-sw3 (:base :lb-stance)   ; K1 the swing, the hit turned -36: muzzle (1.40 1.38 2.09) az 38.0 el 4.5
  (:root :yaw -14.32 :f 0.23 :u -0.12 :pitch 10) (:pelvis :twist 9.32) (:spine :flex 12) (:chest :twist 13) (:neck :twist -13) (:head :twist -2.2 :flex 2) (:thigh-l :flex 52 :side 12) (:knee-l :flex 60) (:thigh-r :flex -32 :side 14) (:knee-r :flex 22) (:arm-r :flex 62.5 :side 35.7 :twist -32.6) (:elbow-r :flex 110.5) (:hand-r :flex -153.9 :twist -33.9) (:arm-l :flex 8.2 :side -66.9 :twist 51.8) (:elbow-l :flex 73.9))
(defpose :br-sk-k1-thru1 (:base :lb-stance)   ; K1 the swing, the hit turned 44: muzzle (-1.69 1.26 1.98) az -39.9 el 2.0
  (:root :yaw 35.28 :f 0.29 :u -0.14 :pitch 10) (:pelvis :twist 19.72) (:spine :flex 12) (:chest :twist 33) (:neck :twist -13) (:head :twist -26.2 :flex 2) (:thigh-l :flex 52 :side 12) (:knee-l :flex 60) (:thigh-r :flex -32 :side 14) (:knee-r :flex 22) (:arm-r :flex 62.5 :side 35.7 :twist -32.6) (:elbow-r :flex 110.5) (:hand-r :flex -153.9 :twist -33.9) (:arm-l :flex 8.2 :side -66.9 :twist 51.8) (:elbow-l :flex 73.9))
(defpose :br-sk-k1-thru (:base :lb-stance)   ; K1 the swing, the hit turned 84: muzzle (-2.51 1.24 0.55) az -79.0 el 2.2
  (:root :yaw 60.08 :f 0.27 :u -0.17 :pitch 10) (:pelvis :twist 24.92) (:spine :flex 12) (:chest :twist 43) (:neck :twist -13) (:head :twist -38.2 :flex 2) (:thigh-l :flex 52 :side 12) (:knee-l :flex 60) (:thigh-r :flex -32 :side 14) (:knee-r :flex 22) (:arm-r :flex 62.5 :side 35.7 :twist -32.6) (:elbow-r :flex 110.5) (:hand-r :flex -153.9 :twist -33.9) (:arm-l :flex 8.2 :side -66.9 :twist 51.8) (:elbow-l :flex 73.9))
(defpose :br-sk-k2-up (:base :lb-stance)   ; K2 hauled over his left shoulder: muzzle (-0.91 2.84 -1.01) az -164.4 el 45.4, grip (-0.58 1.59 0.17)
  (:root :yaw 30 :f 0.12 :u 0 :pitch -2) (:pelvis :twist 22) (:spine :flex -4) (:chest :twist 40) (:neck :twist -30) (:head :twist -30 :flex 6) (:thigh-l :flex 52 :side 12) (:knee-l :flex 60) (:thigh-r :flex -32 :side 14) (:knee-r :flex 22) (:arm-r :flex 107.4 :side 18.7 :twist -63.8) (:elbow-r :flex 0) (:hand-r :flex -85.9 :twist 58.5) (:arm-l :flex 49.8 :side -97 :twist 4.3) (:elbow-l :flex 7.2))
(defpose :br-sk-k2-wind (:base :lb-stance)   ; K2 the wind-up: muzzle (-0.61 3.20 -0.97) az -172.1 el 53.6, grip (-0.47 1.80 0.06)
  (:root :yaw 30 :f 0.12 :u 0.08 :pitch -2) (:pelvis :twist 22) (:spine :flex -10) (:chest :twist 40) (:neck :twist -30) (:head :twist -30 :flex 6) (:thigh-l :flex 52 :side 12) (:knee-l :flex 60) (:thigh-r :flex -32 :side 14) (:knee-r :flex 22) (:arm-r :flex 119 :side 25.4 :twist -82.3) (:elbow-r :flex -0.1) (:hand-r :flex -86 :twist 47.8) (:arm-l :flex 40.5 :side -96.4 :twist 34.2) (:elbow-l :flex 36.7))
(defpose :br-sk-k2-sw1 (:base :lb-stance)   ; K2 the swing: muzzle (-1.83 2.29 0.87) az -79.9 el 27.7, grip (-0.31 1.47 0.59)
  (:root :yaw 20 :f 0.16 :u -0.02 :pitch 4) (:pelvis :twist 14) (:spine :flex 6) (:chest :twist 22) (:neck :twist -20) (:head :twist -20 :flex 4) (:thigh-r :flex 52 :side 12) (:knee-r :flex 60) (:thigh-l :flex -32 :side 14) (:knee-l :flex 22) (:arm-r :flex 75.7 :side -22 :twist 22.4) (:elbow-r :flex 90.4) (:hand-r :flex -131.4 :twist 19.3) (:arm-l :flex 14.4 :side -79.9 :twist 41.9) (:elbow-l :flex 57.9))
(defpose :br-sk-k2-sw2 (:base :lb-stance)   ; K2 the swing: muzzle (-1.14 1.57 2.15) az -41.1 el 5.7, grip (0.00 1.40 0.84)
  (:root :yaw 8 :f 0.2 :u -0.06 :pitch 8) (:pelvis :twist 4) (:spine :flex 10) (:chest :twist 6) (:neck :twist -7) (:head :twist -7 :flex 4) (:thigh-r :flex 52 :side 12) (:knee-r :flex 60) (:thigh-l :flex -32 :side 14) (:knee-l :flex 22) (:arm-r :flex 92.1 :side 1.2 :twist 3.2) (:elbow-r :flex 62.2) (:hand-r :flex -129.6 :twist 21.9) (:arm-l :flex 24 :side -104.2 :twist 22.8) (:elbow-l :flex 27.8))
(defpose :br-sk-k2-hit (:base :lb-stance)   ; K2 the hit: muzzle (0.01 0.92 2.50) az -8.6 el -6.7, grip (0.27 1.12 0.78)
  (:root :yaw -4 :f 0.26 :u -0.1 :pitch 12) (:pelvis :twist -6) (:spine :flex 14) (:chest :twist -10) (:neck :twist 6) (:head :twist 6 :flex 4) (:thigh-r :flex 52 :side 12) (:knee-r :flex 60) (:thigh-l :flex -32 :side 14) (:knee-l :flex 22) (:arm-r :flex 59 :side -24.1 :twist 33.9) (:elbow-r :flex 78.1) (:hand-r :flex -120.2 :twist 10.2) (:arm-l :flex 21.7 :side -52.4 :twist 42.5) (:elbow-l :flex 75))
(defpose :br-sk-k2-thru1 (:base :lb-stance)   ; K2 on through: muzzle (1.05 0.17 1.94) az 31.1 el -25.4, grip (0.24 0.92 0.59)
  (:root :yaw -16 :f 0.27 :u -0.14 :pitch 14) (:pelvis :twist -14) (:spine :flex 18) (:chest :twist -26) (:neck :twist 15) (:head :twist 15 :flex 4) (:thigh-r :flex 52 :side 12) (:knee-r :flex 60) (:thigh-l :flex -32 :side 14) (:knee-l :flex 22) (:arm-r :flex 19.7 :side -34.9 :twist 58.3) (:elbow-r :flex 73.7) (:hand-r :flex -104.2 :twist -26.6) (:arm-l :flex -27.6 :side -23.1 :twist 8.2) (:elbow-l :flex 128.7))
(defpose :br-sk-k2-thru (:base :lb-stance)   ; K2 down at his lower right: muzzle (1.58 0.08 1.43) az 43.4 el -31.5, grip (0.55 0.99 0.35)
  (:root :yaw -24 :f 0.28 :u -0.2 :pitch 18) (:pelvis :twist -18) (:spine :flex 22) (:chest :twist -36) (:neck :twist 20) (:head :twist 20 :flex 4) (:thigh-r :flex 52 :side 12) (:knee-r :flex 60) (:thigh-l :flex -32 :side 14) (:knee-l :flex 22) (:arm-r :flex 33.7 :side -19.2 :twist 18) (:elbow-r :flex 108.4) (:hand-r :flex -141.1 :twist 22.7) (:arm-l :flex 5 :side -46.1 :twist 46) (:elbow-l :flex 81.3))
(defpose :br-sk-k3-carry (:base :lb-stance)   ; K3 the turn, the rifle out: muzzle (2.14 1.10 0.71) az 82.1 el -5.9, grip (0.41 1.28 0.47)
  (:root :u -0.04) (:pelvis :side -16) (:spine :flex 4 :side -6) (:chest :twist -10) (:neck :twist 5) (:head :twist 5 :flex 4) (:thigh-r :flex 52 :side 12) (:knee-r :flex 60) (:thigh-l :flex -32 :side 14) (:knee-l :flex 22) (:arm-r :flex 62.8 :side 35.7 :twist -23.6) (:elbow-r :flex 80.3) (:hand-r :flex -140.5 :twist -74.8) (:arm-l :flex 28.8 :side -79.5 :twist 31.9) (:elbow-l :flex 42.8))
(defpose :br-sk-k3-rise (:base :lb-stance)   ; K3 the turn, rising: muzzle (1.58 2.79 0.61) az 80.7 el 40.0, grip (0.26 1.67 0.39)
  (:root :u 0.06) (:pelvis :side -24) (:spine :flex 4 :side -6) (:chest :twist -10) (:neck :twist 5) (:head :twist 5 :flex 4) (:thigh-r :flex 52 :side 12) (:knee-r :flex 60) (:thigh-l :flex -32 :side 14) (:knee-l :flex 22) (:arm-r :flex 130 :side 38.7 :twist 34.2) (:elbow-r :flex 30.7) (:hand-r :flex -147.1 :twist -67) (:arm-l :flex 65.6 :side -14 :twist 30.8) (:elbow-l :flex 101.9))
(defpose :br-sk-k3-top (:base :lb-stance)   ; K3 overhead: muzzle (0.10 3.76 0.37) az -2.6 el 82.3, grip (0.11 2.02 0.13)
  (:root :u 0.1 :pitch -8) (:pelvis :twist 0) (:spine :flex -8) (:chest :twist 0) (:neck :flex -10) (:head :flex -8) (:thigh-l :flex 20 :side 10) (:knee-l :flex 20) (:thigh-r :flex -10 :side 10) (:knee-r :flex 10) (:arm-r :flex 139.7 :side 14.2 :twist -4.7) (:elbow-r :flex 10.6) (:hand-r :flex -83.7 :twist -11.3) (:arm-l :flex 123.5 :side 34.1 :twist 22.3) (:elbow-l :flex 46.4))
(defpose :br-sk-k3-top2 (:base :lb-stance)   ; K3 arched back, held: muzzle (0.10 3.67 -0.44) az -180.0 el 74.0, grip (0.10 1.99 0.04)
  (:root :u 0.1 :pitch -14) (:pelvis :twist 0) (:spine :flex -14) (:chest :twist 0) (:neck :flex -10) (:head :flex -8) (:thigh-l :flex 20 :side 10) (:knee-l :flex 20) (:thigh-r :flex -10 :side 10) (:knee-r :flex 10) (:arm-r :flex 118.8 :side 20.7 :twist -4.8) (:elbow-r :flex 32.1) (:hand-r :flex -72.7 :twist -16.6) (:arm-l :flex 114 :side 37.2 :twist 28) (:elbow-l :flex 44.1))
(defpose :br-sk-k3-down (:base :lb-stance)   ; K3 coming down: muzzle (0.06 2.98 1.89) az -2.8 el 39.9, grip (0.13 1.86 0.55)
  (:root :f 0.16 :u 0 :pitch 4) (:spine :flex 4) (:thigh-l :flex 52 :side 12) (:knee-l :flex 60) (:thigh-r :flex -32 :side 14) (:knee-r :flex 22) (:arm-r :flex 154.1 :side 7.2 :twist -5) (:elbow-r :flex 5.3) (:hand-r :flex -111.3 :twist -7.9) (:arm-l :flex 141 :side 36.7 :twist 15.5) (:elbow-l :flex 42))
(defpose :br-sk-k3-hit (:base :lb-stance)   ; K3 the smash: muzzle (-0.00 1.29 2.60) az 0.3 el 3.7, grip (-0.01 1.18 0.85)
  (:root :f 0.3 :u -0.1 :pitch 16) (:spine :flex 18) (:chest :twist 4) (:neck :twist -2) (:head :twist -2 :flex 0) (:thigh-l :flex 52 :side 12) (:knee-l :flex 60) (:thigh-r :flex -32 :side 14) (:knee-r :flex 22) (:arm-r :flex 68.6 :side -25.5 :twist 43.4) (:elbow-r :flex 107.8) (:hand-r :flex -142.7 :twist -35.9) (:arm-l :flex 29.5 :side -36.4 :twist 63.9) (:elbow-l :flex 107))
(defpose :br-sk-k3-floor (:base :lb-stance)   ; K3 into the floor: muzzle (0.00 0.07 2.29) az -4.8 el -39.2, grip (0.11 1.18 0.93)
  (:root :f 0.3 :u -0.26 :pitch 24) (:spine :flex 28) (:chest :twist 4) (:neck :twist -2) (:head :twist -2 :flex 6) (:thigh-l :flex 52 :side 12) (:knee-l :flex 60) (:thigh-r :flex -32 :side 14) (:knee-r :flex 22) (:arm-r :flex 133.3 :side 5.7 :twist -2.3) (:elbow-r :flex 95.4) (:hand-r :flex -216.7 :twist -14.2) (:arm-l :flex 153.4 :side 39.3 :twist 20.7) (:elbow-l :flex 73.3))
(defpose :br-pl-brace (:base :br-pl-aim)   ; L 蓄力狙擊: shouldered, braced low, the cheek on the stock: muzzle (-0.01 1.30 2.10) az -3.2 el 0.0, grip (0.09 1.31 0.35)
  (:root :u -0.14) (:head :flex 10 :twist 16) (:thigh-r :flex -16 :side 12) (:knee-r :flex 30) (:thigh-l :flex 34 :side 10) (:knee-l :flex 44))
(defpose :br-pl-brace-kick (:base :br-pl-kick)   ; its recoil: muzzle (0.01 1.69 1.90) az -3.2 el 12.0, grip (0.11 1.33 0.19)
  (:root :f -0.1 :u -0.14) (:head :flex 10 :twist 16) (:thigh-r :flex -16 :side 12) (:knee-r :flex 30) (:thigh-l :flex 34 :side 10) (:knee-l :flex 44))
;; the base form's J3 銃口突 JUKO-TSUKI (R16, DUEL_LILLE_V3 §20, the user 2026-10-12: 「普通攻擊的 J3 幫我插入更多關鍵幀並放慢
;; 一些速度」; its own clip: Lille's :lb-jab stays the old Lille's): the muzzle cross jabbed up into his face, in the base form's
;; big readable style: drawn back low over 8 f (the weight on the back foot, the rifle dipped and pulled in, the free hand
;; up), a held beat, then the whole body driven into the thrust (stretched, *BR-SQUASH*), the hit S 10 (the muzzle as
;; :lb-jab-hit's, its reach 1.6 m: the host FK test), held through A, the recoil rocking him back, the rifle let down
(defpose :br-jab-back (:base :lb-stance)   ; drawn back, the weight on the back foot, the rifle dipped and pulled in: muzzle (0.02 0.56 1.53) el -8
  (:root :f -0.14 :u -0.1 :pitch -4) (:pelvis :twist 8) (:spine :flex -4) (:chest :twist -6) (:neck :twist 6) (:head :twist 6 :flex 6)
  (:arm-r :flex -38.5 :side -14.6 :twist -1.6) (:elbow-r :flex 65.9) (:hand-r :flex -43 :twist -2.2) (:arm-l :flex 46 :side 10) (:elbow-l :flex 96) (:hand-l :flex -30)
  (:thigh-r :flex 24 :side 6) (:knee-r :flex 46) (:thigh-l :flex -8 :side 6) (:knee-l :flex 28))
(defpose :br-jab-hit (:base :lb-jab-hit)   ; the thrust, the body driven in behind it: muzzle (-0.09 2.10 1.63) az -9.6 el 45.3 (reach 1.6)
  (:root :f 0.04 :u -0.08 :pitch 6) (:spine :flex 6) (:chest :twist 10) (:neck :twist -6) (:head :twist -6 :flex -6)
  (:arm-r :flex 2.5 :side -2.4 :twist -9) (:elbow-r :flex 70.3) (:hand-r :flex -15.2 :twist 1)
  (:arm-l :flex 30 :side 30) (:elbow-l :flex 60) (:thigh-r :flex -16 :side 6) (:knee-r :flex 10) (:thigh-l :flex 40 :side 6) (:knee-l :flex 44))
(defstrike :br-jab (10 3 18 :base :lb-stance)
  (0)
  (3 (:root :f -0.05 :u -0.05) (:chest :twist -2) (:arm-r :flex -6 :side 2) (:elbow-r :flex 62) (:hand-r :flex -56) (:arm-l :flex 44) (:elbow-l :flex 80)
   (:thigh-r :flex 10) (:knee-r :flex 20))   ; (the weight going back)
  (6 :br-jab-back)
  (8 :br-jab-back (:root :f -0.16 :u -0.12) (:chest :twist -8) (:hand-r :flex -47))   ; (held: a touch further, the breath)
  (9 :snap :br-jab-back (:root :f -0.04 :u -0.1 :pitch 2) (:chest :twist 2) (:spine :flex 2) (:arm-r :flex -18 :side -8 :twist -5) (:elbow-r :flex 70)
   (:hand-r :flex -30 :twist 0) (:thigh-r :flex 6) (:knee-r :flex 26) (:thigh-l :flex 20) (:knee-l :flex 34))   ; (driven off the back foot)
  (:s :snap :br-jab-hit)
  (12 :br-jab-hit (:root :f 0.05 :u -0.09 :pitch 7)) (:a :br-jab-hit (:root :f 0.05 :u -0.1 :pitch 6))
  (16 :br-jab-hit (:root :f -0.02 :u -0.08 :pitch 0) (:spine :flex 0) (:chest :twist 0) (:arm-r :flex 10 :side 4 :twist -4) (:elbow-r :flex 62) (:hand-r :flex -38)
   (:arm-l :flex 40 :side 14) (:elbow-l :flex 76))   ; (the recoil rocks him back)
  (21 :lb-stance (:root :f -0.03 :u -0.06) (:arm-r :flex 16) (:elbow-r :flex 60) (:hand-r :flex -70))   ; (the rifle let down)
  (26 :lb-stance (:root :u -0.04)) (:end :lb-stance))
;; ---------------------------------------------------------------- the base form's attack-state K string, bold (K1-K3)
;; The user 2026-10-12: 「將常態的普攻 K 動作模組改的更加明顯大膽」: :br-k1 / :br-k2 / :br-k3 (and the copy :br-k2s) play
;; their own clips (the old Lille's :lb-f1 / -f2 / -f3 stay his), the same three ideas exaggerated in the stance clips'
;; style (bigger wind-ups held a beat, the body thrown round, the weight shifted onto a stepped foot, a held impact, a long
;; follow-through, the squash and stretch *BR-SQUASH*). Each at its move's own frames (S A R after decision V8, played at
;; speed 1: :clip-s = S); K2 / K3 are links, entered on their frame 7 / 8 (:enter) from the pose the link before holds at
;; its S + A (the chain opens there on a hit), so their first keys repeat it. On every hit frame Diagramm's muzzle (1.75 m
;; down the barrel) is at the move's reach, his arc's edge (the host FK test, +-0.15 m: drawn reach = hit reach); the
;; keys' comments give it as (x his right, y up, f ahead) and the barrel's azimuth (+ = his right) / elevation.
;; - K1 銃身薙ぎ JUSHIN-NAGI, one hand: the weight dropped and the rifle carried across to his left (f3), wound far round
;;   (f7: the body turned 130 deg away from him, Diagramm laid back behind his left hip, the head over the right shoulder,
;;   the free arm tucked), a moving hold sinking into the squat tell (f10-14), then the spin back: a key a frame (~30 deg)
;;   through f15-18, the hit S 19 at his waist (the free arm flung out wide, the right foot stepped through into a lunge),
;;   swept on 20 deg a frame through the active frames to his right (az +74 at f23), carried round behind his right side
;;   (f27), held there sinking (f31), turned back to the front.
;; - K2 振り下ろし FURIOROSHI, two hands (*GRIP-CLIPS*): from K1's sweep end (f7) hauled up on his right (f11), overhead
;;   and back (f15: the barrel down his back, the column arched, the left knee drawn up high, stretched tall), a moving
;;   hold arching further (f19), the chop snapped down (f20 straight up, f21 forward), the hit S 22 at his middle, the arms
;;   still high, the left foot stamped down into a wide lunge, squashed flat, on down through the active frames with the
;;   body jackknifing over it, into the floor (f28), held there (f28-33), let up.
;; - K3 零距離 REI-KYORI: from K2's chop (f8) drawn back to the right hip, the left hand forward on the barrel, the whole
;;   body coiled back and down onto the right leg (f11-15, held sinking to f18), driven forward (f20, f22) into a long lunge,
;;   the muzzle pressed into his chest at S 23 and fired, the kick the next frame (+31 deg, the free hand flung off, the
;;   head thrown back), blown back upright with Diagramm high (f27), held (f27-34), let down.
(defpose :br-f1-load (:base :lb-stance)   ; K1 the weight dropped, Diagramm carried across to his left: muzzle (-1.77 0.98 1.08) az -62.7 el 0.9
  (:root :yaw 30 :u -0.08) (:chest :twist 10) (:neck :twist -16) (:head :twist -14) (:arm-l :flex 50 :side 0)
  (:elbow-l :flex 96) (:thigh-r :flex 14 :side 6) (:knee-r :flex 38) (:thigh-l :flex 18 :side 6) (:knee-l :flex 39)
  (:arm-r :flex 15.3 :side -14.3 :twist 10.5) (:elbow-r :flex 62.8) (:hand-r :flex -77.7 :twist 0.89))
(defpose :br-f1-coil (:base :lb-stance)   ; K1 wound round, laid back behind his left hip: muzzle (-0.22 1.03 -1.90) az 179.4 el 4.2
  (:root :yaw 95 :f -0.06 :u -0.14 :pitch -4) (:pelvis :twist 10) (:spine :flex 2 :side -8) (:chest :twist 35)
  (:neck :twist -45) (:head :twist -40 :flex 6) (:arm-l :flex 60 :side -10) (:elbow-l :flex 110) (:hand-l :flex -20)
  (:thigh-r :flex -6 :side 16) (:knee-r :flex 34) (:thigh-l :flex 33 :side 14) (:knee-l :flex 47)
  (:arm-r :flex 17.1 :side 8.2 :twist 37.8) (:elbow-r :flex 66.5) (:hand-r :flex -77.6 :twist 3.3))
(defpose :br-f1-hit (:base :lb-stance)   ; K1 the sweep at his waist (reach 2.05): muzzle (-0.20 0.94 2.06) az -14.0 el -0.2
  (:root :yaw 12 :f 0.18 :u -0.22 :pitch 10) (:pelvis :twist -6) (:spine :flex 10) (:chest :twist 4) (:neck :twist -10)
  (:head :twist -10 :flex 2) (:arm-l :flex 20 :side 75) (:elbow-l :flex 15) (:hand-l :flex -10)
  (:thigh-r :flex 50 :side 12) (:knee-r :flex 74) (:thigh-l :flex -26 :side 16) (:knee-l :flex 1)
  (:arm-r :flex -42.7 :side 14.2 :twist -2.2) (:elbow-r :flex 140.8) (:hand-r :flex -77.9 :twist 0.23))
(defpose :br-f1-thru (:base :lb-stance)   ; K1 carried round behind his right side: muzzle (1.91 1.21 -1.19) az 115.6 el 10.0
  (:root :yaw -95 :f 0.2 :u -0.12 :pitch 8) (:pelvis :twist -10) (:spine :flex 8 :side 6) (:chest :twist -20)
  (:neck :twist 40) (:head :twist 40 :flex 2) (:arm-l :flex 70 :side 40) (:elbow-l :flex 20) (:hand-l :flex -10)
  (:thigh-r :flex 40 :side 12) (:knee-r :flex 40) (:thigh-l :flex -11 :side 16) (:knee-l :flex 8)
  (:arm-r :flex 16.4 :side 8.2 :twist 1.87) (:elbow-r :flex 65.4) (:hand-r :flex -57.1 :twist 0.47))
(defstrike :br-f1 (19 4 23 :base :lb-stance)
  (0) (3 :br-f1-load) (7 :br-f1-coil)
  (10 :br-f1-coil (:root :yaw 100 :u -0.17) (:chest :twist 39))   ; (a touch further, sinking)
  (13 :br-f1-coil (:root :yaw 104 :u -0.22 :pitch -2) (:chest :twist 42) (:knee-l :flex 68) (:knee-r :flex 30))   ; (the squat tell)
  (14 :br-f1-coil (:root :yaw 104 :u -0.22 :pitch -2) (:chest :twist 42) (:knee-l :flex 68) (:knee-r :flex 30))
  (15 :snap :br-f1-hit (:root :yaw 120 :f 0.0 :u -0.17)) (16 :snap :br-f1-hit (:root :yaw 86 :f 0.06 :u -0.19))   ; (the spin back,
  (17 :snap :br-f1-hit (:root :yaw 56 :f 0.11 :u -0.21)) (18 :snap :br-f1-hit (:root :yaw 32 :f 0.15))           ;  stepping through)
  (:s :snap :br-f1-hit)
  (20 :snap :br-f1-hit (:root :yaw -8)) (21 :snap :br-f1-hit (:root :yaw -28)) (22 :snap :br-f1-hit (:root :yaw -48))   ; (swept on,
  (:a :snap :br-f1-hit (:root :yaw -68))                                                                                ;  az +74)
  (27 :br-f1-thru) (31 :br-f1-thru (:root :yaw -100 :u -0.15))   ; (carried round, held sinking)
  (37 :lb-stance (:root :yaw -40 :u -0.1) (:arm-r :flex 20) (:elbow-r :flex 70) (:hand-r :flex -80))
  (42 :lb-stance (:root :yaw -6 :u -0.05)) (:end :lb-stance))
(defpose :br-f2-lift (:base :lb-stance)   ; K2 hauled up on his right: muzzle (1.60 2.95 0.77) az 70.1 el 50.0
  (:root :yaw -35 :f 0.16 :u -0.04 :pitch 2) (:pelvis :twist -8) (:spine :flex 2 :side 6) (:chest :twist -16)
  (:neck :twist 20) (:head :twist 20) (:thigh-r :flex 14 :side 12) (:knee-r :flex 16) (:thigh-l :flex -2 :side 14)
  (:knee-l :flex 0) (:arm-l :flex 110 :side 20) (:elbow-l :flex 40) (:arm-r :flex 110.4 :side 29 :twist -0.91)
  (:elbow-r :flex 29.4) (:hand-r :flex -96.2 :twist -34))
(defpose :br-f2-top (:base :lb-stance)   ; K2 overhead, the barrel down his back, the left knee drawn up: muzzle (0.06 3.20 -1.23) az -179.8 el 44.9
  (:root :f -0.08 :u 0.04 :pitch -10) (:pelvis :twist 0) (:spine :flex -12) (:chest :flex -6 :twist 0)
  (:neck :flex -6 :twist 0) (:head :flex -8 :twist 0) (:thigh-l :flex 75 :side 6) (:knee-l :flex 85)
  (:thigh-r :flex -4 :side 8) (:knee-r :flex 6) (:arm-l :flex 150 :side 20) (:elbow-l :flex 40)
  (:arm-r :flex 127.7 :side 23.4 :twist -6) (:elbow-r :flex 6.3) (:hand-r :flex -24.8 :twist -16.4))
(defpose :br-f2-top2 (:base :lb-stance)   ; K2 arched further, held: muzzle (0.08 2.90 -1.50) az -178.4 el 32.8
  (:root :f -0.1 :u 0.05 :pitch -14) (:pelvis :twist 0) (:spine :flex -16) (:chest :flex -8 :twist 0)
  (:neck :flex -8 :twist 0) (:head :flex -10 :twist 0) (:thigh-l :flex 78 :side 6) (:knee-l :flex 88)
  (:thigh-r :flex -7 :side 8) (:knee-r :flex 6) (:arm-l :flex 150 :side 20) (:elbow-l :flex 40)
  (:arm-r :flex 112.2 :side 22 :twist -5.1) (:elbow-r :flex 8.8) (:hand-r :flex -10.5 :twist -14.2))
(defpose :br-f2-up (:base :lb-stance)   ; K2 the chop, straight up: muzzle (0.13 3.70 0.45) az 0.0 el 80.4
  (:root :f 0 :u 0.02 :pitch -2) (:pelvis :twist 0) (:spine :flex -4) (:chest :twist 0) (:neck :twist 0) (:head :twist 0)
  (:thigh-l :flex 45 :side 6) (:knee-l :flex 55) (:thigh-r :flex -6 :side 8) (:knee-r :flex 0) (:arm-l :flex 150 :side 20)
  (:elbow-l :flex 40) (:arm-r :flex 156.5 :side 10.4 :twist -2.4) (:elbow-r :flex 5.4) (:hand-r :flex -87.3 :twist -9.7))
(defpose :br-f2-down (:base :lb-stance)   ; K2 the chop, coming down: muzzle (0.03 2.97 1.75) az -0.3 el 42.0
  (:root :f 0.14 :u -0.08 :pitch 8) (:pelvis :twist 0) (:spine :flex 10) (:chest :twist 0) (:neck :twist 0)
  (:head :twist 0) (:thigh-l :flex 52 :side 8) (:knee-l :flex 58) (:thigh-r :flex -6 :side 10) (:knee-r :flex 7)
  (:arm-l :flex 120 :side 0) (:elbow-l :flex 30) (:arm-r :flex 175.1 :side 19.7 :twist -0.24) (:elbow-r :flex 13.2)
  (:hand-r :flex -129.7 :twist -16.8))
(defpose :br-f2-hit (:base :lb-stance)   ; K2 the hit, the arms high, stamped into a wide lunge (reach 2.05): muzzle (0.00 1.09 2.06) az -1.4 el -17.4
  (:root :f 0.05 :u -0.2 :pitch 4) (:pelvis :twist 0) (:spine :flex 6) (:chest :twist 0) (:neck :flex -4 :twist 0)
  (:head :flex 0 :twist 0) (:thigh-l :flex 54 :side 10) (:knee-l :flex 61) (:thigh-r :flex -27 :side 12) (:knee-r :flex 8)
  (:arm-l :flex 130 :side -10) (:elbow-l :flex 20) (:arm-r :flex 150.4 :side 21.6 :twist 0.05) (:elbow-r :flex 18.3)
  (:hand-r :flex -175.1 :twist 4))
(defpose :br-f2-a (:base :lb-stance)   ; K2 on down, jackknifed over it (the active frames' end): muzzle (-0.01 0.16 2.02) az -0.4 el -45.3
  (:root :f 0.2 :u -0.24 :pitch 14) (:pelvis :twist 0) (:spine :flex 20) (:chest :twist 0) (:neck :flex -10 :twist 0)
  (:head :flex -4 :twist 0) (:thigh-l :flex 60 :side 10) (:knee-l :flex 79) (:thigh-r :flex -19 :side 12)
  (:knee-r :flex 12) (:arm-l :flex 90 :side -10) (:elbow-l :flex 20) (:arm-r :flex 154.1 :side 26.6 :twist -1.66)
  (:elbow-r :flex 21.6) (:hand-r :flex -185.8 :twist 3.6))
(defpose :br-f2-floor (:base :lb-stance)   ; K2 into the floor: muzzle (0.01 0.03 1.96) az 0.0 el -50.1
  (:root :f 0.24 :u -0.28 :pitch 18) (:pelvis :twist 0) (:spine :flex 26) (:chest :twist 0) (:neck :flex -12 :twist 0)
  (:head :flex -2 :twist 0) (:thigh-l :flex 62 :side 10) (:knee-l :flex 88) (:thigh-r :flex -19 :side 12)
  (:knee-r :flex 12) (:arm-l :flex 80 :side -10) (:elbow-l :flex 20) (:arm-r :flex 168.1 :side 25 :twist -0.51)
  (:elbow-r :flex 24.6) (:hand-r :flex -198.2 :twist 2))
(defstrike :br-f2 (22 4 26 :base :lb-stance)
  (0 :br-f1-hit (:root :yaw -68)) (7 :br-f1-hit (:root :yaw -68))   ; (K1's S + A: the link's first frame)
  (11 :br-f2-lift) (15 :br-f2-top) (19 :br-f2-top2)   ; (hauled up, overhead, arched further: held)
  (20 :snap :br-f2-up) (21 :snap :br-f2-down) (:s :snap :br-f2-hit) (:a :snap :br-f2-a)
  (28 :snap :br-f2-floor) (33 :br-f2-floor (:root :u -0.24) (:spine :flex 26))   ; (into the floor, held)
  (40 :lb-stance (:root :f 0.1 :u -0.12 :pitch 8) (:spine :flex 12) (:thigh-l :flex 30 :side 8) (:knee-l :flex 36))
  (46 :lb-stance (:root :u -0.05)) (:end :lb-stance))
(defpose :br-f3-draw (:base :lb-stance)   ; K3 drawn back to the right hip, sitting back: muzzle (0.24 1.03 1.53) az -4.4 el 5.9
  (:root :yaw -20 :f -0.22 :u -0.26 :pitch -6) (:pelvis :twist -6) (:spine :flex -2) (:chest :twist -25) (:neck :twist 25)
  (:head :twist 22 :flex 6) (:thigh-r :flex 50 :side 10) (:knee-r :flex 79) (:thigh-l :flex 45 :side 12) (:knee-l :flex 22)
  (:arm-r :flex 16.2 :side 10.1 :twist 0.54) (:elbow-r :flex 73) (:hand-r :flex -77 :twist 53.9)
  (:arm-l :flex 59.3 :side -20.2 :twist 0.04) (:elbow-l :flex 3.1))
(defpose :br-f3-coil (:base :lb-stance)   ; K3 coiled back and down on the right leg: muzzle (0.21 1.00 1.39) az -4.0 el 6.8
  (:root :yaw -24 :f -0.28 :u -0.32 :pitch -6) (:pelvis :twist -6) (:spine :flex -4) (:chest :twist -32) (:neck :twist 30)
  (:head :twist 26 :flex 6) (:thigh-r :flex 55 :side 10) (:knee-r :flex 92) (:thigh-l :flex 49 :side 12) (:knee-l :flex 17)
  (:arm-r :flex 15.5 :side 10.4 :twist -0.24) (:elbow-r :flex 74.3) (:hand-r :flex -71.7 :twist 64.7)
  (:arm-l :flex 56.9 :side -14.9 :twist 0.02) (:elbow-l :flex 3.2))
(defpose :br-f3-drive (:base :lb-stance)   ; K3 driven forward: muzzle (0.26 0.92 2.05) az -2.0 el 2.2
  (:root :yaw -8 :f 0.05 :u -0.18 :pitch 4) (:pelvis :twist -2) (:spine :flex 6) (:chest :twist -12) (:neck :twist 10)
  (:head :twist 10 :flex 6) (:thigh-r :flex 8 :side 10) (:knee-r :flex 52) (:thigh-l :flex 51 :side 12) (:knee-l :flex 44)
  (:arm-r :flex 15.6 :side 12.1 :twist 20.4) (:elbow-r :flex 79.2) (:hand-r :flex -77.1 :twist 0.11)
  (:arm-l :flex 68.8 :side -43.3 :twist -0.01) (:elbow-l :flex 2.7))
(defpose :br-f3-hit (:base :lb-stance)   ; K3 pressed in and fired, the long lunge (reach 2.15): muzzle (0.03 1.15 2.18) az -0.0 el 5.5
  (:root :yaw 0 :f 0.22 :u -0.16 :pitch 12) (:pelvis :twist 4) (:spine :flex 8) (:chest :twist -6) (:neck :flex -6 :twist 6)
  (:head :flex 10 :twist 6) (:thigh-l :flex 53 :side 10) (:knee-l :flex 55) (:thigh-r :flex -18 :side 12) (:knee-r :flex 1)
  (:arm-r :flex -21.6 :side -24.5 :twist 19.5) (:elbow-r :flex 120.5) (:hand-r :flex -77.2 :twist -2.3)
  (:arm-l :flex 70.7 :side -95.3 :twist -0.03) (:elbow-l :flex 3.4))
(defpose :br-f3-kick (:base :lb-stance)   ; K3 the kick: muzzle (0.06 1.94 2.07) az -0.1 el 30.1
  (:root :yaw 0 :f 0.24 :u -0.14 :pitch 0) (:pelvis :twist 4) (:spine :flex 0) (:chest :flex -10 :twist -6)
  (:neck :flex -16 :twist 6) (:head :flex -10 :twist 6) (:thigh-l :flex 39 :side 10) (:knee-l :flex 48)
  (:thigh-r :flex -27 :side 12) (:knee-r :flex 1) (:arm-l :flex 100 :side 50) (:elbow-l :flex 30)
  (:arm-r :flex 4.5 :side -22 :twist 11.5) (:elbow-r :flex 93) (:hand-r :flex -79.7 :twist -1.64))
(defpose :br-f3-blown (:base :lb-stance)   ; K3 blown back upright, Diagramm high: muzzle (0.04 2.42 1.38) az 0.0 el 52.2
  (:root :yaw 0 :f 0.04 :u -0.12 :pitch -8) (:pelvis :twist 4) (:spine :flex -10) (:chest :flex -12 :twist -6)
  (:neck :flex -14 :twist 6) (:head :flex -10 :twist 6) (:thigh-l :flex 28 :side 10) (:knee-l :flex 32)
  (:thigh-r :flex -18 :side 12) (:knee-r :flex 23) (:arm-l :flex 120 :side 60) (:elbow-l :flex 20)
  (:arm-r :flex -5 :side -24.6 :twist -1.25) (:elbow-r :flex 72.9) (:hand-r :flex -48.4 :twist 12.7))
(defstrike :br-f3 (23 5 36 :base :lb-stance)
  (0 :br-f2-a) (8 :br-f2-a)   ; (K2's S + A: the link's first frame)
  (11 :br-f3-draw) (15 :br-f3-coil) (18 :br-f3-coil (:root :f -0.27 :u -0.27))   ; (drawn back, coiled, held sinking)
  (20 :snap :br-f3-drive) (22 :snap :br-f3-hit (:root :f 0.16 :u -0.17 :pitch 10)) (:s :snap :br-f3-hit)
  (24 :snap :br-f3-kick) (27 :br-f3-blown) (:a :br-f3-blown (:root :f 0.02))   ; (the kick, blown back)
  (34 :br-f3-blown (:root :f 0.0 :u -0.13) (:spine :flex -8))   ; (held)
  (42 :lb-stance (:root :u -0.1) (:arm-r :flex 30) (:elbow-r :flex 70) (:hand-r :flex -90))
  (52 :lb-stance (:root :u -0.05)) (:end :lb-stance))
(pushnew :br-f2 *grip-clips*)   ; (K2 two-handed: the left fist on the handle, GRIP-LEFT!)
;; L 蓄力狙擊 (R15): the charge, held (the move's :clip, at speed 1 up to *BR-W-L-HOLD* 60 f): shouldered by f5, settled and
;; braced by f9, then breathing on the aim, a little lower every beat (the level's coil on top: BR-DEFORM) ...
(defstrike :br-sk-lc (8 2 50 :base :lb-kamae-pose)
  (0) (5 :br-pl-aim (:root :u -0.08) (:head :flex 8)) (9 :br-pl-brace)
  (20 :br-pl-brace (:root :u -0.15) (:head :flex 11)) (30 :br-pl-brace (:root :u -0.14))
  (40 :br-pl-brace (:root :u -0.16) (:head :flex 11)) (50 :br-pl-brace (:root :u -0.15)) (:end :br-pl-brace (:root :u -0.17) (:head :flex 11)))
;; ... and the shot on the release (the move's :clip-2 from the braced aim; level 2 / 3 the same clip): still on the line,
;; the crack f8, the kick (+12 deg, rocked back), back on the line (the level's push back on top: BR-DEFORM)
(defstrike :br-sk-l1 (8 2 14 :base :lb-kamae-pose)
  (0 :br-pl-brace) (5 :br-pl-brace (:head :flex 11)) (:s :br-pl-brace) (:a :snap :br-pl-brace-kick)
  (16 :br-pl-brace (:root :f -0.04 :u -0.12)) (:end :lb-stance))
;; ... level 1's shot (R16, DUEL_LILLE_V3 §20, the user 2026-10-12: 「增加第 1 階 L 射擊的前搖」: its startup 8 -> 16, the
;; move's :clip-2; levels 2 / 3 keep :br-sk-l1 at 8): a real wind-up from the braced aim (f0 the charge's settled pose):
;; settled back into it, the muzzle dipping a touch as the stock is worked into the shoulder and the cheek laid down on it
;; (f2-4), back on the line (f6), the breath drawn in (risen, stretched, f8) and let out (sunk, squashed, f11), held still
;; (f13), the squeeze (tightened, the left hand clamping the barrel, f15; %BR-SNIPE-LOOK's glint flares), the crack f16 on
;; the line, the kick snapped up the next frame (+12 deg), rocked back, back on the line, let down; the rifle stays on his
;; line through the wind-up (the body moves round it: the root, the knees, the head, the squash)
(defstrike :br-sk-l1s (16 2 14 :base :lb-kamae-pose)
  (0 :br-pl-brace)
  (2 :br-pl-brace (:root :f -0.05 :u -0.17) (:head :flex 12 :twist 17) (:hand-r :flex -150) (:knee-r :flex 36) (:knee-l :flex 50))   ; (settled back, the muzzle dipped)
  (4 :br-pl-brace (:root :f -0.06 :u -0.19) (:head :flex 14 :twist 18) (:hand-r :flex -149) (:knee-r :flex 38) (:knee-l :flex 53))   ; (the stock in, the cheek down)
  (6 :br-pl-brace (:root :f -0.05 :u -0.17) (:head :flex 13 :twist 17) (:knee-r :flex 35) (:knee-l :flex 49))   ; (back on the line)
  (8 :br-pl-brace (:root :f -0.04 :u -0.11) (:head :flex 10) (:knee-r :flex 27) (:knee-l :flex 40))   ; (the breath in: risen)
  (11 :br-pl-brace (:root :f -0.05 :u -0.2) (:head :flex 13) (:knee-r :flex 37) (:knee-l :flex 52))   ; (let out: sunk, still)
  (13 :br-pl-brace (:root :f -0.05 :u -0.2) (:head :flex 13) (:knee-r :flex 37) (:knee-l :flex 52))   ; (held)
  (15 :br-pl-brace (:root :f -0.05 :u -0.21) (:head :flex 14) (:elbow-l :flex 26) (:knee-r :flex 38) (:knee-l :flex 54))   ; (the squeeze: tightened)
  (:s :br-pl-brace (:root :f -0.05 :u -0.21) (:head :flex 14) (:elbow-l :flex 26) (:knee-r :flex 38) (:knee-l :flex 54))
  (17 :snap :br-pl-brace-kick) (:a :br-pl-brace-kick (:root :f -0.12 :u -0.13))
  (21 :br-pl-brace-kick (:root :f -0.08 :u -0.13) (:arm-r :flex 58)) (24 :br-pl-brace (:root :f -0.04 :u -0.12))
  (28 :lb-kamae-pose (:root :u -0.08)) (:end :lb-stance))
;; J 槍鬥術 (R15): the gun-kata, one hand. R16 (DUEL_LILLE_V3 §20, the user 2026-10-12: 「架勢 J 的槍鬥術跟普通攻擊的 J3 幫我插入
;; 更多關鍵幀並放慢一些速度」): at S 10, R 14 / 14 / 16, with in-betweens through every turn (a key a frame through the spins,
;; ~90 deg apart), a moving hold on each wind-up, the hips leading and the rifle and the free arm trailing (overlap), and a
;; settle after each shot; the hit poses and their muzzle (*BR-W-TIPS* "BR-S" 1.9 m) unchanged
(defstrike :br-sk-j1 (10 2 14 :base :lb-kamae-pose)   ; J1: coiled left, one spin right with the rifle flung out, the hip shot f10 in a lunge
  (0)
  (2 :br-sj-hip (:root :yaw 14 :f -0.02 :u -0.1 :pitch 2) (:pelvis :twist 12) (:spine :flex 6) (:chest :twist 8) (:neck :twist 2) (:head :twist 2)
   (:arm-r :flex 40 :side -24 :twist 0) (:elbow-r :flex 104) (:hand-r :flex -76 :twist 0) (:arm-l :flex 24 :side 16) (:elbow-l :flex 80)
   (:thigh-r :flex 16) (:knee-r :flex 40) (:thigh-l :flex 2) (:knee-l :flex 34))   ; (the weight drops, the rifle drawn in)
  (4 :br-sj-hip (:root :yaw 40 :f -0.02 :u -0.25 :pitch 2) (:pelvis :twist 30) (:chest :twist 26) (:neck :twist 10) (:head :twist 10)
   (:arm-r :flex 62 :side -46 :twist 0) (:elbow-r :flex 118) (:hand-r :flex -84 :twist 0) (:arm-l :flex 34 :side 22) (:elbow-l :flex 96)
   (:thigh-r :flex 30) (:knee-r :flex 70) (:thigh-l :flex 10) (:knee-l :flex 56))   ; (coiled left)
  (5 :br-sj-hip (:root :yaw 46 :f -0.02 :u -0.27 :pitch 2) (:pelvis :twist 32) (:chest :twist 30) (:neck :twist 12) (:head :twist 12)
   (:arm-r :flex 64 :side -48 :twist 0) (:elbow-r :flex 122) (:hand-r :flex -86 :twist 0) (:arm-l :flex 36 :side 22) (:elbow-l :flex 100)
   (:thigh-r :flex 32) (:knee-r :flex 72) (:thigh-l :flex 10) (:knee-l :flex 58))   ; (held: a touch further)
  (6 :snap :br-sj-hip (:root :yaw 12 :f 0 :u -0.16 :pitch 0) (:pelvis :twist 8) (:chest :twist 30) (:neck :twist 14) (:head :twist 14)
   (:arm-r :flex 46 :side 4 :twist 0) (:elbow-r :flex 86) (:hand-r :flex -88 :twist 0) (:arm-l :flex 30 :side 22) (:elbow-l :flex 96)
   (:thigh-r :flex 24) (:knee-r :flex 52) (:thigh-l :flex 6) (:knee-l :flex 40))   ; (the hips lead out of it, the rifle still in)
  (7 :snap :br-sj-hip (:root :yaw -76 :f 0.04 :u -0.07 :pitch 0) (:chest :twist 18) (:neck :twist 4) (:head :twist 4)
   (:arm-r :flex 12 :side 84 :twist 0) (:elbow-r :flex 16) (:hand-r :flex -92 :twist 0) (:arm-l :flex 20 :side 24) (:elbow-l :flex 76)
   (:thigh-r :flex 18) (:knee-r :flex 32) (:thigh-l :flex 2) (:knee-l :flex 30))   ; (flung out)
  (8 :snap :br-sj-hip (:root :yaw -170 :f 0.08 :u -0.04 :pitch 0) (:chest :twist 8) (:neck :twist -4) (:head :twist -4)
   (:arm-r :flex 5 :side 88 :twist 0) (:elbow-r :flex 6) (:hand-r :flex -92 :twist 0) (:arm-l :flex 12 :side 30) (:elbow-l :flex 62)
   (:thigh-r :flex 26) (:knee-r :flex 36) (:thigh-l :flex -6) (:knee-l :flex 26))   ; (at arm's length, the spin's top)
  (9 :snap :br-sj-hip (:root :yaw -270 :f 0.13 :u -0.09 :pitch 4) (:arm-r :flex -14 :side 46) (:elbow-r :flex 50) (:hand-r :flex -56)
   (:arm-l :flex -20 :side 50) (:elbow-l :flex 34) (:thigh-r :flex 40) (:knee-r :flex 56))   ; (drawn in to the hip, the free arm flung back)
  (:s :snap :br-sj-hip (:root :yaw -360)) (11 :snap :br-sj-hip-kick (:root :yaw -360)) (:a :br-sj-hip (:root :yaw -360 :f 0.16))
  (12.5 :br-sj-hip (:root :yaw -360 :f 0.16)) (12.5001 :snap :br-sj-hip (:root :f 0.16))   ; (the turn wound back to 0 between samples)
  (15 :br-sj-hip (:root :f 0.17 :u -0.19) (:chest :twist 2) (:arm-l :flex -60 :side 56) (:elbow-l :flex 22)
   (:arm-r :flex -34 :side -58 :twist -57.8) (:elbow-r :flex 94) (:hand-r :flex -10 :twist 20))   ; (settled into the lunge, the free arm on)
  (19 :br-sj-hip (:root :f 0.1 :u -0.13) (:arm-l :flex -30 :side 40) (:elbow-l :flex 40))
  (23 :lb-stance (:root :f 0.03 :u -0.06) (:arm-l :flex 30 :side 8) (:elbow-l :flex 66)) (:end :lb-stance))
(defstrike :br-sk-j2 (10 2 14 :base :lb-kamae-pose)   ; J2: pivoted, the rifle snapped upright, half a turn on, the back shot f10, the leg kicked up
  (0 :br-sj-hip)
  (2 :br-sj-hip (:root :yaw 8 :f 0.14 :u -0.12 :pitch 4) (:arm-r :flex 12 :side -18 :twist 0) (:elbow-r :flex 118) (:hand-r :flex -110 :twist 0)
   (:arm-l :flex -20 :side 44) (:elbow-l :flex 50) (:thigh-l :flex -10) (:knee-l :flex 24))   ; (the weight onto the front foot)
  (4 :br-sj-hip (:root :yaw 22 :f 0.12 :u -0.06 :pitch 0) (:arm-r :flex 30 :side 14 :twist 0) (:elbow-r :flex 136) (:hand-r :flex -150 :twist 0)
   (:arm-l :flex 24 :side 30) (:elbow-l :flex 80) (:thigh-l :flex 0) (:knee-l :flex 20))   ; (pivoted, the rifle snapped upright)
  (5 :br-sj-hip (:root :yaw 28 :f 0.12 :u -0.08 :pitch 0) (:arm-r :flex 32 :side 12 :twist 0) (:elbow-r :flex 140) (:hand-r :flex -154 :twist 0)
   (:arm-l :flex 26 :side 30) (:elbow-l :flex 84) (:thigh-l :flex 2) (:knee-l :flex 24))   ; (held, wound a touch further)
  (6 :snap :br-sj-hip (:root :yaw -26 :f 0.08 :u -0.06 :pitch 2) (:arm-r :flex 32 :side 58 :twist 0) (:elbow-r :flex 56) (:hand-r :flex -104 :twist 0)
   (:arm-l :flex 24 :side 34) (:elbow-l :flex 76) (:thigh-l :flex -6) (:knee-l :flex 30) (:neck :twist -4) (:head :twist -4))   ; (the hips turn first)
  (7 :snap :br-sj-back (:root :yaw -84 :pitch 4) (:arm-r :flex 30 :side 74 :twist 0) (:elbow-r :flex 30) (:hand-r :flex -92 :twist 0)
   (:thigh-l :flex -14) (:knee-l :flex 36) (:neck :twist -8) (:head :twist -8))   ; (the rifle flung round)
  (8 :snap :br-sj-back (:root :yaw -128 :pitch 8) (:arm-r :flex 6 :side 20 :twist -30) (:elbow-r :flex 46) (:hand-r :flex -30 :twist -60)
   (:thigh-l :flex -28) (:knee-l :flex 56) (:neck :twist -24) (:head :twist -26))   ; (swung in behind his back, the leg rising)
  (9 :snap :br-sj-back (:root :yaw -166) (:thigh-l :flex -38) (:knee-l :flex 68))   ; (the look over the shoulder)
  (:s :snap :br-sj-back) (11 :snap :br-sj-back-kick) (:a :br-sj-back)
  (14 :br-sj-back (:root :yaw -196 :u -0.08 :pitch 10) (:thigh-l :flex -30) (:knee-l :flex 60) (:arm-r :flex -28 :side -54 :twist -60))   ; (the recoil carries him on)
  (17 :br-sj-back (:root :yaw -270 :u -0.06 :pitch 4) (:thigh-l :flex 0) (:knee-l :flex 20) (:neck :twist 0) (:head :twist 0))
  (20 :lb-stance (:root :yaw -332 :u -0.06) (:arm-l :flex 30 :side 14)) (22 :lb-stance (:root :yaw -360)) (22.5 :lb-stance (:root :yaw -360))
  (22.5001 :snap :lb-stance) (:end :lb-stance))
(defstrike :br-sk-j3 (10 2 16 :base :lb-kamae-pose)   ; J3: whipped back round to his left, dropped wide, fired under the left arm f10, flipped onto the shoulder
  (0 :br-sj-back)
  (2 :br-sj-back (:root :yaw -172 :u -0.18 :pitch 10) (:arm-r :flex -10 :side -40 :twist -40) (:elbow-r :flex 90) (:hand-r :flex -40 :twist -80)
   (:thigh-l :flex -20) (:knee-l :flex 50) (:arm-l :flex 50 :side 34) (:elbow-l :flex 60))   ; (the leg down, sinking, the rifle drawn in)
  (3 :br-sj-under (:root :yaw -160 :u -0.27) (:arm-l :flex 40 :side 30) (:elbow-l :flex 80) (:knee-r :flex 50) (:knee-l :flex 58)
   (:arm-r :flex 69.5 :side -27.7 :twist -41.1) (:elbow-r :flex 168.8) (:hand-r :flex -39.4 :twist 22.6))   ; (whipped round, the rifle tossed up)
  (4 :br-sj-under (:root :yaw -146 :u -0.3) (:arm-l :flex 30 :side 30) (:elbow-l :flex 96) (:arm-r :flex 40 :side -40 :twist 60)
   (:elbow-r :flex 130) (:hand-r :flex -120 :twist 0) (:knee-r :flex 60) (:knee-l :flex 66))   ; (whipped round, dropped wide, the rifle up)
  (5 :br-sj-under (:root :yaw -140 :u -0.32) (:arm-l :flex 30 :side 34) (:elbow-l :flex 100) (:arm-r :flex 42 :side -42 :twist 60)
   (:elbow-r :flex 134) (:hand-r :flex -122 :twist 0) (:knee-r :flex 62) (:knee-l :flex 68))   ; (held, lowest)
  (7 :snap :br-sj-under (:root :yaw -116 :u -0.24) (:arm-l :flex 36 :side 80) (:elbow-l :flex 74) (:arm-r :flex 38 :side -44 :twist 60)
   (:elbow-r :flex 104) (:hand-r :flex -124 :twist 24))   ; (the left arm rising, the rifle coming down under it)
  (8 :snap :br-sj-under (:root :yaw -102 :u -0.19))   ; (on him)
  (9 :br-sj-under (:root :yaw -94 :u -0.15))   ; (the aim held)
  (:s :snap :br-sj-under) (11 :snap :br-sj-under-kick) (:a :br-sj-under)
  (14 :br-sj-under (:root :u -0.17) (:spine :side 8) (:arm-l :flex 34 :side 104) (:elbow-l :flex 60))   ; (the recoil settles, the arm lowers)
  (16 :snap :br-sj-under (:root :yaw -72 :u -0.1) (:arm-r :flex 70 :side -30 :twist 40) (:elbow-r :flex 90) (:hand-r :flex -150 :twist 30)
   (:arm-l :flex 30 :side 60) (:elbow-l :flex 70) (:neck :twist 16) (:head :twist 24))   ; (the flip: the rifle swung up)
  (18 :snap :br-pj-shoulder (:root :yaw -46 :u -0.04)) (19 :br-pj-shoulder (:root :yaw -40 :u -0.02) (:head :flex -4))   ; (on the shoulder)
  (23 :br-pj-shoulder (:head :flex -8)) (:end :lb-stance))
;; K 槍身重揮 (R15): the rifle swung heavy, both hands
(defstrike :br-sk-k1 (16 2 18 :base :lb-kamae-pose)   ; K1: cocked, laid back and stretched, the squat f12, the sweep R -> L f13-16 (hit f16), wrapped round
  (0) (4 :br-sk-cock) (9 :br-sk-wind)
  (12 :br-sk-wind (:root :u -0.16 :f -0.1) (:thigh-r :flex 6) (:knee-r :flex 56) (:thigh-l :flex 46) (:knee-l :flex 66))
  (13 :snap :br-sk-k1-sw1) (14 :snap :br-sk-k1-sw2) (15 :snap :br-sk-k1-sw3) (:s :snap :br-sk-k1-hit)
  (17 :snap :br-sk-k1-thru1) (:a :br-sk-k1-thru) (24 :br-sk-k1-thru (:root :u -0.2))
  (30 :br-sk-k1-thru (:root :yaw 40 :f 0.16 :u -0.12)) (:end :lb-stance))
(defstrike :br-sk-k2 (12 2 18 :base :lb-kamae-pose)   ; K2: hauled up over the left shoulder, the backhand down across him f10-12 (hit f12) to his lower right
  (0 :br-sk-k1-thru) (4 :br-sk-k2-up) (8 :br-sk-k2-wind)
  (10 :snap :br-sk-k2-sw1) (11 :snap :br-sk-k2-sw2) (:s :snap :br-sk-k2-hit) (13 :snap :br-sk-k2-thru1) (:a :br-sk-k2-thru)
  (19 :br-sk-k2-thru (:root :u -0.24)) (26 :br-sk-k2-thru (:root :yaw -14 :f 0.14 :u -0.12)) (:end :lb-stance))
(defstrike :br-sk-k3 (18 2 22 :base :lb-kamae-pose)   ; K3: one turn right f2-13, the rifle out and rising, overhead, arched back, the smash f18, into the floor
  (0 :br-sk-k2-thru)
  (2 :snap :br-sk-k3-carry (:root :yaw -52)) (5 :snap :br-sk-k3-carry (:root :yaw -140)) (8 :snap :br-sk-k3-rise (:root :yaw -228))
  (11 :snap :br-sk-k3-rise (:root :yaw -314 :u 0.1)) (13 :snap :br-sk-k3-top (:root :yaw -360))
  (13.5 :br-sk-k3-top (:root :yaw -360)) (13.5001 :snap :br-sk-k3-top)   ; (the turn wound back to 0 between samples)
  (16 :br-sk-k3-top2) (17 :snap :br-sk-k3-down) (:s :snap :br-sk-k3-hit) (19 :snap :br-sk-k3-floor) (:a :br-sk-k3-floor)
  (27 :br-sk-k3-floor (:root :u -0.24)) (35 :br-sk-k3-floor (:root :f 0.18 :u -0.12 :pitch 10) (:spine :flex 12)) (:end :lb-stance))
;; the J route's L L: one hand, light (one line each)
(defstrike :br-sk-jl1 (8 2 14 :base :lb-kamae-pose)   ; wound half round, whipped back at arm's length (f8), skipped back
  (0 :br-sj-under) (4 :br-pjl-wind)
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
  (0 :br-sk-k3-floor) (5 :br-pkl-load) (8 :br-pkl-shot (:root :f 0.08 :u -0.24))
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
;; wings and the owl's claws (the follow-up's hit is its 萬物貫通 line; the tip on his line, the host test). R11 (§16: 「現在的
;; 架式 J > L 看起來依舊是射擊？」): three lashes, the body thrown into each (twisted, leaning in) in time with the lash's
;; swing (*BR-LASHES*): JL1 the right wing wound out behind him to the right, swung flat round through him and on across to
;; his left; JL2 the left wing raised high behind the left shoulder, the backhand down across him to his lower right; JL3
;; risen tall and arched back with the right wing overhead, the whole body slammed forward and down, the lash cracked
;; straight down on him and on into the floor (the heaviest: stretched tall, then squashed, *BR-SQUASH*).
(defpose :br-en-lash-wind-r (:base :lb-w-stance)    ; JL1 wound up: twisted right, leaning back, the right wing drawn out back to the right
  (:root :f -0.1 :u 0.06 :yaw -26 :pitch -6) (:pelvis :twist -18) (:spine :flex -8) (:chest :twist -44) (:head :twist 34)
  (:arm-r :flex 36 :side 101) (:elbow-r :flex 18) (:arm-l :flex 46 :side 30) (:elbow-l :flex 40)
  (:thigh-r :flex -14) (:thigh-l :flex 16))
(defpose :br-en-lash-sweep-r (:base :lb-w-stance)   ; ... the swing coming round: unwinding, the wing out flat to the right
  (:root :f 0.02 :u 0.02 :yaw -12 :pitch 2) (:pelvis :twist -8) (:spine :flex 4) (:chest :twist -20) (:head :twist 16)
  (:arm-r :flex 56 :side 94) (:elbow-r :flex 6) (:arm-l :flex 30 :side 30) (:elbow-l :flex 40)
  (:thigh-r :flex 6) (:thigh-l :flex -4))
(defpose :br-en-lash-crack-r (:base :lb-w-stance)   ; JL1's crack (S): leaning into it, unwound to square, the wing at him
  (:root :f 0.16 :u -0.04 :yaw 4 :pitch 10) (:pelvis :twist 4) (:spine :flex 14) (:chest :twist 8) (:head :twist -6)
  (:arm-r :flex 114 :side -24) (:elbow-r :flex 0) (:arm-l :flex 10 :side 40) (:elbow-l :flex 30)
  (:thigh-r :flex 24) (:thigh-l :flex -16))
(defpose :br-en-lash-thru-r (:base :lb-w-stance)    ; ... followed through across to his left, wound the other way
  (:root :f 0.22 :u -0.08 :yaw 24 :pitch 12) (:pelvis :twist 16) (:spine :flex 16) (:chest :twist 40) (:head :twist -20)
  (:arm-r :flex 102 :side -6) (:elbow-r :flex 4) (:arm-l :flex -10 :side 46) (:elbow-l :flex 24)
  (:thigh-r :flex 26) (:thigh-l :flex -18))
(defpose :br-en-lash-wind-l (:base :lb-w-stance)    ; JL2 wound up: twisted left, leaning back, the left wing raised high behind the left shoulder
  (:root :f -0.08 :u 0.1 :yaw 24 :pitch -8) (:pelvis :twist 16) (:spine :flex -10) (:chest :twist 46) (:head :twist -30)
  (:arm-l :flex 150 :side -20) (:elbow-l :flex 16) (:arm-r :flex 30 :side 40) (:elbow-r :flex 40)
  (:thigh-l :flex -14) (:thigh-r :flex 16))
(defpose :br-en-lash-sweep-l (:base :lb-w-stance)   ; ... coming down from high on the left
  (:root :f 0.04 :u 0.04 :yaw 10 :pitch 4) (:pelvis :twist 6) (:spine :flex 6) (:chest :twist 20) (:head :twist -10)
  (:arm-l :flex 126 :side -4) (:elbow-l :flex 6) (:arm-r :flex 20 :side 40) (:elbow-r :flex 40)
  (:thigh-l :flex 6) (:thigh-r :flex -4))
(defpose :br-en-lash-crack-l (:base :lb-w-stance)   ; JL2's crack (S): the backhand, leaning down into it
  (:root :f 0.16 :u -0.06 :yaw -4 :pitch 12) (:pelvis :twist -4) (:spine :flex 16) (:chest :twist -8) (:head :twist 6)
  (:arm-l :flex 116 :side -22) (:elbow-l :flex 0) (:arm-r :flex 10 :side 40) (:elbow-r :flex 30)
  (:thigh-l :flex 24) (:thigh-r :flex -16))
(defpose :br-en-lash-thru-l (:base :lb-w-stance)    ; ... followed through down to his lower right
  (:root :f 0.24 :u -0.14 :yaw -24 :pitch 18) (:pelvis :twist -16) (:spine :flex 24) (:chest :twist -40) (:head :twist 16)
  (:arm-l :flex 96 :side -48) (:elbow-l :flex 4) (:arm-r :flex -10 :side 46) (:elbow-r :flex 24)
  (:thigh-l :flex 28) (:thigh-r :flex -20))
(defpose :br-en-lash-rear (:base :lb-w-stance)      ; JL3 wound up: risen tall, arched back, the right wing overhead and back
  (:root :f -0.12 :u 0.16 :pitch -14) (:spine :flex -16) (:chest :twist -10) (:head :flex -10)
  (:arm-r :flex 184 :side -2) (:elbow-r :flex 14) (:arm-l :flex 120 :side 60) (:elbow-l :flex 30)
  (:thigh-r :flex -10) (:thigh-l :flex 6))
(defpose :br-en-lash-over (:base :lb-w-stance)      ; ... brought over the top
  (:root :f 0.02 :u 0.1 :pitch -2) (:spine :flex 0) (:chest :twist 0) (:head :flex 0)
  (:arm-r :flex 155 :side 4) (:elbow-r :flex 4) (:arm-l :flex 60 :side 50) (:elbow-l :flex 30))
(defpose :br-en-lash-slam (:base :lb-w-stance)      ; JL3's crack (S): the whole body slammed forward and down
  (:root :f 0.22 :u -0.14 :pitch 18) (:spine :flex 24) (:chest :twist 6) (:head :flex 10)
  (:arm-r :flex 128 :side 4) (:elbow-r :flex 0) (:arm-l :flex -20 :side 44) (:elbow-l :flex 24)
  (:thigh-r :flex 30) (:thigh-l :flex -20))
(defpose :br-en-lash-floor (:base :lb-w-stance)     ; ... followed through into the floor, bowed over it
  (:root :f 0.28 :u -0.22 :pitch 26) (:spine :flex 32) (:head :flex 14)
  (:arm-r :flex 112 :side 0) (:elbow-r :flex 0) (:arm-l :flex -30 :side 40) (:elbow-l :flex 20)
  (:thigh-r :flex 32) (:thigh-l :flex -22))
(defpose :br-en-lash-rest-r (:base :lb-w-stance)    ; the recovery's settle (each lash's end: the next one's start)
  (:root :f 0.04 :pitch 3) (:spine :flex 4) (:arm-r :flex 40 :side 40) (:elbow-r :flex 20) (:arm-l :flex 40 :side 50)
  (:elbow-l :flex 20))
(defstrike :br-e-jf1 (8 2 14 :base :lb-w-stance)   ; JL1 長鞭 (R11): out of the spin, wound right f4-5, swung flat round through him, the crack f8, through to his left
  (0 :br-en-top-high (:root :u 0.2) (:pelvis :twist -198)) (2 :snap :br-en-top (:pelvis :twist -60))
  (4 :br-en-lash-wind-r) (5.5 :br-en-lash-wind-r (:chest :twist -50) (:arm-r :flex 30 :side 106)) (7 :br-en-lash-sweep-r)
  (:s :snap :br-en-lash-crack-r) (:a :br-en-lash-thru-r)
  (14 :br-en-lash-thru-r (:root :f 0.18 :u -0.06 :yaw 20 :pitch 9) (:arm-r :flex 86 :side -18))
  (19 :br-en-lash-rest-r) (:end :lb-w-stance))
(defstrike :br-e-jf2 (8 2 14 :base :lb-w-stance)   ; JL2 長鞭 (R11): the left wing raised high behind f4-5, the backhand down through him f8, on to his lower right
  (0 :br-en-lash-rest-r)
  (4 :br-en-lash-wind-l) (5.5 :br-en-lash-wind-l (:chest :twist 52) (:arm-l :flex 156 :side -24)) (7 :br-en-lash-sweep-l)
  (:s :snap :br-en-lash-crack-l) (:a :br-en-lash-thru-l)
  (14 :br-en-lash-thru-l (:root :f 0.2 :u -0.1 :yaw -20 :pitch 14) (:arm-l :flex 80 :side -40))
  (19 :br-en-lash-rest-r) (:end :lb-w-stance))
(defstrike :br-e-jf3 (8 2 16 :base :lb-w-stance)   ; JL3 長鞭 (R11): risen and arched back f3.5-5, the wing over the top f6.5, the whole body slammed down with the crack f8, into the floor
  (0 :br-en-lash-rest-r)
  (3.5 :br-en-lash-rear) (5 :br-en-lash-rear (:root :f -0.14 :u 0.2 :pitch -16) (:arm-r :flex 192 :side -2)) (6.5 :br-en-lash-over)
  (:s :snap :br-en-lash-slam) (:a :br-en-lash-floor)
  (16 :br-en-lash-floor (:root :f 0.28 :u -0.2 :pitch 24))
  (21 :br-en-lash-rest-r (:root :f 0.08 :u -0.06 :pitch 8)) (:end :lb-w-stance))
;; the owl's (its claws are the hands: the same bodies, the neck carried with them)
(defpose :br-oen-lash-wind-r (:base :lb-oe-stance)
  (:root :f -0.1 :u 0.08 :yaw -26 :pitch -6) (:pelvis :twist -18) (:spine :flex -8) (:chest :twist -44) (:neck :flex -8)
  (:head :twist 34) (:arm-r :flex 36 :side 91) (:elbow-r :flex 18) (:hand-r :flex -30) (:arm-l :flex 46 :side 30)
  (:elbow-l :flex 40) (:hand-l :flex 10) (:thigh-r :flex -14) (:thigh-l :flex 16))
(defpose :br-oen-lash-sweep-r (:base :lb-oe-stance)
  (:root :f 0.04 :u 0.04 :yaw -12 :pitch 2) (:pelvis :twist -8) (:spine :flex 4) (:chest :twist -20) (:neck :flex 4)
  (:head :twist 16) (:arm-r :flex 52 :side 82) (:elbow-r :flex 6) (:hand-r :flex -10) (:arm-l :flex 30 :side 30)
  (:elbow-l :flex 40) (:hand-l :flex 10) (:thigh-r :flex 6) (:thigh-l :flex -4))
(defpose :br-oen-lash-crack-r (:base :lb-oe-stance)
  (:root :f 0.18 :u -0.04 :yaw 4 :pitch 10) (:pelvis :twist 4) (:spine :flex 14) (:chest :twist 8) (:neck :flex 18)
  (:head :twist -6) (:arm-r :flex 110 :side -36) (:elbow-r :flex 0) (:hand-r :flex 30) (:arm-l :flex 10 :side 40)
  (:elbow-l :flex 30) (:hand-l :flex 10) (:thigh-r :flex 24) (:thigh-l :flex -16))
(defpose :br-oen-lash-thru-r (:base :lb-oe-stance)
  (:root :f 0.24 :u -0.08 :yaw 24 :pitch 12) (:pelvis :twist 16) (:spine :flex 16) (:chest :twist 40) (:neck :flex 20)
  (:head :twist -20) (:arm-r :flex 96 :side -34) (:elbow-r :flex 4) (:hand-r :flex 30) (:arm-l :flex -10 :side 46)
  (:elbow-l :flex 24) (:hand-l :flex 10) (:thigh-r :flex 26) (:thigh-l :flex -18))
(defpose :br-oen-lash-wind-l (:base :lb-oe-stance)
  (:root :f -0.08 :u 0.12 :yaw 24 :pitch -8) (:pelvis :twist 16) (:spine :flex -10) (:chest :twist 46) (:neck :flex -10)
  (:head :twist -30) (:arm-l :flex 150 :side -20) (:elbow-l :flex 16) (:hand-l :flex -30) (:arm-r :flex 30 :side 40)
  (:elbow-r :flex 40) (:hand-r :flex 10) (:thigh-l :flex -14) (:thigh-r :flex 16))
(defpose :br-oen-lash-sweep-l (:base :lb-oe-stance)
  (:root :f 0.06 :u 0.06 :yaw 10 :pitch 4) (:pelvis :twist 6) (:spine :flex 6) (:chest :twist 20) (:neck :flex 4)
  (:head :twist -10) (:arm-l :flex 116 :side -6) (:elbow-l :flex 6) (:hand-l :flex -10) (:arm-r :flex 20 :side 40)
  (:elbow-r :flex 40) (:hand-r :flex 10) (:thigh-l :flex 6) (:thigh-r :flex -4))
(defpose :br-oen-lash-crack-l (:base :lb-oe-stance)
  (:root :f 0.18 :u -0.06 :yaw -4 :pitch 12) (:pelvis :twist -4) (:spine :flex 16) (:chest :twist -8) (:neck :flex 18)
  (:head :twist 6) (:arm-l :flex 112 :side -32) (:elbow-l :flex 0) (:hand-l :flex 30) (:arm-r :flex 10 :side 40)
  (:elbow-r :flex 30) (:hand-r :flex 10) (:thigh-l :flex 24) (:thigh-r :flex -16))
(defpose :br-oen-lash-thru-l (:base :lb-oe-stance)
  (:root :f 0.26 :u -0.14 :yaw -24 :pitch 18) (:pelvis :twist -16) (:spine :flex 24) (:chest :twist -40) (:neck :flex 24)
  (:head :twist 16) (:arm-l :flex 104 :side -60) (:elbow-l :flex 4) (:hand-l :flex 30) (:arm-r :flex -10 :side 46)
  (:elbow-r :flex 24) (:hand-r :flex 10) (:thigh-l :flex 28) (:thigh-r :flex -20))
(defpose :br-oen-lash-rear (:base :lb-oe-stance)
  (:root :f -0.12 :u 0.18 :pitch -14) (:spine :flex -16) (:chest :twist -10) (:neck :flex -16) (:head :flex -10)
  (:arm-r :flex 182 :side -6) (:elbow-r :flex 14) (:hand-r :flex -30) (:arm-l :flex 120 :side 60) (:elbow-l :flex 30)
  (:hand-l :flex -10) (:thigh-r :flex -10) (:thigh-l :flex 6))
(defpose :br-oen-lash-over (:base :lb-oe-stance)
  (:root :f 0.04 :u 0.12 :pitch -2) (:spine :flex 0) (:chest :twist 0) (:neck :flex 0) (:head :flex 0)
  (:arm-r :flex 149 :side 0) (:elbow-r :flex 4) (:hand-r :flex -10) (:arm-l :flex 60 :side 50) (:elbow-l :flex 30)
  (:hand-l :flex 10))
(defpose :br-oen-lash-slam (:base :lb-oe-stance)
  (:root :f 0.24 :u -0.14 :pitch 18) (:spine :flex 24) (:chest :twist 6) (:neck :flex 24) (:head :flex 10)
  (:arm-r :flex 122 :side 0) (:elbow-r :flex 0) (:hand-r :flex 30) (:arm-l :flex -20 :side 44) (:elbow-l :flex 24)
  (:hand-l :flex 10) (:thigh-r :flex 30) (:thigh-l :flex -20))
(defpose :br-oen-lash-floor (:base :lb-oe-stance)
  (:root :f 0.3 :u -0.22 :pitch 26) (:spine :flex 32) (:neck :flex 30) (:head :flex 14)
  (:arm-r :flex 112 :side -10) (:elbow-r :flex 0) (:hand-r :flex 40) (:arm-l :flex -30 :side 40) (:elbow-l :flex 20)
  (:hand-l :flex 10) (:thigh-r :flex 32) (:thigh-l :flex -22))
(defpose :br-oen-lash-rest-r (:base :lb-oe-stance)
  (:root :f 0.06 :pitch 3) (:spine :flex 4) (:neck :flex 4) (:arm-r :flex 40 :side 40) (:elbow-r :flex 20) (:hand-r :flex 10)
  (:arm-l :flex 40 :side 50) (:elbow-l :flex 20) (:hand-l :flex 10))
(defstrike :br-oe-jf1 (8 2 13 :base :lb-oe-stance)   ; JL1 長鞭 (R11): the right claw's lash wound out right f4-5, swung flat round through him f8, through to his left
  (0 :br-oen-top-high (:root :u 0.2) (:pelvis :twist -198)) (2 :snap :br-oen-top (:pelvis :twist -60))
  (4 :br-oen-lash-wind-r) (5.5 :br-oen-lash-wind-r (:chest :twist -50) (:arm-r :flex 30 :side 96)) (7 :br-oen-lash-sweep-r)
  (:s :snap :br-oen-lash-crack-r) (:a :br-oen-lash-thru-r)
  (14 :br-oen-lash-thru-r (:root :f 0.2 :u -0.06 :yaw 20 :pitch 9) (:arm-r :flex 82 :side -30))
  (19 :br-oen-lash-rest-r) (:end :lb-oe-stance))
(defstrike :br-oe-jf2 (8 2 13 :base :lb-oe-stance)   ; JL2 長鞭 (R11): the left claw raised high behind, the backhand down through him f8, on to his lower right
  (0 :br-oen-lash-rest-r)
  (4 :br-oen-lash-wind-l) (5.5 :br-oen-lash-wind-l (:chest :twist 52) (:arm-l :flex 156 :side -24)) (7 :br-oen-lash-sweep-l)
  (:s :snap :br-oen-lash-crack-l) (:a :br-oen-lash-thru-l)
  (14 :br-oen-lash-thru-l (:root :f 0.22 :u -0.1 :yaw -20 :pitch 14) (:arm-l :flex 88 :side -50))
  (19 :br-oen-lash-rest-r) (:end :lb-oe-stance))
(defstrike :br-oe-jf3 (8 2 15 :base :lb-oe-stance)   ; JL3 長鞭 (R11): risen and arched back, over the top, slammed down with the crack f8, into the floor
  (0 :br-oen-lash-rest-r)
  (3.5 :br-oen-lash-rear) (5 :br-oen-lash-rear (:root :f -0.14 :u 0.22 :pitch -16) (:arm-r :flex 190 :side -6)) (6.5 :br-oen-lash-over)
  (:s :snap :br-oen-lash-slam) (:a :br-oen-lash-floor)
  (16 :br-oen-lash-floor (:root :f 0.3 :u -0.2 :pitch 24))
  (21 :br-oen-lash-rest-r (:root :f 0.1 :u -0.06 :pitch 8)) (:end :lb-oe-stance))
;; the stretch (R5 J 長鞭) and the spins (R5 L 陀螺) to Lille's wing looks (lille-art.lisp: %LB-STRETCH!, %LB-WINGS, %LB-LASHES,
;; %LB-DRIVE!; Lille's own clips are in neither)
(defparameter *br-w-stretch*
  '((:br-e-jf1 (0 0 0) (4 0.3 0.1) (8 0.4 0.1) (10 0.3 0.1) (16 0.15 0) (24 0 0))   ; (R9, §14: the whips are the J route's L L;
    (:br-e-jf2 (0 0.15 0) (4 0.1 0.3) (8 0.1 0.4) (10 0.1 0.3) (16 0 0.15) (24 0 0))   ;  R11, §16: the striking wing only,
    (:br-e-jf3 (0 0 0.15) (4 0.35 0.1) (8 0.45 0.1) (10 0.35 0.1) (18 0.15 0) (26 0 0))   ;  short: the lash on from its tip)
    (:br-en-k1 (0 0 0) (4 0.8 0) (8 1.5 0) (10 1.6 0) (11 1.7 0) (13 1.6 0) (15 1.3 0) (16 1.0 0) (17 1.3 0) (22 1.3 0)
               (26 0.5 0) (30 0 0))
    (:br-en-k2 (0 1.2 0) (4 1.3 0) (7 1.6 0) (9 1.5 0) (11 1.2 0) (12 1.0 0) (13 1.3 0) (19 1.2 0) (24 0.5 0) (30 0 0))
    (:br-en-k3 (0 1.0 0) (2 1.1 0) (5 1.3 0) (8 1.5 0) (11 1.7 0) (13 1.8 0) (16 1.8 0) (17 1.5 0) (18 1.15 0) (19 1.4 0)
               (27 1.3 0) (32 0.4 0) (40 0 0))   ; (R10, §15: held long overhead through the turn's end, the split)
    (:br-oe-jf1 (0 0 0) (4 0.3 0) (8 0.4 0) (10 0.3 0) (16 0.15 0) (23 0 0))
    (:br-oe-jf2 (0 0.15 0) (4 0 0.3) (8 0 0.4) (10 0 0.3) (16 0 0.15) (23 0 0))
    (:br-oe-jf3 (0 0 0.15) (4 0.35 0) (8 0.45 0) (10 0.35 0) (18 0.15 0) (25 0 0))
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
    (:br-oen-k3 (0 1 1) (2 0.96 1.04) (5 0.94 1.06) (8 0.96 1.04) (11 1.08 0.94) (13 1.18 0.88) (15 1.22 0.86) (16 1.16 0.9) (17 0.98 1.02) (18 0.72 1.32) (24 0.75 1.3) (30 0.94 1.06) (34 1 1))
    (:br-e-jf3 (0 1 1) (3.5 1.1 0.93) (5 1.14 0.9) (6.5 1.04 0.97) (8 0.8 1.2) (11 0.82 1.18) (17 0.96 1.04) (22 1 1))   ; (R11, §16: JL3,
    (:br-oe-jf3 (0 1 1) (3.5 1.1 0.93) (5 1.14 0.9) (6.5 1.04 0.97) (8 0.8 1.2) (11 0.82 1.18) (17 0.96 1.04) (22 1 1))   ;  the heaviest lash)
    ;; (R15, §19: the base stance's gun-kata, coiled / spun tall / squashed on each point-blank shot, and the rifle swung
    ;;  heavy, the great sword's: stretched on the wind-ups, the squat tells, squashed on the hits)
    ;; (R16, §20: re-timed to S 10 with the in-betweens: the dip, the coil held, sprung tall through the spin, squashed on
    ;;  the shot f10, the settle; the base J3 銃口突 :br-jab drawn back low, stretched on the thrust f10, the recoil)
    (:br-sk-j1 (0 1 1) (2 0.95 1.04) (4 0.87 1.11) (5 0.85 1.13) (6 0.98 1.02) (7 1.1 0.93) (9 1.06 0.96) (10 0.88 1.12)
               (13 0.95 1.05) (15 0.94 1.06) (19 0.98 1.02) (23 1 1))
    (:br-sk-j2 (0 1 1) (2 0.95 1.05) (4 1.08 0.94) (5 1.1 0.93) (7 1.06 0.95) (9 1.02 0.98) (10 0.9 1.1) (13 0.96 1.04)
               (17 1.02 0.98) (20 1 1))
    (:br-sk-j3 (0 1 1) (2 0.93 1.06) (4 0.84 1.14) (5 0.82 1.16) (7 1.0 1.0) (9 0.98 1.02) (10 0.88 1.12) (13 0.95 1.05)
               (16 1.06 0.95) (18 1.1 0.93) (21 1.02 0.98) (24 1 1))
    (:br-sk-l1s (0 1 1) (2 0.97 1.02) (4 0.96 1.03) (8 1.05 0.97) (11 0.96 1.03) (13 0.96 1.03) (15 0.94 1.05) (16 0.94 1.05)
                (17 1.05 0.96) (21 1.01 0.99) (24 1 1))   ; (R16: level 1's wind-up: the breath in / out, the squeeze, the kick)
    (:br-jab (0 1 1) (3 0.97 1.03) (6 0.9 1.08) (8 0.88 1.1) (9 1.06 0.95) (10 1.1 0.92) (12 1.08 0.94) (14 0.95 1.05)
             (18 0.97 1.03) (24 1 1))
    (:br-sk-k1 (0 1 1) (4 1.08 0.95) (9 1.16 0.9) (12 0.84 1.12) (13 1.06 0.96) (15 1.02 0.99) (16 0.78 1.26) (21 0.8 1.24)
               (26 0.95 1.05) (32 1 1))
    (:br-sk-k2 (0 0.95 1.05) (4 1.06 0.96) (8 1.16 0.9) (10 1.06 0.96) (11 0.98 1.02) (12 0.8 1.24) (17 0.82 1.2) (23 0.96 1.04)
               (28 1 1))
    (:br-sk-k3 (0 1 1) (2 0.96 1.04) (8 0.98 1.02) (11 1.1 0.94) (13 1.2 0.87) (16 1.22 0.86) (17 1.02 0.99) (18 0.86 1.16)
               (19 0.7 1.34) (25 0.74 1.3) (31 0.94 1.06) (36 1 1))
    ;; (the base form's attack-state K string, bold (the user 2026-10-12): K1 squashed into the coil and the squat tell,
    ;;  sprung tall out of it, low on the sweep (only a little wide: the muzzle swept far to his side); K2 stretched tallest
    ;;  overhead, squashed flat on the chop and into the floor; K3 compressed in the coil, stretched on the drive, the kick
    ;;  thrown up tall; each link's first frames the squash its predecessor holds there)
    (:br-f1 (0 1 1) (3 0.97 1.02) (7 0.92 1.06) (10 0.9 1.07) (13 0.84 1.1) (14 0.84 1.1) (15 1.08 0.97) (17 1.04 0.99)
            (19 0.86 1.05) (23 0.88 1.04) (27 0.92 1.03) (31 0.94 1.02) (37 1 1))
    (:br-f2 (0 0.88 1.04) (7 0.88 1.04) (11 1.06 0.96) (15 1.16 0.9) (19 1.2 0.88) (20 1.12 0.92) (21 1.02 0.98) (22 0.78 1.24)
            (26 0.76 1.26) (28 0.74 1.28) (33 0.78 1.22) (40 0.95 1.04) (46 1 1))
    (:br-f3 (0 0.76 1.26) (8 0.76 1.26) (11 0.9 1.08) (15 0.84 1.12) (18 0.82 1.14) (20 1.04 0.97) (22 1.1 0.94) (23 0.9 1.08)
            (24 1.12 0.92) (27 1.08 0.94) (28 1.06 0.95) (34 1.04 0.97) (42 0.98 1.01) (52 1 1)))
  "R8 (§13): the body's squash and stretch by clip, keys (frame up sideways) in the clip's frames, linear between, held past
the ends: K1 the level-3 Charged Slash (stretched tall while the wing is hauled over the shoulder, the squat tell f10
since R9's in-betweens, sprung up f11, the swing through the arc, squashed wide and low on the slam f16, held a beat); R9
(§14: 「架式 J 的蓄力斬合併到架式 K 連打中」) K2 the backhand (wound up tall, squashed on the hit f12), K3 the turn (stretched
tall as the blade rises over him; R10 §15: a little wide through the tilted turn, tallest held at the top f13-f15, the
split squashed f18); R11 (§16) JL3's overhead lash (risen tall over the wind-up, squashed on the crack f8); R15 (§19) the base stance's J (the gun-kata's spins and shots) and K (the rifle swung: the
wind-ups tall, the squat tells, the hits squashed, K3's smash flattest on the floor f19). The host FK test scales the tips
the same way (the facing axis untouched: the reach is the unscaled one's).")
(declaim (type list *br-squash-v*))
(defparameter *br-squash-v*
  (loop for (c . keys) in *br-squash* collect (cons c (coerce (mapcar #'f32 (apply #'append keys)) 'f32vec)))
  "*BR-SQUASH* as f32vecs (BR-DEFORM reads them without consing).")
(defmacro %br-charge-depth (f ease)
  "R10 (DUEL_LILLE_V3 §15): how deep F's awakened L charge is coiled, 0..1 (single-float, inline: 0 B): while L is held,
0 at level 1, 0.5 at level 2, 1 at level 3, each level dropped in over 4 frames from its frame held (*BR-W-L-LEVELS*);
after the release the level's (FIGHTER-CHARGE), and with EASE let go over the dash's first 6 frames; 0 for any other move.
R15 (DUEL_LILLE_V3 §19): the base stance's charged snipe (*BR-SNIPE-MOVES*, its copies' main phase from the release) the
same way."
  `(let* ((%f ,f) (%mv (and (eq (fighter-state %f) :move) (fighter-move %f))))
     (if (and %mv (or (member (mv-name %mv) *br-dash-moves*) (member (mv-name %mv) *br-snipe-moves*)))
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
;; R11 (DUEL_LILLE_V3 §16, the user 2026-10-11 on v66: 「我想要為架式切換時增加把腳放出來與收起來的過度動畫。」): the stance
;; switch's legs. JILLIEL KIN stands on the ㄇ legs (:lille-jilliel-kin), JILLIEL EN floats as the long column (:lille-jilliel,
;; no legs); the owl keeps its body and folds its legs up in EN (its own tuck, decision 38, began only after the turn). The
;; bodies swapped and the legs popped on the turn's last frame (into the stance) and on the string's end (back to KIN). Now
;; the legs are put away over the turn (:br-to-en f0-f10: the shanks fold up under the strut, then the ㄇ and the thighs
;; shrink up into the hips while the hip mass draws down into a column), EN's column grows its last stretch over its first
;; frames, and back in KIN they come out over *BR-LEGS-OUT* frames (the hip mass drawn up short, the thighs and the ㄇ
;; growing out of it, the shanks unfolding to the floor); the owl's fold the same way, its EN lift let down with them. A
;; look: the form, the move's frame and the fx clock (a per-side memory, *BR-LEGS*), never the sim.
(defparameter *br-legs-in* 10 "The turn's frames over which the legs are put away (the form turns EN on its f11) ...")
(defparameter *br-legs-out* 9 "... the frames over which they come out once the stance's string ends (back to KIN) ...")
(defparameter *br-legs-hips* 0.85 "... the hip mass drawn down this much longer (x its height) while they are in ...")
(defparameter *br-legs-grow* 5 "... and EN's column grown from 0.75 of its length over this many frames after the turn.")
(declaim (type f32vec *br-legs*) (type simple-vector *br-model*))
(defvar *br-legs*
  (let ((v (make-f32 20))) (dotimes (s 2 v) (setf (aref v (* 10 s)) -1f0 (aref v (+ 2 (* 10 s))) -100f0 (aref v (+ 4 (* 10 s))) -100f0)))
  "Per side (10 each, the looks' memory): [0] last frame's mode (-1 none, 0 KIN, 1 the turn into the stance, 2 EN), [1] the
legs' put-away share 0..1 then, [2] the fx clock when they were let out (KIN again), [3] the share then, [4] the fx clock
EN began, [5] the lift to let down from then (m), [6] last frame's drawn lift; this frame's [7] fold and [8] pull for
LILLE-DRAW (*LB-WF* [89 90]).")
(defvar *br-model* (make-array 2 :initial-element nil)
  "Each side's model as his :pose hook last saw it (BR-DEFORM): the draw hook reads its clip with no entity lookup.")
(defun-fast %br-legs-pose (f side m)
  "R11 (§16): the stance switch's legs for F (SIDE) on model M's posed joints (his :pose hook, after the squash): the mode
(the turn :br-to-en in KIN, EN, KIN), the put-away share U (the turn: f0-*BR-LEGS-IN* by the move's frame; EN 1; KIN: the
share it was let out at, down to 0 over *BR-LEGS-OUT* frames of the fx clock), JILLIEL's fold (U 0-0.55) and pull (U
0.3-1), the owl's fold U: on JILLIEL KIN's body the thighs scaled by 1 - pull about the hips and the hip mass drawn down x 1
+ *BR-LEGS-HIPS* pull; on EN's body the column grown back from 0.75 over *BR-LEGS-GROW* frames; a lift let down (the owl's
EN 0.35 m) raised off him over the let-out. Its fold and pull for LILLE-DRAW in *BR-LEGS* [7 8]. 0 B."
  (declare (fixnum side))
  (let* ((v *br-legs*) (o (* 10 side)) (form (fighter-form f)) (tm (fx-clock))
         (mv (and (eq (fighter-state f) :move) (fighter-move f)))
         (kin (member form '(:jilliel-kin :shin-kin))) (owl (member form '(:shin-kin :shin)))
         (mode (cond ((and kin mv (member (mv-name mv) '(:br-to-en :br-to-en-l)) (eq (fighter-phase f) :main)) 1)
                     ((member form '(:jilliel :shin)) 2) (kin 0) (t -1)))
         (prev (f->i (aref v o))) (lift (the single-float (f32 (body-lift (fighter-kit f) (model-body m)))))
         (bn (body-name (model-body m))) (jm (model-joints m)) (u 0f0) (fold 0f0) (pull 0f0) (out 0f0))
    (declare (type f32vec v jm) (fixnum o mode prev) (single-float tm lift u fold pull out))
    (when (and (= mode 0) (>= prev 1))                  ; (let out: KIN again after the turn or EN)
      (setf (aref v (+ o 2)) tm (aref v (+ o 3)) (aref v (+ o 1)) (aref v (+ o 5)) (f-max 0f0 (- (aref v (+ o 6)) lift))))
    (when (and (= mode 2) (/= prev 2)) (setf (aref v (+ o 4)) tm))
    (when (= mode -1) (setf (aref v (+ o 3)) 0f0 (aref v (+ o 5)) 0f0))
    (setf out (- 1f0 (%lb-ss (/ (- tm (aref v (+ o 2))) (/ (i->f (the fixnum *br-legs-out*)) 60f0))))
          u (case mode
              (1 (%lb-ss (/ (i->f (the fixnum (fighter-sf f))) (i->f (the fixnum *br-legs-in*)))))
              (2 1f0) (0 (* out (aref v (+ o 3)))) (t 0f0))
          fold (if owl u (%lb-ss (/ u 0.55f0)))
          pull (if owl 0f0 (%lb-ss (/ (- u 0.3f0) 0.7f0))))
    (when (and (> pull 0f0) (eq bn :lille-jilliel-kin))   ; the thighs up into the hips, the hip mass drawn down
      (let ((q (f-max 0.04f0 (- 1f0 pull))) (pv (* 16 (ji :pelvis))) (hk (+ 1f0 (* pull (the single-float *br-legs-hips*)))))
        (declare (single-float q hk) (fixnum pv))
        (dotimes (k 2)
          (let ((t0 (* 16 (if (= k 0) (ji :thigh-r) (ji :thigh-l)))))
            (declare (fixnum t0))
            (dotimes (c 11) (unless (= (mod c 4) 3) (setf (aref jm (+ t0 c)) (* q (aref jm (+ t0 c))))))))
        (dotimes (c 3) (setf (aref jm (+ pv 4 c)) (* hk (aref jm (+ pv 4 c)))))))
    (when (and (= mode 2) (eq bn :lille-jilliel))       ; EN's column grows its last stretch
      (let ((g (+ 0.75f0 (* 0.25f0 (%lb-ss (/ (- tm (aref v (+ o 4))) (/ (i->f (the fixnum *br-legs-grow*)) 60f0))))))
            (pv (* 16 (ji :pelvis))))
        (declare (single-float g) (fixnum pv))
        (when (< g 1f0) (dotimes (c 3) (setf (aref jm (+ pv 4 c)) (* g (aref jm (+ pv 4 c))))))))
    (when (and (= mode 0) (> (aref v (+ o 5)) 0f0) (> out 0f0))   ; the owl EN's lift let down with the legs
      (let ((dy (* out (aref v (+ o 5)))))
        (declare (single-float dy))
        (dotimes (j +nj+) (setf (aref jm (+ (* 16 j) 13)) (+ dy (aref jm (+ (* 16 j) 13)))))))
    (setf (aref v o) (i->f mode) (aref v (+ o 1)) u (aref v (+ o 6)) lift (aref v (+ o 7)) fold (aref v (+ o 8)) pull)
    nil))
(defun-fast br-deform (e m)
  "His kit's :pose hook (R8, §13; draw.lisp's DRAW-FIGHTER, right after the FK, E's model M, the FK origin in *POSE-AT*):
while his clip is in *BR-SQUASH*, every joint matrix of the posed body is scaled about his feet (the origin), up x SY and
along his right axis x SX (the keys at the clip's frame), so the column, the legs and the front wings / claws (LILLE-DRAW
draws them from these joints) squash and stretch; his facing axis untouched. R10 (§15): the awakened L's charge coils him
lower and wider by its level (%BR-CHARGE-DEPTH: up x 1 - 0.1 d, sideways x 1 + 0.06 d), let go over the dash's load. Any
other clip and move: nothing (bit-identical). R11 (§16): then the stance switch's legs (%BR-LEGS-POSE), and his model kept
for the draw hook (*BR-MODEL*). R15 (§19): the base stance's charged snipe coils him the same way, and its shot throws him
back by its level (*BR-SNIPE-KICK*). Cosmetic. 0 B."
  (let* ((an (model-anim m)) (c (anim-clip an)) (ent (and c (assoc (clip-name c) *br-squash-v*)))
         (f (fighter e)) (dc (%br-charge-depth f t)) (sy 1f0) (sx 1f0))
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
    (let ((mv (and (eq (fighter-state f) :move) (fighter-move f))))   ; R15 (§19): the snipe's kick throws him back by its level
      (when (and mv (eq (fighter-phase f) :main) (member (mv-name mv) *br-snipe-moves*))
        (let* ((a (- (the fixnum (fighter-sf f)) (the fixnum (mv-s mv))))
               (d (* (the single-float (nth (the fixnum (position (mv-name mv) *br-snipe-moves*)) *br-snipe-kick*))
                     (cond ((< a 0) 0f0) ((< a 3) (%lb-ss (/ (i->f a) 3f0))) (t (- 1f0 (%lb-ss (/ (i->f (- a 3)) 14f0))))))))
          (declare (fixnum a) (single-float d))
          (when (> d 0f0)
            (let* ((jm (model-joints m)) (yaw (aref *pose-at* 3)) (bx (* d (f-sin yaw))) (bz (* d (f-cos yaw))))
              (declare (type f32vec jm) (single-float yaw bx bz))
              (dotimes (j +nj+)                         ; (back: his facing is (-sin yaw, -cos yaw))
                (let ((o (* 16 j)))
                  (declare (fixnum o))
                  (setf (aref jm (+ o 12)) (+ (aref jm (+ o 12)) bx) (aref jm (+ o 14)) (+ (aref jm (+ o 14)) bz)))))))))
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
    (setf (svref *br-model* (fighter-side f)) m)       ; (R11, §16: the draw hook's clip reads)
    (%br-legs-pose f (fighter-side f) m)                ; (R11, §16: the stance switch's legs)
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
(零距離砲擊's blast, R6, §11: 「砲擊不要發射光束，直接在爆炸點炸開光球來表示」; the awakened K route's L L shots, R8, §13): a jade /
gold flash ball with a small white heart on the first two frames (R12, the user 2026-10-11: 「我希望架式 K > L 的砲擊每下都是
代表色（玉綠或是黃金色）」: the flash white and the core 0.62 of the shell before), then the ball swelling over its first
third, its jade / gold shell in a dark rim round a small white heart (0.28 of it) that shrinks away, eroding over its last half, dark smoke puffs rising and thinning from frame 6, a new drawing
every two frames. Single-float forms (a macro: 0 B)."
  `(let* ((%x ,x) (%y ,y) (%z ,z) (%a ,a) (%life ,life) (%r ,r) (%pal ,pal)
          (%d (i->f (* 2 (floor %a 2))))                 ; (on twos)
          (%u (/ %d (i->f %life)))
          (%es (* %r (+ 0.55f0 (* 0.6f0 (%lb-ss (* 3f0 %u))))))   ; (swells over the first third)
          (%k (- 1f0 (%lb-ss (/ (- %u 0.45f0) 0.55f0))))          ; (erodes over the last half)
          (%sd (+ ,sd %d)))
     (declare (fixnum %a %life) (single-float %x %y %z %r %pal %d %u %es %k %sd))
     (if (< %a 2)
         (progn (fx-disc %x %y %z (* 0.55f0 %r) 0.05f0 %sd %pal 0.98f0 :push 0.45f0)   ; (the flash: a jade / gold ball,
                (fx-disc %x %y %z (* 0.18f0 %r) 0.04f0 (+ %sd 1f0) +pal-hit+ 0.95f0 :push 0.5f0))   ;  a white heart, R12)
         (progn                                        ; (the ball of light: no spikes, no line toward him)
           (fx-disc %x %y %z (* 1.08f0 %es) 0.06f0 (+ %sd 3f0) +pal-ink+ (* 0.6f0 %k) :push 0.2f0)   ; (its dark rim)
           (fx-disc %x %y %z %es 0.05f0 %sd %pal %k :push 0.3f0)                               ; (the shell)
           (let ((%cr (* %es (- 0.28f0 (* 0.28f0 (%lb-ss (/ %u 0.45f0)))))))                  ; (the white heart: small, R12)
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

;;; ---------------------------------------------------------------- R15 (DUEL_LILLE_V3 §19): the base stance's looks
;; The user 2026-10-11: 「用覺醒狀態的系統邏輯與動作模組的設計風格重製常態模式」 (「蓄力狙擊」, 「槍鬥術」, 「槍身重揮」). The base
;; form's stance L is one charged snipe, its J the gun-kata's point-blank shots, its K the rifle swung heavy. Their looks, read
;; off his move, its frame and the frames L was held (cosmetic): the charge's tells at the muzzle (BR-CHARGE, the kit's
;; :charge hook in place of the generic fire charge), the shot by its level (%BR-SNIPE-LOOK; the 4 / 12 / 31 m line itself
;; is LB-LOOK's, from BR-SHOT-FIRE's hazard of the move's :len), the coil and the kick (BR-DEFORM), the gun-kata's
;; point-blank blasts and the swings' impacts (%BR-KATA-LOOK; Diagramm's smear is the generic blade trail's).
(defparameter *br-snipe-moves* '(:br-s-l1 :br-s-l1-2 :br-s-l1-3)
  "The base stance's L, the charged snipe (R15), and the copies its release starts at level 2 / 3 (barro.lisp
BR-S-SNIPE-RELEASE): the charge's coil (BR-DEFORM, %BR-CHARGE-DEPTH) and tells (BR-CHARGE); after the release the shot's
level is the move's place in this list (%BR-SNIPE-LOOK, the kick in BR-DEFORM).")
(defparameter *br-snipe-kick* '(0.06 0.16 0.42)
  "The snipe's kick by its level 1 / 2 / 3: he is thrown back this far (m, drawn only: BR-DEFORM) over the 3 frames from the
shot, then eased back over 14.")
(defparameter *br-kata-moves* '(:br-s-j1 :br-s-j2 :br-s-j3 :br-s-k1 :br-s-k2 :br-s-k3)
  "The base stance's melee openers (R15): the gun-kata's point-blank shots (J, the first three) and the rifle swung (K): a
blast / an impact at the muzzle from the hit frame S (%BR-KATA-LOOK).")
(declaim (type f32vec *br-mz* *br-gp* *br-armed*))
(defvar *br-mz* (make-f32 3) "Scratch: Diagramm's muzzle (a joint point of the drawn body) ...")
(defvar *br-gp* (make-f32 3) "... and its grip.")
(defvar *br-armed* (make-f32 2) "Per side: 1 while a gun-kata shot's crack is still to sound (its move before S), else 0.")
(declaim (type f32vec *br-hit-at*))
(defvar *br-hit-at* (make-f32 18)
  "Per side (9 each): where a swing's struck end was on its hit frame S ([0..2]) and on S + 1 ([3..5], K3's floor): the
impact stays there while the rifle swings on (%BR-KATA-LOOK); [6..8] the muzzle on the snipe's shot frame (%BR-SNIPE-LOOK:
its line stays there while the kick throws the rifle up).")
(defmacro %br-barrel! (jm)
  "Diagramm's muzzle and grip of the posed joints JM into *BR-MZ* / *BR-GP* (0 B)."
  `(let ((%jm ,jm))
     (joint-point! *br-mz* %jm (ji :weapon-r) 0f0 0f0 -1.75f0)
     (joint-point! *br-gp* %jm (ji :weapon-r) 0f0 0f0 0f0)))

(defun-fast br-charge (e rdt)
  "His kit's :charge hook (draw.lisp: while a move of his base form, Diagramm in hand, is held; R15, DUEL_LILLE_V3 §19,
「蓄力狙擊」): the snipe's charge tells by the frames held (FIGHTER-HOLD; the levels at *BR-W-L-LEVELS*' 20 / 40), drawn after
his draw hook (BR-DRAW: his place and the opponent's, *BR-AT*): on the opponent, at his chest on the line, the reticle's
four brackets closing in over each level (ink at level 1, jade from 2, turned 45 deg a level; from level 2 a ring of ticks
round them; locked at the top with a white heart); the aim light from the muzzle to that point (level 1 a faint grey line,
2 jade, 3 the jade line on to the wall with a white core); light gathering into the muzzle (5 / 8 / 11 motes) and its glow
from level 2; the scope's glint at his eye, bigger by the level; the level-up flash (a white ball and a star burst at the
muzzle, a ring of shards off the reticle; bigger at 3) over 10 frames from the level's frame held. Cosmetic. 0 B."
  (declare (single-float rdt))
  (setf rdt 0f0)                                        ; (unused: the hook's signature)
  (let* ((f (fighter e)) (mv (fighter-move f)))
    (when (and mv (member (mv-name mv) *br-snipe-moves*))
      (let* ((h (fighter-hold f)) (lvs *br-w-l-levels*) (la (the fixnum (first lvs))) (lb (the fixnum (second lvs)))
             (lv (%br-l-level h)) (side (fighter-side f)) (jm (model-joints (model e))) (mz *br-mz*) (gp *br-gp*) (pa *pose-at*)
             (at *br-at*) (o (* 8 side)) (rt (camera-right *camera*)) (up (camera-upv *camera*)) (sc (aref *lb-v* 31))
             (pal (if (= lv 1) +pal-ink+ +pal-jade+)) (fl (i->f (mod (floor h 2) 2)))
             (p (f-clamp (/ (i->f (- h (case lv (1 0) (2 la) (t lb)))) (i->f (- lb la))) 0f0 1f0))
             (yaw (aref pa 3)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw)))
             (dist (f-max 1f0 (f-hypot (- (aref at (+ o 2)) (aref at o)) (- (aref at (+ o 3)) (aref at (+ o 1))))))
             (tx (+ (aref pa 0) (* dist ux))) (ty (+ (aref pa 1) (* 1.25f0 sc))) (tz (+ (aref pa 2) (* dist uz))))
        (declare (fixnum h la lb lv side o) (type f32vec jm mz gp pa at rt up)
                 (single-float sc pal fl p yaw ux uz dist tx ty tz))
        (%br-barrel! jm)
        (let* ((mx (aref mz 0)) (my (aref mz 1)) (mzz (aref mz 2))
               (dx (- mx (aref gp 0))) (dy (- my (aref gp 1))) (dz (- mzz (aref gp 2))) (dl (f-max 1f-4 (f-hypot dx dy dz)))
               (bx (/ dx dl)) (by (/ dy dl)) (bz (/ dz dl)))
          (declare (single-float mx my mzz dx dy dz dl bx by bz))
          ;; the reticle on him: four brackets closing in, a ring of ticks from level 2, the lock
          (let ((r (* sc (+ 0.42f0 (* 0.9f0 (- 1f0 (%lb-ss p)))))) (rot (* 0.785f0 (i->f (1- lv)))))
            (declare (single-float r rot))
            (dotimes (q 4)
              (let* ((an (+ rot (* 1.5708f0 (i->f q)))) (cq (f-cos an)) (sq (f-sin an))
                     (ox (+ (* cq (aref rt 0)) (* sq (aref up 0)))) (oy (+ (* cq (aref rt 1)) (* sq (aref up 1))))
                     (oz (+ (* cq (aref rt 2)) (* sq (aref up 2)))))
                (declare (single-float an cq sq ox oy oz))
                (fx-shard (+ tx (* r ox)) (+ ty (* r oy)) (+ tz (* r oz)) (- ox) (- oy) (- oz) (* sc 0.5f0) (* sc 0.1f0) 0.03f0
                          (+ 710f0 (i->f q)) pal 0.97f0 :push 0.9f0)))
            (when (>= lv 2)
              (let ((rr (+ r (* sc 0.3f0))))
                (declare (single-float rr))
                (dotimes (q 12)
                  (let* ((an (+ (* 0.5236f0 (i->f q)) (* 0.02f0 (i->f h)))) (cq (f-cos an)) (sq (f-sin an))
                         (ox (+ (* cq (aref rt 0)) (* sq (aref up 0)))) (oy (+ (* cq (aref rt 1)) (* sq (aref up 1))))
                         (oz (+ (* cq (aref rt 2)) (* sq (aref up 2)))))
                    (declare (single-float an cq sq ox oy oz))
                    (fx-shard (+ tx (* rr ox)) (+ ty (* rr oy)) (+ tz (* rr oz)) (- sq) cq 0f0 (* sc 0.2f0) (* sc 0.045f0) 0.02f0
                              (+ 714f0 (i->f q)) +pal-jade+ (if (= lv 3) 0.95f0 0.75f0) :push 0.9f0)))))
            (when (and (= lv 3) (>= p 1f0))
              (fx-disc tx ty tz (* sc (+ 0.12f0 (* 0.04f0 fl))) 0.03f0 727f0 +pal-hit+ 0.95f0 :push 0.95f0)
              (fx-disc tx ty tz (* sc 0.24f0) 0.05f0 728f0 +pal-jade+ 0.75f0 :push 0.92f0)))
          ;; the aim light, the muzzle to him (level 3: on to the wall)
          (let* ((wl (%lb-wall mx mzz ux uz)) (len (if (= lv 3) (f-min wl 31f0) (f-max 0.4f0 (- dist 0.3f0)))))
            (declare (single-float wl len))
            (toon-ribbon ((+ mx (* 0.1f0 ux)) my (+ mzz (* 0.1f0 uz))) ((* (- len 0.1f0) ux) (- ty my) (* (- len 0.1f0) uz))
                         ((* sc (case lv (1 0.014f0) (2 0.026f0) (t 0.045f0))) (* sc (case lv (1 0.01f0) (2 0.018f0) (t 0.03f0))))
                         :heat (1f0 0.8f0) :seed -730f0 :wob 0.01f0 :pal (if (= lv 1) +pal-steel+ +pal-jade+)
                         :k (* (if (= lv 1) 0.55f0 0.9f0) (+ 0.8f0 (* 0.2f0 fl))) :k1 (if (= lv 1) 0.35f0 0.7f0) :segs 2)
            (when (= lv 3)
              (toon-ribbon ((+ mx (* 0.1f0 ux)) my (+ mzz (* 0.1f0 uz))) ((* (- len 0.1f0) ux) (- ty my) (* (- len 0.1f0) uz))
                           ((* sc 0.01f0) (* sc 0.007f0)) :heat (1f0 1f0) :seed -731f0 :wob 0f0 :pal +pal-hit+ :k 0.9f0 :k1 0.7f0
                           :segs 2)))
          ;; light gathering into the muzzle, its glow
          (dotimes (i (+ 2 (* 3 lv)))
            (let* ((fi (i->f i)) (ph (/ (i->f (mod (+ h (* 5 i)) 16)) 16f0)) (an (+ (* 2.39996f0 fi) (* 0.11f0 (i->f h))))
                   (r (* sc (- 1.2f0 (* 1.1f0 ph)))) (ca (* r (f-cos an))) (sa (* r (f-sin an))) (fw (* 0.5f0 r))
                   (k (* (%lb-ss (* 4f0 ph)) (- 1f0 (%lb-ss (/ (- ph 0.82f0) 0.18f0))))))
              (declare (single-float fi ph an r ca sa fw k))
              (fx-star (+ mx (* ca (aref rt 0)) (* sa (aref up 0)) (* fw bx)) (+ my (* ca (aref rt 1)) (* sa (aref up 1)) (* fw by))
                       (+ mzz (* ca (aref rt 2)) (* sa (aref up 2)) (* fw bz)) 0.03f0 (* sc 0.12f0) 4 (* 0.5f0 fi) 0f0 0f0 0.05f0
                       (+ 700f0 fi) pal (* 0.95f0 k) :push 0.4f0)))
          (when (>= lv 2)
            (fx-disc mx my mzz (* sc (+ 0.11f0 (* 0.08f0 (i->f (- lv 2))) (* 0.025f0 fl))) 0.1f0 716f0 +pal-jade+ 0.85f0 :push 0.4f0)
            (when (= lv 3) (fx-disc mx my mzz (* sc (+ 0.06f0 (* 0.015f0 fl))) 0.05f0 718f0 +pal-hit+ 0.95f0 :push 0.45f0)))
          ;; the scope's glint at his eye
          (joint-point! gp jm (ji :head) 0.035f0 0.05f0 -0.12f0)
          (let ((g (* sc (case lv (1 0.14f0) (2 0.28f0) (t 0.5f0)) (+ 0.8f0 (* 0.2f0 (i->f (mod h 3)))))))
            (declare (single-float g))
            (fx-star (aref gp 0) (aref gp 1) (aref gp 2) (* 0.07f0 g) g 4 (+ 0.785f0 (* 0.03f0 (i->f h))) 0f0 0f0 0.02f0 717f0
                     +pal-hit+ 0.95f0 :push 0.6f0))
          ;; the level-up flash
          (let ((u (cond ((<= la h (+ la 9)) (i->f (- h la))) ((<= lb h (+ lb 9)) (i->f (- h lb))) (t -1f0))))
            (declare (single-float u))
            (when (>= u 0f0)
              (let* ((t1 (/ u 10f0)) (k (- 1f0 t1)) (big (if (>= h lb) 1.6f0 1f0)))
                (declare (single-float t1 k big))
                (when (< u 2f0) (fx-disc mx my mzz (* sc big 0.45f0) 0.05f0 735f0 +pal-hit+ (- 0.98f0 (* 0.3f0 u)) :push 0.5f0))
                (fx-star mx my mzz (* sc 0.15f0) (* sc big (+ 0.6f0 (* 1.2f0 (%lb-ss t1)))) (if (>= h lb) 12 8) (* 0.3f0 (i->f h))
                         0f0 0f0 0.1f0 736f0 +pal-jade+ k :push 0.45f0)
                (fx-star mx my mzz (* sc 0.08f0) (* sc big (+ 0.3f0 (* 0.8f0 (%lb-ss t1)))) 6 0.2f0 0f0 0f0 0.08f0 737f0 +pal-hit+ k
                         :push 0.5f0)
                (let ((rr (* sc big (+ 0.5f0 (* 1.1f0 (%lb-ss t1))))))   ; (a ring of shards off the reticle)
                  (declare (single-float rr))
                  (dotimes (q 8)
                    (let* ((an (+ 0.39f0 (* 0.785f0 (i->f q)))) (cq (f-cos an)) (sq (f-sin an))
                           (ox (+ (* cq (aref rt 0)) (* sq (aref up 0)))) (oy (+ (* cq (aref rt 1)) (* sq (aref up 1))))
                           (oz (+ (* cq (aref rt 2)) (* sq (aref up 2)))))
                      (declare (single-float an cq sq ox oy oz))
                      (fx-shard (+ tx (* rr ox)) (+ ty (* rr oy)) (+ tz (* rr oz)) ox oy oz (* sc 0.36f0) (* sc 0.07f0) 0.04f0
                                (+ 740f0 (i->f q)) +pal-jade+ k :push 0.9f0)))))))))))
  nil)

(defun-fast %br-snipe-look (e f side mv)
  "The snipe's shot (a move in *BR-SNIPE-MOVES*, its main phase) by its level, from the shot (S) for 18 frames, at the muzzle
of the drawn body on the shot frame (*BR-HIT-AT*) and along his facing (*POSE-AT*): level 1 a short point-blank burst (a white flash, a jade star, a cone of
sparks, smoke); level 2 a bigger flash and a tracer, a jade comet with a white core running the 12 m in 3 frames; level 3
the 萬物貫通 muzzle blast (a big white flash, a jade star of 12, an ink one), a jade band with a white core along the line to
the wall thinning away, rings of shards bursting off it at 1.5 / 5 / 10 m, smoke. The line itself is LB-LOOK's. R16 (DUEL_LILLE_V3
§20, 「增加第 1 階 L 射擊的前搖」): before the shot, from the release (level 1's 16 frames, the copies' 8), the charge's aim light
held on him by the level and the scope's glint growing, flaring with a white tick at the muzzle over the last 3 frames (the
squeeze). 0 B."
  (declare (fixnum side))
  (let* ((a (- (the fixnum (fighter-sf f)) (the fixnum (mv-s mv)))) (lv (1+ (the fixnum (position (mv-name mv) *br-snipe-moves*)))))
    (declare (fixnum a lv))
    (when (< a 0)                                       ; R16 (§20): the wind-up from the release to the crack
      (let* ((jm (model-joints (model e))) (mz *br-mz*) (gp *br-gp*) (pa *pose-at*) (at *br-at*) (o (* 8 side))
             (sc (aref *lb-v* 31)) (yaw (aref pa 3)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw))) (s (the fixnum (mv-s mv)))
             (dist (f-max 1f0 (f-hypot (- (aref at (+ o 2)) (aref at o)) (- (aref at (+ o 3)) (aref at (+ o 1))))))
             (ty (+ (aref pa 1) (* 1.25f0 sc))) (fl (i->f (mod (floor (the fixnum (fighter-sf f)) 2) 2)))
             (u (f-clamp (/ (i->f (+ s a)) (i->f (max 1 s))) 0f0 1f0))   ; (0 at the release, 1 at the crack)
             (q (if (>= a -3) (/ (i->f (+ a 4)) 3f0) 0f0)))              ; (the squeeze: the last 3 frames)
        (declare (type f32vec jm mz gp pa at) (fixnum o s) (single-float sc yaw ux uz dist ty fl u q))
        (%br-barrel! jm)
        (let* ((mx (aref mz 0)) (my (aref mz 1)) (mzz (aref mz 2))
               (wl (%lb-wall mx mzz ux uz)) (len (if (= lv 3) (f-min wl 31f0) (f-max 0.4f0 (- dist 0.3f0)))))
          (declare (single-float mx my mzz wl len))
          ;; the aim light held on him (the charge's, by the level), steadier as the crack nears
          (toon-ribbon ((+ mx (* 0.1f0 ux)) my (+ mzz (* 0.1f0 uz))) ((* (- len 0.1f0) ux) (- ty my) (* (- len 0.1f0) uz))
                       ((* sc (case lv (1 0.014f0) (2 0.026f0) (t 0.045f0))) (* sc (case lv (1 0.01f0) (2 0.018f0) (t 0.03f0))))
                       :heat (1f0 0.8f0) :seed -732f0 :wob 0.01f0 :pal (if (= lv 1) +pal-steel+ +pal-jade+)
                       :k (* (if (= lv 1) 0.55f0 0.9f0) (+ 0.85f0 (* 0.15f0 (if (> q 0f0) 1f0 fl)))) :k1 (if (= lv 1) 0.35f0 0.7f0) :segs 2)
          ;; the scope's glint at his eye, growing over the wind-up and flaring on the squeeze
          (joint-point! gp jm (ji :head) 0.035f0 0.05f0 -0.12f0)
          (let ((g (* sc (+ (case lv (1 0.12f0) (2 0.24f0) (t 0.42f0)) (* 0.1f0 u) (* 0.35f0 q)))))
            (declare (single-float g))
            (fx-star (aref gp 0) (aref gp 1) (aref gp 2) (* 0.07f0 g) g 4 (+ 0.785f0 (* 0.4f0 q)) 0f0 0f0 0.02f0 (+ 881f0 (i->f side))
                     +pal-hit+ 0.95f0 :push 0.6f0))
          (when (> q 0f0)                               ; (the squeeze: a white tick at the muzzle)
            (fx-disc mx my mzz (* sc (+ 0.04f0 (* 0.05f0 q))) 0.05f0 (+ 883f0 (i->f side)) +pal-hit+ (* 0.9f0 q) :push 0.5f0)))))
    (when (<= 0 a 17)
      (let* ((jm (model-joints (model e))) (mz *br-mz*) (pa *pose-at*) (sc (aref *lb-v* 31))
             (yaw (aref pa 3)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw)))
             (fa (i->f a)) (sd (+ 750f0 (* 40f0 (i->f side)))))
        (declare (type f32vec jm mz pa) (single-float sc yaw ux uz rx rz fa sd))
        (%br-barrel! jm)
        (let ((ha *br-hit-at*) (ho (+ 6 (* 9 side))))   ; (the shot's muzzle kept from S: the kick throws the rifle up)
          (declare (type f32vec ha) (fixnum ho))
          (when (= a 0) (setf (aref ha ho) (aref mz 0) (aref ha (+ ho 1)) (aref mz 1) (aref ha (+ ho 2)) (aref mz 2)))
          (setf (aref mz 0) (aref ha ho) (aref mz 1) (aref ha (+ ho 1)) (aref mz 2) (aref ha (+ ho 2))))
        (let* ((mx (aref mz 0)) (my (aref mz 1)) (mzz (aref mz 2)) (big (case lv (1 1f0) (2 1.35f0) (t 2f0))))
          (declare (single-float mx my mzz big))
          (when (< a 2)                                   ; the flash
            (fx-disc (+ mx (* 0.15f0 ux)) my (+ mzz (* 0.15f0 uz)) (* sc big 0.26f0) 0.05f0 sd +pal-hit+ (- 0.98f0 (* 0.3f0 fa))
                     :push 0.5f0)
            (fx-star mx my mzz (* sc 0.1f0) (* sc big 0.55f0) (if (= lv 3) 12 7) (* 0.7f0 (i->f lv)) 0f0 0f0 0.12f0 (+ sd 1f0)
                     +pal-jade+ 0.95f0 :push 0.4f0)
            (when (>= lv 2)
              (fx-star mx my mzz (* sc 0.14f0) (* sc big 0.75f0) 9 0.3f0 0f0 0f0 0.15f0 (+ sd 2f0) +pal-ink+ 0.9f0 :push 0.3f0)))
          (when (< a 4)                                   ; the sparks thrown forward
            (dotimes (i (+ 3 (* 2 lv)))
              (let* ((fi (i->f i)) (sp (* 0.6f0 (- (hash01 fi (+ sd 3f0)) 0.5f0))) (el (* 0.5f0 (- (hash01 fi (+ sd 4f0)) 0.5f0)))
                     (d (* big (+ 0.3f0 (* 0.35f0 fa (+ 0.6f0 (hash01 fi (+ sd 5f0)))))))
                     (vx (+ ux (* sp rx))) (vz (+ uz (* sp rz))))
                (declare (single-float fi sp el d vx vz))
                (fx-shard (+ mx (* d vx)) (+ my (* d el)) (+ mzz (* d vz)) vx el vz (* sc 0.22f0 big) (* sc 0.025f0) 0.05f0
                          (+ sd 10f0 fi) (if (= lv 1) +pal-hit+ +pal-jade+) (- 1f0 (* 0.22f0 fa)) :push 0.3f0))))
          (when (and (= lv 2) (< a 4))                    ; the tracer
            (let* ((wl (%lb-wall mx mzz ux uz)) (len (f-min wl 12f0)) (hd (f-min len (+ 0.6f0 (* 5.5f0 (+ fa 1f0)))))
                   (tl (f-max 0.6f0 (- (+ 0.6f0 (* 5.5f0 (+ fa 1f0))) 4.5f0))))
              (declare (single-float wl len hd tl))
              (when (> hd tl)
                (%streak (+ mx (* tl ux)) my (+ mzz (* tl uz)) (+ mx (* hd ux)) my (+ mzz (* hd uz)) 0.1f0 +pal-jade+ 0.95f0 (+ sd 20f0))
                (%streak (+ mx (* tl ux)) my (+ mzz (* tl uz)) (+ mx (* hd ux)) my (+ mzz (* hd uz)) 0.04f0 +pal-hit+ 0.95f0 (+ sd 21f0)))))
          (when (= lv 3)                                  ; the 萬物貫通 band and its rings
            (let* ((wl (%lb-wall mx mzz ux uz)) (len (f-min wl 31f0)) (w (* sc (+ 0.03f0 (* 0.24f0 (- 1f0 (%lb-ss (/ fa 14f0)))))))
                   (k (- 1f0 (%lb-ss (/ (- fa 8f0) 9f0)))))
              (declare (single-float wl len w k))
              (toon-ribbon ((+ mx (* 0.2f0 ux)) my (+ mzz (* 0.2f0 uz))) ((* (- len 0.2f0) ux) 0f0 (* (- len 0.2f0) uz)) (w (* 0.7f0 w))
                           :heat (1f0 0.8f0) :seed (- -760f0 fa) :wob 0.03f0 :pal +pal-jade+ :k (* 0.98f0 k) :k1 (* 0.85f0 k) :segs 3)
              (when (< a 7)
                (toon-ribbon ((+ mx (* 0.2f0 ux)) my (+ mzz (* 0.2f0 uz))) ((* (- len 0.2f0) ux) 0f0 (* (- len 0.2f0) uz))
                             ((* 0.35f0 w) (* 0.25f0 w)) :heat (1f0 1f0) :seed (- -761f0 fa) :wob 0.02f0 :pal +pal-hit+
                             :k 0.95f0 :k1 0.85f0 :segs 3))
              (when (< a 9)
                (dotimes (j 3)
                  (let* ((dd (case j (0 1.5f0) (1 5f0) (t 10f0))) (rr (* sc (+ 0.25f0 (* 0.16f0 fa)))) (kk (- 1f0 (/ fa 9f0))))
                    (declare (single-float dd rr kk))
                    (when (< dd len)
                      (dotimes (q 8)
                        (let* ((an (+ (* 0.785f0 (i->f q)) (* 0.4f0 (i->f j)))) (cx (f-cos an)) (sy (f-sin an)))
                          (declare (single-float an cx sy))
                          (fx-shard (+ mx (* dd ux) (* rr cx rx)) (+ my (* rr sy)) (+ mzz (* dd uz) (* rr cx rz)) (* cx rx) sy (* cx rz)
                                    (* sc 0.2f0) (* sc 0.03f0) 0.04f0 (+ sd 30f0 (i->f q) (* 8f0 (i->f j))) +pal-jade+ (* 0.9f0 kk)
                                    :push 0.3f0)))))))))
          (when (<= 2 a 16)                               ; the smoke off the muzzle
            (let ((u (/ (- fa 2f0) 14f0)))
              (declare (single-float u))
              (dotimes (i lv)
                (let ((fi (i->f i)))
                  (declare (single-float fi))
                  (fx-disc (+ mx (* 0.2f0 fi ux)) (+ my (* 0.4f0 u) (* 0.08f0 fi)) (+ mzz (* 0.2f0 fi uz)) (* sc big (+ 0.08f0 (* 0.14f0 u)))
                           0.25f0 (+ sd 50f0 fi) +pal-smoke+ (* 0.7f0 (- 1f0 u)) :push 0.2f0))))))))
    nil))

(defun-fast %br-kata-look (e f side mv)
  "The base stance's melee openers (a move in *BR-KATA-MOVES*, its main phase), from the hit frame S at the muzzle of the
drawn body: J (槍鬥術) the point-blank shot: a white flash, an ink star round a jade one, sparks thrown along the barrel,
smoke rising, and the gun's crack once (armed before S: *BR-ARMED*); K (槍身重揮) the struck end's impact: an ink star round
a white one and ink shards over 3 frames, and K3's smash into the floor: dust puffs, a ring and chips where the muzzle meets
it. 0 B (but the one crack a shot)."
  (declare (fixnum side))
  (let* ((sf (fighter-sf f)) (s (mv-s mv)) (a (- sf s)) (pos (the fixnum (position (mv-name mv) *br-kata-moves*))) (gun (< pos 3)))
    (declare (fixnum sf s a pos))
    (if (< a 0)
        (setf (aref *br-armed* side) 1f0)
        (when (and gun (> (aref *br-armed* side) 0.5f0))
          (setf (aref *br-armed* side) 0f0)
          (sfx-on :lb-crack e)))
    (when (<= 0 a 14)
      (let* ((jm (model-joints (model e))) (mz *br-mz*) (gp *br-gp*) (sc (aref *lb-v* 31)) (fa (i->f a))
             (sd (+ 800f0 (* 40f0 (i->f side)) (* 7f0 (i->f pos)))))
        (declare (type f32vec jm mz gp) (single-float sc fa sd))
        (%br-barrel! jm)
        (let* ((mx (aref mz 0)) (my (aref mz 1)) (mzz (aref mz 2))
               (dx (- mx (aref gp 0))) (dy (- my (aref gp 1))) (dz (- mzz (aref gp 2))) (dl (f-max 1f-4 (f-hypot dx dy dz)))
               (bx (/ dx dl)) (by (/ dy dl)) (bz (/ dz dl)))
          (declare (single-float mx my mzz dx dy dz dl bx by bz))
          (if gun
              (progn
                (when (< a 2)                             ; the point-blank blast
                  (fx-disc (+ mx (* 0.12f0 bx)) (+ my (* 0.12f0 by)) (+ mzz (* 0.12f0 bz)) (* sc 0.3f0) 0.05f0 sd +pal-hit+
                           (- 0.98f0 (* 0.3f0 fa)) :push 0.5f0)
                  (fx-star mx my mzz (* sc 0.12f0) (* sc 0.62f0) 7 (* 0.9f0 (i->f pos)) 0f0 0f0 0.15f0 (+ sd 1f0) +pal-ink+ 0.92f0
                           :push 0.35f0)
                  (fx-star mx my mzz (* sc 0.08f0) (* sc 0.4f0) 6 (* 0.4f0 (i->f pos)) 0f0 0f0 0.1f0 (+ sd 2f0) +pal-jade+ 0.95f0
                           :push 0.45f0))
                (when (< a 4)                             ; sparks along the barrel
                  (dotimes (i 4)
                    (let* ((fi (i->f i)) (d (+ 0.2f0 (* 0.3f0 fa (+ 0.6f0 (hash01 fi (+ sd 3f0))))))
                           (ox (* 0.3f0 (- (hash01 fi (+ sd 4f0)) 0.5f0))) (oy (* 0.3f0 (- (hash01 fi (+ sd 5f0)) 0.5f0))))
                      (declare (single-float fi d ox oy))
                      (fx-shard (+ mx (* d bx) ox) (+ my (* d by) oy) (+ mzz (* d bz)) bx by bz (* sc 0.2f0) (* sc 0.022f0) 0.05f0
                                (+ sd 10f0 fi) +pal-hit+ (- 1f0 (* 0.22f0 fa)) :push 0.3f0))))
                (when (<= 1 a 12)                         ; the smoke rising off it
                  (let ((u (/ (- fa 1f0) 11f0)))
                    (declare (single-float u))
                    (dotimes (i 2)
                      (let ((fi (i->f i)))
                        (declare (single-float fi))
                        (fx-disc (+ mx (* 0.15f0 fi bx)) (+ my (* 0.35f0 u) (* 0.06f0 fi)) (+ mzz (* 0.15f0 fi bz))
                                 (* sc (+ 0.07f0 (* 0.12f0 u))) 0.25f0 (+ sd 20f0 fi) +pal-smoke+ (* 0.65f0 (- 1f0 u)) :push 0.2f0))))))
              (let* ((ha *br-hit-at*) (ho (* 9 side)))   ; (the struck point kept from S, the floor's from S + 1)
                (declare (type f32vec ha) (fixnum ho))
                (when (= a 0) (setf (aref ha ho) mx (aref ha (+ ho 1)) my (aref ha (+ ho 2)) mzz))
                (when (= a 1) (setf (aref ha (+ ho 3)) mx (aref ha (+ ho 4)) my (aref ha (+ ho 5)) mzz))
               (let ((ix (aref ha ho)) (iy (aref ha (+ ho 1))) (iz (aref ha (+ ho 2))) (gx (aref ha (+ ho 3))) (gz (aref ha (+ ho 5))))
                (declare (single-float ix iy iz gx gz))
                (when (< a 3)                             ; the struck end's impact
                  (let ((k (- 1f0 (* 0.28f0 fa))))
                    (declare (single-float k))
                    (fx-star ix iy iz (* sc 0.16f0) (* sc (+ 0.6f0 (* 0.2f0 fa))) 9 (* 0.7f0 (i->f pos)) 0f0 0f0 0.15f0 (+ sd 1f0)
                             +pal-ink+ k :push 0.35f0)
                    (when (< a 2)
                      (fx-star ix iy iz (* sc 0.1f0) (* sc 0.38f0) 7 0.2f0 0f0 0f0 0.1f0 (+ sd 2f0) +pal-hit+ 0.95f0 :push 0.45f0))
                    (let ((rt (camera-right *camera*)) (up (camera-upv *camera*)))   ; (ink chips thrown out round it)
                      (declare (type f32vec rt up))
                      (dotimes (i 5)
                        (let* ((fi (i->f i)) (an (+ (* 1.2566f0 fi) (* 0.5f0 (hash01 fi (+ sd 3f0))))) (d (* sc (+ 0.3f0 (* 0.25f0 fa))))
                               (cx (f-cos an)) (sy (f-sin an))
                               (ox (+ (* cx (aref rt 0)) (* sy (aref up 0)))) (oy (+ (* cx (aref rt 1)) (* sy (aref up 1))))
                               (oz (+ (* cx (aref rt 2)) (* sy (aref up 2)))))
                          (declare (single-float fi an d cx sy ox oy oz))
                          (fx-shard (+ ix (* d ox)) (+ iy (* d oy)) (+ iz (* d oz)) ox oy oz (* sc 0.22f0) (* sc 0.04f0) 0.05f0
                                    (+ sd 10f0 fi) +pal-ink+ k :push 0.3f0))))))
                (when (and (= pos 5) (<= 1 a 14))         ; K3: the smash into the floor
                  (let* ((pa *pose-at*) (gy (aref pa 1)) (u (/ (- fa 1f0) 13f0)) (k (- 1f0 (%lb-ss u))))
                    (declare (type f32vec pa) (single-float gy u k))
                    (%tring gx gy gz (* sc (+ 0.3f0 (* 0.9f0 (%lb-ss (* 2f0 u))))) (* sc 0.05f0) +pal-ink+ (* 0.8f0 k) (+ sd 30f0))
                    (dotimes (i 5)
                      (let* ((fi (i->f i)) (an (+ (* 1.2566f0 fi) 0.3f0)) (r (* sc (+ 0.2f0 (* 0.7f0 u)))))
                        (declare (single-float fi an r))
                        (fx-disc (+ gx (* r (f-cos an))) (+ gy 0.1f0 (* 0.5f0 u)) (+ gz (* r (f-sin an))) (* sc (+ 0.1f0 (* 0.2f0 u)))
                                 0.25f0 (+ sd 40f0 fi) +pal-dust+ (* 0.75f0 k) :push 0.2f0)))
                    (when (< a 6)
                      (dotimes (i 4)
                        (let* ((fi (i->f i)) (an (+ (* 1.5708f0 fi) 0.6f0)) (h (* 0.5f0 fa (- 1.2f0 (* 0.15f0 fa)))))
                          (declare (single-float fi an h))
                          (fx-shard (+ gx (* 0.3f0 fa (f-cos an))) (+ gy 0.05f0 (f-max 0f0 h)) (+ gz (* 0.3f0 fa (f-sin an)))
                                    (f-cos an) 1f0 (f-sin an) (* sc 0.14f0) (* sc 0.05f0) 0.1f0 (+ sd 50f0 fi) +pal-ink+ 0.9f0
                                    :push 0.2f0))))))))))))
    nil))

;; R11 (DUEL_LILLE_V3 §16, the user 2026-10-11 on v66: 「現在的架式 J > L 看起來依舊是射擊？」): the J route's L L rebuilt as
;; whips. R10's lash was a straight line from his chest to the opponent for 3 frames (it read as a beam, a shot). Now the
;; striking front wing (the owl: its claw) runs on into a long tapered lash, a thick-to-thin chain of ribbon segments with
;; small blade segments along its root two thirds (the wing's glass carried on, a snake sword), that is wound up behind him and
;; swung through a big arc with overlapping action (each point of it follows the swing's angle a little later than the one
;; before it: the base leads, the wave runs down it, the tip trails and snaps), cracks on him on the hit frame S (the tip
;; pulled onto the point of his line at the opponent's distance, a burst there), then falls slack and is drawn back in.
;; Three different lashes: JL1 a flat swing from his right, JL2 a backhand from high on his left down across him, JL3 an
;; overhead crack straight down (the longest, the heaviest). Draw-time only, read off the clip's frame (the hit is still the
;; 31 m line, barro.lisp BR-SHOT-FIRE; the clips' own stretch *BR-W-STRETCH* is what the host tip test reads).
(defparameter *br-whip-max* 31.0 "R10 (§15): the whip reaches at most this far (m: the line's 31 m, barro.lisp *BR-X-LEN*) ...")
(defparameter *br-whip-up* 1.1 "... its crack this high over his floor (m: the opponent's chest).")
(defun %br-lash-keys (keys)
  "KEYS ((frame value) ...) as an f32vec (frame value ...)."
  (coerce (mapcar #'f32 (apply #'append keys)) 'f32vec))
(defparameter *br-lash-n* 16 "The lash's segments (*BR-LASH-P* holds its N + 1 points).")
(defparameter *br-lashes*
  '((:br-e-jf1 :g 0 :plane (1.0 0.25) :lag 1.6 :swing 3.2 :w 0.1 :crack 1.0
     :theta ((0 35) (2.5 120) (4 150) (5 140) (5.6 100) (6.4 0) (7.2 -35) (8 -50) (9.5 -72) (12 -80) (16 -40) (20 20) (24 35))
     :wind ((0 0.08) (2 0.45) (4 0.85) (5.5 1) (11 1) (17 0.45) (24 0))
     :reach ((0 0) (6.5 0) (8 1) (10.5 1) (16 0))
     :sag ((0 0.4) (3 0.12) (5 0) (10.5 0) (13 0.55) (19 0.95) (24 1))
     :wave ((0 0.15) (4 0.05) (5.5 0) (10.5 0) (13 0.45) (19 0.3) (24 0.1)))
    (:br-e-jf2 :g 1 :plane (-0.75 0.66) :lag 1.6 :swing 3.2 :w 0.1 :crack 1.0
     :theta ((0 -20) (2.5 80) (4 140) (5 140) (5.6 100) (6.4 0) (7.2 -35) (8 -50) (9.5 -70) (12 -75) (16 -40) (20 0) (24 15))
     :wind ((0 0.08) (2 0.45) (4 0.85) (5.5 1) (11 1) (17 0.45) (24 0))
     :reach ((0 0) (6.5 0) (8 1) (10.5 1) (16 0))
     :sag ((0 0.4) (3 0.12) (5 0) (10.5 0) (13 0.55) (19 0.95) (24 1))
     :wave ((0 0.15) (4 0.05) (5.5 0) (10.5 0) (13 0.45) (19 0.3) (24 0.1)))
    (:br-e-jf3 :g 0 :plane (0.5 0.87) :lag 2.0 :swing 3.8 :w 0.12 :crack 1.4
     :theta ((0 -10) (2.5 90) (3.8 150) (4.6 160) (5.3 110) (6 0) (6.8 -30) (8 -42) (10 -50) (13 -48) (18 -25) (22 -5) (26 0))
     :wind ((0 0.1) (2.5 0.6) (4.5 1) (12 1) (19 0.4) (26 0))
     :reach ((0 0) (6.5 0) (8 1) (11 1) (18 0))
     :sag ((0 0.3) (3 0.1) (4.5 0) (11 0) (14 0.7) (20 1) (26 1))
     :wave ((0 0.1) (4 0) (11 0) (14 0.5) (21 0.3) (26 0.1))))
  "R11 (DUEL_LILLE_V3 §16): the J route's L L whips by clip (the owl's :br-oe-jf* the same keys on its claws): :g the
striking wing (0 right, 1 left); :plane the swing's side axis (his right, up) squared to the line to the target (the
angle 0 points at the crack's point, + toward this axis); :lag the frames the tip's angle trails the base's (s^1.4 along it:
the overlapping action); :swing its length while wound up and swinging (m; at the crack it is pulled onto the point, as
long as the distance); :w its half-width at the root (m, to 0.1 of it at the tip); :crack the burst's size. The keys,
by the clip's frame (S 8): :theta the base's swing angle (degrees, a C1 spline through them), :wind its share of the swing
length, :reach the share of the rest of the distance (the lash shot out to him on the crack), :sag its droop (slack),
:wave a wave running down it, out of the swing's plane (slack).")
(declaim (type list *br-lash-v*))
(defparameter *br-lash-v*
  (loop for (c . p) in *br-lashes*
        for v = (vector (let ((h (make-f32 10)))
                          (setf (aref h 0) (f32 (getf p :g)) (aref h 1) (f32 (first (getf p :plane)))
                                (aref h 2) (f32 (second (getf p :plane))) (aref h 3) (f32 (getf p :lag))
                                (aref h 4) (f32 (getf p :swing)) (aref h 5) 8f0 (aref h 6) (f32 (getf p :w))
                                (aref h 8) (f32 (getf p :crack)))
                          h)
                        (%br-lash-keys (getf p :theta)) (%br-lash-keys (getf p :wind)) (%br-lash-keys (getf p :reach))
                        (%br-lash-keys (getf p :sag)) (%br-lash-keys (getf p :wave)))
        collect (cons c v)
        collect (cons (intern (concatenate 'string "BR-OE-" (subseq (symbol-name c) 5)) :keyword)   ; (the owl's twin)
                      (let ((v2 (copy-seq v)) (h (copy-seq (svref v 0))))
                        (setf (aref h 7) 1f0 (aref h 6) (* 1.1f0 (aref h 6)) (svref v2 0) h)
                        v2)))
  "*BR-LASHES* as (clip . #(header theta wind reach sag wave)), the header an f32vec [0] g, [1 2] the plane, [3] the lag,
[4] the swing length, [5] S, [6] the root half-width, [7] 1 = the owl (from the claw), [8] the crack's size; the owl's
twins (:br-oe-jf*) with its lash 1.1 x wider at the claw. Read without consing.")
(declaim (type f32vec *br-lv* *br-lash-p*))
(defvar *br-lv* (make-f32 48)
  "The whip's scratch (draw time): [0] the clip's frame; [1..3] the root H (the wing's drawn tip / the claw), [4..6] the
wing's direction there (unit), [7..9] A (unit, H -> the crack's point), [10..12] B (the swing's side axis, unit, square to
A), [13..15] A x B, [16..18] the crack's point T, [19] the stub length (the owl: its stretch), [20] the floor, [21] |T - H|;
[29] the chain's time, [30..35] the tip and the mid point a frame back, [36..41] half a frame back; [42] a key query's
time, [43] its value.")
(defvar *br-lash-p* (make-f32 (* 3 17)) "The lash's points (x y z each), root first.")
(defmacro %br-pow (x y) `(ffi:c-inline (,x ,y) (:float :float) :float "powf(fmaxf(#0,0.0f),#1)" :one-liner t))
(defun-fast %br-key! (kv herm)
  "*BR-LV* [43] = the keys KV (frame value ...) at the frame *BR-LV* [42], held past the ends: HERM 1 a C1 spline (the
tangents the neighbours' slope), else linear. 0 B."
  (declare (type f32vec kv) (fixnum herm))
  (let* ((lv *br-lv*) (tq (aref lv 42)) (n (floor (length kv) 2)) (r (aref kv 1)))
    (declare (type f32vec lv) (single-float tq r) (fixnum n))
    (cond ((<= tq (aref kv 0)) (setf r (aref kv 1)))
          ((>= tq (aref kv (* 2 (1- n)))) (setf r (aref kv (1- (* 2 n)))))
          (t (dotimes (i (1- n))
               (let ((t0 (aref kv (* 2 i))) (t1 (aref kv (+ 2 (* 2 i)))))
                 (declare (single-float t0 t1))
                 (when (and (<= t0 tq) (< tq t1))
                   (let* ((v0 (aref kv (1+ (* 2 i)))) (v1 (aref kv (+ 3 (* 2 i)))) (dt (f-max 1f-4 (- t1 t0)))
                          (u (/ (- tq t0) dt)))
                     (declare (single-float v0 v1 dt u))
                     (if (= herm 1)
                         (let* ((m0 (if (> i 0)
                                        (/ (- v1 (aref kv (- (* 2 i) 1))) (f-max 1f-4 (- t1 (aref kv (- (* 2 i) 2)))))
                                        (/ (- v1 v0) dt)))
                                (m1 (if (< (+ i 2) n)
                                        (/ (- (aref kv (+ 5 (* 2 i))) v0) (f-max 1f-4 (- (aref kv (+ 4 (* 2 i))) t0)))
                                        (/ (- v1 v0) dt)))
                                (u2 (* u u)) (u3 (* u2 u)))
                           (declare (single-float m0 m1 u2 u3))
                           (setf r (+ (* (+ (* 2f0 u3) (* -3f0 u2) 1f0) v0) (* (+ u3 (* -2f0 u2) u) dt m0)
                                      (* (+ (* -2f0 u3) (* 3f0 u2)) v1) (* (- u3 u2) dt m1))))
                         (setf r (+ v0 (* u (- v1 v0)))))))))))
    (setf (aref lv 43) r))
  nil)
(defun-fast %br-lash-chain! (ent)
  "The lash of the *BR-LASH-V* entry ENT at the chain's time *BR-LV* [29] into *BR-LASH-P* (*BR-LV* [1..21] set): its
length (the stub, the wound-up swing length by :wind, at most 1.15 x the distance to the crack's point but 1.8 m, the
rest of the way to him by :reach); each point s along it at the
swing angle the base had lag x s^1.4 frames before (the overlapping action), plus the slack's droop and wave; its first
fifth bent from the wing's own direction; kept off the floor; then, round the crack (S - 2.5 .. S + 4), turned and scaled
about its root so its tip lands on the crack's point T. 0 B."
  (declare (type simple-vector ent))
  (let* ((lv *br-lv*) (p *br-lash-p*) (hd (svref ent 0)) (n (the fixnum *br-lash-n*)) (tc (aref lv 29))
         (lag (aref hd 3)) (sw (f-min (aref hd 4) (f-max 1.8f0 (* 1.15f0 (aref *br-lv* 21))))) (s0 (aref hd 5)) (wind 0f0) (reach 0f0) (sag 0f0) (wave 0f0) (ln 0f0)
         (hx (aref lv 1)) (hy (aref lv 2)) (hz (aref lv 3)) (qx (aref lv 4)) (qy (aref lv 5)) (qz (aref lv 6))
         (ax (aref lv 7)) (ay (aref lv 8)) (az (aref lv 9)) (bx (aref lv 10)) (by (aref lv 11)) (bz (aref lv 12))
         (nx (aref lv 13)) (ny (aref lv 14)) (nz (aref lv 15)) (fl (+ (aref lv 20) 0.03f0)) (dd (aref lv 21)))
    (declare (type f32vec lv p hd) (fixnum n)
             (single-float tc lag sw s0 wind reach sag wave ln hx hy hz qx qy qz ax ay az bx by bz nx ny nz fl dd))
    (setf (aref lv 42) tc)
    (%br-key! (svref ent 2) 0) (setf wind (aref lv 43))
    (%br-key! (svref ent 3) 0) (setf reach (aref lv 43))
    (%br-key! (svref ent 4) 0) (setf sag (aref lv 43))
    (%br-key! (svref ent 5) 0) (setf wave (aref lv 43))
    (setf ln (+ (aref lv 19) (* wind sw) (* reach (f-max 0f0 (- dd sw)))))
    (setf (aref p 0) hx (aref p 1) hy (aref p 2) hz)
    (let ((step (/ ln (i->f n))) (px hx) (py hy) (pz hz))
      (declare (single-float step px py pz))
      (loop for i fixnum from 1 to n do
        (let* ((s (/ (i->f i) (i->f n))) (lg (* lag (%br-pow s 1.4f0))))
          (declare (single-float s lg))
          (setf (aref lv 42) (- tc lg))
          (%br-key! (svref ent 1) 1)
          (let* ((th (* 0.017453292f0 (aref lv 43))) (c (f-cos th)) (sn (f-sin th))
                 (wv (* wave s (f-sin (* 6.2831855f0 (- (* 1.3f0 s) (* 0.16666667f0 tc))))))
                 (sg (* sag (%br-pow s 1.2f0)))
                 (dx (+ (* c ax) (* sn bx) (* wv nx))) (dy (- (+ (* c ay) (* sn by) (* wv ny)) sg))
                 (dz (+ (* c az) (* sn bz) (* wv nz)))
                 (k (%lb-ss (/ s 0.2f0))) (k1 (- 1f0 k))
                 (ex (+ (* k1 qx) (* k dx))) (ey (+ (* k1 qy) (* k dy))) (ez (+ (* k1 qz) (* k dz)))
                 (el (f-max 1f-5 (f-hypot ex ey ez))) (o (* 3 i)))
            (declare (single-float th c sn wv sg dx dy dz k k1 ex ey ez el) (fixnum o))
            (setf px (+ px (* step (/ ex el))) py (f-max fl (+ py (* step (/ ey el)))) pz (+ pz (* step (/ ez el)))
                  (aref p o) px (aref p (+ o 1)) py (aref p (+ o 2)) pz)))))
    ;; the crack: the tip pulled onto T (turned about the root and scaled), all of it at the hit frames, eased either side
    (let ((wt (* (%lb-ss (/ (- tc (- s0 2.5f0)) 2f0)) (- 1f0 (%lb-ss (/ (- tc (+ s0 1.5f0)) 2.5f0))))))
      (declare (single-float wt))
      (when (> wt 0f0)
        (let* ((o (* 3 n)) (ux (- (aref p o) hx)) (uy (- (aref p (+ o 1)) hy)) (uz (- (aref p (+ o 2)) hz))
               (vx (- (aref lv 16) hx)) (vy (- (aref lv 17) hy)) (vz (- (aref lv 18) hz))
               (ul (f-max 1f-4 (f-hypot ux uy uz))) (vl (f-max 1f-4 (f-hypot vx vy vz)))
               (kx (- (* uy vz) (* uz vy))) (ky (- (* uz vx) (* ux vz))) (kz (- (* ux vy) (* uy vx)))
               (kl (f-hypot kx ky kz)) (phi (* wt (f-atan2 kl (+ (* ux vx) (* uy vy) (* uz vz)))))
               (sc (+ 1f0 (* wt (- (/ vl ul) 1f0)))) (c (f-cos phi)) (sn (f-sin phi)))
          (declare (fixnum o) (single-float ux uy uz vx vy vz ul vl kx ky kz kl phi sc c sn))
          (if (> kl 1f-5) (setf kx (/ kx kl) ky (/ ky kl) kz (/ kz kl)) (setf kx 0f0 ky 1f0 kz 0f0))
          (loop for i fixnum from 1 to n do
            (let* ((q (* 3 i)) (rx (- (aref p q) hx)) (ry (- (aref p (+ q 1)) hy)) (rz (- (aref p (+ q 2)) hz))
                   (kd (* (+ (* kx rx) (* ky ry) (* kz rz)) (- 1f0 c))))
              (declare (fixnum q) (single-float rx ry rz kd))
              (setf (aref p q) (+ hx (* sc (+ (* rx c) (* sn (- (* ky rz) (* kz ry))) (* kx kd))))
                    (aref p (+ q 1)) (+ hy (* sc (+ (* ry c) (* sn (- (* kz rx) (* kx rz))) (* ky kd))))
                    (aref p (+ q 2)) (+ hz (* sc (+ (* rz c) (* sn (- (* kx ry) (* ky rx))) (* kz kd))))))))))
    nil))
(defun-fast %br-whip-lash (side)
  "After LILLE-DRAW (R11, DUEL_LILLE_V3 §16): while a J route L L whip clip (*BR-LASH-V*) plays, its lash from the striking
wing's drawn tip (JILLIEL: *LB-WF* [74..79], LILLE-DRAW's; the owl: the claw, its stretch the lash's stub, %LB-LASHES
skipping it: [81 82]) at the clip's frame (%BR-LASH-CHAIN!): the ribbon segments, jade (the owl's gold) with a white core,
thick to thin, small blade segments along its root two thirds; its tip's and middle's arc smeared over the swing (the chain a
frame and half a frame back); the crack's burst on the point of his line at the opponent's distance (*BR-AT*: the line's
31 m at most, the opponent's chest height) from S over 5 frames, bigger with the distance; nothing else plays. 0 B."
  (declare (fixnum side))
  (let* ((m (svref *br-model* side)) (an (and m (model-anim m))) (c (and an (anim-clip an)))
         (ent (and c (assoc (clip-name c) *br-lash-v*))))
    (when ent
      (let* ((jm (model-joints m)) (ev (cdr ent)) (hd (svref ev 0)) (lv *br-lv*) (p *br-lash-p*) (w *lb-wf*) (pa *pose-at*) (at *br-at*) (o (* 8 side))
             (n (the fixnum *br-lash-n*)) (tf (* 60f0 (the single-float (anim-time an)))) (s0 (aref hd 5))
             (g (f->i (aref hd 0))) (owl (> (aref hd 7) 0.5f0)) (sc (aref *lb-v* 31))
             (yaw (aref pa 3)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw)))
             (dist (if (> (aref at (+ o 4)) 0.5f0)
                       (f-min (the single-float *br-whip-max*)
                              (f-max 1f0 (f-hypot (- (aref at (+ o 2)) (aref at o)) (- (aref at (+ o 3)) (aref at (+ o 1))))))
                       3f0))
             (fl (- (aref pa 1) (aref *br-legs* (+ (* 10 side) 6))))   ; (his floor: the drawn lift off, *BR-LEGS* [6])
             (tx (+ (aref pa 0) (* dist fx))) (ty (+ fl (the single-float *br-whip-up*))) (tz (+ (aref pa 2) (* dist fz)))
             (pal (if owl +pal-gold+ +pal-jade+)) (wb (* sc (aref hd 6))) (sd (+ 800f0 (* 40f0 (i->f side)) (* 20f0 (i->f g))))
             (zz (* (aref hd 8) (+ 1f0 (* 0.035f0 (f-min dist 20f0))))))
        (declare (type simple-vector ev) (type f32vec jm hd lv p w pa at) (fixnum o n g)
                 (single-float tf s0 sc yaw fx fz rx rz dist fl tx ty tz pal wb sd zz))
        ;; the root H and the wing's direction there
        (if owl
            (let* ((h (* 16 (if (= g 0) (ji :hand-r) (ji :hand-l)))) (b (* 16 (if (= g 0) (ji :lower-arm-r) (ji :lower-arm-l))))
                   (hx (aref jm (+ h 12))) (hy (aref jm (+ h 13))) (hz (aref jm (+ h 14)))
                   (dx (- hx (aref jm (+ b 12)))) (dy (- hy (aref jm (+ b 13)))) (dz (- hz (aref jm (+ b 14))))
                   (dl (f-max 1f-4 (f-hypot dx dy dz))))
              (declare (fixnum h b) (single-float hx hy hz dx dy dz dl))
              (setf (aref lv 1) hx (aref lv 2) hy (aref lv 3) hz (aref lv 4) (/ dx dl) (aref lv 5) (/ dy dl) (aref lv 6) (/ dz dl)
                    (aref lv 19) (+ 0.15f0 (* sc (aref w (+ 72 g))))))
            (let* ((q *lb-p*) (to (if (= g 0) 74 77)))
              (declare (type f32vec q) (fixnum to))
              (if (= g 0) (joint-point! q jm (ji :chest) 0.07f0 0.3f0 0.13f0) (joint-point! q jm (ji :chest) -0.07f0 0.3f0 0.13f0))
              (let* ((hx (aref w to)) (hy (aref w (+ to 1))) (hz (aref w (+ to 2)))
                     (dx (- hx (aref q 0))) (dy (- hy (aref q 1))) (dz (- hz (aref q 2))) (dl (f-max 1f-4 (f-hypot dx dy dz))))
                (declare (single-float hx hy hz dx dy dz dl))
                (setf (aref lv 1) hx (aref lv 2) hy (aref lv 3) hz (aref lv 4) (/ dx dl) (aref lv 5) (/ dy dl) (aref lv 6) (/ dz dl)
                      (aref lv 19) 0.15f0))))
        ;; the swing's frame: A at the crack's point, B its side axis (his right / up by :plane) squared to A, N = A x B
        (let* ((ax (- tx (aref lv 1))) (ay (- ty (aref lv 2))) (az (- tz (aref lv 3))) (al (f-max 1f-4 (f-hypot ax ay az)))
               (ax (/ ax al)) (ay (/ ay al)) (az (/ az al))
               (b0x (* (aref hd 1) rx)) (b0y (aref hd 2)) (b0z (* (aref hd 1) rz))
               (bd (+ (* b0x ax) (* b0y ay) (* b0z az)))
               (bx (- b0x (* bd ax))) (by (- b0y (* bd ay))) (bz (- b0z (* bd az))) (bl (f-max 1f-4 (f-hypot bx by bz)))
               (bx (/ bx bl)) (by (/ by bl)) (bz (/ bz bl)))
          (declare (single-float ax ay az al b0x b0y b0z bd bx by bz bl))
          (setf (aref lv 7) ax (aref lv 8) ay (aref lv 9) az (aref lv 10) bx (aref lv 11) by (aref lv 12) bz
                (aref lv 13) (- (* ay bz) (* az by)) (aref lv 14) (- (* az bx) (* ax bz)) (aref lv 15) (- (* ax by) (* ay bx))
                (aref lv 16) tx (aref lv 17) ty (aref lv 18) tz (aref lv 20) fl (aref lv 21) al (aref lv 0) tf))
        ;; the swing's smear: the tip and the middle a frame and half a frame back
        (let ((sm (* (%lb-ss (/ (- tf (- s0 3.5f0)) 1.5f0)) (- 1f0 (%lb-ss (/ (- tf (+ s0 1f0)) 1.5f0))))) (mi (* 3 (floor (* 5 n) 8))))
          (declare (single-float sm) (fixnum mi))
          (when (> sm 0.02f0)
            (setf (aref lv 29) (- tf 1f0)) (%br-lash-chain! ev)
            (setf (aref lv 30) (aref p (* 3 n)) (aref lv 31) (aref p (1+ (* 3 n))) (aref lv 32) (aref p (+ 2 (* 3 n)))
                  (aref lv 33) (aref p mi) (aref lv 34) (aref p (1+ mi)) (aref lv 35) (aref p (+ 2 mi)))
            (setf (aref lv 29) (- tf 0.5f0)) (%br-lash-chain! ev)
            (setf (aref lv 36) (aref p (* 3 n)) (aref lv 37) (aref p (1+ (* 3 n))) (aref lv 38) (aref p (+ 2 (* 3 n)))
                  (aref lv 39) (aref p mi) (aref lv 40) (aref p (1+ mi)) (aref lv 41) (aref p (+ 2 mi))))
          (setf (aref lv 29) tf) (%br-lash-chain! ev)
          (when (> sm 0.02f0)
            (dotimes (j 2)
              (let* ((q0 (if (= j 0) 30 33)) (qm (if (= j 0) 36 39)) (pe (if (= j 0) (* 3 n) mi))
                     (x0 (aref lv q0)) (y0 (aref lv (+ q0 1))) (z0 (aref lv (+ q0 2)))
                     (x1 (aref p pe)) (y1 (aref p (+ pe 1))) (z1 (aref p (+ pe 2)))
                     (cx (- (* 2f0 (aref lv qm)) (* 0.5f0 (+ x0 x1)))) (cy (- (* 2f0 (aref lv (+ qm 1))) (* 0.5f0 (+ y0 y1))))
                     (cz (- (* 2f0 (aref lv (+ qm 2))) (* 0.5f0 (+ z0 z1))))
                     (sw (* sc zz (if (= j 0) 0.16f0 0.1f0))))
                (declare (fixnum q0 qm pe) (single-float x0 y0 z0 x1 y1 z1 cx cy cz sw))
                (when (> (f-hypot (- x1 x0) (- y1 y0) (- z1 z0)) 0.3f0)
                  (fx-crescent x0 y0 z0 x1 y1 z1 cx cy cz sw :comet 0.05f0 (+ sd 30f0 (i->f j)) pal (* 0.8f0 sm) :push 0.2f0)
                  (fx-crescent x0 y0 z0 x1 y1 z1 cx cy cz (* 0.35f0 sw) :comet 0.03f0 (+ sd 32f0 (i->f j)) +pal-hit+
                               (* 0.7f0 sm) :push 0.25f0))))))
        ;; the lash: thick to thin, a white core over its first four fifths, blade segments along its root two thirds
        (dotimes (i n)
          (let* ((a (* 3 i)) (b (+ a 3)) (s (/ (i->f i) (i->f n))) (s1 (/ (i->f (1+ i)) (i->f n)))
                 (w0 (* wb (+ 0.1f0 (* 0.9f0 (- 1f0 s))))) (w1 (* wb (+ 0.1f0 (* 0.9f0 (- 1f0 s1)))))
                 (x0 (aref p a)) (y0 (aref p (+ a 1))) (z0 (aref p (+ a 2)))
                 (dx (- (aref p b) x0)) (dy (- (aref p (+ b 1)) y0)) (dz (- (aref p (+ b 2)) z0)) (si (i->f i)))
            (declare (fixnum a b) (single-float s s1 w0 w1 x0 y0 z0 dx dy dz si))
            (toon-ribbon (x0 y0 z0) (dx dy dz) (w0 w1) :heat (1f0 0.9f0) :seed (- -1f0 sd si) :wob 0.03f0 :pal pal :k 0.95f0
                         :segs 1)
            (when (< s 0.8f0)
              (toon-ribbon (x0 y0 z0) (dx dy dz) ((* 0.4f0 w0) (* 0.4f0 w1)) :heat (1f0 1f0) :seed (- -100f0 sd si) :wob 0f0
                           :pal +pal-hit+ :k 0.85f0 :segs 1))
            (when (and (oddp i) (< s 0.7f0))
              (let ((dl (f-max 1f-4 (f-hypot dx dy dz))))
                (declare (single-float dl))
                (fx-shard (+ x0 (* 0.5f0 dx)) (+ y0 (* 0.5f0 dy)) (+ z0 (* 0.5f0 dz)) (/ dx dl) (/ dy dl) (/ dz dl)
                          (f-min (* 0.7f0 sc) (* 2.4f0 dl)) (* 2.2f0 w0) 0.04f0 (+ sd 200f0 si) pal 0.92f0 :push 0.1f0)))))
        ;; the crack on him: a white flash and a star over a jade (gold) one, sparks flung out, from S over 5 frames
        (let ((a (- tf s0)))
          (declare (single-float a))
          (when (and (>= a -0.2f0) (< a 5f0))
            (when (< a 2f0)
              (let ((k (- 1f0 (* 0.45f0 a))))
                (declare (single-float k))
                (fx-star tx ty tz (* 0.06f0 zz) (* zz (+ 0.55f0 (* 0.25f0 a))) 10 (* 0.7f0 a) 0f0 0f0 0.08f0 (+ sd 60f0) pal k
                         :push 0.4f0)
                (fx-star tx ty tz (* 0.04f0 zz) (* zz (+ 0.3f0 (* 0.15f0 a))) 7 (* -0.5f0 a) 0f0 0f0 0.06f0 (+ sd 61f0) +pal-hit+
                         (* 0.98f0 k) :push 0.45f0)
                (when (< a 0.6f0) (fx-disc tx ty tz (* 0.1f0 zz (- 1.2f0 a)) 0.05f0 (+ sd 62f0) +pal-hit+ 0.95f0 :push 0.5f0))))
            (dotimes (j 7)
              (let* ((hj (i->f j)) (u (* 6.2831855f0 (+ (* 0.1428f0 hj) (* 0.08f0 (hash01 hj 7.1f0)))))
                     (v (- (* 1.6f0 (hash01 hj 3.3f0)) 0.6f0)) (cu (f-cos u)) (su (f-sin u))
                     (ex (+ (* cu rx) (* 0.4f0 su fx))) (ey (+ su v)) (ez (+ (* cu rz) (* 0.4f0 su fz)))
                     (el (f-max 1f-4 (f-hypot ex ey ez))) (r (* zz (+ 0.18f0 (* 0.32f0 (f-max 0f0 a))))) (k (- 1f0 (* 0.2f0 a))))
                (declare (single-float hj u v cu su ex ey ez el r k))
                (fx-shard (+ tx (* r (/ ex el))) (+ ty (* r (/ ey el))) (+ tz (* r (/ ez el))) (/ ex el) (/ ey el) (/ ez el)
                          (* 0.26f0 zz) (* 0.03f0 zz) 0.02f0 (+ sd 70f0 hj) (if (evenp j) +pal-hit+ pal) k :push 0.35f0))))))))
  nil)
(defsound :br-whip-crack (:peak 0.95)               ; R11 (§16): the awakened J route L L's crack (BR-SHOT-FIRE): a whip's
  (let ((b (au-buf 0.6)))                            ;  supersonic snap, a slap, then the slack lash swishing back
    (au-mix! b (au-fnoise 0.012 :hp 4000 :decay 0.003) 0.0 1.0)
    (au-mix! b (au-fnoise 0.03 :bp 2200 :q 1.5 :decay 0.008) 0.002 0.7)
    (au-ping! b 0.0 3300 0.025 0.4 :attack 0.0005)
    (au-thump! b 0.0 220 90 0.01 0.04 0.35)
    (au-mix! b (au-whoosh 0.22 5200 1400 :q 1.6 :peak 0.08) 0.04 0.45)
    (au-reverb! b 0.18 :size 0.9)
    b))
(defun-fast %br-whip-reach (f side mv)
  "Before LILLE-DRAW (R10, §15): *LB-WF* [80] the wings' sweep tightness while the awakened L charges (1 + 0.25 x
%BR-CHARGE-DEPTH: the eight wings folding tighter by the level); R11 (§16): [81 82] 1 for the striking claw of a J route L
L whip clip (*BR-LASH-V*): the whip's root (%BR-WHIP-LASH draws its lash on from it; %LB-WINGS thins JILLIEL's blade,
%LB-LASHES skips the owl's comet). Zeroed otherwise (Lille never sets
them). 0 B."
  (declare (fixnum side))
  (let ((w *lb-wf*))
    (declare (type f32vec w))
    (setf (aref w 80) 0f0 (aref w 81) 0f0 (aref w 82) 0f0)
    (when mv
      (when (member (mv-name mv) *br-dash-moves*)
        (setf (aref w 80) (+ 1f0 (* 0.25f0 (%br-charge-depth f nil))))))
    (let* ((m (svref *br-model* side)) (c (and m (anim-clip (model-anim m)))) (ent (and c (assoc (clip-name c) *br-lash-v*))))
      (when ent
        (let ((hd (svref (the simple-vector (cdr ent)) 0)))
          (declare (type f32vec hd))
          (setf (aref w (+ 81 (f->i (aref hd 0)))) 1f0))))
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
(%BR-KIWAMI-LOOK); R10 (§15): the charge's wing sweep handed to LILLE-DRAW (%BR-WHIP-REACH), the L charge's tells
(%BR-CHARGE-LOOK); R11 (§16): the whips' claws flagged for LILLE-DRAW (%BR-WHIP-REACH), the lash after it (%BR-WHIP-LASH),
the stance switch's legs' fold and pull handed to it (*BR-LEGS*, set by his :pose hook); R15 (§19): the base stance's
snipe shot and its gun-kata / swings (%BR-SNIPE-LOOK, %BR-KATA-LOOK; the snipe's charge is his :charge hook, BR-CHARGE)."
  (declare (single-float rdt))
  (let* ((f (fighter e)) (side (fighter-side f)) (mv (and (eq (fighter-state f) :move) (fighter-move f)))
         (c (if mv (%br-chain-clock (mv-name mv) (fighter-sf f)) -1)) (o (* 65 side))
         (awake (member (fighter-form f) '(:jilliel-kin :jilliel :shin-kin :shin))) (n (br-ammo-look e)))
    (declare (fixnum side c o n))
    (setf (lb-fxs side 19) (if awake (i->f (1+ (min 8 n))) 0f0))
    (%br-place! e (fighter-opp f) side)                ; (before LILLE-DRAW: R10's whips read it; R15: the snipe's reticle)
    (%br-whip-reach f side mv)                          ; (R10, §15: *LB-WF* [80..82] for LILLE-DRAW, zeroed after it)
    (let ((lg *br-legs*) (o (* 10 side)))               ; (R11, §16: the stance switch's legs, [89 90])
      (setf (aref *lb-wf* 89) (if (>= (aref lg o) 0f0) (+ 1f0 (aref lg (+ o 7))) 0f0) (aref *lb-wf* 90) (aref lg (+ o 8))))
    (lille-draw e rdt)
    (%br-whip-lash side)                                ; (R11, §16: the J route's L L whips, both forms)
    (let ((w *lb-wf*)) (setf (aref w 80) 0f0 (aref w 81) 0f0 (aref w 82) 0f0 (aref w 89) 0f0 (aref w 90) 0f0))
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
    (when (and mv (eq (fighter-phase f) :main) (eq (fighter-form f) :base))   ; R15 (§19): the base stance's snipe, gun-kata, swings
      (cond ((member (mv-name mv) *br-snipe-moves*) (%br-snipe-look e f side mv))
            ((member (mv-name mv) *br-kata-moves*) (%br-kata-look e f side mv))))
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
L1-2 L1-3 (R15, DUEL_LILLE_V3 §19: the snipe's level 2 / 3 shots) J2 J3 K2 K3 JL1 JL2 JL3 KL1 KL2 KL3 (3 m out, started on
their own, 3 pips; + 20 the front view); 52-56 (R15) the base stance's L, the snipe, in its charge held 15 / 22 / 32 / 43 /
56 frames (level 1, level 2's flash, level 2, level 3's flash, level 3), the sim frozen there at once (82299 lets go: the
release, its shot); 57 (R16, DUEL_LILLE_V3 §20) the base form's attack-state J3 銃口突 (:br-j3, its clip :br-jab) 2.2 m out;
5 / 6 / 7 the base form's attack-state K1 / K2 / K3 (:br-k1 / :br-k2 / :br-k3, each started on its own, K2 / K3 from their
link frame :enter) 2.3 m out. The awakened stances' moves: BR-ART-STANCE."
  (let* ((front (oddp (floor k 20))) (k (if front (- k 20) k)) (owl (or (<= 0 k 4) (<= 10 k 13))))
    (if front (ensure-battle :kenpachi :barro) (ensure-battle :barro :kenpachi))
    (let* ((b (if front *p2* *p1*)) (o (if front *p1* *p2*)) (g (gauges b)))
      (setf *br-keep-owl* owl)
      (force-form b (cond ((or (<= 5 k 7) (<= 15 k 17) (<= 40 k 57)) :base) ((<= 18 k 19) :jilliel) (owl :shin-kin) (t :jilliel-kin)))
      (place *p1* *p2* (cond ((= k 57) 2.2) ((<= 5 k 7) 2.3) ((or (<= 15 k 19) (<= 40 k 56)) 3.0) (t 4.0)))
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
        (15 (start-move b (find-move :br-s-l1) :sig))   ; (R15: a held move, its button L: released at once, level 1)
        (16 (start-move b (find-move :br-s-j1))) (17 (start-move b (find-move :br-s-k1)))
        (18 (start-move b (find-move :br-e-l1))) (19 (start-move b (find-move :br-e-k1)))
        ((40 41 42 43 44 45 46 47 48 49 50 51)
         (br-set-ammo b 3)
         (setf (fighter-charge (fighter b)) (case k (40 30) (41 50) (t 0)))   ; (R15: the snipe's level 2 / 3 as if held)
         (start-move b (find-move (nth (- k 40) '(:br-s-l1-2 :br-s-l1-3 :br-s-j2 :br-s-j3 :br-s-k2 :br-s-k3 :br-s-jl1 :br-s-jl2
                                                  :br-s-jl3 :br-s-kl1 :br-s-kl2 :br-s-kl3)))))
        ((52 53 54 55 56)                              ; (R15: the snipe's charge held, frozen at once)
         (let ((h (nth (- k 52) '(15 22 32 43 56))) (an (model-anim (model b))))
           (start-move b (find-move :br-s-l1) :sig)
           (setf (fighter-hold (fighter b)) h (anim-time an) (/ h 60f0))
           (hitstop 100000)))
        (57 (start-move b (find-move :br-j3)))   ; (R16, §20: the base form's attack-state J3 銃口突, its own clip :br-jab)
        ((5 6 7) (start-move b (find-move (nth (- k 5) '(:br-k1 :br-k2 :br-k3))))))   ; (the base form's attack-state K string,
                                                       ;  each on its own: K2 / K3 from their link frame, :enter)
      (setf *br-art-hold* *br-art-hold-next* *br-art-hold-next* -1))))

(defvar *br-art-front* nil "Debug 82389 (R11): the next BR-ART-STANCE scene puts him as P2 (the front view), the owl's too.")
(defun br-art-stance (m)
  "82320+m: Lille II (P1) 3 m from an idle Kenpachi, 8 wings, Reiatsu and flash step full, his awakened stance's move
started on its own: m 0-14 JILLIEL EN's (L1 L2 L3 J1 J2 J3 K1 K2 K3 JL1 JL2 JL3 KL1 KL2 KL3, *BR-S-SEGS*' order: the
openers' clips :br-en-*, the follow-ups' :br-e-jf* / -kf*), 20-34 the owl EN's (kept without a burst: :br-oen-*, :br-oe-jf* /
-kf*); 40-54 JILLIEL's again as P2, facing the behind camera (the front view). Since R10 (one charged L, no L2 / L3) m 1
(21, 41) sets the same scene with no move started, for a script to hold L (the charge) itself; m 15-17 (35-37, 55-57)
JL1-JL3 6 m out (the whips' reach). R11 (DUEL_LILLE_V3 §16): 82389 first puts the next scene in the front view, any m (the
owl's too)."
  (let* ((front (or (>= m 40) *br-art-front*)) (m (if (>= m 40) (- m 40) m)) (owl (>= m 20))
         (far (<= 15 (if owl (- m 20) m) 17)) (m (if far (- m 6) m))   ; (R10: the whips at 6 m)
         (sn (nth (if owl (- m 20) m) '("L1" "L2" "L3" "J1" "J2" "J3" "K1" "K2" "K3" "JL1" "JL2" "JL3" "KL1" "KL2" "KL3")))
         (idle (= (if owl (- m 20) m) 1))              ; (R10: L held by the script)
         (mv (and sn (gethash (intern (format nil "~a-~a" (if owl "BR-OE" "BR-E") sn) :keyword) *moves*))))
    (setf *br-art-front* nil)
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

(defun br-art-legs (k)
  "82390+k (R11, DUEL_LILLE_V3 §16): the stance switch's legs, Lille II (P1) 3 m from an idle Kenpachi, 8 wings: k 0 / 1
JILLIEL KIN / the owl KIN with the turn into the stance (:br-to-en) started (the legs put away); 2 / 3 JILLIEL EN / the owl
EN with the stance's J1 started (its string ends, back to KIN: the legs let out)."
  (let ((owl (oddp k)) (out (>= k 2)))
    (ensure-battle :barro :kenpachi)
    (let* ((b *p1*) (g (gauges b)))
      (setf *br-keep-owl* owl)
      (force-form b (if out (if owl :shin :jilliel) (if owl :shin-kin :jilliel-kin)))
      (place *p1* *p2* 3.0)
      (setf (gauges-reiatsu g) *reiatsu-max* (gauges-fs g) (f32 *fs-max*)
            (gauges-reishi (gauges *p2*)) (gauges-reishi-max (gauges *p2*)))
      (br-set-ammo b 8)
      (start-move b (find-move (if out (if owl :br-oe-j1 :br-e-j1) :br-to-en)))
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
82320+m his awakened stance's move m on its own (BR-ART-STANCE); 82380+k his special set to k, 0-8 (BR-ART-AMMO: the spend
looks); 82389 the next stance scene in the front view; 82390+k the stance switch's legs (BR-ART-LEGS, R11); 82398 the
consing probe."
  (let ((n (- c 82100)))
    (cond ((< n 100) (br-art-scene n))
          ((< n 199) (setf *br-art-hold-next* (- n 100)))
          ((= n 199) (setf *br-art-hold* -1 *br-art-hold-next* -1 *hitstop* 0))
          ((< n 219) (br-art-cine (* 10 (- n 200))))
          ((<= 220 n 277) (br-art-stance (- n 220)))   ; (R11: to m 57, the front view's JL1-JL3 6 m out)
          ((= n 289) (setf *br-art-front* t))
          ((<= 280 n 288) (br-art-ammo (- n 280)))
          ((<= 290 n 293) (br-art-legs (- n 290)))
          ((= n 298) (br-cons-probe))
          (t (log-msg "duel barro: no debug command ~d" c)))))

(defun br-cons-probe ()
  "82398: bytes consed by 10 draws of P1 Lille II's :draw hook (BR-DRAW, LILLE-DRAW's lookups included), of the spends'
note and looks (%BR-SPEND-NOTE / -LOOK: the pip glint's model lookup aside), of his volley look
at its clock 4 and of a string beat's lines (when a string runs), and of 裁き・極's look (while it runs), of 零距離砲擊's
blast (in an awakened K3), of the whips' stretch and the owl's lashes (R5), of the body's squash (BR-DEFORM, R8) and the
K route's balls (in an awakened KL, R8), the whips' reach and the L charge's tells (R10), the whip's lash and the stance
switch's legs (R11), the base stance's snipe charge, its shot and the gun-kata / swings' looks (R15; a \"barro consing\"
line)."
  (let* ((e *p1*) (f (fighter e)) (side (fighter-side f)) (m (model e)) (jm (model-joints m))
         (mv (and (eq (fighter-state f) :move) (fighter-move f))))
    (macrolet ((per (form) `(let ((c0 (cons-bytes))) (dotimes (i 10) ,form) (- (cons-bytes) c0))))
      (setf (aref *br-armed* side) 0f0)                 ; (R15: the gun-kata's crack is a sound, not a draw)
      (log-msg "barro consing (10 draws, B): form ~a clock ~d draw ~d (Lille's ~d) spends ~d recall ~d beat (lines drive beat) ~a kiwami ~d stretch ~d lashes ~d deform ~d kl-balls ~d dash ~d cuts ~d whip ~d charge ~d legs ~d snipe-charge ~d snipe ~d kata ~d"
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
               (if (and mv (member (mv-name mv) *br-dash-moves*)) (per (%br-charge-look f side mv)) -1)
               (per (%br-legs-pose f side m))
               (if (and mv (member (mv-name mv) *br-snipe-moves*) (eq (fighter-phase f) :hold)) (per (br-charge e 0.016f0)) -1)
               (if (and mv (member (mv-name mv) *br-snipe-moves*)) (per (%br-snipe-look e f side mv)) -1)
               (if (and mv (member (mv-name mv) *br-kata-moves*)) (per (%br-kata-look e f side mv)) -1)))))

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

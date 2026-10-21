;;;; barro-art.lisp — LILLE BARRO II's own clips (docs/duel/DUEL_LILLE_V2.md §7, §12, §17, §22; version 3: DUEL_LILLE_V3.md).
;;;; His art is Lille's, shared by reference (lille-art.lisp: the bodies, Diagramm; lille-clips.lisp: every :lb-* clip; lille-draw.lisp:
;;;; LILLE-DRAW's wings / halos / legs, LB-LOOK's lines and beams); this file holds only the clips Lille never had (the volley
;;;; :br-recall and its strings, the turn, the owl's twins, the stance's swing L1, the base stance's strings). His other art files
;;;; (split out 2026-10-21, refactor round 2): barro-draw.lisp (the draw hook BR-DRAW, the looks, the special resource's HUD row)
;;;; and barro-stills.lisp (the art stills, debug 82100-82399, and BR-CONS-PROBE).
;;;; Everything here is cosmetic: the sim never reads it. Loaded after lille-art / -clips / -draw / -cine (the macros and props) and
;;;; before barro.lisp (whose state and knobs these functions read at draw time); the host FK test reads this file's clips and the
;;;; tables *BR-W-STRETCH* and *BR-SQUASH*.
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
;; 一些速度」; its own clip; the old Lille's :lb-jab went 2026-10-21): the muzzle cross jabbed up into his face, in the base form's
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
;; their own clips (the old Lille's :lb-f1 / -f2 / -f3 went 2026-10-21), the same three ideas exaggerated in the stance clips'
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
         (mv (current-move f))
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
    (let ((mv (current-move f)))   ; R15 (§19): the snipe's kick throws him back by its level
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


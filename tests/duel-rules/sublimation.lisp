(in-package :duel)
;;; ================================================================ SUBLIMATION / SPIRIT DRIVE (DUEL_SUBLIMATION, the user 2026-10-31)
;; the knobs
(check (and (~= *sub-dmg* 0.20) (~= *sub-taken* 0.20) (~= *sub-speed* 0.10) (~= *sub-fs* 0.30) (~= *sub-keep* 0.5) (~= *drive-add* 0.5)))
(check (~= *drive-switch* 0.25))   ; the temporary pointer switch costs 0.25 B (DUEL_SUBLIMATION §17)
;; fill (DUEL_SUBLIMATION §18): the awakening gauge by every source (X), then SUBLIMATION / DRIVE by attacking only (XS)
(check (multiple-value-bind (aw sub dr) (awaken-overflow nil 50.0 0.0 0.0 20.0 5.0) (and (~= aw 70.0) (~= sub 0.0) (~= dr 0.0))))
(check (multiple-value-bind (aw sub dr) (awaken-overflow nil 90.0 0.0 0.0 25.0 25.0) (and (~= aw 100.0) (~= sub 0.0) (~= dr 0.0))))   ; the overflow is dropped
(check (multiple-value-bind (aw sub dr) (awaken-overflow nil 100.0 30.0 0.0 10.0 0.0) (and (~= aw 100.0) (~= sub 30.0) (~= dr 0.0))))  ; taken: nothing
(check (multiple-value-bind (aw sub dr) (awaken-overflow nil 100.0 30.0 0.0 10.0 6.0) (and (~= aw 100.0) (~= sub 42.0) (~= dr 0.0))))
(check (multiple-value-bind (aw sub dr) (awaken-overflow nil 100.0 95.0 0.0 10.0 10.0) (declare (ignore aw)) (and (~= sub 100.0) (~= dr 0.0))))
(check (multiple-value-bind (aw sub dr) (awaken-overflow t 0.0 0.0 0.0 12.0 0.0) (and (~= aw 0.0) (~= sub 0.0) (~= dr 0.0))))
(check (multiple-value-bind (aw sub dr) (awaken-overflow t 0.0 0.0 0.0 12.0 12.0) (and (~= aw 0.0) (~= sub 0.0) (~= dr 24.0))))
(check (multiple-value-bind (aw sub dr) (awaken-overflow t 0.0 0.0 95.0 12.0 12.0) (declare (ignore aw sub)) (~= dr 100.0)))
;; *SUB-GAIN* x2 on SUB / DRIVE (2026-11-07, §20): the overflow lines above
(check (~= *sub-gain* 2.0))
;; attacking: 0.035 x 1.5 per point (about 1905 to fill before x *SUB-GAIN*, §18.1), ORANGE x1.5 on top, 10.5 per Konpaku taken
(check (and (~= *sub-attack-mult* 1.5) (~= (sub-attack-gain 100 0 1.0) 5.25) (~= (sub-attack-gain 100 0 *orange-gain*) 7.875)
            (~= (sub-attack-gain 0 2 1.0) 21.0) (< 1904 (/ 100.0 (sub-attack-gain 1 0 1.0)) 1906)))
;; the bonus fraction: SUB / 100 before, 0.5 x s + 0.5 x DRIVE / 100 after (full B as DRIVE's base)
(check (and (~= (sub-frac nil 0.0 0.0 0.0) 0.0) (~= (sub-frac nil 60.0 0.0 0.0) 0.6) (~= (sub-frac nil 100.0 0.0 0.0) 1.0)))
(check (and (~= (sub-frac t 0.0 1.0 0.0) 0.5) (~= (sub-frac t 0.0 1.0 100.0) 1.0) (~= (sub-frac t 0.0 0.4 100.0) 0.7)
            (~= (sub-frac t 0.0 0.0 0.0) 0.0) (~= (sub-frac t 0.0 0.0 100.0) 0.5)))
;; the boosts at a full gauge: damage x1.2, taken x0.8, and a zero fraction changes nothing
(check (and (~= (getf (sub-taken-mods '(:mult 1.0) 1.0) :mult) 0.8) (~= (getf (sub-taken-mods '(:mult 1.15) 0.5) :mult) (* 1.15 0.9))
            (equal (sub-taken-mods '(:mult 1.0) 0.0) '(:mult 1.0))))
;; hit-damage with the multipliers as APPLY-HIT stacks them: 100 x 1.2 x 0.8 = 96
(check (= 96 (hit-damage 100 (list :mult (* 1.0 (+ 1.0 (* *sub-dmg* 1.0)))) (sub-taken-mods '(:mult 1.0) 1.0) 1 nil)))
;; Ichigo's pointers: the seals, pointer 4 and the 超速連斬 of 2026-10-31 were taken out again (DUEL_SUBLIMATION §16): the original tables
(let ((b (kit :ichigo :base)) (k (kit :ichigo :kessa)))
  (check (and (null (getf (kit-core b) :locks)) (null (getf (kit-core k) :locks))))
  (check (equal (getf (kit-core b) :as-by-press) '(1 1 2 2 3)))
  (check (equal (getf (kit-core k) :as-by-press) '(1 1 2 2 3)))
  (check (and (= 3 (length (getf (kit-core k) :ns))) (= 3 (length (getf (kit-core k) :as)))))
  (check (eq (kit-core-move k :ns 2) (kit-move k :ic-k-n2a)))
  (check (equal (mv-callout (kit-move k :ic-k-n2c)) "GETSUGA TENSHO"))   ; KESSA's NS2c is the Getsuga, not JUJISHO (§19)
  (check (null (kit-hook b :link-ok)))
  (check (null (kit-hook k :link-ok)))
  (check (null (kit-next k :ic-k-j3 :q))))

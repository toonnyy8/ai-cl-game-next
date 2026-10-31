(in-package :duel)
;;; ================================================================ SUBLIMATION / SPIRIT DRIVE (DUEL_SUBLIMATION, the user 2026-10-31)
;; the knobs
(check (and (~= *sub-dmg* 0.20) (~= *sub-taken* 0.20) (~= *sub-speed* 0.10) (~= *sub-fs* 0.30) (~= *sub-keep* 0.5) (~= *drive-add* 0.5)))
;; fill: the awakening gauge first, its overflow into SUBLIMATION, DRIVE once awakened
(check (multiple-value-bind (aw sub dr) (awaken-overflow nil 50.0 0.0 0.0 20.0) (and (~= aw 70.0) (~= sub 0.0) (~= dr 0.0))))
(check (multiple-value-bind (aw sub dr) (awaken-overflow nil 90.0 0.0 0.0 25.0) (and (~= aw 100.0) (~= sub 15.0) (~= dr 0.0))))
(check (multiple-value-bind (aw sub dr) (awaken-overflow nil 100.0 30.0 0.0 10.0) (and (~= aw 100.0) (~= sub 40.0) (~= dr 0.0))))
(check (multiple-value-bind (aw sub dr) (awaken-overflow nil 100.0 95.0 0.0 10.0) (declare (ignore aw)) (and (~= sub 100.0) (~= dr 0.0))))
(check (multiple-value-bind (aw sub dr) (awaken-overflow t 0.0 0.0 0.0 12.0) (and (~= aw 0.0) (~= sub 0.0) (~= dr 12.0))))
(check (multiple-value-bind (aw sub dr) (awaken-overflow t 0.0 0.0 95.0 12.0) (declare (ignore aw sub)) (~= dr 100.0)))
;; the bonus fraction: SUB / 100 before, 0.5 x s + 0.5 x DRIVE / 100 after (full B as DRIVE's base)
(check (and (~= (sub-frac nil 0.0 0.0 0.0) 0.0) (~= (sub-frac nil 60.0 0.0 0.0) 0.6) (~= (sub-frac nil 100.0 0.0 0.0) 1.0)))
(check (and (~= (sub-frac t 0.0 1.0 0.0) 0.5) (~= (sub-frac t 0.0 1.0 100.0) 1.0) (~= (sub-frac t 0.0 0.4 100.0) 0.7)
            (~= (sub-frac t 0.0 0.0 0.0) 0.0) (~= (sub-frac t 0.0 0.0 100.0) 0.5)))
;; the boosts at a full gauge: damage x1.2, taken x0.8, and a zero fraction changes nothing
(check (and (~= (getf (sub-taken-mods '(:mult 1.0) 1.0) :mult) 0.8) (~= (getf (sub-taken-mods '(:mult 1.15) 0.5) :mult) (* 1.15 0.9))
            (equal (sub-taken-mods '(:mult 1.0) 0.0) '(:mult 1.0))))
;; hit-damage with the multipliers as APPLY-HIT stacks them: 100 x 1.2 x 0.8 = 96
(check (= 96 (hit-damage 100 (list :mult (* 1.0 (+ 1.0 (* *sub-dmg* 1.0)))) (sub-taken-mods '(:mult 1.0) 1.0) 1 nil)))
;; Kenpachi's Bankai: DRIVE full opens it, whatever his Konpaku
(check (and (bankai-allowed-p t t) (not (bankai-allowed-p t nil)) (not (bankai-allowed-p nil t))))
;; Ichigo's pointers: the seals, pointer 4 and the 超速連斬 of 2026-10-31 were taken out again (DUEL_SUBLIMATION §16): the original tables
(let ((b (kit :ichigo :base)) (k (kit :ichigo :kessa)))
  (check (and (null (getf (kit-core b) :locks)) (null (getf (kit-core k) :locks))))
  (check (equal (getf (kit-core b) :as-by-press) '(1 1 2 2 3)))
  (check (equal (getf (kit-core k) :as-by-press) '(1 1 2 2 3)))
  (check (and (= 3 (length (getf (kit-core k) :ns))) (= 3 (length (getf (kit-core k) :as)))))
  (check (eq (kit-core-move k :ns 2) (kit-move k :ic-k-n2a)))
  (check (null (kit-hook b :link-ok)))
  (check (null (kit-hook k :link-ok)))
  (check (null (kit-next k :ic-k-j3 :q))))

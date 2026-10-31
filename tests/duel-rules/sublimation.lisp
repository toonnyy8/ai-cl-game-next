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
;; Ichigo's pointers (the user 2026-10-31, DUEL_SUBLIMATION §9): the Shikai's pointer 3 is the Getsuga, sealed until the awakening gauge
;; is full; KESSA's pointer 2 is 超速連斬 (NS2 five cuts 22 / 17 / 12 / 6 / 3 f, AS2 two segments), pointer 4 the Getsuga sealed until
;; SPIRIT DRIVE is full (NS4 = three segments, AS4 = four), the sixth J gated by ichigo-link-ok
(let* ((b (kit :ichigo :base)) (k (kit :ichigo :kessa)) (fb (make-fighter :kit b)) (fk (make-fighter :kit k)))
  (check (equal (core-segments :ic-k-h1) '(:ic-k-h1 :ic-k-h2 :ic-k-h3 :ic-k-h4 :ic-k-h5)))
  (check (equal (mapcar (lambda (n) (mv-s (kit-move k n))) '(:ic-k-h1 :ic-k-h2 :ic-k-h3 :ic-k-h4 :ic-k-h5)) '(22 17 12 6 3)))
  (check (equal (mapcar (lambda (n) (mv-dmg (kit-move k n))) '(:ic-k-h1 :ic-k-h2 :ic-k-h3 :ic-k-h4 :ic-k-h5)) '(20 20 25 25 40)))
  (check (equal (mapcar (lambda (n) (length (core-segments n))) (getf (kit-core k) :as)) '(1 2 3 4)))
  (check (equal (core-segments :ic-k-n2a) '(:ic-k-n2a :ic-k-n2b :ic-k-n2c)))
  (check (equal (mapcar (lambda (n) (kit-class k (kit-move k n))) '(:ic-k-h1 :ic-k-h5 :ic-k-hs-as2 :ic-k-hs-as2b :ic-k-as4 :ic-k-as2b)) '(:ns :ns :as :as :as :as)))
  (check (member :through (mv-flags (kit-move k :ic-k-hs-as2))))
  (check (eq (kit-next k :ic-k-j3 :q) (kit-move k :ic-k-na6)))
  (check (equal (getf (kit-core k) :locks) '((4 . :drive-full))))
  (check (equal (getf (kit-core b) :locks) '((3 . :awaken-full)))))

;; KESSA's press table (the user 2026-10-31: 1 2 2 3 3 4): J1 > AS1, J2-J3 > AS2, J4-J5 > AS3, J6 > AS4
(check (equal (getf (kit-core (kit :ichigo :kessa)) :as-by-press) '(1 2 2 3 3 4)))
(check (equal (mapcar (lambda (n) (core-as-pointer n '(1 2 2 3 3 4))) '(1 2 3 4 5 6)) '(1 2 2 3 3 4)))
;; AS4: all four segments hit (the two charges are cuts since 2026-10-31), only the last launches
(let ((k (kit :ichigo :kessa)))
  (check (every (lambda (n) (plusp (length (mv-hits (kit-move k n))))) '(:ic-k-as4 :ic-k-as4b :ic-k-as2)))   ; (the fourth, the crescent, is a wave: a hazard's hit)
  (check (not (member :ender (mv-flags (kit-move k :ic-k-na6))))))

;; ================================================================ the core triangle (duel/lisp/core.lisp, docs/duel/DUEL_CORE.md)
(in-package :duel)
(setf *core-on* t)
;; the note's table (判定表), attacker's view: row = the attacker's class, column = the defender's
(dolist (r '((:na :na :hit) (:na :ns :cancel) (:na :as :cancel) (:na :sa :absorb)
             (:ns :na :cancel) (:ns :ns :hit) (:ns :as :absorb) (:ns :sa :cancel)
             (:as :na :cancel) (:as :ns :hit)
             (:sa :na :hit) (:sa :ns :cancel)))
  (check (eq (core-verdict (first r) (second r)) (third r))))
(check (eq (core-verdict :na nil) :hit))                          ; a defender outside a classed move: a clean hit
(check (eq (core-verdict :na :na :simul t) :cancel))              ; the same frame: cancel
(check (eq (core-verdict :ns :ns :simul t) :cancel))
(check (eq (core-verdict :na :ns :simul t) :cancel))
;; AS against SA: the later start wins, the same frame cancels
(check (eq (core-verdict :as :sa :att-t 20 :def-t 10) :hit))
(check (eq (core-verdict :as :sa :att-t 10 :def-t 20) :absorb))
(check (eq (core-verdict :sa :as :att-t 10 :def-t 10) :cancel))
(check (eq (core-verdict :sa :as :att-t 30 :def-t 10) :hit))
;; the parallel-play scenarios of the note: NA-NA-NA against NS-NS-NS cancels every step; a swap to AS beats NS, to SA beats NA
(check (and (eq (core-verdict :na :ns) :cancel) (eq (core-verdict :ns :na) :cancel)))
(check (and (eq (core-verdict :as :ns) :hit) (eq (core-verdict :ns :as) :absorb)))       ; the attacker swaps to AS at step 2
(check (and (eq (core-verdict :sa :na) :hit) (eq (core-verdict :na :sa) :absorb)))       ; the SP side swaps to SA
(check (and (eq (core-verdict :as :sa :att-t 5 :def-t 4) :hit) (eq (core-verdict :sa :as :att-t 4 :def-t 5) :absorb)))
;; a gap insert: the attacker's AS against the defender's NA cancels, against his NS wins; SA the other way round
(check (and (eq (core-verdict :as :na) :cancel) (eq (core-verdict :as :ns) :hit)
            (eq (core-verdict :sa :na) :hit) (eq (core-verdict :sa :ns) :cancel)))
;; only a same-class tie bounces
(check (and (core-bounces-p :na :na) (core-bounces-p :ns :ns) (not (core-bounces-p :na :ns))))
;; presses
(check (eq (core-press-class :neutral :attack nil) :na))
(check (eq (core-press-class :neutral :sp nil) :ns))
(check (null (core-press-class :na :attack nil)))                 ; an attack link needs a hit
(check (eq (core-press-class :na :attack t) :na-cont))
(check (null (core-press-class :na :sp nil)))                     ; an AS needs the attack to hit
(check (eq (core-press-class :na :sp t) :as))
(check (eq (core-press-class :ns :sp nil) :ns-cont))              ; an NS continues hit or not
(check (eq (core-press-class :ns :attack nil) :sa))
(check (eq (core-press-class :sa :sp t) :as))
(check (null (core-press-class :sa :sp nil)))
(check (null (core-press-class :as :attack t)))                   ; AS ends the combo
(check (null (core-press-class :as :sp t)))
(check (eq (core-class-after :na-cont) :na))
;; the pointer
(check (equal (mapcar #'core-as-pointer '(0 1 2 3 4)) '(1 1 2 3 3)))
;; the Kikon / Soul Break profiles (base worth 2, 3, 4)
(check (equal (mapcar (lambda (b) (core-kikon-count b 1 nil)) '(2 3 4)) '(1 2 3)))
(check (equal (mapcar (lambda (b) (core-kikon-count b 1 t)) '(2 3 4)) '(1 2 3)))
(check (equal (mapcar (lambda (b) (core-kikon-count b 2 nil)) '(2 3 4)) '(2 3 4)))
(check (equal (mapcar (lambda (b) (core-kikon-count b 2 t)) '(2 3 4)) '(3 4 5)))             ; red == a Soul Break
(check (equal (mapcar (lambda (b) (core-kikon-count b 3 nil)) '(1 2 3 4)) '(1 1 2 3)))
(check (equal (mapcar (lambda (b) (core-soul-break-count b 1)) '(2 3 4)) '(3 4 5)))
(check (equal (mapcar (lambda (b) (core-soul-break-count b 2)) '(2 3 4)) '(3 4 5)))
(check (equal (mapcar (lambda (b) (core-soul-break-count b 3)) '(2 3 4)) '(5 5 5)))          ; the finisher style, capped at 5
(check (= (core-kikon-count 2 2 t) (core-soul-break-count 2 2)))                             ; pointer 2: red = zero
(check (and (core-kikon-cancel-p nil t) (not (core-kikon-cancel-p t t)) (not (core-kikon-cancel-p nil nil))))
;; Ichigo's core moves (DUEL_CORE §9, 2026-10-27): every opening strike has a readable coil, NS2 is the ranged one, each pointer its stance
(let ((k (kit :ichigo :base)))
  (check (every (lambda (n) (>= (mv-s (kit-move k n)) 14)) '(:ic-j1 :ic-n1a :ic-n2a :ic-n3a)))   ; the tells (>= 14 f, 0.23 s)
  (check (> (mv-s (kit-move k :ic-n1a)) (mv-s (kit-move k :ic-n1b))))                               ; later segments are quicker than openers
  (check (and (equal (core-segments :ic-n2a) '(:ic-n2a :ic-n2b :ic-n2c))                       ; NS2: charge, charge, JUJISHO
              (zerop (length (mv-hits (kit-move k :ic-n2a)))) (zerop (length (mv-hits (kit-move k :ic-n2b))))
              (>= (getf (mv-params (kit-move k :ic-n2c)) :range) 10.0)))                              ; the long-range wave
  ;; a charge's gap starts its own SA, classed SA, harder than the plain one, and it goes on into J2 like the SA
  (check (and (eq (mv-sa-move k (kit-move k :ic-n2a)) (kit-move k :ic-sa-g1)) (eq (mv-sa-move k (kit-move k :ic-n2b)) (kit-move k :ic-sa-g2))
              (null (mv-sa-move k (kit-move k :ic-n1a)))
              (every (lambda (n) (eq (kit-class k (kit-move k n)) :sa)) '(:ic-sa :ic-sa-g1 :ic-sa-g2))
              (< (mv-dmg (kit-move k :ic-sa)) (mv-dmg (kit-move k :ic-sa-g1)) (mv-dmg (kit-move k :ic-sa-g2)))
              (every (lambda (n) (kit-next k n :q)) '(:ic-sa :ic-sa-g1 :ic-sa-g2))))
  (check (equal (getf (kit-core k) :stances) '(:ic-st-heavy :ic-tsuki :ic-st-rush)))
  (let ((*core-on* t) (f (make-fighter :kit k)))
    (setf (fighter-ptr f) 1) (check (eq (fighter-stance-clip f) :ic-st-heavy))
    (setf (fighter-ptr f) 2) (check (eq (fighter-stance-clip f) :ic-tsuki))
    (setf (fighter-ptr f) 3) (check (eq (fighter-stance-clip f) :ic-st-rush))
    (let ((core (kit-core k)))                                     ; (no :stances: the kit's own :stance; restored)
      (setf (kit-core k) nil) (check (eq (fighter-stance-clip f) (kit-stance k))) (setf (kit-core k) core))))
;; AS n has n segments, all of class AS; only the last knocks down / launches (DUEL_CORE §6, 2026-10-27)
(let ((k (kit :ichigo :base)))
  (check (equal (mapcar (lambda (n) (length (core-segments n))) (getf (kit-core k) :as)) '(1 2 3)))
  (check (every (lambda (n) (every (lambda (m) (eq (kit-class k (kit-move k m)) :as)) (core-segments n))) (getf (kit-core k) :as)))
  (check (every (lambda (n) (let ((segs (core-segments n)))
                              (and (every (lambda (m) (not (member (hw-react (svref (mv-hits (kit-move k m)) 0)) '(:knockdown :launch :crumple)))) (butlast segs))
                                   (let ((h (mv-hits (kit-move k (car (last segs))))))   ; (AS2's last: a wave since 2026-10-28)
                                     (or (zerop (length h)) (member (hw-react (svref h (1- (length h)))) '(:knockdown :launch)))))))
                (getf (kit-core k) :as))))
;; a charged SA's x on its string (J2 / J3 / the AS), not on itself, a hazard, or a new opener (DUEL_CORE §6, 2026-10-27)
(let* ((k (kit :ichigo :base)) (f (make-fighter :kit k)) (sa (kit-move k :ic-sa-g2)) (j2 (kit-move k :ic-j2)) (as (kit-move k :ic-as1)))
  (core-note-start! f sa (kit-move k :ic-n2b))
  (check (= (fighter-charge-mult f) 1.7f0))
  (check (= (core-charge-mult f sa t nil) 1f0))                    ; the SA's own hit: its :dmg already
  (core-note-start! f j2 sa)
  (check (and (= (core-charge-mult f j2 t nil) 1.7f0) (= (core-charge-mult f j2 t t) 1f0)))   ; J2 charged; a hazard not
  (core-note-start! f as j2)
  (check (= (core-charge-mult f as t nil) 1.7f0))                  ; the AS after it too
  (core-note-start! f (kit-move k :ic-j1) nil)
  (check (= (core-charge-mult f (kit-move k :ic-j1) t nil) 1f0)))  ; a fresh opener: gone
;; KESSA's NS3: three presses (no hits of his own: the clones strike), every gap's SA his lunge; his stances by pointer (DUEL_CORE §6)
(let ((k (kit :ichigo :kessa)))
  (check (equal (core-segments :ic-k-n3a) '(:ic-k-n3a :ic-k-n3b :ic-k-n3c)))
  (check (eq (kit-core-move k :ns 3) (kit-move k :ic-k-n3a)))
  (check (every (lambda (n) (and (zerop (length (mv-hits (kit-move k n)))) (eq (mv-sa-move k (kit-move k n)) (kit-move k :ic-k-sa))))
                '(:ic-k-n3a :ic-k-n3b :ic-k-n3c)))
  (check (equal (getf (kit-core k) :stances) '(:ic-k-st-chain :ic-tsuki :ic-k-stance)))
  (check (eq (kit-core-move (kit :ichigo :base) :ns 3) (kit-move (kit :ichigo :base) :ic-n3a))))   ; the Shikai keeps RANGETSU
;; DEFCLIP-MIRROR: a key's right / left channels swapped, the middle's twist and the root's yaw negated
(let* ((a (find-clip :ic-k-xa)) (b (find-clip :ic-k-xb)) (n +pose-n+) (pa (engine::clip-poses a)) (pb (engine::clip-poses b)) (k (* 3 n)))
  (check (and (= (engine::clip-n a) (engine::clip-n b)) (= (clip-dur a) (clip-dur b))))
  (check (and (= (aref pb (+ k (* 3 6))) (aref pa (+ k (* 3 11))))                       ; arm-r flex <- arm-l flex
              (= (aref pb (+ k (* 3 11) 2)) (aref pa (+ k (* 3 6) 2)))                   ; arm-l side <- arm-r side
              (= (aref pb (+ k (* 3 2) 1)) (- (aref pa (+ k (* 3 2) 1))))                ; chest twist
              (= (aref pb (+ k +root+ 3)) (- (aref pa (+ k +root+ 3)))))))               ; root yaw
;; every form's SAs go on into its own J2 (KESSA's inherited the Shikai's; 2026-10-28)
(dolist (cf '((:ichigo :base) (:ichigo :kessa)))
  (let* ((k (apply #'kit cf)) (j2 (kit-next k (getf (kit-commands k) :q) :q)))
    (check (every (lambda (n) (eq (kit-next k n :q) j2)) (append (list (getf (kit-core k) :sa)) (core-segment-sas (kit-core k)))))))
(check (eq (kit-next (kit :ichigo :kessa) :ic-k-sa-g1 :q) (kit-move (kit :ichigo :kessa) :ic-k-j2)))
;; KESSA plays no Shikai clip in the core set (2026-10-28: 「要，都幫我換一換」), and pointer 3's Kikon is 千影
(let* ((k (kit :ichigo :kessa)) (core (kit-core k)))
  (check (notany (lambda (n) (let ((c (mv-clip (kit-move k n)))) (and c (not (search "IC-K-" (symbol-name c))) (not (member c '(:ic-tsuki))))))
                 (core-move-names core)))
  (check (equal (getf core :kikon-cines) '(ic-chain-kikon-cine ic-kessa-getsuga-cine ic-kessa-kikon-cine))))
;; five J (2026-10-28): J1-2 -> AS1, J3-4 -> AS2, J5 -> AS3; the strings J1 > J2 > J3 > J4 > J5 in both forms
(check (equal (mapcar (lambda (n) (core-as-pointer n '(1 1 2 2 3))) '(0 1 2 3 4 5 6)) '(1 1 1 2 2 3 3)))
(dolist (cf '((:ichigo :base) (:ichigo :kessa)))
  (let* ((k (apply #'kit cf)) (m (kit-command-move k :q)) (n 1))
    (loop for nx = (kit-next k (mv-name m) :q) while (and nx (< n 9)) do (setf m nx) (incf n))
    (check (= n 5))
    (check (member :ender (mv-flags m)))))
;; a Getsuga wave's Kikon (2026-10-28: 「打中後瞬步衝過去補一刀」): each wave segment names a follow-up strike in its form's moves,
;; classed as its segment (so its hit is judged as the Kikon), a flash step that can close 12 m
(loop for (cf . segs) in '(((:ichigo :base) :ic-n2c :ic-as2b) ((:ichigo :kessa) :ic-k-n2c :ic-k-as2b))
      do (let ((k (apply #'kit cf)))
           (dolist (n segs)
             (let* ((mv (kit-move k n)) (s (kit-move k (getf (mv-params mv) :kikon-strike))))
               (check (and s (kit-class k s) (eq (kit-class k s) (kit-class k mv))
                           (eq (getf (mv-params s) :look) :flash-step) (>= (getf (mv-params s) :follow-cap) 40.0)))))))
;; only a route's last segment knocks down or launches (2026-10-28, DEVLOG §443: KESSA's X knocked down and the SA after it
;; whiffed): every NS / AS segment that something follows (a next segment, its gap's SA) and its hit windows and wave stagger at most,
;; in every form of a kit with a :core; and KESSA's clone X, which NS3[3]'s SA follows
(dolist (cf '((:ichigo :base) (:ichigo :kessa) (:kenpachi :base) (:hisagi :base) (:hisagi :bankai) (:hisagi :bankai-bind)))   ; (his Bankai, §28.4)
  (let* ((k (apply #'kit cf)) (core (kit-core k)))
    (dolist (n (append (getf core :ns) (getf core :as)))
      (dolist (m (core-segments n))
        (let* ((mv (kit-move k m)) (p (mv-params mv)))
          (when (and mv (or (getf p :ns-next) (getf p :sa)))
            (check (not (or (member (getf p :react) '(:knockdown :launch))
                            (loop for w across (mv-hits mv) thereis (member (hw-react w) '(:knockdown :launch))))))))))))
(check (equal (mapcar (lambda (n) (hw-react (svref (mv-hits (find-move n)) 0))) '(:ic-c-xa :ic-c-xb)) '(:stagger :stagger)))
;; Hisagi's Shikai on the core system (DUEL_HISAGI §26, 2026-10-28): pointer 1 投, since §27 2 刈 (the short-chain reaping) and 3 縛雷
;; (the bind and the lightning merged: two NS segments, the second's SA 放電, 餘電), five J, the SA YOSE's drag, AS1's hook and steal
(let* ((k (kit :hisagi :base)) (core (kit-core k)))
  (flet ((m (n) (kit-move k n)) (eff (n) (let ((x (kit-move k n))) (- (mv-s x) (mv-enter x))))
         (react (n) (hw-react (svref (mv-hits (kit-move k n)) 0))))
    (check (every (lambda (n) (>= (eff n) 14)) '(:hs-j1 :hs-n1a :hs-n2a :hs-n3a)))                         ; the tells
    (check (equal (mapcar #'eff '(:hs-n1a :hs-n1b :hs-n1c :hs-n2a :hs-n2b :hs-n2c :hs-n3a :hs-n3b :hs-sa-hoden))
                  '(20 14 16 16 12 16 18 14 10)))
    (check (equal (mapcar #'core-segments (getf core :ns))
                  '((:hs-n1a :hs-n1b :hs-n1c) (:hs-n2a :hs-n2b :hs-n2c) (:hs-n3a :hs-n3b))))
    (check (equal (mapcar #'core-segments (getf core :as)) '((:hs-as1) (:hs-as2 :hs-as2b) (:hs-as3 :hs-as3b :hs-as3c))))
    (check (equal (mapcar (lambda (n) (mv-dmg (m n))) '(:hs-n1a :hs-n1b :hs-n1c :hs-n2a :hs-n2b :hs-n2c :hs-n3a :hs-n3b
                                                        :hs-as1 :hs-as2 :hs-as2b :hs-as3 :hs-as3b :hs-as3c :hs-sa :hs-sa-hoden))
                  '(62 56 80 45 50 85 40 25 16 45 60 45 35 110 40 60)))
    (check (equal (mapcar #'react '(:hs-n1c :hs-n2c :hs-n3b :hs-as2b :hs-as3c :hs-sa-hoden))
                  '(:stagger :knockdown :stagger :launch :knockdown :stagger)))      ; (NS1c staggers, §27.9)
    ;; §27.10: AS1 TSUMUJI four cuts along the chain, only the last knocks down; the leap back to NAGI's band
    (check (let ((hs (mv-hits (m :hs-as1))))
             (and (= 4 (length hs)) (equal (map 'list #'hw-react hs) '(:flinch :flinch :flinch :knockdown))
                  (every (lambda (w) (eq (hw-seg w) 'hs-core-seg)) hs)
                  (equal (mv-on-frame (m :hs-as1)) '((0 hs-as1-hop))) (= 0 (mv-enter (m :hs-as1)))   ; (f0 runs: no :enter)
                  (< *hs-k-dead* *hs-as1-hop-to* 6.0))))
    (check (eq (react :hs-n3a) :bind))
    (check (every (lambda (n) (eq (hw-seg (svref (mv-hits (m n)) 0)) 'hs-core-seg))
                  '(:hs-n3b :hs-as1 :hs-as3b :hs-sa-hoden)))                                              ; along the chain, within 6.5 m
    ;; §27.9: NS1b / NS1c sweep NAGI's own volume (no chain to the victim)
    (check (let ((v (hw-vols (svref (mv-hits (m :hs-n1a)) 0))))
             (every (lambda (n) (let ((w (svref (mv-hits (m n)) 0))) (and (null (hw-seg w)) (equalp (hw-vols w) v))))
                    '(:hs-n1b :hs-n1c))))
    (check (and (equal (mv-on-frame (m :hs-sa)) '((0 hs-yose))) (eq (kit-class k (m :hs-sa)) :sa)
                (= 120 (getf (mv-params (m :hs-as1)) :steal-fs))))
    ;; §27: NS3a's gap the kit's SA (YOSE), CHIKUDEN's 放電; 放電's distance x; 餘電 set / pending / used up
    (check (and (eq (getf (mv-params (m :hs-n3a)) :sa) :hs-sa) (eq (getf (mv-params (m :hs-n3b)) :sa) :hs-sa-hoden)
                (eq (kit-class k (m :hs-sa-hoden)) :sa)))
    ;; §27.7: the kit's SA (pointers 1 and 2) a plain cut, no drag; NS1's three segments all miss inside NAGI's dead zone
    (check (and (eq (getf core :sa) :hs-sa-kiri) (null (mv-on-frame (m :hs-sa-kiri))) (eq (kit-class k (m :hs-sa-kiri)) :sa)
                (= (mv-dmg (m :hs-sa-kiri)) 40)
                (every (lambda (n) (null (getf (mv-params (m n)) :sa))) '(:hs-n1a :hs-n1b :hs-n1c :hs-n2a :hs-n2b :hs-n2c))))
    (check (every (lambda (n) (= (hw-min (svref (mv-hits (m n)) 0)) *hs-k-dead*)) '(:hs-n1a :hs-n1b :hs-n1c)))
    ;; §27.6 (presentation only): CHIKUDEN / 放電 their own clips at their S (speed 1); CHIKUDEN keeps NOKO's :look-as (HS-TICK's
    ;; hashed anchor on the victim)
    (check (and (eq (mv-clip (m :hs-n3b)) :hs-chikuden) (eq (mv-clip (m :hs-sa-hoden)) :hs-hoden)
                (= 1.0 (mv-clip-speed (m :hs-n3b)) (mv-clip-speed (m :hs-sa-hoden)))
                (= 20 (mv-s (m :hs-n3b))) (= 10 (mv-s (m :hs-sa-hoden))) (eq (hs-look-name (m :hs-n3b)) :hs-k2)))
    ;; §27.10 (presentation only): AS1 TSUMUJI its own clip at its S (speed 1), NOKO's :look-as kept (the hashed anchor)
    (check (and (eq (mv-clip (m :hs-as1)) :hs-tsumuji) (= 1.0 (mv-clip-speed (m :hs-as1))) (= 14 (mv-s (m :hs-as1)))
                (eq (hs-look-name (m :hs-as1)) :hs-k2)))
    (check (and (= (hs-hoden-x 1.0) 2.0) (= (hs-hoden-x 6.5) 1.0) (< (abs (- (hs-hoden-x 4.05) 1.5)) 1e-4) (= (hs-hoden-x 9.0) 1.0)))
    (let ((st (make-hss)))
      (hs-zan-hit st (m :hs-n3b)) (check (and (hss-zan-pend st) (zerop (hss-zan st))))
      (hs-zan-hit st (m :hs-as3c)) (check (= (hss-zan st) *hs-zan-frames* 480))
      (hs-zan-hit st (m :hs-sa-hoden)) (check (zerop (hss-zan st))))
    (check (and (= 3 (length (getf core :stances))) (= 3 (length (getf core :kikon-cines))) (equal (getf core :as-by-press) '(1 1 2 2 3))))
    (let ((x (kit-command-move k :q)) (n 1))                                                                ; five J, the last the ender
      (loop for nx = (kit-next k (mv-name x) :q) while (and nx (< n 9)) do (setf x nx) (incf n))
      (check (and (= n 5) (eq (mv-name x) :hs-j3) (member :ender (mv-flags x)))))))
;; §28.4 (generic, off for every other kit): an AS writes its pointer unless the kit's :as-writes says none; a :no-kikon segment
;; holds into no Kikon; only Hisagi's Bankai has :as-writes or a :no-kikon segment
(check (loop for c being the hash-keys of *kits* using (hash-value alist)
             always (loop for (f . k) in alist
                          always (or (and (eq c :hisagi) (member f '(:bankai :bankai-bind)))
                                     (and (null (getf (kit-core k) :as-writes))
                                          (notany (lambda (n) (getf (mv-params (find-move n)) :no-kikon)) (core-move-names (kit-core k))))))))

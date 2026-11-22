(in-package :duel)
;;; ================================================================ Yamamoto's Shikai on the core system (docs/duel/DUEL_YAMA_CORE.md §7.1, §7.4;
;;; batch 1 stage A). After hisagi.lisp: its stand-in hazard entities (DO-ENTITIES, SPAWN-ENTITY, HAZARD), POS-OF / YAW-OF and sim.lisp's
;;; stand-in fighters (T-PAIR); his file loaded again now that components / fighter / hazards are (its SETFs of their slots expand).
(defun yss (e) (let ((c (gethash e *t-hss*))) (and (typep c 'yss) c)))   ; (his heat state: the stand-in component table, hisagi.lisp's)
(load (merge-pathnames "../../duel/lisp/yama.lisp" *load-truename*))
(let* ((k (kit :yamamoto :base)) (core (kit-core k)))
  (flet ((m (n) (kit-move k n)) (cls (n) (kit-class k (kit-move k n)))
         (react (n) (let ((mv (kit-move k n))) (or (getf (mv-params mv) :react) (hw-react (svref (mv-hits mv) 0))))))
    ;; the roster: slot 0 plays again (index fixed); the awakening is the Bankai since stage C (no :no-awaken)
    (check (and (= 0 (position :yamamoto *roster*)) (member :yamamoto (playable-roster)) (not (member :yamamoto *retired*))))
    (check (and (not (getf core :no-awaken)) (eq :bankai (kit-awaken-form k)) (~= 1.0 (getf core :mult))))
    ;; every class tag (NA J1-J3, the three NS routes, the three AS, the SA, each hazard segment's Kikon strike as its segment)
    (check (every (lambda (n) (eq (cls n) :na)) '(:ya-j1 :ya-j2 :ya-j3)))
    (check (equal (mapcar #'core-segments (getf core :ns)) '((:ya-n1a :ya-n1b :ya-n1c) (:ya-n2a :ya-n2b :ya-n2c) (:ya-n3a :ya-n3b :ya-n3c))))
    (check (every (lambda (r) (every (lambda (n) (eq (cls n) :ns)) (core-segments r))) (getf core :ns)))
    (check (equal (mapcar #'core-segments (getf core :as)) '((:ya-as1) (:ya-as2 :ya-as2b) (:ya-as3 :ya-as3b :ya-as3c))))
    (check (equal (mapcar (lambda (r) (length (core-segments r))) (getf core :as)) '(1 2 3)))   ; AS n: n segments
    (check (every (lambda (r) (every (lambda (n) (eq (cls n) :as)) (core-segments r))) (getf core :as)))
    (check (and (eq (getf core :sa) :ya-sa) (eq (cls :ya-sa) :sa) (eq (kit-next k :ya-sa :q) (m :ya-j2))))   ; SA :q J2
    (check (equal (getf core :as-by-press) '(1 2 3)))
    (check (equal (mapcar (lambda (p) (core-as-pointer p '(1 2 3))) '(1 2 3)) '(1 2 3)))   ; J1 -> AS1, J2 -> AS2, J3 -> AS3
    ;; the openers' tells: J1 and every NS first segment S >= 14 (§7.1: 14 / 22 / 20 / 18)
    (check (equal (mapcar (lambda (n) (mv-s (m n))) '(:ya-j1 :ya-n1a :ya-n2a :ya-n3a)) '(14 22 20 18)))
    (check (every (lambda (n) (>= (- (mv-s (m n)) (mv-enter (m n))) 14)) '(:ya-j1 :ya-n1a :ya-n2a :ya-n3a)))
    ;; §7.1's damage as built (before the kit's :mult): melee windows, a hazard segment's :params :dmg (the ring's burn :ring-dmg)
    (check (equal (mapcar (lambda (n) (mv-sp-damage (m n)))
                          '(:ya-j1 :ya-j2 :ya-j3 :ya-n1a :ya-n1b :ya-n1c :ya-n2a :ya-n2b :ya-n2c :ya-n3a :ya-n3b :ya-n3c
                            :ya-as1 :ya-as2 :ya-as2b :ya-as3 :ya-as3b :ya-as3c :ya-sa))
                  '(34 34 42 70 70 90 40 0 80 40 50 110 50 40 60 40 50 110 55)))
    ;; no mid-route knockdown / crumple / launch: every segment something follows (a next segment, its gap's SA) and its waves stagger
    ;; at most; the routes' last segments carry the big reactions (§7.1)
    (dolist (r (append (getf core :ns) (getf core :as)))
      (dolist (n (butlast (core-segments r)))
        (let ((mv (m n)))
          (check (not (or (member (getf (mv-params mv) :react) '(:knockdown :launch :crumple))
                          (loop for w across (mv-hits mv) thereis (member (hw-react w) '(:knockdown :launch :crumple)))))))))
    (check (not (member (react :ya-j3) '(:knockdown :launch :crumple))))   ; J3: an AS follows
    (check (equal (mapcar #'react '(:ya-n1c :ya-n2c :ya-n3c :ya-as1 :ya-as2b :ya-as3c)) '(:knockback :crumple :crumple :knockdown :launch :knockdown)))
    ;; each hazard segment names a Kikon strike of its own class (a flash step that closes 40 m/s, Ichigo's wave rule); one strike per
    ;; class, never shared across classes
    ;; §30.1: pointer 2 close (0-3 m): NS2a a melee flame slash (S20, 40, 2.4 m, arc 120, a stagger, no hazard, no Kikon strike of its
    ;; own); NS2b's ring and NS2c's dome at the victim's bearing clamped to 0-3 m; AS2b's dome as before; the CPU casts no NS2 from range
    (let ((mv (m :ya-n2a)))
      (check (and (= 1 (length (mv-hits mv))) (= 40 (hw-dmg (svref (mv-hits mv) 0))) (~= 2.4 (mv-reach mv)) (eq (react :ya-n2a) :stagger)
                  (null (getf (mv-params mv) :kikon-strike)) (null (getf (mv-params mv) :speed)) (eq (mv-ns-next k mv) (m :ya-n2b))
                  (equal (mv-on-frame mv) '((0 yama-ns-start))))))
    (check (equal (mapcar (lambda (n) (getf (mv-params (m n)) :far)) '(:ya-n2b :ya-n2c :ya-as2b)) '(3.0 3.0 8.0)))
    (check (and (~= 8.0 (mv-reach (m :ya-as2b))) (equal (getf core :ns-range) '((3.0 7.0) nil nil))))
    (let ((hz '(:ya-n1a :ya-n1b :ya-n1c :ya-n2b :ya-n2c :ya-as2 :ya-as2b)))
      (dolist (n hz)
        (let* ((mv (m n)) (s (getf (mv-params mv) :kikon-strike)) (smv (and s (m s))))
          (check (and smv (eq (kit-class k smv) (kit-class k mv)) (>= (getf (mv-params smv) :follow-cap) 40.0)
                      (eq (getf (mv-params smv) :look) :flash-step)))))
      (check (and (eq (cls :ya-ns-strike) :ns) (eq (cls :ya-as-strike) :as)))
      ;; their fire is a hazard: no melee window of their own (but AS2a's contact), the damage in :params
      (check (every (lambda (n) (zerop (length (mv-hits (m n))))) (remove :ya-as2 hz))))
    ;; a delayed hazard keeps an active window over its delay: NS1b's point on S, the column 12 f later (a hazard spawned on frame S
    ;; counts its first delay frame there: hot on S + delay - 1), inside [S, S + A)
    (let ((mv (m :ya-n1b)))
      (check (and (equal (mv-on-frame mv) '((0 yama-ns-start) (16 yama-column-fire))) (= 13 (getf (mv-params mv) :delay))
                  (= (+ 16 12) (+ (mv-s mv) (getf (mv-params mv) :delay) -1)) (< (+ 16 12) (+ (mv-s mv) (mv-a mv))))))
    ;; AS1 steals 30 flash-step (§7.4); NADEGIRI's hit on S, its split a look 24 f later; the SA a 360 deg halo, r 2.4
    (check (= 30 (getf (mv-params (m :ya-as1)) :steal-fs)))
    (check (and (= 14 (hw-from (svref (mv-hits (m :ya-n3c)) 0))) (equal (mv-on-frame (m :ya-n3c)) '((0 yama-ns-start) (14 yama-nade-split)))))
    (check (and (~= 2.4 (mv-reach (m :ya-sa))) (= 16 (mv-s (m :ya-sa)))))
    ;; stance by pointer
    (check (equal (getf core :stances) '(:ya-shiranui :ya-st-enjo :ya-st-cane)))
    (let ((f (make-fighter :kit k)))
      (check (equal (loop for p from 1 to 3 collect (progn (setf (fighter-ptr f) p) (fighter-stance-clip f)))
                    '(:ya-shiranui :ya-st-enjo :ya-st-cane))))
    ;; the stage-B seam: a segment's x is 1.0 now; a hazard carries its own frozen at its fire frame
    (check (~= 1.0 (yama-seg-x nil (m :ya-n1a))))
    ;; the pure pieces: the point at the victim's bearing, clamped to near .. far and the arena; the ring burns only on its line (Y8)
    (flet ((pt (px pz qx qz lo hi) (multiple-value-list (ya-bearing-point px pz qx qz lo hi))))
      (check (every #'~= (pt 0.0 0.0 0.0 2.0 4.0 7.0) '(0.0 4.0)))       ; too near: pushed out to 4 m
      (check (every #'~= (pt 0.0 0.0 0.0 5.0 4.0 7.0) '(0.0 5.0)))       ; on him
      (check (every #'~= (pt 0.0 0.0 9.0 0.0 4.0 7.0) '(7.0 0.0)))       ; too far: 7 m
      (check (< (sqrt (reduce #'+ (mapcar (lambda (v) (* v v)) (pt 0.0 13.0 0.0 14.9 3.0 8.0)))) *arena-radius*)))   ; inside the arena
    (check (not (ya-ring-touch-p 0.0 0.0 1.6 0.25 0.0 0.0 0.36)))        ; at the centre: free
    (check (ya-ring-touch-p 0.0 0.0 1.6 0.25 1.6 0.0 0.36))              ; on the line: burns
    (check (ya-ring-touch-p 0.0 0.0 1.6 0.25 1.0 0.0 0.36))              ; the cylinder reaching it
    (check (not (ya-ring-touch-p 0.0 0.0 1.6 0.25 3.0 0.0 0.36)))        ; well outside: free
    ;; one ring at a time (stand-in entities): a second NS2b's ring puts the first out; the dome lands on the ring and spends it; a victim at
    ;; 5 m gets the ring at 3 m (§30.1's 0-3 m)
    (multiple-value-bind (a b) (t-pair k (kit :kenpachi :base))
      (setf *t-hz* nil)
      (t-at a 0 0) (t-at b 0 5.0)
      (let ((fa (fighter a)))
        (flet ((rings () (count :ya-ring *t-hz* :key (lambda (x) (hazard-kind (cdr x)))))
               (in (n) (setf (fighter-state fa) :move (fighter-move fa) (m n) (fighter-cls fa) (cls n) (fighter-sf fa) (mv-s (m n)))))
          (in :ya-n2b) (yama-ring-fire a)
          (check (= 1 (rings)))
          (let ((h1 (cdr (find :ya-ring *t-hz* :key (lambda (x) (hazard-kind (cdr x)))))))
            (check (and (~= 3.0 (hazard-z h1)) (eq (hazard-cls h1) :ns) (~= 1.6 (hazard-size h1)) (= 90 (hazard-life h1))
                        (= 20 (hw-dmg (hazard-hw h1))) (~= 1.0 (getf (hazard-data h1) :x)))))
          (t-at b 0 2.0) (yama-ring-fire a)
          (check (= 1 (rings)))                                            ; the first went out
          (check (~= 2.0 (hazard-z (cdr (find :ya-ring *t-hz* :key (lambda (x) (hazard-kind (cdr x))))))))
          (t-at b 3.0 6.0) (in :ya-n2c) (yama-dome-fire a)
          (check (= 0 (rings)))                                            ; spent by the dome
          (let ((d (cdr (find :ya-dome *t-hz* :key (lambda (x) (hazard-kind (cdr x)))))))
            (check (and d (~= 0.0 (hazard-x d)) (~= 2.0 (hazard-z d)) (eq (hazard-cls d) :ns) (= 80 (hw-dmg (hazard-hw d))))))
          (setf *t-hz* nil))))))

;;; ================================================================ stage B: the heat gauge and 爆炎 (DUEL_YAMA_CORE §3, §7.2, §7.4)
(let* ((k (kit :yamamoto :base)) (kb (kit :yamamoto :blaze)) (core (kit-core kb)))
  (flet ((m (n) (kit-move kb n)) (cls (n) (kit-class kb (kit-move kb n))))
    ;; the pure heat rules: gains (Y1: NA 8 / SA 10 / AS 12, NS / none 0, capped at 100)
    (check (every #'~= (mapcar (lambda (c) (ya-heat-gain 0.0 c)) '(:na :sa :as :ns nil)) '(8.0 10.0 12.0 0.0 0.0)))
    (check (~= 100.0 (ya-heat-gain 95.0 :as)))
    ;; J1-J2-J3 > AS3 adds 60 (§7.4's watch line)
    (check (~= 60.0 (reduce #'ya-heat-gain '(:na :na :na :as :as :as) :initial-value 0.0)))
    ;; the NS spend (Y2 / Y3): 25 or what is left, the boost in proportion; no hit of its own: nothing; 爆炎: 25 / 3, x1 (Y9; 1/3 since §32)
    (flet ((sp (h hit b) (multiple-value-list (ya-ns-spend h hit b))))
      (check (every #'~= (sp 40.0 t nil) '(25.0 1.3)))
      (check (every #'~= (sp 10.0 t nil) '(10.0 1.12)))
      (check (every #'~= (sp 0.0 t nil) '(0.0 1.0)))
      (check (every #'~= (sp 40.0 nil nil) '(0.0 1.0)))                 ; NS2b's ring
      (check (every #'~= (sp 60.0 t t) (list (/ 25.0 3.0) 1.0)))
      (check (every #'~= (sp 7.0 t t) '(7.0 1.0)))
      (check (every #'~= (sp 40.0 nil t) '(0.0 1.0))))
    (check (and (~= 40.0 (ya-heat-refund 15.0 25.0)) (~= 100.0 (ya-heat-refund 90.0 25.0))))
    ;; the decay: 10 / s, never below 0 (600 steps from full)
    (check (and (~= (- 100.0 (/ 10.0 60.0)) (ya-blaze-decay 100.0)) (~= 0.0 (ya-blaze-decay 0.1))))
    (check (~= 0.0 (let ((h 100.0)) (dotimes (i 601 h) (setf h (ya-blaze-decay h))))))
    ;; the latch both ways (§7.4): only when free; the Shikai at the top -> 爆炎, 爆炎 at 0 -> the Shikai
    (check (eq :blaze (ya-form-next :base 100.0 t)))
    (check (null (ya-form-next :base 100.0 nil)))                        ; mid-route: waits
    (check (null (ya-form-next :base 99.9 t)))
    (check (eq :base (ya-form-next :blaze 0.0 t)))
    (check (null (ya-form-next :blaze 0.0 nil)))
    (check (null (ya-form-next :blaze 0.5 t)))
    ;; the drain (2 % of max / s through BURN-AMOUNT): a second takes 2 % of 1000 = 20; BURN never below 1 (Y4)
    (check (= 20 (loop for i below 60 sum (burn-amount 1000 0.02 i))))
    (check (and (= 1 (burn 15 20)) (= 1 (burn 1 3)) (= 80 (burn 100 20))))
    ;; the cancel burn: 25 % of the base, at least 1 (Y10)
    (check (and (= 23 (ya-burn-amount 91)) (= 1 (ya-burn-amount 2)) (= 1 (ya-burn-amount 0)) (= 50 (ya-burn-amount 200))))
    ;; the kit :blaze: inherits the Shikai, bared, its own set, free SP, no awakening yet, the drain
    (check (and (eq (kit-inherit kb) :base) (eq (kit-body kb) :yamamoto-bare) (~= 0.02 (kit-burn kb))
                (not (getf core :no-awaken)) (eq :bankai (kit-awaken-form kb)) (getf core :sp-free) (kit-sp-free-p kb) (not (kit-sp-free-p k))
                (null (kit-duration kb)) (equal (kit-form-name kb) "GOKUEN")))
    (check (equal (getf (kit-meter kb) :name) "HEAT"))
    (check (and (equal (yama-hud-label nil k) "HEAT") (equal (yama-hud-label nil kb) "GOKUEN")))
    ;; every 爆炎 copy's class tag, its own chain (no Shikai segment leaks in through a copy's :params)
    (check (every (lambda (n) (eq (cls n) :na)) '(:ya-b-j1 :ya-b-j2 :ya-b-j3)))
    (check (equal (mapcar #'core-segments (getf core :ns))
                  '((:ya-b-n1a :ya-b-n1b :ya-b-n1c) (:ya-b-n2a :ya-b-n2b :ya-b-n2c) (:ya-b-n3a :ya-b-n3b :ya-b-n3c))))
    (check (equal (mapcar #'core-segments (getf core :as)) '((:ya-b-as1) (:ya-b-as2 :ya-b-as2b) (:ya-b-as3 :ya-b-as3b :ya-b-as3c))))
    (check (every (lambda (r) (every (lambda (n) (eq (cls n) :ns)) (core-segments r))) (getf core :ns)))
    (check (every (lambda (r) (every (lambda (n) (eq (cls n) :as)) (core-segments r))) (getf core :as)))
    (check (and (eq (cls :ya-b-sa) :sa) (eq (kit-next kb :ya-b-sa :q) (m :ya-b-j2)) (eq (kit-next kb :ya-b-j1 :q) (m :ya-b-j2))
                (eq (kit-command-move kb :q) (m :ya-b-j1))))
    (check (null (cls :ya-blaze-in)))                                    ; the entry pose: no class, no hit
    (check (and (m :ya-blaze-in) (zerop (length (mv-hits (m :ya-blaze-in)))) (= 24 (mv-total (m :ya-blaze-in)))))
    ;; §7.2's numbers as built (x1.3 where it gives none; NS3c 200, a long recovery; SA r 3.2; J3 IKKOTSU 55)
    (check (equal (mapcar (lambda (n) (mv-sp-damage (m n)))
                          '(:ya-b-j1 :ya-b-j2 :ya-b-j3 :ya-b-n1a :ya-b-n1b :ya-b-n1c :ya-b-n2a :ya-b-n2b :ya-b-n2c :ya-b-n3a :ya-b-n3b
                            :ya-b-n3c :ya-b-as1 :ya-b-as2 :ya-b-as2b :ya-b-as3 :ya-b-as3b :ya-b-as3c :ya-b-sa))
                  '(40 40 55 91 91 117 52 80 104 52 65 200 65 52 78 52 65 143 55)))
    (check (and (> (mv-r (m :ya-b-n3c)) (mv-r (kit-move k :ya-n3c))) (~= 3.2 (mv-reach (m :ya-b-sa))) (eq (mv-clip (m :ya-b-j3)) :ya-ikkotsu)))
    (check (~= 60.0 (getf (mv-params (m :ya-b-n1c)) :track)))
    ;; no mid-route knockdown / crumple / launch in 爆炎 either
    (dolist (r (append (getf core :ns) (getf core :as)))
      (dolist (n (butlast (core-segments r)))
        (let ((mv (m n)))
          (check (not (or (member (getf (mv-params mv) :react) '(:knockdown :launch :crumple))
                          (loop for w across (mv-hits mv) thereis (member (hw-react w) '(:knockdown :launch :crumple)))))))))
    (check (not (member (hw-react (svref (mv-hits (m :ya-b-j3)) 0)) '(:knockdown :launch :crumple))))
    ;; every NS segment (both sets) spends at its start; each hazard segment keeps a Kikon strike of its class
    (dolist (n (append (loop for r in (getf (kit-core k) :ns) append (core-segments r)) (loop for r in (getf core :ns) append (core-segments r))))
      (check (eq 'yama-ns-start (second (assoc 0 (mv-on-frame (kit-move (if (search "-B-" (symbol-name n)) kb k) n)))))))
    ;; §30.1 in 爆炎: NS2a the melee slash x1.3 (its copy's own chain); NS2b's dome at 0-3 m; ENNETSU a disc of fire round him (r 2.5, 104,
    ;; a crumple: a column on his feet), its own move (no melee window inherited from NS2a)
    (let ((a (m :ya-b-n2a)) (c (m :ya-b-n2c)))
      (check (and (= 1 (length (mv-hits a))) (= 52 (hw-dmg (svref (mv-hits a) 0))) (~= 2.4 (mv-reach a)) (eq (mv-ns-next kb a) (m :ya-b-n2b))
                  (null (getf (mv-params a) :kikon-strike))))
      (check (and (zerop (length (mv-hits c))) (eq (mv-clip c) :ya-b-n2c)
                  (equal (mv-on-frame c) '((0 yama-ns-start) (18 yama-column-fire)))
                  (equal (loop for key in '(:near :far :radius :delay :dmg :react) collect (getf (mv-params c) key)) '(0.0 0.0 2.5 0 104 :crumple))
                  (eq (getf (mv-params c) :kikon-strike) :ya-ns-strike)))
      (check (and (~= 3.0 (getf (mv-params (m :ya-b-n2b)) :far)) (equal (getf core :ns-range) '((3.0 7.0) nil nil)))))
    (dolist (n '(:ya-b-n1a :ya-b-n1b :ya-b-n1c :ya-b-n2b :ya-b-n2c :ya-b-as2 :ya-b-as2b))
      (let* ((mv (m n)) (smv (m (getf (mv-params mv) :kikon-strike))))
        (check (and smv (eq (kit-class kb smv) (kit-class kb mv))))))
    ;; free SP in 爆炎 (KIT-SP-START-P): a later NS segment at fs 0 starts there, not in the Shikai
    (check (and (kit-sp-start-p kb (m :ya-b-n1b) 0.0 nil) (not (kit-sp-start-p k (kit-move k :ya-n1b) 0.0 nil))))
    ;; the sim side on stand-in fighters: the NS spend at its start and the frozen x, a hit's gain (once a move), a cancel's refund,
    ;; the latch into 爆炎 at neutral, the decay and the drain held at 1, the burn floor, the way out at heat 0
    (multiple-value-bind (a b) (t-pair k (kit :kenpachi :base))
      (t-at a 0 0) (t-at b 0 1.8)
      (let ((fa (fighter a)) (ga (gauges a)) (gb (gauges b)) (*match-tick* 400))
        (flet ((in (kit n tick) (let ((mv (kit-move kit n)))
                                  (setf (fighter-state fa) :move (fighter-move fa) mv (fighter-cls fa) (kit-class kit mv) (fighter-cls-t fa) tick
                                        (fighter-sf fa) 0 (fighter-phase fa) :main (fighter-follow fa) nil)
                                  mv)))
          (setf (fighter-form fa) :base (fighter-kit fa) k (fighter-character fa) :yamamoto (gauges-meter ga) 40f0)
          (let ((mv (in k :ya-n3a 400))) (yama-ns-start a)
            (check (and (~= 15.0 (gauges-meter ga)) (~= 1.3 (yama-seg-x a mv)) (~= 1.0 (yama-seg-x a (kit-move k :ya-n3b)))))
            (yama-cancel a b mv nil)                                       ; cancelled: the 25 back, once
            (check (~= 40.0 (gauges-meter ga)))
            (yama-cancel a b mv nil)
            (check (~= 40.0 (gauges-meter ga))))
          (let ((mv (in k :ya-n3b 420))) (yama-ns-start a)              ; a new segment: its own spend
            (check (and (~= 15.0 (gauges-meter ga)) (~= 1.3 (yama-seg-x a mv))))
            (yama-hit a b :hit nil mv nil nil)                             ; an NS hit adds nothing
            (check (~= 15.0 (gauges-meter ga))))
          (let ((mv (in k :ya-j1 430)))
            (yama-hit a b :hit nil mv nil nil) (yama-hit a b :hit nil mv nil nil)   ; once a move
            (check (~= 23.0 (gauges-meter ga)))
            (yama-hit a b :blocked nil mv nil nil)
            (check (~= 23.0 (gauges-meter ga))))
          (let ((mv (in k :ya-as3 440)))
            (yama-cancel a b mv nil)                                       ; an AS segment's cancel adds its 12
            (check (~= 35.0 (gauges-meter ga))))
          ;; heat at the top mid-route: no change until he is free; free -> 爆炎, the pose, invulnerable, heat full
          (setf (gauges-meter ga) 100f0)
          (in k :ya-as3b 450)
          (yama-tick a fa ga)
          (check (eq (fighter-form fa) :base))
          (setf (fighter-state fa) :idle (fighter-move fa) nil (fighter-lock fa) 0)
          (yama-tick a fa ga)
          (check (and (eq (fighter-form fa) :blaze) (eq (fighter-kit fa) kb) (eq (fighter-move fa) (m :ya-blaze-in))
                      (= 24 (fighter-invuln fa)) (~= 100.0 (gauges-meter ga))))
          (yama-tick a fa ga)                                              ; in the pose: no decay, no drain
          (check (~= 100.0 (gauges-meter ga)))
          (setf (fighter-state fa) :idle (fighter-move fa) nil (gauges-reishi ga) 15)
          (let ((g0 (gauges-reishi gb))) (yama-hit a b :hit nil (in kb :ya-b-j1 470) nil nil)   ; no gain in 爆炎
            (check (and (~= 100.0 (gauges-meter ga)) (= g0 (gauges-reishi gb)))))
          (setf (fighter-state fa) :move)
          (dotimes (i 60) (yama-tick a fa ga))                             ; a second in a move: decay 10, the drain held at 1
          (check (and (~= 90.0 (gauges-meter ga) 0.01) (= 1 (gauges-reishi ga)) (eq (fighter-form fa) :blaze)))
          ;; the cancel burn: 25 % of his move's base, the opponent's Reishi never below 1; once a step
          (setf (gauges-reishi gb) 500)
          (let ((mv (in kb :ya-b-n1a 500)))
            (yama-ns-start a)
            (check (~= (- 90.0 (/ 25.0 3.0)) (gauges-meter ga) 0.01))      ; 爆炎's NS: 25 / 3 (§32; 25 before)
            (yama-cancel a b mv nil) (yama-cancel a b mv nil)
            (check (and (= 477 (gauges-reishi gb)) (~= 90.0 (gauges-meter ga) 0.01))))   ; 91 x 0.25 = 23; the 8.3 back
          (setf (gauges-reishi gb) 5)
          (let ((*match-tick* 501)) (yama-cancel a b (fighter-move fa) nil))
          (check (= 1 (gauges-reishi gb)))
          (let ((*match-tick* 502)) (yama-cancel a b (fighter-move fa) nil))
          (check (= 1 (gauges-reishi gb)))
          ;; heat 0 in 爆炎: out at the next neutral, heat 0
          (setf (gauges-meter ga) 0.05f0)
          (yama-tick a fa ga)
          (check (eq (fighter-form fa) :blaze))                            ; in a move
          (setf (fighter-state fa) :idle (fighter-move fa) nil)
          (yama-tick a fa ga)
          (check (and (eq (fighter-form fa) :base) (eq (fighter-kit fa) k) (~= 0.0 (gauges-meter ga))))
          ;; 爆炎's tornado turns after him at 60 deg / s (1 deg a step), a wave without :track flies straight
          (t-at a 0 0) (t-at b 3.0 -5.0)
          (let ((hz (make-hazard :kind :wave :owner a :x 0f0 :z -1f0 :yaw 0f0 :data (list :hot 9999 :track 60.0)))
                (hz0 (make-hazard :kind :wave :owner a :x 0f0 :z -1f0 :yaw 0f0 :data (list :hot 9999))))
            (yama-hz nil hz :step) (yama-hz nil hz0 :step)
            (check (and (~= (track-step 60.0) (abs (hazard-yaw hz)) 1e-5) (~= 0.0 (hazard-yaw hz0))))
            (check (< (abs (angle-wrap (- (dir-yaw 3.0 -4.0) (hazard-yaw hz)))) (abs (angle-wrap (dir-yaw 3.0 -4.0))))))
          ;; a wave cancelled after the next segment started still pays its heat back, from its own copy (:heat), once
          (setf (gauges-meter ga) 60f0)
          (in k :ya-n1a 600) (yama-ns-start a)                             ; 35 left
          (let ((w (make-hazard :kind :wave :owner a :cls :ns :sp-src 600 :data (list :hot 9999 :x 1.3 :heat (yama-seg-heat a)))))
            (check (~= 25.0 (getf (hazard-data w) :heat)))
            (in k :ya-n1b 624) (yama-ns-start a)                           ; 10 left: NS1b's spend took the segment's place
            (check (~= 10.0 (gauges-meter ga)))
            (yama-cancel a b nil w) (yama-cancel a b nil w)
            (check (and (~= 35.0 (gauges-meter ga)) (~= 0.0 (getf (hazard-data w) :heat)))))
          ;; ... and a window cancel of the segment closes its hazard's copy (no second refund)
          (setf *t-hz* nil)
          (let ((mv (in k :ya-n1a 700)))
            (yama-ns-start a)                                              ; 10 left
            (spawn-entity (make-hazard :kind :wave :owner a :cls :ns :sp-src 700 :data (list :hot 9999 :heat (yama-seg-heat a))))
            (yama-cancel a b mv nil)
            (check (~= 35.0 (gauges-meter ga)))
            (yama-cancel a b nil (cdr (first *t-hz*)))
            (check (~= 35.0 (gauges-meter ga))))
          (setf *t-hz* nil)
          ;; no heat from a hit during his own burst (§7.4)
          (setf (gauges-burst ga) :orange)
          (yama-hit a b :hit nil (in k :ya-j1 800) nil nil)
          (check (~= 35.0 (gauges-meter ga)))
          (setf (gauges-burst ga) nil)
          (yama-hit a b :hit nil (in k :ya-j1 810) nil nil)
          (check (~= 43.0 (gauges-meter ga)))
          ;; the cancel hook stays off for every other kit
          (check (loop for c being the hash-keys of *kits* using (hash-value alist)
                       always (loop for (f . kk) in alist always (or (eq c :yamamoto) (null (kit-hook kk :cancel))))))
          (check (loop for c being the hash-keys of *kits* using (hash-value alist)
                       always (loop for (f . kk) in alist always (or (and (eq c :yamamoto) (eq f :blaze)) (not (kit-sp-free-p kk)))))))))))

;;; ================================================================ stage C: the Bankai ZANKA NO TACHI, the marks and 北 (DUEL_YAMA_CORE §4, §7.3,
;;; §7.4); §30 (2026-11-21): 西's garb charge (§30.2); §31 AS4 天地灰尽; §33: no 北 form (the kit :north left)
(let* ((kb (kit :yamamoto :bankai)) (core (kit-core kb)))
  (flet ((m (n) (kit-move kb n)) (cls (n) (kit-class kb (kit-move kb n)))
         (react (n) (let ((mv (kit-move kb n))) (or (getf (mv-params mv) :react) (hw-react (svref (mv-hits mv) 0)))))
         )
    ;; the kit: an awakened form of its own (no :inherit: no heat hooks), the TYBW dress, ZANKA, East's stance, the old awakening cinematic;
    ;; its :tick since §30 (西's charged reach, 北 at the next neutral)
    (check (and (kit-awakening kb) (null (kit-inherit kb)) (eq (kit-body kb) :yamamoto-tybw) (eq (kit-weapon kb) :zanka)
                (eq (kit-stance kb) :ya-e-stance) (eq (kit-cine kb) 'yama-bankai-cine) (equal (kit-form-name kb) "ZANKA NO TACHI")
                (eq (kit-hook kb :tick) 'yama-bk-tick) (null (kit-hook kb :cancel)) (not (kit-sp-free-p kb)) (zerop (kit-burn kb))
                (null (kit-hook kb :as-pick)) (equal (getf (kit-meter kb) :name) "ZANKA") (~= 1.0 (getf core :mult))))
    ;; every class tag: NA E-J1-J3, the three NS routes, the three AS, the SA and 西's two charged SAs, each Kikon strike as its segment
    (check (every (lambda (n) (eq (cls n) :na)) '(:ya-e-j1 :ya-e-j2 :ya-e-j3)))
    (check (equal (mapcar #'core-segments (getf core :ns))
                  '((:ya-e-n1a :ya-e-n1b :ya-e-n1c) (:ya-e-n2a :ya-e-n2b :ya-e-n2c) (:ya-e-n3a :ya-e-n3b :ya-e-n3c))))
    (check (equal (mapcar #'core-segments (getf core :as)) '((:ya-e-as1) (:ya-e-as2 :ya-e-as2b) (:ya-e-as3 :ya-e-as3b :ya-e-as3c)
                                                             (:ya-e-as4a :ya-e-as4b :ya-e-as4c :ya-e-as4))))   ; (AS4 天地灰尽: §31)
    (check (equal (mapcar (lambda (r) (length (core-segments r))) (getf core :as)) '(1 2 3 4)))   ; AS n: n segments
    (check (every (lambda (r) (every (lambda (n) (eq (cls n) :ns)) (core-segments r))) (getf core :ns)))
    (check (every (lambda (r) (every (lambda (n) (eq (cls n) :as)) (core-segments r))) (getf core :as)))
    (check (and (eq (cls :ya-e-sa) :sa) (eq (kit-next kb :ya-e-sa :q) (m :ya-e-j2)) (equal (getf core :as-by-press) '(1 2 3 4))
                (equal (getf core :as-writes) '(1 2 3 nil))))   ; (J4 > AS4, no pointer written: §31)
    (check (and (eq (cls :ya-e-ns-strike) :ns) (eq (cls :ya-e-as-strike) :as)))
    (check (null (assoc :north (gethash :yamamoto *kits*))))                           ; (no 北 form since §33)
    (check (notany (lambda (n) (gethash n (kit-moves kb))) '(:ya-e-n4 :ya-e-n4-strike :ya-n-n1a :ya-n-as)))                                                ; (北's wave NSc left for AS4: §31)
    (check (and (= 3 (length (getf core :ns))) (= 4 (length (getf core :as))) (= 3 (length (getf core :stances)))
                (= 3 (length (getf core :kikon-cines)))))
    ;; the openers' tells: E-J1 and every NS first segment S >= 14 (§7.3)
    (check (equal (mapcar (lambda (n) (mv-s (m n))) '(:ya-e-j1 :ya-e-n1a :ya-e-n2a :ya-e-n3a)) '(14 20 16 22)))
    (check (every (lambda (n) (>= (- (mv-s (m n)) (mv-enter (m n))) 14)) '(:ya-e-j1 :ya-e-n1a :ya-e-n2a :ya-e-n3a)))
    ;; §7.3's damage as built (before :mult 1.0); §30.2: 西 NSa / NSb hit nothing, NSc 90 x1.7 = 153, the charged SAs 84 / 102
    (check (equal (mapcar (lambda (n) (mv-sp-damage (m n)))
                          '(:ya-e-j1 :ya-e-j2 :ya-e-j3 :ya-e-n1a :ya-e-n1b :ya-e-n1c :ya-e-n2a :ya-e-n2b :ya-e-n2c :ya-e-n3a :ya-e-n3b :ya-e-n3c
                            :ya-e-as1 :ya-e-as2 :ya-e-as2b :ya-e-as3 :ya-e-as3b :ya-e-as3c :ya-e-sa :ya-e-sa-c1 :ya-e-sa-c2))
                  '(34 38 42 80 70 120 0 0 153 40 50 70 50 40 70 40 50 100 60 84 102)))
    ;; no mid-route knockdown / crumple / launch (the Bankai's routes); the routes' last segments carry them; E-J3 a stagger
    (dolist (kr (list (cons kb core)))
      (dolist (r (append (getf (cdr kr) :ns) (getf (cdr kr) :as)))
        (dolist (n (butlast (core-segments r)))
          (let ((mv (kit-move (car kr) n)))
            (check (not (or (member (getf (mv-params mv) :react) '(:knockdown :launch :crumple))
                            (loop for w across (mv-hits mv) thereis (member (hw-react w) '(:knockdown :launch :crumple))))))))))
    (check (equal (mapcar #'react '(:ya-e-j3 :ya-e-n1c :ya-e-n2c :ya-e-n3c :ya-e-as1 :ya-e-as2b :ya-e-as3c))
                  '(:stagger :knockback :knockback :crumple :knockdown :launch :knockdown)))
    (check (and (eq (react :ya-e-n3a) :bind) (eq (react :ya-e-as3) :stagger)))   ; 南 NSa binds; AS3a a stagger, not a bind (§7.4)
    ;; each hazard segment names a Kikon strike of its own class (one per class; 北's own, with 天地灰尽's cinematic)
    (dolist (n '(:ya-e-n3a :ya-e-n3b :ya-e-n3c :ya-e-as3 :ya-e-as3b :ya-e-as3c))
      (let* ((mv (m n)) (s (getf (mv-params mv) :kikon-strike)) (smv (and s (m s))))
        (check (and smv (eq (kit-class kb smv) (kit-class kb mv)) (>= (getf (mv-params smv) :follow-cap) 40.0)
                    (zerop (length (mv-hits mv)))))))
    (check (null (mv-cine (m :ya-e-ns-strike))))
    ;; 南 NSa: the point on S, the hands 16 f later inside [S, S + A) (a hazard spawned on S counts its first delay frame there)
    (let ((mv (m :ya-e-n3a)))
      (check (and (= 17 (getf (mv-params mv) :delay)) (= (+ 22 16) (+ (mv-s mv) 17 -1)) (< (+ 22 16) (+ (mv-s mv) (mv-a mv)))
                  (= *ya-bind-stun* (getf (mv-params mv) :stun)))))
    ;; §30.3 南's skeleton tower: NSa raises it (40, a bind, r 1.6 at its base), NSb climbs it to level 2 (50, a bind), NSc topples it (70 /
    ;; 100 by level, a crumple); NSa / NSb's binds keep inside the route (:keep-bind) and name the shatter as their gap's SA (55, a bind that
    ;; keeps, its SA class, J2 after it as after any SA); AS3 the hands (40) > the tower's disc (50) > the pile (100), each a mark 南; the CPU
    ;; raises it from 1-4 m
    (check (equal (loop for n in '(:ya-e-n3a :ya-e-n3b) collect (loop for key in '(:sa :level :radius :dmg :react :keep-bind) collect (getf (mv-params (m n)) key)))
                  '((:ya-e-sa3 nil 1.6 40 :bind t) (:ya-e-sa3 2 1.6 50 :bind t))))
    (check (and (equal (mv-on-frame (m :ya-e-n3a)) '((22 yama-tower-fire))) (equal (mv-on-frame (m :ya-e-n3b)) '((16 yama-tower-fire)))
                (equal (mv-on-frame (m :ya-e-n3c)) '((18 yama-topple-fire))) (null (getf (mv-params (m :ya-e-n3c)) :sa))
                (= 100 (getf (mv-params (m :ya-e-n3c)) :dmg-2))))
    (let ((w (svref (mv-hits (m :ya-e-sa3)) 0)))   ; (its own window: the SA's string and AS read his own contact)
      (check (and (= 1 (length (mv-hits (m :ya-e-sa3)))) (= 55 (hw-dmg w)) (= *ya-bind-stun* (hw-stun w)) (= 6 (hw-from w))
                  (equal (hw-flags w) '(:keep-bind :ranged)) (~= 6.0 (mv-reach (m :ya-e-sa3))))))
    (check (and (eq (cls :ya-e-sa3) :sa) (eq (kit-next kb :ya-e-sa3 :q) (m :ya-e-j2)) (eq (react :ya-e-sa3) :bind)
                (eq (mv-sa-move kb (m :ya-e-n3a)) (m :ya-e-sa3)) (eq (mv-sa-move kb (m :ya-e-n3b)) (m :ya-e-sa3)) (null (mv-sa-move kb (m :ya-e-n3c)))))
    (check (equal (mapcar #'react '(:ya-e-as3 :ya-e-as3b :ya-e-as3c)) '(:stagger :stagger :knockdown)))
    (check (equal (third (getf core :ns-range)) '(1.0 4.0)))
    ;; the pure piece: the topple's way (toward the victim, his facing when the victim stands on the base)
    (check (every #'~= (multiple-value-list (ya-topple-dir 0.0 2.5 3.0 6.5 0.0)) '(0.6 0.8)))
    (check (every #'~= (multiple-value-list (ya-topple-dir 0.0 2.5 0.1 2.6 0.0)) (list (fwd-x 0.0) (fwd-z 0.0))))
    ;; 西 NSb / NSc: the turn moves' armour (only those two); AS1 steals 30; the marks by AS
    (check (equal (loop for n being the hash-keys of (kit-moves kb) using (hash-value mv)
                        when (getf (mv-params mv) :turn-armor) collect n into l finally (return (sort l #'string< :key #'symbol-name)))
                  '(:ya-e-n2b :ya-e-n2c)))
    (check (= 30 (getf (mv-params (m :ya-e-as1)) :steal-fs)))
    (check (equal (mapcar (lambda (n) (getf (mv-params (m n)) :mark))
                          '(:ya-e-as1 :ya-e-as2 :ya-e-as2b :ya-e-as3 :ya-e-as3b :ya-e-as3c :ya-e-n1a))
                  '(1 2 2 3 3 3 nil)))
    (check (notany (lambda (n) (assoc 0 (mv-on-frame (m n)))) '(:ya-e-n1a :ya-e-n2a :ya-e-n3a :ya-e-n3b)))   ; no heat spend in the Bankai
    ;; §30.2 西's garb charge: NSa / NSb no hit, still NS-classed, a setup's 10 SP, each naming its charged SA (x1.4 / x1.7, its own damage
    ;; and reach baked: 2.0 + 0.8 / 1.6), the SA's string goes on at E-J2; NSb keeps the 1.5 m advance and its armour; NSc reach 3.6
    (check (and (zerop (length (mv-hits (m :ya-e-n2a)))) (zerop (length (mv-hits (m :ya-e-n2b))))
                (eq (cls :ya-e-n2a) :ns) (eq (cls :ya-e-n2b) :ns) (~= 10.0 (kit-sp-cost kb (m :ya-e-n2a))) (~= 10.0 (kit-sp-cost kb (m :ya-e-n2b)))
                (~= 1.5 (mv-slide (m :ya-e-n2b))) (getf (mv-params (m :ya-e-n2b)) :turn-armor)
                (~= 3.6 (mv-reach (m :ya-e-n2c))) (~= 60.0 (kit-sp-cost kb (m :ya-e-n2c)))))
    (check (and (eq (mv-sa-move kb (m :ya-e-n2a)) (m :ya-e-sa-c1)) (eq (mv-sa-move kb (m :ya-e-n2b)) (m :ya-e-sa-c2))
                (null (mv-sa-move kb (m :ya-e-n1a)))))
    (check (and (eq (cls :ya-e-sa-c1) :sa) (eq (cls :ya-e-sa-c2) :sa) (null (kit-sp-cost kb (m :ya-e-sa-c1)))
                (~= 1.4 (getf (mv-params (m :ya-e-sa-c1)) :charge-mult)) (~= 1.7 (getf (mv-params (m :ya-e-sa-c2)) :charge-mult))
                (~= 2.8 (mv-reach (m :ya-e-sa-c1))) (~= 3.6 (mv-reach (m :ya-e-sa-c2)))
                (eq (kit-next kb :ya-e-sa-c1 :q) (m :ya-e-j2)) (eq (kit-next kb :ya-e-sa-c2 :q) (m :ya-e-j2))))
    (check (and (= 2 (length *ya-reach-copies*)) (equal *ya-reach-moves* '(:ya-e-j2 :ya-e-j3 :ya-e-j4 :ya-e-as1 :ya-e-as2 :ya-e-as2b))))
    ;; the reach copies: the same name, class (registered in the kit's table), SP cost, damage, frames, react and params; reach + 0.8 / + 1.6
    (loop for add in '(0.8 1.6) for lv from 1
          do (dolist (n *ya-reach-moves*)
               (let ((c (ya-reach-copy n lv)) (mv (m n)))
                 (check (and c (not (eq c mv)) (eq (mv-name c) n) (eq (kit-class kb c) (kit-class kb mv))
                             (eql (kit-sp-cost kb c) (kit-sp-cost kb mv)) (= (mv-sp-damage c) (mv-sp-damage mv))
                             (= (mv-s c) (mv-s mv)) (= (mv-a c) (mv-a mv)) (= (mv-r c) (mv-r mv)) (equal (mv-params c) (mv-params mv))
                             (eq (hw-react (svref (mv-hits c) 0)) (hw-react (svref (mv-hits mv) 0)))
                             (~= (+ (mv-reach mv) add) (mv-reach c)) (~= (+ (mv-reach mv) add) (aref (first (hw-vols (svref (mv-hits c) 0))) 1)))))))
    (check (and (null (ya-reach-copy :ya-e-j1 1)) (null (ya-reach-copy :ya-e-as3 2)) (null (ya-reach-copy :ya-e-j2 0))))
    (check (equal (mapcar #'ya-charge-level '(1.0 1.4 1.7)) '(0 1 2)))
    ;; YAMA-REACH-SWAP on a stand-in fighter: charged, a reach move swaps to the level's copy (a cancel's dead mark with it); else nothing
    (let ((f (make-fighter :kit kb)))
      (setf (fighter-move f) (m :ya-e-j2) (fighter-charge-mult f) 1.7 (fighter-dead-mv f) (m :ya-e-j2))
      (yama-reach-swap f)
      (check (and (eq (fighter-move f) (ya-reach-copy :ya-e-j2 2)) (eq (fighter-dead-mv f) (fighter-move f)) (~= 3.19 (mv-reach (fighter-move f)))))
      (yama-reach-swap f)                                                ; (again: already the copy)
      (check (eq (fighter-move f) (ya-reach-copy :ya-e-j2 2)))
      (setf (fighter-move f) (m :ya-e-as2) (fighter-charge-mult f) 1.4)
      (yama-reach-swap f)
      (check (and (eq (fighter-move f) (ya-reach-copy :ya-e-as2 1)) (~= 2.4 (mv-reach (fighter-move f)))))
      (setf (fighter-move f) (m :ya-e-as3) (fighter-charge-mult f) 1.7)   ; 南's hazard AS: unboosted
      (yama-reach-swap f)
      (check (eq (fighter-move f) (m :ya-e-as3)))
      (setf (fighter-move f) (m :ya-e-j2) (fighter-charge-mult f) 1.0)    ; no charge: as written
      (yama-reach-swap f)
      (check (eq (fighter-move f) (m :ya-e-j2))))
    ;; stance by pointer
    (check (equal (getf core :stances) '(:ya-st-higashi :ya-st-nishi :ya-st-minami)))
    (let ((f (make-fighter :kit kb)))
      (check (equal (loop for p from 1 to 3 collect (progn (setf (fighter-ptr f) p) (fighter-stance-clip f)))
                    '(:ya-st-higashi :ya-st-nishi :ya-st-minami))))
    ;; the turn moves' armour in the triangle (pure): an NA that would cancel is absorbed; an AS still hits; nothing changes unarmoured
    (check (eq :absorb (core-turn-armor-verdict (core-verdict :na :ns) :na t)))
    (check (eq :hit (core-turn-armor-verdict (core-verdict :as :ns) :as t)))
    (check (eq :cancel (core-turn-armor-verdict (core-verdict :sa :ns) :sa t)))
    (check (eq :cancel (core-turn-armor-verdict (core-verdict :na :ns) :na nil)))
    ;; §31 AS4 天地灰尽 (J4's): E-J4 the string's fourth link; its four segments 40 > 50 > 60 > 140 (only the last knocks down),
    ;; each tagged :as4 and carrying 天地灰尽's cinematic; frame 0 marks it used; the x and the Konpaku by the marks held
    (check (and (eq (kit-next kb :ya-e-j3 :q) (m :ya-e-j4)) (eq (cls :ya-e-j4) :na) (= 46 (mv-sp-damage (m :ya-e-j4)))
                (member :ya-e-j4 *ya-reach-moves*)))
    (check (equal (mapcar (lambda (n) (mv-sp-damage (m n))) '(:ya-e-as4a :ya-e-as4b :ya-e-as4c :ya-e-as4)) '(40 50 60 140)))
    (check (equal (mapcar #'react '(:ya-e-as4a :ya-e-as4b :ya-e-as4c :ya-e-as4))
                  '(:stagger :stagger :stagger :knockdown)))
    (check (every (lambda (n) (and (getf (mv-params (m n)) :as4) (eq (mv-cine (m n)) 'yama-tenchi-cine)))
                  '(:ya-e-as4a :ya-e-as4b :ya-e-as4c :ya-e-as4)))
    (check (eq 'yama-as4-start (second (assoc 0 (mv-on-frame (m :ya-e-as4a))))))
    (check (and (~= 1.0 (ya-as4-x 0)) (~= 1.25 (ya-as4-x 1)) (~= 1.5 (ya-as4-x 5)) (~= 1.75 (ya-as4-x 7))))
    (check (equal (mapcar (lambda (m) (ya-as4-konpaku m 3)) '(0 2 6 7)) '(2 3 4 5)))
    (check (eq (kit-hook kb :kikon-n) 'yama-kikon-n))
    ;; the marks (pure): one bit per AS, a repeated mark stays one (all three enter nothing since §33)
    (check (equal (mapcar (lambda (a) (apply #'ya-mark-add a)) '((0 1) (1 1) (1 3) (5 2) (7 2))) '(1 1 5 7 7)))
    ;; the sim side on stand-in fighters: an AS hit's mark (a block, an NA, the Kikon's follow-up none), all three held (marks 7);
    ;; the heat leaving on the awakening; the HUD's tags
    (multiple-value-bind (a b) (t-pair kb (kit :kenpachi :base))
      (t-at a 0 0) (t-at b 0 1.6)
      (let ((fa (fighter a)) (*match-tick* 900))
        (flet ((in (n tick) (let ((mv (m n)))
                              (setf (fighter-state fa) :move (fighter-move fa) mv (fighter-cls fa) (kit-class kb mv) (fighter-cls-t fa) tick
                                    (fighter-sf fa) 0 (fighter-phase fa) :main (fighter-follow fa) nil)
                              mv))
               (marks () (yss-marks (ys a))))
          (setf (fighter-form fa) :bankai (fighter-kit fa) kb (fighter-character fa) :yamamoto (fighter-ptr fa) 2 (gauges-meter (gauges a)) 55f0)
          (yama-bankai-enter a)                                            ; heat leaves with the Shikai (§3)
          (check (~= 0.0 (gauges-meter (gauges a))))
          (yama-bk-hit a b :blocked nil (in :ya-e-as1 900) nil nil)        ; a block: no mark
          (check (= 0 (marks)))
          (yama-bk-hit a b :hit nil (in :ya-e-j1 905) nil nil)             ; an NA: none
          (check (= 0 (marks)))
          (yama-bk-hit a b :hit nil (in :ya-e-as1 910) nil nil)            ; AS1 lands: 東
          (check (= 1 (marks)))
          (yama-bk-hit a b :hit nil (in :ya-e-as1 920) nil nil)            ; again: still one
          (check (= 1 (marks)))
          (let ((hz (make-hazard :kind :ya-col :owner a :cls :as :sp-src 930 :data (list :mark 3))))   ; AS3's hands (a hazard): 南
            (yama-bk-hit a b :hit nil nil hz nil))
          (check (= 5 (marks)))
          (setf (fighter-follow fa) t)                                     ; the Kikon's follow-up strike: none
          (yama-bk-hit a b :hit nil (m :ya-e-as2) nil nil)
          (setf (fighter-follow fa) nil)
          (check (= 5 (marks)))
          (in :ya-e-as2b 940) (setf (fighter-move fa) (ya-reach-copy :ya-e-as2b 2))   ; (a charged copy: its :mark as its move's)
          (yama-bk-hit a b :hit nil (fighter-move fa) nil nil)              ; the third distinct mark, the pointer untouched
          (check (and (= 7 (marks)) (= 2 (fighter-ptr fa))))
          ;; AS4 used: his next neutral clears the marks (not before)
          (in :ya-e-as4a 950) (yama-as4-start a)
          (yama-as4-spent a fa)
          (check (= 7 (marks)))
          (setf (fighter-state fa) :idle (fighter-move fa) nil)
          (yama-as4-spent a fa)
          (check (and (= 0 (marks)) (null (yss-as4 (ys a)))))
          ;; the HUD's tag: the marks by number, constant strings
          (setf (yss-marks (ys a)) 0)
          (check (null (yama-bk-tag a)))
          (yama-mark! a 1) (yama-mark! a 3)
          (check (and (equal (yama-bk-tag a) "MARK 13") (eq (yama-bk-tag a) (yama-bk-tag a))))
          (yama-mark! a 2)
          (check (equal (yama-bk-tag a) "MARK 123"))
          (setf (yss-marks (ys a)) 0))))
    ;; §30.3 the tower on stand-in fighters: NSa raises it 2.5 m before him at the victim's bearing (a hitless :ya-tower, level 1, standing 90 f
    ;; after the segment) with its bind disc at the base (40, :keep-bind, delay 17); NSb climbs it (level 2, the stand renewed, a bind disc 50);
    ;; NSc topples it toward the victim: a 6 m line (100), the tower spent; a line that touches along its length, not beside it; the shatter
    ;; spends a standing tower
    (multiple-value-bind (a b) (t-pair kb (kit :kenpachi :base))
      (setf *t-hz* nil)
      (t-at a 0 0 (dir-yaw 0.0 5.0)) (t-at b 3.0 4.0)
      (let ((fa (fighter a)))
        (flet ((in (n) (let ((mv (m n))) (setf (fighter-state fa) :move (fighter-move fa) mv (fighter-cls fa) (kit-class kb mv) (fighter-sf fa) (mv-s mv))))
               (kind (k) (mapcar #'cdr (remove k *t-hz* :key (lambda (x) (hazard-kind (cdr x))) :test-not #'eq))))
          (in :ya-e-n3a) (yama-tower-fire a)
          (let ((tw (first (kind :ya-tower))) (d (first (kind :ya-col))))
            (check (and tw (null (hazard-hw tw)) (~= 1.5 (hazard-x tw)) (~= 2.0 (hazard-z tw)) (= 1 (getf (hazard-data tw) :level))
                        (= (+ 37 90) (hazard-life tw))))
            (check (and d (~= 1.5 (hazard-x d)) (~= 1.6 (hazard-size d)) (= 17 (hazard-delay d)) (= 40 (hw-dmg (hazard-hw d)))
                        (eq :bind (hw-react (hazard-hw d))) (= *ya-bind-stun* (hw-stun (hazard-hw d))) (equal (hw-flags (hazard-hw d)) '(:keep-bind))
                        (eq (hazard-cls d) :ns))))
          (setf (hazard-age (first (kind :ya-tower))) 50)
          (in :ya-e-n3b) (yama-tower-fire a)
          (let ((tw (first (kind :ya-tower))) (d (second (kind :ya-col))))
            (check (and (= 1 (length (kind :ya-tower))) (= 2 (getf (hazard-data tw) :level)) (= (+ 50 24 90) (hazard-life tw))))
            (check (and d (~= 1.5 (hazard-x d)) (= 0 (hazard-delay d)) (= 50 (hw-dmg (hazard-hw d))) (eq :bind (hw-react (hazard-hw d))))))
          (in :ya-e-n3c) (yama-topple-fire a)
          (let ((fl (first (kind :ya-fall))))
            (check (and (null (kind :ya-tower)) fl (= 100 (hw-dmg (hazard-hw fl))) (eq :crumple (hw-react (hazard-hw fl))) (~= 3.0 (hazard-size fl))
                        (~= (+ 1.5 (* 3.0 0.6)) (hazard-x fl)) (~= (+ 2.0 (* 3.0 0.8)) (hazard-z fl))))
            (flet ((touch (x z) (yama-hz nil fl :touches (f32 x) 0f0 (f32 z) 0.36f0 1.65f0)))
              (check (and (touch 1.5 2.0) (touch 3.0 4.0) (touch 4.8 6.4)))   ; the base, the victim, the tip (6 m out)
              (check (not (or (touch 5.5 7.4) (touch 3.9 2.7) (touch 0.0 0.0))))))   ; past the tip, 1.5 m beside it, him
          (setf *t-hz* nil)
          (in :ya-e-n3a) (yama-tower-fire a)
          (in :ya-e-sa3) (yama-shatter-fire a)
          (check (and (notany (lambda (x) (eq (hazard-kind (cdr x)) :ya-tower)) *t-hz*)   ; the shatter spends the tower; its hit is
                      (find :fx *t-hz* :key (lambda (x) (hazard-kind (cdr x))))))))                   ;  the window, the look a hitless :fx
      (setf *t-hz* nil))
    ;; the Lisp HUD's side: the seals 東 西 南, the marks next to the pointer; the tag line shows none of them (北's seal and its kit
    ;; strip, kind 6, left with the form: §33)
    (let ((e (lhud-fighter 1)))
      (check (equal (mapcar #'first (lhud-seals e "ZANKA NO TACHI" "MARK 13")) '("東" "西" "南")))
      (check (equal (second (first (lhud-seals e "ZANKA NO TACHI" nil))) "東 · KYOKUJITSUJIN"))
      (check (equal (mapcar #'first (lhud-seals e "" "HEAT")) '("火" "城" "撫"))))   ; (the Shikai's, unchanged)
    (check (and (equal (lhud-marks "MARK 13") '("東" "南")) (equal (lhud-marks "MARK 123") '("東" "西" "南"))
                (null (lhud-marks "HEAT")) (null (lhud-marks nil))))
    (check (and (= 0 (lhud-kit-kind "NORTH")) (= 5 (lhud-kit-kind "GOKUEN")) (= 0 (lhud-kit-kind "MARK 13"))))
    (check (equal (lhud-tag-segments "YAMAMOTO  ZANKA NO TACHI" "MARK 12") (list (cons "ZANKA NO TACHI" nil))))
    ;; the armour hook and param stay off for every other kit
    (check (loop for c being the hash-keys of *kits* using (hash-value alist)
                 always (loop for (f . kk) in alist
                              always (or (and (eq c :yamamoto) (eq f :bankai))
                                         (and (null (kit-hook kk :armored-fx))
                                              (or (eq c :yamamoto) (null (kit-hook kk :planted)))   ; (art K3: the planted blade, PLANTED-SPOT;
                                                                                                     ;  art S4: 爆炎's IKKOTSU, every form of his)
                                              (loop for mv being the hash-values of (kit-moves kk) never (getf (mv-params mv) :turn-armor)))))))
    ;; art K2 (DUEL_YAMA_CORE §17): the Bankai's smear is the ink wash with an ember hairline (look 3); art S1 (§22): the Shikai's a thin
    ;; fire wash with an orange hairline (look 4); art S4 (§25): 爆炎's flame trail (look 5); every other form keeps the REIATSU comet
    ;; (KIT :smear NIL: DRAW-FIGHTER passes 1, as before)
    (check (eql 3 (kit-smear kb)))
    (check (eql 4 (kit-smear (find-kit :yamamoto :base))))
    (check (eql 5 (kit-smear (find-kit :yamamoto :blaze))))
    (check (loop for c being the hash-keys of *kits* using (hash-value alist)
                 always (loop for (f . kk) in alist always (or (eq c :yamamoto) (null (kit-smear kk))))))
    ;; art K3 (§18): the hooks that replace the armour spark and plant the blade are the Bankai's (the planting one every form's since art
    ;; S4); no move in any kit sets :planted (the generic 0.7 m spot is unused), and a :blend is only on the Bankai's E-J1 (+ its Kikon
    ;; copies) (looks; 北's wave and entry pose too until §31 / §33)
    (check (and (kit-hook kb :armored-fx) (kit-hook kb :planted) (kit-hook (find-kit :yamamoto :blaze) :planted)))
    ;; art batch D (§34): 天地灰尽's ash on the victim's drawn body (DRAW-FIGHTER's VICTIM-LOOK) is the Bankai's hook alone
    (check (eq (kit-hook kb :victim-look) 'yama-victim-look))
    (check (loop for c being the hash-keys of *kits* using (hash-value alist)
                 always (loop for (f . kk) in alist always (or (and (eq c :yamamoto) (eq f :bankai)) (null (kit-hook kk :victim-look))))))
    (check (loop for c being the hash-keys of *kits* using (hash-value alist)
                 always (loop for (nil . kk) in alist always (loop for mv being the hash-values of (kit-moves kk) never (mv-planted mv)))))
    (check (equal (sort (loop for mv being the hash-values of (kit-moves kb) unless (zerop (mv-blend mv)) collect (mv-name mv)) #'string<)
                  '(:ya-e-as-strike :ya-e-j1 :ya-e-ns-strike)))
    ;; art S2 (§23): in the Shikai and 爆炎 only J1 (it starts from three stances) and its copies (the Kikon strikes, 爆炎's J1) blend in;
    ;; art S4 (§25): 爆炎's entry pose too (it starts from any stance)
    (check (equal (sort (loop for mv being the hash-values of (kit-moves (find-kit :yamamoto :blaze)) unless (zerop (mv-blend mv)) collect (mv-name mv))
                        #'string<)
                  '(:ya-as-strike :ya-b-j1 :ya-blaze-in :ya-j1 :ya-ns-strike)))))

;; art S5 (DUEL_YAMA_CORE §26): every glyph of the Shikai Kikon cinematics' captions (不知火, 焱熱地獄, 撫斬) is baked into glyphs.lisp
;; (tools/glyph-bake.py; 焱 composed from three of the font's 火: Yuji Syuku has none), and 焱 is three copies of 火's polygons
(load (merge-pathnames "../../duel/lisp/glyphs.lisp" *load-truename*))
(check (every (lambda (ch) (assoc (char-code ch) *glyph-outlines*)) "不知火焱熱地獄撫斬"))
(check (= (length (cddr (assoc (char-code #\焱) *glyph-outlines*))) (* 3 (length (cddr (assoc (char-code #\火) *glyph-outlines*))))))
;; art S5's wiring (§26): the Shikai's and 爆炎's Kikons (and Soul Breaks) play the three Shikai cinematics by pointer (Q2: the same three)
(check (loop for f in '(:base :blaze)
             always (equal (getf (kit-core (find-kit :yamamoto f)) :kikon-cines) '(yama-shiranui-cine yama-ennetsu-cine yama-nadegiri-cine))))

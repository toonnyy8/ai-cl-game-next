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
    (let ((hz '(:ya-n1a :ya-n1b :ya-n1c :ya-n2a :ya-n2b :ya-n2c :ya-as2 :ya-as2b)))
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
    ;; one ring at a time (stand-in entities): a second NS2b's ring puts the first out; the dome lands on the ring and spends it
    (multiple-value-bind (a b) (t-pair k (kit :kenpachi :base))
      (setf *t-hz* nil)
      (t-at a 0 0) (t-at b 0 5.0)
      (let ((fa (fighter a)))
        (flet ((rings () (count :ya-ring *t-hz* :key (lambda (x) (hazard-kind (cdr x)))))
               (in (n) (setf (fighter-state fa) :move (fighter-move fa) (m n) (fighter-cls fa) (cls n) (fighter-sf fa) (mv-s (m n)))))
          (in :ya-n2b) (yama-ring-fire a)
          (check (= 1 (rings)))
          (let ((h1 (cdr (find :ya-ring *t-hz* :key (lambda (x) (hazard-kind (cdr x)))))))
            (check (and (~= 5.0 (hazard-z h1)) (eq (hazard-cls h1) :ns) (~= 1.6 (hazard-size h1)) (= 90 (hazard-life h1))
                        (= 20 (hw-dmg (hazard-hw h1))) (~= 1.0 (getf (hazard-data h1) :x)))))
          (t-at b 0 6.0) (yama-ring-fire a)
          (check (= 1 (rings)))                                            ; the first went out
          (check (~= 6.0 (hazard-z (cdr (find :ya-ring *t-hz* :key (lambda (x) (hazard-kind (cdr x))))))))
          (t-at b 3.0 6.0) (in :ya-n2c) (yama-dome-fire a)
          (check (= 0 (rings)))                                            ; spent by the dome
          (let ((d (cdr (find :ya-dome *t-hz* :key (lambda (x) (hazard-kind (cdr x)))))))
            (check (and d (~= 0.0 (hazard-x d)) (~= 6.0 (hazard-z d)) (eq (hazard-cls d) :ns) (= 80 (hw-dmg (hazard-hw d))))))
          (setf *t-hz* nil))))))

;;; ================================================================ stage B: the heat gauge and 爆炎 (DUEL_YAMA_CORE §3, §7.2, §7.4)
(let* ((k (kit :yamamoto :base)) (kb (kit :yamamoto :blaze)) (core (kit-core kb)))
  (flet ((m (n) (kit-move kb n)) (cls (n) (kit-class kb (kit-move kb n))))
    ;; the pure heat rules: gains (Y1: NA 8 / SA 10 / AS 12, NS / none 0, capped at 100)
    (check (every #'~= (mapcar (lambda (c) (ya-heat-gain 0.0 c)) '(:na :sa :as :ns nil)) '(8.0 10.0 12.0 0.0 0.0)))
    (check (~= 100.0 (ya-heat-gain 95.0 :as)))
    ;; J1-J2-J3 > AS3 adds 60 (§7.4's watch line)
    (check (~= 60.0 (reduce #'ya-heat-gain '(:na :na :na :as :as :as) :initial-value 0.0)))
    ;; the NS spend (Y2 / Y3): 25 or what is left, the boost in proportion; no hit of its own: nothing; 爆炎: 25, x1 (Y9)
    (flet ((sp (h hit b) (multiple-value-list (ya-ns-spend h hit b))))
      (check (every #'~= (sp 40.0 t nil) '(25.0 1.3)))
      (check (every #'~= (sp 10.0 t nil) '(10.0 1.12)))
      (check (every #'~= (sp 0.0 t nil) '(0.0 1.0)))
      (check (every #'~= (sp 40.0 nil nil) '(0.0 1.0)))                 ; NS2b's ring
      (check (every #'~= (sp 60.0 t t) '(25.0 1.0)))
      (check (every #'~= (sp 7.0 t t) '(7.0 1.0))))
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
    (dolist (n '(:ya-b-n1a :ya-b-n1b :ya-b-n1c :ya-b-n2a :ya-b-n2b :ya-b-n2c :ya-b-as2 :ya-b-as2b))
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
            (check (~= 65.0 (gauges-meter ga) 0.01))                       ; 爆炎's NS: 25
            (yama-cancel a b mv nil) (yama-cancel a b mv nil)
            (check (and (= 477 (gauges-reishi gb)) (~= 90.0 (gauges-meter ga) 0.01))))   ; 91 x 0.25 = 23; the 25 back
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
;;; §7.4)
(let* ((kb (kit :yamamoto :bankai)) (core (kit-core kb)))
  (flet ((m (n) (kit-move kb n)) (cls (n) (kit-class kb (kit-move kb n)))
         (react (n) (let ((mv (kit-move kb n))) (or (getf (mv-params mv) :react) (hw-react (svref (mv-hits mv) 0))))))
    ;; the kit: an awakened form of its own (no :inherit: no heat hooks), the TYBW dress, ZANKA, East's stance, the old awakening cinematic
    (check (and (kit-awakening kb) (null (kit-inherit kb)) (eq (kit-body kb) :yamamoto-tybw) (eq (kit-weapon kb) :zanka)
                (eq (kit-stance kb) :ya-e-stance) (eq (kit-cine kb) 'yama-bankai-cine) (equal (kit-form-name kb) "ZANKA NO TACHI")
                (null (kit-hook kb :tick)) (null (kit-hook kb :cancel)) (not (kit-sp-free-p kb)) (zerop (kit-burn kb))
                (equal (getf (kit-meter kb) :name) "ZANKA") (~= 1.0 (getf core :mult))))
    ;; every class tag: NA E-J1-J3, the three NS routes, the three AS, the SA, 北's NS / AS (the extras), each Kikon strike as its segment
    (check (every (lambda (n) (eq (cls n) :na)) '(:ya-e-j1 :ya-e-j2 :ya-e-j3)))
    (check (equal (mapcar #'core-segments (getf core :ns))
                  '((:ya-e-n1a :ya-e-n1b :ya-e-n1c) (:ya-e-n2a :ya-e-n2b :ya-e-n2c) (:ya-e-n3a :ya-e-n3b :ya-e-n3c))))
    (check (equal (mapcar #'core-segments (getf core :as)) '((:ya-e-as1) (:ya-e-as2 :ya-e-as2b) (:ya-e-as3 :ya-e-as3b :ya-e-as3c))))
    (check (equal (mapcar (lambda (r) (length (core-segments r))) (getf core :as)) '(1 2 3)))   ; AS n: n segments
    (check (every (lambda (r) (every (lambda (n) (eq (cls n) :ns)) (core-segments r))) (getf core :ns)))
    (check (every (lambda (r) (every (lambda (n) (eq (cls n) :as)) (core-segments r))) (getf core :as)))
    (check (and (equal (getf core :ns-extra) '(:ya-e-n4)) (equal (getf core :as-extra) '(:ya-e-as4))
                (eq (cls :ya-e-n4) :ns) (eq (cls :ya-e-as4) :as) (null (mv-ns-next kb (m :ya-e-n4))) (null (mv-ns-next kb (m :ya-e-as4)))))
    (check (and (eq (cls :ya-e-sa) :sa) (eq (kit-next kb :ya-e-sa :q) (m :ya-e-j2)) (equal (getf core :as-by-press) '(1 2 3))))
    (check (and (eq (cls :ya-e-ns-strike) :ns) (eq (cls :ya-e-as-strike) :as) (eq (cls :ya-e-n4-strike) :ns)))
    ;; 北 is no pointer: the grammar's three routes each, so the clamp, the stances, the Kikon table and the switch's route count stay 1-3
    (check (and (= 3 (length (getf core :ns))) (= 3 (length (getf core :as))) (= 3 (length (getf core :stances)))
                (= 3 (length (getf core :kikon-cines)))))
    ;; the openers' tells: E-J1 and every NS first segment S >= 14, 北's NS 24 (§7.3)
    (check (equal (mapcar (lambda (n) (mv-s (m n))) '(:ya-e-j1 :ya-e-n1a :ya-e-n2a :ya-e-n3a :ya-e-n4)) '(14 20 16 22 24)))
    (check (every (lambda (n) (>= (- (mv-s (m n)) (mv-enter (m n))) 14)) '(:ya-e-j1 :ya-e-n1a :ya-e-n2a :ya-e-n3a :ya-e-n4)))
    ;; §7.3's damage as built (before :mult 1.0)
    (check (equal (mapcar (lambda (n) (mv-sp-damage (m n)))
                          '(:ya-e-j1 :ya-e-j2 :ya-e-j3 :ya-e-n1a :ya-e-n1b :ya-e-n1c :ya-e-n2a :ya-e-n2b :ya-e-n2c :ya-e-n3a :ya-e-n3b :ya-e-n3c
                            :ya-e-as1 :ya-e-as2 :ya-e-as2b :ya-e-as3 :ya-e-as3b :ya-e-as3c :ya-e-n4 :ya-e-as4 :ya-e-sa))
                  '(34 38 42 80 70 120 90 40 90 40 50 70 50 40 70 40 50 100 220 180 60)))
    ;; no mid-route knockdown / crumple / launch; the routes' last segments carry them; 北 knocks down both ways; E-J3 a stagger
    (dolist (r (append (getf core :ns) (getf core :as)))
      (dolist (n (butlast (core-segments r)))
        (let ((mv (m n)))
          (check (not (or (member (getf (mv-params mv) :react) '(:knockdown :launch :crumple))
                          (loop for w across (mv-hits mv) thereis (member (hw-react w) '(:knockdown :launch :crumple)))))))))
    (check (equal (mapcar #'react '(:ya-e-j3 :ya-e-n1c :ya-e-n2c :ya-e-n3c :ya-e-as1 :ya-e-as2b :ya-e-as3c :ya-e-n4 :ya-e-as4))
                  '(:stagger :knockback :knockback :crumple :knockdown :launch :knockdown :knockdown :knockdown)))
    (check (and (eq (react :ya-e-n3a) :bind) (eq (react :ya-e-as3) :stagger)))   ; 南 NSa binds; AS3a a stagger, not a bind (§7.4)
    ;; each hazard segment names a Kikon strike of its own class (one per class; 北's own, with 天地灰尽's cinematic)
    (dolist (n '(:ya-e-n3a :ya-e-n3b :ya-e-n3c :ya-e-as3 :ya-e-as3b :ya-e-as3c :ya-e-n4))
      (let* ((mv (m n)) (s (getf (mv-params mv) :kikon-strike)) (smv (and s (m s))))
        (check (and smv (eq (kit-class kb smv) (kit-class kb mv)) (>= (getf (mv-params smv) :follow-cap) 40.0)
                    (zerop (length (mv-hits mv)))))))
    (check (and (eq (mv-cine (m :ya-e-n4-strike)) 'yama-tenchi-cine) (eq (mv-cine (m :ya-e-as4)) 'yama-tenchi-cine)
                (null (mv-cine (m :ya-e-ns-strike)))))
    ;; 南 NSa: the point on S, the hands 16 f later inside [S, S + A) (a hazard spawned on S counts its first delay frame there)
    (let ((mv (m :ya-e-n3a)))
      (check (and (= 17 (getf (mv-params mv) :delay)) (= (+ 22 16) (+ (mv-s mv) 17 -1)) (< (+ 22 16) (+ (mv-s mv) (mv-a mv)))
                  (= *ya-bind-stun* (getf (mv-params mv) :stun)))))
    ;; 西 NSb / NSc: the turn moves' armour (only those two); 西 NSa two hits of 45 round him; AS1 steals 30; the marks by AS
    (check (equal (loop for n being the hash-keys of (kit-moves kb) using (hash-value mv)
                        when (getf (mv-params mv) :turn-armor) collect n into l finally (return (sort l #'string< :key #'symbol-name)))
                  '(:ya-e-n2b :ya-e-n2c)))
    (check (and (= 2 (length (mv-hits (m :ya-e-n2a)))) (~= 2.0 (mv-reach (m :ya-e-n2b))) (= 30 (getf (mv-params (m :ya-e-as1)) :steal-fs))))
    (check (equal (mapcar (lambda (n) (getf (mv-params (m n)) :mark))
                          '(:ya-e-as1 :ya-e-as2 :ya-e-as2b :ya-e-as3 :ya-e-as3b :ya-e-as3c :ya-e-as4 :ya-e-n1a))
                  '(1 2 2 3 3 3 nil nil)))
    (check (and (getf (mv-params (m :ya-e-n4)) :north) (getf (mv-params (m :ya-e-as4)) :north)
                (eq 'yama-north-start (second (assoc 0 (mv-on-frame (m :ya-e-n4))))) (eq 'yama-north-start (second (assoc 0 (mv-on-frame (m :ya-e-as4)))))))
    (check (notany (lambda (n) (assoc 0 (mv-on-frame (m n)))) '(:ya-e-n1a :ya-e-n2a :ya-e-n3a :ya-e-n3b)))   ; no heat spend in the Bankai
    ;; 北's NS starts as a route's first segment (at fs 0, as any NSa); its SP from its damage (DUEL_SP §4)
    (check (and (kit-sp-start-p kb (m :ya-e-n4) 0.0 nil) (not (kit-sp-start-p kb (m :ya-e-n1b) 0.0 nil))
                (~= 60.0 (kit-sp-cost kb (m :ya-e-n4))) (~= 60.0 (kit-sp-cost kb (m :ya-e-as4)))))
    ;; stance by pointer
    (check (equal (getf core :stances) '(:ya-e-stance :ya-st-nishi :ya-st-minami)))
    (let ((f (make-fighter :kit kb)))
      (check (equal (loop for p from 1 to 3 collect (progn (setf (fighter-ptr f) p) (fighter-stance-clip f)))
                    '(:ya-e-stance :ya-st-nishi :ya-st-minami))))
    ;; the turn moves' armour in the triangle (pure): an NA that would cancel is absorbed; an AS still hits; nothing changes unarmoured
    (check (eq :absorb (core-turn-armor-verdict (core-verdict :na :ns) :na t)))
    (check (eq :hit (core-turn-armor-verdict (core-verdict :as :ns) :as t)))
    (check (eq :cancel (core-turn-armor-verdict (core-verdict :sa :ns) :sa t)))
    (check (eq :cancel (core-turn-armor-verdict (core-verdict :na :ns) :na nil)))
    ;; the marks and 北 (pure): one bit per AS, a repeated mark stays one, the third distinct arms 北; its start clears; the switch refused
    (check (equal (multiple-value-list (ya-mark-add 0 1)) '(1 nil)))
    (check (equal (multiple-value-list (ya-mark-add 1 1)) '(1 nil)))
    (check (equal (multiple-value-list (ya-mark-add 1 3)) '(5 nil)))
    (check (equal (multiple-value-list (ya-mark-add 5 2)) '(7 t)))
    (check (equal (multiple-value-list (ya-mark-add 7 2)) '(7 t)))
    (check (equal (multiple-value-list (ya-north-start 7 t)) '(0 nil)))
    (check (equal (multiple-value-list (ya-north-pick t :n :a)) '(:n :a)))
    (check (null (ya-north-pick nil :n :a)))
    (check (and (ya-switch-ok-p nil nil) (not (ya-switch-ok-p t nil)) (not (ya-switch-ok-p nil t))))
    ;; the sim side on stand-in fighters: an AS hit's mark (a block, an NA, 北's AS none), the third arms 北, the picks, the start (the
    ;; marks cleared, the pointer never 4, the Kikon profile 3), the switch's refusal, the heat leaving on the awakening
    (multiple-value-bind (a b) (t-pair kb (kit :kenpachi :base))
      (t-at a 0 0) (t-at b 0 1.6)
      (let ((fa (fighter a)) (*match-tick* 900))
        (flet ((in (n tick) (let ((mv (m n)))
                              (setf (fighter-state fa) :move (fighter-move fa) mv (fighter-cls fa) (kit-class kb mv) (fighter-cls-t fa) tick
                                    (fighter-sf fa) 0 (fighter-phase fa) :main (fighter-follow fa) nil)
                              mv))
               (marks () (yss-marks (ys a))) (north () (yss-north (ys a))))
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
          (check (and (= 1 (marks)) (not (north))))
          (let ((hz (make-hazard :kind :ya-col :owner a :cls :as :sp-src 930 :data (list :mark 3))))   ; AS3's hands (a hazard): 南
            (yama-bk-hit a b :hit nil nil hz nil))
          (check (and (= 5 (marks)) (not (north))))
          (setf (fighter-follow fa) t)                                     ; the Kikon's follow-up strike: none
          (yama-bk-hit a b :hit nil (m :ya-e-as2) nil nil)
          (setf (fighter-follow fa) nil)
          (check (= 5 (marks)))
          (check (null (yama-ns-pick a fa)))                               ; not armed: the pointer's
          (check (null (yama-as-pick a fa 2)))
          (check (yama-switch-ok a fa))
          (yama-bk-hit a b :hit nil (in :ya-e-as2b 940) nil nil)           ; the third distinct mark: 北 armed, the pointer untouched
          (check (and (= 7 (marks)) (north) (= 2 (fighter-ptr fa))))
          (check (eq (yama-ns-pick a fa) (m :ya-e-n4)))                    ; the NS / AS pick is 北's
          (check (equal (multiple-value-list (yama-as-pick a fa 1)) (list (m :ya-e-as4) nil)))   ; any J count; writes no pointer
          (check (equal (multiple-value-list (yama-as-pick a fa 3)) (list (m :ya-e-as4) nil)))
          (setf (fighter-state fa) :idle (fighter-move fa) nil)
          (check (not (yama-switch-ok a fa)))                              ; refused while armed
          (setf (fighter-sp-ptr fa) 2)
          (in :ya-e-n4 950) (yama-north-start a)                           ; 北 starts: the marks clear, the pointer stays 2, profile 3
          (check (and (= 0 (marks)) (not (north)) (= 2 (fighter-ptr fa)) (= 3 (fighter-sp-ptr fa))))
          (check (not (yama-switch-ok a fa)))                              ; in 北's move: still refused
          (yama-bk-hit a b :hit nil (m :ya-e-n4) nil nil)                  ; its hit: no mark
          (yama-bk-hit a b :hit nil (in :ya-e-as4 960) nil nil)
          (check (= 0 (marks)))
          (check (<= 1 (fighter-ptr fa) 3))                                ; never pointer 4
          (setf (fighter-state fa) :idle (fighter-move fa) nil)
          (check (yama-switch-ok a fa))
          ;; the HUD's tag: NORTH while armed (the seals' names 北 · TENCHI KAIJIN), the marks by number, constant strings
          (check (null (yama-bk-tag a)))
          (yama-mark! a 1) (yama-mark! a 3)
          (check (and (equal (yama-bk-tag a) "MARK 13") (eq (yama-bk-tag a) (yama-bk-tag a))))
          (yama-mark! a 2)
          (check (equal (yama-bk-tag a) "NORTH"))
          (setf (yss-marks (ys a)) 0 (yss-north (ys a)) nil))))
    ;; the Lisp HUD's side: the seals 東 西 南, NORTH's names, the marks next to the pointer; the tag line shows none of them
    (let ((e (lhud-fighter 1)))
      (check (equal (mapcar #'first (lhud-seals e "ZANKA NO TACHI" "MARK 13")) '("東" "西" "南")))
      (check (equal (second (first (lhud-seals e "ZANKA NO TACHI" nil))) "東 · KYOKUJITSUJIN"))
      (check (every (lambda (sl) (equal (second sl) "北 · TENCHI KAIJIN")) (lhud-seals e "ZANKA NO TACHI" "NORTH")))
      (check (equal (mapcar #'first (lhud-seals e "" "HEAT")) '("火" "城" "撫"))))   ; (the Shikai's, unchanged)
    (check (and (equal (lhud-marks "MARK 13") '("東" "南")) (equal (lhud-marks "NORTH") '("東" "西" "南")) (null (lhud-marks "HEAT"))
                (null (lhud-marks nil))))
    (check (and (equal (lhud-tag-segments "YAMAMOTO  ZANKA NO TACHI" "MARK 12") (list (cons "ZANKA NO TACHI" nil)))
                (equal (lhud-tag-segments "YAMAMOTO  ZANKA NO TACHI" "NORTH") (list (cons "ZANKA NO TACHI" nil)))))
    ;; the new hooks and the armour param stay off for every other kit
    (check (loop for c being the hash-keys of *kits* using (hash-value alist)
                 always (loop for (f . kk) in alist
                              always (or (and (eq c :yamamoto) (eq f :bankai))
                                         (and (null (kit-hook kk :ns-pick)) (null (kit-hook kk :switch-ok))
                                              (null (getf (kit-core kk) :ns-extra)) (null (getf (kit-core kk) :as-extra))
                                              (loop for mv being the hash-values of (kit-moves kk) never (getf (mv-params mv) :turn-armor)))))))))

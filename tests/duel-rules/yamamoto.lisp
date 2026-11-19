(in-package :duel)
;;; ================================================================ Yamamoto's Shikai on the core system (docs/duel/DUEL_YAMA_CORE.md §7.1, §7.4;
;;; batch 1 stage A). After hisagi.lisp: its stand-in hazard entities (DO-ENTITIES, SPAWN-ENTITY, HAZARD), POS-OF / YAW-OF and sim.lisp's
;;; stand-in fighters (T-PAIR); his file loaded again now that components / fighter / hazards are (its SETFs of their slots expand).
(load (merge-pathnames "../../duel/lisp/yama.lisp" *load-truename*))
(let* ((k (kit :yamamoto :base)) (core (kit-core k)))
  (flet ((m (n) (kit-move k n)) (cls (n) (kit-class k (kit-move k n)))
         (react (n) (let ((mv (kit-move k n))) (or (getf (mv-params mv) :react) (hw-react (svref (mv-hits mv) 0))))))
    ;; the roster: slot 0 plays again (index fixed), the Bankai not yet: :no-awaken (stage C), no awaken form
    (check (and (= 0 (position :yamamoto *roster*)) (member :yamamoto (playable-roster)) (not (member :yamamoto *retired*))))
    (check (and (getf core :no-awaken) (null (kit-awaken-form k)) (~= 1.0 (getf core :mult))))
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
      (check (and (equal (mv-on-frame mv) '((16 yama-column-fire))) (= 13 (getf (mv-params mv) :delay))
                  (= (+ 16 12) (+ (mv-s mv) (getf (mv-params mv) :delay) -1)) (< (+ 16 12) (+ (mv-s mv) (mv-a mv))))))
    ;; AS1 steals 30 flash-step (§7.4); NADEGIRI's hit on S, its split a look 24 f later; the SA a 360 deg halo, r 2.4
    (check (= 30 (getf (mv-params (m :ya-as1)) :steal-fs)))
    (check (and (= 14 (hw-from (svref (mv-hits (m :ya-n3c)) 0))) (equal (mv-on-frame (m :ya-n3c)) '((14 yama-nade-split)))))
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

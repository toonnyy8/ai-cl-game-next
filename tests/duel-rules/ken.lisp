(in-package :duel)
(setf *core-on* nil)   ; (these checks quote the damage numbers of before the core system's scale, 2026-10-27)
;;; ================================================================ the Kikon counts, the ranged hits (what stayed of the cups' block; the
;;; cups KATATE / RYOTE / NOMIHOSE and their NOME went 2026-11-03, DUEL_KEN_V3 §8)
(flet ((rw (name i) (member :ranged (hw-flags (svref (mv-hits (find-move name)) i)))))
  (check (rw :ke-buttagiru 0)))   ; (the meteor and LEAP CLEAVE went 2026-11-05; Yamamoto's rows with his code, 2026-11-12)
(check (and (= 2 (kit-kikon-konpaku (kit :kenpachi :nozarashi))) (= 2 (kit-kikon-konpaku (kit :kenpachi :base)))))
(check (and (= 2 (nth-value 1 (kikon-result 9 2 nil))) (= 3 (nth-value 1 (kikon-result 9 2 t)))
            (= 3 (nth-value 1 (kikon-result 9 3 nil))) (= 4 (nth-value 1 (kikon-result 9 3 t)))
            (= 4 (nth-value 1 (kikon-result 9 4 nil))) (= 5 (nth-value 1 (kikon-result 9 4 t)))
            (= 4 (nth-value 1 (kikon-result 9 5 nil))) (= 5 (nth-value 1 (kikon-result 9 5 t)))
            (= 5 *soul-break-max-event*) (= 4 *kikon-max-event*)))
(check (loop for (nil . k) in (gethash :kenpachi *kits*) always (eq 'soul-break-cine (kit-kikon-cine k))))   ; (no O rush since 2026-11-05: his

;;; ================================================================ Kenpachi's Bankai and 片腕 (docs/duel/DUEL_KEN_BANKAI.md, the user's decisions 2026-09-28)
(let ((b (kit :kenpachi :bankai)) (b2 (kit :kenpachi :bankai-2)))
  ;; 1. entry: no form's P (V3: the Shikai's J7 + SP, KEN-AS-PICK, the Bankai of his pointer: 狂嵐 :bankai / 斬壞 :bankai-2)
  (check (every (lambda (k) (and (eq (kit-cine k) 'ken-bankai-cine) (kit-awakening k) (eq :kenpachi-oni (kit-body k)) (eq :ke-broken (kit-weapon k))
                                 (eq :oni (kit-aura k)) (member :arm-wreck (kit-hide k)) (~= 1.2 (kit-mult k)) (null (kit-meter k))
                                 (= 4 (kit-kikon-konpaku k))))
                (list b b2)))
  (check (and (equal (kit-form-name b) "KYORAN") (equal (kit-form-name b2) "ZANKAI")))
  ;; rend: armour -> a hit, a stance -> broken; a guard, the ward and a parry still hold
  (check (and (eq (resolve-contact :armor :rend t) :hit) (eq (resolve-contact :stance :rend t) :stance-break)
              (eq (resolve-contact :stance-in :rend t) :stance-break) (eq (resolve-contact :guard :rend t) :blocked)
              (eq (resolve-contact :guard :rend t :ward t :in-front nil) :blocked) (eq (resolve-contact :parry :rend t) :parried)
              (eq (resolve-contact :armor) :armored)))
  (dolist (cf *forms*)
    (let ((k (apply #'kit cf)))
      (let ((br (kit-command-move k :breaker)))        ; (Rukia's rooted zero has none)
        (check (or (null br) (> (+ (mv-reach br) 0.34) *breaker-trigger*))))   ; (with the thinnest hurt radius)
      (let ((o (kit-command-move k :kikon)))          ; (Kenpachi has none since 2026-11-05)
        (check (or (null o) (> (mv-reach o) (+ *kikon-trigger* 0.3))))))))


;; the DANGAI boss (DUEL_ROGUE §5): the base kit's :boss hook (ken-meter.lisp KEN-BOSS); the Bankai keeps the arm's tick
(check (and (eq (kit-hook (kit :kenpachi :base) :boss) 'ken-boss)
            (every (lambda (f) (eq (kit-hook (kit :kenpachi f) :tick) 'ken-bk-tick)) '(:bankai :bankai-2))))   ; (V3: the way back, no arm)

(setf *core-on* t)

;;; ---- V3's sealed form (DUEL_KEN_V3 §6 / §35, 2026-11-05): J1-J5, three pointers by grip, AS n = n segments, one SA a pointer
(let* ((k (kit :kenpachi :base)))
  (labels ((m (n) (gethash n (kit-moves k))) (cls (n) (kit-class k (m n))) (p (n key) (getf (mv-params (m n)) key)))
    (check (every (lambda (n) (eq (cls n) :na)) '(:ke-z-j1 :ke-z-j2 :ke-z-j3 :ke-z-j4 :ke-z-j5)))
    (check (every (lambda (n) (eq (cls n) :ns)) '(:ke-z-n1a :ke-z-n1b :ke-z-n1c :ke-z-n2a :ke-z-n2b :ke-z-n3a :ke-z-n3b :ke-z-n3c)))
    (check (every (lambda (n) (eq (cls n) :as)) '(:ke-z-as1 :ke-z-as2 :ke-z-as2b :ke-z-as3 :ke-z-as3b :ke-z-as3c)))
    (check (every (lambda (n) (eq (cls n) :sa)) '(:ke-z-sa1 :ke-z-sa2 :ke-z-sa3)))
    ;; §35's frames
    (check (equal (mapcar (lambda (n) (mv-s (m n))) '(:ke-z-j1 :ke-z-j2 :ke-z-j3 :ke-z-j4 :ke-z-j5)) '(6 6 7 8 10)))
    (check (equal (mapcar (lambda (n) (mv-dmg (m n))) '(:ke-z-j1 :ke-z-j2 :ke-z-j3 :ke-z-j4 :ke-z-j5)) '(35 35 40 45 55)))
    (check (equal (mapcar (lambda (n) (mv-s (m n))) '(:ke-z-n1a :ke-z-n1b :ke-z-n1c :ke-z-n2a :ke-z-n2b :ke-z-n3a :ke-z-n3b :ke-z-n3c))
                  '(14 10 12 16 14 14 12 14)))
    (check (equal (mapcar (lambda (n) (mv-dmg (m n))) '(:ke-z-n1a :ke-z-n1b :ke-z-n1c :ke-z-n2a :ke-z-n2b :ke-z-n3b :ke-z-n3c :ke-z-as1 :ke-z-as2b :ke-z-as3c))
                  '(65 55 70 85 95 70 95 90 100 140)))
    (check (and (null (kit-open-s k)) (equal (getf (kit-core k) :as-by-press) '(1 1 2 2 3))))                                          ; (as written: the old startup tier is off)
    ;; the tells: every NS opener S >= 14; the stance per pointer; the SA of each pointer's gaps
    (check (every (lambda (n) (>= (mv-s (m n)) 14)) '(:ke-z-n1a :ke-z-n2a :ke-z-n3a)))
    (check (equal (getf (kit-core k) :stances) '(:ke-z-st-1 :ke-z-st-2 :ke-z-st-3)))
    (check (equal (getf (kit-core k) :kikon-cines) '(ken-z-kikon1-cine ken-z-kikon2-cine ken-z-kikon3-cine)))   ; §39: its own three
    (check (and (every (lambda (n) (eq (p n :sa) :ke-z-sa1)) '(:ke-z-n1a :ke-z-n1b :ke-z-n1c))
                (every (lambda (n) (eq (p n :sa) :ke-z-sa2)) '(:ke-z-n2a :ke-z-n2b))
                (every (lambda (n) (eq (p n :sa) :ke-z-sa3)) '(:ke-z-n3a :ke-z-n3b :ke-z-n3c))))
    ;; AS n = n segments, NS routes 3 / 2 / 3; only the last AS segment knocks down / launches, no NS segment does
    (flet ((chain (x) (loop for y = x then (p y :ns-next) while y count t)))
      (check (equal (mapcar #'chain '(:ke-z-as1 :ke-z-as2 :ke-z-as3 :ke-z-n1a :ke-z-n2a :ke-z-n3a)) '(1 2 3 3 2 3))))
    (check (notany (lambda (n) (member (getf (mv-spec (m n)) :on-hit) '(:knockdown :launch)))
                   '(:ke-z-n1a :ke-z-n1b :ke-z-n1c :ke-z-n2a :ke-z-n2b :ke-z-n3b :ke-z-n3c :ke-z-as2 :ke-z-as3 :ke-z-as3b)))
    (check (equal (mapcar (lambda (n) (getf (mv-spec (m n)) :on-hit)) '(:ke-z-as1 :ke-z-as2b :ke-z-as3c)) '(:knockdown :launch :knockdown)))
    (check (member :guard-crush (mv-flags (m :ke-z-as3c))))
    ;; pointer 2: one armour hit on each drop, through the active frames (KEN-ARMOR); not on its AS
    (check (and (= 1 (mv-armor-hits (m :ke-z-n2a))) (= 1 (mv-armor-hits (m :ke-z-n2b))) (p :ke-z-n2a :armor-act) (p :ke-z-n2b :armor-act)
                (= 0 (mv-armor-hits (m :ke-z-as2)))))
    ;; pointer 3: the tame hits nothing, catches a melee hit in f2-28 and answers with the thrust
    (check (and (zerop (mv-a (m :ke-z-n3a))) (member :parry (mv-flags (m :ke-z-n3a))) (equal (p :ke-z-n3a :window) '(2 28))
                (eq (mv-name (kit-next k :ke-z-n3a :land)) :ke-z-n3b)))
    ;; the old base mechanics gone from the sealed form: no cancel count, no charges
    (check (loop for n being the hash-keys of (kit-cls k)
                 never (or (getf (mv-params n) :clash-count) (getf (mv-params n) :charge-mult))))
    ;; the hooks reach every form
    (check (loop for (f . kk) in (gethash :kenpachi *kits*) always (and (eq 'ken-armor (kit-hook kk :armor)) (null (kit-hook kk :clash)))))))
;; the parry catches before the triangle: a hit on a defender in a parry's window is not judged (CORE-VERDICTS)
(check (equal (core-verdict :na :ns) :cancel))

;;; ---- V3's two Bankai (DUEL_KEN_V3 §26, 2026-11-04): one pointer each, J1-J5 of its own, NS a-d, the one AS of n segments after Jn
;;; (n 1-4, the J link's :as-ptr), the special AS after J5; every NS / AS segment burns *KEN-BK-COST* (KEN-BK-COST), the special AS takes
;;; him back to the Shikai (KEN-BK-SPECIAL / KEN-BK-TICK)
(dolist (spec '((:bankai :ke-kr- (14 10 10 8) (80 70 70 40) (7 7 8 8 10) (40 40 45 45 65) 110 300)
                (:bankai-2 :ke-zh- (16 12 14 16) (100 90 100 130) (9 10 10 11 13) (50 55 55 60 85) 150 320)))
  (destructuring-bind (form pre ns-s ns-d j-s j-d fin-d sp-d) spec
    (let ((k (kit :kenpachi form)))
      (labels ((nm (x) (intern (format nil "~a~a" pre x) :keyword)) (m (x) (gethash (nm x) (kit-moves k)))
               (cls (x) (kit-class k (m x))) (p (x key) (getf (mv-params (m x)) key)))
        (check (every (lambda (x) (eq (cls x) :ns)) '("NA" "NB" "NC" "ND")))
        (check (every (lambda (x) (eq (cls x) :as)) '("AS1" "AS2" "AS3" "AS3B" "AS4" "AS4B" "AS4C" "FIN" "SP")))
        (check (eq (cls "SA") :sa))
        (check (and (= 1 (length (getf (kit-core k) :ns))) (= 5 (length (getf (kit-core k) :as))) (equal (getf (kit-core k) :as-writes) '(1 1 1 1 1))))
        ;; Jn + SP = the AS of n segments (n 1-4), J5 + SP the special
        (check (equal (mapcar (lambda (x) (p x :as-ptr)) '("J1" "J2" "J3" "J4" "J5" "SA")) '(1 2 3 4 5 1)))
        (flet ((chain (x) (loop for y = (nm x) then (getf (mv-params (gethash y (kit-moves k))) :ns-next) while y count t)))
          (check (equal (mapcar #'chain '("AS1" "AS2" "AS3" "AS4" "NA" "SP")) '(1 2 3 4 4 1))))
        (check (equal (mapcar (lambda (x) (mv-s (m x))) '("NA" "NB" "NC" "ND")) ns-s))
        (check (equal (mapcar (lambda (x) (mv-s (m x))) '("J1" "J2" "J3" "J4" "J5")) j-s))
        (check (equal (mapcar (lambda (x) (mv-dmg (m x))) '("J1" "J2" "J3" "J4" "J5")) j-d))
        (check (equal (cons (mv-dmg (m "FIN")) (mv-dmg (m "SP"))) (cons fin-d sp-d)))
        (check (equal (loop for x in '("NA" "NB" "NC") collect (mv-dmg (m x))) (subseq ns-d 0 3)))
        (check (>= (mv-s (m "NA")) 14))                                    ; (the opener's tell)
        ;; no NS segment knocks down (an SA may follow any); the finisher and the special do
        (check (notany (lambda (x) (member (getf (mv-spec (m x)) :on-hit) '(:knockdown :launch))) '("NA" "NB" "NC" "ND" "AS2" "AS3" "AS3B" "AS4" "AS4B" "AS4C")))
        (check (every (lambda (x) (eq (getf (mv-spec (m x)) :on-hit) :knockdown)) '("FIN" "AS1" "SP")))
        ;; the cost on every NS / AS segment's frame 0, the way back on the special's
        (check (every (lambda (x) (equal (mv-on-frame (m x)) '((0 ken-bk-cost)))) '("NA" "NB" "NC" "ND" "AS2" "AS3B" "AS4C" "FIN" "AS1")))
        (check (equal (first (mv-on-frame (m "SP"))) '(0 ken-bk-special)))   ; (then its looks, §30)
        (check (eql (getf (mv-params (m "SP")) :dmg-at) (if (eq form :bankai) 40 34)))   ; 千切's damage on the burst (§30)
        (check (notany (lambda (h) (kit-hook k h)) '(:lv :as-pick :hit :link-ok)))))))
(check (= 40 *ken-bk-cost*))

;;; the cadence by form (the user, 2026-11-02, DUEL_KEN_CORE §7.2): the NS openers' startup tier, the hitstop by damage
(check (and (= 4 (hs-by-damage 35 *ken-hs-dmg*)) (= 7 (hs-by-damage 60 *ken-hs-dmg*)) (= 8 (hs-by-damage 70 *ken-hs-dmg*))
            (= 9 (hs-by-damage 80 *ken-hs-dmg*)) (= 10 (hs-by-damage 90 *ken-hs-dmg*)) (= 14 (hs-by-damage 140 *ken-hs-dmg*))
            (= 14 (hs-by-damage 210 *ken-hs-dmg*)) (= 4 (hs-by-damage 0 *ken-hs-dmg*))))
(check (equal (mapcar (lambda (f) (kit-open-s (kit :kenpachi f))) '(:base :nozarashi :bankai :bankai-2)) '(nil nil nil nil)))   ; (V3's forms as written, §9 / §26 / §35)
(check (every (lambda (fm) (destructuring-bind (f s . names) fm
                             (every (lambda (n) (= s (mv-s (mv :kenpachi f n)))) names)))
              '((:base 14 :ke-z-n1a) (:base 16 :ke-z-n2a) (:nozarashi 16 :ke-s-n1a) (:nozarashi 14 :ke-s-n2a) (:bankai 14 :ke-kr-na) (:bankai-2 16 :ke-zh-na))))
;; every Kenpachi hit freezes by its damage; another character keeps the kind's (Ichigo's J1 4)
(check (and (= 14 (hw-hs (aref (mv-hits (mv :kenpachi :nozarashi :ke-s-n2e)) 0))) (= 4 (hw-hs (aref (mv-hits (mv :kenpachi :base :ke-z-j1)) 0)))
            (= 11 (hw-hs (aref (mv-hits (mv :kenpachi :base :ke-z-as2b)) 0)))
            (null (kit-hs-dmg (kit :ichigo :base))) (null (kit-open-s (kit :ichigo :base)))))

;;; ---- the Shikai V3 (DUEL_KEN_V3 §3-§9, 2026-11-03): two pointers by grip, the unlock level L, the bursts, the special string
(let ((k (kit :kenpachi :nozarashi)) (b (kit :kenpachi :bankai)))
  (labels ((m (x) (gethash x (kit-moves k))) (cls (x) (kit-class k (m x))) (p (x key) (getf (mv-params (m x)) key)))
    (check (every (lambda (x) (eq (cls x) :ns)) '(:ke-s-n1a :ke-s-n1b :ke-s-n1c :ke-s-n1d :ke-s-n1e :ke-s-n2a :ke-s-n2b :ke-s-n2c :ke-s-n2d :ke-s-n2e)))
    (check (every (lambda (x) (eq (cls x) :as)) '(:ke-s-as1 :ke-s-as1b :ke-s-as1c :ke-s-as1d :ke-s-as2 :ke-s-as2b :ke-s-as2c :ke-s-as2d
                                                   :ke-s-burst1 :ke-s-burst2 :ke-s-sp1 :ke-s-sp2)))
    (check (eq (cls :ke-s-sa) :sa))
    (check (and (= 2 (length (getf (kit-core k) :ns))) (equal (getf (kit-core k) :as-by-press) '(1 1 2))))
    ;; the level each segment needs (§5.3: P1 L0 the lunge only, P2 L0 the jab and the flick; J4-J7 at L3)
    (check (equal (mapcar (lambda (x) (or (p x :lv) 0)) '(:ke-s-n1a :ke-s-n1b :ke-s-n1c :ke-s-n1d :ke-s-n1e :ke-s-n2a :ke-s-n2b :ke-s-n2c :ke-s-n2d :ke-s-n2e
                                                           :ke-s-as1 :ke-s-as1b :ke-s-as1c :ke-s-as1d :ke-s-as2 :ke-s-as2b :ke-s-as2c :ke-s-as2d
                                                           :ke-s-j3 :ke-s-j4 :ke-s-j5 :ke-s-j6 :ke-s-j7))
                  '(0 1 2 3 3 0 0 1 2 3 0 1 2 3 0 1 2 3 0 3 3 3 3)))
    (check (and (every (lambda (x) (p x :special-as)) '(:ke-s-j4 :ke-s-j5 :ke-s-j6)) (p :ke-s-j7 :bankai-as) (not (p :ke-s-j7 :special-as))))
    (check (every (lambda (x) (p x :lv-up)) '(:ke-s-as1 :ke-s-as1b :ke-s-as1c :ke-s-as1d :ke-s-as2 :ke-s-as2b :ke-s-as2c :ke-s-as2d)))
    (check (notany (lambda (x) (p x :lv-up)) '(:ke-s-burst1 :ke-s-burst2 :ke-s-sp1 :ke-s-sp2)))
    (check (every (lambda (x) (equal (p x :burst) '(100 150 200 260))) '(:ke-s-burst1 :ke-s-burst2)))
    ;; §9's figures: S and damage; the openers carry the tell (>= 14); no NS segment knocks down (the SA may follow any)
    (check (equal (mapcar (lambda (x) (mv-s (m x))) '(:ke-s-j1 :ke-s-j2 :ke-s-j3 :ke-s-j4 :ke-s-j5 :ke-s-j6 :ke-s-j7 :ke-s-sa
                                                       :ke-s-n1a :ke-s-n1b :ke-s-n1c :ke-s-n1d :ke-s-n1e :ke-s-n2a :ke-s-n2b :ke-s-n2c :ke-s-n2d :ke-s-n2e
                                                       :ke-s-burst1 :ke-s-burst2 :ke-s-sp1 :ke-s-sp2))
                  '(9 9 11 9 9 10 12 8 16 12 12 10 14 14 10 16 14 18 14 12 12 20)))
    (check (equal (mapcar (lambda (x) (mv-dmg (m x))) '(:ke-s-j1 :ke-s-j3 :ke-s-j7 :ke-s-n1a :ke-s-n1e :ke-s-n2a :ke-s-n2e :ke-s-as1d :ke-s-as2d :ke-s-sp2))
                  '(40 55 70 70 100 45 140 110 150 260)))
    (check (equal (map 'list #'hw-dmg (mv-hits (m :ke-s-sp1))) '(60 60 120)))
    (check (equal (map 'list #'hw-dmg (mv-hits (m :ke-s-n1d))) '(35 35)))
    (check (notany (lambda (x) (member (getf (mv-spec (m x)) :on-hit) '(:knockdown :launch)))
                   '(:ke-s-n1a :ke-s-n1b :ke-s-n1c :ke-s-n1e :ke-s-n2a :ke-s-n2b :ke-s-n2c :ke-s-n2d :ke-s-n2e)))
    ;; the hooks are the Shikai's only: the Bankai (where J7 + SP lands) neither reads L nor picks ASs nor refuses J links
    (check (and (eq (kit-hook k :lv) 'ken-lv) (eq (kit-hook k :as-pick) 'ken-as-pick) (eq (kit-hook k :hit) 'ken-hit) (eq (kit-hook k :link-ok) 'ken-link-ok)))
    (check (notany (lambda (h) (kit-hook b h)) '(:lv :as-pick :hit :link-ok)))
    (check (and (eq (kit-hook b :tick) 'ken-bk-tick) (null (kit-hook (kit :kenpachi :base) :lv))))
    (check (and (getf (kit-meter k) :lv) (= 3 (getf (kit-meter k) :max)) (= 0 (getf (kit-meter k) :start)) (null (kit-open-s k))))
    ;; the J string: J1-J3, then J4-J7 (the links KEN-LINK-OK gates)
    (check (equal (loop for n = :ke-s-j1 then (mv-name (kit-next k n :q)) while (kit-next k n :q) collect (mv-name (kit-next k n :q)))
                  '(:ke-s-j2 :ke-s-j3 :ke-s-j4 :ke-s-j5 :ke-s-j6 :ke-s-j7)))))

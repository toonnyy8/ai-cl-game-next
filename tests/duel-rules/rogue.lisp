;; ================================================================ DANGAI (docs/duel/DUEL_ROGUE.md, rogue-rules.lisp)
(in-package :duel)
(defparameter *rg-roster* '(:yamamoto :kenpachi :rukia :ichigo :senjumaru :barro :hisagi))
;; the layout: elites at 3 6 9 (and every third step on), the boss at 10 only
(check (equal (loop for st from 1 to 13 collect (rogue-step-kind st))
              '(:normal :normal :elite :normal :normal :elite :normal :normal :elite :boss :normal :elite :normal)))
;; the ramp: a normal step is ENDLESS's; an elite is harder than the normal step it replaces; the boss is HARD from any floor
(check (equal (rogue-ramp 1) (endless-ramp 1)))
(check (> (second (rogue-ramp 3)) (second (endless-ramp 3))))
(check (equal (rogue-ramp 10) *rogue-boss-row*))
(check (every (lambda (fl) (eq :hard (ramp-difficulty fl (rogue-ramp 10)))) '(:easy :normal :hard)))
;; ENDLESS's difficulty unchanged by the split into RAMP-DIFFICULTY
(check (loop for fl in '(:easy :normal :hard)
             always (loop for n from 1 to 15 always (eq (endless-difficulty fl n) (ramp-difficulty fl (endless-ramp n))))))
;; rests: at most 2 a run, normal steps 4-9 only, and some seeds have them
(check (loop for seed from 1 to 200
             always (let ((r (rogue-rest-steps seed)))
                      (and (<= (length r) 2) (every (lambda (st) (and (<= 4 st 9) (eq :normal (rogue-step-kind st)))) r)))))
(check (loop for seed from 1 to 50 thereis (rogue-rest-steps seed)))
;; doors: 1-2, the fights' opponents distinct and never PREV, one door at the boss, a rest only on a rest step, replayable
(check (loop for seed from 1 to 100
             always (loop for st from 2 to 15
                          for prev = (nth (mod (+ seed st) 7) *rg-roster*)
                          for d = (rogue-doors seed st prev *rg-roster*)
                          for fights = (loop for x in d when (eq (getf x :kind) :fight) collect (getf x :opponent))
                          always (and (<= 1 (length d) 2)
                                      (= (length fights) (length (remove-duplicates fights)))
                                      (not (member prev fights))
                                      (or (/= st 10) (= 1 (length d)))
                                      (eq (and (find :rest d :key (lambda (x) (getf x :kind))) t)
                                          (and (member st (rogue-rest-steps seed)) t))
                                      (equal d (rogue-doors seed st prev *rg-roster*))))))
(check (= 1 (length (rogue-doors 1 2 :rukia '(:rukia :ichigo)))))        ; one opponent left after PREV: one door
(check (and (= 9 (getf (rogue-rest '(:konpaku 8 :form :base)) :konpaku))
            (= 6 (getf (rogue-rest '(:konpaku 3 :form :base)) :konpaku))))
;; ---------------------------------------------------------------- batch 2: rewards, traits, slots, offers (§4.1-§4.4)
;; the data: 26 rewards with §4.2's ids and categories, 8 traits whose prerequisites exist and never overfill a category
(defun rg-generic () (remove-if #'rogue-kai-char *rogue-rewards* :key #'first))   ; the 26 generic rewards (解 cards apart)
(check (= 26 (length (rg-generic))))
(check (equal (sort (mapcar #'first (rg-generic)) #'<)
              '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 17 18 19 20 21 22 23 24 25 26 27 28)))
(check (equal (loop for c in '(:zan :mamori :shun :rei :chigiri :kai) collect (count c (rg-generic) :key #'second)) '(6 7 2 6 5 0)))
(check (equal (loop for c in '(:zan :mamori :shun :rei :chigiri :kai) sum (rogue-slots c)) 9))
(check (equal (remove-if-not #'rogue-rare-only-p (mapcar #'first *rogue-rewards*)) '(6 12 28)))
(check (= 8 (length *rogue-traits*)))
(check (every (lambda (tr) (and (every #'rogue-reward (third tr))
                                (every (lambda (c) (<= (count c (third tr) :key #'rogue-reward-cat) (rogue-slots c)))
                                       '(:zan :mamori :shun :rei :chigiri))))
              *rogue-traits*))
(check (equal (remove-if #'rogue-tierable-p (mapcar #'first (rg-generic))) '(6 28 24 25 26)))   ; 斷魂 魄鎧 時契 捨身 賭契
;; the fold: nothing held = NIL (every rule point reads its default); COMMON = §4.4's numbers
(check (null (rogue-mods nil)))
(check (equal (rogue-mods '((1 . 0))) '(:dmg 1.10)))
(check (~= 1.32 (getf (rogue-mods '((1 . 0) (22 . 0))) :dmg)))                 ; 鋭刃 x 血契: multiply
(check (= 7 (getf (rogue-mods '((22 . 0))) :konpaku-cap)))
;; tiers scale only benefits: x's m - 1 and + values x1.5 / x2; costs and counts never
(check (~= 1.15 (getf (rogue-mods '((1 . 1))) :dmg)))
(check (~= 1.20 (getf (rogue-mods '((1 . 2))) :dmg)))
(check (~= 0.55 (getf (rogue-mods '((14 . 1))) :hoho-cost)))
(check (~= 0.20 (getf (rogue-mods '((10 . 2))) :chip-taken)))
(check (~= 4.5 (getf (rogue-mods '((9 . 1))) :armor-on-soul-loss)))
(check (~= 0.40 (getf (rogue-mods '((20 . 2))) :awaken-heal)))
(check (let ((m (rogue-mods '((22 . 2))))) (and (= 7 (getf m :konpaku-cap)) (~= 1.40 (getf m :dmg)))))
(check (let ((m (rogue-mods '((23 . 2))))) (and (~= 0.60 (getf m :gg-max)) (~= 1.30 (getf m :dmg)) (~= 1.60 (getf m :reiatsu-regen)))))
(check (let ((m (rogue-mods '((25 . 2))))) (and (~= 0.80 (getf m :reishi-max)) (= 1 (getf m :kikon-plus) (getf m :sb-plus)))))
(check (= 1 (getf (rogue-mods '((6 . 1))) :kikon-past)))
(check (and (= 1 (getf (rogue-mods '((12 . 1))) :revive)) (= 2 (getf (rogue-mods '((12 . 2))) :revive))))   ; 殘心 LEGEND 2
(check (eq t (getf (rogue-mods '((28 . 1))) :kikon-guard)))
;; 時契 / 賭契: the timer's min, 賭契's 0 over 時契's 3 (they share the one 契 slot, but the fold must still say so)
(check (let ((m (rogue-mods '((24 . 0))))) (and (= 150 (getf m :timer)) (= 3 (getf m :clear-konpaku)))))
(check (let ((m (rogue-mods '((24 . 0) (26 . 0))))) (and (= 0 (getf m :clear-konpaku)) (= 1 (getf m :extra-pick)))))
(check (= 0 (getf (rogue-mods '((26 . 0) (24 . 0))) :clear-konpaku)))
(check (and (= 6 (rogue-clear-konpaku 4 nil)) (= 9 (rogue-clear-konpaku 8 nil)) (= 9 (rogue-clear-konpaku 6 (rogue-mods '((24 . 0)))))
            (= 4 (rogue-clear-konpaku 4 (rogue-mods '((26 . 0))))) (= 7 (rogue-clear-konpaku 6 (rogue-mods '((22 . 0)))))))
(check (= 7 (getf (rogue-rest '(:konpaku 6) 7) :konpaku)))
;; traits: on exactly while every prerequisite is held; their keys stack on the rewards'
(check (null (rogue-traits-on '((4 . 0)))))
(check (equal (rogue-traits-on '((4 . 0) (9 . 0))) '(:a)))
(check (let ((m (rogue-mods '((4 . 0) (9 . 0))))) (and (~= (* 1.25 1.35) (getf m :red-dmg)) (~= 5.0 (getf m :red-armor)))))
(check (equal (rogue-traits-on '((4 . 0) (9 . 0) (27 . 0))) '(:a :h)))            ; 劍八 also completes 死線
(check (let ((m (rogue-mods '((4 . 0) (9 . 0) (27 . 0))))) (and (~= 2.0 (getf m :red-armor)) (getf m :red-no-guard)
                                                                 (~= (* 1.25 1.35 1.40) (getf m :red-dmg)))))
(check (let ((m (rogue-mods '((22 . 0) (6 . 1))))) (and (= 3 (getf m :kikon-past)) (= 6 (getf m :konpaku-cap)))))   ; 修羅
(check (equal (rogue-traits-on '((28 . 1) (12 . 1) (6 . 1))) '(:f)))
(check (let ((m (rogue-mods '((4 . 0) (28 . 1) (22 . 0))))) (and (equal (rogue-traits-on '((4 . 0) (28 . 1) (22 . 0))) '(:g))
                                                                  (getf m :kikon-seal) (getf m :kikon-guard) (~= 0.5 (getf m :both-reishi))
                                                                  (~= (* 1.20 1.30) (getf m :dmg)))))
(check (equal (rogue-traits-on '((5 . 0) (13 . 0) (21 . 0) (2 . 0) (8 . 0) (10 . 0))) '(:b :c :d)))
(check (equal (rogue-mods '((9 . 0) (4 . 0))) (rogue-mods '((4 . 0) (9 . 0)))))   ; the pick order never changes the floats
;; slots and REPLACE: a full category's card is :replace; taking it drops the chosen one (and its trait goes off)
(check (rogue-cat-full-p '((13 . 0)) :shun))
(check (not (rogue-cat-full-p '((1 . 0)) :zan)))
(check (rogue-cat-full-p '((1 . 0) (4 . 0)) :zan))
(check (equal (rogue-take-card '((1 . 0)) '(:id 4 :tier 0 :kind :new)) '((1 . 0) (4 . 0))))
(check (let ((h (rogue-take-card '((4 . 0) (9 . 0) (1 . 0)) '(:id 2 :tier 1 :kind :replace) 4)))
         (and (equal h '((9 . 0) (1 . 0) (2 . 1))) (null (rogue-traits-on h)))))
(check (equal (rogue-take-card '((1 . 0) (9 . 1)) '(:id 9 :tier 2 :kind :upgrade)) '((1 . 0) (9 . 2))))
(check (equal (rogue-upgrade '((1 . 2) (9 . 0)) 9) '((1 . 2) (9 . 1))))
(check (equal (rogue-upgradable '((1 . 2) (9 . 0) (28 . 1) (6 . 1) (12 . 1))) '(9 12)))
;; a card that would complete a trait names it
(check (eq :a (rogue-completes '((4 . 0)) 9)))
(check (null (rogue-completes '((4 . 0)) 1)))
;; offers: 3 distinct cards, replayable, never a held reward except as an UPGRADE (RARE only), RARE+ only rewards only on
;; a RARE offer, a full category's cards :replace, every card's slot rule kept by taking it; random held lists
(defun rg-random-held (x)
  "A legal held list from LCG state X: rewards taken through offers (the first REPLACE target when full)."
  (let ((h nil))
    (dotimes (k (mod x 9) h)
      (let* ((o (rogue-offer x k 0 h (oddp (+ x k)))) (c (nth (mod (+ x k) (max 1 (length o))) o)))
        (when c (setf h (rogue-take-card h c (and (eq (getf c :kind) :replace)
                                                 (car (first (rogue-cat-held h (rogue-reward-cat (getf c :id)))))))))))))
(check (loop for seed from 1 to 300
             always (loop for rare in '(nil t)
                          always (let* ((held (rg-random-held (* seed 31))) (o (rogue-offer seed 4 0 held rare))
                                        (ids (mapcar (lambda (c) (getf c :id)) o)))
                                   (and (= 3 (length o)) (= 3 (length (remove-duplicates ids)))
                                        (equal o (rogue-offer seed 4 0 held rare))
                                        (every (lambda (c)
                                                 (let ((id (getf c :id)) (h (assoc (getf c :id) held)))
                                                   (and (if h
                                                            (and rare (eq (getf c :kind) :upgrade) (= (getf c :tier) (1+ (cdr h))))
                                                            (and (member (getf c :kind) '(:new :replace))
                                                                 (= (getf c :tier) (if rare 1 0))
                                                                 (eq (eq (getf c :kind) :replace) (rogue-cat-full-p held (rogue-reward-cat id)))))
                                                        (or rare (not (rogue-rare-only-p id))))))
                                               o)
                                        (every (lambda (cat) (<= (length (rogue-cat-held held cat)) (rogue-slots cat)))
                                               '(:zan :mamori :shun :rei :chigiri)))))))
(check (loop for seed from 1 to 200 thereis (some (lambda (c) (rogue-rare-only-p (getf c :id))) (rogue-offer seed 3 0 nil t))))
(check (loop for seed from 1 to 200 thereis (some (lambda (c) (eq (getf c :kind) :upgrade)) (rogue-offer seed 3 0 '((1 . 0) (13 . 0) (18 . 0)) t))))
(check (not (equal (rogue-offer 5 4 0 nil nil) (rogue-offer 5 4 1 nil nil))))    ; 賭契's extra pick is a new draw
(check (not (equal (rogue-offer 5 4 0 nil nil) (rogue-offer 5 5 0 nil nil))))
;; door reward types: elites / the boss RARE; normal steps GENERIC mostly, KONPAKU sometimes, RARE rarely; replayable
(check (loop for seed from 1 to 100 always
             (loop for st in '(3 6 9 10 12) always (every (lambda (d) (or (eq (getf d :kind) :rest) (eq :rare (getf d :reward))))
                                                         (rogue-doors seed st :rukia *rg-roster*)))))
(check (and (eq :generic (rogue-step-reward 1)) (eq :rare (rogue-step-reward 3)) (eq :rare (rogue-step-reward 10))))
(check (let ((n (list 0 0 0)))
         (loop for seed from 1 to 300 do
           (loop for st in '(2 4 5 7 8) do
             (dolist (d (rogue-doors seed st :rukia *rg-roster*))
               (when (eq (getf d :kind) :fight) (incf (nth (position (getf d :reward) '(:rare :konpaku :generic)) n))))))
         (and (< (first n) (second n) (third n)) (plusp (first n)))))
;; batch 3: conditions (DUEL_ROGUE §5): 1 a normal step, 2 an elite, none the boss; distinct, known ids, replayable
(check (loop for seed from 1 to 100
             always (loop for st from 1 to 13
                          always (loop for i from 0 to 1
                                       for c = (rogue-door-conds seed st i)
                                       always (and (= (length c) (rogue-cond-count st))
                                                   (= (length c) (length (remove-duplicates c)))
                                                   (every (lambda (id) (assoc id *rogue-conditions*)) c)
                                                   (equal c (rogue-door-conds seed st i)))))))
(check (equal (mapcar #'rogue-cond-count '(1 3 10)) '(1 2 0)))
;; every condition is drawn somewhere, and the two doors of a step can differ
(check (every (lambda (id) (loop for seed from 1 to 100 thereis (member id (rogue-door-conds seed 2 0)))) (mapcar #'first *rogue-conditions*)))
(check (loop for seed from 1 to 50 thereis (not (equal (rogue-door-conds seed 2 0) (rogue-door-conds seed 2 1)))))
;; a fight door carries its conditions
(check (loop for seed from 1 to 30
             always (loop for d in (rogue-doors seed 3 :rukia *rg-roster*)
                          always (or (eq (getf d :kind) :rest) (= 2 (length (getf d :conds)))))))
;; the fold: P1's / the opponent's / the stage's plists; P1's stacks onto the rewards' by multiplying
(multiple-value-bind (p1 foe st) (rogue-cond-mods '(:reiatsu :timer))
  (check (equal p1 '(:reiatsu-regen 2.0)))
  (check (equal foe '(:reiatsu-regen 2.0)))
  (check (equal st '(:timer 180))))
(multiple-value-bind (p1 foe st) (rogue-cond-mods nil) (check (and (null p1) (null foe) (null st))))
(check (equal (rogue-merge-x '(:dmg 1.1 :reiatsu-regen 1.3) '(:reiatsu-regen 2.0)) '(:dmg 1.1 :reiatsu-regen 2.6)))
(check (equal (rogue-merge-x nil '(:reiatsu-regen 2.0)) '(:reiatsu-regen 2.0)))
(check (null (rogue-merge-x nil nil)))
;; batch 4 (skeleton): 解 cards only in their character's run; a held twin makes the other a :twin card, which swaps them
(check (loop for seed from 1 to 200 never (some (lambda (c) (member (rogue-kai-char (getf c :id)) '(:kenpachi :hisagi))) (rogue-offer seed 4 0 nil nil :rukia))))
(check (loop for seed from 1 to 200 never (some (lambda (c) (rogue-kai-char (getf c :id))) (rogue-offer seed 4 0 nil nil))))
(check (loop for seed from 1 to 200 thereis (some (lambda (c) (eq (rogue-kai-char (getf c :id)) :kenpachi)) (rogue-offer seed 4 0 nil nil :kenpachi))))
(check (loop for seed from 1 to 200 never (some (lambda (c) (eq (rogue-kai-char (getf c :id)) :hisagi)) (rogue-offer seed 4 0 nil nil :kenpachi))))
(check (loop for seed from 1 to 300
             always (every (lambda (c) (or (/= (getf c :id) 102) (eq (getf c :kind) :twin))) (rogue-offer seed 4 0 '((101 . 0)) t :kenpachi))))
(check (loop for seed from 1 to 300 thereis (find 104 (rogue-offer seed 4 0 '((103 . 0)) nil :hisagi) :key (lambda (c) (getf c :id)))))
(check (equal (rogue-take-card '((1 . 0) (103 . 0)) '(:id 104 :tier 0 :kind :twin)) '((1 . 0) (104 . 0))))
(check (equal (mapcar #'rogue-twin '(101 102 103 104)) '(102 101 104 103)))
(check (notany #'rogue-tierable-p '(101 102 103 104)))   ; no tiers, never an UPGRADE
(check (let ((m (rogue-mods '((103 . 0))))) (and (= (getf m :hs-tip-dmg) 3.42) (= (getf m :hs-flat-dmg) 0.1) (= 4 (length m)))))
(check (let ((m (rogue-mods '((104 . 1))))) (and (= (getf m :hs-tip-dmg) (getf m :hs-flat-dmg) 1.355) (= (getf m :hs-tip-sp) (getf m :hs-flat-sp) 1.15))))
;; batch 4: the 解 move cards (*ROGUE-KAI-EDITS*): every named move is in some kit of its character, the copies carry the
;; edit, the stock moves and kits never change, forms that shared a move share its copy, nothing held = no copies
(check (loop for (id . eds) in *rogue-kai-edits*
             always (loop for ed in eds
                          always (loop for n in (getf ed :moves)
                                       always (some (lambda (fk) (gethash n (kit-moves (cdr fk)))) (gethash (rogue-kai-char id) *kits*))))))
(check (null (rogue-run-kits :yamamoto nil)))
(check (null (rogue-run-kits :kenpachi '((101 . 0) (102 . 0)))))     ; the twins edit no move
(let* ((stock (gethash :ya-tenchi (kit-moves (find-kit :yamamoto :bankai-east))))
       (rk (rogue-run-kits :yamamoto '((112 . 0) (113 . 0))))
       (k (cdr (assoc :bankai-east rk))) (mv (gethash :ya-tenchi (kit-moves k))))
  (check (and (= (mv-armor-hits mv) 1) (= (mv-armor-hits stock) 0) (not (eq mv stock))))
  (check (= (mv-cooldown (gethash :ya-e-kyokko (kit-moves k))) 40))
  (check (= (mv-cooldown (gethash :ya-e-kyokko (kit-moves (find-kit :yamamoto :bankai-east)))) 100))
  (check (not (eq k (find-kit :yamamoto :bankai-east))))
  (let ((kw (cdr (assoc :bankai-west rk))))                            ; East and West share TENCHI: they share its copy
    (check (or (null (gethash :ya-tenchi (kit-moves kw))) (eq (gethash :ya-tenchi (kit-moves kw)) mv)))))
(let ((rk (rogue-run-kits :hisagi '((127 . 0) (129 . 0)))))
  (check (= 2 (length (mv-hits (gethash :hs-kaza (kit-moves (cdr (assoc :base rk))))))))
  (check (= 1 (length (mv-hits (find-move :hs-kaza)))))
  (check (= 64 (hw-stun (svref (mv-hits (gethash :hs-r-sp1 (kit-moves (cdr (assoc :bankai rk))))) 0))))
  (check (= 40 (hw-stun (svref (mv-hits (find-move :hs-r-sp1)) 0)))))
(let ((rk (rogue-run-kits :barro '((126 . 0)))))
  (check (= 5 (length (mv-hits (gethash :br-w-sanren (kit-moves (cdr (assoc :jilliel-kin rk))))))))
  (check (= 3 (length (mv-hits (find-move :br-w-sanren))))))
(let ((rk (rogue-run-kits :rukia '((118 . 0)))))
  (check (equal (kit-cold (cdr (assoc :m18 rk))) '(:sig 0)))
  (check (equal (kit-cold (find-kit :rukia :m18)) *ru-cold-m18*)))
(check (every #'rogue-kai-note (loop for (id) in *rogue-kai-edits* collect id)))
(check (notany #'rogue-tierable-p (loop for id from 111 to 129 collect id)))
(check (= 2 (getf (rogue-mods '((125 . 0))) :br-armor-wings)))
;; batch 5 (DUEL_ROGUE §6): 靈壓階 effects, unlocks, the rank record's packing
(check (equal (rogue-ramp 4 0) (rogue-ramp 4)))
(check (= (fifth (rogue-ramp 4 1)) (round (* (fifth (rogue-ramp 4)) 11) 10)))
(check (and (= (fifth (rogue-ramp 10 3)) 165) (= (fifth (rogue-ramp 10 4)) 198) (= (fifth *rogue-boss-row*) 150)))
(check (and (= (rogue-cond-count 3 1) 2) (= (rogue-cond-count 3 2) 3) (= (rogue-cond-count 2 5) 1) (= (rogue-cond-count 10 5) 0)))
(check (loop for seed from 1 to 50 always (= 3 (length (remove-duplicates (rogue-door-conds seed 6 0 2))))))
;; an elite's clear +5, the boss's to the cap; 賭契's 0 holds (the user, 2026-10-23)
(check (and (= (rogue-clear-konpaku 2 nil 0 :elite) 7) (= (rogue-clear-konpaku 6 nil 3 :elite) 9) (= (rogue-clear-konpaku 1 nil 0 :boss) 9)
            (= (rogue-clear-konpaku 1 '(:konpaku-cap 6) 0 :boss) 6) (= (rogue-clear-konpaku 3 '(:clear-konpaku 0) 0 :boss) 3)
            (= (rogue-clear-konpaku 3 '(:clear-konpaku 0) 0 :elite) 3) (= (rogue-clear-konpaku 4 nil 0 :normal) 6)))
(check (and (= (rogue-clear-konpaku 5 nil 2) 7) (= (rogue-clear-konpaku 5 nil 3) 6) (= (rogue-clear-konpaku 5 '(:clear-konpaku 3) 3) 8)))
(check (and (= 3 (rogue-offer-size 4)) (= 2 (rogue-offer-size 5))
            (loop for seed from 1 to 30 always (<= (length (rogue-offer seed 4 0 nil nil nil 2)) 2))))
(let ((locked (rogue-locked-ids 0 1)))                 ; nothing open, Kenpachi (index 1)
  (check (and (subsetp '(22 23 24 25 26 6 12 28 101 102 115 116) locked) (not (member 111 locked))))
  (check (loop for seed from 1 to 200 never (intersection locked (mapcar (lambda (c) (getf c :id)) (rogue-offer seed 4 0 nil t :kenpachi 3 locked)))))
  (check (null (rogue-locked-ids *rogue-unlock-all* 1))))
(check (and (= (rogue-unlocks-earned 0 2 1) 0) (= (rogue-unlocks-earned 0 3 1) 1) (= (rogue-unlocks-earned 0 5 1) (logior 1 (ash 1 3)))
            (= (rogue-unlocks-earned 0 10 7) (logior 1 2 (ash 1 9))) (= (rogue-unlocks-earned 3 10 0) (logior 3 4))))
(check (let ((p (rogue-rank-put (rogue-rank-put 0 1 3) 7 6)))
         (and (= (rogue-rank-get p 1) 3) (= (rogue-rank-get p 7) 6) (= (rogue-rank-get p 0) 0)
              (= (rogue-rank-open p 1) 3) (= (rogue-rank-open p 7) 5) (= (rogue-rank-open p 0) 0) (< p (ash 1 29)))))
;; the first lap's CPU (the user, 2026-10-23): normal steps EASY, elites NORMAL from any floor; the boss and on by the ramp
(check (loop for fl in '(:easy :normal :hard)
             always (and (equal (loop for st from 1 to 9 collect (rogue-difficulty st fl (rogue-ramp st)))
                                '(:easy :easy :normal :easy :easy :normal :easy :easy :normal))
                         (eq (rogue-difficulty 10 fl (rogue-ramp 10)) :hard)
                         (eq (rogue-difficulty 12 fl (rogue-ramp 12)) (ramp-difficulty fl (rogue-ramp 12))))))


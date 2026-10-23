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
(check (= 26 (length *rogue-rewards*)))
(check (equal (sort (mapcar #'first *rogue-rewards*) #'<)
              '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 17 18 19 20 21 22 23 24 25 26 27 28)))
(check (equal (loop for c in '(:zan :mamori :shun :rei :chigiri :kai) collect (count c *rogue-rewards* :key #'second)) '(6 7 2 6 5 0)))
(check (equal (loop for c in '(:zan :mamori :shun :rei :chigiri :kai) sum (rogue-slots c)) 9))
(check (equal (remove-if-not #'rogue-rare-only-p (mapcar #'first *rogue-rewards*)) '(6 12 28)))
(check (= 8 (length *rogue-traits*)))
(check (every (lambda (tr) (and (every #'rogue-reward (third tr))
                                (every (lambda (c) (<= (count c (third tr) :key #'rogue-reward-cat) (rogue-slots c)))
                                       '(:zan :mamori :shun :rei :chigiri))))
              *rogue-traits*))
(check (equal (remove-if #'rogue-tierable-p (mapcar #'first *rogue-rewards*)) '(6 28 24 25 26)))   ; 斷魂 魄鎧 時契 捨身 賭契
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

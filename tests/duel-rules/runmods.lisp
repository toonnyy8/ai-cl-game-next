;; ================================================================ DANGAI's run modifier table (run-mods.lisp, DUEL_ROGUE §4.4)
(in-package :duel)
;; RMOD: the default unless a run is active and E is its fighter; RMOD-X / RMOD-PLUS give X itself (EQ) on the default path
(check (let ((*run-mods* nil) (*run-mods-who* 7)) (eql (rmod 7 :dmg 1.0) 1.0)))
(check (let ((*run-mods* '(:dmg 1.2)) (*run-mods-who* 7)) (and (= (rmod 7 :dmg 1.0) 1.2) (= (rmod 9 :dmg 1.0) 1.0)
                                                              (= (rmod 7 :sp-dmg 1.0) 1.0) (null (rmod nil :dmg nil)))))
(check (let ((*run-mods* nil) (x 30.0)) (and (eq (rmod-x 7 :hoho-cost x) x) (eq (rmod-plus 7 :awaken-heal x) x))))
(check (let ((*run-mods* '(:dmg 1.2)) (*run-mods-who* 7) (x 30.0))   ; a holder without the key: X itself too
         (and (eq (rmod-x 7 :hoho-cost x) x) (= (rmod-x 7 :dmg 10.0) 12.0) (= (rmod-plus 7 :dmg 1.0) 2.2)
              (run-mods-on-p 7) (not (run-mods-on-p 9)))))
;; batch 3: the opponent's table (a stage's conditions) for every fighter but *RUN-MODS-WHO*; nothing without a run
(check (let ((*run-mods* nil) (*run-foe-mods* '(:reiatsu-regen 2.0)) (*run-mods-who* 7))
         (and (= (rmod 9 :reiatsu-regen 1.0) 2.0) (= (rmod 7 :reiatsu-regen 1.0) 1.0) (= (rmod-x 9 :reiatsu-regen 3.0) 6.0))))
(check (let ((*run-mods* '(:reiatsu-regen 1.5)) (*run-foe-mods* '(:zone-bias 3)) (*run-mods-who* 7))
         (and (= (rmod 7 :reiatsu-regen 1.0) 1.5) (null (rmod 7 :zone-bias nil)) (= (rmod-plus 9 :zone-bias 1) 4))))
(check (let ((*run-mods* nil) (*run-foe-mods* '(:zone-bias 3)) (*run-mods-who* nil)) (null (rmod 9 :zone-bias nil))))
(check (null (rmod *run-mods-who* :kikon-seal nil)))
;; the multiplier folding: an empty table x1; each key on its own condition; stacked multiplicatively
(check (= 1.0 (run-dmg-mult nil :red t :ender t :sp t :ender-sp t :post-burst t)))
(check (= 1.0 (run-taken-mult nil :breaker t :awake t :perfect t)))
(let ((m '(:dmg 1.1 :red-dmg 1.25 :ender-dmg 1.25 :sp-dmg 1.2 :ender-sp-dmg 1.4 :post-burst-dmg 1.3)))
  (check (~= (run-dmg-mult m) 1.1))
  (check (~= (run-dmg-mult m :red t) (* 1.1 1.25)))
  (check (~= (run-dmg-mult m :red t :ender t :post-burst t) (* 1.1 1.25 1.25 1.3)))
  (check (~= (run-dmg-mult m :sp t) (* 1.1 1.2)))
  (check (~= (run-dmg-mult m :ender-sp t) 1.1))                    ; (the ender window counts only on an SP)
  (check (~= (run-dmg-mult m :sp t :ender-sp t) (* 1.1 1.2 1.4))))
(let ((m '(:chip-taken 0.6 :breaker-taken 0.6 :awake-taken 0.85 :perfect-taken 0.4)))
  (check (~= (run-taken-mult m) 1.0))
  (check (~= (run-taken-mult m :breaker t) 0.6))
  (check (~= (run-taken-mult m :awake t :perfect t) (* 0.85 0.4))))
;; the Konpaku a soul break takes: plus before the cap, past after it (§4.2's worked example), never more than he has
(check (loop for k from 0 to 9 always
             (loop for n from 1 to 5 always
                   (loop for sb in '(nil t) always
                         (equal (multiple-value-list (run-konpaku-result k n sb 0 0)) (multiple-value-list (kikon-result k n sb)))))))
(check (equal (multiple-value-list (run-konpaku-result 9 3 nil 1 1)) '(4 5 nil)))   ; awakened Kikon, 捨身 + 斷魂: 3+1=4 (cap) +1 = 5
(check (equal (multiple-value-list (run-konpaku-result 9 4 nil 1 0)) '(5 4 nil)))   ; plus stops at the cap of 4
(check (equal (multiple-value-list (run-konpaku-result 9 2 nil 0 2)) '(5 4 nil)))   ; 修羅: 2 + 2 past the cap
(check (equal (multiple-value-list (run-konpaku-result 9 4 t 1 1)) '(3 6 nil)))     ; Soul Break: 4+1+1 -> cap 5, +1 past
(check (equal (multiple-value-list (run-konpaku-result 2 3 nil 0 2)) '(0 2 t)))     ; never more than he has
;; :regen: nothing before the delay, then exactly the rate a second
(check (zerop (run-regen-heal *run-regen-delay* 1000 0.01)))
(check (= 10 (loop for u from (1+ *run-regen-delay*) repeat 60 sum (run-regen-heal u 1000 0.01))))
;; debug 84800+k: one test row per rule-point key of §4.4 (from :dmg to :awaken-heal), none twice
(check (= 31 (length *run-mods-tests*)))
(check (= 31 (length (remove-duplicates (mapcar #'first *run-mods-tests*)))))
(check (every (lambda (r) (and (keywordp (first r)) (second r) (null (cddr r)))) *run-mods-tests*))

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

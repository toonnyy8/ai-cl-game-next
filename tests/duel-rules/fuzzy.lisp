;; ================================================================ the CPU's fuzzy reactive layer (duel/lisp/fuzzy.lisp, DUEL_AI_MCTS stage 1)
(in-package :duel)
;; memberships: a trapezoid's shoulders and slopes
(check (= (fz-mu 1 :yes) 1.0))
(check (= (fz-mu 0 :yes) 0.0))
(check (~= (fz-mu 2.0 :near) 0.5))          ; halfway down near's slope (1.6 -> 2.4)
(check (~= (fz-mu 2.0 :mid) 0.5))
;; inference: the outputs averaged by strength; no rule firing gives the default
(check (~= (fz-infer '((((:d :near)) 1.0) (((:d :mid)) 0.0)) '(:d 2.0)) 0.5))
(check (= (fz-infer '((((:d :far)) 1.0)) '(:d 0.5) 0.25) 0.25))
;; difficulty: a skill scales down, a choice leans toward 1/2
(check (~= (fz-scale 0.8 :hard :skill) 0.8))
(check (~= (fz-scale 0.8 :easy :skill) 0.24))
(check (~= (fz-scale 0.1 :easy :choice) 0.38))
;; the rule bases read as intended: the read against an NS, no turn without a cue, red Kikons, no cancel while red
(check (> (fz-chance *fz-as-now* '(:ons 1 :press 0.2) :hard :choice) 0.9))
(check (< (fz-chance *fz-as-now* '(:ons 0 :press 0.2) :hard :choice) 0.3))
(check (zerop (fz-chance *fz-ns-turn* '(:ona 0 :ownsa 0 :d 1.0) :hard :skill)))
(check (> (fz-chance *fz-ns-turn* '(:ona 1 :ownsa 0 :d 1.0) :hard :skill) 0.8))
(check (> (fz-chance *fz-kikon* '(:ored 1) :normal :skill) (fz-chance *fz-kikon* '(:ored 0) :normal :skill)))
(check (zerop (fz-chance *fz-cancel* '(:red 1) :hard :skill)))
(check (< (fz-chance *fz-hoho* '(:margin -0.5 :frames 4) :easy :skill) (fz-chance *fz-hoho* '(:margin -0.5 :frames 4) :hard :skill)))
;; the rank step: a :MUST rule holding answers alone; below half way it is averaged as usual
(check (= (fz-infer '((((:d :near)) 0.9 :must) (((:d :near)) 0.1)) '(:d 0.5)) 0.9))
(check (~= (fz-infer '((((:d :near)) 0.9 :must) (((:d :mid)) 0.1)) '(:d 2.2)) (/ (+ (* 0.25 0.9) (* 0.75 0.1)) 1.0)))

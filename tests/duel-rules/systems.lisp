(in-package :duel)
;;; ---------------------------------------------------------------- the guard lock (the user 2026-09-30, DUEL_DESIGN.md "Guard lock")
;; the lock holds a blockstun past its end while the attacker's move may still chain; it ends when that can't happen
(check (guard-locked-p :guard-hit nil 0 :move :main 20 10 3 12 t t))                ; frame 20 of 25: a chain may still start
(check (not (guard-locked-p :guard-hit nil 0 :move :main 24 10 3 12 t t)))          ; frame 24: the last chance was 24
(check (not (guard-locked-p :guard-hit nil 0 :move :main 20 10 3 12 t nil)))        ; nothing left to chain (a link 3)
(check (not (guard-locked-p :guard-hit nil 0 :move :main 20 10 3 12 nil t)))        ; his move never touched him
(check (not (guard-locked-p :guard-hit t 0 :idle nil 0 0 0 0 nil nil)))             ; a new neutral action ends it
(check (not (guard-locked-p :guard-hit t 0 :step nil 0 0 0 0 nil nil)))
;; a follow-up he started carries it through its startup and active frames, then its own window decides
(check (and (guard-locked-p :guard-hit t 0 :move :main 3 10 3 12 t nil) (guard-locked-p :guard-hit t 0 :move :hold 0 10 3 12 t nil)
            (guard-locked-p :guard-hit t 0 :move :main 12 10 3 12 t nil) (not (guard-locked-p :guard-hit t 0 :move :main 13 10 3 12 t nil))))
(check (and (guard-locked-p :guard-hit t 5 :idle nil 0 0 0 0 nil nil)                ; ORANGE's window: the next move is the chain
            (not (guard-locked-p :guard-hit t 5 :step nil 0 0 0 0 nil nil))))
;; the escapes: BLUE (and the awakening) leave blockstun, the lock with it; BLUE is still a blockstun press
(check (and (eq (burst-mode :guard-hit nil 0 nil) :blue) (not (guard-locked-p :idle t 5 :move :main 20 10 3 12 t t))))
(defun locked-free-steps (mv more)
  "FREE-STEPS with the guard lock (fighter.lisp STUN-STEP / FIGHTER-SYSTEM): MV blocked on its first hit, MORE = it may
chain. The lock is judged after each step (from the hit's next one: the hit lands after the fighters stepped) for the
defender's next step. Values: the attacker's and the defender's first actionable step."
  (let* ((enter (mv-enter mv)) (h (- (mv-first-hit mv) enter))
         (end (move-end-frame (mv-s mv) (mv-a mv) (mv-r mv) (mv-whiff mv) :block nil))
         (stun (blockstun (mv-total mv) (mv-first-hit mv) (mv-adv-block mv))) (lock nil))
    (values (loop for step from 1 when (>= (+ enter step) end) return (1+ step))
            (loop for step from (1+ h) for sf from 1
                  when (and (>= sf stun) (not lock)) return (1+ step)
                  do (let ((fr (+ enter step)))
                       (setf lock (guard-locked-p :guard-hit lock 0 (if (>= fr end) :idle :move) :main fr
                                                  (mv-s mv) (mv-a mv) (mv-r mv) t more)))))))
;; every blocked string link that goes on holds the defender to even (the attacker's move ends as he is freed); a link
;; that can't (link 3, no L link ready) keeps its block advantage: an ender is still punishable (Lille II's stance EN, its
;; hitscan strings: their own block below)
(dolist (cf (remove-if (lambda (cf) (and (eq (first cf) :barro) (trace-form-p cf))) *forms*))
  (let ((k (apply #'kit cf)))
    (dolist (row (link-moves k))
      (let ((m (first row)))
        (when (and (integerp (mv-adv-block m)) (plusp (length (mv-hits m))))
          (multiple-value-bind (att def) (locked-free-steps m (string-link-p k (mv-name m)))
            (check (or (= (- def att) (if (string-link-p k (mv-name m)) (max 0 (mv-adv-block m)) (mv-adv-block m)))
                       (format t "~a ~a: lock ~d, adv ~d~%" cf (mv-name m) (- def att) (mv-adv-block m))))))))))
(let* ((k (kit :yamamoto :base)) (j1 (kit-command-move k :q)) (j3 (kit-next k (mv-name (kit-next k (mv-name j1) :q)) :q)))
  (check (and (string-link-p k (mv-name j1)) (not (string-link-p k (mv-name j3))) (< (mv-adv-block j3) -2)
              (= (mv-adv-block j3) (multiple-value-bind (a d) (locked-free-steps j3 nil) (- d a))))))

;;; ================================================================ :x-axis lines: the CPU's threat perception (DUEL_LILLE §11.3,
;;; gap G1 / G8; ai.lisp SNAP-LIVE-P / SNAP-NEAR-P, AI-OPP-AIM, AI-OPP-REFLECT; the moves here are fakes, no kit has the flag yet)
(check (~= (line-dist 0.0 0.0 0.0 0.6 31.0 0.5 -10.0) 0.5))      ; yaw 0 faces -Z: 0.5 m beside the line
(check (~= (line-dist 0.0 0.0 0.0 0.6 31.0 0.0 2.0) 2.6))        ; behind him: from the muzzle (0.6 m ahead)
(check (~= (line-dist 0.0 0.0 0.0 0.6 31.0 0.0 -40.0) 9.0))      ; past the line's end
(check (~= (line-dist 1.0 1.0 (deg 90.0) 0.0 10.0 -4.0 1.0) 0.0)) ; yaw 90: faces -X
(let* ((shot (parse-move :x-fake '(:kind :sig :hold (34 64) :startup 4 :active 2 :recovery 26 :dmg 40
                                   :vol (:cap 0.6 31.0 1.2 0.25) :flags (:ranged :x-axis) :params (:lock 34))))
       (beam (parse-move :x-fake-beam '(:kind :sp :startup 60 :active 30 :recovery 40 :dmg 240
                                        :vol (:cap 0.6 31.0 1.4 1.2) :flags (:ranged :x-axis :reflectable)
                                        :params (:lock 40 :blast 60))))
       (sanren (parse-move :x-fake-3 '(:kind :sp :startup 12 :active 2 :recovery 24 :dmg 30 :vol (:cap 0.6 20.0 1.2 0.25)
                                       :hits ((12 14) (22 24) (32 34)) :flags (:ranged :x-axis))))
       (on (+ 0.4 *ai-line-margin*)))                            ; a 0.4 m hurt radius + the margin
  (check (= (move-lock shot) 34))
  (check (= (move-lock beam) 40))
  (check (null (move-lock sanren)))
  (check (= (move-active-end shot) 6))
  (check (= (move-active-end sanren) 34))                        ; every line of it, not S + A
  ;; on the line at 20 m (the generic reach test, 31 + 1.5, is true everywhere); 3 m beside it at 20 m: not
  (check (<= (x-line-gap shot 0.0 0.0 0.0 0.0 -20.0) on))
  (check (> (x-line-gap shot 0.0 0.0 0.0 3.0 -20.0) on))
  (check (~= (x-line-gap shot 0.0 0.0 0.0 0.5 -10.0) 0.25))      ; the line's own radius taken off
  (check (> (x-line-gap shot 0.0 0.0 0.0 0.0 1.5) on))           ; right behind him
  (check (<= (x-line-gap beam 0.0 0.0 0.0 1.6 -25.0) on))        ; the 1.2 m beam is wider
  ;; the aim: no threat before the lock (no guard through the aim), a threat from it; the shot until its window ends
  (check (not (x-live-p shot :hold 10 0)))
  (check (not (x-live-p shot :hold 33 0)))
  (check (x-live-p shot :hold 34 0))
  (check (x-live-p shot :hold 64 0))
  (check (x-live-p shot :main 40 5))
  (check (not (x-live-p shot :main 40 6)))
  ;; a wind-up with a :lock: from the lock to the window's end
  (check (not (x-live-p beam :main 0 39)))
  (check (x-live-p beam :main 0 40))
  (check (x-live-p beam :main 0 89))
  (check (not (x-live-p beam :main 0 90)))
  (check (x-live-p sanren :main 0 0))                            ; no lock: from frame 0, through its 3rd line
  (check (x-live-p sanren :main 0 33))
  (check (not (x-live-p sanren :main 0 34)))
  (check (not (x-live-p shot :aura 0 0))))
;; the Step off the line goes away from it, to the side he is on (the CPU's stick: TOWARD-STRAFE-DIR)
(loop for (ax az yaw px pz) in '((0.0 0.0 0.0 0.3 -10.0) (0.0 0.0 0.0 -0.3 -10.0) (2.0 1.0 0.7 -3.0 -4.5) (2.0 1.0 0.7 -2.0 -6.5)
                                 (-5.0 3.0 -2.5 0.5 -1.0) (-5.0 3.0 -2.5 -1.0 0.0))
      do (let* ((st (line-off-strafe ax az yaw px pz ax az))
                (fx (fwd-x (float yaw 1f0))) (fz (fwd-z (float yaw 1f0)))
                (al (+ (* (- px ax) fx) (* (- pz az) fz))) (lx (- px ax (* al fx))) (lz (- pz az (* al fz))))
           (multiple-value-bind (dx dz) (toward-strafe-dir 0.0 st px pz ax az)
             (check (plusp (+ (* dx lx) (* dz lz)))))))
;; chances read off the opponent's kit, by difficulty (EASY <= NORMAL <= HARD; :opp-reflect 0.3 -> 0.1 / 0.3 / 0.5)
(check (~= (opp-chance 0.3 :easy) 0.1))
(check (~= (opp-chance 0.3 :normal) 0.3))
(check (~= (opp-chance 0.3 :hard) 0.5))
(check (= (opp-chance 0.6 :hard) 1.0))
(check (<= (opp-chance 0.25 :easy) (opp-chance 0.25 :normal) (opp-chance 0.25 :hard)))
;; the reflect's timing (a blast at f60): a guard pressed at f52 is 8 f old there (2-10: DUEL_LILLE §6.3), a Hoho at f50
;; (f48-f60); hands off just before; nothing after the blast
(check (null (reflect-action 45 60 t)))
(check (eq (reflect-action 46 60 t) :wait))
(check (eq (reflect-action 51 60 t) :wait))
(check (eq (reflect-action 52 60 t) :guard))
(check (<= 2 (- 60 (- 60 *ai-reflect-guard-lead*)) 10))
(check (eq (reflect-action 60 60 t) :guard))
(check (eq (reflect-action 61 60 t) :late))
(check (null (reflect-action 43 60 nil)))
(check (eq (reflect-action 44 60 nil) :wait))
(check (eq (reflect-action 50 60 nil) :hoho))
(check (<= 48 (- 60 *ai-reflect-hoho-lead*) 60))
(check (<= (- 60 *ai-reflect-hoho-lead*) (+ 60 0) (+ (- 60 *ai-reflect-hoho-lead*) *perfect-lead*)))   ; (it is perfect)
;; inert for the first five characters: no move has :x-axis / :reflectable, no form the keys :opp-aim / :opp-reflect /
;; :bankai-ok (Lille's forms have them: DUEL_LILLE §8, §11.3)
(dolist (cf (remove-if (lambda (c) (member c '(:lille :barro))) *forms* :key #'first))
  (let ((k (apply #'kit cf)))
    (check (null (kit-bankai-ok k)))
    (check (not (or (getf (kit-ai k) :opp-aim) (getf (kit-ai k) :opp-reflect))))
    (loop for m being the hash-values of (kit-moves k)
          do (check (not (intersection '(:x-axis :reflectable) (mv-flags m)))))))


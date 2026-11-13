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

;;; ================================================================ a move's real active window (kit.lisp MOVE-ACTIVE-END: the
;;; light model's; the :x-axis lines it served, and the CPU's line / reflect readers, left with the old AI, 2026-11-12)
(let ((shot (parse-move :x-fake '(:kind :sig :startup 4 :active 2 :recovery 26 :dmg 40 :vol (:cap 0.6 31.0 1.2 0.25) :flags (:ranged))))
      (sanren (parse-move :x-fake-3 '(:kind :sp :startup 12 :active 2 :recovery 24 :dmg 30 :vol (:cap 0.6 20.0 1.2 0.25)
                                      :hits ((12 14) (22 24) (32 34)) :flags (:ranged)))))
  (check (= (move-active-end shot) 6))
  (check (= (move-active-end sanren) 34)))                       ; every window of it, not S + A
;; inert for the first five characters: no move has :x-axis / :reflectable (Lille's had them: DUEL_LILLE §8, §11.3)
(dolist (cf (remove-if (lambda (c) (member c '(:lille :barro))) *forms* :key #'first))
  (let ((k (apply #'kit cf)))
    (loop for m being the hash-values of (kit-moves k)
          do (check (not (intersection '(:x-axis :reflectable) (mv-flags m)))))))


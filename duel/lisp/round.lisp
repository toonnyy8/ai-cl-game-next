;;;; round.lisp — the round's end (split from combat.lisp, 2026-11-14, REFACTOR_2026-11 R15b): the souls the step's hits broke
;;;; (handed over as values by combat.lisp TAKE-BROKEN-SOULS) settled together at connect time (SETTLE-KONPAKU, SETTLE-SOULS; cinema.lisp only
;;;; presents them), then the reset (RESET-ROUND) or the finish (flow.lisp MATCH-OVER).
(in-package :duel)

;;; ---------------------------------------------------------------- Kikon, Soul Break, reset
(defun kikon-worth (e)
  "Konpaku E's Kikon would take now: a running rush's worth (fixed at its start), else the kit's :kikon-worth hook (E) (a
worth that follows the fighter's state), else the kit's :kikon-konpaku. (An older kit's red Konpaku hint: webhud.lisp AT-STAKE, a core kit's reads CORE-KIKON-STAKE; a Soul Break takes this + 1: SETTLE-KONPAKU.)"
  (let* ((f (fighter e)) (mv (fighter-move f)) (h (kit-hook (kit-of e) :kikon-worth)))
    (cond ((and mv (eq (fighter-state f) :move) (eq (mv-kind mv) :kikon)) (fighter-kikon-n f))
          (h (funcall h e))
          (t (kit-kikon-konpaku (kit-of e))))))

(defun kikon-ready-p (e)
  "Is E's opponent red: would E's Kikon rush, connecting now with the button held, be the Kikon?
(The HUD's HOLD O prompt, the CPU's rush.)"
  (let ((go (gauges (opp-of e)))) (gauges-red-p go)))

(defun settle-konpaku (att def soul-break)
  "Konpaku at connect time (KIKON-RESULT): DEF loses the Kikon's count (ATT's rush's, read when it started:
FIGHTER-KIKON-N), or on a Soul Break ATT's KIKON-WORTH now + 1 (at most *SOUL-BREAK-MAX-EVENT*: KESSA's follows his
clones, 3 clones 4 + 1 = 5, the user 2026-09-30); his Reishi refills.
Then DEF's kit's :settled hook (def lost left): what his form does with the souls he has left (a beheading).
Returns T when DEF is out of Konpaku; never in a bind (BIND-OF: grey souls, the Konpaku floors at 0, no K.O.)."
  (let ((gd (gauges def)) (bound (bind-of def)))
    (multiple-value-bind (left lost ko)
        (let ((n (if soul-break (kikon-worth att) (fighter-kikon-n (fighter att)))))
          (cond ((kit-core (kit-of att))                ; the core system's counts (core.lisp): the style of the SP in play
                 (core-konpaku-result (gauges-konpaku gd) att soul-break))
                (t (kikon-result (gauges-konpaku gd) n soul-break))))
      (setf (gauges-konpaku gd) left (gauges-reishi gd) (gauges-reishi-max gd))
      (let ((h (kit-hook (kit-of def) :settled))) (when h (funcall h def lost left)))
      (unless (siphon-of def)
        (awaken-fill! gd (awakening-gain 0 0 lost)))
      (unless (siphon-of att)   ; the Konpaku he took fills the attacker's SUBLIMATION / DRIVE (DUEL_SUBLIMATION §18)
        (awaken-fill! (gauges att) 0.0 (sub-attack-gain 0 lost 1.0)))
      (incf (gauges-kikons (gauges att)))
      (emit :konpaku def lost)
      (clog "~a ~a on ~a: -~d konpaku, ~d left (~a)" (side-name att) (if soul-break "SOUL BREAK" "KIKON") (side-name def) lost left
            (fighter-form (fighter att)))
      (and ko (not bound)))))

(defun settle-souls (kk sb)
  "The souls broken during this step, settled together so no side goes first: KK every confirmed Kikon ((attacker victim
move), the Kikon count) and SB every Reishi that reached 0 ((attacker . victim), the count + 1; a Kikon's victim has no Soul
Break on top, the Kikon refills his Reishi), both in the order queued (combat.lisp TAKE-BROKEN-SOULS). Then one
cinematic (the first Kikon's move :cine, else the first Soul Break's attacker's Kikon cinematic: KIT-KIKON-CINE),
then the reset, or the finish (a draw when both souls ran out). The hazards still out are cleared first: the reset clears them anyway,
and frozen through the cinematic their looks would hang in its shots."
  (when (or kk sb)
    (do-entities (e (f fighter)) (burst-end! e))   ; the reset ends every burst, before the Kikon's refund
    (dolist (att (remove-duplicates (append (mapcar #'first kk) (mapcar #'car sb))))   ; a Kikon that connected, or
      (pay-gauges att *kikon-fs-refund*))              ; a Soul Break (the user 2026-09-30): a flash-step bar back (Q18: a gain)
    (let ((kos (append (loop for (att def nil) in kk when (settle-konpaku att def nil) collect def)
                       (loop for (att . def) in sb when (settle-konpaku att def t) collect def)))
          (a (if kk (first (first kk)) (car (first sb))))
          (v (if kk (second (first kk)) (cdr (first sb)))))
      (loop for (att def mv) in kk
            do (when (mv-callout mv) (callout att (mv-callout mv)))
               (emit :kikon att def))
      (loop for (att . def) in sb do (emit :soul-break att def))
      (clear-hazards)
      (cine-stage a v)                                ; (both set down mid-stage for its shots, given back at its end)
      (start-cine (if kk (or (mv-cine (third (first kk))) (core-kikon-cine a) (kit-kikon-cine (kit-of a))) (core-soul-break-cine a)) a v
                  :after (lambda () (cond ((null kos) (reset-round a v))
                                          ((rest kos) (match-over nil))
                                          (t (match-over (opp-of (first kos))))))))))

(defun reset-round (a v)
  "After a Kikon / Soul Break (§1): both placed *RESET-DISTANCE* apart facing, *RESET-NEUTRAL* frames
of neutral, P1 on the left of the view again, hazards cleared, the guard gauges full (and guardless cleared) for
everyone, the hidden stun cleared, the forms kept, flash-step kept, the kit's :reset hook (e) (Hisagi's sickle)."
  (let ((p (pos-of a)) (q (pos-of v)))
    (multiple-value-bind (ax az bx bz) (reset-placement (aref p 0) (aref p 2) (aref q 0) (aref q 2))
      (v3-set! p (f32 ax) 0f0 (f32 az)) (v3-set! q (f32 bx) 0f0 (f32 bz))))
  (face-each-other a v)
  (if (zerop (fighter-side (fighter a))) (view-step a v t) (view-step v a t))
  (clear-hazards)
  (dolist (e (list a v))
    (let ((f (fighter e)) (g (gauges e)) (mo (motion e)))
      (setf (motion-grounded mo) t (motion-kb-left mo) 0 (fighter-lock f) *reset-neutral* (fighter-combo-dmg f) 0
            (fighter-xch f) -1 (fighter-xch-done f) nil)   ; (the reset ends an exchange: DUEL_SP Q11)
      (setf (gauges-gg g) (f32 *gg-max*) (gauges-gg-idle g) 0 (gauges-guardless g) nil (gauges-stun g) 0f0)
      (let ((rf (kit-reset-form (kit-of e))))          ; Rukia: absolute zero never carries over the reset (-18, C 0)
        (when rf (set-form e rf) (setf (gauges-meter g) 0f0 (gauges-meter-idle g) 0)))
      (fill (motion-vel mo) 0f0)
      (vpad-clear! (pilot-vpad (pilot e)))
      (let ((b (brain e))) (when b (setf (brain-press-left b) 0)))   ; a CPU lets go of what it held (a rush's O)
      (let ((h (kit-hook (kit-of e) :reset))) (when h (funcall h e)))   ; the form's own reset (Hisagi's sickle back in hand)
      (to-idle e 0)))
  (emit :reset))

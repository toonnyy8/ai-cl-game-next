;;;; cpu-ih-hisagi-ihr1b2a1.lisp — dream-rsi IH round 1, Hisagi's cell b2_a1 (docs/research/strategy-drsi/sp, ih-H): a strategy arm's style
;;;; (:fn hisagi-ihr1b2a1-style), b2_a0's HISAGI-IHR1B2A0-STYLE (attack into Ichigo's shut Hoho) with a CHASE BUDGET: inside one shut-Hoho
;;;; window the walk-in runs at most :ihy-chase-steps free steps; past it the window only presses what already reaches her, and every other
;;;; step goes to HISAGI-RANGE-STYLE / the MCTS (b2_a0 walked for the whole window, so a kiting Ichigo dragged him to the bell: rest time-outs
;;;; 5 -> 22). The shut test, the reach test and the :ihx-* keys are b2_a0's (IHX-SHUT-P, IHX-FITS-P, its defaults).
(in-package :duel)

(defparameter *ihy-chase-steps* 40 "Free steps a shut-Hoho window may spend walking in (then the range style / MCTS play it).")

(defstruct (ihy (:constructor make-ihy ()))
  "HISAGI-IHR1B2A1-STYLE's state: HISAGI-RANGE-STYLE's HRS, the window's roll and its walk budget."
  (range nil)                   ; HISAGI-RANGE-STYLE's state
  (open nil)                    ; inside a shut-Hoho window
  (go nil)                      ; its roll said yes
  (walk 0 :type fixnum)         ; free steps walked in this window
  (tick 0 :type fixnum))        ; *MATCH-TICK* at the last call (a lower one: a new match)
(inline-readers ihy)

(defun ihy-step (e b f kit s d st)
  "Free, her Hoho shut: J1 / the pointer's NS in reach, else walk in while the window's budget lasts. T when it pressed or walked."
  (if (not (and (member (fighter-state f) '(:idle :run)) (ihx-shut-p b (fighter-opp f))
                (or (member (snap-state s) '(:idle :run :guard)) (snap-punishable-p s))))
      (progn (setf (ihy-open st) nil) nil)
      (progn
        (unless (ihy-open st) (setf (ihy-open st) t (ihy-walk st) 0 (ihy-go st) (style-roll b :ihx-p *ihx-p*)))
        (when (ihy-go st)
          (let* ((m (style-knob b :ihx-margin *ihx-margin*)) (q (kit-command-move kit :q e)) (ns (kit-core-move kit :ns (mc-ptr f))))
            (cond ((ihx-fits-p e q d m)
                   (setf (brain-own-key b) -1) (cai-press b :quick 1) (hr-taken b f) t)
                  ((ihx-fits-p e ns d m)
                   (hr-sp b f s) (hr-taken b f) t)
                  ((let ((hi (max 1.0 (- (strat-reach (or q ns)) m))))
                     (and (< (ihy-walk st) (style-knob b :ihy-chase-steps *ihy-chase-steps*))
                          (< hi d (style-knob b :ihx-chase *ihx-chase*))
                          (ai-walk e b (pilot-vpad (pilot e)) d 0.0 hi)
                          (incf (ihy-walk st))
                          t)))))))))

(defun hisagi-ihr1b2a1-style (e b f kit s d)
  "Attack into Ichigo's shut Hoho with a walk budget (IHY-STEP), else HISAGI-RANGE-STYLE. T when it decided."
  (let ((st (brain-style b)))
    (when (or (not (ihy-p st)) (< *match-tick* (ihy-tick st))) (setf st (make-ihy) (brain-style b) st))
    (setf (ihy-tick st) *match-tick*)
    (or (ihy-step e b f kit s d st)
        (progn (setf (brain-style b) (ihy-range st))
               (prog1 (hisagi-range-style e b f kit s d)
                 (setf (ihy-range st) (brain-style b) (brain-style b) st))))))

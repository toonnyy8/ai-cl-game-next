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
  (hold 0 :type fixnum)         ; steps since this stay in her lunge band began (IHY-HOLD)
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

;;; The lunge band: Ichigo's style at pointer 3 (IKS-GAP) counts his Hoho shut under :iks-gap-fs (the mix arm: 150, above the regen's
;;; 100 cap, so nearly always), backs off to ~5.5 m and lunges NS3a once he is seen WALKING IN at ~5.1-5.25 m (IKS-CLOSING). So while she
;;; is at pointer 3, free, inside [:ihy-hold-lo, :ihy-hold-hi] and no move of his reaches her, he waits (:wait) instead of walking in.
(defparameter *ihy-hold-p* 0.0 "Per free step in her pointer-3 lunge band: wait rather than walk in (0: off, b2_a0's play).")
(defparameter *ihy-hold-lo* 4.4 "The lunge band's near edge (m, perceived).")
(defparameter *ihy-hold-hi* 7.0 "The lunge band's far edge (m, perceived).")
(defparameter *ihy-hold-max* 0 "Steps one stay in the band may wait (her IKS-GAP episode lasts *IKS-GAP-MAX* 150); 0: no limit.")

(defun ihy-hold (e b f kit s d st)
  "Her pointer 3, D in the lunge band (the stay's clock in ST under :ihy-hold-max), both free, neither J1 nor his NS reaching her: wait.
T when it waited."
  (let ((p (style-knob b :ihy-hold-p *ihy-hold-p*)) (mx (style-knob b :ihy-hold-max *ihy-hold-max*)))
    (if (and (= (fighter-ptr (fighter (fighter-opp f))) 3)
             (<= (style-knob b :ihy-hold-lo *ihy-hold-lo*) d (style-knob b :ihy-hold-hi *ihy-hold-hi*)))
        (incf (ihy-hold st))
        (setf (ihy-hold st) 0))
    (when (and (plusp p) (member (fighter-state f) '(:idle :run)) (member (snap-state s) '(:idle :run))
               (plusp (ihy-hold st)) (or (<= mx 0) (<= (ihy-hold st) mx))
               (let ((m (style-knob b :ihx-margin *ihx-margin*)))
                 (not (or (ihx-fits-p e (kit-command-move kit :q e) d m) (ihx-fits-p e (kit-core-move kit :ns (mc-ptr f)) d m))))
               (or (>= p 1.0) (style-roll b :ihy-hold-p *ihy-hold-p*)))
      (mc-press b :wait)
      t)))

(defun hisagi-ihr1b2a1-style (e b f kit s d)
  "Wait in her pointer-3 lunge band (IHY-HOLD), attack into Ichigo's shut Hoho with a walk budget (IHY-STEP), else HISAGI-RANGE-STYLE.
T when it decided."
  (let ((st (brain-style b)))
    (when (or (not (ihy-p st)) (< *match-tick* (ihy-tick st))) (setf st (make-ihy) (brain-style b) st))
    (setf (ihy-tick st) *match-tick*)
    (or (ihy-hold e b f kit s d st)
        (ihy-step e b f kit s d st)
        (progn (setf (brain-style b) (ihy-range st))
               (prog1 (hisagi-range-style e b f kit s d)
                 (setf (ihy-range st) (brain-style b) (brain-style b) st))))))

;;;; cpu-ih-hisagi-ihr1b2a0.lisp — dream-rsi IH round 1, Hisagi's cell b2_a0 (docs/research/strategy-drsi/sp, ih-H): a strategy arm's style
;;;; (:fn hisagi-ihr1b2a0-style) built on HISAGI-RANGE-STYLE. Nothing registers it as a matchup style; only an arm naming it plays it.
;;;; The one job: ATTACK INTO ICHIGO'S SHUT HOHO. Ichigo's style CPU answers a move of his in reach with the timed (perfect) Hoho
;;;; (IKS-TIMED-HOHO, 0.9 at HARD), but only when AI-HOHO-SPARE-P lets her spend it: flash-step >= *FS-HOHO* 100, plus *FS-BURST* 100
;;;; while her Reishi is under *AI-BURST-LOW* (half), and HOHO-READY-P (lockout). Regen stops at one cell (FS-REGEN), so below half
;;;; Reishi she sits at 100 with the Hoho shut until a hit of hers fills it. In that window (her gauges as the HUD shows them, as
;;;; IKS-HIS-HOHO-SHUT-P reads his) Hisagi, free, presses the first of J1 / his pointer's NS that reaches her now (dead zone and reach,
;;;; less :ihx-margin), else walks in from :ihx-chase m; one roll per window (:ihx-p). Everything else is HISAGI-RANGE-STYLE (h1-range's
;;;; play), then the MCTS / generic CPU.
(in-package :duel)

(defparameter *ihx-p* '(:easy 0.0 :normal 0.5 :hard 1.0) "Per shut-Hoho window of hers (one roll as it opens): press into it.")
(defparameter *ihx-margin* 0.3 "The move must reach her perceived distance less this (m).")
(defparameter *ihx-chase* 5.0 "In the window, out of every move's reach but within this (m): walk in (0: never).")
(defparameter *ihx-reishi* 0.0
  "Extra Reishi fraction added to *AI-BURST-LOW* in the shut test (0: exactly her own AI-HOHO-SPARE-P); an arm may widen the window.")

(defstruct (ihx (:constructor make-ihx ()))
  "HISAGI-IHR1B2A0-STYLE's state: HISAGI-RANGE-STYLE's HRS (it runs on it unchanged) and the window's roll."
  (range nil)                   ; HISAGI-RANGE-STYLE's state
  (open nil)                    ; inside a shut-Hoho window
  (go nil)                      ; its roll said yes
  (tick 0 :type fixnum))        ; *MATCH-TICK* at the last call (a lower one: a new match)
(inline-readers ihx)

(defun ihx-shut-p (b o)
  "Is opponent O's Hoho shut for her CPU: HOHO-READY-P false, or AI-HOHO-SPARE-P's need over her flash-step (the low-Reishi reserve
widened by :ihx-reishi)?"
  (let* ((g (gauges o)) (low (+ *ai-burst-low* (style-knob b :ihx-reishi *ihx-reishi*))))
    (or (not (hoho-ready-p o))
        (< (gauges-fs g) (+ *fs-hoho* (if (< (reishi-frac g) low) *fs-burst* 0.0))))))

(defun ihx-fits-p (e mv d margin)
  "Does MV, started now by E, reach D (out of its dead zone, within its reach + slide less MARGIN)?"
  (and mv (plusp (mv-reach mv)) (<= (+ (mv-min-reach mv e) 0.1) d (- (strat-reach mv) margin))))

(defun ihx-step (e b f kit s d st)
  "Free, her Hoho shut: J1 / the pointer's NS in reach, else walk in. T when it pressed or walked."
  (if (not (and (member (fighter-state f) '(:idle :run)) (ihx-shut-p b (fighter-opp f))
                (or (member (snap-state s) '(:idle :run :guard)) (snap-punishable-p s))))
      (progn (setf (ihx-open st) nil) nil)
      (progn
        (unless (ihx-open st) (setf (ihx-open st) t (ihx-go st) (style-roll b :ihx-p *ihx-p*)))
        (when (ihx-go st)
          (let* ((m (style-knob b :ihx-margin *ihx-margin*)) (q (kit-command-move kit :q e)) (ns (kit-core-move kit :ns (mc-ptr f))))
            (cond ((ihx-fits-p e q d m)
                   (clog "~a ihx J1 at ~,1f" (side-name e) d)
                   (setf (brain-own-key b) -1) (cai-press b :quick 1) (hr-taken b f) t)
                  ((ihx-fits-p e ns d m)
                   (clog "~a ihx NS at ~,1f" (side-name e) d)
                   (hr-sp b f s) (hr-taken b f) t)
                  ((< d (style-knob b :ihx-chase *ihx-chase*))
                   (ai-walk e b (pilot-vpad (pilot e)) d 0.0 (max 1.0 (- (strat-reach (or q ns)) m))) t)))))))

(defun hisagi-ihr1b2a0-style (e b f kit s d)
  "Attack into Ichigo's shut Hoho (IHX-STEP), else HISAGI-RANGE-STYLE. T when it decided."
  (let ((st (brain-style b)))
    (when (or (not (ihx-p st)) (< *match-tick* (ihx-tick st))) (setf st (make-ihx) (brain-style b) st))
    (setf (ihx-tick st) *match-tick*)
    (or (ihx-step e b f kit s d st)
        (progn (setf (brain-style b) (ihx-range st))
               (prog1 (hisagi-range-style e b f kit s d)
                 (setf (ihx-range st) (brain-style b) (brain-style b) st))))))

;;;; cpu-ki-ichigo-r2b1a1.lisp — a strategy-search style for Ichigo against Kenpachi (KI round 2, dream-rsi cell ki-I b1_a1; the arm
;;;; docs/research/strategy-drsi/sp/ki-I/rounds/round02/nodes/b1_a1/cand.lisp). ICHIGO-KI-STYLE with one addition, the wake-up roll:
;;;; every combo of his ends in a knockdown and his meaty J1 (KK-MEATY-STEP) lands on her first free frame, a loop her wake-up Hoho
;;;; cannot escape (it presses on that same frame). Against round 1's Kenpachi (c-ki-k-r1-b2a2) the combos his meaty J1 opened were half
;;;; his damage (75k of 150k, 20 seeds a seat). The engine's wake-up roll (fighter.lisp AIR-STEP, *ROLL-DISTANCE* 4 m, invulnerable) is
;;;; taken by holding the stick as :down ends: she holds it away from him through the :down, so she rises ~4 m out, where his meaty J1
;;;; (pressed only within his J1's reach, perceived) is never pressed and the neutral (the whiff punish, the timed Hoho) starts again.
;;;; Not registered by CAI-DEFSTYLE: only an arm's :fn plays it.
(in-package :duel)

(defparameter *ir2-roll-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "Chance per knockdown of hers (one roll as she goes down) that she holds the stick away from him through the :down: the wake-up roll.
Arm key :ir2-roll-p.")
(defparameter *ir2-roll-near* 99.0
  "The roll only when he is within this (perceived, m) at the roll's decision (her first :down step). Arm key :ir2-roll-near.")

(defstruct (ir2 (:include ikst) (:constructor make-ir2 ()))
  (knock nil :type symbol)              ; this knockdown's roll: NIL unmade, :roll, :no
  (rolls 0 :type fixnum)                ; rolls taken this match (log only)
  (oki nil :type symbol))               ; his knockdown's hold roll: NIL unmade, :hold, :no
(inline-readers ir2)

(defun ir2-roll-step (e b f st d)
  "Her :down with the roll said yes: hold the stick away from him (the roll leaves on :down's last frame). T while it holds."
  (case (fighter-state f)
    (:down
     (unless (ir2-knock st)
       (setf (ir2-knock st) (if (and (<= d (style-knob b :ir2-roll-near *ir2-roll-near*)) (style-roll b :ir2-roll-p *ir2-roll-p*))
                               :roll :no))
       (when (eq (ir2-knock st) :roll)
         (incf (ir2-rolls st))
         (clog "~a ir2 roll armed d ~,1f" (side-name e) d)))
     (when (eq (ir2-knock st) :roll)
       (vpad-stick! (pilot-vpad (pilot e)) 0f0 -1f0)
       t))
    ((:air :wakeup) nil)
    (t (setf (ir2-knock st) nil) nil)))

(defparameter *ir2-oki-p* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "Chance per knockdown of his (one roll as he is seen going down) that she presses nothing while he is seen :air / :down / :wakeup and
holds *IR2-OKI-LO*..*IR2-OKI-HI* instead (the base style's presses that step are dropped; its meaty J1, when armed, still runs). Against
c-ki-k-r1-b2a2 her J1 / NS pressed into his invulnerable wake-up (the KESSA episodes hand over to the generic CPU after
*IKS-WAIT-MAX*) whiffed, and his first free J1 or wake-up Hoho opened a combo. Arm key :ir2-oki-p.")
(defparameter *ir2-oki-lo* 2.6 "The hold band's near edge (m, perceived): past his wake-up Hoho's 2.4 m and his sealed J1. Arm key :ir2-oki-lo.")
(defparameter *ir2-oki-hi* 3.3 "The hold band's far edge (m, perceived). Arm key :ir2-oki-hi.")

(defun ir2-oki-step (e b f st s d plan)
  "He is seen knocked down: the roll (once per knockdown), then while it says yes and she is free, drop the base style's press of this
step (its plan restored to PLAN; an awakening press is kept) and walk to the hold band. T while it holds."
  (cond ((not (member (snap-state s) '(:air :down :wakeup))) (setf (ir2-oki st) nil) nil)
        (t (unless (ir2-oki st)
             (setf (ir2-oki st) (if (style-roll b :ir2-oki-p *ir2-oki-p*) :hold :no)))
           (when (and (eq (ir2-oki st) :hold) (member (fighter-state f) '(:idle :run)) (not (ikst-meaty st))
                      (not (and (plusp (brain-press-left b)) (eq (brain-press b) :awaken))))   ; (her awakening goes: its roll is spent)
             (when (plusp (brain-press-left b))
               (setf (brain-press-left b) 0 (ikst-plan st) plan)
               (clog "~a ir2 oki drop d ~,1f" (side-name e) d))
             (iks-walk e b (pilot-vpad (pilot e)) d (style-knob b :ir2-oki-lo *ir2-oki-lo*) (style-knob b :ir2-oki-hi *ir2-oki-hi*))))))

(defun ichigo-ki-r2b1a1-style (e b f kit s d)
  "ICHIGO-KI-STYLE plus the wake-up roll (IR2-ROLL-STEP) and the hold over his knockdown (IR2-OKI-STEP). T when it decided."
  (let ((st (brain-style b)))
    (unless (ir2-p st) (setf st (make-ir2) (brain-style b) st))
    (let* ((plan (ikst-plan st))
           (r (ichigo-ki-style e b f kit s d)))   ; (first: its per-step bookkeeping runs on every step)
      (or (ir2-roll-step e b f st d) (ir2-oki-step e b f st s d plan) r))))

;;;; cpu-perceive.lisp — what every CPU player (the core CPU, core-ai.lisp, and the matchup style CPUs) shares: its delayed
;;;; perception of the opponent (a ring of SNAPs; reaction time is the difficulty: EASY 24, NORMAL 14, HARD 8 frames), the
;;;; readers over a SNAP, and its button presses (the brain's held press, written to its vpad by CORE-BRAIN-STEP). Every random
;;;; number comes from SIM-RND01: a seed replays the same match. Out of ai.lisp on 2026-11-12 (REFACTOR_2026-11 R3): the old AI
;;;; v2 (the generic reflex / intent / decide stack the retired kits played) left with them; its last section is only what the
;;;; frozen ASSIST and old learner still call (assist.lisp, ai-learn.lisp: refactor batch R4 removes it with them).
(in-package :duel)

;;; (EXPT X 2) without boxing, beside fighter.lisp's zero-cons twins (here: fighter.lisp is loaded by the host tests, and the
;;; interpreter can't take FFI:CLINES)
(ffi:clines "static float duel_expt2(float x) { volatile float two = 2.0f; return x == 0.0f ? x * 2.0f : powf(x, two); }")
(defmacro %expt2 (x)
  "CL's (EXPT X 2) of a single-float as ECL computes it: X x 2 for a zero (ecl_times), else powf (X, 2.0) (ecl_expt_float;
the volatile 2 keeps the C compiler from turning it into X*X, which powf need not equal)."
  `(ffi:c-inline (,x) (:float) :float "duel_expt2(#0)" :one-liner t))

(defstruct snap
  "What the CPU sees of its opponent at one step."
  (x 0f0 :type single-float) (z 0f0 :type single-float)
  (state :idle) (kind nil) (phase nil)
  (sf 0 :type fixnum) (s 0 :type fixnum) (active-end 0 :type fixnum)
  (left 0 :type fixnum)                 ; frames left of his move (99 = still charging / dashing) or stun
  (start 0 :type fixnum)                ; tick his current move / guard began (one roll per event)
  (reach 0f0 :type single-float)
  (flags nil)                           ; his move's :flags (:parry :bind ...)
  (contact nil)                         ; what his move touched so far (NIL = nothing yet: a whiff when it ends)
  (move nil))
(inline-readers snap)                           ; his move (NIL: none): its volumes, params (SNAP-NEAR-P ...)

(defun snap-take! (s o)
  "Fill SNAP S with fighter O as he is now."
  (let* ((f (fighter o)) (p (pos-of o)) (mv (fighter-move f)) (st (fighter-state f)))
    (sim-fast (let* ((q p)) (declare (type f32vec q)) (%set-float (snap-x s) (aref q 0)) (%set-float (snap-z s) (aref q 2))))
    (setf (snap-state s) st (snap-sf s) (fighter-sf f))
    (if (and (eq st :move) mv)
        (let ((total (move-end-frame (mv-s mv) (mv-a mv) (mv-r mv) (mv-whiff mv) (fighter-contact f)
                                     (zerop (length (mv-hits mv))) (mv-kind mv))))
          (setf (snap-kind s) (mv-kind mv) (snap-phase s) (fighter-phase f) (snap-s s) (mv-s mv) (snap-flags s) (mv-flags mv)
                (snap-contact s) (fighter-contact f)
                (snap-active-end s) (+ (mv-s mv) (mv-a mv)) (snap-reach s) (f32 (mv-reach mv))
                (snap-left s) (if (eq (fighter-phase f) :main) (max 0 (- total (fighter-sf f))) 99)
                (snap-start s) (- *match-tick* (fighter-sf f) (fighter-hold f))
                (snap-move s) mv))
        (setf (snap-kind s) nil (snap-phase s) nil (snap-reach s) 0f0 (snap-flags s) nil (snap-contact s) nil (snap-move s) nil
              (snap-left s) (if (eq st :stun) (max 0 (- (fighter-stun f) (fighter-sf f))) 0)
              (snap-start s) (if (eq st :guard) (- *match-tick* (fighter-guard-t f)) -1)))
    s))

(defun snap-live-p (s)
  "Is his perceived move S still to hit: before the end of its active frames?"
  (< (snap-sf s) (snap-active-end s)))

(defun snap-recovering-p (s)
  "Is he, as perceived, recovering from a move (its main phase past its active frames)?"
  (and (eq (snap-state s) :move) (eq (snap-phase s) :main) (>= (snap-sf s) (snap-active-end s))))
(defun snap-punishable-p (s)
  "Is he, as perceived, recovering (SNAP-RECOVERING-P) or reeling?"
  (or (snap-recovering-p s) (eq (snap-state s) :stun)))
(defun snap-left-seen (s b) "His frames left as perceived S, less brain B's perception delay." (- (snap-left s) (brain-delay b)))
(defun snap-lead-seen (s b)
  "Frames from his perceived frame (S) to his move's first active frame, less brain B's perception delay."
  (- (snap-s s) (snap-sf s) (brain-delay b)))

(defun snap-seg-gap (s e)
  "How far E's feet are from his perceived move's :seg-fn capsules (kit.lisp SEG-GAP: their segment as his kit gives it now,
radius off), or NIL: no window of it has one (every move but those: the reach test, unchanged)."
  (let ((mv (snap-move s)) (p (pos-of e)))
    (and mv (seg-gap mv (opp-of e) (aref p 0) (aref p 2)))))

(defun snap-near-p (s e d margin)
  "Is E, at the perceived distance D, in reach of his perceived move S: D < its reach + MARGIN (a :seg-fn window: E's feet
within its capsule + E's hurt radius + MARGIN, SNAP-SEG-GAP)?"
  (let ((g (snap-seg-gap s e)))
    (if g (< g (+ (body-hurt-r (model-body (model e))) margin)) (< d (+ (snap-reach s) margin)))))

;;; ---------------------------------------------------------------- pressing buttons
(defun ai-press (b button frames &key modded (act button))
  "Hold BUTTON (with :MOD when MODDED) for FRAMES steps, starting now."
  (setf (brain-press b) button (brain-press-mod b) modded (brain-press-left b) (max 1 frames) (brain-act b) act))

(defun ai-dash (b dir to)
  "Hold Step (the hop, then the run) with the stick toward (DIR 1) or away from (-1) the opponent,
until the distance passes TO (CORE-BRAIN-STEP lets go)."
  (ai-press b :step *ai-dash-frames* :act :dash)
  (setf (brain-dash b) (f32 dir) (brain-dash-to b) (f32 to)))

(defun why (b reason cmd) "Note REASON (debug) and return CMD." (setf (brain-why b) reason) cmd)

(defun ai-event-rolls (b s)
  "One roll per opponent action (his SNAP S starts a new one): brain B's guard / Hoho / reaction rolls."
  (when (/= (snap-start s) (brain-roll-key b))
    (setf (brain-roll-key b) (snap-start s) (brain-guard-roll b) (sim-rnd01) (brain-hoho-roll b) (sim-rnd01)
          (brain-react-roll b) (sim-rnd01))))

(defun ai-strafe (e b)
  "The strafe's next side and how long it lasts (*AI-STRAFE-TIME*)."
  (declare (ignore e))
  (setf (brain-strafe-t b) (+ (first *ai-strafe-time*) (floor (* (second *ai-strafe-time*) (sim-rnd01))))
        (brain-strafe b) (if (< (sim-rnd01) 0.5) -1f0 1f0)))

(defun ai-walk (e b vp d lo hi)
  "The stick toward the range LO..HI, strafing inside it."
  (declare (ignore e))
  (vpad-stick! vp (if (<= lo d hi) (brain-strafe b) (* 0.3 (brain-strafe b)))
               (cond ((> d hi) 1f0) ((< d lo) -1f0) (t 0f0))))

;;; ---------------------------------------------------------------- perception
(defun brain-perceive (e b o)
  "Brain B of E sees opponent O this step: his SNAP goes into the ring; values the SNAP of BRAIN-DELAY steps ago and the
distance to it (the assist's learner perceives the same way: assist.lisp)."
  (let* ((ring (brain-ring b)) (n (length ring))
         (cur (or (svref ring (brain-head b)) (setf (svref ring (brain-head b)) (make-snap)))))
    (snap-take! cur o)
    (let* ((s (or (svref ring (mod (- (brain-head b) (brain-delay b)) n)) cur))
           (p (pos-of e))
           (d (sim-fast                                     ; (SQRT of two EXPT 2s, as twins: bit-identical, no boxing)
                (let* ((sx (snap-x s)) (sz (snap-z s)) (q p))
                  (declare (single-float sx sz) (type f32vec q))
                  (let* ((v (%sqrt (+ (%expt2 (- sx (aref q 0))) (%expt2 (- sz (aref q 2)))))))
                    (declare (single-float v))
                    v)))))
      (setf (brain-head b) (mod (1+ (brain-head b)) n))
      (when (and (eq (snap-state s) :move) (eq (snap-kind s) :quick) (/= (snap-start s) (brain-jkey b)))   ; a J of his begins
        (setf (brain-jkey b) (snap-start s))
        (push *match-tick* (brain-jstarts b)))
      (when (brain-jstarts b)                               ; only the window's
        (setf (brain-jstarts b) (drop-old-jstarts (brain-jstarts b) *match-tick* *ai-mash-window*)))
      (values s d))))

(defun drop-old-jstarts (l now window)
  "(DELETE-IF (LAMBDA (T0) (> (- NOW T0) WINDOW)) L) without its closure and scratch cons: the ticks of L within WINDOW of
NOW, in order (L destroyed)."
  (loop while (and l (> (- now (car l)) window)) do (setf l (cdr l)))
  (when l
    (let ((prev l))
      (loop for c = (cdr prev) while c
            do (if (> (- now (car c)) window) (setf (cdr prev) (cdr c)) (setf prev c)))))
  l)

(defun ai-mash-p (b)
  "Is he mashing J, as brain B saw him: *AI-MASH-STARTS* J starts within *AI-MASH-WINDOW* frames?"
  (>= (length (brain-jstarts b)) *ai-mash-starts*))

(defun brain-system ()
  "Every CPU fighter decides this step (before FIGHTER-SYSTEM reads the vpads): the core CPU (core-ai.lisp CORE-BRAIN-STEP;
every playing kit has a :core)."
  (do-entities (e (b brain) (f fighter)) (core-brain-step e b)))

;;; ================================================================ kept only for the frozen ASSIST and old learner
;;; (assist.lisp, ai-learn.lisp, hisagi-ai.lisp's ASSIST routes call these; neither runs for a :core kit). Refactor batch R4
;;; removes this section with them.
(defun ai-table (e key &optional default) (plist-get (kit-ai (kit-of e)) key default))

(defparameter *ai-steps* '(:learn-plan learn-plan :learn-press learn-press :learn-neutral learn-neutral :burst-chance ai-burst-chance
                           :auto-guard auto-guard :auto-combo auto-combo :auto-break auto-break :auto-sp auto-sp :auto-read auto-read
                           :string-queued ai-string-queued :string-bait ai-string-bait :l-link ai-l-link :k-link ai-k-link :j-link ai-j-link
                           :k-only ai-k-only :l-cancel ai-l-cancel :sp-cancel ai-sp-cancel :end-orange ai-end-orange)
  "The frozen ASSIST's and old learner's replaceable steps and their generic defaults; a kit's :ai :steps names its own.")

(defun ai-step (e name)
  "The function E's CPU runs for step NAME: its kit's own (the :ai plist's :steps sub-plist), else *AI-STEPS*'s default."
  (or (plist-get (ai-table e :steps) name) (plist-get *ai-steps* name)))

(defvar *ai-brain* nil
  "The brain deciding for a fighter that has none (a human): the ASSIST's borrowed brain while ASSIST-STEP runs for him.")

(defun ai-command (b kit cmd d &optional e)
  "Press the buttons of kit command CMD at distance D: KIT's own :command step (its :ai :steps, given the fighter E), else
AI-COMMAND-PRESS."
  (let ((h (and e (getf (getf (kit-ai kit) :steps) :command))))
    (if h (funcall h b kit cmd d e) (ai-command-press b kit cmd d e))))

(defun ai-command-press (b kit cmd d &optional e)
  "The generic :command step: press the buttons of kit command CMD at distance D (holding charge / stance / Breaker moves a
while: a charge move is held to its full charge from beyond 7 m, where it has the time)."
  (let ((r (sim-rnd01)))
    (flet ((hold-for (mv lo spread) (if (and mv (mv-hold mv)) (+ lo (floor (* r spread))) 1)))   ; (NIL: a form without it)
      (case cmd
        (:q (ai-press b :quick 1))
        (:f (ai-press b :flash 1))
        (:sig (ai-press b :sig (let ((h (getf (kit-ai kit) :sig-hold)))   ; a kit's own hold length (its :sig-hold function)
                                 (if h (funcall h kit d e) (hold-for (kit-command-move kit :sig) 12 40)))))
        ((:sp1 :sp1-full)                                 ; :sp1-full: a charge move held to its end
         (let ((mv (kit-command-move kit :sp1)) (h (getf (kit-ai kit) :sp1-hold)))
           (ai-press b :flash (cond (h (funcall h kit d e))
                                    ((and mv (mv-hold mv) (or (eq cmd :sp1-full) (> d 7.0))) (+ 2 (second (mv-hold mv))))
                                    (t (hold-for mv 14 46)))
                     :modded t :act :sp1)))
        (:sp2 (ai-press b :sig (if (< r 0.4) 20 1) :modded t :act :sp2))
        (:breaker (ai-press b :breaker (+ 12 (floor (* r 30)))))
        (:step (ai-press b :step 1))
        (:side-step (ai-press b :step 1 :act :side-step))
        (:hoho (ai-press b :step 1 :modded t :act :hoho))
        (:guard (ai-press b :guard (+ 10 (floor (* r 20)))))
        (:guard-long (ai-press b :guard 60 :act :guard))
        (:guard-cancel (ai-press b :guard 4))
        (:kikon (let ((mv (kit-command-move kit :kikon)))                ; held through the strike (aura + dash + S)
                  (ai-press b :kikon (+ (rush-param mv :aura) (rush-param mv :dash-max) (mv-s mv) 4))))
        (:awaken (ai-press b :awaken 1))
        (:burst (ai-press b :quick 1 :modded t :act :burst))))))

(defun ai-guard-k (e)
  "How much of its guard chance E's CPU uses (AI-GUARD-MULT); none in a form whose U is a move (a :u hook)."
  (if (kit-hook (kit-of e) :u) 0.0 (ai-guard-mult (gauges-gg (gauges e)) (gauges-guardless (gauges e)))))

(defun guarding-p (e) "E holds a guard (:guard / :guard-hit)." (member (state-of e) '(:guard :guard-hit)))

(defun j-beats-open-p (e b)
  "J beats K's window (docs/duel/DUEL_STRINGS.md §4; the assist's AUTO GUARD presses J in it): on the first free step after
our blockstun, his string's next link is a K link still S(J1) + 2 frames from its hit, or his blocked J still recovers,
inside our J1's reach."
  (let* ((f (fighter e)) (o (fighter-opp f)) (fo (fighter o)) (om (fighter-move fo)) (q (kit-command-move (fighter-kit f) :q)))
    (and (eq (brain-was b) :guard-hit) (member (fighter-state f) '(:idle :guard)) (zerop (fighter-lock f))
         (eq (fighter-state fo) :move) (eq (fighter-phase fo) :main)
         (or (and (eq (mv-kind om) :flash) (>= (- (mv-s om) (fighter-sf fo)) (+ (mv-s q) 2)))
             (and (eq (mv-kind om) :quick) (>= (fighter-sf fo) (+ (mv-s om) (mv-a om)))))   ; his blocked J still recovering
         (< (fighter-dist f) (+ (mv-reach q) 0.2)))))

(defun ai-kikon-futile-p (e)
  "Is E's Kikon futile in this DANGAI stage (DUEL_ROGUE §4.4): his opponent's Kikon is always guarded (:kikon-guard), or
the Kikon is sealed for both sides (:kikon-seal)? NIL outside a run."
  (and *run-mods* (or (rmod (opp-of e) :kikon-guard nil) (rmod *run-mods-who* :kikon-seal nil)) t))

(defun ai-sb-finish-p (e)
  "E's opponent is nearly out of Reishi (under *AI-SB-FINISH* of his max): finish him with hits, the Soul Break, not the
Kikon rush he might still guard or dodge. Always, when the Kikon is futile (AI-KIKON-FUTILE-P)."
  (or (ai-kikon-futile-p e)
      (let ((go (gauges (opp-of e)))) (< (gauges-reishi go) (* *ai-sb-finish* (gauges-reishi-max go))))))
(defun ai-o-ender-ok-p (e kit)
  "May E's CPU press the O ender now: no Soul Break finish due (AI-SB-FINISH-P) and KIT's Kikon command open?"
  (and (not (ai-sb-finish-p e)) (kit-command-ok-p e :kikon kit)))

(defun ranged-threat-in (e b s d lo hi)
  "Does a ranged hit reach E within LO..HI frames, as brain B perceives it (Hisagi's assist guard, DUEL_HISAGI §12.4)? One of
his hazards with hits left (moving: its distance over its speed, after its delay; standing: its delay, touching E), or his
perceived move S's next :ranged window (KIT.LISP RANGED-WINDOW-LEAD, less the perception delay) with E in its reach
(SNAP-NEAR-P) beyond its :melee-range (nearer it is the blade)."
  (or (let ((o (opp-of e)) (q (pos-of e)) (bd (model-body (model e))) (hit nil))
        (do-entities (h (hz hazard))
          (when (and (not hit) (eql (hazard-owner hz) o) (hazard-hw hz) (> (hazard-hits-left hz) 0))
            (let ((fr (if (> (hazard-speed hz) 0.1)
                          (+ (max 0 (hazard-delay hz))
                             (/ (* 60 (max 0.0 (- (hypot (- (aref q 0) (hazard-x hz)) (- (aref q 2) (hazard-z hz))) 1.0)))
                                (hazard-speed hz)))
                          (and (hazard-touches-p hz (aref q 0) (aref q 1) (aref q 2) (body-hurt-r bd) (body-hurt-h bd))
                               (max 0 (hazard-delay hz))))))
              (when (and fr (<= lo fr hi)) (setf hit t)))))
        hit)
      (let ((mv (snap-move s)))
        (and mv (eq (snap-state s) :move) (eq (snap-phase s) :main)
             (let ((lead (ranged-window-lead mv (snap-sf s)))) (and lead (<= lo (- lead (brain-delay b)) hi)))
             (let ((r (getf (mv-params mv) :melee-range))) (or (null r) (> d r)))
             (snap-near-p s e d *ai-threat-margin*)))))

(defun ai-cancel-p (e kit)
  "End a landed string with the kit's :cancel command (L, a :cancel Signature) now? Its chance, and it may start."
  (let* ((c (ai-table e :cancel)) (p (getf c :sig)) (mv (kit-command-move kit :sig)))
    (and p mv (member :cancel (mv-flags mv)) (kit-command-ok-p e :sig) (< (sim-rnd01) p))))

(defun ai-orange-p (e b f)
  "CHAIN REVERSE (ORANGE) out of a string link that hit and has no link after it? Allowed (BURST-OK-P :orange), the victim
reeling on the ground within Q1's reach, and healthy (AI-BURST-WANTED-P): one roll (*AI-ORANGE-P* by difficulty)."
  (let ((g (gauges e)) (o (opp-of e)))
    (and (eq (burst-ok-p e) :orange) (eq (state-of o) :stun)
         (< (fighter-dist f) (+ (mv-reach (kit-command-move (fighter-kit f) :q)) 0.2))
         (not (ai-burst-wanted-p (gauges-reishi g) (gauges-reishi-max g) 0))
         (ai-burst-rolled e b :orange (getf *ai-orange-p* (brain-difficulty b) 0.25)))))

(defun ai-string-claim (e name b f mv)
  "STRING-REFLEX's step NAME (e b f mv): :PASS (not this one) or its command (NIL included)."
  (let ((h (ai-step e name))) (if h (funcall h e b f mv) :pass)))

(defmacro def-string-step (name doc test &body body)
  "A claiming STRING-REFLEX step NAME (e b f mv): BODY's value when TEST holds, else :PASS; STRING-REFLEX's locals bound: KIT,
NQ / NF (the J / K links KIT-NEXT allows), BARS (his Reiatsu bars)."
  `(defun ,name (e b f mv)
     ,doc
     (let* ((kit (fighter-kit f))
            (nq (kit-next kit (mv-name mv) :q))
            (nf (kit-next kit (mv-name mv) :f))
            (bars (reiatsu-bars e)))
       (declare (ignorable kit nq nf bars))
       (if ,test (progn ,@body) :pass))))

(def-string-step ai-string-queued
  "the next link is latched already: nothing more"
  (fighter-queued f)
  nil)

(def-string-step ai-string-bait
  "a learner baits his predicted burst: the string ends at its 2nd hit (then a guard: LEARN-FIRE)"
  (and (brain-learn b) (eq (lrn-cmd (brain-learn b)) :bait)
       (>= (fighter-combo-hits (fighter (opp-of e))) 2))
  (why b :bait nil))

(def-string-step ai-l-link
  "L after a K link (a J link: :l-after-j; a kit function (e link L) gives its chance), one roll per hit"
  (let* ((p (ai-table e (if (kit-k-link-p kit (mv-name mv)) :l-after-k :l-after-j) 0.0))
         (l (kit-l-link kit (mv-name mv)))
         (p (if (and p (symbolp p)) (if l (funcall p e mv l) 0.0) p)))   ; (a kit function (e link L): its chance)
    (and (plusp p) (= (fighter-sf f) (fighter-land-sf f)) l (kit-command-ok-p e :sig kit l)   ; one roll per hit
         (< (sim-rnd01) p)))
  (why b :l-after-k :sig))

(def-string-step ai-k-link
  "the next K link, the kit's :string-k share of the time"
  (and nf (< (sim-rnd01) (ai-table e :string-k *ai-string-flash-p*)))
  :f)

(def-string-step ai-j-link
  "else the next J link"
  nq
  :q)

(def-string-step ai-k-only
  "else the K link when it's the only one"
  nf
  :f)

(def-string-step ai-l-cancel
  "the string's last link: end it with L (the kit's :cancel, AI-CANCEL-P)"
  (and (>= (fighter-sf f) (fighter-land-sf f)) (ai-cancel-p e kit))
  (why b :cancel :sig))

(def-string-step ai-sp-cancel
  "SP2 off the last link's hit when the victim is on the ground and the kit's :sp-cancel-bars are there, *AI-SP-CANCEL-P* of the time"
  (and (>= bars (ai-table e :sp-cancel-bars 1)) (kit-command-ok-p e :sp2)
       (= (fighter-sf f) (fighter-land-sf f)) (not (eq (state-of (opp-of e)) :air))
       (< (sim-rnd01) *ai-sp-cancel-p*))              ; one roll, on the first step we see the hit
  :sp2)

(def-string-step ai-end-orange
  "the string's end: ORANGE off it (AI-ORANGE-P)"
  (and (not nq) (not nf) (= (fighter-sf f) (fighter-land-sf f)) (ai-orange-p e b f))
  (why b :orange :burst))

(defun string-reflex (e b f mv)
  "Our link hit: go on with the string (the next link K *AI-STRING-FLASH-P* of the time, among the links KIT-NEXT allows), or
end it with L (the kit's :cancel), else SP2 when the victim is on the ground and the kit's :sp-cancel-bars are there."
  (let ((kit (fighter-kit f)) (r nil))
    (setf (brain-why b) :string)
    (cond ((not (eq (setq r (ai-string-claim e :string-queued b f mv)) :pass)) r)   ; its steps in order (*AI-STEPS*)
          ((not (eq (setq r (ai-string-claim e :string-bait b f mv)) :pass)) r)
          ((not (eq (setq r (ai-string-claim e :l-link b f mv)) :pass)) r)
          ((not (eq (setq r (ai-string-claim e :k-link b f mv)) :pass)) r)
          ((not (eq (setq r (ai-string-claim e :j-link b f mv)) :pass)) r)
          ((not (eq (setq r (ai-string-claim e :k-only b f mv)) :pass)) r)
          ((not (eq (setq r (ai-string-claim e :l-cancel b f mv)) :pass)) r)
          ((let ((h (ai-table e :sp-ender)))            ; the kit's own SP ender (its function picks it, or NIL)
             (and h (= (fighter-sf f) (fighter-land-sf f)) (not (eq (state-of (opp-of e)) :air))
                  (let ((c (funcall h e kit))) (and c (why b :sp-ender c))))))
          ((not (eq (setq r (ai-string-claim e :sp-cancel b f mv)) :pass)) r)
          ((not (eq (setq r (ai-string-claim e :end-orange b f mv)) :pass)) r))))

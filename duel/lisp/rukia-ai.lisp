;;;; rukia-ai.lisp — Rukia's CPU: her four forms' :ai plists (*RU-AI-BASE* .. *RU-AI-ZERO*), her action policy (AI v2,
;;;; docs/duel/DUEL_AI_V2.md: the perfect-Hoho counter-fighter, the cash-out, the zone, absolute zero's REIDO, the bursts' and the
;;;; held kido's reads) and its knobs (the *AI-RU-...* parameters, every chance EASY <= NORMAL <= HARD). Split out of rukia.lisp
;;;; 2026-10-25 for her CPU search (docs/research/rukia-ai-drsi, DUEL_RUKIA_TYBW §17), as hisagi-ai.lisp was. Loads right BEFORE
;;;; rukia.lisp, whose DEFKITs read the :ai plists by name; the plists name the CPU functions as bare symbols (late-bound), and
;;;; tuning.lisp keeps *AI-RU-L-AFTER-K* / -AWAKE* (spliced in by value). Plain CL (the host rules test loads it before
;;;; rukia.lisp); no DEFUN-FAST. The dream-rsi search edits this file.
(in-package :duel)
(defvar *ru-hoho-cold*) (defvar *ru-l-hold*)   ; (rukia.lisp's knobs, set when it loads after this file)

;;; ================================================================ her forms' :ai plists (out of rukia.lisp's DEFKITs 2026-10-25: this file
;;; loads BEFORE rukia.lisp, whose DEFKITs read these by name; a tuning knob inside one is spliced in by value)
(defparameter *ru-ai-base*
  `(:intents (:approach 2 :pressure 3 :zone 2 :defend 1)
       :ranges (:approach (2.8 5.0) :pressure (1.0 2.4) :zone (5.0 7.5) :defend (3.5 6.0))
       :moves ((0.0 1.8 :q 6 :f 2 :breaker 1 :sp2 1)                   ; J up close only (DUEL_STRINGS §13), K beyond
               (1.8 2.8 :f 4 :breaker 1 :sp2 1)
               (2.8 5.0 :f 1 :sp2 2 :sig 2 :sp1 1 :kikon 1 :step 1)
               (5.0 8.0 :sig 4 :sp1 1 :kikon 2 :step 1)
               (8.0 99.0 :kikon 2 nil 2))
       :guard 0.4 :hoho 0.35 :sp-cancel-bars 1 :dash 0.5 :dash-back 0.4 :kikon-range 8.0
       :stun-follow (:sp2 2.4 5.0) :awaken (:melee-share 0.6 :min-taken 150)
       :l-after-k rukia-ai-burst-p :l-after-j rukia-ai-burst-p :sig-hold rukia-ai-sig-hold :sp1-hold rukia-ai-sp1-hold
       :sp-ender rukia-ai-sp-ender :reflex rukia-ai-reflex :assist-guard rukia-assist-guard :steps (:block-hold rukia-ai-block-hold :held rukia-ai-held))
  "Her base form's CPU (the kit's :ai: ai.lisp; DUEL_RUKIA_TYBW §17).")
(defparameter *ru-ai-m18*
  `(:intents (:approach 2 :pressure 3 :zone 1 :defend 2)
       :ranges (:approach (2.5 4.5) :pressure (1.0 2.2) :zone (4.5 7.0) :defend (3.0 5.0))
       :moves ((0.0 1.8 :q 5 :f 2 :breaker 1 :sig 1)
               (1.8 2.8 :f 3 :breaker 1 :sig 1)
               (2.8 5.0 :sp2 2 :step 1 nil 2)
               (5.0 99.0 :sp1 2 nil 2))
       :guard 0.5 :hoho 0.3 :dash 0.2 :dash-back 0.2 :o-ender 0.25 :l-after-k ,*ai-ru-l-after-k-awake* :kikon-range 6.5 :sp-cancel-bars 2
       :cool (:p 0.3 :near 3.5) :stun-follow (:sp2 2.4 5.0) :sp-ender rukia-ai-sp-ender :reflex rukia-ai-reflex :assist-guard rukia-assist-guard :steps (:block-hold rukia-ai-block-hold :held rukia-ai-held))
  "Her m18 form's CPU (the kit's :ai: ai.lisp; DUEL_RUKIA_TYBW §17).")
(defparameter *ru-ai-m50*
  `(:intents (:approach 1 :pressure 3 :zone 0 :defend 2)
       :ranges (:approach (2.0 3.5) :pressure (1.0 2.3) :zone (3.0 5.0) :defend (2.0 3.5))
       :moves ((0.0 1.9 :q 4 :f 2 :sig 3)
               (1.9 3.5 :f 3 :sig 3)
               (3.5 99.0 :sp2 1 :sp1 1 nil 2))
       :guard 0.45 :hoho 0.25 :dash 0.1 :dash-back 0.1 :o-ender 0.25 :l-after-k ,*ai-ru-l-after-k-awake* :kikon-range 7.5 :sp-cancel-bars 2
       :cool (:p 0.35 :near 4.0 :no-projectile t :min-gg 50) :stun-follow (:sp2 2.4 6.0) :reflex rukia-ai-reflex :assist-guard rukia-assist-guard :steps (:block-hold rukia-ai-block-hold :held rukia-ai-held)
       :sp-ender rukia-ai-sp-ender)
  "Her m50 form's CPU (the kit's :ai: ai.lisp; DUEL_RUKIA_TYBW §17).")
(defparameter *ru-ai-zero*
  `(:intents (:approach 0 :pressure 3 :zone 0 :defend 2)
       :ranges (:approach (0.0 99.0) :pressure (0.0 99.0) :zone (0.0 99.0) :defend (0.0 99.0))
       :moves ((0.0 2.2 :q 4 :f 3)
               (2.2 3.5 :f 4 nil 1)
               (3.5 5.5 :sig 3 :f 1 nil 1)
               (5.5 7.5 :sp2 1 :sp1 2 nil 2)
               (7.5 14.0 :sp1 2 nil 2)
               (14.0 99.0 nil 1))
       :guard 0.0 :hoho 0.0 :o-ender 0.25 :l-after-k ,*ai-ru-l-after-k-awake* :kikon-range 9.0 :sp-cancel-bars 2
       :brace (:p 0.2 :near 5.5 :min-gg 30) :opp-intent (:zone 2 :defend 2) :sp-ender rukia-ai-sp-ender
       :reflex rukia-ai-reflex :assist-guard rukia-assist-guard :steps (:block-hold rukia-ai-block-hold :held rukia-ai-held))
  "Her zero form's CPU (the kit's :ai: ai.lisp; DUEL_RUKIA_TYBW §17).")

(defparameter *ai-ru-hoho-in* 0.05 "-50's CPU: chance per free step to Hoho in when that Hoho reaches -273 (RUKIA-AI-HOHO-IN).")

(defun rukia-ai-hoho-in (e b s d)
  "-50's :ai :reflex: beyond 3 m, when a Hoho's cold (RUKIA-HOHO-COLD) would reach -273 and the Hoho is allowed, dive in
now and then (*AI-RU-HOHO-IN* per free step). A command or NIL."
  (declare (ignore s))
  (let ((g (gauges e)))
    (and (> d 3.0) (zerop (gauges-meter-idle g)) (>= (+ (gauges-meter g) *ru-hoho-cold*) *cold-max*)
         (hoho-ready-p e) (< (sim-rnd01) *ai-ru-hoho-in*)
         (why b :hoho-in :hoho))))

;;; ---------------------------------------------------------------- her CPU's action policy (AI v2, docs/duel/DUEL_AI_V2.md)
;;; Every chance is per difficulty (EASY <= NORMAL <= HARD; NORMAL near the shipped CPU, HARD the full version).
(defparameter *ai-ru-k-ender-l* '(:easy 0.0 :normal 0.02 :hard 0.9)
  "Her K3 (the K ender, crumple) hit: the band's L chained after it (the K -> L latch: the Shikai's 白漣 burst, SHIMOBASHIRA, HYOSHIN,
REIDO), per ender hit (RUKIA-AI-SP-ENDER).")
(defparameter *ai-ru-j-ender-sp2* '(:easy 0.1 :normal 0.15 :hard 0.85)
  "Her J3 (the J ender, stagger) hit: SHIRAFUNE off it (it chases the pushed victim), per ender hit, the bars permitting.")
(defparameter *ai-ru-ender-o* '(:easy 0.0 :normal 0.02 :hard 0.9)
  "An ender hit with neither of those taken: the O ender after all (it chases the pushed victim), per ender hit.")

(defun rukia-ai-bars-p (e)
  "Bars enough for an SP and the kit's reserve (:sp-cancel-bars) after it."
  (>= (reiatsu-bars e) (ai-table e :sp-cancel-bars 1)))

(defun rukia-ai-sp-ender (e kit)
  "Her :sp-ender (ai.lisp STRING-REFLEX; a landed ender, no link after it): after a K ender the band's L link (a combo off
the crumple, free in the Shikai, cold in the bands: a chained L overdraws), after a J ender SHIRAFUNE (not at zero: it
would cash the top bar for less than REIDO). A command or NIL."
  (let* ((name (mv-name (fighter-move (fighter e)))) (l (kit-l-link kit name)))
    (cond ((and l (kit-k-link-p kit name) (kit-command-ok-p e :sig kit nil l) (< (sim-rnd01) (ai-chance e *ai-ru-k-ender-l*)))
           :sig)
          ((and (kit-j-link-p kit name) (not (kit-rooted kit)) (kit-command-ok-p e :sp2) (rukia-ai-bars-p e)
                (< (sim-rnd01) (ai-chance e *ai-ru-j-ender-sp2*)))
           :sp2)
          ((and (ai-o-ender-ok-p e kit) (< (sim-rnd01) (ai-chance e *ai-ru-ender-o*))) :kikon))))

;;; ---------------------------------------------------------------- her CPU (AI v2): the perfect-Hoho counter-fighter
;;; Her answer to a commitment is not to meet it but to vanish through it: a Hoho timed into his hit window from what she
;;; saw (the perception delay counted) is PERFECT (combat.lisp PERFECT-NOW-P): the automatic counter, his inputs locked,
;;; a stunned victim behind whom she reappears, and half the flash-step back. Then she cashes the stun with her own ice.
;;; Every chance is per difficulty (EASY <= NORMAL <= HARD; NORMAL near the shipped CPU, HARD the full version).
(defparameter *ai-ru-ph-breaker* '(:easy 0.0 :normal 0.05 :hard 0.95)
  "An incoming Breaker / Kikon rush (aura or dash): a Hoho timed into its strike (RUKIA-AI-PERFECT-HOHO), per phase of his.")
(defparameter *ai-ru-ph-move* '(:easy 0.0 :normal 0.02 :hard 0.8)
  "A committed K / L / SP of his whose hit window she can still reach in time: the timed Hoho, per move of his.")
(defparameter *ai-ru-ph-mash* '(:easy 0.0 :normal 0.02 :hard 0.8)
  "A J masher (AI-MASH-P) recovering from his J: the Hoho timed into the next J he will press, per J of his.")
(defparameter *ai-ru-ph-move-fs* 60.0
  "The flash-step a Hoho on a K / L / SP of his leaves untouched below (one Hoho kept for a Breaker; a masher's J spends it all).")
(defparameter *ai-ru-ph-cash* '(:easy 0.0 :normal 0.05 :hard 0.9)
  "A stunned opponent within SHIRAFUNE's line whose stun outlasts its startup (the counter of a perfect Hoho ...): SP2.")

(defun rukia-ai-perfect-hoho (e b s d)
  "The timed Hoho (:hoho), :wait while his hit window is still to come (nothing pressed: a guard would be broken, a J1
early would be beaten), or NIL. From the perceived SNAP S (DELAY frames old): a Breaker's aura ends *BREAKER-AURA* after it
began (SNAP-START is exact), its dash closes at BREAKER-SPEED, its strike is perfect-able from *BREAKER-TRIGGER* + 0.5 m
through its startup; a committed move's window is SNAP-S .. SNAP-ACTIVE-END of his move frame (now SNAP-SF + DELAY); a J
masher restarts his J as soon as his recovering one ends. A Hoho started inside *PERFECT-LEAD* of the window is PERFECT."
  (let* ((g (gauges e)) (dl (brain-delay b)) (el (- *match-tick* (snap-start s)))
         (roll (brain-react-roll b)) (fs (gauges-fs g)))
    (when (and (hoho-open-p e)
               (ai-hoho-spare-p fs (gauges-reishi g) (gauges-reishi-max g)))
      (flet ((go-when (frames-to-window into)          ; pressed INTO frames inside the window (a frame or two of slack)
               (if (<= frames-to-window (- into)) (why b :perfect-hoho :hoho) (why b :ph-wait :wait))))
        (case (snap-kind s)
          (:breaker
           (when (< roll (ai-chance e *ai-ru-ph-breaker*))
             (let ((v (/ (breaker-speed 20) 60.0)) (win (+ *breaker-trigger* 0.5)))
               (case (snap-phase s)
                 (:aura (when (< d 7.0)
                          (go-when (+ (- (1+ *breaker-aura*) el) (max 0.0 (/ (- d win) v))) 2)))
                 (:dash (when (< d 8.0) (go-when (/ (- d win (* v dl)) v) 2)))
                 (:main (when (< (+ (snap-sf s) dl) (snap-active-end s)) (go-when 0 0)))))))
          (:kikon                                    ; (a rush module's speed is its own: its dash seen within 3 m)
           (when (and (< roll (ai-chance e *ai-ru-ph-breaker*)) (member (snap-phase s) '(:dash :main)) (< d 3.5)
                      (or (eq (snap-phase s) :dash) (< (+ (snap-sf s) dl) (snap-active-end s))))
             (go-when 0 0)))
          ((:flash :sig :sp)
           (when (and (eq (snap-phase s) :main) (plusp (snap-reach s)) (> (snap-active-end s) (snap-s s))   ; (a hit of its own)
                      (snap-near-p s e d 0.7) (not (snap-reflect-p s))   ; (an :x-axis line: on it; a reflect: ai.lisp)
                      (>= fs *ai-ru-ph-move-fs*)
                      (< roll (ai-chance e *ai-ru-ph-move*)))
             (let ((lead (- (snap-s s) (snap-sf s) dl)))
               (when (and (< (+ (snap-sf s) dl 1) (snap-active-end s)) (<= lead 40))
                 (go-when (- lead *perfect-lead*) 3)))))
          (:quick
           (when (and (ai-mash-p b) (eq (snap-phase s) :main) (>= (+ (snap-sf s) dl) (snap-active-end s)) (< (snap-left s) 99)
                      (< d (+ (snap-reach s) 1.0)) (< roll (ai-chance e *ai-ru-ph-mash*)))
             (go-when (- (+ (- (snap-left s) dl) (snap-s s)) *perfect-lead*) 1))))))))

(defparameter *ai-ru-cash-o* '(:easy 0.0 :normal 0.02 :hard 0.9)
  "A stun neither SHIRAFUNE (no bar) nor the band's disc L can cash, short but long enough for her O (the Shikai's ENBU
rush: aura + its dash + S): the O, not a J string, per stun (the cash roll's share).")

(defun rukia-ai-o-lands-p (mv d left)
  "Does O move MV, pressed now at D m, strike within LEFT frames: its aura, its dash into its reach, its startup (a
lane module without a dash: aura + S, D within its lane)?"
  (let ((sp (/ (or (rush-param mv :speed) 0.0) 60.0)) (gap (- d (mv-reach mv) -0.3)))
    (and (or (plusp sp) (< d (mv-reach mv)))
         (>= left (+ (or (rush-param mv :aura) 0) (mv-s mv) 1 (if (and (plusp sp) (plusp gap)) (ceiling gap sp) 0))))))

(defun rukia-ai-cash (e b s d)
  "A stunned opponent (a perfect Hoho's counter, a freeze, a crumple) whose stun, as seen, outlasts the startup of her
ice: SHIRAFUNE within its line (bars and the kit's reserve permitting), else the band's disc L (SHIMOBASHIRA / HYOSHIN /
REIDO) within its radius, else (a stun only) her O when it strikes in time (RUKIA-AI-O-LANDS-P: the Shikai's ENBU after
a perfect Hoho's counter with no bar left, where a J string went before). A command or NIL."
  (let* ((kit (kit-of e)) (sp2 (kit-command-move kit :sp2)) (l (kit-command-move kit :sig))
         (left (snap-left-seen s b)))
    (flet ((lands (mv) (>= left (+ (mv-s mv) (getf (mv-params mv) :delay 0) 1))))   ; (TSUKISHIRO: its pillar's delay)
      (when (and (or (eq (snap-state s) :stun)
                     (and (eq (snap-state s) :move) (eq (snap-phase s) :main) (< (snap-left s) 99)   ; his recovery
                          (>= (+ (snap-sf s) (brain-delay b)) (snap-active-end s))
                          (not (ai-mash-p b))))         ; (a masher's next J comes out of it at once: the Hoho's)
                 (< (brain-react-roll b) (ai-chance e *ai-ru-ph-cash*)))
        (cond ((and sp2 (< 0.5 d (- (mv-reach sp2) 0.5)) (lands sp2) (kit-command-ok-p e :sp2)
                    (>= (reiatsu-bars e) (ai-table e :sp-cancel-bars 1)))
               (why b :ice-cash :sp2))
              ((and l (getf (mv-params l) :radius) (< d (- (getf (mv-params l) :radius) 0.4)) (lands l)
                    (kit-command-ok-p e :sig))
               (why b :ice-cash :sig))
              ((let ((o (kit-command-move kit :kikon)))
                 (and o (eq (snap-state s) :stun) (not (ai-sb-finish-p e)) (kit-command-ok-p e :kikon)
                      (rukia-ai-o-lands-p o d left) (< (brain-react-roll b) (ai-chance e *ai-ru-cash-o*))))
               (why b :o-cash :kikon)))))))

(defparameter *ai-ru-zone-kido* '(:easy 0.0 :normal 0.05 :hard 0.3)
  "A Shikai neutral decision at 3-6.5 m: SP1's kido (SOKATSUI tapped within *AI-RU-SP1-FAR*, RIKUJOKORO held beyond:
RUKIA-AI-SP1-HOLD) instead of the table's pick, per decision (HAKUREN's wave at 5-11 m before 2026-10-24: :hard 0.5).")
(defparameter *ai-ru-sp2-layers* '(:easy 0.0 :normal 0.1 :hard 0.35)
  "A Shikai neutral decision with >= 2 霜の層 on him inside SHIRAFUNE's line: SP2 (it bursts them all: 110 + 25 a layer),
per decision (new 2026-10-24).")
(defparameter *ai-ru-burst-1* '(:easy 0.0 :normal 0.05 :hard 0.15)
  "Her CPU's L off a J1 / K1 that hit with >= 1 layer on him (霜散 / 氷礫: the string ends there), per hit (new 2026-10-24).")
(defparameter *ai-ru-burst-2* '(:easy 0.05 :normal 0.2 :hard 0.4)
  "... off a J2 / K2 with >= 2 layers (雪煙 / 氷柱), per hit (new 2026-10-24).")
(defparameter *ai-ru-burst-3* '(:easy 0.2 :normal 0.5 :hard 0.85)
  "... off a J3 / K3 (霜陣 / 白漣: every layer), per hit (new 2026-10-24).")
(defparameter *ai-ru-l-far* 6.0 "Her CPU's L beyond this (m) is held (TSUKISHIRO), nearer tapped (BYAKURAI's 6 m line; new 2026-10-24).")
(defparameter *ai-ru-sp1-far* 4.5 "Her CPU's SP1 beyond this (m) is held (RIKUJOKORO), nearer tapped (SOKATSUI's 5 m cone; new 2026-10-24).")

(defun rukia-ai-burst-p (e link l)
  "The Shikai's :l-after-k / :l-after-j (ai.lisp STRING-REFLEX, AUTO COMBO's too): the chance of L, burst L, off LINK's
hit by its link number (L's :burst) and the layers on him: link 3 *AI-RU-BURST-3*, link 2 with >= 2 layers
*AI-RU-BURST-2*, link 1 *AI-RU-BURST-1* (rolled once per hit; no layer: RUKIA-OK refuses it anyway)."
  (declare (ignore link))
  (let ((n (getf (mv-params l) :burst)) (layers (fighter-layers (fighter (opp-of e)))))
    (cond ((or (null n) (zerop layers)) 0.0)
          ((>= n 3) (ai-chance e *ai-ru-burst-3*))
          ((= n 2) (if (>= layers 2) (ai-chance e *ai-ru-burst-2*) 0.0))
          (t (ai-chance e *ai-ru-burst-1*)))))

(defun rukia-ai-sig-hold (kit d &optional e)
  "The Shikai's :sig-hold (ai.lisp AI-COMMAND): frames L is held: beyond *AI-RU-L-FAR* TSUKISHIRO (held past *RU-L-HOLD*),
nearer a tap (BYAKURAI)."
  (declare (ignore kit e))
  (if (> d *ai-ru-l-far*) (+ *ru-l-hold* 4) 1))

(defun rukia-ai-sp1-hold (kit d &optional e)
  "The Shikai's :sp1-hold (ai.lisp AI-COMMAND): frames SP1 is held: beyond *AI-RU-SP1-FAR* RIKUJOKORO (to its hold's end),
nearer a tap (SOKATSUI)."
  (declare (ignore e))
  (if (> d *ai-ru-sp1-far*) (+ 2 (second (mv-hold (kit-command-move kit :sp1)))) 1))

(defun rukia-ai-zone (e b s d)
  "Her Shikai's neutral decision (one roll a decision): with >= 2 layers on him inside SHIRAFUNE's line, SP2
(*AI-RU-SP2-LAYERS*); else at 3-6.5 m the kido (SP1: AI-COMMAND's tap / hold by RUKIA-AI-SP1-HOLD, *AI-RU-ZONE-KIDO*). A
command or NIL."
  (declare (ignore s))
  (when (and (<= (brain-decide-t b) 1) (eq (kit-form (kit-of e)) :base))
    (let ((cmd (cond ((and (>= (fighter-layers (fighter (opp-of e))) 2) (< 1.5 d 4.6) (kit-command-ok-p e :sp2) (rukia-ai-bars-p e)
                           (let ((p (ai-chance e *ai-ru-sp2-layers*))) (and (plusp p) (< (sim-rnd01) p))))
                      :sp2)
                     ((and (<= 3.0 d 6.5) (kit-command-ok-p e :sp1)
                           (let ((p (ai-chance e *ai-ru-zone-kido*))) (and (plusp p) (< (sim-rnd01) p))))
                      :sp1))))
      (when cmd
        (setf (brain-decide-t b) (ai-decide-time e b))   ; (the next decision, as AI-NEUTRAL times it)
        (pace e (if (eq cmd :sp2) :ai-sp2-layers :ai-kido))
        (why b (if (eq cmd :sp2) :sp2-layers :zone-kido) cmd)))))

;;; ---------------------------------------------------------------- absolute zero (round 2): REIDO is her answer
;;; Rooted, no Hoho: the shipped CPU at zero only answered with J / K (the ward's freeze-touch was followed up by a J1
;;; string 20 f late, a Breaker met with J1). At zero what touches the ward is answered at once with REIDO TOKETSU (her
;;; own ward's block is felt, no perception delay: the frozen attacker is still frozen at its f10), and a Breaker's dash
;;; is met by the disc (a counter-hit on the dash, docs/duel/DUEL_RUKIA.md 4.4) instead of J1. REIDO cashes the top bar (back
;;; to -50), which a CRACK would empty entirely anyway.
(defparameter *ai-ru-z-ward-reido* '(:easy 0.0 :normal 0.02 :hard 0.9)
  "Absolute zero: the ward just blocked a hit within REIDO's radius - 0.5 (the first melee one froze him): REIDO, per block.")
(defparameter *ai-ru-z-ward-window* 24
  "Ticks after the ward's block within which she still answers it (the block's and the freeze's hitstops pass first).")
(defparameter *ai-ru-z-anti-breaker* '(:easy 0.0 :normal 0.05 :hard 0.9)
  "Absolute zero: a Breaker whose dash reaches REIDO's radius - 0.5 at its f10 (or its aura seen inside it): REIDO, per phase.")

(defun rukia-ai-zero (e b s d)
  "Zero's answers (RUKIA-AI-REFLEX at :zero): REIDO on a ward block up close (felt at once), REIDO timed on a Breaker's
aura / dash (its disc active at the move's S, him inside radius - 0.5 by then). A command or NIL."
  (let* ((f (fighter e)) (l (kit-command-move (kit-of e) :sig)) (r (- (getf (mv-params l) :radius 5.5) 0.5)))
    (when (kit-command-ok-p e :sig)
      (cond ((and (passive-p e :ward) (<= (- *match-tick* (fighter-warded f)) *ai-ru-z-ward-window*) (< (fighter-dist f) r)
                  (< (brain-react-roll b) (ai-chance e *ai-ru-z-ward-reido*)))     ; (one roll per action of his)
             (why b :ward-reido :sig))
            ((and (eq (snap-kind s) :breaker) (< (brain-react-roll b) (ai-chance e *ai-ru-z-anti-breaker*))
                  (case (snap-phase s)
                    (:aura (< d r))
                    (:dash (<= (- d (* (/ (breaker-speed 20) 60.0) (+ (brain-delay b) (mv-s l)))) r))))
             (why b :anti-breaker-reido :sig))))))

(defparameter *ai-ru-band-disc* '(:easy 0.0 :normal 0.0 :hard 0.5)
  "-18 / -50: a neutral decision with him inside the band's L disc (radius - 0.6), not guarding and not attacking: the
disc (SHIMOBASHIRA / HYOSHIN, cold permitting) instead of the table's pick, per decision.")

(defun rukia-ai-band-disc (e b s d)
  "Her bands' neutral decision up close at HARD half the time: the band's L disc round her (its stagger / crumple then
cashed in ice: RUKIA-AI-CASH). A command or NIL."
  (let ((l (kit-command-move (kit-of e) :sig)))
    (when (and (<= (brain-decide-t b) 1) (member (kit-form (kit-of e)) '(:m18 :m50))
               (< d (- (getf (mv-params l) :radius 0.0) 0.6))
               (or (member (snap-state s) '(:idle :run))
                   (snap-recovering-p s))
               (kit-command-ok-p e :sig)
               (let ((p (ai-chance e *ai-ru-band-disc*))) (and (plusp p) (< (sim-rnd01) p))))
      (setf (brain-decide-t b) (ai-decide-time e b))
      (why b :band-disc :sig))))

(defun rukia-ai-reflex (e b s d)
  "Her forms' :reflex: the timed Hoho (RUKIA-AI-PERFECT-HOHO); the stun / recovery cashed with her ice, a stun with no
bar for it with her O (RUKIA-AI-CASH); at -50 the Hoho in (RUKIA-AI-HOHO-IN); the Shikai's neutral decision
(RUKIA-AI-ZONE). A command or NIL. (Her ender confirms are b0a0's
RUKIA-AI-SP-ENDER; b0a0's anti-Breaker J1 and guard break cost strength on top of this and were dropped.) The Shikai's
neutral pick (RUKIA-AI-ZONE) since 2026-10-24: SP2 at >= 2 layers, the kido at 3-6.5 m."
  (or (and (eq (kit-form (kit-of e)) :zero) (rukia-ai-zero e b s d))
      (rukia-ai-perfect-hoho e b s d)
      (rukia-ai-cash e b s d)
      (and (eq (kit-form (kit-of e)) :m50) (rukia-ai-hoho-in e b s d))
      (rukia-ai-zone e b s d)
      (rukia-ai-band-disc e b s d)))

;;; ---------------------------------------------------------------- her own BRAIN-STEP steps (ai.lisp *AI-STEPS*, 2026-10-25:
;;; 「請調查原因並修復你說的兩個問題」, then 「請逐步將共用 AI 的功能轉移給專屬 AI」 / 「只修露琪亞專屬 AI」; DUEL_RUKIA_TYBW §17.6)
(defun rukia-ai-block-hold (e b f)
  "Her :block-hold step: the generic chance and length (AI-BLOCK-HOLD), the press tagged :block-hold for her :held step."
  (when (ai-block-hold e b f) (setf (brain-act b) :block-hold)))

(defun rukia-ai-held (e b f)
  "Her :held step, before every other choice. Under a Kikon lock 1 (a follow-up coming, she isn't red) only the guard works:
a guard she holds stays held (T), so no reflex lets it go on the strike's frame (her perfect Hoho pressed Step there: the
Kikon landed through her guard, 45 of 46). Her post-block hold (:block-hold) ends on the blockstun's last step once
nothing is left to chain (FIGHTER-GLOCK off): she comes out in neutral, not back in a guard (*GUARD-EXIT*), and the block
punish and her reflexes run on the next step (NIL: the step goes on)."
  (declare (ignore e))
  (let ((held (> (brain-press-left b) 0)))
    (cond ((and held (= (fighter-kikon-lock f) 1) (eq (brain-press b) :guard))
           (decf (brain-press-left b))
           t)
          ((and held (eq (brain-act b) :block-hold)
                (not (and (eq (fighter-state f) :guard-hit)
                          (or (fighter-glock f) (< (1+ (fighter-sf f)) (fighter-stun f))))))
           (setf (brain-press-left b) 0)
           nil))))

(defun rukia-assist-guard (e b s d)
  "Her forms' :assist-guard (assist.lisp AUTO GUARD): her defensive answers only, REIDO at zero (a ward block, a Breaker)
and the timed Hoho."
  (or (and (eq (kit-form (kit-of e)) :zero) (rukia-ai-zero e b s d))
      (rukia-ai-perfect-hoho e b s d)))

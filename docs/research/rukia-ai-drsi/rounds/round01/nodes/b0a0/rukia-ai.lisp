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
       :ranges (:approach (2.8 5.0) :pressure (1.0 2.4) :zone (5.0 7.5) :defend (3.5 6.0) :poke (2.1 2.8) :mid (3.0 5.0))
       :moves ((0.0 1.8 :q 6 :f 2 :breaker 1 :sp2 1)                   ; J up close only (DUEL_STRINGS §13), K beyond
               (1.8 2.8 :f 4 :breaker 1 :sp2 1)
               (2.8 5.0 :f 1 :sp2 2 :sig 2 :sp1 1 :kikon 1 :step 1)
               (5.0 8.0 :sig 4 :sp1 1 :kikon 2 :step 1)
               (8.0 99.0 :kikon 2 nil 2))
       :guard 0.4 :hoho 0.35 :sp-cancel-bars 1 :dash 0.5 :dash-back 0.4 :kikon-range 8.0
       :stun-follow (:sp2 2.4 5.0) :awaken (:melee-share 0.6 :min-taken 150)
       :l-after-k rukia-ai-burst-p :l-after-j rukia-ai-burst-p :sig-hold rukia-ai-sig-hold :sp1-hold rukia-ai-sp1-hold
       :sp-ender rukia-ai-sp-ender :reflex rukia-ai-reflex :assist-guard rukia-assist-guard
       :string-k 0.9 :o-ender 0.0)
  "Her base form's CPU (the kit's :ai: ai.lisp; DUEL_RUKIA_TYBW §17).")
(defparameter *ru-ai-m18*
  `(:intents (:approach 2 :pressure 3 :zone 1 :defend 2)
       :ranges (:approach (2.5 4.5) :pressure (1.0 2.2) :zone (4.5 7.0) :defend (3.0 5.0))
       :moves ((0.0 1.8 :q 5 :f 2 :breaker 1 :sig 1)
               (1.8 2.8 :f 3 :breaker 1 :sig 1)
               (2.8 5.0 :sp2 2 :step 1 nil 2)
               (5.0 99.0 :sp1 2 nil 2))
       :guard 0.5 :hoho 0.3 :dash 0.2 :dash-back 0.2 :o-ender 0.0 :string-k 0.9 :l-after-k ,*ai-ru-l-after-k-awake* :kikon-range 6.5 :sp-cancel-bars 2
       :cool (:p 0.3 :near 3.5) :stun-follow (:sp2 2.4 5.0) :sp-ender rukia-ai-sp-ender :reflex rukia-ai-reflex :assist-guard rukia-assist-guard)
  "Her m18 form's CPU (the kit's :ai: ai.lisp; DUEL_RUKIA_TYBW §17).")
(defparameter *ru-ai-m50*
  `(:intents (:approach 1 :pressure 3 :zone 0 :defend 2)
       :ranges (:approach (2.0 3.5) :pressure (1.0 2.3) :zone (3.0 5.0) :defend (2.0 3.5))
       :moves ((0.0 1.9 :q 4 :f 2 :sig 3)
               (1.9 3.5 :f 3 :sig 3)
               (3.5 99.0 :sp2 1 :sp1 1 nil 2))
       :guard 0.45 :hoho 0.25 :dash 0.1 :dash-back 0.1 :o-ender 0.0 :string-k 0.9 :l-after-k ,*ai-ru-l-after-k-awake* :kikon-range 7.5 :sp-cancel-bars 2
       :cool (:p 0.35 :near 4.0 :no-projectile t :min-gg 50) :stun-follow (:sp2 2.4 6.0) :reflex rukia-ai-reflex :assist-guard rukia-assist-guard
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
       :guard 0.0 :hoho 0.0 :o-ender 0.0 :string-k 0.9 :l-after-k ,*ai-ru-l-after-k-awake* :kikon-range 9.0 :sp-cancel-bars 2
       :brace (:p 0.2 :near 5.5 :min-gg 30) :opp-intent (:zone 2 :defend 2) :sp-ender rukia-ai-sp-ender
       :reflex rukia-ai-reflex :assist-guard rukia-assist-guard)
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
(defparameter *ai-ru-k-ender-l* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "A landed ender: the share of RUKIA-AI-SP-ENDER's payoff pick its cash-outs get (the rest: the string just ends), per
ender hit (cell b0a0: 0 / 0.02 / 0.9 the band's L, with SHIRAFUNE and the O ender beside it, before).")
(defun rukia-ai-bars-p (e)
  "Bars enough for an SP and the kit's reserve (:sp-cancel-bars) after it."
  (>= (reiatsu-bars e) (ai-table e :sp-cancel-bars 1)))
(defparameter *ai-ru-bind-bar* 1
  "The Shikai's SHIRAFUNE / SOKATSUI leave this many bars for RIKUJOKORO (its bind -> O: the Kikon; cell b0a0).")
(defun rukia-ai-sp2-bars-p (e)
  "Bars for a Shikai SHIRAFUNE / SOKATSUI with *AI-RU-BIND-BAR* kept for the bind (the bands: RUKIA-AI-BARS-P)."
  (>= (reiatsu-bars e) (+ (ai-table e :sp-cancel-bars 1) (if (eq (kit-form (kit-of e)) :base) *ai-ru-bind-bar* 0))))

(defparameter *ai-ru-cf-orange-fs* 85.0
  "Her ORANGE restart off an ender only with this much flash-step (70 starts it; the rest keeps a Hoho for his answer; cell b0a0).")

(defun rukia-ai-ender-weights (e kit name)
  "The payoff weights of what ends the string at ender NAME's hit (cell b0a0, the catalogues' numbers): :l the burst / the
band's L (the Shikai's K3 + L 白漣 331 and its knockdown, J3 + L 霜陣 178; the bands' K3 + L 285 / 349 / 512), :sp2
SHIRAFUNE (393 at 3 layers off the Shikai's K string: 1 + 2 a layer; the bands' 350-575), :sp1 the bands' wave held (306-608),
:orange the ORANGE restart (416: the scaling restarts, every hit under it signature), :end nothing (a J3 ends +5, kept: the
O ender into his guard was punished). Never the O on a victim who isn't red (the generic O ender has a red one first)."
  (let* ((o (opp-of e)) (base (eq (kit-form kit) :base)) (layers (fighter-layers (fighter o)))
         (l (kit-l-link kit name)) (k (kit-k-link-p kit name)) (bars (rukia-ai-bars-p e)))
    (list :l (if (and l (kit-command-ok-p e :sig kit nil l) (or (not base) (plusp layers))) (if k 6 2) 0)
          :sp2 (if (and (rukia-ai-sp2-bars-p e) (kit-command-ok-p e :sp2) (not (and (kit-rooted kit) (not k)))) (if base (+ 1 (* 2 layers)) 4) 0)
          :sp1 (if (and k (not base) bars (kit-command-ok-p e :sp1)) 3 0)
          :orange (if (and k (eq (burst-ok-p e) :orange) (>= (gauges-fs (gauges e)) *ai-ru-cf-orange-fs*)
                           (eq (state-of o) :stun) (< (fighter-dist (fighter e)) 3.0))
                      3 0)
          :end (if k 1 3))))

(defun rukia-ai-sp-ender (e kit)
  "Her :sp-ender (ai.lisp STRING-REFLEX; a landed ender, no link after it, L not taken): one payoff-weighted pick of
RUKIA-AI-ENDER-WEIGHTS but its :l (the Shikai's L is RUKIA-AI-BURST-P's, the bands' L too: their K3 + L here), nothing
weighing more the lower the difficulty (*AI-RU-K-ENDER-L* the share it decides). A command, :WAIT (the string ends), NIL."
  (let* ((name (mv-name (fighter-move (fighter e)))) (w (rukia-ai-ender-weights e kit name)) (p (ai-chance e *ai-ru-k-ender-l*)))
    (when (eq (kit-form kit) :base) (setf (getf w :l) 0))
    (incf (getf w :end) (* 8.0 (- 1.0 p)))
    (case (apply #'weighted-pick (sim-rnd01) w)
      (:l :sig) (:sp2 :sp2) (:sp1 :sp1) (:orange :burst) (t :wait))))

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
        (cond ((and (eq (kit-form kit) :base) (rukia-ai-cash-pick e b s d left)))
              ((and sp2 (< 0.5 d (- (mv-reach sp2) 0.5)) (lands sp2) (kit-command-ok-p e :sp2)
                    (>= (reiatsu-bars e) (ai-table e :sp-cancel-bars 1)))
               (why b :ice-cash :sp2))
              ((and l (getf (mv-params l) :radius) (< d (- (getf (mv-params l) :radius) 0.4)) (lands l)
                    (kit-command-ok-p e :sig))
               (why b :ice-cash :sig))
              ((let ((o (kit-command-move kit :kikon)))
                 (and o (eq (snap-state s) :stun) (not (ai-sb-finish-p e)) (kit-command-ok-p e :kikon)
                      (rukia-ai-o-lands-p o d left) (< (brain-react-roll b) (ai-chance e *ai-ru-cash-o*))))
               (why b :o-cash :kikon)))))))

(defun rukia-ai-cash-pick (e b s d left)
  "The Shikai's cash-out of a stun / recovery LEFT frames long as seen, by payoff weight (cell b0a0, the catalogue: J1 / K1
open the K string and its burst, 300-331 with no bar; SHIRAFUNE 110 + 25 a layer for a bar; RIKUJOKORO when the stun
outlasts its bind, the seal then the Kikon; BYAKURAI's 45 from afar; the O last, its follow-up guarded): one weighted
roll. A command or NIL (none lands: the old order)."
  (let* ((kit (kit-of e)) (layers (fighter-layers (fighter (opp-of e)))) (stun (eq (snap-state s) :stun)) (bars (rukia-ai-bars-p e)))
    (flet ((can (c lo hi extra) (let ((mv (kit-command-move kit c)))
                                  (and mv (<= lo d hi) (>= left (+ (mv-s mv) extra 1)) (kit-command-ok-p e c)))))
      (let ((opt (weighted-pick (sim-rnd01)
                                :q (if (can :q 0.0 (+ (mv-reach (kit-command-move kit :q)) 0.5) 0) 6 0)
                                :f (if (can :f 1.2 (+ (mv-reach (kit-command-move kit :f)) 0.2) 0) 6 0)
                                :sp2 (if (and (rukia-ai-sp2-bars-p e) (can :sp2 0.5 4.5 0)) (+ 2 (* 2 layers)) 0)
                                :rikujo (if (and bars (can :sp1 2.5 5.8 (+ 16 *ai-ru-rikujo-hold* 16))) 6 0)
                                :byakurai (if (can :sig 2.0 6.0 0) 1 0)
                                :kikon (if (and stun (not (ai-sb-finish-p e)) (kit-command-ok-p e :kikon)
                                                (rukia-ai-o-lands-p (kit-command-move kit :kikon) d left))
                                           1 0))))
        (case opt
          ((:q :f :sp2) (why b :ice-cash opt))
          (:rikujo (why b :ice-cash (rukia-ai-plan! e :hold :sp1)))
          (:byakurai (why b :ice-cash (rukia-ai-plan! e :tap :sig)))
          (:kikon (why b :o-cash :kikon)))))))

(defparameter *ai-ru-zone-kido* '(:easy 0.0 :normal 0.05 :hard 0.3)
  "A Shikai neutral decision at 3-6.5 m: SP1's kido (SOKATSUI tapped within *AI-RU-SP1-FAR*, RIKUJOKORO held beyond:
RUKIA-AI-SP1-HOLD) instead of the table's pick, per decision (HAKUREN's wave at 5-11 m before 2026-10-24: :hard 0.5).")
(defparameter *ai-ru-sp2-layers* '(:easy 0.0 :normal 0.1 :hard 0.35)
  "A Shikai neutral decision with >= 2 霜の層 on him inside SHIRAFUNE's line: SP2 (it bursts them all: 110 + 25 a layer),
per decision (new 2026-10-24).")
(defparameter *ai-ru-burst-1* '(:easy 0.0 :normal 0.03 :hard 0.05)
  "Her CPU's L off a J1 / K1 that hit with >= 1 layer on him (霜散 / 氷礫: the string ends there), per hit (new 2026-10-24).")
(defparameter *ai-ru-burst-2* '(:easy 0.0 :normal 0.03 :hard 0.05)
  "... off a J2 / K2 with >= 2 layers (雪煙 / 氷柱), per hit (new 2026-10-24).")
(defparameter *ai-ru-burst-3* '(:easy 0.3 :normal 0.7 :hard 1.0)
  "... off a J3 / K3 (霜陣 / 白漣: every layer), per hit (new 2026-10-24).")
(defparameter *ai-ru-l-far* 6.0 "Her CPU's L beyond this (m) is held (TSUKISHIRO), nearer tapped (BYAKURAI's 6 m line; new 2026-10-24).")
(defparameter *ai-ru-sp1-far* 4.5 "Her CPU's SP1 beyond this (m) is held (RIKUJOKORO), nearer tapped (SOKATSUI's 5 m cone; new 2026-10-24).")

(defun rukia-ai-burst-p (e link l)
  "The Shikai's :l-after-k / :l-after-j (ai.lisp STRING-REFLEX, AUTO COMBO's too): the chance of L, burst L, off LINK's
hit (rolled once per hit; no layer: 0, RUKIA-OK refuses it anyway). At an ender (L's :burst 3) the burst's share of the
ender's payoff weights (RUKIA-AI-ENDER-WEIGHTS: 白漣 against SHIRAFUNE, ORANGE, nothing) x *AI-RU-BURST-3*; at link 1 / 2
*AI-RU-BURST-1* / -2* (the K string goes on instead: :string-k; cell b0a0)."
  (let ((n (getf (mv-params l) :burst)) (layers (fighter-layers (fighter (opp-of e)))))
    (cond ((or (null n) (zerop layers)) 0.0)
          ((>= n 3) (let* ((w (rukia-ai-ender-weights e (kit-of e) (mv-name link)))
                           (sum (loop for (nil v) on w by #'cddr sum v)))
                      (if (plusp sum) (* (ai-chance e *ai-ru-burst-3*) (/ (getf w :l) sum)) 0.0)))
          ((= n 2) (if (>= layers 2) (ai-chance e *ai-ru-burst-2*) 0.0))
          (t (ai-chance e *ai-ru-burst-1*)))))

(defun rukia-ai-sig-hold (kit d &optional e)
  "The Shikai's :sig-hold (ai.lisp AI-COMMAND): frames L is held: beyond *AI-RU-L-FAR* TSUKISHIRO (held past *RU-L-HOLD*),
nearer a tap (BYAKURAI)."
  (declare (ignore kit))
  (if (case (rukia-ai-plan-hold e) (:hold t) (:tap nil) (t (> d *ai-ru-l-far*))) (+ *ru-l-hold* 4) 1))

(defun rukia-ai-sp1-hold (kit d &optional e)
  "The Shikai's :sp1-hold (ai.lisp AI-COMMAND): frames SP1 is held: beyond *AI-RU-SP1-FAR* RIKUJOKORO (to its hold's end),
nearer a tap (SOKATSUI); her matchup decision says which (RUKIA-AI-PLAN-HOLD). Held: *AI-RU-RIKUJO-HOLD* past the 16 f (the bind longer)."
  (if (case (rukia-ai-plan-hold e) (:hold t) (:tap nil) (t (> d *ai-ru-sp1-far*)))
      (+ (second (mv-hold (kit-command-move kit :sp1))) *ai-ru-rikujo-hold*) 1))

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

;;; ---------------------------------------------------------------- cell b0a0 (round 1): the matchup tables
;;; The opponent and his form decide her plan (the user 2026-10-25: 「請先以每個角色的幀數表、攻防距離等等資訊為基礎來規劃策略」).
;;; His threat distances come from his kit as it is now (RUKIA-AI-HIS: his J1's lunge, its startup, his K1's far edge;
;;; docs/research/rukia-cpu/matchups-shikai.md): her zones are cut against them; his character picks the table of payoff
;;; weights per zone (*AI-RU-MU*), multiplied by what she sees him do (locked in a move or a stance, guarding, running in,
;;; down) and her resources (bars, his layers). One weighted roll a neutral decision (SIM-RND01), the share of decisions it
;;; takes by difficulty (*AI-RU-MU-P*); the confirm off a landed link by the catalogue's damage (:string-k, RUKIA-AI-BURST-P,
;;; RUKIA-AI-SP-ENDER); RIKUJOKORO's bind cashed with the O (RUKIA-AI-SEAL-O: the seal's Kikon).
(defparameter *ai-ru-mu-p* '(:easy 0.0 :normal 0.35 :hard 1.0)
  "A Shikai neutral decision (or an intent re-pick) taken by her matchup table (RUKIA-AI-MU-DECIDE, RUKIA-AI-MU-INTENT)
instead of the generic one, per decision (cell b0a0).")
;; per opponent character: :intents (her intent weights; :poke / :mid are her own ranges, *RU-AI-BASE* :ranges) and the
;; weights per zone (RUKIA-AI-ZONE-OF: :close her J1, :his-j inside his J1's lunge but out of hers, :k her K1, :mid to
;; SHIRAFUNE's 5.3 m, :far to TSUKISHIRO's 8 m, :out beyond); an option missing from a character's zone takes *AI-RU-MU-DEFAULT*'s.
;; Options: :q J1, :f K1, :byakurai / :tsukishiro (L tap / hold), :sokatsui / :rikujo (SP1 tap / hold), :sp2 SHIRAFUNE,
;; :enbu O, :breaker, :guard, :back (a back dash), :in (a dash in), :wait.
(defparameter *ai-ru-mu-default*
  '(:intents (:approach 2 :pressure 3 :zone 2 :defend 1) :breaker-p 0.0
    :close (:q 6 :breaker 1 :f 1 :guard 1 :back 1)
    :his-j (:f 3 :back 2 :guard 2 :q 1)
    :k (:f 5 :byakurai 1 :guard 1 :wait 1)
    :mid (:byakurai 3 :rikujo 4 :sp2 1 :sokatsui 1 :tsukishiro 1 :in 1 :wait 2)
    :far (:tsukishiro 4 :enbu 1 :in 2 :wait 2)
    :out (:in 3 :enbu 1 :wait 1))
  "Her matchup table's default (cell b0a0): the Shikai's frame data against an average opponent.")
(defparameter *ai-ru-mu*
  '((:kenpachi                                   ; J1 7 f 2.2 m lunge (his first strike), K1 2.8 m, BUTTAGIRU 22 f: stay out
     :intents (:mid 3 :approach 2 :defend 2 :zone 1)
     :close (:q 3 :guard 3 :back 3 :breaker 1)
     :his-j (:back 4 :guard 3 :f 1)
     :k (:f 1 :back 3 :guard 2 :rikujo 1)
     :mid (:byakurai 1 :rikujo 6 :sokatsui 1 :tsukishiro 2 :wait 2)
     :far (:tsukishiro 3 :wait 3)
     :out (:wait 2 :in 1))
    (:barro                                      ; J1 6 f / J2 5 f, +0 blocked: never at J range; his K1 2.05 m < her 2.85
     :intents (:poke 4 :mid 2 :approach 1) :guard-on (:br-e-l1 :br-oe-l1)
     :close (:q 2 :breaker 1 :back 4 :guard 1)
     :k (:f 6 :guard 1 :back 1)
     :mid (:rikujo 5 :tsukishiro 2 :byakurai 3 :sp2 1 :in 2 :wait 1)
     :far (:tsukishiro 4 :in 3 :wait 1)
     :out (:in 4 :enbu 1))
    (:hisagi                                     ; J1 8 f but 1.7 m, K1 6 m (the chain), RAIDEN 6.5 m: in close or out far
     :intents (:pressure 3 :zone 2 :approach 1)
     :close (:q 6 :breaker 1 :guard 1)
     :his-j (:back 2 :guard 2 :q 1)
     :k (:f 1 :byakurai 2 :guard 2 :back 1 :in 1)
     :mid (:byakurai 4 :tsukishiro 2 :rikujo 4 :guard 1 :in 1 :wait 1)
     :far (:tsukishiro 3 :wait 2 :in 1)
     :out (:in 2 :wait 1))
    (:yamamoto                                   ; J1 9 f: her J1 (7 f) wins up close; K1 2.6 m < her 2.85
     :intents (:pressure 3 :approach 2 :zone 1)
     :close (:q 7 :f 1)
     :k (:f 5 :byakurai 1 :in 1))
    (:ichigo :breaker-p 0.6)                     ; (her Breaker landed 39 of 60 against him, 15 of 18 against Senjumaru)
    (:senjumaru :breaker-p 0.7))
  "Her matchup tables (cell b0a0): per opponent character a plist over *AI-RU-MU-DEFAULT* (keys it lacks: the default's).")

(defvar *ru-ai-plan* (vector nil nil)
  "Per side: (tick . :tap / :hold), the hold her matchup decision chose for the L / SP1 it presses this tick (read by
RUKIA-AI-SIG-HOLD / -SP1-HOLD the same step, else the distance rule).")

(defun rukia-ai-mu (e key)
  "Her matchup table's KEY against E's opponent (his character's table, else the default)."
  (let ((row (rest (assoc (kit-character (kit-of (opp-of e))) *ai-ru-mu*))))
    (or (getf row key) (getf *ai-ru-mu-default* key))))

(defun rukia-ai-his-j (e)
  "His J1's threat from his kit as it is now (his form's): its far edge + its slide (at most 0.8 m), metres."
  (let ((q (kit-command-move (kit-of (opp-of e)) :q)))
    (if q (+ (move-edge q) (min 0.8 (mv-slide q))) 1.4)))

(defun rukia-ai-zone-of (e d)
  "Her zone at D m against E's opponent: :close (her J1), :his-j (inside his J1's lunge, RUKIA-AI-HIS-J, out of hers),
:k (her K1), :mid (to SHIRAFUNE's 5.3 m), :far (to TSUKISHIRO's 8 m), :out."
  (let ((tj (rukia-ai-his-j e)))
    (cond ((< d 1.6) :close)
          ((< d (max 1.6 (min tj 2.4))) :his-j)
          ((< d 2.9) :k)
          ((< d 5.3) :mid)
          ((< d 8.0) :far)
          (t :out))))

(defun rukia-ai-locked-p (s b n)
  "Is he, as perceived, held for at least N more frames (a move's recovery or a long move such as a stance, a stun)?"
  (and (member (snap-state s) '(:move :stun)) (< (snap-left s) 99) (>= (snap-left-seen s b) n)
       (or (eq (snap-state s) :stun) (not (snap-live-p s)))))

(defun rukia-ai-mu-weights (e b s d)
  "The weight plist of her options at D m: the zone's (RUKIA-AI-MU), each x what she sees and has (RUKIA-AI-MU-K), the
ones she can't press now 0."
  (let ((w (copy-list (or (rukia-ai-mu e (rukia-ai-zone-of e d)) '(:wait 1)))))
    (loop for (opt nil) on w by #'cddr do (setf (getf w opt) (* (getf w opt) (rukia-ai-mu-k e b s d opt))))
    (if (some #'plusp (loop for (nil v) on w by #'cddr collect v)) w '(:wait 1))))

(defun rukia-ai-mu-k (e b s d opt)
  "OPT's multiplier at D m: 0 when it can't start or can't reach; x4 a bind on him held >= 34 f (a stance, a recovery),
x2 on a guard; SHIRAFUNE x his layers + 1; J1 / the Breaker / TSUKISHIRO / the bind on what they beat."
  (let* ((layers (fighter-layers (fighter (opp-of e)))) (st (snap-state s))
         (guard (eq st :guard)) (down (member st '(:down :wakeup))) (run (eq st :run)))
    (flet ((ok (c) (kit-command-ok-p e c)) (reach (c) (mv-reach (kit-command-move (kit-of e) c))))
      (case opt
        (:q (if (and (ok :q) (<= d (+ (reach :q) 0.2)) (not down)) (if guard 0.5 1.0) 0.0))
        (:f (if (and (ok :f) (<= d (+ (reach :f) 0.3)) (not down)) (if run 1.5 1.0) 0.0))
        (:breaker (if (and (ok :breaker) (< d 1.3) (not down)) (* (rukia-ai-mu e :breaker-p) (if guard 4.0 0.3)) 0.0))
        (:byakurai (if (and (ok :sig) (<= 1.0 d 6.0) (not down)) (if run 2.0 1.0) 0.0))
        (:tsukishiro (if (and (ok :sig) (<= 3.0 d 8.0))
                         (cond (down 3.0) ((rukia-ai-locked-p s b 46) 4.0) (guard 1.5) (run 0.3) (t 1.0)) 0.0))
        (:sokatsui (if (and (ok :sp1) (rukia-ai-sp2-bars-p e) (<= 2.0 d 4.8) (not down)) (if run 1.5 1.0) 0.0))
        (:rikujo (if (and (ok :sp1) (rukia-ai-bars-p e) (<= 2.5 d 5.8) (not down))
                     (cond ((rukia-ai-locked-p s b 34) 4.0) (guard 2.0) (t 1.0)) 0.0))
        (:sp2 (if (and (ok :sp2) (rukia-ai-sp2-bars-p e) (< 1.5 d 4.8) (not down)) (+ 1.0 layers) 0.0))
        (:enbu (if (and (ok :kikon) (< d 8.0) (not down) (not (ai-sb-finish-p e))) 1.0 0.0))
        (:in (if (> d 2.5) 1.0 0.0))
        (:back (if (< d 3.0) 1.0 0.0))
        (t 1.0)))))

(defun rukia-ai-plan! (e hold cmd)
  "Note HOLD (:tap / :hold) for the L / SP1 pressed this tick (*RU-AI-PLAN*), CMD."
  (setf (svref *ru-ai-plan* (fighter-side (fighter e))) (cons *match-tick* hold))
  cmd)

(defun rukia-ai-plan-hold (e)
  "The hold her CPU chose this tick (:tap / :hold), or NIL; read once (cleared: a plan never outlives its press)."
  (let* ((side (and e (fighter-side (fighter e)))) (p (and side (svref *ru-ai-plan* side))))
    (when p (setf (svref *ru-ai-plan* side) nil))
    (and p (= (car p) *match-tick*) (cdr p))))

(defun rukia-ai-mu-press (e b d opt)
  "Her option OPT as a command (a dash pressed here: :PRESSED; a wait: NIL)."
  (case opt
    ((:q :f :sp2 :breaker :guard) opt)
    (:byakurai (rukia-ai-plan! e :tap :sig))
    (:tsukishiro (rukia-ai-plan! e :hold :sig))
    (:sokatsui (rukia-ai-plan! e :tap :sp1))
    (:rikujo (rukia-ai-plan! e :hold :sp1))
    (:enbu :kikon)
    (:in (ai-dash b 1.0 (max 2.6 (- d 3.0))) :pressed)
    (:back (ai-dash b -1.0 3.4) :pressed)
    (t nil)))

(defparameter *ai-ru-mu-guard-p* '(:easy 0.0 :normal 0.4 :hard 0.9)
  "One of his moves her matchup lists (:guard-on: a charged dash that closes from afar, outside the generic threat reach)
seen charging or coming within 25 m: a long guard, per move of his (RUKIA-AI-MU-GUARD; cell b0a0).")

(defun rukia-ai-mu-guard (e b s d)
  "His perceived move is one of her matchup's :guard-on (Lille's awakened dash L: 171 of its 311 starts hit her, 28
blocked, cell b0a0's logs; with this guard 262 / 520 of 40 matches) in its charge or before its hit, within 25 m: guard it
through (:GUARD-LONG), one roll per move of his (the brain's guard roll x *AI-RU-MU-GUARD-P*). A command or NIL."
  (let ((moves (rukia-ai-mu e :guard-on)) (mv (snap-move s)))
    (when (and moves mv (not (kit-rooted (kit-of e))) (eq (snap-state s) :move) (member (mv-name mv) moves) (< d 25.0)
               (or (eq (snap-phase s) :hold) (snap-live-p s)) (plusp (ai-guard-k e))
               (< (brain-guard-roll b) (ai-chance e *ai-ru-mu-guard-p*)))
      (why b :mu-guard :guard-long))))

(defun rukia-ai-mu-break (e b s d)
  "His long guard up close (the generic Breaker read's window, AI-REFLEX: held >= *AI-GUARD-BREAK-HOLD* within
*AI-GUARD-BREAK-RANGE*): her matchup decides it, one roll per guard episode (the brain's break key, so the generic roll
is not made again) *AI-RU-MU-P* of the episodes (the rest: the generic read's 0.4, which breaks Bankai West's ward at
NORMAL): the Breaker at her matchup's :breaker-p (cell b0a0's logs: it landed 65 / 83 % against Ichigo / Senjumaru, 0-18 %
against the rest, whose J1 meets its dash). A command or NIL."
  (when (and (eq (snap-state s) :guard) (>= (snap-guard-t s) *ai-guard-break-hold*) (< d *ai-guard-break-range*)
             (/= (brain-break-key b) (snap-start s)) (kit-command-move (kit-of e) :breaker))
    (setf (brain-break-key b) (snap-start s))
    (and (< (sim-rnd01) (if (< (sim-rnd01) (ai-chance e *ai-ru-mu-p*)) (rukia-ai-mu e :breaker-p) *ai-guard-break-p*))
         (kit-command-ok-p e :breaker) (why b :mu-break :breaker))))

(defun rukia-ai-mu-intent (e b)
  "At an intent re-pick (BRAIN-INTENT-T at 1: AI-NEUTRAL re-picks at 0), her matchup's intent weights instead
(*AI-RU-MU-P*; not on a low guard gauge: the generic zones then). Always NIL (it presses nothing)."
  (when (and (= (brain-intent-t b) 1) (eq (kit-form (kit-of e)) :base) (not (ai-gg-low-p e))
             (< (sim-rnd01) (ai-chance e *ai-ru-mu-p*)))
    (setf (brain-intent b) (or (apply #'weighted-pick (sim-rnd01) (rukia-ai-mu e :intents)) :approach)
          (brain-intent-t b) (1+ *ai-repick*)))
  nil)

(defun rukia-ai-mu-decide (e b s d)
  "Her Shikai's neutral decision by her matchup table (one roll at the decision: *AI-RU-MU-P*, then the weighted pick):
not on a red opponent (the generic rush has it), nor into a live attack of his (the generic guard / Hoho reflexes). A
command, :PRESSED, or NIL (a wait: the decision is made)."
  (when (and (<= (brain-decide-t b) 1) (eq (kit-form (kit-of e)) :base) (not (kikon-ready-p e))
             (not (and (eq (snap-state s) :move) (snap-live-p s)))
             (< (sim-rnd01) (ai-chance e *ai-ru-mu-p*)))
    (setf (brain-decide-t b) (ai-decide-time e b))
    (let ((opt (apply #'weighted-pick (sim-rnd01) (rukia-ai-mu-weights e b s d))))
      (pace e :ai-mu)
      (why b (or opt :mu-wait) (rukia-ai-mu-press e b d opt)))))

(defparameter *ai-ru-seal-o* '(:easy 0.3 :normal 0.8 :hard 1.0)
  "Her RIKUJOKORO bound him (his FIGHTER-SEAL: the bind seals him as red for a Kikon follow-up): the O, its follow-up the
Kikon from any health, per bind (cell b0a0: the cash pressed SHIRAFUNE into 60 % of her landed binds, the seal unused).")
(defparameter *ai-ru-rikujo-hold* 14
  "Frames her CPU holds RIKUJOKORO past SOKATSUI's 16 (the bind 45 + 1 a held frame: 58, long enough for her recovery 26
and the O's strike from 6 m; debug trials E7 / E9c held 8; cell b0a0).")
(defvar *ru-ai-seal* (vector nil nil)
  "Per side: (tick seal . yes) at her last look, the bind's one roll (RUKIA-AI-SEAL-O; a tick past now: an earlier match's).")

(defun rukia-ai-seal-o (e b)
  "He is bound by her RIKUJOKORO (his seal frames, a new bind when they rose since her last look: its one roll,
*AI-RU-SEAL-O*): the O (ENBU), held through its strike (AI-COMMAND), the follow-up then the Kikon. A command or NIL."
  (let* ((side (fighter-side (fighter e))) (seal (fighter-seal (fighter (opp-of e)))) (was (svref *ru-ai-seal* side))
         (yes (if (and was (<= (first was) *match-tick*) (<= seal (second was)))
                  (cddr was)
                  (and (plusp seal) (< (sim-rnd01) (ai-chance e *ai-ru-seal-o*))))))
    (setf (svref *ru-ai-seal* side) (list* *match-tick* seal yes))
    (when (and (plusp seal) yes (kit-command-ok-p e :kikon) (not (ai-kikon-futile-p e)))
      (pace e :ai-seal-o)
      (why b :seal-o :kikon))))

(defun rukia-ai-reflex (e b s d)
  "Her forms' :reflex: zero's REIDO; the O on him bound (RUKIA-AI-SEAL-O, cell b0a0); the timed Hoho
(RUKIA-AI-PERFECT-HOHO); her matchup's guard (RUKIA-AI-MU-GUARD); the stun / recovery cashed (RUKIA-AI-CASH: the Shikai's by
payoff, RUKIA-AI-CASH-PICK); her matchup's Breaker read (RUKIA-AI-MU-BREAK); at -50 the Hoho in; the Shikai's intent and
neutral decision by her matchup table (RUKIA-AI-MU-INTENT / -DECIDE), else the old pick (RUKIA-AI-ZONE: SP2 at >= 2
layers, the kido at 3-6.5 m); the bands' disc. A command or NIL."
  (or (and (eq (kit-form (kit-of e)) :zero) (rukia-ai-zero e b s d))
      (rukia-ai-seal-o e b)
      (rukia-ai-perfect-hoho e b s d)
      (rukia-ai-mu-guard e b s d)
      (rukia-ai-cash e b s d)
      (rukia-ai-mu-break e b s d)
      (and (eq (kit-form (kit-of e)) :m50) (rukia-ai-hoho-in e b s d))
      (rukia-ai-mu-intent e b)
      (rukia-ai-mu-decide e b s d)
      (rukia-ai-zone e b s d)
      (rukia-ai-band-disc e b s d)))

(defun rukia-assist-guard (e b s d)
  "Her forms' :assist-guard (assist.lisp AUTO GUARD): her defensive answers only, REIDO at zero (a ward block, a Breaker)
and the timed Hoho."
  (or (and (eq (kit-form (kit-of e)) :zero) (rukia-ai-zero e b s d))
      (rukia-ai-perfect-hoho e b s d)))

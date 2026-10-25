;;;; rukia-ai.lisp — Rukia's CPU: her four forms' :ai plists (*RU-AI-BASE* .. *RU-AI-ZERO*), her action policy (AI v2,
;;;; docs/duel/DUEL_AI_V2.md: the perfect-Hoho counter-fighter, the cash-out, the zone, absolute zero's REIDO, the bursts' and the
;;;; held kido's reads) and its knobs (the *AI-RU-...* parameters, every chance EASY <= NORMAL <= HARD). Split out of rukia.lisp
;;;; 2026-10-25 for her CPU search (docs/research/rukia-ai-drsi, DUEL_RUKIA_TYBW §17), as hisagi-ai.lisp was. Loads right BEFORE
;;;; rukia.lisp, whose DEFKITs read the :ai plists by name; the plists name the CPU functions as bare symbols (late-bound), and
;;;; tuning.lisp keeps *AI-RU-L-AFTER-K* / -AWAKE* (spliced in by value). Plain CL (the host rules test loads it before
;;;; rukia.lisp); no DEFUN-FAST. The dream-rsi search edits this file.
;;;; Cell b1a1 (round 1, a refine of b1a0: her resources and his state): b1a0's value tables (the confirm, the cash, the
;;;; envelope) with the bar priced by what it buys (the oki's seal: 白漣's knockdown -> RIKUJOKORO on his wake-up -> the O,
;;;; b2a0's verified gap-0 sequence; one bar kept for it, :sp-cancel-bars 2), b2a0's anti-step (his Step in met with J1,
;;;; HARD), ORANGE as the K3's cash-out when her flash step is full (its regen otherwise wasted), no plain O (the O lands on a
;;;; red or sealed victim only), and the awakening kept for a comeback (:min-taken 1800: her Shikai now outplays her bands).
;;;; Cell b1a2 (round 1, a refine of b1a1; his state): Lille's charged dash (his awakened EN stance's L) met with a perfect
;;;; Hoho timed to its predicted slide (RUKIA-AI-ANTI-DASH), and the wait instead of a slow poke at a neutral decision against
;;;; that form (RUKIA-AI-MU-DASH): her flash step and her free frames kept for it.
(in-package :duel)
(defvar *ru-hoho-cold*) (defvar *ru-l-hold*)   ; (rukia.lisp's knobs, set when it loads after this file)
(defvar *ru-ai-hold* (vector nil nil)
  "Per side, the L / SP1 hold frames a reflex of hers picked this step (the oki's timed RIKUJOKORO / TSUKISHIRO), read and
cleared by RUKIA-AI-SIG-HOLD / -SP1-HOLD in the same step's AI-COMMAND (never across steps).")

;;; ================================================================ her forms' :ai plists (out of rukia.lisp's DEFKITs 2026-10-25: this file
;;; loads BEFORE rukia.lisp, whose DEFKITs read these by name; a tuning knob inside one is spliced in by value)
(defparameter *ru-ai-base*
  `(:intents (:approach 2 :pressure 3 :zone 2 :defend 1)
       :ranges (:approach (2.8 5.0) :pressure (1.0 2.4) :zone (5.0 7.5) :defend (3.5 6.0))
       :moves ((0.0 1.8 :q 7 :f 2)                          ; J up close only (DUEL_STRINGS §13), K beyond
               (1.8 2.8 :f 5)
               (2.8 5.0 :f 1 :sig 3 :step 1)                ; (b1a0: no neutral O, ENBU is not hers to score;
               (5.0 8.0 :sig 5 :step 1)                     ;  b1a1: no neutral SP: the bar is the oki's seal)
               (8.0 99.0 nil 2))
       :guard 0.4 :hoho 0.35 :o-ender 0.0 :string-k 1.0 :sp-cancel-bars 2 :dash 0.5 :dash-back 0.4 :kikon-range 8.0
       :stun-follow (:sp2 2.4 5.0) :awaken (:melee-share 0.6 :min-taken 1800)   ; (b1a1: 150 -> 1800, the comeback)
       :l-after-k rukia-ai-link-l :l-after-j rukia-ai-link-l :sig-hold rukia-ai-sig-hold :sp1-hold rukia-ai-sp1-hold
       :sp-ender rukia-ai-sp-ender :reflex rukia-ai-reflex :assist-guard rukia-assist-guard)
  "Her base form's CPU (the kit's :ai: ai.lisp; DUEL_RUKIA_TYBW §17).")
(defparameter *ru-ai-m18*
  `(:intents (:approach 2 :pressure 3 :zone 1 :defend 2)
       :ranges (:approach (2.5 4.5) :pressure (1.0 2.2) :zone (4.5 7.0) :defend (3.0 5.0))
       :moves ((0.0 1.8 :q 6 :f 2 :sig 1)
               (1.8 2.8 :f 4 :sig 1)
               (2.8 5.0 :sp2 2 :step 1 nil 2)
               (5.0 99.0 :sp1 2 nil 2))
       :guard 0.5 :hoho 0.3 :dash 0.2 :dash-back 0.2 :o-ender 0.0 :string-k 1.0 :l-after-k rukia-ai-link-l :kikon-range 6.5 :sp-cancel-bars 2
       :cool (:p 0.3 :near 3.5) :stun-follow (:sp2 2.4 5.0) :sp-ender rukia-ai-sp-ender :reflex rukia-ai-reflex :assist-guard rukia-assist-guard)
  "Her m18 form's CPU (the kit's :ai: ai.lisp; DUEL_RUKIA_TYBW §17).")
(defparameter *ru-ai-m50*
  `(:intents (:approach 1 :pressure 3 :zone 0 :defend 2)
       :ranges (:approach (2.0 3.5) :pressure (1.0 2.3) :zone (3.0 5.0) :defend (2.0 3.5))
       :moves ((0.0 1.9 :q 4 :f 2 :sig 3)
               (1.9 3.5 :f 3 :sig 3)
               (3.5 99.0 :sp2 1 :sp1 1 nil 2))
       :guard 0.45 :hoho 0.25 :dash 0.1 :dash-back 0.1 :o-ender 0.0 :string-k 1.0 :l-after-k rukia-ai-link-l :kikon-range 7.5 :sp-cancel-bars 2
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
       :guard 0.0 :hoho 0.0 :o-ender 0.0 :string-k 1.0 :l-after-k rukia-ai-link-l :kikon-range 9.0 :sp-cancel-bars 2
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
(defparameter *ai-ru-k-ender-l* '(:easy 0.0 :normal 0.02 :hard 0.9)
  "Her K3 (the K ender, crumple) hit: the band's L chained after it (the K -> L latch: the Shikai's 白漣 burst, SHIMOBASHIRA, HYOSHIN,
REIDO), per ender hit (RUKIA-AI-SP-ENDER).")
(defparameter *ai-ru-j-ender-sp2* '(:easy 0.1 :normal 0.15 :hard 0.85)
  "Her J3 (the J ender, stagger) hit: SHIRAFUNE off it (it chases the pushed victim), per ender hit, the bars permitting.")
(defparameter *ai-ru-ender-o* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "An ender hit with neither of those taken: the O ender after all (it chases the pushed victim), per ender hit (b1a1: 0.9
-> 0 at HARD: a plain O is not hers to score, and a red victim takes ai.lisp's O ender, the Kikon, first).")

(defun rukia-ai-bars-p (e)
  "Bars enough for an SP and the kit's reserve (:sp-cancel-bars) after it."
  (>= (reiatsu-bars e) (ai-table e :sp-cancel-bars 1)))

(defun rukia-ai-sp-ender (e kit)
  "Her :sp-ender (ai.lisp STRING-REFLEX; a landed ender, no link after it): after a K ender the band's L link (a combo off
the crumple, free in the Shikai, cold in the bands: a chained L overdraws), after a J ender SHIRAFUNE (not at zero: it
would cash the top bar for less than REIDO). A command or NIL."
  (let* ((mv (fighter-move (fighter e))) (name (mv-name mv)) (l (kit-l-link kit name))
         (c (rukia-ai-confirm-pick e mv)))                ; (b1a0: the confirm table's pick at the ender)
    (cond ((member c '(:sp1 :sp2 :burst)) c)
          ((not (eq c :generic)) nil)
          ((and l (kit-k-link-p kit name) (kit-command-ok-p e :sig kit nil l) (< (sim-rnd01) (ai-chance e *ai-ru-k-ender-l*)))
           :sig)
          ((and (kit-j-link-p kit name) (not (kit-rooted kit)) (kit-command-ok-p e :sp2) (rukia-ai-bars-p e)
                (< (sim-rnd01) (ai-chance e *ai-ru-j-ender-sp2*)))
           :sp2)
          ((and (ai-o-ender-ok-p e kit) (< (sim-rnd01) (ai-chance e *ai-ru-ender-o*))) :kikon))))

;;; ---------------------------------------------------------------- the confirm table (cell b1a0, round 1): her resources and his state
;;; A link of hers that hit (J1 / K1 / K2 / K3 / J3 ..., every form) is a decision: the options its frame data allows, each
;;; valued in damage from the frame data and the sim-verified catalogue (docs/research/rukia-cpu/catalogue-*.md) by what
;;; she holds (bars, flash step, Reishi) and what he is (his 霜の層 to burst, red, his Reishi left), one pick per hit by
;;; probability weighted by that value (value^sharp: HARD sharper). Options: the K link (K2 / K2s / K3 off J1, K1, K2: the
;;; route to the ender, never the plain J2 / J3), the link's L (the Shikai's six bursts, the bands' L), SP2 (SHIRAFUNE:
;;; 110 + 25 a layer, unscaled) and SP1 (SOKATSUI tap / the bands' wave) at the ender. The plain O ender is gone
;;; (:o-ender 0: a red victim still takes the Kikon in ai.lisp); the rest of the time (the per-hit gate *AI-RU-CONFIRM*)
;;; ai.lisp's STRING-REFLEX decides as before. Wired through the hooks STRING-REFLEX already calls: the L link's chance
;;; (RUKIA-AI-LINK-L) and the SP ender (RUKIA-AI-SP-ENDER), :string-k 1.0 taking the K link. (ORANGE's restart was an
;;; option: its 70 flash step cost the perfect Hohos and BLUE, -20 HARD wins of 480, z 2.0; as a finisher only, -8.)
(defparameter *ai-ru-confirm* '(:easy 0.2 :normal 0.5 :hard 0.95)
  "A link of hers that hit: the confirm table (RUKIA-AI-CONFIRM-PICK) picks what follows, per hit (else STRING-REFLEX).")
(defparameter *ai-ru-confirm-sharp* '(:easy 1 :normal 1 :hard 3)
  "Every table's pick (RUKIA-AI-PICK: the confirm, the cash, the envelope): each option's weight is its value to this
power (EASY / NORMAL flat, HARD sharper; 2 -> 3, b1a0: +13 HARD wins of 480, z 1.4; 5 is nearly the single best).")
(defparameter *ai-ru-bar-cost* '(80 45 15)
  "The value (damage) a spent bar costs with 1 / 2 / 3 bars held (the last bar is RIKUJOKORO's bind; a full gauge wastes its regen).")
(defparameter *ai-ru-route-ender* 60 "The ender a K route still expects after its K3 (the catalogue: 白漣 94-123, SP2 135-185).")
(defparameter *ai-ru-red-route* 150 "He is red: the K route ends on the O ender's Kikon (2 Konpaku), its value + this.")
(defparameter *ai-ru-finish* 100 "An option whose damage reaches his Reishi left (the Soul Break): its value + this.")
(defparameter *ai-ru-fx-value* '(:hop 0 :refund 20 :circle 40 :push 15 :wave 40 nil 20)
  "A Shikai burst's benefit (:params :fx) as damage: 霜散 the hop (an exit), 雪煙 Reiatsu, 霜陣 the circle (3 layers back),
氷柱 6 m away, 白漣 the knockdown (+50: the oki), 氷礫 (none) +4 and close.")

(defparameter *ai-ru-orange-fs* 100.0
  "b1a1: her K3 that hit is cashed with ORANGE (CHAIN REVERSE: the string restarts unscaled, J1 K2s K3 +L 白漣 again, then the
oki) only with her flash step at least this full (its regen otherwise wasted; below it the flash step is the perfect Hoho's).")
(defparameter *ai-ru-orange-route* 280 "b1a1: ORANGE's restart as damage: J1 K2s K3 (176, unscaled) + 白漣 again (~105).")
(defparameter *ai-ru-orange-cost* 150 "b1a1: the 70 flash step ORANGE takes, as damage (a perfect Hoho / a BLUE it no longer has).")

(defun rukia-ai-dmg (mv)
  "MV's damage as the table counts it: its hit's, else its hazard's :params :dmg (+ :dmg-per twice: a held wave)."
  (let ((p (mv-params mv)))
    (max (mv-dmg mv) (+ (getf p :dmg 0) (* 2 (getf p :dmg-per 0))))))

(defun rukia-ai-bar-cost (e)
  "*AI-RU-BAR-COST* for E's bars now."
  (nth (max 0 (min 2 (1- (reiatsu-bars e)))) *ai-ru-bar-cost*))

(defun rukia-ai-options (e kit mv)
  "The confirm table for E's link MV that just hit: a list of (command . value), every one allowed now (b1a1: 白漣 valued
with its oki, RUKIA-AI-OKI-VALUE; ORANGE at the ender with her flash step full, *AI-RU-ORANGE-FS*)."
  (let* ((f (fighter e)) (o (opp-of e)) (fo (fighter o)) (go (gauges o))
         (name (mv-name mv)) (n (fighter-layers fo)) (h (fighter-combo-hits fo))
         (nf (kit-next kit name :f)) (nq (kit-next kit name :q)) (l (kit-l-link kit name))
         (sp2 (kit-command-move kit :sp2)) (sp1 (kit-command-move kit :sp1))
         (red (gauges-red-p go)) (opts nil))
    (flet ((add (cmd dmg extra) (push (cons cmd (+ dmg extra (if (>= dmg (gauges-reishi go)) *ai-ru-finish* 0))) opts))
           (burst (m) (* (getf (mv-params m) :per 0) (burst-count (getf (mv-params m) :burst 0) n))))
      (when nf                                            ; the K link: the route to the ender
        (let ((nf2 (kit-next kit (mv-name nf) :f)))
          (add :f (+ (* (rukia-ai-dmg nf) (combo-scale (+ h 1)))
                     (if nf2 (* (rukia-ai-dmg nf2) (combo-scale (+ h 2))) 0)
                     *ai-ru-route-ender*)
               (if red *ai-ru-red-route* 0))))
      (when (and l (kit-command-ok-p e :sig kit nil l))   ; the link's L (a burst: RUKIA-OK, >= 1 layer)
        (add :sig (* (+ (rukia-ai-dmg l) (burst l)) (combo-scale (+ h 1)))
             (if (eq (getf (mv-params l) :fx) :wave)
                 (rukia-ai-oki-value e)                   ; (b1a1: 白漣's knockdown is worth its oki)
                 (getf *ai-ru-fx-value* (getf (mv-params l) :fx) 20))))
      (unless (or nf nq)                                  ; the ender (STRING-REFLEX's SP ender comes there only)
        (when (and sp2 (kit-command-ok-p e :sp2) (rukia-ai-bars-p e))
          (add :sp2 (+ (rukia-ai-dmg sp2) (if (getf (mv-params sp2) :burst) (burst sp2) 0)) (- (rukia-ai-bar-cost e))))
        (when (and sp1 (kit-command-ok-p e :sp1) (rukia-ai-bars-p e) (< (fighter-dist f) (rukia-ai-sp1-far e)))
          (add :sp1 (rukia-ai-dmg sp1) (- 10 (rukia-ai-bar-cost e))))
        (when (and (eq (kit-form kit) :base) (eq (burst-ok-p e) :orange) (eq (state-of o) :stun)   ; (b1a1: her flash step full)
                   (>= (gauges-fs (gauges e)) *ai-ru-orange-fs*)
                   (< (fighter-dist f) (+ (mv-reach (kit-command-move kit :q)) 0.2)))
          (add :burst (+ *ai-ru-orange-route* (rukia-ai-oki-value e)) (- *ai-ru-orange-cost*)))))
    (delete-if-not (lambda (c) (plusp (cdr c))) opts)))

(defun rukia-ai-pick (b opts)
  "One option of OPTS ((command . value) ...) by probability weighted by value^*AI-RU-CONFIRM-SHARP*: one SIM-RND01."
  (let* ((k (brain-chance b *ai-ru-confirm-sharp*))
         (ws (mapcar (lambda (c) (expt (float (cdr c)) k)) opts))
         (r (* (sim-rnd01) (reduce #'+ ws))))
    (loop for c in opts for w in ws
          when (< r w) return (car c)
          do (decf r w)
          finally (return (car (car (last opts)))))))

(defvar *ru-ai-memo* (vector (list -1 nil nil) (list -1 nil nil))
  "Per side, the confirm pick of this step (key, move name, command; the key: the tick, his combo hits and Reishi):
RUKIA-AI-LINK-L picks, RUKIA-AI-SP-ENDER reads it in the same STRING-REFLEX call (a step's value, never another step's).")

(defun rukia-ai-confirm-pick (e mv)
  "The confirm pick for E's link MV that hit, once per hit (memoised for this step, *RU-AI-MEMO*): the per-hit gate
*AI-RU-CONFIRM* on E's deciding brain (AI-BRAIN: the CPU's, the ASSIST's), then one pick of RUKIA-AI-OPTIONS; :GENERIC
when the gate says no or there is no brain or no option (the shipped rules decide)."
  (let* ((f (fighter e)) (m (svref *ru-ai-memo* (fighter-side f)))
         (fo (fighter (opp-of e)))
         (key (+ (* 4096 *match-tick*) (* 64 (fighter-combo-hits fo)) (mod (round (gauges-reishi (gauges (opp-of e)))) 64))))
    (if (and (eql (first m) key) (eq (second m) (mv-name mv)))
        (third m)
        (let* ((b (ai-brain e))
               (opts (and b (brain-roll b *ai-ru-confirm*) (rukia-ai-options e (fighter-kit f) mv)))
               (c (if opts (rukia-ai-pick b opts) :generic)))
          (when (and b (not (eq c :generic))) (setf (brain-why b) :confirm))
          (setf (svref *ru-ai-memo* (fighter-side f)) (list key (mv-name mv) c))
          c))))

(defun rukia-ai-link-l (e link l)
  "Every form's :l-after-k / :l-after-j (ai.lisp STRING-REFLEX: L LINK's chance after string link LINK hit): on the hit's
first step, the confirm pick (RUKIA-AI-CONFIRM-PICK): its L 1.0, any other pick 0.0 (the K link: :string-k 1.0; SP1 /
SP2 at the ender: RUKIA-AI-SP-ENDER); :GENERIC: the shipped chance (the Shikai's RUKIA-AI-BURST-P, the bands'
*AI-RU-L-AFTER-K-AWAKE*). 0.0 on any other step (no roll)."
  (let ((f (fighter e)))
    (if (and (eq (fighter-contact f) :hit) (= (fighter-sf f) (fighter-land-sf f)) (not (eq (state-of (opp-of e)) :air)))
        (case (rukia-ai-confirm-pick e link)
          (:generic (if (eq (kit-form (fighter-kit f)) :base) (rukia-ai-burst-p e link l) *ai-ru-l-after-k-awake*))
          (:sig 1.0)
          (t 0.0))
        0.0)))

(defparameter *ai-ru-seal-o* '(:easy 0.2 :normal 0.6 :hard 1.0)
  "RIKUJOKORO's seal on him (FIGHTER-SEAL: a Kikon follow-up treats him as red): her O when it strikes before the seal ends,
per action of his (the Kikon from full health: 2 Konpaku), before any ice cash.")

(defun rukia-ai-seal (e b s d)
  "He is sealed by her RIKUJOKORO: the O (ENBU; the bands' HAKKA) when it lands within the seal (RUKIA-AI-O-LANDS-P).
A command or NIL."
  (declare (ignore s))
  (let ((left (fighter-seal (fighter (opp-of e)))) (o (kit-command-move (kit-of e) :kikon)))
    (when (and o (plusp left) (kit-command-ok-p e :kikon) (not (ai-sb-finish-p e)) (rukia-ai-o-lands-p o d left)
               (< (brain-react-roll b) (ai-chance e *ai-ru-seal-o*)))
      (why b :seal-o :kikon))))

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
  "A stunned or recovering opponent (the counter of a perfect Hoho ...): the cash table (RUKIA-AI-CASH), per action of his
(SP2 only before b1a0).")

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

(defparameter *ai-ru-cash-o* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "A stun neither SHIRAFUNE (no bar) nor the band's disc L can cash, short but long enough for her O (the Shikai's ENBU
rush: aura + its dash + S): the O, not a J string, per stun (the cash roll's share; b1a1: 0.9 -> 0 at HARD, her routes cash it).")

(defun rukia-ai-o-lands-p (mv d left)
  "Does O move MV, pressed now at D m, strike within LEFT frames: its aura, its dash into its reach, its startup (a
lane module without a dash: aura + S, D within its lane)?"
  (let ((sp (/ (or (rush-param mv :speed) 0.0) 60.0)) (gap (- d (mv-reach mv) -0.3)))
    (and (or (plusp sp) (< d (mv-reach mv)))
         (>= left (+ (or (rush-param mv :aura) 0) (mv-s mv) 1 (if (and (plusp sp) (plusp gap)) (ceiling gap sp) 0))))))

(defparameter *ai-ru-bind-cash* 250
  "b1a0: RIKUJOKORO on a stun / recovery he can't Step out of before it shuts (his frames left >= its hold + startup):
the seal's Kikon from full health (2 Konpaku) as damage, in the cash table.")

(defun rukia-ai-route (kit mv)
  "The damage of the K route MV opens (MV, its K link, that one's K link) + *AI-RU-ROUTE-ENDER*."
  (let* ((k2 (kit-next kit (mv-name mv) :f)) (k3 (and k2 (kit-next kit (mv-name k2) :f))))
    (+ (rukia-ai-dmg mv) (if k2 (rukia-ai-dmg k2) 0) (if k3 (rukia-ai-dmg k3) 0) *ai-ru-route-ender*)))

(defun rukia-ai-cash (e b s d)
  "A stunned opponent (a perfect Hoho's counter, a freeze, a crumple) or a recovering one, his frames left as seen: the
cash table (b1a0), one roll *AI-RU-PH-CASH* per action of his, then one pick by value of what lands in time: SHIRAFUNE
within its line (110 + 25 a layer, bars and the kit's reserve permitting), the band's disc L (SHIMOBASHIRA / HYOSHIN /
REIDO) within its radius, her J1's or K1's route (a stun: J1 within its reach; K1 within its line), RIKUJOKORO when he
can't leave its ring in time (*AI-RU-BIND-CASH*), her O (a stun, RUKIA-AI-O-LANDS-P: not hers to score, the last resort).
A command or NIL."
  (let* ((kit (kit-of e)) (sp2 (kit-command-move kit :sp2)) (l (kit-command-move kit :sig))
         (q (kit-command-move kit :q)) (k1 (kit-command-move kit :f)) (sp1 (kit-command-move kit :sp1))
         (o (kit-command-move kit :kikon)) (stun (eq (snap-state s) :stun))
         (n (fighter-layers (fighter (opp-of e)))) (his (gauges-reishi (gauges (opp-of e))))
         (left (snap-left-seen s b)) (opts nil))
    (flet ((lands (mv) (>= left (+ (mv-s mv) (getf (mv-params mv) :delay 0) 1)))   ; (TSUKISHIRO: its pillar's delay)
           (add (c v) (when (plusp v) (push (cons c (+ v (if (>= v his) *ai-ru-finish* 0))) opts))))
      (when (and (or stun
                     (and (eq (snap-state s) :move) (eq (snap-phase s) :main) (< (snap-left s) 99)   ; his recovery
                          (>= (+ (snap-sf s) (brain-delay b)) (snap-active-end s))
                          (not (ai-mash-p b))))         ; (a masher's next J comes out of it at once: the Hoho's)
                 (< (brain-react-roll b) (ai-chance e *ai-ru-ph-cash*)))
        (when (and sp2 (< 0.5 d (- (mv-reach sp2) 0.5)) (lands sp2) (kit-command-ok-p e :sp2) (rukia-ai-bars-p e))
          (add :sp2 (- (+ (rukia-ai-dmg sp2) (if (getf (mv-params sp2) :burst) (* n (getf (mv-params sp2) :per 0)) 0))
                       (rukia-ai-bar-cost e))))
        (when (and l (getf (mv-params l) :radius) (< d (- (getf (mv-params l) :radius) 0.4)) (lands l) (kit-command-ok-p e :sig))
          (add :sig (+ (rukia-ai-dmg l) 20)))
        (when (and q stun (< d (+ (mv-reach q) 0.4)) (lands q) (kit-command-ok-p e :q))
          (add :q (rukia-ai-route kit q)))
        (when (and k1 (< 0.6 d (- (mv-reach k1) 0.2)) (lands k1) (kit-command-ok-p e :f) (not (kit-rooted kit)))
          (add :f (rukia-ai-route kit k1)))
        (when (and sp1 (eq (kit-form kit) :base) (< (rukia-ai-sp1-far e) d 6.0) (kit-command-ok-p e :sp1) (rukia-ai-bars-p e)
                   (>= left (+ 2 (second (mv-hold sp1)) 16 4)))
          (add :sp1 (- *ai-ru-bind-cash* (rukia-ai-bar-cost e))))
        (when (and o stun (not (ai-sb-finish-p e)) (kit-command-ok-p e :kikon) (rukia-ai-o-lands-p o d left)
                   (< (brain-react-roll b) (ai-chance e *ai-ru-cash-o*)))
          (add :kikon 40))
        (let ((c (and opts (rukia-ai-pick b opts))))
          (when c (why b (if (member c '(:q :f)) :route-cash :ice-cash) c)))))))

(defparameter *ai-ru-zone-kido* '(:easy 0.0 :normal 0.05 :hard 0.6)
  "A Shikai neutral decision at 3-6.5 m: SP1's kido (SOKATSUI tapped within RUKIA-AI-SP1-FAR, RIKUJOKORO held beyond:
RUKIA-AI-SP1-HOLD) instead of the table's pick, per decision (b1a0: :hard 0.3 -> 0.6; HAKUREN's wave at 5-11 m before
2026-10-24: :hard 0.5).")
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
  (declare (ignore kit))
  (let ((h (and e (svref *ru-ai-hold* (fighter-side (fighter e))))))
    (cond (h (setf (svref *ru-ai-hold* (fighter-side (fighter e))) nil) h)
          ((> d *ai-ru-l-far*) (+ *ru-l-hold* 4))
          (t 1))))

(defparameter *ai-ru-sp1-far-long* 3.5
  "b1a0: against a long poke (his K1 reaches >= *AI-RU-LONG-POKE* m: SOKATSUI's knockback would leave him at his own
range) her SP1 is held (RIKUJOKORO) beyond this instead of *AI-RU-SP1-FAR*.")
(defparameter *ai-ru-long-poke* 4.0 "b1a0: his K1's reach (m) from which he pokes from SOKATSUI's knockback distance.")

(defun rukia-ai-sp1-far (e)
  "Where E's SP1 starts to be held (RIKUJOKORO): *AI-RU-SP1-FAR-LONG* against a long poke (his kit's K1 reach >=
*AI-RU-LONG-POKE*), else *AI-RU-SP1-FAR*."
  (let ((k1 (and e (kit-command-move (kit-of (opp-of e)) :f))))
    (if (and k1 (>= (mv-reach k1) *ai-ru-long-poke*)) *ai-ru-sp1-far-long* *ai-ru-sp1-far*)))

(defun rukia-ai-sp1-hold (kit d &optional e)
  "The Shikai's :sp1-hold (ai.lisp AI-COMMAND): frames SP1 is held: beyond RUKIA-AI-SP1-FAR RIKUJOKORO (to its hold's
end), nearer a tap (SOKATSUI)."
  (let ((h (and e (svref *ru-ai-hold* (fighter-side (fighter e))))))
    (cond (h (setf (svref *ru-ai-hold* (fighter-side (fighter e))) nil) h)
          ((> d (rukia-ai-sp1-far e))                   ; (b2a0: the bind outlasts her recovery and the O from D m)
           (let ((o (kit-command-move kit :kikon)))
             (+ 2 (second (mv-hold (kit-command-move kit :sp1)))
                (if o (max 0 (min 40 (- (+ 26 (rukia-ai-o-frames o d) 4) 44))) 0))))
          (t 1))))

(defun rukia-ai-o-frames (mv d)
  "Frames her O (MV, a rush module) needs from its press at D m to its strike: aura + dash + S + 1 (its :params read
directly: the host test has no fighter.lisp; b2a0)."
  (let ((sp (/ (or (getf (mv-params mv) :speed) 0.0) 60.0)) (gap (- d (mv-reach mv) -0.3)))
    (+ (or (getf (mv-params mv) :aura) 0) (mv-s mv) 1 (if (and (plusp sp) (plusp gap)) (ceiling gap sp) 0))))

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
                           (or (> d (rukia-ai-sp1-far e)) (rukia-ai-bars-p e))   ; (SOKATSUI keeps the oki's bar)
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

;;; ---------------------------------------------------------------- his first-strike envelope (b1a0): his state, closing in
;;; Every melee CPU opens with J1 (7-10 f) from its lunge's reach as he closes: faster than her perception (HARD 8 f), so
;;; nothing she sees of the J1 itself can answer it. Her answer is to the approach: at a neutral decision with him free
;;; and inside his J1's envelope (his kit's J1 reach + lunge + his closing speed over his J1 and her delay), one pick by
;;; value: guard (his J blocked leaves him -5: her J1 / J beats K), her J1 first (in its reach), the back hop (his J1
;;; whiffs: the punish), K1 or SOKATSUI only while he has no flash step for the perfect Hoho (his gauge < *FS-HOHO*).
(defparameter *ai-ru-front* '(:easy 0.0 :normal 0.15 :hard 0.95)
  "A neutral decision with him free inside his first-strike envelope (RUKIA-AI-FRONT): the envelope table, per decision.")
(defparameter *ai-ru-front-values* '(:guard 40 :q 50 :step 25 :f 60 :sp1 55)
  "The envelope table's values (expected damage swing): guard, her J1, the back hop, K1 / SOKATSUI (no Hoho of his).")

(defun rukia-ai-prev-snap (b)
  "The SNAP brain B perceived the step before this one (its ring), or NIL."
  (let ((ring (brain-ring b))) (svref ring (mod (- (brain-head b) (brain-delay b) 2) (length ring)))))

(defun rukia-ai-closing (b s d e)
  "His perceived closing speed toward E (m/f, > 0: coming), from the SNAP S and the one before it in brain B's ring."
  (let ((s1 (rukia-ai-prev-snap b)) (p (pos-of e)))
    (if (or (null s1) (< d 0.01)) 0.0
        (/ (+ (* (- (snap-x s1) (snap-x s)) (- (snap-x s) (aref p 0))) (* (- (snap-z s1) (snap-z s)) (- (snap-z s) (aref p 2))))
           d))))

(defun rukia-ai-envelope (b his d cv)
  "His first-strike envelope (m): his J1 HIS's reach + its lunge (at most 0.8) + 0.3 + his closing speed CV over his J1's
startup and brain B's delay."
  (declare (ignore d))
  (+ (mv-reach his) (min 0.8 (mv-slide his)) 0.3 (* cv (+ (mv-s his) (brain-delay b)))))

(defun rukia-ai-front (e b s d)
  "Her neutral decision when he is free inside his J1's envelope (RUKIA-AI-ENVELOPE): one roll *AI-RU-FRONT*, then one
pick of *AI-RU-FRONT-VALUES* by value among the options the distance and his flash step allow. A command or NIL."
  (let* ((o (opp-of e)) (his (kit-command-move (kit-of o) :q)) (kit (kit-of e))
         (q (kit-command-move kit :q)) (k1 (kit-command-move kit :f)))
    (when (and his q (<= (brain-decide-t b) 1) (member (snap-state s) '(:idle :run)) (not (kit-rooted kit)))
      (let ((cv (max 0.0 (rukia-ai-closing b s d e))))
        (when (and (<= d (rukia-ai-envelope b his d cv))
                   (let ((pr (ai-chance e *ai-ru-front*))) (and (plusp pr) (< (sim-rnd01) pr))))
          (let ((no-hoho (< (gauges-fs (gauges o)) *fs-hoho*)) (v *ai-ru-front-values*) (opts nil))
            (flet ((add (c) (when (plusp (getf v c 0)) (push (cons c (getf v c)) opts))))
              (add :guard) (add :step)
              (when (<= (- d (* cv (+ (mv-s q) (brain-delay b)))) (+ (mv-reach q) 0.3)) (add :q))
              (when (and no-hoho k1 (<= 1.0 (- d (* cv (+ (mv-s k1) (brain-delay b)))) (+ (mv-reach k1) 0.1))) (add :f))
              (when (and no-hoho (kit-command-ok-p e :sp1) (rukia-ai-bars-p e) (< d (rukia-ai-sp1-far e))) (add :sp1)))
            (setf (brain-decide-t b) (ai-decide-time e b))
            (why b :front (rukia-ai-pick b opts))))))))

;;; ---------------------------------------------------------------- the knockdown's oki: the bar's best use (b2a0, b1a1)
;;; 白漣 (K3 + L) knocks him down at ~4.35 m, +50 with his wake-up (catalogue B6). Verified (combo-trial, b2a0): SP1 held H
;;; frames from P frames before he is free, with P - H in 13..17, lays RIKUJOKORO's bind on his first vulnerable frame (gap 0,
;;; against Kenpachi, Hisagi, Lille, Ichigo alike), then her O lands sealed: the Kikon from full health (2 Konpaku, his Reishi
;;; refilled); TSUKISHIRO pressed 50 frames before he is free puts its pillar on his wake-up (gap 0: 60 + 2 layers, +26).
;;; b1a1: that is what a bar buys her; the confirm table values 白漣 by it (RUKIA-AI-OKI-VALUE).
(defparameter *ai-ru-oki* '(:easy 0.0 :normal 0.4 :hard 0.95)
  "Him down within RIKUJOKORO's range: the oki (RUKIA-AI-OKI), per knockdown (his last action's roll).")
(defparameter *ai-ru-oki-lead* 15 "The oki's RIKUJOKORO: frames before he is free minus this = its SP1 hold (13..17 lands).")
(defparameter *ai-ru-konpaku-dmg* 433
  "The damage a Konpaku is worth to her CPU's tables (a Soul Break's 3 for his 1300 Reishi): a Kikon's 2 Konpaku, less the
Reishi it refills.")
(defparameter *ai-ru-oki-tsuki* 150 "The oki's worth without a bar: the meaty TSUKISHIRO (60 + 2 layers + its +26).")

(defun rukia-ai-free-in (state sf delay)
  "Frames until he is free again, from his knockdown perceived DELAY frames ago in STATE at its frame SF (:down 30 +
:wakeup 30, *REACTION-FRAMES*), or NIL (pure: the host test)."
  (let ((now (+ sf delay)) (rf *reaction-frames*))
    (case state
      (:down (- (+ (getf rf :down 30) (getf rf :wakeup 30)) now))
      (:wakeup (- (getf rf :wakeup 30) now)))))

(defun rukia-ai-seal-value (e)
  "What the seal's Kikon is worth to her now (damage): its Konpaku less the Reishi it refills him."
  (let ((go (gauges (opp-of e))))
    (- (* (kikon-worth e) *ai-ru-konpaku-dmg*) (- (gauges-reishi-max go) (gauges-reishi go)))))

(defun rukia-ai-oki-value (e)
  "白漣's knockdown's worth to the confirm table: the seal (a bar held, RUKIA-AI-SEAL-VALUE) or TSUKISHIRO's pillar."
  (if (>= (reiatsu-bars e) 1) (max *ai-ru-oki-tsuki* (rukia-ai-seal-value e)) *ai-ru-oki-tsuki*))

(defun rukia-ai-oki (e b s d)
  "His knockdown, seen (RUKIA-AI-FREE-IN) within RIKUJOKORO's range: one roll (*AI-RU-OKI*), then the bind timed on his
wake-up whenever a bar is there (its O then cashed by RUKIA-AI-SEAL: the Kikon), else the meaty TSUKISHIRO (:WAIT until
its frame). While he is still seen reeling from the hit that knocked him down: :WAIT. A command, :WAIT or NIL."
  (let ((left (rukia-ai-free-in (snap-state s) (snap-sf s) (brain-delay b))))
    (when (and (eq (kit-form (kit-of e)) :base) (< d 5.8) (not (ai-sb-finish-p e))
               (member (fighter-state (fighter (opp-of e))) '(:air :down :wakeup))   ; (her own knockdown, felt at once)
               (< (brain-react-roll b) (ai-chance e *ai-ru-oki*)))
      (let ((h (and left (- left *ai-ru-oki-lead*))))
        (cond ((null left) (why b :oki-wait :wait))
              ((and (<= 18 h 70) (>= (reiatsu-bars e) 1) (kit-command-ok-p e :sp1))
               (setf (svref *ru-ai-hold* (fighter-side (fighter e))) h)
               (why b :oki-seal :sp1))
              ((and (<= 48 left 51) (kit-command-ok-p e :sig))
               (setf (svref *ru-ai-hold* (fighter-side (fighter e))) (+ *ru-l-hold* 4))
               (why b :oki-tsukishiro :sig))
              ((> left 51) (why b :oki-wait :wait)))))))

;;; ---------------------------------------------------------------- his Step in, met (b2a0's anti-step)
;;; The opponents' first opener is the Step -> J from 2-4 m (the hop ~0.27 m a frame, landing at its f10-11 ~2.7 m on; J1
;;; latched at f12 hits at f19-20). Seen at its frame 1, her J1 pressed now is active D + 8 .. D + 10 (HARD: before his J1;
;;; NORMAL's 14 f delay is too late): when the hop lands him inside her J1's reach, J1 first, one roll per Step.
(defparameter *ai-ru-hop* 2.4 "His Step's hop still to come when she sees its frame 1 (m; measured 2.7 m in 10 f, b2a0).")
(defparameter *ai-ru-anti-step* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "His Step toward her seen at its frame 1: her J1 met into its landing (RUKIA-AI-ANTI-STEP), per Step.")

(defun rukia-ai-anti-step (e b s d)
  "His Step toward her, seen at its frame 1: J1 now when his hop puts him in her J1's reach at its active frames and they
come before his Step's J (*STEP-J-CANCEL* + his J1's S). A command or NIL."
  (when (and (eq (snap-state s) :step) (= (snap-sf s) 1))
    (let* ((v (rukia-ai-closing b s d e)) (q (kit-command-move (kit-of e) :q))
           (his (kit-command-move (kit-of (opp-of e)) :q)) (dl (brain-delay b))
           (at (+ dl 1 (mv-s q) 1)) (dp (- d *ai-ru-hop*)))
      (when (and q his (> v 0.15) (< (+ at 1) (+ *step-j-cancel* (mv-s his)))
                 (< dp (+ (mv-reach q) 0.4)) (kit-command-ok-p e :q)
                 (< (sim-rnd01) (ai-chance e *ai-ru-anti-step*)))
        (why b :anti-step :q)))))

;;; ---------------------------------------------------------------- his charged dash, met with a perfect Hoho (b1a2)
;;; Lille's awakened L (BR-E-L1 / BR-OE-L1, a move with :params :dash) opened 346 of his combos in 40 HARD matches (b1a1's
;;; file: 55 + 39 k damage, 204 of the 270 Konpaku she lost, all as his Kikons). Released, it stands S (8) frames, then slides
;;; through her: the clamped d + 1.6 m (2 .. 10) over 8 frames, its hit volume 0.9 m ahead, 0.7 wide. A Hoho is PERFECT
;;; while that volume is within *PERFECT-INFLATE* (1 m) of her hurt cylinder and its window (S .. S + 10) is near: from the
;;; perceived release frame (her delay counted) his gap at the frame she presses is predicted; inside *AI-RU-DASH-GAP* m the
;;; Hoho (the counter, his inputs locked, then her cash table). Guarding it blocks it but the post-block hold forfeits the
;;; -12 (b1a1 C5: 124 blocked, no wins); her generic perfect Hoho never saw it (his move's reach is 0.9 m: SNAP-NEAR-P).
(defparameter *ai-ru-anti-dash* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "b1a2: his charged :dash move seen released toward her: the timed Hoho into its slide (RUKIA-AI-ANTI-DASH), per dash.")
(defparameter *ai-ru-dash-gap* 3.4
  "b1a2: the predicted gap (m, his feet to hers along his line) at which the Hoho is pressed (Lille, 160 HARD matches, with
the wait below: 2.9 -> 84 wins, 3.2 138, 3.4 131, 3.5 124, 3.8 131: below 3.0 his hit comes first; above 3.4 more of the
Hohos are early, plain dodges).")
(defparameter *ai-ru-dash-lead* 1 "b1a2: frames from her press to the Hoho's own frame (the gap is predicted there).")

(defun rukia-ai-dash-gap (d sf st now)
  "Pure: his charged dash's gap to her (m) at real frame NOW of his move, from D m perceived at its frame SF (S = ST: it
stands still until ST, then slides the clamped D + 1.6 m over 8 frames; D is the release distance while SF < ST)."
  (let ((v (/ (max 2.0 (min 10.0 (+ d 1.6))) 8.0)))
    (- d (* v (- (min 8 (max 0 (- now st))) (min 8 (max 0 (- sf st))))))))

(defun rukia-ai-anti-dash (e b s d)
  "His charged dash (:params :dash) seen in its main phase before its window ends, him facing her (she on his line): the
Hoho when its predicted gap at her press (RUKIA-AI-DASH-GAP) is within *AI-RU-DASH-GAP* m, one roll a dash
(*AI-RU-ANTI-DASH*). A command or NIL."
  (let ((mv (snap-move s)))
    (when (and mv (eq (snap-state s) :move) (eq (snap-phase s) :main) (getf (mv-params mv) :dash) (hoho-open-p e)
               (< (+ (snap-sf s) (brain-delay b)) (+ (snap-s s) 10)))
      (let* ((p (pos-of e)) (fx (fwd-x (snap-yaw s))) (fz (fwd-z (snap-yaw s)))
             (dx (- (aref p 0) (snap-x s))) (dz (- (aref p 2) (snap-z s)))
             (perp (abs (- (* dx fz) (* dz fx))))
             (gap (rukia-ai-dash-gap d (snap-sf s) (snap-s s) (+ (snap-sf s) (brain-delay b) *ai-ru-dash-lead*))))
        (when (and (> (+ (* dx fx) (* dz fz)) 0.0) (< perp 1.6) (< -1.0 gap *ai-ru-dash-gap*)
                   (< (brain-react-roll b) (ai-chance e *ai-ru-anti-dash*)))
          (why b :anti-dash :hoho))))))

;;; Against a form whose L is that dash (his kit as his form has it now) her slow neutral presses are what it punishes
;;; (b1a1's file, 40 matches, his awakened forms: SOKATSUI / RIKUJOKORO from the zone 170 presses, 83 hit first and 31 into
;;; his wing armour; BYAKURAI 82: 32 / 20; TSUKISHIRO 25: 21 hit first): the neutral decision beyond her J1 is the wait, her
;;; flash step kept for the dash (RUKIA-AI-ANTI-DASH) and her answers to his recoveries and Steps (the cash, the anti-step).
;;; Measured (Lille, 160 HARD matches): the anti-dash alone 20 -> 39 of 80 (seeds 1-40), with the wait 67 and 71 of 80
;;; (seeds 1-40 / 41-80; b1a1 20 and 12). A wait / guard mix (0.7 / 0.3) tied (137 vs 131 of 160): the plain wait kept.
(defparameter *ai-ru-mu-dash* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "b1a2: a neutral decision beyond her J1's reach against a form whose L is a charged dash: the wait, per decision.")

(defun rukia-ai-dash-form-p (e)
  "Is E's opponent's form's L a charged dash (:params :dash: Lille's awakened stance L)?"
  (let ((l (kit-command-move (kit-of (opp-of e)) :sig))) (and l (getf (mv-params l) :dash) t)))

(defun rukia-ai-mu-dash (e b s d)
  "Her neutral decision against his dash form beyond her J1's reach + 0.3 m: the wait (*AI-RU-MU-DASH*, one roll a
decision). :WAIT or NIL."
  (declare (ignore s))
  (when (and (<= (brain-decide-t b) 1) (rukia-ai-dash-form-p e)
             (> d (+ (mv-reach (kit-command-move (kit-of e) :q)) 0.3))
             (let ((p (ai-chance e *ai-ru-mu-dash*))) (and (plusp p) (< (sim-rnd01) p))))
    (setf (brain-decide-t b) (ai-decide-time e b))
    (why b :mu-dash-wait :wait)))

(defun rukia-ai-reflex (e b s d)
  "Her forms' :reflex, in order: zero's REIDO answers; his RIKUJOKORO seal cashed with the O (RUKIA-AI-SEAL, b1a0); his
knockdown's oki (RUKIA-AI-OKI: the bind on his wake-up, else TSUKISHIRO; b2a0 / b1a1); his Step in met with J1
(RUKIA-AI-ANTI-STEP, b2a0); his charged dash met with the timed Hoho (RUKIA-AI-ANTI-DASH, b1a2); the timed Hoho
(RUKIA-AI-PERFECT-HOHO); his stun / recovery cashed by the cash table (RUKIA-AI-CASH, b1a0); at -50 the Hoho in
(RUKIA-AI-HOHO-IN); at a neutral decision against his dash form the wait (RUKIA-AI-MU-DASH, b1a2), his first-strike
envelope (RUKIA-AI-FRONT, b1a0), the Shikai's zone
(RUKIA-AI-ZONE: SP2 at >= 2 layers, the kido at 3-6.5 m), the bands' disc. A command or NIL. (Her confirms after a hit:
RUKIA-AI-LINK-L / RUKIA-AI-SP-ENDER, the confirm table.)"
  (or (and (eq (kit-form (kit-of e)) :zero) (rukia-ai-zero e b s d))
      (rukia-ai-seal e b s d)
      (rukia-ai-oki e b s d)
      (rukia-ai-anti-step e b s d)
      (rukia-ai-anti-dash e b s d)
      (rukia-ai-perfect-hoho e b s d)
      (rukia-ai-cash e b s d)
      (and (eq (kit-form (kit-of e)) :m50) (rukia-ai-hoho-in e b s d))
      (rukia-ai-mu-dash e b s d)
      (rukia-ai-front e b s d)
      (rukia-ai-zone e b s d)
      (rukia-ai-band-disc e b s d)))

(defun rukia-assist-guard (e b s d)
  "Her forms' :assist-guard (assist.lisp AUTO GUARD): her defensive answers only, REIDO at zero (a ward block, a Breaker)
and the timed Hohos (his charged dash's, b1a2; any committed move's)."
  (or (and (eq (kit-form (kit-of e)) :zero) (rukia-ai-zero e b s d))
      (rukia-ai-anti-dash e b s d)
      (rukia-ai-perfect-hoho e b s d)))

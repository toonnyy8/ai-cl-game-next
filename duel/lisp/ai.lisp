;;;; ai.lisp — BRAIN-SYSTEM: the CPU player (design-v1 §8, critique-design §5). Generic code: a
;;;; character's identity is the :AI table of its kit form (intents, ranges, weighted moves per
;;;; distance band, guard / Hoho chances, reactions). The CPU plays by writing its fighter's vpad
;;;; exactly like a keyboard (VPAD-SET!, VPAD-STICK!), once per fixed step, and draws every random
;;;; number from SIM-RND01: a seed replays the same match.
;;;;   perception  the opponent as he was DELAY steps ago (a ring buffer of SNAPs; EASY 24,
;;;;               NORMAL 14, HARD 8) — reaction time is the difficulty. What happens to the CPU
;;;;               itself (its own hit, its own blockstun) it feels at once.
;;;;   reflexes    first: the O ender off a completed string (red always, else the kit's :o-ender) / the next
;;;;               link / an SP cancel on hit; the rush on a red opponent in hitstun; punish a blocked ender; follow up a
;;;;               stunned opponent (Guard Break); punish a recovering one; answer an incoming Breaker
;;;;               or Kikon rush (guard it unless red); the kit's reactions (Kenpachi's stance);
;;;;               Breaker a long guard; guard or Hoho a committed move; awaken
;;;;   kikon       the rush on a red opponent (the O ender, on his hitstun, or at a neutral decision
;;;;               within the kit's :kikon-range), the button held through the strike: always the Kikon;
;;;;               on one who isn't red as the O ender (:o-ender) or a poke (the kit's :moves), which a hit
;;;;               turns into the follow-up. As the victim of a follow-up it guards it (*AI-FOLLOW-GUARD-P*)
;;;;   intents     APPROACH / PRESSURE / ZONE / DEFEND re-picked every *AI-REPICK* f: a preferred range
;;;;               to walk to, then a weighted move for the distance band
;;;;   heat        +*AI-HEAT-RATE*/s without dealing damage (x2 far apart): the preferred range
;;;;               shrinks, the Breaker weight doubles at 8 — this is what makes matches end
;;;;   gauges      guards less as its guard gauge runs low (steps aside instead), never guardless;
;;;;               presses a guardless opponent; keeps a Burst's flash-step when a Burst would be worth it
;;;;   cold        Rukia's kit keys: :cool (hold U to the next band), :brace (hold U at absolute zero)
;;;;   stances     kit keys: :cancel (end a landed string with L), :l-after-k (L after a K link that hit, p; :l-after-j the same after a J link), :low (L more often at low Reishi),
;;;;               :gg-low (below it: back off and zone), :block-string (go on with a string the opponent
;;;;               blocks: guard pressure), :sig-gg (L halved below it of the guard gauge: KYOKKO pierces with a
;;;;               full edge), :ward-reversal (Bankai West: L when the ward just took a hit up close); a parry is
;;;;               never attacked into; South's tell is stepped out of (the trap reflex); an opponent in a ward
;;;;               (Bankai West) is seen as guarding (SNAP-TAKE!): the Breaker reflex breaks it
;;;;   J beats K   out of a blocked link, J1 into the string's next K link while it has the frames (J-BEATS-K-P)
;;;;   burst       BLUE: combo'd past its 2nd hit for its perception delay, *FS-BURST* flash-step, and worth it
;;;;               (AI-BURST-WANTED-P): one roll per combo (*AI-BURST-P* by difficulty); ORANGE: a string link that
;;;;               hit with no link after it (AI-ORANGE-P), then Q1 in the startup-cut window (AI-CHAIN-FOLLOW-P);
;;;;               WHITE: behind on Reishi, far from him, at a neutral decision (AI-WHITE-P)
;;;;   dash        far outside its range (the kit's :dash-gap, else *AI-DASH-GAP*): hold Step toward it (the kit's :dash
;;;;               chance), or away from a too-close opponent (:dash-back), released once the range is reached
;;;;   tempo       kit keys: :tempo (x the neutral decision interval), :attack (+ the neutral attack chance),
;;;;               :neutral-guard (a neutral guard's chance, else :guard), :respect (frames in DEFEND after taking it,
;;;;               else *AI-RESPECT*): Kenpachi's cups keep NOME fed (docs/duel/DUEL_NOZARASHI_V2.md, "The CPU after the faster drain")
;;;;   learning    a CPU facing a human (VS CPU / ENDLESS, the LEARNING CPU setting) carries a learner (BRAIN-LEARN,
;;;;               ai-learn.lisp; learn.lisp): it predicts his next action per situation and answers it, and weighs the
;;;;               kit's :moves by a bandit; NIL (every CPU vs CPU, every gate): nothing of it runs (docs/duel/DUEL_LEARNING.md)
;;;; The kit's :ai keys the generic code reads (AI-TABLE, ai.lisp + assist.lisp; the one list: kit.lisp DEFKIT points here).
;;;; A kit's own CPU functions may read further keys of their own form (Lille's :stance :burst :far-dash :far-snipe ...).
;;;;   identity    :intents (:approach :pressure :zone :defend weights)  :ranges (intent -> (lo hi) m)
;;;;               :moves ((lo hi cmd w ...) ...) the weighted moves per distance band  :tempo  :attack  :respect
;;;;   defence     :guard p  :neutral-guard p  :hoho p  :react (:projectile cmd :flash-startup cmd)  :gg-low  :dash  :dash-back
;;;;               :dash-gap
;;;;   strings     :o-ender p  :string-k p  :cancel (:sig p ...)  :l-after-k p  :l-after-j p  :sp-cancel-bars n
;;;;               :block-string p  :low  :sig-gg  :stun-follow (cmd lo hi)  :oki :sp1-full  :oki-above fraction
;;;;   Kikon       :kikon-range m  :kikon-p p
;;;;   forms       :awaken (:melee-share :min-taken)  :awaken-above reishi-fraction  :bankai (:p :own-konpaku ...)
;;;;               :cashout (:punish :near :below)  :pip-hurry frames  :cool (:p :near :no-projectile :min-gg)
;;;;               :brace (:p :near :min-gg)  :ward-reversal p
;;;;   hooks       :reflex (e b s d)  :move-reflex (e b f mv)  :sp-ender  :sig-hold  :sp1-hold  :assist-guard  :assist-combo
;;;;               (:l-after-k / :l-after-j may name a function (e link L) -> its chance: Rukia's bursts)
;;;;   read by the OPPONENT's CPU: :opp-reflex (e b s d)  :opp-aim  :opp-reflect  :opp-intent (:zone n :defend n)
;;;;   steps       BRAIN-STEP's replaceable steps (AI-STEP; the user 2026-10-25: 「請逐步將共用 AI 的功能轉移給專屬 AI」): a kit
;;;;               names its own function for one in its :steps sub-plist (:steps (:held fn ...)), else the generic default
;;;;               in *AI-STEPS* runs (the same code as before):
;;;;               :block-hold (e b f) a guard just blocked a hit: hold on through the string?  (AI-BLOCK-HOLD)
;;;;               :held (e b f) before every generic choice, the press it holds: T = this step is spent (default none);
;;;;               a press made with :act :block-hold is held as :hold is (Rukia's post-block hold, which her :held lets go)
;;;;               :burst (e b) Burst / awakening out of a combo? (AI-BURST-ROLL)  :wake-guard (e b d) out of a hit, him close
;;;;               (AI-WAKE-STEP); AI-REFLEX's, each (e b s d) -> a command or NIL, in its old place: :anti-kikon (AI-ANTI-KIKON)
;;;;               :block-punish (AI-BLOCK-PUNISH)  :punish (AI-PUNISH)  :anti-rush (AI-ANTI-RUSH); AI-REFLEX's in-move ones,
;;;;               each (e b s d) -> :PASS or the command (NIL too ends the reflexes, AI-STEP-CLAIM): :o-ender :step-j
;;;;               :breaker-string :guard-cancel, the kit's :move-reflex, :string :orange :pressure (AI-O-ENDER ... AI-PRESSURE)
;;;;               and the free-state ones after the kit's :reflex / :opp-reflex (DEF-REFLEX-STEP): :ward-reversal :reset
;;;;               :kikon-rush :bankai :cashout :anti-bind :anti-parry :awaken :block-punish :follow-up :stun-follow :oki
;;;;               :punish :anti-rush :react :guard-break :threat
;;;;               AI-NEUTRAL's :intent (e b heat) -> the next intent (AI-PICK-INTENT); AI-DECIDE's, each (e b kit s d lo hi heat)
;;;;               -> :PASS or it decided (DEF-DECIDE-STEP): :neutral-kikon :white :pip-hurry, the habit (debug), :cool :brace
;;;;               :step-in :dash-in :dash-back :neutral-guard :neutral-attack
;;;;               AI-ATTACK's :attack-weights (e b kit s d heat hurry weights) -> the weights (AI-ATTACK-WEIGHTS); STRING-REFLEX's,
;;;;               each (e b f mv) -> :PASS or the command (DEF-STRING-STEP): :string-queued :string-bait :l-link :k-link :j-link
;;;;               :k-only :l-cancel, the kit's :sp-ender, :sp-cancel :end-orange; BRAIN-STEP's :chain-follow :j-beats-k :gap-step
;;;;               (e b s d) -> :PASS or it pressed (AI-BRAIN-CLAIM); AI-COMMAND's :command (b kit cmd d e) (AI-COMMAND-PRESS: how
;;;;               a command's buttons are held: charges, stances, the Breaker, the Kikon rush); the frame's (batch 8): :respect (e b)
;;;;               :wake (e b d) :event-rolls (b s) :strafe (e b) :walk (e b vp d lo hi) :decide-time (e b) (AI-RESPECT AI-WAKE
;;;;               AI-EVENT-ROLLS AI-STRAFE AI-WALK AI-DECIDE-TIME-DEFAULT)
;;;;               ASSIST's (batch 9, assist.lisp "STEPS"): :auto-guard :auto-combo :auto-break :auto-sp :auto-read
;;;;               the learning CPU's (batch 10, ai-learn.lisp): :learn-plan (b l sit) :learn-fire (e b s d) :learn-press
;;;;               (e b cmd d &optional anywhere) :learn-neutral (e b s d) :learn-weights (e l d weights) :burst-chance (b color p)
(in-package :duel)

(defstruct snap
  "What the CPU sees of its opponent at one step."
  (x 0f0 :type single-float) (z 0f0 :type single-float)
  (state :idle) (kind nil) (phase nil)
  (sf 0 :type fixnum) (s 0 :type fixnum) (active-end 0 :type fixnum)
  (left 0 :type fixnum)                 ; frames left of his move (99 = still charging / dashing) or stun
  (start 0 :type fixnum)                ; tick his current move / guard began (one roll per event)
  (reach 0f0 :type single-float) (guard-t 0 :type fixnum) (projectile nil)
  (flags nil)                           ; his move's :flags (:parry :bind ...)
  (contact nil)                         ; what his move touched so far (NIL = nothing yet: a whiff when it ends)
  (tell nil)                            ; a :bind move's tell frames (its :params :tell; NIL = South's 21-30)
  (yaw 0f0 :type single-float)          ; his facing
  (hold 0 :type fixnum)                 ; frames his :hold move has been held (its hold phase: the move frame)
  (move nil))                           ; his move (NIL: none): an :x-axis line's volumes, lock, params (SNAP-NEAR-P ...)

(defun snap-take! (s o)
  "Fill SNAP S with fighter O as he is now."
  (let* ((f (fighter o)) (p (pos-of o)) (mv (fighter-move f))
         (st (let ((st (fighter-state f)))                ; Bankai West's ward is a held guard (its time in West)
               (if (and (passive-p o :ward) (member st '(:idle :run))) :guard st))))
    (setf (snap-x s) (aref p 0) (snap-z s) (aref p 2) (snap-state s) st (snap-sf s) (fighter-sf f) (snap-yaw s) (yaw-of o)
          (snap-guard-t s) (fighter-guard-t f) (snap-projectile s) (incoming-projectile-p o))
    (if (and (eq st :move) mv)
        (let ((total (move-end-frame (mv-s mv) (mv-a mv) (mv-r mv) (mv-whiff mv) (fighter-contact f)
                                     (zerop (length (mv-hits mv))) (mv-kind mv))))
          (setf (snap-kind s) (mv-kind mv) (snap-phase s) (fighter-phase f) (snap-s s) (mv-s mv) (snap-flags s) (mv-flags mv)
                (snap-contact s) (fighter-contact f)
                (snap-tell s) (getf (mv-params mv) :tell)
                (snap-active-end s) (+ (mv-s mv) (mv-a mv)) (snap-reach s) (f32 (mv-reach mv))
                (snap-left s) (if (eq (fighter-phase f) :main) (max 0 (- total (fighter-sf f))) 99)
                (snap-start s) (- *match-tick* (fighter-sf f) (fighter-hold f))
                (snap-hold s) (fighter-hold f) (snap-move s) mv)
          (when (member :x-axis (mv-flags mv))           ; an :x-axis line: its real active window (every line of it)
            (setf (snap-active-end s) (move-active-end mv))))
        (setf (snap-kind s) nil (snap-phase s) nil (snap-reach s) 0f0 (snap-flags s) nil (snap-contact s) nil (snap-move s) nil
              (snap-left s) (if (eq st :stun) (max 0 (- (fighter-stun f) (fighter-sf f))) 0)
              (snap-start s) (if (eq st :guard) (- *match-tick* (fighter-guard-t f)) -1)))
    s))

(defun incoming-projectile-p (o)
  "Is one of O's projectiles flying at his opponent within *AI-PROJECTILE-RANGE*?"
  (let ((v (fighter-opp (fighter o))) (hit nil))
    (when (entity-alive-p v)
      (let ((q (pos-of v)) (r2 (* *ai-projectile-range* *ai-projectile-range*)))
        (do-entities (h (hz hazard))
          (when (and (eql (hazard-owner hz) o) (member (hazard-kind hz) '(:wave :fireball)) (> (hazard-hits-left hz) 0)
                     (< (+ (expt (- (hazard-x hz) (aref q 0)) 2) (expt (- (hazard-z hz) (aref q 2)) 2)) r2))
            (setf hit t)))))
    hit))

;;; ---------------------------------------------------------------- :x-axis lines (docs/duel/DUEL_LILLE.md §11.3, gap G1)
;;; A move flagged :x-axis is a line hit window across the arena. Every threat reader (here, and the kits' reflexes) asks
;;; SNAP-LIVE-P / SNAP-NEAR-P: a move without the flag takes the old test, unchanged (its active window, its reach + the
;;; reader's margin); a line takes its real threat window (KIT.LISP X-LIVE-P: an aim only from its lock) and E's feet
;;; against the line from his perceived feet along his perceived facing (X-LINE-GAP), at any distance.
(defun snap-x-axis-p (s) "Is his perceived move an :x-axis line?" (and (member :x-axis (snap-flags s)) t))
(defun snap-reflect-p (s)
  "Is his perceived move :reflectable (a perfect guard / Hoho at its :params :blast turns it back)? Only :OPP-REFLECT
answers it at its timing (AI-OPP-REFLECT): the kits' timed Hohos and the generic threat Hoho leave it alone."
  (and (member :reflectable (snap-flags s)) t))

(defun snap-live-p (s)
  "Is his perceived move S still to hit: before the end of its active frames (an :x-axis line: in its threat window)?"
  (if (snap-x-axis-p s)
      (x-live-p (snap-move s) (snap-phase s) (snap-hold s) (snap-sf s))
      (< (snap-sf s) (snap-active-end s))))

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

(defun x-on-line-p (s e)
  "Are E's feet on his perceived :x-axis line: within its radius + E's hurt radius + *AI-LINE-MARGIN*?"
  (let ((p (pos-of e)))
    (<= (x-line-gap (snap-move s) (snap-x s) (snap-z s) (snap-yaw s) (aref p 0) (aref p 2))
        (+ (body-hurt-r (model-body (model e))) *ai-line-margin*))))

(defun snap-seg-gap (s e)
  "How far E's feet are from his perceived move's :seg-fn capsules (kit.lisp SEG-GAP: their segment as his kit gives it now,
radius off), or NIL: no window of it has one (every move but those: the reach test, unchanged)."
  (let ((mv (snap-move s)) (p (pos-of e)))
    (and mv (seg-gap mv (opp-of e) (aref p 0) (aref p 2)))))

(defun snap-near-p (s e d margin)
  "Is E, at the perceived distance D, in reach of his perceived move S: D < its reach + MARGIN (an :x-axis line: E on the
line, X-ON-LINE-P, MARGIN aside; a :seg-fn window: E's feet within its capsule + E's hurt radius + MARGIN, SNAP-SEG-GAP)?"
  (if (snap-x-axis-p s)
      (x-on-line-p s e)
      (let ((g (snap-seg-gap s e)))
        (if g (< g (+ (body-hurt-r (model-body (model e))) margin)) (< d (+ (snap-reach s) margin))))))

(defun ranged-threat-in (e b s d lo hi)
  "The CPU's ranged-threat reader (docs/duel/DUEL_HISAGI.md §12.4 hook 8; unused until a kit's reflex asks it): does a
ranged hit reach E within LO..HI frames, as brain B perceives it? One of his hazards with hits left (moving: its distance
over its speed, after its delay; standing: its delay, touching E), or his perceived move S's next :ranged window
(KIT.LISP RANGED-WINDOW-LEAD, less the perception delay) with E in its reach (SNAP-NEAR-P: a line, a :seg-fn capsule, the
reach) beyond its :melee-range (nearer it is the blade). Lille's lines, waves, fireballs, walls and traces alike."
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

(defun ai-opp-aim (e b s d)
  "A CPU facing an aim (his kit's :opp-aim (:step :hoho :rush), read off his kit: other pairings never come here): his
:hold move flagged :x-axis, one roll per aim (BRAIN-AIM-KEY, its start tick), each chance x the difficulty (OPP-CHANCE):
  - perceived before his lock (MOVE-LOCK), :hoho of the time with flash-step for one: a Hoho (he reappears behind);
  - else :step of the time: within :rush m of him the rush at once (O within the kikon range, else the dash in), farther a
    sideways Step off his line, away from its side (LINE-OFF-STRAFE), once he is locked: on the lock it perceives when
    its delay is at most *AI-AIM-REACT* (HARD), else pre-Stepped at a rolled tick lock .. lock + *AI-AIM-PRE-STEP* from
    his perceived start (it would see the lock too late). Only while it stands on the line.
A command, :PRESSED (the dash), or NIL."
  (let* ((k (getf (kit-ai (kit-of (opp-of e))) :opp-aim)) (mv (snap-move s)))
    (when (and k mv (eq (snap-state s) :move) (mv-hold mv) (snap-x-axis-p s) (not (kit-rooted (kit-of e))))
      (let* ((lock (move-lock mv))
             (pre (and (eq (snap-phase s) :hold) (< (snap-hold s) lock)))   ; before his lock, as perceived
             (hoho-ok (hoho-ready-p e)))
        (when (/= (snap-start s) (brain-aim-key b))         ; a new aim: its one roll
          (let ((r (sim-rnd01))
                (ph (opp-chance (getf k :hoho 0.0) (brain-difficulty b))) (ps (opp-chance (getf k :step 0.0) (brain-difficulty b))))
            (setf (brain-aim-key b) (snap-start s)
                  (brain-aim-plan b) (cond ((and (< r ph) pre hoho-ok) :hoho)
                                           ((>= r (+ ph ps)) nil)
                                           ((< d (getf k :rush 0.0)) :rush)
                                           (t :step))
                  (brain-aim-t b) (if (or (not (eq (brain-aim-plan b) :step)) (<= (brain-delay b) *ai-aim-react*)) -1
                                      (+ (snap-start s) lock (floor (* (sim-rnd01) (1+ *ai-aim-pre-step*))))))))
        (case (brain-aim-plan b)
          (:hoho (setf (brain-aim-plan b) nil)
                 (and pre hoho-ok (why b :aim-hoho :hoho)))
          (:rush (setf (brain-aim-plan b) nil)
                 (cond ((and (< d (ai-table e :kikon-range 7.0)) (kit-command-ok-p e :kikon)) (why b :aim-rush :kikon))
                       (t (ai-dash b 1.0 1.8) (why b :aim-rush :pressed))))
          (:step (when (and (if (minusp (brain-aim-t b))
                                (not pre)                              ; the lock perceived (or his release)
                                (>= *match-tick* (brain-aim-t b)))     ; the pre-Step's rolled tick
                            (or (eq (snap-phase s) :hold) (< (snap-sf s) (snap-active-end s)))   ; (not after his shot)
                            (x-on-line-p s e))
                   (setf (brain-aim-plan b) nil
                         (brain-strafe b) (f32 (let ((p (pos-of e)))
                                                 (line-off-strafe (snap-x s) (snap-z s) (snap-yaw s) (aref p 0) (aref p 2)
                                                                  (snap-x s) (snap-z s)))))
                   (why b :aim-step :side-step))))))))

(defun ai-opp-reflect (e b s d)
  "A CPU facing a :reflectable move (his kit's :opp-reflect (:p), read off his kit: other pairings never come here): one
roll per move (BRAIN-REFLECT-KEY, its start tick) at :p x the difficulty (OPP-CHANCE); a yes times the reflect at its
:params :blast frame (else its S), his move frame counted as perceived (SNAP-SF + the delay: REFLECT-ACTION): a guard
pressed *AI-REFLECT-GUARD-LEAD* before it (FIGHTER-GUARD-T 2-10 there), or where the guard can't (a ward, a form whose U
is a move, guardless: AI-GUARD-K 0) a Hoho *AI-REFLECT-HOHO-LEAD* before it; hands off (:WAIT, a held guard let go) just
before the press. Rooted forms can't (they must not stand in it). A command, :PRESSED / :WAIT, or NIL."
  (declare (ignore d))
  (let* ((k (getf (kit-ai (kit-of (opp-of e))) :opp-reflect)) (mv (snap-move s)))
    (when (and k mv (eq (snap-state s) :move) (eq (snap-phase s) :main) (snap-reflect-p s) (not (kit-rooted (kit-of e))))
      (when (/= (snap-start s) (brain-reflect-key b))
        (setf (brain-reflect-key b) (snap-start s)
              (brain-reflect-go b) (< (sim-rnd01) (opp-chance (getf k :p 0.0) (brain-difficulty b)))))
      (when (brain-reflect-go b)
        (let* ((guard (and (plusp (ai-guard-k e)) (not (passive-p e :ward))))
               (act (reflect-action (+ (snap-sf s) (brain-delay b)) (getf (mv-params mv) :blast (mv-s mv)) guard)))
          (case act
            (:wait (setf (brain-press-left b) 0) (why b :reflect-wait :wait))
            (:guard (setf (brain-reflect-go b) nil)
                    (ai-press b :guard (+ *ai-reflect-guard-lead* 12) :act :hold)   ; (held through the blast)
                    (why b :reflect :pressed))
            (:hoho (setf (brain-reflect-go b) nil)
                   (and (hoho-ready-p e) (why b :reflect :hoho)))
            (:late (setf (brain-reflect-go b) nil) nil)))))))

;;; ---------------------------------------------------------------- pressing buttons
(defun ai-press (b button frames &key modded (act button))
  "Hold BUTTON (with :MOD when MODDED) for FRAMES steps, starting now."
  (setf (brain-press b) button (brain-press-mod b) modded (brain-press-left b) (max 1 frames) (brain-act b) act))

(defun ai-dash (b dir to)
  "Hold Step (the hop, then the run) with the stick toward (DIR 1) or away from (-1) the opponent,
until the distance passes TO (BRAIN-STEP lets go)."
  (ai-press b :step *ai-dash-frames* :act :dash)
  (setf (brain-dash b) (f32 dir) (brain-dash-to b) (f32 to)))

(defun ai-awaken-break-p (e &optional b)
  "Could E's CPU awaken out of this combo (the awakening breaks it as a Burst does)? Ready (EVOLUTION), in a state that
allows it (AWAKEN-STATE-P) and its kit's rule says awaken (:awaken-above, AI-AWAKEN-P); or, with its brain B, the second
awakening (Kenpachi's Bankai, Lille's revival: BANKAI-READY-P, the kit's :bankai rule AI-BANKAI-P, its one roll per
stay), which breaks a combo the same way since the user 2026-10-09 (DUEL_KEN_REWORK §7)."
  (let ((g (gauges e)))
    (or (and (gauges-evolution g) (awaken-state-p e (fighter e))
             (>= (reishi-frac g) (ai-table e :awaken-above 0.0))
             (ai-awaken-p e))
        (let ((bk (ai-table e :bankai)))
          (and b bk (bankai-ready-p e) (ai-bankai-p e b bk) t)))))

(defun ai-kikon-futile-p (e)
  "Is E's Kikon futile in this DANGAI stage (DUEL_ROGUE §4.4): his opponent's Kikon is always guarded (:kikon-guard), or
the Kikon is sealed for both sides (:kikon-seal)? NIL outside a run."
  (and *run-mods* (or (rmod (opp-of e) :kikon-guard nil) (rmod *run-mods-who* :kikon-seal nil)) t))

(defun ai-sb-finish-p (e)
  "E's opponent is nearly out of Reishi (under *AI-SB-FINISH* of his max): finish him with hits, the Soul Break (the
Kikon count + 1), not the Kikon rush he might still guard or dodge. Always, when the Kikon is futile (AI-KIKON-FUTILE-P:
every Kikon site asks this, so the CPU fights on to the Soul Break)."
  (or (ai-kikon-futile-p e)
      (let ((go (gauges (opp-of e)))) (< (gauges-reishi go) (* *ai-sb-finish* (gauges-reishi-max go))))))
(defun ai-o-ender-ok-p (e kit)
  "May E's CPU press the O ender now: no Soul Break finish due (AI-SB-FINISH-P) and KIT's Kikon command open?"
  (and (not (ai-sb-finish-p e)) (kit-command-ok-p e :kikon kit t)))

(defun ai-burst-roll (e b)
  "Burst Reverse (or the awakening, which breaks a combo too: AI-AWAKEN-BREAK-P) now? No sooner than the perception
delay after the combo's 2nd hit (BRAIN-BURST-T), allowed (BURST-OK-P) and worth it (AI-BURST-WANTED-P, the next hit
estimated as the combo's average so far): one roll per combo at the difficulty's *AI-BURST-P*. In blockstun: a
string the guard lock holds him in while his guard gauge is low (AI-GG-LOW-P), one roll per locked string."
  (let ((f (fighter e)) (g (gauges e)))
    (when (and (not (brain-burst-rolled b)) (>= (brain-burst-t b) (brain-delay b)) (or (burst-ok-p e) (ai-awaken-break-p e b))
               (or (eq (fighter-state f) :guard-hit)      ; (the clock runs there only for a guard-locked string on a low guard)
                   (eq (brain-habit b) :burst)           ; (debug: the burst-happy scripted player, whenever it may)
                   (ai-burst-wanted-p (gauges-reishi g) (gauges-reishi-max g)
                                      (floor (fighter-combo-dmg f) (max 1 (fighter-combo-hits f))))))
      (setf (brain-burst-rolled b) t)
      (ai-burst-rolled e b (burst-ok-p e) (if (eq (brain-habit b) :burst) 1.0   ; (debug: the burst-happy scripted player)
                                               (getf *ai-burst-p* (brain-difficulty b) 0.4))))))

(defun ai-command (b kit cmd d &optional e)
  "Press the buttons of kit command CMD at distance D: KIT's own :command step (its :ai :steps, given the fighter E; batch 7,
2026-10-25), else AI-COMMAND-PRESS."
  (let ((h (and e (getf (getf (kit-ai kit) :steps) :command))))
    (if h (funcall h b kit cmd d e) (ai-command-press b kit cmd d e))))

(defun ai-command-press (b kit cmd d &optional e)
  "The generic :command step: press the buttons of kit command CMD at distance D (holding charge / stance / Breaker moves a
while: a charge move is held to its full charge from beyond 7 m, where it has the time)."
  (let ((r (sim-rnd01))
        (cmd (if (and (kit-rooted kit) (member cmd '(:hoho :side-step :step))) :q cmd)))   ; rooted (Rukia's zero / THAW)
    (flet ((hold-for (mv lo spread) (if (and mv (mv-hold mv)) (+ lo (floor (* r spread))) 1)))   ; (NIL: a form without it)
      (case cmd
        (:q (ai-press b :quick 1))
        (:f (ai-press b :flash 1))
        (:sig (ai-press b :sig (let ((h (getf (kit-ai kit) :sig-hold)))   ; a kit's own hold length (its :sig-hold function)
                                 (if h (funcall h kit d e) (hold-for (kit-command-move kit :sig) 12 40)))))
        ((:sp1 :sp1-full)                                 ; :sp1-full: a charge move held to its end
         (let ((mv (kit-command-move kit :sp1)) (h (getf (kit-ai kit) :sp1-hold)))   ; (a kit's own hold length: its
           (ai-press b :flash (cond (h (funcall h kit d e))                         ;  :sp1-hold function, Rukia's tap / hold)
                                    ((and mv (mv-hold mv) (or (eq cmd :sp1-full) (> d 7.0))) (+ 2 (second (mv-hold mv))))
                                    (t (hold-for mv 14 46)))
                     :modded t :act :sp1)))
        (:sp2 (ai-press b :sig (if (< r 0.4) 20 1) :modded t :act :sp2))
        (:breaker (ai-press b :breaker (+ 12 (floor (* r 30)))))
        (:step (ai-press b :step 1))
        (:side-step (ai-press b :step 1 :act :side-step))  ; BRAIN-STEP holds the stick sideways
        (:hoho (ai-press b :step 1 :modded t :act :hoho))
        (:guard (ai-press b :guard (+ 10 (floor (* r 20)))))
        (:guard-long (ai-press b :guard 60 :act :guard))    ; through a stagger and the dash-in after it (40 until the
                                                            ;  follow-up's 41 f, 2026-10-24)
        (:guard-cancel (ai-press b :guard 4))               ; the guard cancel, then neutral decides
        (:kikon (let ((mv (kit-command-move kit :kikon)))                ; held through the strike (aura + dash + S)
                  (ai-press b :kikon (+ (rush-param mv :aura) (rush-param mv :dash-max) (mv-s mv) 4))))
        (:awaken (ai-press b :awaken 1))
        (:burst (ai-press b :quick 1 :modded t :act :burst))))))   ; the state picks the mode

;;; ---------------------------------------------------------------- decisions
(defun ai-table (e key &optional default) (getf (kit-ai (kit-of e)) key default))

(defparameter *ai-steps* '(:block-hold ai-block-hold :held nil :burst ai-burst-roll :wake-guard ai-wake-step
                           :anti-kikon ai-anti-kikon :block-punish ai-block-punish :punish ai-punish :anti-rush ai-anti-rush
                           :o-ender ai-o-ender :step-j ai-step-j :breaker-string ai-breaker-string :guard-cancel ai-guard-cancel
                           :string ai-string :orange ai-orange :pressure ai-pressure
                           :learn-plan learn-plan :learn-fire learn-fire :learn-press learn-press :learn-neutral learn-neutral
                           :learn-weights learn-weights :burst-chance ai-burst-chance
                           :auto-guard auto-guard :auto-combo auto-combo :auto-break auto-break :auto-sp auto-sp :auto-read auto-read
                           :respect ai-respect :wake ai-wake :event-rolls ai-event-rolls :strafe ai-strafe :walk ai-walk
                           :decide-time ai-decide-time-default :chain-follow ai-chain-follow :j-beats-k ai-j-beats-k :gap-step ai-gap-step :command ai-command-press
                           :attack-weights ai-attack-weights :string-queued ai-string-queued :string-bait ai-string-bait :l-link ai-l-link :k-link ai-k-link :j-link ai-j-link :k-only ai-k-only :l-cancel ai-l-cancel :sp-cancel ai-sp-cancel :end-orange ai-end-orange
                           :intent ai-pick-intent :neutral-kikon ai-neutral-kikon :white ai-white :pip-hurry ai-pip-hurry :cool ai-cool :brace ai-brace :step-in ai-step-in :dash-in ai-dash-in :dash-back ai-dash-back :neutral-guard ai-neutral-guard :neutral-attack ai-neutral-attack
                           :ward-reversal ai-ward-reversal :reset ai-reset :kikon-rush ai-kikon-rush :bankai ai-bankai :cashout ai-cashout :anti-bind ai-anti-bind :anti-parry ai-anti-parry :awaken ai-awaken :follow-up ai-follow-up :stun-follow ai-stun-follow :oki ai-oki :react ai-react :guard-break ai-guard-break :threat ai-threat)
  "BRAIN-STEP's replaceable steps and their generic defaults (NIL: no default, the step is skipped); a kit's :ai names
its own (the header's \"steps\"; one moved over at a time, each proved to leave the other kits' matches unchanged).")

(defun ai-step (e name)
  "The function E's CPU runs for step NAME: its kit's own (the :ai plist's :steps sub-plist, apart from the other keys: a
kit's :burst / :punish tables are not steps), else *AI-STEPS*'s default (NIL: none)."
  (or (getf (ai-table e :steps) name) (getf *ai-steps* name)))

(defun ai-step-cmd (e name b s d)
  "AI-REFLEX's step NAME (e b s d) -> a command or NIL (NIL too when it has no function)."
  (let ((h (ai-step e name))) (and h (funcall h e b s d))))

(defun ai-block-hold (e b f)
  "The generic :block-hold step (blockstun's first step): keep holding Guard through the string with *AI-HOLD-GUARD*'s
chance, to the blockstun's end + 20 steps (no reflex drops it: BRAIN-STEP)."
  (declare (ignore e))
  (when (< (sim-rnd01) (getf *ai-hold-guard* (brain-difficulty b) 0.85))
    (ai-press b :guard (+ (fighter-stun f) 20) :act :hold)))

(defvar *ai-brain* nil
  "The brain deciding for a fighter that has none (a human): the ASSIST's borrowed brain while ASSIST-STEP runs for him.")

(defun ai-brain (e)
  "E's deciding brain for the kits' CPU code (their :sp-ender, :sig-hold, :assist-guard ...): the assist's while it runs for
him (*AI-BRAIN*; the gate's masher has a brain of its own), else his own (a CPU), else NIL."
  (or *ai-brain* (brain e)))

(defun ai-chance (e plist)
  "PLIST's chance (:easy :normal :hard) at E's CPU difficulty: its brain's (AI-BRAIN: an assisted human's is the assist's
HARD one); no brain: NORMAL's."
  (let ((b (ai-brain e))) (if b (brain-chance b plist) (getf plist :normal 0.0))))

(defun ai-event-rolls (b s)
  "One roll per opponent action (his SNAP S starts a new one): brain B's guard / Hoho / reaction rolls (AI-REFLEX; the
assist's AUTO GUARD for the kit's :assist-guard)."
  (when (/= (snap-start s) (brain-roll-key b))
    (setf (brain-roll-key b) (snap-start s) (brain-guard-roll b) (sim-rnd01) (brain-hoho-roll b) (sim-rnd01)
          (brain-react-roll b) (sim-rnd01))))

(defun why (b reason cmd) "Note REASON (debug) and return CMD." (setf (brain-why b) reason) cmd)

(defun ai-gg (e) "E's guard gauge as a fraction." (/ (gauges-gg (gauges e)) *gg-max*))

(defun ai-guard-k (e)
  "How much of its guard chance E's CPU uses (AI-GUARD-MULT); none in a form whose U is a move (a :u hook: its own
:reflex presses it)."
  (if (kit-hook (kit-of e) :u) 0.0 (ai-guard-mult (gauges-gg (gauges e)) (gauges-guardless (gauges e)))))

(defun ai-gg-low-p (e)
  "Below the kit's :gg-low of its guard gauge: back off, zone while it refills."
  (let ((k (ai-table e :gg-low))) (and k (< (ai-gg e) k))))

(defun guarding-p (e)
  "E holds a guard: :guard / :guard-hit, or Bankai West's ward."
  (or (member (state-of e) '(:guard :guard-hit)) (passive-p e :ward)))

(defun ai-cancel-p (e kit)
  "End a landed string with the kit's :cancel command (L, a :cancel Signature) now? Its chance, and it may start."
  (let* ((c (ai-table e :cancel)) (p (getf c :sig)) (mv (kit-command-move kit :sig)))
    (and p mv (member :cancel (mv-flags mv)) (kit-command-ok-p e :sig) (< (sim-rnd01) p))))

;;; ---------------------------------------------------------------- STRING-REFLEX's steps (batch 6, 2026-10-25): claiming steps
;;; (AI-STRING-CLAIM, :PASS when the clause's test fails, else its value, NIL too: it ends the string reflex as the clause did)
(defun ai-string-claim (e name b f mv)
  "STRING-REFLEX's step NAME (e b f mv): :PASS (not this one) or its command (NIL included)."
  (let ((h (ai-step e name))) (if h (funcall h e b f mv) :pass)))

(defmacro def-string-step (name doc test &body body)
  "A claiming STRING-REFLEX step NAME (e b f mv): BODY's value when TEST holds, else :PASS; STRING-REFLEX's locals bound: KIT,
NQ / NF (the J / K links KIT-NEXT allows; no K link with no pip of the arm), BARS (her Reiatsu bars)."
  `(defun ,name (e b f mv)
     ,doc
     (let* ((kit (fighter-kit f))
            (nq (kit-next kit (mv-name mv) :q))
            (nf (let ((n (kit-next kit (mv-name mv) :f)))
                  (and n (not (and (kit-pip-cmd-p kit :f) (< (gauges-meter (gauges e)) 1f0))) n)))   ; no pip: no K link
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
    (and (plusp p) (= (fighter-sf f) (fighter-land-sf f)) l (kit-command-ok-p e :sig kit nil l)   ; one roll per hit
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
  "Our link hit: go on with the string (the next link K *AI-STRING-FLASH-P* of the time, among the links KIT-NEXT
allows: after a switch only one; pressed once, the latch does the rest), or end it with L (the kit's :cancel), else
cancel into SP2 when the victim is on the ground (a launched victim would drop out of it) and the kit's
:sp-cancel-bars are there, *AI-SP-CANCEL-P* of the time (link 3 staggers / crumples: SP2 always combos off it)."
  (let ((kit (fighter-kit f)) (r nil))
    (setf (brain-why b) :string)
    (cond ((not (eq (setq r (ai-string-claim e :string-queued b f mv)) :pass)) r)   ; its steps in order (batch 6, *AI-STEPS*)
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

(defun ai-orange-p (e b f)
  "CHAIN REVERSE (ORANGE) out of a string link that hit and has no link after it? Allowed (BURST-OK-P :orange), the victim
reeling on the ground within Q1's reach, and healthy (a Burst isn't worth keeping the flash-step for: AI-BURST-WANTED-P):
one roll (*AI-ORANGE-P* by difficulty)."
  (let ((g (gauges e)) (o (opp-of e)))
    (and (eq (burst-ok-p e) :orange) (eq (state-of o) :stun)
         (< (fighter-dist f) (+ (mv-reach (kit-command-move (fighter-kit f) :q)) 0.2))
         (not (ai-burst-wanted-p (gauges-reishi g) (gauges-reishi-max g) 0))
         (ai-burst-rolled e b :orange (getf *ai-orange-p* (brain-difficulty b) 0.25)))))

(defun ai-chain-follow-p (e)
  "In ORANGE's startup-cut window, free, the victim still reeling within Q1's reach: restart the string (felt at once:
its own combo)."
  (let ((f (fighter e)))
    (and (plusp (fighter-chain f)) (member (fighter-state f) '(:idle :guard)) (zerop (fighter-lock f))
         (not (vpad-down (pilot-vpad (pilot e)) :quick))   ; (J still held from the burst's press: let go first, a new press)
         (member (state-of (opp-of e)) '(:stun :air))
         (< (fighter-dist f) (+ (mv-reach (kit-command-move (fighter-kit f) :q)) 2.0)))))   ; (it chases: FIGHTER-END-CHASE)

(defun ai-white-p (e b s d)
  "SOUL REVERSE (WHITE) at a neutral decision: allowed, at least *AI-WHITE-RANGE* m from an opponent not attacking, behind
on Reishi by *AI-WHITE-BEHIND* of the max (fractions), *AI-WHITE-P* of the time."
  (let ((g (gauges e)) (go (gauges (opp-of e))))
    (and (eq (burst-ok-p e) :white) (>= d *ai-white-range*) (not (eq (snap-state s) :move))
         (>= (- (reishi-frac go) (reishi-frac g))
             *ai-white-behind*)
         (ai-burst-rolled e b :white *ai-white-p*))))

(defvar *ai-bankai-mode* (vector nil nil)
  "Per side, the CPU's Bankai entry: NIL = the kit's :bankai rule (AI-BANKAI-P), :SURE = the rule with its chance 1,
:ALWAYS = whenever allowed, :NEVER (debug 31000 + 10 a + b: the gamble A/B, docs/duel/DUEL_KEN_BANKAI.md).")

(defun ai-bankai-p (e b bk)
  "Enter the Bankai now (the kit's :bankai (:p :opp-below :opp-konpaku :own-konpaku); BANKAI-ALLOWED-P holds: he has
<= *BANKAI-KONPAKU* left, no longer red, the user's decision 2026-09-28)? One roll per cup-3 stay. The entry leaves him 1 Konpaku, so he weighs his own: nothing to lose when he has no more than the
opponent's next Soul Break would take (its count + 1, capped); else only as a finisher (the opponent at <= :opp-below of
his Reishi or <= :opp-konpaku Konpaku) with <= :own-konpaku left."
  (case (svref *ai-bankai-mode* (fighter-side (fighter e)))
    (:always t)
    (:never nil)
    (t (unless (brain-bankai-rolled b)
         (let* ((o (opp-of e)) (go (gauges o)) (k (gauges-konpaku (gauges e)))
                (threat (min *soul-break-max-event* (+ (kikon-worth o) *soul-break-extra*))))
           (when (or (<= k threat)
                     (and (<= k (getf bk :own-konpaku 9))
                          (or (<= (gauges-reishi go) (* (getf bk :opp-below 0.0) (gauges-reishi-max go)))
                              (<= (gauges-konpaku go) (getf bk :opp-konpaku 0)))))
             (setf (brain-bankai-rolled b) t)
             (< (sim-rnd01) (if (eq (svref *ai-bankai-mode* (fighter-side (fighter e))) :sure) 1.0 (getf bk :p 0.0)))))))))

(defvar *ai-awaken-mode* (vector nil nil)
  "Per side, the CPU's awakening on EVOLUTION: NIL = the kit's :awaken rule (AI-AWAKEN-P), :ALWAYS, :NEVER (debug 39000 + 10 a
+ b: Rukia's awaken A/B, docs/duel/DUEL_RUKIA.md §9).")

(defun ai-awaken-p (e)
  "Awaken now (EVOLUTION)? The debug mode, else the kit's :awaken (:melee-share :min-taken): only once E has taken
>= :min-taken damage, >= :melee-share of it from blades (Rukia: her cold body answers a melee opponent); no key: yes."
  (case (svref *ai-awaken-mode* (fighter-side (fighter e)))
    (:always t)
    (:never nil)
    (t (let ((r (ai-table e :awaken)) (g (gauges e)))
         (or (null r)
             (let* ((m (gauges-taken-melee g)) (all (+ m (gauges-taken-ranged g))))
               (and (>= all (getf r :min-taken 0)) (>= m (* (getf r :melee-share 0.0) all)))))))))

(defun ai-cool-p (e s d)
  "The kit's :cool (:p :near :no-projectile :min-gg): at a neutral decision within :near m (no projectile of his out, with
:no-projectile; the guard gauge at least :min-gg %: the crack comes from crushes), hold U to cool to the next band
(Rukia's cold gauge), :p of the time."
  (let ((c (ai-table e :cool)))
    (and c (< d (getf c :near 3.0)) (not (and (getf c :no-projectile) (snap-projectile s)))
         (>= (gauges-gg (gauges e)) (getf c :min-gg 0)) (< (sim-rnd01) (getf c :p 0.0)))))

(defun ai-brace-p (e d)
  "The kit's :brace (:p :near :min-gg): at absolute zero, hold U (bracing stops the warming, drains the guard gauge) while
he is within :near m and the guard gauge is at least :min-gg %, :p of the decisions."
  (let ((c (ai-table e :brace)))
    (and c (< d (getf c :near 5.5)) (>= (gauges-gg (gauges e)) (getf c :min-gg 0)) (< (sim-rnd01) (getf c :p 1.0)))))

;;; ---------------------------------------------------------------- AI-REFLEX's replaceable steps (*AI-STEPS*: the defaults, the
;;; code these clauses held before 2026-10-25, moved as written; the same rolls in the same order)
(defun ai-anti-kikon (e b s d)
  "A Kikon rush's strike hit us, O held, and it dashes in after us: not red, hold guard from inside the stagger
(*AI-FOLLOW-GUARD-P* by difficulty); red, nothing guards it."
  (declare (ignore d))
  (and (eq (fighter-state (fighter e)) :stun) (eq (snap-kind s) :kikon) (eq (snap-phase s) :follow)
       (not (gauges-red-p (gauges e))) (plusp (ai-guard-k e))
       (< (brain-react-roll b) (getf *ai-follow-guard-p* (brain-difficulty b) 0.85))
       (why b :anti-kikon :guard-long)))

(defun ai-block-punish (e b s d)
  "We just blocked an ender (-12 ...): it's our turn, felt at once (no perception delay); a K3 (-20) HARD punishes with K1
when it reaches."
  (declare (ignore s d))
  (let* ((f (fighter e)) (kit (fighter-kit f)) (q (kit-command-move kit :q)))
    (and (eq (brain-was b) :guard-hit) (<= (fighter-block-adv f) *ai-punish-adv*)
         (< (fighter-dist f) (+ (mv-reach q) 0.4))
         (< (sim-rnd01) (getf *ai-block-punish-p* (brain-difficulty b) 0.5))
         (why b :block-punish
              (if (and (eq (brain-difficulty b) :hard) (<= (fighter-block-adv f) -20)
                       (< (fighter-dist f) (mv-reach (kit-command-move kit :f))))
                  :f :q)))))

(defun ai-punish (e b s d)
  "A recovering opponent in reach: punish (J1)."
  (let ((q (kit-command-move (kit-of e) :q)))
    (and (snap-recovering-p s) (>= (snap-left-seen s b) (mv-s q)) (< d (+ (mv-reach q) 0.4))
         (why b :punish :q))))

(defun ai-anti-rush (e b s d)
  "An incoming Breaker, a Kikon rush, or a rush's follow-up strike coming (it hit us, not red): guard a rush when not red
(the chance by difficulty); else Hoho through its dash (flash-step); a Breaker: J1 as its dash runs into J1's reach (J beats
I, docs/duel/DUEL_STRINGS.md §14: waiting till then); a rush: Q1 it while it has the room, else Step sideways (a Hoho in
the aura only reappears in front of the dash)."
  (let* ((q (kit-command-move (kit-of e) :q)) (red (gauges-red-p (gauges e))) (hoho-ok (hoho-ready-p e)) (guard-k (ai-guard-k e)))
    (and (member (snap-kind s) '(:breaker :kikon)) (member (snap-phase s) '(:aura :dash :follow))
         (< d (if (eq (snap-phase s) :follow) (+ (snap-reach s) *ai-threat-margin*) *ai-anti-breaker-range*))
         (< (brain-react-roll b) (getf *ai-anti-breaker-p* (brain-difficulty b) 0.5))
         (or (not (eq (snap-kind s) :breaker))
             (and (eq (snap-phase s) :dash)
                  (or (and hoho-ok (< (brain-hoho-roll b) (ai-table e :hoho 0.2))) (< d (+ (mv-reach q) *ai-anti-breaker-j*)))))
         (why b :anti-breaker
              (cond ((and (eq (snap-kind s) :kikon) (not red) (plusp guard-k)) :guard)
                    ((and (eq (snap-phase s) :dash) hoho-ok (< (brain-hoho-roll b) (ai-table e :hoho 0.2)))
                     :hoho)
                    ((eq (snap-kind s) :breaker) :q)
                    ((> d *ai-anti-breaker-q*) :q)
                    (t :side-step))))))

;;; ---------------------------------------------------------------- AI-REFLEX's in-move steps (batch 3, 2026-10-25): each returns
;;; :PASS when its clause's test fails, else the clause's value (NIL too: as before, it ends the reflexes); moved as written
(defun ai-step-claim (e name b s d)
  "AI-REFLEX's claiming step NAME (e b s d): :PASS (not this one, the reflexes go on) or its command (NIL included)."
  (let ((h (ai-step e name))) (if h (funcall h e b s d) :pass)))

(defun ai-o-ender (e b s d)
  "Our completed string (a link-3 hit): the O ender, on a red opponent always, else the kit's :o-ender chance; one roll, on
the first step we see the hit (its land frame)."
  (declare (ignore s d))
  (let* ((f (fighter e)) (mv (fighter-move f)) (kit (fighter-kit f)))
    (if (and (eq (fighter-state f) :move) (eq (fighter-contact f) :hit) (member :ender (mv-flags mv)) (not (ai-sb-finish-p e))
             (= (fighter-sf f) (fighter-land-sf f)) (kit-command-ok-p e :kikon kit t)
             (or (kikon-ready-p e) (< (sim-rnd01) (ai-table e :o-ender *ai-o-ender*))))
        (why b :o-ender :kikon)
        :pass)))

(defun ai-step-j (e b s d)
  "Step -> J: our Step lands him within J1's reach and he isn't mid-attack (a Breaker is: J beats it): J at f10, the latch
starts J1 at the Step's *STEP-J-CANCEL*; one roll per Step."
  (declare (ignore d))
  (let* ((f (fighter e)) (q (kit-command-move (fighter-kit f) :q)))
    (if (and (eq (fighter-state f) :step) (= (fighter-sf f) (- *step-j-cancel* 2)) q
             (< (fighter-dist f) (+ (mv-reach q) *ai-step-j-margin*))   ; (our own hop)
             (not (and (eq (snap-state s) :move) (< (snap-sf s) (snap-active-end s)) (not (eq (snap-kind s) :breaker))))
             (not (eq (snap-state s) :hoho))
             (< (sim-rnd01) (getf *ai-step-j-p* (brain-difficulty b) 0.0)))
        (why b :step-j :q)
        :pass)))

(defun ai-breaker-string (e b s d)
  "Our Breaker landed (a hit or a Guard Break): open a string off it, K1 the kit's :string-k share of the time."
  (declare (ignore s d))
  (let* ((f (fighter e)) (mv (fighter-move f)) (kit (fighter-kit f)))
    (if (and (eq (fighter-state f) :move) (eq (fighter-contact f) :hit) (eq (mv-kind mv) :breaker) (>= (fighter-sf f) (fighter-land-sf f)))
        (flet ((ok (c) (and (or (kit-command-move kit c) (kit-drop kit c)) (kit-command-ok-p e c))))
          (why b :breaker-string (cond ((and (ok :f) (< (sim-rnd01) (ai-table e :string-k *ai-string-flash-p*))) :f)
                                       ((ok :q) :q) ((ok :f) :f))))
        :pass)))

(defun ai-guard-cancel (e b s d)
  "Our hit landed and only the guard cancel's share of its recovery is left (no link latched): guard out of it, unless we see
him still reeling past our recovery's end."
  (declare (ignore d))
  (let* ((f (fighter e)) (mv (fighter-move f)))
    (if (and (eq (fighter-state f) :move) (not (fighter-queued f))
             (guard-cancel-open-p (fighter-sf f) (mv-s mv) (mv-a mv) (mv-r mv) (fighter-contact f) (mv-kind mv) (mv-whiff mv) (getf (mv-params mv) :gc-from))
             (not (and (member (snap-state s) '(:stun :air :down :wakeup))
                       (> (snap-left-seen s b) (- (mv-total mv) (fighter-sf f))))))
        (why b :guard-cancel :guard-cancel)
        :pass)))

(defun ai-string (e b s d)
  "Our own hit: finish the string, else an SP / L cancel (STRING-REFLEX)."
  (declare (ignore s d))
  (let* ((f (fighter e)) (mv (fighter-move f)))
    (if (and (eq (fighter-state f) :move) (eq (fighter-contact f) :hit) (member (mv-kind mv) '(:quick :flash)))
        (string-reflex e b f mv)
        :pass)))

(defun ai-orange (e b s d)
  "Our L / O hit him (he reels): CHAIN REVERSE (ORANGE) on it too, as off a string's last link."
  (declare (ignore s d))
  (let* ((f (fighter e)) (mv (fighter-move f)))
    (if (and (eq (fighter-state f) :move) (eq (fighter-contact f) :hit) (member (mv-kind mv) '(:sig :kikon))
             (= (fighter-sf f) (fighter-land-sf f)) (ai-orange-p e b f))
        (why b :orange :burst)
        :pass)))

(defun ai-pressure (e b s d)
  "Guard pressure (the kit's :block-string): a link the opponent blocked goes on, pressed just before the chain opens (one
roll per link): a J link, a K link only *AI-BLOCK-K-P* of the time (his J interrupts it), never a punishable ender (K3): the
string resets instead (AI-REFLEX's reset); not below :gg-low or into a parry."
  (declare (ignore s d))
  (let* ((f (fighter e)) (mv (fighter-move f)))
    (if (and (eq (fighter-state f) :move) (eq (fighter-contact f) :block) (member (mv-kind mv) '(:quick :flash))
             (ai-pressure-p e) (= (fighter-sf f) (- (mv-total mv) *chain-lead* 1)))
        (let* ((kit (fighter-kit f)))
          (flet ((ok (m) (and m (integerp (mv-adv-block m)) (> (mv-adv-block m) *gg-ender-adv*))))
            (let ((nq (kit-next kit (mv-name mv) :q)) (nf (kit-next kit (mv-name mv) :f)))
              (why b :pressure (cond ((and (ok nf) (< (sim-rnd01) *ai-block-k-p*)) :f) ((ok nq) :q))))))
        :pass)))

;;; ---------------------------------------------------------------- AI-REFLEX's free-state steps (batch 4, 2026-10-25): claiming steps
;;; (AI-STEP-CLAIM), each clause's test and body moved as written into DEF-REFLEX-STEP (the reflexes' locals bound alike)
(defmacro def-reflex-step (name doc test &body body)
  "A claiming AI-REFLEX step NAME (e b s d): BODY's value when TEST holds, else :PASS; AI-REFLEX's locals bound (F G KIT RED
HOHO-OK GUARD-K Q: pure reads of this step's state, as AI-REFLEX's own)."
  `(defun ,name (e b s d)
     ,doc
     (declare (ignorable s d))
     (let* ((f (fighter e)) (g (gauges e)) (kit (fighter-kit f)) (red (gauges-red-p g)) (hoho-ok (hoho-ready-p e))
            (guard-k (ai-guard-k e)) (q (kit-command-move kit :q)))
       (declare (ignorable f g kit red hoho-ok guard-k q))
       (if ,test (progn ,@body) :pass))))

(def-reflex-step ai-ward-reversal
  "Bankai West's reversal: the ward just blocked a hit up close (no blockstun): SHONETSU JIGOKU (L) now and then"
  (let ((p (ai-table e :ward-reversal)))
    (and p (passive-p e :ward) (<= (- *match-tick* (fighter-warded f)) 1) (< (fighter-dist f) 3.0)
         (kit-command-ok-p e :sig) (< (brain-react-roll b) p)))
  (why b :ward-reversal :sig))

(def-reflex-step ai-reset
  "the reset: our blocked string just ended (no safe hit left in it) and he still guards: Q1 again"
  (and (eq (brain-was b) :move) (eq (fighter-contact f) :block) (< d (+ (mv-reach q) 0.2)) (ai-pressure-p e))
  (why b :pressure :q))

(def-reflex-step ai-kikon-rush
  "a red opponent still reeling from our hits (or bound): rush him"
  (and (kikon-ready-p e) (member (snap-state s) '(:stun :air)) (< d (ai-table e :kikon-range 7.0))
       (kit-command-ok-p e :kikon) (not (ai-sb-finish-p e)))
  (why b :kikon :kikon))

(def-reflex-step ai-bankai
  "the Bankai (cup 3, red, free: the kit's :bankai), before the cash-out; free as for the first awakening (AWAKEN-STATE-P, the user 2026-10-09; it was idle / guard only)"
  (let ((bk (ai-table e :bankai)))
    (and bk (kit-bankai-form kit) (bankai-allowed-p (awaken-state-p e f) (gauges-konpaku g))
         (let ((ok (kit-bankai-ok kit))) (or (null ok) (funcall ok e)))   ; (the kit's own rule, if any: :bankai-ok)
         (not (bind-of e))                                                ; (never in a bind: BANKAI-OK-P refuses it)
         (ai-bankai-p e b bk)))
  (why b :bankai :awaken))

(def-reflex-step ai-cashout
  "NOMIHOSE's cash-out (the kit's :cashout): Shift+K only as a punish (he has >= :punish frames of recovery or stun left, in the 12 m lane) or within :near m while NOME is below :below (it would drain away anyway)"
  (let ((c (ai-table e :cashout)))
    (and c (kit-command-ok-p e :sp1) (< d 12.0)
         (setf (brain-why b)
               (cond ((and (member (snap-state s) '(:move :stun)) (< (snap-left s) 99)
                           (>= (snap-left-seen s b) (getf c :punish)))
                      :cashout-punish)
                     ((and (< d (getf c :near)) (< (gauges-meter g) (getf c :below))) :cashout-near)))))
  :sp1)

(def-reflex-step ai-anti-bind
  "South's tell under us: its grab comes 16 f after the stab (real move frame 36); from what we see (delayed), step sideways out of it (the anti-rush chance) or Hoho it (the Hoho roll; perfect late)"
  (and (member :bind (snap-flags s)) (eq (snap-phase s) :main)
       (<= (first (or (snap-tell s) '(21 30))) (+ (snap-sf s) (brain-delay b)) (second (or (snap-tell s) '(21 30)))))
  (cond ((and hoho-ok (< (brain-hoho-roll b) (ai-table e :hoho 0.2))) (why b :anti-bind :hoho))
        ((< (brain-react-roll b) (getf *ai-anti-breaker-p* (brain-difficulty b) 0.5)) (why b :anti-bind :side-step))))

(def-reflex-step ai-anti-parry
  "a parry up close: don't feed it; a Breaker breaks it (half the time), else wait"
  (and (member :parry (snap-flags s)) (eq (snap-phase s) :main) (< d 4.0))
  (and (< (brain-react-roll b) 0.5) (why b :anti-parry :breaker)))

(def-reflex-step ai-awaken
  "The awakening: EVOLUTION ready, our Reishi at or above the kit's :awaken-above and its rule says awaken (AI-AWAKEN-P)."
  (and (gauges-evolution g) (>= (reishi-frac g) (ai-table e :awaken-above 0.0))
       (ai-awaken-p e))
  :awaken)

(def-reflex-step ai-follow-up
  "a stunned opponent (Guard Break, broken stance, our knockback) still stunned when Q1 lands"
  (and (eq (snap-state s) :stun) (>= (snap-left-seen s b) (mv-s q)) (< d (+ (mv-reach q) 0.6)))
  (why b :follow-up :q))

(def-reflex-step ai-stun-follow
  "... farther, the kit's :stun-follow (cmd lo hi): its move if it lands before he is free (Rukia: Shirafune, SOSEN)"
  (let* ((sf (ai-table e :stun-follow)) (c (first sf)))
    (and sf (eq (snap-state s) :stun) (<= (second sf) d (third sf)) (kit-command-ok-p e c)
         (>= (snap-left-seen s b) (mv-s (kit-command-move kit c)))))
  (why b :stun-follow (first (ai-table e :stun-follow))))

(def-reflex-step ai-oki
  "the opponent is launched / down (untouchable for a while): the kit's :oki command (Yamamoto: a full-charge Shiranui, which also fills Inferno -> Hellfire, whose burn he only risks above :oki-above of his Reishi)"
  (and (member (snap-state s) '(:air :down)) (eq (ai-table e :oki) :sp1-full) (mv-hold (kit-command-move kit :sp1))
       (kit-command-ok-p e :sp1) (> d 3.0)
       (>= (reishi-frac g) (ai-table e :oki-above 0.0)))
  (why b :oki (ai-table e :oki)))

(def-reflex-step ai-react
  "the kit's reactions: stance vs a projectile / a Flash startup it can still beat (stance-in must end before the Flash hits, after our perception delay); a parry (West) vs a Flash startup whose hit falls in its window (the SP's super freeze holds him *SUPER-FREEZE* f more)"
  (let ((r (ai-table e :react)))
    (and r (< (brain-react-roll b) *ai-react-p*)
         (or (and (snap-projectile s) (getf r :projectile))
             (and (eq (snap-kind s) :flash) (< d 4.0) (getf r :flash-startup) (kit-command-ok-p e (getf r :flash-startup))
                  (let ((lead (snap-lead-seen s b))
                        (mv (kit-command-move kit (getf r :flash-startup))))
                    (if (member :parry (mv-flags mv))
                        (and (eq (snap-phase s) :main) (parry-frame-p (+ lead *super-freeze*)))
                        (>= lead (+ *stance-in* 2))))))))
  (let ((r (ai-table e :react)))
    (why b :react (if (snap-projectile s) (getf r :projectile) (getf r :flash-startup)))))

(def-reflex-step ai-guard-break
  "a long guard up close: Breaker it"
  (and (eq (snap-state s) :guard) (>= (snap-guard-t s) *ai-guard-break-hold*) (< d *ai-guard-break-range*)
       (/= (brain-break-key b) (snap-start s)))
  (setf (brain-break-key b) (snap-start s))
  (and (< (sim-rnd01) *ai-guard-break-p*) (why b :guard-break :breaker)))

(def-reflex-step ai-threat
  "a committed move coming: Hoho it (flash-step to spare) or guard it; a low guard gauge guards less and steps aside instead (AI-GUARD-MULT); a Kikon rush on us red: Hoho or Step"
  (and (eq (snap-state s) :move) (member (snap-kind s) '(:quick :flash :sig :sp :breaker :kikon))
       (snap-live-p s) (snap-near-p s e d *ai-threat-margin*))   ; (an :x-axis line: on it, in its real window)
  (let ((chance (+ (ai-table e :guard 0.3) (if (eq (brain-intent b) :defend) 0.25 0.0))))
    (cond ((and hoho-ok (ai-hoho-spare-p (gauges-fs g) (gauges-reishi g) (gauges-reishi-max g))
                (>= (- (snap-s s) (snap-sf s)) 6) (not (snap-reflect-p s))   ; (a reflect is :opp-reflect's)
                (< (brain-hoho-roll b) (if (and (eq (snap-kind s) :quick) (ai-mash-p b))   ; a masher's J: Hoho it more
                                           (max *ai-anti-mash-hoho* (* 2 (ai-table e :hoho 0.2)))
                                           (ai-table e :hoho 0.2))))
           (why b (if (ai-mash-p b) :anti-mash :hoho) :hoho))
          ((and red (eq (snap-kind s) :kikon)) (why b :anti-kikon :side-step))
          ((member :grab (snap-flags s)) (why b :anti-grab :side-step))   ; a grab: nothing guards it
          ((< (brain-guard-roll b) (* chance guard-k)) :guard)
          ((< (brain-guard-roll b) chance) (why b :low-guard :side-step)))))

(defun ai-reflex (e b s d)
  "The reflexes (checked before the intent): a command keyword or NIL. S = the perceived opponent,
D = the perceived distance."
  (let* ((f (fighter e)) (g (gauges e)) (kit (fighter-kit f)) (st (fighter-state f)) (mv (fighter-move f))
         (free (member st '(:idle :guard :run)))
         (red (gauges-red-p g))
         (hoho-ok (hoho-ready-p e))   ; flash-step for one
         (guard-k (ai-guard-k e))                                                      ; the guard gauge left
         (q (kit-command-move kit :q))
         (r nil))                                         ; (a claimed step's command)
    (funcall (ai-step e :event-rolls) b s)                ; one roll per opponent action (AI-EVENT-ROLLS)
    (cond
      ;; the in-move steps (*AI-STEPS*, AI-STEP-CLAIM: :PASS when it doesn't apply, else its command, NIL included, ends
      ;; the reflexes as its clause did): the O ender, Step -> J, a string off a landed Breaker, the guard cancel
      ((not (eq (setq r (ai-step-claim e :o-ender b s d)) :pass)) r)
      ((not (eq (setq r (ai-step-claim e :step-j b s d)) :pass)) r)
      ((not (eq (setq r (ai-step-claim e :breaker-string b s d)) :pass)) r)
      ((not (eq (setq r (ai-step-claim e :guard-cancel b s d)) :pass)) r)
      ;; the form's own in-move reflex, before the generic string reflex (the kit's :ai :move-reflex (e b f mv) -> a command
      ;; or NIL: Hisagi's ranged route picks, DUEL_HISAGI §22.6; no other kit has it)
      ((and (eq st :move) (let ((h (ai-table e :move-reflex))) (and h (funcall h e b f mv)))))
      ;; ... then the string (our own hit: finish it, else an SP / L cancel), ORANGE off a landed L / O, guard pressure
      ((not (eq (setq r (ai-step-claim e :string b s d)) :pass)) r)
      ((not (eq (setq r (ai-step-claim e :orange b s d)) :pass)) r)
      ((not (eq (setq r (ai-step-claim e :pressure b s d)) :pass)) r)
      ((eq st :move) nil)
      ;; a Kikon rush's strike hit us, O held, and it dashes in after us: not red, hold guard from inside the
      ;; stagger (*AI-FOLLOW-GUARD-P* by difficulty); red, nothing guards it
      ((ai-step-cmd e :anti-kikon b s d))                 ; (AI-ANTI-KIKON)
      ((not free) nil)
      ;; the learning CPU's neutral read (LEARN-NEUTRAL) on its own clock, before the kit's reflexes: several take the
      ;; neutral decision over (AI v2: Yamamoto's rush veto, Rukia's zone wave, Ichigo's conversion ... reset the decision
      ;; clock and pick themselves; Kenpachi's walk-in :WAITs, so AI-NEUTRAL's clock stops) and starved a read made inside
      ;; AI-DECIDE. A read pressed: the decision is made (:WAIT presses nothing more)
      ((and (brain-learn b) (learn-read-due e b s d))
       (setf (brain-decide-t b) (ai-decide-time e b))
       :wait)
      ;; the form's own reflexes (the kit's :ai :reflex, a character file's function: Ichigo's timed parry, Senjumaru's
      ;; weave), then the ones its opponent's kit asks of a CPU facing it (:opp-reflex)
      ((let ((h (ai-table e :reflex))) (and h (funcall h e b s d))))
      ((let ((h (getf (kit-ai (kit-of (opp-of e))) :opp-reflex))) (and h (funcall h e b s d))))
      ;; ... and the generic keys its kit sets for a CPU facing it: an :x-axis aim (:opp-aim), a :reflectable move
      ;; (:opp-reflect) (docs/duel/DUEL_LILLE.md §11.3; no other kit has them)
      ((ai-opp-aim e b s d))
      ((ai-opp-reflect e b s d))
      ;; Bankai West's reversal: the ward just blocked a hit up close (no blockstun): SHONETSU JIGOKU (L) now and then
      ((not (eq (setq r (ai-step-claim e :ward-reversal b s d)) :pass)) r)   ; (AI-WARD-REVERSAL)
      ;; the reset: our blocked string just ended (no safe hit left in it) and he still guards: Q1 again
      ((not (eq (setq r (ai-step-claim e :reset b s d)) :pass)) r)   ; (AI-RESET)
      ;; a red opponent still reeling from our hits (or bound): rush him
      ((not (eq (setq r (ai-step-claim e :kikon-rush b s d)) :pass)) r)   ; (AI-KIKON-RUSH)
      ;; the Bankai (cup 3, red, free: the kit's :bankai), before the cash-out; free as for the first awakening
      ;; (AWAKEN-STATE-P, the user 2026-10-09; it was idle / guard only)
      ((not (eq (setq r (ai-step-claim e :bankai b s d)) :pass)) r)   ; (AI-BANKAI)
      ;; NOMIHOSE's cash-out (the kit's :cashout): Shift+K only as a punish (he has >= :punish frames of recovery
      ;; or stun left, in the 12 m lane) or within :near m while NOME is below :below (it would drain away anyway)
      ((not (eq (setq r (ai-step-claim e :cashout b s d)) :pass)) r)   ; (AI-CASHOUT)
      ;; South's tell under us: its grab comes 16 f after the stab (real move frame 36); from what we see
      ;; (delayed), step sideways out of it (the anti-rush chance) or Hoho it (the Hoho roll; perfect late)
      ((not (eq (setq r (ai-step-claim e :anti-bind b s d)) :pass)) r)   ; (AI-ANTI-BIND)
      ;; a parry up close: don't feed it; a Breaker breaks it (half the time), else wait
      ((not (eq (setq r (ai-step-claim e :anti-parry b s d)) :pass)) r)   ; (AI-ANTI-PARRY)
      ((not (eq (setq r (ai-step-claim e :awaken b s d)) :pass)) r)   ; (AI-AWAKEN)
      ;; we just blocked an ender (-12 ...): it's our turn, felt at once (no perception delay); a K3 (-20) HARD
      ;; punishes with K1 when it reaches
      ((ai-step-cmd e :block-punish b s d))               ; (AI-BLOCK-PUNISH)
      ;; a stunned opponent (Guard Break, broken stance, our knockback) still stunned when Q1 lands
      ((not (eq (setq r (ai-step-claim e :follow-up b s d)) :pass)) r)   ; (AI-FOLLOW-UP)
      ;; ... farther, the kit's :stun-follow (cmd lo hi): its move if it lands before he is free (Rukia: Shirafune, SOSEN)
      ((not (eq (setq r (ai-step-claim e :stun-follow b s d)) :pass)) r)   ; (AI-STUN-FOLLOW)
      ;; the opponent is launched / down (untouchable for a while): the kit's :oki command
      ;; (Yamamoto: a full-charge Shiranui, which also fills Inferno -> Hellfire, whose burn he
      ;; only risks above :oki-above of his Reishi)
      ((not (eq (setq r (ai-step-claim e :oki b s d)) :pass)) r)   ; (AI-OKI)
      ;; a recovering opponent in reach: punish
      ((ai-step-cmd e :punish b s d))                     ; (AI-PUNISH)
      ;; an incoming Breaker, a Kikon rush, or a rush's follow-up strike coming (it hit us, not red): guard
      ;; a rush when not red (the chance by difficulty); else Hoho through its dash (flash-step); a Breaker: J1 as its dash
      ;; runs into J1's reach (J beats I, docs/duel/DUEL_STRINGS.md §14: waiting till then); a rush: Q1 it while it has the room,
      ;; else Step sideways (a Hoho in the aura only reappears in front of the dash)
      ((ai-step-cmd e :anti-rush b s d))                  ; (AI-ANTI-RUSH)
      ;; the kit's reactions: stance vs a projectile / a Flash startup it can still beat (stance-in
      ;; must end before the Flash hits, after our perception delay); a parry (West) vs a Flash startup
      ;; whose hit falls in its window (the SP's super freeze holds him *SUPER-FREEZE* f more)
      ((not (eq (setq r (ai-step-claim e :react b s d)) :pass)) r)   ; (AI-REACT)
      ;; a long guard up close: Breaker it
      ((not (eq (setq r (ai-step-claim e :guard-break b s d)) :pass)) r)   ; (AI-GUARD-BREAK)
      ;; a committed move coming: Hoho it (flash-step to spare) or guard it; a low guard gauge guards
      ;; less and steps aside instead (AI-GUARD-MULT); a Kikon rush on us red: Hoho or Step
      ((not (eq (setq r (ai-step-claim e :threat b s d)) :pass)) r))))   ; (AI-THREAT)

(defun j-beats-k-p (e b)
  "J beats K (docs/duel/DUEL_STRINGS.md §4): on the first free step after our blockstun, the string's next link is a K link
(no armour) still at least S(J1) + 2 frames from its hit, inside our J1's reach: J1 gets there first. Felt at once,
like the block punish (the gap of a blocked string, not a read through the perception delay: a K link's startup is
shorter than NORMAL's delay); one roll (*AI-J-BEATS-K-P* by difficulty), also out of a guard held through the string.
Also out of his blocked J while it still recovers (the user 2026-10-02: a blocked J leaves the defender *QUICK-BLOCK-ADV*
more; J strings alone shouldn't crush a guard, the CPU's included); against a J masher (AI-MASH-P) *AI-ANTI-MASH-J-P*."
  (and (j-beats-open-p e b)
       (< (sim-rnd01) (if (ai-mash-p b) *ai-anti-mash-j-p* (getf *ai-j-beats-k-p* (brain-difficulty b) 0.45)))))

(defun j-beats-open-p (e b)
  "J-BEATS-K-P's window without its roll (the assist's AUTO GUARD presses J in it: assist.lisp)."
  (let* ((f (fighter e)) (o (fighter-opp f)) (fo (fighter o)) (om (fighter-move fo)) (q (kit-command-move (fighter-kit f) :q)))
    (and (eq (brain-was b) :guard-hit) (member (fighter-state f) '(:idle :guard)) (zerop (fighter-lock f))
         (eq (fighter-state fo) :move) (eq (fighter-phase fo) :main)
         (or (and (eq (mv-kind om) :flash) (>= (- (mv-s om) (fighter-sf fo)) (+ (mv-s q) 2)))
             (and (eq (mv-kind om) :quick) (>= (fighter-sf fo) (+ (mv-s om) (mv-a om)))))   ; his blocked J still recovering
         (< (fighter-dist f) (+ (mv-reach q) 0.2)))))

(defun ai-pick-intent (e b heat)
  "The generic :intent step (AI-NEUTRAL, every *AI-REPICK* steps): the next intent, a weighted pick of the kit's :intents
(pressure + heat, + 3 on a guardless / low-gauge opponent; his kit's :opp-intent added), zone / defend on our low guard gauge."
  (declare (ignore b))
  (let ((w (ai-table e :intents)) (hot (min 3.0 (/ heat 4.0))) (r (sim-rnd01)))
    (cond ((ai-gg-low-p e) (weighted-pick r :zone 3 :defend 2))   ; low guard gauge: zone (the cone), no pressure
          (t (let ((oi (unless (and *run-boss* (eql (opp-of e) *run-boss*))   ; facing a form a CPU waits out (not a
                       (getf (kit-ai (kit-of (opp-of e))) :opp-intent))))         ;  DANGAI boss's: it never ends)
               (or (weighted-pick r :approach (getf w :approach 1)
                                  :pressure (+ (getf w :pressure 1) hot (if (or (opp-guardless-p e) (opp-gg-low-p e)) 3 0))
                                  :zone (rmod-plus e :zone-bias (+ (getf w :zone 1) (getf oi :zone 0)))   ; (DANGAI's FOE ZONES)
                                  :defend (+ (getf w :defend 1) (getf oi :defend 0)))
                   :approach))))))

(defun ai-strafe (e b)
  "The generic :strafe step (batch 8): the strafe's next side and how long it lasts (*AI-STRAFE-TIME*)."
  (declare (ignore e))
  (setf (brain-strafe-t b) (+ (first *ai-strafe-time*) (floor (* (second *ai-strafe-time*) (sim-rnd01))))
        (brain-strafe b) (if (< (sim-rnd01) 0.5) -1f0 1f0)))

(defun ai-walk (e b vp d lo hi)
  "The generic :walk step (batch 8): the stick toward the intent's range LO..HI (the heat's), strafing inside it."
  (declare (ignore e))
  (vpad-stick! vp (if (<= lo d hi) (brain-strafe b) (* 0.3 (brain-strafe b)))
               (cond ((> d hi) 1f0) ((< d lo) -1f0) (t 0f0))))

(defun ai-neutral (e b s d)
  "No reflex fired: walk to the intent's range, and now and then decide (AI-DECIDE)."
  (let* ((kit (kit-of e)) (vp (pilot-vpad (pilot e))) (heat (brain-heat b)))
    (when (<= (decf (brain-intent-t b)) 0)
      (setf (brain-intent-t b) *ai-repick*)
      (setf (brain-intent b) (funcall (ai-step e :intent) e b heat)))   ; (AI-PICK-INTENT)
    (when (<= (decf (brain-strafe-t b)) 0)
      (funcall (ai-step e :strafe) e b))                  ; (AI-STRAFE)
    (destructuring-bind (lo hi) (getf (ai-table e :ranges) (brain-intent b) '(2.0 4.0))
      (multiple-value-bind (lo hi) (heat-range lo hi heat)
        (funcall (ai-step e :walk) e b vp d lo hi)        ; (AI-WALK)
        (when (<= (decf (brain-decide-t b)) 0)
          (setf (brain-decide-t b) (ai-decide-time e b))
          (ai-decide e b kit s d lo hi heat))))))

(defun ai-decide-time (e b)
  "Frames to the next neutral decision: the kit's :decide-time step (batch 8, 2026-10-25; every caller, the kits' own
reflexes too), else AI-DECIDE-TIME-DEFAULT."
  (funcall (ai-step e :decide-time) e b))

(defun ai-decide-time-default (e b)
  "The generic :decide-time step: the difficulty's *AI-THINK* + up to 40, x the kit's :tempo."
  (let ((n (+ (getf *ai-think* (brain-difficulty b) 24) (floor (* 40 (sim-rnd01))))) (k (ai-table e :tempo)))
    (if k (max 1 (round (* k n))) n)))

(defun opp-guardless-p (e)
  "E's opponent can't guard (his guard gauge ran out): press him (AI-NEUTRAL, AI-DECIDE)."
  (gauges-guardless (gauges (opp-of e))))

(defun ai-pressure-p (e)
  "Keep a blocked string going (the kit's :block-string chance; always while hunting a low guard gauge,
OPP-GG-LOW-P)? Only while the opponent really holds guard (or a ward), never below :gg-low of our own gauge."
  (let ((p (ai-table e :block-string)))
    (and p (guarding-p (opp-of e)) (not (ai-gg-low-p e))
         (< (sim-rnd01) (if (opp-gg-low-p e) 1.0 p)))))

(defun opp-gg-low-p (e)
  "E's opponent's guard gauge (on the HUD) is under half: hunt the crush (press him; a blocked string goes on)."
  (< (gauges-gg (gauges (opp-of e))) (* 0.5 *gg-max*)))

;;; ---------------------------------------------------------------- AI-DECIDE's steps (batch 5, 2026-10-25): claiming steps (AI-DECIDE-CLAIM:
;;; :PASS when the clause's test fails; otherwise the decision is taken, whatever its body returns: AI-DECIDE's value is not used)
(defun ai-decide-claim (e name b kit s d lo hi heat)
  "AI-DECIDE's step NAME (e b kit s d lo hi heat): :PASS (not this one) or anything else (it decided)."
  (let ((h (ai-step e name))) (if h (funcall h e b kit s d lo hi heat) :pass)))

(defmacro def-decide-step (name doc test &body body)
  "A claiming AI-DECIDE step NAME: BODY when TEST holds (then T), else :PASS; AI-DECIDE's local Q (the kit's J1) bound."
  `(defun ,name (e b kit s d lo hi heat)
     ,doc
     (declare (ignorable s d lo hi heat))
     (let ((q (kit-command-move kit :q)))
       (declare (ignorable q))
       (if ,test (progn ,@body t) :pass))))

(def-decide-step ai-neutral-kikon
  "the Kikon rush on a red opponent within the kit's :kikon-range, one roll a decision (AI-KIKON-P)"
  (and (kikon-ready-p e) (< d (ai-table e :kikon-range 7.0)) (not (member (snap-state s) '(:down :wakeup :hoho)))
       (kit-command-ok-p e :kikon) (not (ai-sb-finish-p e)) (< (sim-rnd01) (ai-kikon-p e)))
  (ai-command b kit :kikon d e) (setf (brain-why b) :kikon))

(def-decide-step ai-white
  "WHITE (AI-WHITE-P)"
  (ai-white-p e b s d)
  (ai-command b kit :burst d e) (setf (brain-why b) :white))

(def-decide-step ai-pip-hurry
  "the arm's next crack is near: spend the pip now (AI-PIP-HURRY-P)"
  (ai-pip-hurry-p e)
  (ai-attack e b kit s d heat t))

(def-decide-step ai-cool
  "Rukia: hold U the frames the next colder band still needs (AI-COOL-P)"
  (ai-cool-p e s d)
  (ai-press b :guard (+ 2 (temp-cool-frames (gauges-meter (gauges e)))) :act :cool)
  (setf (brain-why b) :cool))

(def-decide-step ai-brace
  "Rukia at zero: brace a while, the warming stops (AI-BRACE-P)"
  (ai-brace-p e d)
  (ai-press b :guard 20 :act :brace)
  (setf (brain-why b) :brace))

(def-decide-step ai-step-in
  "Step -> J: a forward Step that lands within J1's reach (*AI-STEP-IN-P*)"
  (let ((r (and q (mv-reach q))))
    (and r (not (kit-rooted kit)) (> d (+ r *ai-step-j-margin*)) (< d (+ r *step-distance* -0.2))
         (not (and (eq (snap-state s) :move) (< (snap-sf s) (snap-active-end s)))) (not (eq (snap-state s) :hoho))
         (< (sim-rnd01) (getf *ai-step-in-p* (brain-difficulty b) 0.0))))
  (ai-dash b 1.0 (mv-reach q)) (setf (brain-why b) :step-in))

(def-decide-step ai-dash-in
  "beyond the range by the kit's :dash-gap: dash in to its middle, the kit's :dash chance"
  (and (> d (+ hi (ai-table e :dash-gap *ai-dash-gap*))) (< (sim-rnd01) (ai-table e :dash 0.0)))
  (ai-dash b 1.0 (* 0.5 (+ lo hi))) (setf (brain-why b) :dash))

(def-decide-step ai-dash-back
  "inside the range: dash back to its middle (the kit's :dash-back; 0.6 on a low guard gauge)"
  (and (< d (- lo *ai-dash-gap*))
       (< (sim-rnd01) (if (ai-gg-low-p e) 0.6 (ai-table e :dash-back 0.0))))
  (ai-dash b -1.0 (* 0.5 (+ lo hi))) (setf (brain-why b) :dash-back))

(def-decide-step ai-neutral-guard
  "within 3.4 m: guard a while (the kit's :neutral-guard, else :guard; +0.2 defending; x AI-GUARD-K)"
  (and (< d 3.4) (< (sim-rnd01) (* (min 0.9 (+ (ai-table e :neutral-guard (ai-table e :guard 0.3))
                                                (if (eq (brain-intent b) :defend) 0.2 0.0)))
                                    (ai-guard-k e))))
  (ai-press b :guard (+ (first *ai-guard-hold*) (floor (* (second *ai-guard-hold*) (sim-rnd01))))))

(def-decide-step ai-neutral-attack
  "attack (AI-ATTACK: the kit's band for D) with the intent's *AI-AGGRESSION* + heat + the kit's :attack + KOSEI + his guard"
  (< (sim-rnd01) (min 0.9 (+ (getf *ai-aggression* (brain-intent b) 0.3) (* 0.04 heat) (ai-table e :attack 0.0)
                              (* *ai-kosei-aggression* (- 1.0 (ai-gg e)))   ; KOSEI: a low gauge pays to attack
                              (cond ((opp-guardless-p e) 0.3) ((opp-gg-low-p e) 0.2) (t 0.0)))))
  (ai-attack e b kit s d heat nil))

(defun ai-decide (e b kit s d lo hi heat)
  "A neutral decision, at distance D with the preferred range LO..HI (S: the perceived opponent):
the Kikon rush on a red opponent within its range (*AI-KIKON-P*), dash to / from that range (until
its middle), guard, attack (a weighted pick from the kit's band for D), or wait: its steps in order (batch 5, *AI-STEPS*)."
  (cond ((not (eq (ai-decide-claim e :neutral-kikon b kit s d lo hi heat) :pass)))
        ((not (eq (ai-decide-claim e :white b kit s d lo hi heat) :pass)))
        ((not (eq (ai-decide-claim e :pip-hurry b kit s d lo hi heat) :pass)))
        ((and (brain-habit b) (habit-neutral e b kit d)))  ; debug: a scripted player's habit
        ((not (eq (ai-decide-claim e :cool b kit s d lo hi heat) :pass)))
        ((not (eq (ai-decide-claim e :brace b kit s d lo hi heat) :pass)))
        ((not (eq (ai-decide-claim e :step-in b kit s d lo hi heat) :pass)))
        ((not (eq (ai-decide-claim e :dash-in b kit s d lo hi heat) :pass)))
        ((not (eq (ai-decide-claim e :dash-back b kit s d lo hi heat) :pass)))
        ((not (eq (ai-decide-claim e :neutral-guard b kit s d lo hi heat) :pass)))
        ((not (eq (ai-decide-claim e :neutral-attack b kit s d lo hi heat) :pass)))))

(defun ai-pip-hurry-p (e)
  "The kit's :pip-hurry: a pip of the arm is left and its crack is at most that many frames away."
  (let ((h (ai-table e :pip-hurry)) (g (gauges e)))
    (and h (kit-pips (kit-of e)) (>= (gauges-meter g) 1f0) (null (gauges-arm-pending g))
         (>= (gauges-meter-idle g) (- *arm-crack* h)))))

(defun ai-attack-weights (e b kit s d heat hurry weights)
  "The generic :attack-weights step (batch 6, 2026-10-25): AI-ATTACK's band WEIGHTS for D (a fresh plist, changed in place) ->
the weights it picks from: the Breaker by heat (none on a guardless opponent), the stance's (AI-STANCE-WEIGHTS), HURRY's pip
commands only, the learning CPU's bandit."
  (when (getf weights :breaker)                  ; (a guardless opponent has no guard to break)
    (setf (getf weights :breaker) (if (opp-guardless-p e) 0 (* (getf weights :breaker) (heat-breaker-mult heat)))))
  (ai-stance-weights e s d weights)
  (when hurry
    (loop for (cmd nil) on weights by #'cddr unless (and cmd (kit-pip-cmd-p kit cmd)) do (setf (getf weights cmd) 0)))
  (when (brain-learn b) (setf weights (funcall (ai-step e :learn-weights) e (brain-learn b) d weights)))   ; the bandit (LEARN-WEIGHTS)
  weights)

(defun ai-attack (e b kit s d heat hurry)
  "A weighted pick from the kit's band for D, pressed when it may start (not a J / K out of its reach). HURRY: only the
pip commands of the band (the arm's crack is near: AI-PIP-HURRY-P). T when something was pressed."
  (let* ((weights (funcall (ai-step e :attack-weights) e b kit s d heat hurry
                           (copy-list (band-weights (ai-table e :moves) d)))))   ; (AI-ATTACK-WEIGHTS)
    (let ((cmd (apply #'weighted-pick (sim-rnd01) weights)))
      (cond ((and cmd (or (not (member cmd *kit-commands*)) (and (kit-command-move kit cmd) (kit-command-ok-p e cmd)))
                  (or (not (member cmd '(:q :f)))                  ; don't whiff a string at range
                      (<= d (+ 0.2 (mv-reach (kit-command-move kit cmd))))))
             (ai-command b kit cmd d e) (setf (brain-why b) (if hurry :pip-hurry :neutral))
             (when (brain-learn b) (learn-window e (brain-learn b) d weights cmd))
             t)
            ((and (null cmd) (brain-learn b)) (learn-window e (brain-learn b) d weights nil) nil)))))

(defun ai-kikon-p (e)
  "The chance a neutral decision rushes a red opponent: the kit's :kikon-p (Nozarashi's cups 0.25 / 0.5 / 0.9:
a later Kikon is worth more), at least *AI-KIKON-P* once the match has under a minute left; else *AI-KIKON-P*."
  (let ((k (ai-table e :kikon-p)))
    (cond ((null k) *ai-kikon-p*)
          ((< (match-frames-left) 3600) (max k *ai-kikon-p*))
          (t k))))

(defun ai-stance-weights (e s d weights)
  "The stance keys on a neutral pick's WEIGHTS (a fresh plist, edited in place): no Q / F into a guard within 3 m
below :gg-low; none into a parry; L x the kit's :low factor below its Reishi fraction, halved below its :sig-gg
fraction of the guard gauge."
  (loop for (cmd w) on weights by #'cddr
        when (and (member cmd '(:q :f))
                  (or (and (ai-gg-low-p e) (< d 3.0) (member (snap-state s) '(:guard :guard-hit)))
                      (member :parry (snap-flags s))))
          do (setf (getf weights cmd) 0))
  (let ((low (ai-table e :low)) (sg (ai-table e :sig-gg)) (g (gauges e)))
    (when (and low (getf weights :sig) (< (reishi-frac g) (first low)))
      (setf (getf weights :sig) (* (getf weights :sig) (getf (rest low) :sig 1))))
    (when (and sg (getf weights :sig) (< (ai-gg e) sg))
      (setf (getf weights :sig) (* 0.5 (getf weights :sig)))))
  weights)

(defun brain-perceive (e b o)
  "Brain B of E sees opponent O this step: his SNAP goes into the ring; values the SNAP of BRAIN-DELAY steps ago and the
distance to it (the assist's learner perceives the same way: assist.lisp)."
  (let* ((ring (brain-ring b)) (n (length ring))
         (cur (or (svref ring (brain-head b)) (setf (svref ring (brain-head b)) (make-snap)))))
    (snap-take! cur o)
    (let* ((s (or (svref ring (mod (- (brain-head b) (brain-delay b)) n)) cur))
           (p (pos-of e)) (d (sqrt (+ (expt (- (snap-x s) (aref p 0)) 2) (expt (- (snap-z s) (aref p 2)) 2)))))
      (setf (brain-head b) (mod (1+ (brain-head b)) n))
      (when (and (eq (snap-state s) :move) (eq (snap-kind s) :quick) (/= (snap-start s) (brain-jkey b)))   ; a J of his begins
        (setf (brain-jkey b) (snap-start s))
        (push *match-tick* (brain-jstarts b)))
      (when (brain-jstarts b)                               ; only the window's
        (setf (brain-jstarts b) (delete-if (lambda (t0) (> (- *match-tick* t0) *ai-mash-window*)) (brain-jstarts b))))
      (values s d))))

(defun ai-mash-p (b)
  "Is he mashing J, as brain B saw him: *AI-MASH-STARTS* J starts within *AI-MASH-WINDOW* frames (the user 2026-10-02:
both AIs answer J mashing: J out of his recovering blocked J (J-BEATS-K-P, *AI-ANTI-MASH-J-P*), Hoho his coming J
(*AI-ANTI-MASH-HOHO*)? Not safer string enders: no L / O ender against him cost more damage than it saved (the masher's
wins vs HARD 69 -> 74 %, 2026-10-02)."
  (>= (length (brain-jstarts b)) *ai-mash-starts*))

(defun ai-wake-step (e b d)
  "The CPU's first free step out of a hit or a wake-up with him close (BRAIN-STEP): hold Guard *AI-WAKE-GUARD-FRAMES*
(*AI-WAKE-GUARD-P* by difficulty x AI-GUARD-K: a low gauge guards less), else half the time a Hoho (flash-step to spare)
or a back Step out of his reach (the user 2026-10-02); else nothing (a reflex may still act)."
  (let* ((g (gauges e)) (r (sim-rnd01)) (p (* (getf *ai-wake-guard-p* (brain-difficulty b) 0.6) (ai-guard-k e))))
    (cond ((< r p) (ai-press b :guard *ai-wake-guard-frames* :act :hold) (setf (brain-why b) :wake-guard))
          ((< r (+ p (* 0.5 (- 1.0 p))))
           (ai-command b (kit-of e)
                       (if (and (hoho-open-p e)
                                (ai-hoho-spare-p (gauges-fs g) (gauges-reishi g) (gauges-reishi-max g)))
                           :hoho :step)                       ; (a Step with the stick at rest: the back hop)
                       d e)
           (setf (brain-why b) :wake-out)))))

(defun ai-gap-step-p (e b)
  "The gap after his blocked J string (the user 2026-10-02): our first free step out of blocking his J that still
recovers, too far for our J1 (J-BEATS-OPEN-P's window but its reach), against a J masher: back-Step out of his restart
(*AI-GAP-STEP-P* by difficulty), so his J whiffs."
  (let* ((f (fighter e)) (o (fighter-opp f)) (fo (fighter o)) (om (fighter-move fo)) (q (kit-command-move (fighter-kit f) :q)))
    (and (eq (brain-was b) :guard-hit) (member (fighter-state f) '(:idle :guard)) (zerop (fighter-lock f))
         (not (kit-rooted (fighter-kit f))) (ai-mash-p b)
         (eq (fighter-state fo) :move) (eq (fighter-phase fo) :main) (eq (mv-kind om) :quick)
         (>= (fighter-sf fo) (+ (mv-s om) (mv-a om))) (>= (fighter-dist f) (+ (mv-reach q) 0.2))
         (< (sim-rnd01) (getf *ai-gap-step-p* (brain-difficulty b) 0.5)))))

;;; ---------------------------------------------------------------- BRAIN-STEP's frame steps (batch 8, 2026-10-25), moved as written
(defun ai-respect (e b)
  "The generic :respect step: we just took a hit or a block: defend for the kit's :respect frames (*AI-RESPECT*)."
  (setf (brain-intent b) :defend (brain-intent-t b) (ai-table e :respect *ai-respect*)))

(defun ai-wake (e b d)
  "The generic :wake step: our first free step out of a hit or a wake-up, him close, against a J masher (the CPU's pacing
stays otherwise): the :wake-guard step (AI-WAKE-STEP)."
  (let ((f (fighter e)))
    (when (and (member (brain-was b) '(:stun :air :down :wakeup)) (member (fighter-state f) '(:idle :guard :run))
               (zerop (fighter-lock f)) (< d *ai-wake-guard-range*) (not (brain-off b)) (not (brain-habit b))
               (ai-mash-p b))
      (funcall (ai-step e :wake-guard) e b d))))

;;; ---------------------------------------------------------------- BRAIN-STEP's press-first steps (batch 7, 2026-10-25): claiming
;;; steps (AI-BRAIN-CLAIM, :PASS when not this one; else they pressed and the step is spent), moved as written
(defun ai-brain-claim (e name b s d)
  "BRAIN-STEP's step NAME (e b s d): :PASS (not this one) or anything else (it pressed)."
  (let ((h (ai-step e name))) (if h (funcall h e b s d) :pass)))

(defun ai-chain-follow (e b s d)
  "ORANGE's restart: J now (AI-CHAIN-FOLLOW-P)."
  (declare (ignore s d))
  (if (ai-chain-follow-p e) (progn (ai-press b :quick 1) (setf (brain-why b) :chain) t) :pass))

(defun ai-j-beats-k (e b s d)
  "J out of his recovering blocked J / K link (J-BEATS-K-P)."
  (declare (ignore s d))
  (if (j-beats-k-p e b) (progn (ai-press b :quick 1) (setf (brain-why b) :j-beats-k) t) :pass))

(defun ai-gap-step (e b s d)
  "Step out of his restart (AI-GAP-STEP-P)."
  (declare (ignore s d))
  (if (ai-gap-step-p e b) (progn (ai-press b :step 1 :act :step) (setf (brain-why b) :gap-step) t) :pass))

(defun brain-step (e b)
  "One step of the CPU: perceive, then hold / reflex / neutral, written to the vpad."
  (let* ((f (fighter e)) (vp (pilot-vpad (pilot e))) (o (fighter-opp f)))
    (vpad-begin-step! vp)
    (multiple-value-bind (s d) (brain-perceive e b o)
      (setf (brain-heat b) (f32 (heat-after (brain-heat b) (> d *ai-heat-far*))))
      (when (and (brain-learn b) (not (brain-off b))) (learn-step e b s d))   ; the learning CPU watches (perceived)
      (vpad-stick! vp 0f0 0f0)
      (unless (kit-bankai-form (fighter-kit f)) (setf (brain-bankai-rolled b) nil))   ; a new cup-3 stay rolls again
      (when (member (fighter-state f) '(:stun :air :down :wakeup :guard-hit))   ; just took it: respect (AI-RESPECT)
        (funcall (ai-step e :respect) e b))
      (when (and (eq (fighter-state f) :guard-hit) (zerop (fighter-sf f)) (not (brain-off b)))   ; blocked: hold on through the string?
        (funcall (ai-step e :block-hold) e b f))
      (funcall (ai-step e :wake) e b d)                                         ; out of a hit: guard first? (AI-WAKE)
      (if (or (and (member (fighter-state f) '(:stun :air)) (>= (fighter-combo-hits f) *burst-min-hits*))
              (and (eq (fighter-state f) :guard-hit) (fighter-glock f) (ai-gg-low-p e)))   ; a locked string on a low guard
          (incf (brain-burst-t b))                                                ; the Burst clock
          (setf (brain-burst-t b) 0 (brain-burst-rolled b) nil))
      (when (and (eq (brain-act b) :dash) (> (brain-press-left b) 0)              ; a dash reached its range:
                 (if (> (brain-dash b) 0) (<= d (brain-dash-to b)) (>= d (brain-dash-to b))))
        (setf (brain-press-left b) 0 (brain-decide-t b) 1))                      ; decide now (out of the run)
      (unless (or (brain-off b) (> (fighter-lock f) 0) (eq (fighter-state f) :cine))
        (cond ((eq (brain-habit b) :dumb) (dumb-step e b s d))                  ; debug: the button-masher (ASSIST's gate)
              ((eq (brain-habit b) :trial) (trial-step e b))                     ; debug: the trial player (combo-trial.py)
              ((let ((h (ai-step e :held))) (and h (funcall h e b f))))           ; the kit's own held press (AI-STEPS)
              ((funcall (ai-step e :burst) e b)                                   ; a Burst, else the awakening (AI-BURST-ROLL)
               (if (burst-ok-p e) (ai-press b :quick 1 :modded t :act :burst) (ai-press b :awaken 1))
               (setf (brain-why b) :burst))
              ((not (eq (ai-brain-claim e :chain-follow b s d) :pass)))         ; ORANGE's restart (AI-CHAIN-FOLLOW)
              ((not (eq (ai-brain-claim e :j-beats-k b s d) :pass)))            ; (AI-J-BEATS-K)
              ((not (eq (ai-brain-claim e :gap-step b s d) :pass)))             ; out of his restart (AI-GAP-STEP)
              ((and (brain-habit b) (habit-fire e b s d)))                     ; debug: a scripted player's habit
              ((and (brain-learn b) (funcall (ai-step e :learn-fire) e b s d)))   ; the learning CPU's planned counter (LEARN-FIRE)
              ((and (> (brain-press-left b) 0)                                    ; a reflex may drop a guard / a dash,
                    (not (and (eq (fighter-state f) :move) (eq (mv-kind (fighter-move f)) :breaker)   ; or a Breaker's
                              (eq (fighter-contact f) :hit)))                                          ; hold once it landed
                    (or (member (brain-act b) '(:hold :block-hold))                ; not a guard held through a string
                        (not (or (eq (brain-press b) :guard) (eq (brain-act b) :dash)))))
               (decf (brain-press-left b)))
              (t (let ((cmd (ai-reflex e b s d)))
                   (cond ((and cmd (not (and (eq cmd :guard) (eq (brain-press b) :guard) (> (brain-press-left b) 0))))
                          (ai-command b (kit-of e) cmd d e))
                         ((> (brain-press-left b) 0) (decf (brain-press-left b)))
                         ((member (fighter-state f) '(:idle :run)) (ai-neutral e b s d)))))))
      (setf (brain-was b) (fighter-state f))
      ;; the buttons of this step
      (loop for a across *vpad-actions*
            do (vpad-set! vp a (or (and (> (brain-press-left b) 0) (eq a (brain-press b)))
                                   (and (eq a :mod) (> (brain-press-left b) 0) (brain-press-mod b)))))
      (when (> (brain-press-left b) 0)
        (case (brain-act b)
          (:guard (vpad-stick! vp 0f0 0f0))
          (:side-step (vpad-stick! vp (brain-strafe b) 0f0))
          (:dash (vpad-stick! vp 0f0 (brain-dash b))))))))

(defun brain-system ()
  "Every CPU fighter decides this step (before FIGHTER-SYSTEM reads the vpads)."
  (do-entities (e (b brain) (f fighter)) (brain-step e b)))

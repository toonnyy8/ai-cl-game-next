;;;; kit.lisp — characters as data (design-v1 §5, §12): DEFMOVE (one plist per move) and DEFKIT
;;;; (one plist per character form), parsed at load into MOVE / HITWIN / KIT structs. The generic
;;;; fighter code reads only these structs; what a character does beyond the data is a hook: a
;;;; SYMBOL in the data (:on-frame ((40 yama-fire-wave)), :tick, :release, :on-land, :cine,
;;;; :enter-hook, :exit-hook), called with FUNCALL. Kits load before the hook DEFUNs (one
;;;; compilation unit), so #' would fail at load time: hooks stay symbols.
;;;; Numbers in the data may name a tuning knob: *EARMUFFED* symbols are replaced by their value
;;;; at load (RESOLVE-TUNING), so tuning.lisp stays the one place for shared numbers.
;;;; Frames: a move's frame SF counts from 0 (its first frame); startup S, active A, recovery R;
;;;; hit windows [from, to) in move frames. Plain CL: loaded on the host by the rules test.
(in-package :duel)

(defun tuning-ref-p (x)
  (and (symbolp x) x (not (keywordp x)) (not (eq x t))
       (let ((n (symbol-name x)))
         (and (> (length n) 2) (char= (char n 0) #\*) (char= (char n (1- (length n))) #\*)))))

(defun resolve-tuning (tree)
  "TREE with every *EARMUFFED* symbol replaced by its value."
  (cond ((tuning-ref-p tree) (symbol-value tree))
        ((consp tree) (cons (resolve-tuning (car tree)) (resolve-tuning (cdr tree))))
        (t tree)))

;;; ================================================================ moves
(defstruct (hitwin (:conc-name hw-))
  "One active window of a move: [FROM, TO) in move frames, its damage and effect on hit."
  (from 0 :type fixnum) (to 0 :type fixnum)
  (dmg 0 :type fixnum)
  (vols nil)                    ; list of volumes (MAKE-VOL, rules.lisp) in the attacker's frame
  (react :flinch)               ; :flinch :stagger :knockback :launch :knockdown
  (kb 0.0)                      ; knockback slide, metres
  (hs 0 :type fixnum)           ; global hitstop frames
  (chip nil)                    ; chip fraction on block, NIL = none
  (stun nil)                    ; hitstun override in frames (NIL = the reaction's, *REACTION-FRAMES*)
  (guard nil)                   ; guard gauge a block drains (GUARD-VALUE; NIL = a hazard's *GG-HAZARD*)
  (seg nil)                     ; :seg-fn: a kit function (e) -> the world capsule this frame, in place of VOLS (WINDOW-TOUCHES-P)
  (min nil)                     ; :min-reach: no hit on a victim nearer than this (m, centre to centre; NIL = none: COLLECT-MELEE)
  (steal nil)                   ; :steal-fs: flash-step this window's hit takes (NIL = the move's :params :steal-fs: CORE-ON-HIT!)
  (flags nil))
(inline-readers hitwin)                  ; :breaker :guard-crush :unguardable :ranged

(defstruct (move (:conc-name mv-))
  "A move: frame data, hit windows and hooks. See DEFMOVE for the fields."
  (name nil) (kind nil) (clip nil) (clip-2 nil) (callout nil)
  (s 0 :type fixnum) (a 0 :type fixnum) (r 0 :type fixnum) (whiff 0 :type fixnum)
  (dmg 0 :type fixnum) (adv-block nil) (track 0.0) (reach 0.0)
  (hits #() :type simple-vector)
  (hold nil) (slide 0.0) (flags nil)
  (armor-hits 0 :type fixnum) (cooldown 0 :type fixnum)
  (on-frame nil) (tick nil) (release nil) (on-land nil) (cine nil) (params nil)
  (enter 0 :type fixnum)        ; the move starts at this frame (its clip too): a faster string branch
  (clip-speed 1.0)              ; clip playback speed: the clip's startup (:clip-s, else the base
                                ; startup of a derived form) / this startup, so it hits on frame S
  (blend 0.0)                   ; crossfade frames into the clip (0 = snap, attacks)
  (planted nil)                 ; the weapon is planted in the ground during the strike (Ikkotsu)
  (spec nil))
(inline-readers move)                   ; the DEFMOVE plist (resolved), re-parsed for derived forms

(defun mv-total (mv) "S + A + R." (+ (mv-s mv) (mv-a mv) (mv-r mv)))
(defun mv-first-hit (mv) "Frame of the first hit window (or S)."
  (if (plusp (length (mv-hits mv))) (hw-from (svref (mv-hits mv) 0)) (mv-s mv)))

;;; ---------------------------------------------------------------- a move's real active window (the CPU's light model)
(defun move-active-end (mv)
  "The end of MV's real active window: its last hit window's TO (several lines in a row: all of them), else S + A."
  (let ((hits (mv-hits mv)))
    (if (plusp (length hits)) (loop for w across hits maximize (hw-to w)) (+ (mv-s mv) (mv-a mv)))))

;;; ---------------------------------------------------------------- :seg-fn windows (docs/duel/DUEL_HISAGI.md §12.4, hook 2)
;;; A hit window with :seg-fn names a kit function of the attacker entity giving this frame's world capsule: its two ends
;;; and its radius, (values ax ay az bx by bz r) (a chain from a fixed anchor to his hand). The hit collector tests it in
;;; place of the window's volumes (WINDOW-TOUCHES-P), so a hit through it is the attacker's own move contact (strings, the O
;;; ender, SP cancels, on-land hooks, the ender push); the CPU's line readers measure from it (SEG-GAP, ai.lisp SNAP-NEAR-P).
;;; Every window without it: its volumes, as before.
(defun window-touches-p (w att ax ay az fx fz tx ty tz tr th)
  "Does hit window W of ATT (at AX AY AZ facing FX 0 FZ) touch the hurt cylinder at (TX TY TZ), radius TR, height TH? Its
:seg-fn's capsule this frame, else any of its volumes (VOL-HIT-P)."
  (if (hw-seg w)
      (multiple-value-bind (sx sy sz bx by bz r) (funcall (hw-seg w) att)
        (capsule-cyl-hit-p sx sy sz bx by bz r tx ty tz tr th))
      (loop for v in (hw-vols w) thereis (vol-hit-p v ax ay az fx fz tx ty tz tr th 0f0))))

(defun seg-gap (mv att tx tz)
  "How far (TX TZ) is from move MV's :seg-fn capsules (ATT's, this frame) on the ground, their radius taken off; NIL when
no window of MV has a :seg-fn."
  (let ((best nil))
    (loop for w across (mv-hits mv)
          when (hw-seg w)
            do (multiple-value-bind (ax ay az bx by bz r) (funcall (hw-seg w) att)
                 (declare (ignore ay by))
                 (let* ((dx (- bx ax)) (dz (- bz az))
                        (u (max 0.0 (min 1.0 (/ (+ (* (- tx ax) dx) (* (- tz az) dz)) (max 1e-8 (+ (* dx dx) (* dz dz)))))))
                        (g (- (hypot (- tx (+ ax (* u dx))) (- tz (+ az (* u dz)))) r)))
                   (when (or (null best) (< g best)) (setf best g)))))
    best))

(defun ranged-window-lead (mv sf)
  "Frames from move frame SF until move MV's next :ranged hit window opens (0: one is open now), or NIL: none still to come.
The CPU's ranged-threat reader (ai.lisp RANGED-THREAT-IN)."
  (loop for w across (mv-hits mv)
        when (and (member :ranged (hw-flags w)) (< sf (hw-to w)))
          minimize (max 0 (- (hw-from w) sf)) into lead and count t into n
        finally (return (and (plusp n) lead))))

(defun next-window-lead (mv sf used)
  "Frames from move frame SF until move MV's next hit window not yet USED (the fighter's FIGHTER-HITS bits) is open on a step to come
(1: the next step), or NIL: none left. PRACTICE's GUARD ALL dummy (flow.lisp DUMMY-CANCEL-INPUT)."
  (loop for w across (mv-hits mv) for i from 0
        when (and (< (1+ sf) (hw-to w)) (not (logbitp i used)))
          minimize (max 1 (- (hw-from w) sf)) into lead and count t into n
        finally (return (and (plusp n) lead))))

(defvar *moves* (make-hash-table :test 'eq) "Move name -> MOVE, as written in the kit files.")
(defun find-move (name) (or (gethash name *moves*) (error "unknown move ~s" name)))

(defun scale-vol-spec (spec m)
  "Volume spec (kind . args) with its lengths x M (reach)."
  (destructuring-bind (kind &rest a) spec
    (ecase kind
      (:arc (list* :arc (* m (first a)) (rest a)))
      (:cap (list* :cap (* m (first a)) (* m (second a)) (cddr a)))
      (:sph (list :sph (* m (first a)) (second a) (* m (third a))))
      (:tsph spec))))

(defun vol-spec-reach (spec)
  (destructuring-bind (kind &rest a) spec
    (ecase kind (:arc (first a)) (:cap (second a)) (:sph (+ (first a) (third a))) (:tsph 0.0))))

(defun parse-move (name spec &key (startup-add 0) (reach-mult 1.0))
  "SPEC (a resolved DEFMOVE plist) -> MOVE. STARTUP-ADD / REACH-MULT derive a form's version
(Nozarashi): every frame from the startup on shifts, every reach scales."
  (destructuring-bind (&key kind clip clip-2 callout startup active recovery whiff (dmg 0) adv-block
                         track reach (arc 90) (height '(0.2 2.0)) vol vols on-hit (kb 0.0) hs chip
                         hold (slide 0.0) flags hits on-frame tick release on-land cine params
                         (enter 0) (blend 0.0) planted clip-s guard (armor-hits 0) (cooldown 0) min-reach)
      spec
    (let* ((breaker (eq kind :breaker))
           (s (+ startup-add (or startup (if breaker *breaker-startup* 0))))
           (a (or active (if breaker *breaker-active* 0)))
           (r (or recovery (if breaker *breaker-recovery* 0)))
           (dmg (if (and breaker (zerop dmg)) *breaker-damage* dmg))
           (reach (let ((rr (or reach (and vol (vol-spec-reach vol)) (and vols (vol-spec-reach (first vols)))
                                (and breaker *breaker-reach*))))
                    (and rr (cond ((eq kind :quick) (max (* reach-mult rr) *j-reach-min*))   ; (a J: at least this)
                                  (breaker rr)                          ; (a Breaker: unscaled, under every J)
                                  (t (* reach-mult rr))))))
           (vol (cond (vol (scale-vol-spec vol reach-mult))
                      (reach (list* :arc reach arc height))))
           (react (or on-hit (if breaker :stagger :flinch)))   ; (a Breaker: :knockback until 2026-10-02)
           (kb (if (and breaker (zerop kb)) *breaker-knockback* kb))
           (hs (or hs (case kind (:quick *hitstop-light*) (:breaker *hitstop-breaker*) (t *hitstop-heavy*))))
           (flags (if breaker (adjoin :breaker flags) flags))
           (guard (guard-value kind adv-block guard)))
      (flet ((window (from to &key (dmg dmg) (on-hit react) (kb kb) ((:vol hit-vol)) ((:reach hit-reach)) ((:vols hit-vols) vols)
                                   (chip chip) (flags flags) (hs hs) stun (guard guard) ((:seg-fn seg))
                                   ((:min-reach wmin) min-reach) steal-fs)
               ;; a window's own :reach / :vol (scaled like the move's), else the move's volume; :vols (a window's, else
               ;; the move's): several volumes in one window, which still hits once (a fan of lines)
               (let ((v (cond (hit-reach (list* :arc (* reach-mult hit-reach) arc height))
                              (hit-vol (scale-vol-spec hit-vol reach-mult))
                              (hit-vols nil)
                              (t vol))))
                 (make-hitwin :from (+ from startup-add) :to (+ to startup-add) :dmg dmg :react on-hit
                              :kb kb :hs hs :chip chip :flags flags :stun stun :guard guard :seg seg :min wmin :steal steal-fs
                              :vols (cond (seg nil)   ; (a :seg-fn window: its capsule is the kit function's, no fixed volume)
                                          (v (list (make-vol (first v) (rest v))))
                                          (t (loop for spec in hit-vols
                                                   collect (let ((sv (scale-vol-spec spec reach-mult))) (make-vol (first sv) (rest sv))))))))))
        (make-move
         :name name :kind kind :clip clip :clip-2 clip-2 :callout callout
         :s s :a a :r r :whiff (or whiff (if breaker *breaker-whiff* (+ r (case kind (:quick *whiff-extra-j*) (:flash *whiff-extra-k*) (t *whiff-extra*)))))
         :dmg dmg :adv-block (if breaker (or adv-block :guard-break) adv-block)
         :track (or track (case kind (:quick *track-quick*) (:breaker *track-breaker*) (:kikon *kikon-track*) (t *track-heavy*)))
         :reach (or reach 0.0)
         :hits (coerce (cond (hits (loop for h in hits collect (apply #'window h)))
                             ((and (plusp dmg) (or vol vols)) (list (window (- s startup-add) (+ (- s startup-add) a)))))
                       'simple-vector)
         :hold hold :slide slide :flags flags :armor-hits armor-hits :cooldown cooldown
         :on-frame (loop for (f hook) in on-frame collect (list (+ f startup-add) hook))
         :tick tick :release release :on-land on-land :cine cine :params params :spec spec
         :enter (if (plusp enter) (+ enter startup-add) 0) :blend blend :planted planted
         :clip-speed (if (and startup (or clip-s (/= 0 startup-add))) (/ (or clip-s startup) (float s)) 1.0))))))

(defun register-move (name spec)
  (let ((spec (resolve-tuning spec)))
    (setf (gethash name *moves*) (parse-move name spec))))

(defmacro defmove-copy (name of &rest overrides)
  "Move NAME: a copy of move OF (its plist, :enter and all) under another name: a switched string link (J2s, K2s),
whose kit string allows only the new button (docs/duel/DUEL_STRINGS.md §2.1; no new clip). OVERRIDES: keys that replace
OF's (they go first in the plist, so DEFMOVE's &key takes them: the Bankai's MAPPUTATSU is LEAP CLEAVE with its own
callout and cinematic)."
  `(register-move ,name (append ',overrides (mv-spec (find-move ,of)))))

(defun string-grid (grid)
  "A kit's :grid (J1 J2 J3 K1 K2 K3 J2s K2s) as its :strings: up to three links, each J (:q) or K (:f), switching
at most once (JJJ JJK JKK KKK KKJ KJJ). After a switch the alias (J2s after K1, K2s after J1) goes on only with the
new button."
  (destructuring-bind (j1 j2 j3 k1 k2 k3 j2s k2s) grid
    `((,j1 :q ,j2) (,j1 :f ,k2s) (,k1 :f ,k2) (,k1 :q ,j2s) (,j2 :q ,j3) (,j2 :f ,k3) (,k2 :f ,k3) (,k2 :q ,j3)
      (,j2s :q ,j3) (,k2s :f ,k3))))

(defmacro defmove (name &rest spec)
  "One move as ONE plist (critique-design §3.4). Keys:
  :kind     :quick :flash :sig :sp :breaker :kikon (sets the defaults of :track, :hs; a :breaker
            takes S/A/R, whiff, damage, reach, knockback from tuning.lisp unless given; a :kikon is
            the Kikon rush: :params (:aura f :aim deg/s :speed m/s :dash-max f :dash-track deg/s, 0 =
            locked at take-off), then its own strike S/A/R, and :cine)
  :clip :clip-2  clip names (§5; :clip-2 = the second part: throw, strike, cut, flurry)
  :clip-s   the startup the :clip-2 / :clip was authored with (a clip reused at another startup
            plays at clip-s / S speed, so it still reaches its hit pose on frame S)
  :callout  move name shown above the user (Signature / SP / Breaker / Kikon)
  :startup :active :recovery  frame data; :whiff  recovery after a whiff (default R + 6; a J link, :quick, R +
            *WHIFF-EXTRA-J*, a K link, :flash, R + *WHIFF-EXTRA-K*)
  :dmg :adv-block  damage and block advantage (§5 table; NIL = no melee block data)
  :track    deg/s turn during startup; :reach metres; :arc degrees; :height (y0 y1) of the arc;
  :vol      explicit volume (:arc r deg y0 y1 | :cap a b h r [yaw-deg] | :sph fwd up r) instead of reach/arc
  :vols     several volumes in one hit window (it still hits once: a fan of lines), (spec ...); the reach is the first's
  :on-hit   reaction; :kb knockback m; :hs hitstop f; :chip block chip fraction
  :guard    guard gauge a block drains (default by kind, GUARD-VALUE)
  :armor-hits  hits the move's armour takes (move frames *ARMOR-FROM* .. S-1; a Kikon rush: its dash)
  :cooldown frames before its command may start again (from the move start; kept through resets)
  :hold     (min max) frames the button is held before the move proper (charge / stance); :slide metres moved during the move
  :flags    :ender (a string's link 3, J3 / K3: a hit on it opens the O ender, docs/duel/DUEL_STRINGS.md §2.4)
            :breaker :guard-crush :stance :parry (a parry move: *PARRY-WINDOW*) :cancel (a Signature
            that may cancel a landed Quick / Flash, like an SP)
            :ranged (a hit delivered by fire / a ground line, not the blade: like a hazard, no parry catches it;
            with :params (:melee-range r) only beyond r of the attacker: nearer it is the blade, a melee hit;
            one window, so it still hits once)
  :hits     ((from to &key dmg on-hit kb vol vols reach chip flags hs guard) ...) multi-hit windows;
            default: one window [S, S+A) when the move has damage and a volume
  :on-frame ((frame hook) ...), :tick hook (every frame), :release hook (button released during
            :hold), :on-land hook (first hit connects), :cine hook (Kikon cinematic)
  :params   free plist for the hooks (projectile speed, flurry hits ...); :form-mult x replaces the form's damage x
            (kit :mult) for this move's own hits (KIT-ATK-MODS)
  :enter    start at this move frame (skips that much of the wind-up and of the clip): a string
            link that must combo after a J and a K link alike (every K2 / K3: S_eff 14); a derived form adds its startup-add to it
  :blend    crossfade frames into the clip (default 0, attacks snap); :planted  weapon planted
            in the ground during the strike (drawn with DRAW-PLANTED-WEAPON)
  :min-reach  m: the move's windows (a window's own :min-reach in its place) miss a victim nearer than this, centre to
            centre (COLLECT-MELEE; a Kikon's follow-up strike excepted): a dead zone (Hisagi's ranged mode, DUEL_HISAGI §22.2;
            the kit's :min-reach hook may lift it, §29)
  hits: :steal-fs  flash-step a stealing AS takes on this window's hit (else its :params :steal-fs; CORE-ON-HIT!, 2026-11-12);
        :stun  hitstun override (frames); :seg-fn SYMBOL  a kit function (e) -> (values ax ay az bx by bz r), this frame's
            world capsule, tested in place of the window's volumes (WINDOW-TOUCHES-P; the CPU: SEG-GAP); the window is
            the move's own, so its contact counts as the move's (strings, O ender, SP cancels, :on-land, ender push)
  flags also: :rend (armour and a stance don't stop it: RESOLVE-CONTACT) :grab (a grab: the CPU never guards it)
            :step-branch (a stance whose :tick takes Step as a
            follow-up: the one-hand up-flick stays a Step in it, never a Hoho: control.lisp UP-FLICK-HOHO-P)
            :no-close (a J1 / K1 whose hit takes no generic close-in: STRING-OPENER-P; Hisagi's 6 m throw)
            :ranged-ward (while the move runs, hazards and :ranged windows are guarded from every side: rules
            RANGED-WARD-STATE; unguardables pass; a GUARD CRUSH drops the move)"
  `(register-move ,name ',spec))

;;; ================================================================ kits
(defparameter *kit-commands* '(:q :f :sig :sp1 :sp2 :breaker :kikon)
  "Commands every kit form maps to a move (:step :hoho :burst :awaken are universal).")

(defstruct (kit (:conc-name kit-))
  "One character in one form. See DEFKIT for the fields."
  (character nil) (form nil) (inherit nil) (name nil)
  (awakening nil) (awaken-form nil) (duration nil) (burn 0.0)
  (mult 1.0) (taken 1.0) (cornered 0.0) (cornered-max 0.0) (passives nil)
  (walk 3.0) (run 8.0) (run-clips '(:sh-run :sh-skate-b :sh-slide-r :sh-slide-l)) (reishi *reishi-max*) (body nil) (weapon nil) (stance nil) (hide nil) (aura nil)
  (lift 0.0)
  (intro nil) (win nil) (intro-callout nil) (intro-weapon nil) (callout nil)
  (swing-sfx nil) (absorb-sfx nil)
  (enter-clips nil) (enter-hook nil) (exit-hook nil)
  (meter nil) (cine nil) (blade nil) (grade nil)
  (kikon-konpaku 2 :type fixnum)        ; Konpaku a Kikon of this form removes (read at rush start)
  (form-name nil)                       ; the form's name on the HUD (default its keyword)
  (respect-callout nil)                 ; said when the opponent outplays him (a counter-hit, a perfect Hoho, a parry, a Burst)
  (reset-form nil)                      ; a Kikon / Soul Break reset puts the fighter in this form
  (calm nil)                            ; the face never shouts in this form (a look: MAIN.LISP FACE-OF)
  (face nil)                            ; the form's resting expression (NIL = :neutral; a look: DRAW.LISP FACE-OF)
  (stun-tolerance nil)                  ; the hidden stun it takes (NIL: *STUN-TOLERANCE*; STUN-TOLERANCE-OF)
  (gg-regen 1.0)                        ; x the guard gauge's refill rate in this form, not guardless (rules GG-REGEN)
  (l-after-k nil)                       ; L chained after a K link (docs/duel/DUEL_STRINGS.md §12): T its L, or a move (a combo copy)
  (l-after-j nil)                       ; ... after a J link (J1 / J2 / J2s / J3): T its L, or a move
  (hooks nil)                           ; plist hook point -> the character file's function (KIT-HOOK; docs/duel/DUEL_DESIGN.md
                                        ; "Character code layout")
  (clip-map nil)                        ; plist clip -> clip: the form plays its moves' clips as these (a look: KIT-MOVE-CLIP)
  (push-reach nil)                      ; NIL, or the reach a K ender's push is measured from in place of K1's (ENDER-PUSH-REACH)
  (look-clips nil)                      ; plist shared clip -> clip: the form plays these generic clips (its guard) as its own
                                        ; (a look: FIGHTER.LISP PLAY-CLIP, as a body variant's :clips; Lille II's wing wall)
  (core nil)                            ; the core system's moves (docs/duel/DUEL_CORE.md): (:ns (n1 n2 n3) :as (a1 a2 a3) :sa move)
  (open-s nil)                          ; NIL, or the startup of every NS first segment that hits (the form's tier: KIT-CADENCE)
  (hs-dmg nil)                          ; NIL, or (base per min max): every hit's hitstop from its damage (HS-BY-DAMAGE)
  (cls (make-hash-table :test 'eq))     ; MOVE -> :na :ns :as :sa (the triangle's class; built by REGISTER-KIT)
  (sp (make-hash-table :test 'eq))      ; move name -> the SP an NS / AS segment costs (BUILD-SP-COSTS; DUEL_SP §4)
  (commands nil)                ; plist command -> move name
  (strings nil)                 ; ((from-move command to-move) ...)
  (moves (make-hash-table :test 'eq))   ; move name -> this form's MOVE
  (spec nil))
(inline-readers kit)

(defvar *kits* (make-hash-table :test 'eq) "Character -> alist (form . KIT) (no consing to look one up).")
(defvar *roster* (list :yamamoto :kenpachi :rukia :ichigo :senjumaru :lille :barro)
  "Every character, by its index (the saved data's, the gates' pairings; the select screen plays PLAYABLE-ROSTER). The seven
slots of the retired kits (*RETIRED*: their code left main on 2026-11-12, branch `retired-kits`) and of the playing ones before
Hisagi are fixed here, no kit behind the retired ones; a later character's first :base DEFKIT appends it (Hisagi, 7).")
(defparameter *retired* '(:lille :yamamoto :rukia :senjumaru :barro)
  "Roster slots kept for their index (the saved learning tables and records, the gates' pairing numbers) with no character:
never on the select screen, a random opponent, or a default seed gate. Since 2026-10-27 (the core system,
docs/duel/DUEL_CORE.md: 「先只做 2 到 3 個差異大的角色」, the user's 「妥」) also the four characters waiting to be ported to it
(:yamamoto :rukia :senjumaru :barro: their code left main on 2026-11-12, REFACTOR_2026-11 R2 / B8a, and lives on the branch `retired-kits`); only Kenpachi, Ichigo and Hisagi play. :lille, index 5: the old Lille, out of the
game since 2026-10-12 (「幫我將舊版的 lille 從遊戲中移除」, DEVLOG §208), his code removed 2026-10-13 (「幫我移除舊版的 lille」:
barro.lisp reserves the slot; Lille, kit :barro, is 6).")
(defun playable-roster () "*ROSTER* without the *RETIRED* characters." (remove-if (lambda (c) (member c *retired*)) *roster*))
(defun find-kit (character form)
  (or (cdr (assoc form (gethash character *kits*))) (error "unknown kit ~s ~s" character form)))

(defun kit-move (kit name)
  (or (gethash name (kit-moves kit)) (error "kit ~s ~s has no move ~s" (kit-character kit) (kit-form kit) name)))
(defun kit-command-move (kit command &optional e)
  "The move COMMAND starts from neutral, or NIL. Given fighter E, the kit's :command hook (e command) picks first: a MOVE,
or NIL for the form's :commands entry (a kit with two neutral graphs: DUEL_HISAGI §7.2, the sickle out of hand). Callers
without E (the CPU's reach reads, the HUD) see the :commands entry."
  (or (and e (let ((h (kit-hook kit :command))) (and h (funcall h e command))))
      (let ((name (getf (kit-commands kit) command))) (and name (kit-move kit name)))))
(defun kit-next (kit move-name command)
  "The string follow-up of MOVE-NAME for COMMAND (J1 -q-> J2, J2 -f-> K3 ...), a MOVE or NIL."
  (loop for (from cmd to) in (kit-strings kit)
        when (and (eq from move-name) (eq cmd command)) return (kit-move kit to)))

(defun string-link-p (kit move-name)
  "Does MOVE-NAME go on as a J / K string (a :q or :f follow-up)? While it runs every J / K press is taken by the
latch (STRING-LATCH); link 3 has none, so presses there are plain buffered presses (a new J1 after it)."
  (and (or (kit-next kit move-name :q) (kit-next kit move-name :f)) t))
(defun kit-k-link-p (kit move-name)
  "Is MOVE-NAME a K link of KIT's J / K strings: K1 (the :f command's move), or an :f follow-up (K2, K2s, K3)?"
  (or (eq move-name (getf (kit-commands kit) :f))
      (loop for (nil cmd to) in (kit-strings kit) thereis (and (eq cmd :f) (eq to move-name)))))
(defun kit-j-link-p (kit move-name)
  "Is MOVE-NAME a J link of KIT's J / K strings: J1 (the :q command's move), or a :q follow-up (J2, J2s, J3)?"
  (or (eq move-name (getf (kit-commands kit) :q))
      (loop for (nil cmd to) in (kit-strings kit) thereis (and (eq cmd :q) (eq to move-name)))))
(defun kit-l-link (kit move-name)
  "The L link after string link MOVE-NAME (docs/duel/DUEL_STRINGS.md §12): after a K link the kit's :l-after-k, after a J
link its :l-after-j; the form's L (T) or the named copy of it, a MOVE; NIL when the form has none for that link. A plist
(link-move L-move ...) names each link's own L (Rukia's six bursts, DUEL_RUKIA_TYBW §4.3); a link it lacks has none."
  (let ((l (cond ((kit-k-link-p kit move-name) (kit-l-after-k kit)) ((kit-j-link-p kit move-name) (kit-l-after-j kit)))))
    (cond ((eq l t) (kit-command-move kit :sig))
          ((consp l) (let ((m (getf l move-name))) (and m (kit-move kit m))))
          (l (kit-move kit l)))))
(defun string-latch (kit move-name command queued)
  "The latch (docs/duel/DUEL_STRINGS.md §2.1, §2.3): a J / K press (COMMAND :q / :f) during string link MOVE-NAME, with
QUEUED latched so far. The new latched command: COMMAND when the string may go on with it (the last press wins),
else QUEUED: the press is eaten (after a switch the original button is ignored and overwrites nothing)."
  (if (kit-next kit move-name command) command queued))
(defun string-opener-p (kit mv &optional e)
  "Is MV a J / K string's opener in KIT (J1 / K1: the :q / :f command's move, E's :command hook consulted) that takes the
generic close-in on a hit (combat.lisp: the attacker dashes to *STRING-PULL-TO*)? Not with the move flag :no-close."
  (and (member (mv-kind mv) '(:quick :flash)) (not (member :no-close (mv-flags mv)))
       (eq mv (kit-command-move kit (if (eq (mv-kind mv) :quick) :q :f) e))))
(defun move-edge (mv)
  "MV's far edge, where it still touches a hurt cylinder's near side: its reach, + its first volume's radius when that is a
capsule (a capsule hits out to b + r; the user 2026-10-24: 「請修改推開規則，要將半徑也計算進去」, DUEL_RUKIA_TYBW §15)."
  (let* ((hits (mv-hits mv)) (v (and (plusp (length hits)) (first (hw-vols (svref hits 0))))))
    (if (and v (= (aref v 0) 1f0)) (+ (mv-reach mv) (aref v 4)) (mv-reach mv))))
(defun sp-move-p (kit mv)
  "Is MV an SP of KIT: kind :sp, or its :sp1 / :sp2 command's move (Hisagi's ranged KUBIKAKE, Lille's SHIN recall)? Its
hits and its hazards' ignore the combo scaling (the user 2026-10-24: 「所有角色的 SP 也都設置成不受傷害減免影響」)."
  (or (eq (mv-kind mv) :sp) (eq mv (kit-command-move kit :sp1)) (eq mv (kit-command-move kit :sp2))))
(defun ender-push-reach (kit mv opener)
  "The reach a string ender MV's push is measured from (fighter.lisp ENDER-PUSH): a K ender's the kit's :push-reach when
it has one, else OPENER's far edge (J1's after J3, K1's after K3: MOVE-EDGE)."
  (or (and (not (eq (mv-kind mv) :quick)) (kit-push-reach kit)) (move-edge opener)))
(declaim (inline kit-hook))
(defun kit-hook (kit point)
  "The character file's function for hook POINT in KIT (its :hooks plist), or NIL: the generic code calls it where the
point is (docs/duel/DUEL_DESIGN.md \"Character code layout\")."
  (plist-get (kit-hooks kit) point))                  ; (GETF's result, one walk: DEVLOG §621)
(defvar *char-debug* nil "(lo hi fn): debug commands LO..HI a character file handles (debug.lisp calls FN with the command).")
(defun kit-kikon-cine (kit)
  "The cinematic a Soul Break by a fighter in KIT plays (the user's decision 2026-09-27): the form's own (its :hooks
:soul-break-cine, a cinematic's name), else its Kikon cinematic, the one its O would play now (its :kikon move's :cine),
else the generic SOUL-BREAK-CINE."
  (let ((mv (kit-command-move kit :kikon)))
    (or (kit-hook kit :soul-break-cine) (and mv (mv-cine mv)) 'soul-break-cine)))
(defun stun-tolerance-of (kit) "The hidden stun KIT's form takes (its :stun-tolerance, else *STUN-TOLERANCE*)." (or (kit-stun-tolerance kit) *stun-tolerance*))

(defun kit-atk-mods (kit lost &optional (hit-x 1.0) form-mult)
  "The attacker plist for HIT-DAMAGE: the form's multiplier (FORM-MULT in its place when given: a move's :params
:form-mult) x HIT-X (the hit's own factors: APPLY-HIT) and Cornered with LOST Konpaku."
  (list :mult (* (or form-mult (kit-mult kit)) hit-x (if (and *core-on* (kit-core kit)) (* *core-damage* (getf (kit-core kit) :mult 1.0)) 1.0)) :cornered (kit-cornered kit) :cornered-max (kit-cornered-max kit) :lost lost))
(defun kit-def-mods (kit)
  "The defender plist for HIT-DAMAGE: the damage the form takes (:taken)."
  (list :mult (kit-taken kit)))
(defun kit-move-clip (kit clip)
  "The clip a fighter in KIT plays for a move's CLIP: the form's :clip-map entry, else CLIP (NIL stays NIL). A look only:
the move (its name, frames and volumes) is the same in every form that has it (Lille's awakened forms play
the base form's clips on his wings, barro.lisp's :clip-map)."
  (if clip (or (getf (kit-clip-map kit) clip) clip) clip))
(defun kit-clips (kit)
  "Every clip name the form uses (moves, stance, intro/win, entry cinematic, the run, its :look-clips' own), its moves'
through its :clip-map."
  (remove-duplicates
   (remove nil (append (list (kit-stance kit) (kit-intro kit) (kit-win kit)) (kit-enter-clips kit) (kit-run-clips kit)
                       (loop for (nil c) on (kit-look-clips kit) by #'cddr collect c)
                       (loop for mv being the hash-values of (kit-moves kit)
                             collect (kit-move-clip kit (mv-clip mv)) collect (kit-move-clip kit (mv-clip-2 mv)))))))

(defun strip-keys (plist keys) "PLIST without the entries of KEYS (a fresh list)."
  (loop for (k v) on plist by #'cddr unless (member k keys) append (list k v)))

;;; A form's cadence (Kenpachi, the user 2026-11-02: 「節奏：前搖分級與打擊停頓」, DUEL_KEN_CORE §7.2): :open-s, the startup tier of its
;;; NS openers, and :hs-dmg, the hitstop by damage. Applied to the form's own move table after the derivation.
(defvar *cadence-moves* (make-hash-table :test 'equal)
  "Copies made by KIT-CADENCE, keyed by (move s) / (move :hs), so a move two forms share stays one move.")
;; ponytail: the :hs key ignores the spec, since one character uses :hs-dmg; key it by the spec if a second one does

(defun hs-by-damage (dmg spec)
  "The hitstop of a hit of DMG under :hs-dmg SPEC (base zero per lo hi): base + (dmg - zero) / per, rounded, within lo .. hi."
  (destructuring-bind (base zero per lo hi) spec
    (max lo (min hi (round (+ base (/ (- dmg zero) per)))))))

(defun move-hs-by-damage (mv spec)
  "MV with each damaging hit's hitstop from its damage (HS-BY-DAMAGE)."
  (or (gethash (list mv :hs) *cadence-moves*)
      (let ((m (copy-move mv)))
        (setf (mv-hits m) (map 'simple-vector (lambda (h) (if (plusp (hw-dmg h))
                                                              (let ((c (copy-hitwin h))) (setf (hw-hs c) (hs-by-damage (hw-dmg h) spec)) c)
                                                              h))
                               (mv-hits mv)))
        (setf (gethash (list m :hs) *cadence-moves*) m (gethash (list mv :hs) *cadence-moves*) m))))

(defun move-with-startup (mv s)
  "MV starting on frame S: frames inside the startup (early hooks, :enter) scale with it, like its clip; the hits and every
later frame shift by the difference."
  (or (gethash (list mv s) *cadence-moves*)
      (let* ((s0 (mv-s mv)) (d (- s s0)) (m (copy-move mv)))
        (flet ((at (f) (if (<= f s0) (round (* f s) s0) (+ f d))))
          (setf (mv-s m) s
                (mv-hits m) (map 'simple-vector (lambda (h) (let ((c (copy-hitwin h)))
                                                              (setf (hw-from c) (at (hw-from h)) (hw-to c) (at (hw-to h)))
                                                              c))
                                 (mv-hits mv))
                (mv-on-frame m) (loop for (f hook) in (mv-on-frame mv) collect (list (at f) hook))
                (mv-enter m) (if (plusp (mv-enter mv)) (at (mv-enter mv)) 0)
                (mv-clip-speed m) (/ (* (mv-clip-speed mv) s0) (float s))))
        (setf (gethash (list mv s) *cadence-moves*) m))))

(defun kit-cadence (kit)
  "KIT's :hs-dmg on every move it holds, then its :open-s on each NS first segment that hits (a charge keeps its length)."
  (let ((open (kit-open-s kit)) (hs (kit-hs-dmg kit)) (moves (kit-moves kit)))
    (when hs
      (maphash (lambda (k mv) (setf (gethash k moves) (move-hs-by-damage mv hs))) moves))
    (when open
      (dolist (n (getf (kit-core kit) :ns))
        (let ((mv (gethash n moves)))
          (when (and mv (plusp (length (mv-hits mv))) (/= (mv-s mv) open))
            (setf (gethash n moves) (move-with-startup mv open))))))))

(defun register-kit (character form spec)
  (let* ((spec (resolve-tuning spec))
         (parent (and (getf spec :inherit) (find-kit character (getf spec :inherit))))
         (pspec (and parent (kit-spec parent)))
         (commands (append (getf spec :commands) (and parent (kit-commands parent))))
         (strings (append (getf spec :strings) (and (getf spec :grid) (string-grid (getf spec :grid)))
                          (and parent (kit-strings parent))))
         ;; the SA's links go first: a form's own (its J2) must win over the ones it inherits (KITS-NEXT takes the first match: KESSA's
         ;; SA went on into the Shikai's two-blade J2 / J3, the user 2026-10-28: 「畫面上看到的是始解的雙刀動作」)
         (strings (append (core-sa-strings (or (getf spec :core) (and pspec (getf pspec :core))) commands strings) strings))
         ;; the child's keys come first, so they win (a keyword argument list takes the leftmost)
         (merged (list* :commands commands :strings strings
                        (append spec (strip-keys pspec '(:inherit :startup-add :reach-mult :grid)))))
         (startup-add (getf merged :startup-add 0)) (reach-mult (getf merged :reach-mult 1.0)))
    ;; every other key is a slot of the same name (MAKE-KIT refuses an unknown one); a key the form doesn't set keeps the
    ;; slot's default (DEFSTRUCT KIT)
    (let ((kit (apply #'make-kit :character character :form form :spec merged
                      :kikon-konpaku (or (getf merged :kikon-konpaku)
                                         (if (getf merged :awakening) *kikon-konpaku-awakened* *kikon-konpaku*))
                      :form-name (or (getf merged :form-name) (symbol-name form))
                      (strip-keys merged '(:startup-add :reach-mult :grid))))
          (own (loop for (nil m) on (getf spec :commands) by #'cddr collect m)))
      ;; every move the form can reach. The derivation rule (design v2 §0): a move is as written when the
      ;; form lists it in its own :commands or the parent form doesn't have it (new to this form: its
      ;; own strings); an inherited one gets the form's derivation (:startup-add / :reach-mult), and a form
      ;; with no derivation takes the parent's version of it (Nozarashi v2 §2.8: NOMIHOSE plays RYOTE's
      ;; derived moves, not the written ones)
      (dolist (m (remove-duplicates
                  (append (loop for (nil m) on commands by #'cddr when m collect m)   ; (a NIL command: none in this form)
                          (loop for (from nil to) in strings collect from collect to)
                          (loop for l in (list (kit-l-after-k kit) (kit-l-after-j kit))   ; (a per-link plist: its moves)
                                append (cond ((consp l) (loop for (nil m) on l by #'cddr collect m)) ((and l (not (eq l t))) (list l))))
                          (core-move-names (kit-core kit)))))
        (let ((mv (find-move m)) (pmv (and parent (gethash m (kit-moves parent)))))
          (setf (gethash m (kit-moves kit))
                (cond ((or (member m own) (not pmv)) mv)
                      ((and (eql startup-add 0) (= reach-mult 1)) pmv)
                      (t (parse-move m (mv-spec mv) :startup-add startup-add :reach-mult reach-mult))))))
      (kit-cadence kit)
      (build-core-classes kit)
      (build-sp-costs kit)
      (when (and (eq form :base) (not (member character *roster*)))
        (setf *roster* (append *roster* (list character))))
      (let ((forms (remove form (gethash character *kits*) :key #'car)))
        (setf (gethash character *kits*) (acons form kit forms)))
      kit)))

;;; ---------------------------------------------------------------- the core system's moves (docs/duel/DUEL_CORE.md)
(defun core-segment-sas (core)
  "The SAs of single NS segments (a segment's :params :sa: the SA an attack in its gap starts instead of the kit's; Ichigo's charges,
2026-10-27)."
  (loop for n in (getf core :ns) append (loop for m in (core-segments n) for sa = (getf (mv-params (find-move m)) :sa) when sa collect sa)))
(defun core-sa-strings (core commands strings)
  "The SA goes on like the first J does (the user 2026-10-27: 「SP -> A 後的 A 打不出連擊」): attack -> attack is a continuation, so
the string ((SA :q J2)) follows every SA (the kit's and the segments' own) with what follows J1 on an attack."
  (let* ((j1 (getf commands :q))
         (j2 (loop for (from cmd to) in strings when (and (eq from j1) (eq cmd :q)) return to)))
    (and j2 (loop for sa in (append (and (getf core :sa) (list (getf core :sa))) (core-segment-sas core)) collect (list sa :q j2)))))
(defun core-segments (name)
  "NAME and the segments after it (each move's :params :ns-next: an NS's or an AS's next segment, one SP press each), in order."
  (loop for n = name then (getf (mv-params (find-move n)) :ns-next) while n collect n))
(defun core-move-names (core)
  "Every move name a kit's :core plist reaches: the three NS and the three AS sequences (every segment), the SA, and the moves of
:ALSO (not in the grammar: kept in the table so a form that inherits this one derives them, Kenpachi's KATATE for RYOTE)."
  (append (getf core :also) (loop for n in (append (getf core :ns) (getf core :as))
                append (loop for m in (core-segments n) collect m
                             when (getf (mv-params (find-move m)) :kikon-strike) collect it))   ; (a wave's follow-up strike)
          (core-segment-sas core) (and (getf core :sa) (list (getf core :sa)))))
(defun build-core-classes (kit)
  "Fill KIT's class table: the moves of its :q string are NA (J1 .. J3), its :core moves NS / AS / SA."
  (let ((h (kit-cls kit)) (core (kit-core kit)))
    (labels ((tag (name cls)
               (let ((mv (gethash name (kit-moves kit))))
                 (when mv
                   (setf (gethash mv h) cls)
                   (let ((s (getf (mv-params mv) :kikon-strike))) (when s (tag s cls)))))))   ; (its segment's class)
      (when (getf (kit-commands kit) :q) (tag (getf (kit-commands kit) :q) :na))
      (loop for (from cmd to) in (kit-strings kit) when (eq cmd :q) do (tag from :na) (tag to :na))
      (loop for n in (getf core :ns) do (dolist (m (core-segments n)) (tag m :ns)))
      (loop for n in (getf core :as) do (dolist (m (core-segments n)) (tag m :as)))
      (when (getf core :sa) (tag (getf core :sa) :sa))
      (dolist (m (core-segment-sas core)) (tag m :sa)))))
;; The SP costs (DUEL_SP §4, §8.2, batch S2). Kept per kit and by move name, not in a MOVE slot: a kit's :sp-cost-mult (Kenpachi's forms)
;; is not known when a move is parsed, the rule rounds once (after the multiplier), and KIT-CADENCE puts copies of a form's moves in its table.
(defun mv-sp-damage (mv)
  "A segment's damage for its SP cost: the sum of its hit windows, else a wave's :params :dmg (its Kikon strike is free), else 0 (a setup
segment: the minimum cost)."
  (let ((h (loop for w across (mv-hits mv) sum (hw-dmg w))))
    (cond ((plusp h) h) ((getf (mv-params mv) :dmg)) (t 0))))
(defun build-sp-costs (kit)
  "Fill KIT's SP cost table once, at registration: every segment of its :core NS and AS sequences (CORE-SEGMENTS; a wave's Kikon strike is
not one: free), SP-COST of its damage x the kit's :core :sp-cost-mult (default 1), or its own :params :sp-cost."
  (let* ((core (kit-core kit)) (mult (getf core :sp-cost-mult 1.0)) (h (kit-sp kit)))
    (dolist (n (append (getf core :ns) (getf core :as)))
      (dolist (m (core-segments n))
        (let ((mv (gethash m (kit-moves kit))))
          (when mv (setf (gethash m h) (f32 (sp-cost (mv-sp-damage mv) mult (getf (mv-params mv) :sp-cost))))))))))
(defun kit-sp-cost (kit mv) "What NS / AS segment MV costs in KIT (single-float), else NIL (not an SP segment: free)." (and mv (values (gethash (mv-name mv) (kit-sp kit)))))
(defun kit-class (kit mv) "The triangle class of MV in KIT (:na :ns :as :sa), or NIL." (and mv (gethash mv (kit-cls kit))))
(defun kit-sp-start-p (kit mv fs bursting)
  "May MV start for a fighter of KIT whose flash-step gauge is FS (BURSTING: in a burst; DUEL_SP §3)? A move with no SP cost (an NA link,
the SA, a Kikon strike): always; an NS / AS segment by SP-START-P, its FIRST = MV is a route's first segment (in the kit's :core :ns,
wherever it starts: §8.6 Q17). The one test CORE-START! refuses by (every start: a press, the pointer switch's NS1, HOHO-RESUME!'s
segment, a parry's catch) and the CPU reads before it presses (core-ai CAI-NEXT-OK-P, DUEL_SP S7): pure, of the kit's data and two numbers."
  (or (null (kit-sp-cost kit mv))
      (sp-start-p (kit-class kit mv) (member (mv-name mv) (getf (kit-core kit) :ns)) fs bursting)))
(defun kit-core-move (kit role n)
  "The core move of ROLE (:ns or :as) number N (1 .. 3) of KIT, or NIL."
  (let ((name (nth (1- n) (getf (kit-core kit) role)))) (and name (gethash name (kit-moves kit)))))
(defun kit-sa-move (kit) "KIT's SA move, or NIL." (let ((n (getf (kit-core kit) :sa))) (and n (gethash n (kit-moves kit)))))
(defun mv-sa-move (kit mv) "The SA of NS segment MV's gap (its :params :sa), or NIL: then the kit's." (let ((n (getf (mv-params mv) :sa))) (and n (gethash n (kit-moves kit)))))
(defun mv-ns-next (kit mv) "The NS or AS segment after MV in KIT, or NIL." (let ((n (getf (mv-params mv) :ns-next))) (and n (gethash n (kit-moves kit)))))

(defmacro defkit (character form &rest spec)
  "One character form as one plist. :inherit FORM takes every key of that (earlier) form; the
child's keys win, :commands merge per command, :strings add. Keys:
  :name :body :weapon :stance :hide (body part tags hidden) :aura  look (art agent's names)
  :walk :run :reishi                 stats (walk / run speed m/s)
  :lift M                           the body drawn M metres up in every clip while it wears the form's :body (a floating
                                     form: main.lisp BODY-LIFT; a look only, the sim stays on the ground), default 0
  :run-clips (fwd back right left)  the run's clips (he faces the opponent: forward run, back-skate, side
                                     slides; body.lisp DEFRUN), default the shared :sh-* set
  :commands (:q m :f m :sig m :sp1 m :sp2 m :breaker m :kikon m)   see *KIT-COMMANDS*
  :grid (J1 J2 J3 K1 K2 K3 J2s K2s)  the J / K strings as one grid (STRING-GRID), added to :strings
  :strings ((from-move command to-move) ...)   the J / K grid (docs/duel/DUEL_STRINGS.md §1): J1 -q-> J2 -q-> J3,
                                     J1 -f-> K2s -f-> K3 ... (a switched link-2 alias allows only the new
                                     button: J / K switch at most once); a non-button command (:land) names a
                                     follow-up a hook starts (KIT-NEXT), so derived forms derive it too
  :mult :cornered :cornered-max      §4 damage dealt (KIT-ATK-MODS)   :taken  damage x taken (KIT-DEF-MODS)
  :passives (:projectile-cut :parry-block)   (:projectile-cut: his blade cuts a projectile; :parry-block: what his parry
                                     can't catch is blocked from every side: combat.lisp)
  :awakening T (an awakened form)    :awaken-form FORM (what Awaken turns this character into)
  :duration seconds (NIL = permanent; then back to :inherit)   :burn Reishi fraction/s
  :startup-add :reach-mult           derive the inherited moves (not inherited themselves)
  :meter (:name :max)                the character's meter (the kit meter, GAUGES-METER)
  :enter-clips :enter-hook :exit-hook  form change presentation
  :swing-sfx :absorb-sfx             sounds of a non-Quick swing (default :whoosh-heavy) and of a
                                     hit the stance absorbs (Kenpachi's laugh)
  :cine SYMBOL                       the DEFCINE played when the form is entered (awakening)
  :kikon-konpaku n                   Konpaku a Kikon removes in this form (default 2, awakened 3; read when the
                                     rush starts; a Soul Break +1, at most *KIKON-MAX-EVENT*)
  :meter (... :start n :ladder ((form drain/s delay up-at down-below) ...))   a meter that picks the form
                                     (Nozarashi's NOME: rules LADDER-RUNG, ken-meter.lisp KEN-NOME-STEP); :start = its value
                                     at the awakening
  :form-name :respect-callout        the HUD's form name; the callout when the opponent outplays him
  :reset-form FORM                   the form after a Kikon reset
  :l-after-k T | MOVE                L latched during a K link (K1 / K2 / K2s / K3) starts when that link's chain opens
                                     (its own contact, docs/duel/DUEL_STRINGS.md §12): T the form's L, else MOVE, a combo copy
  :l-after-j T | MOVE                the same after a J link (J1 / J2 / J2s / J3); either may be a plist (link MOVE ...):
                                     each link its own L (KIT-L-LINK; Rukia's bursts)
  :calm T                            the face stays calm (no shout: a look, FACE-OF)
  :face :shout | :hurt               the form's resting expression where FACE-OF would pick :neutral (idle, walk, guard,
                                     a cinematic's onlooker; not the intro's, TIME's or the K.O.'s winner): Kenpachi's cup
                                     3 grins the whole cup (a look; default NIL = :neutral)
  :gg-regen x                        x the guard gauge's refill rate in this form (default 1.0)
  :stun-tolerance n                  the hidden stun the form takes before the blow-away (default *STUN-TOLERANCE*;
                                     a derived form inherits it)
  :hooks (point fn ...)              the character's own mechanics (KIT-HOOK; DUEL_DESIGN.md, Character code
                                     layout): :u (e: U pressed; the form never guards), :step (e: a Step's frame 0), :hoho (e: a Hoho reappears),
                                     :ok (e cmd combo: may the command start; NIL refuses it with the :refused cue),
                                     :command (e cmd: the MOVE a neutral command starts, NIL = the :commands entry, :HOLD
                                     = nothing starts, the press stays buffered; KIT-COMMAND-MOVE),
                                     :tick (e f g: every sim step), :hit / :struck (e other res hw mv hazard ranged: after
                                     a hit it dealt / took), :parried (e att: a catch by its parry), :draw (e rdt: looks
                                     on the posed body), :hud-guard (drawn over its guard bar), :deck (e x y d: the
                                     one-hand thumb ring), :settled (e lost left: a Kikon / Soul Break settled
                                     on it, SETTLE-KONPAKU), :body-alpha (e: the body's draw alpha, a constant
                                     float: a see-through form), :charge (e rdt: drawn instead of the fire charge
                                     look of a held move), :p (e free: P once neither the awakening nor a Bankai
                                     takes it, from a run too; T = the press taken), :p-label (e: the AWAKEN chip's
                                     label, the chip then always shown), :reset (e: a Kikon / Soul Break reset put
                                     him back, RESET-ROUND), :hash (e: a string added to his part of the state-hash
                                     line, or NIL), :link-move (e next: the MOVE a latched J / K link starts instead
                                     of NEXT, NIL = NEXT; fighter.lisp), :clash (e other: a clash, once a step for the
                                     pair, CORE-CLASH!), :min-reach (e m: the dead zone, m or NIL, of his window whose
                                     :min-reach is M, now: COLLECT-MELEE, MV-MIN-REACH; Hisagi's cancel unlock,
                                     DUEL_HISAGI §29; no hook: M), the bind's :bind :bind-damage :bind-pool
                                     :bind-heal :bind-step :bind-resolve :bind-snapshot (combat.lisp BIND-OF; Hisagi,
                                     DUEL_HISAGI §17.4)
  :clip-map (clip clip ...)          a look: the form plays a move's clip (or clip 2) as the mapped one (KIT-MOVE-CLIP:
                                     Jilliel KIN's SANREN on his wings; the move, shared with the base form, is unchanged)
  :look-clips (clip clip ...)        a look: the form plays a shared clip the generic code starts (the guard's :sh-guard /
                                     :sh-guard-hit) as the mapped one (FIGHTER.LISP PLAY-CLIP; Lille II's awakened wing wall,
                                     DUEL_LILLE_V3: the wing wall); no state, timer or volume reads a clip
  :push-reach M                      a K ender's (K3's) push is measured from M m instead of K1's reach (ENDER-PUSH-REACH;
                                     Hisagi's 6 m throw: 6.0, DUEL_HISAGI Q6 B), default NIL
  :meter (... :draw fn :label fn :bankai-prompt (:key :right :pad :one-hand strings :rgb colour))  a character's own meter
                                     row / portrait label / BANKAI prompt words
  :blade (look power)                blade look drawn along the held weapon: (:fire 1.0) (:embers 1.0)
  :grade                             the world's grade while the form is on: NIL, or :SPOT (grey but the ember
                                     hue: the composite's spot-keep mode, main.lisp FORM-GRADE)
  :intro :win :intro-callout :callout  clips / texts; :intro-weapon (key frame) = a prop held in the
                                     intro clip until FRAME (Yamamoto's cane)"
  `(register-kit ,character ,form ',spec))

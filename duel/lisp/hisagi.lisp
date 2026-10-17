;;;; hisagi.lisp — HISAGI SHUHEI (檜佐木修兵), roster index 7, kit :hisagi (docs/duel/DUEL_HISAGI.md). Batch B2a: the
;;;; Shikai 風死 KAZESHINI (:base) playable; the Bankai (§17, the ranged and bind modes) is batch B2b (the ";; B2b" seams
;;;; below: until then the awakening gauge stops one point short of EVOLUTION, so P does nothing).
;;;; The Shikai (§7-§8): two kusarigama joined by a chain. The sickle has three states (§7.1): IN (in hand), OUT (thrown:
;;;; NAGE / MAKI at their S frame, the anchor written at the first contact or the line's end), RETURNING (the 8 f
;;;; auto-retrieve). The 60 f auto-retrieve timer counts only frames out of his moves, so the state changes only at a
;;;; throw's / pull's S frame, the auto-retrieve, a reset, never inside a move, and every route's state follows from its
;;;; start state: two static string graphs (§7.2), the IN graph as the kit's :strings and the OUT graph's neutral J1 / K
;;;; through the :command hook (one-handed J, K = MODOSHI the no-hit retrieve). The pulls (HIKI, HODOKI) hit along the
;;;; chain from the anchor to his hand (:seg-fn HS-CHAIN-SEG). L is the windmill KAZAGURUMA (:ranged-ward, Q3 A).
;;;; Everything of his lives here and in hisagi-art.lisp; the shared files only call his :hooks. Plain CL above the hooks:
;;;; the host rules test loads it.
(in-package :duel)
(declaim (special *p1* *p2* *match-tick* *match-seed* *pacing* *pacing-log*))   ; (flow.lisp's, components.lisp's)

;;; ================================================================ knobs (DUEL_HISAGI §7-§8, debug 83000-83999)
(defparameter *hs-walk* 3.8 "Walk m/s, the Shikai (the lead's proposal 2026-10-16, DUEL_HISAGI §8.1: Rukia's 3.8).")
(defparameter *hs-run* 9.0 "Run m/s, the Shikai (the lead's proposal 2026-10-16, §8.1).")
(defparameter *hs-mult* 1.15
  "Damage dealt x, the Shikai: the first pacing knob (the lead's proposal 2026-10-16, §8.1; 83100+k: 0.5 + k / 100).")
(defparameter *hs-taken* 1.0 "Damage taken x, the Shikai (the lead's proposal 2026-10-16, §8.1; 83200+k).")
(defparameter *hs-out-frames* 60
  "Frames out of his moves after which a thrown sickle comes back by itself (the user, 2026-10-16: 「1 秒自動收回」, §5, §7.1).")
(defparameter *hs-return-frames* 8 "The auto-retrieve's flight, frames: the sickle RETURNING, no hit (the lead's proposal, §7.1).")
(defparameter *hs-chain-max* 6.5
  "Out of his moves, his hand farther than this (m) from the anchor starts the auto-retrieve at once (the lead's proposal, §7.1).")
(defparameter *hs-drag-to* 1.6 "A NAGE / HIKI hit drags the victim to this many metres (§7.4 M2, M3: ICHIGO-PULL-TO's rule) ...")
(defparameter *hs-drag-frames* 10 "... over this many frames (the lead's proposal 2026-10-16, §7.4).")
(defparameter *hs-push-reach* 6.0
  "The K enders' push is measured from this reach (kit :push-reach): out of the throw's full reach, ~6.45 m by the victim
(the user, 2026-10-17: Q6 B, §13).")
(defparameter *hs-arena-in* 0.3 "An anchor is clamped this far inside the arena's wall (§7.1).")
(defparameter *hs-hand-ahead* 0.45 "The sim's hand (the chain's near end, HS-HAND): this far ahead of his feet ...")
(defparameter *hs-hand-up* 1.1 "... this high (m; a sim point, not the drawn hand: the art draws the chain along HS-CHAIN-SEG).")
(defparameter *hs-anchor-up* 1.0 "The anchor's height (m: the victim's centre).")
(defparameter *hs-seg-r* 0.35 "The pulls' chain capsule radius (m, §8.2 HIKI).")
(defparameter *hs-hook-r* 0.5 "The sickle is drawn hooked in the victim while he is within this of the anchor (m, §7.1; a look).")
(defparameter *hs-kaza-min* 20 "The windmill is held at least this many frames from its up frame (f6) ...")
(defparameter *hs-kaza-max* 60 "... at most this many (its move's active frames), then R 14 (the lead's proposal, §8.3).")
;; the CPU (DUEL_HISAGI §10; every chance EASY <= NORMAL <= HARD, rolled once per event)
(defparameter *hs-ai-string-k* 0.7 "His CPU's pull (K) after a NAGE contact, else the one-handed J (the kit's :string-k, §10).")
(defparameter *hs-ai-modoshi-p* '(:easy 0.3 :normal 0.5 :hard 0.7)
  "His CPU, once per OUT start (keyed by the throw's tick): MODOSHI as soon as he is free, else wait for the auto-retrieve.")
(defparameter *hs-ai-windmill-p* '(:easy 0.3 :normal 0.6 :hard 0.9)
  "His CPU: the windmill against a ranged threat (RANGED-THREAT-IN 4-24 f), once per threat (its rising edge).")
(defparameter *hs-ai-windmill-hold* 36 "... L held this many frames (the threat passes).")
(defparameter *hs-ai-sp-ender-p* '(:easy 0.1 :normal 0.3 :hard 0.8)
  "His CPU's SP off a link-3 hit (:sp-ender): SP2 after RIN (IN, 4.5 m line), SP1 after a K ender (6.5 m line).")
(defparameter *hs-ai-opp-step-p* '(:easy 0.1 :normal 0.25 :hard 0.5)
  "A CPU facing him (:opp-reflex): a side Step against NAGE / SP1, once per throw start, while its line will reach it.")

;;; ================================================================ the Shikai 風死 (§8.2, §8.3)
;;; J: the chain held short, one sickle whirled round the body (H1: 1.4 m, 110°, J3 200°, Q5 A). The one-handed copies
;;; (the OUT graph, KJJ) are the same clips at x0.8 written in, :params :one-hand (the empty-hand look).
(defmove :hs-j1 :kind :quick :clip :hs-q1 :startup 8 :active 3 :recovery 12 :dmg 30 :adv-block -2 :guard 8
  :reach 1.4 :arc 110 :on-hit :flinch :slide 0.3)                         ; 旋 SEN
(defmove :hs-j2 :kind :quick :clip :hs-q2 :startup 8 :active 3 :recovery 13 :dmg 30 :adv-block -2 :guard 8
  :reach 1.4 :arc 110 :on-hit :flinch)                                    ; 返旋 KAESHI-SEN
(defmove :hs-j3 :kind :quick :clip :hs-spin :startup 9 :active 3 :recovery 18 :dmg 38 :adv-block -4 :guard 12
  :reach 1.4 :arc 200 :on-hit :stagger :flags (:ender))                   ; 輪 RIN, the full spin
(defmove-copy :hs-j1-1h :hs-j1 :dmg 24 :params (:one-hand t))             ; SEN-1H (the OUT graph's J1)
(defmove-copy :hs-j2-1h :hs-j2 :dmg 24 :params (:one-hand t))             ; KAESHI-SEN-1H (the IN graph's J2s, the OUT J2)
(defmove-copy :hs-j3-1h :hs-j3 :dmg 30 :params (:one-hand t))             ; RIN-1H
;; K: the chain. NAGE throws one sickle along a 6 m line (the blade within 2.0 m, the chain beyond: :ranged), turning
;; 30 deg/s in its startup (§7.4 A1), no generic close-in (:no-close): a hit drags him to 1.6 m (HS-DRAG). The sickle is
;; OUT from its S frame, whatever its result (HS-THROW-OUT); the anchor at the first contact (HS-HIT) or its line's end
;; on its last active frame (HS-TICK)
(defmove :hs-k1 :kind :flash :clip :hs-nage :startup 18 :active 4 :recovery 22 :dmg 62 :adv-block -3 :guard 14
  :vol (:cap 0.3 6.0 1.1 0.3) :track 30.0 :on-hit :stagger :flags (:ranged :no-close) :on-land hs-drag
  :on-frame ((18 hs-throw-out)) :params (:melee-range 2.0 :throw 6.0))     ; 投 NAGE
;; HIKI (K2 after NAGE): the pull from behind (ch. 325): the chain from the anchor to his hand (:seg-fn), the sickle IN at
;; its S; a hit drags him to 1.6 m. An explicit :reach for the generic CPU's range reads
(defmove :hs-k2 :kind :flash :clip :hs-hiki :enter 6 :startup 20 :active 4 :recovery 24 :dmg 56 :adv-block -3 :guard 14
  :reach 6.0 :on-hit :stagger :flags (:ranged) :on-land hs-drag :on-frame ((20 hs-sickle-in))
  :hits ((20 24 :seg-fn hs-chain-seg)) :params (:melee-range 2.0))       ; 引 HIKI
;; MAKI (K2s after J1, Q8 A): the chain flung round his body (a 3.2 m line), the sickle OUT, anchored on him
(defmove :hs-k2s :kind :flash :clip :hs-maki :enter 6 :startup 20 :active 4 :recovery 24 :dmg 52 :adv-block -3 :guard 14
  :vol (:cap 0.3 3.2 1.1 0.35) :on-hit :stagger :on-frame ((20 hs-throw-out)) :params (:throw 3.2))   ; 巻 MAKI
;; K3: KARI-OTOSHI after KAESHI-SEN or HIKI (the overhead drop), HODOKI after MAKI (unwound: the hit from behind along the
;; chain, the sickle IN at its S); both push ~6.45 m (the kit's :push-reach, Q6 B)
(defmove :hs-k3 :kind :flash :clip :hs-kari :enter 8 :startup 22 :active 5 :recovery 34 :dmg 80 :adv-block -20 :guard 18
  :reach 2.8 :arc 120 :on-hit :crumple :flags (:ender))                   ; 刈落 KARI-OTOSHI
(defmove :hs-k3h :kind :flash :clip :hs-hodoki :enter 8 :startup 22 :active 5 :recovery 34 :dmg 78 :adv-block -20 :guard 18
  :reach 3.2 :on-hit :crumple :flags (:ender) :on-frame ((22 hs-sickle-in))
  :hits ((22 27 :seg-fn hs-chain-seg)))                                   ; 解 HODOKI
;; MODOSHI (K while the sickle is out): the retrieve, no hit window, IN at f6; not a string link
(defmove :hs-modoshi :kind :flash :clip :hs-modoshi :startup 6 :active 0 :recovery 6 :on-frame ((6 hs-sickle-in)))   ; 戻
;; L 風車 KAZAGURUMA, the windmill (§8.3, Q3 A): up at f6, held 20-60 f (HS-KAZA-TICK), R 14; one push hit as it comes up
;; (20, 1.5 m, 8 f: no lock), 360 deg r 2.0; while it runs, hazards and :ranged windows are guarded from every side
;; (:ranged-ward: their full guard value, the usual chip, no blockstun; unguardables through; a crush drops it). Rooted,
;; free; refused while the sickle is out (HS-OK); cooldown 90 from the press
(defmove :hs-kaza :kind :sig :clip :hs-kaza :startup 6 :active 60 :recovery 14 :whiff 14 :cooldown 90 :dmg 20
  :vol (:arc 2.0 360 0.2 2.0) :on-hit :flinch :kb 1.5 :hits ((6 9 :stun 8)) :tick hs-kaza-tick :flags (:ranged-ward)
  :on-frame ((6 hs-kaza-up)))
;; Shift+K, SP1 破道の十一 綴雷電 TSUZURI RAIDEN (ch. 337): lightning down its own 6.5 m line in every state, the sickle IN
;; at its S; a hit paralyses 40 f (KUSARI-BIKI's)
(defmove :hs-raiden :kind :sp :clip :hs-raiden :callout "TSUZURI RAIDEN" :startup 20 :active 3 :recovery 24 :dmg 110
  :adv-block -14 :vol (:cap 0.3 6.5 1.1 0.3) :track 30.0 :flags (:ranged) :on-hit :bind :hits ((20 23 :stun 40))
  :on-frame ((20 hs-sickle-in)) :params (:melee-range 2.0))
;; Shift+L, SP2 縛 SHIBARI (vs Ayon, ch. 336): one move, two windows on a 4.5 m line: the bind f16-19 (46 f), the slam
;; f46-49 (90, a knockdown); hit before f46 he loses the slam. Refused while the sickle is out (HS-OK)
(defmove :hs-shibari :kind :sp :clip :hs-shibari :callout "SHIBARI" :startup 16 :active 34 :recovery 26 :dmg 60
  :adv-block -14 :vol (:cap 0.3 4.5 1.1 0.35)
  :hits ((16 20 :on-hit :bind :stun 46) (46 50 :dmg 90 :on-hit :knockdown)))
;; I: the universal Breaker, drawn as 首掛け KUBIKAKE (ch. 337 / 384); allowed while out
(defmove :hs-breaker :kind :breaker :clip :hs-breaker :clip-2 :hs-kubikake :callout "KUBIKAKE")
;; O, the Kikon module 刈 KARI: aura 6 (aim 120 deg/s), no dash, the strike along a 7 m lane locked (the sickle hooks him);
;; the follow-up's generic dash drawn as a zip along the chain; cooldown 90; allowed while out
(defmove :hs-kikon :kind :kikon :clip :hs-kari-aim :clip-2 :hs-kari-o :callout "KARE, KAZESHINI" :cine hs-kikon-cine
  :startup 20 :active 2 :recovery 30 :whiff 30 :dmg 70 :adv-block -14 :track 0 :vol (:cap 0.5 7.0 1.2 1.0)
  :on-hit :knockback :kb 2.0 :cooldown 90
  :params (:aura 6 :aim 120.0 :speed 0.0 :dash-max 0 :ender-dash 0 :dash-track 0.0 :look :lane :follow-speed 14.0))

(defparameter *hs-throws* '(:hs-k1 :hs-k2s) "The moves that throw the sickle (OUT at S; their :params :throw = the line's length).")
(defparameter *hs-pulls* '(:hs-k2 :hs-k3h) "The pulls (the chain from the anchor: HS-CHAIN-SEG).")
(defparameter *hs-hooks* '(:tick hs-tick :ok hs-ok :command hs-command :hit hs-hit :struck hs-struck :reset hs-reset
                           :hash hs-hash :draw hisagi-draw :deck hs-deck))
(defparameter *hs-forms* '(:base) "Every form of his built so far (B2b adds :bankai and :bankai-bind).")

(defkit :hisagi :base
  :name "HISAGI" :body :hisagi :weapon :kazeshini :stance :hs-stance
  :intro :hs-intro :win :hs-win :intro-callout "KARE, KAZESHINI"
  :walk *hs-walk* :run *hs-run* :reishi *reishi-max* :swing-sfx :whoosh-heavy :mult *hs-mult* :taken *hs-taken*
  :push-reach *hs-push-reach*
  :commands (:q :hs-j1 :f :hs-k1 :sig :hs-kaza :sp1 :hs-raiden :sp2 :hs-shibari :breaker :hs-breaker :kikon :hs-kikon)
  ;; the IN graph (§7.2): JJJ JJK JKK KKK KKJ KJJ, K3 by route (KARI-OTOSHI after KAESHI-SEN / HIKI, HODOKI after MAKI);
  ;; then the OUT graph's J string (its J1 SEN-1H started by HS-COMMAND; a K during it is eaten)
  :strings ((:hs-j1 :q :hs-j2) (:hs-j1 :f :hs-k2s) (:hs-k1 :f :hs-k2) (:hs-k1 :q :hs-j2-1h)
            (:hs-j2 :q :hs-j3) (:hs-j2 :f :hs-k3) (:hs-k2 :f :hs-k3) (:hs-k2 :q :hs-j3)
            (:hs-j2-1h :q :hs-j3-1h) (:hs-k2s :f :hs-k3h)
            (:hs-j1-1h :q :hs-j2-1h))
  ;; ;; B2b: :awaken-form :bankai (the Bankai's two modes, §17); until then HS-TICK keeps the gauge short of EVOLUTION
  :hooks *hs-hooks*
  ;; an all-rounder at 2-6 m (§6): the throw at 3.5-6.2 m, J strings up close, the windmill against projectiles (his
  ;; :reflex), SP2 / the Breaker at mid range
  :ai (:intents (:approach 2 :pressure 2 :zone 3 :defend 1)
       :ranges (:approach (3.0 5.5) :pressure (1.2 2.2) :zone (3.5 6.0) :defend (4.0 6.0))
       :moves ((0.0 1.8 :q 5 :f 1 :breaker 1 :sp2 1)
               (1.8 3.5 :f 3 :q 1 :sp2 2 :step 1)
               (3.5 6.2 :f 5 :sp1 1 :step 1)
               (6.2 9.0 :sp1 1 :kikon 1 nil 2)
               (9.0 99.0 :kikon 1 nil 2))
       :guard 0.4 :hoho 0.3 :dash 0.6 :dash-back 0.3 :block-string 0.6 :sp-cancel-bars 1 :string-k *hs-ai-string-k*
       :kikon-range 7.0 :reflex hs-ai-reflex :opp-reflex hs-ai-opp :sp-ender hs-ai-ender :sig-hold hs-ai-sig-hold))

;;; ================================================================ pure rules (host-tested: tests/duel-rules-test.lisp)
(defun hs-throw-name-p (name) "Does move NAME throw the sickle?" (and (member name *hs-throws*) t))
(defun hs-anchor-point (x z yaw len)
  "The whiffed throw's anchor: LEN m from (X Z) along facing YAW, clamped into the arena (r *ARENA-RADIUS* - *HS-ARENA-IN*).
Values x z."
  (clamp-to-circle (+ x (* len (fwd-x yaw))) (+ z (* len (fwd-z yaw))) (- *arena-radius* *hs-arena-in*)))
(defun hs-out-next (state out-t in-move far)
  "The sickle's next state and out timer one step on, out of a throw's / pull's S frame (§7.1): IN stays; OUT counts a frame
only out of his moves (IN-MOVE NIL) and starts RETURNING at *HS-OUT-FRAMES*, or at once when FAR (his hand past
*HS-CHAIN-MAX* of the anchor, out of his moves); RETURNING stays (its own countdown: HS-TICK). Values state out-t."
  (case state
    (:out (let ((n (if in-move out-t (1+ out-t))))
            (if (and (not in-move) (or far (>= n *hs-out-frames*))) (values :ret n) (values :out n))))
    (t (values state out-t))))
(defun hs-command-for (state cmd)
  "The OUT graph (§7.2): the move name COMMAND starts from neutral in sickle STATE, :HOLD (K while RETURNING: the press
waits buffered, it throws on the arrival), or NIL (the kit's :commands entry)."
  (unless (eq state :in)
    (case cmd (:q :hs-j1-1h) (:f (if (eq state :ret) :hold :hs-modoshi)))))
(defun hs-refused-p (state cmd) "Is COMMAND refused in sickle STATE (L, SP2 while out or returning: Q4 A)?"
  (and (not (eq state :in)) (member cmd '(:sig :sp2)) t))
(defun hs-kaza-release-p (sf s top held)
  "Does the windmill (S its up frame, TOP = S + A its last held frame) leave its hold at move frame SF: up at least
*HS-KAZA-MIN* frames and L no longer HELD (else it stays up to TOP)?"
  (and (>= sf (+ s *hs-kaza-min*)) (< sf top) (not held)))
(defun hs-band (d)
  "The time-at-range probe's band of distance D (§6): :at-close < 1.8, :at-mid < 4, :at-far <= 6.5, else :at-out."
  (cond ((< d 1.8) :at-close) ((< d 4.0) :at-mid) ((<= d 6.5) :at-far) (t :at-out)))

;;; ================================================================ his state (the sim's): a component on his fighter entity
(defcomponent hss
  "Hisagi's state (HS): on his fighter entity, made on its first use, so a new match's (and PRACTICE's reset's) fighter
starts fresh; a Kikon / Soul Break reset puts the sickle IN (HS-RESET)."
  (state :in)                                 ; the sickle: :in :out :ret (§7.1)
  (anchor (make-f32 2) :type f32vec)          ; the anchor x z (a fixed world point, never moved by art; an f32vec: 0 B reads)
  (anchored nil)                              ; the current throw wrote its anchor (contact or line end)
  (out-t 0 :type fixnum) (ret-t 0 :type fixnum)   ; the out timer (frames out of his moves), the return's countdown
  (throw-t -1 :type fixnum)                   ; the tick the sickle last went out (the CPU's one roll per OUT start)
  (kaza nil)                                  ; he was in the windmill at the last tick (HS-STRUCK's counters)
  (ai-out -1 :type fixnum) (ai-modoshi nil)   ; his CPU: the OUT start it rolled for, and its pick
  (ai-threat nil)                             ; his CPU: a ranged threat seen last step (the windmill's rising edge)
  (opp-key -1 :type fixnum) (opp-go nil))     ; a CPU FACING him (on that fighter's own component): the throw start it
                                              ; rolled for and its pick (HS-AI-OPP)
(defun hs (e)
  "E's state (his HSS component, attached on the first call)."
  (or (hss e) (let ((st (make-hss))) (add-component e st) st)))

;;; ================================================================ the chain's geometry (sim points)
(defun hs-hand (e)
  "Values x y z of E's sim hand: the chain's near end (*HS-HAND-AHEAD* ahead of his feet, *HS-HAND-UP* up)."
  (let ((p (pos-of e)) (yaw (yaw-of e)))
    (values (+ (aref p 0) (* *hs-hand-ahead* (fwd-x yaw))) (+ (aref p 1) *hs-hand-up*) (+ (aref p 2) (* *hs-hand-ahead* (fwd-z yaw))))))
(defun hs-chain-seg (e)
  "The pulls' :seg-fn (kit.lisp WINDOW-TOUCHES-P, SEG-GAP): the chain from E's anchor to his hand this frame, its radius.
Values ax ay az bx by bz r."
  (let ((st (hs e)))
    (multiple-value-bind (hx hy hz) (hs-hand e)
      (values (aref (hss-anchor st) 0) (f32 *hs-anchor-up*) (aref (hss-anchor st) 1) (f32 hx) (f32 hy) (f32 hz) (f32 *hs-seg-r*)))))
(defun hs-hand-dist (e)
  "How far E's sim hand is from his anchor, on the ground."
  (let ((st (hs e)))
    (multiple-value-bind (hx hy hz) (hs-hand e)
      (declare (ignore hy))
      (hypot (- hx (aref (hss-anchor st) 0)) (- hz (aref (hss-anchor st) 1))))))
(defun hs-anchor! (e x z)
  "E's anchor := (X Z), clamped into the arena."
  (let ((st (hs e)))
    (multiple-value-bind (x z) (clamp-to-circle x z (- *arena-radius* *hs-arena-in*))
      (setf (aref (hss-anchor st) 0) (f32 x) (aref (hss-anchor st) 1) (f32 z) (hss-anchored st) t))))

;;; ================================================================ the state machine's events
(defun hs-throw-out (e)
  "A throw's S frame (NAGE / MAKI): the sickle OUT, whatever the result; its anchor still to write."
  (let ((st (hs e)))
    (setf (hss-state st) :out (hss-anchored st) nil (hss-out-t st) 0 (hss-throw-t st) *match-tick*)
    (pace e (if (eq (mv-name (fighter-move (fighter e))) :hs-k1) :throw :maki))
    (clog "~a SICKLE OUT ~a" (side-name e) (mv-name (fighter-move (fighter e))))))
(defun hs-sickle-in (e)
  "A pull's / MODOSHI's / SP1's S frame: the sickle IN."
  (let ((st (hs e)) (name (mv-name (fighter-move (fighter e)))))
    (unless (eq (hss-state st) :in)
      (pace e (case name (:hs-modoshi :modoshi) (:hs-raiden :raiden-in) (t :pull)))
      (clog "~a SICKLE IN ~a" (side-name e) name))
    (setf (hss-state st) :in (hss-out-t st) 0 (hss-ret-t st) 0)))
(defun hs-reset (e)
  "His :reset hook (combat.lisp RESET-ROUND: a Kikon / Soul Break reset): the sickle IN."
  (let ((st (hs e))) (setf (hss-state st) :in (hss-out-t st) 0 (hss-ret-t st) 0 (hss-anchored st) nil)))
(defun hs-drag (e)
  "NAGE's / HIKI's first real hit (:on-land): the chain drags the victim to *HS-DRAG-TO* m over *HS-DRAG-FRAMES* (his slide
replaced; ICHIGO-PULL-TO's rule)."
  (let* ((v (opp-of e)) (p (pos-of e)) (q (pos-of v)) (dx (- (aref p 0) (aref q 0))) (dz (- (aref p 2) (aref q 2)))
         (dist (hypot dx dz)))
    (when (> dist *hs-drag-to*)
      (set-slide v (- dist *hs-drag-to*) *hs-drag-frames* dx dz)
      (pace e :drag)
      (emit :sfx :chain-snap e))))
(defun hs-kaza-up (e) "The windmill's up frame (f6): counted." (declare (ignorable e)) (pace e :windmill))
(defun hs-kaza-tick (e)
  "The windmill, each frame: once it has been up *HS-KAZA-MIN* frames, L let go ends the hold (its recovery R 14 next);
the clip follows (a look)."
  (let* ((f (fighter e)) (mv (fighter-move f)) (sf (fighter-sf f)) (top (+ (mv-s mv) (mv-a mv))))
    (when (hs-kaza-release-p sf (mv-s mv) top (vpad-down (pilot-vpad (pilot e)) :sig))
      (setf (fighter-sf f) top)
      (play-clip e (kit-move-clip (fighter-kit f) (mv-clip mv)) :blend 2 :time (/ top 60.0)))))

;;; ================================================================ his hooks
(defun hs-command (e cmd)
  "His :command hook (kit.lisp KIT-COMMAND-MOVE): the OUT graph's J1 / K while the sickle is out (HS-COMMAND-FOR); :HOLD
for K while it returns (fighter.lisp TRY-COMMAND starts nothing, the press stays buffered: it throws on the arrival)."
  (let ((name (hs-command-for (hss-state (hs e)) cmd)))
    (cond ((eq name :hold) :hold)
          (name (find-move name)))))
(defun hs-ok (e cmd combo)
  "His :ok hook: L and SP2 refused while the sickle is out or returning (the cue; Q4 A)."
  (declare (ignore combo))
  (not (hs-refused-p (hss-state (hs e)) cmd)))
(defun hs-hit (att def res hw mv hazard ranged)
  "His :hit hook: a throw's first contact of any kind (hit, block, armour, absorb, a parry, a catch) writes the anchor at
the victim's centre (§7.1); the counters."
  (declare (ignore hw hazard ranged))
  (when (and mv res)
    (let ((st (hs att)) (name (mv-name mv)))
      (when (and (hs-throw-name-p name) (eq (fighter-move (fighter att)) mv) (not (hss-anchored st)))
        (let ((q (pos-of def))) (hs-anchor! att (aref q 0) (aref q 2)))
        (pace att (if (eq (contact-of res) :hit) :throw-hit :throw-touch)))
      (when (member name *hs-pulls*) (pace att (if (eq (contact-of res) :hit) :pull-hit :pull-touch))))))
(defun hs-struck (def att res hw mv hazard ranged)
  "His :struck hook: the windmill's counters (a ranged hit warded, a crush)."
  (declare (ignore att hw mv hazard))
  (let ((f (fighter def)))
    (when (and ranged res (hss-kaza (hs def)))
      (pace def (if (and (eq (fighter-state f) :stun) (eq (fighter-phase f) :guard-break)) :windmill-crush :windmill-block)))))
(defun hs-tick (e f g)
  "His :tick hook (every step, after the hits): the whiffed throw's anchor on its last active frame, the out timer (only
out of his moves) and the auto-retrieve, the return's arrival; the counters. ;; B2b: the awakening gauge held short."
  (let* ((st (hs e)) (mv (and (eq (fighter-state f) :move) (fighter-move f))) (sf (fighter-sf f)))
    ;; B2b: no Bankai yet: the gauge never reaches EVOLUTION, so P does nothing
    (setf (gauges-awaken g) (f32 (min (gauges-awaken g) (- *awaken-max* 1.0))))
    (when (and mv (eq (fighter-phase f) :main) (hs-throw-name-p (mv-name mv)) (eq (hss-state st) :out)
               (not (hss-anchored st)) (= sf (+ (mv-s mv) (mv-a mv) -1)))
      (let ((p (pos-of e)))
        (multiple-value-bind (x z) (hs-anchor-point (aref p 0) (aref p 2) (yaw-of e) (getf (mv-params mv) :throw))
          (hs-anchor! e x z)))
      (pace e :throw-whiff))
    (case (hss-state st)
      (:out (multiple-value-bind (s n) (hs-out-next :out (hss-out-t st) mv (and (not mv) (> (hs-hand-dist e) *hs-chain-max*)))
              (setf (hss-out-t st) n)
              (when (eq s :ret)
                (setf (hss-state st) :ret (hss-ret-t st) *hs-return-frames*)
                (pace e (if (>= n *hs-out-frames*) :auto-return :far-return))
                (clog "~a SICKLE RETURNING" (side-name e)))))
      (:ret (when (<= (decf (hss-ret-t st)) 0)
              (setf (hss-state st) :in (hss-out-t st) 0)
              (clog "~a SICKLE IN (returned)" (side-name e)))))
    (setf (hss-kaza st) (and mv (eq (mv-name mv) :hs-kaza) t))
    (when *pacing-log*
      (unless (eq (hss-state st) :in) (pace e :out-frames))
      (pace e (hs-band (fighter-dist f))))))
(defun hs-hash (e)
  "His :hash hook (debug.lisp STATE-HASH-LINE): the sickle's state, the anchor (cm), the timers."
  (let ((st (hs e)))
    (format nil "s~a ~d ~d o~d r~d" (case (hss-state st) (:in "I") (:out "O") (t "R"))
            (round (* 100 (aref (hss-anchor st) 0))) (round (* 100 (aref (hss-anchor st) 1))) (hss-out-t st) (hss-ret-t st))))

;;; ================================================================ the CPU (his kit's :ai; DUEL_HISAGI §10)
(defun hs-p (b plist) "PLIST's chance (:easy :normal :hard) at brain B's difficulty." (getf plist (brain-difficulty b) (getf plist :normal 0.0)))
(defun hs-ai-reflex (e b s d)
  "His :reflex (free): the windmill against a ranged threat (RANGED-THREAT-IN 4-24 f), one roll per threat; MODOSHI once
per OUT start (*HS-AI-MODOSHI-P*), else he waits the auto-retrieve out. A command or NIL."
  (let* ((st (hs e)) (threat (and (eq (hss-state st) :in) (ranged-threat-in e b s d 4 24)))
         (edge (and threat (not (hss-ai-threat st)))))
    (setf (hss-ai-threat st) threat)
    (cond ((and edge (kit-command-ok-p e :sig) (< (sim-rnd01) (hs-p b *hs-ai-windmill-p*)))
           (pace e :ai-windmill)
           (why b :windmill :sig))
          ((and (eq (hss-state st) :out) (not (eql (hss-ai-out st) (hss-throw-t st))))
           (setf (hss-ai-out st) (hss-throw-t st) (hss-ai-modoshi st) (< (sim-rnd01) (hs-p b *hs-ai-modoshi-p*)))
           nil)
          ((and (eq (hss-state st) :out) (hss-ai-modoshi st))
           (setf (hss-ai-modoshi st) nil)
           (pace e :ai-modoshi)
           (why b :modoshi :f)))))
(defun hs-ai-sig-hold (kit d &optional e)
  "His :sig-hold (AI-COMMAND): the windmill held *HS-AI-WINDMILL-HOLD* frames."
  (declare (ignore kit d e))
  *hs-ai-windmill-hold*)
(defun hs-ai-ender (e kit)
  "His :sp-ender (ai.lisp STRING-REFLEX, a link-3 hit): SP2 SHIBARI after RIN with the sickle in (its 4.5 m line reaches
the 2.15 m push), else SP1 TSUZURI RAIDEN (6.5 m: after a K ender's 6.45 m push), *HS-AI-SP-ENDER-P* of the time."
  (declare (ignore kit))
  (let ((b (ai-brain e)) (f (fighter e)))
    (when (and b (>= (reiatsu-bars e) 1) (< (sim-rnd01) (hs-p b *hs-ai-sp-ender-p*)))
      (let ((c (if (and (eq (mv-kind (fighter-move f)) :quick) (kit-command-ok-p e :sp2)) :sp2 :sp1)))
        (when (kit-command-ok-p e c) (pace e (if (eq c :sp2) :ai-sp2 :ai-sp1)) c)))))
(defun hs-ai-opp (e b s d)
  "His kit's :opp-reflex (a CPU facing him): his perceived NAGE / SP1 in its startup, one roll per start (*HS-AI-OPP-STEP-P*);
a yes side-Steps once the line will reach E within 0-14 f (RANGED-THREAT-IN: beyond the blade's 2.0 m)."
  (let ((mv (snap-move s)) (st (hs e)))   ; (his HSS on the CPU's own fighter: a fresh one each match)
    (when (and mv (eq (snap-state s) :move) (eq (snap-phase s) :main) (member (mv-name mv) '(:hs-k1 :hs-raiden))
               (< (snap-sf s) (mv-s mv)) (not (kit-rooted (kit-of e))))
      (unless (eql (hss-opp-key st) (snap-start s))
        (setf (hss-opp-key st) (snap-start s) (hss-opp-go st) (< (sim-rnd01) (hs-p b *hs-ai-opp-step-p*))))
      (when (and (hss-opp-go st) (ranged-threat-in e b s d 0 14))
        (setf (hss-opp-go st) nil)
        (pace (opp-of e) :opp-side-step)
        (why b :anti-throw :side-step)))))

;;; ================================================================ the gate line, probes, debug (83000-83999)
(defun hisagi-acc-line ()
  "After a gate row: a \"duel hisagi\" line per side that played him (the pacing log: throws, pulls, auto-returns, the
windmill's holds / blocks / crushes, out frames, the time-at-range bands)."
  (dolist (e (list *p1* *p2*))
    (when (and (entity-alive-p e) (eq (fighter-character (fighter e)) :hisagi))
      (log-msg "duel hisagi ~a seed ~d form ~a ~{~(~a~) ~a~^ ~}" (side-name e) *match-seed* (fighter-form (fighter e))
               (svref *pacing* (fighter-side (fighter e)))))))

(defun hisagi-probe-line (tag)
  (let ((st (hs *p1*)) (g2 (gauges *p2*)))
    (log-msg "duel probe hisagi ~a t ~d p1 ~a ~a sickle ~a anchor ~,2f ~,2f out ~d ret ~d rei ~,1f | p2 ~a r~d gg ~d | d ~,2f"
             tag *match-tick* (fighter-form (fighter *p1*)) (state-of *p1*) (hss-state st) (aref (hss-anchor st) 0) (aref (hss-anchor st) 1)
             (hss-out-t st) (hss-ret-t st) (gauges-reiatsu (gauges *p1*)) (state-of *p2*) (gauges-reishi g2)
             (round (gauges-gg g2)) (fighter-dist (fighter *p1*)))))

(defun hisagi-test (k)
  "83000+k (human P1 Hisagi, P2's CPU off unless noted, P1's Reiatsu full; a \"duel probe hisagi\" line): 0 2 m from an idle
Kenpachi; 1 6 m from him; 2 4 m from him, the sickle out (anchored 3 m ahead, the timer at 0); 3 8 m from Yamamoto, his L
wave started, the windmill started (blocked from every side); 4 5 m from Kenpachi, NAGE started (the throw); 5 the mirror,
both CPUs, 6 m apart; 6 2 m from Kenpachi, J1 started (the JKK: K K for MAKI, HODOKI); any other k the probe line only."
  (flet ((setup (c2 dist &key cpu)
           (ensure-battle :hisagi c2 :cpu cpu)
           (when (brain *p1*) (setf (brain-off (brain *p1*)) (not cpu)))
           (place *p1* *p2* dist)
           (hs-reset *p1*)
           (full-gauges! *p1*) (full-gauges! *p2*)))
    (case k
      (0 (setup :kenpachi 2.0))
      (1 (setup :kenpachi 6.0))
      (2 (setup :kenpachi 4.0)
         (let ((st (hs *p1*)) (p (pos-of *p1*)))
           (setf (hss-state st) :out (hss-out-t st) 0 (hss-throw-t st) *match-tick*)
           (multiple-value-bind (x z) (hs-anchor-point (aref p 0) (aref p 2) (yaw-of *p1*) 3.0) (hs-anchor! *p1* x z))))
      (3 (setup :yamamoto 8.0) (force-cmd *p2* :sig) (force-cmd *p1* :sig))
      (4 (setup :kenpachi 5.0) (force-cmd *p1* :f))
      (5 (setup :hisagi 6.0 :cpu t))
      (6 (setup :kenpachi 2.0) (force-cmd *p1* :q)))
    (hisagi-probe-line (format nil "test ~d" k))))

(defun hisagi-debug (c)
  "His debug commands (debug.lisp *CHAR-DEBUG*, 83000-83999, docs/duel/DUEL_GAMEPLAY.md): 83000+k HISAGI-TEST k; 83100+k /
83200+k the Shikai's damage dealt / taken x (0.5 + k / 100); 83900 the probe line."
  (cond ((< c 83100) (hisagi-test (- c 83000)))
        ((< c 83200) (setf (kit-mult (find-kit :hisagi :base)) (+ 0.5 (/ (- c 83100) 100.0))))
        ((< c 83300) (setf (kit-taken (find-kit :hisagi :base)) (+ 0.5 (/ (- c 83200) 100.0))))
        ((= c 83900) (hisagi-probe-line "probe"))
        (t (log-msg "duel hisagi: no debug command ~d" c))))
(pushnew '(83000 83999 hisagi-debug) *char-debug* :test #'equal)

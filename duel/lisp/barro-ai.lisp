;;;; barro-ai.lisp — Lille's CPU: the route CPU (docs/duel/DUEL_LILLE_V3.md §6.3, the dream-rsi cells b1a0 / b1a1 / b1a2 / b2a0, §22), the learner's
;;;; situations (§22.3) and the ASSIST AUTO COMBO's routes, with the CPU's knobs (*BR-AI-...*) (split out of barro.lisp 2026-10-21,
;;;; refactor round 2). Loads right after barro.lisp; the kit names the CPU functions as bare symbols in its :ai plist
;;;; (:reflex :sig-hold :sp-ender), LEARN-DEF-KIT's :step and the ASSIST :assist-combo, so they are late-bound. Plain CL (the host
;;;; rules test loads it after barro.lisp); no DEFUN-FAST. The debug / probe tail and the HUD registration stay in barro.lisp.
(in-package :duel)

;;; ================================================================ AI (DUEL_LILLE_V3 §6.3; the route CPU, dream-rsi b1a0, §22)
;;; His CPU: his kits' :ai keys (every chance x *BR-AI-DIFF* by difficulty: EASY <= NORMAL <= HARD, one roll per event or
;;; window, never per step), the generic bands and string reflex, and these. The policy is a set of ROUTES, each picked once
;;; at its event from his own state and the perceived opponent; the stance is never a place to wait:
;;;   confirm  an attack-state J / K link that hit -> L (:l-after-j / -k) -> the stance's string at once: the base stance J
;;;            (the gun-kata, S 10) off a J link, its K (the rifle, S 16) off a K link (BR-AI-STANCE-PLAN :combo); awakened
;;;            the turn skipped (R17's link, his CPU's own call in BR-TO-EN-LINK-TICK: BR-AI-LINK-CMD) into EN K1 / J1
;;;   string   the stance's J / K strings go on by the generic latch; at the link points one call (BR-S-CPU-CALL): the
;;;            spending L L follow-up while a special is left, SP2 at a string's end when no follow-up can be paid
;;;   charge   the specials come from the charged L: the base snipe held to level 2 / 3 by the distance (the stance's L,
;;;            BR-AI-KAMAE presses and holds L), the awakened dash held to level 2 / 3 (BR-AI-SIG-HOLD, the kit's :sig-hold:
;;;            KIN's L held is the dash's charge at the turn's end, R13); the far window (BR-AI-REFLEX) opens them
;;;   EN       the rooted stance: one plan per standing window (BR-AI-EN-PLAN: K / J in reach, else the charged dash, else
;;;            the fast Step in), never a wait
;;;   base     the stance's pick by the distance (BR-AI-STANCE-PLAN): J / K in their reach, else the snipe; his attack coming
;;;            the stance Step 飛廉脚 (iframes) and a fresh pick from 5 m out
;;;   cash     (dream-rsi b1a2) every link that hit goes into the stance (:l-after-j / -k 1.0 in the attack states: no plain
;;;            K2s / K3 bridge, the base's J the gun-kata); the base stance at the pips' cap cashes them from range
;;;            (BR-AI-CASH-PLAN: HIRENKYAKU's slide back and 萬物貫通 line instead of a snipe whose gain is lost); :charge /
;;;            :follow / :sp2 0.6 -> 0.7 (HARD x1.5: every charge, line and cash-out; NORMAL x0.3 0.18 -> 0.21)
;;;   base     (dream-rsi b2a0, combined onto round 2 b1a2's line-reader) the never-awakened base form's own plan, the
;;;            rifle's ladder: every J link that hit -> its K link (K2s) -> L -> the stance K string (the rifle swung, 46 /
;;;            46 / 66) whose L L lines spend the pips (70 a pip), never the gun-kata's 15s off a confirm (:l-after-j 0,
;;;            :string-k 1); the pips loaded from range (:charge / :far-snipe its own tables, a failed roll the line's floor,
;;;            BR-AI-SNIPE-FLOOR), spent in close (:follow / :sp2 its own tables); the range by the pips (BR-AI-LADDER:
;;;            loading the zone, full the pressure); the far snipe only in sight (BR-AI-SIGHT-P: his offset and drift
;;;            across the line small by the shot); a Hoho on a charge the line does not read answered by the charge's Step
;;;            (*BR-AI-HOHO-STEP-P*); no long neutral guard (:neutral-guard 0.1) and no stance K1 into a free man in J's
;;;            reach (:j-share 1)
(defparameter *br-ai-diff* '(:easy 0.2 :normal 0.3 :hard 1.5)
  "His CPU's chances (his kits' :ai :p values) x this by difficulty, at most 1 (the old Lille's *LB-AI-DIFF*).")
(defparameter *br-ai-every* 30 "Frames between two of his window rolls (the far snipe / dash, the burst; new 2026-10-09).")
(defparameter *br-ai-dash-reach* '(4.5 10.2)
  "The awakened dash at level 2 / 3: his CPU charges level 2 inside the first (m), level 3 inside the second (the dash's
longest 10 m + its 0.9 m volume - the 0.5 m it must still pass); farther, the fast Step first (dream-rsi b1a0; b1a1: level 2
only inside 4.5 m, 6.4 before: level 3's six cuts and three wings from mid range, the let-go covering the longer hold).")
(defparameter *br-ai-dash-min* 3.0 "Closer than this (m) his awakened L is a tap (the stance's strings reach; dream-rsi b1a0).")
(defparameter *br-ai-facing* 1.0
  "Radians: him reeling farther round than this from his facing (the dash leaves him 1.6 m behind Lille), his CPU turns before
a follow-up (dream-rsi b1a1: the generic follow-up J1 whiffed 253 of 258 times after the dash in b1a0's logs).")
(defparameter *br-ai-turn-p* '(:easy 0.2 :normal 0.3 :hard 1.0)
  "... this share of his actions by difficulty (one roll per action of his: the react roll), else the generic follow-up at once.")
(defparameter *br-ai-kikon-p* '(:easy 0.05 :normal 0.15 :hard 1.0)
  "His Kikon only on an opening (BR-AI-KIKON, dream-rsi b1a1, cell b2a0's rule): him red, perceived reeling / recovering with
the rush's aura + startup + 2 f left past the perception delay, within 11 m; this share of his actions by difficulty. Every
form's :kikon-range 0: the generic neutral / reeling rush never fires (b1a0: 253 Kikons, 54 hits, 45 openings on him).")
(defparameter *br-ai-unguard-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "His answer to a long guard up close (the generic Breaker's moment), this share of his guards by difficulty: back off to his
L's range (BR-AI-UNGUARD; dream-rsi b1a1: b1a0's guard-break Breakers hit 31 of 160 and opened 66 combos on him).")
(defparameter *br-ai-unguard-to* 5.5 "... to this many metres (the snipe's / the dash's range).")

;; pure: host-tested
(defun br-ai-chance (p difficulty) "A chance P of his kit's :ai at DIFFICULTY: x *BR-AI-DIFF*, at most 1." (min 1.0 (* p (getf *br-ai-diff* difficulty 1.0))))
(defun br-ai-p (k key difficulty)
  "Pure: the chance KEY of the kit table K (its :stance, :far-snipe) at DIFFICULTY: a difficulty table (:easy .. :normal ..
:hard ..) as it reads (dream-rsi b2a0: the base form's own tables), else a plain chance x *BR-AI-DIFF* (BR-AI-CHANCE)."
  (let ((v (getf k key 0.0)))
    (if (consp v) (getf v difficulty 0.0) (br-ai-chance v difficulty))))
(defun br-ai-snipe-level (d k)
  "The base snipe's level his CPU charges at the distance D (K: the kit's :stance): 3 from :far m (the 31 m line through
guard), else 2 (the 12 m shot)."
  (if (>= d (getf k :far 7.0)) 3 2))
(defun br-ai-dash-level (d)
  "The awakened dash's level his CPU charges at the distance D (*BR-AI-DASH-REACH*): 2, 3, or NIL (closer than
*BR-AI-DASH-MIN*: the strings; farther than level 3 reaches: the fast Step)."
  (cond ((< d *br-ai-dash-min*) nil)
        ((<= d (first *br-ai-dash-reach*)) 2)
        ((<= d (second *br-ai-dash-reach*)) 3)))
;; (dream-rsi round 2 b1a1, the line-reader refined) the line has a length: a charge is never released at a level whose line
;; cannot reach him. The failed charge roll (NORMAL x0.3: 4 L presses of 5) used to be a tap: the level-1 snipe (4 m) from
;; the far window's 6 m+, the level-1 dash (6 m) from 7-10 m, a whiff and a punish every time (round 2 b1a0's NORMAL logs).
;; The roll now decides only the level by the plan (BR-AI-SNIPE-LEVEL / -DASH-LEVEL); a failed one takes the lowest level
;; that still reaches (BR-AI-FLOOR-LEVEL): a rule, the same at every difficulty, not a chance.
(defparameter *br-ai-dash-floor* '(6.4 8.4)
  "The awakened dash's lowest reaching level by the distance (m): level 1 inside the first (its 6 m + the 0.9 m volume -
0.5 m it must still pass), level 2 inside the second (8 m + 0.9 - 0.5), else level 3 (dream-rsi round 2 b1a1).")
(defun br-ai-floor-level (d reach1 reach2)
  "Pure: the lowest charge level whose line reaches D m (REACH1 / REACH2: level 1's / level 2's reach): 1, 2 or 3."
  (cond ((<= d reach1) 1) ((<= d reach2) 2) (t 3)))
(defun br-ai-plan-level (charged lv floor)
  "Pure: the level his CPU holds a charge for: CHARGED (the :charge roll passed) the planned LV, never under FLOOR (the lowest
level that reaches him: BR-AI-FLOOR-LEVEL); else FLOOR."
  (if charged (max lv floor) floor))
(defun br-ai-snipe-floor (e d)
  "The base snipe's lowest reaching level at D m (the level-1 shot's reach on him, level 2's 12 m)."
  (br-ai-floor-level d (br-ai-reach e :br-s-l1) (+ *br-snipe-len-2* (body-hurt-r (model-body (model (opp-of e)))))))
(defun br-ai-dash-floor (d)
  "The awakened dash's lowest reaching level at D m (*BR-AI-DASH-FLOOR*)."
  (br-ai-floor-level d (first *br-ai-dash-floor*) (second *br-ai-dash-floor*)))

(defparameter *br-route-fs* 30.0
  "BR-ROUTE-J-P: the flash step under which the stance route is J's refill (the user, 2026-10-13: 「現在輔助模式變成只有閃步跟
SP 量表全滿才會使用架式 K 高傷害攻擊」: the K route is the default; 40 / the kit's :recover-fs and a spare special asked
before, the same day).")
(defparameter *br-route-bars* 1 "... and the Reiatsu bars under which (0 bars: J) ...")
(defparameter *br-route-spend* 3 "... unless this many specials are spare above the reserve (a full L L to pay: K, the spend).")
(defun br-route-j-p (fs bars spare k)
  "The stance route by his resources (the user, 2026-10-13: 「依據目前資源的多寡選擇不同的架式」; pure; K the kit's :stance,
unused now): the K route (the damage; its L L lines spend the specials) by default and always with *BR-ROUTE-SPEND*
specials SPARE above the wing reserve; the J route (its hits and L L refill flash step and Reiatsu) only when the flash
step FS is under *BR-ROUTE-FS* or the Reiatsu BARS under *BR-ROUTE-BARS*."
  (declare (ignore k))
  (and (< spare *br-route-spend*) (or (< fs *br-route-fs*) (< bars *br-route-bars*))))
(defun br-spare (e)
  "E's specials above his form's wing reserve (the kit's :stance :keep; the base form none): what the K route may spend."
  (- (brs-ammo (br e)) (getf (ai-table e :stance) :keep 0)))

(defun br-ai-stance-plan (r d jr kr fs bars k &key threat combo from-k (spare 0))
  "His CPU's base stance pick from one roll R at the distance D (JR / KR: the stance J1's / K1's reach on him; K: the kit's
:stance): his attack coming (THREAT, not in a COMBO) the Step (:step of the time); a COMBO (the stance opened off a link
that hit): the K string in its reach off a K link (FROM-K) or out of J's reach, else J (they combo: J S 10 off J's flinch,
K S 16 off K's stagger); in J's reach J when the flash step FS is under :recover-fs or the Reiatsu BARS under :recover-bars
or :j-share of the time, else K (the damage); in K's reach K; farther the snipe, :KAMAE-L (its level: BR-AI-SNIPE-LEVEL)."
  (cond ((and threat (not combo) (< r (getf k :step 0.0))) :kamae-step)
        ((and combo (<= d kr) (or from-k (> d jr))) :kamae-k)
        ((and combo (<= d jr)) :kamae-j)
        ((<= d jr) (if (or (br-route-j-p fs bars spare k) (< r (getf k :j-share 0.3)))   ; (SPARE: the resource rule)
                       :kamae-j :kamae-k))
        ((<= d kr) :kamae-k)
        (t :kamae-l)))
(defun br-ai-en-plan (r d jr kr k dashed &optional j-route)
  "His CPU's plan for one standing window of the awakened stance EN (one roll R; D the distance, JR / KR the stance J1's /
K1's reach on him; K the kit's :stance; DASHED its fast Step spent): K in its reach (in J's reach :j-share of the time J,
the top's refill), the charged dash where it reaches (BR-AI-DASH-LEVEL), else the fast Step in (NIL: spent, the window runs out back to KIN). :Q, :F, :SIG, :STEP or NIL."
  (cond ((<= d jr) (if (or j-route (< r (getf k :j-share 0.25))) :q :f))   ; (J-ROUTE: BR-ROUTE-J-P, his resources)
        ((<= d kr) :f)
        ((br-ai-dash-level d) :sig)
        ((not dashed) :step)))
(defun br-ai-burst-p (r ammo fs d k difficulty)
  "Does his awakened CPU burst into the owl (K: the kit's :burst) from one roll R: AMMO >= :wings, FS >= the burst's
*FS-BURST*, him inside :in m, :p x the DIFFICULTY?"
  (and k (>= ammo (getf k :wings 5)) (>= fs *fs-burst*) (< d (getf k :in 6.0))
       (< r (br-ai-chance (getf k :p 0.0) difficulty))))

(defun br-ai-seen (b)
  "The SNAP brain B perceives this step (BRAIN-PERCEIVE's ring at the delay; NIL before it holds one): for his ticks, which
run inside moves where the reflexes don't (the old LB-AI-SEEN)."
  (let* ((ring (brain-ring b)) (n (length ring)))
    (and (plusp n) (svref ring (mod (- (brain-head b) 1 (brain-delay b)) n)))))
(defun br-ai-seen-d (e s)
  "The distance from E to the opponent as perceived (SNAP S; NIL: the real one)."
  (if s
      (let ((p (pos-of e))) (sqrt (+ (expt (- (snap-x s) (aref p 0)) 2) (expt (- (snap-z s) (aref p 2)) 2))))
      (fighter-dist (fighter e))))
(defun br-ai-reach (e name)
  "Move NAME's whole reach on E's opponent (BR-MOVE-REACH + his body)."
  (+ (br-move-reach (find-move name)) (body-hurt-r (model-body (model (opp-of e))))))
(defun br-ai-threat-p (e s d)
  "Is his perceived move S coming at E (live, in reach + 1 m: SNAP-NEAR-P)?"
  (and s (eq (snap-state s) :move) (member (snap-kind s) '(:quick :flash :sig :sp :breaker :kikon))
       (snap-live-p s) (snap-near-p s e d 1.0)))
(defun br-ai-charge-p (e b)
  "One roll per press: does his CPU charge this L (the kit's :stance :charge x the difficulty)?"
  (< (sim-rnd01) (br-ai-p (ai-table e :stance) :charge (brain-difficulty b))))

(defparameter *br-ai-cash-p* '(:easy 0.1 :normal 0.3 :hard 1.0)
  "His base stance's cash-out (dream-rsi b1a2): the pips full (*BR-AMMO-MAX*: a snipe's gain would be lost) and SP2's bars
there, a snipe plan (him out of the melee strings' reach) becomes the stance's SP2 HIRENKYAKU (the 6 m slide back and its
萬物貫通 line, every pip spent: 50 + 40 a pip), this share of those stances by difficulty (one roll a stance). b1a1's logs: 218
level-2 snipes in 40 HARD matches ended at 3 pips, most of them at the cap already (their +2 lost).")

(defun br-ai-cash-plan (plan n cap ok r p)
  "Pure: the base stance's PLAN with N pips (CAP the most), OK (SP2 may start: its bars, him not down), one roll R against P:
:KAMAE-SP2 for a snipe plan (:KAMAE-L) at the cap, else PLAN."
  (if (and (eq plan :kamae-l) (>= n cap) ok (< r p)) :kamae-sp2 plan))

(defun br-ai-kamae (e f st b)
  "His CPU's pick in the base stance (BR-KAMAE-TICK, from f6): once a stance (one roll, BR-AI-STANCE-PLAN; a learner's read
may change it, BR-LEARN-KAMAE); the snipe's L pressed and held for its level (*BR-AI-HOLD*, BR-AI-SNIPE-LEVEL; :charge of
the time, else a tap); a Step plan clears itself so the window after it (5 m out) picks again."
  (unless (brs-k-plan st)
    (let* ((k (ai-table e :stance)) (g (gauges e)) (s (br-ai-seen b)) (d (br-ai-seen-d e s))
           (left (if (and s (snap-punishable-p s) (< (snap-left s) 99)) (snap-left-seen s b) 0))   ; (his frames left)
           (combo (or (member (mv-name (fighter-move f)) '(:br-kamae-j :br-kamae-k))
                      (>= left (+ (mv-s (find-move :br-s-j1)) 2))))
           (plan (br-ai-stance-plan (sim-rnd01) d (br-ai-reach e :br-s-j1) (br-ai-reach e :br-s-k1) (gauges-fs g)
                                    (reiatsu-bars e) k :threat (br-ai-threat-p e s d) :combo combo :spare (br-spare e)
                                    :from-k (or (eq (mv-name (fighter-move f)) :br-kamae-k)
                                                (>= left (+ (mv-s (find-move :br-s-k1)) 2))))))
      (setf plan (br-learn-kamae e b plan))
      (setf plan (br-ai-cash-plan plan (brs-ammo st) (br-ammo-cap :base)   ; (the pips full: cash them from range)
                                  (and s (not (member (snap-state s) '(:down :wakeup)))
                                       (kit-command-ok-p e :sp2 (fighter-kit f) nil
                                                         (kit-next (fighter-kit f) (mv-name (fighter-move f)) :kamae-sp2)))
                                  (sim-rnd01) (getf *br-ai-cash-p* (brain-difficulty b) 0.0)))
      (setf plan (br-ai-cash-wary plan (brs-ai-cash-read st) left))   ; (round 2 b1a2: a Hoho reader read)
      (when (eq plan :kamae-sp2)                          ; (its answer read at his next free step: BR-AI-CASH-READ)
        (setf (brs-ai-cash-t st) *match-tick* (brs-ai-cash-hp st) (+ (gauges-taken-melee g) (gauges-taken-ranged g))))
      (when (and (eq plan :kamae-step) (not (br-kamae-step-ok-p (brs-dashed st) (gauges-fs g))))
        (setf plan :kamae-l))
      (setf (brs-k-plan st) plan (brs-ai-resume st) nil)
      (when (eq plan :kamae-l)                            ; (the snipe: L held from its start, BR-KAMAE-GO's hold phase)
        (ai-press b :sig (nth (1- (br-learn-charge e b (br-ai-plan-level (br-ai-charge-p e b) (br-ai-snipe-level d k)
                                                                          (br-ai-snipe-floor e d))))
                              *br-ai-hold*)
                  :act :hold))
      (pace e (intern (format nil "AI-~a" plan) :keyword))
      (why b :kamae plan)))
  (let ((plan (brs-k-plan st)))
    (when (eq plan :kamae-step) (setf (brs-k-plan st) nil))
    plan))

(defun br-ai-sig-hold (kit d &optional e)
  "His kits' :sig-hold (ai.lisp AI-COMMAND, the ASSIST's too: the brain through AI-BRAIN): frames L is held. The base form's
L and a link's L are taps (the stance's own pick holds the snipe: BR-AI-KAMAE); awakened from neutral (KIN: the turn, then
the dash's charge at once; EN: the dash) the dash charged by the distance (BR-AI-DASH-LEVEL, *BR-AI-HOLD*; :charge of the
time), else a tap (the stance's strings in reach, the fast Step from afar)."
  (declare (ignore kit))
  (let* ((f (and e (fighter e))) (b (and e (ai-brain e))) (lv (br-ai-dash-level d)))
    (if (and f b lv (not (eq (fighter-form f) :base)) (not (eq (fighter-state f) :move)))
        (nth (1- (br-learn-charge e b (br-ai-plan-level (br-ai-charge-p e b) lv (br-ai-dash-floor d)))) *br-ai-hold*)
        1)))

(defun br-ai-link-cmd (e f b)
  "His CPU's own R17 link (BR-TO-EN-LINK-TICK, the turn off a KIN J / K link that hit: his CPU pressed L there only on a hit):
the stance's opener now, the turn skipped: K1 in its reach (cut to *BR-LINK-K-S*: it combos), J1 in J's, else the dash
(:SIG, charged by the distance). One call a turn (its first frame)."
  (when (<= (fighter-sf f) 1)
    (let* ((form (br-ranged-of (fighter-form f))) (owl (br-owl-form-p form))   ; (the openers by keyword: no string a call)
           (d (br-ai-seen-d e (br-ai-seen b))))
      (cond ((and (<= d (br-ai-reach e (if owl :br-oe-j1 :br-e-j1)))   ; (the resource rule: the J route)
                  (br-route-j-p (gauges-fs (gauges e)) (reiatsu-bars e) (br-spare e) (ai-table e :stance)))
             :q)
            ((<= d (br-ai-reach e (if owl :br-oe-k1 :br-e-k1))) :f)
            ((<= d (br-ai-reach e (if owl :br-oe-j1 :br-e-j1))) :q)
            ((br-ai-dash-level d) :sig)))))

(defparameter *br-ai-breaker-v* 0.16 "A Breaker dash's metres per frame (9-10 m/s: *BREAKER-SPEED-MIN* / -MAX), his CPU's timing.")
(defparameter *br-ai-anti-breaker* '(:easy 0.1 :normal 0.3 :hard 1.0)
  "His CPU answers a Breaker by the reach model (BR-AI-ANTI-BREAKER), this share of the Breakers by difficulty (one roll
each: its react roll; NORMAL low: his NORMAL must stay a fair game, DUEL_LILLE_V3 §22's band); his J1's 1.45 m met the generic J1 too late (the strike landed 4-5 f into it: 75 of 106 Breaker hits on
the base form, dream-rsi b1a0).")
(defun br-ai-anti-breaker (e b s d)
  "His Breaker in its aura / dash within 6 m (one roll per Breaker, BRAIN-REACT-ROLL): where it is when our K1 / J1 would be
active (its dash at *BR-AI-BREAKER-V* from where we saw it a perception delay ago) and when its strike lands (the trigger
range, then its startup): K1 when it gets there in K1's reach before the strike, else J1, else a Hoho close to the strike;
meanwhile :WAIT (the generic J1 would come late). The attack-state forms only."
  (when (and (eq (snap-kind s) :breaker) (member (snap-phase s) '(:aura :dash)) (< d 6.0)
             (< (brain-react-roll b) (getf *br-ai-anti-breaker* (brain-difficulty b) 0.0)))
    (let* ((kit (kit-of e)) (v *br-ai-breaker-v*) (dl (brain-delay b)) (trig *breaker-trigger*)
           (dash (if (eq (snap-phase s) :dash) dl (- dl *breaker-aura*)))
           (wait (max 0 (- dash)))
           (de (- d (* v (max 0 dash))))
           (strike (+ wait (/ (max 0.0 (- de trig)) v) *breaker-startup*)))
      (flet ((fits (cmd)
               (let ((mv (kit-command-move kit cmd)))
                 (and mv (kit-command-ok-p e cmd) (< (+ (mv-s mv) 1) strike)
                      (<= (max trig (- de (* v (max 0 (- (mv-s mv) wait))))) (+ (mv-reach mv) 0.3))))))
        (cond ((fits :f) (why b :anti-breaker :f))
              ((fits :q) (why b :anti-breaker :q))
              ((and (<= strike 13) (hoho-ready-p e)) (why b :anti-breaker :hoho))
              ((> strike 13) :wait))))))

(defun br-ai-stance-punish (e b s d f form)
  "Free, him recovering or reeling as perceived with time for the stance's opener (the base stance up in 6 f + its J1, the
awakened turn 12 f + EN's J1; :punish of the time on his react roll, one per action of his) and in its reach: L, the stance
(its pick then sees the frames left: J, K when they fit, BR-AI-KAMAE; EN's plan, BR-AI-EN) instead of a plain J1: the punish
a signature string (dream-rsi b1a0)."
  (let ((k (ai-table e :stance)))
    (when (and (member (fighter-state f) '(:idle :run :guard)) (zerop (fighter-lock f)) (getf k :punish)
               (snap-punishable-p s) (< (snap-left s) 99) (not (br-ranged-form-p form)))
      (let* ((base (eq form :base)) (j1 (cond (base :br-s-j1) ((br-owl-form-p (br-ranged-of form)) :br-oe-j1) (t :br-e-j1)))
             (jr (br-ai-reach e j1))
             (lead (+ (if base *br-kamae-up* *br-to-en-f*) (mv-s (find-move j1)) 2)))
        (when (and (>= (snap-left-seen s b) lead) (<= d jr) (kit-command-ok-p e :sig)
                   (< (brain-react-roll b) (br-ai-p k :punish (brain-difficulty b))))
          (pace e :ai-stance-punish) (why b :stance-punish :sig))))))

(defun br-ai-en (e b s d f st)
  "The awakened stance EN, free: one plan per standing window (its epoch: the tick its standing clock started, BRS-EN-T),
BR-AI-EN-PLAN, pressed at once (the window lasts *BR-EN-HOLD* f); his attack coming: NIL (the generic guard)."
  (let ((epoch (- *match-tick* (brs-en-t st))))
    (unless (or (= epoch (brs-ai-t st)) (br-ai-threat-p e s d) (member (snap-state s) '(:down :wakeup :hoho))
                (and (not (br-ai-facing-p e s))   ; (the dash goes where he faces: wait for the turn, round 2 b1a0)
                     (> d (br-ai-reach e (if (br-owl-form-p (fighter-form f)) :br-oe-k1 :br-e-k1)))))
      (setf (brs-ai-t st) epoch)
      (let* ((owl (br-owl-form-p (fighter-form f)))
             (plan (br-ai-en-plan (sim-rnd01) d (br-ai-reach e (if owl :br-oe-j1 :br-e-j1))
                                  (br-ai-reach e (if owl :br-oe-k1 :br-e-k1)) (ai-table e :stance)
                                  (brs-dashed st)
                                  (br-route-j-p (gauges-fs (gauges e)) (reiatsu-bars e) (br-spare e) (ai-table e :stance)))))
        (pace e (intern (format nil "AI-EN-~a" plan) :keyword))
        (case plan
          ((nil) nil)
          (:step (ai-press b :step 2 :act :dash) (setf (brain-dash b) 1f0 (brain-dash-to b) 0f0)
                 (why b :en-step :pressed))
          (t (why b :en plan)))))))

(defparameter *br-ai-step-in-p* '(:easy 0.03 :normal 0.08 :hard 1.0)
  "His answer to the opponent's Step in (BR-AI-STEP-IN, dream-rsi b1a1): this share of his Steps by difficulty (one roll a
Step), his J1 timed to land past the Step's iframes, before its J cancel's hit (b1a0 / v1 logs: the opponents' STEP-IN ->
STEP-J was the most common opener on his idle attack-state forms).")
(defparameter *br-ai-step-in-v* 0.08 "... the Step perceived closing on him faster than this (m / f; a Step's hop is 0.21) ...")
(defparameter *br-ai-step-in-late* 18 "... and our J1's hit landing by his Step's frame this (his J cancel f12 + a J1's startup).")

(defun br-ai-closing (b s d e)
  "His perceived speed toward E (m / f, > 0 coming): the SNAP S and the one before it in brain B's ring."
  (let* ((ring (brain-ring b)) (n (length ring))
         (s1 (and (plusp n) (svref ring (mod (- (brain-head b) 2 (brain-delay b)) n)))) (p (pos-of e)))
    (if (or (null s1) (null s) (< d 0.01))
        0.0
        (+ (* (- (snap-x s) (snap-x s1)) (/ (- (aref p 0) (snap-x s)) d))
           (* (- (snap-z s) (snap-z s1)) (/ (- (aref p 2) (snap-z s)) d))))))

(defun br-ai-step-in-plan (sf delay js closing d reach)
  "Pure: his Step perceived at its frame SF (a perception DELAY ago), closing at CLOSING m / f, D metres off; our J1's startup
JS and its REACH on him. Our J1 pressed now hits at his Step's frame SF + DELAY + JS: :GO when that is past the iframes
(*STEP-IFRAMES*) and by *BR-AI-STEP-IN-LATE* with him then in reach (his hop: CLOSING a frame up to its f12); :WAIT while
it would land in his iframes; else NIL."
  (let ((k (+ sf delay js)))
    (cond ((< closing *br-ai-step-in-v*) nil)
          ((> k *br-ai-step-in-late*) nil)
          ((<= (- d (* closing (max 0 (- (min k *step-j-cancel*) (min sf *step-j-cancel*))))) reach)
           (if (<= k (second *step-iframes*)) :wait :go)))))

(defun br-ai-step-in (e b s d f st)
  "His opponent's Step in (perceived): one roll a Step (*BR-AI-STEP-IN-P*); his J1 (the form's :q) timed by
BR-AI-STEP-IN-PLAN: it meets him as he lands, before his Step's J (the R17 link / the stance from that J's hit). :Q, :WAIT
or NIL. The attack-state forms, free."
  (when (and (eq (snap-state s) :step) (member (fighter-state f) '(:idle :run :guard)) (kit-command-ok-p e :q))
    (let ((key (- *match-tick* (brain-delay b) (snap-sf s))))
      (unless (= key (brs-ai-step-key st))
        (setf (brs-ai-step-key st) key
              (brs-ai-step-go st) (< (sim-rnd01) (getf *br-ai-step-in-p* (brain-difficulty b) 0.0))))
      (when (brs-ai-step-go st)
        (let* ((q (kit-command-move (kit-of e) :q))
               (plan (br-ai-step-in-plan (snap-sf s) (brain-delay b) (mv-s q) (br-ai-closing b s d e) d
                                         (+ (br-move-reach q) (body-hurt-r (model-body (model (opp-of e))))))))
          (case plan
            (:go (setf (brs-ai-step-go st) nil) (pace e :ai-step-in) (why b :step-in :q))
            (:wait (why b :step-in-wait :wait))))))))

(defparameter *br-ai-exit-p* '(:easy 0.05 :normal 0.15 :hard 1.0)
  "His exit from the awakened stance (BR-AI-EXIT, dream-rsi b1a1): the first free step back in KIN after EN (a string's end
pushed him out to ~2.8 m: the opponents' J1 found him standing there, b1a0 / v2 logs), this share of the exits by
difficulty (one roll an exit): back into the stance while the wing armour covers the turn, else a dash back.")

(defun br-ai-exit-plan (d wings cost dash)
  "Pure: his exit at D metres with WINGS (COST: the armour's price), DASH the charged dash's level there (BR-AI-DASH-LEVEL):
:SIG (L held: the armoured turn into the charged dash) when the armour holds and the dash reaches; else :BACK (a dash back to *BR-AI-UNGUARD-TO*, the dash's range) when he is nearer; else NIL. (Measured: the
re-entry into EN's K1 / J1 from 2.8 m was punished, v3.)"
  (cond ((and (>= wings cost) dash) :sig)
        ((< d *br-ai-unguard-to*) :back)))

(defun br-ai-exit (e b s d f st)
  "The first free step in KIN after the stance EN (BRS-AI-FORM): one roll (*BR-AI-EXIT-P*), BR-AI-EXIT-PLAN; not while his
attack is on him (the guard), nor on a downed opponent. :SIG, :PRESSED or NIL."
  (when (and (not (member (snap-state s) '(:down :wakeup))) (not (br-ai-threat-p e s d))
             (< (sim-rnd01) (getf *br-ai-exit-p* (brain-difficulty b) 0.0)))
    (let ((plan (br-ai-exit-plan d (brs-ammo st) (br-armor-cost (fighter-form f))
                                 (and (br-ai-facing-p e s) (br-ai-dash-level d)))))   ; (the dash where he faces: round 2 b1a0)
      (pace e (if plan (intern (format nil "AI-EXIT-~a" plan) :keyword) :ai-exit-none))
      (case plan
        (:sig (why b :exit :sig))
        (:back (ai-dash b -1.0 *br-ai-unguard-to*) (why b :exit-back :pressed))))))

(defparameter *br-ai-kite-p* '(:easy 0.01 :normal 0.03 :hard 0.8)
  "His kite (BR-AI-KITE, dream-rsi b1a1 after cell b2a0's ward): free in an attack-state form inside the opponent's
first-strike envelope (BR-AI-ENVELOPE), him free, one roll a *BR-AI-KITE-EVERY* window: a dash back to the envelope +
*BR-AI-KITE-OUT* (v4 logs: Kenpachi's FIRST-STRIKE J1 opened him 37 times on an idle KIN in 12 matches, ~350 a combo).")
(defparameter *br-ai-kite-every* 24 "Frames between two of his kite rolls.")
(defparameter *br-ai-kite-out* 2.0 "... out to his envelope + this many metres (the dash's range: the far-dash window picks it).")

(defun br-ai-envelope (e b s d)
  "His first-strike envelope (m): his form's J1 reach + its lunge (at most 0.8 m) + 0.5 m + his perceived closing speed x
15 f (his J1 and his reaction; cell b2a0's model)."
  (let ((q (kit-command-move (kit-of (opp-of e)) :q)))
    (+ (if q (+ (mv-reach q) (min 0.8 (mv-slide q))) 1.6) 0.5 (* 15 (max 0.0 (br-ai-closing b s d e))))))

(defparameter *br-ai-snipe-min* 6.0
  ;; (round 2 b1a2: the far window opens the stance from :far-snipe :in 4.5 again; this stays the line's own range, where
  ;;  his back-offs stop, BR-AI-BACK-TO)
  "The base snipe starts from no nearer (m): the charge move's reach (*BR-S-NEAR* 4) + the CPUs' threat margin
(*AI-THREAT-MARGIN* 1.5) + 0.5: inside it a CPU's Hoho / guard roll answers the charge (the far window's :in 4.5 before).")
(defparameter *br-ai-snipe-back* 0.5
  "The base form backs off (the kite, the unguard) to the far snipe's range + this (m): *BR-AI-SNIPE-MIN* + 0.5 = 6.5 m (round 2
b1a1: b1a0 moved the far snipe out to 6 m but its kite still stopped at his envelope + 2 m, ~5-5.7 m, and the unguard at
5.5 m: the base form backed off to where its snipe never starts).")
(defun br-ai-back-to (form to)
  "Pure: the distance (m) his CPU backs off to in FORM, TO the attack state's own: the base form's no nearer than the far
snipe's range (*BR-AI-SNIPE-MIN* + *BR-AI-SNIPE-BACK*); KIN keeps TO (the dash's range)."
  (if (eq form :base) (max to (+ *br-ai-snipe-min* *br-ai-snipe-back*)) to))

(defun br-ai-kite (e b s d f st)
  "Free in an attack-state form, him free (idle, walking, running, guarding) inside his envelope: one roll a window
(*BR-AI-KITE-P*), a dash back out of it to the dash's / the snipe's range. :PRESSED or NIL."
  (when (and (member (fighter-state f) '(:idle :run)) (zerop (brain-press-left b))
             (member (snap-state s) '(:idle :run :guard))
             (>= (- *match-tick* (brs-ai-kite st)) *br-ai-kite-every*)
             (<= d (br-ai-envelope e b s d)))
    (setf (brs-ai-kite st) *match-tick*)
    (when (< (sim-rnd01) (getf *br-ai-kite-p* (brain-difficulty b) 0.0))
      (ai-dash b -1.0 (br-ai-back-to (fighter-form f) (+ (br-ai-envelope e b s d) *br-ai-kite-out*)))
      (pace e :ai-kite)
      (why b :kite :pressed))))

(defparameter *br-ai-let-go* '(12 20)
  "His CPU holding a charge (BR-AI-CHARGE-TICK, dream-rsi b1a1): his attack (or his run in) perceived on him lets L go at
once, but a base snipe held this many frames or more short of level 2 (*BR-W-L-LEVELS*' first) holds on into level 2 (its
S 8 lands no later than level 1's S 16 from there, and harder: cell b2a0's finding); the dash lets go at any level (v5
logs: 41 + 49 openings in the charges' hold, 90 of ~800 snipes Perfect-Hoho'd or hit while held).")

(defparameter *br-ai-let-go-p* '(:easy 0.1 :normal 0.3 :hard 1.0)
  "... this share of his charges by difficulty (one roll a charge: its start tick, *MATCH-TICK* - FIGHTER-HOLD).")

(defun br-ai-let-go-p (held snipe threat)
  "Pure: let a charge HELD frames go now, his THREAT perceived? SNIPE: the base snipe (held into level 2 from
*BR-AI-LET-GO*'s first to its second)."
  (and threat (or (not snipe) (not (<= (first *br-ai-let-go*) held (1- (second *br-ai-let-go*)))))))

;;; ---------------------------------------------------------------- the line (dream-rsi round 2, cell b1a0)
;;; R18 froze the charged L's aim at its start (the snipe and the dash go where he faces). Round 2's baseline still released
;;; every charge at its planned hold, wherever the opponent had walked: in its HARD logs 25 % of the dashes left with him
;;; > 1.2 m off the line (1 % hit), and the base snipe started inside the CPUs' threat envelope (the charge move's 4 m reach +
;;; the generic 1.5 m margin: a Hoho on it puts him 1.6 m BEHIND the rooted stance; 153 openings, 30 k damage, in 60 matches,
;;; mostly the generic PUNISH J1 on the whiffed shot's recovery). Here a charge is a held threat: released the frame the
;;; predicted line meets him (BR-AI-LINE-CALL), at the highest level that still lands; the snipe never sits inside his
;;; envelope (the stance Step out, its iframes, and the charge goes on re-aimed: BR-CHARGE-STEP-GO).
(defparameter *br-ai-line-p* '(:easy 0.2 :normal 0.5 :hard 1.0)
  "His charges released by the line (BR-AI-LINE-CALL), this share of them by difficulty (one roll a charge); the rest at
the planned hold (the old rule).")
(defparameter *br-ai-line-margin* 0.1
  "Metres taken off a charged L's half-width on him (its volume's radius + his body's hurt radius) when his CPU reads the line.")
(defparameter *br-ai-line-k* 6 "Steps of the perceived ring his lateral speed is measured over (BR-AI-LINE-OF).")

(defun br-ai-line-of (e b s &optional (k *br-ai-line-k*))
  "His perceived feet against E's facing line (the frozen aim of a charge): values PERP (signed m off it), ALONG (m ahead of
E) and VPERP (his speed across it, signed m / f, over K steps of brain B's ring; 0 before the ring holds them)."
  (let* ((p (pos-of e)) (yaw (yaw-of e)) (fx (fwd-x yaw)) (fz (fwd-z yaw))
         (dx (- (snap-x s) (aref p 0))) (dz (- (snap-z s) (aref p 2)))
         (ring (brain-ring b)) (n (length ring))
         (s1 (and (< (+ k 1 (brain-delay b)) n) (svref ring (mod (- (brain-head b) 1 k (brain-delay b)) n)))))
    (values (- (* dx fz) (* dz fx)) (+ (* dx fx) (* dz fz))
            (if s1 (/ (- (* (- (snap-x s) (snap-x s1)) fz) (* (- (snap-z s) (snap-z s1)) fx)) k) 0.0))))

(defun br-ai-line-call (lv target perp vperp along to-hit width lo reach next-f next-reach)
  "Pure: his CPU's call on a charge this hold frame (LV the level reached, TARGET the planned one): him PERP m off the frozen
line, crossing it at VPERP m / f, ALONG m ahead; the shot / dash meets him TO-HIT frames after a release, WIDTH its
half-width on him, LO .. REACH its length now, NEXT-F held frames to the next level whose length is NEXT-REACH. :LOST (him
behind its start: a Hoho, a cross-up), :FIRE (the predicted line on him at a level >= 2 and nothing better to wait for: the
target reached, or the next level would find him off it) or :HOLD (level 1, or the line off him: he may walk back onto it)."
  (flet ((on (f r) (and (<= (abs (+ perp (* vperp f))) width) (<= lo along r))))
    (cond ((< along lo) :lost)
          ((< lv 2) :hold)
          ((>= lv target) (if (on to-hit reach) :fire :hold))
          ((and (on to-hit reach) (not (on (+ to-hit next-f) next-reach))) :fire)
          (t :hold))))

(defun br-ai-envelope-p (d closing delay)
  "Pure: is he (D m off, CLOSING m / f, seen DELAY frames ago) inside the CPUs' threat envelope of the base snipe's charge
(*BR-S-NEAR* + *AI-THREAT-MARGIN*): a Hoho / guard roll answers it there."
  (< (- d (* (max 0.0 closing) delay)) (+ *br-s-near* *ai-threat-margin*)))

(defparameter *br-ai-face-max* 0.35
  "Radians: his CPU starts a charge (the snipe's stance, KIN's turn into the dash, EN's dash) only facing him within this: the
charge never turns (R18) and the idle turn (*FACE-RATE*) puts him on his line within a few frames (round 2's baseline
dashed away from him off a dash through him: 25 of 1 300 dash charges began with him behind).")
(defun br-ai-facing-p (e s)
  "Does E face his perceived feet (SNAP S) within *BR-AI-FACE-MAX*?"
  (<= (abs (angle-wrap (- (face-yaw-to e (snap-x s) (snap-z s)) (yaw-of e)))) *br-ai-face-max*))

(defparameter *br-ai-hoho-step-p* '(:easy 0.1 :normal 0.4 :hard 1.0)
  "His answer to a Hoho on a charge the line does not read (BR-AI-CHARGE-TICK, dream-rsi b2a0; round 2 b0a0's piece): his
Hoho perceived (he reappears behind the rooted charge: the shot would go forward into nothing, his PUNISH after it), the
charge's own Step (R18: iframes, 5 m away, the charge kept and re-aimed onto him at its end), this share of those charges
by difficulty (one roll a charge). The line's charges (*BR-AI-LINE-P*) Step out of a Hoho by their own rule.")

(defparameter *br-ai-step-fire-min* 2.5
  "His charge back from its Step (R18: the sim re-aimed it on him at the Step's f9) is let go at once at level 2 / 3 when he
is perceived at least this far (m); nearer (he chased the Step down) the line / the envelope decide as before (b1a2's logs:
the re-aimed shot hit 630 of 848 from 6.5-10 m, its whiffs sat under 2 m).")
(defun br-ai-charge-tick (e f b mv)
  "His CPU's charge (the snipe, the dash; their hold phase, BR-S-TICK), one roll a charge (keyed on its start tick): the
let-go (*BR-AI-LET-GO-P*: his attack perceived in reach + 1 m, or him running / stepping in within 3 m: L let go at the level
reached, BR-AI-LET-GO-P) and the line (*BR-AI-LINE-P*: L held up to the cap, released by BR-AI-LINE-CALL; the snipe inside
his envelope or with him behind it: the charge's Step out, re-aimed, once a stance; refused, the shot). The charge back
from that Step (the sim re-aimed it on him) goes at once at level 2 / 3 from *BR-AI-STEP-FIRE-MIN* m (round 2 b1a2). A
charge the line does not read Steps out of his Hoho (*BR-AI-HOHO-STEP-P*, one roll a charge; b2a0)."
  (let* ((s (br-ai-seen b)) (d (br-ai-seen-d e s)) (st (br e)) (dif (brain-difficulty b)))
    (let ((key (- *match-tick* (fighter-hold f))))
      (when (and (/= key (brs-ai-charge-key st)) (brs-ai-resume st))   ; (the charge back after its Step: the same rolls)
        (setf (brs-ai-resume st) nil (brs-ai-charge-key st) key (brs-ai-stepped st) t))
      (unless (= key (brs-ai-charge-key st))
        (let ((lv (if (and (eq (brain-press b) :sig) (plusp (brain-press-left b)))
                      (br-w-l-level (+ (fighter-hold f) (brain-press-left b)))
                      1)))
          (setf (brs-ai-charge-key st) key (brs-ai-stepped st) nil
                (brs-ai-let-go st) (< (sim-rnd01) (getf *br-ai-let-go-p* dif 0.0))
                (brs-ai-line st) (if (and (>= lv 2) (< (sim-rnd01) (getf *br-ai-line-p* dif 0.0))) lv 0))
          (when (plusp (brs-ai-line st))   ; (L held to the cap: the line ends the press)
            (setf (brain-press-left b) (max (brain-press-left b) (- *br-w-l-hold* (fighter-hold f))))))))
    (when (and s (eq (brain-press b) :sig) (plusp (brain-press-left b)))
      (let* ((snipe (getf (mv-params mv) :charged)) (held (fighter-hold f)) (lv (br-w-l-level held))
             (closing (br-ai-closing b s d e)))
        (flet ((fire (why) (setf (brain-press-left b) 0) (pace e why) t)
               (step-out () (and (br-charge-step-go e f st mv) (setf (brs-ai-resume st) t) (pace e :ai-line-step) t)))
          (cond ((and (brs-ai-let-go st)
                      (br-ai-let-go-p held snipe (or (br-ai-threat-p e s d)
                                                     (and (member (snap-state s) '(:run :step)) (< d 3.0) (> closing 0.05)))))
                 (fire :ai-let-go))
                ((and (brs-ai-stepped st) (>= lv 2) (not (eq (snap-state s) :hoho)) (>= d *br-ai-step-fire-min*))
                 (fire :ai-step-fire))
                ((and (zerop (brs-ai-line st)) (eq (snap-state s) :hoho) (/= (brs-ai-charge-key st) (brs-ai-hoho-key st)))
                 ;; (b2a0: a charge the line does not read meets his Hoho with its Step, one roll a charge; back re-aimed,
                 ;;  the step-fire above; the line's charges have their own Step out below)
                 (setf (brs-ai-hoho-key st) (brs-ai-charge-key st))
                 (when (and (< (sim-rnd01) (getf *br-ai-hoho-step-p* dif 0.0)) (br-charge-step-go e f st mv))
                   (incf (brain-press-left b) (1+ *br-kamae-dash-f*))   ; (L held through the Step: the charge's level kept)
                   (setf (brs-ai-resume st) t)
                   (pace e :ai-hoho-step)))
                ((zerop (brs-ai-line st)))
                ((and snipe (or (eq (snap-state s) :hoho) (br-ai-envelope-p d closing (brain-delay b))))
                 ;; (inside his envelope: on the line at level 2+ the shot; level 2 near (b2a0's hold-on), held; else out)
                 (multiple-value-bind (perp along vperp) (br-ai-line-of e b s)
                   (let ((call (br-ai-line-call lv lv perp vperp along (+ (brain-delay b) 9)
                                                (- (+ 0.25 (body-hurt-r (model-body (model (opp-of e))))) *br-ai-line-margin*)
                                                0.6 (+ (if (= lv 3) *br-x-len* *br-snipe-len-2*) 0.3) 0 0.0)))
                     (cond ((and (not (eq (snap-state s) :hoho)) (eq call :fire)) (fire :ai-env-fire))
                           ((and (not (eq (snap-state s) :hoho)) (< lv 2) (>= held (first *br-ai-let-go*))))
                           ((step-out))
                           ((eq (snap-state s) :hoho))   ; (round 2 b1a1: no shot into his Hoho: he reappears, then the line)
                           ((>= lv 2) (fire :ai-env-shot))))))
                (t
                 (multiple-value-bind (perp along vperp) (br-ai-line-of e b s)
                   (let* ((hurt (body-hurt-r (model-body (model (opp-of e)))))
                          (lvls *br-w-l-levels*) (target (brs-ai-line st))
                          (next-f (cond ((< held (first lvls)) (- (first lvls) held)) ((< held (second lvls)) (- (second lvls) held)) (t 0)))
                          (call (if snipe
                                    (br-ai-line-call lv target perp vperp along (+ (brain-delay b) 9)
                                                     (- (+ 0.25 hurt) *br-ai-line-margin*) 0.6
                                                     (+ (if (= lv 3) *br-x-len* *br-snipe-len-2*) hurt) next-f *br-x-len*)
                                    (br-ai-line-call lv target perp vperp along (+ (brain-delay b) (mv-s mv) 5)
                                                     (- (+ *br-w-dash-r* hurt) *br-ai-line-margin*) 0.0
                                                     (+ (nth (1- lv) *br-w-l-dash-max*) *br-w-dash-reach*)
                                                     next-f (+ (nth (min 2 lv) *br-w-l-dash-max*) *br-w-dash-reach*)))))
                     (case call
                       (:fire (fire :ai-line-fire))
                       (:lost (or (step-out) (fire :ai-line-lost)))))))))))))

(defun br-ai-turn-wait (e b s)
  "He reels (stun / air) farther round than *BR-AI-FACING* from Lille's facing (after the dash through him): :WAIT (the
fighter turns to him) instead of the generic follow-up that whiffs, *BR-AI-TURN-P* of his actions (the react roll)."
  (when (and (member (snap-state s) '(:stun :air))
             (> (abs (angle-wrap (- (face-yaw-to e (snap-x s) (snap-z s)) (yaw-of e)))) *br-ai-facing*)
             (< (brain-react-roll b) (getf *br-ai-turn-p* (brain-difficulty b) 1.0)))
    (pace e :ai-turn)
    (why b :turn :wait)))

(defun br-ai-kikon (e b s d)
  "His Kikon on an opening only: him red, perceived reeling / recovering with the rush's aura + startup + 2 frames left, within
11 m, not when the hits would finish him; *BR-AI-KIKON-P* of his actions (the react roll). :KIKON or NIL."
  (let ((mv (kit-command-move (kit-of e) :kikon)))
    (when (and mv (kikon-ready-p e) (snap-punishable-p s) (< (snap-left s) 99) (<= d 11.0)
               (>= (snap-left-seen s b) (+ (or (rush-param mv :aura) 0) (mv-s mv) 2))
               (kit-command-ok-p e :kikon) (not (ai-sb-finish-p e))
               (< (brain-react-roll b) (getf *br-ai-kikon-p* (brain-difficulty b) 0.0)))
      (pace e :ai-kikon)
      (why b :kikon-punish :kikon))))

;;; ---------------------------------------------------------------- dream-rsi round 2, cell b1a2 (refines b1a1, the line-reader)
(defparameter *br-ai-keep-burst* '(:easy 0.2 :normal 0.5 :hard 1.0)
  "The burst kept for the owl (BR-AI-KEEP-BURST: round 1 b0a2's piece, round 2 b0a1's measure, taken here by b1a2): in the
base form, at a string's end that no stance call cashed (no SP2 / L L line), this share by difficulty skips the generic SP2
cancel / CHAIN REVERSE (ORANGE): every burst drains the whole flash step, and only an awakened burst becomes the owl, his best
form (b1a1's 40-seed HARD logs: the base's ORANGE chain J1 0.26 % of his damage, plain).")
(defun br-ai-keep-burst (e kit)
  "The base form's :sp-ender (ai.lisp STRING-REFLEX, a string link that hit with no link after it, its first step): his own
CPU only (BR-TICK-BRAIN: NIL for a human the ASSIST plays and for the gate's masher), one roll (*BR-AI-KEEP-BURST* by the
deciding brain's difficulty, AI-BRAIN): :KEEP-BURST (a command no form has: nothing pressed, the generic SP2 cancel / ORANGE
after it skipped for this hit), else NIL (the generic ender)."
  (declare (ignore kit))
  (let ((b (and (br-tick-brain e) (ai-brain e))))
    (when (and b (< (sim-rnd01) (getf *br-ai-keep-burst* (brain-difficulty b) 0.0)))
      (pace e :ai-keep-burst)
      :keep-burst)))

(defparameter *br-ai-cash-wary-p* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "His read of a Hoho reader (BR-AI-CASH-READ): a cash-out the opponent made him pay for (his damage taken between the
cash-out and his next free step) counts, this share of those events by difficulty (one roll an event). b1a1's 40-seed HARD
logs: HIRENKYAKU from neutral was Perfect-Hoho'd 112 of 205 times by Ichigo and 92 of 229 by Rukia (their timed Hohos), never
by the other three: 204 counters, 23 k of his damage taken (4 %), four of his six lost matches against Ichigo.")
(defparameter *br-ai-cash-commit* 20
  "Read once (BR-AI-CASH-READ), his cash-out from neutral waits for an opponent perceived committed this many frames or more
(a move's recovery, a stagger: HIRENKYAKU's line comes at f20, a Hoho from f8 to f20 is perfect); else the stance's snipe.")
(defun br-ai-cash-read (e b st)
  "His free step after a cash-out (BRS-AI-CASH-T): his damage taken since it started (his own gauges) means the opponent
answered it (a Perfect Hoho's counter, a punish): one roll (*BR-AI-CASH-WARY-P*), a read (BRS-AI-CASH-READ). Always NIL (it
only remembers)."
  (when (>= (brs-ai-cash-t st) 0)
    (let ((g (gauges e)))
      (when (> (+ (gauges-taken-melee g) (gauges-taken-ranged g)) (brs-ai-cash-hp st))
        (when (< (sim-rnd01) (getf *br-ai-cash-wary-p* (brain-difficulty b) 0.0))
          (incf (brs-ai-cash-read st))
          (pace e :ai-cash-read)))
      (setf (brs-ai-cash-t st) -1)))
  nil)
(defun br-ai-cash-wary (plan read left)
  "Pure: the base stance's PLAN after the cash-out's (BR-AI-CASH-PLAN) with READ cash-outs answered this match and the
opponent perceived committed LEFT frames: a read cash-out (:KAMAE-SP2) waits for LEFT >= *BR-AI-CASH-COMMIT*, else the
snipe (:KAMAE-L); any other PLAN as it is."
  (if (and (eq plan :kamae-sp2) (plusp read) (< left *br-ai-cash-commit*)) :kamae-l plan))

(defun br-ai-unguard (e b s d f)
  "A long guard of his up close (the generic Breaker's moment: guarding *AI-GUARD-BREAK-HOLD* f within
*AI-GUARD-BREAK-RANGE*): once per guard (its generic Breaker roll taken, BRAIN-BREAK-KEY), *BR-AI-UNGUARD-P* by difficulty,
a dash back to *BR-AI-UNGUARD-TO* (his L's range: the charge, not a Breaker he Hohos). :PRESSED or NIL."
  (when (and (eq (snap-state s) :guard) (>= (snap-guard-t s) *ai-guard-break-hold*) (< d *ai-guard-break-range*)
             (/= (brain-break-key b) (snap-start s)) (member (fighter-state f) '(:idle :run :guard))
             (< (brain-react-roll b) (getf *br-ai-unguard-p* (brain-difficulty b) 0.0)))
    (setf (brain-break-key b) (snap-start s))
    (ai-dash b -1.0 (br-ai-back-to (fighter-form f) *br-ai-unguard-to*))
    (pace e :ai-unguard)
    (why b :unguard :pressed)))

;;; ---------------------------------------------------------------- dream-rsi round 2, cell b2a0 (the rifleman's ladder)
(defparameter *br-ai-sight-gap* 0.6
  "The base form's sight (BR-AI-SIGHT-P, dream-rsi b2a0): the far snipe's window opens only when the shot's predicted miss
(his offset from where Lille faces + his perceived drift across the line until the level-2 shot lands) is at most this (m:
the line's 0.25 + his body's ~0.4 - a margin); else it waits for a still / approaching target and the stance's turn (the
window kept).")
(defparameter *br-ai-sight-f* 38
  "... the frames from the window to the level-2 shot's hit (the stance's 6 + L held 24 + its startup 8), + the perception delay.")
(defparameter *br-ai-sight-k* 4
  "... his drift measured over this many steps of the perceived ring (BR-AI-LINE-OF; b2a0's own BR-AI-LATERAL folded into the
line-reader's: the same cross-line speed, the facing gate keeps the two within a few %).")

(defun br-ai-sight-p (d dyaw lateral frames)
  "Pure: does a snipe started now find him (D m away, DYAW rad off Lille's facing, drifting LATERAL m / f across the line as
perceived, the shot FRAMES away)? His predicted miss D sin|DYAW| + |LATERAL| FRAMES within *BR-AI-SIGHT-GAP*."
  (<= (+ (* d (sin (min 1.5 (abs dyaw)))) (* (abs lateral) frames)) *br-ai-sight-gap*))

(defparameter *br-ai-ladder-p* '(:easy 0.3 :normal 0.6 :hard 1.0)
  "The base form's ladder (BR-AI-LADDER, dream-rsi b2a0): at each intent re-pick (*AI-REPICK* f, after any respect) this
share by difficulty picks the intent by his pips (BR-AI-LADDER-INTENT) instead of the kit's weights (one roll a re-pick).")

(defun br-ai-ladder-intent (pips cap)
  "Pure: the base form's intent for PIPS of CAP: loading (short of the cap) :ZONE, the snipe's range (6-12 m: the charged
shot fills them, +2 / +3 even on a block); full :PRESSURE, in for the confirm whose rifle string's L L lines spend them
(70 a pip, the base's best damage a pip buys)."
  (if (>= pips cap) :pressure :zone))

(defun br-ai-ladder (e b st f)
  "The base form's range by its pips (his own CPU's neutral, free: idle / run): when ai.lisp's intent is due for its re-pick,
one roll (*BR-AI-LADDER-P*) sets it by BR-AI-LADDER-INTENT for the next *AI-REPICK* frames. NIL (the reflex goes on)."
  (declare (ignore e))
  (when (and (member (fighter-state f) '(:idle :run)) (<= (brain-intent-t b) 1))
    (when (< (sim-rnd01) (getf *br-ai-ladder-p* (brain-difficulty b) 0.0))
      (setf (brain-intent b) (br-ai-ladder-intent (brs-ammo st) (br-ammo-cap :base))
            (brain-intent-t b) *ai-repick*)))
  nil)

(defun br-ai-reflex (e b s d)
  "Every form's :reflex (ai.lisp AI-REFLEX, free states; NIL when there is nothing to do): the awakened stance EN's plan per
window (BR-AI-EN); else one roll a window (*BR-AI-EVERY* f) with the opponent not attacking: the base form the far snipe
(the stance from :far-snipe :in m, its pick the charged L), awakened the burst into the owl (BR-AI-BURST-P) or the
charged dash from afar (:far-dash, the dash's reach; its :p a table by difficulty)."
  (let* ((f (fighter e)) (st (br e)) (form (fighter-form f)) (g (gauges e)) (dif (brain-difficulty b))
         (was (brs-ai-form st)))
    (setf (brs-ai-form st) form)
    (br-ai-cash-read e b st)
    (when (eq form :base) (br-ai-ladder e b st f))   ; (dream-rsi b2a0: the base form's range by its pips; never answers)
    (cond ((br-ranged-form-p form)
           (and (member (fighter-state f) '(:idle :run :guard)) (zerop (fighter-lock f))
                (or (br-ai-kikon e b s d) (br-ai-en e b s d f st))))
          ((br-ai-turn-wait e b s))
          ((and (br-ranged-form-p was) (br-melee-form-p form) (member (fighter-state f) '(:idle :run :guard))
                (zerop (fighter-lock f)) (br-ai-exit e b s d f st)))
          ((br-ai-anti-breaker e b s d))
          ((br-ai-step-in e b s d f st))
          ((br-ai-kikon e b s d))
          ((br-ai-unguard e b s d f))
          ((br-ai-kite e b s d f st))
          ((br-ai-stance-punish e b s d f form))
          ((and (member (fighter-state f) '(:idle :run :guard)) (zerop (fighter-lock f))
                (>= (- *match-tick* (brs-ai-t st)) *br-ai-every*) (not (br-ai-threat-p e s d))
                (br-ai-facing-p e s))   ; (a charge goes where he faces: the window waits for the idle turn, round 2 b1a0)
           (setf (brs-ai-t st) *match-tick*)
           (cond ((eq form :base)
                  (let ((k (ai-table e :far-snipe)))
                    (when (and k (>= d (getf k :in 5.0)))
                      (if (not (br-ai-sight-p d (angle-wrap (- (face-yaw-to e (snap-x s) (snap-z s)) (yaw-of e)))
                                              (nth-value 2 (br-ai-line-of e b s *br-ai-sight-k*))
                                              (+ *br-ai-sight-f* (brain-delay b))))
                          (setf (brs-ai-t st) -999)   ; (b2a0: not in sight, the window waits unspent)
                          (when (< (sim-rnd01) (br-ai-p k :p dif))
                            (pace e :ai-far-snipe) (why b :far-snipe :sig))))))
                 ((and (br-jilliel-form-p form)
                       (br-ai-burst-p (sim-rnd01) (brs-ammo st) (gauges-fs g) d (ai-table e :burst) dif) (burst-ok-p e))
                  (pace e :ai-burst) (why b :owl :burst))
                 (t (let ((k (ai-table e :far-dash)))
                      (when (and k (br-ai-dash-level d) (>= d (getf k :in 3.4)) (< (sim-rnd01) (getf (getf k :p) dif 0.0)))
                        (pace e :ai-far-dash) (why b :far-dash :sig)))))))))

;;; ================================================================ AI: the learning CPU's situations (DUEL_LILLE_V3 §6.3, §22.3)
;;; Only a learner runs this (a CPU facing a human). :shot = his base stance's K K on a free opponent: the human's answer
;;; (:guard :hoho :step :attack :back :take). Read at the stance's pick (one roll): a guard -> K K stays (its 萬物貫通 drain);
;;; a Step / backing off -> J J (quicker); a Hoho / an attack -> the stance Step, else L L.
;;; :charge (the integration of the dream-rsi CPU, §22.3: 「學玩家習慣」) = his charged L (the base snipe, the awakened dash)
;;; entering its charge on a free opponent: the human's answer, a walk off the line (> *LEARN-BACK* m sideways) a Step too.
;;; Read when his CPU picks the charge's level (one roll a charge): a guard -> level 3 (the 31 m line through guard, the dash's
;;; six cuts); a Hoho / an attack -> a tap (nothing held for him to answer); a Step / backing off -> the charge as planned, and
;;; its Step (R18) re-aims once he is seen stepping (BR-AI-RESTEP).
(defparameter *br-learn-diff* '(:easy 0.5 :normal 1.0 :hard 1.5) "His learner's read chance x this by difficulty.")
(defparameter *br-learn-episode* 24 "Frames the :shot situation waits for his answer, + the perception delay.")

(defun br-learn-answer (hprev hs new away)
  "His answer starting this step (perceived HPREV -> HS, NEW: a new move of his, AWAY: metres he moved away since the onset):
:HOHO, :STEP, :ATTACK, :GUARD, :BACK, or NIL."
  (cond ((and (eq hs :hoho) (not (eq hprev :hoho))) :hoho)
        ((and (eq hs :step) (not (eq hprev :step))) :step)
        ((and (eq hs :move) (or (not (eq hprev :move)) new)) :attack)
        ((and (eq hs :guard) (not (eq hprev :guard))) :guard)
        ((> away *learn-back*) :back)))
(defun br-learn-kamae-plan (read plan step-ok)
  "The stance's pick instead of PLAN for his predicted answer READ to K K: a Step / backing off J J, a Hoho / an attack the
stance Step (STEP-OK) else L L; else PLAN."
  (case read
    ((:step :back) :kamae-j)
    ((:hoho :attack) (if step-ok :kamae-step :kamae-l))
    (t plan)))

(defun br-learn-charge-plan (read lv)
  "Pure: the charge's level instead of LV for his predicted answer READ to the charged L, and whether its Step re-aims:
values level, restep."
  (case read
    (:guard (values 3 nil))
    ((:hoho :attack) (values 1 nil))
    ((:step :back) (values lv (> lv 1)))
    (t (values lv nil))))
(defun br-learn-charge (e b lv)
  "His CPU's charge level LV (1 a tap) as a learner's read of :charge leaves it (one roll a charge, only for a charge: LV > 1);
BRS-AI-RESTEP set for it. The level."
  (let ((l (br-learn-l b)) (st (br e)))
    (setf (brs-ai-restep st) nil)
    (if (and l (> lv 1))
        (let ((r (learn-kit-read l :charge (float (getf *br-learn-diff* (brain-difficulty b) 1.0) 1.0))))
          (multiple-value-bind (lv2 restep) (br-learn-charge-plan r lv)
            (setf (brs-ai-restep st) restep)
            (when r (learn-count-read e l r) (pace e (intern (format nil "READ-CHARGE-~a" r) :keyword))
                  (clog "~a read charge ~a -> level ~d~@[ restep~]" (side-name e) r lv2 restep))
            lv2))
        lv)))
(defun br-ai-restep (e f st b mv)
  "His charge on a learner's read of a Step (BRS-AI-RESTEP): him seen stepping -> the charge's Step (BR-CHARGE-STEP-GO,
re-aimed at its end); once a charge."
  (let ((s (br-ai-seen b)))
    (when (and s (eq (snap-state s) :step))
      (setf (brs-ai-restep st) nil)
      (when (br-charge-step-go e f st mv) (pace e :ai-restep)))))

(defstruct (brl (:conc-name brl-))
  "His learner's own state within a match (LRN-KDATA)."
  (own-mv nil) (ox 0f0 :type single-float) (oz 0f0 :type single-float) (ux 0f0 :type single-float) (uz 0f0 :type single-float)
  (len 0 :type fixnum))
(defun br-learn-state (l) (or (lrn-kdata l) (setf (lrn-kdata l) (make-brl))))
(defun br-learn-l (b) "Brain B's learner when it reads his situations (LRN-KIT), else NIL." (let ((l (and b (brain-learn b)))) (and l (lrn-kit l) l)))

(defun br-learn-step (e b s d l)
  "His learner's step (LEARN-DEF-KIT's :step): the :shot onset (his stance's K1 starting on a free opponent), the :charge
onset (his charged L entering its charge on a free opponent), their answer (BR-LEARN-ANSWER; :charge's walk off the line a
Step; at its end :TAKE, or :GUARD held through)."
  (declare (ignore b d))
  (let* ((k (br-learn-state l)) (f (fighter e)) (mv (current-move f))
         (hs (snap-state s)) (hprev (lrn-hstate l)) (new (/= (snap-start s) (lrn-hstart l)))
         (sit (and mv (not (eq mv (brl-own-mv k))) (< (lrn-ksit l) 0) (member hs '(:idle :run :guard))
                   (cond ((member (mv-name mv) '(:br-s-k1 :br-e-k1 :br-oe-k1)) :shot)
                         ((and (member (mv-name mv) '(:br-s-l1 :br-e-l1 :br-oe-l1)) (eq (fighter-phase f) :hold)
                               (not (and (brl-own-mv k) (member (mv-name (brl-own-mv k)) '(:br-k-dash :br-w-charge-step)))))
                          :charge)))))   ; (a charge resumed after its Step: the same episode's, not a new one)
    (when sit
      (let* ((dx (- (snap-x s) (aref (pos-of e) 0))) (dz (- (snap-z s) (aref (pos-of e) 2))) (m (max 1e-3 (hypot dx dz))))
        (setf (brl-ox k) (snap-x s) (brl-oz k) (snap-z s) (brl-ux k) (f32 (/ dx m)) (brl-uz k) (f32 (/ dz m))
              (brl-len k) (+ *br-learn-episode* (brain-delay (brain e)))))
      (learn-kit-open l sit))
    (setf (brl-own-mv k) mv)
    (when (>= (lrn-ksit l) 0)
      (let* ((end (>= (incf (lrn-kep-t l)) (brl-len k)))
             (ox (- (snap-x s) (brl-ox k))) (oz (- (snap-z s) (brl-oz k)))
             (away (+ (* ox (brl-ux k)) (* oz (brl-uz k))))
             (side (abs (- (* ox (brl-uz k)) (* oz (brl-ux k))))))   ; (metres off his line)
        (cond ((member hs '(:stun :air :down :wakeup)) (learn-kit-close l :take))
              (t (let ((ans (or (br-learn-answer hprev hs new away)
                                (and (learn-kit-open-p l :charge) (> side *learn-back*) :step))))
                   (cond (ans (learn-kit-close l ans))
                         (end (learn-kit-close l (if (member hs '(:guard :guard-hit)) :guard :take)))))))))))

(defun br-learn-kamae (e b plan)
  "The base stance's PLAN (his CPU, once a stance): K K on a free opponent is read (one roll: :shot) and answered
(BR-LEARN-KAMAE-PLAN); anything else, or no learner, as planned."
  (let ((l (br-learn-l b)))
    (if (and l (eq plan :kamae-k) (not (member (state-of (opp-of e)) '(:stun :air))))
        (let* ((r (learn-kit-read l :shot (float (getf *br-learn-diff* (brain-difficulty b) 1.0) 1.0)))
               (p (br-learn-kamae-plan r plan (br-kamae-step-ok-p (brs-dashed (br e)) (gauges-fs (gauges e))))))
          (unless (eq p plan) (learn-count-read e l p) (pace e p) (clog "~a read ~a" (side-name e) p))
          p)
        plan)))

(learn-def-kit :barro :situations #(:shot :charge) :actions #(:guard :hoho :step :attack :back :take) :step 'br-learn-step)

;;; ================================================================ ASSIST AUTO COMBO's routes (DUEL_LILLE_V3 §6.3)
;;; "You press J, the CPU chooses": the routes press his buttons as a human's, the AUTO tag.
;;;   attack state  his J in a J / K link that hit, on its land frame: a J link -> its K link; a K link -> L (the stance:
;;;                 the base's at f4, the awakened turn)
;;;   stance        his J while the stance is up (the base stance's window, the awakened stance free): K (K K, whose J J
;;;                 the generic latch takes on his next J); his J kept (the J route) when his resources ask for the
;;;                 refill (BR-ROUTE-J-P: low flash step / Reiatsu, no special spare above the reserve; the user 2026-10-13)
;;;   R17's turn    his J in KIN's turn into the stance off a link (:br-to-en-l): K (the stance K1 at once, it combos)
;;;   the strings   his J in a stance string's segment once its hits are over, the segment having touched him: L (its L L
;;;                 follow-up, a spending one only with a special to pay it), else at a string's last segment that hit
;;;                 with 2 bars Shift+L (the charge-less SP2, every special) (§22.3: the new rules' 「資源循環」)
(defstruct (bras (:conc-name bras-))
  (b nil) (mv nil) (sf -1 :type fixnum) (j nil) (done nil))
(defvar *br-as* (vector (make-bras) (make-bras)) "Per side: the ASSIST routes' state (BR-ASSIST-COMBO).")

(defun br-as-track (f b vp)
  "The route state of F's side for brain B, its move instance brought up to date, his J this step noted."
  (let* ((side (fighter-side f)) (a (svref *br-as* side)) (mv (current-move f)))
    (unless (eq (bras-b a) b) (setf a (make-bras :b b) (svref *br-as* side) a))
    (cond ((null mv) (setf (bras-mv a) nil (bras-j a) nil (bras-done a) nil))
          ((or (not (eq mv (bras-mv a))) (< (fighter-sf f) (bras-sf a)))
           (setf (bras-mv a) mv (bras-j a) nil (bras-done a) nil)))
    (when mv
      (setf (bras-sf a) (fighter-sf f))
      (when (or (vpad-command-pressed-p vp :quick nil) (eq (fighter-queued f) :q)) (setf (bras-j a) t)))
    a))

(defun br-assist-combo (e f b s d vp)
  "His kits' :assist-combo (assist.lisp AUTO-ROUTE): the routes above. A command, :NONE (the route holds the step) or NIL
(the generic AUTO COMBO)."
  (declare (ignore s d))
  (let* ((a (br-as-track f b vp)) (mv (bras-mv a)) (kit (fighter-kit f)) (form (fighter-form f))
         (j-route (br-route-j-p (gauges-fs (gauges e)) (reiatsu-bars e) (br-spare e) (ai-table e :stance))))   ; (his resources)
    (cond ((and mv (eq (mv-name mv) :br-to-en-l))
           (cond ((bras-done a) (vpad-consume! vp :quick) :none)
                 ((and (bras-j a) j-route) (setf (bras-done a) t) (pace e :as-link-j) nil)   ; (his J: the stance J1)
                 ((bras-j a) (setf (bras-done a) t) (vpad-consume! vp :quick) (pace e :as-link-k) :f)))
          ((and mv (br-stance-move-p mv) (eq (fighter-phase f) :main))
           (let* ((name (mv-name mv)) (next (kit-next kit name :lchain)) (sp2 (kit-next kit name :sp2c))
                  (end (and sp2 (getf (mv-params mv) :end))))
             (cond ((not (or next end)) nil)
                   ((bras-done a) (vpad-consume! vp :quick) :none)
                   ((and end (bras-j a) (eq (fighter-contact f) :hit) (kikon-ready-p e) (not (ai-sb-finish-p e)))   ; (R20: the
                    (setf (bras-done a) t) (vpad-consume! vp :quick) (pace e :as-o-ender) :kikon)                  ;  O ender, red)
                   ((not (and (bras-j a) (fighter-contact f) (>= (fighter-sf f) (+ (mv-s mv) (mv-a mv))))) nil)
                   ((and next (or (not (getf (mv-params next) :spend)) (br-follow-ok-p (brs-ammo (br e)))))
                    (setf (bras-done a) t) (vpad-consume! vp :quick) (pace e :as-follow) :sig)
                   ((and end (eq (fighter-contact f) :hit) (>= (reiatsu-bars e) 2))
                    (setf (bras-done a) t) (vpad-consume! vp :quick) (pace e :as-sp2) :sp2))))
          ((and mv (member (mv-name mv) '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re)))
           (cond ((bras-done a) (unless j-route (vpad-consume! vp :quick)) (if j-route nil :none))
                 ((and (>= (1+ (fighter-sf f)) *br-kamae-up*) (bras-j a) j-route)   ; (his J: the stance J1, the refill)
                  (setf (bras-done a) t) (pace e :as-stance-j) nil)
                 ((and (>= (1+ (fighter-sf f)) *br-kamae-up*) (bras-j a))
                  (setf (bras-done a) t) (vpad-consume! vp :quick) (pace e :as-stance-k) :f)))
          ((and (null mv) (br-ranged-form-p form) (member (fighter-state f) '(:idle :run :guard))
                (vpad-command-pressed-p vp :quick nil))
           (if j-route (progn (pace e :as-stance-j) nil) (progn (pace e :as-stance-k) :f)))
          ((and mv (member (mv-kind mv) '(:quick :flash)) (not (br-stance-move-p mv)))
           (let ((name (mv-name mv)) (l (kit-l-link kit (mv-name mv))))
             (cond ((bras-done a) (vpad-consume! vp :quick) (when (eq (fighter-queued f) :q) (setf (fighter-queued f) nil)) :none)
                   ((not (and (bras-j a) (eq (fighter-contact f) :hit) (= (fighter-sf f) (fighter-land-sf f)))) nil)
                   ((and (kit-j-link-p kit name) (kit-next kit name :f)) (setf (bras-done a) t) (pace e :as-k-link) :f)
                   ((and l (kit-k-link-p kit name) (kit-command-ok-p e :sig kit nil l))
                    (setf (bras-done a) t) (pace e :as-stance) :sig)
                   ((kit-next kit name :f) (setf (bras-done a) t) (pace e :as-k-link) :f)))))))

;; every form of his names it (assist.lisp AUTO-ROUTE reads the key off the form's kit)
(dolist (form *br-forms*)
  (let ((k (find-kit :barro form)))
    (unless (getf (kit-ai k) :assist-combo)
      (setf (kit-ai k) (list* :assist-combo 'br-assist-combo (kit-ai k))))))


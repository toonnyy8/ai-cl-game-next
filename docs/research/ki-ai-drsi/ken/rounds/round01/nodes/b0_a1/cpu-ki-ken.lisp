;;;; cpu-ki-ken.lisp — the KI matchup style CPU: Kenpachi against Ichigo (docs/duel/DUEL_MATCHUP_AI.md §4–§5).
;;;; KEN-KI-STYLE runs before the generic core CPU (core-ai.lisp) on every step he is free to press and plays the four styles the user
;;;; chose (§4), each by its own chance per event, EASY <= NORMAL <= HARD:
;;;;   封印肉搏  sealed: the read on her move start (J1 races her NS, the pointer 3 tame catches her hit, NS1a from beyond J reach) and the
;;;;            meaty J1 on her wake-up (K1); its discipline (cell b0_a0): a neutral move only where it reaches (else walk or Hoho in),
;;;;            a whiffed NS stops instead of running on, a Hoho through what he cannot beat (her 4-5 m lunge, KESSA's clones), a
;;;;            Kikon held only on a red Ichigo, and the AS read in his planned strings; the flash-step budget (cell b0_a1): the Hoho in
;;;;            only with a second Hoho in reserve, and a back Step through her lunge / clones when no Hoho is open;
;;;;   解放攀升  the Shikai: awaken, build L to 3 on purpose (the lunge from 3-5 m; the pointer's own AS, never the burst that resets L),
;;;;            then J1-J4..J6 + SP, the special AS (D37-D40);
;;;;   卍解爆發  at L3: J1-J7 + SP, the Bankai (D41), the chase (Hoho in, the meaty J1, D43), J1-J4 + SP cash-outs, and the way back,
;;;;            J1-J5 + SP (CHIGIRI / TATE-GOTO, E6 / E25), before his Reishi runs low: the generic CPU forces the AS at J3 and never leaves;
;;;;   破月牙    her Getsuga route at 3.4-7 m (round 1's b3_a0, grafted by b0_a1): where his NS reaches her (the Shikai's lunge, KYORAN's)
;;;;            it lands on her charge (F15, F18); else mostly Hoho late through the wave (F17) and J1 at once as he lands (:chase), now
;;;;            and then close in (Hoho / dash, then an NS on her charge: F11-F14) or cut the wave with the Shikai / Bankai J1 (F28, F32).
;;;;            A J that lands on her route turns to the AS (AS beats NS; a J only cancels her charge).
;;;; Every roll is made once per event (her move start, her knockdown, her Getsuga route, his form stay, L3 reached, a neutral decision
;;;; the generic CPU would make), never per step. She is read only through the perceived SNAP S and distance D (the brain's delay).
;;;; Trial names: docs/research/ki-ai/kenpachi/{trials.lisp,catalogue.md}.
(in-package :duel)

;;; ---------------------------------------------------------------- the knobs (the dream-rsi search tunes only these)
(defparameter *kk-brawl-p* '(:easy 0.0 :normal 0.1 :hard 0.6)
  "封印肉搏's read: sealed and free, her NA / NS perceived starting within *KK-READ-RANGE*: answer it (one roll per her move start). The
tame at pointer 3 when her hit falls in its catch (frames 2-28, F7-F9); J1 when his J1 lands before her hit (it cancels her NS: the
generic CPU then turns to the AS, F2); NS1a at pointer 1 beyond J reach (F3). 2026-11-06, mine (DUEL_MATCHUP_AI §4).")
(defparameter *kk-read-range* 3.1 "封印肉搏's read: the farthest she is answered from (m): the sealed NS1a's 1.9 m and its 1.2 m slide.")
(defparameter *kk-reach-p* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "封印肉搏's discipline (also the Shikai; a Bankai always): per approach (one roll at its first neutral decision inside the generic CPU's
attack zone, its range + 0.6 m; KK-PICK) start only a move that reaches her: J1 within its reach + slide, the pointer's NS within its own (never the sealed pointer 3 tame from
neutral: it reaches nothing), else walk in and decide again soon. Her style punishes a move started beyond his reach (her *IKS-HIS-REACH*:
sealed J 2.7, NS 3.65): 34 of her ~110 style actions in four HARD matches were such punishes. Her perceived speed away (KEN-CLOSING,
never her speed in) shrinks the reach by the frames to the hit. New 2026-11-06, cell b0_a0.")
(defparameter *kk-reach-margin* 0.5
  "封印肉搏's discipline: the reach + slide less this (m) is the farthest a neutral move starts from (she backs off during its startup;
the perceived distance is 8 frames old at HARD). 0.15 -> 0.5 (20 seeds a seat, paired: score 0.470 -> 0.513, HARD 12 -> 18 of 40; 0.8:
0.410). Sealed NS1a from 2.6 m, J1 from 1.9 m; the Shikai J1 2.7 m, its lunge 5.1 m. 2026-11-06, cell b0_a0.")
(defparameter *kk-reach-retry* 3 "封印肉搏's discipline: frames to the next decision after a walk-in step (re-check as soon as he is in reach).")
(defparameter *kk-ns-stop-p* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "封印肉搏's discipline in his own NS (KK-NS-WHIFF): per NS segment, its next segment waits for its contact and a whiff stops the route
(the generic CPU runs a whiffed NS1a on into b and c, which her style punishes at 3.7-3.8 m). The latch takes the press up to the
segment's end (CORE-LATCH-STEP), so a landed one still goes on. New 2026-11-06, cell b0_a0.")
(defparameter *kk-dodge-p* '(:easy 0.0 :normal 0.1 :hard 0.8)
  "封印肉搏's read, its other answer: her NA / NS perceived starting where his tame / J1 / NS1a cannot beat it (beyond *KK-READ-RANGE*:
her NS3a lunge from 4-5 m, S18 + a 2.4 m slide; the Shikai and the Bankai always) but her move can reach him: Hoho through it (one roll
per her move start). Hoho: invulnerable frames 1-14, behind her on frame 6; a perfect one (her hit within 12 frames) counters 60 and
locks her 40 frames: 14 of 20 dodges in one HARD match were perfect. New 2026-11-06, cell b0_a0.")
(defparameter *kk-step-p* '(:easy 0.0 :normal 0.05 :hard 0.9)
  "封印肉搏's dodge without a Hoho: where *KK-DODGE-P*'s Hoho would answer her move (her 4-5 m lunge, KESSA's clones, any move of hers
that reaches him beyond the brawl answers) but no Hoho is open (it needs 100 of his 300 flash-step, which refills at 9 a second, and
60 frames since the last), a back Step instead (one roll per her move start): free, invulnerable frames 3-9, 2.5 m back. In the
parent's logs (b0_a0, 10 HARD matches a seat) most of her lunges and clone strikes that won an exchange found him with no Hoho
open. New 2026-11-06, cell b0_a1.")
(defparameter *kk-step-lead* 7
  "The back Step is pressed when her perceived frames to her hit are at most this (her hit then falls in the Step's invulnerable
frames 3-9 while the hop carries him out of the lunge's reach).")
(defparameter *kk-step-max* 5.0
  "封印肉搏's back Step only within this distance (m): from farther the 2.5 m hop puts him in her Getsuga band (7.5 m on) for nothing (in
v1's logs a quarter of the Steps came at 6-7 m, against her later NS segments). 2026-11-06, cell b0_a1.")
(defparameter *kk-clone-strike* 15
  "KESSA's NS3 a-c: the frame its clone strikes (the clone appears on f8, strikes 7 frames on), for the back Step's timing (the move's
own startup is 18).")
(defparameter *kk-hin-fs* 200.0
  "封印肉搏's Hoho in only with at least this much flash-step (a Hoho costs 100 of 300, refilled at 9 a second): one Hoho stays in
reserve for the dodge. The parent spent 111 Hohos in 10 HARD matches on walking-distance hops (3.0 m), and the dodge then found no Hoho
open. 0 (any) -> 200, 2026-11-06, cell b0_a1.")
(defparameter *kk-dodge-lead* 9 "封印肉搏's dodge: the Hoho is pressed when her perceived frames to her first active one are at most this.")
(defparameter *kk-dodge-reach* 0.5 "封印肉搏's dodge: her move is answered within its reach + slide + this (m).")
(defparameter *kk-kikon-red-p* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "Per SP he would hold into a Kikon while she is not red (KK-KIKON-RULE): tap it instead. One match (KI seed 1, HARD) held 11 such
Kikons; her style cancelled all 11 (the SP's knockdown lost with it). Red, the Kikon cannot be cancelled and is kept. Her red bar is read
as CAI-SP itself reads it (GAUGES-RED-P, a visible fact). Ablation, 20 seeds a seat paired: without it 0.419 (HARD 10 of 40), with it
0.513 (18 of 40). New 2026-11-06, cell b0_a0.")
(defparameter *kk-hoho-in-p* '(:easy 0.0 :normal 0.05 :hard 0.8)
  "封印肉搏's discipline, sealed or in a Bankai: per approach (KK-PICK's, one roll; one Hoho an approach) out of his reach within
*KK-HOHO-IN-MAX*: Hoho in (he reappears 1.6 m behind her on frame 6, his J1 / NS1a then reach) instead of walking in. Her hover backs
off from a walk-in (3.7-4.2 m sealed) and punishes the move he starts at its edge. New 2026-11-06, cell b0_a0.")
(defparameter *kk-hoho-in-max* 4.6 "封印肉搏's Hoho in: the farthest (m) he Hohos in from (her hover band is 3.7-4.2 m sealed).")
(defparameter *kk-clone-reach* 7.0
  "封印肉搏's dodge: her KESSA NS3 segments (no hit of their own; a clone appears on f8 and strikes on f15, where his J1 / NS1a on her
cannot stop it: the brawl's answers are skipped for them) are Hohoed through within this distance (m).")
(defparameter *kk-as-read-p* '(:easy 1.0 :normal 1.0 :hard 1.0)
  "In a planned string (KK-MOVE: the climb, L3's J4-J7, the Bankai's), a link that lands or cancels while she is seen in an NS turns to
the SP at once, as the generic CPU's CAI-MOVE-STEP always does (one roll per link, the move's own BRAIN-R-TURN). v0's plans pressed the
next J into her NS / SA. A located v0 bug, found independently by round 1's b1_a0 (*KK-TURN-P*) and b2_a0 (*KK-AS-READ-P*).")
(defparameter *kk-meaty-p* '(:easy 0.0 :normal 0.1 :hard 0.7)
  "封印肉搏 / 卍解爆發's chase: per knockdown of hers (one roll as she goes down): walk (or Hoho, from beyond *KK-CHASE-HOHO* m) in and
press J1 to land on her first free frame (K1: 64 a loop; D43 after the Bankai entry).")
(defparameter *kk-meaty-lead* 0
  "The meaty J1 is pressed when her perceived frames to her first free one are J1's startup + this (0: J1's first active frame on it;
K1 gap 0, K2 12 frames late she acts, D47 too early whiffs on her invulnerable wake-up).")
(defparameter *kk-meaty-near* 1.4 "The meaty chase walks in to this distance (m) and waits (the sealed J reaches 1.8 m).")
(defparameter *kk-chase-hoho* 4.5 "The meaty chase Hohos in from beyond this (m) while she is still down (the Bankai entry leaves her 6.13 m away).")
(defparameter *kk-awaken-p* '(:easy 0.0 :normal 0.0 :hard 0.1)
  "Per neutral decision, sealed with the awakening gauge full: awaken into the Shikai, on top of the generic CPU's own *CAI-AWAKEN-P* 0.02
(a failed roll leaves the decision to it). Higher: less sealed brawl, more Shikai / Bankai time.")
(defparameter *kk-climb-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "解放攀升: per Shikai stay (one roll as it starts: the awakening, the return from a Bankai): build L to 3 on purpose. His strings end in
the pointer's own AS (pointer 1: J1 J2 + SP, AS1; pointer 2: J1-J3 + SP, AS2; both raise L), never the bursts that reset it (pointer 1
J3 + SP, pointer 2 J1 / J2 / the SA + SP). Else the generic CPU plays the Shikai. HARD 0.8 -> 1.0 with *KK-BANKAI-P* (2026-11-06, cell
b0_a0; as round 1's b1_a0 / b2_a0).")
(defparameter *kk-lunge-p* '(:easy 0.0 :normal 0.1 :hard 0.5)
  "解放攀升: climbing under pointer 1, per neutral decision at *KK-LUNGE-BAND*: the NS1 lunge (2.6 m + a 3.0 m slide, D2; a landed lunge
is a combo with an NS: L +1, D12).")
(defparameter *kk-lunge-band* '(3.0 5.2) "解放攀升: the distances (m) he lunges from (the lunge hits from 5 m, D2; F15).")
(defparameter *kk-l3-range* 2.8 "解放攀升 / 卍解爆發 at L3 with a plan: a neutral decision within this (m) starts the J string (the Shikai J 2.4 m + 0.8 slide).")
(defparameter *kk-bankai-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "卍解爆發: per time he reaches L3 (one roll): his strings run J1-J7 + SP into the Bankai (D41 / D42). Else, climbing, J1-J*KK-SPECIAL-N*
+ SP into the special AS. HARD 0.6 -> 1.0 with *KK-CLIMB-P* 1.0 (20 seeds a seat, paired: bankai 0.52 -> 0.72, score 0.700 -> 0.708;
an L3 without the Bankai is a 卍解爆發 failure; J1-J7 lands J4-J6 for 解放攀升 on the way). 2026-11-06, cell b0_a0 (as b1_a0 / b2_a0).")
(defparameter *kk-special-n* 4
  "解放攀升 at L3: the J press the special AS's SP follows, 4-6 (J4: DAISHARIN 166 / INSEKI-GIRI 174, D37 / D39; J6: 190 / 198, D38 /
D40; a longer string drops more often).")
(defparameter *kk-bk-cashouts* 1
  "卍解爆發: the J1-J4 + SP cash-outs (KYORAN / ZANKAI AS, 4 segments: 240 / 319 to her, 160 of his own Reishi, E5 / E24) before the string
that leaves the Bankai, J1-J5 + SP (CHIGIRI 247 / TATE-GOTO 288, E6 / E25).")
(defparameter *kk-bk-floor* 0.5
  "卍解爆發: under this fraction of his Reishi his next Bankai string leaves (J5 + SP) and he starts no Bankai NS (40 Reishi a segment, the
Bankai's only cost; no other way out).")
(defparameter *kk-bk-ns-p* '(:easy 0.0 :normal 0.1 :hard 0.25)
  "卍解爆發: per neutral decision in a Bankai within *KK-BK-NS-RANGE* and Reishi over *KK-BK-FLOOR* + *KK-BK-NS-SPARE*: the NS route
(KYORAN's lunge from 4 m, E10; ZANKAI's NS a-d SA J2-J4 AS 461, L6) rather than J1.")
(defparameter *kk-bk-ns-spare* 0.15 "卍解爆發: the Reishi fraction over the floor a Bankai NS route needs (4 segments: 160 of 1300).")
(defparameter *kk-bk-ns-range* 3.8 "卍解爆發: the farthest (m) a Bankai NS starts from (KYORAN's lunge hits from 4 m, E10).")
(defparameter *kk-bk-walk-range* 3.6
  "卍解爆發: a neutral decision in a Bankai within this (m) and beyond J reach walks in (the generic CPU would start the NS, 40 a segment).")
(defparameter *kk-wave-p* '(:easy 0.0 :normal 0.15 :hard 0.9)
  "破月牙: per Getsuga route of hers perceived at *KK-WAVE-BAND* (one roll at its first seen segment): answer it, by *KK-WAVE-MIX*.")
(defparameter *kk-wave-band* '(3.4 7.0)
  "破月牙: the distances (m) her Getsuga route is answered at by *KK-WAVE-MIX* (she shoots from 3.6-6.6 m); nearer, the route is always
closed (an attack on her charge: J1 at the sealed pointer 3, whose tame cannot catch a wave).")
(defparameter *kk-wave-close-max* 5.6
  "破月牙: beyond this (m) :close is not rolled (her charges end before he is in; the cut / late Hoho instead). From round 1's b3_a0
(antiwave 0.36 -> 0.75 at 40 seeds), grafted by cell b0_a1, 2026-11-06.")
(defparameter *kk-wave-margin* 0.3
  "破月牙 :close / :chase: he presses once she is within the move's reach + slide - this (m) (the pointer's NS: sealed NS1a 3.1, NS2a 2.8,
the Shikai's lunge 5.6, the hilt 2.4, KYORAN 4.8; J1: sealed 2.4, the Shikai 3.2). Replaces the fixed 2.6 m / 5.4 m. b3_a0's
*KK-REACH-MARGIN*, renamed by b0_a1 (that name is the brawl's reach gate here, 0.5).")
(defparameter *kk-wave-carry* 0.9
  "破月牙 :close / :chase: added to the reach while he runs (a move started from a run carries 0.8-1.0 m: the dash in ends in a run, so
he presses at once instead of Hohoing from 4.4 m and arriving after JUJISHO). b3_a0, 2026-11-06.")
(defparameter *kk-chase-frames* 90
  "破月牙 after a :cut / :late answer: frames after JUJISHO starts he keeps closing in (a dash from beyond *KK-CHASE-DASH*) and attacks
(her recovery ends at f46; JUJISHO itself is 46 frames). b3_a0, 2026-11-06.")
(defparameter *kk-chase-dash* 4.5 "破月牙 :chase: from beyond this (m) he dashes in (to 2.6 m) instead of walking. b3_a0, 2026-11-06.")
(defparameter *kk-wave-timeout* 60 "破月牙 :close: frames after her last seen route segment he gives up closing (her route is over).")
(defparameter *kk-wave-mix* '(:close 0.25 :cut 0.15 :late 1.0)
  "破月牙's answer weights where his NS does not reach her (KK-WAVE-PLAN; where it does, :close): :close (Hoho, else a dash in, then an
NS on her charge, F11 / F12), :cut (the Shikai / Bankai J1 timed to cut the wave, F28 / F32; the sealed form cannot, F31), :late (Hoho
through the wave, F17, only with a Hoho open; then J1 at once as he lands 1.6 m from her: the sealed J1's S6 lands before her next
press, :chase). b3_a0, 2026-11-06: 1.0 / 1.0 / 0.5 -> 0.25 / 0.15 / 1.0 (the sealed close from 4.4 m landed 2 of 12 in its logs).")
(defparameter *kk-cut-lead* 17
  "破月牙 :cut: J1 pressed this many frames after JUJISHO starts, at 5 m (F28 / F29: 13-21), + 1 a 0.233 m farther (the wave's 14 m/s).")
(defparameter *kk-late-lead* 19 "破月牙 :late: the Hoho this many frames after JUJISHO starts, at 5 m (F17), + 1 a 0.233 m farther.")

;;; ---------------------------------------------------------------- the style's state (BRAIN-STYLE; a new match's brain starts NIL)
(defstruct (kks (:constructor make-kks ()))
  (ev -2 :type fixnum)          ; her move start the brawl read was rolled for
  (was :idle)                   ; her perceived state at his last free step (her knockdown's start)
  (meaty nil)                   ; this knockdown's roll said yes (and the J1 is not pressed yet)
  (form nil)                    ; his form the stay's rolls were made for
  (climb nil)                   ; this Shikai stay climbs
  (l3 nil) (bankai nil)         ; L3 seen in this stay (the Bankai roll made); it said yes
  (bk-n 0 :type fixnum)         ; AS cash-outs in this Bankai
  (gw -999 :type fixnum)        ; the start tick of her last perceived Getsuga segment
  (plan nil)                    ; the answer to her route :close :hit :cut :late :chase, or her move :dodge :sdodge; NIL = none
  (at -1 :type fixnum)          ; :dodge / :sdodge: the tick to press; :chase: the tick it ends
  (appr nil) (reach nil) (hin nil) ; an approach is on (KK-PICK); its reach roll; its Hoho-in roll (unspent)
  (tick 0 :type fixnum))        ; *MATCH-TICK* at his last free step (a lower one: a new match, the state starts over)

(defun kk-route-p (s)
  "Does the perceived SNAP S show her in a segment of the Getsuga route (NS2's two charges, JUJISHO; KESSA's copies)?"
  (and (eq (snap-state s) :move) (snap-move s)
       (member (mv-name (snap-move s)) '(:ic-n2a :ic-n2b :ic-n2c :ic-k-n2a :ic-k-n2b :ic-k-n2c))))

(defun kk-juji-start (s)
  "The tick JUJISHO starts (or started) in the route S shows: its own start, or the charges' starts + their lengths (21 / 17 frames
apart in the log)."
  (let ((n (mv-name (snap-move s))) (t0 (snap-start s)))
    (case n ((:ic-n2c :ic-k-n2c) t0) ((:ic-n2b :ic-k-n2b) (+ t0 17)) (t (+ t0 38)))))

(defun kk-wave-tick (s d lead)
  "The tick to press an answer timed LEAD frames after JUJISHO starts at 5 m, shifted by the wave's travel to D (14 m/s)."
  (+ (kk-juji-start s) lead (round (* (- d 5.0) (/ 60.0 14.0)))))

(defun kk-wave-plan (e b f kit d)
  "One roll for her Getsuga route, or NIL. Nearer than *KK-WAVE-BAND*: :close (the wave leaves 1.7 m in front of her). Where his NS
reaches her from here (the Shikai's lunge, KYORAN's): :close, it lands on her charge (F15, F18). Else by *KK-WAVE-MIX*: :late only
with a Hoho open, :cut not sealed, :close not beyond *KK-WAVE-CLOSE-MAX* (b3_a0)."
  (let* ((far (>= d (first *kk-wave-band*)))
         (lunge (<= d (kk-reach kit f :ns)))
         (wc (cond ((or (not far) lunge) 1.0) ((> d *kk-wave-close-max*) 0.0) (t (getf *kk-wave-mix* :close 0.0))))
         (wk (if (or (not far) lunge (eq (fighter-form f) :base)) 0.0 (getf *kk-wave-mix* :cut 0.0)))
         (wl (if (and far (not lunge) (hoho-open-p e)) (getf *kk-wave-mix* :late 0.0) 0.0)) (sum (+ wc wk wl)))
    (when (and (plusp sum) (brain-roll b *kk-wave-p*))
      (let ((r (* sum (sim-rnd01))))
        (cond ((< r wc) :close) ((< r (+ wc wk)) :cut) (t :late))))))

(defun kk-track (e b f kit s d st)
  "The events, once each: a new form stay (the climb roll), L3 reached (the Bankai roll), her knockdown (the meaty roll), her Getsuga
route (the answer's roll)."
  (let ((form (fighter-form f)) (ss (snap-state s)))
    (unless (eq form (kks-form st))
      (setf (kks-form st) form (kks-l3 st) nil (kks-bankai st) nil (kks-bk-n st) 0
            (kks-climb st) (and (eq form :nozarashi) (brain-roll b *kk-climb-p*)))
      (when (kks-climb st) (clog "~a kk climb" (side-name e))))
    (when (eq form :nozarashi)
      (if (>= (ken-lv e) *ken-lv-max*)
          (unless (kks-l3 st)
            (setf (kks-l3 st) t (kks-bankai st) (brain-roll b *kk-bankai-p*))
            (when (kks-bankai st) (clog "~a kk bankai-plan" (side-name e))))
          (setf (kks-l3 st) nil (kks-bankai st) nil)))
    (when (and (member ss '(:air :down)) (not (member (kks-was st) '(:air :down :wakeup))))
      (setf (kks-meaty st) (brain-roll b *kk-meaty-p*))
      (when (kks-meaty st) (clog "~a kk meaty armed" (side-name e))))
    (unless (member ss '(:air :down :wakeup)) (setf (kks-meaty st) nil))
    (setf (kks-was st) ss)
    (when (kk-route-p s)
      (when (and (> (- (snap-start s) (kks-gw st)) 45)            ; (45: a new route, not its next segment, 21 / 17 frames on)
                 (<= d (second *kk-wave-band*)))
        (setf (kks-plan st) (kk-wave-plan e b f kit d) (kks-at st) -1)
        (when (kks-plan st) (clog "~a kk wave ~a at ~,1f" (side-name e) (kks-plan st) d)))
      (setf (kks-gw st) (snap-start s)))))

;;; ---------------------------------------------------------------- neutral
(defun kk-stick (e toward)
  "Hold the stick TOWARD (1 in, 0 still) this step (the generic walk does not run on a step the style decided)."
  (vpad-stick! (pilot-vpad (pilot e)) 0f0 (f32 toward)))

(defun kk-hoho (b) (ai-press b :step 1 :modded t :act :hoho))

(defun kk-reach (kit f what)
  "How far (m) WHAT reaches for him now: :ns the pointer's NS (0 for the sealed tame), :j J1; reach + slide - *KK-WAVE-MARGIN*, + the
run's carry while he runs (b3_a0)."
  (let ((mv (if (eq what :ns) (kit-core-move kit :ns (fighter-ptr f)) (kit-command-move kit :q))))
    (if (and mv (plusp (mv-reach mv)))
        (+ (- (+ (mv-reach mv) (mv-slide mv)) *kk-wave-margin*) (if (eq (fighter-state f) :run) *kk-wave-carry* 0.0))
        0.0)))

(defun kk-attack-in (e b f s what)
  "Press WHAT (:ns the pointer's NS, :j J1) on her route."
  (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01))
  (if (eq what :ns) (cai-sp b f s) (cai-press b :quick 1))
  (kk-stick e 0))

(defun kk-close-hit (e b f kit s d st)
  "In on her charge: the pointer's NS once it reaches (NS against her charge: the first hit wins; a J there is cancelled and read by
her SA), J1 where the NS cannot hit (the sealed tame). T when it pressed (b3_a0)."
  (let ((rn (if (and (member (fighter-form f) '(:bankai :bankai-2)) (kk-route-p s)
                     (member (mv-name (snap-move s)) '(:ic-n2c :ic-k-n2c)))
                0.0                                         ; (a Bankai NS costs 40 Reishi; at JUJISHO his J1 cuts the wave instead)
                (kk-reach kit f :ns))))
    (when (if (plusp rn) (<= d rn) (<= d (kk-reach kit f :j)))
      (setf (kks-plan st) nil)
      (kk-attack-in e b f s (if (plusp rn) :ns :j))
      t)))

(defun kk-chase-step (e b f kit s d st)
  "After a :cut / :late answer: in on her JUJISHO recovery (no SA there) and hit: J1, the fastest, else the NS where only it reaches.
T when it decided (b3_a0)."
  (let ((rj (kk-reach kit f :j)) (rn (kk-reach kit f :ns)))
    (cond ((> *match-tick* (kks-at st)) (setf (kks-plan st) nil) nil)
          ((<= d rj) (setf (kks-plan st) nil) (kk-attack-in e b f s :j) t)
          ((<= d rn) (setf (kks-plan st) nil) (kk-attack-in e b f s :ns) t)
          ((> d *kk-chase-dash*) (ai-dash b 1 2.6) t)
          (t (kk-stick e 1) t))))

(defun kk-wave-step (e b f kit s d st)
  "Carry out the answer to her Getsuga route. T when it decided this step."
  (let ((plan (kks-plan st)) (route (kk-route-p s)))
    (case plan
      (:close
       (cond ((kk-close-hit e b f kit s d st))                 ; in reach now (the Shikai's lunge from 5.3 m, F15; a run's carry)
             ((hoho-open-p e) (setf (kks-plan st) :hit) (kk-hoho b) t)
             (t (setf (kks-plan st) :hit)                     ; (a dash to 2.2 m overran her: the NS then slid past)
                (ai-dash b 1 (let ((rn (kk-reach kit f :ns))) (if (plusp rn) (max 1.6 (- rn *kk-wave-carry*)) 2.2))) t)))
      (:hit                                                     ; in: hit her charge before JUJISHO
       (cond ((or (not route) (> (- *match-tick* (kks-gw st)) *kk-wave-timeout*)) (setf (kks-plan st) nil) nil)
             ((kk-close-hit e b f kit s d st))
             (t (kk-stick e 1) t)))
      ((:cut :late)
       (if (not route)
           (progn (setf (kks-plan st) nil) nil)
           (let ((at (kk-wave-tick s d (if (eq plan :cut) *kk-cut-lead* *kk-late-lead*))))
             (cond ((< *match-tick* at) (kk-stick e 0) t)
                   ((> *match-tick* (+ at 3)) (setf (kks-plan st) nil) nil)   ; perceived too late: no answer
                   (t (setf (kks-plan st) :chase (kks-at st) (+ (kk-juji-start s) *kk-chase-frames*))   ; (KKS-AT: :chase's end tick)
                      (clog "~a kk wave ~a pressed at ~,1f" (side-name e) plan d)
                      (if (eq plan :cut)
                          (progn (setf (brain-own-key b) -1) (cai-press b :quick 1))
                          (if (hoho-open-p e) (kk-hoho b) (setf plan nil (kks-plan st) nil)))
                      (kk-stick e 0)
                      (and plan t))))))
      (:chase (kk-chase-step e b f kit s d st))
      (:dodge                                                   ; Hoho through her move as its hit comes (KK-READ)
       (cond ((not (eq (snap-state s) :move)) (setf (kks-plan st) nil) nil)
             ((< *match-tick* (kks-at st)) (kk-stick e 0) t)
             (t (setf (kks-plan st) nil)
                (when (hoho-open-p e) (clog "~a kk dodge at ~,1f" (side-name e) d) (kk-hoho b) t))))
      (:sdodge                                                  ; back Step through her move as its hit comes (KK-READ)
       (cond ((not (eq (snap-state s) :move)) (setf (kks-plan st) nil) nil)
             ((< *match-tick* (kks-at st)) (kk-stick e 0) t)
             (t (setf (kks-plan st) nil)
                (clog "~a kk step-dodge at ~,1f" (side-name e) d)
                (ai-press b :step 1) (kk-stick e 0) t)))
      (t nil))))

(defun kk-meaty-step (e b f kit s d st)
  "Her knockdown, the roll said yes: in, and J1 to land on her first free frame. T (it decided)."
  (let* ((q (kit-command-move kit :q)) (rf *reaction-frames*) (sf (+ (snap-sf s) (brain-delay b)))
         (left (case (snap-state s)
                 (:down (- (+ (getf rf :down 30) (getf rf :wakeup 30)) sf))
                 (:wakeup (- (getf rf :wakeup 30) sf))
                 (t 999))))
    (cond ((and q (<= left (+ (mv-s q) *kk-meaty-lead*)))
           (setf (kks-meaty st) nil)
           (when (<= d (+ (mv-reach q) (mv-slide q) 0.2))
             (setf (brain-own-key b) -1)
             (clog "~a kk meaty J1 left ~d" (side-name e) left)
             (cai-press b :quick 1))
           (kk-stick e 0))
          ((and (> d *kk-chase-hoho*) (> left 30) (hoho-open-p e)) (kk-hoho b))
          ((> d *kk-meaty-near*) (kk-stick e 1))
          (t (kk-stick e 0)))
    t))

(defun kk-read (e b f kit s d st)
  "封印肉搏's read on her new move start. Sealed within *KK-READ-RANGE*: the tame, J1 or NS1a (*KK-BRAWL-P*). Else (beyond it, the
Shikai, or no answer fits) while her move can reach him: Hoho through it (*KK-DODGE-P*, one roll per her move start), timed by
*KK-DODGE-LEAD*. T when it pressed or planned."
  (let* ((form (fighter-form f)) (mv (snap-move s))
         (clone (and mv (eq (snap-state s) :move) (eq (cai-class-of (fighter-opp f) s) :ns) (zerop (length (mv-hits mv)))
                     (not (kk-route-p s)))))                    ; (KESSA's NS3 a-c: no hit of its own, a clone strikes on f15)
    (when (and (eq (snap-state s) :move) mv (/= (snap-start s) (kks-ev st))
               (<= d (if clone *kk-clone-reach* (max *kk-read-range* (+ (mv-reach mv) (mv-slide mv) *kk-dodge-reach*)))))
      (setf (kks-ev st) (snap-start s))
      (let ((cls (cai-class-of (fighter-opp f) s)) (left (- (snap-s s) (snap-sf s) (brain-delay b)))   ; frames to her hit
            (q (kit-command-move kit :q)) (ptr (fighter-ptr f)))
        (when (and q (member cls '(:na :ns)))
          (let ((how (and (eq form :base) (not clone) (<= d *kk-read-range*) (brain-roll b *kk-brawl-p*)
                          (progn
                            (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01))
                            (cond ((and (= ptr 3) (<= 3 left 27) (not (kk-route-p s))) (cai-sp b f s) :tame)                  ; the tame catches it (F7-F9)
                                  ((and (> left (mv-s q)) (<= d (+ (mv-reach q) (mv-slide q)))) (cai-press b :quick 1) :j1)   ; J1 first (F1, F2)
                                  ((and (= ptr 1) (eq cls :ns) (> left 14)) (cai-sp b f s) :ns1a))))))   ; NS1a first (F3)
            (when (and (not how) (not (kk-route-p s)))
              (cond ((hoho-open-p e)
                     (when (brain-roll b *kk-dodge-p*)
                       (setf (kks-plan st) :dodge (kks-at st) (+ *match-tick* (max 0 (- left *kk-dodge-lead*))) how :dodge)))
                    ((and (<= d *kk-step-max*) (brain-roll b *kk-step-p*))   ; (no Hoho open: the back Step)
                     (let ((sl (if clone (- left (- (snap-s s) *kk-clone-strike*)) left)))
                       (setf (kks-plan st) :sdodge (kks-at st) (+ *match-tick* (max 0 (- sl *kk-step-lead*))) how :sdodge)))))
            (when how
              (clog "~a kk read ~a ~a left ~d at ~,1f" (side-name e) how cls left d)
              (kk-stick e 0)
              t)))))))

(defun kk-decide (e b f s d st)
  "A neutral decision the generic CPU would make this step, taken by the style when a roll says so. T when it decided."
  (let ((form (fighter-form f)) (vp-free (member (fighter-state f) '(:idle :run))))
    (when vp-free
      (case form
        (:base
         (when (and (gauges-awakened-ok-p e) (brain-roll b *kk-awaken-p*))
           (ai-press b :awaken 1 :modded t) t))
        (:nozarashi
         (let ((lv (ken-lv e)))
           (cond ((and (kks-climb st) (< lv *ken-lv-max*) (= (fighter-ptr f) 1)
                       (<= (first *kk-lunge-band*) d (second *kk-lunge-band*)) (brain-roll b *kk-lunge-p*))
                  (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01))
                  (cai-sp b f s) t)
                 ((and (>= lv *ken-lv-max*) (or (kks-climb st) (kks-bankai st)) (<= d *kk-l3-range*))   ; at L3 with a plan: the J string
                  (setf (brain-own-key b) -1)
                  (cai-press b :quick 1) t))))
        ((:bankai :bankai-2)
         (let ((spare (> (reishi-frac (gauges e)) (+ *kk-bk-floor* *kk-bk-ns-spare*))))
           (cond ((and spare (<= d *kk-bk-ns-range*) (brain-roll b *kk-bk-ns-p*))
                  (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01))
                  (cai-sp b f s) t))))))))   ; (else KK-PICK: J1 in reach, a Hoho or a walk in; no generic NS at 40 a segment)

(defun kk-reach-of (mv)
  "MV's reach + slide less *KK-REACH-MARGIN* (m): the farthest it starts from; 0 for a move that reaches nothing (the tame)."
  (if (and mv (plusp (mv-reach mv))) (- (+ (mv-reach mv) (mv-slide mv)) *kk-reach-margin*) 0.0))

(defun kk-pick (e b f kit s d st)
  "封印肉搏's discipline at a neutral decision inside the generic CPU's attack zone: J1 or the pointer's NS only where it reaches (the
generic's NS / J odds between them), else :walk (in, and decide again in *KK-REACH-RETRY* frames) or, sealed, one Hoho in. The rolls
(*KK-REACH-P*, *KK-HOHO-IN-P*) are made once per approach: it starts at the first such decision and ends when he attacks, leaves the
zone or is no longer free. T / :walk when decided, NIL: the generic CPU decides."
  (let ((hi (second (getf (kit-core kit) :range *cai-range*))) (bk (member (fighter-form f) '(:bankai :bankai-2))))
    (if (not (<= d (if bk (max (+ hi 0.6) *kk-bk-walk-range*) (+ hi 0.6))))
        (setf (kks-appr st) nil)
        (progn
          (unless (kks-appr st)
            (setf (kks-appr st) t (kks-reach st) (or bk (brain-roll b *kk-reach-p*)) (kks-hin st) (brain-roll b *kk-hoho-in-p*)))
          (if (not (kks-reach st))
              (setf (kks-appr st) nil)                         ; (this decision is the generic CPU's)
              (let* ((ns (kit-core-move kit :ns (fighter-ptr f))) (q (kit-command-move kit :q))
                     (v (min 0.0 (ken-closing e b s d)))       ; her perceived speed away (m/f, <= 0): only ever stricter
                     (can-j (and q (<= (- d (* v (+ (brain-delay b) (mv-s q)))) (kk-reach-of q))))
                     (can-n (and ns (not bk) (<= (- d (* v (+ (brain-delay b) (mv-s ns)))) (kk-reach-of ns)))))   ; (a Bankai NS: KK-DECIDE's roll)
                (cond ((and can-n (or (not can-j) (< (sim-rnd01) (if (> d 1.7) *cai-ns-far* *cai-ns-near*))))
                       (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01) (kks-appr st) nil)
                       (cai-sp b f s) t)
                      (can-j (setf (brain-own-key b) -1 (kks-appr st) nil) (cai-press b :quick 1) t)
                      ((and (kks-hin st) (not (eq (fighter-form f) :nozarashi)) (<= d *kk-hoho-in-max*) (hoho-open-p e)
                            (>= (gauges-fs (gauges e)) *kk-hin-fs*))
                       (setf (kks-hin st) nil)                 ; (one Hoho an approach)
                       (clog "~a kk hoho-in at ~,1f" (side-name e) d)
                       (kk-hoho b) :walk)                      ; (behind her, 1.6 m: the next decision comes as he is free)
                      (t (kk-stick e 1) :walk))))))))

(defun kk-neutral (e b f kit s d st)
  "Free: her Getsuga route's answer, the meaty chase, the read, then the decision hook. T when the style decided."
  (cond ((kks-plan st) (kk-wave-step e b f kit s d st))
        ((kks-meaty st) (kk-meaty-step e b f kit s d st))
        ((kk-read e b f kit s d st))
        ((<= (brain-decide-t b) 1)                              ; the generic CPU decides this step: the style may take it
         (let ((how (or (and (not (kks-appr st)) (kk-decide e b f s d st)) (kk-pick e b f kit s d st))))   ; (no re-rolls on a retry)
           (when how
             (setf (brain-decide-t b) (if (eq how :walk) *kk-reach-retry*
                                          (+ (getf *cai-think* (brain-difficulty b) 22) (floor (* 12 (sim-rnd01))))))
             t)))))

;;; ---------------------------------------------------------------- his strings
(defun kk-string-target (e f st)
  "The attack press his SP follows in this string, or NIL (the generic CPU's choice): the Shikai at L3, the Bankai J7 or the special AS
J*KK-SPECIAL-N*; climbing below L3, the pointer's own AS (pointer 1 after J2, pointer 2 after J3); a Bankai, J4 (the AS) or J5 (the way
back: his Reishi under the floor, or the cash-outs spent)."
  (case (fighter-form f)
    (:nozarashi
     (cond ((< (ken-lv e) *ken-lv-max*) (and (kks-climb st) (if (= (fighter-ptr f) 1) 2 3)))
           ((kks-bankai st) 7)
           ((kks-climb st) (max 4 (min 6 *kk-special-n*)))))
    ((:bankai :bankai-2)
     (if (or (< (reishi-frac (gauges e)) *kk-bk-floor*) (>= (kks-bk-n st) *kk-bk-cashouts*)) 5 4))))

(defun kk-route-as-p (e f st)
  "Her Getsuga route is live as his NA / SA lands (a J cancels a charge but not JUJISHO): take the AS now (AS beats NS). Sealed, or the
Shikai at pointer 1 (AS1), or at pointer 2 short of an L3 plan (the SP there is the burst: it resets L but lands, 94-159; at L3 with a
plan the J string goes on: every Shikai J window cuts the wave). Not a Bankai (its strings are its exit). b3_a0, 2026-11-06."
  (case (fighter-form f)
    (:base t)
    (:nozarashi (or (= (fighter-ptr f) 1) (< (ken-lv e) *ken-lv-max*) (not (or (kks-climb st) (kks-bankai st)))))
    (t nil)))

(defun kk-move (e b f s st)
  "In his own NA link or SA, as it lands (or cancels): the next J or the SP by KK-STRING-TARGET; her NS seen, the SP at once
(*KK-AS-READ-P*: the AS beats her NS, as the generic CPU reads). T when it decided."
  (when (and (member (fighter-cls f) '(:na :sa)) (eq (fighter-contact f) :hit) (not (fighter-as-done f))
             (/= (brain-decided b) (fighter-cls-t f)))
    (let ((target (if (and (kk-route-p s) (kk-route-as-p e f st)) 0 (kk-string-target e f st))))   ; (0: the SP now, b3_a0)
      (when target
        (cai-own-rolls b f)
        (setf (brain-decided b) (fighter-cls-t f))
        (cond ((and (< (fighter-presses f) target)
                    (not (and (eq (cai-class-of (fighter-opp f) s) :ns) (< (brain-r-turn b) (brain-chance b *kk-as-read-p*)))))
               (cai-press b :quick 1))
              (t (when (and (member (fighter-form f) '(:bankai :bankai-2)) (= target 4)) (incf (kks-bk-n st)))
                 (clog "~a kk string SP after J~d" (side-name e) (fighter-presses f))
                 (cai-sp b f s 1 (= target 7))))               ; (the BANKAI AS holds no Kikon: :no-kikon)
        t))))

(defun kk-ns-whiff (e b f kit s)
  "封印肉搏's discipline in his own NS: the generic CPU presses the next segment on its first active frame, hit or not, so a whiffed
NS1a runs on into b and c (her punish waits for it). With *KK-NS-STOP-P* (one roll per segment) the next segment waits for the
segment's contact: none by its active end (and she is not in an NA, the SA's read) -> he stops there. The latch takes a press until the
segment's end (CORE-LATCH-STEP), so a hit still goes on through the generic CPU. A parry stance (no reach: the tame) is left alone. T when
it decided (waits or stops)."
  (declare (ignore e))
  (let ((mv (fighter-move f)))
    (when (and mv (eq (fighter-cls f) :ns) (plusp (mv-reach mv)) (null (fighter-contact f)) (mv-ns-next kit mv)
               (/= (brain-decided b) (fighter-cls-t f)) (>= (fighter-sf f) (mv-s mv))
               (not (eq (cai-class-of (fighter-opp f) s) :na)))
      (cai-own-rolls b f)
      (when (< (brain-r-turn b) (brain-chance b *kk-ns-stop-p*))  ; (the move's own roll, made once at its start)
        (when (>= (fighter-sf f) (+ (mv-s mv) (mv-a mv)))
          (setf (brain-decided b) (fighter-cls-t f)))
        t))))

(defun kk-kikon-rule (b f)
  "An SP pressed this step held into a Kikon (40 frames: CAI-SP's roll, the style's or the generic CPU's) while she is not red: a tap
instead with *KK-KIKON-RED-P* (one roll per such SP). Her style cancels a non-red Kikon's follow-up (0.95 at HARD), which throws away
the SP's knockdown (the meaty loop's start)."
  (when (and (eq (brain-press b) :quick) (brain-press-mod b) (> (brain-press-left b) 1)
             (not (gauges-red-p (gauges (fighter-opp f)))) (brain-roll b *kk-kikon-red-p*))
    (setf (brain-press-left b) 1)))

(defun ken-ki-style (e b f kit s d)
  "Kenpachi's style against Ichigo (DUEL_MATCHUP_AI §4): T when it decided this step, NIL for the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (null st) (< *match-tick* (kks-tick st))) (setf st (make-kks) (brain-style b) st))
    (setf (kks-tick st) *match-tick*)
    (kk-track e b f kit s d st)
    (let ((state (fighter-state f)))
      (unless (member state '(:idle :run)) (setf (kks-appr st) nil))
      (when (member state '(:idle :run :move))
        (or (if (eq state :move) (or (kk-move e b f s st) (kk-ns-whiff e b f kit s)) (kk-neutral e b f kit s d st))
            (if (eq state :move) (cai-move-step e b f kit s) (cai-neutral e b f kit s d)))   ; (the generic CPU's step, as CORE-BRAIN-STEP)
        (kk-kikon-rule b f)
        t))))

(cai-defstyle :kenpachi :ichigo 'ken-ki-style)

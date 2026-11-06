;;;; cpu-ki-ken.lisp — the KI matchup style CPU: Kenpachi against Ichigo (docs/duel/DUEL_MATCHUP_AI.md §4–§5).
;;;; KEN-KI-STYLE runs before the generic core CPU (core-ai.lisp) on every step he is free to press and plays the four styles the user
;;;; chose (§4), each by its own chance per event, EASY <= NORMAL <= HARD:
;;;;   封印肉搏  sealed: the read on her move start (J1 races her NS, the pointer 3 tame catches her hit, NS1a from beyond J reach) and the
;;;;            meaty J1 on her wake-up (K1); its discipline (cell b0_a0's): a neutral move only where it reaches (else walk or Hoho in),
;;;;            a whiffed NS stops, a Hoho through what he cannot beat (her 4-5 m lunge, KESSA's clones);
;;;;   解放攀升  the Shikai: awaken, build L to 3 on purpose (the lunge whenever it reaches her from 3-5 m against her retreat; the
;;;;            pointer's own AS, never the burst that resets L), then at L3 one Hoho in and J1-J4..J7 + SP (D37-D41; cell b1_a1);
;;;;   卍解爆發  at L3: J1-J7 + SP, the Bankai (D41), the chase (Hoho in, the meaty J1, D43), J1-J4 + SP cash-outs, and the way back,
;;;;            J1-J5 + SP (CHIGIRI / TATE-GOTO, E6 / E25), before his Reishi runs low: the generic CPU forces the AS at J3 and never leaves;
;;;;   破月牙    her Getsuga route at 3.4-7 m (cell b3_a0's): where his NS reaches her it lands on her charge (F15, F18); else mostly
;;;;            Hoho late through the wave (F17) and J1 as he lands (:chase), now and then close in or cut it (F11-F14, F28, F32).
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
  "封印肉搏 / 解放攀升's discipline: per approach (one roll at its first neutral decision inside the generic CPU's attack zone, its range +
0.6 m; KK-PICK) start only a move that reaches her: J1 within its reach + slide, the pointer's NS within its own (never the sealed
pointer 3 tame from neutral), else walk in and decide again soon. Her perceived speed away (KEN-CLOSING, never her speed in) shrinks
the reach by the frames to the hit. From cell b0_a0 (2026-11-06), carried into the Shikai climb here (cell b1_a1).")
(defparameter *kk-reach-margin* 0.5
  "The reach + slide less this (m) is the farthest a neutral move starts from (she backs off during its startup; the perceived distance
is 8 frames old at HARD). Cell b0_a0's 0.5 (0.15: 0.470, 0.5: 0.513, 0.8: 0.410 at 20 seeds a seat).")
(defparameter *kk-reach-retry* 3 "The discipline: frames to the next decision after a walk-in step (re-check as soon as he is in reach).")
(defparameter *kk-ns-stop-p* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "The discipline in his own NS (KK-NS-WHIFF): per NS segment, its next segment waits for its contact and a whiff stops the route (the
generic CPU runs a whiffed NS on, which her style punishes). The latch takes the press up to the segment's end (CORE-LATCH-STEP), so a
landed one still goes on. From cell b0_a0 (2026-11-06).")
(defparameter *kk-dodge-p* '(:easy 0.0 :normal 0.1 :hard 0.8)
  "The read's other answer: her NA / NS perceived starting where his tame / J1 / NS1a cannot beat it (beyond *KK-READ-RANGE*, the Shikai
and the Bankai always) but her move can reach him: Hoho through it (one roll per her move start; a perfect one counters 60 and locks
her 40 frames). From cell b0_a0 (2026-11-06).")
(defparameter *kk-dodge-lead* 9 "The dodge: the Hoho is pressed when her perceived frames to her first active one are at most this.")
(defparameter *kk-dodge-reach* 0.5 "The dodge: her move is answered within its reach + slide + this (m).")
(defparameter *kk-clone-reach* 7.0
  "The dodge: her KESSA NS3 segments (no hit of their own; a clone strikes on f15, which his J1 / NS1a on her cannot stop: the brawl's
answers are skipped for them) are Hohoed through within this distance (m). From cell b0_a0.")
(defparameter *kk-hoho-in-p* '(:easy 0.0 :normal 0.05 :hard 0.8)
  "The discipline, sealed: per approach (KK-PICK's, one roll; one Hoho an approach) out of his reach within *KK-HOHO-IN-MAX*: Hoho in (he
reappears 1.6 m behind her, his J1 / NS1a then reach) instead of walking into her hover. From cell b0_a0 (2026-11-06).")
(defparameter *kk-l3-hoho-p* '(:easy 0.0 :normal 0.05 :hard 0.8)
  "解放攀升 / 卍解爆發 at L3 with a plan (the Shikai): per approach within *KK-L3-ZONE* (KK-PICK's, one roll), out of J reach: one Hoho
in, so the plan's J1 (S9, 2.4 m) starts from behind her on the next decision instead of a walk into her hover. New, cell b1_a1.")
(defparameter *kk-l3-zone* 6.0 "At L3 with a plan the approach (walk / Hoho in, then J1) runs from this distance (m) in.")
(defparameter *kk-hoho-in-max* 4.6 "The Hoho in: the farthest (m) he Hohos in from (her hover band is 3.7-4.2 m sealed).")
(defparameter *kk-meaty-p* '(:easy 0.0 :normal 0.1 :hard 0.7)
  "封印肉搏 / 卍解爆發's chase: per knockdown of hers (one roll as she goes down): walk (or Hoho, from beyond *KK-CHASE-HOHO* m) in and
press J1 to land on her first free frame (K1: 64 a loop; D43 after the Bankai entry).")
(defparameter *kk-meaty-lead* 0
  "The meaty J1 is pressed when her perceived frames to her first free one are J1's startup + this (0: J1's first active frame on it;
K1 gap 0, K2 12 frames late she acts, D47 too early whiffs on her invulnerable wake-up).")
(defparameter *kk-meaty-near* 1.4 "The meaty chase walks in to this distance (m) and waits (the sealed J reaches 1.8 m).")
(defparameter *kk-chase-hoho* 4.5 "The meaty chase Hohos in from beyond this (m) while she is still down (the Bankai entry leaves her 6.13 m away).")
(defparameter *kk-awaken-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "解放攀升's door: one roll per match, the first free step his awakening gauge is seen full (sealed): yes = awaken on that step (and
on the next free step while it cannot yet). A failed roll leaves it to the generic CPU's own *CAI-AWAKEN-P* 0.02 a decision. 0.1 a
neutral decision -> once per match at 1.0 (b1_a0, 2026-11-06): the old roll sat behind the plans and her loop, so he awakened at
44-150 s, mostly well after the gauge filled (~40 s), and after her sealed pointer-3 Soul Break (-5 Konpaku) in 8 of 10 diagnostic
matches.")
(defparameter *kk-kikon-guard-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "One roll per own move (and per neutral SP of the style): his SP holds a Kikon only when it pays: she is red and the pointer is 2
outside the Bankai (3 Konpaku against red, as a Shikai Soul Break, and she cannot cancel it). Pointer 1 / 3 Kikons take 1 Konpaku and
refill her Reishi (throwing away the Soul Break's 3-5), and a non-red Kikon is cancelled (the AS's later segments lost). The generic
CPU holds 35 % a SP, 60 % against red. Also applied to KK-PICK's neutral NS (cell b1_a1; b1_a0's KK-GENERIC-ATTACK, which took the
generic in-range attack by this roll, is replaced by KK-PICK's reach discipline). b1_a0, 2026-11-06.")
(defparameter *kk-climb-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "解放攀升: per Shikai stay (one roll as it starts: the awakening, the return from a Bankai): build L to 3 on purpose. His strings end in
the pointer's own AS (pointer 1: J1 J2 + SP, AS1; pointer 2: J1-J3 + SP, AS2; both raise L), never the bursts that reset it (pointer 1
J3 + SP, pointer 2 J1 / J2 / the SA + SP). Else the generic CPU plays the Shikai. HARD 0.8 -> 1.0 (b1_a0, 2026-11-06).")
(defparameter *kk-lunge-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "解放攀升: climbing under pointer 1, per neutral decision at *KK-LUNGE-BAND*: the NS1 lunge (2.6 m + a 3.0 m slide, D2; a landed lunge
is a combo with an NS: L +1, D12).")
(defparameter *kk-lunge-band* '(3.0 5.2) "解放攀升: the distances (m) he lunges from (the lunge hits from 5 m, D2; F15).")
(defparameter *kk-bankai-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "卍解爆發: per time he reaches L3 (one roll): his strings run J1-J7 + SP into the Bankai (D41 / D42). Else, climbing, J1-J*KK-SPECIAL-N*
+ SP into the special AS. HARD 0.6 -> 1.0 (b1_a0, 2026-11-06): an L3 rise without the Bankai is a 卍解爆發 failure, and the J1-J7
entry lands J4-J6 too (解放攀升's success on the way).")
(defparameter *kk-bankai-max* 9
  "卍解爆發: the Bankai plans a match may make (the L3 rises after them climb to the special AS). Each way back costs him a Konpaku
(none on his last). 9 = no cap (b1_a0, 2026-11-06): before *KK-TURN-P* a cap of 1 helped (HARD 8 -> 11 of 40 with every L3 a Bankai);
with the turn, every L3 a Bankai and no cap was the best (30 of 40, 20 seeds).")
(defparameter *kk-turn-p* '(:easy 1.0 :normal 1.0 :hard 1.0)
  "His planned strings (the climb, L3's J4-J7, the Bankai's): a link that lands or is cancelled while she is perceived in an NS turns to
the SP at once (AS beats NS), as the generic CPU always does (CAI-MOVE-STEP), instead of the next J into her NS (cancelled / absorbed,
then her punish). One roll per link (BRAIN-R-TURN). New, b1_a0 2026-11-06: the plans pressed J on regardless (g1 seed 2: an L3 J1
cancelled by her KESSA chains, J2 into them, absorbed).")
(defparameter *kk-l3-sa-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "解放攀升 at L3 with a plan: in a Shikai NS segment's gap within *KK-L3-SA-RANGE*, the SA (one roll per segment), so the plan's string
(SA J2 .. J4 / J7 + SP) runs from it. New, b1_a0 2026-11-06: stays ended by an NS kill at L3 counted as failures.")
(defparameter *kk-l3-sa-range* 2.6 "解放攀升: the farthest (m) the L3 SA is pressed from (the generic CPU's own segment SA reach, CAI-MOVE-STEP).")
(defparameter *kk-special-n* 4
  "解放攀升 at L3: the J press the special AS's SP follows, 4-6 (J4: DAISHARIN 166 / INSEKI-GIRI 174, D37 / D39; J6: 190 / 198, D38 /
D40; a longer string drops more often).")
(defparameter *kk-bk-cashouts* 0
  "卍解爆發: the J1-J4 + SP cash-outs (KYORAN / ZANKAI AS, 4 segments: 240 / 319 to her, 160 of his own Reishi, E5 / E24) before the string
that leaves the Bankai, J1-J5 + SP (CHIGIRI 247 / TATE-GOTO 288, E6 / E25). 1 -> 0 (cell b1_a1, as b2_a0 measured: the first Bankai string is the way back,
for 40 Reishi against the cash-out's 160; 20 seeds a seat, paired: shikai .873 -> .936, bankai .646 -> .651, HARD 37 = 37 of 40).")
(defparameter *kk-bk-floor* 0.5
  "卍解爆發: under this fraction of his Reishi his next Bankai string leaves (J5 + SP) and he starts no Bankai NS (40 Reishi a segment, the
Bankai's only cost; no other way out).")
(defparameter *kk-bk-ns-p* '(:easy 0.0 :normal 0.1 :hard 0.25)
  "卍解爆發: per neutral decision in a Bankai within *KK-BK-NS-RANGE* and Reishi over *KK-BK-FLOOR* + *KK-BK-NS-SPARE*: the NS route
(KYORAN's lunge from 4 m, E10; ZANKAI's NS a-d SA J2-J4 AS 461, L6) rather than J1.")
(defparameter *kk-bk-ns-spare* 0.15 "卍解爆發: the Reishi fraction over the floor a Bankai NS route needs (4 segments: 160 of 1300).")
(defparameter *kk-bk-ns-range* 3.8 "卍解爆發: the farthest (m) a Bankai NS starts from (KYORAN's lunge hits from 4 m, E10).")
(defparameter *kk-bk-j-range* 2.2 "卍解爆發: a neutral decision in a Bankai within this (m) starts J1 (the Bankai J 1.8-1.9 m + slide).")
(defparameter *kk-bk-walk-range* 6.0
  "卍解爆發: a neutral decision in a Bankai within this (m) and beyond J reach dashes in to *KK-BK-DASH-TO* (the generic CPU would start
the NS, 40 a segment). 3.6 m and a one-step walk -> 6.0 m and the dash (b1_a0, 2026-11-06): the walk held the stick one step a
decision, she kept 3.1-3.3 m, nobody attacked and the Bankai sat to the 300 s time-out (e1 seed 4).")
(defparameter *kk-bk-dash-to* 1.8 "卍解爆發: the dash in ends at this distance (m); the next decision starts J1 (KYORAN J1 1.8 m + slide).")
(defparameter *kk-wave-p* '(:easy 0.0 :normal 0.15 :hard 0.9)
  "破月牙: per Getsuga route of hers perceived at *KK-WAVE-BAND* (one roll at its first seen segment): answer it, by *KK-WAVE-MIX*.")
(defparameter *kk-wave-band* '(3.4 7.0)
  "破月牙: the distances (m) her Getsuga route is answered at by *KK-WAVE-MIX* (she shoots from 3.6-6.6 m); nearer, the route is always
closed (an attack on her charge: J1 at the sealed pointer 3, whose tame cannot catch a wave).")
(defparameter *kk-wave-close-max* 5.6
  "破月牙: beyond this (m) :close is not rolled (her charges end before he is in; the cut / late Hoho instead). Cell b3_a0, 2026-11-06.")
(defparameter *kk-wave-margin* 0.3
  "破月牙 :close / :chase: he presses once she is within the move's reach + slide - this (m) (the pointer's NS: sealed NS1a 3.1, the
Shikai's lunge 5.6, KYORAN 4.8; J1: sealed 2.4, the Shikai 3.2). Replaces the fixed 2.6 m / 5.4 m (*KK-WAVE-IN* / *KK-WAVE-LUNGE*).
Cell b3_a0's *KK-REACH-MARGIN* 0.3, renamed here (b0_a0's neutral margin 0.5 holds that name).")
(defparameter *kk-wave-carry* 0.9
  "破月牙 :close / :chase: added to the reach while he runs (a move started from a run carries 0.8-1.0 m). Cell b3_a0, 2026-11-06.")
(defparameter *kk-chase-frames* 90
  "破月牙 after a :cut / :late answer: frames after JUJISHO starts he keeps closing in (a dash from beyond *KK-CHASE-DASH*) and attacks
(her recovery ends at f46). Cell b3_a0, 2026-11-06.")
(defparameter *kk-chase-dash* 4.5 "破月牙 :chase: from beyond this (m) he dashes in (to 2.6 m) instead of walking. Cell b3_a0, 2026-11-06.")
(defparameter *kk-wave-timeout* 60 "破月牙 :close: frames after her last seen route segment he gives up closing (her route is over).")
(defparameter *kk-wave-mix* '(:close 0.25 :cut 0.15 :late 1.0)
  "破月牙's answer weights where his NS does not reach her (KK-WAVE-PLAN; where it does, :close): :close (Hoho, else a dash in, then an
NS on her charge, F11 / F12), :cut (the Shikai / Bankai J1 timed to cut the wave, F28 / F32; not sealed, F31), :late (Hoho through the
wave, F17, only with a Hoho open; then J1 at once as he lands 1.6 m from her, :chase). Cell b3_a0, 2026-11-06: 1.0 / 1.0 / 0.5 ->
0.25 / 0.15 / 1.0 (antiwave 0.36 -> 0.75 at 40 seeds there).")
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
  (bk-plans 0 :type fixnum)     ; Bankai plans made this match
  (sa-key -1 :type fixnum)      ; the NS segment (its CLS-T) the L3 SA roll was made for
  (aw nil)                      ; the match's awaken roll: NIL unmade, :go, :no
  (gw -999 :type fixnum)        ; the start tick of her last perceived Getsuga segment
  (plan nil)                    ; the answer to her route: :close :hit :cut :late, NIL = none
  (at -1 :type fixnum)          ; :dodge: the tick to press; :chase: the tick it ends
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

(defun kk-reach (kit f what)
  "How far (m) WHAT reaches for him now: :ns the pointer's NS (0 for the sealed tame), :j J1; reach + slide - *KK-WAVE-MARGIN*, + the
run's carry while he runs (cell b3_a0's)."
  (let ((mv (if (eq what :ns) (kit-core-move kit :ns (fighter-ptr f)) (kit-command-move kit :q))))
    (if (and mv (plusp (mv-reach mv)))
        (+ (- (+ (mv-reach mv) (mv-slide mv)) *kk-wave-margin*) (if (eq (fighter-state f) :run) *kk-wave-carry* 0.0))
        0.0)))

(defun kk-wave-plan (e b f kit d)
  "One roll for her Getsuga route, or NIL (cell b3_a0's). Nearer than *KK-WAVE-BAND*: :close (the wave leaves 1.7 m in front of her).
Where his NS reaches her from here (the Shikai's lunge, KYORAN's): :close, it lands on her charge (F15, F18). Else by *KK-WAVE-MIX*:
:late only with a Hoho open, :cut not sealed, :close not beyond *KK-WAVE-CLOSE-MAX*."
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
            (setf (kks-l3 st) t (kks-bankai st) (and (< (kks-bk-plans st) *kk-bankai-max*) (brain-roll b *kk-bankai-p*)))
            (when (kks-bankai st) (incf (kks-bk-plans st)))
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

(defun kk-kikon-ptr (f)
  "The pointer whose Kikon count his next SP's hold would take: in an NA link / SA the AS the SP starts (CORE-NEXT-AS; the Shikai's
J4-J6 start the current pointer's special AS, D54 / D55), from neutral the pointer's own NS."
  (if (member (fighter-cls f) '(:na :sa))
      (if (and (eq (fighter-form f) :nozarashi) (>= (fighter-presses f) 4)) (fighter-ptr f) (core-next-as f))
      (fighter-ptr f)))

(defun kk-kikon-gate (b f)
  "*KK-KIKON-GUARD-P*: after his SP's Kikon roll (BRAIN-R-KIKON) is made, cancel the hold unless it pays (she is red, the SP's pointer
by KK-KIKON-PTR is 2, sealed or the Shikai; the Bankai's Kikon takes 3 against its Soul Break's 5). Her red bar is a visible fact, read
as CAI-SP and her own style do."
  (when (and (not (and (gauges-red-p (gauges (fighter-opp f))) (eql (kk-kikon-ptr f) 2) (member (fighter-form f) '(:base :nozarashi))))
             (brain-roll b *kk-kikon-guard-p*))
    (setf (brain-r-kikon b) 1f0)))

(defun kk-attack-in (e b f s what)
  "Press WHAT (:ns the pointer's NS, :j J1) on her route (the Kikon gate on the NS's hold)."
  (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01)) (kk-kikon-gate b f)
  (if (eq what :ns) (cai-sp b f s) (cai-press b :quick 1))
  (kk-stick e 0))

(defun kk-close-hit (e b f kit s d st)
  "In on her charge: the pointer's NS once it reaches (NS against her charge: the first hit wins; a J there is cancelled and read by
her SA), J1 where the NS cannot hit (the sealed tame); in a Bankai at her JUJISHO J1 (it cuts the wave; the NS costs 40 Reishi). Cell
b3_a0's. T when it pressed."
  (let ((rn (if (and (member (fighter-form f) '(:bankai :bankai-2)) (kk-route-p s)
                     (member (mv-name (snap-move s)) '(:ic-n2c :ic-k-n2c)))
                0.0
                (kk-reach kit f :ns))))
    (when (if (plusp rn) (<= d rn) (<= d (kk-reach kit f :j)))
      (setf (kks-plan st) nil)
      (kk-attack-in e b f s (if (plusp rn) :ns :j))
      t)))

(defun kk-chase-step (e b f kit s d st)
  "After a :cut / :late answer: in on her JUJISHO recovery (no SA there) and hit: J1, the fastest, else the NS where only it reaches
(cell b3_a0's). T when it decided."
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
                   (t (setf (kks-plan st) :chase (kks-at st) (+ (kk-juji-start s) *kk-chase-frames*))
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
*KK-DODGE-LEAD* (cell b0_a0's). T when it pressed or planned."
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
                            (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01)) (kk-kikon-gate b f)
                            (cond ((and (= ptr 3) (<= 3 left 27) (not (kk-route-p s))) (cai-sp b f s) :tame)                  ; the tame catches it (F7-F9)
                                  ((and (> left (mv-s q)) (<= d (+ (mv-reach q) (mv-slide q)))) (cai-press b :quick 1) :j1)   ; J1 first (F1, F2)
                                  ((and (= ptr 1) (eq cls :ns) (> left 14)) (cai-sp b f s) :ns1a))))))   ; NS1a first (F3)
            (when (and (not how) (not (kk-route-p s)) (hoho-open-p e) (brain-roll b *kk-dodge-p*))
              (setf (kks-plan st) :dodge (kks-at st) (+ *match-tick* (max 0 (- left *kk-dodge-lead*))) how :dodge))
            (when how
              (clog "~a kk read ~a ~a left ~d at ~,1f" (side-name e) how cls left d)
              (kk-stick e 0)
              t)))))))

(defun kk-reach-of (mv)
  "MV's reach + slide less *KK-REACH-MARGIN* (m): the farthest it starts from; 0 for a move that reaches nothing (the tame)."
  (if (and mv (plusp (mv-reach mv))) (- (+ (mv-reach mv) (mv-slide mv)) *kk-reach-margin*) 0.0))

(defun kk-pick (e b f kit s d st)
  "The discipline at a neutral decision inside the generic CPU's attack zone, sealed or in the Shikai (cell b0_a0's, with the Kikon gate
of b1_a0): J1 or the pointer's NS only where it reaches (the generic's NS / J odds between them), else :walk (in, and decide again in
*KK-REACH-RETRY* frames) or, sealed, one Hoho in. At L3 with a plan (the Shikai): J1 only, the plan's J string. The rolls (*KK-REACH-P*,
*KK-HOHO-IN-P*) are made once per approach. T / :walk when decided, NIL: the generic CPU decides."
  (let* ((hi (second (getf (kit-core kit) :range *cai-range*))) (form (fighter-form f))
         (l3 (and (eq form :nozarashi) (>= (ken-lv e) *ken-lv-max*) (or (kks-climb st) (kks-bankai st)))))
    (if (not (and (member form '(:base :nozarashi)) (<= d (if l3 (max (+ hi 0.6) *kk-l3-zone*) (+ hi 0.6)))))
        (setf (kks-appr st) nil)
        (progn
          (unless (kks-appr st)
            (setf (kks-appr st) t (kks-reach st) (or l3 (brain-roll b *kk-reach-p*))
                  (kks-hin st) (brain-roll b (if l3 *kk-l3-hoho-p* *kk-hoho-in-p*))))
          (if (not (kks-reach st))
              (progn (setf (kks-appr st) nil) nil)               ; (this decision is the generic CPU's)
              (let* ((ns (and (not l3) (kit-core-move kit :ns (fighter-ptr f)))) (q (kit-command-move kit :q))
                     (v (min 0.0 (ken-closing e b s d)))       ; her perceived speed away (m/f, <= 0): only ever stricter
                     (can-j (and q (<= (- d (* v (+ (brain-delay b) (mv-s q)))) (kk-reach-of q))))
                     (can-n (and ns (<= (- d (* v (+ (brain-delay b) (mv-s ns)))) (kk-reach-of ns)))))
                (cond ((and can-n (or (not can-j) (< (sim-rnd01) (if (> d 1.7) *cai-ns-far* *cai-ns-near*))))
                       (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01) (kks-appr st) nil) (kk-kikon-gate b f)
                       (cai-sp b f s) t)
                      (can-j (setf (brain-own-key b) -1 (kks-appr st) nil) (cai-press b :quick 1) t)
                      ((and (kks-hin st) (or l3 (and (eq form :base) (<= d *kk-hoho-in-max*))) (hoho-open-p e))
                       (setf (kks-hin st) nil)                 ; (one Hoho an approach)
                       (clog "~a kk hoho-in at ~,1f" (side-name e) d)
                       (kk-hoho b) :walk)
                      (t (kk-stick e 1) :walk))))))))

(defun kk-decide (e b f s d st)
  "A neutral decision the generic CPU would make this step, taken by the style when a roll says so. T when it decided."
  (let ((form (fighter-form f)) (vp-free (member (fighter-state f) '(:idle :run))))
    (when vp-free
      (case form
        (:base nil)                                             ; (KK-PICK)
        (:nozarashi
         (let ((lv (ken-lv e)))
           (cond ((and (kks-climb st) (< lv *ken-lv-max*) (= (fighter-ptr f) 1)
                       (<= (first *kk-lunge-band*) d (second *kk-lunge-band*))
                       (let ((ns (kit-core-move (fighter-kit f) :ns 1)))   ; (it reaches against her perceived retreat)
                         (and ns (<= (- d (* (min 0.0 (ken-closing e b s d)) (+ (brain-delay b) (mv-s ns)))) (kk-reach-of ns))))
                       (brain-roll b *kk-lunge-p*))
                  (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01)) (kk-kikon-gate b f)
                  (clog "~a kk lunge at ~,1f" (side-name e) d)
                  (cai-sp b f s) t)
                 (t nil))))                                     ; (KK-PICK: at L3 with a plan the J string where it reaches)
        ((:bankai :bankai-2)
         (let ((spare (> (reishi-frac (gauges e)) (+ *kk-bk-floor* *kk-bk-ns-spare*))))
           (cond ((and spare (<= d *kk-bk-ns-range*) (brain-roll b *kk-bk-ns-p*))
                  (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01)) (kk-kikon-gate b f)
                  (cai-sp b f s) t)
                 ((<= d *kk-bk-j-range*) (setf (brain-own-key b) -1) (cai-press b :quick 1) t)
                 ((<= d *kk-bk-walk-range*) (ai-dash b 1 *kk-bk-dash-to*) t))))))))   ; (no generic NS at 40 a segment: dash in to J reach)

(defun kk-neutral (e b f kit s d st)
  "Free: her Getsuga route's answer, the meaty chase, the read, then the decision hook. T when the style decided."
  (when (and (eq (fighter-form f) :base) (gauges-awakened-ok-p e))
    (unless (kks-aw st)
      (setf (kks-aw st) (if (brain-roll b *kk-awaken-p*) :go :no))))
  (cond ((and (eq (kks-aw st) :go) (eq (fighter-form f) :base) (gauges-awakened-ok-p e))
         (setf (kks-plan st) nil (kks-meaty st) nil)
         (clog "~a kk awaken" (side-name e))
         (ai-press b :awaken 1 :modded t) t)
        ((kks-plan st) (kk-wave-step e b f kit s d st))
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

(defun kk-move (e b f s st)
  "In his own NA link or SA, as it lands: the next J or the SP by KK-STRING-TARGET. T when it decided."
  (when (and (member (fighter-cls f) '(:na :sa)) (eq (fighter-contact f) :hit) (not (fighter-as-done f))
             (/= (brain-decided b) (fighter-cls-t f)))
    (let ((target (kk-string-target e f st)))
      (when target
        (cai-own-rolls b f)
        (setf (brain-decided b) (fighter-cls-t f))
        (let* ((n (fighter-presses f))
               (turn (and (< n target) (eq (cai-class-of (fighter-opp f) s) :ns) (< (brain-r-turn b) (brain-chance b *kk-turn-p*)))))
          (cond ((and (< n target) (not turn)) (cai-press b :quick 1))
                (t (when (and (member (fighter-form f) '(:bankai :bankai-2)) (< n 5)) (incf (kks-bk-n st)))
                   (clog "~a kk string SP after J~d~:[~; (turn: her NS)~]" (side-name e) n turn)
                   (cai-sp b f s 1 (>= n 7)))))               ; (the BANKAI AS holds no Kikon: :no-kikon)
        t))))

(defun kk-ns-whiff (b f kit s)
  "The discipline in his own NS (cell b0_a0's): the generic CPU presses the next segment on its first active frame, hit or not, so a
whiffed NS runs on (her punish waits for it). With *KK-NS-STOP-P* (the move's own roll, made once at its start) the next segment waits
for the segment's contact: none by its active end (and she is not in an NA, the SA's read) -> he stops there. The latch takes a press
until the segment's end, so a hit still goes on through the generic CPU. A parry stance (no reach: the tame) is left alone. T when it
decided (waits or stops)."
  (let ((mv (fighter-move f)))
    (when (and mv (eq (fighter-cls f) :ns) (plusp (mv-reach mv)) (null (fighter-contact f)) (mv-ns-next kit mv)
               (/= (brain-decided b) (fighter-cls-t f)) (>= (fighter-sf f) (mv-s mv))
               (not (eq (cai-class-of (fighter-opp f) s) :na)))
      (cai-own-rolls b f)
      (when (< (brain-r-turn b) (brain-chance b *kk-ns-stop-p*))
        (when (>= (fighter-sf f) (+ (mv-s mv) (mv-a mv)))
          (setf (brain-decided b) (fighter-cls-t f)))
        t))))

(defun kk-l3-sa (e b f kit d st)
  "解放攀升 / 卍解爆發 at L3 with a plan, in the Shikai's NS gap (the segment out): the SA, so the plan's J string runs on from it (the SA
counts as J1: NS .. SA J2-J4 + SP the special AS, .. J7 + SP the Bankai; L3 / L4 in the catalogue) instead of the NS chain the kill
came from (a match ended by an NS segment at L3 leaves the stay without J4-J7). One roll per segment. T when it pressed."
  (let ((mv (fighter-move f)))
    (when (and mv (eq (fighter-cls f) :ns) (eq (fighter-form f) :nozarashi) (>= (ken-lv e) *ken-lv-max*)
               (or (kks-climb st) (kks-bankai st)) (>= (fighter-sf f) (mv-s mv)) (/= (brain-decided b) (fighter-cls-t f))
               (/= (kks-sa-key st) (fighter-cls-t f)) (kit-sa-move kit) (< d *kk-l3-sa-range*))
      (setf (kks-sa-key st) (fighter-cls-t f))               ; (one roll a segment; a failed one leaves it to the generic CPU)
      (when (brain-roll b *kk-l3-sa-p*)
        (setf (brain-decided b) (fighter-cls-t f))
        (clog "~a kk l3 SA" (side-name e))
        (cai-press b :quick 1)
        t))))

(defun ken-ki-style (e b f kit s d)
  "Kenpachi's style against Ichigo (DUEL_MATCHUP_AI §4): T when it decided this step, NIL for the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (null st) (< *match-tick* (kks-tick st))) (setf st (make-kks) (brain-style b) st))
    (setf (kks-tick st) *match-tick*)
    (kk-track e b f kit s d st)
    (unless (member (fighter-state f) '(:idle :run)) (setf (kks-appr st) nil))
    (case (fighter-state f)
      ((:idle :run) (kk-neutral e b f kit s d st))
      (:move (let ((k (brain-own-key b)))
               (cai-own-rolls b f)
               (unless (= k (brain-own-key b)) (kk-kikon-gate b f)))
             (or (kk-l3-sa e b f kit d st) (kk-move e b f s st) (kk-ns-whiff b f kit s)))
      (t nil))))

(cai-defstyle :kenpachi :ichigo 'ken-ki-style)

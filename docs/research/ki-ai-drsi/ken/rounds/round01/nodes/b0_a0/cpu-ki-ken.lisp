;;;; cpu-ki-ken.lisp — the KI matchup style CPU: Kenpachi against Ichigo (docs/duel/DUEL_MATCHUP_AI.md §4–§5).
;;;; KEN-KI-STYLE runs before the generic core CPU (core-ai.lisp) on every step he is free to press and plays the four styles the user
;;;; chose (§4), each by its own chance per event, EASY <= NORMAL <= HARD:
;;;;   封印肉搏  sealed: the read on her move start (J1 races her NS, the pointer 3 tame catches her hit, NS1a from beyond J reach) and the
;;;;            meaty J1 on her wake-up (K1); its discipline (cell b0_a0): a neutral move only where it reaches (else walk or Hoho in),
;;;;            a whiffed NS stops instead of running on, a Hoho through what he cannot beat (her 4-5 m lunge, KESSA's clones), a
;;;;            Kikon held only on a red Ichigo, and the AS read in his planned strings;
;;;;   解放攀升  the Shikai: awaken, build L to 3 on purpose (the lunge from 3-5 m; the pointer's own AS, never the burst that resets L),
;;;;            then J1-J4..J6 + SP, the special AS (D37-D40);
;;;;   卍解爆發  at L3: J1-J7 + SP, the Bankai (D41), the chase (Hoho in, the meaty J1, D43), J1-J4 + SP cash-outs, and the way back,
;;;;            J1-J5 + SP (CHIGIRI / TATE-GOTO, E6 / E25), before his Reishi runs low: the generic CPU forces the AS at J3 and never leaves;
;;;;   破月牙    her Getsuga route at 3.4-7 m: close it (Hoho / Step in, then an NS on her charge; the Shikai's lunge from 5.4 m: F11-F15), cut
;;;;            the wave with the Shikai / Bankai J1 (F28, F32) or Hoho late through it (F17).
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
(defparameter *kk-wave-in* 2.6 "破月牙 :close: once in this close (m) he hits her charge (the sealed NS1a 1.9 m + 1.2 slide; J 1.8 + 0.6).")
(defparameter *kk-wave-lunge* 5.4 "破月牙 :close in the Shikai under pointer 1: from within this (m) the lunge at once (2.6 m + 3.0 slide, F15) instead of closing.")
(defparameter *kk-wave-timeout* 60 "破月牙 :close: frames after her last seen route segment he gives up closing (her route is over).")
(defparameter *kk-wave-mix* '(:close 1.0 :cut 1.0 :late 0.5)
  "破月牙's answer weights: :close (Hoho, else a Step in, then an NS on her charge, F11 / F12; the Shikai's pointer 1 lunges at once from
5.4 m, F15), :cut (the Shikai / Bankai J1 timed to cut the wave, F28 / F32; the sealed form cannot, F31), :late (Hoho through the wave, F17).")
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
  (plan nil)                    ; the answer to her route: :close :hit :cut :late, NIL = none
  (at -1 :type fixnum)          ; :cut / :late: the tick to press
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

(defun kk-wave-plan (b f d)
  "One roll for her Getsuga route: :close / :cut / :late by *KK-WAVE-MIX* (no :cut sealed; only :close nearer than *KK-WAVE-BAND*: the
wave leaves 1.7 m in front of her), or NIL."
  (let* ((far (>= d (first *kk-wave-band*)))
         (wc (if far (getf *kk-wave-mix* :close 0.0) 1.0)) (wk (if (or (not far) (eq (fighter-form f) :base)) 0.0 (getf *kk-wave-mix* :cut 0.0)))
         (wl (if far (getf *kk-wave-mix* :late 0.0) 0.0)) (sum (+ wc wk wl)))
    (when (and (plusp sum) (brain-roll b *kk-wave-p*))
      (let ((r (* sum (sim-rnd01))))
        (cond ((< r wc) :close) ((< r (+ wc wk)) :cut) (t :late))))))

(defun kk-track (e b f s d st)
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
        (setf (kks-plan st) (kk-wave-plan b f d) (kks-at st) -1)
        (when (kks-plan st) (clog "~a kk wave ~a at ~,1f" (side-name e) (kks-plan st) d)))
      (setf (kks-gw st) (snap-start s)))))

;;; ---------------------------------------------------------------- neutral
(defun kk-stick (e toward)
  "Hold the stick TOWARD (1 in, 0 still) this step (the generic walk does not run on a step the style decided)."
  (vpad-stick! (pilot-vpad (pilot e)) 0f0 (f32 toward)))

(defun kk-hoho (b) (ai-press b :step 1 :modded t :act :hoho))

(defun kk-attack-in (e b f s)
  "The answer once he is in on her charge: the pointer's NS where it reaches and hits (sealed pointers 1 / 2, the Shikai's lunge), else J1
(it cancels a charge; the generic CPU turns to the AS, F10)."
  (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01))
  (let ((ptr (fighter-ptr f)) (form (fighter-form f)))
    (if (or (and (eq form :base) (<= ptr 2)) (and (eq form :nozarashi) (= ptr 1)))
        (cai-sp b f s)
        (cai-press b :quick 1)))
  (kk-stick e 0))

(defun kk-wave-step (e b f s d st)
  "Carry out the answer to her Getsuga route. T when it decided this step."
  (let ((plan (kks-plan st)) (route (kk-route-p s)))
    (case plan
      (:close
       (cond ((and (eq (fighter-form f) :nozarashi) (= (fighter-ptr f) 1) (<= d *kk-wave-lunge*))   ; the lunge at once (F15)
              (setf (kks-plan st) nil) (kk-attack-in e b f s) t)
             ((hoho-open-p e) (setf (kks-plan st) :hit) (kk-hoho b) t)
             (t (setf (kks-plan st) :hit) (ai-dash b 1 2.2) t)))
      (:hit                                                     ; in: hit her charge before JUJISHO
       (cond ((or (not route) (> (- *match-tick* (kks-gw st)) *kk-wave-timeout*)) (setf (kks-plan st) nil) nil)
             ((<= d *kk-wave-in*) (setf (kks-plan st) nil) (kk-attack-in e b f s) t)
             (t (kk-stick e 1) t)))
      ((:cut :late)
       (if (not route)
           (progn (setf (kks-plan st) nil) nil)
           (let ((at (kk-wave-tick s d (if (eq plan :cut) *kk-cut-lead* *kk-late-lead*))))
             (cond ((< *match-tick* at) (kk-stick e 0) t)
                   ((> *match-tick* (+ at 3)) (setf (kks-plan st) nil) nil)   ; perceived too late: no answer
                   (t (setf (kks-plan st) nil)
                      (clog "~a kk wave ~a pressed at ~,1f" (side-name e) plan d)
                      (if (eq plan :cut)
                          (progn (setf (brain-own-key b) -1) (cai-press b :quick 1))
                          (if (hoho-open-p e) (kk-hoho b) (setf plan nil)))
                      (kk-stick e 0)
                      (and plan t))))))
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
            (when (and (not how) (not (kk-route-p s)) (hoho-open-p e) (brain-roll b *kk-dodge-p*))
              (setf (kks-plan st) :dodge (kks-at st) (+ *match-tick* (max 0 (- left *kk-dodge-lead*))) how :dodge))
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
                      ((and (kks-hin st) (not (eq (fighter-form f) :nozarashi)) (<= d *kk-hoho-in-max*) (hoho-open-p e))
                       (setf (kks-hin st) nil)                 ; (one Hoho an approach)
                       (clog "~a kk hoho-in at ~,1f" (side-name e) d)
                       (kk-hoho b) :walk)                      ; (behind her, 1.6 m: the next decision comes as he is free)
                      (t (kk-stick e 1) :walk))))))))

(defun kk-neutral (e b f kit s d st)
  "Free: her Getsuga route's answer, the meaty chase, the read, then the decision hook. T when the style decided."
  (cond ((kks-plan st) (kk-wave-step e b f s d st))
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
  "In his own NA link or SA, as it lands (or cancels): the next J or the SP by KK-STRING-TARGET; her NS seen, the SP at once
(*KK-AS-READ-P*: the AS beats her NS, as the generic CPU reads). T when it decided."
  (when (and (member (fighter-cls f) '(:na :sa)) (eq (fighter-contact f) :hit) (not (fighter-as-done f))
             (/= (brain-decided b) (fighter-cls-t f)))
    (let ((target (kk-string-target e f st)))
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
    (kk-track e b f s d st)
    (let ((state (fighter-state f)))
      (unless (member state '(:idle :run)) (setf (kks-appr st) nil))
      (when (member state '(:idle :run :move))
        (or (if (eq state :move) (or (kk-move e b f s st) (kk-ns-whiff e b f kit s)) (kk-neutral e b f kit s d st))
            (if (eq state :move) (cai-move-step e b f kit s) (cai-neutral e b f kit s d)))   ; (the generic CPU's step, as CORE-BRAIN-STEP)
        (kk-kikon-rule b f)
        t))))

(cai-defstyle :kenpachi :ichigo 'ken-ki-style)

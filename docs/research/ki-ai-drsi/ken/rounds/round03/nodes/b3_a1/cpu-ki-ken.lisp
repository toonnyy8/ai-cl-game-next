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
;;;;   破月牙    her Getsuga route at 3.4-7 m: where his NS reaches her (the Shikai's lunge, KYORAN's) it lands on her charge (F15, F18);
;;;;            else mostly Hoho late through the wave (F17) and J1 at once as he lands (:chase), now and then close in (Hoho / dash, then
;;;;            an NS on her charge: F11-F14) or cut the wave with the Shikai / Bankai J1 (F28, F32). A J that lands on her route turns
;;;;            to the AS (AS beats NS; a J only cancels her charge). (b3_a0, 2026-11-06.) From afar (7-12 m, her style's own shots,
;;;;            mostly as he gets up from her AS2's wave): Hoho in at once and hit her charge, else the cut; sealed without a Hoho, a
;;;;            Step forward timed through the wave, then J1 out of the Step's J cancel (b3_a1, 2026-11-06).
;;;; Cell b3_a1 (round 1) = b0_a0's file (the sealed discipline, the AS read) + b3_a0's 破月牙 + b1_a0's awakening once a match, L3 SA and
;;;; Kikon pointer gate + b2_a0's straight-back Bankai (no cash-out) + b0_a1's flash-step reserve and back-Step dodge + its own far-wave
;;;; answers.
;;;; Cell b0_a0 (round 2, against Ichigo's champion: the whiff confirm, the 3.4-3.8 m hover) on b3_a1: the sealed brawl's
;;;; follow-through. The route after a landed NS goes by reach (KK-LINK), and his sealed AS runs all its segments (KK-AS-ON). Every
;;;; knockdown gets the meaty (never a move into her wake-up), the dodge answers every reachable move she starts, and the Hoho in is off.
;;;; Cell b3_a0 (round 3, against her champion b1_a1: the timed perfect Hoho on his perceived move start, the wake-up Hoho, the meaty J1
;;;; loop) on b0_a0: no neutral move she can see start in time while her Hoho is ready (KK-SEEN-P: J1 S6 / a Step in and J1 out of its
;;;; J cancel instead of NS1a and the Shikai lunge), the meaty wait beyond her wake-up Hoho's 2.2 m, J1 onto her Hoho's end, and with an
;;;; S9 J1 (the Shikai) the wake-up Hoho baited instead of met.
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
(defparameter *kk-link-p* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "封印肉搏's route discipline (KK-LINK), per landed segment of his own sealed NS: the next segment where it reaches, else the SA where it
reaches, else stop. Her champion's whiff confirm (round 2) punished the generic CPU's SA after a landed NS1a (the SA reaches 1.0 m, the
NS1a's slide leaves her ~2 m off). New 2026-11-07, cell b0_a0 (round 2). (A J-string twin, the next J or the AS by reach, was tried and
dropped: the J whiffs it would catch sat at a perceived 0.8 m, mostly her Burst, so the distance could not tell them.) Ablation on the final file, 20 seeds a seat paired: HARD 0 -> brawl 0.845 (272/322) against
0.861 (267/310) with it.")
(defparameter *kk-as-on-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "封印肉搏's AS carried through (KK-AS-ON): per segment of his sealed AS, the next segment once it lands (else the generic CPU's 0.85 a
segment at HARD). New 2026-11-07, cell b0_a0 (round 2): AS3a / AS3b left 3 times of ~350 each (51 / 45 before), and brawl went 0.829
-> 0.879 (20 seeds a seat paired). NORMAL 0: the shipped CPU's own roll.")
(defparameter *kk-link-margin* 0.0
  "封印肉搏's string discipline: a link lands within its reach + slide + this (m), against the perceived distance (8 frames old at HARD).")
(defparameter *kk-dodge-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "封印肉搏's read, its other answer: her NA / NS perceived starting where his tame / J1 / NS1a cannot beat it (beyond *KK-READ-RANGE*:
her NS3a lunge from 4-5 m, S18 + a 2.4 m slide; the Shikai and the Bankai always) but her move can reach him: Hoho through it (one roll
per her move start). Hoho: invulnerable frames 1-14, behind her on frame 6; a perfect one (her hit within 12 frames) counters 60 and
locks her 40 frames: 14 of 20 dodges in one HARD match were perfect. New 2026-11-06, cell b0_a0. HARD 0.8 -> 1.0, 2026-11-07, cell
b0_a0 (round 2), against her champion: 20 seeds a seat paired (both arms with *KK-BRAWL-P* HARD 1.0), brawl 0.747 -> 0.829 (failed
exchanges 114 -> 71; her lunges and NS1a the dodge now always answers).")
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
(defparameter *kk-hoho-in-p* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "封印肉搏's discipline, sealed or in a Bankai: per approach (KK-PICK's, one roll; one Hoho an approach) out of his reach within
*KK-HOHO-IN-MAX*: Hoho in (he reappears 1.6 m behind her on frame 6, his J1 / NS1a then reach) instead of walking in. Her hover backs
off from a walk-in (3.7-4.2 m sealed) and punishes the move he starts at its edge. New 2026-11-06, cell b0_a0. Off: 0 / 0.05 / 0.8 ->
0 / 0 / 0, 2026-11-07, cell b0_a0 (round 2): against her champion's hover (3.4-3.8 m) and whiff punish the Hoho in lost. He lands 1.6 m
behind her, but his perceived distance is from before she backed off; his J1 then started at a real 2.8-3.0 m into her punish-j. The
exchanges after a Hoho in went 42 ok / 33 failed (0.56, under the theme's mean), and turning it off took brawl 0.672 -> 0.754 (20 seeds
a seat, paired). With it off, *KK-HIN-FS* and *KK-HOHO-IN-MAX* do nothing (the code stays for the search).")
(defparameter *kk-hoho-in-max* 4.6 "封印肉搏's Hoho in: the farthest (m) he Hohos in from (her hover band is 3.7-4.2 m sealed).")
(defparameter *kk-blind-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "Her timed Hoho (round 3: her champion Hohos his perceived move start once its hit is 1-6 frames off, within its reach + slide + 1 m;
a perfect Hoho is the 60 counter, his 40-frame lock and her J string, and it opened 377 of her 416 combos on him, 232k of 271k Reishi, in
the baseline's 40 HARD matches, 20 seeds a seat; 356 of them on his NS1a, the sealed one's S14 or the Shikai's S16 lunge). Per approach
(KK-PICK's, one roll) and per neutral decision: while she is free and her Hoho is not perceived locked out (*KK-HOHO-LOCKOUT*), no
neutral move whose startup she can see in time (over *KK-BLIND-S*): J1 where it reaches, else a dash into J1's reach (*KK-DASH-MAX*).
New, cell b3_a0 round 3, 2026-11-07.")
(defparameter *kk-blind-s* 8
  "Her perception is 8 frames at HARD: a move whose hit lands on its frame 8 or sooner is out before she sees it start (the sealed J1 S6,
KYORAN's J1 S7, every SA S7-S8). *KK-BLIND-P*'s line: a neutral move with a later hit waits for her Hoho to be spent. Cell b3_a0 round 3.")
(defparameter *kk-hoho-lockout* 84
  "Frames from her Hoho's start to her next one (*HOHO-FRAMES* 24 + *HOHO-LOCKOUT* 60): after a Hoho of hers he sees, his NS is safe
from the next one until then (less his perception delay). Cell b3_a0 round 3.")
(defparameter *kk-hend-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "Her Hoho seen (not a perfect one: that locks him): J1 timed to land on her first free frame after it (her Hoho's start + *HOHO-FRAMES*
24), where she reappears 1.6 m behind him and her next Hoho is locked out (*KK-HOHO-LOCKOUT*). Before, his next move came on the stale
SNAP or late (her KESSA J1, S8, then won: 7 of the v4 file's Shikai combos on him after her Hoho, 10k of 76k Reishi). One roll per her
Hoho. Cell b3_a0 round 3, 2026-11-07.")
(defparameter *kk-hend-lead* 0 "*KK-HEND-P*: J1's hit lands this many frames after her Hoho's last frame.")
(defparameter *kk-wake-bait* '(:easy nil :normal nil :hard t)
  "Her knockdown, the meaty armed, but his J1 is one she sees in time (the Shikai's S9, the Bankais' over *KK-BLIND-S*): no meaty J1 (her
timed or wake-up Hoho met it on its frame, the J1 landed, and she left his string after one hit). He waits within her wake-up Hoho's
2.2 m (at *KK-MEATY-NEAR*) for the Hoho, and *KK-HEND-P* answers it. Cell b3_a0 round 3, 2026-11-07.")
(defparameter *kk-step-in* '(2.8 4.8)
  "*KK-BLIND-P*: out of J1's reach, she this far (m) off, he Steps in (2.5 m in 12 frames, no move for her Hoho to read) and presses J1 out
of the Step's J cancel where it reaches (KK-STEP-J), instead of walking (4.4 m/s against her 4.2 m/s walk back: her hover keeps her
3.4-4.2 m off). Nearer than the band he walks in. Cell b3_a0 round 3.")
(defparameter *kk-clone-reach* 7.0
  "封印肉搏's dodge: her KESSA NS3 segments (no hit of their own; a clone appears on f8 and strikes on f15, where his J1 / NS1a on her
cannot stop it: the brawl's answers are skipped for them) are Hohoed through within this distance (m).")
(defparameter *kk-as-read-p* '(:easy 1.0 :normal 1.0 :hard 1.0)
  "In a planned string (KK-MOVE: the climb, L3's J4-J7, the Bankai's), a link that lands or cancels while she is seen in an NS turns to
the SP at once, as the generic CPU's CAI-MOVE-STEP always does (one roll per link, the move's own BRAIN-R-TURN). v0's plans pressed the
next J into her NS / SA. A located v0 bug, found independently by round 1's b1_a0 (*KK-TURN-P*) and b2_a0 (*KK-AS-READ-P*).")
(defparameter *kk-meaty-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "封印肉搏 / 卍解爆發's chase: per knockdown of hers (one roll as she goes down): walk (or Hoho, from beyond *KK-CHASE-HOHO* m) in and
press J1 to land on her first free frame (K1: 64 a loop; D43 after the Bankai entry). HARD 0.7 -> 1.0, 2026-11-07, cell b0_a0
(round 2): a failed roll left the generic CPU to start NS1a / J1 into her invulnerable wake-up, the move whiffed and her champion's whiff
confirm J1 landed: 35 of the baseline's 213 failed exchanges (20 seeds a seat), 0 after.")
(defparameter *kk-meaty-lead* 0
  "The meaty J1 is pressed when her perceived frames to her first free one are J1's startup + this (0: J1's first active frame on it;
K1 gap 0, K2 12 frames late she acts, D47 too early whiffs on her invulnerable wake-up).")
(defparameter *kk-meaty-near* 1.4 "The meaty chase walks in to this distance (m) and waits (the sealed J reaches 1.8 m).")
(defparameter *kk-meaty-out* '(:easy nil :normal nil :hard (2.25 2.4))
  "The meaty chase waits in this band (m) instead of at *KK-MEATY-NEAR* (NIL: as before): her wake-up Hoho (round 3: her first free frame,
one roll at 0.9, only with him within 2.2 m of what she sees) met 168 of his 304 meaty J1s in one seat; the J1 still lands then, but her
Hoho takes her out of his string after its first hit (35). From 2.25-2.4 m her Hoho is not rolled, and J1 (1.8 m + 0.6 slide) still
lands on her first free frame. He walks back into the band while she is down (at most until 12 frames before she is up). Cell b3_a0
round 3, 2026-11-07.")
(defparameter *kk-chase-hoho* 4.5 "The meaty chase Hohos in from beyond this (m) while she is still down (the Bankai entry leaves her 6.13 m away).")
(defparameter *kk-awaken-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "解放攀升's door: one roll per match, the first free step his awakening gauge is seen full (sealed): yes = awaken on that step (and
on the next free step while it cannot yet). A failed roll leaves it to the generic CPU's own *CAI-AWAKEN-P* 0.02 a decision. 0.1 a
neutral decision -> once per match at 1.0 (b1_a0, 2026-11-06): the old roll sat behind the plans and her loop, so he awakened at
44-150 s, mostly well after the gauge filled (~40 s), and after her sealed pointer-3 Soul Break (-5 Konpaku) in 8 of 10 diagnostic
matches.")
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
(defparameter *kk-l3-sa-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "解放攀升 at L3 with a plan: in a Shikai NS segment's gap within *KK-L3-SA-RANGE*, the SA (one roll per segment), so the plan's string
(SA J2 .. J4 / J7 + SP) runs from it. New, b1_a0 2026-11-06: stays ended by an NS kill at L3 counted as failures.")
(defparameter *kk-l3-sa-range* 2.6 "解放攀升: the farthest (m) the L3 SA is pressed from (the generic CPU's own segment SA reach, CAI-MOVE-STEP).")
(defparameter *kk-kikon-ptr-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "On top of *KK-KIKON-RED-P*: per SP held into a Kikon on a red Ichigo, tap it unless the SP's pointer (KK-KIKON-PTR) is 2, sealed or
the Shikai (b1_a0's *KK-KIKON-GUARD-P* pointer policy: pointer 1 / 3 Kikons take 1 Konpaku and refill her Reishi, where the Soul Break
takes 3-5; the Bankai's Kikon takes 3 against its Soul Break's 5). One roll per such SP. b3_a1, 2026-11-06 (from b1_a0).")
(defparameter *kk-special-n* 4
  "解放攀升 at L3: the J press the special AS's SP follows, 4-6 (J4: DAISHARIN 166 / INSEKI-GIRI 174, D37 / D39; J6: 190 / 198, D38 /
D40; a longer string drops more often).")
(defparameter *kk-bk-cashouts* 0
  "卍解爆發: the J1-J4 + SP cash-outs (KYORAN / ZANKAI AS, 4 segments: 240 / 319 to her, 160 of his own Reishi, E5 / E24) before the string
that leaves the Bankai, J1-J5 + SP (CHIGIRI 247 / TATE-GOTO 288, E6 / E25). 1 -> 0 (b2_a0's value, taken by b3_a1 2026-11-06: a stay
that ends with the match inside the Bankai fails 卍解爆發; straight back, then the next L3 cycles again).")
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
  "破月牙: the distances (m) her Getsuga route is answered at by *KK-WAVE-MIX* (the generic shoots from 3.6-6.6 m, her style from 7.5 m
on); nearer, the route is always closed (an attack on her charge: J1 at the sealed pointer 3, whose tame cannot catch a wave).
Unchanged: b3_a0 tried 9.5 (to answer her far shots) and reverted it, HARD 3/40 against 6/40 at 7.0 on the same seeds.")
(defparameter *kk-wave-far* 12.0
  "破月牙 from afar: her Getsuga route perceived beyond *KK-WAVE-BAND* and within this (m) (her style shoots from 7.5 m on, mostly as he
gets up from her AS2's point-blank wave) is answered too, by the same roll (*KK-WAVE-P*): Hoho at once (behind her from any distance:
her charges are NS windows with no hit; from behind, JUJISHO's wave flies away from him), then the pointer's NS on her (:close / :hit,
F11 / F14 / F22). No Hoho open: the Shikai / Bankai J1 timed to cut the wave (:cut); sealed, none (the generic CPU's). Before this he
dashed in from beyond 7 m into the wave: 57 full waves (150) hit him in 40 HARD matches at b3_a1's v2, mostly 2-5 in a row. New, b3_a1
2026-11-06 (b3_a0's 9.5 m band answered these by the late Hoho, a different answer, and was reverted).")
(defparameter *kk-wave-close-max* 5.6
  "破月牙: beyond this (m) :close is not rolled (her charges end before he is in; the cut / late Hoho instead). b3_a0, 2026-11-06.")
(defparameter *kk-wave-margin* 0.3
  "(b3_a0's *KK-REACH-MARGIN*, renamed in b3_a1: b0_a0's neutral margin has that name.) 破月牙 :close / :chase: he presses once she is within the move's reach + slide - this (m) (the pointer's NS: sealed NS1a 3.1, NS2a 2.8,
the Shikai's lunge 5.6, the hilt 2.4, KYORAN 4.8; J1: sealed 2.4, the Shikai 3.2). Replaces the fixed 2.6 m / 5.4 m lunge (b3_a0, 2026-11-06).")
(defparameter *kk-wave-carry* 0.9
  "破月牙 :close / :chase: added to the reach while he runs (a move started from a run carries 0.8-1.0 m: the dash in ends in a run, so
he presses at once instead of Hohoing from 4.4 m and arriving after JUJISHO). b3_a0, 2026-11-06.")
(defparameter *kk-chase-frames* 90
  "破月牙 after a :cut / :late answer: frames after JUJISHO starts he keeps closing in (a dash from beyond *KK-CHASE-DASH*) and attacks
(her recovery ends at f46; JUJISHO itself is 46 frames). b3_a0, 2026-11-06.")
(defparameter *kk-chase-dash* 4.5 "破月牙 :chase: from beyond this (m) he dashes in (to 2.6 m) instead of walking. b3_a0, 2026-11-06.")
(defparameter *kk-wave-timeout* 60 "破月牙 :close: frames after her last seen route segment he gives up closing (her route is over).")
(defparameter *kk-wave-mix* '(:close 0.25 :cut 0.15 :late 1.0 :step 1.0)
  "破月牙's answer weights where his NS does not reach her (KK-WAVE-PLAN; where it does, :close): :close (Hoho, else a dash in, then an
NS on her charge, F11 / F12), :cut (the Shikai / Bankai J1 timed to cut the wave, F28 / F32; the sealed form cannot, F31), :late (Hoho
through the wave, F17, only with a Hoho open; then J1 at once as he lands 1.6 m from her: the sealed J1's S6 lands before her next
press, :chase). b3_a0, 2026-11-06: 1.0 / 1.0 / 0.5 -> 0.25 / 0.15 / 1.0 (the sealed close from 4.4 m landed 2 of 12 in the logs: he
sees her route at the end of his dash, as her second charge starts; a cut leaves him 4 m off as she recovers).")
(defparameter *kk-cut-lead* 17
  "破月牙 :cut: J1 pressed this many frames after JUJISHO starts, at 5 m (F28 / F29: 13-21), + 1 a 0.233 m farther (the wave's 14 m/s).")
(defparameter *kk-late-lead* 19 "破月牙 :late: the Hoho this many frames after JUJISHO starts, at 5 m (F17), + 1 a 0.233 m farther.")
(defparameter *kk-wave-step-lead* 21
  "破月牙 :step (sealed, no Hoho open: his flash-step under a Hoho's 100, mostly after a Burst): a Step forward this many frames after
JUJISHO starts, at 5 m, + 1 a 0.233 m farther, so the wave's 1 m box passes him inside the Step's invulnerable frames 3-9 (*STEP-IFRAMES*:
the wave closing at 14 m/s and his hop at about 12 m/s meet on about frame 4 and are through by frame 8); then :chase. The weight is
*KK-WAVE-MIX*'s :step. Before it a sealed Kenpachi without a Hoho had no answer and dashed into the wave (28 of the 37 full waves that
hit him in 80 HARD matches at b3_a1's v4). New, b3_a1 2026-11-06.")
(defparameter *kk-wave-late* '(:easy nil :normal nil :hard t)
  "破月牙, by difficulty: at the press of :close / :hit (KK-CLOSE-HIT), an NS (or the sealed J1, which cannot cut a wave) whose first
active frame would come after JUJISHO's wave is out (KK-WAVE-LATE-P) is not pressed: a Hoho at once instead (open: he reappears behind
her, the wave flies away from him, then :chase onto her JUJISHO recovery), else the timed Step through it (:step). Before it the plan
pressed his NS whenever he got free, however late: round 3 b3_a1's testbed (his HARD style against her generic HARD CPU, 40 seeds a
seat) logged the Shikai lunge started 0-20 frames after JUJISHO's start (seed 4 t 8178, seed 20 t 8171, IK / KI) and the 150 on him
3-48 frames later. The same flag gates the Step-held wait in KK-WAVE-STEP (round 2 b3_a0's located bug: a Hoho / Step pressed on
the step a dash lets go of Step has no down edge and never comes out; never merged into this lineage). A gate, not a chance; NIL below
HARD (NORMAL unchanged). New, round 3 b3_a1 2026-11-07.")
(defparameter *kk-wave-w0* 20
  "破月牙: JUJISHO's wave is out this many frames after JUJISHO starts (:ic-juji / :ic-n2c :startup 20, ICHIGO-JUJI on f20).")
(defparameter *kk-wave-touch* 1.9
  "破月牙: the distance (m) JUJISHO's wave touches him as it comes out (it forms ~1 m ahead of her, its box 0.5 m deep, his body ~0.4 m);
farther, it reaches him 60/14 frames a metre later. Fitted to the testbed's logged 150s: 2.3 m +23 frames, 2.9 m +24 (formula 22 / 24).")

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
  (plan nil)                    ; the answer to her route: :close :hit :cut :late :step :chase, her move: :dodge :sdodge, NIL = none
  (at -1 :type fixnum)          ; :chase: the tick it ends; :dodge: the tick to Hoho
  (sa-key -1 :type fixnum)      ; the NS segment (its CLS-T) the L3 SA roll was made for (b1_a0)
  (aw nil)                      ; the match's awaken roll: NIL unmade, :go, :no (b1_a0)
  (appr nil) (reach nil) (hin nil) ; an approach is on (KK-PICK); its reach roll; its Hoho-in roll (unspent)
  (blind nil) (sj nil)          ; this approach's *KK-BLIND-P* roll; its Step in is on (KK-STEP-J)
  (hl -999 :type fixnum)        ; the tick her perceived last Hoho's lockout ends (*KK-HOHO-LOCKOUT*)
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
with a Hoho open, :cut not sealed, :close not beyond *KK-WAVE-CLOSE-MAX*, :step only sealed without a Hoho. Beyond the band (to
*KK-WAVE-FAR*): :close by a Hoho, else :cut, else (sealed) :step."
  (when (> d (second *kk-wave-band*))                          ; (from afar: Hoho in at once, else the cut; b3_a1)
    (return-from kk-wave-plan
      (cond ((not (brain-roll b *kk-wave-p*)) nil)
            ((hoho-open-p e) :close)
            ((not (eq (fighter-form f) :base)) :cut)
            ((plusp (getf *kk-wave-mix* :step 0.0)) :step))))
  (let* ((far (>= d (first *kk-wave-band*)))
         (lunge (<= d (kk-reach kit f :ns)))
         (wc (cond ((or (not far) lunge) 1.0) ((> d *kk-wave-close-max*) 0.0) (t (getf *kk-wave-mix* :close 0.0))))
         (wk (if (or (not far) lunge (eq (fighter-form f) :base)) 0.0 (getf *kk-wave-mix* :cut 0.0)))
         (wl (if (and far (not lunge) (hoho-open-p e)) (getf *kk-wave-mix* :late 0.0) 0.0))
         (ws (if (and far (not lunge) (not (hoho-open-p e)) (eq (fighter-form f) :base)) (getf *kk-wave-mix* :step 0.0) 0.0))
         (sum (+ wc wk wl ws)))
    (when (and (plusp sum) (brain-roll b *kk-wave-p*))
      (let ((r (* sum (sim-rnd01))))
        (cond ((< r wc) :close) ((< r (+ wc wk)) :cut) ((< r (+ wc wk wl)) :late) (t :step))))))

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
    (when (eq ss :hoho)                                         ; her Hoho seen: its start = now - delay - her frame
      (let ((h0 (- *match-tick* (brain-delay b) (snap-sf s))) (q (kit-command-move kit :q)))
        (when (> (+ h0 *kk-hoho-lockout*) (kks-hl st))         ; (a new one)
          (setf (kks-hl st) (+ h0 *kk-hoho-lockout*))
          (when (and q (null (kks-plan st)) (brain-roll b *kk-hend-p*))
            (setf (kks-plan st) :hend (kks-at st) (+ h0 *hoho-frames* *kk-hend-lead* (- (mv-s q))))
            (clog "~a kk hoho-end plan at ~d" (side-name e) (kks-at st))))))
    (setf (kks-was st) ss)
    (when (kk-route-p s)
      (when (and (> (- (snap-start s) (kks-gw st)) 45)            ; (45: a new route, not its next segment, 21 / 17 frames on)
                 (<= d *kk-wave-far*))
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
run's carry while he runs."
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
her SA), J1 where the NS cannot hit (the sealed tame). T when it pressed."
  (let ((rn (if (and (member (fighter-form f) '(:bankai :bankai-2)) (kk-route-p s)
                     (member (mv-name (snap-move s)) '(:ic-n2c :ic-k-n2c)))
                0.0                                         ; (a Bankai NS costs 40 Reishi; at JUJISHO his J1 cuts the wave instead)
                (kk-reach kit f :ns))))
    (when (if (plusp rn) (<= d rn) (<= d (kk-reach kit f :j)))
      (let ((mv (if (plusp rn) (kit-core-move kit :ns (fighter-ptr f)) (kit-command-move kit :q))))
        (cond ((and (or (plusp rn) (eq (fighter-form f) :base)) (kk-wave-late-p b s d mv))   ; (too late: through the wave instead)
               (if (hoho-open-p e)
                   (progn (setf (kks-plan st) :chase (kks-at st) (+ (kk-juji-start s) *kk-chase-frames*))
                          (clog "~a kk wave late hoho at ~,1f" (side-name e) d)
                          (kk-hoho b) (kk-stick e 0))
                   (progn (setf (kks-plan st) :step)
                          (clog "~a kk wave late step at ~,1f" (side-name e) d)
                          (kk-stick e 0))))
              (t (setf (kks-plan st) nil)
                 (kk-attack-in e b f s (if (plusp rn) :ns :j)))))
      t)))

(defun kk-wave-late-p (b s d mv)
  "*KK-WAVE-LATE*: would MV, pressed now, reach its first active frame only once the wave of her route S (perceived) is out, while
that wave has not yet passed him at D (out at JUJISHO + *KK-WAVE-W0*, then 14 m/s from *KK-WAVE-TOUCH*; + 2 frames)?"
  (and (getf *kk-wave-late* (brain-difficulty b)) mv (kk-route-p s)
       (let ((out (+ (kk-juji-start s) *kk-wave-w0*)))
         (and (>= (+ *match-tick* (mv-s mv)) out)
              (<= *match-tick* (+ out 2 (round (* (max 0.0 (- d *kk-wave-touch*)) (/ 60.0 14.0)))))))))

(defun kk-chase-step (e b f kit s d st)
  "After a :cut / :late answer: in on her JUJISHO recovery (no SA there) and hit: J1, the fastest, else the NS where only it reaches.
T when it decided."
  (let ((rj (kk-reach kit f :j)) (rn (kk-reach kit f :ns)))
    (cond ((> *match-tick* (kks-at st)) (setf (kks-plan st) nil) nil)
          ((<= d rj) (setf (kks-plan st) nil) (kk-attack-in e b f s :j) t)
          ((<= d rn) (setf (kks-plan st) nil) (kk-attack-in e b f s :ns) t)
          ((> d *kk-chase-dash*) (ai-dash b 1 2.6) t)
          (t (kk-stick e 1) t))))

(defun kk-wave-step (e b f kit s d st)
  "Carry out the answer to her Getsuga route. T when it decided this step."
  (let ((plan (kks-plan st)) (route (kk-route-p s)))
    (when (and (member plan '(:close :hit :cut :late :step :chase)) (getf *kk-wave-late* (brain-difficulty b)) (vpad-down (pilot-vpad (pilot e)) :step))
      (kk-stick e 0)                                          ; (Step still down from the dash he just let go: a press there has
      (return-from kk-wave-step t))                           ;  no down edge; wait one step. Round 2 b3_a0's located bug, credited)
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
      ((:cut :late :step)
       (if (not route)
           (progn (setf (kks-plan st) nil) nil)
           (let ((at (kk-wave-tick s d (case plan (:cut *kk-cut-lead*) (:late *kk-late-lead*) (t *kk-wave-step-lead*)))))
             (cond ((< *match-tick* at) (kk-stick e 0) t)
                   ((> *match-tick* (+ at 3)) (setf (kks-plan st) nil) nil)   ; perceived too late: no answer
                   (t (setf (kks-plan st) :chase (kks-at st) (+ (kk-juji-start s) *kk-chase-frames*))
                      (clog "~a kk wave ~a pressed at ~,1f" (side-name e) plan d)
                      (case plan
                        (:cut (setf (brain-own-key b) -1) (cai-press b :quick 1) (kk-stick e 0))
                        (:late (if (hoho-open-p e) (kk-hoho b) (setf plan nil (kks-plan st) nil)) (kk-stick e 0))
                        (t (ai-press b :step 1) (kk-stick e 1)))   ; (:step: the hop toward her, through the wave)
                      (and plan t))))))
      (:chase (kk-chase-step e b f kit s d st))
      (:hend                                                    ; J1 onto her Hoho's end (*KK-HEND-P*)
       (cond ((not (member (snap-state s) '(:hoho :idle :run))) (setf (kks-plan st) nil) nil)
             ((< *match-tick* (kks-at st)) (kk-stick e 0) t)
             (t (setf (kks-plan st) nil)
                (when (and (<= *match-tick* (+ (kks-at st) 2)) (<= d (kk-reach kit f :j)))
                  (setf (brain-own-key b) -1)
                  (clog "~a kk hoho-end J1 at ~,1f" (side-name e) d)
                  (cai-press b :quick 1) (kk-stick e 0) t))))
      (:sdodge                                                  ; back Step through her move as its hit comes (KK-READ)
       (cond ((not (eq (snap-state s) :move)) (setf (kks-plan st) nil) nil)
             ((< *match-tick* (kks-at st)) (kk-stick e 0) t)
             (t (setf (kks-plan st) nil)
                (clog "~a kk step-dodge at ~,1f" (side-name e) d)
                (ai-press b :step 1) (kk-stick e 0) t)))
      (:dodge                                                   ; Hoho through her move as its hit comes (KK-READ)
       (cond ((not (eq (snap-state s) :move)) (setf (kks-plan st) nil) nil)
             ((< *match-tick* (kks-at st)) (kk-stick e 0) t)
             (t (setf (kks-plan st) nil)
                (when (hoho-open-p e) (clog "~a kk dodge at ~,1f" (side-name e) d) (kk-hoho b) t))))
      (t nil))))

(defun kk-step-j (e b f kit s d st)
  "破月牙 :chase after the Step through the wave: J1 pressed 2 frames before the Step's J cancel (*STEP-J-CANCEL* 12; the latch starts
it there) when she is in its reach, instead of waiting out the Step's 24 frames (one sample: his J1 came out 1 frame after her next
move started, the situation lost). Once per Step (its one frame). T when it pressed. b3_a1, 2026-11-06."
  (when (and (or (eq (kks-plan st) :chase) (kks-sj st)) (= (fighter-sf f) (- *step-j-cancel* 2))
             (<= (- d (* (min 0.0 (ken-closing e b s d)) (+ (brain-delay b) 8))) (kk-reach kit f :j)))   ; (her walk back, as KK-PICK)
    (setf (kks-plan st) nil (kks-sj st) nil (brain-own-key b) -1)
    (clog "~a kk step J1 at ~,1f" (side-name e) d)
    (cai-press b :quick 1)
    t))

(defun kk-meaty-step (e b f kit s d st)
  "Her knockdown, the roll said yes: in, and J1 to land on her first free frame. T (it decided)."
  (let* ((q (kit-command-move kit :q)) (rf *reaction-frames*) (sf (+ (snap-sf s) (brain-delay b)))
         (left (case (snap-state s)
                 (:down (- (+ (getf rf :down 30) (getf rf :wakeup 30)) sf))
                 (:wakeup (- (getf rf :wakeup 30) sf))
                 (t 999))))
    (cond ((and q (> (mv-s q) *kk-blind-s*) (brain-chance b *kk-wake-bait*))   ; (her Hoho sees this J1: bait it instead)
           (kk-stick e (if (> d *kk-meaty-near*) 1 0)))
          ((and q (<= left (+ (mv-s q) *kk-meaty-lead*)))
           (setf (kks-meaty st) nil)
           (when (<= d (+ (mv-reach q) (mv-slide q) 0.2))
             (setf (brain-own-key b) -1)
             (clog "~a kk meaty J1 left ~d" (side-name e) left)
             (cai-press b :quick 1))
           (kk-stick e 0))
          ((and (> d *kk-chase-hoho*) (> left 30) (hoho-open-p e)) (kk-hoho b))
          ((let ((out (brain-chance b *kk-meaty-out*)))         ; (her wake-up Hoho's 2.2 m: wait beyond it)
             (when out
               (cond ((> d (second out)) (kk-stick e 1))
                     ((and (< d (first out)) (> left 12)) (kk-stick e -1))
                     (t (kk-stick e 0)))
               t)))
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
        (:nozarashi
         (let ((lv (ken-lv e)))
           (cond ((and (kks-climb st) (< lv *ken-lv-max*) (= (fighter-ptr f) 1)
                       (<= (first *kk-lunge-band*) d (second *kk-lunge-band*)) (brain-roll b *kk-lunge-p*)
                       (not (and (kk-seen-p b s st (kit-core-move (fighter-kit f) :ns 1)) (brain-roll b *kk-blind-p*))))
                  (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01))
                  (cai-sp b f s) t)
                 ((and (>= lv *ken-lv-max*) (or (kks-climb st) (kks-bankai st)) (<= d *kk-l3-range*)   ; at L3 with a plan: the J string
                       (not (and (kk-seen-p b s st (kit-command-move (fighter-kit f) :q)) (brain-roll b *kk-blind-p*))))   ; (her Hoho reads the S9 J1)
                  (setf (brain-own-key b) -1)
                  (cai-press b :quick 1) t))))
        ((:bankai :bankai-2)
         (let ((spare (> (reishi-frac (gauges e)) (+ *kk-bk-floor* *kk-bk-ns-spare*))))
           (cond ((and spare (<= d *kk-bk-ns-range*) (brain-roll b *kk-bk-ns-p*)
                       (not (and (kk-seen-p b s st (kit-core-move (fighter-kit f) :ns (fighter-ptr f))) (brain-roll b *kk-blind-p*))))
                  (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01))
                  (cai-sp b f s) t))))))))   ; (else KK-PICK: J1 in reach, a Hoho or a walk in; no generic NS at 40 a segment)

(defun kk-seen-p (b s st mv &optional (lead 0))
  "*KK-BLIND-P*: would she see MV start in time to Hoho it? Its hit is later than *KK-BLIND-S*, and she is free to Hoho before its last
frame (its startup - 1): not still in her own move or stun by then (her perceived frames left less his delay), not down, and her Hoho
not locked out by one he saw (*KK-HOHO-LOCKOUT*)."
  (and mv (> (mv-s mv) *kk-blind-s*)
       (let ((busy (case (snap-state s)
                     ((:move :stun) (- (snap-left s) (brain-delay b)))
                     ((:air :down :wakeup) 999)
                     (t 0))))
         (< (max busy (- (kks-hl st) *match-tick*)) (+ lead (1- (mv-s mv)))))))   ; (LEAD: frames before MV starts)

(defun kk-reach-of (mv)
  "MV's reach + slide less *KK-REACH-MARGIN* (m): the farthest it starts from; 0 for a move that reaches nothing (the tame)."
  (if (and mv (plusp (mv-reach mv))) (- (+ (mv-reach mv) (mv-slide mv)) *kk-reach-margin*) 0.0))

(defun kk-pick (e b f kit s d st)
  "封印肉搏's discipline at a neutral decision inside the generic CPU's attack zone: J1 or the pointer's NS only where it reaches (the
generic's NS / J odds between them), else :walk (in, and decide again in *KK-REACH-RETRY* frames) or, sealed, one Hoho in. The rolls
(*KK-REACH-P*, *KK-HOHO-IN-P*) are made once per approach: it starts at the first such decision and ends when he attacks, leaves the
zone or is no longer free. T / :walk when decided, NIL: the generic CPU decides."
  (let ((hi (second (getf (kit-core kit) :range *cai-range*))) (bk (member (fighter-form f) '(:bankai :bankai-2))))
    (if (not (<= d (max (if bk (max (+ hi 0.6) *kk-bk-walk-range*) (+ hi 0.6))
                        (if (plusp (brain-chance b *kk-blind-p*)) (second *kk-step-in*) 0.0))))   ; (*KK-BLIND-P*: the Step in from her hover)
        (setf (kks-appr st) nil)
        (progn
          (unless (kks-appr st)
            (setf (kks-appr st) t (kks-reach st) (or bk (brain-roll b *kk-reach-p*)) (kks-hin st) (brain-roll b *kk-hoho-in-p*)
                  (kks-blind st) (brain-roll b *kk-blind-p*)))
          (if (not (kks-reach st))
              (setf (kks-appr st) nil)                         ; (this decision is the generic CPU's)
              (let* ((ns (kit-core-move kit :ns (fighter-ptr f))) (q (kit-command-move kit :q))
                     (v (min 0.0 (ken-closing e b s d)))       ; her perceived speed away (m/f, <= 0): only ever stricter
                     (blind (kks-blind st))
                     (can-j (and q (not (and blind (kk-seen-p b s st q)))
                                 (<= (- d (* v (+ (brain-delay b) (mv-s q))))
                                     (+ (kk-reach-of q) (if (and blind (eq (fighter-state f) :run)) *kk-wave-carry* 0.0)))))
                     (can-n (and ns (not bk) (not (and blind (kk-seen-p b s st ns)))
                                 (<= (- d (* v (+ (brain-delay b) (mv-s ns)))) (kk-reach-of ns)))))   ; (a Bankai NS: KK-DECIDE's roll)
                (cond ((and can-n (or (not can-j) (< (sim-rnd01) (if (> d 1.7) *cai-ns-far* *cai-ns-near*))))
                       (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01) (kks-appr st) nil)
                       (cai-sp b f s) t)
                      (can-j (setf (brain-own-key b) -1 (kks-appr st) nil) (cai-press b :quick 1) t)
                      ((and (kks-hin st) (not (eq (fighter-form f) :nozarashi)) (<= d *kk-hoho-in-max*) (hoho-open-p e)
                            (>= (gauges-fs (gauges e)) *kk-hin-fs*))      ; (one Hoho kept in reserve: b0_a1)
                       (setf (kks-hin st) nil)                 ; (one Hoho an approach)
                       (clog "~a kk hoho-in at ~,1f" (side-name e) d)
                       (kk-hoho b) :walk)                      ; (behind her, 1.6 m: the next decision comes as he is free)
                      ((and blind q (not (kk-seen-p b s st q *step-j-cancel*)) (<= (first *kk-step-in*) d (second *kk-step-in*)))
                       (setf (kks-sj st) t (kks-appr st) nil)  ; (J1 is out before she sees it: Step into its reach, KK-STEP-J)
                       (clog "~a kk step-in at ~,1f" (side-name e) d)
                       (ai-press b :step 1) (kk-stick e 1) t)
                      (t (kk-stick e 1) :walk))))))))

(defun kk-neutral (e b f kit s d st)
  "Free: her Getsuga route's answer, the meaty chase, the read, then the decision hook. T when the style decided."
  (when (and (eq (fighter-form f) :base) (gauges-awakened-ok-p e) (not (kks-aw st)))
    (setf (kks-aw st) (if (brain-roll b *kk-awaken-p*) :go :no)))
  (cond ((and (eq (kks-aw st) :go) (eq (fighter-form f) :base) (gauges-awakened-ok-p e)
              (not (kks-plan st)) (not (kk-route-p s)))        ; (not into her live Getsuga route: the cinematic left the wave on him; b3_a1)
         (setf (kks-meaty st) nil)
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

(defun kk-route-as-p (e f st)
  "Her Getsuga route is live as his NA / SA lands (a J cancels a charge but not JUJISHO): take the AS now (AS beats NS). Sealed, or the
Shikai at pointer 1 (AS1), or at pointer 2 short of an L3 plan (the SP there is the burst: it resets L but lands, 94-159; at L3 with a
plan the J string goes on: every Shikai J window cuts the wave). Not a Bankai (its strings are its exit)."
  (case (fighter-form f)
    (:base t)
    (:nozarashi (or (= (fighter-ptr f) 1) (< (ken-lv e) *ken-lv-max*) (not (or (kks-climb st) (kks-bankai st)))))
    (t nil)))

(defun kk-move (e b f s st)
  "In his own NA link or SA, as it lands (or cancels): the next J or the SP by KK-STRING-TARGET; her NS seen, the SP at once
(*KK-AS-READ-P*: the AS beats her NS, as the generic CPU reads). T when it decided."
  (when (and (member (fighter-cls f) '(:na :sa)) (eq (fighter-contact f) :hit) (not (fighter-as-done f))
             (/= (brain-decided b) (fighter-cls-t f)))
    (let ((target (if (and (kk-route-p s) (kk-route-as-p e f st)) 0 (kk-string-target e f st))))   ; (0: the SP now; b3_a0)
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

(defun kk-link-reach (mv)
  "MV's reach + slide + *KK-LINK-MARGIN* (m): the farthest the next link of his NS route still lands from; 0 for none."
  (if (and mv (plusp (mv-reach mv))) (+ (mv-reach mv) (mv-slide mv) *kk-link-margin*) 0.0))

(defun kk-link (e b f kit s d)
  "封印肉搏's route discipline after his own landed sealed NS segment (the segment out, the gap the generic CPU reads): the generic CPU
takes the SA there within 2.6 m at 0.8, but the sealed SA reaches 1.0 m, and the NS1a's 1.2 m slide often leaves her 1.9-2.2 m off: the
SA whiffs and her whiff confirm J1 lands (14 of the baseline's 213 failed exchanges at 20 seeds a seat). Here, one roll per segment
(*KK-LINK-P*): the next segment where it reaches (NS1 a b c, F3), else the SA where it reaches (the route's SA J2-J5 AS3, L1), else
stop (+2 or better on a hit, never a whiff). Her NA in his gap (the SA's read) stays the generic CPU's. T when it decided."
  (let ((mv (fighter-move f)))
    (when (and mv (eq (fighter-form f) :base) (eq (fighter-cls f) :ns) (eq (fighter-contact f) :hit) (plusp (mv-reach mv))
               (/= (brain-decided b) (fighter-cls-t f)) (>= (fighter-sf f) (mv-s mv))
               (not (eq (cai-class-of (fighter-opp f) s) :na)) (brain-roll b *kk-link-p*))
      (let ((nx (mv-ns-next kit mv)) (sa (or (mv-sa-move kit mv) (kit-sa-move kit))))
        (setf (brain-decided b) (fighter-cls-t f))
        (cond ((and nx (<= d (kk-link-reach nx))) (clog "~a kk link NS at ~,1f" (side-name e) d) (cai-press b :quick 1 t))
              ((and sa (<= d (kk-link-reach sa))) (clog "~a kk link SA at ~,1f" (side-name e) d) (cai-press b :quick 1))
              (t (clog "~a kk link stop at ~,1f" (side-name e) d)))
        t))))

(defun kk-as-on (e b f kit)
  "封印肉搏's AS carried through: in his own sealed AS, each segment out (AS2a > b, AS3a > b > c) presses the next one once it lands,
instead of the generic CPU's *CAI-CONT-P* roll per segment (0.85 at HARD: 15-26 % of AS2a / AS3a / AS3b were left there in 20 HARD
matches a seat, him free ~40 frames later at a perceived 1.8 m as her hover backed off, his J1 then whiffing into her punish). A
segment that whiffs stops there. The roll is the segment's own (BRAIN-R-CONT, *KK-AS-ON-P*). T when it decided (pressed, waits for the
contact, or stops)."
  (let ((mv (fighter-move f)))
    (when (and mv (eq (fighter-form f) :base) (eq (fighter-cls f) :as) (mv-ns-next kit mv) (>= (fighter-sf f) (mv-s mv))
               (/= (brain-decided b) (fighter-cls-t f)) (not (vpad-down (pilot-vpad (pilot e)) :quick)))
      (cai-own-rolls b f)
      (when (< (brain-r-cont b) (brain-chance b *kk-as-on-p*))
        (cond ((eq (fighter-contact f) :hit) (setf (brain-decided b) (fighter-cls-t f)) (cai-press b :quick 1 t))
              ((>= (fighter-sf f) (+ (mv-s mv) (mv-a mv))) (setf (brain-decided b) (fighter-cls-t f))))   ; (a whiff: no more)
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

(defun kk-kikon-ptr (f)
  "The pointer whose Kikon count his next SP's hold would take: in an NA link / SA the AS the SP starts (CORE-NEXT-AS; the Shikai's
J4-J6 start the current pointer's special AS, D54 / D55), from neutral the pointer's own NS."
  (if (member (fighter-cls f) '(:na :sa))
      (if (and (eq (fighter-form f) :nozarashi) (>= (fighter-presses f) 4)) (fighter-ptr f) (core-next-as f))
      (fighter-ptr f)))

(defun kk-kikon-rule (b f)
  "An SP pressed this step held into a Kikon (40 frames: CAI-SP's roll, the style's or the generic CPU's) while she is not red: a tap
instead with *KK-KIKON-RED-P* (one roll per such SP). Her style cancels a non-red Kikon's follow-up (0.95 at HARD), which throws away
the SP's knockdown (the meaty loop's start)."
  (when (and (eq (brain-press b) :quick) (brain-press-mod b) (> (brain-press-left b) 1)
             (if (gauges-red-p (gauges (fighter-opp f)))
                 (and (not (and (eql (kk-kikon-ptr f) 2) (member (fighter-form f) '(:base :nozarashi))))
                      (brain-roll b *kk-kikon-ptr-p*))           ; (red: only pointer 2 pays, b1_a0)
                 (brain-roll b *kk-kikon-red-p*)))
    (setf (brain-press-left b) 1)))

(defun ken-ki-style (e b f kit s d)
  "Kenpachi's style against Ichigo (DUEL_MATCHUP_AI §4): T when it decided this step, NIL for the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (null st) (< *match-tick* (kks-tick st))) (setf st (make-kks) (brain-style b) st))
    (setf (kks-tick st) *match-tick*)
    (kk-track e b f kit s d st)
    (let ((state (fighter-state f)))
      (unless (member state '(:idle :run)) (setf (kks-appr st) nil))
      (unless (eq state :step) (setf (kks-sj st) nil))
      (when (and (eq state :step) (kk-step-j e b f kit s d st)) (return-from ken-ki-style t))
      (when (member state '(:idle :run :move))
        (or (if (eq state :move) (or (kk-l3-sa e b f kit d st) (kk-move e b f s st) (kk-link e b f kit s d) (kk-as-on e b f kit)
                                         (kk-ns-whiff e b f kit s))
                (kk-neutral e b f kit s d st))
            (if (eq state :move) (cai-move-step e b f kit s) (cai-neutral e b f kit s d)))   ; (the generic CPU's step, as CORE-BRAIN-STEP)
        (kk-kikon-rule b f)
        t))))

(cai-defstyle :kenpachi :ichigo 'ken-ki-style)

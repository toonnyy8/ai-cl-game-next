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
(defparameter *kk-clone-reach* 7.0
  "封印肉搏's dodge: her KESSA NS3 segments (no hit of their own; a clone appears on f8 and strikes on f15, where his J1 / NS1a on her
cannot stop it: the brawl's answers are skipped for them) are Hohoed through within this distance (m).")
(defparameter *kk-as-read-p* '(:easy 1.0 :normal 1.0 :hard 1.0)
  "In a planned string (KK-MOVE: the climb, L3's J4-J7, the Bankai's), a link that lands or cancels while she is seen in an NS turns to
the SP at once, as the generic CPU's CAI-MOVE-STEP always does (one roll per link, the move's own BRAIN-R-TURN). v0's plans pressed the
next J into her NS / SA. A located v0 bug, found independently by round 1's b1_a0 (*KK-TURN-P*) and b2_a0 (*KK-AS-READ-P*). Since
2026-11-14 a real hit only: a link that took part in a cancel is answered by every CPU's shared exchange (core-ai.lisp CAI-XCH-STEP,
DUEL_AI_STRATEGY §11.18), which runs before this style.")
(defparameter *kk-meaty-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "封印肉搏 / 卍解爆發's chase: per knockdown of hers (one roll as she goes down): walk (or Hoho, from beyond *KK-CHASE-HOHO* m) in and
press J1 to land on her first free frame (K1: 64 a loop; D43 after the Bankai entry). HARD 0.7 -> 1.0, 2026-11-07, cell b0_a0
(round 2): a failed roll left the generic CPU to start NS1a / J1 into her invulnerable wake-up, the move whiffed and her champion's whiff
confirm J1 landed: 35 of the baseline's 213 failed exchanges (20 seeds a seat), 0 after.")
(defparameter *kk-meaty-lead* 0
  "The meaty J1 is pressed when her perceived frames to her first free one are J1's startup + this (0: J1's first active frame on it;
K1 gap 0, K2 12 frames late she acts, D47 too early whiffs on her invulnerable wake-up).")
(defparameter *kk-meaty-near* 2.4 "The meaty chase walks in to this distance (m) and waits (the sealed J reaches 1.8 m + a 0.6 slide). 1.4 -> 2.4 with *KK-MEATY-MIN*, b0_a0 r3.")
(defparameter *kk-meaty-min* 2.25
  "The meaty chase backs off to this distance (m) while she is down (while *KK-MEATY-BACK* frames remain): her champion Hohos at once on
her first free frame within 2.2 m (her *IKS-WAKE-HOHO-NEAR*, HARD 0.9): perfect, his J1 lands but he is locked 40 frames, and her
follow-up J1 started the loop on him (round 3 v4 logs). From 2.25-2.4 m his J1 (1.8 + a 0.6 slide) still meets her first free frame.
0 (none) -> 2.25 with *KK-MEATY-NEAR* 1.4 -> 2.4, 2026-11-07, cell b0_a0 (round 3).")
(defparameter *kk-meaty-back* 16 "The meaty chase backs off only while more than this many frames remain to her first free one (he stands still after, her view is 8 frames old).")
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

(defparameter *kk-ns-safe-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "封印肉搏 / 解放攀升 against her timed Hoho (KK-NS-OPEN-P): per approach (KK-PICK's roll) and per decision of KK-DECIDE's (the climb's
lunge, the Bankai NS), start a neutral NS only while she cannot Hoho it: seen in her own move with more frames left than its startup,
or in her Hoho's lockout (*HOHO-LOCKOUT*) to its first active frame. Else J1 where it reaches, else walk. Her champion (round 2 b1_a1)
Hohos his perceived attack when its first active frame is 1-6 frames off as she sees it (8 frames late): every move with startup 9 or
more. Against round 3's baseline file, 20 seeds a seat HARD: 146 of 180 sealed NS1a and 202 of 304 Shikai lunges were followed by her
perfect Hoho (counter 60, his lock 40, her follow-up: 126k of her 271k). His sealed J1 (S6) is seen after its hit and never timed.
New 2026-11-07, cell b0_a0 (round 3).")
(defparameter *kk-pf-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "封印肉搏's follow-up after his own perfect Hoho (KK-PF-STEP; one roll per such Hoho): her inputs lock 40 frames (*PERFECT-LOCK*),
so J1 at once where it reaches, else walk in, within *KK-PF-WINDOW*. His wake-up Hoho onto her meaty J1 is perfect, but her J1 lands
on that frame and cancels his counter: the generic CPU then waited, and the 40 locked frames went by (round 3 v1 logs). New
2026-11-07, cell b0_a0 (round 3).")
(defparameter *kk-wake-hoho-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "His wake-up (one roll per wake-up): on his first free step, her seen within *KK-WAKE-HOHO-NEAR*, Hoho at once (her own IKS-WAKE,
turned on her meaty J1: it lands on that frame, but the Hoho is perfect, she is locked 40 frames, and KK-PF-STEP's J1 follows). Her
KESSA J1 (S8) meaty is seen too late for KK-READ (her move start is perceived as his first free frame passes): in v5's logs her
meaty-J1 loop on his Shikai ran unanswered, AS3C after AS3C. New 2026-11-07, cell b0_a0 (round 3).")
(defparameter *kk-wake-hoho-near* 2.4 "His wake-up Hoho: she is seen within this distance (m) (her meaty waits at 1.4 m, her KESSA J1 reaches 1.56 m).")
(defparameter *kk-hoho-blind* 8
  "*KK-NS-SAFE-P*: a move whose startup is at most this is never timed by her Hoho (her HARD perception delay is 8 frames, and her
window opens 1 frame before its first active one as she sees it): the sealed J1 (6), KYORAN's J1-J4 (7-8). New 2026-11-07, b0_a0 r3.")
(defparameter *kk-pf-window* 40 "封印肉搏's follow-up: frames from his perfect Hoho's start in which he presses J1 (her lock is 40).")

(defparameter *kk-step-in-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "封印肉搏's way in without an NS (KK-PICK, one roll per approach; sealed, with *KK-NS-SAFE-P*'s roll): out of J1's reach within
*KK-STEP-IN-BAND*, a Step toward her (2.5 m, free, invulnerable frames 3-9; no attack, so her timed Hoho has nothing to read), then J1
out of the Step's J cancel where it reaches (KK-STEP-J). With the NS gated he walked into her 3.7-4.2 m hover, she backed off, and the
first exchange of a match came after 100 s (round 3 v2 logs). New 2026-11-07, cell b0_a0 (round 3).")
(defparameter *kk-hoho-lockout* 84
  "KK-NS-OPEN-P: frames from her seen Hoho's start to her next one (the engine's lock is *HOHO-FRAMES* 24 + *HOHO-LOCKOUT* 60, set at
the Hoho's start). The parent (b0_a0 r3) read only her :hoho state against *HOHO-LOCKOUT* 60: 24 frames short, and nothing once she had
reappeared, though her Hoho stays shut ~60 frames more (its own proposal's open item). Kept per Hoho in KKS-HL. From b3_a0 r3; b0_a1 r3.")
(defparameter *kk-hend-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "Her Hoho seen (a perfect one locks him and leaves this unfired): J1 timed so its hit lands on her first free frame after it (the
Hoho's start + *HOHO-FRAMES*), where she reappears 1.6 m behind him with her next Hoho shut. One roll per her Hoho. From b3_a0 r3 (84
of 91 landed there); b0_a1 r3.")
(defparameter *kk-hend-lead* 0 "*KK-HEND-P*: J1's hit lands this many frames after her Hoho's last frame.")
(defparameter *kk-cine-wait* '(:easy nil :normal nil :hard t)
  "封印肉搏 after a cinematic (read from his own side: the style did not run for over *KK-CINE-GAP* ticks: her KESSA awakening, his own awakening, a Kikon, the
Bankai): no style decision for his perception delay (BRAIN-DELAY), so he acts on a SNAP taken after the cinematic. The cinematic moves
both fighters, and his first free step still saw her where she stood before it: in the parent's logs (HARD, 20 seeds a seat) her KESSA
awakening during his meaty was followed, on the cinematic's last frame, by `kk pick J1 at 1.8` with her really at ~2.4 m (her own view
said 2.4): the sealed J1 whiffed and her whiff confirm J1 opened her combo, 7 of the 40 brawl exchanges lost. He holds still instead
(the generic CPU, which reads the same stale SNAP, is not handed the step either). New, b0_a1 r3.")
(defparameter *kk-cine-gap* 60
  "*KK-CINE-WAIT*: a gap of more than this many ticks since the style last ran is a cinematic (the brain is not stepped through one;
his longest lock otherwise, the perfect lock, is 40). b0_a1 r3.")
(defparameter *kk-repel-wait* 20
  "*KK-CINE-WAIT*'s other case: his own move cut short (his state :idle right after :move, before the move's last frame: her Burst
Reverse or her awakening, REPEL!, which ends his move, makes her invulnerable *BURST-INVULN* 20 frames and slides him 5 m away over
*BURST-PUSH-FRAMES* 20): no style decision for this many frames. In v3's logs (HARD, 20 seeds a seat) 76 of the sealed form's 111
KK-PICK J1s came 11 frames after her Burst, at a perceived 1.5 m: 9 of the 111 hit, 21 were punished. b0_a1 r3.")
(defparameter *kk-face-max* 60.0
  "封印肉搏's follow-ups (KK-PF-STEP after his perfect Hoho, the Hoho-end J1): J1 only while he faces her within this many degrees, else
he stands (the idle auto-turn is 18 deg/frame) and presses once turned. His Hoho puts him behind her and her meaty J1, landing on the
Hoho's frame, leaves him in 36 frames of hitstun without turning: the J1 (arc 100 deg, 6 deg/frame of tracking in its 6-9 frames of
startup) then swung past her. In the parent's logs every pf J1 came 37-38 frames after the perfect, and 19 of 82 whiffed into her
confirm J1 (the sealed J1: 6 of 10). Rule, HARD only (*KK-PF-P* is 0 below). New, b0_a1 r3.")
(defparameter *kk-step-in-band* '(2.2 4.4) "封印肉搏's Step in: the perceived distances (m) it starts from (J1 reaches 2.4 m, the hop 2.5).")

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
  (safe nil) (sin nil)          ; this approach's *KK-NS-SAFE-P* roll; its Step-in roll (unspent) (b0_a0 r3)
  (pf -999 :type fixnum) (pfr nil) ; the start tick of his last perfect Hoho; its follow-up roll said yes (b0_a0 r3)
  (mine :idle)                  ; his own state at his last step (his wake-up's end: b0_a0 r3)
  (pfw nil)                     ; his FIGHTER-PERFECT at his last step
  (fresh -1 :type fixnum)
  (msf 0 :type fixnum) (mend 0 :type fixnum) ; his own move's frame at his last step and its length (a cut move: *KK-REPEL-WAIT*)       ; no decision before this tick: a cinematic just ended (*KK-CINE-WAIT*; b0_a1 r3)
  (hl -999 :type fixnum)        ; the tick her last seen Hoho's lockout ends (its start + *KK-HOHO-LOCKOUT*) (b0_a1 r3, from b3_a0 r3)
  (tick 0 :type fixnum))
(inline-readers kks)        ; *MATCH-TICK* at his last free step (a lower one: a new match, the state starts over)

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
      (cond ((not (style-roll b :kk-wave-p *kk-wave-p*)) nil)
            ((hoho-ready-p e) :close)
            ((not (eq (fighter-form f) :base)) :cut)
            ((plusp (getf *kk-wave-mix* :step 0.0)) :step))))
  (let* ((far (>= d (first *kk-wave-band*)))
         (lunge (<= d (kk-reach kit f :ns)))
         (wc (cond ((or (not far) lunge) 1.0) ((> d *kk-wave-close-max*) 0.0) (t (getf *kk-wave-mix* :close 0.0))))
         (wk (if (or (not far) lunge (eq (fighter-form f) :base)) 0.0 (getf *kk-wave-mix* :cut 0.0)))
         (wl (if (and far (not lunge) (hoho-ready-p e)) (getf *kk-wave-mix* :late 0.0) 0.0))
         (ws (if (and far (not lunge) (not (hoho-ready-p e)) (eq (fighter-form f) :base)) (getf *kk-wave-mix* :step 0.0) 0.0))
         (sum (+ wc wk wl ws)))
    (when (and (plusp sum) (style-roll b :kk-wave-p *kk-wave-p*))
      (let ((r (* sum (sim-rnd01))))
        (cond ((< r wc) :close) ((< r (+ wc wk)) :cut) ((< r (+ wc wk wl)) :late) (t :step))))))

(defun kk-track (e b f kit s d st meaty)
  "The events, once each: a new form stay (the climb roll), L3 reached (the Bankai roll), her knockdown (the meaty roll, chance MEATY:
KEN-KI-STYLE's), her Getsuga route (the answer's roll)."
  (let ((form (fighter-form f)) (ss (snap-state s)))
    (unless (eq form (kks-form st))
      (setf (kks-form st) form (kks-l3 st) nil (kks-bankai st) nil (kks-bk-n st) 0
            (kks-climb st) (and (eq form :nozarashi) (style-roll b :kk-climb-p *kk-climb-p*)))
      (when (kks-climb st) (clog "~a kk climb" (side-name e))))
    (when (eq form :nozarashi)
      (if (>= (ken-lv e) *ken-lv-max*)
          (unless (kks-l3 st)
            (setf (kks-l3 st) t (kks-bankai st) (style-roll b :kk-bankai-p *kk-bankai-p*))
            (when (kks-bankai st) (clog "~a kk bankai-plan" (side-name e))))
          (setf (kks-l3 st) nil (kks-bankai st) nil)))
    (when (and (member ss '(:air :down)) (not (member (kks-was st) '(:air :down :wakeup))))
      (setf (kks-meaty st) (chance-roll meaty))
      (when (kks-meaty st) (clog "~a kk meaty armed" (side-name e))))
    (unless (member ss '(:air :down :wakeup)) (setf (kks-meaty st) nil))
    (when (eq ss :hoho)                                         ; her Hoho seen: its start = now - delay - her frame (b3_a0 r3)
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
      (setf (kks-plan st) nil)
      (kk-attack-in e b f s (if (plusp rn) :ns :j))
      t)))

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
    (case plan
      (:close
       (cond ((kk-close-hit e b f kit s d st))                 ; in reach now (the Shikai's lunge from 5.3 m, F15; a run's carry)
             ((hoho-ready-p e) (setf (kks-plan st) :hit) (kk-hoho b) t)
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
                        (:late (if (hoho-ready-p e) (kk-hoho b) (setf plan nil (kks-plan st) nil)) (kk-stick e 0))
                        (t (ai-press b :step 1) (kk-stick e 1)))   ; (:step: the hop toward her, through the wave)
                      (and plan t))))))
      (:chase (kk-chase-step e b f kit s d st))
      (:stepin (setf (kks-plan st) nil) nil)
      (:hend                                                    ; J1 onto her Hoho's end (*KK-HEND-P*; b3_a0 r3)
       (cond ((not (member (snap-state s) '(:hoho :idle :run))) (setf (kks-plan st) nil) nil)
             ((< *match-tick* (kks-at st)) (kk-stick e 0) t)
             ((and (not (kk-facing-p e s)) (<= *match-tick* (+ (kks-at st) 2))) (kk-stick e 0) t)   ; (turn first: b0_a1 r3)
             (t (setf (kks-plan st) nil)
                (when (and (<= *match-tick* (+ (kks-at st) 2)) (<= d (kk-reach kit f :j)))
                  (setf (brain-own-key b) -1)
                  (clog "~a kk hoho-end J1 at ~,1f" (side-name e) d)
                  (cai-press b :quick 1) (kk-stick e 0) t))))                    ; (the Step is over: KK-STEP-J pressed J1 or he is nearer)
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
                (when (hoho-ready-p e) (clog "~a kk dodge at ~,1f" (side-name e) d) (kk-hoho b) t))))
      (t nil))))

(defun kk-step-j (e b f kit d st)
  "破月牙 :chase after the Step through the wave: J1 pressed 2 frames before the Step's J cancel (*STEP-J-CANCEL* 12; the latch starts
it there) when she is in its reach, instead of waiting out the Step's 24 frames (one sample: his J1 came out 1 frame after her next
move started, the situation lost). Once per Step (its one frame). T when it pressed. b3_a1, 2026-11-06."
  (when (and (member (kks-plan st) '(:chase :stepin)) (= (fighter-sf f) (- *step-j-cancel* 2)) (<= d (kk-reach kit f :j)))
    (setf (kks-plan st) nil (brain-own-key b) -1)
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
    (cond ((and q (<= left (+ (mv-s q) *kk-meaty-lead*)))
           (setf (kks-meaty st) nil)
           (when (<= d (+ (mv-reach q) (mv-slide q) 0.2))
             (setf (brain-own-key b) -1)
             (clog "~a kk meaty J1 left ~d" (side-name e) left)
             (cai-press b :quick 1))
           (kk-stick e 0))
          ((and (> d *kk-chase-hoho*) (> left 30) (hoho-ready-p e)) (kk-hoho b))
          ((> d *kk-meaty-near*) (kk-stick e 1))
          ((and (< d *kk-meaty-min*) (> left *kk-meaty-back*)) (kk-stick e -1))   ; (out of her wake-up Hoho's reach: b0_a0 r3)
          (t (kk-stick e 0)))
    t))

(defun kk-read (e b f kit s d st)
  "封印肉搏's read on her new move start. Sealed within *KK-READ-RANGE*: the tame, J1 or NS1a (*KK-BRAWL-P*). Else (beyond it, the
Shikai, or no answer fits) while her move can reach him: Hoho through it (*KK-DODGE-P*, one roll per her move start), timed by
*KK-DODGE-LEAD*. T when it pressed or planned."
  (let* ((form (fighter-form f)) (mv (snap-move s)) (rr (style-knob b :kk-read-range *kk-read-range*))
         (clone (and mv (eq (snap-state s) :move) (eq (cai-class-of (fighter-opp f) s) :ns) (zerop (length (mv-hits mv)))
                     (not (kk-route-p s)))))                    ; (KESSA's NS3 a-c: no hit of its own, a clone strikes on f15)
    (when (and (eq (snap-state s) :move) mv (/= (snap-start s) (kks-ev st))
               (<= d (if clone *kk-clone-reach* (max rr (+ (mv-reach mv) (mv-slide mv) *kk-dodge-reach*)))))
      (setf (kks-ev st) (snap-start s))
      (let ((cls (cai-class-of (fighter-opp f) s)) (left (- (snap-s s) (snap-sf s) (brain-delay b)))   ; frames to her hit
            (q (kit-command-move kit :q)) (ptr (fighter-ptr f)))
        (when (and q (member cls '(:na :ns)))
          (let ((how (and (eq form :base) (not clone) (<= d rr) (style-roll b :kk-brawl-p *kk-brawl-p*)
                          (progn
                            (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01))
                            (cond ((and (= ptr 3) (<= 3 left 27) (not (kk-route-p s))) (cai-sp b f s) :tame)                  ; the tame catches it (F7-F9)
                                  ((and (> left (mv-s q)) (<= d (+ (mv-reach q) (mv-slide q)))) (cai-press b :quick 1) :j1)   ; J1 first (F1, F2)
                                  ((and (= ptr 1) (eq cls :ns) (> left 14)) (cai-sp b f s) :ns1a))))))   ; NS1a first (F3)
            (when (and (not how) (not (kk-route-p s)) (>= left 0))   ; (her hit already past as seen: no dodge; b0_a0 r3)
              (cond ((hoho-ready-p e)
                     (when (style-roll b :kk-dodge-p *kk-dodge-p*)
                       (if (<= 0 left *kk-dodge-lead*)        ; (due now: pressed on this step, not the next; b0_a0 r3)
                           (progn (clog "~a kk dodge now at ~,1f" (side-name e) d) (kk-hoho b) (setf how :dodge))
                           (setf (kks-plan st) :dodge (kks-at st) (+ *match-tick* (max 0 (- left *kk-dodge-lead*))) how :dodge))))
                    ((and (<= d (style-knob b :kk-step-max *kk-step-max*)) (style-roll b :kk-step-p *kk-step-p*))   ; (no Hoho open: the back Step)
                     (let ((sl (if clone (- left (- (snap-s s) *kk-clone-strike*)) left)))
                       (if (<= 0 sl *kk-step-lead*)
                           (progn (clog "~a kk step-dodge now at ~,1f" (side-name e) d) (ai-press b :step 1) (setf how :sdodge))
                           (setf (kks-plan st) :sdodge (kks-at st) (+ *match-tick* (max 0 (- sl *kk-step-lead*))) how :sdodge))))))
            (when how
              (clog "~a kk read ~a ~a left ~d at ~,1f" (side-name e) how cls left d)
              (kk-stick e 0)
              t)))))))

(defun kk-decide (e b f s d st safe)
  "A neutral decision the generic CPU would make this step, taken by the style when a roll says so (SAFE: the Hoho-safety roll's chance,
KEN-KI-STYLE's). T when it decided."
  (let* ((form (fighter-form f)) (vp-free (member (fighter-state f) '(:idle :run)))
         (ns (kit-core-move (fighter-kit f) :ns (fighter-ptr f)))
         (q (kit-command-move (fighter-kit f) :q)) (safe (chance-roll safe))
         (ns-ok (or (null ns) (not safe) (kk-ns-open-p b s st ns)))   ; (b0_a0 r3: not into her timed Hoho)
         (j-ok (or (null q) (not safe) (kk-ns-open-p b s st q))))
    (when vp-free
      (case form
        (:nozarashi
         (let ((lv (ken-lv e)))
           (cond ((and ns-ok (kks-climb st) (< lv *ken-lv-max*) (= (fighter-ptr f) 1)
                       (<= (first *kk-lunge-band*) d (second *kk-lunge-band*)) (style-roll b :kk-lunge-p *kk-lunge-p*))
                  (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01))
                  (cai-sp b f s) t)
                 ((and (>= lv *ken-lv-max*) (or (kks-climb st) (kks-bankai st)) (<= d *kk-l3-range*)   ; at L3 with a plan: the J string
                       j-ok)
                  (setf (brain-own-key b) -1)
                  (cai-press b :quick 1) t))))
        ((:bankai :bankai-2)
         (let ((spare (> (reishi-frac (gauges e)) (+ *kk-bk-floor* *kk-bk-ns-spare*))))
           (cond ((and ns-ok spare (<= d *kk-bk-ns-range*) (style-roll b :kk-bk-ns-p *kk-bk-ns-p*))
                  (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01))
                  (cai-sp b f s) t))))))))   ; (else KK-PICK: J1 in reach, a Hoho or a walk in; no generic NS at 40 a segment)

(defun kk-ns-open-p (b s st mv)
  "May his move MV start now without her timed Hoho on it (*KK-NS-SAFE-P*)? Its startup is within *KK-HOHO-BLIND* (seen after its
hit), or she is seen in her own move with more frames left than its startup, down, or in a Hoho whose lockout lasts to its first
active frame (KKS-HL, *KK-HOHO-LOCKOUT*: also after she reappears; b0_a1 r3)."
  (if (<= (mv-s mv) *kk-hoho-blind*)
      t
      (or (>= (- (kks-hl st) *match-tick*) (mv-s mv))
          (case (snap-state s)
            (:move (> (- (snap-left s) (brain-delay b)) (mv-s mv)))
            ((:air :down :stun) t)
            (t nil)))))

(defun kk-facing-p (e s)
  "Does he face her (her perceived position) within *KK-FACE-MAX* degrees?"
  (<= (abs (angle-wrap (f32 (- (face-yaw-to e (snap-x s) (snap-z s)) (yaw-of e))))) (deg *kk-face-max*)))

(defun kk-pf-step (e b f kit s d st)
  "封印肉搏's follow-up after his own perfect Hoho (*KK-PF-P*): J1 where it reaches, else walk in, inside *KK-PF-WINDOW*. T when it
decided."
  (when (kks-pfr st)
    (let ((q (kit-command-move kit :q)))
      (cond ((or (null q) (> (- *match-tick* (kks-pf st)) *kk-pf-window*)) (setf (kks-pfr st) nil) nil)
            ((not (kk-facing-p e s)) (kk-stick e 0) t)             ; (turn first: b0_a1 r3)
            ((<= d (+ (mv-reach q) (mv-slide q)))
             (setf (kks-pfr st) nil (brain-own-key b) -1)
             (clog "~a kk pf J1 at ~,1f" (side-name e) d)
             (cai-press b :quick 1) (kk-stick e 0) t)
            (t (kk-stick e 1) t)))))

(defun kk-reach-of (mv margin)
  "MV's reach + slide less MARGIN (m; *KK-REACH-MARGIN* or the arm's): the farthest it starts from; 0 for a move that reaches nothing (the tame)."
  (if (and mv (plusp (mv-reach mv))) (- (+ (mv-reach mv) (mv-slide mv)) margin) 0.0))

(defun kk-pick (e b f kit s d st safe)
  "封印肉搏's discipline at a neutral decision inside the generic CPU's attack zone: J1 or the pointer's NS only where it reaches (the
generic's NS / J odds between them), else :walk (in, and decide again in *KK-REACH-RETRY* frames) or, sealed, one Hoho in. The rolls
(*KK-REACH-P*, *KK-HOHO-IN-P*) are made once per approach: it starts at the first such decision and ends when he attacks, leaves the
zone or is no longer free. T / :walk when decided, NIL: the generic CPU decides."
  (let ((hi (second (getf (kit-core kit) :range *cai-range*))) (bk (member (fighter-form f) '(:bankai :bankai-2))))
    (if (not (<= d (if bk (max (+ hi 0.6) *kk-bk-walk-range*) (+ hi 0.6))))
        (setf (kks-appr st) nil)
        (progn
          (unless (kks-appr st)
            (setf (kks-appr st) t (kks-reach st) (or bk (style-roll b :kk-reach-p *kk-reach-p*)) (kks-hin st) (style-roll b :kk-hoho-in-p *kk-hoho-in-p*)
                  (kks-safe st) (chance-roll safe) (kks-sin st) (style-roll b :kk-step-in-p *kk-step-in-p*)))
          (if (not (kks-reach st))
              (setf (kks-appr st) nil)                         ; (this decision is the generic CPU's)
              (let* ((ns (kit-core-move kit :ns (fighter-ptr f))) (q (kit-command-move kit :q))
                     (v (min 0.0 (ken-closing e b s d)))       ; her perceived speed away (m/f, <= 0): only ever stricter
                     (rm (style-knob b :kk-reach-margin *kk-reach-margin*))
                     (can-j (and q (<= (- d (* v (+ (brain-delay b) (mv-s q)))) (kk-reach-of q rm))
                                 (or (not (kks-safe st)) (kk-ns-open-p b s st q))))   ; (the Shikai J1 is S9: b0_a0 r3)
                     (can-n (and ns (not bk) (<= (- d (* v (+ (brain-delay b) (mv-s ns)))) (kk-reach-of ns rm))   ; (a Bankai NS: KK-DECIDE's roll)
                                 (or (not (kks-safe st)) (kk-ns-open-p b s st ns)))))   ; (not into her timed Hoho: b0_a0 r3)
                (cond ((and can-n (or (not can-j) (< (sim-rnd01) (if (> d 1.7) *cai-ns-far* *cai-ns-near*))))
                       (setf (brain-own-key b) -1 (brain-r-kikon b) (sim-rnd01) (kks-appr st) nil)
                       (clog "~a kk pick NS at ~,1f" (side-name e) d)
                       (cai-sp b f s) t)
                      (can-j (setf (brain-own-key b) -1 (kks-appr st) nil) (clog "~a kk pick J1 at ~,1f" (side-name e) d)
                             (cai-press b :quick 1) t)
                      ((and (kks-hin st) (not (eq (fighter-form f) :nozarashi)) (<= d (style-knob b :kk-hoho-in-max *kk-hoho-in-max*)) (hoho-ready-p e)
                            (>= (gauges-fs (gauges e)) (style-knob b :kk-hin-fs *kk-hin-fs*)))      ; (one Hoho kept in reserve: b0_a1)
                       (setf (kks-hin st) nil)                 ; (one Hoho an approach)
                       (clog "~a kk hoho-in at ~,1f" (side-name e) d)
                       (kk-hoho b) :walk)                      ; (behind her, 1.6 m: the next decision comes as he is free)
                      ((and (kks-sin st) (kks-safe st) (eq (fighter-form f) :base)
                            (<= (first *kk-step-in-band*) d (second *kk-step-in-band*)))
                       (setf (kks-sin st) nil (kks-plan st) :stepin)   ; (KK-STEP-J presses J1 out of the cancel)
                       (clog "~a kk step-in at ~,1f" (side-name e) d)
                       (ai-press b :step 1) (kk-stick e 1) :walk)
                      (t (kk-stick e 1) :walk))))))))

(defun kk-neutral (e b f kit s d st safe)
  "Free: her Getsuga route's answer, the meaty chase, the read, then the decision hook (SAFE: KK-DECIDE's and KK-PICK's). T when the style
decided."
  (when (and (eq (fighter-form f) :base) (gauges-awakened-ok-p e) (not (kks-aw st)))
    (setf (kks-aw st) (if (style-roll b :kk-awaken-p *kk-awaken-p*) :go :no)))
  (cond ((and (eq (kks-aw st) :go) (eq (fighter-form f) :base) (gauges-awakened-ok-p e)
              (not (kks-plan st)) (not (kk-route-p s)))        ; (not into her live Getsuga route: the cinematic left the wave on him; b3_a1)
         (setf (kks-meaty st) nil)
         (clog "~a kk awaken" (side-name e))
         (ai-press b :awaken 1 :modded t) t)
        ((kks-plan st) (kk-wave-step e b f kit s d st))
        ((kks-meaty st) (kk-meaty-step e b f kit s d st))
        ((kk-pf-step e b f kit s d st))
        ((kk-read e b f kit s d st))
        ((<= (brain-decide-t b) 1)                              ; the generic CPU decides this step: the style may take it
         (let ((how (or (and (not (kks-appr st)) (kk-decide e b f s d st safe)) (kk-pick e b f kit s d st safe))))   ; (no re-rolls on a retry)
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
      (when (< (brain-r-turn b) (style-dif b :kk-ns-stop-p *kk-ns-stop-p*))  ; (the move's own roll, made once at its start)
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
               (not (eq (cai-class-of (fighter-opp f) s) :na)) (style-roll b :kk-link-p *kk-link-p*))
      (let ((nx (mv-ns-next kit mv)) (sa (or (mv-sa-move kit mv) (kit-sa-move kit))))
        (setf (brain-decided b) (fighter-cls-t f))
        (cond ((and nx (<= d (kk-link-reach nx)) (cai-next-ok-p e kit mv)) (clog "~a kk link NS at ~,1f" (side-name e) d) (cai-press b :quick 1 t))
              ;; (the next segment refused at 0, CAI-NEXT-OK-P: the style's own fallback below, the SA where it reaches, S7)
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
      (when (< (brain-r-cont b) (style-dif b :kk-as-on-p *kk-as-on-p*))
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
                      (style-roll b :kk-kikon-ptr-p *kk-kikon-ptr-p*))           ; (red: only pointer 2 pays, b1_a0)
                 (style-roll b :kk-kikon-red-p *kk-kikon-red-p*)))
    (setf (brain-press-left b) 1)))

(defun ken-ki-style (e b f kit s d &key meaty safe)
  "Kenpachi's style against Ichigo (DUEL_MATCHUP_AI §4): T when it decided this step, NIL for the generic core CPU. MEATY / SAFE: the meaty
roll's and the Hoho-safety roll's chances by difficulty, which a style built on this one may pass (cpu-kh-ken.lisp: its wake-up bait and
stand-off breaker; they rebound the two knobs until 2026-11-13, REFACTOR_2026-11 R12); NIL: *KK-MEATY-P* / *KK-NS-SAFE-P*, or the arm's
:KK-MEATY-P / :KK-NS-SAFE-P (STYLE-DIF). A chance passed beats the arm's key."
  (let ((st (brain-style b))
        (meaty (if meaty (brain-chance b meaty) (style-dif b :kk-meaty-p *kk-meaty-p*)))   ; (the two chances, once a step)
        (safe (if safe (brain-chance b safe) (style-dif b :kk-ns-safe-p *kk-ns-safe-p*))))
    (when (or (null st) (< *match-tick* (kks-tick st))) (setf st (make-kks) (brain-style b) st))
    (when (and (> (- *match-tick* (kks-tick st)) *kk-cine-gap*) (brain-chance b *kk-cine-wait*))   ; (a cinematic just ended: b0_a1 r3)
      (setf (kks-fresh st) (+ *match-tick* (brain-delay b))))
    (let ((mv (fighter-move f)))                              ; (his move cut short: a repel; b0_a1 r3)
      (if (and (eq (fighter-state f) :move) mv)
          (setf (kks-msf st) (fighter-sf f) (kks-mend st) (+ (mv-s mv) (mv-a mv) (mv-r mv)))
          (progn
            (when (and (eq (kks-mine st) :move) (member (fighter-state f) '(:idle :run)) (< (kks-msf st) (- (kks-mend st) 2))
                       (brain-chance b *kk-cine-wait*))
              (setf (kks-fresh st) (max (kks-fresh st) (+ *match-tick* *kk-repel-wait*))))
            (setf (kks-mend st) 0))))
    (setf (kks-tick st) *match-tick*)
    (kk-track e b f kit s d st meaty)
    (when (and (< *match-tick* (kks-fresh st)) (member (fighter-state f) '(:idle :run)))
      (kk-stick e 0)
      (return-from ken-ki-style t))
    (let ((state (fighter-state f)))
      (let ((p (fighter-perfect f)))                          ; (his new perfect Hoho: the flag stays until his next move, even when
        (when (and p (not (kks-pfw st)))                       ;  her meaty J1 lands on the Hoho's frame; one roll)
          (setf (kks-pf st) *match-tick* (kks-pfr st) (brain-roll b *kk-pf-p*)))
        (setf (kks-pfw st) p))
      (unless (member state '(:idle :run)) (setf (kks-appr st) nil))
      (when (and (eq (kks-mine st) :wakeup) (member state '(:idle :run)) (<= d *kk-wake-hoho-near*) (hoho-ready-p e)
                 (not (eq (snap-state s) :hoho)) (style-roll b :kk-wake-hoho-p *kk-wake-hoho-p*))
        (setf (kks-mine st) state)
        (clog "~a kk wake-hoho at ~,1f" (side-name e) d)
        (kk-hoho b)
        (return-from ken-ki-style t))
      (setf (kks-mine st) state)
      (when (and (eq state :step) (kk-step-j e b f kit d st)) (return-from ken-ki-style t))
      (when (member state '(:idle :run :move))
        (or (if (eq state :move) (or (kk-l3-sa e b f kit d st) (kk-move e b f s st) (kk-link e b f kit s d) (kk-as-on e b f kit)
                                         (kk-ns-whiff e b f kit s))
                (kk-neutral e b f kit s d st safe))
            (if (eq state :move) (cai-move-step e b f kit s) (cai-neutral e b f kit s d)))   ; (the generic CPU's step, as CORE-BRAIN-STEP)
        (kk-kikon-rule b f)
        t))))

(cai-defstyle :kenpachi :ichigo 'ken-ki-style)

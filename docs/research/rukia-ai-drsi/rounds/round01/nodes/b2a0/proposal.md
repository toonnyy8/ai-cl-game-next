# b2a0 (round 1): the distance bands. Meet his Step in, seal the knockdown at mid range, punish by distance

Primary axis (the brief): the distance bands (spacing, the kido and the seal at mid range, neutral to close). PARENT_DIR:
none, so I started from the frozen file. History read: BASELINE_DIR (0.5898) and the two finished round-1 cells, b0a0
(matchup tables, rescored 0.7154) and b1a0 (value tables for the confirm, the cash and the envelope, rescored 0.7506).
Planning base read: `docs/research/rukia-cpu/` (sheet-shikai, matchups-shikai, strategy-shikai, both catalogues, the
opponents' sheets), rukia.lisp, ai.lisp.

## Result (EVAL_COMMAND `python3 tools/aieval.py --char 2 --seeds 40 -j 2`, the final file)

| | baseline | b0a0 | b1a0 | **b2a0** |
|---|---|---|---|---|
| **score** | 0.5898 | 0.7154 | 0.7506 | **0.8421** |
| strength | 0.273 | 0.325 | 0.410 | **0.671** |
| masher | 1.0 | 1.0 | 1.0 | 1.0 |
| signature | 0.616 | 0.836 | 0.855 | **0.882** |
| NORMAL share (band 0.30-0.60) | 0.423 | 0.4375 | 0.492 | 0.527 (factor 1) |
| pacing (NORMAL P1 medians, all K.O.) | 100.8-140.4 s | 97.5-149.6 s | 101.9-146.7 s | 91.7-150.2 s |

str_by_opp (HARD, both seats, of 80): Yamamoto 29 -> **71**, Kenpachi 0 -> 9, Ichigo 58 -> **80**, Senjumaru 44 -> **67**,
Lille 0 -> 16, Hisagi 0 -> **79**. NORMAL by_opp: Lille 43, Hisagi 42, Ichigo 48, Kenpachi 32, Senjumaru 48, Yamamoto 40.
sig_by: kstring 0.323, burst 0.215, poke 0.187, kido 0.087, **seal 0.070** (baseline 0.002), counter 0.067, Breaker 0.017,
plain O 0.014 (0.097), the bands' O 0.021, plain J 0.000 (0.094).

**Paired, final vs baseline** (my runner over the native sim: the same seeds and seats, 240 HARD matches a block, the
frozen evaluator's classes): seeds 1-20: 69 -> 162 (+0.388, SE 0.034, z 11.3); seeds 21-40: 62 -> 160 (+0.408, SE 0.035,
z 11.5). I stopped there because both blocks were far past 2 SE.

## Step 1. The history, and what I took from it

- **Baseline**: the AI v2 counter-fighter. Diagnosis (combat logs with each move start's distance, 240 matches): **the
  opponents' damage is almost all from openers inside 2.4 m**, and their most common opener is the generic **Step -> J**
  (a hop from 2-4 m, J latched at f12). Hisagi got 65,000 damage from it in 20 seeds, Ichigo 29,000, Yamamoto 17,000,
  Senjumaru 6,000. Kenpachi's FIRST-STRIKE J1 plays the same role for him. Her own best opener was the same Step -> J.
  Mid and long range decided little, except Hisagi's 6 m K1 and Lille's snipes.
- **b0a0 / b1a0 located bugs, and I fixed the same ones** (they are bugs, not ideas): RIKUJOKORO's bind was cashed with SP2
  and never with the O (seal 0.2 %); the plain O ender and the O cash went into a victim who wasn't red (non-signature,
  and his blocked follow-up was punished); J links were used where K links combo. So: `:o-ender 0.0` in the Shikai,
  `*AI-RU-ENDER-O*` / `*AI-RU-CASH-O*` 0, `:string-k 1.0` in **every** form (the bands' J2 / J3 are plain J, their K
  links are signature: +10 wins of 240 and +0.04 signature), and the seal's O (`RUKIA-AI-SEAL`). On their own (my F0)
  these cost strength (69 -> 58 of 240) and raised the signature 0.61 -> 0.77. The gain comes from what is built on them.
- **Not repeated**: b0a0's per-opponent hand-set rows and its anti-approach kido. b0a0 found that one fed the perfect Hoho;
  my kido fires only into committed / held opponents. b1a0's confirm value table and envelope table at neutral decisions:
  my answer to the close band is an event reflex on his Step's frame 1, not a decision-time envelope.

## Step 2. From the frame data: the two findings that carry the score

1. **The Step in is readable and beatable** (measured in the sim, debug trace): the hop covers 0.27 m/f and lands at
   f10-11, about 2.7 m on. His J1 is latched at f12 and hits at f19-20. A HARD brain (delay 8) sees the Step's frame 1 at
   real f9. Her J1 (7 f) pressed then is active at f16-18, **before his J1**. It lands whenever the hop brings him inside
   her J1's reach, i.e. when he started within about 4.2 m. NORMAL's 14 f delay is too late (f22-24), so this belongs to
   HARD alone, and NORMAL's band is untouched by it.
2. **白漣's knockdown -> RIKUJOKORO is a true combo into the seal** (combo-trial, new; trials in my scratch dir):
   K1 K2 K3 +L 白漣 knocks him down at ~4.35 m, +50 with his wake-up. SP1 held H frames, pressed P frames before he is
   free, with **P - H in 13..17**, lays the bind on his first vulnerable frame: **gap 0** against Kenpachi, Hisagi, Lille
   and Ichigo (H 33-37 from her first free frame; 38 gives a 1 f gap, 24 is too early and misses through his wake-up
   iframes). Then the O lands sealed, so **the Kikon from full health: -2 Konpaku, his Reishi refilled**, for one bar.
   With no bar, TSUKISHIRO pressed 50 frames before he rises puts its pillar on his wake-up (gap 0: 60 + 2 layers, +26).
   So every completed K route is worth the route (302-331) **plus 2 Konpaku**: the K string, the burst, the kido and the
   seal (four of the five signature themes) in one sequence.

## Step 3. The tactics by condition (all in duel/lisp/rukia-ai.lisp)

### A. The close band: his Step in, met (RUKIA-AI-ANTI-STEP; *AI-RU-ANTI-STEP* EASY 0 / NORMAL 0.3 / HARD 1.0)

| condition (perceived) | tactic |
|---|---|
| he is in `:step`, seen at its frame 1, closing > 0.15 m/f (a hop toward her), landing d - 2.4 <= her J1 reach + 0.4, her J1's active frames before his Step's J (at f12 + his J1's S) | J1 now, then J1 K2s K3 +L 白漣 and the oki |
| a back hop, a side Step, a dash from beyond 4.2 m (the hop lands outside her reach, then he runs) | nothing (the first try, a linear speed model, fired on dashes and whiffed: 86 vs 87 of 240) |

One roll per Step (frame 1 happens once per Step). This is one option, not a weighted pick: the alternatives (guard,
back hop) only hand him the turn, since his blocked J1 is -2 and his J chain goes on. Hit rate of the J1 (240 matches):
Hisagi 139/139, Ichigo 129/131, Kenpachi 98/101, Yamamoto 135/147 (11 blocked), Senjumaru 68/86, Lille 10/21 (his
stance steps differ). HARD 0.85 -> 1.0: +14 wins of 480 (z 2.5).

### B. The mid band after the knockdown: the oki seal (RUKIA-AI-OKI; *AI-RU-OKI* 0 / 0.4 / 0.95, one roll a knockdown)

| condition | tactic |
|---|---|
| he is down by her own hit (felt at once), she is free, d < 5.8 m, a bar, P - 15 >= 18 (P: his frames until free, from the perceived `:down` / `:wakeup` frame + her delay) | SP1 held P - 15 frames: RIKUJOKORO's bind on his wake-up, then the seal's O (RUKIA-AI-SEAL: 0.3 / 0.7 / 1.0, the Kikon) |
| no bar | TSUKISHIRO pressed at P = 48..51 (`:WAIT` until then): the pillar on his wake-up |
| he is still seen reeling from the hit that knocked him down | `:WAIT` (the shipped generic stun follow-up pressed SP2 into the knockdown and lost the bar) |
| a Soul Break due (AI-SB-FINISH-P) | nothing: finish with hits |

Measured alternatives: **a pick weighted by value between the seal and TSUKISHIRO** (the seal = 2 Konpaku x 433 less the
Reishi it refills, against 150; k = 2) cost **-14 HARD wins of 480 (z -3.2)**. The seal is worth more than any damage
model of it I wrote, so it is always taken when it is available. A floor on its value (> 150 or > -300) tied with no floor,
so I kept the simpler file without one. **The bar is kept for the seal**: `:sp-cancel-bars 2` (SP cancels, the cash's SP2,
the J ender's SP2 only with 2 bars), SOKATSUI's neutral tap only with 2 bars, the SPs out of the Shikai's `:moves`
(+4 of 240, signature +0.01). K3 -> 白漣 *AI-RU-BURST-3* HARD 0.85 -> 0.95.

### C. The range punish by distance (RUKIA-AI-RANGE-PUNISH; *AI-RU-RANGE-P* 0 / 0.4 / 0.95 a move of his; one pick ~ value^k, *AI-RU-SHARP* 1 / 1 / 2)

His move is seen recovering (frames left L, seen), or **held**: a :sig / :sp of his in its hold phase, or in its main
phase with 40+ f left and no hit within reach + 1 m of her (Lille's KAMAE, a charge; never a ranged or :x-axis move;
counted as L = 34). Each of her means that reaches from D and strikes within L is an option:

| option | D (m) | L needed | value |
|---|---|---|---|
| J1 -> the K route | < 1.7 | 8 | route = 331 + the oki (the seal's value with a bar, else 150) |
| K1 -> the K route | 0.6-2.85 | 18 | route + 26 |
| the Step in (-> Step J) | 2.0-3.9 | 21 | 0.8 x route |
| SHIRAFUNE (2 bars) | 0.5-5.0 | 17 | 110 + 25 a layer |
| SOKATSUI (2 bars) | < 4.5 | 15 | 90 |
| BYAKURAI | 0.8-6.0 | 13 | 45 |
| RIKUJOKORO (a bar) | 4.5-5.9 | the bind's hold + 16 | 0.9 x the seal's value |
| TSUKISHIRO | 6.0-8.0 | 38 | 150 |

The range punish on recoveries alone tied (86 vs 87 of 240). The held-stance read added +5 of 240, almost all against
Lille: 2 -> 10 of 40, BYAKURAI into his KAMAE 622 hits of 850. Counting a stance as 50 frames, so that RIKUJOKORO and
TSUKISHIRO become options, lost 7 of 240 (Lille 10 -> 0: he moves out before the bind or the pillar).

### D. The neutral bands and the bind's hold

- RIKUJOKORO's hold by distance (RUKIA-AI-SP1-HOLD): 16 f + 2 + max(0, 26 + the O's frames from D + 4 - 44). The bind then
  outlasts her recovery (26) plus the O's dash from D (RUKIA-AI-O-FRAMES: 25 f from 6 m), so every bind, neutral or oki,
  can be sealed.
- **Spacing by the intent ranges is a tie.** I tried three: a HOME band outside his Step-in reach (approach 4.1-5.6, defend
  4.4-6.2) gave 87 vs 87; standing inside his Step-in band to bait it gave 141 vs 154 (-13, Senjumaru and Lille); the
  shipped ranges gave 304 vs 301 of 480 against HOME. So I kept the shipped ranges. Where she stands mattered far less
  than what she answers at each distance.
- Tried and dropped: the bands without their plain O ender (144 vs 149 of 240; signature +0.005).

### The search, each step a 240-match block (seeds 1-20) against its parent

| step | wins | signature |
|---|---|---|
| baseline | 69 | 0.613 |
| F0: the history's located bugs (no plain O ender / O cash, K links, the seal's O) | 58 | 0.774 |
| + the oki seal (白漣 -> RIKUJOKORO -> O) and the bind's hold by distance | 87 | 0.799 |
| + HOME ranges (later reverted: a tie) | 87 | 0.803 |
| + the range punish on recoveries | 86 | 0.801 |
| + one bar kept for the seal, the SPs out of :moves | 90 | 0.810 |
| + the oki waits through the stale stun | 87 | 0.816 |
| + the anti-step (linear model: wrong, it fired on dashes) | 86 | 0.815 |
| + the anti-step (the measured hop) | **139** | 0.833 |
| + the K links in the bands | 149 | 0.874 |
| + the held-stance read | 154 | 0.879 |
| shipped ranges back (seeds 21-40: 150) | 154 | 0.875 |
| anti-step HARD 1.0 (seeds 21-40: 158) | 160 | 0.880 |
| seal on every knockdown with a bar (final; seeds 21-40: 160) | **162** | 0.882 |

Because I picked steps one after another, each step's z is optimistic. The honest number is the final-vs-baseline pair above.

## The awaken A/B (changed: NORMAL's Shikai play, i.e. the oki at 0.4, the range punish at 0.4, the K links, no plain O ender, the bar reserve; AI-AWAKEN-P and `:awaken` untouched)

`python3 tools/simgate.py --summary --pairs 3,4,5 --seed0 S --seeds 60 --cmd 39020 -j 2` (she is P1, never awakening)
and `--pairs 8,12,23,30 ... --cmd 39002` (she is P2). The never-awaken side's wins of 60, final -> next to the baseline's
(the baseline's as b1a0 measured them at the freeze):

| pairing | S100 | S300 | S500 | baseline S100 / 300 / 500 |
|---|---|---|---|---|
| RY (vs Yamamoto) | 30 | 30 | 21 | 23 / 24 / 21 |
| RK (vs Kenpachi) | 11 | 21 | 15 | 3 / 2 / 6 |
| RR (the mirror) | 31 | 33 | 26 | 11 / 14 / 10 |
| IR (vs Ichigo) | 14 | 19 | 28 | 2 / 5 / 9 |
| SR (vs Senjumaru) | 28 | 31 | 27 | 9 / 12 / 12 |
| BR (vs Lille) | 24 | 25 | 27 | 7 / 6 / 6 |
| HR (vs Hisagi) | 24 | 30 | 22 | 8 / 14 / 10 |

**17 of 21 rows pass** (>= 20; the baseline passes 3). The failures: RK at S100 / S500 (11, 15: the Kenpachi bug below) and
IR at S100 / S300 (14, 19). Her Shikai without the awakening is now strong enough that the awakening is a real choice.

## Risks

- **Kenpachi stays low (9 of 80)**: the known §17.6 bug. Her perfect-Hoho reflex presses Step into his Kikon follow-up,
  and in 40 matches (seeds 1-20, both seats) he took 307 Konpaku from her through O-ender / SP-ender Kikons. The anti-step hits him 98 of 101.
  Once main's fix is ported (the `:steps` hooks, which need main's ai.lisp) this matchup should move most.
- **Lille (16 of 80)**: his awakened far dash L, then the follow-up J1, then the stance strings to a red Kikon. My cell
  only answers his held stances, with BYAKURAI.
- **The anti-step reads the generic Step in.** A kit whose Step is something else (Lille's stance steps) gets little from
  it. If a shared change made the Step's hop slower, or put the J later, *AI-RU-HOP* would need re-measuring.
- **The oki's timing relies on** :down 30 + :wakeup 30 (*REACTION-FRAMES*) and 白漣's knockdown, read through the
  perceived `:down` / `:wakeup` frame plus her delay. She reads his *actual* `:air` / `:down` / `:wakeup` state only to hold
  off (`:WAIT`) during her own knockdown, i.e. her own hit felt at once, as string-reflex feels its contact.
- The anti-step is a sure answer at HARD (1.0, one option). The oki takes the seal whenever it can, because a weighted
  pick measured worse. The tables where several options really compete (the range punish) are weighted picks.
- NORMAL's share rose 0.423 -> 0.527, still inside the band. A later cell that strengthens NORMAL could push it past 0.60.
- `*RU-AI-HOLD*`: a per-side hold length one reflex sets and AI-COMMAND reads and clears in the same step (never across
  steps or matches). There is no other new state.

## Shared-code recommendations (not made)

1. Port main's §17.6 fix (`:steps` :held / :block-hold) into this style at integration. It needs main's ai.lisp hooks,
   which are not at the freeze.
2. A generic anti-step for every CPU (ai.lisp) would mirror this cell's gain onto every opponent. That is a balance
   decision for the user.
3. aieval counts a Kikon's KIKON line as no damage: the seal's Kikon scores only its 70 (b0a0 said the same).

# b1a1 (round 1, a refine of b1a0): her bars, her flash step and her awakening priced by what they buy

Primary axis (the brief): her resources and his state (layers, bars, flash step, red, the cash-out after a confirmed hit).
Parent: b1a0 (rescored 0.7506: value tables for the confirm, the cash and the J1 envelope). History read in full: the
baseline (0.5898), b0a0 (0.7154), b1a0 (0.7506), b2a0 (0.8421), b3a0 (0.719), with their score.rescored.json. Planning base
read: `docs/research/rukia-cpu/` (sheet-shikai, matchups-shikai, strategy-shikai, both catalogues), rukia.lisp, ai.lisp,
Lille's barro-ai.lisp (his charged dash and its line-reader), Kenpachi's ken.lisp (his first strike).

## Result (EVAL_COMMAND `python3 tools/aieval.py --char 2 --seeds 40 -j 2`, the final file)

| | baseline | b1a0 (parent) | b2a0 (best so far) | **b1a1** |
|---|---|---|---|---|
| **score** | 0.5898 | 0.7506 | 0.8421 | **0.8906** |
| strength | 0.273 | 0.410 | 0.671 | **0.750** |
| masher | 1.0 | 1.0 | 1.0 | 1.0 |
| signature | 0.616 | 0.855 | 0.882 | **0.931** |
| NORMAL share (band 0.30-0.60) | 0.423 | 0.492 | 0.527 | 0.542 (x1) |
| pacing (NORMAL P1 medians, all K.O.) | 100.8-140.4 s | 101.9-146.7 s | 91.7-150.2 s | 88.5-142.8 s |

str_by_opp (HARD, both seats, of 80): Yamamoto 72, Kenpachi **35** (b2a0 9), Ichigo 79, Senjumaru 74, Lille 20 (16),
Hisagi 80. NORMAL by_opp: Lille 49, Hisagi 46, Ichigo 37, Kenpachi 27, Senjumaru 57, Yamamoto 44 (of 80).
sig_by: kstring 0.466 (ORANGE's hits count there), burst 0.167, poke 0.141, **seal 0.107** (b2a0 0.070), kido 0.051;
not hers: counter 0.049, O on a red victim 0.009, Breaker 0.005, the bands' O 0.006, plain J 0.000.

**Paired, final vs the others** (my runner over the native sim: the evaluator's run-log commands with a seed offset, the
frozen evaluator's `rukia_class`; it reproduces b2a0's 162 and b1a0's 104 of 240 on seeds 1-20 exactly):

| comparison | matches | wins | diff (SE, z) | signature |
|---|---|---|---|---|
| final vs b2a0 (seeds 1-80) | 960 | 627 -> 708 | +0.084 (0.0136, z 6.2) | 0.878 -> 0.932 |
| final vs b1a0 (seeds 1-20) | 240 | 104 -> 181 | +0.321 (0.032, z 9.9) | 0.854 -> 0.932 |

## 1. What the history says, and what I took

- **b2a0's two finds carry the most** (+93 HARD wins of 240 over its F0): the anti-step (his generic Step -> J met with her
  J1 into its landing, a HARD reflex on the Step's frame 1) and the oki seal (K3 +L 白漣's knockdown -> RIKUJOKORO held to
  land on his first vulnerable frame -> the O sealed: the Kikon from full health; verified gap 0 by combo-trial). Neither is
  in b1a0. b1a0's confirm table (the K link always, the L / SP / ender picked by value^3) was +0.137 strength over the
  baseline on its own, a different layer (the confirm, not the neutral). **They had never been combined.**
- Located bugs every cell fixed (the bind cashed with SP2, the plain O ender, J links): already in b1a0.
- Measured failures I did not repeat: b1a0's ORANGE as a normal option (-20 of 480: the 70 flash step the perfect Hoho
  and BLUE need) and as a finisher (-8); b0a0 / b3a0's guard against Lille's far dash (blocks, no wins); b3a0's awakening
  against everyone (it fired against Hisagi / Lille: here 189 -> 158 of 320, z -4.9); b2a0's weighted pick between the seal
  and TSUKISHIRO (-14 of 480: the seal always when a bar is held).

## 2. The mechanism (all in duel/lisp/rukia-ai.lisp)

### 2.1 The bar is the seal's (the confirm table values 白漣 by its oki)

The parent's confirm table valued 白漣's knockdown at a flat 40. b1a1 values it by what the knockdown buys:
RUKIA-AI-OKI-VALUE = the seal's Kikon (his Konpaku `kikon-worth` x 433 less the Reishi it refills, RUKIA-AI-SEAL-VALUE) when
she holds a bar, else TSUKISHIRO's meaty pillar (150). The bar is kept for it: `:sp-cancel-bars 2` (an SP cancel, the cash's
SHIRAFUNE and the confirm's SP enders only with two bars; one bar measured -23 of 960, z -2.0), no SP in the Shikai's
neutral `:moves`, SOKATSUI's neutral tap only with two bars. The oki itself (RUKIA-AI-OKI, b2a0's timing) and RIKUJOKORO's
hold by distance (the bind outlasts her recovery and the O's dash) are b2a0's measured pieces.

| condition (her K3 hit, the Shikai) | option | value (damage-equivalent) | weight |
|---|---|---|---|
| >= 1 霜の層 (RUKIA-OK) | +L 白漣 | (40 + 35 x layers) x combo-scale + **the oki: the seal (bar held) or 150** | value^3 (HARD), value (NORMAL / EASY) |
| 2+ bars | SHIRAFUNE | 110 + 25 x layers - the bar cost (80 / 45 / 15 with 1 / 2 / 3 bars) | |
| 2+ bars, inside SOKATSUI's cone | SOKATSUI | 90 + 10 - the bar cost | |
| her flash step **100** (full), him reeling within J1 + 0.2 | **ORANGE** (the restart: J1 K2s K3 +L 白漣 again, then the oki) | 280 + the oki - 150 (the 70 flash step) | |
| any option reaching his Reishi left | | + 100 | |
| he is red | the K route (to the O ender's Kikon) | + 150 | |

With a bar held the seal (~500-860) dominates both: at a full flash step HARD takes ORANGE or 白漣 about half and half
(both end in the same knockdown and oki: ORANGE's restart adds ~130 over 白漣-now's ~50-100), else 白漣 -> the oki; SHIRAFUNE
rarely. Without a bar: 白漣 -> TSUKISHIRO vs
SHIRAFUNE / ORANGE by the same table.

### 2.2 Her flash step: ORANGE only when full

ORANGE (CHAIN REVERSE) spends the flash step the perfect Hoho (>= 60) and BLUE need; b1a0 lost 20 HARD wins of 480 with it
as an ordinary option. At 100 the regen is wasted, so ORANGE costs least there: the K3's cash-out may restart the string
(RUKIA-AI-SP-ENDER returns :burst; ai.lisp's chain-follow restarts with J1). Measured: strength a tie (+2 of 960), the
signature +0.006 in both 480-match blocks (the restarted hits count under ORANGE). At 85: a tie (-3 of 960), so 100 kept.

### 2.3 No plain O (his state: the O is the Kikon's)

`*AI-RU-ENDER-O*` and `*AI-RU-CASH-O*` 0.9 -> 0 at HARD (the parent still pressed the plain ENBU off an ender with no
pick, and as the cash of a stun with no bar). The O now lands only on a red victim (ai.lisp's O ender: the Kikon) or a sealed
one (RUKIA-AI-SEAL: tagged "seal"). Measured: -4 of 480 (tie, z -0.6), the signature 0.883 -> 0.907.

### 2.4 The awakening: a comeback, not an opener (`:awaken (:melee-share 0.6 :min-taken 1800)`, AI-AWAKEN-P's own gate)

With 2.1-2.3 her Shikai outplays her bands. Against the four melee opponents (both seats, seeds 1-80, 640 matches):

| :min-taken | wins / 640 | Kenpachi / 160 | Yamamoto / 160 | signature |
|---|---|---|---|---|
| 150 (shipped) | 480 | 28 | 139 | 0.908 |
| **1800 (final)** | **517** | **62** | **147** | 0.932 |
| 2400 | 515 | 78 | 126 | 0.938 |
| 3000 (she never reaches it: no awakening in 10 Kenpachi logs) | 527 | 86 | 135 | 0.941 |
| never (100000) | 531 | 90 | 130 | 0.942 |

She now awakens only once she has taken 1800 (about two Konpaku's worth: a match she is losing), still only against a melee
opponent (the ranged rule stays: awakening against Lille / Hisagi too cost 31 of 320). "Never" scores a little higher
(+14 of 640, z ~1) but throws away her bands; 1800 keeps the awakening as her comeback. The timing stays AI-AWAKEN-P's (its
free reflex and the combo break); the debug modes force it as before.

### 2.5 Kept from b1a0 and b2a0 unchanged

The confirm table's other rows (the K link always; the bursts at link 1 / 2 by value), the cash table, the J1 envelope
(RUKIA-AI-FRONT), the zone (kido 0.6 HARD, RIKUJOKORO from 3.5 m against a long poke), the perfect Hoho, the seal's O, the
bands' disc, REIDO; b2a0's anti-step (*AI-RU-ANTI-STEP* 0 / 0.3 / 1.0), the oki (0 / 0.4 / 0.95), RIKUJOKORO's hold by
distance. Reflex order: zero's REIDO, the seal's O, the oki, the anti-step, the perfect Hoho, the cash, -50's Hoho in, the
envelope, the zone, the bands' disc.

Every new or changed chance scales EASY <= NORMAL <= HARD; every pick is one SIM-RND01 per event (a hit, a decision, an
action of his); the only state is b2a0's per-step `*RU-AI-HOLD*` and b1a0's per-step `*RU-AI-MEMO*`.

## 3. The search (each a paired run on the same seeds and seats; wins of HARD Rukia)

| step | matches | wins (parent -> step) | z | signature | kept |
|---|---|---|---|---|---|
| C1 = b1a0 + b2a0's anti-step + oki + the bar for it (vs b2a0) | 960 | 627 -> 678 | +4.24 | 0.878 -> 0.882 | yes |
| C3 = C1 + no plain O (vs C1) | 480 | 342 -> 338 | -0.59 | 0.883 -> 0.907 | yes (signature) |
| C4 = C3 + b2a0's range punish (recoveries + held stances) | 480 | 338 -> 323 | -2.30 | 0.909 | no (Lille 18 -> 8 / 80) |
| C5 = C3 + a long guard on his charged :through dash (Lille's awakened L) | 240 (Lille) | 41 -> 39 | tie | | no (10 logs: 124 dashes blocked, 50 still opened his combos; no wins) |
| C6 = C3 + ORANGE at a full flash step | 960 | 667 -> 669 | +0.26 | 0.908 -> 0.914 | yes (signature) |
| C7 = ORANGE from 85 | 960 | 669 -> 666 | -0.90 | 0.914 | no (tie: the first kept) |
| C8 = C6 + awaken against everyone (:melee-share 0) | 320 (Lille, Hisagi) | 189 -> 158 | -4.89 | | no |
| C9 / C10 / C12 = :min-taken never / 3000 / 2400 | 640 (melee) | 480 -> 531 / 527 / 515 | +4.45 / / | 0.94 | no (§2.4) |
| **C11 = C6 + :min-taken 1800 (final)** | 960 | 669 -> 708 | **+3.95** | 0.914 -> 0.932 | **yes** |
| C13 = C11 with one bar's reserve (:sp-cancel-bars 1) | 960 | 708 -> 685 | -2.01 | 0.928 | no |

(Sequential picks: each step's z is optimistic; the final-vs-b2a0 pair above is the honest number.)

## 4. Diagnosis of what is left (combat logs, HARD, her P1)

- **Lille (20 / 80)**: his awakened charged dash L (BR-E-L1 / BR-OE-L1) opens 81 of his combos in 10 matches (25 000 damage),
  then the stance strings to a red Kikon. His CPU's line-reader releases it when its predicted line meets her (lateral
  movement is predicted); guarding it blocks most of them (C5) but the wins don't follow (his other openers take over).
  b0a0 and b3a0 found the same: not answered here.
- **Kenpachi (35 / 80)**: his first-strike J1 (KEN-FIRST-STRIKE, inside 4 m, timed to her closing) opens 56 of his combos in
  8 matches; plus the §17.6 bug (his Kikon follow-up through her guard). Most of this cell's Kenpachi gain is the late
  awakening (her bands lose to him: 28 -> 62 of 160).

## 5. The awaken A/B (the awakening rule changed)

`python3 tools/simgate.py --summary --pairs 3,4,5 --seed0 S --seeds 60 --cmd 39020 -j 2` (she is P1, never awakening) and
`--pairs 8,12,23,30 ... --cmd 39002` (she is P2), S = 100 / 300 / 500. The never-awaken side's wins of 60 (pass >= 20), next
to the baseline's (as b1a0 measured them at the freeze) and b2a0's:

| pairing (never-awaken Rukia) | b1a1 S100 / 300 / 500 | baseline | b2a0 |
|---|---|---|---|
| RY (vs Yamamoto) | 26 / **17** / 24 | 23 / 24 / 21 | 30 / 30 / 21 |
| RK (vs Kenpachi) | **14 / 15 / 16** | 3 / 2 / 6 | 11 / 21 / 15 |
| RR (the mirror) | **19** / 32 / 27 | 11 / 14 / 10 | 31 / 33 / 26 |
| IR (vs Ichigo) | 25 / 31 / 23 | 2 / 5 / 9 | 14 / 19 / 28 |
| SR (vs Senjumaru) | 36 / 32 / 33 | 9 / 12 / 12 | 28 / 31 / 27 |
| BR (vs Lille) | 31 / 31 / 22 | 7 / 6 / 6 | 24 / 25 / 27 |
| HR (vs Hisagi) | 31 / 30 / 34 | 8 / 14 / 10 | 24 / 30 / 22 |

16 of 21 rows pass (the baseline 3, b2a0 17). The failures: RK's three (her NORMAL against Kenpachi, the §17.6 bug), RY at
300, the mirror at 100 (19). The A/B now says little about the awakening itself: with :min-taken 1800 the kit-rule side
awakens only when losing.

## 6. Risks

- **The awakening is rarer**: a human will see her bands only in matches she is losing to a melee opponent. If the user
  wants the bands seen more, :min-taken is the one knob (150 costs ~37 HARD wins of 640 against the melee four, mostly
  Kenpachi's).
- ORANGE fires only at a full flash step: rare-ish (after a quiet spell); the theme 「K 連段與橙色爆氣」 is visible but not
  frequent.
- Lille and Kenpachi stay her losing matchups (§4); Kenpachi should move once main's §17.6 fix is ported.
- NORMAL's share rose to 0.542 (in the band; a later NORMAL-strengthening cell could cross 0.60).
- The seal value reads `kikon-worth` (his Konpaku a Kikon would take) and his Reishi: what she sees on the HUD.

## 7. Shared-code recommendations (not made)

1. AI-AWAKEN-P's gate is static per kit (:min-taken / :melee-share / :awaken-above): a kit hook (e.g. `:awaken-when`, called
   with the opponent and both sides' Konpaku) would let her awaken by matchup and score instead of by damage taken (here:
   her bands lose to Kenpachi, help a little against Yamamoto).
2. The §17.6 fixes (the perfect-Hoho Step on Kenpachi's Kikon strike, the post-block hold), as the brief says.
3. aieval counts the seal's Kikon line ("-> Px KIKON") as no damage: the seal scores only its 70.

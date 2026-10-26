# b0a2 (round 1, refine of b0a1): the matchup tables + a comeback awakening + his first-strike envelope, per opponent

Primary axis (the brief): the opponent and his form. Parent: b0a1 (rescored 0.8839: b0a0's matchup tables x measured payoffs,
b2a0's reactive layer, Lille's reads). History read in full: BASELINE_DIR, b0a0, b0a1, b1a0, b1a1, b2a0, b3a0 (proposal,
score.json, score.rescored.json, rukia-ai.lisp where a piece was ported). Planning base read: `docs/research/rukia-cpu/`
(matchups-shikai, sheet-shikai, strategy-shikai, catalogues); the opponents' CPUs where they beat her: ken.lisp
(KEN-WALK-IN, KEN-FIRST-STRIKE, KEN-HOHO-COMMIT), barro.lisp / barro-ai.lisp (the awakened dash L, its wing armour, the
snipe), ai.lisp (AI-AWAKEN-P, the generic Hoho of a committed move, BRAIN-STEP's holds).

## Result (EVAL_COMMAND `python3 tools/aieval.py --char 2 --seeds 40 -j 2`, the final file)

| | baseline | b0a1 (parent) | b1a1 (best so far) | **b0a2** |
|---|---|---|---|---|
| **score** | 0.5898 | 0.8839 | 0.8906 | **0.9188** |
| strength | 0.273 | 0.742 | 0.750 | **0.827** |
| masher | 1.0 | 1.0 | 1.0 | 1.0 |
| signature | 0.616 | 0.923 | 0.931 | **0.941** |
| NORMAL share (band 0.30-0.60) | 0.423 | 0.454 | 0.542 | 0.535 (x1) |
| pacing (NORMAL P1 medians, all K.O.) | 100.8-140.4 s | 99.8-144.7 s | 88.5-142.8 s | 97.1-140.1 s |

str_by_opp (HARD, both seats, of 80): Yamamoto 78 (b0a1 76), **Kenpachi 38** (6), Ichigo 80 (80), Senjumaru 79 (71),
Lille 42 (43), Hisagi 80 (80). NORMAL by_opp: Lille 61, Hisagi 51, Ichigo 39, Kenpachi 17, Senjumaru 51, Yamamoto 38.
sig_by: kstring 0.387, burst 0.223, poke 0.145, seal 0.120, kido 0.067; not hers: counter 0.048, O on a red victim 0.008,
the bands' O 0.002, plain J 0.001, Breaker 0.000.

**Paired** (my runner over the native sim with aieval's own `matches` parsing and `rukia_class`; it reproduces b0a1's
178 / 240 on seeds 1-20 exactly; the same seeds and seats, 240 HARD matches a block):

| comparison | block | A | B | diff (SE, z) | signature A -> B |
|---|---|---|---|---|---|
| final vs b0a1 (the parent) | seeds 1-20 | 178 | 195 | +0.071 (0.026, **2.76**) | 0.922 -> 0.942 |
| final vs b0a1 | seeds 21-40 | 178 | 202 | +0.100 (0.027, **3.71**) | 0.923 -> 0.941 |
| final vs b0a1, both blocks | 480 | 356 | 397 | +0.085 (0.019, 4.59) | Kenpachi 6 -> 38, Senjumaru 71 -> 79, Yamamoto 76 -> 78, Lille 43 -> 42 of 80 |
| step 1 (b0a1 + the late awakening) vs b0a1 | seeds 1-20 | 178 | 189 | +0.046 (0.022, 2.13) | 0.922 -> 0.939 |
| final vs step 1 (the envelope by opponent) | seeds 1-80 (960) | 755 | 778 | +0.024 (0.012, 1.97) | 0.938 -> 0.939 |

## Step 1. The history (what each did, how it did, why), and what I took

| cell | mechanism | measured (rescored) | taken here |
|---|---|---|---|
| baseline | AI v2 counter-fighter | 0.5898 | |
| b0a0 | matchup tables (zones cut at his J1 lunge, weights per opponent), the bind -> O fix | 0.7154 | (via b0a1) |
| b1a0 | value tables: confirm / cash / **the J1 envelope** (guard / J1 / back hop / K1 or SOKATSUI with his flash step < 30) | 0.7506 | **the envelope table** (never combined with the matchup tables) |
| b2a0 | anti-step J1, oki seal, range punish | 0.8421 | (via b0a1) |
| b3a0 | awaken vs everyone, one K grammar, -18 cools anywhere | 0.719 | -18's cooling: measured (a tie here, dropped) |
| b0a1 (parent) | b0a0's tables x measured payoffs (pokes 0, RIKUJOKORO vs Yamamoto / Lille), Lille's reads, b2a0's layer | 0.8839: Kenpachi 6, Lille 43 | the whole file |
| b1a1 | the bar for the seal, ORANGE at a full flash step, **the awakening at :min-taken 1800** | 0.8906: Kenpachi 35, Lille 20 | **:min-taken 1800** |

b0a1 and b1a1 were the two best and lost in different places: b0a1 kept Lille (43 / 80) with his reads, b1a1 kept Kenpachi
(35 / 80) by awakening only as a comeback. The diagnosis below shows why b0a1's Kenpachi is low: her bands lose to him.

## Step 2. The diagnosis by opponent (combat logs, b0a1's file, 10 HARD matches a matchup, her P1; tools in my scratch dir)

Her dealt / taken per form (frames in the form):

| opponent | BASE | -18 | -50 | ZERO |
|---|---|---|---|---|
| Kenpachi (b0a1) | 10717 / 10644 (22254 f) | **7564 / 12512 (19518 f)** | 2889 / 3930 | 332 / 0 |
| Kenpachi (+ :min-taken 1800) | 20483 / 15529 (40006 f) | 1806 / 1635 | 668 / 627 | - |
| Lille (b0a1, 4 matches) | 5227 / 10465 | **0 / 3351** | 875 / 2793 | 1166 / 0 |

Against Kenpachi she spends half the match in -18 (it cools only within 3.5 m), losing it; against Lille -18 deals nothing
(he is far, it never cools). Her Shikai is now her best form against both: the awakening belongs to a match she is losing.

His combos by opener (hits until 90 f quiet; per combo damage):

| opponent | opener | combos / 10 matches | share of his damage |
|---|---|---|---|
| Kenpachi | KE-J1 (KEN-FIRST-STRIKE / -LUNGE after KEN-WALK-IN to 2.3 m: 28 of 47 J1s hit her standing or walking) | 36 (289 each) | 0.58 |
| Lille | his awakened dash L (BR-E-L1 / -OE-L1) | 37 (~370 each) | 0.41 |
| Lille | BR-W-J1 after a **guard crush** (19 crushes in 10 matches, 17 of them on a blocked dash: the long guard of b0a1 drains her gauge) | 17 (385 each) | 0.19 |
| Lille | the base snipe BR-S-L1-2 (KAMAE) | 45 (94 each) | 0.12 |

## Step 3. The tactics by condition (all in duel/lisp/rukia-ai.lisp)

### A. The awakening: a comeback, by what her forms do against each opponent (`:awaken (:melee-share 0.6 :min-taken 1800)`)

| condition (AI-AWAKEN-P's own gate) | before | b0a2 |
|---|---|---|
| EVOLUTION, a melee opponent (>= 60 % of the damage taken from blades) | awaken after 150 taken | awaken after **1800** taken (two Konpaku's worth: a match she is losing) |
| a ranged opponent (Hisagi, Lille at range) | never | never (b1a1 / b3a0 measured awakening against them: -31 of 320) |

The kit gate only knows :min-taken / :melee-share (no per-opponent key: recommendation 1). Measured on the parent: +11 of
240 (z 2.13), Kenpachi 3 -> 14 of 40, signature +0.017 (the bands' O / plain hits gone).

### B. His first-strike envelope, per opponent (RUKIA-AI-FRONT, at a Shikai neutral decision; *AI-RU-FRONT* 0 / 0.15 / 0.95)

He is free (idle / running), not red, inside his envelope = his J1's reach + its lunge (<= 0.8) + 0.3 + his perceived closing
speed x (his J1's startup + her delay) (RUKIA-AI-ENVELOPE, from his kit as his form has it now). One roll a decision, then
one pick by value^k (RUKIA-AI-PICK, k = *AI-RU-SHARP* 1 / 1 / 2) among what is allowed:

| option | value (default, b1a0's) | allowed |
|---|---|---|
| guard (his J1 blocked: -2 for him) | 40 | always |
| her J1 first | 50 | he will be inside her J1's reach + 0.3 at its hit |
| the back hop (his J1 whiffs) | 25 | always |
| K1 | 60 | **his flash step can't pay a Hoho** (RUKIA-AI-HIS-HOHO-P: AI-HOHO-SPARE-P on his HUD gauges, the rule every CPU's Hoho of a committed move obeys) and he is in K1's window at its hit |
| SOKATSUI (tap) | 55 | his Hoho dry, bars beyond the bind's, inside 4.5 m |

Per opponent (his row's `:front`, else the default): **Yamamoto `:none`** (his J1 is 9 f, her J1 7 f already wins up
close: the table's :close q 7; with the envelope on he went 154 -> 150 of 160), everyone else the default. Kenpachi rows
tried: guard 70 (62 vs 68 of 160), back hop 50 (68 vs 68): the default kept. At HARD the neutral decision inside his
envelope is ~40 % guard, ~45 % J1 when it reaches, ~15 % the back hop; K1 / SOKATSUI only while his gauge is dry.

Measured against step A (960 HARD matches, seeds 1-80): 755 -> 778 (+0.024, z 1.97): Kenpachi 57 -> 68, Senjumaru 149 ->
156, Lille 75 -> 80 of 160, the others unchanged; signature +0.001.

### C. Kept from b0a1 unchanged

The matchup tables x measured payoffs (Yamamoto / Lille RIKUJOKORO, Lille's :no-busy, :hold-forms, :guard-on), the reactive
layer (the anti-step J1, the oki seal, the range punish, the seal's O), K3 -> 白漣 0.95, no plain O, no Breaker in the table.
Reflex order: zero's REIDO, the seal's O, the oki, the anti-step, the perfect Hoho, the matchup guard, the range punish, the
cash, the Breaker read, -50's Hoho in, the intent, **the envelope**, the matchup decision, the zone, the bands' disc.

Every new chance scales EASY <= NORMAL <= HARD and is one SIM-RND01 per decision; no new state.

## Tried and dropped (each paired, the same seeds and seats; wins of HARD Rukia)

| variant (on top of step A unless said) | matches | result | why dropped |
|---|---|---|---|
| -18 cools at once anywhere (`:cool (:p 0.9 :near 99)`, b3a0's) | 240 | 189 -> 188 | tie: with the late awakening she rarely reaches -18 |
| **his flash step dry -> the pokes back** (`:poke-dry`: K1 / BYAKURAI / TSUKISHIRO / SOKATSUI / SHIRAFUNE / RIKUJOKORO x1 while he can't pay a Hoho) | 480 | 387 -> 374 (z -1.67), sig -0.004 | Lille 41 -> 28 (his dash, not his Hoho, punishes them); without Lille a wash (Senjumaru +4, Kenpachi -3): the pokes fail by block / Step / trade too, not only by his Hoho |
| a Hoho through Lille's awakened dash seen leaving (`:dodge`, RUKIA-AI-MU-DODGE; HARD 1.0; the Hoho's iframes 1-14 over the slide) | 160 (Lille) | 75 -> 77 | tie: guard crushes 19 -> 9 a 10 matches, but the dash hit her as often (he re-dashes in her Hoho's lockout) |
| the same with her Burst reserve kept (AI-HOHO-SPARE-P) | 80 (Lille) | 41 -> 39 | it rarely fired (her Reishi below half keeps 100 flash step) |
| no K1 / L in the Shikai's generic `:moves` beyond 2.8 m (the red-opponent fallback's BYAKURAI: 10 of 13 punished by Lille) | 240 | 189 -> 190 | tie |
| ORANGE at a full flash step (b1a1's: half the K3 bursts to the restart) | 480 | 397 -> 386 (z -1.77), sig +0.001 | Kenpachi 38 -> 30 |
| Kenpachi's envelope guard 70 / back hop 50 | 160 each | 68 -> 62 / 68 | worse / tie |

## Why it is not a repeat

The two best cells lost in different matchups for different reasons; b0a2 is their first combination (b0a1's matchup
tables and Lille reads + b1a1's comeback awakening), plus b1a0's envelope table — dropped by b1a1's line in favour of its
own confirm tables, never put next to the matchup tables — made per opponent (off against Yamamoto, where the matchup's J1
already wins) and measured. The diagnosis that makes the combination the right one is new: per form dealt / taken by
opponent (her -18 band is a dead form against Kenpachi and Lille), his openers by share (Kenpachi's walk-in J1 58 %, Lille's
dash 41 % and the guard crush it builds). Two new opponent-state mechanisms were measured and dropped (his dry flash step
re-enabling the pokes; the Hoho through Lille's dash).

Stopped at 480 against the parent (both blocks past 2 SE; my runner's 397 / 480 equals aieval's strength 0.827). The
envelope's own 960-match block (z 1.97) sits at the 2 SE line, and its Yamamoto exception was chosen after seeing that
matchup's rows (so its z is optimistic); the honest number is the final-vs-parent pair.

## The awaken A/B

Changed: what decides the awakening (:min-taken 150 -> 1800) and NORMAL's Shikai play (the envelope at 0.15 of its
decisions). `python3 tools/simgate.py --summary --pairs 3,4,5 --seed0 S --seeds 60 --cmd 39020 -j 2` (she is P1, never
awakening) and `--pairs 8,12,23,30 ... --cmd 39002` (she is P2); the never-awaken side's wins of 60 (pass >= 20), next to
b0a1's and the baseline's (as b0a1 / b1a0 measured them at the freeze):

| pairing (never-awaken Rukia) | b0a2 S100 / 300 / 500 | b0a1 S100 / 300 / 500 | baseline S100 / 300 / 500 |
|---|---|---|---|
| RY (vs Yamamoto) | 36 / 31 / 35 | 36 / 31 / 35 | 23 / 24 / 21 |
| RK (vs Kenpachi) | 32 / 24 / 24 | 28 / 24 / 17 | 3 / 2 / 6 |
| RR (the mirror) | 33 / 35 / 32 | 41 / 42 / 42 | 11 / 14 / 10 |
| IR (vs Ichigo) | 26 / 40 / 29 | 32 / 37 / 33 | 2 / 5 / 9 |
| SR (vs Senjumaru) | 37 / 28 / 28 | 36 / 37 / 39 | 9 / 12 / 12 |
| BR (vs Lille) | 33 / 36 / 40 | 32 / 34 / 36 | 7 / 6 / 6 |
| HR (vs Hisagi) | 40 / 42 / 41 | 44 / 40 / 41 | 8 / 14 / 10 |

**21 of 21 rows pass** (b0a1 20, the baseline 3). With :min-taken 1800 the kit-rule side awakens only in a match it is
losing, so the A/B now mostly compares her Shikai with her Shikai plus a late comeback (as b1a1 noted); the rows fell
where the late awakening helps the kit-rule side (the mirror, Senjumaru).

## Risks

- Kenpachi 38 / 80, Lille 42 / 80 stay her losing matchups. Kenpachi: his walk-in J1 is faster than her perception (the
  envelope only shapes what she does inside it) and the §17.6 bug (his Kikon follow-up through her guard; the post-block
  hold) is untouched here. Lille: his dash, guarded, builds his specials and crushes her guard; with the post-block hold
  fixed on main her J1 could punish the blocked dash (-12 for him), which should move this matchup most.
- The awakening is rare (a human sees her bands only when she is losing to a melee opponent); :min-taken is the one knob.
- NORMAL 0.535 (in the band); NORMAL against Kenpachi 17 / 80, against Lille 61 / 80.
- The envelope reads his HUD flash step and his perceived closing speed (two ring SNAPs), as b1a0 did.

## Shared-code recommendations (not made)

1. AI-AWAKEN-P's gate is per kit; a kit hook (`:awaken-when`, called with the opponent) would let her awaken by matchup
   (her bands lose to Kenpachi and Lille, help a little against Yamamoto).
2. Main's §17.6 fixes (`:held` / `:block-hold`) at integration: the block punish of Lille's dash (-12) and of Kenpachi's
   blocked J needs the post-block hold gone.
3. aieval counts the seal's Kikon line as no damage (as every cell noted).

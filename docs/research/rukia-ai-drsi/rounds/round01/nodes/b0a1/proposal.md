# b0a1 (round 1, refine of b0a0): matchup tables with measured payoffs — wait for him, bind where the bind pays

Primary axis (the brief): the opponent and his form. Parent: b0a0 (rescored 0.7154: the matchup tables, the bind -> O fix).
History read in full: BASELINE_DIR, b0a0, b1a0, b2a0, b3a0 (proposal, score.json, score.rescored.json, rukia-ai.lisp).
Planning base read: `docs/research/rukia-cpu/` (sheet-shikai, matchups-shikai, strategy-shikai, both catalogues,
opponents/barro-*, stats-vs-roster). Opponent CPUs read where they decide what beat her: barro-ai.lisp (the far dash, the
snipe charge, the let-go), ken.lisp (KEN-FIRST-STRIKE), ai.lisp (the generic Hoho of a committed move, AI-AWAKEN-P).

## Result (EVAL_COMMAND `python3 tools/aieval.py --char 2 --seeds 40 -j 2`, the final file)

| | baseline | b0a0 (parent) | b2a0 (best so far) | **b0a1** |
|---|---|---|---|---|
| **score** | 0.5898 | 0.7154 | 0.8421 | **0.8839** |
| strength | 0.273 | 0.325 | 0.671 | **0.742** |
| masher | 1.0 | 1.0 | 1.0 | 1.0 |
| signature | 0.616 | 0.836 | 0.882 | **0.923** |
| NORMAL share (band 0.30-0.60) | 0.423 | 0.4375 | 0.527 | 0.454 (x1) |
| pacing (NORMAL P1 medians, all K.O.) | 100.8-140.4 s | 97.5-149.6 s | 91.7-150.2 s | 99.8-144.7 s |

str_by_opp (HARD, both seats, of 80): Yamamoto 76 (b2a0 71, b0a0 35), Kenpachi 6 (9, 0), Ichigo 80 (80, 55), Senjumaru 71
(67, 31), **Lille 43** (16, 8), Hisagi 80 (79, 27). NORMAL by_opp: Lille 45, Hisagi 42, Ichigo 35, Kenpachi 17, Senjumaru
44, Yamamoto 35. sig_by: kstring 0.367, burst 0.218, poke 0.192, **seal 0.091**, kido 0.055; not hers: counter 0.059, the
bands' O 0.010, plain O 0.006, **Breaker 0.001** (b2a0 0.017), plain J 0.001.

**Paired, final vs the parent and vs b2a0** (my runner over the native sim with aieval's own classes; the same seeds and
seats, 240 HARD matches a block; it reproduces aieval's strength and signature exactly):

| block (seeds) | b0a1 | b0a0 | diff (SE, z) | b2a0 | diff (SE, z) | signature b0a1 / b0a0 / b2a0 |
|---|---|---|---|---|---|---|
| 1-20 | 178 | 81 | +0.404 (0.033, 12.3) | 162 | +0.067 (0.029, 2.33) | 0.922 / 0.836 / 0.882 |
| 21-40 | 178 | 75 | +0.429 (0.035, 12.2) | 160 | +0.075 (0.028, 2.69) | 0.923 / 0.836 / 0.881 |
| all 480 | 356 | 156 | +0.417 (0.024, 17.4) | 322 | +0.071 (0.020, 3.55) | |

Stopped at 480: both blocks past 2 SE against both.

## Step 1. The history (what each did, how it did, why)

| cell | mechanism | measured | lesson taken |
|---|---|---|---|
| baseline | AI v2 counter-fighter, ice cash, zone, bursts by link | 0.5898; 0 / 80 vs K, Lille, Hisagi | |
| b0a0 (parent) | matchup tables (zones cut at his J1 lunge, weights per opponent), the bind -> O fix, ender pick | 0.7154: signature +0.22, strength a tie | the tables are the frame-data prior; their **poke weights were set by hand and never measured** |
| b1a0 | value tables for the confirm / cash / envelope; ORANGE dropped (-20 / 480) | 0.7506 | ORANGE costs; K links, no plain O |
| b2a0 | the anti-step J1 on his Step in (frame 1, HARD), the oki seal (白漣 -> RIKUJOKORO on his wake-up -> O), the range punish | **0.8421** | the reactive layer is the strength: Hisagi 0 -> 79, Ichigo 80 |
| b3a0 | awaken vs everyone, one K grammar in the bands, the ward route | 0.719 | the bands' K links help; awakening vs Hisagi |

Grafting b2a0's reactive layer onto b0a0 (v1) gave 292 / 480 vs b2a0's 322: **b0a0's tables cost 30 wins**. Bisected:
(a) b0a0's K3 pick shared the burst with SHIRAFUNE / ORANGE (L ~40 % of K3s) where b2a0 bursts 95 %: the knockdown is the
oki seal's set-up, so +16 / 480 restoring it (a located interaction, not a flaw of the idea); (b) the poke-heavy neutral
picks: measured below. Table off at HARD (v2): 281 — the table itself was worth keeping, its weights were not.

## Step 2. The diagnosis by opponent (combat logs, 20-40 HARD matches each, both seats; tools in my scratch dir)

Her neutral presses and what became of each (n; hit / blocked / his perfect Hoho / she was hit first), b0a0's tables +
b2a0's layer (v7):

| opponent | K1 (table) | BYAKURAI (table) | TSUKISHIRO hold | RIKUJOKORO | the anti-step J1 |
|---|---|---|---|---|---|
| Yamamoto | 129: 30 / 43 / **28** / 10 | 120: 29 / 58 / **30** / 1 | 68: 13 / - / 2 / **26** | 57: **15 binds** / - / 6 / 5 | 173: **150** / 10 / 0 / 13 |
| Ichigo | 26: 4 / 0 / **19** / 3 | 43: 8 / 2 / **25** / 7 | 17: 1 / - / 1 / **13** | 18: 4 / - / 5 / 2 | 83: 76 / 0 / 0 / 7 |
| Hisagi | 5: 0 / 0 / 3 / 2 | 78: 17 / 36 / 8 / 15 | 62: 13 / 15 / 0 / **33** | 29: 10 / - / 1 / **18** | 45: 45 / 0 / 0 / 0 |
| Lille (v5) | 183: 10 / 19 / 10 / **63** | 114: 34 / 37 / 10 / 9 (+20 armoured) | 143: 54 / - / 0 / **63** | 103: **41 binds** / - / 7 / 38 | 18 of his Steps: 4 |

Every HARD opponent Hohos a committed K / L / SP of hers (ai.lisp's generic Hoho of a committed move, KEN-HOHO-COMMIT): her
K1 (17 f), the held L and SP1 are seen early enough to be vanished through; a perfect Hoho's counter then opens his string.
The neutral that pays is the **wait**: it leaves him the Step in, which the anti-step J1 meets (150 of 173 against
Yamamoto). The one neutral poke with a positive payoff where it was measured is **RIKUJOKORO**: its bind -> the seal's O is
the Kikon from full health (2 Konpaku), +104 a press against Yamamoto (26 binds of 92 with the final file), the only answer
to Lille's stance.

Lille (43 / 80, was 8-16 in every cell): his damage on her (40 matches): the awakened far dash L ~32 k (BR-E-L1 / -OE-L1, out
of the EN stance entry BR-TO-EN, 12 f, then a 20-60 f charge; his wing armour covers the entry: her pokes there are
ARMORED), the base snipe from his KAMAE ~29 k (level 2 at 20 f of charge, 8 f to the hit; level 3 chips a guard and its
gauge), his stance strings. Every slow move of hers pressed after his BR-TO-EN was hit (RIKUJOKORO 31 of 31; K1 / BYAKURAI
into the entry hit by the dash through the armour). In the bands she does worse against him (-18: dealt 676 / taken 10333).

## Step 3. The tactics by condition (all in duel/lisp/rukia-ai.lisp)

### A. The neutral: frame-data prior x measured payoff (RUKIA-AI-MU-WEIGHTS, *AI-RU-MU-DEFAULT* / *AI-RU-MU*)

One weighted roll a neutral decision (*AI-RU-MU-P* EASY 0 / NORMAL 0.35 / HARD 1.0, now against every opponent): weight =
the zone's weight (b0a0's frame-data table) x what she sees and has (RUKIA-AI-MU-K) x **the option's measured payoff
against him** (`:poke`, RUKIA-AI-MU-POKE: 0 where the logs above show a loss, 1 where they show a gain).

| opponent | :poke (others 0) | what is left in the zones (weights) | why |
|---|---|---|---|
| default (Ichigo, Senjumaru, Kenpachi) | none | close: J1 6, guard 1, back 1; inside his J1: back 2, guard 2, J1 1; K range: guard 1, wait 1; mid: in 1, wait 2; far: in 2, wait 2; out: in 3, wait 1 | his Step in comes to the anti-step; his commitments to the Hoho / range punish |
| Yamamoto | RIKUJOKORO 1.0 | + mid: RIKUJOKORO 4 (x4 on him held >= 34 f, x2 guarding) | the bind -> seal pays (+104 a press) |
| Lille | RIKUJOKORO 1.0, TSUKISHIRO 0.25, BYAKURAI 0.25 | mid: RIKUJOKORO 5, TSUKISHIRO 0.5, BYAKURAI 0.75, in 2, wait 1; far: TSUKISHIRO 1, in 3, wait 1 | the bind is his stance's answer (61 binds of 162 -> 145 seal Kikons in 40 matches) |
| Lille in his awakened stance (`:hold-forms` :jilliel / :shin, his kit form) | — | only guard (added, 1), wait, J1 | nothing slow survives his dash / strings there |
| Hisagi | none | his row's spacing (close J1 6; mid guard 1, in 1, wait 1 ...) | |

Measured (480 HARD matches each unless said): all pokes x0.25: +6 (sig +0.008); x0: +2, sig +0.008 more, but Lille 19 -> 11;
**per-opponent payoffs (Yamamoto / Lille RIKUJOKORO): +24, Lille 11 -> 36, z 3.66**; the table on against Senjumaru too
(once poke-free): 61 -> 74 of 80 (z 2.97; with b0a0's pokes it cost 6); RIKUJOKORO 2.0: -5 of 160; RIKUJOKORO on against
Kenpachi / Senjumaru: -5 of 160; Lille's L pokes 0.25 -> 0: -7 of 160 (kept 0.25).

### B. His specific threats (Lille: one roll per move of his, every chance EASY <= NORMAL <= HARD)

| condition (perceived) | tactic | measured |
|---|---|---|
| his BR-TO-EN (the stance entry, wing-armoured), BR-E-L1 / BR-OE-L1 (the dash) in any phase before its hit, <= 25 m | a long guard (RUKIA-AI-MU-GUARD; `:guard-on` now (name . nearest m); *AI-RU-MU-GUARD-P* HARD 0.9 -> 1.0) | 20 -> 26 of 80 |
| his held stance (KAMAE ...) | no range punish into it (`:no-busy`, b2a0's held-stance read off against him: BYAKURAI there hit 97, was hit 142 times) | +6 of 160 |
| his awakened stance form | the neutral waits / guards (above) | +4 of 160 |

Tried and dropped: guarding his base snipe charge (KAMAE / BR-S-L1 from 4+ m): 26 -> 18 of 80 (he charges to level 3, which
chips the guard and its gauge); a Hoho behind him into the snipe charge: 41 -> 32 of 80 (his charge Steps out and
re-aims); letting the table decide during his far charge: 41 -> 34.

### C. The reactive layer (b2a0's, ported unchanged but for the bar reserve: SHIRAFUNE / SOKATSUI keep b0a0's bind bar)

The anti-step J1 (his Step's frame 1, HARD 1.0, NORMAL 0.3), the oki seal (白漣's knockdown -> RIKUJOKORO timed on his
wake-up -> the O: the Kikon; TSUKISHIRO with no bar), the range punish by distance (his recovery: J1 / K1 / the Step in /
SHIRAFUNE / SOKATSUI / BYAKURAI / RIKUJOKORO / TSUKISHIRO, value^k), the bind held by distance (b0a0's 14 f), K3 -> 白漣 at
*AI-RU-BURST-3* 0.95 (b0a0's ender pick took half the K3s from it). Order in RUKIA-AI-REFLEX: zero's REIDO, the seal's O,
the oki, the anti-step, the perfect Hoho, the matchup guard, the range punish, the cash, the Breaker read, ...

### D. The signature: the O and the Breaker out of her own choices

No ENBU in the Shikai's `:moves` or the tables, no O in the cash (`*AI-RU-CASH-O*` 0, RUKIA-AI-CASH-PICK's :kikon out):
plain O 0.022 -> 0.006 of her damage, signature +0.018, -11 wins of 480 (z -1.2: kept for the signature: score +0.002).
The Breaker against Ichigo / Senjumaru (b0a0's :breaker-p 0.6 / 0.7 -> 0): Breaker 0.014 -> 0.001, signature +0.028 in
those matchups, -3 of 160. The O stays as the seal's and the red Kikon.

## Why it is not a repeat

b0a0 hand-set the tables' weights from the sheets; b0a1 keeps them as the prior and multiplies each option by its
**measured** outcome against that opponent (a new layer: per opponent payoffs from the combat logs, as the user asked:
options weighted by the advantage each brings), which turns the neutral from poking into waiting for his commitment;
it is the first cell whose tables make the reactive layer (b2a0's) the plan, and the first to read Lille's awakened kit
(his stance form, the wing-armoured entry, his held stance) — Lille 16 -> 43 of 80. Pieces combined: b0a0's tables and
bind -> O, b2a0's anti-step / oki / range punish, b1a0 / b3a0's "no plain O"; new: the payoff layer, the Lille reads, the
Breaker out, two located interactions fixed (the K3 pick starving the oki; the table's pokes feeding his Hoho).

## The search (each a paired HARD block against its predecessor; the final-vs-parent / b2a0 blocks above are the honest numbers)

| step | wins (of) | sig | kept |
|---|---|---|---|
| b0a0 | 156 / 480 | 0.836 | |
| v1: + b2a0's reactive layer, K links 1.0, SPs out of :moves | 292 / 480 | 0.878 | yes |
| v2: v1 with the table off at HARD | 281 / 480 | 0.874 | no |
| v3: K3 -> 白漣 0.95 (the oki's set-up) | 308 / 480 | 0.878 | yes |
| v4: Lille's TO-EN guard, HARD 1.0 (Lille only) | 26 vs 20 / 80 | | yes |
| v5: table off vs Kenpachi / Senjumaru | 320 / 480 | 0.873 | (later on again) |
| v6: guard his snipe charge (Lille) | 18 vs 26 / 80 | | no |
| v7: no plain O in the neutral / cash | 309 / 480 | 0.891 | yes |
| v8: pokes x0.25 | 315 / 480 | 0.899 | step |
| v9: v8 + table vs K / S | 311 / 480 | 0.899 | no |
| v10: pokes x0 | 317 / 480 | 0.907 | step |
| v11: per-opponent payoffs (Yamamoto / Lille RIKUJOKORO) | 341 / 480 | 0.907 | yes |
| v12: Lille :no-busy | 72 vs 66 / 160 | | yes |
| v13: the table vs Senjumaru (poke-free) | 74 vs 61 / 80 | | yes (aieval 0.8788) |
| v14: Hoho into his snipe charge | 32 vs 41 / 80 | | no |
| v15: table decides during his far charge | 34 vs 41 / 80 | | no |
| v16: RIKUJOKORO vs Kenpachi / Senjumaru | 77 vs 82 / 160 | | no |
| v17: no Breaker (Ichigo / Senjumaru) | 151 vs 154 / 160 | +0.028 there | yes |
| v18: Lille :hold-forms | 76 vs 72 / 160; 358 / 480 | 0.921 | yes |
| v19: RIKUJOKORO 2.0 (Y / Lille) | 114 vs 119 / 160 | | no |
| v20: Lille's L pokes 0 | 69 vs 76 / 160 | | no |
| v21: Kenpachi's stay-out row dropped (tie 6 vs 8 / 80) | 356 / 480 | 0.923 | yes (final, aieval 0.8839) |

## The awaken A/B

Changed: NORMAL's Shikai play (its table share 0.35 now poke-free, b2a0's oki 0.4 / anti-step 0.3 / range punish 0.4, K3 ->
白漣 0.7, no plain O, no Breaker in the table); AI-AWAKEN-P and `:awaken` unchanged.
`python3 tools/simgate.py --summary --pairs 3,4,5 --seed0 S --seeds 60 --cmd 39020 -j 2` (she is P1, never awakening) and
`--pairs 8,12,23,30 ... --cmd 39002` (she is P2); the never-awaken side's wins of 60 (pass >= 20), the baseline's as
b0a0 / b1a0 measured them at the freeze:

| pairing (never-awaken Rukia) | b0a1 S100 / 300 / 500 | baseline S100 / 300 / 500 | b2a0 S100 / 300 / 500 |
|---|---|---|---|
| RY (vs Yamamoto) | **36 / 31 / 35** | 23 / 24 / 21 | 30 / 30 / 21 |
| RK (vs Kenpachi) | **28 / 24** / 17 | 3 / 2 / 6 | 11 / 21 / 15 |
| RR (the mirror) | **41 / 42 / 42** | 11 / 14 / 10 | 31 / 33 / 26 |
| IR (vs Ichigo) | **32 / 37 / 33** | 2 / 5 / 9 | 14 / 19 / 28 |
| SR (vs Senjumaru) | **36 / 37 / 39** | 9 / 12 / 12 | 28 / 31 / 27 |
| BR (vs Lille) | **32 / 34 / 36** | 7 / 6 / 6 | 24 / 25 / 27 |
| HR (vs Hisagi) | **44 / 40 / 41** | 8 / 14 / 10 | 24 / 30 / 22 |

**20 of 21 rows pass** (the baseline 3, b2a0 17); the one failure RK at S500 (17: the Kenpachi bug). Her never-awakening
Shikai now wins more than half of these against every opponent but Kenpachi: the awakening is no longer what wins her
matches (it may even cost: her bands against Lille, above; recommendation 1).

## Risks

- Kenpachi stays 6 / 80: the known §17.6 bug (his Kikon follow-up through her guard, the post-block hold); his
  KEN-FIRST-STRIKE J1 (2.2 m lunge, 7 f) opens ~37 k of his damage in 40 matches. Main's fix should move it most.
- Lille 43 / 80: his base snipe loop from 4.5 m+ (KAMAE -> level 2 in 20 f) has no answer that measured better than doing
  nothing; in her bands she loses to his awakened forms (-18 dealt 676 / taken 10333 in 40 matches).
- The payoffs are measured against the frozen HARD CPUs (their Hoho rates, Lille's let-go); a change to an opponent's CPU
  (e.g. his Hoho of a committed move) changes them: re-measure (`:poke`) with the same logs.
- A neutral that waits is a passive look against a human who also waits (the HARD tables only; NORMAL keeps 65 % of the
  generic picks, its share 0.454).
- `*RU-AI-HOLD*` (b2a0's hold for the oki's timed press) now carries its tick: read only on the tick it was set.

## Shared-code recommendations (not made)

1. AI-AWAKEN-P has no per-opponent gate: against Lille her bands lose badly (above); a kit hook (`:awaken-when` with the
   opponent) would let her keep the Shikai where the A/B says so.
2. Main's §17.6 fix (`:held` / `:block-hold`) at integration, as the brief says.
3. aieval counts the seal's KIKON line as no damage (b0a0, b2a0 said the same): the seal's 2 Konpaku score only the O's 70.

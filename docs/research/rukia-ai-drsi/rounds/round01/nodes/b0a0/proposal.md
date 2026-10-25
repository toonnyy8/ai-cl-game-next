# Cell b0a0 (round 1): matchup tables — the opponent and his form decide her plan

Primary axis: **the opponent and his form** (his kit's frame data and reach, read through his kit: `kit-character` /
his J1 move as his form has it now, and what she perceives of him in the SNAP; never his inputs). Every new chance scales
EASY <= NORMAL <= HARD and is rolled once per event (a decision, an intent re-pick, a landed hit, a bind, a guard
episode, a move of his).

## Result (EVAL_COMMAND, 40 seeds, the final file)

| | baseline | b0a0 |
|---|---|---|
| **score** | 0.5898 | **0.7154** |
| strength | 0.273 | 0.325 |
| masher | 1.0 | 1.0 |
| signature | 0.616 | **0.836** |
| NORMAL share (band 0.30-0.60) | 0.423 | 0.4375 (factor 1) |
| pacing (NORMAL medians) | 100.8-140.4 s, all K.O. | 97.5-149.6 s, all K.O. |

str_by_opp (HARD, of 80): Yamamoto 29 -> 35, Kenpachi 0 -> 0, Ichigo 58 -> 55, Senjumaru 44 -> 31, Lille 0 -> 8,
**Hisagi 0 -> 27**. sig_by: kstring 0.302, poke 0.270, burst 0.195, kido 0.042, **seal 0.026** (0.002), counter 0.085,
Breaker 0.030, O (ru-kikon) 0.017 (0.097), plain J 0.013 (0.094), the bands' O 0.020.

**Paired blocks** (the same seeds and seats, 240 HARD matches each, six opponents x both seats; my combat-log runner over
the native sim, the frozen evaluator's classes for the signature):

| block (seeds) | b0a0 wins | baseline wins | diff (SE) | signature b0a0 / baseline |
|---|---|---|---|---|
| 1-20 | 81 | 69 | +0.050 (0.036) | 0.836 / 0.613 |
| 21-40 | 75 | 62 | +0.054 (0.033) | 0.836 / 0.618 |
| 41-60 | 59 | 64 | -0.021 (0.035) | 0.825 / 0.612 |
| 61-80 | 75 | 72 | +0.013 (0.038) | 0.830 / 0.624 |
| all 960 | 290 | 267 | +0.024 (0.018, 1.3 SE) | |

Strength: a tie at 960 matches (+0.024, 1.3 SE) with the wins moved between matchups (of 160 each: Hisagi 1 -> 48,
Lille 0 -> 13, Yamamoto 57 -> 67, Ichigo 123 -> 92, Senjumaru 86 -> 70, Kenpachi 0 -> 0). Signature: +0.21 in every block
(far past 2 SE). The score's gain is the signature's.

## Step 1: the history

Round 1: no earlier cell. The baseline (BASELINE_DIR/proposal.md): AI v2's perfect-Hoho counter-fighter, the ice cash-out,
the Shikai zone (BYAKURAI / TSUKISHIRO / SOKATSUI-RIKUJOKORO / SP2 at >= 2 layers), the bursts by link, the SP enders,
REIDO, the bands' discs; no reading of the opponent, no payoff weights.

## Step 2: the diagnosis (combat logs, tools/simgate/run-log.lisp as aieval runs it)

1. **RIKUJOKORO's bind was wasted (a located bug).** 63 of her 105 binds landed (60 %), and the cash reflex (RUKIA-AI-CASH:
   SHIRAFUNE first within 4.5 m) pressed SP2 into the bound victim 35 f later, every time: the seal (catalogue E8 / E9c: the
   bind -> O lands the Kikon from full health) was never cashed (seal 0.2 % of her damage).
2. **The O ender into a victim who isn't red.** Her non-red O follow-ups landed 16 % (Hisagi) to 42 % (Ichigo) and were
   punished after the guard; the O is not signature (ru-kikon 9.7 % of her damage).
3. **J links where K links combo.** J1 K2s K3 176 > J1 J2 J3 110 (catalogue); plain J 9.4 % of her damage, not signature.
4. **Lille's awakened dash L** (BR-E-L1 / BR-OE-L1, a charged dash from afar) sits outside the generic threat reach
   (snap-reach + 1.5): of 311 starts in 20 matches 171 hit her, 28 were blocked; it opened 78 of his combos (~21000 damage).
5. **The Breaker against the generic anti-Breaker J1**: it landed 65 % against Ichigo, 83 % against Senjumaru, 18 % against
   Yamamoto (his Bankai's J1 met it 23 times in 10 matches), 0 % against Kenpachi, Lille, Hisagi.
6. **Kenpachi** (0 of 80, matches ~45 s): his O ender's follow-up **lands through her held guard** (45 of 46 non-red
   follow-ups in 20 matches; a trace showed her in :GUARD from the follow's start to its hit) — every landed string is
   -2 Konpaku; his first-strike J1 (2.2 m lunge, timed to her closing) opened 95 of his combos in 20 matches; his
   KEN-HOHO-COMMIT perfect-Hohos her K / L / SP within reach + 1 at 75 % (HARD). Not hers to fix (below).

## Step 3: the tactics by condition (duel/lisp/rukia-ai.lisp)

### A. Her zones against his reach (RUKIA-AI-ZONE-OF, RUKIA-AI-HIS-J: his J1's far edge + its slide <= 0.8 m, from his
kit as his form has it)

| zone | distance | her best means (sheet / catalogue) |
|---|---|---|
| :close | < 1.6 m | J1 7 f -> K2s K3 +L (her J range) |
| :his-j | 1.6 m .. his J lunge (<= 2.4) | inside his J, outside hers: K1, back off, guard |
| :k | .. 2.9 m | K1 17 f, edge 2.85 m -> K2 K3 +L 331 |
| :mid | .. 5.3 m | RIKUJOKORO (bind -> O: the Kikon), BYAKURAI 12 f to 6.15 m, SP2 to 5.3 m (110 + 25 a layer), SOKATSUI |
| :far | .. 8 m | TSUKISHIRO's ring (+2 layers), approach |
| :out | > 8 m | approach |

### B. The neutral table: payoff weights per zone and opponent (*AI-RU-MU-DEFAULT*, *AI-RU-MU*; RUKIA-AI-MU-DECIDE: one
weighted roll a neutral decision, *AI-RU-MU-P* EASY 0 / NORMAL 0.35 / HARD 1.0 of the decisions; else the old pick)

| opponent (why) | intents | :close | :his-j | :k | :mid | :far | :out |
|---|---|---|---|---|---|---|---|
| default | approach 2 pressure 3 zone 2 defend 1 | q 6 breaker 1 f 1 guard 1 back 1 | f 3 back 2 guard 2 q 1 | f 5 byakurai 1 guard 1 wait 1 | byakurai 3 **rikujo 4** sp2 1 sokatsui 1 tsukishiro 1 in 1 wait 2 | tsukishiro 4 enbu 1 in 2 wait 2 | in 3 enbu 1 wait 1 |
| Kenpachi (J1 7 f 2.2 m lunge, K1 2.8 m; his Hoho takes K / L / SP: hazards and J) | mid 3 approach 2 defend 2 zone 1 | q 3 guard 3 back 3 breaker 1 | back 4 guard 3 f 1 | f 1 back 3 guard 2 rikujo 1 | byakurai 1 **rikujo 6** sokatsui 1 tsukishiro 2 wait 2 | tsukishiro 3 wait 3 | wait 2 in 1 |
| Lille (J1 6 f / J2 5 f +0 blocked: no J war; his K1 2.05 < her 2.85) | **poke 4** (2.1-2.8 m) mid 2 approach 1 | q 2 breaker 1 back 4 guard 1 | (default) | **f 6** guard 1 back 1 | **rikujo 5** tsukishiro 2 byakurai 3 sp2 1 in 2 wait 1 | tsukishiro 4 in 3 wait 1 | in 4 enbu 1 |
| Hisagi (J1 8 f but 1.7 m, K1 6 m) | pressure 3 zone 2 approach 1 | q 6 breaker 1 guard 1 | back 2 guard 2 q 1 | f 1 byakurai 2 guard 2 back 1 in 1 | byakurai 4 tsukishiro 2 rikujo 4 guard 1 in 1 wait 1 | tsukishiro 3 wait 2 in 1 | in 2 wait 1 |
| Yamamoto (J1 9 f: her J1 wins; K1 2.6 < 2.85) | pressure 3 approach 2 zone 1 | q 7 f 1 | (default) | f 5 byakurai 1 in 1 | (default) | (default) | (default) |
| Ichigo, Senjumaru | (default) | (default; Breaker by :breaker-p) | | | | | |

Multipliers (RUKIA-AI-MU-K, what she sees and has): 0 when the move can't start or reach; the bind x4 on him held >= 34 f
(a stance — Lille's KAMAE —, a recovery, a stun), x2 on a guard (it binds through one); TSUKISHIRO x4 held >= 46 f, x3 on
him down, x1.5 guarding, x0.3 running; SHIRAFUNE x (1 + his layers); BYAKURAI x2 / K1 x1.5 on him running in; J1 x0.5 into
a guard; the Breaker x her matchup's :breaker-p (x4 on a guard). SHIRAFUNE / SOKATSUI keep one bar for the bind
(*AI-RU-BIND-BAR*). Her intents re-picked from the row (RUKIA-AI-MU-INTENT; her own ranges :poke 2.1-2.8, :mid 3.0-5.0).

### C. The bind's cash: RIKUJOKORO -> O (RUKIA-AI-SEAL-O; *AI-RU-SEAL-O* 0.3 / 0.8 / 1.0, one roll a bind)

He is sealed (his FIGHTER-SEAL): the O, held through its strike; the seal makes the follow-up the Kikon from any health
(tagged "seal": signature). RIKUJOKORO held 14 f past SOKATSUI's 16 (*AI-RU-RIKUJO-HOLD*: the bind 58 f, long enough for
her recovery and the O from 6 m). 20 matches vs Kenpachi / Lille / Hisagi: 84 casts, 46 binds, 35 seal Kikons.

### D. The confirm: the catalogue's damage as weights (:string-k, RUKIA-AI-BURST-P, RUKIA-AI-SP-ENDER)

| landed link | options (weight) |
|---|---|
| J1 / J2 / K1 / K2 | the K link 0.9 (:string-k, every form: J1 K2s K3 176 > J1 J2 J3 110); the link-1 / -2 bursts 0.05 (HARD) |
| K3 (the Shikai) | **L 白漣 6** (331, knockdown), SHIRAFUNE 1 + 2 a layer (393 at 3; a bar beyond the bind's), ORANGE 3 (416; FS >= 85, him reeling within 3 m), nothing 1 |
| J3 (the Shikai) | L 霜陣 2 (with layers), SHIRAFUNE 1 + 2 a layer, nothing 3 (+5 at 2.54 m) |
| K3 (the bands) | the band's L 6 (285 / 349 / 512), SP2 4 (350-575), SP1's wave 3 (306-608), ORANGE 3, nothing 1 |
| the O ender | never into a victim who isn't red (:o-ender 0.0; red: the generic O ender, the Kikon) |

NORMAL / EASY: the cash-outs decide *AI-RU-K-ENDER-L* (0 / 0.3 / 1.0) of the pick, the rest ends the string; the K3 burst
x *AI-RU-BURST-3* (0.3 / 0.7 / 1.0).

### E. The cash-out of a stun / a recovery (RUKIA-AI-CASH-PICK, the Shikai; one weighted roll)

J1 6 (in reach, his left >= 8 f: J1 K2s K3 +L), K1 6 (>= 18 f: K1 K2 K3 +L 331), SHIRAFUNE 2 + 2 a layer (bar beyond the
bind's), RIKUJOKORO 6 (his left outlasts the bind: the seal -> O), BYAKURAI 1 (2-6 m), the O 1 (a stun only). The bands
keep the old order.

### F. His specific threats

- **Lille's awakened dash L** (:guard-on (:br-e-l1 :br-oe-l1); RUKIA-AI-MU-GUARD, *AI-RU-MU-GUARD-P* 0 / 0.4 / 0.9 a move
  of his): seen charging or coming within 25 m: a long guard. 40 matches: 258 hit / 521 blocked (was 171 / 28 per 20).
- **The Breaker read** (RUKIA-AI-MU-BREAK: the generic one's window, one roll a guard episode): *AI-RU-MU-P* of the
  episodes by her matchup's :breaker-p (Ichigo 0.6, Senjumaru 0.7, the rest 0: their J1 meets its dash), the rest the
  generic 0.4 (NORMAL keeps breaking Bankai West's ward: with the table on every episode NORMAL's share fell to 0.325,
  Yamamoto 8 of 80).

## Why it is not a repeat

Round 1, no earlier cell. Against the baseline: the opponent is read (his character's table, his form's J1 lunge for
the zones, his listed moves), every pick is a payoff-weighted roll, and two located bugs are fixed (the bind's cash, the
generic O ender on a victim who isn't red). The O-ender's Kikon chance is kept only on a red victim; the seal's Kikon
(signature) replaces it.

## Tried and dropped (measured)

| variant | result |
|---|---|
| anti-approach stop (BYAKURAI / SOKATSUI as he walks in, one roll an approach) | fed his perfect Hoho: vs Kenpachi his counters 22 -> 35, all opponents 28 -> 21 of 120: removed |
| awakened-Lille "wait and guard" table | 4 -> 0 of 40: removed |
| aggressive approach table vs Lille | 3 vs 4 of 40: no change, kept the first |
| :guard-on range 14 m vs 25 m | 262 / 258 dash hits, 4 / 4 wins: no change (25 kept) |
| the O ender by his measured guard failure (:o-end Ichigo 4, Yamamoto 3) | Ichigo +5 of 80 (seeds 1-40), +10 of 40 (41-60); Yamamoto -1 of 80 / +7 of 40; signature -0.010; score 0.7123 vs 0.7146: a tie, the simpler file kept (a candidate for a later cell: Ichigo's 42 % follow-up land rate) |

## The awaken A/B

Changed: NORMAL's Shikai play (the matchup table on 35 % of its decisions, the K links, no O ender on a victim who isn't
red, the ender pick, the bind's O). The awakening rule (AI-AWAKEN-P, :awaken) is unchanged. The never-awaken side's wins
of 60 per stream, next to the baseline's (the same command, the baseline tree):

`python3 tools/simgate.py --summary --pairs 3,4,5 --seed0 S --seeds 60 --cmd 39020 -j 2` (she is P1, the never-awaken side)
and `--pairs 8,12,23,30 ... --cmd 39002` (she is P2), S = 100 / 300 / 500 (pass: >= 20 of 60):

| pairing (never-awaken Rukia) | b0a0 S100 / 300 / 500 | baseline S100 / 300 / 500 |
|---|---|---|
| RY (vs Yamamoto) | 17 / 19 / 10 | 23 / 24 / 21 |
| RK (vs Kenpachi) | 10 / 9 / 8 | 3 / 2 / 6 |
| RR (the mirror) | 15 / 16 / 18 | 11 / 14 / 10 |
| IR (vs Ichigo) | 14 / 19 / 18 | 2 / 5 / 9 |
| SR (vs Senjumaru) | **23** / 19 / **28** | 9 / 12 / 12 |
| BR (vs Lille) | **21** / 15 / **22** | 7 / 6 / 6 |
| HR (vs Hisagi) | **32** / **25** / **27** | 8 / 14 / 10 |

7 of 21 rows pass (the baseline: 3, all RY); 17 of 21 rows nearer the line or past it than the baseline's; RY's three
rows fell below it (her NORMAL against Yamamoto, 39 -> 27 of 80 in the NORMAL band runs too). (Her A/B was left
"until her CPU is rebuilt", DUEL_RUKIA_TYBW §11.2: these are the numbers for that call.)

## Risks

- Kenpachi stays 0 of 160: his O-ender follow-up lands through her guard; her table only keeps her out of his J lunge and
  uses the hazards his perfect Hoho can't take.
- Ichigo -31 / Senjumaru -16 of 160 (the O ender's Kikon chance and the plain J strings' +5 pressure gone): the signature
  pays for it.
- Strength varies a lot with the seeds (seeds 41-60 -0.021, 1-40 +0.05).
- The tables are hand-set from the sheets and 10-20 seed probes; NORMAL is in the band (0.4375) but it now differs from the
  shipped NORMAL (its K links, its enders).

## Shared-code recommendations (not made)

1. **Kenpachi's Kikon follow-up through a held guard**: in 20 HARD matches 45 of 46 of his non-red follow-ups landed on
   Rukia as the Kikon; a trace had her in :GUARD (KIKON-LOCK 1) from the follow's start to its hit (KE-KIKON's dash-track
   150 deg/s vs the guard's in-front test?). Her own follow-ups on others land 16-42 %. Worth a look in combat.lisp.
2. While a CPU holds the guard it pressed after a blocked hit (BRAIN-STEP's hold, :act :hold), no reflex runs: a small
   block punish (his J3 blocked -4 against her J1 7 f) can't be read by a kit's :reflex.
3. aieval counts a Kikon's hit lines ("-> Px KIKON") as no damage: the seal's Kikon strike counts, its Kikon line does not.

# Cell b3a0 (round 1): "the hunter's clock" — every commitment timed on the opponent's clock; the wings as armour first

Freeze 36e93c7, a new direction from the baseline (no parent). Only `duel/lisp/barro.lisp` (his CPU parts) and the
`BARRO-CPU-TESTS` section of `tests/duel-rules-test.lisp` changed. Final measure (`python3 tools/aieval.py --char 6
--seeds 40 -j 2`, score.json; the delivered file = v5 below, comments edited after, re-measured last: the same JSON).
Host test `tests/duel-rules-test.lisp` 8299 checks ALL PASS (BARRO-CPU-TESTS rewritten: the clock, the hold levels, the
stance pick, the string call with the reserve, the armour test, the kits' :plan / :keep / :burst / :sig-hold pinned);
`tools/pkgcheck.sh duel` 0 / 0 / 0.

| | baseline (40 seeds) | b0a0 (rescored) | b1a0 (rescored) | **b3a0 (40 seeds)** |
|---|---|---|---|---|
| score | 0.0 (raw 0.1702) | 0.8032 | 0.6985 | **0.9192** |
| strength (HARD, both seats) | 0.003 | 0.652 | 0.517 | **0.943** |
| masher | 0.302 | 0.953 | 0.802 | **1.0** |
| signature | 0.272 | 0.879 | 0.828 | **0.856** |
| NORMAL share (band 0.30–0.60) | 0.05 → ×0 | 0.5025 | 0.5125 | **0.52** → ×1 (Y 50/80, K 14/80, R 52/80, I 32/80, S 60/80) |
| pacing medians Y K R I S (cap 220, all 40/40 K.O.) | 130.7 113.6 122.2 122.4 123.6 | 128.1 134.3 170.4 164.7 169.5 | 121.2 123.7 149.1 143.9 152.1 | 123.2 120.7 170.1 150.8 168.1 |

sig_by (top): br-e-k 0.243, br-oe-k 0.134, br-oe-kl 0.103, br-e-kl 0.102, plain-jk 0.094, charged 0.071, br-rc 0.069,
br-s-l1- 0.034, br-k-hiren-c 0.034, br-s-j 0.032, br-w-nijushi-c 0.024; outside the whitelist: br-w-kikon 0.012, counter
0.009, Breakers 0.011, level-1 dash / cuts 0.010, Kikons 0.008.

## History read

- **Baseline** (score 0): confirmed broken; its own proposal and score.json read.
- **b0a0** (0.8032, rescored = its own): "hold L as the plan" — L's hold length by distance (tap near, level 2 / 3 far),
  the charge let go when his attack is perceived in reach + 0.8, the stance as a punish, the CPU's R17 link
  (BR-AI-LINK-CMD), **the turn before the follow-up after the dash through him** (its single biggest step: 0.23 → 0.52
  HARD at 10 seeds), EN decisions every 10 f, *BR-AI-DIFF* 0.25 / 0.5 / 1.5 for a fair NORMAL. Its remaining weak
  spots, measured here by running its file (100 HARD matches, 10 seeds both seats: 71 / 100): KIN dealt 34 k / took 94 k,
  BASE dealt 76 k / took 112 k, and **138 openings (26 k damage) taken while charging EN's dash** (its let-go reacts to an
  attack already in reach + 0.8 m with an 8 f perception delay against 7 f J1s: too late). EN / the owl EN are where the
  damage is made (dealt 275 k + 127 k, taken 37 k + 7 k).
- **b1a0** (0.6985): routes chosen on events, the held L by the brain, an EN window plan, the R17 link, a Breaker reach
  model, the owl early (2 wings, 8 m). Its owl finding (the best dealt / taken ratio) agrees with mine below; its routes
  are a different, lower-scoring decomposition of the same pieces.

The ideas both cells validated and that were **located bug fixes of the baseline** are kept as pieces (re-implemented
here): the turn before the follow-up (the dash leaves him behind Lille), L held through the vpad by `:sig-hold`, the
CPU's R17 link, the per-10-frame EN decision, the follow-up-then-SP2 string call, the 0.25 / 0.5 / 1.5 difficulty split.
What is new is how every commitment is decided and how the wings are spent (below).

## The action policy (行動方針)

**THE CLOCK** (`BR-AI-CLOCK`, pure core `BR-AI-TTT`): the frames before the opponent's attack could land on Lille, as
perceived: what is left of the opponent's own commitment (a recovery, a stagger, a knockdown and its wake-up,
`BR-AI-BUSY`); his reaction (`*BR-AI-OPP-REACT*` 12 f) unless he is coming already (his perceived closing speed over 4
steps, `BR-AI-CLOSING`, ≥ 0.03 m/f); his run to his poke's reach (`*BR-AI-OPP-REACH*` 2.2 m at `*BR-AI-OPP-V*` 0.16 m/f,
less what he closed in the perception delay); his poke's startup (7 f). 0 when his attack is on Lille now.
- **A charge starts only when its least useful level fits** (`*BR-AI-COMMIT*`: the snipe 32 f = level 2's 20 f held + S 8
  + margin, a level-1 snipe only reaches 4 m; the dash 26 f = the turn's L hand-off 10 f + S 12 + margin, the dash meets
  a runner at whatever level it reached), **is held to the highest level that fits** (`BR-AI-SIG-HOLD` /
  `BR-AI-HOLD-FOR`: 46 f for level 3, 26 f for level 2), **and is let go the moment the clock runs shorter than the shot /
  dash takes** (`BR-AI-CHARGE-TICK`, the CPU branch of BR-S-TICK's hold phase: a prediction, not a reaction to an attack
  already in reach). Over a knockdown it holds on so the shot lands as he gets up (measured: never fired, charges and
  knockdowns rarely meet).
- **The stance pick** (`BR-AI-STANCE-PLAN`, the base stance and EN alike): the fast Step off his attack; out of melee the
  charge when it fits, else the Step out to buy clock; K when he can't answer K1 (his perceived open frames ≥ K1's S),
  J when he can't answer J1; under his attack J in reach; else K when the clock fits K1 (`:k` of the time when J
  reaches too), else J. In EN, **the wing armour counts as clock**: armoured, K is pressed into his approach.

**THE WINGS AS ARMOUR FIRST** (`BR-AI-CALL`'s reserve, `BR-AI-ARMOUR-P`): his kit's wing armour (BR-ARMOR-P: his own attack
can't be stopped while he holds its price, 4 wings JILLIEL, 2 the owl) makes the wings two resources at once. His CPU
**keeps the armour's price in reserve** (`:keep` = BR-ARMOR-COST in every awakened form): no L L line below it, SP2 (which
spends every wing) only short of the reserve or at `:sp2-all` (8 JILLIEL; 5 the owl, its volley's 300 tier); the owl's
8-wing volley (480) at once (`:volley-at`). With the reserve held:
- **KIN meets his approach with an armoured J1** (`:plan :armour`, one roll per action of his, J1's reach + 0.5 / 0.6 m):
  a first strike (Kenpachi's FIRST-STRIKE, every J1 on an idle KIN) becomes a trade he wins, J1 → L → the R17 link into
  the stance;
- **the burst into the owl stays in reach** (`:burst (:p 0.6 :wings 4 :in 7.0)`, rolled in KIN and now in EN's windows):
  the owl's ×1.2, its 2-wing armour and its full volley.

**Per form**
- **Base**: J pokes close (the bands; nothing far: the clock picks the snipe), a J / K link → L → the stance at f4 (J off a link: the
  gun-kata combos off J's flinch); the stance as a punish when his recovery fits its opener (`:punish`, per action);
  the snipe from ≥ 4.5 m when the clock fits level 2 (`:snipe`, one roll a 30 f window), held to level 3 when it fits.
- **KIN / the owl KIN**: the dash's charge from 3–8.6 m when the clock fits (L held through the turn, R13; `:dash`, a
  window); the armoured J1 (above); J / K links → L → the R17 link (K1 in its reach `:link-k`, else J1); the burst.
- **EN / the owl EN** (rooted 30 f): one decision every 10 f (`BR-AI-EN`): the clocked stance pick; the dash charged to
  what the clock fits out of melee (≤ 8.6 m); farther nothing (EN lapses into KIN, which walks). The bands are a
  placeholder there (`:moves ((0 99 nil 1))`).
- **The stance strings** (`BR-S-CPU-CALL` → `BR-AI-CALL`): the K route's L L line a special (70 a line: the best damage a
  special buys) down to the reserve, SP2 at the string's end; the J route's SP2 at `:sp2-j` (the base: 1 pip,
  HIRENKYAKU 40 a pip) else its refill line.
- **The turn**: after the dash through him he reels behind Lille: the turn first (`*BR-AI-TURN-P*` 0.2 / 0.4 / 1.0, one
  roll per action), then the generic follow-up.

**Difficulty**: every chance through `BR-AI-CHANCE` (`*BR-AI-DIFF*` 0.25 / 0.5 / 1.5) or a difficulty table; rolls once
per window / opponent action (`BR-AI-EVENT-ROLL`) / stance / string link, never per step; the clock is a rule, not a
chance (it reads the perceived SNAP). Randomness only SIM-RND01. The reflex returns NIL when there is nothing to do (the
learner's clock and AI-DECIDE's neutral run); EN's decisions are once per 10 f and give way to the generic guard under
his attack.

**Kept working**: AI-AWAKEN-P / `:awaken` untouched; every debug / test command; the pace counters (new: ai-snipe,
ai-dash, ai-armour, ai-burst, ai-let-go, ai-meaty, ai-charge, ai-link-k / -j, ai-punish); BR-LEARN-KAMAE still reads the
stance's K plan; `:sig-hold` reads the brain through AI-BRAIN (the ASSIST: no ring yet → the distance fallback, level 3
from range); BR-TICK-BRAIN gates every tick branch (BR-S-TICK's hold phase, BR-TO-EN-LINK-TICK; the human branches
byte-for-byte the old ones). New CPU state: three BRS slots (ai-key, ai-roll, ai-en).

## Evidence (each step: 100 HARD matches, 10 seeds both seats vs the five; then the frozen evaluator at 40 seeds)

| step | change | HARD 10-seed | aieval 40 seeds |
|---|---|---|---|
| — | b0a0's file on the same 100 matches | 71 / 100 | (0.8032) |
| v1 | the clock as a worst case (he always runs in at once) | 15 / 100 | — : it forbade almost every charge (KIN 353 k ticks, EN 68 k: the dash never fit) |
| v2 | the clock with his reaction / perceived closing speed, `*BR-AI-COMMIT*` | 77 / 100 | 0.8644 (str 0.80, mash 0.99, sig 0.866, NORMAL 0.46); dash-charge openings 138 → 76 |
| **v3** | **+ the wing reserve (= the armour's price)** | **95 / 100** | **0.9147** (0.93, 1.0, 0.857, NORMAL 0.4825): bursts 95 → 235, 8-wing volleys 11 → 74, armoured hits 216 → 356 per 100 matches; Kenpachi 7 → 17 / 20 |
| v4 | + a clocked guard (short guards re-raised while he closes in) | 90 / 100 | reverted: base openings 404 → 473 (each re-raise is hit in its raise frames) |
| **v5** | **+ the burst at 4 wings / 7 m / 0.6, rolled in EN too** | 96 / 100 | **0.9192** (0.943, 1.0, 0.856, NORMAL 0.52) — **delivered** |
| v6 | + `:l-after-*` 1.0, no neutral K1 in KIN | — | 0.9152 (0.912, 1.0, 0.876, NORMAL 0.565) |
| v7 | v5 + `:l-after-j` 1.0 only | — | 0.9147 (0.910, 1.0, 0.877, NORMAL 0.515) |

v6 / v7 show the trade the generic `:l-after-j` makes: always L after a J link → signature +0.02, HARD strength −0.03
(both runs), net −0.004 and NORMAL up (the key is not difficulty-scaled): not taken.

Per form at v5 (the 100 matches): dealt / taken BASE 70.5 k / 116 k, KIN 30 k / 64 k (b0a0: 34 k / 94 k), EN 220 k / 14 k,
the owl KIN 22 k / 16 k, the owl EN 167 k / 2.5 k (b0a0: 127 k / 6.9 k).

## Why not a repeat

Not a retune of b0a0's or b1a0's tables. Two mechanisms neither had: (1) **the clock** decides every commitment
(start, level, release) from the opponent's perceived commitment, reaction and closing speed — b0a0 picked the level by
distance and released on an attack already in reach; b1a0 by distance bands; (2) **the wings as armour first** — no
earlier cell reserved wings (both spent every wing on L L / SP2): the reserve is the step that took HARD from 77 to 95 of
100 by keeping the armour, the owl's burst and its full volley in reach. The pieces both cells validated (the turn, the
held L, the R17 link) are kept as located fixes, not as the direction.

## Awaken A/B (the burst rule changed; the base form's play too)

`python3 tools/simgate.py --pairs 21,22,23,24,25 --seed0 S --seeds 60 --cmd 39020 -j 2` (P1 Lille II never awakening,
NORMAL; the never-awaken side's wins of 60, Y K R I S):

| seed0 | BY | BK | BR | BI | BS |
|---|---|---|---|---|---|
| 100 | 7 | 0 | 0 | 1 | 1 |
| 300 | 6 | 1 | 0 | 2 | 0 |
| 500 | 2 | 1 | 0 | 0 | 2 |
| baseline 100 / 300 / 500 (b1a0's measure) | 2 / 2 / 6 | 9 / 7 / 3 | 0 / 0 / 0 | 1 / 0 / 0 | 1 / 1 / 1 |
| b0a0 100 / 300 / 500 | 4 / 2 / 4 | 1 / 2 / 0 | 1 / 1 / 0 | 0 / 0 / 0 | 1 / 1 / 0 |

Every match a K.O. but one (BR, seed0 100: one 300.0 s time-out of 60; medians 127.7–174.4 s). All rows far under the
pass mark 20, as for the baseline and both earlier cells: his base form at NORMAL does not win without the awakening.
Listed for the integration gate; not a regression of this cell (BK is lower than the baseline's, BY higher).

The burst acts only in a JILLIEL form, so the never-awaken side never uses it: these rows measure his NORMAL base form
alone (×0.5 chances) against awakening opponents.

## Risks

- NORMAL 0.52 is mid-band; the reserve is a rule (all difficulties), so any later change that strengthens the awakened
  forms raises NORMAL with HARD (v6: 0.565). Kenpachi stays his worst pairing (NORMAL 14 / 80; HARD 17 / 20 at 10 seeds).
- Pacing medians 120.7–170.1 s, ≥ 50 s under the 220 cap (no risk).
- The clock's opponent constants (2.2 m, 0.16 m/f, 7 f, 12 f reaction) are roster-wide, not read from his kit; a new
  faster character would need them revisited.
- The snipe's level 3 is rare (71 of 800 snipes: the clock seldom fits 58 f); the "meaty" hold over a knockdown never
  fired in 100 matches (kept, harmless).
- The ASSIST's AUTO routes that press L get the distance fallback of `:sig-hold` (no ring in the assist brain: level 3
  from range, a tap near).

## Shared-code recommendations (not done)

- ai.lisp STRING-REFLEX: scale `:l-after-k` / `:l-after-j` by the difficulty (a kit factor) — b0a0 and b1a0 asked the
  same; here it would buy the v6 / v7 signature without raising NORMAL.
- A generic "closing speed" helper (Kenpachi's KEN-CLOSING, Lille II's BR-AI-CLOSING are the same idea) and a generic
  clock for kits that charge.
- A generic guard re-raise is punished in its raise frames (v4): a kit hook for a held neutral guard that does not drop
  would let a counter-puncher wait safely.

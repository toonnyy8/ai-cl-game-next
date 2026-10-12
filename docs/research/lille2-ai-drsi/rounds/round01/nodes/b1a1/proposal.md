# Cell b1a1 (round 1, refines b1a0): "meet his commitment" — the Step-in interrupt, the stance's exit, the charge let go, on b1a0's routes

Freeze 36e93c7. Parent b1a0 (its `barro.lisp`, its BARRO-CPU-TESTS section spliced in). Only `duel/lisp/barro.lisp` (his CPU
parts: the `:ai` plists, BR-AI-* functions / knobs, BR-S-CPU-CALL, the CPU-only `:hold` branch of BR-S-TICK gated by
BR-TICK-BRAIN, six new BRS slots for CPU state) and the `BARRO-CPU-TESTS` section of `tests/duel-rules-test.lisp` changed.
Host test 8332 checks ALL PASS; `tools/pkgcheck.sh duel` 0 / 0 / 0. Final measure (`python3 tools/aieval.py --char 6 --seeds
40 -j 2`, score.json = v10 below, the delivered file byte for byte):

| | baseline | b0a0 | b1a0 (parent) | b2a0 | b3a0 | **b1a1 (v10)** |
|---|---|---|---|---|---|---|
| score | 0.0 (raw 0.1702) | 0.8032 | 0.6985 | 0.915 | 0.9192 | **0.9529** (raw 0.9529) |
| strength (HARD, both seats) | 0.003 | 0.652 | 0.517 | 0.882 | 0.943 | **1.0** (400 / 400) |
| masher | 0.302 | 0.953 | 0.802 | 1.0 | 1.0 | **1.0** |
| signature | 0.272 | 0.879 | 0.828 | 0.905 | 0.856 | **0.882** |
| NORMAL share (band 0.30–0.60) | 0.05 (×0) | 0.5025 | 0.5125 | 0.53 | 0.52 | **0.5425** (×1; Y 61, K 20, R 37, I 44, S 55 of 80) |
| pacing medians Y K R I S (cap 220, all 40/40 K.O.) | 131 114 122 122 124 | 128–170 | 121–152 | 143–188 | 121–170 | **123.5 135.7 145.4 149.1 147.6** |

sig_by (top): br-e-k 0.222, br-e-kl 0.123, br-oe-k 0.104, plain-jk 0.104, br-rc 0.095, charged 0.075, br-s-k 0.070,
br-oe-kl 0.065, br-s-l1- 0.048, br-s-kl 0.044, br-w-nijushi-c 0.012, br-s-j 0.012; Kikons / Breakers / counters ≤ 0.005 each.

## History read (every proposal, score.json and score.rescored.json; the rescored number trusted)

- **baseline** (0): the stance at 4 m for 1.9–2.6 m strings, never charges, waits in the rooted EN.
- **b0a0** (0.8032): L's hold as the plan, the R17 link, **the turn before the follow-up** after the dash (its biggest
  step, HARD 0.23 → 0.52), *BR-AI-DIFF* 0.25 / 0.5 / 1.5.
- **b1a0** (0.6985, my parent): routes on events (confirm → stance, punish → stance, string call, held L, EN window plan,
  the CPU's R17 link, the anti-Breaker reach model, the owl at 2 wings). Its weak strength is a **located omission**, not a
  flawed idea: its logs (6 seeds × 5 opponents × both seats, HARD: 29 / 60) show the generic follow-up J1 after the dash
  through him whiffing **253 of 258** times (he reels behind Lille), 165 neutral Kikons (32 hits, 29 combos opened on him),
  76 guard-break Breakers (21 hits, 45 + 14 combos opened on him), and the idle attack-state forms opened 185 + 107 + 56
  times (KIN dealt 18.7 k / took 85 k).
- **b2a0** (0.915): the opponent's reach envelope (ward / kite), the Kikon only on openings, the unguard dash back, the
  snipe let-go fix, the owl at 3 wings.
- **b3a0** (0.9192): the clock for every charge, **the wings as armour first** (the reserve = the armour's price: HARD 77 →
  95 / 100), the owl at 4 wings / EN windows.

So the parent's gap was three bugs / omissions other cells had already located and fixed; I take those fixes (credited),
then spend the cell on what the logs of the fixed file showed next — the opponents' **commitments into Lille** (the Step
in, the walk into his first-strike envelope, the hit on a charge, the re-approach after a string's end), which no cell
answered on the event itself.

## The action policy (行動方針)

b1a0's routes stay as they were (confirm J / K → L → the stance string; awakened, the turn skipped by the CPU's R17 link;
the punish into the stance; the charged snipe / dash from range; EN's window plan; the anti-Breaker model). On top:

**Taken from the history (located fixes, credited):**
- **The turn before the follow-up** (b0a0): him reeling > 1 rad off Lille's facing (after the dash through him) → `:WAIT`
  (the fighter turns) instead of the generic follow-up (`BR-AI-TURN-WAIT`, *BR-AI-TURN-P* 0.2 / 0.3 / 1.0, the react roll).
  Follow-up J1 hits 5 / 253 → 290 / 338.
- **The Kikon only on an opening** (b2a0): every form's `:kikon-range` 0; `BR-AI-KIKON` on a red opponent perceived open
  for the rush's aura + startup + 2 f (0.05 / 0.15 / 1.0).
- **The long guard answered with a dash back** (b2a0's unguard) to 5.5 m instead of the generic Breaker (0.0 / 0.1 / 1.0).
- **The wing reserve** (b3a0): `BR-AI-CALL` (pure) — no L L line below `:keep` (= BR-ARMOR-COST: JILLIEL 4, the owl 2), SP2
  (spends all) only short of the reserve or at `:sp2-all` (8 / 5), the owl's 8-wing volley at once (`:volley-at`); the
  base (no armour) keeps b1a0's call.
- **The envelope kite** (b2a0's ward, kite branch only, `BR-AI-KITE`): free in an attack-state form inside his first-strike
  envelope (his J1 reach + lunge ≤ 0.8 + 0.5 + closing × 15 f), him free: a dash back to it + 2 m, one roll a 24 f window
  (0.01 / 0.03 / 0.8). Measured: Kenpachi's FIRST-STRIKE J1 opened an idle KIN 37 times in 12 matches before it.

**New in this cell:**
1. **The Step-in interrupt** (`BR-AI-STEP-IN`, pure core `BR-AI-STEP-IN-PLAN`): the opponents' most common opener on his
   idle attack-state forms was STEP-IN → STEP-J (a 12 f hop, iframes f3–9, J cancel at f12). One roll per Step of his
   (keyed on the Step's start tick; 0.03 / 0.08 / 1.0): with his perceived closing speed (≥ 0.08 m/f) the CPU predicts
   where he lands and at which of his Step's frames our J1 (the form's `:q`) would hit: past his iframes and by his f18
   (before his Step-J lands), him then inside our J1's reach → J1 now; landing in the iframes → `:WAIT` a frame; else
   nothing. The J1 that hits opens b1a0's confirm (L → the stance, the R17 link). Measured on the HARD logs: **226 of 249
   interrupts hit**; HARD 46 → 55 / 60 on the diagnosis seeds; aieval 0.8295 → 0.8854.
2. **The stance's exit** (`BR-AI-EXIT`, pure core `BR-AI-EXIT-PLAN`): the first free step back in KIN after EN (a string's
   end leaves him ~2.8 m out, where the opponents' J1s found him standing). One roll an exit (0.05 / 0.15 / 1.0): the armour
   holding (≥ its price) and the dash reaching → L held (the armoured turn into the charged dash); else, nearer than 5.5 m, a
   dash back to the dash's range. (v3 re-entered EN's K1 / J1 from 2.8 m instead: punished; replaced.)
3. **The charge let go** (`BR-AI-CHARGE-TICK` from BR-S-TICK's `:hold` phase, his brain only; pure `BR-AI-LET-GO-P`): b1a0
   held L for a fixed time from the brain's press. Now, his attack perceived in reach + 1 m, or him running / stepping in
   within 3 m, ends the press (the shot / the dash at the level reached); a base snipe held 12–19 f holds on into level 2
   (S 8 lands no later than level 1's S 16, b2a0's finding). One roll a charge (keyed on its start tick; 0.1 / 0.3 / 1.0).
   v5's logs: 41 + 49 combos opened on him in the charges' hold phase.
4. **The far dash by difficulty**: `:far-dash :p` a table (0.05 / 0.15 / 1.0, was 0.3 × the multiplier): HARD charges the
   dash at the first window in its range (after the kite / exit put him there); level 2 only inside 4.5 m, level 3 to 10.2 m
   (`*BR-AI-DASH-REACH*` 6.4 → 4.5: six cuts, three wings).

**Per form** (b1a0's routes + the above): base — J pokes / Step-in J1 / stance punish, J / K links → L → the stance
(gun-kata off J, the rifle off K), the K route's L L, HIRENKYAKU; the snipe charged from 4.5 m (let go when threatened).
KIN / the owl KIN — never idle inside his envelope (kite) or at a string's exit (dash / back); the Step-in J1 → L → the R17
link into EN K1 → K2 → K3 → KL lines above the reserve; the charged dash from 3–10.2 m (the armoured turn); the turn-wait
then J1 → link after the dash; the burst into the owl (b1a0's `:burst`, unchanged). EN / the owl EN — b1a0's window plan.

**Difficulty**: every new chance a table EASY ≤ NORMAL ≤ HARD (host-checked); *BR-AI-DIFF* 0.25 / 0.5 / 1.5 → **0.2 / 0.3 /
1.5** (the new rules made NORMAL strong: v5 NORMAL 0.7075 → ×0.28; v9 at these tables 0.5425). Rolls once per event (his
Step, his action, an exit, a charge, a window); the opponent only through the perceived SNAP (+ the ring's previous SNAP
for his closing speed); SIM-RND01 only.

**Kept working**: AI-AWAKEN-P and `:awaken` untouched, the burst (`:burst`, BR-AI-BURST-P) untouched from the parent; every
debug / test command; the `duel barro` pace counters (new: ai-turn, ai-kikon, ai-unguard, ai-step-in, ai-exit-sig /
-back / -none, ai-kite, ai-let-go); the learner (BR-LEARN-* untouched; every new reflex returns NIL when it has nothing to
do; the waits are a frame for a Step's iframes or the turn); the ASSIST (`:sig-hold` unchanged; the new tick branch runs
only under BR-TICK-BRAIN, the human branches byte-for-byte the old ones).

## The steps measured (aieval, 40 seeds; HARD diag = 6 seeds × 5 opponents × both seats, 60 matches)

| step | change | score | str | mash | sig | NORMAL | HARD diag |
|---|---|---|---|---|---|---|---|
| b1a0 | parent | 0.6985 | 0.517 | 0.802 | 0.828 | 0.5125 | 29 / 60 |
| v1 | + turn-wait, Kikon on openings, unguard, wing reserve | 0.8295 | 0.735 | 0.948 | 0.865 | 0.5425 | 46 |
| v2 | + **Step-in interrupt** | 0.8854 | 0.885 | 0.948 | 0.854 | 0.5675 | 55 |
| v3 | + exit re-entering EN's K1 / J1 | — | | | | | 53 (punished) |
| v4 | exit = dash or back | 0.8861 | 0.882 | 0.953 | 0.856 | 0.515 | 54 |
| v5 | + kite, far-dash p 0.67 flat | 0.2698 (raw 0.9523) | 0.998 | 1.0 | 0.883 | **0.7075** (×0.28) | 60 |
| v6–v8 | + let-go, NORMAL tables lowered (NORMAL diag 20 seeds) | — | | | | 0.64 / 0.585 / 0.59 | |
| v9 | let-go one roll a charge, far-dash table, *BR-AI-DIFF* NORMAL 0.3, the snipe's failed charge roll a tap again (a level-2 floor raised NORMAL) | 0.9518 | 1.0 | 1.0 | 0.880 | 0.5425 | |
| **v10** | level 2 only inside 4.5 m (6.4) | **0.9529** | 1.0 | 1.0 | 0.882 | 0.5425 | |

Per form, 60 HARD matches: KIN dealt / taken 18.7 k / 85.1 k (b1a0) → 13.7 k / 8.4 k (v5); idle-KIN openings 185 → 22; the
owl EN 35 k / 3 k → 90 k / 1 k.

## Why it is not a repeat

The located fixes are credited and kept small (they were b1a0's missing pieces, measured in its own logs). The cell's own
mechanisms answer the opponent's commitment on its event, with a frame model, where earlier cells used a distance band or a
continuous envelope: (1) the Step-in interrupt times J1 against his Step's iframes and its J cancel (no cell read his
Step); (2) the exit plan acts on his CPU's own form change (EN → KIN) with the armour's state; (3) the let-go is a per-charge
reaction on b1a0's brain-held L (b0a0 / b2a0 had a let-go on their own hold models; here combined with the R13 turn-held
dash and the snipe's level-2 hold-on).

## Awaken A/B (the burst and the awakening untouched vs the parent; the base form's play changed)

`python3 tools/simgate.py --pairs 21,22,23,24,25 --seed0 S --seeds 60 --cmd 39020 -j 2`, the never-awaken side's (P1 Lille
II, NORMAL) wins of 60, all 900 matches K.O.:

| seed0 | BY | BK | BR | BI | BS |
|---|---|---|---|---|---|
| 100 | 11 | 7 | 6 | 5 | 6 |
| 300 | 15 | 4 | 1 | 6 | 3 |
| 500 | 28 | 6 | 3 | 4 | 3 |
| b1a0 100 / 300 / 500 | 14 / 15 / 10 | 8 / 5 / 7 | 4 / 2 / 5 | 2 / 4 / 2 | 1 / 6 / 6 |
| baseline 100 / 300 / 500 | 2 / 2 / 6 | 9 / 7 / 3 | 0 / 0 / 0 | 1 / 0 / 0 | 1 / 1 / 1 |

Below the gate's 20 except BY at 500, as in the baseline and every cell: his NORMAL base form alone does not win against
awakening opponents. For the integration gate.

## Expected benefit, risks

- Benefit: HARD strength saturated (400 / 400, Kenpachi included), the masher fully beaten, signature 0.88 with NORMAL
  mid-band.
- Risks: NORMAL 0.5425 is 0.0575 under the band's top; it rose to 0.7075 at v5 before the difficulty tables: any later
  change to a rule that is not a roll (the reserve, the R17 link, the exit / let-go mechanics) moves NORMAL with HARD; the
  generic `:l-after-*` keys are raw (not difficulty-scaled). Pacing medians 123–149 s (≥ 70 s under the cap: no risk).
  HARD strength 1.0 leaves no headroom to see further strength gains at 40 seeds. The kite / unguard / exit-back make HARD
  back off often (a human may read it as passive). plain-jk 0.104 (the J1 bridges: after the dash, the Step-in J1, the base
  K2s link) is the largest non-signature share left.

## Shared-code recommendations (not done)

- ai.lisp STRING-REFLEX: scale `:l-after-k` / `:l-after-j` by the difficulty (a kit factor) — every cell asked; it would
  let NORMAL stay fair while HARD confirms more.
- A generic "his Step in" reflex (the interrupt's frame model) would help every short-J kit: the opponents' STEP-IN → STEP-J
  is the most common opener on an idle CPU.
- ai.lisp's generic guard-break (`brain-break-key`) and neutral Kikon could take kit keys instead of a kit writing the
  brain's key (`BR-AI-UNGUARD` does, as b2a0's did).

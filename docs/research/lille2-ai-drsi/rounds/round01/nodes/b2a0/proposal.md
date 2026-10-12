# Cell b2a0 (round 1): "read his reach" — the opponent's first-strike envelope, the kite, the Kikon on openings only

Freeze 36e93c7. Only `duel/lisp/barro.lisp` (his CPU parts) and the `BARRO-CPU-TESTS` section of
`tests/duel-rules-test.lisp` changed (host test 8292 checks ALL PASS; `tools/pkgcheck.sh duel` 0 / 0 / 0). Final measure
(`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, score.json; the same JSON to the digit as the run before the last
comment-only edit):

| | baseline | b0a0 (best so far) | b1a0 | **b2a0 (40 seeds)** |
|---|---|---|---|---|
| score | 0.0 (raw 0.1702) | 0.8032 | 0.6985 | **0.915** (raw 0.915) |
| strength (HARD, both seats) | 0.003 | 0.652 | 0.517 | **0.882** |
| masher | 0.302 | 0.953 | 0.802 | **1.0** |
| signature | 0.272 | 0.879 | 0.828 | **0.905** |
| NORMAL share (band 0.30–0.60) | 0.05 (×0) | 0.5025 | 0.5125 | **0.53** (×1; by opp I 49, K 18, R 26, S 56, Y 63 of 80) |
| pacing medians Y K R I S (cap 220) | 130.7 113.6 122.2 122.4 123.6 | 128.1 134.3 170.4 164.7 169.5 | 121–152 | **143.3 146.4 188.4 172.3 176.8** (all 40/40 K.O.) |

sig_by (top): br-e-k 0.229, br-e-kl 0.145, br-rc 0.110, br-oe-k 0.101, plain-jk 0.082, charged 0.080, br-w-nijushi-c
0.063, br-s-l1- 0.049, br-oe-kl 0.044, br-k-hiren-c 0.035, br-s-j 0.027; Kikons and Breakers ≤ 0.001 each.

## History read, and what I took from it

- **baseline** (score 0): broken by R12–R17 (stance at 4 m, never charges, waits in the rooted EN).
- **b0a0** (0.8032, rescored the same): the L hold length as the plan, the CPU's R17 link, the stance calls, EN decisions
  every 10 f, and above all *the turn before the follow-up* after the dash through him (HARD 0.23 → 0.52). Weak spots it
  reported: Kenpachi (~0.25 HARD), KIN's neutral, the neutral Kikon (35 of 212 reached a Konpaku), the generic step-in.
- **b1a0** (0.6985, rescored the same): routes on events, the anti-Breaker reach model (the generic J1 met Breakers 4–5 f
  late), the owl earlier (2 wings / 8 m: +0.02 at v6). Lacked b0a0's facing wait: its str stayed ~0.5.
- Neither idea failed by a bug I could locate; b1a0's lower strength is the missing turn-before-follow-up, which b0a0
  measured as the big lever. So this cell starts from b0a0's file (its proven route machinery, the strongest measured)
  and adds b1a0's two pieces that measured positive (the anti-Breaker model, the earlier owl) — then puts its effort in a
  **new mechanism neither had: a model of the opponent's reach and of where Lille gets opened**, found by diagnosis.

## Diagnosis (combat logs of b0a0, HARD, 8 seeds × 5 opponents × both seats; scratch scripts parse `run-log.lisp` output)

- 57/80 wins; Kenpachi 4/16. Who opened him: **"idle / walking" openings dominate against every opponent** (58 / 140 / 64 /
  117 / 63 of the opponents' combo openers came with no action of Lille's in the 50 f before): their J1 first strikes
  (Kenpachi's FIRST-STRIKE J1 with its 0.8 m lunge: 68 hits; Rukia / Ichigo / Senjumaru J1s ~55 each).
- His **neutral Kikon** (a 28 f lane shot on a free opponent) was a gift: vs Ichigo 99 tries → 34 Perfect Hohos, 47 blocks,
  3 hits; vs Rukia 70 tries → 55 whiffs.
- His **Breakers** (generic long-guard reflex and the bands): ~45 of ~200 broke / hit, the rest Hoho'd or J'd.
- A threatened snipe let go before level 2 fired at level 1 (16 f wind-up after the release: Perfect-Hoho bait).
- With a plain guard in the envelope (my v1), Kenpachi's J1 pressure became a loop: 10 blocked J1s in a row and a guard
  crush (the generic hold-guard re-presses at each block; Lille's 1.45 m J1 can't use J-beats-K's 1.65 m window).

## The action policy (per form; b0a0's routes kept, see its proposal)

**His reach, read off his kit** (`BR-AI-ENVELOPE`): his form's J1 reach + its lunge (≤ 0.8 m) + 0.5 m + his perceived closing
speed × 15 f (`BR-AI-CLOSING`: two SNAPs of the perceived ring, split into closing / lateral).

- **The kite / the ward** (`BR-AI-WARD`, every attack-state form, free, him free): inside his envelope, one roll a 24 f
  window (`*BR-AI-WARD-P*` 0.05 / 0.1 / 0.8): him coming in (closing > 0.03 m/f) → a dash back to his envelope + 2 m (his
  first strike whiffs; Lille is at the snipe's / the dash's range, where his forms win); else a short guard (12–20 f, under
  any CPU's Breaker-a-guard 24 f). Kenpachi HARD 5/16 → 13/24 on the diagnosis seeds, strength 0.823 → 0.873 at 40 seeds.
- **The Kikon only on an opening** (`BR-AI-KIKON`): him red, perceived reeling / recovering with ≥ the rush's aura + startup +
  2 frames left past the perception delay, within 11 m; one roll per action of his (react roll; 0.05 / 0.15 / 1.0). Every
  form's `:kikon-range` 0: the generic neutral / reeling rush never fires. Strength 0.713 → 0.785.
- **A long guard up close** (`BR-AI-UNGUARD`): him guarding ≥ 24 f within 3 m (the generic Breaker's moment), once per
  guard (that guard's generic roll taken: `BRAIN-BREAK-KEY`), 0.0 / 0.1 / 1.0: a dash back to 5.5 m instead of the Breaker.
  NORMAL keeps the Breaker (with it at 0.6 and no band Breakers, a NORMAL match vs Rukia timed out: pacing failed at v5).
- **Charges** (`BR-AI-CHARGE-TICK`): a threatened base snipe at 12–19 held frames is held into level 2 (`BR-AI-LET-GO-HOLD`:
  level 2 lands no later than level 1 from there, and harder); the awakened dash's done charge waits (≤ 56 f held) while he
  is perceived moving across its line > 0.05 m/f (released on his commitment). No rolls: reactions.
- **His Breaker** (`BR-AI-ANTI-BREAKER`, b1a0's reach model, 0.1 / 0.3 / 1.0), first in the attack-state reflex.
- **The owl sooner**: `:burst (:p 0.6 :wings 3 :in 8.0)` in both JILLIEL forms (b1a0's evidence, b0a0's 3-wing trial).
- **Difficulty**: `*BR-AI-DIFF*` 0.25 / 0.5 / 1.5 → **0.15 / 0.3 / 1.5**: the Kikon fix alone raised NORMAL to 0.65 (×0.67:
  NORMAL's neutral Kikons were its own worst habit), 0.3 brought it to 0.46–0.54. Every new chance EASY ≤ NORMAL ≤ HARD,
  one roll per window / per opponent action / per guard, SIM-RND01 or the brain's event rolls only, the opponent through the
  perceived SNAP (his kit's move data are static knowledge, as Kenpachi's first strike reads Lille's).

Kept working: AI-AWAKEN-P / `:awaken` untouched; the learner (BR-LEARN-* untouched; the reflex returns NIL when nothing
fires: the ward / unguard / Kikon each act on a window or an event); the ASSIST (`:sig-hold` unchanged from b0a0, no new
hook reads a brain; the new code is all inside `BR-AI-REFLEX` and the CPU branch of BR-S-TICK, which `BR-TICK-BRAIN` gates);
debug commands and the `duel barro` counters (new: ai-ward, ai-kite, ai-kikon, ai-unguard, ai-hold-on, ai-let-go,
ai-dash-wait). New BRS slot: `ai-ward`.

## The steps measured (40 seeds, the frozen evaluator; HARD diag = 8–12 seeds × 5 opponents × 2 seats)

| step | change (on b0a0's file) | score | str | mash | sig | NORMAL |
|---|---|---|---|---|---|---|
| b0a0 | (its proposal) | 0.8032 | 0.652 | 0.953 | 0.879 | 0.5025 |
| v1 | + guard ward, snipe let-go fix, dash wait, anti-Breaker model, owl 3 wings / 8 m | 0.8347 | 0.713 | 1.0 | 0.874 | 0.5225 |
| v2 | + Kikon only on openings (`:kikon-range` 0) | 0.5776 (raw 0.8664) | 0.785 | 0.995 | 0.884 | 0.65 (×0.67) |
| v3 | NORMAL Kikon 0.6 → 0.15 | identical to v2 (NORMAL's gain was the dropped neutral rush) | | | | |
| v4 | `*BR-AI-DIFF*` NORMAL 0.5 → 0.3 | 0.8664 | 0.785 | 0.995 | 0.884 | 0.4625 |
| v5 | + unguard (0.3/0.6/1.0), no band Breakers | 0 (raw 0.8811; RUKIA 39/40 K.O.) | 0.802 | 1.0 | 0.900 | 0.4225 |
| v6 | band Breakers back, unguard NORMAL 0.1 | 0.8869 | 0.823 | 0.995 | 0.897 | 0.4625 |
| v7 | **the ward kites when he comes in** | 0.9114 | 0.873 | 1.0 | 0.906 | 0.54 |
| **v8** | ward 0.05 / 0.15 / 0.6 → 0.05 / 0.1 / 0.8 (delivered) | **0.915** | 0.882 | 1.0 | 0.905 | 0.53 |

HARD diag wins (of 16 per opponent, Y K R I S): b0a0 15 4 14 11 13; v4 14 5 15 15 15; v6 16 5 16 13 15; v7 (12 seeds,
of 24) 24 13 24 20 22.

## Why it is not a repeat

b0a0 and b1a0 tuned Lille's own routes; neither modelled the opponent. This cell's core is new: the opponent's reach
envelope from his kit + his perceived motion (the kite / ward, the dash released on his commitment), the Kikon / Breaker
moved from neutral habits to measured openings, and a located bug fixed (the level-1 let-go). The b0a0 / b1a0 pieces it
reuses are kept as they measured, credited above.

## Awaken A/B (the burst changed; the base form's neutral too)

`python3 tools/simgate.py --pairs 21,22,23,24,25 --seed0 S --seeds 60 --cmd 39020 -j 2`, the never-awaken side's (P1
Lille II, NORMAL) wins of 60, Y K R I S:

| seed0 | b2a0 | baseline (b1a0's measure) | b0a0 |
|---|---|---|---|
| 100 | 5 2 0 1 3 (BS 59/60 K.O.: one 300 s time-out) | 2 9 0 1 1 | 4 1 1 0 1 |
| 300 | 6 0 2 4 0 | 2 7 0 0 1 | 2 2 1 0 1 |
| 500 | 7 0 1 2 2 | 6 3 0 0 1 | 4 0 0 0 0 |

All far below the gate's 20, as in the baseline and both earlier cells (the burst never acts in the base form; these rows
measure his NORMAL base form against awakening opponents). The one time-out is in the A/B's forced never-awaken mode, not in
the evaluator's pacing (all 200 K.O.). For the integration gate.

## Expected benefit, risks

- Benefit: HARD 0.65 → 0.88 (Kenpachi the gainer), the masher fully beaten, signature 0.905, NORMAL mid-band.
- Risks: pacing RUKIA 188.4 s is 31.6 s under the 220 cap (v7 had 193.9; v5 showed that removing NORMAL's Breaker breaks
  pacing: keep NORMAL's generic Breaker). NORMAL 0.53 is 0.07 under the band top; NORMAL vs Rukia 26/80 is its low row.
  The kite backs off whenever a HARD opponent walks in: against a human it may look passive (the learner can read it later);
  the arena edge limits it (the dash back simply stops). `BR-AI-UNGUARD` writes the brain's `brain-break-key` (Lille's own
  brain, to take that guard's generic Breaker roll); if the shared reviewers prefer, a kit key in ai.lisp's guard-break
  reflex would be cleaner (below). No Kikon in neutral at any difficulty: a human may notice he never rushes from afar.

## Shared-code recommendations (not done)

- ai.lisp's guard-break reflex: a kit key (`:guard-break-p` or a hook) so a kit can answer a long guard its own way without
  touching `brain-break-key`.
- The generic neutral Kikon (`AI-DECIDE`, `*AI-KIKON-P*` within `:kikon-range`) fires on a free opponent; for kits whose
  rush has a long wind-up a kit key "only on an opening" (his perceived frames left ≥ the rush's) would help every kit.
- The generic hold-guard after a block (`*AI-HOLD-GUARD*`, act `:hold`) never lets a kit's reflex break a J-pressure loop
  (Kenpachi's guard-cancelled J1s); a kit hook there would let short-J1 kits escape.

# Cell b1a0 (round 2): "the line" — every charge held as a threat and released when his feet meet its frozen aim

Freeze 2eaf8b9, a new direction from BASELINE_DIR (baseline-r02, the integrated b1a2 on R18). Only `duel/lisp/barro.lisp`
(his CPU parts: two BRS slots of CPU state, the AI section's new BR-AI-LINE-* / BR-AI-ENVELOPE-P / BR-AI-FACING-P and
knobs, BR-AI-CHARGE-TICK (the CPU branch of BR-S-TICK's hold phase), a facing test in BR-AI-REFLEX's window, BR-AI-EN and
BR-AI-EXIT, the base kit's `:far-snipe :in`) and the `BARRO-CPU-TESTS` section of `tests/duel-rules-test.lisp` changed.
Host test 8363 checks ALL PASS (the section spliced into the frozen file with `splice-tests.py`: byte-identical to the
delivered test); `tools/pkgcheck.sh duel` 0 / 0 / 0.

Final measure (`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, score.json; the delivered file was measured twice, the
second run after three other variants, the same JSON to the digit):

| | baseline-r02 (40 seeds) | **b1a0 (40 seeds)** |
|---|---|---|
| score | 0.9102 | **0.9607** (raw 0.9607) |
| strength (HARD, both seats) | 0.853 | **0.983** |
| masher | 1.0 | **1.0** |
| signature | 0.923 | **0.919** |
| NORMAL share (band 0.30–0.60) | 0.36 (Y 45, K 12, R 37, I 23, S 27 of 80) | **0.3875** ×1 (Y 54, K 11, R 34, I 27, S 29 of 80) |
| pacing medians Y K R I S (cap 220, all 40 / 40 K.O.) | 129.8 124.4 161.3 163.2 158.7 | **136.3 129.6 150.6 159.4 147.1** |

sig_by (top): br-e-k 0.269, br-e-kl 0.155, br-oe-k 0.087, charged 0.079, br-rc 0.075, plain-jk 0.072, br-oe-kl 0.052,
br-k-hiren 0.048, **br-s-l1- 0.046** (baseline 0.024: the level 2 / 3 snipes now land), br-s-j 0.038.

## History read (every proposal, score.json and score.rescored.json; round 1's numbers are pre-R18, mechanisms only)

- **b0a0** (0.8032): L's hold length as the plan; the CPU's R17 link; the turn before the follow-up after the dash (its
  biggest step). **b1a0** (0.6985): routes on events, the anti-Breaker model, the owl early; lacked the turn (a located
  omission). **b2a0** (0.915): the opponent's reach envelope (kite), the Kikon only on openings, the unguard, the snipe's
  level-1 let-go fixed. **b3a0** (0.9192): the clock for every charge; the wings kept as armour (the reserve). **b0a1**
  (0.952): b2a0 + b3a0's reserve + the wake-up shot. **b1a1** (0.9529): the Step-in interrupt, the stance exit, the per-charge
  let-go. **b0a2** (0.9549): the burst kept for the owl; located dead ends (the dash's J1 bridge is forced by frame data;
  backing out of mid-range dashes hands the initiative over). **b1a2** (0.9716 then, 0.9102 on R18 = baseline-r02): every
  link that hits into the stance, the base stance's full-pip HIRENKYAKU cash-out.
- Every earlier cell picked a charge's level by distance (or a clock) and released it at a planned hold; the snipe then
  snapped onto him at the release, so the hold was free. R18 (DUEL_LILLE_V3 §23) froze the aim at the charge's start and
  took that away (b1a2 1.0 → 0.853 strength). No earlier cell looked at *where his feet are against the line* during the
  charge, nor at what the opponents' CPUs do to a charge they perceive (their Hoho), because the snap made both moot.

## Diagnosis of the baseline (combat logs as aieval runs them, HARD, seeds 1–6 × 5 opponents × both seats = 60 matches; scratch parsers)

- 53 / 60 wins (Ichigo 7 / 12, Kenpachi 10 / 12). Dealt / taken by form: base 48.8 k / 62.4 k (0.78), JILLIEL KIN
  11.8 k / 24.5 k (0.48), EN 134.9 k / 27.0 k, the owl EN 89.8 k / 2.2 k.
- **The level-2 snipe was the biggest hole**: 599 shots, 168 hit / 181 blocked / 250 whiffed; **153 combos (30.0 k) opened on
  him right after it**, ~120 of them the generic `PUNISH` J1 26 f after a whiffed shot (its 22 f recovery). A per-frame trace
  of the charges (a temporary log of the real geometry) showed why: at the release the median whiff had him only 0.36 m off
  the line but **1.6 m behind Lille** — the opponents' generic Hoho, rolled on the charge move they perceive (its 4 m reach
  + the CPUs' 1.5 m threat margin), teleports him *behind* the rooted stance, which never turns (126 Hohos on 784 snipe
  charges). 457 of the 784 snipes started at 4–6 m (`:far-snipe :in 4.5`), where 26 % of them opened him.
- **The dash**: 1 291 charges, 512 hit / 183 blocked / 596 whiffed; at its release 289 of 1 154 traced dashes had him
  > 1.2 m off the line (≤ 4 % hit), and some began with him *behind*: KIN's turn into EN (`:br-to-en`, 60 °/s) does not
  turn him round off a dash through him, so the dash went away from the opponent.

## The action policy (行動方針): baseline-r02's routes, plus the line

**THE LINE** — a charge (the base snipe and the awakened dash) is a held threat, not a timer. One roll a charge
(`*BR-AI-LINE-P*` 0.2 / 0.5 / 1.0): the CPU holds L to the cap (its brain press extended) and BR-AI-CHARGE-TICK releases it
each hold frame by **BR-AI-LINE-CALL** (pure): his perceived offset from the frozen line + his lateral speed (over 6 steps of
the perceived ring) × the frames to the hit (the perception delay + the release + the shot's 8 f / the dash's startup + 5)
inside the volume's half-width on him (its radius + his hurt radius − 0.1 m), and him inside its length:
- level 1: hold (a level-1 snipe reaches 4 m and is the Hoho's bait; a level-1 dash gives no signature);
- the planned level reached: fire on the line, else hold (he may walk back onto it; the hold cap is the only forced shot);
- level 2 short of a planned 3: fire now when level 3 would find him off the line, else wait for the bigger shot;
- him behind the line's start (a Hoho, a cross-up): **:lost** → the charge's own Step out (R18's BR-CHARGE-STEP-GO: iframes,
  5 m away from him, the charge kept and re-aimed), refused → the shot.

**THE ENVELOPE** (the snipe) — the CPUs answer the snipe's charge inside its reach + their threat margin (BR-AI-ENVELOPE-P:
4 m + 1.5 m, his closing over the perception delay): the far snipe starts from 6 m (`:far-snipe :in` 4.5 → 6.0); in the
charge, him inside the envelope (or perceived Hohoing): on the line at level 2+ the shot (`ai-env-fire`), held 12–19 f the
hold-on into level 2 (b2a0's finding), else the Step out, else the shot.

**THE FACING** — every charge starts facing him (BR-AI-FACING-P, 0.35 rad): the far snipe / dash / burst window waits for the
idle turn (18 °/frame) instead of being consumed; EN's plan waits out of K1's reach; the stance exit's armoured dash only
facing him (else the dash back).

The let-go (b1a1's, one roll a charge: his attack in reach + 1 m, him running in within 3 m) keeps priority over the line.
Everything else is baseline-r02's (every link that hit into the stance, the R17 link, the turn before the follow-up, the
Step-in interrupt, the kite, the wing reserve, the owl at 2 wings, the K-route L L lines and SP2 cash-ins, HIRENKYAKU at the
full pips, the learner's `:charge` / `:shot`).

Per form: **base** — keeps 6 m+, shoulders the rifle from there, aims and waits for his feet; level 3 (the 31 m line) only
when he will still be on it, else the level-2 shot now; him rushing in mid-charge → the vanish Step back and the shot from 5
m further. **KIN / the owl KIN** — the dash's charge only once turned to him; **EN / the owl EN** — the charged dash held until
he is on its line (fewer dashes, the same number of hits); the strings, wings and volley as before.

Difficulty: every new chance EASY ≤ NORMAL ≤ HARD (`*BR-AI-LINE-P*`; the envelope / lost handling lives under the line roll);
one roll a charge (the resumed charge after its Step keeps its rolls: BRS-AI-RESUME); the per-frame line call is a reaction
to the perceived SNAP, not a chance; randomness only SIM-RND01. Kept working: AI-AWAKEN-P / `:awaken` and the burst
untouched; every debug / test command; the `duel barro` counters (new: ai-line-fire, ai-line-lost, ai-line-step,
ai-env-fire, ai-env-shot); the learner (BR-LEARN-CHARGE still picks the level the line then targets; BR-AI-RESTEP untouched;
no new reflex: the reflex still returns NIL when nothing fires); the ASSIST (`:sig-hold` unchanged; the line runs only in
BR-AI-CHARGE-TICK, which BR-S-TICK calls for BR-TICK-BRAIN, his own CPU). New BRS slots: `ai-line`, `ai-resume`.

## The steps measured (aieval, 40 seeds; HARD diag = seeds 1–6, 5 opponents, both seats)

| step | change | score | str | mash | sig | NORMAL | HARD diag |
|---|---|---|---|---|---|---|---|
| baseline-r02 | | 0.9102 | 0.853 | 1.0 | 0.923 | 0.36 | 53 / 60 |
| v1 | the line + the envelope + `:in` 6 | (diag only) | | | | | 56 / 60 |
| **v2** | **+ the facing, the dash's :lost Step out — delivered** | **0.9607** | 0.983 | 1.0 | 0.919 | 0.3875 | **59 / 60** |
| v3 | + the envelope over both delays, the snipe's room checked before the charge (the stance Step out first) | 0.9573 | 0.975 | 1.0 | 0.918 | 0.38 | 59 / 60 |
| v4 | v3 + the stance J on a free opponent (`free-j` 0.25 / 0.4 / 0.8: K1's 16 f is a Hoho's bait) | 0.9594 | 0.98 | 1.0 | 0.918 | 0.365 | — |

v3 / v4 are within the 40-seed noise of v2 (±3 matches of 400), and v4's J-on-free barely fired (br-e-j 0.001): not taken —
the delivered file is v2, the fewest mechanisms with the best measure and the most NORMAL margin.

The delivered file's 60 HARD matches vs the baseline's (same seeds): base form dealt / taken 59.5 k / 58.4 k (1.02; was 0.78),
JILLIEL KIN 1.10 (0.48), EN 10.9 (5.0); level-2 snipes 530: **368 hit** / 68 blocked / **94 whiffed** (168 / 181 / 250);
openings right after a level-2 snipe 78 / 15.3 k (153 / 30.0 k); Hohos on the snipe's charge 34 (126); dashes 917: **569
hit** / 130 blocked / **218 whiffed** (1 291: 512 / 183 / 596) — the same hits from 29 % fewer dashes; level-1 dashes 70.

## Why it is not a repeat

No cell (round 1 ran before R18) modelled the frozen aim: they chose a hold length and released at it (b0a0's hold-as-plan,
b1a0's distance bands, b3a0's clock, b1a1 / b2a0's let-go on a threat). Here the release itself is the decision, keyed on
his perceived feet crossing the line, and the snipe's spacing is set by what the opponents' CPUs actually answer (their Hoho
envelope), both found in the logs above. The charge's Step (R18) is used only as the escape when the line is lost or he is
on top of the charge — never as the aim (the line is read, not corrected).

## Awaken A/B (informational: AI-AWAKEN-P and the burst are untouched; his base form's snipe changed)

`python3 tools/simgate.py --pairs 21,22,23,24,25 --seed0 S --seeds 60 --cmd 39020 -j 2`, the never-awaken side's (P1 Lille
II, NORMAL) wins of 60, Y K R I S:

| seed0 | b1a0 (Y K R I S) | b1a2 at round 1's freeze (pre-R18) |
|---|---|---|
| 100 | 12 0 1 4 0 | 13 1 1 1 1 |
| 300 | 6 0 0 1 1 | 13 1 1 3 1 |
| 500 | 7 0 1 0 2 | 10 1 2 4 1 |

All 900 matches K.O. (medians 131.4–154.6 s). Far under the pass mark 20, as for every cell and the baseline: these rows
measure his NORMAL base form alone (x0.3 chances, the line at 0.5) against awakening opponents; the base form still cannot
win without the awakening. Not re-measured for baseline-r02 on these pairings (its gate quoted only the mirror's 4 / 1 / 0).

## Expected benefit, risks

- Benefit: HARD strength 0.853 → 0.983 (R18's loss recovered without the snap: the snipe and the dash land by waiting for
  him), the base form an even trade instead of a loss, signature unchanged (more charged snipes, fewer whiffed dashes),
  NORMAL in the band (0.3875).
- NORMAL 0.3875 is 0.0875 over the band's floor (Kenpachi 11 / 80 its low row; ±0.05 is 40-seed noise): a later change
  that weakens NORMAL can leave the band. The line roll at NORMAL is 0.5.
- Pacing medians 129.6–159.4 s, ≥ 60 s under the 220 cap (no risk).
- The hold can last to the cap (60 f) against an opponent who keeps circling: a human may read the long aim and walk round
  it, or close in (the let-go / the envelope then fire or Step); the learner's `:charge` read still answers a stepping
  human (BR-AI-RESTEP).
- The base snipe's Perfect Hoho stays (23 of 530 level-2 shots in the diag): a HARD CPU perceives the S 8 shot at its first
  frame, 8 f late, and its Hoho lands exactly on the hit (below).

## Shared-code / rules recommendations (not done)

- ai.lisp's threat Hoho tests `(- (snap-s s) (snap-sf s)) >= 6` on the *perceived* frame: a CPU with an 8 f delay that sees
  an 8 f move start Hohos on its hit frame — a Perfect Hoho every time its roll passes (the base snipe's level 2 / 3,
  HIRENKYAKU: 22 of 113 Perfect-Hoho'd in the diag, the dash). Taking the delay into the test (`snap-sf + delay`) would make the generic Hoho a read, not a
  frame-perfect certainty.
- KIN's turn into EN (`:br-to-en`, `*TRACK-HEAVY*` 60 °/s over 12 f) does not turn him onto the opponent: a human pressing L
  facing away after a dash through him dashes away too (R18's "where he faces"). If that is not intended, the turn could
  face him (the user's call).

# Cell b0a2 (round 1, refines b0a1): "the burst for the owl" on b0a1 + b1a1's Step-in, a fair NORMAL — and three located dead ends

Freeze 36e93c7. Parent b0a1 (its `barro.lisp`, its BARRO-CPU-TESTS section spliced in). Only `duel/lisp/barro.lisp` (his CPU
parts: the base kit's `:ai` (a new `:sp-ender`), BR-AI-* functions / knobs, two BRS slots for CPU state) and the
`BARRO-CPU-TESTS` section of `tests/duel-rules-test.lisp` changed. Host test 8324 checks ALL PASS; `tools/pkgcheck.sh duel`
0 / 0 / 0. Final measure (`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, score.json, the delivered file byte for byte,
measured last; v6 + comments + the kept burst gated to his own CPU (BR-TICK-BRAIN) gave the same JSON to the digit as v6):

| | baseline | b0a1 (parent) | b1a1 (best str) | v2 | v3 | v5 | **b0a2 (final = v6)** |
|---|---|---|---|---|---|---|---|
| score | 0.0 | 0.952 | 0.9529 | 0.9542 | 0.9075 | 0.9549 | **0.9549** (raw 0.9549) |
| strength (HARD, both seats) | 0.003 | 0.963 | 1.0 | 0.975 | 0.85 | 0.978 | **0.978** |
| masher | 0.302 | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | **1.0** |
| signature | 0.272 | 0.918 | 0.882 | 0.911 | 0.919 | 0.910 | **0.910** |
| NORMAL share (band 0.30-0.60) | 0.05 | 0.525 | 0.5425 | 0.5825 | 0.5325 | 0.585 | **0.4975** (x1; I 49, K 15, R 37, S 49, Y 49 of 80) |
| pacing medians Y K R I S (cap 220, all 40/40 K.O.) | 131-124 | 150 148 172 184 174 | 124-149 | 147 152 191 178 181 | 144 153 178 178 179 | 156 156 189 181 189 | **155.2 157.0 194.1 190.2 190.4** |

sig_by (final): br-e-k 0.247, br-rc 0.138, br-oe-k 0.120, **plain-jk 0.079**, charged 0.076, br-k-hiren-c 0.066, br-e-kl 0.061,
br-s-l1- 0.051, br-w-nijushi-c 0.047, br-s-j 0.046, br-oe-kl 0.030, br-s-k 0.013; outside the whitelist besides plain-jk
only counter 0.008 and Breakers <= 0.001 each.

Honest summary: **+0.003 over the parent, inside the 40-seed noise** (strength +0.015 = 6 matches of 400, signature -0.008).
The cell's value for the search is mostly its evidence: where the parent's remaining plain damage and lost matches come from,
why the signature is near a structural ceiling for a CPU (~0.92 with these rules), and three mechanisms that measured flat
or negative (v1, v3, NORMAL's Step-in) with their located causes, so later cells don't repeat them.

## History read (every proposal, score.json and score.rescored.json; the rescored number trusted)

- **baseline** (0): R12-R17 broke it: the stance entered at 4 m for 1.9-2.6 m strings, never charges, waits in the rooted EN.
- **b0a0** (0.8032): L's hold as the plan, the CPU's R17 link, the stance calls, **the turn before the follow-up** after the
  dash through him (its biggest step).
- **b1a0** (0.6985): routes on events, the anti-Breaker reach model, the owl earlier; lacked b0a0's turn (a located omission).
- **b2a0** (0.915): the opponent's first-strike envelope (ward / kite), the Kikon only on openings, the unguard, the snipe's
  level-1 let-go fixed, *BR-AI-DIFF* NORMAL 0.3.
- **b3a0** (0.9192): the clock for every charge, **the wings as armour first** (the reserve: HARD 77 -> 95 / 100).
- **b0a1** (0.952, my parent): b2a0 + b3a0's reserve + the wake-up shot + `:l-after-j` 1.0.
- **b1a1** (0.9529): b1a0 + the located fixes + **the Step-in interrupt** (226 / 249 hits), the stance's exit, the let-go;
  HARD 1.0 but signature 0.882.
- Nothing in the history was a bug left open; the two best cells (b0a1, b1a1) differ in b1a1's Step-in / exit / kite set vs
  b0a1's envelope / reserve / wake-up set; b1a1's Step-in had never been tried on b0a1's file.

## Diagnosis of the parent (combat logs, `tools/simgate/run-log.lisp` as aieval runs it; HARD, 8 seeds x 5 opponents x both seats = 80 matches; scratch parsers)

- **His plain damage is the J1 bridge** (7.3 % of all he dealt): KIN's J1 3.5 %, the owl's J1 1.9 %, the base J1 1.6 %,
  counters 0.6 %. 4.1 % of all is ONE situation: the attack state's J1 FOLLOW-UP after the charged dash's cuts (605 KIN +
  182 owl J1s), the bridge into L -> the R17 link -> the stance's K route. The rest: the armoured J1, the punish, the
  base's Step-J / anti-Breaker J1, ORANGE's chain J1.
- **Where he loses**: the base form is 44 % of the time and 65 % of the damage he takes (dealt / taken 72 k / 79 k, 0.91);
  JILLIEL EN 170 k / 19 k, the owl EN 132 k / 2.8 k (per frame the owl deals 1.19 and takes 0.07, JILLIEL 0.72 / 0.14).
  Most openers on him: a first strike on an idle / walking base form (Kenpachi's J1 alone 58 combos, 11 % of the damage he
  took), then his own dash / snipe punished.
- **The dash by the armour** (TEMP diagnostic line on every CPU L press, removed): pressed bare (wings short of the armour's
  price) from 3-6.5 m it was punished 101 times of ~600 (17 %: the Perfect Hoho's counter on the released dash, Rukia's
  freeze, Kikons into the charge), armoured 16 of ~490 (3.6 %: the counter meets the armour); bare from >= 8 m 2 of 80.
- **The flash step**: 137 bursts per 80 matches in the base form (ORANGE 73, 58 of them right after the stance J3, each a
  plain chain J1; BLUE 51; WHITE 13), 221 in the awakened forms (each the owl). Every burst drains the whole flash step;
  only an awakened burst becomes the owl.

## What was tried (each step measured; a full aieval at 40 seeds is ~22 min here)

1. **v1 — the dash's cash-in** (not delivered): after a level-3 dash that hit, the turn into EN at his first free frame and
   the stance K1 at once (instead of the plain J1 bridge). 80 HARD matches: K1 hit 204 of 342, 98 Perfect-Hoho'd, 35
   interrupted; HARD wins 75 -> 68 / 80. **Located cause, frame data**: he is free at the touch + 38 f, the last cut's
   stagger ends at + 66-68, the turn (12) + EN's entry (1-2) + K1's startup (16) lands at + 67-70; a level-2 dash leaves
   ~21 f (only J1 fits: the J route's 15s instead of the K route). **The J1 bridge is forced by the rules, not by the CPU**:
   the signature's ceiling for any CPU is ~0.92 while the dash's recovery and the cuts' stagger stay as they are.
2. **v2 — b1a1's Step-in interrupt on b0a1's file** (`BR-AI-STEP-IN`, credited, its pure core and tests as b1a1's):
   strength 0.963 -> 0.975, the base form's dealt / taken 0.91 -> 1.24 (taken 79 k -> 71 k), signature 0.918 -> 0.911 (its
   J1s in the base are plain: base J1 6.4 k -> 9.9 k), score 0.9542.
3. **v3 — "bare: back out first"** (not delivered): bare inside 7 m the L a tap and EN's first pick the fast Step back,
   the charged dash from ~8 m. **Strength 0.85** (score 0.9075): the punish data above was selection bias — bare mid-range
   dashes are punished 17 % but they are also where his wings and his combos come from; backing out hands the initiative
   over. Reverted entirely (do not retry a range rule on the dash without a replacement source of wings).
4. **v4 — NORMAL's Step-in 0.08 -> 0.04**: the NORMAL runs came out identical to the digit: NORMAL's Step-in never decides
   a match; **v2's NORMAL rise (0.525 -> 0.5825) was an RNG-stream shift** (one extra SIM-RND01 per opponent Step), i.e.
   NORMAL's 40-seed share carries +-0.05 of pure noise. Kept 0.02 / 0.04 / 1.0 (EASY <= NORMAL <= HARD).
5. **v5 — the burst kept for the owl** (new, delivered): see below. Score 0.9549 (strength 0.978, signature 0.910).
6. **v6 — a fair NORMAL**: *BR-AI-DIFF* NORMAL 0.3 -> 0.25; NORMAL 0.585 -> 0.4975 (the band's centre: safe at 80 seeds),
   every HARD / masher number identical (NORMAL-only knob); pacing medians +4-10 s (max 194.1 s).

## The action policy (b0a1's, credited in its proposal, plus)

- **The burst belongs to the owl** (`BR-AI-KEEP-BURST`, the base kit's `:sp-ender`, `*BR-AI-KEEP-BURST*` 0.2 / 0.5 / 1.0):
  in the base form, at a string link that hit with no link after it (ai.lisp STRING-REFLEX; the stance's own call in
  BR-S-CPU-CALL already cashed it or declined), one roll: skip the generic SP2 cancel / CHAIN REVERSE (ORANGE). The flash
  step he keeps there is the bar his awakened burst needs — and only an awakened burst becomes the owl, his best form
  (「資源循環」: the base's resource saved for JILLIEL's). Final diag (80 HARD matches): the base form's ORANGEs after the
  stance J3 58 -> 0 (21 left, off the snipe: ai.lisp's L-hit ORANGE runs before any kit hook); the owl EN 67 k -> 73 k
  frames, its damage 105 k -> 118 k; HARD 79 / 80.
- **His Step in met** (b1a1's `BR-AI-STEP-IN`, one roll a Step: J1 timed past his Step's iframes, before its J cancel;
  0.02 / 0.04 / 1.0): the J1 that hits links into the stance as any J link (the base at f4, KIN / the owl by the R17 link).
- **NORMAL's chances x 0.25** (*BR-AI-DIFF* 0.15 / 0.25 / 1.5): NORMAL plays the same policy with fewer rolls landing.
- Unchanged from b0a1: the reach envelope / ward / kite, the Kikon on openings, the unguard, the reserve and the armoured
  J1, the owl at 4 wings / 7 m, the wake-up shot, the turn before the follow-up, the CPU's R17 link, the stance calls.

Difficulty: every new chance a table EASY <= NORMAL <= HARD (host-checked); one roll per event (an opponent's Step, a string
end's hit); randomness only SIM-RND01; the opponent only through the perceived SNAP. Kept working: AI-AWAKEN-P / `:awaken`
untouched; BARRO-TICK / BR-AI-BURST-P / `:burst` untouched (the owl's burst unchanged; only the base form's generic ORANGE at
a string's end is skipped); the learner (BR-LEARN-* untouched; the new reflex branch returns NIL when nothing fires; the
Step-in's waits are a frame for his iframes); the ASSIST (`:sp-ender` returns NIL unless BR-TICK-BRAIN finds his own CPU,
so an assisted human's AUTO COMBO and the gate's masher keep the generic ender; the difficulty read through AI-BRAIN);
debug commands; the `duel barro` counters (new: ai-step-in, ai-keep-burst). New BRS slots: ai-step-key, ai-step-go. The
diag numbers of the final policy (79 / 80, the owl's frames) were taken on the v6 build: its CPU-vs-CPU play is the
delivered file's to the digit (same aieval JSON).

## Why it is not a repeat

The Step-in is b1a1's piece on b0a1's file (a combination never measured: +0.012 strength, -0.007 signature). The burst
economy is new: no cell looked at the flash step (every cell's owl rule is `:burst`'s wings / distance; none asked where the
bar it needs went). The three negative results are new and located (frame data, selection bias, RNG noise).

## Awaken A/B (the base form's play changed: the Step-in, the kept burst; the awakening and the owl's burst untouched)

`python3 tools/simgate.py --pairs 21,22,23,24,25 --seed0 S --seeds 60 --cmd 39020 -j 2`, the never-awaken side's (P1 Lille
II, NORMAL) wins of 60, Y K R I S:

| seed0 | b0a2 (Y K R I S) | b0a1 (parent) | baseline (b1a0's measure) |
|---|---|---|---|
| 100 | 5 0 1 2 1 | 5 0 0 1 1 | 2 9 0 1 1 |
| 300 | 3 0 1 3 1 | 5 0 0 4 1 | 2 7 0 0 1 |
| 500 | 9 1 0 1 0 | 6 2 2 4 0 | 6 3 0 0 1 |

All 900 matches K.O. (medians 146.5-185.1 s). All rows far under the pass mark 20, as for the parent, the baseline and every
cell (measured on the v6 build; the delivered file's only later change gates the kept burst to his own CPU, which the A/B's
CPU-vs-CPU matches cannot see).

The burst never becomes the owl in the base form, so these rows measure his NORMAL base form alone against awakening
opponents; every earlier cell's rows were far below the pass mark 20 too.

## Expected benefit, risks

- Benefit: HARD 0.978, masher 1.0, NORMAL centred (0.4975), more owl time; +0.003 over the parent (noise level).
- Signature 0.910 (parent 0.918): the Step-in's base J1s. If the coordinator values signature over strength, the parent's
  file + only the kept burst + NORMAL x 0.25 is the variant to measure (not done here).
- Pacing medians 190-194 s vs Rukia / Ichigo / Senjumaru (26-30 s under the cap; NORMAL x 0.25 lengthened them 4-10 s).
- NORMAL 40-seed noise is +-0.05 (v4): a later cell near the band's edges should re-measure at 80 seeds.
- `:keep-burst` relies on STRING-REFLEX / BRAIN-STEP pressing nothing for a command no kit has (AI-COMMAND's CASE has no
  default); a shared "no ender" return value for `:sp-ender` would be cleaner (recommendation below).

## Shared-code / rules recommendations (not done)

- The dash's follow-up (rules, the user's call): with the dash's recovery (14 f) or the level-2 / 3 cuts' stagger as they
  are, no CPU can start the stance from the dash without the attack state's J1; if 「架勢連段」 should own that follow-up, a
  rule (e.g. the dash's recovery cancellable into the stance's K1 on a hit) would move ~4 % of his damage onto the whitelist.
- ai.lisp: a kit key to veto the generic ORANGE on an L / O hit (AI-REFLEX's branch before the kit's :reflex) — the kept
  burst covers only the string-end path (STRING-REFLEX's :sp-ender).
- ai.lisp STRING-REFLEX: `:l-after-k` / `:l-after-j` by difficulty (every cell asked); a documented `:sp-ender` value meaning
  "end the string here, no generic SP2 cancel / ORANGE".

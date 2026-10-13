# Cell b2a0 (round 2): "the rifleman's ladder" — the never-awakened base form's own game plan

Freeze 2eaf8b9, a new direction from `baseline-r02` (no parent). Only `duel/lisp/barro.lisp` (his CPU parts: the base kit's
`:ai`, new BR-AI-* functions / knobs, one BRS slot of CPU state, one clause in BR-AI-KAMAE, BR-AI-CALL / BR-AI-CHARGE-P /
BR-AI-STANCE-PUNISH / the far window reading chances through BR-AI-P, BR-AI-CHARGE-TICK (the CPU branch of BR-S-TICK's hold
phase), BR-AI-REFLEX) and the `BARRO-CPU-TESTS` section of `tests/duel-rules-test.lisp` changed. Host test 8369 checks ALL
PASS; `tools/pkgcheck.sh duel` 0 / 0 / 0. Final measure (`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, `score.json`,
the delivered file byte for byte; its logic is v6 below, same JSON to the digit):

| | baseline-r02 | **b2a0 (delivered)** |
|---|---|---|
| score | 0.9102 | **0.9319** |
| strength (HARD, both seats) | 0.853 | **0.917** |
| masher | 1.0 | **1.0** |
| signature | 0.923 | **0.912** |
| NORMAL share (band 0.30–0.60) | 0.36 (Y 45, K 12, R 37, I 23, S 27 of 80) | **0.4625** (Y 47, **K 27**, R 39, I 33, S 39 of 80) |
| pacing medians Y K R I S (cap 220, all 40/40 K.O.) | 129.8 124.4 161.3 163.2 158.7 | **117.2 121.5 154.2 154.4 156.1** |
| **awaken A/B, never-awaken side, Y K R I S of 60** (seed0 100 / 300 / 500) | 8 0 1 1 1 / 8 0 1 4 1 / 11 1 1 4 1 | **39 16 33 33 35 / 50 28 30 37 41 / 40 26 31 35 36** |

sig_by (final): br-e-k 0.224, br-e-kl 0.117, br-oe-k 0.113, plain-jk 0.079, **br-s-k 0.077** (baseline 0.010), charged 0.074,
br-rc 0.073, br-oe-kl 0.068, br-k-hiren 0.065, **br-s-kl 0.037** (0.004), br-s-l1- 0.034, br-w-nijushi-c 0.022, br-s-j 0.001
(0.025); outside the whitelist besides plain-jk: counter 0.005, the cuts / level-1 dash 0.001 each.

The cell's aim was the round's two open problems the six recorded cells left (they all refined the charged L's aim): the
never-awakened base form and Kenpachi. **The awaken A/B passes (>= 20 of 60) on 14 of its 15 rows** (BK at seed0 100: 16;
baseline 0 of 15, every earlier cell 0–1 of 15), **NORMAL vs Kenpachi 12 -> 27 of 80**, and the score is +0.022 over the
baseline (below the round's aim cells, 0.96–0.973: this cell does not aim the awakened dash; see "Combination").

## History read (every proposal, score.json and score.rescored.json; round 1's numbers pre-R18: mechanisms only)

- Round 1: b0a0 0.8032 (L's hold as the plan, the CPU's R17 link, the turn before the follow-up), b1a0 0.6985 (routes on
  events), b2a0 0.915 (reach envelope / kite, Kikon on openings, unguard), b3a0 0.9192 (the clock, the wing reserve), b0a1
  0.952 (+ the wake-up shot), b1a1 0.9529 (Step-in interrupt, exit, let-go), b0a2 0.9549 (the burst kept for the owl; the
  dash's J1 bridge forced), b1a2 0.9716 (**`:l-after-j` 1.0 everywhere: the base's J link -> L -> the gun-kata**, the cash-out).
- Round 2 (all on R18's aim): b0a0 0.9696 (the charge's Step as the re-aim, Hoho behind the charge), b1a0 0.9607 (the line,
  the envelope, the facing), b0a1 0.9724 (facing + kept burst), b0a2 0.97 (pushed wait, the floor, `:neutral-guard` 0.1:
  Kenpachi NORMAL 27/80), b1a1 0.9645 (the floor, the base backs off to 6.5 m), b1a2 0.9733 (step-fire, the 4.5 m window).
  Every one reported the never-awakened base form's A/B at 0–5 of 60 vs Kenpachi / Rukia / Ichigo / Senjumaru, "a base form
  that cannot win without the awakening"; none diagnosed WHY; b1a2 round 1 noted its own `:l-after-j` 1.0 lowered NORMAL
  ("the base gun-kata deals less than the K2s route") and took it as a NORMAL margin.

## Diagnosis (baseline-r02, the combat log as aieval runs it; scratch parsers)

NORMAL, Lille II P1 never awakening (`39020`), seeds 1–8 x the five = 40 matches: **3 / 40 won, dealt 89.6 k / taken 156 k.**
- **Every confirm went into the gun-kata.** b1a2's `:l-after-j` 1.0: J1 hit -> L -> the stance J J J, 15 a shot (448 stance
  J1s, 386 J3s): an opening was worth 22 + 45 (+ HIRENKYAKU-C 90 when 2 bars were there, 54 times), then the end push and a
  whiffed follow-up J1 (369). The rifle's K string (46 / 46 / 66) and its L L lines (70 a pip) ran 135 / 14 times.
- **No pips to spend**: NORMAL's charge chance 0.7 x 0.3 = 0.21, a failed roll a level-1 tap (4 m, S 16) from the far window's
  4.5 m+: 300 snipe charges, 41 level 2, 13 level 3; KL lines 14, JL lines 12 in 40 matches.
- **His long neutral guard** (the kit's `:guard` 0.5 within 3.4 m) fed the opponents' Breaker-a-guard: 143 GUARD-BREAK
  Breakers with no block of his in the 80 f before (b0a2's finding, confirmed); 25 k of counters after Perfect Hohos on his
  stance K1 from neutral (29), his Breakers (34), the tap snipe (18).
- His dealt / taken by the opponent's form: 11.7 k taken from base-form opponents, ~145 k from awakened ones.

HARD (v1 below, seeds 1–8 both seats, 80 matches, 71 won): the base form is an even trade (dealt 84 k / taken 75 k, awakening
at ~2 700 ticks); of 380 openings on the base form **the snipe was his last act before 270** (L1-2 167, L1-3 44, the charge 36,
HIRENKYAKU 26): Hohos on the rooted charge (51) and Perfect Hohos on the shot (25), J1 PUNISH after the whiff.

## The action policy (行動方針): the base form plays its own ladder

**1. Every confirm into the rifle** (the base kit: `:l-after-j` 1.0 -> 0.0, `:string-k` 0.8 -> 1.0; `:l-after-k` 1.0 kept):
J1 hit -> its K link K2s (the generic string reflex) -> L at f4 -> the stance K K K -> the K route's L L lines while pips last.
A confirm is worth 22 + 38 + 158 (+ 70 a pip) instead of 22 + 45. The gun-kata stays the stance's pick in J's reach
(its refill), the J route's L L / HIRENKYAKU-C as before.
**2. Load the pips from range** (the base's own tables, BR-AI-P: a `(:easy .. :normal .. :hard ..)` value reads as it is,
a plain value x `*BR-AI-DIFF*` as before): `:charge` (0.2 / 0.5 / 1.0), `:far-snipe :p` (0.2 / 0.5 / 1.0); a failed charge
roll takes **the snipe's floor** (BR-AI-SNIPE-FLOOR: level 1 only inside the 4 m shot's reach, else level 2 — round 2
b0a2 / b1a1's floor, credited) — the level-2 / 3 shot gains +2 / +3 pips on a hit **or a block**.
**3. Spend them in close**: `:follow` (0.3 / 0.8 / 1.0) and `:sp2` (0.3 / 0.6 / 1.0): the K route's L L lines and
HIRENKYAKU at the string's end; the cash-out from range (b1a2) unchanged.
**4. The ladder** (BR-AI-LADDER, pure BR-AI-LADDER-INTENT, `*BR-AI-LADDER-P*` 0.3 / 0.6 / 1.0, one roll per ai.lisp intent
re-pick, after any respect): short of the cap the base form's intent is `:zone` (6–12 m, the snipe's range: load), at the cap
`:pressure` (1.2–2.6 m: in for the confirm whose rifle string spends them).
**5. The far snipe only in sight** (BR-AI-SIGHT-P, `*BR-AI-SIGHT-GAP*` 0.6 m, `*BR-AI-SIGHT-F*` 38 f + the delay): the far
window opens only when his predicted miss at the level-2 shot's hit (his offset from Lille's facing + his perceived lateral
drift over the shot's frames, BR-AI-LATERAL over 4 steps of the ring) is within the line; else the window waits unspent
(the stance turns, he stops strafing). The facing part is round 2 b1a0 / b0a1's (credited); the drift is new.
**6. A Hoho on a charge meets the charge's Step** (BR-AI-CHARGE-TICK, `*BR-AI-HOHO-STEP-P*` 0.1 / 0.4 / 1.0, one roll a
charge, BRS `ai-hoho-key`): his Hoho perceived during any charge (the snipe, the dash) -> R18's charge Step (iframes, 5 m, the
charge kept and re-aimed at its end), L's press extended over the Step (round 2 b0a0's piece, credited; only its Hoho clause).
**7. Defence**: `:neutral-guard` 0.1 (b0a2's, credited: no long neutral guard for their Breaker); `:j-share` 0.3 -> 1.0 (no
stance K1, S 16, into a free man in J's reach from neutral: Perfect-Hoho'd 29 times in 40 NORMAL matches).

Per form: **base** — loads at 6–12 m with the squared, still-target snipe (level 2 / 3, +2 / +3 even blocked), Steps out of
a Hoho on its charge, then comes in at full pips; every J that lands becomes J1 -> K2s -> the rifle K K K -> the 70-a-pip
lines; HIRENKYAKU from range at the cap (b1a2). **KIN / EN / the owl** — baseline-r02's, plus the Hoho Step on the dash's
charge. Difficulty: every new chance a table EASY <= NORMAL <= HARD (host-checked), HARD 1.0 everywhere it was 1.0; rolls once
per window / re-pick / charge / string link; SIM-RND01 only; the opponent through the perceived SNAP (and the ring's earlier
SNAPs for his drift).

Kept working: AI-AWAKEN-P / `:awaken`, BARRO-TICK / BR-AI-BURST-P / `:burst` untouched; the learner (BR-LEARN-* untouched; the
ladder sets the brain's intent and returns NIL, the sight only delays a window: the reflex answers nothing new); the ASSIST
(no hook it calls changed; the generic AUTO COMBO's string reflex now takes J1 -> K2s in the base, as BR-ASSIST-COMBO's own
route already did); debug commands and the `duel barro` counters (new: `ai-hoho-step`). New BRS slot: `ai-hoho-key`.

## The steps measured (aieval 40 seeds; "nv diag" = NORMAL never-awaken, seeds 1–8 x 5, 40 matches)

| step | change | score | str | sig | NORMAL (K of 80) | nv diag / A/B |
|---|---|---|---|---|---|---|
| base | baseline-r02 | 0.9102 | 0.853 | 0.923 | 0.36 (12) | 3 / 40; A/B 8 0 1 1 1 (100) |
| K | the rifle confirm only | | | | | 8 / 40; A/B 22 13 11 12 13 (500) |
| v1 | + tables, floor, `:j-share`, `:neutral-guard` | 0.9225 | 0.890 | 0.916 | 0.5325 (35) | 22 / 40; A/B 42 24 31 28 40 (100) |
| v2 | v1 + the ladder | 0.9194 | 0.882 | 0.916 | 0.49 (22) | 23 / 40; A/B 44 21 33 30 30 (100) |
| v3 | v2 + the sight | 0.9276 | 0.905 | 0.914 | 0.455 (25) | HARD diag 73 / 80 |
| v4 | v1 + the sight (no ladder) | 0.9099 | 0.865 | 0.910 | 0.4875 (16) | |
| v5 | v3 + a Hoho envelope in the sight (no shot predicted inside 5.8 m) — not kept | 0.9201 | 0.897 | 0.903 | 0.4825 (22) | |
| **v6** | **v3 + the Hoho Step (delivered)** | **0.9319** | 0.917 | 0.912 | 0.4625 (27) | A/B above |

The ladder alone is flat (v2 vs v1, within noise), the sight alone is flat (v4), together +0.005 / +0.015 strength (v3 vs
v1 / v2): zoning to load only pays when the shots it loads with are taken in sight. NORMAL's ±0.05 noise (b0a2 round 1) is
visible across v1–v6 (0.455–0.5325) with the same NORMAL rules.

## Why it is not a repeat

No cell looked at what the base form does with an opening: every one inherited b1a2's `:l-after-j` 1.0, which made every
confirm the gun-kata's 15s; this cell's logs located it as the base form's lost damage (its NORMAL A/B 0–1 -> 11–13 of 60 from
that one change on the 500 stream), and reverts it for the base only (KIN / the owl keep 1.0, the R17 link). The pip ladder
(load at range -> spend in close, the intent by the resource) and the base's own difficulty tables are new; the sight's drift
term is new (the facing and the floor, the neutral guard and the Hoho Step are round 2 pieces, credited and measured here).

## Expected benefit, risks

- The never-awakened base form now wins: the A/B passes 14 of 15 rows (BK at 100: 16 / 60, 26–28 on the other streams).
  Measured against the evaluator: +0.022 (strength +0.064, signature −0.011 from the K2s bridges: plain-jk 0.067 -> 0.079).
- **Awakening at NORMAL is now worth less than the base form**: the never-awaken side wins ~0.58 of the A/B while his NORMAL
  share with the awakening is 0.4625: his NORMAL awakened forms still run on x0.3 chances while the base has its own tables.
  A later cell (or the integration) may give KIN / EN NORMAL tables the same way (BR-AI-P reads them), watching the band's top.
- NORMAL 0.4625 (0.1375 under the band's top; v1 measured 0.5325 with the same rules on another RNG draw).
- Pacing medians 117.2–156.1 s, >= 63 s under the cap (BY / BK ~117–121 s: the gate's 125 s floor is the user's exception
  question, his matches now end faster vs Yamamoto / Kenpachi).
- The base form zones at 6–12 m short of full pips and walks in at full pips: a human sees the rifle from afar, then a rush;
  a human who strafes keeps the far window closed (he waits square to the line).
- Strength 0.917: the awakened dash's aim (R18) is untouched here (the round's aim cells reach 0.99).

## Combination (for the coordinator)

The pieces are orthogonal to the round's aim line: the base kit's `:l-after-j` / `:string-k` / `:j-share` / `:neutral-guard`
and its `:stance` / `:far-snipe` tables (with BR-AI-P), BR-AI-LADDER, BR-AI-SIGHT-P and the Hoho Step can be merged onto b1a2
(0.9733) or b0a1: those cells' strength comes from the awakened dash's aim, this cell's from the base form.

## Shared-code recommendations (not done)

- ai.lisp: the generic threat Hoho on a perceived 8 f shot (every round 2 cell); a kit hook for the hold-guard after a block.
- The awaken A/B's meaning: with a base form that wins on its own the pass mark (>= 20 / 60) is met; whether NORMAL's
  awakening should stay an upgrade is the user's call (a NORMAL table for the awakened forms would restore it).

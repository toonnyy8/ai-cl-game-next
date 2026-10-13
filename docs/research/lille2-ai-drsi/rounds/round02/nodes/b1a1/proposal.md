# Cell b1a1 (round 2, refines b1a0): "the line has a length, and a distance" — the line-reader's located gaps closed

Freeze 2eaf8b9. Parent: round 2's b1a0 ("the line-reader": a charge is a held threat, released when his feet meet the
frozen aim; the charge's Step out when the line is lost). Its `barro.lisp` copied in, its BARRO-CPU-TESTS section spliced
into the frozen test. Only `duel/lisp/barro.lisp` (his CPU parts: two kits' `:ai` keys, two difficulty tables, new pure
BR-AI-* functions / knobs, three call sites, one branch of BR-AI-CHARGE-TICK) and the `BARRO-CPU-TESTS` section changed.
Host test 8372 checks ALL PASS (the section spliced into the frozen file with `splice-tests.py`: byte-identical to the
delivered test); `tools/pkgcheck.sh duel` 0 / 0 / 0.

Final measure (`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, `score.json`, the delivered file byte for byte, measured
last):

| | baseline-r02 | b1a0 (parent, rescored) | b0a0 (sibling, rescored) | **b1a1 (delivered)** |
|---|---|---|---|---|
| score | 0.9102 | 0.9607 | 0.9696 | **0.9645** (raw 0.9645) |
| strength (HARD, both seats) | 0.853 | 0.983 | 0.993 | **0.985** |
| masher | 1.0 | 1.0 | 1.0 | **1.0** |
| signature | 0.923 | 0.919 | 0.932 | **0.926** |
| NORMAL share (band 0.30-0.60) | 0.36 | 0.3875 (K 11/80) | 0.4325 | **0.445** ×1 (Y 52, K 19, R 43, I 28, S 36 of 80) |
| pacing medians Y K R I S (cap 220, all 40/40 K.O.) | 129.8 124.4 161.3 163.2 158.7 | 136.3 129.6 150.6 159.4 147.1 | 134.1 127.2 152.6 163.4 147.7 | **140.2 136.8 158.5 155.5 163.1** |

sig_by (top): br-e-k 0.265, br-e-kl 0.156, br-oe-k 0.088, br-rc 0.080, charged 0.079, **br-k-hiren 0.066** (parent 0.048),
plain-jk 0.066 (0.072), **br-s-l1- 0.056** (0.046), br-oe-kl 0.051, br-s-j 0.028, br-w-nijushi-c 0.018, br-k-hiren-c 0.013;
outside the whitelist besides plain-jk: counter 0.005, cuts / level-1 dash 0.001 each.

## History read (every proposal, score.json and score.rescored.json; round 1's numbers pre-R18: mechanisms only)

- Round 1: b0a0 0.8032 (L's hold as the plan, the CPU's R17 link, the turn before the follow-up), b1a0 0.6985 (routes on
  events; lacked the turn), b2a0 0.915 (the reach envelope / kite, the Kikon on openings, the snipe let-go fix), b3a0 0.9192
  (the clock, the wings as armour), b0a1 0.952 (b2a0 + b3a0's reserve + the wake-up shot), b1a1 0.9529 (the Step-in
  interrupt, the stance exit, the per-charge let-go), b0a2 0.9549 (the burst kept for the owl; located dead ends: the dash's
  J1 bridge forced by frame data, "bare: back out first" a selection bias, NORMAL's ±0.05 RNG noise), b1a2 0.9716 (every
  link into the stance, the pips cashed from range).
- baseline-r02 0.9102: b1a2 on R18 (the charged L no longer snaps onto him).
- Round 2: **b1a0** (my parent, 0.9607): the line (release when the predicted line meets him), the envelope (the snipe from
  6 m, the Step out inside the CPUs' Hoho envelope), the facing. Its own located weak spots: NORMAL 0.3875 (0.0875 over the
  floor), Kenpachi NORMAL 11/80, the never-awakened base form. **b0a0** (0.9696): the aim (the charge's Step used to re-aim
  on a Hoho / a sidestep), a charge floor, `*BR-AI-DIFF*` NORMAL 0.4. As briefed, not merged: this cell stays on b1a0's
  line (the line is read, not corrected by Steps) and fixes its own gaps.

## Diagnosis of the parent (combat logs as aieval runs them; scratch parsers)

NORMAL (8 seeds × 5 opponents × both seats = 80 matches; then the 40-seed NORMAL runs, 400 matches each):
- **The failed charge roll was a tap.** NORMAL's `:charge` is 0.7 × 0.3 = 0.21: 4 L presses in 5 were taps — the level-1
  snipe (4 m) from the far window's 6 m+, the level-1 dash (6 m) from 7–10 m. 80 matches: 108 level-1 snipes vs 17 level-2,
  291 level-1 dashes vs 161 charged; 112 level-1 snipes whiffed, 13 Perfect-Hoho'd. A bug of the plan, not a difficulty.
- **NORMAL's KIN stands still.** KIN dealt 35 k / took 143 k; 483 openings on an idle KIN (96 k) and 304 on an idle base
  form (57 k) in 80 matches. Raw logs: KIN after a string's exit guards or walks for 4–10 s (the exit roll 0.15, the far
  dash 0.15 a window) until the opponent's J1 or a guard-break Breaker lands (Kenpachi: Breaker 150 on a long guard).
- Kenpachi: 2 / 16 in these runs; the same idle-KIN / idle-base pattern, plus his guard-break Breakers.

HARD (6 seeds, 60 matches; 59 / 60 wins): the parent's signature leaks are structural (the follow-up J1 after the dash 4.1 %
of his damage: forced by frame data, b0a2) except one **located bug of the parent's own change**: b1a0 moved the far snipe
out to 6 m (`:far-snipe :in` 4.5 → 6.0) but the base form's kite still backed off to his envelope + 2 m (~5–5.7 m) and the
unguard to 5.5 m — the base form retreated to where its snipe never starts. 60 HARD matches: 708 far-snipe windows, 113
cash-outs (HIRENKYAKU), 530 + 88 level-2 / 3 snipes.

## The action policy (行動方針): b1a0's line, plus

1. **The line has a length** (BR-AI-FLOOR-LEVEL / BR-AI-PLAN-LEVEL, pure; BR-AI-SNIPE-FLOOR, BR-AI-DASH-FLOOR,
   `*BR-AI-DASH-FLOOR*` 6.4 / 8.4 m): a charge is never planned at a level whose line cannot reach him. The `:charge` roll
   (one per press, unchanged chances) now decides only whether the CPU goes for the planned level (BR-AI-SNIPE-LEVEL /
   -DASH-LEVEL); a failed roll takes the lowest level that still reaches (the snipe: level 1 inside its 4 m + his body,
   else level 2; the dash: level 1 inside 6.4 m, level 2 inside 8.4, else 3), in the base stance's pick (BR-AI-KAMAE),
   the awakened `:sig-hold` and the CPU's R17 link. A rule, the same at every difficulty; HARD (the roll always passes)
   is unchanged by it. NORMAL 80 matches: level-1 snipes 108 → 27, level-2 17 → 100; level-1 dashes 291 → 201.
2. **The line's distance** (BR-AI-BACK-TO, pure; `*BR-AI-SNIPE-BACK*` 0.5): the base form backs off (the kite, the
   unguard) to no nearer than the far snipe's range (*BR-AI-SNIPE-MIN* 6 + 0.5 = 6.5 m); KIN keeps the dash's. The base
   kit's intents lean on the zone (approach / pressure / zone / defend 2 2 3 1 → 1 1 5 1, its zone 6–12 m): the base form
   lives where its line reaches and his first strike does not. HARD 60 matches: far-snipe windows 708 → 1 017, cash-outs
   113 → 175, level-2 / 3 snipes 530 / 88 → 669 / 122; the base form dealt / taken 59.5 k / 58.4 k → 65.9 k / 53.3 k;
   60 / 60 wins.
3. **No shot into his Hoho** (BR-AI-CHARGE-TICK's envelope branch): a snipe charge that perceives his Hoho with its Step
   already spent no longer fires blind at level 2 (`ai-env-shot`, a whiff and his PUNISH J1 string); it holds until he
   reappears, then the line (or the let-go on his attack) decides. 6-seed HARD: env-shots 53 → 43, 60 / 60, signature
   unchanged within noise (kept as the line-reader's own rule: a line is fired only at a man who can be on it).
4. **NORMAL's KIN loads the line**: the far dash's window `:far-dash :p` and the stance exit `*BR-AI-EXIT-P*` EASY / NORMAL
   0.05 / 0.15 → 0.1 / 0.35 (HARD 1.0 unchanged): NORMAL's KIN turns into the charged dash (or backs out to its range) at
   its windows instead of guarding in his first-strike range. Calibrated on R18's rules at 40 seeds (below).

Per form: **base** — lives at 6–12 m; from there the far window's stance, the snipe held for the line (level 2 at least
from 6 m, level 3 from 7 m), HIRENKYAKU's cash-out at full pips; inside his envelope the Step out (b1a0), and now no blind
shot after his Hoho; his kite / a long guard of his sends it back to 6.5 m, not 5 m. **KIN / the owl KIN** — b1a0's;
NORMAL's windows fire more often. **EN / the owl EN** — b1a0's (the line, the window plan, the strings, the reserve, the
volley). Every charge at every difficulty reaches him at its release.

Difficulty: every changed chance a table EASY ≤ NORMAL ≤ HARD (host-checked); the floor and the back-off are rules (no
roll); rolls once per press / window / exit as before. Randomness only SIM-RND01 (the RNG draws are the parent's: the
floor reuses the same `:charge` roll). The opponent only through the perceived SNAP. Kept working: AI-AWAKEN-P / `:awaken`,
the burst (BARRO-TICK, BR-AI-BURST-P, `:burst`) untouched; every debug / test command; the `duel barro` counters; the
learner (BR-LEARN-CHARGE still reads the level, now the floored one; no new reflex, nothing answers every step); the ASSIST
(`:sig-hold` reads the brain through AI-BRAIN as before: the ASSIST's HARD brain always charges, so the floor never acts
for it; the new tick branch is inside BR-TICK-BRAIN's CPU path). No new BRS slot.

## The steps measured (aieval 40 seeds; NORMAL-only runs = the evaluator's own NORMAL jobs, 40 seeds both seats)

| step | change | score | str | mash | sig | NORMAL |
|---|---|---|---|---|---|---|
| b1a0 | parent (rescored) | 0.9607 | 0.983 | 1.0 | 0.919 | 0.3875 |
| v1 | the floor (NORMAL-only run; HARD identical by construction) | | | | | 0.3725 |
| v3 | + NORMAL far dash / exit 0.4 (full run) | 0.9607 | 0.983 | 1.0 | 0.919 | 0.47 (K 17/80) |
| v4 | v3 + NORMAL kite 0.2 (NORMAL-only) — not kept | | | | | 0.665 (out of the band) |
| h2 | v3 + the base form's distance (kite / unguard 6.5 m, zone intents) (full run) | 0.9657 | 0.988 | 1.0 | 0.927 | 0.5125 |
| h4 | h2, NORMAL tables 0.3 (NORMAL-only) | | | | | 0.4025 |
| **fin** | **h2 + no shot into his Hoho, NORMAL tables 0.35 (delivered)** | **0.9645** | 0.985 | 1.0 | 0.926 | **0.445** |

Also tried (6-seed HARD diagnosis, not kept): KIN's intents to the dash's range (no gain, 58 / 60); the base band's L only
from 6 m (fewer snipes: signature 0.9247 vs 0.928). h2 and fin differ by one HARD match and 0.001 signature (noise; fin's
HARD rolls differ from h2's only by the Hoho wait); fin is delivered for its centred NORMAL (0.445, the band's middle: 0.145
over the floor, 0.155 under the top), as the brief's NORMAL margin asked.

## Why it is not a repeat

The floor and the distance are located gaps of the parent's own line, not tweaks of a round-1 mechanism: the parent read
the line's direction but released NORMAL's taps out of their reach, and moved its snipe to 6 m without moving its retreats
there. No cell planned a charge's level by its reach (round-1 cells planned by distance bands or a clock, all before R18,
when a tap still snapped onto him); b0a0's charge floor raises the chance to charge, this one never fires a line that
cannot reach (the chance is untouched). The NORMAL tables are a calibration, measured separately.

## Awaken A/B (informational: AI-AWAKEN-P and the burst untouched)

On a native build of the delivered file, `--cmd 39020`, seed0 100, 60 seeds, the never-awaken side's (P1 Lille II, NORMAL)
wins: **Y 8, K 0, R 1, I 0, S 2; the mirror (pairing 27) 0** (all K.O.; medians 139.6–164.3 s, the mirror 200.0 s). The
parent at seed0 100 (its proposal): 12 0 1 4 0; the parent's mirror on the same stream: 2 / 60. **Not fixed**: the base
form's NORMAL play is now fairer in the evaluator (the floor, the distance), but alone against awakening opponents it still
loses as in every cell; streams 300 / 500 not run.

## Expected benefit, risks

- Benefit: +0.004 over the parent (strength 0.983 → 0.985, signature 0.919 → 0.926: the base snipe and HIRENKYAKU land
  more), NORMAL from the band's floor to its middle (0.3875 → 0.445), Kenpachi NORMAL 11 → 19 / 80.
- NORMAL is noisy and sensitive to the KIN tables: 0.3 → 0.4025, 0.35 → 0.445, 0.4 → 0.5125 (with h2); the kite at NORMAL
  0.2 sent it to 0.665. A later change touching NORMAL should be re-measured at 40+ seeds.
- Pacing medians 136.8–163.1 s, ≥ 57 s under the cap (no risk).
- The base form plays farther away (6–12 m) at every difficulty: a human sees more rifle and less gun-kata from neutral; the
  snipe from 6 m still meets a Hoho behind it with the Step out, and only once a stance.
- HIRENKYAKU's cash-out is Perfect-Hoho'd ~15 % of the time by HARD CPUs (27 of ~175 in 60 matches): more cash-outs, more
  of these (its slide back makes the rest safe).
- The never-awakened base form still loses the A/B (above).

## Shared-code recommendations (not done)

- ai.lisp's threat Hoho tests the perceived frame (`snap-s - snap-sf >= 6`): a HARD CPU with an 8 f delay Hohos an S 8 shot
  on its hit frame (the parent's recommendation stands); the same makes HIRENKYAKU's line (S 20) a Perfect Hoho target.
- STRING-REFLEX `:l-after-*` by difficulty (every earlier cell asked).

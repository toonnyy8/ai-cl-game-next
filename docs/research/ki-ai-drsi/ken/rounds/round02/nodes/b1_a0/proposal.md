# b1_a0 (round 2): the Shikai climb's neutral against her KESSA (the lunge as the main tool, gated to land), on top of the sibling b2_a0's Bankai way in

Direction: 解放攀升 (shikai), keeping the other three themes usable. Parent: none, so this cell starts from BASELINE_DIR, the round-1
champion b3_a1 (0.8334 against Ichigo's champion). Opponent: Ichigo's champion, her b2_a1. Only `duel/lisp/cpu-ki-ken.lisp` changed.
Every new knob is a `defparameter` with a docstring. At HARD the knobs are on; at EASY / NORMAL each keeps the baseline's value.
The worktree is at 3d98bfa, not the freeze 2605e96: `git diff --stat 2605e96 HEAD -- tools duel tests` is empty (only
`docs/research/ki-ai-drsi/` differs).

## History read (proposal.md, score.json, score.rescored.json each)

| Cell | Rescored | Mechanism | What it says for this cell |
|---|---|---|---|
| round 1 b0_a0 / b0_a1 | 0.654 / 0.811 | sealed discipline, the dodge, FS reserve, back Step | the sealed form is solved: sealed he lost 0 Konpaku in the baseline's 40 matches (seeds 1-20 a seat) |
| round 1 b1_a0 / b1_a1 | 0.656 / 0.835 | awaken once, Kikon pointer gate, the turn, L3 SA; **b1_a1's reach-gated lunge at 1.0** (+0.07 on its base) and burst skip (dropped, -0.025) | the lunge gate never reached the champion |
| round 1 b2_a0 / b2_a1 | 0.495 / 0.871 | the Bankai cycle, Hoho approach (neutral on b3_a1); pieces interact, so re-measure them on the target base | |
| round 1 b3_a0 / b3_a1 | 0.411 / 0.876 | antiwave; everything combined = the baseline | |
| baseline (b3_a1, second freeze) | 0.8334 | | HARD 74/80, brawl .681, **shikai .930**, bankai .812, antiwave 2/3 |
| round 2 b2_a0 (landed while I worked) | **0.8698** | the Bankai NS a lunge as the way in, then the SA in its gap into SA J2-J5 + SP home | Bankai stalls gone, HARD 79/80 |

**Shikai at .93 is saturated.** Every failed stay I inspected was the match's last stay: he won in the Shikai before J4 landed (8 of 9
in the baseline's 20 seeds; the 9th was a loss). Shaping the last stay to count would key to the detector, so I did not.

The lever in this direction is what the Shikai costs him. In the baseline's 40 HARD matches (seeds 1-20 a seat):
- Shikai: he dealt 84135 and took 47137, and lost 36 Konpaku there.
- Bankai: he lost 40 Konpaku.
- Sealed: he lost 0.

## Method note: held-out seeds

Variants at 20 / 40 seeds differed by less than the draw. So I also judged each one on **held-out HARD seeds 41-240 a seat** (400
matches, set with the same command line through `*gate-seed0*`). I read wins, the theme rates, and the Konpaku lost by his form. A
scratch runner calls `tools/matchup-eval.py`'s own build and command line, and edits nothing. The 20 / 40-seed numbers below are direct
EVAL_COMMAND runs.

## Mechanism

1. **The lunge at 1.0, only where it lands** (`*kk-lunge-p*` HARD 0.5 -> 1.0, `*kk-lunge-gate*` (nil / nil / t), new `kk-lands-p`).
   - When it fires: climbing at pointer 1 in `*kk-lunge-band*` 3.0-5.2 m.
   - The lunge starts only if NS1's reach + slide - `*kk-reach-margin*` covers the distance, lengthened by her perceived retreat over his
     delay + its startup. That is `kk-pick`'s own test.
   - Otherwise he walks in and the next decision may lunge.
   - This is b1_a1's round 1 piece, credited, and never in the champion. On the champion it is a small plus (below).
   - In the final file's held-out logs, the gated lunge from 3-4 m first-hit his 856 / hers 96 / none 91.
2. **The Shikai pick is the lunge, not J1, beyond 1.7 m** (`*kk-s-ns-p*` 0.8 / 0.8 / 1.0, in `kk-pick` at pointer 1).
   - Where both J1 and the NS reach, the generic mix was NS 0.8. At HARD it is now always the lunge (first hit on f16, 5.1 m).
   - **The evidence is the ablation.** On held-out seeds, without it his Shikai Konpaku lost rose 292 -> 384 and his wins fell
     361 -> 357 of 400 (row "v1b without s-ns" below).
   - What first suggested it was a first-hit tally from the baseline's 20 seeds (Shikai picks from 1.5-3.0 m: NS his 115 / hers 22 /
     none 45; J1 his 43 / hers 19 / none 31). That tally mixed pointers. The later pointer-tagged logs show most Shikai J picks beyond
     1.9 m are at pointer 2, where only J1 reaches and this knob does not apply. So the tally is not the evidence.
3. **Grafted from the sibling b2_a0 (round 2, rescored 0.8698), verbatim:**
   - `*kk-bk-lunge-p*`, `*kk-bk-lunge-max*`, `*kk-bk-sa-p*`, `kk-bk-sa`;
   - the Bankai `kk-pick` zone from the NS a's reach;
   - the removal of `*kk-bk-ns-p*` / `-spare` / `-range` and of `kk-decide`'s Bankai branch.

   Merged by hand into `kk-pick`, next to mechanism 2's clause. In a Bankai J1 still goes first where it reaches, as in b2_a0.
   Why this graft: on held-out seeds the two parts add up. b2_a0 fixes the Bankai stall (Konpaku lost there 362 -> 70, baseline -> b2_a0 alone). Mine cuts the
   Shikai's cost, which grows once the Bankai exits sooner and there are more Shikai stays.

Rules kept:
- One roll per event: the lunge per neutral decision as before; the pick's mix roll once per decision; b2_a0's per approach / per
  segment.
- SIM-RND01 only. EASY <= NORMAL <= HARD for every chance.
- She is read only through the SNAP, the distance and her perceived retreat.
- Nothing is keyed to the evaluator. The style registers only Kenpachi against Ichigo.
- The NORMAL path is unchanged: the NORMAL share reproduces the baseline exactly (0.925 at 20 seeds, 0.9125 at 40).
- The `kk lunge` / `kk pick` combat-log lines are logging only (gate rows byte-identical with and without them).
- Host tests: 9843 checks, ALL PASS.

## Measurements

**20 / 40 seeds a seat (EVAL_COMMAND, paired seeds):**

| Variant | seeds | score | HARD | brawl | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|---|
| baseline (b3_a1) | 20 | 0.8647 | 36/40 | .684 | .909 | .771 | 1/1 | .925 |
| v1: gate + lunge 1.0 + an L3 lunge + s-ns, all difficulties | 20 | 0.870 | 36/40 | .684 | .901 | .814 | 2/2 | **.875** |
| v1b: the same, HARD only (NORMAL restored) | 20 | 0.870 | 36/40 | .684 | .901 | .814 | 2/2 | .925 |
| v1b, gate off | 20 | 0.8651 | 36/40 | .684 | .885 | .798 | 2/2 | .925 |
| b2_a0 alone (its own row) | 20 | 0.9102 | 40/40 | .684 | .933 | .784 | 2/2 | .925 |
| **final (v3c = v1c + b2_a0)** | 20 | **0.9162** | **40/40** | .684 | .906 | **.851** | 2/2 | .925 |
| baseline, rescored | 40 | 0.8334 | 74/80 | .681 | .930 | .812 | 2/3 | .9125 |
| v1b | 40 | 0.8476 | 74/80 | .681 | .912 | .841 | 3/4 | .9125 |
| v1b, gate off | 40 | 0.8501 | 75/80 | .681 | .904 | .832 | 3/4 | .9125 |
| v1c (this cell's Shikai pieces alone: gate, lunge 1.0, s-ns) | 40 | 0.8528 | 75/80 | .681 | .906 | .849 | 3/4 | .9125 |
| b2_a0 alone, rescored | 40 | 0.8698 | 79/80 | .681 | .924 | .811 | 3/4 | .9125 |
| **final (score.json)** | **40** | **0.8755** | **79/80** | .681 (904/1328) | .913 (199/218) | **.860 (178/207)** | .75 (3/4) | .9125 (factor 1) |

**Held-out HARD, seeds 41-240 a seat (400 matches each; Konpaku lost by his form, Shikai / Bankai + Bankai-2):**

| Variant | HARD | shikai | bankai | antiwave | lost in Shikai | lost in Bankai |
|---|---|---|---|---|---|---|
| baseline | 355 | .902 | .793 | 9/11 | 404 | 362 |
| v1b (gate, lunge 1.0, L3 lunge, s-ns) | 361 | .916 | .808 | 9/11 | 292 | 304 |
| v1b + a Shikai meaty at 1.0 (tried) | 359 | .915 | .807 | 11/13 | 276 | 310 |
| v1b without the L3 lunge (= v1c) | **368** | .919 | .812 | 9/12 | 285 | 319 |
| v1b without s-ns (ablation) | 357 | .912 | .802 | 12/14 | **384** | 291 |
| v1c without the gate (ablation) | 363 | .916 | .805 | 10/13 | 300 | 336 |
| v1b + the AS read skipped on her clone NS (tried) | 329 | .877 | .775 | 11/14 | **700** | 229 |
| b2_a0 alone | 379 | .904 | .827 | 9/11 | 376 | 70 |
| **v3c = v1c + b2_a0 (final)** | **384** | .913 | **.847** | 8/10 | 347 | 68 |
| v3c + pointer 2 J1 capped at 2.0 m (tried) | 357 | .866 | .835 | 7/13 | **570** | 125 |
| v3c + the lunge band to 5.6 m (tried) | 384 | identical | | | | |
| v3c + the lunge also at <= 1.7 m (tried) | 382 | .908 | .851 | 12/14 | 353 | 65 |

Brawl is byte-identical in every row (the sealed play is untouched).

**Dropped, with the reason:**
- **The L3 lunge.** At L3 with a plan, the lunge from 3-5.2 m (its gap takes the L3 SA): held-out 361 with it, 368 without. Removed
  from the file.
- **A Shikai-only meaty at 1.0.** Neutral (359).
- **The AS read skipped when her NS is a hitless clone segment (KESSA NS3 a-c).** The baseline's logs looked like a located bug:
  - the read's SP after J1 was hit by the clone in 80 of 158 Shikai bursts (the burst also resets L), and in 89 of 128 KYORAN AS1s;
  - a cancel leaves her move running (`core-nohit!` touches only the attacker), and the clone strikes on her f15.

  Continuing the J string instead was far worse: 329 wins, Shikai Konpaku lost 700. The read is the lesser evil, and the clone trade
  is decided before he can perceive her move. Not a bug.
- **Pointer 2 J1 only within 2.0 m.** Pointer 2 J1 picks from 2.0-3.0 m had first-hit his 146 / hers 151 / none 206. Walking in
  instead was worse (357; Shikai lost 570): she punishes the walk. **First-hit tallies are not counterfactuals.** Only the ablation
  rows above are evidence.

## Why it is not a repeat
- **No earlier cell changed the Shikai's neutral against her KESSA.** The champion picked J1 one time in five from 1.7-3.6 m at
  pointer 1, and lunged at 0.5 per decision with no reach test.
- **The pick preference (mechanism 2) is new.** It is the piece the held-out ablation credits with most of this cell's Shikai gain.
- **The gate (mechanism 1) is b1_a1's,** measured here on the champion for the first time: a small plus on held-out (363 -> 368, Shikai
  lost 300 -> 285).
- **The combination with b2_a0 is new.** The parts are complementary: b2_a0's is the Bankai, mine the Shikai. On held-out seeds the
  combination beats b2_a0 alone by +5 wins / 400, bankai +.020, shikai +.009, Shikai Konpaku lost -8 %.

## Expected benefit and risks
- **Expected:** about 0.87-0.88 against her champion.
  - Over b2_a0 alone: +0.006 on the 40 scored seeds, +0.006 on the 20.
  - Over the baseline: +0.042 at 40.
  - The held-out raw score estimate (no NORMAL) is 0.866 against b2_a0's 0.859 and the baseline's 0.830.
- **Risks:**
  - **The shikai rate fell on the scored seeds,** in this cell's own direction: 0.930 -> 0.913 at 40 seeds (199 of 218 against 185 of
    199; more stays, since the Bankai now exits sooner). On held-out seeds it rose (0.902 -> 0.913). Its failures are still stays won
    before J4.
  - **The gain over b2_a0 alone is small** (+5 wins in 400; Shikai Konpaku lost 376 -> 347). On 40 seeds it is inside the draw. The
    held-out rows are the evidence.
  - **Antiwave opens 2-4 times in 40 seeds.** One flip moves the score about 0.03-0.05. A theme with 0 situations would score 0.
  - **The lunge-first Shikai relies on her KESSA hover sitting inside 5.1 m.** An Ichigo who hovers at 5.2+ m or whiff-punishes the
    lunge's 22-frame recovery would cut it.
  - **NORMAL** is exactly the baseline's: every new knob is HARD only.
- **For the coordinator, a detector quirk (disclosed, not coded around).** In KI seed 2 (baseline), KE-S-J4 hit for 45 and broke her
  bar (`SOUL BREAK ... 0 left`), yet that Shikai stay closed `occ`. A hit that Soul Breaks does not seem to read as "hurt" (`ich-hurt`)
  on the K.O. step, so a stay won by J4-J7 itself fails.

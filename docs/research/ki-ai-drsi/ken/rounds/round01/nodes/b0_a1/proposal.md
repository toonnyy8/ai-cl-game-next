# b0_a1 (round 1): a flash-step budget for the sealed brawl (the Hoho in only with a spare, a back Step when no Hoho is open), plus b3_a0's antiwave

Direction: 封印肉搏, the sealed brawl, with the other three themes kept usable. Parent: b0_a0 (rescored 0.6536). Opponent: Ichigo's
champion (= her v0). Only `duel/lisp/cpu-ki-ken.lisp` changed. Every new knob is a `defparameter` with a docstring.

## History read (each with its score.rescored.json)
- **Baseline v0, 0.3505.** str 10/80; brawl 0.568, shikai 0.768, bankai 0.312, antiwave 0.356.
- **b0_a0 (parent), 0.6536.** Reach-gated neutral starts, the whiff stop, the Hoho dodge on her lunge and clones, the Hoho in, red-only
  Kikons, the AS read in the plans, climb / bankai 1.0. str 53/80; brawl 0.706, shikai 0.841, bankai 0.711, antiwave 0.333 (5/15).
- **b1_a0, 0.6558.** Awaken once per match, the Kikon pointer policy, the turn on her NS, the Bankai dash, the L3 SA. Brawl untouched
  (0.561).
- **b2_a0, 0.4954.** The Bankai as a cycle (cash-outs 0), the L3 Hoho approach, the AS read. Strength only 22/80. Brawl untouched.
- **b3_a0, 0.4106.** Antiwave rebuilt: the plan by what reaches, `:late` Hoho + `:chase` J1, the route AS, and the dash that no longer
  overruns. Antiwave reached 0.75 (24/32), but strength stayed at 10/80 because it sat on v0's sealed play. Its idea was sound; it was
  held back by the parent it stood on, not by a bug.
- The parent re-measured here at 20 seeds a seat: 0.7075 (HARD 30/40, brawl 0.720). This matches its own table.

## Diagnosis (the parent's combat logs, HARD, 10 seeds a seat, every brawl situation bucketed by the hit that closed it)
- Brawl failures: 74 in the KI seat and 49 in the IK seat. The largest buckets:
  - KESSA's clone strike (`IC-HIT` after `IC-K-N3A`): 19 + 14;
  - her sealed NS3a lunge from 4 m: 10 + 13;
  - her NS1a: 10 + 7;
  - her perfect Hoho: 5 + 4;
  - the wave: 5 + 1.
- **Most of the lunge / clone hits found him with no Hoho open.** The dodge (`*kk-dodge-p*`) needs `hoho-open-p`. A Hoho costs 100 of
  his 300 flash-step, which refills at only 9 a second (`*fs-hoho*`, `*fs-regen*`), and needs 60 frames since the last.
  - The parent spent **111 Hohos in 10 matches on the Hoho in**, mostly from 2.9–3.1 m (walking distance).
  - Examples, KI seed 1: the hash at t=600 shows f100 after three Hohos. Her lunge at 841 (no answer, hit at 859); a Hoho in at
    9802, then her KESSA lunge at 9851 with nothing open.
  - Several lunges came 100+ frames after a Hoho in, with no answer at all (logs 1999, 2892, 3127, 5751).
- The Hoho in also often led to a whiff: a J1 / NS after it, then her whiff punish (logs 980→989, 2680→2733, 3867→3892).

## The mechanism (three parts, one theme: spend flash-step where it wins exchanges)
1. **The Hoho in keeps a Hoho in reserve** (`*kk-hin-fs*` 200). The parent's Hoho in fires only with at least 200 flash-step, so the
   reactive dodge (mostly perfect Hohos: the automatic 60 counter and her 40-frame lock) still has its 100. Below that he walks in, as
   the parent did when its roll failed.
2. **The back Step dodge** (`*kk-step-p*` 0 / 0.05 / 0.9, `*kk-step-lead*` 7, `*kk-step-max*` 5.0 m, `*kk-clone-strike*` 15).
   - Where the parent's dodge would answer her move (her lunge, KESSA's clones, any move of hers that reaches him beyond the brawl
     answers) but no Hoho is open: a back Step. One roll per her move start (in `kk-read`, the same event as the dodge roll).
   - A Step is free, invulnerable on frames 3–9, and hops 2.5 m back (neutral stick = back). It is pressed when her perceived frames to
     her hit are at most 7.
   - For KESSA's NS3 the hit is the clone's strike on f15, not the move's startup of 18 (`*kk-clone-strike*`).
   - Never beyond 5 m. In the first version a quarter of the Steps came at 6–7 m against her later NS segments, putting him into her
     Getsuga band for nothing.
   - A new plan `:sdodge` in `kk-wave-step`, beside the parent's `:dodge`.
3. **b3_a0's antiwave, grafted.** Taken verbatim, with these changes:
   - `kk-wave-plan` (`:close` where his NS reaches, else mix 0.25 / 0.15 / 1.0 with `:late` only when a Hoho is open, `:close` not
     beyond 5.6 m);
   - `kk-reach` / `kk-close-hit` / `kk-chase-step`, and the `:chase` after `:late` / `:cut`;
   - the dash that stops at the NS's reach;
   - the Bankai J1 during JUJISHO;
   - `kk-route-as-p` in `kk-move`.
   - b3's `*kk-reach-margin*` 0.3 is renamed **`*kk-wave-margin*`**. That name is the parent's brawl reach gate (0.5), and loading both
     would silently retune one of them.
   - The parent's `:dodge` and the new `:sdodge` stay in the merged `kk-wave-step`. `kks-at` is the press tick for those and the end
     tick for `:chase`; the plans are exclusive in `kks-plan`.
   - The FS reserve helps this part too: `:late` needs an open Hoho.

Rules:
- One roll per event: the Step shares her move-start event with the dodge, and b3's route roll is unchanged.
- SIM-RND01 only. EASY ≤ NORMAL ≤ HARD for every chance (`*kk-step-p*` 0 / 0.05 / 0.9).
- She is read only through the SNAP and the distance. His own flash-step gauge and Hoho availability are his own fighter's state.
- Nothing reads inputs, debug state or the evaluator. The style registers only for Kenpachi against Ichigo.

## Measurements (`matchup-eval --side ken`, against the champion; 20 seeds a seat, paired seeds)

| Variant | score | HARD | brawl (ok/occ) | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|
| parent b0_a0 | 0.7075 | 30/40 | .720 (540/750) | .851 | .717 | .429 (3/7) | .925 |
| v1 + FS reserve + back Step (no distance cap) | 0.7049 | 29/40 | .781 (627/803) | .858 | .698 | .429 (3/7) | .95 |
| v2 + b3_a0's antiwave | 0.7644 | 28/40 | .780 (624/800) | .844 | .748 | .857 (6/7) | .95 |
| **v3 + Step only within 5 m (final)** | **0.8333** | **34/40** | **.795 (630/792)** | .893 | .743 | .857 (6/7) | .95 |
| (ablation: v3 with `*kk-hin-fs*` 0) | 0.8046 | 34/40 | .764 (581/760) | .856 | .677 | .80 (4/5) | .925 |

v1's diagnostic logs (10 seeds a seat), against the parent's:
- Brawl failures fell from 74 → 49 (KI seat) and 49 → 43 (IK seat). The lunge failures in the KI seat fell 10 → 6.
- Brawl wins by perfect-Hoho COUNTER rose from 21 → 41 (KI) and 13 → 41 (IK).
- In the KI seat, Hoho-ins fell from 111 to 73, and perfect Hohos rose from 54 to 87.
- The Step fired about 220 times a seat (before the 5 m cap).

**Final file, 40 seeds a seat (score.json): score 0.8108.**
- Strength 0.85 (HARD 68/80; the parent's 53/80).
- Signature 0.7847: **brawl 0.793** (1280/1615; parent 0.706), shikai 0.879 (0.841), bankai 0.718 (0.711), antiwave 0.75 (12/16;
  parent 0.333, 5/15).
- NORMAL 0.925 (band 0.863–1.0, factor 1).
- Host tests: 9843 checks, ALL PASS.

## Why it is not a repeat
- No cell has treated flash-step as a budget. The parent (and b2's L3 approach) spent Hohos freely, so its own dodge kept finding no
  Hoho open.
- No cell uses the Step as a defensive tool: it is free, and it has its own invulnerable frames.
- The antiwave graft is a new combination of two measured pieces, credited to b3_a0: b3's antiwave and the parent's brawl / strength.
  The combination fixes what held b3 back, its v0 strength, and the parent's weakest theme.

## Expected benefit and risks
- Expected: about 0.81 against Ichigo's v0 (0.6536 parent).
- Risks:
  - **Antiwave rests on 16 situations in 40 seeds** (±0.11 on its rate). Its 20-seed 6/7 is not evidence on its own.
  - **The back Step gives ground.** The 5 m cap was worth +0.07 at 20 seeds, partly through strength, which is noisy (one match =
    0.01). An Ichigo whose style follows up a retreat with NS3a from 4–5 m, or shoots once he is 7.5 m off, would punish the Step more
    than this v0 does.
  - The Step timing (lead 7) and the 200 reserve were not swept; one value each was tried (the reserve's ablation is above).
  - **KESSA's NS3 chain** (a, b, c each summon a clone) still beats a single Hoho or Step now and then. It is the largest remaining
    brawl failure (15 + 4 in v1's logs).
  - NORMAL moved 0.925–0.95 across runs, inside the band. The NORMAL Step chance is 0.05.
  - Next leads: a second Step for her NS3b / c clone; the reserve applied to the meaty chase's Hoho and b3's `:close` Hoho; b1's
    awakening-once / Kikon pointer policy on top.

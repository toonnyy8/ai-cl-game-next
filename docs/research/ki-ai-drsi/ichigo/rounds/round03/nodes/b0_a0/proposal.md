# b0_a0 (round 3, Ichigo): the shut-gauge lunge. Lunge only while his Hoho is shut, from beyond his back Step, as he walks in

Direction: 間合い管理 (spacing), keeping the other three usable. Parent: none, so this starts from BASELINE_DIR (round 2's b1_a1, re-measured
against Kenpachi's champion: 0.8104, spacing 0.062). Opponent: `ken/champion/cpu-ki-ken.lisp`. Only `duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
I read every round-1 and round-2 cell's score.rescored.json, and the baseline's proposal in full. Round 1's b0_a0 / b0_a1 and round 2's
b0_a0 I read in their summary, diagnosis and change sections. For the rest I grepped the proposals for flash-step / lockout / dodge.
Round-3 sibling b1_a0 had delivered when I wrote this (0.8407 rescored: holding ground breaks the 3 m standoff; spacing 0.078). The
other siblings were still empty.

| Cell | Spacing mechanism | Rescored | What it tells this cell |
|---|---|---|---|
| r1 b0_a0 / b0_a1 | pointer-2 re-arm; lunge band 4.7–5.0 (the true start is 0.6 m nearer), lunge in every mode | 0.648 / 0.665 | spacing 0.27–0.35, but only against Kenpachi v0, which had no dodge |
| r2 b0_a0 | KESSA far k-lunge 5.05–5.5, beyond his back Step | 0.415 | in the baseline (`:space` only). It still meets his Hoho (clone reach 7 m) |
| r2 b1_a0 | sealed lunge turned off: 12 hers / 52 his first hits to his Hoho / back Step | 0.584 | the failure this cell fixes |
| r2 b1_a1 (baseline) | c6: sealed `:space` lunge back on: spacing +0.04, whiff −0.05, raw down; kept off | 0.8104 now | as above |

Every earlier spacing push lost to the same dodge, `KK-READ`, and no cell had read when that dodge is unavailable. That is not a repeat
of anything above.

## Diagnosis (scratch runner = run-situ.lisp + a tag on every spacing open / close: her pointer, form, mode, his form, distance)
- Baseline, 10 seeds a seat: 7 of 134 spacing situations succeed. 55 open at a round start (8 m; pointer 1 there can't score). Most
  of the mid-band ones open as his Shikai lunge starts at 4.9 m. Her timed Hoho answers it, and the follow-up J1 is at 0.8 m, so it
  doesn't count.
- **His dodge (`cpu-ki-ken.lisp` `kk-read`)** decides once, as he perceives her move start:
  - the Hoho, only if `hoho-open-p` then (100 of his 300 flash-step and the 60 f lockout over);
  - else the back Step, only if his distance is ≤ `*kk-step-max*` 5.0;
  - else nothing.

  His flash-step sat under 100 in about a third of the hash samples (he spends it on the dodge). The sealed NS3a hits from 5.1 m
  and misses at 5.2 (my trials S5.1 / S5.2). KESSA NS3a + its SA lands to 5.6 m. So with his Hoho shut, a lunge his read places
  beyond 5.0 m has no answer.
- **The perception trap**, found by three tries:
  1. Both CPUs measure from their own current position to the other's position 8 f ago (`brain-perceive`).
  2. Lunging from a perceived 5.05–5.1 m met his read at 3.8–3.9 m. He had begun walking in during her 8 blind frames: his snapped
     position was 0.59 m behind his real one every time.
  3. His read comes another 8 f of his walk later. So the read is the perceived distance less **2 × 8 × his speed**.
  4. When she walked out to make room, he followed at her pace for 150 frames.

## The change (the final file)
`iks-gap` runs in every style mode, both forms, at pointer 3, after the timed Hoho, the confirm and the punish. Its pieces:
- **`*iks-gap-p*`** (0 / 0 / 0.9): rolled once per neutral episode, so NORMAL stays the shipped CPU.
- **`iks-his-hoho-shut-p`**: true while his flash-step is under `*iks-gap-fs*` 96 outside a Burst (in a Burst any flash-step allows a
  Hoho), or his Hoho was seen in the SNAP within `*iks-gap-lockout*` 48 f.
- **`iks-closing`**: his approach speed C, from his last two SNAP positions measured from her current position, so her own walk is
  not in it. NIL when the last call was not the previous step.
- **When it lunges**: only when he is seen walking in (C ≥ `*iks-gap-cmin*` 0.05) and idle / running, and the perceived distance D
  satisfies both:
  - D − 2·C·8 > lo: his read comes beyond his Step;
  - D − C·8 ≤ hi + C·hit: it still reaches him as he walks in.

  `*iks-gap-band*` sets (lo hi hit): sealed (5.25 5.1 18), KESSA (5.25 5.6 28). At C = 0.07 that is a perceived 6.37–6.9 m sealed.
- **Otherwise**:
  - she dashes back to `*iks-gap-wait*` 6.5 (+ `*iks-gap-dash-over*` 0.3) and stands;
  - no dash while his perceived move is live (the Hoho / punish / confirm keep that);
  - `*iks-gap-max*` 150 frames an episode, then the patient play resumes.

  A landed sealed NS3a runs into the existing SA string; KESSA's runs into its k-SA.
- **The read**: his flash-step gauge and Burst are drawn on the HUD for both sides (`hud.lisp` `%hud-flash`, line ~500), and are read
  live, as `gauges-red-p` and the Konpaku pips are (DUEL_MATCHUP_AI §9 accepted those). **The coordinator should rule on it.** The
  lockout half of the test is SNAP-only.

Rolls are once per episode and EASY ≤ NORMAL ≤ HARD. Randomness goes only through `brain-roll`. Every knob is a `defparameter` with
a docstring. The file registers only Ichigo against Kenpachi. Host tests: 9843 checks, ALL PASS.

## Measurements (paired seeds)
| Variant (20 seeds a seat) | Score | HARD | Spacing | Whiff | Ptr3 | KESSA | NORMAL |
|---|---|---|---|---|---|---|---|
| baseline | 0.7892 | 37/40 | 0.041 (11/271) | 0.979 | 1.0 | 0.775 | 0.075 |
| v1 shut-gauge lunge (dash out, stand, lunge on his walk-in) | 0.8252 | 38/40 | 0.282 (113/400) | 0.885 | 1.0 | 0.80 | 0.075 |
| **vA = v1 + no dash while his move is live** | **0.8384** | 39/40 | 0.254 | 0.904 | 0.98 | 0.85 | 0.075 |
| vB = vA + old KESSA far k-lunge only while shut | 0.831 | 39/40 | 0.219 | 0.916 | 0.981 | 0.825 | |
| vC = vA + closing clamp 0.12 → 0.2 | 0.831 | 39/40 | 0.214 | 0.872 | 0.979 | 0.875 | |

The 10-seed diagnostics trace the path to v1:
- first try, a stand at 5.05: spacing 19/134, lunges mostly met his Step;
- C ≥ 0.05 with a walk back: 4–5 / 117, almost no lunges;
- dash out: 62/215.

In the dash version, his reads land at 5.0–5.6 m and the sealed lunges land (whiff-mode 15 of 17, ptr3 11 of 12 situations).
Mean match length: 168.6 s at baseline, 164.0 s with the dash. Time-outs: 2 in each.

**40 seeds a seat:**

| Part | Baseline (re-measured) | v1 | **Final (vA)** |
|---|---|---|---|
| Score | 0.8104 | 0.8306 | **0.8387** |
| HARD | 77/80 | 78/80 | **79/80** |
| Spacing | 0.062 (35/561) | 0.271 (226/835) | **0.253 (209/827)** |
| Whiff | 0.978 | 0.879 | 0.891 |
| Ptr3 | 0.99 | 1.0 | 0.99 |
| KESSA | 0.805 | 0.787 | 0.825 |
| NORMAL | 0.075 (factor 1) | 0.075 | 0.075 (factor 1) |

## Expected benefit, risks
- **Spacing is a usable tool now.** It went from 0.06 to 0.25, the only theme with room left. Strength held (79/80).
- **Whiff is the cost.**
  - It fell 0.978 → 0.89, with fewer situations too (603 vs 786).
  - Her time out at 6.5 m is time not spent at his whiff distance, and a dash can't Hoho.
  - The guard got back part of it. The rest is scattered over idle / run cells in KESSA against his Bankai.
- **The flash-step read is a new HUD read** (above). Without it, only the lockout half remains, and the lunge would come far less
  often. That variant was not measured.
- **What would cut it**:
  - a Kenpachi that keeps one Hoho in reserve or widens `*kk-step-max*`;
  - one who stops walking in when out of reach at 6 m.
- **Combination for the coordinator**: sibling b1_a0 (hold ground, break the 3 m standoff) touches the patient hover and the time-outs.
  `iks-gap` sits in its own branch before the hover, so the two should compose.
- **Rejected here**: gating the old KESSA far k-lunge on the shut gauge (vB), and a faster closing clamp (vC).

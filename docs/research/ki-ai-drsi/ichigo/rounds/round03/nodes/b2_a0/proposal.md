# b2_a0 (round 3, Ichigo): the bait hover ends the sealed stand-off; KESSA pointer 3's k-lunge stops its SA on his seen dodge

Direction: 指針三狩魂 (ptr3), keeping the other three usable. Parent: none, so this starts from BASELINE_DIR (round 2's b1_a1,
re-measured against Kenpachi's champion: 0.8104, HARD 77/80). Opponent: `ken/champion/cpu-ki-ken.lisp`. Only
`duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
- Every round-1 / round-2 score.rescored.json and the summary, mechanism and measurement sections of each proposal.
- Read whole: the baseline's (b1_a1), and round 2's b0_a1 (the meaty), because both pointer-3 and spacing run through it.
- Round-3 siblings were empty when I started. They delivered while I measured, and I re-read them before writing:
  - b1_a0 (0.8407): holds ground after 90 f of hovering. It found the same stand-off, by another mechanism (below).
  - b3_a0 (0.8343): a disciplined KESSA, and a k-SA floor of 2.0 m.
  - b0_a0 (0.8387): lunges only while his Hoho is shut. Spacing 0.253.
- **Pointer 3 is saturated**: ptr3 is 0.99 in the baseline (202 / 204), and 0.92–1.0 in every cell since round 1's b2_a1. The hint can
  only pay through the other themes, so this cell puts pointer 3 to work for them. Two things count:
  - how fast a match reaches pointer 3 and its 5-Konpaku Soul Break;
  - what KESSA's pointer-3 tool, the k-lunge, costs.
- No past failure here was a bug left in, except the one located below, which was inherited from round 2's b0_a0 / b3_a0.

## Diagnosis (baseline, 20 seeds a seat, HARD)
Scratch tools are under `scratchpad/ki-ichigo-b2_a0/`. A copy of situ.lisp adds `sx` lines: each spacing open with her form / pointer /
his form, each of her move starts and each of his hurts. Parsers cover quiet stretches, combo openers and the KESSA ledger.

1. **Sealed against sealed, nobody commits.**
   - Stretches of 10 s or more with no hit by anyone fill 58 min of the 40 matches. That is about half of all match time.
   - The cells: her pointer 1 at the opening (1188 s), her pointer 1 mid-match (1006 s), her pointer 3 against his sealed form (1280 s).
   - The first hit lands at a median 1486 ticks (25 s).
   - Her patient hover (3.4–3.8 m at pointer 1, 3.7–4.2 at pointer 3) sits outside every move he starts from neutral. KK-REACH starts
     his NS1a from at most 2.6 m and his J1 from 1.9 m. He walks in and she walks back at the same speed.
   - Seed 12 (P1 seat): 148 s at about 3.2 m with no hit.
   - When a stretch ends, it ends in her favour, 90 of hers to 19 of his. He commits, she times a perfect Hoho, then the counter, the J
     string and AS3. So the cost is only the time spent.
   - **All three HARD losses were 300 s time-outs behind on Reishi.** The awakening fills by damage only, so in those matches it came
     at 286–308 s, and two of the nine kessa failures are those late KESSAs.
2. **KESSA pointer 3's k-lunge SA after his dodge** (a located bug). KK-READ answers her NS3a with a Hoho (he lands 1.6 m behind her)
   or a back Step (2.5 m back). `iks-move` still pressed the SA in NS3a's gap:
   - after a Hoho it started at a true 0.8–1.6 m with him behind her;
   - after a Step it started at 5.2–5.6 m and mostly whiffed.
   - Of 21 SAs pressed after a dodge, his hit came first 8 times and hers 2 times. Without a dodge it was 2 / 9.
   - `k-sa` and `k-lunge → KE-S-N1A` were among his biggest KESSA combo openers (9 combos for 1325, and 15 for 2665).
   - The same branch read her true `fighter-dist`, not the perceived distance it is given (a rule risk).

## The change
1. **The bait hover** (`*iks-bait-hover*` `(:base (2.3 2.7) :nozarashi nil)`, `*iks-bait-modes*` HARD `(:whiff :ptr3 :kessa)`,
   helper `iks-hover-band`).
   - The episodes of those modes hover inside the distance his sealed NS1a starts from, and just out of his J1's.
   - He commits to the NS1a. Its S14 is seen 6 f before the hit, inside the timed Hoho's lead window (1 6). The perfect Hoho's counter,
     the follow-up's J string and AS3 then write pointer 3 at once, instead of after minutes of walking.
   - `:space` keeps the old bands (間合い管理: no exchange at 1.7–3.6 m).
   - Against his released forms, nothing changes: the 4.9–5.3 m hover already draws his lunge.
   - It is not a neutral start into his read. Round 2 measured those at 7 hers / 71 his first hits. Here she never presses first; he
     does, into her timed Hoho.
2. **`*iks-k-sa-dodge-stop*` T.** The k-lunge's SA is not pressed while his perceived state is `:hoho` / `:step`. NS3a ends there and
   the neutral's timed Hoho takes over.
3. **`*iks-k-sa-perceived*` T.** The SA's reach test reads the perceived distance `d`, so `iks-move` now takes `d`. On seeds 1–20 it is
   identical to the true distance (B0 = B0p).

Rules:
- The bait hover is HARD only. The SA stop and the perceived reach are rules, not chances, and they act in every style mode, NORMAL's
  included. NORMAL measured unchanged (0.075, factor 1).
- There are no new rolls: the hover is not a chance, and the stop is a rule.
- He is read only through the SNAP's state and the perceived distance.
- The file registers only Ichigo against Kenpachi.
- Host tests: 9843 checks, ALL PASS. `pkgcheck duel` is clean.

## Measurements
Rows 1–20 are seeds 1–20 a seat, paired, HARD only (`--no-normal`). Raw = 0.4 strength + 0.6 signature. Each row builds on the one
named.

| Variant | raw | HARD | spacing | whiff | ptr3 | kessa |
|---|---|---|---|---|---|---|
| baseline (full eval) | 0.7892 | 37/40 | 0.041 (11/271) | 0.979 | 1.0 | 0.775 |
| A = patient KESSA (`*iks-patient-forms*` + :kessa) | 0.8028 | 37 | 0.029 | 0.982 | 1.0 | 0.875 |
| B = A + SA dodge-stop + perceived | 0.8083 | 37 | 0.065 | 0.982 | 1.0 | 0.875 |
| **B0 = SA dodge-stop + perceived only** | **0.8133** | 38 | 0.085 (23/272) | 0.979 | 1.0 | 0.825 |
| B0p = B0 with the true distance | 0.8133 | 38 | identical | | | |
| C1 = B0 + `:kessa` vs his released forms → far k-lunge | 0.8147 | 38 | 0.068 | 0.979 | 1.0 | 0.85 |
| C2 = B0 + the same → hover | 0.8141 | 38 | 0.065 | 0.979 | 1.0 | 0.85 |
| H3 = C2 + hover 2.7–3.1, all modes | 0.8415 | 40 | 0.083 | 0.995 | 0.991 | 0.875 |
| H1 = C2 + hover 2.3–2.7, all modes | 0.8481 | 40 | 0.105 | 0.992 | 0.991 | 0.90 |
| H2 = C2 + hover 2.0–2.4, all modes | 0.8488 | 40 | 0.110 | 0.992 | 0.99 | 0.90 |
| **H4 = C2 + bait hover 2.3–2.7 for :whiff / :ptr3 / :kessa** | **0.8532** | 40 | 0.092 | 0.98 | 1.0 | 0.95 |
| K1 = H4 + far k-lunge and meaty skip for :ptr3 too | 0.8446 | 40 | 0.177 (58/327) | 0.987 | 1.0 | 0.80 |
| K2 = H4 + far k-lunge for :ptr3, meaty kept | 0.8456 | 40 | 0.113 | 0.983 | 1.0 | 0.875 |
| **H5 = H4 − C2's piece (the final file)** | 0.8507 | 40 | 0.069 | 0.986 | 1.0 | 0.95 |

- The stand-off is gone. On H1's logs, quiet stretches of 10 s or more fall from 58 min to 2.2 min, and the first hit comes at a median
  82 ticks, against 1486.
- **Seeds 21–40 a seat, HARD only** (the scratch observer reproduces the evaluator's HARD numbers):

  | File | raw | HARD | kessa |
  |---|---|---|---|
  | baseline | 0.8317 | 40/40 | 0.838 |
  | H4 (not the delivered H5) | **0.8520** | 40/40 | 0.975 |

  The gain holds out of sample for H4. For the delivered H5, the final 40-seed line below already covers seeds 21–40.
- Dropped:
  - C1 / C2 are level with B0, within noise. H5 removes that code, so there is one switch fewer.
  - A (patient KESSA) is level, and it reverses round 1's finding on noise.
  - K1 / K2: the k-lunge for :ptr3 trades spacing for the KESSA ledger, a net loss. Round 2's b3_a0 (all modes 0.5632) and b1_a0 r3
    agree.

**Final, 40 seeds a seat (EVAL_COMMAND, score.json):**
`{"side": "ichigo", "seeds": 40, "strength": 1.0, "signature": 0.7528, "excluded": [], "themes": {"spacing": {"rate": 0.071, "ok": 36, "occ": 509}, "whiff": {"rate": 0.983, "ok": 686, "occ": 698}, "ptr3": {"rate": 0.995, "ok": 205, "occ": 206}, "kessa": {"rate": 0.963, "ok": 77, "occ": 80}}, "hard": "80/80", "normal": {"share": 0.075, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.8517, "score": 0.8517}`

| Part (40 seeds) | Baseline | **b2_a0** |
|---|---|---|
| Score | 0.8104 | **0.8517** |
| HARD | 77/80 | **80/80** |
| Spacing | 0.062 (35/561) | 0.071 (36/509) |
| Whiff | 0.978 | 0.983 |
| Ptr3 | 0.99 (202/204) | 0.995 (205/206) |
| Kessa | 0.805 (62/77) | **0.963 (77/80)** |
| NORMAL | 0.075 (factor 1) | 0.075 (factor 1) |

Two docstrings in the delivered file are slightly off. They are left as they are, because the file is the measured one:
- `*iks-k-sa-dodge-stop*`'s "against 9 / 2 when he did not dodge" is in hers / his order: hers 9, his 2.
- `*iks-bait-hover*`'s band rows were measured on the C2-based files (H1–H3), not on H5.

## Not a repeat
- No earlier cell moved the patient hover inside his attack distance. Round 2's c10 moved it outward (4.0–4.6) and was level.
- Round 3's b1_a0, written at the same time and independently, breaks the same stand-off another way: it holds ground after 90 f of
  hovering. Here the band itself sits in his NS1a's start distance, from the first frame, for the whiff / ptr3 / kessa modes only.
- The SA dodge-stop is a located bug fix: the SA is skipped on a dodge the SNAP shows. Sibling b3_a0's `*iks-k-sa-min*` (an SA floor of
  2.0 m) touches the same SA by distance alone, so the two compose.
- For the coordinator: b0_a0's shut-gauge lunge (spacing 0.253) is the spacing piece this file lacks. It would compose with the bait
  hover, which changes only the sealed hover of the three non-space modes.

## Expected benefit, risks
- **Benefit.** No time-outs (80/80) and an earlier awakening, so KESSA has time to win its ledger (kessa 0.805 → 0.963). Pointer 3
  arrives sooner (AS3 off the first counter). The gain held on seeds 21–40 (+0.020 raw HARD).
- **Spacing is barely moved.** Its pools are structural:
  - resets to 8 m: after her Soul Break his awakening cinematic closes the situation; at the match start pointer 1 can't reach;
  - his Shikai's dodge meets her sealed NS3a.
- **His likely answer.** A Kenpachi that holds his NS1a against a close hover and walks to J1 range (1.9 m). His J1 (S6) is faster
  than her perception, so a hover at 2.3 m relies on his own reach discipline. H2's 2.0–2.4 band scored the same, which leaves a
  margin.
- **Carried over.** The baseline's risks: the perfect-Hoho lock, the meaty loop, and the form read for the band tables.

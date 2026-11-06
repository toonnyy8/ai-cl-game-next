# b3_a1 (round 2, Ichigo): KESSA spends the flash-step on the Hoho, and the wake-up Hoho's lock is punished

Direction: KESSA 強攻 (kessa), keeping the other three usable. Parent: round 2's b3_a0 (0.7151 at 40 seeds, HARD 65/80, kessa 0.75).
Opponent: `ken/champion/cpu-ki-ken.lisp`. Only `duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
I read the baseline, round 1's eight proposals and round 2's delivered cells, each with score.json and score.rescored.json. Every
rescore equals the cell's own line. b0_a1, b1_a1 and b2_a0 were still empty when this was written (re-listed just before).

| Cell | Mechanism | Rescored | Here |
|---|---|---|---|
| r1 b0 / b1 / b2 / b3 | pointer-2 re-arm, hover; whiff confirm; Konpaku finisher; KESSA timed Hoho + follow-up, read floor | 0.648–0.783 (first freeze) | all in the parent |
| baseline (r1 b2_a1, re-measured) | | 0.2877 | |
| r2 b0_a0 | b3_a1's Hoho graft, far k-lunge 5.05–5.5 in all modes | 0.4151 | far band for `:space` in the parent |
| r2 b1_a0 | patient sealed form, NS whiff stop, timed Hoho in both forms with the untimed one off, breaker, no Hoho after her Burst | 0.584 (58/80, whiff 0.807, kessa 0.139) | not grafted (its refine b1_a1 is the natural place for the combination) |
| r2 b3_a0 (parent) | wake-up Hoho, his slide in the Hoho's reach, follow-up window 64, follow-up after any perfect Hoho, sealed-form timed Hoho | 0.7151 (65/80, kessa 0.75) | starting file |

No past failure was a bug left in. Two open leads in the parent's own risks: "flash-step is the bottleneck" (117 of his KESSA lunges
found her with no Hoho) and the wake-up Hoho's gain being only his 40 f lock. This cell goes after both. They are located faults, not
sweeps. b1_a0's v11 had found that keeping a Burst in reserve by Hohoing less loses (24/80 against 38/80). That is the same trade, in the
direction this cell takes further.

## Diagnosis (the parent, HARD, 20 seeds a seat; scratch runners over matchup-eval's own `run` / `parse`)
The parent's 20-seed line reproduced exactly (0.7271, 33/40).
1. **Kessa failures are losses.** 8 of 40 matches failed the ledger, 6 of them lost. In KESSA, his most damaging opener is the Shikai
   lunge TOSSHIN (KE-S-N1A, S16, reach 2.6 + slide 3.0): 134 hits, 9.4k. Next come the Bankai's special AS (7.2k) and his COUNTERs
   (his perfect Hohos, 3.0k).
2. **The timed Hoho is refused by the Burst reserve, not by an empty gauge.** I logged every frame of the timed Hoho's lead window in
   KESSA with the roll, `hoho-open-p` and `ai-hoho-spare-p` (one throwaway run):
   - Of 261 frames refused only by `ai-hoho-spare-p` (roll yes, Hoho open), 228 had 100–300 flash-step.
   - The cause: below `*ai-burst-low*` (half her Reishi) the shipped budget keeps `*fs-burst*` 200 on top of the Hoho's 100.
   - Against TOSSHIN alone: about 33 windows refused this way, 41 in the Hoho lockout, 16 Hohoed.
   - Of the TOSSHIN combos that opened on her in KESSA, 81 found her with no action of her own in the last 90 f.
3. **The wake-up Hoho's lock went unused.**
   - After a wake-up Hoho that was perfect but hit on its first frame (95 in the sealed form, 50 in KESSA), his next hit came first 70
     times, hers 30, nobody's 45.
   - His next hit came a median 98–126 f later: after the lock he J1'd her point-blank again.
   - Logged on the new code: she is first free 38 f after the Hoho, 2 f before his 40 f lock ends. The parent's follow-up never runs
     there. It is armed only by a perfect flag seen in her `:hoho` state, and she leaves that state on the Hoho's first frame when hit.
     It also waits for his recovery or reeling, and he is idle and locked instead.

## The change (the final file)
1. **`*iks-hoho-no-reserve*` (:kessa)**: in KESSA the timed Hoho needs only `*fs-hoho*` 100, not the shipped Burst reserve. HARD only,
   through `*iks-kessa-hoho-p*` (0 below HARD). The sealed form keeps `ai-hoho-spare-p`.
2. **The lock punish** (`iks-lock-punish`, `*iks-lock-punish-p*` 0 / 0 / 0.95, `*iks-lock-slack*` (:base 13 :kessa 7)).
   - The trigger: a Hoho the style pressed (the wake-up one or the timed one) whose PERFECT count rose, and which was not seen clean
     in `:hoho` (the clean case keeps the parent's follow-up).
   - On her first free frame: one roll, then the fastest `*iks-punishers*` entry (her form and pointer) that lands within the lock end
     plus the slack, walking in first if the frames allow. In practice that is J1 from 0.8 m behind him.
   - The string is tagged like the follow-up, so it runs to AS3.
   - It reads only her own facts: her press tick, her PERFECT count (`gauges-perfects`), her state, and the perceived distance.
3. A small refactor: the confirm's punisher choice moved into `iks-pick-punisher` / `iks-punisher-go`, shared by the two. Its behaviour
   is unchanged. NORMAL reads 0.100 as before, and NORMAL has the confirm at 0.1.

Rules: every chance EASY ≤ NORMAL ≤ HARD, one roll per perfect Hoho. Randomness only through `brain-roll`. Every tunable is a
`defparameter` with a docstring holding its numbers. The file registers only Ichigo against Kenpachi. Host tests: 9843 checks, ALL PASS.

## Measurements
HARD-only rows: a scratch runner with the evaluator's own `parse`, the seeds split in 4 jobs (seed offset 30000+k), raw = 0.4 str +
0.6 sig. Its 40-seed v4k line equals the final EVAL_COMMAND's HARD part exactly.

| Variant (HARD) | Seeds 1–40: raw / HARD | Spacing | Whiff | Ptr3 | Kessa | Seeds 41–80: raw / HARD | Kessa 41–80 |
|---|---|---|---|---|---|---|---|
| parent b3_a0 | 0.7151 / 65 (its score.json) | 0.155 | 0.711 | 0.986 | 0.750 | 0.7015 / 63 | 0.738 |
| v2: + lock punish, slack 7 / 7 | 0.7076 / 63 | 0.149 | 0.713 | 0.993 | 0.762 | | |
| v3: + lock punish, slack 13 / 7 | 0.7266 / 69 | 0.154 | 0.694 | 0.947 | 0.750 | | |
| v4: v3 + no reserve in both forms | 0.7775 / 76 | 0.143 | 0.725 | 0.944 | 0.838 | | |
| **v4k: v3 + no reserve in KESSA (final)** | **0.7865 / 77** | 0.148 | 0.710 | 0.944 | **0.875** | **0.7638 / 74** | 0.762 |
| v5: final without the lock punish (p 0) | 0.7740 / 73 | 0.159 | 0.730 | 0.987 | 0.850 | 0.7599 / 71 | 0.838 |

- **No reserve:** +0.05–0.06 raw on each seed block (v3 → v4k on 1–40; v5 / v4k against the parent on 41–80). It is the main gain:
  kessa 0.75 → 0.875, HARD 69 → 77 of 80.
- **The lock punish:** over 80 seeds a seat, +0.008 raw and +7 wins of 160 (151 against 144). Kessa is mixed (131 against 135 of 160),
  and so is ptr3 (−0.04 on seeds 1–40, +0.007 on 41–80).
  - Its own effect is clear in the logs: after a perfect wake-up Hoho hit on its first frame, hers-first rose from 30 to 93 (v3, 20
    seeds a seat) and his-first fell from 70 to about 25.
  - I kept it for the wins and the located reason. It is the smallest part of the gain.
- v1 (the lock punish with the confirm's 3 f slack) never fired (she is free 2 f before the lock ends, and J1 needs 9). It still
  moved the 20-seed score 0.7271 → 0.7017 through the RNG stream alone, so 20-seed differences under about 0.03 are noise here.

**Final (EVAL_COMMAND, 40 seeds a seat, score.json):**
`{"side": "ichigo", "seeds": 40, "strength": 0.9625, "signature": 0.6692, "themes": {"spacing": {"rate": 0.148, "ok": 174, "occ": 1177}, "whiff": {"rate": 0.71, "ok": 581, "occ": 818}, "ptr3": {"rate": 0.944, "ok": 151, "occ": 160}, "kessa": {"rate": 0.875, "ok": 70, "occ": 80}}, "hard": "77/80", "normal": {"share": 0.1, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.7865, "score": 0.7865}`

| Part (40 seeds) | Baseline | Parent b3_a0 | **This cell** |
|---|---|---|---|
| Score | 0.2877 | 0.7151 | **0.7865** |
| HARD | 6/80 | 65/80 | **77/80** |
| Spacing | 0.062 | 0.155 | 0.148 |
| Whiff | 0.556 | 0.711 | 0.710 |
| Ptr3 | 1.0 (31) | 0.986 (139) | 0.944 (160) |
| Kessa | 0.100 | 0.750 | **0.875** |
| NORMAL | 0.100 | 0.100 | 0.100 (band 0–0.138, factor 1) |

## Not a repeat
- The Burst reserve in the timed Hoho's budget had not been touched. b3_a0 named flash-step as the bottleneck without separating
  "empty" from "reserved", and b3_a0's v6 and b1_a0's v11 moved the budget the other way (both lost).
- The lock punish is new. b3_a0's follow-up covers the clean perfect Hoho only. The hit-on-frame-one case falls through its `:hoho`
  check and its "he is reeling" test.

## Expected benefit, risks
- **Benefit:** 0.7151 → 0.7865 at 40 seeds (HARD 65 → 77 of 80, kessa 0.75 → 0.875). It holds on seeds 41–80 (0.7015 → 0.7638,
  63 → 74 of 80).
- **Less flash-step for the Burst in KESSA.** The generic Burst (200) now often finds the gauge spent. That is the intended trade, and
  b1_a0's v11 measured the same direction: Hohos are worth more than Bursts against this Kenpachi. A Kenpachi that baits Hohos would
  drain her faster.
- **The lock punish leans on an engine fact.** A perfect Hoho locks his inputs 40 f even when his hit lands on its first frame, and
  she is free about 2 f before the lock ends. If hitstun or `*perfect-lock*` changes, the slack no longer fits and it simply stops
  firing (`iks-pick-punisher` finds nothing).
  - The sealed J1 (S14) lands about 13 f after the lock. His Hoho dodge can read it, yet slack 13 beat 7 (69 against 63 of 80).
- **Ptr3 dipped on seeds 1–40** (0.986 → 0.944). On 41–80 it is 0.981 against the parent's 0.971, so I read it as noise around a
  small cost: more of her strings start from the lock punish's J1, and those Soul Breaks are not all at pointer 3.
- **Spacing stays the weakest theme (0.148).** This cell did not work on it.
- **Carried from the parent:** the wake-up Hoho's engine interaction, the Konpaku-pip read, and his form for the band tables.

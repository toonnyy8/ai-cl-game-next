# b3_a0 (round 3, Ichigo): a disciplined KESSA. She Hohos or Steps away from his coming attack instead of pressing into it

Direction: KESSA 強攻 (kessa), keeping the other three usable. Parent: none, so this starts from BASELINE_DIR (round 2's b1_a1, re-measured
against Kenpachi's champion: 0.8104, HARD 77/80, kessa 62/77). Opponent: `ken/champion/cpu-ki-ken.lisp`. Only
`duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
- I read every round-1 and round-2 score.rescored.json, and the baseline's proposal in full.
- I read the summary / change / measurement sections of round 2's b3_a0, b3_a1, b0_a0 and b0_a1, the cells that worked on KESSA and spacing.
- No round-3 sibling had delivered when I read them.
- The baseline (b1_a1) holds round 2's b3_a0 pieces, but not b3_a1's. b3_a1 drops the Burst reserve from the KESSA Hoho: +0.05–0.06 raw on
  its parent, kessa 0.75 → 0.875. It also added the lock punish, which was small. b1_a1 itself names the reserve as "the next graft".
- No past failure was a bug left in. The round-1 note "hovering in KESSA lost its ledger" was against another Kenpachi, with no Hoho kit.

## Diagnosis (baseline, HARD, seeds 1–40 a seat)
Scratch runner: run-situ.lisp plus a dump of the KESSA ledger at each match end, and log parsers (`scratchpad/ki-ichigo-b3_a0/`).
1. **Failures: 15 of 77.** Each failed match spent long in KESSA, and he reached L3 and the Bankai cash-out there.
   - Openers of his combos in failed matches: his Bankai J1 (KE-KR-J1, the meaty loop) 10.2k, his Shikai lunge TOSSHIN (KE-S-N1A) 8.5k,
     his perfect-Hoho COUNTERs 6.4k.
   - Each lunge hit is +1 L, and the third leads to J1–J7 + the Bankai.
2. **What her KESSA starts opened** (his combos after each start; dealt / taken):
   - the generic CPU's NS1 chains: 1 hers / 20 his, 60 / 7.6k;
   - the generic's NS3a: 34.7k / 9.2k;
   - the generic's J1: 25.5k / 8.0k;
   - the pointer-2 J: 3.2k / 7.0k.
   Most of the losing starts were pressed while his move was already under way (the SNAP is 8 f late).
3. **After her awakening's cinematic** both fighters are idle, and his first hit came first 28 times of 77 (hers 44). He presses his lunge
   on the first free frame, while her SNAP still shows him idle and she starts a k-lunge or J1 into it.
4. **Why no Hoho** (logged on the frames of the Hoho's window against attacks that then hit her in KESSA): the Hoho was not open on 103
   of 223 frames. On 60 of them her flash-step was under 100; on 43 she was in the 60 f lockout.
5. **A located bug, the k-lunge's SA.** `iks-move` pressed KESSA NS3a's SA at any distance under 5.7 m. When his dodge Hoho carried him
   through her clone (he lands 1.6 m off), she still lunged.
   - SAs under 2.0 m, first hit within 60 f: hers 15 / his 15 / none 31.
   - At 2.0 m or more: hers 26 / his 9.

## The change (final file)
1. **`*iks-hoho-no-reserve*` (:kessa)**, round 2 b3_a1's graft into `iks-timed-hoho`: in KESSA the timed Hoho needs only `*fs-hoho*`.
2. **`iks-step-dodge`** (new: `*iks-step-dodge-p*` 0 / 0 / 0.9, `*iks-step-dodge-forms*` (:kessa), `*iks-step-lead*` (3 6)).
   - When: his attack is coming (`iks-threat-p`, the timed Hoho's own reach + slide test) and the timed Hoho won't come (roll no, locked
     out, or flash-step short).
   - What: a back Step. It is free, with iframes f3–f9 and a 2.5 m hop, and it is pressed so his first active frame falls in the iframes.
   - One roll per his move start.
   - The lead (4 8) let his TOSSHIN (active 4) hit 12 of 30 times, since active frames 7–8 fall after f9. At (3 6), none of 26 dodges was
     hit within 60 f. His own style dodges her lunges with the same Step.
3. **`*iks-kessa-hold*` (HARD)**: in KESSA, while `iks-threat-p` holds and no Hoho was pressed, she starts nothing.
   - The style backs off (stick away).
   - A press the generic CPU just made is dropped (`iks-generic`).
4. **`*iks-kessa-no-chains*` (HARD)**: in KESSA the generic's neutral SP at pointer 1 (the chains) is dropped.
5. **`*iks-cine-settle*` (HARD 20) with `*iks-cine-gap*` 90.** On her first free step after a gap of more than 90 frames with no style
   call, she starts nothing for her perception delay + 20 frames. The timed Hoho, the step dodge, the wake-up Hoho and the meaty still run.
   - In the logs every such gap is a cinematic: her awakening (170), his Shikai's (109), Kikon / Soul Break (229–253).
   - At 4 frames she still pressed into his lunge about 20 f after the cinematic, so it was raised to 20.
6. **`*iks-k-sa-min*` 2.0**: the k-lunge's SA only from 2.0 m on (item 5 of the diagnosis).

Rules:
- Every new chance is 0 / NIL below HARD, so NORMAL's play is unchanged. Rolls are once per his move start.
- He is read only through the SNAP and the perceived distance. Her own state and gauges are read as before; the cinematic is read from
  her own call gaps.
- Randomness only through `brain-roll`. Every tunable is a `defparameter` with a docstring.
- The file registers only Ichigo against Kenpachi.
- Host tests: 9843 checks, ALL PASS.

## Measurements (HARD only unless marked; scratch runner = matchup-eval's `parse` and formula; paired seeds)
| Variant | 1–20 raw / HARD / kessa | 21–40 raw / HARD / kessa | 1–40 raw | 1–40 kessa | 1–40 spacing |
|---|---|---|---|---|---|
| baseline b1_a1 | 0.7892 / 37 / 31/40 | 0.8317 / 40 / 31/37 | 0.8104 | 62/77 | 35/561 |
| v2 = + no reserve, hold, no chains | 0.8071 / 38 / 33/40 | 0.8100 / 40 / 27/37 | 0.809 | 60/77 | 30/555 |
| v3 = v2 + settle 4 | 0.8032 / 37 / 34/40 | 0.8239 / 40 / 29/36 | 0.814 | 63/76 | 37/566 |
| v4 = v3 + step dodge, lead (4 8) | 0.8022 / 38 / 30/40 | | | | |
| v5 = v3 + step dodge, lead (3 6) | 0.8151 / 38 / 34/40 | 0.8246 / 39 / 32/36 | 0.8198 | 66/76 | 43/553 |
| v6 = v5 + settle 20 | 0.8209 / 38 / 36/40 | 0.8410 / 40 / 34/37 | 0.8309 | 70/77 | 42/551 |
| **v7 = v6 + k-sa min 2.0 (final)** | 0.8223 / 38 / 36/40 | 0.8465 / 40 / 35/37 | **0.8343** | **71/77** | 47/558 |
| v8 = v7 without hold and no-chains | | | 0.8252 | 67/77 | 46/566 |
| holdout seeds 41–60: baseline / v7 | 0.8371 / 39 / 33/35 → 0.8419 / 40 / 32/35 | | | | |

- The v2 bundle alone is flat: no reserve + hold + no chains were level on 1–40. Its parts pay once the step dodge covers the frames where
  no Hoho can come. Ablating hold and no-chains on the final file costs 0.009 raw and 4 kessa.
- After the change, his KESSA openers in failed matches (v5, 1–40) fell from 34k to about 13k.
- **The holdout does not confirm the kessa gain:** 32/35 against 33/35, raw +0.005. The settle (20) and the step lead (3 6) were picked on
  seeds 1–40, so read the 1–40 gain (+0.024 raw, kessa 0.805 → 0.92) as optimistic. The holdout says the change is at least not a loss:
  HARD 40/40 there.

**Final, 40 seeds a seat (EVAL_COMMAND, score.json):**
`{"side": "ichigo", "seeds": 40, "strength": 0.975, "signature": 0.7404, "excluded": [], "themes": {"spacing": {"rate": 0.084, "ok": 47, "occ": 558}, "whiff": {"rate": 0.97, "ok": 797, "occ": 822}, "ptr3": {"rate": 0.986, "ok": 209, "occ": 212}, "kessa": {"rate": 0.922, "ok": 71, "occ": 77}}, "hard": "78/80", "normal": {"share": 0.075, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.8343, "score": 0.8343}`
(Its HARD part equals the scratch runner's v7 row exactly.)

| Part (40 seeds) | Baseline | **b3_a0** |
|---|---|---|
| Score | 0.8104 | **0.8343** |
| HARD | 77/80 | 78/80 |
| Spacing | 0.062 (35/561) | 0.084 (47/558) |
| Whiff | 0.978 | 0.970 |
| Ptr3 | 0.990 | 0.986 |
| Kessa | 0.805 (62/77) | **0.922 (71/77)** |
| NORMAL | 0.075 | 0.075 (band 0–0.138, factor 1) |

## Not a repeat
- The no-reserve Hoho is b3_a1's piece, grafted onto the champion that never had it. b1_a1 named this graft itself.
- The step dodge is new. No Ichigo cell used the Step. b3_a1 / b1_a0 only moved the Hoho's budget.
- The settle after cinematics and the k-sa floor are new. Each answers a located fault, not a sweep.
- The hold differs from round 1's "KESSA hover", which hovered at a band and lost. Here KESSA keeps its play and only refuses to start into an
  attack she can already see.

## Expected benefit, risks
- **Benefit:** kessa 0.805 → about 0.9 on the tuned seeds; level to slightly up on the holdout. Strength and the other themes hold: whiff
  0.97, ptr3 0.99. Spacing is up a little (35 → 47 of about 560, from the k-lunge no longer running into his lunge after a cinematic).
- **The Step leans on an engine fact:** his TOSSHIN's 4 active frames fit in the Step's f3–f9 iframes when pressed at lead 3–6. A move with
  longer active frames, or a Kenpachi that waits out the Step's 24 f, beats it.
- **The settle reads a call gap, not the cinematic itself.** A future state that pauses the style for more than 90 f (a longer held press)
  would also trigger it. That costs at most 28 frames of no starts.
- **Late fills still fail:** a gauge filled near the 300 s time-out enters KESSA with no time to deal (2–3 of the remaining failures).
  Not addressed: the only fix would be to play the ledger itself.
- **Next:** his meaty on her wake-up while her flash-step is under 100 (no wake-up Hoho possible) opens most of what is left. A back Step on
  wake-up (the same `iks-step-dodge` idea, timed on his meaty J1) is the obvious next piece.

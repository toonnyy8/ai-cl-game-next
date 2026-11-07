# b0_a0 (round 3): the sealed brawl against her perfect Hoho. Only moves she cannot time, the meaty outside her wake-up Hoho, his own wake-up Hoho, and a follow-up through her 40 locked frames

Direction: 封印肉搏 (brawl), keeping the other three themes usable. No parent: the start is BASELINE_DIR, round 2's champion b0_a0,
re-measured against Ichigo's new champion (round 2 b1_a1) at 0.2872 (HARD 3/80). Opponent: `ichigo/champion/cpu-ki-ichigo.lisp`.
Only `duel/lisp/cpu-ki-ken.lisp` changed. Every new knob is a `defparameter` whose docstring gives its value and evidence.

## History read
- **Rounds 1–2** (all 15 cells: score.rescored.json each, summary and mechanism sections). Every big step came from a located bug or a
  missing follow-through: the plans' AS read, the Kikon rules, the FS budget, round 2's `kk-link` / `kk-as-on` / meaty 1.0. Knob drift
  gained little. Round 2 b0_a1 (0.7855) lost antiwave to 0 situations; that cliff is gone at the third freeze (an opponent-opened theme
  with no situation leaves the mean). Its `kk-hoho-wait` showed how to read her Hoho from the SNAP.
- **Baseline** (BASELINE_DIR, 40 seeds): 0.2872. Brawl 0.272, shikai 0.337, bankai 0.706, antiwave 1/2.
- **Round 3 siblings.** b1_a0 and b3_a0 were empty when I finished. b2_a0 landed (0.7122, 70/80, brawl 0.771, shikai 0.44, bankai
  0.60; antiwave excluded). It found the NS gate and a wake-up Hoho on its own. Its J1 gate in the Shikai left the Shikai doing nothing
  (shikai 0 of 11), and its dash-in lost. This file has both of those pieces too, but adds what feeds the Shikai: the perfect-Hoho
  follow-up, the meaty spacing and the dodge timing fix (below).

## Diagnosis (the baseline file, HARD, 20 seeds a seat; matchup-eval's own jobs with the logs kept; combos keyed by their opener)
- **Her perfect Hoho is the whole matchup.** 218 of her 228 Hohos were perfect. Her timed Hoho (`iks-timed-hoho`, HARD 0.9) presses
  when his move's first active frame, as she sees it, is 1–6 frames off. She sees him 8 frames late, so it catches every move with
  startup 9 or more: 146 of 180 sealed NS1a, 202 of 304 Shikai lunges, and half the Shikai J1 (S9).
  - Those openers dealt 126k of her 271k: counter 60, his lock 40, her J string, AS3, then her meaty loop.
  - His sealed J1 (S6) and KYORAN's J1–J4 (S7–8) are seen only after they hit, so she never times them.
- **Her meaty J1 loop on his wake-up** (AS3C → meaty J1 → … → AS3C, ~400 a loop) ran unanswered. Three located causes:
  1. **The dodge pressed one step late.** `kk-read` set a `:dodge` plan for "now", and `kk-wave-step` pressed the Hoho on the next free
     step. On a meaty that step comes after the hit (read and hit on the same tick, e.g. 1808).
  2. **Her KESSA J1 (S8) meaty is seen too late for the read.** Her move start is perceived only as his first free frame passes, so
     `kk-read` never fires.
  3. **After his perfect Hoho the generic CPU waited.** Her meaty J1 lands on the Hoho's own frame and cancels his counter, but she is
     still locked 40 frames. A tracker keyed on his `:hoho` state never saw it: he is in hitstun by the next step. `FIGHTER-PERFECT`
     stays set until his next move, so its rising edge is the event.
- **His meaty met her wake-up Hoho** (`iks-wake`, HARD 0.9, within 2.2 m). He waited at 1.4 m, so it was perfect every time, and her
  follow-up started her loop.
- **Stale reads.** Dodges and back Steps on a move whose hit, as he saw it, was already past (`left` −8 to −41), mostly after a Burst.

## Mechanism (every roll once per event, SIM-RND01 only, EASY ≤ NORMAL ≤ HARD; she is read only through the SNAP and the distance)
1. **`*kk-ns-safe-p*` (0 / 0 / 1.0) + `kk-ns-open-p` + `*kk-hoho-blind*` 8.** Per approach (KK-PICK's roll) and per KK-DECIDE
   decision (the climb lunge, the L3 J string, the Bankai NS): a move starts only when one of these holds:
   - its startup is ≤ 8;
   - she is seen in her own move with more frames left than its startup;
   - she is down;
   - she is in a Hoho whose lockout lasts to its first active frame.

   Else J1 where it reaches, else walk. Sealed this means J1 only. In the Shikai it means waiting.
2. **The dodge on time** (a located bug). When the read's Hoho / back Step is due now (`0 <= left <= lead`), it is pressed on this step.
3. **No stale dodge** (a located bug). No dodge when `left < 0`.
4. **`*kk-wake-hoho-p*` (0 / 0 / 1.0), `*kk-wake-hoho-near*` 2.4.** On his first free step after a wake-up, her seen within 2.4 m and
   not in a Hoho: Hoho at once. This is her own `iks-wake`, turned on her. Her meaty J1 lands, but his Hoho is perfect.
5. **`*kk-pf-p*` (0 / 0 / 1.0), `*kk-pf-window*` 40.** Keyed on the rising edge of `FIGHTER-PERFECT`. Inside her 40 locked frames:
   J1 where it reaches, else walk in. The string then runs through `kk-move` / `kk-as-on`.
   - In the Shikai this is the climb's main door. It is J1 J2 + SP: AS1, L +1.
6. **The meaty outside her wake-up Hoho.** `*kk-meaty-near*` 1.4 → 2.4, new `*kk-meaty-min*` 2.25 and `*kk-meaty-back*` 16: he backs
   off to 2.25–2.4 m while she is down. His J1 (1.8 m + a 0.6 slide; the Shikai's 2.4 + 0.8) still meets her first free frame, and her
   Hoho is never rolled.
   - Her wake-up Hohos went 263 → 3 (v4 → v5), and his meaty J1s 482 → 701.
7. **`*kk-step-in-p*` (0 / 0 / 1.0), `*kk-step-in-band*` (2.2 4.4).** Sealed, out of J1 reach: a Step toward her (no attack, so
   nothing to time), then J1 out of the Step's J cancel (`kk-step-j`, new plan `:stepin`).
   - With the NS gated (v2) he walked into her hover, and the first exchange came after ~100 s. In v3–v7 the Step-in J1 landed 146 of
     149.

## Measurements
Rows v1–v6: HARD only, 20 seeds a seat, paired, from a scratch runner that imports the frozen evaluator's `run` / `parse` and keeps the logs.
Rows "full": EVAL_COMMAND. Each row adds to the one above.

| Variant | HARD | brawl | shikai | bankai | antiwave | HARD raw / score |
|---|---|---|---|---|---|---|
| baseline (full, 20 seeds) | 3/40 | .264 (69/261) | .353 | .722 | 1/1 | 0.3809 (NORMAL 1.0) |
| v1 dodge on time | 2/40 | .254 (106/418) | .340 | .412 | 1/1 | |
| v2 + NS gate + pf follow-up | 30/40 | .786 (337/429) | .25 (16) | .33 (6) | 0/0 | ~0.57 |
| v3 + Step-in J1 | 3/40 | .661 (383/579) | .25 | .56 | 0/0 | |
| v4 + the gate on non-sealed J1 (S9) too | 5/40 | .661 | .415 | .625 | 0/0 | |
| v5 + meaty at 2.25–2.4 m | 19/40 | .833 (244/293) | .46 | .70 | 1/2 | ~0.56 |
| v6 + wake-up Hoho | 18/40 | .837 | .54 | .59 | 1/2 | |
| **v7 + pf on the PERFECT edge + no stale dodge (final, full)** | **35/40** | **.862 (250/290)** | **.70 (42/60)** | **.739 (34/46)** | 2/3 | **0.7952** (NORMAL .975) |

- **v2's 30/40 was mostly time-outs.** He rarely awakened: the awakening gauge filled from exchanges, and there were few.
- **v3's collapse was an interaction, not a flaw in the Step-in.** The sealed form became fast enough that both awakened. He then met
  KESSA in a Shikai that had no answer yet:
  - her KESSA meaty loop;
  - his lock after her perfect Hoho on the Shikai J1.

  v5–v7 gave the Shikai its doors: the meaty spacing, his wake-up Hoho and the pf follow-up.
- **v6 → v7 is the pf fix.** In v6 the follow-up fired almost never, because the tracker looked for `:hoho`. In v7 it fired 93 times
  and the wake-up Hoho 101 times.

**Final, 40 seeds a seat (EVAL_COMMAND, score.json):**
`{"side": "ken", "seeds": 40, "strength": 0.8875, "signature": 0.7236, "excluded": [], "themes": {"brawl": {"rate": 0.849, "ok": 506, "occ": 596}, "shikai": {"rate": 0.672, "ok": 80, "occ": 119}, "bankai": {"rate": 0.707, "ok": 65, "occ": 92}, "antiwave": {"rate": 0.667, "ok": 2, "occ": 3}}, "hard": "71/80", "normal": {"share": 0.9875, "band": [0.863, 1.0], "factor": 1.0, "matches": 80}, "raw": 0.7892, "score": 0.7892}`

| Part (40 seeds) | Baseline | b2_a0 (sibling) | **b0_a0** |
|---|---|---|---|
| Score | 0.2872 | 0.7122 | **0.7892** |
| HARD | 3/80 | 70/80 | **71/80** |
| Brawl | 0.272 (562) | 0.771 (777) | **0.849 (596)** |
| Shikai | 0.337 (101) | 0.44 (25) | **0.672 (119)** |
| Bankai | 0.706 (34) | 0.60 (15) | **0.707 (92)** |
| Antiwave | 1/2 | excluded (0/0) | 2/3 |
| NORMAL | 0.9375 | 0.9375 | 0.9875 |

Damage, 20 seeds a seat HARD: hers went 271k → 106k and his went 52k → 334k. Her counters went 362 → ~10.

Host tests: 9843 checks, ALL PASS.

## Why it is not a repeat
- The NS gate and the wake-up Hoho overlap with sibling b2_a0, found independently. The pieces that carry the Shikai and bankai
  themes are not in it:
  - the follow-up through her lock, keyed on the PERFECT edge;
  - the meaty outside her wake-up Hoho's 2.2 m;
  - the dodge on time;
  - the Step-in J1.
- No earlier round had an opponent that lived on perfect Hohos.

## What is left (for the next round)
- **Her KESSA NS3 lash + K-SA** (her `*iks-k-sa-reach*` 5.7). His back Step (2.5 m) lands inside the K-SA. IC-K-SA after his Step:
  89 combos (8k), plus IC-K-J1 after his Step: 27 (10k).
  - **Tried and dropped (v8):** skipping `:sdodge` on clone moves. HARD only, the same seeds: HARD 35 → 28 of 40, shikai .70 → .59,
    bankai .74 → .73. The Step costs less than being hit by the clone and the K-SA.
  - The answer is something else: a Hoho timed for the K-SA, or an AS onto the lash.
- **`kk-ns-open-p`'s Hoho branch uses `*hoho-lockout*` 60.** The engine locks her next Hoho for `*hoho-frames*` + `*hoho-lockout*`
  (84) from its start, so the gate is 24 frames conservative.
- **Losses** (9 of 80) are mostly his Shikai against her KESSA late in a match.

## Risks
- **Several knobs counter this opponent's numbers:**
  - her HARD perception delay (8, behind `*kk-hoho-blind*`);
  - her wake-up Hoho's 2.2 m (`*kk-meaty-min*`);
  - her 1–6 lead window.

  A new champion that Hohos his J1 differently, or wakes up with a Hoho from farther, reopens these.
- **NORMAL is touched** by the dodge-on-time and stale-read fixes (`*kk-dodge-p*` is 0.1 there). Every new knob is 0 at NORMAL.
  NORMAL measured 0.975 (20 seeds) and 0.9875 (40), inside [0.863, 1.0].
- **Antiwave stays at 2–3 situations in 80 matches,** so its rate is noise.

# b2_a0 (round 3, Kenpachi): no NS into her timed Hoho, a wake-up Hoho against her meaty, the clone respected, her whiffs punished

Direction hint: 卍解爆發 (bankai), keeping the other three usable. No parent: the start is BASELINE_DIR, round 2's champion b0_a0,
re-measured against her champion at 0.2872 (HARD 3/80). Opponent: Ichigo's champion, her round-2 b1_a1. Only
`duel/lisp/cpu-ki-ken.lisp` changed.

The worktree was at 7c5e696, not the freeze cee7bd6. `git diff --stat cee7bd6 HEAD` touches only `docs/`, so the evaluator and the game
code are the freeze's.

## History read
- I read every round-1 and round-2 proposal (title, mechanism, measurement) with its score.rescored.json, plus the baseline proposal.
  I read r2 b2_a0 (the Bankai's way in) whole, and her champion's proposal and style file.
- Round 1 / 2 lessons:
  - The big steps came from located causes: the AS read, the Kikon rule, the FS budget, the meaty, KK-LINK / KK-AS-ON.
  - The bankai theme's ceiling is kills before the special AS.
  - r2 b2_a0's KYORAN lunge + SA J2–J5 + SP was never merged; it was idle against her old champion.
- All of that was measured against her earlier champions. Against b1_a1 the champion wins 3 of 80. So the first job was a new
  diagnosis, not a tweak of a round-2 mechanism.
- Round 3 siblings: every directory was still empty when I finished.

## Diagnosis (baseline file against her champion, HARD, 20 seeds a seat; scratch parsers over matchup-eval's own run)
- **Her perfect Hoho is the whole matchup.**
  - 362 COUNTER hits on him. 355 came after his NS1a: 208 the Shikai lunge TOSSHIN (S16), 147 the sealed NS1a (S14).
  - Nearly all were started from neutral (KK-PICK, or the climb lunge).
  - Those counters opened 323 of her ~420 combos (J1 string > AS3 > the meaty loop).
- **The engine fact behind it.** Her timed Hoho (IKS-TIMED-HOHO, 0.9) presses when his move's first active frame, as she sees it,
  is 1–6 frames away. She sees 8 frames late.
  - So any move with startup ≥ 9 is seen in time.
  - His sealed J1 (S6) and KYORAN's J1 (S7) never are.
  - She cannot Hoho at all while she is inside a move of her own.
- **Her meaty J1 on his wake-up** loops J1 J2 NA3 NA4 J3 AS3 → knockdown → meaty again. He had no wake-up answer.
- **Shikai stays against KESSA** (after the NS gate, v4): her clone lunges (KESSA NS3a from 5.05–5.5 m) were his worst leak.
  - Past `*kk-step-max*` 5.0 no back Step was planned while his Hoho was shut, and J1 went into the clone: 29 of 31 such J1s were hit.
  - Her SA after a clone lunge, whiffing past his Step, was never punished.

## Mechanism (cpu-ki-ken.lisp only; every knob a `defparameter` with a docstring; rolls once per event; SIM-RND01 only)
1. **`*kk-wary-p*` (0 / 0 / 1.0) + `kk-hoho-shut-p`.** Per approach (KK-PICK), per climb lunge, per Bankai NS roll: no NS from
   neutral while her Hoho is seen open. "Shut" means a Hoho of hers seen (SNAP state `:hoho` and its frame) whose lock (24 + 60 f)
   still runs at the NS's first active frame + `*kk-wary-margin*` 2. J1 still starts where it reaches.
2. **`kk-wake` (`*kk-wake-p*` 0 / 0 / 1.0, `*kk-wake-near*` 2.6).** On his first free step after a wake-up, her near: Hoho at once,
   one roll per wake-up. Her meaty J1 is active on that frame, so the Hoho is perfect: her string stops at the J1 and she is locked
   40 f. This is her own round-2 wake-up Hoho turned around.
3. **The released forms' J1 race** (`*kk-race-p*` 0 / 0 / 1.0, in KK-READ). On her NA / NS start, where his J1 lands first: J1.
   KK-MOVE's AS read then turns it into the AS (the Shikai's AS1 raises L). Before this the read only dodged in those forms.
4. **The clone respected** (`*kk-clone-hold*`, `*kk-clone-step*`, HARD only). No KK-PICK start while she is seen in a clone segment
   before its strike. The back Step answers clone segments out to `*kk-clone-reach*` 7.0, no longer only within 5.0.
5. **`kk-punish` (`*kk-punish-p*` 0 / 0 / 1.0).** Her move seen recovering from a whiff, with more frames left than his move needs:
   J1 where it reaches, else the pointer's NS (the sealed NS1a, the Shikai's 5.6 m lunge, KYORAN's 4.8 m lunge). One roll per her
   move. This is the one place his NS is always safe (no Hoho out of her own recovery), so it reopens the lunges that item 1 shuts.
   It is the main Shikai / Bankai gain.

**Tried and dropped (HARD-only runs, 20 seeds a seat):**
- **Gating the J1 too** (the Shikai's S9 J1 is seen on its first perceived frame). The Shikai started nothing: shikai 0 of 11 stays,
  he dealt 475 in the Shikai and took 36k. Reverted: the Shikai J1 drew only 5 counters in v1.
- **A dash-in** against her hover, to break the time-out stalemate (`ai-dash` to 1.6 m, then J1): KI 0 of 20, IK 1 of 20.
  `ai-dash` opens with a 24-frame Step she reads (her sealed NS3a lunge opened 84 combos). Removed.

## Measurements
Full formula (`tools/matchup-eval.py --side ken --seeds 20`, paired seeds):

| File | score | HARD | brawl | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|
| baseline (b0_a0 r2) | 0.3809 | 3/40 | .264 (69/261) | .353 (18/51) | .722 (13/18) | 1/1 | 1.0 |
| v5 = items 1–4 | 0.6230 | 34/40 | .765 (309/404) | .25 (3/12) | .40 (2/5) | excl. | .975 |
| **v6 = v5 + item 5** | **0.7417** | 36/40 | .775 (303/391) | .533 (8/15) | .60 (6/10) | excl. | .975 |

HARD-only steps (scratch runner, same seeds; no NORMAL):

| Step | HARD | brawl | shikai | bankai |
|---|---|---|---|---|
| v1 = item 1 (NS only) | 31/40 | 299/376 | 1/12 | 1/3 |
| v2 = v1 + wake + race + J1 gating | 35/40 | 310/399 | 0/11 | 0/0 |
| v3 = v2 − J1 gating + dash-in | 1/40 | 284/503 | 6/42 | 3/8 |
| v4 = v1 + wake + race | 32/40 | 310/399 | 3/13 | 2/3 |

Ledger, baseline vs v6 (damage by his form, both seats):
- **Sealed against her sealed form:** she dealt 93k → 7.4k, he dealt 19.6k → 100k.
- **His Shikai against her KESSA:** she dealt 60k → 31k, he dealt 10.6k → 12.5k.
- **Counters on him:** 362 → 1.

**Final, 40 seeds a seat (score.json, the EVAL_COMMAND's own line):** score **0.7122** against the baseline's 0.2872.
- HARD 70/80.
- Signature 0.6036: brawl .771 (599/777), shikai .44 (11/25), bankai .60 (9/15). Antiwave never came up and is excluded.
- NORMAL 0.9375 (band 0.863–1.0, factor 1).

The 40-seed number sits under the 20-seed 0.7417 because shikai fell from .53 to .44 on the extra seeds (situations are few, below). The final file is v6 with `*kk-clone-hold*` /
`*kk-clone-step*` turned into difficulty plists (HARD t, else nil). HARD play is unchanged; only NORMAL can move.

## What it means for 卍解爆發 (bankai)
- **The rate fell from .722 (13/18) to .60 (6/10) at 20 seeds, on fewer situations.**
  - The baseline's L3s came from Shikai stays it mostly lost.
  - Here L3 → J1–J7 + SP → KYORAN → J1–J5 + CHIGIRI home works (6 of 10). Each L3's J1–J7 also lands J4–J6, which is why shikai
    rose to .53.
- **The failures, by class:**
  - an L3 reached in a second cycle and still open when the match ends (time-out, or a K.O. in the Shikai before the entry: the
    known ceiling);
  - one K.O. inside a Bankai before the special AS.
- Bankai stays still run long now and then: 3 s to 62 s at 20 seeds. She hovers at 4.9–5.3 m against KYORAN, past its J1, and
  KK-PUNISH is the main way in.

## Why the situations are few (for the coordinator)
- Most HARD wins are sealed 300 s time-outs. In v6's KI seat 17 of 20 matches went to 300 s, 15 of them with neither side awakened.
- Her patient sealed form never starts first. With the NS shut, he starts only J1 within 1.9 m, so the walk-in and her back-off
  circle the arena.
- His awakening gauge fills only from damage (0.035 a point dealt), so it stays short. That is why the Shikai stays fell from 51 to
  15 and the L3s from 18 to 10.
- Breaking the stalemate needs a safe committal approach. The dash-in was not one (v3). The next cell's best lever is probably
  there, or in waking her Hoho on purpose: her wake-up Hoho at 0.9, which shuts her Hoho for 84 f (KK-HOHO-SHUT-P).

## Not a repeat
- No earlier cell played her timed perfect Hoho; round 2's champion lost 77 of 80 to it.
- The NS gate keyed to her seen Hoho lock, the wake-up Hoho, the clone hold and the whiff punish are all new for Kenpachi. Each
  rests on a located cause counted in the logs.
- No round-1 / round-2 knob was retuned.

## Rules
- Every new chance is EASY ≤ NORMAL ≤ HARD (NORMAL 0 / nil) and rolled once per event: an approach, a lunge or NS roll, a wake-up,
  her move start, her move's recovery.
- She is read only through the perceived SNAP (state, frame, move, contact, frames left) and the perceived distance.
- No new randomness source. The file registers only Kenpachi against Ichigo.
- Host tests: 9843 checks, ALL PASS.

## Risks
- **An Ichigo who stops Hoho-ing his NS, or Hohos his J1 / lunge only when he is in reach,** reopens the NS game, and this file then
  under-uses it. The gate is per approach and lifts the moment her Hoho is seen locked.
- **Strength rests on time-outs:** sealed leads held to 300 s. A rule change on time-outs would move it.
- **Small samples:** shikai (15) and bankai (10) situations at 20 seeds move ±0.1 per two outcomes.

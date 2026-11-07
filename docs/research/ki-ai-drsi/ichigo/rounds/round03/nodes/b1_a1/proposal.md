# b1_a1 (round 3, Ichigo): b1_a0 + b2_a0's bait hover and k-SA fix, the hold off; her whiffed k-lunge covered by her own Hoho

Direction: 揮空反擊 (whiff), keeping the other three usable. Parent: b1_a0 (the hold after 90 f, 0.8407). Opponent:
`ken/champion/cpu-ki-ken.lisp`. Only `duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
I read every round-1 / round-2 / round-3 score.rescored.json. I read the baseline's, b1_a0's (the parent), b0_a0's and b2_a0's
round-3 proposals whole, and the rest by their summary and measurement sections. b0_a1 and b2_a1 were still empty when I finished.

- **The whiff theme is saturated.** It was 0.974–0.983 in every round-3 cell, so a perfect whiff adds about +0.004.
  - Its oks come almost all from the timed perfect Hoho and its follow-up. In the parent's HARD logs (20 seeds a seat) that was 343
    Hohos and 345 follow-ups, against 9 confirm-SPs and 5 start-time punishes.
  - So the hint can only pay through the other themes. Spacing (0.07–0.09) is the only theme with room. Strength (79–80/80) and kessa
    (0.91–0.96) are near full.
- **b1_a0 (the hold) and b2_a0 (the bait hover) break the same sealed stand-off** in two different ways. Each scored about 0.84–0.85,
  within noise of the other.
- **b2_a0 located a bug, which my logs reproduce.** After his dodge of the KESSA k-lunge, the SA was still pressed: from 1.6 m with
  him behind her after a Hoho, or from 5.4–5.8 m after a Step.
- **b0_a0's spacing gain (0.25) rests on reading his flash-step gauge** (a HUD read awaiting the coordinator's ruling). I did not build
  on it.
- **Widening the k-lunge to more modes has lost every time** (round 2 b3_a0, round 3 b2_a0 K1 / K2). I re-measured it for `:whiff`
  (below), and it loses the same way.

## Diagnosis (parent, HARD, 20 seeds a seat; a logging copy of situ.lisp, scratch only)
Spacing situations by cell (occ / ok):

| Cell | occ | ok |
|---|---|---|
| match start, 8 m, pointer 1 (no tool reaches) | 40 | 0 |
| KESSA ptr 3 vs his Shikai, `:space` (the k-lunge) | 30 | 11 |
| KESSA ptr 3 vs Shikai, `:whiff` / `:ptr3` | 32 | 6 |
| sealed ptr 3 vs Shikai | 37 | 1 |
| far resets, ptr 3 vs sealed (he awakens) | 32 | 0 |
| far, ptr 2 vs Shikai (`*iks-p2-wait*`) | 27 | 0 |

- Against his Shikai, the pattern is the same each time:
  1. she hovers at 4.9–5.3;
  2. he starts KE-S-N1A at a perceived 4.1–4.5 (S16, slide 3.0);
  3. her perfect Hoho, the counter, and the J string.

  That is a whiff ok, but it can never be a spacing ok. His NS1a is seen 8 f late with 8 f to go, so no lunge can beat it. Stepping
  out instead leaves him at about 3.5–3.8 m when it ends, and a punish from there starts under 4 m.
- **An evaluator detail for the coordinator** (frozen, so I did not use it):
  - a perfect Hoho's automatic COUNTER is not a classed move, so the observer credits it with the start distance of her last classed
    move;
  - after a k-lunge from 4.1 m, a later perfect-Hoho counter scores spacing ok;
  - this accounts for 6 of the parent's 25 spacing oks, 7 of 18 with the bait hover, and 24 of 53 with the k-lunge in `:whiff` mode.
- **In KESSA, the biggest openers of his combos come after her k-lunge is dodged**, at the k-SA stop: KE-S-N1A and his Shikai / KYORAN
  J1. He reappears 1.6 m behind her, and 26–37 f later his J1 lands before the delayed SNAP lets her timed Hoho see it.

## The change (the final file)
1. **b2_a0's pieces, ported unchanged**: `*iks-bait-hover*` / `*iks-bait-modes*` / `iks-hover-band` (the `:whiff` / `:ptr3` / `:kessa`
   episodes hover at 2.3–2.7 m against his sealed form), `*iks-k-sa-dodge-stop*` and `*iks-k-sa-perceived*` (no k-SA into his seen
   dodge; the SA's reach test uses the perceived distance; `iks-move` takes `d`).
2. **b1_a0's hold is off at HARD** (`*iks-hold-after*` HARD 90 → NIL; the code stays). With the bait hover, the hold kept her standing
   inside his J1 once an episode passed 90 f. A floor for the hold at 2.8 m recovered most of that, but it still lost out of sample to
   no hold (table).
3. **New: the dodge cover** (`*iks-dodge-hoho-p*` 0 / 0 / 0.9, `*iks-dodge-hoho-near*` 2.6, `iks-dodge-hoho`, slot `dodged`).
   - When the k-SA stop sees his Hoho, she presses her own Hoho on her first free frame, if he is within 2.6 m. One roll per dodge.
   - Her Hoho puts her behind him, and `ikst-hoho-t` arms the existing follow-up: J1 on his seen recovery, or the confirm on his
     whiffed move.
   - This is 揮空反擊 for her own whiff: the dodged lunge is the moment he punishes, and the Hoho turns it back on him. It is the
     pattern of `iks-wake`, the wake-up Hoho.
   - In the logs (seeds 1–20, `:space` k-lunge only) it fired 22 times. Most went on to the follow-up's J string or a confirm.

Rules:
- The bait hover and the cover are HARD only.
- The k-SA stop / perceived reach are rules in every mode, as in b2_a0. NORMAL measured in the final run (below).
- His state is read only through the SNAP (`:hoho`) and the perceived distance.
- Randomness only through `brain-roll`, one roll per event.
- Every knob is a `defparameter` with a docstring.
- Host tests: 9843 checks, ALL PASS.

## Measurements
HARD raw = 0.4 strength + 0.6 signature, through a logging copy of matchup-eval's HARD jobs. It reproduced the full eval exactly on the
parent (0.8416). Variants were set by runtime knob overrides on one build. All rows are paired.

| Variant | seeds 1–20 raw | HARD | spacing | whiff | ptr3 | kessa | seeds 21–40 raw |
|---|---|---|---|---|---|---|---|
| parent b1_a0 (full eval) | 0.8416 | 39 | 0.087 | 0.974 | 1.0 | 0.95 | — |
| + bait + k-SA fix, hold 90 | 0.8106 | 38 | 0.068 | 0.987 | 0.99 | 0.825 | — |
| same, hold from 2.8 m only | 0.8494 | 40 | 0.086 | 0.986 | 1.0 | 0.925 | 0.8300 (39) |
| same, no hold (= b2_a0's H5 again) | 0.8507 | 40 | 0.069 | 0.986 | 1.0 | 0.95 | 0.8527 (40) |
| k-SA fix, hold 90, no bait | 0.8390 | 39 | 0.094 | 0.975 | 1.0 | 0.925 | — |
| hold 2.8 + k-lunge in `:whiff` mode | 0.8349 | 39 | 0.158 | 0.983 | 1.0 | 0.825 | — |
| **no hold + dodge cover (final)** | **0.8547** | 40 | 0.076 | 0.98 | 1.0 | 0.975 | 0.8397 (39) |
| no hold + cover + k-lunge `:whiff` | 0.8393 | 40 | 0.136 | 0.968 | 1.0 | 0.825 | — |
| no hold + cover after any dodged move | 0.8473 | 40 | 0.099 | 0.983 | 1.0 | 0.90 | — |

**Honest reading**
- Over 40 seeds a seat (HARD only), the final averages 0.8472, against 0.8517 for no hold without the cover. That is level within noise:
  the 21–40 gap is one lost match.
- The cover is not proven to help. What it shows: it fires where the k-lunge loses its ledger, keeps whiff at 0.98, and costs nothing
  measurable.
- The k-lunge in `:whiff` mode doubles spacing (real lunge hits 11 → 29), but costs 4–6 kessa matches, with or without the cover. That
  is a third confirmation of the widening's loss.

**Final, 40 seeds a seat (EVAL_COMMAND, score.json):**
`{"side": "ichigo", "seeds": 40, "strength": 0.9875, "signature": 0.7537, "excluded": [], "themes": {"spacing": {"rate": 0.075, "ok": 39, "occ": 519}, "whiff": {"rate": 0.982, "ok": 704, "occ": 717}, "ptr3": {"rate": 0.995, "ok": 204, "occ": 205}, "kessa": {"rate": 0.963, "ok": 77, "occ": 80}}, "hard": "79/80", "normal": {"share": 0.075, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.8472, "score": 0.8472}`

| Part (40 seeds) | Parent b1_a0 (rescored) | b2_a0 (rescored) | **b1_a1** |
|---|---|---|---|
| Score | 0.8407 | 0.8517 | **0.8472** |
| HARD | 79/80 | 80/80 | 79/80 |
| Spacing | 0.078 | 0.071 | 0.075 (39/519) |
| Whiff | 0.981 | 0.983 | 0.982 |
| Ptr3 | 1.0 | 0.995 | 0.995 |
| Kessa | 0.912 | 0.963 | 0.963 |
| NORMAL | 0.075 (factor 1) | 0.075 | 0.075 (factor 1) |

## Expected benefit, risks
- **Benefit.** The parent's lineage now carries the stronger stand-off answer (the bait hover) and the k-SA bug fix. The hold, which
  hurt in that company, is off. Spacing is unchanged; the other three stay at 0.98 / 1.0 / 0.95–0.975.
- **Risk.**
  - The bait hover relies on his reach discipline (b2_a0's risk).
  - The cover spends 100 flash-step on a dodge he may not follow up. If he waits instead, her Hoho is wasted, and the 60 f lockout is
    open to his next move.
- **For the coordinator.**
  - Spacing's remaining pools are structural without b0_a0's gauge read (table above).
  - The perfect-Hoho counter inheriting the start distance of her last classed move is an evaluator artefact worth noting at the next
    freeze.
  - This file and b2_a0 are level. Pick on the re-measure.

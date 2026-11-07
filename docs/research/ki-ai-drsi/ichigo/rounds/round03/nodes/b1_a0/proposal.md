# b1_a0 (round 3, Ichigo): the patient sealed form holds ground and breaks the 3 m standoff

Direction: 揮空反擊 (whiff), keeping the other three usable. Parent: none, so this starts from BASELINE_DIR (round 2's b1_a1, re-measured
against Kenpachi's round-2 champion b0_a0: 0.8104, HARD 77/80). Opponent: `ken/champion/cpu-ki-ken.lisp`. Only
`duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
Read: the baseline's proposal, plus the summary, mechanism and measurement sections and the score.rescored.json of every round-1 and
round-2 cell. b0_a1 (r2, the meaty) and b0_a0 (r2, the far k-lunge) I read in full, because the spacing angle runs through them. The
round-3 sibling folders were empty both when I started and when I re-listed them before writing.

| Cell | Mechanism | Rescored | Bearing here |
|---|---|---|---|
| r1 b1_a1 | whiff confirm + finisher; **hold ground while his whiffing move is live** (`*iks-hold-p*`, one roll per his move) | 0.775 (first freeze) | not in the baseline. Different trigger, below |
| r2 b0_a0 / b0_a1 | far k-lunge 5.05–5.5 (KESSA, `:space`); meaty NS3a / J1 | 0.415 / 0.793 | far band in the baseline. The meaty's NS3a hit can't score spacing: the situation can't open while he is down |
| r2 b1_a1 (baseline) | patient sealed form, timed Hoho kit, pointer-2 wait, meaty J1 | 0.8104 now | starting file |
| r2 b3_a0 | k-lunge in all KESSA modes 0.5632 against `:space` only 0.7271 | 0.7151 | re-confirmed here (v-kall) |

The baseline whiff rate is already 0.978, so pushing the whiff tools further is worth +0.003 at most. Spacing is at 0.06. Every earlier
spacing push (sealed lunge, walk-in, far band in more modes, meaty NS3a) lost strength or whiff to his dodge (a Hoho at 100 flash-step,
the back Step within 5.0 m). No cell had looked at the stretches where nobody moves.

## Diagnosis (baseline, HARD, 20 seeds a seat)
Tools in scratchpad `ki-ichigo-b1_a0/r3/`:
- `ev.py` runs matchup-eval's HARD jobs through a logging copy of situ.lisp and reproduces matchup-eval's HARD numbers exactly (37/40,
  spacing 11/271);
- `eps.py` prints each spacing episode;
- `gaps.py` finds stretches with no combat-log event;
- `match.py` gives a per-match ledger.

1. **Four of the 40 matches went to time-out at 300 s, and three of those were her losses** (31: seed 12; 13: seeds 1 and 10). They
   are all of her HARD losses.
2. **The standoff.** Gaps of 15 s or more with no move by either side add up to **176k ticks, 73 s a match**. Every one of them is
   sealed against sealed, both "idle", and 3.0–3.2 m apart (hash lines). A per-30-tick trace of one stall (seed 12) shows the distance
   oscillating 3.06–3.25 m for 1700 frames while his flash-step refills.
3. **Why the standoff happens.**
   - Her patient hover (pointer 1: 3.4–3.8, pointer 3: 3.7–4.2) walks back whenever he is inside the band.
   - His reach discipline (`kk-pick`, `*kk-reach-p*` 1.0) subtracts her perceived speed away from his reach, over his delay plus the
     move's startup. For the sealed NS1a that is 0.07 m/f × 22 f ≈ 1.5 m, which leaves a 2.6 m start distance at about 1.1 m.
   - So while she backs off he never starts anything, and she never sees a move to Hoho or punish. Both walk in step until something
     random breaks it.
4. **Spacing.** The theme's oks are almost all KESSA pointer 3 against his Shikai (the far k-lunge). Against the Shikai, the 4–5 m
   episodes close on his TOSSHIN lunge, which she perfect-Hohos. The counter is no move start, so those are whiff oks and spacing fails.

## The change (one mechanism; the final file)
`iks-hold-p` (new), with `*iks-hold-after*` 0 / 0 / HARD 90 frames, `*iks-hold-max*` 4.5 m and `*iks-hold-his-forms*` (:base).
- **When:** a patient episode (sealed form, HARD) has hovered longer than 90 frames, he is calm (idle / run) and in his sealed form,
  within 4.5 m.
- **What:** she holds ground (stick 0) instead of walking back to the hover band.
- **Effect:** his discipline then starts the NS1a / J1 where it reaches. Her existing tools answer it: the timed perfect Hoho
  (`*iks-hoho-p*`), the whiff confirm, and the follow-up. This is 揮空反擊 drawn out rather than waited for.
- **Not used against his Shikai:** the 4.9–5.3 hover there already draws his lunge.

It sits in `iks-neutral` just before the hover branch, so the timed Hoho, the punish and the confirm still take precedence. It logs
`ki-style <mode> hold` once an episode: 142 holds in the 40 HARD matches, spread over all four modes, pointer 1 and 3.

Rules:
- It is not a chance (a deterministic rule on her own episode clock), and it is NIL below HARD, so NORMAL stays the shipped CPU.
- It reads only the perceived distance, his SNAP state and his visible form (the existing exception).
- Nothing outside this file changed. Every knob is a `defparameter` with a docstring.

**Not a repeat.** Round 1's b1_a1 `*iks-hold-p*` stood still only while his already-started move would whiff, one roll per his move,
against Kenpachi v0. That fixed her walking out of her punisher's reach. The trigger here is the absence of any move: an episode clock
in the patient form, against a located opponent behaviour (`kk-pick`'s reach shrink, round 2's Kenpachi b0_a0) that v0 did not have.
Nothing in the baseline holds ground.

## Measurements
Paired seeds 1–20 a seat. HARD via `ev.py`, which reproduced matchup-eval's HARD part exactly on the baseline.
raw = 0.4 strength + 0.6 signature (NORMAL is unaffected: every change is HARD-only).

| Variant | HARD | raw | spacing | whiff | ptr3 | kessa | gaps ≥ 15 s | time-outs |
|---|---|---|---|---|---|---|---|---|
| baseline (matchup-eval, 20) | 37/40 | 0.7892 | 0.041 (11/271) | 0.979 | 1.0 | 0.775 | 176k ticks | 4 (3 lost) |
| hold after 0 f | 40/40 | 0.8306 | 0.090 (27/300) | 0.981 | 1.0 | 0.80 | 2.4k | 0 |
| **hold after 90 f (final)** | 39/40 | **0.8416** | 0.087 (25/289) | 0.974 | 1.0 | **0.95** | 0 | 0 |
| hold after 180 f | 38/40 | 0.8171 | 0.092 (27/293) | 0.972 | 1.0 | 0.85 | 0 | 0 |
| 90 f + k-lunge in all four KESSA modes | 33/40 | 0.7477 | 0.114 (50/440) | 0.971 | 1.0 | 0.70 | 0 | 7 losses |

- The three hold values are within the ±0.02–0.03 draw noise of one another, and all are well above the baseline. I chose 90: a short
  hover first keeps the patient form's walk-back for his walk-ins, and it had the best kessa.
- The k-lunge row re-confirms round-2 b3_a0's negative result (`*iks-kessa-space-modes*` docstring). It stays `:space` only.
- 40 seeds a seat, matchup-eval (seeds 21–40 are new to the choice): the hold at 90 scored **0.8407** (HARD 79/80) against the
  baseline's 0.8104 (77/80). After that run only docstrings changed, and the final file reproduced the same line exactly.

**Final, 40 seeds a seat (EVAL_COMMAND, score.json):**
`{"side": "ichigo", "seeds": 40, "strength": 0.9875, "signature": 0.7428, "excluded": [], "themes": {"spacing": {"rate": 0.078, "ok": 45, "occ": 576}, "whiff": {"rate": 0.981, "ok": 663, "occ": 676}, "ptr3": {"rate": 1.0, "ok": 209, "occ": 209}, "kessa": {"rate": 0.912, "ok": 73, "occ": 80}}, "hard": "79/80", "normal": {"share": 0.075, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.8407, "score": 0.8407}`

| Part (40 seeds) | Baseline (b1_a1 vs Kenpachi b0_a0) | **b1_a0** |
|---|---|---|
| Score | 0.8104 | **0.8407** |
| HARD | 77/80 | **79/80** |
| Spacing | 0.062 (35/561) | 0.078 (45/576) |
| Whiff | 0.978 (769/786) | 0.981 (663/676) |
| Ptr3 | 0.99 (202/204) | 1.0 (209/209) |
| Kessa | 0.805 (62/77) | **0.912 (73/80)** |
| NORMAL | 0.075 (band 0–0.138, factor 1) | 0.075 (factor 1) |

Host tests: 9843 checks, ALL PASS.

## Expected benefit, risks
- **Benefit:**
  - the time-out losses go away (0 time-outs in 40 matches, from 4);
  - kessa rises: her KESSA ledger no longer bleeds through long sealed stretches, and the matches end;
  - spacing roughly doubles as a side effect (more KESSA pointer-3 time, fewer dead 4–5 m episodes from the hover's oscillation);
  - whiff holds at 0.97–0.98 with more of his moves drawn out.
- **Risk: it depends on his reach discipline.** A Kenpachi that waits out the hold, or reads her stillness as a cue for something
  her timed Hoho can't meet (a delayed start, a Hoho-in, a feint), reopens the standoff or punishes it. The hold only cancels her
  walk-back. She still Hohos and confirms as before, and it ends with the episode.
- **Spacing is still the weakest theme** (about 0.08). What's left is structural:
  - his perfect-Hohoed Shikai lunge scores whiff, not spacing;
  - the resets to 8 m at pointer 1 / 3 have no move that reaches from there;
  - the far k-lunge only works while his Hoho is spent.
  A spacing cell might try a pointer-2 Getsuga right after a reset against his sealed form, where his anti-wave Hoho budget is the
  open question.

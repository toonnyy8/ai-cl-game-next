# b1_a0 (round 1): the Shikai climb carried through, with four located bugs fixed

Direction: 解放攀升, the Shikai climb, with the other three themes kept usable. Parent: the baseline (v0, 0.3505). Opponent: Ichigo's
champion (v0).

## History read
- Round 1 has no history. When this cell ran, every sibling node directory (b0_a0, b2_a0, b3_a0) was still empty.
- Baseline v0 (proposal.md, score.json 0.3505):
  - str 0.125 (HARD 10/80), sig 0.501 (brawl 0.57, shikai 0.77, bankai 0.31, antiwave 0.36), NORMAL 0.96.
  - Its own known weak spots: Bankai stays that never leave, and the timed cut / late Hoho that rarely fire.

## Diagnosis
Method: combat logs of 10 HARD matches per seat, from `run-situ.lisp` with the evaluator's own commands.

1. **Her sealed loop and the late awakening.**
   - While Kenpachi is sealed, Ichigo's v0 runs NS3a from 4.0–4.1 m into a full AS3 string about every 290 frames.
   - In 8 of 10 matches she then takes a pointer-3 Soul Break (−5 Konpaku) before he awakens.
   - The awakening gauge fills only around 40 s. Even then, the old `*kk-awaken-p*` (0.1 per neutral decision, behind the plans)
     left him sealed until 44–150 s.
2. **Kikons that cost him.** The generic `cai-sp` holds a Kikon 35 % of the time, and 60 % against red, at any pointer.
   - Pointer 1 / 3 Kikons take 1 Konpaku and refill her Reishi, where a Soul Break would take 3–5.
   - Non-red Kikons are cancelled.
   - In the diagnostic logs (10 matches a seat), 27 of 33 landed Kikons took −1 ("KE-S-N1A -> KIKON", "KE-Z-AS1 -> KIKON" on red). The
     other 6 took −2 or −3.
3. **The planned strings never turned (the largest fix).**
   - `kk-move` pressed J after J up to the plan's target, even when the link was CANCELLED by her NS. A cancel counts as contact.
   - So J2 went into her KESSA chains and was absorbed or cancelled, and she punished.
   - The generic CPU turns to the AS on `(eq oc :ns)` every time. The plans had dropped that.
   - Example: g1 seed 2, L3 J1 x CANCEL, then J2 ABSORBED, 3700 frames from L3 to the Bankai.
4. **The Bankai stall.**
   - In the Bankai, a decision between J reach (2.2 m) and 3.6 m held the stick in for one step only. On the other steps the generic walk
     aimed at 1.7–3.0 m.
   - She kept 3.1–3.3 m, so nobody attacked from t≈8000 to the 300 s time-out (e1 seed 4, a loss on time).
5. **Stays killed by an NS at L3.** The Shikai stay often reaches L3 inside the NS combo that kills her. That stay never lands J4–J7,
   and the Bankai situation stays open, so both themes fail.

## The changes (`duel/lisp/cpu-ki-ken.lisp` only; every knob a `defparameter` with its docstring)
- `*kk-awaken-p*`: now one roll per match, made the first free step the gauge is seen full. A yes awakens on that step, or on the next
  free step if it can't yet. HARD 0.1 per decision → 1.0 per match; NORMAL 0.
- `*kk-kikon-guard-p*` (new; EASY 0 / NORMAL 0.5 / HARD 1.0, one roll per own move and per neutral SP):
  - The hold is kept only when she is red and the SP's pointer is 2, sealed or in the Shikai. That Kikon takes 3 against red and can't
    be cancelled.
  - `kk-kikon-ptr` finds the SP's pointer: the AS the SP starts (`core-next-as`), or, for the Shikai's J4–J6, the current pointer of the
    special AS.
  - The Bankai never holds: its Kikon takes 3, its Soul Break 5.
  - The same roll lets the style take the generic CPU's in-range neutral attack (`kk-generic-attack`: the same NS / J odds, gated
    hold). Her red bar is read directly, as `cai-sp` and her own style do: a visible fact (DUEL_MATCHUP_AI §7).
- `*kk-turn-p*` (new; 1.0 at every difficulty, the generic CPU's rule):
  - In a planned string (the climb, L3's J4–J7, the Bankai's), a link that lands or is cancelled while she is perceived in an NS turns to
    the SP at once. One roll per link (`brain-r-turn`).
  - In the Bankai, every SP before J5 counts as a cash-out.
- `*kk-l3-sa-p*` (new; 0 / 0.1 / 1.0) and `*kk-l3-sa-range*` 2.6:
  - At L3 with a plan, in a Shikai NS segment's gap within 2.6 m: the SA, one roll per segment (its own key, so a failed roll leaves the
    segment to the generic CPU).
  - The plan's string then runs SA J2 … J4 + SP (the special AS) or … J7 + SP (the Bankai).
- `*kk-bk-walk-range*` 3.6 → 6.0, now a dash in to the new `*kk-bk-dash-to*` 1.8 m (`ai-dash`). The next decision starts J1.
- `*kk-climb-p*` HARD 0.8 → 1.0.
- `*kk-bankai-p*` HARD 0.6 → 1.0: an L3 rise without the Bankai is a 卍解爆發 failure, and the J1–J7 entry lands J4–J6 on the way.
- `*kk-bankai-max*` (new; 9 = no cap).

## Measurements (20 seeds a seat, paired seeds, against the opponent file; score / HARD / brawl shikai bankai antiwave)

| Variant | Score | HARD | brawl | shikai | bankai | antiwave |
|---|---|---|---|---|---|---|
| v0 baseline | 0.369 | 6/40 | .557 | .714 | .316 | .474 |
| v1 awaken once + Kikon gate (current pointer) + climb 1.0 | 0.447 | 15/40 | .587 | .821 | .296 | .273 |
| v2 + style takes the generic in-range attack (gated) | 0.468 | 18/40 | .576 | .846 | .245 | .25 |
| v3 + gate by the SP's pointer + bankai 1.0 | 0.368 | 7/40 | .557 | .718 | .492 | .222 |
| v4 + the Bankai dash (stall fixed) | 0.411 | 8/40 | .557 | .681 | .72 | .25 |
| v5 + one Bankai a match | 0.427 | 11/40 | .557 | .781 | .524 | .25 |
| v6 bankai 0.6, no cap (v2 + pointer gate + dash) | 0.511 | 16/40 | .557 | .79 | .393 | .6 |
| v7 + `*kk-turn-p*` | 0.651 | 25/40 | .557 | .865 | .50 | .75 |
| v8 + bankai 1.0 | 0.678 | 30/40 | .557 | .814 | .646 | .5 |
| **v10 + the L3 SA (final)** | 0.652 | 27/40 | .557 | .872 | .716 | .4 |

v8 against v10 at 40 seeds a seat (the same seeds):

| Variant | Score | HARD | Signature | brawl | shikai | bankai | antiwave |
|---|---|---|---|---|---|---|---|
| v8 | 0.6167 | 55/80 | 0.570 | .561 | .796 | .649 | .273 |
| **v10** | **0.6558** | **55/80** | **0.635** | .561 | .853 | .708 | .417 |

- The pick is v10. Strength is equal, and shikai and bankai are both up.
- NORMAL share is 0.9375 (band 0.863–1.0, factor 1). The baseline's was 0.9625.
- Brawl stays where it was: the sealed play is untouched, apart from the in-range attack's gated hold.
- The final file (docstrings only changed from the measured v10) re-run at 40 seeds gave the identical JSON, in score.json.

## Why it is not a repeat
Round 1 has no earlier attempts. Against v0, this cell's mechanisms are new:
- the awakening as one event per match;
- the Kikon pointer policy;
- the plans' turn on her NS (a located bug: the plans dropped the generic CPU's read);
- the Bankai approach (a located stall bug);
- the L3 SA that hands NS combos to the plan's J string.

## Expected benefit
- The style now finishes what v0 started. He awakens as soon as he can and climbs on every stay. Every L3 becomes J1–J7 → Bankai →
  cash-out → special AS home, and every planned string reads her NS.
- Against v0 Ichigo: 0.351 → about 0.65.

## Risks
- **Antiwave.** It rests on 11–12 situations a run, so each one is about ±0.013 of score. The awakening-first rule makes her Getsuga
  route rarer while he is sealed.
- **The sealed loop is still there.** Her NS3a lunge loop and the −5 pointer-3 Soul Break in the first ~40 s are untouched. That is the
  brawl's problem, and a natural next target: answer NS3a from 4 m with the pointer-3 tame, or keep out of 4–5 m.
- **Bankai at 1.0.** Each way back costs a Konpaku. With fewer turns in the strings (a stronger NS game from her), the cap
  `*kk-bankai-max*` may need to come back to 1 (v5's lesson).
- **The Kikon gate reads her red bar directly.** There is precedent (`cai-sp`, Ichigo's `iks-sp-frames`). The coordinator may want it
  noted for the user.

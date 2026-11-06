# Cell b2_a0 (round 1, Kenpachi): the Bankai cash-out as a cycle

Direction hint: 卍解爆發. Parent: the baseline (v0, 0.3505 at 40 seeds against Ichigo's champion v0). No sibling or past proposal
existed when this cell read the nodes (round 1, every sibling directory empty), so the history is the baseline alone.

## What was wrong (the baseline's logs, HARD, 20 seeds a seat, both seats)
- 57 L3 situations, 18 ok. Where they failed:
  - 28 of 57 L3 rises had no Bankai plan: `*kk-bankai-p*` 0.6 refused, the climb went to the special AS (L kept), and the situation stayed
    open until the match ended.
  - 7 of 23 Bankai stays ended with the match still inside the Bankai (the cash-out first, then the exit).
  - Many plans took 1000–3000 frames to reach J7. At L3 and beyond 2.8 m the generic CPU took the decision, and from 3–5 m it started NS
    segments that missed. Ichigo's whiff punish (and her KESSA) fed on those.
- **A located bug in the style's own string steering (`kk-move`)**: it pressed the next J whatever she did. The generic `cai-move-step`
  takes the SP when it sees her NS (an AS beats an NS). Without that read, 105 of 117 Shikai J2 / J3 pressed after his J had cancelled
  her NS were absorbed by her SA, or he was hit. The count comes from this cell's first variant at 20 seeds; v0's code has the same gap.
  One sample in v0's own log: J1 cancels IC-K-N1A, J2 ABSORBED, then her ~400 AS3 string.

## The mechanism (only duel/lisp/cpu-ki-ken.lisp; every knob a defparameter with an old -> new note)
1. **Every L3 plans the Bankai** at HARD: `*kk-bankai-p*` 0.6 -> 1.0 (NORMAL stays 0.1). `*kk-climb-p*` 0.8 -> 1.0: the climb is the only
   road to L3.
2. **Straight back**: `*kk-bk-cashouts*` 1 -> 0. The first Bankai string after the entry chase is J1–J5 + SP (CHIGIRI 247 / TATE-GOTO 288
   for 40 Reishi; the cash-out cost 160). Most stays now last 236 frames: entry, meaty chase, special AS, back in the Shikai. Then the
   cycle repeats: climb, L3, J1–J7 Bankai, J1–J5 + SP.
3. **The L3 / Bankai approach** (new `kk-approach`, `*kk-l3-hoho-p*` HARD 0.9, `*kk-l3-hoho-band*` 3–7 m, `*kk-l3-walk-range*` 4.5).
   - At L3 with the plan, or in a Bankai, at 3–7 m: one roll per neutral decision to Hoho in. He reappears 1.6 m behind her, and the next
     free step starts J1 (the decision timer is set to 1).
   - When the roll fails he walks in. He never takes the generic NS from out of reach.
4. **The AS read restored in the style's strings** (`*kk-as-read-p*` 1.0 at every level, as the generic CPU reads):
   - Her NS seen as his link lands: the SP now.
   - Where that SP is a Shikai burst (pointer 1 after J3, pointer 2 after J1 / J2; it resets L), `*kk-read-burst-p*` HARD 1.0 still takes
     it.
   - The BANKAI AS (J7 + SP) is never early: the read needs fewer presses than the target.
5. **The J1 race for 卍解爆發** (`*kk-race-p*` HARD 0.6, its own knob): the sealed read's J1 branch only (F1 / F27), now also at L3 with
   the plan and in a Bankai. Her NA / NS start within 3.1 m: J1 when it lands first, and the string runs to J7 + SP (or J5 + SP in the
   Bankai). The tame and NS1a branches stay sealed-only.
6. **Kikon only on a red Ichigo** in the style's string SPs (`*kk-kikon-red-p*` HARD 0.95). A non-red Ichigo cancels the follow-up (the
   generic's cancel 0.95 at HARD), and the generic held 35 % of SPs into it.

Rules kept: one roll per event (a neutral decision, her move start, a link, L3 reached), SIM-RND01 only, the opponent read through SNAP
and the distance, plus her red bar (a visible fact, as GAUGES-RED-P is in the generic CPU). The sealed form is untouched: brawl is
byte-identical in every run (543/974 at 20 seeds, 1065/1875 at 40).

## Measurements (matchup-eval --side ken; 20 seeds a seat, paired seeds; each row adds to the one above)

| Variant | strength | shikai | bankai | antiwave | score |
|---|---|---|---|---|---|
| baseline v0 | 0.150 | 0.714 | 0.316 | 0.474 | 0.3692 |
| + bankai-p 1.0, Hoho approach 0.6, walk-in, Kikon on red | 0.150 | 0.720 | 0.627 | 0.200 | 0.3756 |
| + cashouts 0 | 0.125 | 0.677 | 0.736 | 0.316 | 0.3930 |
| + climb-p 1.0 | 0.175 | 0.709 | 0.613 | 0.385 | 0.4097 |
| (control: Hoho approach 0.0) | 0.050 | 0.531 | 0.436 | 0.250 | 0.2863 |
| + AS read in the style's strings | 0.150 | 0.787 | 0.755 | 0.353 | 0.4278 |
| + J1 race at L3 / Bankai | 0.175 | 0.845 | 0.660 | 0.400 | 0.4393 |
| (control: read-burst 0.0) | 0.150 | 0.767 | 0.625 | 0.286 | 0.3952 |
| + Hoho approach 0.9 (**final**) | 0.250 | 0.779 | 0.735 | 0.444 | 0.4774 |
| (tried: the same Hoho + J1 for the climb below L3, 0.5) | 0.225 | 0.773 | 0.789 | 0.273 | 0.4490 |

Settled at 40 seeds a seat: the climb Hoho scored 0.4473 (antiwave 0.25, HARD 18/80) and the final 0.4954. The climb Hoho was removed:
it spends the Hoho before her Getsuga comes.

**Final, 40 seeds a seat (score.json):** strength 0.275 (HARD 22/80; baseline 0.125, 10/80), signature 0.6423 (baseline 0.5008):
brawl 0.568 (unchanged), shikai 0.782 (0.768), **bankai 0.747 (0.312; 165/221 against 34/109)**, antiwave 0.472 (0.356). NORMAL 0.9625
(baseline 0.9625), factor 1.0. **Score 0.4954 against 0.3505.**

## Why it is not a repeat
Round 1 has no earlier cells. Compared with v0:
- The Bankai becomes a fast repeating cycle (no cash-out, every L3 commits).
- The style gets its first approach logic for L3 / the Bankai: Hoho in, else walk in.
- A located bug is fixed: the missing AS read in `kk-move`.
- The sealed J1 race is extended to the Bankai route.

This is a structural change, not knob drift around v0's settings.

## Expected benefit and risks
- Expected: bankai about 0.75, shikai about 0.78, more HARD wins. The Bankai's x1.2 and the special AS land more often, and the AS read
  stops the SA punishes.
- Risks:
  - The exit costs him 1 Konpaku each time. Against a stronger Ichigo that may tip close matches.
  - The remaining 卍解爆發 failure is the exit. Final file, 20 seeds a seat (diagnostic logs):
    - 102 L3 plans, 86 entries, 73 exits;
    - 13 stays end with the match inside the Bankai (KESSA Ichigo kills him there, or a J of the J1–J5 exit misses);
    - 14 plans are still open at the end.
    The J1 race raised the end-in-Bankai count in one diagnostic (v5: 23 of 86; the final: 13 of 86, on different streams).
  - One rule edge: when a Hoho press does not come out, the decision timer stays at 1 and `kk-approach` rolls again on the next free
    step. That is a per-step roll in a failure mode. At 0.9 it makes almost no difference; fixing it would change the stream and need a
    re-measure.
  - Antiwave rests on 24–36 situations (±0.08), so its rise is not evidence.
  - The Hoho approach is the largest single lever (0.286 without it, against 0.410 at 0.6 on the same stack). An Ichigo that answers a
    Hoho cross-up, for example by attacking on his reappear, would cut it. In the final logs about 84 of roughly 190 approaches lead to a
    landed J1, and about 30 were hit before he acted.
  - NORMAL: the NORMAL values of the new knobs (`kikon-red` 0.6, `read-burst` 0.5, `as-read` 1.0, the others 0) act only inside the plans
    rolled at 0.1 at NORMAL. The measured NORMAL share is 0.9625, equal to the baseline.

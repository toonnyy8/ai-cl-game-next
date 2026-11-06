# b3_a0: KESSA 強攻 led, the awakening placed and the KESSA strings steered by pointer (round 1)

Direction: lean on KESSA 強攻 while keeping the other three themes usable. Parent: the baseline v0 (`ichigo/baseline`, 0.5781).

## History read
- Round 1 has no history. The sibling node directories (b0–b2) were still empty when this was written. The baseline proposal and its
  score.json (HARD 70/80, kessa 0.463 = 37/80) are the only record. The v0 names two weak spots: the hover sits outside the whiff radius,
  and at pointer 2 inside 2.3 m she opens a J string that his S6 J1 beats.

## Diagnosis (v0, HARD, 20 seeds a seat, combat log; scratch tools, not committed)
- **She does awaken: 39 of 40 matches.** So the failures (19 of 40) are matches where she took more than she dealt while in KESSA,
  not matches where she never entered it.
- She awakened point-blank, 1.3–3.0 m (the `:kessa` check was only `calm` or `d > his reach + 1.5`). The cinematic leaves both
  fighters idle where they stood.
  - Seed 1: three J1–J4 SP1 strings in a row right after the cinematic.
  - Across the 40 matches, though, she landed the first hit after the cinematic in 27 of 39. A point-blank awakening is not shown to be
    the main cause.
- In KESSA, a `:kessa` episode steered its strings to AS2 (`*iks-kessa-as*` 3). AS2 writes pointer 2. Pointer 2's neutral has no
  punisher (no NS punish, and the J string his J1 beats), and it pulls her into the back-dash / Getsuga routine.
- Her KESSA Soul Breaks mostly took 4 Konpaku: the bar broke on J links while the pointer was 1 or 2, which fails 指針三狩魂. Red
  Kikons were rare once the strings ran to AS3.

## The mechanism (only `duel/lisp/cpu-ki-ichigo.lisp`; every new knob a `defparameter` with a docstring)
1. **Go for KESSA once the gauge is full** (`*iks-full-kessa-p*` HARD 0.9, NORMAL 0). An episode that starts with the gauge full is a
   `:kessa` episode, one roll per episode.
2. **Awaken from outside his reach** (`*iks-awaken-gap*` sealed 4.1 m, Shikai 5.3 m; `*iks-awaken-far*` 7.0; `*iks-awaken-band*`
   0.6). Nearer than that, the episode walks out to the gap first, bounded by `*iks-wait-max*`.
   - Awakening still happened in 40 of 40 matches.
   - **This is kept on the A/B alone.** v1 against v1b (gap 0) gave kessa 26 against 20 of 40, about 1.5σ, ledger +18k against +3k.
   - The cause is not known. With the gap on, his first hit after the cinematic was more frequent, not less (17 of 40 against 12 of 39).
   - Many v1 awakenings fired at d ≈ 8 through the `*iks-awaken-far*` branch, for example after a knockdown or a back dash. That may be
     the change that matters.
3. **KESSA strings by pointer:**
   - `*iks-kessa-as*` 3 → 5: a `:kessa` string runs to J5 + SP (AS3 with the clones, 190–193 in K4 / K11), and pointer 3 is kept.
   - New `*iks-kessa-red-as*` 3: in KESSA, in any style mode, when he is red at a string's first link, the string runs to AS2.
     - Its Kikon on profile 2 is held (the existing `*iks-kikon-p*` rule). Against red it takes the Soul Break's count, 4 in KESSA.
     - That Kikon counts as a 指針三狩魂 success, where a J-link break at pointer 1 / 2 would take 4 and fail.
4. **KESSA's own punish reach and plan.**
   - `*iks-kessa-punish-reach*` (3.4 0 4.4). At pointer 3 in KESSA the plan is `:k-lunge`: NS3a summons a clone, then the SA's 3 m lunge.
   - Before, it used the Shikai's 5.0 m reach and plan `:lunge`. That never pressed the SA after KESSA's NS3a, but the punish still
     landed through the clone's swing: 28 of 37 in v0.
   - **Not isolated.** It rode along in every variant from v1 on. In v2a, KESSA pointer-3 J punishes paired with a whiff success
     44 of 54 times.
5. **Mode weights in KESSA** (`*iks-kessa-mix*`, HARD only): a bit more `:whiff` and `:kessa`, less `:generic` / `:ptr3`. NORMAL is
   unchanged.

All rolls stay once per event: the mode once per episode, the steer once per string. Every chance is EASY ≤ NORMAL ≤ HARD. The only new
chance (`*iks-full-kessa-p*`) is 0 at EASY and NORMAL. The opponent is read only through the SNAP, the distance, his visible form (already used by the v0
tables) and `gauges-red-p` (already used by the v0 Kikon rule).

## Why it is not a repeat
This is the first KESSA-led cell. It changes where and when the awakening happens, and which AS the KESSA strings end in, chosen by
pointer and by red. The v0 had a fixed AS2. Each piece rests on a fault located in the v0's log, not on a weight sweep.

## Measurements
Paired at 20 seeds a seat (seeds 1–20). The ledger column is the log's damage dealt − taken while in KESSA; it is not the evaluator's
Reishi ledger, but it tracks it.

| Variant | Score | Str | Spacing | Whiff | Ptr3 | Kessa | NORMAL | Ledger |
|---|---|---|---|---|---|---|---|---|
| v0 (baseline) | 0.5877 | 0.850 | 0.208 | 0.339 | 0.579 | 0.525 | 0.075 | +8k |
| v1: 1 + 2 + 4 + 5 | 0.5944 | 0.825 | 0.217 | 0.259 | 0.637 | 0.650 | 0.025 | +18k |
| v1b: v1 without the gap | 0.5785 | 0.850 | 0.218 | 0.245 | 0.628 | 0.500 | 0.050 | +3k |
| v1c: v1 + kessa-as 5 | 0.6450 | 0.950 | 0.164 | 0.377 | 0.451 | 0.775 | 0.050 | +82k |
| **v2a: v1c + red → AS2 (final)** | **0.6865** | 0.975 | 0.169 | 0.323 | **0.835** | 0.650 | 0.050 | +53k |
| v2b: v1c, no AS read at pointer 3 | 0.6294 | 0.925 | 0.156 | 0.371 | 0.478 | 0.725 | 0.050 | +65k |
| v2c: v2a, red → AS2 only off pointer 3 | 0.6514 | 0.950 | 0.158 | 0.353 | 0.548 | 0.750 | 0.050 | +71k |

Rejected:
- v1d / v3a: hover against his Shikai in KESSA, 0.604 / 0.654; the ledger fell.
- v1e / v1f: a safer / a more aggressive KESSA mix, 0.583 / 0.550.
- v3c: `*iks-wait-max*` HARD 300, 0.576.
- v4a: no NS punish at pointer 1, 0.658.

The kessa rate moves ±0.1 across near-neutral variants at 20 seeds (40 situations), so the variants were judged on the ledger and the
other themes too.

**Final file, 40 seeds a seat (score.json):** score 0.6827, against the baseline's 0.5781.

| Part | Baseline | Final |
|---|---|---|
| HARD | 70/80 | 78/80 |
| Strength | 0.875 | 0.975 |
| Signature | 0.380 | 0.488 |
| Spacing | 0.196 | 0.170 |
| Whiff | 0.307 | 0.324 |
| Ptr3 | 0.556 | 0.783 |
| Kessa | 0.463 | 0.675 |
| NORMAL | 0.1125 | 0.0625 (band 0–0.138, factor 1) |

## Expected benefit and risks
- Benefit:
  - kessa +0.2 and ptr3 +0.2 come mostly from the steering: AS3 keeps pointer 3 (+64k ledger, v1 → v1c), and the red AS2 Kikon
    (ptr3 0.45 → 0.84, v1c → v2a). The awakening gap is a smaller gain whose cause is unexplained;
  - strength rises because KESSA no longer bleeds.
- Risks:
  - Spacing dropped (0.196 → 0.170). In KESSA, AS3's ending (+41 at 1.9 m) puts her close more often than AS2's 4.8 m, so the 4–5 m
    band comes up less.
  - The red AS2 Kikon leaves her at pointer 2 afterwards. v2c, which avoided that, had a higher kessa rate but a lower ptr3 rate.
  - Against a Kenpachi CPU that punishes the walk-out to the awakening gap, the gap would cost time. It is bounded by `*iks-wait-max*`,
    after which the generic CPU plays on.
  - NORMAL's share fell (0.1125 → 0.0625) while staying inside the band. The new chance knob (`*iks-full-kessa-p*`) is 0 at NORMAL,
    and the KESSA mix's NORMAL row is the v0's. The route choices still apply inside NORMAL's style episodes, which are 12 % of them:
    the AS targets, the KESSA punish, and the awakening gap.

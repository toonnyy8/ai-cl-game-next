# b1_a0 (round 2, Ichigo): the patient sealed form. Wait for his whiff, Hoho his attack into the perfect window, stop your own whiffed NS

Direction: 揮空反擊 (whiff), keeping the other three usable. Parent: none, so the file starts from BASELINE_DIR (b2_a1, re-measured
against Kenpachi's champion round01/b3_a1: 0.2877, HARD 6/80). Opponent: `ken/champion/cpu-ki-ken.lisp`. Only
`duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
I read round 1's eight proposals with their score.json and score.rescored.json (every rescore equals the cell's own line), the
baseline, and round 2's b0_a0, which delivered while I worked (rescored 0.4151).

| Cell | Mechanism | Rescored | What it means here |
|---|---|---|---|
| b0_a0 / b0_a1 (r1) | pointer-2 re-arm, p1 hover; base lunge band 4.7–5.0 | 0.648 / 0.665 | re-arm in the baseline. The sealed lunge loses against this Kenpachi's Hoho / back Step (below) |
| b1_a0 / b1_a1 (r1) | whiff confirm + walk-in; hold ground | 0.658 / 0.775 | confirm in the baseline, and it is the one thing that still wins here (confirm J 96 hers / 14 his first hits) |
| b2_a0 / b2_a1 (r1) | Konpaku finisher; b2_a1 = the baseline | 0.715 / 0.783 | kept whole |
| b3_a0 / b3_a1 (r1) | KESSA led; the timed KESSA Hoho + follow-up, read floor | 0.683 / 0.724 | b3_a1 named "the same timed Hoho in the sealed form" as an untested follow-up. It is the biggest piece here |
| b0_a0 (r2) | KESSA k-lunge band 5.05–5.5 m beyond his back Step, all modes lunge there, KESSA Hoho, read floor | 0.4151 | its sealed timed Hoho (v10) was neutral in its file; in a patient sealed form it is +0.10 (below). Its KESSA pieces were tried on top of this file (v17) |

**Round 2's b3_a0 delivered after this file was final** (its own score.json 0.7151, 65/80, kessa 0.75; not rescored when I read it).
It found the same sealed timed Hoho independently, and adds the wake-up Hoho (perfect on his meaty J1's frame: his string stops at that
J1, meaty damage 89k → 43k), a longer Hoho follow-up window (a located bug: 40 f closed before the delayed SNAP showed his reeling), and
b3_a1's Hoho test widened for his Shikai lunge's slide. None of those are in this file. This file's pieces that b3_a0 lacks are the
patient sealed form, the NS whiff stop, the breaker and the post-Burst Hoho fix. They touch different code, so combining the two is the
obvious refine.

No round-1 failure was a bug left in. What changed is the opponent: round01/b3_a1 only starts moves that reach her, stops his own whiffed
NS, Hohos or back-Steps through her lunges, clones and walk-ins (`kk-read`), Hohos in, and loops a meaty J1 on her wake-up.

## Diagnosis (the baseline against b3_a1, 20 seeds a seat, HARD; scratch log parsers over the evaluator's own stdout)
- **His damage on her, by what opened it** (seat 1 / seat 2, 20 matches each): meaty J1 loop 70.7k / 69.2k, his dodge of her move
  (Hoho) 43.4k / 36.3k, his back Step through her move 23.3k / 18.4k, everything else ≤ 18k. Hers: 58k / 73k.
- **Her neutral starts, first hit within 90 f** (hers / his; from the v1 logs, i.e. the baseline plus the post-Burst fix, since the
  log line naming the generic CPU's presses exists from v1 on; the style actions read the same in the baseline's logs): the generic CPU's NS from `:ptr3` episodes 126 / 142, from `:whiff`
  episodes after `*iks-wait-max*` 46 / 104; walk-in NS1a 13 / 67; KESSA chains 11 / 33; pointer-2 J 4 / 32; sealed lunge 23 / 26.
  Against that, the whiff confirm's J 96 / 14, its SP 28 / 14, the punish J 16 / 4. Split by her form, the sealed form's starts are the
  losers (generic NS from `:whiff` 7 / 71, `:ptr3` 26 / 57, walk-in 6 / 33, lunge 4 / 29); in KESSA the generic's starts are about
  even (100 / 85).
- **Located bug 1, the Hoho after her Burst.** The Burst ends his move and pushes him 5 m off, but her SNAP is 8 f old and still shows his
  attack live in reach, so the generic Hoho fired about 10 f after the Burst and put her 1.6 m behind a free Kenpachi, who J1'd her (6 of
  the first 8 Bursts in the seat-1 log).
- **Located bug 2, her whiffed NS runs on.** Once the sealed form waited, the confirm's walk-in NS1a often came up short; the generic CPU
  pressed NS1b anyway on its first active frame, and his dodge (often a perfect Hoho: 60 and a 40 f lock) answered it: the walk-in
  confirm read 12 / 51.
- **His meaty J1 can't be escaped on wake-up** (his J1 lands on the step she becomes idle, before any neutral step of hers; b0_a0
  confirmed it by trial). The only exits are a Burst or the awakening while she is still in his combo (`awaken-state-p` allows both
  from `:stun` / `:air` past the second hit, with no flash-step for the awakening). The generic CPU rolls its Burst once per combo on the
  first eligible step, and the roll is spent even when the flash-step is short then.

## The change (final file = v15)
Items 1–5 are HARD only. Item 6 (the two bands set to NIL, and the KESSA pointer-1 hover that replaces the chains) has no difficulty
gate, so it also changes NORMAL's 12 % style episodes. EASY is unaffected, since its mix is 100 % `:generic`. NORMAL read 0.075 in the
final run, and the band's floor is 0, so it cannot fail low.
1. **The patient sealed form** (`*iks-patient-forms*` (:base), `*iks-patient-p*`): in her sealed form every style mode (`:ptr3` and
   a `:kessa` episode before the gauge is full included) hovers at the whiff distance (`*iks-hover*` / `*iks-hover-p1*`) and attacks only
   through the whiff punish / confirm. It never hands the episode to the generic CPU after `*iks-wait-max*`; no walk-in NS1a; no sealed
   lunge (`*iks-patient-lunge*` NIL). KESSA keeps v0's play (round 1's b3_a0 v1d / b3_a1 measured hovering in KESSA as a loss, and v10
   below agrees).
2. **Her NS whiff stop** (`*iks-ns-stop*`): in a style mode's own NS with hits of its own (not KESSA's clone segments or the Getsuga's
   charges), the next segment waits for contact, and a whiff stops the route (located bug 2; his style does the same, `kk-ns-whiff`).
3. **The timed Hoho in both forms** (`*iks-hoho-p*` HARD 0.9, `*iks-hoho-forms*` (:base :kessa), `*iks-hoho-lead*` (1 6), the J1
   follow-up `*iks-hoho-follow*` 40 f within `*iks-hoho-j-reach*` 1.5 m): b3_a1's KESSA Hoho, extended to the sealed form. His attack
   (NA / NS / SA / AS) in reach is Hohoed 1–6 f before its first active frame, so it falls in the perfect window: her counter (60) lands
   in his whiffed move's recovery, which is exactly the whiff theme's success, then J1 from behind. Where it runs, the generic's untimed
   Hoho roll is off (`*iks-untimed-hoho*` NIL). NORMAL 0.
4. **The breaker** (`*iks-break-p*` HARD 1.0, `*iks-break-awaken*` T): in his combo (`:stun` / `:air` past `*burst-min-hits*`, no Kikon
   lock, after her perception delay), one roll per combo: the awakening when its gauge is full (it repels him, heals 20 % and enters
   KESSA), else the Burst as soon as the flash-step allows it. The neutral awakening waits for it.
5. **No Hoho after her Burst** (`*iks-burst-no-hoho*`): while her own Burst invulnerability runs, the generic Hoho roll is off (bug 1).
6. **No walk-in, no KESSA chains** (`*iks-walkin-band*` NIL, `*iks-kessa-chain-band*` NIL: KESSA pointer 1 in a `:kessa` episode hovers
   in `*iks-hover-p1*` and waits for his whiff).

Rules kept: every chance EASY ≤ NORMAL ≤ HARD and rolled once per event (the timed Hoho per his move start, the breaker per combo, the
rest as before); the per-step pieces (the Hoho suppressions, the hover) are not chances. Randomness only through `brain-roll` /
`sim-rnd01`. He is read through the SNAP and the perceived distance; her own state (form, invulnerability, gauges, combo hits) for the
breaker and the Hoho budget (`ai-hoho-spare-p`). No new read of his gauges. Every tunable is a `defparameter` with a docstring. Host
tests: 9843 checks, ALL PASS.

## Measurements
20-seed rows: the full EVAL_COMMAND with `--seeds 20`, paired on seeds 1–20 (NORMAL included). 40-seed rows: HARD only (`--no-normal`,
raw = 0.4 strength + 0.6 signature), paired on seeds 1–40. "41–80": the evaluator's own run / parse imported by a scratch script that
only adds the seed offset (debug 30000+40), HARD only.

| Variant | 20 seeds: score / HARD | Spacing | Whiff | Ptr3 | Kessa | NORMAL | 40 seeds HARD raw | 41–80 raw |
|---|---|---|---|---|---|---|---|---|
| baseline (b2_a1) | 0.2979 / 4 | 0.054 | 0.540 | 17/17 | 5/40 | 0.10 | 0.2877 (6/80, their line) | 0.3101 (11/80, b0_a0's) |
| v1: no Hoho after her Burst | 0.2947 / 4 | 0.070 | 0.566 | 15/16 | 5/40 | 0.10 | | |
| v2: v1 + patience for `:whiff` / `:ptr3` in every form, `:ptr3` hovers, no walk-in | 0.2760 / 3 | 0.040 | 0.640 | 10/11 | 2/39 | 0.05 | | |
| v3: v2 + breaker | 0.2820 / 2 | 0.060 | 0.637 | 12/12 | 2/40 | 0.05 | | |
| vA: v1 + breaker | 0.2973 / 5 | 0.077 | 0.549 | 18/19 | 3/40 | 0.10 | | |
| v4: vA + patience in the sealed form only, every difficulty | 0.3275 (raw 0.3572) / 8 | 0.057 | 0.642 | 32/33 | 7/39 | **0.15** (factor 0.917) | | |
| v5: v4 HARD only + NS whiff stop | 0.3629 / 10 | 0.043 | 0.640 | 27/28 | 4/38 | 0.10 | | |
| v6: v5 + no sealed lunge | 0.4413 / 17 | 0.034 | 0.675 | 32/34 | 6/38 | 0.10 | | |
| v7: v6 + no walk-in, no KESSA chains | 0.4563 / 18 | 0.043 | 0.674 | 32/34 | 7/38 | 0.075 | 0.4692 (38/80) | |
| v8: v7 + neutral awakening (no awaken breaker) | 0.4275 / 15 | 0.042 | 0.677 | 36/37 | 6/38 | 0.075 | | |
| v9: v7 + inside 1.7 m walk back too | 0.4396 / 15 | 0.040 | 0.729 | 30/31 | 6/31 | 0.075 | 0.4047 (26/80) | |
| v10: v7 + KESSA patient too | | | | | | | 0.3613 (18/80) | |
| v11: v7 + Hoho only with a Burst left (FS ≥ 300) | | | | | | | 0.3886 (24/80; whiff 0.623) | |
| v12: v7 + the timed Hoho in both forms | 0.5815 / 29 | 0.048 | 0.807 | 52/54 | 4/32 | 0.075 | 0.5691 (54/80) | |
| v13 / v14: v12 + awaken breaker only near the end ((4 . 3) / (4 . 0) Konpaku) | | | | | | | 0.5532 (52) / 0.5460 (51) | |
| **v15: v12 + no untimed generic Hoho (final)** | | | | | | | **0.5840 (58/80)** | **0.5541 (53/80)** |
| v16: v12 without the breaker (ablation) | | | | | | | 0.5596 (53/80) | |
| v17: v15 + b0_a0's KESSA pointer-3 pieces (band 5.05–5.5, all modes, SA reach 5.7, projection, read floor) | | | | | | | 0.5778 (53/80; spacing 0.132, kessa 0.181) | 0.5517 (49/80; spacing 129/1037) |

- v1's bug fix halved her Hohos and changed nothing measurable by itself; it stays as a located fix.
- The breaker, attributed on the final structure: v16 → v12, +0.0095 raw, +1 win (inside the noise), kept for the located reason.
- **The 80-seed means (1–80, HARD raw):** baseline about 0.30, v15 **0.569**, v17 0.565.
- v12's whiff by state (its 20-seed logs; v15 differs only by the untimed-Hoho switch and was not logged): base pointer 1 228/333 (0.68, was 0.44), base pointer 3 303/326
  (0.93), KESSA pointer 3 60/70, KESSA pointer 1 27/34. Her damage per 20 matches a seat 87k / 107k against his 77k / 94k (baseline:
  58k / 73k against 178k / 164k). His meaty damage fell from 70k to 22–29k a seat: fewer knockdowns, and the breaker.

**Final (v15, 40 seeds a seat, the EVAL_COMMAND, score.json):**
`{"side": "ichigo", "seeds": 40, "strength": 0.725, "signature": 0.4901, "themes": {"spacing": {"rate": 0.057, "ok": 62, "occ": 1081}, "whiff": {"rate": 0.807, "ok": 1170, "occ": 1449}, "ptr3": {"rate": 0.957, "ok": 110, "occ": 115}, "kessa": {"rate": 0.139, "ok": 10, "occ": 72}}, "hard": "58/80", "normal": {"share": 0.075, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.584, "score": 0.584}`

| Part | Baseline (40 seeds) | Final |
|---|---|---|
| Score | 0.2877 | **0.584** |
| HARD | 6/80 | 58/80 |
| Spacing | 0.062 | 0.057 |
| Whiff | 0.556 | **0.807** |
| Ptr3 | 1.0 (31) | 0.957 (115) |
| Kessa | 0.100 | 0.139 |
| NORMAL | 0.100 | 0.075 (band 0–0.138, factor 1) |

## Negative results (keep them)
- **Patience in KESSA loses** (v10, 18/80 against 38/80): the generic's KESSA starts are even, and hovering lets him come in. Round 1's
  b3_a0 / b3_a1 found the same against Kenpachi v0.
- **Patience at NORMAL breaks the band** (v4: NORMAL 6 of 40 = 0.15 > 0.138). HARD only.
- **Walking back inside 1.7 m loses** (v9: whiff up to 0.729, but 26/80 against 38/80 at 40 seeds). The generic's point-blank press is
  better than retreating into his J1 range.
- **Keeping a Burst in reserve by Hohoing less loses** (v11, 24/80): her Hohos are worth more than the extra Bursts (whiff 0.70 → 0.62).
- **The awakening as a neutral move, not a breaker, loses** (v8, 15/40 against 18/40), and so does saving it for the end of the match
  (v13 / v14): the KESSA ledger did not improve either way.
- **Patience for `:whiff` / `:ptr3` in every form, without the NS stop** (v2 / v3) only moved whiff; strength and kessa fell.

## Not a repeat
- The patient sealed form is new: no cell removed the generic neutral, the walk-in and the sealed lunge together, or measured the
  form split (sealed starts lose, KESSA starts are even).
- The NS whiff stop and the post-Burst Hoho are located bugs, found in this round's logs.
- The breaker (the awakening / the Burst timed by flash-step inside his combo) is new; no cell touched the Burst or used the awakening as
  a combo breaker.
- The timed Hoho is b3_a1's piece; b3_a1 named the sealed version as untested, and b0_a0 (round 2) found it neutral in a non-patient
  file (its v10). In the patient form it is the biggest step here (+0.10 raw at 40 seeds), and the untimed generic Hoho off is new.
- v17 is a combination test with b0_a0's KESSA pieces, not delivered: on 80 seeds it is level with v15 (signature +0.03, strength
  −0.05). A later cell could take it if the spacing / kessa themes weigh more against the next opponent.

## Expected benefit, risks
- **Benefit:** score 0.2877 → **0.584** at 40 seeds; HARD 6 → 58/80 of 80; whiff 0.556 → **0.807**. It holds on seeds 41–80 (53/80,
  raw 0.554 against the baseline's 0.310 there).
- **The opponent will change.** Everything leans on the round-1 champion's habits: he walks in and starts only what reaches, so a patient
  Ichigo gets his whiffs; his attacks are readable from the SNAP for the timed Hoho. A Kenpachi that waits too, or baits the Hoho (a
  delayed segment, a move after her 60 f Hoho lockout), cuts the core of this file.
- **Spacing is low (0.057) and kessa too (0.139).** The sealed form no longer lunges, so the 4–5 m band only comes from the confirm's
  NS3a; the KESSA ledger still fails in most matches she wins (v12 logs: 18 of 22 won matches failed it, 7–53 s in KESSA). v17 shows
  b0_a0's KESSA pieces raise both without a net loss.
- **The Hoho and the Burst are shared defensive tools**, not rows of §4's table (b3_a1's review risk, carried over). They are the shipped
  CPU's own Hoho and Burst, retimed: the Hoho into the perfect window (whose counter is the whiff punish), the Burst / awakening to the
  moment it breaks his combo (the awakening is KESSA 強攻's entry). Both are HARD only.
- **The hover** (`*iks-hover-p1*` 3.4–3.8 m sealed) sits near his NS reach; his Hoho-in reaches it (5–13k a seat in the logs).
- **Carried from the baseline:** the Konpaku-pip read (`iks-kikon-value`) and his form for the band tables.

# Cell b1a2 (round 1, refines b1a1): "every hit into the stance, the pips cashed from range" — the signature's bridges cut, the base form's resource cycle closed

Freeze 36e93c7. Parent b1a1 (its `barro.lisp`, its BARRO-CPU-TESTS section spliced in; re-measured here first: the same JSON
to the digit as its score.rescored.json, 0.9529). Only `duel/lisp/barro.lisp` (his CPU parts: three kits' `:ai` keys, the
`:stance` chances, one new pure function + knob and its call in BR-AI-KAMAE, comments) and the `BARRO-CPU-TESTS` section of
`tests/duel-rules-test.lisp` changed. Host test 8345 checks ALL PASS; `tools/pkgcheck.sh duel` 0 / 0 / 0. Final measure
(`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, score.json = the delivered file, re-measured last; identical to v5
below):

| | baseline | b0a1 | b1a1 (parent) | **b1a2** |
|---|---|---|---|---|
| score | 0.0 (raw 0.1702) | 0.952 | 0.9529 | **0.9716** (raw 0.9716) |
| strength (HARD, both seats) | 0.003 | 0.963 | 1.0 | **1.0** (400 / 400) |
| masher | 0.302 | 1.0 | 1.0 | **1.0** |
| signature | 0.272 | 0.918 | 0.882 | **0.929** |
| NORMAL share (band 0.30–0.60) | 0.05 (x0) | 0.525 | 0.5425 | **0.465** (x1; Y 60, K 16, R 34, I 30, S 46 of 80) |
| pacing medians Y K R I S (cap 220, all 40/40 K.O.) | 131 114 122 122 124 | 150 148 172 184 174 | 124 136 145 149 148 | **117.5 129.8 157.7 151.2 149.8** |

sig_by (top): br-e-k 0.222, br-e-kl 0.138, br-oe-k 0.109, **br-k-hiren 0.090** (0 in every earlier cell), br-rc 0.084,
charged 0.078, br-oe-kl 0.070, **plain-jk 0.065** (b1a1 0.104, b0a1 0.073), br-s-l1- 0.054, br-s-j 0.032; outside the
whitelist besides plain-jk: counter 0.003, cuts / level-1 L 0.002.

## History read (every proposal, score.json and score.rescored.json; the rescored number trusted)

- **baseline** (0): the stance at 4 m for 1.9–2.6 m strings, never charges, waits in the rooted EN.
- **b0a0** (0.8032): L's hold as the plan, the CPU's R17 link, the turn before the follow-up after the dash (HARD 0.23 → 0.52).
- **b1a0** (0.6985): routes on events, the anti-Breaker model, the owl early; its low strength was a located omission (the
  turn), not a flawed idea.
- **b2a0** (0.915): the opponent's reach envelope (kite / ward), the Kikon on openings only, the unguard, the snipe let-go fix.
- **b3a0** (0.9192): the clock for charges, the wings as armour first (the reserve: HARD 77 → 95 / 100). Its v6 / v7
  measured `:l-after-*` 1.0 as net −0.004 there (strength −0.03, NORMAL up).
- **b0a1** (0.952): b2a0 + b3a0 combined, the wake-up shot, `:l-after-j` 1.0 (net +0.006 there: plain-jk 0.092 → 0.073).
- **b1a1** (0.9529, my parent): the Step-in interrupt, the stance's exit, the let-go per charge; strength saturated at 1.0
  (400 / 400), signature 0.882 with plain-jk 0.104 the largest non-signature share; NORMAL 0.5425 (0.0575 under the top).

No failure in the history was a bug left open. The open question at this point was the signature: with strength saturated
and NORMAL near the top, every gain had to come from the share of his damage on the whitelist, without NORMAL drifting up.

## Diagnosis (b1a1's file, the combat log: 4 seeds x 5 opponents x both seats, HARD, 40 / 40 wins)

His damage by move and by the reason his brain pressed it (scratch parser of `run-log.lisp` output, as aieval reads it):
- signature 0.885; plain 0.101, of which: the generic follow-up J1 after the dash through him (BR-W-J1 / BR-O-J1
  FOLLOW-UP) 0.036; **the K2s / K3 bridges of the attack states' strings 0.031** (base BR-K2S 0.012 + BR-K3 0.007 + BR-J2,
  KIN BR-W-K2S 0.005, the owl BR-O-K2S 0.005 + BR-O-K3): the `:l-after-*` rolls that failed (base J 0.3, K 0.9, KIN / owl
  0.85) let the generic string go on with plain links; Step-in / Step-J / chain / anti-Breaker J1s ~0.02; the generic O-ender
  Kikon after the base K3 0.004.
- The follow-up J1 after the dash is a share-positive bridge (J1 20 → EN K1 46 K2 46 K3 66 → KL lines 70: ~94 % signature)
  and cannot be skipped: after a level-2 dash Lille is free 5 f after the last cut, after a level-3 dash 2 f before it; the
  cut's stagger (26 f) leaves no room for the turn (12 f) + EN K1 (16 f) — measured frame by frame in the logs; dropped.
- The base form's pips: in 40 HARD matches 218 level-2 snipes ended at 3 pips, most of them already at the cap (their +2 was
  lost); the base stance's own SP2 (HIRENKYAKU: the 6 m slide back, its 萬物貫通 line, 50 + 40 a pip; whitelisted as
  BR-K-HIREN) was never used from neutral by any cell.

## The action policy (行動方針): b1a1's routes, plus

1. **Every link that hit goes into the stance** (`:l-after-j` / `:l-after-k` 1.0 in the base, JILLIEL KIN and the owl KIN).
   Awakened: J1 / K1 → the R17 link → EN K1 → K2 → K3 → KL lines (no plain K2s / K3 when the roll failed). Base: J → L →
   the gun-kata (all signature) instead of b1a0's J1 → K2s → the rifle (two plain links, 64 damage, before the stance); K →
   the rifle. The trade b3a0 measured negative is positive here: strength has no headroom to lose (1.0 stays 1.0 / 0.998)
   and NORMAL went **down** (0.5425 → 0.4525: the base gun-kata deals less than the K2s route), so the generic keys not being
   difficulty-scaled is no longer a risk to the band — it moved NORMAL to its middle.
2. **The pips cashed from range** (`BR-AI-CASH-PLAN`, pure; `*BR-AI-CASH-P*` 0.1 / 0.3 / 1.0, one roll a stance, in
   BR-AI-KAMAE): in the base stance, a snipe plan (him out of the melee strings' reach) with the pips at the cap (3) and SP2's
   bars there (him not down) becomes the stance's SP2 HIRENKYAKU: the slide back 6 m, then the 萬物貫通 line, every pip spent
   (50 + 3 x 40 = 170, x1.3). The base form's resource cycle closes on its own: the charged snipe gains (level 2 +2, level 3
   +3), HIRENKYAKU spends; the snipe at the cap no longer throws its gain away. Measured (v3 logs, 40 HARD matches): 121
   cash-outs, 95 hits, 4 blocked — the slide back makes it safe and the line rarely misses a CPU that is closing in.
3. **Every charge, line and cash-out at HARD**: the kits' `:stance` `:charge` / `:follow` / `:sp2` 0.6 → 0.7 (x1.5 = 1.0 at
   HARD: no level-1 tap of the dash / snipe, no skipped KL line; NORMAL x0.3 0.18 → 0.21); the base `:far-snipe :p` 0.5 → 0.7
   (HARD: the stance from afar at every window, 0.75 before; NORMAL 0.15 → 0.21): more of the base form's time is the
   charged snipe and the cash-out, both pure signature.

Per form: **base** — J pokes / the Step-in J1 / Step-J → L → the gun-kata J1 J2 J3 → JL (refill) or HIRENKYAKU-C; K links →
the rifle; from ≥ 4.5 m the stance: the charged snipe (level 2, level 3 from 7 m) or, the pips full, HIRENKYAKU from range.
**KIN / the owl KIN** — b1a1's (kite, exit, Step-in J1, far dash charged at HARD every window, the turn-wait then J1 → the
R17 link), every link that hit → the link into EN K1. **EN / the owl EN** — b1a1's window plan; every KL line paid above the
wing reserve; the owl's volley.

Difficulty: every new or changed chance EASY ≤ NORMAL ≤ HARD (`*BR-AI-CASH-P*` a table; the `:stance` values through
`BR-AI-CHANCE`), one roll a stance / string link / window; the `:l-after-*` keys are the generic string reflex's (raw, one
roll per hit). Randomness only SIM-RND01; the opponent through the perceived SNAP (the cash-out reads only his perceived
state for "not down"; the pips, bars and the stance are Lille's own state).

Kept working: AI-AWAKEN-P / `:awaken` and the burst untouched; the learner (BR-LEARN-KAMAE still reads the stance plan before
the cash-out; no new reflex); the ASSIST (no hook it calls changed); every debug / test command and the `duel barro` pace
counters (new: `ai-kamae-sp2`, plus the existing `kamae-sp2`); no new BRS slot, no new tick branch.

## The steps measured (aieval, 40 seeds)

| step | change | score | str | mash | sig | NORMAL | plain-jk |
|---|---|---|---|---|---|---|---|
| v0 | b1a1 re-measured | 0.9529 | 1.0 | 1.0 | 0.882 | 0.5425 | 0.104 |
| v1 | `:l-after-j / -k` 1.0 (base, KIN, owl KIN) | 0.9641 | 0.998 | 1.0 | 0.913 | 0.4525 | 0.077 |
| v2 | + the cash-out (HIRENKYAKU at the pips' cap) | 0.9673 | 0.998 | 1.0 | 0.921 | 0.47 | 0.070 |
| v3 | + the dash at level 3 from 3 m (`*br-ai-dash-reach*` 4.5 → 3.0) — not kept | 0.9669 | 0.993 | 1.0 | 0.925 | 0.4575 | 0.066 |
| v4 | v2 + `:charge / :follow / :sp2` 0.7 | 0.9692 | 0.998 | 1.0 | 0.925 | 0.4825 | 0.068 |
| **v5** | **+ `:far-snipe :p` 0.7** (delivered) | **0.9716** | 1.0 | 1.0 | 0.929 | 0.465 | 0.065 |
| v6 | + the snipe's level 3 from 5 m (`:far` 7 → 5) — not kept | 0.9707 | 0.998 | 1.0 | 0.929 | 0.4675 | 0.064 |

v3 and v6 are within noise of their parents (the signature's gain paid by strength); not taken.

## Why it is not a repeat

The `:l-after-*` 1.0 step is a parameter, taken because the diagnosis located the plain K2s / K3 bridges as the largest
removable non-signature share and because its measured trade changed sign here (strength saturated; NORMAL moved down to the
band's middle instead of up, unlike b0a1's v4 and b3a0's v6). The cash-out is a new mechanism: no cell used the base stance's
SP2 from neutral (b0a0 / b3a0 used it only as the J route's ender HIRENKYAKU-C, which needs a string that hit and 2 bars at
its end); it closes the base form's 「資源循環」 from range the way the K route's L L lines close the awakened one.

## Awaken A/B (informational: the awakening and the burst untouched; the base form's links and its cash-out changed)

`python3 tools/simgate.py --pairs 21,22,23,24,25 --seed0 S --seeds 60 --cmd 39020 -j 2`, the never-awaken side's (P1 Lille
II, NORMAL) wins of 60, Y K R I S:

| seed0 | b1a2 | b1a1 (parent) | baseline (b1a0's measure) |
|---|---|---|---|
| 100 | 13 1 1 1 1 | 11 7 6 5 6 | 2 9 0 1 1 |
| 300 | 13 1 1 3 1 | 15 4 1 6 3 | 2 7 0 0 1 |
| 500 | 10 1 2 4 1 | 28 6 3 4 3 | 6 3 0 0 1 |

All 900 matches K.O. (medians 130.9–167.0 s). All rows far under the gate's 20, as for the baseline and every cell: these
rows measure his NORMAL base form alone (the burst never acts there) against awakening opponents. Lower than the parent's
on BK / BR / BS: the base form's links now go into the gun-kata (less damage than b1a1's K2s → rifle route) and its NORMAL
plays more at range. For the integration gate; the awakening and the burst themselves are unchanged.

## Expected benefit, risks

- Benefit: signature 0.882 → 0.929 with strength 1.0 and the masher 1.0; NORMAL 0.465, the band's middle (0.135 under its
  top, 0.165 over its floor) — the safest NORMAL in the round so far.
- Pacing: medians 117.5–157.7 s, ≥ 62 s under the 220 cap (no risk).
- The cash-out makes the base form play at range when its pips are full (a HIRENKYAKU from the stance at ≥ 4.5 m): a human
  who reads the stance at the cap can Hoho / dash in during its 20 f (the slide back covers 6 m of it); the learner does not
  read it. Its bars compete with the gun-kata's HIRENKYAKU-C ender (br-k-hiren-c 0.015 → 0.012).
- `:l-after-*` 1.0 is raw at every difficulty (the generic reflex): NORMAL confirms every hit into the stance too; measured
  NORMAL went down, but a later change that makes the base stance strings stronger would move NORMAL with HARD.
- plain-jk 0.065 left is mostly the follow-up J1 after the dash (0.034) and the base's Step-in / Step-J / chain J1s: bridges
  into signature routes; the dash's cut stagger leaves no room to skip them (see the diagnosis).

## Shared-code recommendations (not done)

- ai.lisp STRING-REFLEX: a kit factor scaling `:l-after-k` / `:l-after-j` by the difficulty (every cell asked).
- The generic follow-up after a kit's own multi-hit (the dash's cuts) could let a kit name its own follow-up command (here:
  the turn into EN when the frames fit), instead of the generic J1.

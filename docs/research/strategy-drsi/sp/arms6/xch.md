# q3-xch: does the exchange after a cancel have situational value? (2026-11-18)

The user asked why the arms differ so little (「為什麼不同打法帶來的優勢如此不顯著？」), then said 「好」 and 「繼續」. DUEL_AI_STRATEGY §11.37
(dmgsrc) found that ~70 % of the Reishi and the Konpaku come from combos opened inside a cancel exchange, while every arm of a table shares
one exchange unit (`:with`). Before building arms or rules that differ in the exchange, this batch measures whether conditioning the
exchange on the situation can beat the pairing's constant unit at all (§8.5's oracle test, one layer down). No arm built, nothing shipped.
Base: main abdd87e4. Seeds 1-500 only.

## Verdict

**Real headroom, and most of it in one cue: `own`, whether the J side's own J hit made the cancel.** On top of that there is a large
**constant** error in Kenpachi's KI exchange unit.

- **KI Kenpachi, J side.** The shipped unit always takes the AS (`:xch-j 0`). Per exchange decision (teacher's unit, explored decisions,
  bootstrap SE over matches):
  - holding instead is worth +0.19 (SE .02): a better flat unit;
  - the per-`own` rule (AS when his own J did not make the cancel, else hold) adds +0.058 (SE .011, cross-validated) over that flat
    hold.
- **The same cue recurs** on every J side measured: KH Kenpachi +0.044 (SE .009), KH Hisagi +0.036 (SE .006, short window; +0.018 (SE .017)
  on the long one). KI Ichigo shows none (-0.005, SE .017): Kenpachi's NS side watches only 65 % of the time, so Ichigo's AS wins or
  loses on a coin no cue predicts (below).
- **The NS side: the constant matters, the situation little.**
  - KI Kenpachi: always watch, never carry, is +0.080 (SE .007) over his shipped 0.65 / 0.2.
  - Every NS-side situational gain is under 2.5 SE (KH Hisagi `own` +0.026, SE .011).
- **Every other single cue is flat** on every side: my / his flash-step stake, red, the pointers, distance (but KH Kenpachi's +0.051,
  SE .013), the Konpaku lead, the forms (KH Kenpachi +0.049, SE .011), the clock.
  - The two crossings with `own` (x distance, x form) add nothing over `own` alone in KI.
  - In KH they reach +0.08: Kenpachi own x dist +.079 (SE .013), own x form +.086 (.013); Hisagi own x dist +.085 (.015). There his SA misses
    at range (below). Not tested at match level.

### Match level

`xch.py ab`: HARD vs HARD, seeds 301-500, both character orders, 400 matches an arm. The rule plays only on that character's J side;
everything else is shipped. `own`: the AS when `own0`, else hold. `ownj`: the AS when `own0`, else the J. The character's win rate (SE):

| pairing, character | shipped | hold | `own` | `ownj` |
|---|---|---|---|---|
| KI Kenpachi | .133 (.017) | .355 (.024) | **.995** (.004) | |
| KH Kenpachi | .255 (.022) | | .212 (.020) | **.477** (.025) |
| KH Hisagi | .745 (.022) | | .805 (.020) | **.980** (.007) |

- The local situational gain looks small next to KI's constant one, but it is the larger part of the match result: hold alone gives .355,
  the `own` rule .995. The `own0` AS is where the breaks come from.
- The `own1` option must be the pairing's own: hold in KI, the J in KH. KH Kenpachi with hold at `own1` is .212, worse than shipped.
- K.O. wins: all of KI's. KH Hisagi 297 / 319 / 391. KH Kenpachi 96 of his 102 wins shipped, 66 of 85 with `own`, 169 of 191 with `ownj`.
- The rule plays outside rollouts only. Playing it inside every CPU's rollouts too gave identical counts in all three rule rows: no rollout
  of the in-game MCTS reaches an exchange decision (0 hook calls in 2 matches), so the opponent's search would not see the change.

## Method

**Logging** (`tools/simgate/strat-run.lisp` `STRAT_XLOG="<salt> <eps> <seat>"`, a research-only hook `*cai-xch-hook*` in core-ai.lisp,
NIL in the game):
- Every CPU exchange decision outside rollouts is logged on the step CAI-XCH-STEP makes its rolls.
- The cues logged at the decision: both flash-steps, both pointers, both reds, both Konpaku, both Reishi, the distance, the side (J /
  NS), both forms, both awakenings, the match clock, the active arm, `own` (BRAIN-XOWN), the AS available / in reach, and the shipped
  unit's chances (pas / pj, pw / pc).
- The outcome is followed until both fighters are back in neutral (the exchange over, a cinematic, a reset; cap 900 ticks: 4.0 % of KI's
  records, 2.2 % of KH's) and summarised in these fields:
  - `dh`: the change of MC-FULL-HEALTH mine - his, the teacher's unit (Konpaku + 1.5 x the Reishi bar). The main Y.
  - `dhs`: the same, cut when the decision's own exchange key first changes (a fresh cancel or the end). The short window.
  - Konpaku net, Reishi net, flash-step net.
  - Who hit first.
  - Whether he started an SA before that hit.
- **Exploration.** With chance eps = 0.3 the exploring seat's option is replaced by one drawn uniformly from the side's legal ones:
  - J side: AS (when one is left), J, hold;
  - NS side: watch x carry.

  The draw comes from SR-FQ-U over (match seed, tick, side, salt) alone and is made after the shipped rolls, so the RNG stream is
  unchanged up to the decision.
- **One exploring seat a run**, so his answers are the shipped CPU's: four runs a pair ({a b, b a} x {seat 1, seat 2}) x seeds 1-500.
  - KI: 211,662 decisions logged.
  - KH: 264,447 decisions logged.
- **Play unchanged when off.** KI seeds 1-10: the gate rows, hash lines and every other line equal the base build's, with STRAT_XLOG
  unset and with eps 0 (only the `stats:` lines' cons / heap differ). Host tests 3768 ALL PASS, `--cvc` PASS (II 33, IK 20, KK 27 lines).

**Analysis** (`xch.py tab`):
- Only the explored decisions of the exploring seat estimate the options, so the comparison is randomised: the explored option is a
  hash coin, independent of the state.
- Per bin b and option o: m(b, o).
- The shipped unit's value V(b) = sum_o pi_b(o) m(b, o), with pi = its logged chances averaged over all of the bin's decisions.
- Two gains, weighted by the bins' shares:
  - `const` = the best flat option - V. A better constant unit; no situation needed.
  - `situ` = cross-validated. Each bin's best option is picked on odd seeds and scored on even seeds (and swapped), minus the best flat
    option picked and scored the same way. A bin keeps the flat option unless every option has >= 20 explored samples there. Only `situ`
    is situational value.
- SEs: 200 bootstrap resamples of matches (seed x character order).
- The match-level check (`xch.py ab`): strat-run.lisp `STRAT_XPOL="<seat> hold|own|ownj"` (with STRAT_XLOG at eps 0) makes that seat's
  CPU play the rule at every J-side decision, against the same seeds with no rule.
- Files:
  - tables: `xch/tab-{ki,kh}-{dh,dhs}.txt`;
  - the explored decisions: `xch/xch-{ki,kh}.tsv.gz`;
  - the match-level check: `xch/ab-*.txt`.

## The per-bin tables (Y = dh; mean (SE) n, him% = he hit first)

### KI

| side | bin (share) | AS | J | hold | shipped V |
|---|---|---|---|---|---|
| Kenpachi J | all | -.184 (.017) 2884, 78 % | -.116 (.014) 2798, 76 % | **+.009** (.012) 2893, 61 % | -.184 |
| | own0 (.17) | **+.084** (.047) 521, 12 % | -.192 (.047) 461, 79 % | -.257 (.042) 471, 66 % | +.084 |
| | own1 (.83) | -.243 (.017) 2363, 92 % | -.101 (.015) 2337, 75 % | **+.060** (.012) 2422, 60 % | -.243 |
| Ichigo J | all | **-.053** (.011) 2245, 47 % | -.057 (.011) 2408, 57 % | -.071 (.009) 2563, 86 % | -.053 |
| | own0 (.38) | **+.052** (.015) 878, 20 % | +.029 (.016) 980, 62 % | -.023 (.015) 1054, 74 % | +.052 |
| | own1 (.62) | -.120 (.014) 1367, 65 % | -.116 (.014) 1428, 53 % | **-.104** (.010) 1509, 94 % | -.120 |

| side | bin (share) | watch + carry | watch | carry | neither | shipped V |
|---|---|---|---|---|---|---|
| Kenpachi NS | all | +.055 (.012) 1776, 36 % | **+.114** (.014) 1746, 35 % | -.091 (.010) 1917, 80 % | -.091 (.009) 1992, 89 % | +.035 |
| | own0 (.64) | +.152 (.016) | **+.246** (.018) | -.096 (.013) | -.084 (.013) | +.118 |
| | own1 (.36) | -.124 (.020) | -.138 (.019) | **-.081** (.015) | -.103 (.013) | -.122 |
| Ichigo NS | all | +.216 (.016) 2016, 13 % | **+.238** (.019) 2005, 11 % | -.245 (.020) 1951, 95 % | -.242 (.019) 1978, 98 % | +.229 |

### KH

| side | bin (share) | AS | J | hold | shipped V |
|---|---|---|---|---|---|
| Kenpachi J | all | -.081 (.009) 4476, 66 % | **-.066** (.008) 4664, 85 % | -.079 (.007) 4683, 80 % | -.081 |
| | own0 (.18) | **+.077** (.016) 957, 7 % | -.149 (.017) 773, 93 % | -.156 (.014) 853, 94 % | +.054 |
| | own1 (.82) | -.124 (.010) 3519, 82 % | **-.050** (.009) 3891, 84 % | -.062 (.008) 3830, 77 % | -.124 |
| Hisagi J | all | **-.104** (.008) 3432, 64 % | -.134 (.009) 2278, 86 % | -.158 (.007) 3021, 90 % | -.114 |
| | own0 (.45) | **+.024** (.010) 1480, 32 % | -.092 (.013) 1002, 90 % | -.106 (.010) 1548, 90 % | -.012 |
| | own1 (.55) | -.202 (.010) 1952, 89 % | **-.168** (.012) 1276, 83 % | -.214 (.012) 1473, 89 % | -.191 |

| side | bin (share) | watch + carry | watch | carry | neither | shipped V |
|---|---|---|---|---|---|---|
| Kenpachi NS | all | **+.040** (.016) | +.030 (.015) | -.036 (.015) | -.050 (.015) | +.032 |
| Hisagi NS | all | +.036 (.010) | **+.049** (.010) | -.187 (.009) | -.209 (.008) | +.034 |
| | own0 (.68) | +.138 (.012) | **+.159** (.010) | -.226 (.012) | -.201 (.011) | +.136 |
| | own1 (.33) | -.169 (.017) | -.193 (.016) | **-.103** (.016) | -.221 (.013) | -.177 |

The full per-cue tables (12 single cues and 2 crossings, each side) are in `xch/tab-*.txt`.

## The gains (const / situ, SE)

| side | const, Y = dh | situ, `own`, dh | situ, `own`, dhs | best other single cue (dh) |
|---|---|---|---|---|
| KI Kenpachi J | **+.192 (.021)** | **+.058 (.011)** | **+.065 (.010)** | optr +.011 (.016) |
| KI Kenpachi NS | **+.080 (.007)** | +.003 (.017) | +.010 (.011) | form +.020 (.013) |
| KI Ichigo J | .000 (.009) | -.005 (.017) | -.005 (.006) | ptr +.028 (.016), form +.025 (.015) |
| KI Ichigo NS | +.009 (.008) | +.008 (.015) | -.004 (.010) | time +.016 (.023) |
| KH Kenpachi J | +.015 (.011) | **+.044 (.009)** | **+.028 (.011)** | dist +.051 (.013), form +.049 (.011) |
| KH Kenpachi NS | +.008 (.012) | +.027 (.023) | +.042 (.018) | mfs +.041 (.020) |
| KH Hisagi J | +.010 (.004) | +.018 (.017) | **+.036 (.006)** | none |
| KH Hisagi NS | +.015 (.006) | +.026 (.011) | +.005 (.008) | ownform +.037 (.012) |

Bold = past 2.5 SE. Two cautions:
- `dhs` cuts at the next cancel, so it undervalues an option whose value comes in the next exchange. KI Ichigo J's J looks +.07 better
  on `dhs` and equal on `dh`. `dh` is the reading for J.
- The per-decision gains are not additive per match: the long windows of a chain of cancels overlap. The match-level check is `ab`.

## Where his answer varies (the caveat, tested)

Against a fixed CPU the best response is pure, so a situational rule gains only where the opponent's answer varies by situation. Here it
does, through the NS side's SA timing rule (xch-ai.lisp XCH-SA-NOW-P):
- **His segment's hit made the cancel** (the J side's `own0`, his own-hit): he presses the SA a fixed *CAI-XCH-SA-WAIT* (4) frames after the
  cancel. The J side's AS starts later, and the later start wins.
  - KI Kenpachi's AS: Ichigo's SA comes first 81 % of the time, yet Ichigo hits first only 12 %.
  - KH Kenpachi: 95 % / 7 %. KH Hisagi: 32 % hit first.
- **The J side's own J made the cancel** (`own1`): he watches for the AS to start and answers it, BRAIN-DELAY later, and his SA is now the
  later start.
  - KI Kenpachi's AS: his SA 93 %, he hits first 92 %.
  - KH Kenpachi: 95 % / 82 %. KH Hisagi: 89 %.
- So it is not his roll that varies (Ichigo watches with chance 1.0, Hisagi .97) but whether his answer can win. The `own` flag tells the
  J side which case it is in, live and without reading him.
- **Distance** adds a little in KH: Kenpachi's AS beyond 2.5 m is hit first only 20 % of the time, against 74 % inside 1.5 m. His SA misses
  at range.
- **The KI Ichigo J side has no such cue.**
  - Joint table: Ichigo's AS against a Kenpachi who did not watch is +.083 (6 % hit first), against one who watched -.148 (71 %).
  - Kenpachi's watch is a .65 coin no state predicts, so Ichigo's options are about equal everywhere.

## dmgsrc's xch bucket split at the BREAK line (step 4)

`dmgsrc.py --split`, seeds 1-20 (`xch/dmgsrc-split-1-20.txt`):
- `brk` = the combo the breakthrough's hit opened.
- `scr` = a combo opened later in the still open exchange.

| pair | Reishi brk / scr / neu % | Konpaku brk / scr / neu % |
|---|---|---|
| KK | 93.6 / 1.4 / 5.0 | 94.3 / 3.4 / 2.4 |
| KI | 66.7 / 19.0 / 14.3 | 67.3 / 16.2 / 16.5 |
| KH | 66.3 / 4.4 / 29.3 | 70.6 / 5.5 / 23.8 |
| II | 36.3 / 13.2 / 50.4 | 37.6 / 6.2 / 56.2 |
| IH | 43.4 / 6.2 / 50.4 | 32.0 / 2.9 / 65.1 |
| HH | 64.0 / 10.0 / 25.9 | 66.9 / 3.1 / 30.0 |

The xch bucket is mostly the break hit's own combo: who wins the exchange gets the damage. The scramble after it is large only in KI (19 %).

## The two checks (step 5)

**1. Are the exchange keys read live at the exchange step?** Partly.
- CORE-BRAIN-STEP rebuilds BRAIN-NOW every step as `(cons arm (strat-feats ...))`. The keys (`:xch-j`, `:xch-sa-p`, `:xch-carry-p`,
  `:xch-sa-wait`, `:clash-margin`) are read through STRAT-OUT / STRAT-SCALE / STRAT-MUL on it when CAI-XCH-STEP rolls. So an arm's
  `:rules` would fire live on STRAT-FEATS' cues: `:dj :dn :do :lead :mr :or :ored :hoho :ost :wave :awk`.
- **The arm itself is stale.** It is the last judgement's pick: every 30 ticks, and only in neutral, so never inside an exchange.
- **The extra cues are judgement-only.** The xfeats (`:mcell :ocell`, the pointers, `:time`, `:xch` ...) are appended only inside
  STRAT-SWITCH-STEP's judgement.
- **The shipped units carry no rules.** Every `:d-x-*` unit is `:base` only, so the keys are constants.

**2. Does `:rb-sp2` have the cues a rule would need?**
- **It has some of them, for arm selection only:**
  - the flash-step: G3 `:mcell` x `:ocell`, cells 0-3;
  - his red: G0 `:ored`;
  - the pointers: G9 / G10;
  - my Reishi only as G7 `:mr` (low / high), not my red.
- **None of them reaches the exchange step:** they are not in STRAT-FEATS.
- **`own`, the one cue that matters, is in neither feature set.** It is the CPU's own move state (BRAIN-XOWN, set by CAI-XCH-NEW) and is
  read live at that step.
- So an `own`-keyed exchange needs STRAT-FEATS (or the exchange's own reads) to see it, a shared-file change (strategy-glue.lisp /
  core-ai.lisp). A table's arms and `:with` unit cannot express it.
- The constant part needs no new cue: KI Kenpachi's unit with the J side's AS off. There is no key for hold today, though.
  - `:xch-j` only moves the AS / J split, so even `:xch-j` at its maximum gives the J (-.116), not hold (+.009).
  - The one partial lever is `:clash-margin`: the J side holds when the AS is out of its reach + the margin, so a margin of 0 holds by
    distance only.
- What a lever would need, then: the exchange's J side choosing by `own` (the AS at `own0`; hold or the J at `own1`, by pairing), with the
  `own1` choice in the unit as data. That is a change to xch-ai.lisp / core-ai.lisp (shared files: every CPU's exchange), not to a table.

## What failed / caveats

- The local situational gain (+0.058) understates the match-level effect (.355 -> .995). The `own0` AS is a break opportunity, worth more
  over a match than its share of decisions suggests. Read `const` / `situ` as a ranking, the `ab` rows as the size.
- Local and match level can disagree: KH Kenpachi's `own` rule (hold at `own1`, locally -.062 against the AS's -.124) lost at match level
  (.255 -> .212). Its `ownj` (J at `own1`, locally -.050) won (.477). A rule from these tables needs its match-level check.
- The KH crossings (own x dist, own x form: +.08) were not tested at match level.
- Only KI and KH were measured; II, IH, HH and KK were not. Only HARD vs HARD.
- The `ab` rule runs against the opponent's shipped CPU, which does not adapt. A human, or an opponent whose NS side keyed its SA on the
  same flag, could punish an `own`-keyed AS; the per-bin tables only describe the best response to today's CPU.
- Nothing here was gated on 501-600 or 801-1000. The `ab` seeds 301-500 overlap the logging seeds (a different measurement: the rule was
  chosen on the per-bin tables of the same seeds, so a fresh block is needed before shipping anything).

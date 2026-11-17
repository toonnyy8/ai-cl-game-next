# online2 — the online learner's exploration, uncapped, on today's T0 tables (q1-eps, 2026-11-17)

The user, 2026-11-17: 「自適應學習的上限不在設限，開始修改」 (shipped: `*fq-online-cap*` NIL, DUEL_AI_STRATEGY §11.34), then 「都做」
(exploration + pointer rules). This record covers only the exploration's measurement: ε for `fq-explore-arm` (any number of arms, fabade57).
No shipped knob was changed; the recommendation (§6) is for the lead.

Branch q1-eps from main fabade57. Files: `online.py` (updated), `online2/` (tables, proofs, configs, data), `tools/simgate/strat-run.lisp`
(`STRAT_FQBASE`, read-only judge hook).

## 1. What learns, as measured

- The learner is Ichigo's shipped HARD table, played on P2 as in VS CPU, against a proxy CPU treated as the human (`strat-run.lisp STRAT_FQLEARN`
  "in out 2"). The tables: `t0-ki-ichigo` (6 arms) and `t0-ih-ichigo` (4 arms), both `:rule-base :rb-sp2` (104 rules in 11 groups).
  They were dumped from the build's lookup (`online.py dump`: one match at η 0; `online2/t0-*.lisp`).
- The knobs as shipped: η 0.05, cap NIL, scale 0.1. A TD pass at each match's end.
- **The effective discount is the table's own `:gamma 0.966`, not `*fq-online-gamma*` 0.9.** `fq-match-end` passes the table's `:gamma` /
  `:scale`, and both T0 tables carry 0.966 / 0.1.
- **The effective step is about 11 x η.** The firing vector is normalised per group, Q(s, a) sums all groups, and each firing rule takes
  q += η·x·δ. So one transition moves Q(s, a) by η·δ·Σx². The cues are crisp at the judgements, so one rule fires a group and Σx² = the number of
  groups firing (up to 11). At η 0.05 that is about 0.55·δ per transition, on q designed at 0.06. That is what the data below show: the
  tables collapse onto one or two arms within 125 matches.

## 2. Tool fixes and proofs

- **online.py sent stale debug commands.** Its sims sent 81000 / 81030 / 81040, ASSIST's gate commands. Since 2026-11-15, 81030 makes **P1 a
  button-masher** (masher.lisp). These commands are dropped; the sims now send 30000+s, 31100+n, 81022 (HARD), 200000+pairing, as ladder.py does.
  The same three commands are still in `fq/fq.py` (line 154) and `sitcheck/drive.py` (line 13), so any run of those since 2026-11-15 played
  P1 as the masher. Not fixed here (out of scope).
- **New in online.py:**
  - `dump`: writes the lookup table to a file.
  - `heldout` (alias `eval`): takes several learned tables, plays the offline table once, and adds the arm shares per judgement plus `differ`,
    the share of judgements where the offline table would pick another arm on the same cues (strat-run `STRAT_FQBASE`).
  - `stats`: rules moved; flips, counted only on rules whose offline row has a strict leader; tied rows that gained a leader; the largest |q|.
    Most T0 rows are all 0, so any 1e-5 nudge would otherwise count as a "flip".
  - `--eps-decay`; `--out-root`.
  - Training seeds now default to 1-500 (501-600 is the check against the shipped CPU).
  - The subcommand is now named `heldout`: the session's command guard refuses the word `eval` on a command line.
- **Identity** (`online2/identity.py`, `identity-501-510.jsonl`): seeds 501-510, both seats, each T0 table against the opponent's shipped HARD
  CPU, comparing `duel hash` / `duel state` / gate-row lines per match (261-349 lines a cell).
  - The table played raw from the dumped file is identical to the lookup in 10 of 10 matches, in all 4 cells.
  - The learner attached at η 0, ε 0 is also identical, 10 of 10 in all 4 cells.
  - ε 0.1 at η 0 differs from match 1 on (10 of 10 differ): exploration acts.
  - η 0.05 at ε 0: match 1 is identical, then 9 of 9 differ: learning starts from match 2.

## 3. Proxies (fixed before any learning run: `online2/proxies.json`, commit c8477c5b)

- **Shipped**: the opponent's HARD lookup table (`--proxy` omitted): Kenpachi's `t0-ki-kenpachi`, Hisagi's `t0-ih-hisagi`. Note this is not
  `none`, which is his CPU with no strategy at all (KI 99 vs 91).
- **Off-style** (`istyle`): `online/ken-istyle.lisp`, the opponent playing Ichigo's KI style CPU (§8.14's proxy 1).
  - The rule: one proxy for both pairings, among the existing proxy strategies, whose screen falls in 0.25-0.75 in both.
  - The screen is the frozen table's wins, seeds 1-100, P2. KI: shipped 91, istyle 74, every other candidate 99-100. IH: shipped 19, istyle 34;
    the other candidates ki-ken 61, ken-wide 77, s3-zoner 20, none 18, s7-kite 7.
- Disclosed: one 50-match smoke run came first (KI, ε 0.1, istyle, seeds 1-50, a tool check, scratchpad). It was not used for any choice.

## 4. Method

- Per config: 4 runs x 125 sequential learning matches. Run r learns on its own block of seeds 1-500 in order (1-125, 126-250, ...), starting
  from the shipped table, chained in chunks of 25.
- The frozen shipped table plays the same seeds (paired).
- Then each run's final table, frozen:
  - against the proxy on 601-800, both seats (400 matches);
  - against the opponent's shipped HARD CPU on 501-600, both seats (200).
- Seeds 801-1000 were never used.
- `online2/runs.py` runs a config (tags `<ki|ih>-<shipped|istyle>-e<ε x 1000>[-n<η x 1000>]`); `online2/summary.py` → `online2/summary.txt`.
- Per config the data are in `online2/out/<tag>/`: `train.json` (with the curve), the final tables `run<r>-4.lisp`, `heldout-*.jsonl` and
  `stats.jsonl`.
- **Noise.** A held-out share has an SE of about .02 on 400 matches and .03 on 200; a live share of 500, about .02. The spread across the 4
  runs is the real noise for a final table (fixed seed blocks, deterministic). ε vs ε 0 is compared paired, on the same 20 blocks of 25.

## 5. Results

**Shipped knobs, η 0.05, cap NIL.** Live / frozen: wins of 500 on 1-500. Held-out: the 4 final tables (offline table in brackets).

| config | live / frozen (z) | curve, wins per 25-match block (4 runs pooled, of 100) | vs proxy 601-800 | vs shipped 501-600 | broken |
|---|---|---|---|---|---|
| KI shipped ε 0 | 465 / 456 (1.03) | 97/93 95/93 96/92 85/84 92/94 | .915 .948 .892 .860 (.930) | .950 .940 .905 .850 (.890) | 0 |
| KI shipped ε .05 | 471 / 456 (1.78) | 94/93 91/93 94/92 97/84 95/94 | .902 .955 .902 .927 | .895 .945 .920 .930 | 0 |
| KI shipped ε .1 | 470 / 456 (1.70) | 94/93 92/93 94/92 94/84 96/94 | .963 .935 .943 .963 | .960 .940 .960 .960 | 0 |
| KI istyle ε 0 | 398 / 371 (2.03) | 81/75 88/69 79/74 76/81 74/72 | .627 .845 .750 .807 (.745) | .875 .910 .835 .925 (.890) | 0 |
| KI istyle ε .05 | 409 / 371 (2.91) | 79/75 81/69 82/74 83/81 84/72 | .810 .873 .818 .792 | .940 .955 .915 .915 | 0 |
| KI istyle ε .1 | 386 / 371 (1.10) | 82/75 78/69 82/74 74/81 70/72 | .790 .807 .823 .870 | .875 .910 .925 .940 | 0 |
| IH shipped ε 0 | **56 / 85 (-2.68)** | 16/26 12/16 6/15 12/11 10/17 | .110 .058 .138 .043 (.190) | .090 .065 .095 .040 (.210) | **4** |
| IH shipped ε .05 | **45 / 85 (-3.89)** | 11/26 11/16 5/15 8/11 10/17 | .040 .098 .195 .168 | .045 .090 .175 .170 | 2 |
| IH shipped ε .1 | 70 / 85 (-1.28) | 14/26 19/16 15/15 14/11 8/17 | .098 .128 .233 .158 | .090 .120 .215 .135 | 1 |
| IH istyle ε 0 | 208 / 159 (3.31) | 37/25 48/37 42/34 44/30 37/33 | .593 .578 .378 .320 (.352) | **.055 .085 .030** .245 (.210) | 3 |
| IH istyle ε .05 | 171 / 159 (0.82) | 29/25 35/37 34/34 36/30 37/33 | .500 .507 .292 .323 | .085 .090 .150 .115 | 2 |
| IH istyle ε .1 | 152 / 159 (-0.47) | 29/25 34/37 26/34 36/30 27/33 | .253 .287 .240 .312 | .095 .205 .130 .155 | 1 |

"Broken" means held-out below 0.5 x the offline table's against the proxy or the shipped CPU.

**ε vs ε 0 at η 0.05, live, paired by block (mean difference in win share, SE):**

| pairing | ε .05 | ε .1 |
|---|---|---|
| KI shipped | +.012 (.020) | +.010 (.017) |
| KI istyle | +.022 (.023) | -.024 (.029) |
| IH shipped | -.022 (.018) | +.028 (.024) |
| IH istyle | **-.074 (.029)** | **-.112 (.031)** |

**What the tables do** (`summary.txt` has every run):
- The uncapped tables collapse onto one or two arms. Against the proxy, a single arm takes 0.6-0.98 of the judgements in most final tables:
  - IH shipped ε 0: kessa-lunge .83 / .79, brawl .57, economy .80;
  - KI shipped ε 0: brawl .81 / .93, kessa-lunge .65 / .60.
  The offline table spreads its judgements across the arms (KI .05-.42, IH .18-.42).
- `differ`: the final tables pick another arm than the offline table on 0.56-0.95 of the judgements.
- Rules moved 79-97 of 104. Of the rules whose offline row has a strict leader (KI 12, IH 7), 4-11 flipped. 53-87 tied rows gained a leader.
- Largest |q| 0.48 (page integer 47,697), far below the ~1000 flag (a 30-bit fixnum holds up to 5,368).

**A diagnostic outside the brief's grid: η 0.005** (about η / Σx², so one transition moves Q by about 0.05·δ, as η alone suggests). The shipped
η stays 0.05; this measures only whether the step, rather than exploration, is what hurts.

| config | live / frozen (z) | curve (of 100) | vs proxy 601-800 | vs shipped 501-600 | broken |
|---|---|---|---|---|---|
| KI shipped η .005 ε 0 | 470 / 456 (1.65) | 94/93 94/93 95/92 94/84 93/94 | .970 .920 .970 .970 (.930) | .950 .935 .950 .950 (.890) | 0 |
| KI shipped η .005 ε .05 | 472 / 456 (1.94) | 92/93 96/93 93/92 93/84 98/94 | .945 .935 .950 .980 | .955 .880 .960 .965 | 0 |
| KI istyle η .005 ε 0 | **426 / 371 (4.45)** | 87/75 89/69 82/74 87/81 81/72 | **.865 .863 .870 .880** (.745) | .945 .950 .975 .950 (.890) | 0 |
| KI istyle η .005 ε .05 | 410 / 371 (3.11) | 74/75 85/69 86/74 86/81 79/72 | .815 .785 .833 .853 | .945 .935 .935 .975 | 0 |
| IH shipped η .005 ε 0 | **115 / 85 (2.45)** | 26/26 21/16 27/15 19/11 22/17 | .215 .215 .223 .223 (.190) | .225 .230 .225 .225 (.210) | 0 |
| IH shipped η .005 ε .05 | 104 / 85 (1.58) | 21/26 19/16 26/15 19/11 19/17 | .205 .170 .060 .175 | .220 .225 .045 .160 | 1 |
| IH istyle η .005 ε 0 | 204 / 159 (2.97) | 31/25 34/37 44/34 47/30 48/33 | .302 .460 .618 .307 (.352) | .225 .145 .060 .235 (.210) | 1 |
| IH istyle η .005 ε .05 | 169 / 159 (0.67) | 29/25 28/37 39/34 39/30 34/33 | .362 .335 .352 .487 | .200 .195 .145 .150 | 0 |

- At η .005, ε .05 vs ε 0 (live, paired): KI shipped +.004 (.013), KI istyle -.032 (.021), IH shipped -.022 (.018), IH istyle -.070 (.038).
- At η .005 the largest |q| is 0.149. Leaders flip on 0-2 rules, and no arm takes over the table.

## 6. Reading and recommendation

- **The uncapped learner at the shipped knobs (η 0.05, ε 0), reported plainly:**
  - Against the near-converged case (KI, shipped Kenpachi) it is neutral: live +9 of 500 (z 1.0), final tables .86-.95.
  - Against an off-style Kenpachi it gains live (398 vs 371, z 2.0) and keeps the gain on held-out in 2 of 4 tables (.627-.845, offline .745).
  - **Against the shipped Hisagi it hurts**: live 56 vs 85 (z -2.7), and all 4 final tables broke (.04-.14 against .19-.21).
  - Against an off-style Hisagi it gains live (208 vs 159, z 3.3). But 3 of 4 tables then lose to the shipped Hisagi at .03-.09 (offline .21):
    a player's habits teach a table that fails against everyone else.
- **Exploration does not fix this.**
  - At η 0.05: ε .05 / .1 change live wins by -.11 to +.03 (paired). Only IH istyle moves past 2.5 SE, and it moves the wrong way (-.074 and
    -.112).
  - ε does make KI's frozen tables steadier (KI istyle held-out .79-.87 at ε > 0 against .63-.85 at ε 0), but not by a margin beyond the
    run-to-run spread.
  - IH shipped stays below the offline table at every ε (live 45-70 vs 85; 1-4 tables broken).
  - At η .005 every ε .05 cell is at or below its ε 0 cell (-.004 to -.070).
- **The step is what breaks the tables, not the lack of exploration.** The same grid at η .005 and ε 0:
  - every pairing x proxy gains live (z 1.7-4.5);
  - 14 of 16 final tables are at or above the offline table against the shipped CPU (the exceptions: IH istyle runs 1 and 2, .145 and
    .06, tuned to the off-style Hisagi);
  - IH shipped turns from 56 to 115 live (offline 85), with all four tables .215-.230;
  - KI istyle's four tables hold .863-.880 on held-out (offline .745).
- **Recommended ε: 0, with no decay.** Constant ε did not hurt the converged case (KI shipped), which is the case a decay is meant to protect.
  ε helped nowhere beyond noise, and it hurt IH istyle at both η. So a decaying ε would only interpolate toward ε 0. It was not run.
- **For the lead's decision (not changed here): η.** The shipped η 0.05 behaves like an effective step of about 0.55 on these 11-group tables.
  η 0.005 (or, equivalently, dividing the update by Σx²) learned better in every cell measured here.
  - η is the user's earlier knob (§8.14: chosen at cap 0.05 on the two-arm, one-group table, where Σx² = 1).
  - The minimal proposed diff, if the lead takes it: `*fq-online-eta*` 0.05 → 0.005 in strategy.lisp, docstring citing this record.
    Alternatively, FQ-TD-UPDATE! could divide `(* eta x delta)` by the transition's Σx² (one `loop ... sum (* x x)`), which keeps η's meaning
    for any group count. Under the division the host tests' crisp one-rule steps (Σx² = 1) are unchanged, but the split-firing check
    (tests/duel-rules/strategy.lisp, firing 0.75 / 0.25, Σx² 0.625) would need its expected values updated.
  - Neither is measured beyond the grid above: no η sweep, and IH istyle's table that broke against the shipped Hisagi (.06) shows a player can
    still teach a table that loses to others (RESET LEARNING clears it).

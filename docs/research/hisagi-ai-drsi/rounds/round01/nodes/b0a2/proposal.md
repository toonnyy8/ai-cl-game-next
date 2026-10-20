# b0a2 (round 1, §25.15 freeze, a refine of b0a1): 輪 RINNE, the chain's wheel, and 花 HANA, the user's showpiece (§25.16)

Cell b0a2, round 1, freeze 3686d94. Branch b0's primary style: the Shikai chain (鎖鐮連段). PARENT_DIR b0a1 (0.7945): its
`hisagi.lisp` copied over the frozen one and its HISAGI-CPU-TESTS section spliced in, then refined. Everything is in
`duel/lisp/hisagi.lisp`'s CPU parts and the host test's `HISAGI-CPU-TESTS` section. This cell researches DUEL_HISAGI §25.16:
the user's showpiece combo 「J1 J2 J3 > L > K1 K2 > J3 > L > K1 K2 K3」 and its SP versions (「將中段或結尾換成 SP」).

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`)

| | baseline | b0a1 (parent) | **b0a2 (this file)** |
|---|---|---|---|
| **score** | 0.0 (raw 0.4149) | 0.7945 | **0.8203** (raw 0.8203) |
| strength (HARD, 480) | 0.006 | 0.498 | **0.552** |
| masher (HARD, 224) | 0.188 | 1.000 | **1.000** |
| signature | 0.751 | 0.890 | **0.909** |
| sig_by chain / ranged / bind | 0.373 / 0.204 / 0.174 | 0.881 / 0.005 / 0.004 | **0.901 / 0.005 / 0.004** |
| plain J / Kikons / counter / Breaker | 0.111 / 0.063 / 0.037 / 0.038 | 0.069 / 0.023 / 0.012 / 0.006 | 0.065 / 0.011 / 0.011 / 0.005 |
| NORMAL share (factor) | 0.104 (0) | 0.5271 (1) | **0.5271 (1)**: b0a1's to the match (Y 48, K 26, R 48, I 42, S 64, Lille 25 of 80) |
| pacing (NORMAL medians, all 240 K.O.) | 115-175 s | 104.2-157.8 s | **104.2-157.8 s** (identical: NORMAL plays b0a1's CPU) |

`score.json` holds the exact JSON line. HARD wins by opponent (seeds 1-40, both seats, of 80; the diagnostic runner, which
matches aieval's strength to the match): this file Y 67, K 17, R 68, I 40, S 73, Lille 0 (265 / 480); the same build with
the plan off (b0a1's play, another RNG stream) Y 55, K 13, R 62, I 30, S 73, Lille 0 (233 / 480).

Host tests: duel-rules 9870 checks ALL PASS (the frozen 9865 + 5 in the section: b0a1's 4 + 1 here; one existing host call
of HS-AI-MOVE now binds the plan chance to 0, since the host has no sim stream). Splicing this file's section into the
frozen file (`splice-tests.py`) gives the delivered `duel-rules-test.lisp` byte for byte. control 89, learn 131, input 33,
cine 18 ALL PASS; touch 64, 0 failures. `tools/pkgcheck.sh duel`: clean.

## History read, and what it says

| cell | mechanism | rescored | lesson used here |
|---|---|---|---|
| baseline | awoke at once; SAHARAI spam; the dead windmill string | 0.0 | — |
| prior b0a0-b3a0 (§25.12) | RENSA / KARIBA, the bridge K at f9, the reaping fence, the ranged fence, the late awakening | 0.637-0.766 | the Shikai is his strength |
| round01 b0a0 | prior b3a0 ported + KAZAGURUMA-GAESHI + TODOME | 0.783 | the chain is the score; ranged / bind 1 % |
| round01 b1a0 / b1a1 | the ranged routes (tip styles, then the waiting chain), gate 2000 | 0.7517 / 0.7741 | the Bankai's themes show, for HARD and signature |
| round01 b2a0 | the bind first, gate 3000, the SAHARAI cancel bug | 0.7855 | the gate is strength-neutral; NORMAL rides the heal |
| round01 b3a0 | b0a0 + b1a0's routes, gate 3000, the waking noose, the ledger | 0.785 | the reap proof costs at this freeze (b0a1) |
| round01 b0a1 (parent) | MIKIRI (the Hoho read) + TSUME (the close-in) | 0.7945 | the round's best; every cell sat at 0.75-0.79 |

Every earlier cell worked on the neutral (when to open, from where) or on the Bankai. None looked at what a confirmed hit is
turned into. That is where this cell went.

## The diagnosis (HARD, 120 and 480 matches of b0a1's file, the combat log; scripts in the cell's scratch)

His combos grouped hit by hit (`combos.py`: his hits <= 60 f apart, none of the opponent's in between):
- **The conversions stop at one K string.** The top routes were K1 K2 K3 (601 of 7122 combos), K1 K2 K3 RAIDEN (567),
  J1 L K1 K2 K3 RAIDEN (543), K1 K2 (355, 289 of them burst), J1 K2J K3 RAIDEN (321).
- **The leap and the second K string almost never came.** The leap rolled only off K1 / K2 with his intent close, so 2 % of
  his combos had one; a second windmill string after it, 1 %. **The user's full showpiece: 0 of 7122.**
- **The signature counts written damage** (aieval: each hit's base damage, before the combo decay of 10 % a hit after the
  third, floor 40 %). A K tail past the decay still counts in full for the signature, and still deals 40-60 % for the win.
- **The SP middle can't restart the string.** RAIDEN's hit paralyses 40 f; he guard-cancels it at f36, but out of a guard
  cancel no attack starts before the cancelled move's recovery would have ended (FIGHTER-GC-LEFT, f47). K1 (S 18) from f47
  lands 5 f after the paralysis: a frame trap, not a combo. Built (綴返 TSUZURI-GAESHI) and dropped (below).

## The styles and the mix (the 行動方針)

| layer | roll | styles, chances (EASY / NORMAL / HARD) |
|---|---|---|
| the Shikai's chain style (b0a0's) | once a match (HS-AI-STYLE) | RENSA 連鎖 55 % / KARIBA 刈場 45 % |
| MIKIRI / TSUME (b0a1's) | the Hoho read, per event | unchanged |
| **the combo's route plan (new)** | **once per combo, at its first J1 / K1 hit** (HS-AI-PLAN, SIM-RND01) | a plan 0 / 0 / 1.0; then **輪 RINNE 80 %**, **輪止 RINNE-OWARI 10 %**, **花 HANA 10 %** |
| per hit (b0a0's) | once per event | TODOME (a red victim's link 2 into RAIDEN) first; the SP ender off K3 |
| the Bankai / the bind (b0a0's last stand at 4500 taken) | per entry / change event | unchanged |

A plan is a route of (HEAD MIDDLE END), `*HS-AI-PLAN-ROUTES*`:
- **HEAD**, after J1's hit: `:jjj` J2, J3, then the windmill bridge (L); `:j` the bridge at once.
- **MIDDLE**, after the first K string's K2: `:leap` the leap J3K (the combo's one leap), then the bridge again; `:sp` RAIDEN.
- **END**, after the last K string's K2: `:k3` K3 (then the SP ender, RAIDEN with a bar); `:sp` RAIDEN.
- A K1 opener (the reap, the punish, a windmill sweep) plays its plan from the middle.

| plan | route | what a human sees |
|---|---|---|
| **輪 RINNE, the chain's wheel** (80 %) | J1 > L > K1 K2 > J3K > L > K1 K2 K3 (> RAIDEN) | the showpiece from J1 alone: the sickle flick, the windmill, the long chain reaps twice, he leaps back in on the chain, the windmill again, the full K string, lightning. From a reap: K1 K2 > leap > L > K1 K2 K3. |
| **輪止 RINNE-OWARI** (10 %) | J1 > L > K1 K2 > J3K > L > K1 K2 > RAIDEN | the same wheel, its end cut short into the lightning (the user's 「結尾換成 SP」) |
| **花 HANA, the user's showpiece** (10 %) | J1 J2 J3 > L > K1 K2 > J3K > L > K1 K2 K3 (> RAIDEN) | exactly §25.16's: the three sickle spins, the windmill, the chain, the leap, the windmill, the full chain |

**Each plan forced** (HARD, seeds 1-40 both seats, 480 matches, plan chance 1.0; wins / signature / the proxy 0.3 str + 0.5
sig). Different plans draw different random streams, so ±0.023 strength is noise:

| variant | wins | signature | proxy | verdict |
|---|---|---|---|---|
| no plan (b0a1's play) | 233 | 0.890 | 0.5906 | the reference |
| **RINNE** | **254** | **0.922** | **0.6197** | the best |
| RINNE, its end an SP (RINNE-OWARI) | 251 | 0.913 | 0.6134 | ≈ RINNE |
| RINNE, plan chance 0.9 | 247 | 0.921 | 0.6146 | 1.0 kept |
| HANA (the user's, J1 J2 J3 head) | 237 | 0.818 | 0.5571 | strength-neutral, signature −0.07: the J1 J2 J3 head is plain J (98 written) and starts the decay three hits early |
| TSUZURI (J1 > L > K1 K2 > RAIDEN, the SP middle) | 203 | 0.884 | 0.5690 | short and full-scale, but the string stops at hit 5 |
| RINNE 85 / HANA 15 | 248 | 0.907 | 0.6083 | |
| RINNE 70 / HANA 15 / TSUZURI 15 | 251 | 0.901 | 0.6074 | |
| **the shipped mix: RINNE 80 / OWARI 10 / HANA 10** (aieval) | **265** | **0.909** | 0.6203 | kept |
| (10 seeds, 120 matches) HANA-SP (J1 J2 J3 > L > K1 K2 > RAIDEN) / HANA-OWARI | 45 / 59 of 120 | 0.747 / 0.795 | | the SP versions of the full showpiece: dropped |
| 綴返 TSUZURI-GAESHI, RAIDEN's paralysis restarted with K1 (or J1 within 1.7 m), no plan | 231 | 0.889 | 0.5891 | dropped: the K1 restart is a frame trap by the rules (above); the J1 restart is neutral. Its code is removed |

**The research answer on §25.16** (measured, HARD): the showpiece's back half is the strongest route he has. Two windmill K
strings joined by the leap, written 534 with the ender, decayed 348, against 303 for J1 L K1 K2 K3 RAIDEN. The front half,
J1 J2 J3, is the cost. It adds 68 written plain-J damage per combo and makes the K strings hit at 40-80 % instead of
80-100 %: signature 0.818 forced, strength unchanged. The SP versions are short and hit hard per bar: RAIDEN at hit 3-6
deals 66-110, against 44 as the ender of an 11-hit string. But they give up the second K string, and they measured weaker.
The user's 「中段換成 SP」 can't bridge into a second string, because a guard-cancelled RAIDEN frees him only at f47
(FIGHTER-GC-LEFT). So he plays the wheel, and the user's exact showpiece one combo in ten, for the look.

**NORMAL and EASY take no plan** (0 / 0). With NORMAL at 0.3 the NORMAL share went 0.527 → 0.642 (factor 0.72, score
0.5924). At 0 no roll is drawn, so NORMAL plays b0a1's CPU to the match: the same NORMAL share, the same pacing, and the same
awaken A/B.

### What a human notices

- He still opens as b0a1's chain kusarigama: RENSA's step-in J1 or KARIBA's reap at 3-6 m, and MIKIRI's walk-in against a
  Hoho-er.
- **Once anything lands at HARD, the chain goes round twice.** The sickle flick, the windmill, the sideways chain and the saw.
  Then he leaps in along the chain with the full spin, the windmill comes up again, and the whole K string ends in the
  plunge and the lightning. A sweep that lands from range does the same from its K2: the leap, the windmill, the string.
- One combo in ten opens with the three sickle spins first: §25.16's showpiece, as written.
- One combo in ten cuts the second string short into the lightning.
- His Kikons are half as frequent (0.023 → 0.011 of his damage): the wheel's K strings end in RAIDEN, not on a red
  victim's link 3. (A red victim's J3K, the leap, still forces the generic O ender: 12 times in 480 matches.)
- At NORMAL and EASY he plays as b0a1.

**What sets it apart from the earlier cells:**
- It is the first cell that plans the whole combo, not the next link. The plan is rolled once at the opener, so the second
  windmill string and the leap come as one decision.
- It is the first to build and measure the user's showpiece and its SP versions.
- It is the first to move the conversion, not the neutral. The neutral is b0a1's, unchanged.

## Mechanisms implemented (CPU parts only)

- **New functions:**
  - pure, host-tested: HS-PLAN-NEXT (route, link, K strings so far, leapt, bars → the command);
  - HS-AI-PLAN (the combo's plan: cleared by a new combo, which is the victim's combo hits not above the last link hit's, or
    90 f since it; rolled at its first J1 / K1 hit; a K1 hit counts a K string);
  - HS-AI-PLAN-CMD (the plan's command when the kit allows it now: the string's link, the bridge with the sickle in and L's
    own checks, RAIDEN with its bar; else the style's per-hit pick).
- **Changed:**
  - HS-AI-MOVE: TODOME first, then the plan, then b0a0's per-hit picks.
  - The `*HS-AI-STYLES*` docstring now names the plan.
- **New knobs:** `*HS-AI-PLAN-ROUTES*` (RINNE, RINNE-OWARI, HANA, HANA-SP, HANA-OWARI, TSUZURI), `*HS-AI-PLANS*` (0.8 / 0.1 /
  0.1), `*HS-AI-PLAN-P*` (0 / 0 / 1.0).
- **New HSS CPU slots:** `ai-plan`, `ai-plan-k`, `ai-plan-hits`, `ai-plan-t`. None is hashed.
- **Pacing counters:** `plan-rinne`, `plan-rinne-owari`, `plan-hana`, `plan-other`, `ai-plan-sp`; `ai-bridge` also counts the
  plan's bridges. HARD, 480 matches: 5055 RINNE, 663 OWARI and 655 HANA plans; 60 full showpieces ending in RAIDEN and 20
  without it; RINNE's full wheel with RAIDEN 489 times.
- **Not touched:**
  - HS-AI-OPP and its knobs;
  - every move, rule and hook for a human, and the art;
  - HS-HASH and the sim ticks;
  - every other file except the test section;
  - the awakening: still the kit gate `:awaken (:min-taken 4500)` through AI-AWAKEN-P.
- **Kept working:**
  - The learner's clock: the plan acts only on his own link hits, in the :move-reflex, never in a free step.
  - The ASSIST: HS-AI-MOVE reads the brain it is given, so a HARD ASSIST plays the plan too.
  - The debug modes 83000-83999 and the `duel hisagi` line.
- **The rolls:** the plan chance is an (:easy :normal :hard) plist with EASY ≤ NORMAL ≤ HARD (host-pinned). It is rolled once
  per combo; a chance of 0 draws no roll.

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, NORMAL, 60 seeds; pairs 28 29 30 31 32 34)

NORMAL draws no roll and takes no plan, so the never-awaken side is b0a1's NORMAL CPU to the match.

Re-run at seed0 100: HY 39, HK 21, HR 35, HI 26, HS 52, HB 32 of 60. These are b0a1's numbers exactly; every match is a K.O.
and the medians are 103.4-149.3 s.

The 300 / 500 streams are b0a1's by construction:

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 300 | 30 | 23 | 40 | 28 | 48 | 22 |
| 500 | 30 | 22 | 36 | 34 | 49 | 25 |

Every row is at least 21 of 60: it passes (the bar is 20). The baseline fails every row (0-4).

## Expected benefit and risks

**Benefit:**
- 0.7945 → 0.8203, the search's best so far.
- HARD strength 0.498 → 0.552: Yamamoto, Rukia, Ichigo and Kenpachi all up; Senjumaru the same.
- Signature 0.890 → 0.909. The second K string is all chain: written damage per match 3752 → 4341, decayed 3336 → 3356.
- NORMAL, pacing and the A/B are unchanged from b0a1.

**Risks:**
- **The 40-seed noise is about ±0.02.** The forced runs agree, though: RINNE 254, the mix 265, no plan 233 of 480.
- **Burst windows.** A longer combo gives a Burst more hits to wait for. 35 % of his combos end in the opponent's Burst,
  against b0a1's 32 %; most of them at J1 L (309 of 452; b0a1 168 of 231). The plan bridges every J1, where KARIBA used to
  take K2J.
- **Lille stays 0 of 80 at HARD.** The plan converts hits, and she gives none.
- **The ranged and bind themes stay about 1 %:** b0a0's last stand.
- **Pacing:** the longest NORMAL median is 157.8 s (cap 220): no risk.
- **HANA's 10 % costs about 0.007 of signature** (the forced run's −0.07 × 0.1). It is kept as the user's showpiece.

## Shared-code recommendations (not built)

- **FIGHTER-GC-LEFT** (no attack out of a guard cancel before the recovery's end) makes every SP's hitstun past its recovery
  a frame trap. Hisagi's RAIDEN paralyses 40 f with R 24. If the user wants 「中段換成 SP」 to bridge into a second string,
  that is a rules choice (a shorter RAIDEN recovery, or a longer paralysis), not a CPU one.
- **ai.lisp's forced O ender on a red victim** fires off the leap J3K too, because it is an :ender. A kit say in it would
  let the wheel's red window end in RAIDEN (b0a0's note, standing).
- (Standing) AI-AWAKEN-P is one gate for every difficulty; the kit's `:hoho` is one number for every difficulty.

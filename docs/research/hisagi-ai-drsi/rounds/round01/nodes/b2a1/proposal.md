# b2a1 (round 1, §25.15 freeze, a refine of b2a0): 絞首 KOSHU, the bind as a race to the red, under round01 b0a2's Shikai

Cell b2a1, round 1, freeze 3686d94. Branch b2's primary style: the bind (捆綁). PARENT_DIR b2a0 (0.7855): its `hisagi.lisp`
copied over the frozen one and its HISAGI-CPU-TESTS section spliced in, then refined. Everything is in
`duel/lisp/hisagi.lisp`'s CPU parts and the host test's `HISAGI-CPU-TESTS` section.

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`)

| | baseline | b2a0 (parent) | b0a2 (round best) | v1: b0a2's Shikai merged under b2a0 | **b2a1 (this file)** |
|---|---|---|---|---|---|
| **score** | 0.0 (raw 0.4149) | 0.7855 | 0.8203 | 0.8109 | **0.8229** |
| strength (HARD, 480) | 0.006 | 0.458 | 0.552 | 0.533 | **0.565** |
| masher (HARD, 224) | 0.188 | 1.000 | 1.000 | 0.996 | **1.000** |
| signature | 0.751 | 0.896 | 0.909 | 0.904 | **0.907** |
| sig_by chain / ranged / bind | 0.373 / 0.204 / 0.174 | 0.777 / 0.066 / 0.053 | 0.901 / 0.005 / 0.004 | 0.818 / 0.046 / 0.040 | **0.812 / 0.046 / 0.049** |
| plain J / counter / Kikons / Breaker | 0.111 / 0.037 / 0.063 / 0.038 | 0.054 / 0.018 / 0.027 / 0.005 | 0.065 / 0.011 / 0.011 / 0.005 | 0.061 / 0.015 / 0.014 / 0.006 | **0.060 / 0.015 / 0.012 / 0.005** |
| NORMAL share (factor) | 0.104 (0) | 0.454 (1) | 0.527 (1) | 0.460 (1) | **0.475 (1): Y 53, K 21, R 25, I 37, S 64, Lille 28 of 80** |
| pacing (NORMAL medians, all 240 K.O.) | 115-175 s | 110.7-162.1 s | 104.2-157.8 s | 110.7-162.1 s | **110.7-162.5 s (Lille 162.5, Rukia 162.2)** |

`score.json` holds the exact JSON line of the final file. The same CPU before a comment-only pass measured the same line to
the digit (the evaluator is deterministic).

Host tests: duel-rules **9876 checks ALL PASS** (the frozen 9865 + 11 in the section: b2a0's 6 and b0a2's 3 merged, +2 here;
splicing this file's section into the frozen file with `splice-tests.py` gives the delivered `duel-rules-test.lisp`); control
89, learn 131, input 33, cine 18 ALL PASS; touch 64, 0 failures; `tools/pkgcheck.sh duel` clean.

## History read, and what it says

| cell | mechanism | rescored | lesson used here |
|---|---|---|---|
| baseline | awoke at once; SAHARAI spam; the dead windmill string | 0.0 | — |
| prior b0a0-b3a0 (§25.12) | RENSA / KARIBA; the ranged fence; the blade gate + the bind plans SHIME / TSURUSHI; the reaping fence | 0.637-0.766 | the Shikai is his strength; prior b2a0's bind plans never showed (0.3 binds a match) |
| round01 b0a0 | prior b3a0 ported + KAZAGURUMA-GAESHI + TODOME, gate 4500 | 0.783 | the base Shikai |
| round01 b1a0 / b1a1 / b1a2 | the ranged route styles; MACHI-GUSARI (answers only); MIKIRI in both forms, TAIHO (the pure hop) + the lash read | 0.7517 / 0.7741 / 0.7783 | b1a1's located Bankai leaks (ported here); MACHI-GUSARI and TAIHO measured again here: neutral in this CPU |
| round01 **b2a0 (parent)** | b0a0's Shikai + the bind first (KUBITSURI): gate 3000, the noose off every confirmed HARD hit, TSURI / SHIME, the drain margin, the SAHARAI cancel bug | 0.7855 | drained binds +369 each; the ranged mode is where he dies |
| round01 b3a0 | b0a0 + b1a0's routes, gate 3000, the waking noose, the ledger | 0.785 | the waking noose whiffs (153 of 221) |
| round01 b0a1 / **b0a2** | MIKIRI / TSUME (the Hoho read); the combo's route plan RINNE / HANA (§25.16) | 0.7945 / **0.8203** | the round's best Shikai; its Bankai is a last stand (4500) |

Every cell that kept the Bankai in view (b1*, b2a0, b3a0) paid for it with a weaker Shikai than b0a2's; b0a2 has the best
Shikai and the themes at 1 %. Nobody had looked at what decides a bind.

## Step 1: the combination (v1, 0.8109)

A three-way merge (base b0a0, ours b2a0, theirs b0a2: b2a0 and b0a2 both diverge from b0a0's file) applied cleanly; the one
semantic clash, both cells' new HSS slot `ai-plan` (b0a2's combo plan, b2a0's bind plan), is solved by renaming b2a0's to
`ai-bplan` / `ai-bplan-from`. The test sections merge the same way. Paired with b0a2 (HARD, seeds 1-10, both seats, 120
matches, identical until the 3000-taken awakening): b0a2 68 wins, v1 67 (Kenpachi +3, Ichigo -5): the Bankai at 3000 was
strength-neutral, the themes 0.09 of his damage.

## The diagnosis (combat logs as aieval runs them; scratch scripts `bd.py`, `net.py`, `bf.py`, `bs.py`, `bp.py`)

HARD, v1, the awakening forced (debug 39010 / 39001, both seats, 120 matches; then 360):
1. **Per form, dealt / taken a second**: Shikai 38.3 / 20.9, ranged mode 12.4 / 31.0, bind 32.3 / 23.6.
2. **The bind is a race to the red.** Its value is the Konpaku a drain makes real: a drained bind nets +1749 (damage + 1300 a
   Konpaku: his Kikons on the victim and the Soul Breaks at the drain), a released one is undone. What decides it:
   - who lands the **first Kikon** in it: his first, drained 48 of 52; the opponent's first, released 67 of 71 (a Kikon needs
     the victim red and a link 3: the forced O ender);
   - who lands the first hit: his first, drained 153 of 224; the opponent's, released 74 of 87;
   - not the entry state: by red at entry the drain share is 0.42-0.60, by the Reishi gap flat.
3. **His bind strings were the weakest route.** The generic string pick (`*AI-STRING-FLASH-P*`) took the J links: J1 → J2 →
   J3, 145 (the bind's routes: JJJ 145, JJK 206, **JKK 242**, **KKK 290**). J1 → K2s → K3 combos by the rules (J1 A 3 + flinch
   18 ≥ K2s's S_eff 14 + 3; K2s's stagger ≥ K3's S_eff 14).
4. **His bind neutral lost where it was not J1** (net in the 180 f after each, per press): neutral J1 +162, the follow-up J1
   +208, but the neutral K1 -24, the generic Step-in -44 and its Step J SENGEN -40.
5. **Bankai leaks** (round01 b1a1 located them; still here): the J1 reset into a free guard after a blocked string at range
   (320 presses, 10 hit, -23 net), the generic J1 into a Breaker's dash at 4-5 m (-81), the Breaker into a long guard (-161)
   or into a parry (-76).

## The styles (行動方針) and the mix

| layer | roll | styles, chances (EASY / NORMAL / HARD) |
|---|---|---|
| the Shikai's chain style (b0a0's) | once a match (HS-AI-STYLE) | **RENSA 連鎖 55 %** / **KARIBA 刈場 45 %** |
| the Hoho read (b0a1's) | per event (each K1 into a Hoho-ready opponent) | **見切り MIKIRI** → **詰 TSUME** the close-in: 0 / 0.2-0.3 / 0.75 |
| the combo's route plan (b0a2's, §25.16) | once per combo, at its first J1 / K1 hit (0 / 0 / 1.0) | **輪 RINNE 80 %** / **輪止 RINNE-OWARI 10 %** / **花 HANA 10 %** (the user's showpiece) |
| the awakening (b2a0's kit gate) | AI-AWAKEN-P | at 3000 taken |
| the ranged mode, a transit to the noose (b2a0's) | once per entry (HS-R-STYLE) | **SOKUBAKU 束縛 80 %** / **SANGE 散華 20 %**; the noose off every confirmed hit (0 / 0 / 1.0) |
| the bind's plan (b2a0's) | once per bind (HS-B-PLAN) | **吊 TSURI 50 %** (the long hang) / **絞 SHIME 50 %** (the choke) |
| **the bind's play, 絞首 KOSHU, the race to the red (new)** | per link hit / per neutral decision in the bind | the cinching route 0 / 0.3 / 1.0; the walk-in 0 / 0 / 1.0 |

(NORMAL never binds: its noose chance is 0, so the bind's chances act at HARD, and for the ASSIST's borrowed HARD brain.)

### 絞首 KOSHU, the race to the red (this cell, every bind, both plans)

- **The cinching route (`*HS-AI-B-ROUTE-P*`, HS-B-AI-MOVE).** Every link of a bind string is the K one: J1 → K2s 巻斬 → K3 絞
  SHIBORI (242), K1 → K2 → K3 (290). The chains wind and cinch at the end of every string; the generic pick's J1 J2 J3 (145) is
  gone. The rain (KUSARI-AME) still ends a string where the plan allows, and the TODOME (b2a0's: a red victim's K link 2 into the
  rain) comes first.
- **The walk-in (`*HS-AI-B-CLOSE-P*`, HS-B-AI-REFLEX)** and the bands. At a neutral decision 1.8 m or more away he takes the
  decision with nothing and walks in on the chain to J1's range. No neutral K1 in the bind's bands, no Step-in, so no SENGEN
  from range. KOJO (L) keeps its roll per entry into 2.5-4 m (b2a0's 0.3).
- **The Bankai's leaks closed** (round01 b1a1's fixes, ported by hand): :WAIT after a blocked string at any range; the anti-
  Breaker over the generic's 5.0 m; `*HS-AI-R-GUARD-WAIT-P*` HARD 1.0 in both Bankai modes; a parry up close waited out.

### What a human notices

- He fights most of the match as b0a2's chain kusarigama: RENSA's step-in J1 or KARIBA's reap at 3-6 m; once anything lands
  at HARD, the chain goes round twice (RINNE), one combo in ten the user's full showpiece (HANA).
- About two and a half souls down, KARE, KAZESHINI: he backs off behind the chains and waits for the one clean hit, and the
  noose goes round your neck.
- **In the bind he walks you down along the chain and every string he lands cinches**: the short sickle, the chains wrapping,
  the bundle pulled tight (J1, K2s, K3), and when he is ahead the chain rain after it. He never swings the long K1 or hops in
  from range there.
- When the bind goes against you, the grey souls turn real at the drain; when it goes against him, he throws it off.

### How often (HARD, seeds 1-10, both seats, 120 matches, this CPU)

He awakens in 73 of 120 matches. 72 binds: 40 drained (39 of them ahead), 32 released; the noose thrown 92 times, 73 hit.
Per match: 9.5 RINNE plans, 1.2 RINNE-OWARI, 1.1 HANA; 14.0 windmill bridges, 8.7 leaps; 1.3 cinching-route links and 2.0
walk-ins; TSURI 39 / SHIME 33 binds. The bind's first-hit race (HARD, forced awakening, 360 matches): his first
hit drained 477 of 637, the opponent's released 197 of 246; his first Kikon drained 94 of 103.

## Tried and dropped (HARD; "forced" = the awakening forced, both seats; 10 seeds = 120 matches, 30 = 360)

| variant | result | verdict |
|---|---|---|
| v1 (the merge) → **v3: + the cinching route** (forced 120) | wins 50 → 51, signature 0.856 → 0.873, bind dealt / taken a second 32.3 / 23.6 → 36.6 / 23.2, drain share 0.53 → 0.56 | kept |
| v3 → **v4: + the walk-in, no neutral K1 / Step, b1a1's leak fixes** (forced 120) | 51 → 56, bind 38.1 / 21.3, drain share 0.62; non-forced paired 120: b0a2 68, v1 67, v3 68, **v4 71** (awakened matches 26 → 30 of 73) | kept; aieval **0.8229** |
| v2: b1a1's MACHI-GUSARI at HARD (a neutral decision in the ranged mode taken with nothing) on v1 (forced 120) | 50 → 45 | dropped |
| v6: MACHI-GUSARI on v4 (forced 360, seeds 201-230) | 166 → 162, proxy 0.5727 → 0.5725 | dropped (neutral twice) |
| v5: round01 b1a2's TAIHO, the pure hop for every escape / dodge at HARD (aieval 40) | 0.8229 → 0.8232 (strength 0.565 both); forced 120: Kenpachi 8 → 2 of 20 | dropped (neutral, Kenpachi Steps in after a lone hop, as b1a2 found) |
| v7: the gate 3000 → 2500 (aieval 40) | 0.8147: strength 0.542, NORMAL 0.358, themes 0.16 | dropped |
| v8: the bind kit's `:guard` 0.4 → 0.6 (forced 360) | 166 → 154 | dropped |
| the bind plans compared (forced 480, seeds 101-120) | TSURI drained 163 of 271 (0.60), SHIME 177 of 310 (0.57) | both kept, 50 / 50 |

The 120-match forced runs are noisy: the same v4 with one roll fewer per event (HS-ROLL draws nothing at a chance of 1.0)
went 56 → 45 of 120. So the decisions above lean on the 360-match runs and the 40-seed aieval.

## The research on §25.16 (the user's showpiece), as this cell's Shikai plays it

The Shikai is b0a2's, so the showpiece is played and measured as b0a2 found it: RINNE (J1 > L > K1 K2 > J3K > L > K1 K2 K3 >
RAIDEN, the showpiece's back half) is the strongest route he has; HANA (the user's exact J1 J2 J3 > L > K1 K2 > J3K > L > K1 K2
K3) one combo in ten, for the look (its J1 J2 J3 head costs signature: plain J, and the decay three hits early); the SP
versions (an SP in the middle or at the end) measured weaker, the middle one a frame trap by FIGHTER-GC-LEFT (b0a2's notes).
This cell adds no Shikai change; its showpiece counts are in "How often". (A bind-themed ender, SP2 縛 SHIBARI, the Shikai's
own bind, can't end a K string: it is refused while the sickle is out.)

## Mechanisms implemented (CPU parts only)

- **Merged** (CPU hunks, three-way, never a whole file): round01 b0a2's Shikai (b0a1's MIKIRI / TSUME, b0a2's route plan) into
  b2a0's file; b2a0's bind-plan slot renamed `ai-bplan` / `ai-bplan-from`.
- **New functions:** HS-ROLL (one roll of a chance, none drawn at 0 or 1: the host tests have no sim stream).
- **Changed:** HS-B-AI-MOVE (TODOME first, then the cinching route); HS-B-AI-REFLEX (KOJO returns its command, then the
  walk-in); HS-R-AI-REFLEX (no J1 reset at range, a parry waited out, the Bankai guard wait); HS-R-AI-ANTI-BREAKER (within
  `*AI-ANTI-BREAKER-RANGE*`); HS-AI-GUARD-WAIT (an optional plist).
- **Kits:** the bind's `:moves` (0-1.2 m `:q 5`, 1.2-1.8 m `:q 3 nil 1`, 1.8-3.2 m `nil 3`: no neutral K1, no Step).
- **Knobs (new):** `*HS-AI-B-ROUTE-P*` (0 / 0.3 / 1.0), `*HS-AI-B-CLOSE-P*` (0 / 0 / 1.0), `*HS-AI-R-GUARD-WAIT-P*` (0.6 / 0.75
  / 1.0). Unchanged: the gate (3000), the noose, the bind plans, every NORMAL / EASY value of b2a0's and b0a2's.
- **Pacing counters:** `ai-b-route`, `ai-b-close` (with b2a0's and b0a2's).
- **HSS CPU slots:** b2a0's and b0a2's (renamed above); none new; none hashed.
- **Not touched:** HS-AI-OPP and its knobs, every move, rule and human hook, the art, HS-HASH, the sim ticks, every other file
  but the test section.
- **Kept working:** the awakening only through AI-AWAKEN-P's kit gate; the learner's clock (the walk-in acts only at a decision
  due, inside a bind; the route only on his own link hits); the ASSIST (HS-B-AI-MOVE reads the brain it is given; the walk-in is
  :reflex only); the debug modes 83000-83999 and the `duel hisagi` line. Every chance is EASY ≤ NORMAL ≤ HARD (host-pinned),
  rolled once per event (a link hit, a decision due, a bind, an entry, a combo, a match).
- **Host tests (the section):** b2a0's and b0a2's checks merged; the HS-B-AI-MOVE check keeps TODOME's contract with the route
  off and adds the route's (HARD: K off J1 / K1 / K2s / J2, nothing off a K3, a block or out of a bind); the new knobs' values
  and ordering, HS-ROLL, and the bind's bands without a neutral K1 or Step.

## Why it is not a repeat

- The merge is reuse, stated as such: b0a2's Shikai and b2a0's Bankai had never run together.
- 絞首 KOSHU is new: no cell looked inside a bind. It rests on a located cause (the first Kikon decides a bind; the generic
  string pick takes the bind's weakest route; the neutral K1 / Step-in lose there) and changes the bind's own play, not the
  noose or the release (b2a0's) or the ranged mode (b1*'s).
- Two earlier mechanisms were re-measured in this CPU and dropped on the numbers (MACHI-GUSARI, TAIHO), so the next cells need
  not retry them here.

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, NORMAL, 60 seeds a stream; pairs 28 29 30 31 32 34)

The never-awaken side's wins of 60, this file / round01 b0a2's (= b0a1's) / the baseline's (b0a0's measure):

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100 | 39 / 39 / 2 | 21 / 21 / 1 | 35 / 35 / 0 | 26 / 26 / 0 | 52 / 52 / 1 | 32 / 32 / 0 |
| 300 | 30 / 30 / 2 | 23 / 23 / 0 | 40 / 40 / 0 | 28 / 28 / 1 | 48 / 48 / 4 | 22 / 22 / 1 |
| 500 | 30 / 30 / 1 | 22 / 22 / 0 | 36 / 36 / 0 | 34 / 34 / 0 | 49 / 49 / 2 | 25 / 25 / 0 |

- The gate is the parent's (3000), unchanged, but the never-awaken side is now b0a1's NORMAL Shikai (b0a2's plan is HARD's
  only), so the A/B was run on all three streams: every row is at least 21 of 60, it passes (the bar is 20). All 1080 matches
  are K.O.s; medians 103.4-153.6 s.
- The rows equal b0a1's / b0a2's to the match. HK (21-23) stays the closest to the bar, as in every cell.

## Expected benefit and risks

**Benefit:**
- The round's best Shikai (b0a2's) with the bind and ranged themes in view (0.095 of his damage) and a bind that
  wins its race: score 0.8229 vs b2a0's 0.7855 and b0a2's 0.8203.
- HARD strength 0.565; NORMAL mid-band (0.475); masher 1.000.

**Risks:**
- **Noise.** Against b0a2 the gain is within a 40-seed rescore's ±0.02. The paired non-forced run (120 matches) gives +3 wins
  over b0a2 and +4 over the merge, all in awakened matches.
- **Lille stays at 0-2 of 80 at HARD**, as in every cell; Kenpachi and Ichigo stay the hardest of the others.
- **The ranged mode still bleeds** (HARD, forced: 11.6 dealt / 32.7 taken a second): the escape's generic Step → J lash
  (-69 net, 148 of 829 perfect-Hoho'd) and the anti-approach strikes. Neither the waiting chain nor the pure hop fixed it in
  this CPU.
- **Pacing:** the longest NORMAL median is 162.5 s (cap 220): no risk.
- **NORMAL** plays b2a0's Bankai and b0a1's Shikai (the plan and the bind are HARD's): NORMAL 0.475. A later cell
  raising NORMAL's Bankai values must re-measure it (b2a0's note: 0.61-0.67 with NORMAL's fence at 0.15 or more).

## Shared-code recommendations (not built)

- **ai.lisp's generic Step → J** remains the ranged mode's largest leak (every ranged cell's note). A kit key (`:step-j` 0,
  or honouring `:min-reach`) would let the escape be a hop and a run without the lash.
- **The generic string pick** (`*AI-STRING-FLASH-P*`, STRING-REFLEX) takes a kit's J links by default; a kit `:string-k` per
  form exists, but a per-difficulty one would let a kit's route be HARD's without the :move-reflex.
- (Standing) AI-AWAKEN-P is one gate for every difficulty; the kit's `:hoho` / `:guard` are one number for every difficulty.

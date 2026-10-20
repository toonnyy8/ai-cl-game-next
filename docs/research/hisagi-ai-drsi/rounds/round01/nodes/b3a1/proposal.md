# b3a1 (round 1, §25.15 freeze, a refine of b3a0): 三味・輪 SANMI-RINNE, the three themes mixed, the Shikai's wheel inside

Cell b3a1, round 1, freeze 3686d94. Branch b3's primary style: a probabilistic mix of all three themes. PARENT_DIR b3a0
(0.785): its `hisagi.lisp` copied over the frozen one and its HISAGI-CPU-TESTS section spliced in, then refined. Everything
is in `duel/lisp/hisagi.lisp`'s CPU parts and the host test's `HISAGI-CPU-TESTS` section.

The cell is a **new combination of the measured pieces that worked, plus two located-bug fixes and one research answer on
§25.16**. b3a0 and b0a2 were never combined: b0a2 (the round's best, 0.8203) has the best Shikai but no Bankai to speak of
(gate 4500, ranged + bind 1 % of his damage); b3a0 has the three themes but lacks b0a1 / b0a2's Shikai layers and carries a
located bug in its ranged mode.

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`)

| | baseline | b3a0 (parent) | b0a2 (round best) | **b3a1 (this file)** |
|---|---|---|---|---|
| **score** | 0.0 (raw 0.4149) | 0.785 | 0.8203 | **0.8144** (raw 0.8144) |
| strength (HARD, 480) | 0.006 | 0.490 | 0.552 | **0.552** |
| masher (HARD, 224) | 0.188 | 1.000 | 1.000 | **0.996** |
| signature | 0.751 | 0.876 | 0.909 | **0.899** |
| sig_by chain / ranged / bind | 0.373 / 0.204 / 0.174 | 0.757 / 0.079 / 0.041 | 0.901 / 0.005 / 0.004 | **0.806 / 0.062 / 0.031** |
| plain J / counter / Kikons (Shikai, ranged, bind) / Breaker | 0.111 / 0.037 / 0.063 / 0.038 | 0.064 / 0.020 / 0.033 / 0.008 | 0.065 / 0.011 / 0.011 / 0.005 | 0.066 / 0.015 / 0.014 / 0.005 |
| NORMAL share (factor) | 0.104 (0) | 0.5625 (1) | 0.5271 (1) | **0.5062 (1)**: Y 52, K 25, R 30, I 43, S 61, Lille 32 of 80 |
| pacing (NORMAL medians, all 240 K.O.) | 115-175 s | 110.0-163.9 s | 104.2-157.8 s | **111.7-174.7 s** (Rukia 174.7 the longest) |

`score.json` holds the exact JSON line (measured twice, before and after a comment-only pass: the same line).

**The 40-seed number is mostly the seed draw.** So every variant below was compared on **960 HARD matches** (seeds 1-80,
both seats, aieval's strength jobs with the combat log; my `wins.py` reproduces aieval's strength and signature to the
match). One standard error is about 0.016 of strength there. The non-awakened matches of two variants that differ only in
the Bankai are identical match for match, so Bankai variants are paired comparisons.

| 960 HARD matches (seeds 1-80) | wins | strength | signature | 0.3 s + 0.5 g | Y | K | R | I | S | Lille (of 160) |
|---|---|---|---|---|---|---|---|---|---|---|
| A: b3a0 + b0a1 / b0a2's Shikai merged (480 only) | 257/480 | 0.535 | 0.895 | 0.6079 | | | | | | |
| **C (this file)** | **533** | **0.555** | **0.898** | **0.6157** | 133 | 47 | 132 | 65 | 156 | 0 |
| C, gate never (= b0a2's Shikai-only play) | 485 | 0.505 | 0.902 | 0.6025 | 120 | 28 | 130 | 63 | 144 | 0 |
| C, gate 4500 (b0a2's) | 500 | 0.521 | 0.902 | 0.6070 | 121 | 30 | 137 | 64 | 148 | 0 |

So at 960 matches the Bankai at 3000 taken **adds** HARD wins over b0a2's play (+48 wins, about 3 standard errors; Kenpachi
28 -> 47 of 160), for 0.004 of signature. At seeds 1-40 alone both files land on 0.552.

**Per form at HARD** (C, 960 matches): Shikai 101.2 s a match, 37.1 dealt / 24.3 taken a second; ranged mode 9.0 s, 27.9 /
60.1; bind 4.6 s, 47.8 / 29.0. He awakens in 553 of 960 (those are the matches he was losing: he wins 227 of them); not
awakened, he wins 306 of 407.

**Host tests:** duel-rules **9873 checks ALL PASS** (the frozen 9865 + 8 in the section; splicing this file's section into
the frozen file with `splice-tests.py` gives the delivered `duel-rules-test.lisp` byte for byte). control 89, learn 131,
input 33, cine 18 ALL PASS; touch 64, 0 failures. `tools/pkgcheck.sh duel`: clean.

## History read, and what it says

| cell | mechanism | rescored | lesson used here |
|---|---|---|---|
| baseline | awoke at once; SAHARAI spam; the dead windmill string | 0.0 | — |
| prior b0a0-b3a0 (§25.12) | RENSA / KARIBA, the bridge K at f9, the ranged fence, the blade gate, the reaping fence | 0.567-0.766 | the Shikai is his strength |
| round01 b0a0 | prior b3a0 ported + KAZAGURUMA-GAESHI + TODOME, gate 4500 | 0.783 | the best Shikai base |
| round01 b1a0 | the ranged route styles SENTAN / KAISEN / NAWAJI, gate 2000 | 0.7517 | the routes show; the ranged mode costs HARD |
| round01 b2a0 | the bind first, gate 3000, the SAHARAI-cancel bug located | 0.7855 | the bind wins, the ranged mode loses; the cancel bug |
| round01 b3a0 (parent) | b0a0 + b1a0's routes, gate 3000, 3-step reap, waking noose, ledger | 0.785 | the three themes at b0a0's score; still has the cancel bug |
| round01 b0a1 | MIKIRI (the Hoho read) + TSUME (the close-in) | 0.7945 | the perfect Hoho of K1 is his biggest leak |
| round01 b1a1 | MACHI-GUSARI: the ranged mode answers only; the cancel fix | 0.7741 | removing the ranged neutral swings won (forced Bankai 0.338 -> 0.425) |
| round01 b1a2 | TAIHO / MUCHI-YOMI (the lash read), MIKIRI across forms, ranged TODOME | 0.7783 | small gains at gate 2000 |
| round01 b0a2 | the combo's route plan RINNE / OWARI / HANA (§25.16) | **0.8203** | the conversion, not the neutral: +0.05 HARD |

Every proposal claims sit inside the 40-seed noise of each other except b0a2's plan (its forced runs agree). b3a0 lost to
b0a2 by its Shikai (no MIKIRI, no plan), not by its Bankai; b0a2 never measured whether a Bankai could add to its Shikai.

## The styles and the mix (the 行動方針)

| layer | roll | styles, weights / chances (EASY / NORMAL / HARD) |
|---|---|---|
| the Shikai's chain style, 始解鎖鐮連段 (b3a0's) | once a match (HS-AI-STYLE, SIM-RND01), by difficulty | **RENSA 連鎖** / **KARIBA 刈場**: 0.55 / 0.45 at EASY and NORMAL, 0.8 / 0.2 at HARD |
| 見切り MIKIRI -> 詰 TSUME (b0a1's) | the Hoho read, per event | the reap / hop held back 0 / 0.2 / 0.75, the close-in 0 / 0.3 / 0.75, while his K1s are perfect-Hoho'd over 0.42 |
| **the combo's route plan** (b0a2's, §25.16) | once per combo at its first J1 / K1 hit | a plan 0 / 0 / 1.0, then **輪 RINNE 80 %**, **輪止 RINNE-OWARI 10 %**, **花 HANA 10 %** |
| per charge, ward, link hit (b0a0's) | once per event | KAZAGURUMA-GAESHI, TODOME (a red link 2 into RAIDEN), the bridge, the leap, the RAIDEN ender |
| the awakening | the kit gate `:awaken (:min-taken 3000)` (AI-AWAKEN-P; b3a0's, re-measured here) | the Bankai once he has taken 3000 |
| the waking noose (b3a0's) | once per awakening | KUBIKAKE inside 300 f of it, 0.02 / 0.05 / 0.8 |
| the ranged posture **待鎖 MACHI-GUSARI** (b1a1's, ported) | every entry | no J1 / K1 / Step / KOSA / SP1 from the bands, no dash in: every route opens off an answer |
| the ranged route style, 卍解遠距路線 (b1a0's) | once per entry into the ranged mode (HS-R-STYLE) | **SENTAN 尖端 60 %** / **KAISEN 回旋 25 %** / **NAWAJI 縄路 15 %** |
| the bind, 捆綁 (b3a0's ledger) | per change event | the release 150 behind on grey, at any deficit once the pool is <= 150; KAIBAKU-GEKI within 2.8 m, else FREE 0.05 / 0.1 / 0.9 |

How often at HARD (960 matches, a match): RENSA 83 % / KARIBA 17 % of matches; 9.0 RINNE, 1.2 OWARI and 1.1 HANA plans; 13.9
windmill bridges, 8.1 leaps; 5.2 reaps, 3.2 step-ins and 2.2 dash-ins under the read; 2.8 charge wards; 2.6 TODOMEs. In the
Bankai: SENTAN 0.6, KAISEN 0.23, NAWAJI 0.15 entries; 0.43 waking nooses; 0.88 KUBIKAKEs (0.50 hit) for 0.49 binds (0.26
drained, 0.17 FREE releases, 0.07 KAIBAKU-GEKIs); 2.4 strikes into his approach, 0.8 punishes, 0.24 SAHARAI cancels.

### What each style does (per form)

**Shikai** (most of every match; 101 s of 115 at HARD).
- **RENSA 連鎖, the chain link** (80 % of HARD matches): closes in, opens with J1, and the wheel turns.
- **KARIBA 刈場, the reaping ground**: holds 3-6 m, hops out of K1's dead zone, reaps every approach with the sideways
  sweep (K1 timed to his walk, the approach proven over 3 perceived steps at HARD).
- **Either style, at HARD, once anything lands, 輪 RINNE**: J1 > L > K1 K2 > J3K (the leap along the chain) > L > K1 K2 K3 >
  RAIDEN. One combo in ten is **花 HANA**, the user's showpiece as written (J1 J2 J3 > L > K1 K2 > J3K > L > K1 K2 K3); one
  in ten is **輪止 RINNE-OWARI**, the wheel cut short into the lightning (... K1 K2 > RAIDEN).
- **Either style, against a Hoho-er**: once his sideways sweep is perfect-Hoho'd over 42 % of the time (MIKIRI), he stops
  throwing it into a Hoho-ready opponent and walks the chain in by hand (TSUME: the Step in, the short sickle, the windmill).
- **Either style**: the windmill rises against a charged shot and sweeps back with the charged K string (KAZAGURUMA-GAESHI);
  a red victim's link 2 goes into the lightning (TODOME).

**Bankai, ranged mode** (from 3000 taken). The waiting chain: he stands at the chain tips (4-5.6 m) and never swings at a
standing opponent. Walk in and the bundle meets you on its tip; whiff and the chain punishes from where it reaches; get
close and he hops away or SAHARAIs you off and lashes the bundle into your slide.
- **SENTAN, the tip reaper** (60 %): K1 on the tip, the gathered K route to its end (x1.71), the noose off the ender.
- **KAISEN, the Reiatsu wheel** (25 %): J1's tip, the spread J route.
- **NAWAJI, the noose road** (15 %): the noose off the first link that hits.
- **The waking noose**: right after KARE, KAZESHINI, KUBIKAKE at once (80 % of HARD awakenings).

**Bind** (the ledger): he presses close; behind on grey he lets go (FREE, or KAIBAKU-GEKI up close); ahead he lets it drain.

### What a human notices
- At HARD he is the chain kusarigama most of the match: the sickle flick, the windmill, the long reaping chain twice round
  with a leap in between, lightning at the end. One combo in ten is the user's full showpiece with the three sickle spins.
- Perfect-Hoho his sweep a few times and he stops sweeping and walks in instead.
- Hurt him for about two and a third souls and the Bankai comes: the noose flies right out of the awakening, then he waits
  at the chain's tip and only answers. In the bind he presses close and lets go when he is losing.
- **What sets it apart from earlier cells:** the only cell with the three themes and the Shikai's wheel together; the
  Bankai here adds HARD wins over a Shikai-only play of the same Shikai (paired, 960 matches), where every earlier cell
  found the Bankai a cost or neutral.

## Mechanisms implemented (CPU parts only)

- **Merged** (a three-way merge of b0a2's CPU diff over b0a0 onto b3a0, one docstring conflict): b0a1's MIKIRI / TSUME
  (`*HS-AI-MIKIRI-P*`, `-PRIOR*`, `-RATE*`, `*HS-AI-HOHO-QUIET*`, `*HS-AI-CLOSE-P*`; HS-MIKIRI-RATE, HS-HOHO-READY-P,
  HS-OPP-HOHO-READY-P, HS-MIKIRI-UNSAFE-P, HS-MIKIRI-NOTE, HS-AI-CLOSE; HSS slots `ai-hr-*`, `ai-hseen`, `ai-cz*`) and
  b0a2's plan (`*HS-AI-PLAN-ROUTES*`, `*HS-AI-PLANS*`, `*HS-AI-PLAN-P*`; HS-PLAN-NEXT, HS-AI-PLAN, HS-AI-PLAN-CMD; slots
  `ai-plan*`). Their test pins merged the same way.
- **Ported from b1a1** (CPU hunks): MACHI-GUSARI (the ranged kit's `:moves` beyond 2 m empty, `:dash` 0; `:kikon-range` 0 and
  `:o-ender` 0 in both Bankai kits), `*HS-AI-R-GUARD-WAIT-P*` (HS-AI-GUARD-WAIT takes a plist), the parry waited out up
  close, the anti-Breaker over `*AI-ANTI-BREAKER-RANGE*`, the red Kikon rush clause removed. Its pins too.
- **Located bug 1 (the parent's): the SAHARAI hit's cancel** read the victim's distance while SAHARAI's push still carried
  him through K1's dead zone, so nothing was pressed (round01 b2a0 found it; b3a0 still had it). Now read where the push
  leaves him (`(max (fighter-dist f) *hs-saharai-hit*)`): 0.24 L-cancels a HARD match, pinned by b1a1's host test.
- **Located bug 2 (every cell's): SHIBARI after RIN.** HS-AI-ENDER pressed SP2 SHIBARI after the J string's RIN. SHIBARI's
  slam (90, f46) lands only while its bind's 46 f stun outlasts the combo's hitstun decay; late in a string it doesn't:
  as a string SP at HARD (480 matches, a forced test) of 1238 binds its slam landed 402 times and was blocked 659 (after RIN
  alone: 35 and 52 of 100), so ~60-90 written against RAIDEN's clean 110, and the blocked slam is -14 on block. Now every Shikai SP ender is RAIDEN.
- **Not touched:** HS-AI-OPP and its knobs; every move, rule and human hook; the art; HS-HASH; every other file but the test
  section.
- **Kept working:** the awakening only through AI-AWAKEN-P's kit gate (the debug :always / :never modes win); the learner's
  clock (every reflex acts on events, NIL otherwise); the ASSIST (hooks read `ai-brain`; the plan's move-reflex reads the brain
  it is given; MIKIRI's bookkeeping is gated on HS-TICK-BRAIN); the debug modes 83000-83999 and the `duel hisagi` counters.
- Every chance an (:easy :normal :hard) plist, EASY <= NORMAL <= HARD (host-pinned), rolled once per event.

## §25.16 research (the showpiece and its SP versions)

b0a2 measured the RAIDEN versions (HANA-SP, HANA-OWARI, TSUZURI: weaker; RAIDEN's guard-cancel frees him only at f47, so the
SP middle can't restart a string). This cell measured the **SP2 versions**: SHIBARI as the plan's SP end, TODOME's SP and
the K3 ender (縛止 SHIBARI-DOME, HARD 0.5 of SP decisions; 480 matches): 259 vs 265 wins without it, signature 0.892 vs 0.899.
Its slam is lost to the combo's hitstun decay (above), so an SP2 version of the showpiece is a two-hit SP whose second hit
is blocked a third of the time. Dropped, and with it the parent's SHIBARI-after-RIN. Answer: the showpiece's SP versions
should cancel into RAIDEN; SHIBARI belongs outside long strings.

## Tried and dropped (960 HARD matches unless noted; proxy = 0.3 str + 0.5 sig)

| variant | wins / 960 | signature | proxy | verdict |
|---|---|---|---|---|
| **C (this file)** | **533** | 0.898 | **0.6157** | kept |
| gate 2000 / 2500 / 3500 / 4500 / never | 497 / 518 / 511 / 500 / 485 | 0.894-0.902 | 0.6023-0.6099 | 3000 kept (the peak; Kenpachi 47 at 3000 vs 28 never) |
| the reap proof over 1 step at HARD (b0a1's) | 538 | 0.903 | 0.6194 | within noise; b3a0's 3 kept |
| HARD RENSA / KARIBA 0.55 / 0.45 (b0a1's) | 536 | 0.901 | 0.6180 | within noise; b3a0's 0.8 / 0.2 kept |
| no waking noose | 537 | 0.898 | 0.6168 | within noise; kept for the theme |
| NAWAJI-heavy route styles (0.25 / 0.6 / 0.15) | 524 | 0.899 | 0.6132 | dropped |
| the bind released only 600 behind (a longer hang) | 530 | 0.898 | 0.6146 | dropped |
| b1a2's ranged pieces (TAIHO / MUCHI-YOMI, MIKIRI across forms, ranged TODOME) | 522 | 0.899 | 0.6127 | dropped: no gain in a 9 s ranged mode (the awakened matches 216 vs 227 won); code removed |
| 縛止 SHIBARI-DOME (480) | 259 vs 265 | 0.892 vs 0.899 | | dropped (above) |

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, NORMAL, 60 seeds a stream; pairs 28 29 30 31 32 34)

NORMAL's Shikai is b0a1's plus the RAIDEN-after-RIN fix (NORMAL plans nothing), so the A/B was re-run. The never-awaken
side's wins of 60 (this file / b0a1-b0a2's):

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100 | 38 / 39 | 24 / 21 | 35 / 35 | 28 / 26 | 53 / 52 | 30 / 32 |
| 300 | 33 / 30 | 23 / 23 | 41 / 40 | 28 / 28 | 47 / 48 | 24 / 22 |
| 500 | 28 / 30 | 23 / 22 | 38 / 36 | 34 / 34 | 51 / 49 | 25 / 25 |

Every row is at least 23 of 60: it passes (the bar is 20). All 1080 matches K.O.s; medians 102.8-152.4 s. The baseline fails every
row (0-4).

## Expected benefit and risks

**Benefit:**
- 0.785 -> 0.8144 over the parent (HARD 0.490 -> 0.552, signature 0.876 -> 0.899), with all three themes in view (ranged +
  bind 0.093 of his damage).
- Against b0a2 (0.8203): the same HARD strength on seeds 1-40, but on 960 matches the Bankai adds about 0.05 HARD over the
  same Shikai without it, so a rescore on other seeds should favour this file; the signature costs about 0.01 (the
  Bankai's plain J1, Kikons and counters), about 0.005 of score.

**Risks:**
- **The 40-seed score is within noise of b0a2's** (±0.01-0.02 of score).
- **Pacing:** the longest NORMAL median is Rukia's 174.7 s (cap 220, 45 s of margin).
- **NORMAL 0.506**, mid-band.
- Lille stays 0 at HARD (she deals three times his damage: her charged snipes and stance strings).
- The ranged mode still loses at HARD (28 dealt / 60 taken a second); it is short (9 s a match) and the bind (48 / 29)
  pays for it.

## Shared-code recommendations (not built)

- **SHIBARI as a combo's SP:** the combo's hitstun decay shortens its bind's 46 f, so its slam is blocked late in a string.
  If the user wants SP2 in the showpiece's SP versions, the bind's stun could be exempt from the decay (a rules choice).
- (Standing, earlier cells) AI-AWAKEN-P is one gate for every difficulty; the forced O ender on a red victim leaves a kit no
  say; the kit's `:hoho` is one number for every difficulty; ai.lisp's Step -> J ignores `:min-reach`.

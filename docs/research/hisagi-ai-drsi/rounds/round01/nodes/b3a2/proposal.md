# b3a2 (round 1, §25.15 freeze, a refine of b3a1): 三味・空蝉 SANMI-UTSUSEMI, the three themes mixed, the Hoho through the swing

Cell b3a2, round 1, freeze 3686d94. Branch b3's primary style: a probabilistic mix of all three themes. PARENT_DIR b3a1
(0.8144): its `hisagi.lisp` copied over the frozen one and its HISAGI-CPU-TESTS section spliced in, then refined. Everything
is in `duel/lisp/hisagi.lisp`'s CPU parts and the host test's `HISAGI-CPU-TESTS` section.

The cell adds **one new mechanism on a located cause** (空蝉 UTSUSEMI: his best action, the Hoho, was rationed by a kit key
that every difficulty shares), **one new combination** (round01 b2a1's bind play 絞首 KOSHU, the best measured bind, under
b3a1's three-theme CPU, which never had it), and **drops one measured cost** (b3a0's waking noose, -92 net a throw).

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`)

| | baseline | b3a1 (parent) | b2a1 (round best before) | **b3a2 (this file)** |
|---|---|---|---|---|
| **score** | 0.0 (raw 0.4149) | 0.8144 | 0.8229 | **0.8281** (raw 0.8281) |
| strength (HARD, 480) | 0.006 | 0.552 | 0.565 | **0.623** |
| masher (HARD, 224) | 0.188 | 0.996 | 1.000 | **1.000** |
| signature | 0.751 | 0.899 | 0.907 | **0.882** |
| sig_by chain / ranged / bind | 0.373 / 0.204 / 0.174 | 0.806 / 0.062 / 0.031 | 0.812 / 0.046 / 0.049 | **0.815 / 0.043 / 0.025** |
| plain J / counter / Kikons (Shikai, ranged, bind) / Breaker | 0.111 / 0.037 / 0.063 / 0.038 | 0.066 / 0.015 / 0.014 / 0.005 | 0.060 / 0.015 / 0.012 / 0.005 | 0.070 / 0.030 / 0.012 / 0.006 |
| NORMAL share (factor) | 0.104 (0) | 0.5062 (1) | 0.475 (1) | **0.5083 (1)**: Y 51, K 25, R 29, I 46, S 63, Lille 30 of 80 |
| pacing (NORMAL medians, all 240 K.O.) | 115-175 s | 111.7-174.7 s | 110.7-162.5 s | **114.2-172.4 s** (Rukia 172.4 the longest) |

`score.json` holds the exact JSON line of this file (the last measured 40-seed run).

**The 40-seed number is mostly the seed draw** (±0.01-0.02 of score), so every variant was compared on **960 HARD matches**
(seeds 1-80, both seats, aieval's strength jobs with the combat log; the scratch `wins.py` reproduces aieval's strength and
signature to the match). The evaluator is deterministic: the same file rerun gives the same 960 matches to the match.

| 960 HARD matches (seeds 1-80) | wins | strength | signature | 0.3 s + 0.5 g | Y | K | R | I | S | Lille (of 160) |
|---|---|---|---|---|---|---|---|---|---|---|
| b3a1 (parent) | 533 | 0.555 | 0.898 | 0.6157 | 133 | 47 | 132 | 65 | 156 | 0 |
| + KOSHU in the bind | 540 | 0.562 | 0.901 | 0.6193 | 132 | 47 | 141 | 68 | 152 | 0 |
| + UTSUSEMI 0.6 | 557 | 0.580 | 0.893 | 0.6206 | 129 | 46 | 143 | 82 | 157 | 0 |
| + UTSUSEMI 0.9 | 597 | 0.622 | 0.883 | 0.6282 | 132 | 54 | 150 | 100 | 160 | 1 |
| + UTSUSEMI 1.0 | 589 | 0.614 | 0.882 | 0.6249 | 136 | 49 | 151 | 93 | 159 | 1 |
| **+ UTSUSEMI 0.9, no waking noose (this file)** | **610** | **0.635** | **0.884** | **0.6324** | 137 | 57 | 152 | 105 | 157 | 2 |

Against the parent: **+77 HARD wins of 960** (+0.080 strength; Ichigo 65 -> 105, Rukia 132 -> 152, Kenpachi 47 -> 57),
signature -0.014 (the Hoho counter's plain 60), **+0.0167 on the 0.3 s + 0.5 g proxy**. One standard error of a 960-match
strength is about 0.016; +0.080 is five of them.

**Per form at HARD** (this file, 960 matches): Shikai 101.2 s a match, 41.6 dealt / 23.4 taken a second (b3a1 37.1 / 24.3);
ranged mode 5.3 s, 31.6 / 75.8 (9.0 s, 27.9 / 60.1); bind 2.9 s, 55.3 / 28.9 (4.6 s, 47.8 / 29.0). He awakens in 451 of 960
matches (553 before: he takes less damage), wins 208 of them; not awakened, 402 of 509.

**Host tests:** duel-rules **9877 checks ALL PASS** (the frozen 9865 + 12 in the section: b3a1's 8, + 4 here; splicing this
file's section into the frozen file with `splice-tests.py` gives the delivered `duel-rules-test.lisp`). control 89, learn
131, input 33, cine 18 ALL PASS; touch 64, 0 failures. `tools/pkgcheck.sh duel`: clean.

## History read, and what it says

| cell | mechanism | rescored | lesson used here |
|---|---|---|---|
| baseline | awoke at once; SAHARAI spam; the dead windmill string | 0.0 | — |
| prior b0a0-b3a0 (§25.12) | RENSA / KARIBA, the bridge K at f9, the ranged fence, the blade gate, the reaping fence; prior b1a0: the Shikai's `:hoho` 0.9 "strength +, signature −" | 0.567-0.766 | the Shikai is his strength; the Hoho was seen once, as a kit key, and left |
| round01 b0a0 | prior b3a0 ported + KAZAGURUMA-GAESHI + TODOME; `:hoho` 0.3 -> 0.15 dropped (NORMAL's A/B rows) | 0.783 | the kit's `:hoho` is every difficulty's: NORMAL's never-awaken rows hang on it |
| round01 b1a0 / b1a1 / b1a2 | the ranged route styles; MACHI-GUSARI; MIKIRI across forms, TAIHO, the lash read | 0.7517 / 0.7741 / 0.7783 | the ranged mode bleeds whatever its CPU does |
| round01 b2a0 / **b2a1** | the bind first; **KOSHU, the bind as a race to the red** (the cinching route, the walk-in) | 0.7855 / **0.8229** | the best bind; never run under the three-theme CPU |
| round01 b3a0 | b0a0 + b1a0's routes, gate 3000, the waking noose, the ledger | 0.785 | the waking noose whiffs 153 of 221 |
| round01 b0a1 / b0a2 | MIKIRI / TSUME; the combo's plan RINNE / OWARI / HANA | 0.7945 / 0.8203 | the conversion: +0.05 HARD |
| round01 **b3a1 (parent)** | b3a0 + b0a2's Shikai + b1a1's MACHI-GUSARI, the SAHARAI-cancel fix, RAIDEN after RIN | 0.8144 | the Bankai at 3000 adds HARD wins over a Shikai-only play; "no waking noose" within noise (537 vs 533) |

Every round-01 cell after b0a2 sat within 0.01 of 0.82: their mechanisms moved the conversion (the plan), the Bankai or the
neutral's openers. None looked at what he does when the opponent commits.

## The diagnosis (combat logs as aieval runs them, b3a1's file, 960 HARD matches; scratch scripts `an.py`, `opens.py`, `oki.py`)

1. **His Hoho is the best thing he does, and he rations it.** Per Hoho in the Shikai, his damage dealt minus taken over the
   next 240 f: Yamamoto +193, Kenpachi +165, Rukia +270, Ichigo +242, Senjumaru +223, Lille +195 (60-85 % perfect: the
   counter's 60, then the plan's wheel off the follow-up J1). His K1 reap nets +75, his neutral K1 +40, the step-in J1 +87.
   Yet he Hohos 1.3-3.9 times a match. The cause is located in the kit: the generic AI-REFLEX answers a committed move coming
   (live, near, perceived >= 6 f of startup left, flash-step to spare) with a Hoho on the brain's Hoho roll below the kit's
   `:hoho` 0.3, else the guard. `:hoho` is one number for every difficulty, and NORMAL's never-awaken A/B rows hang on it
   (round01 b0a0 measured 0.15: HK 14-18 of 60), so no cell moved it. The flash-step it spends regenerates 3 a second; he
   ended matches with it unspent.
2. **The opponents' Hohos on him** (Rukia 5.5 a match, Ichigo 4.6, mostly perfect) are MIKIRI's subject (b0a1); not touched.
3. **The waking noose** (b3a0's, kept by b3a1 "for the theme"): 411 throws in 960 matches, 20 % hit, -90 net a throw.
4. **The bind under b3a1**: the generic string pick took the J links (J1 J2 J3, 145) and a neutral K1 / Step-in there lost
   (round01 b2a1's diagnosis, which b3a1 never ported).
5. Looked at and not acted on: the opponents' Bursts (3 a match on his combos, half at hit 2; the exchange after them is
   even), Lille (0 of 160: her damage spread over 15 moves, 3.8 k a match; no lever found), the wake-ups (his "free" hits
   are mostly re-opens while he is still stunned: no choice of his).

## The styles and the mix (the 行動方針)

| layer | roll | styles, weights / chances (EASY / NORMAL / HARD) |
|---|---|---|
| the Shikai's chain style, 始解鎖鐮連段 (b3a0's) | once a match (HS-AI-STYLE, SIM-RND01), by difficulty | **RENSA 連鎖** / **KARIBA 刈場**: 0.55 / 0.45 at EASY and NORMAL, 0.8 / 0.2 at HARD |
| **空蝉 UTSUSEMI, the Hoho through the swing (new)** | once per opponent action (the brain's own Hoho roll: no new draw) | the Hoho, in all, **0.3 / 0.3 / 0.9** (EASY / NORMAL keep the kit's generic 0.3; HARD 0.9) |
| 見切り MIKIRI -> 詰 TSUME (b0a1's) | the Hoho read, per event | the reap / hop held back 0 / 0.2 / 0.75, the close-in 0 / 0.3 / 0.75, while his K1s are perfect-Hoho'd over 0.42 |
| the combo's route plan (b0a2's, §25.16) | once per combo at its first J1 / K1 hit | a plan 0 / 0 / 1.0, then **輪 RINNE 80 %**, **輪止 RINNE-OWARI 10 %**, **花 HANA 10 %** |
| per charge, ward, link hit (b0a0's) | once per event | KAZAGURUMA-GAESHI, TODOME, the bridge, the leap, the RAIDEN ender |
| the awakening | the kit gate `:awaken (:min-taken 3000)` (unchanged; re-measured) | the Bankai once he has taken 3000 |
| the ranged posture 待鎖 MACHI-GUSARI (b1a1's) | every entry | no J1 / K1 / Step / KOSA / SP1 from the bands, no dash in |
| the ranged route style, 卍解遠距路線 (b1a0's) | once per entry into the ranged mode (HS-R-STYLE) | **SENTAN 尖端 60 %** / **KAISEN 回旋 25 %** / **NAWAJI 縄路 15 %** |
| the waking noose (b3a0's) | once per awakening | **0 / 0 / 0 (off)**, was 0.02 / 0.05 / 0.8 |
| **the bind, 捆綁: 絞首 KOSHU (round01 b2a1's, ported)** on b3a0's ledger | per link hit / per neutral decision / per change event | the cinching route 0 / 0.3 / 1.0, the walk-in 0 / 0 / 1.0, the bind's TODOME 0.1 / 0.2 / 0.9; the release 150 behind on grey, at any deficit once the pool is <= 150 |

How often at HARD (960 matches, a match): RENSA 83 % / KARIBA 17 % of matches; **2.9 UTSUSEMI Hohos** (his Hohos in all:
Yamamoto 1.25 -> 3.2, Kenpachi 3.9 -> 6.2, Rukia 1.8 -> 3.1, Ichigo 1.3 -> 3.1, Senjumaru 3.0 -> 5.5, Lille 1.5 -> 3.2; 74-82 %
perfect but against Senjumaru / Lille, 48-52 %); 10.0 RINNE, 1.3 OWARI and 1.2 HANA plans; 15.8 windmill bridges; 5.3 reaps,
3.1 step-ins and 2.3 dash-ins under the read; 2.9 TODOMEs. In the Bankai: SENTAN 0.41, KAISEN 0.19, NAWAJI 0.11 entries;
0.31 KUBIKAKEs off hits; in the bind 0.8 cinching links, 1.0 walk-ins, 0.37 KOJOs.

### What each style does (per form)

**Shikai** (most of every match: 101 s of 110 at HARD).
- **RENSA 連鎖, the chain link** (83 % of HARD matches): closes in, opens with J1, and the wheel turns.
- **KARIBA 刈場, the reaping ground**: holds 3-6 m, hops out of K1's dead zone, reaps every approach with the sideways sweep.
- **Either style, at HARD, 空蝉 UTSUSEMI**: whatever the opponent commits to near him, a J, a K, an L, an SP, a Breaker's
  dash, he is gone the moment it starts, nine times in ten while his flash-step lasts: he vanishes, the cicada's shell is
  left in the swing, and he reappears behind with the counter and the wheel. Where b3a1 stood and guarded two times in
  three, this one is never where the blade lands.
- **Either style, at HARD, once anything lands, 輪 RINNE** (J1 > L > K1 K2 > J3K > L > K1 K2 K3 > RAIDEN); one combo in ten
  花 HANA, the user's showpiece as written; one in ten 輪止 RINNE-OWARI (... K1 K2 > RAIDEN).
- **Either style, against a Hoho-er**: MIKIRI's walk-in (TSUME) once his sweep is perfect-Hoho'd over 42 % of the time.

**Bankai, ranged mode** (from 3000 taken; 5 s a match at HARD). The waiting chain: he stands at the chain tips (4-5.6 m)
and swings at nothing that stands still; the route styles SENTAN (K1's tip, the gathered K route), KAISEN (J1's tip, the
spread J route) and NAWAJI (the noose off the first link) are b1a0's. No noose straight out of the awakening any more.

**Bind** (3 s a match): **KOSHU, the race to the red** (b2a1's): every string he lands cinches (J1 > K2s > K3 or K1 > K2 >
K3, never J1 J2 J3); at a decision farther than 1.8 m he walks in to J1 (no neutral K1, no Step-in); a red victim's K link 2
goes into the chain rain. Behind on grey he lets go (b3a0's ledger); ahead he lets it drain.

### What a human notices
- At HARD he is the chain kusarigama most of the match, and **you can hardly touch him**: swing at him and he flickers away
  and hits you from behind, then the chain goes round twice. Bait the Hoho with a feint, or wait for his flash-step to run
  dry (he spends it fast now), then press.
- One combo in ten is the user's full showpiece with the three sickle spins.
- Hurt him for about two and a third souls and the Bankai comes; he waits at the chain's tip; in the bind he walks you down
  and every string ends with the chains pulled tight.
- **What sets it apart from earlier cells:** the first cell that looks at his defence to a committed move; it moves HARD
  strength by +0.08 over the same offence. The first to run b2a1's bind under the three-theme CPU.

## Mechanisms implemented (CPU parts only)

- **New** (`duel/lisp/hisagi.lisp`):
  - `*HS-AI-UTSUSEMI-P*` (0 / 0 / 0.9) and HS-AI-UTSUSEMI, called in HS-AI-REFLEX after the threat ward, the charge ward and
    the anti-Breaker J1: the generic Hoho's own test (a live J / K / L / SP / Breaker / Kikon near him, perceived >= 6 f of
    startup left, `HOHO-READY-P`, `AI-HOHO-SPARE-P`, no reflect, not rooted) on the brain's own per-action Hoho roll in
    `[kit :hoho, *HS-AI-UTSUSEMI-P*)`. Below the kit's 0.3 the generic Hohos as before; at EASY / NORMAL it never acts. No new
    random draw: the roll is BRAIN-HOHO-ROLL, one per opponent action (AI-EVENT-ROLLS).
  - Pacing counter `ai-utsusemi`.
- **Ported from round01 b2a1** (its CPU hunks, onto b3a0's ledger, which replaced b2a1's bind plans and drain margin):
  `*HS-AI-B-ROUTE-P*` (0 / 0.3 / 1.0), `*HS-AI-B-CLOSE-P*` (0 / 0 / 1.0), `*HS-AI-B-TODOME-P*` (b2a0's, 0.1 / 0.2 / 0.9),
  HS-ROLL, HS-B-AI-MOVE (the bind kit's new `:move-reflex`: the bind's TODOME on the grey margin HS-GREY-MARGIN, then the
  cinching route), HS-B-AI-REFLEX's walk-in (KOJO now returns its command), the bind kit's `:moves` (no neutral K1, no Step).
  Pacing counters `ai-b-route`, `ai-b-close`, `ai-b-todome`.
- **Changed:** `*HS-AI-WAKE-P*` 0.02 / 0.05 / 0.8 -> 0 / 0 / 0 (the waking noose off; the knob and its code kept).
- **Not touched:** HS-AI-OPP and its knobs; every move, rule and human hook; the art; HS-HASH and every HSS slot (none new);
  the sim ticks; every other file but the test section; the awakening gate (3000).
- **Kept working:** the awakening only through AI-AWAKEN-P's kit gate; the learner's clock (UTSUSEMI acts only on a committed
  move coming, NIL otherwise; HS-B-AI-MOVE only on his link hits); the ASSIST (UTSUSEMI is `:reflex` only, which the ASSIST
  does not call; HS-B-AI-MOVE reads the brain it is given); the debug modes 83000-83999 and the `duel hisagi` counters.
- Every chance an (:easy :normal :hard) plist, EASY <= NORMAL <= HARD (host-pinned), rolled once per event.
- **Host tests (the section):** the bind's `:move-reflex` pin now HS-B-AI-MOVE; UTSUSEMI's plist, its HARD above the kit's
  `:hoho`, and its contract on host fighters (NORMAL never; HARD below the kit's 0.3 or above its 0.9: NIL, no snap read);
  b2a1's HS-B-AI-MOVE contract (TODOME's NILs with the route off; at HARD the K link off J1 / K1 / K2s / J2, none off a K3, a
  block or out of a bind), the KOSHU chances, HS-ROLL, the bind's bands; the waking noose's pin updated to 0.

## Tried and dropped (960 HARD matches, seeds 1-80 both seats)

| variant | wins / 960 | signature | proxy | verdict |
|---|---|---|---|---|
| **this file** | **610** | 0.884 | **0.6324** | kept |
| UTSUSEMI 0.6 / 1.0 (with the waking noose) | 557 / 589 | 0.893 / 0.882 | 0.6206 / 0.6249 | 0.9 kept (597 with the noose) |
| 受け UKE: the guard against the rest of the committed moves, the generic's 0.35 -> 0.8 / 1.0 at HARD (its own per-action guard roll) | 592 / 613 | 0.886 / 0.886 | 0.6278 / 0.6347 | dropped: not monotonic, within noise (Kenpachi 57 -> 46 at 0.8: his Breaker); code removed |
| K1 punish 0.95 at HARD for both styles (RENSA 0.55, KARIBA 0.85) | 603 | 0.885 | 0.6307 | dropped |
| the gate 2500 / 3500 / 4500 | 578 / 588 / 573 | 0.884 / 0.884 / 0.883 | 0.6227 / 0.6255 / 0.6206 | 3000 kept (ranged + bind 0.12 / 0.03 / 0.00 of his damage at those) |

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, NORMAL, 60 seeds a stream; pairs 28 29 30 31 32 34)

The gate (3000) is unchanged and NORMAL plays b3a1's Shikai (UTSUSEMI and the dropped waking noose are HARD's / the
Bankai's; KOSHU acts only in a bind, which a never-awakening side never enters), so the never-awaken side is b3a1's. Re-run
at seed0 100 to confirm: the never-awaken side's wins of 60, this file / b3a1's:

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100 | 38 / 38 | 24 / 24 | 35 / 35 | 28 / 28 | 53 / 53 | 30 / 30 |
| 300 (b3a1's, by construction) | 33 | 23 | 41 | 28 | 47 | 24 |
| 500 (b3a1's, by construction) | 28 | 23 | 38 | 34 | 51 | 25 |

Every row is at least 23 of 60: it passes (the bar is 20). All 360 matches of the rerun are K.O.s; medians 102.8-150.0 s.
The baseline fails every row (0-4).

## Expected benefit and risks

**Benefit:**
- HARD strength +0.08 over the parent on 960 matches (Ichigo +40, Rukia +20, Kenpachi +10 of 160), for -0.014 signature:
  about +0.017 of score over b3a1 by the proxy, more than any round-01 refine moved it.
- The three themes stay in view (ranged + bind 0.068 of his damage), the bind plays b2a1's winning race.
- NORMAL, its share and the awaken A/B are b3a1's (UTSUSEMI is HARD's only).

**Risks:**
- **Signature -0.014:** the perfect Hoho's counter (60, plain) is 0.030 of his damage (0.015 before). A user who wants the
  chain to be everything may prefer a lower HARD chance (0.6: half the strength, a third of the signature cost).
- **Readability:** a HARD CPU that Hohos nine committed swings in ten (while its flash-step lasts) may feel like a wall to a
  human. The flash-step is the limit (30 a Hoho, 3 a second back): baiting one Hoho opens a 10 s window.
- The waking noose, b3a0's visible "noose right out of the awakening", is gone; KUBIKAKE stays off confirmed hits.
- **Pacing:** NORMAL plays b3a1's Shikai; the longest NORMAL median is Rukia's 172.4 s (cap 220, 48 s of margin), the others 114-162 s.
- Lille stays at 0-2 of 160 at HARD.

## Shared-code recommendations (not built)

- **The kit's `:hoho` is one number for every difficulty** (b0a0's note, again): a difficulty plist there would let a kit
  give HARD the Hoho it uses well without touching NORMAL's fair game; UTSUSEMI does it from his own reflex by re-reading the
  generic's roll.
- (Standing) AI-AWAKEN-P is one gate for every difficulty; the forced O ender on a red victim leaves a kit no say; ai.lisp's
  generic Step -> J reads only the kit's J1 reach.

# b2a2 (round 1, §25.15 freeze, a refine of b2a1): 縛口 SHIBARI-GUCHI, the bind's bite, and the noose sooner

Cell b2a2, round 1, freeze 3686d94. Branch b2's primary style: the bind (捆綁). PARENT_DIR b2a1 (0.8229, the round's best):
its `hisagi.lisp` copied over the frozen one and its HISAGI-CPU-TESTS section spliced in, then refined. Everything is in
`duel/lisp/hisagi.lisp`'s CPU parts and the host test's `HISAGI-CPU-TESTS` section.

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`)

| | baseline | b2a1 (parent) | b0a2 | b3a1 | **b2a2 (this file)** |
|---|---|---|---|---|---|
| **score** | 0.0 (raw 0.4149) | 0.8229 | 0.8203 | 0.8144 | **0.8325** (raw 0.8325) |
| strength (HARD, 480) | 0.006 | 0.565 | 0.552 | 0.552 | **0.598** |
| masher (HARD, 224) | 0.188 | 1.000 | 1.000 | 0.996 | **0.996** |
| signature | 0.751 | 0.907 | 0.909 | 0.899 | **0.908** |
| sig_by chain / ranged / bind | 0.373 / 0.204 / 0.174 | 0.812 / 0.046 / 0.049 | 0.901 / 0.005 / 0.004 | 0.806 / 0.062 / 0.031 | **0.795 / 0.050 / 0.063** |
| plain J / counter / Kikons / Breaker | 0.111 / 0.037 / 0.063 / 0.038 | 0.060 / 0.015 / 0.012 / 0.005 | 0.065 / 0.011 / 0.011 / 0.005 | 0.066 / 0.015 / 0.014 / 0.005 | 0.060 / 0.015 / 0.013 / 0.005 |
| NORMAL share (factor) | 0.104 (0) | 0.475 (1) | 0.527 (1) | 0.506 (1) | **0.508 (1)**: Y 54, K 24, R 30, I 38, S 67, Lille 31 of 80 |
| pacing (NORMAL medians, all 240 K.O.) | 115-175 s | 110.7-162.5 s | 104.2-157.8 s | 111.7-174.7 s | **109.7-167.8 s** (Rukia 167.8 the longest) |

`score.json` holds the exact JSON line of the final file (one 40-seed run of the frozen evaluator). The bind's share of his
damage is the largest of any 0.8+ cell (0.063), with the ranged theme at 0.050 (ranged + bind 0.113).

**The 960-match comparison** (HARD, seeds 1-80, both seats, aieval's strength runs with the combat log; the cell's
`bd.py`). The Shikai plays the same matches to the frame in every variant below (its time and rates are identical: 115.5 s
a match, 33.7 dealt / 22.4 taken a second), so these are paired comparisons of the awakened matches.

| 960 HARD matches | wins | signature | 0.3 s + 0.5 g | Y | K | R | I | S | Lille (of 160) | binds | drained | his first hit in a bind |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b2a1 (parent) | 533 | 0.896 | 0.6146 | 136 | 43 | 133 | 67 | 152 | 2 | 616 | 387 | 462 |
| + the bite (J1), KAMAE off | 550 | 0.898 | 0.6208 | 136 | 47 | 138 | 72 | 156 | 1 | 599 | 451 | 571 |
| + KAMAE (the fallback guard) | 550 | 0.898 | 0.6208 | 138 | 47 | 135 | 73 | 156 | 1 | 589 | 448 | |
| the bite, gate 2500 | 547 | 0.894 | 0.6178 | 139 | 52 | 131 | 68 | 154 | 3 | 921 | 724 | |
| the bite, gate 2000 | 532 | 0.892 | 0.6122 | 131 | 52 | 134 | 57 | 155 | 3 | 1362 | 1032 | |
| **the bite + SANGE 0.5 at HARD (this file)** | **561** | 0.896 | **0.6235** | 137 | 52 | 143 | 71 | 156 | 2 | 626 | 478 | 601 |
| the bite + SANGE 0.8 at HARD | 552 | 0.895 | 0.6201 | 135 | 53 | 139 | 67 | 156 | 2 | 623 | 473 | |

Per form (HARD, 960 matches): the bind dealt / taken a second **37.6 / 22.6 (parent) -> 46.6 / 20.4**; its drain share 0.63
-> 0.76; the ranged mode 10.5 / 30.8 -> 10.9 / 29.7; the time a match in the Bankai 16.4 + 8.3 s -> 16.1 + 8.5 s.

**Host tests:** duel-rules **9877 checks ALL PASS** (the frozen 9865 + 12 in the section: b2a1's 11, + 1 here; splicing
this file's section into the frozen file with `splice-tests.py` gives the delivered `duel-rules-test.lisp` byte for byte);
control 89, learn 131, input 33, cine 18 ALL PASS; touch 64, 0 failures; `tools/pkgcheck.sh duel` clean.

## History read, and what it says

| cell | mechanism | rescored | lesson used here |
|---|---|---|---|
| baseline | awoke at once; SAHARAI spam; the dead windmill string | 0.0 | — |
| prior b0a0-b3a0 (§25.12) | RENSA / KARIBA; the ranged fence; the blade gate + the bind plans SHIME / TSURUSHI; the reaping fence | 0.567-0.766 | the bind plans never showed (0.3 binds a match); the melee-share gate (not repeated: one gate, and the Bankai pays against Yamamoto / Senjumaru too, b3a1) |
| round01 b0a0 / b0a1 / b0a2 | the base Shikai; MIKIRI / TSUME; the combo's plan RINNE / OWARI / HANA (§25.16) | 0.783 / 0.7945 / 0.8203 | the Shikai is his strength; the plan converts (kept, as in the parent) |
| round01 b1a0 / b1a1 / b1a2 | the ranged routes; MACHI-GUSARI; TAIHO and the lash read | 0.7517 / 0.7741 / 0.7783 | the ranged neutral loses; cutting it was neutral in this CPU (b2a1's v2 / v6), TAIHO too (v5): not retried |
| round01 b2a0 | the bind first (KUBITSURI): gate 3000, the noose off every HARD hit, TSURI / SHIME, the drain margin | 0.7855 | drained binds +369 each |
| round01 **b2a1 (parent)** | b0a2's Shikai under b2a0's Bankai + 絞首 KOSHU (the cinching route, the walk-in), b1a1's leak fixes | **0.8229** | the bind is a race to the red: who hits first wins it (his first hit drained 477 of 637; the opponent's released 197 of 246) |
| round01 b3a0 / b3a1 | the three themes mixed; SANMI-RINNE: + b0a2's plan, the SHIBARI-after-RIN fix | 0.785 / 0.8144 | gate 3000 the peak on 960 matches; a located ender bug in every b0-based file (ported here) |

b2a1 measured the race (the first hit decides a bind) and changed the bind's routes and its walk-in, but not **how the race
starts**. Nobody had looked at the first 40 frames of a bind.

## The diagnosis (combat logs as aieval runs them; a debug build tracing the first 45 frames of every bind)

1. **The bind's first hit was given away at its start.** HARD, the parent, the awakening forced (120 matches, 292 binds):
   his first press in a bind came 20-29 f in (172 binds) or after 100 f (90 binds). By what he pressed first:
   - an early J1 (the generic follow-up): drained 104 of 135, every first hit his;
   - **an early KOJO: drained 11 of 37, the opponent's first hit in 22**; a late KOJO 12 of 29;
   - nothing for 100+ frames: the opponent attacks first (Kenpachi's FIRST-STRIKE J1 ~30 f in), released mostly.
2. **Why, frame by frame** (the debug trace): KUBIKAKE's hit has a 9 f hitstop; the victim's 30 f reel runs from there (to
   ~39 f in). The yank still slides him in until ~22 f in (4.3 m -> 2.0 m), and Hisagi guard-cancels KUBIKAKE at its f45-47,
   whose FIGHTER-GC-LEFT lets no attack start before ~22-23 f in. His brain (8 f delay) sees the new reel from ~17 f in, and
   the yank's distance 8 f late:
   - the generic follow-up J1 waits for the *perceived* distance under 2.1 m (~28 f in): it lands at ~36, 3 f inside a full
     reel, and not at all when the reel was cut short by the combo's hitstun decay (a long string before the noose);
   - the KOJO band (2.5-4 m) reads the same perceived mid-yank distance and rolls KOJO at the bind's entry: its yank at f20
     lands after the reel (blocked 134 of 242 KOJOs).
3. **A K1 opener can't make it** (built and measured, v1): K1 HIKIGIRI (S 18) from the lock's end lands ~40 f in, 1 f after
   the reel: 262 K1 openers, the opponent's first hit in 118, drained 160 of 300. J1 (S 8) from the lock's end lands ~31.
4. **The bind's value after the fix**: per second 46.6 dealt / 20.4 taken, the best form he has; vs Kenpachi 56.6 / 23.8
   while the Shikai is 33.4 / 29.9.

## The styles (行動方針) and the mix

| layer | roll | styles, chances (EASY / NORMAL / HARD) |
|---|---|---|
| the Shikai's chain style (b0a0's) | once a match (HS-AI-STYLE) | **RENSA 連鎖 55 %** / **KARIBA 刈場 45 %** |
| the Hoho read (b0a1's) | per event (a K1 into a Hoho-ready opponent) | **見切り MIKIRI** -> **詰 TSUME** the close-in: 0 / 0.2-0.3 / 0.75 |
| the combo's route plan (b0a2's, §25.16) | once per combo, at its first J1 / K1 hit (0 / 0 / 1.0) | **輪 RINNE 80 %** / **輪止 RINNE-OWARI 10 %** / **花 HANA 10 %** |
| the awakening (b2a0's kit gate) | AI-AWAKEN-P | at 3000 taken (re-measured: 2500 / 2000 not better, above) |
| **the ranged mode, a transit to the noose** (b2a0's, re-weighted here) | once per entry (HS-R-STYLE) | **SOKUBAKU 束縛** / **SANGE 散華**: 0.8 / 0.2 at EASY and NORMAL, **0.5 / 0.5 at HARD** (was 0.8 / 0.2); the noose off every confirmed hit (0 / 0 / 1.0) |
| **縛口 SHIBARI-GUCHI, the bind's bite (new)** | once per bind | J1 into the reel, the cinching route after it: 0 / 0.5 / 1.0 |
| the bind's plan (b2a0's) | once per bind (HS-B-PLAN) | **吊 TSURI 50 %** / **絞 SHIME 50 %** |
| the bind's play, 絞首 KOSHU (b2a1's) | per link hit / per neutral decision in the bind | the cinching route 0 / 0.3 / 1.0; the walk-in 0 / 0 / 1.0 |

(NORMAL never binds: its noose chance is 0, so the bind's chances act at HARD, and for the ASSIST's borrowed HARD brain.)

### 縛口 SHIBARI-GUCHI, the bind's bite (this cell, every bind)

The noose closes and he bites at once. In the first 40 frames of a bind (`*HS-AI-BITE-WINDOW*`), on his free steps:
- the victim seen in a reel with more frames left than J1's startup plus his own guard-cancel lock (FIGHTER-GC-LEFT), and his
  own yank's distance (`fighter-dist`, the move he just landed) within the follow-up's 2.1 m: **J1**, pressed during the lock
  so it starts the frame the lock ends (~23 f in) and lands at ~31, 8 f inside the reel;
- while the reel fits but the yank still drags him in: `:WAIT` (no KOJO roll, no generic answer on the perceived mid-yank
  distance);
- the KOJO band's roll is held while the window lasts (`*HS-AI-BITE-WINDOW*`).
Then b2a1's cinching route: **J1 -> K2s 巻斬 -> K3 絞 SHIBORI** (242), and when he is ahead the chain rain. HS-B-BITE-CMD
(pure, host-tested) decides; HS-B-AI-BITE holds the bind's one decision and its roll (`*HS-AI-BITE-P*`, one roll a bind).

### SANGE at HARD 0.5, the noose sooner (this cell)

After a drained bind both Reiatsu bars are empty, and the next noose needs his 200 back. SANGE's spread route earns Reiatsu
x1.3 (x1.69 on the tip): at 0.5 the next KUBIKAKE comes sooner (HARD, 960: binds 599 -> 626, drained 451 -> 478), the two
ranged faces now equally often. (0.8 overshoots: the ranged J1 is plain J, its signature share falls 0.74 -> 0.66.)

### The located ender bug (ported from round01 b3a1)

HS-AI-ENDER pressed SP2 SHIBARI after the J string's RIN. SHIBARI's slam (f46) lands only while its bind's 46 f stun outlasts
the combo's hitstun decay; b3a1 measured it blocked more than it landed as a string's SP. Every Shikai SP ender is RAIDEN now.
At HARD it never fired in this CPU (the plan bridges every J1: `ai-sp2` 0 in 960 HARD matches); it is NORMAL's / EASY's fix.

### What a human notices

- He fights most of the match as b0a2's chain kusarigama (RENSA's step-in J1 or KARIBA's reap at 3-6 m; once anything
  lands at HARD the chain goes round twice, one combo in ten the user's full showpiece HANA).
- About two and a half souls down, KARE, KAZESHINI: half his ranged stretches he lashes the spread chains from J1's tip (his
  Reiatsu fills fast), half he works the bundle from K1's; the noose off the first clean hit.
- **The noose closes and the short sickle is already in your face**: the instant the yank stops, J1, the chains wrapping,
  the bundle pulled tight (J1, K2s, K3), and when he is ahead the chain rain. No pulling at the rope with KOJO while you
  recover, no standing around while you come out of it: in 96 % of binds the first hit is his.
- When the bind still goes against him, he throws it off; when it goes his way, the grey souls turn real at the drain.

### How often (HARD, 960 matches, seeds 1-80, both seats)

Per match: 0.65 binds (0.50 drained, 0.15 released), 0.61 bites, 0.75 KUBIKAKE thrown (0.66 hit); TSURI 0.33 / SHIME 0.32;
2.1 cinching-route links, 2.3 walk-ins, 0.60 KOJOs; SANGE 0.51 / SOKUBAKU 0.58 entries; 9.3 RINNE, 1.3 RINNE-OWARI, 1.2 HANA
plans; 13.8 windmill bridges. His first hit in a bind: 601 of 626 (the parent 462 of 616).

## Tried and dropped (HARD, 960 matches unless noted)

| variant | result | verdict |
|---|---|---|
| v1: the bite with K1 HIKIGIRI as its opener (forced awakening, 120) | 262 K1 openers, the opponent's first hit 118, drained 160 of 300 (parent 172 of 292) | dropped: 1 f late by the rules (above); code removed |
| 構え KAMAE: when the reel is seen too short for J1, guard through its end + 16 f (the opponent's first strike blocked) | 550 / 550 wins, 0.17 a match (forced) | dropped: neutral, it rarely fires; code removed |
| the gate 2500 / 2000 with the bite | 547 / 532 vs 550 (3000) | 3000 kept (2500: the bind theme 0.14 of his damage, the same score within noise) |
| SANGE 0.8 at HARD | 552 vs 561 (0.5) | 0.5 kept |

## Mechanisms implemented (CPU parts only)

- **New functions:** HS-B-BITE-CMD (pure, host-tested), HS-B-AI-BITE (the bind's reflex, first after the release).
- **Changed:** HS-B-AI-REFLEX (the bite first; no KOJO roll in the bite's window); HS-AI-ENDER (RAIDEN, never SHIBARI).
- **Knobs:** new `*HS-AI-BITE-P*` (0 / 0.5 / 1.0), `*HS-AI-BITE-WINDOW*` 40; changed `*HS-AI-SANGE-P*` HARD 0.2 -> 0.5.
- **HSS CPU slot:** `ai-bite-from` (the bind whose bite was decided); not hashed.
- **Pacing counter:** `ai-bite`.
- **Not touched:** HS-AI-OPP and its knobs, every move, rule and human hook, the art, HS-HASH, the sim ticks, every other
  file but the test section; the awakening gate (3000).
- **Kept working:** the awakening only through AI-AWAKEN-P's kit gate; the learner's clock (the bite acts only in a bind's
  first 40 frames, once, :WAIT only while the yank runs); the ASSIST (the bite is :reflex only, which the ASSIST doesn't
  call); the debug modes 83000-83999 and the `duel hisagi` line. Every chance EASY <= NORMAL <= HARD (host-pinned), rolled
  once per event (a bind, an entry, a combo, a match).
- **Host tests (the section):** b2a1's checks kept; the bite's chance and window, HS-B-BITE-CMD's contract (J1 when its
  startup fits after the lock and he is in reach, :wait while the yank brings him in, nothing yet otherwise), the HARD SANGE
  pin.

## Why it is not a repeat

- The bite is new: no cell looked at a bind's first frames. It rests on a located cause (traced frame by frame: the yank, the
  hitstop, the guard-cancel lock, the perception delay of the distance) and fixes it in the bind's own reflex. b2a1 changed
  what the bind's strings are; this changes who strikes first, which b2a1 measured as what decides a bind.
- The KOJO fix is a located bug (the band rolled on a perceived mid-yank distance).
- The ender fix is round01 b3a1's located bug, ported and credited.
- SANGE's weight is a re-weighting of b1a0's mix for a reason this CPU didn't have before (the bind is now worth more, so the
  Reiatsu for the next noose is); measured on 960 paired matches.

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, NORMAL, 60 seeds a stream; pairs 28 29 30 31 32 34)

The gate is the parent's (3000), unchanged, but the never-awaken side's NORMAL Shikai changed (the RAIDEN ender), so the
A/B was run on all three streams. The never-awaken side's wins of 60, this file / b2a1's (= b0a1's) / round01 b3a1's:

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100 | 38 / 39 / 38 | 24 / 21 / 24 | 35 / 35 / 35 | 28 / 26 / 28 | 53 / 52 / 53 | 30 / 32 / 30 |
| 300 | 33 / 30 / 33 | 23 / 23 / 23 | 41 / 40 / 41 | 28 / 28 / 28 | 47 / 48 / 47 | 24 / 22 / 24 |
| 500 | 28 / 30 / 28 | 23 / 22 / 23 | 38 / 36 / 38 | 34 / 34 / 34 | 51 / 49 / 51 | 25 / 25 / 25 |

- Every row is at least 23 of 60: it passes (the bar is 20). All 1080 matches are K.O.s; medians 102.8-152.4 s.
- The rows equal round01 b3a1's to the match: the never-awaken side is the same NORMAL Shikai (b0a1's with the RAIDEN
  ender). HK (23-24) stays the closest to the bar, now 1-3 wins further from it than the parent's.

## Expected benefit and risks

**Benefit:**
- The bind, the user's 「捆綁」, becomes the form that decides his comebacks: drain share 0.63 -> 0.76, his first hit 96 %,
  46.6 dealt / 20.4 taken a second; +28 HARD wins of 960 (paired) over the parent, signature equal.

**Risks:**
- **Noise.** The paired 960-match gain is about +0.03 of strength (about 1.5 standard errors of a paired difference); a
  40-seed rescore moves ±0.01-0.02 of score.
- **Lille stays 1-3 of 160 at HARD**, as in every cell; Kenpachi rises (43 -> 52 of 160) but stays the hardest of the rest.
- **The ranged mode still bleeds** (10.9 dealt / 29.7 taken a second at HARD): its neutral swings (b2a1's note) are untouched.
- **NORMAL** plays b2a1's NORMAL plus the RAIDEN ender fix (NORMAL never binds; SANGE's NORMAL value is unchanged).

## Shared-code recommendations (not built)

- **The guard cancel after a hit that already confirmed a reel** (AI-REFLEX's guard-cancel clause) reads the perceived reel,
  which lags a hitstop: it guard-cancelled KUBIKAKE while the victim was about to reel 30 f, and FIGHTER-GC-LEFT then locked
  his attacks for ~10 f. A hitstop-aware read (or a kit veto) would let every kit with a long-reel hit start its follow-up
  sooner.
- (Standing) ai.lisp's generic Step -> J is the ranged mode's largest leak; AI-AWAKEN-P is one gate for every difficulty
  (the bind against Kenpachi is worth an earlier awakening there, not elsewhere).

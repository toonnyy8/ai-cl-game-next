# b3a0 (round 1, §25.15 freeze): 三味 SANMI, the three themes mixed by probability: chain first, the Bankai in half the matches

Cell b3a0, round 1, freeze 3686d94. Branch b3's primary style: a probabilistic mix of all three themes. PARENT_DIR none: a new
direction from BASELINE_DIR. It is a new combination of this round's two measured cells, plus four mechanisms of this cell.
- From round01 b0a0 (0.783): the Shikai, ported whole, since it runs on this freeze's sim.
- From round01 b1a0 (0.7517): the Bankai's route styles, ported as its CPU hunks.
- New here: the gate moved by measurement, the Shikai style weighted by difficulty, the reap's approach proof, the waking
  noose, and the bind's ledger.

Everything is in `duel/lisp/hisagi.lisp`'s CPU parts and the host test's `HISAGI-CPU-TESTS` section.

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`)

| | baseline | b0a0 | b1a0 | **b3a0 (this file)** |
|---|---|---|---|---|
| **score** | 0.0 (raw 0.4149) | 0.783 | 0.7517 | **0.785** (raw 0.785) |
| strength (HARD, 480) | 0.006 | 0.435 | 0.400 | **0.490** |
| masher (HARD, 224) | 0.188 | 1.000 | 1.000 | **1.000** |
| signature | 0.751 | 0.905 | 0.863 | **0.876** |
| sig_by chain / ranged / bind | 0.373 / 0.204 / 0.174 | 0.895 / 0.005 / 0.005 | 0.605 / 0.175 / 0.083 | **0.757 / 0.079 / 0.041** |
| plain J / counter / Kikons (Shikai, ranged, bind) / Breaker | 0.111 / 0.037 / 0.063 / 0.038 | 0.055 / 0.013 / 0.024 / 0.004 | 0.050 / 0.020 / 0.060 / 0.005 | 0.064 / 0.020 / 0.033 / 0.008 |
| NORMAL share (factor) | 0.104 (0) | 0.525 (1) | 0.5625 (1) | **0.5625 (1)**: Y 57, K 26, R 32, I 47, S 71, Lille 37 of 80 |
| pacing (NORMAL medians, all 240 K.O.) | 115-175 s | 104-158 s | 115-167 s | **110.0-163.9 s** (Lille 163.9 the longest) |

`score.json` holds the exact JSON line.

**HARD wins by opponent** (seeds 1-40, both seats, of 80; the diagnostic runner, which matches aieval's strength to the
match):

| | Y | K | R | I | S | Lille |
|---|---|---|---|---|---|---|
| this file | 58 | 14 | 64 | 20 | 77 | 2 |
| b0a0 | 56 | 8 | 66 | 8 | 71 | 0 |

**Per form at HARD** (480 matches): dealt / taken a second, and time in each form a match.

| form | time a match | dealt / taken a second |
|---|---|---|
| Shikai | 113.6 s | 26.2 / 22.8 |
| ranged mode | 25.0 s | 10.9 / 27.0 |
| bind | 6.9 s | 34.1 / 22.1 |

**Host tests:**
- duel-rules: 9869 checks, ALL PASS. That is the frozen 9865 plus 4 in the section. Splicing this file's section into the
  frozen file (`splice-tests.py`) gives this file byte for byte.
- control 89, learn 131, input 33, cine 18: ALL PASS. touch 64: 0 failures.
- `tools/pkgcheck.sh duel`: clean.

## History read, and what it says

| cell | mechanism | rescored | lesson used here |
|---|---|---|---|
| baseline | awoke at once; SAHARAI spam, the dead windmill string | 0.0 | — |
| prior b0a0 (§25.12) | RENSA / KARIBA, the bridge K at f9, the 4500 gate | 0.637 | the Shikai is his strength |
| prior b1a0 | the ranged fence, three ranged styles, awoke at once | 0.567 | the fence beats the masher; the Bankai costs HARD |
| prior b2a0 | b0a0 + b1a0 behind a blade-share gate, bind styles | 0.684 | the Bankai only where it pays |
| prior b3a0 | b0a0 + b1a0 + the reaping fence, gate 4500 | 0.766 | ranged + bind 1 % of his damage |
| round01 b0a0 | prior b3a0 ported, plus KAZAGURUMA-GAESHI (charge ward → charged sweep) and TODOME (a red link 2 → RAIDEN) | **0.783** | the best Shikai; ranged + bind 1 % |
| round01 b1a0 | prior b3a0 ported, plus SENTAN / NAWAJI / KAISEN (the tip routes), gate 2000, NORMAL cuts | 0.7517 | the themes visible (25 %) for −0.03, mostly signature |

From the history and my own measurements I took four points:
1. **The bind wins and the ranged mode loses at HARD, in every cell.** Here the bind deals 34 and takes 22 a second; the
   ranged mode deals 11 and takes 27. Forced awakening at once: 0.392 at HARD over 240 P1 matches.
2. **Earlier gates looked costly at 10 seeds, but that was noise.** Over 1200 matches the 3000 gate costs nothing at HARD
   (below). b1a0's −0.03 came from its signature: its Shikai lacked b0a0's layers, and its Bankai's J1 and Kikons are
   plain damage.
3. **20- and 40-seed differences between variants are noise.** About ±0.023 strength at 480 matches. So I compared every
   variant at HARD over 1200 matches (seeds 1-40 plus 101-160), with the proxy 0.3 strength + 0.5 signature, and checked
   NORMAL and the masher with aieval.
4. **A located bug in the reaping fence** (prior b3a0's), from the combat log against Lille:
   - The reap fires on any step whose perceived closing speed tops 1.5 m/s. Lille's stance step reads as one step at
     3.6 m/s from 6-7 m.
   - So K1 swept the air every 59 frames, and her charged shot landed on its recovery.
   - At HARD, 913 of 1784 reaps whiffed. Every cell since prior b3a0 had it.

## The styles and the mix (the 行動方針)

| layer | roll | styles, weights / chances (EASY / NORMAL / HARD) |
|---|---|---|
| the Shikai's chain style, 始解鎖鐮連段 | once a match (HS-AI-STYLE, SIM-RND01), **by difficulty** | **RENSA 連鎖** / **KARIBA 刈場**: 0.55 / 0.45 at EASY and NORMAL, **0.8 / 0.2 at HARD** |
| per charge, ward, link hit (b0a0's) | once per event | KAZAGURUMA-GAESHI (ward 0.7-0.9, sweep 0.7-0.9 HARD by style), TODOME 0.2 / 0.4 / 1.0, the bridge, the leap, RAIDEN ender |
| **the awakening** | the kit gate `:awaken (:min-taken 3000)` (AI-AWAKEN-P) | the Bankai once he has taken 3000 |
| **the waking noose** (new) | once per awakening | 0.02 / 0.05 / 0.8: KUBIKAKE thrown within 300 f of the awakening, once its line holds him and he isn't attacking |
| the ranged mode's route style, 卍解遠距路線 (b1a0's) | once per entry into it (the awakening, every bind's end) | **SENTAN 尖端 60 %** / **KAISEN 回旋 25 %** / **NAWAJI 縄路 15 %** |
| **the bind's ledger, 捆綁** (new) | per change event (every 50 of the pool drained, any Konpaku change) | release 0.05 / 0.1 / 0.9 when behind on grey by 150, **by any margin once the pool is ≤ 150**; KAIBAKU-GEKI within 2.8 m, else FREE 0.05 / 0.1 / 0.9 |

Every chance is an (:easy :normal :hard) plist, EASY ≤ NORMAL ≤ HARD (host-pinned). Each is rolled once per event: a match,
a form entry, an awakening, a charge, a link hit, a change of the pool.

### What each style does (per form)

**Shikai**, behind b3a0's reaping fence. At HARD the approach now has to hold 3 perceived steps (`*HS-AI-REAP-SUSTAIN*`
1 / 1 / 3: EASY and NORMAL keep b0a0's one-step read, so the awaken A/B's never-awaken side is b0a0's Shikai unchanged).
- **RENSA 連鎖, the chain link** (80 % of HARD matches, 55 % below).
  - He closes in and opens with J1.
  - Off a J hit he takes the windmill bridge (J → L → charged K1 → K2 → K3 → RAIDEN) at 0.85 at HARD.
  - The leap J2K / J3K brings him back in.
  - He reaps an approach at 0.7 at HARD.
- **KARIBA 刈場, the reaping ground.**
  - He holds 3-6 m, hops out of K1's dead zone (0.9), reaps every approach (0.9) and K1-punishes whiffs at range.
  - Off a J hit he takes the K link first.
- **Both styles:**
  - The windmill comes up against a shot that is being charged, then sweeps with the charged K string
    (KAZAGURUMA-GAESHI).
  - A red victim's link 2 goes into RAIDEN, not the forced Kikon (TODOME).

**Bankai, ranged mode** (from 3000 taken). He holds the chain tips' distance, 4-5.6 m, and waits for a commitment.
- **SENTAN, the tip reaper:**
  - punishes with the opener whose tip holds the opponent (K1 at 4-5 m);
  - plays the gathered K route to its end (K1 → K2 → K3G on the tip, x1.71);
  - throws the noose off the ender.
- **KAISEN, the Reiatsu wheel:** J1's tip at 5-6 m, then the spread J route. J3's 6.6 m push puts the opponent back on the
  tip.
- **NAWAJI, the noose road:** K1 first, then KUBIKAKE's cancel off the first link that hits.
- **The waking noose** (new, every style): right after the awakening's cinematic, KUBIKAKE goes for the bind at once,
  80 % of HARD awakenings.

**Bind** (the ledger, new). He fights the melee set close in.
- While the pool is high, he releases only when 150 behind on grey.
- Once the pool is down to 150 (450 more damage drains it), he releases at any grey deficit. A drained end while behind
  would turn his loss real; a release costs only the rest of the pool.
- He releases with KAIBAKU-GEKI (+120 real) only within its reach. Farther away he uses FREE at once: before, 128 of 150
  KAIBAKU-GEKIs whiffed, each followed by a 28 f recovery.
- Ahead on grey, he spends the pool's SP off a link 3 and lets it drain. A grey Kikon (3 Konpaku) then turns real.

### What a human notices
- He fights most of the match in the Shikai's chain kusarigama. At HARD it is mostly RENSA: J1, the windmill flick, then
  the long reaping K string and lightning.
- Once you have hurt him for about two and a third souls, KARE, KAZESHINI: the Bankai.
  - At HARD the noose flies right out of the awakening four times in five; it often misses a moving target.
  - Otherwise he backs off to the chain tips and punishes from there.
- In the bind he presses close. When he is losing the exchange and the bind is about to run dry, he lets go: the chains
  fall slack and both of you are restored. When he is winning, he lets it run out and your grey souls turn black.

## Mechanisms implemented (CPU parts only)

- **Ported:**
  - round01 b0a0's file whole. It is this freeze's sim plus its CPU.
  - round01 b1a0's Bankai CPU hunks (its b0a0 → b1a0 diff, Bankai hunks only):
    - `*HS-AI-R-STYLE-W*` and `*HS-AI-R-STYLES*` (SENTAN / NAWAJI / KAISEN) and HS-R-TIP-CMD;
    - the tip pick in HS-R-PICK and in the anti-approach strike;
    - :WAIT after a blocked string;
    - `:kubi-at`;
    - the ranged kit's `:ranges`;
    - its NORMAL values;
    - HARD KUBIKAKE 0.95.
  - KUBIGARI, SANGE and SOKUBAKU are gone, and so is the HSS slot `ai-mid`.
  - b0a0's FREE fallback in HS-B-AI-REFLEX is kept. b1a0 had dropped it.
- **New knobs:**
  - `*HS-AI-REAP-SUSTAIN*` (:easy 1 :normal 1 :hard 3), read by HS-P;
  - `*HS-AI-WAKE-P*`, `*HS-AI-WAKE-WINDOW*` 300;
  - `*HS-AI-REL-LOW*` 150, `*HS-AI-KAIBAKU-REACH*` 2.8.
- **New function:** HS-REL-BAR (pure, host-tested).
- **New HSS CPU slots:** `ai-app-n`, `ai-wake`, `ai-wake-t`. None is hashed.
- **Changed:**
  - `*HS-AI-STYLES*` is now by difficulty (HS-AI-STYLE reads `(ai-brain e)`'s).
  - `*HS-AI-AWAKEN*` 4500 → 3000.
  - `*HS-AI-PLAIN-RELEASE-P*` 0.1 / 0.15 / 0.2 → 0.05 / 0.1 / 0.9. It is now the release whenever he is beyond
    KAIBAKU-GEKI's reach.
  - NORMAL's fair game (EASY lowered the same way; HARD untouched). With the gate at 3000, NORMAL measured 0.6208, then
    0.6104 with NORMAL's one-step reap. Cutting NORMAL's Bankai values brought it to 0.562 (480 matches):
    - `*HS-AI-PUNISH-P*` 0.35 → 0.1, `*HS-AI-ANTI-P*` 0.25 → 0.1;
    - `*HS-AI-ESCAPE-P*` 0.35 → 0.2, `*HS-AI-DODGE-P*` 0.2 → 0.1, `*HS-AI-R-ANTI-BREAKER-P*` 0.35 → 0.2;
    - `*HS-AI-THROW-P*` 0.1 → 0.05;
    - `*HS-AI-RELEASE-P*` 0.3 → 0.1, `*HS-AI-PLAIN-RELEASE-P*` 0.1, `*HS-AI-BIND-SP-P*` 0.15 → 0.1;
    - `*HS-AI-WAKE-P*` 0.05.
  - HS-AI-FENCE requires the approach over 3 steps at HARD. HS-R-STYLE rolls the waking noose on an entry from the Shikai.
    HS-R-AI-REFLEX fires it. HS-B-AI-REFLEX is the ledger.
- **Pacing counters:** `ai-wake-noose` (HS-R-AI-REFLEX's `fire`), joining b0a0's and b1a0's.
- **Not touched:**
  - HS-AI-OPP and its knobs;
  - every move, rule and hook for a human, and the art;
  - HS-HASH, and HS-KAZA-TICK's human branch;
  - every other file except the test section.
- **Kept working:**
  - The awakening goes only through AI-AWAKEN-P's kit gate, so the debug :always / :never modes win.
  - The learner's clock: every new read acts on an event and returns NIL otherwise.
  - The ASSIST: HS-AI-STYLE reads `ai-brain`. The new Bankai code is :reflex only, which the ASSIST doesn't call.
  - The debug modes 83000-83999 and the `duel hisagi` line.

## Tried and dropped (HARD over 1200 matches: seeds 1-40 / 101-160; proxy = 0.3 str + 0.5 sig)

| variant | strength | proxy | verdict |
|---|---|---|---|
| b0a0 as delivered | 0.435 / 0.415 | 0.5888 / 0.5828 | the reference |
| + reap over 6 steps | 0.442 / 0.439 | 0.5836 / 0.5836 | fewer K strings: signature −0.013 |
| + b1a0's routes, the ledger (gate 4500) | 0.456 / 0.436 | 0.5879 / 0.5826 | aieval 0.7774 (sig 0.888) |
| a runner exempt from the proof (v > 5 m/s) | 0.410 / 0.406 | 0.574 / 0.573 | dropped |
| the waking noose, HARD style 0.8, gate 4500 | 0.465 / 0.444 | 0.5902 / 0.5846 | |
| ... gate 3000 | 0.463 / 0.478 | 0.5854 / 0.5907 | aieval: NORMAL 0.6208 (factor 0.86) → NORMAL cuts |
| ... gate 2000 | 0.419 / 0.460 | 0.5676 / 0.5802 | dropped |
| gate 3000 + NORMAL cuts + the proof over 3 steps (**this file**) | **0.490 / 0.467** | **0.5938 / 0.5880** | aieval **0.785** |
| ... the proof over 2 steps | 0.465 / 0.454 | 0.5863 / 0.5839 | dropped |
| ... gate 2500 / 3500 | 0.446 / 0.463, 0.467 / 0.440 | 0.5780 / 0.5847, 0.5885 / 0.5822 | 3000 kept |
| ... HARD RENSA 0.9 | 0.487 / 0.465 | 0.5926 / 0.5874 | ≈; 0.8 kept (KARIBA stays visible) |
| ... no waking noose | 0.473 / 0.467 | 0.5890 / 0.5879 | the noose kept (+0.002, within noise; 221 throws, 33 hit, 35 blocked, 153 whiffed at HARD) |
| ... ranged TODOME (a red link 2 → ranged RAIDEN) | 0.444 / 0.478 | 0.5806 / 0.5911 | dropped (no signal) |
| ... the ranged :hoho 0.9 → 0.6 | 0.477 / 0.463 | 0.5896 / 0.5864 | dropped (the key is NORMAL's too) |
| ... the bind's ledger vs b0a0's release (P1 always awakened, 240 HARD) | 0.388 vs 0.392 | | neutral; kept for the release's logic, not for a number |

## Why it is not a repeat
- The mix is new. b0a0's Shikai and b1a0's route styles had never run together. The gate went where the 1200-match
  measurement put it, not where the 10-seed runs had (4500).
- The reap's approach proof fixes a located bug in prior b3a0's fence. Every cell since carried it.
- The waking noose and the ledger are new Bankai mechanisms:
  - No cell threw the noose off the awakening. KUBIGARI threw it from neutral per stay.
  - No cell keyed the release to the pool left, or split KAIBAKU-GEKI from FREE by reach.
- The HARD style weights come from a forced-style measurement: RENSA 217 of 480, KARIBA 190.

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, NORMAL, 60 seeds a stream; pairs 28 29 30 31 32 34)

Never-awaken side's wins of 60 (this file / round01 b0a0's):

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100 | 36 / 36 | 21 / 21 | 35 / 35 | 25 / 25 | 51 / 51 | 31 / 31 |
| 300 | 29 / 29 | 23 / 23 | 42 / 42 | 29 / 29 | 48 / 48 | 22 / 22 |
| 500 | 31 / 31 | 22 / 22 | 35 / 35 | 33 / 33 | 48 / 48 | 24 / 24 |

- Every row is at least 21 of 60: the A/B passes (the bar is 20). Every match is a K.O.; medians 103.4-153.3 s.
- The rows equal b0a0's to the match. The never-awaken side is b0a0's NORMAL Shikai unchanged: NORMAL's styles and its
  one-step reap are kept, and every other change of this cell is HARD's or the Bankai's.
- The baseline fails every row (0-4 of 60, b0a0's measure).
- With the 3-step reap at NORMAL too, the never-awaken side fell under the bar: HK 17 / 19 / 19 and HB 26 / 18 / 21. So
  the proof is HARD's only.

## Expected benefit and risks
**Benefit:**
- The score rises to 0.785, the round's best so far (b0a0 0.783), with the three themes visible. Ranged + bind is 12 % of
  his HARD damage (b0a0: 1 %), and a HARD match spends 32 s in the Bankai (25 s ranged, 7 s bound) against 114 s in the Shikai.
- HARD strength is the best measured: 0.490. Kenpachi goes 8 → 14 and Ichigo 8 → 20 of 80.

**Risks:**
- **The signature is 0.876**, below b0a0's 0.905. The Bankai's J1, its Kikons and the Hoho counters are plain damage.
  Strength pays for it, by a margin within the noise (+0.002).
- **NORMAL is 0.5625**, 0.04 under the band's top. Uncut, the 3000 gate put NORMAL at 0.61. NORMAL's Bankai values are
  now low (0.05-0.2); a refine that strengthens them crosses 0.60.
- **Lille stays near 0 at HARD** (2 of 80).
- The waking noose whiffs often (153 of 221). A whiff costs 60 f; it is kept for the theme, at a measured +0.002.
- **Pacing:** the longest median is 163.9 s (cap 220): no risk.

## Shared-code recommendations (not built)
- **AI-AWAKEN-P is one gate for all difficulties and opponents.** Against Kenpachi the Bankai at 2000 taken wins 20 of 80
  (12 at 3000); against Ichigo and Yamamoto it loses. Prior b2a0 / b3a0 and round01 b1a0 asked for this hook too. A kit
  hook (`:awaken-ok`, still under the debug modes) would let a read of the opponent's blades, or a difficulty, pick the
  gate.
- **The kit's `:hoho` is one number for every difficulty** (b0a0's note). The Bankai's 0.9 feeds plain counters (2 % of
  his damage) and can't be cut for HARD alone.
- **The generic forced O ender on a red victim** (b0a0's note) still makes 3.3 % of his damage a plain Kikon across his
  three forms.

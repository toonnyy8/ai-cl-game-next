# b0a1 (round 1, §25.15 freeze, a refine of b0a0): 見切り MIKIRI, the Hoho read, and 詰 TSUME, the chain brought in by hand

Cell b0a1, round 1, freeze 3686d94. Branch b0's primary style: the Shikai chain (鎖鐮連段). PARENT_DIR b0a0 (0.783):
its `hisagi.lisp` copied over the frozen one and its HISAGI-CPU-TESTS section spliced in, then refined. Everything is in
`duel/lisp/hisagi.lisp`'s CPU parts and the host test's `HISAGI-CPU-TESTS` section.

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`)

| | baseline | b0a0 (parent) | b2a0 | b3a0 | **b0a1 (this file)** |
|---|---|---|---|---|---|
| **score** | 0.0 (raw 0.4149) | 0.783 | 0.7855 | 0.785 | **0.7945** (raw 0.7945) |
| strength (HARD, 480) | 0.006 | 0.435 | 0.458 | 0.490 | **0.498** |
| masher (HARD, 224) | 0.188 | 1.000 | 1.000 | 1.000 | **1.000** |
| signature | 0.751 | 0.905 | 0.896 | 0.876 | **0.890** |
| sig_by chain / ranged / bind | 0.373 / 0.204 / 0.174 | 0.895 / 0.005 / 0.005 | 0.777 / 0.066 / 0.053 | 0.757 / 0.079 / 0.041 | **0.881 / 0.005 / 0.004** |
| plain J / Kikons / counter / Breaker | 0.111 / 0.063 / 0.037 / 0.038 | 0.055 / 0.024 / 0.013 / 0.004 | 0.054 / 0.027 / 0.018 / 0.005 | 0.064 / 0.033 / 0.020 / 0.008 | 0.069 / 0.023 / 0.012 / 0.006 |
| NORMAL share (factor) | 0.104 (0) | 0.525 (1) | 0.454 (1) | 0.5625 (1) | **0.527 (1)**: Y 48, K 26, R 48, I 42, S 64, Lille 25 of 80 |
| pacing (NORMAL medians, all 240 K.O.) | 115-175 s | 104-158 s | 111-162 s | 110-164 s | **104.2-157.8 s** (Rukia 157.8 the longest) |

`score.json` holds the exact JSON line. The file was measured twice at 40 seeds (before and after a docstring-only pass):
the same JSON both times.

**HARD wins by opponent, paired** (seeds 1-20, both seats, 40 a row; the same file with the read switched off by its
knobs, which is b0a0's Shikai):

| | Y | K | R | I | S | Lille | total | signature |
|---|---|---|---|---|---|---|---|---|
| read off (b0a0's play) | 32 | 6 | 32 | **2** | 38 | 0 | 110 / 240 (0.458) | 0.902 |
| **this file** | 32 | 8 | 32 | **14** | 38 | 0 | **124 / 240 (0.517)** | 0.889 |

The perfect Hohos against him over those 40 matches each: Ichigo 337 → 175, Rukia 295 → 203, Kenpachi 175 → 133;
Yamamoto, Senjumaru and Lille unchanged (the read stays off against them).

**Host tests:**
- duel-rules: 9869 checks, ALL PASS (the frozen 9865 + b0a0's 2 + 2 of this cell, in the section only). Splicing this
  file's section into the frozen file (`splice-tests.py`) gives this file byte for byte.
- control 89, learn 131, input 33, cine 18: ALL PASS. touch 64: 0 failures.
- `tools/pkgcheck.sh duel`: clean.

## History read, and what it says

| cell | mechanism | rescored | lesson used here |
|---|---|---|---|
| baseline | awoke at once; SAHARAI spam; the dead windmill string | 0.0 | — |
| prior b0a0-b3a0 (§25.12) | RENSA / KARIBA, the bridge K at f9, the reaping fence, the ranged fence, the late awakening | 0.637-0.766 | the Shikai is his strength; K1 is perfect-Hoho'd |
| round01 b0a0 | prior b3a0 ported + KAZAGURUMA-GAESHI (the charge ward's sweep) + TODOME (a red link 2 into RAIDEN); MACHI-GAMA (the reap skipped against a perfect-Hoho reader) tried and dropped | 0.783 | the parent; MACHI-GAMA gained Ichigo, lost Yamamoto / Rukia / Senjumaru |
| round01 b1a0 | the ranged routes on the chain tip, gate 2000 | 0.7517 | the Bankai costs HARD and signature |
| round01 b2a0 | the bind first, gate 3000 | 0.7855 | the gate is strength-neutral; NORMAL is the heal's |
| round01 b3a0 | b0a0 + b1a0's routes, gate 3000, the reap's approach proof at HARD | 0.785 | HARD 0.490, signature 0.876: the same score |

Every round-01 cell sits at 0.75-0.79: none touched the cause of most of his HARD losses, the perfect Hoho of his K1.
MACHI-GAMA came closest, but it fired on one perfect Hoho, so it also hit the CPUs who Hoho rarely, where the reap pays.
And when it held the reap back, nothing took its place.

## The diagnosis (combat logs as aieval runs them, b0a0's file, HARD, 10-20 seeds a pairing; scripts in the cell's scratch)

1. **The perfect Hoho is his biggest leak.**
   - 494 perfect Hohos against him in 120 HARD matches; 422 of them on a K1 (the reap: 327 of 1784, the neutral K1: 95 of
     498). Each costs the 60 counter plus the string after it, about 200-230 in all.
   - Why: K1 has an 18 f startup. The opponent sees it at f9 with ≥ 6 f to go, and its hit lands within the 12 f perfect
     window, so the Hoho is perfect. J1 (S 8) is already active when it is seen, so no Hoho reads it.
2. **The rate depends on the opponent and on whether he can Hoho.** The reap's K1 is perfect-Hoho'd when he is free, has a
   Hoho's flash-step and no Hoho of his was just seen:
   - Ichigo 55 %, Kenpachi 37 %, Rukia 30 %, Yamamoto 8 %, Senjumaru 7 %, Lille 0 %;
   - 0-8 % when he can't Hoho.
3. **The net damage of an opener, 4 s after it, per opponent** (b0a0's file):

   | opener | vs Ichigo | vs Kenpachi | vs Rukia | vs Yamamoto |
   |---|---|---|---|---|
   | the reap's K1 | −47 | +41 | +58 | +99 |
   | the neutral K1 | −118 | +3 | +67 | +13 |
   | the step-in J1 | +136 | +91 | +190 | +38 |
   | the neutral J1 | +153 | +110 | +234 | +16 |

   Against the Hoho-ers the close J1 is worth far more than K1. Against Yamamoto, Senjumaru and Lille (J1 −166 / −236) the
   reap is the better play.
4. **Measured, not used:**
   - b3a0's reap proof (an approach must hold 3 perceived steps at HARD). It is a located bug, Lille's stance step read as
     a 3.6 m/s approach, but on this file it costs Yamamoto 32 → 25 and Rukia 32 → 27 of 40: 110 → 101 of 240. Dropped.
   - The reap window's far end (70 % of its reaps predicted at 5.0-5.6 m whiff): narrowed to 4.9 m it changed nothing in
     wins.

## The styles and the mix (the 行動方針)

| layer | roll | styles, chances (EASY / NORMAL / HARD) |
|---|---|---|
| the Shikai's chain style, 始解鎖鐮連段 | once a match (HS-AI-STYLE, SIM-RND01) | **RENSA 連鎖 55 %** / **KARIBA 刈場 45 %** (b0a0's, unchanged) |
| **見切り MIKIRI, the Hoho read** (new) | read on events: each K1 of his into an opponent able to Hoho, resolved as Hoho'd or not | turns the match's chain style toward **詰 TSUME** while the read is over its bar and the opponent can Hoho |
| TSUME: the reap or the hop held back | once per fence decision (an approach's reap at its K1, a dead-zone stay's hop) | 0 / 0.2 / 0.75 |
| TSUME: the close-in | once per stay in the step-in or far band, and once per neutral decision due there | 0 / 0.3 / 0.75 |
| per charge, ward, link hit (b0a0's) | once per event | KAZAGURUMA-GAESHI, TODOME, the bridge, the leap, the RAIDEN ender |
| the Bankai's ranged mode / the bind (b0a0's, his last stand at 4500 taken) | once per entry / per change event | SOKUBAKU 64 % / SANGE 16 % / KUBIGARI 20 %; the release on the grey margin |

### MIKIRI 見切り, the Hoho read

He keeps two counts this match (HS-MIKIRI-NOTE, on his own CPU only):
- the K1s he threw while the opponent could Hoho;
- how many of those were perfect-Hoho'd (the opponent's perfect count rose: the slow motion, the callout).

"Could Hoho" (HS-HOHO-READY-P) means, as he sees it:
- the opponent is perceived free (idle, running, guarding, stepping);
- his flash-step on the HUD is at least a Hoho's 30;
- no Hoho of his has been seen for 36 frames (the lockout).

The read (HS-MIKIRI-RATE) is (Hoho'd + 1) / (thrown + 4): a prior of 0.25 weighing 4 K1s. Over **0.42**, while the opponent
can Hoho, the K1 is unsafe (HS-MIKIRI-UNSAFE-P):
- 3 perfect of 4 K1s gives 0.5: the read is on. That is Ichigo's 55 %, by about a third into the match.
- 2 of 4 gives 0.375 and 1 of 4 gives 0.25: the read stays off. That is Rukia's 30 % mostly, Yamamoto's 8 % always.

Once the opponent can't Hoho (his flash-step spent, his Hoho just seen), K1 is free again within the same match.

### TSUME 詰, the chain brought in by hand (the read on)

- **No K1 into him while he can Hoho.** The reap's K1 is held back (0.75 at HARD, one roll at its trigger), and so is the
  hop out to the reap's range.
- **The close-in (HS-AI-CLOSE, 0.75 at HARD).** It rolls once per stay of the opponent (idle or running) in the step-in band
  (1.85-4.0 m) or the far band (4.0-7.5 m), and again whenever a neutral decision falls due there. That last part is what
  replaces the neutral K1: the decision is taken and its clock reset, as Yamamoto's rush veto does.
  - From the step-in band he Steps in, and the generic Step → J lashes J1 at its f10: S 8, inside every Hoho's lead.
  - From the far band he dashes in to 3.2 m, where the step-in band rolls again.
- **Off the J1 hit, b0a0's chain**: the windmill bridge (J → L → the charged K1 → K2 → K3 → RAIDEN) or the K link (K2J →
  K3). 1128 of 1807 J1 hits went into the bridge and 552 into K2J.
- **Not against a J masher** (AI-MASH-P): there the reap is his answer.
- **How often (HARD, a match):** against Ichigo 12.6 step-ins, 9.6 dash-ins, 2.4 reaps held; Rukia 12.6 / 7.9 / 1.6;
  Kenpachi 3.4 / 2.7 / 0.8; Senjumaru 0.6; Yamamoto 0.1; Lille 0.

### What a human notices

- He opens as b0a0's chain kusarigama: RENSA's windmill bridge into the reaping K string, or KARIBA's chain sweep at 3-6 m.
- Hoho his sideways sweep three times in four and he stops throwing it at you. He walks the chain in by hand instead:
  Step, the short sickle, the windmill, then the long chain reaps you three times and the lightning ends it.
- Spend your flash-step, or Hoho anything at all, and the sweep comes back within that same second.
- Against a fighter who doesn't Hoho he never changes.

**What sets it apart from the earlier cells:**
- It is the first CPU that reads the opponent's Hoho as a rate, conditioned on whether a Hoho was possible.
- It is the first that answers that read with another approach, not a skipped one.
- The Bankai stays b0a0's last stand: 4500 taken.

## Mechanisms implemented (CPU parts only)

- **New functions:**
  - pure, host-tested: HS-MIKIRI-RATE, HS-HOHO-READY-P;
  - the read: HS-OPP-HOHO-READY-P, HS-MIKIRI-UNSAFE-P, HS-MIKIRI-NOTE (its own CPU only: HS-TICK-BRAIN);
  - the close-in: HS-AI-CLOSE.
- **Changed:**
  - HS-AI-REFLEX: it resolves the read, then calls HS-AI-CLOSE before the fence.
  - HS-AI-FENCE: the reap and the hop are held back under the read.
  - HS-AI-MOVE: it notes his K1.
- **New knobs:** `*HS-AI-MIKIRI-P*` (0 / 0.2 / 0.75), `*HS-AI-MIKIRI-PRIOR*` (1 3), `*HS-AI-MIKIRI-RATE*` 0.42,
  `*HS-AI-HOHO-QUIET*` 36, `*HS-AI-CLOSE-P*` (0 / 0.3 / 0.75). The `*HS-AI-STYLES*` docstring now names the read.
- **New HSS CPU slots:** `ai-hr-n`, `ai-hr-k`, `ai-hr-key`, `ai-hr-p0`, `ai-hr-ready`, `ai-hseen`, `ai-cz`, `ai-cz-rolled`.
  None is hashed.
- **Pacing counters:** `ai-hoho-read`, `ai-mikiri`, `ai-close`, `ai-rush`.
- **What it reads:** the perceived snap (the state, a Hoho seen), the opponent's flash-step and perfect count (both on the
  HUD; the generic AI and the learner already read the opponent's gauges), and his own fighter. Nothing keyed to a
  character, a seed or the evaluator.
- **Not touched:**
  - HS-AI-OPP and its knobs;
  - every move, rule and hook for a human, and the art;
  - HS-HASH and the sim ticks;
  - every other file except the test section;
  - the awakening: still the kit gate `:awaken (:min-taken 4500)` through AI-AWAKEN-P.
- **Kept working:**
  - The learner's clock: HS-AI-CLOSE acts on a stay's entry or a decision due, and returns NIL otherwise.
  - The ASSIST: HS-MIKIRI-NOTE is gated on HS-TICK-BRAIN, so a human's borrowed brain never writes the read. The close-in
    is :reflex only, which the ASSIST doesn't call.
  - The debug modes 83000-83999 and the `duel hisagi` line.
- Every new chance is an (:easy :normal :hard) plist with EASY ≤ NORMAL ≤ HARD (host-pinned). Each is rolled once per
  event: a reap's trigger, a stay, a neutral decision due. The read itself moves only on resolved K1s.

## Tried and dropped (HARD, both seats; 20 seeds = 240 matches unless noted; "K R I" = 120 matches against those three)

| variant | wins | signature | verdict |
|---|---|---|---|
| b0a0's play (the read off) | 110 / 240 | 0.902 | the reference |
| a fixed close-in style for every match (TSUME as a per-match style), 10 seeds | 54 vs 57 of 120 | 0.853 vs 0.903 | it beats Ichigo (4 → 10 of 20) and loses the others, where the reap pays |
| b3a0's reap proof (HARD 3 steps) alone | 101 | 0.889 | dropped |
| the proof with the read | 112 | 0.876 | dropped |
| the read at 0.35 (prior 1 4), 0.9 / 0.9 | 117-118 | 0.884-0.886 | Rukia's 30 % switches it on: plain J |
| the read at 0.28 | 112 | 0.880 | dropped |
| the read at 0.38 (prior 1 3) | 117 | 0.885 | dropped |
| the read at 0.42, 0.9 / 0.9 | 116 | 0.887 | |
| **the read at 0.42, 0.75 / 0.75 (this file)** | **124** | **0.889** | kept |
| ... close-in 0.9 | 118 | 0.888 | dropped |
| ... 0.6 / 0.6 | 48 vs 54 (K R I) | 0.872 | dropped |
| ... no close-in (the reap only held back: MACHI-GAMA's shape) | 46 vs 54 (K R I): Ichigo 6 vs 14 of 40 | 0.877 | the close-in is the mechanism |
| ... the step-in band from 2.6 m (the dash-in's J1 hits more) | 56 vs 54 (K R I) | 0.870 | within noise; not kept |
| ... the reap window (3.4 4.9) | 120 | 0.889 | no gain |
| ... the SP ender 1.0 at HARD | 119 | 0.891 | no gain |
| ... RENSA 0.8 / KARIBA 0.2 per match (b3a0's HARD weights) | 123 | 0.889 | ≈; b0a0's 55 / 45 kept |

Yamamoto, Senjumaru and Lille play the same matches in every one of these variants: the read never switches on against
them. So the rows differ only where the read acts, and the comparison is a paired one.

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, NORMAL, 60 seeds a stream; pairs 28 29 30 31 32 34)

The awakening isn't changed, but NORMAL's Shikai is (the read at 0.2 / 0.3). So the A/B was run anyway. The never-awaken
side's wins of 60, this file / b0a0's (from its proposal):

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100 | 39 / 36 | 21 / 21 | 35 / 35 | 26 / 25 | 52 / 51 | 32 / 31 |
| 300 | 30 / 29 | 23 / 23 | 40 / 42 | 28 / 29 | 48 / 48 | 22 / 22 |
| 500 | 30 / 31 | 22 / 22 | 36 / 35 | 34 / 33 | 49 / 48 | 25 / 24 |

- Every row is at least 21 of 60: it passes (the bar is 20). Every match is a K.O.; the medians are 103.4-153.6 s.
- The HK rows (21-23) are b0a0's to the match and stay the closest to the bar.

## Expected benefit and risks

**Benefit:**
- 0.783 → 0.7945, the round's best measured so far (b2a0 0.7855, b3a0 0.785).
- HARD strength 0.435 → 0.498, mostly Ichigo: 2 → 14 of 40 paired, and the perfect Hohos against him halved.
- The masher stays 224 of 224. NORMAL stays mid-band (0.527).

**Risks:**
- **The signature is 0.890** (b0a0's 0.905): the close-in's J1 openers are plain J, 0.069 of his damage. They are the price
  of the read's gain against Ichigo, Rukia and Kenpachi. Measured in the score: strength +0.063 (x 0.3 = +0.019) against
  signature −0.015 (x 0.5 = −0.0075), net +0.0115.
- **Lille stays 0 at HARD and Kenpachi near 8 of 40.** The read helps Kenpachi only a little. His J1 (S 7) stuffs the
  step-in J1 27 % of the time, and his 37 % Hoho rate sits under the bar.
- **The read is sticky by design.** Once it is on, he throws no K1 into a Hoho-ready opponent, so the rate stops moving
  until a K1 lands in a lockout. A wrong read (Rukia's 30 % rolling 3 of 4) costs signature, not wins: Rukia 32 of 40
  either way.
- **The ranged and bind themes stay about 1 %** (b0a0's last stand). This cell didn't move the gate, so the A/B is b0a0's.
- **Pacing:** the longest median is 157.8 s (cap 220): no risk.

## Shared-code recommendations (not built)

- **The perfect Hoho decides the HARD matchups of any slow opener.** Every CPU Hohos at its first perceived step with ≥ 6 f
  of startup to go, and every such Hoho is perfect while the hit is within 12 f. So any move with S ≥ delay + 6 thrown into
  a free CPU is a coin flip at the kit's `:hoho`. A rules look (the perfect window against the perceived lead) or a
  generic read like this one in ai.lisp would help every kit with a slow opener, not only Hisagi's K1.
- **The neutral band pick (AI-ATTACK) still has no kit veto** (b3a0's note). The close-in takes a due decision over to
  replace the neutral K1. A `:attack-ok` hook would let a read veto one command of the band without taking the whole
  decision.
- (Standing.) The kit's `:hoho` is one number for every difficulty; the forced O ender on a red victim leaves a kit no say
  (0.021 of his damage is that Kikon); AI-AWAKEN-P is one gate for every difficulty.

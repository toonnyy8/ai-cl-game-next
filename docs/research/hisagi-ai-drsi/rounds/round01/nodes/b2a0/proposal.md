# b2a0: the bind (捆綁) — 首掛 the noose for the blade, SHIME / TSURUSHI in the bind

Cell b2a0, round 1, a new direction from BASELINE_DIR (primary style: the bind). PARENT_DIR none. Everything is in
`duel/lisp/hisagi.lisp`'s CPU parts and the host test's `HISAGI-CPU-TESTS` section (9884 checks ALL PASS; pkgcheck clean).

## History read (and what it taught)

| cell | mechanism | rescored | lesson |
|---|---|---|---|
| baseline | awakens at once; SAHARAI spam; dead windmill K string | 0.0 (NORMAL 0.042) | the ranged mode is a death zone |
| b0a0 | Shikai-first (RENSA / KARIBA), the located bridge / hold bugs fixed, neutral guard 0.1, awakening gated at `:min-taken 4500` | **0.637** (str 0.346, mash 0.67, sig 0.799) | the Shikai is his strength; the Bankai almost never shows (ranged / bind 0.004 each) |
| b1a0 | the fence for the ranged mode (back hop, punish by annulus, Hoho 0.9), three ranged styles, the bind's release at any distance | **0.567** (str 0.056, mash **0.862**, sig 0.756) | the fenced Bankai crushes the button masher but loses to every HARD CPU |

Both results stand when I re-measure them on the same harness (`b0a0` 129 / 360 HARD wins on my 30-seed diagnostic,
b1a0's Bankai vs the masher 99 / 112). The two cells are each strong where the other is weak. Neither tells the Bankai
*when* to come.

## The diagnosis (combat logs, the `duel hisagi` counters, a per-form damage-rate script in the cell's scratch)

These are HARD rates per second, dealt / taken:

| build | Shikai | ranged mode | bind | HARD wins |
|---|---|---|---|---|
| b0a0, awakening at once | 28.7 / 23.6 | 5.9 / 33.9 | 17.6 / 28.9 | 1 / 96 |
| + the bind plan below | 27.2 / 23.6 | 5.3 / 34.5 | 20.4 / 30.1 | 1 / 96 |
| b1a0 vs the **masher** | 28.4 / 16.6 | 19.0 / 13.0 | 29.3 / 19.6 | 99 / 112 |

1. **Against the six CPUs, no bind can pay for the ranged mode around it.** After a drained bind both Reiatsu bars are
   empty, and he needs ~30 s in the ranged mode (−29 a second) for the next 200. Any awakening gate tried that was
   blind to the opponent lost HARD wins: never 70 / 240, 4500 taken 65 / 240, 3000 taken 40 / 240, at once 1 / 96.
2. **Against the masher, the Bankai is his best form.** With b1a0's fence the masher loses both the ranged mode and the
   bind. KUBIKAKE hits it every time (2.43 of 2.47 thrown).
3. **What separates them is already in AI-AWAKEN-P.** I recorded his damage taken by kind at 1500 taken. The masher's is
   100 % blade (J only) against every one of the seven characters. HARD Kenpachi's is 100 % too, and he wins 1 / 60
   against Kenpachi in the Shikai anyway. Ichigo's is 92 %, Rukia's 88 %, Yamamoto's 83 %, Senjumaru's 74 %, Lille's
   30 %. So the kit gate `:awaken (:min-taken 2000 :melee-share 0.999)` awakens him against a pure blade fighter and
   keeps the Shikai against everyone else. The awaken A/B's debug modes still win (they come first in AI-AWAKEN-P).
4. **The shipped bind CPU threw away its option.** The binder can release (the snapshot back, nothing happened) or
   drain (the grey turns real). The shipped CPU released only 300 behind and within KAIBAKU-GEKI's reach. It almost
   never drained on purpose. It lost 572 grey vs 359 per match with the awakening at once.
5. **Reiatsu for the noose costs the chain.** Keeping 200 for KUBIKAKE all match took RAIDEN from 12 % of his Shikai
   damage to 8 % and HARD wins from 0.37 to 0.28 (240 matches). So the keep only applies once the gate is about to open.

## The styles (行動方針) and the mix

**首掛 KUBIKAKE, the noose for the blade** is the plan that sits over everything. He fights in the Shikai until his
opponent has proved to be a pure blade (2000 damage taken, ≥ 99.9 % of it from blades). Then he awakens and hunts the
bind. While that gate is within 600 taken of opening, he keeps 200 Reiatsu (no SP ender below 300). In the ranged mode,
KUBIKAKE goes first wherever its 2.3–7.0 m line reaches:
- as the punish by annulus (one roll per opponent action: 0.3 / 0.6 / 0.9);
- off every confirmed J / K hit (0.4 / 0.7 / 0.95);
- timed into a runner (0.2 / 0.45 / 0.7);
- from neutral, once per entry into 3.0–6.5 m with the opponent not attacking (0.15 / 0.3 / 0.5).

Otherwise b1a0's fence keeps him alive until it lands: the back hop, Hoho 0.9, guard 0.85, the SAHARAI hit cancelled
into K1.

**The bind styles, rolled once per bind (SIM-RND01, keyed by the bind's start tick), 50 / 50.** Both play the binder's
option:

| style | lock in (drain the pool) | release (KAIBAKU-GEKI, at any distance, once he isn't attacked) |
|---|---|---|
| **SHIME 絞 the strangler** | ahead by > 100 grey: spends the pool on KUSARI-AME (a bar of the pool whatever it hits), and the link-3 SP ender always | behind by > 150, by > 0 once the pool is ≤ 200 |
| **TSURUSHI 吊 the hanging** | only a decisive lead: > 1000 grey (a grey soul), so the bind and its x1.2 close damage last | behind by > 600, by > 0 once the pool is ≤ 150 |

For both styles:
- the opponent's grey Reishi at 0 (his Soul Break is due at the drain) locks it in at once;
- his own Reishi at 0 releases it.

The plan is re-read once per change event (every 50 of the pool, either Konpaku) and acted on 0.3 / 0.6 / 0.95 of the
time. The bind's melee keeps the generic rushdown with no Breaker, Hoho 0.9 (b1a0's), b1a0's anti-Breaker, and KOJO from
any distance beyond 3.2 m (its yank reaches anywhere in the bind).

**The Shikai styles stay b0a0's**, rolled per match: RENSA 55 % (the bridge J → L → charged K string) and KARIBA 45 %
(K1 punishing at 3–6 m).

What a human notices:
- Against a ranged or mixed fighter he is b0a0's chain kusarigama all match.
- Fight him only with the blade (or mash J) and after ~2000 damage he releases the Bankai. He backs off with hops,
  throws the noose the moment you whiff or run in, and drags you into the bind.
- In the bind he either strangles a small lead out at once (rain after rain until the pool runs dry), or keeps you on
  the chain. If the bind turns against him, he throws it off with KAIBAKU-GEKI from wherever he stands, and your
  progress is erased.

How often each part shows (HARD, 360 matches of my diagnostic, measured on the 0.6892 file with the same gate):
- the Bankai in 8.4 s per match on average: 42.7 s against Kenpachi, 8 s against Rukia, none against the others;
- 0.30 binds a match (1.57 against Kenpachi);
- against the masher, 2–3 binds a match.

## Mechanisms implemented (CPU parts only)

- **New functions:**
  - HS-BIND-PLAN (pure, host-tested), HS-AI-BIND-STYLE, HS-AI-THREAT-P, HS-AI-KEEP;
  - from b1a0: HS-R-HITS-AT-P, HS-R-CMD-MOVE, HS-R-PICK (now with KUBIKAKE first), HS-TOWARD-P, HS-AI-ANTI-BREAKER.
- **Rewritten:**
  - HS-B-AI-REFLEX (the plan, its lock / release, KOJO, the anti-Breaker) and HS-B-AI-ENDER (always SP1 while locking);
  - HS-R-AI-REFLEX (b1a0's fence with the noose), HS-R-AI-MOVE (the SAHARAI cancel by pick, the noose's route-dmg);
  - HS-AI-ENDER: the keep, and :WAIT under it, so the generic SP cancel can't spend the 200.
- **Kits:**
  - the Shikai: `:awaken` *HS-AI-AWAKEN* = (:min-taken 2000 :melee-share 0.999); `:sp-cancel-bars` stays b0a0's 1;
  - the ranged mode: b1a0's `:ai` (bands, guard 0.85, neutral guard 0.2, Hoho 0.9, dash-back 0.8, string-k 1.0);
  - the bind: no Breaker, KOJO's band past 3.2 m, Hoho 0.3 → 0.9.
- **Knobs:**
  - new: *HS-AI-BIND-STYLES*, *HS-AI-BIND-PLAN*, *HS-AI-PLAN-P*, *HS-AI-PLAN-STEP*, *HS-AI-KEEP*, *HS-AI-KEEP-LEAD*,
    *HS-AI-NOOSE-P*, *HS-AI-NOOSE-BAND*, *HS-AI-NOOSE*;
  - from b1a0: *HS-AI-PUNISH-P*, *HS-AI-ANTI-P*, *HS-AI-DODGE-P*, *HS-AI-R-ANTI-BREAKER-P*, *HS-AI-RUN-GUESS*,
    *HS-AI-ESCAPE-P*, *HS-AI-SAHARAI-P*;
  - changed: *HS-AI-THROW-P* 0.2 / 0.45 / 0.7 → 0.4 / 0.7 / 0.95;
  - removed: b0a0's *HS-AI-R-PUNISH-P* and *HS-AI-SAHARAI-K-P*.
- Every chance is EASY ≤ NORMAL ≤ HARD (host-pinned), rolled once per event: an opponent action, a run, a band entry, a
  link hit, a change event in the bind, a bind (its style), a match (the Shikai style).
- **HSS CPU slots** (never hashed): ai-bstyle, ai-bstyle-from, ai-plan, ai-nband, ai-nrolled, ai-run, ai-run-go.
- **New `duel hisagi` counters:** bstyle-shime / -tsurushi, ai-lock, ai-noose, ai-kubi-punish, ai-escape, ai-dodge,
  ai-punish, ai-block-punish, ai-anti, ai-anti-breaker, ai-l-cancel.
- **Kept working:** the learner's clock, the ASSIST hooks (they read `ai-brain`), every debug mode, and HS-AI-OPP and its
  knobs (untouched).

## Why it is not a repeat

It reuses b0a0's Shikai and b1a0's fence on purpose: they are the two located-and-fixed pieces that measured best. The
new pieces are what neither cell had:
- **When**: the Bankai is chosen by the opponent's kind of damage, through the existing kit gate.
- **The bind as an option**: lock-in / release by a plan, with two named bind styles.
- **Reiatsu banked** only when the noose is near.
- **KUBIKAKE first** in every ranged answer.

## Measurement (tools/aieval.py --char 7 --seeds 40 -j 2, the freeze 7623542)

| part | baseline | b0a0 | b1a0 | **b2a0 (this file)** |
|---|---|---|---|---|
| **score** | 0.0 | 0.637 | 0.5669 | **0.6836** |
| strength (HARD, 480) | 0.000 | 0.346 | 0.056 | 0.346 |
| masher (224) | 0.107 | 0.670 | 0.862 | **0.897** |
| signature | 0.727 | 0.799 | 0.756 | 0.801 |
| sig_by chain / ranged / bind | 0.436 / 0.178 / 0.112 | 0.791 / 0.004 / 0.004 | 0.299 / 0.309 / 0.148 | 0.774 / 0.018 / 0.009 |
| non-sig: plain J / O-Kikon / counter | 0.128 / 0.035 / 0.045 | 0.102 / 0.068 / 0.022 | 0.084 / 0.022 / 0.063 | 0.101 / 0.066 / 0.022 |
| NORMAL share (factor) | 0.042 (0) | 0.540 (1) | 0.452 (1) | **0.535 (1)**: Y 39, K 24, R 53, I 39, S 63, Lille 39 of 80 |
| pacing medians, all K.O. | 117–173 s | 104–159 s | 126–193 s | 114.1–159.3 s (Lille 159.3 the longest) |

The JSON is in `score.json`.

The path, all measured on the frozen evaluator:

| variant | strength | masher | sig | NORMAL | score |
|---|---|---|---|---|---|
| gate (:min-taken 1000 :melee-share 0.99) | 0.283 | 0.946 | 0.799 | 0.513 | 0.6736 |
| gate (2000, 0.999), the Shikai's `:sp-cancel-bars` 3 | 0.356 | 0.911 | 0.800 | 0.517 | 0.6892 |
| **the final**: `:sp-cancel-bars` back to b0a0's 1, the keep blocks only the generic SP cancel | 0.346 | 0.897 | 0.801 | 0.535 | **0.6836** |

The earlier gate awakened him against Ichigo / Rukia before their first ranged hit (HARD wins 18 → 5, 42 → 27 of 60).

The 0.6892 file failed one awaken A/B row: HK, the never-awaken side 19 / 14 / 21 of 60.

- The cause was its `:sp-cancel-bars` 3. The never side spent no SHIBARI below three bars. Back at 1 the same streams
  give 25 / 27 / 25, b0a0's own.
- The keep is now off when the awakening is switched off. HS-AI-KEEP reads *AI-AWAKEN-MODE* :NEVER, as AI-AWAKEN-P
  does, so a never side hoards nothing.
- While the keep is on, HS-AI-ENDER returns :WAIT under 300 Reiatsu, so the generic SP cancel can't spend the 200.

The final file costs 0.006 against the 0.6892 one, inside the 40-seed noise. It is the one delivered.

The diagnostic runs below are HARD wins on 360 / 240 / 112-match runs of my own script:

| variant | HARD wins | masher |
|---|---|---|
| b0a0 file | 129 / 360 | |
| b0a0 + the bind plan + the keep only near the gate (4500 gate) | 134 / 360 | |
| (1500, 0.999) | 122 / 360 | 50 / 56 |
| `:awaken-above 0.6` added to (1000, 0.99) | 107 / 360 | 52 / 56 |
| keep 200 all match | 65–70 / 240 | |

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, 60 seeds a stream; pairs 28 29 30 31 32 34)

The never-awaken side's wins of 60 per stream for this file, next to the baseline's (from b0a0's proposal):

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100: b2a0 / baseline | 34 / 2 | 25 / 1 | 38 / 0 | 33 / 0 | 49 / 1 | 30 / 0 |
| 300: b2a0 / baseline | 31 / 2 | 27 / 0 | 38 / 0 | 29 / 1 | 45 / 4 | 23 / 1 |
| 500: b2a0 / baseline | 34 / 1 | 25 / 0 | 36 / 0 | 32 / 0 | 51 / 2 | 26 / 0 |

Every row is at least 20 of 60, so the A/B passes. Every match is a K.O. The rows match b0a0's within noise: the never
side is the same Shikai.

## Expected benefit and risks

- **The benefit:**
  - +0.05 over b0a0, mostly from the masher (0.67 → 0.90), with HARD strength and the signature held;
  - the bind and the ranged routes now show against blade fighters, and the masher meets the full Bankai.
- **The bind theme stays small** in the strength runs (0.009). Against the six CPUs the Bankai shows only vs Kenpachi
  (and rarely Rukia), because the frozen ranged mode loses −22 a second at HARD. The bind cannot pay for it.
- **NORMAL 0.535:** inside the band, 0.065 under its top.
- **Pacing:** the longest median is Lille's 159.3 s (cap 220): no risk.
- **The gate keys on the opponent's damage kind.** A new pure-blade character would meet the Bankai. That is in
  character (the noose for the one who closes in), but a stronger melee CPU could make it cost.
- Kenpachi stays ~0 at HARD in either form (1 / 60).

## Shared-code recommendations (not built)

- **ai.lisp:** the generic J1 answers (punish, follow-up, Step-J, the Breaker string, the pressure reset) ignore a
  move's `:min-reach`, as b0a0 / b1a0 reported. The ranged mode's dead zones still cost him there.
- **The ranged mode needs a rules look, not a CPU one.** At HARD it loses 22–35 a second against every CPU, whatever
  the CPU does (four cells now). Every bind ends there with empty bars. The bind's value is capped by it.

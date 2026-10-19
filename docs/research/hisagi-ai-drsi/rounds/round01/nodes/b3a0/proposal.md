# b3a0: 三味 SANMI, a probabilistic mix of the three themes behind the reaping fence (刈場の間合い)

Cell b3a0, round 1. Branch b3: a probabilistic mix of all three themes. PARENT_DIR none: a new direction from BASELINE_DIR,
built as a new combination of the two measured cells (b0a0's Shikai styles, b1a0's Bankai styles and fence), plus one
new mechanism of this cell, the reaping fence, and the located fixes below. Everything is in `duel/lisp/hisagi.lisp`'s
CPU parts and the host test's `HISAGI-CPU-TESTS` section.

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`, freeze 7623542)

| | baseline | b0a0 | b1a0 | **b3a0** |
|---|---|---|---|---|
| **score** | 0.0 (raw 0.3848) | 0.637 | 0.5669 | **0.7658** (raw 0.7658) |
| strength (HARD, 480) | 0.000 | 0.346 | 0.056 | **0.417** |
| masher (HARD, 224) | 0.107 | 0.670 | 0.862 | **0.996** (223 of 224) |
| signature | 0.727 | 0.799 | 0.756 | **0.883** |
| sig_by chain / ranged / bind | 0.436 / 0.178 / 0.112 | 0.791 / 0.004 / 0.004 | 0.299 / 0.309 / 0.148 | 0.873 / 0.007 / 0.004 |
| sig_by plain J / Kikon / counter | 0.128 / 0.035 / 0.045 | 0.102 / 0.068 / 0.022 | 0.084 / 0.022 / 0.063 | 0.055 / 0.044 / 0.012 |
| NORMAL share (factor) | 0.042 (0) | 0.540 (1) | 0.452 (1) | **0.544 (1)**: Y 40, K 24, R 57, I 45, S 67, Lille 28 of 80 |
| pacing (NORMAL medians, all K.O.) | 117-173 s | 104-159 s | 126-193 s | 103.4-159.8 s (Lille 159.8, the longest) |

HARD wins by opponent (40 seeds, both seats): Yamamoto 48/80, Kenpachi 14/80, Rukia 60/80, Ichigo 4/80, Senjumaru 74/80,
Lille 0/80. By style: RENSA 98/234 (0.42), KARIBA 96/234 (0.41).

The JSON is `score.json`. The host tests pass: duel-rules 9891 checks, ALL PASS (+8 over the frozen 9883, the section
only; the splice of this section into the frozen file is byte-identical to the delivered `duel-rules-test.lisp`). The
other host tests pass too: control 89, learn 131, input 33, touch 64 (0 failures), cine 18. pkgcheck is clean. A first
version named a local variable `app`, which shadows an ENGINE name; it is renamed `coming`.

## History read, and what this cell takes from it

- **baseline** (score 0): it awoke at once, and its Bankai's ranged mode was a death zone. SAHARAI was spammed and the
  windmill's K string was dead. 0 of 480 HARD wins.
- **b0a0** (0.637): the Shikai chain. RENSA / KARIBA are rolled per match. It fixed the dead windmill string, let L go,
  added the bridge K at f9, dropped neutral SAHARAI, timed the anti-Breaker J1 in the aura, and set the passive neutral
  guard and a late awakening (`:min-taken 4500`). The measured idea is sound. Its leftover losses, located in this cell's
  combat logs, are listed in the next section.
- **b1a0** (0.567): the ranged routes. It added the fence (back hop, punish by annulus, Hoho 0.9, guard 0.85), three
  ranged styles, and the bind's release at any distance. The idea is sound for the ranged mode, and it beat the masher
  (0.86). It awoke at once, though, so its HARD strength was 0.056. The ranged mode is weaker than the Shikai against
  HARD CPUs, so it was let down by where the awakening was placed, not by the fence.
- This cell keeps b0a0's Shikai and b1a0's Bankai, and adds the reaping fence. It is a new mechanism, not a retune: its
  K1 is timed to the opponent's perceived closing speed, and it hops out of K1's dead zone. Neither earlier cell has it:
  b1a0's anti-approach existed only in the ranged mode, guessed a fixed 8 m/s run, and rarely fired.

## The diagnosis (combat logs, `tools/simgate/run-log.lisp` as aieval runs it; scripts in the cell's scratch)

1. **The masher beat b0a0 by standing next to him.** A trace of his brain against the Kenpachi masher showed the loop:
   - After the masher's J3 push (1.8 m) he is free at 2.3 m, inside K1's 3.0 m dead zone.
   - He holds the masher wake-guard for 20 f, then stands idle at 1.9-2.3 m. The intent's range is far away and no
     decision comes for 20 f.
   - The masher walks in and lands J1 / J2 / J3 again.

   He out-damaged the Kenpachi and Rukia mashers (39k vs 32k, 36k vs 27k over 10 matches) but won only 3 of 10 each.
2. **Neutral K1 and the neutral windmill were punished.**
   - The perfect-Hoho COUNTER after K1 cost him 8.1k of 29.8k taken against Ichigo.
   - Lille's far-dash L under the K1: K1 whiffed or was beaten 40 of 102 times.
   - The neutral windmill (charging in place) whiffed or was beaten 67 times in 10 matches against Lille. It was also
     punished by Senjumaru's freeze, Rukia and Kenpachi.
3. **The Bankai is still a strength sink, even with b1a0's fence.** Per-form rates at `:min-taken 3000`, HARD, 10
   matches each, dealt / taken per second:

   | form | vs Rukia | vs Yamamoto | vs Senjumaru |
   |---|---|---|---|
   | Shikai | 36.9 / 18.1 | 30.0 / 18.1 | 38.3 / 13.5 |
   | ranged mode | 10.7 / 22.6 | 7.9 / 16.9 | 15.1 / 13.9 |
   | bind | 19.1 / 23.6 | 26.3 / 6.8 | 24.8 / 26.6 |

4. **An idle fence band re-rolled every jittering step.** The first fence (one roll per entry below 2.9 m) re-rolled each
   time the perceived distance crossed 2.9 m: 161 hops a match at NORMAL, and NORMAL fell to 0.19. This is DREAM_RSI §5.5's
   per-step roll in disguise. Fixed with hysteresis: in below 2.9 m, out only past 3.5 m.

## The styles: 三味 SANMI, three themes mixed by probability

| layer | roll | styles and their weights |
|---|---|---|
| the Shikai, the chain (始解鎖鐮連段) | once per match (`HS-AI-STYLE`, SIM-RND01) | **RENSA 連鎖 55 %** / **KARIBA 刈場 45 %** |
| the Bankai's ranged mode (卍解遠距路線), his last stand | once per entry into the ranged mode (`HS-R-STYLE`: the awakening and every bind's end) | **SOKUBAKU 束縛 64 %** / **SANGE 散華 16 %** / **KUBIGARI 首狩 20 %** (KUBIGARI 0.2, then SANGE 0.2 of the rest) |
| the bind (捆綁) | per change event (every 50 of the pool drained, any Konpaku change) | the release when 150 behind on grey (0.3 / 0.6 / 0.9), KAIBAKU-GEKI at any distance; KOJO's pull per entry into 2.5-4 m (0.1 / 0.2 / 0.3) |
| per event | once per hit / approach / stay | the bridge, K link vs J link, the leap, the SP / O ender, the route's K vs J link, KUBIKAKE off a hit |

**The reaping fence (刈場の間合い, HS-AI-FENCE; new in this cell, both Shikai styles).** The chain fights at its own
distance.

- **The reap.** He reads the opponent's perceived closing speed from step to step. An approach is the opponent walking
  or running in faster than 1.5 m/s within 7.5 m. It rolls once:
  - RENSA 0.15 / 0.25 / 0.7, KARIBA 0.2 / 0.35 / 0.9 (EASY / NORMAL / HARD).
  - On a yes, K1 NAGI is pressed when the opponent will stand 3.4-5.6 m away at K1's hit frame (his perception delay +
    S 18 + 1 ahead).
  - The sweep meets the opponent's walk. K2 / K3 follow by chain, then RAIDEN.
- **The hop.** Each stay inside K1's dead zone (below 2.9 m, until past 3.5 m) with the opponent not attacking rolls
  once:
  - RENSA 0 / 0 / 0.7, KARIBA 0 / 0.05 / 0.9.
  - On a yes, he back-hops and runs out to 4.3 m, where the reap waits.
  - The hop stays rare below HARD. At NORMAL it cost the fair game: 0.15 measured NORMAL 0.22 (the band re-rolling
    before the hysteresis), and 0 / 0.05 measures 0.54.
- **In the ranged mode** (b1a0's anti-approach), the strike is timed by the same perceived closing speed instead of a
  guessed 8 m/s run, so a walker is caught too. Its chance stays b1a0's: 0.2 / 0.45 / 0.7.

**RENSA 連鎖 (the chain link), 55 %:**
- Up close: J1 → the windmill bridge (L) at 0.3 / 0.5 / 0.85. The K at f9 → the charged K string K1 → K2 → K3 → RAIDEN.
- Else the K link K2J (0.5 / 0.7 / 0.8).
- The leap J2K / J3K off K1 / K2 while it wants him close (0.3 / 0.5 / 0.7).
- The reap at 0.7 HARD. It hops less (0.7 HARD) and stays near J range more.

**KARIBA 刈場 (the reaping ground), 45 %:**
- Holds 3-6 m. Hops out of the dead zone (0.9 HARD) and reaps every approach (0.9 HARD).
- K1-punishes every whiff seen at 3.2-6.2 m (0.15 / 0.25 / 0.85).
- Off a J hit the K link first (0.6 / 0.8 / 0.9), the bridge less (0.15 / 0.25 / 0.45).

**The Bankai (b1a0's styles behind b1a0's fence).** It comes as his last stand, when he has taken 4500 (b0a0's gate,
kept; measured below).
- **SOKUBAKU** opens the gathered route with the 360° K1 bundle and takes the K links 80-90 % of the time (guard x1.3).
  Its hop goes to 3.2 m.
- **SANGE** opens the spread route with J1 from 4-6 m and takes the J links to J3's 6.6 m push (Reiatsu x1.3, x1.69 at the
  tip). Its hop goes to 3.8 m.
- **KUBIGARI** throws KUBIKAKE from neutral once per stay at 3.5-6.5 m with his 200 (0.2 / 0.4 / 0.6), and hunts the bind.
- All three share b1a0's fence:
  - the back hop out of 2 m (0.3 / 0.7 / 0.85);
  - punishes by annulus (0.3 / 0.6 / 0.9), KUBIKAKE first when his 200 is there;
  - the dodge-hop (0.2 / 0.45 / 0.7);
  - Hoho or a hop against a Breaker (0.3 / 0.6 / 0.85), and b0a0's guard-wait (no Breaker into a turtle);
  - Hoho 0.9, guard 0.85;
  - a SAHARAI hit cancelled into the style's opener.

## The mechanisms implemented

New in this cell:
- `HS-AI-FENCE`, which `HS-AI-REFLEX` calls last.
- Pure helpers `HS-REAP-AT`, `HS-REAP-OK-P` and `HS-FENCE-BAND` (host-tested).
- Knobs: `*HS-AI-REAP-P*`, `*HS-AI-HOP-P*` (by style × difficulty), `*HS-AI-REAP-CLOSING*`, `*HS-AI-REAP-FROM*`,
  `*HS-AI-REAP-WINDOW*`, `*HS-AI-FENCE-IN*`, `*HS-AI-FENCE-OUT*`, `*HS-AI-HOP-KEEP*`.
- HSS CPU slots: `ai-pd`, `ai-pt`, `ai-app`, `ai-app-go`, `ai-fz`, `ai-fz-rolled`. None is hashed.
- Pacing counters: `ai-reap`, `ai-hop`.

Changed in this cell:
- **No neutral windmill in the Shikai's bands.** The bridge, the ward against ranged threats and the windmill string
  keep it in his play. HARD 0.388 → 0.412 with the O change below (20 seeds), and 0.37 → 0.39-0.44 alone.
- **No O ender against a non-red victim from either style.** The CPUs guard the rush's follow-up, and RAIDEN (the chain
  theme) ends the string instead. The masher's O ender stays (0.3 / 0.6 / 0.9). Effect: HARD 0.388 → 0.412, signature
  0.852 → 0.884 (20 seeds).
- **NORMAL's bridge 0.6 / 0.3 → 0.5 / 0.25, SP ender 0.4 → 0.35, K1 punish 0.2 / 0.3 → 0.2 / 0.25.** The fence and the
  two changes above made NORMAL 0.61 (factor 0.93); it is 0.544 after. HARD is untouched.
- **b0a0's `HS-AI-GUARD-REFLEX` is split.** The Shikai keeps the aura J1. `HS-AI-GUARD-WAIT` (no Breaker into a long
  guard) now runs in every form: the ranged mode and the bind as well.

Merged from b1a0 into the Bankai:
- `HS-R-AI-REFLEX`, `HS-R-STYLE`, `HS-R-PICK`, `HS-R-HITS-AT-P`, `HS-R-CMD-MOVE`, `HS-THREAT-P`, and
  `HS-R-AI-ANTI-BREAKER` (b1a0's `HS-AI-ANTI-BREAKER`, renamed).
- `HS-R-AI-MOVE`, including the SAHARAI hit cancel into the style's opener.
- `HS-B-AI-REFLEX`.
- Their knobs. `*HS-AI-R-STYLES*` and `*HS-AI-R-ANTI-BREAKER-P*` are renamed so they don't clash with b0a0's names.
  `*HS-AI-RUN-GUESS*` and `HS-TOWARD-P` are gone, replaced by the perceived closing speed.
- Both Bankai kits' `:ai` plists, and the HSS slots `ai-form`, `ai-rstyle`, `ai-run`, `ai-run-go`, `ai-rel`, `ai-mid`.
- b0a0's `HS-R-PUNISH-CMD`, `*HS-AI-R-PUNISH-P*` and `*HS-AI-SAHARAI-K-P*` are removed. b1a0's annulus punish replaces
  them.

Kept from b0a0: everything else of the Shikai. That is the styles, the bridge K at f9, L let go in the windmill's CPU
branch, the K1 punish, the aura J1, the late awakening gate, `:string-k` 0, the passive guard, and `:kikon-range` 0.

Not touched: HS-AI-OPP and its knobs, every move, every rule, the art, every other file, and HS-HASH.

The rest keeps working:
- The ASSIST: the hooks the ASSIST calls read the brain they are given (`ai-brain`), and the fence lives only in
  `:reflex`.
- The learner's read clock: the fence acts on events and returns NIL otherwise.
- The debug modes 83000-83999 and the `duel hisagi` counters.
- The awakening goes only through AI-AWAKEN-P (b0a0's kit gate).

Every new chance is an (:easy :normal :hard) plist with EASY ≤ NORMAL ≤ HARD (host-pinned). Each is rolled once per
event: per approach, per stay, per hit, per entry, per match.

## Tried and dropped (measured)

| variant | result | verdict |
|---|---|---|
| the hop alone (0.7) | HARD 0.258, masher 1.0 | hurts strength |
| the reap alone (0.7) | HARD 0.333, masher 1.0 | weaker than both together |
| hop + reap, 0.9 / 0.9 | HARD 0.383 (10 seeds) | the shipped values: 0.7 / 0.9 by style |
| a per-match K1 read (the reap's chance × K1s that hit / were blocked, prior 3) | HARD 0.412 → 0.379, signature 0.884 → 0.867 (20 seeds) | it turned the reap off against the weak CPUs too; dropped |
| no neutral K1 at all | ≈ neutral, signature −0.01 | dropped |
| an earlier awakening with the merged Bankai (and the ranged reap), 20 seeds | see below | 4500 kept |

The earlier awakening, 20 seeds:

| `:min-taken` | HARD | signature | ranged + bind share of damage |
|---|---|---|---|
| 4500 (shipped) | 0.404 | 0.885 | 0.008 |
| 3000 | 0.383 | 0.876 | 0.073 |
| 2000 | 0.271 | 0.862 | 0.206 |

The 3000 trade is about −0.01 score, within the 20-seed noise. It is the lever if the coordinator or the user wants the
ranged and bind themes visible in more matches.

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, 60 seeds a stream; pairs 28 29 30 31 32 34)

The never-awaken side's wins of 60, b3a0 next to b0a0 and the baseline (both as b0a0 measured them):

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100: b3a0 / b0a0 / baseline | 29 / 34 / 2 | 25 / 25 / 1 | 37 / 38 / 0 | 27 / 33 / 0 | 47 / 49 / 1 | 28 / 30 / 0 |
| 300: b3a0 / b0a0 / baseline | 27 / 31 / 2 | 27 / 27 / 0 | 30 / 38 / 0 | 32 / 29 / 1 | 48 / 45 / 4 | 28 / 23 / 1 |
| 500: b3a0 / b0a0 / baseline | 32 / 34 / 1 | 27 / 25 / 0 | 40 / 36 / 0 | 38 / 32 / 0 | 48 / 51 / 2 | 28 / 26 / 0 |

Every b3a0 row is at least 25 of 60, so the A/B passes (the bar is 20). Every match is a K.O., with medians of
107-158 s. The first build with NORMAL's bridge 0.45 / 0.2 (NORMAL 0.49) had HK 18 and HB 19 at seed0 100, below the 20. The
shipped NORMAL values (0.5 / 0.25, NORMAL 0.544) were chosen with that row: HK 25 / 27 and HB 28 / 28 at seed0 100 / 300
in the cell's check.

## Expected benefit and risks

**Benefit:** the score rises from 0.637 (b0a0) to 0.766. By part:
- The masher is effectively solved (0.67 → 0.996). The reap sweeps a walking J masher at range, and the hop never lets
  him stand in the dead zone.
- The signature rises to 0.883: the K string at range replaces the J trade, and RAIDEN replaces the O ender.
- HARD rises to 0.417.

**Risks:**
- Strength rests on Yamamoto, Rukia and Senjumaru. Ichigo (4/80), Kenpachi (14/80) and Lille (0/80) still beat him:
  - Ichigo's and Kenpachi's perfect-Hoho counters punish any K1 (S 18) thrown into a free opponent, the reap's
    included. A K1 read was tried (above) and lost more than it won.
  - Lille's far-dash L goes under K1.
- The ranged and bind themes are about 1 % of his damage at the shipped awakening gate. The mix is real but the last
  stand is rare: the Bankai ends 7 % of HARD matches. `:min-taken 3000` raises them to about 7 % for about −0.01.
- NORMAL 0.544, 0.056 under the band's top. HARD values don't move it. NORMAL's bridge, SP ender and K1 punish do (the
  0.45 / 0.2 version measured 0.49 at 20 seeds).
- The pacing is far from its cap: the longest median is 159.8 s.
- At HARD he hops about 17 times a match, a visible spacing habit, in character (the chain's 3-6 m).

## Shared-code recommendations (not done: outside this cell's scope)

- **`AI-AWAKEN-P` is a fixed kit gate.** A style can't pick its awakening; a mirror of Hisagis shares one kit plist. A
  kit hook (`:awaken-ok`, a function of the fighter and its brain, still respecting the debug :always / :never modes)
  would let a style mix decide per match when the Bankai comes. That is the user's 「使用機率將這些風格戰法互相結合」
  across forms.
- **The neutral band pick (AI-ATTACK) has no kit veto.** A kit can't stop a slow opener (Hisagi's K1, S 18) against an
  opponent it has seen Hoho it. A `:attack-ok` hook (kit, cmd, brain) would let a per-match read act on the neutral pick,
  not only on the kit's own reflex presses.
- **b0a0's note stands.** ai.lisp's generic J1 answers ignore `:min-reach`, and every kit without `:neutral-guard` may
  lose NORMAL matches to the doubled `:guard`.

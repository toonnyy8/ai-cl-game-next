# b1a0 (round 1, §25.15 freeze): 鎖道 KUSARI-MICHI, the ranged routes on the chain tip

Cell b1a0, round 1, a new direction from BASELINE_DIR (primary style: the Bankai ranged routes, 遠距路線). Everything is in
`duel/lisp/hisagi.lisp`'s CPU parts (the three kits' `:ai` plists, the HS-*-AI-* functions and `*HS-AI-...*` knobs, CPU-only
HSS slots, HS-KAZA-TICK's brain branch) and the host test's `HISAGI-CPU-TESTS` section.

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`, freeze 3686d94)

| | baseline | **b1a0** |
|---|---|---|
| **score** | **0.0** (raw 0.4149) | **0.7517** (raw 0.7517) |
| strength (HARD, 480) | 0.006 | **0.400** |
| masher (HARD, 224) | 0.188 | **1.000** |
| signature | 0.751 | **0.863** |
| sig_by chain / ranged / bind | 0.373 / 0.204 / 0.174 | 0.605 / **0.175** / 0.083 |
| sig_by plain J / Kikons / counter / Breaker | 0.111 / 0.063 / 0.037 / 0.038 | 0.050 / 0.060 / 0.020 / 0.005 |
| NORMAL share (factor) | 0.104 (0) | **0.5625 (1.0)**: Y 46, K 25, R 47, I 45, S 67, Lille 40 of 80 |
| pacing (NORMAL medians, all K.O.) | 115-175 s | 114.6-166.6 s (Lille 166.6 the longest) |

HARD wins by opponent (20 seeds, both seats, this file's sibling with the old ranges, 0.392-0.400): Yamamoto 18-21 / 40,
Kenpachi 9-12, Rukia 23-26, Ichigo 4-7, Senjumaru 34-36, Lille 0.

Host tests: duel-rules 9866 checks ALL PASS (the section only; splicing it into the frozen file gives this file byte for
byte); control 89, learn 131, input 33, touch 64 (0 failures), cine 18.

## History read

The current round's history held nothing yet (b0a0 runs alongside). PRIOR_DIR (§25.12 rules), rescored there:

| cell | mechanism | score | lesson |
|---|---|---|---|
| baseline | awakens at once, SAHARAI spam, dead windmill string | 0.0 | the ranged mode a death zone |
| b0a0 | the Shikai chain RENSA / KARIBA, the bridge K at f9, passive guard fixed, awakening at 4500 taken | 0.637 | the Shikai is his strength |
| b1a0 (§25.12) | the ranged fence (back hop, punish by annulus, Hoho 0.9), SANGE / SOKUBAKU / KUBIGARI, awakening at once | 0.567, HARD 0.056 | the fence beats the masher, not the HARD CPUs |
| b2a0 | b0a0 + b1a0, awaken against pure blades (melee share), the bind plan | 0.684 | the Bankai only where it pays |
| b3a0 | b0a0 + b1a0 + the reaping fence (K1 timed to the approach, the hop), awakening at 4500 | 0.766 | the best; ranged / bind 1 % of his damage |

Ported onto §25.13's rules (a three-way merge of b3a0's CPU diff onto the freeze's sim, never its file), b3a0 still
measures 0.770 at 10 seeds (HARD 0.442, NORMAL 0.483) with the ranged theme at 0.6 %.

## The diagnosis on §25.13's rules (combat logs as aieval runs them; scripts in the cell's scratch)

1. **Per-form rates, dealt / taken a second** (the b3a0 port, awakening forced at once, P1, 36 matches each):

   | | Shikai | ranged mode | bind |
   |---|---|---|---|
   | HARD | 31.4 / 20.4 | **18.9 / 57.7** | **46.5 / 26.2** |
   | NORMAL | 27.2 / 14.4 | 20.4 / 28.6 | **46.6 / 17.3** |

   §25.13 made the bind a winning form at both levels; the ranged mode still loses badly at HARD.
2. **The awakening gate decides the trade** (10 seeds, full aieval; the gate is AI-AWAKEN-P's kit `:awaken`):

   | `:min-taken` | HARD | NORMAL | ranged | bind | raw |
   |---|---|---|---|---|---|
   | 4500 (b3a0) | 0.442 | 0.483 | 0.006 | 0.003 | 0.770 |
   | 2500 | 0.425 | 0.700 | 0.090 | 0.076 | 0.759 |
   | 2000 (+ this cell's styles) | 0.433 | 0.800 | 0.163 | 0.084 | 0.761 |
   | 1500 | 0.375 | 0.808 | 0.178 | 0.134 | 0.739 |
   | 0 (at once) | 0.300 | 0.767 | 0.276 | 0.198 | 0.712 |

   HARD per opponent, both seats, never vs always awakened: Yamamoto 15 → 4 / 20, Rukia 14 → 9, Senjumaru 19 → 16,
   Kenpachi 4 → 5, Ichigo 1 → 2, Lille 0 → 0. NORMAL's bind is what lifts NORMAL out of the band.
3. **The HARD ranged mode's losses are the opponents', not his choices.** What opens him there (per match): Lille's far
   dash 493, the PUNISH of his recovery 369 (Yamamoto's dash J1 467 of it against him), NEUTRAL 294, their Step J 171. His
   own actions: J1 off his back hop (the generic Step → J, 90 % at HARD) 6.4 a match, 23 % hit, 18 % perfect-Hoho'd; neutral
   K1 25 % / 19 %; KUBIKAKE timed into an approach 17 % hit (HS-AI-OPP side-steps it); the J1 reset after a blocked string
   6 %; every punish 70-91 %. I removed the hops and the neutral openers (5 / 36 HARD vs 15 / 36), added a whiff-snipe into
   his committed moves (24 % hit), cut the steps from the bands, the KUBIKAKE anti and the J1 reset (6 / 20 vs 8 / 20 against
   Yamamoto + Rukia): **the ranged mode's rates stayed 19 / 50-58 in every variant**. The Hoho counter (60, then his combo)
   answers any slow opener into a free CPU, and the dash punish answers its recovery. A CPU can't fix that (see below).

So this cell does not try to win the HARD ranged neutral. It makes the ranged routes the Bankai's conversion: the openers
only where they land, every route played on the chain tip (§25.13: the whole route x1.71), the noose at the route's end,
and the awakening early enough that the routes show in most matches.

## The styles (行動方針) and the mix

| layer | roll | styles |
|---|---|---|
| the Shikai (b3a0's, unchanged) | once per match | RENSA 連鎖 55 % / KARIBA 刈場 45 % behind the reaping fence |
| **the ranged mode (this cell)** | once per entry into it (the awakening, every bind's end; HS-R-STYLE, SIM-RND01) | **SENTAN 尖端 60 % / KAISEN 回旋 25 % / NAWAJI 縄路 15 %** |
| the bind (b1a0 / b3a0's) | per change event | the KAIBAKU-GEKI release 150 behind on grey; KOJO's pull per entry into 2.5-4 m |

**The awakening**: the Shikai's kit gate `:awaken (:min-taken 2000)` (4500 → 2000): the Bankai arrives once he has
taken 2000 in the match: in 222 of 240 HARD matches of a 20-seed run (the 18 without it were all wins).


**The ranged mode, every style**: his intents hold the chain tips' distance (`:ranges` approach 4.0-5.0, pressure 3.5-4.5,
zone 4.2-5.6, defend 5.0-6.5; 2.5-4.5 before): K1's tip is 4-5 m, J1's 5-6 m. b1a0's fence is kept (the back hop, the
punish by annulus, Hoho 0.9, guard 0.85). Removed or changed, from the logs:
- no KUBIKAKE timed into an approach (17 % hit, side-stepped, a 60 f whiff) and no neutral noose (KUBIGARI is gone);
- after his blocked string, :WAIT at any range (the generic J1 reset into a free guard: 6 % hit, then a dash punish);
- the anti-approach strike of a tip style picks the opener whose tip will hold him on arrival (HS-R-TIP-CMD at the
  perceived arrival distance), else the style's strike in its annulus;
- HS-R-PICK (the punishes) puts a tip style's tip opener first.

| style | what it does that the others don't |
|---|---|
| **SENTAN 尖端 the tip reaper**, 60 % | Hops out to 4.6 m (K1's tip). Punishes and anti-approach strikes with the opener whose tip holds him, then the gathered K route to the end (K link 0.7 / 0.8 / 0.9): K1 → K2 → K3G on the tip, 313. KUBIKAKE only off the ender (link 3). |
| **KAISEN 回旋 the Reiatsu wheel**, 25 % | J1's tip (hop to 5.0 m), the spread J route (K link only 0.1 / 0.15 / 0.2): J1 → J2 → J3, its 6.6 m push puts him back on the tip; the spread route's Reiatsu x1.3 (x1.69 on the tip) refills the noose. KUBIKAKE off the ender. |
| **NAWAJI 縄路 the noose road**, 15 % | No tip read; K1 first; KUBIKAKE's cancel off the first link that hits (0.95 at HARD), the bind before the route's damage. |

The weights came from a 20-seed HARD attribution (wins per match-weight of each style's entries): SENTAN 0.42, KAISEN 0.29,
NAWAJI 0.23 (the bind first trades away the route's x1.71 damage), so 0.45 / 0.35 / 0.20 → 0.60 / 0.25 / 0.15.

**KUBIKAKE**: off a confirmed J / K hit with his 200, *HS-AI-THROW-P* 0.2 / 0.45 / 0.7 → **0.05 / 0.1 / 0.95**: HARD
binds more (the bind is +20 a second there, the ranged mode −39); NORMAL's bind was what put NORMAL at 0.80.

**NORMAL's fair game** (NORMAL's and EASY's values only; HARD untouched; the Shikai's values stay b3a0's, so the awaken
A/B's never-awaken side is b3a0's Shikai): the ranged punish 0.6 → 0.35, the escape hop 0.7 → 0.35, the anti-approach
0.45 → 0.25, the dodge hop 0.45 → 0.2, the anti-Breaker 0.6 → 0.35, the bind's release 0.6 → 0.3, the bind's SP 0.35 →
0.15. The path (10 seeds, NORMAL share): 0.80 → 0.70 (KUBIKAKE 0.15) → 0.61 (punish, hop, anti) → 0.56 (dodge, anti-Breaker,
release) → 0.46 (KUBIKAKE 0.05) → 0.51 at 20 seeds (KUBIKAKE 0.1) → 0.5625 at 40 seeds with the tip ranges.

Every chance is an (:easy :normal :hard) plist, EASY ≤ NORMAL ≤ HARD (host-pinned), rolled once per event (an
opponent action, an approach, a link hit, an entry into the ranged mode, a match).

## What a human will notice

He opens in the Shikai (b3a0's chain kusarigama). Once he has taken 2000 (about a soul and a half), KARE,
KAZESHINI: the Bankai, and he backs off to 4-5.5 m and stays there. He doesn't swing the bundle at you while you stand
ready; he waits for you to commit, then lashes from the tip of the chain and drags the whole route out of it (the
gathered three-hit bundle, or the spread lashes that push you back out to the tip). At the end of the route the noose
goes round your neck and the bind starts. One time in seven a match's ranged stretch is the noose road instead: the
noose off the first lash.

## Mechanisms implemented (all in `duel/lisp/hisagi.lisp`'s CPU parts)

- **Ported** (a three-way merge of PRIOR b3a0's diff vs its freeze onto this freeze; its sim never copied; the one
  conflict, HS-B-AI-REFLEX, takes b3a0's release at any distance): b0a0's Shikai styles, bridge, guard and guard-wait,
  b3a0's reaping fence, b1a0's ranged fence and bind reflex, their knobs, HSS CPU slots and pacing counters.
- **New**: `*HS-AI-R-STYLE-W*`, `*HS-AI-R-STYLES*` (SENTAN / NAWAJI / KAISEN with `:tip`, `:kubi-at`, `:route-dmg`,
  `:keep`), HS-R-TIP-CMD; HS-R-STYLE's weighted pick; HS-R-PICK's tip opener; the tip-at-arrival anti-approach;
  HS-R-AI-MOVE's KUBIKAKE at link 1 only for `:kubi-at` 1; the :WAIT after a blocked string at any range; the ranged kit's
  `:ranges`; the gate 2000; the NORMAL values above; HARD KUBIKAKE 0.95.
- **Removed**: b1a0's `*HS-AI-KUBIGARI-P*`, `*HS-AI-SANGE-P*`, the neutral noose and the HSS slot `ai-mid`.
- **Pacing counters**: `sentan` / `nawaji` / `kaisen` (entries per style) join b3a0's.
- **Kept working**: AI-AWAKEN-P (the kit gate only; the debug :always / :never modes win), the learner's read clock
  (every reflex acts on events and returns NIL otherwise), the ASSIST hooks (they read `ai-brain`), the debug modes
  83000-83999, HS-HASH, HS-AI-OPP and its knobs (untouched).
- **Host tests** (the section only): the gate 2000, the route styles (names, weights, openers, the tip flag, `:kubi-at`,
  `:keep`), every changed chance's shipped value and ordering, HS-R-TIP-CMD against HS-DIST-MULT's tip, HS-R-PICK with the
  tip, the ranged `:ranges`; b3a0's checks kept (one: the route links' reach read updated to §25.13's 7.0 m chain).

## Why it is not a repeat

b1a0 (§25.12) awakened at once and picked an opener per style; its HARD strength was 0.056. This cell keeps the
strongest measured Shikai (b3a0's), and builds the ranged layer on what §25.13 changed: the routes inherit the opener's
tip, so the styles choose the distance (the tip), the route (gathered K / spread J) and where the noose enters it (the
first link or the ender); the awakening is moved by measurement (the gate sweep above) to where the ranged routes show
(17.5 % of his damage, 0.6 % in the b3a0 port) for −0.02 HARD.

## Expected benefit and risks

- **Benefit**: score 0 → 0.7517, with the three themes visible in the HARD strength runs (chain 0.605, ranged 0.175, bind
  0.083) where b3a0's port shows 0.873 / 0.006 / 0.004 for ~0.77.
- **The cost of the direction**: ~−0.02 against b3a0's port (HARD 0.442 → 0.400, signature 0.882 → 0.863: the Kikons and
  plain J of the Bankai). Every awakening gate earlier than 4500 costs HARD strength, mostly against Yamamoto and Rukia.
- **NORMAL 0.5625**: 0.0375 under the band's top. A refine that strengthens NORMAL's Bankai (KUBIKAKE, the punish) crosses
  0.60; NORMAL's KUBIKAKE 0.1 is the first knob (0.05 measured 0.46 at 10 seeds).
- **Pacing**: the longest median is Lille's 166.6 s (cap 220): no risk.
- Kenpachi (25 / 80 NORMAL, ~10 / 40 HARD), Ichigo (~5 / 40 HARD) and Lille (0 HARD) still beat him, as in every cell.

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, 60 seeds a stream; pairs 28 29 30 31 32 34)

The never-awaken side's wins of 60 per stream (this file / the baseline). Every match a K.O.; medians 107-160 s.

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100: b1a0 / baseline | 29 / 2 | 25 / 1 | 37 / 0 | 27 / 0 | 47 / 1 | 28 / 0 |
| 300: b1a0 / baseline | 27 / 2 | 27 / 0 | 30 / 0 | 32 / 1 | 48 / 4 | 28 / 1 |
| 500: b1a0 / baseline | 32 / 1 | 27 / 0 | 40 / 0 | 38 / 0 | 48 / 2 | 28 / 0 |

Every b1a0 row is at least 25 of 60: the A/B passes (the bar is 20). The never side is b3a0's Shikai unchanged (this
cell's NORMAL changes are the Bankai's only), and its rows match PRIOR b3a0's to the match on these streams: §25.13-§25.14
touched only the Bankai, so a Shikai-only match plays as it did. The baseline's rows are the ones b0a0 measured on the
§25.12 freeze for the same reason (its Shikai CPU and the Shikai's rules are unchanged since); not re-run here.

## Shared-code recommendations (not built)

- **The ranged mode at HARD needs a rules look.** Five cells now: whatever the CPU does there, it deals ~19 and takes
  50-58 a second against the HARD CPUs (a perfect Hoho counters every slow opener into a free opponent; the dash punish
  takes the recovery; the generic Step → J fires J1 off every back hop inside 6.1 m, 23 % hit at HARD).
- **ai.lisp's generic Step → J** reads only the kit's J1 reach (6.0 m for the ranged mode): a kit hook (or `:min-reach`) to
  skip it would let a hop be a pure escape.
- **AI-AWAKEN-P is one gate for every difficulty and opponent** (b2a0 / b3a0 said it too): the Bankai is a NORMAL winner
  and a HARD loser here; a kit hook (`:awaken-ok`, still under the debug modes) would let a style or a difficulty pick it.
- b0a0's notes stand (the generic J1 answers ignore `:min-reach`; `:guard` doubles as the neutral guard).

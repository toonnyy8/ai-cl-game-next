# The late-match finish (2026-11-15)

The user's call, on checkpoint 2b's stalls (DUEL_AI_STRATEGY §11.29): 「加「後段收尾」行為 (Recommended)」, the option "Use the clock cue
(the late part of the match) to give both sides a finishing move: the side ahead closes in to finish, and the side behind presses. Then
check that K.O. ≥ 90%." Bar D (PLAN4 §D): HARD vs HARD K.O. rate ≥ .90 on the cross pairings; mirrors reported. Seeds 141-180, both
seats (80 a row). Tools: `finish/finish.py` (`bar`, `diag`, `onset`), `finish/diag-run.lisp` (strat-run.lisp with a late-match trace; read
only). Sim build before: `27c3a6e1920d` (main 2b74d1c9).

## 1. Diagnosis (before any code)

Rows: the shipped lookup (no `STRAT_`: each HARD CPU plays the game's table) KI KH IH KK II HH, and arms5's final Hisagi tables against
the arms5 opponents as inband.md §5 played them (kh5 = `t0-kh-kenpachi` vs `t0-kh-hisagi`, ih5, hh5 = `t0-hh-hisagi` x2).

| Row | K.O. | time-outs | what the time-outs are (last 60 s of each, `finish.py diag`) |
|---|---|---|---|
| ki, kh, kk | 1.000 | 0 | — |
| ih | .975 | 2 | — |
| ii (mirror) | .475 | 42 | 28 a **lockstep**: both seats in KESSA press the same thing on the same frame, NS3a > SA > cancel > `cpu clash ns into his sa` > NS3a, one cycle a second (~120 move starts a side a minute, no damage); 14 active to the bell |
| hh (mirror, B4 table) | .000 | 80 | 78 a **stare from the first exchange** (last move start a median 296 s left, at 9-9): both Shikai Hisagis idle at 1.75 m |
| kh5 | .362 | 51 | 51 a **stare**: Kenpachi (Nozarashi, ahead on Konpaku) and Hisagi (bind mode) idle at 1.3-1.5 m, no move for the rest of the clock; onset a median 139 s left (quartiles 118 / 153), the trailing side then at 5-6 Konpaku mostly |
| ih5 | .588 | 33 | 33 **active to the bell**: last move start a median 0.9 s before it; Hisagi (ranged mode, `hs-r-j1` / `hs-r-n1a`, ~30 moves a minute at 3.5-5 m) ahead in 25, the trailing side at 1-2 Konpaku in 28; Konpaku still change a median ~25 s before the bell |
| hh5 (mirror) | .025 | 78 | 60 a stare (bind mode, 1.7 m), 18 active; onset a median 146 s left with the trailing side at 7-9 |

Pace (K.O. matches, s of play per Konpaku taken by either side): KI 13.7, KH 17.9, kh5 15.3, ih5 20.0, II 17.9, hh5 23.9.

**Who holds and why** (kh5 seed 144 traced whole: after Kenpachi's Soul Break at 160 s left and the reset, both step in once and stand at
1.3 m for 156 s, both on arm 0; `act dash`, no decision logged):
- **KEN-KI-STYLE's Hoho-safety discipline** (`cpu-ki-ken.lisp` `*KK-NS-SAFE-P*`, HARD 1.0; KK-PICK / KK-DECIDE: no move with a startup over
  `*KK-HOHO-BLIND*` 8 frames against an idle opponent, else `:walk` in and retry). Hisagi plays it outside his ranged mode (HISAGI-MERGED-STYLE:
  the Shikai's merged arms and the bind mode); Kenpachi's stand-off breaker (`cpu-kh-ken.lisp` KEN-KH-STANDOFF-STYLE) turns it off only when
  he is *not* winning the bell ("winning the bell he keeps his patience"). Two of them walk into each other. Check (diagnosis only):
  `STRAT_SET='*kk-ns-safe-p*=(:easy 0.0 :normal 0.0 :hard 0.0)'` turns kh5 seed 144 from a 300 s time-out into a K.O. at 203 s.
- **hh (B4's mirror table)**: the same check leaves seed 141 a stare (2 move starts), so its holder is another of the borrowed brawler's
  waits; the stare starts at 9-9 a few seconds in, so no late rule can K.O. it.
- **ii**: no one holds; a symmetric loop through the exchange layer (CAI-CLASH) and KESSA's SA, which a late rule that leaves the exchange
  layer alone does not touch.
- **ih5**: no one holds either: the leader pokes from his band (the ranged mode's kit range, 3.0-4.5 m) and lands too little to finish.
- **The ahead side by the cues disagrees with the bell**: `:lead` reads Konpaku only, HB-BEHIND-P Reishi only; in kh5 seed 144 Hisagi is
  -2 Konpaku but +.80 Reishi, ahead by his own code and losing at the bell.

**What follows for the design**:
- The cross rows that fail are kh5 (a stare under Kenpachi's bell-winning patience) and ih5 (active, too slow). An inactivity trigger would
  leave ih5 as it is: the finish fires on the clock and the bell's order alone.
- The mirrors' stalls (hh's stare at 9-9, ii's lockstep, hh5's stare at 7-9) are out of a late rule's reach; reported.
- Not a strategy-layer unit: the stares run under arm 0 of every table; STRAT-OUT's rules read STRAT-FEATS, which has no `:time`; NORMAL's
  none-arm windows play with no table at all. So the finish is action-layer code, after the exchange (CAI-XCH-STEP) and the clash
  (CAI-CLASH), before the strategy's fn and the MCTS.
- "Late": kh5's stares start 118-153 s before the bell with the trailing side at 5-6 Konpaku; at ~15 s a Konpaku that needs ~90 s. An elapsed
  share of 0.6 (120 s left: the foot of `:t-late`, where the `:rb-sp2` `:time` cue starts to read late) leaves that with a margin; 0.7 (90 s)
  leaves none.

## 2. The design and its variants

**Where**: `core-ai.lisp` CAI-FINISH, one line in CORE-BRAIN-STEP's cond after CAI-XCH-STEP and CAI-CLASH (the exchange layer keeps every
step it takes) and before the strategy's fn, the MCTS and the style CPUs; free steps only (idle / run), so a style's strings, Kikon holds
and reels stay its own. It plays the generic neutral (CAI-NEUTRAL with FINISH: the kit's own `:range`, no strategy `:range` scale, and no
NS or J1 started inside its dead zone, MV-MIN-REACH: the generic roll would pick NAGI at 1.7-3.6 m). **The pure predicate**: `rules.lisp`
FINISH-ROLE (host-tested in `tests/duel-rules/core.lisp`), over MATCH-ELAPSED (the same function the `:rb-sp2` `:time` cue now calls) and
TIME-UP-WINNER (the bell's own order: Konpaku, then Reishi %). **The rule**: from `*cai-finish-at*` 0.6 of the clock (tuning.lisp, new),
the side ahead at the bell takes the finish at once (it closes to finish); the side behind, or a level bell, only once it has neither
attacked (`:move`) nor been hit (a reel) for a whole decision gap of its own, `*cai-think*` + 12 frames (HARD 24, NORMAL 34, EASY 46: its
style passed up a decision), so a trailer's attacking style keeps the step and a holding one is pressed for. The quiet is one brain slot,
`fin-t` (the last tick in `:move` or reeling; the ECS store is in every snapshot). Every CPU, every difficulty; no chance, so no EASY ≤
NORMAL ≤ HARD question. Not a strategy unit (§1).

**Variants tried** (temporary builds `bdd27318f0cb`, `6d13ca4cea6f`, `2d8356d8db96` with A/B knobs for the roles and the quiet, removed before the commit (the before and shipped rows: `27c3a6e1920d`, `a144ffd570a4`), so the variant rows is not reproducible from the commit without re-adding them; all on 141-180, the bar's own block: the shape was chosen for the user's wording, "ahead closes, behind presses", and
the smaller point swing, not for passing; W is the trailer's quiet in frames). K.O. rate / A's points:

| variant | ki | ih | kh5 | ih5 | ii | hh5 |
|---|---|---|---|---|---|---|
| before (27c3a6e1920d) | 1.000 / .113 | .975 / .550 | .362 / 1.000 | .588 / .212 | .475 | .025 |
| every role at once | 1.000 / .338 | .988 / .200 | .938 / .950 | .938 / .050 | .475 | .300 |
| ahead and even at once, behind never | 1.000 / .300 | 1.000 / .575 | .863 / .900 | .850 / .138 | .525 | .025 |
| every role after W 30 | 1.000 / .200 | .975 / .350 | .975 / .912 | .825 / .062 | .575 | .175 |
| every role after W 60 | 1.000 / .163 | .988 / .338 | .925 / .938 | .825 / .075 | .525 | .175 |
| every role after W 120 | 1.000 / .163 | 1.000 / .650 | .938 / 1.000 | .700 / .188 | .575 | .025 |
| ahead at once, behind / even after W 30 | 1.000 / .275 | .988 / .388 | .938 / .963 | .925 / .087 | .525 | .175 |
| ahead at once, behind / even after W 60 | 1.000 / .300 | 1.000 / .438 | .925 / .938 | .875 / .125 | .550 | .125 |
| ahead at once, behind / even after W 120 | 1.000 / .263 | .988 / .450 | .950 / .900 | .800 / .113 | .550 | .025 |
| **shipped: ahead at once, behind / even after `*cai-think*` + 12** | 1.000 / .250 | .988 / .338 | .975 / .975 | .887 / .075 | .550 | .350 |

- A gate on the leader leaves ih5 short (its time-outs are active to the bell: the leader pokes from his band); no gate on the trailer
  swings IH to Hisagi (.55 → .20). W is not picked from the table: it is the trailer's own decision gap by rule (≈ 30 at HARD).

## 3. The scripted check (`finish/scene.lisp`)

One set-up state, only the clock and the score changed: P1 a HARD CPU Kenpachi in Nozarashi at 20 % Reishi (arms5 `t0-kh-kenpachi`), P2 a
HARD CPU Hisagi in the bind mode, full (arms5 `t0-kh-hisagi`), 8 m apart as after a reset: kh5's stare.

| run (`scene.lisp -- fas LEFT K1 K2 SECS 20 80`) | FINISH-ROLE | what happens |
|---|---|---|
| 200 s left, Konpaku 6-4 (Kenpachi ahead), 20 s | P1 / P2 nil (elapsed .33) | both walk in to 1.4 m and stare: **0 move starts in 20 s** (quiet past 1,100 frames) |
| 100 s left, 6-4, 12 s | P1 `ahead` from the first step; P2 nil while quiet < 24, `behind` at 24 | `P1 cpu finish ahead at 8.0`, at 3.0 m both start (P1 KE-S-N1A, P2 HS-B-NA1 0.43 s in); **6 / 5 move starts**; P2 at quiet 22 (role nil) answers P1's finish J1 by the clash (`cpu clash ns into his na`, HS-B-N1A: the exchange layer keeps its step) |
| 100 s left, 4-6 (Hisagi ahead), 12 s | P2 `ahead` at once, P1 `behind` at quiet 24 | `P2 cpu finish ahead at 8.0`, both start 0.43 s in; 6 / 5 move starts |

## 4. Bar D and the points (`finish.py bar`, `finish/bar.jsonl`)

Sim build after `6d1fdd364f23` (`a144ffd570a4` before a docstring reflow: the same rows, both blocks; the scene and the ladder ran on it); `STRAT_SET='*cai-finish-at*=2.0'` on it (the finish off) reproduces the before build's 141-180 rows
exactly (every row, K.O., points, bell). K.O. rate / A's points (mirrors' points are .5 by construction), 80 matches a row:

| row | 141-180 before | 141-180 after | 501-540 before | 501-540 after |
|---|---|---|---|---|
| ki (Kenpachi) | 1.000 / .113 | 1.000 / .250 | 1.000 / .050 | 1.000 / .163 |
| kh (Kenpachi) | 1.000 / 1.000 | 1.000 / 1.000 | 1.000 / 1.000 | 1.000 / .988 |
| ih (Ichigo) | .975 / .550 | .988 / .338 | .975 / .525 | 1.000 / .263 |
| kk | 1.000 | 1.000 | 1.000 | 1.000 |
| ii (mirror) | .475 | .550 | .450 | .475 |
| hh (mirror, B4) | .000 | .000 | .025 | .025 |
| kh5 (arms5: Kenpachi) | .362 / 1.000 | **.975** / .975 | .338 / .975 | **.988** / .925 |
| ih5 (arms5: Ichigo) | .588 / .212 | **.887** / .075 | .550 / .163 | **.887** / .075 |
| hh5 (mirror, arms5) | .025 | .350 | .000 | .425 |

- **Bar D (cross rows ≥ .90)**: the shipped KI / KH / IH pass before and after; arms5's KH (both sides) passes, .362 → .975 (.988 on the
  fresh block); **arms5's IH stays short, .588 → .887 on both blocks** (71 of 80; 9 / 8 time-outs, Hisagi ahead in 9 / 8): not retuned.
- **The points are the finish's real cost**: ih5's new K.O.s come mostly from the trailer being finished (Ichigo .212 → .075); KI moves
  toward even (Kenpachi .113 → .250); the shipped IH moves to Hisagi (Ichigo .550 → .338, .525 → .263 on 501-540).
- Mirrors: II's lockstep and HH's stare at 9-9 stay (§1); hh5 .025 → .350.

## 5. The dev ladder (`sp/ladder.py --seed0 500 --seeds 100`, 200 a cell; before = the same build with the finish off)

**17 → 15 of 27.** Lost: H>N IH .765 → .497 (bell 49 → 53), N>E HK .785 → .695. Moved: H>N HK .435 → .460, H>N IK 1.000 → .995, H>N HH
.930 → .970 (bell 184 → 159), N>E IH .920 → .790, N>E KI .950 → .940, N>E IK 1.000 → .990, E>M KI .105 → .155, E>M IH .110 → .130, E>M HI
.275 → .250; the rest within one match. No tuning for it (the brief). JSON: `build/ladder/finish-{before,after}.json`.

## 6. Checks

Host tests 3718 checks ALL PASS (14 new: 3 MATCH-ELAPSED, 10 FINISH-ROLE, 1 the knob's range; 3704 before); `tools/pkgcheck.sh duel` (the one unexported-look name
`DUEL::APP` is as before); `./build.sh duel`; smoke; G2 regenerated (native = browser): II 40 lines P1 2-0 393.2 s, IK 37 P1 2-0 369.6 s,
KK 26 P2 0-5 262.3 s (was II 37 P2 0-6 366.3 s, IK 35 P1 4-0 349.2 s, KK 26 P2 0-5 257.7 s); fulltest on 2102 4007: 3 checks, 0 differ.

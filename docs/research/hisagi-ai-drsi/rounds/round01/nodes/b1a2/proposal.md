# b1a2 (round 1, §25.15 freeze): 読鎖 YOMI-GUSARI, the waiting chain that reads him

Cell b1a2, round 1. A refine of round01 b1a1 (0.7741), primary style the Bankai ranged routes (遠距路線). Everything is in
`duel/lisp/hisagi.lisp`'s CPU parts (knobs, CPU-only HSS slots, the HS-*-AI-* functions) and the host test's
`HISAGI-CPU-TESTS` section.

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`, freeze 3686d94)

| | baseline | b1a1 (parent) | b0a1 | b2a0 | b3a0 | **b1a2** |
|---|---|---|---|---|---|---|
| **score** | 0.0 (raw 0.4149) | 0.7741 | 0.7945 | 0.7855 | 0.785 | **0.7783** (raw 0.7783) |
| strength (HARD, 480) | 0.006 | 0.448 | 0.498 | 0.458 | 0.490 | **0.467** |
| masher (224) | 0.188 | 1.000 | 1.000 | 1.000 | 1.000 | **1.000** |
| signature | 0.751 | 0.879 | 0.890 | 0.896 | 0.876 | **0.877** |
| sig_by chain / ranged / bind | 0.373 / 0.204 / 0.174 | 0.562 / 0.219 / 0.098 | 0.881 / 0.005 / 0.004 | 0.777 / 0.066 / 0.053 | 0.757 / 0.079 / 0.041 | **0.572 / 0.216 / 0.089** |
| plain J / counter / Kikons / Breaker | 0.111 / 0.037 / 0.063 / 0.038 | 0.056 / 0.025 / 0.035 / 0.005 | 0.069 / 0.012 / 0.023 / 0.006 | 0.054 / 0.018 / 0.027 / 0.005 | 0.064 / 0.020 / 0.033 / 0.008 | 0.060 / 0.030 / 0.028 / 0.005 |
| NORMAL share (factor) | 0.104 (0) | 0.4896 (1) | 0.527 (1) | 0.454 (1) | 0.5625 (1) | **0.5229 (1)**: Y 46, K 26, R 38, I 50, S 63, Lille 28 of 80 |
| pacing (NORMAL medians, all 240 K.O.) | 115-175 s | 113-173 s | 104-158 s | 111-162 s | 110-164 s | **117.1-176.0 s** (Lille 176.0, Senjumaru 174.8) |

`score.json` is the exact line. **The 40-seed number is mostly the seed draw here.** Two files whose HARD play differs only by
one extra `sim-rnd01` per escape (the same decisions, another random stream) measured strength 0.512 and 0.477 on seeds 1-40
(score 0.7901 and 0.780). So every variant below was compared on **1200 HARD matches** (seeds 1-40 + 101-160, both seats, the
log runner that reproduces aieval's strength and signature to the match: the parent gives 215 / 480 and 0.879 there, as
aieval does).

| 1200 HARD matches | wins | strength | signature | 0.3 s + 0.5 g | Y | K | R | I | S | Lille (of 200) |
|---|---|---|---|---|---|---|---|---|---|---|
| b1a1 (parent) | 551 | 0.459 | 0.881 | 0.5781 | 145 | 56 | 144 | 27 | 179 | 0 |
| + MIKIRI both forms, ranged TODOME, the pure hop always (M6) | 571 | 0.476 | 0.875 | 0.5804 | 152 | 30 | 138 | 78 | 173 | 0 |
| ... the pure hop off (M7A) | 542 | 0.452 | | | 132 | 50 | 138 | 50 | 172 | 0 |
| ... + the lash read (M9) | 583 | 0.486 | 0.876 | 0.5840 | 148 | 48 | 133 | 69 | 185 | 0 |
| **... + the read's exploration (this file)** | **577** | **0.481** | **0.878** | **0.5833** | 147 | 53 | 135 | 63 | 179 | 0 |

Against the parent: HARD +0.022, signature -0.003 (the TSUME J1s and the ranged Hoho counters), +0.005 in score terms on
1200 matches; the 40-seed draw gave +0.004. That is within the noise of a 40-seed rescore (about ±0.01 of score).

Host tests: duel-rules **9874 checks ALL PASS** (the frozen 9865 + 9, the section only; splicing this section into the frozen
file gives the delivered `duel-rules-test.lisp` byte for byte); control 89, learn 131, input 33, cine 18 ALL PASS, touch 64
(0 failures); `tools/pkgcheck.sh duel` clean.

## History read

| cell | mechanism | rescored | lesson used here |
|---|---|---|---|
| baseline | awoke at once, SAHARAI spam, the dead windmill string | 0.0 | — |
| prior b0a0-b3a0 (§25.12) | RENSA / KARIBA, the ranged fence, the blade gate, the reaping fence | 0.637-0.766 | the Shikai is his strength |
| round01 b0a0 | prior b3a0 + KAZAGURUMA-GAESHI + TODOME, gate 4500 | 0.783 | the best Shikai layers |
| round01 b1a0 | the route styles SENTAN / KAISEN / NAWAJI, gate 2000 | 0.7517 | the ranged theme costs HARD |
| round01 b2a0 | the bind first, the SAHARAI-cancel bug fixed | 0.7855 | the noose, not the Reiatsu, is the bottleneck |
| round01 b3a0 | b0a0 + b1a0's routes, gate 3000, the reap's proof | 0.785 | the gate is near strength-neutral |
| round01 b0a1 | b0a0 + 見切り MIKIRI (the Hoho read) and 詰 TSUME (the close-in) | **0.7945** | his biggest leak is the perfect Hoho of his K1, mostly Ichigo's |
| round01 b1a1 (parent) | b3a0's Shikai + 待鎖 MACHI-GUSARI (the ranged mode answers only) | 0.7741 | removing the neutral swings won; removing the escape hop lost |

The parent had no MIKIRI. b0a1 had no Bankai to speak of (gate 4500, ranged + bind 1 % of his damage). Nobody had looked
at what the Bankai's answers themselves leak, after MACHI-GUSARI removed the neutral swings.

## The diagnosis (combat logs as aieval runs them: per form, per (move, why) n / hit / block / perfect-Hoho'd / net 240 f)

1. **The awakening forced on or off** (HARD, 480 matches, the parent + the MIKIRI port): never 217 wins (Y 53, K 7, R 54,
   I 29, S 74 of 80), at once 202 (Y 36, **K 24**, R 52, I 24, S 66). The Bankai wins Kenpachi (its bind deals 46-54 a
   second against him, takes 18-22) and loses Yamamoto and Ichigo.
2. **What it loses them with is the escape's lash.** With the awakening forced, his escape hop (b1a0's: a hop and a run out to
   the style's tip) fires ~12 times a match against Yamamoto. The generic Step -> J (ai.lisp, 0.9 at HARD) lashes the
   ranged J1 off every hop at its f10. Against Yamamoto that J1 hit 8 % and was blocked 35 % (-94 net a lash); against
   Ichigo it was perfect-Hoho'd 41 % (-96 to -127). Per opponent (1200 HARD, the parent): answered (blocked or
   perfect-Hoho'd) Y 0.48, I 0.51, R 0.42, S 0.40, Lille 0.22, **K 0.20**; net a lash -93 / -127 / -15 / +23 / -53 / -27.
3. **The ranged openers into a free opponent are perfect-Hoho'd too**: the anti-approach K1 37 % by Ichigo (-110 net), the
   same read b0a1 made of the Shikai's K1 (S 16 / S 14 here, still inside a HARD brain's 8 f lead).
4. **The forced KOSA**: a route's link 3 on a red victim forces the generic O ender (1.4 % of his damage, plain).

## The styles (行動方針) and the mix

| layer | roll | styles and chances (EASY / NORMAL / HARD) |
|---|---|---|
| the Shikai, 始解鎖鐮連段 (b1a1's = b3a0's) | once a match (HS-AI-STYLE) | **RENSA 連鎖** 0.55 / 0.55 / 0.8, **KARIBA 刈場** 0.45 / 0.45 / 0.2; KAZAGURUMA-GAESHI, TODOME per event |
| **見切り MIKIRI, the Hoho read, across both forms** (b0a1's, ported; carried into the ranged mode here) | read on events: each slow opener of his (the Shikai's K1, the ranged K1 / J1) into an opponent able to Hoho | the Shikai: **詰 TSUME** (the reap held back 0 / 0.2 / 0.75, the close-in 0 / 0.3 / 0.75); the ranged mode: the anti-approach strike held back 0 / 0.2 / 0.75 |
| the awakening | the kit gate `:awaken (:min-taken 2000)` (b1a0's, unchanged) | the Bankai once he has taken 2000 |
| the ranged posture | every entry | 待鎖 MACHI-GUSARI (b1a1's: no neutral swings, answers only) |
| the ranged route style, 卍解遠距路線 | once per entry into the ranged mode (HS-R-STYLE) | **SENTAN 尖端 60 %**, **KAISEN 回旋 25 %**, **NAWAJI 縄路 15 %** (b1a0's) |
| **the way out, 退歩 TAIHO / 逃げ NIGE** (new) | once per escape / dodge (HS-TAIHO-P) | TAIHO (the pure hop) 0 / 0 / 1.0 **when the lash read 鞭読み MUCHI-YOMI says so, 80 % of those escapes** (20 % NIGE: the read kept measured); else NIGE, b1a0's hop-and-run with the generic lash |
| **the ranged TODOME** (new) | once per route link-2 hit on a red victim | RAIDEN cancelled out of it, 0.2 / 0.4 / 1.0 |
| the bind, 捆綁 (b1a1's) | per change event | the release 150 behind on grey, KOJO per entry into 2.5-4 m |

**MIKIRI across both forms.** He keeps two counts a match: his slow openers thrown while the opponent could Hoho (free, his
flash-step at a Hoho's, no Hoho of his seen for 36 f), and how many were perfect-Hoho'd. Over 0.42 (prior 1 / 3), and while
the opponent can Hoho: in the Shikai the reap and the hop out to it are held back and the chain comes in by hand (the
step-in J1, then the windmill bridge: b0a1's TSUME); in the Bankai the anti-approach K1 / J1 into his approach is held back
too (the punish by annulus, the SAHARAI cancel and the Hoho stay). The ranged K1 / J1 feed the same counts, so the Bankai
starts with what the Shikai learnt. At HARD the read turns on mostly against Ichigo and Rukia (TSUME's close-ins and dashes
in 8-9 a match against them, under 2 against the others).

**TAIHO 退歩, the pure hop, and MUCHI-YOMI 鞭読み, the lash read.** The escape's Step is held 20 frames with the stick
neutral. BRAIN-STEP counts such a press down without running a reflex, so nothing fires on the hop's f10 and the generic
Step -> J never lashes; the press ends before the hop's 24 f end, so no run. He lands 2.5 m back and waits. That alone (M6):
Ichigo 27 -> 78 of 200, Yamamoto +7, but Kenpachi 56 -> 30: a lone 2.5 m hop lands in Kenpachi's own Step -> J1 range (769
of his Step-J1s after 2825 hops), where the hop-and-run outruns him. So he reads his lashes: each NIGE lash's result
(blocked, perfect-Hoho'd, hit, whiffed); once more than 0.32 (prior 1 / 3) of them are answered, the escapes and dodges
turn to TAIHO, but 20 % still take NIGE so the read keeps measuring. Kenpachi's 0.20 keeps NIGE; Yamamoto's, Ichigo's,
Rukia's and Senjumaru's 0.40-0.51 turn to TAIHO within a few lashes. Per match at HARD: Ichigo 6.9 pure hops / 4.6
hop-and-runs, Rukia 7.4 / 6.6, Yamamoto 4.5 / 3.4, Kenpachi 2.3 / 6.1, Senjumaru 2.3 / 3.2, Lille 0.3 / 1.9. Ranged
mode against Ichigo: taken 38.7 -> 28.1 a second; over all six 29.3 -> 26.9.

**The ranged TODOME.** The Shikai's TODOME (b0a0's) in the ranged mode: a red victim's route link 2 (J2 / K2s / K2 / J2s)
cancels into RAIDEN (9 m line) when SP1's bar is there, not the link 3 whose hit forces KOSA: 0.05-1.0 a match by
opponent; KOSA 1.4 % -> 0.8 % of his damage.

NORMAL and EASY keep b1a1's escape (TAIHO 0 there): with the pure hop at NORMAL too, NORMAL's share fell 0.49 -> 0.36 (the
lash lands on NORMAL CPUs). NORMAL's other new values are b0a1's MIKIRI (0.2 / 0.3) and the TODOME's 0.4.

## What a human will notice

He opens as the chain kusarigama (at HARD mostly RENSA: J1, the windmill flick, the long reaping K string, lightning). If
you perfect-Hoho his sideways sweep a few times, he stops throwing it at you and walks the chain in by hand. Once you have
hurt him for about a soul and a half: KARE, KAZESHINI. In the Bankai he waits at the chain's tip and never swings at you
standing still. Rush him and he hops back. At first he lashes the bundle at you from the hop's far end. If you block that
lash or Hoho it, he stops lashing: from then on he just hops clear and waits again, mostly. He punishes what you whiff
from wherever the chain reaches. Off a SAHARAI hit he drags you into the route, and at its end the noose goes round your
neck and the bind starts. If you Hoho his chain, he stops throwing it into your approach as well. When you are in the red,
the route's second lash turns into the lightning.

## Tried and dropped (measured, 1200 HARD matches unless noted)

| variant | result | verdict |
|---|---|---|
| the MIKIRI port alone (480, seeds 1-40) | 215 -> 216 (Ichigo 9 -> 21 of 80, Rukia -6) | kept as the base of the cross-form read |
| MIKIRI in the ranged mode: no escape hop under the read either (K R I, 240) | 100 -> 94 (Kenpachi 24 -> 17 of 80) | dropped |
| the pure hop at every difficulty (aieval, m5) | NORMAL 0.4896 -> 0.3604 | HARD only |
| 退き読み NOKI-YOMI: an outcome read of both ways (his loss in the 90 f after each, the lower mean, 20 % the other) (480) | 241 -> 228; it took the pure hop 60 % against Kenpachi and Ichigo alike | dropped: too noisy to split them within a match |
| 追手読み OITE-YOMI: a chaser read (a pure hop hit within 60 f, prior 1 / 7, over 0.2: run) | 570 (K 32) | dropped: Kenpachi 0.25-0.28 vs Senjumaru / Lille 0.21-0.22, no split |
| 二段退歩, a second pure hop as the first lands (within 5 m) | 532 (K 29, I 47) | dropped |
| the lash read by value (hit +1, blocked -0.5, whiff -0.25, perfect-Hoho'd -1; bar -0.12) | 570 | dropped (≈ the rate, more knobs) |
| the gate 1500 / 3000 (with the lash read) | 555 (signature 0.874, ranged + bind 0.42) / 578 (0.880, 0.13) vs 583 (0.876, 0.30) | 2000 kept: as strong, and the ranged theme in view |

## Mechanisms implemented (CPU parts only)

- **Ported** (CPU hunks of round01 b0a1, never its file): `*HS-AI-MIKIRI-P*`, `*HS-AI-MIKIRI-PRIOR*`,
  `*HS-AI-MIKIRI-RATE*`, `*HS-AI-HOHO-QUIET*`, `*HS-AI-CLOSE-P*`; HS-MIKIRI-RATE, HS-HOHO-READY-P, HS-OPP-HOHO-READY-P,
  HS-MIKIRI-UNSAFE-P, HS-MIKIRI-NOTE, HS-AI-CLOSE; HS-AI-REFLEX / HS-AI-FENCE / HS-AI-MOVE's hooks into them; the HSS slots
  `ai-hr-*`, `ai-hseen`, `ai-cz*`.
- **New (this cell)**:
  - `*HS-AI-MIKIRI-MOVES*` (the read counts the ranged K1 / J1); HS-R-AI-REFLEX / HS-R-AI-MOVE note them, and the
    anti-approach strike's roll is held back under the read.
  - `*HS-AI-R-TODOME-P*`, `*HS-R-LINK2*` (HS-R-AI-MOVE).
  - `*HS-AI-TAIHO-P*`, `*HS-AI-HOP-HOLD*` (the pure hop), `*HS-AI-MUCHI-PRIOR*` / `-RATE*` / `-EXPLORE*`; HS-MUCHI-RATE,
    HS-MUCHI-NOTE, HS-TAIHO-P; the HSS slots `ai-ls-*`. None of them is hashed.
  - Pacing counters: `ai-taiho`, `ai-nige`, `ai-lash-bad`, `ai-r-todome` (with b0a1's `ai-mikiri`, `ai-close`,
    `ai-rush`, `ai-hoho-read`).
- **Not touched**: HS-AI-OPP and its knobs, every move, every rule and human hook, the art, the sim ticks, HS-HASH, every other
  file; the gate (`:awaken (:min-taken 2000)`).
- **Kept working**:
  - AI-AWAKEN-P is the only way in (the kit gate; the debug :always / :never modes win).
  - The learner's read clock: the new reads act on events (a move's start, a free step after it, an escape) and return NIL.
  - The ASSIST: the new code sits in the reflexes and move-reflexes, and the reads are gated on HS-TICK-BRAIN (his own CPU),
    so a borrowed brain never writes them.
  - The debug modes 83000-83999 and the `duel hisagi` line.
- Every new chance is an (:easy :normal :hard) plist, EASY ≤ NORMAL ≤ HARD (host-pinned). Each is rolled once per event: an
  escape, a dodge, a link-2 hit, an approach, a reap.
- **The pure hop and the vpad.** It is a plain `ai-press` of Step for 20 frames (act :step). BRAIN-STEP's countdown branch
  skips the reflexes while it runs. That is the existing press path, as a long guard or the windmill's L hold uses it. It
  reads no input and touches no rule.

## Host tests (the section)

The section keeps b1a1's pins and adds b0a1's MIKIRI pins (the rate with its prior, HS-HOHO-READY-P, the chances). It also
pins this cell's own:
- the slow openers the read counts (each S ≥ 14, the Shikai's J1 S 8 not);
- the ranged TODOME's chances, and the link-2 list against `*HS-R-STRINGS*`;
- TAIHO HARD-only, held past *STEP-J-CANCEL* - 2 and let go before *STEP-FRAMES*;
- the lash read: the prior, the bar, Kenpachi's 2 of 10 under it, 5 of 10 over it, and the exploration.

## Why it is not a repeat

- MIKIRI is b0a1's, reused and stated as such; carrying it into the ranged mode is new.
- The lash is a leak every ranged cell had and none named (b1a0 / b2a0 / b1a1 named the generic Step -> J only as a shared
  recommendation). This cell closes it from the kit's own presses, without touching ai.lisp. It also measured why the
  plain fix fails (Kenpachi), and replaced two failed in-match reads (the outcome read, the chaser read) with one that
  splits the opponents: the lash's own result.

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, NORMAL, 60 seeds a stream; pairs 28 29 30 31 32 34)

The never-awaken side's wins of 60 (this file / the baseline, b0a0's measure):

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100 | 39 / 2 | 21 / 1 | 35 / 0 | 26 / 0 | 52 / 1 | 32 / 0 |
| 300 | 30 / 2 | 23 / 0 | 40 / 0 | 28 / 1 | 48 / 4 | 22 / 1 |
| 500 | 30 / 1 | 22 / 0 | 36 / 0 | 34 / 0 | 49 / 2 | 25 / 0 |

- Every row is at least 21 of 60, so it passes (the bar is 20). All 1080 matches are K.O.s; medians 103.4-153.6 s.
- The rows equal round01 b0a1's to the match. The never side is b0a1's NORMAL Shikai: the parent's Shikai changes are
  HARD-only, and the MIKIRI port brings b0a1's NORMAL values.
- HK (21-23) stays the closest to the bar, as in every cell.

## Expected benefit and risks

- **Benefit**:
  - HARD +0.022 on 1200 matches (Ichigo 27 -> 63 of 200 the most) with the ranged theme kept (0.216 of his damage);
  - the ranged mode bleeds less (taken 29.3 -> 26.9 a second);
  - masher 1.0, NORMAL mid-band (0.52).
  - The 40-seed score is +0.004 over the parent and below b0a1 / b2a0 / b3a0; at this noise level a rescore can move it
    ±0.01.
- **Signature -0.003**: TSUME's step-in J1s are plain, and the pure hop keeps him nearer, so more of his Hohos become
  counters (the ranged mode's counter share 1.0 -> 1.3 % of his damage; 1.8 % with the pure hop always).
- **Kenpachi**: 56 -> 53 of 200 (the read keeps NIGE against him most of the time; its first lashes or the exploration's 20 %
  are the cost). Rukia 144 -> 135 (MIKIRI's read turns on against her 30 % Hoho rate sometimes, b0a1's note).
- **Pacing**: the longest median is Lille's 176.0 s (cap 220), Senjumaru 174.8.
- Lille stays 0 of 200 at HARD in every variant (the ranged mode takes 52 a second from her).

## Shared-code recommendations (not built)

- **ai.lisp's Step -> J** reads only the kit's J1 reach. A kit key (`:step-j` 0, or honouring `:min-reach`) would let an
  escape be a hop and a run without the lash. TAIHO gets the no-lash half from a held press, but cannot keep the run, which
  is what Kenpachi needs.
- **The kit's `:hoho`** is one number for every difficulty (b0a0's note). The ranged mode's 0.9 now turns into 3 % of his
  damage as plain counters.
- (Standing) AI-AWAKEN-P is one gate for every difficulty and opponent. The forced O ender on a red victim leaves a kit no
  say (2.8 % of his damage is Kikons over his three forms).

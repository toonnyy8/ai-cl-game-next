# b2a0 (§25.15 freeze): 首吊 KUBITSURI, the bind first: the Bankai as his comeback, the ranged mode a transit to the noose

Cell b2a0, round 1 on the §25.15 freeze (3686d94). Primary style: the bind (捆綁). PARENT_DIR none: a new direction from
BASELINE_DIR, built (as this round's b0a0 / b1a0 were) as a new combination: this round's b0a0 Shikai, unchanged, under a
Bankai rebuilt around the bind. Everything is in `duel/lisp/hisagi.lisp`'s CPU parts and the host test's
`HISAGI-CPU-TESTS` section.

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`)

| | baseline | b0a0 (0.783) | b1a0 (0.7517) | **b2a0 (this file)** |
|---|---|---|---|---|
| **score** | 0.0 (raw 0.4149) | 0.783 | 0.7517 | **0.7855** (raw 0.7855) |
| strength (HARD, 480) | 0.006 | 0.435 | 0.400 | **0.458** |
| masher (HARD, 224) | 0.188 | 1.000 | 1.000 | **1.000** |
| signature | 0.751 | 0.905 | 0.863 | **0.896** |
| sig_by chain / ranged / bind | 0.373 / 0.204 / 0.174 | 0.895 / 0.005 / 0.005 | 0.605 / 0.175 / 0.083 | **0.777 / 0.066 / 0.053** |
| non-sig: plain J / Kikons / counter / Breaker | 0.111 / 0.063 / 0.037 / 0.038 | 0.055 / 0.024 / 0.013 / 0.004 | 0.050 / 0.060 / 0.020 / 0.005 | 0.054 / 0.027 / 0.018 / 0.005 |
| NORMAL share (factor) | 0.104 (0) | 0.525 (1) | 0.5625 (1) | **0.454 (1)**: Y 50, K 19, R 23, I 39, S 61, Lille 26 of 80 |
| pacing (NORMAL medians, all K.O.) | 115-175 s | 104-158 s | 115-167 s | 110.7-162.1 s (Ichigo 162.1 the longest) |

The JSON line is `score.json`. The ranged and bind themes are 12 % of his damage (b0a0: 1 %) at b0a0's score: the three
themes all show, the Shikai's chain still carries the match. Host tests: duel-rules 9871 checks ALL PASS (the frozen 9865
+ 6 in the section; the splice of this section into the frozen file is byte-identical to the delivered
`duel-rules-test.lisp`), control 89, learn 131, input 33, touch 64 (0 failures), cine 18; `tools/pkgcheck.sh duel` clean.

## History read

- Baseline (0.0): awakens at once; its ranged mode a death zone.
- This round: b0a0 0.783 (b3a0's port: the Shikai chain RENSA / KARIBA behind the reaping fence, the Bankai a last stand at
  4500 taken; plus KAZAGURUMA-GAESHI and the Shikai's TODOME); b1a0 0.7517 (the same Shikai, the gate 2000, three ranged
  route styles; the ranged + bind themes 0.26 of his damage for -0.035 HARD, NORMAL nerfs to stay in band).
- PRIOR (§25.12 rules, scores not comparable): b0a0 0.637 (the Shikai fixes), b1a0 0.567 (the ranged fence), b2a0 0.684
  (the blade gate `:melee-share 0.999`, the bind plans SHIME / TSURUSHI, the Reiatsu keep; the bind showed in 0.3 binds a
  match), b3a0 0.766 (the reaping fence + both).
- What the history says about the bind: never measured as a form of its own. Every cell found the ranged mode the cost;
  the bind's own value was hidden behind it (b1a0 §25.13 table: HARD bind 46.5 dealt / 26.2 taken a second).

## The diagnosis (combat logs as aieval runs them; scripts in the cell's scratch)

1. **The bind wins, the ranged mode around it loses.** HARD, b0a0's file, the awakening forced at once (P1, 10 seeds a
   pairing), dealt / taken a second by form: vs Kenpachi Shikai 29.0 / 28.8, ranged 22.9 / 48.2, **bind 73.9 / 46.6**; vs
   Ichigo 25.4 / 35.8, 19.4 / 95.7, 28.2 / 31.4; vs Lille 26.1 / 17.8, 8.6 / 113.2, 27.9 / 23.6. Bind by bind: the drained
   ones net **+374** each (22 of 27 ahead), the released ones -324 (undone by the release, as the rules say). The bind with
   its release is an option he wins; the ranged gaps (~20 s before each bind) are where he dies.
2. **The noose, not the Reiatsu, is the bottleneck.** In the ranged mode he held 200 or more in 37-72 % of the hash samples.
   His KUBIKAKE by tag (40 matches): off a confirmed hit (the cancel copy) 49 of 53 hit; timed into an approach (AI-ANTI)
   24 of 88 (side-stepped 14, whiffed 26: a 60 f recovery); KUBIGARI's neutral noose **0 of 20**.
3. **A located bug: the SAHARAI hit cancel never fired.** 35 SAHARAI hits, 1 L-CANCEL. HS-R-AI-MOVE read the victim's
   distance at L's first recovery frame, while the push still carried him through K1's dead zone (2.0 m), so the pick was
   L again and nothing pressed; the generic guard cancel took the recovery at f39. Read where the push leaves him (3.5 m):
   49 L-CANCELs, K1 hits 94 % of them, and that K1 hit is a confirmed hit for the noose.
4. **KAIBAKU-GEKI's 18 f startup was hit 11 of 40 times** (no release: the drain then made his loss real).
5. **Plain Kikons in the Bankai.** The ranged mode's KOSA rush from range (its neutral / reeling uses) hit 29 %; every
   Kikon is non-signature; the generic O ender (0.15) also fired on victims not red.
6. **The gate trades HARD for NORMAL through the awakening's heal** (20 % + 5.6 s of 70 a second: ~650 Reishi). Paired
   runs (the same seeds, P1, 60 HARD matches; identical until his awakening, so only the awakened matches differ) against
   b0a0: gate 4000 +2 / -3, 3000 +3 / -3, 2000 +6 / -5 (strength neutral), the signature 0.883 -> 0.880 / 0.862 / 0.842 as
   the Bankai's leaks grow. NORMAL rose much more: at 3000 with b0a0's NORMAL values 0.74.

## The styles (行動方針) and the mix

| layer | roll | styles and weights |
|---|---|---|
| the Shikai, the chain (始解鎖鐮連段) | once a match (HS-AI-STYLE) | **RENSA 連鎖 55 %** / **KARIBA 刈場 45 %** (b0a0's, unchanged) |
| the awakening | the kit gate | **at 3000 taken**: the Bankai as his comeback (4500 before) |
| the ranged mode, a transit (卍解遠距路線) | once per entry (HS-R-STYLE) | **SOKUBAKU 束縛 80 %** / **SANGE 散華 20 %** (b1a0's; KUBIGARI gone) |
| the bind (捆綁) | once per bind (HS-B-PLAN, SIM-RND01) | **TSURI 吊 50 %** / **SHIME 絞 50 %** |
| per event | per hit / change event | the noose off a confirmed hit (0 / 0 / 1.0), the release (0.2 / 0.3 / 0.9), the bind's TODOME (0.1 / 0.2 / 0.9), the rain (0.1 / 0.15 / 0.7) |

(Chances EASY / NORMAL / HARD.)

**KUBITSURI 首吊, the bind first (the cell's plan, every Bankai):**
- **The ranged mode is a transit.** At HARD every confirmed hit ends in the noose: off a J1 / K1 / link hit (the cancel copy),
  off the punish by annulus (KUBIKAKE first with his 200), off the ender. His routes are the way to that hit:
  - SAHARAI's hit now cancels into K1 where the push leaves him, and K1 into the noose: **L -> K1 -> KUBIKAKE**;
  - the perfect Hoho's counter -> the SAHARAI punish -> the same chain.
  - No noose timed into an approach, none from neutral (KUBIGARI), no KOSA rush from range (`:kikon-range` 0), no O ender
    on a victim not red (`:o-ender` 0): the Kikon only as the O ender forced on a red victim.
- **The bind is read as a drain would settle it** (HS-DRAIN-MARGIN): the grey margin (Konpaku x 1300 + Reishi, his loss -
  the opponent's) plus the Soul Break a fighter at 0 live Reishi pays at the drain (B7: the other's Kikon worth + 1, x 1300).
- **The release:** behind by 150 on that margin (rolled per change event, every 50 of the pool or a Konpaku change):
  - KAIBAKU-GEKI (the release and its 120) only with him beyond 2.5 m or seen recovering past its startup;
  - with the pool at 200 or less, the plain FREE (P) at once (applied that same step);
  - else he waits for one of the two.
- **TODOME of the bind:** a K link 2 hit (K2 / K2s: a stagger the rain combos from) on a red victim while not behind: the
  rain KUSARI-AME cancelled out of it (signature, the pool spent toward the drain that makes the lead real), not the link
  3 whose hit forces the O ender's grey (plain) Kikon.

**TSURI 吊, the long hang (50 % of binds):** the bind is his best form and the ranged mode his worst, so he milks it.
- He releases only once the pool is down to 250 (the drain near) or he is 900 behind.
- He rains only to settle: ahead, with the pool at 300 or less (two rains drain it).
- A human sees a long melee bind: no chains raining, the noose held until the very end.

**SHIME 絞, the choke (50 %):** b0a0's bind with the drain read.
- The rain off every completed string while he is ahead, so the lead is made real fast.
- He releases as soon as he is 150 behind.
- A human sees short binds that end in the chain rain.

What a human notices:
- He fights two thirds of the match as b0a0's chain kusarigama.
- After about 3000 damage (two and a half souls), KARE, KAZESHINI. He backs off behind the chains and waits. Your first
  clean mistake (a whiff he punishes, a hit through his SAHARAI, a perfect Hoho), and the noose is round your neck.
- In the bind he either hangs on to the end, or chokes you with the rain.
- If the bind goes against him, he throws it off: the strike, or a bare FREE the moment the pool runs low.
- He never rushes a Kikon from range in the Bankai.

How often (HARD, P1, 60 matches of a 10-seed run): awakened in 29; 47 binds (20 drained at +369 net each, 17 of them
ahead; 27 released at -228, undone); the noose 50 thrown off confirmed hits, 44 hit; 15 L -> K1 cancels.

## Tried and dropped (aieval unless noted; 20 seeds = 240 HARD matches)

| variant | strength | NORMAL | raw | score | verdict |
|---|---|---|---|---|---|
| gate 3000, b0a0's NORMAL values (v4) | 0.492 | 0.7375 | 0.794 | 0.066 | NORMAL out of band (the heal) |
| + b1a0's NORMAL fence / release / rain values (v5) | 0.492 | 0.671 | 0.794 | 0.419 | still out |
| + the punish's noose gated by the throw roll, NORMAL throw 0.05 (v6) | 0.492 | 0.671 | 0.794 | 0.419 | the binds are not NORMAL's edge |
| v6, gate 3500 | 0.438 | 0.604 | 0.780 | 0.759 | |
| v6, gate 4000 | 0.450 | 0.550 | 0.786 | 0.786 | in band, the Bankai rarer (ranged + bind 0.03) |
| NORMAL throw 0 (v7) | 0.492 | 0.650 | 0.794 | 0.530 | |
| NORMAL fence 0.1-0.15 (v9) | 0.492 | 0.6125 | 0.794 | 0.728 | |
| **NORMAL fence 0 (v10 = this file), 40 seeds** | **0.458** | **0.454** | 0.7855 | **0.7855** | kept |
| v10, gate 2500, 40 seeds | 0.438 | 0.377 | 0.778 | 0.778 | more Bankai, more leaks; NORMAL low |
| the bind's plans forced TSURI / SHIME (awakening at once, bindx 60 matches) | 17 / 21 of 60 | | | | inside the noise: kept 50 / 50 (drained +368 / +379 a bind) |
| the noose on the first free step after the awakening's cinematic | 7 throws in 60 awakenings, 1 hit | | | | dropped |

The 20-seed HARD 0.492 at gate 3000 fell to 0.458 at 40 seeds: the gate is strength-neutral within the noise (as the
paired runs said); what it buys is the bind / ranged themes in the matches he is losing, at b0a0's score.

## Mechanisms implemented (CPU parts only)

- **New functions:**
  - HS-SB-WORTH, HS-DRAIN-MARGIN, HS-RELEASE-DUE-P (pure, host-tested);
  - HS-B-PLAN, HS-R-NOOSE-OK-P;
  - HS-B-AI-MOVE, the bind kit's new `:move-reflex`.
- **Changed:**
  - HS-B-AI-REFLEX: the plan's release, the drain margin, the FREE fallback, KAIBAKU-GEKI only when safe;
  - HS-B-AI-ENDER: the drain margin; TSURI rains only to settle;
  - HS-R-AI-MOVE: the SAHARAI cancel read where the push leaves him;
  - HS-R-AI-REFLEX: no KUBIKAKE in the anti-approach, no KUBIGARI, the noose in the punish behind its roll, the red
    reeling victim to the punish (no generic Kikon rush);
  - HS-R-STYLE: two styles.
- **Kits:**
  - the Shikai: `:awaken` (:min-taken 4500 -> 3000);
  - the ranged mode: `:kikon-range` 9.0 -> 0, `:o-ender` 0, no `:kikon` in its far bands;
  - the bind: `:kikon-range` 3.0 -> 0, `:o-ender` 0, `:move-reflex` HS-B-AI-MOVE.
- **Knobs:**
  - new: *HS-AI-BIND-PLANS*, *HS-AI-HANG-POOL* 250, *HS-AI-HANG-FAR* 900, *HS-AI-SETTLE-POOL* 300, *HS-AI-FREE-POOL* 200,
    *HS-AI-FREE-NEAR* 2.5, *HS-AI-B-TODOME-P*;
  - changed: *HS-AI-THROW-P* 0.2 / 0.45 / 0.7 -> 0 / 0 / 1.0, *HS-AI-RELEASE-P* NORMAL 0.6 -> 0.3, *HS-AI-BIND-SP-P* NORMAL
    0.35 -> 0.15, the ranged fence's EASY / NORMAL (*HS-AI-PUNISH-P*, *-ANTI-P*, *-DODGE-P*, *-R-ANTI-BREAKER-P*,
    *-ESCAPE-P*) -> 0 (HARD kept);
  - removed: *HS-AI-KUBIGARI-P* and KUBIGARI's style entry, the unused *HS-AI-PLAIN-RELEASE-P*.
- **HSS CPU slots:** `ai-plan`, `ai-plan-from` (new); `ai-mid` (removed). None is hashed.
- **Pacing counters:** `plan-tsuri` / `plan-shime`, `ai-b-todome`.
- **Not touched:** HS-AI-OPP and its knobs, every move, every rule, the art, every other file, HS-HASH, the sim ticks.
  The Shikai's CPU is b0a0's byte for byte.
- **Kept working:**
  - The awakening goes only through AI-AWAKEN-P's kit gate.
  - The learner's clock: the new reads act on events and return NIL otherwise.
  - The ASSIST: the bind's hooks read the brain they are given.
  - The debug modes 83000-83999 and the counters.
  - Every chance is EASY <= NORMAL <= HARD, rolled once per event: a hit, a change event, a bind, an entry, a match.

## Why it is not a repeat

- The Shikai is b0a0's as it stands (reuse). The Bankai's pieces are new or aimed at located causes:
  - the SAHARAI cancel bug (1 -> 49 cancels);
  - the noose only where it lands (confirmed hits 44 of 50; KUBIGARI's 0 of 20 and the anti-approach's 26 % removed);
  - the drain margin that prices the Soul Breaks a drain settles;
  - FREE against KAIBAKU-GEKI's stuffed startup;
  - the bind's TODOME;
  - the Bankai's plain Kikons cut, the move b0a0 made in the Shikai, carried into both Bankai modes.
- Prior b2a0 had a bind plan too (SHIME / TSURUSHI). Its bind never showed (0.3 binds a match), so its plans were never
  measured. Here the plans sit on the drain margin, and the bind shows in half the HARD matches.

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, NORMAL, 60 seeds a stream; pairs 28 29 30 31 32 34)

The never-awaken side's wins of 60 for this file, next to b0a0's (from its proposal) and the baseline's:

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100: b2a0 / b0a0 / baseline | 36 / 36 / 2 | 21 / 21 / 1 | 35 / 35 / 0 | 25 / 25 / 0 | 51 / 51 / 1 | 31 / 31 / 0 |
| 300: b2a0 / b0a0 / baseline | 29 / 29 / 2 | 23 / 23 / 0 | 42 / 42 / 0 | 29 / 29 / 1 | 48 / 48 / 4 | 22 / 22 / 1 |
| 500: b2a0 / b0a0 / baseline | 31 / 31 / 1 | 22 / 22 / 0 | 35 / 35 / 0 | 33 / 33 / 0 | 48 / 48 / 2 | 24 / 24 / 0 |

Every row is at least 21 of 60, so the A/B passes (the bar is 20). Every match is a K.O. (medians 103-153 s). The rows are
b0a0's to the match: the never side is b0a0's Shikai, unchanged here (the gate moved, the Shikai's CPU did not). The HK
rows (21-23) remain the closest to the bar.

## Expected benefit and risks

- **The benefit:**
  - b0a0's score (+0.0025, inside the noise) with all three themes in play: chain 0.777, ranged 0.066, bind 0.053;
  - HARD 0.458, the masher 1.0, NORMAL mid-band (0.454).
- **The NORMAL share is the gate's price.** The awakening's heal at 3000 taken lifts NORMAL. It stays in band only because
  the ranged fence is HARD's only (EASY / NORMAL 0): a NORMAL Bankai fences nothing, binds rarely and leans on the heal.
  NORMAL 0.454 at 40 seeds, but 0.61-0.67 whenever NORMAL's fence was 0.15 or more. A refine raising those values must
  re-measure NORMAL.
- **The gate is strength-neutral within the noise** (paired runs, 20 vs 40 seeds). Moving it trades signature (the
  Bankai's leaks) for theme share.
- **Pacing:** the longest median is 162.1 s (cap 220): no risk.
- **Lille stays near 0 at HARD in every form.** Ichigo and Kenpachi stay low.

## Shared-code recommendations (not built)

- **ai.lisp's generic Step -> J** is the Bankai's biggest leak. Off every back hop (his fence's escape) it lashes the ranged
  J1: 110 starts in 60 HARD matches, 23 hit, 44 of them hit back. That is plain J damage. A kit hook (or `:min-reach` / a
  `:step-j` key) would let a form keep the hop as a pure escape.
- **AI-AWAKEN-P is one gate for every difficulty.** The awakening's heal makes the gate a NORMAL lever as much as a HARD
  one. A per-difficulty `:awaken` would let NORMAL wake later than HARD, so a NORMAL Bankai could keep its fence.
- (Standing.) The forced O ender on a red victim leaves a kit no say. The Bankai's Kikons (0.008 here) and the Shikai's
  come from it.

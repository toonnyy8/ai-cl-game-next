# b1a0 — the ranged routes (遠距路線): the fence and three ranged styles

Cell b1a0, round 1, a new direction from the baseline (primary style: the Bankai ranged routes). Everything is in
`duel/lisp/hisagi.lisp`'s CPU parts (the three kits' `:ai` plists, the HS-*-AI-* functions and knobs, four CPU-only HSS
slots, HS-AI-KAZA-K in the windmill's brain branch) and the host test's `HISAGI-CPU-TESTS` section (+6 checks: 9886 ALL
PASS; pkgcheck clean).

## History read

- `baseline/` (the shipped CPU, §25.12): score 0 — raw 0.3848, HARD strength **0.000** (0 of 480), masher 0.107, signature
  0.727, NORMAL share **0.042** (factor 0). No earlier cell has a result (round 1; b0a0 runs alongside), so nothing to
  repeat or avoid but the baseline itself.
- Diagnosis (the combat log, run as aieval runs it; scripts kept in the cell's scratch, not here): per second of each form
  (NORMAL, 10 seeds per opponent) the baseline dealt / took **Shikai 14 / 30, ranged mode 8-12 / 21-43, bind 18-29 /
  17-36**. The ranged mode was half of every match and its worst part: the opponent stood inside 2 m for 40-45 % of it.
  Located causes, all in his CPU:
  1. **SAHARAI spam**: HS-R-AI-REFLEX pressed L (S 18) on every entry within 2 m whatever the opponent did (0.85 HARD); of
     ~120 per 10 matches 30 % were hit in their startup, 35 % blocked (−16), 30 % hit. The 0-2 m band weighted L 6 more.
  2. **Generic J1 presses into J1's 3 m dead zone**: the generic punish / follow-up / block punish / pressure reset /
     anti-Breaker all press `:q` (the ranged J1, 3-6 m) inside 3 m: J1 PUNISH whiffed 11 of 15, J1 BREAKER-STRING 11 of 13.
  3. **A SAHARAI hit was never cancelled** (§25.5's J / K cancel on a hit): no reflex pressed J / K in its recovery.
  4. **The Shikai's HARD block punish** picks K1 off a −20 block inside 2.1 m: always inside K1's 3.0 m dead zone.
  5. **The bridge windmill's K** waited until the victim was past 3.1 m (f19+), so K1 came after the stagger: of 11
     bridge K1s 5 were hit in startup, 3 blocked, 3 whiffed.
  6. **The bind's release** was only taken within KAIBAKU-GEKI's 3.36 m reach and 300 behind, though its release happens at
     its S at any distance (`hs-kaibaku-go`): 4 releases of 17 binds.

## The styles (the 行動方針)

One shared core, **the fence (鎖界)**, and three named ranged styles rolled with SIM-RND01 **once per entry into the
ranged mode** (the awakening, and every bind's end):

| Style | Chance (every difficulty) | Ranged mode: what it does that the others don't |
|---|---|---|
| **SOKUBAKU 束縛 — the bundle** | 64 % | K1-opened gathered routes: K1 (2-5 m, 360°) is its opener for punishes, after a SAHARAI hit and against a runner; the K link 80-90 % per link hit (K2 → K3G, guard ×1.3); back hop to 3.2 m |
| **SANGE 散華 — the spread net** | 16 % (20 % of the rest) | J1-opened spread routes from 4-6 m: J1 opener, the J links (route K only 20-30 %: J2 → J3, the 6.6 m push, Reiatsu ×1.3 / ×1.69 at the tip); back hop to 3.8 m |
| **KUBIGARI 首狩 — the noose hunter** | 20 % | hunts the bind: KUBIKAKE thrown from neutral once per stay at 3.5-6.5 m with his 200 (20 / 40 / 60 %), K1 opener, mixed links (50-70 % K) |

The mix's numbers are `*hs-ai-kubigari-p*` 0.2, `*hs-ai-sange-p*` 0.2 (of the rest), the styles' table `*hs-ai-styles*`
(`:open :anti :route-dmg :keep :noose`). SOKUBAKU carries the weight because alone it measured best (20 seeds: 0.564 vs
SANGE alone 0.536); the other two keep the variety the user asked for.

**The fence** (every style, `HS-R-AI-REFLEX`, `HS-R-PICK`, `HS-AI-ANTI-BREAKER`):
- **the back hop (退鞭)**: once per entry within 2 m while the opponent isn't attacking, the back Step (`*hs-ai-escape-p*`
  0.3 / 0.7 / 0.85) — the hop's iframes, then the generic Step → J lashes J1 from its far end (3-4 m, outside the
  opponent's reach). The single biggest gain (masher 0.04 → 0.48 → 0.80 as it rose, NORMAL 0.11 → 0.33);
- **punishes by annulus**: a recovering / reeling opponent (one roll per action, 0.3 / 0.6 / 0.9) gets the move whose
  annulus holds him in the frames there are: KUBIKAKE first with the 200 (2.3-7 m, S 24: the bind), else the style's
  opener, else the other, SAHARAI inside 2 m only when it lands in time; the same out of his own blockstun (felt at once);
  where the generic reflex would press J1 inside 3 m, `:wait` instead (no whiff);
- **SAHARAI** only as a read (0.05 / 0.1 / 0.15 of what the hop leaves, never into an attack or a runner) and its hit
  cancelled at once into the style's opener (§25.5);
- **Hoho and guard**: the ranged kit's `:hoho` 0.3 → 0.9 (his S 14-18 J / K lose every close trade; the Hoho's iframes
  and its perfect counter don't), `:guard` 0.5 → 0.85, the neutral guard 0.2 (a held guard up close fed the opponents'
  long-guard Breaker), no Breaker / L-heavy 0-2 m band (the back Step there);
- **against the Breaker** (every form): seen dashing in within 4 m, Hoho through it, else the back hop (0.3 / 0.6 / 0.85;
  the generic answer, J1 into the dash, lost the trade or missed inside 3 m);
- **the dodge**: his J / K / L perceived starting up close with 2-14 f to go: the back hop (0.2 / 0.45 / 0.7);
- **anti-approach**: once per run of his seen coming in (0.2 / 0.45 / 0.7), KUBIKAKE / the style's strike timed to land as
  he runs into its annulus (rarely fires: the roster's runs start inside the window; kept as the styles' face).

**The bind** (`HS-B-AI-REFLEX`): the release is rolled per change event (every 50 of the pool drained, any Konpaku change)
when he is 150 behind on grey (`*hs-ai-rel-margin*`; the rules' HS-RELEASE-WANTED-P keeps its pinned 300), and pressed —
KAIBAKU-GEKI at **any distance** (its S releases whatever the strike touches) — once the opponent isn't attacking; the
bind's `:hoho` 0.3 → 0.9, no Breaker in its bands. Measured on the final file's parent: drained binds end with him ahead
47 of 55 at NORMAL (released 30), 14 of 24 at HARD (released 41).

**The Shikai** (`:base`): `:string-k` 0.7 → 1.0 (J1 → K2J → K3, the chain theme, not the plain J2 / J3), the bridge's K
pressed at f9 once the victim is 1.6 m away (`*hs-ai-bridge-k-from*`: the 2.5 m push carries him past 3.0 m before K1's S
18; bridge K1 now hits 6 of 7), the block punish with J1 (not the generic HARD K1 into its own dead zone), Hoho 0.3 → 0.1
(the perfect Hoho's counter is plain damage; the Shikai's chain strings are the theme), no Breaker in the bands. The
awakening is untouched (AI-AWAKEN-P, no `:awaken` key: the A/B was not needed).

Every new chance is an (:easy :normal :hard) plist read by HS-P, EASY ≤ NORMAL ≤ HARD (host-pinned), rolled once per event
(an opponent action's react roll, a blockstun's end, a close-band entry, a run, a stay, a link hit, a form entry, a bind
change event). The learner's read clock, the ASSIST's borrowed brain (:move-reflex reads the brain it is given) and every
debug / pacing counter are kept; new `duel hisagi` counters `ai-escape ai-punish ai-block-punish ai-anti ai-dodge
ai-anti-breaker ai-noose ai-l-cancel sange sokubaku kubigari`.

## Why it is not a repeat

The baseline is the only history. This is a structural change of the ranged mode's close-in plan (the hop instead of L,
punishes by annulus, the Hoho fence) plus located bug fixes (items 2-6 above), not a retune of the baseline's knobs.

## Measurement (tools/aieval.py --char 7 --seeds 40 -j 2, the freeze 7623542)

| Part | Baseline (§25.12) | b1a0 (this file) |
|---|---|---|
| **score** | **0.0** | **0.5669** |
| raw | 0.3848 | 0.5669 |
| strength (HARD, 480 matches) | 0.000 (0) | 0.056 (27: Senjumaru, Yamamoto, Rukia, Kenpachi; Ichigo, Lille 0) |
| masher | 0.107 | 0.862 |
| signature | 0.727 | 0.756 |
| sig_by chain / ranged / bind | 0.436 / 0.178 / 0.112 | 0.299 / **0.309** / **0.148** |
| sig_by plain J / counter / Breaker / Kikons | 0.128 / 0.045 / 0.043 / 0.057 | 0.084 / 0.063 / 0.029 / 0.069 |
| NORMAL share (factor) | 0.042 (0) | **0.452 (1.0)**: Y 42, K 14, R 27, I 43, S 58, Lille 33 of 80 |
| pacing (NORMAL medians, all K.O.) | 117-173 s | 126-193 s (Y 125.7, K 129.8, R 159.9, I 179.8, S 163.7, Lille 193.0) |

What a match looks like now (NORMAL, 60 matches, per match): ~3.9 ranged-mode entries (SOKUBAKU 2.5, KUBIGARI 0.8,
SANGE 0.6), 13.8 back hops, 1.4 punishes by annulus, 3.8 KUBIKAKE thrown (3.0 off a confirmed hit, 0.7 from neutral) for
3.1 binds (1.1 released, 2.0 drained), 1.0 windmill bridge, 80 s in the ranged mode (the opponent inside 2 m 30 % of it,
the baseline's 40-45 %), 39 s bound. HARD: 9.4 hops, 2.9 punishes, 1.2 Breaker answers, 2.1 binds (1.2 released).

Path (raw at 10 / 20 / 40 seeds, the same evaluator; NORMAL share): the fence v1 0.459 (10, NORMAL 0.11) → the hop kept
(v4a) 0.533 (10, 0.33) → `:string-k` 1.0 0.532 → SOKUBAKU-weighted mix 0.550 (20) → no Breaker bands 0.560 (20) → the
bridge K 0.5634 (40, NORMAL 0.37) → the Hoho 0.9 in the ranged mode and the bind, 0.1 in the Shikai, the anti-Breaker,
KUBIGARI 0.5669 (40, NORMAL 0.45). Rejected (measured worse or flat): the hop held without its J1 (0.42), more KUBIKAKE
off hits (−0.006), the bridge at 70 % (−0.010), a release margin of 50 (flat), wider ranges, the Shikai's guard 0.6, the
Hoho 0.9 in the Shikai too (strength +, signature −: the counter is plain).

## Expected benefit, risks

- The score moves from 0 to ~0.57: NORMAL in the band's middle (0.45), the masher beaten 86 %, the signature held at
  ~0.76 while the ranged theme rose 0.18 → 0.31.
- HARD strength stays low (~0.05): the HARD opponents read his S 14-18 J / K, and the hop's J1 is stuffed half the time
  at HARD (fine at NORMAL). Most HARD wins come against Senjumaru and Yamamoto; Ichigo and Lille 0.
- The Hoho share: the perfect Hoho's counter is ~6 % of his damage (not signature); the Shikai keeps 0.1 for that reason.
- Pacing: Lille's NORMAL median 193.0 s (cap 220): the closest; every match a K.O.
- `:hoho` / `:guard` / `:neutral-guard` / `:string-k` are generic kit keys read the same at every difficulty (as every
  kit's); the difficulty layering is in the new plists.

## Shared-code recommendations (not built)

- ai.lisp's generic reflexes (punish, follow-up, block punish, pressure reset, step-J, anti-Breaker, Breaker string)
  assume J1 reaches from 0 m; a kit with a J dead zone (`:min-reach` on its `:q` move) could have them skip it or pick the
  kit's own command (his CPU now answers before them with `:wait`, but the step-J and the Breaker string come earlier in
  AI-REFLEX and still whiff inside 3 m).
- The block punish never reaches a kit's `:reflex` when the guard was held with `:act :hold` (the hold's decrement branch
  runs on the first free step): `ai-block-punish` never fired; a hook there would let a kit choose its punish.

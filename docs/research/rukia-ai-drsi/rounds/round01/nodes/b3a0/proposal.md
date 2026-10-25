# b3a0 (round 1): the cold clock — awaken against everyone, one K grammar in every form, the cash-outs by payoff

Primary axis (the brief): the awakening and her three bands (when to awaken, each band's tactics, the cold). Opened from
BASELINE_DIR (no parent). History read: BASELINE_DIR, b0a0 (0.7154 rescored: matchup tables, the bind -> O fix) and b1a0
(0.7506 rescored: value tables for the confirm / cash, the J1 envelope); b2a0 had no result yet. Planning base read:
`docs/research/rukia-cpu/` (sheet-shikai, opponents/rukia-m18 / -m50 / -zero, matchups-shikai, both catalogues,
strategy-shikai), rukia.lisp's bands, rukia-meter.lisp, tuning.lisp's cold knobs, ai.lisp (AI-AWAKEN-P, AI-REFLEX's order,
STRING-REFLEX, BRAIN-STEP).

## 1. Result (EVAL_COMMAND, 40 seeds, the final file)

| | baseline | b3a0 |
|---|---|---|
| **score** | 0.5898 | **0.719** |
| strength | 0.273 (131/480) | 0.329 (158/480) |
| masher | 1.0 | 1.0 |
| signature | 0.616 | **0.841** |
| NORMAL share (band 0.30-0.60) | 0.423 | 0.417 (x1) |
| pacing (NORMAL P1 medians, all K.O.) | 100.8-140.4 s | 96.3-147.0 s |

str_by_opp (HARD, of 80): Yamamoto 29 -> 39, Kenpachi 0 -> 1, Ichigo 58 -> 64, Senjumaru 44 -> 33, Lille 0 -> 1,
**Hisagi 0 -> 20**. NORMAL by_opp: Lille 34, Hisagi 37, Ichigo 36, Kenpachi 13, Senjumaru 42, Yamamoto 38 (of 80).
sig_by: poke 0.300, kstring 0.269, burst 0.254, kido 0.017; not signature: counter 0.100 (the perfect Hoho's), Breaker
0.029, the O (the Kikon strikes on a red victim) 0.031, plain J 0.000 (baseline: kstring 0.126, plain J 0.094, O 0.097).

**Paired, final vs the shipped CPU** (the same seeds and seats; my combat-log runner over the native sim, which gives the
evaluator's strength and signature exactly: checked on two files against aieval, 0.6799 = 0.6799 and 0.7190 = 0.719):

| block (seeds) | shipped wins | b3a0 wins | diff (SE, z) | signature |
|---|---|---|---|---|
| 1-20 (240) | 69 | 79 | +0.042 (0.031, 1.36) | 0.613 -> 0.844 |
| 21-40 (240) | 62 | 79 | +0.071 (0.033, 2.16) | 0.618 -> 0.837 |
| all 480 | 131 | 158 | **+0.056 (0.022, z 2.51)** | |

## 2. Diagnosis (combat logs of the shipped CPU, 10-20 seeds a pairing)

1. **She never awakens against Hisagi, seldom against Lille.** EVOLUTION came in 20 of 20 matches each, the awakening in
   0 of 20 (Hisagi) and 5 of 20 (Lille): `:awaken (:melee-share 0.6 :min-taken 150)` needs 60 % of her damage taken from
   blades, and Hisagi's chain / Lille's shots are ranged. Against the four melee opponents she awakened 20 of 20. The
   awaken A/B (the never-awaken side 2-24 of 60) says the awakening is worth a lot; she threw it away in exactly the two
   matchups she lost 0 of 80. **Measured: the shipped melee rule back on the final CPU -> Hisagi 0/40, she awakens 0/40;
   the rule off -> 10/40 (seeds 1-20).**
2. **The bands' damage is mostly not hers, and so is the Shikai's.** Per band (shipped CPU, 120 matches): signature share
   base 0.55, -18 0.57, -50 0.73, -273 0.79. The leaks: the J links (J2 / J3: `:string-k` 0.3, 70 % J strings), the plain
   O (the O ender `:o-ender 0.25` in the bands, `*AI-RU-ENDER-O*` 0.9 after a K3 / J3, the ENBU rush in the Shikai's
   :moves from 2.8 m, the O cash of a stun with no bar `*AI-RU-CASH-O*` 0.9: RU-KIKON was 18.7 % of the Shikai's damage).
3. **The bands per minute** (the final CPU, 480 matches; minutes of each form, cinematics in): -273 deals ~3000-4400 a
   minute and takes ~0 (the ward), -50 deals 330-1800 / takes 1200-2900, **-18 deals 120-690 / takes 800-1800** (her worst
   band: the passive cooling guard and nothing of her own). His openers on her in the bands are his J1 (HS-J1, IC-K-J1,
   KE-J1, YA-E-J1, SJ-J1: ~180 of the -50 openers in 60 matches) and Lille's far dash L (BR-E-L1 / BR-OE-L1).
4. **Zero visits are short and good**: ~1-2 a match, 75-140 frames, 95-150 damage each, 0 taken inside; they end with the
   one L / SP that cashes the top bar (REIDO after the ward's freeze-touch). Cooling into zero more often (§5) loses: the
   extra visits are cold ones (he far, the ward drained by shots: Lille's matches cracked 18 times in 40) and the 1.1 s
   guard that buys them is free pressure for him.
5. **Her red rushes at -50 whiff**: the neutral Kikon rush on a red opponent within `:kikon-range` 7.5 (HAKKA's lane: 8
   aura + 20 f) hit 24 of 94 starts; the HARD CPUs step out of it (ANTI-KIKON) and punish.

## 3. The tactics by condition (all in duel/lisp/rukia-ai.lisp)

### 3.1 The awakening (AI-AWAKEN-P's own gate, `:awaken`)

| condition | before | b3a0 |
|---|---|---|
| EVOLUTION, any opponent | awaken only after >= 150 taken, >= 60 % of it from blades | awaken (>= 150 taken; `:melee-share 0.0`) |

The awakening's timing stays AI-AWAKEN-P's (the free reflex and the combo break); the debug modes 39000+10a+b force it
as before. (The only knobs of that gate are :min-taken / :melee-share / :awaken-above: delaying it to a combo break or a
low-Reishi moment is not expressible there; EVOLUTION already arrives after ~1000 taken, so :min-taken never binds.)

### 3.2 The cold: when each band cools

| band | condition | before | b3a0 |
|---|---|---|---|
| -18 | a neutral decision | cool (hold U to -50) 0.3, within 3.5 m | **0.9, at any distance** (`:cool (:p 0.9 :near 99.0)`): -18 is her worst band, leave it |
| -50 | a neutral decision | cool to zero 0.35 within 4 m, no shot out, gg >= 50 % | kept (more cooling to zero measured worse, §5) |
| -273 | the ward's block just froze him (freeze-touch, felt at once), him inside her J1's reach | REIDO 0.9 | **REIDO 198 or the J route J1 K2s K3 + its cash-out 351**, by payoff (RUKIA-AI-WARD-ROUTE-P; HARD: the route 76 %) |
| -273 | the ward blocked a later hit / a Breaker's dash | REIDO | REIDO, only when she is free (not in her own answer) |

### 3.3 One grammar in every form: the K route and the K3 cash-out by payoff

Every form presses the K link whenever one exists (`:string-k 1.0`: J1 -> K2s -> K3, K1 -> K2 -> K3; all of it signature:
the J1 / K1 poke, the K links), never a plain O ender (`:o-ender 0.0`; ai.lisp's O ender on a red victim, the Kikon, still
fires first), no L off a band's K1 / K2 (`:l-after-k 0.0`: the string runs to K3). The K3 that hit is cashed by
RUKIA-AI-BAND-ENDER (*AI-RU-BAND-ENDER* EASY 0 / NORMAL 0.5 / HARD 1.0 of the hits; the Shikai's link-3 burst chance in
RUKIA-AI-BURST-P scaled by the rest, so at HARD the pick decides). Options and payoffs (the catalogues' gain over K1 K2 K3;
picked by probability ∝ value^k, k = *AI-RU-PICK-SHARP* EASY 1 / NORMAL 1 / HARD 2):

| form (K1 K2 K3) | L | SP2 | SP1 | nothing |
|---|---|---|---|---|
| Shikai (208) | 白漣 140 (+94-123, knockdown +50; >= 1 霜の層: RUKIA-OK) | SHIRAFUNE 110 + 25 a layer − 1 bar | SOKATSUI 90 − 1 bar | 12 |
| -18 (229) | SHIMOBASHIRA 61 | 121 − 2 bars | the wave 77 − 1 bar | 12 |
| -50 (259) | HYOSHIN 120 (+90, crumple +18: +30) | 156 − 2 bars | 129 − 1 bar | 12 |
| -273 (344) | REIDO 168 | 231 − 2 bars | the wave 264 − 1 bar | 12 |

A bar costs *AI-RU-BAR-COST* 40; + 100 when the option would take his Reishi; − *AI-RU-OVERDRAW* 60 at -50 / -273 when it
would spend her last cold (down to -18: a whole bar of cooling owed again).

### 3.4 The Kikon as a confirm, not a gamble

| condition | before | b3a0 |
|---|---|---|
| a stun she can't cash in ice, him not red | the O (ENBU / HAKKA), 0.9 | **her J1 / K route** (the generic follow-up; the O cash only on a red victim: the Kikon) |
| the Shikai's neutral :moves 2.8-99 m | the ENBU rush as a poke (weight 1-2) | none (the O is the Kikon's) |
| -18 / -50: a red opponent, a neutral decision or a reeling one | the rush within 6.5 / 7.5 m | **within 3.5 m** (`:kikon-range`): the O ender / the stun rush after her K3's 3.1 m push |

Every chance scales EASY <= NORMAL <= HARD; one roll per event (a K3 hit, a ward block's action, a decision).

## 4. Why it is not a repeat

b0a0 read the opponent's kit (zones, his named threats), b1a0 valued the confirm / cash / envelope by her resources. b3a0
works on the forms: (1) the awakening's own gate (a located defect neither touched: 0 awakenings against Hisagi), (2) the
cold as the band's clock (-18 left at once, -50 kept as shipped after measuring that more zero loses, the ward's freeze
answered by a payoff pick), (3) one string grammar and one payoff cash-out table across the four forms (the catalogue
rows of every band; the bands' SP1 wave and the overdraw are new options), (4) the bands' Kikon range. The K links and the
no-plain-O rule overlap b0a0 / b1a0's Shikai changes (both measured them as signature): here they are the same rule in
all four forms, and the O cash fix (a plain O only on red) is new.

## 5. The search (each a 240-match strength run, seeds 1-20, my runner; score = 0.3 str + 0.5 sig + 0.2)

| step | wins / 240 | sig | ≈ score | kept |
|---|---|---|---|---|
| shipped (seeds 1-10 only: 29/120) | — | 0.605 | 0.575 | |
| awaken vs all (Hisagi / Lille only, 10 seeds) | Hisagi 0 -> 10 / 20 | | | yes |
| + -18 cools at once anywhere (v2a) | 91 | 0.641 | 0.637 | yes |
| + the bands' K route, K3 payoff pick, no O ender (v2b) | 77 | 0.720 | 0.656 | yes |
| v2b without the bands' K route (v2c) | 79 | 0.656 | 0.627 | no |
| v2b + -50 cools to zero anywhere, gg 35 (v3) | 66 | 0.717 | 0.641 | no (cracks: Lille 18 / 40) |
| v2b + -50 cools to zero 0.8 within 4 m (v4) | 66 | 0.714 | 0.640 | no |
| v2b, -50 never cools (v5) | 78 | 0.727 | 0.661 | tie: shipped kept |
| + the Shikai in the same grammar (v6) | 68 | 0.790 | 0.680 | yes (aieval 20 seeds: 0.6799) |
| + no ENBU rush poke (v7) | 70 | 0.795 | 0.685 | yes |
| + the O cash only on red (v8) | 78 | 0.835 | 0.715 | yes |
| v8 − the Breaker in :moves (v9) | 72 | 0.838 | 0.709 | no |
| v8 + -50 spacing outside his J1 (2.0-2.9 m) (v10) | 75 | 0.835 | 0.711 | no |
| + the bands' Kikon within 3.5 m (v11) | 79 | 0.839 | 0.7185 | yes (aieval 40 seeds: 0.716) |
| v11 + zero's neutral by payoff (wait / brace / REIDO / wave by his state) (v12) | 74 | 0.838 | 0.712 | no |
| v11 with -18's shipped cooling (v13) | 67 | 0.829 | 0.698 | no (the -18 cooling is worth ~12 wins) |
| v11 + -50's cold keeper (top the bar up while he is idle) (v14) | 77 | 0.835 | 0.714 | no |
| v11 + RIKUJOKORO held 14 f longer + the seal -> O (v15) | 75 | 0.840 | 0.714 | no |
| v15 + a far rush read by his closing speed -> long guard (v16; 480: 157) | 76 | 0.839 | 0.7145 (480: 0.717) | no (tie, more code) |
| **v11 + the ward's J route + the overdraw cost (v17, final; 480: 158)** | 79 | 0.844 | 0.7208 (480: 0.719) | **yes** |
| v17 + the guard inside his J1 in the bands (v18) | 74 | 0.833 | 0.709 | no (Yamamoto 21 -> 11 / 40) |
| v17 + the bands' disc 0.5 -> 0.9 (v19) | 74 | 0.840 | 0.7125 | no |
| v17 + the seal -> O + RIKUJOKORO held longer (v20; 480) | 153 / 480 | 0.839 | 0.715 | no (Hisagi 20 -> 12 / 80) |

Sequential picks on one seed block: each step's difference is within ±10 wins (1 SE ≈ 7); the final-vs-shipped blocks
(§1) are the honest number. Measured but rejected: everything that made the bands more passive (more zero, guard inside
his J1, the cold keeper) lost to the HARD CPUs' Breakers / first strikes; the seal -> O (b0a0's fix) lost Hisagi wins
here with the longer hold.

## 6. The awaken A/B (the awakening rule and NORMAL's Shikai play changed)

`python3 tools/simgate.py --summary --pairs 3,4,5 --seed0 S --seeds 60 --cmd 39020 -j 2` (she is P1, never awakening)
and `--pairs 8,12,23,30 ... --cmd 39002` (she is P2), S = 100 / 300 / 500; the never-awaken side's wins of 60 (pass >= 20),
the baseline's as b0a0 / b1a0 measured it at this freeze:

| pairing (never-awaken Rukia) | b3a0 S100 / 300 / 500 | baseline S100 / 300 / 500 |
|---|---|---|
| RY (vs Yamamoto) | 15 / 13 / 13 | 23 / 24 / 21 |
| RK (vs Kenpachi) | 3 / 3 / 7 | 3 / 2 / 6 |
| RR (the mirror) | **20 / 20** / 18 | 11 / 14 / 10 |
| IR (vs Ichigo) | 9 / 5 / 7 | 2 / 5 / 9 |
| SR (vs Senjumaru) | 16 / 19 / 18 | 9 / 12 / 12 |
| BR (vs Lille) | 8 / 4 / 7 | 7 / 6 / 6 |
| HR (vs Hisagi) | 11 / 18 / 14 | 8 / 14 / 10 |
| sum of 420 | 82 / 82 / 84 | 63 / 77 / 74 |

2 of 21 rows pass (the baseline: 3, all RY). The awakening is stronger than ever here (it now also fires against Hisagi /
Lille and the bands play their catalogue), so the A/B stays the open item of DUEL_RUKIA_TYBW §11.2; RY's rows fell as in
b0a0 / b1a0 (her Shikai's K grammar against Yamamoto's J1).

## 7. Risks

- Strength vs Senjumaru 44 -> 33 / 80 (the J strings' +5 pressure gone in the Shikai; b0a0 saw the same); Kenpachi and
  Lille stay ~0 (Kenpachi: the known Kikon-through-guard bug, §17.6; Lille's awakened far dash opens 500+ strings: v16's
  closing-speed guard blocked about half of them in a probe but won nothing).
- The K3 pick spends bars the ice cash (SHIRAFUNE after a perfect Hoho) also wants; *AI-RU-BAR-COST* 40 is hand-set.
- `:l-after-k 0.0` in the bands drops the splice of tuning.lisp's *AI-RU-L-AFTER-K-AWAKE* (the debug knob 73000+k already
  had no effect on the spliced value).
- NORMAL share 0.417 (Kenpachi 13 / 80 at NORMAL).
- Docstrings: *AI-RU-BAND-ENDER*'s and RUKIA-AI-BAND-ENDER's say "a band's K3"; since v6 they cash every form's K3
  (the code is right; left as evaluated so the file equals the scored one).

## 8. Shared-code recommendations (not made)

1. AI-AWAKEN-P's gate has no way to keep the awakening for a combo break (a Burst substitute) or a low-Reishi moment; a
   kit hook (e.g. `:awaken-when` called with the free / combo context) would let a CPU time it without going around the
   gate.
2. The cold's band switch only while she is free means a zero visit is always one L / SP long (every one costs the top
   bar). If the user wants -273 to last, a cost below 100 for REIDO would do more than any CPU change.
3. The generic post-block hold (stun + 20, no reflex) and Kenpachi's Kikon through her guard (§17.6) as noted.

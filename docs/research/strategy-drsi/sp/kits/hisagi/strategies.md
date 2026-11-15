# Hisagi: the strategy proposal (PLAN4 step 3, for the user's pick; 2026-11-15)

Built from `sheet.md`, `catalogue.md` (2415 sim trials), `matchup-kenpachi.md`, `matchup-ichigo.md` and `probe.md` (where today's CPU starts
its moves, 160 HARD matches). A strategy = which of his means to use in which `:rb-sp2` situations (PLAN4 §2: G0 lead x his red x
awakening, G1 my form x distance, G2 his state x distance, G3 cells, G4 bursts, G5 exchange, G6 walls, G7 Reishi, G8 clock, G9 switch x
pointer, G10 his pointer x distance). The fuzzy distance sets (fuzzy.lisp): `:m-close` up to 2.9-3.4 m, `:m-mid` 2.9-6.0 (core 3.4-4.5),
`:m-far` from 4.5-6.0. **`:m-close` is NAGI's dead zone and `:m-mid` its band**, so the rule base already separates the kit's main split.

## 1. Why the CPU barely wins with him (verified in code and in `probe.md`)

**What he wins with** (catalogue §1-§5): from **3.4 m out** nothing of sealed Kenpachi reaches him, and NAGI (3.0-6.4) and NS3a (1.0-5.2)
win every simultaneous press there (4.5 / 5.5 m: 51 / 33). Against Ichigo's Shikai he wins the triangle at every distance (NS2a S16 beats
both of his hitting NS openers; NAGI owns 5-6.3 m). His long routes start from there (NS1a > SA > J string > AS3 321 from 3.5 m; NS3a > YOSE
> J string > AS3 286 from 4-5.2 m), NS3a punishes every whiff at +10, and as the J side of a cancel AS1 TSUMUJI wins against every answer
(all four opponent forms, including the lunges that cover NAGI's band).

**What the CPU does instead** (code): in the Shikai his arms play `hisagi-hk-style` → `hisagi-merged-style`, which hands every non-ranged
step to **`ken-ki-style`, Kenpachi's brawler** (cpu-hisagi-range.lisp:175-189). Its neutral decision `kk-pick` (cpu-ki-ken.lisp:589-624)
fires inside the generic CPU's attack zone, the kit's `:range` hi + 0.6; Hisagi's Shikai kit has no `:range` (hisagi.lisp:410-415), so the
default `*cai-range*` (1.7 3.0) (core-ai.lisp:10) applies: it **walks him to 1.7-3.0 m and starts moves at ≤ 3.6 m**. There `kk-reach-of`
(cpu-ki-ken.lisp:585) checks only reach + slide, never `:min-reach`: under pointer 1 it presses **NAGI inside its 3.0 m dead zone** (NAGI
reach 6.0 ≥ any d ≤ 3.6), 80 % of the time beyond 1.7 m (`*cai-ns-far*`). The generic `:ns-range` shot (3.6 6.2) covers pointer 1 only, 50 %
per decision while walking in, and `kk-neutral` decides first. The generic 積極相消 (`cai-clash` / `clash-opener`, xch-ai.lisp:45) throws an
NS into his J as readily as a J into his NS, and the NS side of a cancel loses to his instant AS (X-b).

**Measured** (`probe.md`, `h4-all` = arm 0, seeds 501-540 HARD, against the shipped Kenpachi / Ichigo):

| | vs Kenpachi | vs Ichigo |
|---|---|---|
| Shikai free steps inside 3.0 m | **0.70** | 0.41 |
| NAGI starts inside 3.0 m (hit / cancelled / whiff) | **224** (9 / 202 / 13) | 155 (13 / 114 / 28) |
| NAGI starts at 3.0-6.4 m (hit) | 47 (20) | 155 (113) |
| J1 starts inside 3.0 m (hit / cancel / whiff) | 787 (107 / 532 / 148) | 416 (157 / 104 / 155) |
| AS1 TSUMUJI starts (hit) | 555 (480) | 246 (215) |
| Hisagi K.O. wins | **0 of 40** | 2 of 40 |

So against Kenpachi the CPU spends 70 % of its free time in the one band where the sheet says Kenpachi is faster with both buttons, and
throws its best long move into its own dead zone four times more often than into its band. Arms4's descriptor probe says the same from
the other side (arm 0: mean distance 2.19 m vs Kenpachi, 77 % of steps inside 3 m). The one arm that does the kit's job, `range`, is the
one that passed its proof (it plays the ranged mode's distance rule and leaves the Shikai to the generic CPU, not the brawler): against
Ichigo it K.O.s 33 of 40 here; against Kenpachi still 0 of 40, because in the Shikai it has no distance rule at all (40 % of its free
steps inside 3 m, NAGI started there 306 times).

## 2. General strategies (both opponents)

| # | Name | Idea | Situations (`:rb-sp2`) | Catalogue entries | Expressed by | Descriptor (pre-registrable) |
|---|---|---|---|---|---|---|
| S1 | **鎖の間合い (the chain's band)** | the Shikai stands at 3.4-5.2 m and fights there: NAGI on his walk / run-in (≤ 6 f after his start), on his whiffs and on a charge; NS3a as the opener and the whiff punish (pointer 3); a back Step when he closes inside 3.4 m; **never NAGI inside 3.0 m**; okizeme NAGI +40 after TSUMUJI's knockdown at 5.5 m | G1 form 0 x `:m-mid` / `:m-far`; G2 his attacking / evading x `:m-mid` (whiff punish); G2 down x `:m-mid` (okizeme); G10 his pointer x `:m-mid` (Ichigo's Getsuga charge) | R, T (Kz 4.5 / 5.5 all H; Ib 3.5+), W (NS3a +10), A (NAGI +0 / +6), C (NS1a SA … 321, NS3a YOSE … 286), K (NAGI +40), G (NAGI ≤ 20 f into the charge) | **code**: a Shikai distance rule in Hisagi's style (the ranged one, `hr-close`, is the pattern): walk to `[3.4, 5.0]`, back Step inside 3.4 while he closes (the kite's `hkk-step` exists, `:hkk-near` / `:hkk-far`), NAGI only at d ≥ 3.1 (a `:min-reach` test in the pick), NS3a ≤ 5.0; and keep `ken-ki-style` out of the Shikai neutral (it may keep the string / AS reads). Partly today: `:range 2.0` scales the generic walk band to (3.4 6.0), live only where the KI style declines (KNOBS.md, the KI style's key table: `:range` "live, partial ... Weak") | Shikai free steps at 3.0-6.4 m ≥ 0.55 (arm 0: 0.22 vs K, 0.51 vs I, probe.md) **and** NAGI starts inside 3.0 m ≤ 10 % of NAGI starts (arm 0: 83 % vs K, 46 % vs I); sheet: NAGI 3.0-6.4, dead zone 3.0 |
| S2 | **J 側の相消 (cancel from the J side)** | answer his NS start with J1, never his J with an NS; after the cancel always AS1 TSUMUJI (it wins against SA +2 / +8, NS-next, nothing); answer the long openers (his Shikai lunge to 5.7 m, KYORAN's 4.9, Ichigo's NS3a rush 5.0) the same way | G2 his attacking x `:m-close` / `:m-mid`; G5 exchange open (→ AS1); G10 his pointer x distance (Kenpachi's Shikai ptr 1 = the lunge, Ichigo ptr 3 = the rush) | T (Hb x Ks0: J1 cancels the lunge 1.5-5.5), X-a / X-d (TSUMUJI 100 % of the J-side cells), X-b (NS side loses to the instant AS) | **code, small**: `cai-clash` with the opener restricted to J (a style key, e.g. `:hx-clash-j` replacing `clash-opener`'s NS answer for Hisagi), then the AS on the cancel (J1 → SP is AS1 by press 1: the generic AS roll `:as`-side, forced in this rule). `:clash-p` exists (KNOBS §6) but throws the NS too | per cancel he takes part in: share as the J side ≥ 0.70 and AS1 started within 20 f of the cancel in ≥ 0.80 of those (sheet: X-a TSUMUJI wins 16 of 16 J-side cells; X-b: SA / NS2b as the NS side lose 8 of 8 to his AS +2) |
| S3 | **鏈尖 (the chain tip)**, keep `range`, sharpened | the ranged mode keeps him at the tips: TABA from 4.0-4.9 m (its tip, x1.71 unscaled: 61, route NS2a SA-g J2s AS2ab 308), J1 from 5.5-6.4 m (23; J1-J5 AS3abc 233 → the bind); WA (0-3.4 m, 360°) for anything inside, including a Hoho behind him and his Shikai lunge | G1 form 1 x `:m-mid` / `:m-far`; G2 his attacking x `:m-close` (WA); G9 the switch (WA gap → TABA) | R (Hr), T (TABA H 3.5-5.5; WA beats the lunge 1.5-5.5), A (WA +6 on a Hoho-in), C (308, 233) | today's `hisagi-range-style` (`:hr-*`, passes its proof) + **code**: `*hr-taba-band*` (2.5 2.9) is a list, not a key; the sheet puts TABA's start at 4.0-4.9 (its tip), not 2.5-2.9 (where a J cancels it): make the band a key and start TABA from neutral there | kept descriptor (mean distance ≥ +0.5 m and ranged share ≥ +0.10, `arms4/hisagi.md` §5) + TABA starts at 4.0-4.9 m ≥ 0.5 of TABA starts |
| S4 | **縛りで追い上げ (bind to catch up)** | behind in Reishi, enter the bind (ranged J1-J5 > AS3abc from the J tip, 233) and seek cancels there (J1 into his NS; J vs J ties): each cancel moves 25 % of the gap; ahead, never enter, and leave a bind with AS3 (271) | G0 behind x my awakened; G7 my low x his high; G1 form 2 x `:m-close` | B (300 → 425 / 1300 → 1175 per cancel; none unbound), C (Hr J1-J5 AS3abc, Hd J1-J5 AS3abc release) | **code**: no rule enters the bind on purpose (AS3 after J5 is the press count's); a lead-gated choice of AS3 at J5 (and `:hr-home-p` 0 when behind), then S2's clash rule inside the bind | when behind by ≥ 300: bind steps ≥ 2 x arm 0's share and ≥ 1 BIND EVEN a match (log `BIND EVEN`); when ahead: bind entries ≤ arm 0's |
| S5 | `wake`, **keep** | Hisagi's own wake-up: punish what he whiffed into it (J1 / the pointer's NS), else a short guard, not the Hoho | G2 down (his own knockdown), as admitted | not in this catalogue (Hisagi as the victim); its NS reach grows with pointer 3 (NS3a 5.2 m) | `hisagi-hk-style` `:hk-wake` (passes: wake / kd x1.56 / x1.41) | as admitted |

`all` (arm 0) stays the fallback; with S1 in, arm 0 should stop being Kenpachi's brawler in the Shikai (see §4).

## 3. Targeted strategies

**vs Kenpachi**

| # | Name | Idea | Situations | Entries | Expressed by | Descriptor |
|---|---|---|---|---|---|---|
| K1 | **突進には J (J1 into the lunge)** | against his Shikai (and KYORAN): stand at 5.8-6.4 m (beyond the lunge's 5.7: only NAGI reaches); inside it, answer every lunge start with J1 → TSUMUJI (it cancels the lunge at 1.5-5.5 m, then wins against his SA); no NS of his own inside 5.7 m (the lunge beats them all) | G0 his awakened; G10 his pointer 1 x `:m-mid` / `:m-far`; G5 exchange | T Hb x Ks0 (lunge beats every NS, J1 cancels it everywhere), X-d (52 / 26), matchup-kenpachi §2 | S2's rule + S1's band set to 5.8-6.4 when his form is the Shikai | vs his Shikai: J1 starts during his NS1a startup at 2.5-5.7 m ≥ 2 x arm 0's per match, and Hisagi NS starts inside 5.7 m ≤ 0.5 x arm 0's |
| K2 | (replaces `hoho6`) **封印の外 (out of the sealed reach)** | sealed: keep 3.4-5.2 m, where nothing of his reaches; his run-in is NAGI's at ≤ 6 f; his NS1a whiff (it slides him to 2.2-2.5 m) is NS3a's at +10, not NAGI's | G0 his not awakened; G1 form 0 x `:m-mid`; G2 his attacking x `:m-close` (his slide) | T Hb x Kz, A, W | S1 with Kenpachi's sealed reach (3.3 m) as the floor | S1's descriptor on the sealed segments of the match |

**vs Ichigo**

| # | Name | Idea | Situations | Entries | Expressed by | Descriptor |
|---|---|---|---|---|---|---|
| I1 | **突きと月牙 (the rush and the wave)** | his NS3a rush (to 5.0 m, S18): NS2a (S16) or J1 > TSUMUJI, not NAGI (it loses to the rush to 4.5 m); his Getsuga charge (NS2a > b > c, wave on f56): NAGI in the first 20 f at 4-6 m, else Hoho late (+50 / +60) through the wave, never a back Step; from 6.5 m out walk in to 6 m rather than wait | G10 his pointer 2 x `:m-mid` / `:m-far`, his pointer 3 x `:m-mid`; G2 his attacking x `:m-mid` | T Hb x Ib (NS2a beats NS3a 1.5-5.5), X-d (TSUMUJI vs the rush), G (wave answers) | **code**: a pointer-read rule (his `fighter-ptr` is perceived through SNAP) in the S1 code; `ihx` stays for its own job | vs Ichigo: share of his Getsuga charges answered (NAGI hit or wave Hoho'd / cancelled) ≥ 0.6 (arm 0 measured first); NAGI starts while his NS3a startup is live ≤ 0.2 of them |
| — | `ihx`, **keep** | press into his shut-Hoho window when his Reishi is low (`hisagi-ihr1b2a0-style`) | G7 my high x his low | (passed: nstart x1.43) | as admitted | as admitted |

## 4. Today's arms: keep, replace or merge

| Arm | Verdict | Reason (sheet / catalogue) |
|---|---|---|
| `all` (arm 0) | **keep as the fallback, change its Shikai** | it is Kenpachi's brawler in the Shikai: 70 % of free steps inside 3 m vs Kenpachi, NAGI into its dead zone 224 times in 40 matches (probe.md). With S1 the fallback should at least never press NAGI inside 3.0 m (`kk-reach-of` ignoring `:min-reach` is a defect for any kit with a dead zone) |
| `range` | **keep, sharpen (S3)** | the only arm doing the kit's job (+0.8-0.9 m, ranged share up; 33 / 40 K.O. vs Ichigo here); TABA's band is the one change the sheet asks for |
| `wake` | **keep (S5)** | its job (Hisagi's wake-up) is real and separate; passes |
| `hoho6` (vs K) | **replace by K1 / K2** | a Hoho lands 1.6 m behind him: inside his J reach (2.6 / 3.4 m) and NAGI's dead zone, where no Shikai move hits (A trials from his side: a Hoho-in at 4.5 m leaves the defender with nothing but a J at +12 or a back Step). It passed its descriptor but moved no score (.488-.502) |
| `ihx` (vs I) | **keep** | a Reishi-read job no other arm has; passes |
| `press` (failed) | **drop: the kit contradicts it** | inside 2.6 m sealed Kenpachi is 5 f faster with the J and 2-4 f with the NS (T: Hisagi wins no cell but J1-into-NS); his Shikai's J reaches 3.4 m. Arm 0 already lives there |
| `kite` (failed vs K by 0.02 m) | **merge into S1** | its back Step + poke is S1's retreat half; alone it has no band to hold (the poke from 2.9-6.0 includes the dead zone) |

## 5. What the kit does not support (no separation in the data)

- **A close-range Shikai brawl against Kenpachi** (`press`): every 0-2.6 m cell is his but J1-into-NS (§1, T).
- **Zoning beyond 6.4 m**: no Shikai move reaches past 6.4 m (the ranged J1 6.4 m too); waiting there only gives Ichigo his wave and
  Kenpachi his choice of entry.
- **A Hoho-in offense**: the Hoho lands 1.6 m behind him, inside NAGI's dead zone and his J reach.
- **NAGI as an anti-lunge**: the lunges (S14-S16) are faster and reach into its band; only J1 > TSUMUJI answers them.
- **Picking NS1 vs NS3 by distance at will**: the pointer comes from the last AS's press count (AS1 → NAGI, AS3 → NS3a) or the switch (G9:
  the awakening gauge full once, SP paid). S1 can steer it only by how it ends routes (J1 AS1 writes 1, J1-J5 AS3abc writes 3).
- **The mirror** (HH stalls): every same-move pair cancels at 1.5-4.5 m (T Hb x Hh diagonal: J1 / J1, NS1a / NS1a, NS2a / NS2a, NS3a /
  NS3a), and with three general arms both seats sit in arm 0's brawl. The data supports a distance rock-paper-scissors (≤ 3.5 m NS2a beats
  NS3a; 4.5 m NS3a beats NAGI; 5.5 m NAGI beats all), so an HH arm would be "off the diagonal": the move that beats the mirror's at that
  distance. Not proposed as a fourth general arm: S1 / S2 already change the mirror's picks; measure HH after them.

## 6. For the user's pick (only you can judge the feel)

1. S1 (the chain's band) and S2 (J-side cancels) need a small style rule each; S3 / S4 a key and a lead-gated AS3. Which to build first?
   (Recommended: S1 + S2, both general, both what the sheet says he wins with.)
2. Should arm 0's Shikai stop being Kenpachi's brawler (the `kk-reach-of` dead-zone fix at least), or stay as the "brawl" baseline?
3. `hoho6` out, K1 / K2 in?

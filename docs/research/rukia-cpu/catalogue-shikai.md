# Rukia's Shikai: the catalogue (step 2, sim-verified; 2026-10-25)

`python3 tools/combo-trial.py docs/research/rukia-cpu/trials-shikai.lisp` (main after DUEL_RUKIA_TYBW §17.2): each trial
played in the native sim, P1 Rukia's Shikai pressing only its script against Kenpachi standing (or holding a guard), 2
Reiatsu bars, full flash step. Columns: **dmg** dealt (after scaling); **gaps** per hit after the first, the frames he could
act before it (0 = a true combo); **adv** after the last hit or block (his first free frame − hers; a knockdown counts his
wake-up); **dist** at the end; Reiatsu / flash step change; his layers / chill at the end; the hits (base damage).

## Findings

**Hit-confirmed combos (every gap 0)**
| Route | Cost | dmg | ends | notes |
|---|---|---|---|---|
| K1 K2 K3 ORANGE K1 K2 K3 | 70 FS (the burst) | **416** | +1, 3.35 m | the scaling restarts at the burst; +77 Reiatsu |
| K1 K2 K3 SP2 (3 layers) | 1 bar | **393** | −2, 4.5 m | SHIRAFUNE 110 + 25 × 3, unscaled; layers spent |
| I K1 K2 K3 | — | 345 | +1, 3.35 m | the Breaker opens a K string (150 + the string) |
| K1 K2 K3 +L 白漣 (3) | — | **331** | knockdown (+50 with his wake-up), 4.35 m | no bar; 1 layer: 302; the K string itself makes 1 layer, so +L is always on |
| K1 K2 SP2 (2) | 1 bar | 309 | −2, 2.8 m | |
| K1 K2 K3 SP1 | 1 bar | 298 | 0, 6.35 m | SOKATSUI's knockback ends far |
| J1 J2 J3 SP2 (3) | 1 bar | 295 | −2, 3.85 m | |
| K1 K2 K3 O | — | 268 | +3, 3.3 m | O as the ender |
| J1 J2 J3 ORANGE J1 J2 J3 | 70 FS | 220 | +5, 2.54 m | |
| K1 K2 K3 | — | 208 | **+1**, 3.35 m | 1 layer + 1 chill on him |
| K1 K2 +L 氷柱 (3) | — | 204 | −4, **6.0 m** | pushes him to 6 m |
| J1 J2 J3 +L 霜陣 (3) | — | 178 | −7, 2.54 m | the circle round him (3 layers again by its ticks) |
| J1 K2s K3 / J1 J2 K3 | — | 176 / 152 | +1, 3.35 m | |
| J1 J2 J3 O | — | 170 | +3, 3.3 m | |
| K1 K2 J3 / K1 J2s J3 | — | 166 / 142 | **+5**, 2.54 m | the J3 ender leaves her closest and most plus |
| K1 +L 氷礫 (3) | — | 126 | **+4**, 3.35 m | the one burst that leaves her plus |
| J1 SP1 / J1 SP2 | 1 bar | 124 / 144 | 0 / −2 | |
| J1 J2 J3 | — | 110 | +5, 2.54 m | |
| J1 +L 霜散 (3) | — | 74 | −7, 3.29 m (the hop) | escape tool, not damage |

**Not combos (gaps > 0)**: RIKUJOKORO → Step in → K1 K2 K3 (17 f free before K1), → walk in (83 f); 霜散 → BYAKURAI (20 f);
氷柱 → TSUKISHIRO (52 f, the ring before the pillar: only on a standing target); 霜陣 → J1 (54 f).

**RIKUJOKORO → O** (tap or held, 4–5.9 m): the bind, O, and the seal makes him red: the Kikon follow-up lands (−2 Konpaku)
from full health. The one Kikon setup off neutral.

**Neutral means (one hit)**
| Means | Range | dmg | adv on hit | on block | cost |
|---|---|---|---|---|---|
| BYAKURAI (L tap) | 0.5–6.15 m line | 45 | −13 | 0 (pushed to 5.6 m) | — |
| TSUKISHIRO (L hold) | ≤ 8 m ring | 60 + 2 layers | **+24** | — (a hazard) | — |
| SOKATSUI (SP1 tap) | 5 m cone | 90 | 0, he is knocked to 6–8 m | — | 1 bar |
| RIKUJOKORO (SP1 hold) | ≤ 6 m | 20, bound | +26 (tap) / +74 (held) | **binds through a guard** (+26) | 1 bar |
| SHIRAFUNE (SP2) | ≤ 5.3 m line | 110 + 25 a layer | −2 | −14 | 1 bar |
| O (ENBU) | ~8 m rush | 70 | +3 | — | — |
| I (Breaker) | 1.35 m | 150 | +4 | Guard Break | — |

**Against a guard**: J1 −4, K1 −6; J1 J2 J3 blocked: J3 whiffs (pushed out), −16; K1 K2 K3 blocked: **K2 whiffs** (the block
push), K3 blocked −26; SP2 −14. Her safe pressure is J1 (−4) and K1 (−6) alone; a blocked K string is punishable.

## All trials

| Trial | dmg | hits | combo | gaps | adv | dist | Reiatsu | FS | layers / chill | log |
|---|---|---|---|---|---|---|---|---|---|---|
| A1 J1 J2 J3 | 110 | 3 | 3 | 0 0 | 5 | 2.54 | +20 | +0 | 0 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-J3 HIT 42 |
| A2 J1 J2 K3 | 152 | 3 | 3 | 0 0 | 1 | 3.35 | +26 | +0 | 0 / 1 | RU-J1 HIT 34; RU-J2 HIT 34; RU-K3 HIT 84 |
| A3 J1 K2s K3 | 176 | 3 | 3 | 0 0 | 1 | 3.35 | +29 | +0 | 1 / 0 | RU-J1 HIT 34; RU-SK2S HIT 58; RU-K3 HIT 84 |
| A4 K1 K2 K3 | 208 | 3 | 3 | 0 0 | 1 | 3.35 | +33 | +0 | 1 / 1 | RU-K1 HIT 66; RU-SK2 HIT 58; RU-K3 HIT 84 |
| A5 K1 K2 J3 | 166 | 3 | 3 | 0 0 | 5 | 2.54 | +27 | +0 | 1 / 0 | RU-K1 HIT 66; RU-SK2 HIT 58; RU-J3 HIT 42 |
| A6 K1 J2s J3 | 142 | 3 | 3 | 0 0 | 5 | 2.54 | +25 | +0 | 0 / 1 | RU-K1 HIT 66; RU-J2S HIT 34; RU-J3 HIT 42 |
| B1 J1 +L 霜散 (3) | 74 | 2 | 2 | 0 | -7 | 3.29 | +17 | +0 | 2 / 0 | RU-J1 HIT 34; RU-SHIMOCHIRI HIT 40 |
| B2 J1 J2 +L 雪煙 (3) | 128 | 3 | 3 | 0 0 | -7 | 2.54 | +39 | +0 | 1 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-SETSUEN HIT 60 |
| B3 J1 J2 J3 +L 霜陣 (3) | 178 | 4 | 4 | 0 0 0 | -7 | 2.54 | +37 | +0 | 3 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-J3 HIT 42; RU-SOJIN HIT 80 |
| B4 K1 +L 氷礫 (3) | 126 | 2 | 2 | 0 | 4 | 3.35 | +22 | +0 | 2 / 0 | RU-K1 HIT 66; RU-HYOREKI HIT 60 |
| B5 K1 K2 +L 氷柱 (3) | 204 | 3 | 3 | 0 0 | -4 | 6.00 | +32 | +0 | 1 / 0 | RU-K1 HIT 66; RU-SK2 HIT 58; RU-TSURARA HIT 80 |
| B6 K1 K2 K3 +L 白漣 (3) | 331 | 4 | 4 | 0 0 0 | 50 | 4.35 | +48 | +0 | 0 / 0 | RU-K1 HIT 66; RU-SK2 HIT 58; RU-K3 HIT 84; RU-HAKUREN-K HIT 145 |
| B7 J1 K2s +L 氷柱 (3) | 172 | 3 | 3 | 0 0 | -4 | 6.00 | +29 | +0 | 1 / 0 | RU-J1 HIT 34; RU-SK2S HIT 58; RU-TSURARA HIT 80 |
| B8 K1 J2s +L 雪煙 (3) | 160 | 3 | 3 | 0 0 | -7 | 2.54 | +44 | +0 | 1 / 0 | RU-K1 HIT 66; RU-J2S HIT 34; RU-SETSUEN HIT 60 |
| B9 J1 J2 J3 +L 霜陣 (1) | 144 | 4 | 4 | 0 0 0 | -7 | 2.54 | +35 | +0 | 3 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-J3 HIT 42; RU-SOJIN HIT 40 |
| B10 K1 K2 K3 +L 白漣 (1) | 302 | 4 | 4 | 0 0 0 | 50 | 4.35 | +46 | +0 | 0 / 1 | RU-K1 HIT 66; RU-SK2 HIT 58; RU-K3 HIT 84; RU-HAKUREN-K HIT 110 |
| B11 K1 K2 K3 +L (0: refused) | 272 | 4 | 4 | 0 0 0 | 50 | 4.35 | +44 | +0 | 0 / 1 | RU-K1 HIT 66; RU-SK2 HIT 58; RU-K3 HIT 84; RU-HAKUREN-K HIT 75 |
| C1 J1 SP1 | 124 | 2 | 2 | 0 | 0 | 3.79 | -82 | +0 | 0 / 0 | RU-J1 HIT 34; RU-SOKATSUI HIT 90 |
| C2 J1 SP2 | 144 | 2 | 2 | 0 | -2 | 2.79 | -76 | +0 | 0 / 0 | RU-J1 HIT 34; RU-SHIRAFUNE-S HIT 110 |
| C3 J1 J2 J3 SP2 (3) | 295 | 4 | 4 | 0 0 0 | -2 | 3.85 | -60 | +0 | 0 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-J3 HIT 42; RU-SHIRAFUNE-S HIT 185 |
| C4 K1 K2 K3 SP2 (3) | 393 | 4 | 4 | 0 0 0 | -2 | 4.54 | -48 | +0 | 0 / 0 | RU-K1 HIT 66; RU-SK2 HIT 58; RU-K3 HIT 84; RU-SHIRAFUNE-S HIT 185 |
| C5 K1 K2 K3 SP1 | 298 | 4 | 4 | 0 0 0 | 0 | 6.35 | -60 | +0 | 1 / 1 | RU-K1 HIT 66; RU-SK2 HIT 58; RU-K3 HIT 84; RU-SOKATSUI HIT 90 |
| C6 J1 J2 J3 O | 170 | 4 | 4 | 0 0 0 | 3 | 3.29 | +31 | +0 | 1 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-J3 HIT 42; RU-KIKON HIT 70 |
| C7 K1 K2 K3 O | 268 | 4 | 4 | 0 0 0 | 3 | 3.29 | +44 | +0 | 2 / 1 | RU-K1 HIT 66; RU-SK2 HIT 58; RU-K3 HIT 84; RU-KIKON HIT 70 |
| C8 K1 K2 SP2 (2) | 309 | 3 | 3 | 0 0 | -2 | 2.79 | -58 | +0 | 0 / 0 | RU-K1 HIT 66; RU-SK2 HIT 58; RU-SHIRAFUNE-S HIT 185 |
| D1 K1 K2 K3 ORANGE K1 K2 K3 | 416 | 6 | 6 | 0 0 0 0 0 | 1 | 3.35 | +77 | -57 | 3 / 0 | RU-K1 HIT 66; RU-SK2 HIT 58; RU-K3 HIT 84; RU-K1 HIT 66; RU-SK2 HIT 58; RU-K3 HIT 84 |
| D2 J1 J2 J3 ORANGE J1 J2 J3 | 220 | 6 | 6 | 0 0 0 0 0 | 5 | 2.54 | +45 | -60 | 0 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-J3 HIT 42; RU-J1 HIT 34; RU-J2 HIT 34; RU-J3 HIT 42 |
| E1 BYAKURAI 3 m | 45 | 1 | 1 | — | -13 | 3.00 | +8 | +0 | 0 / 0 | RU-BYAKURAI HIT 45 |
| E2 BYAKURAI 6 m | 45 | 1 | 1 | — | -13 | 6.00 | +8 | +0 | 0 / 0 | RU-BYAKURAI HIT 45 |
| E3 TSUKISHIRO 6 m (hold) | 60 | 1 | 2 | — | 24 | 6.00 | +12 | +0 | 2 / 0 | FREEZE HIT 60 |
| E4 TSUKISHIRO 8 m (hold) | 60 | 1 | 2 | — | 24 | 8.00 | +12 | +0 | 2 / 0 | FREEZE HIT 60 |
| E5 SOKATSUI 3 m | 90 | 1 | 1 | — | 0 | 6.00 | -87 | +0 | 0 / 0 | RU-SOKATSUI HIT 90 |
| E6 SOKATSUI 5 m | 90 | 1 | 1 | — | 0 | 8.00 | -87 | +0 | 0 / 0 | RU-SOKATSUI HIT 90 |
| E7 RIKUJOKORO 4 m (short hold) | 20 | 1 | 2 | — | 26 | 4.00 | -91 | +0 | 0 / 0 | FREEZE HIT 20 |
| E8 RIKUJOKORO 5.9 m (held) O | 0 | 2 | 3 | 0 | 0 | 8.00 | +23 | +0 | 1 / 0 | FREEZE HIT 20; RU-KIKON HIT 70; RU-KIKON KIKON 70 |
| E9 RIKUJOKORO 4 m, Step in, K1 K2 K3 | 228 | 4 | 3 | 17 0 0 | 1 | 3.35 | -59 | +0 | 1 / 1 | FREEZE HIT 20; RU-K1 HIT 66; RU-SK2 HIT 58; RU-K3 HIT 84 |
| E9b RIKUJOKORO 4 m, walk in, K1 K2 K3 +L | 292 | 5 | 4 | 83 0 0 0 | ? | 4.35 | -49 | +0 | 0 / 1 | FREEZE HIT 20; RU-K1 HIT 66; RU-SK2 HIT 58; RU-K3 HIT 84; RU-HAKUREN-K HIT 75 |
| E9c RIKUJOKORO 4 m, O (red by the seal: Kikon) | 0 | 2 | 3 | 0 | 0 | 8.00 | +23 | +0 | 0 / 0 | FREEZE HIT 20; RU-KIKON HIT 70; RU-KIKON KIKON 70 |
| E10 SP2 4 m (0) | 110 | 1 | 1 | — | -2 | 5.06 | -81 | +0 | 0 / 0 | RU-SHIRAFUNE-S HIT 110 |
| E11 SP2 4 m (3) | 185 | 1 | 1 | — | -2 | 5.06 | -75 | +0 | 0 / 0 | RU-SHIRAFUNE-S HIT 185 |
| E12 O 6 m | 70 | 1 | 1 | — | 3 | 4.10 | +17 | +0 | 1 / 0 | RU-KIKON HIT 70 |
| E13 I (Breaker) 1.2 m | 150 | 1 | 1 | — | 4 | 1.35 | +18 | +0 | 0 / 0 | RU-BREAKER HIT 150 |
| E14 I K1 K2 K3 | 345 | 4 | 4 | 0 0 0 | 1 | 3.35 | +46 | +0 | 1 / 1 | RU-BREAKER HIT 150; RU-K1 HIT 66; RU-SK2 HIT 58; RU-K3 HIT 84 |
| F1 J1 +L 霜散 then BYAKURAI (3) | 119 | 3 | 2 | 0 20 | -13 | 3.29 | +23 | +0 | 2 / 0 | RU-J1 HIT 34; RU-SHIMOCHIRI HIT 40; RU-BYAKURAI HIT 45 |
| F2 K1 K2 +L 氷柱 then TSUKISHIRO (3) | 264 | 4 | 3 | 0 0 52 | 24 | 6.00 | +41 | +0 | 3 / 0 | RU-K1 HIT 66; RU-SK2 HIT 58; RU-TSURARA HIT 80; FREEZE HIT 60 |
| F3 J1 J2 J3 +L 霜陣 then J1 J2 J3 (3) | 212 | 5 | 4 | 0 0 0 54 | 3 | 0.79 | +42 | +0 | 3 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-J3 HIT 42; RU-SOJIN HIT 80; RU-J1 HIT 34 |
| G1 J1 J2 J3 / guard | 0 | 0 | 0 | — | -16 | 2.29 | +9 | +0 | 0 / 0 | RU-J1 BLOCKED 34; RU-J2 BLOCKED 34 |
| G2 K1 K2 K3 / guard | 0 | 0 | 0 | — | -26 | 3.70 | +14 | +0 | 0 / 0 | RU-K1 BLOCKED 66; RU-K3 BLOCKED 84 |
| G3 J1 / guard | 0 | 0 | 0 | — | -4 | 1.69 | +5 | +0 | 0 / 0 | RU-J1 BLOCKED 34 |
| G4 K1 / guard | 0 | 0 | 0 | — | -6 | 3.10 | +8 | +0 | 0 / 0 | RU-K1 BLOCKED 66 |
| G5 BYAKURAI 5 m / guard | 0 | 0 | 0 | — | 0 | 5.60 | +5 | +0 | 0 / 0 | RU-BYAKURAI BLOCKED 45 |
| G6 RIKUJOKORO 4 m / guard | 20 | 1 | 2 | — | 26 | 4.00 | -91 | +0 | 0 / 0 | FREEZE HIT 20 |
| G7 SP2 4 m / guard | 0 | 0 | 0 | — | -14 | 3.66 | -90 | +0 | 0 / 0 | RU-SHIRAFUNE-S BLOCKED 110 |
| G8 I 1.2 m / guard | 0 | 0 | 0 | — | ? | 1.85 | +6 | +0 | 0 / 0 | RU-BREAKER GUARD-BREAK 150 |

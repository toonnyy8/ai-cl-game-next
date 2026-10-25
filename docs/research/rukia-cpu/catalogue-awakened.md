# Rukia's awakened bands: the catalogue (sim-verified; 2026-10-25)

`python3 tools/combo-trial.py docs/research/rukia-cpu/trials-{m18,m50,zero}.lisp`: each band forced, her cold set (−18 60,
−50 150, −273 200), 2 Reiatsu bars, Kenpachi a standing or guarding dummy. Columns as `catalogue-shikai.md` (damage after the
band's ×1.1 / ×1.25 / ×1.65 and the scaling; gaps 0 = a true combo). The bands keep their rules (DUEL_RUKIA_TYBW §2): no
layers; K → L is the band's own L.

## Findings
- **Every route combos** in every band (gaps 0); the K string ends +1 (3.65–4.58 m), the J3 enders +5.
- **K string + L** (the band's own L, free): −18 285 (+4), −50 **349 (+18: HYŌSHIN's crumple)**, −273 **512** (−8).
- **K string + SP2** (2 bars in a band): −18 350, −50 415, −273 **575 (+8)**; **+ SP1 held** (HAKUREN's wave): −18 306, −50
  388, −273 **608**.
- **ORANGE restarts**: −18 458, −50 518, −273 603 — at −273 the K links spend cold (K 40), she warms to −50 mid-combo (the
  second K string is −50's).
- **I K1 K2 K3**: −18 381, −50 431 (no Breaker at −273).
- **Neutral**: −18's L SHIMOBASHIRA only round her (r 2.5: 2 m hits, 66, +4; 3 m misses); −50's HYŌSHIN r 3.5 (3 m: 106, +18;
  blocked −8); −273's REIDO r 5.5 (3–5 m: 198, +19; blocked −12). SP1 held to the end: −18 143 at 8 m (+32), −50 186
  (+38), −273 264 (+33). SP2 at 4–6.5 m: 121 / 156 / 231 (−2 / −2 / **+8** at −273). O (HAKKA): 77 / 88 / 116, −3.
- **Against a guard**: J1 −4, K1 −6 in every band; −18 / −50's K string blocked ends −6 (all three links connect, unlike
  the Shikai's), −273's −20 (K2 / K3 pushed out); SP2 −14.

## All trials

### −18
| Trial | dmg | hits | combo | gaps | adv | dist | Reiatsu | FS | layers / chill | log |
|---|---|---|---|---|---|---|---|---|---|---|
| A1 J1 J2 J3 | 120 | 3 | 3 | 0 0 | 5 | 2.54 | +22 | +0 | 0 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-J3 HIT 42 |
| A2 J1 J2 K3 | 166 | 3 | 3 | 0 0 | 1 | 3.65 | +27 | +0 | 0 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-A-K3 HIT 84 |
| A3 J1 K2s K3 | 193 | 3 | 3 | 0 0 | 1 | 3.65 | +30 | +0 | 0 / 0 | RU-J1 HIT 34; RU-K2S HIT 58; RU-A-K3 HIT 84 |
| A4 K1 K2 K3 | 229 | 3 | 3 | 0 0 | 1 | 3.65 | +35 | +0 | 0 / 0 | RU-A-K1 HIT 66; RU-K2 HIT 58; RU-A-K3 HIT 84 |
| A5 K1 K2 J3 | 183 | 3 | 3 | 0 0 | 5 | 2.54 | +30 | +0 | 0 / 0 | RU-A-K1 HIT 66; RU-K2 HIT 58; RU-J3 HIT 42 |
| A6 K1 J2s J3 | 156 | 3 | 3 | 0 0 | 5 | 2.54 | +27 | +0 | 0 / 0 | RU-A-K1 HIT 66; RU-J2S HIT 34; RU-J3 HIT 42 |
| B1 K1 +L | 139 | 2 | 2 | 0 | 4 | 1.79 | +21 | +0 | 0 / 0 | RU-A-K1 HIT 66; FREEZE HIT 60 |
| B2 K1 K2 +L | 203 | 3 | 3 | 0 0 | 4 | 1.79 | +30 | +0 | 0 / 0 | RU-A-K1 HIT 66; RU-K2 HIT 58; FREEZE HIT 60 |
| B3 K1 K2 K3 +L | 285 | 4 | 4 | 0 0 0 | 4 | 1.95 | +40 | +0 | 0 / 0 | RU-A-K1 HIT 66; RU-K2 HIT 58; RU-A-K3 HIT 84; FREEZE HIT 60 |
| C1 K1 K2 K3 SP2 | 350 | 4 | 4 | 0 0 0 | -2 | 4.78 | -150 | +0 | 0 / 0 | RU-A-K1 HIT 66; RU-K2 HIT 58; RU-A-K3 HIT 84; RU-SHIRAFUNE HIT 110 |
| C2 K1 K2 K3 SP1 (held 30) | 306 | 4 | 4 | 0 0 0 | -7 | 0.95 | -57 | +0 | 0 / 0 | RU-A-K1 HIT 66; RU-K2 HIT 58; RU-A-K3 HIT 84; WAVE HIT 70 |
| C3 J1 J2 J3 O | 197 | 4 | 3 | 0 0 3 | -3 | 2.79 | +34 | +0 | 0 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-J3 HIT 42; RU-HAKKA-18 HIT 70 |
| C4 K1 K2 K3 O | 294 | 4 | 4 | 0 0 0 | -3 | 3.52 | +46 | +0 | 0 / 0 | RU-A-K1 HIT 66; RU-K2 HIT 58; RU-A-K3 HIT 84; RU-HAKKA-18 HIT 70 |
| C5 J1 SP2 | 158 | 2 | 2 | 0 | -2 | 2.79 | -174 | +0 | 0 / 0 | RU-J1 HIT 34; RU-SHIRAFUNE HIT 110 |
| D1 K1 K2 K3 ORANGE K1 K2 K3 | 458 | 6 | 6 | 0 0 0 0 0 | 1 | 3.65 | +81 | -57 | 0 / 0 | RU-A-K1 HIT 66; RU-K2 HIT 58; RU-A-K3 HIT 84; RU-A-K1 HIT 66; RU-K2 HIT 58; RU-A-K3 HIT 84 |
| E1 L 3 m | 0 | 0 | 0 | — | ? | 3.00 | +6 | +0 | 0 / 0 |  |
| E2 L 5 m | 0 | 0 | 0 | — | ? | 5.00 | +6 | +0 | 0 / 0 |  |
| E2b L 2 m (SHIMOBASHIRA, r 2.5 round her) | 66 | 1 | 1 | — | 4 | 3.00 | +11 | +0 | 0 / 0 | FREEZE HIT 60 |
| G5b L 2 m / guard | 0 | 0 | 0 | — | -8 | 2.60 | +6 | +0 | 0 / 0 | FREEZE BLOCKED 60 |
| E3 SP1 tap 4 m | 77 | 1 | 2 | — | 9 | 4.00 | -87 | +0 | 0 / 0 | WAVE HIT 70 |
| E4 SP1 held 64 at 8 m | 143 | 1 | 2 | — | 32 | 8.00 | -79 | +0 | 0 / 0 | WAVE HIT 130 |
| E5 SP2 4 m | 121 | 1 | 1 | — | -2 | 5.06 | -180 | +0 | 0 / 0 | RU-SHIRAFUNE HIT 110 |
| E6 SP2 6.5 m | 121 | 1 | 1 | — | -2 | 7.56 | -180 | +0 | 0 / 0 | RU-SHIRAFUNE HIT 110 |
| E7 O 6 m | 77 | 1 | 1 | — | -3 | 8.00 | +17 | +0 | 0 / 0 | RU-HAKKA-18 HIT 70 |
| E8 I 1.2 m | 165 | 1 | 1 | — | 4 | 1.35 | +19 | +0 | 0 / 0 | RU-BREAKER HIT 150 |
| E9 I K1 K2 K3 | 381 | 4 | 4 | 0 0 0 | 1 | 3.65 | +49 | +0 | 0 / 0 | RU-BREAKER HIT 150; RU-A-K1 HIT 66; RU-K2 HIT 58; RU-A-K3 HIT 84 |
| G1 J1 J2 J3 / guard | 0 | 0 | 0 | — | -33 | 2.29 | +9 | +0 | 0 / 0 | RU-J1 BLOCKED 34; RU-J2 BLOCKED 34 |
| G2 K1 K2 K3 / guard | 0 | 0 | 0 | — | -6 | 3.45 | +17 | +0 | 0 / 0 | RU-A-K1 BLOCKED 66; RU-K2 BLOCKED 58; RU-A-K3 BLOCKED 84 |
| G3 J1 / guard | 0 | 0 | 0 | — | -4 | 1.69 | +5 | +0 | 0 / 0 | RU-J1 BLOCKED 34 |
| G4 K1 / guard | 0 | 0 | 0 | — | -6 | 2.25 | +8 | +0 | 0 / 0 | RU-A-K1 BLOCKED 66 |
| G5 L 3 m / guard | 0 | 0 | 0 | — | ? | 3.00 | +6 | +0 | 0 / 0 |  |
| G6 SP2 4 m / guard | 0 | 0 | 0 | — | -14 | 3.66 | -190 | +0 | 0 / 0 | RU-SHIRAFUNE BLOCKED 110 |

### −50
| Trial | dmg | hits | combo | gaps | adv | dist | Reiatsu | FS | layers / chill | log |
|---|---|---|---|---|---|---|---|---|---|---|
| A1 J1 J2 J3 | 136 | 3 | 3 | 0 0 | 5 | 2.68 | +23 | +0 | 0 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-J3-50 HIT 42 |
| A2 J1 J2 K3 | 189 | 3 | 3 | 0 0 | 1 | 3.85 | +29 | +0 | 0 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-A-K3-50 HIT 84 |
| A3 J1 K2s K3 | 219 | 3 | 3 | 0 0 | 1 | 3.85 | +33 | +0 | 0 / 0 | RU-J1 HIT 34; RU-K2S HIT 58; RU-A-K3-50 HIT 84 |
| A4 K1 K2 K3 | 259 | 3 | 3 | 0 0 | 1 | 3.85 | +38 | +0 | 0 / 0 | RU-A-K1-50 HIT 66; RU-K2 HIT 58; RU-A-K3-50 HIT 84 |
| A5 K1 K2 J3 | 206 | 3 | 3 | 0 0 | 5 | 2.68 | +32 | +0 | 0 / 0 | RU-A-K1-50 HIT 66; RU-K2 HIT 58; RU-J3-50 HIT 42 |
| A6 K1 J2s J3 | 176 | 3 | 3 | 0 0 | 5 | 2.68 | +28 | +0 | 0 / 0 | RU-A-K1-50 HIT 66; RU-J2S HIT 34; RU-J3-50 HIT 42 |
| B1 K1 +L | 188 | 2 | 2 | 0 | 18 | 1.79 | +25 | +0 | 0 / 0 | RU-A-K1-50 HIT 66; FREEZE HIT 85 |
| B2 K1 K2 +L | 260 | 3 | 3 | 0 0 | 18 | 1.79 | +34 | +0 | 0 / 0 | RU-A-K1-50 HIT 66; RU-K2 HIT 58; FREEZE HIT 85 |
| B3 K1 K2 K3 +L | 349 | 4 | 4 | 0 0 0 | 18 | 1.95 | +46 | +0 | 0 / 0 | RU-A-K1-50 HIT 66; RU-K2 HIT 58; RU-A-K3-50 HIT 84; FREEZE HIT 85 |
| C1 K1 K2 K3 SP2 | 415 | 4 | 4 | 0 0 0 | -2 | 4.98 | -145 | +0 | 0 / 0 | RU-A-K1-50 HIT 66; RU-K2 HIT 58; RU-A-K3-50 HIT 84; RU-SHIRAFUNE-50 HIT 125 |
| C2 K1 K2 K3 SP1 (held 30) | 388 | 4 | 4 | 0 0 0 | -7 | 0.95 | -50 | +0 | 0 / 0 | RU-A-K1-50 HIT 66; RU-K2 HIT 58; RU-A-K3-50 HIT 84; WAVE HIT 103 |
| C3 J1 J2 J3 O | 224 | 4 | 3 | 0 0 3 | -3 | 2.82 | +36 | +0 | 0 / 0 | RU-J1 HIT 34; RU-J2 HIT 34; RU-J3-50 HIT 42; RU-HAKKA HIT 70 |
| C4 K1 K2 K3 O | 333 | 4 | 4 | 0 0 0 | -3 | 3.45 | +49 | +0 | 0 / 0 | RU-A-K1-50 HIT 66; RU-K2 HIT 58; RU-A-K3-50 HIT 84; RU-HAKKA HIT 70 |
| C5 J1 SP2 | 198 | 2 | 2 | 0 | -2 | 2.79 | -171 | +0 | 0 / 0 | RU-J1 HIT 34; RU-SHIRAFUNE-50 HIT 125 |
| D1 K1 K2 K3 ORANGE K1 K2 K3 | 518 | 6 | 6 | 0 0 0 0 0 | 1 | 3.85 | +87 | -57 | 0 / 0 | RU-A-K1-50 HIT 66; RU-K2 HIT 58; RU-A-K3-50 HIT 84; RU-A-K1-50 HIT 66; RU-K2 HIT 58; RU-A-K3-50 HIT 84 |
| E1 L 3 m | 106 | 1 | 1 | — | 18 | 4.00 | +14 | +0 | 0 / 0 | FREEZE HIT 85 |
| E2 L 5 m | 0 | 0 | 0 | — | ? | 5.00 | +6 | +0 | 0 / 0 |  |
| E3 SP1 tap 4 m | 100 | 1 | 2 | — | 13 | 4.00 | -85 | +0 | 0 / 0 | WAVE HIT 80 |
| E4 SP1 held 64 at 8 m | 186 | 1 | 2 | — | 38 | 8.00 | -76 | +0 | 0 / 0 | WAVE HIT 149 |
| E5 SP2 4 m | 156 | 1 | 1 | — | -2 | 5.06 | -178 | +0 | 0 / 0 | RU-SHIRAFUNE-50 HIT 125 |
| E6 SP2 6.5 m | 156 | 1 | 1 | — | -2 | 7.56 | -178 | +0 | 0 / 0 | RU-SHIRAFUNE-50 HIT 125 |
| E7 O 6 m | 88 | 1 | 1 | — | -3 | 8.00 | +18 | +0 | 0 / 0 | RU-HAKKA HIT 70 |
| E8 I 1.2 m | 188 | 1 | 1 | — | 4 | 1.35 | +21 | +0 | 0 / 0 | RU-BREAKER HIT 150 |
| E9 I K1 K2 K3 | 431 | 4 | 4 | 0 0 0 | 1 | 3.85 | +53 | +0 | 0 / 0 | RU-BREAKER HIT 150; RU-A-K1-50 HIT 66; RU-K2 HIT 58; RU-A-K3-50 HIT 84 |
| G1 J1 J2 J3 / guard | 0 | 0 | 0 | — | -33 | 2.39 | +9 | +0 | 0 / 0 | RU-J1 BLOCKED 34; RU-J2 BLOCKED 34 |
| G2 K1 K2 K3 / guard | 0 | 0 | 0 | — | -6 | 3.65 | +17 | +0 | 0 / 0 | RU-A-K1-50 BLOCKED 66; RU-K2 BLOCKED 58; RU-A-K3-50 BLOCKED 84 |
| G3 J1 / guard | 0 | 0 | 0 | — | -4 | 1.79 | +5 | +0 | 0 / 0 | RU-J1 BLOCKED 34 |
| G4 K1 / guard | 0 | 0 | 0 | — | -6 | 2.45 | +8 | +0 | 0 / 0 | RU-A-K1-50 BLOCKED 66 |
| G5 L 3 m / guard | 0 | 0 | 0 | — | -8 | 3.60 | +6 | +0 | 0 / 0 | FREEZE BLOCKED 85 |
| G6 SP2 4 m / guard | 0 | 0 | 0 | — | -14 | 3.66 | -190 | +0 | 0 / 0 | RU-SHIRAFUNE-50 BLOCKED 125 |

### −273
| Trial | dmg | hits | combo | gaps | adv | dist | Reiatsu | FS | layers / chill | log |
|---|---|---|---|---|---|---|---|---|---|---|
| A1 J1 J2 J3 | 181 | 3 | 3 | 0 0 | 5 | 3.04 | +27 | +0 | 0 / 0 | RU-J1 HIT 34; RU-Z-J2 HIT 34; RU-J3 HIT 42 |
| A2 J1 J2 K3 | 251 | 3 | 3 | 0 0 | 1 | 4.58 | +34 | +0 | 0 / 0 | RU-J1 HIT 34; RU-Z-J2 HIT 34; RU-Z-K3 HIT 84 |
| A3 J1 K2s K3 | 291 | 3 | 3 | 0 0 | 1 | 4.58 | +38 | +0 | 0 / 0 | RU-J1 HIT 34; RU-K2S HIT 58; RU-Z-K3 HIT 84 |
| A4 K1 K2 K3 | 344 | 3 | 3 | 0 0 | 1 | 4.58 | +45 | +0 | 0 / 0 | RU-Z-K1 HIT 66; RU-K2 HIT 58; RU-Z-K3 HIT 84 |
| A5 K1 K2 J3 | 274 | 3 | 3 | 0 0 | 5 | 3.04 | +37 | +0 | 0 / 0 | RU-Z-K1 HIT 66; RU-K2 HIT 58; RU-J3 HIT 42 |
| A6 K1 J2s J3 | 234 | 3 | 3 | 0 0 | 5 | 3.04 | +33 | +0 | 0 / 0 | RU-Z-K1 HIT 66; RU-Z-J2S HIT 34; RU-J3 HIT 42 |
| B1 K1 +L | 307 | 2 | 2 | 0 | -8 | 0.79 | +35 | +0 | 0 / 0 | RU-Z-K1 HIT 66; FREEZE HIT 120 |
| B2 K1 K2 +L | 403 | 3 | 3 | 0 0 | -8 | 0.79 | +46 | +0 | 0 / 0 | RU-Z-K1 HIT 66; RU-K2 HIT 58; FREEZE HIT 120 |
| B3 K1 K2 K3 +L | 512 | 4 | 4 | 0 0 0 | -8 | 4.58 | +59 | +0 | 0 / 0 | RU-Z-K1 HIT 66; RU-K2 HIT 58; RU-Z-K3 HIT 84; FREEZE HIT 120 |
| C1 K1 K2 K3 SP2 | 575 | 4 | 4 | 0 0 0 | 8 | 6.58 | -132 | +0 | 0 / 0 | RU-Z-K1 HIT 66; RU-K2 HIT 58; RU-Z-K3 HIT 84; RU-SHIRAFUNE-0 HIT 140 |
| C2 K1 K2 K3 SP1 (held 30) | 608 | 4 | 4 | 0 0 0 | 2 | 4.58 | -33 | +0 | 0 / 0 | RU-Z-K1 HIT 66; RU-K2 HIT 58; RU-Z-K3 HIT 84; WAVE HIT 160 |
| C3 J1 J2 J3 O | 297 | 4 | 3 | 0 0 3 | -3 | 3.18 | +42 | +0 | 0 / 0 | RU-J1 HIT 34; RU-Z-J2 HIT 34; RU-J3 HIT 42; RU-HAKKA-0 HIT 70 |
| C4 K1 K2 K3 O | 442 | 4 | 4 | 0 0 0 | -3 | 3.38 | +58 | +0 | 0 / 0 | RU-Z-K1 HIT 66; RU-K2 HIT 58; RU-Z-K3 HIT 84; RU-HAKKA-0 HIT 70 |
| C5 J1 SP2 | 287 | 2 | 2 | 0 | 8 | 2.79 | -164 | +0 | 0 / 0 | RU-J1 HIT 34; RU-SHIRAFUNE-0 HIT 140 |
| D1 K1 K2 K3 ORANGE K1 K2 K3 | 603 | 6 | 6 | 0 0 0 0 0 | 1 | 3.85 | +94 | -57 | 0 / 0 | RU-Z-K1 HIT 66; RU-K2 HIT 58; RU-Z-K3 HIT 84; RU-A-K1-50 HIT 66; RU-K2 HIT 58; RU-A-K3-50 HIT 84 |
| E1 L 3 m | 198 | 1 | 2 | — | 19 | 3.00 | +21 | +0 | 0 / 0 | FREEZE HIT 120 |
| E2 L 5 m | 198 | 1 | 2 | — | 19 | 5.00 | +21 | +0 | 0 / 0 | FREEZE HIT 120 |
| E3 SP1 tap 4 m | 264 | 1 | 2 | — | 18 | 4.00 | -72 | +0 | 0 / 0 | WAVE HIT 160 |
| E4 SP1 held 64 at 8 m | 264 | 1 | 2 | — | 33 | 8.00 | -69 | +0 | 0 / 0 | WAVE HIT 160 |
| E5 SP2 4 m | 231 | 1 | 1 | — | 8 | 6.00 | -172 | +0 | 0 / 0 | RU-SHIRAFUNE-0 HIT 140 |
| E6 SP2 6.5 m | 231 | 1 | 1 | — | 8 | 8.50 | -172 | +0 | 0 / 0 | RU-SHIRAFUNE-0 HIT 140 |
| E7 O 6 m | 116 | 1 | 1 | — | -3 | 8.00 | +20 | +0 | 0 / 0 | RU-HAKKA-0 HIT 70 |
| G1 J1 J2 J3 / guard | 0 | 0 | 0 | — | -11 | 3.10 | +9 | +0 | 0 / 0 | RU-J1 BLOCKED 34; RU-J3 BLOCKED 42 |
| G2 K1 K2 K3 / guard | 0 | 0 | 0 | — | -20 | 4.00 | +11 | +0 | 0 / 0 | RU-Z-K1 BLOCKED 66 |
| G3 J1 / guard | 0 | 0 | 0 | — | -4 | 2.50 | +5 | +0 | 0 / 0 | RU-J1 BLOCKED 34 |
| G4 K1 / guard | 0 | 0 | 0 | — | -6 | 4.00 | +8 | +0 | 0 / 0 | RU-Z-K1 BLOCKED 66 |
| G5 L 3 m / guard | 0 | 0 | 0 | — | -12 | 3.60 | +6 | +0 | 0 / 0 | FREEZE BLOCKED 120 |
| G6 SP2 4 m / guard | 0 | 0 | 0 | — | -14 | 4.60 | -190 | +0 | 0 / 0 | RU-SHIRAFUNE-0 BLOCKED 140 |

# Rukia's Shikai: the strategy (step 3, a proposal for the user's pick; 2026-10-25)

From the catalogue (`catalogue-shikai.md`, sim-verified) and the data sheet (`sheet-shikai.md`). Situations → the means
that answer them; the styles are weightings of the same table. Numbers: damage after scaling, against Kenpachi.

## 1. Situations and means

| # | Situation | Means (catalogue) | Why |
|---|---|---|---|
| S1 | Far, > 6 m, both neutral | TSUKISHIRO (L hold, ≤ 8 m: 60, **+2 layers**, +24 on hit); O ENBU (8 m rush, 70, +3); close in | the ring is her only safe far hit and starts the layers |
| S2 | Mid, 3–6 m | BYAKURAI (L tap: 45, safe on block at 5.6 m); **RIKUJOKORO** (SP1 hold, 1 bar: binds through a guard) → **O: the Kikon from full health**; SOKATSUI (SP1 tap, 1 bar: 90, he lands 6–8 m away); SP2 at ≤ 5.3 m (110 + 25 a layer, −2) | the bind is her strongest single read; SOKATSUI resets a rushdown |
| S3 | Close, 1.5–3 m | K1 alone (−6 on block, 2.85 m); on a K1 hit the K string; J1 alone (−4) | a blocked K string is −26 (K2 whiffs): the K string only on a hit |
| S4 | Point blank, < 1.5 m | J1 J2 J3 (+5 at 2.54 m); I (Breaker) against a guard → K1 K2 K3 (**345**) | the Breaker beats a guard; the J ender leaves her plus and close |
| S5 | Her string hit (the confirm) | by resources: **layers ≥ 2 and a bar** → K3 SP2 (393; 3 layers); **no bar** → K3 +L 白漣 (331 at 3, 302 at 1: the K string makes its own layer, always on; a knockdown); **FS ≥ 70** → K3 ORANGE K1 K2 K3 (416); **he is red** → K3 O (the Kikon) | the cash-out by what she has |
| S6 | A J string hit | J3 O (170, +3) or J3 +L 霜陣 (178; the circle re-stacks 3 layers round him); 霜散 off J1 to leave (hop 2.5 m back) | J routes are short: an exit or a set-up, not the damage |
| S7 | He is down (白漣's knockdown, +50) | TSUKISHIRO on his wake-up (the ring is down before he rises) or walk to K1 range | the knockdown's oki |
| S8 | He presses (she is blocking) | guard, then J1 (7 f) on his unsafe recovery; Hoho through a slow move; BLUE when caught | her J1 is her fastest punish |
| S9 | He keeps away | TSUKISHIRO (+2 layers each), BYAKURAI; at 3 layers SP2 from 5 m (185) | she out-ranges a turtle with the ring |

Not to use: RIKUJOKORO → Step → K (17 f free); 氷柱 → TSUKISHIRO (52 f); a K string on block; 霜散 / 雪煙 for damage (−7).

## 2. Styles (weightings of §1; the user picks or mixes)

| | A 霜刃 close burst | B 鬼道 the binder | C 霜層 harvest |
|---|---|---|---|
| Range she seeks | 1.5–3 m | 3–6 m | 4–8 m, then in for the cash-out |
| Opening | K1 pokes, J1, the Breaker on a guard | BYAKURAI, RIKUJOKORO when he is still or guarding | TSUKISHIRO, BYAKURAI |
| Confirm | K string → ORANGE restart / SP2 / 白漣 | short (K1 K2 +L 氷柱 to push him back out) | K string → 白漣 or SP2 by layers |
| Bars spent on | SP2 enders | RIKUJOKORO → O (the Kikon), SOKATSUI | SP2 at 3 layers (185 alone, 393 off a string) |
| Flash step on | ORANGE (70) | Hoho away | kept for defense |
| Signature | the K string, ORANGE, 白漣 | the bind → Kikon, the kido | TSUKISHIRO, the layers, SP2 / 白漣 |
| Risk | blocked strings −26 | a dodged bind costs a bar | slow; loses to a rushdown at 5 m |

A mix (as Hisagi's): one style rolled per match (or per round), its weights tilting §1's choices; e.g. A 0.4, B 0.3, C 0.3.

## 3. How it maps to her CPU (step 4)

- `:ai :moves` bands by distance (S1–S4), `:intents` by style; the confirm (S5) in her `:l-after-k` / `:sp-ender` hooks
  (RUKIA-AI-BURST-P, RUKIA-AI-SP-ENDER) and a new ORANGE rule; S2's bind → O in `:sp1-hold` and a reflex; S7 / S8 in
  `:reflex`; the style roll at the match start (SIM-RND01, once).
- Every chance scaled by difficulty (EASY ≤ NORMAL ≤ HARD), one roll per event; then the frozen evaluator, her gates, the
  awaken A/B (§11.2's deferral ends here).

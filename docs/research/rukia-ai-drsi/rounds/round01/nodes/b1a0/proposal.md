# b1a0 (round 1): her resources and his state — the confirm, the cash and the envelope as value tables

Primary axis (the brief): her resources and his state (layers, bars, flash step, red, the cash-out after a confirmed hit).
History read: round 1 has no finished cell (b0a0 runs alongside), so the only history is BASELINE_DIR (proposal.md,
score.json 0.5898). Planning base read: `docs/research/rukia-cpu/` (sheet-shikai, matchups-shikai, strategy-shikai, both
catalogues), rukia.lisp, ai.lisp, kenpachi's CPU (ken.lisp) for the first-strike model.

## 1. Diagnosis (combat logs, tools/simgate/run-log.lisp, 4 seeds a pairing, the baseline file)

- **Signature leak**: 38 % of her damage was not hers: the counter of the perfect Hoho 0.119, the plain O 0.097 (the
  neutral ENBU rush in `:moves` 2.8–99 m, the O-cash after a perfect Hoho, the generic 15 % O ender: the base plist had
  no `:o-ender`), the plain J links 0.094 (`:string-k` 0.3: J1 J2 J3 70 % of the time), the Breaker 0.034, the bands' O
  0.04.
- **Strength**: Kenpachi's HARD CPU opens with his J1 FIRST-STRIKE (KEN-FIRST-STRIKE, 0.15 a step inside 4 m, timed to
  her closing): 44 of his openers in 4 matches against 1 neutral J1 of hers. Her J1 and his are both 7 f, faster than
  her 8 f perception: nothing she sees of the J1 answers it. Hisagi's loop (KAZA-J → K1 → K2 → J3K → KAZA-J, 600+ a
  touch), Lille's far snipe + stance strings: 0 of 80 each. HARD opponents perfect-Hoho her K / L / SP when they have
  the flash step (KEN-HOHO-COMMIT 0.75), and step out of RIKUJOKORO's / TSUKISHIRO's tell (~75 %) unless they are busy.

## 2. The mechanism (all in duel/lisp/rukia-ai.lisp; no other file)

Every table: options allowed now, each a **value** (damage from the moves' data / the catalogue, ± her resources),
**one pick per event by probability ∝ value^k** (`RUKIA-AI-PICK`, k = `*AI-RU-CONFIRM-SHARP*` EASY 1 / NORMAL 1 / HARD
3 — not the single best: k = 5 is nearly argmax), rolled with SIM-RND01 once per hit / decision / action of his.

### 2.1 The confirm table (a link of hers that hit, every form) — `RUKIA-AI-CONFIRM-PICK`
Wired through the hooks STRING-REFLEX already calls (no `:move-reflex`: a frozen Hisagi test reserves it): the L link's
chance (`RUKIA-AI-LINK-L`: 1.0 if the pick is the L, else 0.0), the SP ender (`RUKIA-AI-SP-ENDER` reads the same pick,
memoised for the step), `:string-k 1.0` (the K link when the pick is the route). Gate `*AI-RU-CONFIRM*` 0.2 / 0.5 / 0.95;
on a miss the shipped rules (`RUKIA-AI-BURST-P`, the bands' `*AI-RU-L-AFTER-K-AWAKE*`, the old sp-ender).

| Condition (link that hit) | Option | Value (damage-equivalent) |
|---|---|---|
| a K link follows (J1 → K2s, K1 → K2, K2 → K3; every form) | the K route | next K + the one after (combo-scaled) + `*AI-RU-ROUTE-ENDER*` 60; **he is red**: + `*AI-RU-RED-ROUTE*` 150 (the ender's O is the Kikon) |
| the link's L allowed (Shikai: RUKIA-OK, ≥ 1 霜の層; bands: cold) | the burst / the band's L | (dmg + per × burst-count(link, **his layers**)) × combo-scale + the fx (`*AI-RU-FX-VALUE*`: 白漣 knockdown 40, 霜陣 circle 40, 雪煙 Reiatsu 20, 氷柱 push 15, 氷礫 20, 霜散 0) |
| the ender (K3 / J3), **bars** ≥ the reserve | SHIRAFUNE | 110 + 25 × **his layers** (unscaled; the bands' 125 / 140) − `*AI-RU-BAR-COST*` (80 / 45 / 15 with 1 / 2 / 3 bars) |
| the ender, bars, inside RUKIA-AI-SP1-FAR | SOKATSUI tap / the bands' wave | its damage + 10 − the bar cost |
| any option reaching **his Reishi left** | | + `*AI-RU-FINISH*` 100 |

The plain J2 / J3 and the plain O ender are no longer options (`:o-ender 0.0` in every form; ai.lisp's red O ender — the
Kikon — still fires first). ORANGE's restart was an option and measured badly (§4: its 70 flash step costs the perfect
Hohos and BLUE): removed.

### 2.2 The cash table (his stun / recovery as seen) — `RUKIA-AI-CASH`
One roll `*AI-RU-PH-CASH*` per action of his, then a pick among what lands before he is free: SHIRAFUNE (110 + 25 a
layer − bar cost), the band's disc L (+20), **her J1 route** (J1 K2s K3 + ender = 236, a stun within J1's reach),
**her K1 route** (268, within K1's line), **RIKUJOKORO** when his frames left ≥ its hold + startup + 4 (38 f: he cannot
Step out; `*AI-RU-BIND-CASH*` 250 − bar cost: the seal's Kikon), the O last (40: not hers).

### 2.3 The seal — `RUKIA-AI-SEAL`
He is sealed by her RIKUJOKORO (`FIGHTER-SEAL`, the state her move put on him): O at once when it strikes before the seal
ends (`*AI-RU-SEAL-O*` 0.2 / 0.6 / 1.0) — the Kikon from full health, before any ice cash (the baseline cashed SP2 first,
throwing away the 2 Konpaku when it had the bars).

### 2.4 The envelope table (his state: closing into his first strike) — `RUKIA-AI-FRONT`
At a neutral decision with him free inside his J1 envelope (his kit's J1 reach + lunge ≤ 0.8 + 0.3 + his perceived
closing speed × (his J1 S + her delay)), `*AI-RU-FRONT*` 0 / 0.15 / 0.95, values `*AI-RU-FRONT-VALUES*`:

| Option | Value | Allowed |
|---|---|---|
| her J1 first | 50 | he will be inside her J1 reach + 0.3 at its hit |
| guard | 40 | always |
| the back hop (his J1 whiffs) | 25 | always |
| K1 | 60 | **his flash step < 30** (no perfect Hoho) and him in K1's window at its hit |
| SOKATSUI | 55 | his flash step < 30, her bars, inside RUKIA-AI-SP1-FAR |

### 2.5 The zone (the shipped one, retuned by his kit)
`*AI-RU-ZONE-KIDO*` HARD 0.3 → 0.6; RIKUJOKORO held from 3.5 m instead of 4.5 m **against a long poke** (his kit's K1 ≥
`*AI-RU-LONG-POKE*` 4 m: SOKATSUI's knockback would leave him at his own range; Hisagi). Neutral `:moves`: no ENBU (O),
no Breaker in the Shikai's / −18's bands (the guard-break reflex keeps the Breaker against a long guard).

Why it is not a repeat: there is no earlier cell; against the baseline the structure is new (value tables with a
weighted pick, his layers / red / Reishi / flash step / seal / closing as conditions, her bars as costs), the strategy
sheet's S5 (the cash-out by resources) implemented as data instead of fixed priorities.

## 3. Measurement (frozen evaluator, this worktree, `python3 tools/aieval.py --char 2 --seeds 40 -j 2`)

| | baseline | b1a0 |
|---|---|---|
| **score** | 0.5898 | **0.7506** |
| strength | 0.273 (131/480) | **0.410** (197/480) |
| masher | 1.0 | 1.0 |
| signature | 0.616 | **0.855** |
| NORMAL share (band 0.30–0.60) | 0.423 | 0.492 (×1) |
| pacing (NORMAL P1 medians, every match a K.O.) | 100.8–140.4 s | 101.9–146.7 s |

str_by_opp (HARD, both seats, of 80): Yamamoto 29 → 42, Kenpachi 0 → 0, Ichigo 58 → 78, Senjumaru 44 → 65, Lille 0 → 0,
Hisagi 0 → 12. NORMAL by_opp: Lille 43, Hisagi 38, Ichigo 38, Kenpachi 29, Senjumaru 45, Yamamoto 43 (of 80).
sig_by: kstring 0.403, poke 0.209, burst 0.195, counter 0.075, kido 0.040, O 0.023, Breaker 0.019, the bands' O 0.028,
seal 0.009, plain J 0.000 (baseline: burst 0.231, poke 0.227, kstring 0.126, counter 0.119, O 0.097, plain J 0.094).

**Paired, final vs baseline** (same seeds and seats, strength runs): block seeds 1–20 (240 HARD matches) 69 → 104, +0.146,
SE 0.029, z 5.05; block seeds 21–40 62 → 93, +0.129, SE 0.032, z 4.10 → stopped (|diff| > 2 SE in both blocks).

The search, each a paired 480-match strength run (2 blocks of 240) against its parent (wins of 480):

| step | wins | Δ vs parent | z | sig |
|---|---|---|---|---|
| v1 confirm table + no plain O / J + J1 cash (with ORANGE) | 116 | −15 vs base | −1.57 | 0.835 |
| no ORANGE | 136 | +20 vs v1 | +2.01 | 0.826 |
| ORANGE as a finisher only (rejected) | 128 | −8 | −1.79 | 0.828 |
| envelope table at decisions (HARD 0.7) | 153 | +17 | +1.66 | 0.835 |
| envelope on entry instead (rejected) | 130 | −23 | −2.15 | 0.821 |
| perfect Hoho down to 30 FS (rejected) | 152 | −1 | −0.26 | |
| zone kido 0.3 → 0.6 | 167 | +14 | +1.78 | 0.837 |
| zone kido 0.9 (rejected) | 151 | −16 | −2.15 | |
| RIKUJOKORO from 3.5 m always (rejected; Hisagi 0 → 9) | 160 | −7 | −0.85 | |
| a weighted zone table with TSUKISHIRO / BYAKURAI (rejected) | 150 | −17 | −1.69 | |
| a weighted zone of kido + SP2 only (rejected) | 153 | −14 | −1.40 | |
| RIKUJOKORO from 3.5 m vs a long poke | 176 | +9 | +3.03 | 0.835 |
| envelope HARD 0.95 | 186 | +10 | +1.00 | 0.837 |
| envelope guard-heavy / J1-heavy / no hop / hop 40 (rejected) | 153 / 180 / 174 / 166 | −33 / −6 / −12 / −20 | −3.25 / −0.63 / −1.40 / −2.34 | |
| the cash table | 181 | −5 | −0.48 | 0.847 |
| red rush at decisions / cheaper bars (rejected) | 176 / 180 | −5 / −1 | | |
| sharpness 2 → 3 | 194 | +13 | +1.40 | 0.851 |
| sharpness 5 (rejected: near argmax, +2) | 196 | +2 | +0.21 | 0.856 |
| no Breaker in the Shikai's :moves / also −18's | 199 / 199 | +5 / 0 | +1.09 | 0.854 |
| his BLUE readiness shortening the route (rejected, tie) | 198 | −1 | | |
| SP2 only at the ender (a fix: an SP2 pick at a link-1 / -2 hit fell through to the K link) | 197 | −2 | −0.34 | 0.855 |

(Many sequential picks: each step's z is optimistic; the final-vs-baseline blocks above are the honest number.)

**Awaken A/B** (I changed NORMAL's Shikai play: the confirm at 0.5, `:string-k` 1, `:o-ender` 0, the envelope 0.15, the
cash table, the moves; AI-AWAKEN-P and `:awaken` untouched): `python3 tools/simgate.py --pairs 3,4,5 --seed0 S --seeds 60
--cmd 39020 -j 2` (Rukia P1 :never) and `--pairs 8,12,23,30 ... --cmd 39002` (Rukia P2 :never); the never-awaken side's
wins of 60, baseline → b1a0 (both measured here, at the freeze):

| pairing | seed0 100 | seed0 300 | seed0 500 |
|---|---|---|---|
| RUKIA–YAMAMOTO (39020) | 23 → 16 | 24 → 17 | 21 → 12 |
| RUKIA–KENPACHI (39020) | 3 → 9 | 2 → 9 | 6 → 9 |
| RUKIA–RUKIA (39020) | 11 → 13 | 14 → 14 | 10 → 12 |
| ICHIGO–RUKIA (39002) | 2 → 5 | 5 → 13 | 9 → 6 |
| SENJUMARU–RUKIA (39002) | 9 → 18 | 12 → 16 | 12 → 19 |
| BARRO–RUKIA (39002) | 7 → 9 | 6 → 13 | 6 → 7 |
| HISAGI–RUKIA (39002) | 8 → 15 | 14 → 20 | 10 → 18 |
| sum of 420 | 63 → 85 | 77 → 102 | 74 → 83 |

Both fail the ≥ 20 rule on most rows (the baseline 3 rows pass, all Yamamoto's; b1a0 1, Hisagi at 300): the known open
item (DUEL_RUKIA_TYBW §11.2, 「等後續重建 AI」). Her never-awakening Shikai is stronger overall (214 → 270 of 1260), weaker
against Yamamoto.

## 4. Risks

- ORANGE is out of her CPU (a user theme, 「K 連段與橙色爆氣」): measured −20 HARD wins of 480 with it; only ORANGE hits
  scored through it. If the user wants it seen, a cheap variant (only at 100 FS with her Reishi high) is untested.
- Kenpachi and Lille stay 0 / 80: their openers and loops are faster than anything her kit-level hooks can answer (the
  burst roll in a combo and the held guard are ai.lisp's); a structural answer needs shared code (below).
- The envelope reads his perceived closing speed (two ring SNAPs) and his flash-step gauge (the HUD's, as ai.lisp reads
  his guard gauge); the seal reads FIGHTER-SEAL (her own move's state on him, as the baseline reads his layers).
- `*RU-AI-MEMO*`: a per-side value for one step (the L-link hook and the SP ender in the same STRING-REFLEX call), keyed
  by the tick, his combo hits and his Reishi; never read on another step. No state carries across matches.

## 5. Shared-code recommendations (not done)

- ai.lisp BRAIN-STEP: a kit hook in the Burst roll (`:burst-wanted`), so a character can BLUE out of a long loop
  (Hisagi's, Lille's) by his combo's pace rather than only by her Reishi; and a kit hook while holding guard (the
  `:hold` press runs no reflex: her J1 out of his blocked J at lunge range never fires; measured: 0 firings).
- tests/duel-rules/hisagi.lisp: the check that only Hisagi's forms carry `:move-reflex` blocks every other kit from
  that hook; allowing it per character would let the confirm table pick SP2 at any link (now only at the ender).

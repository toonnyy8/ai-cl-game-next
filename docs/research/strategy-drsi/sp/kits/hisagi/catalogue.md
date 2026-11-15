# Hisagi: the catalogue (PLAN4 step 2, sim-verified, 2026-11-15)

**2415 trials, every one played in the native sim** (`tools/simgate/trial.lisp`, main c15f9a55 + this branch's three trial keys
`:p1-bound`, `:p2-meter`, `:p1-reishi`). Two full runs gave byte-identical `results.json`. Reproduce:

    python3 docs/research/strategy-drsi/sp/kits/hisagi/gen.py        # writes trials.lisp
    python3 docs/research/strategy-drsi/sp/kits/hisagi/run.py -j 16  # results.json / results.md (every trial: both sides' damage, hits, cancels)
    python3 docs/research/strategy-drsi/sp/kits/hisagi/analyze.py    # tables.md (the grids below come from it)

P1 is Hisagi (Shikai `:base`, the Bankai's ranged mode `:bankai`, the bind `:bankai-bind`, started bound). P2: Kenpachi sealed (Kz), his
Shikai at L0 / L3 (Ks0 / Ks3), his Bankai KYORAN (Kb), Ichigo's Shikai (Ib), KESSA (Ik), Hisagi's Shikai (Hh, the mirror). P2 stands
unless a trial presses for him (`:p2-at` J / SP on a sim frame, `:p2-press` Step / Hoho / run / walk). Damage is after the forms' x and
the victim's taken x (Ichigo's Shikai takes x0.8). `tables.md` holds every grid; `results.md` every trial's log line.

Sections: **R** reach by distance (and his openers on Hisagi), **T** both press on the same frame (the triangle), **C** routes, **CF**
routes short of SP, **B** the bind's clash, **W** / **WH** whiff punishes both ways, **A** anti-approach (run-in, walk-in, Hoho-in),
**X** the exchange after a cancel, **G** Ichigo's Getsuga route, **K** wake-up, **H** the mirror.

## 1. Reach by distance (R, RE, RH, RHE: 0.5 m grid 1-7 m + 0.1 m edges)

| | 0-2.4 m | 2.4-3.0 | 3.0-3.8 | 3.8-5.2 | 5.2-6.4 | 6.4+ |
|---|---|---|---|---|---|---|
| **Hisagi Shikai** | J1 (2.4), NS2a, NS3a | NS2a (3.8), NS3a | NAGI (3.0-6.4), NS2a, NS3a | NAGI, NS3a (5.2) | **NAGI only** | nothing |
| **Hisagi ranged** | WA (0-3.4) | WA, TABA (2.5-4.9) | J1 (3.0-6.4), WA to 3.4, TABA | J1, TABA (tip 4.0-4.9) | J1 (tip 5.5-6.4) | nothing |
| **Hisagi bind** | J1 (2.2), NS2a, KAGIYOSE | NS2a (3.3), KAGIYOSE | KAGIYOSE | KAGIYOSE | KAGIYOSE (6.7) | |
| Kenpachi sealed | J1 (2.6), NS1a, NS2a | NS1a (3.3), NS2a (3.0) | NS1a to 3.3 | nothing | nothing | |
| Kenpachi Shikai (L0 = L3) | J1 (3.4), NS1a, NS2a (2.6) | J1, NS1a | J1 to 3.4, NS1a | **NS1a lunge (5.7)** | NS1a to 5.7 | |
| Kenpachi KYORAN | J1 (2.5), NS1a | NS1a | NS1a | NS1a (4.9) | | |
| Ichigo Shikai | J1 (2.3), NS1a (3.0), NS3a | NS1a, NS3a | NS3a | **NS3a rush (5.0)** | (NS2c JUJISHO wave, 12 m, after 56 f of charge) | |
| Ichigo KESSA | J1 (1.9), NS1a (3.3), NS3a clones (3.0) | NS1a, NS3a | NS1a to 3.3 | (AS1 7 m line, after a J hit) | (JUJISHO) | |

Damage of one opener on the dummy: Hisagi NAGI 51 (41 on Ichigo's Shikai), NS2a 37, NS3a 33, J1 25; ranged J1 14 / tip 23, TABA 36 /
tip 61, WA 19; bind J1 23 / close 30, KAGIYOSE 25. His: sealed Kenpachi J1 18, NS1a 33, NS2a 43; his Shikai J1 20, lunge 35; KYORAN 48;
Ichigo J1 17, NS1a 37, NS3a 38; KESSA J1 16, NS1a 31, NS3a 9.

**Hisagi's Shikai out-ranges both opponents' sealed / Shikai forms from 3.4 m out, with three moves (NAGI 3.0-6.4, NS3a to 5.2, NS2a to
3.8). Inside 2.6 m sealed Kenpachi out-ranges his J (2.6 vs 2.4) and his Shikai J reaches 3.4 m.** The exceptions that cover NAGI's
band: Kenpachi's Shikai lunge (to 5.7 m, S16), KYORAN's (4.9, S14), Ichigo's NS3a rush (5.0, S18), Ichigo's JUJISHO (12 m).

## 2. The triangle at each distance (T: both press on the same frame)

Simplified from `tables.md` §T. "wins" = his real hit lands first; "x" = a cancel (J vs NS) that opens an exchange (§5 decides it); "-" =
nothing reaches.

**Shikai vs sealed Kenpachi**
- 1.5-2.5 m: his J1 (S9) beats Hisagi's J1 (S14); his NS1a / NS2a (S14 / S16) beat Hisagi's NS2a / NS3a / NAGI (NAGI cannot hit inside 3
  m); his J1 cancels every Hisagi NS (he is the J side). **Hisagi wins no cell outright**; his J1 cancels the Kenpachi NS (Hisagi the J
  side, §5: TSUMUJI then wins).
- 3.5 m: his J1 whiffs (and slides him to 2.9 m, inside NAGI's dead zone: NAGI whiffs too); Hisagi's NS2a / NS3a hit (37 / 33); his NS2a's
  armour takes NS3a / NS2a's hit (`a`).
- 4.5-5.5 m: **NAGI wins against everything** (51); NS3a wins to 5.2.

**Shikai vs Kenpachi's Shikai (L0)**
- His lunge (S16, to 5.7 m) beats NAGI, NS2a and NS3a at **every distance 1.5-5.5 m** (35). NS2a vs the lunge is a same-frame NS tie (x).
- **Hisagi's J1 cancels the lunge at every distance 1.5-5.5 m** (it arrives during J1's active frames): Hisagi is the J side, and §5's
  TSUMUJI wins (X-d: 52 at 3.0 / 4.0 / 5.0 m, 26 against his SA +8).
- His J1 (S9, 3.4 m) beats Hisagi's J1 to 3.5 m. NAGI owns only 5.8-6.4 m.

**Shikai vs Ichigo's Shikai** (the best matchup on paper)
- J1 vs J1: both S14, a tie (x) to 2.5 m.
- **NS2a beats both his NS1a (S22) and his NS3a rush (S18) at 1.5-3.5 m, and the rush up to 5.5 m** (30).
- **NS3a beats his J1 at 2.5-5.5 and his NS1a at 1.5-4.5** (26).
- NAGI beats his J1 / NS1a from 3.5 m (41), loses to his NS3a rush up to 4.5 m (S18 < S20), beats it at 5.5 m.
- His J1 vs Hisagi's NS2a: x (Hisagi the NS side).

**Shikai vs KESSA**: NAGI wins every cell 3.5-5.5 m (51); NS2a / NS3a win against his J1 / NS1a to 3.5 / 4.5 m; his NS3a clones (S18 +
hit-at) beat NS2a / NS3a at 1.5-2.5; his J1 (S8) beats Hisagi's J1 at 1.5.

**Ranged mode**: J1 at 4.5-5.5 m hits his J1 (whiffing) everywhere; into his NS it only cancels (x). WA (S14, 360°): his J cancels it
(Hisagi the NS side, x); against his NS1a, sealed Kenpachi's S14 ties (x), his Shikai lunge loses to WA at 1.5-5.5 m (19), Ichigo's NS1a
loses at 1.5-2.5 and his NS3a rush at 1.5-5.5. TABA beats every J and NS at 3.5-4.5 m except his Shikai lunge (o) and Ichigo's NS3a up to
4.5 m (o). Inside 2.5 m only WA hits, and any J cancels it with Hisagi on the NS side.

**Bind mode**: KAGIYOSE (S18) beats KESSA's J1 / NS1a at 1-4 m, loses to his NS3a clones up to 3 m and to Kenpachi's Shikai lunge (S16);
their J1 cancels it.

## 3. Hit-confirmed routes (C), best by distance

| Start distance | Route | vs Kz / Ks0 / Ib / Ik | Ends | SP |
|---|---|---|---|---|
| 1.4 m | J1-J5 AS3abc | 274 / 274 / 219 / 274 | knockdown +53, 2.9 m, ptr 3, sets ZANDEN | -80 |
| 1.4 m | J1 AS1 (TSUMUJI) | 77 / 77 / 64 / 77 | knockdown **+56, 5.5 m** (NAGI's band), steals 50 | 0 (gains 25, pays 25) |
| 1.4 m | J1-J3 AS2ab | 161 / 161 / 129 / 161 | launch **+80**, 1.8 m, ptr 2 | -45 |
| 2.5 m | NS2a SA J2-J5 AS3abc | 306 / 306 / 246 / 306 | +53, 2.9 m | -80 |
| 3.5 m | **NS1a SA J2-J5 AS3abc** | **321** / 321 / 257 / 321 | +53, 2.3 m | -80 |
| 4.0 m (to 5.2) | **NS3a SA(YOSE) J2-J5 AS3abc** | 286 / 286 / 229 / 286 | +53, 2.9 m | -80 |
| 3.2-5.8 m | NS1abc | 163 / 163 / 131 / 163 | **-13**, no push (he is free 13 f first at that distance) | -75 |
| 4.0 m | NS3ab HODEN (2.0 m: 134) | 117 / .. / 93 / 117 | -1 | -10 |
| after AS3 | J1-J5 AS3abc, then J1-J5 under ZANDEN | 420 (vs 274 + 118 = 392) | | |
| ranged 4.25 m (tip) | **NS2a SA-g J2s AS2ab** | **308** / 308 / 246 / 308 | launch +49, 5.25 m | -55 |
| ranged 5.8 m (tip) | J1-J5 AS3abc | 233 / 233 / 186 / 233 | the bind, 2.0 m, -4 | -35 |
| ranged 5.8 m | J1-J5 / J1 AS1 | 110 / 76 | +5 at 6.6 m / +41 at 6.8 m | 0 / -15 |
| ranged 1.5-2.5 m | NS1abc (WA push) | 75 | +41, 5.5 m | -40 |
| bind 1.2 m | J1-J5 AS3abc (release) / J1-J3 AS2ab | 271 / 206 | +48 back to ranged / +62 | -70 / -50 |
| bind 5.0 m | NS1a (hook) SA J2-J5 AS3abc | 274 | +48 | -70 |

Short of SP (CF, sealed Kenpachi): J1-J5 AS3abc 274 at fs 300 / 100 / 30, 244 at 0 (AS starts scaled). NS1abc needs ≥ 75: 163 at 100,
80 at 30 (NS1c refused at 0), 50 at 0 (NS1b refused: a fresh NS1a). **NS3a > YOSE > J string > AS3 keeps 286 at 100 and 278 at 30**: its
NS part costs 15, the rest is J (free) and the AS (scaled). Kikon holds (C, `Kikon ...`): every pointer's hold landed; Konpaku -1 (ptr 1 /
3), -2 (ptr 2); the ranged mode -2 / -3.

The bind's clash (B): bound, 300 vs 1300 Reishi, a cancel → 425 vs 1175 (+125 / -125); from ahead, 1300 vs 300 → 1175 vs 425. Unbound,
the same cancel moves nothing. So the bind is worth entering **behind**, never ahead.

## 4. Whiff punishes (W, WH)

- **NS3a is the universal punish**: on every whiff of every opponent tested (his J1 / NS1a just out of reach, 2.4-6.0 m; the Ks0 J1 row at
  3.4 m is no whiff: his Shikai J1 reaches 3.4 and hits first) NS3a pressed +10 lands (26-33) and leads to YOSE > the J string; NS2a lands from +20 (+10 is too early against a lunge's slide: his NS1a hits first).
  NAGI punishes only whiffs that leave him at 3.0 m or more (Ichigo's NS1a at 3.6, his Shikai lunge from 6.0); sealed Kenpachi's NS1a
  slides him to 2.2-2.5 m, inside the dead zone.
- **Hisagi's own whiffs**: NAGI inside 3.0 m whiffs and recovers 42 f: every opponent's NS1a punishes it (+10 to +30) and his J1 from +20;
  a J1 whiff (Ichigo at 2.4 m; Kenpachi's 0.45 m hurt radius puts 2.4 m inside J1's reach) is punished by Ichigo's J1 from +20 and either
  Ichigo's NS1a; an NS2a whiff at 3.9 m by his NS1a from +20 (at +10 his slide carries him into NS2a); an NS3a whiff at 5.3 m only by his
  Shikai lunge late (+30).

## 5. The exchange after a cancel (X)

- **Hisagi the J side (his J1 cancels the opponent's NS opener)**: AS1 TSUMUJI wins against every answer tried, all four opponents: his SA +2
  / +8, his next NS segment, nothing (52 / 39 / 26 dmg, knockdown at 4.3-5.5 m, +56). The same against the long openers: Kenpachi's
  Shikai lunge at 3.0 / 4.0 / 5.0 m, KYORAN's at 2.5 / 4.0 m (52, + his own 40 Bankai cost), Ichigo's NS3a rush at 2.5 / 3.5 m. **J2 instead loses to his SA** (+2
  and +8), and doing nothing loses to his SA and, against Ichigo's slow NS1a / NS3a, to the cancelled move's own later hit.
  (TSUMUJI's hop carries Hisagi back to 3-4 m while its four cuts reach along the chain; DUEL_CORE §2.1.1 records the same; the user kept
  it: 「先不用」.)
- **Hisagi the NS side (his J cancels Hisagi's NS2a)**: his AS +2 beats Hisagi's SA and NS2b (AS beats NS, the later start beats the SA);
  his AS +8 still beats the SA but loses to NS2b; his J2 loses to the SA. Against Ichigo the AS +8 wins both. So as the NS side Hisagi must
  guess, and loses the guess his opponent is most likely to make (the instant AS).
- **The ranged mode's exchange** (J1 x his NS1a): RANSA (AS1, 3-6 m) wins only against nothing; his SA +8 beats it at 2.2 m (inside RANSA's 3 m
  dead zone, which the cancel's unlock opens at x0.5) and both whiff at 4.5 m. No sure answer there.

## 6. Anti-approach (A) and Ichigo's wave (G)

- Run-in from 6.5 m: NAGI pressed within 6 f of his start hits him at 3.0-3.3 m (51); from +12 f he is inside the dead zone and it whiffs.
  The ranged J1 catches the run-in at +0-12 (14), TABA at +0-6 (36), WA at +12 (19, pushed to 4.1 m).
- Walk-in from 5.0 m: NAGI at +0 / +6 hits (51), +12 whiffs.
- Hoho-in from 4.5 m (he lands 1.6 m behind): no Shikai move hits him; if he then presses J1 (26 f), Hisagi's J1 at +12 / +18 lands first,
  a Step back at +12 / +18 escapes (3.4-4.1 m); the ranged WA at +6 hits him behind (360°, pushed to 4.5 m).
- **Ichigo's JUJISHO route** (NS2a > NS2b > NS2c, the wave on f56): NAGI pressed in the first 20 f of his charge at 4-6 m hits him (41-51),
  NS3a at 4.0 m too; J1 timed into the wave (+60) cancels it; a Hoho at +50 / +60 passes through; a back Step does not (the wave is 12 m
  long). At 8 m nothing of Hisagi's reaches: Hoho or eat 82.

## 7. Wake-up (K)

- J1 AS1 leaves him down at 5.5 m: NAGI pressed +40 f after Hisagi is free lands as he rises (77 → 128); +0 / +20 whiff on the down
  invulnerability. Against a Hoho mashed through his wake-up he escapes (behind Hisagi at 1.6 m); against a J1 mash NAGI +20 still whiffs.
- J1-J5 AS3abc (down at 2.9 m): NAGI +40 lands (313), a walk-in J1 lands on any timing (305).
- NS2abc (down at 1.6 m): NAGI +40 (185), walk-in J1 (173).

## 8. The mirror (H, T Hb vs Hh)

NAGI vs NAGI on the same frame cancels at 3.5-5.5 m; four frames earlier wins (51). By distance: ≤ 3.5 m NS2a beats NS3a and NAGI, NS3a
beats J1; at 4.5 m NS3a beats NAGI (S18 < S20), NAGI beats NS2a; at 5.5 m NAGI beats everything. A back Step out of his NAGI escapes from
4.5 m (to 7.0) but not from 3.5. Whoever presses first in the 3.5-6 m band wins; nobody's general arm stands there (§9 of strategies.md).

## Not covered / limits

- One frame each: T is a simultaneous press; a reaction 8-24 f late (the CPU's perception) changes cells where the startups differ by
  less (most of 1.5-2.5 m).
- The dummy does nothing after a cancel in T / W: `x>H` there means "the exchange opens"; §5 has the answers.
- Kenpachi's L only moves his J string and its AS (D trials of the 2026-11-06 catalogue); his lunge reaches 5.7 m at L0 and L3 alike.
- The dormant OUT-graph moves (`hs-j1-1h` ...) in the sheet are unreachable since S1.

# Ichigo: strategy proposal (PLAN4's kit study, step 3; for the user's pick, 2026-11-15)

Each strategy = which of the catalogue's means to use in which `:rb-sp2` situations (PLAN4 §2: G0 lead x his red x awakening, G1 form x
`:dm`, G2 his state x `:dm`, G3 cells, G4 bursts, G5 exchange, G6 walls, G7 Reishi, G8 clock x lead, G9 switch x pointer, G10 his pointer x
`:dm`). Numbers cite `sheet.md` / `catalogue.md` / `matchup-*.md`. Descriptors are behaviours of **her own choices**, not outcome states (the
four mode arms failed because the opponent set the distance and HARD's patience made the modes alike: `arms4/ichigo.md`). Counters marked
*new* are not in `strat-run.lisp`'s desc line yet (tool-only additions, as `nstart` / `asp` were). Nothing here is built.

## The kit's facts that drive every strategy

1. **Her NS beats his lone J inside 3.2 m** against all four opponent forms (P: cI), because a J cancels the NS in its startup and the
   segment carries on. **Her J loses or ties every J** (S14 against Kenpachi's 9 and Hisagi's 14). So she should answer, not open with J.
2. **NS vs NS is first hit**: Kenpachi's NS1a (S14) / NS2a (S16) and Hisagi's NS2a (S16) / bind (S18) beat her NS openers in their reach.
3. **Reach bands differ by opponent**: sealed Kenpachi reaches 2.9 m, she reaches 4.8 m (NS3a): 3.0-4.8 m is hers. His Shikai reaches
   4.5 m. Hisagi reaches 3.4-6.0 m with his chain and is blind inside 3.0 m. One distance plan cannot serve both.
4. **The exchange is worth ~200 SP** (every breakthrough took 143-200), and after a cancel her SA beats his AS and J2 (except Hisagi's
   TSUMUJI), her AS beats his next segment.
5. **The gauge splits the kit**: at 0 SP the NS1 / NS2 routes die after segment a while J-first routes keep 87-92 % (G); J1-J3 AS2ab nets
   -6 SP and J1 AS1 +10 at 100.
6. **KESSA's NS3a + SA** wins 20 of 20 grid cells against Hisagi's openers and 17 of 20 against sealed Kenpachi's; KESSA J1 (S8) beats
   Kenpachi's J1.

## General strategies (both opponents)

| # | Name | Idea | Situations (`:rb-sp2`) | Catalogue | Expressed by | Descriptor (pre-registrable) | Threshold's sheet number |
|---|---|---|---|---|---|---|---|
| S1 | **answer** (counter-NS) | answer his J with an NS inside 3.2 m; after the cancel, SA at once; never her next segment into a possible AS | G2 his state `:atk` x `:m-close`; G5 exchange open; G3 his cells 2-3 (the breakthrough takes most) | P (NS vs J: cI), X2/K (SA 19 beats AS1; NS1b loses 90), X1 | the exchange keys (§6.5): `:clash-p` k 1.5, `:xch-sa-p` k 1.5, `:xch-carry-p` k 0.3, `:clash-margin` 0.5; **code question**: today these come only from the pairing's `:with` unit, an arm must be allowed to override them | `clash` (clashes a match) >= arm 0 x 1.3, **and** *new* `sa_x`: share of her post-cancel first moves that are the SA >= arm 0 + 0.15 | her NS1a 3.0 m against his J 2.1-2.6 m: the clash lies inside `:m-close`; breakthrough 143-200 SP |
| S2 | **brawl** (today's arm, kept) | live inside 3 m: NS against his J, J-first routes after a hit, AS3 for pointer 3 | G2 `:free` x all; G1 form 0 x close; vs Hisagi always, vs Kenpachi from his Shikai on | P, A12 / B8 / D5, W (his dead zone) | `a4-i-brawl` as built (`:iks-patient-p 0 :iks-gap-p 0`, the ptr3 mode) | (registered) share of steps inside 3 m >= arm 0 + 0.10 (passed +.18 / +.18) | Hisagi's 3.0 m dead zone; Kenpachi's Shikai NS1a 4.5 m takes mid range away |
| S3 | **economy** (new) | at a short gauge play J-first, steer to AS1 for the steal, no NS2 charges, no back dash | G3 my cells 0 (any his); G3 his cells 2-3 x mine 0-1 (the steal and breakthroughs refill her) | G (J routes at 0: 177 / 103; NS routes refused), A6 / G A6 (steal 40, takes his last cell), K2 (KESSA 60) | `:iks-steer-to 2` (AS1), `:ns` 0.2, `:iks-retreat-p 0`, `:iks-gap-p 0` | *new* `as1`: share of her AS that are AS1 >= arm 0 + 0.25, **and** `sp` (SP moves a match) <= arm 0 x 0.85 | AS1 20 SP vs AS3 90; NS2's route needs 80 SP; regen stops at 100 |
| S4 | **lunge** (revises the failed `whiff` / `space`) | hover at the edge of his reach, punish his whiff with NS3a late (f24), catch his walk-in with NS3a at 5-6 m | G2 `:atk` / `:evade` x `:m-mid`; G10 his pointer x mid; G1 form 0 x mid; vs sealed Kenpachi mainly | W (NS3a f24 lands on every whiff inside 4.8 m; f14 loses to his NS1a / NS2a), N2, R | `:iks-ns-wait 24` (default 32), `:iks-punish-p 1`, `:iks-confirm-p 1`, `:iks-mix-whiff 1` | *new* `punish`: her move starts inside his recovery, a match >= arm 0 x 1.5 | NS3a reach 4.8 m vs his 2.9; the f24 timing from W |
| S5 | **kessa-lunge** (replaces `kessa2`'s neutral) | awakened: KESSA NS3a + SA from 4.2-5.5 m, J1 (S8) up close | G0 my awakening = awakened; G1 form 1 x all | P (kNS3a+SA 20/20 vs H, 17/20 vs K), K10 / K13 (SA hits from 4.6 m), R | the style's k-lunge (`*iks-kessa-lunge-band*` 5.05-5.5, `*iks-kessa-space-modes*`) via `:iks-mix-space 1` while awakened; **code**: the band as `-lo` / `-hi` keys to move it to 4.2-5.5 | `k_sp` (SP moves per 1000 awakened steps) >= arm 0 x 1.3, **and** *new* `k_p3`: share of awakened NS starts at pointer 3 >= arm 0 + 0.2 | the SA's 4.6 m reach; its armour f6-9 |

## Targeted strategies

| # | Opponent | Name | Idea | Situations | Catalogue | Expressed by | Descriptor | Sheet number |
|---|---|---|---|---|---|---|---|---|
| T1 | Kenpachi | **sealed band** (= today's `all`, kept) | while he is sealed, hover 3.7-4.2 m (out of his 2.9, inside her 4.8) and punish; once he is in Shikai switch to S2 | G0 his awakening = no x lead; G1 form 0 x mid; his Shikai -> brawl | R, W, N2, P/K vs P/Ks | `a4-i-all` (the sealed hover table 3.7-4.2 is already in her band) | arm 0 | his sealed reach 2.9 m vs his Shikai NS1a 4.5 m |
| T2 | Kenpachi | **keep, ahead only** (today's `keep`, narrowed) | the Getsuga at 10 m when ahead late; his J cancels it at 6.6-8.5 m, so not as a general zone | G8 `:t-late` x `:ahead`; `:m-far` | N1 (10 m hits his run, 8.5 m he cancels and hits), X3/K | `a4-i-keep` | (registered) p2 +0.20 and mean d +0.5 m | wave 12 m at 14 m/s; his run 10 m/s |
| T3 | Hisagi | **inside 3 m** (merge into S2) | never stand at 3.4-6.0 m; go in through NS3a at 3.2-4.2 m (beats his chain NS1a, S18 < S20); stay inside his dead zone | G1 x `:m-mid` -> in; G10 his pointer 1 x mid | P/H (NS3a vs NS1a: I to 4.2 m), W (dead zone), P/Hb (his Bankai J dead inside 3.0) | `a4-i-brawl` + `:iks-hover-add -1.0` | share of steps at 3.4-6.0 m <= arm 0 - 0.10 | his chain 3.4-6.0 m, dead zone 3.0 |

## Today's arms (arms4/ichigo.md), keep / replace / merge

| Arm | Verdict | Why (data) |
|---|---|---|
| `all` (patient hover-and-punish) | **keep** = T1 / S4's base | its sealed hover 3.7-4.2 m sits in the only band that is hers against sealed Kenpachi (3.0-4.8 m) |
| `brawl` | **keep**, absorb T3 | inside 3 m her NS beats his J and Hisagi's chain is dead; the one plan that works against both and against his Shikai |
| `keep` | **keep in KI only, under a lead**; **drop from IH** | Hisagi's J cancels the wave at 6.6 m (X3/H), he out-ranges her at 3.4-6.0 m; the arm lost whole to his `none` (K.O. .79) |
| `kessa2` | **replace by S5** | it hands KESSA's neutral to the generic CPU (`:iks-wait-max 0`); the grid says KESSA's best means is NS3a + SA, which the style already has as the k-lunge |
| `whiff` (failed) | **replace by S4** | the timing fact (f24, not f14) is real; the descriptor must count her punishes, not the mid share |
| `space` (failed) | **drop** | the hover adds were inert (arms4 note 2); spacing is S4's or T1's |
| `ptr3` (failed) | **drop as an arm**; keep as a rule of every arm | pointer 3 is where every AS3 route leaves her already (70 % of steps, ceiling); the finisher steer (pointer 3 Soul Break 5) is in the base |
| `kessa` (failed) | **replaced by S5** | |
| Ichigo-vs-Hisagi cell (failed) | **merged into T3** | its close chase helped against `none`; its descriptor (mean d -0.30) missed by 0.12; T3's descriptor is the band share instead |

**Proposed set**: general S1 answer, S2 brawl, S3 economy, S5 kessa-lunge, and arm 0 `all` (= T1 / S4); targeted T2 (KI) and T3 (merged in
S2 for IH). That is 5 general arms + 1 targeted, within PLAN4's 7.

## What the kit does NOT support (no separation in the data)

- **Getsuga keep-away as a general zone**: a J cancels JUJISHO (X3, X4, N1 at 8.5 m); Hisagi out-ranges her at 3.4-6.0 m; it needs 80 SP
  and ~57 f of charges. Only "ahead, late, 10 m" stands (T2).
- **Wake-up mix-ups**: every meaty of hers lost to a wake-up J mash (Z3, Z4); the knockdown buys the steal and position only.
- **Hoho approach / Hoho pressure**: a Hoho-in caught nothing (N5, N6), costs 100 SP (a third of the gauge), and is refused while an
  exchange is open. As an approach it equals a forward Step (F4) at no cost.
- **Kikon fishing on a non-red opponent**: any J of his cancels the follow-up (E12). The Kikon is a red-opponent tool (already the style's
  `*iks-kikon-p*` rule).
- **The NS2 charge route (360) as an opener**: 64 f standing still inside his reach loses to his NS1a / NS2a (P: H at 1.6-2.4 m); it is a
  punish route, not a strategy.
- **The pointer switch** (DUEL_SP §3): not catalogued (no side stick in the trial player); no strategy rests on it.
- **Clones from Step / Hoho**: gone in the core system (K16).

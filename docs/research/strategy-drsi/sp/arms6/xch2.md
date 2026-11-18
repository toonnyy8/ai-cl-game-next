# q4-defence: making the exchange a real guess (2026-11-18)

The user chose 「先補防守」 (fix the defence first) after q3-xch (`xch.md`): make the NS side not answer the own-hit cancel the same way
every time. The lead's first version (q4-defence aa51ef48): a watching NS side whose own hit made the cancel rolls *CAI-XCH-EARLY-P* .5
(the early SA, else keep watching). It barely helped: KI Kenpachi's `own` rule .965 against shipped .138. This batch: (1) diagnose what
happens after a J-side hold or J, (2) try the smallest NS-side change that keeps every fixed J-side policy near shipped, (3) the A/B.
Branch q4-defence-w (from aa51ef48). Seeds 1-500 only.

## Headline

**No setting of the NS side's exchange rolls makes the exchange a real guess at match level.** Each J side keeps a fixed policy far above
its shipped AS at every point swept. The rolls mostly move the pairings' balance instead.
- **The early SA at the other cancel** (his J's hit made it: a new knob, *CAI-XCH-EARLY-HIS-P*) is the one roll that cuts Kenpachi's
  `own` exploit: KI .945 → .81 at 0.3. It does so by weakening the NS side against the plain AS, so shipped Kenpachi rises from .125 to
  .68 in KI (from .07 to .445 in KH). That is the degenerate way to shrink "best − shipped": make shipped stronger.
- **Ichigo's and Hisagi's J side against Kenpachi's NS side** has its own hole, untouched by every roll here: always the next J
  (KI Ichigo `j` .95-1.00 everywhere; KH Hisagi `ownj` .80-.98). Watching at 1.0 instead of .65 does not close it (.95).
- **The local payoff matrix mispredicts match level** (third time: q3's KH `own`, the .15 / .40 point, the own-hit sweep). It ignores the
  flash-step economy: an AS that is read costs its SP and gives up a breakthrough steal, while hold or J keep the gauge (KI Ichigo own1:
  flash-step net -143 after an AS into a watch, -22 after a J). Knobs were set from the match-level sweep, not the matrix.

Committed: the two-case early roll (own-hit .15, his-hit .3, every tier), as the sweep's best point, **with the balance flip flagged for
the lead and the user**. The neutral alternative is his-hit 0 (the lead's mechanism, own-hit at any of 0 / .15 / .5): no balance change,
no fix (KI Kenpachi `own` .935-.965).

## 1. Diagnosis: what happens after a J-side hold or J

Logs: `xch.py log ki --seeds 1-200` under the lead's knobs (STRAT_SET own-hit .5, his-hit 0), with three new fields per decision
(strat-run.lisp): `m1` my first new action and its frame, `hs1` his action or state on that step, `h1` his first new action, `hit` the
first hit's source. Tables: `xch/q4-hs1-ki.txt`, `xch/q4-diag-ki-*.txt`; traces `xch/q4-trace-*.txt`.

**KI Kenpachi J side, own1** (his J's hit made the cancel; Ichigo's segment still to land):
- **AS (shipped):** pressed on frame 0, into a watching Ichigo whose segment is still out (`hs1` ns:ic-k-n1a / n3a). Ichigo's SA starts
  later and wins: he hits first 89-100 %, dh -0.19 to -0.58. The losing decision is Kenpachi's own: the AS at own1.
- **Hold:** 38 % of the time Kenpachi does nothing until he is hit (Ichigo first 92 %, but dh only -0.14: Ichigo's punish on the Shikai
  is worth little, and Kenpachi bursts out after two hits). The rest, where the value is:
  - his J1 recovers while Ichigo's NS segment is still out, and his clash (CAI-CLASH, J into NS, HARD 1.0 x1.7) cancels it again,
    **now with Ichigo's hit making the cancel**: Kenpachi's own0. Ichigo answers with the early SA (own-hit) and Kenpachi's AS, the
    later start, absorbs it (trace `q4-trace-ki-seed6-11194.txt`: cancel 11187, hold, clash 11235, cancel 11241, Ichigo's SA 11245,
    Kenpachi's AS 11263 absorbs it, hits 11300). Kenpachi's AS while Ichigo is in `sa:ic-k-sa1`: 144 of 1010, he hits first 97 %,
    dh +0.49.
  - **The losing NS decision:** after a hold, Ichigo's segment stays out long enough to be re-cancelled by the free J side, which turns
    own1 (his watch wins) into own0 (his answer is the early SA or a watch that is about even).
- **J:** the next J re-cancels the still-out segment the same way (J2 on frame 10).

**KI Ichigo J side, own1, against Kenpachi's NS side** (the `j` hole):
- Ichigo's J2 on frame 10 meets Kenpachi's Shikai NS1a still active and cancels it again (`hs1` ns:ke-s-n1a, 448 of 612).
- Every cancel his ATK takes part in gains Ichigo +30 flash-step (DUEL_SP §5) and refunds Kenpachi's segment. Kenpachi carries into NS1b,
  Ichigo's J2 cancels that too, then Ichigo's AS absorbs NS1b and hits with a full gauge (trace `q4-trace-ik-seed3-17159.txt`: cancels
  17154 / 17169 / 17208, AS 17216, hit 17262, Ichigo's gauge 300).
- **The losing NS decision:** Kenpachi's NS route carrying on through repeated re-cancels (his long Shikai NS1a / NS1b), never
  answering the new J link in time (the J's start and the cancel fall on the same tick). Not a roll the exchange makes.

## 2. The game and the sweep

**The local matrices** (`xch.py game`, `xch/q4-game-{ki,kh}.txt`, from logs with the early roll at both cancels at .5 so every NS
column is randomised): rows = the J side's explored option, columns = the NS side's shipped roll (watch / early x carry), by own. They
showed the shape (own0: watch + carry beats every J option for Ichigo's NS; own1: the early SA beats hold and J, loses to the AS) and an
NS minimax per cell. Their match-level predictions failed (above), so they only chose the directions.

**The match-level sweep** (`xch/sweep/*.txt`, `xch-sweep.py`): STRAT_SET the knobs, seeds 301-400, both character orders, 200 matches an
arm, every fixed J policy (shipped AS, hold, own, ownj, j) on each of the four J sides. Each cell: shipped / the best fixed policy.

| own-hit, his-hit early | KI Kenpachi | KH Kenpachi | KH Hisagi | KI Ichigo | worst best | mean best - shipped |
|---|---|---|---|---|---|---|
| .5, 0 (the lead's) | .150 / .965 own | .185 / .380 ownj | .815 / .975 ownj | .850 / 1.000 ownj | 1.000 | +.330 |
| 0, 0 | .125 / .935 own | .095 / .570 own | .905 / .980 hold | .875 / 1.000 ownj | 1.000 | +.371 |
| .15, 0 | .125 / .945 own | .070 / .450 own | .930 / .965 hold | .875 / 1.000 ownj | 1.000 | +.340 |
| .15, .1 | .315 / .935 own | .235 / .400 own | .765 / .940 ownj | .685 / 1.000 j | 1.000 | +.319 |
| .15, .2 | .510 / .880 own | .400 / .400 shipped | .600 / .905 ownj | .490 / 1.000 j | 1.000 | +.296 |
| **.15, .3** | .680 / .810 own | .445 / .445 shipped | .555 / .795 ownj | .320 / .960 j | .960 | **+.252** |
| .15, .2, watch HARD 1.0 | .740 / .955 own | .300 / .360 own | .700 / .925 ownj | .260 / .950 j | .955 | +.297 |

(.15, .4 on seeds 301-500, `xch/q4-ab-*.txt`: KI Kenpachi .762 shipped / .662 own; KH Kenpachi .618 / .352; KH Hisagi .383 / .805 ownj;
KI Ichigo .237 / .915 j.)

- **De-confounded:** the own-hit roll alone (0 / .15 / .5 at his-hit 0) changes nothing that matters: KI Kenpachi's `own` stays
  .935-.965. Lowering it is not the fix; the lead's .5 and 0 are equivalent within noise.
- **The his-hit roll** is a monotone trade: Kenpachi's `own` gap shrinks (KI .82 → .13 at .3; KH .38 → 0) while his shipped AS rises in
  both pairings, Ichigo's and Hisagi's shipped fall (KI Ichigo .875 → .32, KH Hisagi .93 → .555), and their `j` / `ownj` exploits stay.
- **The minimax level reached:** the J side's best fixed policy, worst side, 1.000 (lead) → .960 (.15 / .3); mean gap over shipped .330
  → .252. Before the user's request (q3-xch, own-hit 1.0): KI Kenpachi `own` .995.

## 3. The A/B at the committed point (.15 / .3, seeds 301-500)

`xch/q4b-ab-*.txt`, HARD vs HARD, 400 matches an arm (SE about .025). The lead's build (.5 / 0) and the original (q3-xch, own-hit 1.0) in
the last two columns, for the same character's shipped and best policy.

| J side | shipped | hold | own | ownj | j | lead's build: shipped / best | q3 original: shipped / best |
|---|---|---|---|---|---|---|---|
| KI Kenpachi | .660 | .463 | **.780** | .407 | | .138 / .965 own | .133 / .995 own |
| KH Kenpachi | **.445** | .163 | .345 | .190 | | .185 / .380 ownj (301-400) | .255 / .477 ownj |
| KH Hisagi | .555 | .458 | .487 | **.800** | | .828 / .975 ownj | .745 / .980 ownj |
| KI Ichigo | .340 | | .255 | .865 | **.965** | .850 / 1.000 ownj (301-400) | |

- Best fixed policy - shipped: KI Kenpachi +.12 (was +.83), KH Kenpachi 0 (was +.20), KH Hisagi +.245 (was +.15), KI Ichigo +.625 (was
  +.15). Kenpachi's exploits are mostly closed; the two against Kenpachi's NS side are not, and KI Ichigo's grew.
- Balance moved: shipped Kenpachi KI .138 → .660, KH .185 → .445 (Hisagi .828 → .555). The user's call before anything ships.

## What this means

- The exchange's NS rolls cannot make the exchange a guess on their own. In KI the NS side's first hit on a holding Kenpachi is worth
  about zero (he bursts after two hits; Ichigo's Reishi damage on the Shikai is small), so the J side's hold is never punished enough,
  and the AS's read costs a gauge the matrices don't count.
- The holes are elsewhere:
  - **the re-cancel of a segment still out** (both directions: Kenpachi's hold-then-clash, Ichigo's J loop), farmed by the +30
    cancel gain and the refund;
  - **the value after the break** (the burst out of a two-hit punish, the damage on the Shikai).
  Both are rules or kit questions (DUEL_SP §5's cancel gain, a segment's re-cancel, the burst), the lead's and the user's call.
- The committed point moves balance a lot (KI and KH towards Kenpachi). If that is not wanted, set *CAI-XCH-EARLY-HIS-P* to 0: the
  mechanism stays, the balance is the lead's build's.

## Files

- Code: core-ai.lisp (the early roll by whose hit made the cancel), tuning.lisp (*CAI-XCH-EARLY-P* .15, new *CAI-XCH-EARLY-HIS-P* .3),
  tests/duel-rules/xch-ai.lisp, KNOBS.md.
- Tools: strat-run.lisp (`m1` / `hs1` / `h1` / `hit` fields, the NS pick `we..` for early, STRAT_XPOL `j`), `xch.py game` and `ab
  --rule a,b,c`, `xch-sweep.py`, `xch-diag.py`, `xch-hs1.py`.
- Data: `xch/q4-*`, `xch/q4b-*`, `xch/sweep/`.

## §R1. The rule version: the cancel's +30 once per exchange (2026-11-18)

The user, after the section above: 「先量規則版」 (measure the rule version first). Research only; the rule stays as it is unless the user
decides after these numbers.
- **R1** (`*sp-cancel-gain-once*`, tuning.lisp, default NIL): inside one open exchange (from its cancel until both are back in neutral,
  FIGHTER-XCH) only the first cancel pays the ATK's `*sp-gain-cancel*` +30 (DUEL_SP §5); a later cancel before the exchange is over pays 0.
  A same-step second verdict (a same-class J tie) is still the first cancel: both sides are paid. Also for the Kikon follow-up's cancel.
  Pure test: `sp-recancel-p` (sp.lisp, tests/duel-rules/sp.lisp).
- **R2** = R1 + `*sp-recancel-no-refund*` (default NIL): an NS / AS segment cancelled inside an exchange already open gets no refund
  (CORE-CANCEL-LANDED!; a hazard cancelled after its move ended keeps its refund). Measured because R1 did not close the farm (below).
- **Off is EQ:** with both knobs NIL the `--cvc` lines (II / IK / KK seed 7, 99 lines) are byte-identical to 69459d9a's (md5 b87a95d6...);
  host tests 3778 ALL PASS, pkgcheck clean. **Main's NS rolls** (early own-hit 1.0, his-hit 0, R1 off) reproduce main's play: KI and KH
  seeds 1-10, every line but `stats:` equal to the abdd87e4 build's.

### The sweep (seeds 301-400, 200 matches an arm; shipped / the best fixed J policy)

| config | KI Kenpachi | KH Kenpachi | KH Hisagi | KI Ichigo | worst best | mean best - shipped |
|---|---|---|---|---|---|---|
| main's rolls (1.0 / 0), rule as now | .165 / .995 own | .270 / .460 ownj | .730 / .985 ownj | .835 / .945 ownj | .995 | +.346 |
| main's rolls, **R1** | .115 / .980 own | .130 / .530 ownj | .870 / .985 ownj | .885 / .975 ownj | .985 | +.367 |
| main's rolls, **R2** | .065 / .980 own | .155 / .580 ownj | .845 / .965 ownj | .935 / .965 ownj | .980 | +.372 |
| .15 / .3, rule as now | .680 / .810 own | .445 / .445 shipped | .555 / .795 ownj | .320 / .960 j | .960 | +.252 |
| .15 / .3, **R1** | .525 / .630 own | .430 / .430 shipped | .570 / .860 ownj | .475 / .980 j | .980 | +.225 |
| .15 / .3, **R2** | .490 / .625 own | .455 / .455 shipped | .545 / .855 ownj | .510 / .985 j | .985 | +.230 |
| .15 / 0, rule as now | .125 / .945 own | .070 / .450 own | .930 / .965 hold | .875 / 1.000 ownj | 1.000 | +.340 |
| .15 / 0, **R1** | .085 / .965 own | .105 / .545 own | .895 / .985 own | .915 / 1.000 ownj | 1.000 | +.374 |

### The cancel economy (`xch-econ.py`, shipped CPUs, KI + KH seeds 301-340, `xch/r1-econ.txt`)

Cancels per exchange / re-cancel share, and flash-step a match from cancel gains / from refunds:

| config | KI | KH |
|---|---|---|
| main's rolls, off | 1.66 / 40 %; Ichigo 459 / 432, Kenpachi 853 / 269 | 2.21 / 55 %; Hisagi 512 / 463, Kenpachi 1404 / 335 |
| main's rolls, R1 | 1.57 / 36 %; Ichigo 348 / 401, Kenpachi 425 / 270 | 2.10 / 52 %; Hisagi 148 / 465, Kenpachi 814 / 275 |
| main's rolls, R2 | 1.58 / 37 %; Ichigo 396 / 230, Kenpachi 440 / 248 | 2.04 / 51 %; Hisagi 145 / 295, Kenpachi 798 / 82 |
| .15 / .3, off | 1.80 / 44 %; Ichigo 653 / 547, Kenpachi 975 / 403 | 2.40 / 58 %; Hisagi 609 / 512, Kenpachi 1447 / 353 |
| .15 / .3, R1 | 1.81 / 45 %; Ichigo 389 / 509, Kenpachi 480 / 374 | 2.29 / 56 %; Hisagi 175 / 557, Kenpachi 929 / 344 |
| .15 / .3, R2 | 1.91 / 48 %; Ichigo 384 / 280, Kenpachi 504 / 236 | 2.34 / 57 %; Hisagi 179 / 324, Kenpachi 884 / 93 |

R1 removes about half of the flash-step the cancels pay (KI Kenpachi 853 → 425 a match, KH Hisagi 512 → 148) and R2 most of the refunds,
yet the CPUs re-cancel about as often (1.66 → 1.57 cancels an exchange) and every exploit stays.

### The A/B at the best config (.15 / .3 + R1, seeds 301-500, 400 matches an arm)

`xch/sweep/AB500-R1-E-o15-h30.txt`; the same NS rolls without R1 from `xch/q4b-ab-*.txt` (no `j` arm there for the Kenpachi / Hisagi
sides). SE about .025.

| J side | shipped | hold | own | ownj | j | best - shipped | without R1: shipped / best |
|---|---|---|---|---|---|---|---|
| KI Kenpachi | .502 | .398 | **.655** | .320 | .163 | +.153 | .660 / .780 own (+.12) |
| KH Kenpachi | **.425** | .155 | .403 | .155 | .083 | 0 | .445 / .445 shipped (0) |
| KH Hisagi | .575 | .450 | .542 | **.855** | .770 | +.280 | .555 / .800 ownj (+.245) |
| KI Ichigo | .497 | .320 | .285 | .892 | **.970** | +.473 | .340 / .965 j (+.625) |

Worst side's best policy .970 (without R1 .965); mean gap +.227 (without R1 +.248). R1 mostly moves KI back towards even (shipped
Kenpachi .660 → .502); the gaps stay.

### Verdict

- **The +30 is not what drives the re-cancel farm.** R1 takes half the cancels' flash-step out of the game and changes neither how
  often the CPUs re-cancel nor which fixed policy wins: KI Kenpachi `own` .995 → .980 at main's rolls, KI Ichigo `j` / `ownj` .945-.98,
  KH Hisagi `ownj` .985. R2 (no refund on a re-cancel) is the same within noise (.98 / .965 / .965).
- What drives it is positional, as the traces showed: a segment still out gets re-cancelled by the free J side (Kenpachi's
  hold-then-clash), or keeps carrying into the next J and then into the AS (Ichigo's J loop against Kenpachi's Shikai NS1a / NS1b). The
  gauge it pays is a side effect.
- **Balance:** R1 moves a little towards the NS side at main's rolls (shipped Kenpachi KI .165 → .115, KH .270 → .130; Hisagi .730 →
  .870) and pulls the .15 / .3 point back towards even (KI Kenpachi .680 → .525). It does not make the exchange a guess at match level.
- The levers left: the segment's re-cancel itself (whether a segment still out after a cancel may be cancelled again by a fresh J, or
  ends), and the value after the break. Rules questions for the user.

## §R3. The rule version: a cancelled segment goes dead (2026-11-18)

The user, after §R1: 「先量 R3」. Research only; the rule stays as it is unless the user decides after these numbers.

**The reading built** (`*core-cancel-dead*`, tuning.lisp, default NIL):
- On a cancel, every segment that took part is marked dead, in CORE-CANCEL-LANDED!, the one place both sides of a cancel pass: the J
  side's NA / SA, the NS side's NS / AS, and a hazard's firing segment while its owner is still in it. The mark is the move and its start
  tick (new fighter slots `dead-mv` / `dead-t`). The pure test is `core-seg-dead-p` in core.lisp, pinned in tests/duel-rules/triangle.lisp:
  the same move started again later (a second J1), or an SA latched on the cancel's tick, is alive.
- A dead segment:
  - collects no more hits (COLLECT-MELEE, and CUT-HAZARDS for Nozarashi's blade);
  - has no class for the triangle (CORE-WINDOW-CLASS NIL), so it can't take part in another cancel, and a hit on him during its rest is a
    clean hit, which is the breakthrough inside the open exchange.
- Unchanged:
  - FIGHTER-CLS stays, so the cancel windows, the next segment, the SA in the gap, the AS and the CPU's exchange step read the move as
    before;
  - FIGHTER-HITS stays, so the CPU's `own` flag still means "my own hit made the cancel".
- **Edge cases:**
  - A same-class J tie and the Kikon follow-up's cancel already end both moves and bounce, so R3 adds nothing there.
  - Hisagi's chain windows are hit windows of the same move, so they die with it.
  - A dead move's threat to a Hoho (PERFECT-NOW-P) is unchanged. No Hoho starts in an open exchange anyway.
- **Off is EQ:** with the knob NIL the `--cvc` lines are byte-identical to 4996d991's (99 lines, md5 b87a95d6...). Host tests 3783 ALL
  PASS, pkgcheck clean.

**The scripted check** (`xch/r3-trial.lisp` through tools/simgate/trial.lisp, which now reads STRAT_SET; logs `xch/r3-trial-{off,on}.txt`).
Setup: P1 Ichigo's J1 meets P2 Kenpachi's Shikai NS1a (startup 16, active 4) early in its startup, and P1's J2 comes into J1's chain. The
second trial ("P2 SP at 14"):

| tick | R3 off | R3 on |
|---|---|---|
| 104 | P2 move KE-S-N1A | P2 move KE-S-N1A |
| 108 | P1 IC-J1 x P2: CANCEL | P1 IC-J1 x P2: CANCEL |
| 126 / 123 | P1 move IC-J2 | P1 move IC-J2 |
| 150 / 149 | **P1 IC-J2 x P2: CANCEL** (a second cancel on the still-out NS1a) | **P1 IC-J2 -> P2 HIT 32, P1 BREAK** |
| 160 | P2 KE-S-N1A x P1: CANCEL (NS1a's own hit, still to come) | (dead: no hit) |

The fourth trial is the farm's own shape: NS1a's hit cancels J1's startup (tick 286), then with R3 off J1's own hit cancels NS1a again
(tick 298); with R3 on there is no second cancel, and the J2 lands clean (329).

### The sweep (seeds 301-400, 200 matches an arm; shipped / the best fixed J policy)

| config | KI Kenpachi | KH Kenpachi | KH Hisagi | KI Ichigo | worst best | mean best - shipped |
|---|---|---|---|---|---|---|
| main's rolls (1.0 / 0), rule as now | .165 / .995 own | .270 / .460 ownj | .730 / .985 ownj | .835 / .945 ownj | .995 | +.346 |
| main's rolls, **R3** | .085 / .690 own | .250 / .665 own | .750 / .975 ownj | .915 / 1.000 hold | 1.000 | +.333 |
| .15 / .3, rule as now | .680 / .810 own | .445 / .445 shipped | .555 / .795 ownj | .320 / .960 j | .960 | +.252 |
| .15 / .3, **R3** | .550 / .725 ownj | .455 / .605 own | .545 / .880 j | .450 / .995 ownj | .995 | +.301 |
| .15 / .3, R1 | .525 / .630 own | .430 / .430 shipped | .570 / .860 ownj | .475 / .980 j | .980 | +.225 |
| .15 / .3, **R3 + R1** | .465 / .560 ownj | .420 / .625 own | .580 / .850 j | .535 / .995 j | .995 | +.258 |

R3 at main's rolls in KI Ichigo: every policy but the AS wins: hold, own, ownj and j all 1.000, shipped .915.

### The A/B at the best R3 config (R3 + R1, .15 / .3; seeds 301-500, 400 matches an arm; `xch/sweep/AB500-R3R1-E-o15-h30.txt`)

| J side | shipped | hold | own | ownj | j | best - shipped | R1 alone (§R1): shipped / best |
|---|---|---|---|---|---|---|---|
| KI Kenpachi | .450 | .475 | **.545** | .542 | .278 | +.095 | .502 / .655 own |
| KH Kenpachi | .465 | .325 | **.615** | .285 | .100 | +.150 | .425 / .425 shipped |
| KH Hisagi | .535 | .585 | .530 | .785 | **.835** | +.300 | .575 / .855 ownj |
| KI Ichigo | .550 | .965 | .905 | .990 | **.998** | +.448 | .497 / .970 j |

Worst side's best policy .998 (R1 alone .970); mean gap +.248 (R1 alone +.227).

### The economy and the feel (`xch-econ.py`, shipped CPUs, seeds 301-340, `xch/r3-econ.txt`; main's rolls)

| pairing | K.O. of 40, off → R3 | median s, off → R3 | cancels a match, off → R3 | cancels / exchange, off → R3 | re-cancel share, off → R3 |
|---|---|---|---|---|---|
| KK | 40 → 40 | 176.8 → 173.9 | 139.2 → 98.4 | 4.26 → 3.45 | 77 → 71 % |
| KI | 40 → 40 | 168.0 → 174.7 | 49.5 → 48.0 | 1.66 → 1.49 | 40 → 33 % |
| KH | 40 → 38 | 207.6 → 197.9 | 77.0 → 66.0 | 2.21 → 1.93 | 55 → 48 % |
| II | 14 → 22 | 300.0 → 290.2 | 82.9 → 41.0 | 3.40 → 1.62 | 71 → 38 % |
| IH | 35 → 39 | 233.5 → 241.7 | 66.5 → 48.8 | 2.29 → 1.60 | 56 → 37 % |
| HH | 26 → 25 | 285.1 → 282.6 | 100.0 → 89.1 | 1.84 → 1.66 | 46 → 40 % |

Flash-step a match (cancel gain / refund), KI: Ichigo 459 / 432 → 483 / 424, Kenpachi 853 / 269 → 812 / 291; KH: Hisagi 512 / 463 →
440 / 454, Kenpachi 1404 / 335 → 1344 / 270. At .15 / .3 with R3: KI 1.73 cancels an exchange (42 % re-cancels), KH 2.00 (50 %); with
R3 + R1: KI 1.69 / 41 %, KH 1.97 / 49 %, and the cancel gains halve as in §R1.

A "re-cancel" here is any cancel while the exchange is still open. R3 removes the ones a dead segment took part in, but a fresh move
(the next segment, a new J, a clash) still cancels inside the open exchange. That is why KK keeps 3.45 cancels an exchange.

### Verdict

- **R3 does not make the exchange a real guess at match level.** It closes Kenpachi's hold-then-reclash: KI `own` .995 → .690 at main's
  rolls, and +.095 over shipped at the best config. It opens or widens the other side:
  - a fresh J into a dead segment is now a clean hit and the breakthrough, which is the J loop's payoff made direct;
  - KI Ichigo's non-AS policies all win against Kenpachi's NS side (1.000 at main's rolls, .965-.998 at the best config);
  - KH Hisagi's `j` reaches .835.
- **The worst side gets worse:** .998 at the best R3 config (R1 alone .970). The mean gap is about the same (+.248 vs +.227).
- **Balance:** at main's rolls R3 tilts KI further to Ichigo (shipped Kenpachi .165 → .085), KH stays close (.270 → .250). At the best
  config the four shipped rates sit at .45-.55: the most even of every config measured. But each side's best fixed policy is still far
  above.
- **Feel:**
  - Fewer cancels in the mirrors (KK 139 → 98 a match, II 83 → 41) and in IH (66 → 49); KI is unchanged.
  - More K.O.s in II (14 → 22 of 40) and IH (35 → 39); HH and KH about the same.
  - Medians within about 10 s everywhere.
- **What it says about the holes.** Both exploits survive the segment's death: the NS side's answer still loses to the J side's next
  choice. The NS side (Kenpachi's above all) has no CPU answer to a fresh J after a cancel: its watch's SA starts too late, and with R3
  the dead segment can't even cancel it. Closing it needs the NS side's answer to the next J (its timing or a new option), not the
  segment's lifetime.

## §NS-BR. Does any fixed NS-side policy counter "always J"? (2026-11-18)

The one cell that never moved under the rule variants was KI Ichigo's J side against Kenpachi's NS side (.945-.998). Until now only the
J side's policies had been searched. Here Kenpachi's NS side gets the same treatment: fixed NS policies, rule as now, all R knobs off,
main's NS rolls for everyone else (STRAT_SET early 1.0 / 0), HARD vs HARD.

**The tool:** strat-run.lisp `STRAT_XNS="<character> <pick> <carry>"` makes that character play a fixed answer at every exchange where it
is the NS side:
- picks: `watch` (the SA on his seen turn), `early` (the SA *CAI-XCH-SA-WAIT* after the cancel), `main` (early when its own hit made the
  cancel, else watch, with the watch always on), `none` (no SA), `ship` (its rolls);
- carry: 1 / 0 / ship.
- Two mixed modes: `mix pw pe-own pe-his pc` (independent per-event rolls, the form tuning knobs take) and `arms pa pb` (one fixed arm
  per event: early / watch + carry / main).
- Draws come from SR-FQ-U, never SIM-RND01.
- These are all the NS-side exchange options the code has. An NS side can't AS, the Hoho is refused in an open exchange, and the next
  segment is pressed only by the carry, at the segment's active end.

### The NS-arm sweep (seeds 301-400, both orders, 200 matches an arm; `xch/nsbr/*.txt`, `xch-nsbr.py`)

The win rate of the J side's character:

| Kenpachi's NS arm | KI Ichigo shipped | KI Ichigo **j** | KH Hisagi shipped | KH Hisagi **j** | KH Hisagi **ownj** |
|---|---|---|---|---|---|
| shipped (main's rolls: watch .65, carry .2) | .835 | .885 | .730 | .865 | .985 |
| early (early 1.0 / 1.0) | .680 | .780 | .870 | .850 | .975 |
| main (early own-hit, else watch; watch 1.0) | .575 | .560 | .730 | .865 | .985 |
| carry 0 | .875 | .935 | .735 | .860 | .985 |
| carry 1 | .840 | **.460** | .760 | .855 | .975 |
| none (sa-p 0) | 1.000 | 1.000 | .950 | .995 | .985 |
| watch only (sa-p 1, early 0 / 0) | .655 | 1.000 | .790 | .960 | .965 |
| early, wait 0 | .680 | .780 | .870 | .850 | .975 |
| early, wait 2 | .680 | .780 | .870 | .850 | .975 |
| watch + carry 1 | .750 | .625 | .775 | **.820** | **.845** |
| early + carry 0 | .670 | .770 | .875 | .855 | .975 |
| early + carry 1 | .685 | .785 | .880 | .870 | .975 |

- **The wait doesn't matter** (0 / 2 / 4 identical to the match): the CPU's early SA never fires before its first exchange step anyway.
  That step comes after the cancel's hitstop and its perception delay, by which time 4 frames have passed. The wait the SA could use is
  below the CPU's reaction. (The wait arms set the global knob, so the other side's own-hit SA ran with it too.)
- **KI: branch (b) holds.** Two arms put Ichigo's `j` well under .9: carry 1 (.460) and main (.560), and watch + carry .625. Each loses
  elsewhere: carry 1 lets Ichigo's shipped CPU win .840, and main is beaten by his `ownj` (below).
- **KH: no arm gets Hisagi's `j` or `ownj` well below .9.** The best is watch + carry 1: `j` .820, `ownj` .845. Every other arm leaves
  `ownj` at .965-.985.

### KI: the two-sided matrix and its equilibrium (`xch/nsmat/*.txt`, `xch-nsmat.py`)

Ichigo's J policy x Kenpachi's NS arm, Ichigo's win rate, seeds 301-400:

| Ichigo J \ Kenpachi NS | shipped | carry 1 | early | main | main + carry 1 | watch + carry 1 |
|---|---|---|---|---|---|---|
| shipped | .835 | .840 | .680 | .575 | .640 | .750 |
| own | .630 | .490 | .635 | .500 | .415 | .280 |
| ownj | **.945** | **.900** | .710 | **.925** | **.920** | .675 |
| j | .885 | .460 | **.780** | .560 | .565 | .625 |
| his best | .945 | .900 | .780 | .925 | .920 | .750 |

Zero-sum equilibrium (fictitious play, 200,000 rounds): **value .705**, against .945 for Kenpachi's shipped NS side.
- Kenpachi's NS mix: early .533, watch + carry 1 .423, main .044.
- Ichigo's mix: shipped .485, ownj .383, j .132. Against Kenpachi's mix: shipped / ownj / j .705, own .479.

### The A/B of the mix (seeds 401-500, both orders, 200 matches an arm; `xch/nsmat/AB401-*.txt`)

Ichigo's win rate against every fixed J policy:

| Kenpachi's NS side | shipped | hold | own | ownj | j | his best |
|---|---|---|---|---|---|---|
| shipped | .900 | .685 | .650 | .945 | .900 | .945 |
| the mix as **independent rolls** (`mix 1.0 .58 .53 .54`: watch 1.0, early own-hit .58, early his-hit .53, carry .54) | .605 | .540 | .545 | .825 | .765 | .825 |
| the mix **per event as arms** (`arms .533 .423`: early, else watch + carry, else main) | .725 | .505 | .410 | .715 | .720 | **.725** |

- **Played as arms, the equilibrium holds out of sample.** Ichigo's best fixed policy is .725, the predicted .705 within noise, against
  .945 with the shipped NS side. No fixed J policy wins far above the others: shipped .725, ownj .715, j .720.
- **As knob values (independent rolls) it leaks:** `ownj` .825. The equilibrium needs the carry tied to the pick: carry on when watching,
  carry rolled (.2) when firing early. Today's knobs roll them independently (*CAI-XCH-CARRY-P* does not depend on the pick).
- **The knob form closest to the mix:**
  - sa-p 1.0 (watch always), early-own .58, early-his .53;
  - carry 1.0 when watching and .2 when early. That carry-by-pick would be a new knob: a code change in CAI-XCH-STEP (shared), not
    built here.
- **The cost elsewhere:** the shipped Ichigo CPU wins .725 against this NS side (.900 against Kenpachi's shipped one). KI moves towards
  Kenpachi when both sides play their CPUs.

### Verdict

- **KI (branch b): yes, the NS side can counter.** A Kenpachi NS side mixing early SA with watch + carry, per event, holds every fixed
  Ichigo J policy to about .72 (from .945). That is the first configuration in this whole study where the cell is a real guess.
- **KH (closest to branch a):** Kenpachi's NS arms leave Hisagi's `j` / `ownj` at .82-.85 at best (watch + carry 1). The SA's timing
  can't go earlier than the CPU's first exchange step (the wait sweep), so what is missing there would be a faster NS answer to his next
  J. KH's matrix and equilibrium were not built.
- Nothing ships. The pick-dependent carry is a code change in the shared exchange step and needs the user's decision.

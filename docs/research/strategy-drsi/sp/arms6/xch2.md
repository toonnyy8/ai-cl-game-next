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

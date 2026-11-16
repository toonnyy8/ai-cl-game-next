# p9-ih: Ichigo's IH table against Hisagi (2026-11-17)

The brief (batch p9-ih): make Ichigo's IH table (`:t0-ih-ichigo`, arms5's) not dominated at parity, so the higher-tier Ichigo passes the
three IH ladder cells (H>N .630, N>E .445, E>M .325 on main 717dc4c9), with H>N HI and N>E HI still passing. Ichigo-side levers first;
Hisagi's IH table only as a last resort.

**Result.** Two of the three IH cells now pass, from the Ichigo side alone:
- N>E IH .445 → .885.
- E>M IH .325 → .895.
- H>N IH still fails: .630 → .590.

Parity is not reached at either tier. HARD .050 → .035, NORMAL .005 → .035. Hisagi's Shikai band is the block at HARD, and the NORMAL
gap is structural.

## Setup

- Seeds 501-600 (dev ladder), both seats, 200 matches a cell. The replication used 141-180 (80 a cell). No other seeds were used.
- The late-match finish is on, as shipped.
- Shipped sim build after the change: `fabe31b2f849` (`SP_BUILD`). The earlier runs used main 717dc4c9's build.
- A candidate is a raw table file played by both of Ichigo's tiers, through `STRAT_ICHIGO` (Hisagi's side through `STRAT_HISAGI`).
  - Identity check: the shipped table as a file reproduces the lookup exactly (hh .050, nn .005).
  - The installed table reproduces its file exactly, in all 8 cells.
- Tools, all new and tool-side only:
  - `ih.py`: the 8 cells (IH / HI on the three rungs, plus parity N>N and H>H), with bell vs K.O. and the points at the bell.
  - `cands.py` + `tab.py`: write every candidate. Run `python3 cands.py NAME` to regenerate one into `ih/c/`.
  - `run.sh`: the candidate loop.
  - `phase.py`: the phase split of a logged match.
  - `shares.py`: arm time shares.
  - `add.sh`: the install.
  - `diag/probe.lisp` now also reads `STRAT_<CHARACTER>=file`, so a table under test is played at every tier.
- Outputs: `ih/r-*.txt` (parity screens), `ih/f8-*.txt` (8 cells), `ih/b141-*.txt` (the second block).

## 1. Diagnosis

**The arms5 table loses at both parities, and so does every single arm.** Each of its six arms, played whole, scores .000-.095 at HARD and
.005-.115 at NORMAL (`ih/r-one-*.txt`).

**Hisagi's own Shikai band is what beats HARD Ichigo.** Hisagi's `hb-band` (cpu-hisagi-own.lisp) does five things:
- walks to 3.4-4.2 m;
- NAGIs on any closing, when the predicted hit is 3.1-6.0 m;
- back-Steps inside 3.4 m;
- pokes NAGI on his think timer;
- punishes her whiffs with NAGI.

The HARD parity cell moves with Hisagi's table, while Ichigo's stays the same:

| Hisagi's IH table | HH (Ichigo's share) | NN |
|---|---|---|
| arms5 (shipped) | .050 | .005 |
| arms5 without `:hb-band` | .280 | .030 |
| B4's (`arms4/t0final/`) | .500 | .060 |
| none (no strategy) | .525 | .120 |

**The NORMAL gap is structural.** NORMAL Ichigo loses .88-.97 to NORMAL Hisagi with any Hisagi table. About 35 Ichigo variants all stay at
or under .133 at nn.

**Where the Konpaku go** (HARD vs HARD, baseline, 40 logged matches; `phase.py`):
- Both awaken at about 90 s, with Konpaku about even (Ichigo 8.1, Hisagi 8.9).
- Hisagi then takes about 8 of his about 9 Konpaku in his Bankai / bind (Kikon 6.0, Soul Break 2.0).
- Even so, the Shikai phase decides: remove his band and HH goes .05 → .28.

**Ichigo's style misreads Hisagi.** `ichigo-ki-r2b2a1-style` was built against Kenpachi, and its tables list only Kenpachi's forms
(`*iks-his-reach*`, `*iks-hover*` and the others: `:base` / `:nozarashi`):
- The start-time NS / J punish takes his NAGI (6.0 m) for a 3.65 m whiff. She lunges NS3a, he back-Steps it, and NAGI hits her
  recovery. This loops (seed 502 log).
- The shut-gauge lunge (`iks-gap`) reads his Hoho as shut, because he spends his gauge on NAGI. She backs off to 6.5 m and lunges NS3a
  (5.0 m) into his NAGI from 6.2 m.
- In KESSA against his Bankai she hovers at the `:nozarashi` entry (4.9-5.3 m), inside his ranged J (3.4-6.2 m).

Fixing each of these with keys (punish off, gap off, the Hoho at every tier, hovers inside 3 m or outside 6.2 m, KESSA rules on
`(:awk :yes)`) left parity at or under .065 (`ih/r-v*`, `r-w*`, `r-x-*`).

**The IH unit turned her clash off.** `:d-x-ih-i` set `:clash-p 0.0`, which predates §11.30's clash (.45 / 8 at EASY and NORMAL). The
answer arm turns it back on (1.7), and it was the one arm over .09. Played alone it scores:
- H>N .610;
- N>E .935;
- E>M .930.

## 2. The change

**The unit.** `:d-x-ih-i` → `(:clash-p 1.7 :xch-sa-p 1.6 :xch-carry-p 0.3 :clash-margin 0.5 :awaken-break-p 0.0 :awaken-kikon-p 1.2)`.
These are the answer arm's exchange keys. Only `:t0-ih-ichigo` uses the unit.

**The table** (`ih/t0-ih-ichigo.lisp` = candidate `g1d`) keeps arms5's `:rb-sp2` job map and q for four arms:
- Arm 0 = `:a4-i-brawl`: patience off, the ptr3 mode, no shut-gauge lunge.
- `:i6-economy` = economy on arm 0's neutral (its steer to AS1 on top).
- `:i6-punish` = punish on arm 0's neutral. It keeps only the whiff confirm at 1.0; the start-time punish, which reads Kenpachi's reach,
  is off.
- `:a5-i-kessa-lunge`, unchanged.

The answer and brawl arms are dropped: under the new unit both play exactly as arm 0. The 6-arm version (`g1`) gives the same cells within
noise (H>N .618, N>E .870, E>M .885).

How the job arms were picked:
- With all six arms5 job arms kept, E>M stood at .760 (`t-unit-b0`).
- Each of economy, punish and kessa-lunge, swapped for arm 0's play, lifted E>M to .82-.86 (`r-s-*`).
- Putting economy and punish on arm 0's neutral gave .885.

New arm units in strategy.lisp: `:i6-economy`, `:i6-punish`.

Host checks:
- `tests/duel-rules/strategy.lisp`: the IH Ichigo row now expects 4 arms, arm 0 `a4-i-brawl`, the job cue `(:ocell 1)`, and a "before"
  checksum of 179296 (arms5's).
- `style-knob.lisp`: `I6-` units may name knobs.

## 3. Numbers (seeds 501-600, 200 a cell)

Format: share [bell / K.O.]. For IH cells "share" is the higher tier's; at parity it is Ichigo's.

| cell | main | this branch |
|---|---|---|
| H>N IH | .630 [72 / 128] | .590 [134 / 66] fail |
| N>E IH | .445 [153 / 47] | **.885** [102 / 98] PASS |
| E>M IH | .325 [42 / 158] | **.895** [27 / 173] PASS |
| H>N HI | 1.000 [0 / 200] | 1.000 [0 / 200] PASS |
| N>E HI | 1.000 [33 / 167] | .995 [62 / 138] PASS |
| E>M HI | .445 [196 / 4] | .445 [196 / 4] (the masher Ichigo plays no table) |
| N>N IH | .005 | .035 |
| H>H IH | .050 | .035 |

Ichigo's points at the bell (bell matches → her points):

| cell | main | this branch |
|---|---|---|
| H>N | 72 → 37.0 | 134 → 71.0 |
| N>E | 153 → 59.0 | 102 → 82.0 |
| E>M | 42 → 12.0 | 27 → 15.0 |

Her K.O. wins:

| cell | main | this branch |
|---|---|---|
| H>N | 89 of 128 | 47 of 66 |
| N>E | 30 of 47 | 95 of 98 |
| E>M | 53 of 158 | 164 of 173 |

**Second block** (141-180, 80 a cell, main → `g1`):

| cell | main | g1 |
|---|---|---|
| N>E IH | .425 | .838 |
| E>M IH | .400 | .912 |
| H>N IH | .613 | .550 |

N>E and E>M repeat. H>N is within noise.

**Noise.** At 200 a cell the SE is about .03-.035.
- N>E (+.44) and E>M (+.57) are real.
- H>N's −.04 is about 1 SE. Across about 30 variants it never left .50-.64.

**Bar D** (HARD vs HARD, 141-180, `finish.py bar --set shipped`, build `fabe31b2f849`):
- IH K.O. .825 → **.925**.
- Ichigo's points .050 → .037: not up (3 of 80 against 4 of 80).
- Bell: Ichigo ahead 1 / Hisagi ahead 5 (was 2 / 12).
- The other rows are identical to main.

**Switching** (`ladder.py --switch`): every match switches. Median arm changes a match:

| cell | Ichigo's side | median changes |
|---|---|---|
| H>N IH | HARD | 76 |
| N>E IH | NORMAL | 66 |
| E>M IH | EASY | 64 |
| H>N HI | NORMAL | 59 |
| N>E HI | EASY | 76 |

None of these cells has a match without a change.

**Arm shares** (arm 0 / economy / punish / kessa-lunge; `ih/shares.txt`):

| Ichigo vs Hisagi | arm 0 | economy | punish | kessa-lunge |
|---|---|---|---|---|
| HARD vs NORMAL | .556 | .160 | .114 | .170 |
| NORMAL vs EASY | .543 | .262 | .085 | .110 |
| EASY vs HARD (not the E>M cell, whose opponent is the masher) | .543 | .100 | .132 | .226 |
| HARD vs HARD | .392 | .138 | .204 | .266 |

No arm is over .70.

## 4. Hisagi-side options (measured, not on the branch: each overrides a user call)

Both options are with this branch's Ichigo table. Neither changes the KH or HH lookups; they edit only `:t0-ih-hisagi`.

| option | H>N IH | N>E IH | E>M IH | H>N HI | N>E HI | E>M HI | HH | NN | overrides |
|---|---|---|---|---|---|---|---|---|---|
| `:hb-band` removed from his IH arms (`ih/c/h-noband.lisp`) | **.765** | .855 | .760 | .990 | .955 | .695 | .385 | .090 | checkpoint 2a: 「改成修兵自己的打法」 (his own Shikai play) |
| B4's IH Hisagi table | **.835** | .915 | .760 | .975 | .955 | .690 | .560 | .210 | checkpoint 2c: 「KH、IH 換新表」 |

Both pass all three IH cells and keep the HI cells. E>M HI rises because the EASY Hisagi's table changes too. Bar D was not run for
these.

## 5. What was tried and failed (parity screens, `ih/r-*.txt`)

All of the following stayed at or under .133 at either parity:
- The six arms5 arms, played whole.
- The generic CPU.
- Hovers inside 3 m and outside 6.2 m.
- NS3a lunges.
- The punish off, the shut-gauge lunge off, the timed Hoho at every tier.
- KESSA-only rules on `(:awk :yes)`: far, near and mid hovers, k-lunge 4.2-5.0, generic, ptr3, kessa.
- The clash on arm 0.

Tried on H>N IH, all .49-.64 (`ih/r-u*`, `r-n*`, `r-h*`, `r-f*`, `r-t-*`):
- the unit's clash scale at 1.0 / 1.7, with and without the exchange keys;
- the generic's NS share and walk band (`:ns 0`, `:range .5`);
- arm 0 waiting for NAGI (the space hover with its HARD-only timed Hoho);
- arm 0 on arm 0's HARD style with the punish and gap off;
- fixed job arms.

## 6. Open

- **H>N IH.** HARD Ichigo needs an answer to the band that NORMAL Ichigo lacks, because flat arm keys erase the tier's style edge.
  - In H>N, her generic NS1a goes in at his floor, he back-Steps it, and NAGI punishes the whiff (`hn-1.log` pattern).
  - Candidates, untested: a gated Ichigo key family in cpu-ki-ichigo.lisp, such as a Hoho-in that catches his back Step with NS3a, or
    the reach and hover entries for Hisagi's forms.
- **The ladder count** (measured, `ih/ladder-full.txt`, build `fabe31b2f849`): 17 → **19 of 27**. Only the IH / HI cells differ from
  `diag/tier/ladder-ring.txt`; the other 23 cells are identical, KI included.
- **The edited unit:** `:d-x-ih-i` is named by id only from the library (the lookup). The research files that lay it (arms4 / arms5
  tables, `arms5/inband.py`, the DUCT anchors) inline it from `arms4/x-units/d-x-ih-i.lisp` or as text, so they keep the old play.

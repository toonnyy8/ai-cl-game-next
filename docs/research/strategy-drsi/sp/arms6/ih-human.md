# p10-ih-ichigo: CPU Ichigo against a human Hisagi (2026-11-17)

The user's playtest, 2026-11-17: 「我試玩起來感覺一護對修兵的 AI 特別弱」. The user played Hisagi against CPU Ichigo (difficulty not given) and
named three symptoms: 不太進攻 (she barely attacks), 一直衝進來吃招 (she keeps running in and eating his moves), 不懂躲遠距攻擊 (she does not
dodge his ranged attacks). They match p9-ih's diagnosis (`ih.md` §1). That diagnosis was never fixed, because the fixes did not lift parity
against CPU Hisagi's band. This batch judges by behaviour against human-like Hisagis instead. It changes Ichigo's style file only, plus
its test and KNOBS.md. The IH table and every shared file are untouched.

- Base: main 6385a675. The brief's e3a2a9d1 is not an object in this repo, and main = origin/main = 6385a675, which holds p9-ih (v434).
- My build of main reproduces `diag/tier/ladder-p9.txt` and `bar-p9.txt` exactly (`ihh/ladder-main.txt`, `ihh/bar-main.txt`). The hash
  differs (0c4052c2422b against f23d72765792) only because the worktree path is compiled in.

## Tools (`ihh/`, tool side only)

- `beh.lisp`: a runner. It plays the Ichigo / Hisagi pairing gate with a difficulty per seat and prints its own lines: every hit and
  combo opener with the hitter's move, his form, what the victim was doing and the distance; every move started from a free state; and per
  match the frames by his form inside and outside the band. The combat log stays on for the CPU's own tags (`ki-style`, `cpu clash`,
  `cpu xch`, `cpu finish`).
  - `BEH_HISAGI`: `lookup` | `none` (no strategy: the generic core CPU) | `arm:<id>` (one arm played whole, with the IH unit `:d-x-ih-h`
    laid under it as his table does).
  - `BEH_ICHIGO=<table file>`: the Ichigo table, played at every tier.
  - `BEH_SET`: knobs bound at load, as probe.lisp's `PROBE_SET`.
- `beh.py`: the behaviour table per Ichigo tier and opponent, both seats, seeds 141-180 (80 matches a cell).
  - Rates are per minute of battle.
  - It also lists his openers by move and by what she was doing, and her punished whiffs by her move, distance, his form and her tag.
  - Outputs are cached in `build/ihh-cache`, keyed by the build, the runner, the env and the args.
- `table.py`: two `beh.py` JSONs as one before → after table.
- `t/`: the Ichigo tables used in step 1 (`shipped` = the installed one, `arms5` = before v434, `noclash`, `gate`, `gate3`).

**Opponents.**
- The generic CPU Hisagi with no strategy.
- `h5-all` whole: his Shikai band. It holds 3.4-4.2 m, NAGIs on any approach, back-Steps inside 3.4 m, pokes NAGI and punishes her whiffs.
  That is the scripted "holds 4-5 m and NAGIs on approach" opponent, so no separate script was written.
- `h4-range` whole: his ranged-mode style.
- His shipped IH table (`lookup`).

Hisagi is HARD in the main table: an 8-frame delay and his band's rolls at 1.0, the closest stand-in for a competent human. A second table
plays him at NORMAL.

## 1. Step 1: is v434's clash a regression? No

v434 turned her clash on (`:d-x-ih-i :clash-p 1.7`). Removing it does not help against these opponents:
- Rows: arms5's old table (clash 0), or the shipped table with the unit's `:clash-p 0.0`.
- NAGI hits double or triple at every tier.
- His openers on her rise (EASY against h5-all 9.25 → 13-14 a minute).
- Her attack starts fall.

The clash's J into his NAGI is a cancel (DUEL_CORE §2.1), not a hit taken, so it is what kept the NAGI off her. A few rows (main → no
clash, per minute; HARD Hisagi):

| Ichigo | Hisagi plays | NAGI hits | his openers | her attack starts | her share |
|---|---|---|---|---|---|
| EASY | his IH table | 2.92 → 9.87 | 9.94 → 16.35 | 19.6 → 11.7 | .000 → .000 |
| NORMAL | his IH table | 4.58 → 8.64 | 11.84 → 15.50 | 21.4 → 17.7 | .000 → .000 |
| HARD | his IH table | 1.58 → 3.02 | 8.70 → 11.08 | 24.5 → 19.4 | .037 → .138 |
| HARD | h5-all | 1.80 → 3.38 | 8.05 → 9.37 | 24.3 → 20.5 | .325 → .412 |

(arms5's table: much the same, `ihh/b-arms5.txt`.)

**What the clash costs.**
- His SA KIRI in NAGI's gap, after the cancel: 1.2-1.6 openers a minute, on her J's startup.
- Her clash whiffs against his Bankai modes: her NS / J thrown from 2-5 m into his ranged J or bind moves and punished (NORMAL: KESSA
  NS1a from 5 m, 1.8 a minute; HARD: KESSA J1 from 2-4 m, about 1.8).
- At main, the openers within 90 ticks after her `cpu clash` / `cpu xch` were 31 % at EASY / NORMAL and 54 % at HARD (his IH table).

**Gating it on reach (unit rules, data only).**
- `(:dj :out)` / `(:dj :afar)` → `:clash-p 0`: plays as no clash (`ihh/b-gate.txt`).
- Gated only where his J outreaches hers (`+ (:do :in)`, his ranged mode; `t/gate3.lisp`).
  - On top of this branch's code it cut her punished whiffs at HARD (his IH table 4.68 → 3.73) and lifted her HARD share.
  - It raised the ranged-J hits (2.87 → 4.24) and her free-state openers.
  - It cost H>N IH .745 → .570 (seeds 501-600).
- Not adopted: the clash stays as shipped.

An unexpected finding: `:oawk` (his awakening) reads 0 in an arm's or a unit's rules. It is a Q selector's extra cue (STRAT-XFEATS), not a
rule cue, so a gate on it never fires (`ihh/b-v1g2.txt` = `b-v1.txt`).

## 2. Step 2: Hisagi rows in Ichigo's style (`duel/lisp/cpu-ki-ichigo.lisp`)

**Rows by his form.**
- `*iks-hisagi-keys*` maps Hisagi's forms to row keys (`:base` → `:hisagi`, `:bankai` → `:hisagi-ranged`, `:bankai-bind` →
  `:hisagi-bind`).
- `iks-form-get` reads his row when a table has one (NIL included). Otherwise it falls back exactly as before: his form's row, else
  `:nozarashi`'s.
- Kenpachi and Ichigo opponents never reach the new branch.

**The band cross** (`iks-cross`, `*iks-cross-band*`).
- Rows: `:hisagi (3.0 6.4 2.2)`, `:hisagi-ranged (3.0 6.4 2.2)`. NAGI and his ranged J both miss inside 3.0 m (`:min-reach`) and reach 6.0;
  the band ends 0.4 m past that.
- The rule: inside the band, with him free, dodging or recovering, she crosses in to 2.2 m. She uses the Hoho when it is ready with
  flash-step to spare (`*iks-cross-hoho-p*`), else a dash. When his move's hit is coming she leaves the step to the Hoho / punish above.
- It sits in `iks-neutral` before pointer 2 and before the `:ptr3` hand-off to the generic CPU. Every shipped IH arm plays `:ptr3`, so
  without it the generic neutral walked her through the band.
- Rolls: once per episode (`*iks-cross-p*`) and once per cross (`*iks-cross-hoho-p*`). Both are new style keys (KNOBS.md §6.7b), at
  EASY 0, NORMAL 1, HARD 1 (§4).

**The start-time punish reads his move** (`iks-whiff-start-p`, `*iks-move-band-chars*`).
- Against Hisagi, his perceived move whiffs when she is 0.4 m beyond its reach plus its slide, or 0.4 m inside its dead zone
  (`mv-min-reach`, with his kit's hook: 0 in a route out of a cancel).
- Before, `*iks-his-reach*`'s `:base` row (sealed Kenpachi's NS 3.65) took a NAGI started at 4-6 m for a whiff.
- One number per form would misread two pointers of three: TAN-GARI 2.5 + 1.0 slide, SHIBARI's 4.5 m line, WA 0-3, TABA 2.5-4.15.

**The shut-gauge lunge reads only his lockout** (`*iks-gap-lockout-only*`). He spends the flash-step gauge on his SP (NAGI), so a low
gauge is no shut Hoho of his.

**Hover rows.** `*iks-hover*` and `*iks-hover-p1*` gain `:hisagi` / `:hisagi-ranged` (2.0 2.6), inside his dead zone. Before, his Shikai
read 3.7-4.2 and his ranged mode 4.9-5.3, both inside his 3.0-6.0. These matter for KESSA's `:space` (the kessa-lunge arm) and pointer 2's
wait.

**KESSA pointer 3 presses J1 within 2.0 m** (`*iks-close-j-chars*`). KESSA NS3a's clone whiffs at 1 m. In his bind that was her largest
single punished whiff (generic, 0.35-0.70 a minute at NORMAL / HARD).

**Tests and checks.**
- `tests/duel-rules/style-knob.lisp`:
  - Key counts 107 → 109, `iks-` 35 → 37.
  - New: the cross rows are pinned against his kit's moves (NAGI and the ranged J1: dead zone 3.0, reach 6.0 + 0.4), the Hisagi hover
    rows sit inside the dead zone, and Kenpachi's rows are unchanged. The values are read from the style file's text, because the style is
    not host-loadable.
- KNOBS.md §6.7b documents the two keys.

## 3. Behaviour before → after (seeds 141-180, both seats, 80 matches a cell; per minute of battle)

"Ranged-J hits" = HS-R-J1-J5. "His openers" = combos he opens on her. "Her whiffs punished" = his openers while she was in a move's
recovery. The last two columns are her share of his ranged-mode time in 3.4-6.2 m and of his Shikai time in NAGI's 3.1-6.0 m.

**Hisagi HARD** (`ihh/b-main.json` → `ihh/b-final.json`):

| Ichigo | Hisagi plays | her share | NAGI hits | ranged-J hits | his openers | her whiffs punished | her attack starts | ranged mode in 3.4-6.2 m | Shikai in 3.1-6.0 m |
|---|---|---|---|---|---|---|---|---|---|
| EASY | no strategy | 0.000 → 0.000 | 1.38 → 0.77 | 0.89 → 0.94 | 10.48 → 10.34 | 4.16 → 4.39 | 17.1 → 17.4 | 0.42 → 0.27 | 0.24 → 0.23 |
| EASY | h5-all (his band) | 0.000 → 0.000 | 3.00 → 2.72 | 3.00 → 3.03 | 9.25 → 9.03 | 4.36 → 4.48 | 19.3 → 19.6 | 0.51 → 0.45 | 0.58 → 0.57 |
| EASY | h4-range | 0.000 → 0.000 | 1.70 → 1.55 | 2.94 → 2.50 | 11.38 → 11.17 | 5.28 → 5.37 | 17.6 → 17.4 | 0.63 → 0.63 | 0.24 → 0.23 |
| EASY | his IH table | 0.000 → 0.000 | 2.92 → 2.59 | 3.26 → 2.67 | 9.94 → 9.45 | 4.94 → 4.92 | 19.6 → 19.7 | 0.60 → 0.54 | 0.56 → 0.55 |
| NORMAL | no strategy | 0.013 → 0.000 | 1.31 → 0.36 | 1.93 → 1.63 | 9.94 → 9.09 | 4.63 → 3.67 | 19.4 → 19.9 | 0.41 → 0.19 | 0.26 → 0.18 |
| NORMAL | h5-all (his band) | 0.000 → 0.037 | 4.14 → 1.54 | 3.29 → 3.05 | 9.75 → 7.67 | 4.92 → 3.90 | 22.2 → 23.3 | 0.54 → 0.31 | 0.61 → 0.49 |
| NORMAL | h4-range | 0.000 → 0.013 | 2.02 → 0.40 | 6.66 → 1.66 | 13.04 → 9.90 | 7.44 → 3.73 | 18.1 → 19.0 | 0.76 → 0.39 | 0.27 → 0.15 |
| NORMAL | his IH table | 0.000 → 0.013 | 4.58 → 1.69 | 5.03 → 2.68 | 11.84 → 8.09 | 6.34 → 3.89 | 21.4 → 23.8 | 0.70 → 0.33 | 0.61 → 0.50 |
| HARD | no strategy | 0.125 → 0.263 | 0.42 → 0.15 | 1.64 → 1.97 | 9.21 → 8.97 | 5.50 → 4.78 | 24.2 → 22.6 | 0.25 → 0.16 | 0.22 → 0.16 |
| HARD | h5-all (his band) | 0.325 → 0.400 | 1.80 → 0.96 | 2.22 → 2.61 | 8.05 → 7.12 | 5.06 → 4.43 | 24.3 → 22.5 | 0.30 → 0.21 | 0.45 → 0.37 |
| HARD | h4-range | 0.000 → 0.025 | 1.02 → 0.31 | 0.80 → 1.49 | 10.39 → 10.52 | 7.35 → 5.70 | 23.5 → 21.3 | 0.58 → 0.40 | 0.21 → 0.13 |
| HARD | his IH table | 0.037 → 0.163 | 1.58 → 0.95 | 2.27 → 2.87 | 8.70 → 7.85 | 5.79 → 4.68 | 24.5 → 22.7 | 0.46 → 0.29 | 0.44 → 0.37 |

**Hisagi NORMAL** (`ihh/bn-main.json` → `ihh/bn-final.json`):

| Ichigo | Hisagi plays | her share | NAGI hits | ranged-J hits | his openers | her whiffs punished | her attack starts | ranged mode in 3.4-6.2 m | Shikai in 3.1-6.0 m |
|---|---|---|---|---|---|---|---|---|---|
| EASY | no strategy | 0.287 → 0.263 | 1.08 → 0.99 | 2.43 → 2.19 | 8.72 → 8.73 | 3.62 → 3.70 | 20.6 → 20.7 | 0.32 → 0.28 | 0.27 → 0.27 |
| EASY | h5-all (his band) | 0.050 → 0.113 | 3.96 → 3.54 | 2.26 → 2.29 | 8.27 → 7.83 | 4.52 → 4.40 | 24.0 → 24.2 | 0.35 → 0.25 | 0.52 → 0.52 |
| EASY | h4-range | 0.037 → 0.100 | 2.88 → 2.75 | 1.87 → 1.88 | 10.23 → 10.21 | 4.49 → 4.57 | 20.5 → 21.4 | 0.43 → 0.37 | 0.38 → 0.38 |
| EASY | his IH table | 0.013 → 0.050 | 3.98 → 3.58 | 1.98 → 2.10 | 8.32 → 7.88 | 4.45 → 4.41 | 23.5 → 24.0 | 0.41 → 0.33 | 0.53 → 0.52 |
| NORMAL | no strategy | 0.400 → 0.525 | 0.76 → 0.18 | 2.89 → 1.96 | 7.75 → 13.70 | 3.77 → 3.31 | 22.1 → 20.1 | 0.36 → 0.21 | 0.22 → 0.15 |
| NORMAL | h5-all (his band) | 0.087 → 0.175 | 3.57 → 1.73 | 2.06 → 2.10 | 8.48 → 7.11 | 4.91 → 4.23 | 25.8 → 25.9 | 0.38 → 0.18 | 0.53 → 0.40 |
| NORMAL | h4-range | 0.075 → 0.388 | 2.77 → 0.72 | 1.93 → 2.05 | 10.09 → 11.26 | 4.85 → 4.21 | 22.1 → 21.8 | 0.49 → 0.31 | 0.38 → 0.20 |
| NORMAL | his IH table | 0.037 → 0.225 | 4.05 → 1.69 | 2.17 → 3.07 | 8.38 → 7.39 | 4.90 → 4.32 | 25.6 → 25.4 | 0.43 → 0.25 | 0.53 → 0.39 |
| HARD | no strategy | 0.938 → 0.938 | 0.57 → 0.27 | 1.62 → 1.86 | 7.30 → 10.36 | 4.72 → 3.91 | 25.5 → 22.2 | 0.24 → 0.17 | 0.20 → 0.15 |
| HARD | h5-all (his band) | 0.675 → 0.887 | 2.66 → 2.08 | 2.05 → 2.10 | 7.27 → 6.98 | 5.77 → 5.50 | 28.4 → 28.9 | 0.22 → 0.13 | 0.48 → 0.41 |
| HARD | h4-range | 0.562 → 0.675 | 0.95 → 0.53 | 1.29 → 1.43 | 9.62 → 11.01 | 6.43 → 4.81 | 24.9 → 23.8 | 0.41 → 0.29 | 0.28 → 0.18 |
| HARD | his IH table | 0.500 → 0.838 | 2.92 → 2.08 | 2.40 → 2.72 | 7.71 → 7.01 | 5.91 → 5.30 | 28.4 → 28.3 | 0.28 → 0.21 | 0.48 → 0.41 |

How to read them (80 matches a cell: a share's SE is about .05, and rates move by about 5-10 % in noise).

**一直衝進來吃招 (running in and eating his moves).**
- NORMAL / HARD: NAGI hits fall by half to three quarters, her punished whiffs by 10-50 %, and her time in NAGI's band by about a fifth.
- EASY barely moves, because the cross is off at EASY (§4). Only the reach-read punish, the gap lockout, the hover rows and the close J
  apply there.

**不懂躲遠距攻擊 (not dodging his ranged attacks).**
- Her time in his ranged J's band falls at every tier, by about half at NORMAL (.70 → .33 against his table).
- Ranged-J hits fall at EASY / NORMAL against HARD Hisagi (NORMAL against h4-range 6.66 → 1.66).
- They rise at HARD (his table 2.27 → 2.87) and against NORMAL Hisagi's table (2.17 → 3.07). These are mostly string hits after an
  opener, not openers.
- The cross into his ranged mode lands her inside WA (his ranged NS1a, 0-3 m all round, S14) during the dash's hop. Against the generic
  NORMAL Hisagi (no strategy), WA on her step opens 7 combos a minute, so his openers rise 7.75 → 13.70 although her share rises
  .40 → .525.
- Tried and not kept, no better: in his ranged mode, waiting outside 6.6 m and crossing only on his recovery (`ihh/b-v4.txt`,
  `bn-v4.txt`), and a ranged hover outside (`b-v1ro.txt`).

**不太進攻 (barely attacking).**
- Her attack starts rise at NORMAL against HARD Hisagi (+1 to +2.4 a minute).
- They are flat or slightly down at HARD (24.3 → 22.5 against h5-all). The cross itself is not an attack start, and fewer starts are
  thrown from the band, where they whiffed.
- What changed is where she stands, not how often she presses.

**Her share.**
- Against HARD Hisagi, EASY and NORMAL Ichigo still lose nearly everything; HARD Ichigo rises (his table .037 → .163).
- Against NORMAL Hisagi: NORMAL his table .037 → .225 and h4-range .075 → .388; HARD his table .500 → .838 and h5-all .675 → .887.

## 4. Guardrails (seeds 501-600, 200 matches a cell)

**The IH / HI cells**, main → this branch [bell / K.O.]. HI cells play the lower-tier Ichigo.

| cell | main | this branch | EASY cross on (`*iks-cross-p*` EASY 1.0) |
|---|---|---|---|
| H>N IH | .590 [134 / 66] | **.745** [118 / 82] (Wilson .691, still fails) | .745 |
| N>E IH | .885 [102 / 98] | .960 [54 / 146] | .960 |
| E>M IH | .895 [27 / 173] | .925 [26 / 174] | .995 |
| H>N HI | 1.000 [0 / 200] | .995 [6 / 194] | .995 |
| N>E HI | .995 [62 / 138] | .975 [75 / 125] | **.877** [105 / 95] |
| E>M HI | .445 | .445 (the masher Ichigo plays no table) | .445 |
| N>N IH | .035 | .225 | .225 |
| H>H IH | .035 | .210 | .210 |

- EASY's cross at 1.0 takes N>E HI .995 → .877, still passing (Wilson .834). That is about 4 SE below main against the brief's "no worse
  than main", so EASY is 0. At 0.5 it is .925.
- The lead can raise EASY by a number if EASY should cross too: the user's playtest tier is unknown.
- H>N HI .995 and N>E HI .975 are within noise of main (1 and 2 SE).
- Files: `ihh/f8-v3.txt` (cross at every tier), `f8-v3e0.txt` / `f8-v3e5.txt` (EASY 0 / 0.5); `f8-v3g3.txt` (+ the gate3 unit).

**The full ladder** (`ihh/ladder-final.txt` against `ihh/ladder-main.txt`):
- Only the five IH / HI cells above differ.
- The other 22 cells are identical, KI / IK / II included.
- 19 of 27 pass, as on main; H>N IH is still the one IH cell that fails.

**Bar D** (HARD vs HARD, 141-180, `finish.py bar --set shipped`; `ihh/bar-final.txt` against `ihh/bar-main.txt`):
- IH K.O. .925 → .900.
- Ichigo's points .037 → .163.
- Bell: Ichigo ahead 1 / Hisagi ahead 5 → 0 / 8.
- The other five rows are identical.

**Checks.**
- Host tests: ALL PASS (3754 checks).
- `tools/pkgcheck.sh duel`: only the known DUEL::APP note.
- `python3 tools/simgate.py --cvc`: PASS, ii / ik / kk unchanged.

## 5. Open

- **H>N IH** stays .745 (one or two matches short of the .755 bar). Nothing in this batch targets HARD over NORMAL.
- **His ranged mode.** WA covers the inside, and the dash's 24-frame hop is where it lands. A Hoho cross (behind him at 1.6 m, invulnerable
  to f14) needs 100 flash-step, which her SP spending rarely leaves: 4 % of the crosses were Hohos. A cross timed to his J's recovery only
  was no better (§3).
- **His bind** is the largest remaining source of her punished whiffs at HARD (the hook KAGIYOSE on her J's recovery, the clash and the
  finish into his bind J). This batch gives the bind no row.
- **The clash** stays (§1). A reach gate inside his ranged mode helps HARD's behaviour but costs H>N IH, a table-level trade for the lead.

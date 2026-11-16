# Ladder tiering, round 2: today's rules (2026-11-17)

The user's bar (2026-11-15): 「hard > normal > easy > 亂按，對上前一階難度的對手能獲得至少 70:30 的勝率」, judged by the game's result with a
draw as half. Every tier plays the pairing's fuzzy Q table (`*strat-table-chance*` 1 / 1 / 1).

The constraints are those of `tier-t0.md`:
- every chance is EASY ≤ NORMAL ≤ HARD; frames are EASY ≥ NORMAL ≥ HARD;
- no per-pairing knob;
- the masher's pre-registered rates are untouched.

This note re-runs `tier-t0.md`'s probe on main a6c77eeb. Since that probe the game has changed in five ways:
- CLASH-FIT is removed (§11.29, DEVLOG §795);
- the checkpoint 2b / 2c tables are in the lookup;
- the late-match finish is on (`*cai-finish-at*` 0.6);
- an AS out of a cancel waits 6 frames (`*core-xch-as-delay*`);
- the CPUs' perceived start is stamped (§800).

**Setup**
- Build: main a6c77eeb, with its own `build/simgate/duel.fas`.
- Seeds: dev 501-600 only, both seats, 200 matches a cell.
- No game code changed. Every world is a load-time binding (`probe.py --set` / `--lift`, through `run-tier.sh`).
- Pass = ladder.py's rule: one-sided 95 % Wilson low ≥ .70, i.e. at least 151 of 200.
- "raw" = share ≥ .70, the user's 「70:30」 read at face value.
- Tables: `*` = fail (Wilson); `[n]` = matches at the bell when over 50 of 200.
- Cells name the higher tier's character first: in H>N, KI = a HARD Kenpachi against a NORMAL Ichigo. N>N and H>H rows give the first
  character's share at parity.

**Tool changes (tool side only)**
- `probe.py`: the JSON also holds `bellpts`, the higher tier's points from matches that went to the bell.
- `tier-table.py`: a raw-share count column; N>N and H>H rows.
- The spec files are under `tier/` (`spec-r2-*.tsv`), with the logs (`r2-*.log`) and the queues (`r2-q1.sh`, `r2-q2.sh`).

## 1. Parity check and knob groups

- **probe.py = ladder.py on this build, in all 27 cells.** Every share and every bell count equals `arms5/snap/ladder-after.txt`.
- **Knob groups**: every knob in probe.lisp's `@eyes @cai @style @mc @clash` groups is still a live `defparameter`.
- **Per-difficulty knobs outside the groups**: `*hb-off*` (all nil), `*mc-full-lite*` (16 flat), `*strat-table-chance*` (1 flat) and
  `*mc-off-at*` (`((:ichigo :hard))`, a per-character setting). `*cai-finish-at*` and `*core-xch-as-delay*` are scalar rules and are left
  as they are.
- **Two shipped plists run against "EASY ≤ NORMAL ≤ HARD"**: `*cai-xch-carry-p*` (.5 / .35 / .2) and `*strat-lambda*` (.7 / .35 / .1).
  - This note treats them as habits, not skill chances: carrying the NS on after a cancel, and the weight on the prior.
  - Every world that lifts `@cai` flattens both to HARD's values.

## 2. Baseline and tier-t0's worlds on today's build

| world (`tier-t0.md` §2-4) | E>M | N>E | H>N | Wilson | raw |
|---|---|---|---|---|---|
| baseline (main) | 1 | 8 | 8 | **17** | 17 |
| R1a (NORMAL clash delay 14) | 1 | 8 | 8 | 17 | 17 |
| E1 (clash .6 / 8 at every tier) | 5 | 7 | 7 | 19 | 21 |
| E3 (E1 + EASY eyes 14 + HARD's `@cai` at E / N) | 8 | 3 | 5 | 16 | 17 |
| G3n | 9 | 3 | 5 | 17 | 20 |
| G3m22 | 9 | 7 | 5 | 21 | 22 |
| G3m24 | 8 | 7 | 5 | 20 | 22 |

Baseline, with the parity rows and NORMAL > masher for context:

| rung | KK | KI | KH | IK | II | IH | HK | HI | HH | pass | raw |
|---|---|---|---|---|---|---|---|---|---|---|---|
| E>M | .015* | .050* | .755 | .055* | .100* [88] | .125* | .015* | .230* [185] | .165* | 1 | 1 |
| N>E | .925 | .980 | 1.000 [122] | .995 | .980 | .595* [166] | .870 | 1.000 | .965 | 8 | 8 |
| H>N | 1.000 | 1.000 | 1.000 | 1.000 | .990 | .635* [77] | .975 | 1.000 | .965 [162] | 8 | 8 |
| (N>M) | .280* | .915 | .995 | .500* | .815 [74] | .665* | .715* | .985 [159] | .430* [51] | 4 | 5 |
| (N>N) | .500 | .485 | .735 [89] | .515 | .500 | .005 [56] | .265 [89] | .995 [56] | .500 [192] | | |
| (H>H) | .500 | .010 | .280 | .990 | .500 [80] | .080 | .720 | .920 | .500 [194] | | |

What changed against tier-t0:
- **tier-t0's Block 1 is gone.**
  - H>N HK is .975 as shipped (.200 then). With every tier at HARD's clash (E1) it is still .895.
  - The masher Kenpachi column passes in E1 (E>M KK .870, IK .910, HK .975). Then, HK fell to .020 and KK to .575.
  - With CLASH-FIT gone, Hisagi clashes back under 3 m (`arms5/clash2.md`).
- **The squeeze has moved to H>N KI.**
  - With NORMAL at HARD's clash (E1), H>N KI drops 1.000 → .205; in the G3 worlds it is .035.
  - At parity, Ichigo beats Kenpachi .990 at HARD. At NORMAL the cell is even (.485), but only on NORMAL's slow clash (.35 / 10).
- **IH fails at baseline on both upper rungs** (.635, .595). At parity Hisagi beats Ichigo .920 at HARD and .995 at NORMAL. Every lift to
  the lower tier widens that.
- **HH is a stall.** In every G3 and X world (lower tiers lifted), 165-199 of 200 HH matches reach the bell (main: 41 and 162). The share then comes from
  the bell's tiebreak.
- **E>M is now cheap to win.** G3n and G3m22 pass all nine E>M cells (G3m22's HH is .765).

G3m22 on today's build:

| rung | KK | KI | KH | IK | II | IH | HK | HI | HH | pass | raw |
|---|---|---|---|---|---|---|---|---|---|---|---|
| E>M | .960 | .995 | 1.000 | 1.000 | 1.000 | .975 | 1.000 | .990 | .765 | 9 | 9 |
| N>E | .985 | .865 | .925 | .960 | .825 [92] | .420* | .860 | .965 | .620* [181] | 7 | 7 |
| H>N | .875 | .035* | .805 [61] | 1.000 | .820 [65] | .435* | .745* | 1.000 | .695* [197] | 5 | 6 |

## 3. Why EASY loses to the masher today

Per match, as shipped (E>M, all nine cells, `tier/easy-masher-r2base.json`; per cell `tier/r2-em-{KK,IK,HH}-base.txt`):

**C1 (the MCTS hold, `masher-vs-easy.md`) is gone.**
- EASY is deaf 306 steps a match; it was 2309. The tables now decide before the MCTS at every tier.
- `*mc-full*` nil, which was the probe for the hold, now moves E>M only .168 → .187 (it moved .071 → .256 before).

**C2, the clash, is the masher Kenpachi column's whole cause.**
- EASY's clash (.15 / 24) fires 0.29 times a match (KK 0.01, IK 0.00).
- There is a cliff between 8 and 9 frames of clash delay. Below are E>M KK / IK / HK with EASY = NORMAL's clash and HARD's at .6 / 8
  (`spec-r2-cgrid.tsv`):

| clash chance | delay 8 | 9 | 10 | 12 |
|---|---|---|---|---|
| .35 | .440 / .480 / .880 | .050 / .145 / .130 | .070 / .165 / .085 | .040 / .105 / .050 |
| .45 | .655 / .705 / .920 | .090 / .160 / .170 | .065 / .155 / .175 | .055 / .075 / .060 |
| .60 | .870 / .910 / .975 | .150 / .275 / .345 | .205 / .245 / .265 | .070 / .165 / .085 |

- The masher Kenpachi's J1 is live for about 9 frames. CAI-CLASH's live test (`end - seen frame - delay ≥ 1`) passes only with a delay of 8
  or less, so the clash must be 8 frames.

**C3, initiative.** In KK, the masher makes the first move out of a both-free stretch 52 times a match against EASY's 9, and 40 of those
lead to his opener. He takes about 2200 Reishi a match by NA strings, and EASY suffers 8.9 Konpaku by Soul Break.

**The other lifts, one group at a time** (EASY's group at NORMAL's, or both at HARD's; all nine E>M cells; `spec-r2-em.tsv`):

| world | KK | KI | KH | IK | II | IH | HK | HI | HH | all |
|---|---|---|---|---|---|---|---|---|---|---|
| eyes 14 | .010 | .345 | .550 | .060 | .200 | .180 | .035 | .520 | .140 | .227 |
| eyes 8 (all tiers) | .445 | .705 | .990 | .265 | .365 | .415 | .510 | .790 | .265 | .528 |
| clash at NORMAL's | .070 | .685 | .995 | .165 | .335 | .290 | .085 | .400 | .260 | .365 |
| generic `@cai` (not clash) at HARD's | .260 | .650 | .890 | .290 | .510 | .460 | .490 | .855 | .565 | .552 |
| Kenpachi style HARD | .295 | .955 | .965 | .055 | .100 | .125 | .000 | .165 | .075 | .304 |
| Ichigo style HARD | .015 | .050 | .755 | .330 | .805 | .515 | .015 | .230 | .165 | .320 |
| Hisagi style HARD | .015 | .050 | .755 | .055 | .100 | .125 | .135 | .705 | .025 | .218 |
| `@mc` HARD | .015 | .050 | .755 | .030 | .145 | .140 | .015 | .260 | .120 | .170 |
| G3n but EASY's clash shipped | .410 | .900 | .950 | .910 | 1.000 | .985 | .470 | .885 | .610 | .791 |

- No single group is enough.
- The 8-frame clash carries KK, IK and HK; style and eyes carry the rest (G3m22: 9 of 9).
- Without the fast clash, even G3n's lifts leave KK at .410, HK at .470 and HH at .610.

## 4. The squeeze: H>N KI against the masher Kenpachi column

E>M needs EASY's clash at 8 frames, so monotone forces NORMAL's clash to 8 frames too. A NORMAL Ichigo with an 8-frame clash then beats a
HARD Kenpachi:

| NORMAL = EASY clash (HARD .6 / 8) | H>N KI | E>M KK / IK / HK |
|---|---|---|
| .35 / 10 (shipped) | 1.000 | .070 / .165 / .085 |
| .35 / 8 | .820 | .440 / .480 / .880 |
| .45 / 8 | .655 | .655 / .705 / .920 |
| .60 / 8 | .205 | .870 / .910 / .975 |
| delay 9, 10 or 12 at any chance | .990-1.000 | ≤ .345 |

**The cause** (`tier/r2-hn-ki-{base,c6_8}.txt`, per match, HARD Kenpachi / NORMAL Ichigo):
- At .6 / 8, the NORMAL Ichigo throws his NS into Kenpachi's J 22.3 times a match under 3 m (1.5 as shipped).
- He wins 16.5 of the 22.9 exchanges that follow, mostly by the reactive SA (xwin SA 17.8 against Kenpachi's 5.1).
- HARD Kenpachi throws 84-112 J starts a match, so a fast NS clash always has a target. His J side's AS is what the SA beats.

**HARD-only raises do not restore KI** (NORMAL's clash at .6 / 8; `spec-r2-hki.tsv`):

| HARD lever | H>N KI |
|---|---|
| none | .205 |
| clash delay 6 | .460 |
| clash delay 4 | .570 |
| clash chance 1.0 | .205 |
| clash 1.0 / 4 | .570 |
| eyes 4 | .410 |
| `*cai-xch-sa-p*` 1.0 and `*cai-xch-j*` all AS | .390 |
| NORMAL at .45 / 8 with HARD 1.0 / 4 | **.845** |

So the window is narrow, at about NORMAL = EASY = .45 / 8 with HARD at 1.0 / 4:
- With every other knob shipped (X2), E>M KK and IK fall short (.655, .705).
- With G3's lifts (X1), KK and IK pass (.955, 1.000), but NORMAL's other HARD `@cai` takes H>N KI back down to .365.

**Not measurable as a lever**: `*mc-off-at*` nil (HARD Ichigo under the MCTS) gives H>N KI / IH / II exactly as shipped (1.000 / .635 /
.990).

## 5. Candidates (full 27-cell tables)

| world | E>M | N>E | H>N | Wilson | raw |
|---|---|---|---|---|---|
| X1 | 8 | 7 | 7 | **22** | **23** |
| X2 | 3 | 8 | 8 | 19 | 20 |
| X3 (X1, Ichigo style at NORMAL's for E / N) | 7 | 6 | 7 | 20 | 23 |
| X4 (X1, NORMAL Hisagi style at EASY's) | 8 | 7 | 7 | 22 | 23 |
| X5 (X1, generic `@cai` at NORMAL's for E / N) | 8 | 6 | 7 | 21 | 22 |

X4's E>M is X1's, since its EASY is the same. Specs: `tier/spec-r2-cand*.tsv`.

### A. X1: 22 of 27 (raw 23); the most cells

| knob | EASY | NORMAL | HARD | shipped |
|---|---|---|---|---|
| `*strat-table-chance*` | 1.0 | 1.0 | 1.0 | same |
| `*ai-delay*` (frames) | 22 | 14 | **4** | 24 / 14 / 8 |
| `*cai-clash-p*` | **.45** | **.45** | **1.0** | .15 / .35 / .6 |
| `*cai-clash-delay*` (frames) | **8** | **8** | **4** | 24 / 10 / 8 |
| the other 12 `@cai` knobs (skill, think, turn, cont, Hoho, the exchange's three, the awakening breaks, DRIVE switch, `*strat-lambda*`) | HARD's | HARD's | HARD's | per tier |
| Kenpachi `@style-k` | shipped NORMAL | HARD | HARD | per tier |
| Ichigo `@style-i` | HARD | HARD | HARD | per tier |
| Hisagi `@style-h` | shipped | shipped | shipped | per tier |
| `@mc` | shipped | shipped | shipped | |

| rung | KK | KI | KH | IK | II | IH | HK | HI | HH | pass | raw |
|---|---|---|---|---|---|---|---|---|---|---|---|
| E>M | .955 | .985 | 1.000 | 1.000 | 1.000 | .945 | 1.000 | .980 [59] | .700* | 8 | 9 |
| N>E | .985 | .925 | .955 | .975 | .855 [86] | .515* | .865 | .990 | .625* [177] | 7 | 7 |
| H>N | .985 | .365* | .845 [66] | .990 | .925 | .500* | .820 | 1.000 | .785 [195] | 7 | 7 |

- Fails: H>N KI (§4), IH on both upper rungs, N>E HH, and E>M HH (.700: 140 of 200, a raw pass).
- IH is lost by K.O., not at the bell. H>N IH has 24 matches at the bell, with the HARD Ichigo taking 2 points of those 24.
- HH is decided at the bell: 177 and 195 of 200 matches there.
- **X4** is a variant of X1: NORMAL Hisagi's style set to EASY's, which is admissible.
  - It trades H>N IH .500 → .665 against N>E HI .990 → .900 and H>N KH .845 → .815.
  - The count is the same, and it is the closest any world comes to H>N IH without an EASY-side cost.

### B. X5: 21 of 27 (raw 22); the upper rung closest

X1 with the generic `@cai` (all but the clash) at NORMAL's shipped values for EASY and NORMAL. HARD keeps its own.

| knob | EASY | NORMAL | HARD |
|---|---|---|---|
| `*ai-delay*` | 22 | 14 | 4 |
| `*cai-clash-p*` / `*cai-clash-delay*` | .45 / 8 | .45 / 8 | 1.0 / 4 |
| the other 12 `@cai` knobs | shipped NORMAL | shipped NORMAL | shipped HARD |
| `@style-k` / `@style-i` / `@style-h` / `@mc` | as X1 | as X1 | as X1 |

| rung | KK | KI | KH | IK | II | IH | HK | HI | HH | pass | raw |
|---|---|---|---|---|---|---|---|---|---|---|---|
| E>M | .905 | .965 | 1.000 | .995 | .990 | .920 | .990 | .850 [163] | .565* [51] | 8 | 8 |
| N>E | .990 | .900 | 1.000 | .980 | .807 [88] | .545* | .415* [44] | .885 [51] | .575* [177] | 6 | 6 |
| H>N | .980 | .640* | .955 [101] | 1.000 | .935 | .745* [58] | .880 | 1.000 | .940 [192] | 7 | 8 |

- H>N KI improves .365 → .640, and IH .500 → .745 (a raw pass).
- The cost: N>E HK falls to .415, because the EASY Kenpachi now has NORMAL's generic chances. E>M HH falls to .565.

### C. X2: 19 of 27 (raw 20); two knobs from main

Main with **`*cai-clash-p*` (:easy .45 :normal .45 :hard 1.0)** and **`*cai-clash-delay*` (:easy 8 :normal 8 :hard 4)**. Everything else is
shipped.

| rung | KK | KI | KH | IK | II | IH | HK | HI | HH | pass | raw |
|---|---|---|---|---|---|---|---|---|---|---|---|
| E>M | .655* | .820 | .995 | .705* | .445* [133] | .360* [61] | .920 | .565* [193] | .300* [71] | 3 | 4 |
| N>E | .945 | .945 | .995 [73] | .990 | .940 | .410* [158] | .815 [61] | 1.000 | .965 [70] | 8 | 8 |
| H>N | 1.000 | .845 | .980 | .995 | .995 | .555* [82] | .853 | 1.000 | .950 [157] | 8 | 8 |

- The upper rungs stay at 8 and 8. Only IH fails there, as on main.
- E>M goes 1 → 3 (KI, KH, HK); KK and IK are short of the .755 needed.
- The cost is IH: N>E .595 → .410 and H>N .635 → .555.

**Choice for the lead.**
- A (or X4) gives the most cells and passes the masher rung except HH. It leaves KI, IH and HH open above.
- B is the same idea with H>N nearly whole (raw 8 of 9), and pays with the middle rung.
- C is the minimal change: two plists, upper rungs as main, E>M only 3.
- Not a candidate: R1a, `tier-t0.md`'s one-knob fix. It changes nothing today (17 = main), because H>N HK already passes.

## 6. The blocks that remain, and whether they are structural

**Block A: H>N KI against E>M KK / IK (structural under the constraints, within these knobs).**
- E>M against a masher Kenpachi needs EASY's clash ≤ 8 frames and a chance of about .45 or more (§3's cliff).
- Monotone passes that clash to NORMAL. A NORMAL Ichigo's 8-frame NS clash beats HARD Kenpachi's J.
- HARD-only levers recover at most .57 at NORMAL .6, and .845 at NORMAL .45 with every other knob shipped.
- Once NORMAL also gets the lifts that E>M's other cells need, KI falls under .755 (X1 .365, X5 .640, G3m22 .035).
- No world measured passes E>M KK, E>M IK and H>N KI together.

**Block B: IH on both upper rungs (a matchup block, already failing on main).**
- Hisagi beats Ichigo .920 (HARD) and .995 (NORMAL) at parity, so the tier gap has to overcome a near-total matchup edge.
- Main's tier gap reaches only .635 / .595, and every lift to a lower tier narrows it.
- It is decided by K.O. (X1's H>N IH: 24 at the bell), so the late-match finish is not what loses it.
- The one admissible lever measured is NORMAL Hisagi's style at EASY's (X4: H>N IH .665).

**Block C: HH (a stall, not tierable).**
- 165-199 of 200 HH matches reach the bell in every G3 and X world.
- The higher tier then takes .58-.79 of the points from the tiebreak.
- No eyes, clash or style setting changes the stare. This matches §11.29's 「HH 保留舊表」 and its rework note.

## 7. What would move the frontier (not tier knobs)

| change | whose call | effect |
|---|---|---|
| A Kenpachi answer to the NS clash into his J. Options: his KI table's `:xch-j` toward the J link after a cancel, or a Kenpachi arm that throws fewer J starts at 1-3 m against Ichigo | lead (table / arm) | **estimated**. HARD's generic `*cai-xch-sa-p*` 1.0 with an all-AS `*cai-xch-j*` takes H>N KI .205 → .390 at NORMAL .6 / 8, so the generic exchange knobs are not enough; it needs a matchup answer. If KI held at .755 with NORMAL at X1's lifts, X1 would be 23 (raw 24) |
| An IH Ichigo arm or table that is not dominated at parity. Today Hisagi takes .92 / .995 | lead (table / arm; IH is on the rework list) | **estimated** +2 cells (N>E IH, H>N IH) if parity IH moved to about .5 |
| An HH table that does not stare (on the rework list) | lead | **estimated** +1 to +2 cells (N>E HH, E>M HH in X1). Today it is decided at the bell |
| A per-character clash knob, e.g. Ichigo's NORMAL clash chance under EASY Kenpachi's / Hisagi's | **the user** (per character) | **estimated** small. EASY Ichigo needs the fast clash for E>M IK, NORMAL Ichigo must lack it for H>N KI, and monotone links the two. A per-character clash chance only helps if Ichigo's E>M IK can be carried by his style instead (X1's IK is 1.000 with HARD style; untested at his clash .35) |
| A per-character Hisagi style tier (NORMAL Hisagi at EASY's) | **the user** | measured inside the rules as X4. It is already admissible, because style groups are per character by construction |
| The MCTS hold fix (`masher-vs-easy.md` §4.1, `*mc-full*` nil as its probe) | lead (code) | **measured, no longer worth it**: E>M .168 → .187 |
| `*mc-off-at*` nil (HARD Ichigo under the MCTS) | user (per character) | **measured, nil**: identical cells |

## 8. Budget and files

- About 45 rung-runs at 200 a cell, plus about 30 narrowed runs of 1-3 cells (the clash grid and the KI levers).
- Full 27-cell tables: baseline, R1a, G3n, G3m22, G3m24, E1, E3, X1, X2, X3, X5, plus X4's two upper rungs.
- Specs: `tier/spec-r2-{base,worlds,em,cgrid,hki,nontier,cand,cand2,cand3}.tsv`.
- Runs: `tier/<hi>-<lo>-r2*.json`, the logs `tier/r2-*.log`, and the per-cell probe texts `tier/r2-em-*-base.txt` and
  `tier/r2-hn-ki-*.txt`.
- Render any world with `python3 docs/research/strategy-drsi/sp/diag/tier-table.py r2X1`.

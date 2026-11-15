# Kenpachi's arms from his kit study (PLAN4 P5 implementation batch, 2026-11-15)

The user took every strategy of `kits/kenpachi/strategies.md` (「全部採用」, PLAN4 "Checkpoint 2a", DEVLOG §793): `all`, out-range poke, wake-up
by his cells (generalises `bait`), red Kikon on pointer 2 (replaces `spend`), climb (no Bankai route under half Reishi); targeted Getsuga
close-in (vs Ichigo), dead-zone hug (vs Hisagi). Rush and guard are dropped. One arm a file under `arms5/kenpachi/`; the job maps below are
for T0 (a later batch); nothing here touches `strategy.lisp`.

## Code (off by default: no key = today's play)

| File | What | Arm key (default) |
|---|---|---|
| `cpu-ki-ken.lisp` KK-WAVE-MIX | `*kk-wave-mix*`'s four weights and `*kk-wave-close-max*` as arm keys (the study: "code needed to expose it") | `:kk-wave-close` / `-cut` / `-late` / `-step` (the plist's), `:kk-wave-close-max` (5.6) |
| `cpu-ki-ken.lisp` KK-LUNGE-ANY-P | the Shikai NS1 lunge at `*kk-lunge-band*` climbing or not, at any L (the study: "`:kk-lunge-p` fires only while climbing at pointer 1") | `:kk-lunge-any` (none: off) |
| `cpu-ki-ken.lisp` KK-P2-P, KK-STRING-TARGET | his Reishi fraction under the key: strings end J1-J3 + SP, which writes pointer 2 (sealed AS2; the Shikai short of an L3 Bankai plan, before the climb and its special AS: pointer 1's burst, pointer 2's AS2) | `:kk-p2-or` (none: never) |
| `cpu-kh-ken.lisp` KHF-BAIT-CELLS-P | `ken-kh-style`'s bait rolled only while his flash-step (HUD cells) is at least the key, else the KI code's meaty J1 | `:khf-bait-fs` (none: always) |
| `tools/simgate/strat-run.lisp` | under STRAT_DESC a `kdesc` line per match and side: `pfar`, `kikonk`, `wavet` (below); read-only | |
| `arms4/proof.py` | reads `kdesc` (`pfar`, `kikon_k`, `wave_taken`, TOL rel 0.15), the TESTS below, `--arms DIR` (a directory's `*.lisp` in name order) | |

Counters (per match and side): **pfar** = my J / NS (class `:na` / `:ns`) started beyond 2.4 m centre to centre (both opponents' J1 far
edge) whose contact turned `:hit` while his Reishi fell that step (a cancel writes `:hit` too but deals nothing), once a move. **kikon_k** =
his Konpaku lost on a step after one where his `FIGHTER-KIKON-LOCK` was set (my Kikon follow-up coming); a Soul Break outside a lock is not
counted. **wave_taken** = steps on which one of his `:wave` hazards connected (hits-left fell, or spent the step it appeared) and my Reishi
fell (a J's cancel of the wave deals nothing); combo waves (his AS2's point-blank Getsuga) count too.

## The arms (keys over the base = `a4-k-all`'s `:base`, `kenpachi.md`)

| File / id | Strategy | Keys over the base | `:with` |
|---|---|---|---|
| `a0-all` / `k5-all` | arm 0 | none (= `a4-k-all`) | d-x-ki-k (KI), d-x-kh-k (KH) |
| `g1-poke` / `k5-poke` | out-range poke | `:kk-reach-margin 0.1 :kk-reach-p 1.0 :range 1.3` | both |
| `g2-wake` / `k5-wake` | wake-up by his cells | `:fn ken-kh-style :khf-bait-p 1.0 :khf-bait-d 2.3 :khf-bait-fs 100` (no `:kso-stale`: `a4-k-bait`'s base) | both |
| `g3-red` / `k5-red` | red Kikon on pointer 2 | `:kk-p2-or 0.7 :kikon 0.6 :kk-kikon-red-p 1.0 :kk-kikon-ptr-p 1.0` | both |
| `g4-climb` / `k5-climb` | climb | `a4-k-climb`'s (`:kk-climb-p 1 :kk-bankai-p 1 :kk-bk-ns-p 0.25`) + rule `(((:mr :low)) (:kk-bankai-p 0.0))` (under half his own Reishi, any weight, no Bankai roll) | both |
| `t1-getsuga` / `k5-getsuga` | vs Ichigo: close in on the Getsuga | `:range 1.0 :kk-wave-p 1.0 :kk-hin-fs 0 :kk-step-in-p 1.0 :kk-hoho-in-p 1.0 :kk-hoho-in-max 8.0 :kk-reach-p 1.0 :kk-wave-close 1.0 :kk-wave-cut 1.0 :kk-wave-late 1.0 :kk-wave-step 1.0 :kk-wave-close-max 7.0` | d-x-ki-k |
| `t2-hug` / `k5-hug` | vs Hisagi: hug his dead zone | `:kk-step-in-p 1.0 :kk-dodge-p 1.0 :kk-lunge-p 1.0 :kk-lunge-any 1.0 :kk-ns-safe-p 0.0` | d-x-kh-k |

**Keys picked on probe seeds 101-140** (both seats, 80 matches an arm and opponent, before this registration; not the proof seeds):
poke 3 variants + 2 more (margin 0.1-0.15 / -0.1 / 0.0, `:range` 1.0-1.3; the chosen one had the highest pfar ratio vs Ichigo with
K.O. >= .75); red 11 variants (`:kk-p2-or` 0.5-1.01, `:kikon` 0.3-3.0; the climb precedence moved once after the first probes, see the
code row: before it, pointer 2 stayed under +0.06 vs Hisagi even at 1.01); wake 5 (bait-d 1.8-2.3, with and without the cells gate);
Getsuga 6 (mixes, Hoho in); hug 4 (`:range` 0.5-1.0, Hoho in, Hoho-safety). The probes said, before the proof: poke, red and climb pass
both opponents; **wake, Getsuga and hug fail** (below, "Expected").

## Job maps (T0, `:rb-sp2`; for the integration batch)

Format of `arms4/t0final/maps.py` (`[[group, [antecedent substrings]], ...]`, OR across entries). Fire shares are not measured here (no
T0 runs in this batch): the integration batch checks them against the vacuity rule (> 60 % of judgements: not provable) and narrows as
noted.

| Arm | Job (the study's "Situations", narrowed) | If vacuous |
|---|---|---|
| poke | G1 sealed x close `[1, ["(:form :no)", "(:dm :m-close)"]]`; G10 his pointer 1 x close `[10, ["(:optr :yes)", "(:dm :m-close)"]]` | G1 alone |
| wake | G2 his down x close / mid `[2, ["(:ost :down)", "(:dm :m-close)"]]`, `[2, ["(:ost :down)", "(:dm :m-mid)"]]` (the cells split is in the arm: a T0 job is an OR of groups and cannot AND G2 with G3) | |
| red | G0 his red (the 12 `(:ored :yes)` rules) `[0, ["(:ored :yes)"]]`; G7 his Reishi low `[7, ["(:or :r-low)"]]` | G0 alone |
| climb | G0 even / ahead x awakened `[0, ["(:lead :even)", "(:awst :k2)"]]`, `[0, ["(:lead :ahead)", "(:awst :k2)"]]` (G7 my Reishi high is the arm's own rule; G1 form 1 / 2 latches) | |
| getsuga (KI) | G10 his pointer 2 x mid / far `[10, ["(:optr :k2)", "(:dm :m-mid)"]]`, `[10, ["(:optr :k2)", "(:dm :m-far)"]]` | |
| hug (KH) | G10 his pointer 1 x mid `[10, ["(:optr :yes)", "(:dm :m-mid)"]]`; G2 his free x mid `[2, ["(:ost :free)", "(:dm :m-mid)"]]` | |

## Pre-registered (committed before the proof run; the bars are the kit study's, `strategies.md`)

`proof.py desc`, HARD, seeds 1-100 both seats (200 matches), each arm whole as a 1-arm `:rb-sp2` table with its pairing's `:with`, against
the opponent's `none`. General arms against Ichigo (`d-x-ki-k`) and Hisagi (`d-x-kh-k`); an arm shared by tables passes only if it passes
against each. K.O. >= 0.50 (any K.O.) and distinctness (TOL) against `none`, every arm.

| Arm | Descriptor | Pass | Measured against |
|---|---|---|---|
| poke | `pfar` | >= arm 0's x 1.5 | Ichigo's and Hisagi's `none` |
| wake | `wake_kd` | <= arm 0's x 0.5 | both |
| red | `p2` and `kikon_k` | `p2` >= arm 0's + 0.10 **and** `kikon_k` >= arm 0's x 1.5 | both |
| climb | `bankai` | >= arm 0's + 0.05 | both |
| getsuga | `wave_taken` | <= arm 0's x 0.5 | **Ichigo's `a4-i-keep` played whole** (`arms4/cells-k/opp-ki-ichigo-keep.lisp`, `--opp`; the arm that runs the route, as cells-k registered `wave`); K.O. and distinctness in a second run against her `none` |
| hug | `mid` | <= arm 0's - 0.04 | Hisagi's `none` |

**Expected from the probes (101-140), written before the proof**: wake x1.05 vs Ichigo (she is mostly under 100 flash-step at a
knockdown, so the meaty runs: the job and this descriptor disagree; the pure bait gives x0.60 and K.O. .40 there) and x0.67 vs Hisagi
(pure bait .29); Getsuga x0.64 at best (21.4 -> 13.8 waves a match: many are her strings' own waves); hug `mid` +0.00 (.113 vs .111:
Hisagi sets the distance, as guard showed). A bar is never moved after a run.

## Results

(below, after the run)

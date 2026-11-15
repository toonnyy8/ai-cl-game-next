# The clash dead-zone fix (PLAN4 implementation batch, the generic CPU; 2026-11-15)

The user took the lead's fix with the kit studies (Checkpoint 2a, PLAN4; DEVLOG §793: 「相消時丟出的 NS 要先確認距離不在招式死角內」).
In `kits/hisagi/probe.md`, 201 of Hisagi's 224 dead-zone NAGIs against Kenpachi came from the clash (`cpu clash ns`). The other 22 came
from Kenpachi's brawler (`kk pick`, KK-REACH-OF). Both had the same bug: the reach test had an upper bound and no lower bound.

This batch has no arms. It is a shared fix, so the one-job proof (`proof.py desc`) does not apply.

## The change

- **`xch-ai.lisp` CLASH-FIT** (pure, new). It takes the opponent's class OCLS, the perceived distance D, and the dead zones NA-MIN /
  NS-MIN (MV-MIN-REACH; NIL when there is no such move). It applies CLASH-OPENER's rule (the class that cancels his move both ways), but
  returns a class only when its opener's dead zone is <= D, and NIL otherwise. The two classes never both cancel one move, so a dead
  zone means there is no clash at all. CLASH-OPENER is unchanged.
- **`core-ai.lisp` CAI-CLASH** uses CLASH-FIT. The NA opener is `(kit-command-move kit :q e)`: the J that the press starts, with
  Hisagi's out-of-hand graph included; when a kit has none, its dead zone counts as 0, as before. The NS opener is the pointer's NS
  (NIL when the pointer has none, which replaces the old `(or (eq to :na) (kit-core-move ...))` clause). Each dead zone is read through
  the kit's `:min-reach` hook, so Hisagi's cancel unlock (§29) is respected. The test sits inside the existing guard, before
  BRAIN-CLASH-KEY and the roll, so no SIM-RND01 is drawn for a refused clash. The next tick can still clash once the distance fits. The
  upper bound is unchanged (his reach + *CAI-CLASH-MARGIN*).
- **`cpu-ki-ken.lisp` KK-FITS-P** (new). It replaces KK-PICK's two `(<= dp (kk-reach-of mv rm))` tests with two bounds: the dead zone
  <= the perceived distance D, and the distance predicted at the hit <= KK-REACH-OF. KK-REACH-OF itself is unchanged.
  - **Deviation from the first try:** the lower bound reads D, not the predicted distance. Her speed away (KEN-CLOSING, about -0.066
    m/f while Kenpachi steps back) times the delay plus NAGI's 20 f startup lifted picks at 1.6-2.8 m over 3.0 m. With the predicted
    distance, `kk pick` still threw 184 (KH) and 167 (HK) dead-zone NAGIs; with D it throws 0. Both bounds are now "only ever
    stricter", which was KK-PICK's own rule for the projection.
  - No Kenpachi or Ichigo move has a `:min-reach` (grep: only `hisagi.lisp`), so MV-MIN-REACH is 0.0 for them and their play does not
    change.
- Host tests: 10 new checks in `tests/duel-rules/xch-ai.lisp`. They cover the fit, the edge (3.0 at 3.0 hits), no move at all, and
  "no dead zone: equal to CLASH-OPENER for every class".

## Measured (`clash-measure.py`: shipped CPUs, HARD, seeds 1-50, both seats = 100 matches per opponent)

"Dead-zone NAGI" means base HS-N1A started under 3.0 m. The "before" column is a worktree at 39e11628.

| pairing | Hisagi K.O. wins | opp K.O. wins | time-outs (Hisagi ahead) | NAGIs | dead-zone NAGIs (clash / kk pick) |
|---|---|---|---|---|---|
| KH before | 0 | 50 | 0 | 633 | 577 (304 / 259) |
| KH after | 0 | 34 | 16 (1) | 104 | 19 (1 / 0) |
| HK before | 1 | 49 | 0 | 608 | 553 (306 / 232) |
| HK after | 0 | 31 | 19 (0) | 101 | 14 (0 / 0) |
| IH before | 16 | 33 | 1 | 224 | 38 (15 / 11) |
| IH after | 18 | 30 | 2 (1) | 163 | 12 (0 / 0) |
| HI before | 24 | 25 | 1 | 176 | 36 (12 / 13) |
| HI after | 24 | 26 | 0 | 209 | 21 (0 / 0) |

- Against Kenpachi, the dead-zone NAGIs fell from 1130 to 33. Hisagi still wins no K.O. (1 before, 0 after), but Kenpachi's K.O.s fell
  from 99 to 65, and 35 matches now go to time-out (Kenpachi ahead in 34). The fix alone does not make Hisagi competitive against
  Kenpachi; that is the job of his strategy batch (S1 chain band, K1 J1 into the lunge, K2 out of the sealed reach).
- Against Ichigo: 40 K.O. wins before, 42 after. The dead-zone NAGIs fell from 74 to 33.
- The shipped lookup's counts are much higher than probe.md's 224 (`h4-all` P1 only, seeds 501-540). The `kk pick` share especially is
  larger, because the shipped Hisagi tables play the Kenpachi brawler more.
- **Leftovers** (after the fix, under 3.0 m):
  - The clash threw 1, on stale perception: the perceived distance was >= 3.0 while the actual one was below it.
  - `kk read` threw 8 and `kk hoho-end plan` threw 3: other brawler paths, outside this batch.
  - `kk wave` threw 15, against Ichigo.
  - 16 came from the generic neutral, the MCTS or a string.
  - No fudge margin was added.

## Checks

- Host tests: duel-rules 3641 checks ALL PASS; duel-control 124, input 33, touch 100 (0 failures), cine 18.
- pkgcheck: only DUEL::APP.
- `./build.sh duel` built, and the smoke run (run.mjs, 8 s) exited 0. `git checkout -- vendor` was run after the build.
- **G2 did not move.** Native `simgate.py --cvc` and browser `style-gates.py cvc dist/duel` give II 41 lines P2 2-5 403.6 s, IK 42 P2
  1-2 421.7 s, KK 31 P1 3-0 307.2 s, identical to `tests/style-cvc-ref.txt`.
- Build against build (shipped CPUs, HARD, seeds 501-510, duel hash / state / gate-row lines):
  - KK, KI, IK, II are identical.
  - KH, IH, HK, HI, HH differ. This is by design: Hisagi's dead zones now restrict his clash and brawler picks, and it is the fix's
    stated exception to "the shipped lookup plays bit for bit".
  - `identity.py` compares a table with the incumbent inside one build, so it does not apply to a code change.
- snaptest HK (4 matches): straight = pollute, 0 sim lines differ (1848 rollouts).
- fulltest `FT_LAYER=t`, HK seeds 501-502: 680 checks (664 strategy), 0 differ. IH seeds 501-502: 604 checks (592 strategy), 0 differ.
- `tests/sp-costs-check.py`: 116 PASS, 0 FAIL.

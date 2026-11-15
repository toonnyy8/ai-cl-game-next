# arms5 / Hisagi: his own play and the kit study's strategies as arms (PLAN4 checkpoint 2a, 2026-11-15)

The user (2026-11-15) took every strategy of Hisagi's kit study (`kits/hisagi/strategies.md`, 「全部採用」) and, for his Shikai arm 0,
「改成修兵自己的打法」 (DEVLOG §793, PLAN4 "Checkpoint 2a"). The arms4 arms played Kenpachi's brawler (`ken-ki-style`) in the Shikai, at
1.7-3.0 m, inside NAGI's 3.0 m dead zone. This batch writes his own Shikai play and the other strategies into the CPU as style rules under arm
keys, builds the arms, and proves each does its one job. Nothing in the game names the new style: the shipped lookup and G2 are unchanged.

## 1. Code (all off without its key)

- **`duel/lisp/cpu-hisagi-own.lisp`** (new): `hisagi-own-style`, a strategy's `:fn` that plays `hisagi-hk-style` with Hisagi's rules in front
  of Kenpachi's KI code. 18 keys `:hb-*` (KNOBS.md §6.8), 4 of them switches (`style-on`, default `*hb-off*`):
  - `:hb-band` S1 the chain's band: owns every free Shikai step but his reel. Walk to 3.4-4.2 m (`:hb-lo` / `:hb-hi`); NAGI on his walk / run-in
    when its hit is predicted at 3.1-6.0 m (perceived distance less his closing speed x (delay + 20)); the pointer's NS on his whiff when it fits
    (`hkw-fits-p`); NAGI into his charge (a segment with no hit, no parry, not KESSA's clones or the wave); the back Step inside the floor while
    he closes (side Step cornered); okizeme: the pointer's NS 40 f after he is free with the opponent down; the opener (the pointer's NS when it
    reaches) on the think timer; the awakening once a match. No NS ever starts when he is inside its dead zone now or at its hit.
  - `:hb-jclash` S2: J1 into his NS / AS start in reach (CAI-CLASH's test, J opener only, its own event key). The arm turns the generic clash
    off (`:clash-p 0`) and forces the AS on the cancel (`:xch-j 0`). CAI-CLASH itself is not touched.
  - `:hb-bind` S4: behind by `:hb-bind-gap` (300 Reishi), the ranged J string runs to J5 > AS3 (KAKE: the bind) and a J1 is sought from 3.2-6.2 m
    every 30 steps; in the bind, the J clash while behind and AS2 at J4 (stay); ahead, AS2 at J4 in the ranged mode (never AS3) and J1-J5 > AS3
    out of the bind.
  - `:hb-olo` / `:hb-ohi` / `:hb-ons-min` K1: the band and an NS floor against his released forms.
  - `:hb-ich` I1: Ichigo's NS3a rush answered by NS2a (pointer 2, <= 3.6 m) or J1, never NAGI; her Getsuga charge by NAGI in its first 20 f at
    4-6 m, else a Hoho at the wave segment's frame 14 (`:hb-ich-hoho`); no back Step meanwhile.
- `cpu-hk-hisagi.lisp`: `hisagi-hk-style` takes an optional OWN rule, tried after its three rules and before the merged style (none from a
  strategy's `:fn`: the old path).
- `cpu-hisagi-range.lisp`: `*hr-taba-band*` as keys `:hr-taba-lo` / `:hr-taba-hi` (the close event's TABA, still under `:hr-taba-p` 0) and
  S3's neutral TABA `hr-taba-n` under `:hr-taba-n` (pointer 2, the opponent free in the band; no key: nothing read but it, nothing drawn).
- `tools/simgate/strat-run.lisp`: two hooks (`*sr-desc-steps*`, `*sr-desc-extra*`) and Hisagi's block of 20 read-only desc counters
  (`bdsum nagi nagiin xc xj xja taba tabat rbeh rbehb beven bina jlunge nsin osk klunge gch gans rush rushn`); `proof.py`: their means / pooled
  shares (HX_*), absolute test ops `a>=` / `a<=`, distinctness tolerances used only between two h5- arms.
- K2 (out of the sealed reach) has no arm: it is S1 against sealed Kenpachi, which is the new arm 0 (its descriptor against arm 0 is zero by
  construction). His NS1a-whiff rule (NS3a +10, never NAGI at 2.2-2.5 m) is arm 0's whiff clause and dead-zone floor.
- Dropped: `press`, `hoho6` (the user's pick).

Dev screens (seeds 301-320, both seats, 40 matches) set the defaults that changed while writing: the band's top 5.0 -> 4.2, the opener's chance
0.5 -> 1.0 at HARD, the reel handed to the string code, NAGI only on a walk-in (> 0.03 m a step). Tried and dropped: the Kikon hold on the band's
NS (vs Ichigo's `none` K.O. 0.35 -> 0.00 on the screen), a stall breaker (no effect).

## 2. The arms (`arms5/hisagi/arms.lisp`) and their job maps (`arms5/hisagi/jobs.json`, `:rb-sp2`)

| Arm | Keys over arm 0 | Job rules (KH; IH the same unless said) |
|---|---|---|
| `h5-all` (arm 0, S1) | `:hb-band 1 :clash-p 0 :hk-pot 1`, `:ken-ranged t` | everywhere else |
| `h5-cancel` (S2) | `:hb-jclash 1 :xch-j 0` | G2 attacking x close, x mid; G5 exchange open |
| `h5-tip` (S3) | no `:ken-ranged`; h4-range's data and keys; `:hr-taba-n 1 :hr-taba-lo 4.0 :hr-taba-hi 4.9` | G1 form 1 x mid, x far (b4.md v1) |
| `h5-bind` (S4) | `:hb-bind 1` | G0 behind x awakened (`:awst :k2`); G7 my Reishi low x his high; G1 form 2 x close |
| `h5-wake` (S5) | `:hk-wake 1` + h4-wake's `:kk-*` keys | G2 down |
| `h5-k1` (vs K) | `:hb-jclash 1 :xch-j 0 :hb-olo 5.8 :hb-ohi 6.4 :hb-ons-min 5.8` | G10 his pointer 1 x mid, x far |
| `h5-i1` (vs I) | `:hb-ich 1 :xch-j 0` | G10 her pointer 2 x mid, x far; pointer 3 x mid |
| `h5-ihx` (vs I) | cells-h/final/h4-ihx verbatim (its own style) | G7 my Reishi high x hers low |

- No G9 rule anywhere (it latches: b4.md). S2's and I1's G10 / G2 halves are split so no rule has two job arms. The vacuity check (a job
  firing on > 60 % of the judgements) runs on a T0's logs (`proof.py bar`); no T0 is built in this batch. Lasting states: G0 "awakened" in
  `h5-bind` lasts once he is (its G7 / G1 parts do not); G10 pointer 1 in `h5-k1` lasts while Kenpachi's pointer stays 1.
- `h5-ihx`'s Shikai is the MCTS / generic CPU's (its style falls to the range style, which returns NIL outside the ranged mode).

## 3. Pre-registered descriptors (proof.py TESTS; written and committed before the seeds 1-100 run)

`proof.py desc`, seeds 1-100, both seats (200 matches), HARD, against the opponent's `none`, as T0 plays an arm (a 1-arm `:rb-sp2` table, keep-state,
period 30) with the pairing's `:with` unit (`d-x-kh-h`, `d-x-ih-h`). `h5-all` against the OLD arm 0 (`arms5/hisagi/old0.lisp`: `h4-all` first);
every other arm against `h5-all`. Pass = every part + distinct from every sibling + K.O. rate >= 0.50. A general arm must pass against both.

| Arm | Descriptor (per match unless pooled) | Bar |
|---|---|---|
| `h5-all` | Shikai mean distance (pooled over his Shikai steps) **and** NAGI starts inside 3.0 m | >= old arm 0's + 1.0 m **and** <= 0.25 x old arm 0's |
| `h5-cancel` | J-side share of the cancels he takes part in (pooled) **and** AS start within 60 f of a J-side cancel (pooled) | >= arm 0's + 0.30 **and** >= 0.80 |
| `h5-tip` | mean distance, ranged-mode share **and** TABA starts at 4.0-4.9 m / TABA starts (pooled) | >= + 0.5 m, >= + 0.10 **and** >= 0.5 |
| `h5-bind` | bind steps / steps behind by >= 300 (pooled); BIND EVEN a match; bind entries while ahead a match | >= 2 x arm 0's; >= arm 0's + 1; <= arm 0's |
| `h5-wake` | presses in his first 20 free steps per knockdown (pooled) | >= 1.3 x |
| `h5-k1` (vs K) | his J1 starts in Kenpachi's Shikai lunge startup at 2.5-5.7 m; his own Shikai's route-opening NS inside 5.7 m while Kenpachi is in his Shikai | >= 2 x arm 0's and >= arm 0's + 1; <= 0.5 x |
| `h5-i1` (vs I) | Getsuga charges answered (NAGI landed, Hoho, or a cancel before it ended; pooled) **and** her NS3a rushes with a NAGI started in their startup (pooled) | >= 0.6 **and** <= 0.2 |
| `h5-ihx` (vs I) | move starts into her neutral | >= 1.2 x |

Deviations from the kit study, named before the run:
- `h5-cancel`: "AS1 within **20** f" -> 60 f. In the dev logs a J cancelled in its startup by his NS opens its AS window only ~45 f later (the
  sim's cancel window, `cancel-open-p`), so 20 f measures the rule of the game, not the arm. "AS1" read as the AS (TSUMUJI in the Shikai).
- `h5-k1`: "2 x arm 0's" alone is vacuous when arm 0 starts none (arm 0 turns the generic clash off): the + 1 a match part added. The NS count
  is his Shikai's only (K1's band is a Shikai rule).
- `h5-all`'s dead-zone part was written against the old arm 0 before the shared clash fix (main 336830ca: Hisagi's dead-zone NAGIs vs
  Kenpachi 1130 -> 33). On the fixed build the old arm 0 starts ~0.3 a match there (screen), so the x 0.25 part may fail with no dead-zone
  problem left; registered unchanged, the absolute counts are reported beside it.
- `h5-bind`'s x 2 share: on the screen arm 0 already sits in the bind 0.7-0.9 of the steps behind (the old ranged strings end in AS3 by the
  press count), so x 2 is out of reach; registered unchanged.
- Support (screen, per match vs `none`): Kenpachi's lunges 60-70, his Shikai most of the match; Ichigo's charges 2-4, rushes ~0.5.

## 4. Results (seeds 1-100, both seats, 200 matches an arm and opponent; `arms5/hisagi/proof/*.json`)

Builds: first run on p5-hisagi over main 336830ca (the clash fix), proof build `5cab37e096ec`; rerun after merging main c250671f (Ichigo's and
Kenpachi's batches), proof build `c66e637e022f` (sim fas `93f44a5df713`): every arm's descriptors, K.O. rates and tests identical (the files
kept are the rerun's, which carry the other batches' extra keys too).

| Arm | vs Kenpachi: descriptor (value vs arm 0) | K.O. | vs Ichigo: descriptor | K.O. | Verdict |
|---|---|---|---|---|---|
| `h5-all` vs old `h4-all` | Shikai mean d 3.53 vs 2.49 (+1.04) PASS; NAGI < 3 m 0.475 vs 0.25 a match FAIL (x0.25) | .770 (old .965) | 4.02 vs 2.14 (+1.88) PASS; 0.185 vs 4.07 PASS | **.185** (old .525) | fails: the dead-zone part vs K, K.O. vs I |
| `h5-cancel` | J-side share .534 vs .433 (+.10) FAIL; AS within 60 f .951 PASS | .710 | .524 vs .559 FAIL; .875 PASS | .200 | fails |
| `h5-tip` | mean d +.466 FAIL (by .03); ranged share +.445 PASS; TABA at the tip .254 FAIL | .930 | +.339 FAIL; +.112 PASS; .252 FAIL | .660 | fails |
| `h5-bind` | in the bind when behind .203 vs .751 FAIL; BIND EVEN 4.19 vs 6.54 FAIL; entries ahead .15 vs 1.03 PASS | .930 | 0 vs .883 FAIL; .20 vs 6.65 FAIL; .05 vs 1.06 PASS | .960 | fails |
| `h5-wake` | wake / kd .649 vs .416 (x1.56) PASS | **.480** | .537 vs .423 (x1.27) FAIL | .230 | fails (K.O. vs K by .02; vs I) |
| `h5-k1` (vs K) | J1 into the lunge 4.46 vs 0 a match PASS; own Shikai NS inside 5.7 m .255 vs 5.785 PASS | .645 | | | **passes** |
| `h5-i1` (vs I) | | | charges answered .057 FAIL (>= .6); NAGI in her rush 0 PASS | .200 | fails |
| `h5-ihx` (vs I) | | | move starts into her neutral 54.8 vs 19.3 (x2.84) PASS | 1.000 | **passes** |

Every pair of h5- arms is distinct (no `not_distinct_from`). The bars were not moved after the run.

**Stop condition (PLAN4 §3: never fewer than 3 general arms, "then stop and report").** No general job arm passes, and arm 0 fails part of
its own descriptor. Hisagi is below the floor: **no T0 should be built from these arms**; only `h5-k1` (vs K) and `h5-ihx` (vs I) are
admissible. For S5 the arms4 `h4-wake` (passed against the old arm 0, `arms4/hisagi.md` §6) still exists beside this `h5-wake`.

Deviations to weigh at integration: every arm sets **`:clash-p 0`**, which overrides the pairing's `:with` exchange key (1.7 in KH and IH)
that PLAN4 §3 lays under every arm; it was set against the dead-zone NAGIs that the shared CLASH-FIT now prevents, and the arms were never
measured without it (the first lever on arm 0's damage rate). K2 is absorbed into arm 0 (no arm). The AS window 20 -> 60 f and k1's + 1 part
(§3). Arm 0's K.O. "drop" against Ichigo is partly a reading: the old arm 0's .525 K.O.s include being K.O.'d (its K.O. wins .27); the new arm
0 won every screened match (K.O. or the lead at the bell), so it is a finishing problem, not a losing one.

Shared lines edited outside the separated blocks (other batches in flight may conflict there): strat-run.lisp `sr-desc-flush` /
`sr-desc-step` (the two hook lists `*sr-desc-extra*`, `*sr-desc-steps*`); proof.py `close_on_all`'s `hx` argument, `test1`'s op table
(`a>=`, `a<=`), `cmd_desc`'s descriptor keys, print columns and `vals` line. Stale prose left as it is (a Lisp comment change would need a
rebuild): cpu-hisagi-own.lisp's header says the band is 3.4-5.0 m and the predicted hit 3.1-6.2 m; the code uses `*hb-hi*` 4.2 and <= 6.0.

Reading:
- **Arm 0 does the kit's job in the Shikai** (+1.0 / +1.9 m, NAGI 29 / 53 a match from the band) but **K.O.s Ichigo's `none` in 18.5 % of the
  matches** (old 52.5 %). It wins the rest at the bell (every time-out of the dev screen was his lead, 300 s): Ichigo's waiting CPU hovers at
  3.5-4 m, NAGI lands (dev log: 28 hits / 13 whiffs in a match) but does not empty her Konpaku in time. This sinks every general arm's K.O.
  test against Ichigo. It is a damage-rate matter (the band's routes are NS1abc 163; the kit's 321 / 286 routes need NAGI from <= 3.5 m or
  NS3a, i.e. the pointer), the next tuning's first item.
- **The dead-zone part vs Kenpachi** fails as the pre-run note warned: after the shared fix the old arm 0 starts 0.25 a match there, arm 0
  0.475 (the string code's NS starts on his reel, which the band hands to it, and NAGIs whose hit was predicted outside 3.0 m).
- **S2**: the AS on the cancel works (.95 / .87 from .57 / .08); the J-side share hardly moves, because most cancels are his J into Hisagi's
  NAGI (the opponent's clash, which no Hisagi rule controls) and the J clash fires only on his NS / AS starts in reach.
- **S3**: the neutral TABA fires but a quarter of TABA starts are in 4.0-4.9 m (most come from the WA gap's switch at other distances); the
  distance part misses by .03 m vs K.
- **S4**: the rule keeps him out of the bind when ahead (entries x0.15 / x0.05) but, behind, puts him in it less than arm 0 (whose ranged
  strings end in AS3 by the press count far more often than the forced J5 > AS3 connects).
- **I1**: support is thin (3.2 charges a match against her `none`) and few are answered (the NAGI window of 20 f at 4-6 m and the Hoho both
  rarely line up). Her rush: 0.05 a match.

## 5. Checks (on the merged build)

- Host tests: duel-rules 3713 checks ALL PASS (style-knob: 107 keys, 10 `hr-`, 18 `hb-`; the `:fn` contract counts required arguments, and
  cpu-hisagi-own.lisp joins the "definitions only, monotone plists" check); duel-control 124, input 33, touch 100 / 0 failures, cine 18 ALL PASS.
- `tools/pkgcheck.sh duel`: only `DUEL::APP`. `./build.sh duel` exit 0, `git checkout -- vendor`; smoke (`run.mjs --secs 8`) exit 0.
- G2: `tools/simgate.py --cvc` and `tests/style-gates.py cvc dist/duel` PASS (ii 41, ik 42, kk 31 lines), `tests/style-cvc-ref.txt` unchanged
  since 39e11628.
- The shipped lookup, `fq/proof/identity.py` (raw T0 file = live lookup), seeds 501-510, both seats: KH both sides, IH both sides, HH: 10 of 10
  chunks identical, 0 differing.
- Cross-build (main c250671f vs this branch, seeds 501-510 HARD, `STRAT_HRANGE`): h4-all, h4-range, h4-wake, h4-ihx, h4-kite, h4-press against
  `none` (K and I, each seat) and the shipped lookups KH / HK / HI / IH / HH: 29 of 29 jobs identical, 12 443 lines (hash, state, gate row,
  hrange, dswitch, hdesc).
- STRAT_DESC read-only: h5-i1 vs I and h5-k1 vs K, seeds 521-530, with and without: hash / state / gate rows identical.
- snaptest (straight vs pollute, seeds 4 a run, HARD): h5-k1, h5-bind (vs K), h5-tip, h5-i1, h5-cancel (vs I), h5-all (vs K): all the same
  (1638-2276 rollouts each). fulltest (NORMAL, 2 seeds): h5-tip 24, h5-i1 40, h5-cancel 44 checks, 0 differ (h5-k1 / h5-bind / h5-all vs K:
  0 checks: the band owns the neutral the MCTS would have rolled out).
- `tests/sp-costs-check.py`: 116 PASS.

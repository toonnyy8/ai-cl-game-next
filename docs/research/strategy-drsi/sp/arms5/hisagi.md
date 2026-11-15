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

## 2. The arms (`arms5/hisagi.lisp`) and their job maps (`arms5/hisagi-jobs.json`, `:rb-sp2`)

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
period 30) with the pairing's `:with` unit (`d-x-kh-h`, `d-x-ih-h`). `h5-all` against the OLD arm 0 (`arms5/hisagi-old0.lisp`: `h4-all` first);
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

## 4. Results

(below, after the run)

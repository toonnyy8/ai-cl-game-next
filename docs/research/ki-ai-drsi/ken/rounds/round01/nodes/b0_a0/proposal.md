# b0_a0 (round 1): the sealed brawl with discipline. Reach-gated starts, no whiff chains, Hoho through what he can't beat, red-only Kikons

Direction: 封印肉搏, the sealed brawl, with the other three themes kept usable. Parent: the baseline (v0, 0.3505). Opponent: Ichigo's
champion (= v0). Only `duel/lisp/cpu-ki-ken.lisp` changed. Every new knob is a `defparameter` with a docstring (old → new where tuned).

## History read
- Baseline v0 (proposal, score.json 0.3505): str 0.125 (10/80), brawl 0.568, shikai 0.768, bankai 0.312, antiwave 0.356.
- When I started, the sibling nodes were empty. The siblings landed while I was working, and I read all three with their
  score.rescored.json:
  - **b1_a0, 0.6558** (rescored). The Shikai climb: awaken once per match, a Kikon pointer policy, `*kk-turn-p*` (the AS read in the
    plans), a Bankai dash, bankai-p 1.0, the L3 SA. Brawl stayed at 0.561, untouched.
  - **b2_a0, 0.4954.** The Bankai as a cycle: cashouts 0, a Hoho approach at L3 / in the Bankai, the AS read in `kk-move`, bankai-p
    1.0, Kikon on red. Brawl was byte-identical to v0's.
  - **b3_a0, 0.4106.** Antiwave rebuilt (late Hoho + chase, reach-gated close). Antiwave rose to 0.75; strength stayed at 10/80.
- From them I took one thing: the located v0 bug that b1 and b2 found independently. `kk-move` pressed the next J into her NS.
  I fix it here as `*kk-as-read-p*`. I also took their bankai-p / climb-p 1.0 knob values. No sibling touched the sealed play.

## Diagnosis (my own logs, HARD, KI seats; `run-situ.lisp`, scratch scripts)
1. **His starts from beyond his reach.** v0 Kenpachi starts sealed NS1a at a perceived 2.9–3.6 m.
   - Her hover (3.7–4.2 m) backs off during his startup. Her style then punishes, with NS1a / NS3a into a full J5 AS3 string.
   - In four v0 matches, 34 of her ~110 style actions were these punishes (`whiff punish-ns` / `punish-j`).
2. **A whiffed NS runs on.** `cai-move-step` presses the next NS segment on the segment's first active frame, hit or not. So a whiffed
   NS1a went on into b and c, and her punish waits 32 frames for exactly that.
3. **Her NS3a lunge from 4.0–4.1 m** (S18, 2.4 m slide). With an 8-frame delay, his NS1a (S14) is always too late, and the v0 read only
   looked within 3.1 m. That gave about 14 lunges into a full string in four matches. In KESSA, her NS3 a–c have no hit of their own:
   a clone strikes on f15. J1 / NS1a on her cannot stop it, and these became her largest damage source once she awakened.
4. **Non-red Kikons.** The generic `cai-sp` holds 35 % of SPs. In one match Kenpachi held 11 Kikons on a non-red Ichigo, and she
   cancelled all 11, losing him the SP's knockdown each time.
5. **Located bug in my own first draft:** the reach check credited her perceived speed toward him. She was only stepping into her
   hover band, and it let NS1a start at a perceived 3.0 m with +1.4 m of phantom closing. Fixed with `(min 0 v)`: only stricter,
   never looser.

## The mechanism
- **Reach discipline (`kk-pick`, `*kk-reach-p*` 0 / 0.3 / 1.0, `*kk-reach-margin*` 0.5).** This takes the generic CPU's neutral
  decisions inside its attack zone (range + 0.6 m), in every form.
  - He starts J1 or the pointer's NS only where reach + slide − margin covers the distance. That distance is lengthened by her
    perceived speed away (`ken-closing`, his own SNAP ring) times delay + startup.
  - The sealed pointer 3 tame is never started from neutral (it reaches nothing).
  - Otherwise he walks in and decides again in `*kk-reach-retry*` 3 frames.
  - The rolls are made **once per approach**, stored in the `kks` slots `appr` / `reach` / `hin`. An approach ends when he attacks,
    leaves the zone or stops being free, and on a retry the `kk-decide` rolls are skipped.
- **Hoho in (`*kk-hoho-in-p*` 0 / 0.05 / 0.8 per approach, ≤ `*kk-hoho-in-max*` 4.6 m; sealed and the Bankai).** One Hoho per approach
  puts him 1.6 m behind her, where his J1 / NS1a reach on the next decision. The Bankai's own "J1 within 2.2 m / walk within 3.6 m"
  branch now falls through to `kk-pick`: J1 in reach, a Hoho, or a walk. Its NS roll stays.
- **Whiff stop (`kk-ns-whiff`, `*kk-ns-stop-p*` 0 / 0.3 / 1.0, one roll per segment).** The next NS segment waits for the segment's
  contact. With none by its active end (and she is not in an NA, where the generic SA read applies) he stops. A landed segment still
  goes on through the generic CPU: the latch accepts the press until the segment ends (`core-latch-step`). Parry stances are left alone.
- **Dodge (`kk-read`, `*kk-dodge-p*` 0 / 0.1 / 0.8, `*kk-dodge-lead*` 9, `*kk-dodge-reach*` 0.5).** On her NA / NS start, one roll per
  start:
  - sealed within 3.1 m, the v0 answers first (tame, J1 race, NS1a);
  - when none fits (beyond 3.1 m, in the Shikai or the Bankai) and her move's reach + slide + 0.5 covers him: a Hoho timed to her
    perceived 9 frames before her hit.
  - KESSA's hitless NS3 segments are dodged within `*kk-clone-reach*` 7 m, skipping the brawl answers. The Getsuga route is excluded
    (破月牙's own code).
  - Most of these Hohos are **perfect**: 14 of 20 in one match. That is the automatic 60 counter, her 40-frame lock, and his string after it.
- **Red-only Kikon (`kk-kikon-rule`, `*kk-kikon-red-p*` 0 / 0.3 / 1.0, one roll per such SP).** Any 40-frame SP hold, his style's or
  the generic CPU's, becomes a tap while she is not red. Her red bar is read the way `cai-sp` reads it (`gauges-red-p`). To apply the
  rule to the generic CPU's presses too, `ken-ki-style` now calls `cai-neutral` / `cai-move-step` itself when no style piece decides,
  exactly as `core-brain-step` would, and returns T.
- **AS read in the planned strings (`*kk-as-read-p*` 1.0 everywhere, the generic CPU's own rule).** b1 / b2's located v0 bug, as noted
  above.
- Knobs: `*kk-climb-p*` and `*kk-bankai-p*` HARD 0.8 / 0.6 → 1.0.
- Removed: `*kk-bk-j-range*` (the Bankai J range now comes from the move's reach in `kk-pick`).

Rules: one roll per event (an approach, her move start, his move / segment, an SP). SIM-RND01 only. She is read only through the SNAP,
the distance and the perceived speed from his own ring, plus her red bar, as `cai-sp` reads it. Nothing reads inputs, debug state or the
evaluator. EASY ≤ NORMAL ≤ HARD for every chance. The style registers only for Kenpachi against Ichigo.

## Measurements (`matchup-eval --side ken`, against the champion; 20 seeds a seat, paired seeds; each row adds to the one above)

| Variant | score | HARD | brawl | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|
| v0 baseline | 0.369 | 6/40 | .557 | .714 | .316 | .474 | .95 |
| + reach discipline (margin 0.15) | 0.379 | 7/40 | .606 | .768 | .354 | .333 | .925 |
| + whiff stop, perceived-speed reach | 0.396 | 9/40 | .559 | .623 | .302 | .556 | .975 |
| + dodge | 0.445 | 11/40 | .666 | .793 | .345 | .429 | .90 |
| + red-only Kikon | 0.425 | 12/40 | .637 | .759 | .327 | .312 | .975 |
| + Hoho in (still rolled per 3-frame retry: a rule breach) | 0.451 | 13/40 | .611 | .803 | .424 | .30 | .975 |
| per-approach rolls, `(min 0 v)` fix | 0.470 | 12/40 | .667 | .860 | .305 | .50 | .90 |
| + margin 0.5 | 0.513 | 18/40 | .685 | .800 | .333 | .40 | .975 |
| (margin 0.8) | 0.410 | 13/40 | .591 | .724 | .351 | .20 | .95 |
| (ablation: no red-only Kikon) | 0.419 | 10/40 | .663 | .820 | .404 | .24 | .90 |
| + KESSA clone dodge | 0.522 | 19/40 | .720 | .811 | .255 | .429 | .925 |
| + Bankai through `kk-pick` (Hoho in, dodge) | 0.537 | 20/40 | .720 | .714 | .477 | .333 | .925 |
| + AS read in the plans | 0.700 | 30/40 | .720 | .887 | .524 | .533 | .925 |
| **+ climb / bankai 1.0 (final)** | **0.708** | **30/40** | **.720** | .851 | .717 | .429 | .925 |

**Final file, 40 seeds a seat (score.json):** score **0.6536**.
- Strength 0.6625 (HARD 53/80; v0 10/80).
- Signature 0.6477: **brawl 0.706** (1123/1591; v0 0.568), shikai 0.841, bankai 0.711, antiwave 0.333 (5/15).
- NORMAL 0.95 (band 0.863–1.0, factor 1; v0 0.9625).
- Host tests: 9843 checks, ALL PASS.

## Why it is not a repeat
- Every sibling left the sealed form untouched (brawl 0.561–0.568), and none answers her lunge or KESSA's clones.
- Mine is the first to:
  - gate neutral starts by reach against her retreat;
  - stop the generic CPU's whiffed NS chain;
  - Hoho through her lunge / clones as a read (mostly perfect Hohos);
  - apply a red-only Kikon to the generic CPU's own SPs;
  - give the Bankai a reach-gated approach.
- The AS read and the 1.0 knobs are shared with b1 / b2 and credited to them. They multiply the brawl gains: 0.537 → 0.700 with the
  read alone.

## Expected benefit and risks
- Against b1 (0.6558): about the same score by another route, with brawl +0.15 and a different strength profile. **The natural next
  cell combines them**: b1's awakening-once / Kikon pointer policy / L3 SA with this file's sealed discipline and dodge. b3's antiwave
  code is complementary too; antiwave is this file's weakest theme (5/15).
- Risks:
  - **Antiwave** rests on 7–18 situations a run (±0.1 on its rate). The Hoho-in and the dodge use the Hoho lockout (60 f) and FS, which
    the antiwave Hoho (`:close` / `:late`) also wants.
  - **NORMAL** dipped to 0.90 in some 20-seed runs (band floor 0.863). The NORMAL chances (reach 0.3, stop 0.3, red-Kikon 0.3, dodge
    0.1, Hoho in 0.05) are small but not zero.
  - **The dodge relies on her style's timing.** An Ichigo that delays her lunge or baits the Hoho (attacking his reappear point) would
    cut it. The perfect-Hoho rate is a property of her NS3a's slide.
  - **Reading her red bar** (the Kikon rule) has precedent in `cai-sp` and her own style. The coordinator may want it noted for the user.
  - The style now runs the generic CPU's neutral / move step itself so that the Kikon rule applies. This is identical to
    `core-brain-step`'s own call for those states, but a future change there would need mirroring here.

# SOUL DUEL: Ichigo, TYBW look and motion modules (2026-10-14)

Status: **built 2026-10-14** (three batches merged; §6 as built, §7 gates). The plan, §3–§5, is the lead's [G]; the user
delegated the calls, see §1.
Skills: `duel-motion-style` (decide, research, plan, measure, draw), `duel-character-rework` (presentation vs sim, the
proofs), `duel-move-modules` (one grammar a form). Research: `docs/research/ichigo-rework/canon-looks.md` (every visual
state, graded A–D), `canon-motion.md` (fight by fight) and `style-refs.md` (other games' and anime's dual-blade and
greatsword styles, the archetype table, the impact tricks). Earlier design: `DUEL_ICHIGO.md` (v1, v2, the playtest
decisions), `DUEL_STRINGS.md` §2 / §12 / §13, `DUEL_DESIGN.md`.

## 1. The request

> 幫我使用這些新的 skill 改進（千年血戰篇）黑崎一護的造型與動作模組，若有認為需要改到招式與判定就進行更改並回報修改理由與改進方向即可。動作模組可以額外搜尋其他遊戲或動漫作品中雙刀與大劍的戰鬥風格，並以此為基礎進行改進並增加演出魄力。
> (the user, 2026-10-14)

Reading: the look and the motion modules of both forms (the dual Shikai, KESSA) are in scope; the motion research
extends to other games' and anime's dual-blade and greatsword styles, and the goal adds **impact (演出魄力)**. Changes to
moves and hit volumes are allowed when the lead judges them needed, reported with the reason and the direction. No
question round: the skill's "ask first" points are answered by the lead and marked [G]. The user's earlier look
decisions stand (DUEL_ICHIGO "v2: built" → "Both forms: the look", "Playtest look decisions": KESSA from the figures, the
pitch-black 漆黒の月牙天衝, the grey-black phantom clones with a white rim).

## 2. Diagnosis (at 3e078ef; the art viewer's 8-frame strips and the FK tip script)

- **Borrowed clips** (the skill's red flag): KESSA's K1 / K2 / K3 play the Shikai's `:ic-f1` / `:ic-f2` / `:ic-drop`
  (`:clip-s` retimed), posed for two blades; `:ic-drop` alone serves five moves (Shikai K3, KESSA K3, 残月返し, the clones'
  heavy link 3, KAGE-UCHI's strike); `:ic-f1` three (K1, KESSA K1, the clones' heavy); `:ic-cross` three (KOGA K2s, SŌGA at
  ×0.39, the JŪJI rush's strike), so SŌGA's 5 m flash-step lunge is drawn as a standing X.
- **The cleaver in the floor**: the right blade's tip goes under the plaza in 15 of `:ic-q1`'s 22 frames, 12 of `:ic-q2`'s,
  28 of `:ic-drop`'s, 27 of `:ic-mine`'s, 18 of `:ic-tsuki-otoshi`'s, 11 of `:ic-f2`'s (down to −0.8 m); during the J links
  the cleaver hangs point-down into the ground ahead of him. KESSA's idle holds Tensa's end 0.37 m under the floor the whole
  loop (every KESSA clip starts there).
- **One arc plane, one hand set**: K3 RAKUGA and TSUKI-OTOSHI are both two-handed overhead drops; K2 SHŌGA and the
  GETSUGA are both the right hand rising; MINEUCHI repeats K1's horizontal right-hand sweep; J1 / J2 are the same
  horizontal left-hand flick and its return.
- **Drawn reach vs the hit volume** (tip at the hit frame vs the volume's edge): K2 SHŌGA −2.15 m (the blade straight up
  overhead at S), K3 −0.70, K1 −0.37; RANGETSU's four slashes −1.5 to −1.9 (the reversed short blade at 0.5–0.9 m for a
  2.4 m arc); MINEUCHI −0.69; KESSA K1 −0.50, K2 −2.33, K3 −0.84. The J's short blade 1.2 m for a 1.4 m edge (reversed
  grip).
- **Stiff**: the hit poses are held arms on a planted stance; no anticipation squat on the J's, no follow-through past
  the hit pose, the K's recover by snapping to the idle; turns are chest twists; the cross hit pose hides both blades
  edge-on from the behind camera.
- **Impact**: no tell or hold beyond the sim's hitstop, no ground reaction on the drops, the cleaver never rests or carries
  its weight (it is waved like a stick).
- **Look vs canon** (canon-looks §1–§2, the RoS key art `ros_tybw_img_ill`): the short blade is held **reversed** along the
  forearm, 0.5 m, a plain slab (canon: a **forward grip** in the left hand, a straight slab ~0.7 m (manga) to ~1.0 m (anime,
  RoS) whose handle is a closed loop cut in the blade's frame); the long blade is a constant-width slab with a 0.32 m hole
  (canon: a khyber-knife profile widening to a swept, curved point, a slender slit along the spine, a stepped spur, a
  0.28 m wrapped grip); the TYBW outfit's pieces are missing (the white X across the chest, the white left pauldron with
  three red-scale panels, the red-scaled plate at the right hip, the white waist cloak with black slash marks hanging to
  the knees, black wristbands). Canon cuts are **one-handed** (two hands only on the true Bankai): K3's two-handed drop
  has no source. Jūjishō crosses the blades low in front and cuts short-then-long (the clip draws them crossed behind him).
  Kept as the user's decisions (not canon): the flat horn swept sideways in both forms, KESSA's look from the figures.

## 3. Decisions [G] (the lead's, for the user to review in play)

### 3.1 The look (presentation only)

| Part | Now | After |
|---|---|---|
| Short blade (Shikai, left) | 0.5 m, reversed along the forearm | **forward grip**, a straight black slab **0.85 m** with a white edge, its handle a closed loop round the fist with a white wrap (canon's trench-knife frame); between manga and anime length |
| Long blade (Shikai, right) | constant 0.24 m slab, a 0.32 m hole | the same 1.55 m length (the reach stays): a khyber profile, 0.18 m at the root widening to ~0.26 m, the edge sweeping up into a curved point; a slender slit along the spine from the root to mid-blade; a stepped spur on the spine side at the root; the 0.28 m wrapped grip with its loose cloth end |
| Outfit (Shikai only, `:tag :shikai`) | the plain shihakushō | the white X across the chest (two 0.07 m bands), the white left pauldron with three dark-red scale panels (#6E1A1C), the red-scaled plate at the right hip, black wristbands, **the white waist cloak**: two long panels from the sash to the knees, torn ends, black slash marks, **swinging** (a damped spring on his travel and turns, as Yamamoto's hem: a cosmetic `:pose` / `:draw` hook, no random numbers) |
| KESSA | the user's figures | unchanged; only the idle's blade off the floor (§3.2) |

### 3.2 The motion bars (style-refs §4–§6, canon-motion; no two strikes of a form share an arc plane and a hand set)

Archetypes. **Shikai**: Musashi's "the long cuts, the short controls" (the short blade aims and parries while the cleaver
winds up), J a fast short-blade dance, K a momentum maul (the cleaver's weight carries past the target, Berserk / Monster
Hunter), the switched links and the stance's finishers the cross; the cleaver rests on the right shoulder between strikes
(Cloud, Siegfried; canon cocks it there for the Getsuga). **KESSA**: the maul one-handed for J and two-handed for K, a
charge-ladder K3 wrapped in chains, the counter a grab-and-cut (canon ch. 618 / 676); one slab without a point: no
thrusts, no cross.

| Slot | Shikai (cleaver R, short blade L) | KESSA (the slab R, chains L) |
|---|---|---|
| idle | the cleaver on the right shoulder, the short blade aimed at his face at chest height (T8, T10) | the slab hanging point-down across the legs, its end just off the plaza (ep. 45 still) |
| J1 | short blade, horizontal L→R, a step in | one hand, a chop ↘ |
| J2 | short blade, a rising backhand ↖ | one hand, a rising backhand ↗ |
| J3 | both: a full turn (a key every 90°), the cleaver swung off the shoulder high, the short blade low | one hand: a spin, the slab level |
| K1 | cleaver: a waist-high sweep R→L off the shoulder, a deep step, the free hand flung back, overshoot past the target (canon Ep396) | two hands: a full-body bat swing L→R |
| K2 | cleaver: the point dragged along the plaza behind, a rising diagonal ↗ with the arm fully out (ch. 614); the hit pose ahead at ~30° up (not overhead), a held top | two hands: dragged, a rising diagonal ↗ |
| K3 | cleaver one-handed: an anticipation coil, a hop forward, the overhead **vertical drop into the plaza** (ch. 660, Ep409), the short blade flung back for balance; a landing crouch (**a real step: §3.4**) | two hands: the slab held level overhead (the Berserk wind-up), chains wind round it, the vertical drop (**a real step: §3.4**) |
| J2s KAESHI-KIBA | the cleaver still out from K1, the short blade **thrust** under it (an X silhouette) | — |
| K2s KŌGA | both: a rising X that opens upward | — |
| L | the stance 月待: side-on, the short blade aimed level at his face (RoS 朔望 「前方に刀を向けて構え」), the cleaver cocked high behind the right shoulder | the parry 鎖盾: the slab vertical before him (kept), the end off the floor |
| L branches | RANGETSU: the lunge, four cuts **alternating the blades** (short ↘, cleaver backhand ↗, short ←, both blades level for the stagger); TSUKI-OTOSHI: a leap, both blades slammed down parallel; GETSUGA: from the shoulder cock a one-armed **diagonal ↙ fling** (the classic Getsuga swing, the shout) | 残月返し: the left hand grabs his wrist, a one-hand vertical drop (ch. 618 / 676) |
| SP1 | JŪJISHŌ: the blades crossed low in front, arms flung wide; the short blade sweeps level (the first crescent, f12), the cleaver comes overhead and down (f20) | KUSARI-BIKI: the chain cast from the left fist, then a lean back, both feet braced, reeling (T15) |
| SP2 | SŌGA: the flying lunge (the body near level, the cleaver high behind, the short blade low ahead: Ep394), a descending X, the arms ending flung open (T11) | 残像: the slab swept flat before his face (kept, off the floor) |
| I (Breaker) | MINEUCHI: the cleaver's flat shoved forward like a shield, the left forearm braced on its spine (Monster Hunter's guard tackle, T7) | the same |
| O strike | JŪJI: the blades crossed before him, scissored open outward | KAGE-UCHI: a leaping one-hand diagonal ↙ |
| clones | — | the heavy plays KESSA K1's clip (link 3: K3's), the light keeps `:ic-k-cut` / `:ic-k-wrap` (KESSA's own clips retimed, never the Shikai's) |

Plane and hand: Shikai J1 horizontal L, J2 diagonal-up L, J2s thrust L, J3 spin both, K1 horizontal R, K2 diagonal-up R,
K3 vertical-down R, KŌGA rising X both, RANGETSU alternating, TSUKI-OTOSHI vertical-down both, GETSUGA diagonal-down R,
JŪJISHŌ level L then vertical R, SŌGA descending X both, MINEUCHI a shove both, JŪJI a horizontal scissor both. KESSA J1
diagonal-down one hand, J2 diagonal-up one hand, J3 spin one hand, K1 horizontal two hands, K2 diagonal-up two hands, K3
vertical-down two hands, 残月返し vertical-down one hand after the grab, KAGE-UCHI diagonal-down ↙ one hand.

### 3.3 Impact (演出魄力; style-refs §5, the tricks T1–T15)

In the clips: an anticipation coil inside every K's startup (T1), the hit pose held to the end of the active frames (T2),
overshoot and a settle key in the recovery (T4), a body spin feeding the cut with a key every 90° (T9), the short blade
aimed while the cleaver winds up (T10), SŌGA's open-armed finish (T11), the blade dragging the body in the lunges (T13);
turns with root yaw and a pelvis roll; the hit pose on S. Looks (cosmetic, his `:draw` hook; the sim never reads them):

- **月牙の残光, the crescent edge** (T3): on the hit frames of his Flash, Signature and SP strikes (and each RANGETSU cut) an
  ink crescent sweeps from the drawn tip along the cut to the hit volume's edge (mono like the in-play Getsuga: ink with
  a white rim; KESSA's with a BLOOD hairline). Canon: his swings shed reiatsu, and the short blade fires a small Getsuga
  (ch. 583, RoS). It closes the drawn-reach gaps no clip can (RANGETSU's short-blade cuts on a 2.4 m arc).
- **Ground contact** (T5, T6): K3, TSUKI-OTOSHI, KESSA K3 and 残月返し crack the plaza where the blade lands (the shared
  `stage-mark :crack` and `stage-debris`) with a short camera shake.

### 3.4 Moves and hit volumes (the sim)

- **K3 RAKUGA and KESSA K3 TENSA-OTOSHI step in**: the canon drop is a hop forward, so the drawn body travels about 1 m.
  Drawing that without moving the fighter makes him snap back 1 m after the hit; so each gets a real 1.0 m step (`:slide 1.6`: both K3s enter at f7 and slide only over f8–f20, as built §6.2) and its
  capsule shortens by the same 1.0 m (Shikai cap 0.3 → 3.0 becomes 0.3 → 2.0; KESSA 0.3 → 3.2 becomes 0.3 → 2.2): the
  effective reach (edge + slide) stays 3.35 / 3.55 m, the blade lands where the volume ends. Frame data, damage and
  reactions unchanged.
- Everything else is presentation: the clips reach their volumes (the FK ±0.15 m), the crescent edge covers RANGETSU.

## 4. Build (batches, each in its own worktree; the lead merges, re-runs every check and gates)

1. **ic-look**: the blades and the outfit (§3.1), the cloak's spring, the `:draw` hook's crescent edge and ground contact
   (§3.3, keyed by move name).
2. **ic-shikai**: the Shikai clips (§3.2 left column), K3's step (§3.4).
3. **ic-kessa**: KESSA's own clips (§3.2 right column), the clones' and the counter's and KAGE-UCHI's clips, KESSA K3's
   step.

Checks: host tests (the FK test, with the short blade's tip for the J's), pkgcheck, `./build.sh duel`, 8-frame side and
front strips per clip (`tests/duel-view.lisp` scene 9), the tip report, 0 B/frame for the new draw paths; batch 1
byte-identical sim (`simgate --seeds 10` + `--cvc`); batches 2–3 gated against the baseline below.

## 5. Baseline (3e078ef, 20 seeds, match time without cinematics)

IY 110.7 s (Ichigo 7 / 20), IK 106.0 (11), IR 121.3 (8), II 140.6 (P1 10 / P2 10), SI 139.5 (Ichigo 16), BI 157.9
(Ichigo 14); all 120 K.O. Ichigo's awaken A/B (never awakening, of 60; seed0 100 / 300 / 500): IY 14 / 19 / 26, IK 12 /
10 / 8, IR 9 / 12 / 17, II 21 / 20 / 17, SI 27 / 23 / 21, BI 11 / 19 / 11 (an open item since 2026-09-29, AGENTS).

## 6. As built

### 6.1 As built: look (batch ic-look, 2026-10-14; presentation only)

- **Short blade** (`:weapon-l` parts, `:tag :shikai`, the batches' contract): a forward grip, a straight black slab 0.13 m
  wide from y −0.05 to the point at (0 −0.90 0); the spine (a 0.06 m ridge, so it reads edge-on without the old crossed
  boxes) in line with the fist at z 0, the slab out to the white edge on the joint's +Z; the end clipped from the edge up
  to the point; the handle a closed black loop round the fist (bars at z −0.05 / +0.10, a top bar at y 0.125) with a
  white-wrapped bar through it.
- **Long blade** `:zangetsu-long` (`:length 1.55`, `:base 0.4` unchanged): a khyber profile built span by span (SLAB):
  the spine straight, 0.18 m at the root → 0.26 m at y 1.25, the edge sweeping up into a curved point on the spine; a
  0.03 m slit along the spine y 0.08–0.72 (the 0.32 m hole gone); a stepped spur on the spine side at the root; a thin
  white edge; the 0.28 m off-white wrapped grip and its loose cloth end kept.
- **TYBW outfit** (all `:tag :shikai`, so KESSA hides it; KESSA's look and the horn untouched): the white X (two 0.07 m
  bands front and back, straps over the shoulders); the white left pauldron (a shell on `:shoulder-l`, a plate down the
  outside of `:upper-arm-l`; three red-scale panels `:scale` #6E1A1C with `:scale-d` #461013 lines); the red-scaled
  plate at the right hip; black wristbands; the white waist cloak (`:cloak` #F0EEE8): the tied band over the sash, a
  knot and two ends at the front, 12 thin facets round the hips from 46° off the front to the back (open front), flared
  9°, ragged lengths to the knee (−0.44 … −0.56 m under the pelvis), a torn tooth under each, 6 black slash marks. New
  palette keys: `:cloak :scale :scale-d :wrap-w`.
- **The cloak swings** (`:pose ichigo-cloak-pose`, Shikai only): the pelvis matrix (the cloak, the sash, the hip plate
  and the hakama skirt hang on it) swings about the obi by Yamamoto's hem spring, reused as is (`%ya-hem-pose` /
  `%ya-hem-step`, its knobs `*ya-hem-k*` 60 /s² (~1.2 Hz), `*ya-hem-c*` 4.6 /s (~0.3 of critical: one overshoot on a
  stop), `*ya-hem-drag*` 0.03 rad per m/s of travel, `*ya-hem-turn*` 0.05 rad per rad/s of turn, `*ya-hem-max*`
  0.42 rad; a slow breath while standing). The legs are their own joints, so a side still keeps the stride readable; the
  hakama skirt trailing with the cloak reads as cloth. A separate tune would need its own knobs: none added.
- **Impact looks** (`:draw ichigo-draw`, both forms; `*ic-edge-moves*` / `*ic-ground-moves*` keyed by move name, so a
  clip change needs no code change): 月牙の残光, an ink lens from the drawn tip (the short blade's point for RANGETSU's
  hits 1 and 3, else the held blade's) to the hit volume's edge (an arc's rim on the tip's bearing, a capsule's end, a
  sphere's far side; height the tip's, 0.1–1.5 m), grown over the 2 f before the window to reach the edge on its first
  frame, held through it, fading over the 4 f after; bulging along the tip's travel (`*ic-edge-bulge*` 0.28 of the
  span), half-width `*ic-edge-w*` 0.12 of the span (0.08–0.2 m); a white rim (KESSA: a BLOOD hairline). Moves: K1 K2 K3
  K2s RANGETSU TSUKI-OTOSHI SŌGA the Kikon's strike MINEUCHI; KESSA K1 K2 K3 残月返し KAGE-UCHI (the clones' `:ic-c-*`
  are listed but drawn by ICHIGO-CLONE-LOOK, which has no hook: none). Ground contact on the first hit frame of K3,
  TSUKI-OTOSHI, KESSA K3, 残月返し: `stage-mark :crack` r 0.9 + `stage-debris` 4 + `shake 0.06 0.15` where the tip meets
  the plaza (under 0.4 m) or at the volume's far point, once a move (the move frame kept per side).
- **Consing**: debug 74906 (`ichigo-look-cons-check`, after 74000): 10 calls each, pose 0 B, draw (standing) 0 B, draw in
  K1's hit frame 0 B, in RANGETSU's 0 B. (Two traps found: a float passed to a function is boxed, e.g. JOINT-POINT!'s
  `(- len)` in BODY-WEAPON-TIP, and the inline F32 re-boxes; both kept out of the per-frame path.)
- **Proofs**: the sim is byte-identical (`simgate --pairs 6,9 --seeds 10` and `--cvc` equal to the base commit's); host
  tests ALL PASS, pkgcheck clean, no new build warning.

### 6.2 As built: Shikai clips (batch ic-shikai, 2026-10-14)

Every Shikai clip rebuilt to §3.2's left column with §3.3's in-clip tricks; each strike's (S A R) equals its move
(KŌGA's `:ic-cross` is authored at its `:clip-s 14`, played ×0.7); the hit poses were solved on the rig's FK (a coordinate
search over the arm channels with a pull toward a natural wrist), then checked in 8-frame side and front strips.

- **Idle** `:ic-stance`: the cleaver on the right shoulder (the grip at the shoulder's front, the blade back and up at
  ~35°, its edge up), the short blade held **forward** and aimed at his face from chest height (the tip 1.43 m up, 1.39 m
  ahead), the left side leading; a breathing loop. Every Shikai strike starts and ends there; the J links never take the
  cleaver off the shoulder.
- **The short blade's convention** (the contract): it runs down `:weapon-l`'s −Y, so at hand flex 0 it carries on the
  forearm's line; its tip is `(joint-point :weapon-l 0 −0.90 0)`. The FK test's `*strikers*` takes a `(clip joint y)`
  entry for it: `:ic-q1`, `:ic-q2`, `:ic-cross-j` (J2s is a short-blade thrust now).
- **New clips**: `:ic-soga` (SŌGA: launch, flown near level with the body pitched 50°, the cleaver high behind and the
  short blade low ahead, both raised, the descending X at S, the arms flung open on the last active frame; 18/4/26) and
  `:ic-juji-x` (the JŪJI rush's strike: the blades crossed before him, pulled in, scissored open level; 7/3/24).
  `:clip-s` dropped from SŌGA and the O. The Shikai Kikon cinematic's beat 0 holds `:ic-juji-x` (it held `:ic-cross`).
- **Impact tricks in the clips**: a coil inside every K's startup (K1 wound back to his right with the short blade
  aiming, held 3 f; K2 a crouch over the dragged point; K3 a crouch and a hop), carry-through past the hit and a settle
  key in every K's recovery, J3 keyed every 90° of its turn (f4 / 5 / 6 / 7 / 8) with a pelvis roll, the hit pose held
  through the active frames.

**K3's step (§3.4)**: `:ic-k3` `:vol (:cap 0.3 3.0 1.2 0.35)` → `(:cap 0.3 2.0 1.2 0.35)` and **`:slide 1.6`** (not 1.0:
K3 starts at `:enter 7` and MAIN-PHASE-STEP slides `slide / S` per frame on frames 8–20 only, so 1.0 would travel 0.62 m;
1.6 travels 0.99 m, keeping §3.4's edge + step = 3.35 m). The clip's root `:f` is the drawn hop minus that slide: −0.18 at
the coil (f11), +0.09 at the hop's top (f15, root up 0.22), +0.32 on landing (f19), +0.30 at S, 0 at the end, so the body
travels ~1.3 m in the world without a snap back (when he is already inside `*lunge-stop*` and doesn't slide, the coil
reads as a rock back). The blade lands at 2.34 m ahead, 0.09 m up.

Drawn tip at the hit window vs the volume's edge (before: 3e078ef; J's then the fist, the blade reversed; after: the
short blade's tip for J1 / J2 / J2s, the cleaver's tip otherwise):

| Move (clip) | edge | before | after |
|---|---|---|---|
| J1 KOKIBA (`:ic-q1`) | 1.40 | 1.21 (fist) | 1.42 (short tip) |
| J2 KAESHI (`:ic-q2`) | 1.40 | 1.20 (fist) | 1.40 |
| J2s KAESHI-KIBA (`:ic-cross-j`) | 1.40 | 1.32 (cleaver) | 1.47 (short tip; the cleaver held out at 1.80) |
| J3 SŌSEN-GIRI (`:ic-spin`) | 1.44 | 1.48 | 1.53 |
| K1 ŌKIBA (`:ic-f1`) | 2.70 | 2.33 | 2.68 |
| K2 SHŌGA (`:ic-f2`) | 2.70 | 0.55 | 2.58 |
| K2s KŌGA (`:ic-cross` ×0.7) | 2.70 | 2.51 (its hit pose was at move f10) | 2.56 |
| K3 RAKUGA (`:ic-drop`) | 3.35 → 2.35 | 2.65 | 2.34 |
| O JŪJI strike | 2.60 | 2.56 (`:ic-cross`) | 2.55 (`:ic-juji-x`) |
| SP2 SŌGA | 2.60 | 2.55 (`:ic-cross` ×0.39) | 2.61 (`:ic-soga`) |
| RANGETSU hits 1–4 | 2.40 | 1.17 / 1.11 / 1.17 / 1.17 | 1.63 (short) / 2.29 (cleaver) / 1.64 (short) / 2.44 (cleaver) |
| TSUKI-OTOSHI | 2.60 | 2.27 | 2.55 |
| MINEUCHI (Breaker) | 1.35 | 0.66 | 1.01 (the flat shoved, point up: short by design) |

Under the plaza (cleaver tip / short-blade tip, frames): before `:ic-q1` 15, `:ic-q2` 12, `:ic-drop` 28, `:ic-mine` 27,
`:ic-tsuki-otoshi` 18, `:ic-f2` 11, `:ic-juji` 2, `:ic-awaken` 18; after **0 in every Shikai clip** (K3's blade stops at
0.01 m at f23, TSUKI-OTOSHI's at 0.04). The ankles: crouch keys raised to keep the lower ankle ≥ −0.03 m.
`:ic-cero-raise` unchanged; `:ic-awaken` (minimal: the right arm 45° forward at its first key, the left wrist at 0.9 s
turned for the forward blade); `:ic-win`, `:ic-intro`, `:ic-breaker` checked (the Breaker's short blade trails up).
`:ic-drop` left `*grip-clips*` (one-handed now).

Known issues: KESSA's K1 / K2 / K3, the clones' heavies, 残月返し, KAGE-UCHI and KESSA's two cinematics still play
`:ic-f1` / `:ic-f2` / `:ic-drop` (the ic-kessa batch repoints them; until then they show the Shikai motions with Tensa,
and the cinematics' `:ic-drop` frames 17–20 are the hop's top and the swing over); the short blade's look is ic-look's
(the strips used a stand-in box); several solved wrists are unusual numbers (e.g. SŌGA's flight arm flex 200 / side −60,
MINEUCHI's hand twist −114): checked by numbers and in strips, needs the user's eyes.

Checks: host tests ALL PASS (duel-rules 6976, control 89, cine 18, learn 131), pkgcheck 0 / 0 / 0, `./build.sh duel` (no new
warnings), smoke exit 0. Sim (K3's step and capsule are the only sim change): `simgate --pairs 6,7,8,9,14,24 --seeds 10`
all 60 K.O.; medians IY 121.2 s (Ichigo 3 / 10), IK 106.5 (6), IR 122.3 (5), II 130.8 (P1 4 / P2 6), SI 146.0 (Ichigo 8),
BI 157.9 (Ichigo 9); against §5's 20-seed baseline 110.7 / 106.0 / 121.3 / 140.6 / 139.5 / 157.9 (IY, IK, IR were under
125 s before the change). The 20-seed verdict and the awaken A/B are the lead's, after the merge.

### 6.3 As built: KESSA clips (batch ic-kessa)

Every KESSA clip is now its own, at its move's own frames, starting and ending on `:ic-k-stance`; KESSA plays none of the
Shikai's clips (K1 / K2 / K3, 残月返し, KAGE-UCHI and the clones' heavy were `:ic-f1` / `:ic-f2` / `:ic-drop` with
`:clip-s`). Hit poses were solved from the drawn tip (an FK solver over the art: the tip's position and the slab's
direction per key, each key seeded from its neighbour so the in-betweens travel the arc), then checked on 8-frame side and
front strips (`tests/duel-view.lisp` scene 9).

- **Idle** `:ic-k-stance`: the slab hangs forward across his legs, its end 0.07 m off the plaza (was 0.37 m under it).
- **J1** `:ic-k-jab` (8/3/12): cocked over the left shoulder (f3), up and over (f6), a one-hand chop ↘ down across him
  to his right, the slab steep at S, a step in. **J2** `:ic-k-back` (8/3/13): dragged low across to his left, the flat
  turned, a one-hand rising backhand ↗, carried high right. **J3** `:ic-k-wrap-j` (9/3/18, its `:clip-s 10` gone): wound
  right, a full turn left with a key every 90° (root yaw −22 / 68 / 158 / 250 / 360, a pelvis roll), the slab level and
  close, whipped across the front on S. The clones' light links keep the long versions of the same shapes,
  `:ic-k-cut` (the chop with a lunge) and `:ic-k-wrap` (the turn at arm's length, now 9/3/18 like its move).
- **K1** `:ic-k-f1` (18/4/20, new): both hands (`*grip-clips*`), gathered, coiled behind the left shoulder (f12, held
  deeper to f15: the tell), released, a full-body bat swing L → R through the front on S with a deep right-foot step,
  carried past him to the right (f27), settled. **K2** `:ic-k-f2` (20/4/24, enters f6, new): both hands, the end trailing
  behind him low to his left (f6–f12), rising, a diagonal ↗ through the front on S, held high (f30). **K3** `:ic-k-f3`
  (21/5/34, enters f7, new): both hands, the slab lifted level overhead (f11, the Berserk wind-up), held while stepping
  (f15), turned up behind his head (f18), over the top (f20), level ahead on S at the line's end, down to just off the
  plaza (f26, 0.03 m), held to f34. The ic-look batch's chains / cracks go on these poses.
- **残月返し** `:ic-k-gaeshi` (6/3/22, new): the left hand grabs ahead at wrist height (f2), the slab straight up (f4),
  the one-hand vertical drop on S, the grab hauled to his hip. **KAGE-UCHI** `:ic-k-uchi` (7/3/24, new; the Kikon's
  clip 2): a leap (the feet 0.5 m up), cocked over the right shoulder, a one-hand diagonal ↙ as he comes down, a landing
  crouch, the slab low left. **KUSARI-BIKI** `:ic-k-yank` (16/3/24, its own frames, the `:clip-s 6` gone): the left fist
  cocked back (f5–f11, held), thrown at him (f14), the arm straight on S, then a lean back with both feet braced, the fist
  reeling to the hip (f24–f31). **残像** `:ic-k-zanzo`: the same sweep, now level (it went 0.49 m under the plaza); the
  parry `:ic-k-parry`: unchanged but for the idle.
- The clones: `:ic-c-heavy` plays `:ic-k-f1` (`:clip-s 18` for its S16), `:ic-c-heavy3` plays `:ic-k-f3` (`:clip-s 21`
  for its S18). KESSA's cinematics play his clips too: 千影's beat 0 holds KAGE-UCHI's hit, its clones charge on
  `:ic-k-f1` / `:ic-k-f3` / `:ic-k-cut`, the Soul Break holds K3's level overhead (f13) and drops from f17.

**K3's step (the sim change, §3.4)**: `:ic-k-k3` `:vol (:cap 0.3 3.2 1.2 0.35)` → `(:cap 0.3 2.2 1.2 0.35)` and
`:slide 1.6` (the batch built it with 1.0; the lead raised it at the merge to match RAKUGA, §6.2: the move enters at
f7 and slides over f8–f20 only, 13 × 1.0 / 21 = 0.62 m with 1.0, 0.99 m with 1.6; less if he reaches `*lunge-stop*`); the clip draws the stride (the right foot lifted 0.18 m at f18, planted on S) and a 0.25 m lunge into the
hit, not the travel, so nothing moves twice. The drawn body travels about 0.9 m and the slab lands at the line's end
(2.55 m) on S. Frame data, damage, reactions unchanged. The clones' heavy3 keeps its volume (3.75 m) and stands in place:
it plays the same clip, so its drawn tip is 1.2 m short of its line (it was 1.04 m short on `:ic-drop`).

| Move | Edge | Tip at S, before → after |
|---|---|---|
| J1 / J2 / J3 | 1.56 / 1.56 / 1.68 | 1.62 / 1.62 / 1.74 → 1.62 / 1.63 / 1.69 |
| K1 / K2 | 2.90 / 2.90 | 2.40 / 0.57 (overhead) → 2.92 / 2.81 |
| K3 | line 3.55 → **2.55** | 2.71 → 2.55 |
| 残月返し / KAGE-UCHI | 3.00 / 2.80 | 2.72 / 2.72 → 2.93 / 2.75 |
| clones heavy / heavy3 | 3.00 / 3.75 | 2.40 / 2.71 → 2.92 / 2.55 |
| clones light / light3 | 2.40 / 2.80 | 2.25 / 2.57 → 2.36 / 2.76 |

The floor: 0 frames under the plaza in every KESSA clip (was: the idle all 145 frames, `:ic-k-zanzo` 26, `:ic-k-wrap` 13).
Checks: the host tests ALL PASS (rules 6976, control 89, cine 18, learn 131; the FK test's J two-sided ±0.15 m), pkgcheck
clean, `./build.sh duel` (only Lille's 4 style warnings), the smoke run clean. `simgate --pairs 6,7,8,9,14,24 --seeds 10`
(the baseline at dbcffd6 → now, median s, Ichigo's wins): IY 117.0 → 117.0 (3 → 4), IK 106.5 → 106.5 (6 → 6), IR 122.3 →
121.3 (5 → 6), II 130.8 → 130.8 (P1 4 / P2 6 → 5 / 5), SI 146.0 → 155.0 (8 → 8), BI 157.9 → 145.5 (9 → 8); all 60 K.O.
(IY and IK sit under 125 s as before the change.)

Known: KESSA K2's hit pose reads close to a level thrust from the side camera (the rise shows from the front and over
A); the clones' heavy3 is drawn 1.2 m short; the left fist rides the handle by GRIP-LEFT! through each K's recovery and
lets go only after the clip (0.1 s); KUSARI-BIKI's slab is held level at his hip during the cast. Checked by numbers,
needs the user's eyes.

## 7. Gates (merged build 2d583ac, 2026-10-14)

- Host tests: duel-rules-test 6976 (the FK test with the short blade's tip for the J's), duel-control-test 89, cine-test
  18, learn-test 131, ALL PASS; pkgcheck clean; `./build.sh duel` (the 4 style warnings in Lille's files, as before);
  the browser smoke run without errors. Tip report on the merge: every Shikai and KESSA strike's drawn tip within ±0.15 m
  of its edge or short by design (MINEUCHI −0.34, RANGETSU's short-blade cuts covered by the crescent edge); J2s's cleaver,
  held out from K1, is drawn 0.4 m past the J's 1.40 m edge (the hit is the short blade's thrust). Floor: no clip puts a
  blade under the plaza (KESSA's spins 1 frame at −0.05 m).
- **20 seeds** (all 120 K.O.; baseline §5 → now, median / Ichigo's wins): IY 110.7 → 110.7 s (7 → 6), IK 106.0 → 106.0
  (11 → 11), IR 121.3 → 114.2 (8 → 8), II 140.6 → 141.2 (P1 10 / P2 10 → 12 / 8), SI 139.5 → 140.6 (16 → 16), BI 157.9 →
  143.6 (14 → 14): every row within the seed noise of the baseline. IY / IK / IR sit under 125 s as they did before.
- **G2**: identical (`simgate --cvc` PASS on yy / yk / kk; Ichigo plays none of them).
- **Awaken A/B** (Ichigo never awakens; seed0 100 / 300 / 500, of 60; baseline in brackets): IY 13 / 17 / 27 (14 / 19 /
  26), IK 12 / 10 / 7 (12 / 10 / 8), IR 9 / 13 / 16 (9 / 12 / 17), II 14 / 22 / 13 (21 / 20 / 17), SI 26 / 22 / 21 (27 /
  23 / 21), BI 12 / 18 / 11 (11 / 19 / 11). The same rows fail as before (an open item since the user cut his damage,
  2026-09-29, AGENTS): not this change's.
- **Looks**: not run (the change is meant to move his pixels; the random-driven particles of other scenes shift as with
  Yamamoto, §7 of DUEL_YAMA_TYBW).


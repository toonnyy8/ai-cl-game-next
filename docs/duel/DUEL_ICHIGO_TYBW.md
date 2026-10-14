# SOUL DUEL: Ichigo, TYBW look and motion modules (2026-10-14)

Status: **plan** (§1–§5). The plan is the lead's [G]; the user delegated the calls, see §1.
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
  Drawing that without moving the fighter makes him snap back 1 m after the hit; so each gets a real `:slide 1.0` and its
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

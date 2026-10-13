# SOUL DUEL: Yamamoto, TYBW look and motion modules (2026-10-13)

Status: **built 2026-10-13** (three batches merged; §6 as built, §7 gates). The plan, §3–§5, is the lead's [G]; the user
delegated the calls, see §1.
Skills: `duel-motion-style` (decide, research, plan, measure, draw), `duel-character-rework` (presentation vs sim, the
proofs). Research: `docs/research/yamamoto-rework/canon-looks.md` (every visual state, graded A–D, a model checklist per
state, the conflicts table) and `motion-refs.md` (fight by fight, the RoS / Brave Souls kits, the archetype table, the
motion bars per form). Earlier design: `DUEL_YAMA_REWORK.md` (East / West by U), `DUEL_STRINGS.md` §3, `DUEL_DESIGN.md`.

## 1. The request

> 幫我使用這些新的 skill 改進（千年血戰篇）山本總隊長的造型與動作模組，若有認為需要改到招式與判定就進行更改並回報修改理由與改進方向即可。
> (the user, 2026-10-13)

Reading: the look and the motion modules of every form are in scope. Changes to moves and hit volumes are allowed when
the lead judges them needed, reported with the reason and the direction. No question round: the user handed over the
calls. The skill's "ask first" points are answered by the lead below and marked [G].

## 2. Diagnosis (at e4b0f2f; art viewer strips and the FK tip script)

- **Borrowed clips** (the skill's red flag): East J1 / J2 / K1 / K2 play the Shikai's `:ya-q1` / `-q2` / `-f1` / `-f2`
  sped up ×1.13–1.16, so East's whole J1–K2 reads as the Shikai. Base K3 plays the retired Q3 clip at ×0.545 (the snap
  smears, the clip is cut at f61). SENKO and KYOKKO share `:ya-e-thrust`. TENCHI in play is J1's chop ×1.5, while its
  own clip plays only in the cinematic. The L `:ya-sig` is three copied hit poses (K1's, J2's, Q3's).
- **One arc plane dominates**: eight clips raise the blade overhead and chop it to the floor (q1, q3, enjo, kyoku,
  e-drop, the L's third beat; kaka and shonetsu share the wind-up). Base J1 / K3 and East J1 / K3 share plane and hand;
  J2 and J3 are both L→R horizontals.
- **Stiff**: every strike is the same 8-key template; turns are chest-only over a fixed pelvis, no root yaw (only J3
  turns the pelvis); the feet stay planted; the haori is rigid boxes and never trails.
- **Drawn reach vs hit volume** (tip at the hit frame vs the volume's edge): Shikai K1 / K2 / K3 short by 0.94 / 1.47 /
  1.56 m, the L's cuts 0.97; East K1 / K2 short by 2.98 / 3.04 m (thin 3.4 m lines ahead, drawn as a side sweep and an
  upward cut), East K3 1.81, TENCHI 1.13, the West counter 1.22, IKKOTSU 0.58; East J1 HIZASHI 0.34 (the only J outside
  ±0.15 m; the FK test checks East one-sided). K2 and the West counter hold the blade overhead at the hit frame; NADEGIRI's
  tip is 1.5 m to his right while its line runs ahead.
- **Look vs canon** (canon-looks §1–§4, §8): the haori is worn as a shell over the torso (canon: draped like a cape,
  empty sleeves hanging, purple lining `#441F58`, 一 in a rhombus); the beard has one cord (canon: a lattice of 4–6
  crossings); every TYBW battle still shows the black robe with ragged edges and no haori; the serious state bares a
  wiry, scarred torso; West's flames are orange tongues that wing out from the shoulders (repo: red); East's blade has a
  thin smoke thread from the tip.

## 3. Decisions [G] (the lead's, for the user to review in play)

### 3.1 The look per form (presentation only)

| Form | Look |
|---|---|
| Base (Shikai) | the haori **draped over both shoulders as a cape**, its empty sleeves hanging, purple lining, 一 in a rhombus on the back, slit hem; a lagging hem (cosmetic secondary motion). Beard bound by a lattice of 4–6 cord crossings; brows to the jaw; the X scar on the right of the crown; wiry, not broad |
| Hellfire | **bared to the waist** (canon's "serious" state, ch. 155 / 394): the kosode top folded down at the obi, its sleeves hanging behind; a lean scarred torso; the scars glowing red-orange (anime) |
| Bankai East / West | the **TYBW battle dress**: no haori, the black robe with ragged sleeve and hem tatters, the empty left sleeve swinging; East's charred blade with a thin smoke thread from the tip |
| Bankai West | orange tongue flames from the feet up, flaring into two shoulder "wings" at peak, a molten ring at the feet |

### 3.2 The motion bars (motion-refs §5; no two strikes of a form share an arc plane and a hand set)

| Slot | Shikai (base / Hellfire) | Bankai East / West |
|---|---|---|
| idle | the old man's slouch, point resting ahead like the cane | upright, blade low point-down, the smoke thread |
| J1 | S1 the unmovable pivot: a wrist snap ↘, the feet stay, the eyes open on S | E1 a deep fencer's lunge, a level cut at face height R→L |
| J2 | S2 the return flick ↗, elbow leading | E2 from the lunge a rising backhand ↗, standing as it rises |
| J3 | S3 the burning empty sleeve L→R, the hips turning into it | E3 an underhand rising thrust from a dropped knee |
| K1 | S4 the flame wave: a waist-high sweep R→L with a step, the haori flaring | E4 a one-armed diagonal ↘ from over the shoulder |
| K2 | S5 the blade dragged low, raised straight up, a flame column | E5 the sunrise: from the ground behind up through vertical |
| K3 | S6 a full body turn feeding one vertical drop (canon ch. 506); its own clip | E6 the setting sun: blade up, held, dropped to the plaza |
| L | S7 the halo: a semicircle overhead, a backhand down-left, the point driven down, the wave | E7 KYOKKO: the longest lunge, the body near horizontal (its own clip) |
| SP1 | S8 SHIRANUI: the blade drawn back level, the flame spirals, a level thrust | E8 KYOKUJITSUJIN: a backhand diagonal ↙ ending with only the tip touching the ground |
| SP2 | S9 TAIMATSU: the eye-open tell, one full spin rising into a fan of fire; H1 NADEGIRI (Hellfire): an unseen draw-cut L→R, the back turned, the split a beat later | B1 MINAMI: the blade upright before the face, point down, then driven down |
| I | S10 IKKOTSU: the blade planted, one step, the right fist straight out | the same |
| O | S11 JOKAKU ENJO: the blade pointed at arm's length down the lane, held, a flick | B2 TENCHI: flame gathers, one huge passing cut, the blade trailing (its own in-play clip) |
| West | — | W1 SHONETSU: no swing, arms open, the garb flares into wings, the pillars; W2 the parry: stands still, the weapon erased on his body; W3 the counter: a short backhand L→R at chest height, one step |
| Hellfire entry | S12 the blade point-down, drawn along the ground in a circle step, the pillars | — |

Every turn uses root yaw plus a pelvis roll (never the chest alone); a key about every 90° of a spin; the hit pose on S.

### 3.3 Moves and hit volumes (the sim)

- **Shikai**: the volumes stay. Canon's flame outruns the blade (Taimatsu, the Sternritter burst; RoS Homuranagi), so the
  K strikes and the L draw a **flame sheet along the cut out to the volume's edge** (presentation). Reason: the reach is
  the Shikai's identity (its fire), and the balance stays as it is.
- **Bankai East / West**: canon's Kyokujitsujin is the blade itself ("it neither burns nor erupts"), so a 3.4 m line hit by
  a 0.95 m blade is the false part. **The volumes follow the drawn blade** (「跟著動作走」), with a real forward lunge
  (`:slide`) where the motion bar is a lunge, so the effective reach stays near the old one. Applies to J1 HIZASHI, K1
  KAGERO, K2 NISSHO, K3 RAKUJITSU and the West counter (exact numbers in §4 after the measurement). KYOKKO keeps its 4.6 m
  line (the ray is drawn) and its 1.6 m slide.
- Frame data, damage and every other rule unchanged.

## 4. Build (batches, each in its own worktree; the lead merges, re-runs every check and gates)

1. **look**: the bodies and costumes per form (§3.1).
2. **shikai**: the Shikai and Hellfire clips (§3.2 left column), the K / L flame sheets.
3. **bankai**: the East / West / South / North clips (§3.2 right column) and the §3.3 volume change.

Checks: host tests (the FK test), pkgcheck, `./build.sh duel`, 8-frame side and front strips per clip, the tip report,
0 B/frame for new draw paths; batches 1–2 byte-identical sim (`simgate --seeds 10` + `--cvc`); batch 3 gated against the
baseline below.

## 5. Baseline (e4b0f2f, 20 seeds, match time without cinematics)

YY 89.2 s (P1 7 / P2 13), YK 86.3 (Yamamoto 6 / 20), RY 109.1 (Yamamoto 9), IY 106.9 (Yamamoto 16), SY 102.5
(Yamamoto 10), BY 121.0 (Yamamoto 7); all 120 K.O. The 125–210 s window predates the cinematic-free clock (DEVLOG §134):
Yamamoto's pairings sat under it before this change, so this change is judged against this baseline.

## 6. As built (batches yama-look 318cf84, yama-bankai c96d778, yama-shikai c208c7b; merged)

### 6.1 Look (presentation only; the sim byte-identical: `simgate --pairs 0,1,3 --seeds 10` and `--cvc` equal to 4f0657d)

- `yama-art.lisp`: the base body's haori is a cape (tag `:haori`: shoulder pads, the upper back panel with 一 in a
  rhombus, white lapels with the purple lining turned out, empty sleeves hanging wide and pitched +20° against his hunch;
  on the pelvis the lower cape lined `#441F58`, palette key `:lining`, two slits and a dot near each side of the hem); the
  black kosode under it (tag `:kosode`). Beard: two crossing cords, 5 crossings. Brows hang to the jaw. The X scar on the
  right of the crown.
- Hellfire: body variant `:yamamoto-bare` (`*ya-bare-parts*`): a lean torso with ink lines, the kosode folded over the obi
  with its sleeves hanging behind the hips, the left arm a stump above the elbow, 16 scars (12 glowing `#FF5A3C`, 4
  healed). Kit: `:body :yamamoto-bare :hide (:haori :kosode)`.
- Bankai: body variant `:yamamoto-tybw` (`*ya-tybw-parts*`): the robe only, burnt tatters (6 at the right sleeve, 5 at the
  empty left one, 6 round each hakama hem). East's kit: `:body :yamamoto-tybw :hide (:haori)`; West inherits it.
- Looks on the posed body (cosmetic, no sim reads, no random numbers): `YAMA-POSE` (`:pose`) swings the pelvis joint about
  the obi by `%YA-HEM-STEP`'s damped spring per side (stepped on effect seconds; it trails his travel and turns, overshoots
  once when he stops, breathes a little at idle; knobs `*ya-hem-k/c/drag/turn/max*` 60 / 4.6 / 0.03 / 0.05 / 0.42 rad);
  `%YA-SMOKE` draws East's smoke thread (7 segments, 1.1 m up from the tip; not while the blade is planted).
- West's `:garb` aura (vfx.lisp) redrawn orange: 9 + 6 tongues from the feet, two shoulder wings of 3 tongues (span about
  1.3 m: at the spec's 2× shoulder width they vanished inside the body tongues), a molten double ring, orange scraps and
  light. A new toon palette slot 15 FLAME (`+pal-flame+`, engine fx.lisp; the WGSL palette 60 → 64 entries, the clamp 14 →
  15): nothing else uses it.
- Consing (debug 2328, 10 draws): `ya hem pose` 0 B, `ya hem step` 0 B, `ya smoke` 0 B; `garb` 160 B as the old red garb.
- Known: the lower cape is rigid on the pelvis (a deep crouch can push the hem into the floor); the smoke rises straight
  up mid-swing; the empty left sleeve swings only with the upper arm.

### 6.2 Shikai clips (presentation only; the sim byte-identical as §6.1)

Every strike starts and ends on the new idle `:ya-stance` (the slouch, the point resting on the plaza 0.8 m ahead). S1
`:ya-q1`, S2 `:ya-q2`, S3 `:ya-sleeve` (root yaw +22 → −18, pelvis roll ±6), S4 `:ya-f1` (turns away right, steps in,
sweeps through the front on S), S5 `:ya-f2` (the point dragged along the plaza, rising through the front at S), S6 **new
`:ya-f3`** at K3's own frames 22/5/34 (a full turn right, a key every 90°, one vertical drop; `:ya-q3` deleted), S7
`:ya-sig` (three beats of its own at f16 / f28 / f40), S8 SHIRANUI (the throw retimed 6/2/20 → 2/1/20 to land with the
fireball), S9 `:ya-taimatsu` (the tell at f3, one full spin f6–f16), S10 `:ya-ikkotsu` (a step in, the fist at shoulder
height, the body behind it), S11 `:ya-enjo` (the point held level down the lane, a flick on S), H1 `:ya-nadegiri` (a one-
to-two-frame draw-cut crossing ahead at S, then the back turned, the blade lowered), S12 `:ya-hellfire` (point-down,
dragged round in one circle step).

**The fire sheet** (draw.lisp `fire-sheet`, from the `:fire` blade branch: base and Hellfire only): in each arc hit window
of a Flash or Signature move (3 f before to 4 f after) a flame runs from the drawn tip along its bearing to the volume's
edge, reaching it on the hit frame (its far end 0.15–1.4 m high; K3's along the floor). Consing (debug 2390): 0 B
(`vfx-blade-fire`'s body became the inline macro `%blade-fire`; 640 B before).

| Shikai move | Edge | Tip at S before → after |
|---|---|---|
| J1 / J2 / J3 | 1.40 | 1.27 / 1.36 / 1.32 → 1.39 / 1.35 / 1.35 |
| K1 / K2 / K3 | 2.60 / 2.30 / 2.40 | 1.66 / 0.83 (overhead) / 0.84 → 1.99 / 1.26 (ahead) / 1.57 (floor), the fire sheet to the edge |
| L cuts 1 / 2 | 2.60 | 1.63 / 1.64 → 1.19 / 1.50, the fire sheet to the edge |
| IKKOTSU (the fist) | 1.35 | 0.77 → 1.21 |
| NADEGIRI | line ahead | the tip 1.50 m to his right → 0.11 m aside, crossing ahead |

Plane and hand: no two Shikai strikes share both (J1 ↘ fore, J2 ↗ back, J3 L→R sleeve, K1 horizontal R→L fore, K2
vertical up, K3 vertical down after the turn, L overhead semicircle / ↘ back / point-down, SP1 level thrust, SP2 rising fan
out of a spin, NADEGIRI L→R back at the neck, I the fist, O the held point).

Known: the Hellfire idle is the same slouch (an upright one needs a clip-map); one in-between frame at the L's f31 flips
the tip up-left; the neck crack idle variation is not built.

### 6.3 Bankai clips and volumes (the sim change)

East's own clips at its own frames, none of the Shikai's and no `:clip-s` speed-up: `:ya-e-stance` (the East / West idle,
kit `:stance`), `:ya-e-q1` / `-q2` / `-q3`, `:ya-e-f1` / `-f2`, `:ya-e-kyokko` (L; `:ya-e-thrust` deleted), `:ya-e-tenchi`
(TENCHI's in-play strike, the dash kept; `:ya-tenchi` stays the cinematic's), rebuilt `:ya-e-drop`, `:ya-kyoku`, `:ya-kaka`,
`:ya-shonetsu` (16/0/24, its `:clip-s` gone), `:ya-w-parry`, `:ya-w-counter`. Plane and hand: no two share both (TENCHI made
a forehand: motion-refs' backhand clashed with ZANSHO). RAKUJITSU's embers moved to where the tip lands (2.2 → 1.6 m).

| Move | Volume before (+ slide) | After (+ slide) | Edge before → after | Effective reach (edge + slide) | Tip at S before → after |
|---|---|---|---|---|---|
| J1 HIZASHI | cap 0.2 → 1.24, r 0.25 | unchanged | 1.49 | 1.49 | 1.15 → 1.52 |
| K1 KAGERO | cap 0.2 → 3.4, r 0.3 | cap 0.2 → 1.55, **slide 1.6** | 3.70 → 1.85 | 3.70 → 3.45 | 0.72 → 1.83 |
| K2 NISSHO | cap 0.2 → 3.4, h 1.3, r 0.35 | cap 0.2 → 1.56, **slide 1.6** | 3.75 → 1.91 | 3.75 → 3.51 | 0.71 → 1.91 |
| K3 RAKUJITSU | cap 0.3 → 3.2, r 0.3 | cap 0.3 → 1.67, **slide 1.4** | 3.50 → 1.97 | 3.50 → 3.37 | 1.69 → 1.97 |
| West counter | arc 2.6, 120° | arc 1.96, **slide 0.6** | 2.60 → 1.96 | 2.60 → 2.56 | 1.38 → 1.96 |

Heights, frame data, damage and reactions unchanged. The K slides are on "hammer" bars (not lunges): the clips draw a step,
and the effective reach stays within 0.25 m of the old one (the strict reading, no slides, would cut the K reach to about
1.9 m). Tests: East and West leave `*reach-one-sided*` (they pass the two-sided FK test); the "J short, K long" test
(DUEL_STRINGS §13, the user's rule) now compares reach + `:slide` on both sides (with reach alone the K caps are now
shorter than the J ones; with the step, K still reaches further). DUEL_STRINGS §3.2's East rows updated.

Known: MINAMI's "turn and walk away" recovery isn't drawn; KYOKUJITSUJIN's blade volume (2.8 edge, tip 1.86) and TENCHI's
arc (2.4, tip 2.25) were left.

## 7. Gates (merged build, 2026-10-13)

- Host tests: duel-rules-test 6976, duel-control-test 89, cine-test 18, learn-test 131, ALL PASS; pkgcheck clean;
  `./build.sh duel` (the 4 style warnings in Lille's files, as before); the browser smoke run without errors.
- **20 seeds** (all 120 K.O.; baseline §5 → now, median / Yamamoto's wins): YY 89.2 → 89.2 s (P1 7 / P2 13 → 11 / 9),
  YK 86.3 → 85.0 (6 → 6), RY 109.1 → 101.7 (9 → 11), IY 106.9 → 110.7 (16 → 13), SY 102.5 → 102.0 (10 → 11), BY 121.0 →
  123.5 (7 → 8): every row within the seed noise of the baseline.
- **G2**: yy and yk changed (both awaken into East), kk identical. `tests/style-cvc-ref.txt` regenerated: yy now P1 9-0
  118.7 s (was 5-0 134.1), yk P2 0-6 102.9 s (was 0-6 103.7); the browser run (`style-gates.py cvc`) PASS on all three;
  the quotes in DUEL_GAMEPLAY and TUTORIAL updated.
- **Awaken A/B** (Yamamoto never awakens; seed0 100 / 300 / 500, of 60; pass ≥ 20): YY 7 / 8 / 6, YK 1 / 0 / 3, RY 0 / 0 /
  0, IY 2 / 0 / 0, SY 0 / 0 / 0, BY 0 / 0 / 0. **Not this change's**: the never-awakened side plays only the Shikai, whose
  sim this change leaves byte-identical, and the awakening opponents' moves are untouched; the parent 4f0657d gives YY 7 /
  6 / 3 and RY (seed0 100) 0. His Shikai alone loses to any awakening opponent: an open item for the user (reported, not
  tuned).
- **Looks** (`style-gates.py looks`, BASE = the build before the change): 102 of 104 stills differ. The stills with
  Yamamoto change as intended; in the others (Kenpachi, Rukia, Ichigo, Senjumaru, Lille, the menus) the differences are
  the random-driven looks only (speed lines, ash specks, the brush captions' jitter, the camera shake): every scenario
  starts on screens that show Yamamoto, whose new idle and fire looks draw the cosmetic random stream differently, and
  the stream carries on. Checked by side-by-side stills (Senjumaru's hank, Ichigo's awakening, Kenpachi vs Senjumaru):
  the fighters themselves are pixel-for-pixel the same; the new palette slot 15 shows nowhere else.

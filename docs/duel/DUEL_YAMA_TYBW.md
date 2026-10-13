# SOUL DUEL: Yamamoto, TYBW look and motion modules (2026-10-13)

Status: **in progress** (the plan, §3–§5, is the lead's [G]; the user delegated the calls, see §1).
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

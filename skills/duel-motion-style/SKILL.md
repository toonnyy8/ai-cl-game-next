---
name: duel-motion-style
description: Use when deciding or changing how a fighter moves in a code-animated arena fighter like SOUL DUEL — picking a new character's or form's motion style, giving each SP pointer its theme, stance and tells, researching references (canon fights, other games' movesets, anime scenes), and planning it into per-move clips — especially when the user gives concept words or names a style (長鞭, 大刀, 血鎖, 分身, 月牙, 魔物獵人), says strikes 「不太明顯」「沒張力」「更大膽」, says two stances look alike, or a form plays borrowed clips.
---

# Motion style: decide, research, plan, then draw

## Overview
From Kenpachi's rework (`docs/duel/DUEL_KEN_REWORK.md` §2–§8, `docs/research/kenpachi-rework/`), the new Lille's motion
modules (`DUEL_LILLE_V3` §10, §13–§16, §19–§20, §24.1, `docs/research/lille2-motion-styles/`) and Ichigo's core-system sets
(DUEL_CORE §5b–§6, `docs/research/ichigo-rework/`: a theme, a stance and a Kikon cinematic per SP pointer). Core principle:
**settle the style as named archetypes with the user, research them with graded sources, plan every slot in a table the
user approves, measure the drawn reach, then draw.** Canon plus an approved plan took ~1 build round a form; invented
styles 2–3 rounds a string. Case files and templates: `reference.md`. Clip authoring mechanics: `procedural-ink-style`;
the move grammar the clips fill: `duel-move-modules`.

## ⚠ Ask first (AskUserQuestion, recommended first, record the rejected)
- **Canon or invented?** Canon: research the fights first (the user asked 「開始工作前記得先收集與調查各種型態的資料」).
  Invented from concept words: how free (「我只是提概念，請以此延伸自由組合」)? Canon thin on choreography: canon manner
  (stance, habits, graded A–B) plus invented strikes (graded D, labelled as proposals).
- **「幫我決定」**: propose 2–3 whole candidates (each an archetype mix with one line of body per string) and let the user
  pick or combine; don't ask them to design.
- **Concept words that pull apart** (懶散 yet 毒辣, slow yet heavy): give each word a phase of the move (slack wind-up and
  recovery, the snap at S) and restate each as a body before the research.
- **Does reach follow the drawn motion (「跟著動作走」)?** Then the drawn tip sets the hit volume: a sim change, gated.
  Otherwise the art is sized to the existing reach (presentation only, byte-identical).
- **Order**: one form at a time, its look before its strikes (「逐型態：模型＋動作一起做」).
- **The bar**: which reference set every form must match, and what each concept word means as a body (「大刀」 = slow,
  whole-body, deformable, Monster Hunter's great sword?). Restate vague feedback (「更加明顯大膽」) as concrete changes.

## Research
1. Sources: canon fights (chapter / episode), official game kits, other games' movesets and trope catalogues for
   archetypes, the user's photos (trace, never buy). Images go to the git-ignored `.refs/<topic>/`; notes, in English with
   sources, to `docs/research/<topic>/`.
2. Grade every claim: A canon text / still, B official game text, C secondary, D your own inference (a proposal, not a
   reference). Label the user's decisions as theirs, not canon. Write down gaps and how to close them.
3. Templates: an **archetype table** `Archetype | Examples | What makes it read`, ending in "the choice"; a **motion bar
   per form** `# | Archetype | Body in one line | Grade | Slot`; an image table with "dropped" / "could not see".

## Pointers: one theme, read before it starts (the core system)
- **Each SP pointer is a theme** (DUEL_CORE §5b): its stance, its NS, the AS that writes it and its Kikon cinematic share one look
  (KESSA: blood chains / the black Getsuga / the clones). Plan the table per form before any clip.
- **Stances read apart at a glance**: shoot the three side by side from the behind camera (debug 2510 + p); a blade in a similar
  place reads as the same pointer (Shikai §417, KESSA §428).
- **Openers carry a tell** (S ≥ 14, the anticipation held: the cleaver overhead, the blade cocked behind); links keep their speed.
  Author the clip at the move's S.
- **A theme can ride a look on every swing** of a string (the Getsuga wrap after a charge, §422–§423): a draw hook, not new clips.
- **Mirrored pairs**: `defclip-mirror` swaps the left / right channels; a two-handed grip keeps the blade mirrored too (KESSA's X).

## Plan (show the user before any clip)
- An **inventory** of the form's clips (Clip | S/A/R | Motion | current use | proposed use; spares can be revived).
- **Mapping rules**: no two strikes share an arc plane and a hand set; one archetype a string, the user's combinations as
  its finale (whips → cleaver, rush → blast); one beat a press; each route and form its own clips; **read the slot's
  `:arc` / `:vol` first** (a thrust on a 360° spin would hit behind him).
- Get 「可以」 on the table; then build.

## Draw and verify
- Timing: the hit pose on S; a tell (squat, wind-up) inside the startup; heavier strings start later; an impact hold.
  **A key about every 90° of a spin**; accelerating keys through a heavy arc; turns with root yaw + roll, never the pelvis
  alone.
- Squash and stretch through a `:pose` hook, about the feet, **never along the facing axis** (reach stays honest).
- **Measure before rendering**: a host script printing the weapon tip per frame for every form that plays the clip
  (Lille: `*br-tip-print*` in the rules test); FK ±0.15 m; solve hit poses (`tools/pose-solve.py`), don't guess wrists.
- Review 8-frame strips from the side and the front (a 4-frame strip hides the anticipation; `tests/duel-view.lisp`:
  1000000 + 1000 i + k, i the clip's index by name, for any clip; in-match scenes need the character's own debug range), before/after sheets from
  two cameras; say "checked by numbers, needs your eyes"; then the playtest Artifact.

## Red flags
- A sim line or effect drawn over the motion (the whip read as a shot until the 31 m line stopped covering it).
- A "whip" or "beam" that is a straight line for 3 frames: a lash needs a lagging, tapered ribbon.
- A form playing a sibling's clip sped up, or borrowed upright clips on a crouched body.
- Wrists or reach guessed from strips (Kenpachi's K1 / K2 drawn 1.6 m short).
- Clips drawn while the move's rules still move (a sim change dropped 8 drawn clips).

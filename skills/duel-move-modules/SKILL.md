---
name: duel-move-modules
description: Use when designing, restating or restructuring a fighter's move set under SOUL DUEL's core system — NA strings, NS segments, AS n segments, the SA in an NS gap, the SP pointer, the Kikon hold, a wave's Kikon, a charge that powers a string, clones that replay — or when the user writes shorthand like 「NS[1] … NS[3]」「AS1=1 AS2=2 AS3=3」「SP → A」, asks for 「動作模組」 per pointer or form, or a segment gets skipped, a route stops connecting, or a press reads wrong.
---

# Move sets as core modules

## Overview
From Ichigo's rework on the core system (`docs/duel/DUEL_CORE.md` §2–§6, DEVLOG §410–§445; code `duel/lisp/core.lisp` pure,
`core-sim.lisp`, `kit.lisp` `build-core-classes`, `ichigo.lisp`). Core principle: **one grammar for every fighter (NA / NS / AS / SA
judged by the triangle), written as data in the kit's `:core` plist and the moves' `:params`; each pointer one theme across its NS, its AS
and its Kikon; each segment one press.** Evidence, the encoding and the bug classes: `reference.md`. A new fighter: `duel-character`; a
change after a playtest: `duel-character-rework`; the CPU: `duel-character-cpu`; the clips: `duel-motion-style`. The old system's grammar
(stance > JJ / KK > LL, SP2, the O ender, Lille's segment tables) is in git: `git show e55304e:skills/duel-move-modules/SKILL.md`.

## The grammar (DUEL_CORE §2–§3, §5b)
| Class | Started by | Segments | Rule |
|---|---|---|---|
| NA | J from neutral | the J string (Ichigo: five) | each link needs a hit or a cancel |
| NS n | SP from neutral, n = the pointer | up to 3, one SP press each, hit or not | the rhythm goes on until a press is missed |
| AS n | SP after an attack hit | n segments (`:as-by-press`: J1-2 → AS1, J3-4 → AS2, J5 → AS3) | ends the combo; writes the pointer n; only the last segment knocks down / launches |
| SA | J in an NS gap (after the segment's active frames) | one, then the J string goes on (`SA :q J2`) | a segment may name its own SA (`:params :sa`) |

The triangle judges a hit only while the defender is in a classed move's startup or active frames; a hazard (a wave) is never judged.
A cancel is a mutual no-damage bounce with a slow motion. **Pointer n's stance, NS, AS n and Kikon cinematic share one theme** (the user,
2026-10-28, DUEL_CORE §5b).

## ⚠ Restate before building (a segment table, then AskUserQuestion)
| Pointer | Theme | Stance | NS segments (S, hit, reaction) | Its SA | AS n segments | Kikon cinematic |
|---|---|---|---|---|---|---|

Then ask what the table can't show:
- **Scope of a carried effect**: which presses it covers (「應該只包含 NS3 之後接的 J 跟 AS」, not "the next NS"). Restate "replays
  the body's J and SP" as a list of move classes and get a yes.
- **Which pointer an AS's Kikon uses**: the pointer it writes (since §435), not the one before.
- **Direction of a timing change**: 「按住判定時間拉長」 could be more lenient or stricter (asked: 「打中後要多按住幾幀」). Ask which way.
- **Hold or tap per press, and the phone**: a tap fires on the lift in neutral and on the press inside a move (still 40 ms, `press-ms`, so a flick is no press; §444); the SP zone
  is the upper half; a hold is judged where?
- **What ends a route**: every segment that something can follow must not knock down (§443).

## The recipe
1. **Openers carry the tells**: NA1 and every NS first segment S ≥ 14 (Ichigo: NA1 14, NS 22 / 20 / 18), the anticipation held; links keep
   their speed. Author the clip at the new S (`:clip-s` = S).
2. **A stance per pointer** (`:core :stances`) so the opponent reads the next NS before it starts.
3. **Segments chain by `:params :ns-next`**; a latched press starts the next one once the current segment's active frames are over.
   Anything a segment spawns late (a clone's swing, a wave) must land before that earliest start.
4. **AS n = n segments**, the last one the knockdown / launch; the AS steals / launches / hurts by pointer (1 / 2 / 3).
5. **Waves**: a hazard beats every class at range; to let it Kikon, give its segment `:params :kikon-strike` (a strike move the owner
   flash-steps in with, classed as its segment).
6. **Carry-overs as fighter state set at a move's start** (`core-note-start!`): the charge × (`:charge-mult`) from the charged SA through
   the string; the Kikon hold (`fighter-sp-held`); the SP pointer of the strike (`fighter-sp-ptr`).
7. **Pin in host tests** (`tests/duel-rules/triangle.lisp`): every class tag, tells ≥ 14 f, each wave segment's strike (same class, cap
   ≥ 40), stance by pointer, no shared strike across classes, no knockdown / launch on a segment that something follows.

## Red flags
- One move used by an NS and an AS: the class table tags it once; make a copy per class (§437).
- An on-frame earlier than a copy's `:enter` (it never runs, §431).
- A mid-route segment that knocks down (the SA after it whiffs, §443).
- A delayed effect (a lagged clone swing) later than the next segment's start: a quick press eats it (§443).
- A hold read on the hit frame of a move faster than a tap (AS3 at 8 f): judge it after the hitstop (§440–§441).
- Counting hazards by their data struct (a clone's strikes carry the clone's data): identify by hook (§438).

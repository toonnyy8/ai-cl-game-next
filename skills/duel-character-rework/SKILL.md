---
name: duel-character-rework
description: Use when changing an EXISTING fighter in SOUL DUEL after a playtest — a move "doesn't read", a segment gets skipped, a route stops connecting, the Kikon triggers by accident or never on the phone, a stance looks like another pointer's, a cinematic is too fast, a form plays borrowed clips — especially when the request is short zh-TW feedback, arrives as several requests in one turn, or the user wants to discuss options before anything is changed.
---

# Reworking an existing fighter

## Overview
Distilled from the old Lille's 41 post-playtest decisions, today's Lille's V- and R-rounds, Kenpachi's base rework, and Ichigo's rebuild on
the core system (DUEL_CORE §6, DEVLOG §416–§445). Core principle: **find the cause and the intent first, offer composable options, then
make the smallest change; presentation only → prove the sim byte-identical; a sim change → gate the character's pairings.** Evidence:
`reference.md`. A new character: `duel-character`; the move grammar (NS / AS / SA, pointer, Kikon): `duel-move-modules`; the CPU taking a
changed move: `duel-character-cpu`; a strike that 「不太明顯」 or a form's motion style: `duel-motion-style`; retiring, removing or renaming
a character: `reference.md` §9.

## The loop
1. **Quote the feedback verbatim**; 「先跟我討論」 → change nothing until it is agreed. Several requests in one turn: one at a time, each
   with its own docs and check.
2. **Diagnose before proposing.** Reproduce in the browser (`tools/run.mjs --script` key or touch steps, debug setups, the combat log
   `[tick] P1 …`), and against the build before the change when the bug is a regression. State the cause in one paragraph with frames
   ("NS3[2]'s clone hits on f18; NS3[3] can start on f14").
3. **Restate the request as numbers or a beat table**; a direction word (「拉長」「點擊觸發」) gets its direction asked.
4. **Offer 2–4 lettered, composable directions** (AskUserQuestion, recommended first). Give conflicts before a sweeping change (「會有
   什麼衝突嗎」: list every gesture a change would break).
5. **Docs in the same pass**: the design § (verbatim quote, options, choice, knobs old → new), a DEVLOG §, the manual if players see it.
6. **Classify the change**:
   - **Presentation only** (clips, rig, VFX, camera, HUD, cinematic shots): `simgate --seeds 10 --summary` and `--cvc` byte-identical
     to a baseline saved before. Gate time excludes cinematics.
   - **Sim change in the character's files** (or a shared-file hook only he uses): his pairings only (Ichigo `--pairs 7,9,31`); a shared
     rule: all six (`2,7,9,29,31,35`). 10 seeds pass at once inside 135–200 s and all K.O.; else 20; outside 125–210 → 60 → report.
   - **Input only** (touch, the recogniser): host `touch-test`, the browser `--mobile --size 390x844`; the sim gates have no touch.
   - **Playtest first, gates after**: publish the Artifact once host tests, pkgcheck, the build and a smoke pass; gate meanwhile.
7. **Check the CPU** when a rule reads input timing (a hold, a press window): its press lengths change its outcomes; a gate shift
   that the CPU explains is fixed in the CPU, not by retuning the rule (§440: IK 201 s until the CPU held through the confirm).
8. **Verify like a player**: the positive and the negative case for every input (held / tapped, SP zone / attack zone, slow / quick
   press), host tests, `pkgcheck`, `./build.sh duel`, stills from two cameras and both aspect ratios; then update the Artifact.
9. **Reply** in zh-TW: the cause, what changed, the numbers, pushed or not, what needs the user's eyes or decision.

## Regressions to look for after any rule change
- Timing between a latched next segment and a delayed effect of the last (a lagged clone swing, a wave's spawn frame).
- A reaction in mid-route that ends the route (a knockdown before the SA).
- Input: a judgement on the hit frame of a fast move (taps read as holds); the phone's lift-vs-press and its two zones.
- Hidden movement and hidden aim (chases, lunges, `:track`, the Kikon dash-in's cap).
- Class tags: a move shared across NS / AS, a copy's on-frames before its `:enter`.
- Hazards: anything that iterates hazards by their data struct instead of their hook.
- State read too early (a tick runs after the frame count: look at land + 1); per-move state reset at its start.

## Feel tuning
- Feel numbers churn. Get the unit right once, then let the user tune by play; prefer a live knob to another gate cycle.
- Model tweaks by eye: stills (front + side), and for a size or place 3–4 candidates side by side (reference §7).

## Red flags
- Patching a symptom on one path while a sibling path (the wave's Kikon, the phone) shares the same judgement.
- "It works" from a check that only tried the happy input (§436's check held the wrong zone).
- Retuning a knob to fix pacing a CPU behaviour caused.
- Starting the build while the user is still describing.
- Declaring a presentation change done without the byte-identical check.
- A new motion on a move without reading its hit volume (`:arc`, `:vol`).

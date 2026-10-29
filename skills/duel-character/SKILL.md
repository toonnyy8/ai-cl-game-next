---
name: duel-character
description: Use when designing and building a NEW fighter (or porting a frozen one) for SOUL DUEL's core system — a roster character with forms, three SP pointers, NS / AS / SA moves, Kikon cinematics, stances, the phone's one-thumb controls and a CPU — from the first concept talk through rig, clips, systems, CPU and cinematics, especially when the user judges by playtest feel and wants the intent settled before building.
---

# Designing a new fighter

## Overview
Distilled from the old and new Lille (DUEL_LILLE / _V2 / _V3, 2026-10-06 → 10-13) and Ichigo's rebuild on the core system (DUEL_CORE §6,
DEVLOG §416–§445). Core principle: **settle intent and units before building; let the user tune feel numbers in play; keep every art
round presentation-only and prove it byte-identical.** Churn concentrates in feel numbers and silhouettes; intent, once asked, rarely
moves. Evidence: `reference.md`; the zh-TW guide `docs/guides/CHARACTER_DESIGN.zh-TW.md`. The move grammar: REQUIRED `duel-move-modules`;
the CPU `duel-character-cpu`; changing a fighter `duel-character-rework`; the loop `game-dev-workflow`. The old system's checklist (K / L
/ stance, ASSIST routes, learner situations): `git show e55304e:skills/duel-character/SKILL.md`.

## ⚠ Confirm before building (AskUserQuestion, 2–4 options, recommended first, record the rejected ones)
Concept
- **Role against Kenpachi / Ichigo / Hisagi** (the playable three): "what does he do when caught at 2 m?" Probe with a scripted scene
  (both sides' inputs, `tests/scripts/duel.py`), not a CPU match.
- **Three pointer themes per form** (DUEL_CORE §5b): pointer n's stance, NS, AS n and Kikon cinematic share one theme. Name the three
  themes first; fill the table from them.
- **Every form reachable in PRACTICE**; later forms the same system stronger, or their own `:core`?
- **Reuse** an existing system shape (Ichigo's charge > SA, KESSA's clones, a wave's `:kikon-strike`) before inventing one.

Mechanics
- **The move set as the core segment table** (`duel-move-modules`): NA string length, NS segments, AS n segments, each gap's SA, every
  reaction (only a route's last segment knocks down).
- **Tells**: openers S ≥ 14 with a held anticipation; links keep their speed.
- **Every movement move**: where it stops, fixed time or speed, distances in Step lengths. List every hidden movement (lunges, chases,
  the Kikon dash-in's `:follow-cap`) and hidden aim (`:track`).
- **Each press: tap or hold, and the phone** (the one-thumb pad: tap on the lift in neutral, on the press inside a move; SP the upper
  zone; flick Step, rest + up-flick Hoho). Anything held is checked with a tap and with the other zone (§442).
- **Ranged hits are hazards**: never judged by the triangle, so they beat every class at range. What answers them (side Step, Hoho)?
- **Pace**: the kit's `:core :mult` is the lever when tells cut the landed hits (Ichigo 1.3).

Model and look
- **Which part hits; is the weapon visible** from the behind camera. Keep the rig's strike point invisible and draw the weapon to it.
- **A stance per pointer that reads apart at a glance** (KESSA's shoulder rest at 1 read as 2's).
- **The motion bar**: REQUIRED `duel-motion-style`.

Presentation
- **A text storyboard per Kikon cinematic** (three per form): a beat table with frames and camera. Place the actors (CINE-PLACE) and
  check landscape (letterbox 9 %) and portrait.

Wording
- **Restate relative quantities as numbers and get a yes** (「放慢 1 倍」 meant 0.1×; 「拉長」 has a direction).

## Build order
1. A concept talk (no code), canon research with graded claims, a model sheet.
2. The design doc (the pointer table, the segment table) plus an adversarial review.
3. Batch 1: the kit's `:core` with functional clips at the right reach; the generic core CPU plays it at once (`core-ai.lisp`). Measure.
4. Playtest Artifact loop, **the fast checks (host tests, pkgcheck, build, smoke), then publish at once**; `--cvc` meanwhile, balance gates only when asked. Explain causes, offer 3–4 lettered, composable directions.
5. Art batches, presentation only: the scripted smoke's hash / log lines and `--cvc` byte-identical, FK reach ±0.15 m, 0 B/frame
   (seed gates only when asked, since 2026-10-29). Order that worked for Hisagi's Bankai (DUEL_HISAGI §28):
   - the sim, with a reach table the user rules on;
   - the clips and stances, one batch per mode;
   - the Kikon cinematics from approved storyboards;
   - the strings' paths and rhythm.
6. CPU tuning only after the rules freeze (`duel-character-cpu`).
7. The Kikon cinematics last, from the agreed storyboards.

## Implementation rules
- Files by role under one prefix (`<char>.lisp`, `-art`, `-clips`, `-cine`, `-look`, …). Shared files only get generic hooks that default
  off; prove them off (the other pairings and G2 byte-identical).
- Roster: the `:base` defkit appends the index to `*roster*` (never reorder; a retired slot stays). Add the name to `tools/simgate.py`
  `ROSTER`, claim a debug range in DUEL_GAMEPLAY "Debug commands", list the forms in the host tests, re-pin the looks gate's seeds.
- Each form plays its own clips (`:clip-s` retimes a clip; never a sibling form's clip sped up).
- Every mechanic gets the core CPU's use (a roll per event, EASY ≤ NORMAL ≤ HARD) and a counter in the combat log.
- Pin the combo arithmetic and the class tags in host tests (`tests/duel-rules/triangle.lisp`, the character's own file).
- A failing gate is reported, not retuned around; exceptions go into AGENTS.md with the user's words.

## Red flags
- "I'll pick a distance and gate it" before asking the unit → ask, expose the knob.
- A pointer cell borrowed from another theme "for now".
- A hold checked only with a long press, or a phone check in the wrong zone.
- A subagent "improved" a decided value → diff the merge against the decision list.
- Shots framed only at one distance or one aspect ratio.
- Art drawn for a rule the user hasn't played.

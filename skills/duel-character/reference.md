# Designing a new fighter: evidence

Two sources:
- **The two Lilles** (2026-10-06 → 10-13). They were built on the old fight system, and their records stay:
  - `docs/duel/DUEL_LILLE.md`, `DUEL_LILLE_V2.md`, `DUEL_LILLE_V3.md`;
  - `docs/research/lille-retrospective/digest.md`;
  - DEVLOG §84–§216.
- **Ichigo's rebuild on the core system** (2026-10-27 → 10-28): DUEL_CORE §5b–§6, DEVLOG §416–§445.

The old system's parts of this file (ASSIST routes, learner situations, the stance kit encoding) are at `git show
e55304e:skills/duel-character/reference.md`. "G" = generalizable, "P" = project-specific. The zh-TW guide for the user:
`docs/guides/CHARACTER_DESIGN.zh-TW.md`.

## 1. Where the churn went (P → G)
- **The old Lille:**
  - 56 decisions in 3 days. 1–15 were settled before code (10 AskUserQuestions); 16–56 came after playtests.
  - The longest chain was a dash distance: 8 values in about 13 decisions and 11 twenty-seed gates.
  - No balance knob moved after batch 4. Every later shift came from the user's design decisions.
- **Ichigo on the core system:**
  - 30 sections in 2 days (§416–§445).
  - The churn: stances read apart (§417), pointer themes (§428–§434), and the Kikon hold's input semantics (§418, §436, §440–§444).
  - The triangle's table did not move.

## 2. Rework chains and the question that would have saved each (G)
| Chain | Why earlier versions went | Ask, and when |
|---|---|---|
| A dash distance (old Lille, 8 values) | feel tuning; a hidden link chase made the length meaningless | the stop point, fixed time or speed, Step lengths, hidden movement. Design pass |
| An empty swing bought a free cancel | no price checked adversarially | what stops spamming; each cancel route. Design pass |
| A slow motion (6 decisions) | its trigger never specified; 「放慢 1 倍」 ambiguous | trigger, per line or region, live knobs. Before any feel effect |
| A sniper with no escape | could not hold range against rushers | "caught at 2 m?", a 10-seed probe. Concept stage |
| Wings / legs read wrong | arms read as wings; a misread reference | which part hits, a behind-camera still, a side still. Model sheet |
| A form PRACTICE could not reach | a beheading-gated revival | how does a playtester reach each form? Design pass |
| Pointer 1's stance read as 2's (§417, KESSA §428) | two stances with the blade in a similar place | three stances side by side, one still each |
| Pointer cells borrowed across themes (§428–§433) | KESSA's pointer 1 played the Getsuga | the pointer table filled from three themes. Design pass |
| The Kikon hold on the phone (§436, §442, §444) | a tap fires on the lift; the check held the wrong zone | each press: tap / hold, zone, when judged; check the negative case |
| A route that stopped connecting (§443) | a mid-route knockdown; a lagged effect later than the next segment | the reaction and timing of every segment that something follows |

## 3. Process patterns that worked (G)
- Phase 0 is a pure discussion. Agents set up the toolchain and the research meanwhile.
- AskUserQuestion with 2–4 options each, the rejected options recorded.
- A design doc plus an adversarial review before code.
- Canon research with graded claims; a model sheet from reference images (in `.refs/`, never committed).
- Playtest via a private Artifact of the whole game, one URL updated each round; deploy only on request.
- Explain the cause first, then 3–4 lettered, composable directions. The user often picks "all" or combines them.
- Proposals labelled as the lead's; the user corrects cheaply.
- Several requests arriving in one turn (a playtest burst): take them in order, each one documented and checked.
- Worktree fan-out by independent batch, with a lead merge. The lead re-runs every gate.

## 4. Design patterns (P → G)
- **Reuse system shapes:**
  - a charge that powers the string after its SA (`:charge-mult`, §421–§423);
  - clones as a pointer theme (KESSA NS3 / AS3 / 千影);
  - a wave's Kikon by a flash-step strike (§437).
- **A pointer's theme carries a look through the string:**
  - the yellow-white Getsuga wrap on every swing after a charge (§422);
  - the black flame in KESSA (§423);
  - the blood chains from wrists and ankles (§430).
- **One damage lever per kit** (`:core :mult`), set by the pace gate; the user owns win rates.

## 5. Modelling notes (P → G)
- One 21-joint rig and the same hurt cylinder for every form; floats and lifts are drawn only (`:lift`, never baked into clips).
- **Strike point and weapon:** the strike point is an invisible rig hand, and the visible weapon is drawn to it.
- **Translucency:** use an emissive glow × own colour, not alpha < 1.
- **A mirrored pair of strikes:** use `defclip-mirror` (left / right channels swapped, twist and yaw negated). Give it a two-handed
  grip so the blade mirrors too (§425).
- Clip keys commented as aims; FK-solved poses for long reaches (`tools/pose-solve.py`).
- **Pitfalls:**
  - Stance poses move strike points.
  - Spins need two keys 0.0001 f apart.
  - Scaled actors need every metre-authored size scaled by hand.

## 6. The CPU for a new fighter (P → G)
- The generic core CPU (`core-ai.lisp`) plays any kit with a `:core` at once.
  - It rolls once per move start for turn / continue / Kikon.
  - It holds the SP for 40 frames when it wants the Kikon.
  - It shoots from `:core :ns-range` with a gap.
- A kit adds only what the generic rules can't see (Ichigo's ranged band). Details: `duel-character-cpu`.
- The first ranged CPU always shot and the matches crawled (78 waves a match). One roll per decision plus a gap fixed it (§416).

## 7. Cinematic tools (P)
- **Staging:**
  - CINE-PLACE puts the actors at a set gap and gives them back at CINE-END.
  - CINE-SCALE draws an actor ×N.
  - CINE-SLOW scales clips and effect time while the script's frames run on.
- **Framing:** landscape has a 9 % letterbox; portrait widens the lens (`%PORTRAIT-DOLLY`).
- **Ichigo's per-pointer cinematics** (`:core :kikon-cines`):
  - debug stills at 75000 + 80 i + k (frame 3k);
  - every character's ranges are in DUEL_GAMEPLAY "Debug commands".
- Gate time excludes cinematics (since 2026-10-08), so a cinematic's length never moves the gate.

## 8. Rebuilding a fighter under a new prefix (the new Lille, P → G)
- **Copy and diverge:** the sim copied under a new prefix, the art shared by reference, the old pairings byte-identical as the proof.
  - The copy silently lost look hooks (`:body-alpha`, `:hud-guard`). Diff the hook list.
- **Same-day withdrawals** happen: hold the art until the rule has been played.
- **Recurring exceptions:** ask once whether a standing band is wanted, rather than re-asking each round.
- **Human-only cancels the CPU never uses** don't move the sim gates: a cheap way to ship feel. Still pin them in host tests.

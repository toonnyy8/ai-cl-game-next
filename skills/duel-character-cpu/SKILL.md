---
name: duel-character-cpu
description: Use when SOUL DUEL's CPU must take a fighter's new NS / AS / SA, wave, hold or pointer rule, when a CPU never uses a move, holds or taps wrongly for the Kikon, crawls the matches (a ranged move spammed), or when gate medians or win rates move after a rule that reads input timing — and when the user wants a fighter's CPU rebuilt or given a style by a search (dream-rsi, 「風格化學習型 AI」).
---

# The core CPU: teaching it moves, measuring it, searching styles

## Overview
The core system's CPU is generic (`duel/lisp/core-ai.lisp`, DUEL_CORE §5): it plays any kit with a `:core` from the class table, the
pointer and the kit's few hints. Core principle: **the CPU follows the rules, never leads them; it acts by one roll per event and by press
lengths; measure what a rule actually fires, and read every gate shift for a CPU cause first.** Generic gate and CPU rules:
`sim-balance-gates`; the move grammar: `duel-move-modules`. ASSIST, the learner and AI v2's per-kit reflexes are frozen with the old
system: `git show e55304e:skills/duel-character-cpu/SKILL.md`.

## How the core CPU decides (core-ai.lisp)
| Where | What | Knob |
|---|---|---|
| `core-brain-step` | perceive, hold the press in progress, else decide by state | `*cai-think*` (steps between decisions by difficulty) |
| `cai-own-rolls` | three rolls per own move start (turn, continue, Kikon), kept until the next start | — |
| `cai-neutral` | walk to `*cai-range*`; NA or NS (`*cai-ns-near*` / `-far*`); a ranged NS from `:core :ns-range` with a gap | `*cai-ranged-p*`, `*cai-ranged-gap*` |
| `cai-move-step` | after an NA hit: AS or the next link; in an NS gap: the SA (turn) or the next segment; in an AS: the next segment unless holding | `*cai-turn-p*`, `*cai-cont-p*` |
| `cai-sp` | SP as a tap (1 frame) or a hold (40 frames) for the Kikon; red victims raise the chance | `*cai-kikon-p*` |
| `:stun` | cancel a coming Kikon follow-up by an attack | `*cai-cancel-p*` |

Every chance is a plist by difficulty, EASY ≤ NORMAL ≤ HARD, rolled once per event (never per step).

## Teaching it one new rule
1. **Does the generic CPU already use it?** A new NS / AS / SA is in the class table, so it is pressed by the same rolls. Only add a
   kit hint for what the table can't see (a ranged band, a charge gap's SA in reach: Ichigo's SA at < 2.6 m).
2. **A rule about input timing is a rule about press lengths.** A hold the user lengthened (the Kikon confirm) must be matched by the
   CPU's hold (`core-brain-step` keeps a held press through the confirm, §440), or the CPU's Kikons drop and the pace moves.
3. **Prove it fires**: a count in the combat log over a gate run (CLOG lines, e.g. `KIKON FOLLOW-UP`, `lets go`), before and after.
4. **Rate-limit anything ranged**: one roll per decision plus a gap (78 waves a match before `*cai-ranged-gap*`).
5. **Gates**: the character's pairings at 10 / 20 seeds. A shift right after a timing rule → look at the CPU first; the fix that
   restores the old numbers exactly is the proof (IK 201.1 → 191.9 s).

## The order for a style search (the user, 2026-10-25, DEVLOG §369)
「先從幀數表、取消規則、位移與量表消耗等資訊展開出可行的連段與攻擊手段，再思考如何將這些手段引用至對戰策略中」:
1. **Data sheet** per form from the kit: S / A / R, advantage, reactions, reach, movement, every cancel and latch, costs and gains.
2. **Catalogue** of combos and means, each **verified in the native sim** by a scripted input (a frame-math entry the sim refutes is
   dropped).
3. **Strategy**: situations → catalogue entries; styles as weightings. The user picks before any CPU code.
4. **CPU**: encode it; a search (dream-rsi or a grid) only tunes weights under an evaluator frozen in one commit. Fewer than 3 rounds or
   a few dozen cells: say "a grid with bookkeeping, no dreaming" (DREAM_RSI §5.10). The old search workspaces:
   `docs/research/lille2-ai-drsi/`, `docs/research/hisagi-ai-drsi/`.

## Red flags
- A CPU rule "added" with no count showing it fired.
- A per-step chance (it is a certainty).
- Retuning a game rule to fix pacing that the CPU's press length caused.
- A threshold set from intuition about a resource, not its logged distribution.
- A search started while the rules still move (every rule change forces a re-freeze).

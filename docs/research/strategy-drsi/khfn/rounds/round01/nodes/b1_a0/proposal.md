# b1_a0: sealed-form patience with a stalemate breaker

Job (one line): while sealed, play Ichigo's patient hover-and-punish code; when neither side's Konpaku has moved for a long time, hand the
step to his own engaging KI code until something lands; released forms play his own KI code.

## Mechanism (duel/lisp/cpu-kh-ken.lisp)
- Form split: `:base` -> `ichigo-ki-style`, other forms -> `ken-ki-style` (step 4: Ichigo's code took 0.95 of the live table's judgements in
  his base form, none released). The two codes keep separate state structs; `khk-run` swaps `brain-style` per slot (hash keyed by brain,
  cleared when `*match-tick*` goes back).
- Stalemate breaker (`*khk-stale*`, hard 1500 f / normal 2100 / easy 2700): a Konpaku clock over both sides; past the threshold the sealed
  form also plays `ken-ki-style` until a Konpaku change restarts the clock. No per-step roll, nothing read of Hisagi's inputs.

## Evidence from history
No sibling or history proposals existed (round 1). Baseline: his KI code wins the arms group but not the live table; Ichigo's wins the live
table. v1 (form split only) gave live 0.27 but arms 0.52: h7-iki and h11-ids (Hisagi driven by Ichigo's KI code) fell 1.0 -> 0.04.
Cause found (hash lines in build/strategy-eval-cache): both sides at full Konpaku, idle at 3-4 m for the whole match = time-out, which
scores 0. Two waiting codes never engage. Not a bug in either code; a gap neither fills on its own.

## Variants (dev seeds 300)
| variant | scale | score | live | iterates | arms |
|---|---|---|---|---|---|
| v1 form split only | 0.5 | 0.4507 | 0.2745 | 0.5588 | 0.5188 |
| v2 + stale 600 f | 0.5 | 0.4661 | 0.1765 | 0.549 | 0.6729 |
| v3 + stale 1500 f (final) | 0.5 | 0.5183 | 0.1961 | 0.5882 | 0.7707 |
| v3 final | 1.0 | **0.5099** | 0.198 | 0.6089 | 0.7228 |

Baseline on dev 300 (refs): 0.415 (live 0.074); Ichigo's code 0.383 (live 0.223). 600 f broke the patience that wins the live table; 1500 f
kept most of it.

## Not a repeat / near-duplicate
Neither code is re-tuned and it is not a pure picker: the stalemate clock is new logic. Members differ from both codes (h1 0.78, h3 0.54,
h4 0.80 vs his 0.52-0.69; live 0.198 vs his 0.074 and Ichigo's 0.223).

## Risks
The form split alone is "only picks" in spirit; the stalemate breaker is the added job. Live share swings +-0.04 with the draw (0.27 / 0.196 /
0.198 across variants). The 1500 f threshold was tuned on dev 300 only. Released forms (Shikai, Bankai) are his KI code unchanged, untested
apart from the pool.

# b3_a0 (round 1): ken-kh-style = combo breaker by resources, then his KI code

**Job (one line):** when Hisagi has him reeling in a combo (>= 2 hits, once per combo, at the reaction delay), pay for the escape: the
awakening if its gauge is full (free, heals, no flash-step), else the Burst (200 FS, leaving 100 = one Hoho); otherwise play ken-ki-style.

## Mechanism
`kh-break` runs before `ken-ki-style`, only in :stun / :air with kikon-lock 0 and `brain-burst-t >= brain-delay`. It takes the generic CPU's
once-per-combo slot (sets `brain-burst-rolled`) and rolls *KH-BRK-AWAKEN-P* / *KH-BRK-BURST-P* (HARD 1.0 / 1.0; NORMAL 0.3; EASY 0)
instead of the generic fuzzy `*fz-burst*` (0.5 many hits, 0.2 few, 0.9 red). Burst only if FS >= *KH-BRK-FS* 200 and `burst-ok-p`.
Everything else is ken-ki-style unchanged. Reads nothing of Hisagi (own state only).

## Evidence / measurement (dev seeds 300)
| run | score | live | iterates | arms |
|---|---|---|---|---|
| baseline (his KI code) x0.5 | 0.4209 | 0.039 | 0.588 | 0.635 |
| awaken breaker only (burst p 0) x0.5 | 0.4237 | 0.069 | 0.578 | 0.624 |
| awaken + burst 0.9 x0.5 | 0.4595 | 0.118 | 0.490 | 0.771 |
| **final: awaken + burst 1.0, x1** | **0.4468** | 0.1386 | 0.5099 | 0.692 |

refs.jsonl dev-300 x1: his KI code 0.415 / live 0.074; Ichigo's 0.383 / 0.223. inc_live 0.255 (tripwire ok).
- The awakening-as-breaker alone changes nothing: the neutral awaken (kk-awaken-p 1.0) spends the gauge before a combo arrives. The gain is the Burst.
- Gain is on the press arms (h3-press 0.17 -> 0.42-0.5, h6-pressd likewise, h9-kenkite 0.29 -> 0.26-0.42, h2 / h10 0.58 -> 0.66-0.83).
- Cost: the two HK iterates dip (hk-t1 0.62-0.70 -> 0.57, hk-t2 0.46-0.56 -> 0.45); partly noise at 50 matches.

## Not a repeat / near-duplicate
The KI codes have no resource policy in the stun state (ken-ki-style returns NIL there). This job is orthogonal (defence economy, not
neutral or strings), useful across the pool (every Hisagi combo), and composes with any neutral style. It does not pick between the KI codes.

## Risks
Near-duplicate bar (mean |diff| of member shares >= 0.05 vs his KI code) should pass on the arms but is unverified. Burst leaves one Hoho:
a ranged opponent can punish the post-Burst window (hk-t1 / t2 dipped). Follow-ups not tried: gate the Burst on Reishi fraction or
combo damage; stronger awaken timing (hold it for a combo breaker).

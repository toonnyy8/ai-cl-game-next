# b1_a0 (round 2): the timed counter-Hoho -- NEUTRAL, not keep-worthy

Started from: Ichigo's KI code on Hisagi (PARENT none). Direction hint: range control.
Job (one line): in the Shikai, answer a Kenpachi attack that starts in reach with a Hoho timed into the perfect window, then J1 on his whiffed recovery; every other step is hisagi-merged-style unchanged.

## History read
Round 1 (none kept): wake-up replacements lose (b0), kiting gains stand-in/arms only (b1: 0.256-0.283, live ~0.08), whiff punish lifts live only (b2), resource cells neutral, Reishi pot best (b3_a2 0.315). Round 2 siblings had no proposals yet.

## Tried (dev seed0 300)
| variant | scale | score | live / past / arms / standin |
|---|---|---|---|
| start: Ichigo's KI code unchanged | 0.5 | 0.122 | .245 / .114 / .111 / .019 |
| Ichigo's code, patient off, mix :space/:whiff only | 0.5 | 0.095 | .128 / .074 / .160 / .019 |
| counter-Hoho (iks-timed-hoho + iks-hoho-follow, lead (1 6), J reach 1.5) + merged | 0.5 | 0.244 | .078 / .173 / .454 / .269 |
| same, lead (1 8), follow J reach 2.0 (FINAL) | 1.0 | 0.2197 | .050 / .144 / .469 / .216 |

Baseline (merged style) dev: 0.195 (scale 1), 0.216 (scale 0.5). Host tests ALL PASS.

## Findings
- Ichigo's whole code wins the live KH (0.245: patient hover and wake-up/meaty pieces beat the passive bait) but loses everything aggressive: a pure hover / whiff-punish Hisagi stalls against KI-type Kenpachi (0.0 vs k1/k2/k10, stand-in 0.02). Removing its patience made it worse.
- The counter-Hoho is a distinct cheap job (spacing by the Hoho's displacement), but its gain (+0.02-0.03) is inside the +-0.02 noise; live stays 0.05-0.08, far under the 0.2985 bar.

## Risks
Reuses Ichigo's IKS-* helpers and knobs (cpu-ki-ichigo.lisp must stay loaded). State: HKQ struct (includes HMS) in brain-style, reset by *MATCH-TICK*. Will fail the keep rule's live and stand-in floors.

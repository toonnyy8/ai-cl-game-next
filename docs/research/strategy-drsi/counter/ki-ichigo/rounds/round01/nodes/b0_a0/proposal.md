# b0_a0 ki-close (ichigo vs kenpachi, HARD)

Slice: all leads (lead behind / even / ahead = everything), i.e. replaces the incumbent wholesale.
Strategy: `:fn ichigo-ki-style` (the incumbent's style CPU, run before the MCTS fill) with `:base (:range 0.7)`: the action layer's walk-to range x0.7 (closer approach).

Evidence (dev seeds, 50/seed-window, ~100 matches, inc 25 each):
- Style CPU first with no base change is worse than the incumbent (0.19 vs 0.25 at all-lead; 0.17 behind only); narrow slices by lead/Reishi/distance/state never beat the incumbent (gains -0.08..0.00).
- Data-only strategies (no :fn) score 0 against HARD Kenpachi (sitcheck), so :fn is required.
- Base sweep on the all-lead style-first strategy: :range 0.7 +0.10, 0.8 +0.07/+0.06, 0.6 +0.02/+0.11, 0.5 -0.03/+0.10, 1.3 -0.11; awaken, hoho, ns, kikon, turn scales all <= 0.
- Final, seeds 800-899 both seats: see dev.json (0.35 vs 0.25, gain 0.10, paired b49 c29 z2.27).
Not a repeat: first cell. Risk: selected from ~25 variants on dev seeds, so some optimism; neighbours (0.6-0.8, with cont 1.8) agree in sign.

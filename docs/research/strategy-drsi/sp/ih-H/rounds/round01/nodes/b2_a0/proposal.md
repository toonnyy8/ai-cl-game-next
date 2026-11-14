# b2_a0 (IH round 1, Hisagi): attack into Ichigo's shut Hoho (code cell)

**Arm** `:c-ih-h-r1-b2a0`, `:fn hisagi-ihr1b2a0-style` (new file `duel/lisp/cpu-ih-hisagi-ihr1b2a0.lisp` on worktree branch
`worktree-agent-a62fc65e3dc3e012c`). It keeps the baseline h1-range's keys unchanged: `:dswitch 1.0`, `:dswitch-map ((:base 1 3))`
and the two `:dn` rules.

## Mechanism

Ichigo's style CPU answers a Hisagi move in reach with her timed Hoho (`iks-timed-hoho`, 0.9 at HARD). She only presses it when
`ai-hoho-spare-p` lets her spend: flash-step >= 100, plus another 100 while her Reishi is under half (`*ai-burst-low*`), and only when
`hoho-ready-p` (the lockout) allows. Flash-step regen stops at one cell (100). So once her Reishi is under half, her Hoho stays shut
until one of her hits refills the gauge.

The new style reads the same test on her gauges, the way `iks-his-hoho-shut-p` reads his. In that window it acts when Hisagi is free
and she is idle, running, guarding or punishable. It presses the first of J1 or his pointer's NS that reaches her now: outside the
dead zone, inside reach + slide less `:ihx-margin` 0.3. If neither reaches and she is beyond the move's reach, it walks in from up to
`:ihx-chase` 5 m. It rolls once per window (`:ihx-p`, HARD 1.0).

Every other step goes to `hisagi-range-style` (h1-range's play), then the MCTS / generic CPU. The range style's HRS state is kept
inside the IHX struct, which the style guards with `ihx-p`. Tunables (`style-knob` / `style-roll`): `:ihx-p`, `:ihx-margin`,
`:ihx-chase`, `:ihx-reishi` (widens the low-Reishi part of the test).

## Evidence from history

This branch has no earlier attempts, and there are no history dirs. The baseline h1-range scores 0.3647. Its counts, as K.O. wins /
losses / time-outs: anchor 162/33/5, mix 3/197/0, rest 53/142/5.

The mix group is Ichigo's `c-ki-i-r1-b0a2` (`ichigo-ki-style`, ptr3 0.6). It K.O.s every Hisagi member 52-99 % of the time
(`pop/ih-matrix.json`), so the room to gain is in the mix and rest groups. An arm's cues carry no gauge (KNOBS §4), so no data arm can
key on her flash-step. Only code can.

## Why it is not a repeat

No existing Hisagi arm or style reads the opponent's flash-step or Reishi: not h1-range, not the merged / kite / press / dswitch arms,
not the hk-* rules. This cell works on PLAN §2's SP-economy axis: it punishes her spent cells. It does not touch distance or the bias
keys.

## Risks

- Committing into her guard or a counter-hit. Presses only start while she is idle, running, guarding or punishable.
- Time-outs. In v1 the chase branch walked with `ai-walk` while she stood inside the dead zone. That walk only strafes, yet the
  branch returned T, which starved the range style's close rule. The final code walks only when she is beyond the move's reach. That
  fix did not lower the rest group's time-outs (v1 17, fixed 16). The chase distance does move them: 5 m gives 16, 7 m gives 32, and
  0 m (no walking) gives 13 but costs K.O.s. So most time-outs probably come from chasing kiting members, not from the dead-zone
  strafe. The chase stays at 5 m. The final arm's rest group still has 22 time-outs (baseline 5), a cost the next attempt can work on:
  for example, cap the chase per window.
- Overfitting the dev seeds (seed0 300 only).

## Measured (eval.py --seed0 300, 600 matches; K.O. wins / losses / time-outs)

| variant | build | score | anchor | mix | rest |
|---|---|---|---|---|---|
| baseline h1-range | 1f167650 | 0.3647 | 162/33/5 | 3/197/0 | 53/142/5 |
| v0ctl (`:ihx-p 0`, the wrapper identity check) | 87d92c29 | 0.3647 | 162/33/5 | 3/197/0 | 53/142/5 (identical: the wrapper leaks no state) |
| v1 (pre-fix code, the stall) | 87d92c29 | 0.4587 | 190/5/5 | 18/181/1 | 67/116/17 |
| v2 (`:ihx-reishi 0.5`, pre-fix code) | 87d92c29 | 0.4422 | 188/2/10 | 19/181/0 | 58/126/16 |
| fixed code, `:ihx-margin` 0.3 (default) | 21e27859 | 0.4571 | 191/5/4 | 18/182/0 | 65/119/16 |
| fixed, `:ihx-chase 7.0` | 21e27859 | 0.4373 | 191/3/6 | 18/182/0 | 53/115/32 |
| fixed, `:ihx-chase 0.0` | 21e27859 | 0.4257 | 176/19/5 | 15/185/0 | 64/123/13 |
| fixed, `:ihx-margin 0.1` | 21e27859 | 0.4736 | 199/0/1 | 23/176/1 | 62/117/21 |
| **fixed, `:ihx-margin -0.1` (FINAL cand.lisp)** | 21e27859 | **0.4851** | 198/0/2 | 21/179/0 | 72/106/22 (1 draw) |
| fixed, `:ihx-margin -0.3` | 21e27859 | 0.4769 | 199/0/1 | 21/179/0 | 66/114/20 |

The margins from 0.3 to -0.3 lie within about 1.5 SE of each other (SE about 0.02), so -0.1 is the best of a plateau, not a sharp
optimum. Against the baseline: +0.12 (about 6 SE). Anchor 162 to 198 K.O. wins (0 losses), mix 3 to 21, rest 53 to 72. The final
code is commit 1d91750c on branch `worktree-agent-a62fc65e3dc3e012c`. The host tests pass (3170 checks); pkgcheck reports only
DUEL::APP.

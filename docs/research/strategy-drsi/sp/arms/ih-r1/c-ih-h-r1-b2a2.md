# b2_a2 (IH round 1, Hisagi): b2_a1's style, retuned (data cell)

Arm `:c-ih-h-r1-b2a2`, `:fn hisagi-ihr1b2a1-style` (existing code, no new file). Same mechanism as b2_a1 (wait in her pointer-3 lunge band, press into her shut Hoho with a walk budget); only data keys moved, as one retune pass around the parent. Not a structurally new mechanism: honest plateau result.

Final keys: `:dswitch 0.5` (parent 1.0), `:ihx-margin -0.1`, `:ihy-chase-steps 40`, `:ihy-hold-p 1.0`, `:ihy-hold-lo 4.0`, `:ihy-hold-hi 8.0`.

## Variants (seed0 300, build 5aac2ad2; score, anchor / mix / rest as KO wins/losses/time-outs)
| variant | score | anchor | mix | rest |
|---|---|---|---|---|
| parent b2_a1 re-run | 0.5247 | 197/1/2 | 59/134/7 | 59/113/28 |
| hold hi 9.0 | 0.5231 | 197/1/2 | 58/135/7 | 59/111/30 |
| hold lo 3.0 | 0.5248 | 199/0/1 | 50/140/10 | 66/104/30 |
| :ihx-chase 7.0 | 0.5214 | 197/0/3 | 49/144/7 | 67/95/38 |
| :ihx-reishi 0.5 | 0.5181 | 198/0/2 | 45/148/7 | 68/103/29 |
| chase-steps 15, lo 3.0 | 0.5215 | 199/0/1 | 50/141/9 | 64/102/34 |
| :dswitch 1.5 | 0.5247 | identical to parent (value clamped/inert) | | |
| **:dswitch 0.5 (FINAL)** | **0.5281** | 197/0/3 | 58/134/8 | 62/106/32 |

(hold-p 0.97 variant crashed the JSON parse of my helper, not evaluated.) All variants lie within ~0.01 of the parent, inside noise (SE ~0.02); the final is +0.0034 over the parent, not a real gain. The mix group (134 losses) remains the wall; it needs new code, not these keys.

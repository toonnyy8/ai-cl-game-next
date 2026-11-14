# b3_a0 (IH, Hisagi, round 1): a new style `hisagi-ihr1b3a0-style`, then an earlier awakening

Code: `duel/lisp/cpu-ih-hisagi-ihr1b3a0.lisp` on branch `worktree-agent-a434389f74c934889` (commit ea33875c). MANIFEST: after `cpu-hk-hisagi.lisp`.

## Mechanism
The style wraps `hisagi-range-style` (h1-range's `:fn`) with its own state in `brain-style` (struct `ihw`, holding the range style's `hrs`). It adds two rules, each controlled by arm keys:
1. **Whiff punish** (`:ihw-p`, HARD 1.0). Hisagi is free and Ichigo is recovering as perceived (`snap-recovering-p`). One roll per recovery: J1, else the pointer's NS, when it fits (`hkw-fits-p`). `:ihw-late 1` runs it only after the range style declines.
2. **Gap guard** (`:ihg-p`, HARD 1.0; `:ihg-fs` 150, `:ihg-lo` 3.5, `:ihg-hi` 8.0, `:ihg-max` 240, `:ihg-out`). It targets the mix arm `c-ki-i-r1-b0a2`, which plays `:iks-gap-fs 150 :iks-gap-p 1 :iks-mix-ptr3 0.6`. In that arm, Ichigo at pointer 3 backs off and lunges NS3a into Hisagi walking in while Hisagi's flash-step is under 150. The rule applies when Ichigo is free at pointer 3, Hisagi's flash-step is under `:ihg-fs` and the distance is in band. Hisagi then waits (or walks out) instead of walking in, for at most `:ihg-max` free steps per episode.

The final arm turns both rules off and sets the generic CPU's awaken scale `:awaken 5.0`, which only `cai-neutral` reads.

## History
- There are no earlier attempts in b3 and no history dirs. The baseline is h1-range at 0.3647: anchor 162/33/5, mix 3/197/0, rest 53/142/5.
- The IH matrix shows every `ichigo-ki-style` arm beating every Hisagi column. Against the mix member Hisagi wins 3 of 200.
- Not a repeat: no earlier arm reacts to Ichigo's recovery or reads his pointer and Hisagi's own Hoho gauge (the code). None of h1-range, the hk-* styles or `hisagi-merged-style` sets `:awaken` on the ranged style.

## Diagnosis
Six matches against `c-ki-i-r1-b0a2` (seeds 301-306, Hisagi P1, `STRAT_HRANGE`):
- Ichigo is in KESSA every time and K.O.s in 82-152 s.
- In 3 of the 6, Hisagi never awakened and died in his base form.
- When he reached the Bankai he spent 2568 of 4390 ranged steps inside 2.9 m.

## Measured (seed0 300, 600 matches each; W/L/TO per group)

| variant | score | anchor | mix | rest |
|---|---|---|---|---|
| baseline h1-range | 0.3647 | 162/33/5 | 3/197/0 | 53/142/5 |
| control: style, both rules off | 0.3647 | 162/33/5 | 3/197/0 | 53/142/5 (bit-identical: the wrapper is transparent) |
| both rules on | 0.3333 | 159/35/6 | 3/197/0 | 37/156/7 |
| gap guard only (wait) | 0.3267 | 161/35/4 | 3/194/3 | 31/139/30 |
| gap guard only (walk out) | 0.3333 | 158/39/3 | 1/197/2 | 40/144/16 |
| both, punish late | 0.3251 | 158/37/5 | 2/194/4 | 34/129/37 |
| rules off, `:awaken 50` | 0.3746 | 196/4/0 | 1/199/0 | 27/171/2 |
| both rules, `:awaken 50` | 0.3614 | 195/5/0 | 0/171/29 | 21/130/49 |
| gap guard, `:awaken 50` | 0.3598 | 195/5/0 | 0/167/33 | 20/123/57 |
| punish only, `:awaken 50` | 0.3696 | 196/4/0 | 1/199/0 | 24/174/2 |
| gap guard, `:awaken 5` | 0.3696 | 193/7/0 | 1/191/8 | 27/138/35 |
| rules off, `:awaken 3` | 0.3878 | 190/10/0 | 2/198/0 | 40/159/1 |
| **rules off, `:awaken 5` (final)** | **0.3927** | **194/6/0** | **3/197/0** | **38/161/1** |
| rules off, `:awaken 8` | 0.3878 | 193/7/0 | 2/198/0 | 37/162/1 |
| rules off, `:awaken 15` | 0.3812 | 194/6/0 | 1/199/0 | 33/166/1 |

## Verdict
- **The code failed.** The whiff punish feeds Ichigo's timed Hoho, whiff confirm and out-of-reach punishes. The gap guard only adds time-outs and never moves the mix group.
- **The gain is data only.** An earlier awakening lifts the anchor from 162 to 194 K.O.s; past `:awaken` 5, the rest group falls again.
- **It is not proven.** 0.3927 beats 0.3647 by 0.028, under the README's 0.04 tie line, measured on seed 300 only.
- **The mix group did not move.** It stays at 3/197, so the KESSA rush is still unanswered.

## Next
Code that changes the Bankai's close-range game against a hugging Ichigo, or the base form's game before the awakening.

Risk: since the final arm leaves both code rules off, its `:fn` plays exactly `hisagi-range-style`; it also equals h1-range + `:awaken 5` under `:fn hisagi-range-style` (not run separately).

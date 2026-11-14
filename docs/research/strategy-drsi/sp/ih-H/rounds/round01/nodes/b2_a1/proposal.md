# b2_a1 (IH round 1, Hisagi): wait in Ichigo's pointer-3 lunge band (code cell)

**Arm** `:c-ih-h-r1-b2a1`, `:fn hisagi-ihr1b2a1-style`. The style is in a new file, `duel/lisp/cpu-ih-hisagi-ihr1b2a1.lisp`, listed in
MANIFEST after b2_a0's. It is on worktree branch `worktree-agent-a3a48c4fbb59241fe`, commit a2a83d3e. The arm keeps b2_a0's keys
(`:dswitch 1.0`, `:ihx-margin -0.1`, the map, the two `:dn` rules) and adds
`:ihy-chase-steps 40 :ihy-hold-p 1.0 :ihy-hold-lo 4.0 :ihy-hold-hi 8.0`.

## Mechanism

The style runs these steps in order:

1. **IHY-HOLD (new).** It fires while Ichigo is at pointer 3, both fighters are free (idle or run), the perceived distance is within
   [`:ihy-hold-lo`, `:ihy-hold-hi`], and neither J1 nor his NS reaches her. Then he waits (`mc-press :wait`) instead of walking in.
   - Why: `iks-gap`, the shut-gauge lunge (cpu-ki-ichigo.lisp), counts his Hoho as shut while his flash-step is under `:iks-gap-fs`.
     The mix arm `c-ki-i-r1-b0a2` sets that to 150, above the regen cap of 100, so the test holds nearly always. She backs off to about
     5.5 m and lunges NS3a only when she sees him **walking in** (`iks-closing` >= 0.05 m a step) at about 5.1-5.25 m plus a
     closing-speed correction. If he does not walk in, the lunge never fires.
2. **IHY-STEP.** b2_a0's press into her shut Hoho (`ihx-shut-p`, `ihx-fits-p`, its `:ihx-*` keys), with one change: the walk-in is
   limited to `:ihy-chase-steps` free steps per window.
3. **`hisagi-range-style`**, then the MCTS and the generic CPU.

Tunables (`style-knob`): `:ihy-hold-p` (default 0, off), `:ihy-hold-lo` 4.4, `:ihy-hold-hi` 7.0, `:ihy-hold-max` (0, no limit),
`:ihy-chase-steps` 40.

## Evidence and history

- **Parent b2_a0:** 0.4851, anchor 198/0/2, mix 21/179/0, rest 72/106/22. It guessed that the rest group's time-outs (5, then 22) came
  from chasing kiting members.
- **The chase budget falsifies that.** It changed almost nothing: 20 steps 0.4851, 40 steps 0.4901, 80 steps 0.4851. A budget of 1000
  steps reproduces the parent's counts exactly (the identity check).
- **Where the time-outs come from.** Against the baseline, the parent turned 36 rest losses into 19 wins and 17 time-outs. So the
  time-outs are mostly matches he used to lose and now survives without finishing, not a walking stall.
- **`:hoho 2.0` (data only) hurt:** 0.467, mix 15/185. The generic reactive Hoho does not answer the lunge.
- **The big pot is the mix group's losses.** That led to the code above.

| variant (eval.py --seed0 300) | build | score | anchor | mix | rest |
|---|---|---|---|---|---|
| hold off (= w40, budget 40) | b58dd7f8 | 0.4901 | 198/0/2 | 21/179/0 | 75/103/22 (identical to w40: the hold is off by default) |
| hold, band 4.4-7.0 | b58dd7f8 | 0.4703 | 198/0/2 | 21/177/2 | 63/111/26 |
| **hold, band 4.0-8.0 (FINAL)** | fa62889d | **0.5247** | 197/1/2 | 59/134/7 | 59/113/28 |
| hold, band 3.5-9.0 | b58dd7f8 | 0.5148 | 198/0/2 | 56/133/11 | 55/110/35 |
| hold, band 4.4-8.0 | b58dd7f8 | 0.5165 | 196/1/3 | 55/144/1 | 59/116/25 |
| hold 4.0-8.0, `:ihy-hold-max 150` | fa62889d | 0.4868 | 197/1/2 | 40/157/3 | 55/108/37 |
| hold 4.0-8.0, `:ihy-hold-max 300` | fa62889d | 0.4884 | 197/1/2 | 45/151/4 | 51/116/33 |

**Reading the table:**
- The mix group's K.O. wins nearly triple, from 21 to 59.
- The rest group loses 16 wins (75 to 59), and its time-outs rise from 22 to 28. Most rest members keep `:iks-gap-fs` at its default
  of 96, so they see his Hoho as open at 100 and the hold only costs him tempo.
- Net +0.035 over w40 and +0.040 over the parent. That is about 2 SE, a likely gain but not a sure one.
- The band's far edge matters: 7 m loses, 8 m pays.

## Why it is not a repeat

b2_a0 reads her gauges and presses. This cell keys on her **pointer** (3) and on **distance**, and it denies the walk-in cue that her
lunge reads instead of pressing. No Hisagi arm or style waited in a band before this one.

## Risks and next steps

- The hold costs tempo against members that do not lunge. Next, try holding only while his flash-step is under 150 (the mix arm's
  cue), or pressing a ranged move from the band.
- The time-outs rose again. A cap on each stay (`:ihy-hold-max`) made things worse: the mix wins fall back and the time-outs rise.
- This is tuned on the dev seeds (seed0 300) only.

## Measured: final cand.lisp (eval.py --seed0 300)

score 0.5247; anchor 197/1/2 (draws 0); mix 59/134/7 (draws 0); rest 59/113/28 (draws 0); build fa62889d51b1fae2.
Host tests: 3170 checks, ALL PASS. pkgcheck: DUEL::APP only.

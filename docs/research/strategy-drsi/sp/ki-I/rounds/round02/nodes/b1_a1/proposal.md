# b1_a1 (code cell): ichigo-ki-r2b1a1-style, a wake-up roll and a hold over his knockdown, with the shut-gauge lunge keyed on :lead

Code: worktree branch `worktree-agent-a3e87ca10ffed49c4`, commit 1f6f00ec, new file `duel/lisp/cpu-ki-ichigo-r2b1a1.lisp` (listed in
duel/MANIFEST after cpu-ki-ichigo.lisp). `ichigo-ki-r2b1a1-style` calls `ichigo-ki-style` on every step (so its bookkeeping is
unchanged), then adds two pieces. Its state is an `ir2` struct that includes `ikst`, kept in `brain-style`. Its rolls are `style-roll`
only. It is not registered by cai-defstyle, so no other arm, kit or `none` changes. With `:ir2-roll-p 0` the arm reproduces the parent
bit for bit (0.67, identical counts).

## Mechanism
1. **The wake-up roll** (`:ir2-roll-p`, HARD default 1.0): when she is knocked down, she holds the stick away from him through `:down`. The engine's
   roll (fighter.lisp AIR-STEP, 4 m, invulnerable) carries her out of his meaty J1. That J1 is pressed only within his J1's reach, so it is
   never pressed.
2. **The hold over his knockdown** (`:ir2-oki-p`, default 0, this arm 1.0; band `:ir2-oki-lo` / `:ir2-oki-hi`, this arm 2.0-2.6 m):
   while he is seen `:air` / `:down` / `:wakeup`, the press `ichigo-ki-style` made that step is dropped, except an awakening, whose roll
   is already spent. Her plan is restored and she walks to the band.
3. **Data**: the parent's arm with `:iks-gap-p 0.5` in the base and the rule `(((:lead :ahead)) (:iks-gap-p 1.0))`.

## Evidence (logs, 20 seeds a seat against c-ki-k-r1-b2a2, the parent's arm)
- Half of his damage (75k of 150k) came from combos his meaty J1 opened on her wake-up. Her wake-up Hoho fired on only 189 of 885 meaty J1s:
  it presses on the same frame the J1 lands.
- Her J1 / NS pressed into his invulnerable wake-up whiffed (KESSA episodes hand over to the generic CPU after `:iks-wait-max` 40), and his first free J1 then opened a combo.
- With the hold at 2.0-2.6 m, inside his wake-up Hoho trigger (2.4 m), he spends 100 flash-step on a wake-up Hoho with nothing to
  dodge. His Hoho is then shut, so her NS3a meets only his back Step, and KESSA's SA catches him in it (the k-sa). The logs show this;
  it is not proven as the only cause.

## Measured (seed0 300, 600 matches each; W/L/TO per group anchor | mix | rest)
| variant | score | anchor | mix | rest |
|---|---|---|---|---|
| parent b1_a0 (= this fn at roll-p 0) | 0.67 | 195/2/3 | 39/102/59 | 169/14/17 |
| + roll only (v1) | 0.6337 | 189/0/11 | 29/26/145 | 163/4/33 |
| + roll, gap-p 0 | 0.6188 | 114/0/86 | 84/116/0 | 174/25/1 |
| + roll, gap 0.5 + :lead :ahead 1.0 (r4) | 0.7525 | 193/0/7 | 80/120/0 | 180/19/1 |
| + roll + lead rule + hold 2.0-2.6 (final) | **0.8647** | 195/0/5 | 139/60/1 | 187/12/1 |
| final, roll off | 0.7558 | 193/4/3 | 85/115/0 | 177/23/0 |
| final, no lead rule, gap 1.0 | 0.6601 | 191/0/9 | 38/17/145 | 168/3/29 |
| final, no lead rule, gap 0.5 | 0.7673 | 138/0/62 | 139/60/1 | 185/14/1 |
- Every piece pays: roll about +0.11, lead rule about +0.10 / +0.20, hold about +0.11.
- The hold band is a plateau from 1.0 to 2.8 m (0.835-0.861). Its edge is at about 2.6 m, near his wake-up Hoho's 2.4 m: 2.6-3.3 scored
  0.7178 and 3.4-4.2 scored 0.6964.
- The gap-p base is a plateau too: 0.3 gave 0.863, 0.5 gave 0.8647, 0.7 gave 0.8597.
- The awakening exemption measured 0.8647 against 0.8614 without it, a tie.
- Note: the parent's batch1 probes (p6 gap-p 0, p8 wait-max, p10 whiff) appended keys the arm already had, so the first occurrence won and
  those "inert" readings were not tests.

## Why not a repeat
Every earlier attempt tuned `ichigo-ki-style`'s keys or the generic scale keys. Neither touched her own knockdown (no key reaches the
wake-up roll) or her play while he is down. The `:lead` rule on a style key is new in this branch. The only earlier `:lead` rules were
round 1's b2_a1, on ptr3 / wait-max / hoho.

## Risks
- Tuned on seed0 300 only (score SE about 0.02), and the gains are large compared with that.
- The `:lead :ahead` rule may act as a proxy for the opponent type: she leads against the patient anchor, where the shut-gauge lunge is
  her offence, and trails c-ki-k-r1-b2a2, whose 7 m back Step makes the lunge a stall.
- The mix group still loses 60 of 200.
- Host tests: 3165 checks, 5 FAILED. All 5 come from `style-knob.lisp`'s "no SP arm file names a knob" check, which trips on the five
  arms/r1/*.lisp files committed in 9538979f. They fail on HEAD without this change, and none involves this file. pkgcheck: only DUEL::APP.

Final eval (exact command, build f0805b8f3ac5e46b): score 0.8647; anchor 195 W / 0 L / 5 TO, mix 139 / 60 / 1, rest 187 / 12 / 1.

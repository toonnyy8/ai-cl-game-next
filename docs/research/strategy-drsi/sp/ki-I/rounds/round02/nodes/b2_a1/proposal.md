# b2_a1 (code cell): ichigo-ki-r2b2a1-style. A forward-diagonal wake-up roll baits his meaty, the lunge turns off once his far back Step shows, and a stale breaker ends stand-offs

**Code.** Worktree branch `worktree-agent-a9e43c5f5424bb955`, commit `b055117f`. The new file `duel/lisp/cpu-ki-ichigo-r2b2a1.lisp` is listed in `duel/MANIFEST` right after `cpu-ki-ichigo.lisp`. No existing function changed: c-ki-i-r1-b3a2 rescored 0.6155 on the new build with identical counts.

**Arm.** Built on the r1 champion c-ki-i-r1-b3a2, not on b2_a0's arm. b2_a0 scored 0.6254 on its pinned build with three extra keys: `:iks-mix-space 0`, `:iks-punish-p 1.0` and `:iks-confirm-p 1.0`. Its own proposal measured them as within noise of r1-b3a2, so they were not carried over. The change from r1-b3a2 is `:fn ichigo-ki-r2b2a1-style` plus two keys, `:ikw-roll-x 0.7 :ikw-roll-y 0.7`.

## Mechanism
The style is `ichigo-ki-style` (unchanged, on its own `ikst` struct through `(:include ikst)`) plus three pieces. Every piece is tunable by arm keys read through `style-knob` / `style-roll`.

1. **Wake-up roll** (`:ikw-roll-p` 1.0, `:ikw-roll-x` / `:ikw-roll-y`).
   - On each knockdown of hers the stick is held through `:down`. AIR-STEP then rolls her 4 m, invulnerable, as `:down` ends (`*roll-distance*`). No CPU used the roll before.
   - Diagnosis, from combat logs on seeds 301-320 against c-ki-k-r1-b2a2: about half his damage opened with his meaty J1 on her wake-up (KK-MEATY-STEP).
     - He waits at 2.25-2.4 m, just outside IKS-WAKE's 2.2 m Hoho, and lands J1 on her first free frame. Then J2 and AS1 knock her down again: a loop.
     - The champion's logs held about 520 such openers in 20 matches, about 48k of his 86k damage.
   - Rolled forward-diagonally (0.7, 0.7) she ends about 2.9 m away at his flank. He still presses the meaty J1, because his view of her is 8 frames old. It whiffs, and her own whiff punish (IKS-PUNISH: NS3a at pointer 3, then SA, J string, AS3) lands.
   - The angle is narrow; the measured scores are below.
2. **Shut-gauge lunge off once his far back Step is seen** (`:ikw-gap-far` 6.3 m, `:ikw-gap-off-n` 2).
   - IKS-GAP's lunge band (lo 5.25) was built for a 5.0 m back Step. Against `:kk-step-max 7` his read comes at 5.1-5.2 m and he Steps every time, so there are about 100 whiffs a match. The lunges are paid from an empty gauge (`paid 4.1 x0.57`), so her Hoho stays shut.
   - A lunge pressed at a perceived 6.3 m or more that he Steps within 30 frames counts once. After 2 counts the style plays on the arm with `:iks-gap-p 0` put in front of `:base`: a reused cons stands in for BRAIN-NOW, 0 B a step.
   - An opponent with a 5.0 m Step never trips it, so the anchor and most of rest keep the lunge.
3. **Stale breaker** (`:ikw-stale` 600 frames).
   - Once neither side's Reishi or Konpaku has changed for 10 s, her free steps go to IKS-GENERIC until a gauge changes.
   - Diagnosis: against the anchor, the roll left matches frozen at a lead. Example: seed 303, from t = 4800 to the bell, she was at 9 Konpaku, BASE, pointer 1, patient hover; he was at 4, Nozarashi, waiting on his Hoho-safety.

## Evidence (eval.py, seed0 300 unless noted; groups as K.O. W / L / time-outs)
| variant | score | anchor | mix | rest |
|---|---|---|---|---|
| r1-b3a2 (the arm built on; rescored on this build) | 0.6155 | 193/3/4 | 17/127/56 | 160/24/16 |
| r1-b3a2 + `:iks-gap-p 0` (data only) | 0.5858 | 187/12/1 | 15/185/0 | 150/50/0 |
| style, roll straight back (0, -1), lunge always on | 0.6056 | 182/0/18 | 19/48/133 | 163/11/26 |
| same + `:iks-gap-p 0` | 0.5495 | 99/0/101 | 66/133/1 | 165/34/1 |
| + gap-off detector, roll back | 0.6815 | 182/0/18 | 57/142/1 | 171/29/0 |
| roll forward (0, 1) | 0.6666 | 180/0/20 | 53/147/0 | 168/31/1 |
| roll side (±1, 0) | 0.7062 / 0.7096 | | 71/128 / 70/130 | |
| roll back-diagonal (0.7, -0.7) | 0.6881 | | 58/142/0 | |
| roll 30° off toward (0.5, 0.87) | 0.604 | | 17/182/1 | |
| roll 40° (0.643, 0.766) | 0.7723 | 176/0/24 | 107/91/2 | 182/17/1 |
| **roll 45° (0.7, 0.7)** | **0.8812** | 176/0/24 | 167/30/3 | 188/10/2 |
| roll 45° mirrored (-0.7, 0.7) | 0.8729 | | 164/34/2 | |
| roll 50° (0.766, 0.643) | 0.7178 | | 78/121/1 | |
| roll 60° (0.87, 0.5) | 0.7475 | | 90/109/1 | |
| roll 45°, gap never off (`:ikw-gap-off-n 0`) | 0.5743 | 176/0/24 | 12/1/187 | 157/2/41 |
| roll 45°, `:ikw-gap-off-n` 1 / 3 (roll back / side) | 0.66 / 0.693 | | | |
| **final: roll 45° + stale breaker 600** | **0.929** | 199/1/0 | 169/31/0 | 192/8/0 |
| stale 0 (control: identical to roll 45°) | 0.8812 | 176/0/24 | 167/30/3 | 188/10/2 |
| stale 300 / 1200 | 0.9043 / 0.9274 | 200/0/0 / 199/0/1 | 152/48/0 / 167/31/2 | 193/7/0 / 193/5/2 |

Robustness check on another dev block, seed0 100 (seeds 101-200, not the coordinator's or the held-out blocks):

| variant | score | anchor | mix | rest |
|---|---|---|---|---|
| final arm | 0.9422 | 200/0/0 | 173/27/0 | 195/5/0 |
| r1-b3a2 | 0.6072 | 188/2/10 | 21/135/44 | 156/33/11 |
| roll 40° | 0.7789 | | 114/80/6 | |
| roll 45° (no stale breaker) | 0.8812 | | 161/32/7 | |
| roll 50° | 0.731 | | 84/114/2 | |

The 45° peak replicates on this block.

## Why it is not a repeat
Every earlier attempt in this branch and in round 1 tuned `ichigo-ki-style`'s data knobs: the episode mix, hover, gap, meaty, Hoho. b2_a0 showed that no data knob moves the mix group, which stayed at 17-24 wins of 200.

This cell changes a situation no knob reaches. Her wake-up under his meaty chase was never played, since no CPU used the roll. It also gates the lunge on perceived evidence of the opponent's Step range rather than turning it off for everyone. That gating matters: turning the lunge off for everyone cost the anchor about 100 time-outs.

## Expected benefit and risk
- **Benefit.** The mix group goes from 0.09 to 0.84. The anchor and rest groups go up too, because every member with a style CPU (all but a-generic) runs the same meaty chase.
- **Risk: the narrow angle.** The roll angle peaks narrowly: 40° and 50° score 0.77 and 0.72. It replicated on seeds 101-200, and its cause is geometric: where she ends relative to his J1 reach against what he perceives.
  - A Kenpachi arm that changes `:kk-meaty-p` would blunt the bait, and so would a later code change to the meaty chase (its distance, or a check of her roll).
  - The style then still has the roll as an escape.
- **Risk: rescoring.** The lunge-off detector needs 2 observed Steps from 6.3 m+. The stale breaker hands neutral to the generic CPU, which lost first hits against this Kenpachi in round 2. It fires only after 10 s with no gauge change.
- **Checks.**
  - Host tests: 3165 checks, 5 FAILED, the same 5 as the base commit. All are `style-knob.lisp`'s "no arm file names a knob" check on the existing `arms/r1/*.lisp`; none is new.
  - `tools/pkgcheck.sh duel`: only DUEL::APP.
  - G2: `python3 tools/simgate.py --cvc` PASS. ii, ik and kk each match `tests/style-cvc-ref.txt` line for line, so `none` and the other kits play as before.

## Measured (final cand.lisp, build 5e10210e362ccd68)
`{"score": 0.929, anchor 199/1/0 (share 0.9901), mix 169/31/0 (0.8416), rest 192/8/0 (0.9554)}`. Full line: `scratch/final.json`.

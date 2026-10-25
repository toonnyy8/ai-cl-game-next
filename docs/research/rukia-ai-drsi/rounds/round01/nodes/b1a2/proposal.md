# b1a2 (round 1, a refine of b1a1): his state. Lille's charged dash met with a perfect Hoho timed to its slide, and the wait against that form

Primary axis (the brief): her resources and his state. I worked on his state. Parent: b1a1 (rescored 0.8906), whose file is
otherwise unchanged. History read in full: the baseline (0.5898), b0a0 (0.7154), b0a1 (0.8839), b1a0 (0.7506), b1a1 (0.8906),
b2a0 (0.8421) and b3a0 (0.719), each with its score.rescored.json. b0a2 had no result yet. Planning base read:
`docs/research/rukia-cpu/` (matchups-shikai, opponents/barro-*), barro.lisp (the dash: `*BR-W-DASH-*`, BR-W-DASH,
br-defstance), barro-ai.lisp (BR-AI-CHARGE-TICK, the line call, the far dash), combat.lisp PERFECT-NOW-P, rules.lisp
PERFECT-HOHO-P / THREAT-WINDOW-P, ai.lisp (AI-REFLEX, SNAP-NEAR-P).

## Result (EVAL_COMMAND `python3 tools/aieval.py --char 2 --seeds 40 -j 2`, the final file)

| | baseline | b1a1 (parent) | b0a1 | **b1a2** |
|---|---|---|---|---|
| **score** | 0.5898 | 0.8906 | 0.8839 | **0.9214** |
| strength | 0.273 | 0.750 | 0.742 | **0.863** |
| masher | 1.0 | 1.0 | 1.0 | 1.0 |
| signature | 0.616 | 0.931 | 0.923 | 0.925 |
| NORMAL share (band 0.30-0.60) | 0.423 | 0.542 | 0.454 | 0.556 (x1) |
| pacing (NORMAL P1 medians, all K.O.) | 100.8-140.4 s | 88.5-142.8 s | 99.8-144.7 s | 88.5-141.6 s |

str_by_opp (HARD, both seats, of 80): **Lille 74** (b1a1 20, b0a1 43). Yamamoto 72, Kenpachi 35, Ichigo 79, Senjumaru 74
and Hisagi 80 are b1a1's exactly: both new pieces fire only against a form whose L has `:params :dash`, i.e. Lille's EN
stance forms (JILLIEL, SHIN). NORMAL by_opp: Lille 56 (was 49); the rest are b1a1's. sig_by: kstring 0.454, burst 0.175,
poke 0.139, seal 0.108, kido 0.050; outside her signature: counter 0.055 (b1a1 0.049: the perfect Hoho's counter), O on red
0.009, Breaker 0.005.

**Paired, final vs parent** (my runner over the native sim: aieval's run-log commands with a seed offset (30000 + s0) and
the frozen `rukia_class`; it reproduces b1a1's 20/80 on seeds 1-40):

| block | matches | b1a1 | b1a2 | diff (SE) |
|---|---|---|---|---|
| aieval seeds 1-40, all six opponents | 480 | 360 | 414 | +0.113; every other opponent identical, so the whole difference is the Lille rows |
| Lille, seeds 1-40 | 80 | 20 | 74 | +0.675 |
| Lille, seeds 41-120 (out of sample) | 160 | 21 | 133 | +0.700 (0.04, z 17) |

I stopped there: past 2 SE by a wide margin in every block.

## 1. What the history says

- Lille was every cell's losing matchup (0-43 of 80). Every cell named the cause: his awakened charged dash L (BR-E-L1 /
  BR-OE-L1). Several tried a guard on it. b0a0's and b0a1's :guard-on got 20 -> 26 of 80. b1a1's C5 blocked 124 of them
  and won nothing. b3a0's v16 (a far-rush guard by closing speed) tied. b0a1 v14 tried a Hoho behind him during the
  snipe charge and lost 41 -> 32 (his charge Steps out and re-aims).
- **I located why the guard can't pay, in the code.** The dash is -12 on block, but the post-block hold (the §17.6 item:
  stun + 20 frames, no reflex) forfeits the punish. In b1a1's logs her BLOCK-PUNISH J1 after a blocked dash was hit 12
  times out of 14. The dash is :through, so it ends 1.6 m behind her.
- **Why her perfect Hoho never fired on the dash, also located.** RUKIA-AI-PERFECT-HOHO's `:sig` branch needs
  SNAP-NEAR-P (d < his move's reach + 0.7). The dash's own reach is its 0.9 m hit volume, but it travels 2-10 m. So the
  Hoho was never pressed until he was already on her. Combat's PERFECT-NOW-P is generous here: any hit window within
  `*PERFECT-LEAD*` 12 frames, and the volume within `*PERFECT-INFLATE*` 1 m. The window is reachable if she presses at the
  right moment of the slide.
- b0a1's measured lesson: her slow neutral pokes feed every HARD CPU, and the wait leaves him the commitment. I apply it
  only where my logs show it: against his dash form.

## 2. The diagnosis (b1a1's file, 40 HARD matches against Lille, both seats; my scratch tools)

- His damage by opener: BR-E-L1 55 k (237 openers) and BR-OE-L1 39 k (109). Of the 270 Konpaku she lost, 204 were his
  Kikons at the end of those combos (`kikon:BR-E-L1` 124, `kikon:BR-OE-L1` 80). After them: the base snipe BR-S-L1-2
  (10 k), BR-K-HIREN.
- The dash's frames, measured with a trace (`DBG`) on the perceived SNAP: its S is **12** (the move stands still), then
  BR-W-DASH slides him `clamp(d + 1.6, 2, 6 / 8 / 10)` m over 8 frames. The hit volume is 0.9 m ahead and 0.7 wide. His CPU
  releases it when its line meets her (BR-AI-LINE-CALL), so she is on the line.
- Her presses during his awakened forms (outcome: hit / his hit came first / into his wing armour):
  - SOKATSUI / RIKUJOKORO from the zone: 170 presses, 14 / 83 / 31.
  - BYAKURAI: 82 presses, 20 / 32 / 20.
  - TSUKISHIRO: 25 presses, 0 / 21 / -.
  - K1 neutral: 20 presses, 2 / 11 / 2.

  Most of the dashes that hit her found her inside one of these.

## 3. The tactics by condition (all in duel/lisp/rukia-ai.lisp)

### 3.1 His dash, released: the timed perfect Hoho (RUKIA-AI-ANTI-DASH; `*AI-RU-ANTI-DASH*` EASY 0 / NORMAL 0.3 / HARD 1.0, one roll a dash)

| condition (perceived) | tactic |
|---|---|
| his move has `:params :dash`, in its main phase, its window not yet over (sf + her delay < S + 10); she is ahead of him (along > 0) and within 1.6 m of his facing line; her flash step allows a Hoho | the predicted gap at her press (RUKIA-AI-DASH-GAP: standing until S, then the clamped d + 1.6 m over 8 f; d is the release distance) within `*AI-RU-DASH-GAP*` 3.4 m: **Hoho** (PERFECT: the counter, his inputs locked, then her cash table and the K route; slightly early: a plain dodge, the dash whiffs) |
| the predicted gap is still larger | nothing yet (re-checked every step until the window ends; the roll is per dash) |

The gap was measured, not hand-set (Lille, 160 HARD matches, with 3.2):

| `*AI-RU-DASH-GAP*` | wins / 160 |
|---|---|
| 2.9 | 84 (his hit lands on the Hoho's frame) |
| 3.2 | 138 |
| **3.4** | **131** (kept: the middle of the plateau, away from the cliff below 3.0) |
| 3.5 | 124 |
| 3.8 | 131 (more early, plain dodges) |

On its own (gap 2.6, before the wait) she won 14 instead of 10 of 40. With 2.6, 92 Hohos went perfect on the hit's own
frame and the hit still landed; with 3.2 that dropped to 11. The perfect counter hits him 66 times and is absorbed by his
wing armour 78 times (the dash is armoured). Both cases avoid the combo, which is what was costing her the Konpaku.

The ASSIST's AUTO GUARD gets the same answer (`:assist-guard` RUKIA-ASSIST-GUARD: defensive, the brain passed in).

### 3.2 His dash form at a neutral decision: the wait (RUKIA-AI-MU-DASH; `*AI-RU-MU-DASH*` 0 / 0.3 / 1.0, one roll a decision)

| condition | options (payoff weights, measured) | pick |
|---|---|---|
| his form's L has `:params :dash` (JILLIEL / SHIN, his EN stance; read from his kit form), d > her J1's reach + 0.3 m | the wait 1.0. The guard is about as good: a 0.7 / 0.3 wait / guard mix scored 137 vs 131 of 160, a tie. The pokes and kido scored badly (above) | the wait: her flash step and her free frames go to 3.1, her anti-step and her cash table |
| inside her J1's reach + 0.3 | (unchanged: b1a1's envelope / generic J1 and the K route) | |
| his base form or his KIN forms (their L is the snipe or the stance entry BR-TO-EN) | unchanged (b1a1's zone and kido: the bind of his KAMAE pays there) | |

The two pieces together: Lille 20 -> 67 (seeds 1-40) and 12 -> 71 (seeds 41-80) of 80, interpreted variant at gap 3.2.
The final compiled file: 74 / 80 and 133 / 160 (above). Sitting still does not cost pacing: the BARRO NORMAL median is
141.6 s (b1a1 142.8).

### 3.3 Kept from b1a1 unchanged

The confirm table (K link, 白漣 valued with its oki, SHIRAFUNE / SOKATSUI with two bars, ORANGE at a full flash step), the
cash table, the oki seal, the anti-step, the envelope, the zone, no plain O, `:awaken (:melee-share 0.6 :min-taken 1800)`.
New reflex order: zero's REIDO, the seal's O, the oki, the anti-step, **the anti-dash**, the perfect Hoho, the cash, -50's
Hoho in, **the dash-form wait**, the envelope, the zone, the bands' disc. Every new chance scales EASY <= NORMAL <= HARD and
is one roll per event: a dash via BRAIN-REACT-ROLL, a decision via SIM-RND01. No new state.

## 4. Why it is not a repeat

Every earlier answer to the dash was a guard or a Hoho into the charge. This one meets the released dash with a Hoho on the
frame PERFECT-NOW-P accepts, predicted from his kit's slide. That fixes a located gap: the generic perfect-Hoho reach test
cannot see a move that travels. The neutral wait is b0a1's measured lesson, applied only to the form where it pays and read
from his kit form, not his character, so his other forms keep b1a1's play.

## 5. The awaken A/B

The awakening rule is unchanged. NORMAL's Shikai play changed only against Lille's dash forms (0.3 / 0.3), so only the BR row
can move. `python3 tools/simgate.py --summary --pairs 23 --seed0 S --seeds 60 --cmd 39002 -j 2` (she is P2, never
awakening): her wins of 60 (pass >= 20):

| S | b1a2 | b1a1 |
|---|---|---|
| 100 | 35 | 31 |
| 300 | 28 | 31 |
| 500 | 21 | 22 |

All three pass. The other 18 rows equal b1a1's by construction (no other kit has a :dash L).

## 6. Risks

- **The perfect window rests on Lille's dash rules**: S 12, `*BR-W-DASH-F*` 8, PAST 1.6, MIN 2.0, the 10 m cap (assumed),
  `*PERFECT-LEAD*` 12, `*PERFECT-INFLATE*` 1.0. If the user retunes any of them, *AI-RU-DASH-GAP* needs re-measuring (one
  pair.py sweep: below 3.0 m the Hoho comes a frame late).
- She reads his facing (SNAP yaw) and position as perceived, the release frame (his move phase) and his kit form, never his
  inputs. Against a human the same Hoho is a read of the dash's flash, as fair as the generic perfect Hoho.
- NORMAL share 0.556 (b1a1 0.542). That is close to the 0.60 edge if a later cell strengthens NORMAL further.
- Signature: the perfect Hoho's counter (not signature) is 0.09 of her damage against Lille, so the overall signature moved
  0.931 -> 0.925. The score still gains +0.031.
- Kenpachi stays 35 / 80 (§17.6, as the brief says).

## 7. Shared-code recommendations (not made)

1. ai.lisp's generic perfect Hoho (and every CPU's RUKIA-AI-PERFECT-HOHO-style reflex) tests a committed move's reach at his
   current position. A travelling move (a dash's slide, Lille's) is invisible to it until it hits. A shared
   "predicted reach" (the move's slide over its frames) would let every CPU meet it. That is a balance call for the user,
   because it would also strengthen every opponent's CPU against Lille.
2. The §17.6 post-block hold: with it gone, the guard against the dash (-12 on block) becomes a punish too.
3. aieval still counts the seal's KIKON line as no damage (as b0a0 / b2a0 / b1a1 said).

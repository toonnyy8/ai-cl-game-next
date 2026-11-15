# Kenpachi: strategy proposal (PLAN4 kit study, step 3 input, 2026-11-15)

For the user to pick from before any arm is built or searched (PLAN4 "The arms come from each fighter's kit", step 3). Each strategy is a
job derived from `sheet.md`, `catalogue.md` and the two matchup tables. The situations are written in `:rb-sp2`'s groups (PLAN4 §2: G0
lead x his red x awakenings, G1 form x distance, G2 his state x distance, G3 cells, G4 bursts, G5 exchange, G6 walls, G7 Reishi, G8 clock,
G9 pointer switch x my pointer, G10 his pointer x distance). Keys are style keys of `ken-ki-style` / `ken-kh-style` (KNOBS.md §6.1-§6.2):
`:b-*` keys are inert under these styles. Descriptors use `arms4/proof.py`'s counters where one fits (close = steps under 3 m, mid = 3-6 m,
far = over 6 m, evade, wake_kd, p2, bankai, kikon, nstart_r…). The thresholds are set against arm 0's measured rows in
`arms4/kenpachi.md` (seeds 1-100 both seats), not against the sheet alone. Where no counter fits, the new tool-side counter is named.

## General strategies (both opponents)

### 1. Out-range poke (間合い支配)
- **Idea**: stand where only my J reaches (2.4-2.6 m: my sealed J1 2.6 vs their J1 2.4) and, against Ichigo, where only my NS1a reaches
  (3.1-3.3 m); poke from there and whiff-punish their J.
- **Situations**: G1 form 0 x m-close / m-mid edge; G2 his state free x close; G10 his pointer 1 x close. Not against KESSA (her NS1a
  reaches 3.4 m) or Hisagi's bind mode (G0 his awakening).
- **Entries**: P / E (J1 2.6, NS1a 3.3, Shikai J1 3.4), Q (his J1 2.4, Ichigo NS1a 3.1), T at 2.5 m (my J beats his J), W "J1 whiffs
  @2.6" (any opener pressed by f22), S (my J1 whiff is never punished by his J1).
- **Keys**: `:kk-reach-margin` 0.5 -> 0.1-0.2 (start from reach + slide less the margin), `:kk-reach-p` 1, `:range` (the walk band's
  scale) so the generic walk holds 2.4-3.0 m.
- **Descriptor**: a new tool counter `pfar` = my J / NS hits that land from beyond his J1's far edge (2.4 m) per match, >= arm 0's x 1.5
  (the sheet's 0.2 m band: 2.4 -> 2.6). `mean_d` is the fallback, but arm 0 sits at 1.91 m and guard showed Hisagi sets the distance
  (+0.10-0.14 m only).
- **Caveat**: the band is 0.2 m wide. At 4.4 m/s a walk covers it in 3 frames and the HARD CPU sees 8 frames late (about 0.6 m), so the
  data supports it but a CPU may not hold it. Say so before searching.

### 2. Wake-up by his Hoho cells (起き攻め; generalises `bait`)
- **Idea**: after my knockdown, meaty J1 when he cannot Hoho (flash-step under 100), the bait (hold at 2.3 m, answer his wake-up) when he
  can. The meaty J1 (free+28) beats his wake-up J, NS1a and back Step; only a Hoho on his first free tick beats it (perfect counter).
- **Situations**: G2 his state down x close; G3 his cells (0 -> meaty, >= 1 -> bait).
- **Entries**: K (meaty vs J / NS1a / back Step / Hoho ticks 134-140), R13 (64 a loop), R14 (AS3, Step in, 235 / 296).
- **Keys**: `:fn ken-kh-style`, `:khf-bait-p`, `:khf-bait-d` 2.3, `:kk-meaty-p`; the cells split is a T0 job rule (G3), not a key.
- **Descriptor**: `wake_kd` <= arm 0's x 0.5 (bait's registered bar, passed vs Hisagi: .28 vs .97), now registered against **both**
  opponents. Ichigo has the same wake-up Hoho (K rows are identical for I and H).

### 3. Red Kikon on pointer 2 (replaces `spend`)
- **Idea**: a Kikon only pays on a red victim. A non-red one cancels the follow-up with any attack (C: 0 Konpaku). Pointer 2 on red takes
  3 Konpaku (sealed and Shikai), pointer 1 / 3 only 1. So as he nears red, end routes on pointer 2 (sealed J1-J3 / J1-J4 AS2, NS2 a b SA J2
  J3 AS2, the Shikai's J3 AS2) and hold the next SP only once he is red.
- **Situations**: G0 his red; G7 his Reishi low; G9 my pointer.
- **Entries**: C (red ptr 1 -1, ptr 2 -3, ptr 3 -1; non-red cancelled), R4 / R12 / R26 / R28 (routes that write pointer 2), R16 (NS2a
  held -2).
- **Keys**: `:kikon` (the hold chance), `:kk-kikon-red-p` 1 and `:kk-kikon-ptr-p` 1 (arm 0's HARD values already gate on red and on
  pointer 2). **Code needed**: the pointer-2 route choice. A style knob such as "end with AS2 when his Reishi is under X" does not exist.
- **Descriptor**: `p2` share >= arm 0's + 0.10 (arm 0's `p2` is not in the B3 sheets: measure it first), plus a new counter `kikon_k` =
  Konpaku taken by my Kikons per match, >= arm 0's x 1.5.
- Today's `spend` holds every SP (`:kk-kikon-red-p 0`). It passed on Burst + Kikon starts, but most starts are cancelled follow-ups, and it
  loses whole (K.O. win .00 vs Ichigo, .18 vs Hisagi). The catalogue's C rows explain why.

### 4. Climb to the Bankai and cash out (keeps `climb`)
- **Idea**: three neutral lunges take L0 to L3 (R23), then J1-J7 SP (182, +77, he lands 6.1 m away), then Hoho in and a KYORAN string
  (347) or ZANKAI's (396; the NS route 577), then the way back. A cash-out, not a mode: every Bankai segment burns 40 of my Reishi, and
  leaving costs 1 Konpaku.
- **Situations**: G0 even / ahead x awakened; G1 form 1 / 2; G7 my Reishi high (never start a Bankai route under half); G8 late as a
  finisher.
- **Entries**: R23, R33, R34, R42, R47, R49, R43 / R48 (the way back), C (TATE-GOTO's Kikon -3).
- **Keys**: as admitted (`:kk-climb-p 1`, `:kk-bankai-p 1`, `:kk-bk-ns-p 0.25`) plus a G7 job rule.
- **Descriptor**: `bankai` >= arm 0's + 0.05 (registered; passed .149 / .115).

### (not an arm) The late AS in the exchange
- **Finding**: as the J side of a J x NS cancel, an AS 6-10 sim frames after the contact beats both his NS going on and his SA reacting
  at f14. That covers the CPUs' reactive SA, whose `*cai-xch-sa-wait*` is 4 frames. Both forms, all four opponent forms (X). The AS at once
  loses to the reactive SA. 14 frames is too late. J2 always loses.
- This lives in the shared exchange layer (core-ai.lisp `cai-xch-step`, the x-units' keys), not in an arm: arms never name exchange keys.
  **Code needed**: a J-side AS delay knob, e.g. `*cai-xch-as-wait*`, and a unit key for it. With it, `:xch-j` 0 (never J2) for Kenpachi.
- **Descriptor**: a new counter `xwin` = exchanges whose breakthrough is mine / exchanges, >= arm 0's + 0.10.

## Targeted

### vs Ichigo: close in on the Getsuga (replaces `wave`)
- **Idea**: at 3-8 m against his pointer 2, his two charges are NS windows with no hit. Close in and hit them:
  - sealed: Hoho f0 / Step in / walk 24, then NS1 a b c (76 / 96);
  - Shikai: the lunge from up to 5.7 m;
  - never KYORAN's lunge from 5 m (it eats the wave);
  - a J at the wave's arrival cancels the wave (any form).
- **Situations**: G10 his pointer 2 x mid / far; G1 form x mid.
- **Entries**: Q-IG (the wave lands 60-81 ticks after its start, 82 / 78), G rows.
- **Keys**: `:kk-wave-p`, `:kk-hin-fs` 0, `:kk-hoho-in-p`. `*kk-wave-mix*` (cut / Hoho / close-in weights) is not an arm key yet:
  **code needed** to expose it.
- **Descriptor**: a new counter `wave_taken` = his wave hits on me per match, <= arm 0's x 0.5, measured against `a4-i-keep` (the arm that
  runs the route). `wave` failed on Steps + Hohos (x1.03). The job is not to evade, it is to hit the charge.

### vs Hisagi: hug his dead zone (replaces `guard` / `rush` there)
- **Idea**: his Shikai NS1a and Bankai ranged J1 cannot hit under 3.0 m, and my J1 (2.6) out-ranges his J1 (2.4). So stay under 3 m.
  At 3-6 m, his band, never walk in and never throw the sealed NS1a. Instead:
  - the Shikai lunge (S16, to 5.7 m) beats his NS1a (S20) and bind (S18);
  - KYORAN's lunge does the same (S14, 4.9 m);
  - a Step in + J1 beats his NS1a and ranged J1, but not the bind;
  - a Hoho on f8 perfect-counters the bind, the ranged J1 and the bind-mode NS1a.
- **Situations**: G10 his pointer 1 x mid; G1 form x mid; G2 his state free x mid. Not his bind mode (G0 his awakening; no dead zone,
  NS1a to 6.7 m).
- **Entries**: Q (H NS1a 3.0-6.4, Hr J1 3.0-6.4, bind 5.2), G (H / Hr / Hb rows), W (his dead-zone whiffs, punished by everything), S (a
  back Step or a lunge whiff into 3-6 m is punished).
- **Keys**: `:range` (the walk band under 3 m), `:kk-step-in-p` 1, `:kk-dodge-p` 1, `:kk-lunge-p` 1. **Code needed**: `:kk-lunge-p` fires
  only while climbing at pointer 1; the lunge as his-band answer needs that condition lifted.
- **Descriptor**: `mid` <= arm 0's - 0.04 (arm 0: .111 vs Hisagi). Risk: guard's proof showed Hisagi sets the distance (mean_d moved +0.10
  to 0.14 m only). If the search cannot move `mid`, the strategy is not separable by the kit.

### vs Hisagi: `bait` (kept; becomes strategy 2's cells-aware form)

## What the kit does not support (no separation in the data)

- **Zoning / keep-away / ranged play**: no core form has a projectile. Buttagiru and the charge are unbound since the core system. Nothing
  reaches past 5.7 m (the Shikai lunge), nothing sealed past 4.0 m.
- **Guard / turtle**: a core kit never guards. The defensive tools are the Hoho (100 flash-step, a 12-frame perfect window) and the Step
  (iframes 3-9, 2.5 m). A back Step from 2.5 m lands in Hisagi's band (A). That is why `guard` cut his actions instead of adding defence.
- **Rush as its own job**: arm 0 already spends 86 % of its steps under 3 m, the kit's best band. There is nothing to separate. That is
  why `rush` failed, both on `close` and on `nstart_r`.
- **Armour versus J**: NS2's armour does nothing against an NA (it cancels; Tz2). It only beats NS.
- **The tame as a neutral tool**: it hits nothing by itself. It is a read on his J / NS (parry -> thrust 66 / 83), and it never catches KESSA's
  clones (2026-11-06 catalogue F23, not re-run).
- **The Shikai's wave cut**: any J of any form cancels Ichigo's wave now (G).
- **The Bankai as a sustained mode**: it costs 40 Reishi a segment and 1 Konpaku to leave.
- **Racing KESSA with J1**: her J1 (S8) beats the sealed J1 (S9) since DUEL_KEN_V3 §48 (T IK).

## Today's arms: keep, replace, merge

| Arm | Verdict | Why (data) |
|---|---|---|
| `all` (arm 0) | keep | the base every job is measured against |
| `spend` | **replace** with 3 (red Kikon on pointer 2) | non-red Kikon follow-ups are cancelled by any attack (C); spend loses whole |
| `climb` | **keep**, add the G7 rule (no Bankai under half Reishi) | R33-R49: the Bankai pays only as a cash-out; its cost is the player's own Reishi |
| `bait` (vs H) | **keep and generalise** into 2 (cells-aware, vs both) | K: the meaty loses only to a first-tick Hoho, which needs 100 flash-step; identical vs Ichigo |
| `rush` | **drop** | no separation: arm 0 is already under 3 m 86 % of the time |
| `guard` | **drop**; against Hisagi its job becomes "hug his dead zone" | no defensive move separates; against Hisagi the real job is to stay under 3 m |
| `wave` (vs I) | **replace** with "close in on the Getsuga" and a `wave_taken` descriptor | it failed on Steps + Hohos; the answer is to hit the charge (G) |

Suggested sets: general = all, poke (1), wake-up by cells (2), red Kikon (3), climb (4). Targeted: Getsuga close-in (vs Ichigo), dead-zone
hug (vs Hisagi). The exchange's late AS goes to the shared layer for every arm.

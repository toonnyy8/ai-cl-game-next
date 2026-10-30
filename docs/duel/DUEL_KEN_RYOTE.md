# DUEL_KEN_RYOTE — the second cup (雙手 RYOTE) on the core system (2026-10-30)

User's request (verbatim, 2026-10-30): 「第二批」 (the second cup's batch of the three-cup rework, DUEL_KEN_KATATE). Asked (AskUserQuestion), answered:

| Question | Answer (verbatim) |
|---|---|
| RYOTE's character | 「劈道正統：直線、長觸及、一擊重 (Recommended)」: the kendo set as the pointers' moves |
| Pointer 3 | 「倍率高、但沒有霸體 (Recommended)」 |
| Earlier, for all cups | 同主題、各杯換個性 · 一杯一批 · 招牌收進核心 · CPU 這輪不調 |

## 1. The table (RYOTE, NOME 40+; damage x1.15, reach / startup of the base moves x1.4 / +3 as before; the new moves play as written)

| Ptr | Stance (idle, jodan rest varied) | NS segments | Its SA | AS n |
|---|---|---|---|---|
| 1 chain | `:ke-r-st-chain` chudan: the blade level at his throat | `ke-r-n1a` DO 85 (S19, reach 3.9) → `ke-r-n1b` MOROTE-ZUKI 68 → `ke-r-n1c` KABUTO-WARI 92 crumple | KOTE `ke-r-sa` (40, reach 2.4, lunge 1.4 m) | AS1: KABUTO-WARI 70 knockdown |
| 2 rush | `:ke-r-st-rush` hasso: the blade cocked back, leaning in | `ke-r-n2a` the thrust with a 3 m lunge, 85, **one armour hit** → `ke-r-n2b` DO 75, **one armour hit** | KOTE, x(1 + 0.3 per cancel) | AS2: DO 60 stagger → the thrust 100 launch |
| 3 kamae | `:ke-r-st-kamae` jodan: the blade high over the brow | `ke-r-n3a/b/c` the jodan charges (clips `:ke-chg1..3`, S 20 / 16 / 16), **no armour** | KOTE 45 / 60 / 80, charge x **1.4 / 1.8 / 2.4** (base 1.3 / 1.6 / 2.0) | AS3: MEN 50 → the thrust 55 → the meteor 190 (reach 3.9) |

Kit: `:ryote` has its own `:core`; `:also` lists the base form's core moves so NOMIHOSE derives them from RYOTE's table as before; NOMIHOSE's `:core` is the base's again
(until its batch). Clips: only the three stances are new (the strikes are the kendo clips).

## 2. Knobs (all mine)

NS 85 / 68 / 92 and 85 / 75; KOTE 40 / 45 / 60 / 80; charge x 1.4 / 1.8 / 2.4; the thrust's lunge 3.0 m; AS 70 / 60 → 100 / 50 → 55 → 190.

## 3. Checks

Host tests (`tests/duel-rules/ken.lisp` RYOTE block). Scripted scenes `tests/scripts/duel-ken-ryote.json` (debug 84002: RYOTE, NOME 70; 84010 / 84011 as before). G2 `--cvc`. No balance gates.

Results (2026-10-30): host tests 11186 all pass, pkgcheck clean, the build, smoke. Scripted scenes (combat log): NS1 DO 85 → ZUKI 68 → KABUTO-WARI 92; KOTE as the SA hit 40 only after
its reach went 1.44 → 2.4 m with a 1.4 m lunge (the NS pushes the victim away; it whiffed before); NS2 thrust 85 → DO 75; an NS landing in the thrust's startup → `ARMORED 68`;
two cancels → `NS2 SA x1.60`; NS3 SA 45 and 80 (then J2 38); an NS landing in a jodan charge → a plain `HIT 68` (no armour, by design).
G2 `--cvc`: II identical (29 lines), IK 18 → 24 lines (P2 0-3, 236.3 s), KK 24 → 18 (P2 0-3, 177.9 s); `tests/style-cvc-ref.txt` regenerated. Not done: NOMIHOSE, the CPU.

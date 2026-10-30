# DUEL_KEN_NOMIHOSE — the third cup (飲み干し NOMIHOSE) on the core system (2026-10-30)

User's request (verbatim, 2026-10-30): 「開始第三批「飲み干し」。」 (the third cup's batch of the three-cup rework, DUEL_KEN_KATATE). Asked (AskUserQuestion), answered:

| Question | Answer (verbatim) |
|---|---|
| NOMIHOSE's character | 「瘋狂失控：快、重、不防守 (Recommended)」 |
| Where KUKAN-GIRI goes | 「指針 2（硬扛）的 NS2a：一擊＋延遲裂隙 (Recommended)」 |
| The drink | 「AS 的一段：AS2 結尾自動飲，回 NOME 並短暫無敵 (Recommended)」 |
| Pointer 3 | 「不蓄力：快拔刀，一擊超重，有霸體 (Recommended)」 |
| Earlier, for all cups | 同主題、各杯換個性 · 一杯一批 · 招牌收進核心 · CPU 這輪不調 |

Note on the drink: in the code "drink" is cup 3's **guard** (U: takes the hit, half of it feeds NOME; `:drink` passive, combat.lisp), not a move. U stays as it was; the
choice above adds the drink to the core as AS2's finisher: its first frame refills NOME (`ken-gulp`, `*nome-gulp*` 20, capped) and the segment takes one hit through
(`:armor-hits 1`) — the "brief invulnerability" is implemented as that armour, not as intangible frames.

## 1. The table (NOMIHOSE, NOME 100; mult x1.2 as before; the new moves play as written)

| Ptr | Stance | NS segments | Its SA | AS n |
|---|---|---|---|---|
| 1 chain | RYOTE's chudan (cup 3 has no stance poses of its own yet) | `ke-m-n1a` DO 95 → `ke-m-n1b` ZUKI 75 → `ke-m-n1c` KABUTO-WARI 100, **each takes one hit through** | `ke-m-sa` KOTE 50 (reach 2.6, lunge 1.6) | AS1: KABUTO-WARI 80 knockdown |
| 2 rush | hasso | `ke-m-n2a` **KUKAN-GIRI** 90 (3 m lunge, the rift cuts again for 50) → `ke-m-n2b` DO 90, both armoured | KOTE, x(1 + 0.3 per cancel) | AS2: DO 65 → the thrust 110 launch + **the drink** (`ke-m-as2b`: NOME +20, armoured) |
| 3 kamae | jodan | `ke-m-n3a` **BATTOU** one segment, S14, DO-shaped 140, armoured, recovery 32, no charge | KOTE 50 | AS3: MEN 55 → the thrust 60 → the meteor 210 (reach 3.9) |

Kit: `:nomihose` has its own `:core`; its `:also` lists the base form's core moves, and the Bankai (which inherits NOMIHOSE) got the base literal `:core`, so it is unchanged.
Clips: none new (the cup-1 clip map still turns RYOTE's strikes into cup 3's `:ke-x-*`). Debug 84003 = this scene (NOME 100).

## 2. Knobs (all mine)

NS 95 / 75 / 100 and 90 (+ rift 50) / 90; BATTOU 140 (S14, R32); KOTE 50; AS 80 / 65 → 110 / 55 → 60 → 210; `*nome-gulp*` 20.

## 3. Checks

Host tests (`tests/duel-rules/ken.lisp` NOMIHOSE block). Scripted scenes `tests/scripts/duel-ken-nomihose.json` (84003). G2 `--cvc`. No balance gates.

Results (2026-10-30): host tests 11274 all pass, pkgcheck clean, debug ranges ok, the build, smoke. Scripted scenes (combat log): NS1 DO 95 → ZUKI 75 → KABUTO-WARI 100, SA KOTE 50;
NS2 KUKAN-GIRI 90 → the rift 50 → DO 90; an NS landing in the KUKAN-GIRI startup → `ARMORED 68`; one cancel → `NS2 SA x1.30`; NS3 BATTOU 140; J, J2, SP → AS2 DO 65 → SP →
the thrust 110 launch with `GULP` (NOME +20); SP, J, J2, J3, SP x3 → AS3 55 → 60 → the meteor 210. A bug found by the scene: the finisher's `ken-gulp` hung on frame 0 never ran,
because the copied thrust has `:enter 7` (a hook before a copy's `:enter` is skipped); it is now on frame 7. NOME in these scenes falls to RYOTE after ~3 s (the 20/s drain), as before.
G2 `--cvc`: II identical (29 lines), IK 24 → 18 (P2 0-5, 177.9 s), KK 18 → 19 (P2 0-5, 188.9 s); `tests/style-cvc-ref.txt` regenerated.
Not done: cup 3's own stance poses (it plays RYOTE's), the CPU (it does not know BATTOU or the drink finisher), U is still the guard.

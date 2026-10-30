# DUEL_KEN_KATATE — the first cup (片手 KATATE) on the core system (2026-10-30)

User's request (verbatim, 2026-10-30): 「可以，開始三杯（片手 / 雙手 / 飲み干し）的重設計。」 Asked (AskUserQuestion), answered:

| Question | Answer (verbatim) |
|---|---|
| How far | 「同主題、各杯換個性」: every cup keeps the pointer themes (chain / rush / kamae), re-skinned by the cup's character |
| Batches | 「一杯一批：片手 → 雙手 → 飲み干し」 |
| The signatures (SP1 meteor, KUKAN-GIRI, the drink) | 「收進核心：變成某指針的 NS / AS 段」 (the meteor is already AS3's last segment; KUKAN-GIRI and the drink come with their cups' batches) |
| CPU | 「這輪不調」 |
| KATATE's character | 「重甘 + 空著的左手出拳」: the free left hand is a second weapon |
| Pointer 3 | 「片手架式：蓄力的倍率改為低、但不被打斷」 |

## 1. The table (KATATE, NOME 10–40; damage x1.0, the base moves' reach x1.3 and +2 startup as before)

| Ptr | Stance (idle) | NS segments | Its SA | AS n |
|---|---|---|---|---|
| 1 chain | `:ke-kt-st-chain`: the left hand open, loose, low | `ke-n1a/b/c` the K string 70 / 60 / 80 (the one-handed clips, as before) | **left jab** `ke-kt-sa` (7 f, 30, reach 1.7) | as the base: AS1 the drop 40 knockdown |
| 2 rush | `:ke-kt-st-rush`: a clenched fist forward, hunched | `ke-kt-n2a` the shoulder charge (S 24, 90, one armour hit) → `ke-kt-n2b` **the clamp and slam** (S 14, 60, reach 1.8, lunge 2.0 m, one armour hit) | `ke-kt-sa-r` the jab, x(1 + 0.3 per cancel) | AS2: the grab and smash 55 → BUTTAGIRU launch 100 |
| 3 kamae | `:ke-kt-st-kamae`: upright, a raised guard hand | `ke-kt-n3a/b/c` three one-handed charges (S 20 / 16 / 16), **each takes one hit through** (`:armor-hits 1`, frames 6 to S-1) | `ke-kt-sa-c1/2/3` the jab 40 / 55 / 70, charge x **1.2 / 1.4 / 1.6** (the base's 1.3 / 1.6 / 2.0) | AS3: K1 50 → K2 55 → the meteor 170 |

Kit: `:nozarashi` gets its own `:core` (`ken.lisp`); `:also` (new, `core-move-names`) keeps the base form's core moves in its table so RYOTE derives them as it did;
RYOTE's `:core` is the base form's again (NOMIHOSE inherits it) until their own batches. New moves play as written (no +2 / x1.3).
Clips (`ken-art.lisp`): the three stances, `:ke-kt-jab`, `:ke-kt-slam`, `:ke-kt-chg1..3` (the left fist clenches and rises).

## 2. Also fixed: NS2b whiffed

NS2a's stagger pushes the victim out of NS2b's reach, so the sweep (base, 2.4 m) and the slam never hit in the scripted scene. Both now lunge 2.0 m (`:slide 2.0`),
the base form's too (its second segment had been unverified since DUEL_KEN_CORE §6).

## 3. Knobs (all mine)

Jab 30 / 40 / 55 / 70; charge x 1.2 / 1.4 / 1.6; slam S 14, reach 1.8, lunge 2.0; NS2a S 24; the armour hit per charge.

## 4. Checks

Host tests (`tests/duel-rules/ken.lisp` KATATE block: classes, tells, stances, the armour, the charge x, the base moves kept, RYOTE / NOMIHOSE keep the base core and RYOTE's x1.4 reach).
Scripted scenes (`tests/scripts/duel-ken-katate.json`, debug 84001, 84010, 84011).

Results (2026-10-30): host tests 11032 all pass, pkgcheck clean, the build, smoke. Scripted scenes (combat log): NS1 70 / 60 / 80; SA jab 30; NS2 shoulder 90 → clamp 60
(whiffed before the lunge); an NS landing in NS2a's startup after frame 6 → `ARMORED 68`, then NS2a 90; one cancel → `NS2 SA x1.30`, the jab 30; NS3 ×1 → SA-C1 40 → J2,
×3 → SA-C3 70; an NS landing in a charge → `ARMORED 68`. The base form's scene `duel-ken-core.json` still passes and its NS2b now hits 60. G2 `--cvc`: II identical (29 lines),
IK 27 → 18 lines (P2 0-4, 177.1 s), KK 24 → 24 (P2 0-3, 238.9 s); `tests/style-cvc-ref.txt` regenerated. No balance gates (the user, 2026-10-29). Not done: RYOTE, NOMIHOSE, the CPU.
The left hand sits on the far side from the default camera (behind him), so the stances and jab read best from the side camera.

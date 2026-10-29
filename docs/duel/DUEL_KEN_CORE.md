# DUEL_KEN_CORE — Kenpachi's base form rebuilt on the core system (2026-10-29)

User's request (verbatim, 2026-10-29): 「請幫我依據 skill 在新的系統框架下重新設計劍八的戰鬥邏輯」. Asked (AskUserQuestion), answered:

| Question | Answer (verbatim) |
|---|---|
| Scope | 「只做常態（base）」: the base form only; KATATE / RYOTE / NOMIHOSE / Bankai / KATAUDE inherit the new kit as it is (their cups, NOME and the arm unchanged), each reworked later. |
| The pointers' themes | 「以連斬壓制為主題/以霸體硬扛與粗暴突進為主題/以劍道姿勢看穿對手的破綻並打出大幅傷害為主題」: 1 / 2 / 3 in order. |
| What to change | 「NS 節奏與預兆,AS 與連段收尾,劍八特色機制整合」 (his CPU not ticked). |
| Pointer 2's armour | 「NS2 前搖到 active 吃一發不退，抵銷不扣霸體，過程中抵銷越多次 SA 傷害越高」 |
| Pointer 3 | 「NS3 的 a, b, c 三段都是續力架式，會依序提高靈壓特效與後續連段的輸出」 |

## 1. The segment table (base form; S = startup)

| Ptr | Theme | Stance (idle clip) | NS segments | Its SA | AS n | Kikon cinematic |
|---|---|---|---|---|---|---|
| 1 | the chain (連斬壓制) | `:ke-st-chain`: leaning in, the blade carried low and forward | `ke-n1a` K1 S16 70 → `ke-n1b` K2 S20 60 → `ke-n1c` K3 S20 80 (as before) | `ke-sa` (J1, 36) | AS1: `ke-as1`, the K3 drop, knockdown (no steal) | `ken-kikon-cine` (CHARGE and its flurry) |
| 2 | the rush (霸體硬扛與粗暴突進) | `:ke-st-rush`: hunched, the blade on the shoulder, weight on the front foot | `ke-n2a` BUTTAGIRU's leap S22 90 stagger → `ke-n2b` the kick S14 (was 8) 60; **both `:armor-hits 1`** | `ke-sa-r`: 36 × (1 + 0.3 × cancels) | AS2: `ke-as2` (K1, S16, 55 stagger) → `ke-as2b` BUTTAGIRU, 100 launch | `ken-kikon-cine` (its own later) |
| 3 | the kamae (劍道架式續力) | `:ke-st-kamae`: upright, the blade on the centre line in both hands | `ke-n3a` S20 / `ke-n3b` S16 / `ke-n3c` S16: three charges that hit nothing (clips `:ke-chg1..3`, each higher), `:aura-k` 1.5 / 2.2 / 3.0 | `ke-sa-c1` 45 ×1.3 / `-c2` 60 ×1.6 / `-c3` 80 ×2.0 (the `:charge-mult` on the J string and the AS after it) | AS3: `ke-as3` (K1 50) → `ke-as3b` (K2 55) → `ke-as3c` the meteor 170, knockdown | `ken-sky-split-cine` |

Kit `:core :mult` stays 1.2. AS n = n segments, each a fresh SP press, only the last knocks down or launches.

## 2. Mechanics added

- **NS2's armour.** `:armor-hits 1` on both segments; `ken-armor` (the kit's `:armor` hook) extends it from move frame 6 (`*armor-from*`) to the end of the
  active frames (it was the startup only). The triangle judges first: a cancel does no damage, so it never spends the armour (「抵銷不扣霸體」);
  a hit that lands (an AS, or an NS that was first) spends it, and the segment goes on.
- **Cancels feed the SA.** `ken-clash` (`:clash` hook, once a step per exchange) counts a cancel while he is in a segment with `:params :clash-count`
  into `fighter-clash-n` (new, capped at `*ken-clash-max*` 5; reset at the start of a fresh NS route, `core-note-start!`). `ken-dmg-mult`
  (`:dmg-mult` hook) multiplies the SA of the gap (`:params :clash-scale` 0.3) by 1 + 0.3 × the count: 36 → 47 / 58 / 68 / 79 / 90.
- **NS3's charges** use the existing machinery (Ichigo's NS2): a segment's `:params :sa` names the SA of its gap; the SA's `:charge-mult` is armed on
  the fighter and multiplies the J string and the AS after it. The reiatsu look: a move's `:params :aura-k` scales his form's aura while it
  runs (`draw.lisp`, only a move that names it).
- The hooks sit on the base kit and on `:nozarashi` (which replaces `:hooks`), so every cup has them.

## 3. Knobs (all mine; the user decides by playtest)

`*ken-clash-max*` 5; `:clash-scale` 0.3; charge ×1.3 / 1.6 / 2.0; SA damage 45 / 60 / 80; NS2b S 8 → 14 (its armour window needs frames); AS2 / AS3 first
segments 55 / 50 / 55 stagger. Open: pointer 2's Kikon cinematic (reuses CHARGE's), new clips for NS2 / AS segments (retagged old ones), the CPU
(it does not know the kamae or the armour; not ticked by the user).

## 4. Checks

Host tests: 10899 checks all pass (`tests/duel-rules/ken.lisp` pins the classes, the tells ≥ 14, the stances, AS n = n segments, the armour, the
charge order, the hooks on every cup; the Hisagi pins that no other kit had a `:clash` / `:dmg-mult` hook now allow Kenpachi's). Browser, scripted
(`tests/scripts/duel-ken-core.json`, debug 84000 / 84010 / 84011, DUEL_GAMEPLAY; the combat log):
NS1 ×3 → `KE-N1A` 70, `N1B` 60, `N1C` 80. NS2 with Ichigo's NS landing on f9 of NS2a → `P2 IC-N1A -> P1 ARMORED 68`, then `KE-N2A -> P2 HIT 90`
(the armour took it); landing on f4 (before `*armor-from*`) → a plain hit, NS2a interrupted. NS2 with a J1 cancel → `NS2 cancel 1`, then the SA
`NS2 SA x1.30`. NS3 ×1 → SA-C1 45 → J2; ×3 → SA-C3 80 → J2: Ichigo's Reishi lost 36 against 60 (the ratio 1.67 the charge ×1.3 / ×2.0 predicts).
G2 `--cvc`: II identical (29 lines), IK 34 → 33 lines (P2 0-3, 323.8 s), KK 27 → 25 (P1 3-0, 244.9 s); `tests/style-cvc-ref.txt` regenerated. No balance gates
(the user, 2026-10-29). Not done: the playtest Artifact, new clips for the retagged NS2 / AS segments, pointer 2's own Kikon cinematic, the CPU.

## 5. Pointer 1 no longer steals flash-step (the user, 2026-10-29)

「不需要每個角色的 NS1 都剝奪閃步量表，我會根據人物特色訂製不同的 NS」. The steal is a per-move param (`:steal-fs`), not a rule of the system, so each kit
decides. Kenpachi's `ke-as1` loses `:steal-fs 120` (damage 40, knockdown as before); what pointer 1 does instead is the user's to define. Ichigo's and
Hisagi's AS1 (`:steal-fs 120`, and the blood-chain AS1's 30) are left as they are until the user says.

## 6. The second batch: base's open items (the user, 2026-10-30)

「開始第二批」, asked which part; answer 「補完 base 的未完成項」. Then asked (AskUserQuestion): pointer 2's new strikes 「蠻力肩撞與橫掃」, pointer 2's Kikon
「新做「硬扛衝撞」演出」.

- **Pointer 2's strikes.** NS2a `ke-n2a` is a low shoulder charge (clip `:ke-rush-a`, S22 A4 R26 as before; the BUTTAGIRU crack and ranged flag are gone, the leap's
  slide and volume stay); NS2b `ke-n2b` a flat backhand sweep (`:ke-sweep`, S14, **reach 0.88 → 2.4 m, arc 60 → 140**: the sweep must read wide); AS2a `ke-as2` the grab and smash
  (`:ke-smash`, S16, reach 2.8 → 1.7 m, 55 stagger); AS2b stays BUTTAGIRU's launch. Stance poses `:ke-st-rush` as the base of all three. AS3's first segments keep K1 / K2 (pointer 3's
  kendo slashes).
- **Pointer 2's Kikon** `ken-clash-kikon-cine` (176 f): white card, the stamp 来いよ (KOI YO) in black, the shoulder charge drives him into the ground, a held wide-angle push, the smash through
  him (negative, manga page, shatter, splash), the laugh. Debug 2219 (`force-cine` 19), `*cine-names*`, `*hurt-cines*`. Browser stills at frames ~20 / 90 checked.
- **The CPU.** A charge segment (`:params :charge-sa`, NS3 a / b / c) with the opponent inside 2.6 m: the last one always cashes its SA in, the earlier ones half the time (`cai-move-step`, core-ai.lisp;
  no other kit names the param). Not done: a CPU that picks pointer 2's NS to bait a cancel.
- Checks: host 10899 and cine 18 pass, pkgcheck clean; the scripted scenes of §4 give the same numbers; G2 II identical, IK / KK regenerated.

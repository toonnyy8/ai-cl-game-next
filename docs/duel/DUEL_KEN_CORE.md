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

## 7. The redesign of every form (the user, 2026-11-02)

「我要重新設計劍八的模組與戰鬥邏輯了」. The research first (`docs/research/kenpachi-rework/combat-refs.md`, DEVLOG §555), then asked
(AskUserQuestion), answered:

| Question | Answer (verbatim) |
|---|---|
| The pointer themes across the forms (the research favours a verb per form; the cups were 「同主題、各杯換個性」, DUEL_KEN_KATATE) | 「各形態重新定義指針」: every form defines its own three pointers (theme, stance, NS, AS, Kikon), replacing 「同主題、各杯換個性」. Pointer-theme linkage (DUEL_CORE §5b) still holds inside each form. |
| The first batch | 「節奏：前搖分級與打擊停頓」: a startup tier and a hitstop per form (combat-refs §3 C1–C5) |

### 7.1 The cadence today (host dump of the kits, 2026-11-02)

S = startup frames; hitstop by kind (`kit.lisp` `parse-move`): J / SA 4 f (`*hitstop-light*`), every NS / AS hit 8 f (`*hitstop-heavy*`);
no Kenpachi move sets its own `:hs`.

| Form | J1 S | NS1 a → b → c | NS2 a → b | NS3 (charges) | AS2 | AS3 | SA S |
|---|---|---|---|---|---|---|---|
| base | 7 | 16 → 20 → 20 | 22 → 14 | 20 → 16 → 16 | 16 → 22 | 16 → 20 → 26 | 8 |
| KATATE (+2) | 9 | 18 → 22 → 22 | 24 → 14 | 20 → 16 → 16 | 18 → 24 | 18 → 22 → 28 | 7 |
| RYOTE | 10 | 19 → 21 → 21 | 21 → 19 | 20 → 16 → 16 | 19 → 21 | 10 → 21 → 26 | 9 |
| NOMIHOSE | 10 | 19 → 21 → 21 | 20 → 19 | 14 (BATTOU, one segment) | 19 → 21 | 10 → 21 → 26 | 9 |
| Bankai (base `:core`) | 8 | 19 → 23 → 23 | 25 → 17 | 23 → 19 → 19 | 19 → 25 | 19 → 23 → 29 | 11 |
| KATAUDE (base `:core`) | 7 | 16 → 20 → 20 | 22 → 14 | 20 → 16 → 16 | 16 → 22 | 16 → 20 → 26 | 8 |

Read against the research: the NS1 strings and the AS enders get **slower** after the opener (由急至緩), the opposite of C1
(only the opener needs the tell); the forms differ by a flat +2 / +3 startup, and their hits all freeze 4 / 8 f (C3, C4). The sim
does not step during a hitstop (`main.lisp` `time-step`, a global freeze), so link windows already count from its end (C5 holds).

### 7.2 Batch 1: the startup tier and the hitstop by damage (the user, 2026-11-02)

Asked (AskUserQuestion), answered (verbatim):

| Question | Answer |
|---|---|
| The segments' cadence (today the later segments are slower) | 「依據每段的主題與武器決定」: no blanket slow-to-fast rule; each segment's startup is set with its form's new pointers (later batches) |
| The NS openers' startup tier | 「以武器重量分級為主，再來依據攻勢猛烈程度以及是否雙手持械決定。武器重量以武士刀最輕，卍解的片手斧次之，始解的大刀最為沉重。」 |
| Which way two hands and a fiercer form move it | 「兩者都變快」 (two hands -3; fiercer, up to -3) |
| KATAUDE and NOMIHOSE in the tiers | 「取消掉片腕的狀態，飲干算雙手持」 (KATAUDE's removal: §7.3) |
| The numbers | 「可以」: weight bases katana 14 / one-hand axe 18 / cleaver 22, floor 14 |
| The hitstop | 「依傷害大小縮放」, formula 「4 + (傷害−30)/10，4–14 f」: from the move's base damage, rounded, Kenpachi only |

| Form | Weapon (base) | Two hands | Fierce | NS opener S (was) |
|---|---|---|---|---|
| base | katana 14 | — | 0 | **14** (NS1a 16, NS2a 22) |
| KATATE | cleaver 22 | — | 0 | **22** (18, 24) |
| RYOTE | cleaver 22 | -3 | 0 | **19** (19, 21) |
| NOMIHOSE | cleaver 22 | -3 | -3 | **16** (19, 20, BATTOU 14) |
| Bankai | one-hand axe 18 | — | -2 | **16** (19, 25) |

Hitstop = round(4 + (damage − 30) / 10) within 4–14 f on every damaging hit of every form (was 4 for a J / SA, 8 for the rest):
J1 35 → 4, NS 60 → 7, 70 → 8, 90 → 10, charged SA 80 → 9, AS2's launch 100 → 11, BATTOU 140 → 14, the meteor 170 → 14, AS1's drop
40 → 5 (lighter than before), KUKAN-GIRI's rift 50 → 6.

- **Code.** Two generic kit keys (`kit.lisp`, nil for every other kit): `:open-s` (KIT-CADENCE → MOVE-WITH-STARTUP: each NS first segment
  that hits starts on frame S; frames inside the old startup, i.e. its early hooks and `:enter`, scale with it as its clip does, and
  the hits and later frames shift; the clip speed follows so it still lands on S; a charge segment keeps its length) and `:hs-dmg`
  (MOVE-HS-BY-DAMAGE, HS-BY-DAMAGE). Copies are shared through `*cadence-moves*`, so a move two forms hold stays one move. Knobs
  `*ken-open-base*` / `-katate*` / `-ryote*` / `-nomihose*` / `-bankai*` and `*ken-hs-dmg*` (tuning.lisp). The rift's own hit
  window uses the same formula.
- The later segments, AS, SA and J keep their startups (the user: each segment by its theme, later). KATATE's NS1 is now 22 → 22 → 22.
- The sim freezes during a hitstop, so the longer hitstops move no link window (C5).
- **Checks.** Host tests 11305 all pass (new pins: the formula, each form's `:open-s` and openers, a charge's length kept, a shifted
  opener's window and clip speed, Ichigo's kit without the keys); pkgcheck clean; the build; the playtest Artifact v278. Scripted scenes
  `duel-ken-{core,katate,ryote,nomihose}.json` against a baseline build of the parent commit: every route connects as before; the
  timed exchanges moved with the faster openers and longer cancel hitstops (base / NOMIHOSE NS2 now take two cancels before the SA,
  ×1.60; NOMIHOSE's BATTOU at S16 now meets P2's NS as a cancel instead of hitting first). The "N2 cancel x1 then SA" scene's J went
  0.9 → 0.5 s after the SP, since RYOTE's NS2a (S 21 → 19) left P2's J1 to punish its recovery at 0.9 s; it now shows the cancel and
  the SA in all three cups. G2 `--cvc`: II identical (28 lines), IK 18 → 26 lines (P2 0-7, 258.5 s), KK 17 → 22 (P1 3-0, 215.7 s);
  `tests/style-cvc-ref.txt` regenerated. No balance gates (the user, 2026-10-29).

### 7.3 KATAUDE (open)

「取消掉片腕的狀態」 (2026-11-02, DEVLOG §558).

Asked (AskUserQuestion) what the arm's burst leads to instead: 「只拿掉片腕，其他先不動」. The Bankai's `:pips :to` KATAUDE → **NIL**:
`arm-burst!` (combat.lisp) keeps the form when `:to` is NIL; the burst itself stays (120 burnt, the 40 f crumple, the callout), then he
fights on in the Bankai with no pips (a pip command is refused, as at 0 before). The arm meter, its cost and the burst's aftermath are
redesigned with the Bankai's pointers. The `:kataude` kit, its art and its debug scenes (2389, the HUD review) stay in code, unreachable
in play, until that batch. Scene `tests/scripts/duel-ken-armburst.json` (debug 2388, the Bankai with 1 pip): `[300] UDE cracked, 0 left`,
`[301] ARM BURST r1180`, no form line, then J is `KE-B-J1 -> P2 HIT 38` (the Bankai's). Manual, TUTORIAL and DUEL_DESIGN updated.

## 8. The Bankai on the core system (the user, 2026-11-02)

The first form of the redesign (「卍解」, asked which form first). Asked (AskUserQuestion), answered (verbatim):

| Question | Answer |
|---|---|
| The three pointers' themes: A canon's beats (the maw / the broken cleaver / the roar and the split), B the research's berserker mechanics (a beast flurry / an armoured trade / the self-destroying arm), or A + B's arm | 「A 加 B 的自毀之臂」: 1 the maw, 2 the broken cleaver, 3 the self-destroying arm |
| The arm 「腕」's role | 「大招的燃料」: the big segments burn its pips; the last one gone, it bursts |
| The segment table (below) | 「可以」 |
| The crack clock (a pip every 5 s) | 「拿掉」 |
| The three Kikon cinematics | 「先沿用，後續新做」 |

| Ptr | Theme | NS (S, damage, reaction) | Its SA | AS n | Kikon (for now) |
|---|---|---|---|---|---|
| 1 | the maw 撓咬 | `ke-b-n1a` the claw lunge TSUKAMI S16 70 stagger, 1.5 m → `ke-b-n1b` KAMICHIGIRI S12 90 stagger, unguardable → `ke-b-n1c` the rip S14 100 crumple | `ke-b-sa1` the left hook 40 | AS1 `ke-b-as1` KUICHIGIRI (bites the arm off) 120 knockdown | `ken-oni-kikon-cine` |
| 2 | the broken cleaver 斷刀劈砍 | `ke-b-n2a` the leap cut TOBIGIRI S16 90 stagger, 3 m → `ke-b-n2b` the flat-side hammer S18 100 crumple | `ke-b-sa2` a hack 45 | AS2 `ke-b-as2` NAGURI-TOBASHI 60 stagger → `ke-b-as2b` the leap chop 110 launch | `ken-oni-kikon-cine` |
| 3 | the self-destroying arm 自毀之臂 | `ke-b-n3a` UDE-KUDAKI S16 130 stagger → `ke-b-n3b` S14 150 crumple → `ke-b-n3c` TATE-GOTO S20 220 crumple, **1 pip each** | `ke-b-sa3` the sweep 50 | AS3 (canon ch. 670's order) `ke-b-as3` the leap cut 55 → `ke-b-as3b` the chin punch 60 (lunge 2.0 m) → `ke-b-as3c` TATE-GOTO 200 knockdown, **1 pip** | `ken-sky-split-cine` |

- **Deviation from the approved table**: NS1c and NS3c crumple instead of knocking down, since the SA can follow any NS segment (the
  §443 red flag: a knockdown there makes the SA whiff).
- **The arm.** A core move's `:params :pips` (generic, core-sim.lisp `core-pips-ok-p` / `core-start!`): it starts only when the arm holds
  that many pips and burns them on its first frame (ARM-SPEND!, 60 Reishi each, never below 1); refused, the SP press is eaten once
  (`P1 refused KE-B-N3A: no pip`), not retried. The Kikon's strike burns one more when there is one (it strikes anyway at 0). The last pip
  gone: the burst (120, the 40 f crumple), and he stays in the Bankai (§7.3). No crack clock: the kit's `:pips :crack nil` (ken-meter.lisp
  skips PIP-STEP; the web HUD gets -1 for the clock, no `hurry` pulse).
- **Clips** are placeholders (the claw = the left hook, the rip = the bite, the stances all `:ke-b-stance`): the art round is next, with
  the two new Kikon cinematics after the playtest.
- **Debug** 84004 (the Bankai, the arm full, an idle Ichigo 2.2 m), 84080+k (the arm at k pips). **The CPU** uses the generic core CPU; it
  does not know the pips (a refused press is only lost).
- **Checks.** Host tests 11331 all pass (the Bankai block: classes, chains, SAs, startups 16 / 12 / 14 / 16 / 18 / 16 / 14 / 20, the pips
  0 0 0 0 0 1 1 1 0 0 0 0 0 1, no knockdown on an NS segment, the AS enders, the damage); pkgcheck clean (`debug-ranges-check.py` reports
  one overlap, 2510-2513 vs 2513, that was there before this change); the build; the playtest Artifact v280. Scene
  `tests/scripts/duel-ken-bankai.json` (combat log): NS1 70 → 90 → 100; SA1 40 → J2 38; NS2 90 → 100; SA2 45; NS3 at 4 pips 130 → 150 → 220
  (UDE 3 → 2 → 1 left); at 1 pip NS3a 130 (0 left), NS3b refused, ARM BURST, still the Bankai; at 0 pips refused once; AS1 120; AS2 60 → 110;
  AS3 55 → 60 → 200 (UDE -1); the Kikon off AS1 (held SP) burns one (3 left) and plays the oni cinematic. Found by the scene: AS3b's punch
  (2.0 m) whiffed after AS3a's push: lunge 2.0 m added. `duel-ken-armburst.json` now burns the last pip on NS3a (the crack clock is gone).
  G2 `--cvc` identical in all three pairs (no CPU match reaches the Bankai).

## 9. His SP costs (DUEL_SP §4, batch S2, 2026-11-13)

The user (2026-11-12): 「劍八的 SP 攻擊會扣除自身血量，作為交換，請將他 SP 造成的消耗降回平均水準」. Each of his four kits carries a
`:core :sp-cost-mult` that brings its mean segment cost to about Ichigo's and Hisagi's: base **0.76**, Shikai **0.68**, Bankai 狂嵐
**0.71**, Bankai 斬壞 **0.51** (ken.lisp; `def-ken-bankai` takes it as a key). A segment's cost = its damage x 0.4 x the multiplier, rounded
once to 5, clamped 10-60. Route totals (host-pinned in tests/duel-rules/sp.lisp, from the kits' own tables):

| Form | NS | AS |
|---|---|---|
| base | 55 / 55 / 60 (NS3a the tame: 10) | 25 / 50 / 75 |
| Shikai | 100 / 120 | 85 / 110, bursts 25 / 25, DAISHARIN 60, INSEKI-GIRI 60, the Bankai burst 25 |
| 狂嵐 | 90 | 30 / 55 / 75 / 95, CHIGIRI 60 |
| 斬壞 | 85 | 30 / 50 / 70 / 90, TATE-GOTO 60 |

The tame's catch (a parry answering with the thrust, NS3b) pays its 20 like a pressed segment and is refused at 0 like one. His Bankai
segments still burn `*ken-bk-cost*` Reishi on top (a price, not scaled by the SP damage scale).


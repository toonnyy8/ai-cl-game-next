# SOUL DUEL: Yamamoto on the core system (design, 2026-11-19)

Yamamoto (roster 0, retired since the core system, his old code on the branch `retired-kits`: `yama.lisp`, `yama-art.lisp`,
`yama-vfx.lisp`) comes back as a core kit. This file is the rule design; the look and motion records stay in DUEL_YAMA_TYBW (the TYBW
look per form, the motion bars) and DUEL_YAMA_REWORK (the old Bankai), the canon in `docs/research/yamamoto-rework/` (`canon-looks.md`
§4 the four directions of Zanka no Tachi, `motion-refs.md`).

## 1. The request (the user, 2026-11-19, verbatim)

> 我想要開始設計山本重國的角色玩法：
> - 始解狀態會透過炎熱量表來強化 NS 攻擊，NS 以外的攻擊手段會使量表不斷累積。當到達最高點時會進入爆炎狀態，隨時間減少量表且在解除狀態前不會繼續累積量表。爆炎狀態除了強化所有攻擊（變招）外還會隨時間逐步扣除血量，此時使用 NS 與 AS 將不再消耗閃步量表，且可以透過 NS 主動消耗量表以提早脫離爆炎狀態。
> - 卍解則是將殘火太刀「東」「西」「南」做成三種不同的指針，並再湊齊三個指針標記後短暫進入最強的特殊指針：「北」·天地灰盡

## 2. Decisions (AskUserQuestion, 2026-11-19; the user's pick in bold, the rejected listed)

| # | Question | Answer | Rejected |
|---|---|---|---|
| Y1 | When do NA / SA / AS add heat? | **「命中或相消才加」**: a hit or a cancel adds, a whiff does not | on every start (whiffs too); hits plus being hit |
| Y2 | How does a normal-state NS use heat? | **「花熱量換強化」**: NS spends heat for power, so the player may stay below the top and avoid 爆炎 | read the level only, never spend; both |
| Y3 | How is the spend sized? | **「每段花固定量，依比例加成」**: each NS segment spends a fixed amount, pays what is left when short, and its boost is in proportion to what it actually paid (like the flash-step gauge's short-pay scaling, DUEL_SP §3) | one cell a segment, strong / plain versions; the route's first segment spends everything |
| Y4 | Does 爆炎's Reishi drain kill? | **「不會，最低留 1」**: never below 1, as Kenpachi's SP Reishi cost (KEN-BK-COST) | can kill; stops at red |
| Y5 | The Shikai's three pointer themes | **1 不知火 / 2 城郭炎上 / 3 撫斬** (the user's reply spells the third 「撚斬」, the option's 撫斬 = canon Nadegiri) | 1 松明 / 2 城郭炎上 / 3 一骨; the user's own |
| Y6 | How are the Bankai's East / West / South marks earned? | **「AS n 寫入該指針」**: AS1 gives East, AS2 West, AS3 South, when the AS writes its pointer | an NS hit under that pointer; an NS or AS hit under it |
| Y7 | How long does North (天地灰尽) last? | **「一次北的 NS 或 AS」**: one North move (hit or whiff), then back to the pointer before it; the marks clear | a fixed time (e.g. 8 s); until he is hit or a time-out |
| Y8 | 城郭炎上's ring (§9 Q1) | **「會燒的火環，可穿過」**: a burning ring, no collision; Step and Hoho pass, crossing it hurts | a cage that stops walking out; both |
| Y9 | 爆炎's early exit (Q5) | first **「只有指定的才消耗」**; the lead's own example (hold SP) collides with the Kikon hold (a held SP from the segment's start through its hit is the Kikon's input, `fighter-sp-held`), so asked again: **「那改回使用 NS 就消耗熱量」**: every 爆炎 NS segment spends 25 | hold = spend; a landed Kikon clears heat (RoS 1.10); the pointer switch spends |
| Y10 | (the same answer) | **「且對手相消時也會受到灼燒傷害（HP 不會因此被扣的 0）」**: in 爆炎, a cancel with him burns the opponent; never to 0 (floor 1) | — |
| Y11 | 西's NS c (Q4) | **「帶霸體的反擊斬」**: an armoured counter-cut that always swings, inside the triangle | a parry (the old GOKUI GAESHI) |
| Y12 | The pointer tables (§7) | **「可以，開始實作」**: batch 1 starts | change first |
| — | Told the user with the plan, not objected | NADEGIRI's split a look only; 爆炎's entry a short invulnerable pose at the next neutral; 北's Konpaku = pointer 3's profile | — |

## 3. The Shikai: Ryūjin Jakka and the heat gauge

| Rule | Value (knob, the lead's first number; tuned by play) |
|---|---|
| The gauge | heat 0-100 (`*ya-heat-max*`), starts at 0 each match and at each Shikai entry; drawn under the flash-step gauge |
| Gains (Y1) | on a hit or a cancel only: NA +8, SA +10, each AS segment +12 (`*ya-heat-gain*`); NS adds nothing; a whiff adds nothing |
| NS spend (Y2, Y3) | each NS segment spends 25 (`*ya-heat-ns*`), or what is left when short; damage x (1 + 0.3 x paid / 25) (`*ya-heat-boost*` 0.3); at 0 heat a plain segment. The flash-step cost is paid as for any NS (DUEL_SP §3) |
| 爆炎 entry | heat reaching 100 enters 爆炎 at once (the form `:blaze`, its own move set: 「變招」) |
| 爆炎 decay | heat falls 10 / s (`*ya-blaze-decay*`: 10 s from full); no gain of any kind until it ends |
| 爆炎 Reishi drain | 2 % of max Reishi / s (`*ya-blaze-drain*`), never below 1 (Y4) |
| 爆炎 SP | NS and AS segments cost no flash-step gauge (as during a burst, DUEL_SP §2); NA / SA as usual |
| 爆炎 early exit | each NS segment spends 25 heat (`*ya-heat-ns*`) at the 爆炎 move's fixed power (no proportional boost: 爆炎's variants are already the strong set); heat at 0 ends 爆炎 (Y9; a cancelled segment gets its heat back, §7.4) |
| 爆炎 cancel burn | a cancel between his move and the opponent's (any class, either side's hit) burns the opponent 25 % of his cancelled move's base damage (`*ya-blaze-burn*` 0.25), never below 1 (Y10); no hitstun, no combo count |
| 爆炎 end | back to the Shikai's set, heat 0 |
| Awakening in 爆炎 | allowed; 爆炎 ends, heat leaves with the Shikai (the Bankai has no heat) |

Pointer themes (Y5; DUEL_CORE §5b: a pointer's stance, NS, AS n and Kikon share it; each has a 爆炎 variant):

| Pointer | Theme | Canon / old kit | Job (DUEL_CORE §3) |
|---|---|---|---|
| 1 | 不知火 SHIRANUI | the flame spiral thrust (old SP1) | heavy damage, long reach |
| 2 | 城郭炎上 JOKAKU ENJO | the fire walls and pillars (old O) | control: placing walls that shape his lane |
| 3 | 撫斬 NADEGIRI | the unseen draw-cut, the split a beat later (old Hellfire H1) | the finisher |

## 4. The Bankai: Zanka no Tachi

Entered by the awakening (Mod + P) as every kit. Pointer themes, the lead's proposal from canon (`canon-looks.md` §4), to be confirmed with
the segment table:

| Pointer | Theme | Canon | Proposed play |
|---|---|---|---|
| 1 東 | 旭日刃 KYOKUJITSUJIN | only what the tip touches is erased; a graze does nothing | short, exact reach; the highest single-hit damage |
| 2 西 | 殘日獄衣 ZANJITSU GOKUI | 15,000,000 degrees on his body; untouchable | close pressure with super armour; contact burns the toucher |
| 3 南 | 火火十万億死大葬陣 DAISOJIN | the blade planted; charred dead rise and swarm, a wall of bodies | the dead rise from the ground as ranged hits, or a bone wall |
| 北 | 天地灰尽 TENCHI KAIJIN | one huge diagonal wave of fire | the special pointer below |

| Rule | Value |
|---|---|
| Marks (Y6) | an AS n writing pointer n gives mark n (East / West / South); a mark already held stays one; kept through Kikon / Konpaku resets for the match |
| North (Y7) | the third distinct mark sets the pointer to 北 instead of n: his next NS or AS is 天地灰尽's; after that one move (hit, whiff or cancel: default, open) the pointer goes back to n and the marks clear |
| North's Kikon | a hold after 北 lands is the 天地灰尽 cinematic (its own theme, §5b) |
| HUD | the three marks next to the pointer; 北 replaces the pointer label while it is armed |

## 5. Research (2026-11-19; the user: 「請透過 skill 調查山本人物特色與動作設計後規劃人角色系統」)

Skill `duel-motion-style` (+ `duel-character`, `duel-move-modules`). Sources, graded A canon / B official game / C secondary / D proposal:
- `docs/research/yamamoto-rework/motion-refs.md` (2026-10-13): every canon fight, his habits (§1.9), RoS's moves, the archetypes (§3).
- `core-refs.md` (new): the three Shikai themes in canon detail, RoS's 豪焱ゲージ / 獄焱状態 rule by rule, new traits.
- `mechanic-precedents.md` (new): heat / overheat and collect-the-set precedents (Tekken 8 Heat, SF6 Burnout, Melty Blood, BlazBlue
  Susano'o and Hakumen, GGST Asuka, RoS) and their lessons.

What the plan takes from it:

| Finding | Grade | Used for |
|---|---|---|
| He wins by economy: one precise strike, the result arriving late (Nadegiri: the split after) | A | pointer 3, the finisher's delayed split |
| Jōkaku Enjō = a stream along the lane, a ring landing round the target, walls closing into a dome; in canon it cages, it does no damage | A | pointer 2's three segments (stream / ring / dome) |
| Shiranui is a game move (RoS: a tornado of flame ahead; held = more damage), not canon | B | pointer 1; 不知火's folklore (fire appearing at a distance) as the look of NS1b (D) |
| Taimatsu vs the three Fracción: one wave, a full radial halo of fire round him | A | the Shikai's SA (an all-round answer) |
| Ennetsu Jigoku: set up earlier, triggered later; it burns him too | A | pointer 2's Kikon; canon backing for 爆炎's self-drain (Y4) |
| He chooses which targets burn and how hot | A | canon backing for Y3's spend-what-you-choose boost (a small flame at low spend, white-hot at full) |
| RoS: the gauge leaves through Taimatsu (to 0, locked) and Nadegiri (ends Hellfire); a Kikon landed or taken ends Hellfire (patch 1.10) | B | §3's exits; the Kikon end is an open question below |
| The Bankai can be held only briefly (its heat would destroy everything) | A | backing for the one-shot 北 (Y7) |
| Habits: the eye opening before a technique, the neck crack, standing under fire then walking forward, turning his back and walking away, the grab after taking a hit | A | the opener tells (body-scale, the eye opening only a garnish, §7.4), West's advance, the Kikon endings |
| Precedent lessons: an attacker-fed state snowballs; a powered state needs counterplay beyond waiting; show the state, its drain and the floor at a glance; the strongest option costs the whole resource | C / D | the HUD (heat bar, 爆炎 decay bar, Reishi drain stopping at 1), the cancel-ability of 爆炎's free SP, 北 clearing the marks |

## 6. Motion: archetypes per form (motion-refs §3, refined; D unless marked)

| Form | Archetype | Body in one line |
|---|---|---|
| Shikai NA | the unmovable pivot | small wrist snaps, the feet stay, the eyes open on S |
| Shikai 1 不知火 | the flame wave | the blade drawn back level, a spiral gathering, the cast forward with the torso turning |
| Shikai 2 城郭炎上 | the point | the arm locked out level at the target, held; the fire runs off the tip (A, `316Jokaku Enjo`) |
| Shikai 3 撫斬 | the pivot's purest form | eyes shut, almost no wind-up, one snap, then stillness while the result arrives (A) |
| 爆炎 | the same, bared to the waist, the scars glowing | everything bigger and hotter; J3 becomes the brawler-sage's IKKOTSU fist (A) |
| Bankai NA | the fencer's lunge | a deep one-armed lunge, the torso over the front knee (A, `507Yamamoto attacks`) |
| Bankai 東 | the lunge and the tip-tap | the point touches the floor; the line beyond it is erased (A, ch. 507) |
| Bankai 西 | the immovable furnace | no swing: he stands or walks forward through hits, wrapped in flame (A, ch. 508) |
| Bankai 南 | the plant | the blade upright before the face, point down, driven into the floor (A, anime) |
| Bankai 北 | the hammer from the sky | flame gathering, one enormous passing diagonal cut, the blade a smear (A, ch. 509) |

## 7. The pointer tables (the plan, D: for the user's yes)

Costs follow DUEL_SP §4 (damage x 0.4, rounded to 5, clamped 10-60). Damage before the kit's `:mult` (set by measuring, as Ichigo's 1.3).
Openers S >= 14 with the eye-open tell; links keep their speed. `as-by-press (1 2 3)`: J1 -> AS1, J2 -> AS2, J3 -> AS3.

### 7.1 Shikai (RYUJIN JAKKA)

NA: J1 HISEN S14 (the blade drawn back, then a wrist snap; 34, 1.0 m, flinch) -> J2 KAESHIBI S8 (34, flinch) -> J3 TSUKABI S9 (the burning pommel;
42, stagger, no knockdown: an AS follows). Clips `ya-q1` (retimed to 14), `ya-q2`, `ya-tsuka`.

| Pointer | Stance | NS a / b / c | AS n | Kikon |
|---|---|---|---|---|
| 1 不知火 | the blade drawn back level at the hip, a flame spiral on it (`ya-shiranui`'s charge pose) | a: the thrust casts a spiral of fire along the lane (wave, 8 m; S22, 70) / b: the "unknown fire": a column erupts at the victim's bearing 4-7 m ahead, the point sampled at S, the eruption 12 f later inside an active window of 12 (S16, 70; `ya-f2`) / c: the tornado, a wide spinning column that travels (wave 3.5 m wide; S18, 90, knock-back; `ya-sig`) | AS1 (1): the spiral thrust point-blank, steals flash-step (50; `ya-shiranui-throw`) | the tornado swallows him: columns close in |
| 2 城郭炎上 | the arm out, blade pointed at arm's length, held (`ya-enjo`) | a: the stream, a lance of fire along the lane (wave, 10 m; S20, 40) / b: the ring lands round the victim at his bearing (3-8 m, radius 1.6 m; lives 90 f; one ring at a time; S16; see Q1) / c: the walls close into a dome on the ring, or at once at his bearing if no ring stands (S18, 80, crumple; `ya-f3`; an NS hazard: J / SA cancel it) | AS2 (2): the ring snaps round him at contact (40, stagger) -> the dome erupts (60, launch) | ENNETSU JIGOKU: the pillars rise from the floor round both, a dome of fire (A) |
| 3 撫斬 | upright, both hands on the pommel of the planted blade, as on the cane (reads apart from 1's low hip draw) | a: the walking jab of the point (S18, the blade pulled from the floor as the tell; 40, 1.6 m, slide 1.0) / b: the closing step-cut (S12, 50, slide 2.0) / c: NADEGIRI, one snap, the hit on S, the split drawn 24 f later (S14, 110, crumple; `ya-nadegiri`; see Q2) | AS3 (3): back cut (40) -> turning cut (50) -> NADEGIRI (110, knockdown) | he lowers the blade and turns away; the victim splits (A, ch. 338) |

SA (J in an NS gap, any pointer): **TAIMATSU**, the radial halo of fire round him (360 deg, r 2.4 m; 55; the turn move's armour window;
`ya-taimatsu`). Heat (§3): NS segments spend it for the damage boost; the flame drawn smaller or white-hot by what was paid (looks only).

### 7.2 爆炎 (GOKUEN, the kit `:blaze`)

Bared to the waist, the scars glowing (the old Hellfire body, `:yamamoto-bare`). Every move a variant (Y: 「變招」); the first build gives
each its own move entry (copies with new numbers), so the art can diverge later.

| Slot | Shikai -> 爆炎 |
|---|---|
| J1 / J2 | the same clips with a flame trail, 40 / 40 |
| J3 | **IKKOTSU**: the right fist straight out, the body behind it (A, ch. 394; `ya-ikkotsu`; 55, stagger) |
| NS1 | the spiral and the column x1.3; c: the tornado **tracks** him (turn 60 deg/s, as the old Shiranui) |
| NS2 | b: the ring closes at once (b and c in one); c: **ENNETSU**, rows of pillars along the lane (A) |
| NS3 | c: the true NADEGIRI: 200, a long recovery (RoS "a huge opening", B) |
| AS1 / 2 / 3 | x1.3, free of flash-step (§3) |
| SA | TAIMATSU, r 3.2 m |

Entry: see Q3. Early exit: each NS segment spends 25 heat (§3).

### 7.3 Bankai (ZANKA NO TACHI)

TYBW battle dress, the charred blade with its smoke thread (DUEL_YAMA_TYBW §3.1). NA: E-J1 the fencer's lunge S14 (34) -> E-J2 the rising
backhand S7 (38) -> E-J3 the dropped-knee thrust S8 (42, stagger). Clips `ya-e-q1`..`q3`.

| Pointer | Stance | NS a / b / c | AS n | Kikon |
|---|---|---|---|---|
| 1 東 | the blade held level in front, fist toward the foe (A, the naming pose) | a: KYOKKO, the longest lunge (line 4.6 m, slide 1.6; S20, 80; `ya-e-kyokko`) / b: the sunrise, a rising cut from the lunge (S14, 70; `ya-e-f2`) / c: KYOKUJITSUJIN, the tip touches the floor: the line ahead is erased (S18, 120; `ya-kyoku`) | AS1 (1): the tip-touch point-blank, steals flash-step (50) | the chasm: the floor and everything behind him vanish (A, ch. 507) |
| 2 西 | arms open, the flame wings at the shoulders | a: SHONETSU, no swing, the garb flares: a burn round him (r 2 m, 2 hits x 45; S16; `ya-shonetsu`) / b: the advance, 1.5 m forward with the turn moves' armour (f6 to S); the burn round him is this segment's own NS-classed hit window (S14, 40); an AS still beats it / c: the counter (see Q4) | AS2 (2): the grab after the hit (40, A: Aizen, Yhwach) -> the flare throws him (70, launch) | the young Yamamoto seen for a beat; the foe's blade erased on his body (A, Ep372) |
| 3 南 | the blade upright before the face, point down (A) | a: the plant: dead hands rise at the victim's bearing 4-10 m (radius 1.2 m; the point sampled at S, the hands 16 f later inside an active window of 16, so a Step dodges; S22, 40, bind; `ya-kaka`) / b: the swarm crawls along the floor (wave, 6 m/s; S16, 50) / c: the bone wall rises before him (it stops waves 90 f), then falls forward (S18, 70) | AS3 (3): the hands seize (40, stagger: a bind inside a combo is a flinch, `combo-step`) -> the swarm (50) -> the pile collapses (100, knockdown) | the dead swarm and drag the victim down (A, ch. 508-509) |
| 北 | (armed after the third mark) | one NS: flame gathers (S24), an enormous diagonal wave of fire (4 m wide, 14 m; 220, knockdown; `ya-e-tenchi`) | AS 北 (1): the same cut point-blank (180) | 天地灰尽: the diagonal white band, the kanji card (A, ch. 509) |

SA: a pointer-neutral short backhand at chest height (S6, 60; a copy of `ya-w-counter`'s clip, not West's move).

### 7.4 Build rules (the Fable review, 2026-11-19)

- **Form changes latch to the next neutral**, both ways: heat reaching 100 mid-route (an AS segment's gain) or 0 mid-route (a 爆炎 NS
  spend or the decay) is applied when he is next free; a route ends in the kit it started in. Heat stays at 100 (no gain) until then.
- **The decay and the drain** tick only in live sim steps (not in hitstop, cinematics or the entry pose); the drain reuses `gauges.lisp`'s
  `kit-burn` path (per-second Reishi burn floored at 1). A Konpaku reset keeps heat and 爆炎; a new round resets heat to 0 and ends 爆炎.
- **Heat accounting**: a cancelled NS segment gets its heat back (the SP rule, DUEL_SP §3); a segment with no hit of its own (NS2b's ring)
  spends no heat; an AS segment adds its heat once, on its first hit or cancel; Kikon strikes and burst hits add nothing. A segment's damage =
  base x (1 + 0.3 x paid / 25) x the SP short-pay scale, frozen at its start (a hazard's at its fire frame); its SP cost from the base damage.
- **Marks and 北**: a mark is given when the AS **lands** (its first hit), not at its start. The third distinct mark arms 北; the pointer
  returns to n (the third AS's write) and the marks clear when the 北 move **starts**. **北 is a flag, not pointer value 4**: the
  pointer stays 1-3 everywhere (the clamp, `:stances` / `:kikon-cines` by index, the Konpaku table, the HUD, the switch's route count);
  the armed flag replaces the NS / AS pick, and the 北 move's own record picks the 天地灰尽 cinematic with pointer 3's Konpaku profile (Q6). AS 北 follows any J count (`:params :as-ptr`) and writes no pointer and no mark. The pointer switch (DUEL_SP §3) is refused while
  北 is armed. Marks and an armed 北 survive the Bankai's end and return with it (for the match).
- **Every hazard segment carries a Kikon strike** (`:params :kikon-strike`, Ichigo's wave rule), so the hold works on pointers 1 / 2, 南
  and 北. Each move used by two classes gets its own copy (AS2's dome, NADEGIRI as NS3c / AS3c / 爆炎's). AS1 steals flash-step
  (`:steal-fs`, the first number 30 between Ichigo's 40 and Hisagi's 5-20).
- **Tells read at the arena camera**: each opener's tell is a body-scale anticipation (the blade drawn back, raised point-up, pulled from
  the floor); the eye opening is a face-scale garnish.
- **Watch in play**: J1-J2-J3 > AS3 adds 60 heat, so two confirmed strings enter 爆炎; a full 爆炎 burns about 20 % of his Reishi and can
  walk him into red (the HUD warns at the red line). The boosted routes (Shikai NS1 230, 299 at full spend; 爆炎 NS3c 200; 北 220) sit above
  Ichigo's: the kit's `:mult` starts at 1.0 and is tuned by play (no pacing gate: 「以後不用跑平衡測試」), toward the roster's top
  (Kenpachi's AS 240-320).
- **Batch 1 staging**: commit 0 ports the old art and VFX inert (still retired; names already in main dropped: `hem-spring`, `tip-track`,
  `vfx-ember`); stage A the Shikai and the un-retire, then the playtest page; stage B heat and 爆炎; stage C the Bankai, the marks and
  北. A fresh `yama.lisp` (the old one's `:commands`, `:grid`, `:meter`, AI v2 hooks, boss and passives are dead grammar). The Kikon
  cinematics are placeholders until their storyboards; the bone wall's wave stop may wait past batch 1.

## 8. Clip inventory (the old kit, `git show retired-kits:duel/lisp/yama-art.lisp`: 36 clips)

Reused as above (`ya-stance`, `ya-q1/q2`, `ya-tsuka`, `ya-f1..f3`, `ya-sig`, `ya-shiranui(-throw)`, `ya-taimatsu`, `ya-nadegiri`, `ya-enjo`,
`ya-ikkotsu`, `ya-hellfire`, `ya-bankai`, `ya-e-*`, `ya-kyoku`, `ya-kaka`, `ya-shonetsu`, `ya-w-parry`, `ya-w-counter`, `ya-e-tenchi`,
`ya-intro`, `ya-win`). Batch 1 retags them at the right reach (DUEL_CORE §1: 「先重組成新系統後再來重畫」); new clips, each pointer's own stance
and the openers' tells, come in the art batches after the user plays it. Each segment that shares a clip with another class gets a copy
(duel-move-modules red flag).

## 9. Questions (answered 2026-11-19, §2 Y8-Y12)

Q1 -> Y8 (a burning ring), Q4 -> Y11 (the armoured counter), Q5 -> Y9 / Y10 (every 爆炎 NS spends; 爆炎's cancels burn), Q2 / Q3 / Q6 as
recommended (a look only; a short entry pose; pointer 3's profile). Still defaults: a Kikon landed or taken does not end 爆炎; a cancelled 北
counts as used (its gauge refunded, DUEL_SP §3).

## 10. Next

1. Done: the Fable review folded in (§7.4); the user's yes (Y12).
2. Batch 1: the kits' `:core`, the heat gauge and 爆炎 in the sim (pure functions host-tested), the marks and 北, functional clips at the
   right reach; the generic core CPU plays them. Roster: un-retire slot 0 (`*retired*`, simgate `RETIRED`), the host tests, the looks
   gate's seeds.
3. The playtest Artifact, then art batches (presentation only), the Kikon storyboards last.

## 11. As built (batch 1 A, 2026-11-19)

Commit 0 brought `yama-art.lisp` / `yama-vfx.lisp` back from `retired-kits` unchanged but for the API drift: `*ya-hem*` (the hem spring state
R15a dropped from hem-spring.lisp) and the stamp dispatch's ten kinds of his (vfx-stamps.lisp, codes 17-22 / 25-29). Stage A is a fresh
`duel/lisp/yama.lisp`: §7.1's table on the core grammar, slot 0 un-retired (kit.lisp `*retired*`, simgate `RETIRED`; `*roster*` untouched).

**Built.** NA J1 HISEN S14 (34) > J2 KAESHIBI S8 (34) > J3 TSUKABI S9 (42, stagger), `as-by-press (1 2 3)`. The routes, the SA and every
number §7.1 gives, as written (damage before the kit's `:mult` 1.0):

| Pointer | NS a / b / c | AS |
|---|---|---|
| 1 不知火 | a S22 wave 70 (8 m) / b S16 the column 70 at the victim's bearing 4-7 m, the point on S, erupting on S + 12 / c S18 the tornado wave 90 (3.5 m wide, knock-back) | AS1 S10 the thrust 50, knockdown, `:steal-fs` 30 |
| 2 城郭炎上 | a S20 the stream wave 40 (10 m) / b S16 the ring round the victim (3-8 m, r 1.6, 90 f, one at a time) / c S18 the dome on the ring (spends it), or at his bearing 3-8 m: 80, crumple | AS2 S12 the ring snaps round him (40, stagger; the ring left there) > the dome on it (NS2c's copy: 60, launch) |
| 3 撫斬 | a S18 the jab 40 (1.6 m, slide 1.0) / b S12 the step-cut 50 (slide 2.0) / c S14 NADEGIRI 110, crumple, the hit on S, the split a look 24 f later | AS3 S8 40 > S10 50 > NADEGIRI's copy 110, knockdown |

SA TAIMATSU (S16 A8 R24, the old kit's): a 360 deg halo r 2.4, 55, stagger; its armour is the SA class's. SP costs (DUEL_SP §4, the host
test's `*sp-table*`, DUEL_DESIGN §5.1 regenerated): NS 95 / 55 / 80, AS 20 / 40 / 80.

His fire is hazards spawned inside their segment (SPAWN-HAZARD's defaults freeze the class, the SP scale and the start tick at the fire
frame): `:wave` (NS1a / NS1c / NS2a), and his own kinds through `yama-hz` (`:ya-col`, `:ya-ring`, `:ya-dome`). The ring has no collision:
its hit is a burn on its line (±0.25 m), so crossing it hurts and standing inside or outside does not (Y8). Every hazard segment carries
`:params :kikon-strike` (`:ya-ns-strike` for the NS ones, `:ya-as-strike` for AS2a / AS2b: one copy per class). One move per class
(AS2b, AS3c are copies). Only a route's last segment knocks down / crumples / launches (host-tested).

**Stage B seam.** `yama-seg-x` (1.0 now) is the per-segment damage x; the kit's `:dmg-mult` hook (`yama-dmg-mult`) returns it for his own
hits and, for a hazard, the copy frozen in its data (`:x`) at the fire frame. APPLY-HIT multiplies it with the SP short-pay x (`sp-paid /
sp-cost`) and the hazard's frozen SP x. The ring segment is priced as a setup (`:sp-cost` 10; its burn is `:ring-dmg`, not SP damage), so
§7.4's "no hit of its own spends no heat" can read `mv-sp-damage` = 0. Only a hazard's x is frozen today (its data `:x` at the fire
frame); a melee hit calls `yama-seg-x` when it lands, so stage B stores the boost at the segment's start (§7.4) and has `yama-seg-x` read
it.

**The awakening.** `:core :no-awaken t`: Mod + P does nothing and the CPU never awakens (the existing switch, fighter.lisp / core-ai /
webhud); `tests/duel-rules/yamamoto.lisp` pins it with no `:awaken-form`. Stage C replaces it.

**Placeholders** (new art after the playtest, §8):
- Clips: J1 `ya-q1` slowed to S14 (`:clip-s` 9); NS1a `ya-f1`, NS1b `ya-f2`, NS1c `ya-sig` (its f40 wave pose on S), NS2a / NS2b / AS2a
  `ya-enjo`, NS2c / AS2b `ya-f3`, NS3a / AS3a `ya-q2`, NS3b `ya-q1`, NS3c / AS3c `ya-nadegiri`, AS1 `ya-shiranui-throw`, AS3b `ya-f1`, SA
  `ya-taimatsu`; the Kikon strikes J1's clip.
- Stances: 1 `ya-shiranui` (the old charge loop), 2 `ya-st-enjo` (a loop on ENJO's point pose), 3 `ya-st-cane` (a loop on the intro's cane
  lean: the planted blade). The last two are two-key loops on old poses.
- Kikon cinematics: the generic `soul-break-cine` for all three pointers. The old `yama-kikon-cine` calls `push-in-on` (gone with R5) and its
  caption's 城郭炎 are not in glyphs.lisp (only 上 would draw); it waits for the storyboards.
- Hazard looks (yama-vfx.lisp): the old fire wave, a pillar for the column / the tornado, six low pillars for the ring, the old dome from
  its seethe so it detonates on the hit, NADEGIRI's old crescent for the split.

**Deviations from §7.1 / §7.4, each with its reason.**
1. J1's reach 1.0 m (J2 0.96, J3 0.88) plays at 1.4 m: `*j-reach-min*` floors every `:quick` move (Ichigo's 1.1 the same).
2. NS1b's active window is 13, not 12: a hazard spawned on frame S counts its first delay frame in that step, so the eruption on S + 12 needs
   `:delay` 13, and A 13 keeps it inside [S, S + A) (a next segment, which starts at S + A at the earliest, never comes before it).
3. J3 carries no `:ender`: the old O ender's push would carry the victim out of AS3's reach (§7.1: "no knockdown: an AS follows").
4. Numbers §7.1 leaves open, the lead's placeholders (knobs in yama.lisp's move data): the waves' widths / speeds (NS1a 2.0 m 14 m/s, NS1c
   10 m/s over 8 m, NS2a 1.2 m 18 m/s); the column r 1.2, hot 6 f; the dome hot 4 f; the ring's burn 20 (flinch), at most 2 hits 16 f
   apart; the fire's height 2.4 m; every A / R (listed in the file); AS1 / AS2a / AS3a / AS3b's S 10 / 12 / 8 / 10; NS3b's reach 1.6,
   NS3c's 2.4; the reactions §7.1 does not name: stagger mid-route (NS1a, NS1b, NS2a, NS3a, NS3b, AS2a, AS3a, AS3b), AS1 a knockdown.
5. AS2a's 40 is its own melee hit; the ring is spawned by that hit (`:on-land`) round the victim, so a whiffed AS2a leaves none. AS2b (the
   dome) lands at his bearing from 0 m when no ring stands (NS2c's from 3 m).
6. TAIMATSU is a melee window (it moves with him), not a hazard; it has no `:kikon-strike` (not a hazard segment).

**Debug range** 87000-87999 (`yama-debug`, DUEL_GAMEPLAY "Debug commands"): scenes vs Kenpachi / Ichigo / Hisagi, the pointer, a route
or a single NS1 / NS2 segment started on its own, the probe line.

**Checks** (2026-11-19). Host tests ALL PASS (the new `tests/duel-rules/yamamoto.lisp`: the class tags, the openers' tells, no mid-route
knockdown, each hazard segment's strike, AS 1 / 2 / 3, one ring at a time, the stance by pointer, the bearing point, the ring's band);
pkgcheck as main; `--cvc` II / IK / KK identical; the native trials `tests/trials/yamamoto-core.lisp` (P1 scripted, P2 by `:p2-at` /
`:p2-press`), base damage (dealt to Kenpachi):

| Trial | Reading |
|---|---|
| NS1 a-b-c (5 m) | wave 70 (29), the column 70 on NS1b's frame 28 (29), the tornado 90 knock-back (38); SP 30 + 30 + 35 |
| NS2 a-b-c (5 m) | stream 40 (17), the ring round him, the dome on the ring 80 crumple (34); SP 15 + 10 + 30 |
| NS3 a-b-c (1.8 m) | 40 > 50 > 110 crumple, a true combo (gaps 0 0), 84 dealt; SP 80 |
| J1 > AS1 (1.6 m) | 34 > 50 knockdown; STEAL fs 30 from P2, gains 15 |
| J1 J2 > AS2 | 34 34 > 40 > the dome 60 launch, combo 4, gaps 0 |
| J1-J3 > AS3 | 34 34 42 > 40 50 110, combo 6, gaps 0, 130 dealt |
| NS3a > SA | the jab 40 > TAIMATSU 55, a combo |
| NS1a wave x P2's J1 | CANCEL, refund 30 (fs back to 300) |
| NS1b's column x P2's J1 (87411) | CANCEL inside NS1b's window: refund 30, counted as landed for him |
| NS2c alone (87415) | the dome at his bearing (no ring) 80 |
| NS3a held | KIKON FOLLOW-UP, the Kikon: 1 Konpaku (pointer 3) |
| NS1a held | the wave's hit, the strike flash-steps in (YA-NS-STRIKE KIKON), 1 Konpaku |
| NS2 a-b twice | the second ring puts the first out (`ring out (one at a time)`) |
| NS2 a-b, P2 steps back | YA-RING HIT 20 (the crossing burns) |

The browser script `tests/scripts/duel-yama-core.json` plays the routes through the page; one native CPU smoke of YK, IY, HY (3 seeds each)
ran without an error (no balance gate: the CPU is the generic core one, untuned). The looks gate was not run: its `menus` still changes
(a fourth fighter on the select screen). The pairing-keyed CPU layers fall back for a Y pairing: `*strat-lookup*` has no Yamamoto row
(START-MATCH leaves the strategy NIL, so no Q table attaches), `*cai-styles*` none, the strategy layer is off, the MCTS outcome tables
take their `(t t)` row; so the form-keyed tables (cpu-ki-ichigo's `*iks-hover*` by the opponent's form, his `:base` read as Kenpachi's) are
not reached. In the smoke Yamamoto lost all nine (YK 0-3, IY 0-3 with two 300 s time-outs, HY 0-3): the generic untuned CPU at `:mult`
1.0. Still open for the art batch: drawn reach against hit reach (the host FK test does not load yama-art); `yama-nade-look` marks its
hazard's data from the draw path (nothing in the sim reads it; replace with the split's own look).

**Open for stage B / C.** B: the heat gauge (gains on a hit or cancel, NS spend and boost through `yama-seg-x`), 爆炎 (`:blaze`, its own move
set, decay, the Reishi drain floored at 1, free NS / AS, the cancel burn), the form latch at neutral, the HUD bar. C: the Bankai (東 / 西 /
南 pointers, the marks on an AS hit, 北 as a flag, 天地灰尽), the awakening in place of `:no-awaken`. Both: the Kikon storyboards, the
pointer stances' own clips, the bone wall's wave stop.

## 12. The select screen (2026-11-19; the user: 「選角畫面沒有修改，導致我無法選擇山本」)

Stage A un-retired him in the roster but the select screen's cards were a fixed list of three (`*lm-card-order*` #(1 3 7)), so the
cursor reached him with no card to show or pick. Now four cards (#(1 3 7 0)): `+lm-nc+` 4, the geometry's slots by `lmc-xy` / `lmc-wh`
(card k at [8 + 2k] and [8 + 2N + 2k], the head's height at [8 + 4N]), the gaps 10 x (N - 1), the tween buffers N cards; his card (炎, the
three pointers' themes); a name wider than its card shrinks to fit (desktop: the narrower unfocused cards clipped KENPACHI); "4 PLAYABLE".
Host test: the card count and the new geometry (phone and desktop). The looks gate's `menus` scenario shoots four select stills; its
`LOOKS_SEEDS` (2000 + seed, a draw over the playable roster) need re-pinning over the four (open; the looks gate is for refactors).

## 13. As built (batch 1 B: heat and 爆炎, 2026-11-19)

Stage B on top of §11: the heat gauge and 爆炎 GOKUEN as §3, §7.2 and §7.4 decide, in `duel/lisp/yama.lisp` (no new file: a section of
pure rules, one of sim hooks), two shared hooks that default off, and the plate's heat strip.

**Built.**
- **Heat** is the kit meter (`GAUGES-METER`, 0-100; the old kit's Inferno slot), so the match's fresh fighter starts at 0 and a Konpaku
  reset keeps it with the form. The per-segment bookkeeping is a component on his fighter (`yss`: the NS segment's start tick, the heat it
  paid, its frozen x, whether a cancel gave it back; the gain and burn once-guards). Pure rules (host-tested): `ya-heat-gain` (NA 8 / SA 10 /
  an AS segment 12, NS and classless 0, capped at 100), `ya-ns-spend` (25 or what is left; nothing for a segment with no hit of its own, NS2b's
  ring; x 1 + 0.3 x paid / 25 in the Shikai, x 1 in 爆炎), `ya-heat-refund`, `ya-blaze-decay` (10 / s), `ya-form-next` (the latch both ways),
  `ya-burn-amount`. Knobs `*ya-heat-max*` `*ya-heat-gain*` `*ya-heat-ns*` `*ya-heat-boost*` `*ya-blaze-decay*` `*ya-blaze-drain*`
  `*ya-blaze-burn*` `*ya-blaze-in-frames*`.
- **The spend** runs on every NS segment's frame 0 (`:on-frame (0 yama-ns-start)`, both sets; an NS copy played as an AS spends nothing) and
  stores the x there; `yama-seg-x` returns it while that segment is the move in play, so a hazard copies it at its fire frame (§11's seam).
  APPLY-HIT multiplies it with the SP short-pay x as before. A cancelled NS segment gets its heat back once (`:cancel` hook): a hazard
  carries its segment's unrefunded heat in its data (`:heat`, at its fire frame, as `hazard-sp-paid` carries the SP), so a wave cancelled
  after the next segment started is still paid back; a refund by either path closes the other (`yama-heat-back!`).
- **Gains** (`:hit` hook on a real hit, `:cancel` hook on a cancel): once a move (an AS: once a segment; its hazard's hits keyed by the
  segment's start tick), in the Shikai only; a blocked hit, a whiff, an NS, the Kikon's follow-up strike, any hit or cancel during his own
  burst add nothing.
- **爆炎** is the kit `:blaze` (`:inherit :base`; `:body :yamamoto-bare`, `:hide (:haori :kosode)`, `:aura :hellfire`, `:blade (:fire 1.3)`,
  `:callout "GOKUEN"`, the form name GOKUEN). The `:tick` hook (GAUGE-SYSTEM: live sim steps only) enters it when he is free (idle / guard /
  run, no input lock) with heat at 100: heat set to 100, the entry pose `:ya-blaze-in` (24 f, no class, no hit, the old clip `ya-hellfire`
  played whole), 24 f invulnerable, the `:hellfire` flash. Outside the pose the heat decays 10 / s and the Reishi drains through the form's
  `:burn 0.02` with rules.lisp's `burn-amount` / `burn` (never below 1; 26 / s at Reishi max 1300). Heat 0 leaves at his next neutral: the
  Shikai, heat 0. `:no-awaken` stays (stage C).
- **Free NS / AS**: the kit's `:core :sp-free t`, read by `kit-sp-free-p` in `kit-sp-start-p` (so the CPU's pre-press test agrees) and in
  `core-start!` (paid and recorded as in a burst: cost 0, full damage, the regen not reset); the HUD's next-NSa price tick hides with it.
- **The cancel burn** (Y10): `yama-burn!` from the `:cancel` hook in 爆炎: the opponent loses 25 % of his cancelled part's base damage (a
  hazard's hit damage, else the move's `mv-sp-damage`), at least 1, his Reishi never below 1 (`burn`); no hitstun, no combo count, not counted
  as dealt; once a step; a `GOKUEN BURN` clog line.
- **Shared hooks, default off**: core-sim.lisp `core-cancel-hook!` (the kit hook `:cancel (e other mv hz)`), called per verdict in
  `core-nohit!` and `core-hazard-nohit!` for each side of a cancel with his own move or hazard (his window side only when he was in a classed
  window, read once before the verdict lands); kit.lisp `kit-sp-free-p`. No other kit has either (host-tested); `--cvc` byte-identical.
- **HUD** (lhud-plate.lisp `lhud-heat`, the kit strip's kinds 4 / 5 from the meter's label HEAT / GOKUEN): beside the souls on both plates and
  under the bar on the phone's deck line. Shikai: 炎 and the heat bar with a tick at each 25 (the NS segment's price), white-pulsing at the
  top. 爆炎: 爆炎 and the bar white-hot, draining (the decay), then `-2%/s`, or `MIN 1` pulsing red once the drain is held at 1 (webhud V o+21:
  a form with a `:burn` 1 draining, 2 at its floor; it was always 0). No new glyph (爆 and 炎 are already in the Mincho tier); lhud-charset passes.
- **CPU**: the generic core CPU plays the `:blaze` set (its `:core` lists) and ignores heat. No tuning.
- **Debug** (87000-87999): 87500+h P1's heat, 87701-87799 / 87801-87899 P1's / P2's Reishi; the probe line has heat and Reishi.

**爆炎's move set as built** (copies with their own `:params`, so no Shikai `:ns-next` leaks in; damage before `:mult` 1.0):

| Slot | 爆炎 |
|---|---|
| NA | J1 40 > J2 40 (the Shikai's clips) > J3 IKKOTSU 55, stagger (`ya-ikkotsu`, S9 A3 R18 as TSUKABI) |
| NS1 | a wave 91 / b column 91 / c the tornado 117, knock-back, turning after him 60 deg / s (`:track`, the hazard's `:step`) |
| NS2 | a stream 52 / b the ring closes at once: the dome at his bearing 3-8 m, 80, stagger (S16 R20) / c ENNETSU JIGOKU: a wave 2.4 m wide, 12 m/s over 9 m, 104, crumple (S18 R30) |
| NS3 | a 52 / b 65 / c NADEGIRI 200, crumple, R60 (the Shikai's 34) |
| AS | AS1 65 (steal 30) / AS2 52 (the ring's burn 26) > the dome 78, launch / AS3 52 > 65 > NADEGIRI 143, knockdown |
| SA | TAIMATSU r 3.2, 55 |

**Placeholders** (§7.2 leaves them open; the lead's numbers): x1.3 of the Shikai's wherever §7.2 names none (NS1 a / b, NS2a, NS3 a / b,
every AS segment and the ring's burn); NS2b's 80 (the Shikai dome's) and its frames; ENNETSU as one travelling hit drawn with the tornado's
pillar look (its rows of pillars are art to come); NS3c's R60; SA's 55; J3's frames; no flame trail on J1 / J2 yet; the burn has a sound only
(`:explode`), no look; the Kikon cinematics stay `soul-break-cine`; the HUD's `-2%/s` is a literal (change it with `*ya-blaze-drain*`).

**Deviations, each with its reason.**
1. "A new round ends 爆炎 and resets heat": SOUL DUEL has no round inside a match but the Konpaku reset (which keeps both, §7.4); a new match
   spawns fresh fighters (heat 0, the Shikai). PRACTICE's K.O. reset is a Konpaku reset, so it keeps both too.
2. The drain does not go through GAUGE-SYSTEM's `kit-burn` branch itself: that branch runs only for a timed form (`gauges-form-left`), and
   爆炎 has no duration. The `:tick` hook calls the same pieces (`burn-amount` over the form's `:burn` and `gauges-burn-step`, then `burn`).
3. "Never below 1" for the cancel burn is applied both ways: the amount at least 1 and the victim's Reishi at least 1 (Y10's words and §3's).
4. A cancel of the Kikon's follow-up (`core-kikon-cancel!`) burns nothing and moves no heat: it is not a triangle verdict of his move (the
   hook is in `core-nohit!` / `core-hazard-nohit!`, as the brief says).
5. "Burst hits add nothing" is read as a hit or cancel while his own burst runs (`gauges-burst`: WHITE / BLUE / ORANGE), as PAY-GAUGES and
   the flash-step gains give nothing in one.
6. Heat that reaches 100 logs `HEAT +0.0` on later gains: the gain is spent (once a move) but adds nothing at the top (§7.4: "Heat stays at
   100 (no gain) until then").

**Readings** (2026-11-19; native trials `tests/trials/yamamoto-blaze.lisp`, P1 scripted, P2 Kenpachi
by `:p2-at`; damage dealt after his defence, the base in the hit line):

| Trial | Reading |
|---|---|
| B1 / B2 J1 hit / whiff | HEAT +8 (8) / nothing (0) |
| B3 NS3a at heat 0 / 10 / 40 | spends 0 / 10 / 25, x1.00 / 1.12 / 1.30, dealt 17 / 19 / 22 (heat left 0 / 0 / 15) |
| B4 J1-J3 > AS3 from heat 90 | J1 +8 (98), J2 +2 (100, tick 359), the rest +0; the route stays the Shikai's (34 34 42 > 40 50 110); GOKUEN at tick 480, after AS3c's recovery |
| B5 爆炎 from Reishi 30 | `drain held at reishi 1` (Reishi -29), still in 爆炎 |
| B6 NS1a at fs 100 | Shikai: cost 30 paid 30, dealt 29 (70); 爆炎: cost 0 paid 0 (fs +0), dealt 38 (91) |
| B7 爆炎 NS3 a-b from heat 50 | spends 25 (25 left), then 21.5 (the decay took 3.5) -> 0; `GOKUEN over` at the next neutral, the Shikai, heat 0 |
| B8 爆炎 NS1a wave x P2's J1 | CANCEL, HEAT refund 25, BURN 23 (base 91): 1300 -> 1277; from Reishi 5: 5 -> 1 |
| B9 Shikai NS1a x P2's J1 at heat 40 | spends 25, the cancel gives it back: 40 |
| B10-B13 爆炎 routes | NS1 91 / 91 / 117; NS2 52 / the dome 80 / ENNETSU 104; J1 J2 J3 > AS3 40 40 55 > 52 65 143 (combo 6, gaps 0); NS3 52 > 65 > 200, adv -24, heat 0 in its recovery (25 x 3 + the decay): out at neutral |
| B14 / B14b the entry pose | P2's J1 inside it whiffs (invulnerable); the same J1 with no pose hits 35 |
| B15 Shikai NS1 a-b from heat 60, P2's J1 meets NS1a's wave after NS1b started | spends 25 (35), 25 (10), the wave's CANCEL refunds 25: 35 |
| B16 J1 hit in his ORANGE burst | no heat (0) |

The tornado's turn is host-tested (1 deg a step toward him, a wave without `:track` straight): the trial runner has no side step. The browser
script `tests/scripts/duel-yama-blaze.json` (generated by tests/scripts/duel.py) reads the same lines through the page (HEAT +8; NS3a from 40
spends 25 x1.30, dealt 22; GOKUEN in neutral; the drain held at 1; a free 爆炎 NS1a, cost 0) with stills of the heat strip, 爆炎 and MIN 1
(`tests/shots/duel-yama-*.png`, desktop); the phone checked by eye, both the plate without the deck and the strip hung under the deck's
line (87901 turns the deck on). Native CPU smoke (generic CPU, 3 seeds each, no error; rerun after the refund / burst fixes): YK Kenpachi 2-1 (Yamamoto won seed 2 on time);
IY Ichigo 3-0 (three 300 s time-outs), Yamamoto entered 爆炎 once (eight 爆炎 moves, five burns, out at heat 0); HY Hisagi 3-0. The CPU
spends its heat on NS routes, so it seldom reaches 100.

Checks: host tests ALL PASS (3970 checks, +101: the pure heat rules, the drain and burn floors, the latch both ways on stand-in fighters, the
爆炎 copies' class tags and chains, no mid-route knockdown, the free SP, the hazard's heat refund after the next segment, no gain in a burst,
the tornado's turn, both hooks off for every other kit); pkgcheck as main; `--cvc` II / IK / KK identical; `python3 tests/sp-costs-check.py`
116 PASS, 0 FAIL; `./build.sh duel`; the browser smoke (`run.mjs` exit 0).

**Open for stage C.** The Bankai (東 / 西 / 南 pointers, marks on an AS hit, 北 as a flag, 天地灰尽) and the awakening in place of `:no-awaken`
(in 爆炎 it ends 爆炎 and heat leaves with the Shikai, §3). Also open: 爆炎's art (the flame trail, ENNETSU's pillar rows, IKKOTSU's own
timing, the burn's look), a CPU that reads heat (none asked for), the Kikon storyboards, and the defaults §9 keeps (a Kikon landed or taken
does not end 爆炎). The burn writes Reishi directly (`burn`), not through `deal-damage`, so under Hisagi's bind (HY) the bind's grey
accounting does not see it: check when HY is played.

## 14. As built (batch 1 C: the Bankai, the marks and 北, 2026-11-19)

Stage C on top of §11 and §13: the Bankai ZANKA NO TACHI as §4, §7.3 and §7.4 decide, in `duel/lisp/yama.lisp` (a section of moves and the
kit, the pure mark rules, the sim hooks), the old kit's two cinematics in a new `duel/lisp/yama-cine.lisp`, two stance loops in
`yama-art.lisp`, four shared switches that default off (the `:ns-pick` and `:switch-ok` hooks, the `:turn-armor` param, the
`:ns-extra` / `:as-extra` keys), and the HUD's seals and marks.

**Built.**
- **The awakening** (Mod + P, as every kit): `:no-awaken` left both Shikai kits; `:awaken-form :bankai` on the Shikai (爆炎 inherits it).
  The kit `:bankai` has its own `:core` and no `:inherit` (no heat hooks, no drain, no free SP). Its `:enter-hook` (`yama-bankai-enter`)
  sets heat to 0, so heat leaves with the Shikai, and an awakening in 爆炎 ends 爆炎. Its own `:meter` ("ZANKA", max 1) keeps the plate from
  inheriting the heat strip. It wears the body `:yamamoto-tybw` (no haori) and the weapon `:zanka`, uses the stance `ya-e-stance` and the
  grade `:spot`. The entry cinematic is the old `yama-bankai-cine`: it runs on today's cinema API with no change, and the browser still
  `duel-yama-bankai-cine.png` shows its card.
- **The pointers** (§7.3's numbers; damage before `:mult` 1.0):

| Pointer | NS a / b / c | AS n |
|---|---|---|
| 1 東 | a KYOKKO S20, a 4.6 m line, slide 1.6, 80 / b the sunrise S14, slide 1.6, 70 / c KYOKUJITSUJIN S18, a low 6 m line, 120, knock-back | AS1 S10 the tip-touch 50, a knockdown, `:steal-fs` 30 |
| 2 西 | a SHONETSU S16: no swing, a burn round him (r 2, 360°), two windows of 45 (f16, f26) / b the advance S14, slide 1.5, armour f6 to S, its own NS burn r 2, 40 / c the counter-cut (Y11) S12, armour f6 to S, 90, knock-back | AS2 S12 the grab 40, a stagger > the flare S12, 70, a launch |
| 3 南 | a the plant S22: hands at the victim's bearing 4-10 m (r 1.2), the point taken on S, the hands on S + 16 (`:delay` 17 inside A 17), 40, a bind (60 f) / b the swarm S16, a wave at 6 m/s over 8 m, 50 / c the bone wall S18: the fall on a disc 3 m ahead (r 1.6), 70, a crumple; the wall stands 90 f | AS3 S10 the hands at him 40, a stagger > the swarm S10, a wave at 8 m/s, 50 > the pile S12 at him (r 1.4), 100, a knockdown |
| 北 | NS S24: one wave 4 m wide, 20 m/s over 14 m, 220, a knockdown | AS S10: the same cut point-blank, 180, a knockdown |

  The NA is E-J1 S14 (34, the old HIZASHI clip slowed: the opener's tell) > E-J2 S7 (38) > E-J3 S8 (42, a stagger). The SA is S6, 60, the
  old counter's clip. SP costs (DUEL_SP §4, `*sp-table*`, DUEL_DESIGN §5.1 regenerated): NS 110 / 85 / 65, AS 20 / 45 / 75, 北 NS 60 and AS 60.
- **The marks and 北** are fighter state on his `yss` component (`marks` as bits 東 1 / 西 2 / 南 4, `north` as a flag). They live through
  every form change and Konpaku reset for the match.
  - Pure rules, host-tested: `ya-mark-add` (a repeated mark stays one; the third distinct mark arms 北), `ya-north-pick`, `ya-north-start`
    (the marks to 0, the flag off), `ya-switch-ok-p`.
  - A mark is given by `yama-bk-hit`, the Bankai's `:hit` hook. It fires on a real hit of an AS segment, or of the hazard it fired, in the
    Bankai. Each AS segment carries `:params :mark n`, and a hazard copies it into its data at the fire frame.
  - While 北 is armed, the new `:ns-pick` hook (`yama-ns-pick`) starts 北's NS in place of the pointer's. The existing `:as-pick` hook
    (`yama-as-pick`) starts 北's AS after any J count and returns no pointer, so `core-as-start!` logs `AS1 pointer kept 3`.
  - 北's moves sit outside the pointer grammar, in the new core keys `:ns-extra` / `:as-extra`. `core-routes` feeds them to the class
    table, the SP costs and the move table, and 北's NS starts at fs 0 as a route's first segment. The pointer clamp, `:stances`,
    `:kikon-cines`, the Konpaku table and the switch's route count still see three.
  - On its frame 0, a 北 move runs `yama-north-start`: the marks clear, the flag drops, and `fighter-sp-ptr` becomes 3 (pointer 3's Kikon
    profile). The pointer itself was never touched, so it stays n, the third AS's write.
  - The Kikon cinematic is the landing strike's `:cine`: `yama-tenchi-cine` sits on 北's AS and on its wave's strike copy
    (`:ya-e-n4-strike`). The browser still `duel-yama-tenchi-cine.png` shows its card.
- **The shared changes**: four switches, each off by default (plus `core-routes`, the one list of a kit's routes).
  - kit.lisp: `:ns-extra` / `:as-extra` (`core-routes`), and the hook docs.
  - core-sim.lisp: `core-sp-start!` asks the kit's `:ns-pick` hook first; `core-switch-open-p` asks the kit's `:switch-ok` hook.
  - `core-verdicts`: a defender inside a move's `:params :turn-armor` window (f `*armor-from*` 6 to S, `core-turn-armor-p`) turns an NA's
    `:cancel` into an `:absorb` (core.lisp `core-turn-armor-verdict`, pure). Every other verdict stands, so an AS still hits.
  - No other kit has any of these (host-tested), and `--cvc` stays byte-identical.
- **HUD** (no new model slot).
  - The Bankai's `:hud-tag` hook returns constant strings: `MARK 1` ... `MARK 123` by the marks held, and `NORTH` while 北 is armed.
  - lhud-data's FORMS give "ZANKA NO TACHI" the seals 東 / 西 / 南 with their names. "ZANKA NO TACHI NORTH" keeps the seals and names every
    pointer 北 · TENCHI KAIJIN, through the existing form + tag lookup. So both plates and the phone deck replace the label.
  - `lhud-marks` (the side's derived slot 10) gives the held marks, and `lhud-marks-at` draws them in the ember colour after the pointer's
    name, on the plate's seal row and on the deck's ring.
  - webhud's next-NSa price tick (o+27) asks the kit's `:ns-pick` hook first, so it shows 北's 60 while armed.
  - The tag line shows neither tag. The select card is unchanged. The callouts' kanji were added, and the atlas was rebaked (lhud-charset
    passes).
- **CPU**: the generic core CPU plays the Bankai and 北 as they are: `:ns-range` 東 (2.0 5.5), 南 (4.0 9.0). No tuning.
- **Debug** (87000-87999): 87420+i a Bankai segment on its own (i 0-9), 87440 awaken now, 87441-87443 a mark, 87444 北 armed, 87445 cleared,
  87446 into the Bankai with no cinematic, 87447 a `duel yamamoto switch` line. The probe line now carries the marks and 北.

**Placeholders** (§7.3 leaves them open; the lead's numbers, to be tuned by play):
- Frames and hit volumes:
  - every A / R;
  - E-J1-3's reach 1.52 / 1.59 / 1.71, written as arcs (as stage A did);
  - NS1b's slide and reach;
  - NS1c's 6 m low line and its knock-back 3;
  - AS1, AS2a / b, AS3a / b / c's S (10 / 12 / 12 / 10 / 10 / 12) and their radii;
  - NS2c's S12, 90 and knock-back 3;
  - NS3b's width 2 and range 8 m;
  - NS3c's fall disc (3 m ahead, r 1.6) and its crumple;
  - 北's wave speed 20 m/s;
  - AS 北's S10, reach 2.4, arc 110;
  - the SA's reach 2.0 and its stagger;
  - the bind's 60 f (`*ya-bind-stun*`, the old kit's).
- Clips (the old ones, §8):
  - NS1a `ya-e-kyokko`; NS1b `ya-e-f2`; NS1c and AS1 `ya-kyoku`;
  - NS2a / NS2b / AS2b `ya-shonetsu`; NS2c / AS2a / SA `ya-w-counter`;
  - every 南 segment `ya-kaka`;
  - 北 `ya-e-tenchi` (stretched from S6 to S24 on the NS);
  - the Kikon strikes E-J1's.
- Stances: 東 `ya-e-stance`, 西 `ya-st-nishi` (a loop on SHONETSU's flare pose), 南 `ya-st-minami` (a loop on MINAMI's incantation pose,
  the blade upright before the face). The last two are two-key loops on old poses.
- Looks: the hands and the pile are the fire column, the swarm the fire wave, the wall a column, the fall the dome, 北's wave the tornado
  pillar. KYOKUJITSUJIN's slit and ground line are not drawn.
- Cinematics: 東 / 西 / 南's Kikon are `soul-break-cine`. In `yama-bankai-cine`, `vfx-awaken-burst` has no `:bankai` / `:bankai-burst`
  look, so it draws nothing.

**Deviations, each with its reason.**
1. AS 北 "follows any J count (`:params :as-ptr`)" is built through the existing `:as-pick` hook, which ignores the press count. `:as-ptr`
   names the AS of the move he is in; 北's AS must follow J1, J2 and J3 alike, and `:as-pick` returning `(values move nil)` also writes no
   pointer.
2. 西's armour is not `:armor-hits`. `:armor-hits` is judged in `resolve-contact`, after the triangle. A J on an NS cancels before it,
   and an AS would be `:armored` (Kenpachi's NS2), the opposite of "an AS still beats it". The armour is read in the triangle instead
   (`:turn-armor`): an NA is absorbed as by a turn move (SA / AS), and an AS's hit stands. NSc carries the same param.
3. "The pointer switch is refused while 北 is armed" is close to unreachable. Marks come from an AS, so he is never in an NS route when
   北 arms, and his next NS is 北, which clears the flag at its start. The guard therefore also covers a 北 move in play (a switch out of
   its gap would skip it). It is proven by the host test and the debug line (the native trials have no side stick).
4. The bone wall's wave stop is his own hazard hook (`yama-wall-stop` from `yama-hz`'s `:step`), not shared machinery. An opponent
   `:wave` / `:fireball` whose centre comes within the wall's half width plus its own is spent there through `core-hazard-nohit!`
   `:absorb` (as a classless blade cuts one: no refund, no exchange). "Rises before him, then falls forward (S18, 70)" is built as both on
   S: the fall's hit on a disc 3 m ahead, and the wall 1.2 m ahead standing 90 f with no hit. A 90 f fall would need a 90 f active window
   (§7.4's delayed-hazard rule).
5. A mark comes only from a real hit (`:hit` / `:counter`). A cancel, a block, or the Kikon's follow-up strike gives none (§7.4: "when
   the AS lands, its first hit").
6. "Marks and an armed 北 survive the Bankai's end": the Bankai has no end (no `:duration`, no `:reset-form`). The marks live on the
   fighter for the match, so they would survive one.
7. `yama-tenchi-cine` lost one line: the old script set the victim's `model-alpha` to 0 after the ash, and nothing restores it after the
   reset.
8. Heat leaves through the Bankai's `:enter-hook`, not a `:meter :start`, so the zeroing and its log line sit in one place.

**Readings** (2026-11-19; native trials `tests/trials/yamamoto-bankai.lisp`, P1 scripted, P2 Kenpachi unless named; base damage in the
hit lines):

| Trial | Reading |
|---|---|
| C1 the awakening from the Shikai at heat 40 | `AWAKEN from IDLE`, `ZANKA NO TACHI: heat 40.0 -> 0`, form BANKAI, meter 0 |
| C2 the awakening in 爆炎 at heat 100 | `ZANKA NO TACHI: heat 100.0 -> 0`, form BANKAI (爆炎 over), meter 0 |
| C3 東 NS a-b-c (3 m) | 80 > 70 > 120, gaps 0 0; SP 30 + 30 + 50 |
| C4 西 NS a-b-c (1.6 m) | 45 45 > 40 > 90, gaps 0 0 0; SP 35 + 15 + 35 |
| C5 南 NS a-b-c (4 m) | the hands 40 (bound, combo 2) > the wall's fall 70 > the swarm 50 (the slow wave lands after the fall); SP 15 + 20 + 30 |
| C6 J1 > AS1 | 34 > 50, `AS1 pointer 1`, `MARK EAST (marks 1)` on AS1's hit, STEAL fs 30 |
| C7 J1 J2 > AS2 | 34 38 > 40 70, `MARK WEST (marks 2)` on AS2a's hit |
| C8 J1-J3 > AS3 | 34 38 42 > 40 50 100, gaps 0, `MARK SOUTH (marks 4)` on the hands' hit |
| C9 東 held, J1 > AS1 | no MARK line: a repeated mark stays one |
| C10 東 西 held, J1-J3 > AS3 | `MARK SOUTH (marks 7)`, `NORTH armed (pointer 3)` |
| C11 NS 北 (armed, pointer 2, 6 m) | `NORTH YA-E-N4: marks cleared, pointer 2`, SP 60, the wave 220, the pointer still 2 |
| C12 AS 北 after J1 (armed, pointer 3) | `AS1 pointer kept 3`, 34 > 180, no MARK |
| C13 the switch line | armed: `open NIL north T`; cleared: `open T north NIL` |
| C14a 西 NSb x P2's J (2.6 m: NSa whiffs, NSb slides in) | `P2 KE-Z-J1 x P1: ABSORBED` (NSb f8), then NSb's burn 40 |
| C14b the same J on NSa's startup | `CANCEL`, P1's SP refunded 35 |
| C15 西 NSb x P2's AS1 (started under it) | `P2 KE-Z-AS1 -> P1 HIT 90` on NSb's f10 (inside f6-14) |
| C16a 南 NSa, P2 Steps on sim frame 24 (after S22) | no hit, P2 2.5 m further out |
| C16b the same, no Step | the hands 40, bound (combo 2) |
| C17 南 NSc's wall x Ichigo's Getsuga (P2's AS2b at 8 m) | `P1's bone wall stops P2's wave`, `P1 beats P2's wave as`, no hit on P1 |
| C18 AS 北 held after J1 (pointer 2) | the Kikon: -2 Konpaku (pointer 3's profile: the Bankai's 3 - 1) |
| C18b AS2 held after J1 J2 (pointer 2, no 北) | the Kikon: -3 Konpaku (pointer 2's profile) |

The browser script `tests/scripts/duel-yama-bankai.json` (and `-phone.json` with the deck, 87901; generated by tests/scripts/duel.py)
reads the same lines through the page. It also plays the two cinematics the native trials skip: the awakening's card (卍解 / 残火の太刀)
and 北's Kikon (北 / 天地灰尽). Stills: `tests/shots/duel-yama-bankai*.png`, `-marks` (東 南 by the pointer), `-north` (北 · TENCHI KAIJIN,
東 西 南), `-tenchi-cine`; the same with `-phone`. On the phone run the AS 北 scene lands without a Kikon: with the deck up, P1's SP
hold is the touch rule (`core-touch-p`), which keyboard keys do not drive. Its `-tenchi-cine-phone` still therefore shows the fight, and
the cinematic is the desktop run's.

Native CPU smoke (the generic CPU, 3 seeds each, no error): YK Kenpachi 2-1, IY Ichigo 2-1 (Yamamoto won seed 2 on time), HY Hisagi 3-0.
Every match awakened him into the Bankai. 北 was armed in eight of nine matches and played as NS or AS in each of those eight.

Checks: host tests ALL PASS (4067 checks, +97: the Bankai's class tags, openers, no mid-route knockdown, AS segment counts, stances,
strikes and cinematics, the pure mark and 北 rules, the turn-armour verdict, the marks on stand-in fighters with the pointer never 4, the
HUD's seals / marks / tags, every new hook off for the other kits); pkgcheck as main; `--cvc` II / IK / KK identical;
`python3 tests/sp-costs-check.py` 116 PASS, 0 FAIL (it plays no Yamamoto route: the Bankai's costs are pinned by `*sp-table*` only);
the stage A and B trials (`yamamoto-core.lisp`, `yamamoto-blaze.lisp`) give tables identical to db0e303c's; `./build.sh duel`; the
browser smoke (`run.mjs` exit 0).

**Open.** The art batch:
- the pointer stances' own clips;
- every Bankai move's own clip;
- the hands, swarm, bone wall and wall-fall looks, KYOKUJITSUJIN's slit, the awakening burst's `:bankai` look.

Also open:
- The plate's Konpaku stake (o+4) while 北 is armed still reads pointer n's profile (the stake knows nothing of 北's 3).
- 南's timing at 4 m: NS3b's swarm (6 m/s) lands after NS3c's fall. The route's last hit is the late wave, the kind of late effect
  duel-move-modules warns about: check it in the playtest.

Also open: the Kikon storyboards (東 / 西 / 南 still `soul-break-cine`), drawn reach against hit reach (the host FK test does not load
yama-art), a CPU that reads the marks or 北 (none asked for), and §9's defaults.

## 15. The art batch and the 東 / 西 / 南 Kikon storyboards (planned 2026-11-20)

The user, 2026-11-19: 「先做這兩件事」 (「動作與外觀美術」 and 「東西南的毀魂技分鏡」). The plan was drafted by a Fable review (grades: A canon, B official
game, C secondary, D the lead's proposal; sources §4 / §6 / §7.3 / §14, `motion-refs.md` §1.6-§1.9, §5.3-§5.6, `canon-looks.md` §4, §6; code as of
05acf777). The user's decisions are in §15.4; their 西 storyboard replaces the draft's (§15.3.2).
### 15.1 Order and batching

**Bankai first, then the Shikai, then 爆炎.** One form at a time, its looks before its strikes (skill rule).

| Evidence | For |
|---|---|
| §14's placeholder list is longest and most wrong in the Bankai: 5 looks are fire stand-ins (hands, pile, swarm, wall, fall), 北's band is the tornado, the slit and the awakening burst draw nothing, two stances are two-key loops, all six 南 segments play one clip, `ya-w-counter` serves three slots, 北's NS is a S6 clip stretched x4 | Bankai |
| The three storyboards need the same looks (the dead, the void line, the garb): built once, used twice | Bankai |
| Cheap: the old kit left unused Bankai assets in main: the `:skeleton` body + `:sk-grab`, `vfx-kyoku-slit` (`%st-slit`), `vfx-skeleton-dust`, `vfx-garb-flare` / `vfx-nishi` / `vfx-garb-block` / `vfx-scorch` / `vfx-burnout`, the spare clips `ya-e-f1`, `ya-e-drop`, `ya-w-parry`, `draw-planted-weapon` | Bankai |
| Against: every match starts in the Shikai (seen longest); and the Bankai's A / R and the AS S values are §14 placeholders "to be tuned by play" (red flag: clips drawn while the rules still move) | Shikai |

Answer to the risk: looks and stances do not depend on A / R, so they go first; before any strike is keyed the lead freezes the S list
(§2.2's S column) with the user's playtest of stage C. A later A / R change costs a recovery key, not a clip.

| Batch | Content | Review gate (stills to the user) |
|---|---|---|
| K1 | FK coverage first (Yamamoto's Bankai into `tests/duel-rules/art.lisp`: prints today's tips), then the look list §2.1 | every look: match camera + side, landscape + portrait |
| K2 | the three stances, NA, 東's strikes | the stance triptych (debug 2510 + p), 8-frame strips |
| K3 | 西, 南, 北, SA strikes | strips, then the playtest Artifact |
| K4 | the three Kikon cinematics from §3 (after the storyboards' yes; needs K1) | one still per beat, both aspects |

### 15.2 The Bankai in full

Colour rule (D, from A: "no flames are visible as it cuts", ch. 507; the kit's grade is `:spot`): the Bankai is **ink / charcoal + bone-ash
white + one ember hairline**. Orange flame appears only in 西 (the garb, A) and 北 (the band's rim, A). So at most 3 hues a look, and
fire itself becomes the tell that says 西 / 北.

#### 15.2.1 Look list

| # | Look (hazard / effect) | Canon | Shape as vector ink | Sim footprint it must equal | On which frames |
|---|---|---|---|---|---|
| L1 | the dead hands (NS3a, AS3a) | charred skeletons out of a rupture (A, ch. 508) | 3 `:skeleton` bodies, charcoal with thin red highlights (D1), hips under the floor, clawing up (`:sk-grab`) on the disc; an ember crack star under them; `vfx-skeleton-dust` | disc r 1.2 at his bearing 4-10 m (NS); r 1.2 at him (AS) | NS: the crack star glows from S22 through the 17 f delay (the tell a Step reads); the clench lands on S+16 (start `:sk-grab` 8 f before), hot 6 f, gone by 30. AS: at f10 |
| L2 | the swarm (NS3b, AS3b) | they crawl and swarm (A) | a low front of 4 crawling torsos (ink mass, red skull and arm highlights (D1), on twos), ash dragged behind | box 2 m wide; 6 m/s over 8 m (NS), 8 m/s over 6 m (AS); the front edge = the hazard's x | from S16 (NS) / S10 (AS), for its life |
| L3 | the bone wall (`:ya-wall`) | a pile-wall of bodies shields him (A, ch. 509) | a rampart of stacked torsos and skulls, **chest-high (≤ 1.4 m) with gaps** so the behind camera still sees the foe; crumbles to ash in its last 10 f | 3.2 m wide (half 1.6), 1.2 m ahead; stands 90 f; stops waves | rises over the startup f6-S18 (drawn by the move's draw hook: the tell); stands S..S+90 |
| L4 | the wall's fall (NS3c's hit) | (D: the sim's "falls forward") | the rampart's crest topples as an avalanche of bones onto the disc; ash ring on landing | disc r 1.6, 3 m ahead | lands on S18, hot 4 f; debris to 30 |
| L5 | the pile (AS3c) | the dead bury the victim (A, ch. 508-509) | a mound closing in from three sides over him, to 1.8 m; bursts to ash | disc r 1.4 at him | f12, hot; ash to 30 |
| L6 | KYOKUJITSUJIN's erased line (NS1c) + the slit | the tip touches the ground, a chunk vanishes; no fire (A, ch. 507) | the white down-cut slit (`vfx-kyoku-slit`, exists) + a flat **black void strip** on the floor with an ember hairline rim, ash falling in | `:cap 0.2 6.0 0.3 0.4`: 0.2-6.0 m ahead, 0.8 m wide, low | slit on S18; the strip **at full length on S** (the hit is the whole line at once), held 20 f, then filled by ash. AS1: a 1.6 m notch at S10 |
| L7 | KYOKKO's lance (NS1a) | "focuses all his flames into the tip" (B) | a white hairline with an ember core from the tip to the cap's end (no blade is 4.6 m long; the old kit's edge flare) | `:cap 0.2 4.6 1.1 0.3` | S20-S22 |
| L8 | SHONETSU's flare (NS2a / NS2b / AS2b) and 西's garb | orange tongues from the feet, shoulder wings ~2x his width, molten ring at the soles (A, `508Yamamoto in flames`) | `%st-flare` + the ring of `vfx-nishi` rescaled so its **outer edge is 2.0 m**; the wings as two ribbon fans; white-hot core on the pulse | r 2.0, 360° | NS2a pulses on f16 and f26; NS2b on S14; AS2b on S12. The low garb (tongues to the knee, small wings) rides pointer 2's stance |
| L9 | 西's armour absorb | the foe's blade is erased on his body (A) | `vfx-garb-block` + `vfx-scorch` (both exist) on the `ABSORBED` event | at the contact point | the absorb frame |
| L10 | 北's diagonal band (NS wave; AS crescent) | a wide diagonal white band, the blade a smear (A, `509…Kita`) | a leaning white sheet (tilted ~35°), ember rims, ink backing, a scorched ash strip left on the floor | wave 4 m wide, 20 m/s, 14 m (42 f); AS: reach 2.4, arc 110 | NS from S24; AS on S10 |
| L11 | the awakening burst `:bankai` / `:bankai-burst` | every flame is drawn into the blade; the charred blade (A, ch. 506) | `:bankai`: ~24 fire scraps flying **inward** to the raised blade; `:bankai-burst`: an outward ink + ash ring and shards, no flame | none (cinematic) | `yama-bankai-cine` f12 and f118 (the calls exist) |

#### 15.2.2 Clip table

Planes / hands in use, none shared: E-J1 level R→L fore, E-J2 rising L→R back, E-J3 rising thrust, NS1a level thrust, NS1b vertical up,
NS1c ↙ back, AS1 vertical point drop, NS2c rising R→L fore, SA level L→R back, 北 NS ↗ trailing pass, 北 AS ↘ fore; 西's a / b and all of
南 have no swing (body / plant). He has one arm: a grab plants the blade first (`draw-planted-weapon`, as IKKOTSU).
Tip targets are from the move's volume; **the K1 FK print decides** where arm + blade (≈ 1.9-2.2 m with a lunge) falls short.

| Slot | S / A / R | Archetype | Body in one line | Grade | Verdict | Now plays | Drawn tip target |
|---|---|---|---|---|---|---|---|
| Stance 東 | loop | the naming pose | upright, the fist toward the foe at chest height, the blade **level across**, its tip out past his left side; the smoke thread | A | new `ya-st-higashi` | `ya-e-stance` (the Bankai's idle: stays the idle) | - |
| Stance 西 | loop | the furnace | feet apart and sunk, chest out, chin up, arms open low, the blade low right point-down; L8's garb breathing | A | re-key (4 keys: the wings breathe, the feet sink) | 2-key loop on SHONETSU's pose | - |
| Stance 南 | loop | the plant, held | the blade **vertical, point down**, the hilt at the chin, the elbow winged high; held 0.25 m right of the face so the behind camera sees it (D); faint ember cracks at his feet | A (pose) / D (offset) | re-key | 2-key loop on MINAMI's f9 | - |
| E-J1 | 14 / 3 / 12 **(opener: held tell)** | fencer's lunge | charge f0-9 (drawn back right, level), held f10-12, release f13-14: the deep lunge, a level cut at face height | A | re-key at S14 (poses kept) | `ya-e-q1` at clip-s 8 | 1.52 (arc 100) |
| E-J2 | 7 / 3 / 13 | the return | from the lunge a rising backhand, he stands as it rises | A + D | reuse | `ya-e-q2` | 1.59 |
| E-J3 | 8 / 3 / 18 | lunge finale | dropped knee, an underhand rising thrust | D | reuse | `ya-e-q3` | 1.71 (arc 60) |
| NS1a KYOKKO | 20 / 3 / 26 **(tell)** | the lunge, extreme | chambered at the right hip, point at him, held f12-17; the body near horizontal at S | A | re-key at S20 | `ya-e-kyokko` clip-s 15 | the tip as far as FK gives; L7 carries the rest to 4.6 |
| NS1b sunrise | 14 / 4 / 24 | hammer | **frame 0 = KYOKKO's landing lunge**; the blade swung up through vertical, rising onto the toes | D | re-key (new f0, S14; hit pose kept) | `ya-e-f2` clip-s 19 | 1.56, h 1.3 |
| NS1c KYOKUJITSUJIN | 18 / 5 / 26 | the tip-tap | from the raised blade (1b's end) a backhand ↙, only the tip touches the floor on f20 | A | reuse (f0 re-keyed to 1b's landing) | `ya-kyoku` | tip on the floor ahead; L6 is the 6 m |
| AS1 | 10 / 3 / 24 | tip-tap, point-blank | no body swing: the wrist lifts the point to the shoulder, drops it straight to the floor at his toes | A (idea) / D | new `ya-e-as1` | `ya-kyoku` x1.8 | 1.6 (arc 90) |
| NS2a SHONETSU | 16 / 12 / 24 **(tell)** | the furnace | no swing: drawn in f0-12, the arms open on S; a second chest pulse on f26 | A + D | reuse + one key (f26) | `ya-shonetsu` | - (L8 r 2.0) |
| NS2b the advance | 14 / 3 / 20 | the furnace walks | two slow dragging steps, chin up, the blade low; he takes the hit without a flinch (armour f6-S) | A (ch. 508) | new `ya-e-advance` | `ya-shonetsu` | - (L8) |
| NS2c the counter-cut | 12 / 3 / 24 | furnace counter | still f0-7 (taking it), then a rising forehand from the low carry up to his left, one step | D | new `ya-e-gokui-cut` (frees `ya-w-counter` for the SA) | `ya-w-counter` x0.5 | 2.0 (arc 120) |
| AS2a the grab | 12 / 3 / 16 | take the hit, then grab | the blade planted beside him, the right hand shoots to the collar | A (Aizen, Yhwach) | new `ya-e-grab` | `ya-w-counter` | hand at 1.6; if FK is short the garb's flame on the hand covers ≤ 0.3 m |
| AS2b the throw | 12 / 3 / 24 | the flare | arm locked out holding him, the garb flares, the hand opens upward | D | new `ya-e-throw` | `ya-shonetsu` | - (L8) |
| NS3a the plant | 22 / 17 / 20 **(tell)** | the plant | upright hold f6-18 (trembling 3 f), driven straight down into a half kneel on S | A | re-key at S22 | `ya-kaka` | cast check: blade in the floor |
| NS3b the swarm | 16 / 2 / 22 | "go" | still kneeling: the hand twists the planted hilt and levers it forward, the head lifts | D | new `ya-e-minami-b` | `ya-kaka` | - |
| NS3c the wall | 18 / 2 / 30 | the rip | he rises, ripping the blade up out of the floor to overhead on S; recovery: the chest turns away (no root yaw) | D + A (walks away) | new `ya-e-minami-c` | `ya-kaka` | - |
| AS3a the hands | 10 / 3 / 16 | the short plant | from E-J3's dropped knee: a reverse stab into the floor by the front foot | D | new `ya-e-as3a` | `ya-kaka` x2 | - |
| AS3b the swarm | 10 / 2 / 18 | "go", by hand | the hand leaves the planted hilt and sweeps low, palm forward | D | new `ya-e-as3b` | `ya-kaka` | - |
| AS3c the pile | 12 / 3 / 30 | the back turned | he stands, draws the blade out low and looks away as it lands | A (ch. 509) | new `ya-e-as3c` | `ya-kaka` | - |
| 北 NS | 24 / 2 / 30 **(tell)** | hammer from the sky | gather f0-15 (the blade trailing low behind, the only time it burns), coil held f16-20, release f21-24: one passing cut ↗ | A | re-author at S24 | `ya-e-tenchi` S6 x4 | cast check (the wave starts 1 m ahead) |
| 北 AS | 10 / 2 / 30 | the same, point-blank | from over the right shoulder a diagonal ↘ to his low left | A (the band's direction) | revive the spare `ya-e-f1`, re-keyed to S10 | `ya-e-tenchi` | 2.4 (arc 110); L10's crescent covers what FK leaves |
| SA | 6 / 3 / 24 | the short backhand | chest-height L→R, one step | D | reuse (its home now) | `ya-w-counter` | 2.0 (arc 120) |
| Kikon strikes (NS / AS / 北) | E-J1's | - | copies of E-J1: they follow its re-key | - | none | E-J1's | 1.6 |

Count: 11 new, 7 re-keyed, 5 reused, 1 spare revived; `ya-e-drop` and `ya-w-parry` stay spare (the cinematics use them).

#### 15.2.3 Checks the batch proves

| Check | How |
|---|---|
| Presentation only | the native trials `tests/trials/yamamoto-bankai.lisp` (C1-C18), `-core`, `-blaze`: tables identical before / after; the browser script `duel-yama-bankai.json` state-hash and log lines identical; `--cvc` II / IK / KK byte-identical (it plays no Yamamoto: it proves the shared files only). The only `yama.lisp` edits allowed are `:clip`, `:clip-s`, `:look` |
| Drawn reach = hit reach | Yamamoto's Bankai added to the host FK test (`tests/duel-rules/art.lisp`), ±0.15 m; today it does not load `yama-art` (§14 open). Printed before drawing; cast checks for the no-hit-window moves |
| Looks = footprints | each look's edge against §2.1's radius / width in a top-down debug still |
| 0 B / frame | a `vfx consing` probe (debug 2328's pattern) per new look and for the extra skeleton bodies |
| Others untouched | the looks gate's 75 stills byte-identical (new `vfx-awaken-burst` kinds are new branches) |
| Stills | per segment (debug 87420+i) and per stance: match camera + side, landscape + portrait (87901); 8-frame strips side + front; 緩急 by the tip's speed per frame for E-J1, KYOKKO, 北 |

### 15.3 The three Kikon storyboards

House length: the Kikon cinematics in main run 150-206 f (Ichigo 180, Hisagi 150, Kenpachi 196-206), `:hold` 100-160; 天地灰尽 is 168.
Kept apart: 天地灰尽 = the black card, the white slash, the manga page. 東 = **absence** (a tap, then nothing, then the world is missing),
西 = **heat at arm's length** (the foe strikes, the old man takes hold), 南 = **the crowd, and his back** (he never touches the victim).
Landscape letterbox 9 %; "P:" = the portrait note.

#### 15.3.1 東 旭日刃 KYOKUJITSUJIN (168 f)

Idea: one tap of the point; a held beat where nothing happens; then the floor behind the victim is gone.
Actors: `cine-place a v 2.2` (the tip lands at the victim's feet). The victim ends crumpled on the lip of the void, at his placed spot.

| Frames | Shot (angle / dist / height / lens) | Action | Effects / sound | Note |
|---|---|---|---|---|
| 0-12 | (held from play) | beat 0: `hold-both`; he holds `ya-kyoku`'s raised pose (f15), the victim `:sh-kikon-victim` | negative 2 f; whoosh | |
| 12-44 | on him, front 30°, 3.0 m, 0.6 m high, lens 44, roll -6 | the blade high and angled; the only colour its ember edge | silence 32; caption 旭日刃, mark 東, KYOKUJITSUJIN, hanko | P: `:off` halves by itself |
| 44-62 | side-on pair, 5.0 m, 1.0 m, lens 50 | `cine-slow` 0.35: the diagonal comes down, passes his face by a hand's width, the tip taps the floor at his feet (f58) | one dry tick; a pinch of ash at the tip | P: 7.0 m |
| 62-84 | ground level on the tip, 1.6 m, 0.15 m, lens 70; the victim's feet behind | nothing. The smoke thread rises. The victim looks down | silence 22 | the economy beat (A: the result arrives late) |
| 84-100 | from behind him, high: 180°, 6.5 m, 7 m up, looking 4 m ahead, lens 40 | the void opens from the tip: a black wedge, 0.8 m at the tip widening to ~5 m, through the victim's spot to the arena's edge in 10 f | L6 at cinematic scale; ember hairline; ash falls **into** it; the boom 4 f late; shake 0.5 | P: the wedge runs up the tall frame |
| 100-130 | on the victim from behind him, 150°, 4.0 m, 1.0 m, lens 50 | he stands half on the black; f104 the Konpaku shatters; he crumples on the lip | negative 2, `cine-shatter`, manga 10, splash; konpaku-shatter | |
| 130-168 | low, behind the fallen victim, looking back across the void at Yamamoto, 7 m, 0.4 m, lens 40 | he lifts the point off the floor and lets the blade hang | caption exits; ash still falling | |

#### 15.3.2 西 殘日獄衣 ZANJITSU GOKUI (180 f; the user's storyboard, 2026-11-20)

The user (verbatim, replacing the draft's young-Yamamoto / grab / throw version): 「西 殘日獄衣：對手先出手，武器碰到火衣就從刀尖化成灰。山本燃起灼熱的火衣並緩步走向不知所措的對手。最終瞬間穿過對手，使其被升騰的高溫烈焰燒成灰燼。」

Idea: the foe strikes first and his weapon dies on the garb; the old man, burning, walks at him slowly; in one instant he passes through
him, and the rising flames burn the foe to ash. Actors: `cine-place a v 1.4` (the foe's strike reaches him). He walks the foe back about 1.5 m,
then passes through and ends ~2 m beyond him; both are given back at `cine-end`. The victim ends down at his spot, charred and smoking (no
alpha 0: §14 deviation 7; the ash is drawn rising off a black silhouette).

| Frames | Shot | Action | Effects / sound | Note |
|---|---|---|---|---|
| 0-10 | (held) | beat 0; he stands chin up, the blade low | negative 2 | |
| 10-40 | over the victim's shoulder: on v 160°, 2.2 m, 1.5 m, lens 60 | `cine-slow` 0.3: the victim's own first attack swings in; he does not move | a faint garb at his feet; a rising sizzle | P: 3.0 m |
| 40-52 | close on his chest: 20°, 1.6 m, 1.4 m, lens 80 | contact (f40): the weapon turns to ash from the tip toward the hilt; the victim recoils | `vfx-garb-block`, `vfx-scorch`, an ash ribbon drawn over the weapon (the model untouched); silence 12 | §15.3.4 flag 4 |
| 52-72 | low front: 10°, 3.4 m, 0.5 m, lens 40 | the garb ignites: tongues from the feet, the shoulder wings, the molten ring at his soles | L8 at full size, white-hot core; caption 殘日獄衣, mark 西, ZANJITSU GOKUI (f56); a roar of heat | P: 4.6 m |
| 72-124 | tracking side-on, the pair, 4.6 m, 1.2 m, lens 46 | he walks forward slowly (three dragging steps, `ya-e-advance`); the victim backs away, lost (a stagger loop, weapon-less hands up); molten footprints behind him | heat shimmer; footsteps and sizzle only | P: 6.4 m |
| 124-130 | on the victim, front, 2.6 m, 1.4 m, lens 50 | the instant: a white-hot streak; he is through the victim and stands behind him, back to back | negative 2, a hard cut; one sharp crack | the pass is a cut between two placements (CINE-PLACE), no body crossing |
| 130-160 | low, behind Yamamoto looking back past him at the victim, 3.6 m, 0.4 m, lens 40 | the flames rise from the victim's feet into a column; f134 the Konpaku shatters; he chars black and ash streams upward off him; he falls to his knees, then down | flame column (orange, 西's fire), `cine-shatter`, manga 10, ash rising; shake 0.4 | |
| 160-180 | wide side, 7 m, 1.6 m, lens 44 | Yamamoto never turns; the garb gutters out; the charred victim smokes on the floor | `vfx-burnout`, black smoke; caption exits | P: 9 m |

#### 15.3.3 南 火火十万億死大葬陣 DAISOJIN (192 f)

Idea: he plants the blade, says the words, turns his back and walks away; behind him the dead take the victim down.
Actors: `cine-place a v 5.0` (A: "several meters away"). The victim ends under the pile at his placed spot, down.

| Frames | Shot | Action | Effects / sound | Note |
|---|---|---|---|---|
| 0-12 | (held) | beat 0; the blade upright before his face (`ya-kaka` f16) | negative 2 | |
| 12-50 | close front, low: 15°, 2.2 m, 1.0 m, lens 50, roll 6 | the incantation: the vertical blade splits his face; one eye opens | silence 38, a low drone; caption 火火十万億死 / 大葬陣 (two columns), mark 南, DAISOJIN | P: the long caption must pass the caption-fit test |
| 50-56 | front, high: 0°, 4 m, 4.5 m up, looking 1.5 m ahead, lens 44 | the blade driven down (f50) | ember cracks run from the blade toward the victim (`stage-crack-add` along the line); ground-crack; shake 0.3 | |
| 56-96 | on the victim at ground level: 140°, 3.2 m, 0.2 m, lens 32 | hands break the floor round him (3, then 8 bodies, one every 5 f), take his ankles, knees, sword arm; he fights it | L1 bodies, `vfx-skeleton-dust`; bones | P: 4.2 m; the foreground hand kept left of centre |
| 96-140 | in front of Yamamoto, long lens: 0°, 4.5 m, 0.9 m, lens 70 | **he has turned his back on the victim and walks toward the camera**, the blade low, the eye closing; far behind him the pile climbs over the victim to 2.4 m, an arm last | L5 at cinematic scale, soft with distance; footsteps only | the shot the cinematic is for (A, ch. 509) |
| 140-146 | the same | f140 the Konpaku, unseen by him: the pile bursts | negative 2, back-rim on him, `cine-shatter`, manga 10; shake 0.35 | |
| 146-192 | wide, high, side: pair 8 m, 3.0 m, lens 44 | the pile falls to ash; the victim lies in the ring of cracks; he keeps walking, back turned | `vfx-ash-burst` x3, black smoke; caption exits f160 | P: 10 m |

#### 15.3.4 What today's API cannot do as written

| # | Beat | Gap | Proposed way |
|---|---|---|---|
| 1 | 東's void | no way to remove stage geometry | a flat black strip / wedge on the floor (Ichigo's `vfx-ic-split` is the precedent), shot from above so it reads as depth |
| 2 | 西's young Yamamoto | (gone: the user's storyboard has no young Yamamoto) | - |
| 3 | the dead as bodies (南; L1) | no helper draws an extra posed body for him | a small Yamamoto helper on the `ic-ghost` pattern (FK into preallocated joints, `draw-body` with `:skeleton`); cap 8 bodies, the far crowd as vector ink |
| 4 | 西's erased weapon | hiding the victim's weapon needs a restore that also runs when the cinematic is cut short (`cine-end` gives back only places and scale; §14 deviation 7 was this trap) | draw the ash over the weapon and leave the model alone; or the lead adds the restore to `cine-end` (a shared change) |
| 5 | 西's victim attack; 南's victim sunk | the victim's own first-attack clip is a kit lookup (fallback: a generic flinch-in); a body under y 0 may show through the plaza | look it up from the kit's `:commands`; do not sink him: the pile look covers him |
| 6 | the captions | 旭 殘 獄 衣 葬 陣 億 and others may be missing from the baked caption glyphs | an offline bake step (`tools/glyph-bake.py`) in K4 |

### 15.4 Decisions (AskUserQuestion, 2026-11-20; the user's answer in bold)

| # | Question | Answer | Rejected |
|---|---|---|---|
| D1 | How literal are the dead? | **「焦黑骷髏配上紅色高光」**: black charred skeletons, skulls visible, the highlights red (the user's own mix of a and b) | bone-white highlights (the manga's); crimson bones on red cracks (the anime's); abstract hands and ink |
| D2 | The young Yamamoto in 西's Kikon | **the user's own storyboard** (§15.3.2, quoted there): no young Yamamoto, no grab / throw; the slow walk, the pass-through, the rising flames | an 8 f silhouette; a young body; none |
| D3 | 東's erased line in play | **「黑色虛空帶」**: a black void strip, held 20 f, then filled by ash | the slit and a scorch line only; a scar for the round |
| D4 | Fire in the Bankai | **「只有西和北有火」**: orange flame only in 西 and 北; every other look charcoal + an ember line | ember-only everywhere; fire on every move |

Consequence of D1: the dead's red sits near Kenpachi's and Ichigo's blood hue; the red is kept to thin highlights on black (bone edges,
eye sockets, the cracks), never a fill, so a skeleton still reads as charcoal from the arena camera. The lead decides the rest from stills
(the wall's height, 南's stance offset, frame counts).

### 15.5 Later batches (outline)

- **Shikai**: looks first: NS1a's spiral, NS1b's "unknown fire" tell and column, NS1c's tornado (its own look: 北 no longer borrows it),
  the flame's size by heat paid (small to white-hot). Then the three stances (1 the hip draw, 2 the level point, 3 the hand on the planted
  pommel), own clips for NS3a / NS3b (today J2's and J1's), NS2b, AS1-AS3; J1's S14 tell re-keyed. Then three Kikon storyboards
  (the tornado closing in / ENNETSU JIGOKU / the turn away and the late split).
- **爆炎**: the bared body exists. A flame trail on J1 / J2 as a draw hook (no new clips), IKKOTSU exists, the tracking tornado's look,
  ENNETSU's pillar rows, the true NADEGIRI's long recovery, the scars' glow by heat. Open: whether it keeps the Shikai's stances and
  Kikon cinematics or gets its own.

## 16. As built (art batch K1: the Bankai's looks, 2026-11-20)

K1 of §15.1 (the user, 2026-11-19: 「先做這兩件事」; the plan §15.2.1, the decisions §15.4 D1-D4): the FK coverage first, then the eleven
looks L1-L11. Presentation only: the sim never reads any of it (proofs below). Code: a new `duel/lisp/yama-look.lisp` (loaded after
`yama-art.lisp`), the :skeleton body and a crawl clip in `yama-art.lisp`, the awakening's two burst kinds in `vfx.lisp`, a kit hook in
`feedback.lisp`. `yama.lisp` changed only in `:look` params, the bone wall's two look symbols, the hook wiring and debug commands.

### 16.1 Drawn reach against hit reach (the host FK test)

`tests/duel-rules/art.lisp` now reads `yama-art.lisp` too and prints every Bankai segment with a blade window: the zanka's tip by the
rig's FK at the hit frames (radial for an arc, ahead for a capsule) against the volume's far edge. Today's numbers (the placeholder
clips of §14):

| Move | Drawn tip (m) | Volume end (m) | Delta | Verdict |
|---|---|---|---|---|
| E-J1 | 1.52 | 1.52 | 0.00 | within ±0.15 |
| E-J2 | 1.59 | 1.59 | 0.00 | within ±0.15 |
| E-J3 | 1.71 | 1.71 | 0.00 | within ±0.15 |
| NS1a KYOKKO | 2.39 | 4.90 | -2.51 | one-sided: L7's lance carries it to 4.9 |
| NS1b the sunrise | 1.91 | 1.91 | 0.00 | within ±0.15 |
| NS1c KYOKUJITSUJIN | 1.86 | 6.40 | -4.54 | one-sided: L6's void line is the 6 m |
| AS1 the tip-touch | 1.86 | 1.60 | +0.26 | **off** (over): `ya-kyoku` x1.8; its own clip `ya-e-as1` is K2 |
| NS2a SHONETSU | 1.59 | 2.00 | -0.41 | one-sided: no swing, L8's burn round him (r 2.0) |
| NS2b the advance | 1.60 | 2.00 | -0.40 | one-sided: as NS2a |
| NS2c the counter-cut | 1.96 | 2.00 | -0.04 | within ±0.15 |
| AS2a the grab | 1.96 | 1.60 | +0.36 | **off** (over): `ya-w-counter` x0.5; its own clip `ya-e-grab` is K3 |
| AS2b the throw | 1.60 | 2.00 | -0.40 | one-sided: L8 |
| AS 北 | 2.25 | 2.40 | -0.15 | one-sided: L10's crescent reaches 2.4 |
| SA | 1.96 | 2.00 | -0.04 | within ±0.15 |
| the Kikon strikes (E-J1's clip) | 1.52 | 1.60 | -0.08 | within ±0.15 |

The test checks the J links and the swinging segments both ways within 0.15 m, the one-sided rows never over by more than 0.15 m. AS1 and
AS2a are expected failures (`known-off` in the test, printed `(known off: K2 / K3)`); the test fails if either stops being off, so the
clip batches must take them out of the list. The hazard segments (南 a / b / c, AS3 a / b / c, 北's NS) have no blade window: their cast
checks (the blade in the floor) belong to K3's clips. The `:skeleton` body is a look and stays out of the fighters' hurt radii there.

The Shikai and 爆炎 rows are printed too, not checked (their clips are the later batches, §15.5). Today: J1 1.39 / 1.40, J2 1.35 / 1.40, J3
1.78 / 1.40 (+0.38: TSUKABI strikes with the pommel, which the print does not model; 爆炎's J3 IKKOTSU is the fist), NS3a / NS3b and the
Kikon strikes 1.38-1.39 / 1.60, NS3c and AS3c NADEGIRI 1.87 / 2.40, AS1 2.04 / 1.60 (+0.44), AS2 1.66 / 2.00, AS3 1.35 / 1.80, AS3b
1.99 / 2.00, the SA TAIMATSU 1.45 / 2.40 (爆炎's 3.20; its fire cone carries it).

### 16.2 The looks

| # | Look | Built as | Footprint (= the sim's) | Frames |
|---|---|---|---|---|
| L1 | the dead hands (NS3a, AS3a) | `yama-hands-look`: the crack star (an INK ring on the disc's edge, an ember hairline inside it, six ink cracks with ember cores); three of the dead (the :skeleton body) clawing up on `:sk-grab`, 0.3 m higher than the old clip's roots so skull and arms clear the plaza; dust as they break out, ash as they sink | disc r 1.2 (HAZARD-SIZE); the bodies at 0.7 r | through the delay (NS 17 f) the hairline pulses on twos (the tell); `:sk-grab` starts 8 f before the clench, so it closes on the hit; hot 6 f; sinking from 18, gone at 30 |
| L2 | the swarm (NS3b, AS3b) | `yama-swarm-look`: four of the dead prone and crawling abreast (`:sk-crawl`, a 0.6 s loop, on twos), an ASH strip dragged behind over the ground crossed | the wave's box, 2 m wide (the bodies at ±0.25 / ±0.75 w), their hands at its front | its whole life (6 / 8 m/s) |
| L3 | the bone wall | `yama-wall-look` (the :ya-wall hazard) and the rise in `yama-bk-moves`: four heaps of the dead (charcoal torsos, two ink bones each, a skull with red sockets, a red rib hairline) | 3.2 m across at 1.2 m ahead; heaps at ±0.45 / ±1.35 m, 0.5 m wide: three 0.4 m gaps, the middle one straight at the foe; 1.15 m (inner) and 1.4 m (outer) high | rises over NS3c's f6-17 (the draw hook), stands S..S+90, sinks and turns to ash over its last 10 f |
| L4 | the wall's fall | `yama-fall-look`: ten bones and skulls toppling from the crest (1.8 m nearer him, 1.3 m up) onto the disc in 4 f; an ASH ring opening to the disc's edge, an ember hairline on it while hot | disc r 1.6 at 3 m | lands on S18, hot 4 f, erodes by 30 |
| L5 | the pile (AS3c) | `yama-pile-look`: three heaps sliding in from three sides and climbing over him to 1.8 m (a skull on top), three of the dead clawing at the edge; bursts to ash from 16 f | disc r 1.4 at the victim (the ink ring on its edge, an ember hairline while hot) | f12 (spawn), closed by 8 f, hot 6 f, ash 16-24, gone at 30 |
| L6 | KYOKUJITSUJIN's erased line (NS1c), AS1's notch | `yama-bk-moves` codes 2 / 3: the white down-cut slit (the old `%st-slit`'s shape) for 4 f, a flat INK strip on the floor with an ember hairline on its sides and far end, ash falling in, then filling it | 0.2-6.0 m ahead, 0.8 m wide (the `:cap`); AS1: 0.2-1.6 m, 0.6 m wide | full length on S18 (S10), held 20 f, then filled by ash over 11 f (the move's own frames) |
| L7 | KYOKKO's lance (NS1a) | code 1: an ember lens with a white hairline core from 0.2 m to 4.6 m at 1.1 m high, an ink sun r 0.3 with an ember fill at its end | the `:cap 0.2 4.6 1.1 0.3`: the sun's edge is the volume's 4.9 m | S20-22, fading to 25 |
| L8 | SHONETSU's flare (NS2a, NS2b, AS2b) | `%ya-flare` (codes 4-6): 14 orange flame tongues (`+pal-flame+`) thrown out round him, shrunk near the lens (to 8 % within 1.5 m of the camera, so the behind camera keeps the fight); the molten ring; a white-hot ring on the pulse's first two frames; two shoulder wings of three flame ribbons, 0.9 m out each side | r 2.0 (the ring on the edge, no tongue past it) | NS2a's pulses f16 and f26, NS2b S14, AS2b S12, 10 f each |
| L9 | 西's armour | `yama-armored-fx` on the new kit hook `:armored-fx` (FEEDBACK-SYSTEM's `:armored` event, the core verdict `:absorb` that NS2b / NS2c's `:turn-armor` gives): `vfx-garb-block` facing the attacker and `vfx-scorch` on his sword hand | the contact point | the absorb frame |
| L10 | 北's band (NS), crescent (AS) | `yama-north-look`: one white band rising diagonally across the wave's whole width (0.2 m up at his left end to 2.0 m at his right, 0.64 m tall: the passing cut ↗), an orange flame rim above and below it, an INK band just behind; a scorched ASH strip from where it set out; code 8: three stacked crescents (ink, flame, white) from over his right shoulder to his low left | wave 4 m wide (the box); crescent: far edge 2.4 m ahead, 110° | NS from S24 over its 42 f; AS S10-12, fading to 15 |
| L11 | the awakening's bursts | `vfx-awaken-burst` `:bankai`: 24 FIRE scraps from 3-5 m flying in to the raised blade's tip (2.4 m up) in 0.5-0.8 s; `:bankai-burst`: 28 INK shards and 20 ASH puffs flung out in a ring, no flame | none (cinematic) | `yama-bankai-cine` f12 and f118 (the calls were there) |

Colour: every Bankai look is ink / charcoal, bone-ash white and one ember (or, for the dead, red) hairline; orange flame only in L8 and in
L10's rims (D4). L9's hexagon and scorch are the old ember / white stamps; L11's `:bankai` scraps are FIRE because they are the Shikai's
flames being taken into the blade (§15.2.1's L11 row), and `:bankai-burst` has none. The spot grade keeps red and the flame (hues within 25° of 10° and 48°), so the red highlights and 西's fire stay in
colour in a grey world. The dead (D1): the `:skeleton` body is now charcoal (`#2E2826`) and near-black (`#171315`) with red (`#D8141C`)
glows only as hairlines: the eye sockets, a crack over the brow and down the spine, the ribs' front edges, the upper arms' edges (the old
chest fill box and orange spine glow are gone).

How it draws without consing: the hazard looks and `yama-bk-moves` are `defun-fast` over the toon macros, pure functions of the hazard's
age / delay or the move frame (hitstop freezes the age, so nothing is a one-shot keyed on it, and no look writes the hazard). The dead are
`ya-dead`: one scratch pose and joint buffer (DRAW-MESH copies each part's matrix when it queues it), FK at the origin then turned and
moved in place (`%ya-place!`, checked against POSE-FK! with a yaw: 2.4e-7), the clip time a frame index into boxed-once floats, at most 8
bodies a frame (`yama-draw` resets the count before the hazards draw).

### 16.3 Deviations, each with its reason

1. L4: the plan's "the rampart's crest topples" is drawn as bones falling from the crest while the wall stays up: the sim keeps the wall
   standing 90 f after the fall (§14 deviation 4), and a wall that visibly fell but still stopped waves would lie.
2. L6 and L7 are drawn from his feet each frame, not from where he stood on S: neither move slides after S, and a look that kept state
   across frames would need a per-side store for no visible gain.
3. L8's low garb on 西's stance (tongues to the knee) is not built: stances are K2.
4. L9 needed a defender's hook: the turn-armour absorb emits `:armored`, not `:absorbed` (core-sim.lisp CORE-NOHIT!), and FEEDBACK-SYSTEM
   had no per-kit look for it. `:armored-fx` (kit.lisp docs) is off for every other kit (host-tested with §14's other hooks).
5. L2's crawlers are the posed :skeleton (`:sk-crawl`), not the plan's vector torsos: four bodies fit the cap of 8 with L1's three, and
   the same body as the hands keeps the dead one look.
6. L10 is a diagonal band, not the plan's full leaning sheet: the first still's sheet (2.6 m tall over the whole 4 m) hid the foe from the
   behind camera for the wave's whole flight; a band leaves the gaps under and over it, and is the canon's "wide diagonal white band".
7. L3 / L5's heaps are camera-facing ink discs (with ink bones, red sockets and rib hairlines), not posed bodies: twelve bodies a wall would
   break the cap of 8 and the 0 B rule's budget.
8. **For the user (D3):** the INK palette's white value-opposite edge (1.2 px, drawn by the toon shader round every INK shape) shows on
   L6's void strip just inside its ember hairline. Covering it with a wider ember strip did not hide it (the edge draws over it), and
   EMBER at a low heat draws a dark red fill, not black. So the strip carries a thin white rim the decision did not ask for. Keep it (a
   cut's ash edge), or take it off (a toon palette or shader change, shared)? The hairline itself now draws at heat 0.3, the ember's red
   body (at heat 1 its pale core showed as a second white line).
9. Of the unused old assets the plan lists, only the `:skeleton` body and `:sk-grab` are reused. `vfx-kyoku-slit`, `vfx-skeleton-dust`,
   `vfx-garb-flare` / `vfx-nishi` and `vfx-burnout` are one-shot stamps: called from a hazard look they would fire again on every drawn
   frame of a hitstop (the age stands still), and they box their float arguments; L6's slit and L1's dust are redrawn per frame instead
   (the slit is `%st-slit`'s shape). `vfx-garb-flare`'s ring also runs out past 2.0 m (the burn's edge). `draw-planted-weapon` belongs to
   the grab's clip (K3). `vfx-garb-block` / `vfx-scorch` are used for L9, which is an event (once).
10. Debug: 87430+i (a Bankai AS segment on its own), 87437 (an `:armored` event on P1) and 87448 (the consing line) were claimed inside
   his 87000-87999 for the stills and the probe (DUEL_GAMEPLAY "Debug commands").

### 16.4 Checks

| Check | Result |
|---|---|
| Presentation only: the native trials | `tests/trials/yamamoto-bankai.lisp` (C1-C18), `yamamoto-core.lisp`, `yamamoto-blaze.lisp`: tables identical to ecccfed4's (`combo-trial.py --log`, every line) |
| Presentation only: the browser | `tests/scripts/duel-yama-bankai.json`: every `duel hash`, `duel probe`, `duel yamamoto` and combat-log line identical to ecccfed4's dist (93 lines) |
| Shared files | `python3 tests/style-gates.py cvc dist/duel`: II / IK / KK identical to `tests/style-cvc-ref.txt` |
| Host tests | ALL PASS, 4082 checks (+15: the FK print's rows, the known-off guard, the new hook off for every other kit) |
| pkgcheck, debug ranges | as main (the one `DUEL::APP` line); `tests/debug-ranges-check.py` 0 errors |
| 0 B a frame | debug 87448: `yama look consing (10 draws, B): hands 0, tell 0, swarm 0, wall 0, fall 0, pile 0, north 0, lance 0, void 0, notch 0, flare 0, rise 0, crescent 0, dead x8 0` (10 unmeasured draws first: the engine's draw queue doubles at a new high-water mark once, the rest is the steady state). A first build read 16 B a draw on the swarm and 北's band: their trail's travel term (HAZARD-SPEED, then HAZARD-PX with F-HYPOT) consed, which a bisect build pinned to that one binding but not further; the trails now take the wave's speed as a constant (6 m/s, 20 m/s) |
| The looks gate | `tests/style-gates.py looks` against ecccfed4's dist, on the final build: 75 of 76 stills byte-identical; `cvc-hk/w3-0` differs, a frame of `yama-bankai-cine` (L11's scraps, and the cosmetic random stream they draw from, moving later particles). It plays Yamamoto because the gate's pinned pairings drifted when his kit came back (pre-existing: its `cvc-kh` / `cvc-hk` / `cvc-ik` fighters checks fail on BASE too: `YAMAMOTO vs ICHIGO`, `HISAGI vs YAMAMOTO`, `KENPACHI vs KENPACHI`); every other scene is byte-identical, and the two Yamamoto scenes' logs (hash and combat lines) are identical to BASE's |
| Build, smoke | `./build.sh duel` (then `git checkout -- vendor`), `run.mjs` smoke exit 0 |

Stills (untracked, `tests/scripts/duel-yama-k1.json` / `-phone.json`, generated by `tests/scripts/duel.py`): `tests/shots/duel-yama-k1-<look>-<behind|side>[-phone].png`,
each look at its frames from the match camera and the SIDE camera (2109), landscape and portrait (`--mobile --size 390x844`, the deck
on): `l1-hands-tell`, `l1-hands`, `l2-swarm`, `l3-wall-rise`, `l4-fall`, `l3-wall`, `l3-wall-crumble`, `l5-pile-close`, `l5-pile`,
`l6-void`, `l6-void-ash`, `l6-notch`, `l7-lance`, `l8-flare`, `l8-flare-2`, `l9-armour`, `l10-north`, `l10-crescent`, `l11-in`,
`l11-burst` (80 stills); contact sheets `duel-yama-k1-sheet.png` / `-sheet-phone.png`. Checked by eye: the wall's centre gap shows the
foe from the behind camera; each disc's ring sits on its hazard's radius; the flare's ring at 2.0 m leaves the foe at 3 m outside it.
Checked by numbers, needs the user's eyes: the colours, how the dead read at arena distance, the band's angle.

### 16.5 Open

- K2 / K3 (§15.1): the stances (with L8's low garb on 西's), the strike clips, AS1's and AS2a's reach (16.1), the hazard segments' cast
  checks.
- The Bankai's blade smear (the trail behind the zanka on every swing) draws in a REIATSU yellow, from before K1: it breaks D4's "no
  colour but ember" on every swing. It belongs to the strikes (K2).
- `vfx-hit :reiatsu`, the generic spark of every `:armored` event, still draws yellow under L9's fire hexagon (FEEDBACK-SYSTEM's, shared).
- The looks gate's pinned scenes no longer pin their pairings (16.4): a lead's fix in `tests/style-gates.py`.

## 17. As built (art batch K2: the three stances, NA, 東, 2026-11-20)

K2 of §15.1 (the user, 2026-11-19: 「先做這兩件事」; the spec §15.2.2, the decisions §15.4 D1-D4): the three pointer stances, the NA string,
東's three segments and AS1, and the Bankai's swing smear (§16.5). Presentation only (proofs in 17.6). Code: `yama-art.lisp` (the stance
poses and clips, E-J1, KYOKKO, NS1b's `ya-e-f2`, NS1c's `ya-kyoku`, the new `ya-e-as1`; named landing poses), `yama-look.lisp`
(`yama-stance-look`, the probe), `yama.lisp` (`:clip` / `:clip-s`, the `:stances` list, the kit's `:smear 3`, a debug docstring), a kit slot
`:smear` read by `draw.lisp` and a look 3 in `vfx.lisp` `vfx-smear`.

### 17.1 What was built

| Slot | Clip | As built |
|---|---|---|
| Stance 東 | `ya-st-higashi` (new; pointer 1's stance, `:ya-e-stance` stays the form's idle) | upright, the fist toward the foe at chest height (hand 1.25 m up, 0.69 m ahead), the blade level across, its tip 0.80 m out past his left side; the smoke thread from the tip (YAMA-DRAW, as before) |
| Stance 西 | `ya-st-nishi` (re-keyed, 4 keys) | feet apart and sunk, chest out, chin up, arms open low, the blade low at his right, point down (tip 0.13-0.21 m off the plaza); the keys sink the feet, swell the chest and open the arms. L8's low garb on it (`yama-stance-look`): ten orange tongues round his feet up to the knee (0.36-0.48 m), two small wings of two ribbons out from the shoulders, breathing every 2.4 s (deviation 3 of §16.3 closed) |
| Stance 南 | `ya-st-minami` (re-keyed) | the blade vertical, point down, the fist at 1.39 m (the grip above it at the chin), the elbow winged high (1.55 m); by FK the hand is 0.27 m right of his head (target 0.25); six faint ink cracks with ember cores at his feet (no ring) |
| E-J1 | `ya-e-q1` re-keyed at S14, `:clip-s 8` dropped | charge f0-9 (a key a frame: 2 5 10 17 27 40 56 76 % of the way to the drawn pose, the wrist's turn spread over f4-8), held f10-12 (1-2° tremble), released f13-14 into the kept hit pose; on through f15 (`:ya-e-q1-thru`, where an AS starts) and down to his low left by f17 (`:ya-e-q2-from` = J2's first frame) |
| E-J2 | `ya-e-q2` reused | its first frame and its S+A pose named (`:ya-e-q2-from`, `:ya-e-q2-top`): the same numbers, the clip unchanged |
| E-J3 | `ya-e-q3` reused, frame 0 re-keyed | frame 0 = J2's S+A pose (`:ya-e-q2-top`; deviation 1) |
| NS1a KYOKKO | `ya-e-kyokko` re-keyed at S20, `:clip-s 15` dropped | frame 0 = 東's stance (NS1 starts only from pointer 1, and an attack starts with no blend); charge f0-11 (a key a frame: 1 3 6 10 15 21 29 38 49 62 79 %), the hilt drawn back to the right hip, chambered and held f12-17 (the point at him, trembling), released f18-19 into the kept lunge; S+A = `:ya-e-kyokko-land` |
| NS1b | `ya-e-f2` re-keyed at S14, `:clip-s 19` dropped | frame 0 = KYOKKO's landing (`:ya-e-kyokko-land`); out of the lunge the point lowered onto the plaza ahead (f9), held f9-12 (the tell), the rise through level (the kept hit pose) to vertical; S+A = `:ya-e-f2-top` (deviation 4) |
| NS1c | `ya-kyoku` reused, frame 0 re-keyed | frame 0 = NS1b's S+A (`:ya-e-f2-top`, the blade straight up); the hit pose kept; from f20 only the tip on the plaza (y 0.00-0.04 m; it sank to -0.08 before): the bite pose's arm 86 → 90°, wrist -90 → -95° |
| AS1 | `ya-e-as1` (new; was `ya-kyoku` at x1.8) | frame 0 = J1's f15 (where the AS lands); no body swing: the wrist turns the point back over the centre and lifts it to his shoulder's height (f7, tip 1.50 m up), held a frame, then drops it onto the plaza on S10, the tip 1.55 m ahead (deviation 2) |
| Kikon strikes | copies of E-J1 | follow its re-key (no `:clip-s` either): 1.52 vs 1.60 |
| The smear | `vfx-smear` look 3 | the Bankai's trail behind every swing: look 2's charcoal ink wash (`+pal-black-smoke+`) and one EMBER hairline (half-width 0.018 m) down its middle; no REIATSU yellow. A new kit slot `:smear` (NIL = look 1, the REIATSU comet, as every form drew before); only Yamamoto's Bankai sets it (3), host-tested |

The links land where the scripts land them (the trials' and the stills' logs): an NS segment at the previous one's S+A (+8 f hitstop on a
hit), a J link at S+A (+4), an AS at the J's S+1 (+4). Each clip's frame 0 is now the pose its predecessor holds on that frame (attacks
start with blend 0, so a mismatch drew the arm flashing across for one frame):

| Link (lands on) | Tip jump on the link frame, before | After |
|---|---|---|
| J1 > J2 (J1 f17) | 1.41 m (J1 at x0.57 had not finished its follow-through) | 0 |
| J2 > J3 (J2 f10) | 2.12 m (J3 started from the stance) | 0 |
| J1 > AS1 (J1 f15) | 1.57 m (`ya-kyoku` from the stance) | 0 |
| 東 stance > NS1a (f0) | 0 (both `ya-e-stance`) | 0 (both `ya-st-higashi`) |
| NS1a > NS1b (NS1a f23) | 1.84 m | 0 |
| NS1b > NS1c (NS1b f18) | 2.66 m | 0 |

### 17.2 Drawn reach against hit reach (the host FK test)

| Move | Before (K1, §16.1): tip / volume end / delta | After | Verdict |
|---|---|---|---|
| E-J1 | 1.52 / 1.52 / 0.00 | 1.52 / 1.52 / 0.00 | within ±0.15 |
| E-J2 | 1.59 / 1.59 / 0.00 | 1.59 / 1.59 / 0.00 | within ±0.15 |
| E-J3 | 1.71 / 1.71 / 0.00 | 1.71 / 1.71 / 0.00 | within ±0.15 |
| NS1a KYOKKO | 2.39 / 4.90 / -2.51 | 2.39 / 4.90 / -2.51 | one-sided (L7's lance) |
| NS1b | 1.91 / 1.91 / 0.00 | 1.91 / 1.91 / 0.00 | within ±0.15 |
| NS1c KYOKUJITSUJIN | 1.86 / 6.40 / -4.54 | 1.86 / 6.40 / -4.54 | one-sided (L6's void line) |
| AS1 | 1.86 / 1.60 / **+0.26 (off)** | 1.55 / 1.60 / -0.05 | within ±0.15: out of the test's `known-off` list (AS2a stays for K3) |
| the Kikon strikes (E-J1's clip) | 1.52 / 1.60 / -0.08 | 1.52 / 1.60 / -0.08 | within ±0.15 |

### 17.3 緩急: the tip's speed per frame (m a frame, the clip's FK at the root; the move's slide not included)

| Move | Charge | Hold | Release → S | After S |
|---|---|---|---|---|
| E-J1 (S14), before (`ya-e-q1` S8 at x0.57) | f1 0.88 (the first frame the fastest), then 0.75 0.61 0.39 0.20 ... | none | f11 0.94, f12 0.33, f13 0.63, S 0.52 | f15 0.82 |
| E-J1 (S14), after | f1-9: 0.08 0.09 0.14 0.29 0.32 0.39 0.56 0.64 0.55 | f10-12: 0.07 0.04 0.06 | f13 **1.21**, S 1.00 | f15 0.88, f16 1.02, f17 0.55 (down to J2's first frame) |
| KYOKKO (S20), before (`ya-e-kyokko` S15 at x0.75) | f1 0.53, f2 0.33, f3 0.20 ... f8-16 ≤ 0.02 | (the clip's own hold, stretched) | f17 0.47, f18 0.44, f19 0.34, S 0.21 | f21 0.05 |
| KYOKKO (S20), after | f1-12: 0.01 0.02 0.03 0.03 0.06 0.07 0.12 0.13 0.21 0.25 0.36 0.41 | f13-17: 0.02 0.00 0.03 0.01 0.02 | f18 **1.07**, f19 0.21, S 0.20 (+0.08 a frame of slide) | f21 0.06 |

The release's peak now stands out: E-J1 1.21 against a charge of at most 0.64 (before, the first frame of the charge, 0.88, was as fast as
the cut); KYOKKO 1.07 against 0.41 (before 0.53 on f1 and 0.47 at the release). Under the house easing (`*key-ease*` 1, ease-out cubic) a
key several frames away moves most of its way on the first frame, so the charges are keyed a frame apart.

### 17.4 Deviations, each with its reason

1. **E-J3's frame 0 re-keyed** (the table says reuse): the J2 > J3 link lands on J2's S+A pose, the blade high at his right; J3's frame
   0 was the stance, a 2.12 m jump of the tip on the link frame. Only frame 0 changed (J2's S+A pose, named); the rest of the clip is kept.
2. **AS1's tip lands 1.55 m ahead, not "at his toes"**: the move's arc is 1.6 m and the FK test wants the tip within 0.15 m of it; at his
   toes it would be 0.6 m short. 1.55 m is also the far end of L6's notch (0.2-1.6 m), so the tap and the erased notch meet.
3. **西's garb breathes on the effect clock**, not on the stance clip's own phase: reading the clip's time in the look boxed a float (16-24 B
   a draw on the probe); both are 2.4 s loops, so the garb and the arms drift in and out of step.
4. **NS1b's tell lowers the point onto the plaza ahead** (the old clip's tell put it on the plaza behind him): from KYOKKO's landing, a swing
   of the blade back behind him passed the tip 0.35 m through the floor (FK). The rise through level to vertical (the table's line) is kept.
5. **KYOKKO's frame 0 is 東's stance** (not in the table): NS1 starts only from pointer 1's stance and attacks start with no blend.
6. **南's cracks have no ring**: K1's crack star (L1's ink ring with an ember hairline) read as a disc round his feet, i.e. as 南's hands' tell;
   six thin cracks read as "faint".
7. **The smear is a new kit slot `:smear`**, not the existing `:blade` (no code reads `kit-blade`); shared files `kit.lisp`, `draw.lisp`,
   `vfx.lisp`, default NIL = look 1 for every other form (host check: only Yamamoto's Bankai sets it; `--cvc` identical).
8. **The art viewer** (`tests/duel-view.lisp`) shows Yamamoto's Bankai clips (a clip-owner line) when built with `yama-art.lisp`; its strip
   script for K2 is `tests/scripts/duel-view-yama-k2.json` (`duel-view.py`'s `yama_k2`, counting DEFCLIP-MIRROR's clips).

### 17.5 Stills (untracked)

- In play: `tests/scripts/duel-yama-k2.json` / `-phone.json` (`tests/scripts/duel.py`'s `yama_k2_script`), the behind camera then the SIDE
  camera (2109), landscape and portrait (`--mobile --size 390x844`, the deck on): `tests/shots/duel-yama-k2-<still>-<behind|side>[-phone].png`
  for `stance-higashi`, `stance-nishi`, `stance-minami`, `ns1a-charge`, `ns1a-held`, `ns1a-release`, `ns1a-lance`, `ns1b-tell`, `ns1b-hit`,
  `ns1c-raised`, `ns1c-tip`, `j1-charge`, `j1-held`, `j1-hit`, `j1-smear`, `j2-first`, `j2-hit`, `j3-first`, `j3-hit`, `as1-first`,
  `as1-lift`, `as1-tap` (88 stills); the triptychs `duel-yama-k2-triptych-<behind|side>[-phone].png`.
- 8-frame strips, the art viewer (`dist/duelview` built with `yama-art.lisp`): `tests/shots/duel-view-yama-k2-<clip>-<side|front>.png` for
  `ya-e-q1`, `ya-e-q2`, `ya-e-q3`, `ya-e-kyokko`, `ya-e-f2`, `ya-kyoku`, `ya-e-as1` and the three stances (frames 0, S/3, 2S/3, S-2, S, S+A,
  mid-recovery, end).
- Contact sheets: `tests/shots/duel-yama-k2-sheet.png`, `duel-yama-k2-sheet-phone.png`.

Checked by eye: the three stances read apart from the match camera (the blade level across / low right in fire / upright beside the face);
the held tells show (J1's blade drawn back over the shoulder f9-12, KYOKKO's chamber f12-17, NS1b's point on the plaza f9-12); the smear is
black with a red hairline, no yellow. Checked by numbers, needs the user's eyes: how the stances and the garb read in play, the lean of 西.

### 17.6 Checks

| Check | Result |
|---|---|
| Presentation only: the native trials | `tests/trials/yamamoto-bankai.lisp` (513 trial lines), `yamamoto-core.lisp` (241), `yamamoto-blaze.lisp` (268): `combo-trial.py --log` identical to 70356041's, every line |
| Presentation only: the browser | `tests/scripts/duel-yama-bankai.json`: every `duel hash`, `duel probe`, `duel yamamoto` and combat-log line identical to a dist built at 70356041 (86 lines) |
| Shared files | `python3 tests/style-gates.py cvc dist/duel`: II / IK / KK identical to `tests/style-cvc-ref.txt` |
| Host tests | ALL PASS, 4084 checks (+2: the smear slot set on the Bankai, off for every other form); the FK test with AS1 out of `known-off` |
| pkgcheck, debug ranges | as main (the one `DUEL::APP` line); `tests/debug-ranges-check.py` 0 errors (no new debug number: the stills use 87000+k, 87301-87303, 87446, 2109) |
| 0 B a frame | debug 87448: `... crescent 0, garb 0, cracks 0, smear 0, dead x8 0` |
| Build, smoke | `./build.sh duel` (then `git checkout -- vendor`), `run.mjs` smoke exit 0 |
| The looks gate | not run (being re-pinned in a parallel batch) |

### 17.7 Open

- **For the user / the lead: J1 from a stance pops.** E-J1 starts from `ya-e-stance` with no blend (as every attack), so from 東's stance the
  tip jumps 1.83 m on its first frame (西 0.60 m, 南 0.66 m). One clip cannot start from three stances; a 2-3 f `:blend` on E-J1 (a move
  field outside K2's allowed edits) or a per-pointer `:clip-map` would. Ichigo's three stances have the same pop.
- K3: 西, 南, 北, the SA (AS2a's reach, the hazard segments' cast checks).
- `tests/scripts/duel-view-strips.json`'s indices run one short past `ic-k-xb` (`duel-view.py`'s clip list misses DEFCLIP-MIRROR), from
  before K2; the K2 strip script counts it.
- The smear's wash, like every INK shape, keeps the toon shader's 1.2 px white edge (K1's deviation 8, the same question).

## 18. As built (art batch K3: 西, 南, 北, the SA, 2026-11-20)

K3 of §15.1 (the user, 2026-11-19: 「先做這兩件事」; the spec §15.2.2, the decisions §15.4 D1-D4, D1 「焦黑骷髏配上紅色高光」, D4 「只有西和北有火」):
西's five segments, 南's six, 北's two and the SA, each on its own clip at its move's S, frame 0 keyed from where its link lands; the cast
checks; J1's stance pop (§17.7); the yellow armour spark (§16.5). Presentation only (proofs in 18.8). Code: `yama-art.lisp` (the clips and
their named landing poses), `yama-look.lisp` (`*ya-plants*` / `yama-planted`, 北's burn `%ya-blade-burn`, the probe), `yama.lisp` (`:clip`,
dropped `:clip-s`, two `:blend`s, the hook `:planted`, docstrings), and shared: `draw.lisp` `planted-spot`, `body.lisp`
`draw-planted-weapon` (a spot) and `draw-weapon` (no float box at emissive 0), `feedback.lisp` (the `:armored` spark), `kit.lisp` (hook docs).

### 18.1 What was built

| Slot | Clip | As built |
|---|---|---|
| NS2a SHONETSU | `ya-shonetsu` re-keyed (S16 A12; the clip had A 0) | frame 0 = 西's stance (`ya-st-nishi`: NS2 starts only from it, an attack has no blend); drawn in f0-12 (the point lifted off the plaza: it went 0.19 m in), held f13-15, the arms open on S; the breath in on f25 and the second chest pulse on f26 (the second hit and L8's second flare); S+A `:ya-shonetsu-a` (f28) |
| NS2b the advance | `ya-e-advance` (new, S14) | from SHONETSU's open arms two slow dragging steps (the right foot f0-7, the left dragged up f7-12; the move's 1.5 m slide carries him), chin up, the blade low at his right, the arms open low; the flare on S; nothing flinches (the armour f6-S); S+A `:ya-e-advance-a` (f17) |
| NS2c the counter-cut | `ya-e-gokui-cut` (new, S12) | still f0-7 (taking it, the chin up), the low carry at his right (f9), a rising forehand across to his high left with one step; the tip 1.94 m on S (volume 2.0) |
| AS2a the grab | `ya-e-grab` (new, S12) | from J2's S+1 (`:ya-e-q2-thru`) the blade comes down and is planted point-down at his right (f4, `:ya-e-plant-r`: grip 0.74 m up, 0.5 m right, 0.14 m ahead), the free hand drawn back (f6-10, held), shot to his collar on S (the hand 1.60 m out, 1.26 m up; a 0.88 m lunge); S+A `:ya-e-grab-a` (f15, holding him); unthrown, the hand is back on the hilt by f26 |
| AS2b the throw | `ya-e-throw` (new, S12) | the arm locked out holding him (the blade still planted), sinking f0-10 as the garb builds, the hand driven up and opened on S (1.85 m up; L8's flare throws him); back on the hilt by f30, drawn out low into 西's carry (f34) |
| NS3a the plant | `ya-kaka` re-keyed at S22 (was S20 at x0.91) | frame 0 = 南's stance; the blade brought before his face (a key a frame f1-5), held upright f6-18 (the words), trembling f16-18, lifted on f19, driven down f20-21 into the half kneel on S, the point 0.94 m ahead in the plaza; kneeling through the hands' 17 f delay (`:ya-kaka-a`, f39) |
| NS3b the swarm's "go" | `ya-e-minami-b` (new, S16) | from the kneel, bowed lower and the hilt turned in the hand (f0-14), then up straight on his knee, the head lifted, the hilt drawn back over the point on S (the point stays in the plaza, ±0.08 m: FK) |
| NS3c the wall | `ya-e-minami-c` (new, S18) | the grip taken, sunk (f6-11), the blade ripped up out of the plaza (f13, f16) to straight overhead on S (tip 2.84 m up); the recovery turns his chest (-46°) and head (-40°) away, no root yaw |
| AS3a the hands | `ya-e-as3a` (new, S10) | from J3's S+1 (`:ya-e-q3-thru`, the dropped knee) the point drawn back and raised (f3-8), a reverse stab into the plaza by the front foot on S (grip 0.74 m up, 0.2 m right, 0.79 m ahead; the point 0.62 m ahead), held (`:ya-e-as3a-a`, f13) |
| AS3b the swarm, by hand | `ya-e-as3b` (new, S10) | the hand leaves the planted hilt (f0-3), drawn back low, held (f7-8), swept low, palm forward on S (the hand 0.38 m up, 0.68 m ahead); back on the hilt by f24 |
| AS3c the pile | `ya-e-as3c` (new, S12) | the hand back on the hilt by f6 (the blade planted until then), he stands drawing it out low (f9-11) and looks away as the pile lands on S (head -50°, chest -26°) |
| 北 NS | `ya-e-tenchi` re-authored at S24 (was S6 at x0.25) | frame 0 = the idle (`:blend 4`: 北 starts from any pointer's stance); the gather f0-15 a key a frame, eased in to f8 (the blade swung out over the plaza) and on to the coil (`:ya-e-tenchi-coil`: trailing low behind, the tip 0.46 m up, 1.05 m behind); orange tongues off the blade f0-15, gone through the coil (`%ya-blade-burn`, D4); the coil held and trembling f16-20; the release f21-23; the passing cut on S (the tip 2.24 m ahead) |
| 北 AS | `ya-e-f1` revived, re-keyed at S10 (was S16; spare) | frame 0 = J1's f15 (`:ya-e-q1-thru`; after J2 / J3 it jumps, 18.3); up over the right shoulder (f3-6), held f7-8, the diagonal down to his low left with a 0.8 m lunge, the tip 2.32 m ahead on S (L10's crescent carries it to 2.4) |
| SA | `ya-w-counter` (its home now) | unchanged (it starts from any NS segment's S+A: six poses; no blend, 18.3) |
| E-J1 | `ya-e-q1` | `:blend 4` (§17.7's pop, 18.3) |
| The planted blade | hook `:planted` | `*ya-plants*` (yama-look.lisp): (move from to (ahead right)): the grab f4-25 and the throw f0-29 at (0.14 0.5), AS3b f0-23 and AS3c f0-5 at (0.79 0.2), the clips' grips by FK; `draw.lisp` `planted-spot` asks the kit's hook (else a `:planted` move's 0.7 m ahead, as before; no move sets it), hides the hand's weapon and stands it there (`draw-planted-weapon :ahead :right`) |
| The armour spark | `feedback.lisp` `:armored` | a defender's kit `:armored-fx` hook now draws instead of the generic `vfx-hit :reiatsu` (the yellow under L9's hexagon); the sounds stay. Only the Bankai has the hook (host check) |

### 18.2 Drawn reach against hit reach (the host FK test)

| Move | Before (K2, 7eb02f5b): tip / volume end / delta | After | Verdict |
|---|---|---|---|
| NS2a SHONETSU | 1.59 / 2.00 / -0.41 | 1.59 / 2.00 / -0.41 | one-sided (L8's burn r 2.0) |
| NS2b the advance | 1.60 / 2.00 / -0.40 | 1.26 / 2.00 / -0.74 | one-sided (L8): no swing, the blade carried low |
| NS2c the counter-cut | 1.96 / 2.00 / -0.04 (`ya-w-counter` x0.5) | 1.94 / 2.00 / -0.06 | within ±0.15 |
| AS2a the grab | 1.96 / 1.60 / **+0.36 (off)** (the blade of `ya-w-counter` x0.5) | **1.60 / 1.60 / 0.00 (the hand)** | within ±0.15: `known-off` is empty |
| AS2b the throw | 1.60 / 2.00 / -0.40 (the blade) | 0.84 / 2.00 / -1.16 (the hand: the blade stands planted) | one-sided (L8) |
| AS 北 | 2.25 / 2.40 / -0.15 (`ya-e-tenchi` x0.6) | 2.32 / 2.40 / -0.08 | one-sided (L10's crescent), now within 0.15 too |
| SA | 1.96 / 2.00 / -0.04 | 1.96 / 2.00 / -0.04 | within ±0.15 (the clip unchanged) |
| the rest (E-J1-3, 東, AS1, the Kikon strikes) | §17.2 | unchanged | |

The test (`tests/duel-rules/art.lisp`) now measures the grab and the throw by the free hand (`hand`: their blade stands in the plaza), keeps
the `known-off` guard with an empty list, and reads `*ya-plants*` from yama-look.lisp.

### 18.3 Link frames: the tip's jump on the frame the link lands (m)

Where the links land (the native trials' combat logs, ticks after the first move: C4 / C5 / C7 / C8 / C12, and the stills' logs agree): an
NS segment at its predecessor's S+A (+8 f a hitstop on a hit), an AS at the J's S+1 (+4), the SA at an NS segment's S+A. Each clip's frame
0 is the pose its predecessor draws on that frame (a named pose, or a sampled one: `:ya-e-q2-thru`, `:ya-e-q3-thru`), so it starts with no
flash (attacks start with blend 0).

| Link (lands on) | Before | After |
|---|---|---|
| 西 stance > NS2a (f0) | 0.61 | 0 |
| NS2a > NS2b (NS2a f28) | 0.76 | 0 |
| NS2b > NS2c (NS2b f17) | 1.39 | 0 |
| J2 > AS2a (J2 f8) | 2.30 | 0 |
| AS2a > AS2b (AS2a f15) | 1.43 | 0 |
| 南 stance > NS3a (f0) | 0.66 | 0 |
| NS3a > NS3b (NS3a f39) | 0.39 | 0 |
| NS3b > NS3c (NS3b f18) | 0.39 | 0 |
| J3 > AS3a (J3 f9) | 1.43 | 0 |
| AS3a > AS3b (AS3a f13) | 0.39 | 0 |
| AS3b > AS3c (AS3b f12) | 0.39 | 0 |
| J1 > AS 北 (J1 f15) | 2.75 | 0 |
| J2 / J3 > AS 北 (f8 / f9) | 2.41 / 2.99 | 1.87 / 0.76 (one clip, three predecessors: keyed from J1's, the trials' and the CPU's usual route) |
| 東 / 西 / 南 stance > NS 北 (f0) | 2.32 / 1.75 / 1.54 | 1.84 / 0.61 / 0.66 snapped; with its `:blend 4` the peak per-frame motion is 1.09 / 0.19 / 0.72 over f1-4 |
| NS gap > SA: 東 a f23 / 東 b f18 / 西 a f28 / 西 b f17 / 南 a f39 / 南 b f18 | 1.91 / 2.83 / 0.81 / 1.39 / 0.35 / 0.35 | 1.91 / 2.83 / 1.51 / 0.77 / 0.34 / 0.32 (the clip unchanged; 西's poses are new) |

**J1's stance pop (§17.7, item 8).** E-J1 starts from the pointer's stance (the idle in the Bankai is the pointer's stance) with no blend:
the tip jumped 1.84 / 0.61 / 0.66 m (東 / 西 / 南) on its first frame. Fixed with the move's `:blend 4` (PLAY-CLIP's crossfade, smoothstep
over 4 frames): the peak per-frame motion of the tip over f1-4 is now 0.80 / 0.41 / 0.55 m, against the charge's own 0.08-0.64 (§17.3). A
look: `mv-blend`'s one reader is PLAY-CLIP in START-MOVE (grep), and the trials are identical (18.8). The three Kikon strikes are
`defmove-copy`s of E-J1 and carry the blend too. `:clip-map` is per form, not per pointer, so it cannot do this. Ichigo is unchanged.

**Blends tried and dropped.** The same crossfade on the SA and on 北's AS made the peak larger, not smaller: both clips' own wind-up is fast
(the SA's tip moves 1.16 / 1.21 m on f1 / f2, 北 AS's 0.94 / 1.01), and fading toward a pose that is itself moving fast adds the two. With a
blend 3: the SA's peaks 1.28-2.14 m against the snaps above (0.32-2.83), 北 AS 1.40 / 0.74 / 1.05 against 0 / 1.87 / 0.76. So neither has
one; 北's NS keeps its blend (its first frames barely move: 0.03-0.11 m).

### 18.4 緩急: the tip's speed per frame (m a frame, the clip's FK at the root; the move's slide not included)

| Move | Charge | Hold | Release → S | After S |
|---|---|---|---|---|
| 北 NS (S24), before (`ya-e-tenchi` S6 at x0.25) | f1-12: 0.01-0.03 (no gather: the old clip's frame 0 held) | none | f13-16 0.12 0.31 0.44 0.50 (the old wind-up, mid-startup), f17-20 0.49-0.10, f21-23 0.67 0.67 0.64, S 0.59 | f25 0.09 |
| 北 NS (S24), after | f1-8: 0.03 0.07 0.11 0.13 0.16 0.18 0.19 0.21; f9-16: 0.14 0.14 0.13 0.13 0.13 0.12 0.13 0.13 | f17-20: 0.06 0.05 0.06 0.05 | f21 0.87, f22 0.75, f23 0.70, **S 2.27** | f25 0.90, f26 0.58 |
| NS3a (S22), before (`ya-kaka` S20 at x0.91) | f1-9: 0.10 0.27 0.35 0.32 0.26 0.27 0.31 0.30 0.22 (the first frames the fastest) | f10-17 ≤ 0.02 | f18-21 0.06 0.16 0.17 0.18, S 0.19 | f23 0.03 |
| NS3a (S22), after | f1-6 (to the face): 0.01 0.02 0.02 0.03 0.04 0.05 | f7-19: 0.00-0.01, the tremble f17-19 0.04 | f20 1.54, **f21 1.83**, S 0.43 | f23 0.02 |

The releases stand out: 北's cut 2.27 m on S against a gather of at most 0.21 (the burn rides the gather, the coil holds still), NS3a's
drive 1.83 against a rise of at most 0.05 and a still hold. Under the house easing a key several frames away moves most of its way on its
first frame, so both charges are keyed a frame apart (北's from a two-segment table: eased in to f8, even to f16).

### 18.5 Cast checks (host, `tests/duel-rules/art.lisp`)

The segments with no blade window: the tip or the body where the move says on its frame (x his right, y up, ahead; all pass).

| Move, frame | What | Test | Value |
|---|---|---|---|
| NS3a f22 | the tip | in the plaza (-0.2 ≤ y ≤ 0.05), 0.4-1.2 m ahead | 0.14 / -0.03 / 0.94 |
| NS3b f16 | the tip | still in the plaza, 0.4-1.2 m ahead | 0.14 / -0.03 / 0.90 |
| NS3c f18 | the tip | overhead (y ≥ 2.2) | 0.11 / 2.84 / 0.26 |
| AS3a f10 | the tip | in the plaza by the front foot, 0.4-1.2 m ahead | 0.20 / -0.15 / 0.62 |
| AS3b f10 | the hand | low (y ≤ 0.9), swept forward (≥ 0.5 m ahead) | 0.02 / 0.38 / 0.68 |
| AS3c f12 | the tip | drawn out low (y ≤ 0.6) | 1.04 / 0.16 / -0.33 |
| 北 NS f24 | the tip | past the wave's start (≥ 1.0 m ahead) | -0.22 / 1.19 / 2.24 |
| NS2a f16, f26 | the hands | the arms open (right x ≥ 0.6, left x ≤ -0.6) | 0.73 / -0.80; 0.75 |
| NS2b f14 | the right hand | the arms open low (x ≥ 0.5, y ≤ 1.2) | 0.70 / 0.99 |
| AS2b f12 | the right hand | opened upward (y ≥ 1.7) | 1.85 |
| every `*ya-plants*` window | the grip | on the planted spot (0.76 m up) when the hand leaves the hilt and when it is back, within 0.1 m | 0.03 m each (the grab f4 / f26, the throw f30, AS3b f0 / f24, AS3c f6) |

### 18.6 Deviations, each with its reason

1. **E-J1 and 北's NS carry a `:blend`** (a move field, not in the listed edits; item 8 of the brief allows "a short clip blend"): 4 frames
   each; their frame 0 cannot match three stances. Proof that it is a look: `mv-blend` has one reader (PLAY-CLIP), the trials identical.
   The SA and 北's AS have none (18.3: it drew larger jumps).
2. **The planted blade is a kit hook, not the move's `:planted` or a `:params` key**: the grab plants it beside him, and the throw, AS3b and
   AS3c leave it there for a window of frames, while the existing `:planted` path stood it 0.7 m ahead for the whole move (no move used
   it). `:params` is what the sim reads, so the spots and windows are Yamamoto's table (`*ya-plants*`) behind the kit hook `:planted`, read
   by `draw.lisp` `planted-spot`; `draw-planted-weapon` takes the spot. Off for every other kit (host check); no move sets `:planted`.
3. **The throw, AS3b and AS3c also plant the blade** (the table names the grab only): he has one arm, and each of them uses the hand
   (holding the collar, sweeping, the hand back to the hilt) while the blade stands where the segment before left it.
4. **`draw-weapon` no longer boxes a float at emissive 0** (shared `body.lisp`): the planted blade's draw measured 8 B (its one glow part's
   `(+ glow 0)`); the held weapon took the same 8 B a frame before. The same value is passed, so no pixel moves.
5. **NS3b's lever draws the hilt back over the point** (the spec: "levers it forward"): with the point pinned in the plaza the arm cannot
   reach the hilt forward from the kneel (FK); he kneels up straight, the head lifted, the hilt drawn over the point: the "go" reads from
   the camera as the bowed NS3a and the upright NS3b.
6. **NS2a's frame 0 is 西's stance, NS3a's 南's** (the table: reuse + a key / re-key), and NS2a's drawn-in pose lifts the point off the
   plaza (it went 0.19 m in): openers start from their pointer's stance with no blend, as K2's KYOKKO.
7. **The grab's hand is at 1.26 m, not the collar's ~1.4**: the hand at the move's 1.6 m needs a 0.88 m lunge already; higher, the arm
   would point up past him. 北 AS lunges 0.8 m (the tip 2.32 against 2.4). Neither move slides in the sim: the drawn body leads the sim's
   root, as KYOKKO's (0.6 m).
8. **北's gather drags the point 0.09 m into the plaza for two frames** (f4-6): from the idle (the point near the plaza) the blade swings out
   over it; a deeper arc would read as a swing, not a drag.
9. **北's burn is a new look** (`%ya-blade-burn` from `yama-draw`, not in §15.2.1's list): the clip table says the blade burns on the gather;
   five orange tongues rising off it f0-15, gone through the coil. D4's fire for 北.
10. **The SA's frame 0 matches none of its six predecessors** (any NS a / b's S+A); unchanged clip.
11. **The art viewer's strips draw the blade in his hand** in the planted frames (the viewer has no fighter); the stills in play show it
    planted.

### 18.7 Stills (untracked)

- In play: `tests/scripts/duel-yama-k3.json` / `-phone.json` (`tests/scripts/duel.py`'s `yama_k3_script`), the behind camera then the SIDE
  camera (2109), landscape and portrait (`--mobile --size 390x844`, the deck on): `tests/shots/duel-yama-k3-<still>-<behind|side>[-phone].png`
  for `ns2a-tell`, `ns2a-s`, `ns2a-pulse`, `ns2a-end`, `ns2b-tell`, `ns2b-s`, `ns2b-end`, `ns2c-tell`, `ns2c-s`, `ns2c-end`, `as2a-tell`,
  `as2a-cocked`, `as2a-s`, `as2a-end`, `as2b-tell`, `as2b-s`, `as2b-end`, `ns3a-up`, `ns3a-tell`, `ns3a-s`, `ns3a-end`, `ns3b-tell`, `ns3b-s`,
  `ns3b-end`, `ns3c-tell`, `ns3c-s`, `ns3c-end`, `as3a-tell`, `as3a-s`, `as3a-end`, `as3b-tell`, `as3b-s`, `as3b-end`, `as3c-tell`,
  `as3c-s`, `as3c-end`, `n4ns-gather`, `n4ns-tell`, `n4ns-coil`, `n4ns-s`, `n4ns-end`, `n4as-tell`, `n4as-s`, `n4as-end`, `sa-tell`, `sa-s`,
  `sa-end`, `armour` (192 stills).
- 8-frame strips, the art viewer (`dist/duelview` with `yama-art.lisp`): `tests/shots/duel-view-yama-k3-<clip>-<side|front>.png` for
  `ya-shonetsu`, `ya-e-advance`, `ya-e-gokui-cut`, `ya-e-grab`, `ya-e-throw`, `ya-kaka`, `ya-e-minami-b`, `ya-e-minami-c`, `ya-e-as3a`,
  `ya-e-as3b`, `ya-e-as3c`, `ya-e-tenchi`, `ya-e-f1` (`tests/scripts/duel-view-yama-k3.json`, `duel-view.py`'s `yama_k3`; the K2 strip
  script's indices moved with the new clips and were regenerated).
- Contact sheets: `tests/shots/duel-yama-k3-sheet.png`, `duel-yama-k3-sheet-phone.png` (each segment at its S, both cameras).

The links land on the frames the trials gave (the stills' logs: NS2b +44, NS2c +69, AS2a +33, AS2b +56, NS3b +47, NS3c +65, AS3a / b / c +48
/ +69 / +89, 北 AS +19, the SA +44). Observed, cause not traced: NS2a's and NS2b's S stills (S+1, inside the 8 f hitstop of their hit)
show the pose before S and no flare yet, which shows from the frame after the hitstop (`ns2b-end`); AS2a's S still shows the hit pose.
Checked by eye: orange only in 西 (NS2a's two flares,
the advance's and the throw's, 西's stance garb, the armour) and 北 (the burn on the gather, the band's rims); the dead are charcoal with red
hairlines; the armour shows the red hexagon with no yellow spark; the planted blade stands at his right in the grab and the throw and by
his front foot in AS3b; the six 南 segments read apart (upright blade before the face, the half kneel with the point in, kneeling up with
the head lifted, the blade overhead; the reverse stab, the low sweep, the back turned).

### 18.8 Checks (all on the final build)

| Check | Result |
|---|---|
| Presentation only: the native trials | `tests/trials/yamamoto-bankai.lisp` (514 lines of `combo-trial.py --log`), `yamamoto-core.lisp` (241), `yamamoto-blaze.lisp` (268): identical to 7eb02f5b's, every line |
| Presentation only: the browser | `tests/scripts/duel-yama-bankai.json`: every `duel hash`, `duel probe`, `duel yamamoto` and combat-log line identical to a dist built at 7eb02f5b (86 lines) |
| Shared files | `python3 tests/style-gates.py cvc dist/duel`: II / IK / KK identical to `tests/style-cvc-ref.txt` (33 / 28 / 27 lines) |
| The looks gate | `python3 tests/style-gates.py looks BASE dist/duel --jobs 4`, BASE a dist built at 7eb02f5b: PASS, 83 of 83 stills byte-identical (noise floor 0), every scenario's fighters and sim lines as BASE's. It does not exercise K3: in the YK match (seed 28) Yamamoto never awakens (his log: Shikai moves only, no AWAKEN / ZANKA), and no pinned scene shows his Bankai; the K3 stills (18.7) are the review of the changed looks |
| Host tests | ALL PASS, 4105 checks (+21: the FK rows by the hand, the cast checks, the planted windows' grips, the two hooks and `:planted` off for every other kit, the blend list) |
| pkgcheck, debug ranges | identical to 7eb02f5b's output (the one `DUEL::APP` line); `tests/debug-ranges-check.py` 0 errors (no new debug number: the stills use 87000+k, 87301-87303, 87437, 87444-87446, 2109) |
| 0 B a frame | debug 87448: `... smear 0, planted 0, burn 0, plant-spot 0, dead x8 0` (planted read 8 B a draw before deviation 4) |
| Build, smoke | `./build.sh duel` (then `git checkout -- vendor`), `run.mjs` smoke exit 0 |

### 18.9 Open

- **For the user's eyes** (checked by numbers, the stills by eye only): how 西's advance and counter-cut read in play, whether the grab
  (the blade left at his right, the hand to the collar) reads as 「take the hit, then grab」, how far apart the six 南 segments read from the
  match camera (the bowed plant / the upright "go" / the rip overhead; the plant / the sweep / the back turned), 北's burn and gather.
- The SA's frame 0 and 北 AS after J2 / J3 still jump (18.3): one clip cannot start from six (three) poses, and a crossfade made it worse;
  a per-predecessor clip would need a mechanism that does not exist (`:clip-map` is per form).
- The grab's hand stops at 1.26 m, below the collar (deviation 7).
- K4 (§15.1): the three Kikon cinematics (`ya-kaka` keeps its name and its held upright pose, which §15.3.3's beat 0 names at f16).
- **For the lead:** on a hit, 西's flares (L8, keyed on the move frame by YAMA-BK-MOVES since K1) seem to show only after the 8 f hitstop
  (18.7's observation); if so, every move-frame look lags its hit by the hitstop in play. Not traced here.
- Closed here: §16.5's yellow spark and AS2a's reach, §17.7's J1 pop and K3.
- From before: the toon shader's 1.2 px white edge on INK shapes (K1 deviation 8, §17.7); `duel-view-strips.json`'s off-by-one (§17.7).

## 19. As built (art batch K4: the 東 / 西 / 南 Kikon cinematics, 2026-11-20)

K4 of §15.1 (the user, 2026-11-19: 「先做這兩件事」; the storyboards §15.3, the user's 西 §15.3.2 verbatim: 「西 殘日獄衣：對手先出手，武器碰到火衣就從
刀尖化成灰。山本燃起灼熱的火衣並緩步走向不知所措的對手。最終瞬間穿過對手，使其被升騰的高溫烈焰燒成灰燼。」; the decisions §15.4, D1 「焦黑骷髏配上紅色
高光」, D3 「黑色虛空帶」, D4 「只有西和北有火」). Three `defcine`s in `duel/lisp/yama-cine.lisp`: `yama-higashi-cine` (168 f, hold 96),
`yama-nishi-cine` (180 f, hold 140), `yama-minami-cine` (192 f, hold 120), at the storyboards' lengths and CINE-PLACE distances (2.2 / 1.4 /
5.0 m). Each cinematic's AT events cut, play clips and stamp one-shots (step mode); its one DURING calls one look (`yama-higashi-look`,
`yama-nishi-look`, `yama-minami-look`), a DEFUN-FAST of the cinematic frame and the actors' places (draw mode, 0 B, `rnd01` only). None
uses 天地灰尽's black card. 北 keeps `yama-tenchi-cine` (its moves' `:cine`). The wiring (the Bankai's `:core :kikon-cines`) is its own
commit (the last of the batch), because it moves sim ticks (19.2).

### 19.1 The beat tables as built (against §15.3)

東 旭日刃 KYOKUJITSUJIN (168 f; `cine-place a v 2.2`):

| Frames | Shot as built | Action as built | Effects / sound | Against §15.3.1 |
|---|---|---|---|---|
| 0-12 | held from play | `hold-both` 12; he holds `ya-kyoku` at f15 (speed 0), the victim `:sh-kikon-victim` | negative 2, `cine-grade :spot`, whoosh | as written |
| 12-44 | `shot-on a -45 2.6 0.6 :look 1.5 :off 0.8`, lens 44 roll -6 | the blade high; the ember edge and the smoke thread (YAMA-DRAW's, the blade in hand) the only colour | silence 32; caption 旭日刃, mark 東, KYOKUJITSUJIN, ZANKA NO TACHI, hanko | angle -45 / 2.6 m for 30 / 3.0: at 30 the victim (2.2 m ahead) and his weapon stood in front of the lens (deviation 1) |
| 44-62 | `shot-pair a v 1 5.0 1.0` (portrait 7.0), lens 50 | `cine-slow 0.35`; `ya-kyoku` from f15: the diagonal comes down, only the tip on the plaza at f58 (its f20, held there) | whoosh; f58 a dry tick (`:hs-tip`), a pinch of ash at the tip | as written |
| 62-84 | `cine-cam` at the tip on the ground: 1.6 m back / aside, 0.15 m up, at the tip 0.35 m up, lens 70 | nothing; the smoke thread rises | silence 22 | as written |
| 84-100 | `shot-on a 180 6.5 7.0 :look 0 :ahead 4`, lens 40 | the void opens from the tip (1.86 m ahead: NS1c's tip by FK): an INK wedge 0.8 m wide at the tip to 5 m at 12 m, in 10 f (f84-94), through the victim's spot | ember hairline (heat 0.3) on its sides and near end; ash falling in to the end; f88 the boom (ground-crack, explode 0.4), shake 0.5 | as written (L6 at cinematic scale, §15.3.4 flag 1) |
| 100-130 | `shot-on v 150 4.0 1.0` (portrait 5.6), lens 50 | half on the black; f104 the Konpaku (`cine-shatter`, the Kikon's count), `:sh-crumple` on the lip | negative 2, f106 manga 10, splash; konpaku-shatter, shake 0.3 | portrait 5.6 m: past the close-up line, so he is in it too |
| 130-168 | `shot-on a 25 7.0 0.4 :look 1.0`, lens 40 | he blends to the Bankai idle (`ya-e-stance`, 14 f): the point lifted, the blade hanging | caption exits; ash still falling into the void | 25 deg off the line: the crumpled victim hid him at 0 (deviation 1) |

西 殘日獄衣 ZANJITSU GOKUI (180 f; `cine-place a v 1.4`; the user's storyboard):

| Frames | Shot as built | Action as built | Effects / sound | Against §15.3.2 |
|---|---|---|---|---|
| 0-10 | held | `hold-both` 10; he in 西's stance (`ya-st-nishi`: K2's low garb draws with it) | negative 2, `:spot` | as written |
| 10-40 | `shot-on v 145 2.2 1.5 :look 1.3` (portrait 3.0), lens 60 | `cine-slow 0.3`; the victim's own J (his kit's `:q` move: clip, clip speed, started at S - 9 so its hit pose lands on f40, §15.3.4 flag 5; a generic `:sh-clash` if his kit has none); he does not move | the low garb at his feet; sizzle | 145 deg for 160: at 160 he stood hidden behind the victim |
| 40-52 | `shot-on a 70 1.8 1.35 :look 1.25 :ahead 0.4`, lens 80 | contact f40: `vfx-garb-block` on his chest toward the victim, `vfx-scorch` at the victim's hand; the weapon turns to ash from the tip toward the hilt (nine ash clumps over the blade, an ember front, flakes shed), `cine-slow 0.5`; f44 `:sh-flinch`; f52 the rest falls as shards and the weapon is hidden | silence 12 | side-on at 70 deg, 1.8 m, aimed 0.4 m ahead of him (the contact) for 20 deg 1.6 m: at 20 the victim's arm filled the lens; the hiding: deviation 2 |
| 52-72 | `shot-on a 40 3.4 0.5 :look 1.1` (portrait 4.6), lens 40 | the garb ignites (built over 4 f): 10 orange tongues from his feet to ~1.3 m leaning out, two shoulder wings of three flame ribbons ~1.2 m out, the molten ring at his soles with a white-hot core; `ya-e-advance` f0 held (the arms open) | f56 caption 残日獄衣, mark 西, ZANJITSU GOKUI, hanko; explode 0.5, the rising roar (`:awaken-rise` 0.7), shake 0.15 | 40 deg for 10: at 10 the victim's back filled the frame; caption 残 not 殘 (deviation 3) |
| 72-124 | `shot-pair a v 1 4.6 1.2` each step (portrait 6.4), lens 46 | he walks forward 0.029 m a frame (`ya-e-advance` re-started f72, f89, f106: three dragging steps), the victim backs away 0.026 m a frame staggering (`:sh-stagger` x0.5 at f72, f98), weaponless; molten footprints every 9 f behind him | steps f80 f97 f114 | as written (1.5 m walked, 1.35 m backed) |
| 124-130 | `shot-on v 0 2.6 1.4 :look 1.3`, lens 50 | the instant: a hard cut, he stands 2 m beyond the victim, the two back to back (both turned away); a white-hot streak (flame and white) from his old side through the victim to him, fading over 10 f | negative 2, cut-heavy 1.2 | as written: a cut between two placements, no body crossing |
| 130-160 | `cine-cam` low, in front of and off to his side (1.5 m ahead, 3.5 m aside, 0.4 m up) aimed past him 1.2 m toward the victim, lens 40 | the column rises off the victim (10 thin orange tongues at 0.55 m to 3 m, an orange ring); f134 the Konpaku, `silhouette-black` on him (charred: CINE-END undoes it), `:sh-crumple`; ash streams up off him; f150 `:sh-down` | f130 explode 0.7, sizzle; f134 negative 2, `cine-shatter`, f136 manga 10, konpaku-shatter, shake 0.4; f150 the caption exits | off to his side, not straight behind (deviation 1): his garb and the column read apart; the caption out at f150 for f160 (deviation 12) |
| 160-180 | `shot-pair a v 1 7.0 1.6` (portrait 9.0), lens 44 | he never turns; the garb gutters (from f156, gone by f168); the charred victim smokes on the floor | `vfx-burnout` (garb t), black smoke from f150 | as written |

南 火火十万億死大葬陣 DAISOJIN (192 f; `cine-place a v 5.0`):

| Frames | Shot as built | Action as built | Effects / sound | Against §15.3.3 |
|---|---|---|---|---|
| 0-12 | held | `hold-both` 12; the blade upright before his face (`ya-kaka` f16, held) | negative 2, `:spot` | as written |
| 12-50 | `shot-on a 15 2.2 1.0 :look 1.45 :off 0.6`, lens 50 roll 6 | the incantation, the vertical blade before his face | silence 38, a low drone (`:awaken-rise` 0.5); caption 火火十万億死 / 大葬陣 (two columns), mark 南, DAISOJIN, hanko | as written; the portrait stills show both columns inside the frame |
| 50-56 | `shot-on a 0 4.0 4.5 :look 0 :ahead 1.5`, lens 44 | `ya-kaka` from f19 at f48: driven into the plaza on f51 (its S22) | ember cracks: a crack line from the blade to the victim run out in 6 f (the look) and three stage cracks along it (`stage-crack-add`, the round's marks); f51 ground-crack, shake 0.3 | as written |
| 56-96 | `shot-on v 140 3.6 0.3 :look 0.6` (portrait 4.6), lens 50 | `:sh-bound` (he fights it); L1 at his feet (YAMA-HANDS-LOOK on a stand-in hazard: the crack star and three of the dead), then one more of the dead every 5 f (f61-81) at his knees and sword arm: 8 bodies (YA-DEAD, cap 8); he kneels from f60 (`ya-kaka` f30 held) | bones f56 f61 f71 f81; dust as they break out | lens 50 for 32: at 32 his back filled the frame and hid the dead (deviation 1) |
| 96-140 | `shot-on a 20 9.0 1.1 :look 1.2`, lens 30 | **he has turned his back** (yaw + 180) and walks toward the camera (`:sh-walk-f` x0.55, 0.02 m a frame); far behind him L5 (YAMA-PILE-LOOK on a stand-in hazard) closes over the victim by f110 and holds; an arm claws out of its crest f126-140 | steps f96 f120, bones f130 | a long lens is a narrow field here: 30 deg at 9 m for "lens 70" at 4.5 m, 20 deg off his line so the pile shows beside him (deviation 4) |
| 140-146 | the same | f140 the Konpaku, unseen by him: the pile bursts (L5 from its age 16) | negative 2, `back-rim 6`, `cine-shatter`, f142 manga 10, konpaku-shatter, shake 0.35; the caption exits | the caption out at f140 for f160 (deviation 12) |
| 146-192 | `shot-pair a v 1 9.5 3.0` (portrait 13.0, 4.0 up), lens 44 | the pile falls to ash; the victim down (`:sh-down`) in the ring of cracks; he keeps walking | `vfx-ash-burst` x3 (f146) | 9.5 m for 8: at 8 he walked out of the frame's left edge |

### 19.2 Is a Kikon cinematic's length sim timing? Yes (only in ticks)

| Question | Finding (code) |
|---|---|
| Does the cinematic run on sim steps? | yes: `sim-step` (main.lisp) runs `(incf *match-tick*)` on every step, and on a cinematic's steps CINE-STEP instead of the sim systems (fighters, hazards, hits, gauges, match timer frozen) |
| The Kikon's damage frame | not moved: SETTLE-SOULS (round.lisp) settles the Konpaku before START-CINE |
| The round flow | moved by the length: RESET-ROUND (or MATCH-OVER on a K.O.) is the cinematic's AFTER, so it runs LEN ticks after the Kikon |
| What reads `*match-tick*` after | the 600-tick `duel hash` line (its `t=`, and which state it samples), the combat log's tick stamps, RESULTS' ticks / secs, and the CPU: the MCTS seed (`mc-seed` from `*match-tick*`, cpu-mcts.lisp), the online fuzzy Q learner's explore roll (`fq-u01`), the core CPU's finish timers and the style CPUs' tick stamps. So a CPU match with a Bankai Kikon plays differently after it |
| Which cinematic, at the same length | nothing in the sim but the actors' places during it (a 600-tick hash line inside a cinematic samples the CINE-PLACE gap); both are given back at CINE-END |
| What the gates see | nothing: the native trials skip cinematics (`tools/simgate/trial.lisp` `*skip-cines* t`), `--cvc` plays no Yamamoto, the looks gate's YK match never awakens; only a browser run (or a seeded match) with a Bankai Kikon sees it |

The lengths, against the generic cinematic the three replace (`soul-break-cine`, cinema.lisp):

| Pointer | Before: `soul-break-cine` `:len` / `:hold` | After (storyboard) `:len` / `:hold` | Ticks added per Kikon |
|---|---|---|---|
| 東 | 96 / 44 | 168 / 96 | +72 |
| 西 | 96 / 44 | 180 / 140 | +84 |
| 南 | 96 / 44 | 192 / 120 | +96 |

They are built at the storyboards' lengths (fitting 168-192 f of storyboard into 96 f would rewrite the user's own 西 storyboard, a decision
of its own) and the wiring is a separate commit, so the lead can merge the cinematics without moving any tick. The precedent: DUEL_LILLE §23
deviation 5 ("the cinematics' length is sim time") and DUEL_DESIGN "Cinematic lengths" ("the sim is frozen during a cinematic, so only match
ticks and time shift"); every other kit's per-pointer Kikon cinematics already run 150-206 f against the generic 96. The wiring also makes
the Bankai's Soul Break under 東 / 西 / 南 play these (CORE-SOUL-BREAK-CINE reads the same `:kikon-cines`).

The browser proof (`tests/scripts/duel-yama-k4-kikon.json`: each pointer's route held into its Kikon in a fresh match, then a K.O. Kikon from 2
Konpaku): its 147 hash / probe / combat lines against the same script on a dist built at
3173bf43 (the BASE):

| Build | Lines that differ from BASE |
|---|---|
| the cinematics commit (not wired) | none (147 of 147 identical) |
| the wiring commit | the four `cine <name>` lines (YAMA-HIGASHI- / -NISHI- / -MINAMI- / -NISHI-CINE for SOUL-BREAK-CINE); one probe line that the script set 3.0 s after the 南 Kikon (t 405): BASE's reset was done (both IDLE), the new run is still in the 192 f cinematic (both CINE, its place); the K.O. scene: KO-CINE starts at tick 392 for 308, RESULTS at ticks 542 for 458 (secs 9.0 for 7.6), the RESULTS probe and hash lines at t=542 for t=458 (their state equal): +84, 西's added ticks. Every other line, the three t=600 hash lines after the resets among them, identical |

So the cinematics move no rule, damage or state; only when the reset (or the K.O.) happens, by the length added.

**Merged wired (the lead, 2026-11-20).** The storyboards' lengths stay: they are the user's storyboards (西 is theirs word for word), every other kit's per-pointer Kikon cinematic already runs longer than the generic 96 f, the damage frame does not move, and no gate reads the shift (the trials skip cinematics, `--cvc` plays no Yamamoto, the looks gate's YK match never awakens). The cost is +72 / +84 / +96 ticks before the reset after a Bankai Kikon under 東 / 西 / 南; reverting is one line (`:kikon-cines` back to `soul-break-cine`).

### 19.3 Deviations, each with its reason

1. **Camera angles and distances moved where an actor blocked the lens or left the frame** (19.1's last column): the storyboards placed the
   camera without the other actor 1.4-5 m away on the line. 東's caption shot -45 deg 2.6 m (for 30 deg 3.0 m), its last shot 25 deg off the
   line; 西's over-the-shoulder 145 deg (for 160), the contact side-on (70 deg 1.8 m aimed at the contact, for 20 deg 1.6 m), the ignition 40
   deg (for 10), the column shot off to his side; 南's ground shot lens 50 (for 32), the wide 9.5 m (for 8). The portrait distances are the
   storyboards' "P:" notes, plus 東's 100-130 (5.6 m, past the close-up line).
2. **西 hides the victim's weapon at f52**, after the ash has covered it (§15.3.4 flag 4 said "draw the ash over the weapon and leave the model
   alone"): the weaponless hands of the walk (§15.3.2's 72-124) need it gone, and CINE-END already calls REFRESH-LOOK on both actors however
   the cinematic ends (played, skipped or aborted: END-CINE always passes it), which gives the kit's weapon back; `yama-bankai-cine` relies on
   the same (it swaps his own weapon). No shared change.
3. **The caption is 残日獄衣, not 殘日獄衣**: 残 was baked already (残火の太刀) and is the Japanese form of the canon name; 獄 was baked
   (`tools/glyph-bake.py`'s CHARS + 獄, Yuji Syuku from google/fonts, fontTools 4.68 / skia-pathops: the re-bake of the old CHARS was
   byte-identical first, so `duel/lisp/glyphs.lisp` gains one line, the 獄 entry).
4. **南's long lens is 30 deg at 9 m** for "lens 70" at 4.5 m: the engine's LENS is a vertical field of view, so 70 is wide; the shot's "long
   lens" (the pile big behind him) needs a narrow one, and 20 deg off his line so he does not hide the victim.
5. **The dead at cinematic scale are K1's looks on stand-in hazards** (§15.3.4 flag 3): YAMA-HANDS-LOOK and YAMA-PILE-LOOK read a plain
   `hazard` struct (`*ya-chz*`, `*ya-cpz*`, never an entity); their places are set once at 南's f0 (set in the look, the probe read 8 B a draw on those rows), their
   ages (fixnums) each frame. The pile reaches 1.8 m (L5's own height), not §15.3.3's 2.4: the victim, bound and kneeling, is under it.
6. **西's garb is a new look** (`%ya-garb`), not L8's flare: L8 is a pulse thrown out to the 2.0 m burn; the storyboard's garb hugs him
   (tongues from the feet, the wings, the ring at the soles). The first stills' 12 wide tongues to 1.7 m hid his body: 10 thin ones to ~1.3 m,
   leaning out.
7. **The victim's places / facings**: 西 moves both in step mode (the walk) and turns both at the cut; 南 turns him (his back) and walks him;
   CINE-SAVE gives the places back at CINE-END, RESET-ROUND or the K.O. cinematic face them again (the K.O. scene of the proof script).
8. **The three cinematics are in `*hurt-cines*`** (draw.lisp): the victim's hurt face, as under the generic cinematic they replace.
9. **YAMA-DRAW keeps the frame's effect seconds** (`*ya-rdt*`, yama-art.lisp) for the looks' particle rates: DURING's `(cine-dt)` would box a
   float a frame into a DEFUN-FAST argument. 西's ash reads the victim's weapon through JOINT-POINT! with its length and blade base kept at f40
   (`*ya-cw*`): BODY-WEAPON-TIP / -BASE read 48 B a draw on the probe.
10. **The probe (87448) rewinds the fx batches too** (it rewound only the draw count): with the 8 new rows its 560 draws overflowed the toon
    batch (`fx-dropped` 6486), so the last rows were measured on the full batch's skip path; each row now ends with "(dropped)" if it still
    overflows (none does).
12. **西's and 南's captions slice out earlier** (f150 for f160, f140 for f160): in their wide last shots he stands or walks in the caption's
    third of the frame, under it (the first stills, both aspects).
13. Debug: 87450-87452 and 87601-87699 claimed inside his 87000-87999 (DUEL_GAMEPLAY "Debug commands"): the stills only; the proof script uses
    commands that exist at 3173bf43, so it runs on a dist built there.

### 19.4 Stills (untracked)

`tests/scripts/duel-yama-k4.json` / `-phone.json` (`tests/scripts/duel.py`'s `yama_k4_script`): each cinematic from 87450+i after 2.5 s idle in
the Bankai, held at one frame per beat (87600+k), landscape (the 9 % letterbox) and portrait (`--mobile --size 390x844`, the deck on):
`tests/shots/duel-yama-k4-higashi-b0-held` … `b6-hang`, `duel-yama-k4-nishi-b0-held` … `b7-wide`, `duel-yama-k4-minami-b0-held` …
`b6-wide` (`-phone`; 44 stills); contact sheets `tests/shots/duel-yama-k4-<higashi|nishi|minami>-sheet.png` and `-sheet-phone.png`.
Checked by eye, both aspects: every actor in frame (the held victim, the victim's back, the pair) but in 東's caption shot and 南's
incantation (Yamamoto alone, as written) and 南's high plant shot (the victim 5 m out, behind the camera, as written); orange flame only in 西
(the garb, the footprints, the streak, the column; 東 and 南 are ink, ash white and the ember / red hairlines; the victim's own yellow aura is
his kit's); the charred victim stays visible inside the column and under the rising ash, then down and smoking; no caption leaves the screen
(no `brush: caption … off the screen` line in either run's log). Two held stills (西's b7 and 南's b6, portrait) show the caption half sliced
out over Yamamoto at the frame they hold, which is what play shows there (a held still is the frame as played): in the wide last shots of 西
and 南 he stood or walked under the caption, so both captions now slice out before those shots (deviation 12); the stills are of that build.

### 19.5 Checks (all on the final build)

| Check | Result |
|---|---|
| Native trials | `tests/trials/yamamoto-bankai.lisp` (514 lines of `combo-trial.py --log`), `yamamoto-core.lisp` (241), `yamamoto-blaze.lisp` (268) against 3173bf43's: the cinematics commit identical, every line; the wiring commit identical but one line, C18b's `cine SOUL-BREAK-CINE` now `cine YAMA-NISHI-CINE` (its AS2 Kikon under 西; the trials skip cinematics, so no tick moves) |
| The Kikons in the browser | `tests/scripts/duel-yama-k4-kikon.json` against a 3173bf43 dist (19.2): not wired identical (147 lines); wired, the diff is the cinematics' names and the ticks their lengths add, nothing else |
| `duel-yama-bankai.json` | hash / probe / `duel yamamoto` / combat lines identical to the 3173bf43 dist's (89 lines; its Kikon is 北's, `yama-tenchi-cine`, unchanged) |
| Shared files | `python3 tests/style-gates.py cvc dist/duel`: II / IK / KK identical to `tests/style-cvc-ref.txt` (33 / 28 / 27 lines) |
| The looks gate | `python3 tests/style-gates.py looks BASE dist/duel --jobs 4`, BASE a dist built at 3173bf43: PASS, 83 of 83 stills byte-identical (noise floor 0), every scenario's fighters and sim lines as BASE's. It does not play the K4 cinematics (the YK match never awakens, §18.8); the stills (19.4) are their review |
| Host tests | ALL PASS, 4105 checks (unchanged: the cinematics are drawn code the host tests do not load); `tests/cine-test.lisp` 18, ALL PASS |
| pkgcheck, debug ranges | as main (the one `DUEL::APP` line); `tests/debug-ranges-check.py` 0 errors (87450-87452, 87601-87699 claimed) |
| 0 B a frame | debug 87448: `... dead x8 0, east-void 0, west-ash 0, west-walk 0, west-pass 0, west-column 0, south-dead 0, south-pile 0, south-burst 0`, no row "(dropped)" (landscape and portrait runs) |
| The cinematics in the native sim | a scratch trial file (東 J1 > AS1, 西 J1 J2 > AS2, 南 J1-J3 > AS3 under its pointer, each held into its Kikon, 420 frames each) through `combo-trial.py` with `tools/simgate/trial.lisp`'s `*skip-cines*` set to nil for the run (restored after): the three cinematics play to their end in the native build (`cine YAMA-HIGASHI- / -NISHI- / -MINAMI-CINE`), no Lisp error, the trials after them run; the gates (`gate.lisp` plays cinematics) will meet them once wired |
| Build, smoke | `./build.sh duel` (then `git checkout -- vendor`), `run.mjs --secs 8` smoke exit 0 |

### 19.6 Open

- **For the lead / the user: merge the wiring commit or not** (19.2): the cinematics play only through debug 87450-87452 until it is merged;
  merged, each Bankai Kikon under 東 / 西 / 南 adds 72 / 84 / 96 ticks before the reset, as every other kit's per-pointer Kikon does.
- **For the user: the caption 残日獄衣 shows 残, not the 殘 of their storyboard** (deviation 3): the Japanese form, as 残火の太刀; 殘 is one
  bake away (`tools/glyph-bake.py`).
- **For the user: the lens readings** (deviation 4 and 19.1): 南's "long lens 70" built as a narrow 30 deg at 9 m, its ground shot 50 deg for 32
  (the engine's LENS is a vertical field of view); their call to overrule.
- **For the lead: an AS route's Kikon plays the cinematic of the pointer held when its SP started**, not the AS's number (CORE-KIKON-CINE
  reads FIGHTER-SP-PTR): in the native check J1-J3 > AS3 under pointer 1 played 東's (the proof scripts set the pointer first). A rule from
  before K4, unchanged here.
- **For the user's eyes**: the pacing (the 22 f of nothing in 東, the walk in 西, the long lens in 南), whether the void reads as depth from
  above, the charred victim inside 西's column, the dead at the victim's feet from the ground camera.
- The victim's own form aura draws through every shot (in the stills Kenpachi's yellow REIATSU flames, kept by the spot grade): his kit's
  look, not the cinematic's; D4's "only 西 has flame" is about Yamamoto's looks.
- The toon shader's 1.2 px white edge rims 東's void wedge too (K1 deviation 8's question).
- The stills hold the cinematic (87601+), which freezes the effect clock: a caption exiting in a held still stays half out.

## 20. The user's answers on K4 and the jagged void (2026-11-20)

The user, on the K4 open items (with a manga page as reference: BLEACH ch. 507 p. 10, 旭日刃's cut, kept in the git-ignored
`.refs/yamamoto-rework/ch507-p10-kyokujitsujin-tear.png`):

> 1. 維持残日獄衣即可
> 2. 東的虛空帶我希望能像動畫與漫畫一般呈現出不平整的放射狀缺口

1. **The caption stays 残日獄衣** (the Japanese form already baked; no 殘 bake). Closes §19.6's caption item.
2. **東's void becomes an uneven, radial tear**, as in the anime and the manga, not the clean trapezoid wedge of L6 / K4. Read from the page:
   the void is still flat ink on the floor (D3 「黑色虛空帶」 stands), but its outline is ragged: spikes of uneven length and width radiate
   from the cut's line and from its origin (the tip's touch), edges broken like dry brush, no straight side longer than a spike. It applies
   to both places that draw the void: L6 (KYOKUJITSUJIN NS1c's void line and AS1's notch, `yama-look.lisp`) and the K4 cinematic's
   wedge (`yama-higashi-look`, `yama-cine.lisp`). Presentation only. The shape is fixed per cast (seeded, never re-rolled per frame), and the
   spikes grow out as the void opens. The white toon rim question (K1 deviation 8) is judged again on the new shape's stills.

### 20.1 As built (art batch K5: the 東 void as a ragged radial tear, 2026-11-20)

One helper draws the void in both places: `yama-tear` (`yama-look.lisp`, a `defun-fast-inline`: its call expands in place, so the floats
stay unboxed). L6 (`yama-bk-moves` codes 2 / 3) and the K4 cinematic (`yama-higashi-look`) call it in place of the old ink strip / wedge and
their ember hairlines. Presentation only: `yama.lisp` and every rule are untouched.

**The shape.** It is flat INK on the floor, 1.2 cm up, as one toon fan shape. Heat is 0 on the cut's line and 1 on the ragged outline. The
shader's own wobble (0.14; the old strip had 0.05) and its broken edge give the dry-brush lift; no per-frame randomness is added.
- The body runs from the origin (where the tip touched) along the cut. Its half-width goes from W0 to W1. The outline alternates notches
  and spike tips at uneven stations: a notch sits 0.5-0.95 x the local half-width out (0.8 x at the two ends), and its station is
  jittered by ±0.3 of a step. A tip sits between its two neighbouring notches (±0.45 of a step), so no straight side is longer than the
  spike beside it.
- A spike's length out of the body is G x (SL + 0.9 x the local half-width) x (0.2 + 2.0 h³), where h is a hash from 0 to 1. Most spikes
  are short and a few are long thin claws. N spikes are drawn on each side of the line.
- M spikes fan round each end: behind the origin (the tip's touch: "radiating from its origin") and beyond the far end. These are 0.7 x
  as long.
- Every outline point leans forward by (0.15 + 0.8 c + 0.3 sin(6c + seed)) x its distance out, where c is how far along the cut it is
  (0 to 1). This one smooth shear fans the spikes out from the origin, more toward the far end. Because the shear is monotone along the
  cut, no two spikes cross. The stills show no white rim line inside the black.
- **Fixed per cast.** The shape is a pure function of its seed. L6's seed is his feet on a 0.25 m grid, plus the code: one shape per cast,
  and a few mm of drift cannot re-roll it. The cinematic's seed is the constant 78. Only the shader's boil changes, on the fx clock's
  drawings, as every toon shape does.
- **Growth.** G (0 to 1) grows the spikes out of the body. In L6 the void's body is at full length on S, as before (the hit is the whole
  line), and the spikes come out over 4 f (G = (sf - S + 1) / 4). In the cinematic the body opens as before (0.8 m at the tip to 5 m at
  12 m in 10 f from f84), and the spikes grow over 14 f from f84. While k falls (L6's ash fill, 11 f), the fan erodes from the outline in,
  so the spikes go first.

| Call | Origin, length | Body half-width W0 → W1 | SL | Spikes a side N / each end M | Spike length (at the far end) | Vertices |
|---|---|---|---|---|---|---|
| L6 NS1c KYOKUJITSUJIN | 0.2 m ahead, 5.8 m (to the cap's 6.0) | 0.28 → 0.40 | 0.15 | 12 / 4 | 0.10-1.12 m | 336 |
| L6 AS1's notch | 0.2 m ahead, 1.4 m (to 1.6) | 0.21 → 0.30 | 0.15 | 4 / 3 | 0.08-0.92 m | 132 |
| K4 東 cinematic | NS1c's tip (1.86 m ahead), 12 m | 0.40 → 2.50 | 0.35 | 16 / 5 | 0.52-5.7 m (0.14-1.6 m at the tip) | 444 |

**The ember hairline: dropped in both places.** Following a ragged outline would take a second copy of the shape (twice the vertices). As a
fan shape, EMBER draws its red body and pale core rather than a hairline. The INK shape's own white edge already traces every spike. In the
cinematic, the only colour in 東 stays the blade's ember edge (§15.3.1 b1); the void is ink with a white rim.

**The white toon rim (K1 deviation 8) on the new shape.** The INK palette's value-opposite edge (1.2 px x 1.8 at 720 lines) now runs along
every spike and notch. The shader's brush-lift noise breaks it, so it reads as a manga cut's white margin round the black, closer to ch. 507
than the old even line beside the ember hairline. The shared shader is unchanged; keeping the rim or removing it is still the user's call.
INK's shade tone (the outer ~18 % of a fan's field: `d/k + 0.3 s.x > 0.82`) showed on the first build as a lighter grey band inside the
outline. The tear's uv.x is set to -2 ± 0.4, which keeps that test false: one flat black, as D3. This is a geometry-side choice; the
shader is untouched.

**For the user:** the spikes reach past the hit volume. The solid body stays inside L6's cap (0.2-6.0 m ahead, ±0.4 m), but spikes reach up
to ~1.1 m beyond its sides and its far end (AS1's notch: ~0.9 m). The old strip was exactly the cap. This is decoration on a hit that lands
the whole line at once, but a player may read the spikes as reach.

**Stills (untracked).** `tests/scripts/duel-yama-k5.json` / `-phone.json` (`tests/scripts/duel.py`'s `yama_k5_script`) shoot:
- L6 in play from the behind camera and the SIDE camera: NS1c's void at S+2 / +6 / +14 / +26 (growing, full, held, filling), and AS1's
  notch at S+0 / +4 / +11.
- The 東 cinematic held at f90 (opening), f96 (b4-void), f120 (b5-shatter) and f150 (b6-hang).

Every still was shot with a b2dacf06 dist (before) and this build (after), landscape and portrait (`--mobile --size 390x844`):
`tests/shots/duel-yama-k5-<void-grow|void-full|void-held|void-fill|notch-first|notch-full|notch-held>-<behind|side>[-phone].png` and
`duel-yama-k5-cine-<open|b4-void|b5-shatter|b6-hang>[-phone].png`. Contact sheets (before | after): `tests/shots/duel-yama-k5-void-sheet.png`
and `-sheet-phone.png`.

What the stills show, checked by eye:
- From the cinematic's high camera (b4) the tear reads as the reference does: long thin claws and short teeth leaning out from the cut,
  and a star of spikes round the tip at his feet. It reads most clearly in portrait, where the tear runs up the tall frame.
- From the match's behind camera the low angle compresses it to a jagged black crack. From the side camera the spikes read in full.
- AS1's notch is mostly under the two bodies, as before.
- Low across the void (b5, b6) the spikes break the void's near lip into teeth.

**Checks.**

| Check | Result |
|---|---|
| Host tests | `duel-rules-test.lisp`: 4105 checks, ALL PASS |
| pkgcheck, debug ranges | as main (the one `DUEL::APP` line, 0 redefinitions, 0 undefined); `tests/debug-ranges-check.py` 88 ranges, 0 errors |
| Build, smoke | `./build.sh duel` (then `git checkout -- vendor`), no new compiler warning (12, as base); `run.mjs --secs 8` smoke exit 0 |
| Native trials | `combo-trial.py --log` for `tests/trials/yamamoto-bankai.lisp` (513 lines), `-core` (241) and `-blaze` (268) are identical, line for line, to b2dacf06's. The only extra line is the simgate rebuild banner |
| Shared files | `python3 tests/style-gates.py cvc dist/duel`: II / IK / KK identical to `tests/style-cvc-ref.txt` (33 / 28 / 27 lines) |
| The looks gate | `python3 tests/style-gates.py looks BASE dist/duel --jobs 4`, BASE a dist built at b2dacf06: PASS, 83 of 83 stills byte-identical (noise floor 0), every scenario's fighters and sim lines as BASE's. No pinned still shows the void (the YK match's frames hold none), so the K5 stills are the review |
| 0 B a frame | debug 87448, landscape and portrait: `... void 0, void-grow 0, notch 0, ... east-void 0, east-open 0, east-full 0, ...`, every row 0 and none "(dropped)". The new rows are `void-grow` (code 2 at S+1, spikes growing), `east-open` (f86) and `east-full` (f120) |
| The fx batch | the toon batch holds 16384 vertices; the tear takes at most 444. `fx-dropped 0` on every stats line of both K5 runs, which include the cinematic's busiest frames |

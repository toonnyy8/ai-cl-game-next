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
`yama-art.lisp`, five shared hooks that default off, and the HUD's seals and marks.

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
- **The shared changes**: four switches, each off by default, and one refactor.
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
`python3 tests/sp-costs-check.py` 116 PASS, 0 FAIL; `./build.sh duel`; the browser smoke (`run.mjs` exit 0).

**Open.** The art batch:
- the pointer stances' own clips;
- every Bankai move's own clip;
- the hands, swarm, bone wall and wall-fall looks, KYOKUJITSUJIN's slit, the awakening burst's `:bankai` look.

Also open: the Kikon storyboards (東 / 西 / 南 still `soul-break-cine`), drawn reach against hit reach (the host FK test does not load
yama-art), a CPU that reads the marks or 北 (none asked for), and §9's defaults.

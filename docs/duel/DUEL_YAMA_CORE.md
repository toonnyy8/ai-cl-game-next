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

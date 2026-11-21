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
| 2 城郭炎上 | the arm out, blade pointed at arm's length, held (`ya-enjo`) | a: the stream, a lance of fire along the lane (wave, 10 m; S20, 40) / b: the ring lands round the victim at his bearing (0-8 m since J1, §28.3; radius 1.6 m; lives 90 f; one ring at a time; S16; see Q1) / c: the walls close into a dome on the ring, or at once at his bearing if no ring stands (S18, 80, crumple; `ya-f3`; an NS hazard: J / SA cancel it) | AS2 (2): the ring snaps round him at contact (40, stagger) -> the dome erupts (60, launch) | ENNETSU JIGOKU: the pillars rise from the floor round both, a dome of fire (A) |
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
- **Fixed per cast.** The shape is a pure function of its seed, and every seed is a constant: L6's void 32, AS1's notch 46, the cinematic
  78. So each is one fixed shape per move, the same every cast. Nothing that happens mid-cast can re-roll it. A seed from his feet would
  give each cast its own shape, but a crossing of the rounding grid would re-roll every spike mid-hold. Only the shader's boil changes,
  on the fx clock's drawings, as every toon shape does.
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

**For the user: the spikes reach past the hit volume.** The solid body stays inside L6's cap (0.2-6.0 m ahead, ±0.4 m); the old strip was
exactly the cap. Measured on the tear's geometry with the final law (a Python copy of YAMA-TEAR; its float64 hash rolls other shapes than
the game's single floats, so the numbers are a sweep over 400 seeds, then the seed's own value):
- NS1c's void: the spikes reach a median 0.8 m (at most 1.0 m) past the cap's sides, and a median 1.0 m (at most 1.7 m) past its 6.0 m end.
  At seed 32: 0.85 m and 0.98 m.
- AS1's notch: a median 0.6 m (at most 0.8 m) past its ±0.3 m sides, and 0.8 m (at most 1.4 m) past its 1.6 m end.
- The origin's fan reaches up to 0.6 m behind the tip's touch point, under his own feet.

This decorates a hit that lands the whole line at once, but a player may read the spikes as reach. The knobs, if the user wants them
shorter: SL and the fans' x0.7 in `yama-tear`, or N (more spikes, each narrower).

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

**Checks** (all on the final build, constant seeds):

| Check | Result |
|---|---|
| Host tests | `duel-rules-test.lisp`: 4105 checks, ALL PASS |
| pkgcheck, debug ranges | as main (the one `DUEL::APP` line, 0 redefinitions, 0 undefined); `tests/debug-ranges-check.py` 88 ranges, 0 errors |
| Build, smoke | `./build.sh duel` (then `git checkout -- vendor`), no new compiler warning (12, as base); `run.mjs --secs 8` smoke exit 0 |
| Native trials | `combo-trial.py --log` for `tests/trials/yamamoto-bankai.lisp` (513 lines), `-core` (241) and `-blaze` (268) are identical, line for line, to b2dacf06's (the simgate rebuild banner left out) |
| Shared files | `python3 tests/style-gates.py cvc dist/duel`: II / IK / KK identical to `tests/style-cvc-ref.txt` (33 / 28 / 27 lines) |
| The looks gate | `python3 tests/style-gates.py looks BASE dist/duel --jobs 4`, BASE a dist built at b2dacf06: PASS, 83 of 83 stills byte-identical (noise floor 0), every scenario's fighters and sim lines as BASE's. No pinned still shows the void (the YK match's frames hold none), so the K5 stills are the review |
| 0 B a frame | debug 87448, landscape and portrait: `... void 0, void-grow 0, notch 0, ... east-void 0, east-open 0, east-full 0, ...`, every row 0 and none "(dropped)". The new rows are `void-grow` (code 2 at S+1, spikes growing), `east-open` (f86) and `east-full` (f120) |
| The fx batch | the toon batch holds 16384 vertices; the tear takes at most 444. `fx-dropped 0` on every stats line of both K5 runs, which include the cinematic's busiest frames |

## 21. The Shikai and 爆炎 art batch and the Shikai Kikon storyboards (planned 2026-11-20)

The user, 2026-11-20: 「繼續」 (after K5; the next art per §15.5). Drafted 2026-11-20 by a Fable review, read-only, code as of 9cc5e2af. It expands §15.5's outline on §15.1-§15.4's template. Grades: A canon,
B official game, C secondary, D proposal. Sources: DUEL_YAMA_CORE §2 (Y1-Y12), §3, §6-§7.2, §8, §11, §13, §16-§20;
`docs/research/yamamoto-rework/{canon-looks,motion-refs,core-refs}.md`; `duel/lisp/yama.lisp`, `yama-art.lisp`, `yama-vfx.lisp`,
`yama-look.lisp`, `yama-cine.lisp`; skills `duel-motion-style`, `procedural-ink-style`, `duel-character`. Nothing was built or run for this
plan: every "today" number is read from the code or quoted from §16.1.

### 21.0 What the code shows today (found while reading; each changes the plan)

| # | Finding | Where | Consequence |
|---|---|---|---|
| F1 | The Shikai's blade draws no flame. `vfx-blade-fire` has no caller, and no code reads `kit-blade` (爆炎's `:blade (:fire 1.3)` is dead data, §17.4 dev 7). Only the weapon's 3 mm glow strip shows | grep over `duel/lisp`; `yama-draw` draws only the Bankai's looks | "THE fire form" has no fire on its sword: look SL0 is the first job |
| F2 | TAIMATSU's halo draws nothing. `vfx-fire-cone` has no caller; the SA is a melee window with no look | `yama.lisp` `:ya-sa`; grep | §16.1's "its fire cone carries it" is not true today: the SA's 2.4 m (爆炎 3.2 m) reach is invisible past the 1.45 m tip |
| F3 | IKKOTSU punches with the blade in the fist. `*ya-plants*` has Bankai rows only | `yama-look.lisp` | one `*ya-plants*` row (S4) |
| F4 | The Shikai's swing smear is the REIATSU yellow comet (kit `:smear` NIL = look 1) | `draw.lisp` `vfx-smear` | a fourth hue on every swing; S2 gives the form a `:smear` |
| F5 | `yama-nade-look` writes its hazard's data from the draw path (`:done`), and is a one-shot stamp | `yama-vfx.lisp` | breaks "a look never writes"; replaced in S1 |
| F6 | The state hash line counts hazards (`gate.lisp`). `spawn-look` makes a hazard entity | `gate.lisp` l.31, `hazards.lisp` | no new look may be a hazard entity, and no look hazard's `:life` may change: both move hash lines. NADEGIRI's split keeps its `:delay 24 :life 2` entity |
| F7 | The looks gate plays the Shikai: its YK match (seed 28) is Shikai moves only (§18.8) | `tests/style-gates.py` `LOOKS_SEEDS` | **this is the first Yamamoto art batch where 83 / 83 cannot hold.** The YK stills change by design; see §6 |
| F8 | Ten slots play another move's clip, six of them re-timed by `:clip-s` (x0.2 to x2.2) | `yama.lisp`; §3 below | the skill's red flag "a sibling's clip sped up" |
| F9 | Captions: 不 知 火 斬 地 獄 上 are baked; 城 郭 炎 撫 焱 熱 are not | grep over `glyphs.lisp` | 不知火 needs no bake; 撫斬 needs 撫; 焱熱地獄 needs 焱 熱 (城郭炎上 would need 城 郭 炎) |
| F10 | 爆炎's entry pose plays `ya-hellfire` (a 60 f clip with a 360° root turn) in 24 f (`:clip-s 57` at S23: x2.5); IKKOTSU's clip is S8 on a move at S9 with no `:clip-s` | `yama.lisp`, `yama-art.lisp` | S4 re-keys both; the second is to be confirmed by the FK print (the hit pose may land a frame early) |
| F11 | NS2c / AS2b with no ring standing: the bearing point is sampled on S and the dome is hot from S for 4 f. No delay | `yama-dome-fire` | no ground tell is possible there; the tell must be on his body (S3's raised blade). Told here, not changed: a rule |
| F12 | The heat a segment paid is already carried for the looks: a hazard's data `:heat` (0-25, taken at its fire frame) and `yama-seg-heat` (a pure reader) for his own move. 爆炎's segments pay 25 too | `yama-fire`, `yama-wave-fire`, `yama-seg-heat` | the looks read these; no new sim field. In 爆炎 every NS reads "full" for free |

### 21.1 Order and batching

**Shikai looks, then Shikai clips, then 爆炎, then the three Kikon cinematics.** One form at a time, looks before strikes (skill rule).

| Evidence | For |
|---|---|
| Every match starts in the Shikai; it is the form seen longest (§15.1's "against") | Shikai first |
| F1 / F2: the two most-used fire reads (the blade, the SA) draw nothing | looks first |
| 爆炎's moves are `defmove-copy`s of the Shikai's: it reuses every Shikai look with one flag and 13 of its 16 clips | 爆炎 after the Shikai |
| The cinematics use the same looks at cinematic scale (K4 reused K1's on stand-in hazards, §19.3 dev 5) | cinematics last |
| Risk: §11 dev 4 calls the hazard widths / speeds and every A / R "the lead's placeholders", and `:mult` is "tuned by play" | freeze before keying |

Answer to the risk, as §15.1: the looks read `hazard-size` / `hazard-life` from the struct, never a literal, so a retuned width moves the
look with it. Before S2 the lead freezes the S list (§3's S column) with the user's playtest. A later A / R change then costs a recovery key.
Where a look needs a speed as a constant (K1's 0 B fix, §16.4), a host check asserts it equals the move's `:speed`.

| Batch | Content | Review gate (stills to the user) |
|---|---|---|
| S1 | FK first: the Shikai / 爆炎 rows of `tests/duel-rules/art.lisp` become checks (today printed only), with a `known-off` list. Trace K3's open item (do move-frame looks lag the hit by the hitstop, §18.9) before SL7 / SL8 are built on move frames. Then the look list §2 (SL0-SL9) | each look at heat 0 / 12 / 25: match camera + side, landscape + portrait; one top-down still per footprint |
| S2 | the three stances, NA (J1 at S14, the pommel), pointer 1 (NS1a-c, AS1), the Shikai's `:smear` | the stance triptych (debug 2510 + p), 8-frame strips, 緩急 prints for J1 and NS1a |
| S3 | pointer 2, pointer 3, AS2, AS3, the SA, the Kikon strikes | strips, link-jump table, then the playtest Artifact |
| S4 | 爆炎's delta (§4): trail, IKKOTSU, entry pose, tracking tornado, ENNETSU's rows, the true NADEGIRI, scars by heat | stills at heat 100 / 50 / 10, then the playtest Artifact |
| S5 | the three Kikon cinematics from §5 (after the storyboards' yes; needs S1). The wiring is its own, last commit (§19.2's rule) | one still per beat, both aspects |

S1 (`yama-look.lisp`, `yama-vfx.lisp`) and S2 (`yama-art.lisp`) touch different files and may run in two worktrees; both edit `yama.lisp`
(`:look` against `:clip`), so the lead merges and runs `unit-names`. S2 and S3 share `yama-art.lisp` and its named landing poses: in order.

**The heat gauge stays presentation.** A look may read three things and write none: a hazard's `:heat` (F12), `yama-seg-heat` for his own
move, `gauges-meter` for the stance and the scars. Rules for the batch: no `setf` of `gauges-*`, `yss-*` or `hazard-data` in any draw
path (F5 goes); no `sim-rnd01`; a refunded segment's `:heat` is zeroed by the sim, so its look drops to tier 0, which is correct (the
fire was cancelled). The proof is §6's row 1.

### 21.2 The Shikai's looks

**Colour rule (D, from A: "the blade is engulfed in fire"; A: he sets how hot each target burns, ch. 339).** Two hues and two values:
FIRE orange is the mass, EMBER dark red is the backing and every floor mark, INK is the shadow side of the big shapes (the tornado, the dome).
**White-hot has one owner: heat.** It appears only as the core of a segment that paid heat, in proportion, and everywhere in 爆炎. No white
flash, rim or core for any other reason, so the player reads the spend in the fire itself. The three forms then read apart at a glance:
Shikai orange, 爆炎 white-cored, Bankai ink with an ember line (D4). No REIATSU yellow (F4).

**Heat tiers (h = paid / 25).** Three drawn steps, not a ramp (value steps read; the HUD's 25 ticks make "full" the common case):

| Tier | When | Height / reach above the footprint | Density | Core |
|---|---|---|---|---|
| T0 | paid 0 | x0.6 | 60 % of the tongues | none: orange over ember |
| T1 | 0 < paid < 25 | x0.8 | 80 % | a thin white core, 30 % of the width |
| T2 | paid 25 (and every 爆炎 segment) | x1.0 | all | white-hot, 60 % of the width; an EMBER scorch left on the floor for 30 f |

**The footprint never scales with heat**: the hit box is the same at any heat, so the ground edge of every look is the sim's edge at every
tier. Heat changes height, density and core only. (Q1 asks how wide this span should be.)

| # | Look | Canon | Shape as vector ink | Sim footprint it must equal (`yama.lisp`) | Frames |
|---|---|---|---|---|---|
| SL0 | the blade's fire (every Shikai move and stance) | the blade engulfed, igniting from the tip down (A, `RyūjinJakka.gif`) | `%blade-fire` revived from `yama-draw` (it exists, unused): the sheath, three tongues on twos, the T光 line. Power 0.5 at rest, 1.0 in a move's startup to S+A, by tier in an NS | none (it is not reach: the FK test measures the steel) | always; scraps only inside a move |
| SL1 | NS1a's spiral stream | RoS "a veritable tornado of flame", cast ahead (B) | a corkscrew: two FIRE ribbons wound round the lane's axis over an EMBER backing, a rolling head on the hazard's x, a tail 2.5 m long that thins. No flat sheet (K1 dev 6: a sheet hid the foe) | `:wave` 2.0 m wide (half 1.0), 14 m/s over 8 m (34 f), spawned 1 m ahead | S22 to S+34 |
| SL2 | NS1b's tell and column | 不知火 = ghost lights at a distance (D, the folklore); the column (B) | tell: an EMBER ring on the disc's edge and 5 small pale flames hovering 0.3-0.8 m over it, circling inward, pulsing on twos (the Step's read). Eruption: one column as wide as the disc at its foot, tapering, crown tongues | `:ya-col` disc r 1.2 at his bearing 4-7 m; `:delay 13`; hot 6 f; life 30; fire height 2.4 m | tell S16 to S+11; erupts S+12 (f28); hot to S+17; erodes to S+30 |
| SL3 | NS1c's tornado (its own look: 北 no longer borrows it) | RoS tornado (B); the Taimatsu anime's flame tornado round the target (A) | a funnel of 4 stacked, tilted FIRE bands turning on twos, INK on their far side, a spiral EMBER stripe; the lowest band is the footprint (3.5 m), the bands narrow upward to 3.2 m high. **Gaps between the bands** keep the foe in view from behind; shrunk near the lens (`%near-cam`) | `:wave` 3.5 m wide (half 1.75), 10 m/s over 8 m (48 f), knock-back 3 m | S18 to S+48 |
| SL4 | NS2a's stream | a horizontal lance of fire tapering to a point (A, ep. 215) | a lance: a FIRE lens with a pointed head on the hazard's x, tied back to the blade's tip for its first 8 f (fire running off the tip), a thin EMBER scorch line left on the lane for 20 f (a mark, no flames: it must not read as a hazard) | `:wave` 1.2 m wide (half 0.6), 18 m/s over 10 m (33 f) | S20 to S+33 |
| SL5 | the burning ring (NS2b; AS2a's snap) | the stream coils into a ring on the ground (A) | a continuous low wall of 24 tongues on the circle, 0.5 m thick (the band), ≤ 1.0 m high on the camera's side and 1.4 m on the far side; it coils in from one point in 4 f. **It shows its charge**: 2 hits left full, 1 thinner, 0 embers only (a spent ring cannot burn: `hazard-hits-left`). Its last 15 f gutter | `:ya-ring` r 1.6, band ±0.25 m (`*ya-ring-band*`), 90 f, 2 hits of 20 (爆炎 26), one at a time | NS2b from S16; AS2a from its hit frame; 90 f |
| SL5b | the crossing burn | (D: Y8 「會燒的火環，可穿過」) | the generic hit spark at the victim plus SL5 dropping a step. A flare at the crossing point would need a feedback hook (shared, default off): only if the stills say the burn does not read | the hit is the ring's (above) | the hit frame |
| SL6 | the dome (NS2c; AS2b; 爆炎 NS2b) | the walls climb and close into a squat dome, no shell (A, ep. 215) | 12 FIRE tongues on the disc's edge rise and lean in to close at 2.4 m in 4 f, hold as a flattened dome with dark gaps for 12 f, then erode. On a standing ring the ring's own tongues are the ones that rise. Pure of the hazard's age (no `*dome-last*` state) | `:ya-dome` disc r 1.6 on the ring, or at his bearing 3-8 m (AS2b from 0 m); hot 4 f; life 40 | closes S18 to S+4 (hot); holds to S+16; gone by S+40 |
| SL7 | NADEGIRI: the unseen cut and the late split (NS3c, AS3c) | the cut is never shown; the split comes a beat later (A, ch. 338, `HitotsumeNadegiri.gif`) | on S: one INK hairline across the arc at neck height for 2 f, nothing else. At S+24: a seam of fire opens along the cut's line through the victim's spot, two walls of flame parting left and right (a V), tallest at 2.4 m ahead, by tier. Drawn from the move's frames by `yama-draw` (F6: the hazard lives 2 f), from his feet (§16.3 dev 2) | melee `:reach 2.4 :arc 100`, the hit on S14 for 4 f. **The split is aftermath, not a second hit**: no spark, no shake | line S14-S15; split f38 to f52 (the Shikai's R34 ends at f52) |
| SL8 | the SA's halo (TAIMATSU) | a full radial halo of fire, his silhouette at its centre (A, `Taimatsu226.gif`) | tongues ignite round him following the turn, the ring opens from 0.6 m to the reach in 2 f and stands for the window; an EMBER ring on the reach's edge; INK behind him so he reads dark in the fire. The `%ya-flare` pattern with a radius argument, shrunk near the lens | melee `:reach 2.4 :arc 360` (爆炎 3.2), S16 A8 | f16 to f23, fading to f27 |
| SL9 | the small fires | the burning pommel (D, the user's 「右手刀柄回擊」); AS1's point-blank spiral | J3: a fist-sized flame on the pommel from S-2 to S+A. AS1: SL1's corkscrew as a 1.4 m burst from the tip | J3 reach 1.4 (the floor `*j-reach-min*`), arc 140; AS1 `:reach 1.6 :arc 90` | J3 S9; AS1 S10-S12 |

Deviations to expect, said now: SL3 and SL6 will hide part of the victim for 40-48 f whatever the gaps; SL7's seam past 2.4 m is decoration
beyond the hit (K5's caveat, Q4). The old `vfx-fire-wave` / `-pillar` / `-dome` take boxed floats and keep draw-side state (`*wave-ghosts*`,
`*dome-last*`): the new looks are `defun-fast` functions of the hazard's age in `yama-look.lisp` (K1's pattern), and the old ones stay
for `yama-bankai-cine` until nothing calls them.

### 21.3 The Shikai's clips

Planes / hands (motion-refs §5: none shared inside the form): J1 ↘ fore, J2 ↗ back, J3 pommel thrust, NS1a level thrust, NS1b vertical up,
NS1c overhead whirl, NS2a spear cock and lock (travel 0), NS2b wrist circle, NS2c short vertical chop to level, NS3a low rising jab,
NS3b level R→L fore, NS3c level L→R back at the neck, AS3a reverse-grip pull, AS3b rising ↖ fore, SA body turn. Two same-theme pairs share a
plane on purpose (AS1 with NS1a, AS2a's flick with NS2b's circle): §5b's theme rule; they differ by length and startup.
He has one arm (TYBW). No root yaw turns: the blade is carried round him (skill red flag; `ya-taimatsu`, `ya-f3`, `ya-nadegiri` have 360° turns today).
Tip targets are the volumes; **S1's FK print decides**. Today's tips are §16.1's.

| Slot | S / A / R | Archetype | Body in one line | Grade | Verdict | Now plays (**borrowed**) | Drawn tip target (today) |
|---|---|---|---|---|---|---|---|
| Stance 1 不知火 | loop | the flame wave, coiled | sunk and side-on, the hilt drawn back at the right hip 0.3 m out from the body, the blade level along the lane; SL0 as a slow corkscrew on the blade | B + D | re-key (4 keys) | `ya-shiranui`, a 0.5 s 2-key charge loop | - |
| Stance 2 城郭炎上 | loop | the point | upright, the arm locked out at shoulder height, the blade level at the foe; a drip of fire off the tip | A (`316Jokaku Enjo`) | re-key (4 keys) | `ya-st-enjo`, 2 keys on ENJO's pose | - |
| Stance 3 撫斬 | loop | the pivot, at rest | upright, eyes shut, the hand on the pommel of the blade stood point-down **0.25-0.3 m to his right front** (D: his body hides a centred blade from the behind camera, as 南's); **no fire at all**: SL0 off | A (the cane) / D (offset) | re-key | `ya-st-cane`, 2 keys on the intro's lean | cast: tip on the plaza ±0.05 |
| J1 HISEN | 14 / 3 / 12 **(opener: held tell)** | unmovable pivot | charge f0-9 (the wrist cocked high right, the feet still), held f10-12, snap ↘ f13-14; `:blend 4` (it starts from three stances, §18.3) | D | re-key at S14, `:clip-s 9` dropped | `ya-q1` S9 slowed x0.64 | 1.4 (1.39) |
| J2 KAESHIBI | 8 / 3 / 13 | the return flick | frame 0 = J1's f17; low left to high right, the elbow leading | D | reuse (frame 0 checked) | `ya-q2` | 1.4 (1.35) |
| J3 TSUKABI | 9 / 3 / 18 | pivot finale | frame 0 = J2's f11; the grip drawn back, the pommel punched up into the face; SL9 | D (the user, 2026-10-14) | reuse, frame 0 re-keyed | `ya-tsuka` | 1.4 by the **pommel** (the FK row measures the weapon's base; the tip prints 1.78) |
| NS1a | 22 / 2 / 24 **(tell)** | the point, thrown | frame 0 = stance 1; the spiral gathers f0-14 (a key a frame), the coil held and trembling f15-19, a level thrust with the arm locked f20-22 | B + D | **new `ya-n1a`** | **`ya-f1`** (the waist sweep) S18 at x0.82 | cast: tip ≥ 1.0 m ahead at 1.1 m up (the wave starts 1 m out) |
| NS1b | 16 / 13 / 20 | the lift | frame 0 = NS1a's f24; the point dropped to the plaza ahead (f8, held f9-12), then lifted straight up onto the toes on S: the fire answers 4-7 m away | C + D | re-key at S16, `:clip-s 22` dropped | `ya-f2` S22 at x1.4 | cast: tip overhead on S, in the plaza f9-12 |
| NS1c | 18 / 2 / 30 | the whirl | frame 0 = NS1b's f29 (the blade overhead); one whirl of the blade above his head (a key every 90°, the wrist, no root yaw) f0-12, held high f13-15, flung forward and down on S, the torso turning in | B + D | **new `ya-n1c`** | **`ya-sig`** (the three-beat halo, S40) at x2.2 | cast: tip ≥ 1.0 m ahead on S |
| AS1 | 10 / 3 / 24 | the point, point-blank | frame 0 = J1's f15; the hilt pulled to the ribs (f0-6, held f7-8), a short corkscrew thrust, the wrist rolling | B + D | **new `ya-as1`** | **`ya-shiranui-throw`** S2 at x0.2 | 1.6 (2.04: **+0.44 over**) |
| NS2a | 20 / 2 / 22 **(tell)** | the spear | frame 0 = stance 2; the pointing arm cocked back to the shoulder like a spear (f0-12), held f13-17, locked out on S: the lance leaves the tip | A (the cane "used like a spear") + D | re-key | `ya-enjo` (its own; R30 on a move of R22) | cast: tip ≥ 1.0 m ahead on S |
| NS2b | 16 / 2 / 20 | the point draws | frame 0 = NS2a's f22; the wrist draws one circle with the point (r 0.25 m at the tip, f4-13: SL0 leaves the circle in the air), a stop on S | A (the stream coils into a ring) | **new `ya-n2b`** | **`ya-enjo`** again, S20 at x1.25 | - (SL5) |
| NS2c | 18 / 2 / 30 **(F11: the only tell)** | the call | frame 0 = NS2b's f18; the blade raised point-up overhead (f0-8), held f9-14 with fire climbing it, chopped down to the level point on S | A (ep. 215: raised point-up, then the point) | **new `ya-n2c`** | **`ya-f3`** (the 360° spin drop, S22) at x1.2 | cast: tip overhead f9-14, level on S |
| AS2a | 12 / 3 / 16 | the flick | frame 0 = J2's f9; a short level flick of the point across his chest R→L: the tip draws the ring that snaps on | D | **new `ya-as2a`** | **`ya-enjo`** S20 at x1.7 | 2.0, arc 120 (1.66) |
| AS2b | 18 / 2 / 30 | the call, close | frame 0 = AS2a's f15; NS2c's poses from that frame | A | **new `ya-as2b`** (NS2c's poses, its own frame 0) | **`ya-f3`** | - (SL6) |
| NS3a | 18 / 3 / 18 **(tell)** | Onibi's jab | frame 0 = stance 3; the blade pulled up out of the plaza (f0-12: the tell), levelled low at the hip, held f13-15, a low rising jab with the 1.0 m slide | A (Onibi, ch. 337: the low jab, walking past) | **new `ya-n3a`** | **`ya-q2`** (J2's) S8 at x0.44 | 1.6, arc 90 (1.38) |
| NS3b | 12 / 3 / 18 | the closing step | frame 0 = NS3a's f21; one step, a level cut R→L at the waist with the 2.0 m slide | D | **new `ya-n3b`** | **`ya-q1`** (J1's) | 1.6, arc 110 (1.39) |
| NS3c NADEGIRI | 14 / 4 / 34 | the pivot, purest | frame 0 = NS3b's f15; f0-9 still: the blade settles at the left hip, eyes shut; f10-12 a 1° tremble; f13-14 the snap L→R at the neck (2 frames of smear); then stillness: the blade lowered over 20 f, the chest (-46°) and head turned away, no root yaw | A (ch. 338) | re-key at S14, `:clip-s 20` dropped, the 185° root turn removed | `ya-nadegiri` S20 at x1.43 | 2.4, arc 100 (1.87): a 0.3 m drawn lunge, SL7's line carries the rest (one-sided) |
| AS3a | 8 / 3 / 14 | the back cut | frame 0 = J3's f10 (the blade laid back along the forearm); the hilt pulled back across him: the edge cuts on the pull | D | **new `ya-as3a`** | **`ya-q2`** (J2's) | 1.8, arc 120 (1.35) |
| AS3b | 10 / 3 / 16 | the turning cut | frame 0 = AS3a's f11; the blade flipped forward, a rising cut to his high left as the chest turns | D | **new `ya-as3b`** | **`ya-f1`** S18 at x0.55 | 2.0, arc 160 (1.99) |
| AS3c | 14 / 4 / 34 | NADEGIRI | frame 0 = AS3b's f13; NS3c's poses from that frame | A | **new `ya-as3c`** (NS3c's poses, its own frame 0) | **`ya-nadegiri`** | 2.4 |
| SA TAIMATSU | 16 / 8 / 24 | the wave, all round | the eye-open tell (f3), the blade carried once round him low (a key every 90°), rising into the fan on S; SL8 is the reach | A (`Taimatsu226.gif`) + B | re-key (the root 360° replaced by the carried blade; hit pose kept) | `ya-taimatsu` (its own) | one-sided: 1.45 against 2.4 / 3.2 (SL8) |
| Kikon strikes (NS / AS) | J1's | - | copies of J1 with a 0.25 m drawn lunge: J1's tip is 0.21 m short of their 1.6 | - | **new `ya-strike`** (J1's poses, `:root :f`) | **J1's clip** | 1.6 (1.38-1.39: **-0.21**) |

Count: 13 new (two of them pose-sharing copies), 7 re-keyed, 2 reused, 3 stances re-keyed. Borrowed today: NS1a, NS1c, NS2b, NS2c, AS1,
AS2a, AS2b, NS3a, NS3b, AS3a, AS3b, AS3c and the Kikon strikes (13 slots on 8 other moves' clips).
Still open after the batch, as the Bankai's: the SA's frame 0 matches none of its six predecessors (NS1a f24, NS1b f29, NS2a f22, NS2b
f18, NS3a f21, NS3b f15); a per-predecessor clip needs a mechanism that does not exist (§18.9).
S1's `known-off` list starts as: AS1 (+0.44), the Kikon strikes (-0.21), NS3a / NS3b (-0.22), AS3a (-0.45); S2 / S3 empty it.

### 21.4 爆炎 (GOKUEN)

What changes against the Shikai. Everything not listed is the Shikai's clip and look at tier T2.

| Item | Today | Plan | Kind |
|---|---|---|---|
| The body | `:yamamoto-bare`, 12 glowing scars at a fixed 2.4, the `:hellfire` aura | exists; kept | - |
| Scars by heat | fixed glow | the glow follows `gauges-meter`: full at 100, a dull red by 25, pulsing in the last 10 (the form is about to end). `draw-body`'s `:emissive` adds to every part, so this needs either a glow-parts-only gain in `body.lisp` (shared, default 1: the lead's call) or FIRE hairlines drawn over 6 scars by the draw hook | look (read only) |
| The blade | no fire (F1) | SL0 at power 1.3, white-cored | look |
| J1 / J2's flame trail | none | a kit `:smear` look for `:blaze`: the swing's trail as a FIRE wash with tongues off its upper edge (the `:smear` slot of §17.4 dev 7; a new branch in `vfx-smear`, default off). No new clips. The Shikai's `:smear` is the same wash thin, with one orange hairline | draw hook |
| J3 IKKOTSU | `ya-ikkotsu` S8 on a move at S9 (F10); the blade in the fist (F3) | re-key at S9, frame 0 = J2's f11; the blade planted at his right (a `*ya-plants*` row, f2-f24), the fist straight out at shoulder height (A, ch. 394); a short FIRE burst on the fist at S | clip + table row |
| The entry pose `ya-blaze-in` | `ya-hellfire` at x2.5, a 360° root turn in 24 f | its own 24 f clip, no turn: the point lowered to the plaza at his right (f0-6), fire runs down the edge into the floor and a ring runs out (f7-16), he straightens, chest out, chin up (f17-23). The strip is the form swap itself (instant at `set-form`) | clip |
| NS1c: the tornado tracks | SL3 would travel upright | the funnel leans into its turn (its yaw rate is not stored: lean toward the target's bearing, read from `hazard-target`); taller (T2) | look |
| NS2b: the ring closes at once | the dome | SL6 with the coil-in and the close in one (the ring drawn for 4 f, then the walls) | look |
| NS2c ENNETSU JIGOKU | the tornado's pillar look | **rows of pillars**: 3 pillars abreast across the 2.4 m box, a new row rising every 1.0 m as the wave's front passes (5 f at 12 m/s), each standing 16 f then eroding, so 3 rows burn at once behind the front; EMBER circle marks on the floor a row ahead of the front (the tell that it is coming). The front row's far face is the hazard's x | look. Footprint: `:wave` 2.4 m wide, 12 m/s over 9 m (45 f), S18 |
| NS3c: the true NADEGIRI | `ya-nadegiri` with R60 (the last pose held) | its own clip `ya-b-n3c`: the Shikai's cut, then the "huge opening" drawn: the blade lowered over 40 f, his back turned (chest and head), a held stillness to f78. SL7's seam at T2, 8 m long | clip + look |
| AS1 / 2 / 3, NS1 a / b, NS2a, NS3 a / b, SA | the Shikai's clips | the Shikai's clips and looks; the SA's halo at 3.2 m | - |
| The cancel burn (Y10) | a sound only (§13) | `vfx-scorch` on the opponent's weapon hand from the existing cancel feedback, if that event carries the side; else left as a sound | look, to check |

**The open question: its own stances and Kikon cinematics, or the Shikai's? Recommendation: the Shikai's, in 爆炎's dress.**

| Reason | Evidence |
|---|---|
| The pointer themes are the same three | §3: "each has a 爆炎 variant"; DUEL_CORE §5b: stance, NS, AS n and Kikon share one theme. A second stance for the same pointer makes the player relearn the read for a state that lasts seconds |
| 爆炎 is short | 10 s at most (decay 10 / s), less with each NS (25 a segment): three NS segments leave about 2 s (§13 B13) |
| The form already reads at a glance | the bared body, the scars, the aura, the white cores, the trail, the HUD's 爆炎 strip |
| A cinematic's length is sim ticks (§19.2) | three more storyboards would add three more tick costs for a window that seldom holds a Kikon (the Kikon is a hold after an SP; the CPU "spends its heat on NS routes, so it seldom reaches 100", §13) |
| It costs nothing | a `defcine` draws the actor's current model, so the same three cinematics show him bared and scarred; each look takes a form flag for T2 fire. `:blaze`'s `:kikon-cines` lists the same three |

If the user wants one difference, Q2's option B is the cheap one: pointer 2's Kikon alone changes with the form.

### 21.5 The three Kikon storyboards (Shikai)

House length 150-206 f (§15.3). The engine's LENS is a **vertical field of view in degrees**: a small number is a long lens (§19.3 dev 4).
Landscape letterbox 9 %; "P:" = the portrait note. Camera terms as K4 built them (`shot-on actor angle dist height`, `shot-pair`).
Kept apart from each other and from the Bankai's: 1 = **fire that comes from nowhere**, 2 = **the cage**, 3 = **nothing happens, then it has**.
Angles are drafts: K4 moved eight of them because the other actor blocked the lens (§19.3 dev 1). Expect the same.

**The K4 finding applies in full (§19.2): a Kikon cinematic's length is sim timing, in ticks only.** The damage frame does not move; the
reset after it does. Against the generic `soul-break-cine` (96 f):

| Pointer | Storyboard length | Ticks added per Kikon | Cost of the build |
|---|---|---|---|
| 1 不知火 | 174 f | +78 | the ghost lights and the closing columns (SL2, SL3 at cinematic scale); no bake |
| 2 城郭炎上 | 186 f | +90 | the floor pattern, 12 pillars, the dome (SL6 at scale); bake 焱 熱 |
| 3 撫斬 | 156 f | +60 | the seam (SL7 at scale), the victim's own attack clip (K4's `yama-victim-attack`); bake 撫 |

Unlike the Bankai's, **these ticks reach a gate**: the looks gate's YK match plays the Shikai, so if seed 28 holds a Shikai Kikon its later
sim lines shift. The wiring is therefore its own commit, and the YK scenario is re-based on that commit (§6). The CPU's later play also
shifts (MCTS seed and the learner's roll read `*match-tick*`).

#### 21.5.1 Pointer 1: 不知火 SHIRANUI (174 f)

Idea: he thrusts and nothing leaves the blade. Lights wake round the victim, become columns, and close into one tornado.
Actors: `cine-place a v 6.0` (the long-reach pointer). The victim ends down at his placed spot, black and smoking.

| Frames | Shot (angle / dist / height / lens) | Action | Effects / sound | Note |
|---|---|---|---|---|
| 0-10 | (held from play) | beat 0: `hold-both`; he holds stance 1's coil, the victim `:sh-kikon-victim` | negative 2; whoosh | |
| 10-40 | on him, side-front 60°, 1.8 m, 0.9 m, lens 50, roll 5 | the blade at his hip; the spiral winds down it from the tip to the guard and tightens | silence 30; caption 不知火, SHIRANUI, sub RYUJIN JAKKA, hanko | P: `:off` halves by itself. No bake (F9) |
| 40-58 | behind and above the victim: on v 180°, 7 m, 4.5 m, lens 44 | pale lights wink on round the victim on the floor, one every 2 f: 5, then 9, on a circle r 4 m. He looks about | each a soft tick; no source visible (A: none; D: the folklore) | P: 9 m |
| 58-76 | side-on pair, 9 m, 1.2 m, lens 46 | `cine-slow` 0.4: the level thrust (NS1a's release, f62). The spiral on his blade goes out. Far away the nine lights stand up as columns | one dry crack on the thrust; then the roar starts | the economy beat: the blade does nothing here. P: 12 m |
| 76-120 | above the victim: on v 0°, 2 m, 10 m up, looking down, lens 40 | the columns circle him, faster, the circle closing from 4 m to 0.8 m in a spiral; they lean together | SL2 x9 at T2; shake rising to 0.4 | the shot the cinematic is for. P: 12 m up |
| 120-126 | on the victim, front, 3.2 m, 0.5 m, lens 36 | the wall reaches him; f122 the Konpaku shatters | negative 2, `cine-shatter`, manga 10 | |
| 126-150 | low, looking up the tornado: on v 30°, 5 m, 0.3 m, lens 60 | one tornado, 10 m tall, white-cored; the victim a black silhouette inside it, on the floor (never lifted: no y change) | SL3 at scale; `silhouette-black`, `:sh-crumple` | CINE-END undoes the silhouette (§19.1, 西) |
| 150-174 | behind Yamamoto: on a 160°, 3.5 m, 1.6 m, lens 44 | his back (the 一 in its rhombus, the haori settling); beyond him the tornado gutters to embers; he lowers the blade; the victim down | caption exits f150; `:sh-down`; black smoke | P: 5 m |

#### 21.5.2 Pointer 2: 城郭炎上 → 焱熱地獄 ENNETSU JIGOKU (186 f)

Idea (§7.1, A ch. 393): fire runs down the edge into the floor and draws its circles; the pillars rise round **both**; they close into a dome
with him inside it. Actors: `cine-place a v 3.0`. The victim ends down at his spot. (Q3 asks whether he is inside.)

| Frames | Shot | Action | Effects / sound | Note |
|---|---|---|---|---|
| 0-10 | (held) | beat 0; he holds stance 2's point | negative 2 | |
| 10-34 | low on the sword hand: on a 30°, 2.0 m, 0.5 m, lens 50 | he turns the blade point-down, the edge to the floor (`ya-hellfire-point`); f22 the fire on the blade runs down the edge into the ground | silence 20, then a hiss; caption 焱熱地獄, ENNETSU JIGOKU, sub JOKAKU ENJO, hanko | bake 焱 熱 (`tools/glyph-bake.py`); caption-fit test |
| 34-66 | from above: on a 0°, 2 m, 10 m up, looking 1.5 m ahead, lens 44 | EMBER lines run out over the floor from the blade and branch into circles: rings at r 2 / 4 / 6 m and 8 spokes, drawn in 20 f, enclosing both; f60 twelve marks on the r 4 ring ignite | drawn in the look (not `stage-crack-add`: no marks left for the round) | A: "branches in circle patterns". P: 13 m up |
| 66-110 | side-on pair, low, 5.5 m, 0.6 m, lens 46 | the twelve pillars rise behind both, one every 3 f, to 6 m, then lean in. The victim turns, looks for a way out (`:sh-stagger` x0.5). He does not move | ember pillars; the roar; shake 0.2 | P: 7.5 m |
| 110-130 | far, outside: `shot-pair` 12 m, 2.5 m, lens 40 | the pillars join into one squat dome (r 5 m, 4 m tall, dark gaps); both are inside, unseen | silence 12 from f110, then one low boom | A: the flattened sphere (ep. 215). P: 15 m |
| 130-136 | inside, on the victim, front, 2.6 m, 1.4 m, lens 50 | white fire from every side; f132 the Konpaku shatters | negative 2, `cine-shatter`, manga 10 | |
| 136-160 | inside, on him: front 15°, 2.4 m, 1.3 m, lens 44, roll -4 | his dark shape standing in the flames, the blade still down, the haori's hem alight | INK on him, embers on the hem. A look only: **no Reishi is taken** (the self-burn is canon's, not this move's rule) | A: `EnnetsuJigoku.gif` 27-30 s |
| 160-186 | wide, outside, side: 9 m, 2.0 m, lens 44 | the dome falls outward to a scorched ring; the victim down and smoking; he stands with the arm out, the blade pointed at where it stood | caption exits f160; ash; black smoke | A: the pointing end pose (ep. 215). P: 12 m |

#### 21.5.3 Pointer 3: 撫斬 NADEGIRI (156 f)

Idea (A, ch. 338): the cut is never shown. He lowers the blade and turns away. The victim does not know. Then the split.
Actors: `cine-place a v 2.0`. The victim's model is never cut: the split is a seam of light and fire over a black silhouette, then he falls.
Kept apart from 南 (he walks toward a long lens, a crowd behind): here he does not walk, the camera is side-on and close, and nothing is on screen but the two of them.

| Frames | Shot | Action | Effects / sound | Note |
|---|---|---|---|---|
| 0-12 | (held) | beat 0; he holds NADEGIRI's draw pose (the blade at the left hip), the victim `:sh-kikon-victim` | negative 2 | |
| 12-40 | on his face: front 10°, 2.2 m, 1.55 m, lens 20 (a long lens) | eyes shut. Nothing moves | silence 28; caption 撫斬, NADEGIRI, sub RYUJIN JAKKA, hanko | bake 撫. P: 3.0 m |
| 40-52 | over his shoulder at the victim: on a 200°, 2.4 m, 1.5 m, lens 50 | one eye opens (a garnish). The victim, unharmed, starts his own attack (his kit's `:q`, K4's `yama-victim-attack`; `:sh-clash` if none) | `cine-slow` 0.3 | "not even aware of it" (A) |
| 52-56 | the same | the cut, not shown: one INK hairline across the whole frame for 2 f. On the next frame his arm is already out to his right | negative 2; one dry tick, no slash sound | 2 frames of smear (motion-refs H1) |
| 56-110 | side-on pair, 4.2 m, 1.2 m, lens 46 | the victim frozen mid-swing (clip speed 0). He turns his back on him (step mode, as 南's turn) and lowers the blade, slowly, to hang (54 f) | silence; cloth only | the shot the cinematic is for (A: the slow lowering). P: 6 m |
| 110-116 | on the victim, front, 2.6 m, 1.4 m, lens 50 | a white seam opens down him from crown to floor; f112 the Konpaku shatters | negative 2, `cine-shatter`, manga 10 | the model untouched: the seam is drawn over a `silhouette-black` |
| 116-140 | low behind the victim, past him to Yamamoto's back: 3.6 m, 0.4 m, lens 40 | fire bursts from the seam and parts left and right (a V); a scorch line runs away behind him along the floor; `:sh-crumple`, then `:sh-down` | SL7 at scale, T2; shake 0.3; the boom 4 f late | |
| 140-156 | wide side, 7 m, 1.6 m, lens 44 | he has not looked back. The blade hangs | caption exits f140; embers | P: 9 m |

#### 21.5.4 What today's API cannot do as written

| # | Beat | Gap | Proposed way |
|---|---|---|---|
| 1 | 5.1's nine columns, 5.2's twelve pillars | the fx batch holds 16384 vertices; K4's probe overflowed once (§19.3 dev 10) | a cinematic pillar of ≤ 200 vertices (no crown); `fx-dropped 0` on the stats line is a check |
| 2 | 5.2's floor pattern | no helper draws rings and spokes growing | one `defun-fast` look, lines by `%ya-line` (yama-cine.lisp) |
| 3 | 5.3's seam on the victim | the body cannot be split | a white `toon-ribbon` over `silhouette-black` (CINE-END restores it) |
| 4 | 5.3's turn, 5.2's stillness | step-mode moves of the actors | as 南 / 西: CINE-SAVE gives the places back |
| 5 | the captions | 撫 焱 熱 missing (F9) | the offline bake in S5; the re-bake of the old CHARS byte-identical first (§19.3 dev 3) |

### 21.6 Checks the batches prove

| Check | How |
|---|---|
| Presentation only | the native trials `tests/trials/yamamoto-core.lisp`, `-blaze`, `-bankai`: `combo-trial.py --log` identical to the base commit's, every line; the browser scripts `duel-yama-core.json` and `duel-yama-blaze.json`: every `duel hash`, `duel probe`, `duel yamamoto` and combat-log line identical to a base dist's. The only `yama.lisp` edits allowed: `:clip`, `:clip-s`, `:blend`, `:look`, the `:stances` list, `:smear`, hook wiring, debug commands |
| Heat is read, never written | the same proof (the blaze trials' HEAT lines are in the log), plus a host check that the looks' file holds no `setf` of `gauges-meter`, a `yss-` slot or `hazard-data` (F5) |
| Shared files | `python3 tests/style-gates.py cvc dist/duel`: II / IK / KK identical to `tests/style-cvc-ref.txt` (it plays no Yamamoto: it proves `vfx.lisp` `vfx-smear`'s new branch, `body.lisp` if the glow gain is taken, and nothing else) |
| The looks gate (83 stills) | **the expected diff is written down before the run**: the YK match's stills (F7), and `select-3` if SL0 draws on the select screen's model. Pass = every other still byte-identical to BASE, and **the YK scenario's fighters and sim lines identical to BASE's** (S1-S4 move no tick). Then the YK stills are re-based and checked by eye. For S5's wiring commit the YK sim lines may shift after the first Shikai Kikon by +60 / +78 / +90 (look for a `cine SOUL-BREAK-CINE` line in BASE's YK log): re-base once, on that commit |
| Drawn reach = hit reach | the Shikai / 爆炎 rows of the host FK test become checks, ±0.15 m; J3 by the pommel, IKKOTSU by the fist; one-sided rows (NS3c, the SA) never over by 0.15; the `known-off` list empty after S3. Cast checks for the hazard segments (§3's last column) and stance 3's planted point |
| Looks = footprints | each look's ground edge against §2's radius / width in a top-down still, at T0 and T2 (the edge must not move with heat); a host check that any speed constant in a look equals the move's `:speed` |
| Link frames | the tip's jump on each link frame, before / after (§18.3's table), from the trials' ticks |
| 緩急 | the tip's speed per frame for J1, NS1a, NS2c, NS3a and NS3c (NS3c's proof is the opposite: 0 until the 2-frame snap) |
| 0 B a frame | a consing line per new look, tier and stance (87448's pattern; a second probe so its draws do not overflow the batch), `fx-dropped 0`, no row "(dropped)" |
| Host tests, pkgcheck, debug ranges | ALL PASS; `unit-names` (new clip and look names grepped first); new debug numbers claimed in DUEL_GAMEPLAY first: the free 87416-87419 (NS3 a / b / c, the SA on their own) and 87460-87489 (the AS segments, 爆炎's segments, the three cinematics) |
| Stills | per segment and per stance: match camera + side (2109), landscape + portrait (`--mobile --size 390x844`); 8-frame strips side + front; one still per cinematic beat, both aspects |
| Build, smoke | `./build.sh duel` last, `run.mjs` exit 0 |

No balance gate (the user, 2026-10-29). Bounded waits only in every brief; never `pkill -f` / `pgrep -f`.

### 21.7 Questions for the user (AskUserQuestion; recommended first)

| # | Question | Options | Consequence |
|---|---|---|---|
| Q1 | 花熱量時，火焰的大小差多少？ How far apart are heat 0 and a full spend? | **a. Clear but moderate (recommended)**: heat 0 is real fire at 60 % height, orange only; a full spend is full height with a white-hot core. **b. Extreme**: heat 0 is low embers (35 %), a full spend towers (130 %) and whites out. **c. Colour only**: the same size, orange to white | a: the hit box is always fully drawn, the spend reads by the core. b: the strongest read of Y3, but small fire undersells an unchanged hit box and tall fire hides the foe from behind. c: the safest for the camera, the weakest read. The ground edge never changes in any of them |
| Q2 | 爆炎要有自己的架式與毀魂技演出嗎？ Does 爆炎 get its own stances and Kikon cinematics? | **a. The Shikai's, in 爆炎's dress (recommended)**: same stances, same three cinematics, shown bared, scarred and white-hot. **b. One difference**: pointer 2's Kikon is ENNETSU JIGOKU only in 爆炎; the Shikai's becomes the cage round the victim alone. **c. Its own three cinematics**. **d. Its own stances too** | a: no new storyboard, no new tick cost (§4's reasons). b: +1 storyboard, and it settles Q3 as "cage". c: +3 storyboards and a batch, for a state of ≤ 10 s. d: the player relearns three reads |
| Q3 | 城郭炎上的毀魂技要多貼近原作的焱熱地獄？ How literal is ENNETSU JIGOKU? | **a. Literal (recommended)**: the pillars rise round both and he stands inside the dome, a dark shape in the fire, his hem alight (§5.2; no Reishi is taken). **b. The cage**: the ring, the walls and the dome close on the victim alone; he stands outside, pointing (ep. 215's Jōkaku Enjō). **c. Literal and it costs him**: a Reishi cost on the Kikon | a: §7.1's line as agreed in Y12; canon ch. 393. b: nearer the pointer's own name, a calmer image, and the caption becomes 城郭炎上 (bake 城 郭 炎). c is a rule change, not a look: it would need its own decision and gate |
| Q4 | 撫斬「晚一拍裂開」要畫到多明顯？ How literal is NADEGIRI's late split? | **a. A seam of fire (recommended)**: nothing at the hit but a hairline; 24 f later a seam opens through the victim's spot and the flames part in a V, scaled by heat. **b. Almost nothing**: the hairline, then he just falls; the split only in the cinematic. **c. The world splits**: the old look, a scorch line racing 8 m past him | a: reads as the result arriving late; the model is never cut. b: the purest economy, but a 110 / 200 damage finisher with no effect in play. c: the biggest, but 5.6 m of it lies beyond the 2.4 m reach (K5's caveat: decoration read as reach) |

The lead decides the rest from stills, as §15.4: stance 3's offset, the ring's and the dome's heights, the tornado's band count, frame
counts, every camera angle that an actor blocks.

### 21.8 Decisions (AskUserQuestion, 2026-11-20; the user's answer in bold)

| # | Question | Answer | Rejected |
|---|---|---|---|
| Q1 | Heat 0 against a full spend | **「明顯但適中」**: T0 60 % height, orange only; T2 full height with a white-hot core; the ground edge never moves | extreme (35 % / 130 %); colour only |
| Q2 | 爆炎's own stances / cinematics | **「沿用始解的，換爆炎裝扮」**: the Shikai's stances and three cinematics, drawn bared, scarred, white-hot | pointer 2 alone differs; its own three cinematics; its own stances too |
| Q3 | How literal ENNETSU JIGOKU is | **「照原作」**: pillars round both, the dome closes with him inside, his hem alight, a look only (no Reishi taken); caption 焱熱地獄 (bake 焱 熱) | the cage round the victim alone (城郭炎上); literal with a self-burn rule |
| Q4 | NADEGIRI's late split in play | **「火焰裂縫」**: a hairline on the hit, 24 f later a seam of fire parting in a V through the victim's spot, by heat; the model never cut | almost nothing; the world splits (8 m scorch) |

With all four the plan of §21.0-§21.6 stands as drafted. Batches S1 → S5 in order.

## 22. As built (art batch S1: the Shikai's FK checks and looks SL0-SL9, 2026-11-20)

S1 of §21.1 (the user, 2026-11-20: 「繼續」; the plan §21.0-§21.2, the decisions §21.8, Q1 「明顯但適中」, Q4 「火焰裂縫」): the Shikai / 爆炎 FK rows
as checks, the hitstop trace (§18.9's open item), then the looks SL0-SL9. Presentation only (proofs in 22.6). Code: `yama-look.lisp` (the
Shikai's looks, the heat tier, the 87449 probe), `yama-art.lisp` (YAMA-DRAW's Shikai / 爆炎 branch), `yama-vfx.lisp` (F5; the old placeholder
looks and the wave / pillar / dome / blade-fire looks only they used, deleted), `yama.lisp` (`:look` of NS1a / NS2a and 爆炎's copies, the
Shikai's `:smear 4`, debug commands), shared `vfx.lisp` (`vfx-smear` look 4) and `kit.lisp` (its docstring), tests `tests/duel-rules/art.lisp`
and `yamamoto.lisp`.

### 22.1 Drawn reach against hit reach (the host FK test, now checks)

The Shikai and 爆炎 rows of `tests/duel-rules/art.lisp` are checked as the Bankai's: two-sided within ±0.15 m, one-sided (never over by 0.15)
where a look carries the rest (NADEGIRI's seam SL7, TAIMATSU's halo SL8). TSUKABI (J3) is measured by the **pommel** (the `:weapon-r` joint
+0.285 m: MB-BLADE's kashira end), IKKOTSU by the **fist**. `known-off` must stay off (a fixed clip has to leave the list).

| Move | Drawn / volume end / delta (m) | Verdict |
|---|---|---|
| J1 / J2 (both forms) | 1.39 / 1.40 / -0.01; 1.35 / 1.40 / -0.05 | ok |
| J3 TSUKABI (by the pommel) | 1.12 / 1.40 / -0.28 | **known off** (not in §21.3's list: the tip prints 1.78, the pommel 0.28 short; S2) |
| 爆炎 J3 IKKOTSU (by the fist) | 1.21 / 1.40 / -0.19 | **known off** (S4) |
| AS1 (both forms) | 2.04 / 1.60 / +0.44 | known off (S2) |
| AS2a (both forms) | 1.66 / 2.00 / -0.34 | **known off** (not in §21.3's list; S3) |
| AS3a (both forms) | 1.35 / 1.80 / -0.45 | known off (S3) |
| AS3b (both forms) | 1.99 / 2.00 / -0.01 | ok |
| NS3a / NS3b (both forms) | 1.38 / 1.60 / -0.22; 1.39 / 1.60 / -0.21 | known off (S3) |
| NS3c / AS3c NADEGIRI (both forms) | 1.87 / 2.40 / -0.53 | one-sided (SL7) |
| SA TAIMATSU | 1.45 / 2.40 / -0.95 (爆炎 3.20 / -1.75) | one-sided (SL8) |
| the Kikon strikes (J1's clip) | 1.39 / 1.60 / -0.21 | known off (S3) |

`known-off`: J3, AS1, AS2a, AS3a, NS3a, NS3b, the two Kikon strikes, 爆炎's AS1 / AS2a / AS3a / NS3a / NS3b and IKKOTSU (14 moves). The
hazard segments (NS1a-c, NS2a-c, AS2b) have no blade window; their cast checks belong to the clips (S2 / S3).

**F10, confirmed by the print.** IKKOTSU's clip `ya-ikkotsu` has its S at f8 on a move whose S is f9 (no `:clip-s`); the fist ahead per frame
f6-f12: 0.69 0.98 1.19 1.21 1.21 1.20 1.20. The punch lands a frame before the hit window opens and holds through it (the clip's A covers f8-f11),
so the drawn reach in the window is the hold's 1.21 m: a frame early, not a missed hit. S4 re-keys it at S9.

### 22.2 Do move-frame looks lag the hit by the hitstop? No: they freeze on the hit frame

Code: during a hitstop `sim-step` runs only `pilot-read` (`main.lisp`): FIGHTER-SYSTEM (the move frame `fighter-sf`, `main-phase-step`, and the
clip's `anim-advance`) and HAZARD-SYSTEM (a hazard's delay and age) do not run, while the picture is drawn every frame. A hit is applied in
HIT-SYSTEM on the step its frame is reached (the fighters step first), so the frame drawn on the hit's step is already the hit frame, and it is
drawn for the whole hitstop. Evidence, a native trace (a scratch runner on the prelude: per step `*hitstop*`, P1's move frame, his hazards):

| Hit | Steps |
|---|---|
| NS3c NADEGIRI (melee, S14) | sf 13 (hitstop 0) → **sf 14, hitstop 8** (the hit) → sf 14 for 8 more steps (hitstop 7 .. 0) → sf 15 |
| NS1b's column (:ya-col, delay 13) | delay 1 age 0 (sf 27) → **delay 0 age 0, hitstop 8** (the hit, sf 28) → age 0 for 8 more steps → age 1 |
| SA TAIMATSU (melee, S16, a 4 f hitstop) | sf 15 → **sf 16, hitstop 4** → sf 16 for 4 more steps → sf 17 |

So a look keyed on the move frame or the hazard's age does not lag; it **freezes on the hit frame** for the hitstop (9 drawn frames for a heavy
hit), as the body does (the `sa-hit` still shows SL8's halo whole inside the SA's hitstop). K3's still (§18.7: NS2a's S still showed the pose
before S and no flare): the pose is FEEDBACK's `(hold-pose att 3)`, which draws the attacker's cached pose (the frame before S) for 3 frames
after his hit (read in the code); the missing flare likely the shot landing on S-1, since the script timed it from the key press (input
latency; inferred, not traced). The consequence for the looks, built in: **every look's hit frame draws the full hit
extent** (a hazard's age 0 after its delay, the move's S), since that frame is what the player sees during the freeze: the column is at full
height on its eruption frame, the dome closed on its first frame, the SA's halo at its reach on S16 (it ignites over f12-15), AS1's burst whole
on S10. A look that grows on its hit frame would be frozen small while the hit lands at the volume's edge.

### 22.3 The looks

Colour (§21.2): FIRE the mass, EMBER the backing and every floor mark, INK the shadow side of the tornado and the dome and the SA's dark behind
him; white-hot (HIT) only as the core of a segment that paid heat. No REIATSU yellow (the smear: look 4). Every fire shape is a ribbon (an
along shape) with heat lanes 0.3 .. 0.12, which keeps the FIRE palette's own pale-yellow core out (the toon shader draws it where the heat lane is
near 0.7): the only core is the tier's. Heat tiers (`ya-heat-tier`, host-checked): T0 paid 0, T1 part of 25, T2 a full 25 or any 爆炎 segment; T0
60 % of the height and of the tongues and no core, T1 80 % and a white core 30 % of the width, T2 100 %, the core 60 % (over each tongue's lower
half, its root), and an EMBER scorch for 30 f. The floor marks never move with heat (the top-down stills, 22.5).

| # | Look (function) | Footprint (= the sim's) | As built |
|---|---|---|---|
| SL0 | the blade's fire (`yama-blade-fire`, from YAMA-DRAW) | none | the sheath, three tongues on twos and a warm additive line (no white centre: negative alphas), `%blade-fire`'s drawing revived on f32vec ends (the `:weapon-r` joint at -0.95 / -0.25 m: the blade's length and base); power 0.5 at rest, 1.0 from a move's start to S+A, the tier's share in an NS, x1.3 and always cored in 爆炎; scraps only inside a move (none at rest: the cosmetic stream is not drawn from there); off on the intro's cane (the model's weapon is not `:ryujin-jakka`), off in 撫斬's stance (the idle clip `:ya-st-cane`), off at alpha < 0.5 |
| SL1 | NS1a's spiral (`yama-spiral-look`) | the :wave box 2.0 m across, 1.0 m along | two FIRE strands wound round the lane's axis (10 segments each, turning on twos) over an EMBER streak; a rolling head of six tongues whose front is the box's (x + 0.5 m); the tail up to 2.5 m behind, only over the lane crossed; the floor an EMBER strip as wide as the box from its front back under the tail; T2 a scorch over the last 30 f of the lane |
| SL2 | NS1b's ghost lights and column (`yama-column-look`) | the disc r 1.2 | the delay: an EMBER ring on the disc's edge pulsing on twos, five small flames 0.3-0.8 m over it circling inward (their clock: the move's :delay 13, a host-checked constant); the eruption: one FIRE column as wide as the disc at its foot, tapering to a crown of six tongues, 2.4 m x the tier (2.4 = *YA-FIRE-H*, the hit's height, at T2), EMBER behind, full on age 0; it erodes 12-30; shorter and thinner near the lens |
| SL3 | NS1c's tornado (`yama-tornado-look`) | the :wave box 3.5 m across, 1.0 m along | four stacked tilted bands of 12 segments turning on twos, FIRE on the camera's side, INK on the far side, gaps between them; the lowest band is the box itself (an ellipse 1.75 m across, 0.5 m along), the upper ones narrow across, up to 3.2 m x the tier; an EMBER stripe climbing between bands; the floor the box as an EMBER patch; T2 the scorch 30 f back |
| SL4 | NS2a's lance (`yama-lance-look`) | the :wave box 1.2 m across, 1.0 m along | a FIRE lens at 1.1 m, its point the box's front, 2.4 m long (its first 8 f its tail at the blade, 1 m ahead of him), an EMBER backing lens, tongues off its back; the floor an EMBER patch the box's size under the point and a thin EMBER scorch line over the last 20 f of the lane |
| SL5 | the burning ring (`yama-ring-look`) | the band r 1.6 ± 0.25 | the floor ring exactly the band (EMBER); 24 tongues on it, 1.0 m on the camera's side and 1.4 m on the far side x the tier, coiling in both ways from the point nearest him over 4 f; its charge from HAZARD-HITS-LEFT: 2 full, 1 thinner, lower and 70 % of the tongues, 0 the embers only; the last 15 f gutter; tongues sink near the lens |
| SL6 | the dome (`yama-dome-look`) | the disc r 1.6 | 12 tongues from the disc's edge leaning in, closed (2.4 m x the tier) on its first frame, INK backings on the far side, gaps between; holds to 16, the walls fall open and erode by 40; an EMBER ring on the edge; T2 a scorch disc |
| SL7 | NADEGIRI (`yama-sk-moves` code 1) | melee r 2.4, 100 deg | on S and S+1 one INK hairline (3 cm) across the arc at neck height, nothing else; from f38 (S+24) to f52 the seam: an INK + EMBER line on the floor along his facing from 0.6 m to 2.4 m, 14 tongues parting left and right (a V) rising toward 2.4 m ahead, by tier; no spark, no shake |
| SL8 | TAIMATSU's halo (`yama-sk-moves` codes 2 / 3) | melee r 2.4 (爆炎 3.2), 360 deg | 18 tongues igniting round him from his facing over f12-16 and out to the reach by S16, standing to f23, fading to f27; an EMBER ring on the reach's edge from f14; an INK disc behind him (his silhouette dark); tongues shrink near the lens |
| SL9 | J3's pommel, AS1's burst (`%ya-pommel-fire`, code 5) | J3 r 1.4; AS1 r 1.6, 90 deg | J3: two small tongues on the pommel f7-12; AS1: SL1's corkscrew (two strands of 5) from 0.2 m to the reach 1.6 m at 1.1 m, whole on S10, fading to 14 |
| — | the smear (`vfx-smear` look 4, the kit's `:smear 4`) | none | a FIRE comet half the width with one orange FLAME hairline; 爆炎 inherits it until its own trail (S4) |
| — | NADEGIRI's split entity (`yama-nade-look`) | — | draws nothing: no more stamp, no write to its data (F5); the entity stays (the hash counts hazards, F6) |

### 22.4 Deviations, each with its reason

1. **SL3's floor is the box, not a round 3.5 m band.** A :wave hits with a box 2 x size across and only 1.0 m along its travel (*WAVE-BOX*'s
   half-length 0.5): a round lowest band would paint 1.25 m of floor ahead of and behind the hit. The lowest band is an ellipse 3.5 x 1.0 and the
   floor patch the box; the upper bands may be rounder (in the air, not on the floor).
2. **Heads on the box's front.** SL1's and SL4's heads sit at x + 0.5 m (the box's front), not on the hazard's x (§21.2 wrote "on the
   hazard's x"): that is where the hit begins.
3. **The hit frame draws the full shape** (22.2): the column full on age 0 (no rise), the dome closed on its first frame (§21.2: "closes S18 to
   S+4"), the halo's opening moved before S (§21.2: 0.6 m to the reach in 2 f from S16), AS1's burst whole on S10.
4. **AS1's burst is anchored on the volume** (0.2 m to the reach 1.6 m), not "1.4 m from the tip": the borrowed clip's tip is 2.04 m out
   (known off), so a burst from it would draw 3.4 m of fire for a 1.6 m hit. S2's clip brings the tip to the volume.
5. **No fire discs.** A camera-facing fan disc in FIRE always draws the palette's pale-yellow core; the spiral's head is a ball of tongues.
6. **Fades on low-heat ribbons** run their presence over 0.69-0.97 (`%ya-k`): with heat lanes under 0.3 the shader erases an along shape whole
   below 0.7 (the first stills: the dome and the seam vanished at once in their fade).
7. **SL5's ring, the AS segments and the SA are T0 in the Shikai by rule**: NS2b pays no heat (no hit of its own: YA-NS-SPEND), an AS or the SA
   pays none. Their stills are one heat. 爆炎's tier comes from its owner's form at the drawing (T2), so a 爆炎 hazard still alive after the form
   ends drops to its paid tier.
8. **SL7 is drawn from NADEGIRI's move frames** (F6), so the seam goes with the move if he is struck in its recovery; the seam runs along his
   facing from 0.6 m to the reach (the V opening forward), the floor line through where the victim stood.
9. **爆炎's ENNETSU borrows SL3** (its `:look`), its T2 scorch measured at NS1c's 10 m/s (it moves at 12): S4 gives it the rows of pillars.
10. **Lights are small and do not follow heat** (radius 3-4 m, the same intensity at every tier): the first stills' 6-7 m lights lit a pale disc
   on the floor round every look, and a light growing with the tier read from above as a footprint growing with heat.
11. **Deleted, unreferenced after S1**: the five placeholder looks in `yama-vfx.lisp` (their names reused by the new ones, the old wave look
   left), `vfx-fire-wave` (+ `*wave-ghosts*`), `vfx-fire-pillar`, `vfx-fire-dome` (+ `*dome-last*`), `%blade-fire` / `vfx-blade-fire` (its
   drawing lives on in SL0), and a stray `>>>NEW` line from e0069c2c1. `vfx-fireball`, `vfx-fire-cone` and the stamps stay (not S1's).
12. **The probes share one row macro**: 87448's local `cons-per` became `%ya-cons-per` (the same expansion: 87448's line is unchanged), used by the
   new 87449 (`yama-shikai-consing`). The row macro now takes the bytes before it formats the row's name: the first builds made the hazard
   rows' names at run time inside the measured span and read 864-872 B a row of 10 draws (by the name's length: the looks consed nothing);
   the names are now made at expansion and the count is taken first.
13. **The SL5 charge states 1 and 0** are in the probe, not in the stills (a crossing needs the victim to walk out of the ring).

### 22.5 Stills (untracked)

`tests/scripts/duel-yama-s1.json` / `-phone.json` (`tests/scripts/duel.py`'s `yama_s1_script`): each segment on its own (87410+i, 87416+i,
87460) after its heat (87500+h), the behind camera then the SIDE camera (2109), landscape and portrait (`--mobile --size 390x844`, the deck on):
`tests/shots/duel-yama-s1-<still>-h<0|12|25>-<behind|side>[-phone].png` for `spiral-a`, `spiral-b`, `column-tell`, `column-erupt`, `column-late`,
`tornado-a`, `tornado-b`, `lance-tied`, `lance-b`, `dome-hit`, `dome-hold`, `dome-open`, `nade-cut`, `nade-seam`, `nade-late`; one heat:
`ring-coil`, `ring-full`, `sa-ignite`, `sa-hit`, `sa-fade`, `as1-burst`, `as1-late`, `j1-smear`, `j3-a` / `-b` / `-c`, `rest-p1` / `p2` / `p3`,
`blaze-rest`, `blaze-spiral`, `blaze-sa`. From above (87480 + 87481, landscape): `tests/shots/duel-yama-s1-top-<spiral|column|tornado|lance|dome>-h<0|25>.png`,
`-top-ring-h0`, `-top-sa-h0` (with 2103's melee volume). Contact sheets: `tests/shots/duel-yama-s1-heat-sheet.png` (rows the stills, columns the
three heats x the two cameras), `-misc-sheet.png`, `-top-sheet.png`, and `-heat-sheet-phone.png`, `-misc-sheet-phone.png`.

What the stills show, checked by eye: the tiers read apart in height, share and core from both cameras (T0 orange only, T2 white-cored); from
above every floor mark sits on the cyan footprint at T0 and at T2 alike (the spiral's strip and the tornado's lowest band on the box, the
column's and the dome's ring on the disc, the ring's floor on the band, the halo's ring on 2103's 2.4 m volume); the column's eruption still is
full height (the hit frame); the stance-3 still has no fire; the smear is orange, no yellow. Not by eye: NADEGIRI's 3 cm hairline is under the hit
spark from both match cameras (the cut frame is the hit frame); the black radial marks under him in the later stills are the 爆炎 entry's
scorch (FEEDBACK `:hellfire`'s `stage-mark`, kept for the round), not an S1 look.

### 22.6 Checks (all on the final build)

| Check | Result |
|---|---|
| Presentation only: the native trials | `tests/trials/yamamoto-core.lisp` (241 lines of `combo-trial.py --log`), `-blaze` (268), `-bankai` (513): identical to 3a8ef27f's, every line |
| Presentation only: the browser | `tests/scripts/duel-yama-core.json` (110 lines) and `duel-yama-blaze.json` (34): every `duel hash`, `duel probe`, `duel yamamoto` and combat-log line identical to a dist built at 3a8ef27f |
| Heat is read, never written | the trials above (their HEAT lines) and the new host check: no `setf` / `incf` / `decf` / `push` / `remf` of a `gauges-` or `yss-` slot or of `hazard-data` in `yama-look`, `yama-vfx`, `yama-cine`, `yama-art` (it flags the old F5 write when run on 3a8ef27f's `yama-vfx.lisp`) |
| Shared files | `python3 tests/style-gates.py cvc dist/duel`: II / IK / KK identical to `tests/style-cvc-ref.txt` (33 / 28 / 27 lines; `vfx-smear`'s look 4) |
| The looks gate | `tests/style-gates.py looks BASE dist/duel --jobs 4`, BASE a dist built at 3a8ef27f. The expected diff, written before the run: the YK match's stills with Yamamoto on screen (F7) and the select still that shows him (P1's cycle from Ichigo: I, H, Y, K, so select-2). Result: exactly those 8 differ, `menus/select-2` and `cvc-yk/intro`, `start`, `w0-0`, `w1-0`, `w1-1`, `w2-0`, `w3-0`; the other 75 byte-identical (noise floor 0); `cvc-yk fighters` and `cvc-yk sim lines` (12) PASS. Not re-based here: the lead's call (§21.6) |
| Host tests | ALL PASS, 4152 checks (+47: the Shikai / 爆炎 FK rows, the known-off guard, the no-write check, the look constants against the sim, the heat tiers, the smear on the Shikai and 爆炎) |
| pkgcheck, debug ranges, warnings | as main (the one `DUEL::APP` line); `tests/debug-ranges-check.py` 88 ranges, 0 errors (87416-87419, 87449, 87460-87465, 87470-87481 claimed in DUEL_GAMEPLAY "Debug commands"); the compiler's warnings the same set as main's build |
| 0 B a frame | debug 87449, every row 0: `spiral-t-0/1/2`, `lance-t-*`, `column-t-*`, `column-tell`, `tornado-t-*`, `ring-hits-0/1/2`, `dome-t-*`, `spiral-owned`, `blade-rest`, `blade-move`, `blade-ns-t2`, `blade-blaze`, `pommel`, `nade-cut`, `nade-seam-t0`, `nade-seam-t2`, `halo`, `halo-blaze`, `as1`, `tier-move`, `tier-hz`, `smear-4`; no row "(dropped)"; `fx-dropped 0` on every stats line of both stills runs. 87448's line unchanged from BASE's in the same scene: its 南 cinematic rows read 80 B on BASE too when P1 is not in the Bankai (they are 0 in K4's / K5's runs, set up in the Bankai) |
| Build, smoke | `./build.sh duel` (then `git checkout -- vendor`), `run.mjs --secs 8` exit 0 |

### 22.7 Open

- **For the user's eyes** (the sheets): whether T0 / T1 / T2 read apart at play distance (Q1's "明顯但適中"); the dome's T2 (twelve tongues each
  with a white root read as stripes); the tornado's tilted bands and their INK far side; the SA's INK disc behind him; the spiral at 8 m.
- S2 / S3 empty `known-off` (J3's pommel, AS1, AS2a, AS3a, NS3a / NS3b, the Kikon strikes); S4 IKKOTSU (F10) and 爆炎's own looks (the trail,
  ENNETSU's rows, the tornado's lean); S5 the cinematics on 87482-87489.
- SL5's charge states (1 hit left, 0) are proven by the probe only.
- NADEGIRI's hairline cannot be seen under the hit spark from the match cameras; a stronger mark on the cut frame would need the spark's
  owner (FEEDBACK, shared).
- The SA's frame 0 against its six predecessors (§18.9) is unchanged.

### 22.8 Merged (the lead, 2026-11-20)

Merged into main as built. The lead re-ran the fast checks on the merge: host tests 4152 ALL PASS, pkgcheck as before, debug ranges 0 errors,
build, smoke exit 0, `--cvc` II / IK / KK identical. Playtest page v454 (v453 the same build, v454 adds the manual line). **The looks gate is re-based here**: its 8 changed stills are the expected
YK / select-2 ones (YK sim lines identical), so from this merge on BASE is a dist built at this merge, and the pass rule is again 83 / 83
byte-identical until S5's wiring (§21.6) re-bases YK again.

## 23. As built (art batch S2: the Shikai's stances, NA and pointer 1, 2026-11-20)

S2 of §21.1 (the user, 2026-11-20: 「繼續」; the plan §21.3, the decisions §21.8): the three Shikai stances, J1 HISEN at its S14 with a held
tell, J2 reused, J3 TSUKABI's frame 0 and its pommel, pointer 1's NS1a / NS1b / NS1c and AS1, each on a clip at its move's S with frame 0 the
pose its link lands on. Presentation only (proofs in 23.7). Code: `yama-art.lisp` (the clips and their named landing poses), `yama.lisp`
(`:clip`, three dropped `:clip-s`, J1's `:blend 4`, the `:stances` comment), tests `tests/duel-rules/art.lisp` and `yamamoto.lisp`, the art
viewer `tests/duel-view.lisp` (the Shikai's clips on his Shikai body) and the still scripts.

### 23.1 What was built

| Slot | Clip | As built |
|---|---|---|
| Stance 1 不知火 | `ya-shiranui` re-keyed (2.4 s, 4 keys; was a 0.5 s 2-key charge loop) on the new `:ya-st-shiranui` | sunk (knees 40) and side-on (root yaw -25), the hilt drawn back at his right hip (the hand 0.40 m right, 0.85 m up), the blade level along the lane (the tip 0.90 m ahead at 0.89 m); a slow breath that moves the tip under 2 cm |
| Stance 2 城郭炎上 | `ya-st-enjo` re-keyed (4 keys) on the new `:ya-st-jokaku` | upright (spine 2), the arm locked out at shoulder height (the hand 1.33 m up), the blade level at the foe (the tip 1.70 m ahead, 1.34 m up) |
| Stance 3 撫斬 | `ya-st-cane` re-keyed (4 keys) on the new `:ya-st-nade` | upright, the head bowed (the eyes shut), the hand on the hilt of the blade stood point-down at his right front: the tip on the plaza 0.28 m right, 0.22 m ahead (y -0.01) at every phase of the loop (only the head breathes); no fire (YAMA-DRAW's rule, unchanged) |
| J1 HISEN | **`ya-hisen`** (new, S14; the move's `:clip-s 9` dropped, `:blend 4`) | from the form idle the charge f1-9 a key a frame, the arm's side and the wrist leading, the flex and the elbow lagging, to the wrist cocked high right (the feet still); held f10-12 (a 1° tremble); released f13-14 into the kept `:ya-q1-hit` (the tip 1.39 m); on through f15 (`:ya-hisen-thru`, AS1's first frame) to S+A f17 (`:ya-hisen-a` = J2's first frame) |
| J2 KAESHIBI | `ya-q2` reused, byte-identical | J1's S+A pose carries J2's frame-0 numbers, so the link lands with no jump |
| J3 TSUKABI | `ya-tsuka` re-keyed | frame 0 `:ya-q2-a` (J2's f11 as `ya-q2` draws it); the wind-up f1-3 a key a frame to the kept wind pose (f4-7); the hit pose turned: the wrist over, the blade laid back under the forearm (the tip 0.33 m ahead), the pommel leading at the face's height, 1.40 m ahead |
| NS1a | **`ya-n1a`** (new, S22; was `ya-f1` at x0.82) | frame 0 stance 1; the spiral gathers f1-14 (a key a frame, eased; the wrist circles the point 1.5 turns, growing then closing, as the hilt goes back past the ribs: `:ya-n1a-coil`); the coil held and trembling f15-19; the level thrust released f20-21, the arm locked on S (`:ya-n1a-hit`, the old SHIRANUI throw's pose: the tip 2.04 m ahead, 1.15 m up); held out to S+A (`:ya-n1a-land`) |
| NS1b | `ya-f2` re-keyed at S16 (`:clip-s 22` dropped) | frame 0 `:ya-n1a-land`; the point dropped onto the plaza ahead by f8 (`:ya-n1b-plaza`: 1.16 m ahead), held f8-12 (the tell); lifted through level (f14, the old hit pose) onto his toes, the blade straight up on S (`:ya-n1b-hit`, the tip 2.78 m up), held up through the active window to S+A (`:ya-n1b-top`) |
| NS1c | **`ya-n1c`** (new, S18; was `ya-sig` at x2.2) | frame 0 `:ya-n1b-top`; the blade tilted back (f1-3), then the wrist alone circles its tip once over his head, the hand still above it and the blade 50° off upright (behind f3, his left f6, ahead f9, his right f12: keys every 45°, linear, deviation 4); held at his right f13-15; flung forward and down f16-17 as the torso turns in, the tip 1.65 m ahead on S (`:ya-n1c-hit`) |
| AS1 | **`ya-as1`** (new, S10; was `ya-shiranui-throw` at x0.2) | frame 0 `:ya-hisen-thru`; the hilt pulled back to the ribs f1-6 (a key a frame, `:ya-as1-coil`), held f7-8, a short corkscrew thrust (the wrist rolls 30° as it goes), the tip 1.60 m ahead on S (`:ya-as1-hit`) |
| The smear | S1's look 4 | every new clip is a Shikai move: it draws look 4 (the kit's `:smear 4`), unchanged |
| 爆炎 | its `defmove-copy`s | `ya-b-j1` / `-j2`, `ya-b-n1a`-`c` and `ya-b-as1` play the same clips (their FK rows below); IKKOTSU and ENNETSU are S4's |

Deleted, unreferenced after S2: `ya-sig` and its three poses, `ya-shiranui-throw`, `:ya-throw-hit`, `:ya-shiranui-coil`. Kept: `ya-q1` (NS3b
still plays it at `:clip-s 9`), `ya-f1` (AS3b's), `ya-enjo` (pointer 2's), the stance clips' names (YAMA-DRAW keys SL0's absence on
`:ya-st-cane`; the `:stances` list is host-checked).

### 23.2 Drawn reach against hit reach (the host FK test)

| Move | Before (S1, §22.1): drawn / volume end / delta | After | Verdict |
|---|---|---|---|
| J1 (both forms) | 1.39 / 1.40 / -0.01 | 1.39 / 1.40 / -0.01 | within ±0.15 (its own clip, the same hit pose) |
| J2 (both forms) | 1.35 / 1.40 / -0.05 | 1.35 / 1.40 / -0.05 | within ±0.15 (unchanged) |
| J3 TSUKABI (by the pommel; both forms' rows) | 1.12 / 1.40 / -0.28 **(known off)** | **1.40 / 1.40 / +0.00** | within ±0.15: out of `known-off` |
| AS1 (both forms) | 2.04 / 1.60 / +0.44 **(known off)** | **1.60 / 1.60 / -0.00** | within ±0.15: out of `known-off` |
| the Kikon strikes (J1's clip) | 1.39 / 1.60 / -0.21 (known off) | 1.39 / 1.60 / -0.21 (known off) | J1's copies: they follow its clip; S3's own `ya-strike` |

`known-off` left (11): AS2a, AS3a, NS3a, NS3b, the two Kikon strikes; 爆炎's AS2a, AS3a, NS3a, NS3b and IKKOTSU (S3, S4).

### 23.3 緩急: the tip's speed per frame (m a frame, the clip's FK at the root, ease-out cubic; the move's slide not included)

| Move | Charge | Hold | Release → S | After S |
|---|---|---|---|---|
| J1 (S14), before (`ya-q1` S9 at x0.64) | f1 **2.15** (the first frame the fastest: from the stance with no blend), 1.06, 0.38, 0.21, 0.10, f6-10 ≤ 0.02 | (the old wind-up's hold, stretched) | f11 0.06, f12 0.46, f13 0.90, S 1.75 | f15 0.71 |
| J1 (S14), after | f1-9: 0.15 0.24 0.30 0.42 0.58 0.62 0.68 0.64 0.54 | f10-12: 0.02 0.03 0.03 | f13 0.32, **S 1.58** | f15 0.70, f16 0.05, f17 0.01 |
| NS1a (S22), before (`ya-f1` S18 at x0.82) | f1 0.72, 0.55, 0.40, 0.28, 0.18, then ≤ 0.10 | f8-15 ≤ 0.08 | f16 0.13, f17 0.81, f18 0.37, f19 0.10, f20 0.56, **f21 1.19**, S 0.91 | f23 1.10, f24 0.27 |
| NS1a (S22), after | f1-14: 0.04 0.09 0.08 0.11 0.17 0.16 0.12 0.14 0.19 0.17 0.10 0.04 0.05 0.06 (the wrist's circle) | f15-19: 0.01 0.03 0.04 0.02 0.02 | f20 0.38, **f21 0.74**, S 0.55 | f23 0.02, f24 0.00 |

J1's release (1.58) is now 2.3x its fastest charge frame (0.68), and the pop on f1 is gone. NS1a's release (0.74) is 3.9x the gather's
fastest frame (0.19) against a still hold; before, the old sweep's wind-up and its second swing (f20-23: 0.56 1.19 0.91 1.10) outran it.
J1's charge has one long arc to travel (the point from the plaza to over the right shoulder, 4.1 m over 9 frames), so its frames cannot all
be slow: the staggered channels flatten its middle (0.74 → 0.68 a frame) and the f13 key was moved back toward the cocked pose so the last
frame carries the cut (S 1.25 → 1.58).

### 23.4 Link frames: the tip's jump on the frame the link lands (m)

Where the links land (§17.1 / §18.3, the trials' logs): an NS segment at its predecessor's S+A, a J link at S+A, an AS at the J's S+1.

| Link (lands on) | Before | After | The new clip's first frames (f1-4) |
|---|---|---|---|
| J1 > J2 (J1 f17) | 0.03 | 0 | 0.33 0.13 0.06 0.01 (J2's own) |
| J2 > J3 (J2 f11) | 1.81 (J3 started from the stance) | 0 | 0.51 0.81 0.87 0.64 (the wind-up, a key a frame; it was 1.40 on f1 with one key) |
| J1 > AS1 (J1 f15) | 1.22 | 0 | 0.12 0.17 0.17 0.19 |
| stance 1 > NS1a (f0) | 1.11 | 0 (at any phase of the stance's loop: 0.016 at most) | 0.04 0.09 0.08 0.11 |
| NS1a > NS1b (NS1a f24) | 1.76 | 0 | 0.41 0.40 0.32 0.23 |
| NS1b > NS1c (NS1b f29) | 1.13 | 0 | 0.34 0.35 0.35 0.36 |
| stance 1 / 2 / 3 > J1 (f0) | 1.11 / 1.60 / 0.80 snapped, then `ya-q1`'s 2.15 on f1 | 0.96 / 1.65 / 0.59 snapped; with `:blend 4` the tip moves 0.13-0.30 / 0.20-0.53 / 0.49-0.98 a frame over f1-4 | (J1's own f1-4: 0.15 0.24 0.30 0.42) |

### 23.5 Cast checks (host, `tests/duel-rules/art.lisp`; x his right, y up, ahead)

| Move, frame | What | Test | Value |
|---|---|---|---|
| NS1a f22 | the tip | past the spiral's start (≥ 1.0 m ahead) at 0.9-1.3 m | -0.01 / 1.15 / 2.04 |
| NS1b f9, f12 | the tip | on the plaza (-0.2 ≤ y ≤ 0.05), 0.4-1.6 m ahead | 0.05 / -0.00 / 1.16; 0.05 / 0.01 / 1.17 |
| NS1b f16 | the tip | overhead (y ≥ 2.2) | 0.28 / 2.78 / 0.61 |
| NS1c f18 | the tip | flung past 1 m ahead | -0.20 / 0.86 / 1.65 |
| stance 3, its loop every 0.2 s | the tip | x 0.25-0.30, y ±0.05, 0.1-0.35 m ahead | 0.28 / -0.01 / 0.22 at every phase |
| J1, NS1a-c, AS1 | the clip | plays at x1, its S, S+A and end the move's (no `:clip-s`: F10's class of bug) | all five |

### 23.6 Deviations, each with its reason

1. **J1 has a new clip `ya-hisen` instead of `ya-q1` re-keyed in place**: NS3b (and 爆炎's copy) still plays `ya-q1` at `:clip-s 9`; re-keyed,
   NS3b's drawn pose and its known-off row would move in a pointer S2 must not touch. S3 gives NS3b its own clip; `ya-q1` goes then.
2. **J2 is byte-identical and J3's frame 0 is a new pose** (`:ya-q2-a`, `ya-q2`'s f11 sampled): `ya-q2` is also NS3a's and AS3's clip.
3. **J3's hit pose turned over, not only moved forward**: the old pose led with the tip (1.64-1.75 m ahead, the pommel behind the hand), so
   no forward step could put the pommel on the volume without the tip passing it by 0.4 m. The pommel now leads (the blade laid back under
   the forearm), at 1.40 m and the face's height (1.43 m up); the body's forward shift is 0.33 m (was 0.55). Its wind-up got three keys a
   frame apart (the link pose to the wind pose was a 1.40 m first frame).
4. **NS1c's whirl is a cone, not a level blade, keyed every 45°**: a level blade turned once by the wrist winds the hand's twist channel by
   360°, and the crossfade into the idle (channels linear; ANIM-PLAY wraps only the root's yaw) would unwind it as a visible spin; a lasso by
   the shoulder winds the arm's twist the same way. With the hand still over his head and the blade 50° off upright, the wrist's three
   channels oscillate and come back. 90° keys left the tip moving 0.27 / 0.53 a frame by turns; 45° keys 1.5 frames apart, linear, give an
   even 0.32-0.38. It ends at his right (the plan did not say where), so the fling is a diagonal down across him.
5. **AS1 reaches its volume with the body drawn back** (root -0.15 m, the elbow at 25°): a locked arm from where he stands puts the tip at
   1.76 m; point-blank, as the slot's archetype says.
6. **Stance 1's slow corkscrew of fire and stance 2's drip off the tip are not built**: they are new looks (yama-look.lisp), outside S2's
   allowed edits; S1's SL0 burns on both stances as before (open, 23.9).
7. **Stance 1 is side-on by the root's yaw (-25°)**, a still offset (the old placeholder had the same); NS1a turns him into the thrust (+10°
   on S): a 35° body turn, not a spin.
8. **J1's `:blend 4` reaches its copies** (the two Kikon strikes, 爆炎's J1): `defmove-copy` carries it; a look (`mv-blend`'s one reader is
   PLAY-CLIP). A host check lists the Shikai / 爆炎 moves that blend. From stance 3 the blended first frames still move 0.98 m at most (the
   planted blade swung up into J1's charge).
9. **The art viewer draws the Shikai's clips on the Shikai body** (`tests/duel-view.lisp` CLIP-OWNERS): before, a `ya-` clip that was not
   the Bankai's posed Ichigo and Kenpachi, and `ya-st-enjo` / `ya-st-cane` (prefix `YA-ST-`) the Bankai body. The K2 / K3 strip scripts'
   indices moved with the new and deleted clips and were regenerated.

### 23.7 Stills (untracked)

- In play: `tests/scripts/duel-yama-s2.json` / `-phone.json` (`tests/scripts/duel.py`'s `yama_s2_script`), the behind camera then the SIDE
  camera (2109), landscape and portrait (`--mobile --size 390x844`, the deck on): `tests/shots/duel-yama-s2-<still>-<behind|side>[-phone].png`
  for `stance-1`-`3`, `ns1a-gather` / `-coiled` / `-held` / `-release` / `-s` / `-land`, `ns1b-drop` / `-tell` / `-level` / `-s` / `-top`,
  `ns1c-behind` / `-left` / `-ahead` / `-right` / `-held` / `-fling` / `-s`, `as1-first` / `-coil` / `-held` / `-thrust` / `-s`, `j1-charge` /
  `-cocked` / `-held` / `-release` / `-s` / `-thru`, `j2-first`, `j2-s`, `j3-first`, `j3-wind`, `j3-s`, `as1-link-first` / `-coil` / `-s` (160).
- 8-frame strips, the art viewer (`dist/duelview` with `yama-art.lisp`): `tests/shots/duel-view-yama-s2-<clip>-<side|front>.png` for
  `ya-hisen`, `ya-q2`, `ya-tsuka`, `ya-n1a`, `ya-f2`, `ya-n1c`, `ya-as1` and the three stances (`tests/scripts/duel-view-yama-s2.json`,
  `duel-view.py`'s `yama_s2`).
- Contact sheets: `tests/shots/duel-yama-s2-triptych[-phone].png` (the stances, both cameras), `duel-yama-s2-sheet-<behind|side>[-phone].png`
  (every still), `duel-yama-s2-strips-<side|front>.png` (the strips).

Checked by eye: the three stances read apart from both cameras (the blade level at the hip in fire / the arm and blade out at the foe in fire
/ upright with no fire, the blade at his right front); NS1a's coil and thrust, NS1b's point on the plaza then the blade straight up, NS1c's
tip circling over his head and the fling, J3's pommel forward. Stance 3's blade is a thin unlit line: from the behind camera it shows at his
right, from the side camera barely, and in portrait hardly at all (the user's eyes: a faint ember on the point, a look, would be S3 / S4's).

### 23.8 Checks (all on the final build)

| Check | Result |
|---|---|
| Presentation only: the native trials | `tests/trials/yamamoto-core.lisp` (241 lines of `combo-trial.py --log`), `-blaze` (268), `-bankai` (513): identical to 90b84eb7's, every line |
| Presentation only: the browser | `tests/scripts/duel-yama-core.json` (111 lines) and `duel-yama-blaze.json` (35): every `duel hash`, `duel probe`, `duel yamamoto` and combat-log line identical to a dist built at 90b84eb7 |
| Shared files | `python3 tests/style-gates.py cvc dist/duel`: II / IK / KK identical to `tests/style-cvc-ref.txt` (33 / 28 / 27 lines) |
| The looks gate | `python3 tests/style-gates.py looks BASE dist/duel --jobs 4`, BASE a dist built at 90b84eb7 (S1 merged). The expected diff, written before the run from BASE's cvc-yk log: `cvc-yk/start` (his idle in stance 1), `w0-0` (NS1a's recovery), `w1-0` (NS1b), `w1-1` (NS1c), `w2-0` (a step out of stance 2), `w3-0` (NS1a); not `intro` (`ya-intro`) nor `menus/select-2` (the select model plays the form idle `:ya-stance`). Result: 5 differ, `cvc-yk/start`, `w0-0`, `w1-0`, `w1-1`, `w2-0` (8 px: the step's first frames out of the stance); `w3-0` is byte-identical (the still is a KIKON / PERFECT caption frame after his NS1a's hit; his drawn pose there is not the new clip's: read from the image, not traced); the other 78 byte-identical (noise floor 0); every scenario's fighters and sim lines PASS (`cvc-yk sim lines` 12). Not re-based here (the lead's call) |
| Host tests | ALL PASS, 4164 checks (+12: the five cast checks, stance 3's planted point, the five clips' frames against their moves, the Shikai / 爆炎 blend list); `known-off` without J3, AS1, 爆炎's AS1 |
| pkgcheck, debug ranges, warnings | as main (the one `DUEL::APP` line); `tests/debug-ranges-check.py` 88 ranges, 0 errors (no new debug number: the stills use 87014, 87030, 87100, 87300+p, 87401, 87410-87412, 87460, 2109); the compiler's warnings the same set as main's |
| 0 B a frame | debug 87449 every row 0; both consing lines (87449, 87448) identical to BASE's in the same scene (`duel-yama-s2.json` run on a dist built at 90b84eb7; 87448's 南 cinematic rows read 80 B on both with P1 not in the Bankai, as §22.6); `fx-dropped 0` |
| Build, smoke | `./build.sh duel` (then `git checkout -- vendor`), `run.mjs --secs 8` exit 0 |

### 23.9 Open

- **For the user's eyes** (the sheets): the three stances in play (above all stance 3's unlit blade from the side camera); whether NS1c's
  cone whirl reads as "the blade whirled over his head"; J1 from stance 3 (the planted blade swung up into the charge, 0.98 m on a blended
  frame); J3's pommel-first strike; NS1a's wrist circle as the spiral's gather.
- The looks: stance 1's slow corkscrew of fire and stance 2's drip (deviation 6), with S3 / S4's looks work.
- S3: pointer 2 / 3, AS2 / AS3, the SA, the Kikon strikes (`ya-strike`, then they leave `known-off`) and NS3b's clip (then `ya-q1` goes).
- The SA's frame 0 against its six predecessors (§18.9) is unchanged.

### 23.10 Merged (the lead, 2026-11-20)

Merged into main as built. The lead re-ran the fast checks on the merge: host tests 4164 ALL PASS, pkgcheck as before, debug ranges 0 errors,
build, smoke exit 0, `--cvc` II / IK / KK identical. Playtest page v456 (v455 the same build, v456 adds the manual line). The looks gate's 5 changed stills (cvc-yk start, w0-0, w1-0, w1-1, w2-0)
are inside the expected list, the YK sim lines identical: **re-based** at this merge (BASE = a dist built here) until S3.
The lead's call on deviation 6 (stance 1's corkscrew, stance 2's drip) and stance 3's faint blade: S3 adds them with its looks, an ember on
stance 3's point included if the user wants the blade to read (it stays "no fire" by §21.3 until then).

## 24. As built (art batch S3: pointer 2, pointer 3, AS2, AS3, the SA, the Kikon strikes and two stance looks, 2026-11-20)

S3 of §21.1 (the user, 2026-11-20: 「繼續」; the plan §21.3, the decisions §21.8; §23.9's open looks): every Shikai segment left on a borrowed
clip gets its own, at its move's S, with frame 0 the pose its link lands on (§21.3's table); TAIMATSU and NADEGIRI lose their root turns; the
Kikon strikes get `ya-strike`; pointer 1's and 2's stances get their fire. Presentation only (proofs in 24.8). Code: `yama-art.lisp` (the clips
and their named landing poses; YAMA-DRAW calls the stance look), `yama-look.lisp` (YAMA-STANCE-FIRE, YA-STANCE-TIER, the 87449 rows), `yama.lisp`
(`:clip` / `:clip-s` only), tests `tests/duel-rules/art.lisp`, the still scripts (`tests/scripts/duel.py`, `duel-view.py`).

### 24.1 What was built

| Slot | Clip (S / A / R) | Frame 0 (= the landing of) | As built |
|---|---|---|---|
| NS2a (tell) | `ya-enjo` re-keyed (20 / 2 / 22; was 20 / 2 / 30 on a move of R22) | stance 2 `:ya-st-jokaku` | the pointing arm drawn back to the shoulder like a spear f1-12, a key a frame (`:ya-n2a-cock`: the elbow out at the shoulder, the forearm forward, the blade level by the cheek, the tip 1.13 m ahead); held f13-17 (a 1-2 deg tremble); released f18-19, locked out on a short step on S (`:ya-n2a-hit`: the tip 1.88 m ahead at 1.33 m, the lance leaves it); held to S+A (`:ya-n2a-land`) |
| NS2b | **`ya-n2b`** (16 / 2 / 20; was `ya-enjo` at x1.25) | NS2a f22 `:ya-n2a-land` | the arm held out, the point settles f1-3; the wrist draws one circle with the point f4-13 (the hand's flex and side in quadrature, +-15 deg, a key every 45 deg, linear: the tip's circle 0.42 m across, no twist); a stop on S, the point dipped at the ring's spot (`:ya-n2b-hit`); `:ya-n2b-land` at S+A |
| NS2c (F11's tell) | **`ya-n2c`** (18 / 2 / 30; was `ya-f3`, the 360 deg spin drop, at x1.22) | NS2b f18 `:ya-n2b-land` | the blade raised point-up overhead f1-8, a key a frame (`:ya-n2c-up`, the tip 2.68 m up); held f9-15 (a tremble: fire climbs SL0); chopped down f16-17 to the level point on S (`:ya-n2c-hit`: the tip 1.83 m ahead at 1.30 m) |
| AS2a | **`ya-as2a`** (12 / 3 / 16; was `ya-enjo` at x1.67) | J2 f9 `:ya-q2-thru` (new: `ya-q2`'s f9 exactly) | the point brought down level at his right f1-6 (`:ya-as2a-cock`), held f7-9, flicked level R->L across his chest on a 0.2 m drawn lunge f10-12 (`:ya-as2a-hit`: the tip 1.90 m out, 7 deg left of ahead), on through S+2 (`:ya-as2a-thru`, 1.80 m at 31 deg left) |
| AS2b | **`ya-as2b`** (18 / 2 / 30; was `ya-f3`) | AS2a f15 `:ya-as2a-land` | NS2c's keys from its own frame 0 (generated from the same poses) |
| NS3a (tell) | **`ya-n3a`** (18 / 3 / 18; was `ya-q2` at x0.44) | stance 3 `:ya-st-nade` | the blade pulled up out of the plaza and levelled low at his right hip f1-12, a key a frame (`:ya-n3a-low`: the hand drawn back at the hip, the tip 0.86 m ahead at 0.78 m); held f13-16; a low rising jab f17-S (`:ya-n3a-hit`: the tip 1.68 m ahead at 1.14 m); the 1.0 m slide is the sim's, the legs make the lunge (the drawn root 0.1 m) |
| NS3b | **`ya-n3b`** (12 / 3 / 18; was `ya-q1` at x0.75) | NS3a f21 `:ya-n3a-land` | the blade drawn to his right at the waist f1-8 (`:ya-n3b-wind`), held f9, a level cut R->L at the waist on the step f10-S (`:ya-n3b-hit`: the tip 1.65 m ahead at 1.00 m), on through S+2 (1.60 m at 42 deg left) to his left (`:ya-n3b-land`); the 2.0 m slide the sim's (the drawn root 0.12 m) |
| NS3c NADEGIRI | `ya-nadegiri` re-keyed at S14 (14 / 4 / 34; the move's `:clip-s 20` dropped; the 185 deg root turn and the -360 end removed) | NS3b f15 `:ya-n3b-land` | the blade settles at his left hip, the eyes shut f1-6 (`:ya-nadegiri-draw`, the turn in the pelvis 14 / chest 28 deg, no root yaw); still f7-9; a 1 deg tremble f10-12; the snap L->R at the neck f13-S (two drawings; `:ya-nadegiri-hit` on a 0.3 m drawn lunge, the tip 1.94 m ahead at 1.43 m), on through S+2 to his right (37 deg); then the blade lowered over 20 f (f19-38) with the chest (-46 deg) and the head (-30) turned away to his right (`:ya-nadegiri-low`), held to f44, back to the stance by f52 |
| AS3a | **`ya-as3a`** (8 / 3 / 14; was `ya-q2`) | J3 f10 `:ya-tsuka-thru` (new: `ya-tsuka`'s f10, `:ya-tsuka-hit` with root f 0.323, arm flex 131.6) | the reverse-gripped blade cocked out off the little finger to his left front f1-7 (the hand twist kept 166-175 deg: the grip never changes), out on S (`:ya-as3a-hit`: the hand 1.10 m ahead, the tip 1.77 m out at 19 deg left), then the hilt pulled back across him R->L through S+2 (`:ya-as3a-pull`, 1.67 m at 34 deg left): the edge cuts on the pull |
| AS3b | **`ya-as3b`** (10 / 3 / 16; was `ya-f1` at x0.55) | AS3a f11 `:ya-as3a-land` | the blade flipped forward and dropped low at his right front f1-6 (the hand twist 175 -> 0: the flip is the motion), held f7; a rising cut to his high left as the chest turns f8-S (`:ya-as3b-hit`: the tip 1.91 m out at 1.58 m), on up to his high left (`:ya-as3b-land`, the tip 2.03 m up) |
| AS3c | **`ya-as3c`** (14 / 4 / 34; was `ya-nadegiri` at x1.43) | AS3b f13 `:ya-as3b-land` | NADEGIRI's keys from its own frame 0 (the settle comes down from his high left) |
| SA TAIMATSU | `ya-taimatsu` re-keyed (16 / 8 / 24; the root's 360 deg turn and its +360 end removed; `:ya-taimatsu-hit` kept, its yaw 0) | its own (the stance) | the eye-open tell f3; the blade carried once round him low, keys at f5 / 7 / 9 / 11 / 13 / 15, linear (the tip's bearing 30 / 88 / 147 / 208 / 262 / 320 deg: his right front, right, behind right, behind with the hand behind his back, left, left front; 0.2-0.85 m up), the chest turning with it (-8 .. -40 .. +15 deg); rising into the fan across the front on S (the kept hit pose); the order SL8's halo ignites in (front, right, behind, left) |
| the Kikon strikes | **`ya-strike`** (14 / 3 / 12; `ya-ns-strike` gets `:clip`, `ya-as-strike` inherits it) | J1's (its own frame 0, the move's `:blend 4` kept) | `ya-hisen`'s keys with the root drawn forward from the held tell into S (0.02 .. 0.08 m f9-12, 0.17 on f13, 0.25 on S, 0.24 at S+A): the tip 1.62 m |
| stance 1 不知火 (look) | YAMA-STANCE-FIRE code 1 | - | over SL0's rest sheath, a slow corkscrew of fire: two FIRE strands wound 1.5 turns round the blade (r 0.075 m x the tier's height share, widening toward the tip), turning once in 4 s; the tier's white core |
| stance 2 城郭炎上 (look) | YAMA-STANCE-FIRE code 2 | - | a small flame hanging off the point and three drops of fire falling 0.6 m from it in turn (one every 0.4 s, 1.2 s a fall), thinning and fading as they fall; the tier's core |
| stance 3 撫斬 | - | - | still no fire (§21.3; the user decides on an ember later) |

The stance looks' tier is the heat his next NS segment would pay (YA-STANCE-TIER: the gauge capped at 25, the same rule as YA-HEAT-TIER; 2 in
爆炎): T0 at heat 0, T1 below 25, T2 at 25 or more. They read the gauge and write nothing; they use the fx clock and HASH01, never the random
stream, so nothing else in a frame moves with them.

Deleted, unreferenced after S3: `ya-q1` (its hit pose `:ya-q1-hit` stays: `ya-hisen` and `ya-q2` use it), `ya-f1` (+ `:ya-f1-wind` / `-hit`),
`ya-f3` (+ `:ya-f3-cock` / `-hit`), `:ya-taimatsu-low`, the old `:ya-nadegiri-draw` / `-hit` (re-defined). `:ya-enjo-point`, `:ya-lean` and the
stance 2 / 3 poses moved up the file (the new pointer 2 / 3 poses are based on them; a pose must exist before a pose is based on it).
`ya-enjo` keeps its name (NS2a, and 爆炎's ENNETSU at `:clip-s 20` until S4).

### 24.2 Drawn reach against hit reach (the host FK test)

| Move | Before (§23.2): drawn / volume end / delta | After | Verdict |
|---|---|---|---|
| AS2a (both forms) | 1.66 / 2.00 / -0.34 **(known off)** | **1.90 / 2.00 / -0.10** | within +-0.15: out of `known-off` |
| AS3a (both forms) | 1.35 / 1.80 / -0.45 **(known off)** | **1.77 / 1.80 / -0.03** | within +-0.15: out |
| AS3b (both forms) | 1.99 / 2.00 / -0.01 | 1.91 / 2.00 / -0.09 | within +-0.15 (its own clip) |
| NS3a (both forms) | 1.38 / 1.60 / -0.22 **(known off)** | **1.68 / 1.60 / +0.08** | within +-0.15: out |
| NS3b (both forms) | 1.39 / 1.60 / -0.21 **(known off)** | **1.65 / 1.60 / +0.05** | within +-0.15: out |
| NS3c / AS3c NADEGIRI (both forms) | 1.87 / 2.40 / -0.53 (one-sided) | 1.95 / 2.40 / -0.45 | one-sided (SL7's seam) |
| SA TAIMATSU | 1.45 / 2.40 / -0.95 (爆炎 3.20 / -1.75) | the same (the hit pose kept) | one-sided (SL8's halo) |
| the Kikon strikes (both, both forms) | 1.39 / 1.60 / -0.21 **(known off)** | **1.62 / 1.60 / +0.02** | within +-0.15: out |
| 爆炎 J3 IKKOTSU (by the fist) | 1.21 / 1.40 / -0.19 (known off) | unchanged | **known off** (S4) |

`known-off` left: IKKOTSU alone (`'(:ya-b-j3)`). No slot needed a sim change. The arcs are kept too: every window's tip stays inside its move's
arc (AS2a 7-31 deg left of ahead in 120, NS3b 0-42 in 110, NADEGIRI 5-37 in 100, AS3a 19-34 in 120, AS3b 17-42 in 160).

### 24.3 緩急: the tip's speed per frame (m a frame, the clip's FK at the root; the move's slide not included)

| Move | Charge | Hold | Release -> S | After S |
|---|---|---|---|---|
| NS2a (S20), before (`ya-enjo` S20 R30) | f1 **1.23** (from the stance with no blend: the old clip's frame 0 was the idle), 0.41, 0.13, then 0 | f5-17 0 | f18 0.17, f19 0.02, **S 0.60** | f21 0.03 |
| NS2a, after | f1-12: 0.07 0.07 0.05 0.04 0.06 0.09 0.10 0.09 0.08 0.07 0.06 0.05 | f13-17: 0.01 0.02 0.02 0.03 0.02 | f18 0.22, **f19 0.37**, S 0.31 | f21 0.05, f22 0.01 |
| NS2c (S18), before (`ya-f3` at x1.22) | f1 **2.11**, 0.99, 0.33 (the jump off NS2b), then the spin 0.04-0.52 | - | f17 1.42, **S 2.12** | f19 0.23 |
| NS2c, after | f1-8: 0.19 0.27 0.32 0.34 0.32 0.28 0.22 0.15 | f9-15: 0.03 0.04 0.04 0.05 0.05 0.02 0.03 | f16 0.54, **f17 0.77**, S 0.63 | f19 0.05 |
| NS3a (S18), before (`ya-q2` at x0.44) | 0.19 0.12 0.08 ... (J2's wind-up slowed) | - | f15-18 0.26 each, **f19 0.62** (after S) | - |
| NS3a, after | f1-12: 0.16 0.22 0.25 0.26 0.26 0.26 0.25 0.24 0.22 0.21 0.19 0.13 | f13-16: 0.01 0.00 0.00 0.00 | f17 0.51, **S 0.54** | f19 0.02 |
| NS3c (S14), the opposite proof: before (`ya-nadegiri` at x1.43) | f1-6 0.06 0.02 0.29 1.06 0.59 0.22 (the old draw) | f7-11 ~0 | f12 0.42, f13 1.67, S 1.40, f15 2.14 (the turn) | - |
| NS3c, after | f1-6: 0.06 0.18 0.34 0.48 0.44 0.19 (the settle to the hip) | f7-12: 0.00 0.00 0.00 0.01 0.02 0.01 | **f13 1.84, S 1.51** (two drawings) | f15 0.47, f16 0.63, f17 0.03 |

NS2a's release (0.37) is 3.7x its fastest charge frame (0.10); NS2c's chop (0.77) 2.3x its raise (0.34); NS3a's jab (0.54) 2.1x its pull (0.26).
NS3a's pull has a long arc to travel (the blade turned up out of the plaza through 150 deg of wrist), and its frames are even, so its ratio is
the lowest; the jab was made longer for it (the hand drawn back to the hip, the tip 0.86 m ahead: 0.82 m to cover in two frames). NADEGIRI is
0 for six frames before the snap (f7-12: the tremble 0.02 at most), then 1.84 / 1.51.

### 24.4 Link frames: the tip's jump on the frame the link lands (m)

Where the links land (§17.1 / §18.3): an NS segment at its predecessor's S+A, an AS at the J's S+1, an AS segment at its predecessor's S+A.

| Link (lands on) | Before | After | The new clip's first frames (f1-4) |
|---|---|---|---|
| stance 2 > NS2a (f0) | 1.65 | 0 | 0.07 0.07 0.05 0.04 |
| NS2a > NS2b (NS2a f22) | 1.20 | 0 | 0.01 0.00 0.01 0.01 |
| NS2b > NS2c (NS2b f18) | 1.19 | 0 | 0.19 0.27 0.32 0.34 |
| J2 > AS2a (J2 f9) | 1.85 | 0 | 0.10 0.25 0.28 0.25 |
| AS2a > AS2b (AS2a f15) | 1.03 | 0 | 0.17 0.26 0.32 0.37 |
| stance 3 > NS3a (f0) | 1.37 | 0 | 0.16 0.22 0.25 0.26 |
| NS3a > NS3b (NS3a f21) | 1.83 | 0 | 0.03 0.12 0.24 0.42 |
| NS3b > NS3c (NS3b f15) | 0.90 | 0 | 0.06 0.18 0.34 0.48 |
| J3 > AS3a (J3 f10) | 1.25 | 0 | 0.08 0.12 0.17 0.23 |
| AS3a > AS3b (AS3a f11) | 1.81 | 0 | 0.30 0.54 0.41 0.91 (the flip) |
| AS3b > AS3c (AS3b f13) | 1.70 | 0 | 0.17 0.46 0.68 0.73 |
| 爆炎 NS2a > NS2b (b-n2a f22; NS2c's clip at x18/16) | 1.20 | 0.15 | 0.29 0.37 0.40 0.37 |
| 爆炎 NS2b > NS2c (ENNETSU, `ya-enjo` at x1.11) | 0.68 | 0.18 | 0.09 0.08 0.05 0.06 |
| NS1a f24 > SA | 1.73 | 1.73 | (the SA's f1-4: 0.10 0.04 0.01 0.31; was 1.14 on f4, the turn's start) |
| NS1b f29 > SA | 2.84 | 2.84 | |
| NS2a f22 > SA | 1.20 | 1.73 | |
| NS2b f18 > SA | 1.19 | 1.69 | |
| NS3a f21 > SA | 1.83 | 1.50 | |
| NS3b f15 > SA | 0.90 | 1.63 | |

The SA's six predecessors stay open (§18.9: one clip, one frame 0; a per-predecessor frame 0 needs a mechanism that does not exist). The
stances > J1 jumps are S2's (§23.4), unchanged.

### 24.5 Cast checks and guards (host, `tests/duel-rules/art.lisp`; x his right, y up, ahead)

| Move, frame | What | Test | Value |
|---|---|---|---|
| NS2a f20 | the tip | locked out past 1 m ahead | -0.00 / 1.33 / 1.88 |
| NS2c f9-14, AS2b f9-14 | the tip | overhead (y >= 2.2) | y 2.66-2.68 |
| NS2c f18, AS2b f18 | the tip | chopped to the level point: >= 1.0 m ahead at 0.9-1.5 m | 0.16 / 1.30 / 1.83 |
| the S2 five and the 14 S3 moves (NS2a-c, AS2a / b, NS3a-c, AS3a-c, the SA, both Kikon strikes) | the clip | plays at x1, its S, S+A and end the move's (F10's class of bug) | all; 爆炎's NS2b (NS2c's clip on a move at S16) its S scaled by `:clip-s 18` |
| every Shikai / 爆炎 move clip | the root's yaw | no key past 45 deg (the blade is carried, the body never turns) | all but 爆炎's entry pose `ya-hellfire` (S4's) |
| the looks file | heat / hazard data | read, never written (S1's walker) | none written |

### 24.6 Deviations, each with its reason

1. **NS2b's circle is 0.42 m across, not 0.50** (r 0.21 at the tip): the hand's +-15 deg in quadrature, as §21.3 asked by angle; the radius the plan
   wrote would need 18 deg. Read from the stills, not tuned.
2. **AS3a keeps the reverse grip and reaches 1.77 m** by cocking the blade out off the little finger to his left front with the arm out and a
   0.3 m drawn lunge (J3's pommel pose already stood 0.32 m forward): a blade laid back along the forearm cannot pass 1.0 m. The grip never
   changes in AS3a (the hand twist 166-175); AS3b's first six frames are the flip forward (175 -> 0), which is its motion (§21.3: "the blade
   flipped forward").
3. **TAIMATSU's carry passes behind his back** (f10-13, the hand 0.27-0.35 m from his spine axis): one right arm cannot carry a blade round
   him low otherwise, and a root turn is the red flag. The chest turns with it (-40 deg at the back, +15 on the way to the front); the halo
   (SL8) ignites in the same order. The rest of the clip (the tell, the kept hit pose, the recovery) is the old one without its yaw.
4. **NADEGIRI settles for six frames before its stillness** (0.48 m a frame at most, f1-6): NS3b ends with the blade at his left front after
   its cut, and §21.3's "the blade settles at the left hip" is that move; f7-12 are then still (0.02 at most) and the snap is 1.84 / 1.51.
   It returns to the stance over f44-52: a clip ends in the form's idle at the move's end (the S2 check), so the held stillness is f38-44.
5. **爆炎's NS2b plays NS2c's new clip** with `:clip-s 18` on its S16 (the copy's S scaled: the hit pose lands on its frame); its frame 0 is
   NS2b's landing, 0.15 m off 爆炎 NS2a's (S4 may give it its own). **ENNETSU** still plays `ya-enjo` at `:clip-s 20` on its S18: the clip,
   now 44 f (R22), ends at f40 of a 50 f move and holds the stance pose for the last 10 f; **爆炎's NADEGIRI** (R60) holds the stance pose
   for its last 26 f, as it did with the old clip. Both are S4's (§21.4).
6. **The stance-2 drip was made larger after the first stills** (the hanging flame 0.14 -> 0.26 m, the drops 0.05 -> 0.13 m long and twice
   as wide, a 0.8 m fall): at 0.6 m and 2 cm the drops read as specks at play distance. Its first build consed 72 B a draw (a phase bound
   without a type); declared, 0 B.
7. **The stance 2 / 3 poses, `:ya-lean` and `:ya-enjo-point` moved up the file** (before pointer 2's clips, whose poses are based on them; a
   pose is built when its form loads). `:ya-enjo-point` was the deleted O ENJO block's and stays as stance 2's base.
8. **The Kikon strike stills are on NS1a's spiral** (pointer 1, Kenpachi 3 m away, the SP held): NS3a's Kikon is the cinematic itself, with
   no strike (found by the first run).
9. **No new debug number**: every still uses the existing segment starts (87413-87419, 87461-87465), pointers, heat and distances.
10. **The art viewer's K2 / K3 / S2 strip scripts were regenerated** (the clip indices moved with the new and deleted clips).

### 24.7 Stills (untracked)

- In play: `tests/scripts/duel-yama-s3.json` / `-phone.json` (`tests/scripts/duel.py`'s `yama_s3_script`), each segment on its own (Kenpachi 10 m
  away), the behind camera then the SIDE camera (2109), landscape and portrait (`--mobile --size 390x844`, the deck on):
  `tests/shots/duel-yama-s3-<still>-<behind|side>[-phone].png` for `ns2a-cock` / `-cocked` / `-held` / `-release` / `-s` / `-land`, `ns2b-first` /
  `-c1`-`c4` / `-s`, `ns2c-rise` / `-up` / `-held` / `-chop` / `-s` / `-rec`, `as2a-first` / `-cock` / `-flick` / `-s` / `-thru`, `as2b-up` / `-s`,
  `ns3a-pull` / `-low` / `-held` / `-jab` / `-s` / `-land`, `ns3b-wind` / `-held` / `-cut` / `-s` / `-thru`, `ns3c-settle` / `-still` / `-snap` / `-s` /
  `-thru` / `-lower` / `-away`, `as3a-cock` / `-s` / `-pull`, `as3b-flip` / `-low` / `-s` / `-high`, `as3c-settle` / `-s`, `sa-tell`, `sa-right-front`,
  `sa-right`, `sa-behind-right`, `sa-behind`, `sa-left`, `sa-left-front`, `sa-s`; the stance looks `stance-<1|2>-h<0|12|25>-<a|b>` (two phases).
- The Kikon strike: `tests/scripts/duel-yama-s3-strike.json` / `-phone.json` (`yama_s3_strike_script`): NS1a pressed with the SP held, the burst
  `tests/shots/duel-yama-s3-strike-<00-23>-<behind|side>[-phone].png`.
- 8-frame strips, the art viewer (`dist/duelview` built with `yama-art.lisp`): `tests/shots/duel-view-yama-s3-<clip>-<side|front>.png` for the 13
  S3 clips (`tests/scripts/duel-view-yama-s3.json`, `duel-view.py`'s `yama_s3`).
- Contact sheets: `tests/shots/duel-yama-s3-sheet-<behind|side>[-phone].png` (every segment still), `duel-yama-s3-stance-sheet[-phone].png`
  (the stance looks: rows the pointer x phase, columns the two cameras x heat 0 / 12 / 25), `duel-yama-s3-strike-sheet-<behind|side>[-phone].png`,
  `duel-yama-s3-strips-<side|front>.png`.

Checked by eye: NS2a's cocked spear and the lock-out (the side camera), NS2c's blade straight up through the hold and level on S, the dome
on Kenpachi when in reach; NS3c's stillness with the blade at his left hip, the hairline on S and the seam's V at f42 with the blade lowered
at his right; TAIMATSU's blade at his right, behind, then at his left as the halo ignites round him, rising into the fan on S; stance 1's
corkscrew reads at heat 25 (white strands winding round the blade) and is small and orange at heat 0; stance 2's hanging flame reads at the
point, its drops are faint at play distance (deviation 6).

### 24.8 Checks (all on the final build)

| Check | Result |
|---|---|
| Presentation only: the native trials | `tests/trials/yamamoto-core.lisp` (242 lines of `combo-trial.py --log`), `-blaze` (268), `-bankai` (513): identical to a7f6a260's, every line |
| Presentation only: the browser | `tests/scripts/duel-yama-core.json` (110 lines) and `duel-yama-blaze.json` (35): every `duel hash`, `duel probe`, `duel yamamoto` and combat-log line identical to a dist built at a7f6a260 |
| Heat is read, never written | the trials above (their HEAT lines) and S1's host walker over the look files: none written (YA-STANCE-TIER reads GAUGES-METER) |
| Shared files | `python3 tests/style-gates.py cvc dist/duel`: II / IK / KK identical to `tests/style-cvc-ref.txt` (33 / 28 / 27 lines) |
| The looks gate | `python3 tests/style-gates.py looks BASE dist/duel --jobs 4`, BASE a dist built at a7f6a260. The expected list written before the run (from BASE's cvc-yk log): `cvc-yk/start` (P1 idle in stance 1) and, possibly, `w2-0`. **Result: 2 stills differ, neither of them listed**: `cvc-yk/w1-1` (8 px) and `w3-0` (2030 px); `start` and `w2-0` are byte-identical; the other 81 byte-identical (noise floor 0); every scenario's fighters and sim lines PASS (`cvc-yk sim lines` 12). **By the gate's rule this is a FAIL** (unlisted stills differ). Verified after the run: in both the diff image is confined to P1's blade, the pose is the same in BASE and new (the blade level at his hip), and the new image adds stance 1's thin orange strands round the blade (T0): the stance look is the only S3 change that draws there. Inferred from BASE's log, not traced: the CPU had just refused its next NS segment for want of flash-step (`cpu holds YA-N1B` at 6894, `YA-N1C` at 1357), so P1 had no move while his anim's clip was pointer 1's stance (the list read those ticks as "in NS1a / NS1b"); since S2 recorded w3-0 unchanged by the stance's re-key, the pose drawn there is likely FEEDBACK's held pose, not the clip's. At `start` (tick ~41) P1 is stepping (a step clip, no stance fire). Not re-based (the lead's call) |
| Host tests | ALL PASS, 4241 checks (+77: the S3 FK rows now checked, the NS2a / NS2c / AS2b cast checks, the 14 S3 moves and 爆炎's NS2b against their clips' frames, the root-yaw guard over every Shikai / 爆炎 move); `known-off` = `(:ya-b-j3)` |
| pkgcheck, debug ranges, warnings | as main (the one `DUEL::APP` line); `tests/debug-ranges-check.py` 88 ranges, 0 errors (no new debug number); no compiler warning in the yama files (a first build's `*YA-HEAT-NS*` forward reference from YA-STANCE-TIER was replaced by the host-checked 25) |
| 0 B a frame | debug 87449 every row 0, the new `stance-1-t0..2`, `stance-2-t0..2`, `tier-stance` included (the first build's stance-2 rows read 720 B, deviation 6); 87448 the same as BASE's (its 南 rows 80 B with P1 not in the Bankai, §22.6); `fx-dropped 0` on every stats line of the stills runs |
| Build, smoke | `./build.sh duel` (then `git checkout -- vendor`), `run.mjs --secs 8` exit 0 |

### 24.9 Open

- **For the user's eyes** (the sheets): stance 2's drip (the drops faint at play distance; the hanging flame reads); TAIMATSU's carry (the hand
  behind his back for two keys, the halo hides most of it); NADEGIRI's new stillness (no turn: the chest and head turned away, the blade
  lowered at his right); AS3a's hooked reverse grip; NS2a's spear cock (it reads from the side camera, little from behind).
- The looks gate's YK stills (start unchanged; w1-1, w3-0 changed by stance 1's corkscrew) wait for the lead's call. The corkscrew draws
  whenever he has no move and his anim's clip is a pointer stance, so it can show on a held pose for a few frames (w3-0).
- S4: IKKOTSU (`known-off`), 爆炎's NS2b frame 0 (0.15 m), ENNETSU's own clip (it holds the stance for its last 10 f), 爆炎's NADEGIRI's long
  recovery (`ya-b-n3c`), the entry pose `ya-hellfire` (the root-yaw guard's one exemption). S5: the cinematics on 87482-87489.
- The SA's frame 0 against its six predecessors (§18.9): 1.50-2.84 m, unchanged in kind.
- Stance 3 has no fire (an ember on the point is the user's call).

### 24.10 Merged (the lead, 2026-11-20)

Merged into main as built. The lead re-ran the fast checks on the merge: host tests 4241 ALL PASS, pkgcheck as before, debug ranges 0 errors,
build, smoke exit 0, `--cvc` II / IK / KK identical. Playtest page v457.
**The looks gate, by its rule, failed**: the expected list (cvc-yk start, maybe w2-0) missed the two stills that changed (w1-1, 8 px; w3-0,
2030 px). The lead read the w3-0 diff image: every changed pixel lies on his blade in stance 1, where the new corkscrew strands are, and the
YK sim lines are identical. The cause is a mis-prediction (the CPU idles in stance 1 on those ticks), not a leak, so the lead accepts it and
**re-bases** at this merge (BASE = a dist built here). Lesson for the next expected list: a look drawn on a stance shows on every idle tick of
the YK match.

## 25. As built (art batch S4: 爆炎's delta, 2026-11-20)

S4 of §21.1 (the user, 2026-11-20: 「繼續」; the plan §21.4, the decisions §21.8: Q2 「沿用始解的，換爆炎裝扮」, so 爆炎 keeps the Shikai's stances
and Kikon cinematics in its own dress): every row of §21.4's table. Presentation only (proofs in 25.7). Code: `yama-art.lisp` (the four clips,
*YA-SCARS* and the bared body's dull scar glow, YAMA-DRAW's 爆炎 calls), `yama-look.lisp` (YAMA-SCAR-GLOW, YAMA-ENNETSU-LOOK, YAMA-RING-CLOSE,
YAMA-BLAZE-IN-LOOK, %YA-FIST-FIRE, the tornado's lean, YAMA-SK-MOVES code 8, IKKOTSU's *YA-PLANTS* row, the 87449 rows), `yama.lisp` (`:clip`,
`:blend`, `:look`, `:smear`, the `:planted` hook on the Shikai's `:hooks`, debug 87490), shared `vfx.lisp` (`vfx-smear` look 5) and `kit.lisp`
(its docstring), tests `tests/duel-rules/art.lisp` and `yamamoto.lisp`, the art viewer (`tests/duel-view.lisp`: 爆炎's clips on the bared body)
and the still scripts.

### 25.1 What was built, row by row (§21.4)

| §21.4 row | As built |
|---|---|
| Scars by heat | **Kit-local, not the shared gain.** The 12 glowing scars' mesh now glows a dull ember red (`:glow 2.4` → 0.9, `#FF5A3C` → `#A8301E`: the floor, what heat 25 and under shows), and YAMA-SCAR-GLOW draws an additive fire hairline over each (from *YA-SCARS*, the same table that builds the glow parts, 4 mm out along the skin's normal): brightness and width the heat's share above 25 (full at 100, gone by 25), a white centre from 70 up (a positive alpha: white-hot owned by heat, §21.2); at 10 and under a dull ember pulse three times a second on the fx clock. Why kit-local: a glow-parts-only gain needs a new key through DRAW-FIGHTER → DRAW-BODY → the engine's DRAW-PARTS (three files, the engine one shared by every game) for one kit; an additive overlay alone cannot dull a baked 2.4 glow, so the mesh's own glow was lowered in the bared body (爆炎's only), and the hairline carries the ramp. In the stills (25.6) heat 100 / 50 / 10 read apart on the chest from the SIDE camera: bright yellow-white lines, orange lines, dull red |
| The blade | **Already built by S1** (SL0, §22.3): x1.3 and always white-cored in 爆炎 (YAMA-BLADE-FIRE's mode + 10). Not duplicated; 87449's `blade-blaze` row is 0 B. New: no SL0 while IKKOTSU's blade stands planted (the hand is empty; YAMA-DRAW asks PLANTED-SPOT) |
| J1 / J2 flame trail | `vfx-smear` look 5, 爆炎's `:smear 5`: the FIRE wash at full width (look 4 is half), the orange hairline, and three tongues licking up off the Bezier toward the blade end (presence = the smear's). Default off: only a kit's `:smear 5` reaches it; looks 0-4 take the same branches as before. `:smear` is per form, so it draws behind **every** 爆炎 swing, not only J1 / J2 (§21.4 named those two) |
| J3 IKKOTSU | `ya-ikkotsu` re-keyed at the move's S9 (9 / 3 / 18; it struck at S8, F10). Frame 0 J2's S+A (`:ya-q2-a`); the blade planted point-down at his right on f2 (`:ya-ikkotsu-plant`, FK: the grip 0.75 m up, 0.50 m right, 0.14 m ahead; *YA-PLANTS* row `(:ya-b-j3 2 24 (0.14 0.5))`), the hand lets go (f3), the fist drawn back to the ribs (f6) and wound (f7-8), one step in on the left foot and the fist straight out at shoulder height on S (`:ya-ikkotsu-hit`: the wrist 1.35 m ahead at 1.33 m up), held to S+A, drawn back, the hand on the hilt again on f24, the blade drawn out into the stance by f30. A FIRE burst on the fist (%YA-FIST-FIRE: six white-cored tongues along his facing) full on S, to S+A, gone by f13. The `:planted` hook (YAMA-PLANTED) is now on the Shikai's `:hooks`, so 爆炎 inherits it; it returns NIL for every other Shikai move (no move sets `:planted`, so the default 0.7 m rule was never reached) |
| The entry pose | its own `ya-blaze-in` (23 / 1 / 0 = 24 f on the move's frames; it played the 60 f `ya-hellfire` x2.5 with a 360° root turn, now deleted), the move's `:clip-s 57` dropped, `:blend 4` (it starts from any stance). The point lowered to the plaza at his right (f0-6, `:ya-hellfire-point` kept), held while YAMA-BLAZE-IN-LOOK runs the fire down the edge (a white-cored strand guard → point, f7-10) and a ring of fire out over the floor from the point (0.3 → 2.5 m, f10-16, gone by f21); he straightens, chest out, chin up, the arm flung wide (f17-20, `:ya-blaze-up`), held to f24. Its root-yaw exemption is gone from S3's guard |
| NS1c's tornado | YAMA-TORNADO-LOOK leans its upper bands toward the victim's side of its travel when the hazard's data carries `:track` (爆炎's NS1c alone): the lateral share of the victim's bearing x 1.0 m at the top band, a third of it per band, the lowest band (the footprint) never; the Shikai's NS1c (`:track` NIL) draws exactly as before. "Taller (T2)": every 爆炎 segment is T2 already (S1), so it is drawn at full height with no new factor |
| NS2b: the ring closes at once | YAMA-RING-CLOSE on 爆炎 NS2b's move frames f12-15 (S-4 .. S-1): SL5's band (r 1.6, ±0.25) with 24 low white-cored tongues coiling in from the point nearest him over the 4 frames, round the spot the dome will take (his live ring's, else YA-BEARING-POINT's rule: the victim's bearing at 3-8 m, read now); on S16 the dome hazard stands closed at once (SL6, the hit frame full: §22.2). So "the ring for 4 f, then the walls" comes before S, not after it (the hit frame rule; the halo's opening before S is S1's precedent) |
| NS2c ENNETSU JIGOKU | its own clip `ya-b-n2c` (18 / 2 / 30; it played NS2a's `ya-enjo` at x1.11, which ended at f40 of the 50 f move and held the stance pose): frame 0 爆炎 NS2b's landing (NS2c's clip at x18/16 drawn at its f18, sampled exactly), the hilt drawn back to his right hip with the point hanging (f1-12, a key a frame), held f13-15, the point driven down into the plaza at his right front on S (`:ya-b-n2c-hit`: the tip 1.08 m ahead, on the floor), left in it to f30 while the rows run, drawn out into the stance. Its look YAMA-ENNETSU-LOOK (the move's `:params :look`): rows of three pillars abreast across the 2.4 m box (each a third of its width), the front row riding the box (full on age 0, the hit frame; its far face 0.1 m inside the box's front), a fixed row every 1.0 m of the lane the box has crossed, each full 16 f from when the box's centre passed it, eroding over 4 f, so three rows burn behind the front; EMBER circles at the next row's three spots ahead of the box (the tell); a scorch under each row (T2); every row fades over the hazard's last 6 f (its 45 f life cannot grow) |
| NS3c: the true NADEGIRI | its own clip `ya-b-n3c` (14 / 4 / 60): the Shikai's NADEGIRI keys to S+A (frame 0 NS3b's S+A), then the blade lowered over 40 f (f19-58, the Shikai's curve at half speed, a key a frame) with the chest (-46°) and the head turned away, no root yaw, held still to the move's end (f78; TO-IDLE's 6 f blend takes him back). It held the stance pose for its last 26 f before. SL7's seam (YAMA-SK-MOVES code 8, `:ya-b-n3c` only; 爆炎's AS3c keeps code 1): the hairline on S and S+1, then from f38 the seam from 0.6 m to 8 m, 10 white-cored tongues a side in a V, tallest at the reach (2.4 m), lower past it (0.6 at 8 m), gone by f65 |
| AS / NS1a-b / NS2a / NS3a-b / SA | the Shikai's clips and looks at T2, unchanged; **the SA's halo at 3.2 m was already built by S1** (YAMA-SK-MOVES code 3, 87449's `halo-blaze` 0 B) |
| The cancel burn (Y10) | **Left as a sound.** The cancel's feedback is `:clash x y z` (no side); the burn's own event is the generic `(:sfx :explode other)`, which carries the victim, but YAMA-DOME-FIRE emits the same key with Yamamoto himself on every dome, so FEEDBACK cannot tell a burn from a dome without a new event (a sim-file emit, outside S4's allowed edits) |

Deleted, unreferenced after S4: `ya-hellfire` (the clip); kept `:ya-hellfire-point` (the entry's and S5's storyboard's pose). Re-defined:
`:ya-ikkotsu-chamber`, `:ya-ikkotsu-hit` (IKKOTSU's own, no other user).

### 25.2 Drawn reach against hit reach (the host FK test)

| Move | Before (§24.2): drawn / volume end / delta | After | Verdict |
|---|---|---|---|
| 爆炎 J3 IKKOTSU (by the fist) | 1.21 / 1.40 / -0.19 **(known off)** | **1.36 / 1.40 / -0.04** | within ±0.15: out of `known-off` |
| 爆炎 NS3c the true NADEGIRI | 1.95 / 2.40 / -0.45 (one-sided, `ya-nadegiri`) | 1.95 / 2.40 / -0.45 (its own clip, the same cut) | one-sided (SL7's seam, 8 m) |
| 爆炎 SA TAIMATSU | 1.45 / 3.20 / -1.75 | unchanged | one-sided (SL8 at 3.2 m) |

**`known-off` is empty** (`'()`): every Shikai and 爆炎 blade window is within ±0.15 m or one-sided. F10's print: `IKKOTSU (clip YA-IKKOTSU S9,
move S9)`, the fist ahead per frame f6-12: 0.28 0.28 0.28 **1.35** 1.36 1.36 1.35 (before: 0.69 0.98 1.19 1.21 1.21 1.20 1.20, the punch a
frame early). The planted windows: IKKOTSU's grip on its spot 0.01 m off at f2 and f24 (the check now poses each row on its own kit's body).
ENNETSU's cast check: the tip at S18 0.34 / -0.04 / 1.08 (in the plaza, ahead).

### 25.3 Link frames: the tip's jump on the frame the link lands (m)

| Link (lands on) | Before | After | The new clip's first frames (f1-4) |
|---|---|---|---|
| J2 > IKKOTSU (J2 f11) | 1.28 | 0 | 1.27 1.33 1.51 0.82 (the blade driven into the plaza by f2, then drawn planted: the hand's blade is not drawn from f2) |
| 爆炎 NS2b > ENNETSU (NS2b f18, NS2c's clip at x18/16) | 0.18 | 0 | 0.04 0.06 0.09 0.13 |
| 爆炎 NS3b > the true NADEGIRI (NS3b f15) | 0 | 0 | 0.06 0.18 0.34 0.48 (the Shikai's settle) |
| stance > the entry pose | (the old clip from `:ya-stance`, no blend) | `:blend 4` from any stance | (f1-4 of its own: 0.33 0.13 0.02 0.17) |

### 25.4 緩急 (m a frame, the clip's FK at the root)

| Move | Charge | Hold | Release → S | After S |
|---|---|---|---|---|
| IKKOTSU, the fist, before (S8 clip) | f6-8 0.51 0.45 0.29 (no hold: the chamber was frame 0) | - | f9 0.10 | 0.03 |
| IKKOTSU, the fist, after | f4 0.28, f5 0.10 (to the ribs) | f6-8 0.01 0.01 0.01 | **S 1.48** (one drawing) | 0.02 |
| ENNETSU, the tip | f1-12: 0.04 0.06 0.09 0.13 0.18 0.24 0.28 0.29 0.27 0.24 0.20 0.12 | f13-15 ≤ 0.02 | f16 0.27, **f17 0.49**, S 0.45 | 0.01 |
| the true NADEGIRI, the tip | f1-6 the settle (0.48 at most) | f7-12 ≤ 0.02 | **f13 1.84, S 1.51** | the lowering 0.01 → 0.11 → 0.01 over f19-58, then 0 to f78 |

ENNETSU's drive (0.49) is 1.7x its fastest gather frame (0.29): the gather carries the blade from level at the dome to his hip (1.9 m of tip
travel), so it cannot be slow; it was stretched to 12 frames and the drive keyed at 12 % / 45 % so it gathers into S.

### 25.5 Deviations, each with its reason

1. **Kit-local scars, and the bared body's mesh dulled** (25.1): the shared gain would touch three files and the engine for one kit; the
   overlay needs the mesh's own glow lowered to show "dull by 25". The scars' table is now *YA-SCARS* (one source for the parts and the look).
2. **The ring before the dome, not after its first frame** (25.1): §22.2's hit-frame rule; its spot is read on the frames before S, so a victim
   stepping in those 4 frames moves the dome's spot from the ring's by up to his 4 frames of travel (0.3-0.4 m at a walk).
3. **ENNETSU's front row rides the box; the tell lies outside the footprint by design** (§21.4: "a row ahead of the front"). The rows behind
   are the lane already crossed (decoration of a hit that has passed, as the spiral's tail). Rows erode over 4 f (§21.4 said "then eroding"
   with no length) and their crowns are two tongues without a core: the first build's rows overflowed the fx batch in the 87449 probe (10 draws
   past its 16,384 vertices: "(dropped)"); now about 1,200 vertices a draw (counted from the segments, 6 a segment).
4. **The true NADEGIRI's seam has 10 tongues a side, no EMBER backing**: the first build's 14 a side with backings overflowed the probe the same
   way (about 1,850 vertices a draw); now about 860.
5. **The entry pose ends on its straightened pose** (f20-24), and TO-IDLE's 6 f blend takes him back to his stance, as the true NADEGIRI's end
   (its held stillness to f78, as §21.4 asks).
6. **IKKOTSU's fist is a 0.52 m drawn step** (`:root :f 0.52`; the old clip's 0.32): one arm from where he stands reaches 1.2 m; the Bankai's
   grab is the precedent (0.88). Its punch is one drawing (S 1.48 m a frame after a 3-frame hold).
7. **The flame trail draws behind every 爆炎 swing** (`:smear` is per form), not J1 / J2 alone.
8. **Debug 87490** (new, claimed in DUEL_GAMEPLAY): P2 moved 3 m to P1's right, so the tornado has an off-axis victim to turn after (87000+k
   always places him dead ahead).
9. **ENNETSU's front row is centred on the box**, so its far face is 0.1 m inside the box's front (§21.4: "the front row's far face is the
   hazard's x"): the hit begins at the box's front (S1 dev 2's precedent: heads on the box's front), so the pillars stand over the hit.
10. **The tornado's lean was raised from 0.6 m to 1.0 m at the top band** after the first stills, where it hardly read; it is still slight
   (the hazard turns after the victim at 60°/s, so the lateral share of his bearing shrinks as it tracks).

### 25.6 Stills (untracked)

- In play: `tests/scripts/duel-yama-s4.json` / `-phone.json` (`tests/scripts/duel.py`'s `yama_s4_script`), P1 in 爆炎, the behind camera then
  the SIDE camera (2109), landscape and portrait (`--mobile --size 390x844`, the deck on): `tests/shots/duel-yama-s4-<still>-<behind|side>[-phone].png`
  for `heat-100`, `heat-50`, `heat-10`, `heat-10b` (the scars, the blade, stance 1's corkscrew), `j1-trail`, `j2-trail`, `ikk-first` / `-plant` /
  `-chamber` / `-s` / `-a` / `-back` / `-hilt`, `entry-f03`-`f23`, `tornado-s`, `tornado-lean-a` / `-b`, `ring-f12` / `-f14` / `-f15` / `-s` /
  `-f24`, `ennetsu-cock` / `-s` / `-f24` / `-f30` / `-f40` / `-f58`, `nade-s`, `nade-f30`-`f77`; from above (87480 + 87481, landscape):
  `duel-yama-s4-top-ennetsu-f18` / `-f30` / `-f40`, `-top-tornado-f30`.
- 8-frame strips, the art viewer (`dist/duelview` built with `yama-art.lisp`): `tests/shots/duel-view-yama-s4-<clip>-<side|front>.png` for
  `ya-ikkotsu`, `ya-blaze-in`, `ya-b-n2c`, `ya-b-n3c` (`tests/scripts/duel-view-yama-s4.json`, `duel-view.py`'s `yama_s4`; the K2 / K3 / S2 / S3 strip
  scripts regenerated: the clip indices moved).
- Contact sheets: `tests/shots/duel-yama-s4-sheet-<behind|side>[-phone].png`, `duel-yama-s4-top-sheet.png`, `duel-yama-s4-strips-<side|front>.png`.

Checked by eye: the three heats read apart on his chest from the SIDE camera (from behind only the back scar shows); the last-10 pulse is
**not** shown by the stills (`heat-10` and `heat-10b` landed on the same look: the pulse is proven by 87449's `scars-5` row and the code
only); IKKOTSU's blade stands in the plaza at his right from f2, the fist burst on S into Kenpachi (the in-play still names past `ikk-s` run
behind the clip by J3's hitstop: `ikk-back` / `ikk-hilt` still show the fist out, so no still shows the hand back on the hilt; the f24 grip is
proven by the host check, 0.01 m, and the viewer strip draws the blade in his hand); the entry's ring runs out from the point (the big orange disc of f6-f9 is
FEEDBACK `:hellfire`'s existing shockwave, not S4's); NS2b's ring coils round Kenpachi f12-15 and the dome stands after; ENNETSU's rows
stand behind the front and from above the front row fills the box with the tell circles a row ahead; the true NADEGIRI's seam runs past
Kenpachi to 8 m and he stands turned away with the blade low. The tornado's lean is slight at play distance (the hazard turns after the
victim at 60°/s, so the lateral share of his bearing shrinks as it tracks). The black radial marks under him in later stills are the 爆炎
entry's scorch (FEEDBACK `:hellfire`'s `stage-mark`), one per scene.

### 25.7 Checks (all on the final build)

| Check | Result |
|---|---|
| Presentation only: the native trials | `tests/trials/yamamoto-core.lisp` (242 lines of `combo-trial.py --log`), `-blaze` (268), `-bankai` (513): identical to 09002726's, every line |
| Presentation only: the browser | `tests/scripts/duel-yama-core.json` (116 lines) and `duel-yama-blaze.json` (40): every `duel hash`, `duel probe`, `duel yamamoto`, combat-log and scene line identical to a dist built at 09002726 |
| Heat is read, never written | the trials above (their HEAT lines) and S1's host walker over the look files: none written (YAMA-SCAR-GLOW reads GAUGES-METER) |
| Shared files | `python3 tests/style-gates.py cvc dist/duel`: II / IK / KK identical to `tests/style-cvc-ref.txt` (33 / 28 / 27 lines; `vfx-smear`'s look 5) |
| The looks gate | `python3 tests/style-gates.py looks BASE dist/duel --jobs 4`, BASE a dist built at 09002726. The expected list, written before the run from BASE's cvc-yk log: **none, 83 / 83** (no GOKUEN line in seed 28: P1's heat peaks at 40 at tick 1950 and is spent at 1995, so 爆炎 is never on screen; every S4 look and clip is 爆炎's; the Shikai paths touched draw the same: the `:planted` hook returns NIL, SL0's planted guard is false, the tornado's lean is 0 without `:track`, looks 0-4 take the same branches). Result: **83 / 83 byte-identical** (noise floor 0); every scenario's fighters and sim lines PASS (`cvc-yk sim lines` 12) |
| Host tests | ALL PASS, 4252 checks (+11: IKKOTSU's FK row checked (`known-off` empty), its planted window at f2 and f24, 爆炎's four clips on their moves' frames, ENNETSU's point in the plaza on S, the entry pose under the root-yaw guard with no exemption, the look constants +YA-ENNETSU-SPEED+ / +YA-DOME-NEAR+ / +YA-DOME-FAR+ / +YA-ARENA-IN+ against the sim, 爆炎's smear 5, the `:planted` hook on 爆炎, the blend list with the entry pose) |
| pkgcheck, debug ranges, warnings | as main (the one `DUEL::APP` line); `tests/debug-ranges-check.py` 88 ranges, 0 errors (87490 claimed in DUEL_GAMEPLAY "Debug commands"); the compiler's warnings the same three as main's, none in the yama files or `vfx.lisp` |
| 0 B a frame | debug 87449 every row 0 B, the new `scars-100` / `-60` / `-20` / `-5`, `ennetsu-front` / `-rows` / `-end`, `tornado-lean`, `ring-close`, `blaze-in-edge` / `-ring`, `fist`, `nade-seam-8m`, `smear-5`, `plant-spot-ikkotsu` included; no row "(dropped)" (the first build's three: deviations 3 and 4); `fx-dropped 0` on every stats line of both stills runs |
| Build, smoke | `./build.sh duel` (then `git checkout -- vendor`), `run.mjs --secs 8` exit 0 |

### 25.8 Open

- **For the user's eyes** (the sheets): the true NADEGIRI's 8 m seam (§21.4 asks for it; 5.6 m of it lies past the 2.4 m reach: K5's
  caveat, decoration read as reach); the tornado's lean (slight at play distance); IKKOTSU's 0.52 m step and one-drawing punch; ENNETSU's rows
  from the behind camera (the front row starts 1 m ahead of him and fills the lower screen for its first frames); the scars' hairlines (they
  read from the SIDE camera; from behind only the back scar shows).
- The cancel burn stays a sound (25.1): a look would need its own event in YAMA-BURN! (a sim-file edit).
- 爆炎 NS2b still plays NS2c's clip at x18/16 (its frame 0 0.15 m off 爆炎 NS2a's landing, §24.6 dev 5): not in §21.4's table.
- The SA's frame 0 against its six predecessors (§18.9) is unchanged. S5: the three Kikon cinematics on 87482-87489.

### 25.9 The lead's merge (2026-11-20)

- Reviewed the diff: `kit.lisp` only its `:smear` docstring; `vfx.lisp` look 5 a new branch (looks 0-4 take the old ones); `yama.lisp` clip
  wiring, `:smear 5`, the `:planted` hook, debug 87490. No sim number moved.
- Re-run on main after the merge: host 4252 ALL PASS, pkgcheck as before, debug ranges 88 / 0 errors, `./build.sh duel` then `git checkout --
  vendor`, smoke exit 0, `--cvc` II / IK / KK PASS (33 / 28 / 27 lines).
- Looks against `looks-base-s3`: 83/83 byte-identical, every sim line PASS, as predicted (none). A first run with `--keep-base` failed on
  nearly every still, menus included: it compared against base renders left in `build/style/looks/` by an earlier run, not renders of
  `looks-base-s3`. Re-run without `--keep-base`: PASS. The base is now this merge's dist (`looks-base-s4`); S5's wiring changes YK again.
- Playtest v458 (index.js / index.wasm / manual.html hashes verified). The manual's Yamamoto line now names 爆炎's art.

## 26. As built (art batch S5: the Shikai's three Kikon cinematics, 2026-11-20)

### 26.0 The looks gate's expected diff (written before each run)

- **The cinematics commits (not wired)**: none. 83 / 83 stills byte-identical to BASE (a dist built at 22ee1330), every scenario's
  fighters and sim lines as BASE's. The new cinematics play only through debug 87482-87487; YAMA-DRAW's new guard (YAMA-S5-CINE-P) is
  false outside them; the 87449 rows run only on that command; the 爆炎 / Shikai `:kikon-cines` still name `soul-break-cine`.
  **Result: PASS, 83 / 83 byte-identical** (noise floor 0), every scenario's fighters and sim lines as BASE's (`cvc-yk sim lines` 12).
- **The wiring commit**, written from that run's BASE `cvc-yk.log` (seed 28) before the wiring run: P1 Yamamoto's first Kikon is at tick
  4010, `P1 AS2 pointer 2` (J1 J2 > AS2, the ring's hit, then the AS strike), in the Shikai (`(BASE)`), so it will play
  `yama-ennetsu-cine` (186 f) for `soul-break-cine` (96 f): +90 ticks before the reset. (A second, at 4813 under pointer 1, lies after
  it: the match has diverged by then, the CPU reads `*match-tick*`.) The YK stills: `cvc-yk-intro`, `-start`, `-w0-0` (early in the first round),
  `-w1-0`, `-w1-1` (tick 1385), `-w2-0` (tick 3307) are before 4010: identical; `cvc-yk-w3-0` (tick 6898 in BASE) is after it: **expected
  to differ**. The YK sim lines (12: the match line and the `duel hash` lines): `t=600` .. `t=3600` and the match line identical; `t=4200`
  and every later hash line (and the RESULTS line if the run reaches it) **expected to differ**. Every other scenario: identical (they play
  no Yamamoto Kikon in the Shikai or 爆炎: KH, HK, II, IK, the cinematics, fx-a, menus, mobile).

S5 of §21.1 (the user, 2026-11-20: 「繼續」; the storyboards §21.5; the decisions §21.8: Q2 「沿用始解的，換爆炎裝扮」, Q3 「照原作」). Three `defcine`s
in `duel/lisp/yama-cine.lisp`: `yama-shiranui-cine` (174 f, hold 100), `yama-ennetsu-cine` (186 f, hold 120), `yama-nadegiri-cine` (156 f,
hold 90), at the storyboards' lengths and CINE-PLACE distances (6.0 / 3.0 / 2.0 m), on K4's grammar: AT events cut, play clips and stamp
(step mode); one DURING per cinematic calls one look, a DEFUN-FAST of the cinematic frame and the actors' places (`yama-shiranui-look`,
`yama-ennetsu-cine-look`, `yama-nadegiri-cine-look`; the blade's fire in `yama-s5-blade`), 0 B, `rnd01` only. 爆炎 plays the same three
(Q2): DEFCINE draws his current model, so he is bared with the scars lit by heat (YAMA-DRAW's YAMA-SCAR-GLOW), and `%ya-cform` gives every
fire T2 (white-cored) and x1.2 height in 爆炎; in the Shikai the small fires are T1 and the beats the storyboards mark T2 (the columns, the
tornado, the seam, the dome) are T2. Full colour: no `:spot` grade (the Shikai is the orange form; K4's Bankai grey is its own). While one
runs, YAMA-DRAW leaves the blade's fire (SL0 and the stance fire) to the cinematic (`yama-s5-cine-p`), whose look draws it per beat: 不知火's
spiral and its going out, ENNETSU's fire down the edge, and none at all in 撫斬. The wiring (the Shikai's and 爆炎's `:core :kikon-cines`)
is its own commit, the last (§19.2).

### 26.1 The beat tables as built (against §21.5)

不知火 SHIRANUI (174 f; `cine-place a v 6.0`):

| Frames | Shot as built | Action as built | Effects / sound | Against §21.5.1 |
|---|---|---|---|---|
| 0-10 | held | `hold-both` 10; stance 1's coil (`ya-shiranui`), the victim `:sh-kikon-victim` | negative 2, whoosh | as written |
| 10-40 | `shot-on a 60 1.8 0.9 :look 1.1 :off 0.6` (portrait 2.6 m), lens 50 roll 5 | the spiral winds down the blade from the tip to the guard (f10-34, two strands, 1.1 turns) and tightens (r 0.17 → 0.08 m, f10-40) | silence 30; caption 不知火, SHIRANUI, sub RYUJIN JAKKA, hanko | portrait 2.6 m: at 1.8 the blade at his hip left the tall frame |
| 40-58 | `shot-on v 180 7.0 4.5 :look 0.4` (portrait 9.0), lens 44 | nine pale lights (white flames 0.8 m over EMBER marks r 0.35, pulsing on twos) wink on round the victim on a 4 m circle, one every 2 f | a soft tick each (`:hs-tip`) | as written |
| 58-76 | `shot-pair a v 1 9.0 1.2` (portrait 12.0), lens 46 | `cine-slow 0.4`; NS1a's release (`ya-n1a` from f18: its S20 on f63); the spiral goes out f58-62, the blade bare to f150; from f64 the lights stand up as columns (8 f) | f63 one dry crack (`:cut-heavy`), f66 the roar starts | as written |
| 76-120 | `shot-on v 0 2.0 10.0 :look 0` (portrait 12 m up), lens 40 | `cine-slow 1`; the columns (3.2 → 4.8 m, T2) circle him faster, the circle closing 4 → 0.8 m, leaning together; an EMBER ring on the floor at their radius | shake 0.1 / 0.2 / 0.3 / 0.4 at f76 / 90 / 102 / 112 | as written |
| 120-126 | `shot-on v 0 3.2 0.5 :look 1.0`, lens 36 | the wall arrives; f122 the Konpaku (`cine-shatter`, the Kikon's count) | f122 negative 2, splash, konpaku-shatter; f124 manga 10, explode | as written |
| 126-150 | `shot-on v 30 5.0 0.3 :look 3.0`, lens 60 | one tornado from f124 (5 bands, 10 m, T2, FIRE on the camera's side, INK behind, a floor band and gaps), `silhouette-black` on the victim, `:sh-crumple` on the floor | sizzle | the bands thinned (0.35 m at 10 m) and the lowest put on the floor after the first stills: a 0.7 m band at 0.6 m hid him |
| 150-174 | `shot-on a 160 3.5 1.6 :look 1.3` (portrait 5.0), lens 44 | his back; the tornado gutters to embers (f150-166); he blends to `ya-stance` (14 f), the blade's rest fire back; the victim `:sh-down`, black smoke | caption exits | 爆炎: the scarred bare back, not the 一 on the haori (dev 4) |

焱熱地獄 ENNETSU JIGOKU (186 f; `cine-place a v 3.0`; M = the midpoint of the two):

| Frames | Shot as built | Action as built | Effects / sound | Against §21.5.2 |
|---|---|---|---|---|
| 0-10 | held | `hold-both` 10; stance 2's point (`ya-st-enjo`) | negative 2, whoosh | as written |
| 10-34 | `shot-on a 30 2.0 0.5 :look 0.8 :off 0.5`, lens 50 | the point lowered into the plaza at his right (`ya-blaze-in` x0.6 from f10, held at its f10 from f24: S4's entry clip, its fire not drawn); f22-34 a white-cored strand runs down the edge from the guard to the point | silence 20, f30 the hiss; caption 焱熱地獄, ENNETSU JIGOKU, sub JOKAKU ENJO, hanko | the clip: §21.5.2 named the pose `ya-hellfire-point`, which is `ya-blaze-in`'s held frames |
| 34-66 | `shot-on a 0 2.0 10.0 :look 0 :ahead 1.5` (portrait 13 m up), lens 44 | an EMBER line from the point to M (f30-36), 8 spokes out from M to 6 m (f34-46), rings at 2 / 4 / 6 m growing both ways from each spoke (f38-58) round both; f60 twelve small flames on the 4 m ring | f60 explode (low) | drawn in the look, no stage marks (as written) |
| 66-110 | `shot-pair a v 1 5.5 0.6` (portrait 7.5), lens 46 | a pillar from each mark, one every 3 f, to 6 m in 6 f, leaning in from f96 (1.5 m at the top); the victim `:sh-stagger` x0.5; he does not move | the roar, shake 0.2; f96 explode | the pillars between the lens and the pair stand as low stubs (`%near-cam` 2.5-6 m): the portrait first stills lost the pair behind one |
| 110-130 | `shot-pair a v 1 12.0 2.5` (portrait 15.0), lens 40 | the pillars fade (f110-118) into one squat dome: 20 walls on the 5 m circle leaning in, 4 m high (x1.2 in 爆炎), INK backings on its far side, dark gaps | silence 12; f122 the boom (`:awaken-boom` low), shake 0.3 | as written |
| 130-136 | `shot-on v 0 2.6 1.4 :look 1.2`, lens 50 | white fire round the victim (10 tongues at 1.2-2 m); f132 the Konpaku, `:sh-crumple` | f132 negative 2, splash; f134 manga 10 | as written (he stands 0.4 m behind the lens: not in it) |
| 136-160 | `shot-on a 15 2.4 1.3 :look 1.2`, lens 44 roll -4 | `silhouette-black` on him: his dark shape in the flames, the blade still down; 7 small flames on his hem (爆炎: the hakama's, at the ankles); f150 the victim `:sh-down` | sizzle. A look only: no Reishi taken (Q3) | 爆炎: the hakama's hem (no haori, dev 4) |
| 160-186 | `shot-pair a v 1 9.0 2.0` (portrait 12.0), lens 44 | `unsilhouette`; the dome falls outward (f160-172: the walls lean out, sink, fade) to a scorched EMBER ring on the 5 m circle; ash; black smoke off the victim; he points the blade (stance 2, 10 f) | caption exits, explode | the fall 12 f: at 16 f the last walls lay on the floor as red blocks in the wide still |

撫斬 NADEGIRI (156 f; `cine-place a v 2.0`):

| Frames | Shot as built | Action as built | Effects / sound | Against §21.5.3 |
|---|---|---|---|---|
| 0-12 | held | `hold-both` 12; NADEGIRI's draw (`ya-nadegiri` f9, held), the victim `:sh-kikon-victim`; his face calm for the whole cinematic (`face-beat :neutral` 2.6 s: the cinematic attacker's shout would open his mouth) | negative 2 | as written |
| 12-40 | `shot-on a 35 2.2 1.35 :look 1.3 :off 0.25` (portrait 3.0, §21.5.3's P), lens 20 | eyes shut, nothing moves; no fire on the blade | silence 28; caption 撫斬, NADEGIRI, sub RYUJIN JAKKA, hanko | 35° and his face's height for 10° and 1.55 m: at 10° the victim, 2 m ahead, filled the lens (dev 1) |
| 40-52 | `shot-on a 200 2.4 1.5 :look 1.3 :ahead 1.6`, lens 50 | `cine-slow 0.3`; the victim starts his own J (K4's `yama-victim-attack`) | | as written |
| 52-56 | the same | f52 the cut, not shown: one INK hairline across the frame at the victim's neck (12 m long, 2 f); the victim frozen mid-swing (his clip 4 frames on, speed 0); f53 his arm already out (`ya-b-n3c` at its f16, held) | negative 2, `:hs-tip` (no slash sound) | the victim freezes at the cut, not at f56 |
| 56-110 | `shot-pair a v 1 4.2 1.2` (portrait 6.0), lens 46 | he turns his back (yaw + 180, as 南's turn) and lowers the blade (the true NADEGIRI's clip `ya-b-n3c` from f19 at x0.74: its 40 f lowering over 54 f) | silence | 爆炎's own true NADEGIRI clip in both forms (dev 5) |
| 110-116 | `shot-on v 35 2.6 1.4 :look 1.2`, lens 50 | `silhouette-black` on the victim; a white seam down him, crown to floor in 4 f (0.04-0.08 m, 0.4 m toward the lens); f112 the Konpaku | f112 negative 2, splash; f114 manga 10 | 35° for "front": in front of him stood Yamamoto, 0.6 m ahead of the lens (dev 1) |
| 116-140 | `shot-on v 155 3.6 0.4 :look 1.0 :ahead 1.0`, lens 40 | fire bursts from the seam and parts in a V (12 walls a side from 0.6 m before him to 6 m behind, 3 m at him, lower away, sunk near the lens); an INK + EMBER scorch line runs 8 m behind him in 10 f; `:sh-crumple`, f130 `:sh-down` | sizzle; f120 the boom 4 f late, shake 0.3 | 155° for 180° (dev 1): on the line his upright silhouette hid Yamamoto |
| 140-156 | `shot-pair a v 1 7.0 1.6` (portrait 9.0), lens 44 | he has not looked back, the blade hangs; the scorch line kept; embers | caption exits | as written |

### 26.2 Deviations, each with its reason

1. **Camera angles moved where an actor blocked the lens** (K4's dev 1 again; 26.1's last column): 撫斬's face shot 35° at his face's
   height (1.35 m, look 1.3) for 10° at 1.55 (the victim, 2 m ahead, filled the frame at 10°; the draw pose's head is lower than 1.55);
   撫斬's seam shot 35° for "front" (Yamamoto stood 0.6 m in front of the lens); 撫斬's split shot 155° for 180° ("past him to Yamamoto's
   back": on the line the victim's upright silhouette hid him, found in the stills after the wiring commit was first made, so the branch
   was rebuilt with this fix before the wiring commit); 不知火's caption shot 2.6 m in portrait (the blade at his
   hip left the tall frame at 1.8). 焱熱地獄's inside shots and 不知火's front shots kept their angles: the other actor stands behind the lens.
2. **焱 is composed** (the glyph): Yuji Syuku has no 焱 (`tools/glyph-bake.py`: "not in the font"). It is three copies of the font's 火
   (one over two, each mapped from 火's bounding box onto a box of the em: `COMPOSED` in the bake script), so its strokes are about 0.47 x
   火's weight: it reads lighter than 熱地獄 beside it (26.5's stills). The alternatives for the user: 炎熱地獄 (炎 is in the font; not the
   canon name) or a second font for one glyph.
3. **The pillars between the lens and the pair are low stubs** in 焱熱地獄's side-on shot (§21.5.2: "the twelve pillars rise behind both"):
   a pillar nearer the lens than M and within 1.2-3 m of the line to M is drawn at 12-100 % of its height and width. The portrait first
   stills lost both actors behind the near pillars.
4. **爆炎 has no haori** (its form hides `:haori :kosode`): 不知火's last shot shows his scarred bare back, not "the 一 in its rhombus, the
   haori settling"; 焱熱地獄's hem fire is on the hakama's hem at the ankles (0.12 m up, r 0.26), not the haori's at the knees (0.55 m, r 0.34).
5. **撫斬 plays 爆炎's true NADEGIRI clip `ya-b-n3c` in both forms** (its 40 f lowering with the chest and head turned away, S4): §21.5.3's
   slow lowering over 54 f is that clip at x0.74. Turned 180° at f56 (the cut to the side-on pair), so his back is to the victim and the
   blade hangs on his far side.
6. **The victim freezes on the cut (f52)**, not at f56: the hairline is the instant the world stops; his clip is held 4 frames into his
   swing (`yama-victim-attack`'s new LATER / FROZEN arguments; K4's call unchanged).
7. **ENNETSU's opening plays S4's entry clip `ya-blaze-in`** (its point lowered into the plaza at his right, f0-10 at x0.6, held), not a
   clip named `ya-hellfire-point` (that is the clip's held pose); its own fire look (YAMA-BLAZE-IN-LOOK) is not drawn (it reads the move,
   and a cinematic has none): the cinematic draws its own strand down the edge.
8. **YAMA-DRAW's blade fire is off while an S5 cinematic runs** (`yama-s5-cine-p`, a guard in `yama-art.lisp`, the attacker only): without
   it the rest sheath and the stance corkscrew / drip would burn through 不知火's "nothing leaves the blade" and all of 撫斬.
9. **No `:spot` grade**: K4's three are in the Bankai's grey; the Shikai's fire is orange, and `:spot` keeps only the ember hue and the
   REIATSU yellow. Each cinematic runs in full colour under its negatives and manga frames.
10. **撫斬's attacker face is held calm** (`face-beat :neutral` for 2.6 s from f0): every cinematic attacker shouts (draw.lisp FACE-OF);
    "eyes shut, nothing moves" needs the closed mouth.
11. **The probe (87449) rows of the cinematic looks rewind the fx batches after each run** (`%ya-cons-per`'s new EACH argument, default
    off: the old rows expand as before): a cinematic's busiest frame holds more than a tenth of the toon batch, so ten runs without a
    rewind would measure the last ones on the full batch's skip path. The frame's own gate is `fx-dropped 0` on the stills runs.
12. **`%ya-feet` beside K4's `%ya-line`**: the looks that use only the actors' feet bind them there. Bound through `%ya-line` and left
    unused, its unit vectors cost one boxed float a draw (8 B, found by the probe: 不知火's and 焱熱地獄's rows read 80 B / 10 draws until
    then; isolated in scratch builds: a `%ya-line` whose FX / FZ go unused conses, one whose FX / FZ are used does not).
13. **The 爆炎 stills enter 爆炎 through YAMA-CINE-AT** (heat 87600 alone did not enter it while the held cinematic before had just
    ended), which clears the HUD's words (the GOKUEN callout) for the stills; the black radial marks under him in the 爆炎 stills are that
    entry's scorch (FEEDBACK `:hellfire`'s `stage-mark`, S4's §25.6), not the cinematics'.

### 26.3 The glyphs

`tools/glyph-bake.py` (Yuji Syuku, the font in the scratchpad's venv: fontTools 4.68 / skia-pathops). First the re-bake of the old CHARS
unchanged: `duel/lisp/glyphs.lisp` byte-identical to 22ee1330's (158 glyphs, 19567 points; sha256 dd1020cc…). Then CHARS + 撫焱熱: 撫 and
熱 from the font; 焱 is not in it (`not in the font: 焱`), so the script gained `COMPOSED` (a char → its component and one target box per
copy; 焱 = three 火, 1/1000 em boxes (265 10 735 465), (25 470 495 975), (505 470 975 975)). The new `glyphs.lisp` is the old file plus three
lines (161 glyphs, 20300 points): the 158 old entries untouched (the new script, run with the old CHARS, still writes the old file byte for
byte). A host check (`tests/duel-rules/yamamoto.lisp`) asserts every glyph of 不知火 / 焱熱地獄 / 撫斬 is baked and 焱 is three copies of 火's
polygons. The caption fit: no `brush: caption … off the screen` line in either stills run (landscape, portrait), and all four glyphs of
焱熱地獄 draw in the stills (26.5); there is no host test of that name, the brush's once-logged line is the check (K4's).

### 26.4 The tick finding (the wiring commit)

The wiring commit names the three in the Shikai's and 爆炎's `:core :kikon-cines` (yama.lisp; a host check). As K4 found (§19.2), a Kikon
cinematic's length is sim timing in ticks only: the damage frame does not move, RESET-ROUND (or the K.O. cinematic) runs LEN ticks after
the Kikon. Against the generic `soul-break-cine` (96 f): **不知火 +78, 焱熱地獄 +90, 撫斬 +60** ticks before the reset. CORE-SOUL-BREAK-CINE
reads the same list, so a Soul Break he deals in the Shikai or 爆炎 plays the current pointer's cinematic with the same cost.

Every line that moved, against BASE (22ee1330):

| Proof | Lines that differ from BASE | Why |
|---|---|---|
| Native trials (`combo-trial.py --log`) | `yamamoto-core`: 2 of 241, the `cine` names: Y10 (NS3a Kikon, pointer 3) `SOUL-BREAK-CINE` → `YAMA-NADEGIRI-CINE`, Y11 (NS1a wave Kikon, pointer 1) → `YAMA-SHIRANUI-CINE`. `-blaze` (268) and `-bankai` (513) identical | the trials skip cinematics (`*skip-cines* t`): no tick moves |
| `duel-yama-core.json` | 1 of 121: the NS3a Kikon's `cine` name (tick 1449) | its last scene: nothing after it is measured |
| `duel-yama-blaze.json` | none (44) | no Kikon |
| `duel-yama-s5-kikon.json` (new; only commands that exist at 22ee1330, so its BASE log is the same script on BASE) | the six `cine` names (`YAMA-SHIRANUI-` / `-ENNETSU-` / `-NADEGIRI-` / `-ENNETSU-` (爆炎) / `-NADEGIRI-` (the Soul Break under pointer 3) / `-ENNETSU-CINE` (the K.O.)); 城郭炎上's probe at t 399 (166 ticks after its Kikon at 233): BASE idle at 8 m (its reset at 329), wired still in the cinematic (CINE, 1.6 m: its reset at 419); 爆炎's scene: the probe at t 402 likewise (CINE), then at t 582 and the hash lines at t 588 / 600 equal but for his heat (43.2 for 28.2 at t 582: 15.0 = 90 ticks of 爆炎's decay, 10 a second) and Reishi (1153 for 1114: 爆炎's drain over 90 fewer ticks); the K.O.: KO-CINE at tick 419 for 329, RESULTS at ticks 569 for 479 (secs 9.5 for 8.0), its probe and hash lines at t=569 for t=479 with the state equal | +90 each (焱熱地獄 for 96): every moved number is the added length; the 不知火 / 撫斬 / Soul Break scenes' probes fall before the Kikon or after both resets |

So the wiring moves no rule, damage or state; only when the reset (or the K.O.) comes, by the length added. The native check, as K4's:
a scratch trial file (each pointer's Kikon in the Shikai and 撫斬's in 爆炎, 420 frames each) through `combo-trial.py` with
`tools/simgate/trial.lisp`'s `*skip-cines*` set to nil for the run (restored after): `cine YAMA-SHIRANUI- / -ENNETSU- / -NADEGIRI- /
-NADEGIRI-CINE` (the last `(BLAZE)`) play to their end in the native build, no Lisp error, the trials after them run.

### 26.5 Stills (untracked)

`tests/scripts/duel-yama-s5.json` / `-phone.json` (`tests/scripts/duel.py`'s `yama_s5_script`): each cinematic from 87482+i (the Shikai),
then 87485+i (爆炎), after 2.5 s idle, held at one frame per beat (87600+k), landscape (the 9 % letterbox) and portrait (`--mobile --size
390x844`, the deck on): `tests/shots/duel-yama-s5-<shikai|gokuen>-shiranui-<b0-held|b1-caption|b2-lights|b3-thrust|b4-columns|b5-shatter|
b6-tornado|b7-back>[-phone].png`, `…-ennetsu-<b0-held|b1-edge|b2-pattern|b3-pillars|b4-dome|b5-shatter|b6-inside|b7-wide>[-phone].png`,
`…-nadegiri-<b0-held|b1-face|b2-strike|b3-cut|b3b-out|b4-turn|b5-seam|b5b-shatter|b6-split|b7-wide>[-phone].png` (104 stills). Contact
sheets, the Shikai row over the 爆炎 row: `tests/shots/duel-yama-s5-<shiranui|ennetsu|nadegiri>-sheet.png` and `-sheet-phone.png`.

Checked by eye, both aspects, both forms: no actor blocks the lens after deviation 1's moves (the actors in frame wherever the storyboard
has them; 撫斬's face shot and 不知火's caption shot are of him alone, as written); 爆炎's rows show him bared with the scars lit and every
fire white-cored and taller; the victim reads inside the tornado (a black silhouette between the floor band and the next) and inside the
dome's white fire; the composed 焱 draws in every caption still, lighter than 熱地獄 (deviation 2). What the held stills show that play does
not: a negative or manga frame held on the shatter beats and 撫斬's cut (b3, b3b: the hold freezes the effect clock, so the 2-frame negative
stays); the caption half sliced out over the wide last shots in portrait (it slices out in play, K4's §19.4 note).

### 26.6 Checks

| Check | Result |
|---|---|
| Host tests | `duel-rules-test.lisp`: 4254 checks ALL PASS on the cinematics commits (+2: the caption glyphs baked, 焱 three 火), 4255 on the wiring commit (+1: the Shikai's and 爆炎's `:kikon-cines`) |
| pkgcheck, debug ranges, warnings | as main (the one `DUEL::APP` line, 0 redefinitions, 0 undefined); `tests/debug-ranges-check.py` 88 ranges, 0 errors (87482-87487 claimed in DUEL_GAMEPLAY "Debug commands", 87488-87489 left free); the build's warnings the same as 22ee1330's (positions only) |
| Native trials | not wired: `yamamoto-core` (241 lines), `-blaze` (268), `-bankai` (513) identical to 22ee1330's, every line; wired: the two `cine` names of 26.4, nothing else |
| Browser scripts | not wired: `duel-yama-core.json` (121 sim lines), `duel-yama-blaze.json` (44), `duel-yama-s5-kikon.json` (218) identical to a 22ee1330 dist's; wired: 26.4's table |
| Shared files (`--cvc`) | `python3 tests/style-gates.py cvc dist/duel`: II / IK / KK identical to `tests/style-cvc-ref.txt` (33 / 28 / 27 lines), not wired and wired |
| The looks gate (BASE a dist built at 22ee1330, no `--keep-base`) | not wired: **PASS, 83 / 83 byte-identical** (noise floor 0), every scenario's fighters and sim lines as BASE's. Wired: **82 / 83 identical; `cvc-yk/w3-0` differs and `cvc-yk sim lines` differ** (the `t=4200` .. `t=6600` hash lines; the match line and `t=600` .. `t=3600` identical), exactly 26.0's expected list: P1's Shikai Kikon at tick 4010 now plays `YAMA-ENNETSU-CINE`, the reset comes 90 ticks later, the CPUs read `*match-tick*`, and the match diverges after it (in the wired run Yamamoto awakens at 6545: w3-0 shows the 卍解 stamp where BASE's showed a Kenpachi Kikon's 両断). Every other still and scenario PASS. The YK scenario is to be re-based on the wiring commit's dist |
| 0 B a frame | debug 87449 (in the Shikai and in 爆炎, landscape and portrait): every row 0 B, the new `shiranui-30 / 50 / 60 / 100 / 118 / 130 / 160`, `ennetsu-26 / 50 / 62 / 100 / 114 / 132 / 150 / 168`, `nadegiri-52 / 112 / 124 / 150`, `s5-cine-p` included; 87448 every row 0 B; no row "(dropped)" |
| The fx batch | the cinematic pillar 72 vertices (no crown); `fx-dropped 0` on every stats line of both stills runs (28 a run) |
| The native sim | 26.4: the four Kikons with `*skip-cines*` nil play their cinematics to the end, no Lisp error |
| Build, smoke | `./build.sh duel` (then `git checkout -- vendor`), `run.mjs --secs 8` smoke exit 0 |
| Clip fallbacks | no `missing clip` line in the stills runs or the proof scripts (`ya-b-n3c` and `ya-blaze-in` play on the robed Shikai body, and each victim's own J) |

The branch was rebuilt once (the wiring commit first made at ad44c871, kept on `s5-wired-bak`): 撫斬's split shot hid Yamamoto behind
the victim, so a camera commit went in before the wiring and the wiring was cherry-picked on top. The not-wired proofs above stand for it
(a camera AT form is no sim state, and nothing before the wiring plays an S5 cinematic): the trials were re-run on it (identical, 241 /
268 / 513), host 4254. On the final head: host 4255, the three trials, the three browser scripts and the smoke re-run, every sim line equal
to the first wired run's (so 26.4's diff against BASE holds line for line); the stills re-shot; `--cvc` II / IK / KK PASS; the looks gate re-run on the head: the same 82 / 83 (`cvc-yk/w3-0` and the YK hash lines from t=4200 only).

### 26.7 Open (for the lead and the user)

- **The wiring** (26.4): each Shikai / 爆炎 Kikon (and Soul Break) now adds 78 / 90 / 60 ticks before the reset under 不知火 / 焱熱地獄 / 撫斬,
  as the Bankai's do since K4; reverting is the two `:kikon-cines` lines. The looks gate's YK scenario plays one (tick 4010), so its
  stills after it must be re-based on the merge (26.6).
- **For the user's eyes**: 不知火's columns read as tall cones (72-vertex pillars, no crown: §21.5.4's budget), and its tornado as stacked
  rings with wide gaps; 撫斬's pacing (28 f of a still face, a 54 f lowering); the composed 焱 (lighter strokes; 炎熱地獄 is the cheap
  alternative); 焱熱地獄's near pillars sunk to stubs in the side-on shot; the dome from outside as a fan of tongues.
- 撫斬 has no fire on the blade at all, and 不知火's blade is bare from the thrust to his last shot (the economy beats): the Shikai's
  everyday SL0 sheath is off there by design.
- 爆炎's version is the Shikai's staging in its dress (Q2); 不知火's "the 一 in its rhombus" and 焱熱地獄's haori hem have bared answers
  (deviation 4).

### 26.8 The merge (the lead, 2026-11-20)

- Merged as 3f69e585 on top of F1 and Z1, playtest v462. Conflicts: the 87448 probe (Z1 rewinds after every run, S5 only with EACH:
  kept Z1's, EACH stays as an ignored argument), the debug docstring / DUEL_GAMEPLAY row (both kept), `tests/scripts/duel.py` (both
  blocks), this doc (§26 before §27).
- On merged main: host tests 4262 pass, debug ranges 0 errors, pkgcheck as before, build and smoke (exit 0) pass. `--cvc` and the looks
  gate (BASE = main's dist before the merge, `looks-base-s5`; expected: `cvc-yk/w3-0` and the YK hash lines from t=4200 only, §26.0) are
  finished: `--cvc` PASS II / IK / KK; looks 82/83 with only `cvc-yk/w3-0` and the YK sim lines moved, as §26.0 wrote. The looks base
  is re-based to the merged dist (scratchpad `looks-base-s5m`).
- The lead's read of the sheets, for the user: 不知火's columns read as traffic cones and its tornado as stacked rings; the composed 焱 is
  lighter than 熱地獄; 撫斬's 28 f still face then 54 f lowering is slow; 焱熱地獄's near pillars sink to stubs side-on.

## 27. 殘日獄衣's mantle: the reference look (batch Z1, 2026-11-20)

The user, 2026-11-20, attaching a fan illustration of the flame cloak: 「殘日獄衣的造型應該是像附圖這樣，請你在做造型前先搜尋範例圖」. The
references were collected first: `docs/research/yamamoto-rework/zanjitsu-refs.md` (images in `.refs/yamamoto-zanjitsu/`: the user's
image, manga ch. 507 / 508, anime ep. 372). They agree on one closed flame mantle over the whole body, unlike the current L8.
- Current L8: ten separate tongues from the feet plus two small ribbon wings, about a third of the reference's size.
- Reference: the mantle is narrow at the ankles and flares upward. Two great wings of up-curling lobes spread at the shoulders. Lobes
  also rise above the head, to about 1.4x his height. The face and beard show in an opening; the feet show below the hem.
- Colour: yellow-white with a white rim and red-orange flame marks inside.

### 27.1 Decisions (AskUserQuestion, 2026-11-20; the user's answer in bold)

| # | Question | Answer | Rejected |
|---|---|---|---|
| Z-Q1 | When the mantle shows at full size | **「站姿縮小、招式和過場全尺寸」**: a small mantle in 西's stance; full size on the garb flares (NS2a, NS2b, AS2b) and in the 西 Kikon cinematic | full size whenever the pointer is 西; full size only in the cinematic |
| Z-Q2 | The full mantle covers the opponent from the behind camera | **「背面變淡」**: the faces turned toward the camera draw only the rim and the flame marks (hollow middle); from the front and the side it is the solid glowing shape | drawn as is; shrunk while seen from behind |

### 27.2 The spec (presentation only; the lead's numbers from the references)

| Item | Full (flares, cinematic) | Stance (small) |
|---|---|---|
| Silhouette | One closed mantle from the ankles up; about body-wide at the shins, widening through the hips. Sandals visible below. An opening for the face and beard near the top | the same shape language |
| Wings | One per shoulder at shoulder height, 4-5 lobes each, tips curling up; tips ≤ 1.9 m from his centre line, inside L8's 2.0 m burn footprint, so decoration never reads past the hit | about 0.6 m from the centre line |
| Top | 3-5 lobes rising to about 1.4x his height | about head height |
| Hem | 3-4 lobes at the knee curling out and up | the same, smaller |
| Colour | a yellow-white glowing body; a white rim; red-orange flame marks and dark holes inside; sparks drifting off. Within the fire hues | the same at lower intensity |
| Motion | the lobes billow and lick upward on the effect clock (twos); embers drift | breathing with the stance's 2.4 s loop |
| Behind camera (Z-Q2) | the faces toward the camera fade to rim plus marks as the camera comes round behind him; front and side solid | the same rule |
| Blade | outside the mantle, in the right hand (the clips as they are) | |

- Kept: the molten ring at his soles, its outer edge 2.0 m (the footprint rule, §21.6), and L9's armour hexagon.
- Replaced: L8's tongues and ribbon wings.
- The K4 西 cinematic's ignite beat (f52-72) and the beats after it draw the full mantle.
- 北 (canon: him wrapped in West's flames) is not in scope.

Checks:
- presentation only: the native trials, the browser scripts and `--cvc` are identical;
- 0 B a frame on the 87448 probe, `fx-dropped 0`;
- the looks gate: the expected diff is written first (the YK match's stills if seed 28 shows 西, and `select-3` if the select model draws it);
- stills of the stance, each flare and each cinematic beat: the match camera, the side, behind, portrait;
- the side-by-side with the user's image.

### 27.3 The looks gate's expected diff (written before the gate ran)

BASE = `dist/duel` built at 76b9be01 before any Z1 change. The mantle draws only for the Bankai (西's stance with no move, the flares of NS2a /
NS2b / AS2b, the 西 Kikon cinematic). Checked on BASE's own renders of the pinned YK match (seed 28, `--once --only cvc-yk`): Yamamoto is in
the Shikai in all seven stills (intro, start, w0-0 .. w3-0), so none shows 西. The select screen's models are drawn in their base form (no
Bankai). The other scenarios have no Yamamoto. Shared code: none touched (the consing probe's rewind is a debug line). **Expected: 83 of 83
stills byte-identical, no still listed.**

### 27.4 As built (batch Z1, 2026-11-20)

(Round 1. Round 2, §27.6-§27.8, replaced the outline, the bands, the strokes, the front layer and the hollow; where they differ, §27.7 holds.)

Code: `duel/lisp/yama-look.lisp` "殘日獄衣's mantle" (`*ya-mantle-keys*`, `*ya-skirt-keys*`, `ya-mantle-sample`, `ya-mantle-table`, the
`ya-mantle` macro, `ya-mantle-draw`), called from `yama-stance-look` (西's stance), `%ya-flare` (NS2a / NS2b / AS2b) and `%ya-garb` in
`yama-cine.lisp` (the 西 Kikon cinematic, f52-168). Presentation only: no sim file, no sim number.

**The shape.** One closed outline in a cylindrical billboard: U along the camera's horizontal right from his vertical axis, V up from the
floor, so it reads the same from the front, the side and behind (laid in his own right / up plane it would go edge-on from the SIDE
camera and in K4's side-on walk). The table is the right half in keys; it is mirrored and sampled 2 a key gap (Hermite; sharp keys at the
tips): 130 outline points.

| Item | Full (flares, cinematic) | Stance (Z-Q1: small) |
|---|---|---|
| Hem | 0.10 m (the sandals show below), 0.13 m out at the ankle | the same |
| Hem lobes | knee lobe tip 0.64 m out at 0.60 m, hip lobe 0.82 m out at 1.04 m | their reach out of the body's 0.24 m x 0.6 |
| Wings | 4 lobes each (the tip curled up 1.80 m out at 2.12 m, A 1.50 m at 2.18 m, B 1.10 m at 2.06 m, one hanging under the wing, hooked out) | spread x 0.34: the tip 0.61 m out |
| Column | 5 lobes over his head: the centre 2.38 m (1.44 x his 1.65 m), the inner pair 2.28 m, the outer pair 2.12 m; a valley at the neck (1.56 m, 0.50 m out) sets the wings apart from it | height over 1.3 m x 0.34: the top 1.66 m (his head) |
| Motion | the outline billows 0.07 m x its flex (0 at the hem's edge .. 1 at a tip), a sway out and a lick up, its phase by the length along the outline so neighbours move together, on the effect clock's twos | 0.03 m; the size breathes 8 % of the way to full on the stance's 2.4 s loop (twos) |

The fill is the strip between each outline point and its anchor on a skeleton tree inside the shape (the trunk, the hem lobes' branches,
the wing spines, the lobes' branches). A walk entry keeps the outline point and moves its anchor along the tree, so the anchor chain runs
the tree's edges and the strips cover the inside with no gap (a fan round a valley). Host-checked (`tests/duel-rules/art.lisp`): wing
<= 1.9 m (1.80), top / 1.65 in 1.3-1.5 (1.44), hem >= 0.08 m, worst strip fold -0.011 m² (a sliver), every anchor in the half it serves,
the front layer within 0.32 m and below 1.12 m.

**The layers** (all on the toon fx path, its existing shapes and palettes):
- the fill: one fan-flagged FIRE shape whose UV sits on the palette's core spot, so it is all the core #FFE483 (yellow-white), no shade,
  no edge, and the strips never seam; 0.5 m behind his body along the view ray (the body draws over it: his face, arms and blade show in
  front, the reference's "face in an opening");
- the white rim (HIT, -0.025 .. +0.035 m across the outline) and outside it the orange edge (FLAME, +0.015 .. +0.095 m; its shade is the
  outer line), each its own small offset on the view ray;
- 14 flame marks (8 in the stance) inside: FIRE (red-orange) and every third EMBER (dark red) tongues 0.14-0.28 m, rising 0.2 m and
  shrinking as they go, re-cycled on the clock;
- 12 white sparks (6 in the stance) drifting up off the outline;
- the front layer (`*ya-skirt-keys*`) at full size only: the same fill and rim 0.35 m in front of his body, body-wide (0.13 m at the
  ankle, 0.30 m at the hip) and below his hands (a flame at the hip 1.04 m, the centre flame 1.10 m), so his legs are engulfed and the
  hand and blade stay outside;
- an orange light at his chest.
Kept: the flares' molten ring on the 2.0 m edge with its white-hot first two frames, the cinematic's ring at his soles, L9's hexagon.

**Z-Q2.** The solidity S = 1 + (his facing · the way to the eye) / 0.17, clamped: solid from the front round to 90 deg, hollow from 100
deg. Measured with 87448's new line: the match camera stands 106 deg round at 2 m apart and closer (1.0 / 1.4 / 1.6 m: the same 105.8, the
close swing's cap), 112 at 4 m, 141 at 12 m; portrait 108 deg at 1.0-2.0 m (always hollow, 6 deg of margin); the SIDE camera 78 deg
(solid). Hollow, the fill is a band 0.07 m (x the size) in from the outline toward the anchors, widening with S (+3 S² m, so
solid well before S = 1); the rim, the orange edge, the marks (kept near the band) and the sparks stay; the front layer's presence is x S
(it erodes away as the camera goes round).

**Size and timing.** The flares grow from the stance's size to full over 2 frames from each pulse (`%ya-flare`'s old timing and fades
kept: NS2a f16 and f26, NS2b S14, AS2b S12). The cinematic builds it from f52 (size full in 3 f, presence 0 .. 0.98 over f52-56: the fill
grows from the skeleton out) and gutters f156-168 (the fill erodes from the outline in); from f124, when he stands turned away, its right
is his. The stance's small mantle does not draw while the 西 Kikon draws the full one (f124-168, the stance clip is back on).

**Vertices** (87448's line, one draw, of the toon batch's 16384): the stance 2520, a flare 2856 (behind; 3216 with the front layer, side),
the cinematic's f62 look 3408 with its rings. The 87448 probe now rewinds the fx batches after every run (ten mantle draws exceed one batch).

**Debug** (claimed in DUEL_GAMEPLAY): 87491-87493 a camera on P1 from his front / 45 deg / 135 deg, 6.5 m out (`yama-orbit-cam`).
Stills: `tests/scripts/duel-yama-z1.json` (and `-phone`).

**Deviations, with reasons.**
- The fill is FIRE's core (#FFE483), not FLAME's cream: the Bankai's world grade (spot-keep: hue 10 / 48 deg above saturation 0.45)
  greyed FLAME's cream core (#FADBA5, saturation 0.34) to white-grey in the first build; FIRE's core keeps its yellow.
- No hole for the face: the sheet sits behind his body, so his head (and arms, blade) draw over it; the column's lobes frame the head.
- The arms are not engulfed (the reference shows only the hands): the front layer stops below the hands so the blade stays outside, as the
  spec asks.
- The stance has no front layer (small mantle only, behind him).

### 27.5 Checks and stills (batch Z1)

| Check | Result |
|---|---|
| Host tests (`tests/duel-rules-test.lisp`) | 4259 checks ALL PASS (the mantle's 7 new) |
| `tools/pkgcheck.sh duel` | no undefined / redefined; the one `DUEL::APP` note is BASE's too |
| `tests/debug-ranges-check.py` | 88 ranges, 0 errors |
| Native trials (`combo-trial.py --log`: yamamoto-core / -blaze / -bankai) | identical to 76b9be01's, every line (242 / 268 / 513) |
| Browser `duel-yama-core.json` (`--secs 40`) / `duel-yama-blaze.json` | identical to BASE dist's combat / duel / scene lines (123 / 46), exit 0 |
| `style-gates.py cvc dist/duel` | PASS II IK KK |
| Looks gate (BASE at 76b9be01, no `--keep-base`) | 83 of 83 byte-identical, noise floor 0: as written in §27.3 |
| 87448 consing probe | every row 0 B after the cinematic run (the mantle rows `garb`, `mantle-flare`, `mantle-throw`, `west-ignite`, `west-full`, `west-walk` ...); `fx-dropped 0`, no "(dropped)". In a fresh Bankai scene `south-dead` / `south-pile` / `south-burst` read 80 B: BASE reads the same (not the mantle) |
| Smoke (`run.mjs --secs 8`) | exit 0 |
| Stills runs | `duel-yama-z1-phone.json` exit 0; `duel-yama-z1.json` exit 1 from run.mjs's wall timeout at virtual 79.3 s, after its `=== END`: every still and the 87448 line were written before it (the header now passes `--timeout`) |

Stills (`tests/shots/duel-yama-z1-*.png`, untracked): `stance-` / `ns2a-` / `ns2b-` / `as2b-` × `behind` (the match camera, hollow),
`side` (SIDE camera, solid), `front` (87491), `q45`, `q135`, and `-behind-phone`; the 西 Kikon `cine-f54 f62 f80 f100 f128 f146 f160
f170`; `sheet-ref` (the user's image beside the front / side flares and the cinematic), `sheet-before-after` (L8 vs the mantle).

Open (for the user's eyes):
- The lobes are pointed teeth and the outline zigzags under the rim's boil; the reference's lobes are broad, rounded and swept, its wing
  tips long hooks. The key table is the knob (`*ya-mantle-keys*`).
- From the match camera it is the hollow outline: on a phone it reads as a zigzag line of white and orange round him.
- The fill is flat yellow-white; the reference whitens toward his body.
- In the cinematic's close shots (f62, f146) it fills most of the frame.
- At f168-180 of the 西 Kikon, after the full mantle gutters out, the stance's small mantle comes back (the stance clip is on; BASE's
  stance tongues showed there too): extending the guard in `yama-stance-look` to the whole cinematic (`cf < 180`) would end it on the
  gutter, as the storyboard has it.

### 27.6 Round 2 (the lead's review, 2026-11-20): the looks gate's expected diff, written first

The lead, reviewing §27.4's stills against the user's image: the outline read as teeth and a zigzag (an explosion, not flame); he must
read as inside the flame; flat bands (white-hot, yellow, orange); curved strokes; a translucent hollow view; the same shape language in
the stance; the f168-180 reappearance; judged under main's soft-flame shader (668dcd1e, STYLE_STORM_DESIGN §15), merged into the branch
first. BASE for this round = `dist/duel` built at 668dcd1e. The mantle still draws only in the Bankai (西's stance, the three flares, the
西 Kikon), none of which a pinned still shows (§27.3's check); the one engine change is an export (`*msaa-samples*`). **Expected: every
still byte-identical to BASE, none listed.**

### 27.7 Round 2 as built

Same entry points as §27.4 (`ya-mantle` from 西's stance, `%ya-flare`, `%ya-garb`); `yama-look.lisp`'s mantle section rewritten.

- **The outline, traced.** The user's image thresholded to its flame mask, set at his scale (1.65 m tall: 236 px a metre, his axis at x
  365, the floor at y 578), and the right half keyed on it (the right side is the clean one; mirrored). Catmull-Rom through every key (no
  sharp key; tips and hooks from keys set close), 2 samples a gap: 188 points. The keyed outline covers the mask's flame within its glow
  (`tests/duel-rules/art.lisp` checks the numbers; the scratch tracer's gap 322 px and overcover 56 px of 156 573 at the image's scale).

| Item | Round 2 (full) | Stance |
|---|---|---|
| Hem | 0.13 m, 0.17 m out at the ankle | the same |
| Knee-hip lobe | rises out to 0.66 m at 0.93 m, its tip hooked back in at 1.01 m (one a side) | its reach out of the body x 0.6 |
| Notch under the wing | 0.30 m out at 1.20 m | |
| Wings | three swept lobes rising outward: the outer 1.55 m out at 2.04 m, hooked back over (2.09 m); the middle 1.04 m at 2.22 m; the inner 0.70 m at 2.10 m | spread x 0.39: 0.60 m |
| Column | five tongues: the centre 2.42 m (1.47 x), the inner pair 2.34 m, the outer pair 2.33 m; the valley at the neck 0.48 m out at 1.80 m | height over 1.3 m x 0.39: 1.74 m |
| Motion | a smooth, slow displacement of the tips (0.07 m x the flex; a sway out and a lick up, its phase running along the outline: one wave across a lobe) on the continuous effect clock (the soft-flame flow's clock) | 0.04 m; the size breathes 8 % toward full on the stance's 2.4 s loop |

- **Flat bands** (F-Q1): the fill FIRE's core #FFE483 (yellow-white); a white-hot band (HIT) deeper than 0.3 m from the outline (full
  size: the trunk, the wing roots, the column's middle round his head); an orange band (FLAME's body) 0.05 m inside the outline to
  0.035 m outside it, its outer edge feathered by the soft-flame pass (its UV runs 0 .. -1 across it: a silhouette at the outside, no
  shade); the white rim (HIT) -0.018 .. +0.022 m, no boil (a clean line). The inner bands' edges are flat cuts (a fan's field held under
  the presence: no shade band, so no feather either).
- **Strokes:** 16 (7 in the stance) curved comet strokes, FIRE and every third EMBER, 0.28-0.48 m, 0.075 m wide at the base and tapering
  to the tip, bending alternately left and right, leaning out with the outline, rising 0.1 m and fading as they cycle; seated 20-50 % of
  the way from an anchor to its outline point.
- **Inside the flame:** at full size the front layer (`*ya-skirt-keys*`, 36 points) covers his torso and legs from the ankles to a dip
  under the chin (1.31 m; the shoulders 1.40 m, 0.31 m wide at the hip and chest), 0.35 m in front of his body, see-through: glass 3 (3 of
  4 MSAA samples) of FIRE's core, so his body shows dimly through and his head, hands and blade stay clear; its presence x S.
- **Z-Q2, the hollow:** solid to 90 deg, glass from 100 deg (unchanged). Seen from behind the fill turns see-through (glass 3 while S >=
  0.45, then glass 2) and the white-hot band is left out; the rim, the orange band and the strokes stay. The see-through fill is FIRE's
  red-orange body, not the yellow: half-covered, the yellow mixes with the grey stage to a saturation under the Bankai's spot-keep grade
  (0.45) and turned grey in the stills; the red-orange keeps its hue. Glass 1 (the lead's suggestion) read as an empty outline: glass 2.
- **Without MSAA** a glass shape is opaque (the shader keeps it opaque below 2 samples): there the hollow drops the fills and the orange band
  (the rim and the strokes stay) and the front layer is not drawn (`*msaa-samples*`, now exported by the engine). Not shot: the build always gets 4
  samples where the GPU supports it (SwiftShader does), and there is no switch to force 1.
- **The f168-180 reappearance:** the stance's small mantle does not draw for the whole 西 Kikon (`cine-name` = `yama-nishi-cine`), so the
  garb ends on its gutter.
- **Vertices** (87448's line, of the toon batch's 16384): the stance 3756; a flare 4416 seen from behind, 5868 solid with the white-hot
  band and the front layer; the cinematic's f62 look 6060 (the most).

### 27.8 Round 2 checks, stills, verdict

| Check (final build, branch merged with main 668dcd1e) | Result |
|---|---|
| Host tests | 4259 checks ALL PASS (mantle: 188 points, wing 1.55 m, top 2.42 m, worst strip fold -0.012 m², front layer 36 points) |
| pkgcheck / debug-ranges-check | no undefined or redefined (the one `DUEL::APP` note is BASE's); 89 ranges, 0 errors |
| Native trials vs 76b9be01 (core / blaze / bankai) | identical, every line (242 / 268 / 513) |
| Browser `duel-yama-core` (40 s) / `-blaze` vs a dist built at 668dcd1e | 0 diff lines (123 / 46), exit 0 both |
| `style-gates.py cvc` | PASS II IK KK |
| Looks gate, BASE = dist at 668dcd1e, no `--keep-base` | 83 of 83 byte-identical, noise floor 0: as written in §27.6 |
| 87448 | every mantle row 0 B, `fx-dropped 0`, no "(dropped)" (the stills runs too); `south-dead` / `-pile` / `-burst` 80 B in a fresh scene, as on BASE |
| Smoke (`node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 8 > log 2>&1; echo $?`) | 0 |
| Stills runs (`--timeout` now passed) | `duel-yama-z1.json` exit 0, `-phone` exit 0 |

Stills: the same names as §27.5, re-shot; `duel-yama-z1-sheet-ref.png` now puts the user's image beside each view at the same scale
(his height in the still = his height in the image), `duel-yama-z1-sheet-before-after.png` L8 (76b9be01) against round 2.

Verdict (honest): the silhouette now follows the reference (traced from it: the swept wings with the hooked outer tip, the column of
tongues, the knee-hip curls, the narrow hem) and reads as flame, not as an explosion; front and side it is a solid banded mantle he
stands in, from behind a translucent red-orange one with the opponent in view. Still short of the image: the image's body of flame is
broad and full of large dark-red flame strokes and soft glow, while ours is flat bands with small strokes; the column's five tongues are
of near-equal height (a crown) where the image's are uneven and leaning; the front layer's yellow over his black robe reads khaki rather
than fire; the wings' inner lobes are smaller and stiffer than the image's billowing ones.

### 27.9 The merge (the lead, 2026-11-20)

- Round 1 went back (spiky teeth on a flat card, no bands, a scribble from behind); round 2 merged as de0f024b, playtest v461, beside the
  user's image in `tests/shots/duel-yama-z1-sheet-ref.png`.
- On merged main: host tests 4259 pass, the build and smoke (exit 0) pass, `--cvc` re-run; the looks gate stands on round 2's run
  against the dist at 668dcd1e (83/83), the only main commit since being docs.
- The lead's read of the sheet: the silhouette now reads as the image's (swept wings, the hooked outer tip, the knee curls). Still off,
  for the user to rule on: the column over the head is five near-equal spikes (a crown; the image's tongues are uneven and leaning);
  the fill is flat bands with small strokes (the image: a broad body full of large dark-red strokes); the glass front layer over the
  black robe reads khaki; from behind the mantle turns red-orange (the Bankai's grade greys the yellow); 37 % of the fx batch at most.
- Manual: the Bankai paragraph gets one sentence on the mantle.

## 28. The user's playtest of v462: 城郭炎上 back to the old look, the old 殘日獄衣, flames at 80 % (2026-11-20)

The user, 2026-11-20, after playing v462:
1. 「NS 跟 AS 的 城郭炎上 反而是重作前的版本更有魄力，而且現在 NS 的火圈在靠太近時反而包不住人」
2. 「殘日獄衣我覺得 ai-cl-game-test 的原版就做的不錯阿？只要把面對鏡頭的火焰也顯示出來就很好了」
3. 「火焰請用 80% 半透明來表示」
4. 「其他繼續修」

### 28.1 What each means (the lead's reading)

- **(1) The look.** "Before the rework" is batch 1 (05acf777, v446): the ring was six `vfx-fire-pillar` columns on the circle and the
  dome was the old Jokaku Enjo `vfx-fire-dome` (three tiers of fire tongue rings, the detonation star), both ported from the retired
  TYBW kit. Art S3 / S4 replaced them with the SL5 tongue wall (`yama-ring-look`) and SL6 dome. Both old functions left `main` in S3 / S4.
  So NS2 / AS2's ring and dome go back to the old shapes, re-ported into the current tier / palette / 0 B framework (batch J1).
- **(1) The ring that misses.** This is a sim bug, not a look. `ya-bearing-point` clamps the ring's centre to `:near 3.0` m.
  - With the victim 1 m away, the ring (r 1.6) is centred 3 m out, so he stands about 2 m from its centre, outside the fire.
  - Fix: `:near 0` on NS2b, NS2c and their 爆炎 copies, so the ring and the dome land round him at any distance (AS2b has 0 already).
  - It is a sim change: a scripted scene at 1 m and 5 m, `--cvc` identical (no Yamamoto pairing in it), YK's looks lines move.
- **(2) The garb.** "ai-cl-game-test's original" is the TYBW kit's `:garb` aura. The old repo's last `main` (1c19d18, 2026-10-27)
  and the `retired-kits` branch have the same code: orange FLAME `%brush-aura` tongues from the feet up, two wings of three ribbons
  at the shoulders, a molten double ring, scraps, a warm light, K > 1 flaring it.
  - It deliberately drew only behind and at the sides (`%brush-aura`'s skipped camera side, the wings inside `%away-from-eye`) so the
    silhouette stayed readable. "Show the flames facing the camera" flips exactly those two.
  - The Z1 mantle (§27) is replaced; Z-Q1 (the stance shrunk, moves and cinematics full size) and Z-Q2 (the back faded) are
    superseded. The old `:hellfire` aura (爆炎) sits in the same function and is ported with it, closing "the :hellfire aura draws
    nothing" (batch J2).
- **(3) Flames at 80 %.** Read as opacity 0.8 (不透明度 80 %), one knob. The scope is F1's flame class (STYLE_STORM_DESIGN §15.3 /
  §15.5); bodies stay opaque. Recorded in STYLE_STORM_DESIGN §15.6 (batch J0).
- **(4) The rest.** S5's open looks (§26.8: the cone-shaped 不知火 columns and the stacked-ring tornado, the light composed 焱, 撫斬's
  long still face and sheathing, 焱熱地獄's near pillars as stubs), 爆炎 NS2b playing NS2c's clip, stance 3's barely visible blade
  (batch J3); then F1's Lisp `drawing-no` sweep once J0-J3 have merged (it touches every flame site, so it runs alone).

### 28.2 The batches

| Batch | What | Owns (functions / files) |
|---|---|---|
| J0 | flame opacity 0.8: the flame class composited at one alpha (no stacking of overlapping tongues) | engine `render.c`, `render.lisp`, `fx-toon*.wgsl`, composite shaders |
| J1 | 城郭炎上: the old pillars and dome back, `:near 0` | `yama-ring-look`, `yama-dome-look`, `yama-lance-look` if it changed, NS2 / AS2 move params in `yama.lisp` |
| J2 | 殘日獄衣: the old `:garb` with its front flames, the old `:hellfire`; the Z1 mantle and its probes / scripts out | the 西 mantle code in `yama-look.lisp`, the aura hook |
| J3 | S5 fixes, 爆炎 NS2b's own clip, stance 3's blade | `yama-cine.lisp`, its stills, `yama-art.lisp` clips |

Merged one at a time; the looks gate re-based after each.

### 28.3 As built (J1)

**The looks gate's expected diff (written before the run).** BASE = a dist of main at the S5 merge (`looks-base-s5m`, code-equal to
d7d17b1a). J1 touches only Yamamoto: three hazard looks (NS2a's wave, the ring, the dome) and `:near` on NS2b / NS2c / 爆炎 NS2b. Expected:
- Every scenario without Yamamoto (KH, HK, II, IK, cine-ken, cine-ko, cine-ichigo, fx-a, mobile) and `menus` (his select still draws no
  hazard): byte-identical, sim lines as BASE's.
- `cvc-yk` (seed 28): its sim moves only from the first NS2b / NS2c / 爆炎 NS2b fired with the victim inside 3 m (the ring or the dome
  now lands round him, so hits and the hash lines may change from that tick); AS2's ring snaps on the victim and its dome lands on the
  ring, so AS2 alone moves nothing. Its looks move on any still with a ring, a dome or an NS2a wave on screen. S5 recorded his first
  Kikon (J1 J2 > AS2) at tick 4010, so at least `cvc-yk-w3-0` (tick 6898) can differ; `intro`, `start`, `w0-0`, `w1-*` and `w2-0` differ
  only if one of those looks is in frame or an NS2b / NS2c inside 3 m came before them (read from the logs' `ring at` / `dome at` lines).
- **Result**: 82 / 83 byte-identical (noise floor 0). `cvc-yk-w3-0` differs (tick 6898, after the divergence), `cvc-yk` sim lines differ
  from `t=3600` (`t=600` .. `t=3000` and the match line identical): BASE's 4th NS2b (tick 3444) landed its ring at (1.85, -4.99), clamped
  3 m out; with `:near 0` the route plays differently from there (the CPU's full-sim rollouts read the move too). Every other scenario:
  identical, fighters and sim lines as BASE's. As predicted.

**Task A: the ring that misses (sim).** `:near 3.0 -> 0.0` on `:ya-n2b`, `:ya-n2c`, `:ya-b-n2b` (AS2b / 爆炎 AS2b had 0 already);
`ya-bearing-point` itself unchanged (its host test passes explicit near / far). `+ya-dome-near+` (YAMA-RING-CLOSE's predicted spot,
host-checked against `:ya-b-n2b :near`) 3 -> 0. The script (`tests/scripts/duel-yama-j1.json`, debug 87010 / 87050: P1 at x -d/2, P2 at
+d/2 on z 0; combat lines `ring at` / `dome at`):

| Scene | P2 at x | before (main, = batch 1) | after (J1) |
|---|---|---|---|
| NS2b, 1 m | 0.50 | ring at 2.50: P2 2.0 m from its centre, standing on the band, so the ring burned him twice on landing (2 x 20) but did not enclose him | ring at 0.50: round him; no hit on landing (inside the band is free, Y8); he burns when he crosses it |
| NS2b, 5 m | 2.50 | ring at 2.50 | ring at 2.50 (unchanged) |
| NS2c alone, 1 m (heat 0 / 25) | 0.50 | dome at 2.50 (hit 80: the dome's reach plus his hurt radius caught him at 2.0 m) | dome at 0.50 (hit 80) |
| NS2c alone, 5 m | 2.50 | dome at 2.50 | dome at 2.50 |
| 爆炎 NS2a > NS2b, 1 m | 0.50 | dome at 2.50 (hit 80) | dome at 0.50 (hit 80) |
| 爆炎 NS2a > NS2b, 5 m | 2.50 | dome at 2.50 | dome at 2.50 |
| AS2 (J J > AS2a > AS2b), 1.4 m | (0.75 after the hits) | ring 0.75, dome on it | the same (AS2 was already 0) |

Docs: §7.1's NS2b cell now reads 0-8 m; the code comment and YAMA-RING-CLOSE's docstring too. The 3-8 m in §11's table (line ~225),
§13's (~367), §21.2's SL6 row and §25.1's NS2b row are as-built records of their batches, superseded here.

**Task B: batch 1's looks back (presentation).** Reference = 05acf777 (v446), built in a scratch worktree and shot with the same script
as main and J1 (stills `tests/shots/duel-j1-*.png` = J1, `duel-j1-old-*.png` = batch 1, untracked; sheets
`tests/shots/duel-j1-sheet-behind.png` / `-side.png`, columns batch 1 | main | J1). In `yama-look.lisp`, same names and signatures:
- `yama-lance-look` (NS2a): batch 1 had no lance; NS2a drew `yama-wave-look` -> `vfx-fire-wave`, a 2.6 m FIRE crescent wall as wide as
  the box. Main's SL4 was a 1.1 m-high lens: it lost the force, so the wall is back (its body re-ported: EMBER backing wall 20 % taller,
  6 scalloped tongues, edge-on tongues, the lens at 1.2 m, scorch, T光 base lines, scraps; envelope 1 3 hold 18 with the white burst on
  its first drawing; it sinks to 0.4 passing the lens). One change: the crescent's middle sits on the box's front (+0.5 m), its bowed ends
  inside the box. The `*wave-ghosts*` erosion after a hit is not ported (draw-side state).
- `yama-ring-look`: six `%ya-pillar` columns (batch 1's `vfx-fire-pillar` as a 0 B macro: EMBER backing, FIRE column, the twisting stripe,
  the 6-tongue crown, the foot scorch, scraps) 1.4 m high on the circle, plus SL5's EMBER band ±`+ya-ring-band+` on the floor (the
  footprint: it burns between the pillars too). The pillar base half-width is clamped 0.32 -> 0.25 (inside the band) and the foot
  scorch ring shrunk to stay inside it. Batch 1's pillars rose from nothing at age 0; they now stand one drawing up on the first frame
  (§22.2's hit frame: AS2a's snap lands the ring in hitstop). The charge: 2 hits full, 1 hit x0.7 high and x0.8 thin, 0 only the band.
- `yama-dome-look`: batch 1's Jokaku Enjo from its seethe on, as a function of the hazard's age (no `*dome-last*`, no `stamp`): ages
  0-2 the closed three-tier dome (12 + 9 + 6 FIRE tongues leaning in, EMBER backings on the outer tier, boiling scraps, 1.15 r high), from
  age 3 the detonation drawn from `age - 3`: batch 1's `:boom` (the white flash, the 14-spike FIRE star over the EMBER one, the white core
  for 2 drawings) and its `:ring` FIRE shockwave, the flame / smoke / ember burst emitted by rate over ages 3-5 (batch 1 threw 26 + 10 + 16
  at once), the 16 m light fading in 9 f. The footprint ring sits inside the disc's edge.
- Heat: T0 draws batch 1's silhouette as it was (`%ya-up` 1.0: the ring and AS2b's dome are always T0 in the Shikai, and NS2c and NS2a are T0 when no heat is
  paid, so §21.2's T0 x0.6 / 60 % would have drawn them below batch 1: a deviation from §21.2's T0 row, for 「更有魄力」). T1 / T2 and every 爆炎 segment grow x1.15 /
  x1.3 (`%ya-up` from `%ya-hf`) and take `%ya-core`'s white core (30 / 60 % of the width) inside each pillar, tongue and the wave; T2 keeps
  the dome's EMBER scorch disc. Palettes FIRE / EMBER / HIT only (the soft-flame pass's flame class).
- Probes (debug 87449): new rows `ring-rise` (age 1), `ring-t2`, `dome-seethe` (age 0), `dome-seethe-t2`, `dome-boom` (age 3),
  `dome-boom-t2`, `lance-flash` (age 0); all read **0 B**, as do the old rows (`lance-t-*`, `ring-hits-*`, `dome-t-*`, `ring-close`). (A
  first build read 240 B on the lance: `(* 2f0 (hazard-size hz))` and `(+ (hazard-x hz) ...)` went through generic arithmetic; the reads
  are now bound typed first. The probe macro binds `D0` / `F0` / `N0` itself: a stand-in named `d0` was shadowed by `*fx-dropped*` and
  stopped the page; renamed.)

**Checks**: host tests 4262 ALL PASS (the FK reach test and the looks' no-writes walk included); pkgcheck clean but the old `DUEL::APP`;
`./build.sh duel` 0 (vendor restored); smoke 0; `--cvc` II / IK / KK identical; looks gate as above.

**Open (for the lead and the user)**:
- The white burst on the wave's first drawing and the dome's white flash / core are batch 1's, kept as the user's reference, though
  §21.2 gives white to heat alone.
- At 1 m the ring and the dome now sit round both fighters (he stands 1 m from the centre): the dome and its detonation cover Yamamoto
  from the behind camera for ~10 f. The cost of the fix; the stills `duel-j1-dome1m-*`.
  On the phone (390 x 844, `duel-j1-*-phone.png`, sheet `duel-j1-sheet-phone.png`: batch 1 | J1) the 1 m ring's near pillar stands at
  the lower left of the frame and the 1 m dome fills it; the 5 m ring and dome read as batch 1's.
- NS2b at point blank no longer burns on landing (main's off-centre ring caught a 1 m victim on its band for 2 x 20); the ring now traps
  him and burns when he crosses it.
- 爆炎 NS2b still shows SL5's low tongue ring (YAMA-RING-CLOSE, f12-15) before batch 1's dome: not in J1's scope (J3 gives that move its
  own clip).
- The pillars read a little slimmer than batch 1's (base 0.25 for the band, was 0.32).
### 28.4 As built (J2)

**Looks gate expectation (written before the gate ran).** BASE = `dist/duel` built on main after S5 (`looks-base-s5m`). The garb draws only in the Bankai (西's stance clip with no move, the three
flares, the 西 Kikon cinematic); `:hellfire` draws whenever 爆炎 (GOKUEN) is on screen. Checked on BASE's own renders of the pinned YK match
(`--once --only cvc-yk`): Yamamoto is in the Shikai in intro, start, w0-0 .. w2-0 (no bare torso, no scars) and enters the Bankai in w3-0
with the 東 pointer (旭日刃 on the HUD): no still shows 爆炎, 西's stance or a 西 flare. `%brush-aura`'s default expansion is unchanged (the
new optional ALL is T only for the garb), so Kenpachi's auras are the same code. **Expected: 83 of 83 stills byte-identical, none listed.**

**Ported** (presentation only; no sim file, no sim number):
- `vfx.lisp`: the TYBW kit's `:garb` as the macro `%garb-aura` (orange FLAME `%brush-aura` tongues 0.8 h x 9 at 0.34 m and 0.62 h x 6 at
  0.25 m; two wings of three `toon-ribbon`s at the shoulders, to the camera's left and right; the molten double `%tring` at the feet;
  `%t-blob` scraps; a warm `%light`; K < 1 fades it, K > 1 flares it taller x K and wider x 1 + 0.3 (K - 1)), used by `vfx-aura`'s new
  `:garb` case; and the old `:hellfire` case verbatim (7 FIRE tongues behind and at the sides, 8 short FIRE tongues licking at the feet, an
  EMBER scorch ring, scraps, a light). The FLAME (15) and FIRE (0) palettes are both soft-flame class. Code from `retired-kits`
  `duel/lisp/vfx.lisp` (= the old repo's last main 1c19d18).
- **The front flames.** `%brush-aura` takes an optional literal ALL: T draws the camera-side tongues too (the garb's two layers); every
  other caller's drawing is unchanged. The wings no longer sit inside `%away-from-eye` (they were pushed 0.22 m back along the view ray).
- **0 B.** The first build read 32 B a garb draw (debug 87448). A probe split it: each `%brush-aura` boxed the floats it binds and never
  reads (the unused bindings, declared IGNORABLE, were boxed in the generated C; unused ones without the declaration were not): `wpal` whenever WHITE is 0 (8 B, every caller's: Kenpachi's
  `nomihose` / `oni` / `evolution` rows read 80 B per 10 draws on BASE too) and `el` once ALL is T. `%brush-aura` now binds the eye's side
  only when it reads it and `wpal` only when WHITE is 1; the computation of every drawn tongue is the same expression as before.
  Since then every garb / hellfire row reads 0, and so do `nomihose`, `oni`, `oni smoulder` and `evolution` (80 B before).
- `yama-look.lisp`: `ya-garb` (x z k into `*ya-garb-args*`) and `ya-garb-draw` (one `%garb-aura` expansion, h = `+ya-garb-h+` 1.815 m =
  1.1 x his 1.65 m hurt height, as `draw-aura` passes a form aura; the scraps on `*ya-rdt*`), so no float is boxed: 0 B.
  - 西's stance (`yama-stance-look`): `ya-garb` at K 1, the old look's own size (Z-Q1's "stance shrunk" superseded). Still skipped while the
    西 Kikon cinematic runs (it draws its own).
  - The flares (`%ya-flare`, NS2a f16 / f26, NS2b S14, AS2b S12): K = fade x (1 + 0.9 x growth), the growth 0 .. 1 over the pulse's first
    2 frames, so the garb flares to 1.9 x (the old "garb-flare" probe's K) and, as the fade runs, shrinks back to its stance size and then
    fades. The 2.0 m molten ring and the white-hot first two frames are kept.
  - The 西 Kikon cinematic (`yama-cine.lisp` `%ya-garb`, body only; the call and its shots untouched): the same K from its growth G and
    presence; its soles' ring kept, its own light dropped (the garb brings one).
- `:hellfire` now draws: the 爆炎 kit's `:aura :hellfire` reaches `vfx-aura` through `draw-aura` as before; until now the keyword fell
  through to the function case and drew nothing.

**Removed** (everything that only served Z1's mantle): `*ya-mantle-keys*`, `*ya-skirt-keys*`, `ya-mantle-sample`, `ya-mantle-table`,
`*ya-mantle*`, `*ya-skirt*`, `*ya-mt-args*`, `*ya-mt-buf*`, the `ya-mantle` / `%ya-mt-at` / `%ya-mt-shape!` / `%ya-mt-fill` / `%ya-mt-band`
macros and `ya-mantle-draw` (yama-look.lisp, ~250 lines); `%ya-flare`'s unused RX RZ; 87448's mantle vertex-count / eye-angle line; the
mantle sentence of `%ya-cons-per`'s docstring (the per-run rewind stays: S5's rows rely on it); debug 87491-87493 and `yama-orbit-cam`
(yama.lisp; the `(87000 87999)` range itself stays), its clause in DUEL_GAMEPLAY's 87000-87999 row (now "87491-87493 free"); the `yama-z1`
block of `tests/scripts/duel.py` and `duel-yama-z1.json` / `-phone.json`; the mantle's 7 host checks (`tests/duel-rules/art.lisp`).
Left: the engine's `*msaa-samples*` export (Z1 exported it; an engine file, no other user now).

**Checks** (final build; presentation only, no sim file touched):

| Check | Result |
|---|---|
| Host tests (`tests/duel-rules-test.lisp`) | 4255 checks ALL PASS (Z1's 7 mantle checks gone with it) |
| `tools/pkgcheck.sh duel` | 0 undefined, 0 engine redefinitions; the one `DUEL::APP` note is BASE's |
| `tests/debug-ranges-check.py` | 89 ranges, 0 errors |
| Smoke (`run.mjs --secs 8`) | exit 0 |
| `style-gates.py cvc dist/duel` | PASS II IK KK (identical to the reference) |
| Looks gate, BASE = `looks-base-s5m`, no `--keep-base` | 83 of 83 byte-identical, noise floor 0, every scenario's sim lines identical (cvc-yk's 12 too): as written above |
| 87448 / 2328 / 2390 | every garb row 0 B (`garb`, `garb-flare`, `garb-throw`, `flare`, `west-ignite` .. `west-column`; vfx `garb`, `garb-flare`, `hellfire`), `fx-dropped 0`; `south-dead` / `-pile` / `-burst` 80 B in a fresh scene, as on BASE |

**Stills** (`tests/shots/duel-j2-{before,after}-*.png`, untracked; before = BASE with the Z1 mantle, after = J2):
`stance-` / `ns2a-` / `ns2b-` / `as2b-` × `behind` (the match camera) and `side` (SIDE); `f-…-q45` (45 deg off his front: the
orbit camera, shot on a J2 build before 87491-87493 were removed; the `f-…-front` ones have Kenpachi between the lens and him, so the
frontal evidence is q45 and the cinematic's f62 / f146); `cine-f54 … f170` (the 西 Kikon); `blaze-behind` / `-side` (爆炎; BASE draws
nothing there); `-phone` versions (390 x 844, the behind camera); `duel-j2-sheet.png` / `duel-j2-sheet-phone.png` (before | after).
The desktop after stills come from the J2 build before the `%brush-aura` binding fix (the same drawing expressions; the looks gate shows
the fix moves no pixel of the other callers); the phone after stills from the final build.

**Open points for the user:**
- In the 西 Kikon's close frontal shots (f62, f100, f146) the flared garb (K about 1.86) covers him whole: the front tongues stand
  between the lens and his body, so only the column of flame shows. From the match camera (behind) his back and head show between the
  tongues, and from the side he reads inside them. Nothing was faded (the user did not ask for it); if the cinematic should show him,
  the knob is the cinematic's K (`%ya-garb`) or the front layer's height.
- (Closed by the follow-up below: the garb is 西's form aura now, drawn through every move under 西.)
- `:hellfire` keeps the old rule (behind and at the sides only); the user's front-flames request was for 殘日獄衣.
- 87491-87493 are gone, so there is no front camera on P1 now; a front still needs P2 off the line or a cinematic frame.
- The manual's Bankai sentence on the mantle and STYLE_STORM_DESIGN §15.3's inventory (`%ya-garb`, the mantle) are the lead's to update.

**Follow-up: the garb as 西's form aura** (the lead's review of 798b3789, 2026-11-21: the original drew the garb as the West form's aura
through every 西 move, so draw it whenever he is in the Bankai under 西).
- `yama-draw` (yama-art.lisp, the :draw hook) calls `yama-garb-at` (K 1) every frame he is in the Bankai with pointer 2 (西): the stance,
  NA, every segment and AS, the Kikon's startup. Left out while a flare draws it flared (`yama-bk-flare-p`: the same windows
  `yama-bk-moves` now uses, NS2a f16-35, NS2b S14-23, AS2b S12-21; the flares still peak at 1.9), while the 西 Kikon cinematic draws its own,
  while his body is hidden (model alpha <= 0.5) and while a cinematic holds his aura off (`*aura-off*`, as `draw-aura`).
- The form garb stands on the floor under his pelvis joint, not at his sim position: NS2c's and AS2a's clips carry his body about 1 m
  ahead of it, and the first stills showed the garb left behind him (the old form aura, drawn at the sim position, had the same gap).
  The flares and the cinematic still draw at his sim position, as before.
- `yama-stance-look` keeps only 南's cracks; 87448's `garb` row measures `yama-garb-at`.
- Looks gate expectation (written before the gate ran): BASE's YK stills show the Shikai and, in w3-0, the Bankai under 東 (旭日刃 on the
  HUD); the select models are the base form; no other scenario has Yamamoto. **Expected: 83 of 83 byte-identical, none listed.**
- Checks on the follow-up's build: host tests 4255 ALL PASS; pkgcheck clean (BASE's `DUEL::APP` note); smoke exit 0; `cvc` PASS II IK
  KK; looks gate vs `looks-base-s5m` (no `--keep-base`) 83 of 83 byte-identical, noise floor 0, every scenario's sim lines identical
  (cvc-yk's 12): as expected; 87448 / 2328 / 2390 every garb / hellfire row 0 B (`garb` now measures `yama-garb-at`).
- Stills: `tests/shots/duel-j2-form-j1.png` (J1 mid-swing), `-ns2c` (NS2c, no flare: the K 1 garb with him through the lunge), `-as2a`
  (AS2a's grab), behind camera, and `-phone` (390 x 844); `duel-j2-form-sheet-phone.png`. In J1 on the phone his torso leans out of
  the garb's top-front (the garb sits on the floor under his pelvis).
### 28.5 As built (J3: S5's open looks, 爆炎 NS2b's own clip, stance 3's blade, 2026-11-20)

The user, 2026-11-20: 「其他繼續修」 (§28.1 (4)). All six items are presentation only: no move frame, hit volume, hazard or tick changed;
撫斬 keeps its 156 f, so the Kikon wiring (+60 ticks) and the YK sim lines stay as they were. References viewed first (the user's rule):
`.refs/yamamoto/sheet_EnnetsuJigoku.png` (the columns of 11.2-19.6 s: near-constant width, ragged licking sides, dark gaps between),
`sheet_J__kakuEnj__.png` (the tongues inside a wall of flame), `sheet_Taimatsu226.png` (flame wrapping one body), `v_338a.jpg` and
motion-refs §1.3's `HitotsumeNadegiri.gif` order (tell, the unseen cut, the lowering from behind, the late split).

| # | Item | What changed (code) | Kind |
|---|---|---|---|
| 1 | 不知火's columns read as cones; the tornado as stacked rings | `%ya-cpillar` (yama-cine.lisp, used only by the two S5 cinematics) rebuilt as a **column of flame**: nearly as wide at the top (0.6 R) as at the foot (it was R → 0.22 R, the cone), an EMBER backing, two FIRE masses side by side swaying out of step (ragged sides), batch 1's EMBER stripe twisting up the front (VFX-FIRE-PILLAR's spiral), the tier's core narrower (25 / 42 %, was 30 / 60: a seam, not a white wedge), two tongues licking off the sides and three flaring out of the top, re-drawn on twos (about 450 vertices, was 72). 不知火's columns also grow in width with their rise (no squat barrels mid-rise). The tornado (f124-166) is **one twisting body**: a FIRE mass behind the victim over an EMBER rim (camera-facing, widening 1.3 → 2.8 m half-width up its 10 m), six strands wound 1.3 turns floor to top on a funnel widening 1.0 → 2.6 m (FIRE T2 on the camera's side, EMBER on the far side), tongues licking off its rim; the victim's black silhouette reads on the mass between the turns | look |
| 2 | the composed 焱 lighter than 熱地獄 | `tools/glyph-bake.py`: a COMPOSED entry takes a BOLD (font units): the component's outline is thickened (pathops stroke, round joins, unioned) before its copies shrink. 焱 = three 火 + 40 on boxes (250 0 750 470), (10 465 500 985), (500 465 990 985) (was + 0 on 470 x 455-505 boxes). Mean stroke (2 x area / perimeter, 1/1000 em): 焱 45.1 → **63.1**; 熱 61.8, 地 75.5, 獄 57.3; ink area 176 k → 262 k (熱地獄 285-323 k). `glyphs.lisp`: only 焱's line changed (161 glyphs, 20351 points); its 9 polygons are still 3 x 火's (the host check) | bake |
| 3 | 撫斬's still face and sheathing run long | **the length kept (156 f)**, the frames re-distributed, so the wiring and every sim line stay: the face 16 f (f12-28, was 28: f12-40), over the shoulder 28-40 (12 f, as before), the cut f40-41, the turn and the lowering f44-84 with `ya-b-n3c` at x1.0 (40 f, was 54 f at x0.74), the seam f84 (8 f, was 6), the split f92-128 (36 f, was 24: the V of fire burns to f132 and gutters into the wide), the wide f128-156 (28 f, was 16). The look's windows moved with them (the hairline f40-41, the seam f84-122, the V f92-144, the scorch from f144); `:hold` 64 (the turn). Shortening it instead would have cut the payoff the user did not mention and made a sim change | timing |
| 4 | 焱熱地獄's near pillars as stubs side-on | the stubs were S5's dev 3 (`ws`, 12-100 % of height between the lens and the pair). Now the floor pattern and the twelve marks turn with the pair's line (TH0 = the A→V bearing; marks at TH0 + 15° + 30° k, spokes at TH0 + 45° k), so the side-on shot (SHOT-PAIR: the camera on the line's normal) always looks through the gap between the pillars at 75° and 105°, and **every pillar stands full height** (6 m, x1.2 in 爆炎): in landscape (5.5 m) the two nearest the lens frame the pair at the screen's edges. In portrait (7.5 m) those two stood on the lens's line to the actors and hid both (the first portrait stills), so a pillar on the lens's line to either actor is left out (`%ya-sight-blocks`: between them, 0.5 m clear of each end, within 0.45 m (its FIRE half-width) + 0.3 m (the actor's) x its share of the distance, on the floor plane): the portrait shows both between full pillars; in the landscape stills the right-hand framing pillar stays and the left one, just inside the rule (the camera is not exactly on the normal), is left out | look |
| 5 | 爆炎 NS2b played NS2c's clip (x18/16) | its own clip `ya-b-n2b` (16 / 2 / 20, yama-art.lisp; the move's `:clip :ya-b-n2b` for `:clip-s 18`, yama.lisp line 155 only: J1's `:params` line untouched): frame 0 爆炎 NS2a's landing (`:ya-n2a-land`, as the Shikai's NS2b), the wrist flicks one circle with the point f2-6 (a key a frame: "the ring closes at once", YAMA-RING-CLOSE f12-15), the blade swept point-up overhead f7-11 (NS2c's rise at twice its speed), held f11-13 trembling, chopped f14-15 (NS2c's two snaps), the level point on S (`:ya-n2c-hit`), S+A = ENNETSU's frame 0 exactly. Link jumps (the tip, m): **NS2a S+A > NS2b f0 0.00** (was 0.15 after S3, 1.20 before), **NS2b S+A > ENNETSU f0 0.00** (was 0.18 → 0 by S4's frame-0 match); its f1-4 0.02 0.02 0.32 0.33 (the flick). Root yaw ≤ 12.8°. Host: the clip on its move's frames (in S4's own-clip list), cast checks f11 / f13 the blade overhead (y 2.68) and f16 the level point 1.83 m ahead at 1.30 m | clip |
| 6 | stance 3's blade barely visible from behind | both a clearer silhouette and an ember: `:ya-st-nade`'s hand `:side` 13.5 → 33.5 slants the blade out, the point on the plaza **0.50 m right, 0.32 ahead** (y 0.02; was 0.28 / 0.22, behind the haori's edge from the behind camera); and YAMA-STANCE-FIRE code 3 (YAMA-DRAW, out of a move in `:ya-st-cane`, not in an S5 cinematic): still **no fire**, a thin EMBER line down the blade (0.016 → 0.010 m, pushed 0.03 m toward the eye) and a small EMBER ring (r 0.07) where the point meets the plaza, breathing on twos. NS3a starts from the same pose (its frame 0 is `:ya-st-nade`), so stance 3 > NS3a stays 0 at f0; its f1-4 hand `:side` eased 27.5 / 19.6 / 11.2 / 3.4 (was 11.5 / 8.6 / 5.2 / 1.4), so the tip's jumps f1-4 read 0.20 0.28 0.31 0.30 (0.40 at f1 before the easing; 0.16 0.22 0.25 0.26 before J3); NS3a's hit frames and FK row unchanged (1.68 / 1.60). The host cast check now reads x 0.45-0.55, y ±0.05, 0.2-0.4 ahead | pose + look |

The looks gate's expected diff, written before the run (BASE = the merged main's dist, `looks-base-s5m`; no `--keep-base`): every sim
line identical (presentation only, 撫斬 at 156 f); every still identical except a cvc-yk still with P1 idle in pointer 3 (the slanted
blade and its ember), mid-爆炎 NS2b or in NS3a's first frames, or inside an S5 cinematic (§26.0 found none of the YK stills inside one).

Checks (on the final head):

| Check | Result |
|---|---|
| Host tests | `duel-rules-test.lisp` 4266 checks ALL PASS (main 4262; +3 NS2b cast checks, +1 its S+A = ENNETSU's frame 0; NS2b moved from the scaled check into the own-clip list; stance 3's range re-written). Its printed lines against d7d17b1a's: only the stance 3 tip line moved, plus the new NS2b and NS3a lines (every FK row, every other cast check as before) |
| pkgcheck | as main: the one `DUEL::APP` line, 0 redefinitions, 0 undefined |
| Native trials (`combo-trial.py --log`, every line against the same files at d7d17b1a) | `yamamoto-core` 241, `-blaze` 268, `-bankai` 513 lines: **identical** |
| `--cvc` | `tests/style-gates.py cvc dist/duel`: II / IK / KK PASS (33 / 28 / 27 lines) |
| The looks gate | **PASS, 83 / 83 stills byte-identical**, every scenario's fighters and sim lines PASS (cvc-yk 12), noise floor 0 (1396 s wall at 4 jobs): as expected; no YK still shows stance 3 or 爆炎 NS2b. Run again after the NS3a easing: the same, 83 / 83 (1358 s). The portrait pillar rule came after it: it runs only inside 焱熱地獄, which no looks scenario plays |
| Build, smoke | `./build.sh duel` (then `git checkout -- vendor`); `run.mjs --secs 8` exit 0 |
| 0 B a frame | debug 87449 in the Shikai and in 爆炎 (the S5 stills run): every row 0 B, the new `shiranui-124` (the columns and the tornado at once), `nadegiri-40 / 86 / 100 / 130` (its re-timed busiest frames, were 52 / 112 / 124 / 150) and `stance-3-ember` included; 87448 every row 0 B; `fx-dropped 0` on every stats line of the stills runs |

Stills (untracked; the before set rendered from the BASE dist with the same scripts, the old 撫斬 beat frames for its before row):
`tests/shots/duel-j3-<shiranui|ennetsu|nadegiri>-sheet[-phone].png` (rows: before Shikai, after Shikai, before 爆炎, after 爆炎),
`duel-j3-stance3-sheet.png` (before over after: the Shikai and 爆炎, behind and side), `duel-j3-ns2b-before-after-sheet.png` (8 frames,
side camera; `duel-j3-ns2b-sheet.png` both cameras after), the singles `duel-j3-before-*.png`, `duel-j3-stance3-*`, `duel-j3-ns2b-f*`, and
the S5 script's `duel-yama-s5-*` (re-shot). The J3 script: `tests/scripts/duel-yama-j3[-phone].json` (`tests/scripts/duel.py`'s
`yama_j3_script`); `duel-yama-s5[-phone].json`'s 撫斬 beats moved with the re-timing (b1 f20, b2 36, b3 40, b3b 42, b4 64, b5 84, b5b 88,
b6 104, b7 146).

Open (for the lead and the user):
- The 爆炎 NS2b strip's labels run about 2-3 frames behind the move frame (the stills land after the start command's step): the ring is
  already drawn in "f10", the chop in "f13"; the clip's own frames are as keyed (the host cast checks).
- 爆炎's 焱熱地獄 b5 still (f134, a held manga frame) shows a large black shape the before still did not. Inferred, not proven: a random
  layout (the manga frame's or the shatter's shards near the lens) read from the cosmetic stream, whose count moved with 撫斬's re-timing
  earlier in the same script; the Shikai row, which runs before the re-timed 撫斬, is unchanged there. In play it lasts 10 f.
- The first BASE stills run hit run.mjs's 900 s wall timeout at virtual 42 s on the loaded machine (every still after that was taken at
  once, invalid); all the before / after runs were re-made with `--timeout 20000`.
- The in-game SL3 tornado (NS1c, `yama-tornado-look`) still draws stacked bands: out of J3's scope (the user named the cinematic).
- Stance 3 now has an ember, which §21.3 kept out ("no fire at all"): it is EMBER (a dull line, no FIRE, no tongues), the S2 lead's
  anticipated option (§23.10).
- `yama.lisp` line 155 (爆炎 NS2b's `:clip`) sits next to J1's `:near 0` on line 156: a merge may show them as one hunk.

## 29. 西's Kikon cinematic re-boarded (the user, 2026-11-21)

The user (verbatim): 「殘日獄衣的毀魂技動畫分鏡是 1. 對手靠近攻擊後武器損毀，隨即拉開距離 2. 從斜後放拍攝山本緩步向前，每走一步都會讓火焰的威勢擴大（這部分可以透過時緩來增加壓迫感） 3. 隨後瞬間穿過對手，使對手受到高溫焚燒殆盡」

Against the K4 build (§19.1): beats 0-52 (the victim's attack, the weapon to ash) and 124-180 (the pass, the burn, the wide) stay. What changes:

1. After the weapon dies the victim **opens the distance** (a leap back); there is no separate ignition beat any more.
2. The walk is shot **from diagonally behind him** (over his shoulder toward the victim), not side-on. **Each footfall makes the garb
   bigger** (a step up per footfall, not a steady build), and the walk plays in **slow motion** for the pressure.
3. The pass and the burn as built; "焚燒殆盡" = the victim charred black with the ash streaming up (no alpha 0, §14 deviation 7).

Length 180 f and `:hold 140` stay, so no sim tick moves (presentation only, §19.2). The lead's beat table for 52-124 (the rest as §19.1):

| Frames | Shot | Action | Effects / sound |
|---|---|---|---|
| 52-66 | side-on, the pair, wide | f52 what is left of the weapon falls (as built); the victim leaps back to about 4 m, weaponless, off balance; Yamamoto does not move, the garb at the stance's size | a whoosh, the sizzle |
| 66-124 | diagonally behind him (about 150° off his front, above his shoulder, the victim visible past him), tracking him | `cine-slow` over the walk; three slow dragging steps (the footfalls about f74 / f92 / f110), the victim backing off, cowering; at each footfall the garb steps up in size (stance → 3 stages, the last at least the play flare's peak, K 1.9), a heat ring at the foot, a molten footprint; caption 残日獄衣 at the first footfall | the footfall, a heat roar that grows each step, the shake growing (about 0.1 / 0.2 / 0.3) |
| 124-180 | as §19.1 | the pass, the column, the Konpaku, the wide | as §19.1 |

### 29.1 The garb trails behind him as he walks (the user, 2026-11-21)

The user (verbatim): 「請讓火衣在行走時會向反方向自然飄蕩」

The lead's reading: whenever he moves under 西 (play: walking, stepping, the NS2 advance; the 西 Kikon's walk), the garb's tongues and
wings lean away from his direction of travel, more with speed, and settle back upright with a soft lag and a small overshoot when he stops
(a damped spring on his drawn velocity, cosmetic state only, 0 B). The sim is untouched; the looks gate's 西 stills may change.

### 29.2 The garb stays on his shoulders; the walk shot from 30° right-behind, level, no shake (the user, 2026-11-21)

The user (verbatim, after v470): 「1. 火衣的肩膀的部分沒有固定在身體上，反而整體往後飄移 2. 殘日獄衣毀魂技請從右後方 30° 平視往前拍攝，走路時不要震動鏡頭」

1. §29.1's lean sheared the whole garb from the floor, so at shoulder height the wings' roots slid back off him (about 0.4 m at a walk).
   Now every tongue and wing keeps its root where it is on the body; only the part beyond the root trails (the offset grows with the
   distance from the root, the tips most).
2. The 西 Kikon's walk (f66-124): the camera 30° off straight behind him on his right, at about his eye height, looking level forward
   along his walk (no high angle). The footfalls no longer shake the camera (the heat ring, the roar and the garb's steps stay).

### 29.3 More tilt on the wings; the walk at 南's pace, the garb trailing, the flash behind him after three steps (the user, 2026-11-21)

The user (verbatim, after v471): 「我希望肩膀火焰飄蕩的角度更傾斜。然後毀魂技走路節奏請做成跟火火十萬億死的節奏一樣，然後每走完一步就放大火焰，全身的火焰朝後方飄蕩，總共走三步後就瞬移到對手身後」

1. The shoulder wings trail at a steeper angle than §29.2's (about twice the bend; in play and in the cinematic).
2. The 西 Kikon's walk takes 南's (DAISOJIN's) pace: `:sh-walk-f` at speed 0.55 and 0.02 m a frame (a 0.9 s cycle, so about 49 f a step),
   in real time (§29's slow motion goes: 南's walk has none). Three full steps take about 147 f against the old 58 f, so the cinematic
   grows by about 90 f (180 → about 270 f); like every Kikon length this is sim timing (§19.2: the reset after a 西 Kikon comes about 90
   ticks later; no gate plays it).
3. The garb steps up when each step completes (K 1 → 1.3 → 1.6 → 2.0, as §29), and through the walk the whole garb trails back clearly (a
   lean set by the cinematic, not only the spring's 0.02 m a frame).
4. Right after the third step he flash-steps behind the victim (the pass, §19.1's 124 beat and everything after it, moved to follow it).

### 29.4 The walk shot from 15° behind and closer; the garb's tilt at most 25° (the user, 2026-11-21)

The user (verbatim, after v472): 「改成後方 15° 拍攝，並將鏡頭拉近，火衣成水平傾斜最高不超過 25°」

1. The 西 Kikon's walk camera: 15° off straight behind him (on his right, as §29.2), still at eye level and level, closer than §29.3's
   7.0 m (phone 6.0).
2. No part of the garb tilts more than 25° from its upright direction (tan 25° = 0.466 m sideways per metre): the spring's cap (was 0.6 =
   31°), the cinematic's walk lean (was 0.48) and the wings' 2.4× bend (which reached about 50° in the walk) are all clamped to it. The
   wings still trail more than the body at a walk (their bend reaches the cap sooner).

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
| 爆炎 early exit | each NS segment spends 25 heat (`*ya-heat-ns*`) at the 爆炎 move's fixed power (no proportional boost: 爆炎's variants are already the strong set); heat at 0 ends 爆炎 |
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

## 5. Open (defaults the build takes unless the user rules otherwise)

- Does a cancelled 北 count as used? Default yes (its gauge is refunded as any cancel's, DUEL_SP §3; the special pointer is not).
- The 爆炎 variant of each move (the segment table, §6) and the Bankai pointers' confirmation.
- Every number in §3 is a first knob for play.

## 6. Next

1. The segment tables (DUEL_CORE grammar, `duel-move-modules`): Shikai, 爆炎, Bankai (東 / 西 / 南 / 北), NA string, NS segments, AS n, each
   gap's SA, reactions, S / reach / damage; built from the old kit's moves (`git show retired-kits:duel/lisp/yama.lisp`) and the TYBW
   motion bars. A Fable review, then the user's yes.
2. Batch 1: the kits' `:core`, the heat gauge and 爆炎 in the sim (pure functions host-tested), the marks and 北, functional clips at the
   right reach; the generic core CPU plays them. Roster: un-retire slot 0 (`*retired*`, simgate `RETIRED`), the host tests, the looks
   gate's seeds.
3. The playtest Artifact, then art batches (presentation only), the Kikon storyboards last.

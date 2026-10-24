# SOUL DUEL: Rukia, TYBW look, motion modules and a new Shikai (2026-10-24)

Status: **in design** (the request and the scope are decided, §1–§2; the diagnosis §3; the Shikai's combat logic: 霜の層, approved as
the §4.4 frame table; the build starts with the sim batch and the look batch, §5). Skills: `duel-move-modules` (the Shikai's grammar), `duel-motion-style` (decide,
research, plan, measure, draw), `duel-character-rework` (presentation vs sim, the proofs). Research:
`docs/research/rukia-rework/` (`canon-looks.md`, `canon-motion.md`, `style-refs.md`: canon looks, canon motion, nihon buyō archetypes and draft motion bars) on top of
`docs/research/tybw-characters/notes/rukia_tybw.md`. Earlier design: `DUEL_RUKIA.md` (the kit as built 2026-09-28 and
every decision since; it stays the record of the awakening's rules), `DUEL_STRINGS.md` §2 / §12.

## 1. The request

> 我想要請你依據 repo 中的 skill 重新調查與設計露琪亞的動作模組，並與我討論設計細節
> (the user, 2026-10-24)

The lead's diagnosis (§3) and three directions (A: one 舞 stance grammar for both forms; B: rebuild the awakening only;
C: motion only) went to the user with four questions. The answers:

> 範圍：「重作整體造型模組，並重新設計始解的戰鬥邏輯。覺醒只改動作模組跟對應的攻防距離，核心的戰鬥邏輯不變」
> 動作風格：「原作舉止＋日本舞踊」
> (the user, 2026-10-24; no preference on the awakening's cold sources and on −273 °C, which follow from the scope)

## 2. Scope (decided)

| Part | In scope | Kind of change |
|---|---|---|
| Look (model) | the whole model of every form: the TYBW Shikai battle look, the −273 white look, the 白霞罸 Bankai look | presentation (stills, byte-identical sim) |
| Shikai `:base` | **the combat logic is redesigned** (the move set's grammar, its resource, its routes), then its motion modules | sim change: gated against the parent, her pairings at 20 seeds |
| Awakening `:m18` / `:m50` / `:zero` | **the motion modules and the matching attack / defence distances** (reach follows the drawn motion: 「對應的攻防距離」); **the core rules stay**: the cold gauge (two bars, its gains, warming, spending, the band lock, the overdraft), the bands' walk / run, −273's rooting, ward, freeze-touch, bracing, the CRACK, the field, the Hoho cold | reach only: a sim change limited to hit volumes, gated; every other awakened number byte-identical |
| Motion style | 「原作舉止＋日本舞踊」: canon manner and the canon dances (grade A), the strikes in nihon buyō's body language (扇の手, 回り, 摺り足, 見得; grade D proposals) | — |
| Not in scope | the awakened kits' rules above; the DANGAI cards that read them (永凍, 永久凍土, 霜柱無尽 …; re-checked once the Shikai's rules settle) | — |

Implementation note: the awakened kits `:inherit :base`, so any Shikai command, string or knob the new logic changes must
be pinned in `:m18` (or overridden) so the bands keep their rules (a host test lists the awakened kits' commands and grids
before and after).

## 3. Diagnosis (main e378418, 2026-10-24)

### 3.1 The Shikai's grammar (the `duel-move-modules` checklist)
- The attack state is the universal grid (J1–J3 / K1–K3, the six routes, DUEL_STRINGS §2.1); K hits frost (walk / run
  ×0.7). L is TSUKISHIRO (a ring under him ≤ 8 m, the pillar 24 f later; the K → L copy at S 8). SP1 HAKUREN (held 1–4
  stabs, a wave), SP2 SHIRAFUNE (a 5 m ice thrust), I HAINAWA, O ENBU (a shunpo rush into a spin).
- **No resource of her own and no routes**: each canon dance is one button, the universal bars pay for SP. Nothing gives
  a button a role (gain / refill / damage) and nothing follows a string except K → L and the O ender.
- It works: the gates are inside the window and the dances are canon. What it lacks is a decision inside her strings.

### 3.2 The awakening (kept by the scope; recorded for the motion and reach pass)
- The cold gauge has about 15 special rules stacked over a month (the hysteresis by bars, the band switch only while
  free, the combo band lock, the K → L overdraft, only L spending at −18, three warming rates, the ward that also guards
  shots, freeze-touch, bracing, the CRACK, the THAW lock, the Hoho's +50, the field, the DANGAI 永凍 floor). The skill reads
  this as a redesign signal; the user keeps the rules (§2), so only motion and reach change there.
- The user's playtest-1 point 5 (「越冷越強，而且每個階段要有看得出不同的動作」, DUEL_RUKIA "Playtest 1") is met only in part:
  see §3.3.

### 3.3 Clip inventory (31 clips; S / A / R in frames, loops in seconds)

| Clip | S/A/R | Plays | Note |
|---|---|---|---|
| `:ru-stance` | loop 1.8 s | Shikai idle | a light bounce |
| `:ru-cold-stance` | loop 2.6 s | −18 / −50 idle; 白霞罸's tell | |
| `:ru-zero` | loop 4.0 s | −273 idle | |
| `:ru-q1` | 7/3/12 | J1 in Shikai, −18, −50 (and −273 through the white body's swap to `:ru-q1-z`) | **one clip, three forms** |
| `:ru-q2` | 7/3/13 | J2 in Shikai, −18, −50 | **one clip, three forms** |
| `:ru-spin` | 8/3/18 | J3 in Shikai, −18, −273; **ENBU's strike** | shared with O |
| `:ru-thrust` | 17/4/20 | Shikai K1 (−273 swaps to `:ru-thrust-z`) | |
| `:ru-ring` | 21/4/24 | **K2 in all four forms** | the one clip that never changes |
| `:ru-drop` | 21/5/34 | Shikai K3 | |
| `:ru-tsukishiro` | 10/0/26 | L, its K → L copy | |
| `:ru-stab` | loop | HAKUREN's charge; **−18's SHIMOBASHIRA** | shared |
| `:ru-hakuren` | 6/1/24 | SP1 release (Shikai, −50, −273 at `:clip-s 6`) | |
| `:ru-shirafune` | 16/4/28 | SP2 in all four forms | |
| `:ru-breaker`, `:ru-hainawa` | loop, 8/4/18 | I | |
| `:ru-kikon` | 2.0 s | ENBU's Kikon pose | |
| `:ru-intro`, `:ru-win`, `:ru-awaken`, `:ru-hand` | 2.0 s | intro, win, the awakening, 白霞罸's last shot | |
| `:ru-palm` | 17/4/20 | −18 K1 TŌSHU; **−273 J2 at `:clip-s 17`** | a K clip sped up for a J (the skill's red flag) |
| `:ru-flower` | 21/5/34 | −18 K3 HYŌKA; −273 K3 | |
| `:ru-palm-50`, `:ru-spin-50`, `:ru-flower-50` | 17/4/20, 8/3/18, 21/5/34 | −50 K1, J3, K3 | |
| `:ru-stab-2h` | 0.4 s | −50 L HYŌSHIN | |
| `:ru-reido` | 6/0/26 | −273 L at `:clip-s 6` | |
| `:ru-hakka` | 20/3/30 | O 白霞罸 (all bands) | |
| `:ru-q1-z`, `:ru-thrust-z` | 7/3/12, 17/4/20 | −273 J1, K1 (the white body's clip swap) | |

Strike clips of its own per form (J1–J3, K1–K3; the rest are another form's): Shikai 6 of 6, −18 2 (K1, K3), −50 3
(J3, K1, K3), −273 2 (J1, K1; its J2 is −18's K1 sped up, its K3 is −18's). Every clip dates from 2026-09-28, before the motion-style
skill: no anticipation squats, no follow-through, the hit poses held on a planted stance (the same findings as Ichigo's and
Yamamoto's TYBW diagnoses). The FK reach report and the 8-frame strips come with the motion plan.

## 4. The Shikai's combat logic: proposals (under discussion)

The user decided the scope; the shape is still open. Three whole candidates, each a grammar the `duel-move-modules`
recipe can encode once (a segment table, its knobs in `rukia.lisp`); the user may pick or combine.

| | 1. 舞 stance (Lille's grammar) | 2. 舞の順 the dance order | 3. 霜の層 frost layers on him |
|---|---|---|---|
| Attack state | the universal J / K grid | the universal J / K grid | the universal J / K grid |
| L | enters the stance; inside it L1–3 stab the plaza (gain 雪 +1 each), J1–3 shunpo cuts (reposition, refill Reiatsu), K1–3 ice cuts (damage) | **the next dance in canon order**: 初の舞 月白 (ring) → 次の舞 白漣 (wave) → 参の舞 白刀 (ice blade) → 初 again; each dance that hits makes the next one stronger | TSUKISHIRO as now; its freeze adds 2 layers |
| Resource | 雪 pips 0–6 (hers) | the dance index 初 / 次 / 参 (a position, not a meter) | **霜 layers 0–3 on the opponent** (each slows his walk / run ×0.85 / 0.7 / 0.55 and thaws over time) |
| Routes | J3 → JL1–3 月白 rings ≤ 8 m (1 pip each); K3 → KL1–3 白漣 lanes (1 pip each) | K → L plays the current dance as a combo copy | K hits and the dances add layers; at 3 layers he is brittle |
| SP2 | 参の舞 白刀, spend-all (length and damage by pips), only off a string hit | 舞・終: the three dances in one move | 参の舞 白刀 **shatters** the layers (damage by layers, resets them) |
| Identity | a stance dancer like Lille | a dancer who plans her next figure | a freezer who builds and shatters, the awakening's frost-on-every-hit foreshadowed |
| Risk | the most work; close to Lille's grammar (「避免同質化」) | predictable for the opponent; the CPU must plan the order | a new status rule on the victim (host tests, the CPU's thaw read) |

The lead recommends **3** (her own resource on the victim, the canon "freeze, then shatter" of Tsukishiro and
Shirafune's wound that keeps freezing, the fewest new moves), optionally with 2's dance order for L. The questions the
skill asks before any build (tap or hold per button and its one-hand mapping, what a press does with nothing to pay,
which hits reach far, where each string ends, what she does at 2 m) follow once the shape is chosen, as a segment table
for the user's yes.

### 4.1 Chosen: 3, 霜の層; her role 遠近各半 (the user, 2026-10-24)

> 始解戰鬥邏輯：「3 霜の層」；定位：「遠近各半」
> (the user, 2026-10-24; candidates 1 and 2 rejected, 2's dance order not taken)

「遠近各半」 restated: close (1–3 m) and far (5–8 m) both get a full kit, each with a way to add layers and a way to cash
them; neither is the fallback. The lead's restatement as a segment table (numbers are proposals, knobs in `rukia.lisp`):

| Move | Enter by | Range | 霜 layers (on him) | Cashes | Note |
|---|---|---|---|---|---|
| J1–J3 | J | 1.4–1.6 m (close) | **+0** (keeps his thaw timer from running) | — | her fast close answer, S 7 beats every K1 |
| K1–K3 | K | 2.5–2.8 m (close) | **+1 a hit** (KKK = 3) | — | the close gain |
| K → L 月白 (combo copy) | L after a K link | at him | **+2** | — | the close route to 3 layers |
| L 初の舞・月白 | L | ≤ 8 m (far) | **+2** on the pillar's hit | — | the far gain; tell, guardable, a Step clears it (as now) |
| SP1 次の舞・白漣 | Shift+K, held | 11 m wave (far) | **+1** | — | lanes; a side Step clears it (as now) |
| SP2 参の舞・白刀 | Shift+L; off a string hit or alone | 5 m (mid) | **all → 0** | **shatter**: damage by the layers it breaks | the one sink, from close (after a string) and far (after a ring) |
| O 円舞 | O / the O ender | 8 m rush | +1 (proposal) | — | |
| I 這縄 | I | universal | 0 | — | |

| Layer | His walk / run | Look (on his model) |
|---|---|---|
| 0 | ×1.0 | — |
| 1 | ×0.85 | an ice crust on the feet |
| 2 | ×0.70 | to the knees |
| 3 (cap) | ×0.55, brittle | to the waist, a white breath |

- Step, Hoho, dashes and every frame number stay untouched by the layers (the old frost's rule, DUEL_RUKIA §3.1: the
  universal escapes hold).
- Thaw: one layer a **150 f** without a new layer (proposal; the old frost cap).
- Shatter damage (proposal): **70 + 25 a layer** (0: 70, 1: 95, 2: 120, 3: 145; today's SHIRAFUNE 110), before the combo
  scaling.
- The awakening keeps its own frost (frost on every hit, 30 / 60 / 90 f, the core rules, §2): the layers are a separate
  status that only the Shikai's moves add; whether layers survive her awakening is an open question.

### 4.2 The details (the user, 2026-10-24)

> J：「J 不加層，只停住退冰」
> 震碎：「能透過 J1/2/3+L 與 K1/2/3+L 爆開不同的層數並帶來多樣化的效益，並配合鬼道對中程實施壓制逼對手踏入近身陷阱。」
> 0 層白刀：「保留現在的 110」
> 覺醒時的層數：「留著自然退冰」
> (the user, 2026-10-24)

What changes in §4.1:
- **The bursts replace SP2 as the sink**: L after any J link or K link (J1–J3, K1–K3: six routes) **bursts** layers on
  him; each route bursts its own number of layers and gives its own benefit. The K → L 月白 combo copy (+2) gives way to
  the K bursts. The burst table is the lead's proposal below, for the user's yes.
- **Kidō at mid range** (3–5 m): pressure that makes the middle distance costly, so he either backs out to her far tools
  or steps into her close traps. Which kidō (canon manga: 破道の四 白雷, 破道の三十三 蒼火墜, 縛道の六十一 六杖光牢; 這縄 is the
  Breaker) and on which button: open.
- **SP2 白刀 at 0 layers keeps today's 110** (whether it still bursts layers on top: open).
- **Her awakening leaves his layers on him**, thawing as usual; the awakened moves neither add nor burst them (the
  awakening's rules stay, §2).

### 4.3 The bursts, the kidō, SP2 (the user, 2026-10-24)

> 爆開表：「可以，照這張表」　鬼道：「1+2」　白刀：「爆全部：110 ＋ 每層 25」　0 層接 L：「不接，連段在這裡結束」
> (the user, 2026-10-24)

The burst table (the lead's proposal, approved; numbers are knobs). L after a J or K link with at least one layer on him:
**link n bursts up to n layers** (link 1: 1, link 2: 2, link 3: all three); the J routes give position and resource, the
K routes damage and distance. Every burst ends the string (an `:end` row: no link after it); with 0 layers the L is not
taken and the string ends at that link (no 0-resource loop).

| Route | Name [G] | Bursts | Benefit |
|---|---|---|---|
| J1 + L | 霜散 SHIMO-CHIRI | 1 | an ice spray off the blade, a small hit; she hops back 2.5 m, out to the kidō's middle distance |
| J2 + L | 雪煙 SETSUEN | ≤ 2 | a mist burst; refunds Reiatsu (the SP gauge) for each layer burst |
| J3 + L | 霜陣 SŌJIN (the close trap) | all | the shards lie as a frost circle round her, r 3 m, 4 s: while he stands in it he gains a layer every 60 f |
| K1 + L | 氷礫 HYŌREKI | 1 | the shard hits again: extra damage, the stagger lengthened |
| K2 + L | 氷柱 TSURARA | ≤ 2 | an ice pillar out of the plaza under him pushes him to 6 m, into her far tools |
| K3 + L | 雪崩 NADARE-KUDAKI | all | the big shatter: damage by the layers, a knockdown |

The kidō, 「1+2」 (both of the lead's options, joined; the reading below is confirmed with the user):
- **L tap = 破道の四 白雷 BYAKURAI** (a fast straight beam, 3–6 m, no bar; repeats limited by its recovery); **L held =
  初の舞・月白** (the ring ≤ 8 m, as now, a pillar's hit +2 layers).
- **SP1 = kidō**: 破道の三十三 蒼火墜 SŌKATSUI (1 bar; the tap / hold split of option 2 has 白雷 already on L, so SP1 is 蒼火墜).
- **次の舞・白漣 moves into K3 + L** (the avalanche of cold off the shatter, canon ch. 235's release), so 雪崩 is drawn
  as 白漣's wave.

SP2 参の舞・白刀: bursts every layer, **110 + 25 a layer** (0: 110, 3: 185), usable alone (off a ring's freeze at 5 m)
and off any string hit; the one spend-all.

The user confirmed the burst table as shown in full (「可以，照這張表」) and amended the kidō reading: 「SP1 也分輕按／長按」
(the user, 2026-10-24): **SP1 tap = 破道の三十三 蒼火墜, SP1 held = 縛道の六十一 六杖光牢 RIKUJŌKŌRŌ** (six rods of light
pin him). 白漣 stays inside K3 + L.

### 4.4 The whole Shikai, frames and numbers (approved: the user, 2026-10-24: 「可以」)

Frames S / A / R at 60 Hz; every number a knob in `rukia.lisp` (docstring: old → new, date, who). The one-hand deck plays
the same buttons, so a tap and a hold on the L / SP1 chips are the keys' tap and hold.

| Input | Move | S / A / R | Dmg | Range | 霜 | Note |
|---|---|---|---|---|---|---|
| J1–J3 | the universal J (as now) | 7/3/12, 7/3/13, 8/3/18 | 34 / 34 / 42 | 1.44 / 1.32 / 1.56 m | +0, his thaw paused | frost timers removed from the Shikai |
| K1–K3 | the universal K (as now) | 17/4/20, 21→14/4/24, 21→14/5/34 | 66 / 58 / 84 | 2.8 / 2.5 / 2.7 m | **+1 a hit** | |
| J1 / J2 / J3 + L | 霜散 / 雪煙 / 霜陣 | S_eff 10 (A 3 + 10 < flinch 18), A 3, R 22 | 20 + 20 a layer burst | 2.0 m round her | bursts 1 / ≤ 2 / all | 霜散 hops back 2.5 m; 雪煙 refunds 8 % of a bar a layer; 霜陣 the r 3 m circle, 4 s, +1 a 60 f inside |
| K1 / K2 / K3 + L | 氷礫 / 氷柱 / 雪崩 | S_eff 12 (A 4 + 12 < stagger 26), A 4, R 26 | 30 + 30 / 30 + 25 / **40 + 35** a layer | 2.8 m; 雪崩's wave 6 m | bursts 1 / ≤ 2 / all | 氷礫 stagger +8 f; 氷柱 push to 6 m; 雪崩 knockdown (3 layers: 145) |
| L tap | 破道の四 白雷 | 12 / 3 / 28 | 45 | a line 0.5 → 6 m, 0.3 m wide | +0 | `:ranged`, flinch, guard 10, block −12; no bar |
| L held (≥ 12 f) | 初の舞・月白 | from the hold: ring at S, pillar 24 f later (as now) | 60 | ≤ 8 m, r 1.8 | **+2** on the pillar's hit | freeze 36 f as now; guardable, a Step clears it |
| Shift+K tap | SP1 破道の三十三 蒼火墜 | 14 / 4 / 26 | 90 | a 5 m cone, 40° | +0 | knockback 3 m; 1 bar |
| Shift+K held (≥ 16 f) | SP1 縛道の六十一 六杖光牢 | the rods at f16 after the hold, a 14 f tell | 20 | ≤ 6 m at him | +0 | `:bind` 45 f (an opener: he may Burst); guardable from her side; 1 bar |
| Shift+L | SP2 参の舞・白刀 | 16 / 4 / 28 (as now) | **110 + 25 a layer** | a line to 5 m | **bursts all** | alone or off any string hit; the one spend-all |
| O | 円舞 ENBU (as now) | as now | 70 | 8 m rush | +1 | |
| I | 縛道の四 這縄 (the Breaker, as now) | universal | 150 | | +0 | |

| 霜 layer | 0 | 1 | 2 | 3 (cap) |
|---|---|---|---|---|
| His walk / run | ×1.0 | ×0.85 | ×0.70 | ×0.55 |
| Thaw | — | one layer a 150 f without a new one (J hits hold the timer) | | |

Removed from today's Shikai: the K hits' frost timers (60 / 90 f), the K → L 月白 combo copy, SP1 次の舞・白漣 as a button
(its wave lives on in 雪崩). The awakened kits keep their own commands, grids and frost (§2), pinned by a host test.

## 5. Next steps
1. The research notes (`docs/research/rukia-rework/`), then the look plan (a model-sheet review against canon, stills).
2. The Shikai's grammar chosen → its segment table → the user's 「可以」 → the sim batch, host tests, gates vs the parent.
3. The motion plan per form (inventory → archetype per string → slot table) → 「可以」 → the clips, FK reach, the awakened
   bands' volumes moved to the drawn reach (gated), before/after sheets from both cameras, landscape and portrait.

### 5.1 Baseline (main eee02f4, before the new Shikai; 20 seeds, match time without cinematics)

| Pairing | RY | RK | RR | IR | SR | BR | HR |
|---|---|---|---|---|---|---|---|
| Median (s) | 92.0 | 94.5 | 116.5 | 117.2 | 120.8 | 135.3 | 138.8 |
| Wins (P1 / P2) | 13 / 7 | 9 / 11 | 8 / 12 | 9 / 11 | 10 / 10 | 6 / 14 | 3 / 17 |

All 140 K.O. Five of the seven already sit under the 125 s floor on main: the global whiff / block recovery and Kikon
changes of 2026-10-23 (DEVLOG §319–§335) moved many pairings below it before this rework (YY 85.5, YK 87.1 there). The new
Shikai is judged against this parent, not the window alone.

## 6. As built: the new Shikai's rules (batch ru-sim, 3d2b045, merged cd97427; 2026-10-24)

- **霜 layers**: a per-fighter status separate from the frost timer (0–3 + a thaw timer). K hits +1, J hits reset his
  thaw, TSUKISHIRO's pillar +2, ENBU +1, the 霜陣 circle +1 a 60 f inside; one layer thaws a 150 f; walk / run ×0.85 /
  0.70 / 0.55; nothing else slows.
- **Bursts**: the generic `:l-after-j` / `:l-after-k` also take a per-link plist (every other kit's data unchanged). A
  burst needs ≥ 1 layer and a hit (refused on a block), ends the string, and combos off its link including hitstop
  (host-tested).
- **Tap / hold**: L tap BYAKURAI, L held ≥ 12 f TSUKISHIRO (`*ru-l-hold*`); SP1 tap SŌKATSUI, held 16 f RIKUJŌKŌRŌ;
  SP2 110 + 25 a layer.
- **Removed**: the K → L TSUKISHIRO copy, the Shikai's HAKUREN button, every Shikai frost timer.
- **Awakened kits pinned**: their commands and `:l-after-j nil` are set in `:m18`; a host test checks their kit data
  equals adcb94b's. The Shikai's K2 is renamed `:ru-sk2` / `:ru-sk2s` so the bands keep `:ru-k2` with its frost 60.
- **CPU**: `string-reflex` takes a kit function for `:l-after-*` (shared with AUTO COMBO) and a new `:sp1-hold` hook;
  every new move fires in 40 CPU matches, though rarely 霜散 (0), the held TSUKISHIRO (3) and RIKUJŌKŌRŌ (1).
- **DANGAI**: card 119 白船不沈 now covers the Shikai's SP2 too.
- **Knobs**: `*ru-burst-j-s*` `*ru-burst-k-s*` `*ru-hop*` `*ru-refund*` `*ru-sojin*` `*ru-tsurara-to*`
  `*ru-hyoreki-stun*` `*ru-l-hold*`; the CPU's `*ai-ru-burst-1/2/3*` `*ai-ru-zone-kido*` `*ai-ru-sp2-layers*`
  `*ai-ru-l-far*` `*ai-ru-sp1-far*`. Debug 85000+k the scenes, 85499 the looks' consing check (0 B a frame); a
  `duel rukia` pacing line follows her gate rows. 10 kanji baked into `glyphs-extra.lisp`.
- **Placeholder clips** (the motion pass replaces them): 霜散 `:ru-q1-z`, 雪煙 `:ru-spin-50`, 霜陣 `:ru-reido`, 氷礫
  `:ru-thrust-z`, 氷柱 `:ru-flower-50`, 雪崩 `:ru-hakka`, BYAKURAI `:ru-palm-50`, SŌKATSUI `:ru-palm` (its hold
  `:ru-cold-stance`), RIKUJŌKŌRŌ `:ru-flower`. The FK report: every melee burst's drawn tip falls short of its volume
  (霜散 −82 cm, 雪煙 −46, 霜陣 −131, 氷礫 −179, 氷柱 −185); none overshoots.
- **Deviations from §4.4** (the lead's calls, reported to the user): frost also left the Shikai's SP2, TSUKISHIRO and
  ENBU (§4.4 named only the K hits); a 霜陣 laid before her awakening keeps adding layers after it; RIKUJŌKŌRŌ marks
  his spot at its f2 and binds at f16; SŌKATSUI's startup counts from the release, so a tap hits 1–6 f later than S 14.

### 6.1 Checks and gates (the merged main)

Host tests 10220 ALL PASS (control 89, learn 131), pkgcheck clean, the debug ranges check passes, `./build.sh duel` 0
warnings, a browser smoke exit 0 (the batch ran `duel-rukia.json` to the end: every burst fires). Non-Rukia pairings
(YY YK KK IY IK II SS SI, 10 seeds) identical to adcb94b; G2 `--cvc` identical to the reference. Her pairings, 20 seeds,
all K.O. (median s and Rukia's wins of 20, parent → now): RY 92.0 → 97.3 (13 → 11), RK 94.5 → 89.7 (9 → 6), RR 116.5 →
114.5, IR 117.2 → 108.0 (11 → 13), SR 120.8 → 123.4 (10 → 14), BR 135.3 → 131.3 (14 → 13), HR 138.8 → 139.9 (17 →
14). The playtest Artifact is v150.

Awaken A/B (the merged main; Rukia never awakens, the other side on its rule; her wins of 60 at seed0 100 / 300 / 500;
`--cmd 39020` with her as P1, `39002` as P2): RY 38 / 42 / 43, RK 21 / 21 / 32, RR 29 / 30 / 32, IR 28 / 30 / 28, SR
33 / 43 / 36, BR 41 / 40 / 41, HR 44 / 47 / 45: every row ≥ 20, pass (RK the closest). All 1260 matches K.O.; `--cvc`
PASS (yy / yk / kk identical).

## 7. As built: the look (batch ru-look, 9337f55, merged 57c31f7; 2026-10-24; presentation only)

By the gap numbers of `docs/research/rukia-rework/canon-looks.md` §5:

| Gap | As built |
|---|---|
| #1 the ribbon | a 1.8 m chain from the pommel, lying behind her and out to her right, looping in turns; stiffer and shorter in the colder bands (canon ~6 m: cut so it stays out of the behind camera) |
| #2–#4 the sleeves | the left a short puffed cap with the 十三 plaque (muted tan #B4A486, S < 0.3); white fingerless tekkō on both arms; the right sleeve a hanging panel swinging behind the arm |
| #5 the hakama | an 8-panel bell that trails her and flares in turns (Yamamoto's hem spring, rotated, never scaled); wide hakama legs |
| #6 the scabbard | black, at her left hip |
| #7 the guard | a round ring with six spokes |
| #8 the sash | white |
| #10 the irises | a lighter lavender #7A7096 |
| #12 / #17 the ornament | −273 and the Bankai share one ice spray on her left side wrapping behind the head (replaces the symmetric half-crown) |
| #13–#16, #18 the Bankai | four stacked ice collar rings, tiered shoulder plates, an ankle-length white kimono bell, knee-length hanging sleeves, a bow of four loops and three ribbons on her back, a chest snowflake with a tassel |
| skipped | #9, #11 (already canon); #19 the Bankai's guard (a bar or a ring: the user's call); #20 the Ep411 stole (optional) |

The −50 frost rims and the white looks' ice keyline cover the new cloth too. Shared files: `body.lisp` (`defweapon`
takes `:ink-color`, so a cloth part can carry the black-cloth or the ice keyline), `tests/duel-rules/art.lisp` (a body
variant takes its base body's rig: `:rukia` is now built on `:rukia-core`). Her look's draw hook is registered on every form
at the end of `rukia-meter.lisp`. Debug 85500+10l+s the model sheets (l: 0 the Shikai, 1 −18, 2 −50, 3 −273, 4 the
Bankai costume; s: 0 front, 1 left side, 2 back, 3 three-quarters, 4 face, 5 the blade out, 6 the J3 turn from behind, 7
the match from behind, 8 the same walking in), 85900 the consing line.

Checks: on its base, `simgate --seeds 10 --summary` and `--cvc` byte-identical; after the merge with the new Shikai the
host tests 10220 ALL PASS, pkgcheck clean, the ranges check passes, the build 0 warnings, the merged stills checked, the
consing lines 0 B in all five looks (standing / J1 hit) and for every new Shikai look (layers, 霜陣, the beam, the fire,
the rods). After the merge, `simgate --seeds 10 --summary` over all 28 pairings is byte-identical to main 8f452e0 (the new Shikai
without the look). Before / after sheets (landscape and portrait) went to the user; the playtest Artifact is v151.

### 7.1 The left sleeve is the long sleeve pulled up (the user, 2026-10-24)

> 「不對稱的袖子也是跟右邊一樣的寬鬆長袖往上拉後再用臂章固定，所以應該會在上手臂有寬鬆的袖口」
> (the user, 2026-10-24)

The ru-look batch drew the left sleeve as a short puffed cap with a tie (gap #2 read as a cut sleeve). Rebuilt in
`:rukia-core`'s `:upper-arm-l`: the gathered fabric above (a bevel 0.15 × 0.12 × 0.16), the white armband holding it
(0.13 × 0.04 × 0.14, the tan plaque with 十三 on its outside), the sleeve's **loose mouth flaring below the band** round the
upper arm (a black frustum r 0.07 → 0.145, 0.115 tall), the white under-sleeve beneath, and −50's frosted hem on the mouth.
Presentation only: host tests 10220 ALL PASS; her seven pairings at 10 seeds byte-identical to the build before.

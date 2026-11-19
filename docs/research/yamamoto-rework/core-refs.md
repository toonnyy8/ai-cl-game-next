# Genryūsai Shigekuni Yamamoto: references for the core-system kit

Research pass 2026-11-19, for `docs/duel/DUEL_YAMA_CORE.md` (the user's decisions Y1–Y7). It fills three gaps only. It does not
repeat `motion-refs.md` (canon fight by fight, motion bars, the RoS summary in §2.1) or `canon-looks.md` (looks per state). Read those
first.

**Grades.** A canon text with chapter / episode (wiki battle and technique pages via the MediaWiki API), or a still / anime GIF I
looked at myself (file and time named). B official game text (the RoS JP page, RoS in-game strings via the Resource of Souls data
mine, the official patch notes, Brave Souls skill text). C secondary (forum posts, press articles). D my inference or a proposal,
labelled as such. This file is a reference, not a design: where RoS differs from Y1–Y7, the difference is recorded, not argued.

**Access notes.** bleach.fandom.com page views still answer 403; `api.php?action=parse&prop=wikitext` works, and file URLs come from
`action=query&prop=imageinfo` plus `&path-prefix=en&format=original`. The Resource of Souls character page carries its whole
movelist and stat table as JSON inside the Next.js payload (`self.__next_f.push`); the visible page shows only part of it. Fextralife
and Game8 had no reachable Yamamoto page. The RoS character trailer could not be downloaded in this session (not watched).

---

## 1. Shikai pointer themes and link candidates: canon detail to build moves from

### 1.1 城郭炎上 Jōkaku Enjō (pointer 2: control, walls)

Canon text (A): "Creates an immense wall of flame, which surrounds the target(s) before forming a huge sphere of flame in which to
imprison enemies" (ch. 316 pp. 11–15, ep. 215). He tells everyone to step back, releases Ryūjin Jakka and cages Aizen, Gin and Tōsen;
"now they can deal with the Espada in leisure as Aizen won't be able to escape from the cage for some time" (ch. 316 summary, Volume
37). It holds three captain-level fighters "for a significant amount of time". Its job in canon is **separation**: it takes the
opponent out of the fight he wants, not damage.

Anime sequence (A, `JōkakuEnjō.gif`, ep. 215, read as a 0.7 s frame sheet, `.refs/yamamoto/sheet_J__kakuEnj__.png`):

| Time | What I see |
|---|---|
| 0–4.2 s | Eyes shut. The sheathed sword held **level in front of his face**, hand at the tsuba; the cane / sheath falls away, flame starts behind him |
| 4.9–5.6 s | The blade **raised point-up overhead** in one hand; flame climbs off the tip |
| 6.3–7.7 s | A tall column of fire from the blade |
| 8.4–9.1 s | Close-up: the face lit, red glow at the eyes |
| 9.8–14.7 s | A **stream of fire travels horizontally** across the sky, tapering to a point (a thrown lance of flame) |
| 15.4 s | The three targets small inside the stream's head |
| 16.1–17.5 s | Seen from above, the stream **coils round into a ring** on the ground plane |
| 18.9–19.6 s | The ring **rises as a wall** around the three, an open crater in the middle |
| 20.3–21.7 s | The walls climb and close over |
| 22.4–27.3 s | A **squat dome / flattened sphere**; Yamamoto in the foreground, **right arm out, blade pointed at it, fire still running off the blade into the dome** |

Manga colour (A, `316Jokaku Enjo2.png`): one double-page band of flame sweeps from Yamamoto (small, bottom right, haori flaring) up to
a **ring of fire** round the three (upper left), the ring white-hot at its centre. The second panel (`316Jokaku Enjo.png`, cited in
canon-looks §5) is the pointing pose.

- **Body in one line:** sword raised point-up (the call), then the arm brought down to point at the target at arm's length and held,
  fire pouring from the tip.
- **What reads at game distance:** three stages on the floor: a travelling stream along the lane → a ring that lands around the
  opponent → walls rising into a low dome. The pointing arm (held, travel 0) is his body cue; the cage is the effect.
- **Move-set hooks (D):** a stream that travels out (reach), a ring placed at a distance (zone), walls that rise a beat later (the
  delayed close), the held pointing pose as the stance. Canon gives the cage no damage of its own; any damage is a game choice.

### 1.2 撫斬 Nadegiri / 一ツ目・撫斬 Hitotsume: Nadegiri (pointer 3: finisher)

- Name (A): the canon technique is **一ツ目・撫斬 Hitotsume: Nadegiri** ("The First: Killing Stroke"; Viz "First Strike: Mow Down"),
  a **Zanjutsu** technique (sword skill, not a Ryūjin Jakka technique). "A precision cut of extreme force and speed which can casually
  slice through large, multi-story high opponents protected by hardened skin … its victims are not even aware of it until after it
  has taken place" (ch. 338 pp. 11–15, ep. 226). Used once, on the giant Ayon; Ayon is "cut in half", the left half comes back and is
  finished with Taimatsu (ch. 338 summary).
- Manga colour (A, `338Hitotsume - Nadegiri1.png`, "initiates Nadegiri by releasing Ryūjin Jakka"): the cut is drawn as **one huge
  curved sweep of flame** wrapping round Ayon, Yamamoto a small dark figure at its root, Ayon's giant hand reaching for him. So the
  manga's first beat is a release-plus-sweep, the split comes later (`338Hitotsume - Nadegiri2.png`, "Ayon splits in half").
- Anime order (A, already logged in motion-refs §1.3 from `HitotsumeNadegiri.gif`): the cane disintegrates to the blade; eyes shut;
  the cut is never shown; he is seen from behind slowly lowering / sheathing; a beat later the head splits down the middle.
- RoS (B): Nadegiri is the Hellfire-only Reiatsu move 2: 「大量の炎を纏った非常に強力な一閃を放つ。発動後は獄焱状態が解除される」 /
  "Emit heat and slash over a wide area. Leaves a huge opening, but is extremely powerful. Hellfire State ends after activation."
- **Body in one line:** almost no wind-up; one snap of the arm; then stillness, the back turned or the blade lowered slowly, while the
  target stands; the split arrives after.
- **What reads at game distance:** the gap between the cut and its result. A thin line on the opponent (or nothing) at the hit, then
  the split / flame burst 0.3–0.6 s later (D: the delay length is a game choice); his slow lowering is the readable tell that the cut
  already happened. RoS adds the "huge opening" (long recovery) as the price.

### 1.3 不知火 Shiranui (pointer 1: heavy, long reach)

- **Origin: RoS (game), not canon, as far as found.** The Bleach wiki has no Shiranui page, the name appears 0 times in Yamamoto's
  main page wikitext (Plot, Powers, Zanpakutō, Other Media), and the wiki search finds only unrelated hits. Grade: B for the game
  move, "no canon source found" for canon.
- RoS (B): JP official 「前方に炎を放ち攻撃する。発動すると獄焱状態になる。ボタン長押しで発動するとダメージが増加する。」 (casting
  it **puts him into Hellfire**; held, more damage). EN in-game: "Unleash a veritable tornado of flame. Covers a wide area and can
  whittle away the opponent's Guard Gauge. Hold the input to delay this move's activation time. The short input version is perfect for
  a combo finisher. The long input is slow to activate, but lets you use follow-up moves on hit." Cost 50 Reiatsu. Siliconera on the
  trailer: "casts ranged flames ahead of him" (C). The EN text does not say it enters Hellfire; patch 1.10 lists "reduced Inferno
  Gauge gain" for Reiatsu move 1 (it adds gauge). See §2.3.
- Name (D, context only): 不知火 is the folklore "unknown fires", ghost lights seen over the sea at night (Yatsushiro / Ariake). A
  look idea, not a reference: fire that appears at a distance in front, not travelling from the blade.
- **Body in one line (B + D):** a planted forward cast; short press = a quick burst in front as a combo ender, held = a slow charge
  that releases a wide tornado / column ahead.
- **What reads at game distance:** a wide spinning column in front of him (RoS "tornado"); a short and a held version with a visible
  charge between them. motion-refs §5.1 S8 already drafts the charge-and-thrust body.

### 1.4 Link, SA and Kikon candidates (brief)

| Technique | Canon / game detail | Body in one line | Reads at game distance | Candidate use (D) |
|---|---|---|---|---|
| 焱熱地獄 Ennetsu Jigoku | Fire runs down the edge into the ground, branches in circle patterns, raises immense pillars that join into one inferno; **can be set up before the fight and triggered later**; "powerful enough to destroy everyone caught in its vicinity, **including Yamamoto himself**" (ch. 393 pp. 13–14, ep. 294; A). Anime (`EnnetsuJigoku.gif`, A): glowing red scars on his face, eyes open (0.7–3.5 s), a wall of fire, rows of vertical pillars across the city (11.2–19.6 s), his dark silhouette arms-out inside the flames (27–30 s). RoS: awakened Kikon 2 (B) | Blade point-down, edge to the ground; he stands still while the pillars rise | A ring / rows of tall pillars around both fighters, rising from marks on the floor | Kikon (as RoS); its "set up earlier, trigger later" fits pointer 2's walls; its self-burn is canon backing for 爆炎's Reishi drain |
| 松明 Taimatsu | "A great inferno with a wave of Ryūjin Jakka"; he directs the flames only at the targets he chooses and sets their intensity (ch. 338 p. 17, ch. 339 pp. 2–6; A). vs the Tres Bestias attacking from three sides (`Taimatsu226.gif`, A): the haori swirls (4.2 s), then **a full radial halo of fire with his silhouette at its centre** (4.9–6.3 s), then he stands, eyes shut. RoS normal-state Reiatsu move 2: low damage, startup invincible, gauge to 0 and locked (B, §2) | One wave or one turn; fire bursts out all round him | A ring of fire around him (360°), not a forward line | A reversal / SA: the all-round burst answers attackers on every side; the halo is the canon root of the RoS Kikon's "halo of flames … on his back" |
| 鬼火 Onibi | A thrust with a blunt weapon (the cane) that punches a cylindrical hole (ch. 337 p. 18; A) | Short jab of the sealed cane, walking past | A small, fast forward poke; the hole after | NA opener or a link: the cane before the release |
| 一骨 Ikkotsu | One punch through the abdomen, sends the target through buildings (ch. 394 pp. 5–9; A) | Right fist straight out at shoulder height, body behind it | A straight fist with a long knock-back | A link / launcher; already the Breaker in the old kit |
| 双骨 Sōkotsu | Two-fisted punch, "completely destroy an opponent in one blow" (ch. 394 pp. 18–19, ch. 395 pp. 2–5; A) | Both fists side by side, arms locked | — | Needs two arms: pre-TYBW only (motion-refs §6) |
| 一刀火葬 Ittō Kasō | Hadō 96, forbidden; cast **through his own body as the catalyst** ("the spell of sacrifice", ch. 396 p. 2); a shockwave, then a red pillar shaped like a katana tip; cost him the left arm (ch. 395–396, ch. 423 p. 6; A) | Grabs the enemy from the ground; the charred arm cracks as the pillar rises | A tall red blade-tip pillar on the opponent | A Kikon or a last-stand move that costs Reishi; Brave Souls uses it as a Shikai special (B) |

---

## 2. BLEACH Rebirth of Souls (2025): Yamamoto's moves and the 豪焱ゲージ / 獄焱状態 rules

### 2.1 Move list (B unless marked)

Sources: the JP official page, the Resource of Souls movelist JSON (in-game EN strings, character id `pl016`), the official patch
notes 1.04–1.40. RoS has no Bankai: awakening = 始解"流刃若火" at higher output (JP). (Siliconera calls the awakening a Bankai, C; the
JP page and the movelist say Shikai.)

| Slot | Name | Text |
|---|---|---|
| Signature 己有技 | 焔薙 Homuranagi | JP 「炎を纏った威力が高く範囲の広い斬撃を放つ。追加入力でもう一度攻撃を出すことが可能。」 EN: "Slash in front of you to raze the area with massive flames. Powerful and leaves little opening, but **dramatically raises the Inferno Gauge** on activation. Unleash another slash with additional inputs. **Cannot be activated during Hellfire State.**" Costs nothing |
| Reiatsu move 1 | 不知火 Shiranui | §1.3; 50 Reiatsu |
| Reiatsu move 2, normal | 松明 Taimatsu | JP 「低威力の攻撃を行う。発動後は一定時間、豪焱ゲージが上昇しなくなる。」 EN: "Slash while spinning to launch multi-hit flame projectiles. You're invincible during the startup, letting you trigger this move to fend off attacks. **Reduces the Inferno Gauge to 0 on activation, and temporarily prevents it from rising.**" 100 Reiatsu, gauge cost 100 |
| Reiatsu move 2, Hellfire | 撫斬 Nadegiri | §1.2; 100 Reiatsu; **Hellfire ends after activation** |
| Special Flash | Enmatoi | "Rush forward wreathed in flames for a sweeping strike. Maintain the input to extend the rushing distance. **This extended rush fills the Inferno Gauge.**" |
| Strings | Quick, Flash | Q→Q→Q, F→F, ANY→F→F ("a simple flurry"); no pose text anywhere |
| Kikon 1 (normal) | "Ero No Hitonade" (Resource of Souls spelling; motion-refs writes "Enro"; kanji not found) | "drapes Ryūjin Jakka in a semicircle, emblematic of the rising sun … a halo of flames emerge from his blade and adorn his back … an effortless, but devastating strike". Destroys 2 Konpaku (3 with a Soul Break) |
| Kikon 1 (awakened) | same | 3 Konpaku (4 with a Soul Break) |
| Kikon 2 (awakened) | 焱熱地獄 Ennetsu Jigoku | 5 Konpaku (6 with a Soul Break) |
| Awakening | 始解"流刃若火" | JP 「出力を上昇させることで性能が強化。霊子がより多くなり、相手に与えるダメージが上昇」 (more Reishi, more damage). Data: max Reishi 11000 → 13000 awakened |

Resource of Souls' Taimatsu entry also says "Only available in the Hellfire State". That contradicts the JP page, its own Nadegiri
entry ("Taimatsu changes to this during the Hellfire State") and the trailer coverage: an editor error. Taimatsu is the **normal-state**
move.

### 2.2 The gauge rules, rule by rule

RoS's Reishi is its HP bar (the Konpaku pool's current life), so "Reishi depletes" = HP drains.

| RoS rule | Source, grade | DUEL_YAMA_CORE §3 |
|---|---|---|
| Flash attacks and the Signature fill the gauge (JP 「閃撃や己有技等を使用すると…蓄積」; EN "increases with the use of Flash Attacks or Signature Moves") | JP page + movelist, B | differs: Y1 fills on a hit or cancel by NA / SA / AS, never on use |
| Homuranagi "dramatically raises" it on activation; its second hit adds more (1.20: more gauge on the 2nd hit) | movelist + patch 1.20, B | — (no single big filler) |
| Enmatoi's held, extended rush fills it (1.20: more gauge while advancing) | movelist + patch 1.20, B | — |
| Reiatsu move 1 (Shiranui) adds gauge (1.10 awakened: "reduced Inferno Gauge gain"); JP: casting it enters Hellfire | patch 1.10, JP page, B (conflict, §2.3) | differs: NS spends heat (Y2) |
| **Quick attacks that hit lower it** (JP 「速撃を当てると減少」); guarded Quick attacks lower it less since 1.20; awakened Quick attacks lower it faster since 1.10 | JP page, movelist, patches, B | differs: NA adds heat (Y1) |
| **Breaker hits lower it** (since 1.10) | patch 1.10, B | — |
| It decreases over time (EN "Decreases over time"; tag `minimumValue0`) | movelist, B | differs: §3 decays only during 爆炎 |
| **Attack power rises in proportion to the fill**, no spending (JP 「豪焱ゲージが溜まるほど攻撃力が上昇」; EN "damage is based on how much of the gauge is charged") | JP page, movelist, B | differs: Y2 / Y3 spend heat per NS segment for a proportional boost |
| Full → 獄焱状態 Hellfire, **for a fixed time** (JP 「最大まで溜まると一定時間"獄焱状態"」; EN "a temporary special state") | JP page, movelist, B | same entry; §3 times it by heat decay 10 / s |
| Hellfire: attacks "dramatically stronger" (JP 「相手に与えるダメージが大きく上昇」); SP2 becomes Nadegiri | JP page, movelist, B | §3: 爆炎 = every move a variant |
| Hellfire: **Reishi (HP) constantly drains** (JP 「自身の霊子が減少していく」「常に霊子が減少する」) | JP page, movelist, B | same idea; §3 floor 1 (Y4); RoS's floor and rate not stated |
| Hellfire: Homuranagi unusable | movelist, B | — |
| **Taimatsu (normal state): gauge to 0 and locked for a while** (JP 「発動後は一定時間、豪焱ゲージが上昇しなくなる」) | JP page, movelist, B | the RoS pressure valve; parallels Y2 (spend to stay under the top) |
| **Nadegiri (Hellfire): ends Hellfire** | JP page, movelist, B | parallels §3's 爆炎 early exit by NS |
| **Landing or taking a Kikon ends Hellfire** (since 1.10) | patch 1.10, B | — (open in §3) |
| Hellfire strings (forum): Q→Q→Q cancels into Special Flash; SP2 after the last hit of a Quick or Flash string; the SP2 "health loss" is severe unless used at once | Steam forum, C | — |

Rates, duration, cooldown: **no source states a fill rate, a drain rate, a Hellfire duration or a lock length.** The movelist's
`cooldown` field is a placeholder ("X Seconds") for every entry.

Data-mine fields (Resource of Souls stat table, `pl016`, **unlabelled**; the reading is mine, grade D):

| Field | Value | Comparison | Reading (D, not a rule) |
|---|---|---|---|
| `enhance_max_time1` / `2` / `3` | 900 / 600 / 180 | Hitsugaya `enhance_max_time1` 1200; Soi Fon `enhance_max_time2` 1500; Kenpachi, Byakuya, Tōsen, Hisagi none | frames at 60 fps = 15 s / 10 s / 3 s: plausibly the Hellfire length, the Taimatsu lock, and one short timer |
| `unique_val1` | 10 | — | unknown (a gain per hit or a per-second value) |
| `unique_val2` | 0.5 | — | unknown (a ratio: Quick-hit loss? the max power bonus?) |
| `unique_val3` | 0.0005 | Hitsugaya `unique_val1` −0.0005 (same size, negative: a rate of some kind) | a per-frame fraction: 0.0005 × 60 = 3 % / s (gauge decay outside Hellfire, or the Reishi drain) |
| `unique_val4` | 0.0075 | — | a per-frame fraction: 45 % / s is too fast for HP; maybe gauge per frame of Enmatoi's held rush |
| `unique_val6` | 0.2 | — | unknown (a 20 % bonus?) |
| `transform_atk_rate` / `ura_transform_atk_rate` | 1.25 / 1.35 | generic fields | awakening attack ×1.25 (generic, not Hellfire) |

### 2.3 Conflicts and patch history

- **Shiranui and Hellfire.** JP official: 「発動すると獄焱状態になる」 (casting Shiranui enters Hellfire). The EN in-game text does not
  say it, and patch 1.10 speaks of Shiranui's "Inferno Gauge gain" (so it adds gauge, not a switch). motion-refs §2.1 quoted the JP
  line with an ellipsis and dropped this clause. Open: verify in a video (§4).
- Patch notes (official Bandai Namco pages; read through a fetch tool, so paraphrased except the short quotes; B):
  - **1.04**: fixed Homuranagi's second hit failing when Hellfire began during it; Enmatoi's follow-up when blocked and its frame
    advantage; a Reiatsu move 2 hitbox that could vanish.
  - **1.10**: Hellfire now ends when he hits or receives a Kikon; Breaker lowers the gauge on hit; awakened Quick attacks lower it
    faster; awakened Signature: more damage and reach, less gauge, cancels into Reiatsu moves 1 and 2; awakened Shiranui: more reach,
    less gauge. Developer intent: his firepower was offset by falling back to neutral after closing in; more gauge so he reaches
    big attacks sooner, Hellfire made less risky to end.
  - **1.20**: guarded Quick attacks lower the gauge less; more gauge from Enmatoi's advance and from the Signature's second hit.
    Developer note: managing the gauge was made harder so that "reckless offensive methods have become difficult".
  - **1.30**: Signature first hit recovers faster, second hit stuns longer ("a fix for an unintended issue").
  - **1.40**: awakened Special Flash: more damage, slower startup, longer hitstun, better scaling, more gauge.
- Design read of the RoS loop (D): gauge comes from the big moves (Signature, Flash, the held rush), leaves through the small fast
  ones (Quick hits, Breaker) and time; full = a timed Hellfire that pays HP; the player either vents (Taimatsu) to stay below the
  top or cashes out (Nadegiri) to leave it. SOUL DUEL's Y1–Y7 keep the same three exits (spend below the top, a timed 爆炎, an NS
  that leaves early) with different fills.

### 2.4 Newer media with the Bankai directions as moves

- **Brave Souls** (B; skill text, the only 2025–26 source found): East/South version special **Kakajumanoku Shidaisoujin** ("uses
  his sword's flames to control the undead"); West/North version special **Tenchi Kaijin** ("focuses all his flame in the tip of his
  sword then attacks", Burn); **TYBW 2026 version** special **Tenchi Kaijin** ("attacks, causing immense damage and inflicting Burn+",
  innates Sprinter 2, Havoc, Marauder); **TYBW: The Fire** special **Like an Inferno** ("slashes upwards with a blade wreathed in
  red-hot flame", Weaken + Burn; motion-refs §2.2 had it as "Rekka no Gotoshi … initiates East and West simultaneously", an older
  wording of the same card); TYBW 2023 **Bankai! Zanka no Tachi!** ("covers his blade and his body in flame and then sets off an
  explosion"). East and West have no move of their own in any game text found; South and North appear only as specials.
- Nothing found for BLEACH Soul Resonance or other 2025–26 games (searches in EN, JP and ZH).

---

## 3. Traits worth a mechanic or a tell (new items only; motion-refs §1.9 covers the eye opening, the neck crack, the sitting wait, the cane peel, the stripping, standing under fire, the grab after a hit, walking away)

| Trait | Source, grade | As a stance, tell or rule (D) |
|---|---|---|
| He **chooses which targets burn and how hot** ("power over the intensity of the flames"; the Tres Bestias "lightly toasted") | ch. 339 pp. 5–6, A | canon backing for Y3's spend-what-you-choose boost; a low-heat NS can show a small flame, a full spend a white-hot one |
| **Ennetsu burns him too** (destroys everyone in its vicinity, himself included); he smothers the blast with his body and lies burnt | ch. 393 pp. 13–14, ch. 395, A | canon backing for 爆炎's Reishi drain; a charred-arm / red-scar look while it drains (canon-looks §5) |
| **The Bankai can be held only briefly**: its heat would destroy the opponent, Soul Society and himself | ch. 508 p. 3, A | canon backing for a one-shot 北 (Y7) or any Bankai limit; rain when it ends (motion-refs §1.6) as the exit beat |
| **Traps prepared in advance**: Ennetsu "can be set up prior to combat and initiated later"; the whole Fake Karakura defence was its trap | ch. 393, A | pointer 2's walls as marks laid now and closed later; Y6's marks written by AS as "the trap being laid" |
| **Separates, then fights**: Jōkaku Enjō cages the three strongest so the rest can be fought "in leisure" | ch. 316, A | the cage as a control tool that removes the opponent's approach, not a damage move |
| **Quick to anger at betrayal and insult**: furious at Driscoll using Chōjirō's stolen Bankai, "brutally burned" him | ch. 504 pp. 15–17, A | an 爆炎 entry beat (the shout, eyes wide, motion-refs §1.5) |
| Calls opponents **"youngster"**, a fight a **"beating" / "punishment"** | ch. 155 p. 6, A | voice lines for the Kikon or the intro |
| **Merciful when he chooses**: spared the Tres Bestias, would not strike Wonderweiss in child form, told Nanao to leave | ch. 339, 394, 155, A | presentation only (a light hit that does not kill); no rule |
| **Rarely shows surprise**: opening one or both eyes is his only reaction | wiki Personality, A | the eye-open as the one universal tell (already §1.9), reused for every pointer's start |
| Tea ceremony master, plaits his own beard monthly; strict on the haori | Bootleg databook, ch. 423, A | idle flavour at most (a beard-smoothing idle) |

---

## 4. Gaps still open

- **RoS numbers**: no fill rate, drain rate, Hellfire duration or Taimatsu lock length is published. The data-mine fields (§2.2) are
  unlabelled. Close: a frame count from gameplay video, or a labelled data mine.
- **RoS trailer and gameplay video not watched** (`https://www.youtube.com/watch?v=2JYfn-o37aA`; the download was not permitted in
  this session). It would settle the Shiranui → Hellfire conflict (§2.3), the Q / F string poses and the Hellfire look (bared torso
  or not).
- **Jōkaku Enjō in the manga**, black-and-white, ch. 316 pp. 8–15: only two colour panels were read; the pose order there (raised
  point-up, then pointing) is from the anime.
- **Nadegiri's draw**: neither the manga nor the anime shows the cut; the body is a proposal (motion-refs H1).
- **The RoS Kikon's name in kanji** ("Ero / Enro no Hitonade"): not found.
- **East and West as standalone game moves**: no game text found (Brave Souls only names South / North specials). Soul Resonance
  and other 2025–26 games: nothing found.

## 5. Sources

- Bleach Wiki via the API (`https://bleach.fandom.com/api.php?action=parse&page=PAGE&prop=wikitext&format=json`): Jōkaku_Enjō (+
  /Image_Gallery), Hitotsume:_Nadegiri (+ /Image_Gallery), Ennetsu_Jigoku (+ /Image_Gallery), Taimatsu (+ /Image_Gallery), Ittō_Kasō,
  Ikkotsu, Sōkotsu, Onibi, Genryūsai_Shigekuni_Yamamoto (Personality, Weaknesses, Plot), BEAUTY_IS_SO_SOLITARY (Volume 37 summaries),
  Episode_215; search for "Shiranui".
- Wiki files viewed (in `.refs/yamamoto/`, git-ignored): `JōkakuEnjō.gif`, `316Jokaku Enjo.png`, `316Jokaku Enjo2.png`,
  `Ep215JōkakuEnjō1.png`, `Ep215JōkakuEnjō2.png`, `338Hitotsume - Nadegiri1.png`, `Taimatsu226.gif`, `EnnetsuJigoku.gif`,
  `Ep327EnnetsuJigoku1.png`, `RoS Yamamoto Ennetsu Jigoku.png`; frame sheets `sheet_*.png`.
- RoS official JP character page: https://bleach-ros.bn-ent.net/character/?chara=shigekuni-yamamotogenryusai
- Resource of Souls (movelist, Kikon, combos and stat JSON): https://resource-of-souls.com/characters/shigekuni-genryusai-yamamoto/
  (comparison pages: /characters/toshiro-hitsugaya/, /soi-fon/, /kenpachi-zaraki/, /byakuya-kuchiki/, /kaname-tosen/, /shuhei-hisagi/)
- Patch notes: 1.04 https://en.bandainamcoent.eu/bleach/news/bleach-rebirth-of-souls-version-104-updates ; 1.10
  https://en.bandainamcoent.eu/bleach/news/bleach-rebirth-of-souls-patch-version-110 ; 1.20
  https://en.bandainamcoent.eu/bleach/news/bleach-rebirth-of-souls-patch-version-120 ; 1.30
  https://www.bandainamcoent.com/news/bleach-rebirth-of-souls-version-1-30-updates ; 1.40
  https://www.bandainamcoent.com/es_mx/news/bleach-rebirth-of-souls-version-1-40-updates
- Siliconera trailer article (C): https://www.siliconera.com/shigekuni-genryusai-yamamoto-strikes-in-bleach-rebirth-of-souls-trailer/
- Steam forum thread on his Signature and Hellfire (C): https://steamcommunity.com/app/1689620/discussions/0/597396108583414311
- Brave Souls wiki via the API (`https://bleach-bravesouls.fandom.com/api.php`): the 5★ / 6★ TYBW East/South, West/North (+
  Resurrection), TYBW 2023, TYBW 2026 and TYBW: The Fire version pages, and the disambiguation page "Shigekuni Genryusai Yamamoto".

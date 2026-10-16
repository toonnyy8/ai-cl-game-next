# Shūhei Hisagi (檜佐木修兵): canon, Bankai and game references for SOUL DUEL

Research date 2026-10-16. For the next SOUL DUEL fighter: base form = Shikai **Kazeshini (風死)**, awakening = Bankai
**風死絞縄**. Research only; no design decisions here. Format follows `docs/research/yamamoto-rework/`.

## 0. Method, sources, grades

**Grades.** **A** = canon text or picture (manga chapter / page, the light novel *Can't Fear Your Own World* (CFYOW), an
anime episode); **B** = official game text or data (Rebirth of Souls, Brave Souls, patch notes); **C** = secondary (wikis,
articles, fan data-mines); **D** = my inference. Most A claims below were read through the Bleach fandom wiki's summary
with its chapter / page reference, not from the book itself. Where that matters, the grade is written **A (via C)**.
Nobody here has read the CFYOW text directly (no copy available). Every Bankai fact is a wiki summary of CFYOW III ch. 24.

**Access.**
- `bleach.fandom.com` page views answer 403 (Cloudflare). The MediaWiki API works:
  `https://bleach.fandom.com/api.php?action=parse&prop=wikitext&format=json&page=<title>`. Pages read: `Shūhei Hisagi`,
  `Shūhei Hisagi/Expanded Universe`, `Shūhei Hisagi/Battles & Events`, `Shūhei Hisagi/Image Gallery`,
  `Shūhei Hisagi vs. Findorr Calius`, `Sajin Komamura & Shūhei Hisagi vs. Kaname Tōsen`, `Shūhei Hisagi vs. Kazeshini`,
  `Kazeshini (Zanpakutō spirit)`, `Kubikake`, `Bleach: Can't Fear Your Own World` + its volumes I, II, III,
  `BLEACH Rebirth of Souls`, `Bleach: Brave Souls`. Page URL form: `https://bleach.fandom.com/wiki/Sh%C5%ABhei_Hisagi`
  (`/Expanded_Universe`, etc.).
- Rebirth of Souls (RoS): the data-mine `https://www.resource-of-souls.com/characters/shuhei-hisagi` (in-game strings,
  character id `pl011`); patch notes `https://www.bandainamcoent.com/news/bleach-rebirth-of-souls-version-1-10-updates`
  (2025-06-10); Siliconera `https://www.siliconera.com/shuhei-hisagi-joins-bleach-rebirth-of-souls-character-roster/`
  (2025-01-27). The official JP page `https://bleach-ros.bn-ent.net/character/?chara=shuhei-hisagi` exists but renders by
  script (no text came back).
- Brave Souls: Gamerch JP wiki pages `https://gamerch.com/bleach-bravesouls/<id>` (ids below) and the fandom summary.
- JP reading: ciatr `https://ciatr.jp/topics/324502`.
- Not reachable: WebFetch fails on fandom, gematsu and siliconera DNS. curl through the proxy worked.

**Wiki image naming.** `NNN…` = manga chapter NNN (digital colour edition); `EpNNN…` = anime overall episode number.
TYBW ep. 1 = Ep367, so Ep370 = TYBW 4, Ep371 = TYBW 5, Ep379 = TYBW 13, Ep383 = TYBW 17, Ep389 = TYBW 23,
Ep397–399 = TYBW 31–33.

## 1. Kazeshini (風死), the Shikai

### 1.1 Weapon shape, release, how it is held

| Claim | Grade | Source |
|---|---|---|
| Name 風死 "Kazeshini", "Wind of Death" (Viz: "Death Wind"). Sealed: a plain katana with an octagonal tsuba, worn at the waist, sometimes on the back. | A (via C) | fandom `Shūhei Hisagi` §Zanpakutō |
| Release command **「刈れ」 kare, "Reap"** ("…Reap, Kazeshini"). | A | ch. 324 p. 19 / Ep219 |
| Released form: **two kusarigama-like weapons. Each has two scythe blades, one inverted, so it looks like a pinwheel / S-shape. Each blade pair sits on a spiked rod, and the two rods are joined by one long chain.** | A | ch. 324 p. 19 (fandom ref) |
| Held one in each hand by the rod, chain trailing low between them (Ep219 still: rod about forearm-to-arm length, chain loops to the ground). | A | Ep219 still `Ep219HisagiShikaiKazeshini.png` |
| Swung by the chain in large circles so the blade end spins like a fan. Thrown as a projectile, steered in flight by pulling the chain, "making Kazeshini's paths unpredictable". | A (via C) | ch. 325 (fandom summary) |
| The chain can extend at will, but **Hisagi prefers to keep it as short as possible**. | B-ish (author Q&A) | Kubo, Klub Outside Q&A #397 (cited by fandom) |
| Hisagi dislikes the shape: "Wouldn't you say this shape is made for reaping lives?" | A | ch. 325 pp. 3–4 |
| CFYOW reveal: "dual zanpakutō" don't exist normally, so **the chain is the true Zanpakutō, not the two scythes** (Shunsui). The chain is "life", the blades are "death". | A (via C) | CFYOW III ch. 24 |
| CFYOW reveal, Shikai passive: **the chain heals any injury Hisagi takes by pulling his body back together, even total destruction, as long as he has Reiatsu.** Injuries taken *before* release are not healed. Pain is not removed. It explains his past survival (Kensei / Mashiro training, Lille Barro's shot through his Saketsu and Hakusui). | A (via C) | CFYOW Prologue the Second; III ch. 24 |

### 1.2 Named technique(s)

- **Kubikake (首挂, "Neck-Hanging")**: the chain is thrown around the opponent's neck, then pulled to throttle, unbalance or
  drag them in and **slam them into the ground**. A (via C), ch. 337 pp. 5 & 9; Ep225 (lifting and slamming the giant
  Ayon); ch. 384 p. 12 (chain round Tōsen's neck, yanked back, slammed into a roof).
- No other named Kazeshini technique in canon (A, absence in the wiki). Anime filler adds unnamed **"Shadow Blades"**
  (wind blades fired from the scythes) and a **black-tornado transformation**, used by the manifested Kazeshini spirit
  only (anime Ep234–236, 260; filler, A for the episode, not manga canon).

### 1.3 Every canon use, by fight

| Fight | Where | What Kazeshini does | Grade |
|---|---|---|---|
| vs Yumichika (sealed only) | ch. 139, 147, 156; Ep51–55 | Loses; never releases. | A (via C) |
| **vs Findorr Calius** (Fake Karakura) | ch. 319, 322, 324, 325; Ep216, 218, **219** ("Hisagi's Shikai! The Name is…") | Fights sealed for most of it. Throws an **explosive armband** (ch. 324 p. 12), pins Findorr with **Bakudō #62 Hyapporankan** (p. 13). Trapped in water, releases Kazeshini to cut free (p. 19). Then: a thrown scythe nicks Findorr; he **drops down, pulls the chain, and the other scythe hits Findorr from behind**; swings it overhead asking "are you scared?"; **swings backward to split Findorr's arm lengthwise**; appears behind and finishes him. | A (via C), ch. 325 pp. 7–18 |
| **vs Ayon** | ch. 336–337; Ep225 | **Ties Ayon up with the chains**; channels **Hadō #11 Tsuzuri Raiden through the chain** (paralyses it); Kubikake lift-and-slam (anime). Ayon breaks the chains and crushes him. | A (via C) |
| **with Komamura vs Tōsen** | ch. 367–368, 384, 386–387; Ep279–280, 289–291 | Entrance: **entangles Tōsen's sword with the chain** (ch. 367 p. 16); Tōsen vibrates his blade free (ch. 368). **Chain round Tōsen's neck, yanks him back, slams him into a roof**, holds him by the throat, "never use excessive force" (ch. 384). Final blow: stabs **sealed** Kazeshini down through the top of Tōsen's head from his back, then **releases Shikai inside the wound so the transformation impales him through the mouth / throat** (ch. 386 pp. 17–19). Tōsen then explodes (ch. 387 pp. 15–19); Komamura blames Aizen. | A (via C) |
| vs Driscoll Berci (TYBW) | ch. 495, 503–505; Ep370–371 (TYBW 4–5) | Shikai released but helpless; Yamamoto saves him. | A (via C) |
| Bankai training with Kensei / Mashiro | ch. 538; Ep379 (TYBW 13) | Fails to reach Bankai. | A (via C) |
| vs Mask De Masculine | ch. 559–560; Ep382–383 (TYBW 16–17) | **Wraps Kazeshini round Mask's leg** to stop him; Mask pulls him in and clotheslines him. | A (via C) |
| vs an unnamed Sternritter, then vs Byakuya under PePe's "Love" | ch. 594–596; Ep389 (TYBW 23) | Beats an unnamed Sternritter off-panel; charmed, attacks Byakuya, then **dual-wields Senbonzakura (sealed) and Kazeshini**. | A (via C) |
| vs the black creatures | ch. 621; Ep397 (TYBW 31) | Shikai, fighting a swarm with Ikkaku / Yumichika. | A (via C) |
| Shot by **Lille Barro** | ch. 635; Ep399 (TYBW 33) | Sniped from a roof. (CFYOW: Kazeshini's chain kept him alive.) | A (via C) |
| 10 years later | ch. 685 pp. 13–14 | Claims he has mastered Bankai; Rangiku, Hitsugaya and Kensei have never seen it. | A (via C) |
| **vs Tokinada Tsunayashiro** (CFYOW) | CFYOW III ch. 22–23 | Uses **the chain to block every blade** of Tokinada's copied Benihikō; scythes too fast for the copied **Wabisuke** to weigh down; flames of the copied Ryūjin Jakka too weak to slow them; **scythes deflect all Senbonzakura petals and cut off Tokinada's sword arm**; **hides Kazeshini inside a Reiatsu-concealing cloak** to ambush him. | A (via C) |
| **vs Hikone Ubuginu** (CFYOW) | CFYOW III ch. 24 | Binds Hikone in Kazeshini's chains; Hikone breaks free and **bisects him**. Inner-world talk, then he gets up unharmed and the chains keep wrapping Hikone and pulling them back. Then **Bankai** (§2). | A (via C) |

### 1.4 Fighting manner

- **Swordsman first, Shikai as the last resort**: regularly fights released opponents with a sealed blade (A via C,
  ch. 324 pp. 4–19). Releasing is "a very rare occasion" that the other Shinigami remark on (A via C, ch. 325).
- **Kusarigama style**: distance fighting, ensnaring with the chain, throws, odd attack angles (A via C, ch. 325).
- **Shunpo**: dodges a barrage of Bala, appears behind the enemy repeatedly (A, Ep219; ch. 325).
- **Kidō without incantation**: Bakudō #62 Hyapporankan (ch. 324 p. 13), Hadō #11 Tsuzuri Raiden through the chain
  (ch. 337 p. 8); Hakufuku (sleep Bakudō) planned on Hikone in CFYOW ch. 24 (A via C).
- **Gear**: the choker and both armbands are explosives that make a blinding smoke burst (ch. 324 p. 12, A).
- **Restraint**: "even when his blade is drawn his style has always been never to use excessive force" (ch. 384, A via C).
- **Inner habit**: "Every time I draw my blade, every time I face the enemy – on the inside, I'm always taking a
  half-step back!" (ch. 384 p. 15, A).
- Anime-only moves in the Findorr fight: a **low sliding slash at the legs**, crashing back off a pole (Ep219, A anime).
- Strength: lifts and slams the giant Ayon with the chain (Ep225, A anime).
- Stance (D, from the Ep219 stills): upright, one scythe in each hand by the rod, arms loose and wide, chain slack between
  them; the overhead whirl precedes a throw.

## 2. The Bankai: 風死絞縄

### 2.1 Name and reading

| Claim | Grade | Source |
|---|---|---|
| Kanji **風死絞縄**. Reading **ふしのこうじょう, Fushi no Kōjō** (fandom romanises it "Fushi no Kōjyō" in the CFYOW III summary, "Fushi no Kōjō" on the character tab). | A (via C) / C | ciatr (reading table: 卍解 風死絞縄, 読み ふしのこうじょう); fandom Expanded Universe |
| Brave Souls calls the special 「卍解『風死絞縄』」, romanised "Bankai! Fushi no Kōjō!", translated "Full Release! Undying Hangman's Noose!". | B (via C) | fandom `Shūhei Hisagi` §Video Games |
| 絞縄 kōjō = hangman's noose. The kanji 風死 are read **fushi** here, not kazeshini, which sounds like 不死 "undying". | D (wordplay; matches the Brave Souls "Undying" rendering) | — |
| **The forms "Kazeshini Kōjō" and "Fūshi Kōjō" in the brief are not attested in anything I found.** | — | — |

### 2.2 Source and opponent

- **Source**: Ryōgo Narita (story, with Tite Kubo's input and designs), *BLEACH Can't Fear Your Own World*, **volume III**,
  **chapter 24**, plus the Final Chapter for the aftermath. Shueisha JP 2018-12-04, Viz EN 2021-04-20. Hisagi is the
  series' lead. A (via C), fandom `Bleach: Can't Fear Your Own World`; ciatr says 卍解登場回 3巻 (C).
- **Opponent: Hikone Ubuginu, not Tokinada.** Tokinada is the novel's main villain and gets fought with the Shikai
  (ch. 22–23). The Bankai is used on Tokinada's creation / protégé Hikone (Shinigami–Hollow–Quincy–Fullbringer hybrid
  carrying Soul King fragments, wielding Ikomikidomoe), to stop Hikone killing Aura Michibane and to keep Zaraki from
  killing Hikone. Hisagi asks Zaraki to stand aside; Zaraki does. A (via C), CFYOW III ch. 24.

### 2.3 How it starts (A via C, CFYOW III ch. 24)

1. Hikone bisects him; in his inner world (an idyllic plain with big trees and a **red, rusty windmill that turns
   forever**; Kazeshini appears as **black wind**) Kazeshini "yields". Hisagi understands that dedicating his life
   "means not to die or kill, but rather to not let others die". Kazeshini: freely manipulating who lives and dies "is
   the very definition of a god of death".
2. Back in the fight, before the Bankai, the **Shikai's chain already heals him**: Hikone bisects him again, cuts off his
   arms, blasts a Cero through his chest; black chains pull him back together each time. Bystanders note it is not
   zombification and not High-Speed Regeneration, and that the **surrounding Reiatsu has changed**.
3. Release: he **throws both scythes into the air; the chains intertwine and form a whirlpool above him**; he calls the
   Bankai; **a black wind of Reiatsu bursts out of him**.
4. The wind stops and **the scythes come back to his hands**. He is **wrapped in his own chain**. Hikone **cannot sense
   any Reiatsu** any more, though it is clearly there.

### 2.4 What it does (A via C, CFYOW III ch. 24)

- **The orb**: a **jet-black orb made of chains, hovering above them**. Chains run from it to Hisagi and to Hikone. It
  casts shadows "as if they were beams of light" (inverted lighting). Its chains **cannot be destroyed for good**: Hikone
  Ceros the orb itself; the chains part for a moment and rejoin.
- **The noose**: Hisagi **raises one of the blades and the chains constrict around both their necks**, linking the two
  fighters neck to neck.
- **Who it binds**: Hisagi plus the opponent he chooses (the wiki: "any opponent Hisagi chooses"). Only one opponent is
  ever shown.
- **Leash**: Hikone tries to put distance between them; **the chains simply pull them back**.
- **"Neither can die" healing**: every injury to **either** fighter heals at once. Hisagi uses the chains to **rip off
  Hikone's arm**; it is back before Hikone feels the pain. Hikone tests it by **tearing off their own arm** and Ceroing
  Hisagi.
- **The cost**: **each healed injury drains the combined Reiatsu of both fighters** (the wiki: "at the cost of their
  combined Reiatsu"). Hikone notices their Reiatsu falling from the moment the Bankai starts.
- **Not immortality**: Hisagi says he will certainly die if Hikone keeps attacking him without end, **and so will
  Hikone**. Neither can kill the other until both are exhausted. **Hisagi cannot kill the opponent with it** either: "it
  is outright not possible for him to do so."
- **Pain stays**: wounds heal, the pain does not. Hikone asks him to end it; he refuses. Hikone realises nothing can
  hurt him more than the deaths already dealt. The wiki counts **over one hundred "deaths"** (bisection, crushed organs,
  full incineration by Cero), endured without faltering.
- **World effect**: the orb **stagnates the Reishi** in the air, halting the circulation of life and death ("neither
  regression nor evolution"), like the world before Soul Society existed. The Shikai = reaping, the circulation of life;
  the Bankai = **a chain of seals that stops the flow**.
- **Classification**: Shunsui calls it a rather extreme **"Bakudō-type"** Bankai, hard to use (Final Chapter).
- **Danger to the user**: when it drops, both are drained, so either side's allies (Shunsui, Zaraki) could kill the
  exhausted fighters. It is "dangerous to its wielder unless they have nearby allies they can trust without question".
- **Duration**: not timed. It lasts while both have Reiatsu. Hisagi spends it teaching Hikone, pointing out the flaws in
  Hikone's technique and Tōsen's lessons, while he is cut apart over and over without resisting.
- **How it ends**: both Reiatsu nearly empty, both collapse. Hisagi asks Shunsui not to hurt Hikone, Shunsui agrees,
  and **Hisagi deactivates it voluntarily**, meaning to put Hikone to sleep with Hakufuku. (Then Ikomikidomoe's Hollow
  form lunges at Hikone, Aura shields the child, and Zaraki destroys Ikomikidomoe.)
- **Aftermath**: Seinosuke Yamada scolds him for the reckless Bankai. Hisagi says he only reached it just now, having
  "materialised and subjugated" Kazeshini without noticing. Shunsui says that makes him eligible for captain; **he
  declines to stay editor-in-chief of the Seireitei Communication**.

### 2.5 How Hisagi feels about it (A via C)

- He **envies flashy Bankai** like Tensa Zangetsu or Daiguren Hyōrinmaru. Fushi no Kōjō is **his fear of dying and his
  fear of killing, made into a power**.
- He is still guilty about having fallen into hatred against Tokinada. The Bankai is the opposite: he uses it to save the
  enemy. ciatr sums it up: 「自分が死ぬのも相手を殺すのも怖い、檜佐木らしい卍解」 ("a Bankai that is very Hisagi:
  afraid both of dying and of killing") (C).
- Short quotes from the wiki summary (paraphrase-close, not the book's exact wording): the chain halts "the flow of life
  and stagnates the world"; Kazeshini, about manipulating life and death: "the very definition of a 'god of death'".

### 2.6 Look

| Claim | Grade | Source |
|---|---|---|
| Black orb of tangled chains overhead, chains running down to the noose round Hisagi's neck and to the opponent. Hisagi holds the scythes, chains trailing. Black wind at release. | A (via C) | CFYOW III ch. 24 summary |
| The novel illustration (`Hisagi's Bankai CFYOW.png`, pencil): Hisagi stands straight, a **thick twisted rope of chains rises from his neck straight up** to a tangle at the top of the frame; one scythe in each hand hanging down, chains looping to the ground; a figure lies at his feet. The scythes there read as **single long crescent blades**, not the Shikai pinwheel (D from the picture; the drawing is rough). | A (picture) / D | `.refs/hisagi/Hisagi_s_Bankai_CFYOW.png` |
| Brave Souls art: a **huge black sphere** top-right, many chains hanging from it, **chain coiled round his neck and right arm**, two black crescent scythes, sleeveless shihakushō. | B | `.refs/hisagi/BBSHisagi_s_Bankai.png` |
| Brave Souls special: "countless chains rain down from a sphere in the sky", debuff nearby enemies, big damage + Weaken. | B (via C) | fandom §Video Games |
| Colour: black orb, black chains, black wind. Hisagi's Reiatsu is **green** (anime Ep219; also CFYOW). | A (via C) | fandom |
| **Size of the orb, length of the chains, how long the release takes: not stated anywhere I could read.** | gap | — |

### 2.7 Anime and games

- **Anime: not shown** in the manga or TYBW parts 1–3 (A, it isn't in the manga; C, Game Rant / CBR). **Part 4 "禍進譚"
  (The Calamity)** aired from **2026-07-25** (C, Famitsu `https://www.famitsu.com/article/202607/82448`). I found **no
  report** that it shows the Bankai. A Yahoo Chiebukuro answer argues it can't, because he learns it after the war (C).
  **Unverified: not watched.**
- **Brave Souls**: a playable "Post-Timeskip Bankai (CFYOW)" Hisagi exists. Melee strong-attack type, Heart attribute,
  "Arrancar Killer", chance to inflict Weaken on every attack. Special 「卍解『風死絞縄』」 = chains raining from a sphere
  (B via C, fandom). Its Gamerch page was not found.
- **Rebirth of Souls**: **no Bankai**. His Awakening is the Shikai (B, §5.1).

## 3. His look

| Claim | Grade | Source |
|---|---|---|
| Tall, lean. **181 cm, 67 kg**. Born 14 August. | A (databook) | BLEACH Bootleg ("karaburi") p. 103; Souls p. 181 (via fandom) |
| Dark grey eyes, short spiky black hair (blue-black in colour art). | A (via C) | fandom §Appearance; CFYOW cover art |
| **Three parallel scars running straight down over his right eye onto the cheek** (from a huge Hollow at the academy field lesson, Ep46 / ch. 384). | A | fandom; `520.5Hisagi_profile.png` |
| **"69" tattoo on his left cheek**, after the 69 on Kensei's chest (Kensei saved him as a child, ch. −104). Tattoos done by 6th seat Kajōmaru's family (Q&A #730). | A | ch. −104; Klub Outside #730 |
| **A blue horizontal stripe tattoo** across the left cheek and over the bridge of the nose (absent in the flashback before he became a seated officer). | A (via C) | fandom |
| **Choker** round the throat; matching **bands on both upper arms** (all explosive). | A | ch. 324 p. 12 |
| **Sleeveless shihakushō**; lieutenant badge tied to the **left arm**. White obi / sash. | A | fandom; Ep219 stills |
| **TYBW**: hair grown out, falling against his face down near the ears (17 months after Aizen). | A (via C) | ch. 489 p. 4; `Ep370DriscollConfrontsHisagi.png` (TYBW 4: messy fringe, scars, choker, sleeveless) |
| Academy days: hair down to the neck at the back. | A (via C) | ch. −17 p. 12 |
| Anime Kazeshini spirit (filler): thin dark man, long black hair to the lower back, light-blue eyes, grey cloth strips, curled-toe boots, red outline. | A (anime filler) | fandom `Kazeshini (Zanpakutō spirit)`; Ep234–236 |
| Bankai look: §2.6. In the Brave Souls art he keeps the TYBW-era face and the sleeveless robe. | B | `BBSHisagi_s_Bankai.png` |

## 4. Character themes that could become mechanics

Facts (A unless marked); the "→" lines are **D**, ideas only.

- **Fear of his own blade.** Tōsen's lesson: "He who fears not the blade he wields has no right to wield that blade"
  (ch. 325 p. 15; flashback ch. 384 pp. 15–18). Asked Tōsen to strip his seat because he was afraid (ch. 384). CFYOW
  ch. 22: Tōsen trained him inside Suzumushi Tsuishiki Enma Kōrogi (total sensory loss). He lasted half an hour and broke.
  Tōsen: "denying one's fear … would only turn those who do so into demons." → a Fear resource that rises as the fight
  gets dangerous; RoS already does exactly this (§5.1).
- **Reluctant release**: he fights sealed and releases only when cornered (ch. 324–325). → the awaken is gated by danger,
  not only by meter.
- **Restraint / "never excessive force"** (ch. 384). → binding and pulling tools rather than raw damage.
- **The release as the attack**: he released Shikai *inside* Tōsen's wound (ch. 386). → the awaken or Shikai-release
  input itself is a hitbox.
- **Tōsen**: his captain and mentor. Tōsen betrays him; he defeats Tōsen with Komamura (the killing blow is his
  ch. 386, Tōsen dies ch. 387). **Correction to the brief: chapters 386–387, not ~391.** CFYOW: he finally understands
  Tōsen's motives; Tokinada thanks him "for killing Tōsen". He defends Tōsen even to Kensei (ch. 538 p. 14).
- **Kensei / 69**: Kensei saved him as a boy (ch. −104), hence the tattoo. Kensei is now his captain and drove the Bankai
  training (ch. 538, 560). In CFYOW, Kensei realises it was Kazeshini that kept saving him.
- **Editor-in-chief of the Seireitei Communication**: his column "Please Teach Me! Shūhei Sensei!!" was cancelled after
  three lessons (Bootleg p. 139). In CFYOW he investigates as a journalist and turns down captaincy to stay editor.
  Also: guitar (Fender Stratocaster), motorcycle (Kawasaki Z-2) (Q&A #774). → cosmetic: taunts, win poses, a
  notebook/camera intro.
- **"Bankai fraud" running gag**: ch. 685, nobody has seen his Bankai; JP fans' 「卍解するするサギ」 (C, ciatr).
  → an intro / taunt line.
- **Lille Barro shot him** (ch. 635), and SOUL DUEL has Lille (index 6). → a natural special intro for that pairing (D).
- **The Bankai's rules as a mode** (all D): a neck tether linking both fighters; a leash that pulls the foe back past a
  max range; damage on either side converted into a drain on *both* fighters' resource instead of HP; no K.O. while it
  is up; it ends when Hisagi's pool runs dry or he drops it, and he is left exhausted. ⚠ This clashes with a K.O.-based
  1v1: it needs a design answer (e.g. healing converts damage into drain on both, the round can't end mid-Bankai, a
  timer, or a reduced "half heal") before building. RoS dodges the question by having no Bankai.

## 5. Existing games

### 5.1 BLEACH Rebirth of Souls (2025, Tamsoft / Bandai Namco): playable, base roster

Grade B (in-game strings via the data-mine; patch notes direct). `pl011`, "#27".
- Archetypes: **Mid / Hybrid Range, Fast, Melee + Ranged + Kidō, Gauge, "Ramper"**. Ease of use 3/5. Data-mine star
  stats: Power 3, Speed 3, **Range 4**, Defense 2, Technique 2 (C, site's rating).
- **Exclusive Ability "Fear"**: "You accumulate Fear when Awakenings occur or either fighter's Konpaku is destroyed. The
  higher the Fear, the more damage he deals to opponents, and some of his actions change." Patch 1.10 (2025-06-10): Fear
  is also added when he uses Spiritual Pressure Moves 1 and 2, because opponents starved him by not using Kikon moves.
  The intent wording: "a slow starter type that demonstrates his true value due to the influence of 'Fear'".
- **Signature: Hadō #58 Tenran** (whirlwind). Reishi damage even if blocked, big guard-gauge damage; area and hit count
  grow with Fear (the "Tenran Level"). Patch 1.10 extended its reach.
- **Spiritual Pressure Move 1**: Hadō #31 Shakkaho → **#33 Sōkatsui at Fear 7** → **#54 Haien at Fear 13** ("Kidō Level").
- **Spiritual Pressure Move 2: "A Warrior's Poise"**: a counter stance; a hit taken in it triggers a combo counter;
  power grows with Fear.
- **Special Flash Attack "Sliding"**: a slide-in slash, **invulnerable to projectiles**, blocked if it hits point-blank.
- **Awakening = Shikai Kazeshini**: "Hisagi tosses his blade aside, as it warps into a double-ended scythe, spinning in
  the air connected to a second scythe by a long chain, returning to Hisagi". After it, the Flash Attack changes into
  mid-range tools and the Fear boosts grow.
- **Kikon moves**: Normal "**Blade That Knows Fear**" (1–4 Konpaku, more with Fear 5 / 10) and Awakened "**Inherited
  Techniques**" (2–6 Konpaku, more with Fear 10 / 15 / 20).
- The base form fights with the **sealed sword and Kidō**; the chain is the awakened layer (B). RoS has no Bankai for him.
- Tōsen is his opponent in the reveal trailer (C, Siliconera).
- Not obtained: the awakened normal / flash strings and the Kikon cinematics' content (the data-mine's Awakened tab did
  not render).

### 5.2 Brave Souls (mobile, KLab), grade B (Gamerch JP pages = official skill text, transcribed)

| Version | Special | Text (official, JP) | Page |
|---|---|---|---|
| Kyōtō (Shikai & Kazeshini duo) ★4 | 風陣双撃 | 風死と共に縦横無尽に鎌を操り… (works the scythes in every direction together with Kazeshini) | `/458666`, `/851998` |
| Kyōtō ★5 知 | 刈れ | 凄まじい竜巻と共に相手を斬りつけ…麻痺 (slashes with a fierce tornado; paralysis) | `/458482` |
| Fierce Battle ★5 速 (vs Tōsen climax) | 風死 | 解号と共に始解した風死が鋭く突き刺さり… (release command, Kazeshini stabs sharply) | `/852017` |
| ★6 速 | 百歩欄干 | 百歩欄干で敵を捕らえた後、刀で斬りつけ… (Hyapporankan pins, then a sword slash) | `/826285` |
| TYBW 2026 ★6 力 (released 2026-09-30) | 風死 | 当たった敵全員に絶大ダメージ | `/1018146` |
| Bankai (CFYOW) | 卍解『風死絞縄』 | chains rain from a sphere in the sky; debuff, Weaken | fandom (C) |
| Academy | 決死の猛撃 | dodge, leap, downward slash | fandom (C) |

Also White Day, Christmas and Party Time joke variants (not useful). Tokinada's Brave Souls kit uses "Shuhei's Kazeshini"
among his copied normal attacks (C).

### 5.3 Older games (C, thin)

- First appearance: Heat the Soul 3. **First uses his Shikai as an attack in Heat the Soul 6** (fandom). Playable in Heat
  the Soul 6 and Blade Battlers 2nd (listed in their roster pages); **movesets not found**.
- DS series (3rd Phantom, Dark Souls): fights **mainly unarmed**; the scar story is changed (Tōsen saved him) (fandom).
- **Not in Soul Resurrección** (no Hisagi in its roster page). **Jump Ultimate Stars: not checked.**
- The Shikai's first screen appearance was the film *Fade to Black* (2008), before the anime (C).

## 6. Reference images (`.refs/hisagi/`, git-ignored; source URLs in `.refs/hisagi/_urls.tsv`)

All downloaded from the fandom image API. I looked at the ones marked "seen".

| File | Shows |
|---|---|
| `Hisagi_s_Bankai_CFYOW.png` (seen) | CFYOW III Bankai illustration, pencil: chain-rope from neck up to the orb, scythes in hand |
| `BBSHisagi_s_Bankai.png` (seen) | Brave Souls Bankai art: big black sphere, hanging chains, chain round neck and right arm |
| `CFYOWHisagi_portrait.png` (seen) | Kubo colour portrait (CFYOW): blue-black hair, blue stripe, "69" on left cheek, scars on right |
| `520.5Hisagi_profile.png` (seen) | Manga colour headshot, TYBW era: longer hair, 3 scars over his right eye, stripe, 69, choker |
| `Ep216HisagiProfile.png` | Anime profile, Arrancar arc |
| `Ep219HisagiShikaiKazeshini.png` (seen) | Full-body Shikai pose: pinwheel double blades on rods, chain to the ground, sleeveless, armband |
| `Ep219HisagiReleases.png` (seen) | Back view at release: one scythe forward on its rod, chain arcing, Findorr in the distance |
| `Ep219HisagiShikaiIntimidation.png` (seen) | Close-up: blade held across the face (the "are you scared" glare) |
| `219Findorr_and_armband.png` | Armband explosive thrown at Findorr |
| `Allonsmouth.png` | Ayon about to swallow Hisagi (ch. 337) |
| `Kubikake.gif` | Anime clip of Kubikake (190×108, 475 frames) |
| `Ep291HisagiStabsTosen.png` | Final blow on Tōsen |
| `Ep291HisagiImpalesTosen.png` (seen) | Silhouette: Hisagi on Tōsen's back, blade through the head |
| `Ep370DriscollConfrontsHisagi.png` (seen) | TYBW anime look (TYBW 4): fringe, scars, choker |
| `Ep371HisagiOverwhelmed.png` | Overwhelmed by Driscoll (TYBW 5) |
| `Ep383MaskClotheslinesHisagi.png` | Mask clotheslines him (TYBW 17) |
| `Ep389HisagiAttacksByakuya.png` (seen) | Under PePe, Kazeshini + Senbonzakura vs Byakuya (red-graded scene) |
| `Ep397IkkakuHisagiStruggle.png` (seen) | Shikai vs the black creatures, chain mid-swing (TYBW 31) |
| `BBSFierce_Battle_Hisagi.png` | Brave Souls Fierce Battle art (sealed sword) |
| `Ep260HisagiVsKazeshini.png`, `260Hisagi_blocks.png` | Filler: Hisagi with his own kusarigama vs the Kazeshini spirit |

No failed downloads.

## 7. Gaps and conflicts

1. **Bankai name**: the brief's "Kazeshini Kōjō / Fūshi Kōjō" is not attested. Use **Fushi no Kōjō (風死絞縄,
   ふしのこうじょう)**. The Viz English rendering in the novel is unknown (not checked).
2. **Bankai opponent**: the brief says Tokinada; canon says **Hikone Ubuginu** (CFYOW III ch. 24). Tokinada is beaten
   with the Shikai plus allies (ch. 23).
3. **Tōsen's death**: the brief says ch. ~391; it is **ch. 386** (Hisagi's blow) and **ch. 387** (death, by explosion;
   the text implies Aizen).
4. **Not read first-hand**: the CFYOW text itself. Every Bankai detail comes through the fandom chapter summaries. Exact
   lines, orb size, chain count and whether more than one enemy can be bound are **unknown**.
5. **Bankai scythes**: the novel illustration and the Brave Souls art draw single crescent blades, while the Shikai has a
   double (pinwheel) blade. Unclear whether the Bankai changes the blades or the artists simplified them.
6. **Anime Part 4 (2026)**: whether it adds the Bankai is unconfirmed (no report found, not watched).
7. **RoS awakened moveset** (normals, flash follow-ups, Kikon cinematics) not obtained; HtS 6/7, Blade Battlers and
   Jump Ultimate Stars movesets not found.
8. **Rod length / chain length** in Shikai: only pictures (D); Kubo says the chain extends but he keeps it short.
9. Fandom calls Kazeshini's ability "can restore any injury … even if his entire body is destroyed". That is a wiki
   paraphrase; the healing limit (Reiatsu) is the only stated cap.

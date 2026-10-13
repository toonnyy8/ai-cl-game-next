# Genryūsai Shigekuni Yamamoto: every visual state, for the procedural rebuild

Research date 2026-10-13. For SOUL DUEL's Yamamoto (index 0, `duel/lisp/yama.lisp`, art `yama-art.lisp`). Companion:
`motion-refs.md` (how he fights, the motion bars per form, gaps). Format follows `docs/research/kenpachi-rework/`.

## 0. Method, sources, grades

**Access.**
- `bleach.fandom.com/wiki/...` page views answer 403. The MediaWiki API works:
  - text: `api.php?action=parse&prop=wikitext&page=<title>`;
  - images: `api.php?action=query&prop=imageinfo&iiprop=url&titles=File:<name>`, then the returned URL plus
    `&path-prefix=en&format=original` (without `path-prefix=en` the CDN returns a 520-byte placeholder).
- Pages read (wikitext): `Genryūsai Shigekuni Yamamoto` (Appearance, Personality, Plot, Powers, Zanpakutō, Other Media,
  Trivia), its `/Image Gallery`, the battle pages `vs. Wonderweiss Margela`, `vs. Driscoll Berci`, `vs. Royd Lloyd`,
  `vs. Yhwach`, `Shunsui Kyōraku & Jūshirō Ukitake vs. Genryūsai Shigekuni Yamamoto`, the technique pages (`Ittō Kasō`,
  `Ikkotsu`, `Sōkotsu`, `Ennetsu Jigoku`, `Jōkaku Enjō`, `Taimatsu`, `Hitotsume: Nadegiri`, the four `Zanka no Tachi, …`
  pages), `The Fire (episode)` (TYBW ep. 6 = overall Ep372), `BLEACH Rebirth of Souls`.
- RoS: the official JP character page `https://bleach-ros.bn-ent.net/character/?chara=shigekuni-yamamotogenryusai` and
  the data-mine `https://resource-of-souls.com/characters/shigekuni-genryusai-yamamoto/` (in-game strings, `pl016`).
- Brave Souls: `bleach-bravesouls.fandom.com` API (kit names only; no animation text).
- 99 files went to `.refs/yamamoto/` (git-ignored, third-party; never commit): manga digital-colour panels, anime stills,
  official art, and 14 anime GIF clips from the wiki (190×108, ~20 fps, 13–37 s each). I **looked at every still I cite**
  (contact sheets) and sampled colours with PIL. GIFs were read as 0.5–0.8 s frame sheets.

**File naming on the wiki.** `NNN…` = manga chapter NNN (digital colour edition); `EpNNN…` = anime overall episode;
`294…` (no "Ep") = anime ep. 294 (the Wonderweiss fight, manga ch. 393–396). TYBW part 1: ep. 5 = Ep371 ("Wrath as a
Lightning", Driscoll), ep. 6 = Ep372 ("The Fire", Royd), ep. 7 = Ep373 (his death).

**Colour trust.** Manga digital colour = the albedo reference. The TYBW anime grades its fights hard (orange fire,
magenta/crimson for North and South), so anime samples are hue hints only. Model hexes marked [C] are my toon picks.

**Grades.**
- **[A]** the wiki states it with a chapter/page cite, or I saw it in a still myself (file named).
- **[B]** official game text or official game art (RoS, Brave Souls).
- **[C]** secondary text, or my estimate from a still.
- **[D]** my proposal for the game, not a reference.

**A correction to the brief.** Ittō Kasō belongs to the **Aizen** fight (ch. 395–396), not to Driscoll Berci. Against
Driscoll (ch. 503–504) he only takes the stolen Bankai's lightning and burns him with one Shikai slash [A].

---

## 1. Base: the robed Captain-Commander (sealed and Shikai)

### Takeaway
A small, thin, very old man (168 cm, 52 kg [A, infobox, Souls databook p. 200]) whose clothes make him big: a **huge,
long-sleeved white haori draped over the shoulders like a cape, not worn** (the sleeves hang empty), lined in **deep
purple**, over a black shihakushō with a white obi. A **long white beard bound down its length by crossing purple cords**
(an X lattice), long drooping white brows, a bald crown with **two crossed scars above the right eye**, eyes shut to slits.
He leans on a **tall, gnarled red-brown cane** that hides the sword.

### Findings
**Body and face**
- "fair-skinned man of average height … bald head, deep wrinkles, hooked nose, and pronounced cheekbones … red eyes, long
  eyebrows, long mustache, and a hip-length white beard secured by a purple band crossing down it" [A, wiki Appearance;
  red eyes cite the Vol. 45 cover].
- Scars: "many scars on his body … a pair of long scars crossing above his right eye" [A, ch. 504 p. 12]. Seen as an X on
  the right side of the crown/forehead in `206Yamamoto profile`, `Ep210YamamotoProfile`, `Yamamoto Anime Face` [A].
- "often standing in a slouch"; eyes "partially closed slits for the majority of the time", he opens "one or both" when
  surprised [A, wiki]. He fell asleep standing [A]. The anime opens one eye as the tell before a technique (`Taimatsu.gif`
  0.0–1.0 s, `HitotsumeNadegiri.gif`) [A visual].
- Brows: long, white, hanging past the cheekbones to the jaw (`Yamamoto Anime Face`, three views) [A visual].
- Beard: mustache flows into it; reaches the hip/groin; bound by a purple cord criss-crossing down its length (X lattice,
  4–6 crossings) (`Ep210YamamotoProfile`, `394Yamamoto prepares`, `Yamamoto Anime Fullbody`) [A visual]. TYBW manga
  (`506Yamamoto's Bankai`) draws the bound beard as a braided rope [A visual].

**Clothing**
- "a captain's long-sleeved haori draped over his back instead of actually wearing it, with its size being greatly
  exaggerated" [A, wiki]. Official art (`Yamamoto Anime Fullbody`, `RoS Yamamoto`): the haori hangs from the shoulders to
  the ankles, the empty sleeves wide and long, open at the front so the black robe shows in a broad vertical band [A/B].
- Haori lining: **deep purple** (`RoS Yamamoto`, `Ep226…`, `316Jokaku Enjo`, `338Taimatsu`: the purple shows whenever it
  flares) [A/B visual].
- Haori hem: a few black **slit and dot cut-outs** near the bottom edge on each side (`Yamamoto Anime Fullbody`, `RoS
  Yamamoto`) [B visual].
- Back: the 1st Division mark **一 inside a rhombus** (`Taimatsu.gif` 11.5–14 s, `Ep226YamamotoConfrontsAyon`) [A visual].
- Under it: black kosode, a white undercollar V, a **white obi tied with hanging ends** at the front, black hakama, white
  tabi and straw zōri (official art) [B]. Some anime frames show bare feet in straw sandals (`Sōkotsu.gif` 0.0 s) [A visual].
- Hands: big, knuckled, veined; the forearms are ropey (`394Yamamoto reveals`, `155Yamamoto's Zanpakuto`) [A visual].

**Sealed Ryūjin Jakka (the cane)**
- "usually takes the appearance of a wooden cane, which can be used like a spear … removes this disguise by disintegrating
  the wood, revealing … a standard katana, with a dark purple handle, a circular bronze handguard, and a brown sheath"
  [A, wiki].
- Look: a tall staff reaching his chest, red-brown, gnarled, swelling into a **knob head with a spiral grain** at the top,
  tapering to a point at the foot (`RoS Yamamoto`, `RyūjinJakka.gif` 0.5–2 s) [A/B visual]. He rests **both hands on the
  knob** when standing (pre-TYBW official art) [B].
- The reveal: the wood **peels off in curling strips** that fly away, leaving the sheathed katana upright
  (`155Yamamoto reveals`, `Ep55YamamotoRevealsZanpakuto`, `RyūjinJakka.gif` 2–4 s) [A visual].
- Hilt: dark purple wrap with pale diamond windows; round tsuba, gold/bronze in manga colour, grey in the 2009 anime; sheath
  red-brown (`155Yamamoto's Zanpakuto`, `RyūjinJakka.gif`) [A visual].
- First appearance: "approximately as long as Yamamoto was tall, resembling a nodachi … significantly lankier" (ch. 81)
  [A, Trivia]; later a standard katana [A].

**Shikai Ryūjin Jakka**
- Command 万象一切灰燼と為せ (ch. 155 pp. 23–24) [A]. "the blade … is engulfed in fire" [A]; in ch. 155–156 the whole blade
  turns into a surge of fire that **coils around him** (`155Yamamoto's Shikai`, `156Yamamoto releases`) [A].
- `RyūjinJakka.gif` (2009 anime): the drawn blade ignites from the tip downward, then flame swallows the frame [A visual].
- TYBW (ep. 5–6): the flame is an orange-white burst with a skull-like fire face over Driscoll (`YamamotoIncineratesDriscoll
  .gif` 4.8–8 s); afterwards he stands in a wall of fire, blade hanging low in the right hand [A visual].

### Model checklist (base, TYBW-era, one-armed)
- Height 1.68 m (as built). Head ≈ 0.22 m. Thin wrists and neck; long arms (hands reach mid-thigh, `394Yamamoto prepares`).
- Skin: lit `#EED7C0`, mid `#D1B59E`, deep shadow `#6F5D50` (sampled, `394Yamamoto prepares`). Repo now `#D8B4A0` [C: within range].
- Face: hooked nose, deep cheek lines, slit eyes (opening = the tell), brows hanging to the jaw, the X scar on the **right**
  side of the crown.
- Beard: white `#F0EEEA`, shadow `#B0A196`; the cord lattice `#414057`–`#535076` (manga) / `#82537D` (ch. 393 lit); repo
  cord `#4A3A6A` is in range. Draw 4–6 X crossings down the beard, not one band.
- Haori: white `#F4F5F4`, shadow cool grey; **lining `#441F58`, shadow `#26023C`** (sampled from official RoS art); a
  cape over both shoulders with empty sleeves hanging; 一 in a rhombus on the back; 2–3 black slit cut-outs at each side
  of the hem.
- Robe black, obi white with hanging ends, tabi white, zōri straw `#D8C79A` [C].
- Cane: red-brown `#A23A2A` lit / `#36241E` shadow (RoS art); knob head with a spiral groove; height ≈ 1.3 m.
- Sheathed katana (after the peel): hilt wrap `#2C1C3A` with pale diamonds, tsuba bronze `#C5BE9D` / `#A18A5F`, sheath
  `#8B4D3A`.

---

## 2. Upper body bared: the serious state

### Takeaway
When he means it he **strips the haori and the kosode top**, which hangs from the obi like a black skirt with the sleeves
dangling behind. Under it is a **wiry, sinewy, scar-covered body**, not bulky: long stringy muscles, deep abs, veined arms,
dozens of thin scars. The beard lattice stays on.

### Findings
- "Despite his old and frail demeanor … he in fact has a very muscular and well-defined build, which he only reveals when
  serious for battle" [A, wiki].
- Twice in canon: vs Shunsui and Ukitake, "removes his haori and top" before the Shikai (ch. 155 pp. 22–24) [A]; vs
  Wonderweiss, "removing the top half of his shihakushō" before Hakuda (ch. 394 pp. 6–10) [A]. The haori was already lost
  when Wonderweiss threw him (ch. 393) [A].
- Stills: `155Yamamoto's Shikai` (flame-lit, torso crossed by thin scars, one blade arm), `394Yamamoto prepares` (frontal:
  narrow shoulders, long arms hanging to the knees, sinewy, many scars, kosode at the waist with the white obi),
  `294Yamamoto removes` (anime: the black sleeves hang behind his hips like tails), `MangaVolume45Cover` [A visual].
- Anime adds glowing **red scars** on the bared torso and face when his reiatsu flares (`Ep55YamamotoExposesTorso`,
  `EnnetsuJigoku.gif` 0–3 s) [A visual, anime-only].
- Kubo's data chart gives Physical Strength 60/100, every other stat 100 [A, Bootleg databook]: strength reads as density,
  not bulk [C].

### Model checklist
- Same height and limb lengths. Torso: lean, ribs and serratus visible, eight-pack, a narrow waist; shoulders not wider than
  the robed silhouette (≈ 0.42 m). Long thin arms with knotted forearms.
- Scars: 10–20 thin darker lines across chest, belly and arms (`#B08A70` [C]); optional anime glow `#FF5A3C` along them.
- Kosode top folded down at the obi; the two black sleeves hang behind the hips; obi white.
- One arm in TYBW: the left sleeve of the folded-down top hangs empty; the left upper arm ends above the elbow (§6).
- [D] Use this for the **Hellfire** state (the game's "serious" timed form): canon gives no Hellfire look, and this is his
  own canon "serious" tell.

---

## 3. TYBW battle dress (Driscoll, Royd, Yhwach)

### Takeaway
In every TYBW fight still (ch. 503–511, Ep371–373) he wears the **black shihakushō only, no white haori**; the sleeve and
hem edges are **ragged, flame-eaten tatters**; the left forearm is gone. The haori appears in the office scenes.

### Findings
- `503Yamamoto deflects`, `506Yamamoto's Bankai`, `507Yamamoto attacks`, `507Zanka no Tachi, East`, `Ep372Yamamoto
  BankaiZankaNoTachi`, `Ep373YamamotoBifurcated`, Brave Souls' TYBW art (`BBS Yamamoto's Bankai`, `BBSFire Yamamoto`):
  black robe, white obi, torn black edges, no haori [A/B visual]. Brave Souls draws the kosode open over the chest [B].
- The empty left sleeve hangs at his side (`506Yamamoto's Bankai`) [A visual]. He lost the arm to Ittō Kasō (ch. 423 p. 6)
  and refused Orihime's healing (ch. 511 pp. 9–10) [A].
- Ep372 adds straw sandals and ragged hakama hems (`ZankaNoTachiHigashiKyokujitsujin.gif` 8.0 s) [A visual].
- Habit before the fight: "cracks his neck and right shoulder" (ch. 506 p. 10) [A].

### Model checklist
- [D] A TYBW costume variant: no haori (or burn it off on the Bankai cinematic), the robe's sleeve ends and hakama hem cut
  as 5–7 tatter triangles, the left sleeve empty and swinging.

---

## 4. Bankai Zanka no Tachi

### 4.1 The blade (all four directions)
- "the blade takes the form of an ancient and worn-out katana, severely scorched by fire" (ch. 506 pp. 16–17) [A]. "No flames
  are visible as it cuts" (ch. 507) [A]. Every flame already out is drawn into it at release (ch. 506 p. 15) [A].
- Manga colour (`506Yamamoto's Bankai`): a normal-length katana, **charred brown-black with grey ash patches**, slightly
  irregular edge; samples `#4A3327`, `#78563A`, `#A27D64`, ash `#E5DED5`. Hilt and tsuba unchanged (purple wrap, round
  bronze tsuba) [A visual].
- **A thin white smoke thread rises straight up from the tip** in every Bankai still (`506…`, `507…East`, `Ep372…Bankai`,
  `Ep372YamamotoExplainsAbility`, Brave Souls art) [A/B visual]. The most readable Bankai cue at game distance.
- Anime: the blade is black with **glowing ember cracks** (red-orange, lava-like) along its length
  (`ZankaNoTachiHigashiKyokujitsujin.gif` 2.4–5.6 s, 19–21 s); when he explains East, the **edge glows as a continuous
  ember line** (`Ep372YamamotoExplainsAbility`, samples `#A34126`, `#D56C3C`, `#EDB87A`) [A visual, anime].
- Carry: hanging low in the right hand, point down-forward, the arm relaxed (`506…`, `Ep372…Bankai`, `Driscoll.gif`
  9–14 s) [A visual].
- The Bankai of 1,000 years ago is only shown as a black silhouette in fire (`507Yamamoto's original Bankai`,
  `Ep372YamamotoOldBankai`) [A visual].

### 4.2 East: Kyokujitsujin (旭日刃)
- "concentrates the intense flames of the sword along the **tip** of the blade. It neither burns nor erupts, but anything it
  touches is eradicated" (main page, ch. 507 pp. 13–15) [A]; the technique page says "along the **edge**" [A]. Conflict §8.
- The demonstration: the tip touches the ground on a missed downward cut and **a huge chunk of ground and the building
  behind vanish** (ch. 507 pp. 8–11; `ZankaNoTachiHigashiKyokujitsujin.gif` 22–24 s: a deep clean chasm) [A].
- A grazing cut through Royd's cloak does nothing: it must hit directly (ch. 508 pp. 9–13) [A].
- Look: no aura on the body; the blade as §4.1. The explaining pose holds the blade level in front, fist toward the viewer
  (`507Zanka no Tachi, East`) [A visual].

### 4.3 West: Zanjitsu Gokui (殘日獄衣)
- "engulfs his body in heat … 15,000,000 degrees … impossible to even touch him"; "unseen … unless Yamamoto wills it";
  Haschwalth: such heat would not look like fire, it is his reiatsu seen as flame (ch. 507 pp. 14–19, ch. 508 pp. 1–2)
  [A]. "flames encircle his feet and enshroud his body, setting the nearby buildings alight"; "the ground beneath his feet
  heats up and melts … his feet beginning to sink into it" [A, battle page].
- Manga colour: **orange flame tongues** cover him from the feet up; at full flare they **wing out from the shoulders**
  about twice his width and rise above his head, a tall flared silhouette; the face and beard stay visible
  (`507Zanka no Tachi, West`, `508Yamamoto in flames`) [A visual]. Samples: `#F18349`, `#F69F5C`, core `#FADBA5`,
  shade `#7B3B24`; white-hot `#FEFEFA` in the core [A].
- The blade stays charcoal and low in the right hand inside the flames (`508Yamamoto in flames`) [A visual].
- Side effects shown in Ep372: moisture vanishes, water evaporates, clouds clear, Hitsugaya's ice melts, rain falls when it
  ends (ch. 507–509) [A]. Anime: Yhwach sees him as his **younger self** for a beat (Ep372) [A, anime].

### 4.4 South: Kaka Jūman'okushi Daisōjin (火火十万億死大葬陣)
- "Pushing his sword tip-first into the ground", with the incantation 「尸共　我が炎に散った亡者の灰よ　手を貸せ　暫し戦の
  愉悦をくれてやる」; the dead "emerge as **charred skeletons** from the ground" through a rupture that breaks Sankt
  Zwinger; they swarm, form a wall to shield him, and can show the faces they had alive (ch. 508 pp. 14–17, ch. 509
  pp. 1–8) [A].
- Manga colour: **black skeletons** with grey-white highlights, some with ragged hair and remnant cloth, sizes from human to
  several times his height (`508…Minami`, `509Cover`, `509Yamamoto is shielded`: a pile-wall of bodies) [A visual].
  Samples: `#000000`, highlight `#DFE5EB`, mid `#625E6A`.
- Anime: **crimson bones** on a dark magenta field, the ground split by red glowing cracks radiating from the blade
  (`Ep372…Minami`, `…Minami.gif` 13.6 s, 19–34 s) [A visual, anime].
- The planted blade: anime holds it **upright in front of his face, point down, the hilt at chin height**, during the
  incantation, then drives it straight down (`…Minami.gif` 8.8–13.6 s) [A visual].

### 4.5 North: Tenchi Kaijin (天地灰尽)
- "As Yamamoto manifests flames around the blade … he slashes at his target, generating an enormous wave of fire" (ch. 509
  pp. 15–16) [A]. It takes off Royd's left forearm and a large chunk of his torso; afterwards he releases the Bankai and
  rain falls [A].
- Manga colour (`509Zanka no Tachi, Kita`): a **wide diagonal white band** crosses the spread from upper left to lower
  right with Yamamoto, wrapped in West's flames, inside it, the blade a smear trailing behind; the four kanji 天地灰尽 in
  black and red brush at the corners [A visual].
- Anime: red-magenta flame streaks, the kanji as a white-on-black cut card, a white-out flash (`…Kita.gif`) [A visual].
- Brave Souls: "focuses all his flame in the tip of his sword then attacks" [B].

### Model checklist (Bankai)
- Blade: same katana length as Shikai; charcoal `#2A201B` [C] with brown char `#78563A` patches and ash flecks; an ember
  line or 3–5 ember cracks `#D56C3C` (anime) [C]; a thin vertical smoke thread from the tip (a 6–8 segment wobbling
  ribbon, white `#E8E4DE`) [C].
- East: no body aura (repo's "4 charcoal heat wisps" is a [D] liberty, harmless).
- West: orange tongue-flames from the feet up, flaring into two shoulder "wings" at peak (≈ 2× shoulder width, ≈ 0.5 m above
  the head); a molten ring at the feet (`#F7D49D` core, `#8E4737` rim). Canon is orange, not red.
- South: black skeletons with pale bone highlights (manga) as the base; the anime's crimson as the alternative. The plant
  pose: blade vertical in front of the face, then down.
- North: the cut as a broad diagonal white band with ember edges; kanji 天地灰尽 as the cinematic card.

---

## 5. Kidō, Hakuda and the burnt arm

- **Ennetsu Jigoku**: "running down the length of the cutting edge of the blade into the ground, a spark of liquid fire
  branches off in intricate circle pattern formations and creates several immense pillars of flame" (ch. 393 pp. 13–14)
  [A]. Manga colour `393Ennetsu Jigoku`: tall straight orange pillars, a dozen or more in a ring (`#F39F5F`, `#E7804F`,
  core `#F7D49D`, shade `#8E4737`) [A visual]. He holds Aizen by the arm while it rises (`393Yamamoto grabs`) [A].
- **Jōkaku Enjō**: "an immense wall of flame, which surrounds the target(s) before forming a huge sphere" (ch. 316) [A].
  `316Jokaku Enjo`: he **points the flaming blade straight out at arm's length** and a stream of fire runs off it to the
  far target [A visual].
- **Taimatsu**: "a great inferno with a wave of Ryūjin Jakka" (ch. 338–339) [A]. `338Taimatsu`: one-handed sweep, the haori
  flaring purple; `339Taimatsu2`: a **semicircle arch of flame over him** [A visual]. Anime: the flame becomes a tornado
  around the target (`Taimatsu.gif` 5.5–10 s) [A visual].
- **Ikkotsu / Sōkotsu**: one punch / a two-fisted punch (ch. 394–395) [A]. `394Yamamoto reveals`: the right fist driven
  straight out at shoulder height, sleeve pushed up, the forearm veined [A visual]. `394Sokotsu`, `Sōkotsu.gif` 20–28 s:
  **both fists side by side, arms locked straight**, the body leaning in behind them [A visual].
- **Ittō Kasō**: cast through "his own charred body … his arm cracking as he casts it" (ch. 396 pp. 2–4); "a massive
  pillar of red fire shaped like the tip of a katana" [A]. `396Itto Kaso1`: the **charred black arm with glowing red crack
  lines** gripping Aizen's ankle (the caption 焦げた腕が) [A visual]. Samples: `#231D1B`, `#070403`; cracks `#FF3A2A` [C].
  `Itto Kasō.gif` 9–15 s: a crimson-white pillar with a pointed top [A visual].
- **Burnt after the explosion**: "both arms and part of his face badly burnt", lying in a crater (`294Yamamoto lies`,
  `395Yamamoto is burned`: on all fours, arms blackened, blood) [A].

### Model checklist
- [D] A charred-arm material (black, red crack lines) is canon-backed for any self-sacrifice beat (a Hellfire burn tick, a
  Soul Break). The repo's empty left sleeve is canon for TYBW.

---

## 6. The young Yamamoto (posture and cinematic only)

- 2,000+ years ago: "black hair on the sides of his head and was bald on top … a tuft of hair sticking up at the back of his
  head in a topknot … thick but well-managed eyebrows and a mustache with no beard … a single large scar on his forehead
  (丿) … a sleeveless captain's haori worn appropriately" (ch. 504 pp. 6–12) [A]. `504Younger Yamamoto`,
  `Ep371YoungYamamoto`, `504Yamamoto is scarred`: a square heavy jaw, black handlebar mustache, stubble, brows slanted into
  a glare [A visual].
- Brave Souls' young version: upright and square-shouldered, flames curling round him (`BBSYoung Yamamoto`) [B].
- Ep372: Yhwach "briefly sees Yamamoto as a middle-aged man", and as his younger self when West appears [A, anime].
- Posture notes [C/D]: the young man stands **upright, chest out, chin down, square to the enemy**; the old man **slouches,
  head forward, eyes shut**, and only straightens when serious. A one-beat young-self overlay is a canon-backed cinematic
  accent for the Bankai or West reveal.

---

## 7. Game references (looks)

- **RoS** (B): official art = the robed Shikai look with both arms, the haori draped, purple lining, both hands on the cane
  (`RoS Yamamoto`, `ros_official_img_ill.webp`). Awakening is "Full power Shikai" [B, wiki]. A canon mod adds a
  "battle-damaged outfit from his Bankai moment" and young Yamamoto [C, Resource of Souls]: RoS itself has no Bankai.
- **Brave Souls** (B): Bankai versions East/South, West/North, The Fire, TYBW 2023/2026, Young, Hakuda, One-Armed. The TYBW
  art: black robe open on the chest, ragged sleeves, sheath at the left hip, smoke from the blade tip; West/North art: the
  flame-wrapped body inside a diagonal ink band (the North panel's grammar).

---

## 8. Conflicts

| Item | Source 1 | Source 2 | Pick for the game |
|---|---|---|---|
| Eye colour | red (wiki, Vol. 45 cover) [A] | dark brown/black irises in anime close-ups (`Taimatsu.gif`) [A visual] | irrelevant at 12 px; dark |
| East: where the flame sits | "along the tip" (main page, ch. 507) [A] | "along the edge" (technique page) [A]; anime draws an ember line along the whole edge [A visual] | ember **edge line**, brightest at the tip (as built) |
| Tsuba colour | bronze/gold (manga colour) [A] | grey/silver (2009 anime) [A] | bronze |
| Haori in TYBW fights | worn in office scenes and pre-TYBW art | absent in every TYBW battle still (§3) [A] | repo keeps it; a no-haori TYBW variant is a user call |
| How the haori is worn | draped like a cape, sleeves empty [A] | repo: a white shell worn over the torso | cape over both shoulders, empty sleeves hanging |
| Back mark | 一 in a rhombus (anime) [A] | repo: a bare 一 bar | add the rhombus |
| Beard cord | a lattice of crossings [A] | repo: "tied with a purple cord" (one band?) | 4–6 X crossings |
| West colour | orange (manga colour) [A] | repo: "red flames" | orange tongues, white-hot core |
| Skeletons | black, manga [A] | crimson, anime [A] | black (as built) |
| Footwear | white tabi + zōri (official art) [B] | bare feet in straw sandals (some anime frames) [A] | tabi |
| Bulk | "very muscular" [A] | 52 kg, Strength 60/100 [A] | wiry, not broad |

## 9. Gaps (looks) and how to close them
- **Manga B&W pages for ch. 506–509** were not reachable (only the wiki's colour panels): the exact West flare shape at
  each beat and the North panel's body pose. Close: the user's own volumes 57–58, or the colour edition pages.
- **Anime ep. 5–6 at full resolution**: the GIFs are 190×108. Close: watch Ep371–372 (Disney+/Hulu) for the blade's ember
  pattern and the West silhouette in motion; trace frames, never redistribute.
- **The skeletons' size mix and count**: inferred from 4 stills. Close: ch. 508–509 spreads.
- The haori's purple lining appears in anime and official art; the manga colour shows it once (`316Jokaku Enjo`) [A]; enough.

## 10. Image table (`.refs/yamamoto/`, git-ignored, never commit)

Every wiki file: `https://bleach.fandom.com/wiki/File:<name>`; downloaded from
`https://static.wikia.nocookie.net/bleach/images/<x>/<xy>/<name>/revision/latest?path-prefix=en&format=original`
(full list with exact URLs in `.refs/yamamoto/_urls.tsv`). Local names replace `'`, `,`, spaces and macrons with `_`.

| File | What it shows | Status |
|---|---|---|
| `Yamamoto_Anime_Fullbody.png` | TYBW anime model sheet, front: draped haori with purple lining, beard lattice, one hand visible | used |
| `Yamamoto_Anime_Face.png` | TYBW head, three views: X scar, brows, beard | used |
| `RoS_Yamamoto.png`, `ros_official_img_ill.webp` | RoS official art: cane, both hands on the knob, haori hem cut-outs (bn-ent.net) | used |
| `ros_official_img_cut-in.png` | RoS cut-in: closed eyes only | dropped (no info) |
| `206Yamamoto_profile.png`, `Ep210YamamotoProfile.png` | anime face, scar, beard cord | used |
| `155Yamamoto_reveals.png`, `Ep55YamamotoRevealsZanpakuto.png` | the cane's wood peeling off | used |
| `155Yamamoto_s_Zanpakuto.png` | hilt, tsuba, sheath close-up (manga colour) | used, sampled |
| `155Yamamoto_s_Shikai_Ryujin_Jakka.png`, `156Yamamoto_releases.png`, `156Captains_clash.png` | Shikai, bared torso, flame coil | used |
| `Ep55YamamotoExposesTorso.png`, `Ep55YamamotoUsesRy_jinJakka.png` | anime bared torso, glowing scars, blade overhead | used |
| `394Yamamoto_prepares.png`, `294Yamamoto_removes.png`, `MangaVolume45Cover.png` | bared body front, kosode at the waist | used, sampled |
| `394Yamamoto_reveals.png`, `294Yamamoto_punches.png`, `Ikkotsu.gif` | Ikkotsu | used |
| `394Sokotsu.png`, `294Sokotsu.png`, `S_kotsu.gif`, `BBSHakuda_Yamamoto.png` | Sōkotsu | used |
| `394Yamamoto_rips.png`, `294Yamamoto_rips.png` | tearing Wonderweiss's arms | used |
| `393Yamamoto_grabs.png`, `393Ennetsu_Jigoku.png`, `294Ennetsu_Jigoku.png`, `EnnetsuJigoku.gif` | Ennetsu Jigoku | used |
| `294Yamamoto_lies.png`, `395Yamamoto_is_burned.png` | burnt after the explosion | used |
| `396Itto_Kaso1.png`, `Itt_Kas_.gif` | the charred arm, the katana-tip pillar | used, sampled |
| `316Jokaku_Enjo.png`, `316Jokaku_Enjo1.png`, `Ep215J_kakuEnj_.png`, `J_kakuEnj_.gif` | Jōkaku Enjō | `316Jokaku_Enjo` used; the rest could not see detail (fire only) |
| `338Taimatsu.png`, `339Taimatsu2.png`, `Taimatsu.gif` | Taimatsu sweep, the flame arch | used |
| `338Hitotsume_-_Nadegiri1.png`, `338Hitotsume_-_Nadegiri2.png`, `HitotsumeNadegiri.gif` | Nadegiri | GIF used; stills show the result only |
| `Onibi.gif`, `Ep226YamamotoConfrontsAyon.png` | the cane thrust, the back mark | used |
| `Ry_jinJakka.gif` | cane peel, draw, ignition (2009 anime) | used |
| `503Yamamoto_deflects.png`, `Ep371YamamotoDeflectsHeiligPfeil.png` | deflecting the Heilig Pfeil one-handed | used |
| `504Yamamoto_kills.png` | Driscoll burning | dropped (Yamamoto not readable) |
| `Ep371YamamotoIncineratesDriscoll.png`, `YamamotoIncineratesDriscoll.gif` | TYBW Shikai slash, the shout, the fire wall | used |
| `505Yamamoto_takes_off.png`, `505Yamamoto_confronts.png`, `505Cover.png` | the comet launch, the landing, standing before a fire wall | used |
| `506Yamamoto_s_Bankai_Zanka_no_Tachi.png`, `Ep372YamamotoBankaiZankaNoTachi.png` | the Bankai blade, the low carry, smoke thread | used, sampled |
| `507Yamamoto_attacks.png`, `Ep372YamamotoAttacksRoyd.png`, `507Yamamoto_vs._Royd.png`, `Ep372RoydAttacksYamamoto.png` | the lunge cut; Royd's attacks | used |
| `507Zanka_no_Tachi_East_-_Kyokujitsujin.png`, `Ep372YamamotoExplainsAbility.png`, `Ep372ZankaNoTachiHigashiKyokujitsujin.png`, `ZankaNoTachiHigashiKyokujitsujin.gif` | East | used |
| `507Zanka_no_Tachi_West_-_Zanjitsu_Gokui.png`, `508Yamamoto_in_flames.png`, `Ep372ZankaNoTachiNishiZanjitsuGokui.png`, `ZankaNoTachiNishiZanjitsuGokui372.gif` | West (the GIF shows only the heat side effects) | used, sampled |
| `508Zanka_no_Tachi_Minami_-_Kaka_Jumanokushi_Daisojin.png`, `Ep372ZankaNoTachiMinamiKakaJumanokushiDaisojin.png`, `509Yamamoto_is_shielded.png`, `509Cover.png`, `ZankaNoTachiMinamiKakaJumanokushiDaisojin.gif` | South | used, sampled |
| `509Zanka_no_Tachi_Kita_-_Tenchi_Kaijin.png`, `Ep372ZankaNoTachiKitaTenchiKaijin.png`, `ZankaNoTachiKitaTenchiKaijin.gif` | North | used |
| `507Yamamoto_s_original_Bankai.png`, `Ep372YamamotoOldBankai.png` | the old Bankai (silhouette) | used |
| `510Yamamoto_is_slashed.png`, `Ep373YamamotoBifurcated.png` | his death; TYBW robe | used |
| `504Younger_Yamamoto.png`, `Ep371YoungYamamoto.png`, `504Yamamoto_is_scarred.png`, `BBSYoung_Yamamoto.png` | the young Yamamoto | used |
| `SJYamamoto_profile.png` | young Yamamoto 1,000 years ago | dropped (12 KB thumbnail) |
| `Ep373OriginalCaptains.png` | the original captains in silhouette | dropped (no detail) |
| `Ep371YamamotoScarred.png` | Chōjirō's scar (anime) | used with `504Yamamoto_is_scarred` |
| `506Cover.png`, `MangaVolume58Cover.png` | covers | 506 used (TYBW robe); 58 dropped (red monotone) |
| `KUBOYamamoto.png` | civilian clothes illustration | dropped |
| `BBS_Yamamoto_s_Bankai.png`, `BBSNorth-West_Yamamoto.png`, `BBSFire_Yamamoto.png` | Brave Souls Bankai art | used (B) |
| `RoS_Yamamoto_Ryujin_Jakka.png`, `RoS_Yamamoto_Ennetsu_Jigoku.png`, `RoS_Yamamoto_victory_screen.png` | RoS in-game shots | used (B) |

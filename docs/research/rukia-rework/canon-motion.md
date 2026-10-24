# Kuchiki Rukia (TYBW): how she moves, fight by fight, for the strike-clip rebuild

Research date 2026-10-24. The user's style for the rework: 「原作舉止＋日本舞踊」 (canon manner plus Japanese classical
dance), canon moves stay canon, invented strikes are proposals (the user, 2026-10-24, `docs/duel/DUEL_RUKIA_TYBW.md` §2,
DEVLOG §340). Looks: `canon-looks.md`; the dance archetypes and the motion bars: `style-refs.md`. Mechanics already
researched (the temperature ladder, costs, games' kits): `docs/research/tybw-characters/notes/rukia_tybw.md`; not repeated.

**Sources and access.** Bleach Wiki through its MediaWiki API (the battle pages follow the manga panel by panel): `Rukia
Kuchiki vs. Di Roy Rinker`, `… vs. Aaroniero Arruruerie`, `… vs. Riruka Dokugamine`, `… vs. Äs Nödt`, `The White Haze
(episode)` (with its Anime Notes), the technique pages `Some no mai, Tsukishiro`, `Tsugi no mai, Hakuren`, `San no mai,
Shirafune`, the volume page holding ch. 235, the character page's Powers section. RoS: the Resource of Souls data mine
(in-game EN strings) and the official JP page. Stills and two Ep385 GIFs (190×108, 20 fps) in the git-ignored
`.refs/rukia-rework/`, read as frame sheets (`_sheets/`); the GIFs give poses and order, not exact timing. **No full episode
was watched.**

**Grades.** **A** canon text (wiki, chapter / episode cited) or a still / GIF frame I looked at (file named; "anime" when
anime-only). **B** official game text. **C** secondary or my estimate from a still. **D** my inference or proposal.

---

## 1. Canon, fight by fight

### 1.1 General (wiki Powers; A)
- Swordsmanship "rudimentary" at first; trained by Kaien Shiba (ch. 268 p. 8); later holds her own against Aaroniero, who
  has Kaien's skill (ch. 266 pp. 1–7).
- Kaien's style, as she reads it on Aaroniero: "the unorthodox style, high-held weapon, style of spinning, **dance-like
  technique**, and method of trapping the enemy" are "all Kaien's moves, which her eyes and body know" (ch. 265–266). The
  teacher's style is a dance: the canon root for a dancing Rukia.
- Shunpo expert: "helpful and effective because of her high speed" (Renji); dodges several Adjuchas at once (Ep149); after
  the palace training fast enough to surprise and cut Äs (ch. 567 pp. 13–14).
- Kidō expert, top of her class; "able to instantly switch from Zanjutsu to Kidō without delay should she lose her
  Zanpakutō" (ch. 266 pp. 9–11). Hakuda "seldom relied on".
- Small but strong: carries two unconscious captains with a shawl (Ep384).
- Her dances are **舞** (*mai*), not 踊り: the command is 「舞え」 ("Dance") and each technique is a numbered *mai* (初の舞, 次の
  舞, 参の舞). In Japanese dance terms *mai* is the slow, circling, gliding kind (see `style-refs.md` §1) [A for the names;
  the reading is D].

### 1.2 The release 「舞え、袖白雪」 (ch. 201 p. 16 / Ep117; ch. 264 p. 17 / Ep155)
- "Rukia holds her Zanpakutō out in front of her and turns it in a circle counter-clockwise. While she is turning it, the
  blade, hilt, and tsuba turn completely white … The transformation is accompanied by a rush of cold air in all directions"
  [A, wiki].
- `Ep117RukiaShikaiSodeNoShirayuki.png`: square to the camera, feet together, the blade held **vertically before her
  centreline, point down**, right fist at the chest, the left hand on the right forearm; the ribbon a vertical loop round
  her [A, anime].
- `264Rukia_releases.png` (manga colour): the end of the turn: a **low wide stance**, knees bent, the blade driven out
  forward-left, the ribbon closing a huge circle round her, snow bursting from her feet [A].
- RoS's awakening: "Rukia holds her Zanpakuto as she spins it in a circle, mimicking the reflection of the pale white moon"
  [B].
- The repo's `:ru-intro` turns the hand's twist through 360° in front of her [as built]; canon matches.

### 1.3 vs Di Roy (ch. 201 / Ep117): the first 初の舞・月白
- Blocks his strike and "is pushed down" by it; thrown up, **lands on the side of a telephone post and pushes herself off it
  to slash** (a wall kick) [A].
- Tsukishiro: "calls out the name of the dance **while holding her Zanpakutō upside down**. The blade glows, and she makes
  a slashing motion when her target is in position. When she does this, she draws a circle with the tip" [A, technique
  page, databook *Masked* p. 78]. The circle took in both of them; the pillar caught Di Roy mid-air; "Rukia … **walks away**
  as the pillar shatters" [A].
- `201Some_no_mai__Tsukishiro1.png` (manga colour): **a deep crouch**, knees wide, weight low; the blade low at her right
  side; **the ribbon a horizontal ring at hip height**; the white disc on the ground under both [A].
- `Ep117SomeNoMaiTsukishiro1.png`: crouched and leaning, the right arm sweeping low and wide, the ribbon ring round her [A].
- `201Rukia_reveals.png`: after the pillar, she stands upright, calm, the blade point-down behind her right hip [A].

### 1.4 vs Grimmjow (ch. 235 / Ep140): the first 次の舞・白漣
- "punctures the ground once, creating a large ice circle … then punctures the ground in front of her four times in a semi
  circle. As ice particles begin to flow up from the punctures … she **takes a battle stance**. After building up at the tip
  … the particles are released as a large, powerful avalanche of cold air" [A, technique page].
- `235Tsugi_no_mai__Hakuren.png` (manga colour), the battle stance: knees bent, one foot forward; **both hands on the hilt
  raised to head height**, the blade horizontal over her head pointing back-left (a high *kasumi*-like guard); four ice
  spikes standing in the plaza round her; particles rising in columns; **the ribbon standing straight up** from the pommel
  [A].

### 1.5 vs Aaroniero (ch. 264–268 / Ep155–160)
- Releases in anger; a wave of ice (Hakuren) from a platform; then "simply levels Sode no Shirayuki" at him [A].
- Blocks Nejibana's tip "inches from her head"; blocks the next blow "**with one hand on the blade** of Sode no Shirayuki"
  (a two-hand block, the left palm on the flat) [A]. `Ep155RukiaKaienClash.png`: the blade horizontal overhead [A, anime].
- Disarmed, she "holds out her hand in front of [his] face and fires Hadō #33 Sōkatsui" (the palm at his face) [A];
  Hainawa on his arm, then a double incantation (Nijū Eishō) [A].
- "pulls Sode no Shirayuki out of the ground … assumes a battle stance"; later "**leaps forward to attack**"
  (`Ep155RukiaAttacksKaien.png`: in the air, the blade raised overhead one-handed, the cloak flying) [A].
- Impaled, she grips Nejibana's handle and **ice spreads outward from her left hand** (the touch-freeze before TYBW) [A].
- 参の舞・白刀: she "lifts the broken Sode no Shirayuki to Aaroniero's face with her trembling right hand"; an icy blade grows
  out of it and pierces his head; then she **shatters the capsule by slashing downward** [A].
  `268San_no_mai__Shirafune.png`: a straight one-handed arm, the ice blade through his head [A].

### 1.6 vs Riruka (ch. 469–471 / Ep363–364, Fullbring arc, the TYBW-era look)
- Slices a heart cabinet; "easily dodge[s] or destroy[s]" plushies with the Shikai [A]. `469Rukia_cuts.png`: **the blade
  raised high over her right shoulder, one-handed**, the left fist forward [A].
- Turned into a plushie, she escapes by Shunpo; her Sōkatsui backfires [A].
- **Ice-rope connection**: an ice line from her hand to the dropped sword lets her cast Tsukishiro at a distance; Riruka
  escapes with a frozen foot (ch. 471 pp. 14–15) [A]. `471Ice-Rope_Connection.png`: the ice line on the floor, the sword
  lying with its ring guard [A].

### 1.7 vs Äs Nödt (ch. 566–570 / Ep385): the true Shikai and the Bankai
Per the battle page and the Ep385 page [A]; stills and GIF frames as noted.
1. **Dodges** "dozens of Reishi Thorns" (she runs: Äs mocks her for it) [A].
2. **The ice wall**: "intercepts them by creating a wall of ice with her Shikai" (the motion is not described); the fear
   seeps through the wall, down the blade and up her arm; her arm freezes and she **drops the sword** [A].
3. **The bare-hand catch**: "Rukia catches one with her **left hand** and freezes it solid from the point of contact … letting
   the frozen chunks fall" [A]. `Ep385RukiaFreezesThorn.png`: the open hand, fingers spread, the ice growing up the thorn
   away from the palm [A, anime]. `SodeNoShirayuki.gif` 12.6–13.8 s: **the left arm raised forward-high, palm toward him**,
   the blade held low and back in the right hand; then the blade drawn across her body and lowered point-down at her right
   side [A, anime].
4. **The cooling** (`SodeNoShirayuki.gif` 0.0–1.5 s): standing square, the blade low; **she turns a quarter, arms opening,
   the cloak flaring into a bell**; mist rises in spirals round her feet; she ends with the left arm out to the side [A,
   anime].
5. **−18 °C**: "moves past him with Shunpo, cuts deeply into and freezes his left shoulder" (a pass-through cut; she ends
   behind him) [A]. `Ep385RukiaCutsAs.png`: the frozen wound in the foreground, her white figure standing some way behind
   him, back turned, still [A, anime]. `SodeNoShirayuki.gif` 9.6–12.0 s: her black silhouette in mid-air inside a white
   column, the ribbon looping above [A, anime].
6. **−50 °C**: she stands; "the ground shaking around them is from her freezing the water beneath the ground" (no motion
   given: the quake comes from her stillness) [A].
7. **−273.15 °C**: "as Äs rushes toward her … freezing Äs completely solid", then "**standing several meters behind Äs**"
   (she passed him again) [A]. `Ep385RukiaFreezesAs.png`: Äs frozen mid-run; in the background she stands low, the blade
   held low back, the ribbon trailing on the plaza [A, anime].
8. **The thaw**: "slowly raising her body temperature"; a small cut on her thumb [A].
9. **Vs Tatarforas**: "she **leaps forward and slashes at him several times**, only for her blade to not reach" [A]
   (anime: he lands in front; manga: behind, and she turns) [A, Anime Notes]. `SodeNoShirayuki.gif` 25.8–27.0 s: the blade
   raised overhead in the right hand, then the cut, a white arc [A, anime].
10. **The Bankai**: Byakuya leaves "Rukia to **hold up Sode no Shirayuki in a battle stance**"; she activates the Bankai "in a
    pillar of ice"; "**raising her blade towards her opponent**, Rukia releases a massive wave" (Ep385) [A].
    `HakkaNoTogame.gif`: the eyes close and open (0–5.4 s), white-out (6.0–6.6), a snowflake blooming on the plaza into a
    pillar under a flat disc (7.2–9.6), **the ice blade held level in the right hand, slid out horizontally** (10.2–11.4),
    the wave over the city (14.4–17.4), the curved ice blade in close-up (18.0–19.8), then she stands still, **the blade
    point-down low across her body, the ribbons looping round her** (20.4–27.0) [A, anime].
11. **After**: her hand cracks; Byakuya holds it; she exhales cold air [A].

### 1.8 Ep387, Ep411 (TYBW, anime)
- Ep411 "LIFE TO DEFEND YOU" (anime-original; wiki episode page via the 2026-09-27 notes): Renji sends her ahead; she
  **throws** her Shikai blade, which freezes Yhwach's darkness; fights beside Ichigo freezing darkness on contact and
  freezing the ground to pin him; Bankai while the Blood Chains hold him; impaled by a Reishi broadsword [A, anime].
- `Ep411RukiaRunsZabimaru.png`: running along Zabimaru's segments, **body low and forward, the blade trailing level behind
  her** in the right hand [A, anime].
- `Ep411IchigoRukiaPrepare.png`: **both hands on the hilt at the waist, the blade vertical before her face** (a centred,
  upright guard) [A, anime].
- `Ep411IchigoRukiaAttack.png` (from behind): a **wide, deep stance**, the blade held low and across, ice spikes erupting
  round Yhwach while her thrown blade flies past [A, anime].
- "Her mobility in this form was initially severely limited … by the time of the penultimate battle against Yhwach, Rukia
  was able to move at roughly her normal speed" [A].

### 1.9 Signature habits (graded)
| Habit | Where | Grade |
|---|---|---|
| One-handed blade (right), arm extended, the left hand free | Ep385 Shikai still, ch. 268, ch. 469 | A |
| Two hands for the big stance: Hakuren's high guard, the Ep411 vertical guard, the overhead block | ch. 235, Ep411, ch. 266 | A |
| The blade **point-down** ("upside down") to cast and at rest | Tsukishiro, Ep117 release, ch. 201 reveals, ch. 570 | A |
| A **counter-clockwise** circle with the blade (the release) | ch. 201, 264 | A |
| **Low, wide, knees-bent** stances; deep crouch to draw the circle | ch. 201, 264, Ep155, Ep411 | A |
| The free **left palm**: kidō at the face (Sōkatsui), the catch, freezing what it grips | ch. 266, 268, 567 | A |
| **Shunpo passes**: ends behind the target, back turned, still | ch. 567 (−18, −273) | A |
| Walks away while the ice shatters | ch. 201 | A |
| Stillness while the cold works (the quake, absolute zero) | ch. 567 | A |
| Overhead raise before a cut or a release | ch. 469, ch. 569, Ep385 GIF | A |
| Light and agile: wall kicks, leaps, "high speed" | ch. 201, ch. 266, Ep149 | A |
| Dance-like spinning learned from Kaien | ch. 265–266 | A |

## 2. Games

### 2.1 BLEACH Rebirth of Souls (2025; pre-TYBW Rukia, Shikai as the awakening) [B]
| Slot | String (Resource of Souls / official page) |
|---|---|
| Awakening | "holds her Zanpakuto as she spins it in a circle, mimicking the reflection of the pale white moon; the blade shimmers with permafrost … a snow-white tassle flows from the sword's handle" |
| Base SP1 "You're Too Slow!" | "Hunker down in a deep stance. Taking an attack in this stance triggers a Shakkaho counter" |
| Base SP2 Sōkatsui | "Incant a Sōkatsui that explodes right in front of you" (official: 「前方へ突進し斬り払い、ヒットすると蒼火墜で追撃」) |
| Base Special Flash "Lunge Slash" | "Step through a forward slice at the enemy. Moves quickly … close the distance in an instant from mid-range" |
| Awakened Special Flash "Rush Slash" | "Get in close to unleash **two slashes**" |
| Awakened SP1 Tsukishiro | "**Leap back** and unleash Tsukishiro. **Warps to the opponent** and triggers a huge ice pillar at their feet. You're invincible while leaping back" |
| Awakened SP2 Hakuren | "**Stab** Sodenoshirayuki into the ground … you can stab the ground up to two more times to increase Hakuren's power" |
| Kikon | Tsukishiro (base and awakened); awakened Kikon 2: Hadō #73 Sōren Sōkatsui |
| Style | 「小回りが利き攻撃を仕掛けやすい」; Resource of Souls: "pulls foes into range with her multi-hit moves … close-to-mid-range" |

RoS confirms two motion ideas canon leaves open: **Tsukishiro off a backward leap** and **Hakuren as repeated stabs that
power the wave**. No video was watched, so the bodies of these moves are not known beyond the strings.

### 2.2 Other games (B, from the 2026-09-27 notes)
- Jump Force: the three dances as specials; the Bankai as the awakening super, reverting "upon the ice shattering".
- Brave Souls: the Bankai as a special: "A pillar of frozen air with Rukia at its center erupts from the ground to the sky".
- Heat the Soul 3: 氷破雪月花, a slash-through freeze before the canon Tsukishiro existed (technique page trivia) [B].

## 3. The current clips against canon (`rukia-art.lisp`)
| Clip (slot) | As built (one line) | Canon / style note |
|---|---|---|
| `:ru-stance` | right foot forward, body turned, blade low forward, a light bounce | canon has the one-handed forward blade [A]; the bounce is a boxer's, not *mai* (no bob, low hips: D) |
| `:ru-q1` J1 | a one-handed flat cut, left arm flung back | fine as a cut; the hit pose planted, no glide |
| `:ru-q2` J2 | the backhand back along the same line | the same plane as J1 |
| `:ru-spin` J3, O | a pirouette on the ball of the foot, one key at S for the full 360° | the skill wants a key every 90°; canon turns are counter-clockwise (check its direction) |
| `:ru-thrust` K1 | a fencer's lunge, back arm up | a Western fencing figure; canon has no fencing lunge |
| `:ru-ring` K2 | a rising turn, the blade swept up; **in all four forms** | shared clip |
| `:ru-drop` K3 | both hands high, dropped | matches the overhead raise [A] |
| `:ru-tsukishiro` L | low, the point drawn round in one sweep | matches canon [A] but the blade is not reversed and the ribbon is too short to ring her |
| `:ru-stab`, `:ru-hakuren` SP1 | point into the plaza loop; release swept up | canon stabs then a two-hand high stance before the release [A]; missing |
| `:ru-shirafune` SP2 | the deepest one-handed thrust | matches [A] |
| `:ru-hainawa` I | the left hand snaps forward, two fingers | fine (canon: the rope from her hand) |
| `:ru-palm` −18 K1, −273 J2 | the bare left palm driven out | the catch is canon [A]; canon's catch is arm raised forward-high, palm to him, not a punch |
| `:ru-flower` K3 | one knee down, palm into the plaza | D (invented) |
| `:ru-reido` −273 L | the left palm swept out low | D |
| `:ru-hakka` O | the blade raised, then levelled | matches [A] ("raising her blade towards her opponent") |
| `:ru-kikon` | the pirouette end, then low and a ground circle | fine |
| `:ru-intro` | the blade turned counter-clockwise before her | matches [A] |

## 4. Canon beats most useful for clips (each a separate silhouette)
1. **The CCW blade circle** (release): the blade before her, turned through a full circle; the ribbon a loop round her (A).
2. **The reversed blade, the low crouch and the ground circle** (Tsukishiro): point-down, sink, sweep the tip round; the
   ribbon a hip ring; then rise and walk away (A).
3. **The four stabs and the high two-hand guard** (Hakuren): stab, stab-stab-stab-stab in a half circle; both hands raised
   to head height, ribbon straight up; release (A).
4. **The one-arm thrust from the trembling hand, the ice growing, then a downward slash** (Shirafune) (A).
5. **The raised palm catch** (−18 reveal): the left arm forward-high, the open palm, the blade low and back (A).
6. **The Shunpo pass**: she ends behind, back turned, still; the wound freezes a beat later (A).
7. **Stillness as the attack** (−50 quake, −273): the body does nothing; the plaza does (A).
8. **The overhead raise** (ch. 469, Ep385 slashes, the Bankai's battle stance) (A).
9. **The two-hand vertical guard** before the face (Ep411) (A).
10. **The crouched run with the blade trailing level** (Ep411) (A).
11. **The Bankai's still figure**: upright, the blade point-down across her, ribbons moving round her while she does not (A).

## 5. Gaps
- **No video watched.** The ice wall's motion, the thrown blade in Ep411 and the slashes vs Tatarforas are known only by
  text and one or two frames. Close: Ep385 at 9:00–20:30 and Ep411's Rukia scenes, logged as wind-up / hit / hold frames.
- **RoS bodies**: only strings; close with a RoS awakened-Rukia combo video (the leap back into Tsukishiro, the stabs).
- **Kaien's "spinning, dance-like" style** is described, not shown in the stills I have (Ep155/160 flashbacks).
- The manga's black-and-white pages of ch. 566–570 were not read; the battle page follows them, but the exact poses of
  the −18 pass and the −273 freeze are anime frames.
- No canon choreography exists for J / K strings: every J / K body in `style-refs.md` §5 is a D proposal on canon habits.

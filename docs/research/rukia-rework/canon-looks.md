# Kuchiki Rukia (TYBW): every visual state, for the look rebuild

Research date 2026-10-24. For SOUL DUEL's Rukia (index 2, `duel/lisp/rukia.lisp`, art `duel/lisp/rukia-art.lisp`), the
rework in `docs/duel/DUEL_RUKIA_TYBW.md` (the user, 2026-10-24: 「重作整體造型模組」). Companions: `canon-motion.md` (how she
fights, fight by fight) and `style-refs.md` (nihon buyō archetypes and the motion bars). The earlier fact file is
`docs/research/tybw-characters/notes/rukia_tybw.md` (2026-09-27); this file extends it with stills and does not repeat
its mechanics. Format: `docs/research/ichigo-rework/canon-looks.md`.

## 0. Method, sources, grades

**Access.** `bleach.fandom.com` page views answer 403; its MediaWiki API works (`api.php?action=parse&prop=wikitext` for
`Rukia Kuchiki`, `Rukia Kuchiki/Image Gallery`, the battle pages, the technique pages, `The White Haze (episode)`;
`prop=imageinfo&iiprop=url`, then the URL plus `&path-prefix=en&format=original`). RoS: the official JP page
(`bleach-ros.bn-ent.net/character/?chara=rukia-kuchiki`) and the Resource of Souls data mine
(`resource-of-souls.com/characters/rukia-kuchiki`).

58 files went to `.refs/rukia-rework/` (git-ignored, third-party; never commit): manga digital-colour panels, anime stills
(1433×929 / 1440×1080 / 1920×1080), two anime GIF clips (190×108, 20 fps, 31–37 s) read as frame sheets in
`.refs/rukia-rework/_sheets/`. I looked at every file I cite. Colours were sampled with PIL (marked [C]).

**Episode numbering.** The wiki uses the overall number: TYBW ep. n = Ep(366+n). Ep385 = TYBW 19 "THE WHITE HAZE"
(vs Äs Nödt); Ep387 = TYBW 21; Ep411 = TYBW 45 "LIFE TO DEFEND YOU" (anime-original Rukia vs Yhwach). Pre-TYBW
references: Ep117 (vs Di Roy, ch. 201), Ep140 (Hakuren vs Grimmjow, ch. 235), Ep155–160 (vs Aaroniero, ch. 264–268),
Ep361–364 (Fullbring arc, ch. 459–471).

**Colour trust.** Manga digital colour is the albedo reference. The anime grades its TYBW fights hard (Ep385 is blue-cold
with red rims, Ep411 blood-red), so its hues are not albedo.

**Grades.** **[A]** canon: the wiki with a chapter / episode cite, or a still / GIF frame I looked at (file named; anime-only
details say "anime"). **[B]** official game text (RoS). **[C]** secondary text, or my estimate / sample from a still.
**[D]** my proposal, not a reference. **[U]** a decision the user already made. **[G]** a repo design choice not taken from canon
and not the user's own words.

**Corrections to the repo's current text.**
- DUEL_RUKIA §2 says the ribbon "is an fx ribbon along the pommel's position history". The code draws it as **static
  geometry** (`ru-ribbon`, 8 segments × 0.05 m ≈ 0.4 m, plus a 0.25 m curl), "short enough never to poke far out of a
  pose" (`rukia-art.lisp`). Canon's ribbon is several metres long (§1).
- DUEL_RUKIA §2 gives her a white armband with 十三 in ink. Canon's lieutenant badge is a **gold-tan plaque** tied on with a
  white cloth over a **shortened left sleeve** (§2).
- In TYBW canon she never fights in a plain shihakushō until after the Bankai: from ch. 559 to ch. 570 she wears the
  **Ōken** outfit (white head shawl, visor, long white cloak) (§2.2). The plain black look is [G] (DUEL_RUKIA §2), which is
  also what she wears from Ep387 on and in Ep411.

---

## 1. Shikai: 袖白雪 Sode no Shirayuki

### Takeaway
A slim, plain katana turned **pure white**: blade, hilt and guard. The guard is a **hollow round ring** with a snowflake
lattice inside; a **long, flat white ribbon** (the manga calls it a "long, flat tassel") runs from the pommel. The ribbon is
the shape that reads at any range: it makes loops wider than she is tall in every turn, rises straight up in the cold
updraft, and lies along the ground when she is still.

### Findings
- Release: "the blade, hilt, and tsuba turn completely white. The tsuba becomes a hollow snowflake-like circle, and a white
  ribbon forms from the pommel" (ch. 201 p. 16, Ep117); "a long, flat tassel" (the Di Roy battle page) [A, wiki].
- Sealed form: a normal katana, a rectangular tsuba with flame-like patterns, a reddish-brown hilt [A, wiki Zanpakutō].
- Guard, seen: `471Ice-Rope_Connection.png` (manga colour): a **round** white ring around the blade with an inner hub [A].
  `Ep385RukiaShikaiSodeNoShirayuki.png`: a round disc-ring whose centre is an open snowflake lattice, about 1.5× the
  hilt's width [A, anime]. Not hexagonal in either.
- Hilt, seen: white, a diamond wrap pattern, a small tie at the pommel where the ribbon starts
  (`Ep385RukiaShikaiSodeNoShirayuki.png`, `Ep385ByakuyaHoldsRukia.png`) [A, anime].
- Ribbon length and behaviour, seen:
  - `264Rukia_releases.png` (manga colour, the release vs Aaroniero): the ribbon closes a near-circle about **1.5× her
    height** across round her and the blade; at 1.44 m that is a loop of ~2.2 m diameter, so **≥ 6 m of ribbon** [C, estimate].
  - `201Some_no_mai__Tsukishiro1.png`, `Ep117SomeNoMaiTsukishiro1.png`, `Ep155SomeNoMaiTsukishiro1.png`: a **horizontal ring
    at hip height** round her body during Tsukishiro [A].
  - `Ep117RukiaShikaiSodeNoShirayuki.png`: a vertical loop round her while she holds the blade point-down before her [A, anime].
  - `235Tsugi_no_mai__Hakuren.png`: in Hakuren's stance it **rises straight up** from the pommel in one tall loop [A].
  - `Ep385RukiaShikaiSodeNoShirayuki.png`: one-handed, arm out; the ribbon loops back past her shoulder and off frame [A].
  - `SodeNoShirayuki.gif` 28.2 s and `Ep385RukiaFreezesAs.png` (background figure): at rest it **trails on the plaza** behind
    her [A, anime].
  - Width: about the blade's width or less, flat, no fringe [A].
- Blade length: stills show a standard katana against her small frame (fist to tip ≈ 0.55 × her height ≈ 0.8 m in
  `Ep385RukiaShikaiSodeNoShirayuki.png`) [C, measured].
- Scabbard: black, thrust through the white sash at the **left hip**, often still worn while she fights
  (`459Rukia_stabs.png`, `235Tsugi_no_mai__Hakuren.png`, `Ep117RukiaShikaiSodeNoShirayuki.png`) [A].
- −18 / −50 in Ep385: cold mist runs along the blade, rime on its edge (`SodeNoShirayuki.gif` 6.6–9.0 s) [A, anime]. The
  rimed blade `:ru-rime` matches this.
- RoS: "the blade shimmers with permafrost, coating it in a white gleam, as a snow-white tassle flows from the sword's
  handle" [B, Resource of Souls string].

### Model checklist (Shikai blade)
- White blade (#F4F6F8, shade #9AA8BE as now), ~0.8 m at her scale.
- Guard: a round ring (r ≈ 0.045 m, 12–16 segments) with six thin spokes to a hub: a snowflake read from the side and
  from behind [D].
- Ribbon: a **cosmetic chain**, 3–4 m drawn (canon ~6 m; trimmed so it never crosses the screen), flat, one width, lagging
  the pommel (lag × s^1.4, Lille's whip recipe, `skills/duel-motion-style` red flags), hanging to the plaza and trailing
  when still, rising when cold [D]. It never touches the sim (presentation is cosmetic).
- A black scabbard at the left hip, worn in play [D].

---

## 2. The TYBW outfits

### 2.1 Lieutenant shihakushō (Fullbring arc → TYBW; the gameplay look)

**Takeaway.** A black shihakushō with an asymmetric top: the **left sleeve is cut short** to a puffed cap over the upper arm
with the lieutenant's badge on it; long **white fingerless tekkō** run from the hand to above the elbow on both arms (the
right one under a normal wide black sleeve); a white sash with the knot at the front; a long, wide hakama; white tabi and
straw sandals.

**Findings**
- "She wears a fingerless white tekkō, similar to Byakuya's, which extend above her elbows. As a lieutenant, she wears her
  Division Badge around her uniform's left sleeve, which has been shortened to just reach her upper arm" (ch. 459 p. 14)
  [A, wiki Appearance].
- Seen: `459Rukia_stabs.png`, `460Rukia_kicks.png` (manga colour): the left sleeve a short black puff; the badge a gold-tan
  plaque (sampled #C0A060–#D0B070 [C]) with 十三 and the snowdrop in black, tied on over a white under-sleeve; the white
  tekkō full length on the left arm, from the knuckles to above the elbow; the right sleeve wide and black, the tekkō's end
  showing at the wrist [A].
- TYBW: `Ep387ByakuyaCautionsRukia.png` (from behind) shows the plaque on the left arm [A, anime]; `Ep411IchigoRukiaPrepare.png`
  shows the short left sleeve with the plaque and a wide right sleeve [A, anime]. The tekkō are not clearly visible in any
  TYBW still I have (the Ep411 grade is too red; `Ep385RukiaFreezesThorn.png` shows a cuff line at the wrist) [C].
- Hakama: ankle-length, very wide, pleated; it billows into a bell in her turns and lunges (`Ep117SomeNoMaiTsukishiro1.png`,
  `Ep155SomeNoMaiTsukishiro1.png`, `264Rukia_releases.png`) [A].
- Sash: white, wrapped twice, the knot at the front (`459Rukia_stabs.png`, `Ep117RukiaShikaiSodeNoShirayuki.png`) [A].
- Ep411 (anime-original): the same black uniform with a **white scarf or stole round the shoulders**
  (`Ep411IchigoRukiaPrepare.png`, `Ep411IchigoRukiaBicker.png`) [A, anime].

### 2.2 The Ōken outfit (ch. 559–570, Ep384–385, until the Bankai)
- "a long white shawl wrapped around her head and hang past her shoulders, fluffy white earmuffs, a white visor covering her
  eyes, and a long white cloak worn over her shihakushō"; destroyed by the Bankai (ch. 570 p. 7) [A, wiki Equipment].
- Seen: `Ep385RukiaShikaiSodeNoShirayuki.png` (the head wrap, a dark visor pushed up, the cloak over the black uniform);
  `SodeNoShirayuki.gif` 0.0–1.5 s: the cloak **flares into a bell** in a quarter turn as the cold mist rises [A, anime].
- The repo keeps the black look in play [G, DUEL_RUKIA §2]. Not proposed for the rework; recorded because every Ep385
  motion reference wears it (the flaring cloak is part of why those turns read).

### 2.3 Hair, face, proportions
- 144 cm, 33 kg (vol. 1 profile) [A, wiki infobox].
- Post-Fullbring: a **bob to the jaw**, pointed locks, several strands between the eyes (`460Rukia_profile.png`,
  `Ep361RukiaProfile.png`) [A]. Ten years later (ch. 685) long hair and a captain's haori: out of scope [A].
- Eyes: "big purple eyes" [A, wiki]; manga colour samples a pale lavender-grey iris with a dark pupil (#B0B0C0 range in
  `460Rukia_profile.png`) [C]; anime a deeper violet (`Ep361RukiaProfile.png`) [A, anime].
- Hair black with a blue sheen in the anime, white highlight strokes in the manga [A].

---

## 3. The cold states in play: −18 / −50 / −273 (canon vs the repo)

- Canon: in Ep385 the temperature ladder shows on **her surroundings**, not her outfit: frost on the plaza, mist spiralling
  up round her feet (`SodeNoShirayuki.gif` 0.9–1.5 s), the frozen wound, the quake; she still wears the Ōken [A, anime].
  At −273 nothing on her changes visibly before the Bankai [A, ch. 567, Ep385].
- She exhales cold air after the Bankai ("With Rukia exhaling cold air", Ep385) [A].
- Her hand cracks (`Ep385ByakuyaHoldsRukia.png`: her bare fingers inside an ice crust under Byakuya's gloved hand; the
  crack is described on the back of the hand) [A].
- The repo's band looks: −18 breath puffs and a stiff ribbon; −50 ice rims on hems, collar and hair tips, the rimed blade;
  −273 the body variant `:rukia-zero` with **white hair and irises**, the ice half-crown, an ice-blue keyline. The white hair
  at −273 borrows the Bankai's colouring: **the user's decision** ("white hair / ice crystals", the ice keyline, 2026-09-28)
  [U, DUEL_RUKIA §2].

---

## 4. Bankai 白霞罸 Hakka no Togame (the awakened Kikon cinematic only [U])

### Takeaway
A **white, ankle-length kimono** that glitters like frost, with a **tall standing collar of stacked ice bands**, **tiered
ice plates rising off the shoulders**, **very long, wide sleeves** (to the knee), a **snowflake of ice on the chest** with a
small tassel, an **ice ornament on the side of the head** (a spray of crystals like a feather, with a tassel in the anime),
white (manga) or pale-lilac (anime) hair and irises, and **many long ribbons** from the back that make large loops and
trail on the ground. The blade is the Shikai's shape in clear ice.

### Findings
- Text: "a white, ankle-length kimono with lined patterns … an attached ornate collar, edges, and shoulder design made of
  transparent ice with long, wide sleeves … long, flowing ribbons tied at her back that form numerous large loops … a small
  ice flower formation at the center of her chest, and a half crown of ice which extends around the back of her head. Rukia's
  hair and irises become white, and her blade … is now composed of transparent ice" (ch. 570 pp. 6–7, Ep385) [A, wiki].
- Seen, manga colour `570Hakka_no_Togame.png`: upright, the blade point-down low across her body in the right hand; the
  collar a tall ring of 3–4 stacked bands up to the jaw; shoulder plates stepped and pointing up-out; sleeves hanging to
  the knee; the ornament a spray of ice "feathers" on her **left** side of the head sweeping back; ribbons from the back in
  big loops, longer than she is tall, some lying on the ground [A].
- Seen, anime `Ep385RukiaBankaiHakkaNoTogame.png`: the same, with a sparkle texture on the kimono (sampled near-white
  #F0F0F0–#F3FCFC [C]); hair pale lilac-white (#E0E0F0 range [C]); the chest snowflake with a hanging tassel; the head
  ornament on her left with a tassel; the hilt white with a diamond wrap [A, anime].
- The Bankai blade's guard: in `Ep385ByakuyaHoldsRukia.png` and `HakkaNoTogame.gif` 10.2–11.4 s it reads as a **small
  bar-shaped guard**, not the ring [A, anime]; the wiki says the blade "still resembles its Shikai form". Conflict noted;
  the manga panel is too small to settle it [C].
- The wiki's "half crown … around the back of her head" vs the stills' one-sided ornament: the manga spray may wrap behind
  the head; neither still shows a symmetric crown [C].
- The release staging: a snowflake bloom spreading on the plaza, then a pillar with a flat disc at the top ("lake-like
  frost above and below", Oricon's quote of the official site), then the freezing wave
  (`HakkaNoTogame.gif` 7.2–17.4 s; `569Hakka_no_Togame.png` manga: a white pillar under a flat disc of white) [A].

### Manga vs anime (looks)
| Item | Manga | Anime |
|---|---|---|
| Bankai hair | white | pale lilac / translucent ("lilac hair", Ep385 summary; ABEMA: hair and lashes translucent) |
| Head ornament | an ice spray, no tassel visible | an ice spray with a tassel |
| Chest flower | a small ice flower | a snowflake with a hanging tassel |
| Kimono | flat white, lined | white with a frost-sparkle texture |
| Ōken visor (Shikai) | pushed up / not dominant | a dark glossy visor with red highlights |
| Shikai ribbon end | "a long, flat tassel" | a ribbon from a small tie at the pommel |

---

## 5. The current model (`rukia-art.lisp`) vs canon

| # | Item | Canon | Current model | Gap / proposed fix | Grade |
|---|---|---|---|---|---|
| 1 | **Ribbon** | ≥ 6 m, flat; loops wider than her height in turns; a hip ring in Tsukishiro; rises straight in Hakuren; trails on the ground at rest (§1) | static geometry ≈ 0.4 m plus a 0.25 m curl, bent behind the fist | **the biggest gap.** A cosmetic 3–4 m chain with lag × s^1.4, hanging to the plaza; per-move paths (ring, rise, trail); frozen stiff at −50 / −273 | A / D |
| 2 | **Left sleeve, badge** | short puffed left sleeve, a gold-tan plaque #C4A465 with 十三 and the snowdrop over a white under-sleeve (§2.1) | both lower arms the same wide box sleeve; a white band with ink on the left upper arm | cut the left sleeve to the upper arm; the plaque in tan on a white tie | A / D |
| 3 | **Tekkō** | white fingerless gloves from the knuckles to above the elbow, both arms (ch. 459) | bare skin hands, no forearm cover | white tekkō (left forearm all white; right showing below the sleeve); the white forearm also makes her palm moves (the catch) read | A (TYBW: C) / D |
| 4 | **Right sleeve** | a wide, hanging kimono sleeve | a 0.15 m box with a flap, rigid | a hanging sleeve panel that lags the arm (the 袖 archetype needs it) | A / D |
| 5 | **Hakama** | ankle-length, very wide, a bell in turns | a 0.44 m cylinder flare at the pelvis, black shin cylinders (reads as trousers) | a wide bell skirt (hip to ankle), its hem swinging out with root yaw | A / D |
| 6 | **Scabbard** | black, at the left hip through the sash | none | add it | A / D |
| 7 | **Guard** | a round ring with a snowflake lattice (§1) | a hexagonal ring with six points | a round ring with six spokes | A / D |
| 8 | Sash | white, the knot at the front | light grey #C8CCD6 box with a knot | lighten to the white key | A / D |
| 9 | Hair | a jaw-length bob, pointed locks, strands between the eyes | matches | none | A |
| 10 | Irises | lavender-grey (manga) / violet (anime) | #5A5070 | lighten toward lavender if it survives the S ≤ 0.3 rule (STYLE_STORM) | C |
| 11 | Proportions | 144 cm, small, slight | scale 0.80, width 0.92, head ×1.3 | keep; the hurt cylinder stays a fairness floor [G] | A |
| 12 | −273 white look | no visible change in canon (§3) | white hair / irises, the half-crown, ice keyline | keep (the user's call); align its ornament with the Bankai's side spray | U |
| 13 | **Bankai collar** | a tall ring of 3–4 stacked ice bands to the jaw | four cones round the neck | stacked rings | A / D |
| 14 | **Bankai shoulders** | tiered ice plates rising up and out | one cone a shoulder | 2–3 stepped plates a side | A / D |
| 15 | **Bankai sleeves** | very long, wide, to the knee | the base's box sleeves | knee-length hanging sleeves (the variant's own parts) | A / D |
| 16 | **Bankai ribbons** | many big loops from the back, tails trailing on the ground | two flat boxes and two 0.5–0.6 m tails | 3–4 loops plus 2–3 ribbon chains reusing #1's ribbon | A / D |
| 17 | Bankai head ornament | a one-sided ice spray on her left, a tassel (anime) | a symmetric fan of seven cones behind the head | a spray on her left sweeping back; a tassel optional | A / D |
| 18 | Bankai chest | a snowflake with a hanging tassel | four cones | a flat six-point star, a tassel optional | A / D |
| 19 | Bankai guard | a bar (anime close-up) vs "resembles Shikai" (wiki) | the ring in ice | user's pick; the anime's bar is what the close-up shows | A / C |
| 20 | Ep411 stole | a white scarf round the shoulders (anime) | none | optional: a TYBW marker that also lags in turns | A / D |

### Top five for the rebuild
1. The ribbon (#1): the one shape canon uses to draw every dance.
2. The sleeves: the short left sleeve with the plaque and the tekkō, and a hanging right sleeve (#2–#4).
3. The hakama as a bell that swings (#5): turns read from behind only if the hem flares.
4. The Bankai variant's collar, shoulders, sleeves, ribbons and ornament (#13–#18).
5. The scabbard and the round guard (#6–#7).

## 6. Gaps (looks)
- **TYBW tekkō**: confirmed in the Fullbring arc (manga colour); in TYBW stills too dark or too red to see. Close: a neutral
  Ep387 or Ep394 still, or the TYBW anime character sheet.
- **The Bankai guard** (bar vs ring) and the **half-crown vs side spray**: close with the manga ch. 570 pp. 6–7 at full size
  or the official TYBW Bankai setting sheet.
- **No RoS model**: RoS has no TYBW Rukia; no official 3D reference exists for her TYBW look.
- The ribbon's exact length is my estimate from two panels (§1).
- I did not read the manga's black-and-white pages; only the wiki's colour panels and anime stills.

## 7. Image table (`.refs/rukia-rework/`, git-ignored, never commit)

Wiki URLs: `https://static.wikia.nocookie.net/bleach/images/…?path-prefix=en&format=original`; local names replace spaces,
`'`, `,` and `&` with `_`.

| File | What it shows | Status |
|---|---|---|
| `Ep385RukiaShikaiSodeNoShirayuki.png` | Ōken outfit, one-handed blade out, round lattice guard, long ribbon | used (guard, ribbon, hold) |
| `Ep385RukiaBankaiHakkaNoTogame.png` | Bankai full figure (anime) | used (main Bankai ref) |
| `570Hakka_no_Togame.png` | Bankai full figure (manga colour) | used |
| `569Hakka_no_Togame.png` | the pillar under a disc | used (cinematic) |
| `Ep385ByakuyaHoldsRukia.png` | her iced hand, the Bankai hilt and bar guard | used |
| `Ep385RukiaFreezesThorn.png` | bare left hand catching, a wrist cuff | used |
| `Ep385RukiaFreezesAs.png`, `Ep385RukiaCutsAs.png`, `Ep385RukiaVsAs.png` | the −18 / −273 beats, ribbon trailing | used (see canon-motion) |
| `SodeNoShirayuki.gif`, `HakkaNoTogame.gif` (+ `_sheets/`) | Ep385 clips | used |
| `459Rukia_stabs.png`, `460Rukia_kicks.png` | short left sleeve, plaque, tekkō, sash, scabbard (manga colour) | used (main outfit ref) |
| `460Rukia_profile.png`, `Ep361RukiaProfile.png`, `476Rukia_profile.png`, `459Rukia_profile.png` | face, bob, eyes | used |
| `Ep361RukiaWithSword.png`, `Ep387ByakuyaCautionsRukia.png` | the plaque from behind | used |
| `Ep411IchigoRukiaPrepare.png`, `Ep411IchigoRukiaBicker.png`, `Ep411IchigoRukiaAttack.png`, `Ep411RukiaRunsZabimaru.png` | Ep411 look (stole), stances | used |
| `264Rukia_releases.png`, `201Some_no_mai__Tsukishiro1.png`, `235Tsugi_no_mai__Hakuren.png`, `268San_no_mai__Shirafune.png`, `201Rukia_reveals.png` (+ `_sheets/manga_dances.png`) | the dances (manga colour) | used (ribbon, see canon-motion) |
| `Ep117*`, `Ep155*`, `Ep160*`, `265Rukia_uses.png` (+ `_sheets/anime_dances.png`) | the dances (anime) | used |
| `471Ice-Rope_Connection.png`, `469Rukia_cuts.png` | guard ring (manga), overhead hold | used |
| `Ep385RukiaWatchesFear.png`, `Ep385RukiaRevealsPower.png`, `Ep385AsConfrontsRukia.png`, `566*`, `567*`, `562Rukia_lands.png`, `Ep380*`, `545*`, `613*`, `Ep411RukiaImpaled.png`, `Ep411TechniqueAftermath.png` | context | looked at, not cited / dropped (too dark, tiny, or no Rukia pose) |

## 8. Sources
- Bleach Wiki (MediaWiki API, wikitext): `Rukia Kuchiki` (Appearance, Equipment, Powers, Zanpakutō, Weaknesses),
  `Rukia Kuchiki/Image Gallery`, `Rukia Kuchiki vs. Äs Nödt`, `Rukia Kuchiki vs. Di Roy Rinker`, `The White Haze (episode)`,
  https://bleach.fandom.com/wiki/Rukia_Kuchiki
- Resource of Souls (RoS in-game strings): https://www.resource-of-souls.com/characters/rukia-kuchiki
- RoS official page: https://bleach-ros.bn-ent.net/character/?chara=rukia-kuchiki
- Oricon (the official site's Bankai text, quoted in the 2026-09-27 notes): https://www.oricon.co.jp/news/2290788/full/

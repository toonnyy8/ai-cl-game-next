# Kurosaki Ichigo (TYBW): every visual state, for the look rebuild

Research date 2026-10-14. For SOUL DUEL's Ichigo (index 3, `duel/lisp/ichigo.lisp`, art `ichigo-art.lisp`). Companion:
`canon-motion.md` (how he fights, fight by fight). Format follows `docs/research/yamamoto-rework/canon-looks.md`; the
earlier fact file is `docs/research/tybw-characters/notes/ichigo_tybw.md` (2026-09-27).

## 0. Method, sources, grades

**Access.** `bleach.fandom.com` page views answer 403; its MediaWiki API works (`api.php?action=parse&prop=wikitext`,
`list=allimages&aiprefix=EpNNN`, `prop=imageinfo&iiprop=url`, then the URL plus `&path-prefix=en&format=original`).
Pages read (wikitext): `Ichigo Kurosaki` (Appearance, Powers: Zanpakutō, Half-Hollowfication, Blood Chains Ichigo),
`Ichigo Kurosaki/Image Gallery`, `/Other Media` (the RoS kit), the battle pages `Ichigo Kurosaki vs. The Bambies`,
`Ichigo Kurosaki vs. Yhwach`, `Ichigo Kurosaki & Orihime Inoue vs. Yhwach`, the technique pages `Getsuga Jūjishō`,
`Blood Chains`, `Reiatsu Clones`, `Chain`, `Cero Creciente`, and the episode pages `LIFE TO DEFEND YOU` (Ep411),
`THE END` (Ep412), `THE END 2` (Ep413). RoS: the official JP page
`https://bleach-ros.bn-ent.net/character/?chara=ichigo-kurosaki_the_blood_warfare` (text + official art).
Brave Souls: `bleach-bravesouls.fandom.com` API (kit stats only).

97 files went to `.refs/ichigo/` (git-ignored, third-party; never commit): manga digital-colour panels, anime stills
(1414×918), 10 anime GIF clips (190×108, ~20 fps, 5–66 s), RoS official art. I **looked at every file I cite** (contact
sheets in `.refs/ichigo/_sheets/`), read GIFs as 0.15–1.4 s frame sheets, and sampled colours with PIL.

**Episode numbering.** The wiki files use the overall number: TYBW ep. n = Ep(366+n). Reforging ep. 13 = Ep379; Candice
ep. 21 = Ep387; Soul King palace ep. 28 = Ep394; vs Uryū ep. 30 = Ep396 and ep. 40 = Ep406; Wahrwelt throne room
ep. 42–44 = Ep408–410; **血鎖の一護 ep. 45 = Ep411 "LIFE TO DEFEND YOU"** (aired 2026-08-22; shown as "DEFEND YOU" until
the full title at the end); ep. 46 = Ep412 "THE END"; ep. 47 = Ep413 "THE END 2"; ep. 48 = Ep414 "THE END TWO WORLD".

**Colour trust.** Manga digital colour and the RoS official art are the albedo references. The anime grades its fights
hard (the Ep411 throne room is lit blood-red, so its skin and robe hues are not albedo). Hexes marked [C] are my samples.

**Grades.** **[A]** canon: the wiki with a chapter/episode cite, or a still/GIF I looked at (file named; anime-only details
say "anime"). **[B]** official game text or art (RoS, Brave Souls). **[C]** secondary text or my estimate from a still.
**[D]** my proposal, not a reference. **[U]** a decision the user already made (quoted from `docs/duel/DUEL_ICHIGO.md`).

**Corrections to the brief.**
- The short blade is **not** held in a reverse grip in any source I found: every still, the RoS art and the RoS stance text
  show a **forward (hammer) grip in the left hand** (§1.2).
- The TYBW top has **no right-arm guard or gauntlet**; the asymmetric armour is a **white pauldron with red scales on the
  LEFT shoulder** plus a matching plate at the **right hip**, joined by a white X across the chest (§2).
- The half-Hollow horn is a **long, forward-pointing spike** from the left side of the head (wiki: "a long,
  forward-pointing horn"), not a flat blade swept back (§3).
- He never fights Haschwalth with the two blades: Haschwalth cuts the **old** Tensa Zangetsu (ch. 514), before the reforging.

---

## 1. Shikai: the dual Zangetsu (二刀の斬月)

### Takeaway
Two **pure-black** blades with steel-grey sheen. Right hand: the **long cleaver**, a khyber-knife slab about his height
whose spine carries a **long thin slit** from the base to mid-blade, on a long cloth-wrapped tang. Left hand: the **short
blade**, a straight slab like a clipped cleaver whose **handle is an enclosed loop cut into the blade's own frame** (a
trench-knife grip), wrapped in cloth, held in a **forward grip**. At rest they hang at his sides, points down.

### Findings
**The pair**
- "two separate, purely black blades" (ch. 547 p. 2); long one = "the size of his previous sword … the shape of a khyber
  knife, with the grip at the base of the blade and a handle extending back … roughly the width and length of Ichigo's
  forearm. There is a thin, hollowed-out portion running along the back edge of the blade from the base to the middle"
  [A, wiki Zanpakutō, ch. 542 pp. 1–14].
- Short one = "relatively small, about the size of Ichigo's arm … resembles a trench knife more than a sword … an
  enclosed handle, with a portion acting like a hand guard" [A, same]. ja.wikipedia: 柄が無く石包丁に似た形状 [C, fact file].
- "the larger blade represents his inner Hollow … the smaller blade represents 'the old man' (… his Quincy powers)" [A,
  wiki, ch. 542]. (This closes the fact file's open "which blade is which" gap.)
- "After gaining his new Zanpakutō, Ichigo wraps the hilts of both swords in cloth, and now carries the larger blade on his
  back and the shorter blade on his right hip" [A, ch. 555 p. 2, Ep385].

**The long blade, seen**
- `542Ichigo_s_Shikai__Zangetsu` (manga colour): black slab with a long open window along the spine near the base, the tang
  a long black bar behind the fist [A]. `ros_tybw_img_ill.webp` (RoS official art, `_sheets/ros_blades.png`): a **white
  diagonal cloth wrap** on a ~0.28 m grip; a **stepped spur** on the spine side at the base; a **slender slit along the spine
  for ~45 % of the blade**; the blade widens toward the end and the edge sweeps up into a long curved point [B].
- RoS proportion (figure 1.81 m = 850 px): fist to tip ≈ 1.43 m, grip ≈ 0.28 m, widest ≈ 0.2–0.25 m near the end,
  ≈ 0.12 m at the base [C, measured].
- Carried on the back, the **wrapped grip standing up over his LEFT shoulder** (`582Ichigo_s_new_outfit`,
  `Ep394GetsugaTensho.gif` 0–0.6 s) [A].
- Half-Hollow state: "the larger blade of Zangetsu turns white" (ch. 675 p. 14); seen white in `Ep410IchigoMovesForward` [A].

**The short blade, seen, and how it is held**
- `542Ichigo_s_Shikai__Zangetsu` zoomed (`_sheets/c542hand.png`): a wide straight slab; its top is a closed rectangular
  frame; the left fist grips the frame's bar through the window, thumb side up, the blade continuing **straight down from
  the fist** as the arm hangs [A]. `Ep379IchigoShikaiZangetsu` (anime ep. 13) repeats the pose: long blade out in the right
  hand, short blade hanging point-down-forward from the left [A].
- `ros_tybw_img_ill.webp` (`_sheets/ros_short.png`): left hand, white-wrapped grip inside a black loop that closes above the
  fist, blade out and down at ~45°, **forward grip**; straight spine, the end clipped to a point; fist to tip ≈ 1.0 m [B].
- `Ep394IchigoPreparesFight` (`_sheets/cPrep.png`): guard X before the chest: the right fist low holds the long blade
  **point up**, the left fist at chest height holds the short blade **horizontal across the body**, blade leaving the
  thumb side: both forward grips [A].
- `Ep394YhwachEvadesIchigo` (`_sheets/cEvade.png`): flying lunge, long blade high in the right hand, the short blade low and
  **pointed forward** from the left fist [A]. `Chain406.gif` 5.2–6.0 s: he opens the left hand, the short blade flies into
  it (the "Chain" technique), he holds it **blade up** from a forward grip and fires a small Getsuga from it [A].
- Pointing it: "Ichigo lands, points the smaller blade of Zangetsu at Yhwach" (Ep409); "fire a Getsuga Tenshō by simply
  pointing his smaller sword at the enemy and making a small slash" (ch. 583 pp. 10–11) [A]. RoS 朔望 (Syzygy):
  「前方に刀を向けて構えを取り」, the wiki: "points the smaller blade of Zangetsu forward" [B].
- Length: "about the size of Ichigo's arm" (manga, ~0.7 m) [A]; anime and RoS draw it ~0.9–1.0 m [A/B, measured].
- He sheathes it to fight with the long blade alone (ch. 676 pp. 4–7, the half-Hollow) [A].

**Cloth**: the wraps are off-white with dark diagonal crossings; no loose cloth tail is drawn in TYBW stills (the old
single Zangetsu's long cloth is gone) [A visual: `Ep394IchigoPreparesFight`, `ros_tybw_img_ill.webp`].

### Model checklist (Shikai blades)
- Long (`:zangetsu-long`): black `#121216`–`#192031`, sheen `#39455A`–`#475368` [C, RoS samples]; the edge a thin
  lighter line, not white (stills show no white edge band; the repo's `#C8CCD4` edge is a readability choice).
- Shape: slab ~1.43 m, 0.12 m wide at the base widening to ~0.23 m, edge sweeping up into a curved point; a **slit**
  ~0.04 × 0.6 m along the spine from the base; a small stepped spur at the spine-side base; grip 0.28 m, off-white wrap with
  dark diagonals, **no guard**.
- Short (left hand): straight slab 0.75–0.9 m [D: between manga and RoS], ~0.13 m wide, the end clipped to a point; the
  handle a **closed loop in the blade's frame** with a wrapped bar; **forward grip**, blade leaving the thumb side.
- Carry (intro / win / idle beats): long blade on the back, grip up over the left shoulder; short blade in a black sheath
  at the right hip.

### Conflicts (Shikai blades vs the repo)
| Item | Canon | Repo (`ichigo-art.lisp`) | Pick |
|---|---|---|---|
| Short blade grip | forward grip, left hand [A, B] | `:weapon-l` "held REVERSED along the forearm" (+Y toward the elbow) | **forward grip** [D]; the reverse grip has no source |
| Short blade length | ~0.7 m manga, ~1.0 m RoS | 0.5 m blade | 0.75–0.9 m [D] |
| Short blade handle | enclosed loop / trench-knife guard | a 0.1 m wrap stub | add the loop frame |
| Long blade hole | a slit along the spine, base to mid | a 0.32 m hole between hilt and blade | lengthen into a spine slit |
| Long blade outline | widens to the end, swept curved point | constant 0.24 m slab, slanted tip | taper base → end |
| Edge colour | black blade, thin sheen | a white 0.016 m edge bar | keep a thin light edge for read [D] |

---

## 2. The TYBW shihakushō (Ōken outfit, then the X-strap outfit)

### Takeaway
After the palace he wears a black shihakushō with **a white X across the chest**, a **white pauldron with three red-scale
panels on the LEFT shoulder**, a matching **red-scaled plate at the RIGHT hip** (the short blade's mount), and a **white
cloak tied round the waist** that hangs like a split overskirt with black slash marks and ragged ends. **Sleeves are wide
and end around or just past the elbow** (manga, RoS), forearms bare with **black wristbands**; white tabi, straw zōri.
No haori, no rank badge, **no arm guard on the right**.

### Findings
- "two white shoulder plates crossing his chest in an X shape that hold his Shikai blades in place, with the first plate on
  his left shoulder having three sections adorned with red scales, the second … on his right waist (ch. 591 p. 2), and a
  white cloak with black markings tied around his waist (ch. 582 p. 12)" [A, wiki Appearance].
- Before that (ch. 555–582) the **Ōken clothing**: a head wrap, a green patterned scarf, a big tan cape with a padded
  yoke (`555Ichigo_s_Oken_clothing`, `Ep385IchigoOkenClothing`) [A]; Candice's Galvano Blast destroys it and he stands "in a
  secondary outfit with a red-scaled pad on his left shoulder and an X formed across his chest" (ch. 582 pp. 11–15) [A].
  The fight look is the X outfit; RoS dresses him in it too (`ros_tybw_img_ill.webp`) [B].
- Sleeves: `582Ichigo_s_new_outfit` (`_sheets/c582.png`) balloon sleeves ending at or just past the elbow, forearms bare,
  **black bands at both wrists** [A]. RoS art: wide sleeves to the upper forearm with a **white lining cuff** [B]. Anime
  stills often draw them longer, hanging past the forearm (`Ep394IchigoPreparesFight`, `Ep396IchigoSlashesArrow`) [A, anime].
- The X straps are flat white bands ~6–8 cm wide from each shoulder to the opposite hip, crossing on the sternum; the
  collar V is open, chest skin showing (`582…`, `Ep394…`) [A].
- The pauldron: a curved white plate on top of the left shoulder, three red panels with a scale texture
  (`#621415`–`#792224` [C, RoS]); Ep412: "his left shoulder is wounded and his pauldron is destroyed" [A].
- The waist cloak: white `#F4F4F0` [C], knotted at the front, hanging to the knees on both sides over the black hakama, the
  lower edges torn into points, broad black slash marks near the hem (`Ep394YhwachEvadesIchigo`: it streams behind him
  like a cape in a lunge) [A]. Orihime "grabs Ichigo by the edge of his cloak" (Ep409) [A].
- Build and face: 181 cm, 66 kg (Vol. 51) [A]; "fairly tall, lean-built", brown eyes [A]. TYBW: hair spiky orange, longer
  than in the Soul Society arc, with sideburns (ch. 424 spread) [A]. Lit hair `#D28B46`, shadow `#906C4E` [C, RoS].
- Posture: upright, shoulders square, weight low only when striking; at rest the blades hang at his sides
  (`542…`, `Ep379…`, `ros_tybw_img_ill.webp`) [A/B]. The scowl stays [A].

### Model checklist (outfit)
- Keep: black robe and hakama, white under-collar V, the sleeves ending just past the elbow with a white-lined cuff and bare
  forearms [U, v2 "Both forms: the look"; matches manga and RoS].
- Add: the white X (two flat bands, 0.07 m); the left pauldron (white shell, three dark-red scale panels); the right-hip plate
  (white, red scales) carrying the short sheath; black wristbands; the white waist cloak (two long panels to the knee, torn
  hem, 2–3 black slashes each) [D].
- Hair stays orange, muted per the house palette (repo `#B8733E` vs RoS lit `#D28B46`: the repo is the muted notan choice).

### Conflicts (outfit vs the repo)
| Item | Canon | Repo | Pick |
|---|---|---|---|
| Chest | white X straps [A, B] | plain black chest, the white V only | add the X |
| Shoulders | left: white pauldron, red scales [A, B] | plain black bevels | add the left pauldron |
| Right hip | red-scaled plate + short sheath [A, B] | none | add (cosmetic) |
| Waist | white cloak with black slashes [A, B] | black sash only | add the cloak panels (they also show motion: they stream in lunges) |
| Right arm guard | none in any source | none | nothing to add |
| Wrists | black bands (manga) [A] | bare | add thin black bands [D] |
| Sleeve length | past the elbow (manga, RoS); longer in the anime | past the elbow [U] | keep [U] |

---

## 3. Half-Hollowfication (半虚化, ch. 675–680; anime ep. 43–47)

### Takeaway
The left half only: **a long, thin, white horn from the left side of the head pointing forward**, black vertical stripes down
the left side of the face and neck, the left eye inverted (black sclera, yellow iris), a red glare in the anime. The long
blade turns white. No mask.

### Findings
- "the left side of Ichigo's face and neck change to resemble the form his inner Hollow took on while fighting Ulquiorra …
  his left eye inverts in color with a black sclera and yellow iris, he has dark marks running down his face and along his
  neck that reach into a hollow hole, and he gains a long, forward-pointing horn on the left side of his head" [A, ch. 675
  pp. 16–17].
- `675Ichigo_s_Half-Hollowfication` (manga colour): the horn rises from the upper left temple and runs **forward and down
  across the face** like a spike, about twice the head's length, tapering to a point; two thick black stripes from the
  hairline through the left eye to the jaw; black patches on the chest; the top torn [A].
- `Ep410IchigoRevealsControl` (anime): the same horn **straight out ahead of the face**, slightly curved, white with a pink
  rim light; the left eye red; black stripes [A, anime].
- `Ep410IchigoMovesForward`: full figure, the **white long blade low in the right hand**, the short blade sheathed at the
  hip, the X outfit intact [A]. Gran Rey Cero is charged **from the horn** (ch. 676 pp. 16–17) [A].
- Rukia (Ep411, anime): he "looks like he is rolled up in a black blanket"; he "insists that the horn is cool" [A].
- Yhwach breaks the horn off with the Bankai (ch. 678) [A].
- RoS: the awakening 虚化 (Hollowfication) of TYBW Ichigo [B]; its art was not on the page.

### Model checklist (half-Hollow; the repo draws this horn in both forms)
- Horn: a tapered white spike ~0.35–0.45 m [C: ≈ 2 head lengths], base ~0.04 m, from the upper left temple, aimed
  **forward** (toward the opponent) and slightly down; colour bone white `#E8E4D8` (repo `:horn` fits).
- Face: two black vertical stripes over the left eye from hairline to jaw, continuing down the neck; left eye black with a
  yellow (manga) / red (anime) iris.
- Long blade white while the state lasts.

### Conflicts
| Item | Canon | Repo | Pick |
|---|---|---|---|
| Horn shape and aim | long thin spike, forward-pointing [A] | "a flat white blade from the left temple, swept sideways and back" (`:horn` box 0.012 × 0.03 × 0.2 at rot −50°) | forward spike [D]; the sideways flat horn traces to the KESSA figures [U], not to the half-Hollow |
| Face marks | black stripes down the left side + neck [A] | only in the awakening cinematic's first beat (`:tag :mark`, white) | the manga marks are black, not white |
| Shikai form has a horn | only after ch. 675 [A] | the horn in the base form at all times | the user's look decision (v2) [U]; canon-wise the plain Shikai has none |

---

## 4. True Tensa Zangetsu (manga ch. 678–684; anime ep. 46–48)

### Takeaway (for contrast with KESSA's blade)
The two blades placed side by side become a **huge white khyber-knife blade with a black core**, a katana-like black-wrapped
grip, a stepped guard jutting from the underside, and a **chain looping from the guard over the spine to near the point**.
Under its white shell is the old single Shikai cleaver.

### Findings
- "places the two blades of his Shikai side-by-side, causing a surge of flaming energy … the smaller black blade comprises
  the inner part … the handle … with black wrapping … a section jutting out from the underside as a guard, with a chain
  attached to it that loops over the top and attaches right before the point" [A, ch. 678 p. 5].
- `678Ichigo_s_Bankai__Tensa_Zangetsu`: one-handed, raised; white blade, black core stripe, the chain loop, golden flame [A].
- `Ep414TrueTensaZangetsuB`: held **two-handed, low, point down-forward**, barefoot, torso bare under an open robe [A,
  anime]. `684True_Tensa_Zangetsu`: the shell shatters off the old black cleaver mid-swing [A].
- Its Getsuga is golden and huge (ch. 683; `GetsugaTensho414.gif`) [A].

---

## 5. 血鎖の一護 KESSA NO ICHIGO (anime ep. 45, Ep411, 2026-08-22; Kubo's design)

### Takeaway
Half-Hollowfication + Bankai: **two horns** (Full-Hollow style), **reddened skin, a thicker tattoo**, a **ragged black robe
open down the middle** on the bare chest, **barefoot**, glowing **blood-red chain reiatsu at the neck, both wrists and both
ankles**, and one **thick, tapered silver-white blade** with a white melted-texture grip, a black fuller, the **tip sheared
off**, and a long red reiatsu **tassel** that becomes the chains. Footsteps leave black flame.

### Findings
- Wiki (Ep411): "gaining a second horn on the right side of his head. Ichigo's skin darkens to a deep red color, his outfit
  changes to a ragged shihakushō that is open in the middle exposing his bare chest, and glowing blood-red chains of
  Reiatsu surge from his neck, hands, and feet. His Zanpakutō becomes a large silver sword with a white handle that has a
  melted-like texture. A black fuller runs from the handle through most of the length of the blade, and the tip of the
  sword is sheared off, leaving it with a wide cross-section. When he walks … footprints of flaming black Reiatsu" [A].
- Episode page: "a second horn mirroring the first on the other side of his head, a thicker tattoo, reddened skin, and red
  Reiatsu around his neck, wrists, and ankles"; he "steps forward with a thick, tapered sword bearing a long Reiatsu tassel
  in his right hand" [A]. Blood Chains page: chains formed "with the red Reiatsu tassel extending from the end of his sword
  … by either extending the tassel itself or driving the blade into the ground" [A]. The chains' colour and placement echo
  the red hair tufts of the Ulquiorra-fight Full Hollow (Trivia) [A].
- Official text: 完全虚化を思わせる二本の角, 首・手・足には血鎖の霊圧が迸る [B/C, fact file §2].
- `Ep411IchigoActivatesBloodChains` (`_sheets/cBCA.png`): silhouette: each horn goes **out sideways from the temple, then
  turns straight up** in an angular ⌐ bend, the tips above the crown (a Vasto-Lorde U); the coiled red chain mass round
  the neck like a scarf trailing off one shoulder; the robe torn open, a black tattoo down the sternum and ribs [A].
- `Ep411BloodChainsIchigo` (`_sheets/cBC.png`): full figure: blade low in the **right** hand, point near the floor ahead;
  long black robe to the shins with **white lapel edges** running down the open front; sleeves wide to the wrist, ragged;
  bare feet; red chains coiling at both wrists and both ankles and at the neck; red eyes [A].
- `BloodChainsGetsugaTensho411.gif` 4.1–8.1 s: close-ups: angular white horns with a pink rim, a red eye, open roaring mouth;
  34.3–36.3 s: from behind, floating in the crescent's gap, the robe hanging, the chain scarf streaming from the neck, chains
  at both wrists, the blade low in the right hand [A].
- `ReiatsuClones.gif` 61.9–64.7 s: the clones are **grey-black smoky copies** of the full figure [A]. Wiki: "his black
  Reiatsu taking his form" [A].
- Brave Souls: "Ichigo Kurosaki (TYBW 2026 Version)" is this form (special move listed as "Getsugatensho") [B].
- Ep412: Yhwach says "that version of the future never existed"; the manga timeline (the Bankai broken at once) resumes [A].

### Model checklist (KESSA)
- Two horns: from each temple **out ~0.08 m, then up ~0.2 m**, squared bends, flat-sided, bone white with a dark keyline.
- Skin: a deep-red cast (anime); robe black, open from collar to navel with white lapel edges, wide ragged sleeves, a
  shin-length ragged hem; a black tattoo on the sternum and ribs; bare feet.
- Chains: five glowing BLOOD sources: a coiled mass at the neck trailing one end, coils at both wrists, both ankles.
- Blade: right hand; long, thick, slightly tapered silver-white slab, square sheared tip, a black fuller from the grip
  through most of the length, a white grip with a lumpy melted texture, **no guard**, a long red tassel from the pommel.

### Conflicts (KESSA vs the repo)
| Item | Canon (Ep411) | Repo / the user's choice | Note |
|---|---|---|---|
| Horns | out then straight up, angular [A] | "two flat white horns … flat sideways" [U, v2 decision 6] | user's call; canon differs |
| Hair split black on the left | not seen (stills too red to judge) | [U, decision 6] | user's; unverified |
| Left half of the face black | "a thicker tattoo" (stripes) [A] | a black half-face mask [U] | user's; canon is stripes |
| Chest emblem | black tattoo down the sternum [A] | a dark red disc + black lines [U] | user's |
| Skin | "darkens to a deep red" [A, anime] | normal skin | not built; a tint knob [D] |
| Robe | long ragged robe open in the middle, white lapel edges, wide sleeves [A] | kosode open to the navel, sleeves cut past the elbow, torn cuff [U/build] | near enough; sleeves longer in canon |
| Blade | silver-white, black fuller, sheared tip, melted white grip, red tassel [A] | white slab, jagged black line, square end with a 45° notch, white diamond-wrapped hilt [U, v2 "the figures"] | matches in spirit; tassel missing |
| Chains | glowing red at neck, wrists, ankles; from the tassel [A] | dark maroon coils with BLOOD glints [U/build] | fine; canon glows brighter |
| Barefoot | yes [A] | yes | match |
| Black flame footprints | yes [A] | none | optional fx [D] |

---

## 6. Gaps (looks)
- **Manga black-and-white pages** for ch. 582–591 and 673–684 were not read; only the wiki's colour panels. The exact
  scale-panel count and the X straps' width come from colour panels and RoS art.
- **Ep411 at full resolution in neutral light**: KESSA's albedo (skin red, hair) is hidden by the red grade; the GIFs are
  190×108. Close: the official 血鎖 key visual (bleach-anime.com, 2026-08-22) or the Brave Souls 2026 art.
- **RoS half-Hollow and Cero Creciente art**: not on the official page; the game's in-motion model needs a video.
- The short blade's exact sheath and how the right-hip plate holds it: seen only at small size.

## 7. Image table (`.refs/ichigo/`, git-ignored, never commit)

Wiki URLs in `.refs/ichigo/_urls.tsv` (`https://static.wikia.nocookie.net/bleach/images/…?path-prefix=en&format=original`).
Local names replace spaces, `'` and `,` with `_` and drop macrons. Contact sheets: `.refs/ichigo/_sheets/`.

| File | What it shows | Status |
|---|---|---|
| `542Ichigo_s_Shikai__Zangetsu.png` | reforging panel: long blade right hand, short blade hanging left, loop handle | used (grip) |
| `Ep379IchigoShikaiZangetsu.png` | anime ep. 13, same pose | used |
| `ros_tybw_img_ill.webp` | RoS official art: both blades, forward grips, X outfit, pauldron, cloak | used (main look ref) |
| `582Ichigo_s_new_outfit.png` | X outfit, pauldron, wristbands, blade carry | used |
| `555Ichigo_s_Oken_clothing.png`, `Ep385IchigoOkenClothing.png`, `Ep385IchigoRushesDown.png` | Ōken cape outfit | used (dropped for the model) |
| `Ep394IchigoPreparesFight.png` | X guard, both forward grips | used |
| `Ep394YhwachEvadesIchigo.png` | flying lunge, cloak streaming | used |
| `Ep396IchigoSlashesArrow.png` | follow-through, sleeves, hip sheath | used |
| `675Ichigo_s_Half-Hollowfication.png`, `Ep410IchigoRevealsControl.png`, `Ep410IchigoMovesForward.png` | half-Hollow horn, stripes, white blade | used |
| `Ep409IchigoHalfHollowfication.png` | half-Hollow, dark | dropped (too dark) |
| `678…Tensa_Zangetsu.png`, `684True_Tensa_Zangetsu.png`, `681Tensa_Zangetsu_is_repaired.png`, `Ep414IchigoBankaiTrueTensaZangetsu.png`, `Ep414TrueTensaZangetsuB.png`, `Ep412IchigoBankaiBroken.png` | true Bankai | used |
| `Ep411BloodChainsIchigo.png`, `Ep411IchigoActivatesBloodChains.png` | KESSA full figure, horns silhouette | used |
| `Ep411IchigoChainsDeflectBeams.png`, `Ep411IchigoGeneratesClones.png`, `Ep411ClonesAttackYhwach.png`, `Ep411GetsugaTensho.png` | chains wall, clones, black crescent | used |
| `BloodChains.gif`, `BloodChainsGetsugaTensho411.gif`, `ReiatsuClones.gif` | KESSA clips | used (low res) |
| `ros_tybw_img_cut-in.png`, `ros_tybw_thumb_trailer.jpg` | RoS cut-in / trailer thumb | not looked at closely |
| other `Ep387*`, `Ep396*`, `Ep406*`, `Ep408*`–`Ep414*`, manga `583`–`684` stills | motion refs | see `canon-motion.md` |

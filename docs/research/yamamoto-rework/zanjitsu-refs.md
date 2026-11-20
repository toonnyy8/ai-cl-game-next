# Zanjitsu Gokui (殘日獄衣): the look references (2026-11-20)

The user, 2026-11-20 (with a fan illustration attached): 「殘日獄衣的造型應該是像附圖這樣，請你在做造型前先搜尋範例圖」.
Images go to the git-ignored `.refs/yamamoto-zanjitsu/` (fetched from the Bleach Fandom wiki's file pages through its MediaWiki API).
Grades as `canon-looks.md`: A canon still, B official game, C secondary, D inference. The earlier notes on West are
`canon-looks.md` §4.3; this file replaces their "tongues from the feet + two wings" reading with the whole-body mantle below.

| File | Source | What it shows | Grade |
|---|---|---|---|
| `user-ref-zanka-flame-cloak.webp` | the user's attachment (a fan illustration, "Zanka no Tachi / Longsword of the Remnant Flame") | the target look (below) | the user's decision |
| `508Yamamoto_in_flames.png` | manga ch. 508, colour | the same silhouette, orange | A |
| `507Zanka_no_Tachi__West_-_Zanjitsu_Gokui.png` | manga ch. 507, colour | close: the flame wraps him like a cloth from the feet up, his head and beard inside it | A |
| `Ep372ZankaNoTachiNishiZanjitsuGokui.png`, `ZankaNoTachiNishiZanjitsuGokui*.gif` | anime ep. 372 (TYBW ep. 6) | billowing yellow-orange cloud flames, his body a dark shape inside, the blade low at his right | A (anime) |
| `509…Kita`, `Ep372…Kita` | ch. 509 / ep. 372 | 北: him wrapped in West's flames inside the white band | A |

## What makes it read (the user's image and ch. 508 agree)

1. **One closed mantle, not separate tongues.** The flame is a single silhouette that wraps the whole body from the ankles up. Only
   the feet (sandals) show below it, and the face and beard show in an opening near the top. Inside it are darker holes and
   flame-shaped marks (A, ch. 508; the user's image).
2. **The silhouette: narrow at the feet, flaring up.** It is about body-wide at the shins, widens through the hips, and at the
   shoulders throws **two great wings sideways**, each roughly 1.5-2x his height in span from the centre. The wings are made of
   several lobes whose tips **curl upward** like flame tongues or antlers. Lobes **rise above his head** to about 1.3-1.5x his height
   (A ch. 508; the user's image).
3. **The lower hem** breaks into a few lobes curling out and up at knee height (the user's image; ch. 508).
4. **Colour.**
   - The user's image: a **yellow-white glowing body** with a **white rim light** and **red-orange flame marks** inside, sparks round
     it, on a dark ground.
   - Manga ch. 508: orange with pale streaks.
   - The anime: yellow-orange.
   - The user picked the yellow-white version.
5. **The blade stays outside the mantle**, held in the right hand. The user's image holds it level across the front; ch. 508 holds it
   low and point-down at his right (A).
6. **Motion** (anime, A): the lobes billow and lick upward continuously; embers drift off.

## Against the current build (art K2 / K4, `yama-look.lisp` L8, `%st-flare`)

- Today 西 draws ten separate orange tongues from the feet, two small three-ribbon wings, and a molten ring. The stance version
  reaches the knee; the flare version reaches about 1.3 m.
  - No closed mantle;
  - the body reads as a black figure standing in fire;
  - the size is about a third of the reference.
- The reference is a large, bright, mostly opaque shape. From the match's behind camera it would cover the opponent. This is
  `procedural-ink-style`'s "big foreground parts that hide the fight" mistake, so the in-play size, or the opacity from behind, is a
  decision for the user.

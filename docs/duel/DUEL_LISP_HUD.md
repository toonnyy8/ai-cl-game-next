# DUEL_LISP_HUD — the HTML HUD and menus redrawn by Lisp (design, 2026-11-10)

Status: **phase 0 (the spike) built and measured, 2026-11-10 (§8); phase 1 built in three parallel worktrees and merged, 2026-11-11: 1a the full bake (§9), 1b the paint stream's shapes (§10), 1c text layout, tweens, layout, input and the small-text weight (§11), the merge and its cross-phase fixes (§12); phase 2, the handheld portrait battle screen, built 2026-11-11 (§13); phases 3-4, the landscape battle screen and the overlays (pause, intro, READY / 斬, finish), built 2026-11-11 (§14): under `:lisp` nothing of the canvas HUD draws in a battle**; phases 5-6, the menus, built 2026-11-11 (§15); accepted 2026-11-11: **the Lisp renderer is the only one, the HTML UI is removed (§16; the user: 「將 lisp 版設為預設並移除 html」), and the old canvas HUD with it (「舊的 Canvas HUD 也移除」, §16.6)**. The source of the look is the HTML UI as it stands at main 5c212105
(`duel/web/hud.js`, `hud.css`, `menu.js`, `menu.css`, removed 2026-11-11 (§16): `git show 562acb37:duel/web/…`; its record is DUEL_WEBUI). Background: DUEL_WEBUI §18,
docs/engine/REFACTOR_2026-11.md §6 D4 and §10, DEVLOG §448, §458, §704, §705.

## 1. The requests and the fidelity bar

The user, 2026-11-10, verbatim:

- 「等等完成一個段落後先暫停，我希望使用 lisp 完全重現目前的 html HUD」
- On text, of the four ways offered (DUEL_WEBUI §18 A3): 「我選 3，說明手冊保留在 html 頁面」. Option 3 is an offline-baked SDF
  atlas: the build scans the characters actually used, bakes a distance-field texture and its metrics, and an SDF shader draws
  it. manual.html stays an HTML page.
- Asked whether the HTML HUD stays side by side until the Lisp HUD is accepted: 「並存」.
- On fidelity and method: 「不用到 100% 完全相同，但要還原大多數的美術風格與動畫。請根據程式的實作判斷該如何移植。」

"Reproduce most of the art style and animation" is taken to mean the following bar. Review is by the user's eye on
side-by-side stills and in play (§5.3), not by a pixel gate.

**Must match**

- Every screen and element of §2: present, showing the same data, in the same place. Positions within about 1 `u` (the HUD's
  unit, §4.2) or 2 % of the viewport. The same layout variants: desktop, phone portrait with and without the deck, the
  left-hand mirror, the narrow-window menus (≤ 760 CSS px), the short-window menus (≤ 560 px tall).
- The palette: the `:root` tokens exactly (ink #0b0b10, night #161922, slate #2c303d, stone #767d8e, steel #bcc1cc, paper
  #eeeeea, blood #e81e3a, reiatsu #ffd83a; and the literal colours in the CSS), the same alphas.
- The typefaces' character: the condensed display face for Latin headings and numbers, the Mincho for kanji, the sans for zh
  body text, the mono for labels. Also the weights' contrast, upper case, letter spacing, vertical columns (`writing-mode:
  vertical-rl`), outlined text (the title's DUEL), the hard drop shadows.
- The visual devices, by an equivalent (§2.4): torn and cut paper (clip-path polygons), the brush stroke behind a focused
  row, the blood slash under the combo count, the screentone dots, the radial ink washes, the hanko seals, the soul flames,
  the rings.
- Every named animation of §2.5: the same property, trigger, delay and duration, and the same easing curve (the three
  cubic-béziers and `steps(1)`), within one frame.

**May differ**

- Glyph rasterisation: sub-pixel antialiasing, hinting, kerning pairs (advances only), the exact stroke weight between
  baked weights (an SDF edge shift stands in, §4.1).
- Line-break points in zh paragraphs (±1 character); `text-overflow: ellipsis` may become a hard cut.
- Noise-made shapes: the torn edge (feTurbulence + feDisplacementMap), the dry brush, the paper grain become a fixed
  hash jitter; their exact contour differs.
- Blur kernels (`filter: blur`, `drop-shadow`, `box-shadow` blur) become SDF softness or feathered shapes; the falloff
  differs.
- Hover cursors, focus rings, selection: none (nothing is selectable).

## 2. Inventory of the HTML UI (from the code)

Files: hud.js 399 lines, hud.css 480, menu.js 378, menu.css 389 (1,646 in all). Sizes in `u` are the battle unit, `--u:
min(1vw, 1.7778vh)`, phone portrait (`hphone`, innerHeight > innerWidth) `2.36vw`: 12.8 CSS px at 1280×720, 19.2 at
1920×1080, 9.2 at 390×844. Menu sizes are CSS px, `clamp()` or vw / vh. Keys are the page protocol of DUEL_WEBUI §3
(30000 + k: `V[k]` in menu.js) and §7.2 (30100 + k: `V[k]`, strings `S[k - 120]` in hud.js); side `s` offset `o = 50 + 30s`.

### 2.1 Battle (hud.js, hud.css; `#hud`, z 2, `contain: strict`, pointer-events none but the pause rows)

| Element | Data | Layout that matters | Type | Devices | Animations |
|---|---|---|---|---|---|
| Layer state | V0 bits 1 battle, 2 cine, 4 paused, 8 deck, 16 practice, 32 page cine, 64 rotate; V42 left hand | `.hudl` z 10; `hphone`, `left-hand`, `nodeck` classes | | canvas `filter: grayscale(.9) brightness(.45) contrast(1.1)` when paused | `.hudl` opacity .3 s (cine 0, paused .3); canvas filter .5 s ease-out |
| Plate ×2 (P2 mirrored, P1 mirrored with the left hand on the phone) | V o+0 roster, S 4s label (form after two spaces), S 4s+1 tag | top `max(2.4u, st + 1u)`, left / right `max(2.6u, sl / sr + 1u)`, width 36u (phone 30u, P2 27u with the deck), grid gap .55u | name 900 2.3u display upper, .06em, shadow 0 2px; kanji 800 1.25u Mincho steel .15em; tag 600 .72u mono stone .16em, ellipsis | phone: radial ink pool behind (`::before`, farthest-side at 35 % / 65 %) | |
| Reishi bar | V o+1 ‰, o+2 red | height 1.55u (phone 1.3u), flex 1 | | clip-path polygon (cut square inside, torn outside); fill gradient #fff → paper 45 % → #c9cbcf; grid `repeating-linear-gradient` 9 / 10 / 23 px at .35; inset 1 px outline; P2 `scaleX(-1)` | ghost (blood) `transform` .55 s delay .38 s ease-cut on a drop, snaps on a refill; fill `clip-path` .12 s ease-out; red: blood gradient + `hd-pulse` 1.1 s brightness 1.35 infinite |
| Soul flames ×9 | V o+3 Konpaku, o+4 at stake | flex gap .38u; 1.05 × 1.45u each | | SVG path (flame), paper fill, ink stroke 1.2; at stake blood stroke 2.4; gone: grey dot r .19u | `hd-flame` 1.6 / 1.9 / 1.35 s (by nth-child, delays −.7 / −1.1 s) scaleY + skewX; `hd-stake` 1.4 s bob while red; `hd-shatter` .5 s scale 1.8 rot 12° + blood glow on loss; gone: opacity .3 s delay .15 s, dot .3 s delay .3 s |
| Kit strip (Kenpachi: NOME / UDE / KAIHO) | S 4s+1 kind, V o+15 value, o+16 max, o+20 cup rung, o+21 crack clock ‰ | beside the souls; phone: under the bar, half its width | kanji 800 1.15u; value 600 .8u mono | NOME: three SVG cups on a bar + ticks; UDE: four skewed pips (clip-path) with a crack line; KAIHO three pips + MAX | cup fill / stroke .25 s; bar width .15 s ease-out; `near` pulse .7 s; pips .25 s; crack clock width .2 s linear; hurry pulse .45 s; MAX pulse .8 s |
| Flash step + awakening | V o+6 ‰ (3 cells), o+7 ‰, o+8 ready, o+22 sublimation ‰, o+23 mode | grid 3fr 2fr, width 64 %, height .42u | label 800 .8u display .2em | cells steel on #2c303d; awakening reiatsu; sublimation pink over it; drive red | cell scale .25 s ease-out; bar .4 s ease-out; full: `hd-aw` 1 s brightness 1.5 + glow; label opacity .3 s |
| Pointer seals (desktop) | V o+9 pointer, o+24 locks, seals by form (FIGHTERS table) | flex gap .35u, 1.75u squares (phone 2.2u) | 800 1.05u Mincho; name 600 .7u mono | 1 px border; on: paper fill, rot −4° scale 1.08; lock: dashed, .35 | `all .25s ease-out` |
| Clock | V1 seconds (−1 none), practice ∞ | top centre `max(1.6u, st + .6u)`; phone top-left 2.4u; with the deck a 札 tab 10.4 × 8.4u on Lisp's pause chip (V39 / V40) | digits 800 4.3u display tabular, shadow 0 3px; caption 600 .62u mono .3em | tab: clip-path cut corner, inset outline, II 止 PAUSE; ∞ as an SVG stroke | last 10 s blood + `hd-tick` 1 s steps(1); ∞ `hd-write` .9 s ease-cut stroke-dashoffset |
| Combo ×2 (under the attacker's plate) | V o+10 hits, o+11 dmg, o+12 scale ‰, o+13 serial | top 16.4u + st (phone over the deck, see css 259-277) | count 900 italic 6.2u display, blood shadow .25u; HITS 800 1.5u; detail 600 .95u mono | blood skewed slash (clip-path) behind the count | on: opacity .25 s + translateX .35 s ease-out, 1.2 s then off (wall clock); each hit `hd-stamp` .24 s ease-snap scale 1.5 rot −6° |
| Callout ×2 (move name) | V o+14 serial, S 4s+2 romaji (kanji from the MOVES table) | top 13.6u + st | kanji 800 1.9u Mincho; romaji 700 .95u display .28em (romaji-only 1.5u paper) | | `hd-cut` .32 s ease-out clip reveal left → right; off after 1.5 s (opacity .2 s) |
| Prompt | V2 kind, V3 arg, S 8 keys, S 9 AS romaji | bottom 5.5u centre; phone right over the deck | 800 1.3u display .24em; sub 600 .65u mono; key cap 600 .95u mono | key cap: border + 3 px bottom, radius 3; ring (SVG circles) with 毀 | opacity .2 s + translateY .3 s ease-out; Kikon hold: `hd-ring` linear over `--hold` (frames / 60 s) |
| Deck (phone) | V30-33 rect ‰, V34 / V35 line ends, V43 pad top | absolute from Lisp's numbers; z 9 | SP 技 / ATK 斬 labels 800 1.6u display .3em, alpha .42 | paper gradient to the pad top, 7 px dot screen at .5; two clip-path zones split by the slanted line | opacity .3 s; zone lit .2 s |
| P1 plate on the line (phone, draft C 界) | as the plate + V36-41 | rotated to the line (`rotate`, transform-origin), grid areas "s w" / "b b" | name 1.75u | | |
| 爆 seal (phone) | V4 bits (ready, holding, pressed, can, burst mode), V56 flash step ‰, V36-38 centre / radius | circle at Lisp's chip 7 | 爆 800 2.2u Mincho, RV 600 .85u mono | the ink level: a second face clipped (`clip-path inset`) inside a grey / paper / mode-colour level; ticks at 1/3 and 2/3 (gradient gap); awakening ring (SVG arcs, dasharray) + sublimation ring + hold ring; 覺 tab | level height .45 s ease-out; `hd-arm` .42 s ease-snap; `hd-deny` .3 s shake; `hd-dip` .32 s; `hd-awbreath` 1.6 s drop-shadow; `hd-awfill` .3 s linear; `hd-kak` .34 s ease-snap; pressed scale .9 .15 s ease-snap |
| Stance seals (phone) | V o+9, seals | four seals on a 6.2u circle around 爆 at 304 / 270 / 236 / 202° (mirrored by hand) | as the seals, name .78u | | as the seals; opacity .3 s |
| Touch ink (phone) | V5 serial, V6 kind, V7-10 place / stroke, V11-13 hold ring | `.fx` z 15 | gesture word 900 2.4u display .2em, ink shadow | ripple ring 16u border 2 px; trail gradient + rounded end, rotated; hold ring SVG | `hd-ink` .5 s, `hd-trail` .45 s (clip reveal then fade), `hd-gname` .6 s rise and fade, `hd-ring` .6 s; DOM nodes removed after 0.6-0.9 s |
| Pause | V17 cursor, V18 count, V19 serial, S 10-29 rows ("EN  value"), V0 bit 64 | grid `auto 1fr`, padding 8u; phone one column | 止 800 13u Mincho vertical (phone 10u horizontal), shadow 0 6px; rows: no 600 .75u mono, en 900 2.1u display, zh 500 .95u sans (PAUSE table), val 600 .8u mono boxed | 止's blood blot (12-point clip-path star); the paper strip (clip-path quad, rot −1.2°); row rules | `hd-strip` .42 s ease-out clip reveal; cur row blood + translateX .6u .2 s; phone `hd-fromtab` .42 s (止 grows out of the clock tab) |
| Intro card | V14 phase, S 30 / 31 reading and line, names (FIGHTERS full / CRY tables) | letterbox 9 % ×2; name column right / left 8 %; VS bar bottom-left | full name 800 7.2u Mincho vertical, shadow 0 6px; reading 800 1.5u display .5em vertical; line 600 .9u mono; VS names 900 1.9u, `vs` 900 italic 3.4u blood | blood line between | letterbox scaleY .5 s ease-cut; `hd-brush` 1.1 s delay .2 s (clip reveal top → bottom); `hd-fade` .6 s delay 1.1 s; VS `hd-fade` .5 s delay 1.5 s |
| READY / 斬 | V14 = 3 / 4 | centre | READY 900 9u display .12em; 斬 800 15u Mincho; shadow 0 6px | slash line 3 px rot −8° | `hd-ready` .9 s (READY .7 s): scale 1.7 + blur 6 px in, hold, out to .94; `hd-slash` .5 s ease-cut |
| Finish | V15 kind, V16 winner, V o+3 / o+17 / o+18 | 決着 right 9 % top 10 % vertical; splat; K.O. vertical; winner bottom-left | 決着 800 10.5u Mincho; K.O. 600 1.1u mono .6em; winner 900 4.6u display; line 500 1u sans + 600 mono numbers | bottom gradient 42 % to ink .82; blood splat (14-point clip-path) | `hd-brush` .7 s delay .15 s; `hd-splat` .35 s delay .55 s ease-snap; `hd-fade` .4 s delay .9 s; `hd-rise` .6 s delay 1.2 s |

### 2.2 Menus (menu.js, menu.css; `#ui-back` under the canvas, `#ui` over it)

| Screen / element | Data | Layout that matters | Type | Devices | Animations |
|---|---|---|---|---|---|
| Backdrop | V0 screen | `#ui-back .world` (SELECT only, under the canvas); `#ui .wash` over the scene elsewhere | | radial gradients; 7 px screentone with a 170° mask fade; paper grain (feTurbulence data URL, .07) | |
| Ash (title) | | full screen canvas 2D | | 30 / 60 particles, 6 % blood | per frame on rAF wall clock: rise, sway, wrap (Math.random) |
| Rails | screen crumb, input kind (keys / pad / touch) | top and bottom, gutter `max(16px, safe)` + 8, safe top / bottom + 14 | mark 800 15px display .18em; crumb 400 10px mono + 800 13px kanji; hints 400 10px mono, key caps 600 10px mono | blood tick rot −24°; caps border + 2 px bottom | hint opacity .3 s |
| Screen cut | screen change | full screen, z 20 | | ink polygon wipe + a blood diagonal line | WAAPI: line dashoffset 300 ms `cubic-bezier(.7,0,.2,1)`; ink clip-path polygon 380 ms `cubic-bezier(.16,1,.3,1)` (keyframe at .55) |
| TITLE | V11 ready, input kind | grid `1fr auto`, bottom-aligned | wordmark 900 `clamp(84px, 17vw, 268px)` / .76 (phone 31vw), DUEL outlined 2 px; NEXT 900 .26em blood .5em; sub 500 13px sans; PRESS 800 22px display .3em; 魂 800 `clamp(180px, 46vh, 520px)` Mincho; vertical line 600 13px Mincho .6em | slash (blood, clip-path, rot −5°); 魂 filled with a 6 px dot halftone (`background-clip: text`); PRESS frame skewed −12° | `rise` .9 s ease-out (SOUL, DUEL +.12 s, NEXT +.24 s) clip reveal + translateY; `slash` .46 s delay .5 s ease-cut; dot `pulse` 2.4 s; press frame hover .2 s; rows gated by V11 (opacity .35 s) |
| MODE | V1 cursor; MODES table (7 rows) | grid 1.05fr 1fr, gap 4vw | rows 800 `clamp(30px, 4.4vw, 54px)` display, zh 500 12px .24em; m-kanji 800 `clamp(96px, 22vh, 230px)` vertical; card: eyebrow 10px mono, h2 800 `clamp(26px, 3vw, 38px)`, p 400 15px / 1.75 sans 34ch, tags 10px mono boxed | row brush (SVG symbol, #dry displacement, paper gradient tail), red seal box (rot −6°, inset highlight); paper card with torn edge (#torn) and 5 px dot texture | brush scaleX .34 s ease-out; seal scale + rot .3 s delay .08 s; `stamp` .42 s; m-kanji `inkin` .42 s (blur 8 px, −14 px); color .18 s |
| SETTINGS | V1 cursor, V40-46 options, V41 hand (menus swap side on a phone) | grid 1fr 1.25fr, gap 5vw | h1 900 `clamp(56px, 9vw, 140px)`; 設定 800 `clamp(28px, 4vw, 52px)` blood; p 400 14px; rows 800 22px; options 800 15px; help 400 12px | focus bar 3 px blood; focus gradient wash; options with a skewed paper slab; volume / sensitivity drops (rounded, rising heights) | bar scaleY .3 s; slab scaleX .3 s ease-out; help max-height .4 s; arrows opacity .2 s; drops .25 s |
| CONTROLS | V9 column (+10 capturing), V10 phone page, V50-57 bindings | the same split | tabs 800 18px; key map SVG (31 caps + space + labels) 600 13px mono; binds 700 15px display + small 400 11px sans; combos 400 12px | caps hot = paper, mod = blood stroke; capture cap blood | capture `pulse` 1 s |
| CONTROLS (phone gestures) | V10 = 1 | the PHONE_SVG card (560 × 330 viewBox) | 22px display, 12px mono, 11px sans | dashed zones, thumb circle + arrow | `thumb` 4.8 s ease-cut infinite (rise 46 px and fade) |
| SELECT (two copies: back = fills + emblems, front = text) | V2 phase, V3 / V4 picks, V5 difficulty, V6 mode, V7 camera, V8 rows; sends the model spot (get 30002 / 30003) | rows `auto 1fr auto`; three cards `flex 1` → focused 2.6 (phone: stacked, 4) | h2 800 `clamp(30px, 4vw, 48px)`; slots 800 20px; card name 900 `clamp(34px, 4.6vw, 70px)`, jp 600 13px Mincho .3em, tagline 400 14px / 1.7 sans 42ch; pointers: n 600 10px mono blood, th 800 15px, zh 400 11px; emblem 800 `clamp(160px, 40vh, 420px)` Mincho; options 800 18px | card dots with a gradient mask; emblem slate; pick seal (blood, rot); skewed paper option slab | flex-grow .6 s ease-out; emblem colour .5 s, translateX .7 s ease-out; more max-height .6 s, opacity .4 s delay .1 s; pick `stamp` .45 s; slot border .3 s; rows opacity .3 s |
| RESULTS | V20 winner, V21 seconds, V22-31 stats, V11 ready | grid 1.2fr 1fr | who 400 11px mono; name 900 `clamp(70px, 12vw, 190px)`; over 400 13px mono; stats 800 34px display tabular + 12px mono | 勝 hanko with a torn 6 px border (#torn); soul eggs; stat grid with 1 px rules | `hanko` .6 s delay .3 s ease-out (scale 2.4 rot −26° in); menu gated 2.5 s (opacity .35 s) |
| Toast | (none in use) | | | | |

Counts: about 35 battle element kinds and 45 menu element kinds (about 80). Animations: 27 `@keyframes` in hud.css, 9 in
menu.css (2 of them, `inL` / `inR`, belong to the dropped VS screen), 2 WAAPI animations (the cut), the title's ash, and about
54 `transition` declarations. `prefers-reduced-motion` cuts every animation in both sheets.

### 2.3 Behaviour carried by the JS, not the CSS

- Change detection by serials: the combo (o+13), the callout (o+14), the touch event (V5), the pause rows (V19). The page
  reacts once per new serial and runs its own timers (combo 1.2 s, callout 1.5 s) on `performance.now()`.
- Tables that turn ASCII into kanji (`page-set-str` sends ASCII only; any other character becomes `?`, platform.lisp
  `page-set-str`): FIGHTERS (names, seals by form), CRY, MOVES (37 romaji → kanji), PAUSE (16 rows → zh), the tag
  rewrites (風死 · in hand, 分身 · ×n). The menus' MODES, FIGHTERS cards, SETTINGS help, BINDS, KEYS / PADS names, RMENU,
  SCREENS live only in menu.js.
- The 爆 seal's own rules: arm on reaching 2/3, slosh on a Hoho drop, deny shake and NO BURST on an early press, the
  awakening word on a held release (hud.js `renderDeck`).
- Pointer: hover moves the cursor (mouse only), click confirms, touch picks; SELECT measures the focused card's model spot
  every frame and Lisp reads it.

### 2.4 CSS features without a cheap equivalent, and what the Lisp version does instead

None of `backdrop-filter`, `mix-blend-mode` is used. The rest:

| Feature (count) | Where | Lisp equivalent |
|---|---|---|
| `filter: url(#torn)`, `#dry` (feTurbulence + feDisplacementMap) | the paper card, the hanko border, the row brush | edges as polygons jittered by a fixed hash once per box size (cached); the brush as a baked polygon with a tapered tail and two streaks |
| feTurbulence paper grain (data URL, .07) | SELECT's world | a hash-noise term in the shader (paint mode flag, §4.1), or dropped (it is 7 % alpha) |
| `filter: blur()` (2) | READY's entry, MODE's kanji swap | SDF softness: the glyph's edge width widened over the animation |
| `drop-shadow` / `box-shadow` blur (≈ 10) | cup glow, awakening glow and breath, armed / ready seal glow, ∞ shadow | a feathered shape (rounded box / ring with a wide feather) under the element; for text, the SDF's outer band |
| `text-shadow` (10, all hard offsets but the gname's) | names, digits, big kanji | the glyph run drawn again offset in the shadow colour (no blur needed) |
| `-webkit-text-stroke` | the title's DUEL | SDF outline band (edge ± width) |
| `background-clip: text` with a dot pattern | 魂 on TITLE | SDF glyph × halftone pattern (shader flag) |
| `mask-image` gradients (6) | screentone fades | vertex alpha gradient on the pattern quad |
| `radial-gradient` (10) | washes, ink pools, the world | a triangle fan with ring stops (vertex colours) |
| `repeating-linear-gradient` | the Reishi grid | thin quads at fixed x (they do not move with the fill: DEVLOG §618) |
| `clip-path` polygon, static (≈ 15) | bar ends, pips, slash, tab, strip, stars | polygons with a 1 px antialiased fringe |
| `clip-path` animated inset / polygon (≈ 10) | callout, brush reveal, title rise, strip, trail, Reishi fill, 爆's ink | a clip rectangle in the element's local frame, applied to quads on the CPU (uv adjusted) |
| `writing-mode: vertical-rl` (8) | big kanji columns, intro, finish | a vertical layout run (upright CJK, per-glyph vertical advance) |
| SVG circles with `stroke-dasharray` | rings, arcs | analytic arc (shader) or `%arc`-style segments |
| SVG paths | flame, cup, ∞, brush | paths flattened once at init to point lists; strokes with a drawn fraction for the dashoffset tweens |
| canvas `filter` (pause) | the scene | `*grade-desat*` 0.9 plus an ink rect of about .55 |
| flex-grow transitions | SELECT's cards | the weights tweened, the split recomputed |
| `max-height` transitions | help lines, card details | a tweened clip height |

## 3. What the engine has and lacks (verified)

**Has**

- A textured-quad path. `ui-init` makes the RP_UI pipeline over a 96×48 R8 font atlas (engine/lisp/ui.lisp:49-55);
  `r_font_new` uploads it once (engine/c/render.c:155-159, `r_upload` is setup-time only, render.c:100-119). The whole UI is
  one draw call in the swapchain pass after the composite, with the font bound through the nearest sampler (render.c:290-297).
  The vertex is 8 floats, layout 0x224 (pos, uv, colour; ui.lisp:81-99); the shader multiplies the vertex colour by the atlas
  coverage, and a solid white cell gives flat colour (engine/shaders/ui.frag.wgsl). Capacity 32,768 vertices (render.c:21).
- A linear sampler exists (`r_linear`, render.c:125-128). `r_shader` counts samplers by the literal text `": sampler;"`
  (render.c:39): a new shader declares each sampler exactly so, and (the gotcha) no WGSL name may contain `sampler`, `read`
  or `write` (ui.frag.wgsl names it `smp`).
- `r_make_pipe` takes a vertex layout as hex digits, at most 4 attributes (render.c:49-58), and blend modes 0-3 (none,
  alpha, additive, alpha-to-coverage).
- ui.lisp's primitives: rects, gradients, bars, outlines, free quads (`%ui-poly4`), the 0 B macros `%hq` / `%hrect` /
  `%hbar`, `%ring` / `%arc` / `%disc` (24 segments, no antialiasing), the 5×7 bitmap font at integer scales (`ui-text`),
  block text and bitmaps as solid pixel quads. 0 B per frame comes from `with-ui-verts` in DEFUN-FAST code writing floats
  straight into the stream buffer (ui.lisp:81-99). `ui-scale` is an integer (1 per 360 px of height); `*ui-min-css*` floors it
  so a 7 px glyph is at least that many CSS px tall (ui.lisp:57-68). None of it suits continuous `u` sizes or CJK.
- The brush glyphs: Yuji Syuku outlines baked offline by tools/glyph-bake.py into duel/lisp/glyphs.lisp (+ glyphs-extra.lisp,
  ~360 KB of source together), ear-clipped at load (brush.lisp `brush-init`, a `:load` step) and drawn as UI triangles
  without antialiasing. They stay for the cinematics' captions.
- Window size in device pixels (`pf_width` = `SDL_GetWindowSizeInPixels`, platform.c:64, 134) and `pixel-density`; the
  safe-area insets top and bottom in CSS px (`*safe-top*` / `*safe-bot*`, page get 3 / 4, pwa.js:51-63).
- Lisp owns keys, pads and touch: the touch recogniser (engine/lisp/touch.lisp) has taps with their position
  (`touch-tapped-p`, `touch-tap-x/-y`), chips, gestures and their events (`touch-glyph`, `-t`, `-x`, `-y`, the stroke `fx`
  / `fy`, the stick origin `ox` / `oy`); the canvas menus already hit-test taps against row boxes noted while drawing
  (onehand.lisp `note-menu-row` / `tapped-row`).
- The HUD model: webhud.lisp and webui.lisp already compute every number and string the HTML draws, into `*hud-sent*`
  (200 fixnums), `*hud-strs*` (64 strings) and `*ui-sent*` (64 fixnums), each frame, 0 B.
- `*render-transparent*` and RP_COMP_A (the scene's alpha out, DUEL_WEBUI §4) for SELECT.

**Lacks**

- An SDF text path: an atlas texture with a linear sampler, a shader that turns distance into coverage, glyph metrics,
  layout (measure, CJK wrap, vertical runs), a run cache.
- Antialiased shapes: every edge in the UI batch is aliased (no MSAA in the swapchain pass). The HTML's rounded seals,
  rings, slanted bars and glows need either a feather fringe or analytic shapes.
- Fills by pattern: a 7 px screentone over a 1280×720 screen is about 19,000 dots, about 113,000 vertices as quads, three
  times the batch. Patterns, grain and radial fades must be computed in the fragment shader.
- A layer under the scene: `#ui-back` (SELECT's card fills and emblems) is drawn under the canvas; the engine's UI is only
  drawn after the composite.
- A tween / keyframe facility. `fx-envelope` (engine/lisp/fx-shapes.lisp:47-71) is a fixed VFX shape (anticipate, flash,
  grow, hold, out in 60 Hz frames, on the fx clock): it does not fit CSS keyframes and cubic-béziers, and its clock stops
  while paused.
- The absolute mouse position: platform.c accumulates only relative motion (`xrel` / `yrel`, platform.c:102-103), so desktop
  hover and click cannot be hit-tested.
- The left / right safe-area insets and `prefers-reduced-motion` (pwa.js answers neither).

**The canvas HUD**: hud.lisp, hud-screens.lisp and onehand.lisp's `hud-deck` / `hud-gestures` draw the old pre-HTML look (the
5×7 font, the old system's guard, Reiatsu and cooldown meters). As the look to port they are obsolete; as code, what carries over
is `%soul-flame` (hud.lisp:222), the engine's `%ring` / `%arc` / `%disc`, the `*timer-strings*` pattern (strings made once),
`%hround`, and the deck geometry Lisp already lays out (`deck-layout`, `*deck*`, `*deck-rect*`, `*deck-split-at*`).
`hud-world`, `hud-rush-lines`, `hud-hint` (drawn in the world) stay as they are.

## 4. Architecture

Engine modules that know no game (engine/lisp, engine/c, engine/shaders), and a game layer (duel/lisp) that ports hud.js
and menu.js on top of the existing model.

```
model (unchanged producers)        renderers (one at a time)
webhud.lisp  -> *hud-sent* / *hud-strs* --> :html   page-set / page-set-str -> hud.js, menu.js (today)
webui.lisp   -> *ui-sent*               \-> :lisp   lhud-*.lisp reads the same vectors -> engine paint stream
                                         \-> :canvas hud.lisp / hud-screens.lisp (no page: the native gate, an old page)
```

### 4.1 The paint stream (engine): one ordered stream for everything the new HUD draws

- **A second pipeline and stream, `RP_HUD` (slot 19) and `*hud-batch*`**, drawn after the existing UI in the same pass.
  Text, shapes and polygons all go into it, in paint order, so the HTML's interleaving holds: the slash under the combo
  count, a shadow under its text, text on the paper strip. The existing RP_UI stream and its callers are not touched.
  Reason: the looks gate cannot prove byte-identity today (REFACTOR_2026-11.md §10.2), so the old UI must stay unchanged by
  construction. The cost is one more draw call. (A mode lane in the existing 8-float vertex would also work, but it changes
  every existing UI vertex.)
- **Vertex: 16 floats** in four float4 attributes (layout 0x4444, inside `r_make_pipe`'s existing 4-attribute parse):
  position + uv, colour (sRGB, straight alpha), `p`, `q`. Capacity 32,768 vertices (2 MB of the transfer buffer; only the
  used part is copied).
- **Modes** (`p.x`), in one fragment shader:
  - 0 flat: the vertex colour. Polygons, vertex-colour gradients, radial fans.
  - 1 SDF glyph: uv into the atlas (linear sampler). `p.y` the edge (0.5 = the baked weight; lower = bolder: weights 500-900
    from one bake), `p.z` the softness (1 = a 1-pixel antialiased edge from `fwidth`; larger = the blur of READY and the
    MODE kanji), `p.w` an outline band width (0 = filled; > 0 = only the band: the outlined DUEL).
  - 2 rounded box: uv = local pixels from the centre, `p.yz` the half size, `p.w` the radius, `q.x` the feather (1 =
    antialiased edge; large = a box-shadow glow), `q.y` a border width (0 = filled).
  - 3 ellipse / ring / arc: uv local pixels, `p.yz` radii, `p.w` the inner radius (0 = disc), `q.x` feather, `q.y` the drawn
    fraction clockwise from the top (the SVG dasharray rings), `q.z` the direction (the left hand's mirror).
  - Pattern flags on any mode (`q.w`): 0 none; a positive value = a halftone dot pitch in CSS px times the density (dots on
    screen coordinates, `@builtin(position)`), multiplied into the coverage; a negative value = hash grain at that alpha.
    The vertex alpha carries the mask gradient.
- **Lisp emitters** (DEFUN-FAST / macros, 0 B, like `with-ui-verts`): `paint-rect` (2 or 4 corner colours), `paint-box`
  (rounded box), `paint-ellipse` / `paint-arc`, `paint-poly` (a convex or star-shaped polygon, fan from its centre, with an
  outward 1 px alpha fringe as ImGui does), `paint-stroke` (a polyline of a width with a drawn fraction, round or flat ends),
  `paint-radial` (fan with stops), glyph quads (4.2). Every emitter goes through a current 2D affine (translate, rotate,
  scale, origin; a fixed-depth stack in an f32vec), a current opacity, and a local clip rectangle that cuts axis-aligned quads
  on the CPU (uv cut with them). Rotated content is clipped in its local frame before the transform.
- **The back layer**: a third stream `*hud-back*` drawn into the swapchain before the composite when the frame is transparent;
  the composite then blends premultiplied-over (a blend mode 4 in `r_make_pipe`: one, one minus source alpha; the pass loads
  instead of clearing). Only SELECT uses it (its card fills and emblems behind the fighter, the cards' text in front). With
  the Lisp HUD the canvas needs no page behind it; the transparency is only for the sandwich.
- `r_frame` gains the two streams (four arguments); the atlas texture is bound for RP_HUD.

### 4.2 Text: an offline-baked SDF atlas

- **Single-channel SDF, two tiers.** Body glyphs at a 32 px em with a 4 px spread (a 40 px cell); display glyphs at a 96 px em
  (104 px cell) for the few that are drawn huge. Reason: the largest drawn sizes (below) magnify a 32 px bake 8-16×, where a
  single channel rounds Big Shoulders' square corners; MSDF keeps corners at 32 px but needs msdfgen (not installed; Python
  ports are slow and CJK outlines with overlaps give artefacts) and three channels (the same bytes as a 55 px single channel).
  Two tiers keep one simple shader and generator. The SDF also gives weight (edge shift), outline, glow and blur for free.

  | Largest drawn | CSS px at 1280×720 / 1920×1080 | Tier |
  |---|---|---|
  | TITLE 魂 `clamp(180px, 46vh, 520px)` | 331 / 497 | display |
  | wordmark SOUL DUEL `clamp(84px, 17vw, 268px)` | 218 / 268 (×2 on a 2× screen) | display |
  | emblems 剣 月 風 `clamp(160px, 40vh, 420px)` | 288 / 420 | display |
  | 斬 15u, 止 13u, 決着 10.5u, READY 9u, intro name 7.2u | 192, 166, 134, 115, 92 / ×1.5 | display |
  | combo 6.2u, clock 4.3u, results name `clamp(70px, 12vw, 190px)`, MODE kanji `clamp(96px, 22vh, 230px)` | 79-158 / 119-230 | display (digits, the shown kanji, the names) |
  | everything else | ≤ 70 | body |

- **Faces** (the page's, baked as subsets; one weight each, the others by edge shift):

  | Face | Used for | Baked set |
  |---|---|---|
  | Big Shoulders Display (900) | headings, names, numbers, rows | ASCII 32-126 |
  | Martian Mono (600) | labels, eyebrows, key caps | ASCII 32-126 |
  | Shippori Mincho B1 (800) | kanji: names, seals, emblems, crumbs, big columns, move names | the CJK and kana of strings marked `:kanji` |
  | Noto Sans TC (500) | zh body: help, descriptions, pause zh, taglines | every other CJK, kana, CJK punctuation, ASCII |

  A Latin face falls back to the sans for CJK, as the browser does (the mono eyebrow 「KONPAKU 魂魄」, the display 「覺醒
  READY」). Licences: all four are published under the SIL Open Font License 1.1 as far as known (**not verified here**: check
  each OFL.txt when the fonts are fetched); the baked subsets are a Modified Version as glyphs.lisp's are, each with its licence
  text in `duel/` (`FONT-LICENSE-<face>.txt`), no Reserved Font Name used.
- **The charset is closed and small.** Every non-ASCII character the HUD shows comes from tables (`page-set-str` carries ASCII
  only, so the CJK in today's HTML is all in hud.js / menu.js's tables): 383 distinct CJK characters (395 non-ASCII with the
  symbols · × – — → ⇧ ∞ ␣ ▶ ◀ ✚ ↺) in those two files, measured. The 943 that a scan of every Lisp string finds are mostly
  docstrings quoting the user. The tables move into one Lisp data file, `duel/lisp/lhud-data.lisp`, where each string carries its
  face (`(kj "更木剣八")`, `(zh "…")`; untagged = ASCII). The bake reads that file (and the `lhud-*.lisp` renderer files' string
  literals) and adds ASCII to every face. Dynamic strings are ASCII (callout romaji, kit labels, pause rows, key names, the
  intro's reading and line) or digits. Estimate: about 95 + 95 + 250 + 450 ≈ 900 body glyphs and about 80 display glyphs
  (wordmark letters, digits, K.O. / READY, the big kanji and the roster's names). DUEL_WEBUI §18's 1,500-glyph estimate
  shrinks accordingly.
- **Bake offline, check at build.** No font file is tracked (glyph-bake.py takes the font as an argument); the same here.
  `tools/sdf-bake.py FONTDIR` (the glyph-bake venv: fontTools, skia-pathops, plus numpy) reads each glyph's outline, removes
  overlaps (pathops), flattens it (glyph-bake's `Flatten`), and computes the exact signed distance to the segments on the cell
  grid (numpy; inside by winding), packs the cells (rows by height), and writes the committed output. The build does only the
  cheap part: a host test (`tests/duel-rules/lhud-charset.lisp`, phase 1a: §9) fails with "re-run tools/sdf-bake.py" when a string in the data or
  renderer files has a (face, char) the bake lacks. The atlas is therefore static: uploaded once in a `:load` step, never
  updated between frames.
- **Output form: a committed binary atlas, turned into a C array by the build.** `duel/hud-font/atlas.r8` (R8 texels) and
  `metrics.bin` (per glyph: code, face, tier, atlas rect, advance, bearings; int16) go into the MANIFEST; `build.sh` turns a
  listed `.bin` / `.r8` into `build/<t>/<name>.c` (`static const unsigned char[]`, a few lines of shell or Python, engine
  generic) for emcc. Reasons: the bytes live in wasm static data (no GC heap, no load-time consing: a Lisp literal of a
  megabyte would be read at load, and the 110 MB startup heap cap exists because of such load garbage, DEVLOG / ARCHITECTURE
  "Runtime model"); the repo keeps a 1-2 MB binary instead of a 5-8 MB generated C text with noisy diffs. A Lisp glyph table is
  built from `metrics.bin` at init (one FFI copy into a fixnum vector; lookup by binary search on face × code, 0 B).
- **Sizes (estimates):** body 900 glyphs × ~1,300 texels (narrow Latin cells packed) ≈ 1.2 MB; display 80 × 104² ≈ 0.9 MB;
  atlas ≈ 2.1 MB raw as one R8 texture of 2048 × 1024 or two pages. Wasm +2.1 MB data (index.wasm 11.2 → ~13.3 MB with the code
  of §6); gzip roughly halves an SDF (smooth gradients), so about +1 MB transferred. GPU memory +2 MB. GC heap: the glyph table
  and the run cache, under 1 MB.
- **Layout**: runs measured and laid out once per (string, face, wrap width) into a cache (glyph index, x, y in em units; the
  size applies at draw, so one layout serves every size). CJK wraps between any two CJK characters, Latin at spaces, with the
  kinsoku rules (no line starts with 。，、；：）」』… and no line ends with （「『), letter spacing in em, line height,
  baseline mixing by the face's ascent. Vertical runs stack CJK upright with the em as the advance. Strings from the model are
  EQ-stable until they change (`*hud-strs*`), so a cache hit is an EQ test; numbers are drawn as digit glyphs from an integer
  without a string (0 B). Missing glyph: the sans's □ (and a once-per-string log).
- **Styles from the field**: hard shadow = the run again offset (no extra texture read); outline = mode 1 with `p.w`; glow =
  a second draw with a lowered edge and a wide softness; halftone fill = the pattern flag; blur = softness tweened.

### 4.3 Layout: anchors, units, clamps, splits, stacks (no flexbox)

The HTML screens are fixed compositions: every element is placed from a viewport edge or a parent box, sized in `u` or by
`clamp()`, and lists are single stacks. So the layout is a handful of functions over f32 rectangles, no tree:

- Units: `css` (device px / `pixel-density`), `u` (battle: `min(1vw, 1.7778vh)`, portrait `2.36vw`), `vw`, `vh`, `clamp(min,
  pref, max)`.
- The form, chosen per frame: battle `:landscape` / `:portrait` (+ deck, + left hand); menus `:desk`, `:narrow` (≤ 760 CSS px
  wide), `:short` (≤ 560 tall and > 760 wide). Each screen has a layout function per form, written from the CSS rules.
- Anchors: a point of the viewport or of a box, an offset, `max(a, safe + b)` for the safe area (four insets: top / bottom
  today, left / right through two new page keys, §4.5).
- Splits: a width cut by ratios (`grid-template-columns: 1.05fr 1fr` with a gap); the SELECT cards' weights are tweened.
- Stacks: children measured, then placed along an axis with a gap and an alignment (start, end, centre, baseline for text
  rows, `margin-inline-start: auto` as a spacer), mirrored for P2 and the left hand by flipping x in the box.
- Why not flexbox: no screen depends on content-driven reflow beyond one row or one column; the two places that grow (SELECT's
  cards, the help line's height) are explicit tweens. A general flex solver would be the largest module for no visible gain.

### 4.4 Animation: tweens and keyframes on a real-time UI clock

- `engine/lisp/tween.lisp`: cubic-bézier easing (the page's three: `ease-cut (.7,0,.2,1)`, `ease-out (.16,1,.3,1)`,
  `ease-snap (.2,1.6,.4,1)`, plus CSS `ease`, `ease-in-out`, `linear`, `steps(n)`) solved by a 64-entry table per curve made at
  load; keyframe tracks (offsets, values, per-segment easing) as constant f32 vectors; animation slots (start time, duration,
  delay, iterations, fill, direction) in a pool of f32 vectors; transitions (from, to, start, duration, curve) per numeric slot.
  0 B per frame. `restart` (the page's class toggle) = set the start time to now.
- **The clock: real time for menus and the battle HUD.** `*ui-clock*` advances by the unscaled frame time every frame, paused or
  not. The HTML runs on the wall clock everywhere: hitstop, slow motion and the cancel's slow motion do not slow it, and under
  the pause the flames keep flickering at .3 opacity. The Lisp HUD does the same. The canvas HUD's convention (the fx clock,
  stopped while paused) is not kept. Under `tools/run.mjs --fixed-dt` the frame time is virtual, so stills stay deterministic.
- Reduced motion: a page key (§4.5) or the OS setting off the web; on, every duration is 0 (the sheets' rule).
- `fx-envelope` is not reused (fixed shape, fx clock). `%pulse` (ui.lisp) is reused for the infinite pulses.

### 4.5 Input

- Keys, pads and touch stay as they are (Lisp already owns them); the Lisp HUD only adds pointer targets.
- A per-frame registry of hot boxes (id, rectangle, in drawing order); hit tests use last frame's boxes, as `note-menu-row`
  does. Mouse hover over a row = cmd 1 (cursor); click = cmd 1 + 2; a tap = the same through `touch-tapped-p`; SELECT's card
  picks and the settings' options as menu.js's click handler (cmd 6, 7, 8). The commands go through the same dispatcher as the
  page's queue (the bodies of `webui-commands` / `webhud-commands` become a function of `(screen cmd arg)`), so both renderers
  drive the flow identically.
- Engine: `pf_mouse_xy` (the absolute position from SDL's motion event) and `mouse-x` / `mouse-y`. SDL's `x` / `y` are window
  coordinates, not pixels; `pf_mouse_xy` multiplies them by the pixel density so they match `window-width` and the layout
  (otherwise hit tests are off by the device pixel ratio on a 2× desktop).
- Page keys added in pwa.js (it stays JS glue): get 5 / 6 the left / right safe-area insets, get 7 `prefers-reduced-motion`,
  get 8 the HUD renderer flag from the URL (§4.6).
- Phone menus that overflow (narrow SETTINGS / CONTROLS / RESULTS scroll in the HTML): the list scrolls to keep the cursor row
  visible, and a vertical touch drag scrolls it (the recogniser's stick delta while no row is pressed).

### 4.6 Coexistence and comparison

(History: the HTML renderer, the URL flag, the page transport and the canvas renderer below were removed on 2026-11-11, §16.)

- `*hud-renderer*`: `:html` (the default while the HTML HUD is the shipped one), `:lisp`, `:canvas` (no page: the native gate,
  an old cached page). Today's `webhud-p` / `webui-p` answer two questions at once; they split into two predicates:
  - **`page-draws-p`** (renderer `:html`): send to the page and read its command queue. Callers: `webhud-put` / `webhud-put-str`
    / `ui-put`'s `page-set` (the vectors are always updated), `webhud-commands` and `webui-commands`' page queue (webhud.lisp:244,
    webui.lisp:77), flow's read of SELECT's model spot (get 30002 / 30003).
  - **`canvas-hud-off-p`** (renderer `:html` or `:lisp`): the canvas HUD leaves the element out, and the model runs. Callers:
    `webhud-sync` and `webui-sync` (webhud.lisp:208, webui.lisp:38, the model; `*scene-transparent*` for SELECT, set in
    `webui-sync`), `webui-on-screen-p` (hud-screens.lisp:237, the menus), the letterbox and caption of the intro / K.O. / TIME
    and `*caption-out*` (hud-screens.lisp:231, 235, with `webhud-cine-p`), the canvas pause overlay (hud-screens.lisp:250),
    `hud-battle`'s early return (hud.lisp:834), the world callout (hud.lisp:768), `hud-deck`'s reduced drawing
    (onehand.lisp:328), the intro's FIGHT! word (cinema.lisp:372), SELECT's `:select-web` camera (camera.lisp:321; in `:lisp`
    the spot comes from the Lisp layout instead of the page).
  - The recogniser's changes of DUEL_WEBUI §7.4 do not key on `webhud-p` (checked: the only touch-side caller is
    onehand.lisp:328's drawing), so input behaves the same in all three renderers.
- **A switch mid-run**: `webhud-put` / `ui-put` skip a value equal to the last one sent, so every switch resets `*hud-sent*`,
  `*hud-strs*` and `*ui-sent*` to their unsent state (the page gets a full re-send on a switch to `:html`); a switch to `:lisp`
  first sends 30000 = 0 and 30100 = 0 so the HTML hides.
- The switch: the URL flag `?hud=lisp` (pwa.js page get 8; bookmarkable on the phone, survives reloads) and a debug command
  (2517 toggles the renderer: to be claimed in DUEL_GAMEPLAY "Debug commands" with `tests/debug-ranges-check.py` in phase 0;
  2518 a still mode that holds the touch ink, as hud.js's `still`; 2519 the Lisp HUD's consing probe, as 2515).
- The protocol is unchanged: the 30000 / 30100 blocks remain the model's layout and the HTML renderer's wire format.
- Comparison: the same `tools/run.mjs --script` run twice with `--fixed-dt`, once plain and once with an `eval` of debug 2517 at
  t = 0 (or the URL flag), stills at the same virtual times; `tests/lhud-compare.py` (Pillow) puts each pair side by side with
  a difference map. The HUD is presentation only, so the sim lines of the two runs must be equal (checked in each phase).

### 4.7 Performance budget

- 0 B per frame in steady state (the probe 2519; allocation only when a string changes, a screen opens or the window resizes).
- Draw calls: +1 (RP_HUD), +1 on SELECT (the back layer).
- Vertices: a busy battle frame (two plates, 18 flames, combo, callout, prompt, deck) ≈ 600 glyphs + 300 shapes ≈ 6,000 vertices;
  the menus up to ≈ 15,000 (CONTROLS' key map). 16 floats each: up to ~1 MB written and copied a frame on the menus, ~0.4 MB
  in battle (estimate; measured in phase 0).
- Lisp time: target under 1 ms a frame for the battle HUD on desktop (relative measure on SwiftShader: before / after, as
  AGENTS says).
- Startup: the atlas upload and the glyph table in one `:load` step; easing tables at load.
- Heap: under +5 MB at startup (the 110 MB `--max-heap` check in `tools/run.mjs` stays green).
- Wasm: +2.1 MB atlas + ~0.6 MB code (estimate); removing the canvas HUD later (~850 lines) and the HTML files (~140 KB of
  page) gives some back.

### 4.8 Principles: ECS + pragmatic FP (the user, 2026-11-11, DEVLOG §709)

The standing rule (AGENTS.md "Design principles"): low coupling, high cohesion, state in data (ECS), logic as pragmatic
functional programming. How the Lisp HUD as built (phases 0-1, §8-§12) maps onto it, and where it does not yet:

- **Pure functions** (plain CL, host-tested in tests/hud-engine-test.lisp and tests/paint-shapes-test.lisp): layout.lisp's units,
  clamps, anchors, splits and stacks; `wrap-lines` (kinsoku); tween.lisp's `ease`, `tween-value`, `trans-value`; `path-points`.
  They write their float results into lanes (`*tw-io*`, `*text-io*`) only to keep 0 B a frame: a calling convention, not state.
- **Where state lives**: the model the HTML and Lisp renderers both read (`*hud-sent*` / `*hud-strs*`, webhud.lisp: plain
  vectors, written by the game once a frame); per-element animation state in fixed slots (`*lhud-f*` / `*lhud-i*`, tween slots,
  transitions); the paint stream's preallocated buffers, its transform / opacity / scissor / pattern stack and the text pen. The
  last are mutation for the 0 B rule, kept inside paint.lisp / paint-shapes.lisp.
- **Hidden channels today**: the setters that must be called in order before an emitter (`paint-clip!` resets the gradient and
  centre, so `paint-grad!` / `paint-centre!` come after it; `paint-dots!` / `paint-stripes!` and `paint-scissor!` stay in force
  until `paint-reset` or `paint-pop`); `*paint-pat*` and `*paint-sc*` read by every emitter; the pen read by every text call;
  `*lay*` read by the `lay-*` helpers. Each is one named place, but a caller can leak it to the next element: the rule is one
  `paint-reset` (or a push / pop pair) per element.
- **The rule for the screen phases (2-6)**: each screen is a view function from the model (plain data) + the layout frame + the
  UI clock to paint calls; element state (a ghost's drain, a stamp's start, a hover) is a component in a plain vector updated by a
  small system before the view runs; no screen reads sim internals (only the model, as the HTML does); no element reaches into
  another's state.
- **Not ECS entities**: engine/lisp/ecs.lisp's world is one global of 256 slots shared with the game (fighters, hazards), its
  `spawn-entity` conses, and flow.lisp's per-match reset `clear-entities` empties it; HUD elements there would take sim slots,
  be wiped at each match and couple the HUD to the sim's determinism. The HUD's elements are a fixed set known at load, so plain
  component vectors indexed by element (as `*lhud-f*` already is) give the same data-oriented layout with none of that.
- **To change later** (not now): name the per-element slots (`*lhud-f*`'s offsets) as small component structs or accessors; make
  the setters' order explicit by an element macro that resets and pushes (a `with-element`); split lhud-battle.lisp's view
  functions from their slot updates when phase 2 rewrites the plate.

## 5. Phases

Every phase: host tests (duel-rules, control, input, touch, cine and the new lhud / tween tests), pkgcheck, `./build.sh duel`, a
smoke (`run.mjs` exit 0 and the heap line), G2 `--cvc` identical (the HUD is presentation only), the 0 B probe, and side-by-side
stills (HTML vs Lisp) of the same scripted scene the user reviews. The looks gate cannot prove byte-identity today
(REFACTOR_2026-11.md §10.2); it is not used as a proof here.

| Phase | Scope | Files | Proof / exit | Lines (est.) | Model | Parallel |
|---|---|---|---|---|---|---|
| 0 spike | RP_HUD with modes 0-2, a minimal bake (sans + display tier, the plate's and combo's strings only), one plate's name / kanji / tag, the combo count with `hd-stamp`, `*hud-renderer*` + 2517 | render.c, a new hud shader, `engine/lisp/paint.lisp`, `tools/sdf-bake.py`, `duel/lisp/lhud-battle.lisp` (stub) | measured: wasm bytes, startup heap, frame ms (before / after), consing; stills at 390×844 dpr 3 and 1280×720 / 1920×1080 dpr 1 of the smallest sizes (.62u mono ≈ 8 CSS px at 1280, ≈ 6 at 390; menu 10 px mono, 11-12 px zh) with the densest kanji (鏡 鍵 鐮 觸 覺 鬥). Exit: the user finds the smallest text legible next to the HTML; 0 B; wasm and heap within the estimates ±50 % | ~900 | Opus | |
| 1a bake + build (done 2026-11-11, §9) | the full bake (four faces, two tiers, packing), the charset file and test, licence files, the hud-font README (no build.sh step: `#embed`, §8.6) | tools/sdf-bake.py, duel/lisp/lhud-charset.lisp, tests/duel-rules/lhud-charset.lisp, duel/hud-font/, duel/FONT-LICENSE-* | the test fails on a missing glyph and passes on the data; atlas size as estimated | ~450 | Sonnet | with 1b, 1c |
| 1b paint (done 2026-11-11, §10) | modes 3 and the patterns, polygons with the fringe, strokes, radial fans, the affine / opacity / clip stacks, the back layer and blend 4 | paint.lisp, render.c, render.lisp, the shader | engine host tests where pure; stills of a test card (shapes, rings, a halftone, a reveal) | ~700 | Opus | with 1a, 1c |
| 1c text, tween, layout, input (done 2026-11-11, §11; built as text.lisp, the run cache left out) | run layout (CJK wrap, kinsoku, vertical), the run cache, styles; tween.lisp; layout helpers; the hot-box registry; `pf_mouse_xy`; pwa.js keys 5-8 | `engine/lisp/sdf-text.lisp`, `tween.lisp`, `layout.lisp`, platform.c / .lisp, pwa.js | host tests: easing against CSS reference values, wrap and kinsoku cases, clamp / anchor math | ~900 | Opus (text), Sonnet (tween, layout) | with 1a, 1b |
| 2 handheld, portrait (first complete screen; done 2026-11-11, §13) | the portrait battle screen of the phone, right hand (the user's screenshot, §7): the slanted Reishi bars and soul flames, the plate on the line, the stance picker (構 / 肩 / 拖 with its label), the 爆 dial (ink level, ticks, rings, arm / deny / slosh) with 重 / 月 / 亂, the SP 技 / ATK 斬 zones and their dividing line, the pause chip, the clock tab, touch ink, the left hand; the kanji tags (風死, 分身), the paused .3 opacity; the data file's battle tables. This is the old phase 4 plus the portrait part of the old phase 2 | lhud-data.lisp, lhud-battle.lisp, lhud-deck.lisp | `--mobile` stills at 390×844 with touch scripts (tap, flick, hold), both hands, the screenshot's state reproduced side by side with the HTML; the user's first review of a whole screen | ~1,300 | Opus | after 1a-1c, with 5 |
| 3 battle, landscape (done 2026-11-11, §14) | the desktop HUD: plates (bar, flames, kit strip, meters, seals), clock, combo, callout, prompt: what phase 2 did not already build | lhud-battle.lisp (+ lhud-data.lisp) | side-by-side stills of scripted fights (both sides' callouts and combos, low Reishi, a Kikon at stake, awakening, sublimation, Kenpachi's NOME / UDE / KAIHO, PRACTICE ∞) | ~500 | Opus | after 2 |
| 4 overlays (done 2026-11-11, §14) | pause (desktop and phone), intro card and READY / 斬, finish (K.O., TIME, draw) | lhud-overlay.lisp | stills through each phase of the intro and finish, the pause with PRACTICE's long list | ~500 | Sonnet | after 2 |
| 5 menus I | the backdrop, rails, cut, TITLE (wordmark, halftone 魂, ash), MODE (rows, brush, seals, torn card), SETTINGS, RESULTS | lhud-menus.lisp | stills of each screen at 1440×900 and 390×844, the cut mid-way, hover and tap through the hot boxes | ~1,000 | Opus | with 2 |
| 6 menus II | CONTROLS (tabs, key map, binds, capture), the phone gestures page, SELECT (cards, weights, emblems on the back layer, the model spot computed in Lisp) | lhud-menus.lisp (+ lhud-select.lisp) | stills of SELECT's three phases with the fighter between the layers, at both sizes | ~800 | Opus | after 5 and 1b |
| 7 acceptance | the user plays both; the default flips to `:lisp` on his word; then the removals (hud.js / menu.js / css, the canvas HUD) are his decision | flags, docs | the user's playtest | small | main session | |

Total ≈ 7,000 lines including tests and the bake tool (estimate), of which ≈ 2,500 engine, ≈ 4,000 game, ≈ 500 tools / tests.
Below §704's 8-12k because the model layer exists and the atlas is static (no runtime rasteriser or cache). Order of review:
phase 0's stills, then phase 2's handheld portrait screen (the user's first choice, §7), then phase 3's landscape battle, then phase 5's menus,
which can be built in parallel in a second worktree once phase 1 lands.

## 6. Risks and what is not done

- **Not done**: manual.html (stays HTML, the user's decision); the PWA, fullscreen, service worker, wake lock, the history /
  Back trap and localStorage (pwa.js, sw.js stay JS); accessibility (the HTML HUD is `aria-hidden` already; the menus' roles and
  labels are lost in the canvas); text selection; the frozen ENDLESS / DANGAI screens (still the canvas HUD).
- **Wasm size**: +2-3 MB is the largest cost; if phase 0 shows more, the display tier drops to 64 px or the hero glyphs move to
  outline polygons (§7 Q4).
- **Legibility of the smallest text** (6-8 CSS px labels at dpr 1-3): an SDF at 32 px is fine down to about 9 device px; below
  that the HTML's hinted text is crisper. Phase 0 decides with stills.
- **Drift during coexistence**: the shown tables exist twice (lhud-data.lisp and the JS) until the HTML is removed; the JS
  copies are frozen as the reference and the Lisp file is the one edited.
- **Noise-made looks** (torn paper, dry brush, grain) will not match contour for contour; judged by eye.
- **Fonts**: the licences are assumed OFL 1.1 until each licence file is read; Noto Sans TC's CJK outlines are large (the bake
  is offline, so only the bake is slow).
- **Determinism of stills**: the renderer nondeterminism of REFACTOR_2026-11.md §10.2 affects the scene behind the HUD, not the
  comparison of two HUD renderers by eye; the 0 B and G2 checks do not depend on it.

## 7. ⚠ Questions for the user

**Decided by the main session under the user's delegation (2026-11-10)**: the user left the method to us (「請根據程式的實作判斷該如何
移植」), so the main session took option (1) of each question below; each stays open to the user's veto.

1. After the spike: the battle HUD (landscape), then the overlays, then the phone deck; the menus in parallel.
2. Switching: the URL flag `?hud=lisp` plus debug commands (2517 the renderer, 2518 the still mode, 2519 the probe); no SETTINGS
   row yet.
3. New code in `lhud-*` files (the engine side in its own engine files: `engine/lisp/paint.lisp`, `engine/shaders/hud.*.wgsl`);
   the canvas HUD stays as the no-page fallback until acceptance.
4. The full two-tier bake as designed, unless phase 0's measurements say otherwise (they do not: §8).

**Decided by the user (2026-11-11)**, asked how to use the screenshot he sent of the handheld (portrait, right-hand) battle screen
(「手持模式的操作介面（右手）」: the slanted Reishi bars, soul flames, the stance picker 構 / 肩 / 拖 with its label, the 爆 dial with
重 / 月 / 亂, the SP 技 / ATK 斬 zones and their dividing line, the pause chip):

5. 「手持直向畫面優先重現 (Recommended)」: that screen is the first complete Lisp HUD screen, built right after phase 1, before the
   landscape desktop HUD (§5: the old phase 4 plus the portrait part of the old phase 2 is now phase 2; landscape, overlays, menus follow).
6. Asked about small-text legibility (12 px zh-TW legible but lighter than Chrome's, 8 px kanji soft): 「先加粗小字再看一次 (Recommended)」:
   text under about 14 px gets an edge bias (§8.3's knob, 0.5 to about 0.47) so its stroke weight is near the browser's; new comparison
   stills go to the user; phase 1 proceeds meanwhile (the bias is phase 1c's, in the text code).

**Decided by the main session (2026-11-11)**, revising answer 2 above:

7. **A SETTINGS row for the renderer**, 「HUD：HTML／LISP」, in both menus (menu.js and the Lisp menus), saved with the other settings
   (control.lisp `*settings*` row `:hud`, appended last so the saved rows keep their places; pwa.js `soulduel.hud`) and applied at once
   (webui.lisp `webui-renderer-sync` → `set-hud-renderer`). Reason: the user playtests through an Artifact page, where a URL flag cannot
   be passed. The URL flag `?hud=lisp` and debug 2517 stay; the row and the renderer are kept equal edge-triggered both ways, and the URL
   flag wins for its run (the row shows LISP, not saved). The default stays HTML. Built in §15.

**Decided by the user (2026-11-11)**, asked whether, after acceptance, to make Lisp the default and remove the HTML HUD and the old
canvas HUD:

8. 「將 lisp 版設為預設並移除 html」: the Lisp renderer is the only shipped HUD and menu renderer; the HTML HUD and menus are removed with
   everything that only fed them, and with them answer 7's SETTINGS row, the URL flag and the page transport (§16). The manual stays an
   HTML page (answer 「我選 3，說明手冊保留在 html 頁面」, §1).
9. 「舊的 Canvas HUD 也移除」 (the same day, relayed by the main session as a scope change): the canvas battle HUD, its menus, its pause
   and the one-hand deck's drawing go in the same batch, with the renderer switch; refactor decision D4 is done by it (§16.6).

The questions as they were put:

1. **What to build first after the spike?** (1) **The battle HUD (landscape), then the overlays, then the phone** (recommended:
   the screen seen most, and it exercises text, bars and the most animations); (2) the menus first (static layouts and zh
   paragraphs, easier to compare); (3) the phone deck first (where the HTML has most of its custom work).
2. **How to switch between the two HUDs for comparing**: (1) **a URL flag `?hud=lisp` plus a debug command** (recommended: no menu
   change, both bookmarkable on the phone); (2) a SETTINGS row 「HUD：HTML／LISP」 (visible; changes the row counts and the test
   scripts); (3) both.
3. **The canvas HUD code** (hud.lisp / hud-screens.lisp / onehand.lisp's deck): (1) **left as the no-page fallback and removed
   when the Lisp HUD is accepted (D4); the Lisp HUD in new `lhud-*` files** (recommended: the old paths stay untouched and
   comparable, nothing unprovable is edited); (2) rewritten in place into the Lisp HUD.
4. **The atlas's size against its sharpness**: (1) **the full bake, ≈ +2.1 MB wasm (+≈ 1 MB transferred)** (recommended: the
   big kanji and the wordmark stay sharp at 4K); (2) a smaller display tier (64 px, ≈ +1.6 MB, slightly round corners on the
   biggest glyphs); (3) the hero glyphs as outline polygons from the same fonts (≈ +1.3 MB, but their edges are not antialiased).

## 8. Phase 0 results (the spike, 2026-11-10)

The spike answers §5's phase 0 questions with the smallest build: the engine's paint stream, a mini bake of all four faces in
both tiers, both plates' name row and Reishi bar (desktop; the phone's P2), both combos with `hd-stamp`, and a legibility card.
Opus 5.5 built and measured it in a worktree; the main session reviews.

### 8.1 What was built

| Where | What |
|---|---|
| engine/c/render.c | `RP_HUD` = slot 19 (render.c:10); `r_hud_atlas_new` (render.c:164, R8, linear sampler); a 32,768 × 64 B region of the transfer buffer and its vertex buffer; drawn after the UI in the swapchain pass (render.c:311) only when the stream has vertices and an atlas exists, so the default path issues nothing new. `r_frame` takes the stream (two arguments; engine.h, render.lisp's call, tools/simgate/stubs.c) |
| engine/shaders/hud.vert.wgsl, hud.frag.wgsl | 16-float vertex (0x4444); modes 0 flat, 1 SDF glyph (edge, softness, outline band), 2 rounded box (half size, radius, feather, border); the atlas is sampled and `fwidth`ed before any branch (WGSL uniformity) |
| engine/lisp/paint.lisp (266 lines, after ui.lisp) | `paint-init` (:28, from `engine-init`); `with-hud-verts`; `paint-poly` (:100: a convex polygon clipped to a rectangle, Sutherland-Hodgman, vertical gradient, fan); `paint-box!`; `paint-font-init` (:149, metrics.bin into a sorted key vector + 9 floats a glyph); `glyph-find` (:167: the display tier above 40 px, else the body tier; fallback face → sans → Mincho → □); `%paint-run` (:193: runs with letter spacing, a synthetic-oblique skew, a pen that advances); `paint-int` (digits, no string); `ease-curve` (:250, the five CSS curves by Newton); `*ui-clock*` and `paint-clock-advance`. Float inputs travel in f32vecs (the transform, clip, pen, box), so no float crosses a call boxed |
| tools/sdf-bake.py (193 lines) | `--fetch` (Google Fonts repository → build/font-cache/, git-ignored); variable faces instanced at the page's weights (Big Shoulders Display 900, Martian Mono 600 / wdth 100, Noto Sans TC 500; Shippori Mincho B1 ExtraBold is static), subset first, pathops overlaps, exact segment distance (numpy), shelf packing; writes duel/hud-font/atlas.r8 + metrics.bin and copies each OFL.txt to duel/FONT-LICENSE-<face>.txt. The charset: ASCII for the display, mono and sans faces, plus the strings in `(kj "…")` / `(zh "…")` / `(big "…")` forms of duel/lisp/lhud-*.lisp; a character the sans lacks goes to the Mincho (the HTML's 「決闘」 has 闘, not in Noto Sans TC) |
| duel/hud-font/lhud-font.c | `#embed`s the two files (C23; emcc 4.0.12's clang accepts it, its warning silenced by a pragma) and serves them through `lhud_font(k, &n)`; listed in duel/MANIFEST. **build.sh needs no change**: this replaces §4.2's "build.sh turns a listed .bin into a C array" |
| duel/lisp/lhud-battle.lisp (281 lines, after webhud.lisp) | `lhud-plate` (:77: hud.css .plate / .who / .reishi: the baseline-aligned name, kanji and tag with letter spacing and the name's hard shadow; the bar's clip-path polygon, the ghost's drop transition (.38 s delay, .55 s ease-cut, snapping on a refill), the white → paper → #c9cbcf fill, the fixed grid, the inset line; P2 mirrored; the phone's P2 at 3.8u / 2.2u / 30u, or 27u with the deck); `lhud-combo` (:155: the slash under a P1 row stretched to the DMG line as the grid does, the blood shadow, a 0.25 skew for Chrome's synthetic italic, HITS at edge 0.53 for weight 800, the DMG / SCALE line; on for 1.2 s after a new serial, opacity .25 s ease and x 2u .35 s ease-out from wherever they are, `hd-stamp` .24 s ease-snap from scale 1.5 rotate −6° about the count's box; the first serial seen is not shown, as in hud.js); `lhud-card` (:245, debug 2518); `lhud-draw` (:260); `lhud-init` (:272, a `:load` step: one FFI copy of the metrics, the atlas uploaded from static data) |
| duel/lisp/webhud.lisp | `*hud-renderer*` (:html / :lisp), `set-hud-renderer` (to :lisp the page's layer is hidden once with 30100 = 0; to :html every value is re-sent); `webhud-p` reads page get 8 with its first answer and stays true under :lisp (the canvas HUD keeps out); `webhud-put` / `webhud-put-str` always update the vectors and send only under :html |
| hud-screens.lisp, debug.lisp, main.lisp | `hud-draw` advances the UI clock and calls `lhud-draw` under :lisp; debug 2517 / 2518 / 2519 (DUEL_GAMEPLAY "Debug commands"; debug-ranges-check 0 errors); `lhud-init` in the load steps |
| duel/web/pwa.js, tools/run.mjs, tests/lhud-compare.py | page get 8 = `?hud=lisp`; `run.mjs --query hud=lisp`; the side-by-side sheet tool (HTML, Lisp, difference ×4, crop, zoom) |

Not in the spike (as planned for later phases): the back layer and blend 4, the transform stack, the polygon fringe (polygon
edges are aliased), pattern flags, wrap / kinsoku / vertical runs, keyframe tables, the phone's P1 plate on the deck's line and the
ink pool behind phone plates, the plate's kanji tags (風死, 分身), the paused .3 opacity, the pause rows (under :lisp the pause
draws nothing yet), the menus (they stay HTML under :lisp).

**`?hud=lisp` in phase 0 is a comparison mode for stills, not a playable build**: everything else of the battle screens is blank
under it — the clock, the soul flames, the flash-step and awakening meters, the kit strip, the pointer seals, the callout, the
prompt, the phone's deck visuals (爆, the stance seals, the touch ink), the intro card, READY / 斬 and the K.O. / TIME finish (the
canvas letterbox and caption stay off too, since `webhud-p` is true), and the pause, which opens and takes keys but shows nothing.
Do not publish it as a playtest. §4.6's split of `webhud-p` into `page-draws-p` and `canvas-hud-off-p` is deferred: the spike
reuses `webhud-p` (true under :lisp) and guards the two put macros; phase 2 makes the split.

### 8.2 Measurements

| What | Command | Before | After |
|---|---|---|---|
| index.wasm | `./build.sh duel`; `wc -c`, `gzip -9 \| wc -c`, `llvm-objdump -h` | 11,155,455 B (gzip 3,116,682); code 7,958,293, data 3,161,700 | 11,570,734 B (+415,279; gzip 3,339,769, +223,087); code +44,175 (paint.lisp, lhud-battle.lisp, the shaders' text), data +370,982 |
| The mini bake | `build/sdf-venv/bin/python -I tools/sdf-bake.py` | | 382 glyphs: display body 97 (666 texels a glyph), mono 97 (835), Mincho 30 (≈ 1,360), sans 147 (942), display tier 11 digits (3,865); atlas 1024 × 512 = 524,288 B raw (82 % packed), metrics 6,958 B; the atlas gzips to 188,714 B. The wasm data grew by 71 % of the raw bytes (the linker drops the atlas's zero runs) |
| Full bake, extrapolated | per-glyph texels above × §4.2's charset (≈ 290 ASCII cells, ≈ 630 CJK body cells at ≈ 1,360, ≈ 40 Latin + 40 kanji display cells at ≈ 3,900 / ≈ 10,800) | | ≈ 1.8 MB raw (§4.2 estimated 2.1), ≈ 1.3 MB of wasm data, ≈ 0.65 MB gzip |
| Startup heap | `run.mjs` (`startup: heap`) | 73.4 MB | 74.3 MB (+0.9: the stream's 2 MB f32vec within the heap's growth step); limit 110 |
| Consing a frame | debug 2519 (100 calls each; P1's combo forced on mid-stamp) | | plate 0 B, combo 0 B, whole draw 0 B, at 1280 × 720 and 390 × 844 |
| Consing, the whole frame | the `stats:` lines' `cons/frame` of the `--fixed-dt` scene runs (deterministic: the old build's two runs agree), :html vs :lisp at the same tick | t 121: 1666 B (phone 1801); t 242: 1397 (1525) | t 121: 1653 B (1788: 13 B less, no page sends); t 242: 1397 (1525). The :lisp path, clock included, adds 0 B a frame |
| Lisp time | debug 2519 in a wall-clock run (`run.mjs --secs 14 --query hud=lisp`, SwiftShader, desktop) | | plate 0.136 ms, combo 0.034 ms, the whole draw (two plates and a combo) 0.31 ms a frame; most of a plate is its 20 clipped grid strips |
| Vertices | debug 2519 | | plate 252, combo 144, the busiest frame 666 (of 32,768) |
| Frame | the stats lines of the same wall-clock runs, :html vs :lisp (the 12-15 s window, idle) | queue 0.55 / 0.47 ms, 40-53 fps | queue 0.92 / 0.87 ms, 92-120 fps. The +0.35 ms is the Lisp HUD; the higher fps is SwiftShader no longer compositing the HTML layer, not a claim about phones |

### 8.3 Legibility (the stills; paths in the worktree's build/lhud/, git-ignored)

The scene: debug 74000 (human Ichigo vs Kenpachi), 2393 (2.2 m), four J taps, `--fixed-dt 16.666667`, stills at 10.95-13.60 s, run
once plain and once with `--query hud=lisp`, at 1280 × 720 and `--mobile --size 390x844` (dpr 3). The card: debug 2518 under :lisp
beside an HTML twin with the same rows, faces, sizes and places (build/lhud/ref/index.html): mono at .62u (7.9 CSS px at 1280),
.72u and 10 px; Noto Sans TC at 11 and 12 px with 鏡 鍵 鐮 觸 覺 鬥; the pause rows' zh and the Mincho at .95u and 1.25u.

- The plates and the combo land on the HTML's positions within 1-2 device px (the bar's first row 64 vs 65, its ends 46 / 1233
  vs 44 / 1235 at 1280; 177 vs 178 and 324 vs 325 on the phone); the type, spacing, colours, shadow and the slash read the same.
- At dpr 3 (the phone) the smallest text is indistinguishable from the HTML's at a glance.
- At dpr 1, 8-12 px, the Lisp text is legible but a little lighter and softer than Chrome's hinted text; the densest kanji at
  12 px stay readable; the 7.9 px mono reads, its 「決闘」 is a blot in both. The knob if the user wants it heavier: an edge bias
  under ≈ 14 device px (0.5 → ≈ 0.47), not applied.
- Sheets: cmp-desk-{11.05,11.50,13.60}.png, cmp-desk-p1-z3.png, cmp-desk-p2-z3.png, cmp-desk-combo-z3.png, cmp-mob-*.png,
  cmp-mob-p2.png, cmp-card.png, cmp-card-small-z3.png, cmp-card-m.png, cmp-card-m-small.png; the raw stills in build/lhud/s/.

**A finding about the comparison method**: hud.css's transitions and animations run on Chrome's own clock, not on run.mjs's
virtual clock, so the HTML's animation phases in `--fixed-dt` stills are not deterministic (the ghost has already drained, the
stamp is at another phase, the soul flames flicker differently run to run). The Lisp side is deterministic. Phase 2's animation
review needs either the HTML's CSS animations paused and seeked through the DevTools Animation domain (a run.mjs option) or a
wall-clock video; until then, compare animation timing against the CSS numbers, not against HTML stills.

**The default renderer is unchanged as far as the noise allows**: the same scene on the old build twice and on the new build
once. Every differing pixel lies in the HTML HUD's band (the top 110 px and the combo box: the flames, the ghost, the stamp, all
CSS animations on Chrome's clock): base vs base 0-1,549 px, base vs new 1,316-3,455 px, and outside the band ≤ 7 px in all
three pairs; the sim's log lines are equal and G2 is identical. The higher base vs new count is the flames' phase
(cmp-default-12.00-z3.png, at a time the old build's two runs happened to match), not a change of look; a pixel proof waits on
REFACTOR_2026-11.md §10.2's nondeterminism and on the CSS clock above.

### 8.4 Licences (each OFL.txt read)

| Face | Licence | Reserved Font Name | Embedding |
|---|---|---|---|
| Big Shoulders Display | SIL OFL 1.1, © 2019 The Big Shoulders Project Authors | none declared | allowed; the baked subset is a Modified Version, the licence travels in duel/FONT-LICENSE-BigShouldersDisplay.txt |
| Martian Mono | SIL OFL 1.1, © 2021 The Martian Mono Project Authors | none declared | as above, FONT-LICENSE-MartianMono.txt |
| Shippori Mincho B1 | SIL OFL 1.1, © 2021 The Shippori Mincho Project Authors | none declared | as above, FONT-LICENSE-ShipporiMinchoB1.txt |
| Noto Sans TC | SIL OFL 1.1, © 2014-2021 Adobe | 'Source' | allowed; the subset must not be named "Source…" (it carries no name: a table of SDF cells); FONT-LICENSE-NotoSansTC.txt |

No face blocks embedding.

### 8.5 Exit criteria (§5)

| Criterion | Result |
|---|---|
| The user finds the smallest text legible next to the HTML | **for the user**: the sheets above; our read: yes at dpr 3, yes but lighter at dpr 1 |
| 0 B | met: plate 0, combo 0, whole draw 0 (debug 2519) |
| wasm within the estimates ±50 % | met: the full bake extrapolates to ≈ 1.8 MB raw / ≈ 1.3 MB of wasm data against §4.2's 2.1 MB; code +44 KB for ≈ 580 lines, on course for §4.7's ≈ 0.6 MB |
| heap within the estimates ±50 % | met: +0.9 MB against the +5 MB budget |
| frame time (target under 1 ms of Lisp a frame) | met: 0.31 ms for two plates and a combo (SwiftShader) |

### 8.6 What the measurements change

- Keep §7 Q4's option (1), the full two-tier bake: it costs less than estimated in the shipped wasm.
- Phase 1a: no build.sh step; a `.c` file that `#embed`s the bake, as here. Its charset test reads the same tagged forms.
- Phase 1b: the grid strips show that many small clipped polygons cost (0.1 ms a plate): add the pattern flag for repeated
  stripes and dots early, and the polygon fringe (the bar's slanted ends and the slash are aliased now).
- Phase 1c: the clock is advanced by the caller, not by the draw (a probe that calls the draw 100 times must not move it).
- Phase 2: add the CSS-animation freeze to run.mjs before the animation review (§8.3); the phone's ink pool, the paused opacity
  and the kanji tags join the battle work.
- The phases' order and sizes stand: phase 0 took ≈ 580 lines of Lisp, C and WGSL and ≈ 220 of tools, inside §5's ≈ 900.

## 9. Phase 1a results (the full bake, 2026-11-11)

Sonnet 5.5 in a worktree; the main session reviews. `tools/sdf-bake.py` now bakes the closed set of the HUD; no code of the renderer changed.

**The scan** (all in the bake, reproducible): (1) the tagged forms of `duel/lisp/lhud-*.lisp` with `;` comments dropped: `(kj)` Mincho body,
`(bigkj)` Mincho display tier, `(big)` display face display tier, `(zh)` sans, `(lhud-shape)` nowhere; the declarations live in the new
`duel/lisp/lhud-charset.lisp` (in the MANIFEST after lhud-battle.lisp; pure data, the macros return the string); (2) every non-ASCII
character in a string literal of `duel/web/hud.js` and `menu.js` (comments skipped), 400 characters: all go to the sans, the
non-CJK ones also to the mono and display faces when those carry them, and a character the sans lacks (the 闘 of 決闘) goes to the
Mincho; the bake exits with an error when a page character has no face and is not an `(lhud-shape)`. The per-face choice comes from the
CSS (`--f-*` of hud.css / menu.css): names, seals, the callout, crumbs and emblems are Mincho, labels and digits Latin, paragraphs sans;
sizes over 40 px (`+big-px+`) take the display tier, so only the big seals, emblems, finish words, the intro's name column, the menu's
mode kanji and the Latin display words are baked at 96 px. Display Latin is upper case only (the CSS upper-cases those; the Lisp side
upper-cases at draw).

| Face, tier | Glyphs | Texels (a glyph) |
|---|---|---|
| Big Shoulders Display, body | 100 | 66,037 (660) |
| Martian Mono, body | 100 | 82,645 (826) |
| Shippori Mincho B1, body | 152 | 209,339 (1,377) |
| Noto Sans TC, body | 473 | 602,045 (1,273) |
| Big Shoulders Display, display | 55 | 197,494 (3,591) |
| Shippori Mincho B1, display | 58 | 501,782 (8,651) |
| total | 938 | 1,659,342 |

Atlas 1024 × 2048 = 2,097,152 B (1,796 rows used, 88 %; gzip 804,069), metrics.bin 16,948 B. Two runs give byte-identical
`atlas.r8` and `metrics.bin` (sha256 compared). The bake takes 15 s. Licence files: the four `duel/FONT-LICENSE-*.txt` are the OFL.txt
of §8.4, unchanged; `duel/hud-font/README.md` lists the faces, sources, the OFL note and the rebake commands.

| What | Phase 0 (mini bake) | Phase 1a (full bake) |
|---|---|---|
| index.wasm | 11,570,734 B (gzip 3,339,769) | 12,694,617 B (gzip 4,001,406): +1,123,883 B, +661,637 gzip |
| startup heap | 74.3 MB | 73.3 MB (run to run noise; limit 110) |
| Extrapolation of §8.2 | | wasm data ≈ +1.3 MB, ≈ +0.65 MB gzip; measured +1.12 MB and +0.66 MB |

**The host test** `tests/duel-rules/lhud-charset.lisp` (a file of the duel-rules runner): reads metrics.bin and the sources as text
(an independent Lisp scan of the same strings) and fails, naming the face and character, when (a) ASCII 32-126 is missing from the
display, mono or sans body tiers, (b) a `kj` / `bigkj` / `big` character is missing from its own (face, tier), a `zh` one from the
sans and the Mincho, (c) a non-ASCII character of a script string is in neither the sans nor the Mincho and not an `lhud-shape`.
Proved to fail: a `(kj "鬱")` added without a rebake is reported and the run exits 1.

## 10. Phase 1b results (the paint stream's drawing power, 2026-11-11)

Opus 5.5 built it in a worktree from 9b3ee63a, in parallel with 1a (the bake) and 1c (text, tween, layout, input); the main session
reviews. The handheld portrait battle screen came first (the user's first complete screen, 2026-11-11).

### 10.1 What was built

| Where | What |
|---|---|
| engine/lisp/paint-shapes.lisp (new, after paint.lisp in engine/MANIFEST) | the shapes and drawing state of 10.2; phase 0's `paint-reset`, `paint-xform!`, `paint-clip!`, `paint-rect`, `paint-box!`, `paint-poly` moved here from paint.lisp (paint.lisp keeps the vertex macro, the pen and the text runs) |
| engine/shaders/hud.frag.wgsl | mode 0's analytic AA (three edge distances), mode 2's feather in screen pixels (the same at scale 1), mode 3 ellipse / ring / arc, the pattern lane (dots, stripes) |
| engine/c/render.c, engine.h, render.lisp, tools/simgate/stubs.c | blend mode 4 (premultiplied over) in `r_make_pipe`; `RP_COMP_AO` = slot 20 (fs_comp_a with blend 4); `r_frame` takes the back stream (two more arguments; an 8,192-vertex region, 512 KB). The back pass runs only on a transparent frame with back vertices; every other frame takes the old path unchanged |
| duel/lisp/lhud-battle.lisp | the plate only: the 20 clipped grid strips became one striped polygon; the fill's moving end is antialiased and its 45 % band split is not (no seam); the ghost is drawn only beyond the fill (two antialiased edges stacked showed a blood fringe). The bar ends and the combo slash get the AA with no change of their own |
| duel/lisp/lhud-shapes.lisp (new), debug 2509 | the test card (DUEL_GAMEPLAY "Debug commands"): twelve cells, one primitive or one handheld part each; 2509's third state draws a back-layer slab on a transparent frame |
| debug 2519 | now also measures the card: `shapes …` consing, ms and vertices |
| tests/paint-shapes-test.lisp | host checks of `path-points` (relative commands, numbers run together, arc sweeps, the soul flame) |

### 10.2 The primitives (API in docs/engine/ENGINE_API.md "Paint stream shapes")

| Primitive | API | Vertices |
|---|---|---|
| polygon, AA | `paint-clip!` (cut rect, vertical gradient, the cut's AA mask), `paint-grad!`, `paint-centre!`, `paint-poly pts n c0 c1`, `paint-rect` | 3 per point after the cut |
| linear gradient | `paint-clip!`'s GY0 GY1 or `paint-grad! x0 y0 x1 y1` (any axis, two stops; more stops = bands cut with no AA on the split) | (in the polygon) |
| radial gradient | `paint-radial! cx cy rx ry stops n` (stops `t r g b a`; the phone's ink pool) | 96 + 192 (n − 2) |
| patterns | `paint-dots! pitch radius` (screen halftone, glyphs too once 1c routes it), `paint-stripes! ox oy dx dy pitch width` (fixed to the shape: turns with it), `paint-pattern-off!` | 0 |
| rounded box, glow | `paint-box! cx cy hw hh radius feather border col` (feather in screen px: 1 = AA, more = a soft shadow) | 6 |
| ellipse / ring / arc | `paint-ellipse! cx cy rx ry col &key thick feather frac ccw` (arc from the top, butt ends; another start by the transform) | 6 |
| stroke | `paint-stroke! pts n width col &key frac round` (a rotated mode-2 box a segment: round or butt ends, square joints, a drawn fraction) | 6 a segment |
| SVG path | `path-points d &key segs` → f32vec (init time) | |
| transform / opacity / scissor stack | `paint-push`, `paint-pop`, `paint-transform! ox oy &key sx sy rot skew dx dy`, `paint-opacity! a`, `paint-scissor! x0 y0 x1 y1` | 0 |
| back layer | `with-paint-back` (into `*hud-back*`) | |
| text outline | in the shader since phase 0 (mode 1, p.w); the run must route a pen slot to p.w (1c's `%paint-run`) | |

### 10.3 The AA method and why

- **Polygons: analytic coverage, not a fringe strip.** The polygon is a fan from its centre; each triangle carries, per vertex, the
  signed distance to its own outer edge's line and to its two neighbours' lines (at convex corners), in local units. Distance to a
  line is affine, so the interpolation is exact, and the shader divides each by its screen gradient: the true distance in pixels
  under any transform (the phone's rotated plate, the stamp's scale). Coverage = clamp(nearest + 0.5). The outline is pushed out
  one screen pixel along the miters so the ramp's outer half has fragments. Why: 3 vertices a point against a fringe's
  3 (n − 2) + 6 n, exact under rotation and scale, and gradients and patterns stay per-vertex affine. The neighbour distances are
  needed: with the own edge only, a flat fan triangle's ray to a pushed-out corner ran up to a pixel above the next edge for about
  40 px (a one-row stub on the bar's top near the fill end), seen in the first stills and fixed.
- **Cut edges are antialiased per side** (the cut's mask): the fill's moving end yes, a gradient band split no, the scissor never.
- **Star-shaped polygons (`paint-centre!`) are drawn aliased**: near a reflex vertex the per-edge distances left pinholes inside
  the soul flame. The flame's outline is a stroke drawn over the fill, as hud.css does, so its edge is antialiased anyway.
- **Boxes, ellipses, strokes**: their distance fields in local units divided by the local units per pixel (the uv's screen
  Jacobian), so a feather is in screen pixels at any scale (exact for similarity transforms).
- **Patterns**: halftone dots on the screen grid with the CSS dots' soft pixel; stripes box-filtered over one pixel, their
  coordinate an affine function of the local position set per vertex (fixed to the shape, mirrored for P2, rotating with it).

### 10.4 Measurements

| What | Before (9b3ee63a, built in the same session) | After |
|---|---|---|
| Plate, ms a call (2519, wall clock, SwiftShader, desktop) | 0.141-0.148 | 0.050-0.054 |
| Whole draw (two plates and a combo) | 0.321-0.350 ms | 0.142-0.162 ms |
| Vertices: plate / combo / busiest frame | 252 / 144 / 666 | 156 / 150 / 486 |
| Consing (100 calls): plate, combo, draw, shapes card | 0, 0, 0 | 0, 0, 0, 0 (1280 × 720 and 390 × 844) |
| Shapes card (all twelve cells) | | 0.33-0.50 ms, about 2,400-2,550 vertices |
| index.wasm | 11,570,756 B | 11,625,416 B (+54,660) |
| Startup heap (`startup: heap`) | 74.3 MB (one run) | 73.3 MB (every run) |
| Startup, any renderer (nothing a frame) | | one more pipeline (RP_COMP_AO), a 512 KB f32vec, a 512 KB GPU vertex buffer, 512 KB more transfer buffer |

A find on the way: Lisp float arithmetic in a macro's inner `let` inside an initialiser consed 64 B a call (the box's pixel
size); it is a C one-liner now (`%paint-px`).

### 10.5 Proof

Stills (the worktree's `build/lhud/`, git-ignored): `s/desk-card-9.00.png`, `s/desk-card-back.png` (1280 × 720),
`s/mob-card-9.00.png`, `s/mob-card-back.png` (390 × 844, dpr 3); before / after zooms `cmp-desk-bar-z6.png` (both bars' ends, P2's
fill end and grid), `cmp-desk-slash-z4.png` (the combo slash), `cmp-mob-bar-z4.png` (the phone's P2 bar); the raw stills
`s/{base,desk,basemob,mob}-*.png`. Host tests ALL PASS (duel-rules 10149, control, learn, input, touch, cine, test-math,
paint-shapes-test); pkgcheck only `DUEL::APP`; debug-ranges-check 0 errors; smoke 8 s default and `hud=lisp` exit 0; G2
`simgate.py --cvc` and `style-gates.py cvc` identical (II 32, IK 34, KK 33). `tests/engine-check.sh`: 71 pass, 2 fail, the same two
(`%ui-poly4` 14,400 B / 100, `ui-rect` 4,800 B / 100: the RP_UI path) as 9b3ee63a's own run; not this change's. Not looked at in a
still: the low-Reishi red fill (the same code path as the paper fill).

### 10.6 Left out, and why

- CSS group opacity (render the group, then fade): opacity multiplies each primitive, so overlaps differ (a hard shadow shows
  through at .3); an offscreen pass if a screen shows it matters.
- Convex clip regions: the scissor is a rectangle (the reveals, the 爆 level); strokes and radial fans are not scissored.
- Dashed borders (the locked stance seal), paper grain, translucent stroke joints (the overlap darkens), multi-stop gradients in
  one call.
- Text halftone (TITLE 魂) and text outline: the shader side is done; the run must pass them into the glyph vertices (10.7; done at
  the merge, §12).

### 10.7 For 1c and the screen phases (the 1c items done at the merge, §12)

- 1c: in `%paint-run`, route a pen slot to the glyph vertices' p.w (the outline band) and copy `*paint-pat*` [0] [1] into q.x / q.w
  (dots); clip glyph quads to `*paint-sc*` (the callout's `hd-cut` reveal, the 爆 seal's second face inside its level).
- `paint-clip!` resets `paint-grad!` and `paint-centre!`: set those after it. `paint-reset` clears the stack, scissor and pattern:
  once an element, as phase 0 does.
- The back layer shows only on a transparent frame (`*render-transparent*`). `webui-sync` resets `*scene-transparent*` each frame
  while the page is there, so debug 2514 does not hold in a battle; the card sets `*render-transparent*` itself.
- Merge notes: paint.lisp lost its shape sections (moved, same meaning); its `*paint-pa*` / `*paint-pb*` scratch and
  `*paint-clip*` [4] [5] are unused now (left so the declaim line stays as it was); the package exports are a new block after
  phase 0's paint lines.

## 11. Phase 1c results (text layout, tweens, layout, input, the small-text weight; 2026-11-11)

Opus 5.5 built phase 1c in a worktree from main 9b3ee63a, beside 1a (the bake) and 1b (shapes); the main session reviews.

### 11.1 The small-text weight (the user, 2026-11-11: 「先加粗小字再看一次 (Recommended)」)

- The knob (engine/lisp/paint.lisp, the text section): text below `*text-small-css*` = 14 CSS px per em grows by `*text-small-bold*`
  = **0.06 device px** on each side of every stroke (an SDF edge shift: edge − 0.06 / size × the tier's SDF units per em, 4 for the
  body tier, 12 for the display tier), at full strength up to 14 px and fading out by 18 px; its ramp is `*text-small-soft*` = 1
  (unchanged). The shift is in device px, so at dpr 3 it is a third as much in CSS px.
- How it was chosen: the legibility card's rows against their HTML twin, the sum of each row's brightness above the panel (its ink),
  Lisp / Chrome, swept in steps of 0.025 px:

  | Row | dpr 1 before | dpr 1 after (0.06) | dpr 3 before | dpr 3 after (0.06) |
  |---|---|---|---|---|
  | mono .62u (7.9 / 5.7 CSS px) | 0.84 | 0.95 | 0.89 | 0.93 |
  | mono .72u | 0.88 | 0.95 | 0.91 | 0.95 |
  | mono 10 px | 0.93 | 1.00 | 0.97 | 0.99 |
  | sans 11 px | 0.90 | 1.01 | 0.96 | 1.00 |
  | sans 12 px | 0.91 | 1.03 | 0.96 | 1.00 |
  | sans .95u | 0.89 | 1.02 | 0.96 | 1.01 |
  | Mincho .95u | 0.92 | 1.04 | 0.92 | 0.98 |
  | Mincho 1.25u (16 px at 1280 × 720: half strength; 11.5 px on the phone) | 0.91 | 0.96 | 0.93 | 0.99 |

  0.05 brings the sans to 1.00 and leaves the mono at 0.93; 0.075 brings the mono to 0.97 and the sans to 1.05: Martian Mono is a
  little lighter than Chrome's at every size and dpr (a face difference, not a pixel one), so one knob splits the difference. The
  count of fully lit pixels already matches Chrome's for the mono and is 10-25 % higher for the sans and the Mincho at softness 1
  (Chrome's hinting blurs more), so the softness stays 1.
- Sheets for the user (build/lhud/, git-ignored): `1c-card-desk-small-z3.png` and `1c-card-mob-small.png` (the 8-12 px rows: HTML, phase 0, phase 1c
  stacked, ×3 at dpr 1); `1c-card-desk-small-options-z3.png` (the same rows at 0, 0.05, 0.10 and 0.15 px, to pick by eye);
  `1c-card-{desk,mob}-{before,after}.png` and `1c-card-{desk,mob}-small-{before,after}…png` ([HTML | Lisp | difference ×4],
  tests/lhud-compare.py); `1c-demo-{desk,mob}.png` (the phase 1c rows against their HTML twin); `1c-hover-dpr2-{para,clock}.png`
  (the hover frame at dpr 2: the mouse's density scaling); the raw stills in build/lhud/s/. The HTML twin (build/lhud/ref/index.html)
  gained the phase 1c rows with the same strings, faces, sizes and places.
- What still differs: the ink now matches within -7 % / +4 %, but Chrome's 8-10 px mono still looks darker and crisper: it hints stems onto
  whole pixels at full brightness, where the SDF spreads the same ink over two columns at partial brightness (no edge shift reproduces
  hinting). 0.10 px looks closer to Chrome's mono by eye but makes the sans and the dense Mincho heavier than Chrome's (ink 1.10); 0.15
  smears 鏡鍵鐮. The value is one number in paint.lisp for the user's call. At dpr 3 the two are hard to tell apart either way. The
  wrapped paragraph breaks exactly where Chrome breaks it at both sizes (「…就算按 / 下；…」 at 168 px, 「…就算 / 按下；…出 / 招。」 at 150 px:
  招 goes down with its 。), the vertical column and the turned K.O. land on Chrome's; the label row (月 · CLEAVER, ATK) sits 2-3 CSS px
  higher than Chrome's, which puts mixed faces on the strut's baseline, not the Mincho's line box (phase 2 places each element from
  its own CSS line box).

### 11.2 What was built

| Where | What |
|---|---|
| engine/lisp/layout.lisp (149 lines, plain CL) | `layout-frame!` (once a frame: window, density, the four safe-area insets) → `*lay*`; `lay-u` (hud.css `--u`, 2.36vw in portrait), `lay-css`, `lay-vw`, `lay-vh`, `lay-inset`, `lay-menu-form` (desk / narrow ≤ 760 / short ≤ 560); `css-clamp`, `lay-safe` (max(a, inset + b)), `lay-anchor`, `lay-mirror`, `lay-split!` (fr tracks with a gap), `lay-stack!` (one flex line with an alignment); `fl-floor` / `fl-round` / `fl-abs` (float → fixnum with no consing: ECL's FLOOR / ROUND / ABS of a float box; C under COMPILE-FILE, plain CL on the host); `wrap-lines` (greedy breaks: CJK between any two characters, Latin at spaces, kinsoku `*kinsoku-no-start*` 。，、；：？！）」』… and `*kinsoku-no-end*` （「『…, hanging spaces, newlines, an overflow cut) |
| engine/lisp/tween.lisp (184 lines, plain CL) | `ease` (the page's three cubic-béziers, CSS ease / ease-in / ease-in-out / ease-out, linear, steps(n); Newton, then bisection); `make-tween` (keyframes with per-keyframe curves, several properties, delay, iterations incl. infinite, direction, fill, base values); `tween-value`, `tween-progress`; `make-tween-slots`, `tween-restart`, `tween-watch` (restart on a changed serial; the first serial seen only records it, as hud.js); `make-transitions`, `trans-to` (retarget from where it is, delay, DUR 0 snaps), `trans-value`; `*reduced-motion*` (animations at their end state or base, transitions at their target). NOW is the caller's: the UI clock is advanced by `hud-draw` once a frame (phase 0), so debug 2519's 100 calls do not move it. (Named `tween-*` because anim.lisp owns `make-anim` / `anim-*`.) |
| engine/lisp/text.lisp (171 lines) | `line-baseline` (the CSS line box's baseline), `paint-text-aligned` (:start / :center / :end), `paint-int-tab` / `paint-measure-int-tab` (tabular figures, zero padding, no string), `paint-paragraph` (wrapped at a width in px, line-height, alignment; its breaks cached in `text-layout` per EQ string, face, width and spacing), `paint-vertical` / `paint-measure-vertical` (vertical-rl: CJK upright an em apart, other characters turned 90° clockwise, the em box centred on the column). Mixed faces on one baseline = the pen through `paint-text` once per face (a face's missing glyph falls back on the same baseline, as before) |
| engine/lisp/hot.lisp (66 lines) | `hot-begin-frame`, `hot-add` (a rectangle through the current paint transform, stored as its quad), `hot-hit` (the topmost of last frame's boxes; -1), `hot-focus-step` (drawing order, wrapping) |
| engine/lisp/paint.lisp (text section only) | `%paint-run` takes a character range (the paragraph's lines); `with-small-text` / `glyph-edge` (the small-text weight above, used by runs and columns); `*glyph-dscale*` (SDF units per em by tier, from metrics.bin) |
| engine/c/platform.c, engine/lisp/platform.lisp | `mouse-x` / `mouse-y`: the last absolute mouse position from SDL's motion and button events times the pixel density, in `*input*` lanes 13 / 14 (15 floats now). §4.5's `pf_mouse_xy` became these two lanes: no new C entry point, engine.h untouched |
| duel/web/pwa.js | page get 5 / 6 the left / right safe-area insets (CSS px; `testInsets` takes four values now), get 7 `prefers-reduced-motion` (one MediaQueryList); get 8 stays the renderer flag of phase 0, so §4.5's numbering holds |
| duel/lisp/lhud-battle.lisp | `lhud-frame` (under :lisp, once a frame: `layout-frame!` with the four insets, the page asked again only when the window's size changed, `*reduced-motion*`, `hot-begin-frame`); `lhud-card-demo`: the card's phase 1c rows (debug 2518), beside the card on a desktop, under it in portrait: a wrapped paragraph (11 px sans), a kanji + spaced mono label end-aligned with ATK spaced .3em (the handheld screen's 「拖 · DRAG」 / SP 技 pattern), a 4.3u tabular clock that pops with hd-stamp at each new second (`tween-watch`), PAUSE spaced .3em, a vertical column 月牙天衝 + K.O. turned, and a stone frame on whichever of them the mouse is over. Only characters the phase 0 bake has (1a owns the bake) |
| duel/lisp/debug.lisp | debug 2519 prints a second line: the frame's and the demo's consing, the demo's time and vertices |
| tests/hud-engine-test.lisp | 121 host checks: units at 1280 × 720, 1920 × 1080, 2560 × 1080 and 390 × 844 dpr 3 with a notch; clamp (incl. MIN > MAX); safe-area anchors; splits; stacks; the mirror; the menus' form; eleven wrap / kinsoku cases; the easings against CSS's values (ease .5 → .8024 …, the page's three, steps); keyframes (hd-stamp, a delay with fill both, an infinite alternate flame with a negative delay, per-keyframe steps(1), an even alternate count ending at 0, reduced motion); restart on a serial; transitions (the Reishi ghost's delay and drain, a snap, a retarget mid-way, reduced motion); hot boxes (overlap order, last frame only, a rotated box, the focus order). `$ECL_HOST --norc --load tests/hud-engine-test.lisp` |

### 11.3 Measurements

| What | Result |
|---|---|
| Consing (debug 2519, `--fixed-dt`, 1280 × 720 and 390 × 844 dpr 3) | plate 0, combo 0, the whole draw 0 B (still mode off); `lhud-frame` 0 B, the card's phase 1c rows 0 B (330 vertices). With still mode on the draw shows 1,304 B a call: phase 0's legibility card (a debug still: a list walk with double floats), unchanged |
| Lisp time (wall clock, SwiftShader, desktop) | plate 0.136 ms (phase 0: 0.136, so the small-text weight costs nothing measurable), combo 0.038, the phase 1c rows 0.039 ms (a 2-line paragraph, the labels, the clock, a 5-glyph column, 4 hot boxes) |
| index.wasm | 11,570,734 → 11,629,153 B (+58,419: the four engine files, the card's rows, the probe) |
| Startup heap | 73.4 MB, unchanged |
| G2 | native and browser identical: II 32, IK 34, KK 33 lines |
| Host tests | duel-rules 10149 ALL PASS, control, learn, input, touch, cine, ecs, math pass; hud-engine-test 121 ALL PASS |
| pkgcheck | only `DUEL::APP` |
| Smoke | 8 s default and `--query hud=lisp`: exit 0 |

### 11.4 Left out, and why

- **A per-glyph run cache.** Single-line runs still look each glyph up (a binary search over the glyph keys) every frame; only the
  paragraphs' line breaks are cached. The cost is in the measurements above (the demo's ms); a cached glyph-index vector per string is
  the upgrade if phase 2's full battle HUD shows it.
- **The paragraph cache is keyed by the string alone** (one entry per EQ string, remade when the face, width or spacing changes): one
  string object drawn at two widths in the same frame would lay out twice a frame. No screen does that; key on the parameters too if
  one does.
- **Hot boxes are quads** (rectangles through the transform). The 爆 dial's circle and the deck's slanted zones would hit by their
  bounding quads; a circle / polygon hit is phase 4's (the deck taps go through the touch recogniser anyway).
- **Not wired to the menus or the battle commands**: the registry and the pointer exist; feeding hits into `webui-commands` /
  `webhud-commands` is §4.5's dispatcher split, phase 2 / 5 work. Keys / pads already move the model's cursors.
- **No new glyphs**: the bake is 1a's; the demo uses the phase 0 card's characters (so 「拖 · DRAG」 is shown as 「月 · CLEAVER」).
  Since the merge the card shows the real seals (§12).
- **Ellipsis** (`text-overflow`), `text-wrap: balance` (MODE's heading) and hyphenation: not built (no battle element needs them; §1
  allows a hard cut).
- **Reduced motion is read when the window's size changes**, not live; a change of the OS setting mid-game shows after a resize or a
  reload.
- **What 1b's paint.lisp must keep** (done at the merge, §12): `text.lisp`'s vertical columns emit their quads through `with-hud-verts` / `hvtx` with phase 0's
  16-value vertex (mode 1, edge, softness); if 1b changes that macro (a clip stack, a new lane), the vertical path follows it. The
  small-text weight lives in the text section (`with-small-text`, `glyph-edge`) and needs no shader change. `paint-box!` binds a
  plain `b` around its argument forms, so a caller's variable named `b` is captured (it boxed floats in the card until renamed): a
  gensym there is 1b's to make.

## 12. The phase 1 merge (2026-11-11)

Opus 5.5 merged the three worktrees (1a, 1b, 1c, each from 9b3ee63a) into one tree and made the follow-ups their authors left for
each other; the main session reviews. No behaviour of the default (`:html`) renderer changed.

### 12.1 Conflicts and how each was resolved

| File | Resolution |
|---|---|
| duel/MANIFEST | both new files after lhud-battle.lisp: lhud-charset.lisp (1a), then lhud-shapes.lisp (1b) |
| engine/MANIFEST | paint.lisp, paint-shapes.lisp (1b), then layout, tween, text, hot (1c) |
| engine/lisp/package.lisp | both export blocks kept (1b's shapes, 1c's layout / tween / text / hot); `ease-curve` removed |
| engine/lisp/paint.lisp | merged cleanly (1b took the shape sections out, 1c changed the text section); then the follow-ups below |
| duel/lisp/debug.lisp (2519) | one probe: k 0-3 plate, combo, draw, 2509's shapes card (1b's line, the back stream reset too), k 4 2518's phase 1c rows (1c's second line) |
| DUEL_LISP_HUD.md | 1a's results §9, 1b's §10 (its 9.x renumbered), 1c's §11 (was unnumbered); every "Phase N results" reference in docs and code now names the § |
| ENGINE_API.md | both new sections, 1b's then 1c's, plus a text-runs bullet (the merge's facts) |
| DUEL_GAMEPLAY.md | 2518 and 2519 rows merged (2519 lists the shapes card and the 1c line) |

### 12.2 The follow-ups

- **Glyph quads** (1b → 1c): one emitter `%glyph-quad` (paint.lisp) for runs, paragraphs and vertical columns (upright and turned):
  the quad is cut to the scissor `*paint-sc*` with its uv following the cut, the pen's new slot [8] (`paint-pen! … :outline`) goes
  to p.w (the shader's outline band), `*paint-pat*` [0] / [1] to q.x / q.w when it is a dot pattern (stripes stay the polygons'). The
  transform and opacity stack applied already (`with-hud-verts` reads `*paint-xf*`). `*paint-sc*` and `*paint-pat*` moved from
  paint-shapes.lisp to paint.lisp, which loads first. ponytail: with a skew the cut is made on the upright cell.
- **Variable capture** (1c → 1b): `%f32-set` (paint.lisp) stores a macro's floats through a gensym; `paint-pen!`, `paint-box!`,
  `paint-ellipse!`, `paint-stroke!`, `paint-radial!`, `paint-clip!`, `paint-grad!`, `paint-centre!`, `paint-scissor!`, `paint-dots!`,
  `paint-stripes!`, `paint-transform!`, `paint-paragraph` use it; `paint-xform!`, `paint-opacity!` and `paint-rect` bind gensyms.
- **One easing** (1c): phase 0's `ease-curve` and `*ease-pts*` removed; lhud-battle.lisp calls tween.lisp's `ease` (the same five
  curves at the same numbers; Newton 8 steps with a bisection fallback instead of 6 steps).
- **The display tier's upper case** (1a): `glyph-find` looks a-z up as A-Z in the display face's display tier (no string made; the
  body tier keeps lower case), checked in tests/paint-shapes-test.lisp.
- **The real handheld labels** on 2518's phase 1c rows: Kenpachi's three pointer seals 「拖 · DRAG」 「肩 · SHOULDER」 「構 · CHUDAN」
  (hud.js FIGHTERS), Mincho kanji + spaced mono, end-aligned.
- hud-screens.lisp declares `*hud-renderer*` special (phase 0's build warning).
- debug 2519's merged probe: the merge's rewrite had `ms` call `one` inside a `flet` (1b's `ms` repeated the body instead), which
  stopped the game with "ONE is undefined" at the first probe; caught by the probe run (it printed no lines), fixed with `labels`
  (pkgcheck does not see local functions).

### 12.3 Measurements and proof

| What | Result |
|---|---|
| index.wasm | 12,810,716 B (gzip -9 4,033,812): 9b3ee63a 11,570,734 + 1a 1,123,883 + 1b 54,660 + 1c 58,419 = 12,807,696, the merge +3,020 (the glyph quad's cut, the seal rows) |
| Startup heap | 73.3 MB or 87.4 MB depending on the build, not on the code: three builds of nearly the same tree read 87.4, 73.3 (after a one-line declaim change), 87.4 (after `flet` → `labels` in a debug probe), each the same in every run; 1a+1b alone (45270c67) 73.4, each phase alone 73.3-73.4. The frames' consing is identical in the 73.3 and 87.4 builds (cons/frame 1422, 1232, 1230, 1240 B at the same ticks), so the flip is not the code's: the startup line is Boehm's heap size, which moves in growth steps of about 14 MB with where the startup collections fall. Under the 110 MB limit either way; a used-bytes line would make this readable |
| Consing (debug 2519, `--fixed-dt`, P1's combo forced mid-stamp; 1280 × 720 and 390 × 844 dpr 3) | plate 0, combo 0, whole draw 0, 2509's shapes card 0, `lhud-frame` 0, 2518's phase 1c rows 0 B a call |
| Lisp time (wall clock, SwiftShader, desktop) | plate 0.050-0.052 ms, combo 0.039-0.043, whole draw 0.146-0.154, the shapes card 0.329-0.337, the phase 1c rows 0.053-0.057 (1c alone 0.039 with one label row; now three seal rows) |
| Vertices | plate 156, combo 150, the busiest frame 486 (phone 330), the shapes card 2,379-2,553, the phase 1c rows 420 |
| Host tests | duel-rules 10153 (10149 + 1a's charset file), hud-engine-test 121, paint-shapes-test (with the upper-case check), input 33, touch 100, cine 18, control 100, learn 131: all pass |
| pkgcheck / debug-ranges-check | only `DUEL::APP` / 112 ranges, 0 errors |
| Smoke | 8 s default and `--query hud=lisp`: exit 0 |
| G2 | native `simgate.py --cvc` and browser `style-gates.py cvc`: II 32, IK 34, KK 33, identical |

Stills (the worktree's `build/lhud/`, git-ignored; scenes with 1b's and 1c's own timings, `build/lhud/gen.py`, `runall.sh`):
`s/{desk,mob}-2509.png`, `s/{desk,mob}-2509-back.png` (2509's card and its back layer), `s/{desk,mob}-2518.png`,
`s/{desk,mob}-2518-pop.png` (2518: the legibility card and the phase 1c rows with the real seals), `desk-2518-seals-z3.png`;
plates and combo `s/{desk,mob,deskhtml,mobhtml}-{10.95,11.50,13.60}.png`. Comparisons (tests/lhud-compare.py, [before | after |
difference ×4]): `cmp-vs0-{desk,mob}-{10.95,11.50,13.60}.png` (phase 0's own Lisp stills, 9b3ee63a, from 1b's worktree | the
merge's: desktop mean 0.23-0.25, max 111, only the bars' edges and grid (1b's AA and striped polygon) and the small kanji's weight
(1c); phone mean 0.11, the same plus P2's name from 1a's display tier); `cmp-html-lisp-desk-11.50.png` (HTML | Lisp, the plates and combo); `cmp-vs1b-desk-{10.95,11.50,13.60}.png`
(1b's Lisp | the merge's: mean 0.00, max 24, only the small kanji's weight from 1c), `cmp-vs1b-mob-11.50-full.png` (the phone's
P2 name now from 1a's display tier, the kanji's weight; the scene's own render noise on the fighter), `cmp-vs1b-2509-desk.png`
(the card: the label text's weight and the time-driven cells (the dial's level, the stroke's fraction, the reveal) a frame apart),
`cmp-vs1c-2518-{desk,mob}.png` (1c's | the merge's: the seal rows and the clock moved down by them, the bars' AA from 1b; the
upright and turned vertical column are pixel-identical).

## 13. Phase 2 results (the handheld portrait battle screen, 2026-11-11)

Opus 5.5 built it in a worktree from main da9eec7b (the user, 2026-11-11: 「手持直向畫面優先重現 (Recommended)」, §7 Q5); the main session
reviews. Under `?hud=lisp` (or debug 2517) the phone's portrait battle screen is drawn whole by Lisp, right and left hand; the default
renderer (`:html`) is unchanged.

### 13.1 What was built (one job a file; each element a system and a view)

| File (lines) | Job |
|---|---|
| duel/lisp/lhud-data.lisp (98) | hud.js's tables as plain CL: FIGHTERS (`*lhud-fighters*`: names, plate kanji, pointer seals by form and form + tag), MOVES (`*lhud-moves*`), tagHTML (`lhud-tag-segments`: form · 風死 · IN HAND / 分身 · ×N, the jade dots), the kit kind; the string tags `kj` / `zh` / `big` moved here. Host-tested |
| duel/lisp/lhud-geom.lisp (45) | pure geometry from the model's permille numbers: `lhud-deck-line!` (the deck rect, the line's far point, length and your plate's rotation, hud.js renderDeck), `lhud-seal-ring!` (the stance seals at 304 / 270 / 236 / 202° × the hand), `lhud-deck-bottom` (hud.css `--deck`). Plain CL (sin / cos / atan / sqrt are C under COMPILE-FILE, CL on the host), host-tested |
| duel/lisp/lhud-model.lisp (113) | the model's accessors (`hv`, `hs`, `side-o`, `hv-deck-p` …), the per-side derived strings (`*lhud-side*`, refreshed by `lhud-model-update` only when a model string changes: EQ), the layers' fade slots, the palette, the SVG shapes (soul flame, ∞) flattened at load, small helpers (`row-h`: a baseline-aligned flex row's height and baseline, `text-w`, `col-mix`, `twv`) |
| duel/lisp/lhud-plate.lisp (376) | the plates: `lhud-plate-update` (system: ghost drain, fill cut, each flame's fade / dot / shatter, hd-stake's start, the meters, the seals' on), row views `lhud-name-row`, `lhud-bar`, `lhud-souls`, `lhud-meters`, `lhud-seal` / `lhud-seal-row`, `lhud-kit` (KAIHO / UDE pips), the grids `lhud-plate` (the phone's P2 with its ink pool; the phone's P1 without the deck; desktop plates) and `lhud-plate-line` (your plate on the deck's line, rotated about its far point) |
| duel/lisp/lhud-deck.lisp (305) | `lhud-deck-update` (system: V4's edges → hd-arm, hd-deny, hd-dip, hd-awfill, hd-kak, the press words; the level, armed, the arcs, the stance seals' on, pressed, the ∞'s hd-write), views `lhud-deck` (paper, dot screen, SP 技 / ATK 斬), `lhud-clock` (the clock tab = the pause chip: digits / ∞, II 止 PAUSE, the last ten in blood), `lhud-dial` + `lhud-face` (爆: rim, ink level as a gradient circle polygon cut at the level, both faces with their ticks, the awakening / SUBLIMATION / DRIVE / hold rings, the glows, 覺), `lhud-ring` (the stance seals around 爆 and the live one's name) |
| duel/lisp/lhud-fx.lisp (358) | `lhud-layers-update` (system: .hudl .3 paused / 0 in a cinematic, the deck and 爆 out, the clock tab out paused, the canvas grade), the combo (`lhud-combo-update` / `lhud-combo`, phase 0's moved and split, anchored on the deck from the model), the move name (`lhud-callout-update` / `lhud-callout`, hd-cut through the scissor), the prompt (`lhud-prompt-update` / `lhud-prompt`, the Kikon ring), the touch ink (`lhud-fx-update`: a fixed ring of 12 slots fed by V5's serial; `lhud-fx`: ripples, brush trails with the elliptical end, words, the hold ring) |
| duel/lisp/lhud-battle.lisp (191) | `lhud-frame`, `lhud-systems` (every system once a frame, before any view), `lhud-draw` (the views back to front as hud.css stacks them: deck z 9, .hudl z 10, 爆 / ring z 14, ink z 15), the atlas's load step, debug 2518's card |
| duel/lisp/webhud.lisp | §4.6's split: `webhud-page-p` (the page has hud.js), `page-draws-p` (renderer :html and the page: send values, read the pause queue), `canvas-hud-off-p` (:html with the page, or :lisp: the canvas HUD leaves the battle screens out, the model runs); `webhud-p` is gone |
| duel/lisp/debug.lisp | 2505 / 2506 / 2507 (the scenes, the hand), 2508 (P2 Kenpachi's next form), 2440+k (the states), 2519's phase 2 line (DUEL_GAMEPLAY "Debug commands") |
| engine/lisp/paint-shapes.lisp | `paint-ellipse!`'s `:ccw` decided when it runs: a form (the left hand) was taken as true at expansion, so every arc drawn with `:ccw <form>` ran counter-clockwise (found by the awakened scene; ENGINE_API) |
| tools/run.mjs | `--freeze-css` (with `--fixed-dt`): every CSS animation and transition is paused when first seen and its currentTime set from the virtual clock each frame; the page's timers of 100 ms or more fire by the virtual clock too (§8.3's request). Default behaviour unchanged |

**The predicate split, callers** (§4.6, with one deviation). `canvas-hud-off-p`: `webhud-sync` (the model), `hud-battle`'s early return
and the world callout (hud.lisp), `hud-deck`'s reduced drawing (onehand.lisp). `page-draws-p`: `webhud-commands` (the page's pause
queue), and, **interim until phase 4**, the screens the Lisp HUD does not draw yet: the canvas pause overlay (hud-screens.lisp), the
intro / K.O. / TIME letterbox and caption and the slice-out (hud-screens.lisp), the intro's FIGHT! word (cinema.lisp). So under :lisp the
canvas draws those in their old look and the build is playable end to end; §4.6 puts them under `canvas-hud-off-p`, which phase 4
does when it draws them. The menus keep `webui-p`: they are the page's under either battle renderer until phase 5. Under :html
every caller answers as `webhud-p` did; with no page (the native gate) both are NIL (G2 identical).

**The principles (§4.8)**. Views read only the model (`*hud-sent*` / `*hud-strs*`), their own component state and the UI clock; no
view reads the sim or another element's state, except the shared layer fades (`layer-op`, one slot vector read by every view of a
layer, as CSS opacity inherits). State: fixed component vectors per element (transition slots of tween.lisp, animation starts,
serials seen), mutated only in the `…-update` systems (`lhud-systems`). Floats cross calls through one lane (`lane!`, `*lhud-a*`) and
the pen, as phase 0's paint calls do. Each view does `paint-reset` (or push / pop) before it draws. Exceptions, named: (1)
`lhud-layers-update` writes `*grade-desat*` (the engine's composite grade, which draw.lisp zeroes every non-cinematic frame and a
cinematic owns; the HUD writes it only paused and not in a cinematic); (2) `col-mix` / `with-col` return a shared scratch colour
(read at once; the dial copies the first before the second); (3) the pure geometry is host-tested, the views are checked by stills.

### 13.2 What it draws, and what it reads

| Element | hud.css / hud.js | Model |
|---|---|---|
| P2's plate: ink pool, name / kanji / tag, bar with ghost and grid, nine flames (flicker, stake, shatter, spent dot), flash-step cells and awakening bar (SUBLIMATION pink, DRIVE red, hd-aw), 覺醒 READY label, pointer seals 構 肩 拖 + 「拖 · DRAG」, kit strip | .plate, .who, .reishi, .souls, .meters, .awk, .hptr, .kit | V o+0..25 (25: a BLUE burst's burn left ‰ of the flash step, 0 otherwise: the cells tint that span in `+c-burst-b+`, `lhud-cell-burn`), S 4s, 4s+1 |
| Your plate on the line (both hands) | #hud.hphone:not(.nodeck) .plate.p1, renderDeck | V30-35, V42, V o+… |
| Deck paper, dots, SP 技 / ATK 斬 | .deck, .zl | V30-35, V43, V42 |
| Clock tab: ∞ (hd-write) or the seconds (the last ten blood, hd-tick), II 止 PAUSE, out when paused | .clock (phone) | V1, V0 16, V39 / V40 |
| 爆: rim, ink level, ticks, armed (white ink, blood rim, glow), Burst colours (a BLUE burst: only the burning span of the level is blue, `lhud-dial-band`, V75), awakening / SUBLIMATION / DRIVE / hold rings, ready (breath, glow, 覺 hd-kak), pressed .9, hd-arm, hd-deny + NO BURST, hd-dip, BURST / 覺醒 AWAKEN words | .dbtn.rv, renderDeck | V4, V36-38, V56, V57, V72, V73 |
| Stance seals around 爆, the live one's name (the CSS's displaced-on quirk reproduced: rotate / scale about the 0 × 0 box's corner) | .rvc | V59, V74, S 0 |
| Combo (stamp, slash) and move name (hd-cut) over the deck; P2's under its plate; the left hand swaps | .combo, .callout | V o+10..14, S 4s+2 |
| Prompt over the deck (Hold SP + the Kikon ring, SP · AS n, Chain / Burst; Awaken left to 覺) | .prompt | V2, V3, S 9 |
| Touch ink: ripple, trail, gesture words, the hold ring | .fx, renderTouch | V5-13 |
| Paused: .hudl .3, deck / 爆 / ring / clock tab out, the canvas greyed | #hud.paused, body.hud-paused | V0 4 |

### 13.3 What differs from the HTML, and why

- **The pause strip, intro card, READY / 斬, finish are not drawn** (phase 4): under :lisp the canvas draws its old pause menu (with its
  own .55 ink rect over the greyed scene), letterbox, caption and FIGHT!. The Lisp HUD greys the canvas (`*grade-desat*` .9) and fades
  itself to .3; the canvas's brightness / contrast are the old overlay's rect, without the .5 s transition.
- **Glows and drop shadows** are feathered shapes (§2.4): 爆's armed / ready glows, hd-awbreath, hd-aw's bar glow, hd-shatter's blood
  glow, the clock and ∞'s hard shadows as offset copies (the ∞'s shadow darkens where its translucent segments overlap).
- **Dashed borders** (a sealed pointer) are drawn solid at .35 (§10.6). NOME's cups are not drawn (no current kit publishes NOME).
- **The dot screen's phase**: the shader's dots sit on the screen grid; the CSS dots on the deck box's grid (a few px apart in y).
- **Text**: SDF glyphs with the small-text weight; the zone labels, seal names and tags match by eye; the `.awk` label is placed where
  Chrome puts it (`left: 100%` even for the rtl P2: off the plate to the right, as the HTML does).
- **Timing**: the HTML reacts in its own next rAF, so starts can be one frame apart (the advisor's note; also seen between two HTML
  runs with `--freeze-css`: §13.5).
- **A Burst's first frame**: the HTML's level shows no colour for a frame or two after a Burst starts (`var(--bc)` is set in the same
  render that adds `.bursting`); the Lisp ink takes the Burst's colour at once (`cmp-burst-10.080`; the sheet's large mean difference
  is the scene's own impact flash caught a frame apart).
- **Not reached by the scripts**: Kenpachi's kit strip as P1 on the line (only P2's: `ken-shikai`), a running Burst's coloured ink
  after its first frames, the phone without the deck (two hands in portrait), the desktop (phase 3).

### 13.4 Measurements

| What | Result |
|---|---|
| Consing (debug 2519, `--fixed-dt`, 390 × 844 dpr 3 and 1280 × 720; the busiest frame forced) | every entry 0 B a call: plate, combo, the whole draw, 2509's card, the frame, 2518's rows, the systems, your plate on the line, the deck, 爆, the stance ring, the clock tab, the touch ink, the move name, the prompt. Found on the way (all fixed): a parallel `let` of floats boxed its initial values (`let*` everywhere now), a float argument to a function boxed it (`col-mix` is a macro now), and `(* k (tween-value …))` went through generic math (`twv` declares the type) |
| Lisp time (2519 in a wall-clock run, `--mobile --size 390x844`, SwiftShader; other sessions' Chromes were running) | the whole draw 1.32 ms a frame (phase 1: 0.15 for two name rows, two bars and a combo); P2's plate 0.50, your plate on the line 0.39 (most of each is its nine flames: fill + stroke), the systems 0.08, 爆 0.10, the clock tab 0.09, the deck 0.03, the ring 0.03, the ink 0.03, the prompt 0.02, the move name 0.015 |
| Vertices (phone, PRACTICE, both full) | the whole frame 4,548 (of 32,768): P2's plate 1,884, your plate 1,410, the clock tab 501, 爆 237, the ring 168, the combo 150, the prompt 102, the move name 96, the deck 78. A flame is 15 points (fill 45 vertices + a round-capped stroke 90); at 25 points (5 segments a curve) the plates were 2,694 / 2,220 |
| index.wasm | 12,810,716 → 12,907,695 B (+96,979: ≈ 1,250 lines of game Lisp); gzip -9 4,033,813 → 4,061,215 |
| Startup heap | 73.3 MB (unchanged; limit 110) |
| Default renderer | `:html` draws nothing new (`lhud-draw` runs only under `:lisp`); the model and the page protocol are unchanged |

### 13.5 Proof

Scenes (the worktree's `build/lhud/p2/`, git-ignored; `gen.py` writes one `run.mjs` script per scene, run twice, HTML and
`?hud=lisp`, with `--fixed-dt 16.666667 --freeze-css --mobile`; `runall.sh` runs them; `sheets.py` makes the sheets with
tests/lhud-compare.py). Every state is reached by debug commands and scripted touches (2505 / 2506 + 2440+k; ATK taps under the line,
SP taps over it, a held thumb, a flick, taps on 爆 and on the clock tab), never by a CPU. 390 × 844 dpr 3 unless named; 453 × 823 for the
user's screenshot (`neutral-453`, `left-453`, `combo-453`).

| Sheet ([HTML \| Lisp \| difference × 4]) | What it shows |
|---|---|
| `cmp-neutral-453-10.000.png`, `cmp-neutral-390-10.000.png` | the user's screenshot's state (PRACTICE, both full, pointer 1); mean difference 2.1-2.9 of 255, mostly the scene and the dot screen's phase |
| `cmp-left-10.000.png`, `cmp-left-453-10.000.png`, `cmp-left-ptr2-10.000.png` | the left hand: your plate from the right edge, 爆 and the ring mirrored, the zone labels swapped |
| `cmp-ptr2-10.000.png`, `cmp-ptr3-10.000.png` (and neutral = 1) | the stance picker's three states, P2's seals and yours around 爆 (the displaced on seal) |
| `cmp-low-10.000.png`, `-10.550.png` | Reishi 15 %: the red fills (hd-pulse), P1's six flames and three spent dots |
| `cmp-spent-10.000.png`, `cmp-half-10.000.png` | 爆 empty / half (no arming, the ticks) |
| `cmp-ready-{9.100,9.200,10.000}.png` | the awakening ready: 覺 (hd-kak), the breathing ring, the reiatsu glow, P2's 覺醒 READY (off the plate, as the HTML) |
| `cmp-awakened-10.000.png`, `cmp-sublim-10.000.png` | DRIVE 60 (red arc), SUBLIMATION 60 (pink), KESSA's tag 「KESSA · 分身 · ×0」 |
| `cmp-vscpu-10.000.png`, `cmp-clockend-{10.000,10.600}.png` | the clock tab with digits; the last ten in blood, hd-tick's dim half |
| `cmp-combo-*.png`, `cmp-combo-453-*.png`, `cmp-as-*.png`, `cmp-sp-*.png` | combos over the deck, the move name 落牙 RAKUGA, the prompt (Chain, SP · AS1), ripples and words |
| `cmp-hold-*.png` | the Kikon's hold: HOLD SP / KIKON · 毀魂 nF with its ring, the hold ring under the thumb |
| `cmp-ken-shikai-10.000.png`, `cmp-ken-kyoran-10.000.png`, `cmp-ken-zankai-10.000.png` (and their `z-…-p2`) | P2 Kenpachi's forms by 2508: the Shikai's seals 旋 墜, its KAIHO strip (解, L2), the form tag; the Bankai's one seal 狂 / 壞 and 「狂嵐 · KYORAN」 / 「斬壞 · ZANKAI」 |
| `cmp-flick-*.png`, `cmp-burst-*.png`, `cmp-paused-*.png` | a Hoho flick (trail, HOHO, 爆's dip and the ink a third lower); 爆 pressed full (BURST); paused (.3, greyed; the canvas pause rows: phase 4) |
| `z-<scene>-<t>-{p2,line,dial,tab}.png` | the same pairs cropped at the native 3 × (dpr 3): P2's plate, your plate on the line, 爆 and its ring, the clock tab |
| `strip-stamp.png`, `strip-ink.png`, `strip-deny.png`, `strip-cut.png` | animation strips, HTML over Lisp, 2 or 4 frames apart: the combo's hd-stamp, a tap's ripple and ATK word, hd-deny + NO BURST, the move name's hd-cut |

Read by eye: layout, palette, type and the named animations read as the same design; the animation strips agree within a frame or two
(the HTML reacts in its next rAF). The HTML frames of `strip-cut` show the move name already revealed (its hd-cut and fade were not
held by `--freeze-css` there; compare that one to the CSS numbers). Between two HTML runs with `--freeze-css` (the base build), two of
three stills were byte-identical and the third differed only in the combo's entry transition, a frame apart. **The default renderer is
unchanged**: the same script on the base build and on this one (`:html`): in the HUD's bands (the top 700 and the deck's 980 device px)
the stills at 10.72 and 11.50 s are identical; at 10.12 s only 爆's glow differs (its `box-shadow` transition, a frame apart); the rest of
the differences are the scene (REFACTOR_2026-11.md §10.2).

Checks: host tests duel-rules 10190 (with tests/duel-rules/lhud-geom.lisp: the tables and the geometry against hud.js's numbers),
hud-engine 121, paint-shapes, touch 100, input 33, control 100, cine 18, learn 131: all pass; pkgcheck only `DUEL::APP`;
debug-ranges-check 115 ranges, 0 errors; G2 native `simgate.py --cvc` (on the final sources) and browser `style-gates.py cvc`: II 32, IK 34, KK 33, identical;
smoke 8 s, default and `?hud=lisp`, 1280 × 720 and 390 × 844: exit 0, no "stopped"; under `?hud=lisp` the HTML menus still work
(Enter from TITLE to a battle).

### 13.6 Left for the next phases

- Phase 3 (landscape): the desktop clock, prompt key caps, callouts and the plates' desktop specifics (the code draws the desktop
  plates with the same row views; unreviewed).
- Phase 4: the pause strip (hot boxes, 止's hd-fromtab), intro, READY / 斬, finish; then the interim `page-draws-p` callers move to
  `canvas-hud-off-p`.
- `--freeze-css`'s one-frame nondeterminism (which callback order makes it is not found), and its miss on the move name's hd-cut.
- Performance: the whole HUD is 1.32 ms a frame on SwiftShader (phase 0's target was under 1 ms), most of it the 18 soul flames (a fill
  and a round-capped stroke each, ~135 vertices). The upgrade if it matters on phones: the flame baked once into the atlas as an SDF
  shape (fill + outline band from one cell: 6 vertices a flame), or one cached vertex block per flame state.
- The pause strip's own dimming: under :lisp the canvas fallback draws its .55 ink rect in RP_UI (under the paint stream), so the Lisp
  HUD draws no dim rect of its own yet (it would cover the fallback's rows).

(Phases 3-4 closed the phase 3 / 4 items above, the flames' cost and the pause's dimming: §14.)

## 14. Phases 3-4 results (the landscape battle screen and the overlays, 2026-11-11)

Opus 5.5 built them in a worktree from main d337a824, in parallel with the menus (phase 5, §15); the main session reviews. Under `?hud=lisp`
(or debug 2517) a whole battle is now drawn by Lisp at every size: the desktop / landscape screen (phase 3) and the pause, the intro
card, READY / 斬 and the finish (phase 4), in landscape and portrait. The interim `page-draws-p` callers of §13.1 moved to
`canvas-hud-off-p` as §4.6 designed, so under `:lisp` nothing of the old canvas HUD draws in a battle. The default renderer (`:html`) is
unchanged.

### 14.1 What was built

| File (lines) | Job |
|---|---|
| duel/lisp/lhud-clock.lisp (new, 105) | the clock, moved out of lhud-deck.lisp and completed: the desktop / landscape grid at the top centre (`max(1.6u, st + .6u)`: the seconds 800 4.3u / .85, tabular, a 3 px shadow, the last ten in blood with hd-tick; or PRACTICE's ∞ 7 × 3.6u drawn by hd-write; the caption ROUND · 決闘 / PRACTICE · 練習, .62u mono .3em), the phone in portrait without the deck (from 2.4u / 3.4u + st, 3.4u, 6.6 × 3.2u), and the clock tab on the deck (phase 2's). `lhud-clock-update` (system: when the ∞ restarts) |
| duel/lisp/lhud-overlay.lisp (new, ≈ 490) | each overlay a system and a view: `lhud-dim` (the paused scene's brightness(.45) as an ink rect of .55 on the grade's .5 s ease-out, under every layer); `lhud-intro-update` / `lhud-intro` (the letterbox, the vertical name column with hd-brush, the side's reading, blood line and line with hd-fade, wrapped by the flex shrink as Chrome does: KUROSAKI / ICHIGO in two columns; the VS bar with hd-fade); `lhud-ready` (READY .7 s and 斬 .9 s with hd-ready's scale and blur as SDF softness, the slash line's hd-slash with its moving origin); `lhud-finish-update` / `lhud-finish` (the 42 % ink gradient, 決着 / 時間切れ with hd-brush, the splat with hd-splat's overshoot, K.O. / TIME / DRAW turned with hd-fade, the winner block with hd-rise and the Konpaku / best combo / Kikons line in mixed faces); `lhud-pause-update` / `lhud-pause` (止 vertical with its 12-point blood blot, the phone's 止 across with hd-fromtab out of the clock tab; the paper strip rotated -1.2° with hd-strip's reveal; the eyebrow, the rows with their numbers, English (wrapped in its 1fr column on the phone: CHARACTER / SELECT), zh or boxed value, rules, the cursor's .2 s colour and .6u shift; the long list's sizes; each row its own grid height); `lhud-pause-pointer` (the rows' hot boxes 700 + row: a mouse that moved onto a row moves the cursor, a click or a tap confirms, as hud.js's strip listeners) |
| duel/lisp/lhud-data.lisp | FIGHTERS' full names (the intro's column), CRY, PAUSE's zh, `lhud-full-name`, `lhud-cry-line`, `lhud-pause-row` (hud.js's split of "EN  value"): host-tested in tests/duel-rules/lhud-geom.lisp |
| duel/lisp/lhud-fx.lisp | the prompt's key cap (.hkey: S8, .95u mono .08em, padding .55u .8u, a steel border with its 3 px bottom, radius 3, ink .65; none for Awaken or on a phone) between the ring and the words; `lhud-layers-update` takes FRESH (the HUD's first frame after being off snaps the fades: `display: none` -> block runs no transition) and no longer writes the engine; `lhud-canvas-grade!` is the HUD's one output outside the paint stream, called by `hud-draw` |
| duel/lisp/lhud-plate.lisp | the soul flame as one baked SDF glyph (two quads: the paper fill at the path, the stroke as an outline band centred on it, 1.2 units, at stake 2.4 in blood); a sealed pointer's dashed border (3 px dashes: the stripes pattern on four edge rects) |
| duel/lisp/lhud-model.lisp | `col-mix!` takes its out colour (`*lhud-mix*`, `*lhud-mix2*` when two blends are alive at once: 爆's ink stops), so no call shares a scratch it does not name; `+soul-glyph+` |
| duel/lisp/lhud-battle.lisp | `lhud-systems` (FRESH) runs the clock, intro, finish and pause systems too; `lhud-draw` adds the dim first and the overlays last (z 18-20) and draws the clock in every form; `*lhud-v0*` |
| duel/lisp/webhud.lisp | `webhud-pause-cmd`: one dispatcher of the pause commands for the page's queue (:html) and the Lisp HUD's pointer (:lisp); `page-draws-p` now only gates the page itself |
| duel/lisp/hud-screens.lisp, cinema.lisp | the routing (§4.6): the canvas pause, the intro / K.O. / TIME letterbox and caption, the slice-out and FIGHT! are off under `canvas-hud-off-p`; `hud-draw` calls `lhud-canvas-grade!` after `lhud-draw` |
| duel/lisp/debug.lisp | 2495 (the 2505 scene with the intro played), 2496 (human Kenpachi in his Shikai vs Ichigo: the KAIHO strip on the left plate), 2497 (P2 K.O.'d now), 2519's fourth line (the overlays forced mid-animation) and its flame A/B line (DUEL_GAMEPLAY "Debug commands") |
| engine/lisp/text.lisp (engine) | an upright vertical glyph sits in the ideographic em box (0.88 em over its baseline: the CJK faces' typo ascender, where their vmtx puts the vertical origin, as Chrome does); before, the line box's ascent / descent split put every vertical column 0.08 em high (13 px on the desktop 止). ENGINE_API |
| engine/lisp/package.lisp (engine) | exports `*glyph-dscale*` and `+big-px+` (the flame's band is set in em; `+big-px+` was otherwise read unbound as DUEL::+BIG-PX+) |
| tools/sdf-bake.py | `SHAPES`: SVG paths baked as glyphs at private-use codes, body tier only (fontTools' svgLib parses the path; the display tier's spread would clip the stake's band); the soul flame is U+E000 in the sans. The atlas and metrics are rebaked (the new `kj` strings: 時 間 and the full names' body tier) |

**The principles (§4.8)**, as built: every overlay is a system (`…-update`, run once a frame by `lhud-systems` before any view: the
model's edges -> animation starts, strings made only when their source changes) and a view (model + that state + the UI clock -> paint
calls, `paint-reset` / push / pop around it). No view reads the sim; the pause's pointer reads only last frame's hot boxes and the
model's cursor and turns them into the commands the page sends. §13.1's two named exceptions are closed: `*grade-desat*` is written in
one named function (`lhud-canvas-grade!`, called by the integration point), and `col-mix!`'s out vector is the caller's. What is not
pure: the views still take their floats through `*lhud-a*` / the pen (the 0 B convention), `lhud-vwords` and `lhud-pz-measure` write their
measures into lanes, and the intro's flex shrink and the pause's row heights are computed in the views each frame (a few measures), not
in host-tested layout functions.

### 14.2 What differs from the HTML, and why

- **Animation phases in the HTML stills**: `--freeze-css` does not hold every HTML animation: the pause's hd-strip, the phone's deck fade
  and the VS bar of a match started from the menus show at other phases (or their end) in the HTML stills; the Lisp side follows the CSS
  numbers. Compare those against the CSS, not the HTML stills.
- **The HTML reacts a frame late**: when a battle ends (V0 = 0) the HTML keeps its last frame once (the finish still showing at the
  results' first frame); Lisp hides at once.
- **Blur**: READY's and 斬's 6 px blur are SDF softness, capped by the 4 px spread of the display tier: softer than none, less than
  Chrome's gaussian.
- **The blot and the splat** are their clip-path stars (star-shaped fans, aliased); the blot's `border-radius: 50%` rounding of the
  star's far points is not applied.
- **"vs"** is drawn from the body tier scaled past 40 px, so it stays lower case (the display tier holds capitals only); Big Shoulders'
  lower case reads as small capitals, as in the HTML.
- **The pause's English** wraps to two lines at most (the rows are two words).
- **Not reached by the scripts**: a sealed pointer's dashed border (no scene sets V o+24; the code is drawn but unseen), a K.O. draw, the ROTATE eyebrow (the phone held across is not one-handed under AUTO: `ml-land` shows
  the plain landscape HUD), Hisagi's plate (14.5).

### 14.3 Measurements

| What | Result |
|---|---|
| Consing (debug 2519, every entry, 1280 × 720 and 390 × 844) | 0 B a call: plate, combo, the whole draw, the systems (once the three new systems were DEFUN-FAST: a plain DEFUN's float transitions boxed 160 B a call), the clock, intro, READY, finish, pause (14 rows), dim, pointer, the flame glyphs |
| The flames (2519's A/B: 18 flames at a phone plate's size in the same run and transform, 24 samples; the machine's load average was 36-46, other sessions' Chromes) | polygon fill + round-capped stroke 0.64-1.42 ms (median ≈ 0.80), 2,430 vertices; the baked glyph 0.066-0.167 ms (median ≈ 0.10), 216 vertices: ≈ 8× less time, 11× fewer vertices |
| The whole draw (the busiest frame, 2519, the same load) | phone 0.68 ms median (2,334 vertices; phase 2: 1.32 ms and 4,548 at a lower load), desktop 0.49 ms (1,662 vertices; phase 2's build 1.08 ms and 3,438). The vertex counts compare; the ms only roughly (the load) |
| The overlays (2519's fourth line, medians, the same load) | clock 0.07 ms (desktop) / 0.16 (phone tab), intro 0.04, READY 0.05, finish 0.07, pause 0.62 ms (14 rows, 1,464 vertices; its rows measured each frame; only while paused) |
| index.wasm | 12,907,695 → 12,959,387 B (+51,692: ≈ 700 lines of game Lisp, the shape glyph, the new kanji); gzip -9 ≈ 4.08 MB |
| Startup heap | 73.6 MB (limit 110) |
| G2 | native `simgate.py --cvc` and browser `style-gates.py cvc`: II 32, IK 34, KK 33, identical |

### 14.4 Proof

Scenes (the worktree's `build/lhud/p34/`, git-ignored; `gen.py` writes one `run.mjs` script per scene, run twice, HTML and `?hud=lisp`,
with `--fixed-dt 16.666667 --freeze-css`; `runall.sh` runs them; `sheets.py` makes the sheets with tests/lhud-compare.py). Every state by
debug commands, keys, mouse events and touches, never a CPU: 2505 / 2506 + 2440+k, 2495-2497, 2508, Escape / arrows, a mouse moved and
clicked on rows, a tap on the clock tab and on a row. 1280 × 720 unless named; 2560 × 1080 (`wide-`), 1024 × 768 (`narrow-`), the phone
390 × 844 (`m-`) and 844 × 390 (`ml-`) at dpr 3.

| Sheet | What it shows |
|---|---|
| `cmp-d-combo-*.png`, `z-d-combo-*-low.png`, `cmp-{wide,narrow}-combo-*.png` | landscape at three sizes: both plates, the clock, the combo and its slash, the prompt with its key cap (SHIFT + J / SP · AS2 / J HIT → 双牙 · SOGA) |
| `z-d-prac-*-p1.png`, `z-d-ready-*-p1.png`, `cmp-d-{ptr2,low,spent,ready,awakened,sublim,clockend,hold,prompt}-*.png` | the plate rows (the flame glyphs, meters, seals, 覺醒 READY), ∞ and its caption, the last ten, the Kikon hold ring with the key cap |
| `z-d-ken-{shikai,kyoran}-*-p2.png`, `cmp-d-ken-p1-*.png` | Kenpachi's KAIHO strip, form seals and tags on the right, and mirrored on the left (2496) |
| `strip-d-ready.png` | READY's entry (scale 1.7 and the blur as SDF softness), the slash line, 斬 in and out; the HTML row runs ahead there (`--freeze-css` misses these animations' start: the Lisp row follows hd-ready's numbers) |
| `sheet-landscape-tops.png` | the plates and clock of clockend (the last ten in blood; the HTML's second is a frame late at the boundary), wide, low, awakened, sublimation, pointer 2, prompt |
| `strip-d-intro.png`, `z-intro-col.png`, `z-intro-vs.png`, `cmp-d-intro-*.png`, `cmp-narrow-intro-*.png` | the intro: letterbox, 黒崎一護 / 更木剣八 revealed, KUROSAKI / ICHIGO and 斬月 · ZANGETSU wrapped as Chrome wraps them, the VS bar, READY, 斬 and the slash |
| `strip-d-ko.png`, `strip-d-time.png`, `cmp-d-ko-*.png` | the finish by K.O. and by TIME (決着 / 時間切れ, the splat, K.O. / TIME, the winner), then the results screen |
| `cmp-d-pause-*.png`, `strip-d-pause-strip.png`, `cmp-{wide,narrow}-pause-*.png`, `cmp-d-pause-vs-*.png` | the pause: 止 and its blot, the strip, 14 long rows (PRACTICE) and 5 (VS CPU), the cursor moved, the pause closed |
| `strip-m-pause.png`, `cmp-m-pause-*.png`, `cmp-m-pause-vs-*.png` | the phone's pause: 止 growing out of the clock tab, the rows across, CHARACTER / SELECT wrapped |
| `cmp-d-pointer-*.png`, `cmp-m-tap-*.png` | the pause by pointer: hover moves the cursor, a click on CAMERA flips its value, a click / tap on RESUME closes it |
| `sheet-mobile.png`, `cmp-m-{intro,ko}-*.png`, `cmp-ml-land-*.png` | the overlays in portrait and the phone held across |
| `sheet-full-lisp.png`, `cmp-full-*.png` | a whole match under `:lisp` by keys from the title through the HTML menus, the intro, a combo, the pause, a K.O. to the results: no canvas HUD in any still |

Checks: host tests duel-rules 10200 (+10: the overlays' tables), hud-engine 121, paint-shapes, touch 100, input 33, control 100, cine 18,
learn 131: all pass; pkgcheck only `DUEL::APP`; debug-ranges-check 119 ranges, 0 errors; smoke 8 s default and `?hud=lisp` at 1280 × 720
and 390 × 844: exit 0. **The default renderer is unchanged**: the HTML combo scene on the base build and on this one (`build/lhud/p34/base/`): at 10.45 and 11.60 s the HUD's bands differ by 0-14 px, at 11.05 s by the combo stamp's CSS phase (a frame apart, §13.5) and the scene's own noise (REFACTOR_2026-11.md §10.2).

### 14.5 Left for the next phases, and doubts

- **Hisagi in the scripted scenes** (fixed 2026-11-11, DEVLOG §712): `lhud-scene` with Hisagi on either side aborted right after the
  battle started ("not a lisp data object"), and so did a human-played Hisagi from the menus, since phase 2 (d337a824). Cause: phase 2's
  macros `hs` (a model string) and `alpha!` in `lhud-model.lisp` had the names of Hisagi's state reader `hs` (`hisagi.lisp`) and the
  canvas HUD's function `alpha!` (`hud.lisp`); in the one build unit the later definition replaced the function. Renamed `hstr` and
  `col-alpha!`; the host test `tests/duel-rules/unit-names.lisp` now fails on any top-level name defined twice in the unit. Hisagi's
  plate (風死 · IN HAND, his seals) is still unreviewed in landscape.
- Hot-box ids 700-719 are the pause's; the menus (§15) must keep clear of them (one registry a frame: `hot-begin-frame` in `lhud-frame`).
- `--freeze-css`'s misses (14.2) make the HTML side of an animation strip unreliable for the pause and for a match started from the menus.
- The pause measures its rows each frame (0.6 ms under load, only while paused): a per-serial cache of the widths if it matters.
## 15. Phases 5-6 results (the menus in Lisp, 2026-11-11)

Merge note (the main session): the worktree's debug 2495+k collided with §14's 2495-2497, so the menus' review scenes are 2401+k on
main (the stills below were shot with the old numbers); `col-mix` calls became `col-mix! *lhud-mix*` (§14's helper).

Opus 5.5 built them in a worktree from main d337a824, beside the battle side's phases 3-4 (§14); the main session reviews. Under `:lisp`
(the URL flag, debug 2517, or the new SETTINGS row) TITLE, MODE, SETTINGS, CONTROLS (keys and the phone's gestures card), SELECT and
RESULTS are drawn by Lisp and take keys, pads, the mouse and touch; MANUAL still opens manual.html (the user: 「說明手冊保留在 html 頁面」).
The default renderer (`:html`) is unchanged but for the HUD row (DUEL_WEBUI §19) and its CSS room.

### 15.1 What was built (one job a file)

| File (lines) | Job |
|---|---|
| duel/lisp/lhud-menu-data.lisp (106) | menu.js's tables as plain CL: MODES, the cards, SETTINGS (8 rows with HUD) and the two action rows, BINDS, KEYS / PADS (`lm-bind-name`), COLS, the key map's rows, RMENU, SCREENS, the title's lines, the side texts, the phone card's texts, SELECT's headings and slot captions. Upper case where the CSS upper-cases; faces tagged for the bake |
| duel/lisp/lhud-menu-geom.lisp (172) | the pure layout: menu.css's grids worked out per screen and form (desktop, narrow ≤ 760, short) in CSS px from the window, the insets and the few measured inputs (a paragraph's lines, the tags' rows, the help tweens, the cards' weights): `lm-content!`, `lm-title-geom!`, `lm-mode-geom!`, `lm-set-row-h` / `lm-set-geom!`, `lm-ctl-geom!`, `lm-select-geom!`. Host-tested against Chrome's boxes |
| duel/lisp/lhud-menu.lisp (471) | the frame (`lhud-menu-draw`: the systems, the pointer, the screen, the rails, the cut), the input kind (keys / pad / touch), the pointer (hot boxes → the page's commands), the backdrop (`#ui .wash`; SELECT's world), the rails (mark, crumb, hints), the cut, and the shared devices: the key cap, the shape glyphs (⇧ ␣ ▶ ◀ ✚ ↺), the brush, the seal, the torn paper, the option slab; the title's ash |
| duel/lisp/lhud-menu-front.lisp (335) | TITLE (wordmark rise, outlined DUEL, NEXT, the slash, the halftone 魂, the vertical line, PRESS gated by V11), MODE (inkin kanji, the torn card, the seven rows), RESULTS (who, name, DEFEATED, the hanko, the soul eggs, the stats, the gated rows); the shared row `lm-row` |
| duel/lisp/lhud-menu-set.lisp (362) | the side title; SETTINGS (focus wash and bar, labels, arrows, option slabs, drops, the help line wrapped and clipped by its max-height tween, the rule); CONTROLS (column tabs, the key map with the bound caps, the ⇧ combos, the ten binding rows, the capture's pulsing PRESS; the phone's gestures card with its dashed zones and the rising thumb) |
| duel/lisp/lhud-menu-select.lisp (257) | SELECT: the cards' weights, fills, emblems, details and pick stamps (system); the back layer (`with-paint-back`: the world, the cards' fills, screentone and emblems, on a phone the other cards' text) under the transparent scene; the front (heading, slots, the cards' text, DIFFICULTY / CAMERA / START); `lm-select-spot`, the camera's spot from the same layout |
| duel/lisp/webui.lisp | the model kept for both renderers (`ui-put` sends only under `:html`), `lhud-menus-p`, `menu-page-draws-p`, `webui-on-screen-p` true under `:lisp`, the renderer switch and the HUD row (`webui-renderer-sync`), the Lisp command queue (`ui-send`), one dispatcher (`webui-command`), `select-spot` |
| duel/lisp/flow.lisp | `menu-nav`'s `tapped-row`, TITLE's and the phone CONTROLS page's `tap-p` (`menu-tap-p`), SELECT's `tap-third` (`menu-tap-third`) off while the page or the Lisp menus draw the screen |
| duel/lisp/control.lisp, duel/web/pwa.js, menu.js, menu.css, manual.html | the HUD row (DUEL_WEBUI §19) |
| duel/lisp/hud-screens.lisp (one line, the battle side's file) | `(lhud-menu-draw)` after `lhud-draw` under `:lisp` (it relies on `lhud-draw` having run `lhud-frame`: the layout and `hot-begin-frame`) |
| duel/lisp/camera.lisp (one line) | `:select-web` reads `select-spot` instead of page get 30002 / 30003 |
| duel/lisp/debug.lisp | 2401+k (`lm-results-scene`: a K.O. into RESULTS, k 3 SELECT with Hisagi / Ichigo picked), 2519's menus line (`lm-consing`) |
| engine/lisp/text.lisp, package.lisp | `paint-measure-paragraph` (a paragraph's line count before its box is drawn); `*glyph-dscale*` exported (DUEL's outline in px). ENGINE_API |
| tests/duel-rules/lhud-menu.lisp | the tables against the model's rows; every geometry function against Chrome's `getBoundingClientRect` at 1280 × 720 and 390 × 844 (`build/lhud/p56/dom.py`) |

**The principles (§4.8)**. The views read only the model (`*ui-sent*`, the 30000 block both renderers read), their screen's
component state and the UI clock; the systems (`lm-mode-update`, `lm-settings-update`, `lm-controls-update`, `lm-select-update`,
`lm-results-update`, the frame's cut / input / ash) are the only places that change state, once a frame before the views; the layout
is pure and host-tested; floats cross calls through `*lm-a*` and the geometry lanes (`*lm-g*`, `*lm-g2*`). Where not: (1) the input
kind (keys / pad / touch) is read from the devices by the frame's system, as menu.js reads the DOM events (it is the page's state,
not the game's); (2) `lm-select-back` sets `*render-transparent*` (the engine's one-frame latch; `*scene-transparent*` already set it
for the frame); (3) the pointer is handled in the draw (`lm-pointer`, against last frame's boxes) and turned into queued commands, so
the flow still decides everything in its own update the next frame; (4) V41 (HAND) is read as menu.js reads it (DUEL_WEBUI §19's
latent quirk).

### 15.2 What it draws, against the HTML

| Screen / device | menu.css / menu.js | How |
|---|---|---|
| Backdrop | `#ui .wash` (radial + linear ink, the 7 px screentone masked at 170°); SELECT's `#ui-back .world` (radial night, screentone, grain) | a radial fan (3 stops), a gradient rect, a dotted rect with an alpha gradient along 170°; the world in the back layer, its grain as a flat white at .037 |
| Rails | `.rail`, `.mark`, `.crumb`, `.hints`, `.key` | the tick turned −24°, the word, the crumb (narrow: the kanji only), the hints by input kind (MOVE / BACK hidden narrow) |
| Cut | menu.js `cut()` WAAPI | the ink polygon through its three keyframes on cubic-bezier(.16,1,.3,1) 380 ms, the blood line drawn by its middle then faded, 300 ms ease-cut; skipped under reduced motion and on a renderer switch |
| TITLE | `.wordmark`, `rise`, `slash`, `.big-kanji`, `.t-vert`, `.press`, `pulse`, ash | each line's clip rising (a scissor) with translateY .2em, .9 s ease-out, delays 0 / .12 / .24; DUEL as the SDF outline band (2 px); the slash's 5-point polygon, rotate(−5°) scaleX .46 s .5 s ease-cut; 魂 slate under a 6 px steel halftone (glyph × dot pattern); the dot's pulse; PRESS J / A / TAP TO BEGIN by input kind, gated by V11 (.35 s); 60 ash flakes (30 narrow) on a cosmetic LCG |
| MODE | `.m-kanji` + `inkin`, `.paper`, `.row`, `.brush`, `.seal` | the vertical kanji with inkin (opacity, an SDF softness standing in for blur(8px), −14 px); the card as a hash-jittered polygon with the 5 px dots; rows with the brush (scaleX .34 s ease-out, the tail's 86 % fade cut apart because gradients are per vertex), the seal (scale + rotate .3 s, .08 s after focusing), the colour .18 s |
| SETTINGS | `.side-title`, `.set`, `.opt`, `.drops`, `.help`, `.arrow` | the focus wash and bar (scaleY .3 s), slabs (scaleX .3 s, skew −14°), colours .2 s, drops (on / current .25 s, scale 1.15), the help wrapped in its row and clipped by the max-height tween (.4 s); narrow rows fit-content as Chrome sizes them (the help's max-content included) |
| CONTROLS | `.tabs`, `.kbd`, `.combos`, `.binds`, the capture, `PHONE_SVG`, `thumb` | the tabs' slabs, the key map (the bound caps paper, SHIFT's blood stroke), the labels in two runs (no string made), ⇧ + caps, the rows with focus bar and wash, PRESS pulsing in blood; the phone card at its CSS scale, dashed zones as dash strokes, the thumb's keyframes (4.8 s ease-cut) |
| SELECT | `#ui-back` / `#ui` copies, `.fighter`, `.emb`, `.more`, `.pick` + `stamp`, `.slot`, `.diff`, `#sel-go` | the back layer under the scene (world, fills .4 s, dots masked to 70 %, emblems with colour .5 s and translateX −6 % .7 s), the weights' flex-grow .6 s ease-out, the details' max-height .6 s + opacity .4 s .1 s, the pick stamp .45 s, the slots' borders .3 s, the foot's live rows .3 s; the camera's spot from the same layout |
| RESULTS | `.r-win`, `.hanko` + `hanko`, `.souls`, `.stats`, `.r-menu` | who / name / DEFEATED, the hanko (scale 2.4 rot −26° → .92 / −10° → 1 / −12°, .6 s .3 s), the eggs as ellipses (lost: a 1.5 px ring), the stat grid with tabular numbers, the rows gated 2.5 s by V11 (.35 s) |

### 15.3 What differs from the HTML, and the replacement for each CSS effect

- **Torn paper** (`filter: url(#torn)`, feTurbulence + displacement 7 px: MODE's card): a 32-point polygon whose edges are jittered ±3 CSS
  px by a fixed hash (`lm-torn`), star-shaped about its centre, so its edge is aliased (§10.3); the 5 px dot texture is the halftone
  pattern. The hanko's torn 6 px border (RESULTS) is a clean rounded ring (`paint-box!` border): no jitter.
- **Dry brush** (`#dry` displacement on the row brush): left out; the brush is menu.js's own path (convex body, two dry streaks at .55 /
  .45), stretched over the row as `preserveAspectRatio="none"`; its 86 % tail fade is a second polygon cut at 86 % (gradients are per
  vertex: a fan from the centre would start the fade at the middle).
- **Paper grain** (SELECT's `#ui-back .world::after`, white feTurbulence at .07): its mean, a flat white at .037 over the world (without it
  the backdrop read 8-10 levels darker than Chrome's, uniformly); the noise's texture is left out.
- **Blur** (`inkin`'s blur(8px) on MODE's kanji): the SDF softness widened over the animation (1 → 17 px).
- **Text stroke** (DUEL, 2 px): the SDF outline band, 1 px each side of the edge. **background-clip: text** (魂): the glyph twice, slate,
  then steel through a 6 px dot pattern.
- **Masks** (the screentones' 170° fades, the cards' dots to 70 %): the alpha as a vertex gradient along the mask's axis.
- **Dashed strokes** (the phone card's zones, 4 5): dash strokes along the rect.
- **Weights**: Big Shoulders Display is baked at 900; the 800 / 700 text (rows, labels, options, slots, stats, key labels) is drawn
  condensed by 0.94 / 0.90 about its start (`+wd8+` / `+wd7+`: Chrome's 800 runs about 6 % narrower, measured on MODE's rows: VS CPU 132 vs
  141 px at 54 px before the condensing) and at a raised SDF edge; the other faces' lighter weights by the edge alone (§11).
- **Line breaks**: zh paragraphs break within ±1 character of Chrome's (SELECT's taglines break one character earlier at the 42ch width).
- **Animation timing**: the cut, the rise, the focus move and the swaps follow the CSS numbers on the UI clock; `--freeze-css` does not
  hold the HTML's transitions in every still (its focus-move frames show the brush already full), so those strips compare against the CSS
  numbers rather than frame for frame (§8.3, §13.5).
- **Layout**: within 1-2 CSS px of Chrome's boxes on every screen checked (the geometry host test, the sheets' difference maps); the narrow
  SETTINGS rows take their fit-content width as Chrome does, the help line's max-content included.
- **The ash** uses a cosmetic LCG instead of Math.random: the same counts, sizes, speeds and colours, other places.
- **Not built**: the narrow menus' scrolling (§4.5: nothing overflows at 390 × 844 once the HUD row's CSS room is in; a phone shorter than
  about 780 CSS px would clip the bottom of SETTINGS / RESULTS: the HTML scrolls there), `prefers-reduced-motion` read live (as §11.4), hover
  cursors, focus rings, text selection, accessibility roles. The toast (unused in the HTML too).

### 15.4 Measurements

| What | Result |
|---|---|
| Consing (debug 2519's `lmenu consing` line, `--fixed-dt`, 1280 × 720 and 390 × 844 dpr 3, each view warmed first) | every entry 0 B a call: the systems, TITLE, MODE, SETTINGS, CONTROLS, SELECT, SELECT's back layer, RESULTS, the rails, the wash, the cut, the pointer. Found on the way (all fixed): float arguments to compiled functions boxed (`lm-brush`, `lm-seal`, `lm-slab`, `lm-row-box`, `lm-dashed-rect`, the SETTINGS / SELECT geometry are `defun-fast-inline` now); CL `max` / `min` of floats are generic calls (C `f-max` / `f-min` in the views, if-based `fmx` / `fmn` in the host-tested geometry); `paint-measure-paragraph`'s parallel `let` boxed its width (engine, `let*` now); the torn edge's hash overflowed into bignums (30-bit fixnums); a swallowed `let*` binding made SELECT's card text read two unbound globals (an abort, caught by the probe) |
| Consing, the whole frame (the keys walk's `stats:` lines, `--fixed-dt`, HTML vs Lisp at the same windows) | RESULTS 1,233 / 1,233 and 1,232 / 1,232 B a frame, TITLE 1,104 / 1,114 and 1,290 / 1,293; the SELECT window that holds the screen's entry 1,374 / 1,899 (the entry lays its paragraphs out once). The Lisp menus add nothing a frame in steady state |
| Lisp time a call (2519 in a wall-clock run, SwiftShader, desktop) | TITLE 0.065 ms, MODE 0.32, SETTINGS 0.36-0.45, CONTROLS 0.55-0.58, SELECT 0.26 (its front; 0.08 off the screen) + its back layer 0.07-0.09, RESULTS 0.13, the rails 0.03-0.07, the wash 0.03, the cut 0.012, the systems 0.002-0.09: under 0.7 ms for any screen's frame |
| Vertices (desktop / phone) | TITLE 327 / 273, MODE 1,242 / 1,212, SETTINGS 1,488 / 1,212, CONTROLS 3,099 / 2,271 (the phone's card), SELECT front up to 1,362 / 1,104 and back 402 / 552, RESULTS 1,104 / 1,104, the rails ≤ 348, the wash 312, the cut 15 (of 32,768; the back layer of 8,192) |
| index.wasm | 12,907,695 → 13,099,362 B (+191,667: ≈ 1,700 lines of game Lisp, the engine macro, and the worktree's rebake with the HUD row's glyphs); gzip -9 4,061,214 → 4,113,304 |
| Startup heap | 73.3 MB (unchanged; limit 110) |
| Default renderer | `:html` draws nothing new (`lhud-menu-draw` runs only under `:lisp`); the page gets the same values but for the HUD row (V47) |

### 15.5 Proof

Walks (the worktree's `build/lhud/p56/`, git-ignored: `gen.py` writes one `run.mjs` script per walk, run for both renderers with
`--fixed-dt 16.666667 --freeze-css`; `runall.sh`; `sheets.py` → `cmp/`): **keys**, 1280 × 720 and `--mobile` 390 × 844: TITLE → MODE (each
row focused) → SETTINGS (HAND changed, the HUD row toggled both ways) → CONTROLS (MOVE UP rebound to I, the pad column; the phone: its
gestures card) → SELECT (Ichigo, the CPU's Kenpachi, the last page, HARD, the camera row) → a match's intro → debug 2401 → RESULTS (a row
focused) → TITLE; **touch**, 390 × 844: a tap on TITLE, the SETTINGS row, the HUD row, LISP, HTML, LISP, BACK, CONTROLS (the card, a tap
back), VS CPU, the focused card twice (P1, the CPU), HARD, START, then 2401 → RESULTS: both renderers log the same `duel ->`, `duel setting
HUD …` and `hud renderer …` lines and start the same seeded match (`duel match seed 21683 VS-CPU ICHIGO vs KENPACHI HARD`); **strips**
(`sdesk`, `smob`): the cut, a focus move, the title's rise; **SELECT again** (`sel`, `smob2`) after its last fixes.

| Sheet ([HTML \| Lisp \| difference × 4]) | What it shows |
|---|---|
| `cmp/desk-title.png`, `cmp/zoom-desk-title.png`, `cmp/mob-title.png`, `cmp/zoom-mob-title.png` | TITLE: the wordmark, DUEL's outline, NEXT, the slash, 魂's halftone, the vertical line |
| `cmp/desk-mode{0,2..6}.png`, `cmp/zoom-desk-mode2.png`, `cmp/mob-mode*.png` | MODE, each row focused: the brush, the seal, the card |
| `cmp/desk-settings*.png`, `cmp/zoom-*-settings-hud.png`, `cmp/mob-settings*.png`, `cmp/tmob-t-hud-*.png` | SETTINGS: the focused row, HAND changed, the HUD row (in the HTML run a toggle to LISP hands the screen to the Lisp menus and back) |
| `cmp/desk-controls*.png`, `cmp/mob-controls.png`, `cmp/tmob-t-controls.png` | CONTROLS: the capture, the rebound key, the pad column; the phone's gestures card |
| `cmp/sel-select{0,1,2-hard}.png`, `cmp/smob2-select*.png`, `cmp/tmob-t-select*.png` | SELECT's three phases with the fighter between the layers, at both sizes |
| `cmp/desk-results.png`, `cmp/smob2-results.png`, `cmp/tmob-t-results.png` | RESULTS after 2401 |
| `cmp/strip-sdesk-{cut,focus,rise}.png`, `cmp/strip-smob-*.png` | frames, HTML above and Lisp below: the cut (50-450 ms), a focus move (33-450 ms), the title's rise (50 ms-1.4 s) |

Read by eye: layout, palette, type and the named animations read as the same design; the rise and the cut agree frame for frame; the
HTML's focus-move frames are not held by `--freeze-css` (its brush is full in the first frame), the Lisp one follows the CSS numbers.

Checks: host tests duel-rules 10236 (with tests/duel-rules/lhud-menu.lisp), duel-control 100, hud-engine 121, paint-shapes, touch 100,
input 33, learn 131, cine 18: all pass; pkgcheck only `DUEL::APP`; debug-ranges-check 117 ranges, 0 errors; G2 native `simgate.py --cvc`
and browser `style-gates.py cvc`: II 32, IK 34, KK 33, identical; smoke 20 s, default and `?hud=lisp`, 1280 × 720 and 390 × 844: exit 0,
the startup heap 73.3 MB.

**Found, not this branch's**: on d337a824 any Hisagi spawned by a human aborted ("not a lisp data object", or "STRUCTURE-REF … HSS"),
SELECT's A / D included (cycling to Hisagi): lhud-model.lisp's macro `hs` shadowed hisagi.lisp's function in the one build unit; fixed on
main (`hstr`, `col-alpha!`), renamed the same here. The long walks (run before the rename) avoid A / D on SELECT; after it, debug 2404
(SELECT with Hisagi picked) runs in both renderers (`cmp/sel-select-hisagi.png`).

## 16. The Lisp renderer becomes the only one; the HTML UI removed (2026-11-11)

The user, 2026-11-11, asked whether, after acceptance, to make Lisp the default and remove the HTML HUD and the old canvas HUD:
「將 lisp 版設為預設並移除 html」 (§7 answer 8), then 「舊的 Canvas HUD 也移除」 (§7 answer 9). The manual stays an HTML page (「我選 3，
說明手冊保留在 html 頁面」). Opus 5.5 built it in a worktree from main 562acb37, as two commits (the HTML, §16.1-§16.5; the canvas,
§16.6); the main session reviews.

### 16.1 What was removed, and what replaced it

| Removed | Lines | Replaced by / why it could go |
|---|---|---|
| `duel/web/hud.js`, `hud.css` | 399 + 480 | the Lisp battle HUD (lhud-battle / -plate / -deck / -fx / -clock / -overlay.lisp, §13-§14) |
| `duel/web/menu.js`, `menu.css` | 379 + 396 | the Lisp menus (lhud-menu*.lisp, §15) |
| `duel/web/alpha.js` | 11 | made the canvas premultiplied so `#ui-back` showed through SELECT's transparent scene; the Lisp SELECT draws its cards in the paint stream's back layer, which is opaque (stills with and without it differ only where the fighter animates, as two runs with it do) |
| `head.html`: the Google Fonts links, `menu.css` / `menu.js` / `hud.css` / `hud.js` / `alpha.js` | 19 -> 12 | the HUD's glyphs are baked into index.wasm (§4.2); the loading veil and its system fonts are in `engine/web/shell.html`, unchanged; manual.html has its own head and never used the web fonts |
| `pwa.js`: page get 8 (`?hud=lisp`), the 30000 / 30100 routes to `gameUI` / `gameHUD`, `setStr`, the `hud` settings key | 139 -> 126 | nothing reads them |
| `sw.js`: the five files, the `soulduel-fonts` cache and its fetch branch | 38 -> 27 | the activate step now deletes every cache but the build's, the old fonts cache included |
| webhud.lisp: `+pg-hud+`, `*webhud*`, `+pg-hud-flag+`, `webhud-page-p`, `page-draws-p`, the page sends in `webhud-put` / `webhud-put-str`, the page queue in `webhud-commands` | 291 -> 255 | `webhud-sync` still writes the model (`*hud-sent*`, `*hud-strs*`), the one place that does; `webhud-pause-cmd` the one pause dispatcher |
| webui.lisp: `+pg-ui+`, `*webui*`, `webui-p`, `menu-page-draws-p`, `webui-renderer-sync`, `*ui-rend*`, `*hud-row-seen*`, the page queue, `select-spot` (camera.lisp calls `lm-select-spot`) | 162 -> 118 | `webui-sync` writes `*ui-sent*`; `webui-command` the one menu dispatcher; the Lisp queue (`ui-send`) |
| SETTINGS' HUD row (§7 answer 7): control.lisp `:hud`, lhud-menu-data's row, pwa.js `hud`, manual.html's row | - | one renderer, nothing to choose. It was the last row, so dropping it moves no saved row (pwa.js saves by place); a saved `soulduel.hud` is ignored. SETTINGS has 7 rows + RESET LEARNING + BACK again (`+lm-set-rows+` 9) |
| `tests/lhud-compare.py`, `tools/run.mjs --freeze-css` and `--query` | 27 + 18 net | the HTML-vs-Lisp sheets have no HTML left to compare; no test passes a URL flag |

The file names webhud.lisp / webui.lisp are kept (the functions' `webhud-` / `webui-` names run through lhud-*.lisp, debug.lisp, flow.lisp
and the DUEL_WEBUI protocol tables); their headers now say what they are: the battle screens' and the menus' models. `:html` and the URL
flag are gone (no test needs `?hud=canvas`); in the first commit debug 2517 still toggled `:lisp` / `:canvas`, and §16.6 removed it with
the canvas HUD.
`engine:page-set-str` (and `pf_page_set_str`) has no caller left; it stays, an unused engine export for refactor batch B1.

Also in this pass: `build.sh` deletes the dist's page files before copying `duel/web/*` (a removed page file lingered in `dist/` and
would have been deployed); `tools/run.mjs` fails a run on any 404 (a page still naming a removed file); manual.html names its icon
(`icon-192.png`: its `/favicon.ico` request was a 404 the new rule caught).

### 16.2 The gap audit: what the HTML page did that a player could notice

| What the page did | Now |
|---|---|
| A screen taller than the window scrolled (SETTINGS below about 750 CSS px, RESULTS / MODE on small phones, every stacked screen on a landscape phone) | **added**: the screen shrinks to fit. `lm-fit-k` (lhud-menu-geom.lisp, pure, host-tested) gives the zoom from the height the screen's stack took last frame (each geometry's `[31]`); `lm-zoom!` / `lm-unzoom!` (lhud-menu.lisp) scale the frame's density for MODE, SETTINGS, CONTROLS and RESULTS only, the rails and the cut keep the real one. A phone has no keys to scroll focus into view and a drag scroll is more code; a shrunken screen keeps every row tappable. Checked at 360 x 640, 320 x 568 and 844 x 390 (zoomed), 390 x 844 and 1280 x 720 (zoom 1) |
| ROTATE TO PORTRAIT in the pause on a turned phone | Lisp: lhud-overlay.lisp `*lhud-ey-rotate*` (§14) |
| Focus / hover / active states | Lisp: the focus transitions (brush, bar, wash, seal); the mouse over a row moves the cursor (`lm-pointer`, as menu.js). **Dropped**: the CSS `:active` press tint (cosmetic) and the `cursor: pointer` hand (a canvas keeps the arrow) |
| Pad glyphs vs key caps in the hints | Lisp: the input kind (keys / pad / touch) picks the hints (`lm-rails`, §15) |
| VS PLAYER bindings and the rebind capture in CONTROLS | Lisp: the capture's pulsing PRESS; the capture itself is control.lisp's, unchanged (§15.5 rebinds MOVE UP) |
| Long names | the roster's names and Hisagi's form tags fit (the 83000 / 83010 / 83012 stills, both orientations) |
| Safe-area insets (a notch) | pwa.js get 3-6, unchanged; `lhud-frame` / `lm-content!` read them |
| Reduced motion | pwa.js get 7, unchanged; read when the window's size changes (§11.4: not live) |
| Text selection, the context menu, the tap highlight | `engine/web/shell.html` (user-select none, contextmenu prevented), unchanged |
| The first touch unlocking audio | engine/c/audio.c (resumes the AudioContext on the first gesture), unchanged |
| What shows while the wasm loads | the veil in `engine/web/shell.html`, unchanged |
| Accessibility hooks (`aria-label` on the keyboard map and the pad, `role="menu"` on the pause) | **dropped**: a canvas has none; the action game is not screen-reader playable either way, and the manual stays an accessible HTML page |
| RESULTS of a draw / a time-out | Lisp: DRAW · TIME UP and the finish's 時間切れ / TIME / DRAW (§14, §15) |
| CPU VS CPU (no human) | Lisp: SELECT's CPU slots, the battle, the pause, RESULTS (the `cvc` walk) |
| Hisagi's plate in landscape (never reviewed) | **reviewed** (83000 the Shikai, 83010 the ranged mode, 83012 a bind, 1280 x 720 and 390 x 844): name, kanji, the tag (風死 · IN HAND / FUSHI NO KOJO · RANGED / · BIND), the seals 投 刈 雷 / 散 聚 / 鎌 絞 with their names, SPIRIT DRIVE: all as designed, nothing to fix |
| A pause during a cinematic | **decided**: the plates stay hidden (the cinematic hides them, V0 bit 2), the scene is dimmed by the pause's ink rect (`lhud-dim`), and the cinematic keeps its own grade (no added grey: `lhud-canvas-grade!` leaves a cinematic's grade alone); the strip and 止 draw over its brush title. Legible, and the HTML's .3 plates over a cinematic were not worth bringing back |
| MANUAL (MODE row 7) | pwa.js page set 1 -> manual.html, unchanged; its back link returns |
| The web fonts cached for offline play | not needed: the glyphs are in index.wasm |

### 16.3 The charset now comes from the Lisp sources alone

tools/sdf-bake.py bakes ASCII for the Latin faces and the sans, and the tag forms of `duel/lisp/lhud-*.lisp` (`kj`, `bigkj`, `zh`,
`big`; `lhud-shape` names the characters drawn as polygons); a zh string's non-CJK symbols also go to the Latin faces. The scan of
`hud.js` / `menu.js` is gone. tests/duel-rules/lhud-charset.lisp proves coverage of what the game can put on screen, as far as a static
scan can: every tag form at its face and tier; every non-ASCII character of every string literal of `lhud-*.lisp`, `webhud.lisp` and
`webui.lisp` (read by the Lisp reader, docstrings and tag forms left out) in the sans or the Mincho; every kit's form name, form label,
U tag, intro line and move callout (walked from `*kits*` on the host) ASCII or baked. It cannot see strings built at run time elsewhere
(numbers are ASCII), a kit hook's `:hud-tag` result (ASCII literals in the kit files, turned into kanji by `lhud-tag-segments`) or the
intro's reading (brush.lisp `*brush-names*`, not loaded on the host; ASCII romaji). The page scan had added only the HUD row's help
(畫 繪 製 誰 面 頁 由 擎) beyond the tags; the sans drops from 482 to 404 glyphs (the menus' zh texts were tagged already; the 78 that
left were the page's own strings that no Lisp screen draws): **1712 of 2048 atlas rows** (1808 before), metrics.bin 17,200 -> 15,814 B.

### 16.4 Measurements

| What | Before (562acb37, built here) | After |
|---|---|---|
| index.wasm | 13,151,359 B (gzip -9 4,129,052) | 13,047,301 B (gzip -9 4,069,777) |
| dist/duel total | 13,836,990 B, 17 files | 13,587,942 B, 11 files |
| Startup heap | 73.3 MB | 73.6 MB (the model and the Lisp HUD now start with the page; limit 110) |
| Debug 2519 (`--fixed-dt`, 1280 x 720 after 2500, 390 x 844 after 2505) | | every entry 0 B on both: `lhud consing` plate 0, combo 0, draw 0, shapes 0 (frame 1,998 / 1,308 vertices); `1c`, `p2`, `p34`, `flames` all 0; `lmenu consing` every screen 0 (CONTROLS 2,271 / 2,967 vertices); debug 2515 `webhud consing` sync 0, side 0, prompt 0, deck 0, tag 0, stake 0, touch 0 |
| Host tests | 10249 | duel-rules 10260, duel-control 100, hud-engine 121, touch 100, input 33, cine 18, learn 131: all pass |

### 16.5 What still differs or is open

- The fit shrinks the whole screen: at 320 x 568 RESULTS' nine soul eggs still run past the right edge (the row is wider than the
  narrowest phone; the HTML wrapped them). Not fixed: 320-px-wide phones are rare.
- Brush captions and the big words no longer dodge the plates: `*panel-box*` (brush.lisp), which the canvas plates filled, stays 0
  (it was 0 under the HTML HUD since 2026-10-28 too). A later batch could have the Lisp HUD publish its plates' boxes there.
- `engine:page-set-str` is unused (B1).

### 16.6 The canvas HUD removed (the user, 2026-11-11: 「舊的 Canvas HUD 也移除」)

Refactor decision D4 is done by this commit (docs/engine/REFACTOR_2026-11.md §6). With one renderer left, the switch went with it:
`*hud-renderer*`, `set-hud-renderer`, `canvas-hud-off-p`, `lhud-menus-p` and debug 2517 are gone; `webhud-sync`, `webui-sync` and their
command readers run unconditionally; `lhud-draw` / `lhud-menu-draw` are simply the HUD (`hud-draw` calls them every frame).

| File | Lines (before -> after) | What went | What stayed (and why) |
|---|---|---|---|
| hud.lisp | 852 -> 179 | the panels `hud-side` / `hud-side-portrait` and every meter they drew (Reishi, guard, flash step, Reiatsu, soul flames `%hud-pips` / `%soul-flame` and their shatter clock, cooldowns, the KOSEI 攻 tag and its ember mote, the combo counter, labels, the timer), the world move-name callout and the brush callout columns (`side-cap`, `callout-y`), the pointer row at the feet, `awaken-fill`, `guard-gauge-bits`, `burst-prompt`, `pool-tally`, `%q->f`, `%hud-pulse`, `%hud-text` | the big words (`announce`, `draw-words`), `hud-world` (the red soul flame), `hud-rush-lines`, `hud-hint` (HOHO! / AUTO), `pips-shatter` (now only the glass burst and its sound), `hud-text` and the colour lists (the frozen modes' screens), the portrait block geometry (`portrait-hud-bottom`, `portrait-p1-top`, `*safe-top*` / `*safe-bot*`: the one-hand deck's layout and the frozen screens), `*refused-t*` / `refused-flash` / `hud-refused` (only the retired kits' meters read them), `hud-battle` (four lines: the world overlays and ENDLESS's tag) |
| hud-screens.lisp | 261 -> 128 | the canvas TITLE, MODE, SETTINGS, CONTROLS, the non-ENDLESS RESULTS (`results-strings`, the 勝 card), the canvas pause, the `*panel-box*` fill | `hud-draw` (the flash, focus lines, a cinematic's letterbox and brush title but the intro's / K.O.'s / TIME's, the frozen screens, the battle's world overlays, the words, then the Lisp HUD, the Lisp menus, debug 2509's card, the debug overlay); the frozen modes' `hud-menu`, `hud-select` (+ portrait), `results-card` |
| onehand.lisp | 393 -> 333 | `hud-deck`'s outline, split line, SP / ATK labels, chips and the gesture glyph; `hud-gestures` and its card | `hud-stick` (the floating stick's ring and a form's `:deck` ring: no Lisp twin, players see it), every input, gesture and deck-geometry function |
| ken-meter.lisp | 97 -> 38 | `%hud-lv`, `%hud-arm`, `hud-arm-label`, `ken-hud-meter` (the Lisp plate draws KAIHO / UDE) | `ken-boss`, `ken-card-bankai`, `ken-hud-label` (the plate's tag) |
| ichigo.lisp | -54 | `ichigo-hud-meter` (the plate's tag shows BUNSHIN xN); the KONPAKU-flash labels; 74907 measures the tag and the deck ring now | `ichigo-hud-tag`, `ichigo-hud-label`, `ichigo-deck` |
| hisagi-draw.lisp | -13 | `hs-hud-meter` | `hs-hud-tag`, `hs-hud-label`, `hs-deck` |
| webhud.lisp / webui.lisp | 255 -> 262 / 118 -> 114 | the renderer switch | `kit-hud` and `at-stake` moved in from hud.lisp (the model's inputs) |
| combat.lisp, feedback.lisp | -2, -1 | the `:kosei` event and its handler (the canvas mote was its only reader); `kosei!` takes (att g) | |
| cinema.lisp | 0 | the canvas FIGHT! word at the intro's frame 250 (READY / 斬 is the Lisp HUD's since §14) | its `:fight` sound |
| debug.lisp | -20 | 2517; 2328's canvas bar probes; 2704's portrait-column figure | 2328's hud-text and vfx lines, 2440+k, 2430+k scenes |

Net over the commit: about +200 / -1,210 lines in duel/lisp and tests (the webui.lisp churn is re-indentation).

**The gap audit, the canvas half.** Since 2026-10-28 the canvas HUD drew only its "live arm" in a battle (the page drew the rest), and
since phase 4 the same under `:lisp`; what a player could see of it with the three live kits in VS CPU / PRACTICE / VS PLAYER / CPU VS
CPU, and where it is now:

| Canvas, seen by players | Now |
|---|---|
| Kikon rush / SP2 dash speed lines | kept (`hud-rush-lines`) |
| The red soul flame over a Kikon-able fighter | kept (`hud-world`) |
| PERFECT HINT's HOHO!, ASSIST's AUTO | kept (`hud-hint`) |
| The floating stick's ring and the forms' `:deck` rings (Hisagi's sickle dot, KESSA's clone dots) | kept (`hud-stick`) |
| A cinematic's letterbox and brush title (Kikon, awakening, Bankai), the big words (COUNTER, GUARD BREAK …) | kept (`hud-draw`, `draw-words`) |
| The intro's FIGHT! word (canvas, never under the HTML / Lisp HUD) | gone; READY / 斬 (§14) |
| The plates, gauges, timer, combo, callouts, pointer row, KOSEI tag, brush callout columns, the pause, the menus | not drawn by the canvas since 2026-10-28 (the HTML, then Lisp drew the plates, timer, combo, callouts under the plate, pointer seals, pause and menus). The KOSEI 攻 tag and the brush callout columns had no HTML or Lisp twin, so players have not seen them since 2026-10-28; their data (`*brush-callouts*` entries in brush.lisp, barro, rukia, senjumaru, ichigo-look) is now never drawn: dead data for D1 / B8c |

**What stayed only for the frozen modes and the retired kits (one cut for D1 / D2).**

- D2 (ENDLESS / DANGAI): endless.lisp's and rogue.lisp's screens (`hud-endless-results`, `hud-endless-clear`, `hud-endless-tag`,
  `hud-rogue-doors`); hud-screens.lisp's `hud-menu`, `hud-select`, `hud-select-portrait`, `results-card` and `hud-draw`'s `:select` /
  `:results` / `:clear` / `:doors` clauses (WEBUI-SCREEN gives 0 for ENDLESS's SELECT and RESULTS); hud.lisp's `hud-text`, `*white*`,
  `*dim*`, `*dim-ink*`, `*ember*`, `*shade*`, `hud-dt`, `alpha!` (also vfx.lisp's), and `hud-battle`'s ENDLESS tag; onehand.lisp's
  `note-menu-row`, `tapped-row`, `tap-third`, `*menu-rows*`, `touch-tap-zones-p`, flow.lisp's `menu-tap-p` / `menu-tap-third` and
  `menu-nav`'s `tapped-row`, webhud.lisp's `*menu-rows*` reset in the pause. (The portrait block geometry stays after D2: the deck uses it.)
- D1 (retired kits): their kit meters' `:draw` hooks, now called by nothing (only the canvas panels called them): rukia-meter.lisp's
  `rukia-hud-meter`, `hud-temp`, `%hud-temp`, `hud-temp-label`; senjumaru.lisp's `senju-hud-meter` (and its consing probe); barro-draw.lisp's
  `br-hud-meter`; hud.lisp's `*refused-t*`, `refused-flash`, `hud-refused` (feedback.lisp's `:refused` handler) serve only them;
  `hud-stick`'s frost arc (a `:temp` meter: Rukia's).
- **D1 leftovers, done (refactor R5, 2026-11-12, REFACTOR_2026-11 §11.3 R5):** `*refused-t*` / `refused-flash` / `hud-refused` (the `:refused`
  event keeps its dud tick, nothing else), `hud-stick`'s frost arc, `*brush-callouts*` (never read: brush.lisp's table and Ichigo's
  append), the retired kits' `*brush-names*` entries, the `*hurt-cines*` Yamamoto entries, `hud-pulse`, `bcap-restart`, `push-in-on`, flow.lisp's
  `*mode-menu*` / `settings-items` / `settings-note` / `*results-menu*` (canvas menu data, no reader). The D2 half (ENDLESS / DANGAI screens) stays R4's.
- engine/lisp/ui.lisp is untouched (engine API; its now-unused exports are refactor batch B1's), as `page-set-str` (§16.1).

**Proof.** Host tests: duel-rules 10260 (tests/duel-rules/hisagi.lisp's label check follows `*ic-bunshin-labels*`; sim.lisp's `kosei!`
call), duel-control 100, hud-engine 121, touch 100, input 33, cine 18, learn 131: all pass. pkgcheck: only `DUEL::APP`, 0 undefined
functions; the build's undefined-variable warnings the same five as before. Measurements and the walks: §16.7.

### 16.7 Measurements and walks after both commits

| What | 562acb37 | after the HTML (§16.1-§16.5) | after the canvas (§16.6) |
|---|---|---|---|
| index.wasm | 13,151,359 B | 13,047,301 B | 12,740,973 B (gzip -9 4,014,784) |
| dist/duel | 13,836,990 B, 17 files | 13,587,942 B, 11 files | 13,281,652 B, 11 files |
| Startup heap | 73.3 MB | 73.6 MB | 73.3 MB |

Debug 2519 (`--fixed-dt`; 1280 x 720 after 2500, 390 x 844 after 2505) and 2515: every entry 0 B in both runs (`lhud consing`, `1c`,
`p2`, `p34`, `flames`, `lmenu consing`, `webhud consing`). G2: native `simgate.py --cvc` and browser `style-gates.py cvc` identical to
tests/style-cvc-ref.txt (II 32, IK 34, KK 33 lines); a native match without turbo (4007, the HUD drawn every frame against the
stubbed empty atlas) also prints exactly the IK reference lines, in 21 s. Scripted walks (worktree `build/lhud/p7/w-*-c/`, keys on
desktop, touches on 390 x 844): TITLE -> MODE -> SETTINGS (HAND changed and back / CAMERA tapped) -> CONTROLS -> SELECT -> the
intro (both name cards, READY, 斬) -> the battle -> the pause (CAMERA changed) -> resume -> 2497 (K.O.) -> the finish -> RESULTS ->
REMATCH -> RESULTS -> CHARACTER SELECT -> TITLE; PRACTICE's pause list; CPU VS CPU through RESULTS; MODE > MANUAL opens manual.html;
83000 / 83010 / 83012 at both sizes; 360 x 640; ENDLESS's run (80103) and STAGE CLEAR (80980) on the canvas; the stick ring (2505, a
held touch): exit 0, no console error, no 404, the same `duel ->` lines as the first commit's walks. The looks gate's scripts walk as
before (their menu keys are the desk walk's); its baseline changes wholesale with this batch (every menu and battle still), so it
needs a fresh BASE.

# DUEL_LISP_HUD — the HTML HUD and menus redrawn by Lisp (design, 2026-11-10)

Status: **design only, nothing built.** The source of the look is the HTML UI as it stands at main 5c212105
(`duel/web/hud.js`, `hud.css`, `menu.js`, `menu.css`; its record is DUEL_WEBUI). Background: DUEL_WEBUI §18,
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
  cheap part: a host test (`tests/lhud-charset-test.lisp`) fails with "re-run tools/sdf-bake.py" when a string in the data or
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

## 5. Phases

Every phase: host tests (duel-rules, control, input, touch, cine and the new lhud / tween tests), pkgcheck, `./build.sh duel`, a
smoke (`run.mjs` exit 0 and the heap line), G2 `--cvc` identical (the HUD is presentation only), the 0 B probe, and side-by-side
stills (HTML vs Lisp) of the same scripted scene the user reviews. The looks gate cannot prove byte-identity today
(REFACTOR_2026-11.md §10.2); it is not used as a proof here.

| Phase | Scope | Files | Proof / exit | Lines (est.) | Model | Parallel |
|---|---|---|---|---|---|---|
| 0 spike | RP_HUD with modes 0-2, a minimal bake (sans + display tier, the plate's and combo's strings only), one plate's name / kanji / tag, the combo count with `hd-stamp`, `*hud-renderer*` + 2517 | render.c, a new hud shader, `engine/lisp/paint.lisp`, `tools/sdf-bake.py`, `duel/lisp/lhud-battle.lisp` (stub) | measured: wasm bytes, startup heap, frame ms (before / after), consing; stills at 390×844 dpr 3 and 1280×720 / 1920×1080 dpr 1 of the smallest sizes (.62u mono ≈ 8 CSS px at 1280, ≈ 6 at 390; menu 10 px mono, 11-12 px zh) with the densest kanji (鏡 鍵 鐮 觸 覺 鬥). Exit: the user finds the smallest text legible next to the HTML; 0 B; wasm and heap within the estimates ±50 % | ~900 | Opus | |
| 1a bake + build | the full bake (four faces, two tiers, packing), the MANIFEST binary step, the charset test, licence files | tools/sdf-bake.py, build.sh, tests/lhud-charset-test.lisp, duel/hud-font/, duel/FONT-LICENSE-* | the test fails on a missing glyph and passes on the data; atlas size as estimated | ~450 | Sonnet | with 1b, 1c |
| 1b paint | modes 3 and the patterns, polygons with the fringe, strokes, radial fans, the affine / opacity / clip stacks, the back layer and blend 4 | paint.lisp, render.c, render.lisp, the shader | engine host tests where pure; stills of a test card (shapes, rings, a halftone, a reveal) | ~700 | Opus | with 1a, 1c |
| 1c text, tween, layout, input | run layout (CJK wrap, kinsoku, vertical), the run cache, styles; tween.lisp; layout helpers; the hot-box registry; `pf_mouse_xy`; pwa.js keys 5-8 | `engine/lisp/sdf-text.lisp`, `tween.lisp`, `layout.lisp`, platform.c / .lisp, pwa.js | host tests: easing against CSS reference values, wrap and kinsoku cases, clamp / anchor math | ~900 | Opus (text), Sonnet (tween, layout) | with 1a, 1b |
| 2 battle, landscape | plates (bar, flames, kit strip, meters, seals), clock, combo, callout, prompt; the data file's battle tables | lhud-data.lisp, lhud-battle.lisp | side-by-side stills of scripted fights (both sides' callouts and combos, low Reishi, a Kikon at stake, awakening, sublimation, Kenpachi's NOME / UDE / KAIHO, PRACTICE ∞); the user's first review | ~900 | Opus | with 5 |
| 3 overlays | pause (desktop and phone), intro card and READY / 斬, finish (K.O., TIME, draw) | lhud-overlay.lisp | stills through each phase of the intro and finish, the pause with PRACTICE's long list | ~500 | Sonnet | after 2 |
| 4 phone | portrait plates, the deck, the plate on the line, 爆 (ink level, ticks, rings, arm / deny / slosh), the stance seals, the clock tab, touch ink, left hand | lhud-deck.lisp | `--mobile` stills at 390×844 with touch scripts (tap, flick, hold), both hands | ~800 | Opus | after 2 |
| 5 menus I | the backdrop, rails, cut, TITLE (wordmark, halftone 魂, ash), MODE (rows, brush, seals, torn card), SETTINGS, RESULTS | lhud-menus.lisp | stills of each screen at 1440×900 and 390×844, the cut mid-way, hover and tap through the hot boxes | ~1,000 | Opus | with 2 |
| 6 menus II | CONTROLS (tabs, key map, binds, capture), the phone gestures page, SELECT (cards, weights, emblems on the back layer, the model spot computed in Lisp) | lhud-menus.lisp (+ lhud-select.lisp) | stills of SELECT's three phases with the fighter between the layers, at both sizes | ~800 | Opus | after 5 and 1b |
| 7 acceptance | the user plays both; the default flips to `:lisp` on his word; then the removals (hud.js / menu.js / css, the canvas HUD) are his decision | flags, docs | the user's playtest | small | main session | |

Total ≈ 7,000 lines including tests and the bake tool (estimate), of which ≈ 2,500 engine, ≈ 4,000 game, ≈ 500 tools / tests.
Below §704's 8-12k because the model layer exists and the atlas is static (no runtime rasteriser or cache). Order of review:
phase 0's stills, then phase 2's battle (the screen seen most), then phase 5's menus, which can be built in parallel in a second
worktree once phase 1 lands.

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

# DUEL_WEBUI — the HTML / CSS / SVG menus

The user, 2026-10-28: 「你能否使用 js, css 與 html 跟 SVG 構築全新的 UI/UX 選單介面呢？」, then a design draft (Artifact
「SOUL DUEL Menus」, the ink-and-paper manga spread), then 「不用，幫我接入遊戲中吧」.

## 1. Decisions (asked 2026-10-28)

| Question | Answer |
|---|---|
| Frozen entries (MODE's ENDLESS / DANGAI; SETTINGS' TAP SPLIT, LEARNING CPU, AUTO GUARD / COMBO / BREAK, RESET LEARNING) | 「隱藏」: not shown; their code and saved values stay |
| SELECT: the plaza's two models vs the draft's three big cards | 「照設計稿的大卡」: the cards; the picked fighter is drawn inside the focused card |
| Behind the menus | 「透出 3D 場景」: the engine's scene shows through a translucent ink layer |
| The Lisp-drawn menus | 「保留為備援」: drawn when the page has no HTML menus (the native gate, an old page) |
| SELECT's background (mid-task) | 「選角畫面現在會在廣場上畫出雙方的 3D 模型時，將人物以外的背景設為透明」: on SELECT the canvas is transparent except the fighters |

Then (2026-10-28): 「讓 service worker 也把字型存起來」 (`sw.js`: the Google Fonts CSS and files cache-first in `soulduel-fonts`, kept
across builds); 「選角保持」 (the fighters' blob shadows and Kenpachi's aura stay drawn on the transparent SELECT).

Defaults chosen: the draft's VS card is dropped (the intro cinematic is the versus moment); the pause menu, the battle HUD and the
cinematics stay engine-drawn (until §6-§7, 2026-10-28: the battle HUD, the pause and the intro / finish's text are the page's too).

## 2. Who owns what

- **Lisp owns the flow and every decision** (`flow.lisp`): the screen, the cursor, the select phases and rows, the settings, the
  bindings, every key and pad press (SDL reads them as before). The browser scripts that drive the menus by keys keep working.
- **The page only renders** (`duel/web/menu.js`, `menu.css`) what Lisp publishes, and sends back what a pointer or a touch did on
  its rows. It never acts on a key itself (no double press) and keeps no copy of options or bindings.
- **Layers** (z order, bottom to top): `#ui-back` (card fills, the big kanji, the ink wash) → the canvas → `#ui` (text, rows,
  seals). On SELECT the canvas is transparent outside the fighters, so they stand between the two layers; elsewhere the canvas is
  opaque (alpha 1 everywhere) and `#ui` is a translucent wash over it. In battle both layers are `display: none`.

## 3. The page protocol (gamePage get / set, the block 30000+)

Set (Lisp → page), only when the value changed:

| Key | Value |
|---|---|
| 30000 | screen: 0 none (battle, intro, finish, pause, ENDLESS / DANGAI screens), 1 title, 2 mode, 3 settings, 4 controls, 5 select, 6 results |
| 30001 | the cursor (`*menu*`, in the screen's visible rows) |
| 30002 | select phase (0 P1, 1 P2 / CPU, 2 the rows), 30003 P1 pick, 30004 P2 pick (roster indices), 30005 difficulty 0–2, 30006 mode (0 VS CPU, 1 PRACTICE, 2 VS PLAYER, 3 CPU VS CPU), 30007 camera behind 1 / side 0, 30008 the select rows' kinds (bits: 1 difficulty, 2 camera) |
| 30009 | controls: column 0–3 (P1 key, P1 pad, P2 key, P2 pad) + 10 while capturing; 30010 the gestures page (a phone) 1 / 0 |
| 30011 | menu ready: 1 once the screen takes presses (the title after 0.3 s, the results after 2.5 s) |
| 30020–30031 | results: 30020 winner (0, 1, 2 draw), 30021 seconds, 30022–30026 P1 damage / Kikons / perfect Hohos / best combo / Konpaku left, 30027–30031 P2's |
| 30040–30044 | settings: the five visible rows' option indices |
| 30050–30057 | controls: the current column's eight bindings (1 + the name's place in `*bind-keys*` / `*bind-pads*`) |

Get (page → Lisp):

| Key | Value |
|---|---|
| 30000 | 1: the page has the HTML menus |
| 30001 | the next queued command, 0 = none (drained each frame in `flow-update`, outside the sim step) |
| 30002 / 30003 | SELECT: the focused card's model spot (x, y), permille of the window |

Commands: `screen × 100000 + cmd × 1000 + arg`; Lisp drops one whose screen is not the current one (a quick double click). cmd 1
cursor = arg; 2 confirm; 3 back; 4 left; 5 right; 6 pick roster index arg (select phase 0 / 1); 7 settings visible row r option o
(arg = 10 r + o); 8 controls column arg.

## 4. The engine side

- `camera-shift-x` (engine): a horizontal lens shift like `camera-shift-y` (ndc x += shift). Reset outside SELECT every frame.
- A transparent scene for SELECT: the stage is not drawn, the scene clears to alpha 0, the composite passes the scene's alpha out; the
  canvas is configured `premultiplied`. With the flag off every frame is byte-identical (the looks gate).
- SELECT's camera (web UI on): the fighter being picked, framed at the focused card's model spot (get 30002 / 30003).

Engine side, as built (2026-10-28):

- `camera-shift-x` (engine/lisp/render.lisp, exported): the camera slot next to `shift-y`, default 0. `update-camera` sets
  the projection's `(m@ pr 0 2)` to −shift, so ndc x += shift: +0.4 moves the image right by 0.2 of the window width
  (256 px at 1280; the still below). 0 leaves the matrix untouched. Nothing in the engine or `camera.lisp` resets it: the
  flow sets it on SELECT and puts it back to 0 outside SELECT.
- `*render-transparent*` (engine, exported): a one-frame latch that `end-frame` passes as `r_frame`'s rp[22] (`*rp*` 22 → 23
  floats) and then clears. When on, `r_frame` skips the sky (the scene target's clear is already 0,0,0,0) and composites
  through a new pipeline, slot 18 `RP_COMP_A` = `fs_comp_a` in composite.frag.wgsl: `fs_comp`'s image, its colour clamped to
  0–1, with alpha = max(the scene's alpha, the brightest channel), so bloom and additive glows stay a valid premultiplied
  colour. The transparent frame takes this path even under `*grade-impact*`. `RP_COMP`, `RP_COMP_FX` and `fs_comp` are
  untouched.
- `*scene-transparent*` (duel/lisp/draw.lisp, default NIL): when T, `draw-scene` skips `stage-draw` (floor, walls, town,
  ruins, the ash, cracks, marks, chips) and sets `*render-transparent*` for the frame. The fighters, their weapons, ink
  hulls, auras, their blob shadows (from `draw-body`) and the particles still draw. The ash flakes already in the air live
  out their 6 s. NIL = the old code path. Debug 2514 toggles it, 2520+k sets `camera-shift-x` = (k − 30) / 100 (DUEL_GAMEPLAY).
- `duel/web/alpha.js` (loaded first in head.html, listed in sw.js): wraps `GPUCanvasContext.prototype.configure` to add
  `alphaMode: 'premultiplied'`. Every other frame writes alpha 1 everywhere (the composite's 1.0, then the UI blend keeps
  it), so the page behind never shows. Checked with a green body: SELECT after toggling 2514 back off and a CPU vs CPU
  battle show no green.
- Proofs (BASE = c3a029f's build): the looks gate 115 of 115 stills byte-identical, the 15 scenarios' sim lines equal (its
  four `cvc-ys / hy / ir / bk fighters` name checks fail on BASE alike: the retired roster); G2 ii / ik / kk identical to
  style-cvc-ref.txt; host tests ALL PASS (duel-rules 10799, touch 71); pkgcheck 0 / 0 / 0; debug-ranges-check 0 errors;
  engine-check 71 pass, 2 fail (the `%ui-poly4` / `ui-rect` consing checks, failing on BASE too). Browser stills at 1280×720 with
  a green body: SELECT after 2514 + 2120 shows only the two fighters (their shadows, Kenpachi's aura, three leftover ash
  flakes) on green; 2590 moves Ichigo from x ≈ 270 to ≈ 530 px. Cost when off, 60 s of real-time CPU vs CPU (4003, twelve 5 s
  stats lines each, SwiftShader): BASE render 0.40 ms / queue 1.82 ms / 78.6 fps, new 0.41 / 1.73 / 83.4 (noise).

## 5. As built (2026-10-28)

- **Lisp** (`duel/lisp/webui.lisp`, new; `flow.lisp`): `webui-p` (get 30000, asked once), `webui-sync` (the §3 values, set only on a
  change: `*ui-sent*`, no consing), `webui-commands` (the queue; one press a frame, so two rights are two steps). The presses are
  `*ui-press*` bits that `menu-up-p` … `confirm-p` / `back-p` read with the keys, so every screen's logic is the old one. `hud-draw`
  skips a screen the page draws (`webui-on-screen-p`); the frozen ENDLESS / DANGAI screens stay engine-drawn.
- **Frozen rows hidden** in both renderers: MODE is `*mode-rows*` (keywords: VS CPU / PRACTICE / VS PLAYER / CPU VS CPU / SETTINGS /
  CONTROLS / MANUAL; dispatch by key, `mode-row` for the cursor on return), SETTINGS is `settings-shown` (`*settings-hidden*`;
  `*settings*` keeps its order for the saved rows) + BACK. ASSIST's three settings are ignored for a core kit (`assist-config`): a
  saved AUTO GUARD ALWAYS could no longer be turned off once hidden.
- **SELECT**: `*scene-transparent*` on while the page draws SELECT; `menu-camera`'s `:select-web` frames the fighter being picked
  (P1 in phase 0, P2 after) from his front, 3.9 m (portrait 7.2), moved to the focused card's spot by `camera-shift-x` / `-y`
  (the page measures it: above the card's text; on a phone beside it). `main.lisp` zeroes `camera-shift-x` every frame before the
  camera.
- **Page** (`duel/web/menu.js`, `menu.css`, from the design draft): built on load, drawn in a rAF only when a value changed; no key
  handling of its own (a passive keydown only picks the hint chips); pointer-down refocuses the canvas so SDL keeps the keys. Google
  Fonts (offline: the fallbacks); `sw.js` caches `menu.js` / `menu.css` / `alpha.js`.
- **Tests**: `tools/run.mjs` serves `.css` (and svg / png / json / webmanifest) with their types (a stylesheet as octet-stream is
  dropped). `tests/scripts/duel.py`'s row counts (VS PLAYER row 2, SETTINGS row 4, CAMERA two below HAND): `duel-flow`,
  `duel-practice` regenerated and checked (every `duel ->` / `duel setting` line as before). The ENDLESS / DANGAI scripts that enter
  by the MODE row no longer reach their mode (frozen; their debug entries still work).
- **Checks**: host tests (rules 10799, control 93), pkgcheck clean; browser shots of every screen at 1440×900 and 390×844 (title,
  mode, settings, controls, SELECT's three phases with the fighter in its card, results after a seeded CPU match). Sim gates (six
  pairings, 10 seeds) identical to the run before (KK 167.2, IK 192.6, II 231.6, HK 146.3, HI 204.1, HH 172.4 s); G2's three matches
  identical natively and in the browser (the page path).
- **A phone's SELECT, the fighter over the cards** (2026-10-28, the user: 「手持模式的選角畫面中，讓目前聚焦的人物可以放大到超出自身卡片，並且能蓋過其他
  卡片的文字」): the portrait camera's distance 7.2 -> 4.2 m (`:select-web`), so the focused fighter stands taller than his card; on a
  phone (max-width 760 px) the other cards' text (name, kanji line, the pick seal) is drawn by the `#ui-back` copy under the canvas
  instead of `#ui`, so he covers it; the focused card's own text stays over him. Shot at 390x844: Ichigo's blade reaches into
  Kenpachi's card.
- **A phone's Back, every time** (2026-10-28, the user: 「順便幫我處理下手持模式中沒有返回上一步的選項，請修改瀏覽器的「上一頁」功能來完成此目標」):
  the history trap (`pwa.js`, touch-first devices) already sent the browser's Back to Lisp as BACK in the menus and pause in a battle
  (`*back-press*`), but it re-pushed its entry inside `popstate`, with no user activation; Chrome's back-button intervention marks such
  an entry skippable, so the second Back left the page. Now a `CloseWatcher` (Chrome / Android, `typeof CloseWatcher`) takes Back
  itself and is made again after each close; the trap entry is pushed only on a tap (`pointerup`), and re-pushed in `popstate` only
  where there is no CloseWatcher (Safari, Firefox). Checked at 390x844 `--mobile`: `history.back()` on MODE -> TITLE, a tap re-arms,
  Esc (a key and a close at once) steps back once. iOS's installed app (standalone) has no Back gesture at all.

## 6. The battle screens in HTML: HUD, phone controls, pause, intro / finish (the user, 2026-10-28; built: §7)

The user's request (verbatim): 「幫我修改對戰與手機操作介面的 UI/UX」, with an award-tier brief (typography, whitespace, visual hierarchy,
color, motion, micro-interaction, responsive, originality; benchmark Awwwards / Webby / FWA winners; self-review until no gap remains).

| Question (AskUserQuestion) | The user's pick | Rejected |
|---|---|---|
| How they are drawn | **「改用 HTML/CSS/SVG 疊層（推薦）」**: as the menus, Lisp publishes the values, the page draws; the engine-drawn HUD stays as the fallback (no page: the native gate, an old page) | kept engine-drawn, redesigned there |
| Process | **「先出設計稿 Artifact（推薦）」**: an interactive draft (desktop landscape, phone portrait, both hands) first, then the integration | straight into the game |
| Scope | **all four**: the battle HUD (Reishi, Konpaku, flash step, awaken, the timer, combo and damage, callouts, the SP pointer, input hints), the phone controls (the one-hand dial, the gesture zone, touch feedback, left / right hand), the pause menu, the intro and the finish (VS / READY, K.O., the winner's moment) | |

Draft v1 (Artifact 「SOUL DUEL Battle Screens」, https://claude.ai/artifact/PY4irN8vNAk1eWf5XJKumq, over clean game frames captured with the
engine HUD switched off locally), the menus' tokens and faces:
- **Plates** hang from the top edge (P1 left, P2 right, mirrored; the phone: the foe at the top, you right above the gesture zone): the
  name (display face) + its kanji, the character's status tag (風死 · IN HAND for KAZESHINI IN), Reishi as a torn brush stroke (a blood
  ghost drains after the hit; under 25 % the stroke itself goes blood and pulses), nine soul flames (spent: a dashed outline; at stake: a
  blood outline that bobs), flash step's three cells and the awaken line in REIATSU, the SP pointer as three hanko seals carved with
  each pointer's theme glyph (Hisagi 投 / 刈 / 雷) and the live one's name.
- **One place per job**: the move's name (kanji + romaji) and the combo (a stamped count over a blood slash, its damage and scaling)
  only under the attacker's plate, never over the fighters. **Blood means now**: the combo, the last ten seconds, the souls at stake,
  the Kikon hold ring.
- **Prompts** at the bottom centre: the key and what it does now (SP · AS2 after J4; Hold SP with the 12-frame ring; Awaken ready).
- **Phone deck**: the lower 37 % is a screentone field split by one ink line (SP over ATK), a one-line gesture hint, the dial on the
  thumb's side as three seals 止 / 爆 / 覺 (the latter lit only when usable); every touch leaves an ink ripple, a flick a brush trail
  with the gesture named, a held SP its Kikon ring; left / right hand mirrored.
- **Pause**: the scene greys, a vertical 止 with a blood splash, one torn paper strip of numbered rows (EN + zh), the camera value.
- **Intro / finish**: letterbox, the name brushed down a vertical column with its romaji and cry, HISAGI vs KENPACHI, then READY > 斬;
  決着 brushed with a blood splat, K.O., the winner with Konpaku / best combo / Kikons on an ink scrim.

Draft v2 (the user, 2026-10-28: 「我希望手的的停止鍵做更上面，然後 SP 跟 ATK 沿著目前大約『覺』的位置往斜上方畫界分割」):
- The pause seal 止 leaves the deck: on the thumb's side, above the player's own plate (37 % + 17 u up).
- SP / ATK split by one ink diagonal from the 覺 seal up to the far edge (the deck's height 20 % at the far edge, 98.6 % at the near
  one): SP the upper side along the dial (爆 in it, 覺 on the line's foot), ATK the lower side under the thumb; the gesture hint runs
  along the line; the hit test is the same line (`y / h < .20 + .786 x / w`, mirrored for the left hand).
- Left hand: the player's plate, move name and combo move to the right (mirrored like P2's), the pause seal to the left.
- v3 (the user: 「分割起始點在往上一些」): the line's near end 98.6 % -> 82 % of the deck's height (the far end 20 % kept), now just above
  the 覺 seal; one pair of numbers (`Y0` / `Y1`) draws it and hit-tests it.
- v4 (the user: 「把覺醒鍵整合進爆氣中，改由長按覺醒」): the 覺 seal is gone; 爆 does both. Not ready to awaken: the Burst fires on the
  press, no wait. Ready: the seal wears a REIATSU ring, a release before 0.3 s is the Burst, a hold of 0.3 s fills the ring and awakens
  (the old AWK chip's 0.3 s hold). For the integration: the touch layer's AWK chip folds into RV (touch.lisp / onehand.lisp), the
  manual's two rows become one.

Approved (the user, 2026-10-28: 「善哉！！幫我把整套接進遊戲中」): draft v4 goes into the game, all four parts (§7, as built).

Status: built 2026-10-28 (§7).

## 7. The battle screens as built (2026-10-28)

The user, 2026-10-28: 「善哉！！幫我把整套接進遊戲中」 (draft v4 of §6, all four parts). Same architecture as the menus (§2): Lisp
decides and publishes, the page draws; every key, pad and touch press is Lisp's (the HUD layer is `pointer-events: none`, so the
touches reach the SDL canvas and the recogniser); only the pause rows take a pointer, queued back as commands.

### 7.1 Files

- `duel/lisp/webhud.lisp` (new, after webui.lisp): `webhud-p` (get 30100, asked once), `webhud-sync` (every frame of a battle,
  set-on-change: `webhud-put` compares a fixnum array, `webhud-put-str` compares by EQ then STRING=), `webhud-commands` (the
  pause rows' queue, get 30101), `webhud-side` (a DEFUN-FAST per plate), `webhud-prompt`, `webhud-deck`, `webhud-pause`.
- `duel/web/hud.js`, `hud.css` (new; head.html loads them after the menus; sw.js caches them): built on load, drawn in a rAF only
  when a value changed or a timed fade ends; the menus' tokens and faces (menu.css `:root`); its classes avoid the menus' global
  ones (`.hphone` `.hkey` `.crow` `.htag` `.hptr`).
- Engine: `page-set-str` (platform.lisp, exported) → `pf_page_set_str` (platform.c, an EM_JS: `gamePage.setStr(k, UTF8ToString(s))`;
  engine.h; the native sim's stub in tools/simgate/stubs.c): ASCII only (other characters go as `?`), a preallocated 256-byte
  buffer, 0 B. Every kanji (names, theme glyphs, the callouts', the tags', 決着 / 時間切れ) is the page's own table.
- `pwa.js` routes get / set / setStr 30100–30299 to `globalThis.gameHUD`.

### 7.2 The protocol (gamePage get / set / setStr, the block 30100+)

Set (Lisp → page), only when the value changed:

| Key | Value |
|---|---|
| 30100 | layer bits: 1 a battle (intro / fight / finish), 2 a cinematic (the plates hidden), 4 paused, 8 the phone's deck (ONE-HAND in portrait, in the fight), 16 PRACTICE (no timer), 32 the cinematic's 2D layer is the page's (the intro, the K.O., TIME), 64 ONE-HAND turned to landscape (the pause says rotate) |
| 30101 | the timer, seconds (−1 none: PRACTICE) |
| 30102 / 30103 | the prompt (the first human side's): 0 none, 1 the Kikon's hold (arg: its confirm frames left, of `*core-kikon-confirm*` 12), 2 SP → AS n off a landed attack (arg n), 3 a Burst (1 BLUE, 2 ORANGE), 4 the awakening (or the Bankai) ready |
| 30104 | 爆's bits: 1 the awakening's hold is armed (ready), 2 the hold under way, 4 pressed, 8 a burst possible |
| 30105–30110 | the last recognised gesture: a serial, its kind (1 tap ATK, 3 tap SP, 2 flick (Step), 6 up-flick (dash), 4 Hoho, 7 a down-flick Burst; the rest is no event), x, y (‰ of the window), the stroke dx, dy (‰) |
| 30111–30113 | the Kikon hold ring: 1 while a thumb held in the SP zone keeps an NS / AS going, its x, y (‰) |
| 30114 | the intro's phase: 1 P1's name (frames 0–119), 2 P2's (120–224), 3 READY (225–249), 4 斬 (250: the FIGHT! beat), 0 none |
| 30115 / 30116 | the finish: 1 K.O., 2 TIME with a winner, 3 TIME, a draw; the winner 0 / 1 / 2 draw (`*winner*`, else the K.O.'s first actor) |
| 30117 / 30118 / 30119 | the pause: the cursor (`*menu*`), the rows' count, a serial (the rows re-sent: on opening, after `pause-do`) |
| 30130–30133 | the deck (`*deck-rect*`: the window's lower `*deck-frac*` 37 %): x0 y0 x1 y1, ‰ |
| 30134 / 30135 | the tap zones' line (`*deck-split*`): its height in ‰ of the deck's at the far edge (200) and at the thumb's (820) |
| 30136–30138 / 30139–30141 | 爆 (chip 7) and 止 (chip 6): centre x, y (‰ of the window), radius (‰ of the width): the recogniser's hit circles (+ its 8 px slop) |
| 30142 | the left hand 1 |
| 30150 + 30 s + k | side s (0 P1, 1 P2): k 0 roster index + 1, 1 Reishi ‰, 2 red (the Kikon's must-hit line), 3 Konpaku left, 4 the souls at stake (`at-stake`), 6 flash step ‰, 7 the awakening ‰, 8 its state (0 filling, 1 ready, 2 awakened / an awakened form), 9 the SP pointer (0: no core kit), 10–13 the combo this side deals (the victim's hits, damage, the last hit's scaling ‰, a serial per counted hit: from the 2nd, PRACTICE's from the 1st), 14 the callout's serial, 15 / 16 the kit meter's value / max, 17 / 18 best combo / Kikons, 19 human 1 |

Strings (setStr, ASCII): 30220 + 4 s the name label (`kit-hud`: "ICHIGO  KESSA"), + 1 the status tag (a kit's `:hud-tag` hook:
Hisagi's KAZESHINI IN / OUT / ..., KESSA's BUNSHIN xN; else the meter's label NOME / UDE), + 2 the callout's romaji (the page's
table gives the kanji; romaji alone when unknown); 30228 the prompt's keys (`key-prompt` :sp-keys / :p-key / :awaken-keys,
from the bindings; none on the phone); 30229 the AS's romaji; 30230 + i the pause rows (`pause-items`; "LABEL  VALUE" splits into a
row and its value chip); 30250 / 30251 the page-drawn cinematic title's reading and line (`bcap-reading` / `bcap-sub`: KUROSAKI
ICHIGO, ZANGETSU).

Get (page → Lisp): 30100 = 1 (hud.js loaded); 30101 the next queued pause press, `7 × 100000 + cmd × 1000 + arg` (1 the row under
the pointer, 2 confirm; 4 / 5 left / right reserved), dropped unless the pause is up, one press a frame.

### 7.3 What the engine leaves to the page (under `webhud-p`)

The plates (`hud-side`, `hud-side-portrait`), the timer, PRACTICE's tag, the callouts (`hud-world`'s, the brush column `side-cap`),
the pointer row at the feet (`hud-pointer`), the deck's outline, line, chips and gesture glyph (`hud-deck`), the pause overlay, the
intro's FIGHT! word (`intro-cine`: READY > 斬 instead), and the letterbox and title of the intro, the K.O. and TIME
(`webhud-cine-p`; their slice-out too: `*web-caption*`). Kept engine-drawn: the speed lines, the red soul flame over a red
fighter, HOHO! / AUTO, ENDLESS's tag, the big words (EVOLUTION …), the thumb's stick ring and the kits' `:deck` rings (KESSA's
clone dots, Rukia's frost), every other cinematic's letterbox and title, the screen flashes. Without the page every one of them is
drawn as before (the native gate, an old page: `webhud-p` NIL).

### 7.4 The input changes (Lisp, the recogniser)

- **The slanted line**: `touch-split!` (engine touch.lisp) sets a line over a rect (the deck), `touch-hi-at-p` tests a point
  against it (beyond the rect the edges' heights; none set: the pad's level `tap-split` as before). `%tap!` (the tap's zone) and
  `core-touch-sp-p` (the Kikon hold's zone) both use it. onehand.lisp `*deck-frac*` 0.37, `*deck-split*` (0.20 0.82) (the far edge,
  the thumb's edge; mirrored for the left hand: `deck-split-ends`). Before: the pad's level middle (y 50 %). The flow pad (where a
  gesture may start) keeps its 2026-09-27 size (460 CSS px from the bottom, ~54 % of an 844 px phone): above the deck it is all SP.
- **爆 does both**: `touch-chip-tap-p` (a hold chip let go before its hold: a pulse, latched for one vpad read like the gestures'),
  `touch-chip-hold!` (a chip's hold for its next press; a running press keeps its own). `onehand-frame` sets chip 7's hold to 300 ms
  while `rv-ready-p` (`awaken-hold-ready-p`: a Mod + P would awaken or take the Bankai from this state, the form not `:no-awaken`;
  a form's `:p` hook is left out: Kenpachi's is DANGAI's frozen card, Hisagi's FREE is in his `:no-awaken` Bankai), else 0.
  `rv-buttons` (control.lisp): down without a hold = P (the Burst on the press); with it, Mod + P once held (the awakening), P alone
  for the read of an early lift (the Burst). The AWAKEN chip (5) is off screen.
- **The chips' spots** (`*chip-spots*`, in the draft's unit U = 2.36 % of the width): 止 (chip 6) 6.7 U from the thumb's edge, its
  bottom 17 U above the deck, r 3.1 U; 爆 (chip 7) 6.7 U in, its top 22 % down the deck, r 3.7 U. Before: pause (32 px from the edge,
  under the HUD's top block, r 22), RV (170 / 472, r 22), AWAKEN (270 / 396, r 26).
- The engine's fallback deck (`hud-deck`) draws the same slanted line, 爆 with its REIATSU ring, no AWAKEN chip.

### 7.5 Checks (2026-10-28)

- Host tests ALL PASS: duel-rules 10782, touch 94 (the slanted line both hands, the chip's early lift, the hold kept through a
  press), duel-control 99 (`rv-buttons` on the recogniser and a vpad: not ready the Burst on the press; ready a tap the Burst on the
  lift, a 300 ms hold the awakening and no Burst on its lift; readiness lost mid-press keeps the hold), input 33, cine 18; pkgcheck
  0 / 0 / 0; debug-ranges-check 0 errors (2515 claimed).
- The sim did not move: `simgate.py --pairs 2,7,9,29,31,35 --seeds 10` identical to the run before the change (KK 167.2 s, IK
  192.6, II 231.6, HK 183.8, HI 190.4, HH 295.7, the same KOs and wins); `--cvc` 3 PASS; the browser G2 (`style-gates.py cvc`)
  identical to style-cvc-ref.txt (ii / ik / kk).
- Consing: debug 2515 in a battle, 100 calls each: `webhud-sync` 0 B, `webhud-side` 0, `webhud-prompt` 0, `webhud-deck` 0,
  `webhud-tag` 0, `at-stake` 0, the deck's four `touch-button` reads 0 (`rv-buttons`' second value by MULTIPLE-VALUE-BIND) (`at-stake` was 24 B a call: `konpaku-at-stake`'s NTH-VALUE consed its value list; a MULTIPLE-VALUE-BIND now,
  which also cuts the engine HUD's). The stats line, 60 s of real-time CPU vs CPU (`duel-perf.json`, 1440x900, SwiftShader): BASE
  (85dc72d) cons/frame 3.4–4.7 KB, queue 1.6–2.3 ms, render 0.33–0.44 ms; with the page's screens 2.3–3.7 KB,
  0.7–1.0 ms, 0.24–0.40 ms (the engine HUD is not drawn). The fps line on SwiftShader is noisy and lower with the page (BASE 45–93,
  new 37–61): the DOM layer's compositing in a CPU renderer; hiding the layer mid-run did not give a clear difference. G3 (`style-gates.py perf BASE dist/duel duel`, A B A B A B, 45 s
  real-time runs): frame 33.7 → 35.1 ms median, B / A = 1.042; startup heap 87.2 MB both; first frame 5260 → 5620 ms (+7 %, under the
  +10 % line). The SP → AS prompt checked by a dump: after HS-J1's hit, kind 2 arg 1 for its cancel window, then 3 (ORANGE).
- Shots (1440x900 and 390x844 `--mobile`, both hands): neutral, a combo (the callout and the count under the attacker), the Kikon
  hold (the 12-frame ring prompt; the deck's hold ring), red / souls at stake / the awakening ready, 爆's hold ring filling, the
  pause (desk and phone), the intro (P1's and P2's columns, 斬), the K.O. (2208), the touch ink (a still of the tap ripple, the
  flick's trail and name: `gameHUD.still(true)` holds them for a test still, since the page's animations run in real time).

### 7.6 The phone's nudges (the user, 2026-10-28)

> 「1. 請將我方的 HUD 下移約 0.5 cm 2. 爆氣鍵上移約 0.5 cm 3. 戰鬥畫面中心向上偏移約 0.5 cm」「沒改戰鬥系統所以不用跑對戰測試」

0.5 cm = 18.9 CSS px (96 an inch); phone (portrait) only.

| What | Knob | Old → new |
|---|---|---|
| Your own plate, its move name and combo count (`hud.css`, `#hud.hphone`; not under `.nodeck`) | `--low` | 0 → `.5cm` lower |
| 爆 (chip 7's centre, the hit and the drawn seal alike; `onehand.lisp` DECK-LAYOUT) | `*rv-lift*` | 0 → 18.9 CSS px up |
| The portrait battle frame's centre (the lens shift + `*pcam*` [1], set by DECK-UPDATE; `camera.lisp`) | `*pt-center-lift*` | 0 → 18.9 CSS px up |

Checks: duel-control 99 and touch 94 ALL PASS, pkgcheck 0 / 0 / 0, a 390x844 `--mobile` shot before / after. No sim gate (the
user: no battle rule moved; the camera and the chips are presentation and touch spots only).

### 7.7 The second nudges, the line's lift, no hit flash (the user, 2026-10-29)

> 「1. 請將我方的 HUD 再次下移約 0.5 cm 2. 爆氣鍵再次上移約 0.5 cm 3. 戰鬥畫面中心再次向上偏移約 0.5 cm 4. SP 與 ATK 的分割線下界往上
> 0.5 cm，上界往上 1 cm」「沒改戰鬥系統所以不用跑對戰測試」, then 「打中對手時不要讓螢幕閃爍白光，這種原本沒有的特效讓視覺上很不舒服」

| What | Knob | Old → new |
|---|---|---|
| Your own plate, move name and combo count | `--low` | `.5cm` → `1cm` |
| 爆 | `*rv-lift*` | 18.9 → 37.8 CSS px |
| The portrait frame's centre | `*pt-center-lift*` | 18.9 → 37.8 CSS px |
| The SP / ATK line: its upper (far) end, its lower (thumb's) end | `*deck-split-lift*` (new; DECK-UPDATE applies it over `*deck-split*` into `*deck-split-at*`, which the recogniser, the page (30134 / 30135) and the fallback deck read) | 0 0 → 37.8 18.9 CSS px up |
| The SP label (`.zl.sp`, out of the lifted line's way) | `top` | 36 % → 18 % of the deck |
| The hit's screen flash (`.flash`, a paper overlay for 0.18 s on each counted hit, added with the page HUD) | removed | |

Checks: duel-control 99, touch 94 ALL PASS, pkgcheck 0 / 0 / 0, 390x844 `--mobile` shots (neutral, a combo). No sim gate (the user).

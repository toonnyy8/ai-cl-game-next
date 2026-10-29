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
| 30104 | 爆's bits: 1 the awakening's hold is armed (ready), 2 the hold under way, 4 pressed, 8 a burst possible; your running burst 16 WHITE, 32 BLUE, 64 ORANGE (since draft C, §11) |
| 30105–30110 | the last recognised gesture: a serial, its kind (1 tap ATK, 3 tap SP, 2 flick (Step), 6 up-flick (dash), 4 Hoho, 7 a down-flick Burst; the rest is no event), x, y (‰ of the window), the stroke dx, dy (‰) |
| 30111–30113 | the Kikon hold ring: 1 while a thumb held in the SP zone keeps an NS / AS going, its x, y (‰) |
| 30114 | the intro's phase: 1 P1's name (frames 0–119), 2 P2's (120–224), 3 READY (225–249), 4 斬 (250: the FIGHT! beat), 0 none |
| 30115 / 30116 | the finish: 1 K.O., 2 TIME with a winner, 3 TIME, a draw; the winner 0 / 1 / 2 draw (`*winner*`, else the K.O.'s first actor) |
| 30117 / 30118 / 30119 | the pause: the cursor (`*menu*`), the rows' count, a serial (the rows re-sent: on opening, after `pause-do`) |
| 30130–30133 | the deck (`*deck-rect*`: the window's lower `*deck-frac*` 37 %): x0 y0 x1 y1, ‰ |
| 30134 / 30135 | the tap zones' line (`*deck-split-at*`: `*deck-split*` less `*deck-split-lift*`): its height in ‰ of the deck's at the far edge and at the thumb's (draft C, §11: 1 cm under the top, 0.82 less 2 cm) |
| 30143 | the pad's top (the recogniser's touch area), ‰ of the height: the deck's paper is drawn up to it (§11.1) |
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

### 7.8 The opponent's count, the line again, 爆 on the bar, the centre again (the user, 2026-10-29)

> 「對手的 hit 數提示請放在與我方相反方向」「1. SP 與 ATK 的分割線再次將下界往上 0.5 cm，上界往上 1 cm 2. 爆氣鍵對齊血量表」「沒改戰鬥系統所以一樣不用
> 跑對戰測試」「戰鬥畫面中心再次向上偏移約 0.5 cm」

| What | Knob | Old → new |
|---|---|---|
| The opponent's combo count in left-hand mode (it sat on your side once your block moved right) | `#hud.hphone.left-hand .combo.p2` | right → left (right-hand: already opposite) |
| The SP / ATK line's lift (upper, lower end) | `*deck-split-lift*` | 37.8 18.9 → 75.6 37.8 CSS px; the upper end is clamped at the deck's top edge (on 390x844 the deck is 312 px and the far end stood 62 px down) |
| 爆's centre | `*rv-on-bar*` 9.12 U over the deck's top + `*plate-low*` 37.8 (= `--low`) | level with your Reishi bar's middle (measured: 485.3 vs 485.6 px on 390x844); `*rv-lift*` retired |
| The portrait frame's centre | `*pt-center-lift*` | 37.8 → 56.7 CSS px |

Checks: duel-control 99, touch 94 ALL PASS, pkgcheck 0 / 0 / 0, 390x844 `--mobile` shots, both hands. No sim gate (the user).

## 8. Draft v5: 爆 on your Reishi, the clock as the pause (the user, 2026-10-29; not built yet)

> 「請幫我為手持模式設計將爆氣鍵與血量鍵結合的 UI，並將暫停鍵與時間顯示結合（練習模式顯示時間為無限符號），先修改 Artifact 設計稿給我看。」

The draft (the same Artifact, version 5; it also catches up with §7.6–§7.8 as built: your block 1 cm lower, the line at 0 / 70 %
of the deck on 390x844, no hit flash):

- **爆 × Reishi**: the 爆 seal (7.4 U, as before) is pressed over the thumb-side end of your own Reishi stroke, overlapping it by
  1.6 U, so the plate and the button are one object (left hand: mirrored, the seal at the stroke's left end). The seal's outer ring is
  the awakening gauge (the plate's yellow line moves into it, filling clockwise); full, it glows and a 覺 tab lights on top. Tap =
  Burst; ready, a 0.3 s hold = Awaken (an inner sweep). The plate's name row leaves the seal's width free. Desktop: unchanged.
- **The clock = the pause**: on the phone the timer is a paper tab at the top-left (92 x 74 CSS px on 390x844, a cut corner),
  the digits over `II 止 PAUSE`; a tap pauses (it inverts while pressed). The 止 seal over the deck is gone. PRACTICE shows ∞
  (the desktop clock too, not pressable there: Esc / its key).
- To build once approved: Lisp places 爆's spot from the plate (as §7.8 already does) and the pause chip's spot from the clock tab;
  the page draws both there (DUEL_WEBUI §7.2's 30136–30141), `*plate-low*` / `--low` unchanged.

### 8.1 Draft v5's review loop (the user, 2026-10-29: the award-tier OBJECTIVE / CHECK / LOOP brief again)

Artifact version 6. Two passes over the eight checks, each patched and re-shot (390x844 both hands, PRACTICE, the pause):

| Check | Gap found | Patch |
|---|---|---|
| typography | the clock tab's `止 PAUSE` at 0.62 U (≈ 5.7 px), the 覺 tab at 1 U | 1.0 U mono / 1.45 U kanji; 覺 1.25 U |
| whitespace | the foe's plate ran under the clock tab | the phone's P2 plate 30 → 27 U (a 1.6 U gap) |
| hierarchy / color | the ready ring (2.2 stroke + a strong glow) outshone the blood cues | 1.7 → 2.1 when ready, a slow 1.6 s breath instead of a glow |
| hierarchy | the phone's AWAKEN prompt repeated the seal's 覺 tab and sat on the split line; any prompt's ring read 毀 | no awaken prompt on the phone; the ring only for a hold (the Kikon) |
| originality / typography | ∞ was a fallback font glyph | an ink stroke (SVG lemniscate) that writes itself in 0.9 s; the tab gets a punched hole (a 札) |
| motion | the pause's 止 appeared from nowhere | it grows out of the tab you pressed (0.42 s from the top-left) |
| micro-interaction | a Burst press gave no feedback on the seal; 覺 just appeared | a blood ring spills off the seal; 覺 stamps in |
| responsive | none found (the phone mock at 2.36 cqw, the bars wrap) | |

### 8.2 Draft v6: 起筆, your Reishi drawn out of the 爆 seal (the user, 2026-10-29)

> 「你現在的做法只是把覺醒鈕疊到血量的開頭上，兩個完全沒有一體感，甚是還遮蔽了一部分的血量顯示。你覺得應該要如何修正」, then the pick
> 「起筆：血從印章流出（推薦）」 (rejected: 刀柄, the bar as a blade out of a tsuba; 膠囊, one capsule frame round both).

Artifact version 7. The seal is where the brush lands; the Reishi stroke starts at its rim (no overlap: v5 hid 1.6 U of it), flaring
through a neck (2.6 x 4 U, under the seal by 1.3 U) into it. Your phone stroke is anchored at the seal (flipped: the torn end is the far
one), so damage eats it from the far end back toward the seal and what is left always touches it; the neck turns blood with the bar
when low, slate at 0. The awakening ring covers 85 % of the circle with its gap facing the neck (rotated 207 deg; the left hand 27 deg).
The seal's dark halo is gone (it separated the two); the name row keeps 9.4 U clear for the seal and its ring.
To build: P1's phone Reishi fill anchors at the thumb's side (hud.css; the engine HUD's fallback unchanged), the neck an inline SVG.

## 9. Draft v6 in the game: 起筆, the clock tab, ∞, the soul flames (the user, 2026-10-29)

> 「1. 好，幫我接進遊戲 … 3. 靈魂的火焰做成動畫，然後被打掉的空缺以灰色小點表示」

- **起筆** (§8.2): on the phone with the deck, your plate's row is the Reishi stroke + an inline SVG neck (2.6 x 4 U); hud.js sizes the
  plate from Lisp's 爆 spot (30136–30138) so the neck runs 1.3 U under the seal (right hand: width = cx − r + 1.3 U − 2.2 U; left:
  mirrored). The stroke is anchored at the seal (flipped `scaleX(-1)`; the left hand unflipped), the neck blood when low, slate at 0.
  The seal's ring is P1's awakening (`--aw` from 30157), 85 % of the circle with its gap toward the neck (rotate 207 deg / 27 deg),
  the 覺 tab stamped in when ready, the 0.3 s hold's inner sweep. The plate's own awakening line and READY word are hidden there.
  Lisp unchanged for 爆 (`*rv-on-bar*` keeps it level with the bar).
- **The clock tab = the pause**: chip 6 is `(7.4 :clock 4.6 "II")` in `*chip-spots*`: its middle 7.4 U from the window's left (either
  hand) and `*safe-top*` + `*clock-tab-mid*` 7.4 U down, radius 4.6 U; the page draws the 10.4 x 8.4 U tab centred on it (30139 /
  30140), the digits over `II 止 PAUSE`, a punched hole. The 止 seal is gone from the page; the pause's 止 grows out of the tab.
  The foe's phone plate 30 → 27 U (clear of the tab).
- **∞**: PRACTICE (30100 bit 16) shows the clock again with an ink lemniscate written in 0.9 s (desktop too: `PRACTICE · 練習`).
- **Soul flames**: each flame flickers on its own beat (three periods 1.35 / 1.6 / 1.9 s, transform only); a spent one bursts
  (the shatter, the flame fading after 0.15 s) and leaves a grey dot (0.38 U) where it stood.
- Checks: touch / control host tests, pkgcheck, `--cvc` (the sim untouched), phone shots both hands (see DEVLOG §467).

## 10. Draft v7: A 落款 / B 鍔, clearing the phone's middle (the user, 2026-10-29; not built yet)

> 「請幫我嘗試以下兩種設計，並產出對應的 Artifact 設計稿供我參考。1. 將我方的血量與魂魄放到最下面，並將閃步量表結合進爆氣鍵當中，當前架式提示
> 也放置爆氣鍵周遭減少視覺遮蔽。2. 基於 1，但是將血量與魂魄都整合到爆氣鍵周遭。」 (with the award-tier OBJECTIVE / CHECK / LOOP brief)

Artifact version 8 (the same draft; phone only, both drafts side by side, one at a time under 880 px; right / left hand; scenes
neutral, flash step, stance, combo, hurt, danger · ready, Kikon hold; an anatomy overlay naming the parts). Why: §9's plate sits
over your fighter's legs (above the deck); both drafts move everything of yours off the middle.

- **A 落款** (rakkan, the signature at a scroll's foot): your Reishi stroke (1.3 U) and the nine flames + name + tag run along the
  screen's bottom edge, 3.6 U over it (clear of the home indicator). The thumb's root covers that edge's thumb-side end, so the stroke
  is anchored at the far side and damage eats it from the thumb's side (the left hand mirrored). 爆 stays where it is
  (`*chip-spots*` chip 7). Round it: the awakening as a gold ring at 4.25 U (clockwise from the top), the flash step as three
  110 deg arcs at 5.05 U (10 deg gaps; a Step / Dash / Hoho spends one: it flashes, drops to slate, refills); the three pointer seals
  on an arc at 7.05 U on the seal's inner side (302 / 270 / 238 deg, the left hand mirrored), the pointer's name beside them; the 覺
  tab on top when ready. The callout and your combo sit on the far side over the deck (6.4 / 9.6 U up).
- **B 鍔** (tsuba): A, with the Reishi and Konpaku also on 爆: one guard (a 木瓜 four-lobed plate, r 6.5 U) centred 9.4 U from
  the thumb's edge and 2.8 U over the deck (A's 爆: 6.7 / −5 U), so the flames stay on screen. The Reishi is a 270 deg ring (r 5.45 U,
  1.06 U thick) from 7:30 over the top to 4:30, anchored at the far end (it drains from the thumb's side), blood ghost behind it; its
  bottom gap holds the flash step's three 18 deg pips; the nine flames stand round the top (r 7.35 U, 290–90 deg, spent ones from the
  thumb's side, grey dots); the gold awakening ring hugs the seal, ready = the seal's `RV` becomes 覺; the pointer seals at 7.75 U
  (258 / 232 / 206 deg); your name, the tag and the pointer's name as a caption on the inner side. A hit on you nicks the guard (a
  0.26 s shake; A: the bottom line).
- Trade-offs (as told to the user): B leaves the top half to the foe and the clock and needs one glance, but an arc's length reads
  worse than a bar's for "how much is left", and the guard (~16 U across, A's cluster ~11 U) is covered bottom-right by the thumb on a
  press. A keeps the straight bar but splits you between the bottom edge and 爆.
- To build once picked: Lisp's 爆 spot (chip 7) moves for B only; the touch circle stays 3.7 U; the deck's line, the foe's plate and
  the clock tab are unchanged; the desktop HUD unchanged.

### 10.1 Draft v7.1: 墨池, the flash-step gauge inside 爆 (the user, 2026-10-29; not built yet)

> 「由於爆氣需要消耗閃步量表，那何不就直接將量表做進圓圈中呢？」

Artifact version 9, both drafts. The rules as built (tuning.lisp): the gauge is 0–100, a Hoho costs `*fs-hoho*` 30, every Burst
needs `*fs-burst*` 70 and drains it to 0 at `*burst-drain*` 18 / s, regen `*fs-regen*` 3 / s after `*fs-delay*` 60 f; plain Steps and
Dashes are free (v7 wrongly spent a third per Step / Dash: corrected).

- The gauge is the ink standing in the 爆 seal, its height = flash-step / 100 (the web HUD's three-cell split, 33.3 each, never matched
  the 30 / 70 thresholds; the engine HUD's ticks did). Two marks on the far rim: 30 and 70.
- Under 70 the rim and 爆 are dim; a tap shakes the seal and writes `NO BURST · 70`. Crossing 70 lights the rim and 爆 and pops the
  seal once (armed). A running Burst drains the ink in its mode's colour (the engine's `*c-burst-white*` / `-blue*` / `-orange*`); a
  Hoho drops it by 30 with a slosh. The 爆 glyph is drawn twice, paper over the empty part and ink over the ink.
- A loses the outer three-arc ring (the cluster ~11 → ~9 U; the pointer seals move in, r 7.05 → 6.2 U); B's ring gap is left empty.
- To build: 30156 (P1's flash-step ‰) drives the level; the armed / running state from the gauge and 30104's burst bits (ready /
  can, §7.2); no Lisp change for the gauge itself.

### 10.2 Draft v7.2: the gauge 0–300, B's stance in the ring's gap (the user, 2026-10-29; the draft only)

> 「幫我將閃步量表改成 0-300，並且將 hoho 消費改成 100，爆氣設為 200，其他恢復量也做對應的提昇。先改 UI」, then
> 「將架式狀態改到靈子環下方缺口」 (B)

Artifact version 10.
- **墨池 0–300**: the ink's height = flash-step / 300; the rim's marks at the thirds, 100 (a Hoho) and 200 (every Burst), so the
  well reads as three bars. Under 200 dim / `NO BURST · 200`; crossing 200 arms it. The draft runs the new numbers: Hoho −100, the
  Burst's drain 54 / s (18 × 3: a full gauge still lasts 5.6 s, 200 → 0 in 3.7 s), the regen 9 / s (3 × 3) after 1 s.
- **B's stance in the gap**: the three pointer seals (1.9 U) stand in the Reishi ring's bottom gap (135–225 deg) at r 5.7 U, 203 /
  180 / 157 deg, read 1 → 3 left to right in both hands (not mirrored); the pointer's name under them (7.6 U down). The inner
  caption keeps only the name and the tag; the old seals' place (r 7.75 U, lower inner side) is free.
- **The rules, not changed yet** (「先改 UI」; the plan, everything that fills or spends the gauge × 3): `*fs-max*` 100 → 300,
  `*fs-hoho*` 30 → 100, `*fs-burst*` 70 → 200, `*fs-regen*` 3 → 9, `*burst-drain*` 18 → 54, `*fs-taken*` 0.045 → 0.135, `*kosei-fs*`
  0.10 → 0.30, `*kikon-fs-refund*` 35 → 105, the AS steals (`:steal-fs` Kenpachi / Ichigo / Hisagi 40 → 120, KESSA's chain 10 → 30).
  Not a pure × 3: a Hoho's share 30 → 33.3 %, the Burst's threshold 70 → 66.7 % of the gauge; the shared tuning gates all pairings
  (`2,7,9,29,31,35`) and the CPU's gauge reads (`*ai-burst-low*` etc.) are checked.

### 10.3 Draft v7.3: no marks in the 墨池 (the user, 2026-10-29)

> 「現在就不用額外的墨線了」

Artifact version 11: the two rim marks (100 / 200) are gone from the 爆 seal in both drafts; with the gauge at 0–300 the thresholds
are its thirds, and the seal lighting (armed) at 200 says when a Burst is possible.

### 10.4 Draft v7.4: B's guard bitten in under the gap (the user, 2026-10-29)

> 「靈子環下方缺口的深色環底請設計成向內凹陷，不要影響到架式印章」

Artifact version 12: B's dark 木瓜 plate (r 6.5 U) is concave under the Reishi ring's gap: 4.5 U across 146–214 deg (the seals'
inner edge is at 4.75 U), eased back to the rim by 130 / 230 deg, so the three stance seals stand on the scene and the plate no
longer runs under them.

### 10.5 Draft v7.5: a flat ink surface, the marks back (the user, 2026-10-29)

> (on 「墨面上方那條晃動的深色波紋」) 「對對對！幫我拿掉他」

§10.3's 「墨線」 meant the ink's moving dark surface wave, not the rim marks. Artifact version 13: the wave is gone (the level is
flat; a Hoho drops it by 100 and dips the seal 0.35 U once instead of sloshing); the 100 / 200 marks are back on the far rim as in
§10.2 (v7.3 removed them by that misreading).

### 10.6 Draft v7.6: the marks as red chords (the user, 2026-10-29)

> 「100 與 200 的兩道刻線去掉數字，並將刻線改成橫切到對面，跟外圈一樣的紅色線，但不要碰到中間的『爆』與 RV 字體。」

Artifact version 14: the 100 / 200 marks lose their numbers and become chords across the whole seal at 1/3 and 2/3 of its height
(clipped by the seal's circle), 1.5 px in the rim's red: dim (`rgba(232,30,58,.4)`) with the rim under 200, full blood once armed
(a 0.5 s flash on arming); each is cut 1.6 U either side of the middle, so neither touches 爆 or RV.

### 10.7 Draft v7.7: the chords closer to the glyphs (the user, 2026-10-29)

> 「更貼近字體一些」

Artifact version 15: each chord's cut is fitted to the text it passes: the 200 chord (through 爆) stops 1.35 U from the middle,
the 100 chord (through RV) 1.05 U (both were 1.6 U), about 0.3 U clear of the glyphs.

### 10.8 Draft v7.8: the chords white (the user, 2026-10-29)

> 「改成白色」

Artifact version 16: the two chords are white (paper) instead of the rim's red: half-bright (`rgba(238,238,234,.45)`) under 200, full
once armed. They are drawn like the glyph: each face of the seal (the empty part, the ink) carries its own pair, so over the empty
seal a chord is white and inside the ink it is ink-dark (70 %), and it never vanishes on the white ink of a gauge over 200. Both
faces are clipped to the seal's circle.

### 10.9 Draft v7.9: C 界, the Reishi bar as the SP / ATK line (the user, 2026-10-29)

> 「幫我新增一個 C 版，是使用血條與魂魄代替原本的 SP 與 ATK 分界線」 (after asking which of A / B the assistant prefers: B, for one
> glance point, no palm over it and the unity; the caveats an arc's readability and the guard's size)

Artifact version 17: three phones (one at a time under 700 px). **C 界** keeps A's 爆 (墨池, the gold ring, the pointer seals) and
lays your Reishi stroke on the deck's split line itself: the bar's middle on the line (the far edge at the deck's top, the thumb's
edge 70 % down the deck), drawn by `hypot()` / `atan2()` of the screen, so it follows any aspect; the flames, name and tag on the SP
side above it. What is left is anchored at the far end and drains from the thumb's end; the empty track (a 1 px paper hairline over
ink) keeps the boundary drawn at any Reishi. The old ink line is not drawn. Touch is unchanged: above the bar's middle SP, below ATK.
The bar is read on a slant and lies where the thumb taps SP / ATK.

### 10.10 Draft v7.10: A / B's SP label at the thumb's edge (the user, 2026-10-29)

> 「幫我將 A / B 的『SP 技』標示往側邊偏移」

Artifact version 18: in A and B the deck's `SP 技` label moves from 40 % across / 20 % down the deck (by the fighters' feet) to the
thumb's edge, 5 % in from it and 44 % down the deck: under 爆 (B: under the guard's gap and the stance seals), above the split line,
which is 70 % down at that edge. The left hand mirrors it. C keeps its own place (over its slanted bar).

### 10.11 Draft v7.11: the screentone up to the deck's top (the user, 2026-10-29)

> 「再將網點延伸到觸控區的上界」

Artifact version 19, all three drafts: the deck's screentone dots (7 px grid, 18 % steel) no longer fade in over its top 40 % (a
mask, transparent → opaque at 40 %); they run at full strength up to the deck's top edge, so the dots alone mark where the touch
zone begins. The dark gradient under them is unchanged.

### 10.12 Draft v7.12: A / B's SP label 0.8 cm up (the user, 2026-10-29)

> 「『SP 技』標示往上偏移 0.8cm」

Artifact version 20: A / B's `SP 技` label (§10.10) 0.8 cm (30.2 CSS px) higher: `top: calc(44% - .8cm)` of the deck at the thumb's
edge, still under B's stance seals and the pointer's name. C's label unchanged.

### 10.13 Draft v7.13: C's SP label at A / B's place (the user, 2026-10-29)

> 「C 的 SP 標示移到跟 A, B 同樣的位置」

Artifact version 21: C's `SP 技` label leaves its place over the slanted bar (6 % down, 46 % across) for A / B's (§10.10, §10.12):
5 % in from the thumb's edge, `calc(44% - .8cm)` down the deck, above C's bar there. All three drafts now share it.

### 10.14 Draft v7.14: the SP / ATK line's ends moved in (the user, 2026-10-29)

> 「幫我將 SP / ATK 分割線的下界上移 1 cm，上界下移 0.5 cm」

Artifact version 22: the split line's upper (far) end moves from the deck's top edge to 0.5 cm under it, its lower (thumb) end
from 70 % down the deck to `calc(70% - 1cm)`. The deck carries both ends as `--y0: .5cm` / `--y1: calc(70% - 1cm)`; the SP / ATK
zones' clip paths, the line (now a 2 px clip-path band instead of an SVG line, mirrored per hand), C's slanted Reishi bar (its far
end 0.5 cm down, its rise `25.9cqh - 1.5cm`) and the draft's touch split (`isSp`, in CSS cm scaled to the phone) all read them.
The SP label (§10.12) stays above the line at the thumb's edge in A, B and C, both hands. Draft only: the game's touch split
(`onehand.lisp`) is unchanged until a version is chosen.

### 10.15 Draft v7.15: the line's far end 1 cm down, 爆 1 cm down (the user, 2026-10-29)

> 「上界再次下移 0.5 cm，爆氣鍵下移 1 cm」

Artifact version 23: `--y0` .5cm → 1cm (the line's far end 1 cm under the deck's top; the thumb end stays at `calc(70% - 1cm)`);
C's bar follows (far end 1 cm down, rise `25.9cqh - 2cm`) and so does the draft's touch split. The 爆 cluster moves 1 cm down in
every version: A / C `top: calc(63% - 5u + 1cm)`, B `calc(63% - 2.8u + 1cm)`. In both hands 爆, its stance seals and B's guard stay
clear of the SP label and the line.

## 11. Draft C 界 in the game, the flash-step gauge 0–300 (the user, 2026-10-29)

> 「我選 C，然後幫我套用新的閃步量表規則」

Draft C (§10.9, as it stood at v7.15, artifact version 23) is the phone's battle screen; the rules change is DUEL_DESIGN
"Flash-step gauge 0-300". What the phone (portrait, one hand) now draws, all where Lisp lays it out:

| Part | Now | Before (draft v6 in the game, §9) |
|---|---|---|
| The SP / ATK line | far end 1 cm under the deck's top, thumb end 2 cm over 82 % (`*deck-split*` 0.20 0.82 → 0.0 0.82, `*deck-split-lift*` 75.6 37.8 → -37.8 75.6 CSS px); the recogniser hit-tests the same line | far end at the top (0.20 less 2 cm, clamped), thumb end 1 cm over 82 % |
| Your plate | 界: the Reishi bar's middle on the line, the far edge to the thumb's (hud.js lays it from 30130–30135: length, angle, its far end the anchor); flames, name, kanji and tag above it on the SP side; what is left stays at the far end; the empty track keeps the line drawn (no separate line, no gesture legend) | 起筆: a level plate 1 cm under the deck's top, the stroke out of 爆 through a neck; the ink line and `FLICK ↑ DASH …` along it |
| 爆 | its middle 5 U over the deck's top + 1 cm (`*rv-on-bar*` 9.12 → 5.0, `*plate-low*` 1 cm), 6.7 U in from the thumb's edge, r 3.7 U | level with the plate's bar |
| Flash step | 墨池: the ink standing in 爆 by height (30156), white chords at 1/3 (a Hoho) and 2/3 (a Burst), cut 1.05 / 1.35 U each side of the middle; under 2/3 the seal is dim (rim at 40 %, 爆 grey), from 2/3 armed (rim and 爆 lit, a flash on arming); a running Burst turns the ink its mode's colour (30104 bits 16 / 32 / 64) as it drains; a Hoho dips the seal; a press under 2/3 shakes it and writes NO BURST | three cells under your bar |
| Awakening | a gold ring hugging 爆 (r 4.25 U), clockwise from the top (the left hand counter-clockwise), the hold sweep and 覺 as before | the ring with a gap where the neck entered |
| Stance | your three pointer seals on a circle of 6.2 U around 爆 at 304° / 270° / 236° (mirrored for the left hand), the live one inked, its name 9.4 U to the far side | three seals in your plate |
| SP / ATK labels | SP at the thumb's edge 5 % in, `calc(44% - .8cm)` down the deck (under 爆, over the line); ATK 8 % in, 16 % up | SP 44 % across, 18 % down |
| Your move name / combo | just over the deck: 6.4 U / 9.6 U | over your plate (15.5 / 19 U, less 1 cm) |
| Screentone | to the deck's top edge (draft v7.11) | faded in over the top 40 % |

The foe's plate, the clock tab, the prompt, the pause and the landscape / two-hand screens are unchanged. Code: `onehand.lisp`
(`*deck-split*`, `*deck-split-lift*`, `*rv-on-bar*`), `webhud.lisp` (30104's burst bits), `hud.js` (`renderDeck`: the slanted plate, the
ink, the states; the stance cluster `.rvc`), `hud.css` (界, 爆, the cluster). Checks: host tests (rules 10661, control 99, touch 100,
input 33), pkgcheck clean, the page's Lisp path 0 B (debug 2515), smoke; shots at 390 × 844 in both hands (a full, a 60 % and a
draining gauge, a kit without pointers). DEVLOG §504.

### 11.1 The deck's paper up to the pad's top, your plate over it (the user, 2026-10-29)

> 「1. 請將觸控板的視覺範圍往上延伸 2. 目前我方角色的 HUD 被壓在觸控面板下面了」

- The deck's dark gradient and screentone now start at the pad's top (the recogniser's touch area, `deck-layout`'s pad: 460 CSS px over
  the window's bottom, so 148 px over the 37 % deck at 390 × 844), not at the deck's: what is drawn is where a touch counts. Lisp
  publishes the pad's top (30143, ‰ of the height); hud.js sets `--ext` (the gap to the deck's top) and `.deck::before` / `::after`
  reach up by it. The zones, the labels and the line stay on the deck.
- The deck drew over your plate (`.deck` z-index 12 over `.hudl` 10: the bar and the names were dimmed by its paper): the deck is now
  z-index 9, under the plates; 爆 and its stance seals (14) and the touch ink (15) stay over everything.
- Checks: the page's Lisp path 0 B (debug 2515), pkgcheck clean, shots in both hands. DEVLOG §505.

### 11.2 The line and your bar up, 爆 up (the user, 2026-10-29)

> 「1. SP/ATK 分隔線（血量等 HUD）下界上移 0.5 cm，上界上移 1 cm 2. 爆氣鍵上移 0.75 cm」

- The line (and with it your Reishi bar, its flames and name, and the recogniser's split): `*deck-split-lift*` -37.8 75.6 → **0.0 94.5**
  CSS px: the far (upper) end from 1 cm under the deck's top onto it, the thumb's (lower) end from 2 cm to 2.5 cm over 0.82.
- 爆 (and its ring, 覺 and the stance seals around it): `*plate-low*` 37.8 → **9.45** CSS px, its middle 5 U over the deck's top + 0.25 cm.
- The SP label rose with the line's thumb end, 0.5 cm (`calc(44% - .8cm)` → `calc(44% - 1.3cm)`), or it met the tag above the bar's
  thumb end. Shots in both hands; nothing else moves. DEVLOG §506.

### 11.3 Once more: the line and your bar up, 爆 up (the user, 2026-10-29)

> 「請再次執行以下修改：1. SP/ATK 分隔線（血量等 HUD）下界上移 0.5 cm，上界上移 1 cm 2. 爆氣鍵上移 0.75 cm」

- `*deck-split-lift*` 0.0 94.5 → **37.8 113.4** CSS px: the far end 1 cm over the deck's top, the thumb's 3 cm over 0.82. DECK-UPDATE no
  longer clamps an end at the deck's top (`(max 0.0 …)` gone): the pad reaches 148 px higher at 390 × 844, and the recogniser extends the
  line past its ends, so a touch over the deck's top follows the line too (over it SP, under it ATK).
- `*plate-low*` 9.45 → **-18.9** CSS px: 爆's middle 5 U + 0.5 cm over the deck's top.
- The SP label up 0.5 cm more with the thumb's end (`calc(44% - 1.8cm)`). Control 99 and touch 100 pass; shots in both hands. DEVLOG §507.

### 11.4 爆 under the line (the user, 2026-10-29)

> 「將爆氣鍵移到分隔線下面」

爆 moves to the ATK side, tied to the line: its centre `*rv-under-line*` **6.5 U** under the line's height at 爆's x (the line from
`*deck-split*` less `*deck-split-lift*`, computed in DECK-LAYOUT), 6.7 U in from the thumb's edge as before. Its top is 2.8 U (0.7 cm at
390 CSS px) under the line; its stance seals, gold ring and 覺 tab stay clear of your bar. It follows any later move of the line.
`*rv-on-bar*` and `*plate-low*` are gone (their history is in the new knob's docstring). The SP label stays above the line at the thumb's
edge. A tap on 爆 is its chip as before. Control 99, touch 100, pkgcheck clean; shots in both hands. DEVLOG §508.

## 12. The name SOUL DUEL NEXT and the badge icon (the user, 2026-10-29)

> 「幫我修改名稱與 icon 後推上 gh page」; asked, the user answered the name 「SOUL DUEL NEXT」 and the icon 「以代理死神證作為 icon」.

- **The name** players see: the page title and the loading logo (`duel/MANIFEST`'s `# title:`), the installed app (`manifest.webmanifest`
  `name` and `short_name`, `head.html`'s `apple-mobile-web-app-title`), the window title (`main.lisp`), the menus' rail mark and the title
  screen's wordmark (SOUL / DUEL and a small blood `NEXT` line at DUEL's indent, `menu.js` / `menu.css`), the engine's fallback title and
  mode screens (`hud-screens.lisp`, fitted to the width), the manual (title, header, credits: 「2026-10-29 前叫 SOUL DUEL」), the README.
  The code, the docs and the saved data keep the name SOUL DUEL (`soulduel.*` storage keys, the service worker's cache names), so a player's
  settings and learning tables carry over. `short_name` is the full 14 characters; a home screen may cut it.
- **The icon** (`tools/pwa-icons.py`, the four PNGs): the Substitute Shinigami Badge (代行証), drawn stylised: a dark-wood cross pattée with
  a pale rim and a few grain lines, a bone skull in its middle (dark sockets, nose, teeth), hung on a red cord from the top edge, on the
  dusk ink; the maskable one inside the 80 % safe circle. Drawn from the canon's description (a wooden pass with a skull whose eyes light
  on a Hollow alert), not traced from an image. Before: a pale soul ring cut by a red brush slash.
- Deployed to GitHub Pages on request (`tools/deploy-pages.sh`). DEVLOG §509.

### 12.1 The badge redrawn from the user's photo (the user, 2026-10-29)

The user sent a photo of the badge: a pentagon point down, a black rim, a white face, a black angular skull (flat top, cut corners,
two round eyes, a toothed jaw) over a black X whose bars run from the upper corners down and out past the rim, one badge with a hanging
tab. `tools/pwa-icons.py` now draws that: a pale edge (so the black rim reads on the ink), the black rim, the white face; the X's bars
from the face's upper corners to the middle of its far lower edges, cut by the rim, a white line down each; the skull and jaw; the tab
on the red cord. The first take (§12: a wooden cross pattée with a bone skull) was drawn without a reference and is gone. Redeployed.
DEVLOG §510.

### 12.2 Flatter, no cord (the user, 2026-10-29)

> 「稍微扁一點，然後為什麼有那條紅線？」

The red line was a cord the first takes hung the badge on (my addition, not on the badge): gone; the tab stays, as on the photo. The
badge is squashed to 0.84 of a regular pentagon's height (`FLAT`), sized up a little (R .44 → .46) and centred a little lower; the skull's
height 0.155 → 0.14. Redeployed. DEVLOG §511.


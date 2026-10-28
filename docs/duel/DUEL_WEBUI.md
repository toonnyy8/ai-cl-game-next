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
cinematics stay engine-drawn.

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

## 6. The battle screens in HTML: HUD, phone controls, pause, intro / finish (the user, 2026-10-28; in design)

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

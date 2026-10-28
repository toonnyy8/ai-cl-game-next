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

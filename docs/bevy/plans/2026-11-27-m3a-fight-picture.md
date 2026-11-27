# M3a The fight's picture (rig, clips, meshes, draw path, FX, cinematics, Bevy renderer, game loop) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A Kenpachi vs Ichigo fight is drawn by Bevy exactly as the frozen build draws it, and a keyboard player can fight the
CPU on a separate Rust playtest Artifact. The data each frame hands the GPU equals the frozen build's, and so does every clip's FK.

**Architecture:**
- **M3 is split into two plans** (the lead's call under BEVY_PORT §7: "the builder splits each").
  - **M3a (this plan)** is the fight's picture: the rig and clips, bodies, meshes and the stage, the draw path, FX, the cinematics' looks,
    the battle canvas words, the Bevy renderer, and the game loop with keyboard input.
  - **M3b** is the shell: the HUD and menus (the paint stream `hb` / `hk`), sound synthesis and playback, the touch deck, the saved-data
    protocol, the phone values (coarse, one-hand, scene scale), and the stills sheets of the whole looks gate.
  - M3a's page boots straight into a fight. In place of the HUD it shows a plain dev text line: the gauges, "PAUSED", and "K.O. — Enter
    to rematch". M3b replaces that line with the real HUD, the pause screen and the results.
- **The answer key is what the frozen build hands the C renderer.** In the native image, `RENDER-FRAME` passes everything a frame
  draws to one C call:
  - `r_frame(fu, p, dq, n, fxa, nfa, fxb, nfb, ui, nui, ft, nft, hb, nhb, hk, nhk)`: the frame uniforms (160), the post parameters
    (30, `render.lisp:215`), the draw queue (32 floats a record), and six vertex streams whose fills are float counts (strides 9 / 8 / 16:
    `render.lisp:264-271`, `ui.lisp:55`, `paint.lisp:38`);
  - every mesh through `r_mesh_new`.

  M0a's `tools/port/capture/stubs-capture.c` already records both. Task 1 widens it into the draw key `build/oracle/draw/`. The Rust
  side produces the same arrays as plain data (`duel_look::FrameOut`), and `duel-tools draw --check` compares them 1:1. The renderer
  (Task 9) only turns a `FrameOut` into Bevy draws, so the picture is proven before Bevy touches it.
- **The sim tells the looks through a queue, applied per step.**
  - Each `// look:` site in `duel-sim` (114 of them, M1_NOTES §8) pushes a `look::LookEvent` onto `Match.looks`.
  - `flow::sim_step` calls a `LookSink` at the place of Lisp's `FEEDBACK-SYSTEM`: after `god-update` / `probe-update`, before `hash-log` and
    `mc-full-step` (`main.lisp:30-45`).
  - The sink, `duel_look::Scene`, drains the queue there and reads the live state, as `feedback-system` does (`feedback.lisp:67-81`).
  - An event whose Lisp call reads the state before the step's systems run carries what it read in its payload. `slow-snapshot` saves the
    fighters before `sim-systems`.
  - `Scene` keeps its own state: the animation per entity, the FX pool, the camera, the cinematic looks and the cosmetic RNG. It never
    writes to `Match`.
  - A CPU rollout runs `sim-step-lean` (no feedback, no slow-snapshot, events dropped: `sim-state.lisp:43-52`), and its restore puts
    back the ECS and the cinematic roots (`sim-state.lisp:19-27`). So every push is muted while `m.in_rollout`, and the rollout passes a
    null sink.
- **The loop is the Lisp's loop, not Bevy's scheduler.** One Bevy `Update` system runs a frame in Lisp's order (`app.lisp` `%FRAME`,
  `main.lisp:143-150`, `draw.lisp:325-340`):
  1. `flow::frame(m, s, input, scene, dt)`: the commands, FLOW-UPDATE, the steps;
  2. `duel_look::draw_frame`: the camera, the stage, the fighters, the hazards, then `cine::cine_draw(m)` (unless turbo) at
     DRAW-SCENE's place, then the cinematic looks, stamps, FX and the canvas words;
  3. `flow::frame_end(m, s)`: FQ-MATCH-END's apply.

  The headless tools run the same three calls with a null drawer (`flow::frame_headless`). There is no `FixedUpdate`.

**Tech Stack:** Rust 1.99 (edition 2024), Bevy =0.20.1 (`duel-app` only), `libm` =0.2.16. Host ECL 24.5.10, gcc -m32 and Python 3 for
the Task 1 recorder. Node + headless Chrome (`tools/run.mjs`) for the page checks.

**Spec:** `docs/bevy/BEVY_PORT.md` (§1 the user's renderer choice, §3 browser and performance rules, §4 crates, §5.3 floats, §6
verification, §7 the M3 row). Also read:
- `docs/bevy/M1_NOTES.md`: §1 animation is a sink, §2 VIEW-STEP, §8 the `// look:` sites, §10's M3 items;
- `docs/bevy/M2_NOTES.md` §12 (the M3 carries);
- `docs/bevy/M0_NOTES.md`: §4 the answer key and the `fk/` format (`tools/port/oracle/look.lisp`'s header is authoritative), §6's M3 items;
- `docs/bevy/M0A_SPEED.md` and `rs/spikes/m0a/` (the toon `Material` that already ran on the phone);
- `docs/bevy/DIVERGENCES.md` §1 (Kikon's DURING forms move actors once per rendered frame);
- `tools/simgate/fulltest.lisp` (what a rollout must leave unchanged).

## Global Constraints

- **Freeze.** Lisp is frozen at tag `lisp-freeze` (395fd0b6). Never edit `duel/`, `engine/` or `tests/`. Never edit `tools/simgate/stubs.c`:
  gen.py hashes it into the sim key's provenance. Task 1's recorder lives in `tools/port/oracle/` and includes `stubs.c`, as
  `stubs-capture.c` does.
- **No redesign, no look changes.** A Lisp bug is ported as a bug and listed in `docs/bevy/DIVERGENCES.md`. A drift is fixed in Rust, never in the
  key. The dev text line (Task 10) is the one addition: it is temporary, marked `// dev: M3b replaces`, and M3b removes it.
- **Crates.**
  - `duel-look` depends on `duel-sim` and `duel-data` only: no Bevy, no clock, no `unsafe`.
  - `duel-sim` gains `look.rs`, the `LookSink` trait, the pushes at its `// look:` sites, and the `frame` / `frame_end` split. Its results
    must not change.
  - `duel-app` is the only crate with Bevy (=0.20.1, features trimmed for wasm).
  - A new dependency needs one line of reason in the task report.
  - `unsafe` only at the web boundary, each use commented.
- **Inside Bevy's renderer** (the user: 「全部用 Bevy 繪圖」). Each ported WGSL becomes a `Material`, a `SpecializedRenderPipeline` or a render-graph
  node. Nothing draws with raw wgpu passes outside Bevy's graph. The WGSL stays close to `engine/shaders/`. Every camera is built by
  `duel_app::camera_bundle()`, which carries the clustering fix (`ClusterConfig::None`; `GlobalClusterSettings::gpu_clustering = None`
  on the app: M0_NOTES §1).
- **Data, never retyped.** Clips, rig, bodies, poses, weapons, glyphs, stage, tuning and kit look plists come from `duel-data`. Missing
  values go into `tools/port/extract/extract.lisp`, then a re-extraction and a new checksum pin (now `3ddcd77c9a34edf5`). Code-valued
  data (kit `:pose` / `:draw` hooks, computed keys) is ported by hand and names its Lisp source (`// port: duel/lisp/<file> <FN>`).
- **Floats** (M1's rules): a bare literal is single-float; double only from `d0`, `(float x 1d0)`, double data and `pi`; CL contagion;
  every transcendental through `libm`; no `mul_add`; the CL helpers live in `duel_sim::cl`.
  - `pi`-derived look values come from the native image's long-float and differ from the wasm game in the lowest bits (accepted,
    presentation only: BEVY_PORT §5.3).
- **Tolerances against the key.**
  - FK and draw arrays: `|a − b| ≤ 1e-5 · max(1, |b|)` per float.
  - Integers exact: mesh ids, pipes, counts, stream lengths, the RNG state.
  - A mismatch report names the scene, frame, array, index and both values.
- **The key's fixed inputs are `Scene` / `FrameOut` inputs, never constants buried in the port.** Task 1 records each one in INDEX:
  - the viewport (`pf_width` / `pf_height` / `pf_density`);
  - the MSAA sample count (the stub's 1, so `fu[157]` = 0.5; `render.lisp:508`);
  - `*render-scale*` 1 and `*pixel-lights*` 8 (`r_timing` returns 0);
  - `*coarse*`, `*one-hand*`, `*scene-scale-cap*` (`pf_page_get` 0: a desktop window, `onehand.lisp:150-160`);
  - `*match-seed*`;
  - dt = `raw_dt(frame_n)` (the stub's clock alternates by 1 ns: `stubs.c:35-41`).

  Task 9 feeds Bevy's real sample count and viewport; M3b makes the phone values live.
- **RNG.** The cosmetic stream `rng_float` (`engine/engine.h`: xorshift32, `>> 8` × 2^-24; never reseeded by the game, so it runs from
  boot) is ported bit-exact into `duel_look::CosRng`. It is never the sim stream and never inside `Match` (a restore would roll it back;
  Lisp's C global is never restored). The key records its state per keyed frame.
- **Overflow drops are ported:** `stream-room-p`, the 512-record `*dq*`, `R_MAX_DRAWS`. A full stream drops what Lisp drops.
- **Hot path.** 0 heap allocations per rendered frame in the sink + `draw_frame` (a counting allocator in `duel-tools draw`, as the
  sim's 0-alloc gate). The sim keeps 0 per battle step. `FrameOut` and the event queue are preallocated and cleared, never reallocated
  in steady state.
- **The sim gates stay green after every task that touches `duel-sim`:**
  - `tools/port/replay-gate.sh`: 22 OK;
  - `replay-gate.sh --live`: 20 OK;
  - `cargo test`;
  - `duel-tools cvc --check $ORACLE/cvc-tag.txt`: 88 lines.
- **Scope.** Kenpachi and Ichigo, all their forms, and the stage. The Hisagi / Yamamoto looks are M4: their draw hooks and meshes resolve to
  `look_unported`, which the page surfaces. HUD, menus, sound, touch and saving are M3b.
- **Answer key path.** `ORACLE` = `/media/8tsp/projects/ai-cl-game-next-bevy/build/oracle`; every command takes it from `$ORACLE`.
- **Repo rules.**
  - Bounded waits only; never `pkill -f` / `pgrep -f`.
  - Subagents never push, merge, deploy or publish, and never edit the DEVLOG or the manual.
  - Never commit `build/`, `rs/target/`, `tests/shots/` or `*.profraw`.
  - Commit subjects start with `Bevy port M3a:`.
  - Ignore hook lines that say CONTEXT WARNING: they report the parent session.

## Review Focus

1. **Looks inside a CPU rollout.** The rollout mutes every push and passes a null sink. Lisp's rollout runs no feedback and restores the
   ECS. So after a rollout the queue, `Scene` and `CosRng` are unchanged. The key's per-frame RNG state proves no cosmetic draw was
   skipped. Test `rollout_leaves_scene_and_cosrng` (Task 4, on cvc-ki-s1 at a job tick).
2. **Slow motion, hitstop and pause draw between sim frames** (SLOW-SNAPSHOT inside the step, SLOW-DRAW in the frame: `main.lisp:30-45`,
   91-115). Debug 2513 (3 s of the cancel's slow motion) and a hitstop window are keyed. Test `slowmo_frames_match` (Task 5).
3. **A rendered rate other than 60 Hz.** At dt = 1/120 the sim steps every other frame, and the Kikon DURING forms run on every frame
   (DIVERGENCES §1, ported as is). At 1/30 two steps run before one draw, and the sink runs per step. Test `frame_rate_120_and_30`
   (Task 4 for the sink's anim / FX state per step; Task 10 for the `cine_draw` count during a cinematic).
4. **Portrait and landscape.** The projection, the letterbox (9 %) and the camera's framing follow the viewport. Task 1 keys one battle
   scene and one cinematic at 390x844, as a narrow desktop window, not the phone (coarse and one-hand stay off: M3b). Tests
   `portrait_scene_matches` (Task 7) and `cine_portrait_matches` (Task 8).
5. **The page meets something not ported** (a Hisagi pick, `m.unported`, `look_unported`, a cut CPU rollout, a Bevy device loss). The page
   stops the fight, draws the reason as text and logs it once. It does not freeze silently or panic in a loop. Test
   `unported_surfaces_on_page` (Task 10: a page script that starts Kenpachi vs Hisagi).

---

## File structure

```
tools/port/oracle/draw.lisp          Task 1: drives the frozen native image through the draw scenes (as capture.lisp)
tools/port/oracle/stubs-draw.c       Task 1: stubs.c + the recorder (r_mesh_new, r_frame's nine arrays), viewport, real HUD font
tools/port/oracle/draw-scenes.json   Task 1: the scenes (debug commands, viewport, frames to key)
rs/duel-sim/src/look.rs              Task 4: LookEvent, LookQueue, LookSink (+ NoLook)
rs/duel-look/src/lib.rs              re-exports; Scene; draw_frame
rs/duel-look/src/rng.rs              Task 4: CosRng
rs/duel-look/src/anim.rs             Task 2: clip sampling, the per-entity player (engine/lisp/anim.lisp)
rs/duel-look/src/rig.rs              Task 2: rig proportions, pose FK (engine/lisp/body.lisp, anim.lisp POSE-FK!)
rs/duel-look/src/mesh/               Task 3: meshgen, bodies, brush, Kenpachi / Ichigo art, stage
rs/duel-look/src/scene.rs            Task 4: Scene state, the sink
rs/duel-look/src/draw/               Task 5: frame.rs (FrameOut, fu / p), queue.rs, camera.rs, stage.rs, slow.rs
                                     Task 7: fighter.rs (draw.lisp), ken.rs / ichigo.rs (ken-look, ichigo-look draw and :pose hooks)
rs/duel-look/src/fx/                 Task 6: fx.lisp, fx-shapes.lisp, vfx*.lisp, feedback.lisp, the stage's cracks, the hazards' looks
rs/duel-look/src/cine.rs             Task 8: cinema.lisp + engine cine.lisp looks, the kits' cinematic looks
rs/duel-look/src/canvas.rs           Task 8: the battle canvas words of hud-screens.lisp:27-42 into the ui stream
rs/duel-tools/src/draw.rs            Task 5: `duel-tools draw --check FILE.bin` (+ --arrays, --frames, --mask), the alloc count
rs/duel-app/src/render/              Task 9: FrameOut -> Bevy (materials, passes), camera_bundle; WGSL under rs/duel-app/assets/shaders
rs/duel-app/src/game.rs              Task 10: the Update system, keyboard -> vpad, the start, the dev line
rs/duel-app/src/page.rs              Task 10: _debug_cmd, console lines, the stop message, the frame-done counter
docs/bevy/M3A_NOTES.md               every task's findings; Task 11 closes it
```

---

### Task 1: The draw key

**Files:**
- Create: `tools/port/oracle/stubs-draw.c`, `tools/port/oracle/draw.lisp`, `tools/port/oracle/draw-scenes.json`
- Modify: `tools/port/oracle/gen.py` (a `draw` verb), `docs/bevy/oracle-index.json` (pin), `docs/bevy/M0_NOTES.md` §4 (a table row)
- Create: `docs/bevy/M3A_NOTES.md` §1 (the format, the scenes and what each command does, the fixed inputs, the sizes)

**Interfaces:**
- Produces: `build/oracle/draw/<scene>.bin`, `build/oracle/draw/meshes.json` and `build/oracle/draw/INDEX.json`. The format is documented
  in the `.c` header, which is authoritative:
  - `"SDDRW1\0\0"`, `u32 width`, `u32 height`, `u32 n_meshes`, `u32 n_frames`;
  - per mesh (only those the keyed frames draw): `u32 id`, `u32 n_floats`, then the f32s exactly as `r_mesh_new` got them;
  - per keyed frame: `u32 frame` (r_frame calls since the scene's start), `u32 tick` (`*tick*`), `u32 rng_state` (`rng_float`'s), then
    for each of `fu` (160), `p` (30), `dq` (n × 32), `fxa`, `fxb`, `ui`, `ft`, `hb`, `hk`: `u32 n_floats` and the f32s.
- `meshes.json` gives each id what made it (the body, part, prop or stage piece; written by draw.lisp after `sg-init`, and for the
  lazily built art on its first draw: `main.lisp:162-177`).
- INDEX records, per scene: the commands, viewport, frames, `*match-seed*`, sha1 and size. Once for the whole key: the fixed inputs
  (Global Constraints) and the image's build hash.
- Consumes: `stubs-capture.c` (copied and widened; the M0a file stays as is), `tools/simgate/prelude.lisp`, the SG_STUBS hook in
  `tools/simgate/build.lisp`.

- [ ] **Step 1:** Write `stubs-draw.c`:
  - Start from `stubs-capture.c` and record all nine arrays and the RNG state at the frames `DRAW_FRAMES` lists (env: a comma list or
    `a-b/k` ranges).
  - `#define`-rename `pf_width`, `pf_height`, `pf_density` as `r_frame` is renamed, and serve them from env `DRAW_W` / `DRAW_H` /
    `DRAW_DPR`.
  - Override `lhud_font` with the real atlas: `#include "duel/hud-font/lhud-font.c"`. Then `hb` / `hk` are what the browser gets, and
    M3b can use them; the stock stub returns 0, `stubs.c:76`.
- [ ] **Step 2:** Write `draw.lisp`. It starts as the page does (`sg-init`), writes `meshes.json`, queues a scene's debug commands before
  the first `%frame` (they start from the title, as M0a's 4003 did) or at their listed frames, and runs `ENGINE::%FRAME` (drawn, not
  turbo) until the recorder writes and exits 0. Exit 4 means the frame budget ran out.
- [ ] **Step 3:** Write `draw-scenes.json`, Kenpachi, Ichigo and the stage only. Confirm each command's meaning in `debug.lisp` /
  DUEL_GAMEPLAY "Debug commands" and write it into INDEX. The scenes:
  - **quiet** (Tasks 5-7: no intro, no cinematic, CPU off), 640x360, every 5th frame of 10 s:
    - 2500, 2501, 2502, 2503 (human vs idle CPU, cinematics skipped);
    - 2394-2397 (the string test, per form);
    - 84000, 84001, 84004, 84005 (Kenpachi's core scenes);
  - **slowmo**: 2500 then 2513, every frame of 3 s, and one hitstop window: a scripted J hit in 2501 via `tests/scripts`' key steps.
    Name the frames in INDEX;
  - **forms**:
    - 2505, then 2508 three times (P2 Kenpachi through his forms);
    - 84001 / 84004 / 84005;
    - 2394 / 2395 (Ichigo's forms);

    each form is keyed on 3 frames 20 apart;
  - **battle** (Task 8: everything at once): 2005 and 2006 (seeded CvC with the intro and every mid-match cinematic played), 640x360,
    every 10th frame of the first 60 s plus every frame of the looks gate's windows (`tests/style-gates.py` LOOKS_WINDOWS);
  - **portrait**: 2501 and 2005 at 390x844, every 30th frame of 30 s;
  - **cinematics** at their frames, every 5th frame, at 640x360:
    - held by CINE-AT 10000 + 1000 k + f for k in `*cine-names*` = 1, 6, 7, 8, 9 (`debug.lisp:389-392`), plus 35000+f;
    - played Kikons by their own commands: 84094 / 84095, 84006-84008 (`ken.lisp:1096-1112`), the cinematics in Ichigo's 74000-75599
      (`ichigo-debug`), and 75300+k;
    - one of them also at 390x844.
- [ ] **Step 4:** Add `gen.py draw [NAME...] [--check]`. It builds the image with `SG_STUBS=tools/port/oracle/stubs-draw.c`, runs each
  scene twice in fresh processes, requires the two `.bin` files to be byte-identical, then writes INDEX. `--check` counts and
  sanity-checks: every frame has `fu` (160) and `p` (30), every `dq` record's mesh id is in `meshes.json`, no float is NaN, and `hb` is
  non-empty in a battle frame.
- [ ] **Step 5:** Run it: `python3 tools/port/oracle/gen.py draw`.
  Expected: every scene `draw OK` twice, identical; INDEX written. Record the total size and time in M3A_NOTES §1.
- [ ] **Step 6:** Pin the INDEX's hashes in `docs/bevy/oracle-index.json`, and commit `Bevy port M3a: the draw key (r_frame's nine arrays,
  the RNG state and the meshes at keyed frames of N scenes)`.

### Task 2: Clip sampling, rig FK, the look host checks

**Files:**
- Create: `rs/duel-look/src/anim.rs`, `rs/duel-look/src/rig.rs`, `rs/duel-look/tests/fk.rs`, `rs/duel-look/tests/art.rs`
- Modify: `rs/duel-look/Cargo.toml`, `rs/duel-look/src/lib.rs`, `rs/duel-sim/tests/PORTED.md`

**Interfaces:**
- Consumes: `duel_data` clips / rig / bodies / poses / weapons.
- Produces:
  - `rig::Proportions::of(body: &Body) -> Proportions` (MAKE-RIG-PROPORTIONS);
  - `anim::sample(clip: &Clip, t: f32, key_ease: u8, out: &mut Pose)` (CLIP-SAMPLE!);
  - `rig::pose_fk(pose: &Pose, props: &Proportions, scale: f32, hunch: f32, root: &Mat4, out: &mut [Mat4; 21])` (POSE-FK!);
  - `rig::joint_point(m: &Mat4, local: Vec3) -> Vec3` (JOINT-POINT!);
  - `anim::Anim`, the per-entity player: `play(clip, speed, blend)`, `advance(dt)`, the crossfade (ANIM-PLAY / ANIM-ADVANCE).

  `Mat4` is column-major `[f32; 16]` in the engine's layout. No external math crate in `duel-look`.

- [ ] **Step 1:** Write the failing tests:
  - `fk_matches_key`: every clip file in `$ORACLE/fk/` (401 entries; skip any that is not a clip, such as an index). For each rig and form,
    sample every frame under `key_ease` and compare the 21 joint matrices and the weapon tip / base. Report the first miss per clip;
  - `anim_crossfade_blends` (a hand case from ANIM-ADVANCE: the blend weight at 0, half and full);
  - the host checks M1 left for the looks, with PORTED.md rows:
    - `tests/duel-rules/art.lisp`'s Kenpachi / Ichigo checks (the drawn reach against the hit volume, ±0.15 m) in `tests/art.rs`; the
      Hisagi / Yamamoto ones are M4;
    - triangle.lisp 120-124 (FIGHTER-STANCE-CLIP), 155, 156 (DEFCLIP-MIRROR poses), 167 (KESSA's clip names);
    - core.lisp 185, 186 (MV-CLIP-SPEED), 738, 740, 746, 747;
    - ken.lisp 52.
- [ ] **Step 2:** Run `cargo test -p duel-look`. Expected: FAIL (nothing ported).
- [ ] **Step 3:** Port `engine/lisp/anim.lisp` and the rig half of `engine/lisp/body.lisp` (`// port:` on every function). Both `key_ease`
  modes: 0 smoothstep, 1 ease-out cubic.
- [ ] **Step 4:** Run `cargo test -p duel-look`. Expected: PASS, every clip file.
- [ ] **Step 5:** Commit `Bevy port M3a: clip sampling and rig FK (N fk files within 1e-5), the look host checks`.

### Task 3: Meshes (meshgen, bodies, Kenpachi / Ichigo art, stage)

**Files:**
- Create: `rs/duel-look/src/mesh/{mod,gen,body,brush,stage,ken,ichigo}.rs`, `rs/duel-look/tests/mesh.rs`
- Modify: `tools/port/extract/extract.lisp` only if a body / prop / stage value is missing (then re-pin the checksum)

**Interfaces:**
- Consumes: Task 1's `meshes.json` and the meshes in the `.bin` files, `duel_data`.
- Produces:
  - `mesh::Meshes`: a sparse map from Lisp mesh id to `MeshData { floats: Vec<f32> }` (9 floats a vertex: pos, normal, sRGB colour, as
    `r_mesh_new` gets them);
  - `Meshes::build(data: &Data) -> Meshes`. It fills only the ids `meshes.json` names for Kenpachi, Ichigo and the stage. The Hisagi /
    Yamamoto ids stay empty and are listed as M4. The ids come from the extracted table, not from counting creation order;
  - `mesh::Ids`, the lookup the draw path uses: body part / prop / stage piece → id.
- Extract `meshes.json`'s table into `duel-data` (a data file), so the app never reads the key.

- [ ] **Step 1:** Write the failing test `meshes_match_key`: for every Kenpachi / Ichigo / stage id drawn in any Task 1 scene, the floats equal
  the key's and the count matches exactly. Report the first mismatched vertex.
- [ ] **Step 2:** Run `cargo test -p duel-look --test mesh`. Expected: FAIL.
- [ ] **Step 3:** Port in MANIFEST order:
  - `engine/lisp/meshgen.lisp`;
  - `duel/lisp/body.lisp`, `brush.lisp`;
  - the body / prop builders in `ken-art.lisp` and `ichigo-art.lisp` (the clips are data from Task 2, never ported here);
  - `stage.lisp`'s meshes, the cracks and chips included.
- [ ] **Step 4:** Run `cargo test -p duel-look`. Expected: PASS.
- [ ] **Step 5:** Commit `Bevy port M3a: meshes (N Kenpachi / Ichigo / stage meshes equal to the draw key)`.

### Task 4: The look queue, the per-step sink, the frame split

**Files:**
- Create: `rs/duel-sim/src/look.rs`, `rs/duel-look/src/scene.rs`, `rs/duel-look/src/rng.rs`, `rs/duel-sim/tests/look.rs`
- Modify:
  - every file with a `// look:` marker (`grep -rn '// look:' rs/duel-sim/src`);
  - `rs/duel-sim/src/state.rs` (`Match.looks`);
  - `rs/duel-sim/src/flow.rs`: the sink in `frame` / `advance_sim` / `sim_step`; `frame` stops before the draw; `frame_end`;
    `frame_headless`;
  - the callers in `rs/duel-tools`, `rs/duel-sim/src/cpu` (rollouts pass `NoLook`) and the tests;
  - `rs/duel-sim/tests/PORTED.md`.
- Docs: `M3A_NOTES.md` §2, the site table

**Interfaces:**
- Produces:
  - `duel_sim::look::LookEvent`, one variant per distinct Lisp call kind at the sites (`Clip { e: Entity, clip: u16, speed: f32, blend: f32
    }`, `AnimSpeed`, `AnimAdvance { e, dt }`, `SlowSnapshot { … what slow-snapshot saves }`, `Alpha`, `Rim`, `Weapon`, `Hide`, `Emit(Event)`
    for `*events*`' entries, `Sound`, `Cue`, `Camera…`, and so on). The fields are the call's arguments, or the state the call reads
    before the step's systems move it. The enum is `Copy`, with no `String` and no `Vec`;
  - `LookQueue { v: Vec<LookEvent> }`: `push(&mut self, e)` (a no-op while `in_rollout`; capacity 512, reserved in `Match::new`, enough
    since it drains every step), `drain(&mut self) -> impl Iterator`, `clear()`. `Match.looks` holds it;
  - `trait LookSink { fn step(&mut self, m: &mut Match); }`, called by `sim_step` at FEEDBACK-SYSTEM's place. It drains `m.looks` and reads
    the state; it writes nothing else. `NoLook` clears the queue;
  - the frame split, one per caller:
    - `flow::frame(m, s, input, look: &mut dyn LookSink, rdt: f32) -> bool`: the commands, FLOW-UPDATE and the steps, with dt as an
      argument (M1_NOTES §10);
    - `flow::frame_end(m, s)`: FQ-MATCH-END's apply;
    - `flow::frame_headless(m, s, input, look)`: `frame` with `raw_dt(frame_n)`, then `cine_draw` unless turbo, then `frame_end`. The
      tools' path, so the replayer's order is unchanged;
  - `duel_look::Scene::new(data: &Data, inputs: SceneInputs) -> Scene`, which implements `LookSink`. `SceneInputs` holds the viewport,
    the MSAA count, render scale, pixel lights, coarse, one-hand and scene-scale cap;
  - `duel_look::CosRng`: `seed(u32)`, `rnd01() -> f32` (`rng_float`'s bits), `state() -> u32`.
- Consumes: `Match.in_rollout`, Task 2's `Anim`.

- [ ] **Step 1:** Build the site table in M3A_NOTES §2. One row per `// look:` site:
  - the Lisp call;
  - the variant;
  - whether the call reads pre-step state (then its payload carries it);
  - the rollout rule (muted: `sim-step-lean` drops feedback and the restore puts back the ECS and the cinematic roots,
    `sim-state.lisp:19-52`; `tools/simgate/fulltest.lisp` asserts the specials).

  Also list, in call order, every cosmetic `rnd01` call reachable from the step's feedback or the frame (`grep -n 'rnd01' duel/lisp
  engine/lisp`).
- [ ] **Step 2:** Write the failing tests:
  - `queue_order_matches_sites`: replay `cvc-ki-s1` 600 ticks; the per-step event kinds equal a hand-checked expectation at three ticks (a
    move start, a hit, a K.O.);
  - `rollout_leaves_scene_and_cosrng` (Review Focus 1);
  - `frame_rate_120_and_30`: the sink's anim state per entity after the same steps is equal at dt 1/60, 1/120 and 1/30 (Review Focus 3);
  - `look_queue_no_alloc`: the 17 cvc rows' battle steps, 0 allocations with the queue and a counting sink on;
  - ecs-test.lisp's 4 event-queue checks (`emit` / `take-events` / `do-events`, deferred by M1) on `LookQueue`.
- [ ] **Step 3:** Run `cargo test -p duel-sim --test look`. Expected: FAIL.
- [ ] **Step 4:** Write `look.rs`, the pushes at every site (each marker becomes `m.looks.push(..)` with a `// look:` comment naming the Lisp
  call), the sink call, the frame split, and `Scene`'s sink for the anim variants (Task 2's `Anim` per entity, created on spawn). The FX,
  sound and camera variants are no-ops until Tasks 5-8, each marked `// task N`.
- [ ] **Step 5:** Run the tests and the sim gates (Global Constraints). Expected: PASS; 22 / 20 / 88 OK.
- [ ] **Step 6:** Commit `Bevy port M3a: the look queue (114 sites) applied per step, the frame split, CosRng`.

### Task 5: The draw core (uniforms, queueing, camera, stage, slow draw)

**Files:**
- Create: `rs/duel-look/src/draw/{mod,frame,queue,camera,stage,slow}.rs`, `rs/duel-tools/src/draw.rs`, `rs/duel-tools/tests/draw.rs`
- Modify: `rs/duel-tools/src/main.rs` (the `draw` verb); `rs/duel-sim/src/debug.rs`. Task 5 ports the scene commands its scenes need:
  2500-2503, 2513, 2394-2397, 84000 / 84001 / 84004 / 84005, `ensure-battle` / `place` / `force-form` (now `unported!`, `debug.rs:21-29`).

**Interfaces:**
- Produces:
  - `FrameOut { fu: [f32; 160], p: [f32; 30], dq: Vec<[f32; 32]>, fxa, fxb, ui, ft, hb, hk: Vec<f32> }`, preallocated and cleared each
    frame: the arrays `r_frame` gets;
  - `duel_look::draw_frame(scene: &mut Scene, m: &mut Match, rdt: f32, out: &mut FrameOut)` in DRAW-SCENE's order:
    - the camera;
    - the stage;
    - the fighters (Task 7);
    - the hazards (Task 6);
    - `cine::cine_draw(m)` unless turbo;
    - the cinematic looks (Task 8), stamps and FX (Task 6), the canvas words (Task 8);
    - then `fill-frame-uniforms`, `select-lights` and RENDER-FRAME's `p`.

    `m` is `&mut` only for `cine_draw`; everything else reads;
  - camera.lisp's look half (VIEW-STEP's look side, M1_NOTES §2). `view_behind` comes from a `Settings` struct with Lisp's defaults, by
    SET-CAM-BEHIND's rule `(and (or cam-behind one-hand) (vs-cpu-p) t)` (M2_NOTES §12);
  - SLOW-DRAW (`main.lisp:91-115`): the drawn transforms between the step's snapshot and now, put back after;
  - `duel-tools draw --check $ORACLE/draw/<scene>.bin [--arrays fu,p,dq] [--mask LANES]`. It replays the scene's commands with the key's
    inputs and dt = `raw_dt(frame_n)`, compares the keyed frames, and prints `draw OK <scene> <frames>` or the first mismatch, plus the
    allocations per frame. `--mask` exists only for the lanes a later task fills: `fu` 70..135 (the point lights, from `vfx.lisp`), and
    `dq` records whose mesh is a crack / chip or Ichigo's look meshes. Task 6 removes every use of it.
- Consumes: Tasks 2-4, Task 1's quiet and slowmo scenes.

- [ ] **Step 1:** Write the failing tests in `rs/duel-tools/tests/draw.rs`:
  - `quiet_core_matches` (`fu` / `p` and the stage's `dq` on the quiet scenes, with the fighters' and the later tasks' lanes masked);
  - `slowmo_frames_match` (Review Focus 2: the camera and `fu` through 2513 and the hitstop window).
- [ ] **Step 2:** Run `cargo test -p duel-tools --test draw`. Expected: FAIL.
- [ ] **Step 3:** Port in MANIFEST order: render.lisp's queueing, uniforms and lights; camera.lisp; the stage draw (`stage.lisp`, its
  cracks left for Task 6); SLOW-SNAPSHOT's use and SLOW-DRAW.
- [ ] **Step 4:** Run the tests. Expected: PASS, 0 allocations per frame after the first.
- [ ] **Step 5:** Commit `Bevy port M3a: the draw core (fu / p / the stage on N quiet frames, the slow draw)`.

### Task 6: FX (feedback, fx shapes, VFX, the stage's cracks, the hazards' looks, point lights)

**Files:**
- Create: `rs/duel-look/src/fx/{mod,shapes,vfx,stamps,ember,feedback,crack,hazard,ken,ichigo}.rs`
- Modify: `rs/duel-look/src/scene.rs` (Emit / Fx / Cue / shake), `rs/duel-tools/tests/draw.rs`

**Interfaces:**
- Consumes: Task 4's events and sink, `CosRng`, Task 5's `FrameOut` and `draw_frame` slots.
- Produces:
  - `fx::Pool` inside `Scene`, with the Lisp pool's fixed capacity;
  - `fx::draw(..., out: &mut FrameOut)` writing `fxa`, `fxb`, `ft`, the point lights, and the crack / chip / hazard / Ichigo look `dq` records;
  - `Scene.sounds: Vec<SoundReq>`: the sound requests feedback makes, collected. M3a's loop clears them; M3b plays them.

- [ ] **Step 1:** Write the failing tests:
  - `quiet_fx_matches`: the quiet and slowmo scenes with no mask, all of `fu` / `p` / `dq` / `fxa` / `fxb` / `ft`;
  - `cosrng_draw_order`: `CosRng::state()` after each keyed frame equals the key's `rng_state`.
- [ ] **Step 2:** Run them. Expected: FAIL.
- [ ] **Step 3:** Port, in this order:
  - `engine/lisp/fx.lisp`, `fx-shapes.lisp`;
  - `duel/lisp/feedback.lisp`, `vfx.lisp`, `vfx-stamps.lisp`, `vfx-ember.lisp`;
  - the stage's cracks and chips (`stage.lisp:221-294`);
  - `hazard-draw` (the Getsuga waves, the clones);
  - the kits' VFX and look meshes in ken-look / ichigo-look.

  Remove every `--mask` from the tests.
- [ ] **Step 4:** Run `cargo test -p duel-tools --test draw`. Expected: Tasks 5 and 6 PASS with no mask, 0 allocations a frame.
- [ ] **Step 5:** Commit `Bevy port M3a: FX (fxa / fxb / ft, point lights, cracks, hazards equal to the key)`.

### Task 7: The fighters (draw.lisp, the kits' draw and pose hooks, every form)

**Files:**
- Create: `rs/duel-look/src/draw/{fighter,ken,ichigo}.rs`
- Modify: `rs/duel-look/src/draw/mod.rs`, `rs/duel-tools/tests/draw.rs`, `rs/duel-sim/src/debug.rs` (2505, 2508 if not ported)

**Interfaces:**
- Consumes: Tasks 2-6.
- Produces: `draw::fighter::draw_fighter(scene, m, e, rdt, out)` (DRAW-FIGHTER). It covers the kit `:pose` / `:draw` hooks, the two-handed grip
  (GRIP-STEP), the beat pose, the lift, the mirror P2's rim and tint, and Kenpachi's Bankai cinematic body (`:kenpachi`). The rim and tint
  come from `Match.mirror_rim` and tables.json `mirror_tint` (M1_NOTES §10), never from hand constants. A Hisagi / Yamamoto fighter
  gives `look_unported`.

- [ ] **Step 1:** Write the failing tests:
  - `forms_draw_matches`: the forms scenes, all arrays but `ui` / `hb` / `hk`. This is the draw-level FK M0_NOTES §6 asked for: the hooks,
    the grip, the beat, the lift;
  - `quiet_full_matches`: the quiet scenes with the fighters;
  - `portrait_scene_matches`: the 2501 portrait scene (Review Focus 4).
- [ ] **Step 2:** Run them. Expected: FAIL.
- [ ] **Step 3:** Port `draw.lisp`, then ken-look.lisp's and ichigo-look.lisp's draw and `:pose` hooks.
- [ ] **Step 4:** Run `cargo test -p duel-tools --test draw`. Expected: Tasks 5-7 PASS, 0 allocations a frame.
- [ ] **Step 5:** Commit `Bevy port M3a: the fighters (every Kenpachi / Ichigo form drawn equal to the key)`.

### Task 8: The cinematics' looks, the canvas words, the full battles

**Files:**
- Create: `rs/duel-look/src/cine.rs` (+ `cine/ken.rs`, `cine/ichigo.rs` if it grows), `rs/duel-look/src/canvas.rs`
- Modify:
  - `rs/duel-look/src/scene.rs`;
  - `rs/duel-tools/tests/draw.rs`;
  - `rs/duel-sim/src/debug.rs`: CINE-AT and `force-cine`, 35000+, 75300+, 84006-84008, 84094 / 84095, the Ichigo cinematic commands
    of 74000-75599, and 2000-2099 with the seed draw (2005 / 2006).

**Interfaces:**
- Consumes:
  - `duel_sim::cine` (the sim half: the DURING forms that move actors, already ported);
  - Task 4's cine events;
  - Tasks 5-7.
- Produces:
  - the cinematic camera, the actors' clips and scale (CINE-SCALE), the slow (CINE-SLOW), and the cinematics' FX and ink, all drawn into
    `FrameOut`. KEN-BANKAI-CINE's looks are included (M1_NOTES §10);
  - `canvas::draw` into `ui`: the canvas part of `hud-draw` (`hud-screens.lisp:27-42`). That is the flash, the focus lines, the
    cinematic letterbox and brush caption, the world overlays and the big words. The `lhud-*` HUD (`hb` / `hk`) and the pause grade in
    `p[8]` (`lhud-fx.lisp:22-29`) are M3b.

- [ ] **Step 1:** Write the failing tests:
  - `cines_match`: every cinematic scene, all arrays but `hb` / `hk`;
  - `cine_portrait_matches` (Review Focus 4);
  - `battles_match`: 2005 / 2006, all arrays but `hb` / `hk` (the intro, the mid-match cinematics, every look at once);
  - cine-test.lisp's 7 deferred checks (43, 44 DURING, 47 the actor hook, 50 the shot's eye, 56 / 59 / 76 the debug hold), with a
    PORTED.md row.
- [ ] **Step 2:** Run them. Expected: FAIL.
- [ ] **Step 3:** Port `engine/lisp/cine.lisp`'s looks, `duel/lisp/cinema.lisp`, and the kits' cinematic looks: Kenpachi's Nozarashi /
  Bankai / KR / ZH / Z2, Ichigo's awakening and his Kikon per pointer, the soul break, the intro and the K.O. Then the canvas words.
- [ ] **Step 4:** Run `cargo test -p duel-tools --test draw`. Expected: PASS for Tasks 5-8.
- [ ] **Step 5:** Commit `Bevy port M3a: the cinematics' looks and the canvas words (N cinematic and battle frames equal to the key)`.

### Task 9: The Bevy renderer

**Files:**
- Create:
  - `rs/duel-app/src/render/{mod,meshes,toon,lit,fx,ui,sky,post,camera}.rs`;
  - `rs/duel-app/assets/shaders/*.wgsl`, ported from `engine/shaders/`. The `ui.*` pair draws the canvas stream; the `hud.*` pair is M3b;
  - `tools/port/stills.py`.
- Modify: `rs/duel-app/Cargo.toml` (features), `rs/duel-app/src/main.rs`, `tools/port/build-web.sh`, `tools/port/page-smoke.sh`

**Interfaces:**
- Consumes: `FrameOut`, `Meshes`, M0a's toon `Material` (`rs/spikes/m0a/src/toon.rs`).
- Produces:
  - `duel_app::render::RenderPlugin`. It reads a `FrameOut` resource each frame and draws it in render.c's pass order: the lit / toon /
    ink-hull pipes and the transparent ones, the fx alpha / add / toon batches, the ui canvas, sky, bloom bright → blur → composite, the
    flame layer and the split grade cut;
  - `duel_app::camera_bundle()`;
  - `SceneInputs` from the real surface: the viewport and the MSAA sample count Bevy uses;
  - the page's frame-done counter (`Module._frames_done()`), so `run.mjs` stills settle deterministically (M0_NOTES §6);
  - `tools/port/stills.py SCENE...`: renders a scene from the frozen dist and from the Rust dist under `run.mjs --fixed-dt 16.666667`, and
    writes a Lisp | Rust | diff sheet with the SSIM per still into `build/port/stills/`.

- [ ] **Step 1:** Port the shaders and the passes. Meshes upload once from `Meshes` during the `:load` steps, split over frames. Draw records map
  onto a pool of entities reused every frame (0 allocations).
- [ ] **Step 2:** Run `tools/port/page-smoke.sh` on the web-dev build with the 2005 scene. Expected: no JS / WebGPU error, frames presented
  ≥ 900 (the M0 device-loss check).
- [ ] **Step 3:** Run `python3 tools/port/stills.py` over the looks gate's 2005 / 2006 / cine-ken / cine-ichigo / cine-ko stills. Expected:
  sheets written and the SSIM per still reported. The Rust side has no `lhud` HUD, so SSIM drops where the HUD draws. Report per
  still in M3A_NOTES; the judgment is the lead's and the user's.
- [ ] **Step 4:** Commit `Bevy port M3a: the Bevy renderer (FrameOut through materials and render-graph passes; stills sheets)`.

### Task 10: The game loop, the keyboard, the page

**Files:**
- Create: `rs/duel-app/src/game.rs`, `rs/duel-app/src/input.rs`, `tools/port/page-log-check.sh`
- Modify: `rs/duel-app/src/page.rs`, `rs/duel-sim/src/cpu/fq.rs` (the leaked `&'static` tables become an arena owned by `Search`)

**Interfaces:**
- Consumes: Tasks 4-9, `PilotInput`, `debug::debug_command`, `debug::vs_start`.
- Produces:
  - `duel_app::input::Keyboard: PilotInput`, with `read` and `rollout_read` (held keys written again inside a rollout: DIVERGENCES §1).
    The bindings are the Lisp's defaults (`control.lisp` / `engine/lisp/input.lisp`);
  - the page: `Module._debug_cmd(n)` reaches `debug_command`, and the console prints the same lines (the combat log `[tick] P1 …`, the hash
    lines, `=== …`);
  - the start: `?p1=ken&p2=ichigo&cpu=normal` (defaults: human Kenpachi vs NORMAL Ichigo, cinematics on). It calls what the menu's VS CPU
    confirm calls in Lisp; find it from `lhud-menu-select.lisp` and name it in M3A_NOTES;
  - the dev line (`// dev: M3b replaces`): the gauges, Esc toggles "PAUSED" (the sim's pause, as the pause menu sets it), and after a K.O.
    "K.O. — Enter to rematch" restarts the same match where Lisp would go to RESULTS.

- [ ] **Step 1:** Write the failing tests:
  - `fq_arena_no_leak`: 100 learned matches in a row; the arena's size stays constant after the first;
  - `cine_draw_per_rendered_frame`: during a played Kikon at dt 1/120, `cine_draw` runs once per rendered frame and the actors match a
    hand run of the same calls (Review Focus 3);
  - `page-log-check.sh`: the frozen page and the Rust page under `run.mjs --fixed-dt 16.666667` with debug 2005 for 60 s print the same
    combat-log and hash lines;
  - `unported_surfaces_on_page` (Review Focus 5).
- [ ] **Step 2:** Run them. Expected: FAIL.
- [ ] **Step 3:** Write the loop: one `Update` system runs the keyboard read, `flow::frame(.., scene, dt)`, `draw_frame`, then `frame_end`.
  When `frame` returns false or a `look_unported` is set, the fight stops and the page draws the reason as text, logged once. Then the
  dev line and the fq arena.
- [ ] **Step 4:** Run the tests, the sim gates and the page smoke. Expected: all PASS; 22 / 20 / 88 OK; logs equal.
- [ ] **Step 5:** Commit `Bevy port M3a: the game loop, the keyboard, the page (logs equal to the frozen page; fq arena)`.

### Task 11: Close M3a

**Files:**
- Modify:
  - `docs/bevy/M3A_NOTES.md`: the numbers, the site table's final state, the carries to M3b;
  - `docs/bevy/BEVY_PORT.md`: the M3 row, "M3a done";
  - `docs/bevy/DIVERGENCES.md`: anything new;
  - `rs/Cargo.toml`: the opt-level decision;
  - `docs/README.md`: the notes row;
  - `AGENTS.md`: the docs map's bevy list.

- [ ] **Step 1:** Measure against the frozen build (BEVY_PORT §6.4), and put the table in M3A_NOTES:
  - native sim steps/s with the CPUs on (still ≥ 3×);
  - the headless frame time on 2005 (SwiftShader, before/after only);
  - startup to the first fight frame;
  - peak heap, counting the ICCs' 2.06 MB (M2_NOTES §12);
  - `index.wasm` and its gzip size;
  - the allocations per frame.
- [ ] **Step 2:** Decide R9 with the real page. Build release at opt-level `"z"` and at `3`, and record the size, the gzip size, the sim steps/s
  and the frame time. Keep the smaller one, unless 3 fits the Artifact's 15 MB limit gzipped and is more than 1.5× faster on the sim.
  Write the decision and the numbers in M3A_NOTES.
- [ ] **Step 3:** Run every gate once more:
  - the sim gates;
  - `cargo test --workspace`;
  - `duel-tools draw --check` on every scene;
  - the page smoke and the log check.

  Build the release dist (`tools/port/build-web.sh --release`) and list its sha256 per file for the lead's Artifact publish. The
  Artifact's text says there is no HUD and no sound yet (M3b).
- [ ] **Step 4:** Write M3A_NOTES' carries to M3b:
  - the HUD streams `hb` / `hk` are keyed but not drawn, and the pause grade `p[8]` too;
  - `Scene.sounds` is collected but not played;
  - the touch deck and its sim branches (M1_NOTES §10's `// port: touch stub`), input-test's 7 device checks, touch-test.lisp's 95;
  - the HUD's host tests (hud-engine-test 74, paint-shapes-test 9, lhud-geom 58, lhud-menu 51, lhud-charset 5);
  - the phone values (coarse, one-hand, scene scale, auto render scale) as live inputs;
  - saving and the `soulduel.*` protocol;
  - the debug commands the looks gate's other scenes need;
  - remove the dev line;
  - the whole looks gate's stills sheet.
- [ ] **Step 5:** Commit `Bevy port M3a: close (numbers, opt-level decision, carries to M3b)`.

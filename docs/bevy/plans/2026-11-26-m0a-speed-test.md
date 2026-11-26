# M0a Speed Test Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Measure whether Bevy's own renderer is fast enough before any real port work. Two real frames of the frozen game, drawn through
Bevy's toon `Material`, are compared with the frozen Lisp build on four measures: startup, wasm size, frame time, and the user's Android +
Chrome phone.

**Architecture:**
- Capture: a capture variant of the host-native sim image (`tools/simgate`) records what the frozen game sends to `r_frame` for a run of
  frames: meshes, frame uniforms and the draw queue.
- Spike: a throwaway Bevy 0.20.1 wasm page replays those frames, drawing the toon draws (characters + stage) through a Bevy `Material`
  with the ported toon shader, under a Bevy `Camera3d`, plus one line of Bevy text. It prints the same console lines as the frozen build.
- Measurement: the existing G3 harness pattern measures both builds.

**Tech Stack:**
- host ECL 24.5.10 (32-bit, gcc -m32);
- Rust 1.99 / Cargo, Bevy 0.20.1 (webgpu), `wasm-bindgen-cli` (the version matching the `wasm-bindgen` crate Bevy pulls in), `binaryen`
  `wasm-opt`;
- `tools/run.mjs` (headless Chrome), Python 3.

**Spec:** `docs/bevy/BEVY_PORT.md` (§1 the user's answers, §6.4 performance, §7 M0a).

## Global Constraints

- The Lisp build is frozen. Tag `lisp-freeze` = 395fd0b6 (v492). Never edit `duel/`, `engine/` or `tests/`.
- Bevy is pinned to `=0.20.1` for the whole port.
- The picture goes through Bevy's own rendering: `Material` / render graph, `Camera3d` (the user: 「全部用 Bevy 繪圖」). No raw wgpu pass of
  our own.
- The phone that judges is Android + Chrome (the user).
- The spike is throwaway. It lives under `rs/spikes/m0a/` and its code is not reused by M0 and later. What carries forward is the numbers,
  the capture format, and the wasm build script's flags.
- The page output is `index.html` + `index.js` + `index.wasm`, so the Artifact publish flow and its sha256 check work as they do today.
- No per-frame heap allocation in the replay loop: preallocate entities and materials, and update them in place.
- Bounded waits only. Never use `pkill -f` / `pgrep -f`. Subagents never push or deploy.
- Run `git checkout -- vendor` after any `./build.sh`.

## Review Focus

1. **WebGPU missing or refused on the phone**: the page shows a readable error line, not a blank or black canvas. The Task 4 smoke checks the
   error path with `--use-webgpu-adapter=none`, or with WebGPU disabled.
2. **Resolution unfairness**: Bevy renders at full device pixels while the Lisp build auto-scales (`render-scale` in its `perf:` line). The spike
   renders at the same pixel count as the Lisp run measured beside it. Task 4 logs both sizes and Task 5 checks they match.
3. **First-use pipeline compile hitch**: Bevy compiles a material's pipeline the first time it draws, which can freeze a frame. Warm up during
   load, and report the max frame time and the frame-time median separately. Task 5 asserts that both are reported.
4. **Background tab / focus loss**: the replay must not spin or pile up frames while hidden. After a focus loss the next perf window must not
   carry the hidden time; Task 4 checks this with `--secs` and a forced blur via `Emulation.setFocusEmulationEnabled`.
5. **Capture drift**: the captured draw list must be the real frame, not a partial one, for example a frame where the HUD or the cinematic
   path wasn't run in the headless image. Task 2 checks that draw counts match the frozen browser build's `perf:` `draws` count for the same
   scene within ±5 %.

---

## File structure

```
tools/simgate/build.lisp            modify: stubs path from env SG_STUBS (default tools/simgate/stubs.c)
tools/port/capture/stubs-capture.c  create: stubs.c + r_mesh_new keeps vertex data + r_frame records frames [F0, F0+N)
tools/port/capture/capture.lisp     create: runner: build/port/capture.fas, a scene's debug commands, N frames -> frames.bin
tools/port/capture/check.py         create: reads frames.bin, prints counts, asserts the format
tools/port/m0a-perf.py              create: A/B real-time runs (G3 pattern), sizes, the table
rs/Cargo.toml                       create: workspace (members = ["spikes/m0a"]), bevy = "=0.20.1"
rs/spikes/m0a/Cargo.toml            create
rs/spikes/m0a/src/main.rs           create: app, capture decode, replay system, perf lines
rs/spikes/m0a/src/capture.rs        create: frames.bin decoder (no Bevy types)
rs/spikes/m0a/src/toon.rs           create: ToonMaterial (AsBindGroup) + Frame-lanes uniform
rs/spikes/m0a/assets/shaders/toon.wgsl  create: toon.vert/frag ported to Bevy's material bindings (embedded with embedded_asset!)
rs/spikes/m0a/web/index.html        create: loads index.js, init('index.wasm'), window.Module shim, error overlay
rs/spikes/m0a/build-web.sh          create: release wasm -> wasm-bindgen --target web -> wasm-opt -Oz -> dist/bevy-m0a/
docs/bevy/M0A_SPEED.md              create: the numbers and the verdict question for the user
```

---

### Task 1: Freeze tag and the frozen build's numbers

**Files:**
- Create: `docs/bevy/M0A_SPEED.md` (the "Frozen build" table only)

**Interfaces:**
- Produces:
  - tag `lisp-freeze`;
  - `dist/duel` built at the tag (the A side for Task 5);
  - the scene's debug commands, `4003` (seeded CvC Ichigo vs Kenpachi, the G3 scene) then `2106` (the perf log), which Task 2 captures and
    Task 5 measures.

- [ ] **Step 1: Tag the freeze**

Run: `git tag lisp-freeze 395fd0b6 && git push origin lisp-freeze`
Expected: `git rev-parse lisp-freeze` prints `395fd0b6…`.

- [ ] **Step 2: Build the frozen dist**

Run: `git status --short duel engine tests | grep -v '^??'` (expected: empty), then `./build.sh duel; git checkout -- vendor`.
Expected: build exit 0; `ls -l dist/duel/index.wasm` about 11.9 MB.

- [ ] **Step 3: Measure the frozen build**

Run the G3 harness against itself: `python3 tests/style-gates.py perf dist/duel dist/duel duel`.
Record:
- frame ms median;
- startup heap;
- page-to-first-frame ms;
- the `perf:` line's `render-scale`, `draws` and `tris`, from a log in `build/style-tmp` (the path `tests/style-gates.py` uses as `TMP`).

Also record `index.wasm` raw and gzip size: `gzip -9c dist/duel/index.wasm | wc -c`.

- [ ] **Step 4: Write the table and commit**

```bash
git add docs/bevy/M0A_SPEED.md
git commit -m "Bevy port M0a: lisp-freeze tag and the frozen build's numbers (frame ms, startup, heap, wasm size)"
```

### Task 2: Capture real frames from the frozen game

**Files:**
- Modify: `tools/simgate/build.lisp`. The `ffi:clines` include of `tools/simgate/stubs.c` reads `(or (ext:getenv "SG_STUBS") "tools/simgate/stubs.c")`.
- Create: `tools/port/capture/stubs-capture.c`, `tools/port/capture/capture.lisp`, `tools/port/capture/check.py`

**Interfaces:**
- Consumes: Task 1's scene (`4003`, `2106`), the tag.
- Produces: `build/port/capture/frames.bin`, little-endian:
  - header `"SDCAP1\0\0"`, `u32 n_meshes`, `u32 n_frames`;
  - per mesh: `u32 id`, `u32 n_verts`, `n_verts*9 f32` (pos xyz, normal xyz, sRGB rgb: `+vertex-floats+`);
  - per frame: `u32 tick`, `160 f32` frame uniforms (`fu`, struct `Frame` in `engine/shaders/frame.wgsl`), `u32 n_draws`, then per draw
    `u32 mesh_id`, `u32 pipeline` and `32 f32` (struct `Draw`: model, tint, fx, rim, toon).

  Where the mesh id and the pipeline sit relative to the 32-float record is in `engine/c/render.c` `r_frame` and `R_DQ`: copy them as the C
  side reads them.

- [ ] **Step 1: Write `check.py` first**

It asserts:
- the magic;
- `n_frames == 240`;
- every draw's `mesh_id` in the mesh table;
- every frame has at least one toon character draw (`toon.x > 1.5`) and at least one stage toon draw (`0.5 < toon.x <= 1.5`).

It prints the per-frame draw count min / median / max and the vertex total.
Run: `python3 tools/port/capture/check.py build/port/capture/frames.bin`. Expected: FAIL (no file).

- [ ] **Step 2: Build the capture image**

- `stubs-capture.c` = `stubs.c`, with two changes:
  - `r_mesh_new` copies the vertices into a growable table;
  - `r_frame` appends the frame to an in-memory buffer when the tick is in `[F0, F0+240)`. `F0` comes from env `CAP_F0`, default 600, so
    both fighters are already moving.
- `capture.lisp`, after the prelude: `sg-init`, queue `4003` and `2106`, step frames until 240 are recorded, write the file, quit 0. It runs
  frames the way `tools/simgate/run.lisp` does.

Run: `SG_STUBS=tools/port/capture/stubs-capture.c $ECL_HOST --norc --load tools/simgate/build.lisp -- build/port/capture.fas`, then
`$ECL_HOST --norc --load tools/port/capture/capture.lisp -- build/port/capture.fas`.
Expected: exit 0, `frames.bin` written.

- [ ] **Step 3: Run `check.py`; compare with the browser**

Expected: PASS. The median draw count is within ±5 % of Task 1's `perf:` `draws` (Review Focus 5). If it is not, find which path the
headless image skipped and record it; don't paper over it.

- [ ] **Step 4: Check the simgate image is unchanged without the env**

Run: `python3 tests/style-gates.py cvc dist/duel`.
Expected: three PASS lines, identical to the reference (the default stubs path still builds the old image).

- [ ] **Step 5: Commit**

```bash
git add tools/simgate/build.lisp tools/port/capture/
git commit -m "Bevy port M0a: capture the frozen game's r_frame input (meshes, frame uniforms, draw queue) from the native image"
```

### Task 3: The Bevy replay page (native first)

**Files:**
- Create: `rs/Cargo.toml`, `rs/spikes/m0a/{Cargo.toml,src/main.rs,src/capture.rs,src/toon.rs,assets/shaders/toon.wgsl}`

**Interfaces:**
- Consumes: `frames.bin` (Task 2's format). It is embedded with `include_bytes!` from `build/port/capture/frames.bin`, so the page needs no
  fetch. This is a spike: an exception to "no asset files" that never reaches the port.
- Produces: a binary `m0a` that plays the 240 frames in a loop at 60 Hz. The wasm build is Task 4.
  - `capture::Capture::parse(&[u8]) -> Result<Capture, String>`, with `meshes: Vec<CapMesh { id: u32, verts: Vec<[f32; 9]> }>` and
    `frames: Vec<CapFrame { tick: u32, fu: [f32; 160], draws: Vec<CapDraw { mesh: u32, pipe: u32, rec: [f32; 32] }> }>`;
  - `toon::ToonMaterial { lanes: ToonLanes }`, where `ToonLanes` is a `ShaderType` holding `tint`, `fx`, `toon` (per draw) and the `Frame` lanes
    the toon shader reads (`key`, `toon`, `shd`, `rim`, `amb_sky`, `amb_ground`, `fog`, `fogh`, `cam`).

- [ ] **Step 1: Write the decoder tests**

In `capture.rs`:
- `parses_header_and_counts`: a hand-built two-mesh, one-frame buffer → `meshes.len() == 2`, `frames[0].draws.len()` as built;
- `rejects_bad_magic` → `Err`;
- `rejects_truncated` → `Err`.

Run: `cargo test -p m0a` in `rs/`. Expected: FAIL to compile.

- [ ] **Step 2: Implement `Capture::parse`; the tests pass**

Use `u32::from_le_bytes` / `f32::from_le_bytes` slices, with a bounds check on every read.

- [ ] **Step 3: The app**

- Entities: one per (frame-max) draw slot, spawned once with that slot's mesh handle. The meshes have `POSITION`, `NORMAL` and
  `COLOR` (sRGB → linear in the shader, as the original does `pow(c, 2.2)`). Unused slots are hidden.
- Each `FixedUpdate` tick at 60 Hz advances the frame index. The replay system then:
  - writes every draw's `Transform` from its `model` matrix (`Mat4` → `Transform::from_matrix`; flag a non-affine matrix);
  - writes its material's per-draw lanes in place (`Assets<ToonMaterial>::get_mut`, one material per slot, preallocated);
  - sets the `Camera3d` from the frame's `cam.xyz` (eye) and the view direction from `inv_vp`;
  - sets `PerspectiveProjection.fov = 2·atan(1/scr.z)` (`scr.z` = proj[1][1]) and `near = 0.1`, `far = 400` (render.lisp's camera).
- Only toon draws are drawn: `toon.x > 0.5`, per `toon.vert.wgsl`. Other pipelines are skipped and counted in a log line.
- One `Text` line ("YAMAMOTO 山本 284") stands in for the HUD.

- [ ] **Step 4: The shader**

Port `toon.vert.wgsl` / `toon.frag.wgsl` (with `frame.wgsl`, `toon-io.wgsl`, `lit-io.wgsl` as needed) into one Bevy material shader:
- Bevy's `mesh_functions` give the world position and normal, Bevy's view gives the clip position;
- `shade_of`, the key-light band and the rim follow the original;
- the point lights are left out (log it);
- keep the original's comments on what each lane does.

- [ ] **Step 5: Look at it**

Run `cargo run -p m0a --release`. Take one screenshot (Bevy's `Screenshot`) at frame 120. Put it side by side with the frozen build's still at
the same tick (`tools/run.mjs dist/duel --fixed-dt 16.666667 --script` with `4003` and a `--shot` at that tick) in `build/port/m0a-sheet.png`.
Expected: same fighters, places and poses, roughly the same banding. It is a speed test, not parity: note the differences, don't fix them.

- [ ] **Step 6: Commit**

```bash
git add rs/Cargo.toml rs/Cargo.lock rs/spikes/m0a
git commit -m "Bevy port M0a: Bevy 0.20.1 replay of captured frames through a toon Material (spike)"
```

### Task 4: The wasm page and its console contract

**Files:**
- Create: `rs/spikes/m0a/web/index.html`, `rs/spikes/m0a/build-web.sh`
- Modify: `rs/spikes/m0a/src/main.rs` (perf lines, resolution, warm-up, focus)

**Interfaces:**
- Consumes: Task 3's app.
- Produces: `dist/bevy-m0a/{index.html,index.js,index.wasm}` and these console lines, the same text the frozen build prints, so
  `tools/run.mjs` and Task 5 parse both:
  - once, after the first rendered frame: `startup: heap X MB, wasm memory Y MB` (X = Y = the wasm memory size);
  - every 2 s: `perf: startup S ms | frame F ms avg (P fps) max M | render-scale R pixel-lights 0 | draws D tris T`;
  - on failure: `engine fatal: <reason>`, also shown as a visible overlay.
- `window.Module = { _debug_cmd(n) {} }` exists, so scripts that call it don't throw.

- [ ] **Step 1: The build script**

`build-web.sh`:
- `cargo build -p m0a --release --target wasm32-unknown-unknown` (profile: `opt-level = "z"`, `lto = "fat"`, `codegen-units = 1`,
  `panic = "abort"`);
- `wasm-bindgen --target web --no-typescript --out-name index`;
- rename `index_bg.wasm` → `index.wasm`; `index.html` calls `init('index.wasm')`;
- `wasm-opt -Oz`.

Install `wasm-bindgen-cli` at the exact version in `rs/Cargo.lock`, and `binaryen`, if missing. Write the versions into `M0A_SPEED.md`.
Bevy features: `default-features = false` plus only what the spike needs (`bevy_render`, `bevy_core_pipeline`, `bevy_pbr`, `bevy_text`,
`default_font`, `bevy_winit`, `webgpu`, `bevy_window`, `multi_threaded` off on wasm). List them in `M0A_SPEED.md`.

- [ ] **Step 2: Resolution and warm-up**

- The window's physical size equals the Lisp run's scene pixel size, from Task 1's `render-scale` × canvas size (Review Focus 2). Log
  `m0a: render px WxH`.
- Before the first `startup:` line, draw one frame with every material slot visible off-screen, so the pipelines compile during load
  (Review Focus 3).

- [ ] **Step 3: Focus**

When the page is hidden, nothing is stepped or rendered (Bevy's `WinitSettings` / `UpdateMode::reactive_low_power` while unfocused). The perf
window resets on refocus (Review Focus 4).

- [ ] **Step 4: Smokes**

Run each check with `python3 -m http.server`-free `tools/run.mjs`, which serves the directory:

| Command | Expected |
|---|---|
| `node tools/run.mjs dist/bevy-m0a --secs 12` | exit 0; a `startup: heap` line; at least 3 `perf:` lines |
| `node tools/run.mjs dist/bevy-m0a --secs 8 --use-webgpu-adapter=none` (or the equivalent run.mjs flag that disables WebGPU) | an `engine fatal:` line, a non-blank shot (Review Focus 1) |
| `node tools/run.mjs dist/bevy-m0a --secs 8 --mobile --size 390x844 --shot build/port/m0a-phone.png` | exit 0; the fighters visible in the shot |

- [ ] **Step 5: Commit**

```bash
git add rs/spikes/m0a
git commit -m "Bevy port M0a: wasm page (index.js/index.wasm), the frozen build's perf/startup console lines, warm-up, matched resolution"
```

### Task 5: Measure, publish, ask

**Files:**
- Create: `tools/port/m0a-perf.py`
- Modify: `docs/bevy/M0A_SPEED.md`, `docs/DEVLOG.zh-TW.md` (a new § = the file's max + 1)

**Interfaces:**
- Consumes: A = `dist/duel` (Task 1), with script `4003`, `2106`; B = `dist/bevy-m0a` (Task 4).

- [ ] **Step 1: `m0a-perf.py`**

It follows `tests/style-gates.py perf`: six real-time runs, A B A B A B, 45 s each.
- It parses the `perf:` frame ms (skipping the first two windows), the max ms, `startup: heap` and `[run] startup done`.
- It also adds the raw and gzip wasm size of each side.
- It prints one table and asserts that every cell was found (no NaN). That covers Review Focus 3's "both reported".

- [ ] **Step 2: Run it**

Run: `python3 tools/port/m0a-perf.py dist/duel dist/bevy-m0a`.
Expected: a full table. Copy it into `M0A_SPEED.md` with:
- what B draws and A does not: B draws only the toon draws of captured frames, with no sim, AI, FX, sky, post or HUD paint stream, so its
  frame time is the floor of the Bevy renderer;
- the render pixel sizes (Review Focus 2);
- the max-frame (hitch) figures.

- [ ] **Step 3: Publish the page for the phone**

Publish `dist/bevy-m0a` as a **new** Artifact (`index.html`, files `index.js`, `index.wasm`; icon `chart`). The Lisp playtest page
(https://claude.ai/artifact/JFuuxi3T1FQf6mA2n58YcV, v492) is the A side on the phone. Verify the sha256 of each file by reading them back
from the published Artifact (`Artifact` action read with `paths`).

- [ ] **Step 4: Docs and commit**

- The DEVLOG § (zh-TW): the user's 「先測速再繼續」, the table, and the open question.
- `M0A_SPEED.md`: the question for the user. Asked in zh-TW: on Android + Chrome, is the Bevy page smooth, and does it start fast enough, to
  go on with Bevy's own rendering?

```bash
git add tools/port/m0a-perf.py docs/bevy/M0A_SPEED.md docs/DEVLOG.zh-TW.md
git commit -m "Bevy port M0a: speed test numbers (frozen build vs Bevy replay), page for the user's Android check"
git push origin main
```

- [ ] **Step 5: Stop**

Report to the user (zh-TW): the table, the two links, and the question. **The port does not continue until the user answers** (spec §7 M0a).

---

## After M0a (outline; each gets its own plan once the user says go)

| Milestone | Plan to write | First tasks |
|---|---|---|
| M0 | `docs/bevy/plans/<date>-m0-extractor-oracle.md` | The extractor (registries → `rs/duel-data/src/gen`), reproducible at the tag; the oracle generator (input traces, per-tick hashes, combat logs, FK tables, cvc at the tag: the checked-in `tests/style-cvc-ref.txt` is stale, spec §7); the workspace's real crates (`duel-sim`, `duel-data`, `duel-look`, `duel-app`, `duel-tools`); the wasm pipeline from M0a's script |
| M1 | `…-m1-sim-core.md` | The CL-semantics module (`round`, `truncate`, contagion), the three RNG streams, math / hitvol / vpad, then the MANIFEST order through `combat`, `round`, `core-sim`, `hazards`, Kenpachi, Ichigo; the trace-replay harness |
| M2 | `…-m2-cpu.md` | `cpu-perceive`, `core-ai`, `mcts-lite`, `cpu-mcts`, strategies, the fq tables (data), `fq-online`; cvc II / IK / KK |
| M3 | `…-m3-presentation.md` | Rig / FK and clips (FK tables), bodies → meshes (the capture as a check), the renderer passes, FX, camera, stage, cinematics, the HUD paint stream and atlas, audio, the touch deck; the first Rust playtest Artifact |
| M4 | `…-m4-hisagi-yamamoto.md` | Each fighter: sim → CPU → looks → cinematics |
| M5 | `…-m5-parity.md` | Every gate of spec §6, practice, debug commands, manual, performance, the phone |
| M6 | none until the user says so | Switch-over |

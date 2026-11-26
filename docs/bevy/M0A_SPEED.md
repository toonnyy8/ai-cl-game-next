# M0a speed test: the numbers

The Bevy port's go / no-go measurement (docs/bevy/BEVY_PORT.md §7 M0a; plan docs/bevy/plans/2026-11-26-m0a-speed-test.md).
Headless Chrome (SwiftShader WebGPU, `tools/run.mjs`, real time, 1280x720) on the lead's machine: only before / after comparisons
mean anything; the feel is judged on the user's Android + Chrome phone.

## Frozen build (A): `lisp-freeze` = 395fd0b6, v492 (2026-11-26)

Scene: debug 4003 (seeded CvC Ichigo vs Kenpachi, the G3 scene) + 2106 (the perf log); six 45 s runs
(`python3 tests/style-gates.py perf dist/duel dist/duel duel`).

| Measure | Value |
|---|---|
| Frame ms (mean per run, first two windows skipped) | 38.3 41.6 41.6 39.6 39.9 38.2, median **39.8** |
| Worst perf window's max frame (A's windows are 5 s) | 140.9 ms |
| Startup (page to first frame) | **3220 ms** (median) |
| Startup heap | 76.0 MB |
| Render | render-scale 1.00 (1280x720 scene px), pixel-lights 8, draws 121-145, tris about 18k |
| `index.wasm` | 11,899,490 B raw, 3,761,561 B gzip -9 |

## Bevy replay (B) against the frozen build (A), 2026-11-26

`python3 tools/port/m0a-perf.py ../ai-cl-game-next/dist/duel dist/bevy-m0a`: turns A B B' x3, 45 s real time each, 1280x720 (both render
1280x720 px: A's render-scale 1.00, B's `render px 1280x720`).

| Side | frame ms (3 runs) | median | worst window max | startup ms | heap MB | wasm raw / gzip |
|---|---|---|---|---|---|---|
| A frozen | 40.4 38.8 41.2 | **40.4** | 156.6 | 3390 | 76.0 | 11,899,490 / 3,749,665 |
| B Bevy, MSAA 4x (Bevy's default; A uses 4x too) | 119.4 121.1 121.0 | **121.0** | 147.7 | 3430 | 71.4 | 24,349,094 / 6,136,618 |
| B' Bevy, MSAA off (`?msaa=off`) | 28.0 29.3 29.3 | **29.3** | 93.4 | 2570 | 71.4 | same |

**What B draws and A does not.** B replays the 240 captured frames' mesh draws only (all of them: toon 81 slots, ink hull 72;
the capture held no lit / transparent draw) under a Bevy `Camera3d`, with one Bevy `Text` line. It runs no sim, CPU, FX (the
ink / flame batches), sky, bloom / composite, HUD paint stream or audio, and its toon shader has no point lights. So B's frame
time is the **floor** of Bevy's renderer for this scene; A's 40.4 ms carries the whole game.

**Breakdown (one 14 s run each, SwiftShader):**

| B variant | frame ms |
|---|---|
| default (MSAA 4x) | 123 |
| `?msaa=off` | 29 |
| `?empty` (no mesh visible), MSAA 4x | 94 |
| `?empty&msaa=off` | 16.7 (the 60 Hz cap) |
| `?static` (no per-frame updates) | 120 |

- Bevy's MSAA path costs about 94 ms a frame on SwiftShader with nothing drawn, while A's own 4x MSAA fits in 40 ms with
  everything. SwiftShader rasterises on the CPU, so this says little about a phone's GPU, where MSAA is usually cheap. The
  phone check therefore covers both B and B'.
- Without MSAA, the 145 draws cost about 12 ms over the empty page, and the per-frame updates (transforms, materials,
  camera) cost almost nothing (`?static` 120 vs 123).
- Size: B embeds the 6.9 MB capture (682 KB gzip), so Bevy's code is about 17.4 MB raw / 5.45 MB gzip against A's 11.9 / 3.75:
  about 1.45x gzip **before any game code** (A's figure holds the whole game and the ECL runtime, so this is a floor that will grow), with this feature set (`default_app`, `bevy_winit`, `default_font`, `common_api`,
  `bevy_render`, `bevy_core_pipeline`, `bevy_pbr`, `bevy_light`, `ui_api`, `ui_bevy_render`, `webgpu`; no audio yet).
- Startup is a floor as well: A's 3.39 s includes generating every mesh, glyph and sound; B only parses an embedded blob. B's
  figure includes its 12 warm-up frames (about 1.4 s at 121 ms a frame), which explains most of the gap between B and B'. These
  first runs loaded `index.wasm`, not the gzip copy the published page loads (re-measured below).
- Found on the way:
  - Some of the frozen game's model matrices carry shear (TRS error up to 0.69). Bevy's `Transform` cannot hold them, so B writes
    `GlobalTransform` directly; the port's draw path must do the same.
  - Bevy's default font has no CJK glyphs; the port draws the HUD with its own SDF atlas anyway.
  - `run.mjs --fixed-dt` waits for `Module.preinitializedWebGPUDevice`, so the Bevy page's deterministic stills need that hook in M0.

Tools: wasm-bindgen-cli 0.2.130 (`cargo install --locked`), wasm-opt from emsdk (`/media/8tsp/projects/emsdk/upstream/bin`),
Rust 1.99, Bevy =0.20.1.

## Corrections after the final review (2026-11-26)

The whole-branch review (a fresh Fable reviewer) found two faults in what the user had been shown; both are true.

1. **Pixels on the phone.** The first published page forced Bevy's scale factor to 1, so on a DPR-3 phone the headless run drew
   390x844 px (0.33 MP), while the frozen build caps its scene at about 1.6 MP on phones (`*scene-scale-cap*`, onehand.lisp). The
   user's 「可以接受」 was given on a page that drew about a fifth of A's pixels. The page now drops the override and shows its
   real canvas size on screen. Headless Chrome's DPR emulation still reports the CSS size to winit (390x844 again), so the real
   phone's figure can only be read off the phone: Chrome on Android reports `devicePixelContentBox`, which winit uses, so the
   canvas should get the device's full pixels (about 3 MP at DPR 3: more than A, so the comparison now leans against B).
2. **Device loss.** B' lost its GPU device in 2 of 3 first runs (`Caught DeviceLost error: Unknown A valid external Instance
   reference no longer exists`, then Bevy quits); `m0a-perf.py` did not notice. It now fails a run on `DeviceLost`, a page
   exception, a nonzero run.mjs exit or too few perf windows. Re-runs: B' lost the device in 3 of 3 runs; B (MSAA 4x) after about
   106 s in a 200 s run; `?static&msaa=off` after about 20 s; `?empty&msaa=off` (nothing drawn, 60 fps) never in 70 s. The loss
   comes after about 700-900 frames that draw the meshes, whatever the per-frame updates. Keeping the page's probe adapter alive
   did not help, and Bevy keeps its wgpu `Instance` (`RenderInstance`). The frozen build never shows it in the same headless
   Chrome (G2 cvc runs 60 s, about 1500 frames). Cause unknown: suspected the wgpu web backend's JS objects and garbage
   collection, possibly headless / SwiftShader only. **Open item for M0** (before any playable Rust page): reproduce on a real
   GPU, try a newer wgpu / Bevy patch, or report upstream. The page now shows such an error on screen instead of freezing.

Re-measured with the gzip load (index.gzip.wasm) and the new failure checks:

| Side | frame ms (3 runs) | median | worst window max | startup ms | heap MB | runs failed |
|---|---|---|---|---|---|---|
| A frozen | 38.4 41.6 39.7 | 39.7 | 140.5 | 3330 | 76.0 | 0 |
| B Bevy MSAA 4x | 120.5 119.2 120.7 | 120.5 | 133.5 | 3520 | 70.0 | 0 (45 s runs; lost at about 106 s in a 200 s run) |
| B' Bevy MSAA off | 29.4 29.5 29.2 | 29.4 | 86.5 | 2810 | 73.6 | 3 of 3 (DeviceLost) |

## Size limit and rebuild times (found in M0a)

- The Artifact serves binary files up to 15 MB and no `.gz`; the release `index.wasm` is 24.3 MB (code 14.4 MB, data 9.7 MB of
  which 6.9 MB is the capture). The page loads `index.gzip.wasm` (gzip bytes, 6.1 MB, under a served name) and unzips it with
  `DecompressionStream`, falling back to the bytes as they came when the server already decoded them. The port's page needs the
  same (or a wasm under 15 MB) from M3 on.
- Rebuild times (rs/, wasm32): release (`opt-level z`, fat LTO, wasm-opt) about 2 min 51 s a build; `--profile web-dev`
  (opt-level 1, no LTO, incremental) 95 s the first time, then about 1 s after touching a source or the shader, plus 3 s of
  wasm-bindgen (its wasm is 119 MB: local runs only).

## The user's phone check (Android + Chrome)

Pages: A = the Lisp playtest page (https://claude.ai/artifact/JFuuxi3T1FQf6mA2n58YcV, v492); B = the Bevy replay page
(https://claude.ai/artifact/93Vi4g42Ge1SGWyj99VfV1, links at the top right switch MSAA 4x / off: B'). The question: is B (and B')
smooth and quick enough to start, compared with A, to go on with Bevy's own rendering?

**The user's answer (2026-11-26, after trying both pages on the phone): 「可以接受」**, given on the first page (0.33 MP on a
DPR-3 phone, see the corrections above): asked again on the corrected page. MSAA stays the original's 4x unless the user asks otherwise; B' showed it can be dropped if a phone
needs it.

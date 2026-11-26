# M0 notes

Findings of the Bevy port's M0 (plan docs/bevy/plans/2026-11-26-m0-extractor-oracle.md). Headless runs: `tools/run.mjs`,
headless Chrome 158 with SwiftShader WebGPU (run.mjs's default flags), 1280x720, real time, on the lead's machine.

## 1. Headless device loss (Task 1, 2026-11-26)

**Symptom (M0a).** The m0a replay page lost its WebGPU device after 20-110 s of drawing meshes:
`Caught DeviceLost error: Unknown A valid external Instance reference no longer exists`, then Bevy quits.

**Cause.**
- Chrome's log (`CHROME_LOG=1`) shows the GPU process dying at the same moment: `GPU process exited unexpectedly:
  exit_code=133` (SIGTRAP, Chrome's crash on a failed check). When the GPU process dies, the page's Dawn wire instance is
  torn down. Its pending device-lost callback then fires with "A valid external Instance reference no longer exists". The same
  message appears at once when the GPU process cannot start (a hardware flag set below).
- The GPU process's RSS grows by about 22 MB/s from the first frame, while the scene stays static: 550 MB at 4 s, 1.1 GB at
  31 s, then the crash at about 39 s (`?static&msaa=off`).
- Counting `GPUDevice.createBuffer` calls (`?gpucount`) shows about 5 new buffers a frame, about 21 MB/s: 4 unlabelled
  buffers plus "clustering Z slicing metadata buffer". With one mesh drawn (a temporary `n=1` switch, since removed) the rate is the same.
- Bevy 0.20.1's GPU light clustering (`bevy_pbr::cluster::gpu::prepare_clusters_for_gpu_clustering`) builds a new
  `ViewClusterBindings` and a new `ViewGpuClusteringBuffers` for every view on every frame. That is 2 + 2 unlabelled buffers
  plus the metadata `StorageBuffer`, even with no lights in the scene.
- wgpu 30.0.2's web backend has a no-op `Drop` for `WebBuffer` (`src/backend/webgpu.rs`: `// no-op`). A dropped buffer is
  never `destroy()`ed, so its GPU memory waits for V8 to collect the JS `GPUBuffer`. The page's JS heap stays at about
  12 MB, so a full GC is rare, and the GPU process grows to about 1.1 GB. The JS heap (`mem:` lines) shows no leak: 125 MB
  during load, then 11-13 MB.
- `?empty` (nothing drawn, 60 fps) allocates even more (about 30 MB/s). Its GPU RSS also climbed to 1.08 GB in 24 s, then
  hovered at 1.08-1.2 GB to 90 s without a crash (GC is reclaiming there). `?static` crashed during its first plateau, at
  1.1 GB.
- So the crash is not a plain out-of-memory. Suspect (a) below kept the GPU RSS at 0.7-0.76 GB with a forced GC, and the GPU
  process still died at about 2550 frames.
- Nor is it the number of buffers. A died after about 12.7k buffers (5 a frame x 2549 frames); the fixed page D made about
  17.9k (2 a frame x 8946 frames) and never lost the device.
- What separates the runs is the bytes churned (about 1.3 GB before A died, under 1 MB in D) or the GPU clustering passes
  themselves. The fix removes both, so the runs prove that GPU clustering being on is the cause, not which part of it. The
  exact Dawn / SwiftShader check is unknown: Chrome is stripped and the GPU process logs nothing before it dies.

**Not headless-only.** Bevy turns GPU clustering off only for `target_os = "android"` and the iOS simulator. A wasm build's
`target_os` is `unknown`, so Chrome on an Android phone runs GPU clustering and makes the same buffers. Whether a phone's GPU
process dies of it is unproven: the user's phone session was short and saw no error. The fix is a code change either way.

**Fix (kept by the port): no light clustering.** On the main world, set `GlobalClusterSettings::gpu_clustering = None`, and
put `ClusterConfig::None` on every camera. Both are needed:
- `ClusterConfig::None` alone, with GPU clustering on, makes an empty "clustering dummy texture" (`width:0, height:0`). The
  app then quits on a validation error.
- `gpu_clustering = None` alone (CPU clustering) still makes 2 buffers a frame of about 58 KB each.

Both together leave 2 buffers of 18 B a frame on the static page, and about 25 KB/s on the animated page (Bevy's other
per-frame buffers). The port draws no Bevy lights (the toon shader takes its own lanes), so it loses nothing.
`duel-app` applies this in its camera setup. Tasks 3 and 9 need no run.mjs flag. The m0a spike now does it by default;
`?gpuclust` brings back the old behaviour.

**Suspects of the plan (Step 2).**
- (a) GC. A forced `gc()` every 5 s (`?forcegc`, with Chrome's `--js-flags=--expose-gc`) on the unfixed page
  (`?static&msaa=off&gpuclust`, release build, 300 s).
  - Result: the forced GCs bounded the GPU RSS: 0.66-0.71 GB from 11 s to 43 s, then a slow creep to 0.76 GB. The device was
    still lost at about 73 s (2549 frames, about 14 forced GCs in, not at the first), with the GPU process exiting 133.
  - So the loss is not a JS reference dropped at a GC. A GC flag frees memory but does not stop the crash, so it is no fix
    for headless runs either.
- (b) Backend. A hardware adapter could not be reached headless on this machine (RTX 4090, NVIDIA 595.99, Vulkan 1.4; X on
  :0). Flag sets tried, each with and without `DISPLAY=:0`:
  - `--use-angle=vulkan --enable-features=Vulkan` (± `--disable-vulkan-surface`, `--use-vulkan=native`,
    `--disable-gpu-sandbox`, `--ozone-platform=x11`, `SkiaGraphite`, `--disable-vulkan-fallback-to-gl-for-testing`): no adapter.
    The log shows "Failed to initialize vulkan surface" and "Failed to send GpuControl.CreateCommandBuffer", and once the same
    "A valid external Instance reference no longer exists".
  - `--use-angle=gl` / `--use-gl=egl`: EGL cannot open the display, or the GPU process exits (exit 139).
  - plain `--enable-unsafe-webgpu --ignore-gpu-blocklist`: SwiftShader again (`isFallbackAdapter`).

  Ruled out as impossible here; not needed, because the cause is found above.
- (c) Versions. wgpu 30.0.2 and Bevy 0.20.1 are the newest patches on crates.io (2026-11-26), so there is nothing to update.

**Exit criterion: 300 s headless runs of the fixed page (release build), drawing every mesh (131 meshes, 141 draws of
frame 0; the plan's "145" is the frozen build's draw count).**

| Run (release build, `rs/spikes/m0a/build-web.sh`) | perf windows | frames | mean frame | GPU RSS over the run | DeviceLost |
|---|---|---|---|---|---|
| A: unfixed + forced GC, `?static&msaa=off&gpuclust&forcegc` | 35 | 2549 | 28.0 ms | 0.66 to 0.76 GB, then crash (exit 133) | **lost at 73 s** |
| B: fixed, the default page (animated, MSAA 4x) | 143 | 2600 | 115.7 ms | 477 MB at 34 s, 527 at 130 s, 554 at 299 s | none |
| C: fixed, B' (`?msaa=off`, animated) | 147 | 8911 | 33.8 ms | 473 MB at 34 s, 491 at 131 s, 505 at 300 s | none |
| D: fixed, `?static&msaa=off` (the page that failed fastest) | 147 | 8946 | 33.6 ms | 438 MB at 34 s, 464 at 131 s, 459 at 299 s | none |

- A and B ran at the same time, as did C and D (two SwiftShader pages share the CPU, so the frame times are slower than
  M0a's single runs).
- Unfixed runs before the fix, one page each: lost at about 78 s (release), 44 s, 15 s and 39 s (web-dev); all exited
  run.mjs with 0.
- C and D drew 3.5 times the frames at which A died, and their GPU RSS is flat. The fixed pages still create Bevy's other
  per-frame buffers: 2 of 18 B a frame on the static page, about 150 small ones a second (about 25 KB/s) on the animated
  one. B's 0.08 GB rise over 265 s is that, and it flattens. That churn is a count of small buffers, about 7-25 MB over
  300 s, two orders of magnitude under A's 1.3 GB: low risk, to be checked again once duel-app draws a real match.

**Upstream (not filed; for the record).**
- wgpu: the web backend's `Drop for WebBuffer` (and `WebTexture` / `WebQuerySet`) never calls `destroy()`.
- Bevy: `prepare_clusters_for_gpu_clustering` allocates its buffers again every frame instead of reusing them.
- Bevy: `ClusterConfig::None` with GPU clustering on creates a zero-size texture.

**Smoke tools.** run.mjs exits 0 on a `DeviceLost` and on Bevy's `Caught rendering error`. The page-smoke of Task 3 must fail
on `DeviceLost`, `Caught rendering error` and the page's `engine fatal:` line.

Diagnostics left in the spike:
- `?gpucount` (WebGPU objects and buffer bytes created per 2 s);
- `?forcegc`;
- a `mem:` line before each `perf:` line (wasm memory, JS heap, frames);
- `?gpuclust`.

Ruling: the device loss is Bevy 0.20.1's per-frame GPU-clustering buffers that wgpu's web backend never destroys. The port
keeps Bevy at =0.20.1 and turns light clustering off: `gpu_clustering = None` plus `ClusterConfig::None` on every camera.

## 2. The blank page and its contract (Task 3, 2026-11-26)

`rs/duel-app` (`src/page.rs`: `DebugQueue`, `debug_cmd`, `say`, the `startup:` / `perf:` lines, `camera_bundle` with the §1 fix),
its shell `rs/duel-app/web/index.html`, `tools/port/build-web.sh <crate> <out_dir> [release|web-dev]`, and the smoke
`tools/port/page-smoke.sh [DIST]` (default `dist/rs-blank`).

- **Stills.** Two `--fixed-dt 16.666667` runs to virtual 10 s give byte-identical PNGs. The page draws only its clear colour, so
  this proves the harness path (the virtual clock starts, frames present, `__settle` returns), not determinism of drawn frames.
  The canvas does present: the centre pixel is the clear colour (20, 20, 26), one off the page background `#141419` (20, 20, 25);
  the row also requires a `startup:` line in both logs.
- **`Module.preinitializedWebGPUDevice`** is an idle device the page requests from its own adapter before `init`; Bevy / wgpu
  make their own. run.mjs's rAF tick (not only `__settle`) chains `onSubmittedWorkDone` on it, so neither waits for Bevy's GPU
  work. Harmless for a clear colour; once frames draw (Task 9), stills may need that wait on wgpu's device.
- **Frames before `startup:` vary run to run** under the virtual clock: `perf: startup 217 ms` in one run, `233 ms` in the
  next (13 vs 14 virtual frames before Bevy's 12th update), so Bevy's update count is not tied 1:1 to rAF ticks at startup.
  `FixedUpdate` reads Bevy's `Time` (performance.now, the virtual clock), so the sim steps by virtual time T should still match;
  Task 9's traces check that.
- **Wall speed.** The blank page runs 11.6 fps (86 ms frames) in headless SwiftShader at 1280x720, MSAA 4x; the M0a page with
  `?empty` measured the same that hour (11.4 fps), so it is the machine's SwiftShader, not the page.
- `Tonemapping::None` on the camera: the default TonyMcMapFace needs the `tonemapping_luts` feature and logs an error without it
  (the port grades in its own shaders, as M0a did).
- `web-dev` builds skip wasm-opt: 109 MB wasm, 15.4 MB gzip (over the Artifact's 15 MB binary limit; for local runs only).

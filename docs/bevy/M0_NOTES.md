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

## 3. Data files (Tasks 4-6)

`rs/duel-data/data/*.json` (7.96 MB with the two hud-font copies), extracted from the frozen native image
`build/simgate/duel.fas` (tag `lisp-freeze`). Loaded by `rs/duel-data` (typed structs, serde); `cargo run -p duel-tools --
check-data [dir]` loads them and prints the counts and the float checksum.

**Re-extract** (needs the musl libm, as the sim gate: weapon sections call sin / cos, rims call pow; the extractor exits 1 if
`muslm.so` is not mapped):

```sh
env LD_PRELOAD=$PWD/build/simgate/muslm.so $ECL --norc --load tools/port/extract/extract.lisp -- build/simgate/duel.fas all
env LD_PRELOAD=$PWD/build/simgate/muslm.so $ECL --norc --load tools/port/extract/extract.lisp -- build/simgate/duel.fas census
```

`all` (~25 s) writes the files (optional 3rd arg: another out dir; modes `moves` / `kits` write only that file). `census`
(~15 s) re-reads them and checks them against the image (counts, an independent symbol sweep that reaches the same 549 moves,
tuning key set = source names, no shape conflict, manifest checksum). Two `all` runs are byte-identical. `tools/port/extract/test-json.lisp`
tests the writer (`$ECL --norc --load ...`).

**Counts (`manifest.json`)**: bodies 11, clips 400, debug_ranges 90, glyphs 248, kits 12 (forms), moves 549, poses 443, rig 21
(joints), tables 25, tuning 1146, weapons 11; `skipped_tuning` 3; `float_checksum` `6640f0fd66ac0848`.

| File | Shape |
|---|---|
| `moves.json` | list of every MOVE object, one per line, id `<char>/<form>/<name>`; copies found only in a variable get `var/<variable>/<name>#<n>` (`var/ya-garb-copies/ya-e-n1c#0`). A move shared by inheritance is claimed by the form that defines it. `spec` slots are not written (no runtime reader) |
| `kits.json` | `{"kits":{char:{form:{...}}},"roster":[...],"retired":[...]}`; per form also `cls` (move id to na/ns/as/sa), `sp`, `moves` (sorted ids). Duplicate `commands` keys keep the first (GETF) |
| `clips.json` | `{name:{dur,loop,marks{},poses[[68]],snaps[n],times[n]}}`, `loop` true or null |
| `poses.json` | `{name:[68 f32]}` |
| `rig.json` | `{aliases,joints[{name,parent,offset,flex_sign,mirror}],key_ease,mirror_pairs}`; `offset` = `*RIG-OFF*` in engine coords |
| `bodies.json` | every BODY slot but name and mesh handles; spec / palette / girth / ink are positional arrays |
| `weapons.json` | `{name:{len,base,sections[{kind:"solid"\|"glow",...,verts}]}}`, verts in groups of 9 (position, normal, colour); ink hulls not written (the port runs `mb-hull`) |
| `glyphs.json` | `[[code,advance,[[x0,y0,...]...]]...]` |
| `debug_ranges.json` | `[[lo,hi,NAME\|null]...]`; 72 of 90 names are null (inline handlers) |
| `tables.json` | 25 named tables (stage, fz_*, strat_*, lhud_*, commands, vpad_actions); `*STRAT-*` tables are forced objects, repeated `:base` keys keep the first |
| `tuning.json` | `{SYMBOL-NAME: value}`, every `defparameter` of `duel/` and `engine/` (3 skipped as `{"kind":"skipped","why":"move"}`); `*PERFECT-HW*` is a hitwin object |
| `hud-font/` | byte copies of `duel/hud-font/` (atlas.r8, metrics.bin) |

Conventions: `T` is `true`, `NIL` is `null` or `[]` / `{}` by slot type, so booleans are true or null; integer values in float
fields stay integers (move.track, move.blend, params.chain, positional tuples); a double is `{"f64":"..."}`; a plist is an object
only where the extractor forces it or the shape guess finds distinct keyword keys and even length.

**Code fields** are written as symbol names (the port ports them by hand; the full per-field lists are in the task-4 / task-5
reports): kit `aura`, `cine`, `enter_hook`, `hooks.*` (armor, as-pick, cancel, clash, command, deck, dmg-mult, draw, hash, hit, hit-fx,
hud-tag, kikon-n, kikon-worth, link-move, link-ok, lv, min-reach, ok, parried, planted, pose, reset, soul-break-cine, sp-gain-mult,
step-dist, struck, threat, tick, unscaled, victim-look), `core.kikon-cines`, `meter.label`; move `cine`, `hits.seg`, `on_frame`,
`on_land`, `params.look`, `release`, `tick`; `tables.strat_*` `:fn` (the ten `*-STYLE` functions); `tuning`: `*CAI-STYLES*`,
`*CINE-NAMES*`, `*DEBUG-KNOBS*`, `*HS-HOOKS*` / `*HS-BK-HOOKS*` / `*HS-R-HOOKS*` / `*ICHIGO-HOOKS*` / `*KESSA-HOOKS*`,
`*HURT-CINES*`, `*YA-S5-CINES*`. Not swept by the census: closures and symbol plists.

**Float checksum** (`manifest.json`, recomputed by `rs/duel-data` `checksum.rs`): FNV-1a 64 (basis `0xcbf29ce484222325`, prime
`0x100000001b3`, per byte `h = (h ^ b) * prime`) over the data files sorted by name (bodies, clips, debug_ranges, glyphs, kits,
moves, poses, rig, tables, tuning, weapons; manifest and hud-font excluded), and within a file over the float tokens in document
order. A float is a number token containing `.`, `e` or `E` (parsed as f32) or the string of an `{"f64":...}` object (f64);
integer tokens are skipped. 13 bytes per float from CL `(integer-decode-float x)`: sign (1 byte: 0 for +, 1 for -), exponent
(i32 LE), mantissa (u64 LE). F32 zero is (0, 0); a denormal is normalised first (frac shifted until bit 23, exponent
-149 - k); f64 likewise (bit 52, -1074 - k). Test vectors: `1.0f0` is `00 e9 ff ff ff 00 00 80 00 00 00 00 00`; `-0.0f0` is
`01` then 12 zero bytes.

## 4. The answer key (Tasks 7-8)

Generated by `tools/port/oracle/gen.py` into `build/oracle/` (git-ignored, ~620 MB), from the frozen native image. Provenance
is in `INDEX.json` (the `lisp-freeze` commit and whether the sources equal it). Run `gen.py sim` (traces, ~9 min), `gen.py
replay [NAME...]` (verifies traces on the stock image with the brains detached, 63 in ~5 min), `gen.py look [--check]` (FK,
sounds, stills, ~8 min; `--check` only counts and sanity-checks).

| Path | Content |
|---|---|
| `build/oracle/*.trace`, `INDEX.json` | 63 per-tick traces (1.9 M steps): 48 seeded CvC (every ordered pairing of Y K I H, seeds 1-3), 3 cvc-tag (II / IK / KK seed 7), 12 trial files. INDEX has per trace name, kind, start, steps, sha1, nonperturbed, trials; `excluded` (Rukia's research trials) and `deferred` (`tests/scripts/*.json`, waits for M1) |
| `build/oracle/cvc-tag.txt` | the `--cvc` reference at `lisp-freeze`; equal to `tests/style-cvc-ref.txt` (M2's reference) |
| `build/oracle/fk/<clip>.json` | 400 files (107 MB): 21 joint world matrices per frame per rig (column-major), plus weapon tip / base per form |
| `build/oracle/sound/<key>.f32` | 51 sounds, 48 kHz mono f32 LE, rendered twice, identical; `INDEX.json` |
| `build/oracle/stills/` | 83 PNGs of the looks gate (frozen dist `e35032a7`), byte-identical across 3 renders |

**Trace grammar** (header of `tools/port/oracle/trace.lisp` is the spec):

```
S cmds <debug cmd> ...      CvC / gate start: sg-init, queue the commands, run frames
S trials <file>             trial start: sg-init + one frame; then E / F lines
E <action> <args>           an out-of-band action between frames (set, battle, form, place, vpad-clear, core-start, cmd, ...)
e [  tick] ...              combat log line that the E action printed (compared)
R [  tick] ...              line the trial runner printed between frames (never compared)
F                           run one frame (%frame, 1/60 s); its step records follow
[  tick] ...                sim combat log line (compared)      C [  tick] ...   CPU log line (not compared)
T tick vt1 downs1 sx1 sy1 vt2 downs2 sx2 sy2 rnd    inputs + sim RNG right after brain-system
H duel hash t=...           the hash line
```

`downs` is 3 hex digits, bit i = `*vpad-actions*`[i] (0 mod, 1 quick, 2 flash, 3 sig, 4 guard, 5 breaker, 6 kikon, 7 step, 8
awaken); sx / sy are shortest-round-trip f32; rnd is 8 hex digits. Records are keyed by order, not tick (`begin-battle` resets
the tick). CPU pilots keep `cam-relative` nil. The recorder runs on a second compiled image (the stock unit plus one hook after
`brain-system`, `build-rec.lisp`); non-perturbation is checked per trace. Replay uses the stock image and attaches no brains.

Look data: the FK is the engine's clip-level FK (`clip-sample!` then `pose-fk!`, `*key-ease*` = 1 as the game sets it). Clips owned
by a kit are sampled for that kit's forms (310); 62 unowned clips go to the forms of the prefix character (ya- ke- ic- hs-) and 26
`sh-` clips to every form; victim clips carry all 4 rigs (standard, Kenpachi's, Yamamoto's, skeleton). Cross-checked against the
host reach test: 12 of 12 Yamamoto tip reaches agree to 2 decimals.

## 5. Rulings (from the M0 ledger)

- **Device loss** (Task 1): Bevy 0.20.1 GPU clustering buffers that wgpu's web backend never destroys; the port sets
  `gpu_clustering = None` plus `ClusterConfig::None` on every camera. 131 meshes / 141-153 draws instead of the brief's 145 (the
  capture holds every mesh the frozen frames draw; 145 was the browser's draw count).
- `check-deps.sh` counts `cargo tree -e normal --prefix none | grep -c ^bevy` (the brief's `^.*bevy` matched the worktree path).
- **Float checksum order**: data files sorted by name, within a file JSON float tokens in document order (untagged f32, `f64`-tagged
  f64); keys are written sorted, so Rust walks `serde_json::Value` in the same order; a separate test checks typed fields equal
  those bits.
- **Var move ids**: moves found only in a variable are `var/<variable-lowercase-no-stars>/<name>#<index>`; `garb_copy_present` asserts
  at least three `ya-e-n1c` moves with capsule lengths 4.5, 5.4, 6.3 (the test compares against the game's f32 `4.5f32 * 1.4` =
  6.2999997, not the decimal 6.3).
- **kits.json** is `{"kits":{char:{form}},"roster","retired"}` so roster / retired cannot collide with a character name.
- Lisp `T` is JSON `true`; NIL is `false` / `null` per slot. Duplicate kit `commands` keys keep the first (GETF). Integers in float
  fields stay integers; the checksum counts float tokens only. 12 kits load (the survey said 11).
- A MOVE shared through inheritance is claimed by the form that defines it (kit-inherit parent first): 23 `kenpachi/bankai/*` ids
  became `kenpachi/base/*`. The extractor fails when one JSON path holds both object and array shapes. `*STRAT-*` plists are forced
  to objects, a repeated `:base` key keeps the first. `*PERFECT-HW*` is dumped as a hitwin in tuning.json.
- **`pi` is a long-float** in ECL (80-bit x87 natively, IEEE quad on wasm). 339 f64 values in hisagi-bankai's body spec and ~1821
  near-zero weapon vertex floats come from the native image and differ from the wasm game in the lowest bits. Accepted: presentation
  only, far inside the spec 6.2 look tolerance (1e-5); the sim never takes PI (native and wasm hashes always matched). M1 asserts that
  no sim field reads these values.
- A nullable field the extractor stops writing reads as None silently (accepted: files are generated once at the freeze; the census
  guards the writer).
- **Page-smoke** (Task 3): the deterministic-stills row proves the harness on a clear-colour page only (`preinitializedWebGPUDevice` is
  a separate idle device, so run.mjs settle does not wait on Bevy's GPU work); deterministic drawn stills are an M3 requirement.
  Smoke row 2 runs `--secs 10`, fixed-dt rows `--timeout 180`, and the stills row also requires `startup:` (SwiftShader runs 11.6 fps).
- **Recorder** (Task 7): a second compiled image with one hook after `brain-system` (a runtime wrapper cannot intercept the compiled
  direct call; `duel/` is untouched); proven non-perturbing on all 63 traces. The recorded T holds the vpads and sim RNG right after
  `brain-system`.
- **Trial traces are self-describing** (E / e / R / F lines): M1 needs no port of `trial-run`.
- `tests/style-cvc-ref.txt` is not stale: `cvc-tag.txt` generated at `lisp-freeze` equals it (BEVY_PORT 7 corrected).
- **FK key** is the engine's clip-level FK; draw-time looks (kit `:pose` hooks, two-hand grip, beats, lift, cinematic scale) are ported
  in M3 and checked there by draw lists / stills. Clips with no owning kit are assigned to forms by name prefix, victim clips sampled
  on all 4 rigs.
- **Split** (Task 9): a subagent wrote these notes; the controller writes the DEVLOG section, runs the gates, merges and pushes.

## 6. Open items for M1-M3

M1 (sim):
- Trial traces replay through their E lines; the grammar and the E-action list must be implemented, and `trial-run`'s between-frame
  `core-start!` calls come as `E core-start`.
- Sim code that branches on whether a brain is attached (Ichigo's parry and tsuki stance, Hisagi's `hs-tick-brain`, the round
  reset's brain clear) never fired in the 63 traces; decide how the Rust sim treats it.
- Typed knobs for `tuning.json` (the file repeats tables.json's ~460 KB); `adv_block` is int / "guard-break" / null (an enum); `f64`
  tag versus plain f32 in one positional slot (hisagi-bankai spec); `loop` true / null.
- `debug_ranges.json` has 72 of 90 names null (inline handlers): another map to the handlers is needed (read `debug.lisp`).
- PI-derived values (long-float) must never be read by the sim; add the assertion.
- Replay's rnd comparison checks injected against itself (not RNG verification); the recorder wraps a fixed trial action list (a new
  `trial-run` action would surface as a divergence); same-name moves with identical JSON could swap `#0` / `#1` (none today).
- Tool hygiene: `check-deps.sh` hides a failing `cargo tree`; page-smoke's tmp dir is hard-coded `/tmp/claude-1000`; 'Caught
  rendering error' is not in the page's on-screen regex; smoke row 1 has little headroom at 11.6 fps; the JSON reader maps
  unknown escapes to the letter; `provenance()` compares commits, not the working tree.

M3 (presentation):
- Deterministic drawn stills need a Bevy-side settle hook (the wgpu device or a frame-done signal).
- Every camera must go through `camera_bundle()` (the clustering fix); nothing enforces it yet.
- A draw-level FK key (hooks, grip, beats, lift, cinematic scale) on top of the clip-level FK.
- Victim clips on all rigs: `lk-players` gives kit-owned clips only that kit's rigs; confirm for clips also named by a victim.
- The sound and still outputs are not tied to the build hash in INDEX; `look_check` does not sanity-check FK content.

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

**Possibly not headless-only.** Bevy turns GPU clustering off only for `target_os = "android"` and the iOS simulator. A wasm build's
`target_os` is `unknown`, so Chrome on an Android phone runs GPU clustering and makes the same buffers. Whether a phone's GPU
process dies of it is unproven (so "not headless-only" is a suspicion, not a result): the user's phone session was short and saw no error. The fix is a code change either way.

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
- C and D drew 3.5 times the frames at which A died, and their GPU RSS is nearly flat (run B +0.08 GB over 265 s; run C 473 -> 505 MB). The fixed pages still create Bevy's other
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

Not extracted: the sim-side defconstants (engine/lisp/input.lisp `+no-press+`, two in rules.lisp, ten in mcts-lite.lisp, `+pi+` / `+two-pi+`); M1 ports them by hand.

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

**Code fields** (hooks, cinematics, tick / on-frame callbacks, style functions) are written as symbol names; every name, grouped by
field path, is in [M0_CODE_FIELDS.md](M0_CODE_FIELDS.md) (the port writes them by hand). Not swept by the census: closures and symbol plists.

**Float checksum** (`manifest.json`, recomputed by `rs/duel-data` `checksum.rs`): FNV-1a 64 (basis `0xcbf29ce484222325`, prime
`0x100000001b3`, per byte `h = (h ^ b) * prime`) over the data files sorted by name (bodies, clips, debug_ranges, glyphs, kits,
moves, poses, rig, tables, tuning, weapons; manifest and hud-font excluded), and within a file over the float tokens in document
order. A float is a number token containing `.`, `e` or `E` (parsed as f32) or the string of an `{"f64":...}` object (f64);
integer tokens are skipped. 13 bytes per float from CL `(integer-decode-float x)`: sign (1 byte: 0 for +, 1 for -), exponent
(i32 LE), mantissa (u64 LE). F32 zero is (0, 0); a denormal is normalised first (frac shifted until bit 23, exponent
-149 - k); f64 likewise (bit 52, -1074 - k). Test vectors: `1.0f0` is `00 e9 ff ff ff 00 00 80 00 00 00 00 00`; `-0.0f0` is
`01` then 12 zero bytes.

**Loader quirks** (`rs/duel-data`, Task 6; M1 types the rest): `Data` has `load(dir)`, `embedded()` (include_bytes!), `files()`,
`file(name)`, `counts()`; `FILES` is the checksum order. Typed with `deny_unknown_fields`: Move, HitWin (`vols: [f32; 6]`, MAKE-VOL's
layout), Kit, Kits, Meter, Clip (`loop` as `looping: bool`), Body, Weapon / Section (tagged by kind), Rig, RigJoint, Manifest.
`adv_block` is `Option<AdvBlock>` (`Frames(i32)` or `Key(GuardBreak)`). Left as `serde_json::Value` until M1: `Move.params`, `Kit.core`,
tables.json, tuning.json. `Datum` (Null, Bool, Int, F32, F64, Str, List) holds the positional lists (`Body.spec` and `ink`,
`Move.on_frame`, `Kit.blade`, `Kit.intro_weapon`; hisagi-bankai mixes f32 and `{"f64"}` in one slot). Number fields that hold some
integers (track, blend, duration, push_reach, stun_tolerance) are `f32`. Null-only fields are typed from the slot's meaning and
fail loudly if another kind appears (`chip: Option<f32>`, `open_s: Option<i32>`, `exit_hook` / `face` / `reset_form`:
`Option<String>`, `ink_color: Option<i64>`; `l_after_k` / `l_after_j`: `Option<String>`, though the Lisp slot may be T or a plist).
`deny_unknown_fields` catches an added key only; a nullable key the extractor stops writing reads as None. No serde_json features
beyond the default (preserve_order / float_roundtrip / arbitrary_precision would unify into the Bevy crates). The checksum is a scanner
over the raw text (strings skipped, `{"f64":"..."}` counted only when it is the sole key). `cargo test -p duel-data` runs 8 tests
(loads_every_file, embedded_equals_load, float_checksum_matches_manifest, serde_float_path_is_exact (floor 500000 f32 tokens, 526441
today), edge_floats, decode_matches_ecl, garb_copy_present, typed_vols_match_walk); mutation checks (a changed rig offset fails the
checksum; an unknown key fails the load) were run by hand.

## 4. The answer key (Tasks 7-8)

Generated by `tools/port/oracle/gen.py` into `build/oracle/` (git-ignored, ~5.4 GB since M1 Task 1's B line: the traces 5301 MB, were ~505 MB), from the frozen native image. Provenance
is in `INDEX.json` (the `lisp-freeze` commit and whether the sources equal it). Run `gen.py sim [NAME...]` (traces, ~9 min; with NAMEs only
those, recorded and replayed, no INDEX / cvc-tag written), `gen.py replay [NAME...]` (verifies traces on the stock image with the brains detached, 63 in ~5 min), `gen.py look [--check]` (FK,
sounds, stills, ~8 min; `--check` only counts and sanity-checks).

| Path | Content |
|---|---|
| `build/oracle/traces/*.trace`, `INDEX.json` | 63 per-tick traces (1.9 M steps, 5301 MB with the B line; the largest, trial-sp-kits-hisagi, 1040 MB): 48 seeded CvC (every ordered pairing of Y K I H, seeds 1-3), 3 cvc-tag (II / IK / KK seed 7), 12 trial files. INDEX has per trace name, kind, start, steps, sha1, nonperturbed, trials; `excluded` (Rukia's research trials) and `deferred` (`tests/scripts/*.json`, waits for M1) |
| `build/oracle/frozen-dist/` | a copy of the frozen browser build (`index.wasm` sha256 `e35032a7...`), the source of the stills; `gen.py look` prefers it over the main checkout's `dist/duel` and keeps the sha check |
| `build/oracle/cvc-tag.txt` | the `--cvc` reference at `lisp-freeze`; equal to `tests/style-cvc-ref.txt` (M2's reference) |
| `build/oracle/fk/<clip>.json` | 400 files (107 MB): 21 joint world matrices per frame per rig (column-major), plus weapon tip / base per form |
| `build/oracle/sound/<key>.f32` | 51 sounds, 48 kHz mono f32 LE, rendered twice, identical; `INDEX.json` |
| `build/oracle/stills/` | 83 PNGs of the looks gate (frozen dist `e35032a7`), byte-identical across 3 renders |

**Trace grammar** (the header of `tools/port/oracle/trace.lisp` is authoritative; if this copy differs, the header wins):

```
# ...                       comments ("# trial begin NAME" / "# trial end NAME | ..." are trial.lisp's own lines)
S cmds <debug cmd> ...      CvC / gate start: sg-init, queue the commands, run run.lisp's frames until the gate / match is over (no E / F lines)
S trials <file>             trial start: sg-init + one frame (no step), then E / F lines in order; <file> is reference only, a replay never reads it
E <action> <args>           an out-of-band action taken between frames: apply it now
e [  tick] ...              a combat log line that the E action printed (compared)
R [  tick] ...              a line the trial runner printed between frames outside any E action (never compared)
F                           run one frame (%frame, 1/60 s, not turbo); its step records follow
[  tick] ...                sim combat log line (compared)      C [  tick] ...   CPU log line from brain-system (never compared)
T tick vt1 downs1 sx1 sy1 vt2 downs2 sx2 sy2 rnd
H duel hash t=...           STATE-HASH-LINE at the step's end
B <field> ...               (M1 Task 1) the sim state's raw bits at the step's end, or "B =" (same text as the trace's last B line);
                            a step's record is its [ / C lines, T, H, B
# B fields: <name> ...      (line 2) the B fields' names in order
```

**B line** (M1 Task 1, widened in its fix round 1 by the lead's ruling: every slot; `tr-b-line` in trace.lisp; the replay compares it as a
string and names the first differing field). H is quantised (cm, 0.01 rad); B is bit-exact, on every step. Encoding (`tr-b-enc`, by
runtime type; a field never contains a space):

| Value | Field |
|---|---|
| single-float / double-float | IEEE bits, 8 / 16 upper-case hex digits (the width tells which; no double occurs today); NaN / infinity stops the recorder |
| integer | decimal |
| symbol | `prin1` in package DUEL: `:IDLE`, `T`, `NIL`, `KE-FOO` |
| string | `prin1`, spaces as `_` |
| MOVE / KIT | `#m:NAME` (the move's name; the side's kit disambiguates) / `#k:CHARACTER/FORM` |
| other struct | `#TYPE{a,b,...}`: its slots in order, each encoded the same way (HITWIN, Ichigo's ICC) |
| list / vector | `(a,b,...)` (a dotted tail `,.x`) / `[a,b,...]` (fighter `cd`, f32vecs) |
| function / hash table / other | `#FN` / `#HASH:<count>` / `#<TYPE>`; nesting deeper than 4 levels is `#...` |
| a kit component the fighter lacks | `:ABSENT` |

Fields, in order (430 names in the `# B fields:` header, line 2; Rust reads the order from there; slot lists are read at load from the
`defcomponent` forms, so they follow the source):
1. globals (29): `*timer*` `*hitstop*` `*slow-acc*`, the 24 `*slowmo*` floats (`*slowmo*[0]`...), `*flow*`, `cine-cf` (`-1` with no `*cine*`);
2. per side, `p1.` then `p2.` (187 each): `pos-x/y/z`, `yaw`, `motion-vel-x/y/z`, `motion-kb-x/y/z`, `motion-kb-left`, `motion-grounded`,
   then every slot in slot order of `fighter` (components.lisp), `gauges` (components.lisp), and the kit components `ics` (ichigo.lisp),
   `hss` (hisagi.lisp), `yss` (yama.lisp), named `fighter-<slot>` etc. (qualified: `fighter-stun` is a fixnum, `gauges-stun` a float);
3. `|`, then per live hazard in entity order (look-only `:FX` hazards included) every `hazard` slot (26) in slot order; `owner` as
   `:P1` / `:P2` (else the raw handle or `NIL`), `hw` as a `#HITWIN{...}` struct, `data` / `hook` by the table. A mismatch there is named
   `hz<n>.<field>`.

`tr-read` keeps only each B line's file position (`tr-b-at` reads it back when the step is checked): the B text outgrows the 32-bit
host's 1 GB heap. `gen.py replay` counts a run with no `replay OK` line as a failure (an ECL error drops into the debugger, which exits
0 at stdin's end). No trace has a `B =` line today: some field (`*timer*`, `cine-cf`, a countdown) moves every step.

T: on a sim frame (the vpad ticks advance) the values right after `brain-system` (what the brains wrote for `fighter-system`, and the sim
stream after their draws); on any other step (intro, cinematic, hitstop, slow-motion wait) the values at the step's end. `vtK` is side K's
vpad tick; `downsK` its nine buttons as 3 hex digits (bit i = `*vpad-actions*` element i: 0 :mod, 1 :quick, 2 :flash, 3 :sig, 4 :guard,
5 :breaker, 6 :kikon, 7 :step, 8 :awaken); `sxK` / `syK` the stick as single-floats printed shortest round-trip (`0.3`, `-1.0`, `-0.0`;
Rust's `f32::from_str` reads them back exactly); `rnd` = `(sim-rnd-state)` as 8 hex digits. A replay writes the downs with `vpad-set!`
in bit order after the step's `vpad-begin-step!`. Records are keyed by order, not tick (`begin-battle` resets `*match-tick*` after the
intro; a trial file's trials share one match). CPU pilots keep `cam-relative` nil.

E grammar (SIDE is 0 for P1, 1 for P2; values are Lisp-printed: integers, single-floats as in T, keywords `:NAME`, `T` / `NIL`):

| E line | Applies |
|---|---|
| `E set SIDE <accessor> <value>` | `(setf (<accessor> obj) value)`; obj is GAUGES for `gauges-*`, FIGHTER for `fighter-*`, HS (Hisagi's state, attached if missing) for `hss-*`. Emitted for each field that changed since the last E / F line. Fields (`*TR-SIDE-FIELDS*`): gauges-awakened gauges-konpaku gauges-sub gauges-sub-s gauges-drive gauges-awaken gauges-meter gauges-fs gauges-burst gauges-burn gauges-reishi fighter-xch fighter-xch-done fighter-hoho-lock fighter-ptr fighter-state fighter-guard-t hss-bound hss-bind-arm hss-unbind |
| `E set - <global> <value>` | a global (`*TR-GLOBALS*`): `*COMBAT-LOG*` `*SKIP-CINES*` `*TIMER*` by `symbol-value`; `SIM-RND-STATE` by `(setf (sim-rnd-state))` |
| `E battle <C1> <C2>` | `(ensure-battle C1 C2 :cpu t)`: a CPU vs CPU match of those characters (a new one, cinematics skipped, unless one is already in battle) |
| `E form SIDE <form>` | `(force-form e form)` |
| `E hisagi-reset SIDE` | `(hs-reset e)` |
| `E place <dist>` | `(place P1 P2 dist)`: DIST m apart on the x axis around the centre, facing, idle, no hazards |
| `E vpad-clear SIDE` | `(vpad-clear! his vpad)` |
| `E clear-hazards` | `(clear-hazards)` |
| `E skip-cine` | `(skip-cine)` (defined; no trace uses it) |
| `E burst-end SIDE` | `(burst-end! e)` |
| `E full-gauges SIDE <meter>` | `(full-gauges! e meter)` |
| `E cmd <n>` | `(debug-command n)` (the Yamamoto trials' `:p1-cmd`) |
| `E core-start SIDE <move>` | `(core-start! e move)`, move = the key of his kit's `kit-moves` table (`:p2-start`) |

The recorder hook is `*oracle-brain-hook*`, a `defvar` plus `(when *oracle-brain-hook* (funcall *oracle-brain-hook*))` right after
`(brain-system)` in `sim-systems` of the scratch unit `build/oracle/rec/duel.fas` (`build-rec.lisp`, ~3 min; gen.py rebuilds it only
when the stock unit or build-rec.lisp is newer). Its unit differs from the stock one by those two forms only; the hook is ignored inside
rollouts (`*in-rollout*`). `post-draw` counts sim frames whose state at the step's end differs from the hook's (0 in all 63 traces:
`sim-rnd01` appears only in CPU code). `tr-log-equal` allows a recorded move / step / dash line to end in the brain's " TRIAL" why,
which a brainless replay cannot print. A replay's rnd check compares injected against itself; it is not RNG verification. The event
layer covers what `trial-run` does today (`*rec-actions*` plus the fields above); a new trial key that mutates something outside them
shows up as a replay divergence. Exit codes: record exits 2 on a wrong image; run frames exit 3 / 4 as `run.lisp` does.

**INDEX.json schemas.** `build/oracle/INDEX.json`: provenance (`lisp-freeze` commit, whether the sources equal it, the commit of the
run), `traces` (per trace: name, kind, start, pair / seed or file, steps, last_tick, bytes, sha1, start_miss, post_draw, compared_lines,
nonperturbed, trials), `excluded` (Rukia's research trial files, retired) and `deferred` (`tests/scripts/*.json`). `fk/INDEX.json`: per
clip the frames, dur, loop, each rig's bodies and each form's [form, by, weapon]. `sound/INDEX.json`: per key the samples, loop, peak,
NaN / Inf zeroed count (0 for all), sha1.

**FK file** `build/oracle/fk/<clip>.json` (keys sorted, single-floats shortest round-trip):

```
{"clip", "dur", "loop" (true | null), "fps": 60, "frames": N+1, "t": [t_0..t_N], "key_ease": 1,
 "joint_names": [21 joints in *RIG* order: pelvis spine chest neck head shoulder-r upper-arm-r lower-arm-r hand-r weapon-r
                 shoulder-l upper-arm-l lower-arm-l hand-l weapon-l thigh-r shin-r foot-r thigh-l shin-l foot-l],
 "rigs": [{"bodies": [...], "scale", "hunch" (rad), "props": 64 f32 (MAKE-RIG-PROPORTIONS) | null,
           "joints": per frame 336 f32 = 21 x 16; joint j's world matrix at [16j, 16j+16), column-major
                     (p -> m[0..2]*x + m[4..6]*y + m[8..10]*z + m[12..14])}],
 "forms": [{"form": "character/form", "body", "rig": index into rigs, "by": "kit" | "prefix" | "shared",
            "weapon", "weapon_len", "weapon_base", "tip": per frame [x,y,z], "base": per frame [x,y,z]}]}
```

Frames: t_i = i / 60 (single-float), i = 0..N, N = floor(dur * 60 + 0.001); a loop clip at t = dur wraps to its start, a one-shot clamps.
Rigs are deduplicated by (scale, hunch, props); the live bodies form 4: standard (hisagi, hisagi-bankai, ichigo, ichigo-kessa), Kenpachi's
(kenpachi, kenpachi-nomi, kenpachi-oni: scale 1.07 + props), Yamamoto's (yamamoto, yamamoto-bare, yamamoto-tybw: 0.95, hunch 0.244,
props), skeleton (hunch 0.349). The pose is sampled at the origin, yaw 0 (facing -Z); tip / base are `weapon-r` applied to
(0, 0, -weapon-len) / (0, 0, -weapon-base). `by`: "kit" = a form whose `kit-clips` name the clip (310 clips), "prefix" = the clip no
kit names (62), given to every form of the character named by the prefix, "shared" = the 26 `sh-` clips for every form (kenpachi
bankai / bankai-2 drop the 7 shared clips their body replaces); 2 clips (sk-crawl, sk-grab) have no form. Clips attributed by prefix or
shared carry the joints of all 4 rigs (victim clips play on the opponent's body).

**Sound file** `build/oracle/sound/<key>.f32`: raw little-endian f32, 48 kHz mono, rendered in a fresh process right after the image
loads (no `sg-init`; `au_rng` starts at 0x9E3779B9) in `*au-defs*` order: funcall, `au-sanitize!`, `au-finish!` unless looping,
`au-normalize!` to its peak. A render after `sg-init` is identical (the `:load` steps draw nothing from `au_rng`).

Look data: the FK is the engine's clip-level FK (`clip-sample!` then `pose-fk!`, `*key-ease*` = 1 as the game sets it). Clips owned
by a kit are sampled for that kit's forms (310); 62 unowned clips go to the forms of the prefix character (ya- ke- ic- hs-) and 26
`sh-` clips to every form; victim clips carry all 4 rigs (standard, Kenpachi's, Yamamoto's, skeleton). Cross-checked against the
host reach test: 12 of 12 Yamamoto tip reaches agree to 2 decimals.

**Committed pins** (build/ is git-ignored): `docs/bevy/oracle-index.json` (per trace name, kind, steps, last tick, sha1, plus the sound and FK
index summaries with sha1s; regenerate it from `build/oracle/INDEX.json` after `gen.py`) and `docs/bevy/cvc-tag.txt` (the `--cvc`
reference at `lisp-freeze`).

**What H proves and does not.** The per-tick `H` is `state-hash-line` (duel/lisp/gate.lisp), a QUANTISED state line: positions rounded
to cm, yaw to 0.01 rad, gauges rounded, a hazard count only; velocities, timers and hazard state are absent. A Rust float bug under
0.5 cm passes H at the tick it happens and only shows when it grows into a visible difference. So H is a coarse sync check, not a
bit-exact proof; M1 needs a finer line (§6).

## 5. Rulings (from the M0 ledger)

- **Device loss** (Task 1): Bevy 0.20.1 GPU clustering buffers that wgpu's web backend never destroys; the port sets
  `gpu_clustering = None` plus `ClusterConfig::None` on every camera. 131 meshes / 141-153 draws instead of the planned 145 (the
  capture holds every mesh the frozen frames draw; 145 was the browser's draw count).
- `check-deps.sh` counts `cargo tree -e normal --prefix none | grep -c ^bevy` (an earlier `^.*bevy` pattern matched the worktree path).
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
- Bit-level oracle line: record.lisp (the recorder image, no duel/ edit) should also emit a per-step line of raw float bits (pos, vel,
  yaw, gauges, fighter timers, hazards) so M1's replay compares exact state, not only the quantised H (§4).
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
- Tool hygiene: page-smoke's tmp dir is hard-coded `/tmp/claude-1000`; 'Caught
  rendering error' is not in the page's on-screen regex; smoke row 1 has little headroom at 11.6 fps; the JSON reader maps
  unknown escapes to the letter; `provenance()` compares commits, not the working tree.

M3 (presentation):
- Deterministic drawn stills need a Bevy-side settle hook (the wgpu device or a frame-done signal).
- Every camera must go through `camera_bundle()` (the clustering fix); nothing enforces it yet.
- A draw-level FK key (hooks, grip, beats, lift, cinematic scale) on top of the clip-level FK.
- Victim clips on all rigs: `lk-players` gives kit-owned clips only that kit's rigs; confirm for clips also named by a victim.
- The sound and still outputs are not tied to the build hash in INDEX; `look_check` does not sanity-check FK content.

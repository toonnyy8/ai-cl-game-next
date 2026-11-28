# M3a notes: the fight's picture in the Rust port

The working notes of M3a (the plan: `docs/bevy/plans/2026-11-27-m3a-fight-picture.md`). Each task adds its section; M0's answer key is
in `M0_NOTES.md` §4, M1's and M2's notes in `M1_NOTES.md` and `M2_NOTES.md`.

## 1. The draw key (Task 1)

The answer key for the picture: what the frozen native image hands the C renderer, recorded at keyed frames of debug-command scenes.
Later tasks compare a pure-Rust `FrameOut` against it 1:1.

```sh
python3 tools/port/oracle/gen.py draw [NAME...]   # build the image if stale, run every scene twice, write the key, check it
python3 tools/port/oracle/gen.py draw --check     # only the check
```

### Files

| Path | What |
|---|---|
| `tools/port/oracle/stubs-draw.c` | the recorder: `tools/simgate/stubs.c` (included unchanged) plus `r_mesh_new` / `r_frame` recording, the viewport from the environment, the real HUD atlas. **Its header is the format** (authoritative) |
| `tools/port/oracle/draw.lisp` | drives one scene: `SG-INIT`, names the meshes, queues the commands, runs `ENGINE::%FRAME` (drawn, not turbo) until the recorder is done; its header lists its stdout lines |
| `tools/port/oracle/draw-scenes.json` | the scenes (commands, viewport, frames, named frame ranges), each command's meaning, the fixed inputs |
| `build/oracle/draw-img/duel.fas` | the image: `tools/simgate/build.lisp`'s unit with `SG_STUBS=tools/port/oracle/stubs-draw.c` |
| `build/oracle/draw/<scene>.bin` | the key, one file per scene |
| `build/oracle/draw/<scene>.log` | run 1's stdout: the game's log plus one `draw f` line per frame (`*tick*`, `*match-tick*`, `*flow*`, cinematic name / frame / held, `*hitstop*`, the slow-motion scale), the mesh names, the seeds, the fixed inputs |
| `build/oracle/draw/meshes.json` | mesh id -> what made it and its vertex count |
| `build/oracle/draw/INDEX.json` | per scene: commands, viewport, frame list, named ranges, `match_seed`, `rng_start`, sha1, size, meshes made / drawn; once: the fixed inputs (as written and as read from the image), every command's meaning, the image's and the stub's sha1, provenance (`lisp_freeze`, `sources_equal_tag`) |

### Format (summary; the `.c` header wins)

`"SDDRW1\0\0"`, `u32 width`, `u32 height`, `u32 n_meshes`, `u32 n_frames`; per mesh the keyed frames draw (id ascending): `u32 id`,
`u32 n_floats`, the f32s as `r_mesh_new` got them (9 per vertex); per keyed frame: `u32 frame` (r_frame calls since the process
started; startup makes none, so frame 0 is the first `%FRAME`), `u32 tick` (`ENGINE::*TICK*`), `u32 rng_state` (`rng_float`'s state as
`r_frame` is called), then `fu` (160), `p` (30), `dq` (n × 32), `fxa`, `fxb`, `ui`, `ft`, `hb`, `hk`, each `u32 n_floats` + f32s.
Little-endian. A dq record's mesh id is `(int) record[23]`. Strides: fxa / fxb / ft 9, ui 8, hb / hk 16.

### How the recorder differs from the stock stubs

- `r_mesh_new` keeps every mesh's floats; `r_frame` records the frames `DRAW_FRAMES` lists (`a`, `a-b`, `a-b/k`, comma separated) to a
  temp file, then writes `DRAW_OUT` (header, the drawn meshes, the frames) after the last one. `r_frame` returns `n`: it only feeds
  `*draw-count*`, the stats line and `r_timing`, which returns 0.
- `pf_width` / `pf_height` / `pf_density` come from `DRAW_W` / `DRAW_H` / `DRAW_DPR`.
- `lhud_font` serves the real atlas, so `hb` / `hk` are what the browser gets. **Deviation from the brief:** the brief says
  `#include "duel/hud-font/lhud-font.c"`. That file uses `#embed`, and the host gcc (13.3) lacks it. Building the ECL unit with clang
  instead would change the image's float code. So the stub pulls in the same two files (`atlas.r8`, `metrics.bin`) with the
  assembler's `.incbin`, and defines the same function. The paths are relative to the build's working directory, which is the repo root
  (gen.py's `cwd`). Proof that it works: `hb` is non-empty in every battle frame without a cinematic (the check).
- `pf_pump` is wrapped, not changed. Its first call prints `draw: rng at start 0x...`: the cosmetic RNG's state at the scene's start,
  after startup and before frame 0 draws. It is `0x9e3779b9` (the seed) in every scene: startup draws nothing from `rng_float`.
- The handshake: after the last keyed frame the recorder sets `DRAW_DONE=1` in the environment. `draw.lisp` reads it with
  `EXT:GETENV` after each frame, names the meshes made since, and exits 0. (Interpreted Lisp cannot `ffi:c-inline` a query.)
- `tick` is read in C through `ecl_symbol_value` of `ENGINE::*TICK*`.

gen.py runs each scene twice in fresh processes and requires the two `.bin` files byte-identical and the mesh names equal. A run must
also print the recorder's `draw: … N frames` line with N equal to the list's length (an ECL error drops into the debugger, which exits 0
at stdin's end; stdin is `/dev/null`).

### Fixed inputs (each one a `Scene` / `FrameOut` input)

| Input | Value in the key | Source |
|---|---|---|
| viewport | per scene: 640x360 (landscape scenes) or 390x844 (portrait), DPR 1 | `DRAW_W` / `DRAW_H` / `DRAW_DPR` |
| MSAA samples | 1, so `fu[157]` = 0.5 | the stub's `r_sample_count`, render.lisp FILL-FRAME-UNIFORMS |
| `*render-scale*` / `*pixel-lights*` | 1.0 / 8 | `r_timing` returns 0, so the auto scale never moves |
| `*coarse*` / `*one-hand*` / `*scene-scale-cap*` | NIL / NIL / 1.0 | `pf_page_get` 0: a desktop window with nothing saved |
| `*match-seed*` | per scene, INDEX `match_seed` | the command |
| dt | `raw_dt`: `(floor(n · 50/3 · 1e6) − floor((n−1) · 50/3 · 1e6)) · 1e-9f` for pump n, alternating by 1 ns around 1/60 s | `stubs.c:35-41` |
| cosmetic RNG | runs from `0x9e3779b9`; state at the start (`rng_start`) and at every keyed frame | `engine/c/rng.c` |

`draw.lisp` prints the render scale, lights, scale cap, MSAA, coarse and one-hand after `SG-INIT` and at the end; all 82 runs printed
the same line (INDEX `fixed_inputs.read_from_image`).

### meshes.json

`draw.lisp` names each mesh by the shortest path to its `MESH` struct from a special variable of DUEL / ENGINE. It walks breadth-first
over conses, general vectors, hash tables (keys sorted by their printed form) and structure slots. Examples:
`*BODIES*{:KENPACHI}.PARTS[3]`, `*BODIES*{…}.HULLS[i][1]` (an ink hull), `*WEAPONS*{:KAZESHINI}.MESHES[0][0]`, `*ST-FLOOR*`,
`*ST-ROCKS*[0].` (the cdr of a cons), `*SHADOW-MESH*`. All 670 meshes are made at startup and all are named. The lazily built art
(`main.lisp:162-177`) is the retired characters' only, which no scene draws. gen.py fails if a mesh has no name, or if a mesh id names
something different in two scenes or two runs (ids are per process).

### The scenes (41; 3733 keyed frames)

Every command's meaning, checked in the code, is in `draw-scenes.json` / INDEX `commands`.

| Group | Scenes | Commands | Frames keyed |
|---|---|---|---|
| quiet (Tasks 5-7) | `quiet-2500` … `-2503`, `quiet-2394` … `-2397`, `quiet-84000`, `-84001`, `-84004`, `-84005` | the one command at frame 0 | every 5th of 10 s (`0-600/5`) |
| slowmo | `slowmo-2513` | 2500 at 0, 2513 at 30 | every frame `0-239` (named `slowmo` 30-209: SLOWMO-SCALE 0.2 at frames 30-203, easing to 1 at 204-209, 1.0 from 210, read from the log) |
| forms | `forms-ken-p2` (2505, then 2508 at 80 / 160 / 240: P2 Kenpachi sealed -> Shikai L2 -> KYORAN -> ZANKAI), `forms-ken-p1` (84001, 84004 at 80, 84005 at 160), `forms-ichigo` (2394, 2395 at 80) | as listed | frame 0, then each form on 3 frames 20 apart (30 / 50 / 70 after its command; named) |
| battle (Task 8) | `battle-2005` (Ichigo vs Kenpachi, seed 5), `battle-2006` (Ichigo vs Ichigo, seed 6) | the one command | every 10th frame of the first 60 s, the looks windows, the hitstop window (2005), each mid-match cinematic every 5th frame (named) |
| portrait | `portrait-2501`, `portrait-2005` (390x844) | the one command | every 30th of 30 s |
| cinematics | 5 held by CINE-AT (`cine-ken-nozarashi` 11107, `cine-soul-break` 16095, `cine-intro` 17299, `cine-ko` 18149, `cine-ken-bankai` 35185); 7 Kenpachi Kikons played (`cine-84094`, `-84095`, `-84096`, `-84097`, `-84006`, `-84007`, `-84008`); 8 Ichigo cinematics held (`cine-ic-kikon` 75061, `-kessa-kikon` 75143, `-kessa` 75215, `-kessa-getsuga` 75299, `-heavy-kikon` 75379, `-rush-kikon` 75459, `-chain-kikon` 75539, `-haste-kikon` 86110); `cine-84094-portrait` (390x844) | the one command | every 5th frame from 0 to the hold frame + 15 (held) or the cinematic's length + 30 (played) |

What was checked from each scene's `draw f` lines:
- **quiet:** `*flow*` is BATTLE with no cinematic at the end of every frame. 2500-2503, 2394-2397 and 84000-84005 call START-MATCH under
  `*skip-cines*`, so INTRO-CINE starts and ends inside frame 0's command (its `[0] cine INTRO-CINE` log line). No `P1` / `P2 move`
  line: both fighters stand (no input reaches P1 natively; P2's brain is off).
- **held cinematics:** each one plays from frame 0, one cinematic frame per frame, and holds at the listed frame (`held` 1 from there).
  The CINE-AT ones use f = length − 1, so the whole cinematic plays and holds on its last frame. Ichigo's commands can hold only at
  3k: each holds at the last multiple of 3 below its length (183 of 186, 189 of 192, 165 of 168, 177 of 180). Their last 2-3 frames
  and their ends have no key here; the battle scenes' played Ichigo Kikons (heavy, rush, the awakening) cover those three's ends. One
  command per cinematic is enough: the looks gate's several commands per cinematic only move the hold point.
- **played Kikons:** the cinematic runs its full length, then the scene runs on (BATTLE, no cinematic).
- **forms:** the log has `P2 form NOZARASHI / BANKAI / BANKAI-2` at the commands' frames (forms-ken-p2).
- **battle:** the intro holds the first 300 frames, so the battle starts at frame 300. `*match-tick*` restarts there, and from then on
  frame = 300 + match tick, one step per frame, cinematics included. `ENGINE::*TICK*` does not advance in a cinematic (CINE-STEP skips
  TIME-STEP), so it lags the frame count after the intro and after each Kikon. Neither match ends within the keyed 7124 frames.

**Deviations from the brief's scene list, with reasons:**
1. **75300+k replaced by all seven Ichigo cinematics.** `ichigo-debug` decodes 75000 + 80 i + k as cinematic i held at frame 3k. So
   75300 is i 3 (`ic-kessa-getsuga-cine`) at frame 180, and 75320 and up is i 4. It is no longer "the awakening at frame 2k": that is
   the old 150 i + 2k numbering, which `tests/style-gates.py` LOOKS_CINES's comment still quotes. The awakening is i 2 (`ic-kessa-cine`).
   The key holds each i = 0 … 6 at 3k = the last multiple of 3 below its length, which covers every 75000+ still.
2. **`ic-haste-kikon-cine` (超速連斬) added through 86110** (ichigo.lisp ICHIGO-SUB-DEBUG). It is outside 74000-75599, and 86110 is the
   only command that starts it, so it is keyed up to its hold at frame 40 only (frames 0-60). Its frames 41-159 have no key.
3. **84096 / 84097 added**: the Bankai's Kikons (`ken-kr-kikon-cine`, `ken-zh-kikon-cine`), in the same KEN-CORE-DEBUG block as 84094 /
   84095 and 84006-84008.
4. **35000+f only.** 35000+f and 19000+f dispatch to the same `(cine-at 9 f)` (`ken-bankai-cine`), so the Bankai is keyed once, as
   35185.
5. **The hitstop window (the controller's ruling R2)** is in `battle-2005`, not a scripted J in 2501 (the native image has no key
   device). Frames 422-434: P2's KE-Z-AS1 hits P1 (HIT 90) at match tick 123. Frame 423 sets `*hitstop*` 10; frames 424-432 are frozen
   (`*hitstop*` 9 … 1 at their ends); frame 433 releases. (The earlier 3-frame windows at match ticks 66 and 105 come from a CANCEL and
   an ABSORBED.) The slowmo scene is 2500, then 2513 at frame 30.
6. **The looks windows by match tick, drawn.** The looks gate reaches its windows in turbo (2102: 120 steps per frame, no draw, no
   HUD) after skipping the intro with Enter. Turbo cannot be keyed and the native image has no Enter. So the key stays drawn, keeps the
   intro, and keys every frame around each window's match tick. The gate's script gives: about 48 live ticks after the skip, then turbo
   2 / 8 / 16 / 30 frames (×120 ticks), each followed by its shots at +0.1 s (and +0.4 s for w1) and 0.05 s more. That makes w0 tick
   288 (shot 294), w1 1257 (1263, 1281), w2 3204 (3210) and w3 6813 (6819). The keyed frames are 300 + tick from 5 ticks before the
   window to 5 after its last shot: 583-600, 1552-1586, 3499-3515 and 7108-7124 (named in INDEX). They are timing windows only: the
   gate's seeds (12 41 6 5 28) are not 2005 / 2006's.
7. **Mid-match cinematics added to the battle scenes.** None starts in the first 60 s. Ichigo's Kikons come at match ticks 6153 (2005:
   `IC-HEAVY-KIKON-CINE`), 5260, 5674 and 5928 (2006: rush, heavy, and the awakening `IC-KESSA-CINE`). Each is keyed every 5th frame
   over its length, so "everything at once" has its cinematics.
8. **2005 / 2006 are in scope:** seeds 5 and 6 draw Ichigo vs Kenpachi and Ichigo vs Ichigo from the playable roster, so no Hisagi or
   Yamamoto appears.

### Sizes and times

593 MB in `build/oracle/draw/` (the 41 `.bin`, 148 M floats), plus the logs. The largest is `battle-2006` (110 MB, 552 frames). gen.py
draw takes ~30 s on this machine (6 parallel processes; 1.5-6 s a scene, twice), plus ~2.5 min to build the image when stale. Nothing
was thinned.

### Findings for later tasks

- **`*dq*` grows; it never drops.** DRAW-MESH doubles `*dq*` when it is full (`render.lisp` DRAW-MESH: `(replace (make-f32 (* 2 (length
  q))) q)`). 512 records is only its initial size. The key has frames with up to 578 records. The only cap is C's `R_MAX_DRAWS` 4096
  (`render.c:259`). The plan's Global Constraints call it "the 512-record `*dq*`": only the stream buffers (`stream-room-p`) and
  `R_MAX_DRAWS` drop.
- The HUD (`hb`) is empty in a cinematic and on the frame a cinematic ends. `hk` is empty in every keyed frame: only the paint shapes'
  test card and the transparent scene fill it, and no scene turns either on. `ui` (the canvas words) appears in the cinematics and in
  the battle's captions. `fxb` (additive) appears in the battles and the Kikons.
- `fu[157]` = 0.5 in every frame (MSAA 1).
- **HUD-DRAW writes one value the next frame's picture reads: `*aura-cap*`.** AURA-CAP-UPDATE (hud-screens.lisp:10, the first form
  of HUD-DRAW) sets it from the fighters' distance (0.5 within 2.5 m, 1 from 3.5 m). The next frame's VFX-AURA multiplies its presence
  by it (vfx.lisp:277), and its emission counts (`n-of`) draw `rnd01`. So whatever replaces the HUD on M3a's page must still run
  AURA-CAP-UPDATE at HUD-DRAW's place, or the cosmetic RNG leaves the key. Measured: the same scenes with debug 2120 at frame 0 (no
  HUD-DRAW at all) keep every keyed `rng_state` in battle-2005 and cine-84094. battle-2006 differs from frame 6437 on: the frame after
  a hit at match tick 6136 brings the fighters close while Ichigo's KESSA aura burns. No `lhud-*`, `hud*`, `webhud` or `paint*` file
  calls `rnd01`: the HUD itself draws no cosmetic randomness.

## 2. Clip sampling and rig FK (Task 2)

`rs/duel-look/src/anim.rs` (CLIP-SAMPLE!, ANIM-PLAY / -ADVANCE / -EVAL, F-WRAP, KIT-MOVE-CLIP, FIGHTER-STANCE-CLIP) and
`src/rig.rs` (the rig tables, %EULER! / %AFFINE-MUL! / %JOINT-ROT!, %POSE-FK!, JOINT-POINT!, BODY-WEAPON-POINT / -TIP / -BASE).
`tests/fk.rs` `fk_matches_key` replays all 400 clip files of `$ORACLE/fk` (every rig, every form's weapon tip and base, every
frame): **bit-exact** (largest |a-b| / max(1, |b|) = 0 over 11,474,064 matrix floats and 273,552 weapon floats). The test fails when
`ORACLE` is unset; it never skips.

### Interfaces as built (what Task 7 calls)

- `pose_fk(pose, props, px, py, pz, yaw, scale, hunch, out: &mut [Mat4; 21])`, not the plan's `root: &Mat4`: %POSE-FK! adds the
  pose's root yaw (`pose[66]`) to YAW before one cos / sin, so a precomputed root matrix cannot round the same. DRAW-FIGHTER passes
  the fighter's position and yaw, as here.
- `Proportions::of(rig: &duel_data::Rig, body: &Body)` (the plan: `of(body)`): it carries the rig's parents, flex signs and mirrors
  with the body's bone offsets and pelvis height, all POSE-FK! reads besides the pose. `bodies.json`'s `props` already holds
  MAKE-RIG-PROPORTIONS' 64 floats (the image computed them), so MAKE-RIG-PROPORTIONS is not ported; a body without `props` takes
  rig.json's offsets (*RIG-OFF*) and %POSE-FK!'s literal `0.98f0`.
- `anim::sample(clip, t, key_ease, out)`: `key_ease` 0 smoothstep (the engine default; art.lisp's host load), else ease-out cubic
  (the game: START-GAME sets *KEY-EASE* 1; rig.json's `key_ease` is 1). A :snap key is linear in both. The FK key is mode 1;
  `tests/art.rs` runs mode 0.
- `Anim<'d>` holds `&'d Clip`; `play(clip, blend, speed, time, restart)` takes all of ANIM-PLAY's keywords (the plan listed three:
  PLAY-CLIP passes time and restart too). `eval(key_ease)` samples with the given mode; the crossfade itself is always smoothstep.
  `advance` keeps a +0 blend at +0 (the Lisp's `signbit` guard). Everything is inline arrays: no allocation per frame.
- sin / cos are `duel_sim::math::f_sin` / `f_cos` (libm = musl's sinf / cosf: the native image's preload, M1_NOTES §4); F-WRAP is its
  c-inline literally (`x - 6.2831853f * floorf((x + 3.14159265f) * 0.15915494f)`), not ANGLE-WRAP.

### Findings

- The FK key needed no new extracted data: clips.json's times / snaps / poses / dur / loop, rig.json, bodies.json's scale / hunch /
  props and weapons.json's len / base are all a clip's FK reads. The checksum pin is unchanged.
- `fk_matches_key` also asserts the key's inputs equal the data's: each rig's scale, hunch and props bit for bit against every body
  in it, each form's body and weapon against kits.json, t_i = i / 60 bit for bit, N = floor(dur x 60 + 0.001).
- art.lisp's reach rows (62 links of the Kenpachi / Ichigo forms) equal a native-image run of the same loop under *KEY-EASE* 0 at
  four decimals (a scratch runner on `build/simgate/duel.fas`), so the frame ranges, clip maps and clip speeds are the Lisp's, not only
  inside ±0.15 m.
- core.lisp 738's `*clips-5*` is read off the frozen test file's own text (`include_str!`), not retyped.
- **`engine/lisp/body.lisp` has no rig half.** The plan's "the rig half of engine/lisp/body.lisp" finds BUILD-PARTS / BUILD-SOLID /
  BUILD-SHAPE / SHAPE-XFORM / PAL-RGB (the part meshes: Task 3) and DRAW-PARTS (queueing the posed parts: Task 5 / 7) only; the rig
  and its FK are all in `engine/lisp/anim.lisp`, ported here. The rig math left is in `duel/lisp/body.lisp`, all draw-time looks for
  Task 7: GRIP-LEFT! / GRIP-TARGET-OK-P / GRIP-GAP with %ROT-TO! / %ROT-COLS! (the left fist pulled onto the handle after the FK, for
  *GRIP-CLIPS*), DRAW-WEAPON / DRAW-PLANTED-WEAPON / %PLANTED-M!, DRAW-BODY, DRAW-SHADOW; its BODY-WEAPON-POINT / -TIP / -BASE are
  ported here (`rig.rs`), its DEFPOSE / DEFCLIP / DEFRUN forms are data (clips.json, poses.json).

## 3. Meshes (Task 3)

`rs/duel-look/src/mesh/`: `meshgen.rs` (engine/lisp/meshgen.lisp: the builder, WITH-XFORM, %MB-TRI with the smooth normals,
MB-POLY-OUT, the box / bevel box / cylinder / cone / sphere / wedge, MB-HULL), `body.rs` (engine/lisp/body.lisp BUILD-PARTS /
BUILD-SOLID / BUILD-SHAPE / SHAPE-INK-K, duel/lisp/body.lisp GIRTH-SPEC), `stage.rs` (stage.lisp STAGE-INIT's meshes), `mod.rs`
(`Meshes::build(&Data)`, the weapons, the ink shadow, `Ids`). `tests/mesh.rs`:
- `mesh_table_matches_key`: duel-data's registry equals the key's meshes.json (670 entries);
- `meshes_match_key`: the filled ids are exactly the 368 in scope. Every in-scope id has the registry's vertex count, and the 277 the 41
  scenes draw equal the key. That is 1,002,618 floats; the largest |a − b| / max(1, |b|) is 3.9e-14 (`*ST-FLOOR*`, a near-zero
  coordinate from a long-float cos). 8,409 floats are not bit-equal, all of them within 4e-14 of zero (signed zeros and pi-noise). Every
  other float is bit-exact.

Both tests fail when `ORACLE` is unset.

### The mesh registry (the controller's ruling R1)

`tables.json` `mesh_ids` = `[[id, path, verts] ...]` by id. `tools/port/extract/extract.lisp` X-MESH-IDS builds it after SG-INIT with a
copy of draw.lisp's naming walk (DW-NAME-MESHES: the shortest path from a DUEL / ENGINE special, BFS, hash keys sorted). It is read by
`Data::mesh_ids()`. The extract image (`build/simgate/duel.fas`, stubs.c) makes the same 670 meshes in the same order as the draw
image, so the table equals the key's meshes.json entry for entry, and the app never reads the key.
- Tables went from 27 to 28. The float checksum stays `3ddcd77c9a34edf5`: the table holds only integers and strings, and JSON-TREE-FNV
  folds floats only.
- Every other data file re-extracted byte-identical, and the census passes.

`Meshes::build` writes each mesh into the id its Lisp path names (`*BODIES*{:KENPACHI}.EXTRAS[9][1]`, `*WEAPONS*{:TENSA}.MESHES[0][3]`,
`*ST-ROCKS*[2].` ...). The ids never come from counting creation order.

### Findings

- **Weapons are data.** weapons.json's section verts (the extractor ran each DEFWEAPON section on a fresh builder, as BUILD-WEAPON
  does) are the meshes bit for bit. Only their hulls are built here (MB-HULL k = the section's ink, c 0.8). MB-BLADE, MB-TUBE and the
  section lambdas are not ported.
- **ken-art.lisp, ichigo-art.lisp and brush.lisp build no meshes.** Their bodies are DEFBODY / BODY-VARIANT specs, already extracted
  into bodies.json with the variant merge applied. So the brief's `brush.rs`, `ken.rs` and `ichigo.rs` do not exist. The only mesh
  builders are engine/lisp/body.lisp, duel/lisp/body.lisp (BUILD-WEAPON, BODIES-INIT's shadow) and stage.lisp.
- **`gen.rs` is `meshgen.rs`**: `gen` is a reserved word in edition 2024.
- **No cosmetic RNG at build time.** Jitter is 0 on every builder (BUILD-SOLID's `*part-jitter*` 0.0, BUILD-MESH's default), so
  MB-RAND never runs. The stage's randomness is ST-RND, an integer LCG seeded with 7771 and ported exactly in i64, called in the Lisp's
  evaluation order.
- **Long-float sites** (every `pi`: rings, sphere rows, the shadow disc, the stage's annuli, walls and houses) are computed in f64 through
  `duel_sim::math::sin_d` / `cos_d` (musl via `libm`, new). The rational factors `(/ k n)` are f64 divisions, narrowed where the Lisp
  narrows (V3, XFORM's F32). Single sites stay single: the cracks' ST-STRIP, hull and ink-k math, and M4-EULER! with cosf / sinf.
- **MB-HULL's groups** use CL ROUND's single quotient `x / 1e-4` (half to even). Each group's normal sum runs newest first (the Lisp
  pushes), and its MIN / MAX keep CL's tie rule.
- **BUILD-PARTS' lists** are push lists: EXTRAS / HULLS index i is the reverse of build order. Tags come from REMOVE-DUPLICATES, which
  keeps the last occurrence.
- **Not ported** (no Kenpachi / Ichigo / stage shape uses them): a shape's `:squash` (it asserts), MB-BOX `:colors`, MB-PLANE.

### Interfaces as built (what Tasks 5 / 7 call)

`Meshes::build(&Data) -> Meshes`. `Meshes::get(id) -> Option<&MeshData>` (`floats`, 9 a vertex), and `filled()`. `Meshes.ids: Ids`:
- `bodies[name]`: `parts[joint] -> Option<id>`, plus `extras` and `hulls` in the Lisp's list order with their joint, tint, emissive
  and tag (DRAW-PARTS' inputs);
- `weapons[name]`: the sections with id, tint, emissive and hull id (DRAW-WEAPON's);
- `shadow`;
- `stage`: floor, walls, town, burnt, and rocks as (chip, hull).

The keys are the data's lower-case names.

### M4: ids left empty

302 of the 670 meshes:
- the bodies `hisagi`, `hisagi-bankai`, `yamamoto`, `yamamoto-bare`, `yamamoto-tybw` and `skeleton`;
- the weapons `kazeshini`, `hs-sealed`, `hs-orb`, `ryujin-jakka`, `zanka` and `ya-cane`.

`mesh::PORTED` (`kenpachi`, `ichigo`) selects the bodies (the name or `<name>-…`) and the kits' weapons. M4 adds a name there and
checks those meshes, all drawn by no M3a scene, against a key that draws them.

91 in-scope meshes are drawn by no scene: `kenpachi-nomi` 52, `kenpachi-oni` 21, `ichigo` 17, `ichigo-kessa` 1. The test checks only
their vertex counts.

## 4. The look queue, the per-step sink, the frame split (Task 4)

`rs/duel-sim/src/look.rs` (`Event`, `LookEvent`, `LookQueue`, `LookSink`, `NoLook`, `KitRef`, `Match::look` / `Match::emit`),
`rs/duel-look/src/scene.rs` (`Scene`, `SceneInputs`, `Model`, `Rim`), `rs/duel-look/src/rng.rs` (`CosRng`). Every `// look:` site in
`duel-sim` now pushes its call onto `Match.looks`, and `flow::sim_step` hands the queue to a `LookSink` at FEEDBACK-SYSTEM's place.

### How it works

- **One queue, two kinds of call.** The Lisp applies a model / clip / camera / sound call at once, inside the step's systems, and queues
  an EMIT on `*events*` for FEEDBACK-SYSTEM. Both go into `Match.looks` in program order. A sink applies every non-`Emit` event in
  order (`LookQueue::calls`), then every `Emit` in order (`LookQueue::events`). That is the Lisp's order: the calls during the systems,
  then DO-EVENTS oldest first. (`feedback.lisp`'s `:step` reads the clip a later PLAY-CLIP of the same step set, so one pass in push order
  would be wrong.)
- **The sink's place** (`main.lisp:30-45`): `sim_step` = `sim_core` (the tick, then the cinematic, a hitstop step, a slow-motion wait
  or the systems), FQ-MATCH-END's Search half, `look.step(m)`, HASH-LOG's `step_end`, MC-FULL-STEP. GOD-UPDATE / PROBE-UPDATE are not
  ported (debug). `LookSink::step` drains the queue and reads the match; it writes nothing else.
- **The frame pass** (`LookSink::frame`): `flow::frame` calls it last, after the steps, so it is done before any caller draws. It applies and removes the
  immediate calls still queued, and keeps the EMITs for the next step's FEEDBACK-SYSTEM. Those calls come from a debug command, or from
  a frame that ran no step: `raw_dt(1)` is under a step, so the frame that spawns the fighters runs none; at 120 Hz every other frame
  runs none; a pause or a menu runs none. The Lisp made them at once, before that frame's draw. (Fix round 1: it was in `frame_headless`
  only, so the documented loop would have drawn with them still queued.)
- **The mute.** `Match::look` / `Match::emit` do nothing while `m.in_rollout`. No site calls `m.looks.push` directly
  (`grep -rn 'looks.push' rs/duel-sim/src` finds only look.rs). `sim_step_lean` (SIM-STEP-LEAN) ends with `NoLook` (its TAKE-EVENTS).
  The Lisp rollout runs no feedback, drops `*events*` (no snapshot root), and its restore puts back the ECS, whose MODEL holds the clip
  player, and the cinematic roots (`sim-state.lisp:19-52`; `tools/simgate/fulltest.lisp` asserts every special). So the rollout's
  looks never happen, and the live `Scene` is never handed to a rollout. `LookQueue::push` itself does not check the flag: the queue
  does not know the match. Deviation from the brief's wording: the brief puts the mute on `push`.
- **SPAWN-PAIR's TAKE-EVENTS** is `LookQueue::take_events`. It drops the EMITs only: the immediate calls queued before it were already
  made in the Lisp.
- **The frame split** (M1_NOTES §10, M2_NOTES §12):
  - `flow::frame(m, s, input, look, rdt) -> bool`: the commands, FLOW-UPDATE, GATE-UPDATE, the steps, then the frame pass; RDT is an
    argument;
  - `flow::frame_end(m, s)`: FQ-MATCH-END's apply;
  - `flow::frame_headless(m, s, input, look)`: `frame` with `raw_dt(frame_n + 1)` (unchanged arithmetic), `cine_draw` unless turbo,
    `frame_end`. That is the replayer's order before this task, and all the tools use it. The game's loop is the same three calls:
    `frame`, `draw_frame` (whose DRAW-SCENE runs `cine_draw`), `frame_end`.
  - `Match`'s `Clone` reserves the look queue's whole `LOOK_RESERVE` (beside `iccs` and `hz_dead`): a snapshot slot made from a short
    queue at `warm` takes a later mid-step snapshot (the strategy layer's, inside BRAIN-SYSTEM, after SLOW-SNAPSHOT's events) with no
    allocation (fix round 1; `state::tests::clone_keeps_the_look_reserve`).
  - The four frame-time `// look:` sites in `flow.rs` (SCREEN-FX-UPDATE / ONEHAND-FRAME, the menus' idle ANIM-ADVANCE by RDT,
    SLOW-DRAW / the fx clock / the camera, the HUD) are not queued: they belong to the drawer (Tasks 5-7, 10).
- **`to_idle` takes TO-IDLE's blend.** The Lisp's callers pass 0 (BEGIN-BATTLE, REPEL!, ORANGE, the awakening / Bankai AFTERs,
  RESET-ROUND, CORE-BOUNCE!, CORE-KIKON-UNDO!'s wave, KEN-BK-TICK, debug PLACE), 3 / 4 (fighter.lisp 543, 910, 917, 978) or the default
  6. Each Rust caller now passes the same value. Only the clip's crossfade reads it, so the sim gates cannot see it.
- **Kit readers moved.** `kit_move_clip` / `fighter_stance_clip` moved from `duel_look::anim` to `duel_sim::kit`, so the sim's sites
  can choose the clip. `duel_look::anim` re-exports them, so Task 2's tests are unchanged.
- **Hit-window look flags.** `:ice` / `:blade` / `:thread` got bits in `combat.rs`'s flag table (they were discarded). The `:hit`
  EMIT's kind is the Lisp's COND over them, in its order: ice, bind, blade → flash, thread → quick, hazard → fire, the move's kind, else
  counter. No sim path reads them.
- **`Scene` (Task 4's part).** It keeps the fighters' MODEL (body, weapon, hide tags, alpha, mirror tint, the rim and ICHIGO's saved
  rim) and Task 2's `Anim` per fighter, created by the `Model` event (SPAWN-FIGHTER's MAKE-MODEL). It applies `Clip` (PLAY-CLIP's
  :look-clips → BODY-CLIPS → the clip, falling back to the kit's stance), `AnimSpeed`, `RecoveryPace` (its anim half, reading the clip
  player), `AnimAdvance`, `CineActorStep` (+STEP+ × `*cine-time-scale*`, reset by `CineEndLook`), `Alpha`, `Rim`, `RefreshLook`,
  `SlowSnapshot` / `SlowKeep` (`*slow-was*`, cleared past 48 entries). FX, sound, camera, canvas words and the cinematic looks are
  no-ops marked `// task N` (6, M3b, 7, 8, 8). `SceneInputs` holds the viewport, MSAA, render scale, pixel lights, coarse, one-hand and
  the scene-scale cap; the tests read them from the key's INDEX.json, and nothing in the port holds them as constants.
- **`CosRng`**: `rng_float` bit for bit (the sim stream's xorshift32 wrapped, its own state, boot state `0x9E3779B9`); `seed` is
  `rng_seed` (fmix32), `rnd01`, `state`. It lives in `Scene`, never in `Match`. Nothing draws from it yet: the first draws are Task 6's.
- **`KitRef`** (`&'static Kit`, compared by address, printed by its name) keeps `LookEvent` `Copy + PartialEq` without `Kit: PartialEq`.
  `LookEvent` holds no `String` or `Vec`; a clip or sound name is a `&'static str` from the data or a literal (the brief's `clip: u16`
  would need a name → index table; the sink resolves the name against the model's body and the kit instead, as PLAY-CLIP does).

### The sites: 145 rows

The brief's 114 markers became 145 rows, for three reasons:
- markers that listed several calls were split, one row per call;
- the Lisp calls with no marker were added: ICHIGO-RENZAN's `:sfx`, ICHIGO-PARRY-OPEN's two `:sfx`, KEN-CHIGIRI-BURST's and
  KEN-TATEGOTO-CUT's `:ken-bk-burst`, KEN-GROUND-CRACK's and KEN-BK-SLAM's `:ground-scar` + `:sfx`, a ward's `:blocked`, CORE-KIKON-KNOCK!'s
  CORE-FOLLOW-CUES, SET-BLOCKSTUN's clip, SET-CAM-BEHIND's `*cam-cut*`;
- the parry rim is written on every frame of the window, not only when it is saved.

Columns:
- **pre**: the state the call reads. `C` means the payload carries what it read at the call (for a clip: the clip chosen from the sim
  state and the kit). A SLOW-SNAPSHOT keep and a cinematic's `CineAt` carry state from before the step's systems or script moved it.
  `L` means the payload holds entity handles only, and the sink reads live state at FEEDBACK-SYSTEM's place, as the Lisp does.
- **rollout**: `muted` means `Match::look` pushes nothing while `in_rollout`, as described above.

By variant: 21 `Clip`, 19 `Emit(Sfx)`, 6 `RefreshLook`, 5 `Emit(KenBkBurst)`, 4 each `Emit(Refused)` / `Emit(Clash)`, 3 each
`Emit(RushDash)` / `Emit(HohoOut)` / `Emit(GroundScar)`, 2 each `SlowKeep` / `Rim` / `Music` / `Emit(Step)` / `Emit(Konpaku)` /
`Emit(HazardCut)` / `Emit(Blocked)` / `Emit(Armored)` / `CamCut` / `Alpha` / CORE-FOLLOW-CUES' pair; one each of the rest.
Ten rows push nothing: four frame-time, four cinematic arms covered by `CineAt`, the absent `:step` hook, Bankai's LOST 0.

| Site | Lisp call | Variant | pre | rollout |
|---|---|---|---|---|
| `ken/mod.rs:72` | emit :ken-bk-burst (KEN-BANKAI-BURST / -CHIGIRI-STILL / -QUAKE) | Emit(KenBkBurst) | C: the point / values at the emit | muted |
| `ken/hooks.rs:106` | emit :konpaku | Emit(Konpaku) | C: the point / values at the emit | muted |
| `ken/hooks.rs:141` | emit :ken-bk-burst :chigiri-draw | Emit(KenBkBurst) | C: the point / values at the emit | muted |
| `ken/hooks.rs:148` | emit :ken-bk-burst :chigiri | Emit(KenBkBurst) | C: the point / values at the emit | muted |
| `ken/hooks.rs:160` | emit :ground-scar | Emit(GroundScar) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `ken/hooks.rs:161` | emit :ken-bk-burst :tategoto | Emit(KenBkBurst) | C: the point / values at the emit | muted |
| `ken/hooks.rs:168` | emit :ken-bk-burst :tategoto-cut | Emit(KenBkBurst) | C: the point / values at the emit | muted |
| `ken/hooks.rs:188` | emit :sfx | Emit(Sfx) | C: the point / values at the emit | muted |
| `ken/hooks.rs:195` | emit :ground-scar | Emit(GroundScar) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `ken/hooks.rs:196` | emit :sfx :ground-crack | Emit(Sfx) | C: the point / values at the emit | muted |
| `ken/hooks.rs:210` | emit :ground-scar | Emit(GroundScar) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `ken/hooks.rs:211` | emit :sfx :ground-crack | Emit(Sfx) | C: the point / values at the emit | muted |
| `fighter/moves.rs:115` | (play-clip e (kit-move-clip kit (mv-clip mv)) :blend (mv-blend mv) :speed … :time (/ (* enter speed) 60.0)): a pre-roll's | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/moves.rs:137` | emit :super | Emit(Super) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/moves.rs:139` | emit :breaker | Emit(Breaker) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/moves.rs:141` | emit :rush | Emit(Rush) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/moves.rs:163` | play-clip at the cut (:blend 0) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/moves.rs:180` | (play-clip e (kit-move-clip kit (mv-clip-2 mv)) :blend 0 :speed …) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/moves.rs:183` | emit :breaker-end | Emit(BreakerEnd) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/moves.rs:305` | emit :rush-dash | Emit(RushDash) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/moves.rs:329` | emit :rush-dash | Emit(RushDash) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/moves.rs:362` | a pre-roll's (setf (anim-speed …) (mv-clip-speed mv)) at the hit pose | AnimSpeed | C: value | muted |
| `fighter/moves.rs:373` | emit :swing on a window's first frame | Emit(Swing) | C: the point / values at the emit | muted |
| `fighter/moves.rs:386` | RECOVERY-PACE (the anim's speed: the sink reads its clip) | RecoveryPace | C: steps left; the clip read by the sink | muted |
| `fighter/react.rs:83` | (play-clip e :sh-launch :blend 2) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/react.rs:85` | emit :launch | Emit(Launch) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/react.rs:102` | (play-clip e (case react … (t :sh-flinch)) :blend 0) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/react.rs:113` | (play-clip e (or clip :sh-guard-hit) :blend 0) (no caller passes CLIP: a drunk hit's, retired) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/states.rs:42` | the :step hook (no live kit has one: `kit.hooks` has no "step", none queued) | - | - | comment only (no live kit has a :step hook) |
| `fighter/states.rs:50` | (play-clip e (cond … :sh-step-r / -l / -f / -b) :blend 2) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/states.rs:52` | emit :step | Emit(Step) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/states.rs:88` | (play-clip e (run-clip e f) :blend 5 :speed (/ (kit-run kit) 8.0)) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/states.rs:90` | emit :step | Emit(Step) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/states.rs:114` | emit :hoho-out | Emit(HohoOut) | C: the point / values at the emit | muted |
| `fighter/states.rs:123` | emit :perfect | Emit(Perfect) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/states.rs:158` | (play-clip e :sh-guard :blend 3) (unreachable: GUARD-HELD-P is NIL) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/states.rs:183` | (play-clip e (fighter-stance-clip f) :blend 6 :restart nil) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/states.rs:196` | (play-clip e (… :sh-strafe-r / -l, :sh-walk-f / -b) :blend 6 :restart nil) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/states.rs:269` | (play-clip e (fighter-stance-clip f) :blend 6) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/states.rs:281` | (play-clip e (run-clip e f) :blend 5 :speed (/ speed 8.0) :restart nil) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/states.rs:322` | (setf (model-alpha (model e)) (if (< sf *hoho-appear*) (f32 (- 1.0 (/ sf (float …)))) 1f0)) | Alpha | C: value | muted |
| `fighter/states.rs:328` | (play-clip e :sh-hoho-in :blend 0) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/states.rs:329` | emit :hoho-in (the :hoho hook: no live kit has one) | Emit(HohoIn) | C: the point / values at the emit | muted |
| `fighter/states.rs:335` | a perfect Hoho's counter pose (play-clip … :blend 0 :time 0.1) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/states.rs:363` | (play-clip e :sh-down :blend 3) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/states.rs:364` | emit :land | Emit(Land) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/states.rs:373` | (play-clip e :sh-wakeup :blend 2) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/states.rs:381` | (play-clip e :sh-roll :blend 2) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/mod.rs:258` | MAKE-MODEL (body, mirror tint / rim), MAKE-BLADE | Model | C: kit, mirror | muted |
| `fighter/mod.rs:279` | refresh-look | RefreshLook | C: kit at the call | muted |
| `fighter/mod.rs:280` | (play-clip e (kit-stance kit) :blend 0) | Clip | C: clip chosen and kit read at the call | muted |
| `fighter/mod.rs:354` | emit :refused | Emit(Refused) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/mod.rs:431` | emit :refused | Emit(Refused) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/mod.rs:438` | emit :refused | Emit(Refused) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `fighter/mod.rs:589` | (anim-advance (model-anim (model e)) +step+) (M1_NOTES §1) | AnimAdvance | C: dt | muted |
| `fighter/mod.rs:668` | (play-clip e (fighter-stance-clip f) :blend blend) | Clip | C: clip chosen and kit read at the call | muted |
| `combat.rs:584` | emit :hit | Emit(Hit) | C: the point / values at the emit | muted |
| `combat.rs:673` | emit :armored | Emit(Armored) | C: the point / values at the emit | muted |
| `combat.rs:692` | emit :parried | Emit(Parried) | C: the point / values at the emit | muted |
| `combat.rs:704` | emit :absorbed | Emit(Absorbed) | C: the point / values at the emit | muted |
| `combat.rs:725` | emit :guard-crush | Emit(GuardCrush) | C: the point / values at the emit | muted |
| `combat.rs:736` | emit :blocked (a ward's) | Emit(Blocked) | C: the point / values at the emit | muted |
| `combat.rs:740` | emit :blocked | Emit(Blocked) | C: the point / values at the emit | muted |
| `combat.rs:752` | emit :guard-break | Emit(GuardBreak) | C: the point / values at the emit | muted |
| `combat.rs:758` | emit :stance-break | Emit(StanceBreak) | C: the point / values at the emit | muted |
| `combat.rs:911` | emit :clash | Emit(Clash) | C: the point / values at the emit | muted |
| `cine.rs:86` | (setf *grade-split* 0.0 … *cine-cam* nil) | CineStart | args | muted |
| `cine.rs:100` | (setf *cine-cam* nil *grade-desat* 0.0 *grade-split* 0.0) | CineStop | - | muted |
| `cine.rs:148` | *cine-actor-hook* (CINE-ACTOR-STEP: the actor's clip advances) | CineActorStep | L (the time scale: the sink's) | muted |
| `cine.rs:160` | the script's look forms at CF (every script's: the arms below) | CineAt | C: actors before the script | muted |
| `cine.rs:162` | clips, shots, captions, intro weapons, the negative cut, FIGHT!'s sound (`LookEvent::CineAt` above) | - | - | covered by `CineAt` (cine.rs:160) |
| `cine.rs:168` | clips, hold-pose, the two-tone frame, shots, the stamp, the rain (`LookEvent::CineAt` above) | - | - | covered by `CineAt` (cine.rs:160) |
| `cine.rs:174` | clips, hold-both, impact frames, shots, the stamp, silence, cine-shatter (vfx), shake (`LookEvent::CineAt` above) | - | - | covered by `CineAt` (cine.rs:160) |
| `cine.rs:180` | the caption, the negative frame, the shot (`LookEvent::CineAt` above) | - | - | covered by `CineAt` (cine.rs:160) |
| `cine.rs:200` | caption, lens, close-up flags | CineBegin | args | muted |
| `cine.rs:216` | caption, card, grade, dutch, fov, aura, draw scale, time scale, camera up, silhouette, flash, screen fx, stage env | CineEndLook | - | muted |
| `cine.rs:233` | refresh-look | RefreshLook | C: kit at the call | muted |
| `cine.rs:283` | (setf *cam-cut* t) | CamCut | - | muted |
| `round.rs:63` | emit :konpaku | Emit(Konpaku) | C: the point / values at the emit | muted |
| `round.rs:120` | emit :kikon | Emit(Kikon) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `round.rs:123` | emit :soul-break for each of SB | Emit(SoulBreak) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `round.rs:188` | emit :reset | Emit(Reset) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `core_sim.rs:114` | emit :refused | Emit(Refused) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `core_sim.rs:438` | emit :clash | Emit(Clash) | C: the point / values at the emit | muted |
| `core_sim.rs:455` | emit :armored | Emit(Armored) | C: the point / values at the emit | muted |
| `core_sim.rs:522` | emit :clash | Emit(Clash) | C: the point / values at the emit | muted |
| `core_sim.rs:533` | emit :hazard-cut | Emit(HazardCut) | C: the point / values at the emit | muted |
| `core_sim.rs:592` | emit :sp-break | Emit(SpBreak) | C: the point / values at the emit | muted |
| `core_sim.rs:713` | the follow cues on frame 1 (a tap is up after the hitstop) | Emit(KikonFollow), Emit(RushDash) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `core_sim.rs:738` | the dash-in's cues | Emit(KikonFollow), Emit(RushDash) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `core_sim.rs:743` | emit :kikon-follow | Emit(KikonFollow) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `core_sim.rs:744` | emit :rush-dash | Emit(RushDash) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `core_sim.rs:802` | emit :clash | Emit(Clash) | C: the point / values at the emit | muted |
| `gauges.rs:221` | (setf (model-alpha (model o)) 1f0) | Alpha | C: value | muted |
| `gauges.rs:248` | emit :burst | Emit(Burst) | C: the point / values at the emit | muted |
| `gauges.rs:259` | emit :burst-end | Emit(BurstEnd) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `gauges.rs:324` | refresh-look (the body's hurt volume is read from the current kit: docs/bevy/M1_NOTES.md §1) | RefreshLook | C: kit at the call | muted |
| `gauges.rs:331` | emit :form | Emit(Form) | C: the point / values at the emit | muted |
| `gauges.rs:358` | emit :awaken | Emit(Awaken) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `gauges.rs:384` | refresh-look | RefreshLook | C: kit at the call | muted |
| `gauges.rs:385` | (when (plusp lost) (emit :konpaku e lost)): LOST is 0 (his Konpaku kept) | - | - | comment only (LOST is always 0) |
| `gauges.rs:386` | emit :bankai | Emit(Bankai) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `gauges.rs:435` | emit :guard-back | Emit(GuardBack) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `gauges.rs:466` | emit :evolution | Emit(Evolution) | L: ids; the sink reads live state, as FEEDBACK-SYSTEM | muted |
| `flow.rs:65` | screen-fx-update, onehand-frame (frame time: the drawer's, before the steps; not queued) | - | - | frame time: the drawer's (Tasks 5-7, 10); not queued |
| `flow.rs:72` | the menus' idle clips (frame time: the drawer's ANIM-ADVANCE by RDT; not queued) | - | - | frame time: the drawer's (Tasks 5-7, 10); not queued |
| `flow.rs:74` | slow-draw (it puts back what it moves), the fx clock, the camera (frame time: the drawer's; not queued) | - | - | frame time: the drawer's (Tasks 5-7, 10); not queued |
| `flow.rs:98` | the HUD (frame time: the drawer's, before `frame_end`) | - | - | frame time: the drawer's (Tasks 5-7, 10); not queued |
| `flow.rs:186` | slow-snapshot (its CLRHASH) | SlowSnapshot | - | muted |
| `flow.rs:190` | slow-snapshot's KEEP of a fighter | SlowKeep | C: the place before the systems | muted |
| `flow.rs:199` | slow-snapshot's KEEP of a hazard | SlowKeep | C: the place before the systems | muted |
| `flow.rs:298` | (take-events) (`*events*` dropped; the immediate calls stay: the Lisp made them) | `LookQueue::take_events` | - | muted |
| `flow.rs:299` | (fx-clear) | FxClear | - | muted |
| `flow.rs:301` | (stage-clear-cracks) | StageClearCracks | - | muted |
| `flow.rs:320` | (play-music :music-title) | Music | args | muted |
| `flow.rs:338` | (clear-words) | ClearWords | - | muted |
| `flow.rs:343` | SET-CAM-BEHIND's (setf *cam-cut* t) | CamCut | - | muted |
| `flow.rs:354` | (play-music :music 0.2); log-msg: the match seed line, debug-knobs-line | Music | args | muted |
| `flow.rs:365` | refresh-look | RefreshLook | C: kit at the call | muted |
| `flow.rs:371` | (duel-camera *p1* *p2* 0.0 :snap t) | CameraSnap | L (nothing moves after it in the step) | muted |
| `flow.rs:421` | refresh-look | RefreshLook | C: kit at the call | muted |
| `flow.rs:429` | (play-clip e (if won (or (kit-win kit) (kit-stance kit)) :sh-lose) :blend 8) | Clip | C: clip chosen and kit read at the call | muted |
| `flow.rs:433` | (music-stop 1.0) (setf *music* nil) | MusicStop | args | muted |
| `ichigo/mod.rs:75` | emit :sfx :getsuga | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/mod.rs:78` | emit :hoho-out | Emit(HohoOut) | C: the point / values at the emit | muted |
| `ichigo/mod.rs:91` | emit :sfx :getsuga | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/clones.rs:287` | emit :sfx :clone | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/clones.rs:454` | emit :sfx :whoosh-heavy | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/clones.rs:576` | emit :sfx :getsuga | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/clones.rs:698` | emit :sfx :clone | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/clones.rs:753` | emit :sfx :clone | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/clones.rs:882` | emit :hazard-cut | Emit(HazardCut) | C: the point / values at the emit | muted |
| `ichigo/hooks.rs:29` | emit :sfx :chain-snap | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/hooks.rs:107` | (ui-flash 1 1 1 0.55 7.0) | UiFlash | args | muted |
| `ichigo/hooks.rs:108` | emit :sfx :parry-ting | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/hooks.rs:109` | emit :sfx :chain-snap | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/hooks.rs:127` | emit :sfx :getsuga | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/hooks.rs:135` | emit :sfx :whoosh-heavy | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/hooks.rs:144` | emit :sfx :whoosh-heavy | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/hooks.rs:153` | emit :sfx :chain-rattle | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/hooks.rs:154` | emit :sfx :parry-open | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/hooks.rs:168` | emit :hoho-out | Emit(HohoOut) | C: the point / values at the emit | muted |
| `ichigo/hooks.rs:169` | emit :sfx :whoosh-light | Emit(Sfx) | C: the point / values at the emit | muted |
| `ichigo/hooks.rs:332` | (setf (model-rim m) (parry-rim (- 1.0 (/ (- sf (first w)) (float (max 1 (- (second w) (first w)))))))) (the rim saved first) | Rim | C: parry level | muted |
| `ichigo/hooks.rs:339` | (setf (model-rim m) (ics-rim st)) restored | Rim | C: parry level | muted |

### Cosmetic `rnd01` reachable from a step's feedback or the frame, in call order

From `grep -n 'rnd01\|rnd-range' duel/lisp engine/lisp` (retired kits left out), each attributed to its function. The order within
a phase is the Lisp's call order there; Tasks 5-8 pin it against the key's per-frame `rng_state`.

| Phase (GAME-FRAME order) | Calls that draw | Where |
|---|---|---|
| SCREEN-FX-UPDATE, ONEHAND-FRAME, FLOW-UPDATE, GATE-UPDATE | none | |
| each step's immediate calls (pass 1) | a cinematic's step-mode look forms (`CineAt`): KE-Z-DUST, KE-Z-BLOOD, KE-ZH-CHIPS (ken.lisp:750, frames 36-54), SHAKE, VFX-SHOCKWAVE, VFX-AWAKEN-BURST, VFX-KEN-BK-BURST in Kenpachi's scripts; VFX-KONPAKU-SHATTER (cinema.lisp:183's helper, Ichigo's scripts at ichigo-look.lisp:681, 858), VFX-HIT; Ichigo's other forms in ichigo-look.lisp | ken.lisp:790, 799, 685; fx.lisp:27; vfx-stamps.lisp:457, 383, 346; vfx.lisp:554; ken-art.lisp:1575; ichigo-look.lisp (Task 8) |
| each step's FEEDBACK-SYSTEM (pass 2), event by event | `:absorbed`'s absorb-sound roll; VFX-HIT (and its shards); VFX-STEP-DUST; VFX-KIKON-RUSH; VFX-SHOCKWAVE; VFX-SMOKE-PUFFS; VFX-KONPAKU-SHATTER (`:konpaku` through hud.lisp PIPS-SHATTER); SHAKE (3 draws a call); STAGE-MARK's crack rays (STAGE-CRACK-ADD) and STAGE-DEBRIS; VFX-KEN-BK-BURST / VFX-KEN-TATEGOTO-CUT (`:ken-bk-burst`); `:drink`'s laugh (retired kit: unreachable). (`:parried`'s VFX-EMBER draws none.) | feedback.lisp:119 (201); vfx-stamps.lisp:346, 443, 395, 457, 435, 383; fx.lisp:27; stage.lisp:228, 289; ken-art.lisp:1575, 1563 |
| DRAW-SCENE (draw.lisp:325-345): STAGE-DRAW | the ash / feathers (ST-EVERY's emission) | stage.lisp:374 |
| DRAW-SCENE: DRAW-FIGHTER P1, then P2 | VFX-AURA (its N-OF emission counts and its particles, %GARB-AURA), scaled by last frame's `*aura-cap*`; Ichigo's aura base; VFX-CHARGE (a charged blade's tip, draw.lisp:239) | vfx.lisp:40, 242, 293; ichigo-look.lisp:219; vfx-ember.lisp:26 |
| DRAW-SCENE: HAZARD-DRAW | the hazards' looks: VFX-LINE-CUT (hazards.lisp:130), ICHIGO-ECHO-LOOK | vfx.lisp:419; ichigo-look.lisp:185 |
| DRAW-SCENE: CINE-DRAW | a script's DURING looks: VFX-AURA, VFX-LINE-CUT (ken.lisp:764, 908), Ichigo's cinematics (VFX-SKY-SPLIT draws none) | vfx.lisp:40, 293, 419; ichigo-look.lisp:689, 841, 905, 919 |
| DRAW-SCENE: STAMPS-DRAW, FX-UPDATE, FX-DRAW-PARTICLES, FX-RINGS-UPDATE | none found by the grep (they move what the calls above emitted) | |
| HUD-DRAW | AURA-CAP-UPDATE draws nothing, but sets `*aura-cap*`, which the next frame's VFX-AURA reads (ruling R4: Task 6 ports it at HUD-DRAW's place) | hud-screens.lisp:10 |

### Tests

- `rs/duel-sim/src/look.rs`:
  - `ecs_test_lisp_events`: tests/ecs-test.lisp lines 26-37, the 4 event-queue checks, on `LookQueue`;
  - `take_events_keeps_calls`.
- `rs/duel-sim/tests/look.rs`:
  - `queue_order_matches_sites`: cvc-ki-s1 run live from its S line to its end. Each step's kinds are checked at three steps against
    the calls read off the sources: tick 49 (P2's IC-J1 starts while P1 walks back), tick 165 (P1's pre-rolled KE-Z-AS1 hits:
    AnimSpeed, swing, RECOVERY-PACE, `:hit`, the launch clip, `:sp-break`), and tick 20918 (the K.O.: the last soul's cinematic ends
    into KO-CINE). The brief asked for 600 ticks; the K.O. comes at 20918, so the test runs the whole match.
  - `rollout_pushes_nothing`: 40 battle steps on a copy push looks as the live match and none with `in_rollout`.
- `rs/duel-look/tests/scene.rs`:
  - `rollout_leaves_scene_and_cosrng` (Review Focus 1): cvc-ki-s1 run twice, turbo off after its commands. The second run does an
    extra rollout of the oldest CPU job after every frame. The Scene, CosRng and state hash stay equal frame for frame for 3,000 frames,
    and the rollout's match queues nothing.
  - `frame_rate_120_and_30` (Review Focus 3): dt 1/60, 1/120 and 1/30. The Scene and state hash are equal at battle ticks 1, 300,
    600, 900 and 1200, read inside the step's sink, before the first cinematic.
- `rs/duel-tools/src/replay.rs` `look_queue_no_alloc`: the 17 cvc rows with a counting sink. 0 allocations in 293,640 battle steps;
  each row's sink saw 54,000-103,000 calls and 1,000-1,600 events.

### For later tasks

- **CINE-AT's interleaving (Task 8; superseded by ruling R9, §8).** `CineAt.pre` held the actors before the script ran; Task 8 runs
  the look forms inline after the sim forms instead (`CineLook`), and `CineAt` (no `pre`) is only START-CINE's queued frame 0.
- **The menus' idle clips** (`main.lisp:135`: ANIM-ADVANCE by RDT when not running, the fighters alive and not paused) are the drawer's
  (Task 10's page; M3b's menus).
- **Not queued:** debug PLACE's FX-CLEAR and its model flash / super reset (a debug helper); KEN-BANKAI-CINE's MODEL-BODY swap (a
  cinematic look form: Task 8).

## 5. The draw core (Task 5)

`rs/duel-look/src/draw/`: `frame.rs` (`FrameOut`, the environment `Env` with STAGE-ENV, the post globals `Post`, END-FRAME's `*rp*`,
SELECT-LIGHTS, FILL-FRAME-UNIFORMS / FILL-TOON-UNIFORMS), `queue.rs` (DRAW-MESH, ADD-POINT-LIGHT), `camera.rs` (CAMERA, UPDATE-CAMERA,
M4-LOOK-AT! / -PERSPECTIVE! / -MUL! / -INVERT!, DUEL-CAMERA's landscape half: BEHIND-CAMERA, PAIR-CAMERA, LANDSCAPE-LENS; SHAKE-UPDATE),
`stage.rs` (STAGE-DRAW's four draws and ST-ASH-FX's emission), `slow.rs` (SLOW-DRAW-BEGIN / -END), `mod.rs` (`draw_frame`, DRAW-SCENE,
FORM-GRADE, END-FRAME). `rs/duel-tools/src/draw.rs`: `duel-tools draw --check FILE.bin [--arrays …] [--frames A-B]` (its `--mask` left in Task 7, §7).

```sh
rs/target/release/duel-tools draw --check $ORACLE/draw/quiet-2394.bin --arrays fu,p,dq,fxa,fxb,ft,rng
```

**Result: bit-exact.** The 12 quiet scenes (121 keyed frames each) and `slowmo-2513` (240): 1,692 frames, 426,384 floats of `fu` / `p`
/ `dq`, largest |a − b| / max(1, |b|) = 0 in every array, with the `lights` and `fighters` lanes masked. 0 heap allocations: in every
whole frame after frame 0 that runs no command (the combat log turned off after the commands' frame, as the sim's 0-alloc gate), and in
`draw_frame` alone on every frame from 1 (command frames too: slowmo-2513's frame 30 is its first SLOW-DRAW).
`rs/duel-tools/tests/draw.rs`: `quiet_core_matches`, `slowmo_frames_match` (both fail without `$ORACLE`'s key).

### How a frame is drawn

The game loop is `flow::frame` → `duel_look::draw_frame(scene, m, rdt, out)` → `flow::frame_end`. `draw_frame` is GAME-FRAME after its
steps, then END-FRAME, in the Lisp's order:
1. `out.begin()` (BEGIN-FRAME's queues);
2. SLOW-DRAW-BEGIN;
3. FDT (0 while FX-FROZEN-P, else RDT × `*cine-time-scale*`), the fx clock;
4. DUEL-CAMERA on the drawn places, SHAKE-UPDATE (three cosmetic draws every 1/12 s, a shake running or not), UPDATE-CAMERA;
5. DRAW-SCENE unless turbo: STAGE-DRAW, FORM-GRADE (no cinematic), `[fighters: Task 7]`, `[hazards: Task 6]`, `duel_sim::cine::cine_draw(m)`
   (one call, where Task 8 adds the look hook: ruling R9), `[stamps, impact frames, particles, rings, the hit flash: Task 6]`;
6. `[HUD-DRAW: M3b; its AURA-CAP-UPDATE: Task 6, ruling R4]`, SLOW-DRAW-END;
7. END-FRAME: UPDATE-CAMERA, `*rp*`, SELECT-LIGHTS, FILL-FRAME-UNIFORMS.

`m` is `&mut` only for CINE-DRAW. The key's fixed inputs come from `SceneInputs` (the draw tool reads INDEX.json), the camera setting
from `Match.settings` (below); nothing in the draw code holds them.

### Findings and decisions

- **The battle start's camera snap reads the sim at the call, not at the sink.** BEGIN-BATTLE's `(duel-camera *p1* *p2* 0.0 :snap t)`
  runs inside a debug command's START-MATCH (cinematics skipped), and the same command's PLACE then moves the fighters (2394-2397,
  84000+). The anchor of the behind camera stays where the snap put it and springs after P1 from there: frames 0-30 of quiet-2394 show
  it. So `LookEvent::CameraSnap` carries what DUEL-CAMERA reads then: both places, both hurt radii, `*behind-yaw*`, `*view-x*` /
  `*view-z*`, `*view-behind*` (`duel-sim` change; the sim's results are unchanged). Checked by mutation: a sink that ignores the snap fails
  quiet-2394 and quiet-84004 at frame 0 (`fu[12]`); quiet-2500 still passes (no PLACE, so `*cam-cut*` snaps to the same places).
- **`LookEvent::Place`** (new): debug PLACE's looks, FX-CLEAR, `*punch-t*` 0, the models' flash / super 0. The sink applies `*punch-t*`;
  the rest are marked for Tasks 6 / 7.
- **`Match.settings`** (new, `duel_sim::state::Settings`), the one holder of `*one-hand*` (the draw tool sets it from the key's fixed
  input; `SceneInputs` has no `one_hand`): the page's SETTINGS line (`*setting-ix*`, each row's default from tuning.json
  `*SETTINGS*`: `(0 1 2 2 0 0 0 0 0 0 5)`) and `*one-hand*`. START-MATCH's SET-CAM-BEHIND is now its rule, `(and (or *cam-behind*
  *one-hand*) (vs-cpu-p) t)` with `*cam-behind*` = APPLY-SETTINGS' `(zerop (setting :camera))` (M2_NOTES §12's carry). The page (M3b) sets
  them; the tools keep the defaults, which give the old hard-wired value.
- **Scene commands ported** (`duel-sim/src/debug.rs`): 2500-2503 (DEBUG-VS-IDLE), 2394-2397 (STRING-TEST), 2513 (SLOWMO
  `*core-clash-slowmo-scale*` 3 s), 84000 / 84001 / 84004 / 84005 (KEN-CORE-DEBUG's scene). ENSURE-BATTLE takes its `:cpu` argument (a trace
  records only T; the scenes pass NIL: VS CPU, the brains off).
- **SLOW-DRAW without writing the match.** The Lisp writes the drawn places into the fighters' and hazards' slots and puts them back after
  the HUD. Here they are an overlay (`SlowDraw.at`) read through `Scene::drawn_pos` / `drawn_yaw`; the clips are the Scene's and are moved
  and put back as in the Lisp. DUEL-CAMERA reads the drawn places, as GAME-FRAME's order gives.
- **`look_unported`** is `Scene.unported`: the first look path not ported yet (the draw tool exits 3 on it, the page will show it). Set by
  the portrait camera (Task 7), a cinematic's camera while `m.cine` runs (Task 8), the menus' camera (M3b) and a `:spot` form grade (M4).
- **The cosmetic RNG is not compared yet.** Every key frame draws the shake's and the ash's numbers (ported) and the fighters' (VFX-AURA's
  N-OF, Ichigo's aura: Tasks 6 / 7) in between. Frame 0 of quiet-2500 draws 4 in the key and 3 here (the shake's): the fourth is the
  fighters'. `--arrays rng` is there for Task 6's `cosrng_draw_order`.
- **`duel_sim::cl::musl_powf` is public** (SRGB->LIN's `powf(x, 2.2f)`, %POW2), and `duel_sim::math::f_tan` is new (M4-PERSPECTIVE!'s tanf):
  duel-look calls no math crate directly.

### The masks (rulings R3; all gone since Task 7, §7)

`--mask lights` leaves out `fu` 70..=135 (the light count, the per-pixel count, `*lp*`, `*lc*`: vfx.lisp's ADD-POINT-LIGHT, Task 6). The
dq lanes are chosen by the mesh's registry path (tables.json `mesh_ids`, equal to the key's meshes.json), on both sides, then the rest is
compared record by record in order:
- `fighters`: `*BODIES*…`, `*WEAPONS*…`, `*SHADOW-MESH*` (DRAW-FIGHTER, Task 7). Ichigo's look bodies (the clones, ICHIGO-ECHO-LOOK, his
  cinematic body) draw the same meshes, so they fall in this lane: Task 6 cannot check their records until Task 7 removes it.
- `chips`: `*ST-ROCKS*…` (ST-CHIPS, Task 6).

No dq lane exists for the cracks and marks (they draw only into `ft`) nor for the hazards (they draw no mesh). The controller's list named
those lanes; there is nothing to mask in `dq` for them.

### For later tasks

- **Review Focus 2 is only half covered here.** In slowmo-2513 both fighters stand idle, so the drawn places equal the sim's and the camera
  cannot show SLOW-DRAW. Measured: with SLOW-DRAW-BEGIN disabled, slowmo-2513 still passes `--mask lights,fighters`. Its two halves are
  proven later, each by mutation:
  - the clip-time rewind (the drawn clip one sim frame's share back, the blend): Task 7's unmasked slowmo-2513 run (idle fighters still
    play their stance clips);
  - the position / yaw interpolation (`slow.rs` SLOW-MIX) and `Scene::drawn_pos` feeding the camera: not provable on slowmo-2513 (with
    nothing moving SLOW-MIX gives the same place for any weight); Task 8 proves it on a keyed slowmo window with motion, a core-clash
    slow motion inside battle-2005 / 2006.
  - Task 6's hazards (and Task 7's fighters) must read `Scene::drawn_pos` / `drawn_yaw`, never `fighter::pos_of`.
- Task 6: ST-ASH-FX computes each flake's FX-EMIT arguments (`stage.rs`, marked) for the pool; SHAKE (the request) writes
  `CamState.shake`; `*screen-fx*` is `DrawState.screen_fx` (FX-FROZEN-P reads [6], FORM-GRADE [0]); LIGHTS-FLUSH and the cracks, marks
  and chips go where `draw_scene` marks them; then drop `--mask lights,chips`.
- Task 7: DRAW-FIGHTER at its mark in `draw_scene`, reading `drawn_pos` / `drawn_yaw`; the portrait camera (%PORTRAIT-CAMERA needs
  `*band*`, DECK-UPDATE's) in `Scene::duel_camera`.
- (done, §8) Task 8: the cinematic camera branch of DUEL-CAMERA (with %KEEP-SUBJECT / %PORTRAIT-DOLLY and the dutch roll), CINE-HELD-P in
  FX-FROZEN-P (no Rust cinematic holds yet), CINE-END's camera fov / up and STAGE-ENV, the card beat hiding the stage.

## 6. The FX (Task 6)

`rs/duel-look/src/fx/`:
- `mod.rs`: `FxState` (in `Scene.fx`), `Ctx` (a frame's drawing: the arrays, the camera, `CosRng`, the state, the fx clock) and `Em`
  (its starting half: feedback's calls inside a step), WITH-FX-VERTS / STREAM-ROOM-P (`Ctx::verts`: a full batch drops the whole shape
  and counts `FrameOut.fx_dropped`), engine/lisp/fx.lisp's particle pool (%FX-SLOT, FX-EMIT, FX-UPDATE, FX-DRAW-PARTICLES), rings
  (FX-RING, FX-RINGS-UPDATE) and FX-CLEAR;
- `shapes.rs`: fx-shapes.lisp (TOON-A, %H01 / HASH01, DRAWING-NO, FLOW-PH / FLOW01, SAGE, %TOWARD-EYE, %TRING, FX-RIBBON / TOON-RIBBON /
  %TONGUE, TOON-GROUND-SEG, %SECTOR-VERTS, FX-STAR, FX-SHARD, FX-CRESCENT, FX-DISC, FX-WALL) and render.lisp FX-LINE;
- `vfx.rs`: vfx.lisp LIGHTS-FLUSH / FLASH-LIGHT / N-OF / %BRUSH-AURA / %REIATSU-AURA / %KIKON-AURA / VFX-AURA / VFX-BREAKER-RING,
  draw.lisp's aura tail of DRAW-FIGHTER (`fighter_auras`: DRAW-AURA, ONI-AURA-K, BODY-LIFT; RUSH-LIFT is 0 in scope), ichigo-look.lisp
  ICHIGO-AURA-BASE, hud-screens.lisp AURA-CAP-UPDATE, fx.lisp's trails and vfx.lisp VFX-SMEAR (looks 0-2);
- `stamps.rs`: vfx-stamps.lisp (STAMP, STAMPS-DRAW, FX-ENVELOPE, %ST-HIT / -GUARD / -GUARD-BREAK / -GUARD-CRUSH / -CLASH / -HOHO /
  -BURST / -KONPAKU / -RING / -GASH, the VFX-* calls) and vfx-ember.lisp (%ST-EMBER, VFX-EMBER, VFX-CHARGE);
- `crack.rs`: stage.lisp 218-356 (STAGE-CRACK-ADD, ST-DRAW-CRACKS, STAGE-MARK, ST-DRAW-MARKS, STAGE-DEBRIS, ST-CHIPS);
- `feedback.rs`: feedback.lisp FEEDBACK-SYSTEM (`Scene::feedback`, the sink's second pass), SHOW-HIT, GROUND-SCAR, hud.lisp
  PIPS-SHATTER, ken-art.lisp VFX-KEN-BK-BURST / VFX-KEN-TATEGOTO-CUT;
- `screen.rs`: cinema.lisp IMPACT-FRAME (`*impact-presets*` from tuning.json), FOCUS-LINES, BACK-RIM, SCREEN-FX-UPDATE / -CLEAR, and
  fx.lisp SHAKE;
- `hazard.rs`: hazards.lisp HAZARD-DRAW, vfx.lisp VFX-LINE-CUT :meteor / :crack and %CRACK, ken-art.lisp KEN-CHIGIRI-LOOK / -CUTS,
  KEN-TATEGOTO-LOOK, KEN-TATEGOTO-WAVE(-AT), ichigo-look.lisp VFX-IC-CRESCENT, IC-WAVE-K and the GETSUGA / JUJI / FORM / KX / BURST /
  ZANZO / RENZAN looks; feedback.rs also has ken.lisp KEN-BK-HIT-FX (the Bankai kits' :hit-fx, two sounds).

**Result: bit-exact.** The 12 quiet scenes (11 with `fu,p,dq,fxa,fxb,ft,rng`, quiet-2395 with `fu,p,dq`) and `slowmo-2513`
(`fu,p,dq,fxa,fxb,ft,rng`), `--mask fighters` only: largest |a − b| / max(1, |b|) = 0 in every array; the cosmetic RNG's state equals the
key's on all 1,571 frames it is checked on (11 quiet scenes and slowmo-2513). 0 heap allocations a frame. `rs/duel-tools/tests/draw.rs` `quiet_fx_matches`; the `lights`
and `chips` masks are gone from every test (the tool kept `--mask` for `fighters` until Task 7 removed it, §7).

### What the quiet key checks, and what it cannot

- `fxa` is the falling ash (ST-ASH-FX's feathers through the pool), `ft` Kenpachi's aura (the brush tongues and their flecks through the
  pool; Ichigo's Shikai aura draws nothing), `fu[70]` the hit flash's light (LIGHTS-FLUSH: `*flash-light*` starts zeroed at fx clock 0,
  so frames 0-8 carry a black light) plus the :oni aura's light in 84004 / 84005. No chips, stamps or rings appear in a quiet scene.
- **AURA-CAP-UPDATE (ruling R4)** runs in `draw_frame` at HUD-DRAW's place (unless turbo, after DRAW-SCENE, before SLOW-DRAW-END: it
  reads the drawn places). Proven by mutation: with it off, quiet-2394 (fighters 2.2 m apart) fails at frame 5 (`ft[8]`, the reiatsu's
  presence lane); 84004 (the :oni kind uses the uncapped K) and 2500 (far apart) still pass.
- **R11 measured:** the cosmetic RNG matches the key on every quiet scene but 2395 already, because no fighter draw in those scenes
  draws `rnd01` (Ichigo's Shikai :draw hook and every DRAW-FIGHTER step before the auras draw none when idle). The quiet test checks
  `rng`; Task 7 keeps it and adds 2395.
- **The unverified half.** Feedback, the stamps, VFX-EMBER / -CHARGE, the cracks / marks / chips, the hazards' looks, VFX-LINE-CUT and
  VFX-SMEAR get no key check before Task 8's battle scenes (their intro cinematic stops at the cinematic camera, Task 8). They are ported
  from the source line by line, in the Lisp's evaluation order for every `rnd01` (each macro argument bound in turn). Two runnable
  checks on the 17 cvc gate rows (whole matches):
  - `replay.rs` `scene_sink_no_alloc`: the real `Scene` as the sink (12,840-21,840 battle steps a row, 1,000-1,600 sound requests): no
    panic, 0 allocations;
  - `replay.rs` `scene_draw_no_alloc`: the page's loop (`flow::frame`, `draw_frame`, `flow::frame_end`), turbo off, so
    STAMPS-DRAW, HAZARD-DRAW, the line cuts, chips, rings and every particle kind draw (13,059-22,077 battle frames a row, 2-3.5e8 fx
    floats, none dropped): no panic, 0 allocations. It caught one: matching a look's name through `to_ascii_uppercase` allocated in
    every frame with an Ichigo hazard (now `eq_ignore_ascii_case` against a fixed table).

### Decisions and findings

- **`LookSink::frame_begin(m, rdt)`** (new, default no-op; ruling R12): GAME-FRAME's SCREEN-FX-UPDATE runs before FLOW-UPDATE with this
  frame's RDT, and the debug commands arrive between the Lisp's frames, so `flow::frame` calls it after its commands and before
  FLOW-UPDATE and the steps (a pause a command sets already holds: 0 s). `Scene`'s impl clears last frame's `sounds`, then runs
  SCREEN-FX-UPDATE. The loop stays three calls: `flow::frame`, `draw_frame`, `flow::frame_end`. (Fix round 1: it was a free function the
  loop called before `flow::frame`, so it ran before the commands.)
- **`Scene.sounds: Vec<SoundReq>`** (At / Play / HumStart / HumStop / SilenceEnd), bounded at 256, reserved once; readable after the
  draw (M3b plays it), cleared at the next frame's start (`frame_begin`). `Scene.hums` is feedback.lisp `*hums*` (a Breaker hum runs, per side).
- **`Em`, not a FrameOut in the sink.** FEEDBACK-SYSTEM runs inside the step, where the Rust sink has no `FrameOut` (the Lisp's frame
  arrays exist then: BEGIN-FRAME precedes the steps). No feedback call writes a frame array (they start stamps, particles, the hit light,
  marks, the shake), so the sink draws through `Em`. Task 8's step-mode cinematic looks may need the frame's arrays during the step.
- **Kit look names.** A hazard's keyword look is `Sym(":METEOR")`, a look function `Sym("KEN-CHIGIRI-LOOK")`; a kit's :aura is
  `reiatsu` / `oni` (keywords, lower case) or a function name (`ICHIGO-AURA-BASE`).
- **Knobs from data:** `*fire-density*`, `*reiatsu-glass*`, `*oni-k-attack*`, `*impact-presets*`, `*chigiri-cuts*` / `-burst*` /
  `-quake*` / `-still-frames*`, `*tategoto-cut*`, `*tategoto-wave-len*` (all already in tuning.json; no re-extraction, the checksum pin
  unchanged). `*shake-mult*` / `*shake-hz*` were Task 5's.
- **`f_atan2`** is `duel_sim::math::yaw_to(-y, -x)` (atan2f(-a, -b)): duel-look calls no math crate, and duel-sim is unchanged.

### Left to later tasks (`// task N` in the code)

- **Task 7 (the fighters' draw; done, §7):** DRAW-FIGHTER before its auras (body, weapon, hooks, VFX-CHARGE's call, the trails' pushes and
  VFX-SMEAR's call); KESSA's aura (ICHIGO-AURA-KESSA reads IC-JOINT: posed joints; a no-op marked at its call site, so quiet-2395 checks `fu,p,dq` only: ruling R13); the model looks
  feedback starts (SMEAR, HOLD-POSE, MODEL-SUPER / -FLASH, FACE-BEAT); START-GHOST and DRAW-GHOST (the Hoho's, a flash step's,
  ICHIGO-AURA-BASE's afterimages: reaching one sets `Scene.unported`); the hazard looks that read posed joints (ICHIGO-CLONE-LOOK and
  ICHIGO-ECHO-LOOK through IC-GHOST, ICHIGO-FLARE-LOOK through IC-JOINT: reaching one sets `unported`); DRAW-FIGHTER's per-frame
  STOP-HUM.
- **Task 8 (cinematics, canvas; done, §8):** ANNOUNCE's words, FOCUS-LINES' centre on a world point (WORLD-TO-SCREEN: the centre stays -1),
  `*ui-flash*`'s drawing (stored in `FxState.ui_flash`), `*cine-grade*` coming back in SCREEN-FX-UPDATE, CINE-HELD-P in `Scene::frame_begin`,
  CINE-END's SCREEN-FX-CLEAR (`fx::screen::screen_fx_clear`, its only caller; STAMPS-CLEAR has none outside debug),
  `*aura-off*`, DRAW-SCALE-OF, the cinematic step forms' FX (KE-Z-DUST etc.), `*card-only*`.
- **M3b:** WEBHUD-REFUSED! / WEBHUD-BREAK! (the HUD's cues), playing `Scene.sounds`.
- **M4:** Yamamoto's / Hisagi's aura kinds (:hellfire, :garb), stamp kinds (17-22, 25-30), line cuts (:enjo / :kyoku / :south /
  :kyokko), smear looks 3-5, a :hit-fx other than KEN-BK-HIT-FX (Hisagi's), any :armored-fx (Yamamoto's): each sets `unported`.

## 7. The fighters (Task 7)

`rs/duel-look/src/draw/`:
- `fighter.rs`: draw.lisp DRAW-FIGHTER and what it calls:
  - the pose, the held pose, BEAT-POSE!, POSE-FK!, the kit's :pose hook;
  - GRIP-STEP / GRIP-LEFT! / GRIP-TARGET-OK-P with %ROT-TO! / %ROT-COLS!;
  - MOVE-BEATS, SMEAR-JOINTS!, START-GHOST / DRAW-GHOST, FACE-OF / FACE-ACCENT / VFX-FACE-ACCENT;
  - body.lisp DRAW-BODY / DRAW-WEAPON / DRAW-SHADOW / DRAW-PLANTED-WEAPON and engine/lisp/body.lisp DRAW-PARTS;
  - the weapon's VFX-CHARGE call, trail and VFX-SMEAR;
  - the aura tail with DRAW-AURA / ONI-AURA-K (moved here from `fx/vfx.rs`), and the per-frame STOP-HUM;
  - the feedback's model looks: HOLD-POSE, SMEAR, FACE-BEAT.
- `ken.rs`: ken-look.lisp KEN-DRAW (the sword wind, %KE-STREAKS / -CRESCENT / -DUST-LINE, KEN-SPECIAL-LOOK's tornado and meteor).
- `ichigo.rs`:
  - ICHIGO-CLOAK-POSE with hem-spring.lisp %YA-HEM-POSE / -STEP;
  - ICHIGO-DRAW: the edge and ground contact, the charged blades and %IC-BLACK-FLAME, the chain lash and rest, the red wisps;
  - ICHIGO-AURA-BASE / -KESSA, VFX-IC-CHAIN, tip-track.lisp's %IC-FRAME / -HELD-TIP / -TRACK / -FAR;
  - the hazards' posed-body looks: ICHIGO-CLONE-LOOK / -ECHO-LOOK (IC-GHOST, IC-MIST) and ICHIGO-FLARE-LOOK.
- `camera.rs`: %PORTRAIT-CAMERA, and DECK-UPDATE's `*band*` / `*pcam*`[1] as a pure function of the viewport (`band`).

**Result: bit-exact.** Every array but `ui` / `hb` / `hk` matches, with no mask. That is `fu,p,dq,fxa,fxb,ft` plus the cosmetic RNG's state on every keyed frame:
- the 12 quiet scenes (121 keyed frames each);
- `slowmo-2513` (240 frames);
- the forms scenes: `forms-ken-p2` (13), `forms-ken-p1` (10), `forms-ichigo` (7);
- `portrait-2501` (61).

The largest |a − b| / max(1, |b|) is 0 in every array. `rs/duel-tools/tests/draw.rs` has `quiet_full_matches`, `slowmo_frames_match`, `forms_draw_matches`
and `portrait_scene_matches`. The draw tool's `--mask` is gone; no mask remains anywhere. There are 0 heap allocations a frame.

### Decisions and findings

- **State where the Lisp keeps it.**
  - Per spawn, in `Model` (the `Model` event resets them): the joints, flash, super, hold, smear and its direction, the ghost and its
    age, face, face-t, beat, last-sf, face-was, LOOKS, and MAKE-BLADE's trail and smear.
  - Per side, in `Scene.fl` (never reset at a spawn, as the Lisp's specials): `*ke-look*`, `*ic-look*`, `*ic-charged*`, the charge trails and
    smears, the clone anims and joints.
  - `*toon-body*`'s feet lane (`FighterLooks.toon_y`) is a global the next draw reads: DRAW-GHOST's ink pass and IC-GHOST read whatever
    the last DRAW-BODY left there.
- **`*grip-clips*` is extracted**, as tables.json `grip_clips`.
  - It is a `defvar` that the art files fill with PUSHNEW, so it was in neither tuning.json nor tables.json.
  - `tools/port/extract/extract.lisp` now has `("grip_clips" . *grip-clips*)`. The table is strings only, so the float checksum stays
    `3ddcd77c9a34edf5`. Tables went from 28 to 29. Every other file re-extracted byte-identical, and the census passes.
  - A clip is matched by identity (the resolved `&Clip`), as CLIP-NAME of the playing clip.
- **Kit aura functions dispatch in DRAW-AURA.** VFX-AURA funcalls a kit's aura with `(x y z h ka dt)`, where KA is the capped presence
  (`fx::vfx::aura_ka`). It does this once per crossfade half, so twice while an aura changes. ICHIGO-AURA-BASE / -KESSA now run inside
  `draw_aura`'s dispatch, with the models and the drawn places. Task 6 had the base aura outside the crossfade, which was wrong during a
  form change. ICHIGO-AT matches the *drawn* feet (SLOW-DRAW writes them into the Lisp's slots).
- **Every place read at draw time is the drawn one** (`Sides`, from `Scene::drawn_pos` / `drawn_yaw`): DRAW-FIGHTER, KEN-DRAW's wind
  and special looks, ICHIGO-DRAW's hit look, the chains, the charged blades' facing, ICHIGO-AT, and START-GHOST from the draw.
  START-GHOST from the feedback reads the sim's place, as the step does.
- **Move names are the data's lower case** (`ke-charge`, `ke-s-sp1`, `ic-soga`). Task 6's ICHIGO-AURA-BASE compared `"IC-SOGA"` and
  never matched. It was fixed when it moved here (commit 2fcae884).
- **The mirror P2** draws `Match.mirror_rim` and tables.json `mirror_tint` (quiet-2502 / 2503). The parry rim is PARRY-RIM's
  `(rim-vec #xFFFFFF (* 0.45 i))` = 0.45 i, since `(expt 1.0 2.2)` = 1. The super rim, the clones' rims and the mist tint are RIM-VEC /
  HEXC of the files' load-time constants (`fighter::rim_vec`, musl powf).
- **`*weapon-m*`** is M4-EULER! of `(deg 90)` (90 × the f32 of pi / 180) and `(f32 pi)`: the dq records match bit for bit.
- **The portrait camera's band** is DECK-UPDATE's arithmetic: UI-SCALE with ONEHAND-FRAME's `*ui-min-css*` 11 on a portrait
  window, PORTRAIT-HUD-BOTTOM / PORTRAIT-P1-TOP (29 px × scale), and `*pt-center-lift*`. It reads `SceneInputs`, which gains `safe_top`
  / `safe_bottom` (the page's safe-area insets: 0 on the recorder, INDEX `fixed_inputs.page`). The camera's FOV is written only on a
  change over 0.002, and its shift only when it differs, as the Lisp's boxed slots.
- **Not reachable in scope, ported as written:**
  - RUSH-LIFT and BODY-LIFT: no in-scope move has `:lift`, and every in-scope kit's `:lift` is 0.
  - A move's `:aura-k`: no move has one, and moves.json's params lack the key.
  - DRAW-SCALE-OF and `*aura-off*`: `Scene.cine`, which Task 8 writes.
  - A planted move: none has `:planted`.
  - A Yamamoto / Hisagi fighter, any other kit's :pose / :draw / :planted / :body-alpha / :charge hook, and an opponent's
    :victim-look: these give `look_unported`.
- **Debug 2505 / 2508** are ported in `duel-sim/src/debug.rs` (LHUD-SCENE with the default picks, LHUD-P2-FORM). This is a duel-sim
  change; the sim gates stay green.

### SLOW-DRAW's clip-time half (Review Focus 2), proved by mutation

With `slow::begin`'s clip-time / blend rewind removed, `slowmo-2513` fails at its first slowed frame:
`frame 30 dq[141]: 0.916494 key 0.9166415` (record 4, a body part's translation). With the rewind it passes every frame 0-239. The
position / yaw half stays Task 8's (§5).

### Coverage

- **Not float-compared by any keyed scene** (checked against every `.bin`'s drawn-mesh list):
  - Kenpachi's Nomi body (`kenpachi-nomi`, 52 meshes): no kit uses it in scope.
  - The Oni body's crack glows: 13 of `kenpachi-oni`'s 15 extras, among them the four crack glows with a `:rot`. The Bankai kits'
    `:hide` lists `crack-1`…`crack-4`, so DRAW-PARTS skips them.
  - The forms scenes draw 39 Oni meshes, but not those.
  - Not re-keyed (the brief); M4 / a later key covers them.
- **Not reached by any keyed scene** (both fighters idle): the grip (no stance clip is a grip clip), the beat, the smear, the ghost,
  the face accent, the hooks' move looks.
- **The cvc rows' `scene_draw_no_alloc`** runs the page's loop on 17 whole matches and reaches most of these. It found no panic and
  0 allocations. It now fails on any `look_unported` but a cinematic's camera (Task 8; done, §8: now only the menus' camera) and the menus'
  camera after the match (M3b).
  A temporary counter probe, since removed, counted the calls over the 17 rows:

  | Path | Calls |
  |---|---|
  | GRIP-LEFT! | 12,786 |
  | the face accent | 109,317 |
  | DRAW-GHOST live | 2,313 |
  | START-GHOST | 166 |
  | SMEAR-JOINTS! | 7,765 |
  | KEN-DRAW's wind | 32,107 |
  | DAISHARIN's tornado | 2,596 |
  | the charged blades | 9,563 |
  | the black flame | 6,635 |
  | ICHIGO-CLONE-LOOK | 25,077 |
  | the red wisps | 186,222 |
  | the hem spring | 120,266 |

  These were never reached, each for a measured reason (a second temporary probe listed the 104 moves that reach their main phase
  over the 17 rows):
  - INSEKI-GIRI's tail and impact: `ke-s-sp2` never reaches its main phase (DAISHARIN, `ke-s-sp1`, does);
  - ICHIGO-DRAW's crescent edge: none of the 16 moves `*ic-edge-moves*` lists reaches its main phase (the CPUs play the core moves
    `ic-j*`, `ic-n*`, `ic-as*`, `ic-k-j*` ...);
  - VFX-CHARGE: the only in-scope move with a `hold` is `ke-stance`, which has the `stance` flag, so no in-scope move reaches it;
  - MOVE-BEATS' afterimage: `ke-charge` never reaches its main phase (the 166 START-GHOST calls are the Hohos' and the flash steps');
  - the echo and flare looks, the beat, a planted weapon (no in-scope move is `:planted`).

  Task 8's battle keys check the reached ones' floats.

## 8. The cinematics, the canvas words, the full battles (Task 8)

`rs/duel-look/src/cine/` (`mod.rs`: the director's looks, the shot helpers, the cinematic camera, the generic scripts; `ken.rs`,
`ichigo.rs`: the kits' scripts and their looks), `rs/duel-look/src/canvas.rs` (the canvas part of HUD-DRAW, brush.lisp's glyphs and
captions, the big words, fx-shapes.lisp's UI punctuation, ui.lisp's shapes); `rs/duel-sim/src/cine.rs` / `debug.rs` / `look.rs`
(the hook, the hold, the scene commands).

**Result: bit-exact.** All 41 scenes of the key match on every array but `hb` / `hk` (`fu,p,dq,fxa,fxb,ui,ft` and the cosmetic RNG's
state on every keyed frame), with no mask and 0 heap allocations a frame, bit for bit (`duel-tools draw --exact`) but one array: the 20
cinematic scenes and `cine-84094-portrait`, both battles (`battle-2005`, `battle-2006`: 491 and 552 keyed frames, the hitstop window
422-434 every frame) and `portrait-2005`, and again the quiet, slowmo, forms and portrait scenes, now with `ui`. The one: cine-ic-kessa-getsuga's
`fxa` (the black C, VFX-IC-C-CUT) is within 2.05e-7 (first at frame 110, `fxa[14743]` 0.04981986 vs 0.049819864): its band goes through
`(sin (* pi u))`, and the native image's `pi` is an 80-bit long-float (sinl, powl), which the port computes in doubles: as the wasm page
does, whose `pi` is a double (Task 9 fix round 3, DIVERGENCES §3: the gap is the native key's, the port agrees with wasm) (the accepted
pi deviation, BEVY_PORT §5.3; the tolerance holds it). Tests:
`rs/duel-tools/tests/draw.rs` `cines_match`, `cine_portrait_matches`, `battles_match` (and the earlier four with `ui` added).

### The cinematics' look hook (ruling R9)

- **`duel_sim::look::CineLook`** (`forms(m, name, cf, a, v, step)`, default nothing; `LookSink: CineLook`). CINE-STEP calls it right
  after the step-mode script's sim forms of frame CF (`cine_step(m, look)`, from `sim_core` with the step's sink; `sim_step_lean` and the
  headless path pass `NoLook`); CINE-DRAW right after its draw-mode sim forms (`cine_draw(m, look)`; `draw_frame` passes a
  `cine::CineDraw { sc, out, dt }`, which draws the DURING forms into the frame). `Scene`'s step-mode `forms` first applies the step's
  queued immediate calls (`Scene::apply_calls`, the amended R9), then the AT forms.
- **One call after the sim forms is the Lisp's order.** In every in-scope script (the 4 generic, 9 Kenpachi, 8 Ichigo), checked form by
  form, the forms that move an actor (FACE-EACH-OTHER, CINE-PLACE, KE-KK-LINE / -AT / -YAW, 血鎖's reel-in) come before the look forms of
  the same AT / DURING / `(when step-p …)` call that read the actors; a look form before them (a CARD, a CAPTION-EXIT, a CINE-CLIP) reads
  no place. So no script's sim forms are replayed on a copy (the M3A_NOTES §4 bullet that planned one is superseded).
- **START-CINE's frame 0 is queued** (`LookEvent::CineAt { name, cf: 0, a, v }`, pushed after the script's frame-0 sim forms; it lost its
  `pre` field): START-CINE runs inside a debug command or a system (HIT-SYSTEM's SETTLE-SOULS, an awakening, TIME-UP, MATCH-OVER inside
  END-CINE's AFTER) where no sink is reachable without threading one through every system. The sink runs the same `Scene::cine_at` at that
  place in the queue, reading the live match. It sees what the Lisp's inline forms saw: after START-CINE in a system nothing moves the
  actors in the rest of the step (`m.cine` set: HAZARD-, HIT-, GAUGE- and MATCH-SYSTEM are skipped; CORE-XCH-STEP moves no place; the
  other fighter's FIGHTER-SYSTEM step is a halted `:cine` state); a debug command's START-CINE is its last form but the hold. The queue
  keeps the order of the calls around it (END-CINE's `CineStop` / `CineEndLook` before a K.O.'s KO-CINE frame 0).
- **The commands' calls before SCREEN-FX-UPDATE.** engine/lisp/app.lisp RUN-FRAME runs the debug commands after BEGIN-FRAME and before
  GAME-FRAME, so a cinematic a command starts has made its frame-0 calls (a FREEZE, a HOLD-POSE) before SCREEN-FX-UPDATE runs them down.
  `LookSink::frame_begin` now takes `&mut Match` and `Scene` applies the queued calls first (found by cine-soul-break: its 6-frame freeze
  lasted one frame too long; `duel-sim` change, the gates rerun).
- **`FrameOut` in the sink (Task 6's carry): not needed.** No step-mode form writes a frame array: they start particles, stamps, rings,
  stage marks and debris, a shake, set the grade, the environment, a caption, the UI flash, and store a splash's or the focus lines'
  screen point (WORLD-TO-SCREEN on the camera as it stands: END-FRAME's update, which BEGIN-FRAME's UPDATE-CAMERA repeats unchanged). The
  sink draws through `Em`.

### The hold and the scene commands (ruling R7)

- `Cine.hold` and `Match.cine_hold` (`*cine-hold*`): START-CINE takes the script's `:hold` while `cine_hold` (`CineName::hold_frame`), and
  `skip_cines` ends a cinematic only when not held; CINE-STEP stands still at or past the hold (no frame, no script, no actor step, no
  end); DEBUG-COMMAND clears `cine_hold` unless CINE-STILL-COMMAND-P (2200-2299, 10000-19999, 35000-35999). The draw side: CINE-HELD-P
  in FX-FROZEN-P and in `frame_begin`'s SCREEN-FX-UPDATE dt.
- `debug.rs`: FORCE-CINE (2200+k) and CINE-AT (10000 + 1000 k + f; 35000 + f for k 9) for `*cine-names*` 1 6 7 8 9 (a retired kit's k:
  `unported!`); ICHIGO-CINE-AT (75000 + 80 i + k at frame 3k; 86110 the 超速連斬 at 40; `IcCine::Haste` added, its sim forms FACE-EACH-OTHER
  2.6 / 3.2); KEN-CORE-DEBUG's played Kikons 84094 / 84095 (on 84001), 84096 / 84097 (on 84004 / 84005, 4 souls, CINE-STAGE), 84006-84008
  (on 84000, 3 souls, CINE-STAGE); 2000+seed: START-CVC's two `sim-rnd01` draws over PLAYABLE-ROSTER (`*roster*` less `*retired*`: seed 5
  Ichigo vs Kenpachi, seed 6 Ichigo vs Ichigo).

### The looks

- **The cinematic camera** (`Scene::cine_camera`, DUEL-CAMERA's `*cine-cam*` branch): the shot's eye and target, %PORTRAIT-DOLLY on a
  tall window (the lens at least `*pt-cine-fov*`, the dolly-back held in the arena ring; a close-up keeps the script's lens), %KEEP-SUBJECT
  (the SHOT-ON subject's posed pelvis, its last drawn joints), `*cam-cut*`, %ROLL-UP's dutch up vector, the punch-in's clock. It runs
  while `CineLooks.cam`, so a cinematic frame before its first shot (soul break's 0-5, a Kikon's beat 0) keeps the duel camera, as the
  Lisp's `*cine-cam*` test does. `Scene.unported_camera` keeps only the menus' camera (M3b); `scene_draw_no_alloc` now allows nothing else.
- **The director's looks** (START-CINE, CINE-BEGIN, END-CINE, CINE-END): `CineLooks` holds the shot, `*dutch*`, `*lens-fov*`,
  `*cine-close*`, `*cine-subject*`, `*card*` / `*card-only*`, `*cine-grade*` (SCREEN-FX-UPDATE brings it back after an impact frame),
  `*caption*` / `*caption-out*`, `*splash-args*`, `*aura-off*` and CINE-SCALE. A card skips STAGE-DRAW and draws only its actor; CINE-END
  restores the lens, the up vector, STAGE-ENV and clears the screen punctuation. FORM-GRADE's :spot path is ported (no in-scope kit has
  one: ported, unverified). SILHOUETTE-BLACK is called by no in-scope script (not ported).
- **Model slots a cinematic sets:** the body (the Bankai's kneel in the base body), the weapon, `*aura-off*`, and IC-KESSA-CINE's HIDE-SETs
  that are no kit's list (`Model.hide_x`, cleared by REFRESH-LOOK).
- **Floats that go through the long-float pi** (as Task 7's IC-MIST): VFX-IC-CHAIN-BIND's arc `(* 0.9 (sin (* pi s)) (- 1.0 s))` and
  VFX-IC-C-CUT's band thickness `(expt (max 0.0 (sin (* pi u))) 0.6)`, and every C point built on it, are doubles rounded once by FX-LINE's
  F32; where the sine is 0 MAX keeps its single 0.0 and the point is single arithmetic (`duel_sim::math::pow_d` added). CL MOD of singles
  is ECL's single/single `p·n − q·n` (q = floorf p), which the native libecl's x87 code evaluates exactly before one rounding, so it
  equals `(p − q) · y` in singles (`duel_sim::cl::mod_f32`; the fixnum-by-single branch's own form): the impact splash's seed, KEN-FOREST's petals, the caption splash's seed.
- **The canvas** (`Scene::hud_canvas`, after AURA-CAP-UPDATE at HUD-DRAW's place): the UI flash (faded by CINE-DT: HUD-DT), the impact
  splash and the focus lines (a clash's on its world point now), the letterbox and brush title of a cinematic whose 2D layer is the canvas's
  (not the intro's, the K.O.'s or TIME's: WEBHUD-CINE-P), an ended title slicing out unless it was such a cinematic's (`Bcap.web`, the
  port of `*web-caption*`, which WEBHUD-SYNC sets to the running web cinematic's caption), the battle's world overlays (HUD-RUSH-LINES;
  HUD-WORLD's red soul flame, drawn into `ft`; PERFECT HINT's HOHO! for a human with the setting on is `unported`: the settings are M3b),
  the big words (ANNOUNCE from the feedback, DRAW-WORDS; `*panel-box*` is all zeros since the canvas HUD left). The cinematics' own UI
  looks (KEN-FOREST, KE-GLASS, KE-RIFT-BAND, VFX-SKY-SPLIT) draw from CINE-DRAW, before it, as in the Lisp. Glyphs: BRUSH-INIT's EAR-CLIP
  of glyphs.json once in `Scene::new`; DRAW-BCAP with the stamp's zoom and shake, the splash, the hanko, the reading, the chapter line and
  the slice exit (%GLYPH-TRIS-CLIP).

### Two earlier-task bugs the cinematics found

- **The stamp seed (Task 6):** STAMP's `(mod (+ *stamp-seed* 7.31) 40.0)` was `sd − 40`; ECL's float MOD rounds differently (3.8600016 vs
  3.8600006), inside the tolerance as a value but a hash seed for the stamp's star: cine-84096 frame 100's Konpaku star drew rotated.
- **GRIP-LEFT!'s %ROT-COLS! is a no-op in the Lisp** (a variable capture: DIVERGENCES §1, to rule on): the two-handed grip moves only the
  left arm's joint origins. Ported as is (cine-84097 frame 25: with the rotations the left upper arm missed by 7.9e-2). Task 7's port
  rotated the columns; no earlier key drew a grip.

### SLOW-DRAW's position half (Task 5's carry), proved by mutation

On the battles' slow motions (battle-2005's first at frames 366-407, every 10th keyed; the looks window 583-600 inside 542-624):
- with `slow.rs`'s place / yaw interpolation removed (the drawn place = the sim's, the clip rewind kept): `battle-2005 frame 410 fu[12]:
  -0.5020692 key -0.5107775` (the camera eye, carried by the smoothing past the slow motion's end) and, run on 583-600 alone, `frame 583
  dq[3072]: 0.7837914 key 0.7888575` (a fighter drawn at the sim's yaw);
- with `Scene::pair` reading the sim's places instead of the drawn ones (DUEL-CAMERA not fed by SLOW-DRAW): `battle-2005 frame 410
  fu[12]` the same, `battle-2006 frame 410 fu[1]: 0.035871245 key 0.035055127`, `portrait-2005 frame 420 fu[0]`.

Restored, all pass.

### Coverage left

- TIME-CINE has no key (no keyed match runs out its timer); its looks are ported from source.
- The keyed cinematics hold 3 Ichigo scripts short of their ends (`draw-scenes.json`); the battles play the heavy and rush Kikons and the
  awakening through.
- `unported` paths left: a kit's `:intro-weapon` (Yamamoto's cane), PERFECT HINT's HOHO!, the menus' camera (M3b). FORM-GRADE's :spot is
  ported but unverified (no in-scope kit has :spot).
- START-CINE's queued frame 0 is float-checked from both kinds of system caller: battle-2005 frame 6453 (IC-HEAVY-KIKON-CINE's cf 0, started
  by HIT-SYSTEM's SETTLE-SOULS) and battle-2006 frame 6228 (IC-KESSA-CINE's cf 0, the awakening from FIGHTER-SYSTEM), both exact; never
  keyed: END-CINE -> MATCH-OVER -> KO-CINE's frame 0 (neither battle ends; the cvc rows reach it, `scene_draw_no_alloc`: no panic, no
  allocation). Whether the battles reach Task 7's unreached move looks (INSEKI-GIRI, the edge, VFX-CHARGE, the echo and flare, the beat, a
  planted weapon) was not measured.

### For later tasks

- Task 9 / 10: the page's loop is unchanged (three calls); `draw_frame` now also draws the canvas words. The dev text line replaces only
  the Lisp HUD (`hb` / `hk`). `Scene.sounds` gains `Play`'s pitch and `Silence`.
- M3b: the Lisp HUD and its pause grade, the menus' camera, PERFECT HINT (the settings), the one-hand stick.

## 9. The Bevy renderer, the page, the stills sheets (Task 9)

`rs/duel-app/src/render/` (`mod.rs`: the plugin, the copy, render.c's `r_frame` pass for pass, the frame counters; `pipes.rs`: the RP_*
table and `r_make_pipe`; `meshes.rs`: `r_mesh_new`'s chunks; `ui.rs`: ui.lisp's font atlas; `camera.rs`: `camera_bundle`),
`rs/duel-app/assets/shaders/` (engine/shaders/*.wgsl copied unchanged, the `hud.*` pair left for M3b), `rs/duel-app/src/driver.rs` (ruling
R17's driver), `rs/duel-app/src/main.rs`, `rs/duel-app/web/index.html`, `rs/duel-app/tests/alloc.rs`, `tools/port/stills.py`,
`tools/port/page-smoke.sh`.

**Result.** The page boots to the title and plays the fight a debug command starts (`Module._debug_cmd(2005)`). Every pass of render.c
runs. Static geometry matches the frozen page pixel for pixel: the stage, the sky and the fog read the same RGB at sampled points of a
2005 frame, so the gamma and the orientation are right. Two runs give byte-identical stills (27 of 27, and page-smoke's drawn 2005
still). The page passes page-smoke: 1007 frames finished by virtual 16.9 s (1009 before the targets waited for the first drawn frame), no error, startup heap 92.9 MB. Rust's combat log for
cvc-ik is the frozen page's, line for line (832 lines). After concern 1's fix (the page's dt), most cinematic stills read 0.95-1.0. What
is left is the Lisp HUD (M3b), the title's state (M3b) and one held pose (below).

### How a frame is drawn (and what differs from SDL_GPU)

- **One render-graph system, not Materials plus an entity pool.** The brief named M0a's toon `Material` and a pool of entities. Both are
  replaced here, and each needs the controller's ruling:
  - `camera_bundle()` gives the camera its own render-graph schedule (`CameraRenderGraph(DuelGraph)`). That schedule holds one
    system, `duel_frame` (a `ViewQuery` and a `RenderContext`), which encodes `r_frame`'s passes in render.c's order.
  - Every RP_* slot is a pipeline queued in Bevy's `PipelineCache` from a port of `r_make_pipe` (layout, target, depth, blend, cull) and
    RENDER-INIT's table.
  - Bevy's Opaque3d / Transparent3d phases would re-bin the opaque records and distance-sort the transparent ones. render.c draws the
    sky first, the transparent records in record order, the flame layer in three passes, and the UI in the composite's pass. So the phases
    cannot reproduce it.
  - The draw records go to a storage buffer read at `instance_index` (lit.vert / toon.vert's `draws[ii]`), as render.c does, so no
    entity exists per record. This is the global constraint's "render-graph node" form. M0a's toon WGSL is the engine's own
    toon.vert / toon.frag, used unchanged.
- **The WGSL is unchanged.** The SDL backend's group convention is kept: 0 the vertex storage, 1 the vertex uniform (Frame or S), 2
  the fragment textures, 3 the fragment uniform (Frame or P). Unused groups get an empty layout and an empty bind group. render.lisp's
  READ-WGSL is ported (`pipes::expand`): it resolves `// #include` textually and strips comments. naga_oil's `#import` cannot replace
  it, because frame.wgsl's functions read `F`, which only the including file declares.
- **The shaders are embedded, not loaded at run time.** `include_str!` of assets/shaders/, then `Shader::from_wgsl`. This deviates from
  BEVY_PORT §7.1's hot reload: the include resolution has to run before Bevy sees the text. A loader that resolves includes on reload can
  come when someone edits shaders live. `duel-data` stays embedded too, as before.
- **The colour path.** The engine shaders write sRGB-encoded values (tonemap's and toon's `pow`) into `R8G8B8A8_UNORM` targets. All
  offscreen targets are `Rgba8Unorm`.
  - Bevy writes the swapchain through an sRGB-suffixed view (`ExtractedWindow::set_swapchain_texture`), which would encode a second time.
    The composite and UI pass instead write a view created each frame from the surface texture in the surface's own format (Chrome's
    canvas: `rgba8unorm` or `bgra8unorm`, never sRGB).
  - A native surface that is itself sRGB is written as it is (doubly encoded natively; the page is the target, and no native run was
    made). Bevy draws nothing into its ViewTarget, so a Bevy-drawn dev line (Task 10) would not show without its own pass.
- **Presenting.** Bevy presents a window only when its ViewTarget's output attachment was taken that frame, and keeps an unpresented
  swapchain texture for the next update. The web canvas has already expired that texture by then: the first try failed with "Destroyed
  texture used in a submit". So `duel_frame` takes the attachment every frame, which marks it presented, and clears the canvas while the
  meshes and pipelines load.
- **Load ops.** render.c's `DONT_CARE` loads, used by the post passes and the composite, become `Clear(0)`: WebGPU has no don't-care
  load, and every pixel is written anyway. `RESOLVE` becomes `Discard` with a resolve target. Pass C's `LOAD` keeps the MSAA scene: pass
  A stores it when the flame layer is on, as in render.c. A pipeline with target 0 always has the D32 depth state (depth 0 →
  `Always`, no write; the sky and RP_COMP_FL included), as r_make_pipe does.
- **MSAA.** `render::SCENE_MSAA` = 4 (r_init's 4, which WebGPU guarantees for RGBA8 and D32) sizes the targets and is `SceneInputs.msaa`,
  so fu[157] is 0 and alpha-to-coverage is on, as on the frozen page. The camera has `Msaa::Off`: Camera3d still makes Bevy's ViewTarget
  main textures and a depth texture (single-sample, unused). That costs memory, not speed; dropping Camera3d is a Task 11 option.
- **The meshes** upload once, 2 MB a frame during the load (`meshes::BUDGET`), into 4 MB chunks indexed by the Lisp mesh id
  (`r_mesh_new`). The driver starts only when every mesh is uploaded, every pipeline is `Ok` (`render::ready()`); the targets are made at the first drawn frame's size (no 1x1 targets first).
  A pipeline error prints `render: pipeline N failed: …`, which run.mjs fails on.
- **The copy** (`extract_frame`) writes fu, the records (clamped to R_MAX_DRAWS 4096) and the four streams into fixed GPU buffers sized
  as render.c's. The CPU side (`copy_frame`: the records r_draw_queue reads, p, fu[159], the fills) goes into a `Mirror` reserved once.
  The post passes' uniforms each have their own small buffer and bind group. The texture bind groups are rebuilt only with the targets.
- **hb / hk** (the Lisp HUD and the menus) are not drawn: RP_HUD and RP_COMP_AO are M3b's. So the intro's letterbox and name card, the
  battle HUD, the 斬 glyph and RESULTS are missing on the Rust side.

### The driver and the page (ruling R17)

- **One Update system** (`main.rs` `drive`) runs `Game::frame`, which is `flow::frame` → `draw_frame` → `frame_end` in duel-tools
  draw.rs's order, with the Scene as the sink, the page clock's dt (below), and `NoInput`. `FixedUpdate` is gone, and so is M0's
  drain.
- **dt is the frozen page's, not the key's (concern 1; R17 amended for the page; the tools keep `raw_dt`).** The frozen page's RUN-FRAME
  dt is pf_pump's `(now - prev) * 1e-9f` over SDL_GetTicksNS, and on emscripten that clock has whole milliseconds:
  - SDL asks for CLOCK_MONOTONIC_RAW (4);
  - emscripten's `clock_gettime` refuses any clock above WASI's 3 (EINVAL);
  - so SDL falls back to `gettimeofday`, which reads `Date.now()` (run.mjs `--fixed-dt`: `d0 + Math.round(vt)`).

  So the frozen page's frames are 16 or 17 ms (0.016 / 0.017 as f32), and a frame now and then runs no step or two.
  `Game::rdt_of` gives each frame that dt from the rounded page clock, pf_pump's bit for bit, and the page's first frame has dt 0. The key's `raw_dt` (the stub's 16666666 / 16666667 ns) puts the steps, the fx clock and the screen-fx timers on
  other frames than the frozen page's.
- **Pacing.** Task 9 ran the frames a 60 Hz grid of the page clock said were due, with a catch-up from the page's start. The final
  review found that grid wrong on a real display (I1-I3); since ruling R32 the page runs one game frame per browser frame, as the
  frozen page does (§11 "The page's pacing").
- **Debug commands.** Each one is logged `debug N`, as M0 did, and applies at the start of the next frame run, as main.c's queue
  hands it to the next RUN-FRAME (since R32; Task 9 stamped it with a frame of the grid). page-smoke's row 2 sends 2005
  instead of M0's 42, because Rust's `debug_command` stops the fight on an unported 42.
- **The menus' camera** (`Scene.unported_camera` on title frames, M3b) is not a stop. The title draws with the camera it has, as
  duel-tools replay reads it and clears it after every frame. Any other unported path stops the fight and logs
  `duel: stopped: unported …` once (Task 10 owns the on-page message).
- **The URL diagnostic** `?log` keeps the combat log on and prints it, as the frozen page does after a debug command. It allocates, so
  it is off by default. (`?dt=clock` is gone: the page clock is the only dt.)

### The frame-done counter (M0_NOTES §2, §6)

- `render::count_frames` (RenderSystems::Cleanup, after the submit and present) counts a drawn frame as submitted. It registers
  `queue.on_submitted_work_done`, which counts the frame as done once the GPU has finished it. The page exports
  `Module._frames_done()` / `_frames_submitted()`.
- **run.mjs is unchanged.** Its rAF tick holds each frame until `Module.preinitializedWebGPUDevice.queue.onSubmittedWorkDone()`
  resolves, and `__settle` awaits it. The page now sets that object to `{device, queue: {onSubmittedWorkDone}}`: the real idle device,
  plus a promise that resolves once `_frames_done() >= _frames_submitted()`, polled on wall-time timeouts (rAF is run.mjs's clock).
  run.mjs therefore waits on Bevy's real GPU work, and the frozen dist's runs are untouched.
- **Proof.** page-smoke row 3 (two 2005 stills at virtual 6 s, byte-identical) and `stills.py --twice` (27 stills of five scenarios,
  each rendered twice, all byte-identical).

### Stills: `tools/port/stills.py`

- The scenarios are the looks gate's (`tests/style-gates.py` `looks_scenarios()`, imported read-only): cvc-ik (the brief's "2005": seed
  5), cvc-ii ("2006": seed 6), cine-ken, cine-ichigo and cine-ko, at 640x360 under `--fixed-dt 16.666667`.
- Both sides render the same script with its key steps removed. The M3a page has no keyboard (Task 10), so the cvc scenarios' Enter
  (skip the intro) would move only the frozen side. The frozen side is therefore rendered fresh (build/oracle/frozen-dist) rather than
  taken from build/oracle/stills.
- SSIM is Wang 2004 on luma: an 11 x 11 Gaussian window with σ 1.5, numpy only (no skimage; no pip dependency added). The output is
  build/port/stills/ (`<scene>-<still>.png`: Lisp | Rust | diff x4, with the SSIM on top) and `stills.tsv`.

SSIM per still (web-dev build): before → after concern 1's fix (the page's whole-ms dt). "max" and "px" (the largest channel
difference, the pixels that differ of 230,400) are after:

| still | SSIM | max | px | what differs |
|---|---|---|---|---|
| cvc-ik intro | 0.7610 → 0.7800 | 205 | 49146 | the letterbox and name card (hb) |
| cvc-ik start | 0.8024 → 0.8204 | 140 | 43812 | the battle HUD (hb) |
| cvc-ik w0-0 | 0.8065 → 0.8063 | 241 | 95227 | HUD, 斬 (hb); speed lines and sparks (the title state (M3b)) |
| cvc-ik w1-0 | 0.2652 → 0.2724 | 245 | 132110 | the same; full-screen speed lines dominate |
| cvc-ik w1-1 | 0.7443 → 0.7800 | 230 | 40294 | HUD; the title state (M3b) |
| cvc-ik w2-0 | 0.1078 → 0.2779 | 255 | 157043 | the frozen frame is in a negative impact grade (blue = inverted yellow), Rust's now too (the dt fix); speed lines |
| cvc-ik w3-0 | 0.2220 → 0.2258 | 247 | 168289 | speed lines; HUD |
| cvc-ii intro | 0.7619 → 0.7811 | 205 | 49012 | letterbox and name card (hb) |
| cvc-ii start | 0.8090 → 0.8217 | 183 | 43674 | HUD |
| cvc-ii w0-0 | 0.8017 → 0.8006 | 234 | 125942 | HUD; the title state (M3b) |
| cvc-ii w1-0 | 0.3336 → 0.2960 | 240 | 151684 | speed lines; HUD |
| cvc-ii w1-1 | 0.7934 → 0.8201 | 230 | 29174 | HUD; the title state (M3b) |
| cvc-ii w2-0 | 0.1906 → 0.2307 | 239 | 109853 | the impact frame (the dt fix); speed lines |
| cvc-ii w3-0 | 0.6942 → 0.7615 | 222 | 46237 | HUD; the title state (M3b) |
| cine-ken ken-nozarashi-026 | 0.8058 → 0.8277 | 224 | 63754 | Kenpachi's held pose: native-vs-wasm (below) |
| cine-ken ken-nozarashi-096 | 0.9869 → 0.9987 | 228 | 2339 | was the dt offset (fixed); a residue of ~2,000 px |
| cine-ken ken-bankai-030 | 0.9931 → 0.9988 | 228 | 2008 | was the dt offset (fixed); a residue of ~2,000 px |
| cine-ken ken-bankai-080 | 0.8845 → 0.9593 | 246 | 15081 | the dt offset fixed; the aura's tongues still differ in places (not examined) |
| cine-ken ken-bankai-120 | 0.9236 → 0.9987 | 247 | 2523 | was the dt offset (fixed); a residue of ~2,000 px |
| cine-ichigo ichigo-awaken-020 | 0.9892 → 1.0000 | 21 | 2009 | was the dt offset (fixed); a residue of ~2,000 px |
| cine-ichigo ichigo-awaken-060 | 0.9833 → 0.9981 | 244 | 2074 | was the dt offset (fixed); a residue of ~2,000 px |
| cine-ichigo ichigo-awaken-110 | 0.8941 → 0.9520 | 220 | 26310 | the dt offset fixed; a residue not examined |
| cine-ko soul-break-030 | 0.9678 → 0.9996 | 180 | 2012 | was the dt offset (fixed); a residue of ~2,000 px |
| cine-ko soul-break-090 | 0.9931 → 0.9993 | 102 | 2024 | was the dt offset (fixed); a residue of ~2,000 px |
| cine-ko ko-012 | 0.8978 → 0.9006 | 205 | 97728 | the 決着 caption and the K.O. shade over the floor (both hb) |
| cine-ko ko-060 | 0.8389 → 0.8867 | 221 | 102885 | the same as ko-012 |
| cine-ko results | 0.4089 → 0.4086 | 242 | 230399 | RESULTS is the Lisp HUD (M3b) |

**What the stills show, and what is only suspected.**

- **Seen:** the HUD (hb / hk, M3b) is missing on the Rust side, as expected. The sim is the same: the combat logs agree tick for tick,
  and the shots fall between the same log lines on both pages. Static pixels are equal.
- **The impact grade renders.** Shot on both pages: frame 361's negative impact (the intro, no turbo) and frame 5928 of a 2006 fight
  (IC-RENZAN's Kikon, the manga mode 3) are the same image but for the HUD and, in the second, the left fighter's pose. Mode 2 (the "red"
  two-tone) never comes up in the two fights; mode 4 (spot-keep) is Yamamoto's (M4).
- **Concern 1: the page drew some looks a frame off. Root cause: the dt.** After a turbo window, cvc-ik's frozen still at frame 452 is in
  a negative impact; the Rust page drew it at 453 / 454. The investigation:
  - **The port is not at fault.** A scratch native key over cvc-ik's command frames (gen.py's `draw_run`, scenes and output in the
    scratchpad; draw-scenes.json and build/oracle untouched) through all three turbo windows is equal to `duel-tools draw` bit for bit
    (69 keyed frames). Its impact frame is at 452 / 453.
  - **The page's dt was.** The page fed R17's `raw_dt`, the stub's clock; the frozen page's is whole milliseconds (above). The two give
    the same ticks (the combat logs agree) but not the same frames for what runs on frame time. Here it was the fx clock, whose 24 Hz
    drawings time the Burst ring's beat: the negative impact frame in stamps_draw.
  - **The fix:** `Game::rdt_of`. The native replay of the page (`tests/page_clock.rs`) now gives the impact at 452 only, as the frozen
    page's stills show (452 negative, 453 / 454 not). Under `raw_dt` the same test fails (453 / 454), a mutation check.
  - **The stills:** w2-0 0.108 → 0.278 (cvc-ik) and 0.191 → 0.231 (cvc-ii). Most cinematic stills rise to 0.95-1.0
    (ichigo-awaken-020 1.0000, bankai-120 0.9987, soul-break-030 0.9996): their effects' timing was the same dt offset, which the first
    write-up had put down to the cosmetic RNG.
  - **The nozarashi cinematic's frames** (debug 11026 at virtual 4.0 s, shots every second frame from 242 to 274) now match the frozen
    page to the noise floor through frame 264. Before the fix, 260-264 differed: the frozen page ran a frame ahead.
- **ken-nozarashi-026's held pose (0.8277): the frozen page differs from its own native image.** Ruling R26 makes the wasm page the
  truth.
  - From the hold (frame 266 on), the frozen page holds Kenpachi's arm and sword low-left: its arm continues smoothly from frame 264.
    The port and the native key hold it raised up-left, by the clip time of cine-frame 26.
  - `page-nozarashi`, fed the page's own dt, title frames and command frame, equals the port at every keyed frame 239-330, bit for bit.
  - Fix round 3 had one bounded round to find the discrete flip and did not find it. The first suspect, the x87 form of `mod_f32`,
    re-rendered strict on the page, leaves the still at 0.8277: MOD is not on the pose's path.
  - The held pose has no flip in the clip time (±1e-6 s moves records by about 2e-5), and neither the cosmetic RNG nor the command's
    frame moves the arm.
  - Recorded as a native-vs-wasm divergence in DIVERGENCES §3, with the candidates left: a long-float `pi` branch, a hash-table order,
    a page input the key lacks.
- **ko-012 / ko-060's darker floor is the Lisp HUD.** The native `hb` at both frames holds four triangles of colour (0.043 0.043 0.063)
  at alpha 0.41 over y 208-361, the screen below the horizon: the K.O. screen's shade, M3b's paint stream.
- **Bounded by M3b (the coordinator's ruling):** the cosmetic RNG and the fx clock enter the fight from a title that runs M3b's menus and
  HUD on the frozen page, which Rust's title does not. What is left in the battle stills (the speed lines and the sparks in the w windows)
  is the Lisp HUD's area plus this state; M3b's title closes it.

### The page-dt draw key (Task 9 fix round 2, ruling R25)

The draw key fed every scene the stub's uniform `raw_dt`, so a look reading the wrong dt (STEP, raw_dt, an accumulator, HUD-DT /
CINE-DT from another source) would match the key and still drift on the page. A scene can now run on the frozen page's clock.

- **The recorder.** `tools/port/oracle/stubs-draw.c` takes `DRAW_DT=page` (tools/simgate/stubs.c untouched). Each pump still runs the
  stub's own pump (its frame counter, the virtual ms); then `vt += 16.666667`, `ns = (u64)(vt + 0.5) x 1e6` (Math.round in SDL's ns),
  `dt = (ns - prev) x 1e-9f` with 0 at the first pump, into the dt lanes (and platform.c's fps average, which skips a 0 dt).
  `gen.py` sets it for a scene whose `draw-scenes.json` entry says `"dt": "page"` and copies `dt` into INDEX.
- **The port.** The same arithmetic lives once, in `duel_sim::flow::PageClock` (with `page_ns` and `PAGE_FRAME_MS`). The page's driver
  (`Game::rdt_of`) and `duel-tools draw` use it; for a page-dt scene the tool feeds frame F `PageClock::rdt` at vt = (F + 1) x
  16.666667. The tool also lets the menus' camera (M3b) pass on an unkeyed frame, so a scene can start from the title as the page does.
- **The scenes** (the looks gate's scripts at their command frames):

  | scene | commands (key frame: debug) | keyed frames | `--exact` |
  |---|---|---|---|
  | `page-nozarashi` | 239: 11026 | 239-330 (the still at 324) | yes |
  | `page-ko` | 239: 16030, 335: 16090, 422: 18012, 500: 18060 | 490-496, 565-571 (ko-012 at 493, ko-060 at 568) | yes |
  | `page-turbo-ik` | 239: 2005, then 2102 at 383 386 395 403 430 446 455 | 440-460 (w2-0 at 451) | yes |

  Pinned in docs/bevy/oracle-index.json (`dt: page`, `stubs_sha1` 4175bab7, `generated_page_dt`) and M0_NOTES §4's row. The draw suite
  checks them (`rs/duel-tools/tests/draw.rs` `page_dt_scenes_match`).
- **Provenance.** `gen.py draw` regenerated all 44 scenes with the new recorder image. The 41 earlier scenes are byte-identical to their
  pins (every sha1 and meshes.json's), so the mode changes nothing by default.
- **What it caught.** No look reads the wrong dt: all three scenes pass bit for bit at once, and duel-look's only STEP read is CINE-ACTOR-
  STEP's (cinema.lisp's own). It caught one allocation bug on the CPU half: a command frame's combat-log lines stayed in `Match.log`,
  and each CPU snapshot (`Search::snapshot`, a `Match` clone) cloned them again (38 and 72 allocations in `page-turbo-ik`'s turbo
  frames). The page's driver and `duel-tools draw` now drop those lines with the log switched off.
- **What it showed.** The page's remaining gaps are not the port's dt: nozarashi's held pose is native-vs-wasm (above), and ko's floor is
  the HUD.

### 0 allocations

- `rs/duel-app/tests/alloc.rs` runs a counting global allocator over a 2005 fight, 3,600 frames of `Game::frame` + `copy_frame`. The
  result is 0 allocations in the 3,599 frames after the command frame.
- `extract_frame` writes the GPU buffers from slices, and `duel_frame` walks the mirror (no Vec in either).
- Outside the count, all wgpu's and Bevy's own per-frame objects:
  - the swapchain view created each frame;
  - `on_submitted_work_done`'s boxed callback;
  - the render pass objects;
  - `queue.write_buffer`'s staging.
- Not measured natively: no native window was run (the page is the target).

### Speed (not a gate here; Task 11 measures)

- Headless SwiftShader, web-dev build (no wasm-opt), 1280x720, wall clock, `perf:` lines:
  - the title: 26.0-26.5 fps (37.7-38.4 ms);
  - the 2005 fight: 19.9-27.3 fps (36.7-50.2 ms, max 119 ms).
- The frozen page in the same run reports 53-107 fps in its own `stats:` line (its loop does not wait for the GPU, so the two are not
  comparable).
- Startup heap: 92.9 MB (run.mjs's budget is 110). `startup` 233-250 ms virtual.
- Candidates for Task 11:
  - drop Camera3d's unused main / depth textures;
  - the release build;
  - skipping the 2 MB / frame upload cap;
  - creating the swapchain view less often.

### For Task 10

- The URL switch `?log` is a diagnostic this task added. R17 gives the URL parameters to Task 10, which keeps or drops it.
- The page's dt is the frozen page's whole-ms clock (`Game::rdt_of`, concern 1). Task 10's loop keeps it.
- `tools/port/build-web.sh` needed no change: the shaders are embedded, so there is no `assets/` to copy. The brief listed it as
  modified.
- ken-nozarashi-026's held pose (open, above).

### Rulings (the controller's, in progress.md)

- R17 (amended by concern 1): the minimal driver; the page's dt is the frozen page's whole-ms clock, the tools keep `raw_dt`.
- R18: one render-graph system with PipelineCache pipelines and a storage buffer of records, in place of Materials and an entity pool.
- R19: the shaders embedded (no hot reload; BEVY_PORT §7.1).
- R20: the swapchain through a per-frame non-sRGB view; Task 10's dev line draws through the ui pass.
- R21: the frame-done shim on the page's `preinitializedWebGPUDevice.queue` (run.mjs untouched).
- R22: the page-clock pacing; `?log` stays a diagnostic for Task 10 (`?dt=clock` went with concern 1's fix).
- R23: the menus' camera does not stop the page.
- R24: the dependencies `bytemuck` and `wgpu =30.0.2` (no features of its own; the version Bevy pins).
- For Task 10: a rebase after 900 load frames would skew the stamps of commands queued during the load (the reviewer's item 7).

## 10. The game loop, the keyboard, the page (Task 10)

`rs/duel-app/src/game.rs` (Task 9's `driver.rs`, renamed and grown: `Game`, the screens' keys, the start, the dev line),
`rs/duel-app/src/input.rs` (`Keyboard`), `rs/duel-app/src/page.rs` (`Params`, `query`), `rs/duel-app/src/main.rs`,
`rs/duel-sim/src/cpu/fq.rs` (the fq arena), `rs/duel-app/tests/{alloc,game}.rs`, `tools/port/page-log-check.sh`, `tools/port/stills.py`.

**Result.** The page is a playable game. It boots into a VS CPU fight: human Kenpachi on the keyboard against a NORMAL Ichigo, with the
cinematics played. Esc pauses, Enter or J skips the intro and K.O. cinematics, and after a K.O. Enter plays the match again. A dev text
line stands in for the HUD. On the console, the Rust page prints the same combat log and hash lines as the frozen page through a 60 s
CPU fight (page-log-check). A pick the port has not got stops the fight with its reason on screen and in the log, once.

### The loop

- **One Update system** (`main.rs` `drive`) copies Bevy's key state into `Game.kb`, then runs one frame if a browser frame went by
  since the last one (ruling R32, §11 "The page's pacing"; Task 10 ran the frames a 60 Hz grid said were due). Each frame
  (`Game::frame`) runs in this order:
  1. the page's start, if one is queued;
  2. the debug commands that arrived since the last frame;
  3. the screens' keys;
  4. `flow::frame` with the keyboard as the `PilotInput` and the Scene as the sink;
  5. `draw_frame`;
  6. the dev line;
  7. `frame_end`.

  The dt and the Scene sink are Task 9's (R17 amended: `Game::rdt_of`, the page's whole-ms clock).
- **The screens** (flow.lisp FLOW-SCREENS' battle parts) read the frame's presses:
  - BATTLE: PAUSE-P (Esc) toggles `*paused*`. The pause screen's rows are M3b's.
  - INTRO / FINISH with a cinematic: PAUSE-P or CONFIRM-P skips it (`cine::skip_cine`).
  - RESULTS: after 2.5 s, CONFIRM-P is the REMATCH row (NEW-SEED, START-MATCH): "K.O. - Enter to rematch".

  They run app-side, before `flow::frame`. In the Lisp, the debug commands, SCREEN-FX-UPDATE and FLOW-UPDATE's `(incf *ft* rdt)` all
  run before FLOW-SCREENS, so on a human press the page is one frame off (presentation only, ruling R30):
  - a pause stops the screen effects' timers (`frame_begin`'s dt) and `ft` a frame **earlier** than the Lisp, and a resume restarts them
    a frame earlier (the Lisp's frame of the press still runs them with the old `*paused*`);
  - RESULTS' 2.5 s guard reads last frame's `ft`, so it opens a frame late;
  - after a rematch or an intro skip, `ft` holds this frame's rdt, where the Lisp's is 0 (SET-FLOW's reset comes after its increment);
  - a press on a debug command's frame acts on the flow before the command (the Lisp drains the commands first).

  No match result changes: the sim reads the pause only through `sim_running_p`, and no `ft` reader exists outside game.rs today.
  **Carried to M3b** (R30): a hook that runs the screens' keys after `flow_update`, in FLOW-SCREENS' slot (M3b's HUD reads `ft` and its
  pause rows need the slot anyway).
- **The page's start** is what the menus' VS CPU confirm calls in the Lisp. `lhud-menu-select.lisp` only draws SELECT; its START hot box
  (11) sends a confirm press, which **flow.lisp SELECT-UPDATE** turns into `(new-seed) (start-match)` (line 258), with `*mode*` `:vs-cpu`
  set by MODE and the picks and `*difficulty*` set by SELECT. The port calls **`duel_sim::debug::vs_start`** (trace.lisp TR-VS-START: mode,
  picks, difficulty, seed, `flow::start_match`). The seed is NEW-SEED's `floor(now) mod 100000`, from the page clock (performance.now;
  run.mjs's virtual clock under `--fixed-dt`, so a script's seed is fixed). No debug command runs, so `*learn-debug-off*` stays off: a
  HARD Ichigo learns against the player (FQ-ATTACH!), as in the Lisp.
- **The rematch on the real path** (`duel-app/tests/game.rs` `rematch_after_the_match_ends`): a VS CPU match on a 3 s timer runs to
  TIME-UP's cinematic and GO-RESULTS. An Enter before 2.5 s of RESULTS does nothing; one after plays the same pairing from its intro with
  the new seed.
- **A press while no frame runs** (review F3): `Game::keys` drops the presses collected while the renderer is not ready or the fight
  has stopped (the held keys are still taken). KEY-PRESSED sees only the frame's own presses, so an Enter during the load no longer
  skips the intro on frame 1. Test: `game::tests::a_press_during_the_load_is_dropped`. Presses in an update that runs no frame (no
  browser frame since the last) are kept for the next frame.
- **The rebase** (Task 9's deferred minor) went with the 60 Hz grid (R32). The one catch-up left, `?stills`' title frames on its first
  update, is capped at 900 frames and needs none: a command applies at the next frame run, whatever its arrival time.

### The keyboard (`input::Keyboard: PilotInput`)

- `read` is engine/lisp/input.lisp VPAD-READ! over control.lisp's default `:key` bindings. Every vpad action is set in `*vpad-actions*`
  order, `:mod` first, so a J pressed in the same step as Shift is modified. Then the stick is set from the direction keys (VPAD-STICK!,
  clamped; no analog stick).
- Only a human side reads, from START-MATCH's SPAWN-PAIR rule (P1 unless CPU vs CPU, P2 in VS PLAYER). The rule does not use the
  fighter's brain: the stepping CPU's brain is out of its fighter while it thinks.
- `rollout_read` is the same read. The Lisp's P1-READER reads the same SDL state inside a rollout, so a human's held keys reach the
  CPU's rollouts (DIVERGENCES §1, kept).
- `step_end` is HASH-LOG's state hash line (every 600 battle ticks), pushed into `Match.log` under `?log`.
- Pad, touch, CONTROLS' rebinding and FOCUS-LOST-P's pause are M3b's.

| action | P1 | P2 |
|---|---|---|
| up / down / left / right | W S A D | ↑ ↓ ← → |
| quick (J: attack, Mod+J: SP) | J | Numpad 1 |
| step (Space: Step, Mod+Space: Hoho) | Space | Numpad 0 |
| mod | Left Shift | Numpad Enter |
| awaken (P: Burst, Mod+P: awaken) | P | Numpad + |
| flash, sig, guard, breaker, kikon | (none) | (none) |
| CONFIRM-P (skip a cinematic, rematch) | Enter, J, Numpad 1, Numpad Enter | |
| PAUSE-P | Esc | |

Bevy's `KeyCode` names physical keys, as SDL's scancodes do on the frozen page.

### The URL parameters (R22, decided here)

| parameter | meaning |
|---|---|
| `?p1=ken&p2=ichigo&cpu=normal` | the VS CPU match: P1 (the human) and P2 (the CPU) by roster name (`kenpachi`, `ichigo`, `hisagi`, `yamamoto`, …) or short form (`ken`, `yama`), the CPU's difficulty `easy` / `normal` / `hard`. Defaults: human Kenpachi vs a NORMAL Ichigo, cinematics played. An unknown value is logged (`duel: unknown page parameter p2=renji (the default kept)`) and the default kept |
| `?stills` | boot to the title with no match and no dev line: the looks gate's scripts start their own fight with a debug command (stills.py, page-log-check.sh) |
| `?log` | the console prints the combat log (`[tick] P1 …`, once a debug command has turned it on, as on the frozen page) and HASH-LOG's `duel hash t=…` lines. Kept as a diagnostic, off by default: the lines allocate |

- `?dt=clock` went with Task 9's concern 1. M0a's `?msaa` / `?nogpu` page switches stay as index.html's.
- **The console lines.** Always printed:
  - `debug N` for each debug command (page-smoke greps it; the frozen page prints `debug cmd N`);
  - `duel: stopped: unported …`, once;
  - `startup:` and `perf:`.

  Under `?log`, the combat log and the hash lines are printed too. The frozen page's other LOG-MSG lines (`duel -> INTRO`, `duel match
  seed …`, `stats:`) are not ported. **There are no `=== …` lines.** The brief named them, but neither the Lisp (no `===` in duel/ or
  engine/) nor the frozen page's 60 s 2005 log has any.

### The dev line (`// dev: M3b replaces`)

- After `draw_frame`, `Game::dev_line` writes a line into the canvas stream (`FrameOut.ui`, drawn by the composite's ui pass, R20) at the
  top left. The line holds both fighters' character, form, Reishi, Konpaku, flash-step gauge and meter, and the clock in seconds.
- "PAUSED", or "K.O. - Enter to rematch" at RESULTS, is drawn centred at twice the size. The 5x7 font has no em dash: an unknown glyph
  draws as `?` (UI-TEXT's rule), so the brief's "—" is written "-".
- The text is a port of ui.lisp UI-TEXT / %GLYPH-RUN (`game::ui_text`: the atlas UVs of `render::ui`, a 1-scale shadow, STREAM-ROOM-P).
  It is formatted into a `String` reserved once (`clear` + `write!`): no allocation per frame.
- **Hidden for stills:** `?stills` turns the dev line off (`Game.dev`) and keeps the title boot. `tools/port/stills.py` passes
  `RUN_QUERY=?stills` to the Rust side only (the frozen dist is unchanged), so its stills stay comparable with Task 9's table. The script's
  key steps are still removed on both sides. With them, the cvc scenarios' Enter would now skip the intro on both pages; adopting that
  would change the table, so it is left for Task 11.
- **The stop** (Review Focus 5): on the frame that stops, `STOPPED: unported <reason>` is drawn in red, centred, at twice the size (or
  smaller, to fit the width). It is written into `FrameOut`, which the page keeps drawing: `drive` runs no more frames, and the render
  world copies the same `FrameRes` every update. The log line is printed once.

### The fq arena (M2_NOTES §12)

- A player's fq copy used to be leaked once per load and again per learned match: about 85 kB each, on a wasm heap that never shrinks.
- Now the copy's **structure** is leaked once, when its cell is made (`fq_table`: COPY-TREE's identity, EQ to no library entry). Its
  **q values**, the only part FQ-MATCH-END writes, live in the cell: `FqCell.q`, in rule order, in the arena `Search` owns.
- STRAT-JUDGE reads a copy's q from its cell (`strat_judge(.., q)`, through `fq::copy_q` and `strat_switch_step(.., cells)`).
  FQ-MATCH-END runs the unchanged `fq_td_update` on a scratch value holding the cell's q and writes them back. This happens outside the
  battle.
- The page codes and TR-A-STRAT's `/fq(…)` come from the cell's q. The copy keeps its identity across matches, as the Lisp's in-place
  update does; the old repoint of every brain is gone.
- **The pool** (review F1, ruling R27): the leaked structures are kept in `Search.fq_pool`, keyed by (me, vs, library entry). A cell made
  again after debug 2504 or RESET LEARNING reuses its structure. Its q come from the page (after a clear) or are the entry's fresh ones
  (after RESET LEARNING), never the forgotten cell's. The leak is bounded by the distinct keys: at most the 3 x 3 playable pairings
  times the Q selectors the lookup gives them. It no longer grows with resets.
  - One difference from the Lisp: a re-made cell is EQ to the forgotten one, where COPY-TREE makes a new object. Only a brain holding
    the old copy across a reset could tell, and none does: 2504 starts a new match, and RESET LEARNING is a SETTINGS row.
  - Test: `fq_pool_reuses_the_structure_across_resets` runs 10 rounds of a learned match, then a clear or a reset. The pool stays at 1,
    the same structure is used every time, and the q start fresh or from the page. Reading the structure's own q in place of the
    page's fails it (a mutation check, reverted).
- Test: `duel-sim/tests/fq.rs` `fq_arena_no_leak` runs 100 learned matches in a row (the tool's force: both HARD CPUs learn in CPU vs
  CPU, with a 3 s match timer). After the first match, the pool (2), the cells (2) and their q's lengths and capacities stay the
  same, and every match is counted.
- `page_roundtrip` now checks the in-place update: the same copy, new q in the cell, the leaked structure unchanged.
- `learned_q_read_from_the_cell` checks the values, not just the sizes. A reference copy of the library's :FQ is updated in place by
  FQ-TD-UPDATE! over the same records each match: the Lisp's in-place copy, which is what the repointed copy gave before.
  - Over 5 learned matches, the cell's q equal the reference's bit for bit.
  - STRAT-FQ-Q over the cell's q (what STRAT-JUDGE reads for a copy) equals STRAT-FQ-Q of the reference at 300 cue vectors.
  - Both shapes are covered: q1-ichigo-ken (plain) and t0-ki-ichigo (`:groups`, the table a HARD Ichigo learns with).
  - A one-off shift of the overlay index fails it (a mutation check, reverted). vs-learn alone could not catch that: it only sees the
    copy at 0 matches, where the cell's q equal the structure's.
- The sim gates are unchanged: 22 / 20 / 88. vs-learn (the learner's A lines, `/fq(…)` included) replays bit for bit.

### Review Focus 3 and 5

- **RF3, `cine_draw_per_rendered_frame`** (`duel-app/tests/game.rs`). Kenpachi's Bankai 狂嵐 Kikon (debug 84096: KE-KK-AT blows the
  victim away over cinematic frames 108-130) runs at dt 1/120 and 1/30. The page's `Game::frame` gives both fighters' places and facings
  equal, bit for bit on every frame, to a hand loop of `flow::frame` + one `cine::cine_draw` + `frame_end`.
  - The mutation (no CINE-DRAW) differs, so the window does run the DURING forms.
  - The forms set places from the cinematic frame. They are absolute, so a second call in the same frame repeats the first, and a count
    of two would not show. What the rate changes is which cinematic frames are drawn: every one at 1/120, every second at 1/30.
  - The per-step sink at 1/30 is Task 4's `frame_rate_120_and_30`.
  - **Which rates the page produces** (the final review's I2 / M6): until ruling R32 none but 60 Hz. The page ran a 60 Hz grid of the
    page clock whatever the display, so these rates were the library's only. Since R32 it runs one frame per browser frame, so a 120 Hz
    or 144 Hz screen gives 120 or 144 frames a second, and a page that drops refreshes gives fewer, as on the frozen page. Proven at 120
    Hz under run.mjs by page-log-check row 4 (§11 "The page's pacing").
- **RF5, `unported_surfaces_on_page`**, in two halves.
  - Native (`duel-app/tests/game.rs`): Kenpachi vs Hisagi stops on frame 1, at the intro's `:intro-weapon` (a look: the Scene's
    `unported`). The reason is drawn, and the frames after return false at once with the same `FrameOut`.
  - The page (page-log-check row 2): `?p2=hisagi` logs `duel: stopped: unported a kit's :intro-weapon (Yamamoto's cane, Hisagi's
    sealed blade: M4)` exactly once, with no error. `_frames_done` rises from 233 at virtual 4 s to 353 at 6 s, so the page draws on.
  - The label named only Yamamoto's cane; Hisagi's kit has `:intro-weapon (:hs-sealed 70)` too, so it now names both.
  - A cut CPU rollout and `m.unported` take the same path (`Game::frame`'s `stopped`).
  - A Bevy device loss: page-smoke and page-log-check fail on `DeviceLost` in the log, and the page shows the overlay with Bevy's line
    (index.html's console hook matched `DeviceLost` from the start; this note said otherwise until the final review's I4). Since that
    fix the hook also matches Bevy's `Caught rendering error` and `Quitting the application`, and a `render: pipeline N failed`, and a
    renderer still not ready 30 s after the wasm is up shows it too (§11 "The overlay").

### page-log-check (`tools/port/page-log-check.sh`)

- It runs the frozen dist (refused unless index.wasm's sha256 starts with e35032a7, as stills.py and gen.py check) and the Rust page,
  started with `?stills&log`. Both get `run.mjs --fixed-dt 16.666667 --size 640x360`, debug 2005 at virtual 1.0 s, and 60 virtual
  seconds, at once (each wait is on its PID).
- It compares the `[tick] …` and `duel hash t=…` lines below the last tick both reached, and needs at least 300 combat lines and 4 hash
  lines. Row 2 is RF5's.
- **Result:** both pages reach tick 3212 with 416 lines. Below it, 410 combat lines and 5 hash lines are equal.

### 0 allocations

- `tests/alloc.rs` `page_cpu_half_allocates_nothing` (Task 9's 2005 fight) still counts 0.
- New: `page_vs_cpu_keys_and_dev_line_allocate_nothing`. It plays the default VS CPU match with scripted held keys and presses (walk, J,
  Shift+J, Space, an Esc pause and resume) through `Keyboard::set`, the dev line drawn every frame, and `copy_frame`.
  - Counting starts the frame after the first rollout. That rollout makes the human's stand-in brain (`mcts::rollout_start`), which the
    scratch match keeps and reuses from then on.
  - Result: 0 allocations in 2,487 frames, from frame 2313 to 4800.
- Allocations left by design:
  - the `?log` lines;
  - FQ-MATCH-END's scratch value at a learned match's end (outside the battle);
  - a HARD learner's FQ-NOTE records (`Brain.fql.recs`: one firing vector per judgement, M2 R8). The VS alloc test plays a NORMAL Ichigo,
    so it covers no learner, and it counts only from the first rollout (frame 2313): the intro and the battle's first ~38 s are not
    counted.

### Sizes and speed

| build | index.wasm | index.gzip.wasm (what the Artifact page loads) | wall fps, headless SwiftShader, 1280x720, the default VS fight |
|---|---|---|---|
| web-dev (`tools/port/build-web.sh duel-app dist/rs-m3a web-dev`, no wasm-opt) | 118.3 MB | 17.0 MB: **over** the Artifact's 15 MB per binary | 21.9-27.0 fps (37.1-45.6 ms) |
| release (`… dist/rs-m3a-release release`, wasm-opt -Oz; opt-level "z" then, 3 since Task 11: §11) | 24.6 MB | 6.3 MB | 23.5-24.8 fps (40.2-42.6 ms) |

- The Artifact has to be the release build: web-dev's gzip is over the limit. Publish index.html, index.js and index.gzip.wasm.
  index.html fetches index.gzip.wasm first, decompresses it (DecompressionStream) and falls back to index.wasm. index.wasm (24.6 MB) stays
  out: it is over 15 MB.
- The release build passes page-smoke (4/4) and page-log-check (2/2) as web-dev does.
- The two builds run at the same speed under SwiftShader, so the page is GPU-bound there.
- Startup heap: release 89.4 MB, web-dev 93.9 MB (run.mjs's budget is 110).
- No new dependency.

### For Task 11

- The page's other LOG-MSG lines (`duel -> …`, `duel match seed …`), if the console should match the frozen page beyond the combat log.
- stills.py's key steps: with the keyboard, the cvc scenarios' Enter could stay (the SSIM table would then be re-measured).
- A device loss drawn as a reason on the page (RF5's last case). (Wrong as written: index.html's hook showed the overlay on
  `DeviceLost` already; corrected in the final fix pass, §11 "The overlay".)
- The screens' keys before the commands, SCREEN-FX-UPDATE and `ft`'s increment (above): carried to M3b as the after-`flow_update`
  hook (R30), not Task 11's.

Task 11 settled this list: all four items are carried to M3b (§11 "Carries to M3b").

## 11. Closing M3a (Task 11, 2026-11-28)

`rs/Cargo.toml` (the release opt-level), `rs/duel-sim/src/debug.rs` (debug 2105, its host test `debug_2105_toggles_the_brains`),
`rs/duel-app/src/page.rs` (the wasm memory on the `perf:` line), `rs/duel-app/tests/game.rs` (`rollout_reads_the_held_keys`, fix
round 1), `tools/port/page-log-check.sh` (row 3), and the docs.

**Result.** M3a is done. The page draws the fight that the frozen build draws: every keyed frame of the 44 draw scenes is equal to the
answer key, and on the page the combat log and hash lines equal the frozen page's, both in a CPU fight and in a human-on-the-keyboard
VS CPU fight. The release build moves to opt-level 3: the sim runs about twice as fast as at "z", and the gzip wasm is 9.3 MB, under
the Artifact's 15 MB limit. The HUD, the sound, the menus and the touch deck are M3b's.

### The numbers (BEVY_PORT §6.4; the frozen build `build/oracle/frozen-dist`, index.wasm sha256 e35032a7…)

| measure | frozen Lisp | Rust release, opt-level 3 (shipped) | Rust release, "z" (M3a until now) |
|---|---|---|---|
| native sim with both CPUs on, steps/s (cvc-kk-s1 / cvc-ki-s1 / cvc-ii-s1; Rust opt 3: the shipped tree's duel-tools, built from rs/Cargo.toml after debug 2105) | 143,709 / 118,933 / 77,264 | 928,777 / 810,909 / 552,595 (**6.46 / 6.82 / 7.15×**; the gate is 3×) | 429,671 / 383,747 / 259,038 (**2.99 / 3.23 / 3.35×**) |
| wasm32 sim (node, `replay-wasm.mjs --live --bench`), steps/s | (none) | 636,612 / 559,285 / 374,917 | 273,199 / 246,490 / 165,008 |
| headless frame time, SwiftShader 1280x720, wall clock | `stats:` 34.8-129.7 fps (its loop does not wait for the GPU: not comparable) | the default VS fight 36.0-49.8 ms (20.1-27.8 fps); 2005 38.3-54.7 ms (18.3-26.1 fps) | 38.6-52.8 ms (18.9-25.9 fps) |
| startup: run.mjs's `startup done … after navigation` (the page's `startup:` line, after its warm-up; not the first battle frame) | 2.47 s, at the title | 2.54 s, the 12th frame of the VS fight's intro (the default page); 2.46 s, at the title (`?stills`) | 1.85 s, at the title (`?stills`) |
| peak heap (the wasm memory at the end of a 40 s run) | 128.0 MB (`wasmMemory.buffer.byteLength` = 134,217,728 at 39.5 s of a 2005 fight; its own ECL heap count: 76.0 MB) | 89.6 MB (the same at startup: a CPU fight grows nothing) | peak not measured (that build had no `wasm memory` on its `perf:` line); at startup 89.6 MB (this task's "z" run, `?stills` + 2005) and 89.4 MB (§10, Task 10's release build) |
| `index.wasm` / gzip -9 | 11,899,490 / 3,761,550 B | 37,316,478 / 9,348,870 B | 24,552,341 / 6,295,516 B |
| allocations per frame | (Lisp: 1,410-12,585 B consed a frame, `stats:`) | 0 | 0 |

- **The sim.** BEVY_PORT §6.4's measure, as M2_NOTES §10 took it: the Rust median of 11 runs in one process (`duel-tools replay TRACE
  --live --bench`), the Lisp median of 5 process runs (`sim-bench.lisp … brains` on `build/simgate/duel.fas` with the musl preload),
  both re-measured in this session, one at a time. The Lisp moved by 1-3 % since M2 (142,427 / 118,099 / 74,925).
- **"z" fell to 2.99× on KK** (M2: 3.17×; KI 3.41 → 3.23, II 3.59 → 3.35), under the 3× gate. Rust lost about 5 % since M2
  (450,895 → 429,671 on KK). Not profiled; the candidates are M3a's look queue (`Match::look` pushes at every look site in a step,
  muted only in rollouts) and the counting allocator that release duel-tools now carries (Task 5's deferred minor; the sim allocates
  nothing in a step, so it should cost little). Opt-level 3 settles the gate: 6.46-7.15×.
- **Frame time** is GPU-bound under SwiftShader: "z" and 3 draw at the same speed (the same 38-54 ms). The frozen page's `stats:` fps
  counts loop turns that do not wait for the GPU (Task 9), so the two columns are not comparable; the page's real speed is the user's
  phone's (M3b's playtest).
- **Startup.** The frozen page boots to its title (80 load steps). The Rust page with `?stills` boots to the title; without it, into
  the VS CPU fight's intro (the same startup line: the 12th frame). Neither is the time to the first battle frame: the frozen page
  reaches a fight only through its menus or a debug command, and the Rust page's intro runs first. That measure is carried to M3b,
  when both pages reach the fight by the same menus. Opt-level 3's larger wasm compiles longer: 1.85 s to the title at "z", 2.46-2.69 s at 3 over three runs (single wall-clock runs, noisy); the frozen page takes 2.47 s to its title.
- **Peak heap.** Wasm memory never shrinks, so the last `perf:` line's `wasm memory` (new in this task) is the run's peak; the frozen
  page's is `wasmMemory.buffer.byteLength` read at the run's end. The Rust figure is from a CPU fight, so it holds what a CPU match
  reserves: the six `Match` copies' ICC lists (2.06 MB, M2_NOTES §12) and the snapshot slots. run.mjs's startup budget is 110 MB.
- **Allocations.** `duel-tools draw --check` counts 0 allocations a frame in every keyed scene after its command frame (the 44 scenes,
  battle-2005's 7,124 frames included); duel-app's alloc tests count 0 over 3,599 frames of a CPU fight and 2,487 frames of the VS
  CPU page with keys and the dev line (§10).
- **Losses against the frozen build** (§6.4 asks for each to be explained): `index.wasm` is 3.1× the frozen one (gzip 2.5×). Most of
  it is Bevy's own code (M0a: 17.4 MB of the release wasm before the game's) and the rest opt-level 3's inlining (+12.8 MB over "z");
  Bevy's share is the user's accepted cost (BEVY_PORT §1), opt-level 3's buys the sim's 2.1-2.3×. Startup is level with the frozen
  page's (2.5 s). Frame time cannot be compared headless (above).

### The opt-level (Task 11 Step 2's rule)

The rule: keep the smaller build, unless opt-level 3 fits the Artifact's 15 MB gzipped and is more than 1.5× faster on the sim.
Written down before measuring: "more than 1.5× on all three traces, natively and in wasm32; if they disagree, keep "z"".

| | "z" | 3 | 3 / "z" |
|---|---|---|---|
| index.wasm (after `wasm-opt -Oz`, build-web.sh's) | 24,552,341 B | 37,316,478 B | 1.52 |
| index.gzip.wasm (what the Artifact page loads) | 6,295,516 B | 9,348,870 B (under 15 MB) | 1.48 |
| native sim steps/s, KK / KI / II (opt 3: the decision's build, `CARGO_PROFILE_RELEASE_OPT_LEVEL=3` before debug 2105; the numbers table has the shipped tree's) | 429,671 / 383,747 / 259,038 | 923,414 / 801,502 / 549,865 | **2.15 / 2.09 / 2.12** |
| wasm32 sim steps/s, KK / KI / II | 273,199 / 246,490 / 165,008 | 636,612 / 559,285 / 374,917 | **2.33 / 2.27 / 2.27** |
| frame time, SwiftShader 1280x720 | 38.6-52.8 ms | 38.7-54.1 ms | (GPU-bound) |
| startup to the title | 1.85 s | 2.69 s | |

**Decision: opt-level 3** (`rs/Cargo.toml`, with the numbers in its comment). 3 fits (9.3 MB gzipped) and is 2.09-2.33× faster on the
sim everywhere. Notes:
- build-web.sh still runs `wasm-opt -Oz` on the page (left as is: the sizes above are the shipped ones). The sim numbers come from
  duel-tools, which wasm-opt never touches. The Task 11 reviewer measured what `-Oz` costs opt-3 code: build-web.sh's exact flags on
  the opt-3 wasm32 duel-tools, then `replay-wasm.mjs --live --bench`: KK 628,941 → 628,745 steps/s (-0.0 %), II 381,958 → 375,022
  (-1.8 %). Keeping `-Oz` (the smaller download) costs at most about 2 % of the sim.
- The release duel-tools and the sim gates now run at 3 too (the same profile). M2's "z" numbers in M2_NOTES §10 stay as history.
- The 3 build was measured with `CARGO_PROFILE_RELEASE_OPT_LEVEL=3` before the file changed; the shipped dist was rebuilt from the
  file.

### The gates (the final tree, opt-level 3)

Task 11's state; the final fix pass's numbers (page-log-check 4/4, page-smoke 5/5) are in "The page's pacing" below.

| gate | result |
|---|---|
| `tools/port/replay-gate.sh` | 22 OK |
| `tools/port/replay-gate.sh --live` | 20 OK |
| `tools/port/replay-gate.sh --wasm` / `--wasm --live` (the opt-level changed) | 22 OK / 20 OK |
| `duel-tools cvc --check $ORACLE/cvc-tag.txt` | 88 lines equal |
| `ORACLE=build/oracle cargo test --release --workspace` | 303 passed, 0 failed, 3 ignored after fix round 1 (301 before; + `debug_2105_toggles_the_brains`, `rollout_reads_the_held_keys`) |
| `duel-tools draw --check` on all 44 scenes (`--exact` on 43; cine-ic-kessa-getsuga within 2.05e-7, the native key's long-float `pi`, DIVERGENCES §3) | 44 pass, 0 allocations a frame |
| `tools/port/page-smoke.sh dist/rs-m3a-release` | 4/4 (1,008 frames done at virtual 16.9 s; startup heap 89.5 MB) |
| `tools/port/page-log-check.sh dist/rs-m3a-release` | 3/3: row 1 410 combat + 5 hash lines equal to tick 3212; row 2 Hisagi stopped once, frames done 234 → 354; row 3 (new) 268 combat + 3 hash lines equal to tick 2099 |

### The keyboard end to end (ruling R28; page-log-check row 3)

- **The fight.** No frozen debug command starts a human P1 against a thinking NORMAL CPU: 2500-2503 idle the CPU, and 2504's HARD
  Ichigo sits in `*MC-OFF-AT*` (no full-sim job). The row sends 2501 (human Kenpachi vs an idle Ichigo, VS CPU, seed 1, cinematics
  skipped: the frozen page logs `duel match seed 1 VS-CPU KENPACHI vs ICHIGO NORMAL`) and then **2105** (toggle every brain: the CPU's
  on). 2105 was not ported; it is now (`debug.rs`, one arm: the brains of P1 and P2, only a CPU side has one; host test
  `debug_2105_toggles_the_brains`). A NORMAL Ichigo against a human Kenpachi queues full-sim MCTS jobs (vs-cpu-ichigo's 19), but **not
  inside row 3's 36 s**: its compared window holds only Ichigo's style lines (`ki-style`), no core-ai neutral line that requests a job.
  So row 3 proves the keyboard path's parity on the page, and the held keys inside rollouts are proven natively (below).
- **The keys.** run.mjs's key steps (CDP `Input.dispatchKeyEvent` by `code`) reach both pages: Bevy's `KeyCode`, like SDL's scancodes,
  names the physical key. The script holds W, A and Shift for seconds at a time while the CPU plays, with J, Shift+J and Space presses.
- **Result.** Equal. Both pages reach tick 2099 in 36 virtual seconds with 273 lines; below it, 268 combat lines and 3 hash lines
  are the same, line for line. Among them are 7 P1 lines the keys drive (steps, an NS1 and wake-up rolls from a held direction); Ichigo's strings eat most presses. The first, longer script (182 steps, below) was equal for the 253 lines it
  reached on web-dev and on release.
- **The held keys inside rollouts** (ruling R31, fix round 1), proven natively:
  - duel-app `tests/game.rs` `rollout_reads_the_held_keys` runs debug 2501 + 2105 with W held through the page's own `Keyboard` (in a
    counting wrapper; `Game::frame` hands the same `&mut Keyboard` to `flow::frame`). The first rollout runs by frame 1017; all 54 of
    its P1 reads go through `Keyboard::rollout_read` and leave W on the stand-in's vpad (the stick straight up). With `rollout_read`
    emptied (a mutation, checked and reverted) only the first of the 54 reads still shows W (the live vpad copied into the scratch match) and the test fails.
  - M2's vs-cpu-ichigo live trace records the human's device every step (its F lines: buttons and stick, injected into the vpad, in
    rollouts too) and the CPU's decisions (A lines, 38 of them carrying a job's choice; 3,010 device reads in the rollouts, counted when
    M2 keyed it, the human holding a button on 29 of the 38 job steps). The live replay reproduces those choices bit for bit only if the
    rollouts read the held buttons the Lisp's did.
  - On the page, a run long enough for a rollout would take well over 12 minutes under the run.mjs slowdown (below). The page-side
    rollout check is carried to M3b, after run.mjs wraps `cancelAnimationFrame`.
- **The harness's cost.** Under run.mjs, every script step leaves the Bevy page one more update per rendered frame: the `perf:` line's
  frame count per virtual 2 s grows with each key step (60 → 5,000 "fps" over 182 steps), with no frame of the game run twice (the
  logs stay equal). The likely cause: run.mjs wraps `requestAnimationFrame` but not `cancelAnimationFrame`, so winit's cancel (it
  cancels and re-requests its frame on an event) misses a callback the hold re-queued, and the chain lives on. The frozen page does not
  cancel. The first script (182 steps, 60 s) reached only virtual 33.6 s in run.mjs's 1,400 s, on web-dev and release alike (its
  253 lines up to there were equal). Row 3 now uses 58 steps over 36 s. Without the wrapper the page does not leak: the same 58 key
  steps in a wall-clock run (no `--fixed-dt`, release, 1280x720, 40 s) keep the `perf:` windows flat at 41.0-51.2 ms (19.5-24.4 fps)
  from the first step to the last, as in the run with no keys (36.0-49.8 ms). Carried to M3b: wrap `cancelAnimationFrame` in run.mjs (it is outside rs/, and R21 left it untouched).

### The page's pacing (ruling R32; the final review's fix pass, 2026-11-28)

The final review found the page's driver wrong in three ways, all from Task 9's 60 Hz grid of the page clock (R17 / R22):
- **I1, the load played.** The first update after the renderer was ready ran every grid frame since the page's navigation (up to 900).
  On the default page frame 1 starts the match, so a 2 s load cut the intro by 2 s and a slow phone's load started the player mid-fight.
- **I2, not one frame per browser frame.** The page ran 0, 1 or 2 frames an update by the grid; the frozen page runs one RUN-FRAME per
  requestAnimationFrame. On a 120 Hz screen the Rust page drew 60 game frames a second, and the Lisp's frame-rate-dependent sim
  (DIVERGENCES §1's DURING row) did not show on it.
- **I3, a stall played in full.** A stall of 100-600 ms ran every step of it, up to 36 in one update; RUN-FIXED-STEPS drops the backlog
  after 6.

**The loop now** (game.rs's header, `Game::refresh`, main.rs `drive`, index.html):
- **One game frame per browser frame.** index.html's rAF loop calls `raf_tick` once per refresh (`Module._raf_frames()` reads the
  count). `drive` runs a frame only when the count moved since the last frame; the other Bevy updates of a refresh (run.mjs's
  re-queued callbacks, an input event's) run nothing. One more guard: run.mjs can leave winit's stale callback before the tick and
  its new one after it in one refresh, so the second update sees the counter moved at the same virtual time; `refresh` also needs the
  page time to have moved (a live page cancels winit's callback for real, and its clock never repeats). The frame's dt is the page
  clock's (`PageClock`, performance.now read in the
  update, which winit runs inside the rAF callback).
- **The loop starts when the wasm is up**, not at the page's load. Under run.mjs `--fixed-dt` any rAF user moves the virtual clock, so a
  loop started earlier would put a wall-time-long download into the page's time and make the runs differ.
- **Several browser frames between two updates are one frame** with the whole gap as its dt. The frozen page would have run each; here
  a refresh with no Bevy update is a stall, and one frame through the clamp is R32's stall rule. It never happens under run.mjs or on a
  live page (winit asks for a redraw every update, so each refresh runs one update), so no gate sees it.
- **No load backlog.** The first frame after the renderer is ready has dt 0 (`PageClock`'s first frame).
- **A stall** is one frame whose dt RUN-FRAME's clamp makes 0.1 s, and RUN-FIXED-STEPS runs 6 steps of it from any accumulator (checked
  on time.lisp's function in the host ECL), the rest dropped. Test `game::tests::a_stall_is_one_clamped_frame` goes through `rdt_of`:
  6 steps after a 200 ms gap and after a 2 s gap (the grid ran about 12 and 36).
- **`?stills` keeps a title catch-up** (`Game.title_catch_up`): its first update runs one title frame per browser frame counted so far
  (at most 900), spread over the page clock from 0. The frozen page has no catch-up, but under run.mjs its whole startup runs inside one
  browser frame (the virtual clock stands still within a frame, so main.c's STARTUP_FRAME_MS budget never runs out) and its title
  starts with its clock; Bevy's renderer is ready some 15 browser frames after its clock starts (tests/page_clock.rs's model). The title frames carry the fx clock
  into the fight the stills' debug command starts: without them `tests/page_clock.rs` (the frozen page's negative impact frame at 452)
  fails, the beat a frame off. The default page boots into the intro and never gets it.
- **Debug commands** apply at the next frame run (the grid's frame stamps and the rebase are gone).

**Checks.**
- The 60 Hz rows did not move: page-log-check rows 1-3 give the same counts as before (410 + 5, Hisagi stopped once, 268 + 3);
  `stills.py --twice` renders 27 stills byte-identical twice, and the SSIM table (stills.tsv) is byte-identical to the one before the
  fix; page-smoke passes 5 of 5 (row 5 is the overlay's, below); page-log-check 4 of 4; `cargo test --release --workspace`
  303 passed, 0 failed, 3 ignored (the alloc tests included).
- **One harness row moved: page-smoke row 3** (two fixed-dt stills of 2005 at virtual 6 s, byte-identical) now runs with `?stills`.
  On the default page the first frame is the renderer's first ready one, and under a loaded SwiftShader its virtual frame moves by a
  frame or so between runs (the pipelines compile on the wall clock: the `perf:` line's startup read 250 and 267 ms in two runs), so
  the intro frames before 2005, and the fx clock they carry, differ and so do the stills. The grid hid it by tying every frame to the
  page time. `?stills` replays the title frames since the clock started and is the harness's boot (stills.py and page-log-check use
  it). The default page under `--fixed-dt` is therefore not byte-stable before its first debug command; nothing checks it, and players
  have no virtual clock.
- **page-log-check row 4, 120 Hz** (`--fixed-dt 8.333333`). 2005's 60 s window has no Kenpachi Kikon (only Ichigo's Kikon follow-up,
  cancelled), and its log at 120 Hz equals the frozen page's on the grid page too, so it cannot tell the two loops apart. The row plays
  84000 (the sealed-form scene) at 1.0588 s and 84006 (the 鈴 Kikon, played) at 9.0 s. KEN-Z-KIKON1's DURING turns the victim over
  cinematic frames 108-122, and he keeps the last drawn frame's yaw after it; at 120 Hz every cinematic frame is drawn, on a 60 Hz grid
  two of three (whole-ms 16 / 17 ms frames run 0, 1 and 2 steps in turn). The hash at t=600 gives P2's yaw: frozen 363, the old grid
  page 355, the new page 363. The times came from a native scan of the two loops (the Game driven as each page drives it, 8 x 8 command
  times for each of 84096, 84006 and 84097): only 84006 after 84000 at 1.0588 s gave a difference in the DURING alone; the other 51
  differences came from a command applied a step apart (also a frame-rate effect, but not the DURING's).
- 6 s on the wall clock (release dist, no `--fixed-dt`): the intro still plays.

### The overlay (the final review's I4)

- index.html's console hook shows the `#fatal` overlay on the log lines that mean the canvas will stay black or frozen: a panic,
  Bevy's `Caught DeviceLost error`, `Caught rendering error` (a wgpu validation or out-of-memory error) and `Quitting the application
  due to …` (Bevy then stops rendering: bevy_render error_handler.rs), and `render: pipeline N failed` (render/mod.rs: READY stays
  false).
- **The ready watchdog.** A renderer not ready 30 s after the wasm is up (counted only while the tab is shown) shows "the renderer did
  not start in 30 s". 30 s is chosen far past a slow phone's pipeline compiles (the download and the wasm compile are before it); under
  run.mjs the whole page is up about 2.5 s after navigation.
- **page-smoke row 5** logs each of the four lines from a script step through the page's own console (no test code in the page) and
  reads the overlay back after each: 4 of 4 shown (the build before the fix: 1 of 4, the device loss only). Untested: a real GPU
  failure, and the watchdog (no page makes READY stay false without test code).

### The site table's final state (§4)

All 145 rows are wired: no `// task N` marker is left in rs/. The frame-time rows that still draw nothing are the HUD's (`flow.rs`
`// look: the HUD`), M3b's.

### Carries to M3b

The picture is done; these are the parts of M3 that are not:
- **The HUD.** The streams `hb` and `hk` are keyed but not drawn (R6), and the pause grade `p[8]` too. The ko stills' darker floor is
  the HUD's shade (§9). The Lisp HUD's host tests: hud-engine-test 74, paint-shapes-test 9, lhud-geom 58, lhud-menu 51,
  lhud-charset 5.
- **The sound.** `Scene.sounds` is collected each frame but not played. No `:select` sound on pause (Task 10's deferred minor).
- **The touch deck** and its sim branches (M1_NOTES §10's `// port: touch stub`, 5 sites), input-test's 7 device checks, and
  touch-test.lisp's 95.
- **The phone values** as live inputs: coarse pointer, one-hand, the scene scale and the auto render scale.
- **Saving** and the `soulduel.*` protocol.
- **The menus**: the title, mode, select, settings, controls and results screens; their camera (R23) and idle clips (R10).
- **The debug commands** the looks gate's other scenes need (any not in `debug.rs` stops the page with `unported debug N`).
- **The dev line** (`// dev: M3b replaces`): remove it when the HUD draws. Its glyph width is byte-wise, wrong for a non-ASCII stop
  reason; it says "K.O. - Enter to rematch" after a time-up too, and during RESULTS' 2.5 s guard (Task 10's deferred minors).
- **The whole looks gate's stills sheet**, for the user's review. stills.py still strips the scripts' key steps on both pages so the
  SSIM table stays comparable with §9; with the keyboard, the cvc scenarios' Enter could stay (§10's list; then re-measure).
- **The screens' keys after `flow_update`** (R30): the hook in FLOW-SCREENS' slot (a pause a frame early, the RESULTS guard a frame
  late, `ft` = rdt after a rematch or skip; §10).
- **The console's other LOG-MSG lines** (`duel -> …`, `duel match seed …`), if the console should match the frozen page beyond the
  combat log (§10's list).
- **The overlay on a real failure.** page-smoke row 5 proves the hook on each line logged by hand; no run makes the GPU fail, and
  the 30 s ready watchdog is untested (§11 "The overlay").
- **index.html's non-gzip branch** (the final review's #7): a host that answers a missing `index.gzip.wasm` with 200 and an HTML page
  hands that body to `init`; check the wasm magic (`00 61 73 6d`) before using a body that is not gzip.
- **run.mjs's `cancelAnimationFrame`** (above), then the page-side rollout check: row 3 run past a rollout (R31). Since R32 the extra
  Bevy updates it causes run no game frame (no new browser frame, or the same page time: `Game::refresh`), so they cost wall time only.
- **Startup to the first battle frame** on both pages, once both reach it through the menus (the numbers table measures the startup
  line only).
- **Profile the ~5 % sim loss since M2** (KK 450,895 → 429,671 at "z"): the look queue's pushes, the counting allocator. Opt-level 3
  hides it; it is not explained.
- **The portrait band** is checked only at 390x844, DPR 1 (Task 7's carry): the phone values' sizes and densities.
- **ken-nozarashi-026's held pose** (DIVERGENCES §3): open, cause not found.
- **render/mod.rs** (658 lines): split when the HUD joins the node (Task 9's deferred minor).
- **The final review's deferred minors:**
  - `SlowDraw.now` gains an entry per slow-drawn entity and is never cleared;
  - scene.rs:19 says CSS pixels where they are physical;
  - the `perf:` line prints constant pixel-lights / draws / tris;
  - `Scene.sounds` is cleared per game frame, so the sound player must drain it per frame.
- **The final re-review's minors:**
  - **Unfocused pacing.** `WinitSettings::game()` updates on a 1/60 s timer while the canvas is unfocused, folding the refreshes of a 120 / 144 Hz screen into one frame. Set `unfocused_mode: UpdateMode::Continuous`, or let FOCUS-LOST's pause make it moot. Until then, the "never happens on a live page" sentence above and the `ponytail:` note in game.rs overclaim.
  - **The watchdog.** The 30 s ready watchdog overwrites an earlier, more specific overlay. It also counts wall seconds while the tab is shown, so it could trip on a throttled iframe; count only seconds in which `raf_frames()` moved.
  - **Early commands under `?stills`.** A debug command that arrives before the renderer is ready applies at title frame 1, not at its arrival frame. There is a 4x margin today.

The ledger's deferred minors still true (checked against the code at this task's base):
- the draw key's recorder (tools/port/oracle/gen.py): a failed `draw` run leaves `.run2` and prints tracebacks before INDEX; INDEX
  records no `-dirty` flag, and a partial run overwrites the shared `image_sha1`; the default settings line (`0 1 2 2 0 0 0 0 0 0 5`) is
  not in `fixed_inputs`; stubs-draw.c's page mode writes `f[10]` as ns x 1e-9, not platform.c's now − pf_t0 (no keyed array reads it);
- §1's "hold frame + 15" is not true of 86110;
- `anim_crossfade_blends` never advances at a speed other than 1 nor plays from a time other than 0;
- the Nomi body and Oni's crack glows are never float-compared (no keyed frame draws them), with Task 7's other unreached looks
  (INSEKI-GIRI, ICHIGO-DRAW's edge, VFX-CHARGE, echo / flare, beat, the planted weapon: §7) and TIME-CINE;
- `LookQueue::push` is `pub` and does not mute (the mute is the caller's, `Match::look`);
- `duel-tools draw`'s scene entry unwraps INDEX's command entries (a panic, not exit 2, on a malformed INDEX);
- `stamps::Kind::of_hit` panics on an unknown kind (the port's `unported` convention would stop instead);
- AURA-CAP-UPDATE and the draw ignore `*no-draw*` (debug 2120+, not ported);
- `kit.face`'s match is dead in scope (every live kit's is NIL);
- SLOW-DRAW's mutation proofs are prose (the keyed frames still guard it); cine-test 43 / 44 check the pure `during` helper only;
- `canvas.rs` `hint_on` scans `tuning["*SETTINGS*"]` every frame (no allocation);
- the page clock's first-frame dt 0: the frozen page's first RUN-FRAME has `min(0.1, time since pf_init)` (startup step 0), at its
  title where no step runs; under run.mjs its whole startup is one browser frame, so that dt is one frame's. The Rust page's first
  frame has dt 0 by R32 (no load backlog), the intro's first frame on the default page (pinned by the page scenes and the 452 test).

Closed by now (not carried): Task 1's dt wording; Task 4's `slow_was` reserve (MAX_ENTITIES), the Scene pose tests (Task 5's draw),
the commit subject; Task 2's POSE_N assert (in `fk_matches_key`); Task 5's `fu[71]` and the mask lanes (no mask since Task 7), the
release allocator's re-time (done above; the loss it found is carried); Task 7's tolerance (`--exact`); Task 9's rebase (Task 10); Task 10's `fq_leaks` (the pool, R27).

### For the lead's Artifact

Publish `dist/rs-m3a-release`'s index.html, index.js and index.gzip.wasm (index.wasm is over 15 MB and stays out); the hashes are in
the task report. The Artifact's text should say there is no HUD and no sound yet (M3b): a dev text line stands in for the HUD.

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
| `build/oracle/draw/<scene>.log` | run 1's stdout: the game's log plus one `draw f` line per frame (`*tick*`, `*match-tick*`, `*flow*`, cinematic name / frame / held, `*hitstop*`), the mesh names, the seeds, the fixed inputs |
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
| slowmo | `slowmo-2513` | 2500 at 0, 2513 at 30 | every frame `0-239` (named `slowmo` 30-215) |
| forms | `forms-ken-p2` (2505, then 2508 at 80 / 160 / 240: P2 Kenpachi sealed -> Shikai L2 -> KYORAN -> ZANKAI), `forms-ken-p1` (84001, 84004 at 80, 84005 at 160), `forms-ichigo` (2394, 2395 at 80) | as listed | frame 0, then each form on 3 frames 20 apart (30 / 50 / 70 after its command; named) |
| battle (Task 8) | `battle-2005` (Ichigo vs Kenpachi, seed 5), `battle-2006` (Ichigo vs Ichigo, seed 6) | the one command | every 10th frame of the first 60 s, the looks windows, the hitstop window (2005), each mid-match cinematic every 5th frame (named) |
| portrait | `portrait-2501`, `portrait-2005` (390x844) | the one command | every 30th of 30 s |
| cinematics | 5 held by CINE-AT (`cine-ken-nozarashi` 11107, `cine-soul-break` 16095, `cine-intro` 17299, `cine-ko` 18149, `cine-ken-bankai` 35185); 7 Kenpachi Kikons played (`cine-84094`, `-84095`, `-84096`, `-84097`, `-84006`, `-84007`, `-84008`); 8 Ichigo cinematics held (`cine-ic-kikon` 75061, `-kessa-kikon` 75143, `-kessa` 75215, `-kessa-getsuga` 75299, `-heavy-kikon` 75379, `-rush-kikon` 75459, `-chain-kikon` 75539, `-haste-kikon` 86110); `cine-84094-portrait` (390x844) | the one command | every 5th frame from 0 to the hold frame + 15 (held) or the cinematic's length + 30 (played) |

What was checked from each scene's `draw f` lines:
- **quiet:** `*flow*` is BATTLE with no cinematic at the end of every frame. 2500-2503, 2394-2397 and 84000-84005 call START-MATCH under
  `*skip-cines*`, so INTRO-CINE starts and ends inside frame 0's command (its `[0] cine INTRO-CINE` log line). No `P1` / `P2 move`
  line: both fighters stand (no input reaches P1 natively; P2's brain is off).
- **held cinematics:** each one plays from frame 0, one cinematic frame per frame, and holds at the listed frame (`held` 1 from there).
  A single command with f = length − 1 (Ichigo's: 3k ≤ length − 1) plays the whole cinematic and holds on its last frame, so one
  command per cinematic is enough. The looks gate's several commands per cinematic only move the hold point.
- **played Kikons:** the cinematic runs its full length, then the scene runs on (BATTLE, no cinematic).
- **forms:** the log has `P2 form NOZARASHI / BANKAI / BANKAI-2` at the commands' frames (forms-ken-p2).
- **battle:** the intro holds the first 300 frames, so the battle starts at frame 300. `*match-tick*` restarts there, and from then on
  frame = 300 + match tick, one step per frame, cinematics included. `ENGINE::*TICK*` does not advance in a cinematic (CINE-STEP skips
  TIME-STEP), so it lags the frame count after the intro and after each Kikon. Neither match ends within the keyed 7124 frames.

**Deviations from the brief's scene list, with reasons:**
1. **75300+k replaced by all seven Ichigo cinematics.** `ichigo-debug` decodes 75000 + 80 i + k as cinematic i held at frame 3k. So
   75300 is i 3 (`ic-kessa-getsuga-cine`) at frame 180, and 75320 and up is i 4. It is no longer "the awakening at frame 2k": that is
   the old 150 i + 2k numbering, which `tests/style-gates.py` LOOKS_CINES's comment still quotes. The awakening is i 2 (`ic-kessa-cine`).
   The key holds each i = 0 … 6 at its last frame, which covers every 75000+ still.
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

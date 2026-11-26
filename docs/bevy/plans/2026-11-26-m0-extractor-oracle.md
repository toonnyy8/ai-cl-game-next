# M0 Extractor, Answer Key and Workspace Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Everything M1 needs before porting logic:
- headless Chrome can run a Bevy page for as long as the checks need;
- the real crates exist;
- a blank Bevy page answers `Module._debug_cmd` and gives deterministic stills;
- the frozen game's data sits in data files a Rust loader reads exactly;
- the answer key (sim traces and look data) is generated from `lisp-freeze`.

**Architecture:**
- Data comes out of the frozen build by running it in the host-native image (`tools/simgate`), never by retyping.
  - An extractor walks the registries after load and writes JSON data files into `rs/duel-data/data/`, committed and reproducible.
  - An oracle generator records traces and look data into the git-ignored `build/oracle/`.
- Rust gets the real workspace layout of spec §4. `duel-data` deserialises the files, and a float checksum proves every number
  came through bit for bit.
- `duel-app` starts as a blank Bevy page with the page contract of spec §3 (debug commands, console lines, gzip load,
  deterministic stills).

**Tech Stack:**
- host ECL 24.5.10 (32-bit, the native image of `tools/simgate`);
- Rust 1.99, Bevy `=0.20.1`, serde + serde_json, wasm-bindgen-cli 0.2.130, emsdk's wasm-opt;
- `tools/run.mjs`, Python 3.

**Spec:** `docs/bevy/BEVY_PORT.md` (§3 constraints, §4 crates, §5 extraction and floats, §6 answer key, §7 M0, §7.1 rebuild speed).
`docs/bevy/M0A_SPEED.md` records the M0a findings this plan builds on.

## Global Constraints

- **Freeze.**
  - Lisp is frozen at tag `lisp-freeze` (395fd0b6).
  - Never edit `duel/`, `engine/` or `tests/`.
  - The extractor and the oracle read the build of that tag only: `build/simgate/duel.fas` built by `tools/simgate/build.lisp` with the default stubs.
- **Bevy** stays at `=0.20.1`. The picture goes through Bevy's own rendering (the user: 「全部用 Bevy 繪圖」).
- **Crates** (spec §4): `duel-sim`, `duel-data`, `duel-look`, `duel-app`, `duel-tools`.
  - `duel-sim`, `duel-data` and `duel-look` never depend on Bevy.
  - `duel-sim` depends on `duel-data` and `libm` only.
- **Data, not code.**
  - Data files hold data. A field that is code in Lisp (a hook, an on-frame function, a lambda, a cinematic body) is written as
    its symbol name, a string such as `"YAMA-GARB-SET"`, for hand porting. It is never evaluated or re-expressed.
  - Knob names come from reading the source `(defparameter …)` forms. Their values come from `symbol-value` after load
    (`resolve-tuning` replaced the names inside move and kit plists).
- **Floats** (spec §5.3).
  - A `single-float` is written with ECL's shortest round-trip printing, and a `double-float` likewise, tagged in the schema as f64.
  - Rust parses them into `f32` / `f64`.
  - A checksum over `integer-decode-float` triples must agree on both sides (Task 6).
- **Determinism.** Data files are written in sorted, stable order; two extractor runs produce byte-identical files.
- **Repo rules.**
  - Bounded waits; never `pkill -f` / `pgrep -f`.
  - Subagents never push, merge or deploy, and never edit the DEVLOG or the manual.
  - Run `git checkout -- vendor` after any `./build.sh`.
  - Never commit `build/`, `dist/`, `rs/target/` or `.superpowers/`.
- **Page contract** (spec §3, M0a):
  - `index.html` + `index.js` + `index.gzip.wasm` (gzip bytes: Artifact binaries stop at 15 MB and `.gz` is not served), with an
    `index.wasm` fallback;
  - `window.Module._debug_cmd(n)`;
  - the console lines `startup: heap X MB, wasm memory Y MB` and
    `perf: startup S ms | frame F ms avg (P fps) max M | render-scale R pixel-lights 0 | draws D tris T`;
  - errors shown on screen.
- **Rebuild speed** (spec §7.1):
  - In development, data files and shaders are read from disk and hot-reloaded.
  - The release page embeds them.
  - wasm development uses `--profile web-dev`.

## Review Focus

1. **A move reached only through a kit or a copy**: derived forms (`:startup-add`, `:reach-mult`), cadence copies and
   `*ya-garb-copies*`-style variables must all be in `moves.json`, each once, with its own numbers. Task 4's test counts objects by
   `eq` identity against the image.
2. **A knob that is not a knob**: `defparameter`s holding tables, MOVE copies or functions must not crash the tuning dump. They are
   written as `{"kind": "skipped", "why": …}` and counted; Task 5 asserts the count is reported and no symbol is silently lost.
3. **A float that does not survive**: denormals, negative zero, values like `1.4f0` that print differently as double, and doubles
   such as `pi` inside plists. Task 6's checksum over every float, plus a fixture of those edge values, pins it.
4. **A replay that cannot replay**: recording vpads without the sim RNG state makes CPU traces unreplayable. Task 7 records
   `(sim-rnd-state)` after `brain-system` each tick, and its test re-runs one trace with the recorded inputs and RNG injected and
   gets the same per-tick hashes.
5. **A long headless run**: every still and smoke of the port runs in headless Chrome, where Bevy lost its device after about
   700-900 drawn frames (M0a). Task 1 must end with a 300 s headless run drawing meshes and no `DeviceLost`, or with the cause
   proven and the user asked.

---

## File structure

```
rs/Cargo.toml                         modify: members += duel-sim duel-data duel-look duel-app duel-tools; deps serde serde_json libm
rs/duel-sim/{Cargo.toml,src/lib.rs}   create: empty sim crate (no Bevy), one smoke test
rs/duel-data/{Cargo.toml,src/lib.rs,src/*.rs}  create: serde types + loader for data/*.json, checksum
rs/duel-data/data/*.json              create (generated, committed): moves kits clips poses rig bodies weapons glyphs tables tuning debug_ranges manifest
rs/duel-look/{Cargo.toml,src/lib.rs}  create: empty look crate (no Bevy)
rs/duel-app/{Cargo.toml,src/main.rs,src/page.rs,web/index.html}  create: blank Bevy page with the page contract
rs/duel-tools/{Cargo.toml,src/main.rs}  create: `duel-tools check-data` (loads all data, prints counts + checksum)
tools/port/build-web.sh               create: release | web-dev page build (from rs/spikes/m0a/build-web.sh, generalised)
tools/port/extract/extract.lisp       create: runner: load duel.fas, sg-init, write data/*.json
tools/port/extract/json.lisp          create: tiny JSON writer (sorted keys, shortest floats, symbol names as strings)
tools/port/extract/defparams.lisp     create: read source forms -> knob names
tools/port/oracle/record.lisp         create: runner: *step-hook* recorder (vpads, rnd state, hash every tick, clog) for cvc / trials
tools/port/oracle/replay.lisp         create: runner: replay a trace with brains detached, recorded vpads + rnd injected
tools/port/oracle/look.lisp           create: runner: FK tables per clip, sound PCM
tools/port/oracle/gen.py              create: drives all oracle runs into build/oracle/, writes build/oracle/INDEX.json
docs/bevy/M0_NOTES.md                 create: device-loss findings, data file schema, oracle layout, counts
```

---

### Task 1: Headless device loss (investigation with an exit criterion)

**Files:**
- Modify: `rs/spikes/m0a/*` (diagnostics only)
- Create: `docs/bevy/M0_NOTES.md` §1

**Interfaces:**
- Produces: a statement of the cause, plus either a fix (code / flag / version) that later tasks apply, or a ruling. `duel-app` and the
  run.mjs flags of Tasks 3 and 9 depend on it.

- [ ] **Step 1: Reproduce in a minimal form.**
  - M0a's replay with `?static&msaa=off` loses the device after about 20 s.
  - Bisect what must be drawn for the loss: 1 mesh vs 145; one material type vs three; `NoFrustumCulling` on / off; the `Text`
    entity on / off.
  - Log `performance.memory.usedJSHeapSize` every 2 s (Chrome) and wasm memory, to separate a leak from a GC-triggered fault.
  - Expected: a smallest scene that still loses the device, with its frame count at loss.
- [ ] **Step 2: Test the three suspects, each with one 300 s run.**
  - **(a) GC.** Force GC every 5 s (`--js-flags=--expose-gc` through `CHROME_FLAGS` if run.mjs passes it, else add the flag behind
    an env var to run.mjs).
    - If loss comes at the first forced GC: a JS reference dropped (wgpu web backend).
  - **(b) Backend.** Run with `--use-angle=vulkan` / without SwiftShader, if the machine allows.
    - If the loss disappears: headless-SwiftShader only.
  - **(c) Versions.** Run the newest Bevy 0.20.x / wgpu 30.0.x patch (`cargo update -p wgpu`) in the spike only.
- [ ] **Step 3: Rule.**
  - Exit criterion: a 300 s headless run of the m0a page drawing all 145 meshes with no `DeviceLost`, by a fix the port can keep
    (a code change, a run.mjs flag for headless only, or a patch version allowed by `=0.20.1`'s lock).
  - If none works within the three suspects: write the evidence in `M0_NOTES.md` §1, add a ledger `Ruling:`, and **stop and ask
    the user**. Bevy is the user's choice, and the checks need long headless runs.
- [ ] **Step 4: Commit** `rs/spikes/m0a` diagnostics and `docs/bevy/M0_NOTES.md`
  (`git commit -m "Bevy port M0: headless device loss — <cause / fix>"`).

### Task 2: The workspace crates

**Files:**
- Modify: `rs/Cargo.toml`
- Create: `rs/duel-sim`, `rs/duel-data`, `rs/duel-look`, `rs/duel-app`, `rs/duel-tools` (Cargo.toml + lib / main)

**Interfaces:**
- Produces:
  - crate names `duel_sim`, `duel_data`, `duel_look`, `duel_app` (bin `duel-app`), `duel_tools` (bin `duel-tools`);
  - workspace deps `serde = { version = "1", features = ["derive"] }`, `serde_json = "1"`, `libm = "0.2"`.

- [ ] **Step 1: Write the boundary tests.**
  - `rs/duel-sim/src/lib.rs` `#[test] fn sim_crate_builds()` (asserts `duel_sim::VERSION == "0.0.0"`).
  - `tools/port/check-deps.sh`: for each of `duel-sim duel-data duel-look`, `cargo tree -p X -e normal | grep -c '^.*bevy'` must print 0.
- [ ] **Step 2: Run.** `cargo test --workspace` in `rs/`. Expected: FAIL (crates missing).
- [ ] **Step 3: Create the five crates.**
  - `duel-app` depends on bevy with the M0a feature list plus `file_watcher` behind a `dev` feature.
  - `duel-sim` depends on `duel-data` and `libm`.
  - `duel-look` depends on `duel-sim` and `duel-data`.
  - `duel-tools` depends on `duel-sim` and `duel-data`.
- [ ] **Step 4: Run.** `cargo test --workspace` and `tools/port/check-deps.sh`. Expected: PASS; three zeros.
- [ ] **Step 5: Commit.** `git add rs tools/port/check-deps.sh && git commit -m "Bevy port M0: workspace crates (sim / data / look without Bevy)"`

### Task 3: The blank page and its contract

**Files:**
- Create: `rs/duel-app/src/main.rs`, `rs/duel-app/src/page.rs`, `rs/duel-app/web/index.html`, `tools/port/build-web.sh`

**Interfaces:**
- Consumes: Task 1's fix (flags / code), Task 2's `duel-app`.
- Produces:
  - `duel_app::page::DebugQueue` (a `Resource` holding `VecDeque<i32>`), filled by the exported wasm function
    `#[wasm_bindgen] pub fn debug_cmd(n: i32)`;
  - `window.Module._debug_cmd = n => wasm.debug_cmd(n)`, set by `index.html` after init;
  - `tools/port/build-web.sh <crate> <out_dir> [release|web-dev]`;
  - `Module.preinitializedWebGPUDevice` set to a device the page requests before init, so `run.mjs --fixed-dt` starts its clock.
    Only `__settle` awaits it.

- [ ] **Step 1: Write the smoke script and the checks first.** Create `tools/port/page-smoke.sh`. It runs and asserts:

  | Command | Expected |
  |---|---|
  | `node tools/run.mjs dist/rs-blank --secs 8` | exit 0; one `startup:` line; at least 2 `perf:` lines |
  | `--fixed-dt 16.666667 --script` with `Module._debug_cmd(42)` at 9.0 s | the log has `debug 42` |
  | two runs of `--fixed-dt 16.666667 --shot a.png` / `b.png` at 10 s | `cmp a.png b.png` is silent (deterministic stills) |
  | `RUN_QUERY=?nogpu` | an `engine fatal:` line |

  Run it. Expected: FAIL (no page).
- [ ] **Step 2: Implement.**
  - The page: `ClearColor` and a `Camera3d`.
  - `DebugQueue` is drained each `FixedUpdate` at 60 Hz, logging `debug N` through the M0a `say()`.
  - Port M0a's `startup:` / `perf:` lines.
  - `index.html` is M0a's (gzip load, error overlay, canvas size line), plus the `preinitializedWebGPUDevice` request and the
    `_debug_cmd` hookup.
  - `build-web.sh` = M0a's script with the crate name, the output directory and the profile as arguments. `web-dev` skips wasm-opt.
- [ ] **Step 3: Run `tools/port/page-smoke.sh`.** Expected: every row passes. If the two fixed-dt stills differ, record why in
  `M0_NOTES.md` and make a ruling. Don't drop the check.
- [ ] **Step 4: Commit.** `git commit -m "Bevy port M0: blank duel-app page — debug commands, console contract, gzip load, deterministic stills"`

### Task 4: Extractor I — the JSON writer, moves and kits

**Files:**
- Create: `tools/port/extract/json.lisp`, `tools/port/extract/extract.lisp`, `tools/port/extract/test-json.lisp`

**Interfaces:**
- Consumes: `build/simgate/duel.fas`, built by `python3 -c "import sys; sys.path.insert(0,'tools'); import simlib; simlib.build()"`.
- Produces:
  - `rs/duel-data/data/moves.json`: an array sorted by `id`. Each move is `{"id": "<kit-char>/<kit-form>/<name>[#n]",
    "name", "kind", "clip", "clip2", "s", "a", "r", "whiff", "dmg", "adv_block", "track", "reach", "hits": [{"from", "to", "dmg",
    "vols": [[6 floats]], "react", "kb", "hs", "chip", "stun", "guard", "seg", "min", "steal", "flags"}], "hold", "slide",
    "flags", "armor_hits", "cooldown", "on_frame": [[frame, "HOOK"]], "tick", "release", "on_land", "cine", "params": {…},
    "enter", "clip_speed", "blend", "planted"}`. `#n` is added only when two different objects share a kit and a name.
    Hook fields are strings.
  - `rs/duel-data/data/kits.json`: `{char: {form: {…slots…, "cls": {move_id: "na|ns|as|sa"}, "sp": {name: cost},
    "moves": [move_id…], "hooks": {point: "FN"}}}}`.
  - Also `roster`, `retired`.
  - `cl-user::extract-json (object stream)` in json.lisp:
    - keywords become lowercase strings without the colon;
    - other symbols become `symbol-name`;
    - plists become objects, with keys sorted;
    - vectors and lists become arrays;
    - single-floats print with `~a` under `*read-default-float-format* 'single-float`;
    - doubles become `{"f64": "<repr>"}`;
    - `nil` becomes `null` in value position and `[]` where the schema says list.

- [ ] **Step 1: Write `test-json.lisp`.**
  - It asserts the output of `extract-json` for: `1.4f0` → `1.4`, `-0.0f0` → `-0.0`, `least-positive-single-float` →
    `1.4012985e-45`, `pi` → `{"f64":"3.141592653589793"}`, `'(:b 2 :a 1)` → `{"a":1,"b":2}`, `'ya-garb-set` → `"YA-GARB-SET"`,
    `#(1 2)` → `[1,2]`.
  - Run: `$ECL_HOST --norc --load tools/port/extract/test-json.lisp`. Expected: FAIL (no writer).
- [ ] **Step 2: Implement `json.lisp`; run the test.** Expected: PASS.
- [ ] **Step 3: Write the move census test** in `extract.lisp` (mode `census`). It walks every kit's `kit-moves`, `*moves*`,
  `*cadence-moves*`, `*ya-reach-copies*`, `*ya-garb-copies*`, `*hs-k1-scaled*` and `*perfect-hw*`'s owner. It collects
  distinct MOVE objects by `eq`, prints `census moves N`, and the run exits 1 if `moves.json` has a different count or a missing
  identity.
  - Run before Step 4. Expected: FAIL (no moves.json).
- [ ] **Step 4: Implement `extract.lisp` modes `moves` and `kits`.**
  - Moves are dumped from the struct slots, never from `mv-spec` (a derived form's spec holds the base numbers).
  - Write both files.
  - Run `census`. Expected: `census moves N` and exit 0.
- [ ] **Step 5: Check reproducibility.** Run the extractor twice; `cmp` both files. Expected: identical.
- [ ] **Step 6: Commit.** `git add tools/port/extract rs/duel-data/data/{moves,kits}.json && git commit -m "Bevy port M0: extractor I — JSON writer, moves (all objects by identity), kits"`

### Task 5: Extractor II — clips, poses, bodies, weapons, glyphs, tables, tuning, debug ranges

**Files:**
- Modify: `tools/port/extract/extract.lisp`
- Create: `tools/port/extract/defparams.lisp`

**Interfaces:**
- Produces these files in `rs/duel-data/data/`, each sorted by key:
  - `clips.json` `{name: {"dur", "loop", "times": [f32], "snaps": [f32], "poses": [[68 f32]…], "marks": {…}}}`
  - `poses.json` `{name: [68 f32]}`
  - `rig.json` `{"joints": [{"name", "parent", "offset", "flex_sign", "mirror"}], "aliases", "mirror_pairs", "key_ease"}`
  - `bodies.json`: body specs, palettes, props, girth, rim, ink, scale, width, hunch, hurt_r, hurt_h, clips (the variants included)
  - `weapons.json` `{name: {"sections": [{"verts": [[9 f32]…]}], …}}`: each section lambda run on a fresh mesh builder,
    `mb-data` read before `mb-build`
  - `glyphs.json`: `*glyph-outlines*` as `[[code, advance, [poly…]]…]`
  - `tables.json`: `stage_ruins`, `plaza_cracks`, `stamp_kinds`, `fz_sets` and the fuzzy rule bases, `strat_*` tables
    (`*strat-library*` with its `:fq` Q tables), `lhud_fighters`, `lhud_moves`, `commands`, `vpad_actions`
  - `tuning.json` `{"SYMBOL": value | {"kind": "skipped", "why": "function|move|unprintable"}}` over every source
    `(defparameter …)` name in `engine/lisp` and `duel/lisp`
  - `debug_ranges.json` `[[lo, hi, "NAME"]…]`
  - `manifest.json` `{"counts": {file: n}, "skipped_tuning": n, "float_checksum": "<hex>"}`
  - The HUD atlas is copied, not extracted: `duel/hud-font/{atlas.r8,metrics.bin}` → `rs/duel-data/data/hud-font/`.
- `defparams.lisp`: `cl-user::source-defparameters (dirs) -> list of symbols`. It reads every form of every `.lisp` file in
  MANIFEST order with `*read-eval* nil`, collecting `(defparameter NAME …)` at top level and inside `progn` / `eval-when`.

- [ ] **Step 1: Write the census checks** as mode `census` lines that must equal the image:
  - `(hash-table-count *clips*)`;
  - `(hash-table-count *poses*)`;
  - `*bodies*` and `*weapons*` counts;
  - `(length *glyph-outline*s)`;
  - `(length *debug-ranges*)`;
  - the source defparameter count = `tuning.json` entries (written + skipped).

  Run. Expected: FAIL.
- [ ] **Step 2: Implement each dump.** Run `census`. Expected: every count equal; the skipped tuning count is printed and nonzero
  only for listed reasons.
- [ ] **Step 3: Compute the float checksum.** In the extractor, compute the checksum: FNV-1a 64 over `(sign, exponent, mantissa)`
  of every float written, in file order. Write it to `manifest.json`.
- [ ] **Step 4: Check reproducibility (twice, `cmp`); check sizes.** If `data/` passes 30 MB, rule: switch the largest file to
  a gzip of the same JSON (`.json.gz`, read by the loader). Ledger it.
- [ ] **Step 5: Commit.** `git commit -m "Bevy port M0: extractor II — clips, poses, rig, bodies, weapons, glyphs, tables, tuning, debug ranges, manifest"`

### Task 6: `duel-data`, the loader and its exactness proof

**Files:**
- Create: `rs/duel-data/src/{lib.rs,moves.rs,kits.rs,clips.rs,body.rs,tables.rs,tuning.rs,checksum.rs}`, `rs/duel-tools/src/main.rs`

**Interfaces:**
- Consumes: Tasks 4-5's files and manifest.
- Produces:
  - `duel_data::Data::load(dir: &Path) -> Result<Data, String>`;
  - `duel_data::Data::embedded() -> Data`, which uses `include_bytes!` (release / wasm);
  - typed structs `Move`, `HitWin`, `Kit`, `Clip`, `Body`, `Weapon`, `RigJoint`;
  - `duel_data::checksum::floats(&Data) -> u64`, the same FNV-1a order as Task 5;
  - `duel-tools check-data [dir]`, which prints the counts and the checksum.

- [ ] **Step 1: Write the tests.**
  - `loads_every_file`: counts equal `manifest.counts`.
  - `float_checksum_matches_manifest`.
  - `edge_floats`: a fixture JSON with `1.4`, `-0.0`, `1.4012985e-45`, `{"f64":"3.141592653589793"}`. Assert the bits:
    `0x3fb33333`, `0x80000000`, `0x00000001`, `0x400921fb54442d18`.
  - `garb_copy_present`: `moves` contains two `yamamoto/bankai/ya-e-n1c` entries with different capsule length (4.5 base, 5.4 /
    6.3 copies).

  Run `cargo test -p duel-data`. Expected: FAIL.
- [ ] **Step 2: Implement.** serde with `#[serde(deny_unknown_fields)]` on every struct, so a schema drift fails loudly. f64 fields
  parse the tagged form.
- [ ] **Step 3: Run the tests and `cargo run -p duel-tools -- check-data rs/duel-data/data`.** Expected: PASS; the checksum
  printed equals the manifest's.
- [ ] **Step 4: Commit.** `git commit -m "Bevy port M0: duel-data loader with float checksum = extractor's (bit-exact data)"`

### Task 7: Answer key I — sim traces

**Files:**
- Create: `tools/port/oracle/record.lisp`, `tools/port/oracle/replay.lisp`, `tools/port/oracle/gen.py` (the sim part)

**Interfaces:**
- Consumes: `build/simgate/duel.fas`.
- Produces: `build/oracle/traces/<name>.trace`, line-oriented, one line per sim step that advanced `*match-tick*`:
  `T <match-tick> <vpad-tick p1> <downs p1 as 9 bits hex> <sx p1> <sy p1> <same for p2> <rnd-state after brain-system hex>`,
  then `H <state-hash-line>` every tick, plus the `[tick] …` combat log lines as they print.
  - The traces cover:
    - seeded CvC for every ordered pairing of the four fighters (Yamamoto 0, Kenpachi 1, Ichigo 3, Hisagi 7), seeds 1-3;
    - `--cvc`'s II / IK / KK at the tag (`cvc-tag.txt`, replacing the stale `tests/style-cvc-ref.txt` for M2);
    - every combo trial of `tools/simgate/trial.lisp`.
  - `build/oracle/INDEX.json` lists them with tick counts.

- [ ] **Step 1: Write the replay check first.** `replay.lisp TRACE`:
  - detaches both brains;
  - each step, before `fighter-system`, writes the recorded vpad state into each pilot's vpad and sets `(setf (sim-rnd-state)
    rnd)`;
  - compares its own `state-hash-line` with each `H` line;
  - prints `replay OK N ticks` or `replay DIVERGED at tick T`, with exit 0 / 1.

  Run on a hand-made 2-line trace. Expected: FAIL (no recorder output).
- [ ] **Step 2: Implement `record.lisp`.**
  - Hook point: `*step-hook*`, plus a wrapper around `brain-system`'s end for the rnd state. If the hook order makes that
    impossible, record the rnd state at `*step-hook*` and the state before the step, and rule.
  - Turn `*combat-log*` on after the first frame, as `run-log.lisp` does.
- [ ] **Step 3: Record seed 1 of Ichigo vs Kenpachi; replay it.** Expected: `replay OK`. This is Review Focus 4's test.
- [ ] **Step 4: `gen.py sim` records the whole set.** Replay three traces picked by `gen.py` (one per pairing kind). Expected: all
  `replay OK`; `INDEX.json` written.
- [ ] **Step 5: Commit** the tools only (`build/oracle` is git-ignored):
  `git commit -m "Bevy port M0: answer key — per-tick traces (vpads, sim RNG, hash, combat log) for CvC and trials, replay-verified"`

### Task 8: Answer key II — look data

**Files:**
- Create: `tools/port/oracle/look.lisp`
- Modify: `tools/port/oracle/gen.py` (the look part)

**Interfaces:**
- Produces:
  - `build/oracle/fk/<clip>.json`: per frame at 60 Hz over the clip's duration, every joint's world matrix (16 f32), plus the weapon
    tip and base for each form that plays the clip (bodies with a weapon);
  - `build/oracle/sound/<key>.f32`: raw 48 kHz mono f32 for every `*au-defs*` entry. They are rendered in definition order in a
    fresh process, before anything calls `au-rnd`, through the sequence of `engine/lisp/audio.lisp:358-370` (funcall, sanitize,
    finish unless looping, normalize to peak);
  - `build/oracle/stills/`: the 83 looks-gate stills of the frozen `dist/duel`
    (`python3 tests/style-gates.py looks dist/duel dist/duel --jobs 4`, copied from its output).

- [ ] **Step 1: Write the checks.** `gen.py look --check` asserts:
  - one FK file per clip in `clips.json`;
  - 51 sound files, each nonzero and finite;
  - 83 stills.

  Run. Expected: FAIL.
- [ ] **Step 2: Implement `look.lisp`.** Use the engine's own FK (the code path `tests/duel-rules/art.lisp` uses for the reach
  test). Run `gen.py look`.
- [ ] **Step 3: Check sound determinism.** Render twice in two fresh processes; `cmp` all 51. Expected: identical.
- [ ] **Step 4: Commit** the tools. `git commit -m "Bevy port M0: answer key — FK tables per clip, sound PCM, looks-gate stills"`

### Task 9: Docs, gates, merge

**Files:**
- Modify: `docs/bevy/M0_NOTES.md`, `docs/bevy/BEVY_PORT.md`, `docs/README.md`, `AGENTS.md`, `docs/DEVLOG.zh-TW.md` (new § = the file's max + 1)

- [ ] **Step 1: `M0_NOTES.md`.** Record:
  - device loss (Task 1);
  - the data file schema, with the code-field list (hooks as names);
  - the counts from `manifest.json`;
  - the oracle layout and `INDEX.json`;
  - the rulings.
- [ ] **Step 2: AGENTS.md and docs/README.md.** Add rows for `rs/`, `tools/port/` (extract, oracle, build-web, page-smoke,
  check-deps) and the Bevy docs.
- [ ] **Step 3: Gates.** Expected: all pass.
  - `cargo test --workspace`;
  - `tools/port/check-deps.sh`;
  - `tools/port/page-smoke.sh`;
  - `cargo run -p duel-tools -- check-data`;
  - the extractor twice + `cmp`;
  - `gen.py sim` and `gen.py look --check`;
  - `python3 tools/simgate.py --cvc` (the default image unchanged: 3 PASS).
- [ ] **Step 4: DEVLOG § (zh-TW), commit, merge to `main`, push.** Report to the user: the counts, the device-loss outcome, and
  that M1's plan is next.

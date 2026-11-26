# SOUL DUEL on Rust + Bevy: the port (design, 2026-11-26)

The design a builder plans the port from. Sections 1-3 are the user's. Sections 4-8 are the lead's calls, marked as such, and a builder
may change them with a reason. The DEVLOG § and the plan come later.

## 1. Intent (the user's words)

- 2026-11-26: 「請幫我基於目前的實作進行移植，目標是從當前的 ecl 將遊戲系統與動畫移植到基於 bevy 的 rust 上」
- Why: 「我希望提高整體的運行效能，並用更安全的語言來減少未來的維護難度」
- The lead played the finish line back to the user and they confirmed it (「你理解的沒錯」). The Rust + Bevy build plays exactly like the
  current game:
  - the same moves, numbers, animation, effects, cinematics, HUD, menus, sound and phone controls;
  - it runs in the browser and on phones;
  - it is published to the same playtest page;
  - only faster.

  Once it has caught up, it replaces the Lisp build: the Lisp build is archived and only Rust is maintained.
- 「搬遷這段時間 Lisp 版會凍結」: no Lisp change during the port.
- The builder check's question (2026-11-26), answered by the user:
  - If Bevy's renderer turns out slower than today's lean pipeline, what gives? → **「全部用 Bevy 繪圖」**. The picture goes through Bevy's
    own rendering (materials, render graph), and being slower somewhere is accepted. The rejected options were a Bevy shell drawing with
    its own wgpu passes, and dropping Bevy for plain Rust + wgpu.
  - A speed test before the big work? → **「先測速再繼續」** (§7 M0a).
  - The phone that judges performance → **「Android + Chrome」**.
- The lead then played back four more points and the user confirmed them (「沒有遺漏，萊醬你可以開始了」):
  - the frozen Lisp build is the answer key;
  - the browser and phone targets;
  - only what runs on `main` is ported;
  - the order of §7.

## 2. Goals, non-goals, anti-goals

**Goals**
- Parity, defined below. Every playable fighter and form on `main` at the freeze must be ported: Yamamoto, Kenpachi, Ichigo and Hisagi, with
  their Shikai / Bankai / 爆炎 forms, their NS / AS / SA / NA, Kikon cinematics, stances and looks. Also ported:
  - the core system: the triangle, SP, pointers, the temporary switch, holds, cancels, hazards;
  - rounds and gauges: awakening, SUBLIMATION / DRIVE;
  - the CPU: core-ai, cpu-perceive, MCTS, strategies, the fuzzy Q tables, the online learner;
  - PRACTICE;
  - the Lisp HUD and menus;
  - the touch deck;
  - camera, stage, VFX, sound and music;
  - the debug commands the tests use.
- Faster overall: the sim and the game's own code. Measured against the frozen build (§6.4). The renderer is Bevy's own, by the user's
  choice, even where it costs more.
- Safer to maintain: safe Rust in the game. `unsafe` only at the FFI / web boundary, and every use commented.
- Ships as a browser build (wasm32 + WebGPU) that runs on phones and publishes to the playtest Artifact.

**Non-goals**
- No redesign, rebalancing, new features or look changes during the port, even ones that look like fixes. A Lisp bug is ported as a bug and
  listed in `docs/bevy/DIVERGENCES.md` for the user to rule on after parity.
- Not ported:
  - the retired kits (branch `retired-kits`) and the frozen modes (branch `frozen-modes`);
  - the Babylon port;
  - research tools whose only job was a finished search, such as dream-rsi workspaces, `teach-*`, `mc-*` and `strategy-*` scorers. Their
    outputs (tables, knobs) are ported as data.
- No native desktop release is required. A native build exists for the headless gates and for development.

**Anti-goals** (these fail the port even if it "works")
- A Rust build that only looks or plays alike. A match that drifts from the Lisp answer key, whether by one tick, one hash or one hit, is a
  failing port.
- Hand-transcribing thousands of keyframes and move tables. Typos there are invisible until a playtest finds them.
- The sim depending on Bevy's scheduler, system order or parallelism for its results.
- Slowness that is not measured and reported. Bevy's rendering may cost more than today's pipeline in places, and the user accepts that
  (「全部用 Bevy 繪圖」). Every such cost still shows up in the numbers of §6.4 and is reduced where Bevy allows (pipeline warm-up during
  the `:load` steps, so no first-use hitch, trimmed features).
- A Lisp change sneaking in during the freeze. If the user asks for one anyway, stop the port and ask how to merge it.

## 3. Constraints

- **The freeze.**
  - Tag `lisp-freeze` on `main` at 395fd0b6, the last Lisp commit (v492).
  - The answer key is generated from that tag only.
  - `duel/`, `engine/` and `tests/` stay untouched until the switch-over in §7 M6.
- **Repo rules carry over** (AGENTS.md):
  - every user decision goes into the design doc, the DEVLOG and the manual;
  - commit and push `main` at each gated milestone;
  - deploy only when asked;
  - bounded waits, never `pkill -f`;
  - subagents never push or deploy;
  - no balance gates;
  - presentation-only steps run no match tests;
  - low coupling / high cohesion, ECS and pragmatic FP.
- **Determinism.**
  - Fixed 60 Hz steps.
  - Every input goes through a vpad.
  - The three RNG streams are ported bit-exact (`engine/c/engine.h`, `rng.c`: `rng_float` cosmetics, `rng2_float` the sim, `au_rng` the
    audio noise; xorshift32, `>> 8` × 2^-24, fmix32 seeding).
  - Wall-clock reads (`get-internal-real-time` in `cpu-mcts.lisp` / `strategy-glue.lisp`) only feed the `duel mcfull` / `duel stratlayer`
    cost lines. The parity diff leaves those lines out; nothing in the sim reads a clock.
  - Cosmetics never touch the sim stream.
  - The native and wasm builds must agree bit for bit.
- **Browser.**
  - The wasm build must:
    - load from `index.html` + `index.js` + `index.wasm` (+ `manual.html`) as today, so the Artifact publish flow and its sha256 check stay
      the same;
    - run under `tools/run.mjs` (headless Chrome, `--fixed-dt`, `--script`, `--shot`, `--mobile`);
    - expose `Module._debug_cmd(n)` with the same integer codes (DUEL_GAMEPLAY "Debug commands"), so every `tests/scripts/*.json` drives
      it unchanged;
    - print the same console lines: the combat log `[tick] P1 …`, the hash lines and `=== …` markers.
  - The page shell may change; the PWA (`duel/web/pwa.js`, `sw.js`, the manifest) keeps working. Saved data (`soulduel.*` in localStorage, through
    `pwa.js`'s numeric `gamePage` get / set codes) keeps its protocol, so players' settings, bindings and learned fq tables carry over.
- **No asset files.** Meshes, clips, effects, glyphs and sound are generated by code or by data extracted from the frozen source (§5.2), as
  today. The baked HUD SDF atlas (`duel/hud-font/`) is already generated data.
- **Performance rules.** No per-frame heap allocation in the sim, draw or HUD hot paths (the Lisp 0 B/frame rule). Heavy startup work is
  split over frames so the page never freezes.
- **Bevy.** Pin one version for the whole port (0.20.1 is current on crates.io, 2026-11-26) and don't chase upgrades mid-port.

## 4. Architecture (the lead's call)

A Cargo workspace at `rs/`, one crate per job:

| Crate | Job | Depends on |
|---|---|---|
| `duel-sim` | The deterministic game: math, hit volumes, RNG, vpads, kits / moves, fighter, gauges, combat, round, core triangle, hazards, the CPU (perceive, core-ai, MCTS with full-sim rollouts, strategies, fq-online), practice's sim step, the hash line, the combat log, snapshots. Plain Rust, **no Bevy**. | `duel-data`, `libm` |
| `duel-data` | Generated tables extracted from the frozen Lisp (§5.2), checked in as generated Rust. | none |
| `duel-look` | Presentation that is pure data → data: rig FK, clip sampling and poses, bodies → meshes, FX shapes and envelopes, cinematic timelines, camera, the HUD's paint stream / layout / tweens, sound synthesis. Host-testable, **no Bevy**. | `duel-sim` (read only), `duel-data` |
| `duel-app` | The Bevy app: window / canvas, input (keys, touch deck, gamepad) → vpads, `FixedUpdate` at 60 Hz stepping `duel-sim`, renderers through Bevy's own rendering (the user: 「全部用 Bevy 繪圖」; the WGSL ported as Bevy `Material`s and render-graph nodes: toon, fx-toon, flame bloom, composite, the split grade cut, sky, HUD / UI), audio mixer, the debug-command / console bridge, `:load` steps. | the three above, `bevy` |
| `duel-tools` | Native CLIs: replay an input trace, cvc, combo trials, sp-costs, digest per tick, and the parity harness (§6). They replace `tools/simgate/*.lisp` at switch-over. | `duel-sim` |

- The sim keeps its own small ECS, matching `engine/lisp/ecs.lisp`: entities are ids, components are plain structs in arrays, and systems are
  functions. Iteration order equals spawn order, as in Lisp's `do-entities`. Bevy's ECS holds only presentation state.
- Lisp specials become explicit context structs. There are no hidden globals in the sim. The match state is one value that can be snapshot,
  restored and hashed; the MCTS's full-sim rollouts and `fulltest` need this.
- Kit hooks (`:pose :draw :hit :dmg-mult :tick :kikon-n :lv :hash …`) become per-kit function tables, and each kit keeps its own module
  (`yama/`, `ken/`, `ichigo/`, `hisagi/`), split by role as today (`-art -look -cine -ai`).

## 5. How the port is done (the lead's call)

### 5.1 Logic by hand, data by extraction
- Logic (functions, rules, hooks, AI, draw code) is ported by hand, file by file, in the Lisp MANIFEST order. Each Rust function names its
  Lisp source in a comment (`// port: duel/lisp/core-sim.lisp CORE-LATCH-STEP`), so a reviewer can diff the two.
- Data is never retyped:
  - `defmove`, `defkit`, `defstrike` / `defclip` / `defclip-mirror` keyframes;
  - bodies and props;
  - `defsound` parameters;
  - glyph polygons;
  - tuning `defparameter`s;
  - strategy / fuzzy Q tables;
  - stage, cinematic beat tables where they are data;
  - the debug range registry.

### 5.2 The extractor
- An ECL script (`tools/port/extract.lisp`) loads the frozen build unit (`build/duel/game-all.lisp` at `lisp-freeze`) on the host ECL.
- It walks the registries (kits, moves, clips, sounds, …) after load and writes `rs/duel-data/src/gen/*.rs` (or RON plus a loader; the
  builder decides). Writing the values after load means macros have already expanded and the values are exactly what the game used.
- The generated files are committed. Re-running the extractor at the tag must reproduce them byte for byte.
- Where data is code, for example a clip key computed by a function or a hook, the extractor flags it and it is ported by hand.

### 5.3 Floats
- `single-float` → `f32`, `double-float` → `f64`, exactly where Lisp has them. `pi` and literals without an `f0` suffix are doubles in ECL
  and promote. Mixed-type arithmetic follows CL's contagion rules.
- Transcendentals use the `libm` crate, a port of musl, on both the native and the wasm build. The answer key's native sim also uses musl.
- No FMA and no fast-math.
- Integer overflow: Lisp fixnums promote to bignums. Each counter's range is checked; the default is `i64` where a counter could pass `i32`.
- `round` follows CL's banker's rounding, which the hash line depends on.

## 6. Verification (the lead's call): the frozen build as the answer key

### 6.1 Answer key artefacts
Generated once from `lisp-freeze`, by `tools/port/oracle/`, and stored in the git-ignored `build/oracle/`. The generator is committed so the
key can be regenerated.

- **Input traces**: per-tick vpad states for both sides, plus per-tick hash lines and the combat log. Sources:
  - every `tests/scripts/*.json` scene that runs a match (recorded in the browser through a recording debug hook added only to a scratch
    copy of the frozen build, never committed to `duel/`, or in the native sim with scripted vpads);
  - seeded CPU vs CPU for every pairing of the four fighters, several seeds each;
  - the combo trials (`tools/simgate/trial.lisp`) and `sp-costs-check.py`.
- **Host-test expectations**: the 21 files of `tests/duel-rules/` (about 5k lines), ported as Rust tests with the same expected values.
- **FK tables**: per clip, per frame, every joint's world transform and the weapon tip. These are the reach checks (`tests/duel-rules/art.lisp`)
  generalised.
- **Look data**: per scene, the HUD paint stream and the FX / cinematic draw lists at chosen frames.
- **Stills**: every scenario of the looks gate (83 stills), plus the per-character still scripts and both aspect ratios.
- **Sound**: each synthesised sound's PCM.

### 6.2 Pass rules
| Layer | Pass |
|---|---|
| Sim | Per-tick hash lines and the combat log byte-identical over every input trace and seeded cvc |
| Host tests | Every ported check passes |
| FK / poses | Every joint within 1e-5 m / rad of the key (exact expected; any difference is investigated) |
| Draw lists, HUD paint stream, sound PCM | Equal to the key (float tolerance 1e-5) |
| Stills | Side-by-side sheets (Lisp \| Rust \| diff) per scenario. A scenario is flagged when SSIM < 0.98 (the builder may tune this number with the first sheets). The user's eyes are the final judge, since two renderers are never pixel-equal |
| Phone | `--mobile --size 390x844` scripts give the same log lines; touch tests ported |

- When the sim drifts, the per-tick digest (as `snaptest.lisp digest FILE` does today) finds the first divergent tick. The fix goes in Rust,
  never into the key.
- If something proves impossible to match bit for bit, such as a libm call that differs, it is written up with the evidence and brought to
  the user. It is not tolerated silently.

### 6.3 Gates per step
- Sim steps run the sim parity harness.
- Presentation steps run the FK / draw-list / still checks.
- Every step builds both the native and the wasm target and runs a `run.mjs` smoke with no JS / WebGPU error.

### 6.4 Performance
At M0, measure the frozen build's numbers, and remeasure at every milestone:
- native sim steps/s (cvc turbo);
- headless-browser frame time (SwiftShader: compare before and after only);
- startup time to the title;
- peak heap;
- `index.wasm` size (11.9 MB today).

Targets:
- sim steps/s at least 3× the Lisp native sim (a gate);
- browser frame time, startup and wasm size are measured and reported at every milestone against the frozen build, and any loss is
  explained. Losses from Bevy's rendering are accepted (the user's choice, §1); losses from the game's own code are not.

The user's Android + Chrome phone judges the feel: once at M0a, and again before switch-over.

## 7. Milestones (order confirmed by the user; contents are the lead's call)

Each milestone ends gated, committed and pushed, with a DEVLOG §. From M3 on, each milestone also publishes a **separate Rust playtest
Artifact** for the user; the current Lisp page stays as it is until switch-over.

| | Content | Gate |
|---|---|---|
| M0a | **Speed test** (the user: 「先測速再繼續」): a throwaway Bevy wasm page drawing one fighter's body (extracted or hand-built mesh) with the toon / ink shader through a Bevy `Material`, a stage floor and the HUD's text, next to the frozen build: startup to first frame, `index.wasm` size, frame time under `run.mjs`, and the user's Android + Chrome phone (the sim's speed is measured later, at M1) | The numbers and the page go to the user; the port continues on their word |
| M0 | `lisp-freeze` tag; extractor and answer key; baseline numbers; workspace with Bevy pinned; a wasm pipeline (`wasm-bindgen-cli`, `wasm-opt`) producing a blank Bevy canvas that `run.mjs` loads and `_debug_cmd` reaches | Extractor reproducible; key generated; blank page smoke |
| M1 | Sim core plus Kenpachi and Ichigo (all forms), driven by input traces, no CPU | Their CPU-free traces (scripted scenes, combo trials) hash-identical; their host tests pass. CPU matches wait for M2: the CPU draws from the sim stream, so its traces cannot replay without it |
| M2 | The CPU (perceive, core-ai, MCTS, strategies, fq tables, online learner) | cvc II / IK / KK identical to the `--cvc` output regenerated at `lisp-freeze` (the checked-in `tests/style-cvc-ref.txt` is dated 2026-11-18 and predates later shared-rule commits) and to the key's extra seeds |
| M3 | Presentation: bodies, rig, clips, poses, the toon / ink renderer, FX, stage, camera, cinematics, HUD and menus, sound, the touch deck. **First playable Artifact** (Kenpachi and Ichigo) | FK / draw lists / sound equal; stills sheets reviewed by the user |
| M4 | Hisagi, then Yamamoto: sim, CPU, looks, cinematics | All pairings' traces and cvc identical; their stills reviewed |
| M5 | Parity sweep: practice, every debug command the scripts use, the manual, the phone, performance targets | Every gate of §6; the user's playtest and phone check |
| M6 | Switch-over, **only after the user says so**: the tools, gates, skills, AGENTS.md and README point at `rs/`; the Lisp build moves to a branch `lisp-archive` (`duel/` and `engine/` leave `main`) | The user's go-ahead |

The milestones are large. The builder splits each into batches of one worktree and one subagent each (AGENTS.md "Big work"), ordered by the
MANIFEST dependency order.

## 7.1 Rebuild speed (the user, 2026-11-26: 「你能透過熱重載減少更改後的編譯時間嗎」; the lead's answer)

- Data and shaders hot-reload: the extracted data (moves, clips, tuning, bodies, sounds' parameters) is runtime-loaded data
  files (RON or a binary form, typed by serde, checked on load and by the tests), and the shaders are files. In development
  they are read from disk and reloaded on change (Bevy's `file_watcher`), so a number or a shader changes with no compile; the
  release page embeds them (`embedded_asset!` / `include_bytes!`), so it still ships as one page. This settles §5.2's
  "generated Rust or RON" toward data files.
- Code does not hot-patch: Bevy 0.20's `hotpatching` is native-only and experimental, and this machine has no display (every
  check runs in headless Chrome on wasm). Instead: `duel-sim` has no Bevy (its tests and the parity tools build in seconds);
  wasm development uses `--profile web-dev` (M0a measured: 95 s the first time, then about 1 s a change plus 3 s of
  wasm-bindgen, against 2 min 51 s a release build); native tests may use Bevy's `dynamic_linking`.
- The release page loads a gzip copy of the wasm (M0a: the Artifact serves binary files up to 15 MB and no `.gz`; Bevy's
  release wasm was 17.4 MB of code and data before the game's own).

## 8. Left to the builder

- Crate internals and module layout inside each crate, generated Rust vs RON, and naming.
- How each WGSL shader maps onto Bevy's rendering: a `Material`, a custom `SpecializedRenderPipeline` or a render-graph node (all inside
  Bevy's renderer, per the user's choice). Keep the shader code close to the original.
- The Bevy features compiled in (trim for wasm size).
- The audio backend under Bevy: a custom `Decodable` source or a mixer on `cpal`. The C mixer's rules stand: it never blocks and allocates
  nothing per buffer.
- How input traces are recorded from the frozen build, as long as the frozen source is untouched.
- Batch boundaries, and which batches run in parallel.
- Any CL-semantics helper needed (e.g. `cl_round`, `cl_truncate`, float contagion helpers) lives in one module, host-tested.

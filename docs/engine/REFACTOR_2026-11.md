# Refactor round 4 (2026-11): consistency, cohesion, leftovers, engine moves (audit and plan)

Status: **audit and plan only** (2026-11-10, from main fd9e7180). No code changed. Nothing here is decided until the user
answers the ⚠ questions in §6; the batches in §7 that need no decision can start as soon as the user says go. Earlier
rounds: `REFACTOR_2026-10.md` (round 1), `REFACTOR_2026-10-21.md` (round 2), `REFACTOR_2026-10-21-R3.md` (round 3),
the backlog `REFACTOR_NEXT.md` (its "Not to do" list still holds). DEVLOG §702.

## 1. Request

The user (2026-11-10), verbatim: 「請幫我開始對目前程式進行重構，確保設計上的一致性與「高內聚、低耦合」的軟體工程原則。還有移除與精簡掉在開發過程產生的冗餘程式，並將可以複用與模組化的功能轉移到遊戲引擎的設計中。」

Read as four aims: (A1) consistency of design, (A2) high cohesion / low coupling, (A3) remove and trim what development
left behind, (A4) move reusable, modular functionality into the engine (which must keep knowing no game).

## 2. Method

1. The auditor (Opus 5.5) measured the inventory (lines per area, object-code bytes per file from `build/duel/game-all.o`
   with `llvm-nm --size-sort`, a token scan for definitions named nowhere else) and read the earlier rounds.
2. Five read-only Sonnet 5.5 audits, one per area: the CPU stack; the shared sim systems; the character files; the
   presentation and the web page; the engine, tools and tests. Each returned `file:line - fact - action - risk`.
3. The auditor spot-checked the claims that carry a decision or a batch in the code (marked **[v]** below; **[a]** = the
   audit's claim, not re-checked by the auditor). Two audit claims were wrong and are corrected here: `ichigo.lisp:654`
   is a `cond` clause `(*core-on* nil)`, not a rebinding of `*core-on*`; "yama-vfx.lisp is shared infrastructure" is
   too strong: generic dispatchers call it, but only for Yamamoto's data (§5.3).
4. No build, gate or test run except `tests/debug-ranges-check.py` (read-only). No balance gate (standing rule).

## 3. Inventory (main fd9e7180)

Lines (`wc -l`). Object bytes = function code attributed to the file in `game-all.o` (4.47 MB of functions in an
8.9 MB object; `dist/duel/index.wasm` is 11.16 MB). Clip data (`defstrike`, compiled into the init function and the
constant string) is **not** in the byte column, so it is a lower bound; the real saving of a removal is only known from
a build without the code.

| area | files | lines | object bytes (functions) |
|---|---|---|---|
| engine/lisp | 19 | 5,454 | 347 KB |
| engine/c, shaders, web | 6 + 15 + 1 | 871 + 540 + 124 | – |
| shared sim (package tuning rules core control kit components fighter combat core-sim hazards flow sim-state main) | 14 | 6,668 | |
| live CPU (core-ai fuzzy strategy cpu-ki-ken cpu-ki-ichigo cpu-hisagi-range cpu-kh-ken cpu-hk-hisagi mcts-lite cpu-mcts hisagi-ai) | 11 | 6,539 | |
| old AI v2 + old learner + ASSIST (ai ai-learn learn assist scripted; ai.lisp and ai-learn.lisp also hold live parts, K3) | 5 | 2,367 | 180 KB |
| ENDLESS / DANGAI (endless endless-rules rogue rogue-rules run-mods) | 5 | 1,322 | 81 KB |
| debug + gate | 2 | 1,000 | |
| shared presentation (sounds body glyphs glyphs-extra brush cinema stage vfx vfx-stamps camera feedback hud hud-screens onehand webui webhud draw) | 17 | 6,640 | |
| Kenpachi / Ichigo / Hisagi (kit + art + look/draw/cine/stills + meter) | 4 / 3 / 5 | 4,194 / 3,798 / 8,283 | |
| **retired**: Yamamoto 3 files 2,230; Rukia 4 / 4,693; Senjumaru 2 / 2,553; Lille (`:barro` + the old Lille's art) 9 / 8,950 | 18 | **18,426 (31 % of duel/lisp)** | **976 KB (22 % of all function code)** |
| duel/lisp total | 84 | 59,237 | |
| duel/web (menu.js hud.js pwa.js sw.js alpha.js head.html css manual.html) | 10 + icons | 2,952 | – |
| tools (+ tools/simgate) | 31 + 14 | 2,734 + 1,201 | – |
| tests (+ duel-rules, scripts) | 31 + 17 + 52 | 4,344 + 5,649 + 1,151 | – |

Character code counted per character with its CPU files: active 18,825 lines, retired 18,426 [a, sum v]. A token scan
(strings and comments stripped) finds only 34 definitions named once in game code; past rounds left little orphan code,
so the leftovers are whole systems, not stray functions [v].

## 4. Findings by aim

### 4.1 Consistency (A1)

- **C1 Kit plug-in, four mechanisms for one job** [a]. `kit` struct (~75 slots, kit.lisp:284-333) holds data and four
  hooks as slots (`:enter-hook :exit-hook :crush-hook :bankai-ok`, called at combat.lisp:815, 822, 319, 897 and
  ai.lisp:790); everything else goes through the `:hooks` plist (`kit-hook`, kit.lisp:414); meters through
  `:meter (:draw :label)`; debug through `*char-debug*` (kit.lisp:418). About 37 hook points are called, the `defkit`
  docstring (kit.lisp:659-680) lists about 24 (undocumented: `:soul-break-cine :unscaled :step-dist :siphon :lv
  :kikon-worth :hud-tag :hit-fx :dmg-mult :armor :as-pick :link-ok :pose :boss :base`). `:exit-hook` and `:crush-hook`
  are set only by retired kits.
- **C2 "Is this a core kit"** is asked two ways [a]: `(kit-core kit)` (fighter.lisp:587, combat.lisp:819, 929,
  ai.lisp:1305, hud.lisp:803, onehand.lisp:210) and `(and *core-on* (kit-core kit))` (hud.lisp:446, 605,
  core-sim.lisp:278, 356, kit.lisp:437). `*core-on*` (tuning.lisp:675) is a test toggle; Ichigo's clone code tests it
  in `cond` clauses (ichigo.lisp:654, 741, 821, 1071, 1076) [v]. Folding the two needs a check of who binds it NIL.
- **C3 Knobs outside the rule** (AGENTS: shared knobs in tuning.lisp, a character's own in its file) [a]:
  shared knobs elsewhere: core.lisp:37, 50, 51 (`*core-pointer-max* *core-kikon-max* *core-soul-break-max*`),
  fighter.lisp:278 `*behind-turn*`, combat.lisp:145 `*delay-hit-hold*`. Character knobs in tuning.lisp: Kenpachi's
  (tuning.lisp:429-437) and Rukia's (§5 block, ~151 knobs from line ~405, mostly for retired characters). Four NOME
  knobs are dead: `*nome-max* *nome-up-t2* *nome-down-t2* *nome-down-t3*` (tuning.lisp:434-437, named nowhere else) [v];
  `*ai-ru-l-after-k*` (tuning.lisp:553) likewise [v]. About 97 of 354 tuning knobs carry no date / who / § in the
  docstring [a, regex only].
- **C4 Debug registration, three ways, and it drifted** [v]. The `cond` in `debug-command` (debug.lisp:550-660, ~105
  clauses), `*char-debug*` triples pushed by hand in each character file (`pushnew ... :test #'equal`, ken.lisp:1063,
  1167; ichigo.lisp:1181, 1279; hisagi.lisp:1481; hisagi-stills.lisp ×11; barro.lisp:1711; rukia.lisp:821;
  senjumaru.lisp:1364), gate commands in the same `cond`. `python3 tests/debug-ranges-check.py` today: **1 error**,
  `(<= 2510 c 2513)` (debug.lisp:646) is consulted before `(= c 2513)` (debug.lisp:647), so 2513's slow motion never
  runs. Kenpachi's `(84000 84099 ken-core-debug)` (ken.lisp:1167) shadows DANGAI's `84000+100c+n` for c = 0
  (DUEL_GAMEPLAY lists both) [a]. Round 2's rule (N1) was "a registry only if the table drifts again"; it has drifted
  twice, and the checker existed but was not run (§6 D7).
- **C5 Character file layout** [a]. Only Hisagi follows the split by role fully (kit / -ai / -art / -draw / -cine /
  -stills). Kenpachi: art in one 2,607-line file, cinematics in ken.lisp (512-777), look in ken-look. Ichigo:
  ichigo-look.lisp (1,197) holds looks, hooks, sounds, glyphs and the cinematics. The DUEL_DESIGN section
  "Character code layout" (DUEL_DESIGN.md ~1100) names only `<name>.lisp` + `<name>-art.lisp`; the role suffixes live
  in the MANIFEST header. Matchup CPU files are `cpu-<pair>-<char>`, a second naming. Meters: two in own files
  (ken-meter, rukia-meter), the others in the kit file.
- **C6 Kit definition style** [a]. Hooks inline (ken.lisp:188, 206) vs named variables (`*ichigo-hooks*`,
  `*hs-hooks*`); the same concept as `:l-after-k` (Ichigo) and `:l-after-j` (Hisagi); `defmove-copy` + `:params`
  (Kenpachi) vs knob variables in `defmove` (Hisagi) vs literals (Ichigo).
- **C7 The page bridge, written twice** [a]. `webui-commands` (webui.lisp:73-101) and `webhud-commands`
  (webhud.lisp:240-256) are the same decoder (`screen*100000 + cmd*1000 + arg`); the HUD's hard-codes screen 7
  (webhud.lisp:249, hud.js:53). JS `send / queue / get / set` copied in menu.js:54-64 and hud.js:53-60. pwa.js:64-102
  routes eight slot ranges with an if-ladder documented only in its header. The roster is hard-coded on the page twice
  (hud.js:14-24 six fighters with retired ones; menu.js:22-27 three, `CARDS=[1,3,7]`, "3 PLAYABLE" at menu.js:94)
  next to Lisp's `*roster*` / `playable-roster`. sw.js's cached `FILES` list is hand-written (sw.js:11-12).
- **C8 Doc drift** [v]. RAVEN EDGE (`game/`) was removed 2026-10-27 (DEVLOG §409), but ARCHITECTURE.md still describes
  it (21 mentions: title, the game/ module table, `tests/rules-test.lisp`), ENGINE_API.md (9; "Two games use it"),
  engine comments (body.lisp, anim.lisp, render.lisp, render.c: "RAVEN defaults"), engine-check.lisp strings, two
  skills; `docs/README.md` links three deleted `docs/raven-edge/*` files. ENGINE_API.md lacks about 95 exports (most
  of touch.lisp, `gc-*`, `page-get/set`, snapshot) [a]. `sim-state.lisp:2` says "Nothing in play calls these", false
  since the in-game MCTS (cpu-mcts.lisp:229-257, 323-340) [v comment, a call sites]. `*strat-lookup*`'s docstring
  (strategy.lisp:2798-2823) is a 20-line history that DUEL_AI_STRATEGY §8 already holds [v].

### 4.2 Cohesion and coupling (A2)

- **K1 Generic files that name a character** [a; v for the yama-vfx sites]. fighter, combat, core-sim, hazards (code),
  rules, core, ai, core-ai, onehand, hud, camera: clean. Not clean:
  - gate.lisp:46 `(eq ... :rukia)`, :83 `:kenpachi`, :133-137 `*pairs-0*`, :188 five `<char>-acc-line` calls.
  - draw.lisp:79 `*hurt-cines*` (yama-kikon, yama-tenchi, ken- cinematics); brush.lisp:408 `*brush-names*` seeded with
    three names, appended by four kit files at load (barro.lisp:893, hisagi-draw.lisp:1856, ichigo-look.lisp:598,
    senjumaru.lisp:311), read only by cinema.lisp:336.
  - feedback.lisp:219-233 `:ken-bk-burst` (Kenpachi) and :122 `:cold-crack` (Rukia) inside the generic event `case`
    (feedback.lisp:62, 187 lines).
  - draw.lisp:160-265, feedback.lisp:98-120, 195, hazards.lisp:193-209, vfx-stamps.lisp (`%st-ember` and nine more) call
    yama-vfx.lisp, keyed by Yamamoto's data (`:fire :embers :charcoal :garb :skeleton-rise`). A grep of the live kits'
    files for those keys finds nothing [v], so this is Yamamoto's look reached through generic dispatch, removable with
    him (D1), not shared infrastructure.
  - webhud.lisp:111-114: a Kenpachi-named block (cup, arm pips) in the generic `webhud-side` (behind kit data).
  - Data keyed by character, legitimate: flow.lisp:27 `*picks*`, `*strat-lookup*`, mcts-lite.lisp:33-60,
    cpu-mcts.lisp:21 `*mc-off-at*`.
- **K2 Live character to character** [v hem, a rest]. Ichigo's (and Rukia's) hem uses Yamamoto's spring
  `%ya-hem-pose` / `%ya-hem-step` (yama-art.lisp:227-290; ichigo-look.lisp:254, 514; rukia-art.lisp:787-788): a live
  kit depends on a retired kit's file. ken-look.lisp:76-179 calls Ichigo's `%ic-far %ic-frame %ic-held-tip %ic-track`.
  hisagi.lisp:912 calls `ichigo-pull-to`. The matchup CPU files read each other: cpu-ki-ichigo.lisp:110-142 →
  cpu-ki-ken's `kk-read kk-ns-whiff kk-wave-plan`; cpu-hisagi-range.lisp:177 → `ken-ki-style`; cpu-hk-hisagi.lisp:33 →
  `*kk-hend-p*`.
- **K3 The CPU stack's seams** [a; v the first line].
  - `brain-step` (ai.lisp:1303) returns at once to `core-brain-step` for a `:core` kit (ai.lisp:1305) [v]; the live
    path still uses ~350 lines of ai.lisp (snap ring ai.lisp:91-195, `ai-press`/`ai-dash` 287-296, `ai-step` with
    `:strafe :walk :event-rolls`, `brain-perceive` 1204, `brain-system` 1359); the other ~1,000 lines (the AI v2
    reflex / decide stack and its 90-line header) run only for retired kits.
  - ai-learn.lisp mixes the **live** FQ online learner (ai-learn.lisp:64-142, saved as `soulduel.fq.<me>.<vs>`) with the
    **frozen** old learner (143-375). They are two different learners.
  - core-ai.lisp hosts strategy glue (`strat-reach :51 strat-feats :53 strat-form-index :65 strat-xfeats :69
    strat-switch-step :223 strat-event-step :265 strat-hold-awaken-p :207`) while strategy.lisp is pure; core-ai ↔
    cpu-mcts call each other (resolved by load order and a bare `(defvar *in-rollout*)` at core-ai.lisp:214, valued at
    cpu-mcts.lisp:44).
  - Hidden channels: `*strat-now*` (bound in core-ai, read in strategy.lisp:50, cpu-mcts.lisp:117, core-ai.lisp:41,
    the hisagi style files); `*mc-plan*` / `*mc-next*` written by cpu-hisagi-range.lisp; the rollout's special
    bindings written twice (sim-state.lisp `sim-rollout` and cpu-mcts.lisp:209-211 `mc-full-rollout`), so a new log
    special must be added in two places or a rollout pollutes the match.
  - Six "reach of a move" helpers with different margins (`strat-reach` core-ai.lisp:51, `mv-min-reach` :103,
    `kk-reach` / `kk-reach-of` / `kk-link-reach` cpu-ki-ken.lisp:377, 582, 700, `mc-move-rec` mcts-lite.lisp:82); four
    bandit / UCT flavours (mcts-lite fixnum UCB, `strat-puct`, the old learner's bandit, FQ TD).
  - The `brain` component (components.lisp:198-240) has ~40 slots, ~20 of them strategy / learner state.
- **K4 The sim reads a device** [v]. `core-held-p` (core-sim.lisp:266-269) reads `*touch*` through
  `core-touch-sp-p` (core-sim.lisp:259-263) inside the 60 Hz step, beside the vpad. Device state should enter the
  sim only through the vpad (ARCHITECTURE "Input, randomness"). The native sim never sees it (no `*one-hand*`), so G2
  cannot catch a change; a phone script can.
- **K5 Files with several jobs** [a]. control.lisp (vpad actions, command table, bindings, rebinding, the SETTINGS table,
  one-hand rules, practice dummy); kit.lisp (hit volumes and move geometry 25-135, `parse-move` / `defmove`, the kit
  struct, roster, cadence, core class building); components.lisp (components + pacing / combat logs + input device
  globals 313-317); fighter.lisp:88-141 DANGAI helpers. Function length is not the problem: the longest sim function
  is `debug-command` (111 lines).
- **K6 Frozen-mode state read by the generic sim** [a]: `*run-mods*` branches at 14 combat.lisp sites and
  fighter.lisp:88-141, 334, 433, 448, 585, 1165; `*run-boss*` read in 11 files.
- **K7 Draw mutates the sim and restores it** [a]: main.lisp:64-121 (slow-motion smoothing writes positions, anim time
  and hazard positions for the draw and puts them back). Safe only because the draw is single-threaded. Leave
  (looks-sensitive), noted for the record.

### 4.3 Redundant code (A3)

Decision-free (dead or superseded with no user stake):
- **R-a** The 2513 clause (C4), the four dead NOME knobs and `*ai-ru-l-after-k*` (C3), the false comment (C8).
- **R-b** Engine exports with no caller anywhere: `fx-debris`, `fx-debris-update` and their pool (fx.lisp:320-379)
  [v: only defined and exported], `edge-vignette` (fx.lisp:472), `mb-capsule` / `mb-flat-quad` (meshgen.lisp:246,
  351), `set-loop-gain` / `audio-locked-p` (audio.lisp:418, 464), `fx-clear-orbs` export [a]. About 20 exports used only
  inside the engine or in tests could be unexported [a].
- **R-c** Tools duplicating each other [a]: `sha / build_hash / run_job / parse` in strategy-eval.py:35-113 and
  strategy-switch.py:37-183 (and a third `parse` in matchup-eval.py:45); the four-line Lisp runner prelude copied in
  nine files (tools/simgate/{run,run-log,run-situ,strat-desc,strat-run,trial,contact,teacher}.lisp,
  tools/roguegate/run.lisp); assistgate.py and strategy-matrix.py never call `build()` (the stale-build class that cost
  round 5 step 11, DEVLOG §700).
- **R-d** Canvas-HUD widgets of the old fight system (L refusal / cooldowns, U tag, non-core KOSEI, AUTO tag, the
  bind-pool tally: hud.lisp:219-404, 784-793, ~70 lines) [a]: they die with the retired kits (D1) or the fallback (D5).

Decisions (each ⚠ in §6; sizes from §3):
- **D1 The four retired kits and the old system that only they use**: 18,426 lines of character code, plus the AI v2
  stack (~1,000 lines of ai.lisp), and the old-system mechanics in shared files that run only for a kit with no `:core`
  (frost / cold, pips, ward / pierce / drink / hellfire, breaker, U guard, K / L strings: an estimated 600-900 lines in
  rules / fighter / combat / kit / hud / gate, tuning §5's ~151 knobs) [a], the generic dispatch to yama-vfx (K1),
  manual.html's retired chapters (~350 lines) and the canvas widgets of R-d. The support cannot go while the kits stay,
  so it is one question.
- **D2 Frozen modes**: ENDLESS / DANGAI 1,322 lines + `*run-mods*` / `*run-boss*` branches + tests (rogue.lisp 245,
  runmods.lisp 48) + roguegate; ASSIST (assist.lisp 232, assistgate.py, the AUTO tag) and the **old** learner
  (learn.lisp 313, ai-learn.lisp 143-375, learn-test.lisp 242, `learn-attach!` attaching it to a core P2 at
  flow.lisp:199 where `core-brain-step` never reads it). **Not** the FQ online learner: it and its SETTINGS row are live
  (since 2026-11-09). The menu rows of ENDLESS / DANGAI are hidden already (flow.lisp:364-367); only debug commands
  reach them.
- **D3 The strategy library's unnamed entries**: 37 entries in `*strat-library*` (strategy.lisp:539-2780, 2,234 lines);
  9 are named by `*strat-lookup*` (749 lines) [v: 9 tables, all `:hard`]; 19 superseded Q tables and 9 seed / code
  entries (~1,485 lines) plus the arms `a-hk-wake / -pot / -kite / -all`, data units `d-hk-*`, and the style
  `st-hisagi-hk` (cpu-hk-hisagi.lisp, 143 lines) are named by no table [a]. The user decided today that these "stay in
  the library" (DEVLOG §701). The FQ save format does not depend on the library: `fq-checksum` (strategy.lisp:180)
  covers only the live table's own q values, and the page key is the roster index pair [v].
- **D4 The canvas HUD / menu fallback** (~850 lines: hud.lisp 147-572, 574-718, 786-826; hud-screens.lisp 7-205;
  onehand.lisp 321-393) [a]. DUEL_WEBUI §1 kept it deliberately for a page without hud.js / menu.js. No gate sees it:
  `tools/run.mjs` saves `Page.captureScreenshot` (the whole page, HTML on) and no script, URL flag or test turns the
  HTML layer off [v]. An unseen path rots.
- **D5 manual.html**: ~500 of 1,088 lines describe the old system (`#strings` to `#blow`, 373-465), the retired
  characters (484-565, 640-742, 807-883, 884-971) and the frozen modes (197-252); the header still says 「七個角色」
  (:131) [a].
- **D6 tracked review stills and old style scripts**: tests/shots has 317 tracked files, 106 MB on disk (241 duel-*,
  35 mobile-*, 23 batch-*, 14 webgl-*, 3 style-*, 1 practice-*) [v]; tests/style-2..6-shots/-checks.py, style-shots.py,
  batch-shots.py (~1,290 lines) are called by no tool or test, only cited by STYLE_STORM_DESIGN, the
  procedural-ink-style reference and the tutorial [a].
- Research tools stay where they are (strategy-*, teach-*, combo-trial, *-sheet, tools/simgate/{strat-*, litefit,
  teacher, trial, run-log}): the dream-rsi workspaces under docs/research call them by path. They only need a row in
  AGENTS' tool table (no decision).

### 4.4 Move to the engine (A4)

The engine already owns most of what the request names: the snapshot walker (snapshot.lisp; the game registers roots in
sim-state.lisp), both RNG streams (`rnd01`, `sim-rnd01`, C xorshift), the fixed step (`run-fixed-steps`, time.lisp:64),
hit stop / slow motion, the vpad with its press buffer and modifier (input.lisp), the touch gesture recogniser
(touch.lisp), the cinematic director (cine.lisp), the toon shapes and trails (fx-shapes, fx, render `fx-trail`). The
engine's game knowledge is in comments and docs only (RAVEN, C8) plus three SOUL DUEL palette names baked with a shader
(fx-shapes.lisp:15-17, fx-toon-pal.wgsl; leave). What is left to move is small:

| candidate | now | generic part → engine | stays in the game | risk |
|---|---|---|---|---|
| E1 fuzzy inference | duel/lisp/fuzzy.lisp:41-66 | `engine/lisp/fuzzy.lisp`: `fuzzy-mu (x a b c d)`, `fuzzy-infer (rules feats default)`, `fuzzy-chance`; ~25 lines | the sets (`*fz-sets*`), the rule bases, `*fz-skill*` | low: pure arithmetic, host-tested (tests/duel-rules/fuzzy.lisp); G2 decides |
| E2 secondary-motion spring (hem) | yama-art.lisp:227-290 (`%ya-hem-pose/-step`, 5 knobs), used by Ichigo | `engine/lisp/anim.lisp`: `spring-chain-step (st o dt k c drag turn max)`, `spring-chain-pose (joints st o on)` | the knob values, which joints | low if the arithmetic is moved verbatim (float order); looks (Ichigo stills, `ichigo-awaken`, `ichigo-clones`) |
| E3 key / pad rebinding | control.lisp:61-131 (`rebind reset-bindings bind-code bind-from-code binding-input`) | `engine/lisp/input.lisp` beside `vpad-read!`, over (pair action device name) | the default bindings, `*bind-actions*` | low: pure, host-tested (duel-control-test) |
| E4 settings row table | control.lisp:151-176 (`setting setting-value setting-from-page`) | `engine/lisp/ui.lisp` or `platform.lisp`: `defsettings`, the page slot mapping | the rows | low |
| E5 earmuffed data resolution | kit.lisp:13-23 (`resolve-tuning`, `tuning-ref-p`) | engine package utilities | – | low |
| E6 debug range registry (if D7 = registry) | debug.lisp `cond` + `*char-debug*` | `engine/lisp/app.lisp`: `(define-debug-range lo hi fn "doc")`, declaration order = dispatch order, overlap error at load | every range and its handler | medium: order decides ownership; G2 + the cvc scripts drive debug commands |
| E7 page bridge helper | webui.lisp:30, webhud.lisp:19-31 + menu.js / hud.js | `engine/lisp/platform.lisp`: a change-compare `page-put` over a fixnum cache (0 B, debug 2515 measures it) + `engine/web/page.js` (`registerPage(lo, hi, handlers)`) | slot meanings, the `soulduel.*` storage prefix (must stay, or saved data is lost) | medium: smoke + browser scripts; do with B7 |

Not worth moving (churn without benefit, or high pixel / determinism risk with no second game to use it):
`strat-puct` / `strat-final` (research only, the strategy layer is off in the game); mcts-lite's fixnum UCB (tangled with
its 10 actions and slot-indexed vectors; G2 bit risk); the extra RNGs (`mc-rand`, `fq-u01`; must stay bit-identical and
inside their own state); the brush / glyph toolkit and its triangulator (looks risk HIGH, triangulation order is the
pixels); the vfx stamp pool as an engine `defpool` (HIGH); camera rigs (`%pow2` / `%atan2-d` match ECL's rounding,
HIGH); `cinema.lisp` into `cine.lisp` (it takes fighters); the state hash line (its text is G2); trail / chain / ring
unification across characters (each is its own look on engine primitives that already exist).

## 5. Proofs (unchanged bar, by kind)

- **Pure move** (split, reorder, rename inside DUEL): `tools/unit-forms.lisp` on `build/duel/game-all.lisp` BASE vs NEW:
  `only in base 0 / only in new 0`, the order list unchanged; looks 113 stills byte-identical (BASE = a copy of
  `dist/duel` built at the parent); G2 identical; host tests; pkgcheck; build with 0 warnings.
- **Behaviour-neutral rewrite** (a helper, a hook instead of a slot, one decoder): unit-forms with the new macros
  expanded where it applies (else the exact form diff in the commit message); G2 identical; host tests; looks 113.
  Helpers expand to the text they replace (REFACTOR_2026-10 §8); no `sim-rnd01` moves into or out of a helper.
- **Move into ENGINE**: a package change breaks unit-forms EQUAL, so G2 + host tests + looks 113 + pkgcheck (it catches
  an unexported name). Before moving, grep for names that reach a string (`pace` keys, `ic-key`, `intern` / `format`,
  the state-hash line, `symbol-name`).
- **Removal**: pkgcheck (dangling calls), build 0 warnings, host tests minus the removed suites, **G2 identical** (its
  pairs II IK KK use no retired kit and no frozen mode, so an unchanged G2 proves the live path did not move), the looks
  stills that survive byte-identical against BASE, the removed stills replaced and the new set recorded as the
  reference (every quote of "113" updated), smoke's startup heap and `index.wasm` size before / after (the measurable
  benefit; not measured yet).
- Wait rules for every brief: bounded waits on a PID or a notification only; never `pkill -f` / `pgrep -f`; no balance
  gates; subagents never commit, push or deploy.

## 6. ⚠ Decisions for the user

**⚠ D1 The four retired kits (Yamamoto, Rukia, Senjumaru, Lille) and the old system only they use.**
Size: 18,426 lines in 18 files + ~1,000 lines of AI v2 + an estimated 600-900 lines of old mechanics in shared files +
~151 tuning knobs; ≥ 976 KB of object code (function bytes only). Removal costs: about 66 of the 113 looks stills
re-pinned (all four cvc scenarios YS / HY / IR / BK = 29 stills, the yama / rukia / senju / barro cinematic sets,
fx-a's three Yamamoto stills, fx-b's nine, mobile's three Senjumaru stills) and every quote of "113"; ~500 host checks
leave with tests/duel-rules/{barro,rukia,senjumaru,yama}.lisp; tests/scripts' Yamamoto / Rukia scripts regenerated over
live pairs; manual chapters; DUEL_GAMEPLAY's retired debug ranges. Kept either way: the roster indices (`*roster*`
order, stub kits like `:lille`), simgate's `RETIRED` / `PAIRS`, the saved-data keys (learn tables, ENDLESS slots,
`soulduel.fq.<me>.<vs>`), and the ability to port a frozen fighter back (the `duel-character` skill's port path reads
the code from the branch). Prerequisite: Ichigo's hem spring leaves yama-art.lisp first (B3).
Options:
1. **Archive to a branch `retired-kits` and remove from main** (recommended; the repo's own precedent: the Babylon port
   moved to branch `babylon` on 2026-10-27, RAVEN EDGE was removed in §409). Biggest cut; G2 proves the live path.
2. Keep the code in main but out of the shipped build (a second MANIFEST target for tests only): smaller wasm, but every
   shared-file change must still compile and test against them.
3. Keep everything as it is (no cost now; the shared files stay ~30 % larger than the live game needs).
**Decided (the user, 2026-11-10):** 「封存到分支後移出 main (Recommended)」. Consequence: option 1. Archive the four kits and the
old system only they use to the branch `retired-kits`, then remove them from main (B8). Roster indices (`*roster*` order, stub
kits like `:lille`), simgate's `RETIRED` / `PAIRS` and the saved-data keys stay. The old AI v2 goes once D1 frees it.

**⚠ D2 The frozen modes: ENDLESS / DANGAI, ASSIST and the old learner (not the FQ online learner, which stays).**
Size: 1,322 + 232 + ~545 lines (+ scripted.lisp's ASSIST / gate players if nothing else uses them), ≥ 81 KB (ENDLESS /
DANGAI) + 18 KB (assist) + 16 KB (learn) + part of ai-learn's 40 KB of object code; 14 `*run-mods*` sites in combat.lisp and the fighter.lisp DANGAI helpers; tests rogue.lisp / runmods.lisp /
learn-test.lisp; tools roguegate.py / assistgate.py; the ENDLESS looks scenario (4 stills); debug ranges 80000-80999,
81000-81200, 84000-84999 (which also clears the 84000 double claim). Saved-data keys stay reserved.
Options:
1. **Archive to the same branch and remove from main** (recommended; the menus already hide ENDLESS / DANGAI).
2. Remove only ENDLESS / DANGAI, keep ASSIST and the old learner frozen.
3. Keep all frozen as now.
**Decided (the user, 2026-11-10):** 「全部封存後移除 (Recommended)」. Consequence: option 1. ENDLESS / DANGAI, ASSIST and the old learner
are archived (the same branch) and removed from main (B9), together with the old AI v2 once D1 has freed it. The FQ online
learner stays. Saved-data keys stay reserved. This also clears the 84000 double claim.

**⚠ D3 The strategy library's entries that no table names** (19 superseded Q tables, 9 seeds, the `a-hk-*` arms,
`d-hk-*`, `st-hisagi-hk`: ~1,630 lines). Today's decision (DEVLOG §701): "the multi-rule arms stay in the library".
Options:
1. **Keep them, but in an archive file that only tools and tests load** (e.g. `tools/simgate/strat-archive.lisp`,
   loaded by strat-run / strat-desc and tests/duel-rules/strategy.lisp) (recommended: it keeps §701's library for every
   research run and takes ~1,600 lines out of the shipped wasm; saved FQ tables are unaffected, `fq-checksum` covers
   only the live table).
2. Keep them in the game as now.
3. Delete them (git history keeps them).
**Decided (the user, 2026-11-10):** 「留在遊戲裡」. Consequence: the library's unused entries (superseded Q tables, seeds, the
`a-hk-*` arms, `d-hk-*`, `st-hisagi-hk`) stay in the game as they are; **B10 is dropped** (no strategy archive file).

**⚠ D4 The canvas HUD and menu fallback** (~850 lines, kept on purpose by DUEL_WEBUI §1; no gate draws it).
Options:
1. **Remove it after D1** (recommended: the page and the wasm are built and cached together, and an unseen fallback rots;
   `hud-world`, `hud-rush-lines`, `hud-hint` stay).
2. Keep it and add a looks scenario with the HTML layer off, so a gate sees it.
3. Keep it as is.
**Decided (the user, 2026-11-10), in order:**
1. 「移除，順便向你參考，如果要將 html 的 HUD 完全移植成 lisp 版本是可行的嗎？成本會有多高？」 Removal chosen, held for the
   feasibility answer.
2. After the main session's estimate of a Lisp port (a full port about 8-12k lines; the blocker is arbitrary zh-TW text;
   recommendation: stay HTML and remove the fallback): 「移除」.
3. Then: 「等等完成一個段落後先暫停，我希望使用 lisp 完全重現目前的 html HUD」.
**Status: DONE (2026-11-11).** The user: 「將 lisp 版設為預設並移除 html」, then 「舊的 Canvas HUD 也移除」: the Lisp HUD
became the only renderer and the canvas battle HUD, its menus, its pause and the one-hand deck's drawing were removed in the same
batch (docs/duel/DUEL_LISP_HUD.md §16.6). What stayed: `hud-world` (the red soul flame), `hud-rush-lines`, `hud-hint`, the big
words, the cinematics' letterbox and captions, the stick ring, and the frozen modes' and retired kits' canvas pieces listed in
§16.6 for D1 / D2. (Before: ON HOLD; the canvas path was the Lisp-side starting point of the Lisp HUD, DEVLOG §704.) Refactor round 4 pauses after wave 0 and the first
merged batches; B2, B3, B4, B6 and waves 2-3 (including the removals D1 / D2) are not started.

**⚠ D5 manual.html's old-system, retired-character and frozen-mode sections (~500 of 1,088 lines).**
Options: 1. **Remove them with D1 / D2 and fix the header and TOC** (recommended); 2. fold them under a closed
`<details>` 「舊版參考」; 3. keep.
**Decided (the user, 2026-11-10):** 「這三項都按你建議的去做」 (D5, D6 and D7 together, after the main session explained its
three recommendations): option 1. The manual's old-system, retired-character and frozen-mode sections are removed together
with D1 / D2 (header and TOC fixed then); done when the refactor resumes, after D1 / D2, not now.

**⚠ D6 Tracked review stills and the old style scripts** (317 tracked stills, 106 MB on disk; ~1,290 lines of
style-2..6 / batch scripts no tool calls).
Options: 1. **Untrack batch-* and webgl-* (37 files) and move the style-2..6 / batch scripts to
`docs/research/style-history/`, keep duel-* / mobile-* that docs cite** (recommended); 2. untrack every still the
gates do not read; 3. keep.
**Decided (the user, 2026-11-10):** 「這三項都按你建議的去做」: option 1. Untrack the 37 batch-* and webgl-* stills that no
gate reads and move the style-2..6 / batch scripts to `docs/research/style-history/`; duel-* / mobile-* that docs cite stay.
Done when the refactor resumes.

**⚠ D7 Debug commands: a registry, or keep the checker** (round 2's 「檢查程式」, with "a registry only if the table drifts
again"; it drifted twice: 2513, 84000).
Options: 1. **A registry (`define-debug-range`, in the engine; overlaps fail at load) replacing the `cond` and
`*char-debug*`; keep the doc checker** (recommended); 2. keep the checker and run it in every gate pass (add it to
AGENTS' fast checks); 3. leave as is.
**Decided (the user, 2026-11-10):** 「這三項都按你建議的去做」: option 1. A `define-debug-range` registry in the engine
(an overlap fails at load) replaces the `cond` and `*char-debug*`; the doc checker stays. Done when the refactor resumes.

## 7. Batch plan

Merge serialization points: `duel/MANIFEST`, `kit.lisp`, `debug.lisp`, `tuning.lisp`, `tests/duel-rules-test.lisp` and
`tests/style-gates.py`. No two batches of one wave edit the same one; when a wave has two MANIFEST edits, the lead (the main session)
merges them one after another. Each batch: its own worktree + branch + fresh subagent, a compact brief with the wait
rules; the lead re-runs the bar on the merged head, commits and pushes.

### Wave 0 (no decision; start at once) [B0 merged, B5 merged]

| batch | scope | proof | size | risk | model |
|---|---|---|---|---|---|
| **B0 fixes and doc drift** | 2513: decide its owner and renumber the other (debug.lisp:646 says "SP pointer 1 / 2 / 3 / 4", 2513 = pointer 4; the core pointer is 1–3 and no script or doc found uses 2511–2513, only 2510, so narrowing to `(<= 2510 c 2512)` looks right, but confirm no fighter has a fourth pointer first); DUEL_GAMEPLAY's 84000 note; sim-state.lisp:2 comment; dead knobs `*nome-max* *nome-up-t2* *nome-down-t2* *nome-down-t3* *ai-ru-l-after-k*`; `*strat-lookup*` docstring cut to 3 lines + § ref; ARCHITECTURE.md rewritten for one game (drop the game/ table, RAVEN G1, `tests/rules-test.lisp`); docs/README.md's three dead raven-edge links; engine comments / engine-check strings "RAVEN defaults" → "the default look"; the two skills' RAVEN lines | debug-ranges-check 0 errors; host tests; pkgcheck; build; G2 identical; looks 113 identical | ~150 code/doc lines + ARCHITECTURE rewrite | low | Sonnet |

### Wave 1 (no decision; parallel, disjoint files; after B0 merges) [B1 held back, B5 merged, B2 / B3 / B4 / B6 not started]

| batch | scope (files) | proof | size | risk | model |
|---|---|---|---|---|---|
| **B1 engine dead exports + API doc** | engine/lisp/{fx,meshgen,audio,package}.lisp (R-b), docs/engine/ENGINE_API.md (RAVEN lines, ~95 missing exports: a table per area, touch.lisp included) | removal: pkgcheck, build, looks 113, ecs / test-math / input / touch / cine tests, engine-check | −150 lines, +~120 doc | low | Sonnet |
| **B2 kit plug-in consistency (live and shared parts only)** | kit.lisp (hook-point table in the `defkit` docstring, checked against a grep), `def-char-debug` macro used by ken.lisp / ichigo.lisp / hisagi.lisp / hisagi-stills.lisp (retired files wait for D1), shared knobs core.lisp / fighter.lisp / combat.lisp → tuning.lisp, `core-kit-p` only if nothing binds `*core-on*` NIL outside tests (else leave), `:l-after-k` / `:l-after-j` one name if the CPU readers allow, `ichigo-pull-to` (ichigo.lisp:472, called at hisagi.lisp:912) → a generic pull in fighter.lisp if its body names nothing of Ichigo | unit-forms (knob moves EQUAL, macro expanded), G2, host tests, debug-ranges-check taught the macro | ~200 lines touched | low-medium | Opus |
| **B3 live cross-character coupling (duel package only)** | the hem spring (`%ya-hem-pose/-step` and its five knobs, yama-art.lisp:227-290) moved **verbatim, names kept**, to a new shared duel file loaded before ichigo-look and rukia-art (no call site changes, no retired-file edit); Ichigo's weapon-tip tracker (`%ic-far %ic-frame %ic-held-tip %ic-track`) moved the same way to a shared duel file before ken-look; both files added to the MANIFEST | pure move: unit-forms only in base / new 0 (order list changes only by the moved forms' place), looks 113, G2, pkgcheck | ~250 lines moved | low | Sonnet |
| **B4 CPU boundaries** | ai.lisp → `cpu-perceive.lisp` (the live ~350 lines) + `ai-v2.lisp` (the retired kits' stack); ai-learn.lisp → `fq-online.lisp` (live) + `ai-learn.lisp` (old learner); core-ai's `strat-*` glue → `strategy-glue.lisp`; `*in-rollout*` defined once; the rollout's special bindings in one macro used by `sim-rollout` and `mc-full-rollout`; cross-style reads (K2's `kk-*` from Ichigo's file, `ken-ki-style`, `*kk-hend-p*`) named in one shared file; MANIFEST; tests/duel-rules-test.lisp load list; DUEL_AI_* file references | unit-forms (splits: only in base / new 0, order kept), G2, host tests, `tools/simgate/snaptest.lisp`, `fulltest.lisp` | ~3,000 lines moved, ~40 rewritten | medium (load order, the core-ai ↔ cpu-mcts cycle) | Opus |
| **B5 tools** | `tools/simlib.py` (sha, build_hash(extra), run_lisp, parse, pool) for strategy-eval / strategy-switch / matchup-eval; `tools/simgate/prelude.lisp` for the nine runners; assistgate.py and strategy-matrix.py call `build()`; AGENTS tool table: a "research tools (dream-rsi)" row | each tool's smallest run byte-identical before / after (G2 via `simgate.py --cvc`; one tiny strategy-switch job; one matchup-eval seed: smoke, not a balance gate) | −150 lines | low | Sonnet |
| **B6 web bridge** | one `page-commands` decoder (webui.lisp, webhud.lisp); `duel/web/bridge.js` shared by menu.js / hud.js; pwa.js's ranges as a route table; one roster table on the page (or published by Lisp); sw.js `FILES` written by build.sh | smoke; browser scripts duel-flow, duel-touch, duel-mobile; looks 113 (menus and HUD are HTML in every still) | ~200 lines | medium (no native gate; an offline / install check by hand) | Sonnet |

Files by batch in wave 1 (checked pairwise; no cell shared but the MANIFEST):

| batch | files it edits |
|---|---|
| B1 | engine/lisp/{fx,meshgen,audio,package}.lisp, docs/engine/ENGINE_API.md |
| B2 | kit.lisp, tuning.lisp, core.lisp, fighter.lisp, combat.lisp, core-sim.lisp / hud.lisp / onehand.lisp (only if `core-kit-p` goes in), ken.lisp, ichigo.lisp, hisagi.lisp, hisagi-stills.lisp, tests/debug-ranges-check.py |
| B3 | yama-art.lisp, ichigo-look.lisp, ken-look.lisp (only the moved forms leave them), two new shared files, **MANIFEST** |
| B4 | ai.lisp, ai-learn.lisp, core-ai.lisp, cpu-mcts.lisp, sim-state.lisp, cpu-ki-ken.lisp, cpu-ki-ichigo.lisp, cpu-hisagi-range.lisp, cpu-hk-hisagi.lisp, new cpu files, **MANIFEST**, tests/duel-rules-test.lisp, docs/duel/DUEL_AI_*.md |
| B5 | tools/*.py, tools/simgate/*.lisp, tools/roguegate/run.lisp, AGENTS.md (tool table) |
| B6 | webui.lisp, webhud.lisp, duel/web/*.js, build.sh |

B3 and B4 both add MANIFEST lines: the lead merges B4 first, then B3 (a rebase of one-line MANIFEST additions). B0
already edited ARCHITECTURE.md and the skills; B1 alone edits ENGINE_API.md. The engine half of the hem spring (E2,
`spring-chain-*` in anim.lisp) moves in B7, after B1, and after D1 may have removed rukia-art.lisp.

### Wave 2 (after B2 merges; small engine moves)

| batch | scope | proof | size | risk | model |
|---|---|---|---|---|---|
| **B7 engine moves** | E1 fuzzy core, E2 the hem spring (B3's shared file → anim.lisp `spring-chain-*`, call sites renamed), E3 rebinding, E4 settings table, E5 `resolve-tuning`, E7 page-put helper (with B6's JS), E6 the registry if D7 = 1 (debug.lisp, every `*char-debug*` push) | G2, host tests (duel-control, fuzzy, input), looks 113, pkgcheck; the string-name grep first | ~300 lines moved | medium (E6: dispatch order) | Opus |

### Wave 3 (after the decisions; removal)

| batch | scope | proof | size | risk | model |
|---|---|---|---|---|---|
| **B8a retired files out** (D1) | branch `retired-kits` at the parent; the 18 files, ai-v2.lisp, rukia-ai / barro-ai, kit stubs that keep the roster indices; MANIFEST; tests/duel-rules/{barro,rukia,senjumaru,yama}.lisp and the runner | pkgcheck (it lists every dangling call for B8b / B8c), build, host tests, G2 identical | −20k lines | low (mechanical) | Sonnet |
| **B8b old mechanics out of the shared sim** (D1) | rules / fighter / combat / kit / tuning §5 / gate (`*pairs-0*`, acc lines, the Rukia band) / debug.lisp scenarios / hazards fire waves; kit slots used only by retired kits | G2 identical (the decisive proof), host tests, pkgcheck, simgate's state-hash lines for II IK KK unchanged | −1.5k to −2k lines | medium | Opus |
| **B8c presentation dispatch out** (D1, with D4) | draw / feedback / vfx-stamps branches to yama-vfx, yama-vfx.lisp, `*hurt-cines*` / `*brush-names*` entries (then a `:brush-name` kit slot), R-d widgets, the canvas fallback if D4 = 1, hud.js roster rows | looks: surviving stills byte-identical | −1.5k lines | low-medium | Sonnet |
| **B8d gates, scripts, docs** (D1, D5) | looks re-pin (new cvc seeds over K I H, the cinematic sets, fx-a / fx-b / mobile replacements), every "113" quote; tests/scripts/duel.py sections and jsons; DUEL_GAMEPLAY debug table; manual.html (D5); AGENTS / README / skills mentions | the new still set recorded; smoke heap and wasm size before / after reported | docs + scripts | low | Sonnet |
| **B9 frozen modes out** (D2) | endless / rogue / run-mods files, `*run-mods*` / `*run-boss*` sites, ASSIST, the old learner, their tests, tools, the ENDLESS looks scenario, debug ranges | G2 identical, host tests, looks re-pin of the 4 ENDLESS stills | −3k lines | medium (combat.lisp sites) | Opus |
| **B10 strategy archive** (D3) | the unnamed entries and `st-hisagi-hk` to `tools/simgate/strat-archive.lisp`, loaded by tools and tests/duel-rules/strategy.lisp | G2 identical, host tests (strategy suite with the archive), one tiny strat-run with an archived id | −1.6k lines in the game | low | Sonnet |
| **B11 stills and style scripts** (D6) | `git rm --cached` per D6, move the scripts, fix the docs that cite them | docs grep | – | low | Haiku |

B8a first; then B8b ∥ B8c (disjoint: B8b sim files, B8c presentation files); B8d last. B9 after B8b (both edit combat.lisp
and fighter.lisp). B10 ∥ B8 (strategy files only). B11 anytime.

### Wave 4 (after wave 3; consistency of what remains, only if wanted)

- Kenpachi's and Ichigo's split by role (ken-art → -art / -draw / -cine with ken.lisp's cinematics; ichigo-look →
  -draw / -cine), and the role table in DUEL_DESIGN "Character code layout". Pure moves (unit-forms + looks). Worth it
  only before the next big change to either fighter; otherwise churn.
- The `kit` struct trimmed to what `:core` kits use, the last slot hooks into `:hooks`; Kenpachi's tuning.lisp knobs into
  his file; feedback's `:ken-bk-burst` through the `:hit-fx` hook (sound and shake order kept: looks + G2).
- K4: the phone's SP-zone hold through the vpad (a `:sp-zone` action written by `p1-reader`); proof by a phone script
  (duel-touch / duel-mobile) whose `duel hash` lines stay identical. Opus.
- The `brain` component's strategy state as its own struct: last, only with a snapshot pollution run (snaptest, fulltest).

## 8. What should NOT be done

- Any consistency work inside retired-kit files before D1 (Rukia's knobs out of tuning.lisp, the `:acc-line` hook's five
  callers, the lb- / br- prefix tidy, Lille's `def-char-debug`): wasted if D1 removes them.
- Merging the Kenpachi and Ichigo style CPUs (~800 lines each, same shape) or the six reach helpers into one: their
  margins differ on purpose and the style searches were scored on them; a merge is a behaviour change for G2 to judge,
  not a refactor.
- Splitting files that are long but cohesive (hisagi-art 2,793, strategy.lisp's machinery) just for size.
- The "not worth moving" list in §4.4, and REFACTOR_NEXT's "Not to do" list.
- Renaming exported engine symbols without a prefix (`hypot`, `xform`, `fv`): every call site moves for no behaviour.

## 9. Not verified

- No build, test or gate was run for this audit (only `tests/debug-ranges-check.py`).
- The 600-900 lines of old mechanics in shared files, the ~850-line canvas fallback, the ~500 manual lines and the
  97 knobs without provenance are the audits' estimates.
- Which of the old Lille's 290 definitions `:barro` really reaches (85 named directly; no reachability run).
- Whether any of the 113 looks stills draws a canvas-HUD pixel (none should: HTML is on in every still).
- Object bytes are function code only; the clip data and the startup heap saved by D1 / D2 need a build without them.

## 10. Status at the pause (2026-11-10)

Waves 2-3 (B7, B8a-d, B9, B11) and wave 4 are not started; B10 is dropped (D3).

### 10.1 Batches

- **B0 (Sonnet 5.5): merged.** Debug range 2510-2512 so 2513's slow motion is reachable; five dead knobs removed from tuning.lisp
  (`*nome-max*`, `*nome-up-t2*`, `*nome-down-t2*`, `*nome-down-t3*`, `*ai-ru-l-after-k*`); the sim-state.lisp comment; the
  `*strat-lookup*` docstring; RAVEN leftovers in ARCHITECTURE.md, comments, skills and docs/README.md's three dead links.
  `tests/debug-ranges-check.py`: 108 ranges, 0 errors (1 before).
- **B5 (Sonnet 5.5): merged.** `tools/simlib.py` (76 lines) + `tools/simgate/prelude.lisp` (12 lines); nine Python tools and
  twelve Lisp runners use them; assistgate.py and strategy-matrix.py now build first. Tool outputs identical before / after
  (only wall-clock, heap and cons figures differ). Net +14 lines (the plan guessed -150). Not run: the trial / contact /
  teacher / litefit runners.
- **B1 (Sonnet 5.5): held back, not merged.** Removed the dead engine exports (`fx-debris` pool with `fx-debris-update` /
  `fx-clear-debris` / `*debris-life*`, `fx-clear-orbs`, `edge-vignette`, `mb-capsule`, `mb-flat-quad`, `set-loop-gain`,
  `audio-locked-p`) and synced ENGINE_API.md; all its own checks passed, index.wasm -5,924 B. Reverted in the main checkout (the
  patch is kept outside the repo) because the looks gate could not prove it pixel-neutral (10.2). ENGINE_API.md's RAVEN text
  therefore remains for now.

### 10.2 The looks gate was broken before this round

Found by Sonnet 5.5; the fixes in `tests/style-gates.py` are merged. A full run took about 7,250 s and failed twice.

1. The menus scenario pressed ArrowDown 6 times for SETTINGS, but MODE has 7 rows since ENDLESS / DANGAI were hidden, so row 6
   is MANUAL; the page navigated to manual.html and run.mjs waited out `--timeout 7200` (DEVLOG §604 had noted "menus scenes
   stuck on the manual page"). Fixed to 4 presses.
2. LOOKS_SEEDS (re-pinned 2026-10-17) named retired pairings (YS, HY, IR, BK); `2000+seed` now draws from the playable roster.
   Re-pinned to (1 KH), (3 HK), (7 II), (10 IK), scenario names cvc-kh / hk / ii / ik; still 113 stills.
3. `--keep-base` reused BASE stills left from 2026-11-07 (another BASE), so the "88 of 113 noisy" floor was meaningless. Use
   `--keep-base` only with a BASE rendered in the same session, on a clean build / style / looks.

After the fixes a full run takes 453 s with no timeout; the fighters and sim-line checks pass; but 26 stills still fail, because
**rendering is nondeterministic run to run in every build**, including a fresh build of fd9e7180:

- The menu backdrop (moon rings, colonnade, idle fighters, floor sparkle; never the HTML panels) alternates between two states
  (about 80 % / 20 %), 1,678 px apart on menus/mode and 3,743 on settings.
- cine-rukia stills are bimodal (about 18,000 px on rukia-hakka-120); the title, ENDLESS stills and the match stills w*-0 also
  vary. The source is not found (timing, or an unseeded cosmetic path).
- A rebuild of identical sources (fd9e7180) is not byte-identical to the saved base (index.wasm 11,155,672 vs 11,155,696 B).
- Bisect on the menus stills (serial runs): builds without B1 (old base, rebuilt base, B0 only) showed only the two known
  states in 35 runs; builds with B1 (B1 only, B0+B1) showed extra states in 5 of 19 runs, of the same size as the known gap.
  B0: supported as pixel-neutral. B1: unproven, hence held.

So the two-BASE noise floor is unreliable (a third render can differ where two agreed), and "113 stills byte-identical, noise
floor 0" cannot be met today. G2 (`--cvc`, native and browser: II 32, IK 34, KK 33), host tests (10149 ALL PASS), pkgcheck and the
smoke passed for the merged state; the main session reran them after the merge.

**Found and fixed by R0 (2026-11-12, Opus 5.5).** The cause was the test driver's virtual clock, not the game. Under
`run.mjs --fixed-dt` the clock advanced one DT per browser frame from the main loop's first frame, but main.c's first frames
return at once while the page's GPU device is still pending (`engine/c/main.c:70`, `m_gpu_ready`; the device comes from
shell.html's `requestAdapter` / `requestDevice` promise, a wall-time race with the wasm download). So startup (`pf_init`, the
title) began 1-7 frames late in virtual time, a different number each run, and every scripted key, debug command and still
landed that many frames off. The menu orbit, for one, is `(* 0.05 (elapsed-time))` (camera.lisp:322), seconds since `pf_init`.
Evidence, on one build (6 serial-ish renders at `--jobs 3` of menus, cvc-kh, cine-ken): the still md5 classes followed the
page's `load: gpu device at N ms` line (virtual) exactly: cvc-kh 17 ms gave one hash in all three runs that had 17, and 33,
50 and 67 ms each their own; menus 17 / 50 / 117 ms three hashes; cine-ken 17 / 83 / 100 ms three; 22 of the 24 stills
differed. §10.2's "80 / 20 %" was the device usually arriving on the same frame. The startup steps themselves are
deterministic: the clock does not move inside a frame, so all 175 `%INIT-STEP`s run in the first frame ("wall 0 ms").

The fix (tools/run.mjs, the fixed-dt rAF wrapper): no frame runs and the clock stays at 0 until `Module.preinitializedWebGPUDevice`
exists, so startup always runs at virtual 16.67 ms; every log now reads `gpu device at 0 ms`. No game, engine or sim code
changed (G2 identical, native and browser). After it, on the same build: the 3 scenarios x 6 renders, 24 of 24 stills identical;
the whole looks set (15 scenarios, **113 stills**) x 3 at `--jobs 4`: 0 differ; again x 3 at `--jobs 6` with a `./build.sh duel`
running beside it: 0 differ, and the two sets equal each other (six renders, one md5 per still). A rebuild of the same sources
differs from the first in 8 bytes of index.wasm (same size, 12,773,467 B): two ECL module init tags
(`_eclLwPWfIS6_G5kGyT81` / `..._XszLyT81`, `init_lib__ECLNE0OTKR6_...`), names only; `style-gates.py looks` BASE (the first build) vs that rebuild at `--jobs 4`: 113 of 113 bytes identical, noisy
between the two BASE runs 0, every scenario exit 0, sim lines equal, 531 s wall (and both equal the six renders above: nine
renders, one md5 per still). **Noise floor 0 again**; the still count stays 113 (15 scenarios). For R7: menus select-1 and
select-4 are the same image (P1's cycle over the playable roster); cine-rukia, cine-senju, cine-barro, part of fx-b and endless
still drive retired kits and frozen modes. Checks: G2 native and browser identical (II 39, IK 36, KK 28 lines), host tests
10326 ALL PASS, pkgcheck clean, smoke PASS.

### 10.3 Next (after the pause; nothing is running)

1. Find the rendering nondeterminism and restore a zero noise floor (a prerequisite for every "must not move a pixel" batch);
   then re-judge B1. The Lisp HUD is compared with the HTML one by side-by-side stills the user reviews, so it no longer waits
   for this (DUEL_LISP_HUD §4.6, §5; confirmed by the main session, 2026-11-10, on the user's 「不用到 100% 完全相同，但要還原大多數的美術風格與動畫」).
2. The Lisp HUD: a design doc first (scope: menus, settings, battle HUD; text by an offline-baked SDF atlas; the engine pieces:
   textured quads, atlas, layout, focus / scroll, tweens), a spike measuring wasm / heap and 11 px legibility at a phone size,
   then screens one by one against the HTML reference (DUEL_WEBUI "A Lisp HUD").
3. Refactor waves 1-3 resume afterwards; D5-D7 are decided (option 1 each, the user 2026-11-10: 「這三項都按你建議的去做」)
   and are carried out when the refactor resumes (D5 after D1 / D2).
4. When the refactor resumes, audit the game against ECS + pragmatic FP (the user, 2026-11-11, AGENTS.md "Design principles",
   DEVLOG §709): how much of `duel/` uses the engine's ECS today (components.lisp and the kits' DEFCOMPONENTs against the state
   kept in specials and per-fighter structs), where state hides in specials, which logic could be pure and host-tested; fold the
   result into the batches.

## 11. Re-plan, 2026-11-12

The user (2026-11-12): 「規劃實作的同時也幫我重新安排之前為完成的程式優化與整合」: the SP design (docs/duel/DUEL_SP.md, its plan §8, batches
S0-S9) is to be built, and what this round left is re-sequenced around it. A plan by the Fable advisor; nothing here is built. Line
numbers are main 172e65a4.

### 11.1 What changed since the pause

- **D4 is done** and the HTML UI is gone (DUEL_LISP_HUD §16): `duel/web/` holds only head.html, pwa.js, sw.js, manual.html and the
  icons. **B6 shrinks** to sw.js's `FILES` written by build.sh and one command decoder for webui.lisp / webhud.lisp (114 + 265 lines);
  B7's E7 (the page-put helper for B6's JS) is dropped.
- DUEL_LISP_HUD §16.6 lists the canvas pieces that stayed only for the frozen modes and the retired kits: they leave with D2 / D1 in the
  same cuts (R4 / R5 below), not as a batch of their own.
- The sim's shared paths moved (the symmetric cancel DUEL_CORE §2.1, the steal §2.2, GUARD ALL §9, Hisagi §29-§30) and
  `tests/duel-rules/unit-names.lisp` now catches duplicate names: every "pure move" batch runs it.
- Dead code found on 2026-11-12 (DUEL_SP §7): the DRIVE-full Bankai gate, pointer locks, arm pips; and the Reiatsu gauge's internals,
  which nothing in the core path spends.
- The looks gate still cannot prove byte-identity (10.2; fixed by R0 the same day), and after the Lisp HUD every still changed:
  the old BASE is void.
- **B1's held patch is stale** (two days of engine edits for the Lisp HUD: paint stream, SDF text, layout, tweens in engine/lisp). It is
  not rebased: B1 is redone from the list in 10.1 against the current exports (R9), and the old patch and worktree are discarded.

### 11.2 The ordering argument

SP rewrites the shared gauge and hit paths: `rules.lisp` (`fs-regen`, `burst-allowed-p`, `hit-gains`, `kosei-gain`), `combat.lisp`
(`pay-gauges`, `gain-gauges`, `kosei!`, `apply-hit`, `burst-*`, `gauge-system`), `fighter.lisp` (`spend-fs`, `start-hoho`) and
`core-sim.lisp`. The same functions carry what D1 / D2 remove: the Reiatsu half of every gain (`reiatsu-gain!`, `pay-gauges`' R, the bind
pool combat.lisp:76-89), 16 `*run-mods*` sites in combat.lisp and 6 in fighter.lisp, `rmod-x :fs-regen / :hoho-cost`, the old AI's
readers of `*fs-burst*` / `*fs-hoho*` (ai.lisp, ai-learn.lisp, scripted.lisp), and ~500 host checks of the retired kits that pin the old
gauge rules. So:

- **Before SP (it shrinks SP's surface, and its proof is cleaner without a sim change in flight)**: the dead core code (R1), the retired
  kits (R2, R3), the frozen modes (R4), the Reiatsu internals (R6). All are proven by **G2 identical + host tests + the state-hash
  lines**, none needs the looks gate. With them gone no SP rule needs a `core-kit-p` branch and S3 edits a `pay-gauges` with one gauge.
- **In parallel with SP (disjoint files)**: the looks nondeterminism hunt (R0), the presentation cut (R5), the gates / scripts / docs
  re-pin (R7), the stills (R8), the ECS + FP audit (R10, read-only), S0 itself during the removals.
- **After SP (same files as SP, or worth doing only on the settled code)**: the kit plug-in consistency + the debug registry (R11), the
  CPU file boundaries (R12), the engine moves (R13), the small bridge (R14), the audit's findings (R15), wave 4.
- **Cut line if the user wants the SP playtest sooner**: R4 and R6 may move to after S5. The price: S1-S3 edit around the 22 run-mods
  sites and the Reiatsu argument, S1 needs the frozen CPU readers left compiling, and R4 / R6 then rebase over SP. R1-R3 stay before
  SP in either case (the retired kits' tests cannot survive S1).
- **Decided 2026-11-12** (the user: 「按你建議的做」, DEVLOG §730): **removals first**, the timeline of 11.4 as written; the cut line is not
  used.

### 11.3 Batches

Proof words: **G2** = `tests/style-gates.py cvc` identical to `tests/style-cvc-ref.txt` (II IK KK, native and browser); **hash** =
simgate's state-hash lines for those pairs unchanged; **unit-forms** = `tools/unit-forms.lisp` (moves EQUAL, only-in-base / only-in-new
0); **fast** = host tests, pkgcheck, build, smoke, `debug-ranges-check`, `unit-names`. No balance gates.

| # | Batch (old name) | Scope | Proof | Size / risk | Model | When |
|---|---|---|---|---|---|---|
| **R0** | The looks gate's nondeterminism | Find why two renders of one build differ (10.2: the menu backdrop's two states, the cinematic stills, the w*-0 match stills; suspects: an unseeded cosmetic `rnd01` path, frame timing against `--fixed-dt`, startup `:load` step order); fix or pin it; then render a whole new BASE over the Lisp HUD and record the still count | three renders of one build byte-identical, twice; then BASE vs a rebuild of the same sources | unknown (timebox two sessions; if not found, the gate is redefined as "per-scenario stills identical in 3 of 3 same-session renders" and the doc says so) | **Opus** | at once, parallel to everything (it edits tests/style-gates.py and cosmetic paths only; a cosmetic fix merges between sim batches). **Done 2026-11-12** (10.2's last paragraph): the cause was run.mjs's virtual clock running while main.c waited for the GPU device; fixed in run.mjs alone; 113 stills, 0 differ in 3 + 3 renders (`--jobs` 4 and 6 under a build), noise floor 0; BASE vs a rebuild of the same sources 113 of 113 bytes identical |
| **R1** | Dead core code (new) | `core-pips-ok-p`, `arm-spend!` and `:pips`; `core-pointer-locked-p`, `:locks` and the loop in `core-next-as`; `drive-full-p` and `bankai-allowed-p`'s DRIVE argument with `kit-bankai-form`'s dead callers (fighter.lisp:493, combat.lisp:906, onehand.lisp:212, ai.lisp:789); first a grep that no live kit's data carries `:pips` / `:locks` and that no live path reaches the gate. **Not assumed dead**: the arm meter itself (`kit-pips`, `gauges-meter`, `gauges-arm-pending`, the plate's UDE) is still printed in the hash line (gate.lisp:20) and may be live on Kenpachi; R1 removes only the per-move `:pips` price unless the grep shows the whole meter is unreachable, and then reports before cutting | fast, G2 (a hash-line column that leaves: compared with it stripped, as R6), snaptest / fulltest | ~120 lines, low | Sonnet | first; before S2 (`core-start!` is rebuilt there) |

**R1 done on branch** (2026-11-12): removed `core-pips-ok-p`, `arm-spend!` (and its two callers in fighter.lisp / core-sim.lisp), `core-pointer-locked-p` and the loop in `core-next-as`, `drive-full-p` and `bankai-allowed-p`'s second argument (callers in fighter, combat, onehand, ai; three tests adjusted); `core-start!` is now `start-move` + T, `core-sp-start!` lost its refuse branch, webhud slot 24 (the seals bitmask) is a constant 0. Grep findings: no kit anywhere (live or retired) carries `:pips`, `:locks`, or a non-nil `:bankai-form` (ken.lisp:312 is `nil`), so `kit-pips` and `kit-bankai-form` are always NIL. **The arm (pip) meter is therefore dead**; `gauges-meter` itself is live, but as the kit-meter's storage (Kenpachi's KAIHO level, ken.lisp:205, raised by KEN-HIT; Ichigo's BUNSHIN tag, ichigo.lisp:379), not as pips. Left in place: `bankai!`'s pip fill, `refresh-look`'s cracks, ai.lisp:466/1151/1162, fighter.lisp:473/896/903, webhud.lisp:126, ken-meter.lisp, `kit-pip-cmd-p`, `gauges-arm-owed` / `-arm-pending`, the hash line's `kit-pips` test (untouched); candidates for a follow-up cut together with `bankai!` / `:bankai-form` / `:bankai-ok` and the HUD seal slot.
| **R2** | B3 then B8a | **B3 first** (D1's prerequisite): Ichigo's hem spring out of yama-art.lisp and his weapon-tip tracker to shared duel files, verbatim. Then branch `retired-kits` at the parent and the 18 retired files, ai-v2 pieces that are whole files, rukia-ai / barro-ai, their four host test files and the runner's list leave main; stub kits keep the roster indices | B3: unit-forms, G2, same-session stills of two Ichigo scenes; B8a: pkgcheck (its dangling list is R3's work list), build, host tests, G2 | −20k lines, low (mechanical) | Sonnet (two agents, serial) | after R1 |
**R2 done on branch** (2026-11-12): two commits. **B3** (a pure move, `unit-forms` EQUAL, only-in-base / only-in-new 0): the hem spring (`%ya-hem-pose` / `-step` / `%ya-spring`, five knobs, `*ya-hem*`, `*ya-hem-m*`) to `hem-spring.lisp`; `%ic-frame` / `%ic-held-tip` / `%ic-track` / `%ic-far` to `tip-track.lisp`; and the three yama-vfx forms the shared dispatch still reaches (`vfx-ember`, its stamp `%st-ember`, and `vfx-charge`, the default hold look of any kit with no `:charge` hook) to `vfx-ember.lisp`, all verbatim, names kept. **B8a**: branch `retired-kits` at the B3 commit (`feabc015`, the last commit that holds the 18 files; local until the lead pushes it); removed 18 files (yama, yama-art, yama-vfx, rukia, rukia-ai, rukia-art, rukia-meter, senjumaru, senjumaru-art, lille-art, lille-clips, lille-draw, lille-cine, barro, barro-ai, barro-art, barro-draw, barro-stills: 18,317 lines) and `tests/duel-rules/{yama,rukia,senjumaru,barro}.lisp`; there was no whole-file `ai-v2.lisp` yet (B4's split is R12), so ai.lisp stays. `*roster*` is now a fixed list in kit.lisp (`:yamamoto :kenpachi :rukia :ichigo :senjumaru :lille :barro`, Hisagi appended by his `defkit` as 7): no stub kits, a retired slot is kit-less exactly as `:lille` was since 2026-10-13 (every live path filters through `*retired*` / `playable-roster`). Shared code touched to make pkgcheck empty (21 dangling names): draw.lisp (the `:ya-*` move beats, the TSUKABI block, `fire-sheet`, the `:fire` / `:embers` blade-look case, Rukia's layers / frost), feedback.lisp (West's ward in `:blocked`, the `:scorch` / `:ward-crush` / `:skeleton-rise` events), hazards.lisp (the `:wave` / `:fireball` / `:pillars` looks and the wave ghosts: Ichigo's waves draw by their `:look` function), vfx-stamps.lisp (dispatch arms 17, 20-22, 25-29), gate.lisp (the three retired `*-acc-line` calls), debug.lisp (the retired vfx consing probes, the Senjumaru cine arms; `burst-burn-test` P1 Yamamoto -> Ichigo so `duel-blue-burn.json` still runs). Host tests 10440 -> 3188 checks: the four files held 3177; the rest came from the shared test files' sweeps over `*forms*` (28 -> 9 forms) and checks that used a retired kit as the fixture (core -2,944, art -497, systems -576, ken -40, hisagi -7, rogue -11; thirteen core checks, `perfect-hoho-p`'s eight, Kenpachi's J1 against the Breaker aura and the pure half of East's pierce table, were kept on inline or live fixtures; `locked-free-steps` of a J3, `band-weights` of a kit's `:moves` and the East / Hellfire kit-data checks went with their kits). G2 identical (native `--cvc` and the browser `style-gates.py cvc`: II 39, IK 36, KK 28 lines). Leaves for R3 / R5 / R7: the debug scenarios in debug.lisp / ken.lisp / ichigo.lisp / hisagi.lisp that still name a retired kit (they compile and stop with `unknown kit`), `*pairs-0*`, gate.lisp's Rukia band line (46), `spawn-hand` (:skeleton body), the vfx-stamps keyword table, the dangling `*ya-tip*` in hem-spring's declaim, `*rogue-kai-edits*` / `rogue-rules` cards of the retired kits, `tests/duel-view.lisp` + `tests/duel-vfx.lisp` (build targets over yama art), `tests/style-gates.py`' cine-yama / rukia / senju scenarios, `tools/simgate/trial.lisp`'s `:rukia` default, aieval.py, combo-trial.py.

| **R3** | B8b + the old AI | The old mechanics in rules / fighter / combat / kit / tuning §5 / gate / debug scenarios / hazards' fire waves; kit slots only retired kits used; ai.lisp cut to the live perception (~350 lines, renamed `cpu-perceive.lisp`: B4's first half done here because the cut forces it); scripted.lisp's players nobody calls | **G2 + hash (decisive)**, host tests, pkgcheck | −2.5k to −3k lines, medium | **Opus** | after R2 |
**R3 done on branch `worktree-agent-ae692873cd228ba65`** (2026-11-12): six commits, duel/ −2,781 / +618 lines (the build unit
51,181 → 49,018 lines), wasm 10,895,616 → 10,678,614 B, startup heap 74.0 MB both. **The old AI**: ai.lisp (1,361) removed;
`cpu-perceive.lisp` (353) keeps the live perception (the SNAP ring, its readers, AI-PRESS / AI-DASH / AI-EVENT-ROLLS / AI-STRAFE /
AI-WALK, BRAIN-PERCEIVE, BRAIN-SYSTEM calling CORE-BRAIN-STEP) and a last section only the frozen ASSIST / old learner call (R4
removes it with them: AI-TABLE, *AI-STEPS* cut to their steps, AI-COMMAND, STRING-REFLEX and its steps, J-BEATS-OPEN-P,
RANGED-THREAT-IN ...); scripted.lisp keeps the trial player (tools/simgate/trial.lisp) and *DUMB-DELAY*. **Arm pips**: KIT-PIP-CMD-P,
the :bankai-form / :bankai-ok / :pips slots, GAUGES-ARM-PENDING / -OWED, BANKAI-OK-P / -READY-P / -ALLOWED-P, PIP-SPEND, the
four *ARM-* knobs, the :arm-* events, REFRESH-LOOK's crack hiding; BANKAI! takes its form; KIT-COMMAND-OK-P / TRY-COMMAND lose
ENDER; GAUGES-METER kept. The state-hash line lost its u / * / fr / sl columns (conditional: no live kit ever printed them), so
the reference needs no regeneration; h (the old heat, 0) kept. **Old mechanics**: Rukia's frost / cold / layers / field /
temperature / rooted / freeze-touch / optic, Yamamoto's ward / pierce / scorch / intangible / guard-to / drop-to / keep, drink,
the NOME gain, the cut, the blade chip, the :shield catch, the Hellfire meter (:full-form), the old hazards (:fireball :pillars
:bind :freeze :hand :rift, SPAWN-HAND, hit groups, fragile), the :x-axis readers; 13 kit slots, the hit window's frost / meter;
32 rules functions; 115 tuning knobs nothing read. **R2 leftovers**: the retired kits' debug scenes, probes, module / stance
tests, HUD review, Rukia pairings and cinematics out, the generic ones repointed to Ichigo (2209, 2320-2326, force-cine 1 6 8 9,
force-special 5-10 13 65, string test rows 0 / 1, ichigo tests 3 5 9), the old AI's debug knobs (24000 25000 28000 29000 31000
39000) and the arm's (32000-34999) freed; *PAIRS-0* by roster index; Rukia's band lines; the dangling *YA-TIP* out of hem-spring's declaim. **Proof**: G2 identical native and browser (II 39, IK 36, KK 28 lines); snaptest straight =
pollute but for the timing lines (167 duel lines; 1,735 rollouts); fulltest 102 + 45 checks, 0 differ; host tests 3188 → 3114
(the arm / Bankai-entry checks 15, East's pierce 8, the :x-axis / line / reflect / opp-chance block ~32, heat 4: all of removed
functions); control 116, learn 131, input 33, touch 100, cine 18, hud-engine 121 (the same on BASE); pkgcheck only DUEL::APP; debug-ranges
92 ranges, 0 errors. Browser scripts: every live `tests/scripts/duel-*.json` on the same-session BASE (main c389ea08) and the new build, fixed dt, the
log's sim / combat / hash lines compared (timing and stats stripped): 29 identical (blue-burn, cvc-ii / ik / kk, drive-switch and
its phone run, endless and its portrait run, flow, hisagi-bankai / j1-cancel / kin / ns2, ken-armburst / bankai / core / sealed /
shikai, keys, practice, practice-cancel, rogue, shikai-dswitch, steal-cap, sublimation, switch-routes, touch, touch-left, and
mobile / mobile-insets, which both builds stop identically at debug 2700: PORTRAIT-TEST's box division by NIL, a bug of before
R3); 10 equal up to where BASE stopped on a retired kit (bankai's `unknown kit :KENPACHI NIL`, BANKAI-TEST now enters :bankai;
extras, gauges, ichigo, ichigo-portrait, kikon, probe, shots, stances, strings on `unknown kit :YAMAMOTO`), the new build going on
through the repointed or freed scenes; rukia / rukia-kl / rukia-portrait out of scope (retired kit); gate (retired pairings, 1,100
s), perf (real time), endless-gate and the duelvfx / duelview targets not run. Looks (same-session BASE, noise floor 0): 63 stills of the 10 scenarios that render on both builds bytes identical (cvc-kh / hk / ii / ik 29, menus 11, fx-b 10, endless 4, cine-ichigo / senju / barro 3 each), their sim lines equal; the other 50 (cine-yama, cine-ken, cine-rukia, fx-a, mobile) stop on BASE at a retired kit (`unknown kit`: R7 re-pins them). Kept and listed for later: the K / L strings (live kits set :l-after-k / -j,
Hisagi's debug latches :sig), the Breaker (every live kit carries one, debug and hooks start it), the guard (GUARD-HELD-P is NIL for
every :core kit, so guard / blockstun / guard lock / crush are unreachable in play, but interleaved with the triangle and the frozen
modes), SIPHON-OF / HIT-GAINS' siphoned (the SP batch rewrites those gains), the :u / :hoho / :settled hooks, KIT-RESET-FORM
(endless-rules reads it), Kenpachi's cup pacing lines (gate.lisp CUP-ACC), hisagi-ai.lisp's old CPU functions (host-tested).
| **R4** | B9 + §16.6's D2 leftovers | endless / rogue / run-mods files and every `*run-mods*` / `rmod` / `rmod-x` site (combat 16, fighter 6, hisagi.lisp's `:hs-tip-*` cards, flow.lisp:136-154); ASSIST; the old learner (the FQ online learner stays, in `fq-online.lisp`); the frozen screens (`hud-menu`, `hud-select`, `results-card`, `hud-text`, the `:select` / `:results` / `:clear` / `:doors` clauses, `hud-endless-*`, `hud-rogue-doors`); roguegate.py / assistgate.py; tests rogue / runmods / learn-test; debug ranges 80000-80999, 81000-81200, 84000-84999 (saved-data keys stay reserved) | G2 + hash, host tests, pkgcheck, smoke of every menu path | −3.5k lines, medium | **Opus** | after R3 (same files) |
| **R5** | B8c + §16.6's D1 leftovers | draw / feedback / vfx-stamps branches to the retired kits' VFX, `*hurt-cines*` / `*brush-names*` entries, the never-drawn `*brush-callouts*` data, R-d widgets, the canvas pieces §16.6 lists for D1 | fast; surviving scenarios' stills identical against a BASE rendered in the same session (or R0's gate if it is ready) | −1.5k lines, low-medium | Sonnet | after R2; parallel to R3 / R4 / SP (presentation files only) |

**R5 done on branch** (2026-11-12, Sonnet 5.5 subagent; one commit): presentation code only the retired kits reached, each piece grepped to zero live callers (Kenpachi / Ichigo / Hisagi and the shared paths) before the cut. brush.lisp: `*brush-callouts*` (never read since 2026-10-28; its append in ichigo-look.lisp too), the Yamamoto / Rukia `*brush-names*` entries, `bcap-restart`. draw.lisp: the Yamamoto `*hurt-cines*`, `model-flare` (never set; slot out of components.lisp), the `kit-blade` smear / breaker-colour cases (no live kit has a `:blade`). vfx.lisp: `vfx-aura`'s `:hellfire` / `:garb` / `:heat` / `:breaker-fire` / `:breaker-ember` looks, `vfx-awaken-burst`'s `:bankai` / `:bankai-burst` / `:nozarashi-half` (the live `:nozarashi` is the same arithmetic with vk = 1), and the headers. vfx-stamps.lisp: the keyword table's `:slit :wisps :cone :boom :garb :garb-guard :scorch :flare :gutter :nade` (codes 17-22, 25-29 free; a kind with no draw arm was already a no-op). feedback.lisp: `*crack-t*` and the never-emitted `:cold-crack`, the `:refused` HUD flash (the dud tick stays), the `kit-blade` branches of `show-hit` / `:armored`. hud.lisp: `*refused-t*`, `refused-flash`, `hud-refused`, `hud-pulse`. onehand.lisp: `hud-stick`'s frost arc (Rukia's `:temp` meter). cinema.lisp `push-in-on`; flow.lisp `*mode-menu*`, `settings-items`, `settings-note`, `*results-menu*` (canvas menu rows, no reader). sounds.lisp: nine sounds nothing plays (`:fire-whoosh :fire-roar :fire-crackle :fire-wave :heat-flare :frost-tick :ice-rise :ice-shatter :hand-crack`; the synthesis noise stream `au_rand` is one global, so every later sound's noise draws shift: same statistics, different samples, not bit-identical audio). glyphs.lisp / glyphs-extra.lisp: 59 brush glyphs whose character appears in no live source file (`tools/glyph-bake.py`'s CHARS pruned to match). debug.lisp: 2390's stamp list. Tests: `tests/duel-vfx.lisp` (the VFX gallery over the retired Yamamoto's looks) and its generator / JSON removed; `tests/duel-view.lisp` repointed to Ichigo and Kenpachi (scenes 0 1 3 4 5 6 7 9; the cane / skeleton and Hellfire scenes and the Yama / Rukia clip owners out; `duel-view.py` reads ken-art + ichigo-art and the three JSONs were regenerated; builds with the line in its header and renders). Proof: wasm 10,895,616 -> 10,773,555 bytes (-122 KB); about -1,030 / +90 lines over duel/ tests/ tools/ (without the regenerated JSON); host tests 3188 ALL PASS, hud-engine 121, pkgcheck only `DUEL::APP`, debug-ranges 115 ranges 0 errors; looks gate against a BASE built at c389ea08 (renders deterministic): menus 11, cvc-kh / hk / ii / ik 29, cine-ichigo 3, endless 4 stills byte-identical, noise floor 0; the scenarios that start a retired kit (`cine-yama`, `cine-rukia`, `cine-senju`, `cine-barro` and `cine-ken`, whose debug 11000 / 35000 ensure-battle a retired opponent) hang on BASE as well and are R7's re-pin. Left: `tests/style-gates.py`'s `duelstill` (needs the removed duelvfx build; R7), `toon_check.py --bg`'s doc, `vfx-smear` look 2 (black smoke) and `*reiatsu-glass*`' `:nomihose` (no live caller, kept: tiny), hazards.lisp's `spawn-hand` and `:freeze` / `:hand` hazards, combat.lisp's `:freeze-touch` / `:scorch` and `kit-blade-chip` (sim: R3), the roster table in lhud-data.lisp (R7), `components.lisp`'s Rukia frost / layers fields (sim state: R3).

| **R6** | The Reiatsu internals (new) | `gauges-reiatsu`, `reiatsu-gain!`, the R of `pay-gauges` / `hit-gains` / `kosei-gain` / `kikon-refund`, `burst-gain-mult`'s Reiatsu use, WHITE's Reiatsu, the reset's `kit-reset-reiatsu`, the knobs, the debug setters, the hash line's column (gate.lisp:20). **Check first**: Hisagi's tip reads the gauge to measure a gain (hisagi.lisp:1354, 1378 `hss-tip-r`) and prints it (1447, 1462): if anything live consumes that number it is rewritten to its real source, else removed | fast; G2 identical **with the Reiatsu column stripped from both sides**, then the reference regenerated for the format (header note); snaptest / fulltest | ~300 lines, medium | **Opus** | after R4, before S1 |
| **R7** | B8d + D5 | The looks scenario list re-pinned to what remains (needs R0's BASE); tests/scripts/duel.py sections and JSONs of retired kits and frozen modes; DUEL_GAMEPLAY's debug table; manual.html's old-system / retired / frozen sections (D5; **before S9**, which writes the SP chapter); AGENTS / README / skills mentions; every quote of the still count | the new still set recorded; wasm size and startup heap before / after reported | docs + scripts, low | Sonnet | after R4 and R5; parallel to SP S1-S5 |
| **R8** | B11 (D6) | untrack the 37 batch-* / webgl-* stills, move the style-2..6 / batch scripts to docs/research/style-history/, fix citations; decide `.gitattributes` (untracked today) with it. Done on branch: 37 stills untracked, 12 scripts moved, citations fixed; `.gitattributes` stays local (graphify's merge driver for the ignored graphify-out/, excluded in .git/info/exclude). | docs grep | low | Haiku | anytime |
| **R9** | B1 redone | dead engine exports re-derived against today's engine/lisp (10.1's list as the start), ENGINE_API.md synced (RAVEN lines, the missing exports, the Lisp HUD's new exports). Done on branch worktree-agent-a74279fd66378a38e: 12 dead exports removed (`fx-burst`, `fx-debris` / `fx-debris-update` / `fx-clear-debris` / `*debris-life*` with the `*deb*` pool, `fx-clear-orbs`, `edge-vignette`, `fx-trail`, `mb-capsule`, `mb-flat-quad`, `set-loop-gain`, `audio-locked-p`), engine -139 lines, index.wasm 12,771,527 -> 12,760,456 B; ENGINE_API.md synced (RAVEN / game/ / examples lines gone, all 703 exports named, new sim-snapshot section; AUDIO.md two rows); looks 113 stills byte-identical (noise 0), G2 II 39 / IK 36 / KK 28 identical, host tests 10440, pkgcheck only `DUEL::APP`, engine tests pass; engine-check 71 pass / 2 fail (`%ui-poly4`, `ui-rect` consing), the same two on the unmodified base 027f784c. | pkgcheck, build, engine tests, engine-check, **R0's gate** | −150 lines, low | Sonnet | after R0|
| **R10** | ECS + pragmatic-FP audit (10.3 item 4) | Read-only, on the lean main (after R4): per file, state by home (component slot / struct / special), every special written inside the step and whether it is a snapshot root, logic that is pure today vs could be, the hidden channels (`*core-on*`, `*in-rollout*`, `*skip-cines*`, `*gauges-inf*`, `*dummy*`), what of `duel/` the ECS does not hold. Output: a § in this file with a ranked list; no code | review by the main session | a report | **Opus** | parallel to SP S1-S2 |
| **R11** | B2 + D7 | One batch because both rewrite each kit's debug hookup: the `define-debug-range` registry in the engine (overlap fails at load) replacing debug.lisp's `cond` and `*char-debug*`, the doc checker kept; the `defkit` hook-point table; shared knobs to tuning.lisp; `*core-on*` / `core-kit-p` removed (every kit is a core kit after R2: a hidden channel gone); `ichigo-pull-to` -> a generic pull | unit-forms (knob moves EQUAL), G2, fast, every debug command of the scripts still dispatches (the scripts' logs identical) | ~400 lines, medium (dispatch order) | **Opus** | after S9 (debug.lisp, kit.lisp, tuning.lisp, core-sim.lisp are SP's files) |
| **R12** | B4's remainder | `fq-online.lisp` naming settled by R4; core-ai's `strat-*` glue -> `strategy-glue.lisp`; `*in-rollout*` defined once; the rollout's bindings in one macro for `sim-rollout` and `mc-full-rollout`; the cross-style reads named in one file | unit-forms, G2, snaptest, fulltest | ~1.5k lines moved, medium | **Opus** | after S7 (same CPU files) |
| **R13** | B7 less E6 / E7 | E1 the fuzzy core, E2 the hem spring -> anim.lisp `spring-chain-*`, E3 rebinding, E4 the settings table, E5 `resolve-tuning` | G2, host tests (duel-control, fuzzy, input), R0's gate | ~300 lines, medium | Opus | after S9 (fuzzy.lisp is S7's, control.lisp S9's) |
| **R14** | B6's remainder | one command decoder for webui / webhud; sw.js `FILES` from build.sh | smoke, duel-flow / duel-touch / duel-mobile scripts, an offline / install check by hand | ~80 lines, low | Sonnet | after S8 (webhud.lisp) |
| **R15** | The audit's findings + wave 4 | What R10 ranks first (expected: specials written in the step moved into components or passed as arguments; pure cores split out of `apply-hit` and `gauge-system`), then wave 4's items only where the next feature needs them | per item: unit-forms or G2, snaptest / fulltest | open | Opus | last; the main session picks |

Dropped: B10 (D3), B7's E6 (now R11) and E7, B6's JS bridge, the old B1 patch.

### 11.4 The combined timeline (both tracks)

Serial lane = one agent at a time on the shared sim files; side lanes are separate worktrees. The lead (main session) re-runs the proof
on each merged head, commits, pushes; subagents never push. `/graphify --update` after each merge point.

| Step | Serial lane (sim files) | Side lanes (parallel) | Merge point / release |
|---|---|---|---|
| 1 | **R1** dead core code | **S0** sp.lisp (pure, new file) · **R0** looks hunt · **R8** stills | |
| 2 | **R2** B3, then B8a | R0 continues | |
| 3 | **R3** old mechanics + old AI | **R5** presentation cut | |
| 4 | **R4** frozen modes | | |
| 5 | **R6** Reiatsu internals | **R10** ECS + FP audit starts | **M1 "lean main"**: G2 identical through R1-R5, format-only regeneration at R6; wasm size and heap reported. **Artifact A0** (nothing should play differently) |
| 6 | **S1** gauge rules | **R7** gates / scripts / manual D5 (after R0's BASE) · **R9** B1 redone (after R0) | G2 regenerated |
| 7 | **S2** costs | R10 hands back | **M2. Artifact A1**: the SP loop (costs, refunds, scaling, one-cell bursts) |
| 8 | **S3** ATK gains ∥ **S6** switch + awakening (two worktrees, merged S3 then S6) | **S8** HUD cues starts | |
| 9 | **S4** breakthrough | | |
| 10 | **S5** projectiles | | **M3. Artifact A2**: the whole rule set |
| 11 | **S7** CPU statements | S8 merges | **Artifact A3**: with cues |
| 12 | **S9** PRACTICE + manual | | **M4**: SP done; DUEL_SP status "built" |
| 13 | **R11** kit plug-in + debug registry | **R12** CPU boundaries · **R14** bridge | |
| 14 | **R13** engine moves | | |
| 15 | **R15** audit findings, wave 4 if wanted | | **M5**: a new looks BASE recorded on the final tree; round 4 closed |

Merge serialization points as in §7 (MANIFEST, kit.lisp, debug.lisp, tuning.lisp, the test runner's list, style-gates.py), plus
`tests/style-cvc-ref.txt` (regenerated only by the lead), `tests/scripts/duel.py` and DUEL_GAMEPLAY's debug table.

### 11.5 Risks

1. **R3 is the hard cut**: old and live mechanics are interleaved in `apply-hit` and the fighter step; the only proof is G2 + hash,
   which cover three pairings' CPU matches, not every scripted scene. R3 also re-runs every `tests/scripts/duel-*.json` of the live
   kits and compares their logs before / after.
2. **R0 may not converge.** Nothing before M4 depends on it except R7's re-pin and R9; the fallback gate is written in R0's row.
3. **The removals delay the SP playtest** by steps 1-5. The cut line in 11.2 trades that for more conflict work; the main session
   decides at step 3, when R3's real size is known.
4. **Saved data**: roster indices, stub kits, `RETIRED` / `PAIRS` and the saved-data keys stay (D1 / D2); R2-R4 each state in their
   hand-back that a save written before the cut still loads.

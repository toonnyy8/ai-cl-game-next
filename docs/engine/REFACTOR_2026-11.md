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

**DUEL_SP §7's dead-code list, handed over by SP batch S9** (2026-11-13; for R1 / R6 follow-ups; grep of `duel/lisp/*.lisp` on S9's base 224608bb): the Reiatsu internals in the core path (gains, regen, `kikon-refund`, `gauges-reiatsu`): **gone** (R6); `*drive-switch*`: **gone** (SP S6); KOSEI (`kosei!`, its knobs, debug 27000+k): **gone** (SP S3); the DRIVE-full Bankai gate (`drive-full-p`, `kit-bankai-form`, `:bankai-form`, `:bankai-ok`), pointer locks (`:locks`, `core-pointer-locked-p`), the arm pips (`:pips`, `kit-pips`, `kit-pip-cmd-p`, `core-pips-ok-p`, `arm-spend!`, `gauges-arm-owed` / `-pending`): **gone** (R1, R3), 0 references each. **Left**: `bankai!` (combat.lisp ~641-646) binds `keep` to the constant T, so `lost`'s `(- (gauges-konpaku g) 1)` branch and the Konpaku `(if keep ... 1)` are dead (a few lines; the docstring's "before: set to 1" history can stay). Nothing else on the list is live.
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
**R4 done on branch `worktree-agent-ac875e6523b45938c`** (2026-11-13, Opus subagent; four commits; the archive is the branch `frozen-modes` at
77de43f8): duel/ −3,703 / +284 lines (the build unit 48,711 → 45,292 lines), tests and tools −882 / +36; wasm 10,563,058 → 10,264,852 B
(−298 KB), startup heap 74.7 → 74.8 MB (every run of each build; the Lisp heap holds data, not code). **ENDLESS / DANGAI**: endless.lisp, endless-rules.lisp, rogue.lisp (with its card data), rogue-rules.lisp,
run-mods.lisp (1,316 lines) and every site: combat (GG-CAP inlined to *GG-MAX*, the run's atk / def mods, :kikon-guarded, the run
armour, :guard-drain / :chip-taken, the revive, RUN-MODS-STEP!, the :awaken-heal / :reiatsu-regen / :fs-regen / :gg-regen factors, the
konpaku counts), fighter (the DANGAI helpers RM-OF ... RUN-NO-GUARD-P, :hoho-cost, :sp-armor, :kikon-seal, DEFENDER-STATE's run armour),
ichigo.lisp (the boss's free clones, ZANZO, ICHIGO-BOSS), hisagi.lisp (the 尖端 cards in HS-DMG-BASE, which reduce to X and *HS-R-TIP-SP-MULT*
exactly; the boss's regen, HS-BK-STRUCK, the boss-unhit slot), ken (KEN-BOSS, the :endless-form keys; KEN-CARD-BANKAI became KEN-P, a no-op
:p hook kept on purpose: a form with a :p hook takes P in its run (fighter.lisp *RUN-COMMANDS-P*), so dropping it would have taken the
awakening-from-a-run away from Kenpachi's Shikai), kit.lisp's :endless-form slot, flow.lisp (*ROGUE*, *TIMER-CUT*, the :clear / :doors /
:reward / ENDLESS-results states, the ENDLESS branches of SELECT and the pause), components' rm slot, debug (80000-80999 and DANGAI's
84000+100c+n / 84501-84598 / 84800-84899 / 84980-84999: the 84000 double claim is gone, Kenpachi keeps 84000-84099). **The frozen screens**
(DUEL_LISP_HUD §16.6, "D2 leftovers, done"): hud-screens.lisp's HUD-MENU / HUD-SELECT (+ portrait) / RESULTS-CARD and HUD-DRAW's clauses,
hud.lisp's HUD-TEXT and its colours, ALPHA!, the ENDLESS tag; the canvas menus' taps (onehand.lisp *MENU-ROWS* / NOTE-MENU-ROW /
TAPPED-ROW / TAP-THIRD / TOUCH-TAP-ZONES-P, flow.lisp MENU-TAP-P / MENU-TAP-THIRD and MENU-NAV's tapped row: no menu drew rows any more),
webui.lisp's ENDLESS screen codes and WEBUI-ON-SCREEN-P, camera.lisp's canvas SELECT camera; debug 2328's HUD-TEXT line. **ASSIST**:
assist.lisp, the fighter's assist-next / assisted, the x*ASSIST-MULT* factor, the AUTO tag, *ASSIST-MULT* / *ASSIST-TAG-FRAMES*, the
assist system's call. The SETTINGS rows AUTO GUARD / COMBO / BREAK stay in *SETTINGS* as hidden placeholders, read by nothing: the page
saves rows by place (`+pg-setting+` 10 + i, pwa.js' `settings` array). **The old learner**: learn.lisp, ai-learn.lisp's LRN learner, its
tables and page storage, the ASSIST's learner; the brain's learn slot; flow.lisp LEARN-MATCH-START / -END. **The learner split**: what
LEARNING CPU and RESET LEARNING drive is the online fuzzy Q (`fq-online.lisp`, ai-learn.lisp's lines 64-141 verbatim plus
*LEARN-DEBUG-OFF*, which FQ-ATTACH! reads; the file is now named, R12's question settled); LEARN-ATTACH! read SIM-RND-STATE without a
draw and CORE-BRAIN-STEP never read the learner, so VS CPU plays bit for bit as before. **cpu-perceive.lisp's last section** (AI-TABLE,
*AI-STEPS*, AI-STEP, *AI-BRAIN*, AI-COMMAND(-PRESS), AI-GUARD-K, GUARDING-P, J-BEATS-OPEN-P, AI-KIKON-FUTILE-P, AI-SB-FINISH-P, AI-O-ENDER-OK-P,
RANGED-THREAT-IN, AI-CANCEL-P, AI-ORANGE-P, STRING-REFLEX and its steps) and WHY; 8 knobs only they read (*AI-THINK*, *AI-STRING-FLASH-P*,
*AI-SP-CANCEL-P*, *AI-GUARD-BREAK-HOLD* / -RANGE, *AI-THREAT-MARGIN*, *AI-ORANGE-P*, *AI-SB-FINISH*). **hisagi-ai.lisp** (477 lines) whole:
past R3 its old CPU (HS-AI-PLAN, HS-R-AI-MOVE, HS-B-AI-MOVE, the styles and fences), his learner situations (LEARN-DEF-KIT) and his ASSIST
routes were reached only from ASSIST (HS-AS-DECIDE, HS-ASSIST-COMBO) and the host tests; HS-AI-KAZA-K, the one call from hisagi.lisp, was
NIL at run time (nothing set HSS-AI-KZ), so HS-KAZA-TICK lost its CPU / assist branches; HS-TIP-BAND (the tip glint's, live) moved verbatim to
hisagi-draw.lisp; the 46 hss fields only the old CPU / ASSIST touched (none hashed) and *HS-FORMS* went. **The learning gate**: its habits
(*HABITS*, *DUMB-P2*, LEARN-GATE-SETUP / -LINE, scripted.lisp's *DUMB-DELAY*, gauges' counters slot) left; 200000+ stays as the pairing gate
(START-PAIR-GATE: seeds of one pairing at 81020+i's difficulty), because strategy-eval.py, strategy-switch.py, matchup-eval.py and aieval.py
start their matches with it (h and m no longer read); 81020-81022 stay; 81000 / 81030 / 81040 / 81100 (ASSIST's) were freed and dropped
from those tools' command lists. Hisagi's ASSIST scenes 83020 / 83021 out. **Tests and tools**: tests/duel-rules/rogue.lisp (113 checks),
runmods.lisp (30), learn-test.lisp (131), Hisagi's old CPU / learner / ASSIST checks (12; one HS-DIST-MULT tip check added in place of the
HS-TIP-BAND sweep, which can no longer load on the host), the ENDLESS looks scenario (4 stills: the looks gate is 109 stills now),
tools/roguegate.py + tools/roguegate/, assistgate.py, tests/endless-sheet.py; the load lists of duel-rules-test and the three sheets.
**Proof**: host tests 3114 → 2960 (rogue 113, runmods 30, hisagi 11 net), control 116, input 33, touch 100, cine 18, hud-engine 121
(learn-test gone); pkgcheck only DUEL::APP, 0 undefined functions; the build's undefined-variable warnings *FLOW* / *WINNER* as before;
debug-ranges 84 ranges, 0 errors; unit-names passes; G2 identical native after each code commit and in the browser (II 39, IK 36, KK 28
lines; the state-hash line unchanged, no column left); snaptest straight = pollute but for the timing lines (171 duel lines, 1,735 rollouts);
fulltest 102 + 45 checks, 0 differ; the pairing gate (200310: Ichigo vs Kenpachi, 2 seeds, NORMAL) gives the same `duel gate row` lines as
the seed gate's pairing 7 (2132) and simlib's ROW parses them; move-sheet, stat-sheet and matchup-sheet run. Browser scripts: every `tests/scripts/duel-*.json` on the
same-session BASE (77de43f8) and the new build, fixed dt, the log's sim / combat / hash lines compared (timing and stats stripped; the
runs that timed out under load re-run alone): 35 identical (bankai, blue-burn, cvc-ii / ik / kk, drive-switch and its phone run, extras,
flow, gauges, hisagi-bankai / j1-cancel / kin / ns2, ichigo, ichigo-portrait, ken-armburst / bankai / core / sealed / shikai, keys, kikon,
practice, practice-cancel, probe, shikai-dswitch, shots, stances, steal-cap, strings, sublimation, switch-routes, touch, touch-left);
mobile / mobile-insets identical, both builds stopping at debug 2700's division by NIL (PORTRAIT-TEST, before R3); endless,
endless-portrait and rogue differ from the first removed command on (their JSONs leave with R7); rukia / rukia-kl / rukia-portrait out of
scope (retired kit); gate, perf, endless-gate and the view targets not run. Looks (a BASE built at 77de43f8 in the same session, noise floor 0): 53 stills of
the scenarios that render on both (cvc-kh / hk / ii / ik 29, menus 11, fx-b 10, cine-ichigo 3) bytes identical, their sim lines equal; the
ENDLESS scenario left; cine-yama / ken / rukia / senju / barro, fx-a and mobile still stop at a retired kit on BASE (R7). Every menu path by
keyboard (TITLE → MODE → SETTINGS: LEARNING CPU off / on, RESET LEARNING, BACK → CONTROLS → back → the MANUAL row → VS CPU → SELECT: P1, P2,
difficulty, camera → INTRO skipped → BATTLE → pause / RESUME → K.O. → RESULTS → REMATCH → RESULTS → CHARACTER SELECT → MODE → TITLE →
PRACTICE: pause, DUMMY → the pause's TITLE / CHARACTER SELECT → CPU VS CPU → pause → TITLE), desktop and `--mobile --size 390x844`, on
both builds: every `duel ->`, setting, fq and combat line identical (93 / 68 lines). **Saved data**: a page holding a save written before
the cut (every SETTINGS row off its default, AUTO GUARD / COMBO / BREAK included, soulduel.endless.* / rogue.0, the old learner's and the
ASSIST's tables, a foreign soulduel.fq.3.1) loads the same `duel page: … settings (2 0 4 3 1 0 1 2 1 1 3)` on both builds, plays debug 2504
to a K.O. with the same `duel fq load 3 1 fresh` / `duel fq learn 3 1 …` and writes the same fq table; the one difference: the new build no
longer rewrites soulduel.learn.3 (the old learner). `*SETTINGS*`, pwa.js and the page indices are unchanged; *ROSTER*, *RETIRED* and
simgate's RETIRED / PAIRS untouched.
**Left for later**: tests/scripts/duel.py's ENDLESS / DANGAI sections and their JSONs (duel-endless, duel-endless-portrait, duel-endless-gate,
duel-rogue), DUEL_GAMEPLAY's script rows and the manual's ENDLESS / ASSIST lines (R7, D5); the kits' :ai plists (data nothing live reads:
R10 / R12); pwa.js keeps serving the reserved soulduel.endless.* / rogue.* / learn.* / learn.a* keys (saved-data keys stay); KEN-P (a
design call: should Kenpachi's Shikai keep the awakening from a run?); ichigo.lisp PARRY-FROM-BLOCKSTUN's (not (brain-habit b)) (guard
only: unreachable for a :core kit); pre-existing orphans *HS-R-GATHER-LINKS*, +C-WORLD0+, +TWO-PI+; simgate.py's COMPANION regex still
names learn / endless (harmless); engine exports with no duel caller any more (`fit-scale`, `ui-big-text`, the 5x7 `ui-block-text` path:
B1 candidates). **Beyond the row's list, for the lead to accept or undo**: hisagi-ai.lisp went whole (R3 had kept it because ASSIST still
reached it; the reachability argument above), which also ends the Hisagi dream-rsi workflow: `docs/research/hisagi-ai-drsi/splice-tests.py`
spliced cells into the `>>> BEGIN / <<< END HISAGI-CPU-TESTS` section of tests/duel-rules/hisagi.lisp, which is gone (the archive keeps it).
learn-test.lisp (131 checks) went whole: every check was of learn.lisp, which nothing live calls.

| **R5** | B8c + §16.6's D1 leftovers | draw / feedback / vfx-stamps branches to the retired kits' VFX, `*hurt-cines*` / `*brush-names*` entries, the never-drawn `*brush-callouts*` data, R-d widgets, the canvas pieces §16.6 lists for D1 | fast; surviving scenarios' stills identical against a BASE rendered in the same session (or R0's gate if it is ready) | −1.5k lines, low-medium | Sonnet | after R2; parallel to R3 / R4 / SP (presentation files only) |

**R5 done on branch** (2026-11-12, Sonnet 5.5 subagent; one commit): presentation code only the retired kits reached, each piece grepped to zero live callers (Kenpachi / Ichigo / Hisagi and the shared paths) before the cut. brush.lisp: `*brush-callouts*` (never read since 2026-10-28; its append in ichigo-look.lisp too), the Yamamoto / Rukia `*brush-names*` entries, `bcap-restart`. draw.lisp: the Yamamoto `*hurt-cines*`, `model-flare` (never set; slot out of components.lisp), the `kit-blade` smear / breaker-colour cases (no live kit has a `:blade`). vfx.lisp: `vfx-aura`'s `:hellfire` / `:garb` / `:heat` / `:breaker-fire` / `:breaker-ember` looks, `vfx-awaken-burst`'s `:bankai` / `:bankai-burst` / `:nozarashi-half` (the live `:nozarashi` is the same arithmetic with vk = 1), and the headers. vfx-stamps.lisp: the keyword table's `:slit :wisps :cone :boom :garb :garb-guard :scorch :flare :gutter :nade` (codes 17-22, 25-29 free; a kind with no draw arm was already a no-op). feedback.lisp: `*crack-t*` and the never-emitted `:cold-crack`, the `:refused` HUD flash (the dud tick stays), the `kit-blade` branches of `show-hit` / `:armored`. hud.lisp: `*refused-t*`, `refused-flash`, `hud-refused`, `hud-pulse`. onehand.lisp: `hud-stick`'s frost arc (Rukia's `:temp` meter). cinema.lisp `push-in-on`; flow.lisp `*mode-menu*`, `settings-items`, `settings-note`, `*results-menu*` (canvas menu rows, no reader). sounds.lisp: nine sounds nothing plays (`:fire-whoosh :fire-roar :fire-crackle :fire-wave :heat-flare :frost-tick :ice-rise :ice-shatter :hand-crack`; the synthesis noise stream `au_rand` is one global, so every later sound's noise draws shift: same statistics, different samples, not bit-identical audio). glyphs.lisp / glyphs-extra.lisp: 59 brush glyphs whose character appears in no live source file (`tools/glyph-bake.py`'s CHARS pruned to match). debug.lisp: 2390's stamp list. Tests: `tests/duel-vfx.lisp` (the VFX gallery over the retired Yamamoto's looks) and its generator / JSON removed; `tests/duel-view.lisp` repointed to Ichigo and Kenpachi (scenes 0 1 3 4 5 6 7 9; the cane / skeleton and Hellfire scenes and the Yama / Rukia clip owners out; `duel-view.py` reads ken-art + ichigo-art and the three JSONs were regenerated; builds with the line in its header and renders). Proof: wasm 10,895,616 -> 10,773,555 bytes (-122 KB); about -1,030 / +90 lines over duel/ tests/ tools/ (without the regenerated JSON); host tests 3188 ALL PASS, hud-engine 121, pkgcheck only `DUEL::APP`, debug-ranges 115 ranges 0 errors; looks gate against a BASE built at c389ea08 (renders deterministic): menus 11, cvc-kh / hk / ii / ik 29, cine-ichigo 3, endless 4 stills byte-identical, noise floor 0; the scenarios that start a retired kit (`cine-yama`, `cine-rukia`, `cine-senju`, `cine-barro` and `cine-ken`, whose debug 11000 / 35000 ensure-battle a retired opponent) hang on BASE as well and are R7's re-pin. Left: `tests/style-gates.py`'s `duelstill` (needs the removed duelvfx build; R7), `toon_check.py --bg`'s doc, `vfx-smear` look 2 (black smoke) and `*reiatsu-glass*`' `:nomihose` (no live caller, kept: tiny), hazards.lisp's `spawn-hand` and `:freeze` / `:hand` hazards, combat.lisp's `:freeze-touch` / `:scorch` and `kit-blade-chip` (sim: R3), the roster table in lhud-data.lisp (R7), `components.lisp`'s Rukia frost / layers fields (sim state: R3).

| **R6** | The Reiatsu internals (new) | `gauges-reiatsu`, `reiatsu-gain!`, the R of `pay-gauges` / `hit-gains` / `kosei-gain` / `kikon-refund`, `burst-gain-mult`'s Reiatsu use, WHITE's Reiatsu, the reset's `kit-reset-reiatsu`, the knobs, the debug setters, the hash line's column (gate.lisp:20). **Check first**: Hisagi's tip reads the gauge to measure a gain (hisagi.lisp:1354, 1378 `hss-tip-r`) and prints it (1447, 1462): if anything live consumes that number it is rewritten to its real source, else removed | fast; G2 identical **with the Reiatsu column stripped from both sides**, then the reference regenerated for the format (header note); snaptest / fulltest | ~300 lines, medium | **Opus** | after R4, before S1 |

**R6 done on branch `worktree-agent-ad040c3d707255b8e`** (2026-11-13, Opus subagent; three commits: the code, the reference and
docs, this record): duel/ −235 / +108 lines (the build unit 45,292 → 45,165), tests and tools −121 / +68; wasm 10,264,852 → 10,253,921 B (−11 KB),
startup heap 74.8 → 75.0 MB (three runs of each build, every one the same). **Checked first**: nothing live reads the gauge. No CPU file (core-ai, cpu-*, mcts-lite, cpu-mcts, strategy*,
fuzzy, fq-online), the light model, webhud / lhud-* (their `+c-reiatsu+` / `+pal-reiatsu+` / `:reiatsu` aura and stamp names are colours
and looks, kept) or snapshot code names it, so no feature index moves and no constant was needed; the snapshot copies the gauges
component generically. **Hisagi's tip**: HS-DMG-MULT marked his Reiatsu before a tip or spread-route hit (HSS-TIP-R / -X) and HS-BK-HIT
paid the gain since the mark x0.3 more (§25.5 / §25.11), counted by the pacing key `:tip-sp`; its only target was the gauge and the
pacing log is the gate companion's (`duel hisagi` line), so it was **log-only and removed** (the knobs `*hs-r-tip-sp-mult*` /
`*hs-r-spread-sp-mult*`, the two hss slots, the mark, the probe line's `rei`); the damage multiplier, HSS-ROUTE-TIP, -TIP-HIT and
-TIP-NOW stay. **The command cost check**: every command a live kit can press costs 0 (`*commands*` holds :awaken :hoho :burst :step
:sp :q; :f / :sig / the Breaker / :kikon 0); SP1 / SP2 (1-2 bars) are reached only by debug's FORCE-CMD, which filled the gauge first,
so KIT-COMMAND-OK-P's bars test was always true: it went with KIT-COMMAND-COST, `*cost-sp*` / `*cost-sp-awakened*`, the move slot and
key `:cost` (three Hisagi moves named it) and TRY-COMMAND's spend. **Removed**: `gauges-reiatsu`; REIATSU-OF / -SPEND! / -GAIN! /
-BARS, SPEND-BARS; PAY-GAUGES (e fs), GAIN-GAUGES (e dealt taken &optional n), HIT-GAINS -> fs aw sfs, KOSEI-GAIN -> fs m (KOSEI!'s
ORANGE x1.5 was the Reiatsu's only), KIKON-REFUND (fs); HIT-RBASE, HIT-REIATSU-BASE, REIATSU-GAIN (rules), the hazard's `rbase` slot,
DEAL-DAMAGE's and DELAY-HIT's RBASE argument (N moves up; every caller fixed); BLUE's bar, WHITE's 15 / s, the 3 / s regen, the
Kikon / Soul Break bar, RESET-ROUND's `:reset-reiatsu` (Kenpachi's +10; the kit slot); the bind pool's last readers (the `:bind-pool`
hook point, BIND-DRAIN, BIND-RELEASE-SPLIT, `*hs-bind-drain-rate*`: no live kit holds a bind hook since §28.4); 12 knobs (*REIATSU-MAX*
-BAR -REGEN -KIND -KIND-OTHER -TAKEN, *COST-SP* (-AWAKENED), *KOSEI-REIATSU*, *WHITE-REIATSU*, *KIKON-REIATSU-REFUND*,
*RESET-REIATSU-BONUS*); the debug setters (FULL-GAUGES!, FORCE-CMD, PROBE-MASH, FORCE-BURST, Ichigo's preamble, PRACTICE's GAUGES
INFINITE; 2108 is a no-op kept because duel-bankai / keys / ichigo-portrait / rukia-portrait still send it, 27000 keeps its
`*kosei-fs*` half); the state-hash line's `a` column; tools/simgate/trial.lisp's Reiatsu delta (`:bars` accepted and ignored, as
`:layers`), combo-trial.py's column, move-sheet / stat-sheet's cost rows. **Kept, renamed**: `*reiatsu-combo-step*` / `-max` ->
`*combo-gain-step*` / `-max` (live: the flash-step of damage taken and KOSEI's points); BURST-GAIN-MULT (the awakening's ORANGE x1.5).
**Proof**: host tests 2960 → 2939 (21 checks of removed functions: core 5, REIATSU-GAIN, SPEND-BARS x2, KIT-COMMAND-COST,
KIT-RESET-REIATSU; sim 15, the bind's Reiatsu pool, its frozen gains and the source count of `(setf (gauges-reiatsu`; hisagi 1; the
checks of HIT-GAINS, KOSEI-GAIN, KIKON-REFUND, the white knobs and Hisagi's tip were rewritten to their live halves: the tip test now
pins the damage x only), control 116, input 33, touch 100, cine 18, hud-engine 121; pkgcheck only DUEL::APP; debug-ranges 84 ranges, 0
errors; the build's undefined-variable warnings *FLOW* / *WINNER* as before. **G2** in two steps: (1) native `--cvc` on the new build
equal to the old reference with the `a` column stripped from both sides (II 39, IK 36, KK 28 lines, the same winners and ticks); (2)
`tests/style-cvc-ref.txt` regenerated for the format only (header note "2026-11-13 R6"), then native `--cvc` and the browser
`style-gates.py cvc` PASS against it. snaptest straight = pollute but for the timing lines (171 duel lines, 1,735 rollouts); fulltest
102 + 45 checks, 0 differ. Browser scripts: every live `tests/scripts/duel-*.json` (37; ENDLESS / DANGAI / Rukia / gate / perf / view out of scope) on BASE and the new build, fixed dt, the log's sim / combat / hash lines compared with the hash line's `a` column and the Hisagi probe's `rei` stripped: 37 identical (35 to the end; mobile / mobile-insets both stop identically at debug 2700's division by NIL, the PORTRAIT-TEST bug from before R3); the runs that timed out on wall time under a load of ~150 were re-run with a longer limit on both builds. Looks (BASE built at 581df983 in the same session, noise floor 0): 53 stills byte-identical (cvc-kh / hk / ii / ik 29, menus 11, fx-b 10, cine-ichigo 3);
their sim lines equal BASE's with the `a` column stripped (the gate's own sim-line check reports DIFFER for the column, as expected:
a BASE built before R6 always will). **Left**: the rest of the bind framework (BIND-OF and its readers, the grey damage, the
snapshot, sim.lisp's dummy binder: no live kit holds a `:bind` hook), SIPHON-OF (no live kit holds `:siphon`), `vfx-hit`'s `:reiatsu`
stamp and the palette names (looks), debug 2108 until R7 drops it from the scripts, DUEL_DESIGN's old-system paragraphs (annotated,
not rewritten). **For S3 (the lead's call)**: the §25.5 / §25.11 tip and spread "SP recovery" bonuses (x1.3 / x1.3) had the Reiatsu as
their only target; whether DUEL_SP §5's ATK gains take them is open.

| **R7** | B8d + D5 | The looks scenario list re-pinned to what remains (needs R0's BASE); tests/scripts/duel.py sections and JSONs of retired kits and frozen modes; DUEL_GAMEPLAY's debug table; manual.html's old-system / retired / frozen sections (D5; **before S9**, which writes the SP chapter); AGENTS / README / skills mentions; every quote of the still count | the new still set recorded; wasm size and startup heap before / after reported | docs + scripts, low | Sonnet | after R4 and R5; parallel to SP S1-S5 |
**R7 done on branch** (2026-11-13, Sonnet 5.5 subagent; commits on `worktree-agent-a914696804acb448c`): the gates, the scripts and the docs follow the roster that plays. **Looks gate re-pinned** (`tests/style-gates.py`): `cine-yama`, `cine-rukia`, `cine-senju`, `cine-barro` and `fx-b` left (their commands, 10000-12000 Yamamoto, 40000+ Rukia, 78000 Senjumaru, 82300 Lille, 2412-2481, were no-ops: the stills showed the title or an idle fight; `cine-senju` and `cine-barro` were one image under two names); `cine-ken` stays (Nozarashi 11000, Bankai 35000: it renders on this build), `cine-ko` is new (Soul Break 16000, K.O. 18000 and RESULTS), `cine-ichigo` stays; `fx-a` is rebuilt on live commands (2505 + the Lisp HUD review states 2440+k: 2430+k was a no-op; Kenpachi's smears and moves 2309 / 2305 / 2306 / 2308 / 2310; KESSA's clones 74007); `menus` shows 3 select stills, not 7 (the P1 cycle wraps every 3 fighters: select-1 / 4, 0 / 3 / 6 and 2 / 5 were the same images, the finding behind "select-1 = select-4"); `mobile` drops Senjumaru's two and the Yamamoto cinematic (10110 became 11060) and takes 2440+k, with k 6 for the last HUD (**2447 / k 7 does `force-form :kessa` on P1, and with Kenpachi as P1 the game stops with `unknown kit :KENPACHI :KESSA` and run.mjs then waits forever**: a scenario must make P1 Ichigo first, as `lhud-scene` does). The gate is **75 stills** (menus 7, cvc 29, cine-ken 5, cine-ko 5, cine-ichigo 3, fx-a 12, mobile 14; 109 before). Proof: a BASE built at 581df983 and the new build rendered the whole new set (BASE twice, new once, `--jobs 4`): **75 / 75 bytes identical, noise floor 0**, every `duel hash` / RESULTS line equal, every run exit 0 (mobile re-run alone after fixing the k 7 hang: 14 / 14). The new build and a copy of itself were not rendered against each other: BASE twice already differs by 0 px and new = BASE on all 75, so two renders of the new build are equal too. `duelstill` now drives the art viewer (`dist/duelview`, scene 4 of `tests/duel-view.lisp`: OUT.png and OUT-bg.png without actors, 4004) instead of the removed `duelvfx` build (`--flat` / ink variants out); `tools/toon_check.py`'s `--bg` text points at it. **Portrait test fix** (`duel/lisp/debug.lisp` PORTRAIT-TEST 0, presentation-only): `fighter-screen-box` returns NIL when any corner of the box is behind the camera or off the projection (the title's demo at 6.95 s of `duel-mobile.json`, P1 after the 24 m of debug 2701); the log line then divided `(/ nil d)`; now it prints zeros. `duel-mobile.json` / `duel-mobile-insets.json` run past debug 2700 (the whole probe log is there: `duel frame boxes`, band lines, p1 4/4 both 4/4 on the neutral frame). The probe's band counts read 0 / 0 while P1 has no box: that is the probe reporting, not a framing result. **tests/scripts/duel.py**: out are the sections and JSONs of `rukia`, `rukia-kl`, `rukia-portrait`, `endless`, `endless-portrait`, `endless-gate`, `rogue`, and (every command a no-op since R3: 2315-2319, 2330-2360 the O modules, 2370-2379 Yamamoto's Bankai stances, 2327 the guard gauge) `probe`, `kikon`, `stances`, `gauges`; `nome` was gone already. The remaining JSONs are generated identical (only the mobile pair changed: the retired Kikon / Bankai cinematics 12030 / 12080 / 10110 / 14030 became 11030 / 11100 / 35030 / 16010 and the CONTROLS row 7 became 5); their headers and the keys / extras / strings / shots comments describe what the live game logs (J J J = `IC-J1`, `IC-J2`, `IC-NA3`; the K / L / I / U / O presses of `keys`, `strings`, `shots`, `bankai` do nothing). **Docs**: manual.html (the ENDLESS and DANGAI sections and rows, the AUTO GUARD / COMBO / BREAK settings rows and the assist bullet, `#strings` `#triangle` `#guard` `#kikon` (the old fight system's text), the four retired characters' sections and TOC entries, the old learner's habits text (the LEARNING CPU section is now the HARD Ichigo vs Kenpachi table and RESET LEARNING), the tips that taught K / L / U / I / O; header 「三個角色」; all `#` links resolve; 1,091 -> 615 lines. **Still old in the manual** (S9, the SP chapter, rewrites them): `#move`, `#burst`, `#awaken`, `#kosei`, `#blow` are the pre-core text, and the three characters' move tables are the old K / L / U / I / O tables), DUEL_GAMEPLAY (the scripts table rows, the looks gate paragraph, II / IK / KK in the debug rows, 2365 / 2366, 2500+k, the stale usage lines of simgate, the Yamamoto stills paragraph), AGENTS.md (the looks row: 75, BASE clause), README.md (roster table and screenshots of the retired characters out, modes ENDLESS / DANGAI out, the CPU paragraph; **new screenshots of the three characters are still owed**: `docs/duel/readme/{fight,roster,yama-bankai}.png` are no longer linked), docs/README.md (DUEL_AI_V2 / LEARNING / ASSIST / ENDLESS / ROGUE / ROGUE_B1_PLAN marked removed 2026-11-13), five skill lines, `tools/combo-trial.py` and `tools/aieval.py` examples. **Proof**: host tests 2960 ALL PASS; pkgcheck only `DUEL::APP`; debug-ranges 84 ranges, 0 errors; `simgate.py --cvc` II 39, IK 36, KK 28 lines identical; smoke desktop and `--mobile --size 390x844` exit 0, startup heap 74.8 MB (as before), wasm 10,264,852 -> 10,264,933 B (+81 B, PORTRAIT-TEST). **Scripts run on the new build** (`--fixed-dt 16.666667`, `--mobile --size 390x844` for the phone ones, the host at load 85-150, 4 streams): **28 of the 35 remaining `tests/scripts/duel-*.json` ran to their end with exit 0, no `stopped:` / exception line**: mobile, mobile-insets (both past debug 2700 to RESULTS), touch, touch-left, ichigo, ichigo-portrait, practice, flow, keys, extras, strings, bankai, cvc-ii / ik / kk (RESULTS lines equal the G2 references: II 3-1 ticks 23379, IK 2-0 ticks 21243, KK 0-5 ticks 16521), hisagi-bankai / j1-cancel / kin / ns2, ken-armburst / core / sealed, shikai-dswitch, steal-cap, sublimation, blue-burn, drive-switch, switch-routes. **Not finished** (stopped at about 70 minutes of wall time, no error in their partial logs): drive-switch-phone, ken-bankai, ken-shikai, practice-cancel, shots (an earlier try of shots hit my 1,400 s wall cap; its partial log shows the menus, the CPU match, BUTTAGIRU and the guard break as in the table). duel-gate, duel-perf are long or real-time and were not run (the `duel-view-*` JSONs belong to the duelview build). **Not done / for the lead**: the five scripts above (they ran identically on BASE and new at R4 and R3 and nothing they use changed here), duel-gate / duel-perf, `style-gates.py duelstill` against a built `dist/duelview` (the commands 2004 and 4004 are in duel-view.lisp's header; not built here), the self-render of the new build against a copy of itself (argument above).
| **R8** | B11 (D6) | untrack the 37 batch-* / webgl-* stills, move the style-2..6 / batch scripts to docs/research/style-history/, fix citations; decide `.gitattributes` (untracked today) with it. Done on branch: 37 stills untracked, 12 scripts moved, citations fixed; `.gitattributes` stays local (graphify's merge driver for the ignored graphify-out/, excluded in .git/info/exclude). | docs grep | low | Haiku | anytime |
| **R9** | B1 redone | dead engine exports re-derived against today's engine/lisp (10.1's list as the start), ENGINE_API.md synced (RAVEN lines, the missing exports, the Lisp HUD's new exports). Done on branch worktree-agent-a74279fd66378a38e: 12 dead exports removed (`fx-burst`, `fx-debris` / `fx-debris-update` / `fx-clear-debris` / `*debris-life*` with the `*deb*` pool, `fx-clear-orbs`, `edge-vignette`, `fx-trail`, `mb-capsule`, `mb-flat-quad`, `set-loop-gain`, `audio-locked-p`), engine -139 lines, index.wasm 12,771,527 -> 12,760,456 B; ENGINE_API.md synced (RAVEN / game/ / examples lines gone, all 703 exports named, new sim-snapshot section; AUDIO.md two rows); looks 113 stills byte-identical (noise 0), G2 II 39 / IK 36 / KK 28 identical, host tests 10440, pkgcheck only `DUEL::APP`, engine tests pass; engine-check 71 pass / 2 fail (`%ui-poly4`, `ui-rect` consing), the same two on the unmodified base 027f784c. | pkgcheck, build, engine tests, engine-check, **R0's gate** | −150 lines, low | Sonnet | after R0|
| **R10** | ECS + pragmatic-FP audit (10.3 item 4) | Read-only, on the lean main (after R4): per file, state by home (component slot / struct / special), every special written inside the step and whether it is a snapshot root, logic that is pure today vs could be, the hidden channels (`*core-on*`, `*in-rollout*`, `*skip-cines*`, `*gauges-inf*`, `*dummy*`), what of `duel/` the ECS does not hold. Output: a § in this file with a ranked list; no code | review by the main session | a report | **Opus** | parallel to SP S1-S2 |
| **R11** | B2 + D7 | One batch because both rewrite each kit's debug hookup: the `define-debug-range` registry in the engine (overlap fails at load) replacing debug.lisp's `cond` and `*char-debug*`, the doc checker kept; the `defkit` hook-point table; shared knobs to tuning.lisp; `*core-on*` / `core-kit-p` removed (every kit is a core kit after R2: a hidden channel gone); `ichigo-pull-to` -> a generic pull | unit-forms (knob moves EQUAL), G2, fast, every debug command of the scripts still dispatches (the scripts' logs identical) | ~400 lines, medium (dispatch order) | **Opus** | after S9 (debug.lisp, kit.lisp, tuning.lisp, core-sim.lisp are SP's files) |
**R11 done, merged to main 2026-11-14** (2026-11-13, Opus 5.5 subagent; commits on `worktree-agent-a65f6bcda47828550`, one per item group). **Knobs**: `*core-pointer-max*`, `*core-kikon-max*`, `*core-soul-break-max*` (core.lisp), `*behind-turn*` (fighter.lisp), `*delay-hit-hold*` (combat.lisp) moved verbatim to tuning.lisp (unit-forms: the five forms EQUAL, absent from the diff). **`*core-on*` out** (§11.5 item 9) with every NIL branch (combat, fighter, kit, core-sim ×2, ichigo ×2, ichigo-look, webhud ×2: R14's file, two one-token edits) and the code only they reached: KESSA's `:step` hook `ichigo-step-clone`, `hoho-clone`, `ichigo-press`, `clone-pay!`, `clone-affordable-p`, `*clone-cost*`, ICS's `hoho-done` slot. `core-kit-p` never existed; the `(kit-core kit)` tests stay (a kit without `:core` is legal data: the host tests' binder kit). Host checks: **one restated, none removed** (core.lisp: the Shikai × Cornered 1.20 = 120 under the old NIL → 60 under the core scale, 0.42 × his `:core :mult` 1.2); flipping `*core-on*` to T in the two NIL files first showed it was the only dependent check. **Hooks as data** (item 10): Kenpachi's Shikai's `:p` KEN-P (a no-op) became the kit key `:run-awaken t` (KIT slot `run-awaken`; the host dump shows it on exactly the forms `:p` was on: Nozarashi); the `:p` hook point stays (sim.lisp's binder kit tests it). `:u` out: `u-press!`, its two call sites, `guard-held-p`'s clause, onehand's `u-chip-p`, `*u-chip-holds*`, the deck key's ninth slot. Hisagi's three `kit-meter` SETFs (hisagi-draw) are `:meter` keys of his three DEFKITs (the host dump: the same plists). **The hook-point table**: DEFKIT's docstring `:hooks` entry lists all 33 called kit points and the bind's six with arguments, caller and live users; the unused ones are named (`:p`, `:step`, `:hoho`, `:settled`, `:siphon`, the bind's six, `:body-alpha`, `:charge`); `:hud-guard` / `:p-label` had no caller left and are out of it; DUEL_DESIGN's 2026-09-29 table points at it. **The registry** (D7): `engine/lisp/debug-ranges.lisp` (plain CL, host-loaded; ENGINE_API "Debug command ranges"): `define-debug-range` (a handler name, or `(c)` + body), `debug-dispatch` (the narrowest range holding the command; an unclaimed one does nothing, as before), `debug-range-find`, `*debug-ranges*`; a partial overlap or a span claimed twice errors at load, the same handler on the same span replaces itself (the host tests load hisagi.lisp twice). E6's "declaration order = dispatch order" was not kept: nesting with the narrowest winning makes the order irrelevant, which is what the old checker's rule 1 enforced. `debug-command` keeps its preamble and calls `debug-dispatch`; its 69 `cond` clauses became 69 forms (bodies verbatim), the 17 `*char-debug*` pushes 17 forms; `*char-debug*` is gone. `tests/debug-ranges-check.py` reads the forms (rules 1-4 kept); `tests/debug-ranges-test.lisp` (16 checks) tests the registry. **Pull**: `ichigo-pull-to` and Hisagi's identical `hs-pull-to` are one `pull-opp-to` in fighter.lisp (T when it moved him: the callers ignore the value). **Debug knobs** (item 15): not reset on `start-match` (that would break the gates they exist for: 81020+i and the rule knobs must hold through a gate's every match, 2101 through duel-shots' later scenes); instead `start-match` logs `duel match knobs: …` naming each rule knob a debug command changed (`*red-threshold*`, `*gg-regen*`, `*gg-regen-guardless*`, 26000's K-link %), nothing while none differs (the scripts' logs unchanged); the gate / setup settings (`*gate-*`, `*konpaku-start*`) are left as they are. `scale-k-links` rewrites the kits' hit windows in place and nothing uses 26000+: a removal candidate (the lead's call). **At the merge** (the lead, 2026-11-14): Fable's read-only review found no behaviour change (dispatch 0..219999 routed alike, every removed branch unreachable, `pull-opp-to` token-identical); the leftovers it named went with the merge: `ichigo-ns-regroup` and `ic-reach-key` (no caller since `ichigo-press` left), sim.lisp's `'ken-p` exclusion, two stale debug.lisp comments. Still open for R15: `scale-k-links` / 26000+; the sheet tools (`tools/move-sheet`, `stat-sheet`, `matchup-sheet`) broken since SP (`SP-COST` undefined: their load lists need sp / core and now `debug-ranges`).
**Proof** (each commit, then the final head): native G2 II 36 / IK 40 / KK 38 lines identical to tests/style-cvc-ref.txt five times (base, after the knobs + `*core-on*`, after the hooks, after the registry, after the pull + knobs line; the reference not regenerated); host 2979 ALL PASS (one restated, none removed), control 124, input 33, touch 100, cine 18, hud-engine 121, ecs ALL PASS, debug-ranges-test 16 (new); pkgcheck only `DUEL::APP`; debug-ranges-check 86 ranges (17 through a character handler), 24 nested, 0 errors; sp-costs-check 114 PASS; unit-forms base vs the first commit: the five knob forms EQUAL (absent from the diff), the rest the edited functions; the 69 old `cond` clause bodies EQUAL (read forms, keyed by span) to the 69 inline range bodies; the old first-match owner = the new narrowest range for every command 0..1,300,000; native `2102 2650 26080 4007` logs `duel match knobs: *RED-THRESHOLD* 0.5 (written 0.3) *K-LINK-PCT* 80 (written 100)`, `2102 4007` no such line; build + smoke exit 0, startup heap 74.8 MB, index.wasm 10,284,829 -> 10,280,088 B; looks 75 / 75 stills bytes identical to the 315f18b6 BASE (noise floor 0); 17 browser scripts run on the 315f18b6 BASE and the new build (`--fixed-dt 16.666667`), every log identical but for the timing / stats lines, all exit 0: practice, practice-fs, practice-fs-phone, practice-cancel (2800-2815), steal-cap, switch-routes, sp-break, sp-cues, blue-burn (2610+k), ken-core (84000+), ken-shikai, bankai (`ken-debug` 2387 / 71000), ichigo (74000+), drive-switch (`ichigo-sub-debug` 86100+), hisagi-ns2, hisagi-kin (83000+), hisagi-bankai (the old `hs-pull-to` call sites). Not verified: that a load-time overlap stops the browser build visibly (the host load and the checker are the proven guards). Left: two stale comments in debug.lisp (`cine-still-command-p`'s "clause of DEBUG-COMMAND", the 2510-2512 line's "2513 below is reachable"); tools/matchup-sheet, move-sheet, stat-sheet were already broken on 315f18b6 (`SP-COST` undefined: their load lists lack sp / core, and now debug-ranges).
| **R12** | B4's remainder | `fq-online.lisp` naming settled by R4; core-ai's `strat-*` glue -> `strategy-glue.lisp`; `*in-rollout*` defined once; the rollout's bindings in one macro for `sim-rollout` and `mc-full-rollout`; the cross-style reads named in one file | unit-forms, G2, snaptest, fulltest | ~1.5k lines moved, medium | **Opus** | after S7 (same CPU files) |
**R12 done, merged to main 2026-11-14** (branch `worktree-agent-a6da18b1309bdc4db`, 2026-11-13, Opus subagent; seven commits on 315f18b6, a-f and the docs). **fq-online**: nothing
left to do. R4 already named the file (ai-learn.lisp is gone, `fq-online.lisp` holds the online fuzzy Q). **a. `*in-rollout*` once**: new
`rollout.lisp` (15 lines, loaded before core-ai) holds the one valued `defvar` and `with-rollout ((extra ...) body)`. That macro expands to
the seven bindings both lets had, in the same order. `sim-rollout` calls `(with-rollout () ...)`; `mc-full-rollout` passes its own
`(*cai-styles* nil)` and locals as extras. The bare `(defvar *in-rollout*)` in core-ai left. unit-forms with WITH-ROLLOUT expanded: only
that defvar out and the macro in. Trap kept as it was: `*gate-log*` and `*step-hook*` are defined in gate.lisp, after cpu-mcts, so in
`mc-full-rollout` they bind lexically. That is harmless, because a lean step never calls HASH-LOG; the macro's docstring says so. **b. The
glue** moved verbatim to `strategy-glue.lisp` (203 lines, loaded right after core-ai). From core-ai: STRAT-REACH, -FEATS, -FORM-INDEX,
-XFEATS, STRAT-HOLD-AWAKEN-P, *STRAT-JUDGE-HOOK*, STRAT-SWITCH-STEP and the event layer (STRAT-EVENT-STEP / -CALL). From cpu-mcts: the
whole strategy layer (STJOB ... STRAT-LOG). The DRIVE switch's presses (CAI-DSWITCH, CAI-SWITCH-PRESS / -TARGET, *CAI-SWITCH-COUNTS*)
stay in core-ai, renamed nothing. core-ai 349 -> 258 lines, cpu-mcts 362 -> 276. About 190 lines moved, not the row's 1.5k (B4's
estimate included ai.lisp's split, which R3 did). unit-forms: no form changed. The compiler's warnings and notes are identical to the
base's (21). **c.** Comments and *STRAT-JOBS*' docstring now point at strategy-glue. **d. Item 11**:
- `*strat-now*` became the brain's `now` slot. It is set where the binding was (after `sw` / `cur` / `ev`) and set back to NIL at the end
  of that body, so every step-end snapshot holds NIL as before. The state hash line does not walk BRAIN.
- STRAT-OUT and STRAT-SCALE take NOW as their first argument, which makes them pure. MC-EST takes it too. Every caller passes
  `(brain-now b)`.
- `*mc-select*` is gone: it is now MC-SEARCH's required SELECT argument (cpu-mcts, tools/simgate/litefit.lisp and teacher.lisp, the mcts
  host test).
- cpu-kh-ken's rebinding of `*kk-meaty-p*` / `*kk-ns-safe-p*` became KEN-KI-STYLE's keywords `:meaty` / `:safe`. Their defaults are the
  knobs, read at the call, so a tool that sets them still works. They are threaded to KK-TRACK / KK-NEUTRAL / KK-DECIDE / KK-PICK.

**e. The cross-style reads**: a table in strategy-glue.lisp's header. Rescanned on code only (strings and comments stripped), three remain:
- Hisagi's merged style calls KEN-KI-STYLE, the one call across characters.
- cpu-kh-ken uses KEN-KI-STYLE, KKS (`:include`), KKS-TICK / -PLAN / -APPR and KK-STICK.
- cpu-hk-hisagi uses HISAGI-MERGED-STYLE, HMS (`:include`), HR-SP and HR-TAKEN.

Ichigo's KI style reads no other style; B4's "K2's `kk-*` from Ichigo's file" and `*kk-hend-p*` now appear only in docstrings. HR-TAKEN
wrote `*mc-plan*` directly, through a second bare `(defvar *mc-plan*)` in cpu-hisagi-range. It now calls cpu-mcts's new MC-PLAN-DROP, and
that defvar left. **f. 11.5.2 D**: `sim-rollout` (offline: the teacher, snaptest) runs SIM-STEP-LEAN, as `mc-full-rollout` does, so no
feedback, sound or stage marks run inside it. It still keeps `*cai-styles*` (the teacher's semantics; `mc-full-rollout` turns them off).
The lead decides whether to unify that. Item 14 skipped (its row: "only if the next feature needs it").

**Proof**:
- G2 `simgate.py --cvc`: identical to tests/style-cvc-ref.txt (II 36, IK 40, KK 38 lines), not regenerated.
- Full native stdout, base fas against each new fas (only timing / heap lines filtered), identical for the three cvc matches, snaptest
  straight and pollute (IK gate, 4 seeds: 2008 rollouts), fulltest IK (148 checks, 0 differ) and FT_VS=1 (54, 0 differ), and
  strat-desc.lisp HARD KH and HK, 2 seeds a seat, `duel hash` lines included.
- HARD random-pairing matches (81022 2102 2000+s, s = 1 2 3 5 8, combat log on) identical to the base at R12e (f touches only the offline
  `sim-rollout`). Seeds 1 KH and 3 HK reach the wake-up bait
  (`khf bait armed` 28), the meaty roll, the merged style's `kk *` lines and the strategy tables. The stand-off breaker and the CPU's
  DRIVE switch did not fire in them.
- D's own check: a scratch harness ran full vs lean steps from one snapshot under WITH-ROLLOUT, every 40 ticks, comparing the state hash
  line and the sim RNG. IK gate: 2008 checks. HARD KH: 470. HARD HK: 465. 0 differ.
- strategy-eval: its cache key holds the build's hash, so a new build always misses; the proof is that the base and the new build give the
  same output. `--char kenpachi --vs hisagi --seeds 2 --no-normal` on `khfn/cand-standoff.lisp` and `cand-khfn.lisp` (the stand-off
  breaker's and the bait's styles, whose knobs item 11 touched): the printed results are identical (4/4 each), and so are the four cached
  raw outputs.
- FT_LAYER=t crashes on the base as on the new build, identically (`STRUCTURE-SET ... KKS ... not of the expected type IKST` at tick
  3430). This is a bug in the off-by-default strategy layer, not R12's: a layer pick changes BRAIN-STRAT without resetting BRAIN-STYLE.
  Left for R15.
- Host 2979 ALL PASS, duel-control 124, input 33, touch 100, cine 18, hud-engine 121; pkgcheck only DUEL::APP; debug-ranges 86 ranges, 0
  errors; sp-costs-check 114 PASS. `./build.sh duel`: index.wasm 10,286,727 B. Smoke (`run.mjs --fixed-dt 16.666667 --secs 8`): exit 0,
  startup heap 74.8 MB.
| **R13** | B7 less E6 / E7 | E1 the fuzzy core, E2 the hem spring -> anim.lisp `spring-chain-*`, E3 rebinding, E4 the settings table, E5 `resolve-tuning` | G2, host tests (duel-control, fuzzy, input), R0's gate | ~300 lines, medium | Opus | after S9 (fuzzy.lisp is S7's, control.lisp S9's) |
**R13 done on branch** (2026-11-14, Opus 5.5 subagent; five commits on `worktree-agent-a1a066494c9679f31` from 6fe20f4c, one per item and two of docs). Each item was checked again before it moved; two moved whole, one in part, two were skipped (YAGNI over the plan). **E5 moved**: `tuning-ref-p` and `resolve-tuning` verbatim to engine/lisp/package.lisp beside `plist-get` (exported; ENGINE_API "Package helpers"); kit.lisp's two callers unchanged, every host runner already loads package.lisp. **E1 moved**: new engine/lisp/fuzzy.lisp (MANIFEST after touch.lisp; ENGINE_API "Fuzzy inference") holds `fz-mu` and `fz-infer` (bodies verbatim, names kept: no call site changed) and `fz-sets!`, the load-time resolution that was duel's `dolist` (it had to move with `fz-mu`: the property key `fz-trap` is now ENGINE's, so a duel-side `dolist` would have written a key `fz-mu` never reads). duel/lisp/fuzzy.lisp keeps `*fz-sets*` (now `(fz-sets! *fz-sets*)`), `*fz-skill*`, `fz-scale` / `fz-chance` (they read `*fz-skill*`) and the rule bases. tests/duel-rules-test.lisp and tools/sp-cost-table.lisp load the engine file (the three sheet tools stay broken as R11 found them). **E3 moved in part**: `binding-input` / `binding-name`, the readers of the binding plists `vpad-read!` defines, verbatim to engine/lisp/input.lisp (ENGINE_API "Virtual controller"). `rebind`, `reset-bindings`, `bind-code`, `bind-from-code` stay in control.lisp: they read `*bind-actions*`, both default tables, `*bind-keys*` / `*bind-pads*` and `*prompt-cache*`, and the swap rule (one shared keyboard, a pad per player) and the saved codes are SOUL DUEL's; a generic version would add a policy parameter for one caller. **E2 skipped**: one live caller (Ichigo's cloak; debug.lisp's two lines only measure consing), and the pose bakes in the look (the obi's 0.06 m offset, the breath sines on the fx clock, the Ry Rx Rz order on the pelvis matrix): `spring-chain-*` would be ~8 arguments for one user; hem-spring.lisp's header says so (it had promised the move). **E4 skipped**: every function reads the game's `*settings*` / `*setting-ix*`, and `setting-from-page` encodes pwa.js's page contract (stored = index + 1, 0 = default); generic means a `defsettings` macro or the table threaded through ~15 call sites, for one game. **Proof** (on the final build): unit-forms with symbols compared by name (a scratch copy of tools/unit-forms.lisp printing with `princ`, the base unit's packages renamed so both load in one image; the stock tool flags every form that calls a moved name): only duel's `dolist` out, `fz-sets!` and its call in, and `fz-mu`'s docstring ("a name given to FZ-SETS!"); the five other moved definitions EQUAL (tuning-ref-p, resolve-tuning, fz-infer, binding-input, binding-name); the order warnings are the base's nine. Host 2979 ALL PASS (unchanged: no check added or removed), duel-control 124, input 33, touch 100, cine 18, hud-engine 121, debug-ranges-test 16, ecs ALL PASS; pkgcheck only DUEL::APP; debug-ranges-check 86 ranges, 0 errors; sp-costs-check 114 PASS. `./build.sh duel`: index.wasm 10,281,458 B. Smoke desktop and `--mobile --size 390x844`: exit 0, startup heap 75.1 MB. G2 native `--cvc` and browser `style-gates.py cvc`: II 36 / IK 40 / KK 38 lines identical to tests/style-cvc-ref.txt. Looks gate against BASE 315f18b6: 75 stills byte-identical, 0 noisy.
| **R14** | B6's remainder | one command decoder for webui / webhud; sw.js `FILES` from build.sh | smoke, duel-flow / duel-touch / duel-mobile scripts, an offline / install check by hand | ~80 lines, low | Sonnet | after S8 (webhud.lisp) | **R14 done, merged to main 2026-11-14** (2026-11-13): `ui-press-cmd` (webui.lisp) is the one decoder of the pointer commands both dispatchers share (1 cursor, 2 confirm, 4 left, 5 right); `webui-command` calls it and keeps 3 back / 6-8 (menu-only), `webhud-pause-cmd` is its guarded call. sw.js `FILES` is `@FILES@`, filled by build.sh with `./` plus every file of `dist/<target>` but sw.js (a new page file needs no list edit); the built list is the same 11 entries as the old hand list (order differs: `./` then alphabetical). Offline / install check for a human: open the built page over http, wait for the worker, go offline (DevTools Network), reload: the game and `manual.html` must load; a rebuild must install a new cache and reload once.
| **R15** | The audit's findings + wave 4 | What R10 ranks first (expected: specials written in the step moved into components or passed as arguments; pure cores split out of `apply-hit` and `gauge-system`), then wave 4's items only where the next feature needs them | per item: unit-forms or G2, snaptest / fulltest | open | Opus | last; the main session picks |
**R15a done on branch** (2026-11-14, Sonnet 5.5 subagent; four commits on `worktree-agent-ac830befe2bae3596` from 9b9c496f, one per item; no gameplay or visual change). **1**: `*fire-density*` was a defparameter in tuning.lisp and a defvar in vfx.lisp; `tests/duel-rules/unit-names.lisp` missed it because its variable half carried an exemption list (`*fire-density*`, `*weave-pass*`, "known harmless same-value pairs"; `*weave-pass*` no longer exists anywhere). The list is dropped, the check failed on exactly that one pair, vfx.lisp's defvar is gone and tuning's docstring carries its meaning; no other duplicate. **2**: debug range 26000-26999, `scale-k-links`, `*k-link-pct*` and its `duel match knobs` entry removed (85 ranges). **3**: the two `ya hem` cons-per lines and `*ya-hem*` (read by nothing else; the state layout is now a comment in hem-spring.lisp) removed; the file and `*ya-hem-m*` / the `*ya-hem-*` knobs stay for Ichigo's cloak. **4**: tools/move-sheet.lisp, stat-sheet.lisp, matchup-sheet.lisp deleted (docs/research left as is). **Proof**: host 2979 ALL PASS (same count: the checker's change is an edit, not a new check), duel-control 124, input 33, touch 100, cine 18, hud-engine 121, debug-ranges-test 16; pkgcheck only DUEL::APP; debug-ranges-check 85 ranges, 0 errors; sp-costs 114; native G2 II 36 / IK 40 / KK 38 identical to tests/style-cvc-ref.txt; smoke desktop and mobile clean; looks gate 75 stills byte-identical to the base (noise floor 0); smoke 8 s desktop clean, mobile 390x844 clean at 2 s (the 8 s run exceeds 400 s in software GL).

Dropped: B10 (D3), B7's E6 (now R11) and E7, B6's JS bridge, the old B1 patch; R13 (2026-11-14) dropped E2 (the hem spring: one caller, the look baked in) and E4 (the settings table: one game, pwa.js's page contract) and moved E3 only in part (the binding readers).

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

### 11.5 R10: the ECS + FP audit (2026-11-13)

Read-only (Opus subagent), on the lean main **581df983** (after R4); **line numbers in this section are 581df983's**. The yardstick is
the user's (2026-11-11, AGENTS.md "Design principles", DEVLOG §709): one job per module behind a small interface; state in data
(entities as ids, components as plain data, systems as functions over them); logic pure where the hot path allows; mutation kept to
named places; no hidden channels through specials. R6 (the Reiatsu internals) runs in parallel: what it removes (`gauges-reiatsu`,
`reiatsu-gain!`, the bind pool, `kikon-refund`'s Reiatsu argument, `*kosei-reiatsu*`, the R half of `pay-gauges` / `hit-gains`) is
marked "(R6)" where it shows and is not ranked. (This section was inserted as 11.5; the risks below it moved to 11.6.)

**Method and limits.** A small reader over every file of `engine/MANIFEST` and `duel/MANIFEST` (5,506 top-level forms) built a static
call graph: an edge is a distinct caller → callee pair (not a call site), from every symbol in a function's body that names a function.
"In the step" = reachable from `sim-step` (main.lisp:29) plus the functions named in kit / move data (`:hooks`, `:on-frame`, `:on-land`,
`:tick`, style `:fn`), but not the draw keys (`:draw :pose :body-alpha :charge :hit-fx :hud-tag :deck :look :label`); that reaches
~1,000 of duel's 1,664 functions and macros and over-counts (load-time `register-kit` / `register-move` / `build-clip` and the debug
scenes a data form names are in it). Writes = `setf` / `setq` / `incf` / `decf` / `push` / `pop` of a special, or of a place whose
arguments name one, or `fill` / `clrhash` / `replace` on one; `%set-float` writes (fighter.lisp:235-237) were added by hand. "Pure" =
no write outside its own bindings, no component read, no `emit` / `sim-rnd01` / `rnd01` / log / `funcall`, no special that any function
writes, and every callee pure (a fixpoint); macros count as pure, `funcall` as impure. Every row below that calls a slot or a branch
dead was checked with a whole-accessor grep over duel/ tests/ tools/ and the hash line (gate.lisp:10-27). Scratch scripts are not in
the repo.

#### 11.5.1 Where state lives, per file

The engine's ECS (ecs.lisp: 256 slots, one store per component kind) holds **11 components**: TRANSFORM (engine), MOTION, MODEL, BLADE,
FIGHTER (81 slots), GAUGES (35), PILOT, BRAIN (56), HAZARD (23) in components.lisp, HSS in hisagi.lisp, ICS in ichigo.lisp. duel/ has
1,449 `defvar` / `defparameter`; 230 of them are written by some function at run time (the rest are knobs and tables). Pure today: 374 of
1,664 functions (rules.lisp 97 of 101, strategy 25 / 33, kit 22 / 53, hisagi 21 / 90, control 17 / 22, core 7 / 7, sp 9 / 9, fuzzy 4 / 4).
"Mixed" in the last column = more than one job in the file.

| File | Job | State lives in | Mixed |
|---|---|---|---|
| package | the package | — | |
| tuning | shared knobs | 231 knobs; 5 set at run time by debug-command (debug.lisp:529-534: `*red-threshold*`, `*gg-regen*`, `*gg-regen-guardless*`, `*kosei-fs*`, `*kosei-reiatsu*` (R6)) | |
| rules | the rules, pure | none (97 / 101 pure; reads knobs only) | |
| core | the triangle, pure | none | |
| sp | SP rules, pure (S0, no caller yet) | none | |
| fuzzy | fuzzy terms, pure | knobs | |
| strategy | strategies as data, the selector's math | 30 specials; 4 written in the step by the strategy layer (`*strat-jobs*` 227, `*strat-stats*` 228, `*strat-picks*` 229, `*strat-library*` 539) + `*strat-now*` (48, bound per brain step) | yes: the library data, the pure math, and the job queue the CPU writes |
| control | controls, bindings, PRACTICE row helpers | data; `*prompt-cache*`, `*setting-ix*` | |
| sounds | the SFX bank | load-time only | |
| components | the component definitions + small helpers | 8 DEFCOMPONENTs; `*match-tick*` (293), `*pacing*` (274, per side), `*touch*` (296), `*one-hand*` (297), `*hand*`, `*coarse*`, `*back-press*`, `*pose-at*` | yes: the ONE-HAND device globals and the pacing log live here because fighter / flow read them |
| body | rigs, weapons, drawing a body | registries (`*bodies*`, `*weapons*`) + BODY / WEAPON structs (snapshot-shared) | |
| kit | DEFMOVE / DEFKIT, kit queries | load-time registries `*kits*` `*moves*` `*roster*`; MOVE / HITWIN / KIT structs (shared); memo `*cadence-moves*` (418) | |
| glyphs, glyphs-extra | generated glyph data | data | |
| brush | brush typography | glyph cache, draw scratch | |
| cinema | the cinematic grammar | ~20 specials, all snapshot roots (sim-state.lisp:18-21) | |
| stage | the plaza, its marks / cracks / debris | f32 rings + counters (`*st-nmarks*` 266, `*st-chips*` 267, `*st-chip-i*` 268, `*st-ncracks*` 52); not roots | |
| vfx, vfx-stamps, vfx-ember | shared looks | aura caches, the stamp ring, `*stamp-seed*` (vfx-stamps 25) | |
| hem-spring, tip-track | shared looks | knobs; per-draw scratch | |
| ken-art, ichigo-art, hisagi-art | clips and bodies | data | |
| ichigo-look | Ichigo's looks, hooks, sounds, cinematics, a consing probe | presentation specials; the probe writes FIGHTER slots (ichigo-look.lisp:489, 495; debug 74906) | yes (by design, round 2), plus debug |
| ken | Kenpachi's moves, kits, hooks, cinematics, debug scenes | FIGHTER / GAUGES slots (54 slot writes); no mutable special | yes: data + mechanics + cines + debug (84000-84099) |
| ken-look, ken-meter | his Shikai looks; two hooks | `*ke-kk*` scratch; none | |
| ichigo | moves, kits, the clone mechanics, debug | ICS component + ICC / ICE structs in it; memo `*ic-keys*` (445), `*parry-rims*` (953); 4 knobs set by `ichigo-debug` | yes: data + clones + debug |
| hisagi | kit, mechanics, debug scenes | HSS component; 107 specials (knobs); `*hs-trace*` (1336, debug, read by the :tick hook 1359) | yes: data + mechanics + debug |
| hisagi-draw | his looks | 14 mutable draw scratch specials; **sets `kit-meter` of three kits at load (1870-1875)** | yes: a draw file writes kit data |
| hisagi-cine, hisagi-stills | cinematics; debug stills / probes | none; stills write 94 FIGHTER slots (debug setups) | |
| fighter | FIGHTER-SYSTEM: vpad → command → state machine → physics; the human's camera-relative stick | FIGHTER / MOTION slots (165 slot writes); `*view-x/-z/-side*`, `*behind-yaw*` (212-215, roots); memos `*hide-sets*` (122), `*missing-clips*` (143) | yes: the view frame (220-250) is the camera's input math |
| combat | hits (collect, judge, apply), gauges, bursts, forms (awaken / Bankai / `set-form`), the round's settle and reset | GAUGES (66) / FIGHTER (32) slots; `*blow-aways*` 10, `*kikons*` 11, `*soul-breaks*` 15, `*pending*` 425 | **yes: four jobs** |
| core-sim | the core system's sim side | FIGHTER (42) / GAUGES (6) slots; no special; reads `*touch*` / `*one-hand*` (240-253) | |
| hazards | HAZARD-SYSTEM | HAZARD component | |
| scripted | the trial player | `*trial-script*`, `*trial-state*` | |
| cpu-perceive | the SNAP ring, presses, BRAIN-SYSTEM | BRAIN slots (ring of SNAP structs) | |
| core-ai | the generic core CPU + the strategy glue | BRAIN slots (43 writes); registry `*cai-styles*` (25); counter `*cai-switch-counts*` (218) | yes: CPU + the strategy layer's glue (R12) |
| cpu-ki-ken, cpu-ki-ichigo, cpu-kh-ken, cpu-hk-hisagi, cpu-hisagi-range | matchup / strategy style CPUs | their state structs in BRAIN-STYLE (KKS, IKST, KHS, KSO, HKS, HRS, HMS); knobs; `*hr-counts*` (cpu-hisagi-range 49) | |
| mcts-lite | the light model and search | preallocated buffers (`*mc-g*` 120, `*mc-w*` 122, `*mc-slots*` 115, `*mc-legal*` 125, `*mc-legal2*` 128), memo `*mc-recs*` (79) | |
| cpu-mcts | the in-game MCTS, full-sim jobs, the strategy layer's rollouts | `*mc-plan*` (45, per side, root), `*mc-jobs*` (48), `*mc-full-stats*` (49), `*mc-next*` (114, root), `*in-rollout*` (44) | yes: action jobs + strategy jobs (R12) |
| fq-online | the online fuzzy Q | `*fq-tables*`; BRAIN-FQL | |
| camera | the two cameras | `*pcam*`, `*cam-ang*`, `*cam-dist*`, `*pt-lens*`, `*punch-t*` (20), `*cam-cut*` (19, root) | |
| feedback | events → sounds, sparks, words | `*hums*` (29, per side) | |
| flow | screens, match start / end, **the PRACTICE sim** (`practice-step` 291, from MATCH-SYSTEM), the pause menu | 27 mutable specials: `*flow*` `*timer*` `*winner*` (roots), `*p1*` `*p2*`, `*mode*`, the PRACTICE options (`*dummy*` 212, `*dummy-counter*` 213, `*hp-refill*` 215, `*gauges-inf*` 216, `*practice-rows*` 218, `*practice-aw*` 227, `*practice-aw-done*` 228) | **yes: screens + a sim system** |
| hud, hud-screens | canvas words; the frame's UI entry | `*words*` (hud 22) | |
| onehand | the touch deck's input, geometry, page saves | `*deck*`, `*deck-rect*`, `*touch-burst*`, `*wake*` ... | yes: input + layout + storage |
| webui, webhud | the menus' / battle screens' models | `*ui-sent*`; `*hud-sent*`, `*hud-strs*` (fixnum / string vectors) | |
| lhud-data, -geom, -charset, -menu-data, -menu-geom | HUD tables and pure layout | data (mostly pure) | |
| lhud-model, -plate, -fx, -deck, -clock, -overlay, -battle, -shapes, -menu, -menu-front, -menu-set, -menu-select | the Lisp HUD and menus | the model (webhud's vectors) + preallocated tween / clock specials per element (`*lhud-*`, `*lm-*`) | |
| gate | the hash line, the seed gate, Kenpachi's cup pacing | `*gate*` ... (9 mutable), `*cup-acc*` | yes: hash line + gate + one character's pacing |
| debug | debug commands, scenarios, probes | `*probe*` (29, written by `probe-update` in the step), `*god*` (21) ... | debug by nature (R11) |
| sim-state | snapshot roots, the two rollout runners | none | |
| draw | the scene and the fighters | MODEL slots; `*form-grade*`, `*oni-k*` | |
| main | entry, the fixed step, slow-motion drawn smooth | `*slow-acc*` (12, root), `*slow-was*` / `*slow-now*` / `*slow-drawn*` (63-65) | yes: the step + a look |

Engine files the duel step reaches (lean step; `sim-step` adds feedback's audio / fx): **ecs** (the stores, roots; `*events*` 163,
drained each step), **time** (`*hitstop*` 14, `*tick*` 15, `*slowmo*` 17: roots), **cine** (`*cine*` 28 root; `*cine-cam*` 34 and
render's `*grade-split*` / `*grade-desat*` written by `start-cine` / `end-cine`, not roots), **input** (the vpad inside PILOT), **anim**
(the ANIM inside MODEL), **hitvol** and **math** (pure), package's `sim-rnd01` (C state, saved by the snapshot), and **touch**
(`touch-active-p` / `touch-hi-at-p`, read by core-sim: 11.5.3).

#### 11.5.2 Specials written inside the step, by consequence

Roots = `snapshot-roots` (sim-state.lisp:11-21, snapshot.lisp:24-26). The snapshot is taken only in battle, outside a cinematic and
unpaused (`sim-snapshot-ok-p`, sim-state.lisp:25), at the end of `sim-step` (`mc-full-step`, main.lisp:42), after `feedback-system` has
drained `*events*`. In-game rollouts run `sim-step-lean` (no feedback, no hash log, no full-sim step) under `mc-full-rollout`'s bindings
(cpu-mcts.lisp:212-213).

**A. Sim state, rooted (fine).**

| Special (defined) | Written at |
|---|---|
| `*match-tick*` (components 293) | main 31, sim-state 42 |
| `*slow-acc*` (main 12) | main 34, 36; sim-state 45, 47 |
| `*timer*` / `*winner*` / `*flow*` (flow 30 / 37 / 19) | match-system 206; match-over 170, time-up 181; set-flow 48 |
| `*pending*` / `*kikons*` / `*blow-aways*` (combat 425 / 11 / 10) | collect-melee 433, 446, hit-apply 497-499, hazards 88; apply-hit 276, settle-souls 719; apply-hit 332 |
| `*mc-plan*` / `*mc-next*` (cpu-mcts 45 / 114) | cpu-mcts 161, 174, 231, 246, 262, cpu-hisagi-range 72; cpu-mcts 138 |
| `*view-x*` `*view-z*` `*view-side*` `*behind-yaw*` (fighter 212-215) | view-step 234-237 |
| engine: ECS stores, `*hitstop*` `*tick*` `*slowmo*`, `*cine*` | ecs 108-132; time 22-59; cine 72, 84 |
| cinema's roots (`*cine-placed-e*`, `*screen-fx*`, `*impact-next*`, `*cam-cut*`, `*caption*`, `*card*`, `*cine-close*`, `*cine-subject*`, `*lens-fov*`, `*dutch*`, `*silhouette*`, `*splash-args*`, `*cine-grade*`, `*draw-scale-e*`, `*aura-off*` ...) | the cinema.lisp grammar (93-288) and the scripts' `at` forms |

**B. Sim state, not rooted, drained before any snapshot (safe today; a consistency gap).**

| Special | Why it is empty at a snapshot | Note |
|---|---|---|
| `*soul-breaks*` (combat 15) | pushed only by `queue-soul-break!` (191) from `deal-damage` (185), whose callers are `apply-hit` and `delay-hit-hook` (combat 159, a hazard of HAZARD-SYSTEM); settled in the same step by `settle-souls` (719). The one way to carry it over a step, a cinematic started between HAZARD-SYSTEM and HIT-SYSTEM (main 23-24), also forbids the snapshot until it ends | its siblings `*pending*` / `*kikons*` are roots; it is not |
| `*events*` (ecs 163) | drained by `feedback-system` (live) / `take-events` (lean, sim-state 49) | |
| `*mc-jobs*`, `*mc-full-stats*` (cpu-mcts 48-49), `*strat-jobs*` `*strat-stats*` `*strat-picks*` `*strat-library*` (strategy 227-229, 539) | written only outside rollouts: `mc-neutral` returns at once in one (cpu-mcts 126), `mc-full-step` / `strat-layer-step` test `*in-rollout*` (243-244, 310) | the jobs hold snapshots themselves |
| `*cai-switch-counts*` (core-ai 218), `*hr-counts*` (cpu-hisagi-range 49) | the increments test `*in-rollout*` (core-ai 222, cpu-hisagi-range 52) | stats |
| `*mc-g*` `*mc-w*` `*mc-slots*` `*mc-legal*` `*mc-legal2*` (mcts-lite 115-128) | scratch, rewritten by `mc-setup` before each search; no search inside a rollout | 0 B buffers |
| memo caches `*hide-sets*` (fighter 122), `*missing-clips*` (143), `*mc-recs*` (mcts-lite 79), `*ic-keys*` (ichigo 445), `*parry-rims*` (953), `*cadence-moves*` (kit 418) | monotonic, value-identical whoever fills them | |

**C. Presentation written by sim code (not restored; the one real leak).** `ground-scar` (ken.lisp:428-433) writes the stage's mark and
debris rings (`stage-mark`, `stage-debris`: stage.lisp:276-295, cosmetic `rnd-range`) and is called from **move hooks**, not from
feedback: Buttagiru's `:on-frame ((22 ken-ground-crack))` (ken.lisp:39 → 419; the sealed kit's `:sp1` command, ken.lisp:176, which a
core match may never press: not verified), the Bankai J5's `((13 ken-bk-slam))` (281 → 425) and
TATE-GOTO's `ken-tategoto-split` (364). They run inside `sim-step-lean`, so a CPU rollout that reaches those frames leaves a crack and
chips on the live stage that the match never made (and draws the cosmetic stream). fulltest digests `*st-nmarks*` / `*st-chip-i*`
(numbers), so its "0 differ" means the sampled jobs did not reach those frames, not that the path is safe. The other
stage writers are feedback.lisp's (51-169) and the cinematics' (`stage-crack-add`): both outside rollouts. Also presentation, harmless:
`set-flow` (flow 48) writes `*ft*` / `*menu*` at a rollout's K.O. (`*ft*` is read only on TITLE / RESULTS); `start-cine` / `end-cine`
zero `*grade-split*` / `*grade-desat*` and `*cine-cam*` in a rollout (nil / 0 at any snapshot); `*practice-aw-done*` (flow 228) can flip
inside a PRACTICE rollout with DUMMY CPU (P1's awakening; not verified).

**D. Offline only.** `sim-rollout` (sim-state.lisp:29-37: snaptest, teacher) runs the full `sim-step`, so `feedback-system` (sounds,
`*hums*`, `*punch-t*`, `*words*`, stage marks) runs inside those rollouts, and it does not bind `*cai-styles*` NIL as `mc-full-rollout`
does (cpu-mcts.lisp:213). One shared binding form is R12's item.

**Determinism greps.** `get-internal-real-time` in the step only feeds stats (cpu-mcts.lisp:247/265, 337/351: `*mc-full-stats*` /
`*strat-stats*`, skipped by fulltest). `rnd01` / `rnd-range` in step-reachable code: only the cosmetic paths above and cinematic helpers
(ken.lisp:707-825). No sim decision reads them.

#### 11.5.3 Hidden channels

Specials that change what a function does without being passed to it.

| Channel | Defined | Set by | Read by (behaviour changed) | Verdict |
|---|---|---|---|---|
| `*core-on*` | tuning 458 | only host tests: tests/duel-rules/core.lisp:2, ken.lisp:2 / 39 (NIL: they quote pre-core damage numbers), triangle.lisp:3, mcts.lisp:3 | kit 395 (damage scale), combat 155, core-sim 262, 339, fighter 156, ichigo 648, 735, 815, 1043, 1048, ichigo-look 397, webhud 72, 142 | always T in the game: every NIL branch is dead in play. KESSA's `:step` hook `ichigo-step-clone` (ichigo 643) is a no-op (its first clause), `hoho-clone` (655) unreachable. R11 removes it; it must first restate the host checks that set it NIL (core.lisp, ken.lisp) in core-scaled numbers |
| `*in-rollout*` | cpu-mcts 44 (re-declared core-ai 217) | bound by `sim-rollout` (sim-state 33), `mc-full-rollout` (cpu-mcts 212) | cpu-mcts 126, 243, 244, 310; core-ai 222, 238, 239, 254, 273; cpu-hisagi-range 52; flow 186 (`go-results`) | a legitimate mode flag (no search, no learning, no results inside a rollout); defined once and bound in one form by R12 |
| `*skip-cines*` | engine cine 29 | gate 128, 167; debug 214, 227, 337, 494, 559, 564; ken 953; hisagi 1477; trial.lisp 21; both rollouts | `start-cine` (cine 77) | a debug / rollout switch with one reader; fine |
| `*gauges-inf*`, `*dummy*`, `*dummy-counter*`, `*hp-refill*`, `*practice-rows*`, `*practice-aw*` | flow 212-227 | the pause menu `pause-do` (flow 436-438), debug 226, 229, hisagi 1476 | `practice-step` (flow 291-313): writes the dummy's BRAIN presses (298-303) and both sides' GAUGES every sim step | the PRACTICE options are a sim input kept in six specials; S9 adds a seventh (a GAUGES row) |
| `*mode*` | flow 23 | menus, debug, gate | match-system 205, match-over 164, **ichigo-struck (ichigo 1022)** | a kit hook asking the game mode (PRACTICE's EARLY / LATE callout) |
| `*touch*`, `*one-hand*`, `*p1*` | components 296-297, flow 29 | onehand's frame, the menus | `core-touch-p` (core-sim 240), `core-touch-sp-p` (244), `core-held-p` (250) → the Kikon hold (`core-hold-step` 230, `apply-hit` 270, `delay-hit-hook` 156) | **the sim reads a device outside the vpad.** A replay of the vpads cannot reproduce a phone Kikon, and a rollout's P1 (the stand-in brain of `mc-full-roll`, cpu-mcts 232) reads the human's live thumb |
| `*strat-now*` | strategy 48 | bound per brain step (core-ai 298) | core-ai 45, 122, 311; cpu-mcts 120; cpu-hisagi-range 184, 186; strategy 52, 56 | an implicit argument of the strategy's cues |
| `*mc-select*` | mcts-lite 133 | bound per decision (cpu-mcts 131) | mcts-lite 323 | an implicit argument of `mc-search` |
| `*kk-meaty-p*`, `*kk-ns-safe-p*` | cpu-ki-ken 111, 214 (knobs) | **rebound** by cpu-kh-ken 47, 95 around `ken-ki-style` | cpu-ki-ken 352, 532, 597 | one style CPU reaches another's knobs to change its decisions |
| `*cai-styles*` | core-ai 25 | `cai-defstyle` at load; bound NIL in `mc-full-rollout` (cpu-mcts 213); tools REMF it | `cai-style-fn` (core-ai 31) | registry; the two rollout runners disagree (11.5.2 D) |
| the brain asked by a rule | — | — | `core-switch-ready-p` (core-sim 116-120): a switch is legal for a human, or for a CPU only while its press is a strategy's `:switch` | a rule that depends on who drives ("human vs CPU is only has-a-BRAIN", components.lisp header). S6 rewrites this function |
| hooks used as flags | — | — | `(kit-hook kit :p)` picks `*run-commands-p*` (fighter 859, 432-435): KEN-P (ken-meter 9) exists only for this; `(kit-hook kit :u)` (fighter 468, 475, onehand 266): no live kit has a `:u` hook, so `u-press!` and both tests are dead | a presence test standing in for kit data |
| debug-mutated knobs | tuning, ichigo 35-46 | debug-command (debug 529-534), `ichigo-debug` (`*clone-life*`, `*clone-burst-dmg*`, `*clone-scale*`, `*kessa-parry-catch*`) | their rules | never reset in the page: a debug command changes a later match |
| tool hooks | gate 67, core-ai 223 | tools/simgate (`*step-hook*`, `*strat-judge-hook*`) | hash-log 70; core-ai 238 | observers; NIL in play; fine |
| log switches | `*combat-log*`, `*pacing-log*`, `*gate-log*`, `*log-mute*` | debug, gate, rollouts | output only | fine |

#### 11.5.4 Pure today, and the cores worth splitting

Already pure (host-tested or testable as they stand): rules.lisp (97 / 101), core.lisp, sp.lisp, fuzzy.lisp, most of strategy.lisp,
control.lisp's PRACTICE helpers (`dummy-cancel-press`, `dummy-guard-left`, `practice-reishi`), kit.lisp's queries (`kit-atk-mods`,
`kit-def-mods`, `mv-total` ...), core-sim's `core-charge-mult`, `core-next-as`, `core-seg-ok-p`, `core-window-class`, Hisagi's 21
(`hs-dist-mult`, `hs-charge-scale` ...), cpu-perceive's SNAP readers, `mc-est`. Untested pure functions are host-test candidates only
where a rule hides in them (`core-next-as`, `hs-dist-mult`, `kit-atk-mods`).

The functions the brief expected to split, as they are at 581df983:

| Function | Pure core today | What is left | Split now? |
|---|---|---|---|
| `hit-gains` (rules 492) | **is pure** | — | no |
| `core-on-hit!` (core-sim 359-368) | `steal-take` (rules) | two `setf`s of `gauges-fs` and a log line | no split; but see the fs writers below (S1) |
| `pay-gauges` (combat 114-119) | `gauge-add`, `burst-fs-gain`, `sub-of`'s `sub-frac` | after R6: one `gauge-add` line | a named pure `(fs-gain fs gain burst sub-frac)` in rules.lisp would make S3's gains host-testable; S3's first commit |
| `gauge-system` (combat 767-805) | `fs-regen`, `gg-regen`, `gg-idle-next`, `stun-decay`, `burn-amount` (all rules) | the per-step shell: burst step, the awakening's regen, form timers, the kit `:tick`, EVOLUTION's latch | no: the rules are already out; S1 changes `fs-regen`'s cap (pure) and passes it; S4 adds one step here |
| `apply-hit` (combat 219-414, 196 lines) | `resolve-contact`, `kikon-outcome`, `combo-step`, `stun-add`, `hit-damage`, `hitstun`, `blockstun`, `chip-damage` | the gathering of their inputs from four components, then ~25 writes, 6 `emit`s, 4 hook calls | **one seam during S2** (below); the full split after S5 |
| `deal-damage` (combat 169-186) | `soul-break-p` | Reishi, stats, the bind hook, a write into the CPU's BRAIN (`brain-heat` 180), combo damage, both sides' gains, the soul-break queue | after S5 |

**The `gauges-fs` writers** (what S1-S3 rule on; no kit hook writes the gauge today, only a debug line, ichigo.lisp:1150):

| Site | What | Through |
|---|---|---|
| fighter 356 `spend-fs` | the spend (Hoho 362, TSUKI's dash ichigo 536); resets `fs-idle` | the named spend |
| combat 119 `pay-gauges` | every gain (hits, KOSEI): no gain in a burst, x (1 + `*sub-fs*` x SUB) | the named gain |
| combat 603 `burst-step`, 777 `gauge-system` | the burst's drain; the regen | the per-step system |
| **core-sim 366-367** `core-on-hit!` | the steal: the victim loses TAKE **without** `spend-fs` (his `fs-idle` is not reset), the attacker gains **without** `pay-gauges` (gains inside his own burst, no SUBLIMATION factor) | neither. S1 rewrites the steal's floor; the `fs-idle` and burst / SUBLIMATION points are not among DUEL_SP 8.6's questions (Q1 settles only paying and refunding): a question for S1 |
| **combat 724** `settle-souls` | the Kikon / Soul Break refund (`kikon-refund`, its Reiatsu argument R6) | neither; kept by DUEL_SP Q4. Whether it should pass `pay-gauges` (no gain in a burst: the reset ends the burst first, combat 721, so the same today) is S3's to state |
| flow 312 `practice-step`; debug 205, 259-260, 520; core-sim 372 | PRACTICE's infinite gauge; debug scenes | settings / debug |

**The `apply-hit` damage seam for S2.** Today the damage is `(hit-damage base atk dmods scale counter orange)` (combat 307-313) with
`atk = (kit-atk-mods kit lost px form-mult)` (259-266), where `px = core-charge-mult x (1 + *sub-dmg* x sub-of att) x the kit's
:dmg-mult hook` (262-265). S2's `sp-scale` is one more factor of PX. Extract `(hit-px charge sub-frac dmg-mult &optional (sp-scale 1.0))`
→ a single-float, pure, into rules.lisp (or sp.lisp) as S2's first commit: the impure side keeps gathering the four numbers (and S5's
hazard keeps its frozen scale in its slot), and S2's "a scaled hit's reaction and stun equal the full hit's" is then a host check of
the seam plus the scripted scene. The reaction, stun and combo fields stay on the other side of the seam (`combo-step`, `stun-add`),
so damage-only scaling holds by construction.

**Wait until after S5:** the outcome-record split of `apply-hit` (inputs: def-state, flags, ranged, ward, in-front, rush / held / fstrike,
red, combo counters, burst; outputs: res, outcome, follow, react, dmg, stun, the stun gauge, blow), the `deal-damage` split, and moving
gauges / bursts / forms and the round out of combat.lisp: S2, S3, S4 and S5 each edit `apply-hit`, `pay-gauges`, `core-nohit!` and
`gauge-system`, so a move now only makes their diffs conflict.

#### 11.5.5 What of duel/ the ECS does not hold

| State | Lives in | Per | Note |
|---|---|---|---|
| the two fighters' handles | `*p1*` `*p2*` (flow 29) | match | fine (handles) |
| the CPU's full-sim plan | `*mc-plan*` (cpu-mcts 45: 5 fixnums per side, root) | fighter | BRAIN-shaped state in a flat special indexed by side |
| the CPU's jobs | `*mc-jobs*`, `*strat-jobs*` | fighter | lists of vectors / STJOBs holding snapshots; not roots by design |
| per-side stats | `*pacing*` (components 274), `*cai-switch-counts*`, `*hr-counts*`, `*hums*` (feedback 29) | fighter | logs / sound handles |
| the human's view frame | `*view-x*` `*view-z*` `*view-side*` `*behind-yaw*` (fighter 212-215, roots) | human | could be a slot of P1's PILOT |
| P1's gesture recogniser | `*touch*` (components 296), `*one-hand*` | human | read by the sim (11.5.3) |
| the step's hit queues | `*pending*`, `*kikons*`, `*soul-breaks*` (combat) | step | intra-step channels between `apply-hit` and `settle-souls` |
| the match | `*match-tick*`, `*timer*`, `*winner*`, `*flow*`, `*blow-aways*`, `*slow-acc*`, `*mc-next*`; engine `*hitstop*` `*slowmo*` `*tick*` `*cine*` | match | roots; a "match" entity would hold them, but nothing needs that |
| PRACTICE's options and latch | flow 212-228 (seven specials) | match | a sim input outside the ECS |
| the cinematic's world | cinema.lisp's ~20 roots | match | presentation the sim's step sets |
| the stage's marks | stage.lisp's rings | match | presentation (11.5.2 C) |

Dead or write-only component slots (whole-accessor grep, duel/ tests/ tools/, the hash line): FIGHTER `cancelled` (0 uses), `seal`
(read at combat 448 and decremented at fighter 1082, never set above 0), `step-open` (cleared at fighter 325, read at 1009, never set T),
`block-adv` (written at fighter 985, never read); BRAIN `intent-t`, `break-key`, `bankai-rolled`, `aim-key`, `aim-plan`, `aim-t`,
`reflect-key`, `reflect-go` (0 uses), `react-roll` (written at cpu-perceive 91, never read), `heat` (only ever set to 0, combat 180;
**printed in the hash line**, gate.lisp:24), `intent` (read only by the debug overlay, debug 651); GAUGES `form-total` (written at combat
623, never read); MODEL `t3` (0 uses). Kit data: the `:ai` plists of six kits (ken 3, ichigo 2, hisagi 1) have no game reader: `kit-ai` is
read only by host tests (tests/duel-rules/hisagi.lisp:236, 608, 1006-1009; systems.lisp:53), which pin the data and go with it. The guard's slots (`glock`, `guard-t`, `ward-until`, `crush` / `stored` / `dmg-bonus` of the stance) are reachable only
through paths R3 listed as unreachable for a `:core` kit; they go with the guard, not here.

#### 11.5.6 Coupling hot spots

Distinct caller → callee pairs from one duel file into others (fan-out), and slot writes by file (`setf` / `incf` / `decf` / `push` of a
component accessor; a multi-pair `setf` counted once per place):

| File | Pairs out | Files reached | Top targets | Component slot writes |
|---|---|---|---|---|
| combat | 172 | 8 | rules 59, components 43, fighter 23, kit 22, core-sim 16 | 105 (GAUGES 66, FIGHTER 32, MOTION 4, BRAIN 2) |
| ichigo | 142 | 14 | components 38, fighter 27, ichigo-look 14, hazards 14, debug 13 | 39 |
| fighter | 136 | 9 | rules 43, kit 34, components 30, combat 13, core-sim 9 | 165 (FIGHTER 150) |
| debug | 122 | 30 | flow 11, brush 8, fighter 7, vfx 7 | 65 |
| cpu-ki-ken | 105 | 7 | components 38, core-ai 27, kit 16, fighter 10 | 26 (BRAIN) |
| hisagi | 104 | 11 | components 59, fighter 9, kit 8, debug 7 | 27 |
| flow | 65 | 18 | kit 11, onehand 9, control 8, fighter 7 | 40 (GAUGES 19, BRAIN 14, FIGHTER 7) |
| core-sim | 57 | 5 | kit 18, components 16, fighter 12, rules 6, core 5 | 48 |

Fan-in: fighter, components 27 files each; kit 26; lhud-plate 24; rules 19. Read: the sim's coupling runs one way (systems → rules /
kit / components), which is the intended shape; the hot spots are the cross-module **writes**:

- **combat writes the CPU**: `deal-damage` zeroes `brain-heat` (combat 180), a dead anti-stall heat that the hash line still prints;
  `reset-round` clears `brain-press-left` (761).
- **flow writes the sim**: `practice-step` writes the dummy's BRAIN presses and both GAUGES every sim step (flow 295-313); 19 GAUGES and
  14 BRAIN writes in a screens file.
- **kit hooks write GAUGES directly** (ken 32, ichigo 14, hisagi 12 slot writes; the meter, Reishi, flags), not through a named place;
  none writes `gauges-fs` (above), which is what the SP batches need.
- **a draw file writes kit data**: hisagi-draw.lisp:1870-1875 sets `kit-meter` of three kits at load.
- **a look file writes the sim's slots** for a probe (ichigo-look 489-495) and hisagi-stills 94 FIGHTER writes: debug code in art files
  (R11's registry).
- **hooks that are side effects or flags rather than data**: KEN-P (`:p`, a no-op kept so `*run-commands-p*` applies, fighter 859);
  `:u`'s presence tests (fighter 468, 475; onehand 266) with no `:u` hook on any live kit; KESSA's `:step` hook, a no-op under
  `*core-on*`; ken.lisp's `:on-frame` look hooks that write the stage (11.5.2 C) where the rest of the kit emits events
  (`:ken-bk-burst`, `:sfx`).
- **the sim reads the human's device** (core-sim 240-253) and **a rule reads the brain** (core-sim 116-120): 11.5.3.

#### 11.5.7 Ranked changes for R15 (and for the SP batches)

Ordered by value per risk; cheap fixes in files SP does not touch first. Proof words as in 11.3 (fast, G2, hash, unit-forms, snaptest /
fulltest); "looks" = the looks gate's stills against a same-session BASE.

| # | What | Why (principle) | Size | Risk | Proof | When |
|---|---|---|---|---|---|---|
| 1 | `ground-scar`'s three callers (ken 364, 419, 425) emit an event (`:ground-scar p yaw ds r`) and feedback.lisp makes the marks | rules never call code that shows (ecs.lisp header); stops the rollout leak (11.5.2 C) | ~15 lines (ken, feedback) | low | fast, G2 and fulltest identical; looks diffs expected and reviewed (`stage-debris` draws the cosmetic stream, so moving its call into feedback reorders those draws, and rollouts stop advancing it): only chips and marks may move | **now**, side lane; S2 also edits ken.lisp (`:sp-cost-mult` in four `:core` plists, DUEL_SP 8.2): other forms, a trivial merge |
| 2 | add `*soul-breaks*` to `snapshot-roots` (sim-state 11-12) | one rule for the three hit queues; safe today only by an argument about cinematic timing | 1 line | none | fast, snaptest / fulltest, G2 | now (or with #1) |
| 3 | remove the dead slots of 11.5.5 (FIGHTER `cancelled` `seal` `step-open` `block-adv`; BRAIN `intent-t` `break-key` `bankai-rolled` `aim-*` `reflect-*` `react-roll` `heat` `intent`; GAUGES `form-total`; MODEL `t3`) and the kits' `:ai` plists; `heat`'s hash column by R6's method (compared stripped, then the reference regenerated for the format) | data that means nothing; one fewer cross-module write (combat 180) | ~60 lines | low | fast, G2 stripped of `h`, snaptest / fulltest, pkgcheck | **after R6, before S2** (S2 / S4 add FIGHTER / GAUGES slots); the `h` column leaves inside S2's own hash regeneration (S2 adds `sp-paid`, DUEL_SP 8.3), so the format changes once there |
| 4 | `hit-px` seam (11.5.4) | pure where the hot path allows; S2's scale becomes a host-tested argument | ~15 lines | low | unit-forms not applicable (a refactor inside S2): G2 identical before S2's knobs move | **during S2**, its first commit |
| 5 | `fs-gain` pure core of `pay-gauges`; decide the steal's and the refund's path (spend-fs / pay-gauges or stated exceptions) | one named writer per gauge direction | ~10 lines + two rule answers | low (the answers may move G2) | host test; G2 identical for the pure move; the answers by S1 / S3's neutral-knob method | **S1** (the questions), **S3** (the core) |
| 6 | `core-switch-ready-p` stops reading the brain: the CPU's gate moves to `cai-switch-press` (core-ai), the sim's legality reads only the vpad and the gauges | input-agnostic rules ("human vs CPU is only has-a-BRAIN") | ~10 lines | low (the shipped CPU never switches, DUEL_AI_STRATEGY §8.16) | G2, fulltest | **during S6** (it rewrites the function) | **Done 2026-11-13 in DUEL_SP batch S6**: `core-switch-ready-p` deleted, `core-switch-open-p` (vpad + gauges only) is the one legality check, the CPU presses through `cai-dswitch` / `cai-switch-press`; G2 identical.
| 7 | PRACTICE's options into one struct (or the dummy's BRAIN + a PRACTICE component), `practice-step`'s gauge writes as a pure "practice refill" of gauge values; flow.lisp keeps only screens | a sim input in seven specials and a sim system in a screens file | ~80 lines | low-medium | the practice scripts' logs identical (duel-practice, practice-cancel), G2 (no practice), saved settings load | **during S9** (it adds the GAUGES row here), first commit |
| 8 | the phone's SP hold into the vpad: onehand's reader sets a vpad button (and the tap / rearm flag in PILOT), `core-held-p` / `core-touch-p` read only the vpad | vpads for every input source (AGENTS determinism); no device read in the sim or a rollout | ~40 lines | medium (phone feel) | duel-touch / touch-left / mobile scripts' logs identical, G2, a phone playtest | after S6 (core-sim.lisp is S1-S6's), R15 |
| 9 | `*core-on*` out (R11 already plans it), with the NIL branches: KESSA's `:step` hook, `hoho-clone`, ichigo 735 / 815 / 1043 / 1048, combat 155, kit 395; the host checks that set it NIL (core.lisp, ken.lisp) restated in core-scaled numbers first | a hidden channel that only tests flip | ~40 lines + test edits | low | fast, G2, unit-names | R11 (after S9) |
| 10 | hooks as data: `:p`'s run rule as a kit key (`:run-awaken t` or `:run-commands`), KEN-P out; `:u`'s dead tests and `u-press!` out; hisagi-draw's `kit-meter` setfs moved into his `defkit` forms | kit data is data; a hook is called, never tested for presence | ~30 lines | low | unit-forms (the meter move), G2, the ken-shikai script (P from a run) | R11 (its hook-point table) |
| 11 | the implicit arguments: `*strat-now*` and `*mc-select*` passed (or a field of the style state), `*kk-meaty-p*` / `*kk-ns-safe-p*` rebinding replaced by an argument of `ken-ki-style` | no hidden channels through specials | ~60 lines | medium (many readers, CPU files) | G2, snaptest / fulltest, `strategy-eval` cache hit unchanged | R12 (after S7) |
| 12 | `apply-hit`'s outcome record (pure core + apply step), `deal-damage`'s split, the step's hit queues returned as values from `hit-apply` to `settle-souls` | pure core / imperative shell in the hit path | ~250 lines moved | medium-high | host tests of the core, G2 + hash, snaptest / fulltest, every live `duel-*.json` log identical | **after S5** (R15) |
| 13 | combat.lisp's four jobs split: hits / gauges + bursts + forms / the round (settle, reset) | one job per module | ~500 lines moved | low (a pure move) | unit-forms EQUAL, G2 | **after S9** (R15; every S batch edits these functions) |
| 14 | `*mc-plan*` and the jobs' owner as BRAIN slots (or a CPU component); `*view-*` as P1's PILOT slots | state in components, not in side-indexed specials | ~50 lines | medium (snapshot roots change) | snaptest / fulltest, G2, the camera scripts | R12 / R15, only if the next feature needs it |
| 15 | debug-mutated knobs reset on `start-match` (or the debug commands bind instead of set) | a debug command must not change a later match silently | ~20 lines | low | the debug scripts' logs | R11 |

**R10 items 1-3 done on branch (2026-11-13; two commits, items 2-3 first so the looks gate could tell them apart).**
Item 1: the three ken.lisp hooks (`ken-tategoto-split`, `ken-ground-crack`, `ken-bk-slam`) emit `(:ground-scar x z yaw ds r)` (the
feet's numbers captured at the hook, not the live position vector) in the place their `ground-scar` call stood; `ground-scar` moved
to feedback.lisp with that signature and the event's handler, so the sim step no longer writes the stage. A lean rollout drops its
events (`sim-step-lean` ends in `take-events`); the offline `sim-rollout` still runs `feedback-system` (11.5.2 D, R12's). Proven
directly with a scratch native check (debug 2309, Buttagiru: snapshot, 90 lean steps, restore): before, the rollout left 2 marks and 6
chips on the live stage; after, 0 and 0, and the live step still makes them. Item 2: `*soul-breaks*` in `snapshot-roots` beside
`*pending*` / `*kikons*`. Item 3: FIGHTER `cancelled` `seal` `step-open` `block-adv`, BRAIN `intent` `intent-t` `break-key`
`bankai-rolled` `aim-key` `aim-plan` `aim-t` `reflect-key` `reflect-go` `react-roll`, GAUGES `form-total`, MODEL `t3` out with their
writers and their always-constant reads (combat's `:red` is `gauges-red-p` alone, the Step's iframes no longer test `step-open`,
`set-blockstun` lost its ADV argument); the kits' six `:ai` plists, the kit's `ai` slot and the four knobs only they read
(`*ai-ic-l-after-k*`, `*hs-ai-string-k*`, `*hs-ai-l-after-j*`, `*hs-ai-awaken*`); debug 2104's overlay prints action + heat. BRAIN
`heat` and the hash line's `h` column stay for S2's format regeneration, and so does the old reaction roll's `sim-rnd01` draw in
`ai-event-rolls` (now read by nothing): removing it would move the sim RNG stream and G2. Proof: host tests 2939 -> 2929 (the
removed checks pinned the `:ai` data: hisagi.lisp's `:ai` knob check, systems.lisp's `:opp-aim` / `:opp-reflect` check over 9 forms;
two `kit-ai` clauses dropped from live checks), control 116, input 33, touch 100, cine 18, hud-engine 121 all pass; pkgcheck only
`DUEL::APP`; debug ranges 84, 0 errors; G2 identical (II 39, IK 36, KK 28 lines; native after each commit, the browser on the final
build), reference not regenerated; snaptest IK straight = pollute, fulltest IK 102 / FT_VS 45 / KK 102 checks, 0 differ (both commits); smoke desktop and
phone 0; looks 75 / 75 bytes identical to a BASE built at a5a75b0f after items 2-3 **and** after item 1
(likely none of its stills reaches a Kenpachi crack: not checked)). index.wasm 10,254,002 -> 10,246,780 B.

Not ranked (no gain found): `hit-gains`, `core-on-hit!`, `gauge-system` (11.5.4); the rollout bindings' macro and `*in-rollout*` defined
once (already R12); the guard's slots (with the guard).

### 11.6 Risks

1. **R3 is the hard cut**: old and live mechanics are interleaved in `apply-hit` and the fighter step; the only proof is G2 + hash,
   which cover three pairings' CPU matches, not every scripted scene. R3 also re-runs every `tests/scripts/duel-*.json` of the live
   kits and compares their logs before / after.
2. **R0 may not converge.** Nothing before M4 depends on it except R7's re-pin and R9; the fallback gate is written in R0's row.
3. **The removals delay the SP playtest** by steps 1-5. The cut line in 11.2 trades that for more conflict work; the main session
   decides at step 3, when R3's real size is known.
4. **Saved data**: roster indices, stub kits, `RETIRED` / `PAIRS` and the saved-data keys stay (D1 / D2); R2-R4 each state in their
   hand-back that a save written before the cut still loads.

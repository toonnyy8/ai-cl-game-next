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

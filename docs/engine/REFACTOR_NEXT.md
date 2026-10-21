# Refactor: the next round (backlog)

Recorded 2026-10-09 after the 2026-10 refactor merged (`REFACTOR_2026-10.md`, DEVLOG §153–§155). The user: 「把下一輪的修改事項紀錄下來，之後再執行」.
Round 2 (2026-10-21, `REFACTOR_2026-10-21.md`, DEVLOG §304) worked through it: each item below says what it did. Each item says why, where, what to measure first, and how to know it is done. When the user asks
for the next round, pick from here, keep the same bar as 2026-10 (§ "Bar" below), and tick the item off with its DEVLOG §.

## Bar (unchanged from 2026-10)

- Refactors change no sim bit and no pixel: native simgate 15x10 rows byte-identical to the parent commit's, G2 cvc 3/3,
  the 8 host suites, pkgcheck duel + game, both builds 0 warnings, RAVEN G1, and `tests/style-gates.py looks BASE NEW`
  (108 stills byte-identical; BASE = a copy of `dist/duel` built from the parent, `--keep-base` for a series).
- Helpers expand to the text they replace (REFACTOR_2026-10 §8); no anaphoric names across the ENGINE / DUEL packages
  (names a body needs come from the caller, as `with-cam (rx ry rz ux uy uz)`).
- An allocation item is measured before and after with a consing probe; no probe, no change.

## Items

### N1. `defdebug`: the debug command table from one source (the user's item 2) — closed by a checker (round 2, 2026-10-21)
- Round 2: the advisor counted 112 clauses, two overlap patterns (2209 inside 2200–2299, the specific 23xx before the
  2300–2399 catch-all) and one undocumented range (31101–31199); the drift was in the prose. The user chose 「檢查程式」:
  `tests/debug-ranges-check.py` (every range in DUEL_GAMEPLAY "Debug commands", no silent overlap; 96 ranges, 22 through
  `*char-debug*`, 0 errors), the doc fixed, `cine-still-command-p`. A registry only if the table drifts again.
- Decided: 「第 2 項下一輪再做」(2026-10-09, after the macro discussion; REFACTOR_2026-10 §1).
- Why: `debug.lisp`'s dispatch is ~112 `cond` clauses on number ranges, and `docs/duel/DUEL_GAMEPLAY.md` "Debug commands"
  is written by hand. They drift: batch B2 found more than a dozen ranges the doc lacked.
- What: `(defdebug (from to) "doc line" (k) body)` registers a range, its handler (K = the offset in the range) and its
  table line; the dispatcher walks the ranges in declaration order (first match, as the `cond` does now); a host tool
  prints the table for DUEL_GAMEPLAY (or a check that the doc lists every registered range). Character ranges keep going
  through `*char-debug*`.
- Watch: clause order matters where ranges overlap (`(>= c 6300)` style fall-throughs in the viewer and debug.lisp):
  keep it explicit. Debug commands drive the gates: simgate rows and cvc must be byte-identical.

### N2. Ichigo's and Senjumaru's HUD meters: per-frame consing (was D11 / C12) — probed, partly done (round 2) — done (round 3, 2026-10-21, REFACTOR_2026-10-21-R3.md)
- Round 3: `defun-fast` / `%hrect` / single-float angles: Ichigo's meter 1200 → 240 B a call, his deck 864 → 96; Senjumaru's
  Bankai meter 3904 → 216 B, her ring 2288 → 0. Left: Ichigo's clone list / sort / `%arc` arguments (240 B).
- Round 2: probes 74907 (Ichigo) / 2490 (Senjumaru). Ichigo meter + label 2864 → 1408 B a frame, Senjumaru's Shikai label
  728 → 0, her Bankai meter 4016 → 3904 (live zones once, labels from load-time tables). Left: Ichigo's meter 1200 B, his
  deck 864 B, her Bankai meter ~3900 B, her ring 2288 B: generic float math, colour lists, closures — a float-path rewrite,
  so a look change (the looks gate decides), not a refactor.
- Where: `ichigo-hud-meter`, `ichigo-deck`, `senju-hud-meter`, `senju-hud-label`, `senju-ring` (ichigo.lisp,
  senjumaru.lisp), Ichigo's `ic-rgb` boxing, `ichigo-live-clones`: `list`, `sort`, `remove-if-not`, `format nil`, boxed
  floats every frame.
- First: add a consing probe like Lille's (debug 79195, `lille consing`): one line per side of bytes per 10 draws of the
  meter, the deck, the ring. Claim a debug range in DUEL_GAMEPLAY first.
- Done when: the probe reads 0 B (or the remaining bytes are explained), pixels identical.

### N3. `hud-text`: ~200 B per call, dozens of calls per frame (the advisor's find) — probed (round 2) — done (round 3, 2026-10-21, REFACTOR_2026-10-21-R3.md)
- Round 3: `%ui-block-text` (`defun-fast`) in the engine: `hud-text` 208 → 16 B a call (8 B per `ui-block-text`: the
  returned width), every still byte-identical.
- Round 2: the probe in `hud-cons-check` (2328) reads 208 B a call, the same for a literal and a run-time string; a battle
  frame makes ~12–16 calls (2.5–3.3 KB). The cost is the engine's `ui-block-text` (`&key`, boxed floats), called twice a
  `hud-text` (the shadow): the fix is a no-boxing path there, then the looks gate.
- Where: duel/lisp/hud.lisp `hud-text` (block text on whole pixels). It is the biggest remaining HUD allocator, larger
  than everything removed in 2026-10's HUD batch.
- First: count calls and bytes per frame in a battle with a probe (both orientations, every form's HUD).
- Idea: cache the block quads per (string object, scale) since the strings are mostly constants (as `line-width` caches
  per string object); strings built per frame (numbers) need a fixed buffer instead.

### N4. Senjumaru's draw layer has no `defun-fast` — done (round 3, 2026-10-21, REFACTOR_2026-10-21-R3.md)
- Round 3 (the user: 「三項都做」): `sj-prop` / `sj-seg` macros over fixed-arity `defun-fast`s, the domain / ring props /
  needle thread on single floats: `senju-draw` 84880–156080 → ~20000 B per 10 calls (probe 2491); 9 stills moved by
  1–8 edge pixels (the old double `pi`), the user: 「接受」.
- Where: duel/lisp/senjumaru-art.lisp (`sj-seg`, `sj-prop`: generic double math, boxing; ~12 calls a frame for the
  echo arms alone).
- First: measure with a probe; do it together with the next Senjumaru rework, not alone. Pixel risk: a single-float port
  moves vertices by ulps, so the looks gate will differ; that makes it a look change for the user to accept, not a refactor.

### N5. `gate.lisp`: the gate machinery out of debug.lisp (with B3.3) — done (round 2, 2026-10-21)
- Round 2: `duel/lisp/gate.lisp` (state hash, cvc, the seed / learning gates, the scripted players ai.lisp calls, the
  pacing printers); Rukia's and Kenpachi's scenarios and knobs through `*char-debug*` (`rukia-debug`, `ken-debug`, narrow
  ranges); the two-character scenarios, `*cine-names*` and the face stills stay in debug.lisp (1166 → 725 lines).
- Why: `debug.lisp` (now ~1150 lines) mixes the gate code (`start-cvc`, `gate-update`, `state-hash-line`, `hash-log`, the
  pacing printers) with scenarios and knobs; scenario churn risks the gate.
- What: move the gate code to `duel/lisp/gate.lisp` (MANIFEST before debug.lisp), and the character-specific scenarios to
  their characters' `*char-debug*` hooks (B3.3, ~500 lines). Pure moves; tools/simgate loads the MANIFEST, check its
  fixed lists anyway. Pairs well with N1.

### N6. `toon-ground-seg` into the engine — done (round 2, 2026-10-21)
- Done: the four sites (rukia-art `vfx-ru-sheet` x2, vfx.lisp `vfx-line-cut` `:kyoku` / `:south`) spell the
  shifted start out as a 3-term `+` (left-folded: the old nested sum's float order), the macro moved verbatim to
  engine/lisp/fx-shapes.lisp (after `%tongue`) and is exported; the looks gate gained fx-a `kyoku` / `south`
  (2304 / 2303; neither look was guaranteed in the 105 stills). Record below.
- Why it stayed in duel/lisp/stage.lisp: four sites read the macro's own `x0` / `z0` binding in a later argument
  (vfx.lisp ~703, ~726; rukia-art.lisp ~714, ~716), e.g. `(+ x0 (* e ux))` really adds to the macro's x0. In the engine
  that binding becomes `engine::x0` and the sites would read their own x0 (pixels change).
- What: rewrite those four sites with the value spelled out in the same float order (`(+ x0 (* 0.5f0 ux) (* e ux))`
  only if that is the same order as the old nested sum, else bind it explicitly), then move the macro; looks gate.

### N7. Smaller ones (do only with a reason)
- Round 2: C8 done (171 `with-xform` one-liners → `mb-at`, W3-B); C4 rejected again (P6); the rest unchanged.
- Per-side state created on the draw path: `(lb e)` / `(ic e)` / `(sj e)` can `add-component` when the HUD meter is the
  first reader (a render-path mutation of the ECS, same as before B8 in spirit). Attach the component in the kit's enter
  hook or at spawn instead, if creation order can be proven not to change any read (simgate + cvc).
- Lille's `*lb-ai*` / `*lb-as*` are not components (`*lb-as*` is keyed by the brain; a component would change when it
  resets). Leave unless the ASSIST gate is rerun.
- `*pacing-log*` stays T after a gate / cvc debug command in a browser session (as the counters always ran before 2026-10).
  Clear it in `go-title` if anyone cares; no gate line changes.
- Names: `gauges-red-p` reads like a GAUGES accessor; `reishi-frac` takes the gauges struct while `reiatsu-bars` takes the
  entity. A rename pass (mechanical) if a future reader trips on it.
- C4 `stamp-code` (read `*stamp-kinds*` at macroexpansion for the stamp magic numbers), C8 the art files' 138 long-form
  `with-xform` one-liners -> `mb-at`, C9 the sound shower helpers (needs an audio buffer diff tool first: no audio gate
  exists).

### N8. Kenpachi's and Rukia's meters through the kit hooks (round 2's S4 / S7) — done (round 3, 2026-10-21, REFACTOR_2026-10-21-R3.md)
- Round 3: `ken-meter.lisp` / `rukia-meter.lisp` (`:tick` hooks, the meter's `:draw` / `:label`); hud.lisp's nine
  character branches gone; rows and stills identical. Still by name in generic files: onehand.lisp's frost arc, ai.lisp's
  `ai-cool-p`.
- Why: NOME / UDE and the cold gauge are wired into combat.lisp (`gauge-system`), hud.lisp and ai.lisp by name, while the
  four later characters use `:tick` / the meter's `:draw` / `:label`. A pure move to a file (S4) keeps that coupling.
- What: when a Kenpachi or Rukia HUD change is wanted anyway, move their meter steps to `:tick` and their widgets to
  `:draw` / `:label` in a new `hud-meters.lisp` (not their kit files: those are host-loaded). Both HUD orientations in the
  looks gate; simgate rows for the step order.

### N9. `tests/duel-rules-test.lisp` per character (the advisor's find) — done (round 3, 2026-10-21, REFACTOR_2026-10-21-R3.md)
- Round 3: a runner + `tests/duel-rules/{core,yama,ken,rukia,senjumaru,art,systems,barro,sim,hisagi}.lisp`.
- Why: 4400+ lines, 9887 checks; four of round 2's eight batches and every character batch edit it (load lists, art reader).
- What: a shared prelude + one file per character; the suite's check count is quoted in many docs, so update every quote.

### N10. `scripted.lisp`: the players the sim calls — done (round 3, 2026-10-21, REFACTOR_2026-10-21-R3.md)
- Round 3: `duel/lisp/scripted.lisp` before ai.lisp.
- Why: ai.lisp calls `dumb-step` / `habit-fire` / `habit-neutral` (now in gate.lisp, before round 2 in debug.lisp): the sim
  depends on gate code. The masher / habit players are sim code and could own a file before gate.lisp.

### N11. The 82320+m stance stills crash (found by round 2's W2-B) — done (round 3, 2026-10-21, REFACTOR_2026-10-21-R3.md)
- Round 3: the held L dash was started with no button; `start-move ... :sig` at both sites.
- `82320` / `82118` stop the page with "game-frame: unknown vpad action NIL" (engine/lisp/input.lisp `vpad-index`), on
  4a48540 too: not a refactor regression. A debug-scene bug in `br-art-stance` / its scene; fix with the next Lille work.

### N12. Smaller deferrals of round 2 — round 3: L7's last site done (`*br-s-openers*`); P9, P11, K2 stay
- P9: `glyphs-extra.lisp` has no generator recipe in `tools/glyph-bake.py` (needs the font, not in the cloud container);
  before the next fighter's glyphs. P11: `hazard-draw` hard-codes Yamamoto's hazard looks (ichigo.lisp reads `hazard-look`
  in a rule: move the `case` body only). K2: ichigo.lisp / senjumaru.lisp `-ai` / `-debug` splits when they pass ~1500
  lines (the amended layout rule). L7's 8th site (`br-s-end-push`, a name parse once per string-end hit).

## Not to do (decided in 2026-10, with reasons in REFACTOR_2026-10 §7)
Fold `(expt x 2)` into `hypot`; swap `sqrt` / `f-sqrt` flavours; port the landscape cameras to single-float; merge `%h01`
with `hash01`; merge `ken-roll` with a plain chance; deep-merge `:ai` plists on `:inherit`; ASSIST state as a component;
a data table for the knob clauses; mirrored-joint DSL; `defstrike` sugar.

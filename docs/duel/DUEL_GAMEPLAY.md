# SOUL DUEL — Gameplay systems, debugging and tests

How to build, play, debug and test SOUL DUEL (`duel/`, package `DUEL`). The rules and every
number are in `DUEL_DESIGN.md`; the engine calls in `ENGINE_API.md`; the teaching walkthrough is
TUTORIAL.zh-TW.md step 9. RAVEN EDGE's equivalent of this file is `GAMEPLAY.md`.

## Build, run, play

```sh
./build.sh duel                                # duel/MANIFEST -> dist/duel/ (wasm ~5.9 MB)
python3 -m http.server -d dist/duel 8000       # open http://localhost:8000/ in a WebGPU browser
tools/pkgcheck.sh duel                         # 0 / 0 / 0 expected (exit 1 on any finding)
```

The build must log 0 warnings (`build/duel/lisp.log`). Sound starts after the first key press.
The pointer is never locked (`*pointer-lock*` NIL): a keyboard-only game.

| Action | P1 keys | P2 keys | Pad (P1 = pad 0, P2 = pad 1) |
|---|---|---|---|
| Move | W A S D | arrows | left stick / d-pad |
| Quick / Flash / Signature | J / K / L | KP1 / KP2 / KP3 | X / Y / B |
| Guard (hold; Bankai East: switch to West, whose ward is always up; cup 3: DRINK) | U | KP4 | LB |
| Breaker (hold) | I | KP5 | RB |
| Kikon rush (hold through the strike: the Kikon on a red opponent) | O | KP6 | RT |
| Step (hold = dash: run after the hop) | Space | KP0 | A |
| Reiatsu modifier (hold) | Left Shift | KP Enter | LT |
| Awaken | P | KP + | Back, or LS+RS |
| SP1 / SP2 / Hoho | Shift+K / Shift+L / Shift+Space | KP Enter + KP2 / KP3 / KP0 | LT + Y / B / A |
| Burst Reverse (in a combo, past its 2nd hit) | Shift+J | KP Enter + KP1 | LT + X |
| Pause (skips the intro / finish; battle cinematics can't be skipped, 2026-09-28) | Esc | Esc | Start |

Menus: up / down with W S, arrows or the d-pad; confirm Enter / J / KP1 / KP Enter / pad A; back
Esc / K / KP2 / pad B. The title also takes Space or Start. VS CPU and PRACTICE use the camera behind P1 (stick
up = at the opponent); CAMERA: BEHIND / SIDE is a SETTINGS row, the pause menu's last item and the second row of the
select screen's difficulty page (up / down picks the row, left / right changes it). The CONTROLS screen (MODE menu) shows
the same table. The bindings are data: `*p1-bindings*` / `*p2-bindings*` in
`duel/lisp/control.lisp`.

**Flow** (`flow.lisp`, one `duel -> STATE` log line per change): TITLE → MODE (VS CPU / PRACTICE / VS
PLAYER / CPU VS CPU / SETTINGS / CONTROLS / MANUAL; the cursor starts on VS CPU) → SELECT (left / right picks P1, confirm, then P2 or the
CPU, then the CPU difficulty and, VS CPU / PRACTICE, the camera; back steps back) → INTRO (a 5 s cinematic; Esc or confirm
skips) → BATTLE (Esc: RESUME / RESTART / CHARACTER SELECT / TITLE, VS CPU also CAMERA; losing focus
pauses) → FINISH (K.O. or TIME
cinematic) → RESULTS (REMATCH / CHARACTER SELECT / TITLE after 2.5 s). A menu match is seeded
from the clock; REMATCH takes a new seed.

**ENDLESS / DANGAI** (2026-09-29 / 2026-10-22, [DUEL_ENDLESS.md](DUEL_ENDLESS.md), [DUEL_ROGUE.md](DUEL_ROGUE.md)): frozen with the core
system (their MODE rows hidden since 2026-10-28) and removed from main on 2026-11-13 with ASSIST and the old learner (the user,
2026-11-10, refactor decision D2: 「全部封存後移除」; REFACTOR_2026-11 R4); the code lives on the branch `frozen-modes`. Their saved
data keys (`soulduel.endless.*`, `soulduel.rogue.*`, `soulduel.learn.*`) stay reserved: duel/web/pwa.js still serves them.

**One VS CPU** (2026-09-28, the user's request 「添加『練習模式』與『設定』…後將『one hand vs cpu』與『vs cpu』整合」):
the separate ONE-HAND VS CPU and HAND rows are gone. VS CPU (and PRACTICE) is one-handed, with the thumb deck, the
portrait camera and HUD and the gesture prompts, whenever the ONE-HAND MODE setting is in effect there
(`one-hand-effective-p`, control.lisp `one-hand-on-p`), and the keyboard / pad VS CPU otherwise. VS PLAYER and CPU VS CPU
are unchanged.

**SETTINGS** (keyboard, pad and taps; landscape and portrait): up / down picks a row, left / right, confirm or a tap
changes it, BACK / Esc returns to MODE. The rows are data (`*settings*` in `control.lisp`); each change is in force at
once and saved by the page (`duel/web/pwa.js`, localStorage, every access in try/catch; missing or blocked storage = the
defaults). These defaults were chosen for the user, who can revise them:

| Row | Options (default first in bold) | localStorage key | Effect |
|---|---|---|---|
| ONE-HAND | **AUTO** / ON / OFF | `soulduel.onehand` | AUTO: one-handed on a touch-first device held in portrait (the old preselection). ON: wherever one-hand is offered (a portrait window or a touch-first device; never a landscape desktop). OFF: never. The note under the rows says whether it is in effect here |
| HAND | LEFT / **RIGHT** (LEFT on the left: the user, 2026-11-02, DEVLOG §553; RIGHT / LEFT before) | `soulduel.handlr` (`soulduel.hand`, RIGHT 1 / LEFT 2, is carried over swapped once) | the thumb deck's side |
| TAP SPLIT | 40 % / 45 % / **50 %** / 55 % / 60 % | `soulduel.split` | the recogniser's `tap-split`: the pad's top part whose taps are K |
| SENSITIVITY | 1 / 2 / **3** / 4 / 5 | `soulduel.flick` | the recogniser's `flick-min`: 40 / 34 / **28** / 23 / 18 CSS px (higher = a shorter flick) |
| CAMERA | **BEHIND** / SIDE | `soulduel.camera` | VS CPU / PRACTICE with two hands (one hand always uses the portrait behind camera; the setting is kept); also on the pause menu and the select screen, which save it too |

The page value of a row is its option index + 1 (0 = never saved). A sound volume row was not added: the engine exposes
only the music bus gain (`set-music-volume`), no master or effects volume.

**PRACTICE**: P1 against a dummy on the normal select screen (both characters, every form reachable in play). No timer
(the HUD shows PRACTICE in its place, landscape) and no match end: `practice-step` (the last sim system, instead of the
timer) keeps the dummy's Konpaku at its DUMMY KONPAKU row, and a K.O. (P1's last Konpaku, e.g. in Kenpachi's Bankai)
resets the round with both fighters' Konpaku and Reishi at their rows instead of FINISH. The combo counter stays on screen
(single hits too): hits and damage of the last combo. The pause menu: RESUME / RESET POSITION / DUMMY / HP REFILL /
GAUGES / P1 HP / P1 KONPAKU / DUMMY HP / DUMMY KONPAKU / CHARACTER SELECT / TITLE / CAMERA (two hands; one hand pauses by
the II chip or the back gesture, as before). The list is long, so `hud-menu` packs its rows between 0.4 and 0.9 of the
height (text shrinks when it must: 12 rows fit at 390 × 844 and at 1280 × 720). Option rows change on confirm, a tap or
left / right:

| Option | Values (default first) | What it does |
|---|---|---|
| DUMMY | **STAND** / GUARD ALL / GUARD AFTER HIT / CPU | P2's brain switched off (STAND), holding guard always, or from the moment a hit lands on it until 60 f after its last hit or block (`dummy-guard-left`: a string's first hit lands, the rest is blocked unless it combos); CPU = the brain on, at the difficulty picked on the select screen. GUARD ALL with a `:core` dummy (the three live kits; 2026-11-12, the user: 「練習模式 DUMMY 的「GUARD ALL」會自動使出能跟對手相消的攻擊」): it holds no guard and cancels instead, pressing J or SP so each incoming hit lands inside a move the triangle cancels it with (`dummy-cancel-press`, DUEL_CORE §9; nothing when no hit is coming) |
| COUNTER | **OFF** / J1 | J1 (2026-10-25, the user: 「幫我將練習模式的假人新增一個受傷後反擊的功能」, 「固定 J1」, 「被打中或擋下後都反擊」): on the last step of each hit / block reaction (or wake-up) the dummy lets Guard go and presses J1 (`dummy-counter-now-p`; not while a guard lock holds its blockstun), so J1 starts on its first free frame (measured: free f52 → KE-J1 f53 after a K1 hit; free f44 → f45 after a block); any DUMMY but CPU |
| HP REFILL | **AUTO** / OFF | AUTO: the dummy's Reishi is back at its DUMMY HP row once it is out of its hit / block reactions (a combo ended); OFF: it stays, so it can be taken red, and a Soul Break (its Konpaku refilled) refills it |
| GAUGES | **NORMAL** / INFINITE | INFINITE: P1's Reishi held at its P1 HP row, his guard gauge, Reiatsu, flash step and Awakening gauge full every frame (awakenings, SPs and Hohos are free to try). The kit meters (Inferno, NOME) keep their own play, so Hellfire and the cups still come from playing |
| P1 HP, DUMMY HP | **100 %** / 75 / 50 / 25 / 10 % | that fighter's Reishi, at once; also what RESET POSITION, HP REFILL, INFINITE and a K.O. restore (`practice-reishi`; 25 % is red) |
| P1 KONPAKU, DUMMY KONPAKU | 1 … **9** (wraps) | that fighter's Konpaku, at once; the dummy's is held there every frame (after a Kikon), P1's is restored by RESET POSITION and a K.O. (a Kikon on P1 still costs him Konpaku). Kenpachi's Bankai: the main-tree batch changes its condition to cup 3 with his own Konpaku ≤ 4, so set P1 KONPAKU ≤ 4 to try it (until that batch lands the old cup 3 + red rule applies: P1 HP 25 %) |
| RESET POSITION | — | both fighters fresh at the start (first forms, full gauges), their Reishi and Konpaku at the four rows, straight into the fight |

Battle cinematics stay unskippable in PRACTICE too.

## Files

`duel/MANIFEST` order: `package`, `tuning`, `rules`, `control` (plain CL, host-tested), `sounds`,
`components`, `body`, `kit`, `cinema`, `stage`, `vfx`, `vfx-stamps`, `yama-vfx`, `yama-art`, `ken-art`, `rukia-art`, `ichigo-art`, `ichigo-look`, `senjumaru-art`,
`yama`, `ken`, `rukia`, `ichigo` (the characters: data, hooks, cinematics; Ichigo's and Senjumaru's mechanics live in their
own files and the generic ones call them through the kit's `:hooks`, DUEL_DESIGN "Character code layout"), `endless-rules`
(plain CL, host-tested), `fighter`, `combat`, `hazards`, `ai`, `camera`, `feedback`, `flow`, `hud`, `onehand`, `senjumaru`
(after hud / onehand: her meter uses their drawing macros), `debug`, `endless`, `main` (the
generic systems; only `debug.lisp` names characters, to set up scenes). The module table is in ARCHITECTURE.md. The
name-leak check (it must print nothing):

```sh
grep -nE ':ya-|:ke-|:ru-|:ic-|:sj-|:lb-|yama|kenpachi|rukia|ichigo|senju|lille' duel/lisp/{rules,control,fighter,combat,hazards,ai,ai-learn,camera,flow,endless-rules,endless,learn}.lisp
```

Engine modules the duel was the first user of (moved into the engine by the harvest):
`engine/lisp/input.lisp` (the vpad), `hitvol.lisp` (hit volumes), `body.lisp` (rigid-part bodies),
`cine.lisp` (the cinematic director), `run-fixed-steps` (time.lisp), `fx-ribbon` / `fx-sector`
(fx.lisp), `ui-bitmap` / `ui-big-text` (ui.lisp), `defstrike` (anim.lisp).

## Time model (`main.lisp`)

* `game-frame`: flow (menus, pause) → the frame's fixed steps (`advance-sim`: the engine's
  `run-fixed-steps`, at most 6 per frame, only while a match runs) → camera → draw → HUD.
* `sim-step`, one 1/60 s step:
  - a cinematic runs (`*cine*`): read the humans' devices, then `cine-step` (engine cine.lisp);
  - hitstop (`time-step` returns NIL): read the devices only;
  - else slow motion by **step skipping**: `*slow-acc*` += the slow-mo scale; a sim frame runs
    only when it reaches 1 (`start-match` zeroes it: see Determinism). Then `pilot-system` (human vpads read their devices) and
    `sim-systems`: `brain-system` → `fighter-system` → `hazard-system` → `hit-system` →
    `gauge-system` → `match-system` (the last four skip when a Kikon started a cinematic mid-way);
  - always: `god-update`, `probe-update`, `feedback-system`, `hash-log`.
* A press made during hitstop, slow motion or a cinematic is still buffered afterwards
  (`pilot-read` reads devices without advancing the vpad clock); a cinematic's end forgets presses
  (`vpad-flush!`) so mashing through it fires nothing.
* Cosmetic work (particles, auras, cinematic looks, the camera) runs per rendered frame on real
  time and uses `rnd01`; everything the sim decides uses `sim-rnd01`.

## Entities (`components.lisp`)

A fighter = `transform motion model blade fighter gauges pilot` (+ `brain` when the CPU plays);
a hazard = `hazard` (fire wave, Shiranui, Ennetsu pillars, South's grab, ground-line looks); a South
hand (a skeleton's arm clawing out, a look) = `hazard transform model`. "Human or CPU" is only "has a `brain`": the brain writes the same
`pilot-vpad` the keyboard does. Key slots: `fighter-state` (`:idle :guard :guard-hit :step :run :hoho
:move :stun :air :down :wakeup :cine :intro :win :lose`), `fighter-sf` (frame in state),
`fighter-phase` (a move's `:hold :aura :dash :main`), `fighter-move` (a MOVE of the current
kit), `fighter-kit` / `fighter-form`, `fighter-contact` (`:hit` / `:block` / NIL), `fighter-burst` (a Burst
pressed this step, applied at the end of `fighter-system`), `fighter-invuln` (frames);
`gauges-reishi konpaku reiatsu awaken meter form-left` and the results stats.

## Characters as data (`kit.lisp`)

`(defmove :name :kind … :startup :active :recovery :dmg :adv-block :reach :arc … :on-frame ((f
hook)) :params (…))` and `(defkit :character :form :inherit … :commands (…) :grid (…) :strings (…) :ai (…))`
(the keys are documented in the two macros' docstrings; `:grid (J1 J2 J3 K1 K2 K3 J2s K2s)` is a form's J / K strings,
`defmove-copy` makes the switched link 2, DUEL_STRINGS.md). A form may `:inherit` another and derive
its moves (`:startup-add`, `:reach-mult`). Hooks are symbols called with FUNCALL (the kits load
before the hook DEFUNs). `*ROSTER*` lists every character with a `:base` kit, in load order; the
select screen cycles through it.

## Debug commands (`Module._debug_cmd(N)`, `debug.lisp`)

`python3 tests/debug-ranges-check.py` checks this table against the code: no two ranges overlap except a specific
range consulted before the generic one holding it, every range's low number is in this section, and every cinematic-still
range keeps a held cinematic (`cine-still-command-p`). The gates' machinery (`start-gate`, `roster-pairs`, the learning
gate) is `gate.lisp`, its scripted players (the habits, the masher: ai.lisp calls them) `scripted.lisp`; the commands that start
them are dispatched here.

**Archived rows (2026-11-12, refactor R2 / B8a, REFACTOR_2026-11 §11.3).** The four retired kits' files left `main` (branch
`retired-kits`), so every row below that runs through `rukia-debug`, `rukia-look-debug`, `senju-debug`, `barro-debug` /
`barro-art-debug` (2410–2426, 2450–2491, 43000–68001, 72000–73100, 76000–78999, 82000–82999, 85000–85999, 90000–99999) is
**archived**: the code is gone, the command falls through to nothing. The scenarios in `debug.lisp` that named `:yamamoto`, `:rukia`, `:senjumaru` or `:barro` were repointed to Ichigo / Kenpachi or freed by R3 (2026-11-13; the row text of the freed ones is kept as the record, marked where the number is free).

The first command turns on the combat log (`*combat-log*`) and the 2 s stats line. Arguments are
encoded in the integer.

| N | Effect |
|---|---|
| 2000+s | seeded CPU vs CPU now (NORMAL), both characters drawn from seed s (s < 100) |
| 3000+s / 4000+s / 5000+s | the same with a fixed pairing: II / IK (P1 Ichigo) / KK (s < 1000) |
| 2100 | toggle: skip every cinematic |
| 2101 | the next match starts with 2 Konpaku each (smoke runs) |
| 2102 | toggle turbo: up to 120 steps per frame, no scene drawn |
| 2103 | toggle the hitbox overlay: hurt cylinders (green), open melee windows (the volumes + a reach line, red), hazards (orange) |
| 2104 | toggle the CPU intent overlay (intent, current action, heat) |
| 2105 | toggle both CPUs off |
| 2106 | toggle the engine's perf log |
| 2107 | log both fighters' state (a hash line) |
| 2108 | fill both fighters' Reiatsu |
| 2109 | toggle the CAMERA option (BEHIND / SIDE; the behind camera is VS CPU's): `duel camera …` line |
| 2110+p | the seed gate: seeds 1–20 of pairing p (0 YY, 1 YK, 2 KK; 3 = 2113: every pairing of the playable roster, `*pairs*` without the retired, 28 since Hisagi joined) back to back, turbo, cinematics on, combat log off; then `duel gate …` lines |
| 2120+k | toggle drawing part k off (0 HUD, 1 fighters, 2 stage, 3 hazards + cinematic looks): perf bisection |
| 2200+k | force cinematic k now and hold it at its hold frame (Kenpachi vs Ichigo): 1 Nozarashi, 6 Soul Break, 7 intro, 8 K.O., 9 Kenpachi's Bankai (4 / 5 / 10 / 19, Kenpachi's old Kikons, removed 2026-11-05, DUEL_KEN_V3 §43; 0 / 2 / 3 Yamamoto's and 11-18 Rukia's / Senjumaru's, removed with their code (2026-11-12, REFACTOR_2026-11 R3): they do nothing) |
| 2209 | a K.O. of P2 (Ichigo vs Kenpachi; Yamamoto vs Kenpachi until 2026-11-12, REFACTOR_2026-11 R3): the K.O. cinematic, then the results screen (the 勝 card) |
| 10000+1000k+f | stills: cinematic k (as 2200+k) held at frame f with the effects frozen there (impact frames, particles, stamps); a later command for the same k continues it to its new f (`docs/research/style-history/style-4-shots.py`) |
| 2300+k | force a special now (Kenpachi vs Ichigo): 5 Split the Meteor, 6 Guard Break, 7 Ichigo's perfect Hoho out of Kenpachi's K, 8 Kenpachi's stance, 9 Buttagiru, 10 Kenpachi's SP2 flurry, 11 EVOLUTION for both, 13 Nozarashi form, 14 P2 red (Reishi 200), 65 the Shikai's rung event (Yamamoto's 0-4 / 12 / 62-64 / 66 and the old cups' 15 / 16 removed 2026-11-12, REFACTOR_2026-11 R3: they do nothing; 15-19, 27, 30-61 and 70-79 are free under the catch-all) |
| 2320 | Burst test: human P1 Ichigo (Yamamoto until 2026-11-12, REFACTOR_2026-11 R3; 3 bars) 2 m from Kenpachi, whose switched-off CPU mashes Quick for 60 steps (J1 J2 J3); press Shift+J after the 2nd hit |
| 2321 | force a Burst Reverse now (P1 Ichigo two hits into Kenpachi's string): screenshots |
| 2322–2324 / 2325 | a Burst on P1 now (Ichigo vs Kenpachi 3.5 m apart, CPUs off, P1's flash-step full): 2322 WHITE, 2323 BLUE, 2324 ORANGE (its aura, the HUD bar draining in its colour; screenshots); 2325 the same scene without the burst (the bar's glow, the RV chip) |
| 2800–2815 | PRACTICE's GUARD ALL with a `:core` dummy (DUEL_CORE §9; claimed 2026-11-12, `practice-cancel-scene` in debug.lisp): 2800 + 3a + b (a / b 0-2: Kenpachi, Ichigo, Hisagi) a PRACTICE, human P1 a against dummy b set to GUARD ALL, cinematics skipped, 2.2 m apart, idle (the log line `duel practice scene A vs B DUMMY … COUNTER …`); 2809 both 2.2 m apart again, idle; 2810+k (k 0-3) the DUMMY option STAND / GUARD ALL / GUARD AFTER HIT / CPU now (2.2 m, idle); 2814 both 6 m apart (out of reach); 2815 toggles COUNTER J1 / OFF (`duel-practice-cancel.json`) |
| 2610+k (k 0-2) | the burst's burning budget (`burst-burn-test`, DUEL_DESIGN "BLUE burns one cell", 2026-11-12): human P1 3.5 m from an idle Kenpachi (CPUs off) bursts at once: 0 BLUE with the flash step full (300), 1 BLUE from 230, 2 WHITE from 300; the combat log's `BURST` / `BURST END` lines carry `fs` (`duel-blue-burn.json`: a Hoho 0.5 s into the burn) |
| 2326 | force a clash now (Breaker vs Breaker, Ichigo vs Kenpachi 3 m apart: the CLASH event; screenshots) |
| 2328 | consing (the canvas battle HUD's bar probes left with that HUD, 2026-11-11, DUEL_LISP_HUD §16) of Nozarashi's cup-3 aura and the rift (in the `vfx consing` line); and of the Bankai stance looks (10 draws each: West's flame garb, the bound ash, the heat sheet, KYOKKŌ's ray, South's crack, the aura crossfade; since 2026-10-13 also Yamamoto's haori hem `ya hem pose` / `ya hem step` and East's smoke thread `ya smoke`, 0 B, DUEL_YAMA_TYBW): `vfx consing (10 draws, B): garb 0, …` (0 B each; the crossfade conses ~60 B a frame only during its 350 ms); since 2026-10-21 `hud-text consing (10 draws, B): const …, fresh …` (`hud-text` on a literal and on a run-time string, the frozen modes' canvas text path; REFACTOR_NEXT N3's probe) |
| 2329 | consing of the brush captions (100 draws of each layout: cinematic, card, callout, results), the impact splash, the dutch roll and a brush Latin line: `brush consing (100 draws, B): cine 0, card 0, callout 0, results 0, splash 0, roll 0, line 0` |
| 2380+k | (retired 2026-11-03: Nozarashi v2's NOME / cup tests went with the cups, DUEL_KEN_V3 §8; free for reuse after a claim) |
| 2365 | (force-special 65) Kenpachi in Nozarashi 4 m from Ichigo, the `:rung` event emitted (the page, the grin with the head thrown back). 2362-2364 were Yamamoto's Phase 5 looks (Taimatsu, Nadegiri, Ikkotsu): free since 2026-11-12 |
| 2390 | consing of the Phase 5 looks (10 draws each: fireball, charge, pillar, dome, the Hellfire / Evolution / Breaker auras and ring, the garb flare, the rift, a spent wave's erosion, the Phase 5 stamps, the face / beat / move-beat choices; since 2026-10-13 the Shikai's `fire-sheet`, DUEL_YAMA_TYBW): `vfx5 consing (10 draws, B): fireball 0, …` (0 B each) |
| 2366 | free since 2026-11-12 (was the Phase 6 destruction still: Yamamoto shouts, Kenpachi hurt amid rubble; the looks scenario `fx-a` no longer calls it, REFACTOR_2026-11 R7) |
| 2391 | consing of the Phase 6 looks (10 draws each: the marks and chips with both pools full, a pillar and a fire wave beside the lens, the Nozarashi skull, the K.O. rain, both face accents, the face-change note, the left-hand grip step + IK, a caption slicing out): `vfx6 consing (10 draws, B): marks 0, …` (0 B each) |
| 2392 | (ken.lisp `grip-drift-check`, `ken-debug`) the left fist's gap to the cleaver's handle over every grip clip (the RYOTE kendo set, KUKAN-GIRI, the stance) and every grip-clip → grip-clip crossfade, keys only and with the draw's `GRIP-LEFT!` (P1 must be Kenpachi, e.g. after 2383): `grip <clip> (raw/IK mm): …` per frame, `grip drift: raw max … mm, IK max … mm`; then per clip at 120 Hz the left arm against the torso (`grip-front`, DUEL_KEN_REWORK §6.2.2): `grip front <clip> (mm, + = in front of the chest): elbow min …, fist min …, below the shoulders min … (… of … samples behind the back plane), in the torso max …`, and `grip front: below the shoulders min … mm` |
| 22000+k / 23000+k | gate knobs without a rebuild: `*gg-regen*` / `*gg-regen-guardless*` = k / 10 (20000 / 21000, `*ward-mult*` / `*pierce-max*`, removed 2026-11-12, REFACTOR_2026-11 R3) |
| 2114+p | the seed gate of 2110+p with the combat log kept and a `pace t=… \| FORM m… r… g…[!] k… w…` line every 60 ticks per side (scratchpad `pace.py` reads it: cup times, stays, the Bankai gauge, scorches) |
| 2393 | the string test: the running match's fighters 2.2 m apart, facing, idle, nothing held (a switched-off CPU lets go of its guard): the scripts' string + O ender (`duel-touch.json`) |
| 2394+k | the string test (DUEL_STRINGS.md; `duel-strings.json`): human P1 in form k (0 Ichigo's Shikai, 1 KESSA (Yamamoto's Shikai / Bankai East until 2026-11-12, REFACTOR_2026-11 R3), 2 Kenpachi base, 3 his Shikai) 2.2 m from an idle Kenpachi (CPU off); the script presses J / K / O |
| 26000+k / 27000+k | the strings' seed-gate knobs without a rebuild (before 2113): every K2 / K3 (and copy) deals k % of its written damage (26000), `*kosei-reiatsu*` = k / 100 and `*kosei-fs*` half that (27000) (24000 / 25000 / 28000 / 29000, the old AI's knobs, removed 2026-11-12, REFACTOR_2026-11 R3) |
| 2400 | toggle god mode: each step both fighters' Reishi is raised to at least 400 |
| 2500+k | human P1 vs an idle CPU, cinematics skipped: 0 Ichigo vs Kenpachi, 1 Kenpachi vs Ichigo, 2 II, 3 KK |
| 2495 / 2496 / 2497 | the Lisp HUD's landscape and overlay scenes (DUEL_LISP_HUD §14; claimed 2026-11-11, `lhud-scene` in debug.lisp): 2495 the 2505 scene with the intro played (the card, READY / 斬; `--fixed-dt` stills at 8.1-12.9 s after it); 2496 human Kenpachi (P1) in his Shikai with KAIHO L2 (the kit strip and the form's seals on the left plate, mirrored) vs Ichigo with his CPU off, cinematics skipped, VS CPU; 2497 P2 K.O.'d now (`match-over`): the K.O. cinematic and the finish, then the results |
| 2505 / 2506 / 2507 / 2508 | the Lisp HUD's handheld scenes (DUEL_LISP_HUD §13; claimed 2026-11-11, `lhud-scene` in debug.lisp): 2505 human Ichigo (P1) vs Kenpachi with his CPU off, cinematics skipped, VS CPU, one-handed where it is in effect (run with `--mobile`); 2506 the same in PRACTICE (the ∞ clock tab); 2507 toggles the hand (left / right) for this run, not saved; 2508 puts P2 (Kenpachi) in his next form: sealed → the Shikai with KAIHO L2 → the Bankai KYORAN → ZANKAI → sealed (`lhud-p2-form`) |
| 2504 | VS CPU HARD: human Kenpachi (P1) vs a playing Ichigo CPU (P2) that learns online (the fuzzy Q table, DUEL_AI_STRATEGY §8.14), cinematics skipped; clears the debug flag that keeps learners off and drops the in-memory tables, so the attach reads the page (the save / load check) |
| 2509 | cycle the paint shapes' test card: off, on, on with a transparent frame (the back layer shows where the sky was), off (DUEL_LISP_HUD §10; claimed 2026-11-11; lhud-shapes.lisp): twelve cells over the scene, drawn in any renderer: the Reishi bar rotated (AA ends, 3-stop fill, stripes grid), a linear gradient and a masked screentone, a box glow and a tilted tag, ellipse / ring / arcs / glow, the 爆 dial mock (a level cut by the scissor), strokes (butt, round with a drawn fraction), a radial ink pool, soul flames from hud.js's SVG path, a scissor reveal, group opacity, the stance boxes and pause chip, a back-layer slab (the third state) |
| 2510+p (p 0–2) | P1's SP pointer = p + 1 (1 / 2 / 3: the pointer stances, DUEL_CORE §6) |
| 2513 | (not a pointer: the range above stops at 2512 since 2026-11-10) 3 s of the cancel's slow motion (`*core-clash-slowmo-scale*`): the smooth-draw check (DUEL_CORE §6) |
| 2514 | toggle `*scene-transparent*` (DUEL_WEBUI §4): no stage, no sky, the canvas keeps the scene's alpha (the paint stream's back layer shows around the fighters: the Lisp SELECT's cards) |
| 2515 | consing of the battle screens' model in the running battle (webhud.lisp, DUEL_WEBUI §7; claimed 2026-10-28): 100 calls each of `webhud-sync`, `webhud-side`, `webhud-prompt`, `webhud-deck`, `webhud-tag`, `at-stake` and the thumb deck's four `touch-button` reads once the values are written: a `webhud consing (100 calls, B): sync …, side …, prompt …, deck …, tag …, stake …, touch …` line (0 B wanted) |
| 2518 | toggle the Lisp HUD's still mode (DUEL_LISP_HUD §4.6): phase 0 adds the legibility card (the smallest sizes the HTML uses, the densest kanji; its HTML twin is built in §8); phase 1c adds its layout / text / tween / hot-box rows beside it (below it in portrait: a wrapped paragraph, the handheld's pointer seals 「拖 · DRAG」 「肩 · SHOULDER」 「構 · CHUDAN」, a tabular clock that pops each second, a vertical column, a frame on the row under the mouse; DUEL_LISP_HUD §11); phase 4 adds the held touch ink |
| 2519 | consing and time of the Lisp HUD's per-frame path in the running battle (DUEL_LISP_HUD §4.7): 100 calls each of a plate, a combo, the whole draw and (since phase 1b) 2509's shapes card, with P1's combo forced on mid-stamp (the busiest frame; put back after): `lhud consing (100 calls, B): plate …, combo …, draw …, shapes …; ms a call: …; verts: plate …, combo …, frame …, shapes …` (0 B wanted; the ms read 0 under `--fixed-dt`'s virtual clock: time it in a wall-clock run); since phase 1c a second line `lhud consing 1c (100 calls, B): frame …, demo …; ms a call: demo …; verts: demo …` (the frame's layout and hot-box reset, 2518's phase 1c rows: DUEL_LISP_HUD §11); since phase 2 the busiest frame also forces P1's move name, the Kikon prompt with its ring and a ripple, a trail and two words of touch ink, and a third line `lhud consing p2 (100 calls, B): systems …, line …, deck …, dial …, ring …, clock …, ink …, name …, prompt …; ms a call: …; verts: …` (DUEL_LISP_HUD §13); since phases 3-4 a fourth line with the overlays forced on mid-animation (the card, READY, the finish, the pause with its rows, the dimmed scene; put back after): `lhud consing p34 (100 calls, B): clock …, intro …, ready …, finish …, pause …, dim …, pointer …; ms a call: …; verts: …` (DUEL_LISP_HUD §14); since phases 5-6 a menus line `lmenu consing (100 calls, B): systems …, title …, mode …, settings …, controls …, select …, back …, results …, rails …, wash …, cut …, pointer …; ms a call: …; verts: …` (every screen's view from whatever the model holds, SELECT's back layer, the cut half-way; `lm-consing`, DUEL_LISP_HUD §15) |
| 2516 | P1 knocked down by P2 now (`set-reaction :knockdown`): the wake-up check (2026-11-07, DEVLOG §614): hold a direction as he gets up and the log says `P1 roll` |
| 2520+k | `(camera-shift-x *camera*)` = (k − 30) / 100, k 0–79 (2550 = 0, 2590 = +0.4: the image moves right); nothing else resets it but a new value (DUEL_WEBUI §4) |
| 2600+k | `*red-threshold*` = k % (pace the gate without a rebuild) |
| 2387 / 2388 | Kenpachi's Bankai tests (`bankai-test` in ken.lisp, `ken-debug`, human P1 Kenpachi vs an idle Ichigo; `duel-bankai.json`): 2387 in the Bankai at once, 2.2 m; 2388 the Bankai with 1 pip left (the burst). (2386, the cup-3 entry, and 2389, 片腕, retired 2026-11-03 with the cups and KATAUDE.) |
| 35000+f | stills: the Bankai cinematic held at frame f (as 10000+1000k+f, k 9; 36000+f / 2210, MAPPUTATSU, removed 2026-11-05, DUEL_KEN_V3 §43) |
| 30000+k / 31101–31199 | the seed gate's seeds k+1 .. k+N; N = 31100+n: n seeds per pairing (the default 20, the quick pass 10) (31000+10a+b, the old CPU's Bankai entry, and 39000+10a+b, its awakening A/B, removed 2026-11-12, REFACTOR_2026-11 R3: the core CPU never read them) |
| 2410+k | her tests (`rukia-test` in rukia.lisp, `rukia-debug` through `*char-debug*`, human P1 Rukia, P2's CPU off; `duel-rukia.json`): 0 the Shikai 5 m from Kenpachi, 1 −18 °C / 2 −50 °C (cold 150) at 2.2 m, then zero (cold 200): 3 Kenpachi's J1 into the ward (the freeze-touch), 4 Yamamoto's full Shiranui through it (optic), 5 his Breaker (the CRACK), 6 the Breaker answered by REIDO TŌKETSU within 5.5 m, 7 zero left to warm out, 8 zero 3 m from him (hold U: bracing to the CRACK); a `duel probe rukia …` line every 10 f |
| 2420+k | K → L tests (`rukia-kl-test` in rukia.lisp, `rukia-debug`, `*kl-tests*`): 0 Shikai, 1 −18, 2 −50, 3 zero, 4 −18 short of L's cold, 5 / 6 the Shikai / −18 into a held guard; a `duel probe kl` line per hit with his stun frames left before it |
| 72000+k / 73000+k | (rukia.lisp `rukia-debug` through `*char-debug*`) her CPU's `:l-after-k` = k / 100 in the Shikai / in the three bands |
| 68001 | (rukia.lisp `rukia-debug` through `*char-debug*`) the white Rukia's lashes dark again (the before still of 68000) |
| 2440+k | the Lisp HUD's handheld states on the running battle (after 2505 / 2506; DUEL_LISP_HUD §13; claimed 2026-11-11, `lhud-review`): both 2.2 m apart, idle, full gauges, Konpaku 9, then k: 0 that (the user's screenshot), 1 / 2 both SP pointers 2 / 3, 3 Reishi 15 % (red) and P1's Konpaku 6, 4 the flash step empty (the Burst spent), 5 the flash step at half, 6 the awakening ready, 7 P1 awakened in KESSA with SPIRIT DRIVE 60, 8 SUBLIMATION 60, 9 the clock at 9 s (VS CPU) |
| 2700+k | portrait presentation (DUEL_MOBILE_DESIGN.md P2): 0 the framing / text probe on (every 30th battle frame off a cinematic: both fighters' upper halves clear of the two HUD blocks, ≥ 70 % of each one's width on the screen, the smallest pixel-font glyph drawn) and its `duel frame …` line now; 1 the fighters 24 m apart; 2 P2 flashed to P1's side (90°, 4 m: the camera's catch-up); 3 1 m apart; 4 consing of the portrait camera and dolly (100 calls each; the canvas HUD column left 2026-11-11): `portrait consing …` |
| 81020+i | the gates' CPU difficulty (0 EASY, 1 NORMAL, 2 HARD; `*gate-difficulty*`, gate.lisp START-CVC; sent by `tools/strategy-eval.py`, `strategy-switch.py`, `matchup-eval.py`, `aieval.py`). (81000+g+3c+6b, 81030+i, 81040+i and 81100+k, ASSIST's gate, were freed 2026-11-13 with ASSIST: REFACTOR_2026-11 R4, branch `frozen-modes`) |
| 67000+k / 68000 | review stills (rukia.lisp `rukia-debug`, on the branch `retired-kits`): P1's cold = k and its band; the white Rukia with the old ink keyline (69000 / 70000, her face close-ups, removed with debug.lisp's scenes, 2026-11-12, REFACTOR_2026-11 R3) |
| 71000 / 71001 / 71004 | review stills (ken.lisp `ken-debug` through `*char-debug*`): Kenpachi's reiatsu opaque ↔ see-through (`*reiatsu-glass*`); human P1 Kenpachi in the Shikai (71001, L 0) / the Bankai (71004) 3 m from an idle Yamamoto (71002 / 71003, cups 2 / 3, retired 2026-11-03) |
| 2125+k | one seed-gate pairing alone (0 YY, 1 YK, 2 KK, 3 RY, 4 RK, 5 RR, 6 IY, 7 IK, 8 IR, 9 II, 10 SY, 11 SK, 12 SR, 13 SS, 14 SI; P1 the first): the fifteen in parallel give the same rows as 2113's first fifteen (it plays every pairing) |
| 74000+k … 75599 | Ichigo (DUEL_ICHIGO.md "v2: built", its Knobs; `ichigo-debug`, his own range through `*char-debug*`): 74000+k his tests (human P1 Ichigo, P2's CPU off): 0 / 1 the Shikai / KESSA 3 m from Kenpachi, 2 Kenpachi's K1 into KESSA (L: the catch), 3 Yamamoto's L wave at 7 m (L: blocked), 4 Kenpachi's Breaker (it breaks the parry), 5 the Shikai vs Yamamoto's wave (Shift+K cuts it), 6 the Shikai 8 m out, 7 / 8 KESSA with three clones 8 m / 2.2 m from Kenpachi (8: the worst-case J string), 9 KESSA vs Rukia, 10 Kenpachi's J1 into KESSA (block it, L from blockstun); 74080+k the 60-seed gate of pairing k (one A/B stream in one run); 74100+k … 74400+k the Shikai's / KESSA's damage dealt / taken × (0.5 + k / 100); 74500+k the parry window f2–(k+1); 74600+k `*kessa-parry-catch*`; 74700+k `*clone-life*` 10k; 74800+k `*clone-burst-dmg*`; 74900+k (k 0–3) P1's clones = k, 74904 (2026-11-12) two NS3 clones (`:ns-a` / `:ns-b`: they replay his J / AS), 74908 (after 74000 / 74001) 1.5 m apart, P1's flash-step 100, P2's 300 (a `duel steal` line), 74909 that line again (DUEL_CORE §2.2), 74905 logs P2's combo, 74906 the looks' consing probe (`ichigo-look-cons-check`, after 74000: the cloak's :pose, the :draw hook idle and frozen in K1's / RANGETSU's hit frame; each 0 B, DUEL_ICHIGO_TYBW §6.1), 74907 the HUD's consing probe (`ichigo-hud-cons-check`, KESSA with three clones: the plate's tag `ichigo-hud-tag` and the one-hand deck ring `ichigo-deck`, 10 calls each: `duel ichigo hud consing (10 calls, B): tag …, deck …`; the canvas meter row it measured before left with the canvas HUD, 2026-11-11), 74910+k `*clone-scale*` k / 20; 74950+k the CPU's parry chance k / 50; 74989 / 74990+k pose stills; 75000 + 80 i + k stills of cinematic i (0 the Cero Kikon, 1 千影, 2 the awakening, 3 漆黒の月牙天衝, 4 the Shikai's cleaver Kikon, 5 his rush Kikon, 6 KESSA's chain Kikon) at frame 3k (2026-10-28; 150 i + 2k before) |
| 43000+k … 66000+k | her knobs without a rebuild (rukia.lisp `rukia-debug` through `*char-debug*`) (DUEL_RUKIA.md "Knobs (the rework)"): 43000 `*frost-slow*` k / 100, 44000 `*zero-brace-drain*` k / 10, 45000 `*freeze-touch*`, 46000 `*ru-cool-rate*` k, 47000 `*crack-self*`, 48000 zero's damage × k / 100, 49000 the awakening's melee share, 50000 / 53000 the `:cool` chance / distance, 51000 `*ru-thaw-lock*` k f, 54000 the Shikai's ZONE weight, 55000 zero's warming k / 10, 56000 / 57000 the −50 / −18 walk k / 10, 58000 the Shikai's damage, 60000 / 61000 the Shikai's / the bands' damage taken × k / 100, 62000 / 63000 `*ru-block-cool*` / `*ru-hit-warm*` k / 100, 65000 zero's field `:away` k / 100, 66000 `*field-floor*` k / 100 (every gate row is followed by a `duel band` line per awakened Rukia side) |
| 80000–80999 | free since 2026-11-13: ENDLESS's (DUEL_ENDLESS.md §8; endless.lisp ENDLESS-DEBUG), removed with the mode (REFACTOR_2026-11 R4, branch `frozen-modes`) |
| 84100–84999 | free since 2026-11-13: DANGAI's (DUEL_ROGUE.md; 84000+100c+n its debug runs, 84501–84598 its rewards, 84800–84899 the run modifier table, 84980–84999 its stage commands), removed with the mode (REFACTOR_2026-11 R4); the double claim with Kenpachi's 84000–84099 is gone |
| 85000+k / 85499 | claimed 2026-10-24 for **Rukia's new Shikai** (霜の層, DUEL_RUKIA_TYBW §4.4; rukia.lisp RUKIA-LAYER-TEST through `*char-debug*`): human P1 Rukia's Shikai vs Kenpachi (P2's CPU off unless noted), both gauges full, P2 with the scene's 霜の層; a `duel probe rukia 1kk …` line every 10 f for 600 f (P1's form, state, move, Reishi, Reiatsu `ra`, guard gauge, meter, frost; P2's state, form, Reishi, frost, `sl` his layers, `th` his thaw timer; `d` the distance). k 0–3 P2 with k layers 2.2 m out (play the strings); 10–15 P2 with 3 layers, 2.2 m out (J2 / J3: 1.2 m), P1's J1 / J2 / J3 / K1 / K2 / K3 started with L latched (its burst: 霜散 雪煙 霜陣 氷礫 氷柱 雪崩); 16 J1 + L with 0 layers (the L refused, the string ends); 17 K2 + L with 1 layer; 20 BYAKURAI (L tap) 5 m out; 21 TSUKISHIRO (L held) 6 m out; 22 SOKATSUI (SP1 tap) 3.5 m out; 23 RIKUJOKORO (SP1 held) 5 m out; 24 / 25 SP2 SHIRAFUNE 3 m out with 3 / 0 layers (185 / 110); 30 the thaw (3 layers, idle, 3 m); 31 his walk in under 3 layers (P2's CPU on, 8 m out); 40 J3 + L's 霜陣 circle round him (1.2 m) (+1 a 60 f inside); any other k < 99 the probe line only; 85499 a `duel rukia look consing` line (10 calls each of the new looks: the layer crust at 1 / 2 / 3, 霜陣's circle, BYAKURAI's beam, SOKATSUI's fire, RIKUJOKORO's marks / rods; 0 B wanted). Every gate row with her Shikai is followed by a `duel rukia` line per side (the pacing log: the bursts by move name, `layers-laid`, `layers-burst`, `sojin-layer`, `l-held`, `byakurai`, `sp1-tap` / `sp1-held`, her CPU's `ai-kido` / `ai-sp2-layers`). 85099–85498 free |
| 2135+k (k 15–64: 2150–2199) / 2136+i (i 4–13: 2140–2149) | claimed 2026-10-06 for the roster's 6th character on (index 5 = Lille Barro, appended last): pairing k ≥ 15 alone, and character i's pairings (its pairings with every earlier character, then its mirror; `char-pairs`); `*pairs*` = `roster-pairs` (the fifteen above, then per later character (i, 0) … (i, i−1), (i, i)), so the 6th character's six are k 15–20 = 2150–2155 and its group is 2141; `tools/simgate.py` `gate_cmd(k)` computes the command, `ROSTER` there is the tools' one roster list (assistgate / aieval read it). Room: ten characters (55 pairings); with five characters these commands log `duel gate: no pairing …` and start nothing |
| 200000 + 100 c1 + 10 c2 | the pairing gate (gate.lisp START-PAIR-GATE; `tools/strategy-eval.py`, `strategy-switch.py`, `matchup-eval.py`, `aieval.py`): seeds as the seed gate (30000+k, 31100+n), P1 (roster c1) and P2 (roster c2) CPUs at 81020+i's difficulty, back to back, a `duel gate row` per match. Until 2026-11-13 the old learner's gate (200000 + 1000 h + 100 c1 + 10 c2 + m: P1's habit h, P2's learning m, a `duel learn row`; DUEL_LEARNING.md): h and m are no longer read (REFACTOR_2026-11 R4); the range stays 200000–209999. Every debug command still switches the online fuzzy Q learner off (`*learn-debug-off*`, fq-online.lisp) |
| 2125+k (k 10–14) / 2140 | the seed gate of Senjumaru's pairings SY / SK / SR / SS / SI alone / all five (2113 plays every pairing); every gate row is followed by a `duel senju` line per side that played her (the pacing log: stitches sewn / fallen / detonated, soldiers, catches, weaves, torn, skips, zones by hank, reflections, mirror damage) |
| 2401+k (k 0–3) | the Lisp menus' RESULTS review (DUEL_LISP_HUD §15; claimed 2026-11-11, `lm-results-scene` in debug.lisp): a K.O. now, human Ichigo (P1) vs Kenpachi (P2) in VS CPU with some results numbers (P1 Konpaku 6, best combo 12, 2 Kikons, 3 perfect Hohos; P2 4 / 7 / 1 / 0), then k: 0 P1 wins, 1 P2 wins, 2 a draw; the K.O. cinematic plays (a key skips it) and RESULTS follows, drawn by either renderer; k 3: SELECT with P1 Hisagi and P2 Ichigo (VS CPU: Hisagi's and Ichigo's cards focused without cycling the picks) |
| 2450+k | Senjumaru's tests (`senju-test`, her range through `*char-debug*`, human P1, P2's CPU off unless noted; a `duel probe senju …` line): 0 the Shikai 2.2 m from Kenpachi, 1 six stitches and L at 5 m on a 50-Reishi Kenpachi (1 Reishi left), 2 the soldier vs an active Kenpachi, 3 the umbrella vs a full Shiranui, 4 `:tsuji1` at 3 m (hold L, then 2479: P2's J1 tears the weave), 5–10 each hank's form at 6 m, 11 the combo cut on `:tsuji4`, 12 zero Rukia before `:tsuji2`, 13 `:tsuji1` vs a Yamamoto CPU, 14 `:tsuji1` 5 m from Kenpachi; review stills: 20–25 hank k−19 unfolded under him, 26 six stitches on him, 27 the umbrella open, 28 a weave, 29 P2's J1 now, 30 the 星 siphon probe, 31–34 the awakened Senjumaru at the arena's edge (the drapes' fade: the pair on a tangent at z ±14.8, P1 at the rim with P2 3 m inward, swapped); 2490 the HUD's consing probe (`senju-hud-cons-check`: the Shikai with four stitches, then the Bankai with a live hank, woven 40 and a torn one: the meter in the portrait slot, the landscape row with its label, the portrait label, the one-hand ring; 10 calls each; REFACTOR_NEXT N2); 2491 the draw hook's consing probe (`senju-draw-cons-check`: 10 calls of `senju-draw` in the Shikai idle, at MACHIBARI's first active frame, in the Bankai with its domain; REFACTOR_NEXT N4); 99500+k sets the drapes' fade floor to k / 100 (99600: off, the before still) |
| 76000+f / 77000+f / 78000+f | stills of her Kikon 仕立て直し / 死出六色浮文機 / the awakening held at frame f |
| 90000+ | her knobs without a rebuild (DUEL_SENJUMARU.md "Knobs"; senjumaru.lisp SENJU-KNOB; 80000+ on her branch, moved off ENDLESS's range) |
| 79000–79999 | free since 2026-10-13: the old Lille's (roster index 5, DUEL_LILLE.md; retired 2026-10-12, DEVLOG §208; his code, lille.lisp LILLE-DEBUG / LILLE-ART-DEBUG, removed 2026-10-13, DEVLOG §216). Index 5 stays reserved (`*retired*`): a pairing or a debug command naming it has no character |
| 82000–82999 | claimed 2026-10-09 for Lille Barro II, **Lille** since 2026-10-13 (roster index 6, `:barro`; DUEL_LILLE_V2.md, version 3 since 2026-10-10: DUEL_LILLE_V3.md; barro.lisp BARRO-DEBUG through `*char-debug*`). 82000+k his tests (`barro-test`, human P1, P2's CPU off unless noted, P1's Reiatsu and flash step full; a `duel probe barro …` line: form, state, Reishi, Konpaku, flash step, Reiatsu `rei`, the special resource `ammo` (the base's 狙擊 pips / the wings), the running burst, and `| d` the P1–P2 distance): 0 the base form 2.2 m from Kenpachi, 1 the base form 14 m out, 2 JILLIEL KIN 5 m out, 3 JILLIEL EN (the stance) 3 m out, 4 the owl KIN 5 m out (kept without a burst: `*br-keep-owl*`), 5 the base form 3 m out with 3 pips, 6 KIN 1.4 m out with 8 wings, 7 the base form 3 m out with 3 pips and the stance started (K K → SP2: HIRENKYAKU, every pip), 8 EN 3 m out with 8 wings (K K → SP2: NIJUSHI-KO), 9 the owl EN 3 m out, 10 EN 3 m out with 8 wings, 11 KIN 2 m out with 4 wings and P2's CPU on (the wing armour), 12 the base form 3 m out with the stance started, 13 KIN 4 m out with 8 wings (a burst: the owl), 14 the owl EN 3 m out with 8 wings (K K → SP2: the full volley, 裁き・極), 15 the base form 3 m out with 0 pips, the stance started, 16 the same with 3 pips, 20 flash step and no Reiatsu (J J → L L's gains), 17 KIN 1.5 m out with 4 wings, his K1 and P2's J1 started together (the wing armour), 20 the mirror (both CPUs) 12 m apart, 30 / 31 `*br-keep-owl*` off / on, any other k (99) the probe line only; 82040 / 82041 the ASSIST gate's masher as him (P1) plays every match from JILLIEL KIN, off / on, 82050 / 82051 / 82052 his CPU plays EASY / NORMAL / HARD whatever the gate's difficulty, 82053 off (gate flags, no probe line); 82100–82399 his art stills (barro-art.lisp BARRO-ART-DEBUG, registered ahead of BARRO-DEBUG): 82100+k a scene, Lille II P1 (k + 20: P2, facing the behind camera: the front view) 4 m from an idle Kenpachi, k 0–4 the owl with 0 / 2 / 4 / 6 / 8 wings and the volley started (空收 / 二連 / 四連 / 裁き / 裁き・極), 8 / 9 JILLIEL's turn into the stance / its stance's K K → L L line KL1, 10 / 11 the owl's, 12 the owl's SP2 on its own (the volley's wind-up), 13 the base stance's SP2 HIRENKYAKU, 14 JILLIEL's SANREN, 15 / 16 / 17 the base stance's L1 / J1 / K1 3 m out, 18 / 19 JILLIEL's stance L1 / K1 3 m out, 40–51 the base stance's L1-2 L1-3 (R15, DUEL_LILLE_V3 §19: the snipe's level 2 / 3 shots) J2 J3 K2 K3 JL1 JL2 JL3 KL1 KL2 KL3 3 m out (started on their own, 3 pips; 60–71 their front views); 52–56 (R15) the base stance's L, the snipe, in its charge held 22 / 33 / 48 / 64 / 84 frames (level 1, level 2's flash, level 2, level 3's flash, level 3; 15 / 22 / 32 / 43 / 56 before its levels' x1.5, 2026-10-26), the sim frozen there at once (82299 lets go: the release and its shot; 72–76 their front views); 57 (R16, DUEL_LILLE_V3 §20) the base form's attack-state J3 銃口突 (`:br-j3`, its clip `:br-jab`) 2.2 m out (77 its front view); 58 / 59 (2026-10-26, DUEL_LILLE_V3 §32) a whiffed snipe's recovery `:br-sk-lw` frozen at its frame 6 / 12, 3 m out (78 / 79 their front views); 5 / 6 / 7 (the user 2026-10-12: 「將常態的普攻 K 動作模組改的更加明顯大膽」) the base form's attack-state K1 / K2 / K3 (`:br-k1` / `:br-k2` / `:br-k3`, their own clips `:br-f1` / `:br-f2` / `:br-f3`; each started on its own, K2 / K3 from their link frame `:enter`) 2.3 m out (25 / 26 / 27 their front views); 82200+f the sim freezes once his look clock reaches f, 82299 lets go; 82300+k his awakening held at frame 10 k; 82320+m his awakened stance's move m started on its own, 3 m out with 8 wings (BR-ART-STANCE; a held move, the L dash of m 0 / 20 / 40 and 82118, starts with its button L and releases at once, level 1, as 82115: refactor round 3, 2026-10-21, before it stopped the page with `unknown vpad action NIL`; m 0–14 JILLIEL EN's L1 L2 L3 J1 J2 J3 K1 K2 K3 JL1 JL2 JL3 KL1 KL2 KL3, the openers' clips `:br-en-*`, the follow-ups' `:br-e-jf*` / `-kf*`; 20–34 the owl EN's, `:br-oen-*`, `:br-oe-jf*` / `-kf*`; 40–54 JILLIEL's as P2, the front view; DUEL_LILLE_V3 §8.5, §9; since R10, §15, one charged L: m 1 / 21 / 41 the scene with nothing started, for a script holding L (the charge), m 2 / 22 / 42 unused, m 15–17 / 35–37 / 55–57 JL1–JL3 6 m out); 82380+k his special resource set to k, 0–8 (the spend looks read the drop: one wing a burst at its tip, two or more the armour's shatter, a pip the muzzle glint); 82389 (R11, DUEL_LILLE_V3 §16) the next 82320+m scene in the front view (Lille II as P2, the owl's too; m 55–57 reachable since R11; also the next 82394+k); 82390+k the stance switch's legs 3 m out (BR-ART-LEGS): k 0 / 1 JILLIEL KIN / the owl KIN with the turn into the stance started (the legs put away), 2 / 3 JILLIEL EN / the owl EN with the stance's J1 started (its string ends: back to KIN, the legs let out); 82394+k his awakened guard, the wing wall (BR-ART-WALL, DUEL_LILLE_V3 "The wing wall", the user 2026-10-12): Lille II 2 m from Kenpachi with 8 wings, holding his guard through his brain's press (the scene starts a CPU-vs-CPU match, both brains off), k 0 JILLIEL KIN, 1 the owl KIN (kept without a burst), 2 JILLIEL EN, 3 the owl EN; P1 (the behind camera: his back), or P2 (the front view) after 82389; 82399 the opponent's J1 started now (blocked: the wall's knock); 82398 a `barro consing` line (R11: `whip` the J route L L's lash, `legs` the switch's legs; R15: `snipe-charge` the snipe's charge tells, `snipe` its shot, `kata` the gun-kata's blasts / the swings' impacts, -1 when that move isn't running); 82400–82999 free. Every gate row with him is followed by a `duel barro` line per side (form, ammo, the wing armour's hits, then the pacing log: `kamae`, `kamae-l` / `-j` / `-k` / `-sp1` / `-sp2` / `-step` (the base stance's picks), `k-dash`, `dash-j`, `l-chain`, `spend` / `spend-none` (a follow-up shot's special), `ammo-gain`, `recover` / `recover-big`, `slow-fresh` / `slow-volley`, `to-ranged`, `stance-out`, `owl-in` / `owl-out` / `owl-wing` / `owl-tick`, `armored`, `volley` and `volley-tN`, `sp1-t0`…`-t2`, `sp2-spend` (the specials SP2 spent), `k-sp2` (a K K → SP2 cancel), `follow-empty` (an L L follow-up with nothing to spend), `en-dash` (EN's fast Step), `misuji`, `x-hit` / `x-guarded`, the CPU's `ai-kamae-*` / `ai-zone` / `ai-burst` / `ai-follow-no`, the ASSIST's `as-k-link` / `as-stance` / `as-stance-k`, `awaken-tick`) |
| 83000–83999 | claimed 2026-10-17 for **Hisagi** (roster index 7, `:hisagi`, DUEL_HISAGI.md; hisagi.lisp HISAGI-DEBUG through `*char-debug*`, the art's 83901 ahead of it). 83000+k his tests (`hisagi-test`, human P1 Hisagi, P2's CPU off unless noted, both gauges full, the sickle IN unless noted; a `duel probe hisagi …` line: form, state, the sickle `:in` / `:out` / `:ret`, the anchor x z, the out timer, the return's countdown, Reiatsu, `| p2` state / Reishi / guard gauge, `| d` the distance): 0 2 m from an idle Kenpachi, 1 6 m from him, 2 4 m from him with the sickle out (anchored 3 m ahead, the timer at 0), 3 8 m from Yamamoto with his L wave started and the windmill started (hold L: it wards the wave from every side), 4 5 m from Kenpachi with NAGE started, 5 the mirror (both CPUs) 6 m apart, 6 2 m from Kenpachi with J1 started (K K: MAKI, HODOKI until S1; since S1 K K: NOKO, TSUI, DUEL_HISAGI §23.3), 7 2 m from him with J1 started and L latched (S1's bridge: hold L to charge, K for the K string; DUEL_HISAGI §23.1), 8 8 m from him with the windmill started (hold L, K: the charged K1 at range), 9 5 m from him with K1 started and J latched (S2's KJ: J2K leaps in on the hit; J again for KJJ; DUEL_HISAGI §23.5), 19 5 m from him with K1 started and K latched (KK; J during K2: KKJ's J3K leaps in; claimed 2026-10-18); the Bankai (B2b, P1 awakened without the cinematic): 10 the ranged mode 6 m from Kenpachi, since DUEL_HISAGI §28.4 (the core Bankai, 2026-10-29; §17's KUBIKAKE / grey / pool scenes retired) 11 the ranged mode 4.5 m from him (J ×5 > SP ×3: AS3's KAKE binds), 12 a bind 1.6 m from him, P1's Reishi 400 against his 1300 (a clash evens them), 13 as 12 with his Reishi 10 and one Konpaku (a K.O. inside the bind; his Konpaku 9 in 12 / 14), 14 a bind 6.5 m from him with the bind AS3 started (SP SP: its whiff, back to the ranged mode), 30 / 31 (claimed 2026-10-29) P2 starts his NS (his pointer's) / his J1 now, no setup (a scripted clash), 15 the Bankai mirror (both CPUs, both awakened) 6 m apart; B4c (DUEL_HISAGI §22.6; B4a's mark scenes retired with the marks): 16 the ranged mode 2.5 m from an idle Kenpachi (the gathered route: K1 綁束 then K K / K J / J J), 17 the ranged mode 3.5 m from him (the spread route off J1: J J / J K / K K), 18 the ranged mode 4 m from a CPU Rukia with P1's CPU on (the zone game; a fresh CPU battle: no other scene starts Hisagi vs Rukia); 20 / 21 (claimed 2026-10-20, DUEL_HISAGI §25.20) P1 the ASSIST gate's button-masher (habit `:dumb`, an EASY CPU's 24 f eyes) with ASSIST ALWAYS + COMBO + BREAK against a CPU 6 m off: 20 the Shikai vs Lille (her shots: AUTO GUARD's windmill; the route plans), 21 the Bankai's ranged mode vs Kenpachi (the tip opener, the routes, the bind); 22 / 23 (claimed 2026-10-23, DUEL_HISAGI §25.26) the ranged mode 4.25 / 5.75 m (DUEL_HISAGI §25.35's tips) from an idle Kenpachi (on K1's / J1's chain tip: the flow down the hanging chains / their ends' glints, §25.28), 24 (claimed 2026-10-23, DUEL_HISAGI §25.27) the Bankai mirror 4.25 m apart (§25.35), both CPUs off (both on K1's tip: P1's white flow, P2's black); 40–47 (claimed 2026-11-12, DUEL_HISAGI §29, the cancel's unlock; `tests/scripts/duel-hisagi-kin.json`): 40 / 41 the Shikai 2.0 m from an idle Kenpachi at pointer 1, P1's NS1a NAGI started with / without P2's J1 started on the same step (its hit in NAGI's startup: NA × NS, a cancel), 42 / 47 the ranged mode at pointer 1, NS1b ŌGI started with / without his J1, 43 / 44 the ranged mode at pointer 2, NS2a TABA started with / without his J1, 45 the Shikai 1.5 m, both J1 started, P1's move frame set ahead by the two startups' difference (both hit on one step: a same-class tie, the bounce), 46 no setup: the two put 2.0 m apart again, idle, P1's state kept (the combat log's `KIN on` / `KIN off` / `KIN: … inside its m dead zone at d …` lines, the `hisagi-bind` probe line's `kin`); 48 / 50–99 (claimed 2026-11-12, DUEL_HISAGI §30, NS2 a > b > c; `tests/scripts/duel-hisagi-ns2.json`): the ranged mode at pointer 2 from an idle Kenpachi at 2.0 + (k - 50) / 10 m (50–99: 2.0–6.9 m; 56 2.6, 60 3.0, 65 3.5, 70 4.0) / 48 from an idle Ichigo at 3.0 m, and a per-tick `duel trace t N p1 STATE MOVE sf N | p2 STATE sf N | d D` line while the scene runs (`*hs-trace*`, set only by these scenes; the hit ticks come from the combat log, the victim's first IDLE tick from the trace); any other k < 100 the probe line only; 83100+k / 83200+k the Shikai's damage dealt / taken × (0.5 + k / 100); 83300+k / 83400+k the ranged mode's; 83900 the probe lines (also a `duel probe hisagi-bind …` line: the form, bound / armed / ending, the 聚 flag, the pointer, each side's Reishi and Konpaku; §17's pool and snapshot before DUEL_HISAGI §28.4); 83901 a `duel hisagi look consing` line (his `:pose` hook HS-POSE and HISAGI-DRAW in the stance, out at the anchor, NAGE's and HIKI's hit frames (since A1, DUEL_HISAGI §24.1: K1 NAGI's and K2 NOKO's, plus NOKO's wheel, K3 TSUI's plunge and its sky, the leap J3K), the windmill, and the Shikai clips' J1 short grip, J3's two let-out sickles, KARI-OTOSHI's, SHIBARI's wrap, KUBIKAKE's garrote: 10 calls each, 0 B wanted; DUEL_HISAGI §21.4; since §21.8 also the Bankai's clips: J3, gathered K2 SOKUDA's hit (TSUISA's clip until batch A2 drew its own), KUBIKAKE, SAHARAI, SP1, SP2, KOSA (B4a's marks' look gone with them, B4c), the bind's MAKIGIRI, SHIBORI, SP1, KOSHU, UNWIND; since batch A2, §24.2, the ranged route links' lashes and the bundle and the bind's stance with the noose held; since batch A3, §24.3, SAHARAI's recovery, KOJO's heave (the held chain trembling) and reap, KAIBAKU-GEKI's haul and its throw-off; since DUEL_HISAGI §26, NA1's grip and the bind's hawser and the lightning's sparks in their pointer stances; since §27.5, 刈's stance (the wound chain), TAN-GARI's / REN-GARI's / SEN-GARI's / KO-GARI's / KARI-AGE's hit frames, CHIKUDEN's charge down the chain, 放電's burst on a hit, 餘電 at 400 and fading at 30; since §27.6, on their own clips, also CHIKUDEN's front down the chain, 放電's charge and NS3a's wrap; since §27.10 AS1 TSUMUJI's own clip: the flat-spinning sickle's flight, its orbit with the cuts, its return); 83902 a `duel hisagi tip` line per Bankai move (hisagi-art.lisp HISAGI-TIP-CHECK, DUEL_HISAGI §21.8: P1 awakened 3 m from Kenpachi; on each hit frame the body posed by the form's clip and the draw hook run, what strikes measured from his feet against the volume's far edge; since A1, DUEL_HISAGI §24.1, also `duel hisagi tip base …` lines for the Shikai's K1 at x1.0 / x1.6, J2K, J3K against their arcs and K2 / K2J / K3 as how far the drawn sickle sits off the victim, 0 wanted; since §27.5 also pointer 2 刈's five moves' let-outs against their arcs; since §27.10 AS1 TSUMUJI's drawn sickle off the victim, its orbit 0.45 m, ≤ 0.50 wanted: the chain capsule's 0.35 + 0.15; since DUEL_HISAGI §28.15 `duel hisagi tip hook` lines: the bind's KAGIYOSE / KAGIYOSE-GIRI at 3 / 6 m and MATOI at 2.5 m with the victim 0 / 30 / 60° (MATOI 0 / 7°, and 30° whiffed) off his facing, the drawn crescent's point off the victim's feet, ≤ 0.15 wanted); 83500–83549 the Bankai's clip strips (DUEL_HISAGI §21.8: 83500+k picks slot k of `*hs-bk-strips*`, k 0–46: 0 idle, 1 walk, 2 run, 3 J1, 4 J2, 5 J3, 6 L (redrawn at S 10 / R 32 by batch A3), 7 SP1, 8 SP2, 9 the O's aim, 10 its strike, 11 the Breaker's dash, 12 its strike, 13 KUBIKAKE, then the bind's 14 J1, 15 J2, 16 J3, 17 K1, 18 K2, 19 K3, 20 SP2 KAIBAKU-GEKI (HIKIYOSE's clip, its stand-in, until batch A3, DUEL_HISAGI §24.3; its own clip since), 21 the old SP1 RAIDEN, 22 KOJO (L since B4c; redrawn at S 30 by batch A3), 23 the O's zip, 24 its strike, 25 UNWIND (B3b's K1 / K2 / K3 slots gone with their clips since B4a), then batch A2's (DUEL_HISAGI §24.2) 26 K1 綁束, 27 spread K2, 28 spread K3, 29 gathered K2, 30 gathered K3, 31 gathered J2, 32 gathered J3, 33 the bind's stance, 34 the bind's Step + J SENGEN (DUEL_HISAGI §25.10), then the Shikai's core-system clips (DUEL_HISAGI §26, the base form) 35 NA1 旋 SEN's coil `:hs-na1`, 36 pointer 2's stance `:hs-st-bind` (dormant since DUEL_HISAGI §27.5), 37 pointer 3's `:hs-st-raiden`, then §27.5's (claimed 2026-10-28) 38 pointer 2 刈's stance `:hs-st-kari`, 39 TAN-GARI `:hs-kr-tan`, 40 REN-GARI `:hs-kr-ren`, 41 SEN-GARI `:hs-kr-sen`, 42 KO-GARI `:hs-kr-ko`, 43 KARI-AGE `:hs-kr-age`, 44 CHIKUDEN, 45 放電 HODEN (on a hit: the burst on the victim; since DUEL_HISAGI §27.6 their own clips `:hs-chikuden` / `:hs-hoden` at their S, 2 m, the bind wound on the victim and the lightning along the chain; `:hs-s-noko` / `:hs-s-raiden` before), then 46 AS1 旋風 TSUMUJI `:hs-tsumuji` (claimed 2026-10-29, DUEL_HISAGI §27.10; 4.5 m, where its leap ends); then 83940+3i+v as below, the ranged slots awakened, the bind's with a bind on); 83560–83579 (claimed 2026-10-29, DUEL_HISAGI §28.11, batch 2a) the core ranged mode's clip strips: 83560+k picks slot k of `*hs-r2-strips*` (0 聚 stance `:hs-k-st-shu`, 1 SA UCHI `:hs-k-uchi`, 2 the gathered SA (the bundle; since DUEL_HISAGI §28.21 its own clip `:hs-k-g-sa`, 直刺), 3 NS1a WA (`:hs-k-saharai` at 18/14), 4 NS1b OGI `:hs-k-ogi`, 5 NS1c ISSEI `:hs-k-issei`, 6 AS1 RANSA `:hs-k-ransa`, 7 NS2b TATAKI `:hs-k-tataki`, 8 AS2a 叩 `:hs-k-sweep`, 9 AS2b JIBASHIRI `:hs-k-jibashiri`, 10 AS3b MAKI `:hs-k-maki`, 11 AS3c KAKE `:hs-k-kake`, 12 / 13 the gathered J2 / J5 at 4.5 m (since DUEL_HISAGI §28.21 the 聚 route's J2 上撈 / J3 繞身連枷), 14 散 stance; since DUEL_HISAGI §28.15 15 J3 SHŌBEN `:hs-k-na3`, 16 J4 SŌBEN `:hs-k-na4` (17 / 18 the gathered J3 / J4 until §28.21 deleted them)), then 83940+3i+v as below (awakened); 83580–83589 (claimed 2026-10-29, DUEL_HISAGI §28.12, batch 2b) the core bind's own clip strips (`*hs-kb-strips*`, a bind on: 83580+k picks slot k, 0 the 絞 stance `:hs-kb-st-shibori`, 1 NS1a KAGIYOSE, 2 AS1 KAGIYOSE-GIRI, 3 NS1c JŪJI, 4 NS2a MATOI (on a hit: the wrap), 5 NS2b / AS2a SHIME, 6 AS2b TSURI (on a hit: hooked), 7 AS3b SAN (DUEL_HISAGI §28.13, 2.3 m); then 83940+3i+v as below); 83910–83964 the Shikai clip strips (hisagi-art.lisp HISAGI-STRIP, DUEL_HISAGI §21.4): 83910+k picks slot k of `*hs-strips*` (0 stance, 1 walk, 2 run, 3 J1, 4 J2, 5 J3, 6 KAESHI-SEN-1H, 7 RIN-1H, 8 NAGE, 9 HIKI, 10 MAKI, 11 KARI-OTOSHI, 12 HODOKI, 13 MODOSHI, 14 KAZAGURUMA, 15 SP1, 16 SP2, 17 the Breaker's dash, 18 KUBIKAKE, 19 the O's aura, 20 the O's strike, 21 intro, 22 win; batch A1, DUEL_HISAGI §24.1: 23 K1 NAGI, 24 K2 NOKO, 25 K3 TSUI, 26 the leap J2K, 27 the leap J3K), 83940+3i+v shows its frame i of 8 (a strike's 0, S/3, 2S/3, S-2, S, S+A, mid-recovery, end; else eight even steps) from view v (0 his right side, 1 the front 33° to his left: him alone on a white card in a held cinematic shot; 2 the match's behind camera with the sim frozen), 83964 lets go; 83980–83985 the Shikai model sheet (hisagi-art.lisp HISAGI-LOOK-SCENE: him alone on a white card, 8 m from an idle Kenpachi, held 4 s in a cinematic shot, then the match: 0 the front, 1 his left side, 2 the back, 3 three-quarters from his left front, 4 the face, 5 Kazeshini held out to his right; DUEL_HISAGI §21 "Look as built"; the match frames are 83000 / 83001); 83986–83994 the Bankai's model sheet (hisagi-art.lisp HISAGI-BANKAI-LOOK, DUEL_HISAGI §21.6: P1 awakened (the ranged mode), P2's CPU off: 83986+k, k 0–5, him alone on a white card 8 m from an idle Kenpachi, held 4 s in a cinematic shot, then the match: 0 the front, 1 his left side, 2 the back, 3 three-quarters from his left front, 4 Kazeshini held out to his right, 5 a wide shot up at the orb and its rope; 83992 / 83993 the match (the behind camera) in the ranged mode 2 / 6 m from Kenpachi; 83994 a bind 2 m from him, no damage dealt (the noose)); 83901's line also counts `Bankai` (the orb, the rope) and `bind` (with the noose), and since DUEL_HISAGI §28.11 a second `duel hisagi look consing 2a` line (the 聚 stance and the core ranged clips' hit frames, 0 B wanted); 83965–83978 his cinematics' stills (batch B5, hisagi-stills.lisp HISAGI-CINE-DEBUG, DUEL_HISAGI §22.7, §26.6): 83965+c starts cinematic c from a fresh scene, played through (0 the awakening 卍解 風死絞縄: P1 in his Shikai 6 m from an idle Kenpachi, AWAKEN! itself; 1 the Shikai Kikon 刈れ, 4 m from him; 2 KOSA, the ranged mode 7.5 m from him; 3 KOSHU, a bind 2 m from him; 4 (83969, claimed 2026-10-28) pointer 2's Kikon 首掛 KUBIKAKE, the Shikai 4 m from him), 83977 (claimed 2026-10-28) is c 5, pointer 3's Kikon 綴雷電 TSUZURI RAIDEN, the same scene; 83978 (claimed 2026-10-28, DUEL_HISAGI §27.8) is c 6, pointer 2's Kikon 刈 KARI, the same scene; 83995 (claimed 2026-10-29, DUEL_HISAGI §28.16) is c 9, the ranged pointer 1 散's Kikon 鎖雨 KUSARI-AME, KOSA's scene, and 83996 (claimed the same day) c 2 again, the rebuilt 聚 降鎖 KOSA; both also log a `duel hisagi cine consing` line (their looks, 10 calls at a frame of each beat, 0 B wanted); 83997 / 83998 (claimed 2026-10-29, DUEL_HISAGI §28.17, batch 3b) are c 7 / 8, the bind kit's pointer 1 / 2 Kikon (CORE-POINTER-CINE: 鎌 鉤刈 KAGI-GARI / 絞 絞首 KŌSHU with its revised beat 1) from c 3's bind scene; 83970+b restarts the last one held at its beat b's middle frame (`*hs-cine-beats*`), 83976 lets go; 83903 / 83904 (claimed 2026-10-28, DUEL_HISAGI §27.5, hisagi-stills.lisp HISAGI-ZAN-SCENE) P1 in his Shikai 2.5 m from an idle Kenpachi with 餘電 ZANDEN on him at 480 frames (the full crawl) / 50 (its fade), the match camera, the sim running; 83600+d / 83700+d (claimed 2026-11-01, DUEL_SUBLIMATION §17.7) the switch routes: P1 in the Shikai with SUBLIMATION 60 / in the Bankai's ranged mode with DRIVE 60, d / 10 m from an idle Kenpachi, pointer 1 (`tests/scripts/duel-switch-routes.json`); 83800–83808 (claimed 2026-11-09, DUEL_AI_STRATEGY §8.16, cpu-hisagi-range.lisp HISAGI-RANGE-SCENE) the ranged mode's distance control: P1 a HARD CPU Hisagi in the ranged mode playing the library's `:h1-range`, P2 a HARD CPU Kenpachi: 83800 pointer 1, DRIVE 60, Kenpachi idle 2.0 m off (his CPU off: WA, then the DRIVE switch to TABA), 83801 as 83800 with DRIVE 20 (no switch), 83802 pointer 2, Kenpachi walking in from 2.0 m (his CPU after 1.2 m), 83803 pointer 1, DRIVE 60, Kenpachi 1.8 m off starting J1, 83804 as 83800 with no strategy (the shipped CPU), 83805 as 83800 with the strategy without `:dswitch`, 83806 / 83807 the Shikai, pointer 1, SUBLIMATION 60 / 20, 4.5 m from an idle Kenpachi (his CPU off), P1's NS1 started (the generic `:dswitch-map` route NS1 > NS3a), 83808 pointer 1, DRIVE 60, Kenpachi walking in from 5 m; 83809 / 83810 (claimed 2026-11-09, DUEL_AI_STRATEGY §8.19 round 3) as 83806 with the merged style (`:dswitch 1.0`, the Shikai's map) with / without `:shikai-dswitch` (`tests/scripts/duel-shikai-dswitch.json`: 83809 logs `P1 cpu switch 1 -> 3`, 83810 none); a `duel hrange scene` line; 83811–83814 (claimed 2026-11-12, DUEL_CORE §2.1, hisagi.lisp HS-J1-CANCEL-SCENE; the diagnosis of 「為什麼檜佐木遠距 J1 相消後接不了 J2 與 AS？」, `tests/scripts/duel-hisagi-j1-cancel.json`) a PRACTICE vs Kenpachi, P1 in the ranged mode, idle: 83811 / 83812 the dummy on GUARD ALL 2.2 / 4.5 m apart, 83813 / 83814 the same with the dummy on STAND (the script presses J1, then J or SP: the CANCEL line, whether J2 / the AS start); 83815 / 83816 (claimed 2026-11-12, DUEL_CORE §2.2, `tests/scripts/duel-steal-cap.json`) the steal scene: 83815 = 83000 (the Shikai 2 m from an idle Kenpachi) with P1's flash-step 100 and P2's 300, 83816 a `duel steal end … fs p1 … p2 …` line; 83550–83559, 83590–83599, 83817–83899, 83905–83909, 83979, 83999 free. His pairings: k 28–35 (HY HK HR HI HS HL HB HH; HL, k 33, retired), `gate_cmd` 2163–2170, his group 2143. Every gate row with him is followed by a `duel hisagi` line per side (form, then the pacing log: `throw` / `maki` (the sickle out), `throw-hit` / `throw-touch` / `throw-whiff` (the anchor's case), `drag`, `pull` (HIKI / HODOKI took it in), `pull-hit` / `pull-touch`, `modoshi`, `raiden-in`, `auto-return` / `far-return`, `out-frames` (frames out of hand), `windmill` (holds) / `windmill-block` / `windmill-crush`, S1's (DUEL_HISAGI §23.1) `bridge` (the windmill off a J link) / `kaza-k` (K out of a windmill: the K string started) / `charge` (its charge frames, summed) / `ai-kaza-k` (his CPU's), S2's (DUEL_HISAGI §23.5) `leap` (a J after a K leapt: J2K / J3K) / `ai-leap` (his CPU's pick of it), the time-at-range bands `at-close` (< 1.8 m) / `at-mid` (< 4) / `at-far` (≤ 6.5) / `at-out`, his CPU's `ai-windmill` / `ai-modoshi` / `ai-sp1` / `ai-sp2`, and `opp-side-step` (a CPU facing him side-Stepped his throw); the Bankai's since DUEL_HISAGI §28.4: `bind-arm` (AS3's KAKE hit), `binds` / `unbinds` (the bind's start / end), `bind-even` (a clash's balance), `bind-frames`; since DUEL_HISAGI §29 (2026-11-12, every form): `kin` (a cancel turned the close-range unlock on) / `kin-hit` (a contact inside a dead zone the unlock lifted); before it (B2b, DUEL_HISAGI §20): `kubi` (KUBIKAKE started) / `kubi-hit` (a hit with his 200: the bind due) / `kubi-plain` / `kubi-block` / `kubi-whiff` / `kubi-nobind` (the mirror's double throw, a stale hit), `binds`, `pool-start` / `pool-end` (summed per bind), `bind-frames`, `end-drained` / `end-released` / `end-timeup`, `rel-opp` / `rel-self` (the release split, summed), `grey-dealt` / `grey-taken`, `pool-sp` (SPs from the pool), `release-press` / `release-held` (the bind's P FREE: gone in DUEL_HISAGI §24.5, back since §25.14), `kaibaku` (B4c: SP2 KAIBAKU-GEKI's release), `j-push` / `j3-push` (B4a: J1 / J2 onto the tip, J3's 5.5 m), `uchi-push` (B4c: gathered K2's slam onto its line), `saharai-hit` / `saharai-block`, `pull` / `pull-arrive` (L KOJO's drag since B4c), `r-frames` / `r-near` (< 2 m) / `r-mid` (3.5–9 m) in the ranged mode, `b-near` (< 2 m bound), his CPU's `ai-throw` / `ai-saharai` / `ai-dmg` / `ai-fast` / `ai-end` (B4c: its route pick off a link-1 / -2 hit: the K, the J, the end) / `ai-release` (the plain P FREE: gone in §24.5, back since §25.14) / `ai-kaibaku` / `ai-kojo` / `ai-bsp1` (B4c; `ai-pull`, `ai-bsp2` gone; `ai-throw` the SP2 cancel off a hit), `opp-step-kubi` (a CPU facing him side-Stepped KUBIKAKE)) |
| 86100–86199 | claimed 2026-10-31 for **Ichigo's SUBLIMATION / switch scenes** (`ichigo-sub-debug`, ichigo.lisp, DUEL_SUBLIMATION): human P1 Ichigo vs an idle Kenpachi (CPUs off): 86100 / 86101 the Shikai 2.2 m (gauges full); 86102 / 86103 KESSA 1.4 m with SPIRIT DRIVE empty / full; 86104 / 86105 / 86106 the Shikai with SUBLIMATION 60, KESSA with DRIVE 60, KESSA with DRIVE full, on the phone's deck (run with --mobile --size 390x844; 86105 is also the keyboard switch scene of `duel-drive-switch.json`); 86107 KESSA with DRIVE 20; 86108 the Shikai with SUBLIMATION 60; 86110 the 超速連斬 Kikon cinematic at frame 40; 86120 P2's J1 now; 86130 the Getsuga flame preview |
| 84000–84099 | claimed 2026-10-29 for **Kenpachi's core scenes** (`ken-core-debug`, ken.lisp, DUEL_KEN_CORE.md): 84000 (since 2026-11-05 the V3 sealed form, DUEL_KEN_V3 §35, `duel-ken-sealed.json`; 84001: the same with Kenpachi in the V3 Shikai, awakened, L 0, DUEL_KEN_V3; 84004 / 84005: in V3's Bankai 狂嵐 KYORAN / 斬壞 ZANKAI, DUEL_KEN_V3 §26 (84004 was the old Bankai with the arm full, DUEL_KEN_CORE §8); 84002 / 84003, RYOTE / NOMIHOSE, retired 2026-11-03) human P1 Kenpachi and an idle Ichigo P2 2.2 m apart (both CPUs off, gauges full); on the running scene 84010 P2 starts his NS now, 84011 his J1 now (the scripts time the presses); 84020+k (k 0–10) P1's awakening gauge full with SUBLIMATION at 10k %, 84040+k P1 awakened with s 0.4 frozen and SPIRIT DRIVE at 10k %, 84060 the real awakening with SUBLIMATION at 50 %, 84070 a `duel sub …` probe line per side (DUEL_SUBLIMATION §7; the scene start clears all three gauges); 84080+k (k 0–4) the Bankai's arm at k pips (DUEL_KEN_CORE §8); 84090+k (k 0–3) the Shikai's unlock level L = k on the running scene (DUEL_KEN_V3 §4; `duel-ken-shikai.json`); 84094 / 84095 (claimed 2026-11-04, DUEL_KEN_V3 §19) the 84001 scene 3 m apart, then the Shikai's pointer-1 / pointer-2 Kikon cinematic (回天斬 KAITENZAN / 墜天斬 TSUITENZAN) played through; 84096 / 84097 (claimed 2026-11-05, DUEL_KEN_V3 §33) the 84004 / 84005 scene 3 m apart, then the Bankai's Kikon cinematic (狂嵐 千切・極 / 斬壞 盾ごと・極) played through; 84006 / 84007 / 84008 (claimed 2026-11-05, DUEL_KEN_V3 §39) the 84000 scene 3 m apart, then the sealed form's Kikon cinematic (鈴 / 斬ってみろよ / 両断) played through |
| 85500–85999 | claimed 2026-10-24 for **Rukia's look** (the TYBW look rebuild, DUEL_RUKIA_TYBW §2; rukia-art.lisp RUKIA-LOOK-DEBUG through `*char-debug*`, ahead of rukia.lisp's ranges; 85000–85499 are her sim batch's). 85500+10l+s: the model sheet of P1 Rukia in look l (0 the Shikai, 1 −18, 2 −50, 3 −273, 4 the 白霞罸 costume: the zero form drawn in the `:rukia-bankai` body with the ice blade), 8 m from an idle Kenpachi (P2's CPU off, both gauges full; the band set by her cold as 67000+k): s 0–6 her alone on a card (white behind the black looks, black behind the white ones) held 4 s in a cinematic shot (`*ru-look-shots*`): 0 the front, 1 her left side (the plaque), 2 the back, 3 three-quarters from her left front, 4 the face, 5 the blade held out to her right (the guard, the ribbon), 6 J3's pirouette (`:ru-spin`) seen from behind (the cloth in a turn: shoot ~0.27 s in); 7 / 8 the match (the behind camera) 4 m from him (8: the same, for a script that holds W to walk her in); 85900 a `duel rukia look consing` line (RUKIA-LOOK-CONS-CHECK: 10 calls of her `:draw` hook RUKIA-LOOK-DRAW, the moving cloth, standing and in the form's J hit frame, in each look; 0 B wanted); the rest free |

Most scenario commands (2200–2319) first make sure the right battle runs (`ensure-battle`: a new
match with its intro skipped and P2's CPU switched off) and then place the fighters a few metres
apart (`place`).

## Log lines

| Line | From |
|---|---|
| `duel -> TITLE` … `duel -> RESULTS` | every flow change (`set-flow`) |
| `duel match seed 7 CPU-CPU YAMAMOTO vs KENPACHI NORMAL` | a match starts |
| `duel hash t=600 \| x y z yaw STATE FORM r<reishi> k<konpaku> a<reiatsu> f<flash-step> g<guard>[!] w<awaken> m<meter> n<kikon> h<heat> \| … \| cd <P1 cooldowns> <P2> \| haz N` | every 600 battle steps: positions in cm, yaw in 0.01 rad, gauges (`!` = guardless; m = Inferno or NOME, the FORM = Nozarashi's cup), n = the Konpaku the last Kikon rush was worth, CPU heat, each command slot's cooldown, hazard count (the determinism check) |
| `duel -> RESULTS winner P1 konpaku 7-0 ticks 7351 secs 122.5` | the match result (winner, Konpaku P1-P2, sim steps, seconds) |
| `duel gate YAMAMOTO KENPACHI: 20 matches, KOs 20, median … s, min …, max … \| …` | the seed gate summary |
| `duel gate row seed N P1CHAR P2CHAR secs … winner P1\|P2 forms F1 F2 blow N` | one per gate match: its final forms (BANKAI / KATAUDE: he entered the Bankai; the gamble A/B reads them) and the match's blow-aways (the hidden hit-stun tolerance, DUEL_DESIGN.md) |
| `duel probe YA-J1 blocked: attacker free at +27, defender at +25, advantage -2 (table -2)` | a frame probe |
| `[  tick] P1 move YA-J1 [why]` (the CPU's why: `STRING`, `O-ENDER`, `J-BEATS-K`, `PRESSURE`, …), `P1 YA-J1 -> P2 HIT 38`, `P1 YA-KIKON -> P2 KIKON 70` (a rush strike that became the Kikon; `BLOCKED` / `HIT` otherwise), `P1 KIKON FOLLOW-UP on P2 [(red)]` (it hit with O held: the knockback and the dash-in), `P1 BURNOUT RECOIL` (… `BLOCK` / `ARMOUR` / `BREAKER`: a Bankai stance's gauge ran out) and `P1 GUARDLESS BLOCK` (any gauge, by cause), `P1 form BANKAI-WEST` (the L switch), `P1 refused SIG: cooling 61` (a press while it cools), `P2 scorched 15` (West's armour / parry), `P1 BIND -> P2 HIT 40` (South's grab), `P1 KIKON on P2: -2 konpaku, 7 left`, `P1 GUARD CRUSH` / `P1 GUARD BACK`, `P1 form HELLFIRE`, Nozarashi's cups `P1 form RYOTE` / `NOMIHOSE` / `NOZARASHI`, `P1 DRINK 21 (+20 drunk)`, `P1 GUARD CRUSH (drinking)`, `P1 RIFT -> P2 HIT 50`, `P1 RIFT CLOSED`, `P1 CASH-OUT` (why `CASHOUT-PUNISH` / `-NEAR` on the move line), `KIKON on P2: -3 konpaku, 6 left (RYOTE)` (the attacker's form), `P1 PERFECT HOHO`, `P1 EVOLUTION`, `P2 BLOWN AWAY by P1 (stun tolerance 18.0, combo hit 8)` (the hidden hit-stun tolerance, DUEL_DESIGN.md), `CLASH`, `cine NAME`, `P1 step [why]` / `P1 dash [why]` (a run starts; why DASH / DASH-BACK for the CPU) / `P1 run -> YA-Q1, carry 1.0 m` / `P1 BURST` / `hoho` / `guard` | the combat log (`clog`, components.lisp): move starts (with the CPU's reason), every applied hit and its result, Konpaku, forms, events |
| `duel camera CAMERA  SIDE` | the CAMERA option changed (menu or 2109) |
| `duel page: coarse T hand RIGHT settings (0 0 2 2 0)` | startup: the device kind and the saved SETTINGS (option indices, `*settings*` order) |
| `duel setting HAND LEFT` | a SETTINGS row changed (saved) |
| `duel practice DUMMY  GUARD ALL`, `duel practice reset`, `duel practice K.O. -> reset` | a PRACTICE option changed, RESET POSITION, a K.O. in PRACTICE (no match end) |
| `missing clip :name` | once per clip name the art lacks (the stance plays instead) |
| `stats: fps … cons/frame … draws … particles … \| ms/frame sim … queue … render … \| BATTLE t … p1 STATE reishi p2 … \| heap … MB \| fx-dropped N` | the engine's 2 s stats line plus the duel's tail |

## Test scripts (`tests/scripts/duel.py`)

`python3 tests/scripts/duel.py` writes `tests/scripts/duel-*.json`; run each with
`node tools/run.mjs dist/duel --secs N --script tests/scripts/duel-X.json` (headless Chrome,
SwiftShader WebGPU). Every script waits 9 s for startup.

| Script | --secs | What it does / what to check |
|---|---|---|
| `duel-cvc-ii.json`, `-ik`, `-kk` | 40 | turbo + seeded CPU vs CPU (debug 2102, then 3007 / 4007 / 5007: II, IK, KK since the core system, 2026-10-27; YY / YK before): reaches `duel -> RESULTS winner …` in a few seconds; the G2 references (`tests/style-cvc-ref.txt`, `style-gates.py cvc`) |
| `duel-gate.json` | 1100 | debug 2113 (every pairing of the playable roster × 20 seeds), then 2107 to turn the combat log back on: one `duel gate` line per pairing, every match a K.O. Long; not run unless the user asks (2026-10-29) |
| `duel-keys.json` | 40 (`--fixed-dt 16.666667`) | P1's keyboard against an idle CPU (2500: Ichigo vs Kenpachi): `P1 move IC-J1`, `IC-J2`, `IC-NA3` (it walks in with W: VS CPU's behind camera, then 2393 puts him 2.2 m out, since a string needs contact), `P1 step`, `P1 hoho`, in that order. The script still presses K, L, I, U and SP1 / SP2 with the old keys (unbound since the core system: no log line) |
| `duel-extras.json` | 45 | P1's keyboard, VS CPU (behind camera): hold Space + W (`P1 step`, `P1 dash`), again with J out of the run (`P1 run -> IC-J1, carry 0.8 m`), Shift+Space (`P1 hoho`: the camera swings round), 2320 + Shift and J taps (`P2 KE-Z-J1`…`J5 -> P1 HIT`, then `P1 BURST BLUE`), 2321 (a forced Burst), pause → CAMERA → SIDE (`duel camera CAMERA  SIDE`). Shots `tests/shots/duel-extras-*.png`: behind, dash, hoho-a / -b, burst-a / -b, pause, side |
| `duel-bankai.json` | 44 (`--fixed-dt 16.666667`) | Kenpachi's Bankai (2386+k, DUEL_KEN_BANKAI.md): P from cup 3 with ≤ 4 Konpaku → `P1 BANKAI (konpaku -> 1, -3)` and a dump `BANKAI r1300 k1 … m4 u0`; K K K → `UDE -KE-B-K1 3 left`, `-KE-B-K2 2 left`, `-KE-B-K3 1 left`; the bite `KE-B-BITE -> P2 HIT 120`; TATE-GOTO `KE-B-SPLIT -> P2 HIT 260`; one pip left: `UDE -KE-B-K1 0 left`, then `form KATAUDE` / `ARM BURST` only after that K1's recovery; 片腕 J1 `KE-J1`. Shots `tests/shots/duel-ken-bankai-*.png` (the stance, the bite, TATE-GOTO, the burst, 片腕, the two cinematics' key frames via 35000+f / 36000+f) |
| `duel-strings.json` | 40 (`--fixed-dt 16.666667`) | the J strings by keyboard (2394+k, form k 0 Ichigo's Shikai, 1 KESSA, 2 Kenpachi, 3 his Shikai): `IC-J1`, `IC-J2`, `IC-NA3`; `P1 form KESSA`; `KE-Z-J1`..`J3`; `P1 form NOZARASHI`, `KE-S-J1`..`J3`. The K and O presses of the old strings (K1-K3, the O ender, J K J) do nothing since the core system. Shots `tests/shots/duel-string-{sodebi,o-ender,rakujitsu,tsuki,kick}.png` (names kept) |
| `duel-practice.json` | 62 (`--fixed-dt 16.666667`: real-time key timing on a loaded host loses string presses) | SETTINGS and PRACTICE by keyboard (1280×720): `duel -> SETTINGS`, `duel setting HAND LEFT`, `HAND RIGHT`, `CAMERA SIDE`, back to MODE, PRACTICE (`match seed … PRACTICE …`), J J J on the standing dummy (`IC-J1`, `IC-J2`, `IC-NA3 -> P2 HIT`, then the dump shows P2 `r1300`: refilled), `duel practice DUMMY  GUARD ALL` (the default pair is Ichigo vs Kenpachi, two `:core` kits: `IC-J1 x P2: CANCEL`, `IC-J2 x P2: CANCEL`, DUEL_CORE §9), `DUMMY  GUARD AFTER HIT` (J → `HIT`, a J 0.8 s later → `BLOCKED`; a `:core` dummy never guards: `HIT` twice), `GAUGES  INFINITE` (the dump: P1 `a300 f100 w100`), CAMERA back to BEHIND (`duel camera`), the HP / KONPAKU rows (`duel practice P1 HP  50%` … `DUMMY KONPAKU  8`; dumps P1 `r650 k4`, P2 `r325 k8`, again after a hit and after `duel practice reset`); no `RESULTS`. Shots `tests/shots/duel-practice-{mode,settings,combo,pause,pause-rows}.png`; `practice-settings-sheet.png` (+ `mobile-practice-*.png`) is the review sheet |
| `duel-practice-cancel.json` | 230 (`--fixed-dt 16.666667`) | PRACTICE's GUARD ALL with a `:core` dummy (DUEL_CORE §9, 2026-11-12), P1's keys written out: per pair KK KI IK IH HK HI (2800 + 3a + b) J1, the five J, NS ×3, NS then the SA, J then SP (the AS), idle 3 s on KK / IH; then Hisagi's NS1 ×3 at 2.2 m against DUMMY STAND (the control: no contact), Ichigo's pointer 2 (the wave lands), J1 at 6 m (no answer), STAND / GUARD AFTER HIT / CPU, COUNTER J1 with GUARD ALL (J1 after the SA's stun). Read the combat log's `x P2: CANCEL` / `-> P2 HIT` lines per `===` scene: J1 1/1 cancelled in every pair, the five J 5/5 (HK 4/5), NS ×3 3/3, NS then SA 1/2, J then AS 1/2 (the counts DUEL_CORE §9 lists) |
| `duel-hisagi-j1-cancel.json` | 125 (`--fixed-dt 16.666667`) | a cancel is symmetric (DUEL_CORE §2.1, 2026-11-12): Hisagi's ranged J1, then J or SP 0.2 / 0.35 / 0.5 / 0.7 s later, PRACTICE vs Kenpachi at 2.2 / 4.5 m against GUARD ALL (83811 / 83812) and STAND (83813 / 83814): at 2.2 m GUARD ALL `P2 KE-Z-N1A x P1: CANCEL`, then `P1 move HS-R-J2` / `P1 move HS-R-AS1` (`HS-R-AS1 -> P2 HIT 43`); 4.5 m and STAND as before |
| `duel-steal-cap.json` | 45 (`--fixed-dt 16.666667`) | a stealing AS's per-hit take, no cap, 50 % to the attacker (DUEL_CORE §2.2, 2026-11-12): P1 (flash-step 100) J1 then SP vs P2 (300): Hisagi's TSUMUJI (83815), Ichigo's RAKUGA (74000), KESSA's KUSARI-BIKI alone and with two NS3 clones (74001, + 74904); the combat log's `P1 STEAL fs N from P2, gains G` per hit, `duel steal` lines before / after |
| `duel-flow.json` | 34 | the menus by keyboard: VS PLAYER (row 2: VS CPU, PRACTICE, VS PLAYER; P2 confirms with KP1), skip the intro, pause / resume, pause → CHARACTER SELECT → back to TITLE, then VS CPU HARD; check the `duel ->` lines; shot `duel-flow-vs-cpu-hard.png` |
| `duel-perf.json` | 75 | 60 s of real-time CPU vs CPU (4003): the stats lines |
| `duel-shots.json` | 90 | the screenshot set `tests/shots/duel-*.png`: title, mode, select, intro, a CPU vs CPU neutral (Perfect Hoho and `COUNTER` lines on the way), Kenpachi's BUTTAGIRU hit (2309), a guard break (2306), Ichigo's and Kenpachi's force-cine stills (2200+k); the commands of the retired kits' stills (2300-2303 Yamamoto's fire wave, Hellfire, Shiranui…) do nothing now |

Screenshots stall a script by ~0.5 s, so keys pressed right after one can arrive in the same frame
as their release and be lost; keep shots out of timed key sequences.

Stills of the Kenpachi batch (the awakening without an eyepatch, the three cups, DRINK, the rift, the cash-out, West's
hold-U armour, the run facing the opponent): `python3 docs/research/style-history/batch-shots.py` → `tests/shots/batch-*.png` and the contact
sheet `batch-sheet.png`.

Galleries (test targets, not the game; build lines in their headers): `tests/duel-view.lisp`
(bodies, weapons, clip strips, stage, every sound; `tests/scripts/duel-view.py`; scene 5 = 2005 lines up both
fighters' three expressions, 6300+k sets every actor's face: 0 neutral, 1 shout, 2 hurt; 7000+k shows grip clip k's four
worst-drift frames, each as a pair: keys only, then with the game's left-hand grip); since refactor R5 (2026-11-12) it shows Ichigo and
Kenpachi (the retired kits' art left main) and `tests/duel-vfx.lisp` (the VFX gallery over the retired Yamamoto's looks) is gone (git history).
Restyle Phase 5 stills: `python3 docs/research/style-history/style-5-shots.py` (the redone effects, the kendo and re-authored clips, the
expressions, before / after the previous build), `python3 docs/research/style-history/style-5-checks.py --run dist/duel` (3 expressions per
fighter, the Jokaku manga page, callouts clear of the HUD at 1280x720 and 800x450, 0 B for the new looks).

## Determinism

The same seed replays the same match: all gameplay randomness is `sim-rnd01` drawn inside fixed
steps (seeded by `start-match`), devices are read inside the step, the human stick is converted
through the sim-owned view (not the lagging render camera), hitstop and slow motion skip whole
steps, and cinematics run on the step clock. The camera choice cannot change a CPU match: CPU
pilots never read the view, and the view humans steer by is sim state for both cameras.

A match also starts from nothing of the one before: `spawn-pair` makes new entities (fighters,
vpads, brains; hazards gone) and clears hitstop / slow motion (`time-reset`), and `start-match`
reseeds the sim stream and zeroes `*match-tick*`, the timer and the slow-motion clock
(`reset-slow-clock`). That last one was a real leak: a perfect Hoho's slow motion leaves a
fraction in `*slow-acc*` (0.13, 0.5, 0.75, 0.88 ...), which used to carry into the next match and
shift the steps of its first slow motion, so a gate pairing gave other times when other matches
ran before it (KK alone median 135.8 s, after YY and YK 140.8). Check: each pairing's gate alone
(2110 / 2111 / 2112) gives the same per-seed `duel -> RESULTS` lines as inside 2113, and a seed
run fresh gives the same combat log as after a gate.

Reference (YK, seed 7, `duel-cvc-yk.json`):

```
duel -> RESULTS winner P2 konpaku 0-9 ticks 5474 secs 91.2
```

(The recovery back to medium and the guard cancel earlier, 2026-10-23: all three changed; before it `winner P2 konpaku 0-1 ticks
9873 secs 164.6`.) (The heavy whiff / block recovery, 2026-10-23: all three changed; before it `winner P2 konpaku 0-6 ticks 5809 secs 96.8`.) (The whiff / block recovery rework, 2026-10-23 (DUEL_DESIGN "Whiff and block recovery"): all three changed; before it `winner P2
konpaku 0-1 ticks 6622 secs 110.4`.) (A perfect Hoho stops refunding flash-step, 2026-10-19: yk and kk changed; before it `winner P2 konpaku 0-6 ticks 6173 secs
102.9`.) (The CPU learns Step -> J, 2026-10-02 (DUEL_STRINGS.md §19): all three changed; before it `winner P2 konpaku 0-1 ticks 7168
secs 119.5`.) (The Breaker opens a combo, 2026-10-02 (DUEL_STRINGS.md §17): all three changed; before it `winner P1 konpaku 1-0 ticks 8178
secs 136.3`.) (The perfect Hoho's lead 8 -> 12 frames, 2026-10-01: yk changed; before it `winner P1 konpaku 7-0 ticks 9328 secs 155.5`.)
(The base AI after the newer rules, 2026-09-30 (DUEL_LEARNING.md "v2"): the Soul Break finish and ORANGE off an L / O hit;
all three changed; YK was `winner P2 konpaku 0-1 ticks 10288 secs 171.5`.)

(East's refill then x0.25 with the guardless refill unchanged, the same day: yy's hash lines and yk changed again; x0.5
gave `winner P2 konpaku 0-1 ticks 10983 secs 183.1`.)

(Bankai East's guard gauge refilling at x0.5, the user 2026-09-30 (DUEL_DESIGN "Bankai East's guard refill"): yy's hash
lines and yk changed; YK was `winner P1 konpaku 3-0 ticks 10862 secs 181.0` from the guard lock on (the awakening heal kept it).)

(The guard lock, the user 2026-09-30 (DUEL_DESIGN "Guard lock"): all three changed; YK was `winner P1 konpaku 1-0
ticks 12426 secs 207.1` from BLUE's Reiatsu bar through the Reishi regen 70/s.)

(The slower awakening gauge, ×0.7, the user 2026-09-30: YK changed again, it was `winner P2 konpaku 0-5 ticks 8247 secs
137.4` after the three burst modes (DUEL_DESIGN "Burst modes", the same day), which changed all three; before them YK was
`winner P2 konpaku 0-3 ticks 7662 secs 127.7`.)

(The J/K cut + closer grab merged with the hidden hit-stun tolerance and the KESSA clone cost, 2026-09-29: YK changed
again; YY and KK equal the J/K-cut branch's. On the J/K-cut branch alone YK was `winner P2 konpaku 0-6 ticks 7879 secs
131.3`; with the hit-stun tolerance alone, `winner P1 konpaku 5-0 ticks 6708 secs 111.8` (Yamamoto blown away twice).
Before both: `winner P2 konpaku 0-6 ticks 5516 secs 91.9`.)

(The J cut and the closer grab, 2026-09-29 (DUEL_STRINGS.md §13–§14): every pairing changed; YY `winner P1 konpaku 1-0
ticks 8342 secs 139.0`, KK `winner P2 konpaku 0-1 ticks 7967 secs 132.8`. Before it this line was `winner P2 konpaku 0-6
ticks 5516 secs 91.9`.)

(Kenpachi's more aggressive CPU in cups 2 / 3, AI only, 2026-09-29 (DUEL_NOZARASHI_V2.md, "The CPU after the faster
drain"): YK and KK changed (KK `winner P2 konpaku 0-6 ticks 5603 secs 93.4`), YY unchanged. Before it, after the 2× NOME
drain, this line was `winner P1 konpaku 2-0 ticks 9636 secs 160.6`.)

(The string follow-up chase and Kenpachi's Bankai entry at <= 4 Konpaku, 2026-09-28 (DUEL_STRINGS.md §11,
DUEL_KEN_BANKAI.md): every pairing's lines changed; YY `winner P1 konpaku 2-0 ticks 9248 secs 154.1` (the chase alone),
KK `winner P2 konpaku 0-4 ticks 8225 secs 137.1`; before them this line was `winner P2 konpaku 0-3 ticks 7123 secs 118.7`.
The Soul Break rule and Kenpachi's Bankai, 2026-09-28 (DUEL_KEN_BANKAI.md; the hash line gained `u<clock>` / `*` for a
form with the arm meter only): this line and all of YK's and KK's hash lines are unchanged (no Soul Break, no Bankai in
them); YY changed from t=4200 (a Soul Break's longer cinematic): `winner P2 konpaku 0-4 ticks 6948 secs 115.8`, before
`ticks 6876 secs 114.6`. The J / K strings, the O ender and KŌSEI, 2026-09-27 (DUEL_STRINGS.md): every pairing's lines changed; before them
`winner P1 konpaku 2-0 ticks 7688 secs 128.1`. The Bankai rework and the slower guard refill, 2026-09-27 (DUEL_YAMA_REWORK.md): every pairing's lines changed; before
it `winner P2 konpaku 0-4 ticks 9305 secs 155.1`. Guard v3, 2026-09-26: Reishi 1300, GUARD HOLD, Bankai's fed flame, West's garb guard and ranged armour, K3 and
`*bankai-taken*` 1.2 change every pairing; its follow-up the same day (Bankai drains ×1.3, East feeds 0.05, the blade /
line split) keeps this line and KK's, and changes YY and YK's hash lines; before it `winner P1 konpaku 7-0 ticks 7351 secs 122.5`, turbo and real
time alike. The Kenpachi batch, 2026-09-26: West's hold-U armour changed YY and YK (KK stayed identical), Nozarashi v2 changed YK
and KK (YY stayed identical once the hash line's new `n` field is set aside), the run facing the opponent changed none of
the three; before it `winner P2 konpaku 0-3 ticks 8594 secs 143.2`. User review 3 of the restyle lengthened the Kikon and awakening cinematics: the same match, every event later by the
cinematic frames added before it. With the ~1.45× slow-down alone it was `ticks 8384 secs 139.7`, before it `ticks 8054
secs 134.2`; before the Bankai stances, the Kikon dash-in and the slower guard refill it was `winner P1 konpaku 1-0
ticks 9438 secs 157.3`; before the gauges, the O rule and the O modules `winner P1 konpaku 2-0 ticks 9780 secs 163.0`;
before the Kikon rush `winner P2 konpaku 0-1 ticks 7298 secs 121.6`; before Bankai became
permanent, `winner P2 konpaku 0-4 ticks 5857 secs 97.6`; before Burst and the dash, `0-7 ticks
5302 secs 88.4`.)

To verify, run the script twice (or once without turbo: drop the 2102 step; real time takes
~90 s of sim) and compare every `duel` line:

```sh
node tools/run.mjs dist/duel --secs 40 --script tests/scripts/duel-cvc-yk.json > a.log
node tools/run.mjs dist/duel --secs 40 --script tests/scripts/duel-cvc-yk.json > b.log
diff <(grep '^duel' a.log) <(grep '^duel' b.log)          # empty
```

Any change to the rules, the AI, a kit or a tuning knob changes the reference; a change that
should not (a refactor, an engine move) must keep it and all thirteen `duel hash` lines identical.
`tests/style-cvc-ref.txt` holds all three pairings' result and hash lines (`python3
tests/style-gates.py cvc dist/duel` compares them).
The harvest was checked this way after each step.

## Pacing gate

`duel-gate.json` (20 seeds × pairing, NORMAL, turbo). **The match time leaves the cinematics out** since 2026-10-08 (the
user: 「毀魂技演出不計入對戰時長」, every cinematic: Kikons, awakenings, revivals, the intro; `MATCH-PLAY-TICKS`, the frames the
match timer ran, which a cinematic stops); every median and accepted exception quoted before that date includes them. No baseline was re-measured then (the
user: 「現在先不用重新計算，只要計入規則，未來測試記得排除就行」): gates from then on measure without them.
Target: every match ends by K.O. (before the 300 s timer), **median 125–210 s** per pairing (125–180 s until guard
v3: Reishi 1100 → 1300 is the user's decision 2026-09-26, because real human matches run much faster than CPU vs
CPU), win rates near even (YK within ±3 of 10 / 10). The gate runs ~15 min of turbo for six pairings: `--secs 1100`; with
fifteen pairings (2026-09-29: Ichigo's four, Senjumaru's five) run them in parallel instead: one run.mjs per pairing with
2125+k (k 0–14, `--secs 1500` each, at most 4 at once on a shared machine). Since 2026-09-29 the gate runs natively
instead: `python3 tools/simgate.py` gives the same rows (see "The native sim gate" below).

**Gate policy (the user, 2026-09-29: the gates were getting too long with five characters).** (1) **Only what changed:**
a change inside one character's files runs that character's five pairings and its awaken A/B; a change to shared rules
(combat, fighter, rules, ai, tuning, kit) runs all fifteen. (2) **Two stages:** first 10 seeds per pairing (debug
31100+10 before 2125+k); a pairing passes at once when all 10 are K.O. and its median sits inside 135–200 s (10 s clear of
the 125–210 window); otherwise it is rerun with the full 20 (31120, or no knob), which is the verdict. (3) **The seed
gates and the awaken A/B streams run on the host-native sim gate** (`tools/simgate.py`, below; built 2026-09-29, DEVLOG
§38); the browser keeps G2 (`style-gates.py cvc`, the bit-exact references), smoke, duelstill and the touch scripts.

**The looks gate (`style-gates.py looks BASE NEW`, for refactors that must not change a pixel).** 75 fixed stills of SOUL DUEL
from `run.mjs --fixed-dt` at 640x360 (390x844 for the portrait one), 10 scripts generated in Python (nothing committed):
`menus` (title, MODE / SETTINGS / CONTROLS, the select screen with the three fighters that play: P1's cycle wraps every 3, so the
old seven presses showed three images twice; 7 stills); four CPU-vs-CPU matches (debug 2000+seed: Kenpachi-Hisagi, Hisagi-Kenpachi,
Ichigo-Ichigo, Ichigo-Kenpachi, seeds 1 / 3 / 7 / 10; the intro, the first frame, then turbo jumps of 240 / 960 / 1920 / 3600 ticks
each followed by live frames, plus the pause menu; 29); the cinematics at their key frames (`cine-ken`: Nozarashi and Bankai, 5;
`cine-ko`: Soul Break and K.O. with RESULTS, 5; `cine-ichigo`: his awakening, 3); `fx-a` (12: the Lisp HUD's review states on a
running battle (2505, 2440+k), Kenpachi's sword smears and moves (2309, 2305, 2306, 2308, 2310) and KESSA's three clones (74007));
and the portrait touch layout `mobile` with its RESULTS (14). **Re-pinned 2026-11-13 (REFACTOR_2026-11 R7):** the cinematic sets of
Yamamoto, Rukia, Senjumaru and Lille, `fx-b`'s Rukia / Senjumaru looks, `fx-a`'s Yamamoto looks and the HUD forms 2430+k were
commands that no longer exist (the scripts rendered the title or an idle fight under their names; `cine-senju` and `cine-barro`
were one image under two names) and left; 109 before; a BASE built at 581df983 renders the same 75 stills byte for byte
as the build that carries the re-pin (the unchanged scenarios and the new ones alike), noise floor 0. (115 before Kenpachi's old
Kikon cinematic `ken-kikon` left with its two stills, 2026-11-05, DUEL_KEN_V3 §43; 110 before refactor round 3 added the portrait
meters and thumb rings; 105 before refactor round 2 added five, 2026-10-21.) They are
rendered from BASE twice (the noise floor) and NEW once, three at a time by default; per still the max abs channel diff
and the number of differing pixels, a diff image under `build/style/looks/diff/` for any that differ, and the `duel hash`
/ `RESULTS` lines of every scenario; PASS only when NEW is within the BASE-vs-BASE noise floor (0 px: all 109 were byte
identical between two BASE renders on 2026-10-09). Options: `--jobs N`, `--size WxH`, `--only TEXT` (scenario names),
`--once` (BASE only, to look at the stills). Cost: ~11.9 k rendered frames a dist (~0.085 s each under SwiftShader at
640x360), so ~17 min of process time per dist and a full three-render gate of ~50 min of process time (measured under a
machine load of 20-40 on four cores: ~56 min wall at `--jobs 4`); the 900 s default of `run.mjs --timeout` is raised to
7200 s for it. A still that is noisy between the two BASE runs is not dropped but compared against its own floor and
listed in the summary line.

**The native sim gate (`tools/simgate.py`).** The same Lisp as `./build.sh duel` (engine + duel MANIFESTs, nothing
forked, no `#+` guard in any game file), compiled by the 32-bit host ECL with `gcc -m32 -msse2 -mfpmath=sse
-ffp-contract=off` into `build/simgate/duel.fas` (~2 min, redone when a source is newer). The engine's C layer is
`tools/simgate/stubs.c`: the real random streams (`engine/c/rng.c`), everything else a headless leaf (no window, no GPU:
meshes get ids and frames draw nothing; no audio device, so no sound is synthesized; a desktop page with nothing saved;
virtual 1/60 s time). `tools/simgate/run.lisp` starts it as the page would and runs the real frame (`%FRAME`: flow,
gate, 120 turbo steps, camera, HUD; the scene is never drawn in turbo) with the gate's debug commands, one core per
process. Usage:

```
python3 tools/simgate.py                          # every pairing without a retired kit (KK IK II HK HI HH), seeds 1-20
python3 tools/simgate.py --pairs 2,7,9 --seeds 10 # the quick pass (31110) for KK IK II (indices into simgate.py PAIRS)
python3 tools/simgate.py --pairs 9 --seed0 100 --seeds 60 --cmd 39020   # one awaken A/B stream
python3 tools/simgate.py --cvc                    # self-check: G2's three matches vs tests/style-cvc-ref.txt
```

It prints every `duel gate row` (with its `duel band` / `cups` / `senju` lines) and the page's summary line per pairing,
plus `duel gate A B wins P1 n P2 m DRAW d blow b`. The per-match `duel band` / `cups` / `senju` / `ichigo` / `lille`
lines are the pacing log, counted only while `*pacing-log*` is on (`PACE` into the per-side plists `*pacing*`,
components.lisp; `BAND-ACC-STEP` / `CUP-ACC-STEP` in `HASH-LOG`): `START-CVC` sets it (and clears the counts) before
`START-MATCH`, so every gate and every 2000+s / 3000+s CPU-vs-CPU match counts while play builds no keys (refactor,
2026-10-09). A new pacing counter goes through `pace` (or under `*pacing-log*`). `--cmd N` (repeatable) queues any debug knob before the gate command;
`-j` sets the processes (default 16). One process plays a pairing's seeds back to back, as the page does; `--chunk N`
(seeds per process) is faster for one long stream and gives the same rows: Ichigo's, Senjumaru's and Lille's state is a
component on their fighter entity (`ics` / `sjs` / `lbs`, made on first use, so every match's fighters start fresh;
Senjumaru's per-side state carried over between matches until 2026-09-29, DEVLOG §38–§39; components since the
2026-10-09 refactor). The wasm build's libm is emscripten's musl, and glibc's `sinf` / `expf` / ... differ from it in the last bit
now and then (3 of 15 pairings drifted a few cm by t=7200, one row changed), so `simgate.py` builds the same musl math
sources from the emsdk (`build/simgate/muslm.so`) and preloads them (`LD_PRELOAD`: the Lisp's inline calls and libecl's
both land there); running `tools/simgate/run.lisp` by hand without it gives glibc's math.
**Validation (2026-09-29, 4a58f3e):** all 15 pairings × seeds 1–10 in the browser (31110, 2125+k) and natively: 150 / 150
rows identical, and every compared line (the 600-tick `duel hash` lines, RESULTS, rows, band / cups / senju lines,
the summaries): 2693 / 2693. At seeds 1–20 the ten pairings Ichigo's later changes do not touch reproduce the table
above (medians, ranges, wins, blow-aways) exactly; `--cvc` passes G2's three references. **Speed:** all 15 × 20 seeds
in 14 s wall at `-j 16` (the machine at load ~45 from other browser gates), 15 × 10 in 8 s; the browser took ~160 s
per 10-seed pairing (~6 cores each), about an hour for the 20-seed gate at 4 at once.

(2026-09-29, main after merging the J/K cut + closer grab, the hidden hit-stun tolerance, the KESSA clone cost, KESSA
×1.35 and Shikai taken ×0.7, on the native gate (tools/simgate.py, seeds 1–20): 300/300 K.O.; medians YY 152.4, YK 148.7,
KK 137.4, RY 143.1, RK 151.8, RR 191.4, IY 146.4, IK 148.0, IR 192.0, II 198.3, SY 151.6, SK 156.1, SR 190.5, SS 186.4,
SI 200.6 s. Awaken A/B ("never" wins of 60, streams 100 / 300 / 500): every cell ≥ 20 (Ichigo 26–41, Rukia 32–40,
Senjumaru 20–41). **Then the user cut Ichigo's damage (Shikai 1.6 → 1.3, KESSA 1.35 → 1.1) without a gate (「不用再做測試」)**,
so the Ichigo rows below are stale until the next gate.)

| Pairing | Median | Range | K.O. | Wins P1 / P2 | Blow-aways |
|---|---|---|---|---|---|
| Yamamoto vs Yamamoto | 134.7 s | 98.2–205.5 | 20/20 | 9 / 11 | 0 |
| Yamamoto vs Kenpachi | 128.2 s | 79.6–182.4 | 20/20 | Yamamoto 15 / Kenpachi 5 | 13 |
| Kenpachi vs Kenpachi | 131.8 s | 88.4–180.4 | 20/20 | 11 / 9 | 6 |
| Rukia vs Yamamoto | 134.6 s | 88.3–163.5 | 20/20 | Rukia 13 / Yamamoto 7 | 7 |
| Rukia vs Kenpachi | 136.5 s | 93.4–186.6 | 20/20 | Rukia 13 / Kenpachi 7 | 28 |
| Rukia vs Rukia | 169.1 s | 125.6–253.9 | 20/20 | 12 / 8 | 1 |
| Ichigo vs Yamamoto | 143.8 s | 98.8–226.9 | 20/20 | Ichigo 5 / Yamamoto 15 | 1 |
| Ichigo vs Kenpachi | 142.7 s | 107.4–183.9 | 20/20 | Ichigo 7 / Kenpachi 13 | 32 |
| Ichigo vs Rukia | 186.9 s | 143.2–252.2 | 20/20 | Ichigo 6 / Rukia 14 | 18 |
| Ichigo vs Ichigo | 201.8 s | 110.5–237.6 | 20/20 | 11 / 9 | 17 |
| Senjumaru vs Yamamoto | 140.2 s | 95.2–165.5 | 20/20 | Senjumaru 10 / Yamamoto 10 | 7 |
| Senjumaru vs Kenpachi | 133.0 s | 96.1–175.4 | 20/20 | Senjumaru 6 / Kenpachi 14 | 33 |
| Senjumaru vs Rukia | 164.1 s | 106.7–230.9 | 20/20 | Senjumaru 4 / Rukia 16 | 27 |
| Senjumaru vs Senjumaru | 195.3 s | 149.9–244.5 | 20/20 | 13 / 7 | 81 |
| Senjumaru vs Ichigo | 189.7 s | 124.3–233.0 | 20/20 | Senjumaru 14 / Ichigo 6 | 43 |

(2026-09-29, Ichigo's clones swinging in place and the hidden hit-stun tolerance (DUEL_DESIGN.md "Hidden hit-stun
tolerance", DEVLOG §37): seeds 1–20, one run per pairing with 2125+k, 300/300 K.O., every median inside 125–210 s;
**YK is back over the floor (121.1 → 128.2 s)**. YY replays row for row (no blow-away in it). Blow-aways: the match's
count in its gate row.)

The rows before it (DEVLOG §34's integrated gate; §35's Senjumaru batch then moved SY / SK / SR / SS / SI to 143.9 / 132.9 / 186.1 / 197.9 / 180.5 s):

| Pairing | Median | Range | K.O. | Wins P1 / P2 |
|---|---|---|---|---|
| Yamamoto vs Yamamoto | 152.4 s | 116.2–188.8 | 20/20 | 9 / 11 |
| Yamamoto vs Kenpachi | 139.2 s | 105.9–208.7 | 20/20 | Yamamoto 14 / Kenpachi 6 |
| Kenpachi vs Kenpachi | 137.4 s | 97.1–167.2 | 20/20 | 7 / 13 |
| Rukia vs Yamamoto | 144.8 s | 101.8–160.6 | 20/20 | Rukia 8 / Yamamoto 12 |
| Rukia vs Kenpachi | 141.6 s | 95.9–219.0 | 20/20 | Rukia 14 / Kenpachi 6 |
| Rukia vs Rukia | 182.2 s | 154.3–233.9 | 20/20 | 10 / 10 |
| Ichigo vs Yamamoto | 147.4 s | 106.3–182.7 | 20/20 | Ichigo 10 / Yamamoto 10 |
| Ichigo vs Kenpachi | 152.5 s | 105.7–208.5 | 20/20 | Ichigo 16 / Kenpachi 4 |
| Ichigo vs Rukia | 190.0 s | 147.6–242.6 | 20/20 | Ichigo 6 / Rukia 14 |
| Ichigo vs Ichigo | 201.2 s | 131.9–257.1 | 20/20 | 9 / 11 |
| Senjumaru vs Yamamoto | 151.0 s | 128.3–186.7 | 20/20 | Senjumaru 4 / Yamamoto 16 |
| Senjumaru vs Kenpachi | 155.8 s | 111.1–177.8 | 20/20 | Senjumaru 12 / Kenpachi 8 |
| Senjumaru vs Rukia | 199.7 s | 119.4–229.9 | 20/20 | Senjumaru 12 / Rukia 8 |
| Senjumaru vs Senjumaru | 192.3 s | 107.1–237.3 | 20/20 | 8 / 12 |
| Senjumaru vs Ichigo | 197.4 s | 110.0–263.4 | 20/20 | Senjumaru 13 / Ichigo 7 |

(2026-09-29, the J cut and the closer grab (DUEL_STRINGS.md §13–§14, DEVLOG §36): J 0.4–0.6× (Yamamoto and Kenpachi 0.4, Ichigo's
J1 / J2 0.5, his J3 / KESSA, Rukia and Senjumaru 0.6), K a little shorter, the Breaker at 0.95 / 0.7 m, the CPU tables for close J:
seeds 1–20, one run per pairing with 2125+k, 300/300 K.O., every median inside 125–210 s, YK too (the rows before it:
YY 134.7, YK 121.1 (accepted), KK 127.7, RY 133.7, RK 130.8, RR 170.1, IY 148.0, IK 147.1, IR 179.3, II 194.1, SY 136.8,
SK 132.9, SR 176.0, SS 190.5, SI 180.5 s).)

(2026-09-29, main after Kenpachi's CPU aggression, the awakening breaking his attack, Senjumaru's playtest batch and Ichigo v2 (DEVLOG §31–§34): seeds 1–20, one run per pairing, 300/300 K.O. **Yamamoto vs Kenpachi's median is 121.1 s, under the 125 s floor; the user accepted it (「劍八那邊就這樣給過即可」)**: Kenpachi's CPU was tuned to sit on the floor (DUEL_NOZARASHI_V2.md), and a cup-3 `:tempo` 0.7 trial fixed YK (126.4 s) but broke KK (117.8 s), so the tuned CPU stays.)

(2026-09-29, Ichigo v2 (DUEL_ICHIGO.md "v2: built", DEVLOG §33), on main 97f40c1: the five Ichigo rows above are v2's; the other ten replay main's rows exactly (the two shared hook points are inert). Its awaken A/B, "never" wins 21–42 of 60 on every stream.)

(2026-09-29, the Senjumaru merge and hook unification (DEVLOG §30): seeds 1–20, one run per pairing with 2125+k, 300/300
K.O. The ten pairings main already had replay **row for row** as main 202c33c's build (checked on both builds): the
Kenpachi rows carry the faster NOME drain (DUEL_DESIGN "Playtest decision"). Her SY / SR / SS rows equal her branch's;
SK moved 144.4 → 136.9 s (Senjumaru 11 → 9) with that drain. SI is new. Its awaken A/B (seeds 1–60 / 61–120 / 121–180,
39000+10a+b; always / never): P1 Senjumaru 22/37, 19/33, 19/30; P2 Ichigo 22/34, 31/32, 30/40: "never" wins ≥ 30 of 60
on every stream, the user's criterion. Earlier: Ichigo's A/B (streams 30000+o, o = 100 / 300 / 500) "never" wins 26–37;
Senjumaru's (her branch) SY 18/23, 22/25, 22/27; SK 22/33, 34/22, 29/28; SR 16/38, 25/38, 17/32; SS 21/34, 14/40, 16/39.)

(2026-09-28, the cold-gauge rework + one UDE pip per string + South without a cooldown (DUEL_RUKIA.md, "Measurements
(the cold gauge rework)"): KK 125.8 → 131.2 and YK 137.1 → 136.2 from the one-pip rule, YY unchanged; her awakening's A/B
over seeds 1–60 (39000+10a+b), P1 always / never: RY 30 / 28, RK 35 / 32, RR 26 / 27 wins of 60: a sidegrade. Before it,
Rukia's first build: RY 144.0, RK 152.1, RR 186.0; A/B always / never / the rule RY 25 / 28 / 23, RK 34 / 37 / 34, RR
28 / 27 / 28.)

(The string follow-up chase and Kenpachi's Bankai entry at ≤ 4 Konpaku, the user's decisions 2026-09-28
(DUEL_STRINGS.md §11, DUEL_KEN_BANKAI.md): the chase alone YY 134.7 / YK 128.6 (Yamamoto 12) / KK 136.1 s; with the
entry change the Bankai came 14 times in YK (the entrant won 7) and 19 in KK (won 6). No retune: all inside the window,
KK at its floor's edge. Before: YY 131.8 s (99.7–165.1) 9 / 11, YK 138.4 s (98.1–200.9) Yamamoto 8 / Kenpachi 12, KK
131.5 s (97.4–174.2) 7 / 13.)

(The Soul Break rule and Kenpachi's Bankai, the user's decisions 2026-09-27 / 28 (DUEL_KEN_BANKAI.md). After the Soul
Break rule alone: YY 131.8 s, YK 138.0 s (77.0–197.3) Yamamoto 9 / 11, KK 131.5 s. The Bankai entered 3 times in YK and
6 in KK (the CPU's finisher rule, `:own-konpaku` 5 → 4 at this gate: YK Kenpachi 13 → 12). The gamble A/B over seeds
1–60 (debug 30000+k seed offset, 31000+10a+b the entry mode per side): DUEL_KEN_BANKAI.md "Measurements". Before:
the strings' values below.)

(The J / K strings: YY 129.4 s (97.7–165.1) 9 / 11, YK 137.3 s (77.0–196.1) Yamamoto 10 / 10, KK 130.4 s (97.4–172.0) 7 / 13.)

(The J / K strings, the O ender and KŌSEI, the user's decisions 2026-09-27: K2 / K3 at 80 %, the CPU's string K 0.3,
O ender 0.15, SP cancel 0.3 (one roll), chosen by runtime sweeps (debug 24000–29000 before 2113; DUEL_STRINGS.md §10
has them). As designed the medians were YY 106.8 / YK 119.0 / KK 121.7 s. Before the strings: YY 128.6 s (88.2–160.2)
14 / 6, YK 129.9 s (96.3–153.2) Yamamoto 10 / 10, KK 169.2 s (111.9–196.9) 15 / 5.)

(The Bankai rework and the slower guard refill, the user's decisions 2026-09-27: `*pierce-max*` 0.45 and `*ward-mult*`
1.1 chosen by runtime sweeps (debug 20000+k / 21000+k before 2113; DUEL_DESIGN §7 has the sweep). The win counts come
from the per-match `duel -> RESULTS winner` lines, in gate order YY, YK, KK. Before it, guard v3 with its follow-up:
YY 165.3 s (123.3–231.9) 11 / 9, YK 155.1 s (107.2–205.0) Yamamoto 7 / 13, KK 169.2 s (111.9–196.9) 13 / 7.)

(Guard v3's follow-up, the user's decision 2026-09-26: every Bankai drain ×1.3, East's feed 0.05, the blade / line
melee-ranged split; a deliberate nerf, no knob retuned. Before it: YY 181.8 s (135.5–230.4), YK 157.8 (115.2–194.9),
KK identical; wins 10 / 10, 8 / 12. YK seeds 21–40: Yamamoto 7 / 13 (was 9 / 11), so 14 of 40 (was 17). Bankai's
gauge mean 77 % (YK) / 82 % (YY); burnouts 8 in 20 YK matches, 2 in YY; the human proxy still reaches cup 3 while
Yamamoto has ≥ 4 Konpaku in 20 / 20.)

(Guard v3, 2026-09-26 (DUEL_DESIGN §12): the rules alone at Reishi 1300 and `*bankai-taken*` 1.4 gave YY 153.2, YK
143.8 (Yamamoto 7 / 13), KK 169.2; East's taken 1.3 YY 171.5, YK 157.4 (7 / 13); 1.2 is the table. Seeds 21–40 (a
build with the gate's seeds moved) for the balance read: Yamamoto won 6 / 8 / 9 of 20 YK at taken 1.4 / 1.3 / 1.2,
so 13 / 15 / 17 of 40. Usage (the logged gate, 2114+p): Kenpachi's first cup 3 28.2 s (YK) / 28.7 s (KK) after the
awakening, stays mean 6.4 / 6.7 s (max 12.0 / 18.9), cash-outs 47 / 118; Bankai's gauge mean 85 % (YK) / 89 % (YY),
1 burnout in YK, 0 in YY; West 48 % of Bankai time, scorches 57 (YK) / 143 (YY); ranged hits armoured by West: 6
cash-outs in YK, ~7 heat cones in YY. The human proxy (Kenpachi on HARD, the rush at 0.9 in every cup, no stance)
reaches cup 3 while Yamamoto has ≥ 4 Konpaku in 20 / 20 matches, YK median 161.2 s.)

(Before guard v3 (the Kenpachi batch): YY 148.9 s (114.7–219.2), YK 140.3 s (97.8–180.6), KK 154.1 s (106.8–170.0),
wins 11 / 9, Yamamoto 7 / Kenpachi 13, 8 / 12. The Kenpachi batch, 2026-09-26, each item measured on its own (no knob retuned): before it YY 158.7 s (95.5–223.2), YK
152.1 (115.2–185.2), KK 159.7 (128.8–197.4), wins YY 9 / 11, YK 6 / 14, KK 10 / 10; + the run facing the opponent: YY
161.0 (95.5–223.2), YK 155.6 (115.8–185.2), KK 159.7 (unchanged); + West's hold-U armour (Nozarashi v2 off): YY 148.9,
YK 142.9 (107.8–188.4, wins 9 / 11), KK 159.7; + Nozarashi v2 without ignore-armor: the table. Usage (YK / KK, 20
matches each): cup-3 stays mean 5.6 / 6.2 s (max 10.8 / 19.8), cash-outs 32 / 75 (about half connect), drinks 1 / 20,
rifts 7 / 15, West's armoured hits 33 in YK (52 in YY); DUEL_NOZARASHI_V2.md "Built" has the table. The gate runs close to
300 s now: give it `--secs 330`.)

(User review 3 of the restyle (STYLE_STORM_DESIGN §14) lengthened the Kikon and awakening cinematics: slowed ~1.45×,
then their caption close-ups held +30 f. The same 60 matches, each longer by the added cinematic frames. With the
slow-down alone: YY 155.2 s (93.5–219.7), YK 149.6 (112.7–181.7), KK 157.2 (127.0–194.9); before it, exactly the
table below: YY 150.4 s (90.9–214.9), YK 145.5 (108.1–176.2), KK 152.4 (122.2–190.1).)

(The Bankai stances with burnout, the Kikon dash-in, the guard gauge refilling at 12/s after 60 f
(guardless 14/s), the CPUs' guard pressure; no pacing knob retuned. Usage over the 60 matches (per
match): L switches 214 (3.6; YY 6.4, YK 4.3), guard crushes 13 (0.22), burnouts 8 (0.13, all by a
blocked hit: CPUs keep a stance's own recoil / armour inside the gauge by the `:gg-low` / `:armor-gg`
keys), parries 44 (39 caught a hit, 0.65), South casts 40 (0.67), binds landed 18 (0.30), Bursts out of
a bind 5, KYOKUJITSUJIN 44 (0.73), blocked hits 1086 (18.1; 8.5 before the guard pressure), armoured hits
142, Kikon dash-ins 352 (5.9; 351 on a red victim: the CPUs' non-red O pokes are guarded at the first
strike, so a non-red dash-in is rare: 1, and it was blocked), Kikons 299, Bursts 248, Hohos 242. Before
the guard pressure the CPUs made 0 guard crushes and 0 burnouts in 60 matches.
Before (the guard and flash-step gauges, Reiatsu 3/s, the O rule with its follow-up, the four O modules with
the CPU's non-red O pokes; no knob retuned. With the gauges alone (the old rush): YY 181.9 s
(137.7–281.7), YK 135.8 (101.8–154.7), KK 141.9 (117.4–159.6); the O modules brought YY back inside.
Usage over the 60 matches: 353 Hohos, 215 Bursts, 199 perfect Hohos, 532 O presses, 333 Kikons, 1
follow-up, 0 guard crushes: CPUs block ~7 hits a match and guard less as their gauge runs low, so the
guard gauge rarely empties between CPUs (the keyboard script shows it does against a turtling human).
Before (the Kikon rush): YY 153.4 s (118.8–181.4), YK 136.9 (106.3–165.3), KK 140.6 (114.0–157.1).
9 Konpaku, Reishi 1100, red 0.30, CPU Burst chance NORMAL 0.6, Bankai permanent, the Kikon rush
with the CPU's `*ai-kikon-p*` 0.5; each pairing gives the same times alone. Before the Kikon rush
(the instant Kikon after a hit): YY 144.2 s (109.2–203.4), YK 138.1 (110.8–179.6), KK 140.8
(107.9–163.2). Before, with a 20 s Bankai and the slow-motion leak: YY 134.2, YK 120.1,
KK 135.8 s; before Burst and the dash: YY 129.7, YK 106.9, KK 134.8 s; with Burst at 0.4: 131.3 /
107.4 / 137.9.) Usage per match (combat log of the gate before Bankai became permanent, both fighters): Bursts YY 1.4, YK 1.2, KK 2.2; dashes (runs) YY 5.3 (2.3 in, 3.0 back),
YK 4.9 (Kenpachi dashes in 1.9 per match, Yamamoto 0.8 in + 1.5 back), KK 2.4; moves out of a run
YY 1.9, YK 0.5, KK 0.2 (mostly Yamamoto's Signature / Shiranui once back in his zone); Hohos 4.5 /
3.2 / 2.5; moves 70 / 71 / 89.

## Performance (headless SwiftShader, `duel-perf.json`, 60 s real-time CPU vs CPU)

| Measure | Value | Budget (design §14) |
|---|---|---|
| consed per frame | 2026-10-26, the native profiler (CPU vs CPU fight frames, landscape): 2.8–3.1 KB (was 9.5–11.6 KB before that day's render and sim consing cuts, DEVLOG §405; portrait one-hand 12.9–14.3 → 4.5–5.0 KB); earlier browser figures: 13.2 KB mean, 17.5 KB max (before the Bankai stances 14.1 / 17.5; behind camera, VS CPU: 14.0 / 15.9; guard v3, `duel-perf.json`: 12.5 / 15.3) | ≤ 60 KB mean, ≤ 150 KB worst |
| Lisp ms per frame | sim 0.29, queue 1.49, render 0.35 | — |
| draws | 45–46 | < 600 |
| live particles | 331 mean, 525 max | ≤ 1200 |
| `fx-dropped` | 0 | 0 |
| startup heap (`tools/run.mjs` fails over `--max-heap`, default 110, since 2026-10-26) | 87.3 MB (wasm memory 153.6 MB; 2026-10-26, after the constants' #n= labels went: it was 359.1 / 458.9 MB, docs/engine/ARCHITECTURE.md "Runtime model"; 103.1 earlier) | ≤ 110 MB |
| frame rate | ~70 fps on this machine's SwiftShader | — |

## Host tests (no build, no browser)

```sh
E=/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl
$E --norc --load tests/duel-rules-test.lisp      # duel-rules-test: 9887 checks, ALL PASS (2350 when ENDLESS landed)
$E --norc --load tests/duel-control-test.lisp    # duel-control-test: 71 checks, ALL PASS
$E --norc --load tests/input-test.lisp           # input-test: 31 checks, ALL PASS  (engine vpad)
$E --norc --load tests/cine-test.lisp            # cine-test: 18 checks, ALL PASS   (engine director)
```

* **duel-rules-test** is a runner (`tests/duel-rules-test.lisp`: the engine and duel loads over the engine's plain-CL
  `math`, `hitvol`, `input` with DEFCINE stubbed, then `tests/duel-rules/{core,yama,ken,rukia,senjumaru,art,systems,barro,sim,hisagi}.lisp`
  in that order into one image, then the one `N checks, ALL PASS` line; `core` holds `check` and the shared helpers; `art`
  loads `anim.lisp` and runs the FK reach test; `sim` loads `touch`, `components`, `combat`, `fighter`, `flow` over
  stand-in entities; `hisagi` adds `hazards`, `hisagi`, `hisagi-ai`; refactor round 3 cut it from one 4433-line file, no
  check changed). It holds: the triangle and clash matrix; block / whiff
  advantage, including a frame-by-frame replay of every move of every form against its table;
  damage and combo scaling; the contact rule; armour budgets; the J / K strings (DUEL_STRINGS: every form's six routes
  walked from J1 / K1, the §2.1 budget on every reachable link: J1 / K1 frames, J beats K, K2 / K3 at S_eff 14, every
  link pair a combo on hit, the block gaps (K ≥ 11 f, J ≤ his own J1), J3 −4 / K3 −20 and its punish, the enders,
  whiff R + 8 / R + 12, the copies equal their originals, the O ender always combos off link 3; route resolution through
  `string-latch`: JKJ / KJK end at link 2, the last allowed press wins, an eaten press overwrites nothing, link 3 latches
  nothing; the string gate at every frame (link 1 by its own contact, a follow-up link carried at block timing) and the
  follow-up chase (`string-chase-speed`); KŌSEI's `kosei-mult` / `kosei-gain`); the Kikon rush (its phases with each
  module's aura / dash, reaches and press → hit times, cooldowns, `kikon-outcome`: guarded → nothing,
  held → the dash-in whose hit is the Kikon, released → a plain hit; the dash-in's window for every
  module (a non-red victim free `*kikon-follow-gap*` frames first, a red one reeling through it), its
  guard (blocked not red, unguardable red), its speed; every form's rush punishable on block), Konpaku
  counts, Soul Break, time-up; the guard gauge (guard values, drain, crush advantage, the 5.5/s after
  60 f refill, guardless 6.5/s, GUARD HOLD: `gg-regen` guarding, `gg-idle-next` frozen not restarted; East's pierce
  `pierce-rate` and its hit / through-guard arithmetic, the ward never refilled) and
  the flash-step gauge (costs, regen, refund); Reiatsu 3/s; burns; Burst eligibility and the CPU's Burst rule; the run (stop, carry, brake, kit speeds);
  combo limits; the perfect-Hoho window; facing, movement and arena; AI helpers; hit
  volumes; kit sanity (every form's commands, costs and derived Nozarashi numbers); the Bankai stances
  (DUEL_YAMA_REWORK: the forms' numbers, U's `:guard-to`, West's `:drop-to` / `:keep` via `kit-drop`, the ward in
  `resolve-contact` (360°, a Breaker / guard-crush breaks it, unguardables through, a hazard in the parry window
  blocked), KYOKKŌ and SHŌNETSU JIGOKU, East's combos, the ender-gap rule, Kenpachi's strings against the ward,
  KYOKUJITSUJIN's blade / cone against a guard, the parry window and counter, South's bind: cooldown,
  follow-up window, unguardable, opener only, Burst-able, the Step / Hoho escape windows, `cast-point`); which windows
  are `:ranged` (a parry can't catch them); Reishi 1300; the run clip sets; Nozarashi v2 (DUEL_NOZARASHI_V2
  §2.13 1–11: `nome-gain`, `meter-drain`, `ladder-rung`, `drink-split` / `drink-adv`, `cut-value` (RYOTE's K K K: 69), the Kikon count and
  its cap, the register-kit parent-move rule, the three cups' tables and links, the rift's +8, the cash-out, the looks
  and the AI keys); the Soul Break rule (the attacker's count + 1, cap 5 against a Kikon's 4, `kit-kikon-cine` of every
  form); Kenpachi's Bankai and 片腕 (DUEL_KEN_BANKAI.md: `bankai-allowed-p`, only cup 3 has `:bankai-form`, `pip-spend`,
  `pip-step` (the crack at 300 f, locked frames don't count, 4 cracks = 1200 f), `burst-due-p`, `:rend` in
  `resolve-contact`, the bite (unguardable, a grab, +9), the pip commands, the Kikon counts 4 / 3 and their Soul Breaks 5 /
  4, no NOME / ladder / cut in the Bankai, guard 28 / 28 / 36, TATE-GOTO's guard crush, SP2's punch, KKK 444, 片腕's reaches
  and every form's Breaker / Kikon strike beyond its trigger, the looks, the AI keys; both forms walk the strings'
  budget; the one pip per string, `string-pip-due-p`, and the burst waiting through the last pip's chain,
  `move-follows-p`); Rukia (DUEL_RUKIA.md: `frost-next` / `frost-speed`; the cold gauge: `temp-next`, `temp-band`
  (hysteresis by bars, several steps at once), `temp-cool-frames`, the pacing (2.2 s to zero, zero's bar 20 s), the
  field `field-velocity` / `field-step` / `field-k`; the bands' `:cold` (only L at −18), `:warm`, `:field`,
  `:crush-hook`; colder never weaker (damage, frost, J / K / L / SP / O reach and damage rise band by band), zero's
  follow-ups within reach without the chase, every HAKUREN's lane under a side Step, `optic-p`, the walks, the Kikon counts
  and cinematics, the routes (JJJ 110, KKK 208), the looks and U tags, the AI keys).
* **duel-control-test**: the buffer window, consume and holds; command priority and modifier
  combos (a refused command doesn't hide the next); stick and opponent-relative directions; a
  device read through the binding tables equals direct injection; SETTINGS (the defaults are the old behaviour, the page
  value's decoding with its fallbacks, ONE-HAND AUTO / ON / OFF over coarse × portrait: the merged VS CPU's rule) and the
  PRACTICE dummy's guard (GUARD ALL, GUARD AFTER HIT's hold and count-down, STAND / CPU never; GUARD ALL's cancelling press for a
  `:core` dummy, `dummy-cancel-press`: the answer per class, the lead's edges, never the same class, DUEL_CORE §9), the HP / KONPAKU rows
  (`practice-reishi`, 25 % red, `konpaku-step` wrapping) and the HUD's Konpaku at stake (`konpaku-at-stake`: 2 / 3 / 4,
  capped at what is left).
* **input-test** and **cine-test** check the engine modules on their own (buffering, modifier,
  flush / clear, command tables, bindings; AT / DURING, length, hold, skip / abort, hooks, shots).

RAVEN's host tests (`ecs-test`, `rules-test`, `test-math`) are listed in README.md.

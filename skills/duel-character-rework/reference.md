# Reworking an existing fighter: evidence

Evidence:
- **The old Lille's post-playtest rounds:** `docs/duel/DUEL_LILLE.md` §22–§23 (decisions 16–56), DEVLOG §92–§135,
  `docs/research/lille-retrospective/digest.md`. These were on the old fight system.
- **Kenpachi's base rework** (§8).
- **Ichigo's rebuild on the core system:** §10; DUEL_CORE §6, DEVLOG §416–§445.

The old system's ASSIST-specific cases are at `git show e55304e:skills/duel-character-rework/reference.md`. "G" = generalizable,
"P" = project-specific.

## 1. How the rounds ran (P → G)
- Feedback came as short zh-TW lines after a playtest of the private Artifact, often several in a burst, and often
  「請先跟我討論…後再修改」 (16–20, 44, 53). Each round: a cause, then options, then the docs, the build, the gates and a
  new Artifact version.
- Lettered options the user combined: 41 (A pierce mark / B 0-damage flinch / C snap / D slowing zone → C + a slow
  motion); 44 (A/B/C/D → A, N = 10 f); 50 (four directions, all chosen); 56 (a style plus four extras, all chosen).
- Parameters asked separately with defaults: 56b's slow-motion strength (1/5 → 1/3 → 1/2) and opening length (40 f).
- The user wrote the cinematic storyboard in prose over several messages (「我繼續講分鏡」). The lead held the build
  (SendMessage to the worker: "hold the camera"), appended each message to the doc, and sent the agreed beat sheet.
- A shot-by-shot text breakdown (10 shots with frames, angle, distance, height, lens) let the user name exactly what was
  wrong: 「第三幕太快」「第一幕也拉長」 (56b).

## 2. Presentation-only proofs (G)
- Every art round (§22.5, §23.5, §23.9, §23.19, §23.31, §23.37) saved a baseline (`simgate --seeds 10 --summary`,
  `--cvc`) before the change and compared byte for byte afterwards.
- When a cinematic's length changed match seconds (before the 2026-10-08 rule), the worker rebuilt with the old `:len`
  to prove the outcomes identical; wins and K.O.s were compared instead of medians.
- CINE-PLACE moves the actor for the shot and restores him in CINE-END; Lille's six pairings stayed byte-identical,
  which proves the restore.
- `:clip-map` (kit key, `KIT-MOVE-CLIP`): Jilliel KIN plays `:lb-w-sanren` for the shared move `:lb-sanren`, and the
  move name the AI and tests read is unchanged.

## 3. Sim-change rounds (P)
- TENSHIN chain (decisions 25 → 54): each distance change ran the six pairings at 20 seeds; LR / LI crossing 210 s
  meant 60-seed reruns and reports; 3 exceptions accepted in the user's words; 55 「不用調整，玩起來夠強了」.
- The fixed-speed rule (53): `lb-switch-dash-f` = ⌈60d/30⌉ capped at 14; distances in Step lengths; host tests pin it.

## 4. Regressions found after rule changes (G)
- 43: K → L, a latched L in a K string became a chained follow-up and the string chase pulled him forward (a 7 m back
  dash measured 0.88 m in the browser). Fix: the switch tick zeroes walk/chase every frame.
- 52: a shorter dash changed nothing because the link chased (≤ 40 m/s): measure the actual travel.
- 24: the onehand rule "an up-flick during a move is a Hoho" fired inside a stance move: a generic `:step-branch` flag. (The same
  class of bug: §10's phone checks.)

## 5. Merge lessons (G)
- Two art batches both used `*LB-WF*` [64]–[66]; the owl's moved to [68]–[70] at merge (§23.37 "Merged").
- A worker "fixed" a decided colour; diff against the decision list.
- After the merge the lead re-ran the host tests, `pkgcheck`, the build, `--cvc`, the seed gate, and the browser
  scripts with the consing probe, then republished the Artifact.

## 6. Cinematic rework checklist (P → G)
- Placement: CINE-PLACE at a fixed gap (6 m for Jilliel's Kikon).
- Aspect ratios: landscape draws a 9 % letterbox (hud.lisp), so keep the subject's head ≤ 0.35 of the half-height below
  centre on landscape. Portrait widens the lens and backs off (%PORTRAIT-DOLLY); keep its framing when the user likes it.
- Time: CINE-SLOW for hits (actors and effects), with the script's frames running on; the effect-time tables must use
  the same clock.
- Scale: CINE-SCALE multiplies the rig; scale every metre-authored size in the draw hook by hand.
- Stills: a frame hold (the old Lille's 79200 + f, gone; today's Lille 82200 + f), contact sheets per beat, both aspects.
- Gate time excludes cinematics since 2026-10-08 (DEVLOG §134); the 125–210 s window predates that.

## 7. Model edits by stills (decision 57, the face) (G)
- The user iterated the head in ten short requests, stills only (「做完後先不要跑對局測試，直接拍影像給我看」): build, debug
  the old Lille's 79198 + 79199 (front, side; gone, today's Lille: 82100 + k / its front view k + 20), a cropped sheet; WIP commits on the dev branch; the gates and docs once the look settled.
- For a position or size, shoot a candidate sheet (0 / −2 / −4 / −6 cm side by side, front and side): the user picked
  a value between two (−3 cm) in one reply.
- Restate shape words against the profile: 「頂部往下降」 meant keep the foot, lower the top. A part placed inside another
  shows only what sticks out (a trapezoid nose whose block sat inside the skull read as a triangle): check the side still.
- A squashed (ellipsoid) head needs its features squashed with it: `:squash` scales the placement too.

## 8. Strike clips by measurement (Kenpachi's base round, DUEL_KEN_REWORK §5) (G)
(The whole style → research → plan → measure process: `skills/duel-motion-style/`.)
- Research first: canon looks per form and a motion bar per form (6–15 archetypes, no two sharing an arc plane and a
  hand set), then map them onto the move slots and get a yes.
- Measure before rendering: a host script that loads the art files and prints the weapon tip (or a striker joint) per
  frame in the fighter's frame (right, up, forward) and the FK test's radial reach per link. It found the old K1 / K2
  drawn 1.6 m short of their volumes, and it found the wrist values (a grid over hand flex and twist) that put a
  dragged tip on the floor behind him: guessing them from 4-frame strips cost two builds.
- One clip is often played by several forms (KATATE, the Bankai and KATAUDE borrow the base clips at other reaches and
  blades): read the reach report for every form that plays it, not only the one being reworked.
- The default 4-frame strip (0, S, S+A, end) hides the anticipation; review 8 frames from the side and from the front.

## 9. Retire, remove, rename a character (the old Lille, DEVLOG §208 / §216, DUEL_LILLE_V3 §26) (G)
- **Retire** (out of play, code kept): `*retired*` / `playable-roster` (kit.lisp), simgate's `RETIRED`; the select screen and
  CPU-vs-CPU picks skip him. The core system retired four this way (Yamamoto, Rukia, Senjumaru, Lille; DUEL_CORE §1).
- **Remove** (code gone): keep his **roster index reserved** (append the keyword to `*roster*` before the next defkit):
  saved learning tables, endless records and gate pairings are keyed by index. Keep the survivor's internal names (kit,
  prefix, debug range); rename only player-facing text (`:name`, brush names, the manual).
- **Move what the survivor still uses** first: shared cinematics, structs, knobs (here 4 cines, the hazard look struct,
  the misuji knobs). `pkgcheck` finds undefined functions, not data symbols (cine names in plists): grep them.
- Sweep every list that names him: MANIFEST, host-test load lists and per-form lists, browser scripts
  (`tests/scripts/`), `tools/aieval.py`, `tests/style-gates.py` (looks seeds / frames), debug habits, docs (AGENTS roster
  line, debug ranges freed in DUEL_GAMEPLAY, the docs map).
- **Prove it sim-neutral**: his old opponents' pairings identical at 20 seeds, G2 identical, the looks gate on a fresh BASE
  (a `--keep-base` render from an earlier session is stale): 96 / 104 identical + 8 only the name's text. A roster change
  moves the looks gate's CPU-vs-CPU draws: re-pin its seeds in the same pass (they had failed silently for a day).
- Host checks drop with his sections (8451 → 6976); record the new count where it is quoted.

## 10. Ichigo's rebuild on the core system (2026-10-27 → 10-28, DEVLOG §416–§445) (P → G)
- **The shape of the rounds.** About 30 sections in 2 days. Feedback often came as two or three requests in one message, or as new
  messages mid-turn. Each request got its own doc §, its own check and its own line in the reply.
- **Diagnosis by frames.** Every fix started from a frame count:
  - the clone's hit on f18 against the next segment's start on f14 (§443);
  - AS3's hit on f8 against a tap's length (§441);
  - the hitstop's 8 frames as the window where an undo is exact (§440).
- **Run the regression on the old build.** The same script on the build before the fix shows the bug and the fix side by side (§443:
  NS-B no hit and the SA whiffing before; 18, 18, SA 50 after).
- **Input checks need the negative case:**
  - §436's phone check passed while holding the attack zone, which is exactly the bug §442 found.
  - Now every input check runs: held / tapped, the SP zone / the attack zone, a slow / quick press.
  - Mobile runs need `--mobile --size 390x844`; without the size, touches miss the pad.
- **A rule that reads input timing moves the pace through the CPU.**
  - §440's 12-frame confirm alone made IK 201.1 s and HI 204.1 s.
  - Holding the CPU's press through the confirm restored the numbers exactly (IK 191.9 s).
- **Explain conflicts before a sweeping input change.** For 「點擊觸發」 everywhere, the reply was a table of the gestures it breaks
  (drag, flick Step, Hoho, Burst) and three options. The user chose the narrow one (press-fire only inside a move, §444).
- **Scope of the gates.** A change in one character's files, or a shared hook only he uses, gates his pairings only (the user,
  2026-10-27: 「現在只有改一護，只測他的對戰結果就好」, DEVLOG §424). A shared rule gates all six.
- **Exceptions:**
  - The Ichigo mirror 221.4 s with 2 time-outs of 60 after the NS3 fix was accepted (「列為例外」, §445).
  - Ichigo's win rates stay the user's call.

## 11. Hisagi's Bankai redesign (2026-10-29, DUEL_HISAGI §28, DEVLOG §470–§501) (P → G)
- **The shape.** One day, about 25 sections. The order was batch 1 the sim (§28.5), then the user's rule rounds on the reach table
  (§28.6–§28.10, §28.13, §28.20, §28.22). Batch 2 the clips and stances (2a ranged, 2b bind, in parallel worktrees). Batch 3 the four
  Kikon cinematics, storyboards first (「先畫分鏡給我」 → 「分鏡可以」, 3a / 3b). Batch 4 the strings' looks (4a 散, 4b 聚) and the 聚 rhythm
  (4c, 4d). Each round's plan table got a 「可以」 before its clips.
- **The table as the decision surface.** 「請列出遠距的攻擊範圍、鏈尖判定與狀態為「聚」還是「散」」 → a table per move (S, reach, tip
  band, mode, §28.6). The answers came as five numbered rules on that table (§28.7): bands per mode, the tip by class, the SA by the
  state. Then 「請列出原版遠距的攻擊範圍」 for the before view. Re-print the table after each round (§28.8).
- **Without balance gates** (since §468), each sim round ran:
  - host tests;
  - `--cvc`;
  - the scripted smoke `tests/scripts/duel-hisagi-bankai.json`, with a scene per changed move (A4–A9, E, ...) and the numbers quoted
    from its log (「WA hits 30 and pushes (3.94 m at ŌGI's start)」).
  Each art round proved the same smoke's 154–197 hash / log lines identical to the parent's. Moving a scene's end by a few frames
  shifts later hash lines by carry-over: say so, and re-baseline.
- **Diagnosis by a probe in the script.** Both "it doesn't reach" (§28.13) and "it doesn't combo" (§28.22) were found by a distance /
  state print every 2–3 f in one scene, which gave the cause in frames:
  - the push to 2.30 m during the startup;
  - IDLE at f167 against the hit at f170.
  The fixes were the smallest knob that kept the user's intent: SAN's reach 1.5 → 3.0, the user's pick of three; AS2a's `:stun 36`, so
  聚 stays slow.
- **A baseline goes stale through a peer.** A parallel session's flash-step gauge change (0–300, AS1 `:steal-fs` 40 → 120) moved the
  sim. Every smoke baseline before it is void: regenerate from the new `main` before the next presentation proof.
- **Parallel art batches collide in shared tables**, even inside one character's files:
  - `*hs-lashes*` / strip-slot rows;
  - the cinematic debug scene index (c 7 / 8 went to the bind, so KUSARI-AME became c 9);
  - DUEL_GAMEPLAY's debug-range line.
  Merge by union, renumber the later batch, and apply a long doc line as the branch's delta rather than taking either side.
- **Things noticed and offered, not done:** the bundle's pop between links, the ranged chases drawn along his facing, J2's hand-chain
  choice. List them as open in the § and in the reply. The user picks them up or not.

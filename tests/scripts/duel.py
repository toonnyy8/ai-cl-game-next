# SOUL DUEL headless scripts (duel/lisp/debug.lisp lists the debug commands). Run:
#   python3 tests/scripts/duel.py            (writes tests/scripts/duel-*.json)
#   node tools/run.mjs dist/duel --secs 60  --script tests/scripts/duel-cvc-ik.json   seeded CPU vs CPU -> RESULTS (also -ii, -kk)
#   node tools/run.mjs dist/duel --secs 1100 --script tests/scripts/duel-gate.json    20 seeds x every pairing of the playable
#     roster (2113): "duel gate" lines (long; better one run per pairing with 2125+k, --secs 1500, at most 4 at once on a shared
#     machine; the 2026-10-29 rule: not run unless the user asks)
#   node tools/run.mjs dist/duel --secs 40 --fixed-dt 16.666667 --script tests/scripts/duel-keys.json   P1 keyboard: J J J, Step, Hoho
#   node tools/run.mjs dist/duel --secs 50  --script tests/scripts/duel-extras.json   dash, Hoho swing, Burst, camera toggle
#   node tools/run.mjs dist/duel --secs 40 --fixed-dt 16.666667 --script tests/scripts/duel-strings.json   the J strings
#     per form (shots tests/shots/duel-string-*.png)
#   node tools/run.mjs dist/duel --secs 75  --script tests/scripts/duel-perf.json     real-time CPU vs CPU: stats lines
#   node tools/run.mjs dist/duel --secs 140 --script tests/scripts/duel-shots.json    tests/shots/duel-*.png
#   node tools/run.mjs dist/duel --secs 62 --fixed-dt 16.666667 --script tests/scripts/duel-practice.json   SETTINGS +
#     PRACTICE by keyboard (--fixed-dt: on a loaded host real-time key timing drops string links)
# (R7, 2026-11-13: the scripts of the retired kits (rukia*, probe, kikon, gauges, stances) and of the frozen modes (endless*, rogue)
# left; every debug command they used is gone from debug.lisp.)
# Determinism: run a cvc script twice (or once with turbo and once without: drop the 2102 step) and
#   diff <(grep '^duel' run1.log) <(grep '^duel' run2.log)   -> empty.
# Determinism reference: the state-hash lines of the three cvc scripts are the G2 references (tests/style-cvc-ref.txt,
# `python3 tests/style-gates.py cvc dist/duel`); the old YK match's result lines left with Yamamoto (git history).
import json
T0 = 9.0          # startup (meshes + sound synthesis) is done by then
SHOTS = "tests/shots/duel-"

def write(name, ev):
    json.dump(ev, open(f"tests/scripts/duel-{name}.json", "w"), indent=0)
    print(f"duel-{name}.json: {len(ev)} steps, last at {max(e['at'] for e in ev):.1f} s")

def cmd(t, c): return {"at": round(t, 2), "eval": f"Module._debug_cmd({c})"}
def shot(t, n): return {"at": round(t, 2), "shot": f"{SHOTS}{n}.png"}
def key(t, k, down=True): return {"at": round(t, 2), "key": k, "down": down}
def tap(t, k, hold=0.08): return [key(t, k), key(t + hold, k, False)]

# seeded CPU vs CPU, turbo (120 steps / frame), cinematics play: reaches RESULTS in a few seconds
for pair, base in (("ii", 3000), ("ik", 4000), ("kk", 5000)):   # (II IK KK since the core system, 2026-10-27; YY YK before)
    write(f"cvc-{pair}", [cmd(T0, 2102), cmd(T0 + 0.1, base + 7)])
write("gate", [cmd(T0, 2113), cmd(T0 + 0.3, 2107)])

# P1 on the keyboard vs an idle CPU (2500: Ichigo vs Kenpachi). Log lines the live game still gives, in order:
# P1 move IC-J1 IC-J2 IC-NA3 (2393 puts him 2.2 m out: a string needs contact) | P1 step | P1 hoho. The K, L, I, U presses and the
# SP1 / SP2 with the old keys do nothing since the core system (R7, 2026-11-13: no log line, the script runs on).
ev = [cmd(T0, 2500)]
t = T0 + 1.2
ev += [key(t, "KeyW"), key(t + 1.8, "KeyW", False)]; t += 2.1               # walk in (VS CPU: the behind camera, W = at him)
ev.append(cmd(t - 0.2, 2393))                                               # 2.2 m apart: the string makes contact
for k in ("KeyJ", "KeyJ", "KeyJ"): ev += tap(t, k); t += 0.3              # J J J (each latched during the link before)
t += 1.0
ev += tap(t, "KeyK"); ev += tap(t + 0.35, "KeyK"); t += 1.8                 # K K
ev += tap(t, "KeyL"); t += 2.0                                              # Signature (the fire wave)
ev += [key(t, "KeyI"), key(t + 0.6, "KeyI", False)]; t += 1.8               # Breaker (held)
ev += [key(t, "KeyU"), key(t + 0.8, "KeyU", False)]; t += 1.2               # Guard
ev += [key(t, "KeyA"), key(t + 0.5, "KeyA", False)] + tap(t + 0.1, "Space"); t += 1.2   # Step
ev += [cmd(t, 2108), key(t + 0.1, "ShiftLeft"), key(t + 0.15, "KeyK"), key(t + 0.9, "KeyK", False),
       key(t + 1.0, "ShiftLeft", False)]; t += 2.5                         # SP1 Shiranui (charged, 1 bar)
ev += [key(t, "ShiftLeft"), key(t + 0.05, "Space"), key(t + 0.15, "Space", False), key(t + 0.2, "ShiftLeft", False)]; t += 1.5   # Hoho
ev += [key(t, "ShiftLeft"), key(t + 0.05, "KeyL"), key(t + 0.15, "KeyL", False), key(t + 0.2, "ShiftLeft", False)]; t += 2.0   # SP2 Taimatsu
ev += [cmd(t, 2107)]
write("keys", ev)

# Burst, dash and the camera by keyboard (P1 Ichigo vs an idle Kenpachi, VS CPU = the behind camera).
# Expected log lines, in order: P1 step, P1 dash (the run), P1 step, P1 dash, P1 run -> IC-J1, carry ...,
# P1 hoho, KE-Z-J1..J5 -> P1 HIT (the mash test 2320), P1 BURST BLUE, then "duel camera CAMERA  SIDE" (pause menu).
# Shots: extras-behind (neutral), extras-dash (running), extras-hoho-a / -b (the swing after a Hoho),
# extras-burst-a / -b (2321, the shockwave), extras-pause (the menu with CAMERA), extras-side.
t = T0
ev = [cmd(t, 2500), shot(t + 1.5, "extras-behind")]
t += 2.5
ev += [key(t, "KeyW"), key(t + 0.05, "Space"), shot(t + 1.0, "extras-dash"), key(t + 1.6, "Space", False), key(t + 1.6, "KeyW", False)]
t += 3.0
ev += [cmd(t, 2500)]; t += 1.0                                              # again: J out of the run
ev += [key(t, "KeyW"), key(t + 0.05, "Space")] + tap(t + 0.8, "KeyJ") + [key(t + 1.0, "Space", False), key(t + 1.0, "KeyW", False)]
t += 2.5
ev += [cmd(t, 2500), cmd(t + 0.5, 2108)]; t += 1.0                          # Hoho behind P2: the camera swings round
ev += [key(t, "ShiftLeft"), key(t + 0.05, "Space"), key(t + 0.3, "Space", False), key(t + 0.35, "ShiftLeft", False),
       shot(t + 0.4, "extras-hoho-a"), shot(t + 1.8, "extras-hoho-b")]
t += 3.0
ev += [cmd(t, 2320), key(t + 0.1, "ShiftLeft")]                             # Burst out of Kenpachi's string
for i in range(16): ev += tap(t + 0.3 + 0.12 * i, "KeyJ", 0.05)
ev += [key(t + 2.4, "ShiftLeft", False)]
t += 3.5
ev += [cmd(t, 2321), shot(t + 0.05, "extras-burst-a"), shot(t + 0.5, "extras-burst-b")]
t += 2.0
ev += tap(t, "Escape") + [shot(t + 0.6, "extras-pause")]                    # pause -> CAMERA (5th item) -> SIDE
for i in range(4): ev += tap(t + 1.2 + 0.3 * i, "ArrowDown")
ev += tap(t + 2.6, "Enter") + tap(t + 3.1, "Escape") + [shot(t + 4.0, "extras-side"), cmd(t + 4.5, 2107)]
write("extras", ev)

# (Nozarashi v2's NOME ladder script, duel-nome.json, went with the cups, 2026-11-03: DUEL_KEN_V3 §8)

# The J strings by keyboard (debug 2394+k: human P1 2.2 m from an idle Kenpachi, k 0 Ichigo's Shikai, 1 KESSA, 2 Kenpachi,
# 3 his Shikai). Log lines the live game still gives: P1 move IC-J1 IC-J2 IC-NA3 (k 0); P1 form KESSA (k 1); KE-Z-J1..J3 (k 2);
# P1 form NOZARASHI, KE-S-J1..J3 (k 3). The K and O presses of the old strings (K1-K3, the O ender, J K J) do nothing since the core
# system (R7, 2026-11-13). Shots: string-sodebi, string-o-ender, string-rakujitsu, string-kick, string-tsuki (names kept).
t = T0
ev = []
def string(k, keys, shots=()):
    """Form K (2394+k), then KEYS ((key, s after the first) ...) tapped, SHOTS ((s, name) ...)."""
    global t
    ev.append(cmd(t, 2394 + k)); t0 = t + 1.0
    for key_, w in keys: ev.extend(tap(t0 + w, key_, 0.05))
    for w, n in shots: ev.append(shot(t0 + w, n))
    t = t0 + 3.0
string(0, (("KeyJ", 0), ("KeyJ", 0.15), ("KeyJ", 0.4), ("KeyO", 0.75)), ((0.68, "string-sodebi"), (1.08, "string-o-ender")))
string(1, (("KeyK", 0), ("KeyK", 0.2), ("KeyK", 0.6)), ((1.15, "string-rakujitsu"),))
string(2, (("KeyJ", 0), ("KeyK", 0.1), ("KeyK", 0.35), ("KeyO", 1.0)))
string(3, (("KeyJ", 0), ("KeyJ", 0.15), ("KeyJ", 0.4)))
string(3, (("KeyK", 0), ("KeyK", 0.25), ("KeyJ", 0.8)), ((0.76, "string-tsuki"),))
string(2, (("KeyJ", 0), ("KeyJ", 0.12), ("KeyJ", 0.35)), ((0.61, "string-kick"),))
string(2, (("KeyJ", 0), ("KeyK", 0.12), ("KeyJ", 0.4)))
ev.append(cmd(t, 2107))
write("strings", ev)

# the menus by keyboard: TITLE -> MODE (VS PLAYER) -> SELECT (P1 Kenpachi, P2 confirms with KP1) -> INTRO
# -> skip (Esc) -> BATTLE -> pause (Esc) -> RESUME -> pause -> CHARACTER SELECT -> back ... -> TITLE;
# then VS CPU HARD. Expected "duel -> STATE" lines in that order.
t = T0
ev = tap(t, "Enter") + tap(t + 0.4, "ArrowDown") + tap(t + 0.55, "ArrowDown") + tap(t + 1.0, "Enter")   # VS PLAYER (row 2 since the HTML menus hid ENDLESS / DANGAI, 2026-10-28)
ev += tap(t + 1.6, "KeyD") + tap(t + 2.0, "Enter") + tap(t + 2.4, "Numpad1")      # P1 Kenpachi, P2 confirms
ev += tap(t + 4.0, "Escape") + tap(t + 6.0, "Escape") + tap(t + 6.6, "Enter")     # skip intro, pause, resume
ev += tap(t + 8.0, "Escape") + tap(t + 8.4, "ArrowDown") + tap(t + 8.8, "ArrowDown") + tap(t + 9.2, "Enter")  # -> select
ev += tap(t + 10.0, "Escape") + tap(t + 10.5, "Escape")                            # select -> mode -> title
ev += tap(t + 11.5, "Enter") + tap(t + 12.0, "Enter") + tap(t + 12.6, "Enter") + tap(t + 13.0, "Enter")
ev += tap(t + 13.4, "KeyD") + tap(t + 14.2, "Enter")                             # VS CPU, HARD
ev += [shot(t + 21, "flow-vs-cpu-hard")]
write("flow", ev)

# SETTINGS and PRACTICE by keyboard (the MODE menu since the HTML menus, 2026-10-28: VS CPU / PRACTICE / VS PLAYER / CPU VS CPU /
# SETTINGS / CONTROLS / MANUAL; SETTINGS: ONE-HAND / HAND / SENSITIVITY / CAMERA / LEARNING CPU / PERFECT HINT / VOLUME / RESET LEARNING / BACK). Expected, in order: duel -> SETTINGS, duel setting HAND LEFT, ... HAND RIGHT, duel setting CAMERA SIDE,
# duel camera CAMERA  SIDE (the pause menu flips it back: BEHIND), duel -> MODE, duel -> SELECT, the match seed line with
# PRACTICE, duel -> BATTLE; J J J on the standing dummy: YA-J1 / J2 / J3 -> P2 HIT (the dump after it: P2 r1300, the
# HP refilled); duel practice DUMMY  GUARD ALL, then J1 / J2 -> P2 BLOCKED (a :core dummy, Ichigo vs Kenpachi since 2026-11-12: J1 / J2
# x P2: CANCEL, DUEL_CORE §9); DUMMY  GUARD AFTER HIT: J1 -> HIT, then a J1
# 0.5 s later -> BLOCKED; GAUGES  INFINITE (the dump: P1 a300 f100 w100); the HP / KONPAKU rows (P1 r650 k4, P2 r325
# k8, again after a hit and after duel practice reset). No RESULTS line.
# Shots: practice-mode, practice-settings, practice-combo (the counter stays up), practice-pause.
t = T0                                   # (a shot stalls the page ~0.5 s: no key within 1 s after one)
ev = tap(t, "Enter") + [shot(t + 0.8, "practice-mode")]                           # TITLE -> MODE
t += 2.0
for i in range(4): ev += tap(t + 0.18 * i, "ArrowDown")                            # SETTINGS (row 4)
ev += tap(t + 1.2, "Enter") + [shot(t + 1.8, "practice-settings")]
t += 3.0
ev += tap(t, "ArrowDown") + tap(t + 0.3, "ArrowRight") + tap(t + 0.6, "ArrowLeft")   # HAND LEFT, back to RIGHT
for i in range(2): ev += tap(t + 0.9 + 0.25 * i, "ArrowDown")                      # CAMERA
ev += tap(t + 1.8, "ArrowRight") + tap(t + 2.2, "Escape")                          # SIDE; back to MODE (cursor on SETTINGS)
for i in range(3): ev += tap(t + 2.6 + 0.25 * i, "ArrowUp")                        # PRACTICE (row 1)
ev += tap(t + 3.6, "Enter") + tap(t + 4.1, "Enter") + tap(t + 4.6, "Enter") + tap(t + 5.1, "Enter")   # P1, P2, CPU
ev += tap(t + 6.6, "Escape")                                                       # skip the intro
t += 8.5
ev += [cmd(t, 2393)] + tap(t + 0.5, "KeyJ", 0.05) + tap(t + 0.62, "KeyJ", 0.05) + tap(t + 0.9, "KeyJ", 0.05)   # J J J on STAND
ev += [shot(t + 1.6, "practice-combo"), cmd(t + 3.0, 2107)]
t += 3.5
ev += tap(t, "Escape") + [shot(t + 0.6, "practice-pause")]
t += 1.6
ev += tap(t, "ArrowDown") + tap(t + 0.25, "ArrowDown") + tap(t + 0.5, "ArrowRight")    # DUMMY -> GUARD ALL
ev += tap(t + 1.0, "Escape") + [cmd(t + 1.5, 2393)] + tap(t + 2.0, "KeyJ", 0.05) + tap(t + 2.12, "KeyJ", 0.05) + tap(t + 2.4, "KeyJ", 0.05)
t += 4.0
ev += tap(t, "Escape") + tap(t + 0.5, "ArrowDown") + tap(t + 0.75, "ArrowDown") + tap(t + 1.0, "ArrowRight")   # AFTER HIT
ev += tap(t + 1.5, "Escape") + [cmd(t + 2.0, 2393)] + tap(t + 2.5, "KeyJ") + tap(t + 3.3, "KeyJ")
t += 5.0
ev += tap(t, "Escape")                                                             # GAUGES -> INFINITE, CAMERA -> BEHIND
for i in range(5): ev += tap(t + 0.4 + 0.25 * i, "ArrowDown")   # (row 5 since COUNTER, 2026-10-25)
ev += tap(t + 1.6, "Enter")
for i in range(9): ev += tap(t + 2.0 + 0.18 * i, "ArrowDown")                     # CAMERA (row 14 since FLASH STEP, 2026-11-13; 13 since P1 AWAKEN)
ev += tap(t + 3.6, "Enter") + tap(t + 4.1, "Escape") + [cmd(t + 5.0, 2107)]
t += 5.5
# the HP / KONPAKU rows (the user's request 2026-09-28): P1 HP 100 -> 50 %, P1 KONPAKU 9 -> 4, DUMMY HP -> 25 %,
# DUMMY KONPAKU 9 -> 8; the dump: P1 r650 k4 (INFINITE holds his Reishi at his row), P2 r325 k8
ev += tap(t, "Escape")
for i in range(8): ev += tap(t + 0.4 + 0.15 * i, "ArrowDown")                      # P1 HP (row 8 since FLASH STEP, 2026-11-13; 7 since P1 AWAKEN)
ev += tap(t + 1.6, "ArrowRight") + tap(t + 1.8, "ArrowRight") + tap(t + 2.1, "ArrowDown")
for i in range(5): ev += tap(t + 2.4 + 0.2 * i, "ArrowLeft")                       # P1 KONPAKU 4
ev += tap(t + 3.6, "ArrowDown")
for i in range(3): ev += tap(t + 3.9 + 0.2 * i, "ArrowRight")                      # DUMMY HP 25 %
ev += tap(t + 4.7, "ArrowDown") + tap(t + 5.0, "ArrowLeft")                         # DUMMY KONPAKU 8
ev += [shot(t + 5.6, "practice-pause-rows")] + tap(t + 6.6, "Escape") + [cmd(t + 7.0, 2107)]
t += 7.5
ev += [cmd(t, 2393)] + tap(t + 0.5, "KeyJ", 0.05) + [cmd(t + 2.5, 2107)]            # a hit, then refilled to 25 %
t += 3.0
ev += tap(t, "Escape") + tap(t + 0.4, "ArrowDown") + tap(t + 0.8, "Enter") + [cmd(t + 2.0, 2107)]   # RESET POSITION: the rows again
t += 3.0
# P1 AWAKEN (2026-10-31): the row after FLASH STEP (after GAUGES before 2026-11-13), right x3 -> SUBLIMATION 50 (the gauge full, SUBLIMATION 50), then x1 -> SUBLIMATION FULL; the log lines say it
ev += tap(t, "Escape")
for i in range(7): ev += tap(t + 0.4 + 0.2 * i, "ArrowDown")                       # P1 AWAKEN (row 7 since FLASH STEP)
for i in range(3): ev += tap(t + 1.8 + 0.25 * i, "ArrowRight")
ev += tap(t + 2.8, "ArrowRight") + [shot(t + 3.2, "practice-pause-awaken")] + tap(t + 4.2, "Escape") + [cmd(t + 4.6, 2107)]
write("practice", ev)

# 60 s of real-time CPU vs CPU for the stats lines (cons/frame, ms sim / queue / render, fx-dropped)
write("perf", [cmd(T0, 4003), cmd(T0 + 64, 2107)])

# screenshots
t = T0 - 0.5
ev = [shot(t, "title")]
ev += tap(t + 0.5, "Enter"); ev.append(shot(t + 1.5, "mode"))
ev += tap(t + 2.0, "Enter"); ev.append(shot(t + 3.5, "select"))
t += 4.5
def scene(c, name, wait, extra=()):
    global t
    ev.append(cmd(t, c))
    for w, n in ((wait, name),) + tuple(extra): ev.append(shot(t + w, n))
    t += max([wait] + [w for w, n in extra]) + 1.0
scene(2207, "intro", 4.5)
scene(4003, "neutral", 12.0)
scene(2309, "hit", 0.36, ((0.45, "hit-b"), (0.55, "hit-c")))
scene(2306, "guard-break", 0.62, ((0.8, "guard-break-b"),))
scene(2307, "perfect", 0.3, ((0.5, "perfect-b"),))
scene(2300, "hellfire", 0.35, ((0.6, "hellfire-b"),))
scene(2302, "fire-wave", 0.9)
scene(2301, "shiranui", 1.4)
scene(2303, "kaka", 1.4, ((1.9, "kaka-b"),))
scene(2305, "meteor", 0.6)
scene(2200, "bankai", 1.5)
scene(2203, "tenchi", 1.2)
scene(2201, "nozarashi", 1.6)
scene(2202, "kikon-jokaku", 1.9)
scene(2204, "kikon-ken", 1.9)
scene(2205, "kikon-sky", 1.2)
scene(2206, "soul-break", 1.4)
ev += [cmd(t, 2100), cmd(t + 0.1, 2101), cmd(t + 0.2, 2102), cmd(t + 0.3, 4003), cmd(t + 6.0, 2102), shot(t + 9.0, "results")]
t += 10
ev += [cmd(t, 2101), cmd(t + 0.1, 4005), {"at": t + 5, "size": "800x450"}, shot(t + 7, "hud-800x450")]
write("shots", ev)

# Kenpachi's Bankai (docs/duel/DUEL_KEN_BANKAI.md; run with --fixed-dt 16.666667 --secs 60). Expected log lines, in order:
# "P1 BANKAI (konpaku -> 1, -8)" and the dump "... BANKAI r1300 k1 ... m4 u0" (P from cup 3 + red: Konpaku 1, Reishi
# full, 4 pips); "UDE -KE-B-K1 3 left", "-KE-B-K2 2 left", "-KE-B-K3 1 left" (KKK, a pip each); the bite
# "KE-B-BITE -> P2 HIT"; with 1 pip "UDE -KE-B-K1 0 left" then "ARM BURST" only after K1's recovery; 片腕 J "KE-J1".
# Shots: tests/shots/duel-ken-bankai-*.png (the stance, the bite, TATE-GOTO, the burst, 片腕, the cinematics' key frames).
def bshot(t, n): return {"at": round(t, 2), "shot": f"tests/shots/duel-ken-bankai-{n}.png"}
t = T0
ev = []   # (the cup-3 entry 2386 and 片腕 2389 went with the cups and KATAUDE, 2026-11-03)
ev += [cmd(t, 2109), cmd(t + 0.1, 2387), bshot(t + 1.2, "stance")]; t += 1.6             # the side camera from here
for k in ("KeyK", "KeyK", "KeyK"): ev += tap(t, k); t += 0.35                            # KKK: three pips
t += 1.5; ev += [cmd(t, 2107)]; t += 0.3
ev += [cmd(t, 2387)]; ev += tap(t + 0.5, "KeyL"); ev += [bshot(t + 0.5 + 0.17, "bite"), bshot(t + 0.5 + 0.35, "bite-b")]; t += 2.0
ev += [cmd(t, 2387), cmd(t + 0.05, 2108)]
ev += [key(t + 0.5, "ShiftLeft"), key(t + 0.55, "KeyK"), key(t + 0.65, "KeyK", False), key(t + 0.7, "ShiftLeft", False)]
ev += [bshot(t + 0.55 + 0.42, "split"), bshot(t + 0.55 + 0.6, "split-b")]; t += 2.5
ev += [cmd(t, 2388)]; ev += tap(t + 0.5, "KeyK")                                          # the last pip: the burst after it
ev += [bshot(t + 0.5 + 0.72, "burst"), bshot(t + 0.5 + 0.85, "burst-b"), bshot(t + 0.5 + 1.2, "burst-c")]; t += 3.0
ev += [cmd(t, 2109)]; t += 0.3
last = 0
for k, frames in ((35000, (6, 26, 64, 92, 130, 176)), (36000, (8, 40, 74, 110, 150))):
    last = 0
    for f in frames:
        ev.append(cmd(t, k + f)); wait = (f - last) / 60.0 + (1.2 if last == 0 else 0.35)
        ev.append(bshot(t + wait, f"{'cine' if k == 35000 else 'kikon'}-{f:03d}")); t += wait + 0.1; last = f
    t += 0.5
ev.append(cmd(t, 2107))
write("bankai", ev)

# Kurosaki Ichigo (docs/duel/DUEL_ICHIGO.md; run with --fixed-dt 16.666667 --secs 100, landscape, and duel-ichigo-portrait.json
# with --size 390x844). The select screen (the roster cycled to him), then human P1 Ichigo vs an idle Kenpachi (debug
# 74000+k, ICHIGO-TEST): the Shikai (stance, J1, K1, J3, K3, the cross KOGA, GETSUGA, JUJISHO, SOGA), KESSA (stance, J1's
# chain, K1's sweep, the giant GETSUGA and its residue, KUSARI-BIKI, KUSARI-GAKI, the parry's flare, a Step's clone and its
# slash, the KESSA lane), the catch of Kenpachi's K1 (74002, U timed), a Yamamoto wave blocked by the parry (74003), then
# key frames of his three cinematics (75000+f the Shikai Kikon, 75200+f the KESSA Kikon, 75400+f the awakening).
# Shots tests/shots/duel-ichigo[-p]-*.png (review stills).
def ichigo_script(tag, portrait):
    def rs(t, n): return {"at": round(t, 2), "shot": f"{SHOTS}ichigo{tag}-{n}.png"}
    def stap(t, k): return [key(t, "ShiftLeft"), key(t + 0.02, k), key(t + 0.08, k, False), key(t + 0.1, "ShiftLeft", False)]
    def touch(t, x, y): return [{"at": round(t, 2), "touch": "start", "x": x, "y": y}, {"at": round(t + 0.05, 2), "touch": "end", "x": x, "y": y}]
    t = T0 - 0.5
    ev = tap(t + 0.5, "Enter") + tap(t + 1.5, "Enter")
    for i in range(3):
        ev += touch(t + 2.5 + 0.5 * i, 350, 400) if portrait else tap(t + 2.5 + 0.5 * i, "ArrowRight")
    ev.append(rs(t + 4.3, "select")); t += 5.0
    ev += [cmd(t, 74000)] + ([] if portrait else [cmd(t + 0.1, 2109)]); t += 1.2
    ev.append(rs(t, "base-stance")); t += 0.3
    for keys, n, dt in ((["KeyJ"], "j1", 0.12), (["KeyK"], "k1", 0.27), (["KeyJ", "KeyJ", "KeyJ"], "j3-spin", 0.5),
                        (["KeyK", "KeyK", "KeyK"], "k3-drop", 0.97), (["KeyJ", "KeyK"], "k2s-koga", 0.52)):
        ev += [cmd(t, 2393)]; t += 0.3
        for i, k in enumerate(keys): ev += tap(t + [0, 0.12, 0.3][i], k, 0.06)
        ev.append(rs(t + dt, n)); t += 1.5
    ev += [cmd(t, 74006), cmd(t + 0.05, 2108)]; t += 0.5
    ev += tap(t, "KeyL", 0.06); ev += [rs(t + 0.3, "getsuga"), rs(t + 0.5, "getsuga-b")]; t += 1.8
    ev += [cmd(t, 74006), cmd(t + 0.05, 2108)]; t += 0.5
    ev += stap(t, "KeyK"); ev += [rs(t + 0.24, "juji-first"), rs(t + 0.45, "juji")]; t += 1.8
    ev += [cmd(t, 74000), cmd(t + 0.05, 2108)]; t += 0.5
    ev += stap(t, "KeyL"); ev += [rs(t + 0.18, "soga-dash"), rs(t + 0.33, "soga")]; t += 1.6
    ev += [cmd(t, 74001), cmd(t + 0.05, 2108)]; t += 1.2
    ev.append(rs(t, "kessa-stance")); t += 0.3
    ev += tap(t, "KeyJ", 0.06); ev.append(rs(t + 0.18, "k-j1")); t += 1.0
    ev += [cmd(t, 74001)]; t += 0.3
    ev += tap(t, "KeyK", 0.06); ev.append(rs(t + 0.35, "k-k1")); t += 1.2
    ev += [cmd(t, 74007), cmd(t + 0.05, 2108)]; t += 0.4
    ev += tap(t, "KeyL", 0.06); ev += [rs(t + 0.42, "k-giant"), rs(t + 1.3, "k-residue")]; t += 2.4
    ev += [cmd(t, 74001), cmd(t + 0.05, 2108)]; t += 0.4
    ev += stap(t, "KeyK"); ev += [rs(t + 0.3, "k-hiki"), rs(t + 0.55, "k-hiki-b")]; t += 1.6
    ev += [cmd(t, 74008), cmd(t + 0.05, 2108)]; t += 0.4
    ev += stap(t, "KeyL"); ev += [rs(t + 0.4, "k-wall"), rs(t + 1.0, "k-wall-b")]; t += 1.8
    ev += [cmd(t, 74001)]; t += 0.4
    ev += tap(t, "KeyU", 0.06); ev.append(rs(t + 0.12, "k-parry")); t += 1.0
    ev += [cmd(t, 74001)]; t += 0.4
    ev += tap(t, "Space", 0.06); ev += [rs(t + 0.2, "k-clone"), rs(t + 0.38, "k-clone-slash")]; t += 1.4
    ev += [cmd(t, 74001)]; t += 0.4
    ev += tap(t, "KeyO", 0.06); ev.append(rs(t + 0.4, "k-lane")); t += 1.4
    ev += [cmd(t, 74002)]; t += 0.12
    ev += tap(t, "KeyU", 0.06); ev += [rs(t + 0.3, "k-catch"), rs(t + 0.5, "k-yank")]; t += 1.6
    ev += [cmd(t, 74003)]; t += 0.5
    ev += tap(t + 0.35, "KeyU", 0.06); ev += [rs(t + 0.5, "k-block-wave")]; t += 2.0
    if not portrait: ev.append(cmd(t, 2109)); t += 0.2
    for k, frames in ((75000, (6, 40, 90, 116, 140, 160, 178)), (75200, (6, 30, 70, 110, 135, 160, 182)),
                      (75400, (6, 30, 60, 84, 120, 160))):
        last = 0
        for f in frames:
            ev.append(cmd(t, k + f)); wait = (f - last) / 60.0 + (1.2 if last == 0 else 0.35)
            ev.append(rs(t + wait, f"cine{(k - 75000) // 200}-{f:03d}")); t += wait + 0.1; last = f
        t += 0.5
    ev.append(cmd(t, 2107))
    return ev
write("ichigo", ichigo_script("", False))
write("ichigo-portrait", ichigo_script("-p", True))
# Hisagi's core Bankai (DUEL_HISAGI §28.4, batch 1; --fixed-dt 16.666667 --secs 57): every scene a debug setup (83011-83014,
# 83000) and both sides' presses written out, no CPU (P2's own by 83030 his NS / 83031 his J1). A1 / A2 the ranged NS on
# pointer 1 / 2 (2511), A3 pointer 2's gap SA then J: the gathered J2-J4; B J x5 > SP x3: AS3's KAKE binds ("BIND START" at
# the move's end); C / C2 clashes in the bind ("BIND EVEN a -> a', b -> b'": 400 / 1300 -> 512 / 1188); D a K.O. inside the
# bind; E the bind's J x5 > SP x3 (KAIBAKU) back to ranged ("BIND END"); F its whiff; G a Kikon inside the bind (still bound
# after); H the real Mod+P awakening from the Shikai at pointer 3 (2512, 2311: the gauge full): the ranged mode at pointer 2.
def hisagi_bankai_script():
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def press(t, k, down=True): ev.append(key(t, k, down))
    def jtap(t): ev.extend(tap(t, "KeyJ", 0.05))
    def sp(t, hold=0.05): press(t, "ShiftLeft"); ev.extend(tap(t + 0.01, "KeyJ", hold)); press(t + hold + 0.03, "ShiftLeft", False)
    def mash(t0, t1, f, dt):
        while t0 < t1: f(t0); t0 += dt
    def j5_sp3(s): mash(s, s + 1.25, jtap, 0.08); mash(s + 1.3, s + 2.4, sp, 0.12)
    def g(s): press(s, "ShiftLeft"); press(s + 0.01, "KeyJ"); press(s + 1.8, "KeyJ", False); press(s + 1.82, "ShiftLeft", False)
    def h(s):
        ev.extend([cmd(s - 0.2, 2512), cmd(s - 0.15, 2311)])
        press(s, "ShiftLeft"); ev.extend(tap(s + 0.01, "KeyP", 0.06)); press(s + 0.1, "ShiftLeft", False)
        ev.append(cmd(s + 4.5, 83900)); sp(s + 4.7)
    t = T0
    for label, c, dur, body in (
            ("A1 ranged NS1", 83011, 2.5, lambda s: [sp(s), sp(s + 0.25), sp(s + 0.55)]),
            ("A2 ranged NS2", 83011, 3.0, lambda s: [ev.append(cmd(s - 0.1, 2511)), sp(s), sp(s + 0.45), sp(s + 0.95)]),
            ("A4 ranged NS1 WA push", 83016, 3.0, lambda s: [ev.append(cmd(s - 0.1, 2510)), sp(s), sp(s + 0.3), sp(s + 0.7), ev.append(cmd(s + 0.62, 83900))]),
            ("A5 ranged NS1 tip carried", 83023, 3.0, lambda s: [ev.append(cmd(s - 0.1, 2510)), sp(s), sp(s + 0.3), sp(s + 0.7)]),
            ("A6 ranged NS2 TATAKI push", 83016, 3.0, lambda s: [ev.append(cmd(s - 0.1, 2511)), sp(s), sp(s + 0.45), sp(s + 0.95), ev.append(cmd(s + 1.32, 83900))]),
            ("A3 ranged NS2a SA gathered J", 83011, 3.0,
             lambda s: [ev.append(cmd(s - 0.1, 2511)), sp(s), mash(s + 0.4, s + 1.6, jtap, 0.08)]),
            ("A7 gathered SA AS1", 83011, 3.5,
             lambda s: [ev.append(cmd(s - 0.1, 2511)), sp(s), mash(s + 0.4, s + 0.76, jtap, 0.08), mash(s + 0.95, s + 1.5, sp, 0.12)]),
            ("A8 gathered J2 AS2", 83011, 3.5,
             lambda s: [ev.append(cmd(s - 0.1, 2511)), sp(s), mash(s + 0.4, s + 1.1, jtap, 0.08), mash(s + 1.35, s + 2.0, sp, 0.12)]),
            ("A9 gathered J3 AS3 bind", 83011, 5.0,
             lambda s: [ev.append(cmd(s - 0.1, 2511)), sp(s), mash(s + 0.4, s + 1.6, jtap, 0.08), mash(s + 1.75, s + 2.6, sp, 0.12)]),
            ("B J5 AS3 bind", 83011, 4.5, j5_sp3),
            ("B2 after the bind", 83900, 1.0, lambda s: None),
            ("C bind clash", 83012, 2.0, lambda s: [ev.append(cmd(s, 83030)), jtap(s + 0.02)]),
            ("C2 bind clash NS vs NA", 83012, 2.0, lambda s: [sp(s), ev.append(cmd(s + 0.02, 83031))]),
            ("D bind KO", 83013, 6.0, jtap),
            ("E bind AS3 release", 83012, 4.5, j5_sp3),
            ("F bind AS3 whiff", 83014, 2.5, lambda s: [sp(s + 0.1), sp(s + 0.5), sp(s + 0.9)]),
            ("G bind Kikon", 83012, 8.0, g),
            ("H Mod+P awakening", 83000, 7.5, h)):
        say(t, label); ev.extend([cmd(t, c), cmd(t + 0.02, 83900)])
        body(t + 0.3)
        t += dur
        ev.append(cmd(t - 0.05, 83900))
    return sorted(ev, key=lambda x: x["at"])
write("hisagi-bankai", hisagi_bankai_script())

# Hisagi's cancel unlock (DUEL_HISAGI §29; --fixed-dt 16.666667 --secs 35): every scene a debug setup (83040-83047), both sides'
# moves started by it or pressed here, no CPU. A the Shikai 2.0 m: his NS1a and Kenpachi's J1 (a cancel) -> "KIN on", NS1a / NS1b /
# NS1c hit inside 3 m ("KIN: ... inside its 3.0 m dead zone at d ..."), "KIN off" at the route's end; then 2.0 m again: a fresh NS1a
# whiffs. B the same with no J1: NS1 whiffs. C1 the ranged mode, pointer 1: OGI (NS1b, no push) and his J1 -> OGI / ISSEI inside
# 3 m; C4 OGI alone whiffs; C2 pointer 2: TABA and his J1 -> TABA, the gathered SA, J2, J3 inside 2.5 m; C3 TABA alone whiffs. D a same-class tie
# (both J1 on one step) bounces both to neutral: "KIN on" and "KIN off" on that tick; 2.0 m again, NS1a whiffs.
def hisagi_kin_script():
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def jtap(t): ev.extend(tap(t, "KeyJ", 0.05))
    def sp(t, hold=0.05): ev.append(key(t, "ShiftLeft")); ev.extend(tap(t + 0.01, "KeyJ", hold)); ev.append(key(t + hold + 0.03, "ShiftLeft", False))
    def again(s): ev.extend([cmd(s, 83046), cmd(s + 0.02, 83900), cmd(s + 0.6, 83900)]); sp(s + 0.2)
    def probes(s, *ts): ev.extend(cmd(s + x, 83900) for x in ts)
    t = T0
    for label, c, dur, body in (
            ("A Shikai NS1 after a cancel", 83040, 4.5, lambda s: [sp(s + 0.1), sp(s + 1.05), sp(s + 1.25), probes(s, 0.5, 1.2), again(s + 2.6)]),
            ("B Shikai NS1 no cancel", 83041, 3.0, lambda s: [sp(s + 0.1), sp(s + 0.55), sp(s + 0.7), probes(s, 0.3, 0.9)]),
            ("C1 ranged NS1b after a cancel", 83042, 3.0, lambda s: [sp(s + 0.1), probes(s, 0.5, 1.2)]),
            ("C4 ranged NS1b no cancel", 83047, 3.0, lambda s: [sp(s + 0.1), probes(s, 0.3, 0.8)]),
            ("C2 ranged NS2 after a cancel", 83043, 3.5, lambda s: [jtap(s + 0.6), jtap(s + 0.95), jtap(s + 1.3), jtap(s + 1.8), jtap(s + 2.05),
                                                                    probes(s, 0.5, 1.2)]),
            ("C3 ranged NS2 no cancel", 83044, 3.0, lambda s: [jtap(s + 0.6), probes(s, 0.45)]),
            ("D tie bounce", 83045, 3.0, lambda s: [probes(s, 0.2), again(s + 1.0)])):
        say(t, label); ev.extend([cmd(t, c), cmd(t + 0.02, 83900)])
        body(t)
        t += dur
        ev.append(cmd(t - 0.05, 83900))
    return sorted(ev, key=lambda x: x["at"])
write("hisagi-kin", hisagi_kin_script())


def ken_core_script():
    """Kenpachi's base kit on the core system (DUEL_KEN_CORE): control scripts, both sides' inputs, read from the combat log."""
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def sp(t, hold=0.05): ev.append(key(t, "ShiftLeft")); ev.extend(tap(t + 0.01, "KeyJ", hold)); ev.append(key(t + hold + 0.03, "ShiftLeft", False))
    def jt(t): ev.extend(tap(t, "KeyJ", 0.05))
    t = T0
    for label, ptr, body in (
            ("N1 chain: SP x3", 2510, lambda s: [sp(s), sp(s + 0.4), sp(s + 0.8)]),
            ("N2 rush: SP x2, no interference", 2511, lambda s: [sp(s), sp(s + 0.6)]),
            ("N2 armour: P2's NS lands inside the startup", 2511, lambda s: [ev.append(cmd(s - 0.2, 84010)), sp(s)]),
            ("N2 armour: P2's NS lands in the startup, then a second hit", 2511, lambda s: [ev.append(cmd(s - 0.25, 84010)), sp(s), ev.append(cmd(s + 0.12, 84011))]),
            ("N2 cancel x1 then SA", 2511, lambda s: [sp(s), ev.append(cmd(s + 0.1, 84011)), jt(s + 0.9)]),
            ("N3 kamae: SP, J (SA c1) , J2", 2512, lambda s: [sp(s), jt(s + 0.45), jt(s + 0.75)]),
            ("N3 kamae: SP x3, J (SA c3), J2", 2512, lambda s: [sp(s), sp(s + 0.45), sp(s + 0.8), jt(s + 1.15), jt(s + 1.45)]),
            ("N3 kamae: SP, J, J2, SP (AS)", 2512, lambda s: [sp(s), jt(s + 0.45), jt(s + 0.75), sp(s + 1.0)])):
        say(t, label)
        ev.extend([cmd(t, 84000), cmd(t + 0.05, ptr)])
        body(t + 0.3)
        ev.append(cmd(t + 3.6, 2107))   # the state-hash line: both Reishi after the scene
        t += 4.0
    return sorted(ev, key=lambda x: x["at"])
write("ken-core", ken_core_script())


def ken_shikai_script():
    """The V3 Shikai (DUEL_KEN_V3 §3-§9): scene 84001 (the Shikai, awakened, L 0, an idle Ichigo 2.2 m), 2510+p the pointer, 84090+k the unlock
    level L; read the combat log: the segments a route plays at each L, "P1 Ln" when a route lands, the burst ("BURST to pointer n (Lk)",
    "BURST d"), J4 refused below L3, the special AS (J4-J6 + SP), the Bankai (J7 + SP), the temporary switch keeping L (84046: DRIVE 60),
    the awakening starting at L 0 (scene 84000 + 84020, Shift+P)."""
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def sp(t, hold=0.05, stick=None):
        if stick: ev.append(key(t - 0.02, stick))
        ev.append(key(t, "ShiftLeft")); ev.extend(tap(t + 0.01, "KeyJ", hold)); ev.append(key(t + hold + 0.03, "ShiftLeft", False))
        if stick: ev.append(key(t + hold + 0.05, stick, False))
    def jt(t): ev.extend(tap(t, "KeyJ", 0.05))
    def js(t, n): [jt(t + 0.32 * i) for i in range(n)]
    def awaken(t): ev.append(key(t, "ShiftLeft")); ev.extend(tap(t + 0.01, "KeyP", 0.05)); ev.append(key(t + 0.1, "ShiftLeft", False))
    t = T0
    for label, scene, setup, body, dur in (
            ("SH P1 L0: SP x3 (only the lunge; L0 -> 1)", 84001, (2510, 84090), lambda s: [sp(s), sp(s + 0.5), sp(s + 1.0)], 4.0),
            ("SH P1 L1: SP x3 (lunge, spin; L1 -> 2)", 84001, (2510, 84091), lambda s: [sp(s), sp(s + 0.5), sp(s + 1.0)], 4.0),
            ("SH P1 L2: SP x4 (lunge, spin, reverse spin; L2 -> 3)", 84001, (2510, 84092), lambda s: [sp(s + 0.45 * i) for i in range(4)], 4.0),
            ("SH P1 L3: SP x5 (all five)", 84001, (2510, 84093), lambda s: [sp(s + 0.45 * i) for i in range(5)], 5.0),
            ("SH P2 L0: SP x3 (jab, flick only)", 84001, (2511, 84090), lambda s: [sp(s), sp(s + 0.35), sp(s + 0.7)], 4.0),
            ("SH P2 L3: SP x5 (all five)", 84001, (2511, 84093), lambda s: [sp(s + 0.35 * i) for i in range(5)], 5.0),
            ("SH AS1 keeps P1 at L2: J, SP x3 (3 segments; L2 -> 3)", 84001, (2510, 84092), lambda s: [jt(s), sp(s + 0.3), sp(s + 0.75), sp(s + 1.2)], 4.0),
            ("SH burst to P2 at L2: J J J, SP (TOSSHIN-ISSEN 200; P2, L0)", 84001, (2510, 84092), lambda s: [js(s, 3), sp(s + 1.0)], 4.0),
            ("SH burst to P1 at L3: J, SP (ZANGAESHI 260; P1, L0)", 84001, (2511, 84093), lambda s: [jt(s), sp(s + 0.3)], 4.0),
            ("SH burst to P2 at L0: J J J, SP (100)", 84001, (2510, 84090), lambda s: [js(s, 3), sp(s + 1.0)], 4.0),
            ("SH one combo, NS + SA + J + AS at L0: SP, J, J, SP (+1 once: L0 -> 1)", 84001, (2510, 84090),
             lambda s: [sp(s), jt(s + 0.5), jt(s + 0.8), sp(s + 1.1)], 4.0),
            ("SH J4 refused at L2: J x5", 84001, (2510, 84092), lambda s: [js(s, 5)], 4.0),
            ("SH special AS P1 at L3: J x4, SP (DAISHARIN 60+60+120)", 84001, (2510, 84093), lambda s: [js(s, 4), sp(s + 1.35)], 4.5),
            ("SH special AS P2 at L3: J x6, SP (INSEKI-GIRI 260)", 84001, (2511, 84093), lambda s: [js(s, 6), sp(s + 2.0)], 5.0),
            ("SH Bankai at L3: J x7, SP (BANKAI from pointer 1)", 84001, (2510, 84093), lambda s: [js(s, 7), sp(s + 2.3)], 8.0),
            ("SH temporary switch at L1: SP, D+SP, SP x2 (P2's route at L1; no reset)", 84001, (2510, 84091, 84046),
             lambda s: [sp(s), sp(s + 0.5, stick="KeyD"), sp(s + 1.0), sp(s + 1.5)], 4.0),
            ("SH the awakening starts at L0: Shift+P, then SP x3 (only the lunge)", 84000, (84020,), lambda s: [awaken(s), sp(s + 4.5), sp(s + 5.0), sp(s + 5.5)], 8.0)):
        say(t, label)
        ev.append(cmd(t, scene))
        for i, c in enumerate(setup): ev.append(cmd(t + 0.05 * (i + 1), c))
        body(t + 0.4)
        ev.append(cmd(t + dur - 0.4, 2107))
        t += dur
    return sorted(ev, key=lambda x: x["at"])
write("ken-shikai", ken_shikai_script())


def ken_armburst_script():
    """The Bankai's arm burst keeps the Bankai (no KATAUDE since 2026-11-02: 「取消掉片腕的狀態」, DUEL_KEN_CORE §7.3): scene 84004 with the arm
    at 1 pip (84081), pointer 3 (2512): SP burns the last pip on NS3a (no crack clock since §8), ARM BURST, then J is still the Bankai's KE-B-J1."""
    ev = [{"at": T0, "eval": "console.log('=== arm burst: NS3a burns the last pip, he stays BANKAI')"}, cmd(T0, 84004), cmd(T0 + 0.05, 84081),
          cmd(T0 + 0.1, 2512), key(T0 + 0.3, "ShiftLeft")]
    ev += tap(T0 + 0.31, "KeyJ", 0.05); ev.append(key(T0 + 0.39, "ShiftLeft", False))
    ev += tap(T0 + 3.0, "KeyJ", 0.05)
    return ev
write("ken-armburst", ken_armburst_script())


def ken_bankai_script():
    """The Bankai on the core system (DUEL_KEN_CORE §8): scene 84004 (the Bankai, the arm full, an idle Ichigo 2.2 m), pointer 2510+p; each
    pointer's NS, its SA, the three AS (AS3 in canon's order); pointer 3's pips: 84080+k sets the arm to k pips (3 burn 3, 1 lets only NS3a
    start, 0 refuses it); the arm's last pip burnt bursts it and he stays in the Bankai."""
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def sp(t, hold=0.05): ev.append(key(t, "ShiftLeft")); ev.extend(tap(t + 0.01, "KeyJ", hold)); ev.append(key(t + hold + 0.03, "ShiftLeft", False))
    def jt(t): ev.extend(tap(t, "KeyJ", 0.05))
    def pips(t, k): ev.append(cmd(t, 84080 + k))
    t = T0
    for label, ptr, body in (
            ("BK N1 maw: SP x3 (claw, bite, rip)", 2510, lambda s: [sp(s), sp(s + 0.45), sp(s + 0.85)]),
            ("BK N1 maw: SP, J (SA hook), J2", 2510, lambda s: [sp(s), jt(s + 0.5), jt(s + 0.8)]),
            ("BK N2 cleaver: SP x2 (leap cut, flat hammer)", 2511, lambda s: [sp(s), sp(s + 0.6)]),
            ("BK N2 cleaver: SP, J (SA hack)", 2511, lambda s: [sp(s), jt(s + 0.55)]),
            ("BK N3 arm: SP x3 at 4 pips (burns 3)", 2512, lambda s: [sp(s), sp(s + 0.6), sp(s + 1.1)]),
            ("BK N3 arm: SP x3 at 1 pip (NS3a, then refused; the burst)", 2512, lambda s: [pips(s - 0.1, 1), sp(s), sp(s + 0.6), sp(s + 1.1)]),
            ("BK N3 arm: SP at 0 pips (refused)", 2512, lambda s: [pips(s - 0.1, 0), sp(s)]),
            ("BK AS1: J, SP (bites the arm off)", 2510, lambda s: [jt(s), sp(s + 0.3)]),
            ("BK AS2: J, J2, SP, SP (chin punch, leap chop)", 2510, lambda s: [jt(s), jt(s + 0.3), sp(s + 0.65), sp(s + 1.25)]),
            ("BK Kikon: J, SP held (the Kikon of AS1 burns a pip)", 2510, lambda s: [jt(s), sp(s + 0.3, hold=1.6)]),
            ("BK AS3: SP, J, J2, J3, SP x3 (leap cut, chin punch, TATE-GOTO burns 1)", 2510,
             lambda s: [sp(s), jt(s + 0.9), jt(s + 1.2), jt(s + 1.5), sp(s + 1.85), sp(s + 2.4), sp(s + 2.95)])):
        say(t, label)
        ev.extend([cmd(t, 84004), cmd(t + 0.05, ptr)])
        body(t + 0.3)
        ev.append(cmd(t + 3.6, 2107))
        t += 4.0
    return sorted(ev, key=lambda x: x["at"])
write("ken-bankai", ken_bankai_script())


def ken_sealed_script():
    """V3's sealed form (DUEL_KEN_V3 §35): scene 84000 (the sealed katana, an idle Ichigo 2.2 m), pointer 2510+p; each pointer's NS and its SA,
    pointer 2's armour against Ichigo's NS (84010), pointer 3's tame catching his J1 (84011) and the thrust answering, the three AS."""
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def sp(t, hold=0.05): ev.append(key(t, "ShiftLeft")); ev.extend(tap(t + 0.01, "KeyJ", hold)); ev.append(key(t + hold + 0.03, "ShiftLeft", False))
    def jt(t): ev.extend(tap(t, "KeyJ", 0.05))
    t = T0
    for label, ptr, body in (
            ("Z N1 drag: SP x3 (drag-up, back-hand, sweep)", 2510, lambda s: [sp(s), sp(s + 0.5), sp(s + 0.95)]),
            ("Z N1 drag: SP, J (SA shove)", 2510, lambda s: [sp(s), jt(s + 0.5)]),
            ("Z N2 shoulder: SP x2 (two drops)", 2511, lambda s: [sp(s), sp(s + 0.6)]),
            ("Z N2 shoulder: Ichigo NS, SP (the drop takes his hit)", 2511, lambda s: [ev.append(cmd(s, 84010)), sp(s + 0.2)]),
            ("Z N3 chudan: SP x3 (tame, thrust, men)", 2512, lambda s: [sp(s), sp(s + 0.3), sp(s + 0.75)]),
            ("Z N3 chudan: SP, Ichigo J1 (the tame catches it, the thrust)", 2512, lambda s: [sp(s), ev.append(cmd(s + 0.05, 84011))]),
            ("Z N3 chudan: SP, J (SA kote)", 2512, lambda s: [sp(s), jt(s + 0.3)]),
            ("Z AS1: J1 J2 SP (drag-up, knockdown)", 2510, lambda s: [jt(s), jt(s + 0.3), sp(s + 0.6)]),
            ("Z AS2: J1 J2 J3 SP SP (overhead, rising cut launch)", 2510, lambda s: [jt(s), jt(s + 0.3), jt(s + 0.6), sp(s + 0.9), sp(s + 1.4)]),
            ("Z AS3: J1-J5 SP x3 (thrust, kote, the thrust through the guard)", 2510,
             lambda s: [jt(s), jt(s + 0.3), jt(s + 0.6), jt(s + 0.9), jt(s + 1.2), sp(s + 1.55), sp(s + 2.05), sp(s + 2.5)]),
            ("Z Kikon 1: J1 J2 SP held (the Kikon of AS1)", 2510, lambda s: [jt(s), jt(s + 0.3), sp(s + 0.6, hold=1.6)]),
            ("Z Kikon 2: J1 J2 J3 SP SP held (the Kikon of AS2)", 2510, lambda s: [jt(s), jt(s + 0.3), jt(s + 0.6), sp(s + 0.9), sp(s + 1.4, hold=1.6)])):
        say(t, label)
        ev.extend([cmd(t, 84000), cmd(t + 0.05, ptr)])
        body(t + 0.3)
        ev.append(cmd(t + 3.6, 2107))
        t += 4.0 if "Kikon" not in label else 7.0   # (the Kikon's cinematic plays through)
    return sorted(ev, key=lambda x: x["at"])
write("ken-sealed", ken_sealed_script())


def sublimation_script():
    """SUBLIMATION / SPIRIT DRIVE (DUEL_SUBLIMATION): J1 damage and taken at 0 / 100 % SUBLIMATION and at DRIVE 100 with s 0.4, the real
    awakening's freeze, the Bankai's entry needing a full DRIVE; since §18 only attacking fills SUBLIMATION / DRIVE (debug 84020+k / 84040+k / 84060 / 84070 on the 84000 scene)."""
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def jt(t): ev.extend(tap(t, "KeyJ", 0.05))
    def awaken(t): ev.append(key(t, "ShiftLeft")); ev.extend(tap(t + 0.01, "KeyP", 0.05)); ev.append(key(t + 0.1, "ShiftLeft", False))
    t = T0
    for label, scene, setup, body in (
            ("SB J1 at sub 0", 84000, 84020, lambda s: [jt(s)]),
            ("SB J1 at sub 100", 84000, 84030, lambda s: [jt(s)]),
            ("SB J1 at drive 100, s 0.4 (frac 0.7)", 84000, 84050, lambda s: [jt(s)]),
            ("SB taken at sub 0: P2 J1", 84000, 84020, lambda s: [ev.append(cmd(s, 84011))]),
            ("SB taken at sub 100: P2 J1", 84000, 84030, lambda s: [ev.append(cmd(s, 84011))]),
            ("SB J1 at drive 50: DRIVE fills by attacking (DUEL_SUBLIMATION §18)", 84000, 84045, lambda s: [jt(s)]),
            ("SB taken at drive 50: P2 J1 (DRIVE stays)", 84000, 84045, lambda s: [ev.append(cmd(s, 84011))]),
            ("SB real awakening at sub 50 -> s 0.5, frac 0.25", 84000, 84060, lambda s: [])):   # (the cup-3 Bankai rows went with the cups)
        say(t, label)
        ev.extend([cmd(t, scene), cmd(t + 0.05, setup)])
        body(t + 0.3)
        ev.append(cmd(t + 1.6, 84070))
        ev.append(cmd(t + 1.7, 2107))
        t += 2.2
    return sorted(ev, key=lambda x: x["at"])
write("sublimation", sublimation_script())

def drive_switch_script():
    """The temporary pointer switch (DUEL_SUBLIMATION §17): KESSA with DRIVE 60 (debug 86105): SP, then D (right) / A (left) held + SP in the gap;
    a second switch inside the temporary route (refused); the awakening gauge never full (86107: refused); SP 15 (86111: the switch starts scaled,
    S6, DUEL_SP §3 / Q14) and SP 0 (86112: refused, only a route's first NS segment starts at 0). Each switch logs `NS pointer a -> b (SP; DRIVE d SUB s
    unchanged)` and the `SP <seg> fs .. cost .. paid .. x..` line of the segment it starts."""
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def sp(t, hold=0.05): ev.append(key(t, "ShiftLeft")); ev.extend(tap(t + 0.01, "KeyJ", hold)); ev.append(key(t + hold + 0.03, "ShiftLeft", False))
    def jt(t): ev.extend(tap(t, "KeyJ", 0.05))
    def sw(t, k): ev.append(key(t - 0.05, k)); sp(t); ev.append(key(t + 0.15, k, False))
    t = T0
    for label, setup, body in (
            ("DS right: SP, D+SP", 86105, lambda s: [sp(s), sw(s + 0.3, "KeyD")]),
            ("DS left: SP, A+SP", 86105, lambda s: [sp(s), sw(s + 0.3, "KeyA")]),
            ("DS twice: SP, D+SP, D+SP (second refused)", 86105, lambda s: [sp(s), sw(s + 0.3, "KeyD"), sw(s + 0.9, "KeyD")]),
            ("DS no stick: SP, SP (plain next segment)", 86105, lambda s: [sp(s), sp(s + 0.3)]),
            ("DS sublimation 60 (Shikai): SP, D+SP", 86108, lambda s: [sp(s), sw(s + 0.3, "KeyD")]),
            ("DS charge base: ptr 2, SP, J (charged SA), J2, J3", 86105, lambda s: [ev.append(cmd(s - 0.2, 2511)), sp(s), jt(s + 0.45), jt(s + 0.75), jt(s + 1.05)]),
            ("DS charge via switch: ptr 3, SP, A+SP (NS2a), J (SA), J2, J3", 86105, lambda s: [ev.append(cmd(s - 0.2, 2512)), sp(s), sw(s + 0.3, "KeyA"), jt(s + 0.85), jt(s + 1.15), jt(s + 1.45)]),
            ("DS clones via switch: ptr 1, SP, D+SP... (ptr 2 -> D -> 3), J, J2", 86105, lambda s: [ev.append(cmd(s - 0.2, 2511)), sp(s), sw(s + 0.3, "KeyD"), jt(s + 0.85), jt(s + 1.15)]),
            ("DS NS2 > NS3 keeps the charge: ptr 2, SP, D+SP, J (charged SA), J2", 86105, lambda s: [ev.append(cmd(s - 0.2, 2511)), sp(s), sw(s + 0.3, "KeyD"), jt(s + 0.85), jt(s + 1.15)]),
            ("DS NS3 > NS1: clones replay the cuts: ptr 3, SP, D+SP", 86105, lambda s: [ev.append(cmd(s - 0.2, 2512)), sp(s), sw(s + 0.3, "KeyD")]),
            ("DS plain SA: ptr 1, SP, J (the SA is J1's motion)", 86105, lambda s: [sp(s), jt(s + 0.45)]),
            ("DS gauge never full (86107): SP, D+SP (refused)", 86107, lambda s: [sp(s), sw(s + 0.3, "KeyD")]),
            ("DS SP 15 (86111): SP, D+SP (starts scaled)", 86111, lambda s: [sp(s), sw(s + 0.3, "KeyD")]),
            ("DS SP 0 (86112): SP, D+SP (refused)", 86112, lambda s: [sp(s), sw(s + 0.3, "KeyD")])):
        say(t, label)
        ev.extend([cmd(t, setup), cmd(t + 3.0, 2107)])
        body(t + 0.3)
        t += 3.5
    return sorted(ev, key=lambda x: x["at"])
write("drive-switch", drive_switch_script())

def switch_routes_script():
    """The switch routes the user named (DUEL_SUBLIMATION §17.7): Hisagi's Shikai with SUBLIMATION 60 (debug 83600+d, d / 10 m from an idle
    Kenpachi): NS1 at range, then A (left: pointer 3) + SP for NS3a, J for its SA 引寄 or SP for NS3b and J for its SA 放電; the Bankai's
    ranged mode with DRIVE 60 (83700+d): NS1a 環 WA, then D + SP for 聚 NS2a and its route. 83900 logs the distance (`| d`; 83099 did before the trace scenes took 83050-83099: it set up a Bankai trace and turned this script's Shikai into the Bankai, S6)."""
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def sp(t, hold=0.05): ev.append(key(t, "ShiftLeft")); ev.extend(tap(t + 0.01, "KeyJ", hold)); ev.append(key(t + hold + 0.03, "ShiftLeft", False))
    def jt(t): ev.extend(tap(t, "KeyJ", 0.05))
    def sw(t, k): ev.append(key(t - 0.05, k)); sp(t); ev.append(key(t + 0.15, k, False))
    def d(t): ev.append(cmd(t, 83900))
    t = T0
    for label, setup, body in (
            ("SR shikai 6.0 m: NS1a, A+SP (NS3a), J (SA YOSE), J2", 83660, lambda s: [sp(s), sw(s + 0.3, "KeyA"), jt(s + 0.8), jt(s + 1.3)]),
            ("SR shikai 4.5 m: NS1a, A+SP (NS3a), J (SA YOSE), J2", 83645, lambda s: [sp(s), sw(s + 0.3, "KeyA"), jt(s + 0.8), jt(s + 1.3)]),
            ("SR shikai 4.5 m: NS1a, NS1b, A+SP (NS3a), J (SA YOSE), J2", 83645, lambda s: [sp(s), sp(s + 0.3), sw(s + 0.7, "KeyA"), jt(s + 1.2), jt(s + 1.7)]),
            ("SR shikai 6.0 m: NS1a, A+SP (NS3a), SP (NS3b), J (SA HODEN)", 83660, lambda s: [sp(s), sw(s + 0.3, "KeyA"), sp(s + 0.8), jt(s + 1.3)]),
            ("SR shikai 4.5 m: NS1a, A+SP (NS3a), SP (NS3b), J (SA HODEN)", 83645, lambda s: [sp(s), sw(s + 0.3, "KeyA"), sp(s + 0.8), jt(s + 1.3)]),
            ("SR shikai 6.0 m: NS1a, NS1b, A+SP (NS3a), SP (NS3b), J (SA HODEN)", 83660, lambda s: [sp(s), sp(s + 0.3), sw(s + 0.7, "KeyA"), sp(s + 1.2), jt(s + 1.7)]),
            ("SR shikai 6.0 m: NS1a, NS1b, NS1c, A+SP (after the last segment)", 83660, lambda s: [sp(s), sp(s + 0.3), sp(s + 0.75), sw(s + 1.2, "KeyA")]),
            ("SR shikai 6.0 m base: NS1a, NS1b, NS1c", 83660, lambda s: [sp(s), sp(s + 0.3), sp(s + 0.75)]),
            ("SR bankai 2.5 m base: NS1a WA, NS1b OGI, NS1c ISSEI", 83725, lambda s: [sp(s), sp(s + 0.15), sp(s + 0.7)]),
            ("SR bankai 2.5 m: NS1a WA, D+SP (NS2a TABA), SP (TATAKI), SP (OMEGURI)", 83725, lambda s: [sp(s), sw(s + 0.15, "KeyD"), sp(s + 0.75), sp(s + 1.45)]),
            ("SR bankai 2.5 m: NS1a WA, D+SP (NS2a TABA), J (gathered SA), J2", 83725, lambda s: [sp(s), sw(s + 0.15, "KeyD"), jt(s + 0.75), jt(s + 1.3)])):
        say(t, label)
        ev.extend([cmd(t, setup), cmd(t + 3.5, 2107)])
        body(t + 0.3)
        for k in range(1, 8): d(t + 0.3 + 0.4 * k)
        t += 4.0
    return sorted(ev, key=lambda x: x["at"])
write("switch-routes", switch_routes_script())

def shikai_dswitch_script():
    """The Shikai's DRIVE switch for a CPU under the merged style (DUEL_AI_STRATEGY §8.19 round 3): debug 83809 (P1 a HARD CPU Hisagi in the
    Shikai, SUBLIMATION 60, 4.5 m from an idle Kenpachi, NS1 started, the merged style with :DSWITCH 1.0 and :SHIKAI-DSWITCH) must log
    `P1 cpu switch 1 -> 3`; 83810 (the same without :SHIKAI-DSWITCH) must not. 2107 logs the state."""
    ev = []
    t = T0
    for label, c in (("SD 83809 merged + shikai-dswitch: expect P1 cpu switch 1 -> 3", 83809), ("SD 83810 merged, no shikai-dswitch: no switch", 83810)):
        ev.append({"at": round(t, 2), "eval": f"console.log('=== {label}')"})
        ev.extend([cmd(t, c), cmd(t + 3.5, 2107)])
        t += 4.0
    return sorted(ev, key=lambda x: x["at"])
write("shikai-dswitch", shikai_dswitch_script())

def drive_switch_phone_script():
    """The thumb's switch (DUEL_SUBLIMATION §17.3; --mobile --size 390x844): KESSA with DRIVE 60 (debug 86105): an SP tap in the upper pad, then a
    sideways flick (right / left) in the NS gap = the pointer switch; a flick with the awakening gauge never full (86107) stays a Step (S6: the gate is SP > 0 and the gauge full once, not DRIVE)."""
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def tap(t, x, y): return [{"at": round(t, 2), "touch": "start", "x": x, "y": y}, {"at": round(t + 0.05, 2), "touch": "end", "x": x, "y": y}]
    def flick(t, x0, x1, y=600): return [{"at": round(t, 2), "touch": "start", "x": x0, "y": y}, {"at": round(t + 0.03, 2), "touch": "move", "x": (x0 + x1) // 2, "y": y},
                                         {"at": round(t + 0.06, 2), "touch": "move", "x": x1, "y": y}, {"at": round(t + 0.12, 2), "touch": "end", "x": x1, "y": y}]
    t = T0
    for label, setup, body in (
            ("DP right flick: SP tap, flick right", 86105, lambda s: [*tap(s, 195, 520), *flick(s + 0.3, 150, 260)]),
            ("DP left flick: SP tap, flick left", 86105, lambda s: [*tap(s, 195, 520), *flick(s + 0.3, 260, 150)]),
            ("DP gauge never full: SP tap, flick right (a Step)", 86107, lambda s: [*tap(s, 195, 520), *flick(s + 0.3, 150, 260)])):
        say(t, label)
        ev.extend([cmd(t, setup), cmd(t + 3.0, 2107)])
        ev.extend(body(t + 0.3))
        t += 3.5
    return sorted(ev, key=lambda x: x["at"])
write("drive-switch-phone", drive_switch_phone_script())


def blue_burn_script():
    """BLUE burns one cell (DUEL_DESIGN "BLUE burns one cell", 2026-11-12; debug 2610+k): (a) BLUE from 300 runs out, (b) BLUE from 300 and a Hoho 0.5 s in
    (P1 Mod+Space), (c) BLUE from 230 runs out, (d) WHITE from 300 for contrast; each scene's `BURST` / `BURST END` lines carry fs."""
    ev = [cmd(T0 - 1, 2105)]
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    t = T0
    for label, c, hoho in (("a BLUE 300 runs out", 2610, None), ("b BLUE 300, Hoho at 0.5 s", 2610, 0.5), ("c BLUE 230 runs out", 2611, None), ("d WHITE 300", 2612, None)):
        say(t, label)
        ev += [cmd(t, c), cmd(t + 0.05, 2107)]
        if hoho is not None:
            ev += [key(t + hoho, "ShiftLeft"), key(t + hoho + 0.03, "Space"), key(t + hoho + 0.13, "Space", False), key(t + hoho + 0.16, "ShiftLeft", False)]
        ev += [shot(t + 1.0, f"blue-burn-{label[0]}-1s"), cmd(t + 7.0, 2107)]
        t += 8.0
    return sorted(ev, key=lambda x: x["at"])
write("blue-burn", blue_burn_script())


def practice_cancel_script():
    """PRACTICE's GUARD ALL with a :core dummy (DUEL_CORE §9, 2026-11-12: 「練習模式 DUMMY 的「GUARD ALL」會自動使出能跟對手相消的攻擊」;
    --fixed-dt 16.666667 --secs 230): P1's keys written out (frames after the scene command; each press lands inside the link before it), the
    dummy's presses its own. 2800 + 3a + b: P1 a against dummy b (0 Kenpachi, 1 Ichigo, 2 Hisagi), 2.2 m, GUARD ALL; per pair (a) J1, (b) the
    five J, (c) NS x3, (d) NS then the SA, (e) J then SP (the AS), (f) idle 3 s on KK / IH. Then (g) Hisagi's NS1 x3 at 2.2 m against DUMMY
    STAND (the control: no contact without a cancel's unlock), (h) Ichigo's pointer 2 at 2.2 m and (h2) at 6 m (DUEL_SP S5: the wave is judged as NS2c,
    GUARD ALL presses J into its arrival, `P1 wave ns x P2: CANCEL`; before S5 it landed), (i) J1 at 6 m (out of
    reach: no answer), (j) STAND / GUARD AFTER HIT / CPU as before, (k) COUNTER J1 with GUARD ALL: J1 once the SA's stun ends. Read the
    combat log's `CANCEL` / `HIT` lines per `===` scene."""
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def press(t, kind):
        if kind == "j": ev.extend(tap(t, "KeyJ", 0.05))
        else: ev.append(key(t, "ShiftLeft")); ev.extend(tap(t + 0.01, "KeyJ", 0.05)); ev.append(key(t + 0.09, "ShiftLeft", False))
    t = T0
    def scene(label, cmds, presses, ticks):
        nonlocal t
        say(t, label)
        ev.extend(cmd(t + 0.02 * i, c) for i, c in enumerate(cmds))
        for off, kind in presses: press(t + 0.05 + off / 60, kind)
        t += ticks / 60 + 0.6
    names = "KIH"
    pairs = {(0, 0): ([23, 43, 81, 135], 59, 21), (0, 1): ([23, 43, 81, 127], 59, 21), (1, 0): ([23, 54, 103, 155], 67, 29),
             (1, 2): ([23, 51, 90, 144], 67, 29), (2, 0): ([23, 54, 102, 161], 50, 29), (2, 1): ([23, 51, 91, 146], 50, 29)}
    for (a, b), (js, ns3, as_) in pairs.items():
        c, pr = 2800 + 3 * a + b, names[a] + names[b]
        scene(f"{pr} a J1", [c], [(10, "j")], 200)
        scene(f"{pr} b J x5", [c], [(10, "j")] + [(o, "j") for o in js], 400)
        scene(f"{pr} c NS x3", [c], [(10, "sp"), (23, "sp"), (ns3, "sp")], 400)
        scene(f"{pr} d NS then SA", [c], [(10, "sp"), (23, "j")], 300)
        scene(f"{pr} e J then SP (AS)", [c], [(10, "j"), (as_, "sp")], 300)
        if (a, b) in ((0, 0), (1, 2)): scene(f"{pr} f idle 3 s", [c], [], 180)
    scene("g HK NS1 x3 at 2.2 m, DUMMY STAND (control)", [2806, 2810], [(10, "sp"), (23, "sp"), (43, "sp")], 300)
    scene("h IK pointer 2 x3 (the wave)", [2803, 2511], [(10, "sp"), (23, "sp"), (39, "sp")], 400)
    scene("h2 IK pointer 2 x3 at 6 m (the wave cancelled)", [2803, 2814, 2511], [(10, "sp"), (23, "sp"), (39, "sp")], 400)
    scene("i KK J1 at 6 m", [2800, 2814], [(10, "j")], 120)
    scene("j KK STAND J1", [2800, 2810], [(10, "j")], 120)
    scene("j KK GUARD AFTER HIT J x2", [2800, 2812], [(10, "j"), (23, "j")], 160)
    scene("j KK CPU, P1 idle", [2800, 2813], [], 240)
    scene("k KK COUNTER J1 + GUARD ALL: NS then SA", [2800, 2815], [(10, "sp"), (23, "j")], 300)
    ev.append(cmd(t, 2815))
    return sorted(ev, key=lambda x: x["at"])
write("practice-cancel", practice_cancel_script())
# Hisagi's ranged NS2 a > b > c (DUEL_HISAGI §30; --fixed-dt 16.666667 --secs 45): the ranged mode at pointer 2 from an idle Kenpachi at
# 2.6 / 3.0 / 3.5 / 4.0 m (83056 / 83060 / 83065 / 83070) and from an idle Ichigo at 3.0 m (83048), SP mashed every 0.1 s (the earliest
# latch); the per-tick `duel trace` lines (his move, both states, the distance) and the combat log's hit ticks give every link's margin
# (the next hit's tick against the first IDLE tick of the victim). The last two scenes press the second SP late (0.75 s: b hits 5 f
# inside the stun; 0.85 s: 1 f after he is free).
def hisagi_ns2_script():
    ev = []
    t = T0
    def sp(s, hold=0.05):
        ev.append(key(s, "ShiftLeft")); ev.extend(tap(s + 0.01, "KeyJ", hold)); ev.append(key(s + hold + 0.03, "ShiftLeft", False))
    for name, c, presses in (("A2.6", 83056, None), ("A3.0", 83060, None), ("A3.5", 83065, None), ("A4.0", 83070, None),
                             ("Ichigo3.0", 83048, None), ("slow0.75", 83060, (0, 0.75)), ("slow0.85", 83060, (0, 0.85))):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.append(cmd(t, c))
        for p in (presses or [0.1 * i for i in range(13)]): sp(t + 0.3 + p)
        t += 3.8
    return sorted(ev, key=lambda x: x["at"])
write("hisagi-ns2", hisagi_ns2_script())
# A cancel is symmetric (DUEL_CORE §2.1, the user 2026-11-12: 「為什麼檜佐木遠距 J1 相消後接不了 J2 與 AS？」, then 「相消不該有所謂的攻擊方與
# 受擊方，是一個平等的狀態」; --fixed-dt 16.666667 --secs 130): Hisagi's ranged J1, then J (J2) or SP (the AS) 0.2 / 0.35 / 0.5 / 0.7 s
# after it, in PRACTICE vs Kenpachi at 2.2 / 4.5 m against GUARD ALL (83811 / 83812) and STAND (83813 / 83814). Read the combat log's
# `CANCEL` / `HIT` lines, the J2 / AS start lines and `KIN on / off` per `===` scene.
def hisagi_j1_cancel_script():
    ev = []
    t = T0
    for c, dist, dummy in ((83811, 2.2, "GUARD ALL"), (83812, 4.5, "GUARD ALL"), (83813, 2.2, "STAND"), (83814, 4.5, "STAND")):
        for second in ("J", "SP"):
            for off in (0.2, 0.35, 0.5, 0.7):
                ev.append({"at": round(t, 2), "eval": f"console.log('=== {dist} m {dummy} J1 then {second} +{off}')"})
                ev.append(cmd(t, c))
                ev.extend(tap(t + 0.3, "KeyJ", 0.05))
                a = t + 0.3 + off
                if second == "J": ev.extend(tap(a, "KeyJ", 0.05))
                else: ev.append(key(a, "ShiftLeft")); ev.extend(tap(a + 0.01, "KeyJ", 0.05)); ev.append(key(a + 0.09, "ShiftLeft", False))
                t += 3.5
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("hisagi-j1-cancel", hisagi_j1_cancel_script())
# A stealing AS never takes the last cell of the victim's flash-step (DUEL_SP §2 / §6, S1 2026-11-13; before: a victim's whole gauge, DUEL_CORE §2.2;
# --fixed-dt 16.666667 --secs 110): P1's flash-step 100, P2's 100 / 130 / 300 (2820-2822 after the setup), then J, 0.5 s later Shift+J (J1 then the AS):
# Hisagi's TSUMUJI (83815), Ichigo's RAKUGA (74000), KESSA's KUSARI-BIKI without clones (74001) and with two NS3 clones (74001 + 74904); 74908 / 83815 set
# the gauges, 74909 / 83816 print the `duel steal` fs line; the combat log's `STEAL fs` lines give each hit's take and the attacker's gain.
def steal_cap_script():
    ev = []
    t = T0
    for victim in (0, 1, 2):
        for name, setup, prime, end, sp in (("TSUMUJI", 83815, None, 83816, 0.5), ("RAKUGA", 74000, 74908, 74909, 0.5),
                                            ("KUSARI-BIKI", 74001, 74908, 74909, 0.25), ("KUSARI-BIKI 2 NS3 clones", 74001, 74908, 74909, 0.25)):
            ev.append({"at": round(t, 2), "eval": f"console.log('=== {name} victim {(100, 130, 300)[victim]}')"})
            ev.append(cmd(t, setup))
            if "NS3" in name: ev.append(cmd(t + 0.03, 74904))
            if prime: ev.append(cmd(t + 0.05, prime))
            ev.append(cmd(t + 0.1, 2820 + victim))                 # (after the scene's own gauges: P2 at 100 / 130 / 300)
            ev.extend(tap(t + 0.5, "KeyJ", 0.05))                  # J1 (hits the idle dummy), then SP: the AS
            a = t + 0.5 + sp                                       # (KESSA's J1 is shorter: SP inside its hit window)
            ev.append(key(a, "ShiftLeft")); ev.extend(tap(a + 0.01, "KeyJ", 0.05)); ev.append(key(a + 0.1, "ShiftLeft", False))
            ev.append(cmd(t + 6.0, end))
            t += 8.0
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("steal-cap", steal_cap_script())
# PRACTICE's FLASH STEP row (DUEL_SP §8.4 S9, 2026-11-13; --fixed-dt 16.666667 --secs 75): Kenpachi vs Kenpachi on DUMMY STAND (2800 + 2810, 2.2 m),
# the row set by keyboard (pause, 6 x down, right: KEEP -> FULL -> ONE CELL -> EMPTY -> KEEP), then NS1 x3 (2809: 2.2 m, idle). Expected per `===`
# scene: `duel practice FLASH STEP  <v>`, then the combat log's `P1 SP KE-Z-N1A / B / C fs F cost C paid P xS` lines: FULL fs 300.0 each, paid in
# full; ONE CELL fs 100.0 each; EMPTY `fs 0.0 ... paid 0.0 x0.50` then `P1 SP KE-Z-N1B refused (fs 0.0)`; KEEP (a fresh match: 300) the gauge
# going down by each price. Then EMPTY against GUARD ALL (2811) and a J1: the dummy pays like a player (`P2 SP ... fs 0.0 ... x0.50`, DUEL_SP Q16 / Q19).
# Shots: practice-fs-pause (the pause with the row); duel-practice-fs-phone.json (`--mobile --size 390x844`) is the same on the handheld PRACTICE scene 2506 (Ichigo vs Kenpachi: IC-N1A..C).
def practice_fs_script(first=2800):
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def sp(t): ev.append(key(t, "ShiftLeft")); ev.extend(tap(t + 0.01, "KeyJ", 0.05)); ev.append(key(t + 0.09, "ShiftLeft", False))
    def set_row(t, shot_name=None):                      # pause, FLASH STEP (row 6), one step right, resume
        ev.extend(tap(t, "Escape"))
        for i in range(6): ev.extend(tap(t + 0.4 + 0.2 * i, "ArrowDown"))
        ev.extend(tap(t + 1.8, "ArrowRight"))
        if shot_name: ev.append(shot(t + 2.3, shot_name))
        ev.extend(tap(t + 3.4, "Escape"))
        return t + 3.8
    t = T0
    ev += [cmd(t, first), cmd(t + 0.05, 2810)]
    t += 1.0
    for v in ("FULL", "ONE CELL", "EMPTY", "KEEP"):
        say(t, v)
        t = set_row(t, ("practice-fs-pause" + ("-phone" if first != 2800 else "")) if v == "FULL" else None)
        if v == "KEEP": ev += [cmd(t, first), cmd(t + 0.05, 2810)]; t += 0.5
        ev.append(cmd(t, 2809))
        for f in (10, 23, 59): sp(t + 0.05 + f / 60)
        t += 3.0
    say(t, "EMPTY vs GUARD ALL, J1")
    for _ in range(3): t = set_row(t)                    # KEEP -> FULL -> ONE CELL -> EMPTY
    ev += [cmd(t, 2811)]
    ev.extend(tap(t + 0.05 + 10 / 60, "KeyJ", 0.05))
    t += 3.0
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("practice-fs", practice_fs_script())
write("practice-fs-phone", practice_fs_script(2506))

# the plates' red Konpaku hint follows the pointer (REFACTOR_2026-11 R15d, 2026-11-14): human P1 Ichigo vs Kenpachi's idle CPU (2500),
# P1's pointer 1 / 2 / 3 (2510-2512), then P2 red (2314: P2 at 200 Reishi): a `webhud stake P1 a P2 b ...` line each (2515).
# P2's plate shows what P1's Kikon would take: base 2 -> 1 / 2 / 1, red 1 / 3 / 1 (was 2 for all six before R15d);
# P1's (Kenpachi on pointer 1): 1.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --script tests/scripts/duel-stake.json
def stake_script():
    ev, t = [cmd(T0, 2500)], T0 + 1.0
    for red in (False, True):
        if red: ev.append(cmd(t, 2314)); t += 0.2
        for p in (2510, 2511, 2512):
            ev += [cmd(t, p), cmd(t + 0.1, 2515)]
            t += 0.3
    ev.append({"at": round(t + 0.5, 2), "eval": "console.log('=== END')"})
    return ev
write("stake", stake_script())

# Yamamoto's core kit, batch 1 stage A (DUEL_YAMA_CORE "As built (batch 1 A)"; the browser path of the native trials in
# tests/trials/yamamoto-core.lisp): human P1 Yamamoto vs an idle Kenpachi (87000 + 10 x m), each pointer's NS a-b-c from 5 m (NS3
# from 1.8 m), J1-J3 > AS3 from 1.6 m, NS3a > TAIMATSU, and NS3a held (the Kikon). Read the combat log's `-> P2` / `ring` / `dome` /
# `KIKON` lines per `===` scene.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 40 --script tests/scripts/duel-yama-core.json
def yama_core_script():
    ev, t = [], T0
    def sp(s, hold=0.05):
        ev.append(key(s, "ShiftLeft")); ev.extend(tap(s + 0.01, "KeyJ", hold)); ev.append(key(s + hold + 0.03, "ShiftLeft", False))
    for name, c, ptr, presses in (("NS1 a-b-c", 87050, 87301, "sss"), ("NS2 a-b-c", 87050, 87302, "sss"),
                                  ("NS3 a-b-c", 87018, 87303, "sss"), ("J1-J3 AS3", 87016, 87301, "jjjsss"),
                                  ("NS3a SA", 87018, 87303, "sj"), ("NS3a held: Kikon", 87018, 87303, "H")):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev += [cmd(t, c), cmd(t + 0.05, ptr)]
        a = t + 0.3
        for p in presses:
            if p == "s": sp(a)
            elif p == "j": ev.extend(tap(a, "KeyJ", 0.05))
            else: sp(a, 1.2)
            a += 0.3
        t += 4.5
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-core", yama_core_script())

# Yamamoto's heat and 爆炎, batch 1 stage B (DUEL_YAMA_CORE "As built (stage B)"; the browser path of tests/trials/yamamoto-blaze.lisp):
# human P1 vs an idle Kenpachi. J1 hit from heat 0 (+8), NS3a from heat 40 (spends 25, x1.30: the HUD's heat strip, a still), heat 100
# (87600) enters 爆炎 at once in neutral (the pose; a still of the bared body and the 爆炎 strip), Reishi 10 in 爆炎 (87710: the drain
# held at 1, MIN 1 on the strip, a still), a free NS1a in 爆炎 (cost 0). Read the `HEAT` / `GOKUEN` / `SP` lines per `===` scene.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 32 --script tests/scripts/duel-yama-blaze.json
def yama_blaze_script():
    ev, t = [], T0
    def sp(s, hold=0.05):
        ev.append(key(s, "ShiftLeft")); ev.extend(tap(s + 0.01, "KeyJ", hold)); ev.append(key(s + hold + 0.03, "ShiftLeft", False))
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
    scene("J1 hit from heat 0", (87016, 87500)); ev.extend(tap(t + 0.3, "KeyJ", 0.05)); t += 2.5
    scene("NS3a from heat 40", (87018, 87303, 87540)); sp(t + 0.3); ev.append(shot(t + 1.5, "yama-heat")); t += 3.0
    scene("heat 100: GOKUEN in neutral", (87050, 87301, 87600)); ev.append(shot(t + 1.2, "yama-blaze")); t += 2.0
    scene("GOKUEN Reishi 10: the drain held at 1", (87710,)); ev.append(shot(t + 1.5, "yama-blaze-floor")); t += 2.5
    scene("GOKUEN NS1a free", (87050, 87301)); sp(t + 0.3); t += 3.0
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-blaze", yama_blaze_script())

# Yamamoto's Bankai, batch 1 stage C (DUEL_YAMA_CORE "As built (batch 1 C)"; the browser path of tests/trials/yamamoto-bankai.lisp, and
# the cinematics the native trials skip): human P1 vs an idle Kenpachi. The awakening from heat 40 (87440: the old yama-bankai-cine, a
# still on its card), the Bankai's plate (東 西 南, heat gone), 東 NS a-b-c from 3 m, J1-J3 > AS3 (mark 南), two marks by the pointer
# (87441 87443, a still), 北 armed (87444: the label 北 · TENCHI KAIJIN, a still), AS 北 after J1 held (the Kikon: yama-tenchi-cine, a still).
# Read the `AWAKEN` / `ZANKA` / `MARK` / `NORTH` / `-> P2` / `KIKON` lines per `===` scene. PHONE: the same on the deck (87901), stills -phone.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 34 --script tests/scripts/duel-yama-bankai.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 34 --mobile --size 390x844 --script tests/scripts/duel-yama-bankai-phone.json
def yama_bankai_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    def sp(s, hold=0.05):
        ev.append(key(s, "ShiftLeft")); ev.extend(tap(s + 0.01, "KeyJ", hold)); ev.append(key(s + hold + 0.03, "ShiftLeft", False))
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
    scene("awaken from the Shikai at heat 40", (87040, 87540, 87445) + ((87901,) if phone else ()) + (87440,))
    ev.append(shot(t + 1.4, "yama-bankai-cine" + sx)); ev.append(shot(t + 3.4, "yama-bankai" + sx)); t += 4.0
    scene("BANKAI east NS a-b-c", (87030, 87301)); sp(t + 0.3); sp(t + 0.6); sp(t + 0.9); t += 3.5
    scene("BANKAI J1-J3 AS3: mark south", (87014, 87301, 87445)); [ev.extend(tap(t + 0.3 + 0.25 * i, "KeyJ", 0.05)) for i in range(3)]
    sp(t + 1.1); sp(t + 1.4); sp(t + 1.7); t += 3.5
    scene("two marks by the pointer", (87040, 87445, 87441, 87443, 87900)); ev.append(shot(t + 0.6, "yama-marks" + sx)); t += 1.5
    scene("NORTH armed: the label", (87444, 87900)); ev.append(shot(t + 0.6, "yama-north" + sx)); t += 1.5
    scene("AS NORTH after J1, held: the Kikon", (87014, 87302, 87445, 87444)); ev.extend(tap(t + 0.3, "KeyJ", 0.05)); sp(t + 0.62, 1.4)
    ev.append(shot(t + 2.6, "yama-tenchi-cine" + sx)); t += 6.0
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-bankai", yama_bankai_script())
write("yama-bankai-phone", yama_bankai_script(True))

# Yamamoto's Bankai looks, art batch K1 (DUEL_YAMA_CORE §16): each look L1-L11 on its own segment (87420+i NS, 87430+i AS, P1 in the Bankai
# at once: 87446), P2 an idle Kenpachi placed so the footprint shows (k / 10 m: 87000+k), stills at the look's frames from the behind
# camera, then the same from the SIDE camera (2109). The awakening's two bursts (L11) come first in each pass (a fresh match in the
# Shikai: 87200 then 87040). 87448's consing line ends the run. PHONE: the deck on (87901), stills -phone.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 75 --script tests/scripts/duel-yama-k1.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 75 --mobile --size 390x844 --script tests/scripts/duel-yama-k1-phone.json
YAMA_K1 = (   # look, P2 metres, the segment's command, ((frames after it, still name) ...)
    ("hands", 6.0, 87426, ((30, "l1-hands-tell"), (41, "l1-hands"))),
    ("swarm", 9.0, 87427, ((50, "l2-swarm"),)),
    ("wall", 6.0, 87428, ((13, "l3-wall-rise"), (20, "l4-fall"), (50, "l3-wall"), (103, "l3-wall-crumble"))),
    ("pile", 2.0, 87435, ((16, "l5-pile-close"), (24, "l5-pile"))),
    ("void", 7.0, 87422, ((22, "l6-void"), (44, "l6-void-ash"))),
    ("notch", 3.0, 87430, ((14, "l6-notch"),)),
    ("lance", 8.0, 87420, ((22, "l7-lance"),)),
    ("flare", 3.0, 87423, ((18, "l8-flare"), (28, "l8-flare-2"))),
    ("armour", 2.0, 87437, ((4, "l9-armour"),)),
    ("north", 12.0, 87429, ((30, "l10-north"),)),
    ("crescent", 4.0, 87436, ((11, "l10-crescent"),)),
)
def yama_k1_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    deck = (87901,) if phone else ()
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
        return t + 0.05 * (len(cmds) - 1)
    for cam in ("behind", "side"):
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
        s0 = scene(f"L11 awakening {cam}", (87200, 87040, 87540, 87445) + deck + (87440,))
        ev.append(shot(s0 + 25 / 60, f"yama-k1-l11-in-{cam}{sx}")); ev.append(shot(s0 + 124 / 60, f"yama-k1-l11-burst-{cam}{sx}"))
        t += 3.5
        for look, m, c, shots in YAMA_K1:
            s0 = scene(f"{look} {cam}", (87000 + round(10 * m), 87446) + deck + (c,))
            for f, n in shots: ev.append(shot(s0 + f / 60, f"yama-k1-{n}-{cam}{sx}"))
            t += 2.2
    ev.append(cmd(t, 87448)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-k1", yama_k1_script())
write("yama-k1-phone", yama_k1_script(True))

# Yamamoto's Bankai art K2 (DUEL_YAMA_CORE §17): the stance triptych (pointer 1 / 2 / 3, then 87446: into the Bankai at once, the idle the
# pointer's stance) and the strikes in play, each from its link as the scripts land it (the clips' frame 0 keyed from the landing): 東 NS
# a-b-c from 3 m (NS1a's charge / hold / release / lance, NS1b's tell and hit, NS1c raised and on the floor), J1-J3 from 1.4 m (J1's charge,
# hold, hit and smear, J2 and J3 at their first frame and their hit), J1 > AS1 (its lift and the tap), from the behind camera, then the SIDE
# camera (2109). Frame offsets: a move starts on its press; an NS link lands at S+A (+8 f hitstop on a hit), a J link at S+A (+4), an AS at
# S+1 (+4). 87448's consing line ends the run. PHONE: the deck on (87901), stills -phone.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 70 --script tests/scripts/duel-yama-k2.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 70 --mobile --size 390x844 --script tests/scripts/duel-yama-k2-phone.json
def yama_k2_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    deck = (87901,) if phone else ()
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
        return t + 0.05 * (len(cmds) - 1)
    def sp(s): ev.append(key(s, "ShiftLeft")); ev.extend(tap(s + 0.01, "KeyJ", 0.05)); ev.append(key(s + 0.09, "ShiftLeft", False))
    def shots(a, frames, cam):
        for f, n in frames: ev.append(shot(a + f / 60, f"yama-k2-{n}-{cam}{sx}"))
    for cam in ("behind", "side"):
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
        for p, n in ((1, "higashi"), (2, "nishi"), (3, "minami")):
            s0 = scene(f"stance {n} {cam}", (87020, 87300 + p, 87446) + deck)
            ev.append(shot(s0 + 1.2, f"yama-k2-stance-{n}-{cam}{sx}")); t += 1.8
        s0 = scene(f"east NS a-b-c {cam}", (87030, 87301, 87446) + deck); a = s0 + 1.6   # (after the form's callout)
        for i in range(3): sp(a + 0.3 * i)
        a += 0.01
        shots(a, ((7, "ns1a-charge"), (14, "ns1a-held"), (18, "ns1a-release"), (20, "ns1a-lance"), (31 + 11, "ns1b-tell"),
                  (31 + 14, "ns1b-hit"), (57 + 12, "ns1c-raised"), (57 + 20, "ns1c-tip")), cam)
        t += 4.3
        s0 = scene(f"J1-J3 {cam}", (87014, 87301, 87446) + deck); a = s0 + 1.6   # (after the form's callout)
        for i in range(3): ev.extend(tap(a + 0.25 * i, "KeyJ", 0.05))
        shots(a, ((6, "j1-charge"), (11, "j1-held"), (14, "j1-hit"), (16, "j1-smear"), (21, "j2-first"), (28, "j2-hit"),
                  (35, "j3-first"), (43, "j3-hit")), cam)
        t += 3.8
        s0 = scene(f"J1 > AS1 {cam}", (87014, 87301, 87446) + deck); a = s0 + 1.6   # (after the form's callout)
        ev.extend(tap(a, "KeyJ", 0.05)); sp(a + 0.2)
        shots(a, ((19, "as1-first"), (26, "as1-lift"), (29, "as1-tap")), cam)
        t += 3.8
    ev.append(cmd(t, 87448)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-k2", yama_k2_script())
write("yama-k2-phone", yama_k2_script(True))

# Yamamoto's Bankai art K3 (DUEL_YAMA_CORE §18): 西, 南, 北 and the SA in play, each from its link as the scripts land it (the native trials'
# ticks: C4 西 NS a-b-c from 1.6 m, C7 J1 J2 > AS2 a-b, C5 南 NS a-b-c from 4 m, C8 J1-J3 > AS3 a-b-c, C11 北's NS (armed) from 6 m, C12 J1 >
# 北's AS, and the SA in 西 NSa's gap; scene names carry no quote: they go into a console.log('...')), each segment at its tell, its S and its end (frames after the first press; an NS link lands at S+A,
# +8 f a hitstop on a hit; a J link at S+A (+4), an AS at S+1 (+4); 西's flare stills at S+1, the flare's first drawn frame); then 西's armour (87437: the garb's mark, no yellow spark). From the
# behind camera, then the SIDE camera (2109). 87448's consing line ends the run. PHONE: the deck on (87901), stills -phone.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 110 --script tests/scripts/duel-yama-k3.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 110 --mobile --size 390x844 --script tests/scripts/duel-yama-k3-phone.json
YAMA_K3 = (   # scene, setup commands, presses (("j" | "sp", seconds after the start) ...), ((frame after the first press, still) ...)
    ("west NS a-b-c", (87016, 87302, 87445), (("sp", 0), ("sp", 0.3), ("sp", 0.9)),
     ((12, "ns2a-tell"), (17, "ns2a-s"), (34, "ns2a-pulse"), (44 + 7, "ns2b-tell"), (44 + 15, "ns2b-s"), (69 + 7, "ns2c-tell"),
      (69 + 12, "ns2c-s"), (69 + 12 + 8 + 18, "ns2c-end"), (44 + 14 + 8 + 2, "ns2b-end"), (44, "ns2a-end"))),
    ("J1 J2 > AS2 a-b", (87014, 87301, 87445), (("j", 0), ("j", 0.25), ("sp", 0.45), ("sp", 0.75)),
     ((33 + 4, "as2a-tell"), (33 + 9, "as2a-cocked"), (33 + 12, "as2a-s"), (56, "as2a-end"), (56 + 9, "as2b-tell"), (56 + 12, "as2b-s"),
      (56 + 12 + 8 + 18, "as2b-end"))),
    ("south NS a-b-c", (87040, 87303, 87445), (("sp", 0), ("sp", 0.4), ("sp", 0.8)),
     ((6, "ns3a-up"), (17, "ns3a-tell"), (22, "ns3a-s"), (34, "ns3a-end"), (47 + 8, "ns3b-tell"), (47 + 16, "ns3b-s"), (65, "ns3b-end"),
      (65 + 10, "ns3c-tell"), (65 + 18, "ns3c-s"), (65 + 34, "ns3c-end"))),
    ("J1-J3 > AS3 a-b-c", (87014, 87301, 87445), (("j", 0), ("j", 0.25), ("j", 0.5), ("sp", 0.75), ("sp", 1.05), ("sp", 1.35)),
     ((48 + 6, "as3a-tell"), (48 + 10, "as3a-s"), (69, "as3a-end"), (69 + 7, "as3b-tell"), (69 + 10, "as3b-s"), (89, "as3b-end"),
      (89 + 6, "as3c-tell"), (89 + 12, "as3c-s"), (89 + 12 + 8 + 20, "as3c-end"))),
    ("NORTH NS (armed)", (87060, 87302, 87445, 87444), (("sp", 0),),
     ((8, "n4ns-gather"), (15, "n4ns-tell"), (19, "n4ns-coil"), (24, "n4ns-s"), (40, "n4ns-end"))),
    ("J1 > NORTH AS (armed)", (87014, 87303, 87445, 87444), (("j", 0), ("sp", 0.2)),
     ((19 + 6, "n4as-tell"), (19 + 10, "n4as-s"), (19 + 10 + 8 + 20, "n4as-end"))),
    ("SA in the west NSa gap", (87016, 87302, 87445), (("sp", 0), ("j", 0.4)),
     ((44 + 1, "sa-tell"), (44 + 6, "sa-s"), (44 + 6 + 8 + 16, "sa-end"))),
    ("west armour", (87020, 87302, 87445), (), ()),
)
def yama_k3_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    deck = (87901,) if phone else ()
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
        return t + 0.05 * (len(cmds) - 1)
    def sp(s): ev.append(key(s, "ShiftLeft")); ev.extend(tap(s + 0.01, "KeyJ", 0.05)); ev.append(key(s + 0.09, "ShiftLeft", False))
    for cam in ("behind", "side"):
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
        for name, cmds, presses, shots in YAMA_K3:
            s0 = scene(f"{name} {cam}", cmds[:2] + (87446,) + cmds[2:] + deck)   # (the pointer, into the Bankai at once, the marks)
            a = s0 + 1.6                                                        # (after the form's callout)
            for kind, dt in presses:
                if kind == "sp": sp(a + dt)
                else: ev.extend(tap(a + dt, "KeyJ", 0.05))
            a += 0.01
            for f, n in shots: ev.append(shot(a + f / 60, f"yama-k3-{n}-{cam}{sx}"))
            if name == "west armour":
                ev.append(cmd(a, 87437)); ev.append(shot(a + 4 / 60, f"yama-k3-armour-{cam}{sx}"))
            t += 4.0
    ev.append(cmd(t, 87448)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-k3", yama_k3_script())
write("yama-k3-phone", yama_k3_script(True))

# Yamamoto's Bankai art K4 (DUEL_YAMA_CORE §19): the 東 / 西 / 南 Kikon cinematics landed in play, the proof that they move no sim line
# but the ones a cinematic's length moves (the debug commands exist at 3173bf43 too, so the same script runs on a dist built there and
# its log can be diffed line by line). Each scene a fresh match (87200 then 87014: the opponent changes twice), human P1 in the Bankai
# 1.4 m from an idle Kenpachi, then the route held into its Kikon: J1 > AS1 (東), J1 J2 > AS2 (西), J1-J3 > AS3 (南); probe lines and a
# hash line after the cinematic and the reset; the t=600 hash line lands after every cinematic. Last, 2101 (2 Konpaku a match from the
# next) and the 西 route again: its Kikon is the K.O. (the match-over path, the K.O. cinematic, RESULTS).
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 62 --script tests/scripts/duel-yama-k4-kikon.json
YAMA_K4_KIKON = (   # scene, pointer, presses (("j" | "hold", seconds after the start) ...)
    ("east J1 > AS1 held", 87301, (("j", 0), ("hold", 0.2))),
    ("west J1 J2 > AS2 held", 87302, (("j", 0), ("j", 0.25), ("hold", 0.45))),
    ("south J1-J3 > AS3 held", 87303, (("j", 0), ("j", 0.25), ("j", 0.5), ("hold", 0.75))),
    ("west again from 2 Konpaku: the K.O.", 87302, (("j", 0), ("j", 0.25), ("hold", 0.45))),
)
def yama_k4_kikon_script():
    ev, t = [], T0
    def sp(s, hold): ev.append(key(s, "ShiftLeft")); ev.extend(tap(s + 0.01, "KeyJ", hold)); ev.append(key(s + hold + 0.03, "ShiftLeft", False))
    for name, ptr, presses in YAMA_K4_KIKON:
        if name.startswith("west again"): ev.append(cmd(t - 0.3, 2101))
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        cmds = (87200, 87014, ptr, 87446, 87445)
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
        a = t + 0.05 * (len(cmds) - 1) + 1.6                                # (after the form's callout)
        for kind, dt in presses:
            if kind == "hold": sp(a + dt, 1.2)
            else: ev.extend(tap(a + dt, "KeyJ", 0.05))
        for dt in (1.0, 5.0, 8.0): ev.append(cmd(a + dt, 87900))
        ev.append(cmd(a + 8.1, 2107))
        t += 12.0
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-k4-kikon", yama_k4_kikon_script())

# Yamamoto's Bankai art K4 (DUEL_YAMA_CORE §19): one still per storyboard beat of each Kikon cinematic (87450+i from frame 0, P1 in the
# Bankai 3 m from an idle Kenpachi set down mid-stage, after 2.5 s idle in the Bankai (87030, 87446 the first time); 87600+k holds it at frame 2k, the
# still a moment after it gets there, then the next hold). 87448's consing line ends the run. PHONE: the deck on (87901), stills -phone.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 50 --script tests/scripts/duel-yama-k4.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 50 --mobile --size 390x844 --script tests/scripts/duel-yama-k4-phone.json
YAMA_K4 = (   # cinematic, name, ((frame (even), beat still) ...)
    (0, "higashi", ((6, "b0-held"), (30, "b1-caption"), (56, "b2-tap"), (74, "b3-nothing"), (96, "b4-void"), (120, "b5-shatter"),
                    (150, "b6-hang"))),
    (1, "nishi", ((6, "b0-held"), (30, "b1-strike"), (46, "b2-ash"), (62, "b3-ignite"), (100, "b4-walk"), (128, "b5-pass"),
                  (146, "b6-column"), (170, "b7-wide"))),
    (2, "minami", ((6, "b0-held"), (32, "b1-words"), (52, "b2-plant"), (84, "b3-dead"), (122, "b4-back"), (144, "b5-burst"),
                   (172, "b6-wide"))),
)
def yama_k4_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    for i, name, beats in YAMA_K4:
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev += [cmd(t, 87030)] + ([cmd(t + 0.05, 87446)] if i == 0 else [])   # (idle in the Bankai first: the form's callout gone)
        t += 2.5
        ev.append(cmd(t, 87450 + i))
        if phone: ev.append(cmd(t + 0.02, 87901))
        ev.append(cmd(t + 0.03, 87600 + beats[0][0] // 2))
        a, f0 = t + 0.03, 0
        for j, (f, n) in enumerate(beats):
            a += (f - f0) / 60 + 0.3                                         # (it runs on to frame f, then a still)
            ev.append(shot(a, f"yama-k4-{name}-{n}{sx}"))
            if j + 1 < len(beats): ev.append(cmd(a + 0.05, 87600 + beats[j + 1][0] // 2))
            a += 0.05
            f0 = f
        t = a + 0.6
    ev.append(cmd(t, 87448)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-k4", yama_k4_script())
write("yama-k4-phone", yama_k4_script(True))

# Yamamoto's 西 Kikon re-boarded (DUEL_YAMA_CORE §29, retimed §29.3: 272 f): K4's holds (87451, 87600+k; frames over 198: 87810+k) at the
# board's frames: the strike, the ash, the leap back, the walk at 南's pace with each footfall's garb step (115 / 164 / 213, the frame
# before and after), the flash behind him (216), the column, the shatter (226), the wide. Stills
# tests/shots/duel-yama-nishi2-fNNN[-phone].png; 87448's consing line ends the run.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 30 --script tests/scripts/duel-yama-nishi2.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 30 --mobile --size 390x844 --script tests/scripts/duel-yama-nishi2-phone.json
YAMA_NISHI2 = (20, 46, 56, 64, 90, 112, 118, 140, 162, 166, 190, 212, 218, 228, 236, 262)
def yama_hold(f): return 87600 + f // 2 if f <= 198 else 87810 + f // 2   # (87601-87699: frames 2-198; 87910-87999: 200-378)
def yama_nishi2_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    ev += [cmd(t, 87030), cmd(t + 0.05, 87446)]                              # (idle in the Bankai first: the form's callout gone)
    t += 2.5
    ev.append(cmd(t, 87451))
    if phone: ev.append(cmd(t + 0.02, 87901))
    ev.append(cmd(t + 0.03, yama_hold(YAMA_NISHI2[0])))
    a, f0 = t + 0.03, 0
    for j, f in enumerate(YAMA_NISHI2):
        a += (f - f0) / 60 + 0.3
        ev.append(shot(a, f"yama-nishi2-f{f:03d}{sx}"))
        if j + 1 < len(YAMA_NISHI2): ev.append(cmd(a + 0.05, yama_hold(YAMA_NISHI2[j + 1])))
        a += 0.05
        f0 = f
    t = a + 0.6
    ev.append(cmd(t, 87448)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-nishi2", yama_nishi2_script())
write("yama-nishi2-phone", yama_nishi2_script(True))

# Yamamoto's 西 garb trailing (DUEL_YAMA_CORE §29.1): P1 in the Bankai under 西 (87302, 87446), Kenpachi 8 m away (87080), W held 1.2 s
# then let go; stills mid-walk, just stopped, the overshoot (+0.3 s) and settled (+1.0 s), from the behind camera, then the SIDE camera
# (2109); then the 西 Kikon's walk at its footfalls 116 / 164 / 212 (87451, 87600+k; §29.3's retiming), each shot 2 frames after the hold (a held frame stands
# still: the spring settles). Stills tests/shots/duel-yama-lean-*[-phone].png; 87448's consing line ends the run.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 34 --script tests/scripts/duel-yama-lean.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 34 --mobile --size 390x844 --script tests/scripts/duel-yama-lean-phone.json
YAMA_LEAN_WALK = ((1.0, "walk"), (1.23, "stop"), (1.5, "over"), (2.2, "settled"))
def yama_lean_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    deck = (87901,) if phone else ()
    for cam in ("behind", "side"):
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== walk {cam}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate((87080, 87302, 87446) + deck))
        t += 1.6
        ev += [key(t, "KeyW"), key(t + 1.2, "KeyW", False)]
        ev.extend(shot(t + dt, f"yama-lean-{cam}-{n}{sx}") for dt, n in YAMA_LEAN_WALK)
        t += 3.0
    ev.append(cmd(t, 2109)); t += 0.3                                     # (back to the behind camera)
    ev.append({"at": round(t - 0.05, 2), "eval": "console.log('=== nishi')"})
    ev += [cmd(t, 87030)]
    t += 2.5
    ev.append(cmd(t, 87451))
    if phone: ev.append(cmd(t + 0.02, 87901))
    frames = (116, 164, 212)
    ev.append(cmd(t + 0.03, yama_hold(frames[0])))
    a, f0 = t + 0.03, 0
    for j, f in enumerate(frames):
        a += (f - f0) / 60 + 0.03
        ev.append(shot(a, f"yama-lean-kikon-f{f:03d}{sx}"))
        if j + 1 < len(frames): ev.append(cmd(a + 0.02, yama_hold(frames[j + 1])))
        a += 0.02
        f0 = f
    t = a + 0.6
    ev.append(cmd(t, 87448)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-lean", yama_lean_script())
write("yama-lean-phone", yama_lean_script(True))

# Yamamoto's Bankai art K5 (DUEL_YAMA_CORE §20.1): the 東 void as a ragged radial tear, every place it shows. L6 in play (K2's scenes):
# 東 NS a-b-c from 3 m, NS1c's void at its S18+2 / +6 / +14 / +26 (growing, full, held, filling with ash), J1 > AS1's notch at its S10
# +0 / +4 / +11; from the behind camera, then the SIDE camera (2109); then the K4 東 cinematic's frames 90 (opening), 96 (b4-void), 120
# (b5-shatter), 150 (b6-hang) (K4's holds: 87450, 87600+k). 87448's consing line ends the run. PHONE: the deck on (87901), stills -phone.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 40 --script tests/scripts/duel-yama-k5.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 40 --mobile --size 390x844 --script tests/scripts/duel-yama-k5-phone.json
def yama_k5_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    deck = (87901,) if phone else ()
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
        return t + 0.05 * (len(cmds) - 1)
    def sp(s): ev.append(key(s, "ShiftLeft")); ev.extend(tap(s + 0.01, "KeyJ", 0.05)); ev.append(key(s + 0.09, "ShiftLeft", False))
    def shots(a, frames, cam):
        for f, n in frames: ev.append(shot(a + f / 60, f"yama-k5-{n}-{cam}{sx}"))
    for cam in ("behind", "side"):
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
        s0 = scene(f"east NS a-b-c {cam}", (87030, 87301, 87446) + deck); a = s0 + 1.6
        for i in range(3): sp(a + 0.3 * i)
        a += 0.01
        shots(a, ((57 + 20, "void-grow"), (57 + 24, "void-full"), (57 + 32, "void-held"), (57 + 44, "void-fill")), cam)
        t += 4.3
        s0 = scene(f"J1 > AS1 {cam}", (87014, 87301, 87446) + deck); a = s0 + 1.6
        ev.extend(tap(a, "KeyJ", 0.05)); sp(a + 0.2)
        shots(a, ((29, "notch-first"), (33, "notch-full"), (40, "notch-held")), cam)
        t += 3.8
    ev.append({"at": round(t - 0.05, 2), "eval": "console.log('=== higashi')"})
    ev += [cmd(t, 87030), cmd(t + 0.05, 87446)]   # (idle in the Bankai first: the form's callout gone)
    t += 2.5
    ev.append(cmd(t, 87450))
    if phone: ev.append(cmd(t + 0.02, 87901))
    beats = ((90, "cine-open"), (96, "cine-b4-void"), (120, "cine-b5-shatter"), (150, "cine-b6-hang"))
    ev.append(cmd(t + 0.03, 87600 + beats[0][0] // 2))
    a, f0 = t + 0.03, 0
    for j, (f, n) in enumerate(beats):
        a += (f - f0) / 60 + 0.3
        ev.append(shot(a, f"yama-k5-{n}{sx}"))
        if j + 1 < len(beats): ev.append(cmd(a + 0.05, 87600 + beats[j + 1][0] // 2))
        a += 0.05
        f0 = f
    t = a + 0.6
    ev.append(cmd(t, 87448)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-k5", yama_k5_script())
write("yama-k5-phone", yama_k5_script(True))

# Yamamoto's Shikai art S1 (DUEL_YAMA_CORE §21.2, §22): every look SL0-SL9 in play. Each segment started on its own (87410+i NS1a-NS2c,
# 87416+i NS3a-c / the SA, 87460 AS1) in a fresh placement (87000+k: Kenpachi k / 10 m away), the heat set first (87500+h) at 0 / 12 /
# 25 (T0 / T1 / T2) for the NS looks; the ring, the SA and AS1 pay none (T0 by rule: one heat). Stills at move frames (the frame after
# the start command is sf 1; a hit freezes sf for the hitstop: the late frames are counted past it). The behind camera, then the SIDE
# camera (2109). Then J1-J2-J3 (the smear, J3's pommel), the three stances at rest (SL0, none in 撫斬's), 爆炎 (87600: heat 100, its entry
# pose, then its NS1a and its SA at 3.2 m). Last the footprints from above (87480 the top-down camera, 87481 the sim footprints in cyan)
# at heat 0 and 25 (landscape only), and the consing lines (87449 the Shikai's looks, 87448 the Bankai's). PHONE: the deck on (87901).
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 330 --script tests/scripts/duel-yama-s1.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 300 --mobile --size 390x844 --script tests/scripts/duel-yama-s1-phone.json
YAMA_S1 = (   # look, setup (scene, pointer), start command, by heat?, ((frame, still) ...)
    ("spiral", (87080, 87301), 87410, True, ((30, "spiral-a"), (44, "spiral-b"))),
    ("column", (87050, 87301), 87411, True, ((22, "column-tell"), (29, "column-erupt"), (46, "column-late"))),
    ("tornado", (87080, 87301), 87412, True, ((28, "tornado-a"), (44, "tornado-b"))),
    ("lance", (87090, 87302), 87413, True, ((24, "lance-tied"), (36, "lance-b"))),
    ("dome", (87050, 87302), 87415, True, ((19, "dome-hit"), (36, "dome-hold"), (58, "dome-open"))),
    ("nadegiri", (87018, 87303), 87418, True, ((16, "nade-cut"), (48, "nade-seam"), (56, "nade-late"))),
    ("ring", (87050, 87302), 87414, False, ((18, "ring-coil"), (46, "ring-full"))),
    ("sa", (87020, 87301), 87419, False, ((14, "sa-ignite"), (17, "sa-hit"), (29, "sa-fade"))),
    ("as1", (87016, 87301), 87460, False, ((11, "as1-burst"), (14, "as1-late"))),
)
YAMA_S1_TOP = (("spiral", (87080, 87301), 87410, 44), ("column", (87050, 87301), 87411, 29), ("tornado", (87080, 87301), 87412, 44),
               ("lance", (87090, 87302), 87413, 36), ("dome", (87050, 87302), 87415, 36), ("ring", (87050, 87302), 87414, 46),
               ("sa", (87020, 87301), 87419, 17))
def yama_s1_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    deck = (87901,) if phone else ()
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
        return t + 0.05 * (len(cmds) - 1)
    for cam in ("behind", "side"):
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
        for look, setup, start, by_heat, frames in YAMA_S1:
            for h in ((0, 12, 25) if by_heat else (0,)):
                a = scene(f"{look} heat {h} {cam}", setup + (87500 + h,) + deck) + 0.3
                ev.append(cmd(a, start))
                for f, n in frames: ev.append(shot(a + f / 60, f"yama-s1-{n}{'-h%d' % h if by_heat else ''}-{cam}{sx}"))
                t = a + 1.4
        a = scene(f"J1 J2 J3 {cam}", (87014, 87301, 87500) + deck) + 0.3   # (the presses as K2's: J at 0, 0.25, 0.5 s)
        for dt in (0, 0.25, 0.5): ev.extend(tap(a + dt, "KeyJ", 0.05))
        for f, n in ((16, "j1-smear"), (44, "j3-a"), (46, "j3-b"), (48, "j3-c")): ev.append(shot(a + f / 60, f"yama-s1-{n}-{cam}{sx}"))
        t = a + 1.6
        for p in (1, 2, 3):
            a = scene(f"stance {p} {cam}", (87030, 87300 + p) + deck)
            ev.append(shot(a + 0.6, f"yama-s1-rest-p{p}-{cam}{sx}")); t = a + 0.8
        a = scene(f"blaze {cam}", (87050, 87301, 87600) + deck)
        ev.append(shot(a + 1.0, f"yama-s1-blaze-rest-{cam}{sx}"))
        ev.append(cmd(a + 1.2, 87470)); ev.append(shot(a + 1.2 + 30 / 60, f"yama-s1-blaze-spiral-{cam}{sx}"))
        t = a + 2.4
        a = scene(f"blaze SA {cam}", (87020,) + deck) + 0.2
        ev.append(cmd(a, 87479)); ev.append(shot(a + 17 / 60, f"yama-s1-blaze-sa-{cam}{sx}"))
        t = a + 1.0
        a = scene(f"blaze out {cam}", (87050, 87500))                                  # (heat 0: back to the Shikai at his next neutral)
        t = a + 1.2
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
    if not phone:
        for look, setup, start, f in YAMA_S1_TOP:
            for h in ((0, 25) if look not in ("ring", "sa") else (0,)):
                a = scene(f"top {look} heat {h}", setup + (87500 + h, 87480, 87481) + ((2103,) if look == "sa" else ())) + 0.3
                ev.append(cmd(a, start)); ev.append(shot(a + f / 60, f"yama-s1-top-{look}-h{h}"))
                ev.extend((cmd(a + f / 60 + 0.05, 87480), cmd(a + f / 60 + 0.1, 87481)))
                if look == "sa": ev.append(cmd(a + f / 60 + 0.15, 2103))
                t = a + f / 60 + 0.6
    ev.append(cmd(t, 87449)); t += 0.3
    ev.append(cmd(t, 87448)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-s1", yama_s1_script())
write("yama-s1-phone", yama_s1_script(True))

# Yamamoto's Shikai art S2 (DUEL_YAMA_CORE §21.3, §23): the stance triptych (pointer 1 / 2 / 3 at rest: 87300+p, Kenpachi 3 m away), then
# each re-keyed or new clip in play at its frames: pointer 1's segments on their own (87410-87412 NS1a-c, 87460 AS1; the frame after the
# start command is sf 1), J1 alone (87401: a J press), J1 J2 J3 by presses (K2's frame offsets: a J link lands at S+A, +4 f a hitstop on a
# hit) and J1 > AS1 (the AS at J1's S+1, +4). Kenpachi 10 m away for the segments on their own (no hit: no hitstop freezes the frames),
# 1.4 m for the strings. The behind camera, then the SIDE camera (2109). Last the consing lines (87449 the Shikai's looks, 87448 the
# Bankai's). PHONE: the deck on (87901), stills -phone.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 120 --script tests/scripts/duel-yama-s2.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 120 --mobile --size 390x844 --script tests/scripts/duel-yama-s2-phone.json
YAMA_S2 = (   # scene, setup commands, start ("cmd" c | presses ((kind, seconds) ...)), ((frame, still) ...)
    ("NS1a", (87100, 87301), ("cmd", 87410), ((7, "ns1a-gather"), (14, "ns1a-coiled"), (18, "ns1a-held"), (21, "ns1a-release"), (22, "ns1a-s"),
                                             (24, "ns1a-land"))),
    ("NS1b", (87100, 87301), ("cmd", 87411), ((3, "ns1b-drop"), (10, "ns1b-tell"), (14, "ns1b-level"), (16, "ns1b-s"), (29, "ns1b-top"))),
    ("NS1c", (87100, 87301), ("cmd", 87412), ((3, "ns1c-behind"), (6, "ns1c-left"), (9, "ns1c-ahead"), (12, "ns1c-right"), (15, "ns1c-held"),
                                             (17, "ns1c-fling"), (18, "ns1c-s"))),
    ("AS1", (87100, 87301), ("cmd", 87460), ((1, "as1-first"), (6, "as1-coil"), (8, "as1-held"), (9, "as1-thrust"), (10, "as1-s"))),
    ("J1", (87100, 87301), ("cmd", 87401), ((5, "j1-charge"), (9, "j1-cocked"), (11, "j1-held"), (13, "j1-release"), (14, "j1-s"), (15, "j1-thru"))),
    ("J1 J2 J3", (87014, 87301), (("j", 0), ("j", 0.25), ("j", 0.5)), ((21, "j2-first"), (29, "j2-s"), (36, "j3-first"), (40, "j3-wind"), (45, "j3-s"))),
    ("J1 > AS1", (87014, 87301), (("j", 0), ("sp", 0.2)), ((19, "as1-link-first"), (26, "as1-link-coil"), (29, "as1-link-s"))),
)
def yama_s2_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    deck = (87901,) if phone else ()
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
        return t + 0.05 * (len(cmds) - 1)
    def sp(s): ev.append(key(s, "ShiftLeft")); ev.extend(tap(s + 0.01, "KeyJ", 0.05)); ev.append(key(s + 0.09, "ShiftLeft", False))
    for cam in ("behind", "side"):
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
        for p in (1, 2, 3):
            a = scene(f"stance {p} {cam}", (87030, 87300 + p) + deck)
            ev.append(shot(a + 1.2, f"yama-s2-stance-{p}-{cam}{sx}")); t = a + 1.5
        for name, setup, start, frames in YAMA_S2:
            a = scene(f"{name} {cam}", setup + deck) + 0.5
            if start[0] == "cmd": ev.append(cmd(a, start[1]))
            else:
                for kind, dt in start:
                    if kind == "sp": sp(a + dt)
                    else: ev.extend(tap(a + dt, "KeyJ", 0.05))
                a += 0.01
            for f, n in frames: ev.append(shot(a + f / 60, f"yama-s2-{n}-{cam}{sx}"))
            t = a + 2.0
    ev.append(cmd(t, 87449)); t += 0.3
    ev.append(cmd(t, 87448)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-s2", yama_s2_script())
write("yama-s2-phone", yama_s2_script(True))

# Yamamoto's Shikai art S3 (DUEL_YAMA_CORE §21.3, §24): each new or re-keyed clip in play at its frames, on its own (87413-87415 NS2a-c,
# 87416-87419 NS3a-c and the SA, 87461-87465 AS2a / b, AS3a / b / c; the frame after the start command is sf 1; Kenpachi 10 m away: no hit,
# no hitstop), then the stance looks (pointer 1's corkscrew, pointer 2's drip) at heat 0 / 12 / 25, two phases each. The behind camera, then the SIDE camera (2109). Last the consing lines
# (87449 the Shikai's looks, 87448 the Bankai's). PHONE: the deck on (87901), stills -phone.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 150 --script tests/scripts/duel-yama-s3.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 150 --mobile --size 390x844 --script tests/scripts/duel-yama-s3-phone.json
YAMA_S3 = (   # scene, pointer, start command, ((frame, still) ...)
    ("NS2a", 87302, 87413, ((6, "ns2a-cock"), (12, "ns2a-cocked"), (16, "ns2a-held"), (19, "ns2a-release"), (20, "ns2a-s"), (22, "ns2a-land"))),
    ("NS2b", 87302, 87414, ((2, "ns2b-first"), (5, "ns2b-c1"), (7, "ns2b-c2"), (9, "ns2b-c3"), (11, "ns2b-c4"), (16, "ns2b-s"))),
    ("NS2c", 87302, 87415, ((4, "ns2c-rise"), (8, "ns2c-up"), (12, "ns2c-held"), (16, "ns2c-chop"), (18, "ns2c-s"), (30, "ns2c-rec"))),
    ("AS2a", 87302, 87461, ((3, "as2a-first"), (8, "as2a-cock"), (11, "as2a-flick"), (12, "as2a-s"), (14, "as2a-thru"))),
    ("AS2b", 87302, 87462, ((8, "as2b-up"), (18, "as2b-s"))),
    ("NS3a", 87303, 87416, ((6, "ns3a-pull"), (12, "ns3a-low"), (15, "ns3a-held"), (17, "ns3a-jab"), (18, "ns3a-s"), (21, "ns3a-land"))),
    ("NS3b", 87303, 87417, ((5, "ns3b-wind"), (9, "ns3b-held"), (11, "ns3b-cut"), (12, "ns3b-s"), (14, "ns3b-thru"))),
    ("NS3c", 87303, 87418, ((5, "ns3c-settle"), (11, "ns3c-still"), (13, "ns3c-snap"), (14, "ns3c-s"), (16, "ns3c-thru"), (28, "ns3c-lower"),
                            (42, "ns3c-away"))),
    ("AS3a", 87303, 87463, ((3, "as3a-cock"), (8, "as3a-s"), (10, "as3a-pull"))),
    ("AS3b", 87303, 87464, ((3, "as3b-flip"), (7, "as3b-low"), (10, "as3b-s"), (12, "as3b-high"))),
    ("AS3c", 87303, 87465, ((6, "as3c-settle"), (14, "as3c-s"))),
    ("SA", 87301, 87419, ((3, "sa-tell"), (5, "sa-right-front"), (7, "sa-right"), (9, "sa-behind-right"), (11, "sa-behind"), (13, "sa-left"),
                          (15, "sa-left-front"), (16, "sa-s"))),
)
def yama_s3_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    deck = (87901,) if phone else ()
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
        return t + 0.05 * (len(cmds) - 1)
    for cam in ("behind", "side"):
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
        for name, ptr, start, frames in YAMA_S3:
            a = scene(f"{name} {cam}", (87100, ptr) + deck) + 0.5
            ev.append(cmd(a, start))
            for f, n in frames: ev.append(shot(a + f / 60, f"yama-s3-{n}-{cam}{sx}"))
            t = a + 1.6
        for p in (1, 2):
            for h in (0, 12, 25):
                a = scene(f"stance {p} heat {h} {cam}", (87030, 87300 + p, 87500 + h) + deck)
                ev.append(shot(a + 0.8, f"yama-s3-stance-{p}-h{h}-a-{cam}{sx}")); ev.append(shot(a + 1.4, f"yama-s3-stance-{p}-h{h}-b-{cam}{sx}"))
                t = a + 1.6
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
    ev.append(cmd(t, 87500)); t += 0.3
    ev.append(cmd(t, 87449)); t += 0.3
    ev.append(cmd(t, 87448)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-s3", yama_s3_script())
write("yama-s3-phone", yama_s3_script(True))
# The Kikon strike (art S3: ya-strike, J1's poses with a 0.25 m drawn lunge): NS1a pressed with the SP held, Kenpachi 3 m away: the spiral
# hits, he flash-steps in and cuts (YA-NS-STRIKE, its hit ~1.5 s after the press); a burst of stills every 3 frames from 0.9 s, both cameras.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 30 --script tests/scripts/duel-yama-s3-strike.json   (+ -phone, --mobile --size 390x844)
def yama_s3_strike_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    deck = (87901,) if phone else ()
    for cam in ("behind", "side"):
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== NS1a held: the Kikon strike {cam}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate((87030, 87301) + deck))
        a = t + 0.5
        ev.append(key(a, "ShiftLeft")); ev.extend(tap(a + 0.01, "KeyJ", 1.4)); ev.append(key(a + 1.45, "ShiftLeft", False))
        for i in range(24): ev.append(shot(a + 0.9 + i * 0.05, f"yama-s3-strike-{i:02d}-{cam}{sx}"))
        t = a + 3.5
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-s3-strike", yama_s3_strike_script())
write("yama-s3-strike-phone", yama_s3_strike_script(True))

# Yamamoto's 爆炎 art S4 (DUEL_YAMA_CORE §21.4, §25): P1 in 爆炎 (87600: it enters at his next neutral, the entry pose 24 f), each look in
# play: the scars, blade and stance at heat 100 / 50 / 10 (87500+h right before the still: 爆炎 decays 10 a second), J1 J2 IKKOTSU by
# presses (Kenpachi 1.4 m: S2's frame offsets), the entry pose itself (87600 from the Shikai's stance), the tornado's lean (87472, then
# 87490 moves Kenpachi 3 m to P1's right), NS2b's ring closing before its dome (87474), ENNETSU's rows (87475), the true NADEGIRI (87478);
# the behind camera then the SIDE camera (2109); from above (87480 + 87481, landscape only) ENNETSU and the tornado. Last the consing line
# (87449). PHONE: the deck on (87901), stills -phone.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 130 --script tests/scripts/duel-yama-s4.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 130 --mobile --size 390x844 --script tests/scripts/duel-yama-s4-phone.json
YAMA_S4 = (   # scene, setup (after 爆炎's entry), start command, ((frame, still) ...)
    ("entry", (87030, 87301), 87600, ((3, "entry-f03"), (6, "entry-f06"), (9, "entry-f09"), (12, "entry-f12"), (16, "entry-f16"),
                                      (19, "entry-f19"), (23, "entry-f23"))),
    ("tornado", (87100, 87301), 87472, ((18, "tornado-s"), (34, "tornado-lean-a"), (44, "tornado-lean-b"))),
    ("ring close", (87050, 87302), 87474, ((12, "ring-f12"), (14, "ring-f14"), (15, "ring-f15"), (16, "ring-s"), (24, "ring-f24"))),
    ("ennetsu", (87100, 87302), 87475, ((10, "ennetsu-cock"), (18, "ennetsu-s"), (24, "ennetsu-f24"), (30, "ennetsu-f30"), (40, "ennetsu-f40"),
                                        (58, "ennetsu-f58"))),
    ("nadegiri", (87030, 87303), 87478, ((14, "nade-s"), (30, "nade-f30"), (42, "nade-f42"), (50, "nade-f50"), (58, "nade-f58"),
                                         (70, "nade-f70"), (77, "nade-f77"))),
)
YAMA_S4_TOP = (("ennetsu", (87100, 87302), 87475, (18, 30, 40)), ("tornado", (87100, 87301), 87472, (30,)))
def yama_s4_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    deck = (87901,) if phone else ()
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
        return t + 0.05 * (len(cmds) - 1)
    for cam in ("behind", "side"):
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
        for h in (100, 50, 10):                      # the scars, the blade, the stance by heat
            a = scene(f"heat {h} {cam}", (87030, 87301, 87600) + deck) + 1.0
            ev.append(cmd(a, 87500 + h)); ev.append(shot(a + 0.05, f"yama-s4-heat-{h}-{cam}{sx}"))
            if h == 10: ev.append(shot(a + 0.13, f"yama-s4-heat-{h}b-{cam}{sx}"))
            t = a + 0.5
        a = scene(f"J1 J2 IKKOTSU {cam}", (87014, 87301, 87600) + deck) + 1.0   # (the presses as S2's: J at 0, 0.25, 0.5 s)
        for dt in (0, 0.25, 0.5): ev.extend(tap(a + dt, "KeyJ", 0.05))
        for f, n in ((15, "j1-trail"), (29, "j2-trail"), (36, "ikk-first"), (38, "ikk-plant"), (42, "ikk-chamber"), (45, "ikk-s"), (48, "ikk-a"),
                     (56, "ikk-back"), (61, "ikk-hilt")):
            ev.append(shot(a + f / 60, f"yama-s4-{n}-{cam}{sx}"))
        t = a + 1.8
        for name, setup, start, frames in YAMA_S4:
            if name == "entry":
                a = scene(f"{name} {cam}", (87500,) + setup + deck) + 0.6
            else:
                a = scene(f"{name} {cam}", setup + (87600,) + deck) + 0.8
            ev.append(cmd(a, start))
            if name == "tornado": ev.append(cmd(a + 22 / 60, 87490))
            for f, n in frames: ev.append(shot(a + f / 60, f"yama-s4-{n}-{cam}{sx}"))
            t = a + max(f for f, n in frames) / 60 + 0.8
        a = scene(f"out {cam}", (87050, 87500)); t = a + 1.0                       # (heat 0: back to the Shikai)
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
    if not phone:
        for name, setup, start, frames in YAMA_S4_TOP:
            for f in frames:
                a = scene(f"top {name} f{f}", setup + (87600, 87480, 87481)) + 0.8
                ev.append(cmd(a, start))
                if name == "tornado": ev.append(cmd(a + 22 / 60, 87490))
                ev.append(shot(a + f / 60, f"yama-s4-top-{name}-f{f}"))
                ev.extend((cmd(a + f / 60 + 0.05, 87480), cmd(a + f / 60 + 0.1, 87481)))
                t = a + f / 60 + 0.8
        a = scene("out top", (87050, 87500)); t = a + 1.0
    ev.append(cmd(t, 87600)); t += 0.8
    ev.append(cmd(t, 87449)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-s4", yama_s4_script())
write("yama-s4-phone", yama_s4_script(True))

# The soft flame's prototype strips (batch F1, docs/style/STYLE_STORM_DESIGN.md §15): one run per candidate c (88000+c first: 0 the
# current look, 1-3 the feather x glow rows), the same timeline in every run, so the rows differ only by the candidate. Each subject:
# 8 consecutive frames (shots held at the middle of frames n .. n+7 of the fixed 60 Hz clock): (a) Kenpachi's REIATSU aura idle
# (84000), (b) 爆炎's ENNETSU pillars (87475, frames 30-37), (c) the Shikai's stance-1 blade fire (87030 87500 87301: heat 0, out of 爆炎), (d) the Bankai's
# 西 stance garb (87446 87302). PHONE: --mobile --size 390x844, (a) and (b) only.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 40 --script tests/scripts/duel-soft-flame-c0.json   (c0..c3, + -phone)
def soft_flame_script(c, phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    def fshot(a, n, name): return {"at": round((round(a * 60) + n + 0.5) / 60, 5), "shot": f"{SHOTS}softflame-{name}-c{c}-f{n}{sx}.png"}
    ev.append(cmd(t - 0.5, 88000 + c))
    scenes = [("aura", (84000,), None, 1.5), ("ennetsu", (87100, 87302, 87600), 87475, 30 / 60)]
    if not phone: scenes += [("stance1", (87030, 87500, 87301), None, 1.5), ("west", (87030, 87446, 87302), None, 1.5)]
    for name, setup, start, wait in scenes:
        ev.extend(cmd(t + 0.05 * i, x) for i, x in enumerate(setup))
        a = t + 0.05 * len(setup) + 0.8
        if start: ev.append(cmd(a, start))
        b = a + wait
        ev.extend(fshot(b, n, name) for n in range(8))
        t = b + 0.6
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
for c in range(4):
    write(f"soft-flame-c{c}", soft_flame_script(c))
    write(f"soft-flame-c{c}-phone", soft_flame_script(c, True))
# Yamamoto's Shikai art S5 (DUEL_YAMA_CORE §26): the proof that the Shikai's / 爆炎's three Kikon cinematics move no sim line but the
# ones a cinematic's length moves (only commands that exist at 22ee1330, so the same script runs on a dist built there and its log can
# be diffed line by line). Each scene a fresh match (87200 then 87014), human P1 in the Shikai 1.4 m from an idle Kenpachi, the route held
# into its Kikon under its pointer: J1 > AS1 (不知火), J1 J2 > AS2 (城郭炎上), J1-J3 > AS3 (撫斬); in 爆炎 (87600: heat 100, entered at the
# next neutral; the entry pose waited out) J1 J2 > AS2; a Soul Break he deals under pointer 3 (P2's Reishi 1, then J1: CORE-SOUL-BREAK-CINE
# reads the same :kikon-cines); last 2101 (2 Konpaku a match from the next) and the 城郭炎上 route (AS2's Kikon takes 2): its Kikon is the K.O.
# (the match-over path, the K.O. cinematic, RESULTS). Probe lines at 1 / 5 / 8 s
# and a hash line after each.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 86 --script tests/scripts/duel-yama-s5-kikon.json
YAMA_S5_KIKON = (   # scene, setup commands after 87200 87014, presses (("j" | "hold", seconds after the start) ...)
    ("shiranui J1 > AS1 held", (87301,), (("j", 0), ("hold", 0.2))),
    ("jokaku J1 J2 > AS2 held", (87302,), (("j", 0), ("j", 0.25), ("hold", 0.45))),
    ("nadegiri J1-J3 > AS3 held", (87303,), (("j", 0), ("j", 0.25), ("j", 0.5), ("hold", 0.75))),
    ("gokuen jokaku J1 J2 > AS2 held", (87302, 87600), (("j", 0), ("j", 0.25), ("hold", 0.45))),
    ("soul break under nadegiri: J1 on Reishi 1", (87303, 87801), (("j", 0),)),
    ("jokaku again from 2 Konpaku: the K.O.", (87302,), (("j", 0), ("j", 0.25), ("hold", 0.45))),
)
def yama_s5_kikon_script():
    ev, t = [], T0
    def sp(s, hold): ev.append(key(s, "ShiftLeft")); ev.extend(tap(s + 0.01, "KeyJ", hold)); ev.append(key(s + hold + 0.03, "ShiftLeft", False))
    for name, setup, presses in YAMA_S5_KIKON:
        if name.startswith("jokaku again"): ev.append(cmd(t - 0.3, 2101))
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        cmds = (87200, 87014) + setup
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
        a = t + 0.05 * (len(cmds) - 1) + 1.6                                # (爆炎's entry pose is over by then)
        for kind, dt in presses:
            if kind == "hold": sp(a + dt, 1.2)
            else: ev.extend(tap(a + dt, "KeyJ", 0.05))
        for dt in (1.0, 5.0, 8.0): ev.append(cmd(a + dt, 87900))
        ev.append(cmd(a + 8.1, 2107))
        t += 12.0
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-s5-kikon", yama_s5_kikon_script())

# Yamamoto's Shikai art S5 (DUEL_YAMA_CORE §26): one still per storyboard beat of each Shikai Kikon cinematic, in the Shikai (87482+i from
# frame 0, P1 3 m from an idle Kenpachi set down mid-stage, after 2.5 s idle) then in 爆炎 (87600 first: heat 100 enters it at the next
# neutral, the entry pose over before 87485+i); 87600+k holds it at frame 2k, the still a moment after it gets there, then the next hold.
# 87449's consing line after each form (the cinematic looks' rows in that form), 87448's at the end. PHONE: the deck on (87901), stills -phone.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 100 --script tests/scripts/duel-yama-s5.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 100 --mobile --size 390x844 --script tests/scripts/duel-yama-s5-phone.json
YAMA_S5 = (   # cinematic, name, ((frame (even), beat still) ...)
    (0, "shiranui", ((6, "b0-held"), (30, "b1-caption"), (54, "b2-lights"), (68, "b3-thrust"), (100, "b4-columns"), (124, "b5-shatter"),
                     (138, "b6-tornado"), (162, "b7-back"))),
    (1, "ennetsu", ((6, "b0-held"), (28, "b1-edge"), (62, "b2-pattern"), (96, "b3-pillars"), (120, "b4-dome"), (134, "b5-shatter"),
                    (148, "b6-inside"), (172, "b7-wide"))),
    (2, "nadegiri", ((6, "b0-held"), (20, "b1-face"), (36, "b2-strike"), (40, "b3-cut"), (42, "b3b-out"), (64, "b4-turn"), (84, "b5-seam"), (88, "b5b-shatter"),
                     (104, "b6-split"), (146, "b7-wide"))),   # (re-timed in J3, DUEL_YAMA_CORE §28.5)
)
def yama_s5_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    for base, form in ((87482, "shikai"), (87485, "gokuen")):
        for i, name, beats in YAMA_S5:
            ev.append(cmd(t - 0.6, 87699))                                   # (the last one let run out: a held cinematic freezes the
            ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {form} {name}')"})   #  effect clock, so a callout would wait)
            ev += [cmd(t, 87030)] + ([cmd(t + 0.05, 87600)] if form == "gokuen" else [])   # (idle first; 爆炎 entered by heat 100)
            t += 2.5
            ev.append(cmd(t, base + i))
            if phone: ev.append(cmd(t + 0.02, 87901))
            ev.append(cmd(t + 0.03, 87600 + beats[0][0] // 2))
            a, f0 = t + 0.03, 0
            for j, (f, n) in enumerate(beats):
                a += (f - f0) / 60 + 0.3                                     # (it runs on to frame f, then a still)
                ev.append(shot(a, f"yama-s5-{form}-{name}-{n}{sx}"))
                if j + 1 < len(beats): ev.append(cmd(a + 0.05, 87600 + beats[j + 1][0] // 2))
                a += 0.05
                f0 = f
            t = a + 0.6
        ev.append(cmd(t, 87449)); t += 0.3
    ev.append(cmd(t, 87448)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-s5", yama_s5_script())
write("yama-s5-phone", yama_s5_script(True))

# Yamamoto batch J1 (DUEL_YAMA_CORE §28.3): 城郭炎上's looks and the ring's centre, on commands batch 1 (05acf777) has too, so one script
# shoots the old build, main and the new one alike. NS2a (87413) at 9 m, NS2b's ring (87414) and NS2c's dome (87415) with the victim at
# 1 m and 5 m (87010 / 87050: P1 at x -d/2, P2 at +d/2; the `ring at` / `dome at` combat lines and the probe (87900) give the centre);
# AS2 by presses (J J, then SP SP: the ring snaps round him, the dome on it) at 1.4 m; 爆炎 (87600, its entry pose let run) NS2a > NS2b (the
# dome at once) at 5 m and 1 m, and its AS2. Heat 0 / 25 for the segments that pay (T0 / T2). The behind camera, then the side one (2109).
# PHONE: the deck on (87901). Stills tests/shots/duel-j1-*.png.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 150 --script tests/scripts/duel-yama-j1.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 150 --mobile --size 390x844 --script tests/scripts/duel-yama-j1-phone.json
YAMA_J1 = (   # name, setup, start, ((frame, still) ...)
    ("lance", (87090, 87302), 87413, ((24, "a"), (32, "b"))),
    ("ring1m", (87010, 87302), 87414, ((18, "rise"), (30, "a"), (60, "b"))),
    ("ring5m", (87050, 87302), 87414, ((18, "rise"), (30, "a"), (60, "b"))),
    ("dome1m", (87010, 87302), 87415, ((19, "hit"), (22, "boom"), (28, "c"), (40, "d"))),
    ("dome5m", (87050, 87302), 87415, ((19, "hit"), (22, "boom"), (28, "c"), (40, "d"))),
)
def yama_j1_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    deck = (87901,) if phone else ()
    def sp(s): ev.append(key(s, "ShiftLeft")); ev.extend(tap(s + 0.01, "KeyJ", 0.05)); ev.append(key(s + 0.09, "ShiftLeft", False))
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
        return t + 0.05 * (len(cmds) - 1)
    for cam in ("behind", "side"):
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
        for name, setup, start, frames in YAMA_J1:
            for h in ((0,) if name.startswith("ring") else (0, 25)):
                a = scene(f"{name} heat {h} {cam}", setup + (87500 + h,) + deck) + 0.3
                ev.append(cmd(a - 0.05, setup[0])); ev.append(cmd(a, start)); ev.append(cmd(a + 21 / 60, 87900))
                for f, n in frames: ev.append(shot(a + f / 60, f"j1-{name}-{n}-h{h}-{cam}{sx}"))
                t = a + 1.8
        for g in ("", "-gokuen"):
            a = scene(f"AS2{g} {cam}", (87014, 87302, 87500) + ((87600,) if g else ()) + deck) + 1.6   # (爆炎's entry pose over by then;
            ev.append(cmd(a - 0.1, 87014))                                                            #  set down again: a stray step)
            ev.extend(tap(a, "KeyJ", 0.05)); ev.extend(tap(a + 0.25, "KeyJ", 0.05)); sp(a + 0.45); sp(a + 0.8)
            for f, n in ((14, "snap"), (26, "ring"), (40, "b-hit"), (44, "b-boom"), (52, "b-c")):
                ev.append(shot(a + 0.45 + f / 60, f"j1-as2{g}-{n}-{cam}{sx}"))
            ev.append(cmd(a + 0.75, 87900))
            t = a + 2.6
        for d in (50, 10):
            a = scene(f"gokuen NS2a NS2b {d / 10:g} m {cam}", (87000 + d, 87302, 87600) + deck) + 1.6
            ev.append(cmd(a - 0.1, 87000 + d)); sp(a); sp(a + 0.5)
            for f, n in ((24, "lance"), (47, "dome-hit"), (50, "dome-boom"), (58, "dome-c")):
                ev.append(shot(a + f / 60, f"j1-gokuen{d // 10}m-{n}-{cam}{sx}"))
            t = a + 2.4
        t = scene(f"out {cam}", (87050, 87500)) + 1.2                          # (heat 0: back to the Shikai at his next neutral)
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-j1", yama_j1_script())
write("yama-j1-phone", yama_j1_script(True))

# Yamamoto J3 (DUEL_YAMA_CORE §28.5): stance 3 (撫斬) at rest in the Shikai and in 爆炎 (87600: heat 100), the behind camera then the SIDE
# camera (2109), two phases of its loop each; 爆炎's NS2b (87474, its own clip since J3) as an 8-frame strip from the S4 ring scene's setup,
# both cameras. PHONE: the deck on (87901), stills -phone.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 40 --script tests/scripts/duel-yama-j3.json
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 40 --mobile --size 390x844 --script tests/scripts/duel-yama-j3-phone.json
def yama_j3_script(phone=False):
    ev, t, sx = [], T0, ("-phone" if phone else "")
    deck = (87901,) if phone else ()
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
        return t + 0.05 * (len(cmds) - 1)
    for cam in ("behind", "side"):
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
        for form, extra in (("shikai", ()), ("gokuen", (87600,))):
            a = scene(f"stance 3 {form} {cam}", (87500, 87030, 87303) + extra + deck) + 1.2
            ev.append(shot(a, f"j3-stance3-{form}-a-{cam}{sx}")); ev.append(shot(a + 0.7, f"j3-stance3-{form}-b-{cam}{sx}"))
            t = a + 1.0
        a = scene(f"gokuen NS2b {cam}", (87500, 87050, 87302, 87600) + deck) + 0.8
        ev.append(cmd(a, 87474))
        for f in (1, 4, 7, 10, 13, 15, 16, 18):
            ev.append(shot(a + f / 60, f"j3-ns2b-f{f:02d}-{cam}{sx}"))
        t = a + 1.5
        if cam == "side": ev.append(cmd(t, 2109)); t += 0.3
    ev.append(cmd(t, 87500)); t += 0.3
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-j3", yama_j3_script())
write("yama-j3-phone", yama_j3_script(True))

# Yamamoto §30 (DUEL_YAMA_CORE §30.2 / §30.4, as built §30.6; the browser path of tests/trials/yamamoto-sp30.lisp, and what the native trials
# skip: 北's Kikon cinematic). P1 in the Bankai (87446) vs an idle Kenpachi: 西 NSa > SA > J2 > J3 from 2.6 m and NSa > NSb > SA > J2 > J3
# from 4.4 m (the `WEST charge` lines: x, reach, distance; stills of the garb at 0.6 / 1.0 / 1.4), the third mark (東 西 held, J1-J3 > AS3)
# and 北's entry at the next neutral (stills: the entry pose, the plate's 北 bar), 北's NS a-b-c from 5 m, J1 > AS, then J1 > AS a held (the
# Kikon: yama-tenchi-cine) with probe lines (87900) before, through and after it: 北's ticks stop while it plays; then idle until `NORTH
# over` (the match ticks between the entry and that line = 624 + the cinematic's). 87448's consing line ends the run.
#   node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 60 --script tests/scripts/duel-yama-sp30.json
def yama_sp30_script():
    ev, t = [], T0
    def sp(s, hold=0.05):
        ev.append(key(s, "ShiftLeft")); ev.extend(tap(s + 0.01, "KeyJ", hold)); ev.append(key(s + hold + 0.03, "ShiftLeft", False))
    def j(s): ev.extend(tap(s, "KeyJ", 0.05))
    def scene(name, cmds):
        ev.append({"at": round(t - 0.05, 2), "eval": f"console.log('=== {name}')"})
        ev.extend(cmd(t + 0.05 * i, c) for i, c in enumerate(cmds))
    scene("west base garb (0.6)", (87026, 87302, 87446, 87445)); ev.append(shot(t + 1.0, "yama-sp30-garb-base")); t += 1.5
    scene("west NSa > SA > J2 > J3 (2.6 m)", (87026, 87302, 87445)); sp(t + 0.3); j(t + 0.55); j(t + 0.9); j(t + 1.15)
    ev.append(shot(t + 0.75, "yama-sp30-garb-1")); t += 3.0
    scene("west NSa > NSb > SA > J2 > J3 (4.4 m)", (87044, 87302, 87445)); sp(t + 0.3); sp(t + 0.6); j(t + 0.95); j(t + 1.25); j(t + 1.5)
    ev.append(shot(t + 1.3, "yama-sp30-garb-2")); t += 3.0
    scene("west neutral again (0.6)", (87900,)); ev.append(shot(t + 0.2, "yama-sp30-garb-after")); t += 0.6
    scene("the third mark: J1-J3 > AS3, NORTH at the next neutral", (87014, 87301, 87445, 87441, 87442))
    [j(t + 0.3 + 0.25 * i) for i in range(3)]; sp(t + 1.1); sp(t + 1.4); sp(t + 1.7)
    ev.append(cmd(t + 3.0, 87900)); ev.append(shot(t + 2.75, "yama-sp30-north-in")); ev.append(shot(t + 3.4, "yama-sp30-north")); t += 4.0
    scene("NORTH NS a-b-c (5 m)", (87050, 87444)); sp(t + 0.6); sp(t + 0.9); sp(t + 1.2); t += 3.0
    scene("NORTH J1 > AS (1.4 m)", (87014, 87444)); j(t + 0.6); sp(t + 0.95); sp(t + 1.2); sp(t + 1.45); t += 3.0
    scene("NORTH J1 > AS held: the Kikon pauses the count", (87014, 87444, 87900)); j(t + 0.6); sp(t + 0.95, 1.4)
    for k in range(12): ev.append(cmd(t + 1.0 + 0.5 * k, 87900))
    ev.append(shot(t + 3.0, "yama-sp30-north-kikon")); t += 7.5
    scene("NORTH counts on to its end", ())
    for k in range(14): ev.append(cmd(t + 0.5 * k, 87900))
    t += 7.5
    ev.append(cmd(t, 87448)); t += 0.5
    ev.append({"at": round(t, 2), "eval": "console.log('=== END')"})
    return sorted(ev, key=lambda x: x["at"])
write("yama-sp30", yama_sp30_script())

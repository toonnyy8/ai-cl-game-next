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
for i in range(8): ev += tap(t + 2.0 + 0.2 * i, "ArrowDown")                      # CAMERA (row 13 since P1 AWAKEN)
ev += tap(t + 3.6, "Enter") + tap(t + 4.1, "Escape") + [cmd(t + 5.0, 2107)]
t += 5.5
# the HP / KONPAKU rows (the user's request 2026-09-28): P1 HP 100 -> 50 %, P1 KONPAKU 9 -> 4, DUMMY HP -> 25 %,
# DUMMY KONPAKU 9 -> 8; the dump: P1 r650 k4 (INFINITE holds his Reishi at his row), P2 r325 k8
ev += tap(t, "Escape")
for i in range(7): ev += tap(t + 0.4 + 0.2 * i, "ArrowDown")                       # P1 HP (row 7 since P1 AWAKEN, 2026-10-31)
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
# P1 AWAKEN (2026-10-31): the row after GAUGES, right x3 -> SUBLIMATION 50 (the gauge full, SUBLIMATION 50), then x1 -> SUBLIMATION FULL; the log lines say it
ev += tap(t, "Escape")
for i in range(6): ev += tap(t + 0.4 + 0.2 * i, "ArrowDown")                       # P1 AWAKEN (row 6)
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
    a second switch inside the temporary route (refused); DRIVE 20 (< 25: refused)."""
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
            ("DS drive 20: SP, D+SP (refused)", 86107, lambda s: [sp(s), sw(s + 0.3, "KeyD")])):
        say(t, label)
        ev.extend([cmd(t, setup), cmd(t + 3.0, 2107)])
        body(t + 0.3)
        t += 3.5
    return sorted(ev, key=lambda x: x["at"])
write("drive-switch", drive_switch_script())

def switch_routes_script():
    """The switch routes the user named (DUEL_SUBLIMATION §17.7): Hisagi's Shikai with SUBLIMATION 60 (debug 83600+d, d / 10 m from an idle
    Kenpachi): NS1 at range, then A (left: pointer 3) + SP for NS3a, J for its SA 引寄 or SP for NS3b and J for its SA 放電; the Bankai's
    ranged mode with DRIVE 60 (83700+d): NS1a 環 WA, then D + SP for 聚 NS2a and its route. 83099 logs the distance (`| d`)."""
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def sp(t, hold=0.05): ev.append(key(t, "ShiftLeft")); ev.extend(tap(t + 0.01, "KeyJ", hold)); ev.append(key(t + hold + 0.03, "ShiftLeft", False))
    def jt(t): ev.extend(tap(t, "KeyJ", 0.05))
    def sw(t, k): ev.append(key(t - 0.05, k)); sp(t); ev.append(key(t + 0.15, k, False))
    def d(t): ev.append(cmd(t, 83099))
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
    sideways flick (right / left) in the NS gap = the pointer switch; a flick with no DRIVE (86107) stays a Step."""
    ev = []
    def say(t, s): ev.append({"at": round(t, 2), "eval": f"console.log('=== {s}')"})
    def tap(t, x, y): return [{"at": round(t, 2), "touch": "start", "x": x, "y": y}, {"at": round(t + 0.05, 2), "touch": "end", "x": x, "y": y}]
    def flick(t, x0, x1, y=600): return [{"at": round(t, 2), "touch": "start", "x": x0, "y": y}, {"at": round(t + 0.03, 2), "touch": "move", "x": (x0 + x1) // 2, "y": y},
                                         {"at": round(t + 0.06, 2), "touch": "move", "x": x1, "y": y}, {"at": round(t + 0.12, 2), "touch": "end", "x": x1, "y": y}]
    t = T0
    for label, setup, body in (
            ("DP right flick: SP tap, flick right", 86105, lambda s: [*tap(s, 195, 520), *flick(s + 0.3, 150, 260)]),
            ("DP left flick: SP tap, flick left", 86105, lambda s: [*tap(s, 195, 520), *flick(s + 0.3, 260, 150)]),
            ("DP no DRIVE: SP tap, flick right (a Step)", 86107, lambda s: [*tap(s, 195, 520), *flick(s + 0.3, 150, 260)])):
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
    STAND (the control: no contact without a cancel's unlock), (h) Ichigo's pointer 2 (the wave: a hazard, it lands), (i) J1 at 6 m (out of
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

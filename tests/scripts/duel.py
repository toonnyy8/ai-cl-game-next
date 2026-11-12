# SOUL DUEL headless scripts (duel/lisp/debug.lisp lists the debug commands). Run:
#   python3 tests/scripts/duel.py            (writes tests/scripts/duel-*.json)
#   node tools/run.mjs dist/duel --secs 60  --script tests/scripts/duel-cvc-yk.json   seeded CPU vs CPU -> RESULTS
#   node tools/run.mjs dist/duel --secs 1100 --script tests/scripts/duel-gate.json    20 seeds x YY/YK/KK: "duel gate" lines
#     (2113 now plays all fifteen pairings (YY YK KK RY RK RR IY IK IR II SY SK SR SS SI): better one run per pairing with
#     2125+k, k 0-14, --secs 1500, at most 4 at once on a shared machine)
#     (+ the combat log: 2107 turns it back on after the gate starts; scratchpad pt/attr.py-style analysers read it)
#   node tools/run.mjs dist/duel --secs 20  --script tests/scripts/duel-probe.json    frame probes: "duel probe ... advantage
#     A (table A)" for blocked Q1 / Q3 / F2 / Taimatsu (must be equal), then a mirror Q1 trade (same Reishi both sides)
#   node tools/run.mjs dist/duel --secs 60  --script tests/scripts/duel-keys.json     P1 keyboard: J/K/L/I/U/Space/Shift
#   node tools/run.mjs dist/duel --secs 50  --script tests/scripts/duel-extras.json   dash, Hoho swing, Burst, camera toggle
#   node tools/run.mjs dist/duel --secs 170 --script tests/scripts/duel-kikon.json    the four O modules and the O rule
#   node tools/run.mjs dist/duel --secs 50  --script tests/scripts/duel-gauges.json   guard gauge (crush, guardless) + flash-step
#   node tools/run.mjs dist/duel --secs 70  --script tests/scripts/duel-stances.json  Bankai East / West: U, L, the ward, SP1, South
#   node tools/run.mjs dist/duel --secs 90  --script tests/scripts/duel-nome.json    Nozarashi v2 cups, DRINK, rift, cash-out, West's ward
#   node tools/run.mjs dist/duel --secs 40 --fixed-dt 16.666667 --script tests/scripts/duel-strings.json   the J / K
#     strings, the latch, the O ender (shots tests/shots/duel-string-*.png)
#   node tools/run.mjs dist/duel --secs 75  --script tests/scripts/duel-perf.json     real-time CPU vs CPU: stats lines
#   node tools/run.mjs dist/duel --secs 140 --script tests/scripts/duel-shots.json    tests/shots/duel-*.png
#   node tools/run.mjs dist/duel --secs 62 --fixed-dt 16.666667 --script tests/scripts/duel-practice.json   SETTINGS +
#     PRACTICE by keyboard (--fixed-dt: on a loaded host real-time key timing drops string links)
# Determinism: run a cvc script twice (or once with turbo and once without: drop the 2102 step) and
#   diff <(grep '^duel' run1.log) <(grep '^duel' run2.log)   -> empty.
# Reference (the hidden hit-stun tolerance and the J/K cut, 2026-09-29, docs/duel/DUEL_DESIGN.md "Hidden hit-stun tolerance",
# docs/duel/DUEL_STRINGS.md): duel-cvc-yk.json (seed 7) ends
#   duel -> RESULTS winner P2 konpaku 0-6 ticks 6220 secs 103.7    (turbo and real time alike; also after a gate)
#   (before the perfect Hoho's 12-frame lead, 2026-10-01: winner P1 konpaku 7-0 ticks 9328 secs 155.5)
#   (before Kenpachi's more aggressive cup 2 / 3 CPU, 2026-09-29, docs/duel/DUEL_NOZARASHI_V2.md: winner P1 konpaku 2-0 ticks 9636 secs 160.6)
#   (before them, the J / K strings + the Soul Break rule + the Bankai: winner P2 konpaku 0-3 ticks 7123 secs 118.7;
#   before the strings, the Bankai rework + the slower guard refill: winner P1 konpaku 2-0 ticks 7688 secs 128.1;
#   before the rework, guard v3: winner P2 konpaku 0-4 ticks 9305 secs 155.1; before guard v3, the Kenpachi batch: winner P1 konpaku 7-0 ticks 7351 secs 122.5; before the batch: winner P2 konpaku 0-3 ticks 8594 secs 143.2; before user review 3's slower cinematics: the same match with shorter cinematics, ticks 8384 secs 139.7 and ticks 8054 secs 134.2; P1 1-0 ticks 9438 secs 157.3 with the gauges and the O modules; P1 2-0 ticks 9780 secs 163.0 with the Kikon rush; P2 0-1 ticks 7298 secs 121.6 with the instant Kikon; 0-4 ticks 5857 secs 97.6 with a timed Bankai;
#   0-7 ticks 5302 secs 88.4 before Burst and the dash)
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
write("probe", [cmd(T0 + 2 * i, 2315 + i) for i in range(5)])

# P1 on the keyboard vs an idle CPU (2500: Yamamoto vs Kenpachi). Expected log lines, in order:
# P1 move YA-J1 YA-J2 YA-J3 (2393 puts him 2.2 m out: a string needs contact) | YA-K1 | YA-SIG | YA-BREAKER | P1 guard |
# P1 step | YA-SHIRANUI | P1 hoho | YA-TAIMATSU
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

# Burst, dash and the camera by keyboard (P1 Yamamoto vs an idle Kenpachi, VS CPU = the behind camera).
# Expected log lines, in order: P1 step, P1 dash (the run), P1 step, P1 dash, P1 run -> YA-Q1, carry ...,
# P1 hoho, KE-Q1 / KE-Q2 -> P1 HIT (the mash test 2320), P1 BURST, then "duel camera CAMERA  SIDE" (pause menu).
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

# The O modules and the O rule by keyboard (debug 2330+k: P1 with module k % 4 -- 0 ENJO, 1 TENCHI, 2 CHARGE,
# 3 LEAP -- 1 m inside its reach from a Yamamoto CPU who, by k // 4: 0 stands, 1 guards, 2 stands red,
# 3 guards red, 4 plays at HARD, 5 stands in 0.1x slow motion, 6 guards once hit, 7 red and guards once hit).
# The rule (the user's, with the lead's dash-in): the strike is guardable; a hit with O held knocks him back
# and the rusher DASHES IN to the follow-up strike, the Kikon: guardable during the dash unless he is red.
# Expected log lines per step:
#   k 20..23 (slow motion, O held): "-> P2 HIT 70", "KIKON FOLLOW-UP on P2" (the dash-in), "-> P2 KIKON 70", the cinematic
#   k 4 / 5  (guarding, not red, O held): "-> P2 BLOCKED 70" and nothing more
#   k 13 / 15 (guarding RED, O held): "-> P2 BLOCKED 70", no Kikon (the first strike is always guardable)
#   k 9 / 11 (red, O held): "-> P2 HIT 70", "FOLLOW-UP", "-> P2 KIKON 70";  k 10 with O tapped: "-> P2 HIT 70" only
#   k 17 (HARD CPU, not red): the CPU guards the strike or the dash-in by its roll, or takes the Kikon
#   k 24 / 26 (not red, guards once hit): "-> P2 HIT 70", "KIKON FOLLOW-UP", then "-> P2 BLOCKED 70": no Kikon
#   k 29 / 30 (RED, guards once hit): "-> P2 HIT 70", "KIKON FOLLOW-UP", then "-> P2 KIKON 70": red can't guard it
# The script turns the CAMERA option to SIDE first (2109): the lanes and dashes read from the side.
# Shots: tests/shots/duel-o-<module>-{a,b,c,d,e}.png (the aim / aura, the dash or lane, the strike, the dash-in,
# its strike).
t = T0
ev = [cmd(t - 0.5, 2109)]
for k, name, hit in ((20, "enjo", 4.7), (21, "tenchi", 4.5), (22, "charge", 8.0), (23, "leap", 7.7)):   # hit: ~s to the strike
    ev += [cmd(t, 2330 + k), key(t + 0.2, "KeyO"), shot(t + 1.2, f"o-{name}-a"), shot(t + 2.6, f"o-{name}-b"),
           shot(t + 4.0, f"o-{name}-c"), shot(t + hit + 1.0, f"o-{name}-d"), shot(t + hit + 2.5, f"o-{name}-e"),
           key(t + 15.0, "KeyO", False)]
    t += 18.0
for k in (4, 5, 13, 15, 9, 11, 17, 24, 26, 29, 30):
    ev += [cmd(t, 2330 + k), key(t + 0.3, "KeyO"), key(t + 3.0, "KeyO", False)]
    t += 7.0
ev += [cmd(t, 2330 + 10)] + tap(t + 0.3, "KeyO", 0.1)                      # CHARGE tapped (released) on a red target: a plain hit
ev += [cmd(t + 4.0, 2107)]
write("kikon", ev)

# The two universal gauges by keyboard. Guard gauge (2327: human P1 Yamamoto holds U while Kenpachi presses
# Quick for 20 s): "P2 KE-Q* -> P1 BLOCKED" (28 per Q string) until "P1 GUARD CRUSH" on the 4th string, then
# "-> P1 HIT" lines although U is held, then "P1 GUARD BACK" 1 s + 7.1 s after the gauge emptied, then BLOCKED
# again. Flash-step (2500: P1 Yamamoto vs an idle Kenpachi): Shift+Space x4 -> three "P1 hoho" (30 each),
# the 4th refused; then 2500 again, one Hoho (70 left), 2320 + Shift+J after Kenpachi's 2nd hit -> "P1 BURST"
# (70), the hash line shows f0. Shots: gauges-drain, gauges-crush, gauges-guardless, gauges-hoho, gauges-burst.
t = T0
ev = [cmd(t, 2327), key(t + 0.2, "KeyU"), shot(t + 3.0, "gauges-drain"), shot(t + 6.0, "gauges-crush"),
      shot(t + 9.0, "gauges-guardless"), key(t + 22.0, "KeyU", False), cmd(t + 22.2, 2107)]
t += 24.0
ev += [cmd(t, 2500)]
for i in range(4):
    ev += [key(t + 1.0 + 1.8 * i, "ShiftLeft"), key(t + 1.05 + 1.8 * i, "Space"), key(t + 1.2 + 1.8 * i, "Space", False),
           key(t + 1.25 + 1.8 * i, "ShiftLeft", False)]
ev += [shot(t + 8.4, "gauges-hoho"), cmd(t + 8.5, 2107)]
t += 10.0
ev += [cmd(t, 2500), key(t + 1.0, "ShiftLeft"), key(t + 1.05, "Space"), key(t + 1.2, "Space", False), key(t + 1.25, "ShiftLeft", False)]
t += 3.0
ev += [cmd(t, 2320), key(t + 0.1, "ShiftLeft")]
for i in range(16): ev += tap(t + 0.3 + 0.12 * i, "KeyJ", 0.05)
ev += [key(t + 2.4, "ShiftLeft", False), shot(t + 2.6, "gauges-burst"), cmd(t + 2.8, 2107)]
write("gauges", ev)

# The Bankai stances by keyboard (debug 2370+k: human P1, P2's CPU off; the side camera; docs/duel/DUEL_YAMA_REWORK.md).
# Expected log lines:
#   0 East vs an idle Kenpachi 3 m: L "P1 move YA-E-KYOKKO", "P1 YA-E-KYOKKO -> P2 HIT 85" (the log shows the base: 162 dealt at a full gauge, x(1 + 0.9));
#     U held: "P1 form BANKAI-WEST"; L: "P1 move YA-W-SHONETSU" (he stays West), the pillars; J: "P1 form BANKAI-EAST",
#     "P1 move YA-E-Q1" (the drop on frame 0)
#   1 East J strings into a guard the probe keeps full: "-> P2 BLOCKED", P2's r falls by the pierce's chip (34 x 0.45 =
#     15 for E-Q1 at a full gauge, 57 a string), the probe's "P1 gg" stays 100 (no recoil any more)
#   2 West's ward under Kenpachi's Quick mash (no U): "P2 KE-Q1 -> P1 BLOCKED", P1 never in blockstun (no GUARD-HIT),
#     the probe's "P1 gg" falls 31 per string (28 x1.1) and never refills, "P1 GUARDLESS", "P1 WARD BROKEN", "P1 form BANKAI-EAST"
#     on the 4th string (GUARD CRUSH), then "P2 KE-Q1 -> P1 HIT"
#   9 West's ward vs ranged hits (the :ranged probe, P2 a cup-3 Kenpachi 4.8 m away): the rifts, the cash-out and the
#     Meteor "-> P1 BLOCKED" (the ward covers them; the cash-out breaks it within 6 m: GUARD-BREAK, "WARD BROKEN")
#   3 East Shift+K into a guard at 2 m: "P1 YA-KYOKU -> P2 GUARD-BREAK 90", then "P1 YA-KYOKU -> P2 HIT 130" (x1.5)
#   4 the same at 6 m: "P1 YA-KYOKU -> P2 BLOCKED 130" only (the cone never breaks guard; its pierce chips 65)
#   5 West Shift+K (Kenpachi's F1 on its way; P1's gauge at 40): "P2 KE-F1 -> P1 PARRIED 70", "P2 scorched 15", the
#     gauge full again ("g100" in the 2107 line), "P1 move YA-W-COUNTER", "P1 YA-W-COUNTER -> P2 HIT 150", still West
#   6 East Shift+L on an idle Kenpachi at 3 m, then J J J: "P1 BIND -> P2 HIT 40", "P1 YA-E-Q1 -> P2 HIT 34", ...
#   7 human Kenpachi under the CPU's South: "P2 BIND -> P1 HIT 40", Shift+J: "P1 BURST"
#   8 the same in 0.25x slow motion, a sideways Step in the tell: no "BIND ->" line (it grabs the air)
# Shots: tests/shots/duel-yama-*.png (kyokko: the ray, west-ward: the ward, shonetsu: the pillar ring, ward-block: the
#   ward under the mash, ward-crush: broken back to East), tests/shots/duel-stance-*.png (east-idle, kyoku-*, parry /
#   counter, south-*)
def yshot(t, n): return {"at": round(t, 2), "shot": f"tests/shots/duel-yama-{n}.png"}
t = T0
ev = [cmd(t - 0.5, 2109)]
ev += [cmd(t, 2370), shot(t + 0.3, "stance-east-idle")] + tap(t + 0.5, "KeyL") + [yshot(t + 0.78, "kyokko")]
ev += [cmd(t + 2.0, 2370), key(t + 2.3, "KeyU"), key(t + 2.6, "KeyU", False), yshot(t + 2.75, "west-ward")]
ev += tap(t + 3.2, "KeyL", 0.15) + [yshot(t + 3.75, "shonetsu")] + tap(t + 4.6, "KeyJ", 0.15) + [cmd(t + 5.5, 2107)]
t += 6.0
ev += [cmd(t, 2371)]
for i in range(40): ev += tap(t + 0.4 + 0.15 * i, "KeyJ", 0.05)
ev += [cmd(t + 8.0, 2107)]
t += 9.0
ev += [cmd(t, 2372), yshot(t + 1.5, "ward-block"), yshot(t + 9.5, "ward-crush"), cmd(t + 16.0, 2107)]
t += 17.0
ev += [cmd(t, 2379), key(t + 1.6, "KeyU"), key(t + 3.3, "KeyU", False)] + tap(t + 5.9, "KeyJ") + [cmd(t + 10.0, 2107)]
t += 10.5
ev += [cmd(t, 2373), key(t + 0.5, "ShiftLeft"), key(t + 0.55, "KeyK"), key(t + 0.65, "KeyK", False), key(t + 0.7, "ShiftLeft", False),
       shot(t + 0.95, "stance-kyoku-break"), shot(t + 1.2, "stance-kyoku-cone")]
t += 3.0
ev += [cmd(t, 2374), key(t + 0.5, "ShiftLeft"), key(t + 0.55, "KeyK"), key(t + 0.65, "KeyK", False), key(t + 0.7, "ShiftLeft", False),
       shot(t + 1.1, "stance-kyoku-far"), cmd(t + 2.5, 2107)]
t += 3.0
ev += [cmd(t, 2375), key(t + 0.5, "ShiftLeft"), key(t + 0.55, "KeyK"), key(t + 0.65, "KeyK", False), key(t + 0.7, "ShiftLeft", False),
       shot(t + 0.95, "stance-parry"), shot(t + 1.25, "stance-counter"), cmd(t + 3.0, 2107)]
t += 4.0
ev += [cmd(t, 2376), key(t + 0.5, "ShiftLeft"), key(t + 0.55, "KeyL"), key(t + 0.65, "KeyL", False), key(t + 0.7, "ShiftLeft", False),
       shot(t + 0.95, "stance-south-tell"), shot(t + 1.4, "stance-south-bound")]
for i in range(3): ev += tap(t + 1.5 + 0.2 * i, "KeyJ", 0.05)
ev += [cmd(t + 3.0, 2107)]
t += 4.0
ev += [cmd(t, 2377), key(t + 1.3, "ShiftLeft"), key(t + 1.35, "KeyJ"), key(t + 1.45, "KeyJ", False), key(t + 1.5, "ShiftLeft", False),
       shot(t + 1.2, "stance-south-victim"), shot(t + 1.6, "stance-south-burst"), cmd(t + 3.0, 2107)]
t += 4.0
ev += [cmd(t, 2378), key(t + 1.9, "KeyD"), key(t + 1.95, "Space"), key(t + 2.05, "Space", False), key(t + 2.4, "KeyD", False),
       shot(t + 2.6, "stance-south-step"), cmd(t + 8.0, 2107)]
write("stances", ev)

# (Nozarashi v2's NOME ladder script, duel-nome.json, went with the cups, 2026-11-03: DUEL_KEN_V3 §8)

# The J / K strings and the O ender (docs/duel/DUEL_STRINGS.md; debug 2394+k: human P1 2.2 m from an idle Kenpachi, k 0 Shikai,
# 1 Bankai East, 2 Kenpachi, 3 RYOTE). Expected log lines: P1 move YA-J1 YA-J2 YA-J3, then YA-KIKON (O-ENDER) -> P2 HIT
# (no aura: the strike at once); YA-E-K1 YA-E-K2 YA-E-K3; KE-J1 KE-K2S KE-K3 + KE-KIKON; KE-R-J1 KE-R-J2 KE-R-J3;
# KE-R-K1 KE-R-K2 KE-R-J3; and J K J: KE-J1 KE-K2S, the third press eaten (the string ends: no KE-J3).
# Shots: string-o-ender (Shikai's ENJO off J3), string-sodebi (J3 TSUKABI since 2026-10-14, the pommel lit; the shot keeps its old name), string-rakujitsu, string-kick,
# string-tsuki.
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

# Kuchiki Rukia (docs/duel/DUEL_RUKIA.md; run with --fixed-dt 16.666667 --secs 80, landscape, and duel-rukia-portrait.json with
# --size 390x844). The select screen (the roster cycled to her by keyboard; in portrait by a tap on the right third),
# then human P1 Rukia vs an idle Kenpachi (debug 2410+k): the Shikai (stance, L tap BYAKURAI, L held TSUKISHIRO's ring and
# pillar, J1, K1, the pirouette J3, K3, SP1 tap SOKATSUI, SP1 held RIKUJOKORO, SHIRAFUNE; since 2026-10-24 the 霜の層 crust
# and the six bursts, 85000+k), -18 C (TOSHU, HYOKA, HAKKA's pillar and lane, HAKUREN's stabs and wave), -50 C (HYOSHIN's
# tell and quake), absolute zero (the freeze-touch on Kenpachi's J1, REIDO TOKETSU), the CRACK after a Breaker, then key
# frames of her three cinematics (40000+f 月白, 41000+f 白霞罸, 42000+f 絶対零度). Shots tests/shots/duel-rukia[-p]-*.png.
def rukia_script(tag, portrait):
    def rs(t, n): return {"at": round(t, 2), "shot": f"{SHOTS}rukia{tag}-{n}.png"}
    def stap(t, k): return [key(t, "ShiftLeft"), key(t + 0.02, k), key(t + 0.08, k, False), key(t + 0.1, "ShiftLeft", False)]
    def touch(t, x, y): return [{"at": round(t, 2), "touch": "start", "x": x, "y": y}, {"at": round(t + 0.05, 2), "touch": "end", "x": x, "y": y}]
    t = T0 - 0.5
    ev = tap(t + 0.5, "Enter") + tap(t + 1.5, "Enter")                       # title -> MODE -> VS CPU: select
    if portrait: ev += touch(t + 2.5, 350, 400) + touch(t + 3.0, 350, 400)   # the right third: next character, twice
    else: ev += tap(t + 2.5, "ArrowRight") + tap(t + 3.0, "ArrowRight")
    ev.append(rs(t + 3.8, "select")); t += 4.5
    ev += [cmd(t, 2410)] + ([] if portrait else [cmd(t + 0.1, 2109)]); t += 1.2
    ev.append(rs(t, "base-stance")); t += 0.3
    ev += tap(t, "KeyL", 0.06); ev.append(rs(t + 0.22, "byakurai")); t += 1.2         # L tap: BYAKURAI (5 m out)
    ev += [cmd(t, 2410)]; t += 0.4
    ev += tap(t, "KeyL", 0.35); ev += [rs(t + 0.5, "tsukishiro-ring"), rs(t + 0.84, "tsukishiro-pillar")]; t += 1.8   # L held
    ev += [cmd(t, 2393)]; t += 0.4
    ev += tap(t, "KeyJ", 0.06); ev.append(rs(t + 0.12, "j1")); t += 0.9
    ev += [cmd(t, 2393)]; t += 0.3
    ev += tap(t, "KeyK", 0.06); ev.append(rs(t + 0.29, "k1")); t += 1.2
    ev += [cmd(t, 2393)]; t += 0.3
    ev += tap(t, "KeyJ", 0.06) + tap(t + 0.1, "KeyJ", 0.06) + tap(t + 0.3, "KeyJ", 0.06); ev.append(rs(t + 0.5, "j3-spin")); t += 1.4
    ev += [cmd(t, 2393)]; t += 0.3
    ev += tap(t, "KeyK", 0.06) + tap(t + 0.2, "KeyK", 0.06) + tap(t + 0.55, "KeyK", 0.06); ev.append(rs(t + 0.97, "k3-drop")); t += 1.8
    ev += [cmd(t, 2410), cmd(t + 0.05, 2108)]; t += 0.4
    ev += stap(t, "KeyK"); ev.append(rs(t + 0.34, "sokatsui")); t += 1.4               # SP1 tap: SOKATSUI's cone
    ev += [cmd(t, 2410), cmd(t + 0.05, 2108)]; t += 0.4
    ev += [key(t, "ShiftLeft"), key(t + 0.02, "KeyK"), rs(t + 0.36, "rikujo-tell"), key(t + 0.5, "KeyK", False),
           key(t + 0.52, "ShiftLeft", False), rs(t + 0.64, "rikujo")]; t += 1.6      # SP1 held: RIKUJOKORO's rods
    ev += [cmd(t, 2410), cmd(t + 0.05, 2108)]; t += 0.4
    ev += stap(t, "KeyL"); ev.append(rs(t + 0.3, "shirafune")); t += 1.3
    # 霜の層 and the six bursts (debug 85000+k, DUEL_RUKIA_TYBW §4.4): the crust at 3 layers, each J / K link + L, 霜陣's circle
    ev += [cmd(t, 85003)]; t += 0.5; ev.append(rs(t, "layers-3")); t += 0.3
    for k, n, at in ((10, "shimochiri", 0.42), (11, "setsuen", 0.42), (12, "sojin", 0.43), (13, "hyoreki", 0.72),
                     (14, "tsurara", 0.66), (15, "nadare", 0.68)):
        ev += [cmd(t, 85000 + k), rs(t + at, f"burst-{n}")]; t += 1.5
    ev += [cmd(t, 85040), rs(t + 1.5, "sojin-circle")]; t += 2.2
    ev += [cmd(t, 2411)]; t += 1.0
    ev.append(rs(t, "m18-stance")); t += 0.2
    ev += tap(t, "KeyK", 0.06); ev.append(rs(t + 0.29, "toshu")); t += 1.2
    ev += [cmd(t, 2411)]; t += 0.3
    ev += tap(t, "KeyK", 0.06) + tap(t + 0.2, "KeyK", 0.06) + tap(t + 0.55, "KeyK", 0.06); ev.append(rs(t + 1.0, "hyoka")); t += 1.8
    ev += [cmd(t, 2411)]; t += 0.4
    ev += tap(t, "KeyO", 0.06); ev += [rs(t + 0.2, "hakka-pillar"), rs(t + 0.5, "hakka-lane")]; t += 1.6
    ev += [cmd(t, 2411), cmd(t + 0.05, 2108)]; t += 0.4                                # -18's HAKUREN (the bands' SP1)
    ev += [key(t, "ShiftLeft"), key(t + 0.02, "KeyK"), rs(t + 0.8, "hakuren-stab"), key(t + 1.1, "KeyK", False),
           key(t + 1.12, "ShiftLeft", False), rs(t + 1.45, "hakuren-wave")]; t += 2.4
    ev += [cmd(t, 2412)]; t += 1.0
    ev.append(rs(t, "m50-stance")); ev += tap(t + 0.1, "KeyL", 0.06); ev += [rs(t + 0.3, "hyoshin-tell"), rs(t + 0.4, "hyoshin")]; t += 1.4
    ev += [cmd(t, 2413)]; t += 0.25
    ev.append(rs(t, "zero-freeze")); t += 1.0
    ev.append(rs(t, "zero-stance")); t += 0.3
    ev += tap(t, "KeyL", 0.06); ev.append(rs(t + 0.12, "reido")); t += 1.2
    ev += [cmd(t, 2415)]; t += 1.3
    ev.append(rs(t, "crack")); t += 0.4
    if not portrait: ev.append(cmd(t, 2109)); t += 0.2
    for k, frames in ((40000, (6, 40, 84, 114, 140, 160, 176)), (41000, (6, 20, 26, 50, 100, 126, 146, 164, 186)),
                      (42000, (6, 24, 50, 80, 124))):
        last = 0
        for f in frames:
            ev.append(cmd(t, k + f)); wait = (f - last) / 60.0 + (1.2 if last == 0 else 0.35)
            ev.append(rs(t + wait, f"cine{k // 1000 - 40}-{f:03d}")); t += wait + 0.1; last = f
        t += 0.5
    ev.append(cmd(t, 2107))
    return ev
# K -> L (docs/duel/DUEL_STRINGS.md §12; run with --fixed-dt 16.666667 --secs 60): human P1 Rukia 2.2 m from an idle Kenpachi
# (debug 2420+k, *KL-TESTS*): per form K L, K K L, K K K L. Expected "duel probe kl" lines: each L hit with P2 still in
# stun (left-before > 0, the combo count up); k 4 (-18, 10 cold): no RU-SHIMOBASHIRA; k 5 / 6 (a held guard): the L
# blocked too. Shots tests/shots/duel-kl-<form>-<n>.png (the K hit, the L's ring / disc).
def kl_script():
    t = T0; ev = []
    ev += tap(t, "Enter") + tap(t + 0.8, "Enter") + tap(t + 1.6, "ArrowRight") + tap(t + 2.0, "ArrowRight"); t += 3.5
    for k, tag in ((0, "base"), (1, "m18"), (2, "m50"), (3, "zero"), (4, "cold"), (5, "block"), (6, "block18")):
        for ks in (1, 2, 3):
            ev.append(cmd(t, 2420 + k)); t0 = t + 0.6
            for i in range(ks): ev += tap(t0 + [0, 0.2, 0.55][i], "KeyK", 0.05)
            lt = t0 + [0.12, 0.35, 1.0][ks - 1]
            ev += tap(lt, "KeyL", 0.05)
            if k < 4: ev += [shot(lt + 0.25 + 0.2 * ks, f"kl-{tag}-{ks}a"), shot(lt + 0.55 + 0.2 * ks, f"kl-{tag}-{ks}b")]
            t = t0 + 3.2
    ev.append(cmd(t, 2107))
    return ev
write("rukia-kl", kl_script())
write("rukia", rukia_script("", False))
write("rukia-portrait", rukia_script("-p", True))

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
# ENDLESS (docs/duel/DUEL_ENDLESS.md; run with --fixed-dt 16.666667 --secs 110): a menu run, so it writes the record.
# Landscape by keyboard: MODE row 1 (ENDLESS) -> P1 Kenpachi -> START NORMAL; stage 1 cleared by debug 80980 (STAGE
# CLEAR not awakened: CONTINUE / QUIT) -> CONTINUE; stage 2: 80987 (his 5th form, KATAUDE) + the clear -> STAGE CLEAR
# awakened -> REVERT; stage 3's line "P1 form base konpaku 9 awaken 100"; 80981 (the Bankai: Konpaku 1) + the clear ->
# CONTINUE (BANKAI -> KATATE); stage 4's line "P1 form nozarashi konpaku 3 awaken 0 meter 10"; pause -> RETIRE ->
# "duel endless over stages 3 ... record T"; NEW RUN -> pause -> RETIRE -> "over stages 0 ... best 3"; then the autopilot
# once (80992: P1 Kenpachi as a HARD CPU, seed 1, CONTINUE every clear): "duel endless over" + "duel endless gate".
# Portrait (--mobile --size 390x844, duel-endless-portrait.json, --secs 60) by taps: P1 Yamamoto, stage 1 cleared,
# stage 2 in BANKAI-WEST (80985) -> REVERT, stage 3 retired from the pause chip.
# Shots tests/shots/duel-endless-*.png; python3 tests/endless-sheet.py builds the contact sheet.
def endless_script(portrait):
    tag = "-p" if portrait else ""
    def es(t, n): return {"at": round(t, 2), "shot": f"{SHOTS}endless{tag}-{n}.png"}
    def touch(t, x, y): return [{"at": round(t, 2), "touch": "start", "x": x, "y": round(y)}, {"at": round(t + 0.05, 2), "touch": "end", "x": x, "y": round(y)}]
    H, ROW = 844, 36.67                                  # portrait CSS px: a menu row is 22 s (s = 5 at DPR 3)
    def row(y0, i): return y0 * H + 12 + i * ROW         # the i-th row of a HUD-MENU starting at Y0 (fraction of h)
    t = T0; ev = [cmd(t - 0.5, 2106)]
    if portrait:
        ev += touch(t, 195, 500) + [es(t + 0.8, "mode")] + touch(t + 1.8, 195, row(0.52, 1))   # title; MODE row 1
        ev += touch(t + 3.0, 195, 600) + [es(t + 3.8, "select")] + touch(t + 4.6, 195, 600)   # P1 Yamamoto; START NORMAL
        ev += touch(t + 6.5, 195, 400)                                                         # skip the intro
    else:
        ev += tap(t, "Enter") + [es(t + 0.8, "mode")] + tap(t + 1.8, "ArrowDown") + tap(t + 2.1, "Enter")
        ev += tap(t + 3.0, "KeyD") + tap(t + 3.3, "Enter") + [es(t + 3.9, "select")] + tap(t + 4.8, "Enter")
        ev += tap(t + 6.5, "Escape")
    t += 8.0
    ev += [es(t, "hud"), cmd(t + 1.0, 80980), es(t + 6.0, "clear")]                           # stage 1 -> STAGE CLEAR
    ev += touch(t + 7.0, 195, row(0.8, 0)) if portrait else tap(t + 7.0, "Enter")              # CONTINUE
    ev += touch(t + 9.0, 195, 400) if portrait else tap(t + 9.0, "Escape")                     # skip the intro
    t += 11.0
    ev += [cmd(t, 80985 if portrait else 80987), es(t + 5.0, "clear-awakened")]              # stage 2, awakened
    ev += touch(t + 6.0, 195, row(0.8, 1)) if portrait else tap(t + 6.0, "ArrowDown") + tap(t + 6.3, "Enter")   # REVERT
    ev += touch(t + 8.0, 195, 400) if portrait else tap(t + 8.0, "Escape")
    t += 10.0
    if not portrait:
        ev += [cmd(t, 80981), cmd(t + 9.0, 80980), es(t + 14.0, "clear-bankai")] + tap(t + 15.0, "Enter")   # stage 3
        ev += tap(t + 17.0, "Escape"); t += 19.0
    ev += [es(t, "hud-4" if not portrait else "hud-3")]
    if portrait: ev += touch(t + 1.0, 358, 200) + [es(t + 1.8, "pause")] + touch(t + 2.6, 195, row(0.45, 1))   # II, RETIRE
    else: ev += tap(t + 1.0, "Escape") + [es(t + 1.8, "pause")] + tap(t + 2.6, "ArrowDown") + tap(t + 2.9, "Enter")
    ev += [es(t + 7.0, "results")]
    t += 8.0
    if not portrait:
        ev += tap(t, "Enter") + tap(t + 8.0, "Escape") + tap(t + 8.4, "ArrowDown") + tap(t + 8.7, "Enter")   # the intro ran out
        ev += [es(t + 13.0, "results-best")]; t += 14.0                                        # NEW RUN, retired: BEST 3
        ev += [cmd(t, 80992)]                                                                  # the autopilot, one run
    return ev
write("endless", endless_script(False))
write("endless-portrait", endless_script(True))
# DANGAI (docs/duel/DUEL_ROGUE.md batches 1-2; --fixed-dt 16.666667 --secs 80): MODE row 2 -> P1 Kenpachi -> START NORMAL;
# stage 1 cleared by 80980 -> CONTINUE -> REWARD (shot, GENERIC: 3 cards) -> card 0 -> DOORS (shot: the reward types) ->
# door 0; stage 2: every category filled by debug 84501-84522 and the stage's reward forced GENERIC (84550), cleared ->
# REWARD (every card REPLACE, shot) -> card 0 -> the drop menu (shot) -> its row 0 -> DOORS -> door 1; stage 3 (an elite,
# RARE) cleared -> RARE REWARD (shot) -> card 0 -> DOORS -> door 0; stage 4: pause RETIRE -> RESULTS (the BUILD line).
# Log: "duel rogue reward step 1 pick ...", "duel rogue reward step 2 pick ... replace ...", "duel rogue mods (...)".
def rogue_script():
    def es(t, n): return {"at": round(t, 2), "shot": f"{SHOTS}rogue-{n}.png"}
    t = T0; ev = [cmd(t - 0.5, 2106)]
    ev += tap(t, "Enter") + tap(t + 1.8, "ArrowDown") + tap(t + 2.0, "ArrowDown") + tap(t + 2.3, "Enter")
    ev += tap(t + 3.0, "KeyD") + tap(t + 3.3, "Enter") + tap(t + 4.8, "Enter") + tap(t + 6.5, "Escape")
    t += 8.0
    ev += [cmd(t, 80980), es(t + 5.0, "clear")] + tap(t + 6.0, "Enter") + [es(t + 7.5, "reward")] + tap(t + 8.0, "Enter")
    ev += [es(t + 9.5, "doors")] + tap(t + 10.0, "Enter") + tap(t + 12.0, "Escape"); t += 14.0
    ev += [cmd(t + 0.1 * i, c) for i, c in enumerate((84501, 84502, 84507, 84508, 84513, 84517, 84522, 84550))]
    ev += [cmd(t + 1.0, 80980)] + tap(t + 7.0, "Enter") + [es(t + 8.5, "reward-replace")] + tap(t + 9.0, "Enter")
    ev += [es(t + 10.5, "replace")] + tap(t + 11.0, "Enter")
    ev += [es(t + 12.5, "doors-2")] + tap(t + 13.0, "ArrowDown") + tap(t + 13.3, "Enter") + tap(t + 15.0, "Escape"); t += 17.0
    ev += [cmd(t, 80980)] + tap(t + 6.0, "Enter") + [es(t + 7.5, "reward-rare")] + tap(t + 8.0, "Enter")
    ev += [es(t + 9.5, "doors-3")] + tap(t + 10.0, "Enter") + tap(t + 12.0, "Escape"); t += 14.0
    ev += tap(t, "Escape") + tap(t + 0.8, "ArrowDown") + tap(t + 1.1, "Enter") + [es(t + 6.0, "results")]
    return ev
write("rogue", rogue_script())
# the ENDLESS pacing check (debug 80990: every character x seeds 1-20, CONTINUE policy; 80991 for REVERT): one
# "duel endless over" line per run, then "duel endless gate P1 c policy stay runs 20 median m ..." per character
write("endless-gate", [cmd(T0, 80990)])
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

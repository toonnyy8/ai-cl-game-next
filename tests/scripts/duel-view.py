# SOUL DUEL art viewer scripts (tests/duel-view.lisp). Run: python3 tests/scripts/duel-view.py, then
#   node tools/run.mjs dist/duelview --secs 40  --script tests/scripts/duel-view-looks.json
#   node tools/run.mjs dist/duelview --secs 120 --script tests/scripts/duel-view-strips.json
#   node tools/run.mjs dist/duelview --secs 25  --script tests/scripts/duel-view-stage.json
#   node tools/run.mjs dist/duelview --secs 40  --script tests/scripts/duel-view-sounds.json
#   node tools/run.mjs dist/duelview --secs 20  --script tests/scripts/duel-view-strings.json   (the strings' new clips:
#     tests/shots/duel-string-*.png)
# Shots: tests/shots/duel-view-*.png. The clip indices follow the viewer's order (names sorted), which
# this script rebuilds by reading the DEFCLIP / DEFSTRIKE forms of the art files.
import json, re
T0 = 9.0                     # startup (meshes + sound synthesis) is done by then
SRC = ["duel/lisp/body.lisp", "duel/lisp/ken-art.lisp", "duel/lisp/ichigo-art.lisp"]
clips = set({m.group(2).upper() for f in SRC for m in re.finditer(r"^\((defclip|defstrike) :([a-z0-9-]+)", open(f).read(), re.M)}
               | {n.upper() for f in SRC for m in re.finditer(r"^\(defrun :[a-z0-9-]+ ((?::[a-z0-9-]+ ?)+)\)", open(f).read(), re.M)
                  for n in m.group(1).replace(":", "").split()})    # (DEFRUN base run skate-b slide-r slide-l)
clips |= {n.upper() for f in SRC for n in re.findall(r"^\s+'?\(\(?:([a-z0-9-]+) [\d.]+ \(\(", open(f).read(), re.M)}   # BUILD-CLIP tables
clips |= {n.upper() for f in SRC for m in re.finditer(r"for name in '\(((?::[a-z0-9-]+ ?)+)\)", open(f).read())
          for n in m.group(1).replace(":", "").split()}                  # (the oni's walk / run: ken-art.lisp)
clips = sorted(clips)

def script(name, build):
    ev, t = [], [T0]
    def cmd(c, wait=0.25): ev.append({"at": round(t[0], 2), "eval": f"Module._debug_cmd({c})"}); t[0] += wait
    def shot(n, wait=1.0): t[0] += wait; ev.append({"at": round(t[0], 2), "shot": f"tests/shots/duel-view-{n}.png"}); t[0] += 0.2
    build(cmd, shot, t)
    json.dump(ev, open(f"tests/scripts/duel-view-{name}.json", "w"), indent=0)
    print(f"duel-view-{name}.json: {len(ev)} steps, ends at {t[0]:.0f} s")

def looks(cmd, shot, t):
    for scene, who in ((0, ("ichigo", "ken")), (1, ("ichigo-kessa", "ken-nozarashi"))):
        cmd(2000 + scene)
        for i, w in enumerate(who):
            for deg, view in ((0, "front"), (90, "side"), (180, "back"), (35, "34")):
                cmd(3000 + deg); cmd(6000 + i); shot(f"{w}-{view}")
            cmd(3000); cmd(6100 + i); shot(f"{w}-face")
    cmd(2003); shot("mirror")
    cmd(2000); cmd(3035); shot("lineup")

def strips(cmd, shot, t):
    for i, n in enumerate(clips):
        cmd(1000000 + 1000 * i); shot(f"strip-{n.lower()}", 0.9)

def stage(cmd, shot, t):
    cmd(2004); shot("stage", 2.5)
    cmd(4002); shot("stage-cracks", 1.5)
    cmd(4003); cmd(2000); cmd(4000); shot("no-stage", 1.0)   # fighters only: cons/frame in the stats line
    t[0] += 4.5; cmd(4004); t[0] += 4.5                     # nothing drawn: the viewer's own baseline

def sounds(cmd, shot, t):
    for i in range(44): cmd(5000 + i, 0.8)

NEW = ("ke-kick",)   # the strings' new clips (docs/duel/DUEL_STRINGS.md §3)

def strings(cmd, shot, t):
    # their strips (0, S, S+A, end) as tests/shots/duel-string-*.png
    for n in NEW:
        cmd(1000000 + 1000 * clips.index(n.upper()))
        t[0] += 0.9; ev_shot(n)

def script(name, build):
    ev, t = [], [T0]
    def cmd(c, wait=0.25): ev.append({"at": round(t[0], 2), "eval": f"Module._debug_cmd({c})"}); t[0] += wait
    def shot(n, wait=1.0): t[0] += wait; ev.append({"at": round(t[0], 2), "shot": f"tests/shots/duel-view-{n}.png"}); t[0] += 0.2
    global ev_shot
    ev_shot = lambda n: (ev.append({"at": round(t[0], 2), "shot": f"tests/shots/duel-string-{n}.png"}), t.__setitem__(0, t[0] + 0.2))
    build(cmd, shot, t)
    json.dump(ev, open(f"tests/scripts/duel-view-{name}.json", "w"), indent=0)
    print(f"duel-view-{name}.json: {len(ev)} steps, ends at {t[0]:.0f} s")

# Yamamoto's Bankai, art K2 (DUEL_YAMA_CORE §17): the viewer built with yama-art.lisp too (tests/duel-view.lisp's header), so the clip
# indices count its clips; 8-frame strips from the side (k 1) and from 33 degrees off the front (k 2) of E-J1..3, NS1a..c, AS1 and the
# three stances: tests/shots/duel-view-yama-k2-<clip>-<side|front>.png
#   node tools/run.mjs dist/duelview --secs 40 --script tests/scripts/duel-view-yama-k2.json
YA_CLIPS = sorted(clips + [m.group(2).upper() for m in re.finditer(r"^\((defclip|defstrike) :([a-z0-9-]+)", open("duel/lisp/yama-art.lisp").read(), re.M)]
                  + [n.upper() for f in SRC + ["duel/lisp/yama-art.lisp"] for n in re.findall(r"\(defclip-mirror :([a-z0-9-]+)", open(f).read())])
                  # (+ DEFCLIP-MIRROR's clips, which CLIPS misses: Ichigo's ic-k-xb, so its indices past it run one short)
YA_K2 = ("ya-e-q1", "ya-e-q2", "ya-e-q3", "ya-e-kyokko", "ya-e-f2", "ya-kyoku", "ya-e-as1", "ya-st-higashi", "ya-st-nishi", "ya-st-minami")
def yama_k2(cmd, shot, t):
    for n in YA_K2:
        for k, view in ((1, "side"), (2, "front")):
            cmd(1000000 + 1000 * YA_CLIPS.index(n.upper()) + k); shot(f"yama-k2-{n}-{view}", 0.9)

# Art K3 (DUEL_YAMA_CORE §18): the same strips for 西, 南, 北's new and re-keyed clips (the viewer draws the blade in his hand: the planted
# blade of the grab / AS3b is the game's, PLANTED-SPOT): tests/shots/duel-view-yama-k3-<clip>-<side|front>.png
#   node tools/run.mjs dist/duelview --secs 60 --script tests/scripts/duel-view-yama-k3.json
YA_K3 = ("ya-shonetsu", "ya-e-advance", "ya-e-gokui-cut", "ya-e-grab", "ya-e-throw", "ya-kaka", "ya-e-minami-b", "ya-e-minami-c",
         "ya-e-as3a", "ya-e-as3b", "ya-e-as3c", "ya-e-tenchi")   # (ya-e-f1 left with art D: AS4's last its own clip)
def yama_k3(cmd, shot, t):
    for n in YA_K3:
        for k, view in ((1, "side"), (2, "front")):
            cmd(1000000 + 1000 * YA_CLIPS.index(n.upper()) + k); shot(f"yama-k3-{n}-{view}", 0.9)

# Art S2 (DUEL_YAMA_CORE §23): the same strips for the Shikai's re-keyed and new clips (J1 HISEN's own clip, J2 reused, J3 TSUKABI,
# pointer 1's NS1a / NS1b / NS1c and AS1, the three stances): tests/shots/duel-view-yama-s2-<clip>-<side|front>.png
#   node tools/run.mjs dist/duelview --secs 40 --script tests/scripts/duel-view-yama-s2.json
YA_S2 = ("ya-hisen", "ya-q2", "ya-tsuka", "ya-n1a", "ya-f2", "ya-n1c", "ya-as1", "ya-shiranui", "ya-st-enjo", "ya-st-cane")
def yama_s2(cmd, shot, t):
    for n in YA_S2:
        for k, view in ((1, "side"), (2, "front")):
            cmd(1000000 + 1000 * YA_CLIPS.index(n.upper()) + k); shot(f"yama-s2-{n}-{view}", 0.9)

# Art S3 (DUEL_YAMA_CORE §24): the same strips for pointer 2 / 3, AS2 / AS3, the SA and the Kikon strike:
# tests/shots/duel-view-yama-s3-<clip>-<side|front>.png
#   node tools/run.mjs dist/duelview --secs 50 --script tests/scripts/duel-view-yama-s3.json
YA_S3 = ("ya-n2a", "ya-n2b", "ya-n2c", "ya-as2a", "ya-as2b", "ya-n3a", "ya-n3b", "ya-nadegiri", "ya-as3a", "ya-as3b", "ya-as3c", "ya-taimatsu",
         "ya-strike")
def yama_s3(cmd, shot, t):
    for n in YA_S3:
        for k, view in ((1, "side"), (2, "front")):
            cmd(1000000 + 1000 * YA_CLIPS.index(n.upper()) + k); shot(f"yama-s3-{n}-{view}", 0.9)

# Art S4 (DUEL_YAMA_CORE §25): 爆炎's own clips (IKKOTSU, the entry pose, ENNETSU, the true NADEGIRI) on the bared body (the viewer draws
# IKKOTSU's blade in his hand: the planted blade is the game's): tests/shots/duel-view-yama-s4-<clip>-<side|front>.png
#   node tools/run.mjs dist/duelview --secs 20 --script tests/scripts/duel-view-yama-s4.json
YA_S4 = ("ya-ikkotsu", "ya-blaze-in", "ya-b-n2c", "ya-b-n3c")
def yama_s4(cmd, shot, t):
    for n in YA_S4:
        for k, view in ((1, "side"), (2, "front")):
            cmd(1000000 + 1000 * YA_CLIPS.index(n.upper()) + k); shot(f"yama-s4-{n}-{view}", 0.9)

# Art batch D (DUEL_YAMA_CORE §34): E-J4's stepping kesa cut and AS4's four clips (the ash grip, the ash cut, the ash line, 天地灰尽):
# tests/shots/duel-view-yama-d-<clip>-<side|front>.png
#   node tools/run.mjs dist/duelview --secs 25 --script tests/scripts/duel-view-yama-d.json
YA_D = ("ya-e-q4", "ya-e-as4a", "ya-e-as4b", "ya-e-as4c", "ya-e-as4")
def yama_d(cmd, shot, t):
    for n in YA_D:
        for k, view in ((1, "side"), (2, "front")):
            cmd(1000000 + 1000 * YA_CLIPS.index(n.upper()) + k); shot(f"yama-d-{n}-{view}", 0.9)

script("looks", looks); script("strips", strips); script("stage", stage); script("sounds", sounds); script("strings", strings)
script("yama-k2", yama_k2); script("yama-k3", yama_k3); script("yama-s2", yama_s2); script("yama-s3", yama_s3); script("yama-s4", yama_s4)
script("yama-d", yama_d)
print(len(clips), "clips:", " ".join(c.lower() for c in clips))

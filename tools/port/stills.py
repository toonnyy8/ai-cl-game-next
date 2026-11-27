#!/usr/bin/env python3
"""tools/port/stills.py — Lisp | Rust stills sheets (docs/bevy/M3A_NOTES.md §9; the M3a plan's Task 9).

  python3 tools/port/stills.py [SCENE...] [--rust DIST] [--lisp DIST] [--out DIR] [--reuse-lisp] [--twice] [--jobs N]

SCENE: a scenario of the looks gate (tests/style-gates.py looks_scenarios(), read, never edited): cvc-ik (alias 2005), cvc-ii
(alias 2006), cine-ken, cine-ichigo, cine-ko; default all five. Each is rendered from the frozen dist (--lisp, default
build/oracle/frozen-dist) and the Rust dist (--rust, default dist/rs-m3a) under `run.mjs --fixed-dt 16.666667 --size 640x360`
(the looks gate's size), from the same script with its key steps removed on both sides (Task 9's choice, from before the page had a
keyboard; kept so the SSIM table stays comparable: with the keys, the cvc scenarios' Enter would skip the intro on both sides). The
Rust page runs with `?stills` (RUN_QUERY): the title boot, no dev line (M3A_NOTES §10). Output in build/port/stills/: lisp/ and rust/ (the
stills and logs), one sheet per still (<scene>-<still>.png: Lisp | Rust | diff x4, the SSIM on top) and stills.tsv (scene, still,
SSIM, max channel diff, pixels that differ). --reuse-lisp keeps the frozen side's stills from an earlier run; --twice renders the
Rust side a second time into rust2/ and checks every still byte for byte (the page's determinism). --out: another output directory
(default build/port/stills; --reuse-lisp then reads the frozen stills from it).

SSIM: Wang et al. 2004 on the luma (BT.601), an 11 x 11 Gaussian window (sigma 1.5), K1 0.01, K2 0.03, L 255, the mean over the
image (numpy only: skimage is not installed and no pip dependency is added).
"""
import hashlib, importlib.util, json, os, subprocess, sys, time
import numpy as np
from PIL import Image, ImageDraw

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
OUT = os.path.join(ROOT, "build/port/stills")
ALIAS = {"2005": "cvc-ik", "2006": "cvc-ii"}
DEFAULT = ["cvc-ik", "cvc-ii", "cine-ken", "cine-ichigo", "cine-ko"]


def scenarios():
    spec = importlib.util.spec_from_file_location("style_gates", os.path.join(ROOT, "tests/style-gates.py"))
    m = importlib.util.module_from_spec(spec)
    cwd = os.getcwd(); os.chdir(ROOT)           # (it makes build/style/ relative to the cwd at import)
    try: spec.loader.exec_module(m)
    finally: os.chdir(cwd)
    return m.looks_scenarios()


def render(dist, name, steps, secs, tag):
    """Start run.mjs for one scenario; returns (Popen, log path). Stills go to OUT/TAG/NAME-<still>.png."""
    d = os.path.join(OUT, tag); os.makedirs(d, exist_ok=True)
    st = [dict(e, shot=f"{d}/{name}-{e['shot']}.png") if "shot" in e else e for e in steps if "key" not in e]
    sp = os.path.join(d, f"{name}.json"); json.dump(st, open(sp, "w"))
    log = os.path.join(d, f"{name}.log")
    args = ["node", os.path.join(ROOT, "tools/run.mjs"), dist, "--secs", str(secs), "--script", sp, "--size", "640x360",
            "--fixed-dt", "16.666667", "--timeout", "3000"]
    # the Rust page boots into a VS CPU fight with its dev text line (M3A_NOTES §10); `?stills` keeps the title boot the looks gate's
    # scripts expect (their debug command starts the fight) and draws no dev line
    env = dict(os.environ, RUN_QUERY="?stills") if tag.startswith("rust") else None
    return subprocess.Popen(args, stdout=open(log, "w"), stderr=subprocess.STDOUT, env=env), log


def luma(p):
    a = np.asarray(Image.open(p).convert("RGB")).astype(np.float64)
    return a, a @ np.array([0.299, 0.587, 0.114])


def blur(x, k):
    """Separable 'valid' convolution with the 1-D kernel K along both axes."""
    n = len(k)
    y = sum(k[i] * x[:, i:x.shape[1] - n + 1 + i] for i in range(n))
    return sum(k[i] * y[i:y.shape[0] - n + 1 + i, :] for i in range(n))


def ssim(a, b):
    g = np.exp(-((np.arange(11) - 5) ** 2) / (2 * 1.5 ** 2)); g /= g.sum()
    c1, c2 = (0.01 * 255) ** 2, (0.03 * 255) ** 2
    ma, mb = blur(a, g), blur(b, g)
    va, vb, cov = blur(a * a, g) - ma * ma, blur(b * b, g) - mb * mb, blur(a * b, g) - ma * mb
    return float((((2 * ma * mb + c1) * (2 * cov + c2)) / ((ma * ma + mb * mb + c1) * (va + vb + c2))).mean())


def sheet(name, still, lp, rp):
    (la, ll), (ra, rl) = luma(lp), luma(rp)
    if la.shape != ra.shape: return None, -1, -1
    s = ssim(ll, rl)
    d = np.abs(la - ra).max(-1)
    diff = np.clip(d * 4, 0, 255).astype(np.uint8)
    h, w = la.shape[:2]
    img = Image.new("RGB", (3 * w + 20, h + 28), (20, 20, 25))
    for i, im in enumerate((Image.open(lp).convert("RGB"), Image.open(rp).convert("RGB"), Image.fromarray(diff).convert("RGB"))):
        img.paste(im, (i * (w + 10), 28))
    ImageDraw.Draw(img).text((6, 8), f"{name} {still}   Lisp | Rust | diff x4   SSIM {s:.4f}   max {int(d.max())}   {int((d > 0).sum())} px differ", fill=(230, 230, 230))
    img.save(os.path.join(OUT, f"{name}-{still}.png"))
    return s, int(d.max()), int((d > 0).sum())


def main():
    global OUT
    a = sys.argv[1:]
    opt = lambda k, dflt: a[a.index(k) + 1] if k in a else dflt
    OUT = os.path.abspath(opt("--out", OUT))
    rust = os.path.abspath(opt("--rust", os.path.join(ROOT, "dist/rs-m3a")))
    lisp = os.path.abspath(opt("--lisp", os.path.join(ROOT, "build/oracle/frozen-dist")))
    jobs = int(opt("--jobs", "3"))
    skip = {i + 1 for i, x in enumerate(a) if x in ("--rust", "--lisp", "--jobs", "--out")}
    names = [ALIAS.get(x, x) for i, x in enumerate(a) if not x.startswith("--") and i not in skip] or DEFAULT
    # the frozen browser build only (as tools/port/oracle/gen.py checks it: index.wasm sha256 e35032a7...)
    wasm = hashlib.sha256(open(os.path.join(lisp, "index.wasm"), "rb").read()).hexdigest()
    if not wasm.startswith("e35032a7"):
        sys.exit(f"stills: {lisp}/index.wasm is {wasm[:8]}, not the frozen build e35032a7")
    sc = scenarios()
    for n in names:
        if n not in sc: sys.exit(f"stills: no scenario {n} (have: {', '.join(sorted(sc))})")
    todo = []
    for n in names:
        steps, secs, _ = sc[n]
        if "--reuse-lisp" not in a: todo.append((lisp, n, steps, secs, "lisp"))
        todo.append((rust, n, steps, secs, "rust"))
        if "--twice" in a: todo.append((rust, n, steps, secs, "rust2"))
    t0, running, bad = time.time(), [], []
    while todo or running:
        while todo and len(running) < jobs:
            dist, n, steps, secs, tag = todo.pop(0)
            p, log = render(dist, n, steps, secs, tag)
            running.append((p, log, tag, n))
        for r in list(running):
            if r[0].poll() is not None:
                running.remove(r)
                if r[0].returncode != 0: bad.append(f"{r[2]}/{r[3]} exit {r[0].returncode} (log {r[1]})")
        time.sleep(0.5)
    print(f"stills: rendered in {time.time() - t0:.0f} s" + ("" if not bad else "; FAILED runs: " + "; ".join(bad)))
    rows = []
    for n in names:
        for e in sc[n][0]:
            if "shot" not in e: continue
            lp, rp = (os.path.join(OUT, t, f"{n}-{e['shot']}.png") for t in ("lisp", "rust"))
            if not (os.path.exists(lp) and os.path.exists(rp)):
                rows.append((n, e["shot"], "missing", "", "")); continue
            s, mx, px = sheet(n, e["shot"], lp, rp)
            if s is None:
                rows.append((n, e["shot"], "size mismatch", "", "")); continue
            same = ""
            if "--twice" in a:
                r2 = os.path.join(OUT, "rust2", f"{n}-{e['shot']}.png")
                same = "rust twice: " + ("bytes identical" if os.path.exists(r2) and open(rp, "rb").read() == open(r2, "rb").read() else "DIFFER")
            rows.append((n, e["shot"], f"{s:.4f}", mx, px, same))
    with open(os.path.join(OUT, "stills.tsv"), "w") as f:
        f.write("scene\tstill\tssim\tmax\tpx_differ\n")
        for r in rows: f.write("\t".join(map(str, r[:5])) + "\n")
    for r in rows: print("  ".join(map(str, r)))
    print(f"sheets: {OUT}/<scene>-<still>.png, table {OUT}/stills.tsv")
    sys.exit(1 if bad or any(r[2] in ("missing", "size mismatch") for r in rows) or any("DIFFER" in str(r[-1]) for r in rows) else 0)


if __name__ == "__main__":
    main()

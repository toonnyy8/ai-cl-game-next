#!/usr/bin/env python3
"""sdf-bake.py — bake the Lisp HUD's text atlas (docs/duel/DUEL_LISP_HUD.md §4.2): single-channel signed distance fields of
the glyphs the HUD shows, from the faces the HTML UI used (removed 2026-11-11, DUEL_LISP_HUD §16), into duel/hud-font/atlas.r8 + metrics.bin (committed; the build
embeds them as static data through duel/hud-font/lhud-font.c; each face's OFL.txt is copied to duel/FONT-LICENSE-<face>.txt). Build-time only: no font file is tracked.

  build/sdf-venv/bin/python -I tools/sdf-bake.py [--fetch]

--fetch downloads the four faces and their OFL.txt from the Google Fonts repository (github.com/google/fonts, ofl/) into
build/font-cache/<face>/ (git-ignored), once. Needs fonttools, skia-pathops, numpy (`uv venv build/sdf-venv && uv pip install
--python build/sdf-venv/bin/python fonttools skia-pathops numpy`).

The charset: every face gets printable ASCII (Mincho: none); the rest comes from the HUD's Lisp files (duel/lisp/lhud-*.lisp) alone:
a string in (kj "...") goes to the Mincho, (zh "...") to the sans (and the Latin faces, for the non-CJK symbols they carry), (big "...")
to the display tier of the display face. tests/duel-rules/lhud-charset.lisp fails when a string the HUD can show has a character no
tag form names (every literal of those files but the docstrings, the model's writers, the kits' texts).
Per glyph: the outline with its overlaps removed (pathops), flattened (chord error <= FLAT px at the bake size), the exact
distance from each texel centre to the nearest segment (numpy), inside by even-odd crossings; stored as
clamp(0.5 + d / (2 SPREAD), 0, 1) * 255 (the edge at 128, inside > 128). Tiers: body = a 32 px em, display = a 96 px em, both
with a 4 px spread. Cells are packed in shelves (rows by height) into one R8 texture ATLAS_W wide.

metrics.bin (little-endian int16 / uint16):
  header 16 words: 'SD', version 1, glyph count, atlas w, atlas h, body em px, display em px, spread px, face count, 0 ...
  per face 4 words: ascent, descent (1/1000 em, positive down; the hhea values, or OS/2 typo when USE_TYPO_METRICS is set: what
                    Chrome uses for the line box), 0, 0
  per glyph 9 words, sorted by (tier * 4 + face) * 65536 + code: code, tier * 4 + face, atlas x, y, w, h,
                    cell left (px from the pen), cell top (px above the baseline), advance (1/64 px), all at the tier's em
"""
import math, os, re, struct, sys, urllib.request
import numpy as np
from fontTools.ttLib import TTFont
from fontTools.pens.basePen import BasePen
from fontTools import subset
from fontTools.varLib import instancer
import pathops

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
CACHE = os.path.join(ROOT, "build/font-cache")
OUT = os.path.join(ROOT, "duel/hud-font")
REPO = "https://raw.githubusercontent.com/google/fonts/main/ofl/"
# face index -> (name, repo dir, file, axes to pin): the HTML UI's faces, one weight each (DUEL_LISP_HUD §4.2)
FACES = [("display", "bigshouldersdisplay", "BigShouldersDisplay[wght].ttf", {"wght": 900}),
         ("mono", "martianmono", "MartianMono[wdth,wght].ttf", {"wght": 600, "wdth": 100}),
         ("kanji", "shipporiminchob1", "ShipporiMinchoB1-ExtraBold.ttf", {}),
         ("sans", "notosanstc", "NotoSansTC[wght].ttf", {"wght": 500})]
BODY_EM, DISPLAY_EM, SPREAD, FLAT, ATLAS_W = 32, 96, 4, 0.1, 1024
ASCII = "".join(chr(c) for c in range(32, 127)) + "·×"   # (the tags' middle dot and the clone count's ×)
# shapes baked as glyphs at private-use codes (DUEL_LISP_HUD §14): code, face, SVG path, its viewBox height (= 1 em, the baseline at
# the bottom), advance (viewBox units). Body tier only: the 4 px spread at a 32 px em is 1.75 units of a 14-unit flame, room for the
# stake's 2.4-unit blood stroke drawn as an outline band (1.2 each side of the path); the display tier's spread would clip it.
SHAPES = [(0xE000, 3, "M5 .6C6.4 3 9.2 5.4 9.2 8.6A4.2 4.2 0 0 1 .8 8.6C.8 6.6 2.2 5.2 3 3.6 3.4 5 4 5.6 4.8 5.8 4.4 4 4.6 2.2 5 .6z",
           14, 10)]   # hud.js SOUL, the soul flame (viewBox 0 0 10 14)


def fetch():
    for _, d, f, _ in FACES:
        os.makedirs(os.path.join(CACHE, d), exist_ok=True)
        for name in (f, "OFL.txt"):
            dst = os.path.join(CACHE, d, name)
            if not os.path.exists(dst):
                url = REPO + d + "/" + name.replace("[", "%5B").replace("]", "%5D")
                print("fetch", url); urllib.request.urlretrieve(url, dst)


def lhud_sources():
    """The Lisp HUD's files (duel/lisp/lhud-*.lisp) with their ; comments blanked: (name, text)."""
    d = os.path.join(ROOT, "duel/lisp")
    for fn in sorted(os.listdir(d)):
        if fn.startswith("lhud-") and fn.endswith(".lisp"):
            yield fn, re.sub(r'("(?:[^"\\]|\\.)*")|;[^\n]*', lambda m: m.group(1) or "", open(os.path.join(d, fn), encoding="utf-8").read())


def charset():
    """(face, tier) -> the chars to bake, and the chars drawn as shapes. ASCII for the Latin faces and the sans; the tagged strings
    of duel/lisp/lhud-*.lisp ((kj) Mincho body, (bigkj) Mincho display, (big) display face display tier, (zh) sans, (lhud-shape) none);
    the zh strings' non-CJK symbols also in the Latin faces (a Latin face keeps the symbols it has; the rest falls to the sans)."""
    want = {(0, 0): set(ASCII), (1, 0): set(ASCII), (2, 0): set(), (3, 0): set(ASCII) | {"\u25a1"}, (0, 1): set(), (2, 1): set()}
    tag = {"kj": (2, 0), "bigkj": (2, 1), "zh": (3, 0), "big": (0, 1)}
    shapes = set()
    for _, src in lhud_sources():
        for t, s in re.findall(r'\((kj|bigkj|zh|big|lhud-shape)\s+"((?:[^"\\]|\\.)*)"', src):
            if t == "lhud-shape": shapes |= set(s)
            else: want[tag[t]] |= set(s) - {" "} if t != "big" else set(s)
    sym = {c for c in want[(3, 0)] if 127 < ord(c) < 0x2E80}
    for f in (0, 1): want[(f, 0)] |= sym
    return want, shapes


class Flatten(BasePen):
    """Contours as point lists, curves flattened to a chord error of TOL font units (as tools/glyph-bake.py's)."""
    def __init__(self, gs, tol):
        super().__init__(gs); self.contours = []; self.cur = None; self.tol = tol

    def _moveTo(self, p): self.cur = [p]
    def _lineTo(self, p): self.cur.append(p)

    def _curve(self, pts, f):
        p0 = self.cur[-1]; n = max(1, math.ceil(math.sqrt(sum(math.dist(a, b) for a, b in zip([p0] + pts, pts)) / (8 * self.tol))))
        for i in range(1, n + 1): self.cur.append(f(p0, *pts, i / n))

    def _qCurveToOne(self, a, b):
        self._curve([a, b], lambda p0, p1, p2, t: tuple((1 - t) ** 2 * p0[k] + 2 * (1 - t) * t * p1[k] + t * t * p2[k] for k in (0, 1)))

    def _curveToOne(self, a, b, c):
        self._curve([a, b, c], lambda p0, p1, p2, p3, t: tuple((1 - t) ** 3 * p0[k] + 3 * (1 - t) ** 2 * t * p1[k]
                                                               + 3 * (1 - t) * t * t * p2[k] + t ** 3 * p3[k] for k in (0, 1)))

    def _closePath(self):
        if self.cur and len(self.cur) > 2: self.contours.append(self.cur)
        self.cur = None
    _endPath = _closePath


def load_face(i, chars):
    _, d, f, axes = FACES[i]
    font = TTFont(os.path.join(CACHE, d, f))
    if chars:                                              # subset first: instancing all of Noto Sans TC is slow
        opt = subset.Options(); opt.layout_features = []; opt.notdef_outline = True; opt.name_IDs = ["*"]
        sub = subset.Subsetter(opt); sub.populate(unicodes=[ord(c) for c in chars]); sub.subset(font)
    if "fvar" in font: font = instancer.instantiateVariableFont(font, axes)
    return font


def face_metrics(font):
    upm = font["head"].unitsPerEm; os2 = font["OS/2"]; hh = font["hhea"]
    a, dsc = (os2.sTypoAscender, os2.sTypoDescender) if os2.fsSelection & (1 << 7) else (hh.ascent, hh.descent)
    return round(1000 * a / upm), round(-1000 * dsc / upm)


def sdf(contours, s, pad):
    """The cell (R8 rows, left px, top px) of one glyph: CONTOURS in font units, S px per unit, PAD texels around the ink."""
    if not contours: return None, 0, 0
    pts = [np.array(c, dtype=np.float64) * s for c in contours]
    allp = np.concatenate(pts)
    x0 = math.floor(allp[:, 0].min()) - pad; x1 = math.ceil(allp[:, 0].max()) + pad
    y0 = math.floor(allp[:, 1].min()) - pad; y1 = math.ceil(allp[:, 1].max()) + pad   # (y up)
    a = np.concatenate([p for p in pts]); b = np.concatenate([np.roll(p, -1, axis=0) for p in pts])
    w, h = x1 - x0, y1 - y0
    xs = x0 + 0.5 + np.arange(w); ys = y1 - 0.5 - np.arange(h)
    px, py = np.meshgrid(xs, ys); P = np.stack([px.ravel(), py.ravel()], 1)
    ab = b - a; L2 = np.maximum((ab ** 2).sum(1), 1e-12)
    out = np.empty(len(P))
    for k in range(0, len(P), 2048):                       # (chunks: texels x segments)
        q = P[k:k + 2048, None, :]
        t = np.clip(((q - a) * ab).sum(2) / L2, 0, 1)
        dist = np.sqrt((((a + t[..., None] * ab) - q) ** 2).sum(2)).min(1)
        qy = q[..., 1]; qx = q[..., 0]
        crosses = ((a[:, 1] <= qy) != (b[:, 1] <= qy)) & (qx < a[:, 0] + (qy - a[:, 1]) * ab[:, 0] / np.where(ab[:, 1] == 0, 1e-12, ab[:, 1]))
        inside = crosses.sum(1) % 2 == 1
        out[k:k + 2048] = np.where(inside, dist, -dist)
    v = np.clip(0.5 + out / (2 * SPREAD), 0, 1)
    return (np.round(v * 255).astype(np.uint8).reshape(h, w)), x0, y1


def bake():
    want, shapes = charset(); faces = {}; glyphs = []
    sans = set(TTFont(os.path.join(CACHE, FACES[3][1], FACES[3][2])).getBestCmap())
    gone = {c for c in want[(3, 0)] if ord(c) not in sans}  # (e.g. the Japanese 闘: the Mincho stands in, as a browser's next CJK face)
    want[(3, 0)] -= gone; want[(2, 0)] |= gone
    for (fi, tier), chars in sorted(want.items()):
        if not chars: continue
        allc = set().union(*(c for (f2, _), c in want.items() if f2 == fi))
        font = faces.get(fi) or faces.setdefault(fi, load_face(fi, allc))
        cmap = font.getBestCmap(); gs = font.getGlyphSet(); hm = font["hmtx"]; upm = font["head"].unitsPerEm
        em = DISPLAY_EM if tier else BODY_EM; s = em / upm
        missing = [c for c in chars if ord(c) not in cmap]
        if missing and (fi, tier) not in ((0, 0), (1, 0)): print(f"face {FACES[fi][0]} tier {tier}: not in the font: {''.join(sorted(missing))!r} (the sans, then the Mincho stand in)")
        for c in sorted(chars):
            if ord(c) not in cmap: continue
            name = cmap[ord(c)]
            p = pathops.Path(); gs[name].draw(p.getPen(glyphSet=gs)); p.simplify()
            fl = Flatten(gs, FLAT / s); p.draw(fl)
            cell, left, top = sdf(fl.contours, s, SPREAD)
            glyphs.append(dict(code=ord(c), ft=tier * 4 + fi, cell=cell, left=left, top=top, adv=round(hm[name][0] * s * 64)))
    from fontTools.svgLib.path import parse_path
    for code, fi, d, vh, adv in SHAPES:                    # (y flipped: font units up, the baseline at the viewBox's bottom)
        fl = Flatten(None, FLAT * vh / BODY_EM); parse_path(d, fl)
        fl.contours = [[(x, vh - y) for x, y in c] for c in fl.contours]
        cell, left, top = sdf(fl.contours, BODY_EM / vh, SPREAD)
        glyphs.append(dict(code=code, ft=fi, cell=cell, left=left, top=top, adv=round(adv * BODY_EM / vh * 64)))
    have = {g["code"] for g in glyphs if g["ft"] in (2, 3)}
    lost = sorted(c for (fi, t), cs in want.items() if fi in (2, 3) and t == 0 for c in cs if ord(c) not in have)
    if lost: sys.exit(f"no face has {''.join(lost)!r}: list it in an (lhud-shape \"...\") form of duel/lisp/lhud-charset.lisp (drawn as a shape) or fix the string")
    # shelf packing, tallest first
    order = sorted(range(len(glyphs)), key=lambda i: -(glyphs[i]["cell"].shape[0] if glyphs[i]["cell"] is not None else 0))
    x = y = rowh = 0
    for i in order:
        g = glyphs[i]; c = g["cell"]
        if c is None: g["x"] = g["y"] = g["w"] = g["h"] = 0; continue
        h, w = c.shape
        if x + w > ATLAS_W: x, y, rowh = 0, y + rowh + 1, 0
        g["x"], g["y"], g["w"], g["h"] = x, y, w, h; x += w + 1; rowh = max(rowh, h)
    ah = 1 << max(4, math.ceil(math.log2(y + rowh + 1)))   # (a power of two tall)
    atlas = np.zeros((ah, ATLAS_W), np.uint8)
    for g in glyphs:
        if g["cell"] is not None: atlas[g["y"]:g["y"] + g["h"], g["x"]:g["x"] + g["w"]] = g["cell"]
    glyphs.sort(key=lambda g: g["ft"] * 65536 + g["code"])
    hdr = [0x4453, 1, len(glyphs), ATLAS_W, ah, BODY_EM, DISPLAY_EM, SPREAD, len(FACES)] + [0] * 7
    fm = []
    for fi in range(len(FACES)):
        fm += list(face_metrics(faces[fi])) + [0, 0] if fi in faces else [800, 200, 0, 0]
    rows = [[g["code"], g["ft"], g["x"], g["y"], g["w"], g["h"], g["left"], g["top"], g["adv"]] for g in glyphs]
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, "metrics.bin"), "wb") as f:
        f.write(struct.pack("<16H", *hdr)); f.write(struct.pack(f"<{len(fm)}h", *fm))
        for r in rows: f.write(struct.pack("<2H4H3h", *r))
    atlas.tofile(os.path.join(OUT, "atlas.r8"))
    for _, d, f, _ in FACES:                               # the OFL travels with the glyphs: duel/FONT-LICENSE-<face>.txt
        name = re.sub(r"[\[-].*", "", f.replace(".ttf", ""))
        with open(os.path.join(CACHE, d, "OFL.txt"), "rb") as src, open(os.path.join(ROOT, f"duel/FONT-LICENSE-{name}.txt"), "wb") as dst:
            dst.write(src.read())
    by = {}
    for g in glyphs: by.setdefault(g["ft"], []).append(g)
    for ft, gl in sorted(by.items()):
        tex = sum(g["w"] * g["h"] for g in gl)
        print(f"{FACES[ft % 4][0]:8s} tier {ft // 4}: {len(gl):4d} glyphs, {tex:8d} texels ({tex / max(1, len(gl)):.0f} a glyph)")
    print(f"atlas {ATLAS_W} x {ah} = {ATLAS_W * ah} bytes ({y + rowh} rows used), metrics {16 * 2 + len(fm) * 2 + 18 * len(rows)} bytes")


if __name__ == "__main__":
    if "--fetch" in sys.argv: fetch()
    bake()

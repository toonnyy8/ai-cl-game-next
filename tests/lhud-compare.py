#!/usr/bin/env python3
"""lhud-compare.py — side-by-side stills of the HTML HUD and the Lisp HUD (docs/duel/DUEL_LISP_HUD.md §4.6): each pair as
[HTML | Lisp | difference x4], optionally cropped and magnified (nearest), plus the mean / max channel difference.

  python3 tests/lhud-compare.py OUT.png HTML.png LISP.png [--crop x0,y0,x1,y1] [--zoom N]
"""
import sys
from PIL import Image, ImageChops

a = sys.argv[1:]
opt = lambda k, d=None: a[a.index(k) + 1] if k in a else d
out, html, lisp = a[0], Image.open(a[1]).convert("RGB"), Image.open(a[2]).convert("RGB")
crop = opt("--crop")
if crop:
    box = tuple(int(v) for v in crop.split(","))
    html, lisp = html.crop(box), lisp.crop(box)
diff = ImageChops.difference(html, lisp)
st = [px for px in diff.getdata()]
mean = sum(sum(p) for p in st) / (3 * len(st)); mx = max(max(p) for p in st)
diff = diff.point(lambda v: min(255, 4 * v))
w, h = html.size
sheet = Image.new("RGB", (3 * w + 8, h), (255, 0, 255))
for i, im in enumerate((html, lisp, diff)): sheet.paste(im, (i * (w + 4), 0))
z = int(opt("--zoom", "1"))
if z > 1: sheet = sheet.resize((sheet.width * z, sheet.height * z), Image.NEAREST)
sheet.save(out)
print(f"{out}: {w}x{h}, mean diff {mean:.2f}, max {mx}")

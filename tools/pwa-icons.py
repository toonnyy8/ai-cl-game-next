#!/usr/bin/env python3
"""pwa-icons.py — draw SOUL DUEL NEXT's app icons into duel/web/ (PIL only, already used by the tests):
icon-192.png, icon-512.png, icon-maskable-512.png (the mark inside the 80 % safe circle) and apple-touch-icon.png
(180 px, opaque). The mark (the user, 2026-10-29: 「以代理死神證作為 icon」, then a photo of the badge): the Substitute Shinigami
Badge as it looks: a pentagon point down, a black rim round a white face, a black angular skull with round eyes and a toothed jaw
over a black X, its hanging tab on top, on the dusk ink (a little flatter than a regular pentagon; no cord). (Before: a pale soul ring cut by a red brush slash.)
python3 tools/pwa-icons.py"""
import math
from PIL import Image, ImageDraw

BG, PAPER, BLACK = (7, 7, 12, 255), (236, 238, 240, 255), (14, 14, 18, 255)


FLAT = .84   # the badge's height over a regular pentagon's (the user, 2026-10-29: 「稍微扁一點」)


def pent(cx, cy, r):
    """A pentagon, point down (its top edge flat), squashed to FLAT of its height."""
    return [(cx + r * math.sin(math.radians(a)), cy - FLAT * r * math.cos(math.radians(a))) for a in (180 + 72 * i for i in range(5))]


def icon(size, scale=1.0):
    k = 4                                              # supersample, then shrink (smooth edges)
    n = size * k
    im = Image.new("RGBA", (n, n), BG)
    d = ImageDraw.Draw(im)
    s = n * scale
    cx, cy, R = n / 2, n / 2 + .05 * s, .46 * s
    top = cy - FLAT * R * math.cos(math.radians(36))   # the flat top edge's height
    d.rounded_rectangle([cx - .07 * s, top - .075 * s, cx + .07 * s, top + .01 * s], radius=.015 * s, fill=PAPER)   # the hanging tab
    d.rounded_rectangle([cx - .045 * s, top - .055 * s, cx + .045 * s, top - .02 * s], radius=.008 * s, fill=BG)
    d.polygon(pent(cx, cy, R), fill=PAPER)             # a pale edge (the black rim would sink into the ink)
    d.polygon(pent(cx, cy, R * .95), fill=BLACK)       # the rim
    d.polygon(pent(cx, cy, R * .8), fill=PAPER)        # the face
    # the X behind the skull: two black bars from the face's upper corners to the middle of its far lower edges, cut by the rim, a white
    # line down each
    face = pent(cx, cy, R * .8)                        # (point down: bottom, lower left, upper left, upper right, lower right)
    u = .01 * s
    bars = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    g = ImageDraw.Draw(bars)
    mid = lambda p, q: ((p[0] + q[0]) / 2, (p[1] + q[1]) / 2)
    for a, b in ((face[2], mid(face[4], face[0])), (face[3], mid(face[1], face[0]))):   # an upper corner to the far lower edge
        a, b = (a[0] - .3 * (b[0] - a[0]), a[1] - .3 * (b[1] - a[1])), (b[0] + .3 * (b[0] - a[0]), b[1] + .3 * (b[1] - a[1]))
        g.line([a, b], fill=BLACK, width=int(8 * u))
        off = 1.9 * u * (1 if a[0] < cx else -1)
        g.line([(a[0], a[1] - off), (b[0], b[1] - off)], fill=PAPER, width=max(1, int(1.1 * u)))
    mask = Image.new("L", (n, n), 0)
    ImageDraw.Draw(mask).polygon(face, fill=255)
    im.paste(bars, (0, 0), Image.composite(bars, Image.new("RGBA", (n, n), (0, 0, 0, 0)), mask).getchannel("A"))
    d = ImageDraw.Draw(im)
    # the skull: an angular cranium (flat top, cut corners), round eyes, a toothed jaw
    sy = cy - .05 * s
    w, h = .235 * s, .14 * s
    d.polygon([(cx - w * .62, sy - h), (cx + w * .62, sy - h), (cx + w, sy - h * .45), (cx + w, sy + h * .35),
               (cx + w * .55, sy + h * .95), (cx - w * .55, sy + h * .95), (cx - w, sy + h * .35), (cx - w, sy - h * .45)], fill=BLACK)
    for ex in (-1, 1):
        er = .058 * s
        ec = (cx + ex * .1 * s, sy + .005 * s)
        d.ellipse([ec[0] - er, ec[1] - er, ec[0] + er, ec[1] + er], fill=PAPER)
    jy0, jy1 = sy + h * 1.05, sy + h * 1.65             # the jaw: a black band with white tooth gaps
    d.polygon([(cx - w * .5, jy0), (cx + w * .5, jy0), (cx + w * .38, jy1), (cx - w * .38, jy1)], fill=BLACK)
    for i in range(-2, 3):
        tx = cx + i * w * .17
        d.rectangle([tx - .4 * u, jy0 + .25 * (jy1 - jy0), tx + .4 * u, jy0 + .7 * (jy1 - jy0)], fill=PAPER)
    return im.resize((size, size), Image.LANCZOS)


for name, size, scale in (("icon-192", 192, 1.0), ("icon-512", 512, 1.0), ("icon-maskable-512", 512, 0.78),
                          ("apple-touch-icon", 180, 0.9)):
    icon(size, scale).convert("RGB").save(f"duel/web/{name}.png", optimize=True)
    print(f"duel/web/{name}.png")

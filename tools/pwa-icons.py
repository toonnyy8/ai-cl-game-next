#!/usr/bin/env python3
"""pwa-icons.py — draw SOUL DUEL NEXT's app icons into duel/web/ (PIL only, already used by the tests):
icon-192.png, icon-512.png, icon-maskable-512.png (the mark inside the 80 % safe circle) and apple-touch-icon.png
(180 px, opaque). The mark (the user, 2026-10-29: 「以代理死神證作為 icon」): the Substitute Shinigami Badge, drawn stylised: a
dark-wood cross pattee with a pale rim, a bone skull in its middle, hung on a red cord, on the dusk ink. (Before: a pale soul ring
cut by a red brush slash.)  python3 tools/pwa-icons.py"""
from PIL import Image, ImageDraw

BG, RIM, WOOD, GRAIN, BONE, HOLE, CORD = ((7, 7, 12, 255), (176, 146, 98, 255), (58, 40, 30, 255), (74, 52, 38, 255),
                                         (232, 226, 208, 255), (16, 12, 12, 255), (232, 30, 58, 255))


def cross(c, s, k):
    """The badge's outline, scaled by K about C: four flared arms (a cross pattee), the ends cut slightly concave."""
    cx, cy = c
    out = []
    for ax, ay in ((0, -1), (1, 0), (0, 1), (-1, 0)):        # each arm: root half-width .09, end half-width .19, reach .40
        px, py = -ay, ax
        root, end, reach, dip = .09 * s * k, .19 * s * k, .40 * s * k, .035 * s * k
        out += [(cx + px * -root + ax * root, cy + py * -root + ay * root),
                (cx + ax * reach + px * -end, cy + ay * reach + py * -end),
                (cx + ax * (reach - dip), cy + ay * (reach - dip)),
                (cx + ax * reach + px * end, cy + ay * reach + py * end),
                (cx + px * root + ax * root, cy + py * root + ay * root)]
    return out


def icon(size, scale=1.0):
    k = 4                                              # supersample, then shrink (smooth edges)
    n = size * k
    im = Image.new("RGBA", (n, n), BG)
    d = ImageDraw.Draw(im)
    c = (n / 2, n / 2 + n * .03 * scale)
    s = n * scale
    d.line([(c[0], 0), (c[0], c[1] - .36 * s)], fill=CORD, width=max(2, int(.03 * s)))   # the cord it hangs on
    d.polygon(cross(c, s, 1.0), fill=RIM)
    d.polygon(cross(c, s, .9), fill=WOOD)
    grain = Image.new("RGBA", (n, n), (0, 0, 0, 0))   # a few grain lines across the wood, kept inside it
    g = ImageDraw.Draw(grain)
    for i in (-2, -1, 1, 2):
        y = c[1] + i * .07 * s
        g.line([(c[0] - .4 * s, y), (c[0] + .4 * s, y + .01 * s)], fill=GRAIN, width=max(1, int(.008 * s)))
    mask = Image.new("L", (n, n), 0)
    ImageDraw.Draw(mask).polygon(cross(c, s, .9), fill=255)
    im.paste(grain, (0, 0), Image.composite(grain, Image.new("RGBA", (n, n), (0, 0, 0, 0)), mask).getchannel("A"))
    # the skull: cranium, jaw, sockets, nose, teeth
    r = .15 * s
    x0, y0 = c[0], c[1] - .02 * s
    d.ellipse([x0 - r, y0 - r, x0 + r, y0 + r * .95], fill=BONE)
    d.rounded_rectangle([x0 - r * .62, y0 + r * .45, x0 + r * .62, y0 + r * 1.25], radius=r * .25, fill=BONE)
    for sx in (-1, 1):
        d.ellipse([x0 + sx * r * .42 - r * .27, y0 - r * .12, x0 + sx * r * .42 + r * .27, y0 + r * .38], fill=HOLE)
    d.polygon([(x0, y0 + r * .42), (x0 - r * .12, y0 + r * .68), (x0 + r * .12, y0 + r * .68)], fill=HOLE)
    for i in range(-2, 3):
        tx = x0 + i * r * .22
        d.line([(tx, y0 + r * .88), (tx, y0 + r * 1.18)], fill=HOLE, width=max(1, int(.012 * s)))
    d.line([(x0 - r * .55, y0 + r * .88), (x0 + r * .55, y0 + r * .88)], fill=HOLE, width=max(1, int(.012 * s)))
    return im.resize((size, size), Image.LANCZOS)


for name, size, scale in (("icon-192", 192, 1.0), ("icon-512", 512, 1.0), ("icon-maskable-512", 512, 0.78),
                          ("apple-touch-icon", 180, 0.9)):
    icon(size, scale).convert("RGB").save(f"duel/web/{name}.png", optimize=True)
    print(f"duel/web/{name}.png")

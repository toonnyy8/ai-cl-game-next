//! The battle canvas words (docs/bevy/M3A_NOTES.md §8): the canvas part of duel/lisp/hud-screens.lisp HUD-DRAW (the UI flash, the
//! focus lines and the impact splash, a cinematic's letterbox and brush title, the battle's world overlays, the big words) into the
//! `ui` stream, with brush.lisp's glyphs, captions and brush text, engine/lisp/fx-shapes.lisp's UI punctuation and engine/lisp/ui.lisp's
//! shapes. The Lisp HUD (`hb` / `hk`) and its pause grade are M3b.
use crate::fx::shapes::h01;
use crate::scene::Scene;
use duel_sim::cl::{max_f32, min_f32, mod_f32};
use duel_sim::ecs::Entity;
use duel_sim::math::{f_cos, f_hypot, f_sin};
use duel_sim::state::Match;

// ---------------------------------------------------------------- engine/lisp/ui.lisp's primitives (the `ui` stream: x y u v r g b a)

/// ui.lisp's batch: `(make-stream-buffer 8 32768)` (STREAM-ROOM-P's cap in floats).
pub const UI_STREAM_FLOATS: usize = 8 * 32768;
/// ui.lisp +WHITE-U+ / +WHITE-V+: the atlas's solid white cell (a flat colour).
pub const WHITE_U: f32 = (15.0 * 6.0 + 3.0) / 96.0;
pub const WHITE_V: f32 = (5.0 * 8.0 + 4.0) / 48.0;

/// port: ui.lisp WITH-UI-VERTS' reservation: the batch when NV vertices fit (STREAM-ROOM-P), else nothing (the shape is skipped).
pub fn ui_verts(ui: &mut Vec<f32>, nv: usize) -> Option<&mut Vec<f32>> {
    (ui.len() + 8 * nv <= UI_STREAM_FLOATS).then_some(ui)
}

/// WITH-UI-VERTS' UVTX on the white cell.
#[inline]
pub fn uvtx(v: &mut Vec<f32>, x: f32, y: f32, c: [f32; 4]) {
    v.extend_from_slice(&[x, y, WHITE_U, WHITE_V, c[0], c[1], c[2], c[3]]);
}

/// port: ui.lisp UI-RECT (%UI-RECT, one colour): a filled rectangle in window pixels.
pub fn ui_rect(ui: &mut Vec<f32>, x: f32, y: f32, w: f32, h: f32, c: [f32; 4]) {
    let (x1, y1) = (x + w, y + h);
    if let Some(v) = ui_verts(ui, 6) {
        uvtx(v, x, y, c);
        uvtx(v, x1, y, c);
        uvtx(v, x1, y1, c);
        uvtx(v, x, y, c);
        uvtx(v, x1, y1, c);
        uvtx(v, x, y1, c);
    }
}

/// port: ui.lisp %UI-POLY4 — a solid quad TL TR BR BL; C0 on TL / TR, C1 on BR / BL.
#[allow(clippy::too_many_arguments)]
pub fn ui_poly4(ui: &mut Vec<f32>, x0: f32, y0: f32, x1: f32, y1: f32, x2: f32, y2: f32, x3: f32, y3: f32, c0: [f32; 4], c1: [f32; 4]) {
    if let Some(v) = ui_verts(ui, 6) {
        uvtx(v, x0, y0, c0);
        uvtx(v, x1, y1, c0);
        uvtx(v, x2, y2, c1);
        uvtx(v, x0, y0, c0);
        uvtx(v, x2, y2, c1);
        uvtx(v, x3, y3, c1);
    }
}

/// port: ui.lisp UI-RECT-OUTLINE with an integer THICKNESS.
pub fn ui_rect_outline(ui: &mut Vec<f32>, x: f32, y: f32, w: f32, h: f32, c: [f32; 4], tk: f32) {
    ui_rect(ui, x, y, w, tk, c);
    ui_rect(ui, x, (y + h) - tk, w, tk, c);
    ui_rect(ui, x, y + tk, tk, h - 2.0 * tk, c);
    ui_rect(ui, (x + w) - tk, y + tk, tk, h - 2.0 * tk, c);
}

/// port: ui.lisp UI-SCALE — the integer UI scale of a W x H window at DENSITY: 1 per ~360 px of height, at most 1 per 480 px of width,
/// at least ONEHAND-FRAME's `*ui-min-css*` floor (11 CSS px on a portrait window, else none).
pub fn ui_scale(w: u32, h: u32, density: f32) -> i64 {
    let (w, h) = (w as i64, h as i64);
    // (round h 360): CL ROUND, half to even
    let (q, r) = (h.div_euclid(360), h.rem_euclid(360));
    let rq = if 2 * r > 360 || (2 * r == 360 && q % 2 != 0) { q + 1 } else { q };
    let s = 1.max(rq.min(w.div_euclid(480)));
    if h > w { s.max(((11.0 * density) / 7.0).ceil() as i64) } else { s }
}

// ---------------------------------------------------------------- engine/lisp/fx-shapes.lisp's UI punctuation

const TAU: f32 = 6.2831855;

/// port: fx-shapes.lisp UI-FOCUS-LINES — N thin wedges from RMAX pointing at (CX CY), their tips at RMIN (hashed), per DRAWING.
#[allow(clippy::too_many_arguments)]
pub fn ui_focus_lines(ui: &mut Vec<f32>, cx: f32, cy: f32, n: usize, rmin: f32, rmax: f32, col: [f32; 4], drawing: i32) {
    let (seed, nf) = (0.37 * drawing as f32, n.max(1) as f32);
    let Some(v) = ui_verts(ui, 3 * n) else { return };
    for i in 0..n {
        let f = i as f32;
        let ang = TAU * ((f + 0.8 * (h01(f, seed) - 0.5)) / nf);
        let r0 = rmin * (0.75 + 0.5 * h01(f + 1.7, seed));
        let w = rmax * (0.003 + 0.011 * h01(f + 4.1, seed));
        let (c, s) = (f_cos(ang), f_sin(ang));
        uvtx(v, cx + r0 * c, cy + r0 * s, col);
        uvtx(v, (cx + rmax * c) - w * s, (cy + rmax * s) + w * c, col);
        uvtx(v, (cx + rmax * c) + w * s, (cy + rmax * s) - w * c, col);
    }
}

/// port: fx-shapes.lisp UI-SPEED-LINES — N long thin wedges across a W x H screen parallel to DIR (radians), hashed per DRAWING.
#[allow(clippy::too_many_arguments)]
pub fn ui_speed_lines(ui: &mut Vec<f32>, w: f32, h: f32, dir: f32, n: usize, col: [f32; 4], drawing: i32) {
    let (c, s) = (f_cos(dir), f_sin(dir));
    let (diag, px, seed) = (f_hypot(w, h), h / 720.0, 0.53 * drawing as f32);
    let Some(v) = ui_verts(ui, 3 * n) else { return };
    for i in 0..n {
        let f = i as f32;
        let off = diag * (h01(f, seed) - 0.5);
        let along = (0.6 * diag) * (h01(f + 2.3, seed) - 0.5);
        let hl = (0.5 * diag) * (0.15 + 0.3 * h01(f + 5.9, seed));
        let wd = px * (1.5 + 4.0 * h01(f + 8.3, seed));
        let mx = (0.5 * w + along * c) - off * s;
        let my = (0.5 * h + along * s) + off * c;
        uvtx(v, mx - hl * c, my - hl * s, col);
        uvtx(v, (mx + hl * c) - wd * s, (my + hl * s) + wd * c, col);
        uvtx(v, (mx + hl * c) + wd * s, (my + hl * s) - wd * c, col);
    }
}

/// port: fx-shapes.lisp UI-INK-SPLASH — an ink splash at (CX CY), radius RAD px: a 14-gon blob, spikes and droplets hashed from SEED,
/// grown at DRAWING 0 (x 0.6).
pub fn ui_ink_splash(ui: &mut Vec<f32>, cx: f32, cy: f32, rad: f32, seed: f32, col: [f32; 4], drawing: i32) {
    let rad = rad * if drawing < 1 { 0.6 } else { 1.0 };
    let ns = 5 + (4.99 * h01(1.3, seed)) as usize;
    let nd = 6 + (6.99 * h01(2.9, seed)) as usize;
    let Some(v) = ui_verts(ui, 42 + 3 * ns + 18 * nd) else { return };
    let (mut lx, mut ly) = (0.0, 0.0);
    for j in 0..15 {
        let f = (j % 14) as f32;
        let ang = TAU * (f / 14.0);
        let rr = rad * (0.7 + 0.45 * h01(f, seed));
        let (x, y) = (cx + rr * f_cos(ang), cy + rr * f_sin(ang));
        if j > 0 {
            uvtx(v, cx, cy, col);
            uvtx(v, lx, ly, col);
            uvtx(v, x, y, col);
        }
        (lx, ly) = (x, y);
    }
    let nsf = ns as f32;
    for j in 0..ns {
        let f = j as f32;
        let ang = TAU * (f / nsf + 0.1 * h01(f + 11.0, seed));
        let (c, s) = (f_cos(ang), f_sin(ang));
        let w = rad * (0.05 + 0.06 * h01(f + 13.0, seed));
        let l = rad * (1.3 + 0.9 * h01(f + 17.0, seed));
        let bb = 0.6 * rad;
        uvtx(v, (cx + bb * c) - w * s, (cy + bb * s) + w * c, col);
        uvtx(v, (cx + bb * c) + w * s, (cy + bb * s) - w * c, col);
        uvtx(v, cx + l * c, cy + l * s, col);
    }
    for j in 0..nd {
        let f = j as f32;
        let sp = (nsf * h01(f + 23.0, seed)) as i32 as f32;
        let ang = TAU * ((sp / nsf + 0.1 * h01(sp + 11.0, seed)) + 0.04 * (h01(f + 29.0, seed) - 0.5));
        let dist = rad * (1.4 + 1.1 * h01(f + 31.0, seed));
        let dr = rad * (0.03 + 0.07 * h01(f + 37.0, seed));
        let (ox, oy) = (cx + dist * f_cos(ang), cy + dist * f_sin(ang));
        let (mut qx, mut qy) = (0.0, 0.0);
        for q in 0..7 {
            let qa = TAU * ((q % 6) as f32 / 6.0);
            let (x, y) = (ox + dr * f_cos(qa), oy + dr * f_sin(qa));
            if q > 0 {
                uvtx(v, ox, oy, col);
                uvtx(v, qx, qy, col);
                uvtx(v, x, y, col);
            }
            (qx, qy) = (x, y);
        }
    }
}

// ---------------------------------------------------------------- brush.lisp: the glyphs

/// A brush glyph (brush.lisp GLYPH): the advance (em) and the triangles (x y per corner, em, y down from the em box's top).
pub struct Glyph {
    pub adv: f32,
    pub tris: Vec<f32>,
}

/// brush.lisp `*glyphs*` (BRUSH-INIT): char code -> glyph, sorted by code.
pub struct Glyphs(Vec<(u32, Glyph)>);

impl Glyphs {
    /// port: brush.lisp BRUSH-INIT — every glyph of glyphs.json ear-clipped into triangles once.
    pub fn new(d: &duel_data::Data) -> Glyphs {
        let mut v: Vec<(u32, Glyph)> = Vec::with_capacity(d.glyphs.len());
        for g in &d.glyphs {
            let mut tris = Vec::new();
            for p in &g.2 {
                for k in ear_clip(p) {
                    tris.push(p[2 * k] as f32 / 1000.0);
                    tris.push(p[2 * k + 1] as f32 / 1000.0);
                }
            }
            let gl = Glyph { adv: g.1 as f32 / 1000.0, tris };
            match v.iter_mut().find(|x| x.0 == g.0) {
                Some(x) => x.1 = gl, // ((setf (gethash code *glyphs*) …): a later outline replaces)
                None => v.push((g.0, gl)),
            }
        }
        v.sort_by_key(|x| x.0);
        Glyphs(v)
    }

    /// The glyph of CH, if any.
    pub fn get(&self, ch: char) -> Option<&Glyph> {
        self.0.binary_search_by_key(&(ch as u32), |x| x.0).ok().map(|i| &self.0[i].1)
    }

    /// port: brush.lisp BRUSH-WIDTH — STR's width in em set horizontally with GAP em between letters (a space is 0.35 em).
    pub fn width(&self, s: &str, gap: f32) -> f32 {
        let mut sum = 0.0f32;
        for ch in s.chars() {
            sum += if ch == ' ' { 0.35 } else { self.get(ch).map_or(0.0, |g| gap + g.adv) };
        }
        sum
    }
}

/// port: brush.lisp BRUSH-CELLS — STR's height in em set vertically (a space or 、 is half a cell).
pub fn brush_cells(s: &str) -> f32 {
    s.chars().map(|ch| if ch == ' ' || ch == '、' { 0.5 } else { 1.0 }).sum()
}

/// port: brush.lisp EAR-CLIP — the triangles of the simple polygon V (x0 y0 x1 y1 …, integers, wound positive with y down) as corner
/// indices, 3 a triangle, in the order they were cut. Collinear corners are dropped without a triangle.
fn ear_clip(v: &[i32]) -> Vec<usize> {
    let n = v.len() / 2;
    let (xs, ys): (Vec<i64>, Vec<i64>) = (0..n).map(|k| (v[2 * k] as i64, v[2 * k + 1] as i64)).unzip();
    let mut nx: Vec<usize> = (0..n).map(|k| (k + 1) % n).collect();
    let mut pv: Vec<usize> = (0..n).map(|k| (k + n - 1) % n).collect();
    let cross = |a: usize, b: usize, c: usize| (xs[b] - xs[a]) * (ys[c] - ys[a]) - (ys[b] - ys[a]) * (xs[c] - xs[a]);
    let (mut tris, mut left, mut i, mut miss) = (Vec::new(), n, 0usize, 0usize);
    while left > 2 {
        let (a, c) = (pv[i], nx[i]);
        let cr = cross(a, i, c);
        let ear = |nx: &[usize]| {
            let mut p = nx[c];
            while p != a {
                let at = |q: usize| xs[p] == xs[q] && ys[p] == ys[q];
                if !(at(a) || at(i) || at(c)) && cross(a, i, p) >= 0 && cross(i, c, p) >= 0 && cross(c, a, p) >= 0 {
                    return false;
                }
                p = nx[p];
            }
            true
        };
        if cr == 0 || (cr > 0 && ear(&nx)) || miss > left {
            if cr > 0 {
                tris.extend([a, i, c]);
            }
            nx[a] = c;
            pv[c] = a;
            (left, i, miss) = (left - 1, c, 0);
        } else {
            (i, miss) = (c, miss + 1);
        }
    }
    tris
}

/// The glyph runs' drawing state: the `ui` stream, the glyphs, and brush.lisp `*bclip*` [0..6] (the slice exit's clip: [0] 0 = off,
/// +1 / -1 the side kept, [1 2] the cut's normal, [3] c, [4 5] the kept half's slide).
struct Brush<'a> {
    ui: &'a mut Vec<f32>,
    g: &'a Glyphs,
    clip: [f32; 6],
}

impl Brush<'_> {
    /// port: brush.lisp %GLYPH-TRIS — the triangles TV, the em box's top left at (GX GY), GS px per em, colour C; cut by the clip.
    fn tris(&mut self, tv: &[f32], gx: f32, gy: f32, gs: f32, c: [f32; 4]) {
        let nv = tv.len() / 2;
        if self.clip[0] != 0.0 {
            return self.tris_clip(tv, gx, gy, gs, c);
        }
        let Some(v) = ui_verts(self.ui, nv) else { return };
        for k in 0..nv {
            uvtx(v, gx + gs * tv[2 * k], gy + gs * tv[2 * k + 1], c);
        }
    }

    /// port: brush.lisp %GLYPH-TRIS-CLIP — each triangle clipped to the kept side of the cut (0-2 triangles), slid by the half's offset.
    fn tris_clip(&mut self, tv: &[f32], gx: f32, gy: f32, gs: f32, col: [f32; 4]) {
        let [sg, nx, ny, cc, ox, oy] = self.clip;
        let nt = tv.len() / 6;
        let Some(v) = ui_verts(self.ui, 6 * nt) else { return };
        let mut tri = |v: &mut Vec<f32>, ax: f32, ay: f32, bx: f32, by: f32, cx: f32, cy: f32| {
            uvtx(v, ax + ox, ay + oy, col);
            uvtx(v, bx + ox, by + oy, col);
            uvtx(v, cx + ox, cy + oy, col);
        };
        // CUTS: P = A->B and Q = A->C on the line
        let cuts = |a: (f32, f32, f32), b: (f32, f32, f32), c: (f32, f32, f32)| {
            let (u, w) = (a.2 / (a.2 - b.2), a.2 / (a.2 - c.2));
            (a.0 + (b.0 - a.0) * u, a.1 + (b.1 - a.1) * u, a.0 + (c.0 - a.0) * w, a.1 + (c.1 - a.1) * w)
        };
        for k in 0..nt {
            let q = 6 * k;
            let (x0, y0) = (gx + gs * tv[q], gy + gs * tv[q + 1]);
            let (x1, y1) = (gx + gs * tv[q + 2], gy + gs * tv[q + 3]);
            let (x2, y2) = (gx + gs * tv[q + 4], gy + gs * tv[q + 5]);
            let d0 = sg * ((nx * x0 + ny * y0) - cc);
            let d1 = sg * ((nx * x1 + ny * y1) - cc);
            let d2 = sg * ((nx * x2 + ny * y2) - cc);
            let (p0, p1, p2) = ((x0, y0, d0), (x1, y1, d1), (x2, y2, d2));
            let one = |v: &mut Vec<f32>, tri: &mut dyn FnMut(&mut Vec<f32>, f32, f32, f32, f32, f32, f32), a: (f32, f32, f32), b, c| {
                let (px, py, qx, qy) = cuts(a, b, c);
                tri(v, a.0, a.1, px, py, qx, qy);
            };
            let two = |v: &mut Vec<f32>, tri: &mut dyn FnMut(&mut Vec<f32>, f32, f32, f32, f32, f32, f32), a: (f32, f32, f32), b: (f32, f32, f32), c: (f32, f32, f32)| {
                let (px, py, qx, qy) = cuts(a, b, c);
                tri(v, px, py, b.0, b.1, c.0, c.1);
                tri(v, px, py, c.0, c.1, qx, qy);
            };
            match (d0 >= 0.0) as u8 + 2 * (d1 >= 0.0) as u8 + 4 * (d2 >= 0.0) as u8 {
                7 => tri(v, x0, y0, x1, y1, x2, y2),
                1 => one(v, &mut tri, p0, p1, p2),
                2 => one(v, &mut tri, p1, p2, p0),
                4 => one(v, &mut tri, p2, p0, p1),
                6 => two(v, &mut tri, p0, p1, p2),
                5 => two(v, &mut tri, p1, p2, p0),
                3 => two(v, &mut tri, p2, p0, p1),
                _ => {}
            }
        }
    }

    /// port: brush.lisp %BRUSH-RUN — STR from (X Y) (the first em box's top left), SZ px per em: down one em a char (VERTICAL) or right
    /// by the advance + GAP em. A space is half a cell (0.35 em across); a char with no glyph is skipped.
    #[allow(clippy::too_many_arguments)]
    fn run(&mut self, s: &str, x: f32, y: f32, sz: f32, vertical: bool, gap: f32, c: [f32; 4]) {
        let (mut px, mut py) = (x, y);
        let g = self.g;
        for ch in s.chars() {
            match g.get(ch).filter(|_| ch != ' ') {
                Some(gl) => {
                    let comma = vertical && ch == '、';
                    if comma {
                        (px, py) = (px + 0.55 * sz, py - 0.55 * sz);
                    }
                    self.tris(&gl.tris, px, py, sz, c);
                    if vertical {
                        if comma {
                            (px, py) = (px - 0.55 * sz, py + 1.05 * sz);
                        } else {
                            py += sz;
                        }
                    } else {
                        px = (px + sz * gl.adv) + sz * gap;
                    }
                }
                None => {
                    if vertical {
                        py += 0.5 * sz;
                    } else {
                        px += 0.35 * sz;
                    }
                }
            }
        }
    }

    /// port: brush.lisp %BRUSH-BOX — a solid box.
    fn rect(&mut self, x: f32, y: f32, w: f32, h: f32, c: [f32; 4]) {
        ui_rect(self.ui, x, y, w, h, c);
    }
}

// ---------------------------------------------------------------- brush.lisp: the captions

/// port: brush.lisp BCAP — a brush caption of a cinematic (`:layout :cine`, no mark, untimed): its strings, side (0 left / 1 right
/// third), INK (black glyphs on a white card), HANKO (the red Kikon seal); T0 the fx clock it started at (F[0]), EXIT the slice exit's
/// start (F[7]; 0 = none). F[2..5] (the cells and widths) are measured where they are drawn. WEB: the title of a cinematic whose 2D
/// layer is the Lisp HUD's (WEBHUD-CINE-P: the intro, the K.O., TIME), which the canvas never draws, sliced out or not
/// (`*web-caption*`).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Bcap<'d> {
    pub kanji: &'d str,
    pub kanji2: Option<&'d str>,
    pub reading: Option<&'d str>,
    pub sub: Option<&'d str>,
    pub side: i32,
    pub ink: bool,
    pub hanko: bool,
    pub t0: f32,
    pub exit: f32,
    pub web: bool,
}

impl<'d> Bcap<'d> {
    /// port: brush.lisp MAKE-BCAP with `:layout :cine` (the keys set by the caller), starting at fx clock T0.
    pub fn new(kanji: &'d str, t0: f32) -> Bcap<'d> {
        Bcap { kanji, kanji2: None, reading: None, sub: None, side: 0, ink: false, hanko: false, t0, exit: 0.0, web: false }
    }

    /// port: brush.lisp BCAP-EXIT — it slices out from CLOCK (once).
    pub fn exit(&mut self, clock: f32) {
        if self.exit <= 0.0 {
            self.exit = clock;
        }
    }
}

/// port: brush.lisp DRAW-BCAP for a `:cine` caption C on a W x H window at fx clock CLOCK: the column (and the second one), the
/// stamp's zoom and drawn shake on twos, the ink splash, the hanko, the reading, the chapter line; the slice exit (the column cut
/// through, its halves sliding apart). False once it is gone.
fn draw_bcap(ui: &mut Vec<f32>, g: &Glyphs, c: &Bcap, w: u32, h: u32, clock: f32) -> bool {
    let (ww, hh) = (w as f32, h as f32);
    let age = clock - c.t0;
    let right = c.side == 1;
    let d = (12.0 * age) as i32;
    let ex = if c.exit > 0.0 { clock - c.exit } else { -1.0 };
    let exiting = ex >= 0.0;
    let de = if exiting { (12.0 * ex) as i32 } else { 0 };
    let a = if exiting { crate::fx::shapes::f_clamp((0.3 - ex) / 0.12, 0.0, 1.0) } else { 1.0 };
    let n = max_f32(1.0, brush_cells(c.kanji));
    let n2 = c.kanji2.map_or(0.0, brush_cells);
    let (hk, rd) = (c.hanko, c.reading);
    let top = 0.1 * hh;
    let tall = hh > ww;
    let bot = if c.sub.is_some() { 0.84 * hh } else { 0.895 * hh };
    let ls = 0.034 * hh;
    let lsh = if rd.is_some() { 1.05 * ls } else { 0.0 };
    let nb = max_f32(n + if hk { 0.58 } else { 0.0 }, if n2 > 0.0 { 0.35 + 0.42 * n2 } else { 0.0 }) + if rd.is_some() { 0.15 } else { 0.0 };
    let sz = min_f32(min_f32(0.24 * hh, ((bot - top) - lsh) / nb), if tall { ww * 0.36 } else { 1e9 });
    let bh = sz * nb + lsh;
    let k = min_f32(match d { 0 => 1.8, 1 => 1.15, _ => 1.0 }, (bot - top) / bh);
    let sx = match d { 1 => 0.012 * hh, 2 => -0.008 * hh, 3 => 0.004 * hh, _ => 0.0 };
    let ink = c.ink;
    let (gr, gb, pr, pb) = if ink { (0.03, 0.047, 0.96, 0.94) } else { (0.96, 0.94, 0.03, 0.047) };
    let ksz = k * sz;
    let w2 = if n2 > 0.0 { 0.483 * ksz } else { 0.0 };
    let cx = if right { 0.83 * ww } else { 0.17 * ww };
    let kx = crate::fx::shapes::f_clamp(sx + (cx - 0.5 * ksz), 0.02 * ww + if right { w2 } else { 0.0 }, (0.98 * ww - ksz) - if right { 0.0 } else { w2 });
    let ky = duel_sim::math::f_max(top, min_f32((top + 0.5 * bh) - (0.5 * k) * bh, bot - k * bh));
    let (mut yy, mut yb) = (ky, ky);
    if ex >= 0.3 {
        return false;
    }
    let mut b = Brush { ui, g, clip: [0.0; 6] };
    if d >= 1 && !exiting {
        // the ink splash, from drawing 1, beside the column's head (BCAP-SPLASH-ARGS: the same every frame on one window)
        let spx = if right { cx + 0.62 * sz } else { cx - 0.62 * sz };
        let seed = mod_f32(7.31 * c.t0, 97.0);
        let col = if ink { [0.03, 0.03, 0.047, 1.0] } else { [0.96, 0.96, 0.94, 1.0] };
        ui_ink_splash(b.ui, spx, top + 0.2 * sz, 0.26 * sz, seed, col, d - 1);
    }
    let y0 = yy;
    let gcol = [gr, gr, gb, a];
    let pcol = [pr, pr, pb, 0.8 * a];
    let columns = |b: &mut Brush, yb: &mut f32| {
        if !ink {
            b.run(c.kanji, kx + 0.04 * ksz, y0 + 0.04 * ksz, ksz, true, 0.0, pcol);
        }
        b.run(c.kanji, kx, y0, ksz, true, 0.0, gcol);
        if n2 > 0.0 {
            let s2 = 0.42 * ksz;
            let x2 = if right { kx - 1.15 * s2 } else { (kx + ksz) + 0.15 * s2 };
            let y2 = ky + 0.35 * ksz;
            let k2 = c.kanji2.unwrap_or("");
            if !ink {
                b.run(k2, x2 + 0.05 * s2, y2 + 0.05 * s2, s2, true, 0.0, pcol);
            }
            b.run(k2, x2, y2, s2, true, 0.0, gcol);
            *yb = y2 + s2 * n2;
        }
    };
    if !exiting {
        columns(&mut b, &mut yb);
    } else {
        // the slice exit: a brush cut rising left to right through the column's middle; the halves slide apart on twos
        let (mx, my) = (kx + 0.5 * ksz, y0 + (0.5 * ksz) * n);
        let (ux, uy, nx, ny) = (0.866f32, -0.5f32, 0.5f32, 0.866f32);
        let sl = ksz * (0.1 + 0.25 * de as f32);
        let sp = (ksz * 0.04) * (1.0 + de as f32);
        b.clip = [1.0, nx, ny, nx * mx + ny * my, sl * ux + sp * nx, sl * uy + sp * ny];
        columns(&mut b, &mut yb);
        (b.clip[0], b.clip[4], b.clip[5]) = (-1.0, (0.0 - sl * ux) - sp * nx, (0.0 - sl * uy) - sp * ny);
        columns(&mut b, &mut yb);
        b.clip[0] = 0.0;
        if de < 2 {
            let hl = 1.3 * ksz;
            let hw = ksz * if de == 0 { 0.04 } else { 0.018 };
            if let Some(v) = ui_verts(b.ui, 6) {
                uvtx(v, mx - hl * ux, my - hl * uy, gcol);
                uvtx(v, mx + hw * nx, my + hw * ny, gcol);
                uvtx(v, mx + hl * ux, my + hl * uy, gcol);
                uvtx(v, mx - hl * ux, my - hl * uy, gcol);
                uvtx(v, mx + hl * ux, my + hl * uy, gcol);
                uvtx(v, mx - hw * nx, my - hw * ny, gcol);
            }
        }
    }
    yy += ksz * n;
    if hk && !exiting {
        // the red seal: 鬼 knocked out of BLOOD red
        let hs = 0.46 * ksz;
        let (hx, hy) = (kx + 0.5 * (ksz - hs), yy + 0.12 * ksz);
        b.rect(hx, hy, hs, hs, [0.816, 0.063, 0.11, a]);
        b.run("鬼", hx + 0.1 * hs, hy + 0.1 * hs, 0.8 * hs, true, 0.0, [0.96, 0.95, 0.93, a]);
        yy = hy + hs;
    }
    if let Some(rd) = rd.filter(|_| !exiting) {
        let f4 = g.width(rd, 0.25);
        let room = if right { (kx + ksz) - 0.51 * ww } else { 0.49 * ww - kx };
        let rs = min_f32(ls, room / max_f32(1.0, f4));
        let rw = rs * f4;
        let rx = if right { (kx + ksz) - rw } else { kx };
        let ry = duel_sim::math::f_max(yy, yb) + 0.15 * ksz;
        if !ink {
            b.run(rd, rx + 0.06 * rs, ry + 0.06 * rs, rs, false, 0.25, pcol);
        }
        b.run(rd, rx, ry, rs, false, 0.25, gcol);
    }
    if let Some(sub) = c.sub.filter(|_| !exiting) {
        // the chapter line at the foot of its half: — SUB —
        let f5 = g.width(sub, 0.3);
        let ls = min_f32(0.024 * hh, (0.44 * ww) / (f5 + 4.0));
        let (tw, rl) = (ls * f5, 1.6 * ls);
        let x = if right { ((0.95 * ww - tw) - rl) - 0.2 * ls } else { (0.05 * ww + rl) + 0.5 * ls };
        let y = 0.868 * hh;
        b.rect((x - rl) - 0.5 * ls, y + 0.52 * ls, rl, 0.07 * ls, gcol);
        b.run(sub, x, y, ls, false, 0.3, gcol);
        b.rect((x + tw) + 0.2 * ls, y + 0.52 * ls, rl, 0.07 * ls, gcol);
    }
    true
}

// ---------------------------------------------------------------- hud.lisp: the big words

/// port: hud.lisp WORD — a big word (ANNOUNCE): its text and sub, its colour (r g b; the drawn alpha is 1, faded), its seconds, SMALL
/// (the upper lane, smaller), SIDE (over that side's panel), the fx clock it started at.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Word<'d> {
    pub text: &'d str,
    pub sub: Option<&'static str>,
    pub col: [f32; 3],
    pub secs: f32,
    pub small: bool,
    pub side: Option<i32>,
    pub t0: f32,
}

/// `Scene.words`' bound: at most one centred word per lane and one per side live at once (ANNOUNCE removes the lane's last).
pub const WORDS_MAX: usize = 16;

impl<'d> Scene<'d> {
    /// port: hud.lisp ANNOUNCE — TEXT big in the middle (SMALL: smaller, the upper lane; SIDE 0 / 1: over that side's panel), SUB
    /// under it; it replaces the centred word of its lane.
    pub(crate) fn announce(&mut self, text: &'d str, sub: Option<&'static str>, col: [f32; 4], secs: f32, small: bool, side: Option<i32>) {
        let wd = Word { text, sub, col: [col[0], col[1], col[2]], secs, small, side, t0: self.draw.post.fx_clock };
        self.words.retain(|w| !(w.side.is_none() && w.small == small));
        if self.words.len() < WORDS_MAX {
            self.words.insert(0, wd);
        }
    }
}

/// port: brush.lisp BRUSH-TEXT (SET-LINE, LINE-WIDTH, BRUSH-LINE) — one line of brush Latin STR centred on X, the caps' middle at Y,
/// EM px per em, colour COL x ALPHA, over an ink backing (4 diagonal copies).
#[allow(clippy::too_many_arguments)]
fn brush_text(ui: &mut Vec<f32>, g: &Glyphs, s: &str, x: f32, y: f32, em: f32, col: [f32; 4], alpha: f32) {
    let lw = g.width(s, 0.06);
    let x = x - (0.5 * em) * lw;
    let y = y - 0.53 * em;
    let o = max_f32(1.0, 0.035 * em);
    let a = alpha * col[3];
    let sa = 0.85 * a;
    let ink = [0.03, 0.03, 0.047, sa];
    let mut b = Brush { ui, g, clip: [0.0; 6] };
    b.run(s, x + o, y + o, em, false, 0.06, ink);
    b.run(s, x - o, y + o, em, false, 0.06, ink);
    b.run(s, x + o, y - o, em, false, 0.06, ink);
    b.run(s, x - o, y - o, em, false, 0.06, ink);
    b.run(s, x, y, em, false, 0.06, [col[0], col[1], col[2], a]);
}

/// port: hud.lisp WORD-LAYOUT — word X on a W x H window: its centre x, the caps' middle y and its em px (the pop-in over 0.08 s; a long
/// word shrinks to 92 % of the width); BAND the portrait frame's top and bottom (fractions).
fn word_layout(g: &Glyphs, x: &Word, w: f32, h: f32, clock: f32, band: Option<(f32, f32)>) -> (f32, f32, f32) {
    let k = min_f32(1.0, (clock - x.t0) / 0.08);
    let em = h * if x.side.is_some() { 0.05 } else if x.small { 0.085 } else { 0.13 * (1.0 + 0.5 * (1.0 - k)) };
    let lw = g.width(x.text, 0.06);
    let em = min_f32(em, (0.92 * w) / max_f32(0.1, lw));
    let cx = match x.side {
        Some(0) => 0.2 * w,
        Some(1) => 0.8 * w,
        _ => 0.5 * w,
    };
    let edge = x.side.is_some() || x.small;
    let mut cy = match band {
        Some((b0, b1)) => h * if edge { b0 + 0.05 } else { 0.5 * (b0 + b1) },
        None => (if edge { 0.3 } else { 0.45 }) * h,
    };
    // (*panel-box* is all 0 since the canvas HUD left: a word clear of both "panels" unless it runs off the top left)
    let hw = (0.5 * em) * lw;
    for _ in 0..2 {
        if cx - hw < 0.0 && 0.0 < cx + hw && cy - 0.45 * em < 0.0 {
            cy = (0.0 + 0.012 * h) + 0.45 * em;
        }
    }
    (cx, cy, em)
}

impl Scene<'_> {
    /// port: hud.lisp DRAW-WORDS — the big words in brush Latin, fading out over their last 0.25 s (the ended ones dropped first).
    fn draw_words(&mut self, ui: &mut Vec<f32>) {
        let clock = self.draw.post.fx_clock;
        self.words.retain(|x| clock - x.t0 <= x.secs);
        let (w, h) = (self.inputs.width as f32, self.inputs.height as f32);
        let band = self.portrait_p().then(|| {
            let i = &self.inputs;
            let b = crate::draw::camera::band(&self.draw.knobs, &crate::draw::camera::View { w: i.width, h: i.height, density: i.density, safe_top: i.safe_top, safe_bottom: i.safe_bottom });
            (b.top, b.bottom)
        });
        for x in &self.words {
            let age = clock - x.t0;
            let fade = min_f32(1.0, (x.secs - age) / 0.25);
            let col = [x.col[0], x.col[1], x.col[2], 1.0];
            let (cx, cy, em) = word_layout(&self.glyphs, x, w, h, clock, band);
            brush_text(ui, &self.glyphs, x.text, cx, cy, em, col, fade);
            if let Some(sub) = x.sub {
                let se = max_f32(0.032 * h, 0.36 * em);
                brush_text(ui, &self.glyphs, sub, cx, (cy + 0.55 * em) + 0.5 * se, se, col, fade);
            }
        }
    }

    /// port: hud.lisp HUD-RUSH-LINES — speed lines along a Kikon rush's dash-in (toward its victim's mark) and Kenpachi's SP2 dash (on
    /// his facing), on the screen direction from E (its drawn place).
    fn hud_rush_lines(&mut self, m: &Match, e: Entity, ui: &mut Vec<f32>) {
        use duel_sim::components::{Phase, State};
        let Some(f) = m.fighter.get(e) else { return };
        let mv = duel_sim::fighter::current_move(f).map(|id| duel_sim::fighter::mv(m, id));
        let charge = mv.is_some_and(|mv| {
            f.state == State::Move && mv.name == "ke-charge" && f.phase == Some(Phase::Main) && (mv.s as i64) <= f.sf && f.sf <= (mv.s + mv.a - 1) as i64
        });
        let dashing = match f.phase {
            Some(Phase::Dash) => true,
            Some(Phase::Follow) => f.dist > m.knobs.kikon_trigger + 0.05,
            _ => false,
        };
        if !(charge || (f.state == State::Move && f.phase == Some(Phase::Follow) && dashing)) {
            return;
        }
        let (p, yaw) = (self.drawn_pos(m, e), self.drawn_yaw(m, e));
        let Some(a) = self.world_to_screen(p[0], 1.0, p[2]) else { return };
        let b = if charge {
            self.world_to_screen(p[0] + 2.0 * duel_sim::math::fwd_x(yaw), 1.0, p[2] + 2.0 * duel_sim::math::fwd_z(yaw))
        } else {
            self.world_to_screen(f.ox, 1.0, f.oz)
        };
        let Some(b) = b else { return };
        // (atan dy dx) of singles: a double atan2, rounded (DIR-YAW's arithmetic: atan2(-a, -b))
        let dir = duel_sim::math::dir_yaw(-(b[1] - a[1]), -(b[0] - a[0]));
        let drawing = (12.0 * self.draw.post.fx_clock) as i32;
        ui_speed_lines(ui, self.inputs.width as f32, self.inputs.height as f32, dir, 14, [1.0, 1.0, 1.0, 0.55], drawing);
    }
}

impl<'d> Scene<'d> {
    /// port: hud.lisp HUD-WORLD — over E in the world (his drawn place): the red soul flame while he is red (a Kikon on him is live).
    fn hud_world(&mut self, m: &Match, e: Entity, out: &mut crate::draw::FrameOut) {
        let Some(g) = m.gauges.get(e) else { return };
        let Some(hh) = self.model(e).map(|md| self.data.bodies[md.body].hurt_h) else { return };
        let p = self.drawn_pos(m, e);
        let top = (p[1] + hh) + 0.5;
        if duel_sim::fighter::gauges_red_p(&m.knobs, g) {
            let clock = self.draw.post.fx_clock;
            crate::cine::vfx_soul_flame(&mut self.ctx(out), p[0], top, p[2], clock);
        }
    }

    /// The PERFECT HINT setting (control.lisp `*settings*`' :hint row) is ON.
    fn hint_on(&self, m: &Match) -> bool {
        let rows = self.data.tuning["*SETTINGS*"].as_array().expect("tuning *SETTINGS*");
        rows.iter().position(|r| r[0] == "hint").is_some_and(|i| m.settings.ix[i] == 1)
    }

    /// port: hud-screens.lisp HUD-DRAW's canvas part after AURA-CAP-UPDATE: the UI flash (faded by the frame's HUD seconds, HUD_DT), the
    /// focus lines and the impact splash (DRAW-SCREEN-FX), a cinematic's letterbox and brush title (not the intro's, the K.O.'s, TIME's:
    /// the Lisp HUD's), an ended cinematic's title slicing out, the battle's world overlays (the speed lines, the red soul flame: into the
    /// fx streams), the big words. (PERFECT HINT's HOHO! is a human's with the setting on: `unported`, M3b; the Lisp HUD, M3b.)
    pub(crate) fn hud_canvas(&mut self, m: &Match, out: &mut crate::draw::FrameOut, hud_dt: f32) {
        let (w, h) = (self.inputs.width, self.inputs.height);
        let (wf, hf) = (w as f32, h as f32);
        let f = &mut self.fx.ui_flash;
        if f[3] > 0.0 {
            ui_rect(&mut out.ui, 0.0, 0.0, wf, hf, [f[0], f[1], f[2], f[3]]);
            f[3] = max_f32(0.0, f[3] - f[4] * hud_dt);
        }
        // port: cinema.lisp DRAW-SCREEN-FX
        let sfx = self.draw.screen_fx;
        if sfx[7] > 0.0
            && let Some(sp) = self.cine.splash
        {
            ui_ink_splash(&mut out.ui, sp[0], sp[1], sp[2], sp[3], [0.03, 0.03, 0.047, 1.0], 1);
        }
        if sfx[1] > 0.0 {
            let cx = if sfx[4] < 0.0 { 0.5 * wf } else { sfx[4] };
            let cy = if sfx[5] < 0.0 { 0.5 * hf } else { sfx[5] };
            let drawing = (12.0 * self.draw.post.fx_clock) as i32;
            ui_focus_lines(&mut out.ui, cx, cy, 56, 0.16 * hf, 1.4 * w.max(h) as f32, [0.03, 0.03, 0.05, 0.92], drawing);
        }
        let clock = self.draw.post.fx_clock;
        let web = m.cine.as_ref().is_some_and(|c| matches!(c.name, duel_sim::cine::CineName::Intro | duel_sim::cine::CineName::Ko | duel_sim::cine::CineName::Time));
        if m.cine.is_some() && !web {
            ui_rect(&mut out.ui, 0.0, 0.0, wf, 0.09 * hf, [0.0, 0.0, 0.0, 1.0]);
            ui_rect(&mut out.ui, 0.0, 0.91 * hf, wf, 0.09 * hf, [0.0, 0.0, 0.0, 1.0]);
            if let Some(c) = self.cine.caption
                && !draw_bcap(&mut out.ui, &self.glyphs, &c, w, h, clock)
            {
                self.cine.caption = None;
            }
        }
        if let Some(c) = self.cine.caption_out.filter(|c| !c.web)
            && !draw_bcap(&mut out.ui, &self.glyphs, &c, w, h, clock)
        {
            self.cine.caption_out = None;
        }
        if matches!(m.flow, duel_sim::components::Flow::Battle | duel_sim::components::Flow::Finish) && m.cine.is_none() {
            // port: hud.lisp HUD-BATTLE (HUD-STICK: the one-hand deck's, M3b)
            for e in [m.p1, m.p2] {
                if m.ents.alive(e) {
                    self.hud_rush_lines(m, e, &mut out.ui);
                    self.hud_world(m, e, out);
                    if m.fighter.get(e).is_some_and(|f| f.brain.is_none()) && self.hint_on(m) {
                        self.unported.get_or_insert("PERFECT HINT's HOHO! (hud.lisp HUD-HINT: M3b, the settings)");
                    }
                }
            }
        }
        let ui = &mut out.ui;
        self.draw_words(ui);
    }
}

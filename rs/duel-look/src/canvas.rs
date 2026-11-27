//! The battle canvas words (docs/bevy/M3A_NOTES.md §8): the canvas part of duel/lisp/hud-screens.lisp HUD-DRAW (the UI flash, the
//! focus lines and the impact splash, a cinematic's letterbox and brush title, the battle's world overlays, the big words) into the
//! `ui` stream, with brush.lisp's captions and brush text and engine/lisp/ui.lisp's shapes. The Lisp HUD (`hb` / `hk`) is M3b.

/// port: brush.lisp BCAP — a brush caption of a cinematic (`:layout :cine`, no mark, untimed): its strings, side (0 left / 1 right
/// third), INK (black glyphs on a white card), HANKO (the red Kikon seal); T0 the fx clock it started at (F[0]), EXIT the slice exit's
/// start (F[7]; 0 = none). F[2..5] (the cells and widths) are measured where they are drawn.
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
}

impl<'d> Bcap<'d> {
    /// port: brush.lisp MAKE-BCAP with `:layout :cine` (the keys set by the caller), starting at fx clock T0.
    pub fn new(kanji: &'d str, t0: f32) -> Bcap<'d> {
        Bcap { kanji, kanji2: None, reading: None, sub: None, side: 0, ink: false, hanko: false, t0, exit: 0.0 }
    }

    /// port: brush.lisp BCAP-EXIT — it slices out from CLOCK (once).
    pub fn exit(&mut self, clock: f32) {
        if self.exit <= 0.0 {
            self.exit = clock;
        }
    }
}

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

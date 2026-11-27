//! port: engine/lisp/render.lisp's camera (CAMERA, UPDATE-CAMERA) with engine/lisp/math.lisp's matrices (M4-LOOK-AT!,
//! M4-PERSPECTIVE!, M4-MUL!, M4-INVERT!), duel/lisp/camera.lisp's look half (DUEL-CAMERA: the behind and pair cameras; the side
//! of the fighter axis is the sim's VIEW-STEP, read from `Match`) and engine/lisp/fx.lisp SHAKE-UPDATE.
use duel_data::tuning::knob;
use duel_sim::cl::{expf, max_f32};
use duel_sim::math::{angle_wrap, deg, dir_yaw, f_cos, f_hypot, f_max, f_min, f_sin, f_sqrt, f_tan};

pub type M4 = [f32; 16];
const IDENTITY: M4 = [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0];

/// port: render.lisp (defstruct camera): the placed camera and what UPDATE-CAMERA derives from it.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Camera {
    pub pos: [f32; 3],
    pub target: [f32; 3],
    pub up: [f32; 3],
    /// A world offset added to POS and TARGET (the screen shake).
    pub shake: [f32; 3],
    /// Vertical, radians.
    pub fov: f32,
    pub shift_y: f32,
    pub shift_x: f32,
    pub near: f32,
    pub far: f32,
    pub eye: [f32; 3],
    pub right: [f32; 3],
    pub upv: [f32; 3],
    pub forward: [f32; 3],
    pub view: M4,
    pub proj: M4,
    pub view_proj: M4,
    pub inv_view_proj: M4,
}

impl Default for Camera {
    fn default() -> Self {
        Camera {
            pos: [0.0, 3.0, 8.0],
            target: [0.0, 1.0, 0.0],
            up: [0.0, 1.0, 0.0],
            shake: [0.0; 3],
            fov: deg(60.0),
            shift_y: 0.0,
            shift_x: 0.0,
            near: 0.1,
            far: 400.0,
            eye: [0.0; 3],
            right: [1.0, 0.0, 0.0],
            upv: [0.0, 1.0, 0.0],
            forward: [0.0, 0.0, -1.0],
            view: IDENTITY,
            proj: IDENTITY,
            view_proj: IDENTITY,
            inv_view_proj: IDENTITY,
        }
    }
}

impl Camera {
    /// port: render.lisp UPDATE-CAMERA — the eye and target with the shake, the view, its axes, the projection (with the lens
    /// shifts), view-proj and its inverse. ASPECT is WINDOW-ASPECT.
    pub fn update(&mut self, aspect: f32) {
        for i in 0..3 {
            self.eye[i] = self.pos[i] + self.shake[i];
        }
        let tgt = [self.target[0] + self.shake[0], self.target[1] + self.shake[1], self.target[2] + self.shake[2]];
        m4_look_at(&mut self.view, self.eye, tgt, self.up);
        let v = &self.view;
        self.right = [v[0], v[4], v[8]];
        self.upv = [v[1], v[5], v[9]];
        self.forward = [-v[2], -v[6], -v[10]];
        m4_perspective(&mut self.proj, self.fov, aspect, self.near, self.far);
        if self.shift_y != 0.0 {
            self.proj[2 * 4 + 1] = -self.shift_y;
        }
        if self.shift_x != 0.0 {
            self.proj[2 * 4] = -self.shift_x;
        }
        self.view_proj = m4_mul(&self.proj, &self.view);
        m4_invert(&mut self.inv_view_proj, &self.view_proj);
    }
}

/// port: math.lisp M4-MUL! — A x B (B applied first), column-major.
pub fn m4_mul(a: &M4, b: &M4) -> M4 {
    let mut t = [0.0f32; 16];
    for c in 0..4 {
        let (b0, b1, b2, b3) = (b[c * 4], b[c * 4 + 1], b[c * 4 + 2], b[c * 4 + 3]);
        for r in 0..4 {
            t[c * 4 + r] = a[r] * b0 + a[4 + r] * b1 + a[8 + r] * b2 + a[12 + r] * b3;
        }
    }
    t
}

/// port: math.lisp M4-PERSPECTIVE! — WebGPU clip space (z in [0, 1]); FOVY vertical, radians.
fn m4_perspective(o: &mut M4, fovy: f32, aspect: f32, near: f32, far: f32) {
    let f = 1.0 / f_tan(0.5 * fovy);
    let nf = 1.0 / (near - far);
    *o = [0.0; 16];
    (o[0], o[5], o[10], o[14], o[11]) = (f / aspect, f, far * nf, far * near * nf, -1.0);
}

/// port: math.lisp M4-LOOK-AT! — the view matrix (the camera looks down -Z).
fn m4_look_at(o: &mut M4, eye: [f32; 3], target: [f32; 3], up: [f32; 3]) {
    let (mut fx, mut fy, mut fz) = (target[0] - eye[0], target[1] - eye[1], target[2] - eye[2]);
    let mut fl = f_sqrt(fx * fx + fy * fy + fz * fz);
    if fl < 1e-9 {
        (fz, fl) = (-1.0, 1.0);
    }
    (fx, fy, fz) = (fx / fl, fy / fl, fz / fl);
    let (ux, uy, uz) = (up[0], up[1], up[2]);
    let (mut sx, mut sy, mut sz) = (fy * uz - fz * uy, fz * ux - fx * uz, fx * uy - fy * ux);
    let mut sl = f_sqrt(sx * sx + sy * sy + sz * sz);
    if sl < 1e-9 {
        (sx, sy, sz, sl) = (1.0, 0.0, 0.0, 1.0);
    }
    (sx, sy, sz) = (sx / sl, sy / sl, sz / sl);
    let (vx, vy, vz) = (sy * fz - sz * fy, sz * fx - sx * fz, sx * fy - sy * fx);
    let (ex, ey, ez) = (eye[0], eye[1], eye[2]);
    // (m@ o r c) = o[c * 4 + r]; (sqrt (the (single-float 0f0) x)) is sqrtf: F-SQRT's fmaxf changes nothing for a sum of squares
    (o[0], o[4], o[8], o[12]) = (sx, sy, sz, -(sx * ex + sy * ey + sz * ez));
    (o[1], o[5], o[9], o[13]) = (vx, vy, vz, -(vx * ex + vy * ey + vz * ez));
    (o[2], o[6], o[10], o[14]) = (-fx, -fy, -fz, fx * ex + fy * ey + fz * ez);
    (o[3], o[7], o[11], o[15]) = (0.0, 0.0, 0.0, 1.0);
}

/// port: math.lisp M4-INVERT! — the general inverse; O untouched when A is singular.
fn m4_invert(o: &mut M4, a: &M4) {
    let mut inv = [0.0f32; 16];
    inv[0] = a[5] * a[10] * a[15] + -(a[5] * a[11] * a[14]) + -(a[9] * a[6] * a[15]) + a[9] * a[7] * a[14] + a[13] * a[6] * a[11] + -(a[13] * a[7] * a[10]);
    inv[4] = -(a[4] * a[10] * a[15]) + a[4] * a[11] * a[14] + a[8] * a[6] * a[15] + -(a[8] * a[7] * a[14]) + -(a[12] * a[6] * a[11]) + a[12] * a[7] * a[10];
    inv[8] = a[4] * a[9] * a[15] + -(a[4] * a[11] * a[13]) + -(a[8] * a[5] * a[15]) + a[8] * a[7] * a[13] + a[12] * a[5] * a[11] + -(a[12] * a[7] * a[9]);
    inv[12] = -(a[4] * a[9] * a[14]) + a[4] * a[10] * a[13] + a[8] * a[5] * a[14] + -(a[8] * a[6] * a[13]) + -(a[12] * a[5] * a[10]) + a[12] * a[6] * a[9];
    inv[1] = -(a[1] * a[10] * a[15]) + a[1] * a[11] * a[14] + a[9] * a[2] * a[15] + -(a[9] * a[3] * a[14]) + -(a[13] * a[2] * a[11]) + a[13] * a[3] * a[10];
    inv[5] = a[0] * a[10] * a[15] + -(a[0] * a[11] * a[14]) + -(a[8] * a[2] * a[15]) + a[8] * a[3] * a[14] + a[12] * a[2] * a[11] + -(a[12] * a[3] * a[10]);
    inv[9] = -(a[0] * a[9] * a[15]) + a[0] * a[11] * a[13] + a[8] * a[1] * a[15] + -(a[8] * a[3] * a[13]) + -(a[12] * a[1] * a[11]) + a[12] * a[3] * a[9];
    inv[13] = a[0] * a[9] * a[14] + -(a[0] * a[10] * a[13]) + -(a[8] * a[1] * a[14]) + a[8] * a[2] * a[13] + a[12] * a[1] * a[10] + -(a[12] * a[2] * a[9]);
    inv[2] = a[1] * a[6] * a[15] + -(a[1] * a[7] * a[14]) + -(a[5] * a[2] * a[15]) + a[5] * a[3] * a[14] + a[13] * a[2] * a[7] + -(a[13] * a[3] * a[6]);
    inv[6] = -(a[0] * a[6] * a[15]) + a[0] * a[7] * a[14] + a[4] * a[2] * a[15] + -(a[4] * a[3] * a[14]) + -(a[12] * a[2] * a[7]) + a[12] * a[3] * a[6];
    inv[10] = a[0] * a[5] * a[15] + -(a[0] * a[7] * a[13]) + -(a[4] * a[1] * a[15]) + a[4] * a[3] * a[13] + a[12] * a[1] * a[7] + -(a[12] * a[3] * a[5]);
    inv[14] = -(a[0] * a[5] * a[14]) + a[0] * a[6] * a[13] + a[4] * a[1] * a[14] + -(a[4] * a[2] * a[13]) + -(a[12] * a[1] * a[6]) + a[12] * a[2] * a[5];
    inv[3] = -(a[1] * a[6] * a[11]) + a[1] * a[7] * a[10] + a[5] * a[2] * a[11] + -(a[5] * a[3] * a[10]) + -(a[9] * a[2] * a[7]) + a[9] * a[3] * a[6];
    inv[7] = a[0] * a[6] * a[11] + -(a[0] * a[7] * a[10]) + -(a[4] * a[2] * a[11]) + a[4] * a[3] * a[10] + a[8] * a[2] * a[7] + -(a[8] * a[3] * a[6]);
    inv[11] = -(a[0] * a[5] * a[11]) + a[0] * a[7] * a[9] + a[4] * a[1] * a[11] + -(a[4] * a[3] * a[9]) + -(a[8] * a[1] * a[7]) + a[8] * a[3] * a[5];
    inv[15] = a[0] * a[5] * a[10] + -(a[0] * a[6] * a[9]) + -(a[4] * a[1] * a[10]) + a[4] * a[2] * a[9] + a[8] * a[1] * a[6] + -(a[8] * a[2] * a[5]);
    let det = a[0] * inv[0] + a[1] * inv[4] + a[2] * inv[8] + a[3] * inv[12];
    if det.abs() < 1e-20 {
        return;
    }
    let d = 1.0 / det;
    for i in 0..16 {
        o[i] = inv[i] * d;
    }
}

/// camera.lisp's knobs (defparameters, from tuning.json).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct CamKnobs {
    pub orbit_rate: f32,
    pub dist_rate: f32,
    pub max_r: f32,
    pub close: f32,
    pub behind_back: f32,
    pub behind_up: f32,
    pub behind_shoulder: f32,
    pub behind_widen: f32,
    pub behind_look: f32,
    pub behind_close: f32,
    pub behind_blend_far: f32,
    pub behind_side: f32,
    pub behind_rate: f32,
    /// fx.lisp `*shake-hz*` (START-GAME sets 12) and `*shake-mult*`.
    pub shake_hz: f32,
    pub shake_mult: f32,
    /// The portrait camera's: `*pt-back*` `*pt-up*` `*pt-shoulder*` `*pt-close*` `*pt-side*` `*pt-lead*` `*pt-head*`
    /// `*pt-frame-bottom*` `*pt-band-fov*` `*pt-fov-min*` `*pt-fov-max*`, and onehand.lisp `*pt-center-lift*` (CSS px).
    pub pt_back: f32,
    pub pt_up: f32,
    pub pt_shoulder: f32,
    pub pt_close: f32,
    pub pt_side: f32,
    pub pt_lead: f32,
    pub pt_head: f32,
    pub pt_frame_bottom: f32,
    pub pt_band_fov: f32,
    pub pt_fov_min: f32,
    pub pt_fov_max: f32,
    pub pt_center_lift: f32,
}

impl CamKnobs {
    pub fn new(d: &duel_data::Data) -> CamKnobs {
        let k = |n: &str| knob::<f32>(&d.tuning, n).unwrap_or_else(|e| panic!("{e}"));
        CamKnobs {
            orbit_rate: k("*CAM-ORBIT-RATE*"),
            dist_rate: k("*CAM-DIST-RATE*"),
            max_r: k("*CAM-MAX-R*"),
            close: k("*CAM-CLOSE*"),
            behind_back: k("*BEHIND-BACK*"),
            behind_up: k("*BEHIND-UP*"),
            behind_shoulder: k("*BEHIND-SHOULDER*"),
            behind_widen: k("*BEHIND-WIDEN*"),
            behind_look: k("*BEHIND-LOOK*"),
            behind_close: k("*BEHIND-CLOSE*"),
            behind_blend_far: k("*BEHIND-BLEND-FAR*"),
            behind_side: k("*BEHIND-SIDE*"),
            behind_rate: k("*BEHIND-RATE*"),
            shake_hz: k("*SHAKE-HZ*"),
            shake_mult: k("*SHAKE-MULT*"),
            pt_back: k("*PT-BACK*"),
            pt_up: k("*PT-UP*"),
            pt_shoulder: k("*PT-SHOULDER*"),
            pt_close: k("*PT-CLOSE*"),
            pt_side: k("*PT-SIDE*"),
            pt_lead: k("*PT-LEAD*"),
            pt_head: k("*PT-HEAD*"),
            pt_frame_bottom: k("*PT-FRAME-BOTTOM*"),
            pt_band_fov: k("*PT-BAND-FOV*"),
            pt_fov_min: k("*PT-FOV-MIN*"),
            pt_fov_max: k("*PT-FOV-MAX*"),
            pt_center_lift: k("*PT-CENTER-LIFT*"),
        }
    }
}

/// camera.lisp's state (its defvars) and fx.lisp's `*shake*`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct CamState {
    /// `*cam-eye*`, `*cam-at*` (the smoothed midpoint), `*cam-ang*`, `*cam-dist*`, `*cam-cut*` (snap on the next frame), `*punch-t*`
    /// (the perfect-Hoho punch-in's real seconds left), `*cam-anchor*` (the behind camera's spring on P1), `*pt-lens*`.
    pub eye: [f32; 3],
    pub at: [f32; 3],
    pub ang: f32,
    pub dist: f32,
    pub cut: bool,
    pub punch_t: f32,
    pub anchor: [f32; 3],
    pub pt_lens: bool,
    /// `*shake*`: amp dur left noise-t ox oy oz.
    pub shake: [f32; 8],
    /// `*pcam*`: [0] the portrait orbit's lead over `*behind-yaw*`, [2] the smoothed vertical FOV ([1], DECK-UPDATE's lens lift, is
    /// `Band::lift`).
    pub pcam: [f32; 3],
}

impl Default for CamState {
    fn default() -> Self {
        CamState { eye: [0.0, 3.0, 12.0], at: [0.0, 1.0, 0.0], ang: 0.0, dist: 7.0, cut: true, punch_t: 0.0, anchor: [0.0; 3], pt_lens: false, shake: [0.0; 8], pcam: [0.0; 3] }
    }
}

/// What DUEL-CAMERA reads of the sim (the live match's, or a `CameraSnap`'s copy): P1's and P2's places and hurt radii (the body's
/// `body-hurt-r`), `*behind-yaw*`, `*view-x*` / `*view-z*`, `*view-behind*`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Pair {
    pub p: [f32; 3],
    pub q: [f32; 3],
    pub hurt: [f32; 2],
    pub behind_yaw: f32,
    pub view_x: f32,
    pub view_z: f32,
    pub view_behind: bool,
}

/// port: camera.lisp DUEL-CAMERA for a landscape window with no cinematic shot (the caller checks those: `draw::duel_camera`):
/// the punch-in's clock, LANDSCAPE-LENS, the behind or the pair camera, the world's up, the camera placed and updated.
pub fn duel_camera_landscape(st: &mut CamState, cam: &mut Camera, kn: &CamKnobs, pr: &Pair, rdt: f32, snap: bool, aspect: f32) {
    st.punch_t = max_f32(0.0, st.punch_t - rdt);
    if st.pt_lens {
        // port: camera.lisp LANDSCAPE-LENS
        (st.pt_lens, cam.shift_y, cam.fov) = (false, 0.0, deg(60.0));
    }
    if pr.view_behind {
        behind_camera(st, kn, pr, rdt, snap);
    } else {
        pair_camera(st, kn, pr, rdt, snap);
    }
    cam.up = [0.0, 1.0, 0.0];
    (cam.pos, cam.target) = (st.eye, st.at);
    cam.update(aspect);
}

/// The page's geometry the portrait camera reads (SceneInputs): the window in pixels, the density, the safe-area insets (CSS px).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct View {
    pub w: u32,
    pub h: u32,
    pub density: f32,
    pub safe_top: f32,
    pub safe_bottom: f32,
}

/// onehand.lisp DECK-UPDATE's portrait frame: `*band*` [0 1] (the frame under P2's HUD block down to `*pt-frame-bottom*`) and
/// `*pcam*` [1] (the lens's lift, NDC).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Band {
    pub top: f32,
    pub bottom: f32,
    pub lift: f32,
}

/// port: onehand.lisp DECK-UPDATE's `*band*` / `*pcam*` [1] for the view V, with engine/lisp/ui.lisp UI-SCALE (ONEHAND-FRAME's
/// `*ui-min-css*`: 11 on a portrait window, else 0) and hud.lisp PORTRAIT-HUD-BOTTOM / PORTRAIT-P1-TOP (a block 29 x scale px tall).
pub fn band(kn: &CamKnobs, v: &View) -> Band {
    let (w, h, d) = (v.w as i64, v.h as i64, v.density);
    let min_css: i64 = if h > w { 11 } else { 0 };
    // (round h 360): CL ROUND, half to even, of the ratio; (floor w 480)
    let rq = |a: i64, b: i64| {
        let (q, r) = (a.div_euclid(b), a.rem_euclid(b));
        if 2 * r > b || (2 * r == b && q % 2 != 0) { q + 1 } else { q }
    };
    let mut s = 1.max(rq(h, 360).min(w.div_euclid(480)));
    if min_css > 0 {
        s = s.max(((min_css as f32 * d) / 7.0).ceil() as i64); // (ceiling (* *ui-min-css* (pixel-density)) 7)
    }
    let block = (29 * s) as f32;
    let hud_bottom = (v.safe_top * d + (2 * s) as f32) + block;
    let p1_top = (h as f32 - max_f32(8.0, v.safe_bottom + 4.0) * d) - block;
    let (hb, pt) = (hud_bottom / h as f32, p1_top / h as f32);
    Band { top: hb + 0.03, bottom: f_min(kn.pt_frame_bottom, pt - 0.03), lift: (2.0 * kn.pt_center_lift * d) / h.max(1) as f32 }
}

/// port: camera.lisp %PORTRAIT-CAMERA — `*cam-eye*` / `*cam-at*` and the lens for the portrait camera behind P1 toward P2 (SNAP: no
/// smoothing); then DUEL-CAMERA's tail (`*cam-cut*` cleared, the up vector, the camera placed and updated).
pub fn duel_camera_portrait(st: &mut CamState, cam: &mut Camera, kn: &CamKnobs, pr: &Pair, rdt: f32, snap: bool, v: &View) {
    st.punch_t = max_f32(0.0, st.punch_t - rdt);
    let snap = snap || st.cut;
    let bd = band(kn, v);
    let (p, q) = (pr.p, pr.q);
    let (dx, dz) = (q[0] - p[0], q[2] - p[2]);
    let sep = f_sqrt(dx * dx + dz * dz);
    let sim = pr.behind_yaw;
    let lim = 0.017453292 * kn.pt_lead;
    let clamp = |x: f32, lo: f32, hi: f32| f_min(f_max(x, lo), hi);
    let wrap = crate::anim::f_wrap;
    let atan2 = |y: f32, x: f32| duel_sim::math::yaw_to(-y, -x);
    let want = if sep > 0.01 { clamp(wrap(atan2(-dx, -dz) - sim), -lim, lim) } else { 0.0 };
    let k = if snap { 1.0 } else { 1.0 - expf(-8.0 * rdt) };
    let pc = &mut st.pcam;
    let lead = pc[0] + k * (want - pc[0]);
    let yaw = sim + lead;
    let (fx, fz) = (-f_sin(yaw), -f_cos(yaw));
    let wide = kn.behind_widen * f_max(0.0, sep - 4.0);
    let back = kn.close * (kn.pt_back + wide) * if st.punch_t > 0.0 { 0.8 } else { 1.0 };
    let off = 0.017453292 * (kn.pt_side + (kn.pt_close - kn.pt_side) * clamp((kn.behind_blend_far - sep) / (kn.behind_blend_far - 2.0), 0.0, 1.0));
    let side = kn.pt_shoulder + back * f_sin(off);
    let bk = back * f_cos(off);
    let ka = if snap { 1.0 } else { 1.0 - expf(-kn.behind_rate * rdt) };
    pc[0] = lead;
    let c = &mut st.anchor;
    c[0] += ka * (p[0] - c[0]);
    c[2] += ka * (p[2] - c[2]);
    let mut ex = c[0] + -bk * fx + side * -fz;
    let mut ez = c[2] + -bk * fz + side * fx;
    let r = f_sqrt(ex * ex + ez * ez);
    let kr = f_min(1.0, kn.max_r / f_max(0.01, r));
    let h = kn.pt_up + 0.33 * wide + 0.4 * (r - kr * r);
    (ex, ez) = (kr * ex, kr * ez);
    for o in [p, q] {
        // (never inside a fighter)
        let (ddx, ddz) = (ex - o[0], ez - o[2]);
        let d = f_sqrt(ddx * ddx + ddz * ddz);
        if d < 1.0 && d > 0.001 {
            (ex, ez) = (o[0] + ddx / d, o[2] + ddz / d);
        }
    }
    st.eye = [ex, h, ez];
    let (ax, az, bx, bz) = (p[0] - ex, p[2] - ez, q[0] - ex, q[2] - ez);
    let (d1, d2) = (f_sqrt(ax * ax + az * az), f_sqrt(bx * bx + bz * bz));
    let (a1, a2) = (atan2(-ax, -az), atan2(-bx, -bz));
    let da = wrap(a2 - a1);
    let want = wrap((a1 + 0.5 * da) - yaw);
    let dy = clamp(want, -(lim + off), lim + off);
    let aim = yaw + dy;
    let t1 = atan2(h, f_max(0.5, d1 - 0.6));
    let t2 = atan2(h - kn.pt_head - 0.3, d2 + 0.6);
    let pitch = 0.5 * (t1 + t2);
    let cp = 5.0 * f_cos(pitch);
    let b = f_max(0.1, bd.bottom - bd.top);
    let hb = f_max(0.0087266462 * kn.pt_band_fov, 0.5 * (t1 - t2) + 0.026);
    let hz = 0.5 * duel_sim::math::f_abs(da) + duel_sim::math::f_abs(want - dy) + atan2(0.7, f_max(0.5, f_min(d1, d2) - 0.6));
    let asp = v.w as f32 / v.h.max(1) as f32;
    let hz1 = f_min(hz, 1.4);
    let fov = clamp(2.0 * f_max(atan2(f_sin(hb) / f_cos(hb), b), atan2(f_sin(hz1) / f_cos(hz1), asp)), 0.017453292 * kn.pt_fov_min, 0.017453292 * kn.pt_fov_max);
    let pc = &mut st.pcam;
    let sm = if snap || !st.pt_lens { fov } else { pc[2] + k * (fov - pc[2]) };
    let sh = (1.0 - (bd.top + bd.bottom)) + bd.lift;
    st.at = [ex + cp * -f_sin(aim), h - 5.0 * f_sin(pitch), ez + cp * -f_cos(aim)];
    (pc[2], st.pt_lens) = (sm, true);
    if duel_sim::math::f_abs(cam.fov - sm) > 0.002 {
        cam.fov = sm;
    }
    if cam.shift_y != sh {
        cam.shift_y = sh;
    }
    st.cut = false;
    cam.up = [0.0, 1.0, 0.0];
    (cam.pos, cam.target) = (st.eye, st.at);
    cam.update(asp);
}

/// port: camera.lisp %POW2: `(expt x 2)` of a single float as ECL computes it (C powf).
pub(crate) fn pow2(x: f32) -> f32 {
    duel_sim::cl::musl_powf(x, 2.0)
}

/// port: camera.lisp BEHIND-CAMERA — `*cam-eye*` / `*cam-at*` behind P1, looking along `*behind-yaw*` toward P2.
fn behind_camera(st: &mut CamState, kn: &CamKnobs, pr: &Pair, rdt: f32, snap: bool) {
    let (p, q) = (pr.p, pr.q);
    let sep = f_sqrt(pow2(q[0] - p[0]) + pow2(q[2] - p[2]));
    let wide = kn.behind_widen * f_max(0.0, sep - 4.0);
    let mut back = kn.close * (kn.behind_back + wide) * if st.punch_t > 0.0 { 0.6 } else { 1.0 };
    let blend = f_max(0.0, f_min(1.0, (kn.behind_blend_far - sep) / (kn.behind_blend_far - 2.0)));
    let off = deg(kn.behind_side + (kn.behind_close - kn.behind_side) * blend);
    let side = kn.behind_shoulder + back * f_sin(off);
    let (fx, fz) = (-f_sin(pr.behind_yaw), -f_cos(pr.behind_yaw));
    back *= f_cos(off);
    let c = &mut st.anchor;
    if snap || st.cut {
        (c[0], c[2], st.cut) = (p[0], p[2], false);
    } else {
        let k = 1.0 - expf(-kn.behind_rate * rdt);
        c[0] += k * (p[0] - c[0]);
        c[2] += k * (p[2] - c[2]);
    }
    let mut ex = c[0] + -back * fx + side * -fz;
    let mut ez = c[2] + -back * fz + side * fx;
    let r = f_hypot(ex, ez);
    let k = f_min(1.0, kn.max_r / f_max(0.01, r));
    let h = kn.behind_up + 0.33 * wide + 0.4 * (r - k * r);
    (ex, ez) = (k * ex, k * ez);
    for (o, hr) in [(p, pr.hurt[0]), (q, pr.hurt[1])] {
        // (never inside a fighter)
        let (dx, dz) = (ex - o[0], ez - o[2]);
        let d = f_hypot(dx, dz);
        let min_d = 0.5 + hr;
        if d < min_d && d > 0.001 {
            (ex, ez) = (o[0] + dx * (min_d / d), o[2] + dz * (min_d / d));
        }
    }
    st.eye = [ex, h, ez];
    st.at = [c[0] + kn.behind_look * sep * fx, 1.1, c[2] + kn.behind_look * sep * fz];
}

/// port: camera.lisp PAIR-CAMERA — `*cam-eye*` / `*cam-at*` on the sim's view side of P1 and P2, the orbit angle, distance and
/// midpoint smoothed (SNAP or `*cam-cut*`: none).
fn pair_camera(st: &mut CamState, kn: &CamKnobs, pr: &Pair, rdt: f32, snap: bool) {
    let (p, q) = (pr.p, pr.q);
    let (mx, mz) = (0.5 * (p[0] + q[0]), 0.5 * (p[2] + q[2]));
    let (dx, dz) = (q[0] - p[0], q[2] - p[2]);
    let sep = f_hypot(dx, dz);
    let (ux, uz) = if sep > 0.01 { (dx / sep, dz / sep) } else { (1.0, 0.0) };
    let ang = dir_yaw(-pr.view_z, -pr.view_x); // (%atan2-d: the double atan2 rounded; DIR-YAW's atan2(-dx, -dz))
    let dist = kn.close * f_max(6.0, 4.5 + 0.85 * sep) * if st.punch_t > 0.0 { 0.6 } else { 1.0 };
    let h = 2.5 + 0.15 * sep;
    if snap || st.cut {
        (st.ang, st.dist, st.cut, st.at[0], st.at[2]) = (ang, dist, false, mx, mz);
    } else {
        let k = 1.0 - expf(-kn.orbit_rate * rdt);
        let kd = 1.0 - expf(-kn.dist_rate * rdt);
        st.ang += k * angle_wrap(ang - st.ang);
        st.dist += kd * (dist - st.dist);
        st.at[0] += k * (mx - st.at[0]);
        st.at[2] += k * (mz - st.at[2]);
    }
    let (cd, ca, c) = (st.dist, st.ang, st.at);
    let back = 0.05 * cd;
    let ex = c[0] + cd * f_cos(ca) - back * ux;
    let ez = c[2] + cd * f_sin(ca) - back * uz;
    let k = f_min(1.0, kn.max_r / f_max(0.01, f_hypot(ex, ez)));
    st.eye = [k * ex, h, k * ez];
    st.at[1] = 1.05;
}

/// port: engine/lisp/fx.lisp SHAKE-UPDATE — the shake decays over its duration; its noise (three cosmetic draws) changes
/// `*shake-hz*` times a second, drawn even with no shake running.
pub fn shake_update(st: &mut CamState, cam: &mut Camera, kn: &CamKnobs, cos: &mut crate::CosRng, dt: f32) {
    let s = &mut st.shake;
    s[2] = f_max(0.0, s[2] - dt);
    s[3] -= dt;
    if s[3] <= 0.0 {
        s[3] = 1.0 / f_max(1.0, kn.shake_hz);
        for x in &mut s[4..7] {
            *x = -1.0 + (1.0 - -1.0) * cos.rnd01();
        }
    }
    let a = if s[1] > 0.0 { s[0] * (s[2] / s[1]) } else { 0.0 };
    cam.shake = [a * s[4], a * s[5], a * s[6]];
}

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
}

impl Default for CamState {
    fn default() -> Self {
        CamState { eye: [0.0, 3.0, 12.0], at: [0.0, 1.0, 0.0], ang: 0.0, dist: 7.0, cut: true, punch_t: 0.0, anchor: [0.0; 3], pt_lens: false, shake: [0.0; 8] }
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

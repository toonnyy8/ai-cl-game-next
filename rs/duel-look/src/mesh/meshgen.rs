//! port: engine/lisp/meshgen.lisp — the mesh builder (flat normals, per-vertex colour, analytic smooth normals on spheres and
//! cylinder sides), its primitives and the ink hull; 9 floats a vertex (position, normal, sRGB colour) as MB-BUILD hands them to
//! r_mesh_new. Setup time: allocates freely.
//!
//! Floats follow the Lisp's types site by site: singles where the Lisp is single; every `pi` site is a long-float in the native
//! image (a double in the wasm game), done here in f64 with musl's sin / cos and narrowed once where the Lisp narrows (V3, XFORM's
//! F32), so those values may differ from the key in the last bits (BEVY_PORT §5.3).
use duel_sim::cl::{max_f32, min_f32, round_f32};
use duel_sim::math::{f_max, f_min, f_sqrt};
use std::collections::HashMap;

pub type V3 = [f32; 3];
pub type M4 = [f32; 16];

pub const PI: f64 = std::f64::consts::PI;

/// port: engine/lisp/package.lisp F-HYPOT of three singles: F-SQRT of ((a² + b²) + c²).
fn f_hypot3(a: f32, b: f32, c: f32) -> f32 {
    f_sqrt(a * a + b * b + c * c)
}

/// port: engine/lisp/meshgen.lisp HEXC: #xRRGGBB -> (r g b), each channel times K, capped at 1 (CL MIN).
pub fn hexc_k(h: i64, k: f32) -> V3 {
    let ch = |s: u32| min_f32(1.0, k * (((h >> s) & 0xff) as f32 / 255.0));
    [ch(16), ch(8), ch(0)]
}
pub fn hexc(h: i64) -> V3 {
    hexc_k(h, 1.0)
}

/// port: engine/lisp/math.lisp M4-MUL! (o = a * b, b applied first; each sum left to right).
pub fn m4_mul(a: &M4, b: &M4) -> M4 {
    let mut o = [0f32; 16];
    for c in 0..4 {
        let (b0, b1, b2, b3) = (b[c * 4], b[c * 4 + 1], b[c * 4 + 2], b[c * 4 + 3]);
        for r in 0..4 {
            o[c * 4 + r] = a[r] * b0 + a[4 + r] * b1 + a[8 + r] * b2 + a[12 + r] * b3;
        }
    }
    o
}

/// port: engine/lisp/math.lisp M4-EULER! (T * Ry(yaw) Rx(pitch) Rz(roll) * S, single-float, cosf / sinf).
#[allow(clippy::too_many_arguments)]
pub fn m4_euler(px: f32, py: f32, pz: f32, yaw: f32, pitch: f32, roll: f32, sx: f32, sy: f32, sz: f32) -> M4 {
    let (cy, sny, cp, sp, cr, sr) = (libm_cos(yaw), libm_sin(yaw), libm_cos(pitch), libm_sin(pitch), libm_cos(roll), libm_sin(roll));
    [
        sx * (cy * cr + sny * sp * sr),
        sx * cp * sr,
        sx * (cy * sp * sr - sny * cr),
        0.0,
        sy * (sny * sp * cr - cy * sr),
        sy * cp * cr,
        sy * (sny * sr + cy * sp * cr),
        0.0,
        sz * sny * cp,
        sz * -sp,
        sz * cy * cp,
        0.0,
        px,
        py,
        pz,
        1.0,
    ]
}
fn libm_cos(a: f32) -> f32 {
    duel_sim::math::f_cos(a)
}
fn libm_sin(a: f32) -> f32 {
    duel_sim::math::f_sin(a)
}

/// port: engine/lisp/math.lisp XFORM's keywords (every one made a single by F32 first).
#[derive(Clone, Copy)]
pub struct Xf {
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub yaw: f32,
    pub pitch: f32,
    pub roll: f32,
    pub sx: f32,
    pub sy: f32,
    pub sz: f32,
}
pub const XF: Xf = Xf { x: 0.0, y: 0.0, z: 0.0, yaw: 0.0, pitch: 0.0, roll: 0.0, sx: 1.0, sy: 1.0, sz: 1.0 };
impl Xf {
    /// port: engine/lisp/math.lisp XFORM.
    pub fn m(&self) -> M4 {
        m4_euler(self.x, self.y, self.z, self.yaw, self.pitch, self.roll, self.sx, self.sy, self.sz)
    }
    /// `:s s` (sx sy sz default to it).
    pub fn s(self, s: f32) -> Xf {
        Xf { sx: s, sy: s, sz: s, ..self }
    }
}

/// port: engine/lisp/meshgen.lisp M4-DET3.
fn m4_det3(m: &M4) -> f32 {
    m[0] * (m[5] * m[10] - m[9] * m[6]) + m[8] * (m[1] * m[6] - m[5] * m[2]) - m[4] * (m[1] * m[10] - m[9] * m[2])
}

/// port: engine/lisp/meshgen.lisp MESH-BUILDER. ponytail: no jitter / seed: every builder this port makes has jitter 0
/// (BUILD-SOLID's *PART-JITTER* 0.0, BUILD-MESH's default 0), so MB-RAND never runs; add them with the first builder that jitters.
pub struct Mb {
    pub data: Vec<f32>,
    xform: M4,
    flip: bool,
    pub cur: V3,
    /// NIL, or #(kind hs slope) of the surface being emitted (%MB-TRI).
    smooth: Option<V3>,
}

impl Default for Mb {
    fn default() -> Self {
        Self::new()
    }
}

impl Mb {
    /// port: engine/lisp/meshgen.lisp MAKE-MESH-BUILDER (current colour 0.7 0.7 0.7).
    pub fn new() -> Mb {
        let mut id = [0f32; 16];
        (id[0], id[5], id[10], id[15]) = (1.0, 1.0, 1.0, 1.0);
        Mb { data: Vec::with_capacity(4096), xform: id, flip: false, cur: [0.7, 0.7, 0.7], smooth: None }
    }
    /// port: engine/lisp/meshgen.lisp BUILD-MESH's builder: COLOR set first.
    pub fn with_color(c: V3) -> Mb {
        let mut mb = Mb::new();
        mb.cur = c;
        mb
    }
    pub fn fill(&self) -> usize {
        self.data.len()
    }
    /// port: engine/lisp/meshgen.lisp MB-COLOR (each channel F32: already singles here).
    pub fn color(&mut self, c: V3) {
        self.cur = c;
    }
    /// port: engine/lisp/meshgen.lisp MBC.
    pub fn hex(&mut self, h: i64) {
        self.cur = hexc(h);
    }

    /// port: engine/lisp/meshgen.lisp WITH-XFORM (current * M for F's duration, the winding flipped when the transform mirrors).
    pub fn with(&mut self, m: &M4, f: impl FnOnce(&mut Mb)) {
        let old = self.xform;
        self.xform = m4_mul(&old, m);
        self.flip = m4_det3(&self.xform) < 0.0;
        f(self);
        self.xform = old;
        self.flip = m4_det3(&old) < 0.0;
    }
    /// port: engine/lisp/meshgen.lisp MB-AT.
    pub fn at(&mut self, x: Xf, f: impl FnOnce(&mut Mb)) {
        self.with(&x.m(), f)
    }

    /// port: engine/lisp/meshgen.lisp %MB-FACE-COLOR with jitter 0: (min 1 c) per channel (fminf).
    fn face_color(&self, color: Option<V3>) -> V3 {
        let c = color.unwrap_or(self.cur);
        [f_min(1.0, c[0]), f_min(1.0, c[1]), f_min(1.0, c[2])]
    }

    /// port: engine/lisp/meshgen.lisp %MB-TRI (the face normal, or the analytic smooth normal turned by the builder transform).
    fn tri(&mut self, fc: V3, a: V3, b: V3, c: V3) {
        let m = self.xform;
        let (b, c) = if self.flip { (c, b) } else { (b, c) };
        let xf = |v: V3, i: usize| m[i] * v[0] + m[i + 4] * v[1] + m[i + 8] * v[2] + m[i + 12];
        let (x0, y0, z0) = (xf(a, 0), xf(a, 1), xf(a, 2));
        let (x1, y1, z1) = (xf(b, 0), xf(b, 1), xf(b, 2));
        let (x2, y2, z2) = (xf(c, 0), xf(c, 1), xf(c, 2));
        let (ax, ay, az) = (x1 - x0, y1 - y0, z1 - z0);
        let (bx, by, bz) = (x2 - x0, y2 - y0, z2 - z0);
        let (mut nx, mut ny, mut nz) = (ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx);
        let l = f_hypot3(nx, ny, nz);
        if l > 1e-12 {
            let k = 1.0 / l;
            (nx, ny, nz) = (nx * k, ny * k, nz * k);
        } else {
            (nx, ny, nz) = (0.0, 0.0, 0.0);
        }
        for (x, y, z, v) in [(x0, y0, z0, a), (x1, y1, z1, b), (x2, y2, z2, c)] {
            let mut n = [nx, ny, nz];
            if let Some(s) = self.smooth {
                let (lx, lz) = (v[0], v[2]);
                let ly = if s[0] < 1.5 { v[1] - f_max(-s[1], f_min(s[1], v[1])) } else { s[2] * f_sqrt(lx * lx + lz * lz) };
                let wx = m[0] * lx + m[4] * ly + m[8] * lz;
                let wy = m[1] * lx + m[5] * ly + m[9] * lz;
                let wz = m[2] * lx + m[6] * ly + m[10] * lz;
                let wl = f_hypot3(wx, wy, wz);
                if wl > 1e-6 {
                    n = [wx / wl, wy / wl, wz / wl];
                }
            }
            self.data.extend_from_slice(&[x, y, z, n[0], n[1], n[2], fc[0], fc[1], fc[2]]);
        }
    }

    /// port: engine/lisp/meshgen.lisp MB-POLY-OUT (a convex planar polygon facing away from CENTER; a fan from its first point).
    pub fn poly_out(&mut self, pts: &[V3], color: Option<V3>, center: V3) {
        let rev: Vec<V3>;
        let pts = if outward_p(pts[0], pts[1], pts[2], center) {
            pts
        } else {
            rev = pts.iter().rev().copied().collect();
            &rev
        };
        let fc = self.face_color(color);
        for w in pts[1..].windows(2) {
            self.tri(fc, pts[0], w[0], w[1]);
        }
    }
    pub fn poly(&mut self, pts: &[V3]) {
        self.poly_out(pts, None, [0.0; 3])
    }

    /// port: engine/lisp/meshgen.lisp MB-BOX.
    pub fn box_(&mut self, w: f32, h: f32, d: f32) {
        self.bevel_box(w, h, d, 0.0)
    }

    /// port: engine/lisp/meshgen.lisp %MB-BOX-FACES (colours: always the current one here; no caller passes MB-BOX :colors).
    fn box_faces(&mut self, full: V3, inn: V3) {
        for fi in 0..6 {
            let (axis, i, j) = (fi / 2, (fi / 2 + 1) % 3, (fi / 2 + 2) % 3);
            let mut q = [[0f32; 3]; 4];
            for (qi, v) in q.iter_mut().enumerate() {
                v[axis] = if fi % 2 == 1 { -full[axis] } else { full[axis] };
                v[i] = if qi == 1 || qi == 2 { inn[i] } else { -inn[i] };
                v[j] = if qi >= 2 { inn[j] } else { -inn[j] };
            }
            let fc = self.face_color(None);
            if outward_p(q[0], q[1], q[2], [0.0; 3]) {
                self.tri(fc, q[0], q[1], q[2]);
                self.tri(fc, q[0], q[2], q[3]);
            } else {
                self.tri(fc, q[3], q[2], q[1]);
                self.tri(fc, q[3], q[1], q[0]);
            }
        }
    }

    /// port: engine/lisp/meshgen.lisp MB-BEVEL-BOX (BEVEL 0 = MB-BOX: the Lisp's integer 0 wins its MIN, so nothing is inset).
    pub fn bevel_box(&mut self, w: f32, h: f32, d: f32, bevel: f32) {
        let he = [0.5 * w, 0.5 * h, 0.5 * d];
        let bv = if bevel == 0.0 { 0.0 } else { min_f32(bevel, 0.49 * min_f32(min_f32(w, h), d)) };
        let pt = |s: [f32; 3], axis: usize| -> V3 {
            let mut v = [0f32; 3];
            for i in 0..3 {
                v[i] = s[i] * if i == axis { he[i] } else { he[i] - bv };
            }
            v
        };
        let full = he;
        let inn = [he[0] - bv, he[1] - bv, he[2] - bv];
        self.box_faces(full, inn);
        if bv > 0.0 {
            for e in 0..3 {
                let (i, j) = ((e + 1) % 3, (e + 2) % 3);
                for si in [-1f32, 1.0] {
                    for sj in [-1f32, 1.0] {
                        let c = |se: f32| {
                            let mut s = [0f32; 3];
                            (s[e], s[i], s[j]) = (se, si, sj);
                            s
                        };
                        let (lo, hi) = (c(-1.0), c(1.0));
                        self.poly(&[pt(lo, i), pt(hi, i), pt(hi, j), pt(lo, j)]);
                    }
                }
            }
            for sx in [-1f32, 1.0] {
                for sy in [-1f32, 1.0] {
                    for sz in [-1f32, 1.0] {
                        let s = [sx, sy, sz];
                        self.poly(&[pt(s, 0), pt(s, 1), pt(s, 2)]);
                    }
                }
            }
        }
    }

    /// port: engine/lisp/meshgen.lisp MB-CYLINDER (a frustum along Y, centred; TOP 0 a cone; SMOOTH: analytic normals on the side, flat caps).
    #[allow(clippy::too_many_arguments)]
    pub fn cylinder(&mut self, radius: f32, height: f32, segments: usize, top: f32, caps: bool, top_color: Option<V3>, smooth: bool) {
        let hy = 0.5 * height;
        let bot = ring(radius, -hy, segments);
        let tp = ring(top, hy, segments);
        if smooth {
            self.smooth = Some([2.0, 0.0, (radius - top) / max_f32(height, 1e-6)]);
        }
        for k in 0..segments {
            let k2 = (k + 1) % segments;
            if top < 1e-6 {
                self.poly(&[bot[k], bot[k2], tp[k]]);
            } else {
                self.poly(&[bot[k], bot[k2], tp[k2], tp[k]]);
            }
        }
        self.smooth = None;
        if caps {
            self.poly(&bot);
            if top > 1e-6 {
                self.poly_out(&tp, top_color, [0.0; 3]);
            }
        }
    }

    /// port: engine/lisp/meshgen.lisp MB-CONE.
    pub fn cone(&mut self, radius: f32, height: f32, segments: usize) {
        self.cylinder(radius, height, segments, 0.0, true, None, false)
    }

    /// port: engine/lisp/meshgen.lisp MB-SPHERE (a UV sphere; STRETCH > 0 splits it at the equator around a cylinder of that length).
    pub fn sphere(&mut self, radius: f32, segments: usize, rings: usize, stretch: f32, smooth: bool) {
        let (n, hs, half) = (segments, 0.5 * stretch, rings / 2);
        let mut spec: Vec<(usize, f32)> = (0..=half).map(|i| (i, hs)).collect();
        if stretch > 0.0 {
            spec.push((half, -hs));
        }
        spec.extend((half + 1..=rings).map(|i| (i, -hs)));
        let rows: Vec<(bool, Vec<V3>)> = spec
            .iter()
            .map(|&(i, dy)| {
                let phi = PI * (i as f64 / rings as f64);
                let y = dy as f64 + radius as f64 * duel_sim::math::cos_d(phi);
                let r = radius as f64 * duel_sim::math::sin_d(phi);
                (i == 0 || i == rings, ring_d(r, y, n))
            })
            .collect();
        if smooth {
            self.smooth = Some([1.0, hs, 0.0]);
        }
        for w in rows.windows(2) {
            let ((up_pole, up), (dn_pole, dn)) = (&w[0], &w[1]);
            for k in 0..n {
                let k2 = (k + 1) % n;
                if *up_pole {
                    self.poly(&[up[k], dn[k], dn[k2]]);
                } else if *dn_pole {
                    self.poly(&[up[k], dn[k], up[k2]]);
                } else {
                    self.poly(&[up[k], dn[k], dn[k2], up[k2]]);
                }
            }
        }
        self.smooth = None;
    }

    /// port: engine/lisp/meshgen.lisp MB-WEDGE (W x D footprint, full height at the back (-Z), sloping to the front).
    pub fn wedge(&mut self, w: f32, h: f32, d: f32) {
        let (hx, hy, hz) = (0.5 * w, 0.5 * h, 0.5 * d);
        let c = [0.0, -(hy / 3.0), -(hz / 3.0)];
        let (lb, rb) = ([-hx, -hy, hz], [hx, -hy, hz]);
        let (lk, rk) = ([-hx, -hy, -hz], [hx, -hy, -hz]);
        let (lt, rt) = ([-hx, hy, -hz], [hx, hy, -hz]);
        self.poly_out(&[lb, rb, rk, lk], None, c);
        self.poly_out(&[lk, rk, rt, lt], None, c);
        self.poly_out(&[lb, rb, rt, lt], None, c);
        self.poly_out(&[lb, lk, lt], None, c);
        self.poly_out(&[rb, rk, rt], None, c);
    }
}

/// port: engine/lisp/meshgen.lisp MB-CYLINDER's ring: (r cos a, y, -r sin a) at a = 2 pi k / n (a long-float: `(/ (* 2 pi k) n)`), R and Y singles.
fn ring(r: f32, y: f32, n: usize) -> Vec<V3> {
    (0..n)
        .map(|k| {
            let a = 2.0 * PI * k as f64 / n as f64;
            [(r as f64 * duel_sim::math::cos_d(a)) as f32, y, (r as f64 * -duel_sim::math::sin_d(a)) as f32]
        })
        .collect()
}
/// port: engine/lisp/meshgen.lisp MB-SPHERE's ring: the same with R and Y long-floats (`(* radius (sin phi))`).
fn ring_d(r: f64, y: f64, n: usize) -> Vec<V3> {
    (0..n)
        .map(|k| {
            let a = 2.0 * PI * k as f64 / n as f64;
            [(r * duel_sim::math::cos_d(a)) as f32, y as f32, (r * -duel_sim::math::sin_d(a)) as f32]
        })
        .collect()
}

/// port: engine/lisp/meshgen.lisp OUTWARD-P (is A B C wound CCW seen from outside, relative to interior point C*?).
pub fn outward_p(a: V3, b: V3, c: V3, ctr: V3) -> bool {
    let (ux, uy, uz) = (b[0] - a[0], b[1] - a[1], b[2] - a[2]);
    let (vx, vy, vz) = (c[0] - a[0], c[1] - a[1], c[2] - a[2]);
    let (nx, ny, nz) = (uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx);
    nx * (a[0] + b[0] + c[0] - 3.0 * ctr[0]) + ny * (a[1] + b[1] + c[1] - 3.0 * ctr[1]) + nz * (a[2] + b[2] + c[2] - 3.0 * ctr[2]) >= 0.0
}

/// port: engine/lisp/meshgen.lisp MB-HULL: append to DST the ink hull of SRC's triangles in floats [START, END): the same
/// triangles in COLOR, each vertex's normal slot holding its extrusion E = K s / max(min s.n, C), s the normalised sum of its
/// position group's distinct face normals (groups by CL (round x 1e-4) per coordinate: the single quotient, half to even).
pub fn hull(dst: &mut Vec<f32>, d: &[f32], start: usize, end: usize, k: f32, c: f32, color: V3) {
    struct G {
        /// The group's distinct unit face normals in discovery order (the Lisp pushes: its list is newest first).
        ns: Vec<V3>,
        e: V3,
    }
    let key = |o: usize| (round_f32(d[o] / 1e-4), round_f32(d[o + 1] / 1e-4), round_f32(d[o + 2] / 1e-4));
    let mut groups: HashMap<(i64, i64, i64), G> = HashMap::new();
    let dot = |a: V3, b: V3| a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
    for o in (start..end).step_by(27) {
        let (ax, ay, az) = (d[o + 9] - d[o], d[o + 10] - d[o + 1], d[o + 11] - d[o + 2]);
        let (bx, by, bz) = (d[o + 18] - d[o], d[o + 19] - d[o + 1], d[o + 20] - d[o + 2]);
        let n = [ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx];
        let l = libm_sqrtf(dot(n, n));
        for v in 0..3 {
            let vo = o + v * 9;
            let g = groups.entry(key(vo)).or_insert_with(|| G { ns: vec![], e: [d[vo + 3], d[vo + 4], d[vo + 5]] });
            if l > 1e-12 {
                let u = [n[0] / l, n[1] / l, n[2] / l];
                if !g.ns.iter().any(|m| dot(u, *m) > 0.999) {
                    g.ns.push(u);
                }
            }
        }
    }
    for g in groups.values_mut() {
        let mut sum = [0f32; 3];
        for n in g.ns.iter().rev() {
            sum = [sum[0] + n[0], sum[1] + n[1], sum[2] + n[2]];
        }
        let sl = libm_sqrtf(dot(sum, sum));
        g.e = if sl < 1e-3 {
            [k * g.e[0], k * g.e[1], k * g.e[2]]
        } else {
            let s = [sum[0] / sl, sum[1] / sl, sum[2] / sl];
            let m = g.ns.iter().rev().map(|n| dot(s, *n)).reduce(min_f32).unwrap();
            let q = max_f32(m, c);
            [k * s[0] / q, k * s[1] / q, k * s[2] / q]
        };
    }
    for o in (start..end).step_by(27) {
        for v in 0..3 {
            let vo = o + v * 9;
            let e = groups[&key(vo)].e;
            dst.extend_from_slice(&[d[vo], d[vo + 1], d[vo + 2], e[0], e[1], e[2], color[0], color[1], color[2]]);
        }
    }
}
fn libm_sqrtf(x: f32) -> f32 {
    // CL SQRT of a non-negative single = sqrtf (correctly rounded: std's sqrt is the same IEEE operation).
    x.sqrt()
}

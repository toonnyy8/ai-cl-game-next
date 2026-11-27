//! The FX (docs/bevy/M3A_NOTES.md §6): engine/lisp/fx.lisp's pools (particles, rings, the trails), fx-shapes.lisp's toon kit
//! (`shapes`), render.lisp's fx batches (WITH-FX-VERTS, STREAM-ROOM-P), and SOUL DUEL's looks on them: vfx.lisp's lights and auras
//! (`vfx`), the stage's cracks, marks and chips (`crack`), feedback.lisp (`feedback`). Everything here is cosmetic: it reads the match
//! and draws `CosRng`, never the sim stream.
pub mod crack;
pub mod feedback;
pub mod hazard;
pub mod screen;
pub mod shapes;
pub mod stamps;
pub mod vfx;

use crate::draw::camera::Camera;
use crate::draw::frame::FrameOut;
use crate::rng::CosRng;
use duel_sim::math::{f_max, f_min, f_mod};

/// A fx batch (WITH-FX-VERTS' MODE): `*fx-alpha*`, `*fx-add*`, `*fx-toon*`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Mode {
    Alpha,
    Add,
    Toon,
}

/// RENDER-INIT's `(make-stream-buffer 9 16384)` for each fx batch: STREAM-ROOM-P's cap in floats.
pub const FX_STREAM_FLOATS: usize = 9 * 16384;

/// The particle pool's size and stride (fx.lisp +PMAX+, +PSTRIDE+).
pub const PMAX: usize = 2000;
pub const PSTRIDE: usize = 15;
/// The particle kinds (fx.lisp +P-...+).
pub const P_MIST: f32 = 0.0;
pub const P_SPARK: f32 = 1.0;
pub const P_DUST: f32 = 2.0;
pub const P_ORB_A: f32 = 3.0;
pub const P_ORB_B: f32 = 4.0;
pub const P_FEATHER: f32 = 5.0;
pub const P_GLOW: f32 = 6.0;
pub const P_FLAME: f32 = 7.0;
pub const P_T_BLOB: f32 = 8.0;
pub const P_T_SHARD: f32 = 9.0;
/// The rings (fx.lisp +RING-N+, +RING-STRIDE+).
pub const RING_N: usize = 16;
pub const RING_STRIDE: usize = 13;

/// The FX state a match's frames keep (fx.lisp's pools, vfx.lisp's lights and auras, the stage's marks, stamps.lisp's stamps),
/// all preallocated: no frame allocates.
pub struct FxState<'d> {
    /// `*parts*`, `*pcursor*`, `*plive*`.
    pub parts: Vec<f32>,
    pub cursor: usize,
    pub live: usize,
    /// `*rings*`.
    pub rings: [f32; RING_N * RING_STRIDE],
    /// vfx.lisp `*flash-light*`: x y z r g b start (fx clock).
    pub flash: [f32; 8],
    /// The body auras (vfx.lisp / draw.lisp): `*aura-now*`, `*aura-was*` (a kit's :aura name or none), `*aura-t*`, `*oni-k*`,
    /// `*aura-cap*`.
    pub aura_now: [Option<&'d str>; 2],
    pub aura_was: [Option<&'d str>; 2],
    pub aura_t: [f32; 2],
    pub oni_k: [f32; 2],
    pub aura_cap: f32,
    /// The stage's cracks, marks and chips (stage.lisp).
    pub stage: crack::StageFx,
    /// The stamps (vfx-stamps.lisp).
    pub stamps: stamps::Stamps,
    /// cinema.lisp `*ui-flash*`: r g b alpha fade (the canvas draws it: task 8).
    pub ui_flash: [f32; 5],
    pub knobs: Knobs,
    pub ken: hazard::KenKnobs,
}

/// The FX knobs read from tuning.json (never retyped).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Knobs {
    /// tuning.lisp `*fire-density*`.
    pub fire_density: f32,
    /// vfx.lisp `*reiatsu-glass*`: :reiatsu :nozarashi :nomihose :oni :oni-ink.
    pub glass: [i64; 5],
    /// draw.lisp `*oni-k-attack*`.
    pub oni_k_attack: f32,
}

impl Knobs {
    pub fn new(d: &duel_data::Data) -> Knobs {
        let f = |k: &str| d.tuning[k].as_f64().unwrap_or_else(|| panic!("tuning {k}")) as f32;
        let g = d.tuning["*REIATSU-GLASS*"].as_array().expect("tuning *REIATSU-GLASS*");
        let glass_of = |name: &str| {
            let i = g.iter().position(|x| x.as_str() == Some(name)).unwrap_or_else(|| panic!("*REIATSU-GLASS* {name}"));
            g[i + 1].as_i64().unwrap()
        };
        Knobs {
            fire_density: f("*FIRE-DENSITY*"),
            glass: ["reiatsu", "nozarashi", "nomihose", "oni", "oni-ink"].map(glass_of),
            oni_k_attack: f("*ONI-K-ATTACK*"),
        }
    }
}

impl<'d> FxState<'d> {
    pub fn new(d: &duel_data::Data) -> FxState<'d> {
        FxState {
            parts: vec![0.0; PMAX * PSTRIDE],
            cursor: 0,
            live: 0,
            rings: [0.0; RING_N * RING_STRIDE],
            flash: [0.0; 8],
            aura_now: [None; 2],
            aura_was: [None; 2],
            aura_t: [0.0; 2],
            oni_k: [1.0; 2],
            aura_cap: 1.0,
            stage: crack::StageFx::default(),
            stamps: stamps::Stamps::default(),
            ui_flash: [0.0; 5],
            knobs: Knobs::new(d),
            ken: hazard::KenKnobs::new(d),
        }
    }
}

/// What a look draws with: the frame's arrays, the render camera, the cosmetic RNG, the FX state and the fx clock's seconds.
pub struct Ctx<'a, 'd> {
    pub out: &'a mut FrameOut,
    pub cam: &'a Camera,
    pub cos: &'a mut CosRng,
    pub fx: &'a mut FxState<'d>,
    pub clock: f32,
}

/// What a look that only starts things draws with (feedback's calls inside a step: stamps, particles, the hit light, the stage's
/// marks): the cosmetic RNG, the FX state and the fx clock. A frame's drawing reborrows one from its `Ctx` (`Ctx::em`).
pub struct Em<'a, 'd> {
    pub cos: &'a mut CosRng,
    pub fx: &'a mut FxState<'d>,
    pub clock: f32,
}

impl Em<'_, '_> {
    /// RND01.
    pub fn rnd(&mut self) -> f32 {
        self.cos.rnd01()
    }
    /// port: engine/lisp/package.lisp RND-RANGE: `(+ a (* (- b a) (rnd01)))`.
    pub fn rr(&mut self, a: f32, b: f32) -> f32 {
        a + (b - a) * self.cos.rnd01()
    }
}

impl<'d> Ctx<'_, 'd> {
    /// The starting half of this context.
    pub fn em(&mut self) -> Em<'_, 'd> {
        Em { cos: &mut *self.cos, fx: &mut *self.fx, clock: self.clock }
    }
    /// RND01.
    pub fn rnd(&mut self) -> f32 {
        self.cos.rnd01()
    }
    /// port: engine/lisp/package.lisp RND-RANGE: `(+ a (* (- b a) (rnd01)))`.
    pub fn rr(&mut self, a: f32, b: f32) -> f32 {
        a + (b - a) * self.cos.rnd01()
    }
    /// port: render.lisp WITH-FX-VERTS' reservation: the MODE batch when NV vertices fit (STREAM-ROOM-P), else `*fx-dropped*` + 1
    /// and nothing (the whole shape is dropped).
    pub fn verts(&mut self, mode: Mode, nv: usize) -> Option<&mut Vec<f32>> {
        let s = match mode {
            Mode::Alpha => &mut self.out.fxa,
            Mode::Add => &mut self.out.fxb,
            Mode::Toon => &mut self.out.ft,
        };
        if s.len() + 9 * nv <= FX_STREAM_FLOATS {
            Some(s)
        } else {
            self.out.fx_dropped += 1;
            None
        }
    }
    /// port: render.lisp ADD-POINT-LIGHT / ADD-POINT-LIGHT-V (%ADD-LIGHT), scored against the camera's target.
    #[allow(clippy::too_many_arguments)]
    pub fn light(&mut self, x: f32, y: f32, z: f32, r: f32, g: f32, b: f32, radius: f32, k: f32, prio: i32) {
        crate::draw::queue::add_point_light(self.out, self.cam.target, x, y, z, r, g, b, radius, k, prio);
    }
}

/// WITH-FX-VERTS' VTX.
#[inline]
#[allow(clippy::too_many_arguments)]
pub fn vtx(s: &mut Vec<f32>, x: f32, y: f32, z: f32, u: f32, v: f32, r: f32, g: f32, b: f32, a: f32) {
    s.extend_from_slice(&[x, y, z, u, v, r, g, b, a]);
}

/// port: fx-shapes.lisp %BB-VERTS — a camera-facing quad: half axes S (right) and U (up).
#[allow(clippy::too_many_arguments)]
pub fn bb_verts(s: &mut Vec<f32>, x: f32, y: f32, z: f32, sx: f32, sy: f32, sz: f32, ux: f32, uy: f32, uz: f32, r: f32, g: f32, b: f32, a: f32) {
    vtx(s, x - sx - ux, y - sy - uy, z - sz - uz, -1.0, -1.0, r, g, b, a);
    vtx(s, (x + sx) - ux, (y + sy) - uy, (z + sz) - uz, 1.0, -1.0, r, g, b, a);
    vtx(s, x + sx + ux, y + sy + uy, z + sz + uz, 1.0, 1.0, r, g, b, a);
    vtx(s, x - sx - ux, y - sy - uy, z - sz - uz, -1.0, -1.0, r, g, b, a);
    vtx(s, x + sx + ux, y + sy + uy, z + sz + uz, 1.0, 1.0, r, g, b, a);
    vtx(s, (x - sx) + ux, (y - sy) + uy, (z - sz) + uz, -1.0, 1.0, r, g, b, a);
}

// ---------------------------------------------------------------- particles

impl FxState<'_> {
    /// port: fx.lisp %FX-SLOT — the slot the next particle takes (a dead one near the cursor, else the oldest).
    fn slot(&mut self) -> usize {
        let (p, mut i, mut tries) = (&self.parts, self.cursor, 0);
        while tries < 64 && p[i * PSTRIDE + 6] > 0.0 {
            i += 1;
            tries += 1;
            if i >= PMAX {
                i = 0;
            }
        }
        let o = i * PSTRIDE;
        i += 1;
        if i >= PMAX {
            i = 0;
        }
        self.cursor = i;
        o
    }

    /// port: fx.lisp FX-EMIT with ALPHA 1 (%FX-PUT; the caller evaluates the arguments left to right, as the macro binds them).
    #[allow(clippy::too_many_arguments)]
    pub fn emit(&mut self, ty: f32, x: f32, y: f32, z: f32, vx: f32, vy: f32, vz: f32, life: f32, size: f32, grav: f32, r: f32, g: f32, b: f32) {
        self.emit_a(ty, x, y, z, vx, vy, vz, life, size, grav, r, g, b, 1.0);
    }
    /// port: fx.lisp FX-EMIT with its optional ALPHA.
    #[allow(clippy::too_many_arguments)]
    pub fn emit_a(&mut self, ty: f32, x: f32, y: f32, z: f32, vx: f32, vy: f32, vz: f32, life: f32, size: f32, grav: f32, r: f32, g: f32, b: f32, alpha: f32) {
        let o = self.slot();
        self.parts[o..o + PSTRIDE].copy_from_slice(&[x, y, z, vx, vy, vz, life, life, size, grav, r, g, b, ty, alpha]);
    }

    /// port: fx.lisp FX-UPDATE (DT effect seconds). ponytail: no orb is ever emitted in SOUL DUEL (`*orb-target*` stays 0,
    /// `*on-orb-absorbed*` NIL), so the homing reads a zero target and calls no hook, as the Lisp would.
    pub fn update(&mut self, dt: f32) {
        let (p, tg) = (&mut self.parts, [0.0f32; 3]);
        let mut live = 0;
        for i in 0..PMAX {
            let o = i * PSTRIDE;
            let life = p[o + 6];
            if life > 0.0 {
                live += 1;
                let ty = p[o + 13];
                let nl = life - dt;
                p[o + 6] = nl;
                if ty == P_ORB_A || ty == P_ORB_B {
                    let age = p[o + 7] - nl;
                    let (dx, dy, dz) = (tg[0] - p[o], tg[1] - p[o + 1], tg[2] - p[o + 2]);
                    let d = duel_sim::math::f_sqrt(dx * dx + dy * dy + dz * dz);
                    if age > 0.4 && d < 0.6 {
                        p[o + 6] = 0.0;
                    } else if age > 0.4 && d < 8.0 {
                        let k = 12.0 / f_max(d, 0.01);
                        (p[o + 3], p[o + 4], p[o + 5]) = (dx * k, dy * k, dz * k);
                    } else {
                        let dr = f_max(0.0, 1.0 - 3.0 * dt);
                        (p[o + 3], p[o + 4], p[o + 5]) = (dr * p[o + 3], dr * p[o + 4] - 2.0 * dt, dr * p[o + 5]);
                    }
                } else {
                    let drag = if ty == P_MIST || ty == P_DUST || ty == P_FEATHER {
                        f_max(0.0, 1.0 - 3.5 * dt)
                    } else if ty == P_FLAME {
                        f_max(0.0, 1.0 - 1.5 * dt)
                    } else {
                        1.0
                    };
                    p[o + 3] *= drag;
                    p[o + 4] = drag * p[o + 4] - p[o + 9] * dt;
                    p[o + 5] *= drag;
                }
                p[o] += dt * p[o + 3];
                p[o + 1] += dt * p[o + 4];
                p[o + 2] += dt * p[o + 5];
                if p[o + 1] < 0.03 {
                    (p[o + 1], p[o + 4]) = (0.03, -0.3 * p[o + 4]);
                    (p[o + 3], p[o + 5]) = (0.6 * p[o + 3], 0.6 * p[o + 5]);
                }
            }
        }
        self.live = live;
    }

    /// port: fx.lisp FX-CLEAR (the particles and rings; the shake is the camera's: the caller clears it).
    pub fn clear(&mut self) {
        for i in 0..PMAX {
            self.parts[i * PSTRIDE + 6] = 0.0;
        }
        for i in 0..RING_N {
            self.rings[i * RING_STRIDE + 6] = 0.0;
        }
        self.live = 0;
    }

    /// port: fx.lisp FX-RING (PALETTE: a toon ring's palette, or none).
    #[allow(clippy::too_many_arguments)]
    pub fn ring(&mut self, x: f32, y: f32, z: f32, r0: f32, r1: f32, dur: f32, r: f32, g: f32, b: f32, flat: bool, width: f32, palette: Option<f32>) {
        let s = &mut self.rings;
        let (mut best, mut ba) = (0, -1.0f32);
        for i in 0..RING_N {
            let rem = s[i * RING_STRIDE + 6] - s[i * RING_STRIDE + 5];
            if ba < 0.0 || rem < ba {
                (ba, best) = (rem, i);
            }
        }
        let o = best * RING_STRIDE;
        s[o..o + RING_STRIDE].copy_from_slice(&[x, y, z, r0, r1, 0.0, dur, r, g, b, if flat { 1.0 } else { 0.0 }, width, palette.unwrap_or(-1.0)]);
    }
}

/// port: engine/lisp/fx.lisp %MATTER-PAL-P — palettes 6 7 8 11 draw on threes.
fn matter_pal_p(p: f32) -> bool {
    p == 6.0 || p == 7.0 || p == 8.0 || p == 11.0
}

/// port: fx.lisp FX-DRAW-PARTICLES — every live particle into its batch.
pub fn draw_particles(c: &mut Ctx) {
    let (rt, up, eye) = (c.cam.right, c.cam.upv, c.cam.eye);
    let (rx, ry, rz, ux, uy, uz) = (rt[0], rt[1], rt[2], up[0], up[1], up[2]);
    for i in 0..PMAX {
        let o = i * PSTRIDE;
        let p = &c.fx.parts[o..o + PSTRIDE];
        let life = p[6];
        if life <= 0.0 {
            continue;
        }
        let pp: [f32; PSTRIDE] = p.try_into().unwrap();
        let (ty, u, s, x, y, z) = (pp[13], life / pp[7], pp[8], pp[0], pp[1], pp[2]);
        let (r, g, b, ka) = (pp[10], pp[11], pp[12], pp[14]);
        if ty >= P_T_BLOB {
            let pal = ka;
            let rate = if matter_pal_p(pal) { 3.0 } else { 2.0 };
            let age = pp[7] - life;
            let since = f_mod(c.clock, rate / 24.0);
            let lag = f_min(age, since);
            let u = f_min(1.0, (life + lag) / pp[7]);
            let (vx, vy, vz) = (pp[3], pp[4], pp[5]);
            let (x, y, z) = (x - lag * vx, y - lag * vy, z - lag * vz);
            let seed = 40.0 * shapes::h01(i as f32, 0.618);
            let (k, wob) = (0.12 + 0.86 * u, r);
            if age < since {
                continue;
            }
            if ty == P_T_BLOB {
                let sz = s * if matter_pal_p(pal) { 1.0 + 0.8 * (1.0 - u) } else { 0.4 + 0.6 * u };
                let (x, y, z, sc) = shapes::toward_eye(c.cam, x, y, z, 0.8 * sz);
                let sz = sz * sc;
                let (sx, sy, sz2, vx, vy, vz) = (sz * rx, sz * ry, sz * rz, sz * ux, sz * uy, sz * uz);
                let a = shapes::toon_a(pal, k);
                if let Some(v) = c.verts(Mode::Toon, 6) {
                    bb_verts(v, x, y, z, sx, sy, sz2, vx, vy, vz, 1.0, seed, wob, a);
                }
            } else {
                let l = f_hypot3(vx, vy, vz);
                if l > 1e-3 {
                    shapes::fx_shard(c, x, y, z, vx / l, vy / l, vz / l, s, 0.3 * s, wob, seed, pal, k, 0.1);
                } else {
                    shapes::fx_shard(c, x, y, z, rx, ry, rz, s, 0.3 * s, wob, seed, pal, k, 0.1);
                }
            }
        } else if ty == P_SPARK {
            let (vx, vy, vz) = (pp[3], pp[4], pp[5]);
            let (x1, y1, z1) = (x - 0.035 * vx, y - 0.035 * vy, z - 0.035 * vz);
            let (dx, dy, dz) = (x1 - x, y1 - y, z1 - z);
            let (ex, ey, ez) = (eye[0] - x, eye[1] - y, eye[2] - z);
            let (mut cx, mut cy, mut cz) = (dy * ez - dz * ey, dz * ex - dx * ez, dx * ey - dy * ex);
            let (cl, w) = (f_hypot3(cx, cy, cz), s * u);
            if cl > 1e-6 {
                (cx, cy, cz) = (w * (cx / cl), w * (cy / cl), w * (cz / cl));
                if let Some(v) = c.verts(Mode::Add, 3) {
                    vtx(v, x - cx, y - cy, z - cz, 0.0, -1.0, r, g, b, ka * u);
                    vtx(v, x + cx, y + cy, z + cz, 0.0, 1.0, r, g, b, ka * u);
                    vtx(v, x1, y1, z1, 0.0, 0.0, r, g, b, 0.0);
                }
            }
        } else if ty == P_MIST || ty == P_DUST {
            let sz = s * (1.0 + 1.2 * (1.0 - u));
            let a = ka * ((if ty == P_MIST { 0.85 } else { 0.45 }) * u);
            let k = if ty == P_MIST { 0.5 + 0.5 * u } else { 1.0 };
            if let Some(v) = c.verts(Mode::Alpha, 6) {
                bb_verts(v, x, y, z, sz * rx, sz * ry, sz * rz, sz * ux, sz * uy, sz * uz, k * r, k * g, k * b, a);
            }
        } else if ty == P_FEATHER {
            let a = ka * (0.9 * u);
            if let Some(v) = c.verts(Mode::Alpha, 6) {
                bb_verts(v, x, y, z, s * rx * 0.45, s * ry * 0.45, s * rz * 0.45, s * ux, s * uy, s * uz, r, g, b, a);
            }
        } else if ty == P_FLAME {
            let age = 1.0 - u;
            let k1 = f_min(1.0, 5.0 * age);
            let k2 = f_min(f_max(2.857 * (age - 0.2), 0.0), 1.0);
            let (mut cr, mut cg, mut cb) = (r + (1.0 - r) * k1, g + (0.42 - g) * k1, b + (0.06 - b) * k1);
            let a = ka * if age < 0.1 { 0.8 * u } else { -0.8 * u };
            let sz = s * (0.3 + 0.7 * u);
            (cr, cg, cb) = (cr + (0.45 - cr) * k2, cg + (0.05 - cg) * k2, cb + (0.02 - cb) * k2);
            if let Some(v) = c.verts(Mode::Add, 6) {
                bb_verts(v, x, y, z, sz * rx, sz * ry, sz * rz, sz * ux, sz * uy, sz * uz, cr, cg, cb, a);
            }
        } else {
            let fl = if ty > 4.5 { u } else { 1.0 };
            let a = ka * if life < 0.5 { 2.0 * life } else { 1.0 };
            let sz = s * fl;
            if let Some(v) = c.verts(Mode::Add, 6) {
                bb_verts(v, x, y, z, sz * rx, sz * ry, sz * rz, sz * ux, sz * uy, sz * uz, r, g, b, a);
            }
        }
    }
}

/// port: engine/lisp/package.lisp F-HYPOT of three singles: F-SQRT of the sum in order.
pub fn f_hypot3(a: f32, b: f32, c: f32) -> f32 {
    duel_sim::math::f_sqrt(a * a + b * b + c * c)
}

/// port: fx.lisp FX-RINGS-UPDATE (DT effect seconds).
pub fn rings_update(c: &mut Ctx, dt: f32) {
    let (rt, up) = (c.cam.right, c.cam.upv);
    for i in 0..RING_N {
        let o = i * RING_STRIDE;
        let s = c.fx.rings;
        let (age, dur) = (s[o + 5], s[o + 6]);
        if age >= dur {
            continue;
        }
        c.fx.rings[o + 5] = age + dt;
        let u = age / dur;
        let rad = s[o + 3] + u * (s[o + 4] - s[o + 3]);
        let (mut a, w, flat) = (1.0 - u, s[o + 11], s[o + 10] > 0.5);
        let (x, mut y, z) = (s[o], s[o + 1], s[o + 2]);
        let (mut r, mut g, mut b, pal) = (s[o + 7], s[o + 8], s[o + 9], s[o + 12]);
        if pal >= 0.0 {
            (r, g, b, a, y) = (1.0, 1.0 + i as f32, 0.12, shapes::toon_a(pal, 0.98 * (1.0 - u * u)), y + 0.02);
        }
        let mode = if pal >= 0.0 { Mode::Toon } else { Mode::Add };
        let pt = |cs: f32, sn: f32, rr: f32| -> (f32, f32, f32) {
            if flat {
                (x + rr * cs, y + 0.03, z + rr * sn)
            } else {
                (x + rr * (cs * rt[0] + sn * up[0]), y + rr * (cs * rt[1] + sn * up[1]), z + rr * (cs * rt[2] + sn * up[2]))
            }
        };
        let Some(v) = c.verts(mode, 6 * 24) else { continue };
        for k in 0..24 {
            let a0 = k as f32 * 0.2618;
            let a1 = a0 + 0.2618;
            let (c0, s0, c1, s1) = (duel_sim::math::f_cos(a0), duel_sim::math::f_sin(a0), duel_sim::math::f_cos(a1), duel_sim::math::f_sin(a1));
            let (ri, ro) = (rad - w, rad + w);
            let (x0, y0, z0) = pt(c0, s0, ri);
            let (x1, y1, z1) = pt(c0, s0, ro);
            let (x2, y2, z2) = pt(c1, s1, ro);
            let (x3, y3, z3) = pt(c1, s1, ri);
            let (vi, vo) = if pal >= 0.0 { (-1.0, 1.0) } else { (1.0, 0.0) };
            vtx(v, x0, y0, z0, 0.0, vi, r, g, b, a);
            vtx(v, x1, y1, z1, 0.0, vo, r, g, b, a);
            vtx(v, x2, y2, z2, 0.0, vo, r, g, b, a);
            vtx(v, x0, y0, z0, 0.0, vi, r, g, b, a);
            vtx(v, x2, y2, z2, 0.0, vo, r, g, b, a);
            vtx(v, x3, y3, z3, 0.0, vi, r, g, b, a);
        }
    }
}

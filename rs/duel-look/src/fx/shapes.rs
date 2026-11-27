//! port: engine/lisp/fx-shapes.lisp — the stateless toon kit: the clock's drawings and flow, TOON-A, the sine hashes, the toon
//! shapes (%TRING, TOON-RIBBON / FX-RIBBON, %TONGUE, TOON-GROUND-SEG, %SECTOR-VERTS, FX-STAR, FX-SHARD, FX-CRESCENT, FX-DISC, FX-WALL)
//! and render.lisp's FX-BILLBOARD / FX-LINE / FX-DECAL. Every shape writes one fx batch through `Ctx::verts` (dropped whole when full).
use super::{bb_verts, f_hypot3, vtx, Ctx, Mode};
use crate::draw::camera::Camera;
use duel_sim::math::{f_abs, f_cos, f_hypot, f_max, f_min, f_mod, f_sin, f_sqrt};

/// Palettes (fx-shapes.lisp +PAL-...+) and the flame flag.
pub const PAL_FIRE: f32 = 0.0;
pub const PAL_EMBER: f32 = 1.0;
pub const PAL_REIATSU: f32 = 2.0;
pub const PAL_INK: f32 = 3.0;
pub const PAL_STEEL: f32 = 4.0;
pub const PAL_HIT: f32 = 5.0;
pub const PAL_SMOKE: f32 = 6.0;
pub const PAL_DUST: f32 = 7.0;
pub const PAL_ASH: f32 = 8.0;
pub const PAL_SOUL: f32 = 9.0;
pub const PAL_BLOOD: f32 = 10.0;
pub const PAL_BLACK_SMOKE: f32 = 11.0;
pub const PAL_BLUE: f32 = 12.0;
pub const PAL_GOLD: f32 = 14.0;
pub const PAL_FLAME: f32 = 15.0;
pub const TOON_FLAME: f32 = 128.0;

/// port: engine/lisp/package.lisp F-CLAMP: `(f-min (f-max x lo) hi)`.
pub fn f_clamp(x: f32, lo: f32, hi: f32) -> f32 {
    f_min(f_max(x, lo), hi)
}
/// port: engine/lisp/package.lisp (I->F (F->I x)): `(float)(int)floorf(x)`.
pub fn ffloor(x: f32) -> f32 {
    duel_sim::cl::floor_f32(x) as i32 as f32
}
/// port: engine/lisp/fx-shapes.lisp TOON-A — palette P + presence K clamped to 0.01..0.98.
pub fn toon_a(p: f32, k: f32) -> f32 {
    p + f_clamp(k, 0.01, 0.98)
}
/// port: engine/lisp/fx-shapes.lisp TOON-A with FAN T (the fan-shape flag 16).
pub fn toon_a_fan(p: f32, k: f32) -> f32 {
    (16.0 + p) + f_clamp(k, 0.01, 0.98)
}
/// port: engine/lisp/fx-shapes.lisp %H01 — v - floor(v) of the sine hash.
pub fn h01(i: f32, seed: f32) -> f32 {
    let v = 43758.547 * f_sin(i * 12.9898 + seed * 78.233);
    v - ffloor(v)
}
/// port: engine/lisp/fx-shapes.lisp HASH01 — |v| mod 1 of the sine hash.
pub fn hash01(i: f32, seed: f32) -> f32 {
    f_mod(f_abs(43758.547 * f_sin(i * 12.9898 + seed * 78.233)), 1.0)
}
/// port: engine/lisp/fx-shapes.lisp DRAWING-NO — the fx clock's drawing number (0..63) at PER-SECOND drawings.
pub fn drawing_no(clock: f32, per_second: f32) -> f32 {
    ((duel_sim::cl::floor_f32(per_second * clock) as i32) & 63) as f32
}
/// port: engine/lisp/fx-shapes.lisp FLOW-PH (12 radians a second, wrapped to 20 pi).
pub fn flow_ph(clock: f32) -> f32 {
    f_mod(12.0 * clock, 62.831852)
}
/// port: engine/lisp/fx-shapes.lisp FLOW01 at its default 6 keys a second.
pub fn flow01(clock: f32, i: f32, seed: f32) -> f32 {
    let tt = f_mod(6.0 * clock, 64.0);
    let n = ffloor(tt);
    let u = tt - n;
    let a = hash01(i + n, seed);
    let b = hash01(i + if n >= 63.0 { 0.0 } else { n + 1.0 }, seed);
    a + u * u * (3.0 - 2.0 * u) * (b - a)
}
/// port: engine/lisp/fx-shapes.lisp SAGE — AGE quantised to the clock's drawings of RATE ticks.
pub fn sage(clock: f32, age: f32, rate: f32) -> f32 {
    f_max(0.0, age - f_mod(clock, rate / 24.0))
}
/// port: engine/lisp/fx-shapes.lisp %TOWARD-EYE — (x y z) moved PUSH m toward the eye (at most half way) and the size factor keeping the screen size.
pub fn toward_eye(cam: &Camera, x: f32, y: f32, z: f32, push: f32) -> (f32, f32, f32, f32) {
    let e = cam.eye;
    let (dx, dy, dz) = (e[0] - x, e[1] - y, e[2] - z);
    let d = f_max(1e-3, f_hypot3(dx, dy, dz));
    let p = f_min(push, 0.5 * d);
    (x + p * (dx / d), y + p * (dy / d), z + p * (dz / d), (d - p) / d)
}

/// port: engine/lisp/fx-shapes.lisp %TRING — a flat toon ring on the ground at Y (+2 cm), radius R, band half-width W, SEGS segments.
#[allow(clippy::too_many_arguments)]
pub fn tring(c: &mut Ctx, x: f32, y: f32, z: f32, r: f32, w: f32, pal: f32, k: f32, seed: f32, segs: usize) {
    let (cx, cy, cz, ri, ro, pk) = (x, y + 0.02, z, f_max(0.0, r - w), r + w, toon_a(pal, k));
    let (sd, da) = (-1.0 - seed, 6.2831855 / segs as f32);
    let Some(v) = c.verts(Mode::Toon, 6 * segs) else { return };
    for i in 0..segs {
        let a0 = da * i as f32;
        let a1 = a0 + da;
        let (c0, s0, c1, s1) = (f_cos(a0), f_sin(a0), f_cos(a1), f_sin(a1));
        let h0 = 0.3 + 0.7 * f_abs(f_sin(2.5 * a0 + sd));
        let h1 = 0.3 + 0.7 * f_abs(f_sin(2.5 * a1 + sd));
        vtx(v, cx + ri * c0, cy, cz + ri * s0, -1.0, 0.0, h0, sd, 0.12, pk);
        vtx(v, cx + ro * c0, cy, cz + ro * s0, 1.0, 0.0, h0, sd, 0.12, pk);
        vtx(v, cx + ro * c1, cy, cz + ro * s1, 1.0, 0.0, h1, sd, 0.12, pk);
        vtx(v, cx + ri * c0, cy, cz + ri * s0, -1.0, 0.0, h0, sd, 0.12, pk);
        vtx(v, cx + ro * c1, cy, cz + ro * s1, 1.0, 0.0, h1, sd, 0.12, pk);
        vtx(v, cx + ri * c1, cy, cz + ri * s1, -1.0, 0.0, h1, sd, 0.12, pk);
    }
}

/// FX-RIBBON's arguments (`*ribbon-args*`): base, axis, widths, the base and tip colour lanes, phase, sway, bend.
#[derive(Clone, Copy, Debug)]
pub struct Ribbon {
    pub p: [f32; 3],
    pub a: [f32; 3],
    pub w0: f32,
    pub w1: f32,
    pub c0: [f32; 4],
    pub c1: [f32; 4],
    pub ph: f32,
    pub sway: f32,
    pub bend: [f32; 3],
}

/// port: fx-shapes.lisp %FX-RIBBON — SEGS segments into the MODE batch.
pub fn fx_ribbon(c: &mut Ctx, rb: &Ribbon, segs: usize, mode: Mode) {
    let (eye, rt) = (c.cam.eye, c.cam.right);
    let ([x, y, z], [ax, ay, az]) = (rb.p, rb.a);
    let l = f_hypot3(ax, ay, az);
    if l <= 1e-4 {
        return;
    }
    let (nx, ny, nz) = (ax / l, ay / l, az / l);
    let (ex, ey, ez) = (eye[0] - x, eye[1] - y, eye[2] - z);
    let (mut sx, mut sy, mut sz) = (ny * ez - nz * ey, nz * ex - nx * ez, nx * ey - ny * ex);
    let sl = f_hypot3(sx, sy, sz);
    let (w0, w1, ph, sw, [bx, by, bz]) = (rb.w0, rb.w1, rb.ph, rb.sway, rb.bend);
    let inv = 1.0 / segs as f32;
    if sl < 1e-5 {
        (sx, sy, sz) = (rt[0], rt[1], rt[2]);
    } else {
        (sx, sy, sz) = (sx / sl, sy / sl, sz / sl);
    }
    let Some(v) = c.verts(mode, 6 * segs) else { return };
    let (mut l3, mut q3, mut pc) = ([0.0f32; 3], [0.0f32; 3], [0.0f32; 4]);
    for i in 0..=segs {
        let u = i as f32 * inv;
        let off = sw * u * (f_sin(ph + 5.0 * u) + 0.5 * f_sin(1.7 * ph + 11.0 * u));
        let w = (w0 + (w1 - w0) * u) * (1.0 + 0.14 * f_sin(2.3 * ph + 9.0 * u));
        let cx = x + ax * u + sx * off + bx * u * u;
        let cy = y + ay * u + sy * off + by * u * u;
        let cz = z + az * u + sz * off + bz * u * u;
        let col = [0, 1, 2, 3].map(|j| rb.c0[j] + u * (rb.c1[j] - rb.c0[j]));
        let m3 = [cx - sx * w, cy - sy * w, cz - sz * w];
        let k3 = [cx + sx * w, cy + sy * w, cz + sz * w];
        if i > 0 {
            let [r, g, b, a] = col;
            let [pr, pg, pb, pa] = pc;
            vtx(v, l3[0], l3[1], l3[2], -1.0, 0.0, pr, pg, pb, pa);
            vtx(v, q3[0], q3[1], q3[2], 1.0, 0.0, pr, pg, pb, pa);
            vtx(v, k3[0], k3[1], k3[2], 1.0, 0.0, r, g, b, a);
            vtx(v, l3[0], l3[1], l3[2], -1.0, 0.0, pr, pg, pb, pa);
            vtx(v, k3[0], k3[1], k3[2], 1.0, 0.0, r, g, b, a);
            vtx(v, m3[0], m3[1], m3[2], -1.0, 0.0, r, g, b, a);
        }
        (l3, q3, pc) = (m3, k3, col);
    }
}

/// TOON-RIBBON's keywords besides the base, axis and widths.
#[derive(Clone, Copy, Debug)]
pub struct Toon {
    pub heat: [f32; 2],
    pub seed: f32,
    pub wob: f32,
    /// The presence lanes at the base and the tip (already TOON-A'd).
    pub k0: f32,
    pub k1: f32,
    pub ph: f32,
    pub sway: f32,
    pub segs: usize,
    pub bend: [f32; 3],
}

impl Toon {
    /// TOON-RIBBON's defaults: heat (1 0.2), wob 0.3, ph 0, sway 0, 6 segments, no bend; K both ends.
    pub fn new(seed: f32, k: f32) -> Toon {
        Toon { heat: [1.0, 0.2], seed, wob: 0.3, k0: k, k1: k, ph: 0.0, sway: 0.0, segs: 6, bend: [0.0; 3] }
    }
}

/// port: fx-shapes.lisp TOON-RIBBON — FX-RIBBON :mode :toon with its colour lanes named.
pub fn toon_ribbon(c: &mut Ctx, p: [f32; 3], a: [f32; 3], w0: f32, w1: f32, t: &Toon) {
    let rb = Ribbon {
        p,
        a,
        w0,
        w1,
        c0: [t.heat[0], t.seed, t.wob, t.k0],
        c1: [t.heat[1], t.seed, t.wob, t.k1],
        ph: t.ph,
        sway: t.sway,
        bend: t.bend,
    };
    fx_ribbon(c, &rb, t.segs, Mode::Toon);
}

/// port: fx-shapes.lisp %TONGUE — one toon flame tongue (w1 0; the seed made negative: along).
#[allow(clippy::too_many_arguments)]
pub fn tongue(c: &mut Ctx, p: [f32; 3], a: [f32; 3], w: f32, pal: f32, k: f32, seed: f32, ph: f32, sway: f32, segs: usize, wob: f32) {
    let (sd, pk) = (-1.0 - f_abs(seed), toon_a(pal, k));
    toon_ribbon(c, p, a, w, 0.0, &Toon { wob, ph, sway, segs, ..Toon::new(sd, pk) });
}

/// port: fx-shapes.lisp TOON-GROUND-SEG — a flat toon strip on the ground from (x0 z0) to (x1 z1) at height Y.
#[allow(clippy::too_many_arguments)]
pub fn ground_seg(c: &mut Ctx, x0: f32, z0: f32, x1: f32, z1: f32, gy: f32, w: f32, h0: f32, h1: f32, seed: f32, wb: f32, pk: f32) {
    let sd = -1.0 - f_abs(seed);
    let (dx, dz) = (x1 - x0, z1 - z0);
    let l = f_hypot(dx, dz);
    if l <= 1e-4 {
        return;
    }
    let (nx, nz) = (w * (-dz / l), w * (dx / l));
    let Some(v) = c.verts(Mode::Toon, 6) else { return };
    vtx(v, x0 - nx, gy, z0 - nz, -1.0, 0.0, h0, sd, wb, pk);
    vtx(v, x0 + nx, gy, z0 + nz, 1.0, 0.0, h0, sd, wb, pk);
    vtx(v, x1 + nx, gy, z1 + nz, 1.0, 0.0, h1, sd, wb, pk);
    vtx(v, x0 - nx, gy, z0 - nz, -1.0, 0.0, h0, sd, wb, pk);
    vtx(v, x1 + nx, gy, z1 + nz, 1.0, 0.0, h1, sd, wb, pk);
    vtx(v, x1 - nx, gy, z1 - nz, -1.0, 0.0, h1, sd, wb, pk);
}

/// port: fx-shapes.lisp %SECTOR-VERTS — a flat sector at Y (+3 cm) between R0 and R1 about YAW, +-HALF, SEGS segments; L = the four
/// colour lanes.
#[allow(clippy::too_many_arguments)]
pub fn sector_verts(c: &mut Ctx, mode: Mode, segs: usize, x: f32, y: f32, z: f32, r0: f32, r1: f32, yaw: f32, half: f32, l: [f32; 4]) {
    let (cx, cy, cz, a0, da) = (x, y + 0.03, z, yaw - half, (2.0 * half) / segs as f32);
    let [ht, sd, wb, pk] = l;
    let Some(v) = c.verts(mode, 6 * segs) else { return };
    for k in 0..segs {
        let t0 = a0 + da * k as f32;
        let t1 = t0 + da;
        let (c0, s0, c1, s1) = (-f_sin(t0), -f_cos(t0), -f_sin(t1), -f_cos(t1));
        vtx(v, cx + r0 * c0, cy, cz + r0 * s0, 0.0, -1.0, ht, sd, wb, pk);
        vtx(v, cx + r1 * c0, cy, cz + r1 * s0, 0.0, 1.0, ht, sd, wb, pk);
        vtx(v, cx + r1 * c1, cy, cz + r1 * s1, 0.0, 1.0, ht, sd, wb, pk);
        vtx(v, cx + r0 * c0, cy, cz + r0 * s0, 0.0, -1.0, ht, sd, wb, pk);
        vtx(v, cx + r1 * c1, cy, cz + r1 * s1, 0.0, 1.0, ht, sd, wb, pk);
        vtx(v, cx + r0 * c1, cy, cz + r0 * s1, 0.0, -1.0, ht, sd, wb, pk);
    }
}

/// port: fx-shapes.lisp FX-STAR (%FX-STAR).
#[allow(clippy::too_many_arguments)]
pub fn fx_star(c: &mut Ctx, x: f32, y: f32, z: f32, r0: f32, r1: f32, n: usize, rot: f32, dx: f32, dy: f32, wob: f32, seed: f32, pal: f32, k: f32, push: f32) {
    let (pk, rt, up) = (toon_a_fan(pal, k), c.cam.right, c.cam.upv);
    let n = n.max(3);
    let m = 2 * n;
    let (dl, poly) = (f_hypot(dx, dy), r0 >= r1);
    let (step, near) = (6.2831855 / m as f32, f_cos(3.1415927 / n as f32));
    let (x, y, z, sc) = toward_eye(c.cam, x, y, z, push);
    let (r0, r1) = (r0 * sc, r1 * sc);
    let Some(v) = c.verts(Mode::Toon, 3 * m) else { return };
    let (mut px, mut py, mut pz, mut pu, mut pv) = (0.0f32, 0.0f32, 0.0f32, 0.0f32, 0.0f32);
    for j in 0..=m {
        let jj = if j == m { 0 } else { j };
        let (jf, tip) = (jj as f32, jj % 2 == 0);
        let ang = rot + step * jf + if poly { 0.0 } else { 0.42 * (h01(jf, seed) - 0.5) };
        let (ca, sa) = (f_cos(ang), f_sin(ang));
        let dir = if dl > 1e-4 { (ca * dx + sa * dy) / dl } else { 0.0 };
        let len = if poly {
            if tip { r1 } else { r1 * near }
        } else if tip {
            r1 * (0.5 + 0.9 * h01(jf + 7.1, seed))
                * if dir > near {
                    1.7
                } else if dir < -near && h01(3.3, seed) > 0.5 {
                    1.25
                } else {
                    1.0
                }
        } else {
            r0 * (0.75 + 0.5 * h01(jf + 3.3, seed))
        };
        let ox = len * (ca * rt[0] + sa * up[0]);
        let oy = len * (ca * rt[1] + sa * up[1]);
        let oz = len * (ca * rt[2] + sa * up[2]);
        let (wx, wy, wz) = (x + ox, y + oy, z + oz);
        if j > 0 {
            vtx(v, x, y, z, 0.0, 0.0, 0.0, seed, wob, pk);
            vtx(v, px, py, pz, pu, pv, 1.0, seed, wob, pk);
            vtx(v, wx, wy, wz, ca, sa, 1.0, seed, wob, pk);
        }
        (px, py, pz, pu, pv) = (wx, wy, wz, ca, sa);
    }
}

/// port: fx-shapes.lisp FX-SHARD (%FX-SHARD).
#[allow(clippy::too_many_arguments)]
pub fn fx_shard(c: &mut Ctx, x: f32, y: f32, z: f32, dx: f32, dy: f32, dz: f32, len: f32, w: f32, wob: f32, seed: f32, pal: f32, k: f32, push: f32) {
    let pk = toon_a_fan(pal, k);
    let (x, y, z, sc) = toward_eye(c.cam, x, y, z, push);
    let e = c.cam.eye;
    let (ex, ey, ez) = (e[0] - x, e[1] - y, e[2] - z);
    let (sx, sy, sz) = (dy * ez - dz * ey, dz * ex - dx * ez, dx * ey - dy * ex);
    let sl = f_max(1e-5, f_hypot3(sx, sy, sz));
    let (len, w) = (len * sc, (w * sc) / sl);
    let (f, b) = (0.6 * len, 0.4 * len);
    let (tx, ty, tz) = (x + f * dx, y + f * dy, z + f * dz);
    let (bx, by, bz) = (x - b * dx, y - b * dy, z - b * dz);
    let (lx, ly, lz) = (x + w * sx, y + w * sy, z + w * sz);
    let (rx, ry, rz) = (x - w * sx, y - w * sy, z - w * sz);
    let Some(v) = c.verts(Mode::Toon, 12) else { return };
    for [(ax, ay, az, au, av), (bx2, by2, bz2, bu, bv)] in [
        [(tx, ty, tz, 0.0, 1.0), (lx, ly, lz, -1.0, 0.0)],
        [(lx, ly, lz, -1.0, 0.0), (bx, by, bz, 0.0, -1.0)],
        [(bx, by, bz, 0.0, -1.0), (rx, ry, rz, 1.0, 0.0)],
        [(rx, ry, rz, 1.0, 0.0), (tx, ty, tz, 0.0, 1.0)],
    ] {
        vtx(v, x, y, z, 0.0, 0.0, 0.0, seed, wob, pk);
        vtx(v, ax, ay, az, au, av, 1.0, seed, wob, pk);
        vtx(v, bx2, by2, bz2, bu, bv, 1.0, seed, wob, pk);
    }
}

/// port: fx-shapes.lisp FX-CRESCENT (%FX-CRESCENT): COMET 1 the comet profile, else the lens.
#[allow(clippy::too_many_arguments)]
pub fn fx_crescent(c: &mut Ctx, p0: [f32; 3], p1: [f32; 3], bc: [f32; 3], w: f32, comet: bool, wob: f32, seed: f32, pal: f32, kk: f32, push: f32) {
    let ([x0, y0, z0], [x1, y1, z1], [bx, by, bz]) = (p0, p1, bc);
    let (seed, pk, e) = (-1.0 - f_abs(seed), toon_a(pal, kk), c.cam.eye);
    let Some(v) = c.verts(Mode::Toon, 48) else { return };
    let (mut l3, mut r3, mut lh) = ([0.0f32; 3], [0.0f32; 3], 0.0f32);
    for i in 0..9 {
        let u = 0.125 * i as f32;
        let vv = 1.0 - u;
        let px = vv * vv * x0 + 2.0 * u * vv * bx + u * u * x1;
        let py = vv * vv * y0 + 2.0 * u * vv * by + u * u * y1;
        let pz = vv * vv * z0 + 2.0 * u * vv * bz + u * u * z1;
        let tx = 2.0 * vv * (bx - x0) + 2.0 * u * (x1 - bx);
        let ty = 2.0 * vv * (by - y0) + 2.0 * u * (y1 - by);
        let tz = 2.0 * vv * (bz - z0) + 2.0 * u * (z1 - bz);
        let (ex, ey, ez) = (e[0] - px, e[1] - py, e[2] - pz);
        let el = f_max(1e-3, f_hypot3(ex, ey, ez));
        let pp = f_min(push, 0.5 * el);
        let (px, py, pz) = (px + pp * (ex / el), py + pp * (ey / el), pz + pp * (ez / el));
        let (sx, sy, sz) = (ty * ez - tz * ey, tz * ex - tx * ez, tx * ey - ty * ex);
        let sl = f_max(1e-6, f_hypot3(sx, sy, sz));
        let hw = if comet { w * duel_sim::cl::musl_powf(u, 0.4) * duel_sim::cl::musl_powf(f_max(vv, 0.0), 0.15) } else { w * f_sin(3.1415927 * u) };
        let hw = (hw * ((el - pp) / el)) / sl;
        let heat = 0.2 + 0.8 * u;
        let m3 = [px - hw * sx, py - hw * sy, pz - hw * sz];
        let n3 = [px + hw * sx, py + hw * sy, pz + hw * sz];
        if i > 0 {
            vtx(v, l3[0], l3[1], l3[2], -1.0, 0.0, lh, seed, wob, pk);
            vtx(v, r3[0], r3[1], r3[2], 1.0, 0.0, lh, seed, wob, pk);
            vtx(v, n3[0], n3[1], n3[2], 1.0, 0.0, heat, seed, wob, pk);
            vtx(v, l3[0], l3[1], l3[2], -1.0, 0.0, lh, seed, wob, pk);
            vtx(v, n3[0], n3[1], n3[2], 1.0, 0.0, heat, seed, wob, pk);
            vtx(v, m3[0], m3[1], m3[2], -1.0, 0.0, heat, seed, wob, pk);
        }
        (l3, r3, lh) = (m3, n3, heat);
    }
}

/// port: fx-shapes.lisp FX-DISC (%FX-DISC): PUSH < 0 = 0.8 R.
#[allow(clippy::too_many_arguments)]
pub fn fx_disc(c: &mut Ctx, x: f32, y: f32, z: f32, r: f32, wob: f32, seed: f32, pal: f32, k: f32, push: f32) {
    let (pk, push, rt, up) = (toon_a(pal, k), if push < 0.0 { 0.8 * r } else { push }, c.cam.right, c.cam.upv);
    let (x, y, z, sc) = toward_eye(c.cam, x, y, z, push);
    let r = r * sc;
    if let Some(v) = c.verts(Mode::Toon, 6) {
        bb_verts(v, x, y, z, r * rt[0], r * rt[1], r * rt[2], r * up[0], r * up[1], r * up[2], 1.0, seed, wob, pk);
    }
}

/// port: fx-shapes.lisp FX-WALL (%FX-WALL) on the ground polyline XS / ZS (N points).
#[allow(clippy::too_many_arguments)]
pub fn fx_wall(c: &mut Ctx, xs: &[f32], zs: &[f32], n: usize, height: f32, scallops: usize, wob: f32, seed: f32, pal: f32, k: f32) {
    let (pk, sd) = (toon_a(pal, k), -1.0 - f_abs(seed));
    let cols = 6 * scallops.max(1);
    let inv = 1.0 / cols as f32;
    if n < 2 {
        return;
    }
    let Some(v) = c.verts(Mode::Toon, 6 * cols) else { return };
    let (mut lx, mut lz, mut lh, mut lv) = (0.0f32, 0.0f32, 0.0f32, 0.0f32);
    for col in 0..=cols {
        let p = (n - 1) as f32 * inv * col as f32;
        let seg = (n - 2).min(duel_sim::cl::floor_f32(p) as usize);
        let f = p - seg as f32;
        let x = xs[seg] + f * (xs[seg + 1] - xs[seg]);
        let z = zs[seg] + f * (zs[seg + 1] - zs[seg]);
        let u = inv * col as f32;
        let m = 2.0 * u - 1.0;
        let q = scallops as f32 * u;
        let j = (scallops - 1).min(duel_sim::cl::floor_f32(q) as usize);
        let tri = 1.0 - f_abs(2.0 * (q - j as f32) - 1.0);
        let tip = tri * f_sqrt(tri);
        let h = height * (1.0 - 0.4 * m * m) * f_min(1.0, 5.0 * f_min(u, 1.0 - u)) * (0.45 + 0.55 * tip * (0.75 + 0.25 * h01(j as f32, seed)));
        if col > 0 {
            let vv = lv + 0.8 * f_hypot(x - lx, z - lz);
            vtx(v, lx, 0.02, lz, 0.0, lv, 1.0, sd, wob, pk);
            vtx(v, x, 0.02, z, 0.0, vv, 1.0, sd, wob, pk);
            vtx(v, x, h, z, 1.0, vv, 0.2, sd, wob, pk);
            vtx(v, lx, 0.02, lz, 0.0, lv, 1.0, sd, wob, pk);
            vtx(v, x, h, z, 1.0, vv, 0.2, sd, wob, pk);
            vtx(v, lx, lh, lz, 1.0, lv, 0.2, sd, wob, pk);
            lv = vv;
        }
        (lx, lz, lh) = (x, z, h);
    }
}

/// port: render.lisp FX-LINE — a camera-facing segment (half-widths W0 at the start, W1 at the end; alphas A0, A1).
#[allow(clippy::too_many_arguments)]
pub fn fx_line(c: &mut Ctx, p0: [f32; 3], p1: [f32; 3], w0: f32, r: f32, g: f32, b: f32, a0: f32, mode: Mode, w1: f32, a1: f32) {
    let ([x0, y0, z0], [x1, y1, z1], eye) = (p0, p1, c.cam.eye);
    let (dx, dy, dz) = (x1 - x0, y1 - y0, z1 - z0);
    let (ex, ey, ez) = (eye[0] - x0, eye[1] - y0, eye[2] - z0);
    let (mut sx, mut sy, mut sz) = (dy * ez - dz * ey, dz * ex - dx * ez, dx * ey - dy * ex);
    let sl = duel_sim::math::hypot3(sx, sy, sz);
    if sl <= 1e-9 {
        return;
    }
    (sx, sy, sz) = (sx / sl, sy / sl, sz / sl);
    let Some(v) = c.verts(mode, 6) else { return };
    vtx(v, x0 - sx * w0, y0 - sy * w0, z0 - sz * w0, 0.0, -1.0, r, g, b, a0);
    vtx(v, x0 + sx * w0, y0 + sy * w0, z0 + sz * w0, 0.0, 1.0, r, g, b, a0);
    vtx(v, x1 + sx * w1, y1 + sy * w1, z1 + sz * w1, 0.0, 1.0, r, g, b, a1);
    vtx(v, x0 - sx * w0, y0 - sy * w0, z0 - sz * w0, 0.0, -1.0, r, g, b, a0);
    vtx(v, x1 + sx * w1, y1 + sy * w1, z1 + sz * w1, 0.0, 1.0, r, g, b, a1);
    vtx(v, x1 - sx * w1, y1 - sy * w1, z1 - sz * w1, 0.0, -1.0, r, g, b, a1);
}

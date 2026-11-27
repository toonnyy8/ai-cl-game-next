//! port: duel/lisp/stage.lisp 218-356 — the Bankai's cracks (STAGE-CRACK-ADD, ST-DRAW-CRACKS), the round's marks (STAGE-MARK,
//! ST-DRAW-MARKS), the rubble chips (STAGE-DEBRIS, ST-CHIPS). Marks and cracks draw into the toon batch; a chip is two dq records
//! (its rubble mesh and its ink hull).
use super::shapes::{ground_seg, hash01, toon_a, PAL_BLACK_SMOKE, PAL_EMBER};
use super::Ctx;
use crate::draw::queue::{draw_mesh, DrawOpts};
use crate::draw::stage::TOON_GROUND;
use duel_sim::math::{f_abs, f_cos, f_sin};

/// +CRACK-MAX+, +CRACK-SEGS+, +CRACK-STRIDE+, +MARK-N+, +MARK-STRIDE+, +CHIP-N+, +CHIP-STRIDE+.
const CRACK_MAX: usize = 8;
const CRACK_SEGS: usize = 20;
const CRACK_STRIDE: usize = 4 + 4 * CRACK_SEGS;
const MARK_N: usize = 20;
const MARK_STRIDE: usize = 5;
const CHIP_N: usize = 24;
const CHIP_STRIDE: usize = 10;
/// stage.lisp `*st-ink*`: a chip hull's toon lanes (mode 3, full fog, 1.4 px).
const ST_INK: [f32; 4] = [3.0, 0.01, 1.0, 1.4];

/// The stage's FX state: `*st-cracks*` / `*st-ncracks*`, `*st-marks*` / `*st-nmarks*`, `*st-chips*` / `*st-chip-i*`.
pub struct StageFx {
    cracks: [f32; CRACK_MAX * CRACK_STRIDE],
    ncracks: usize,
    marks: [f32; MARK_N * MARK_STRIDE],
    nmarks: usize,
    chips: [f32; CHIP_N * CHIP_STRIDE],
    chip_i: usize,
}

impl Default for StageFx {
    fn default() -> Self {
        let mut chips = [0.0; CHIP_N * CHIP_STRIDE];
        for i in 0..CHIP_N {
            chips[i * CHIP_STRIDE + 8] = -1.0;
        }
        StageFx { cracks: [0.0; CRACK_MAX * CRACK_STRIDE], ncracks: 0, marks: [0.0; MARK_N * MARK_STRIDE], nmarks: 0, chips, chip_i: 0 }
    }
}

impl StageFx {
    /// port: stage.lisp STAGE-CLEAR-CRACKS (a new match: no cracks, marks or chips).
    pub fn clear_cracks(&mut self) {
        self.ncracks = 0;
        self.clear_marks();
    }
    /// port: stage.lisp STAGE-CLEAR-MARKS (the :reset event).
    pub fn clear_marks(&mut self) {
        self.nmarks = 0;
        for i in 0..CHIP_N {
            self.chips[i * CHIP_STRIDE + 8] = -1.0;
        }
    }
}

/// port: stage.lisp STAGE-CRACK-ADD — 5 jagged rays of 4 segments from (x z), R long (the newest +CRACK-MAX+ kept).
pub fn crack_add(c: &mut Ctx, x: f32, z: f32, r: f32) {
    let o = (c.fx.stage.ncracks % CRACK_MAX) * CRACK_STRIDE;
    c.fx.stage.cracks[o..o + 4].copy_from_slice(&[x, z, r, 0.0]);
    let mut s = 4;
    for ray in 0..5 {
        let a = ray as f32 * 1.2566 + c.rr(-0.4, 0.4);
        let (mut px, mut pz, step) = (x, z, r / 4.0);
        for _ in 0..4 {
            let a2 = a + c.rr(-0.6, 0.6);
            let (nx, nz) = (px + step * f_cos(a2), pz + step * f_sin(a2));
            c.fx.stage.cracks[o + s..o + s + 4].copy_from_slice(&[px, pz, nx, nz]);
            s += 4;
            (px, pz) = (nx, nz);
        }
    }
    c.fx.stage.ncracks += 1;
}

/// port: stage.lisp ST-DRAW-CRACKS.
pub fn draw_cracks(c: &mut Ctx) {
    let tm = c.clock;
    let n = c.fx.stage.ncracks.min(CRACK_MAX);
    let d3 = ((duel_sim::cl::floor_f32(8.0 * tm) as i32) & 63) as f32;
    for i in 0..n {
        let (o, fi) = (i * CRACK_STRIDE, i as f32);
        let pk = 0.6 + 0.4 * f_abs(f_sin(1.7 * d3 + 2.3 * fi));
        for k in 0..CRACK_SEGS {
            let s = o + 4 + k * 4;
            let j = (k % 4) as f32;
            let (h0, w, sd) = (1.0 - 0.2 * j, 0.09 * (1.0 - 0.18 * j), 5.0 * fi + k as f32);
            let h1 = h0 - 0.2;
            let q: [f32; 4] = c.fx.stage.cracks[s..s + 4].try_into().unwrap();
            ground_seg(c, q[0], q[1], q[2], q[3], 0.035, w, h0, h1, sd, 0.25, toon_a(PAL_BLACK_SMOKE, 0.98));
            ground_seg(c, q[0], q[1], q[2], q[3], 0.042, 0.3 * w, h0, h1, sd + 50.0, 0.1, toon_a(PAL_EMBER, pk));
        }
    }
}

/// port: stage.lisp STAGE-MARK — a :scorch (CRACK false) or :crack mark of radius R at (x z), inside the plaza only.
pub fn stage_mark(c: &mut Ctx, crack: bool, x: f32, z: f32, r: f32) {
    if x * x + z * z < 14.5 * 14.5 {
        let o = (c.fx.stage.nmarks % MARK_N) * MARK_STRIDE;
        c.fx.stage.marks[o..o + 5].copy_from_slice(&[x, z, r, if crack { 1.0 } else { 0.0 }, c.clock]);
        c.fx.stage.nmarks += 1;
    }
}

/// port: stage.lisp STAGE-DEBRIS — N chips thrown up from (x z) at SPEED x 2.5-4.5 m/s.
pub fn stage_debris(c: &mut Ctx, x: f32, z: f32, n: usize, speed: f32) {
    for _ in 0..n {
        let o = c.fx.stage.chip_i * CHIP_STRIDE;
        let a = c.rr(0.0, 6.2832);
        let sp = speed * c.rr(2.5, 4.5);
        c.fx.stage.chip_i = (c.fx.stage.chip_i + 1) % CHIP_N;
        let (ca, sa) = (f_cos(a), f_sin(a));
        let vy = c.rr(3.0, 6.0);
        let spin = c.rr(-14.0, 14.0);
        let sc = c.rr(0.6, 1.3);
        c.fx.stage.chips[o..o + CHIP_STRIDE].copy_from_slice(&[x + 0.25 * ca, 0.15, z + 0.25 * sa, sp * ca, vy, sp * sa, a, spin, 0.0, sc]);
    }
}

/// port: stage.lisp ST-DRAW-MARKS.
pub fn draw_marks(c: &mut Ctx) {
    let (n, tm) = (c.fx.stage.nmarks.min(MARK_N), c.clock);
    for i in 0..n {
        let o = i * MARK_STRIDE;
        let v: [f32; 5] = c.fx.stage.marks[o..o + 5].try_into().unwrap();
        let (x, z, r) = (v[0], v[1], v[2]);
        let (sd, y) = (3.7 * x + 1.3 * z, 0.018 + 0.0015 * (i % 6) as f32);
        let pk = toon_a(PAL_BLACK_SMOKE, super::shapes::f_clamp((tm - v[4]) / 0.12, 0.35, 0.98));
        if v[3] < 0.5 {
            for j in 0..9 {
                let fj = j as f32;
                let a = 0.698 * fj + 0.5 * (hash01(fj, sd) - 0.5);
                let l = r * (0.55 + 0.75 * hash01(fj + 9.0, sd));
                let w = r * (0.16 + 0.1 * hash01(fj + 3.0, sd));
                let (cx, sx) = (f_cos(a), f_sin(a));
                let (mx, mz) = (x + 0.5 * l * cx, z + 0.5 * l * sx);
                ground_seg(c, x, z, mx, mz, y, w, 1.0, 0.7, sd + fj, 0.12, pk);
                ground_seg(c, mx, mz, x + l * cx, z + l * sx, y, 0.4 * w, 0.7, 0.2, sd + fj + 20.0, 0.12, pk);
            }
        } else {
            for j in 0..5 {
                let fj = j as f32;
                let a = 1.2566 * fj + 0.6 * (hash01(fj, sd) - 0.5);
                let (mut px, mut pz) = (x, z);
                let st = r * ((0.8 + 0.4 * hash01(fj + 7.0, sd)) / 3.0);
                for k in 0..3 {
                    let fk = k as f32;
                    let a2 = a + 0.9 * (hash01(fj + 5.0 * fk, sd + 1.0) - 0.5);
                    let (nx, nz, h0) = (px + st * f_cos(a2), pz + st * f_sin(a2), 1.0 - 0.3 * fk);
                    ground_seg(c, px, pz, nx, nz, y, r * 0.05 * (1.0 - 0.3 * fk), h0, h0 - 0.3, sd + fj + 7.0 * fk, 0.12, pk);
                    (px, pz) = (nx, nz);
                }
            }
        }
    }
}

/// port: stage.lisp ST-CHIPS (DT effect seconds; ROCKS the three (mesh, hull) ids of `*st-rocks*`).
pub fn chips(c: &mut Ctx, rocks: &[(u32, u32); 3], dt: f32) {
    for i in 0..CHIP_N {
        let o = i * CHIP_STRIDE;
        let ch = &mut c.fx.stage.chips[o..o + CHIP_STRIDE];
        let mut age = ch[8];
        if age < 0.0 {
            continue;
        }
        age += dt;
        ch[8] = age;
        if age > 7.0 {
            ch[8] = -1.0;
            continue;
        }
        let s = ch[9] * super::shapes::f_clamp((7.0 - age) / 0.4, 0.0, 1.0);
        let fl = 0.05 * ch[9];
        if dt > 0.0 {
            ch[4] -= 18.0 * dt;
            for k in 0..3 {
                ch[k] += dt * ch[3 + k];
            }
            ch[6] += dt * ch[7];
            if ch[1] < fl {
                ch[1] = fl;
                if ch[4] < -2.0 {
                    (ch[4], ch[3], ch[5], ch[7]) = (-0.3 * ch[4], 0.5 * ch[3], 0.5 * ch[5], 0.4 * ch[7]);
                } else {
                    (ch[3], ch[4], ch[5], ch[7]) = (0.0, 0.0, 0.0, 0.0);
                }
            }
        }
        let mut m = [0.0f32; 16];
        crate::rig::euler(&mut m, ch[0], ch[1], ch[2], i as f32 + 0.6 * ch[6], ch[6], 0.0, s);
        let (mesh, hull) = rocks[i % 3];
        draw_mesh(c.out, mesh, &m, &DrawOpts { toon: Some(TOON_GROUND), ..DrawOpts::default() });
        draw_mesh(c.out, hull, &m, &DrawOpts { toon: Some(ST_INK), ..DrawOpts::default() });
    }
}

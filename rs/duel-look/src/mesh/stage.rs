//! port: duel/lisp/stage.lisp STAGE-INIT's meshes: the floor (the plaza, its joints and ink cracks, the curb), the walls, the town,
//! the burnt ruins and the three rubble chips with their hulls; their randomness is ST-RND (an integer LCG from 7771, setup only),
//! never the cosmetic RNG. (ST-DRAW-CRACKS / ST-DRAW-MARKS are stream draws: the FX task.)
use super::meshgen::{hexc, hull, Mb, Xf, PI, V3, XF};
use duel_sim::cl::max_f32;
use duel_sim::math::{cos_d, sin_d};

/// port: duel/lisp/stage.lisp *ST-RNG* / ST-RND / ST-R.
struct Rnd(i64);
impl Rnd {
    fn rnd(&mut self) -> f32 {
        self.0 = (self.0 * 1103515245 + 12345).rem_euclid(2147483648);
        ((self.0 >> 6) & 0xFF_FFFF) as f32 / 16777216.0
    }
    /// `(+ a (* (- b a) (st-rnd)))` (an integer pair's difference is exact as a single).
    fn r(&mut self, a: f32, b: f32) -> f32 {
        a + (b - a) * self.rnd()
    }
}

/// port: duel/lisp/stage.lisp ST-UP-QUAD: an upward polygon through PTS (x z) at height Y (PTS singles or long-floats, narrowed by V3).
fn up_quad(mb: &mut Mb, pts: &[[f64; 2]], y: f32) {
    let v: Vec<V3> = pts.iter().map(|p| [p[0] as f32, y, p[1] as f32]).collect();
    mb.poly_out(&v, None, [pts[0][0] as f32, y - 1.0, pts[0][1] as f32]);
}

/// port: duel/lisp/stage.lisp ST-ANNULUS (a0 = 2 pi (k / n): long-floats).
fn annulus(mb: &mut Mb, r0: f32, r1: f32, y: f32, n: usize) {
    let (r0, r1) = (r0 as f64, r1 as f64);
    for k in 0..n {
        let (a0, a1) = (2.0 * PI * (k as f64 / n as f64), 2.0 * PI * ((k + 1) as f64 / n as f64));
        let (c0, s0, c1, s1) = (cos_d(a0), sin_d(a0), cos_d(a1), sin_d(a1));
        up_quad(mb, &[[r0 * c0, r0 * s0], [r1 * c0, r1 * s0], [r1 * c1, r1 * s1], [r0 * c1, r0 * s1]], y);
    }
}

/// port: duel/lisp/stage.lisp ST-STRIP with long-float ends (the floor's radial joints).
#[allow(clippy::too_many_arguments)]
fn strip_d(mb: &mut Mb, x0: f64, z0: f64, x1: f64, z1: f64, w0: f32, w1: f32, y: f32) {
    let (dx, dz) = (x1 - x0, z1 - z0);
    let h = (dx * dx + dz * dz).sqrt();
    let l = if 1e-4f32 as f64 >= h { 1e-4f32 as f64 } else { h }; // (max 1e-4 l): the first unless the second is higher
    let (nx, nz) = (-dz / l, dx / l);
    let (w0, w1) = (w0 as f64, w1 as f64);
    up_quad(mb, &[[x0 - w0 * nx, z0 - w0 * nz], [x0 + w0 * nx, z0 + w0 * nz], [x1 + w1 * nx, z1 + w1 * nz], [x1 - w1 * nx, z1 - w1 * nz]], y);
}

/// port: duel/lisp/stage.lisp ST-STRIP with single ends (the ink cracks).
#[allow(clippy::too_many_arguments)]
fn strip_s(mb: &mut Mb, x0: f32, z0: f32, x1: f32, z1: f32, w0: f32, w1: f32, y: f32) {
    let (dx, dz) = (x1 - x0, z1 - z0);
    let l = max_f32(1e-4, (dx * dx + dz * dz).sqrt());
    let (nx, nz) = (-dz / l, dx / l);
    let p = |x: f32, z: f32| [x as f64, z as f64];
    up_quad(mb, &[p(x0 - w0 * nx, z0 - w0 * nz), p(x0 + w0 * nx, z0 + w0 * nz), p(x1 + w1 * nx, z1 + w1 * nz), p(x1 - w1 * nx, z1 - w1 * nz)], y);
}

/// port: duel/lisp/stage.lisp ST-CRACK: 5 cm wide at its start, 1.5 cm at its end (`(/ i n)` a ratio, made a single by the multiplication).
fn crack(mb: &mut Mb, pts: &[f32]) {
    let n = pts.len() / 2 - 1;
    let q = |i: usize| (i as f64 / n as f64) as f32;
    for i in 0..n {
        let (p, r) = (&pts[2 * i..], &pts[2 * i + 2..]);
        strip_s(mb, p[0], p[1], r[0], r[1], 0.025 - 0.0175 * q(i), 0.025 - 0.0175 * q(i + 1), 0.006);
    }
}

/// port: duel/lisp/stage.lisp BUILD-FLOOR.
fn build_floor(cracks: &[Vec<f32>]) -> Vec<f32> {
    let mut mb = Mb::with_color(hexc(0x767D8E));
    annulus(&mut mb, 0.0, 15.1, 0.0, 64);
    mb.hex(0x6A7182);
    for r in [11.3f32, 13.2] {
        annulus(&mut mb, r - 0.008, r + 0.008, 0.003, 96);
    }
    for k in 0..40 {
        let a = 2.0 * PI * ((k as f32 + 0.5) / 40.0) as f64;
        let (c, s) = (cos_d(a), sin_d(a));
        strip_d(&mut mb, 11.3f32 as f64 * c, 11.3f32 as f64 * s, 15.05f32 as f64 * c, 15.05f32 as f64 * s, 0.008, 0.008, 0.003);
    }
    mb.hex(0x262A36);
    for c in cracks {
        crack(&mut mb, c);
    }
    mb.hex(0x5C6272);
    mb.at(Xf { y: 0.06, ..XF }, |mb| mb.cylinder(15.6, 0.12, 64, 15.6, false, None, false));
    annulus(&mut mb, 15.1, 15.6, 0.12, 64);
    mb.hex(0x3C4150);
    annulus(&mut mb, 15.6, 160.0, -0.01, 64);
    mb.data
}

/// port: duel/lisp/stage.lisp ST-WALL-SEGMENT.
fn wall_segment(mb: &mut Mb, g: &mut Rnd, len: f32, h: f32, broken: bool) {
    mb.hex(0x30343F);
    mb.at(Xf { y: 0.2, ..XF }, |mb| mb.box_(len + 0.1, 0.4, 0.6));
    mb.hex(0x464B5C);
    if broken {
        let h1 = g.r(0.8, 0.8 * h);
        let h2 = g.r(0.5, 0.6 * h);
        mb.at(Xf { x: -0.25 * len, y: 0.4 + 0.5 * h1, ..XF }, |mb| mb.box_(0.5 * len, h1, 0.45));
        mb.at(Xf { x: 0.25 * len, y: 0.4 + 0.5 * h2, ..XF }, |mb| mb.box_(0.5 * len, h2, 0.45));
        mb.hex(0x30343F);
        for _ in 0..4 {
            let x = Xf { x: g.r(-len, len), y: 0.15, z: g.r(0.4, 1.4), yaw: g.r(0.0, 3.0), ..XF };
            let (w, d) = (g.r(0.3, 0.7), g.r(0.3, 0.6));
            mb.at(x, |mb| mb.box_(w, 0.3, d));
        }
    } else {
        mb.at(Xf { y: 0.4 + 0.5 * h, ..XF }, |mb| mb.box_(len, h, 0.45));
        mb.hex(0x50566A);
        mb.at(Xf { y: 0.5 + h, ..XF }, |mb| mb.box_(len + 0.2, 0.2, 0.9));
        mb.at(Xf { y: 0.68 + h, pitch: 0.785, ..XF }, |mb| mb.box_(len + 0.2, 0.22, 0.22));
        mb.at(Xf { y: 0.62 + h, pitch: 0.3, z: 0.25, ..XF }, |mb| mb.box_(len + 0.3, 0.06, 0.5));
        mb.at(Xf { y: 0.62 + h, pitch: -0.3, z: -0.25, ..XF }, |mb| mb.box_(len + 0.3, 0.06, 0.5));
    }
}

/// port: duel/lisp/stage.lisp BUILD-WALLS.
fn build_walls(g: &mut Rnd) -> Vec<f32> {
    let mut mb = Mb::new();
    let (n, r) = (30, 19.0f32);
    for k in 0..n {
        let a = 2.0 * PI * ((k as f32 + 0.5) / n as f32) as f64;
        let roll = g.rnd();
        if roll >= 0.18 {
            mb.at(Xf { x: (r as f64 * sin_d(a)) as f32, z: (r as f64 * cos_d(a)) as f32, yaw: a as f32, ..XF }, |mb| {
                wall_segment(mb, g, 3.9, 2.4, roll < 0.45)
            });
        }
    }
    mb.data
}

/// port: duel/lisp/stage.lisp ST-ROOF (a 4-sided pyramid of base W x D, height H, centred at height Y).
#[allow(clippy::approx_constant)] // (the Lisp's literal 0.7071, not FRAC_1_SQRT_2)
fn roof(mb: &mut Mb, y: f32, w: f32, d: f32, h: f32) {
    mb.at(Xf { y, sx: 0.7071 * w, sz: 0.7071 * d, ..XF }, |mb| mb.at(Xf { yaw: (PI / 4.0) as f32, ..XF }, |mb| mb.cone(1.0, h, 4)));
}

/// port: duel/lisp/stage.lisp ST-HOUSE.
#[allow(clippy::too_many_arguments)]
fn house(mb: &mut Mb, w: f32, d: f32, h: f32, roof_c: i64, wall: i64, beam: i64, storeys: u32) {
    for s in 0..storeys {
        let k = 1.0 - 0.25 * s as f32;
        let (w, d, y0) = (w * k, d * k, s as f32 * (h + 0.9));
        mb.hex(wall);
        mb.at(Xf { y: y0 + 0.5 * h, ..XF }, |mb| mb.box_(w, h, d));
        mb.hex(beam);
        for sx in [-0.5f32, -0.17, 0.17, 0.5] {
            mb.at(Xf { x: sx * (w - 0.1), y: y0 + 0.5 * h, z: 0.5 * d, ..XF }, |mb| mb.box_(0.14, h, 0.06));
        }
        mb.at(Xf { y: y0 + 0.8 * h, z: 0.5 * d, ..XF }, |mb| mb.box_(w, 0.14, 0.06));
        mb.hex(roof_c);
        mb.at(Xf { y: y0 + h + 0.05, ..XF }, |mb| mb.box_(w + 1.2, 0.1, d + 1.2));
        roof(mb, y0 + h + 0.75, w + 1.2, d + 1.2, 1.4);
    }
}

/// port: duel/lisp/stage.lisp BUILD-TOWN.
fn build_town(g: &mut Rnd) -> Vec<f32> {
    let mut mb = Mb::new();
    let at = |r: f32, a: f64, yaw: f64| Xf { x: (r as f64 * sin_d(a)) as f32, z: (r as f64 * cos_d(a)) as f32, yaw: yaw as f32, ..XF };
    for k in 0..16 {
        let a = 2.0 * PI * (k as f64 / 16.0) + g.r(-0.12, 0.12) as f64;
        let r = g.r(25.0, 34.0);
        let x = at(r, a, a + PI + g.r(-0.2, 0.2) as f64);
        let (w, d, h) = (g.r(6.0, 10.0), g.r(5.0, 7.0), g.r(2.8, 3.6));
        let st = if g.rnd() < 0.3 { 2 } else { 1 };
        mb.at(x, |mb| house(mb, w, d, h, 0x363A48, 0x484D60, 0x2C303C, st));
    }
    for k in 0..12 {
        let a = 2.0 * PI * ((k as f32 + 0.5) / 12.0) as f64 + g.r(-0.1, 0.1) as f64;
        let r = g.r(40.0, 50.0);
        let x = at(r, a, a + PI + g.r(-0.3, 0.3) as f64);
        let (w, d, h) = (g.r(8.0, 14.0), g.r(6.0, 9.0), g.r(3.5, 5.0));
        let st = if g.rnd() < 0.5 { 2 } else { 1 };
        mb.at(x, |mb| house(mb, w, d, h, 0x363A48, 0x3E4354, 0x2C303C, st));
    }
    for k in 0..40 {
        let a = 2.0 * PI * (k as f64 / 40.0);
        let (r, w, h) = (g.r(80.0, 110.0), g.r(10.0, 22.0), g.r(4.0, 12.0));
        mb.at(at(r, a, a), |mb| {
            mb.hex(0x343846);
            mb.at(Xf { y: 0.5 * h, ..XF }, |mb| mb.box_(w, h, 8.0));
            mb.hex(0x262A34);
            roof(mb, h + 1.2, 1.05 * w, 8.5, 2.4);
        });
    }
    mb.data
}

/// port: duel/lisp/stage.lisp BUILD-BURNT (*STAGE-RUINS*: x z scale).
fn build_burnt(g: &mut Rnd, ruins: &[[f32; 3]]) -> Vec<f32> {
    let mut mb = Mb::new();
    for &[x, z, s] in ruins {
        let yaw = g.r(0.0, 3.0);
        mb.at(Xf { x, z, yaw, ..XF }.s(s), |mb| {
            mb.hex(0x2E3240);
            mb.at(Xf { y: 2.2, ..XF }, |mb| mb.box_(10.0, 4.4, 7.0));
            mb.hex(0x262A34);
            for _ in 0..6 {
                let x = Xf { x: g.r(-5.0, 5.0), y: g.r(4.5, 7.0), z: g.r(-3.5, 3.5), pitch: g.r(-0.6, 0.6), roll: g.r(-0.6, 0.6), ..XF };
                let hh = g.r(2.0, 4.0);
                mb.at(x, |mb| mb.box_(0.3, hh, 0.3));
            }
            mb.hex(0x343846);
            mb.at(Xf { x: -2.0, roll: 0.25, ..XF }, |mb| roof(mb, 5.2, 7.0, 5.5, 1.6));
        });
    }
    mb.data
}

/// port: duel/lisp/stage.lisp BUILD-ROCKS: three chips (mesh, ink hull).
fn build_rocks() -> Vec<(Vec<f32>, Vec<f32>)> {
    (0..3)
        .map(|k| {
            let kf = k as f32;
            let mut mb = Mb::new();
            mb.hex(0x3A3E4A);
            mb.at(Xf { yaw: 0.7 * kf, roll: 0.3 * kf, ..XF }, |mb| mb.box_(0.2 + 0.05 * kf, 0.12, 0.18 - 0.03 * kf));
            mb.hex(0x5C6272);
            mb.at(Xf { x: 0.04, y: 0.05, yaw: 0.6, pitch: 0.5, roll: 0.4, ..XF }, |mb| mb.box_(0.12, 0.08, 0.1));
            let mut h = vec![];
            hull(&mut h, &mb.data, 0, mb.fill(), 1.0, 0.55, hexc(0x0C0C12));
            (mb.data, h)
        })
        .collect()
}

/// The stage's meshes (STAGE-INIT, *ST-RNG* bound to 7771 across them, in its order).
pub struct Stage {
    pub floor: Vec<f32>,
    pub walls: Vec<f32>,
    pub town: Vec<f32>,
    pub burnt: Vec<f32>,
    pub rocks: Vec<(Vec<f32>, Vec<f32>)>,
}

/// port: duel/lisp/stage.lisp STAGE-INIT (tables.json plaza_cracks and stage_ruins).
pub fn build(cracks: &[Vec<f32>], ruins: &[[f32; 3]]) -> Stage {
    let mut g = Rnd(7771);
    let floor = build_floor(cracks);
    let walls = build_walls(&mut g);
    let town = build_town(&mut g);
    let burnt = build_burnt(&mut g, ruins);
    Stage { floor, walls, town, burnt, rocks: build_rocks() }
}

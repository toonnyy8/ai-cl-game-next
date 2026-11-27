//! port: duel/lisp/vfx-stamps.lisp and vfx-ember.lisp — the one-shot stamps (STAMP, STAMPS-DRAW, the %ST-* drawings through
//! FX-ENVELOPE on SAGE'd ages) and the universal looks that start them or emit toon scraps (VFX-HIT, -HOHO, -BURST, -KONPAKU-SHATTER,
//! -KIKON-RUSH, -RUSH-DASH, -SMOKE-PUFFS, -STEP-DUST, -SHOCKWAVE, -EMBER, -CHARGE). Yamamoto's / Hisagi's stamp kinds (17-22, 25-30)
//! and KUKAN-GIRI's VFX-RIFT are M4: a live one is reported as not ported.
use super::shapes::*;
use super::vfx::{flash_light, n_of, t_blob};
use super::{Ctx, Em, P_T_SHARD};
use duel_sim::math::{f_cos, f_hypot, f_max, f_mod, f_sin};

const STAMP_N: usize = 48;
const STAMP_STRIDE: usize = 12;

/// `*stamps*` (kind x y z dx dy dz age scale seed n flag; kind 0 = free), `*stamp-seed*`, `*burst-flag*`.
pub struct Stamps {
    s: [f32; STAMP_N * STAMP_STRIDE],
    seed: f32,
    /// `*burst-flag*`[0]: set when a Burst stamp's ring fires (DRAW-SCENE gives it its beat and clears it).
    pub burst_flag: f32,
}

impl Default for Stamps {
    fn default() -> Self {
        Stamps { s: [0.0; STAMP_N * STAMP_STRIDE], seed: 0.0, burst_flag: 0.0 }
    }
}

/// `*stamp-kinds*`' codes (the in-scope ones).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Kind {
    Cut = 1,
    Heavy = 2,
    Fire = 3,
    Counter = 4,
    Guard = 5,
    GuardBreak = 6,
    Clash = 7,
    HohoOut = 8,
    HohoIn = 9,
    Burst = 10,
    Konpaku = 11,
    Rush = 12,
    Land = 13,
    GuardCrush = 14,
    Reiatsu = 15,
    Ember = 16,
    Ring = 23,
    Gash = 24,
}

impl Kind {
    /// A VFX-HIT kind's name (lower case; :breaker is :guard-break).
    pub fn of_hit(k: &str) -> Kind {
        match k {
            "cut" => Kind::Cut,
            "heavy" => Kind::Heavy,
            "fire" => Kind::Fire,
            "counter" => Kind::Counter,
            "guard" => Kind::Guard,
            "guard-break" | "breaker" => Kind::GuardBreak,
            "clash" => Kind::Clash,
            "guard-crush" => Kind::GuardCrush,
            "reiatsu" => Kind::Reiatsu,
            _ => panic!("vfx-hit kind {k}"),
        }
    }
}

/// port: vfx-stamps.lisp STAMP — the one-shot KIND at (x y z), direction D (a free slot, else the oldest).
#[allow(clippy::too_many_arguments)]
pub fn stamp(c: &mut Em, kind: Kind, x: f32, y: f32, z: f32, dx: f32, dy: f32, dz: f32, scale: f32, n: f32) {
    let st = &mut c.fx.stamps;
    let (mut best, mut oldest) = (0, -1.0f32);
    for i in 0..STAMP_N {
        let o = i * STAMP_STRIDE;
        if st.s[o] == 0.0 {
            best = i;
            break;
        }
        if st.s[o + 7] > oldest {
            (oldest, best) = (st.s[o + 7], i);
        }
    }
    let sd = st.seed + 7.31;
    st.seed = if sd >= 40.0 { sd - 40.0 } else { sd }; // (mod (+ seed 7.31) 40.0): the seed stays in [0, 40)
    let o = best * STAMP_STRIDE;
    st.s[o..o + STAMP_STRIDE].copy_from_slice(&[kind as i32 as f32, x, y, z, dx, dy, dz, 0.0, scale, st.seed, n, 0.0]);
}

/// port: vfx-stamps.lisp STAMPS-CLEAR.
pub fn stamps_clear(c: &mut Ctx) {
    c.fx.stamps.s = [0.0; STAMP_N * STAMP_STRIDE];
}

/// A stamp's slot as WITH-STAMP names it.
#[derive(Clone, Copy)]
struct S {
    o: usize,
    kind: f32,
    x: f32,
    y: f32,
    z: f32,
    dx: f32,
    dy: f32,
    dz: f32,
    age: f32,
    sc: f32,
    seed: f32,
    n: f32,
    sdx: f32,
    sdy: f32,
    drawing: f32,
}

fn slot(c: &Ctx, o: usize) -> S {
    let v = &c.fx.stamps.s[o..o + STAMP_STRIDE];
    let (rt, up) = (c.cam.right, c.cam.upv);
    let (dx, dy, dz) = (v[4], v[5], v[6]);
    S {
        o,
        kind: v[0],
        x: v[1],
        y: v[2],
        z: v[3],
        dx,
        dy,
        dz,
        age: v[7],
        sc: v[8],
        seed: v[9],
        n: v[10],
        sdx: dx * rt[0] + dy * rt[1] + dz * rt[2],
        sdy: dx * up[0] + dy * up[1] + dz * up[2],
        drawing: drawing_no(c.clock, 12.0),
    }
}

/// port: duel/lisp/vfx-stamps.lisp HIT-AGE — on ones for the first 2 ticks, then on twos.
fn hit_age(c: &Ctx, age: f32) -> f32 {
    if age < 0.0834 { sage(c.clock, age, 1.0) } else { sage(c.clock, age, 2.0) }
}

/// port: fx-shapes.lisp FX-ENVELOPE — (scale k flash phase) for AGE seconds (60 Hz frame counts FL GR HO OU, anticipation A).
fn envelope(age: f32, fl: f32, gr: f32, ho: f32, ou: f32, a: f32) -> (f32, f32, f32, i32) {
    let mut f = age * 60.0;
    if f < a {
        return (1.0 - 0.2 * (f / f_max(a, 1.0)), 0.98, 0.0, 0);
    }
    f -= a;
    if f < fl {
        (0.6, 0.98, 1.0, 1)
    } else if f < fl + gr {
        let u = (f - fl) / f_max(gr, 1.0);
        (0.6 + 0.5 * (1.0 - (1.0 - u) * (1.0 - u)), 0.98, 0.0, 2)
    } else if f < fl + gr + ho {
        (1.0, 0.98, 0.0, 3)
    } else if f < fl + gr + ho + ou {
        let u = (f - fl - gr - ho) / f_max(ou, 1.0);
        (1.0 + 0.05 * u, 0.98 * (1.0 - u), 0.0, 4)
    } else {
        (1.0, 0.0, 0.0, 5)
    }
}

/// port: duel/lisp/vfx-stamps.lisp %STAR — an irregular hit star at the stamp, reshuffled every drawing.
#[allow(clippy::too_many_arguments)]
fn star(c: &mut Ctx, s: &S, r0: f32, r1: f32, n: usize, sdx: f32, sdy: f32, wob: f32, seed: f32, pal: f32, k: f32, push: f32) {
    let rot = 6.2831855 * hash01(1.7, seed + s.drawing);
    fx_star(c, s.x, s.y, s.z, r0, r1, n, rot, sdx, sdy, wob, seed + s.drawing, pal, k, push);
}

/// port: duel/lisp/vfx-stamps.lisp %FLASH — drawing 1 of a hit: the white flash.
fn flash(c: &mut Ctx, s: &S, r: f32) {
    fx_star(c, s.x, s.y, s.z, 0.8 * r, 1.15 * r, 12, 6.2831855 * hash01(0.3, s.seed), 0.0, 0.0, 0.1, s.seed, PAL_HIT, 0.98, 0.45);
}

/// port: duel/lisp/vfx-stamps.lisp %STREAK — a straight tapered toon streak.
fn streak(c: &mut Ctx, p0: [f32; 3], p1: [f32; 3], w: f32, pal: f32, k: f32, seed: f32) {
    let m = [0.5 * (p0[0] + p1[0]), 0.5 * (p0[1] + p1[1]), 0.5 * (p0[2] + p1[2])];
    fx_crescent(c, p0, p1, m, w, true, 0.05, seed, pal, k, 0.3);
}

/// port: duel/lisp/vfx-stamps.lisp %SHARDS-OUT — N shards out of P around the screen direction (SDX SDY) (+-SPREAD), SPEED m/s at AGE.
#[allow(clippy::too_many_arguments)]
fn shards_out(c: &mut Ctx, n: usize, p: [f32; 3], sdx: f32, sdy: f32, age: f32, speed: f32, len: f32, w: f32, pal: f32, k: f32, seed: f32, spread: f32, push: f32) {
    let base = f_atan2(sdy, sdx);
    for i in 0..n {
        let f = i as f32;
        let a = base + spread * 2.0 * (hash01(f, seed) - 0.5);
        let (cs, sn, rt, up) = (f_cos(a), f_sin(a), c.cam.right, c.cam.upv);
        let (wx, wy, wz) = (cs * rt[0] + sn * up[0], cs * rt[1] + sn * up[1], cs * rt[2] + sn * up[2]);
        let d = 0.15 + age * speed * (0.6 + 0.8 * hash01(f + 3.1, seed));
        let l = len * (0.7 + 0.6 * hash01(f + 5.3, seed));
        fx_shard(c, p[0] + d * wx, p[1] + d * wy, p[2] + d * wz, wx, wy, wz, l, w, 0.06, seed + f, pal, k, push);
    }
}

/// F-ATAN2 (atan2f) through `yaw_to` = atan2f(-a, -b): duel-look calls no math crate.
pub fn f_atan2(y: f32, x: f32) -> f32 {
    duel_sim::math::yaw_to(-y, -x)
}

/// port: duel/lisp/vfx-stamps.lisp %ST-HIT (:cut :heavy :fire :counter :reiatsu).
fn st_hit(c: &mut Ctx, s: &S) -> bool {
    let heavy = s.kind == 2.0;
    let pal = match s.kind {
        3.0 => PAL_FIRE,
        4.0 => PAL_BLOOD,
        15.0 => PAL_REIATSU,
        _ => PAL_HIT,
    };
    let a = hit_age(c, s.age);
    let (es, k, _, ph) = envelope(a, 1.0, 2.0, if heavy { 3.0 } else { 2.0 }, if heavy { 8.0 } else { 6.0 }, 0.0);
    let (rt, up) = (c.cam.right, c.cam.upv);
    if ph == 1 {
        flash(c, s, s.sc * if heavy { 0.26 } else { 0.18 });
    } else if ph < 5 {
        let r1 = s.sc * es * if heavy { 0.9 } else if s.kind == 4.0 { 0.75 } else { 0.55 };
        star(c, s, 0.22 * r1, r1, if heavy { 8 } else { 6 }, s.sdx, s.sdy, 0.06, s.seed, pal, k, 0.35);
        shards_out(c, if heavy { 6 } else { 4 }, [s.x, s.y, s.z], s.sdx, s.sdy, a, 5.0, s.sc * 0.3, s.sc * 0.045, pal, k, s.seed, 0.7, 0.3);
        if heavy && a < 0.25 {
            let (l, px, py, x, y, z) = (s.sc * 0.65, -s.sdy, s.sdx, s.x, s.y, s.z);
            let pa = [x + l * (px * rt[0] + py * up[0]), y + l * (px * rt[1] + py * up[1]), z + l * (px * rt[2] + py * up[2])];
            let pb = [x - l * (px * rt[0] + py * up[0]), y - l * (px * rt[1] + py * up[1]), z - l * (px * rt[2] + py * up[2])];
            let pc = [
                x + 0.5 * l * (s.sdx * rt[0] + s.sdy * up[0]),
                y + 0.5 * l * (s.sdx * rt[1] + s.sdy * up[1]),
                z + 0.5 * l * (s.sdx * rt[2] + s.sdy * up[2]),
            ];
            fx_crescent(c, pa, pb, pc, s.sc * 0.07, false, 0.08, s.seed, PAL_HIT, 0.98, 0.5);
        }
    }
    ph == 5
}

/// port: duel/lisp/vfx-stamps.lisp %ST-GUARD.
fn st_guard(c: &mut Ctx, s: &S) -> bool {
    let a = hit_age(c, s.age);
    let (es, k, _, ph) = envelope(a, 0.0, 1.0, 4.0, 5.0, 0.0);
    if ph < 5 {
        let rot = 0.5236 * hash01(2.1, s.seed);
        fx_star(c, s.x, s.y, s.z, 1.0, s.sc * 0.5 * es, 6, rot, 0.0, 0.0, 0.03, s.seed, PAL_STEEL, k, 0.4);
        fx_star(c, s.x, s.y, s.z, 1.0, s.sc * 0.26 * es, 6, rot, 0.0, 0.0, 0.03, s.seed + 1.0, PAL_HIT, k, 0.42);
        shards_out(c, 4, [s.x, s.y, s.z], -s.sdx, -s.sdy, a, 4.0, s.sc * 0.22, s.sc * 0.04, PAL_STEEL, k, s.seed, 1.1, 0.3);
    }
    ph == 5
}

/// port: duel/lisp/vfx-stamps.lisp %ST-GUARD-BREAK.
fn st_guard_break(c: &mut Ctx, s: &S) -> bool {
    let a = hit_age(c, s.age);
    let (es, k, _, ph) = envelope(a, 1.0, 2.0, 3.0, 10.0, 0.0);
    let p = [s.x, s.y, s.z];
    if ph == 1 {
        flash(c, s, s.sc * 0.3);
    } else if ph < 5 {
        star(c, s, s.sc * 0.2, s.sc * es * 0.85, 8, s.sdx, s.sdy, 0.06, s.seed, PAL_HIT, k, 0.35);
        shards_out(c, 12, p, s.sdx, s.sdy, a, 4.5, s.sc * 0.42, s.sc * 0.11, PAL_BLOOD, k, s.seed, 3.1, 0.3);
        shards_out(c, 12, p, s.sdx, s.sdy, a, 4.5, s.sc * 0.34, s.sc * 0.075, PAL_INK, k, s.seed, 3.1, 0.36);
    }
    ph == 5
}

/// port: duel/lisp/vfx-stamps.lisp %ST-GUARD-CRUSH.
fn st_guard_crush(c: &mut Ctx, s: &S) -> bool {
    let a = hit_age(c, s.age);
    let (es, k, _, ph) = envelope(a, 0.0, 1.0, 3.0, 10.0, 0.0);
    if ph < 5 {
        if a < 0.05 {
            fx_star(c, s.x, s.y, s.z, 1.0, s.sc * 0.5, 6, 0.5236 * hash01(2.1, s.seed), 0.0, 0.0, 0.03, s.seed, PAL_STEEL, 0.98, 0.4);
        } else {
            star(c, s, s.sc * 0.18, s.sc * es * 0.7, 8, s.sdx, s.sdy, 0.06, s.seed, PAL_HIT, k, 0.35);
            shards_out(c, 12, [s.x, s.y, s.z], s.sdx, s.sdy, a, 4.0, s.sc * 0.3, s.sc * 0.08, PAL_STEEL, k, s.seed, 3.1, 0.3);
        }
    }
    ph == 5
}

/// port: duel/lisp/vfx-stamps.lisp %ST-CLASH.
fn st_clash(c: &mut Ctx, s: &S) -> bool {
    let a = hit_age(c, s.age);
    let (es, k, _, ph) = envelope(a, 1.0, 2.0, 4.0, 10.0, 0.0);
    if ph == 1 {
        flash(c, s, s.sc * 0.34);
    } else if ph < 5 {
        star(c, s, s.sc * 0.25, s.sc * es * 1.2, 8, 0.0, 1.0, 0.06, s.seed, PAL_HIT, k, 0.35);
        shards_out(c, 6, [s.x, s.y, s.z], 1.0, 0.0, a, 6.0, s.sc * 0.35, s.sc * 0.05, PAL_HIT, k, s.seed, 3.1, 0.3);
    }
    if ph < 5 {
        let r = 0.4 + 6.0 * sage(c.clock, s.age, 2.0);
        tring(c, s.x, 0.0, s.z, r, 0.07, PAL_HIT, 0.98 * k, s.seed, 32);
    }
    ph == 5
}

/// port: duel/lisp/vfx-stamps.lisp %ST-HOHO (:hoho-out: streaks then dust puffs; :hoho-in: converging streaks then a small star).
fn st_hoho(c: &mut Ctx, s: &S) -> bool {
    let a = sage(c.clock, s.age, 2.0);
    let (hx, hz, gy, x, y, z) = (-s.dz, s.dx, f_max(0.0, s.y - 1.0), s.x, s.y, s.z);
    if s.kind == 8.0 {
        let (_, k, _, ph) = envelope(a, 0.0, 0.0, 10.0, 14.0, 0.0);
        if a < 0.17 {
            for i in 0..6 {
                let f = i as f32;
                let (h, sd) = (gy + 0.3 + 0.26 * f, if i % 2 == 0 { 1.0 } else { -1.0 });
                let l0 = 0.2 + 0.5 * hash01(f, s.seed);
                let l1 = l0 + 1.2 + 9.0 * a;
                streak(c, [x + sd * l0 * hx, h, z + sd * l0 * hz], [x + sd * l1 * hx, h, z + sd * l1 * hz], s.sc * 0.035, PAL_HIT, 0.98 - 4.0 * a, s.seed + f);
            }
        }
        if a >= 0.16 {
            for i in 0..3 {
                let f = i as f32;
                let (ang, r) = (2.1 * f + s.seed, 0.3 + 1.2 * (a - 0.16));
                fx_disc(c, x + r * f_cos(ang), gy + 0.18, z + r * f_sin(ang), s.sc * (0.2 + 0.3 * a), 0.2, s.seed + f, PAL_DUST, k, -1.0);
            }
        }
        ph == 5
    } else {
        let (es, k, _, ph) = envelope(a, 0.0, 0.0, 6.0, 6.0, 6.0);
        if ph == 0 {
            for i in 0..6 {
                let f = i as f32;
                let ang = s.seed + 1.047 * f;
                let (cs, sn) = (f_cos(ang), f_sin(ang));
                let r1 = 2.2 - 16.0 * a;
                let r0 = r1 - 0.9;
                if r0 > 0.05 {
                    streak(c, [x + r1 * cs * hx, y + 0.9 * r1 * sn, z + r1 * cs * hz], [x + r0 * cs * hx, y + 0.9 * r0 * sn, z + r0 * cs * hz], s.sc * 0.03, PAL_HIT, 0.98, s.seed + f);
                }
            }
        } else if ph < 5 {
            star(c, s, s.sc * 0.08, s.sc * es * 0.4, 6, 0.0, 0.0, 0.05, s.seed, PAL_HIT, k, 0.35);
        }
        ph == 5
    }
}

/// port: duel/lisp/vfx-stamps.lisp %ST-BURST.
fn st_burst(c: &mut Ctx, s: &S) -> bool {
    let (a, cy) = (sage(c.clock, s.age, 1.0), s.y + 1.1);
    let (_, k, _, ph) = envelope(a, 0.0, 3.0, 3.0, 16.0, 4.0);
    if ph == 0 {
        for i in 0..8 {
            let f = i as f32;
            let ang = s.seed + 0.785 * f;
            let (cs, sn) = (f_cos(ang), f_sin(ang));
            let r1 = 2.4 - 25.0 * a;
            let r0 = r1 - 1.0;
            if r0 > 0.1 {
                streak(c, [s.x + r1 * cs, cy + r1 * sn, s.z], [s.x + r0 * cs, cy + r0 * sn, s.z], s.sc * 0.035, PAL_STEEL, 0.98, s.seed + f);
            }
        }
    } else if ph < 5 {
        if c.fx.stamps.s[s.o + 11] < 0.5 {
            c.fx.stamps.s[s.o + 11] = 1.0;
            c.fx.stamps.burst_flag = 1.0;
        }
        let r = s.sc * (0.5 + 7.0 * (a - 0.066));
        tring(c, s.x, s.y, s.z, r, 0.16, PAL_HIT, k, s.seed, 32);
        tring(c, s.x, s.y, s.z, f_max(0.1, r - 0.55), 0.05, PAL_STEEL, k, s.seed + 1.0, 32);
        shards_out(c, 8, [s.x, cy, s.z], 0.0, 1.0, a, 7.0, s.sc * 0.3, s.sc * 0.05, PAL_STEEL, k, s.seed, 3.1, 0.3);
    }
    ph == 5
}

/// port: duel/lisp/vfx-stamps.lisp %ST-KONPAKU.
fn st_konpaku(c: &mut Ctx, s: &S) -> bool {
    let a = hit_age(c, s.age);
    let (es, k, _, ph) = envelope(a, 1.0, 2.0, 3.0, 10.0, 0.0);
    if ph == 1 {
        flash(c, s, s.sc * 0.22);
    } else if ph < 5 {
        star(c, s, s.sc * 0.15, s.sc * es * 0.7, 7, 0.0, 1.0, 0.05, s.seed, PAL_SOUL, k, 0.35);
        tring(c, s.x, s.y - 1.1, s.z, 0.3 + 3.0 * a, 0.05, PAL_SOUL, k, s.seed, 32);
    }
    ph == 5
}

/// port: duel/lisp/vfx-stamps.lisp %ST-RING (:rush :land :ring; :garb is Yamamoto's: M4).
fn st_ring(c: &mut Ctx, s: &S) -> bool {
    let (rush, ring, a) = (s.kind == 12.0, s.kind == 23.0, sage(c.clock, s.age, 2.0));
    let pal = if rush {
        PAL_BLOOD
    } else if ring {
        s.n
    } else {
        PAL_DUST
    };
    let (_, k, _, ph) = envelope(a, 0.0, 2.0, 3.0, 14.0, 0.0);
    if ph < 5 {
        let r = s.sc * (0.4 + (if ring { 7.0 } else if rush { 5.0 } else { 2.5 }) * a);
        tring(c, s.x, s.y, s.z, r, s.sc * if rush || ring { 0.12 } else { 0.06 }, pal, k, s.seed, 32);
        if rush || ring {
            tring(c, s.x, s.y, s.z, s.sc * (0.3 + (if ring { 4.5 } else { 2.5 }) * a), 0.04, pal, k, s.seed + 1.0, 32);
        }
    }
    ph == 5
}

/// port: vfx-ember.lisp %ST-EMBER.
fn st_ember(c: &mut Ctx, s: &S) -> bool {
    let a = hit_age(c, s.age);
    let (es, k, _, ph) = envelope(a, 1.0, 2.0, 2.0, 8.0, 0.0);
    if ph == 1 {
        flash(c, s, s.sc * 0.2);
    } else if ph < 5 {
        star(c, s, s.sc * 0.15, s.sc * es * 0.55, 7, s.sdx, s.sdy, 0.06, s.seed, PAL_EMBER, k, 0.35);
        shards_out(c, 4, [s.x, s.y, s.z], s.sdx, s.sdy, a, 4.0, s.sc * 0.25, s.sc * 0.04, PAL_EMBER, k, s.seed, 2.0, 0.3);
    }
    ph == 5
}

/// port: duel/lisp/vfx-stamps.lisp %ST-GASH — a rift's ink gash (X Y Z its near end, D along it, SC its length; TATE-GOTO's stands it up).
fn st_gash(c: &mut Ctx, s: &S) -> bool {
    let a = sage(c.clock, s.age, 2.0);
    let p0 = [s.x, s.y, s.z];
    let p1 = [s.x + s.sc * s.dx, s.y + s.sc * s.dy, s.z + s.sc * s.dz];
    let (es, k, _, ph) = envelope(a, 0.0, 1.0, 4.0, 16.0, 0.0);
    let mid = [0.5 * (p0[0] + p1[0]), 0.5 * (p0[1] + p1[1]), 0.5 * (p0[2] + p1[2])];
    let bc = [mid[0], 0.06 + mid[1], mid[2]];
    if ph < 5 {
        fx_crescent(c, p0, p1, bc, 0.13 * es, false, 0.1, s.seed, PAL_INK, k, 0.2);
        if ph < 4 {
            fx_crescent(c, p0, p1, bc, 0.03, false, 0.05, s.seed + 1.0, PAL_HIT, 0.98, 0.25);
        }
        shards_out(c, 4, mid, 0.0, 1.0, a, 4.0, 0.25, 0.05, PAL_INK, k, s.seed, 1.4, 0.3);
    }
    ph == 5
}

/// port: vfx-stamps.lisp STAMPS-DRAW — age every live stamp by DT and draw it; free the finished ones. Returns a kind not ported.
pub fn stamps_draw(c: &mut Ctx, dt: f32) -> Option<&'static str> {
    let mut un = None;
    for i in 0..STAMP_N {
        let o = i * STAMP_STRIDE;
        let kind = duel_sim::cl::floor_f32(c.fx.stamps.s[o]) as i32;
        if kind <= 0 {
            continue;
        }
        c.fx.stamps.s[o + 7] += dt;
        let s = slot(c, o);
        let done = match kind {
            1..=4 | 15 => st_hit(c, &s),
            5 => st_guard(c, &s),
            6 => st_guard_break(c, &s),
            7 => st_clash(c, &s),
            14 => st_guard_crush(c, &s),
            8 | 9 => st_hoho(c, &s),
            10 => st_burst(c, &s),
            11 => st_konpaku(c, &s),
            12 | 13 | 23 => st_ring(c, &s),
            16 => st_ember(c, &s),
            24 => st_gash(c, &s),
            17..=22 | 25..=30 => {
                un = un.or(Some("a Yamamoto / Hisagi stamp (yama-vfx.lisp %ST-*, %ST-GASH, %ST-TIP: M4)"));
                true
            }
            _ => true,
        };
        if done {
            c.fx.stamps.s[o] = 0.0;
        }
    }
    un
}

// ---------------------------------------------------------------- the calls the game makes

/// port: vfx-stamps.lisp VFX-HIT — the hit spark KIND at (x y z), (dx dz) the hit direction; the heavy / fire / guard-break scraps
/// and the hit light.
pub fn vfx_hit(c: &mut Em, x: f32, y: f32, z: f32, kind: &str, dx: f32, dz: f32) {
    let l = f_max(0.01, f_hypot(dx, dz));
    let (dx, dz) = (dx / l, dz / l);
    let kind = if kind == "breaker" { "guard-break" } else { kind };
    stamp(c, Kind::of_hit(kind), x, y, z, dx, 0.0, dz, 1.0, 0.0);
    match kind {
        "heavy" => {
            for _ in 0..3 {
                let px = x + c.rr(-0.2, 0.2);
                let pz = z + c.rr(-0.2, 0.2);
                let l = c.rr(0.5, 0.8);
                let s = c.rr(0.16, 0.26);
                t_blob(c, px, y - 0.3, pz, 1.2 * dx, 0.6, 1.2 * dz, l, s, -0.2, 0.2, PAL_DUST);
            }
            let n = 5 + duel_sim::cl::floor_f32(3.99 * c.rnd()) as usize;
            for _ in 0..n {
                let sp = c.rr(2.5, 5.0);
                let vx = sp * (dx + c.rr(-0.4, 0.4));
                let vy = c.rr(0.5, 2.5);
                let vz = sp * (dz + c.rr(-0.4, 0.4));
                let l = c.rr(0.35, 0.6);
                let s = c.rr(0.03, 0.06);
                t_blob(c, x, y, z, vx, vy, vz, l, s, 9.0, 0.3, PAL_BLOOD);
            }
        }
        "fire" | "guard-break" => {
            let fire = kind == "fire";
            let (m, sp, vy, lf, sz) = if fire { (2.0, 0.6, [1.0, 2.5], [0.3, 0.5], [0.1, 0.16]) } else { (3.0, 0.5, [0.5, 2.5], [0.35, 0.55], [0.03, 0.05]) };
            for _ in 0..4 {
                let vx = m * (dx + c.rr(-sp, sp));
                let v = c.rr(vy[0], vy[1]);
                let vz = m * (dz + c.rr(-sp, sp));
                let l = c.rr(lf[0], lf[1]);
                let s = c.rr(sz[0], sz[1]);
                if fire {
                    t_blob(c, x, y, z, vx, v, vz, l, s, -2.0, 0.3, PAL_FIRE);
                } else {
                    t_blob(c, x, y, z, vx, v, vz, l, s, 9.0, 0.3, PAL_BLOOD);
                }
            }
        }
        _ => {}
    }
    flash_light(c, x, y, z, 1.0, 1.0, 1.0);
}

/// port: duel/lisp/vfx-stamps.lisp VFX-HOHO — vanish (APPEAR false) or appear at the body's centre; (dx dz) the facing.
pub fn vfx_hoho(c: &mut Em, x: f32, y: f32, z: f32, appear: bool, dx: f32, dz: f32) {
    stamp(c, if appear { Kind::HohoIn } else { Kind::HohoOut }, x, y, z, dx, 0.0, dz, 1.0, 0.0);
}

/// port: duel/lisp/vfx-stamps.lisp VFX-BURST.
pub fn vfx_burst(c: &mut Em, x: f32, y: f32, z: f32) {
    stamp(c, Kind::Burst, x, y, z, 0.0, 0.0, -1.0, 1.0, 0.0);
    flash_light(c, x, y + 1.0, z, 0.85, 0.9, 1.0);
}

/// port: duel/lisp/vfx-stamps.lisp VFX-KONPAKU-SHATTER — N soul-glass Konpaku lost at (x y z): 3N SOUL shards, a SOUL star, a ring.
pub fn vfx_konpaku_shatter(c: &mut Em, x: f32, y: f32, z: f32, n: usize) {
    stamp(c, Kind::Konpaku, x, y, z, 0.0, 0.0, -1.0, 1.0, 0.0);
    for _ in 0..3 * n {
        let a = c.rr(0.0, 6.2832);
        let sp = c.rr(2.5, 5.5);
        let vx = sp * f_cos(a);
        let vy = c.rr(0.5, 4.0);
        let vz = sp * f_sin(a);
        let l = c.rr(0.6, 1.0);
        let s = c.rr(0.12, 0.22);
        c.fx.emit_a(P_T_SHARD, x, y, z, vx, vy, vz, l, s, 7.0, 0.05, 0.0, 0.0, PAL_SOUL);
    }
    flash_light(c, x, y, z, 0.8, 0.9, 1.0);
}

/// port: duel/lisp/vfx-stamps.lisp VFX-KIKON-RUSH — a BLOOD ground ring and 5 DUST puffs at feet (x z).
pub fn vfx_kikon_rush(c: &mut Em, x: f32, z: f32) {
    stamp(c, Kind::Rush, x, 0.0, z, 0.0, 0.0, -1.0, 1.0, 0.0);
    for _ in 0..5 {
        let a = c.rr(0.0, 6.2832);
        let (ca, sa) = (f_cos(a), f_sin(a));
        let l = c.rr(0.5, 0.8);
        let s = c.rr(0.2, 0.3);
        t_blob(c, x + 0.4 * ca, 0.15, z + 0.4 * sa, 2.5 * ca, 0.5, 2.5 * sa, l, s, -0.3, 0.25, PAL_DUST);
    }
}

/// port: duel/lisp/vfx-stamps.lisp VFX-RUSH-DASH — a rush module takes off at (x z) along (dx dz), by LOOK.
pub fn vfx_rush_dash(c: &mut Em, x: f32, z: f32, dx: f32, dz: f32, look: Option<&str>) {
    match look {
        Some("flash-step") => stamp(c, Kind::HohoOut, x, 1.0, z, dx, 0.0, dz, 1.0, 0.0),
        Some("leap") => {
            stamp(c, Kind::Land, x, 0.0, z, 0.0, 0.0, -1.0, 1.2, 0.0);
            vfx_step_dust(c, x, z, dx, dz);
        }
        _ => vfx_step_dust(c, x, z, dx, dz),
    }
}

/// port: duel/lisp/vfx-stamps.lisp VFX-SMOKE-PUFFS — N BLACK SMOKE puffs rising at (x y z).
pub fn vfx_smoke_puffs(c: &mut Em, x: f32, y: f32, z: f32, n: usize) {
    for _ in 0..n {
        let px = x + c.rr(-0.15, 0.15);
        let pz = z + c.rr(-0.15, 0.15);
        let vx = c.rr(-0.3, 0.3);
        let vy = c.rr(0.8, 1.6);
        let vz = c.rr(-0.3, 0.3);
        let l = c.rr(0.6, 1.0);
        let s = c.rr(0.12, 0.22);
        t_blob(c, px, y, pz, vx, vy, vz, l, s, -0.4, 0.3, PAL_BLACK_SMOKE);
    }
}

/// port: duel/lisp/vfx-stamps.lisp VFX-STEP-DUST — 3 DUST puffs kicked back at feet (x z) moving along (dx dz).
pub fn vfx_step_dust(c: &mut Em, x: f32, z: f32, dx: f32, dz: f32) {
    for _ in 0..3 {
        let px = x + c.rr(-0.2, 0.2);
        let pz = z + c.rr(-0.2, 0.2);
        let vx = 2.0 * dx - c.rr(-0.6, 0.6);
        let vy = c.rr(0.3, 0.8);
        let vz = 2.0 * dz - c.rr(-0.6, 0.6);
        let l = c.rr(0.4, 0.6);
        let s = c.rr(0.14, 0.22);
        t_blob(c, px, 0.12, pz, vx, vy, vz, l, s, -0.2, 0.25, PAL_DUST);
    }
}

/// port: duel/lisp/vfx-stamps.lisp VFX-SHOCKWAVE — a toon ground ring at (x z) to radius R in PAL (DUST: the :land stamp and 4 puffs).
pub fn vfx_shockwave(c: &mut Em, x: f32, z: f32, r: f32, pal: f32) {
    if pal == PAL_DUST {
        stamp(c, Kind::Land, x, 0.0, z, 0.0, 0.0, -1.0, r / 2.5, 0.0);
        for _ in 0..4 {
            let a = c.rr(0.0, 6.2832);
            let (ca, sa) = (f_cos(a), f_sin(a));
            t_blob(c, x + 0.3 * ca, 0.12, z + 0.3 * sa, 2.0 * ca, 0.4, 2.0 * sa, 0.6, 0.2, -0.2, 0.25, PAL_DUST);
        }
    } else {
        stamp(c, Kind::Ring, x, 0.0, z, 0.0, 0.0, -1.0, r / 2.5, pal);
    }
}

/// port: vfx-ember.lisp VFX-EMBER — an EMBER star at (x y z), hit direction (dx dz).
pub fn vfx_ember(c: &mut Em, x: f32, y: f32, z: f32, dx: f32, dz: f32, scale: f32) {
    stamp(c, Kind::Ember, x, y, z, dx, 0.0, dz, scale, 0.0);
    flash_light(c, x, y, z, 1.0, 0.5, 0.2);
}

/// port: vfx-ember.lisp VFX-CHARGE — charging at the blade (x y z), K 0..1 (DRAW-FIGHTER's hold phase calls it).
pub fn vfx_charge(c: &mut Ctx, x: f32, y: f32, z: f32, k: f32, dt: f32) {
    let dr = f_mod(12.0 * c.clock, 64.0);
    let kq = 0.16667 * ffloor(6.0 * f_clamp(k, 0.0, 1.0));
    let (rt, up) = (c.cam.right, c.cam.upv);
    for i in 0..6 {
        let f = i as f32;
        let a = 1.0472 * f + 0.4 * hash01(f, 3.3);
        let ph = 1.0 - 0.1875 * f_mod(dr + f, 4.0);
        let rr = (0.35 + 0.5 * k) * (0.4 + 0.8 * ph);
        let (cs, sn) = (f_cos(a), f_sin(a));
        let (wx, wy, wz) = (cs * rt[0] + sn * up[0], cs * rt[1] + sn * up[1], cs * rt[2] + sn * up[2]);
        let pal = if i % 2 == 0 { PAL_FIRE } else { PAL_EMBER };
        fx_shard(c, x + rr * wx, y + rr * wy, z + rr * wz, -wx, -wy, -wz, 0.22 * (0.6 + k), 0.03, 0.05, f, pal, 0.9, 0.3);
    }
    fx_disc(c, x, y, z, 0.07 + 0.26 * kq, 0.3, 50.0, PAL_FIRE, 0.95, 0.2);
    fx_disc(c, x, y, z, 0.03 + 0.08 * kq, 0.2, 55.0, PAL_HIT, 0.98, 0.25);
    let c2 = &mut c.em();
    let n = n_of(c2, 20.0 + 40.0 * k, dt);
    for _ in 0..n {
        let c = &mut *c2;
        let (dx, dy, dz) = (c.rr(-1.0, 1.0), c.rr(-1.0, 1.0), c.rr(-1.0, 1.0));
        let l = f_max(0.05, super::f_hypot3(dx, dy, dz));
        let r = 0.6 + 0.5 * k;
        let sp = r / (l * 0.3);
        t_blob(c, x + r * (dx / l), y + r * (dy / l), z + r * (dz / l), -(sp * dx), -(sp * dy), -(sp * dz), 0.3, 0.03 + 0.04 * k, 0.0, 0.2, PAL_FIRE);
    }
    c.light(x, y, z, 1.0, 0.5, 0.15, 3.0 + 3.0 * k, 0.5 + k, 5);
}

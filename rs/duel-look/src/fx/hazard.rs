//! port: duel/lisp/hazards.lisp HAZARD-DRAW — every hazard's look this frame, at its drawn place (SLOW-DRAW's overlay): a :line's
//! ground cut (vfx.lisp VFX-LINE-CUT :meteor / :crack, %CRACK), Kenpachi's look hazards (ken-art.lisp KEN-CHIGIRI-LOOK,
//! KEN-TATEGOTO-LOOK, KEN-TATEGOTO-WAVE). Ichigo's look functions (ichigo-look.lisp: the Getsuga waves, the clones' and echoes' posed
//! bodies, RENZAN, the form / KX / flare looks) are reported as not ported (`Scene.unported`): task 7 draws posed bodies, and their
//! toon shapes come with it.
use super::shapes::*;
use super::vfx::{n_of, t_blob};
use super::{Ctx, P_T_SHARD};
use duel_sim::components::{Hazard, HazardKind};
use duel_sim::math::{f_abs, f_cos, f_hypot, f_sin, fwd_x, fwd_z};
use duel_sim::state::Match;

/// Kenpachi's look knobs (ken-art.lisp, from tuning.json).
#[derive(Clone, Copy, Debug)]
pub struct KenKnobs {
    pub chigiri_cuts: i64,
    pub chigiri_burst: i64,
    pub chigiri_quake: i64,
    pub tategoto_cut: i64,
    pub tategoto_wave_len: f32,
}

impl KenKnobs {
    pub fn new(d: &duel_data::Data) -> KenKnobs {
        let i = |k: &str| d.tuning[k].as_i64().unwrap_or_else(|| panic!("tuning {k}"));
        KenKnobs {
            chigiri_cuts: i("*CHIGIRI-CUTS*"),
            chigiri_burst: i("*CHIGIRI-BURST*"),
            chigiri_quake: i("*CHIGIRI-QUAKE*"),
            tategoto_cut: i("*TATEGOTO-CUT*"),
            tategoto_wave_len: d.tuning["*TATEGOTO-WAVE-LEN*"].as_f64().expect("tuning *TATEGOTO-WAVE-LEN*") as f32,
        }
    }
}

/// port: hazards.lisp HAZARD-DRAW (RDT the frame's effect seconds); AT the drawn place of a hazard (SLOW-DRAW's, else its own).
pub fn hazard_draw(c: &mut Ctx, m: &Match, kn: &KenKnobs, at: impl Fn(duel_sim::ecs::Entity) -> Option<[f32; 4]>, rdt: f32) -> Option<&'static str> {
    let mut un = None;
    for s in 0..m.ents.top {
        let Some(e) = m.ents.at(s) else { continue };
        let Some(h) = m.hazard.get(e) else { continue };
        let mut hz: Hazard = *h;
        if let Some(a) = at(e) {
            (hz.x, hz.y, hz.z, hz.yaw) = (a[0], a[1], a[2], a[3]);
        }
        // (a keyword look is ":METEOR"-like, a draw function its name)
        let look = hz.look.map(|l| l.0);
        let kw = look.and_then(|l| l.strip_prefix(':'));
        match look {
            Some(l) if kw.is_none() && l.eq_ignore_ascii_case("KEN-CHIGIRI-LOOK") => chigiri_look(c, kn, &hz),
            Some(l) if kw.is_none() && l.eq_ignore_ascii_case("KEN-TATEGOTO-LOOK") => tategoto_look(c, kn, &hz),
            Some(l) if kw.is_none() && l.eq_ignore_ascii_case("KEN-TATEGOTO-WAVE") => tategoto_wave_at(c, hz.x, hz.z, hz.yaw, hz.age, kn.tategoto_wave_len),
            Some(_) if kw.is_none() => {
                un = un.or(Some("a hazard's look function (ichigo-look.lisp's waves, clones, echoes, RENZAN, form / KX / flare looks: task 7)"));
            }
            _ => {
                if hz.delay <= 0 && hz.kind == Some(HazardKind::Line) {
                    let (x, z, age, life) = (hz.x, hz.z, hz.age as f32 / 60.0, hz.life as f32 / 60.0);
                    let (l, yaw) = (hz.size, hz.yaw);
                    let kind = if kw.is_some_and(|k| k.eq_ignore_ascii_case("METEOR")) { "meteor" } else if kw.is_some_and(|k| k.eq_ignore_ascii_case("CRACK")) { "crack" } else { "m4" };
                    un = un.or(vfx_line_cut(c, x, z, x + l * fwd_x(yaw), z + l * fwd_z(yaw), age, life, kind, rdt));
                }
            }
        }
    }
    un
}

/// port: vfx.lisp %CRACK — a jagged ground cut of toon strips: a DUST gash of half-width W and a REIATSU core (presences KG / KC).
#[allow(clippy::too_many_arguments)]
fn crack(c: &mut Ctx, x0: f32, z0: f32, x1: f32, z1: f32, w: f32, kg: f32, kc: f32, seed: f32) {
    let (dx, dz) = (x1 - x0, z1 - z0);
    let l = f_hypot(dx, dz);
    let n = (duel_sim::cl::floor_f32(1.5 * l) as i32).max(2);
    let (px, pz) = (-dz / duel_sim::math::f_max(l, 1e-4), dx / duel_sim::math::f_max(l, 1e-4));
    let (mut ox, mut oz, mut oh) = (x0, z0, 1.0f32);
    let (pg, pc) = (toon_a(PAL_DUST, kg), toon_a(PAL_REIATSU, kc));
    if kg <= 0.02 {
        return;
    }
    for i in 0..n {
        let u = (i + 1) as f32 / n as f32;
        let jag = if i == n - 1 { 0.0 } else { 0.35 * (hash01(i as f32, seed) - 0.5) };
        let (nx, nz, nh) = (x0 + u * dx + jag * px, z0 + u * dz + jag * pz, 1.0 - 0.8 * u);
        let ww = w * (0.35 + 0.65 * (1.0 - f_abs(2.0 * u - 1.0)));
        ground_seg(c, ox, oz, nx, nz, 0.03, ww, oh, nh, seed, 0.3, pg);
        if kc > 0.02 {
            ground_seg(c, ox, oz, nx, nz, 0.037, 0.28 * ww, oh, nh, seed + 3.0, 0.15, pc);
        }
        (ox, oz, oh) = (nx, nz, nh);
    }
}

/// port: vfx.lisp VFX-LINE-CUT for Kenpachi's kinds (:meteor: the split, the heave, the light sheet, rocks and dust; :crack /
/// anything else: Buttagiru's crack). Yamamoto's :enjo / :kyoku / :south / :kyokko are M4. DT feeds the particles.
#[allow(clippy::too_many_arguments)]
pub fn vfx_line_cut(c: &mut Ctx, x0: f32, z0: f32, x1: f32, z1: f32, age: f32, life: f32, kind: &str, dt: f32) -> Option<&'static str> {
    let (dx, dz) = (x1 - x0, z1 - z0);
    let l = duel_sim::math::f_max(1e-3, f_hypot(dx, dz));
    let (px, pz) = (-dz / l, dx / l);
    let v = f_clamp(age / duel_sim::math::f_max(life, 0.01), 0.0, 1.0);
    let (fade, seed) = (1.0 - v * v, x0 + 3.0 * z0);
    match kind {
        "meteor" => {
            let open = f_clamp(age / 0.12, 0.0, 1.0);
            let glow = f_clamp(1.0 - age / (0.6 * life), 0.0, 1.0);
            let inn = f_clamp(age / 0.03, 0.0, 1.0);
            let (sa, dr) = (sage(c.clock, age, 2.0), drawing_no(c.clock, 12.0));
            let wave = inn * f_clamp(1.0 - age / 0.6, 0.0, 1.0);
            let off = 0.4 + 9.0 * duel_sim::math::f_sqrt(sage(c.clock, age, 3.0));
            crack(c, x0, z0, x0 + open * dx, z0 + open * dz, 0.42, inn * 0.98 * fade, inn * glow, seed);
            if wave > 0.05 {
                let pk = toon_a(PAL_DUST, wave);
                ground_seg(c, x0 + off * px, z0 + off * pz, x1 + off * px, z1 + off * pz, 0.04, 0.22, 1.0, 0.2, seed + 7.0, 0.35, pk);
                ground_seg(c, x0 - off * px, z0 - off * pz, x1 - off * px, z1 - off * pz, 0.04, 0.22, 1.0, 0.2, seed + 8.0, 0.35, pk);
            }
            if inn > 0.0 && sa < 0.25 {
                for k in 0..5 {
                    let u = 0.25 * k as f32;
                    let sd = -2.0 - k as f32 - 5.0 * dr;
                    let pk = toon_a(PAL_HIT, 0.98 - 3.0 * sa);
                    let w0 = duel_sim::cl::min_f32(0.35, 0.05 * l);
                    toon_ribbon(c, [x0 + u * dx, 0.0, z0 + u * dz], [0.0, 5.0, 0.0], w0, 0.03, &Toon { wob: 0.15, ph: dr, segs: 2, ..Toon::new(sd, pk) });
                }
            }
            if age < 0.2 {
                let n = n_of(&mut c.em(), 40.0, dt);
                for _ in 0..n {
                    let (u, sd, sp) = (c.rnd(), if c.rnd() < 0.5 { -1.0 } else { 1.0 }, c.rr(3.0, 6.0));
                    let vy = c.rr(2.0, 5.0);
                    let lf = c.rr(0.6, 0.9);
                    let s = c.rr(0.1, 0.2);
                    c.fx.emit_a(P_T_SHARD, x0 + u * dx, 0.2, z0 + u * dz, sd * sp * px, vy, sd * sp * pz, lf, s, 9.0, 0.05, 0.0, 0.0, PAL_DUST);
                }
                let n = n_of(&mut c.em(), 50.0, dt);
                for _ in 0..n {
                    let (u, sd, sp) = (c.rnd(), if c.rnd() < 0.5 { -1.0 } else { 1.0 }, c.rr(1.5, 3.0));
                    let vy = c.rr(0.3, 1.0);
                    let lf = c.rr(0.6, 1.0);
                    let s = c.rr(0.25, 0.4);
                    t_blob(&mut c.em(), x0 + u * dx, 0.2, z0 + u * dz, sd * sp * px, vy, sd * sp * pz, lf, s, -0.2, 0.25, PAL_DUST);
                }
            }
            None
        }
        "m4" => Some("a Yamamoto line cut (vfx.lisp VFX-LINE-CUT :enjo / :kyoku / :south / :kyokko: M4)"),
        _ => {
            let open = f_clamp(age / 0.08, 0.0, 1.0);
            let glow = f_clamp(1.0 - age / (0.5 * life), 0.0, 1.0);
            crack(c, x0, z0, x0 + open * dx, z0 + open * dz, 0.2, 0.98 * fade, glow, seed);
            if age < 0.2 {
                let n = n_of(&mut c.em(), 20.0, dt);
                for _ in 0..n {
                    let (u, sd) = (c.rnd(), if c.rnd() < 0.5 { -1.0 } else { 1.0 });
                    let vy = c.rr(2.0, 4.0);
                    let lf = c.rr(0.5, 0.8);
                    let s = c.rr(0.08, 0.14);
                    c.fx.emit_a(P_T_SHARD, x0 + u * dx, 0.15, z0 + u * dz, sd * 2.5 * px, vy, sd * 2.5 * pz, lf, s, 9.0, 0.05, 0.0, 0.0, PAL_DUST);
                }
                let n = n_of(&mut c.em(), 35.0, dt);
                for _ in 0..n {
                    let (u, sd) = (c.rnd(), if c.rnd() < 0.5 { -1.0 } else { 1.0 });
                    let vy = c.rr(0.5, 1.2);
                    let lf = c.rr(0.5, 0.8);
                    let s = c.rr(0.18, 0.3);
                    t_blob(&mut c.em(), x0 + u * dx, 0.15, z0 + u * dz, sd * 2.0 * px, vy, sd * 2.0 * pz, lf, s, -0.2, 0.25, PAL_DUST);
                }
            }
            None
        }
    }
}

/// port: ken-art.lisp KEN-CHIGIRI-LOOK — the draw's white ring for 3 frames, then the slits (KEN-CHIGIRI-CUTS).
fn chigiri_look(c: &mut Ctx, kn: &KenKnobs, hz: &Hazard) {
    let (age, x, z) = (hz.age, hz.x, hz.z);
    if age < 3 {
        for i in 0..4 {
            let a0 = i as f32 * 1.5708;
            let (a1, am, r) = (a0 + 1.5708, a0 + 0.785, 2.0f32);
            let p0 = [x + r * f_cos(a0), 1.35, z + r * f_sin(a0)];
            let p1 = [x + r * f_cos(a1), 1.35, z + r * f_sin(a1)];
            let bc = [x + 1.45 * r * f_cos(am), 1.35, z + 1.45 * r * f_sin(am)];
            fx_crescent(c, p0, p1, bc, 0.16 - 0.05 * age as f32, false, 0.06, (40 + i) as f32, PAL_HIT, 0.95, 0.2);
        }
    }
    chigiri_cuts(c, x, z, age, kn.chigiri_cuts, 1.0, 0.0, kn.chigiri_burst, kn.chigiri_quake, 3);
}

/// port: ken-art.lisp KEN-CHIGIRI-CUTS — N slits round (x z) at AGE frames.
#[allow(clippy::too_many_arguments)]
pub fn chigiri_cuts(c: &mut Ctx, x: f32, z: f32, age: i64, n: i64, spread: f32, stagger: f32, burst: i64, quake: i64, flare: i64) {
    if age >= burst + flare {
        return;
    }
    let dr = drawing_no(c.clock, 12.0);
    for i in 0..n {
        let fi = i as f32;
        if (age as f32) < 2.0 + fi * stagger {
            continue;
        }
        let a = 6.2832 * hash01(fi, 1.7);
        let d = spread * (0.7 + 1.7 * hash01(fi, 2.9));
        let y = 0.5 + spread * 1.8 * hash01(fi, 4.3);
        let b = 6.2832 * hash01(fi, 5.1);
        let tilt = 1.6 * hash01(fi, 6.7) - 0.8;
        let l = spread * (0.55 + 0.5 * hash01(fi, 8.3));
        let (cx, cz) = (x + d * f_cos(a), z + d * f_sin(a));
        let (dx, dz, dy) = (l * f_cos(b) * f_cos(tilt), l * f_sin(b) * f_cos(tilt), l * f_sin(tilt));
        let g = duel_sim::cl::min_f32(1.0, (age - (burst - quake)).max(0) as f32 / quake as f32);
        let tr = spread * (0.008 + 0.09 * g) * (hash01(dr, fi) - 0.5);
        let burst_p = age >= burst;
        let p0 = [cx - dx, tr + (y - dy), cz - dz];
        let p1 = [cx + dx, tr + y + dy, cz + dz];
        let bc = [cx, tr + y, cz];
        fx_crescent(c, p0, p1, bc, if burst_p { 0.3 } else { 0.06 + 0.06 * g }, false, 0.06, (20 + i) as f32, PAL_BLOOD, 0.95, 0.2);
        fx_crescent(c, p0, p1, bc, if burst_p { 0.18 } else { 0.015 + 0.035 * g }, false, 0.04, (30 + i) as f32, PAL_HIT, 0.98, 0.24);
    }
}

/// port: ken-art.lisp KEN-TATEGOTO-LOOK — the chop's chord, the rift trembling, the cut.
fn tategoto_look(c: &mut Ctx, kn: &KenKnobs, hz: &Hazard) {
    let (age, x, z, dr) = (hz.age, hz.x, hz.z, drawing_no(c.clock, 12.0));
    let tr = 0.03 * (hash01(dr, 3.0) - 0.5);
    let xx = x + tr;
    let (p0, p1, bc) = ([xx, 7.0, z], [xx, 0.0, z], [xx, 3.5, z]);
    if age < 2 {
        fx_crescent(c, p0, p1, bc, 0.12, false, 0.04, 61.0, PAL_HIT, 0.98, 0.3);
    } else if age < kn.tategoto_cut {
        fx_crescent(c, p0, p1, bc, 0.07, false, 0.08, 61.0 + ((duel_sim::cl::floor_f32(dr) as i32) % 5) as f32, PAL_BLOOD, 0.95, 0.3);
        fx_crescent(c, p0, p1, bc, 0.018, false, 0.04, 66.0, PAL_HIT, 0.98, 0.34);
    } else if age < kn.tategoto_cut + 2 {
        fx_crescent(c, p0, p1, bc, 0.55, false, 0.06, 67.0, PAL_BLOOD, 0.95, 0.3);
        fx_crescent(c, p0, p1, bc, 0.32, false, 0.05, 68.0, PAL_HIT, 0.98, 0.34);
    }
}

/// port: ken-art.lisp KEN-TATEGOTO-WAVE-AT — three upright BLOOD crescents racing LEN m along YAW from (x0 z0) over 10 frames.
pub fn tategoto_wave_at(c: &mut Ctx, x0: f32, z0: f32, yaw: f32, age: i64, len: f32) {
    let u = duel_sim::cl::min_f32(1.0, age as f32 / 10.0);
    let (fx, fz) = (fwd_x(yaw), fwd_z(yaw));
    let (d, w) = (0.8 + len * u, 0.4 * (1.0 - 0.6 * u));
    let (cx, cz) = (x0 + d * fx, z0 + d * fz);
    if age >= 13 {
        return;
    }
    for (k, (off, h)) in [(-1.3f32, 3.0f32), (0.0, 4.6), (1.3, 3.0)].into_iter().enumerate() {
        let sd = (71 + k) as f32;
        let (x, z) = (cx + off * fz, cz - off * fx);
        let (p0, p1, bc) = ([x, 0.0, z], [x, h, z], [x + 0.9 * fx, 0.5 * h, z + 0.9 * fz]);
        fx_crescent(c, p0, p1, bc, w, false, 0.06, sd, PAL_BLOOD, 0.95, 0.3);
        fx_crescent(c, p0, p1, bc, 0.4 * w, false, 0.04, sd + 10.0, PAL_HIT, 0.98, 0.34);
    }
}

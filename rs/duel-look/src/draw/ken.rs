//! port: duel/lisp/ken-look.lisp KEN-DRAW (Kenpachi's :draw hook, the Shikai and the Bankai; docs/bevy/M3A_NOTES.md §7): the sword
//! wind on each hit window of the move he is in by the level it shows (streaks, crescents, a dust line, the floor's crack), and the
//! special ASs' looks (DAISHARIN's tornado, INSEKI-GIRI's meteor tail and impact). The tip tracking is Ichigo's (`ichigo.rs`).
use super::fighter::Sides;
use super::ichigo::{held_tip, ic_far, ic_frame, track};
use crate::fx::crack::{crack_add, stage_debris, stage_mark};
use crate::fx::shapes::{drawing_no, f_clamp, fx_crescent, fx_line, PAL_BLOOD, PAL_DUST, PAL_HIT, PAL_INK, PAL_REIATSU};
use crate::fx::stamps::vfx_shockwave;
use crate::fx::{f_hypot3, Ctx, Mode};
use crate::scene::Model;
use duel_data::Data;
use duel_sim::components::{Form, Phase, State};
use duel_sim::ecs::Entity;
use duel_sim::math::{f_cos, f_max, f_min, f_sin, f_sqrt};
use duel_sim::state::Match;

/// ken-look.lisp's knobs: `*ke-wind-life*`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Knobs {
    pub wind_life: i64,
}

impl Knobs {
    pub fn new(d: &Data) -> Knobs {
        Knobs { wind_life: d.tuning.get("*KE-WIND-LIFE*").and_then(|v| v.as_i64()).expect("tuning *KE-WIND-LIFE*") }
    }
}

/// A frame's shake requests reach `*shake*` (fx.lisp SHAKE) through this: the state and `*shake-mult*`.
pub type Shake<'a> = (&'a mut [f32; 8], f32);

/// port: ken-look.lisp %KE-STREAKS — L1+: three white streaks over a RIM rim peeling off behind TIP against its cut direction ST[D..],
/// fanned out from his centre (PX PZ), longer by LV; K presence.
#[allow(clippy::too_many_arguments)]
fn streaks(c: &mut Ctx, st: &[f32], d: usize, tip: [f32; 3], px: f32, pz: f32, lv: i64, k: f32, rim: f32) {
    let [x, y, z] = tip;
    let (dx, dy, dz) = (st[d], st[d + 1], st[d + 2]);
    let (rx, rz) = (x - px, z - pz);
    let rl = f_max(0.05, f_sqrt(rx * rx + rz * rz));
    let (ux, uz) = (rx / rl, rz / rl);
    let len = 0.6 * (1 + lv) as f32;
    let dr = drawing_no(c.clock, 12.0);
    for j in 0..3 {
        let fj = j as f32;
        let out = 0.08 + 0.14 * fj;
        let l = len * (1.0 - 0.22 * fj);
        let p0 = [x + out * ux + -l * dx, y + (0.1 - 0.1 * fj) * 1.0 + -l * dy, z + out * uz + -l * dz];
        let p1 = [x + out * ux, y + (0.1 - 0.1 * fj) * 1.0, z + out * uz];
        let bc = [0.5 * (p0[0] + p1[0]) + 0.12 * ux, 0.5 * (p0[1] + p1[1]), 0.5 * (p0[2] + p1[2]) + 0.12 * uz];
        let w = 0.05 + 0.03 * lv as f32;
        fx_crescent(c, p0, p1, bc, 1.6 * w, false, 0.04, 420.0 + fj + dr, rim, 0.6 * k * (1.0 - 0.2 * fj), 0.08);
        fx_crescent(c, p0, p1, bc, w, false, 0.04, 410.0 + fj + dr, PAL_HIT, k * (1.0 - 0.2 * fj), 0.12);
    }
}

/// port: ken-look.lisp %KE-CRESCENT — a wind crescent T0 of the way along its flight from TIP's bearing out of (PX PZ) to 1.6 x FAR's
/// distance, sinking toward 1.0 m, its chord the cut (ST[D..]) across the flight, a white lens W thick with a RIM rim behind it.
#[allow(clippy::too_many_arguments)]
fn crescent(c: &mut Ctx, st: &[f32], d: usize, tip: [f32; 3], far: [f32; 3], px: f32, pz: f32, t0: f32, w: f32, k: f32, seed: f32, rim: f32) {
    let (fx, fz) = (far[0] - px, far[2] - pz);
    let fl = f_max(0.1, f_sqrt(fx * fx + fz * fz));
    let (ux, uz) = (fx / fl, fz / fl);
    let dist = fl * (0.6 + 1.0 * t0);
    let (cx, cz) = (px + dist * ux, pz + dist * uz);
    let ty = f_clamp(tip[1], 0.6, 1.8);
    let cy = ty + t0 * (1.0 - ty);
    let (dx, dy, dz) = (st[d], st[d + 1], st[d + 2]);
    let du = dx * ux + dz * uz;
    let (mut ax, mut ay, mut az) = (dx - du * ux, dy, dz - du * uz);
    let al = f_hypot3(ax, ay, az);
    if al < 0.2 {
        (ax, ay, az) = (-uz, 0.0, ux);
    } else {
        (ax, ay, az) = (ax / al, ay / al, az / al);
    }
    let (h, b) = (1.2f32, 0.4 * 1.2f32);
    let (x0, y0, z0) = (cx - h * ax, f_max(0.1, cy - h * ay), cz - h * az);
    let (x1, y1, z1) = (cx + h * ax, f_max(0.1, cy + h * ay), cz + h * az);
    fx_crescent(c, [x0 - 0.08 * ux, y0, z0 - 0.08 * uz], [x1 - 0.08 * ux, y1, z1 - 0.08 * uz], [cx + (b - 0.08) * ux, cy, cz + (b - 0.08) * uz], 1.35 * w, false, 0.05,
                seed, rim, 0.85 * k, 0.08);
    fx_crescent(c, [x0, y0, z0], [x1, y1, z1], [cx + b * ux, cy, cz + b * uz], w, false, 0.05, seed + 7.0, PAL_HIT, k, 0.14);
}

/// port: ken-look.lisp %KE-DUST-LINE — L2+: a dust line along the floor from his feet (PX PZ) toward the far point, running out with T0.
fn dust_line(c: &mut Ctx, far: [f32; 3], px: f32, pz: f32, t0: f32, k: f32, seed: f32) {
    let (fx, fz) = (far[0] - px, far[2] - pz);
    let s = 0.4 + 1.4 * t0;
    let (x1, z1) = (px + s * fx, pz + s * fz);
    fx_crescent(c, [px + 0.3 * fx, 0.03, pz + 0.3 * fz], [x1, 0.03, z1], [0.5 * (px + x1), 0.12, 0.5 * (pz + z1)], 0.12, false, 0.1, seed, PAL_DUST, k, 0.05);
}

/// port: ken-look.lisp %KE-WIND — one hit window's sword wind at move frame SF (window FROM-TO, volume V, his feet P facing YAW, the cut
/// direction ST[D..]) at level LV; ONCE on the frame the window opens (the floor's crack, the rubble, the shake).
#[allow(clippy::too_many_arguments)]
fn wind(c: &mut Ctx, shake: &mut Shake, kn: &Knobs, st: &[f32], d: usize, v: &[f32; 6], p: [f32; 3], yaw: f32, tip: [f32; 3], sf: i64, from: i64, to: i64,
        lv: i64, once: bool, rim: f32) {
    let (px, pz, life) = (p[0], p[2], kn.wind_life);
    let Some(far) = ic_far(v, p, yaw, tip) else { return };
    let k = if sf < to + 1 { 1.0 } else { f_max(0.0, (to + life - sf) as f32 / life as f32) };
    let t0 = f_clamp((sf - from) as f32 / life as f32, 0.0, 1.0);
    let dr = drawing_no(c.clock, 12.0);
    if sf < to + 7 {
        let kk = 0.95 * f_min(1.0, (sf - (from - 3)) as f32 / 3.0) * f_min(1.0, (to + 7 - sf) as f32 / 5.0);
        streaks(c, st, d, tip, px, pz, lv, kk, rim);
    }
    if lv >= 2 && sf >= from {
        let kc = 0.95 * (1.0 - t0 * t0);
        crescent(c, st, d, tip, far, px, pz, t0, if lv >= 3 { 0.22 } else { 0.15 }, kc, 430.0 + dr, rim);
        if lv >= 3 {
            crescent(c, st, d, tip, far, px, pz, 0.7 * t0, 0.3, 0.8 * kc, 450.0 + dr, rim);
        }
        dust_line(c, far, px, pz, t0, 0.8 * k, 470.0 + dr);
    }
    if once {
        if lv >= 3 {
            stage_mark(&mut c.em(), true, far[0], far[2], 1.1);
            stage_debris(&mut c.em(), far[0], far[2], 6, 1.0);
            crate::fx::screen::shake_on(shake.0, shake.1, 0.1, 0.22);
        } else if lv == 2 {
            stage_debris(&mut c.em(), far[0], far[2], 3, 1.0);
        }
    }
}

/// port: ken-look.lisp %KE-TORNADO — the wind funnel round (PX PZ) at TM frames into it, presence K: four rings of three arcs widening
/// upward, each turning faster than the one below; a dust ring on the floor.
pub(crate) fn tornado(c: &mut Ctx, px: f32, pz: f32, tm: f32, k: f32, seed: f32) {
    for lv in 0..4 {
        let fl = lv as f32;
        let (y, r, spin) = (0.3 + 0.8 * fl, 1.1 + 0.4 * fl, tm * (0.32 + 0.06 * fl));
        for i in 0..3 {
            let a0 = spin + 2.0944 * i as f32 + 0.7 * fl;
            let (a1, am, rb) = (a0 + 1.6, a0 + 0.8, 1.22 * r);
            fx_crescent(c, [px + r * f_cos(a0), y + 0.12 * f_sin(a0), pz + r * f_sin(a0)], [px + r * f_cos(a1), y + 0.1, pz + r * f_sin(a1)],
                        [px + rb * f_cos(am), y + 0.18, pz + rb * f_sin(am)], (0.05 + 0.025 * fl) * k, false, 0.05, seed + 3.0 * fl + i as f32, PAL_HIT,
                        k * (0.95 - 0.12 * fl), 0.1);
        }
    }
    for i in 0..4 {
        let a0 = 0.4 * tm + 1.5708 * i as f32;
        let (a1, am) = (a0 + 1.2, a0 + 0.6);
        fx_crescent(c, [px + 1.6 * f_cos(a0), 0.05, pz + 1.6 * f_sin(a0)], [px + 1.6 * f_cos(a1), 0.05, pz + 1.6 * f_sin(a1)],
                    [px + 1.9 * f_cos(am), 0.1, pz + 1.9 * f_sin(am)], 0.16 * k, false, 0.1, seed + 20.0 + i as f32, PAL_DUST, 0.8 * k, 0.05);
    }
}

/// port: ken-look.lisp %KE-METEOR-TAIL — INSEKI-GIRI's falling blade: a yellow-white tail 1.8 m back from TIP against its cut
/// direction ST[D..], an ink edge under it.
fn meteor_tail(c: &mut Ctx, st: &[f32], d: usize, tip: [f32; 3], k: f32) {
    let l = 1.8f32;
    let p0 = [tip[0] - l * st[d], tip[1] - l * st[d + 1], tip[2] - l * st[d + 2]];
    fx_line(c, p0, tip, 0.02, 0.05, 0.04, 0.06, 0.7 * k, Mode::Alpha, 0.5, 0.7 * k);
    fx_line(c, p0, tip, 0.01, 1.0, 0.86, 0.45, 0.8 * k, Mode::Add, 0.36, 0.8 * k);
    fx_line(c, p0, tip, 0.005, 1.0, 0.97, 0.85, k, Mode::Add, 0.14, k);
}

/// port: ken-look.lisp KE-METEOR-IMPACT — the floor cratered at (X Z), a yellow ring (VFX-SHOCKWAVE :rgb (1 0.9 0.5): REIATSU), rubble,
/// a shake.
fn meteor_impact(c: &mut Ctx, shake: &mut Shake, x: f32, z: f32) {
    crack_add(&mut c.em(), x, z, 2.4);
    vfx_shockwave(&mut c.em(), x, z, 4.5, PAL_REIATSU);
    stage_debris(&mut c.em(), x, z, 10, 1.2);
    crate::fx::screen::shake_on(shake.0, shake.1, 0.35, 0.45);
}

/// port: ken-look.lisp KEN-SPECIAL-LOOK — the special ASs (move MV at frame SF, PREV the frame at the last draw; the tip tracked at O).
#[allow(clippy::too_many_arguments)]
fn special_look(c: &mut Ctx, shake: &mut Shake, st: &[f32], o: usize, mv: &duel_data::Move, sf: i64, prev: i64, tip: [f32; 3], p: [f32; 3], yaw: f32) {
    match mv.name.as_str() {
        "ke-s-sp1" => {
            if (4..=40).contains(&sf) {
                let k = f_min(1.0, (sf - 3) as f32 / 8.0) * f_min(1.0, (41 - sf) as f32 / 10.0);
                tornado(c, p[0], p[2], sf as f32, k, 600.0 + drawing_no(c.clock, 12.0));
            }
        }
        "ke-s-sp2" => {
            if (15..=21).contains(&sf) {
                meteor_tail(c, st, o + 3, tip, f_min(1.0, (sf - 14) as f32 / 3.0));
            }
            if prev < 20 && 20 <= sf {
                match mv.hits[0].vols.first().and_then(|v| ic_far(v, p, yaw, tip)) {
                    Some(far) => meteor_impact(c, shake, far[0], far[2]),
                    None => meteor_impact(c, shake, tip[0], tip[2]),
                }
            }
        }
        _ => {}
    }
}

/// port: ken-look.lisp KEN-DRAW (KIT-HOOK :draw, the Shikai and the Bankai) — the sword wind on each hit window of the move he is in, by
/// the level it shows (L now; a burst's the route's); the Bankai's always L3's with a BLOOD rim, its special SPs left to their own
/// looks.
#[allow(clippy::too_many_arguments)]
pub fn ken_draw(c: &mut Ctx, mut shake: Shake, m: &Match, e: Entity, sides: &Sides, md: &Model, st: &mut [f32; 32], kn: &Knobs, d: &Data) {
    let Some(f) = m.fighter.get(e) else { return };
    let o = 16 * f.side as usize;
    let bk = matches!(f.form, Form::Bankai | Form::Bankai2);
    let mv = (f.state == State::Move && f.phase == Some(Phase::Main))
        .then_some(f.mv)
        .flatten()
        .map(|id| duel_sim::fighter::mv(m, id))
        .filter(|mv| !(bk && matches!(mv.name.as_str(), "ke-kr-sp" | "ke-zh-sp")));
    let sf = if mv.is_some() { f.sf } else { -1 };
    let prev = ic_frame(st, o + 6, sf);
    let rim = if bk { PAL_BLOOD } else { PAL_INK };
    let Some(mv) = mv else { return };
    if md.weapon.is_empty() || md.alpha <= 0.5 {
        return;
    }
    let lv = if bk { 3 } else { 3.min(if mv.params.burst.is_some() { f.lv_cap } else { duel_sim::ken::hooks::lv(m, e) }) };
    let (p, yaw) = sides.at(m, e);
    let ji_wr = crate::rig::WEAPON_R;
    let tip = held_tip(&md.joints[ji_wr], d.weapons[md.weapon].len);
    track(st, o, o + 3, tip);
    special_look(c, &mut shake, st, o, mv, sf, prev, tip, p, yaw);
    if lv > 0 {
        for hw in &mv.hits {
            let (from, to) = (hw.from as i64, hw.to as i64);
            if let Some(v) = hw.vols.first()
                && from - 2 <= sf
                && sf < to + kn.wind_life
            {
                wind(c, &mut shake, kn, st, o + 3, v, p, yaw, tip, sf, from, to, lv, prev < from && from <= sf, rim);
            }
        }
    }
}

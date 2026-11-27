//! port: duel/lisp/vfx.lisp's lights and auras (LIGHTS-FLUSH, FLASH-LIGHT, N-OF, %BRUSH-AURA, %KIKON-AURA, %REIATSU-AURA, VFX-AURA,
//! VFX-BREAKER-RING), draw.lisp's aura tail of DRAW-FIGHTER (DRAW-AURA, ONI-AURA-K, RUSH-LIFT, BODY-LIFT) and hud-screens.lisp
//! AURA-CAP-UPDATE.
use super::shapes::*;
use super::{Ctx, Em, P_T_BLOB};
use duel_sim::cl::min_f32;
use duel_sim::components::{Burst, Phase, State};
use duel_sim::ecs::Entity;
use duel_sim::math::{f_cos, f_hypot, f_max, f_min, f_mod, f_sin, f_sqrt};
use duel_sim::state::Match;

/// vfx.lisp +LIVE-CAP+: no new VFX particles while the pool holds this many.
const LIVE_CAP: usize = 1150;

/// port: vfx.lisp LIGHTS-FLUSH — the 0.15 s hit flash while it lasts.
pub fn lights_flush(c: &mut Ctx) {
    let fl = c.fx.flash;
    let age = c.clock - fl[6];
    if -0.001 < age && age < 0.15 {
        c.light(fl[0], fl[1], fl[2], fl[3], fl[4], fl[5], 6.0, 2.0 * (1.0 - age / 0.15), 6);
    }
}

/// port: vfx.lisp FLASH-LIGHT — start the 0.15 s hit-flash light at (x y z).
pub fn flash_light(c: &mut Em, x: f32, y: f32, z: f32, r: f32, g: f32, b: f32) {
    c.fx.flash = [x, y, z, r, g, b, c.clock, 0.0];
}

/// port: vfx.lisp N-OF — particles to emit this frame for RATE a second (0 near the budget; one draw otherwise).
pub fn n_of(c: &mut Em, rate: f32, dt: f32) -> usize {
    if c.fx.live < LIVE_CAP {
        let fd = c.fx.knobs.fire_density;
        duel_sim::cl::floor_f32(rate * dt * fd + c.rnd()) as usize
    } else {
        0
    }
}

/// port: fx-shapes.lisp %T-BLOB (the arguments already evaluated, left to right).
#[allow(clippy::too_many_arguments)]
pub fn t_blob(c: &mut Em, x: f32, y: f32, z: f32, vx: f32, vy: f32, vz: f32, life: f32, size: f32, grav: f32, wob: f32, pal: f32) {
    c.fx.emit_a(P_T_BLOB, x, y, z, vx, vy, vz, life, size, grav, wob, 0.0, 0.0, pal);
}

/// port: vfx.lisp %BRUSH-AURA without ALL / SHEAR (Yamamoto's: M4): N tongues of PAL round the body at RAD, behind and at the sides
/// only, white core lines in the back ones when WHITE.
#[allow(clippy::too_many_arguments)]
fn brush_aura(c: &mut Ctx, x: f32, y: f32, z: f32, h: f32, k: f32, pal: f32, n: usize, rad: f32, w: f32, white: bool) {
    let (fp, pk, step) = (flow_ph(c.clock), toon_a(pal, 0.95 * k), 6.2831855 / n as f32);
    let e = c.cam.eye;
    let (ex, ez) = (e[0] - x, e[2] - z);
    let el = f_max(0.01, f_hypot(ex, ez));
    let wpal = PAL_HIT + 32.0 * ffloor(pal / 32.0);
    for i in 0..n {
        let f = i as f32;
        let ang = step * f + 0.3 * hash01(f, 1.3);
        let (cs, sn) = (f_cos(ang), f_sin(ang));
        let front = (ex * cs + ez * sn) / el;
        if front < 0.35 {
            let hh = h * (0.8 + 0.45 * flow01(c.clock, f, 3.7));
            let lean = 0.25 * (flow01(c.clock, f, 5.9) - 0.5);
            let (bx, bz, sd) = (x + rad * cs, z + rad * sn, -1.0 - f);
            toon_ribbon(c, [bx, y, bz], [lean * cs, hh, lean * sn], w, 0.0, &Toon { ph: f + fp, sway: 0.12, ..Toon::new(sd, pk) });
            if white && front < -0.4 {
                let wk = toon_a(wpal, 0.95 * k);
                toon_ribbon(c, [bx, y + 0.1, bz], [0.7 * lean * cs, 0.6 * hh, 0.7 * lean * sn], 0.035, 0.0, &Toon { wob: 0.1, segs: 3, ..Toon::new(sd, wk) });
            }
        }
    }
}

/// White flecks rising (the reiatsu / burst / evolution / Kikon kinds' N-OF loops): `n` blobs of RAD spread, rising VY0..VY1.
#[allow(clippy::too_many_arguments)]
fn flecks(c: &mut Em, n: usize, x: f32, y: f32, z: f32, h: f32, rad: f32, hy: [f32; 2], vy: [f32; 2], life: [f32; 2], size: [f32; 2], wob: f32, pal: f32) {
    for _ in 0..n {
        let px = x + c.rr(-rad, rad);
        let py = y + h * c.rr(hy[0], hy[1]);
        let pz = z + c.rr(-rad, rad);
        let v = c.rr(vy[0], vy[1]);
        let l = c.rr(life[0], life[1]);
        let s = c.rr(size[0], size[1]);
        t_blob(c, px, py, pz, 0.0, v, 0.0, l, s, 0.0, wob, pal);
    }
}

/// port: vfx.lisp VFX-AURA — the body aura KIND at the feet (x y z) of a fighter HEIGHT tall, presence K; DT the frame's effect
/// seconds. KIND is a VFX-AURA keyword's name (lower case) or a kit's :aura function name. Returns the look not ported, if any.
#[allow(clippy::too_many_arguments)]
pub fn vfx_aura(c: &mut Ctx, x: f32, y: f32, z: f32, height: f32, kind: &str, dt: f32, k: f32) -> Option<&'static str> {
    let h = height;
    let e = c.cam.eye;
    let (ex, ey, ez) = (e[0] - x, e[1] - (y + 0.6 * h), e[2] - z);
    let near = f_clamp((super::f_hypot3(ex, ey, ez) - 1.5) / 2.5, 0.35, 1.0);
    let ka = near * c.fx.aura_cap * f_clamp(k, 0.0, 1.0);
    let glass = c.fx.knobs.glass;
    match kind {
        "burst-white" | "burst-blue" | "burst-orange" => {
            let kc = f_clamp(k, 0.0, 1.0);
            let pal = match kind {
                "burst-white" => PAL_HIT,
                "burst-blue" => PAL_BLUE,
                _ => PAL_FIRE,
            };
            brush_aura(c, x, y, z, 0.95 * h, kc, pal + TOON_FLAME, 8, 0.46, 0.15, true);
            let r = 0.7 + 0.05 * flow01(c.clock, 0.0, 4.1);
            tring(c, x, y, z, r, 0.05, pal + TOON_FLAME, 0.9 * kc, 0.0, 32);
            let n = n_of(&mut c.em(), 8.0, dt);
            flecks(&mut c.em(), n, x, y, z, h, 0.4, [0.1, 0.8], [1.2, 2.2], [0.3, 0.5], [0.02, 0.035], 0.1, pal);
        }
        "evolution" => {
            brush_aura(c, x, y, z, 0.85 * h, 0.8 * f_clamp(k, 0.0, 1.0), PAL_STEEL + TOON_FLAME, 5, 0.33, 0.09, false);
            let n = n_of(&mut c.em(), 8.0, dt);
            flecks(&mut c.em(), n, x, y, z, h, 0.35, [0.1, 0.8], [0.8, 1.6], [0.4, 0.7], [0.015, 0.03], 0.1, PAL_HIT);
        }
        "reiatsu" | "nozarashi" | "nomihose" => {
            let (gi, awake) = match kind {
                "reiatsu" => (0, false),
                "nozarashi" => (1, true),
                _ => (2, true),
            };
            reiatsu_aura(c, x, y, z, if kind == "nomihose" { 1.6 * h } else { h }, ka, awake, glass[gi]);
            let rate = match kind {
                "nomihose" => 22.0,
                "nozarashi" => 12.0,
                _ => 5.0,
            };
            let n = n_of(&mut c.em(), rate, dt);
            flecks(&mut c.em(), n, x, y, z, h, 0.45, [0.1, 0.8], [1.2, 2.4], [0.3, 0.6], [0.015, 0.03], 0.1, PAL_HIT);
        }
        "bound" => {
            let c = &mut c.em();
            let n = n_of(c, 10.0, dt);
            for _ in 0..n {
                let px = x + c.rr(-0.35, 0.35);
                let pz = z + c.rr(-0.35, 0.35);
                let vx = c.rr(-0.2, 0.2);
                let vy = c.rr(0.4, 0.9);
                let vz = c.rr(-0.2, 0.2);
                let l = c.rr(0.8, 1.2);
                let s = c.rr(0.04, 0.07);
                t_blob(c, px, 0.1, pz, vx, vy, vz, l, s, -0.1, 0.2, PAL_ASH);
            }
        }
        "oni" => {
            let kc = f_clamp(k, 0.0, 1.0);
            let (gb, gi) = (32.0 * glass[3] as f32, 32.0 * glass[4] as f32);
            brush_aura(c, x, y, z, 1.35 * h, kc, PAL_INK + gi + TOON_FLAME, 9, 0.5, 0.2, false);
            brush_aura(c, x, y, z, 1.05 * h, kc, PAL_BLOOD + gb + TOON_FLAME, 9, 0.4, 0.16, true);
            let n = n_of(&mut c.em(), 18.0 * kc, dt);
            flecks(&mut c.em(), n, x, y, z, h, 0.4, [0.1, 1.2], [1.5, 3.0], [0.4, 0.7], [0.02, 0.04], 0.15, PAL_BLOOD);
            c.light(x, y + 1.2, z, 1.0, 0.15, 0.12, 5.0, 0.9 * kc, 8);
        }
        "kikon" => {
            let (h2, k2) = (0.95 * h, f_clamp(k, 0.3, 1.0));
            brush_aura(c, x, y, z, h2, k2, PAL_BLOOD + TOON_FLAME, 7, 0.5, 0.2, true);
            let r = 0.72 + 0.06 * flow01(c.clock, 0.0, 8.3);
            tring(c, x, y, z, r, 0.07, PAL_BLOOD + TOON_FLAME, 0.95 * k2, 0.0, 32);
            let n = n_of(&mut c.em(), 10.0, dt);
            flecks(&mut c.em(), n, x, y, z, h, 0.4, [0.2, 0.9], [1.0, 2.0], [0.4, 0.7], [0.025, 0.045], 0.2, PAL_BLOOD);
            c.light(x, y + 1.0, z, 1.0, 0.15, 0.2, 4.5, 1.0, 6);
        }
        "breaker" => {
            let pk = f_clamp(0.55 + 0.45 * k, 0.0, 1.0);
            let gr = 1.0 + 0.25 * f_clamp(k - 1.0, 0.0, 1.0);
            brush_aura(c, x, y, z, 1.1 * h * gr, pk, PAL_INK, 7, 0.5, 0.2, false);
            brush_aura(c, x, y, z, 0.9 * h * gr, pk, PAL_REIATSU, 7, 0.4, 0.16, true);
            let n = n_of(&mut c.em(), 14.0 * pk, dt);
            flecks(&mut c.em(), n, x, y, z, h, 0.4, [0.2, 0.9], [1.0, 2.0], [0.3, 0.6], [0.03, 0.05], 0.2, PAL_BLOOD);
            c.light(x, y + 1.0, z, 1.0, 0.3, 0.2, 5.0, 1.2 * pk, 5);
        }
        "ICHIGO-AURA-BASE" => {} // (its afterimages: the caller's, `ichigo_aura_base`)
        "ICHIGO-AURA-KESSA" => {} // task 7: ICHIGO-AURA-KESSA reads ic-joint (posed joints); quiet-2395 compares fu,p,dq until Task 7
        _ => return Some("a Yamamoto / Hisagi aura (vfx.lisp VFX-AURA :hellfire / :garb, a kit's aura function: M4)"),
    }
    None
}

/// port: vfx.lisp %REIATSU-AURA — Kenpachi's yellow brush flame (AWAKE: the Nozarashi's 9 wider tongues, the inner white ones, the
/// ring and the light); GLASS the see-through level.
#[allow(clippy::too_many_arguments)]
fn reiatsu_aura(c: &mut Ctx, x: f32, y: f32, z: f32, h: f32, k: f32, awake: bool, glass: i64) {
    let g = 32.0 * glass as f32 + TOON_FLAME;
    if awake {
        brush_aura(c, x, y, z, 1.05 * h, k, PAL_REIATSU + g, 9, 0.5, 0.19, true);
        brush_aura(c, x, y, z, 0.7 * h, k, PAL_HIT + g, 3, 0.3, 0.06, false);
        let r = 0.8 + 0.06 * flow01(c.clock, 0.0, 8.3);
        tring(c, x, y, z, r, 0.06, PAL_REIATSU + g, 0.95 * k, 0.0, 32);
        c.light(x, y + 1.2, z, 1.0, 0.8, 0.25, 5.0, 0.7, 8);
    } else {
        brush_aura(c, x, y, z, 0.8 * h, k, PAL_REIATSU + g, 7, 0.45, 0.16, true);
    }
}

/// port: vfx.lisp VFX-BREAKER-RING — a steady BLOOD ring and an INK ripple every 0.4 s under a Breaker.
pub fn vfx_breaker_ring(c: &mut Ctx, x: f32, z: f32, age: f32) {
    let sa = sage(c.clock, age, 2.0);
    let f = f_mod(sa, 0.4) / 0.4;
    let dr = drawing_no(c.clock, 12.0);
    tring(c, x, 0.0, z, 0.8, 0.08, PAL_BLOOD, 0.95, ((duel_sim::cl::floor_f32(dr) as i32) % 5) as f32, 24);
    tring(c, x, 0.0, z, 0.95 + 1.4 * f, 0.05, PAL_INK, 0.95 * (1.0 - f), 3.0, 24);
}

/// port: draw.lisp ONI-AURA-K — the oni pillar's presence for side I, eased toward `*oni-k-attack*` while ATTACKING.
fn oni_aura_k(c: &mut Ctx, i: usize, attacking: bool, rdt: f32) -> f32 {
    let k = c.fx.oni_k[i];
    let want = if attacking { c.fx.knobs.oni_k_attack } else { 1.0 };
    c.fx.oni_k[i] = k + (want - k) * min_f32(1.0, 10.0 * rdt);
    c.fx.oni_k[i]
}

/// port: draw.lisp DRAW-AURA — side I's body AURA (crossfaded over 350 / 300 ms when it changes), height H, presence K.
#[allow(clippy::too_many_arguments)]
fn draw_aura<'d>(c: &mut Ctx<'_, 'd>, i: usize, aura: Option<&'d str>, x: f32, y: f32, z: f32, h: f32, rdt: f32, k: f32) -> Option<&'static str> {
    if aura != c.fx.aura_now[i] {
        (c.fx.aura_was[i], c.fx.aura_now[i], c.fx.aura_t[i]) = (c.fx.aura_now[i], aura, c.clock);
    }
    let ms = (duel_sim::cl::floor_f32(1000.0 * (c.clock - c.fx.aura_t[i])) as i32).min(100000);
    let mut un = None;
    if let Some(was) = c.fx.aura_was[i]
        && ms < 350
    {
        un = un.or(vfx_aura(c, x, y, z, h, was, rdt, k * (1.0 - ms as f32 / 350.0)));
    }
    if let Some(a) = aura {
        un = un.or(if ms >= 300 {
            vfx_aura(c, x, y, z, h, a, rdt, k)
        } else {
            vfx_aura(c, x, y, z, h * (1.0 + 0.35 * (1.0 - ms as f32 / 300.0)), a, rdt, k * min_f32(1.0, 0.2 + ms as f32 / 120.0))
        });
    }
    un
}

/// The scene's reads of a fighter for its aura tail.
pub struct AuraIn<'a> {
    pub e: Entity,
    /// The drawn feet (SLOW-DRAW's place) and the model's body, alpha and `*aura-off*` (a cinematic's: task 8).
    pub p: [f32; 3],
    pub body: &'a str,
    pub alpha: f32,
    pub aura_off: bool,
}

/// port: draw.lisp DRAW-FIGHTER's aura tail (its lines 247-275): the form's aura, the bind's ash, EVOLUTION, a burst, the Breaker,
/// the Kikon rush, with the Y DRAW-FIGHTER computed (RUSH-LIFT, BODY-LIFT). RDT the frame's effect seconds.
pub fn fighter_auras(c: &mut Ctx, m: &Match, a: &AuraIn, rdt: f32) -> Option<&'static str> {
    let Some(f) = m.fighter.get(a.e) else { return None };
    let kit = duel_sim::fighter::kit_of(m, a.e);
    let mv = duel_sim::fighter::current_move(f).map(|id| duel_sim::fighter::mv(m, id));
    let look = mv.filter(|mv| mv.kind == "kikon" || f.phase == Some(Phase::Follow)).and_then(|mv| mv.params.look.as_deref());
    let rush_dashing = match f.phase {
        Some(Phase::Dash) => true,
        Some(Phase::Follow) => f.dist > m.knobs.kikon_trigger + 0.05,
        _ => false,
    };
    let flashing = look == Some("flash-step") && rush_dashing;
    let hh = m.data.bodies.get(a.body).map_or(0.0, |b| b.hurt_h);
    // ponytail: RUSH-LIFT is 0 (no in-scope move has :lift); BODY-LIFT is the kit's :lift on its own body (0 in every in-scope kit);
    // DRAW-SCALE-OF is a cinematic giant's (task 8: 1 here).
    let body_lift = if kit.lift != 0.0 && kit.body == a.body { kit.lift } else { 0.0 };
    let (x, y, z) = (a.p[0], a.p[1] + 0.0 + body_lift, a.p[2]);
    let side = f.side as usize;
    let mut un = None;
    if !(flashing || a.alpha <= 0.0 || a.aura_off) {
        let aura = kit.aura.as_deref();
        if aura == Some("ICHIGO-AURA-BASE") {
            un = un.or(ichigo_aura_base(f, mv)); // (VFX-AURA's funcall of the kit's aura function)
        }
        let k = if look == Some("charge") && f.phase != Some(Phase::Main) {
            1.5
        } else if mv.is_some_and(|mv| mv.kind == "kikon") && aura == Some("oni") {
            0.15
        } else if aura == Some("oni") {
            let attacking = mv.is_some_and(|mv| f.phase == Some(Phase::Main) && matches!(mv.kind.as_str(), "quick" | "flash" | "sp"));
            oni_aura_k(c, side, attacking, rdt)
        } else {
            1.0
        };
        un = un.or(draw_aura(c, side, aura, x, y, z, 1.1 * hh, rdt, k));
    }
    if f.state == State::Stun && f.phase == Some(Phase::Bind) {
        un = un.or(vfx_aura(c, x, y, z, hh, "bound", rdt, 1.0));
    }
    let g = m.gauges.get(a.e);
    if g.is_some_and(|g| g.evolution) {
        un = un.or(vfx_aura(c, x, y, z, hh, "evolution", rdt, 0.5));
    }
    let bm = g.and_then(|g| g.burst);
    if let Some(bm) = bm
        && a.alpha > 0.0
        && f.state != State::Cine
    {
        let kind = match bm {
            Burst::White => "burst-white",
            Burst::Blue => "burst-blue",
            _ => "burst-orange",
        };
        un = un.or(vfx_aura(c, x, y, z, hh, kind, rdt, 1.0));
    }
    if bm.is_none() && g.is_some_and(|g| g.awake_regen > 0) && a.alpha > 0.0 && f.state != State::Cine {
        un = un.or(vfx_aura(c, x, y, z, hh, "burst-white", rdt, 0.6));
    }
    if let Some(mv) = mv
        && mv.kind == "breaker"
    {
        if f.phase != Some(Phase::Main) {
            un = un.or(vfx_aura(c, x, y, z, hh, "breaker", rdt, if f.phase == Some(Phase::Dash) { 1.0 } else { 0.5 }));
            let age = c.clock;
            vfx_breaker_ring(c, x, z, age);
        }
        if f.phase == Some(Phase::Main) && (f.sf as i32) < mv.s {
            un = un.or(vfx_aura(c, x, y, z, hh, "breaker", rdt, 1.0 + f.sf as f32 / mv.s as f32));
        }
    }
    if let Some(mv) = mv
        && mv.kind == "kikon"
        && f.state == State::Move
        && !flashing
        && (f.phase != Some(Phase::Main) || (f.sf as i32) < mv.s)
    {
        un = un.or(vfx_aura(c, x, y, z, hh, "kikon", rdt, 1.0));
    }
    un
}

/// port: ichigo-look.lisp ICHIGO-AURA-BASE — SOGA's and TSUKIWATARI's flash steps start an ink afterimage every 4 f of their startup.
/// The afterimage is DRAW-FIGHTER's ghost (task 7): reaching it here is a look not ported yet.
fn ichigo_aura_base(f: &duel_sim::components::Fighter, mv: Option<&duel_data::Move>) -> Option<&'static str> {
    let mv = mv?;
    (matches!(mv.name.as_str(), "IC-SOGA" | "IC-TSUKI-DASH") && f.phase == Some(Phase::Main) && (f.sf as i32) < mv.s && f.sf % 4 == 0)
        .then_some("Ichigo's flash-step afterimage (draw.lisp START-GHOST: task 7)")
}

/// port: hud-screens.lisp AURA-CAP-UPDATE — `*aura-cap*` for the next frame: 0.5 within 2.5 m, 1 from 3.5 m (P / Q the drawn places
/// when both fighters are alive).
pub fn aura_cap_update(cap: &mut f32, pq: Option<([f32; 3], [f32; 3])>) {
    *cap = match pq {
        Some((p, q)) => {
            let d = f_sqrt(crate::draw::camera::pow2(p[0] - q[0]) + crate::draw::camera::pow2(p[2] - q[2]));
            f_max(0.5, f_min(1.0, 0.5 + 0.5 * (d - 2.5)))
        }
        None => 1.0,
    };
}

// ---------------------------------------------------------------- sword trails and the smear (DRAW-FIGHTER's: task 7 calls them)

/// fx.lisp +TRAIL-N+: a trail holds this many base / tip samples, oldest first; [60] the count.
pub const TRAIL_N: usize = 10;
pub type Trail = [f32; 6 * TRAIL_N + 1];

/// port: fx.lisp %TRAIL-DROP — drop the oldest of N samples.
fn trail_drop(tr: &mut Trail, n: usize) {
    tr.copy_within(6..6 * n, 0);
    tr[6 * TRAIL_N] = (n - 1) as f32;
}

/// port: fx.lisp TRAIL-PUSH — one base / tip sample, the oldest dropped when full.
pub fn trail_push(tr: &mut Trail, b: [f32; 3], t: [f32; 3]) {
    let mut n = duel_sim::cl::floor_f32(tr[6 * TRAIL_N]) as usize;
    if n >= TRAIL_N {
        trail_drop(tr, n);
        n = TRAIL_N - 1;
    }
    tr[6 * n..6 * n + 6].copy_from_slice(&[b[0], b[1], b[2], t[0], t[1], t[2]]);
    tr[6 * TRAIL_N] = (n + 1) as f32;
}

/// port: fx.lisp TRAIL-DECAY — drop the oldest sample.
pub fn trail_decay(tr: &mut Trail) {
    let n = duel_sim::cl::floor_f32(tr[6 * TRAIL_N]) as usize;
    if n > 0 {
        trail_drop(tr, n);
    }
}

/// port: vfx.lisp VFX-SMEAR — the comet crescent through the blade's 0.7 points of the last drawing's samples (FX-SMEAR-CAPTURE! into
/// SM: x0 y0 z0 x1 y1 z1 bx by bz, half-width, drawing, presence). LOOK 0 FIRE, 1 REIATSU, 2 the charcoal wash; 3-5 are Yamamoto's (M4).
pub fn vfx_smear(c: &mut Ctx, tr: &Trail, sm: &mut [f32; 12], look: i32) -> Option<&'static str> {
    let n = duel_sim::cl::floor_f32(tr[6 * TRAIL_N]) as usize;
    let dr = drawing_no(c.clock, 12.0);
    if sm[10] != dr {
        (sm[10], sm[11]) = (dr, 0.0);
        if n >= 3 {
            let i0 = n.saturating_sub(5);
            let (im, i1) = ((i0 + n - 1) / 2, n - 1);
            let (o0, om, o1) = (6 * i0, 6 * im, 6 * i1);
            for k in 0..3 {
                let u = 0.7f32;
                let p0 = tr[o0 + k] + u * (tr[o0 + k + 3] - tr[o0 + k]);
                let pm = tr[om + k] + u * (tr[om + k + 3] - tr[om + k]);
                let p1 = tr[o1 + k] + u * (tr[o1 + k + 3] - tr[o1 + k]);
                (sm[k], sm[k + 3], sm[k + 6]) = (p0, p1, 2.0 * pm - 0.5 * (p0 + p1));
            }
            let len = super::f_hypot3(tr[o1 + 3] - tr[o1], tr[o1 + 4] - tr[o1 + 1], tr[o1 + 5] - tr[o1 + 2]);
            (sm[9], sm[11]) = (0.33 * len, if n >= 5 { 0.98 } else { 0.6 });
        }
    }
    if look >= 3 {
        return Some("a Yamamoto smear (vfx.lisp VFX-SMEAR looks 3-5: M4)");
    }
    if sm[11] > 0.0 {
        let seed = if look == 2 { 1000.0 + dr } else { 5.0 + dr };
        let pal = match look {
            0 => PAL_FIRE,
            1 => PAL_REIATSU,
            _ => PAL_BLACK_SMOKE,
        };
        fx_crescent(c, [sm[0], sm[1], sm[2]], [sm[3], sm[4], sm[5]], [sm[6], sm[7], sm[8]], sm[9], true, 0.06, seed, pal, sm[11], 0.15);
    }
    None
}

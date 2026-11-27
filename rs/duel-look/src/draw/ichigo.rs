//! port: duel/lisp/ichigo-look.lisp's hooks on the posed body (docs/bevy/M3A_NOTES.md §7): the Shikai's cloak (ICHIGO-CLOAK-POSE with
//! hem-spring.lisp %YA-HEM-POSE / %YA-HEM-STEP), ICHIGO-DRAW (the crescent edge and the ground contact, the charged blades, KESSA's
//! blood chains and red wisps), the auras (ICHIGO-AURA-BASE / -KESSA), and tip-track.lisp's helpers Kenpachi's look shares
//! (%IC-FRAME, %IC-HELD-TIP, %IC-TRACK, %IC-FAR). Cosmetic: reads the drawn places, draws `CosRng` only where the Lisp calls RND01.
use super::fighter::{start_ghost, AuraWorld, Knobs as FKnobs, Sides};
use crate::anim::Anim;
use crate::fx::crack::{stage_debris, stage_mark};
use crate::fx::shapes::{drawing_no, f_clamp, fx_crescent, fx_shard, hash01, tongue, PAL_BLACK_SMOKE, PAL_BLOOD, PAL_EMBER, PAL_HIT, PAL_INK, PAL_REIATSU, TOON_FLAME};
use crate::fx::stamps::f_atan2;
use crate::fx::vfx::{t_blob, trail_decay, trail_push, vfx_smear, Trail, TRAIL_N};
use crate::fx::{f_hypot3, Ctx};
use crate::rig::{joint_index, joint_point, Mat4, NJ};
use crate::scene::Model;
use duel_data::Data;
use duel_sim::components::{Phase, State};
use duel_sim::ecs::Entity;
use duel_sim::math::{f_cos, f_max, f_min, f_sin, f_sqrt, fwd_x, fwd_z};
use duel_sim::state::Match;

/// ichigo-look.lisp's and hem-spring.lisp's knobs (tuning.json), the chain / wisp roots resolved to joints.
pub struct Knobs<'d> {
    /// `*ic-edge-moves*`: (move, the hit windows the short blade cuts), `*ic-ground-moves*`, `*ic-edge-w*`, `*ic-edge-bulge*`.
    pub edge_moves: Vec<(&'d str, Vec<i64>)>,
    pub ground_moves: Vec<&'d str>,
    pub edge_w: f32,
    pub edge_bulge: f32,
    /// `*ya-hem-k*` `*ya-hem-c*` `*ya-hem-drag*` `*ya-hem-turn*` `*ya-hem-max*`.
    pub hem: [f32; 5],
    /// `*ic-chain-roots*`, `*ic-wisp-roots*`: (joint, local point, the neck's).
    pub chain_roots: Vec<(usize, [f32; 3])>,
    pub wisp_roots: Vec<(usize, [f32; 3], bool)>,
    /// `*ic-mist-tint*` (hexc #x1E1E1E), `*ic-mist-rim*` (rim-vec #xFFFFFF 1.6), `*ic-clone-rim*` (rim-vec #xD0101C 1.4): the file's
    /// load-time forms.
    pub mist_tint: [f32; 3],
    pub mist_rim: [f32; 3],
    pub clone_rim: [f32; 3],
}

impl<'d> Knobs<'d> {
    pub fn new(d: &'d Data) -> Knobs<'d> {
        let t = |k: &str| d.tuning.get(k).unwrap_or_else(|| panic!("tuning {k}"));
        let f = |k: &str| t(k).as_f64().unwrap_or_else(|| panic!("tuning {k}")) as f32;
        let roots = |k: &str| -> Vec<(usize, [f32; 3], bool)> {
            t(k).as_array()
                .unwrap()
                .iter()
                .map(|r| {
                    let r = r.as_array().unwrap();
                    let n = r[0].as_str().unwrap();
                    (joint_index(&d.rig, n), [1, 2, 3].map(|i| r[i].as_f64().unwrap() as f32), n == "neck")
                })
                .collect()
        };
        Knobs {
            edge_moves: t("*IC-EDGE-MOVES*")
                .as_array()
                .unwrap()
                .iter()
                .map(|r| {
                    let r = r.as_array().unwrap();
                    (r[0].as_str().unwrap(), r[1..].iter().map(|x| x.as_i64().unwrap()).collect())
                })
                .collect(),
            ground_moves: t("*IC-GROUND-MOVES*").as_array().unwrap().iter().map(|x| x.as_str().unwrap()).collect(),
            edge_w: f("*IC-EDGE-W*"),
            edge_bulge: f("*IC-EDGE-BULGE*"),
            hem: ["*YA-HEM-K*", "*YA-HEM-C*", "*YA-HEM-DRAG*", "*YA-HEM-TURN*", "*YA-HEM-MAX*"].map(f),
            chain_roots: roots("*IC-CHAIN-ROOTS*").into_iter().map(|r| (r.0, r.1)).collect(),
            wisp_roots: roots("*IC-WISP-ROOTS*"),
            mist_tint: crate::draw::frame::hexc(0x1E1E1E),
            mist_rim: super::fighter::rim_vec(0xFFFFFF, 1.6),
            clone_rim: super::fighter::rim_vec(0xD0101C, 1.4),
        }
    }
}

/// ichigo-look.lisp's per-side state: `*ic-look*` (the cloak spring, the tips, their cut directions, the move frame), `*ic-charged*`,
/// `*ic-charge-trails*`, `*ic-charge-smears*`, and `*ic-clone-anim*` / `*ic-clone-joints*` (a clone's or echo's pose).
pub struct IcState<'d> {
    pub look: [f32; 64],
    pub charged: [i64; 2],
    pub trails: [Trail; 4],
    pub smears: [[f32; 12]; 4],
    pub clone_anim: [Anim<'d>; 2],
    pub clone_joints: [[Mat4; NJ]; 2],
}

impl Default for IcState<'_> {
    fn default() -> Self {
        Self::new()
    }
}

impl IcState<'_> {
    pub fn new() -> Self {
        IcState {
            look: [0.0; 64],
            charged: [0; 2],
            trails: [[0.0; 6 * TRAIL_N + 1]; 4],
            smears: [[0.0; 12]; 4],
            clone_anim: [Anim::default(), Anim::default()],
            clone_joints: [[[0.0; 16]; NJ]; 2],
        }
    }
}

// ---------------------------------------------------------------- tip-track.lisp

/// port: tip-track.lisp %IC-FRAME — ST[I] = the move frame SF; the frame it held before.
pub fn ic_frame(st: &mut [f32], i: usize, sf: i64) -> i64 {
    let prev = duel_sim::cl::floor_f32(st[i]);
    st[i] = sf as f32;
    prev
}

/// port: tip-track.lisp %IC-HELD-TIP — the held weapon's tip: :weapon-r's point (0 0 -LEN).
pub fn held_tip(wr: &Mat4, len: f32) -> [f32; 3] {
    [0, 1, 2].map(|i| wr[12 + i] - len * wr[8 + i])
}

/// port: tip-track.lisp %IC-TRACK — ST[O..O+2] the tip's last point; ST[D..D+2] the unit direction it last moved in (kept while it
/// stands, or across a jump over 1.5 m).
pub fn track(st: &mut [f32], o: usize, d: usize, tip: [f32; 3]) {
    let [x, y, z] = tip;
    let (dx, dy, dz) = (x - st[o], y - st[o + 1], z - st[o + 2]);
    let l = f_hypot3(dx, dy, dz);
    if l > 0.01 && l < 1.5 {
        (st[d], st[d + 1], st[d + 2]) = (dx / l, dy / l, dz / l);
    }
    (st[o], st[o + 1], st[o + 2]) = (x, y, z);
}

/// port: tip-track.lisp %IC-FAR — the far point of hit volume V for a fighter at P facing YAW: an arc's rim on TIP's bearing, a
/// capsule's end, a sphere's far side; its height the tip's within 0.1-1.5 m (a sphere's: its centre). None for another kind.
pub fn ic_far(v: &[f32; 6], p: [f32; 3], yaw: f32, tip: [f32; 3]) -> Option<[f32; 3]> {
    let (ty, k, px, pz, fx, fz) = (f_clamp(tip[1], 0.1, 1.5), v[0], p[0], p[2], -f_sin(yaw), -f_cos(yaw));
    if k < 0.5 {
        let (mut bx, mut bz) = (tip[0] - px, tip[2] - pz);
        let (l, r) = (f_sqrt(bx * bx + bz * bz), v[1]);
        if l < 0.05 {
            (bx, bz) = (fx, fz);
        } else {
            (bx, bz) = (bx / l, bz / l);
        }
        Some([px + r * bx, ty, pz + r * bz])
    } else if k < 1.5 {
        let (c, sn) = (f_cos(v[5]), f_sin(v[5]));
        let (ux, uz, b) = (fx * c + fz * sn, fz * c - fx * sn, v[2]);
        Some([px + b * ux, ty, pz + b * uz])
    } else if k < 2.5 {
        let d = v[1] + v[3];
        Some([px + d * fx, v[2], pz + d * fz])
    } else {
        None
    }
}

// ---------------------------------------------------------------- the cloak (hem-spring.lisp)

/// port: hem-spring.lisp %YA-HEM-POSE — record the obi's world point and the pelvis heading in ST (offset O); ON: swing the pelvis
/// matrix about the obi by ST's angles plus a slow breath (CLOCK the fx clock).
fn hem_pose(jm: &mut [Mat4; NJ], st: &mut [f32], o: usize, on: bool, clock: f32) {
    let p = jm[0];
    st[o + 11] = 0.06 * p[4] + p[12];
    st[o + 12] = 0.06 * p[5] + p[13];
    st[o + 13] = 0.06 * p[6] + p[14];
    st[o + 14] = f_atan2(p[8], p[10]);
    if on {
        let yl = st[o + 8];
        let back = st[o + 4] + 0.02 * f_sin(1.3 * clock);
        let side = st[o + 6] + 0.012 * f_sin(0.9 * clock);
        let mut r = [0.0f32; 16];
        crate::rig::euler(&mut r, 0.0, 0.0, 0.0, yl, -back, side, 1.0);
        (r[12], r[13], r[14]) = (-0.06 * r[4], 0.06 - 0.06 * r[5], -0.06 * r[6]);
        jm[0] = crate::draw::camera::m4_mul(&jm[0], &r);
    }
}

/// port: hem-spring.lisp %YA-SPRING — the angle ST[I] (rate ST[I+1]) toward TGT over DT s, capped at `*ya-hem-max*`.
fn spring(st: &mut [f32], i: usize, tgt: f32, dt: f32, h: &[f32; 5]) {
    let a = st[i];
    let r = st[i + 1] + dt * (h[0] * (tgt - a) - h[1] * st[i + 1]);
    st[i + 1] = r;
    st[i] = f_clamp(a + dt * r, -h[4], h[4]);
}

/// port: hem-spring.lisp %YA-HEM-STEP — step the hem spring at O by DT effect seconds (substeps of <= 1/60 s): it trails the obi's
/// travel and lags the pelvis's turn; a jump over 1.5 m re-primes it.
fn hem_step(st: &mut [f32], o: usize, dt: f32, h: &[f32; 5]) {
    if dt <= 0.0 {
        return;
    }
    let (x, y, z, hd) = (st[o + 11], st[o + 12], st[o + 13], st[o + 14]);
    let (dx, dy, dz) = (x - st[o], y - st[o + 1], z - st[o + 2]);
    let mut dh = hd - st[o + 3];
    if dh > 3.1415927 {
        dh -= 6.2831855;
    }
    if dh < -3.1415927 {
        dh += 6.2831855;
    }
    if st[o + 10] < 0.5 || f_hypot3(dx, dy, dz) > 1.5 {
        st[o + 10] = 1.0;
        st[o + 4..o + 10].fill(0.0);
    } else {
        let (bx, bz) = (f_sin(hd), f_cos(hd));
        let vf = -(dx * bx + dz * bz) / dt;
        let vr = (dx * bz - dz * bx) / dt;
        let w = dh / dt;
        let (drag, mx) = (h[2], h[4]);
        let tb = f_clamp(drag * vf, -mx, mx);
        let ts = f_clamp(-drag * vr, -mx, mx);
        let ty = f_clamp(-h[3] * w, -0.3, 0.3);
        let n = duel_sim::cl::floor_f32(0.999 + 60.0 * dt).clamp(1, 4);
        let sdt = dt / n as f32;
        for _ in 0..n {
            spring(st, o + 4, tb, sdt, h);
            spring(st, o + 6, ts, sdt, h);
            spring(st, o + 8, ty, sdt, h);
        }
    }
    (st[o], st[o + 1], st[o + 2], st[o + 3]) = (x, y, z, hd);
}

/// port: ichigo-look.lisp ICHIGO-CLOAK-POSE (KIT-HOOK :pose, the Shikai) — the cloak's swing on the posed pelvis.
pub fn cloak_pose(jm: &mut [Mat4; NJ], ic: &mut IcState, side: usize, clock: f32) {
    hem_pose(jm, &mut ic.look, 32 * side, true, clock);
}

// ---------------------------------------------------------------- the looks

/// port: ichigo-look.lisp VFX-IC-CHAIN — a blood chain from P0 to P1: ink links (shards turned alternately), a BLOOD core, presence K.
pub fn vfx_ic_chain(c: &mut Ctx, p0: [f32; 3], p1: [f32; 3], k: f32) {
    let ([x0, y0, z0], [x1, y1, z1]) = (p0, p1);
    let (dx, dy, dz) = (x1 - x0, y1 - y0, z1 - z0);
    let l = f_max(0.01, f_hypot3(dx, dy, dz));
    let (ux, uy, uz) = (dx / l, dy / l, dz / l);
    let n = duel_sim::cl::floor_f32(l / 0.14).clamp(2, 40);
    let dr = drawing_no(c.clock, 12.0);
    for i in 0..n {
        let u = (0.5 + i as f32) / n as f32;
        let (px, py, pz) = (x0 + u * dx, y0 + u * dy, z0 + u * dz);
        fx_shard(c, px, py, pz, ux, uy, uz, 0.16, if i % 2 == 0 { 0.045 } else { 0.02 }, 0.05, i as f32 + 400.0 + dr, PAL_INK, k, 0.1);
        if i % 2 == 0 {
            fx_shard(c, px, py, pz, ux, uy, uz, 0.08, 0.012, 0.05, i as f32 + 460.0, PAL_BLOOD, k, 0.14);
        }
    }
}

/// port: ichigo-look.lisp %IC-EDGE — the crescent edge from TIP toward FAR (G the fraction of the way, K its presence), bulging along
/// the cut direction ST[D..D+2]: an ink lens, a white rim (BLOOD: a BLOOD hairline) on its leading side.
#[allow(clippy::too_many_arguments)]
fn ic_edge(c: &mut Ctx, kn: &Knobs, st: &[f32], d: usize, tip: [f32; 3], far: [f32; 3], g: f32, k: f32, blood: bool) {
    let [x0, y0, z0] = tip;
    let (x1, y1, z1) = (x0 + g * (far[0] - x0), y0 + g * (far[1] - y0), z0 + g * (far[2] - z0));
    let (cx, cy, cz) = (x1 - x0, y1 - y0, z1 - z0);
    let span = f_hypot3(cx, cy, cz);
    if span <= 0.15 {
        return;
    }
    let (ux, uy, uz) = (cx / span, cy / span, cz / span);
    let (dx, dy, dz) = (st[d], st[d + 1], st[d + 2]);
    let du = dx * ux + dy * uy + dz * uz;
    let (px, py, pz) = (dx - du * ux, dy - du * uy, dz - du * uz);
    let b = kn.edge_bulge * span;
    let w = f_clamp(kn.edge_w * span, 0.08, 0.2);
    let (mx, my, mz) = (0.5 * (x0 + x1), 0.5 * (y0 + y1), 0.5 * (z0 + z1));
    let dr = drawing_no(c.clock, 12.0);
    fx_crescent(c, [x0, y0, z0], [x1, y1, z1], [mx + b * px, f_max(0.05, my + b * py), mz + b * pz], w, false, 0.05, 330.0 + dr, PAL_INK, k, 0.1);
    let a = 0.6 * w;
    fx_crescent(
        c,
        [x0 + a * px, y0 + a * py, z0 + a * pz],
        [x1 + a * px, y1 + a * py, z1 + a * pz],
        [mx + (b + a) * px, f_max(0.05, my + (b + a) * py), mz + (b + a) * pz],
        if blood { 0.12 * w } else { 0.25 * w },
        false,
        0.03,
        340.0 + dr,
        if blood { PAL_BLOOD } else { PAL_HIT },
        k,
        0.16,
    );
}

/// port: ichigo-look.lisp %IC-HIT-LOOK — one hit window's looks at move frame SF (window FROM-TO, volume V; the feet P facing YAW):
/// the crescent edge from TIP grown over the 3 f to FROM, fading over the 4 f after TO; GROUND: the plaza's crack, rubble and a shake
/// where TIP meets it (under 0.4 m), else at the volume's far point.
#[allow(clippy::too_many_arguments)]
fn ic_hit_look(c: &mut Ctx, shake: &mut (&mut [f32; 8], f32), kn: &Knobs, st: &[f32], d: usize, v: &[f32; 6], p: [f32; 3], yaw: f32, tip: [f32; 3], sf: i64, from: i64,
               to: i64, blood: bool, ground: bool) {
    let Some(far) = ic_far(v, p, yaw, tip) else { return };
    let g = f_min(1.0, (sf - (from - 3)) as f32 / 3.0);
    let k = 0.9 * if sf < to { 1.0 } else { (to + 4 - sf) as f32 / 4.0 };
    ic_edge(c, kn, st, d, tip, far, g, k, blood);
    if ground {
        let low = tip[1] < 0.4;
        let (gx, gz) = if low { (tip[0], tip[2]) } else { (far[0], far[2]) };
        stage_mark(&mut c.em(), true, gx, gz, 0.9);
        stage_debris(&mut c.em(), gx, gz, 4, 1.0);
        crate::fx::screen::shake_on(shake.0, shake.1, 0.06, 0.15);
    }
}

/// port: ichigo-look.lisp %IC-BLACK-FLAME — KESSA's charge: black flame along the slab P0 -> P1, an ink core, tongues licking up; BIG
/// (the second charge) larger, with a ragged band across (facing FX FZ) into an irregular cross. SEED the drawing.
#[allow(clippy::too_many_arguments)]
fn black_flame(c: &mut Ctx, p0: [f32; 3], p1: [f32; 3], big: bool, seed: f32, fx: f32, fz: f32) {
    let ([x0, y0, z0], [x1, y1, z1]) = (p0, p1);
    let fl = 0.8 + 0.3 * hash01(seed, 4.1);
    let w = fl * if big { 0.22 } else { 0.11 };
    let m = [0.5 * (x0 + x1), 0.05 + 0.5 * (y0 + y1), 0.5 * (z0 + z1)];
    fx_crescent(c, p0, p1, m, w, false, 0.14, 620.0 + seed, PAL_BLACK_SMOKE, 0.85, 0.1);
    fx_crescent(c, p0, p1, m, 0.4 * w, false, 0.06, 630.0 + seed, PAL_INK, 0.95, 0.14);
    let nt = if big { 5 } else { 3 };
    for i in 0..nt {
        let u = (0.5 + i as f32) / if big { 5.0 } else { 3.0 };
        let (px, py, pz) = (x0 + u * (x1 - x0), y0 + u * (y1 - y0), z0 + u * (z1 - z0));
        let h = if big { 0.55 } else { 0.3 } * (0.6 + 0.6 * hash01(seed + i as f32, 7.3));
        let sw = 0.15 * (hash01(seed + i as f32, 9.1) - 0.5);
        fx_crescent(c, [px, py, pz], [px + sw * fz, py + h, pz - sw * fx], [px + 2.0 * sw * fz, py + 0.5 * h, pz - 2.0 * sw * fx], 0.45 * w, true, 0.1,
                    640.0 + seed + i as f32, PAL_BLACK_SMOKE, 0.8, 0.12);
    }
    if big {
        let (bx, by, bz) = (x1 - x0, y1 - y0, z1 - z0);
        let (mut cx, mut cy, mut cz) = (by * -fz - 0.0, bz * fx - bx * -fz, 0.0 - by * fx);
        let cl = f_max(1e-3, f_sqrt(cx * cx + cy * cy + cz * cz));
        let l = 0.42 * f_sqrt(bx * bx + by * by + bz * bz);
        let u = 0.62;
        let (ox, oy, oz) = (x0 + u * bx, y0 + u * by, z0 + u * bz);
        let j0 = 0.8 + 0.4 * hash01(seed, 11.7);
        let j1 = 0.8 + 0.4 * hash01(seed, 13.9);
        let tw = 0.12 * (hash01(seed, 15.1) - 0.5);
        (cx, cy, cz) = (cx / cl, cy / cl, cz / cl);
        let a = [ox - l * j0 * cx, oy - l * j0 * cy - tw, oz - l * j0 * cz];
        let e = [ox + l * j1 * cx, oy + l * j1 * cy + tw, oz + l * j1 * cz];
        fx_crescent(c, a, e, [ox, oy + 0.06, oz], 0.9 * w, false, 0.16, 660.0 + seed, PAL_BLACK_SMOKE, 0.85, 0.1);
        fx_crescent(c, a, e, [ox, oy + 0.06, oz], 0.35 * w, false, 0.06, 670.0 + seed, PAL_INK, 0.95, 0.14);
    }
}

/// The move names of ICHIGO-CHARGED-BLADES' three cases (the move's name: 1 the short blade charged, 2 both, the string after the SA
/// keeping the side's charge).
const CHARGE_1: [&str; 5] = ["ic-n2a", "ic-sa-g1", "ic-k-n2a", "ic-k-sa-g1", "ic-k-as2"];
const CHARGE_2: [&str; 7] = ["ic-n2b", "ic-sa-g2", "ic-k-n2b", "ic-k-sa-g2", "ic-k-as2b", "ic-as2", "ic-as2b"];
const CHARGE_KEEP: [&str; 16] = [
    "ic-j2", "ic-j3", "ic-na3", "ic-na4", "ic-k-na3", "ic-k-na4", "ic-as1", "ic-as3", "ic-as3b", "ic-as3c", "ic-k-j2", "ic-k-j3", "ic-k-as1", "ic-k-as3",
    "ic-k-as3b", "ic-k-as3c",
];

/// port: ichigo-look.lisp ICHIGO-CHARGED-BLADES — step the side's charge (set by the move he is in) and draw its glow and trails on the
/// posed body (KESSA: the black flame on the slab, ink trails).
#[allow(clippy::too_many_arguments)]
fn charged_blades(c: &mut Ctx, m: &Match, f: &duel_sim::components::Fighter, md: &Model, ic: &mut IcState, kn: &FKnobs, d: &Data, kessa: bool, yaw: f32) {
    let side = f.side as usize;
    let mv = (f.state == State::Move).then_some(f.mv).flatten().map(|id| duel_sim::fighter::mv(m, id));
    let n = mv.map(|mv| mv.name.as_str());
    let ch = match n {
        Some(n) if CHARGE_1.contains(&n) => 1,
        Some(n) if CHARGE_2.contains(&n) => 2,
        Some(n) if CHARGE_KEEP.contains(&n) => ic.charged[side],
        _ => 0,
    };
    let swing = mv.is_some_and(|mv| f.phase == Some(Phase::Main) && f.sf >= (mv.s - 4) as i64 && f.sf < (mv.s + mv.a + 3) as i64);
    let jm = &md.joints;
    let dr = drawing_no(c.clock, 12.0);
    ic.charged[side] = ch;
    for b in 0..2 {
        let ti = 2 * side + b;
        if (b as i64) < (if kessa { ch.min(1) } else { ch }) && !md.weapon.is_empty() && md.alpha > 0.5 {
            let (base, tip) = if b == 0 && !kessa {
                (joint_point(&jm[kn.ji.weapon_l], [0.0, 0.0, 0.0]), joint_point(&jm[kn.ji.weapon_l], [0.0, -0.9, 0.0]))
            } else {
                (joint_point(&jm[kn.ji.weapon_r], [0.0, 0.0, 0.0]), held_tip(&jm[kn.ji.weapon_r], d.weapons[md.weapon].len))
            };
            let ([x0, y0, z0], [x1, y1, z1]) = (base, tip);
            let mid = [0.5 * (x0 + x1), 0.06 + 0.5 * (y0 + y1), 0.5 * (z0 + z1)];
            let fl = 0.85 + 0.15 * hash01(dr + b as f32, 2.3);
            if kessa {
                black_flame(c, base, tip, ch == 2, dr + side as f32, fwd_x(yaw), fwd_z(yaw));
            } else {
                fx_crescent(c, base, tip, mid, 0.09 * fl, false, 0.05, 600.0 + dr + b as f32, PAL_REIATSU, 0.9, 0.12);
                fx_crescent(c, base, tip, mid, 0.03 * fl, false, 0.03, 610.0 + dr + b as f32, PAL_HIT, 0.95, 0.16);
            }
            if swing {
                trail_push(&mut ic.trails[ti], base, tip);
            } else {
                trail_decay(&mut ic.trails[ti]);
            }
        } else {
            trail_decay(&mut ic.trails[ti]);
        }
        vfx_smear(c, &ic.trails[ti], &mut ic.smears[ti], if kessa { 2 } else { 1 });
    }
}

/// port: ichigo-look.lisp ICHIGO-CHAIN-LASH — a chain move's lash (its :params :chain (from-deg to-deg len from-y to-y)): the chain
/// cast from the left wrist swept from FROM to TO degrees off his facing, its tip from FROM-Y to TO-Y; the other roots' chains reach
/// for it fainter and a beat behind; one sweep, or one per hit window (alternating directions).
fn chain_lash(c: &mut Ctx, m: &Match, f: &duel_sim::components::Fighter, md: &Model, kn: &Knobs, p: [f32; 3], yaw: f32) {
    let Some(mv) = (f.state == State::Move).then_some(f.mv).flatten().map(|id| duel_sim::fighter::mv(m, id)) else { return };
    let Some([a0, a1, len, y0, y1]) = mv.params.chain else { return };
    if md.alpha <= 0.5 {
        return;
    }
    let (sf, n) = (f.sf, mv.hits.len());
    for w in 0..(if n > 1 { n } else { 1 }).max(1) {
        let (lo, span) = if n > 1 {
            let hw = &mv.hits[w];
            ((hw.from - 3) as i64, ((hw.to - hw.from) + 6) as i64)
        } else {
            ((mv.s - 4) as i64, (mv.a + 8) as i64)
        };
        let (b0, b1) = if w % 2 == 0 { (a0, a1) } else { (a1, a0) };
        for (r, (j, l)) in kn.chain_roots.iter().enumerate() {
            let u = (sf - lo - 2 * r as i64) as f32 / span as f32;
            if 0.0 < u && u < 1.0 {
                let v = joint_point(&md.joints[*j], *l);
                let ang = yaw + (b0 + u * (b1 - b0)) * 0.017453292;
                let l = len * if r == 0 { 1.0 } else { 0.8 } * duel_sim::cl::min_f32(duel_sim::cl::min_f32(1.0, 4.0 * u), 4.0 * (1.0 - u));
                let t = [p[0] + l * fwd_x(ang), y0 + u * (y1 - y0), p[2] + l * fwd_z(ang)];
                vfx_ic_chain(c, v, t, if r == 0 { 0.95 } else { 0.5 });
            }
        }
    }
}

/// port: ichigo-look.lisp ICHIGO-CHAIN-REST — KESSA resting under pointer 1: a blood chain out of each wrist and ankle, curling round
/// him and swaying (two links of arc each).
fn chain_rest(c: &mut Ctx, f: &duel_sim::components::Fighter, md: &Model, kn: &Knobs, p: [f32; 3]) {
    if !(f.ptr == 1 && matches!(f.state, State::Idle | State::Guard)) {
        return;
    }
    let tm = c.clock;
    for (i, (j, l)) in kn.chain_roots.iter().enumerate() {
        let mut q = joint_point(&md.joints[*j], *l);
        let ang = 0.8 * tm + i as f32 * 1.571;
        let r = 0.85;
        let hy = 0.5 + 0.35 * (i % 2) as f32 + 0.15 * f_sin(1.7 * tm + i as f32);
        for k in 0..3 {
            let a1 = ang + (k + 1) as f32 * 0.6;
            let q1 = [p[0] + r * f_cos(a1), hy + 0.25 * k as f32, p[2] + r * f_sin(a1)];
            vfx_ic_chain(c, q, q1, 0.85);
            q = q1;
        }
    }
}

/// port: ichigo-look.lisp ICHIGO-RED-WISPS — red flame tongues at KESSA's wrists, ankles and neck (the neck's spread out while he stands,
/// trailing back as he moves); V his motion's velocity.
fn red_wisps(c: &mut Ctx, md: &Model, kn: &Knobs, v: [f32; 3]) {
    let tm = c.clock;
    let spd = f_sqrt(v[0] * v[0] + v[2] * v[2]);
    let still = duel_sim::cl::max_f32(0.0, 1.0 - 0.5 * spd);
    for (i, (j, l, neck)) in kn.wisp_roots.iter().enumerate() {
        let r = joint_point(&md.joints[*j], *l);
        let n = if *neck { 6 } else { 3 };
        for k in 0..n {
            let ph = 2.4 * tm + 1.9 * i as f32 + 2.1 * k as f32;
            let len = if *neck { 0.42 } else { 0.5 } * (0.85 + 0.25 * f_sin(1.3 * ph));
            let ang = 6.2832 * (k as f32 / n as f32) + 0.25 * tm;
            let (lean, lean_z) = if *neck {
                (still * 0.4 * f_cos(ang) + -0.1 * v[0], still * 0.4 * f_sin(ang) + -0.1 * v[2])
            } else {
                (-0.08 * v[0] + 0.12 * f_cos(2.1 * k as f32), -0.08 * v[2] + 0.12 * f_sin(2.1 * k as f32))
            };
            let rise = if *neck { len * (0.3 + 0.7 * (1.0 - still)) } else { len };
            let sd = (i + 3 * k) as f32;
            tongue(c, r, [lean, rise, lean_z], 0.06, PAL_BLOOD + TOON_FLAME, 0.95, sd, ph, 0.08, 6, 0.04);
            tongue(c, r, [0.8 * lean, 0.7 * rise, 0.8 * lean_z], 0.03, PAL_EMBER, 0.9, sd + 40.0, ph + 0.7, 0.05, 5, 0.04);
        }
    }
}

/// port: ichigo-look.lisp ICHIGO-DRAW (KIT-HOOK :draw, both forms) — step the Shikai's cloak spring; the charged blades; KESSA's chains
/// and wisps; per move of `*ic-edge-moves*` the crescent edge through each hit window and the ground contact.
#[allow(clippy::too_many_arguments)]
pub fn ichigo_draw(c: &mut Ctx, mut shake: (&mut [f32; 8], f32), m: &Match, e: Entity, sides: &Sides, md: &Model, ic: &mut IcState, kn: &FKnobs, d: &Data, rdt: f32) {
    let Some(f) = m.fighter.get(e) else { return };
    let o = 32 * f.side as usize;
    let kessa = duel_sim::fighter::kit_of(m, e).form == "kessa";
    let mv = (f.state == State::Move && f.phase == Some(Phase::Main)).then_some(f.mv).flatten().map(|id| duel_sim::fighter::mv(m, id));
    let sf = if mv.is_some() { f.sf } else { -1 };
    let prev = ic_frame(&mut ic.look, o + 28, sf);
    let edge = mv.and_then(|mv| kn.ic.edge_moves.iter().find(|(n, _)| n.eq_ignore_ascii_case(&mv.name)));
    let (p, yaw) = sides.at(m, e);
    if !kessa {
        hem_step(&mut ic.look, o, rdt, &kn.ic.hem);
    }
    charged_blades(c, m, f, md, ic, kn, d, kessa, yaw);
    if kessa {
        chain_lash(c, m, f, md, &kn.ic, p, yaw);
        chain_rest(c, f, md, &kn.ic, p);
        if md.alpha > 0.5 {
            red_wisps(c, md, &kn.ic, m.motion.get(e).map_or([0.0; 3], |mo| mo.vel));
        }
    }
    let (Some(mv), Some((_, short_ws))) = (mv, edge) else { return };
    if md.weapon.is_empty() || md.alpha <= 0.5 {
        return;
    }
    let jm = &md.joints;
    let st = &mut ic.look;
    let mut tip_l = [0.0f32; 3];
    if !short_ws.is_empty() {
        tip_l = joint_point(&jm[kn.ji.weapon_l], [0.0, -0.9, 0.0]);
        track(st, o + 19, o + 25, tip_l);
    }
    let tip = held_tip(&jm[kn.ji.weapon_r], d.weapons[md.weapon].len);
    track(st, o + 16, o + 22, tip);
    for (i, hw) in mv.hits.iter().enumerate() {
        let (from, to) = (hw.from as i64, hw.to as i64);
        let short = short_ws.contains(&(i as i64));
        if let Some(v) = hw.vols.first()
            && from - 2 <= sf
            && sf < to + 4
        {
            let ground = i == 0 && prev < from && from <= sf && kn.ic.ground_moves.iter().any(|g| g.eq_ignore_ascii_case(&mv.name));
            ic_hit_look(c, &mut shake, &kn.ic, st, if short { o + 25 } else { o + 22 }, v, p, yaw, if short { tip_l } else { tip }, sf, from, to, kessa, ground);
        }
    }
}

/// port: ichigo-look.lisp ICHIGO-AT — the fighter whose drawn feet stand at (X Z) (within 1 mm), P1 first.
fn ichigo_at(w: &AuraWorld, x: f32, z: f32) -> Option<Entity> {
    (0..2).find(|&i| w.sides.alive[i] && (w.sides.p[i][0] - x).abs() < 1e-3 && (w.sides.p[i][2] - z).abs() < 1e-3).map(|i| w.sides.e[i])
}

/// port: ichigo-look.lisp ICHIGO-AURA-BASE — the Shikai has no aura; SOGA's and TSUKIWATARI's flash steps start an ink afterimage
/// every 4 f of their startup.
pub fn aura_base(w: &mut AuraWorld, x: f32, z: f32) {
    let Some(e) = ichigo_at(w, x, z) else { return };
    let m = w.m;
    let Some(f) = m.fighter.get(e) else { return };
    let Some(mv) = (f.state == State::Move).then_some(f.mv).flatten().map(|id| duel_sim::fighter::mv(m, id)) else { return };
    if matches!(mv.name.as_str(), "ic-soga" | "ic-tsuki-dash") && f.phase == Some(Phase::Main) && f.sf < mv.s as i64 && f.sf % 4 == 0 {
        let (p, yaw) = w.sides.at(m, e);
        if let Some(md) = w.models.iter_mut().find(|md| md.e == e) {
            start_ghost(md, p, yaw);
        }
    }
}

/// port: ichigo-look.lisp ICHIGO-AURA-KESSA — a smoulder of dark blood wisps at the neck, wrists and shins (a trace in his own Kikon
/// rush); K the capped presence VFX-AURA passes, DT the effect seconds.
pub fn aura_kessa(c: &mut Ctx, w: &mut AuraWorld, x: f32, z: f32, k: f32, dt: f32) {
    let Some(e) = ichigo_at(w, x, z) else { return };
    let m = w.m;
    let f = m.fighter.get(e);
    let mv = f.filter(|f| f.state == State::Move).and_then(|f| f.mv).map(|id| duel_sim::fighter::mv(m, id));
    let kk = if mv.is_some_and(|mv| mv.kind == "kikon") { 0.2 * k } else { k };
    let Some(md) = w.models.iter().find(|md| md.e == e) else { return };
    let ji = &w.kn.ji;
    for j in [ji.neck, ji.hand_r, ji.hand_l, ji.shin_r, ji.shin_l] {
        let v = joint_point(&md.joints[j], [0.0, 0.0, 0.0]);
        let em = &mut c.em();
        if em.rnd() < 3.0 * dt * kk {
            let vx = em.rr(-0.2, 0.2);
            let vy = em.rr(0.3, 0.7);
            let vz = em.rr(-0.2, 0.2);
            let life = em.rr(0.3, 0.5);
            let size = em.rr(0.02, 0.035);
            t_blob(em, v[0], v[1], v[2], vx, vy, vz, life, size, -0.1, 0.05, PAL_BLOOD);
        }
    }
}

// ---------------------------------------------------------------- the hazards' posed-body looks (HAZARD-DRAW: (fn hazard rdt))

/// What the clone / echo / flare looks reach besides the frame: the fighters' models (the flare reads its owner's joints), the
/// fighters' draw state (the mesh ids, knobs, the clone poses, `*toon-body*`'s lane), the data.
pub struct HzBodies<'a, 'd> {
    pub models: &'a [Model<'d>],
    pub fl: &'a mut super::fighter::FighterLooks<'d>,
    pub data: &'d Data,
}

/// port: ichigo-look.lisp IC-MIST — grey-black mist rising off a phantom at (X Z): six soft wisps climbing past its head.
fn ic_mist(c: &mut Ctx, x: f32, z: f32, alpha: f32, seed: f32) {
    let clk = c.clock;
    for i in 0..6 {
        let v = 0.5 * clk + i as f32 / 6.0 + 0.13 * seed;
        let ph = v - v.floor(); // ((mod v 1.0))
        let a = 2.1 * i as f32 + seed + 0.6 * clk;
        let r = 0.18 + 0.2 * ph;
        let (x0, z0, y0) = (x + r * f_cos(a), z + r * f_sin(a), 0.1 + 1.9 * ph);
        // (* alpha 0.8 (sin (* pi ph))): a long-float pi, so a double
        let k = ((alpha * 0.8) as f64 * duel_sim::math::sin_d(std::f64::consts::PI * ph as f64)) as f32;
        crate::fx::shapes::fx_line(c, [x0, y0, z0], [x0 + 0.15 * f_cos(a + 1.0), y0 + 0.55, z0 + 0.15 * f_sin(a + 1.0)], 0.25 + 0.3 * ph, 0.2, 0.2, 0.21, k,
                                   crate::fx::Mode::Alpha, 0.45 + 0.4 * ph, 0.0);
    }
}

/// port: ichigo-look.lisp IC-GHOST — KESSA's body at the hazard's spot and facing, posed at TM s of CLIP, at ALPHA; RIM a BLOOD ring at
/// its feet; MIST (a clone) a grey-black phantom drawn twice (the second copy drifting) with mist rising, else pale (an echo).
#[allow(clippy::too_many_arguments)]
fn ic_ghost(c: &mut Ctx, w: &mut HzBodies, m: &Match, hz: &duel_sim::components::Hazard, clip: &str, tm: f32, alpha: f32, rim: bool, mist: bool) {
    let o = hz.owner;
    let side = if m.ents.alive(o) { m.fighter.get(o).map_or(0, |f| f.side as usize) } else { 0 };
    let d = w.data;
    let b = &d.bodies["ichigo-kessa"];
    let (x, z, yaw) = (hz.x, hz.z, hz.yaw);
    let super::fighter::FighterLooks { ids, props, kn, toon_y, ic, .. } = &mut *w.fl;
    let an = &mut ic.clone_anim[side];
    an.play(&d.clips[clip], 0.0, 1.0, duel_sim::cl::max_f32(0.0, tm), true);
    let pr = &props.iter().find(|q| q.0 == "ichigo-kessa").expect("KESSA's proportions").1;
    let hide = super::fighter::Hide { tags: &[], extra: &["shikai", "mark"], face: kn.face_hides[0] };
    let mut copy = |c: &mut Ctx, x: f32, z: f32, a: f32| {
        let pose = *ic.clone_anim[side].eval(kn.key_ease);
        crate::rig::pose_fk(&pose, pr, x, 0.0, z, yaw, b.scale, b.hunch, &mut ic.clone_joints[side]);
        let args = super::fighter::BodyArgs {
            body: b,
            ids: &ids.bodies["ichigo-kessa"],
            weapon: ids.weapons.get("tensa").map(Vec::as_slice),
            hide,
            tint: mist.then_some(kn.ic.mist_tint),
            rim: Some(if mist { kn.ic.mist_rim } else { kn.ic.clone_rim }),
            flash: if mist { 0.25 } else { 0.35 },
            alpha: a,
            shadow: false,
        };
        let jm = ic.clone_joints[side];
        let mut bc = super::fighter::BodyCtx { ids, weapon_m: &kn.weapon_m, weapon_r: kn.ji.weapon_r, toon_y };
        super::fighter::draw_body(c.out, &mut bc, &jm, x, 0.0, z, &args);
    };
    if mist {
        let clk = c.clock;
        let (dx, dz) = (0.06 * f_sin(5.0 * clk), 0.06 * f_cos(4.0 * clk));
        copy(c, x, z, 0.75 * alpha);
        copy(c, x + dx, z + dz, 0.4 * alpha);
        ic_mist(c, x, z, alpha, hz.x);
    } else {
        copy(c, x, z, alpha);
    }
    if rim {
        crate::fx::shapes::tring(c, x, 0.0, z, 0.55, 0.04, PAL_BLOOD, 1.8 * alpha, 3.0, 24);
    }
}

/// port: ichigo-look.lisp ICHIGO-CLONE-LOOK — a clone: a grey-black phantom of KESSA (IC-GHOST :mist) with a BLOOD ring: idle in the
/// stance, answering with the answer's clip at its frame, charging in the run, fading over its last frames.
pub fn clone_look(c: &mut Ctx, w: &mut HzBodies, m: &Match, hz: &duel_sim::components::Hazard, i: usize) {
    use duel_sim::ichigo::clones::IccState;
    let cl = &m.iccs[i];
    let age = hz.age as f32 / 60.0;
    let a = 0.45 * f_min(1.0, 0.max(cl.life) as f32 / 20.0) * f_min(1.0, hz.age as f32 / 6.0);
    match cl.state {
        IccState::Answer | IccState::Replay => {
            let mv = duel_sim::fighter::mv(m, cl.mv.expect("an answering clone's move"));
            ic_ghost(c, w, m, hz, &mv.clip, (0.max(cl.sf) as f32 * mv.clip_speed) / 60.0, duel_sim::cl::max_f32(a, 0.3), true, true);
        }
        IccState::Charge => ic_ghost(c, w, m, hz, "sh-run", 1.5 * age, 0.6, true, true),
        IccState::Fade => ic_ghost(c, w, m, hz, "ic-k-stance", age, 0.45 * duel_sim::cl::max_f32(0.0, 1.0 - cl.fade as f32 / 8.0), false, true),
        IccState::Idle => ic_ghost(c, w, m, hz, "ic-k-stance", age, a, true, true),
    }
}

/// port: ichigo-look.lisp ICHIGO-ECHO-LOOK — an afterimage: his move replayed behind him, alpha 0.35, pale, no ring.
pub fn echo_look(c: &mut Ctx, w: &mut HzBodies, m: &Match, hz: &duel_sim::components::Hazard, mv: duel_sim::components::MoveId, sf: i64, end: i64) {
    let mv = duel_sim::fighter::mv(m, mv);
    let clip = if mv.kind == "kikon" { mv.clip2.as_deref().expect("a Kikon's second clip") } else { mv.clip.as_str() };
    if sf >= 0 {
        ic_ghost(c, w, m, hz, clip, (sf as f32 * mv.clip_speed) / 60.0, 0.35 * f_min(1.0, (end - sf) as f32 / 6.0), false, false);
    }
}

/// port: ichigo-look.lisp ICHIGO-FLARE-LOOK — KUSARI-TATE: the chains flaring out of his neck, wrists and ankles (the parry's tell);
/// P the owner's drawn feet.
pub fn flare_look(c: &mut Ctx, w: &HzBodies, m: &Match, hz: &duel_sim::components::Hazard, p: [f32; 3]) {
    let e = hz.owner;
    if !(m.ents.alive(e) && m.fighter.get(e).is_some()) {
        return;
    }
    let Some(md) = w.models.iter().find(|md| md.e == e) else { return };
    let k = duel_sim::cl::max_f32(0.02, 0.95 - 0.045 * hz.age as f32);
    let g = f_min(1.0, (hz.age + 1) as f32 / 3.0);
    let ji = &w.fl.kn.ji;
    for j in [ji.neck, ji.hand_r, ji.hand_l, ji.foot_r, ji.foot_l] {
        let [x, y, z] = joint_point(&md.joints[j], [0.0, 0.0, 0.0]);
        let (dx, dz) = (x - p[0], z - p[2]);
        let l = duel_sim::cl::max_f32(0.05, duel_sim::math::hypot(dx, dz));
        let r = 0.9 * g;
        vfx_ic_chain(c, [x, y, z], [x + r * (dx / l), y + 0.3 * g, z + r * (dz / l)], k);
    }
}

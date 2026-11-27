//! port: duel/lisp/draw.lisp DRAW-FIGHTER and what it calls (docs/bevy/M3A_NOTES.md §7): the pose (the clip, the held pose, the
//! head-back beat, POSE-FK!), the kit's :pose hook, the two-handed grip (GRIP-STEP / GRIP-LEFT!), the smear and the Hoho afterimage,
//! the face, the body (duel/lisp/body.lisp DRAW-BODY, engine/lisp/body.lisp DRAW-PARTS, DRAW-WEAPON, DRAW-SHADOW), the kit's :draw
//! hook (`ken.rs`, `ichigo.rs`), the weapon's trail and smear, and the auras (the form's, EVOLUTION, a burst, the Breaker, the Kikon
//! rush; ICHIGO-AURA-BASE / -KESSA). Everything reads the places this frame draws (`Scene::drawn_pos` / `drawn_yaw`), never the sim's.
use super::frame::FrameOut;
use super::queue::{draw_mesh, DrawOpts};
use super::stage::TOON_GROUND;
use crate::anim::Pose;
use crate::fx::shapes::{drawing_no, fx_shard, hash01, sage, PAL_BLACK_SMOKE, PAL_HIT};
use crate::fx::vfx::{trail_decay, trail_push, vfx_aura, vfx_breaker_ring, vfx_smear};
use crate::fx::Ctx;
use crate::mesh::{BodyIds, Ids, WeaponPartId};
use crate::rig::{body_weapon_point, joint_index, joint_point, pose_fk, Mat4, Proportions, NJ};
use crate::scene::{push_sound, Face, Model, Rim, Scene, SoundReq};
use duel_data::{Body, Data, Kit, Move};
use duel_sim::cl::{floor_f32, max_f32, min_f32};
use duel_sim::components::{Burst, Fighter, Phase, State};
use duel_sim::ecs::Entity;
use duel_sim::math::{f_abs, f_cos, f_max, f_min, f_sin, f_sqrt, fwd_x, fwd_z};
use duel_sim::state::Match;

/// The rig's joints the draw reads by name (JI), resolved once from rig.json.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Ji {
    pub spine: usize,
    pub chest: usize,
    pub neck: usize,
    pub head: usize,
    pub upper_arm_l: usize,
    pub lower_arm_l: usize,
    pub hand_l: usize,
    pub hand_r: usize,
    pub weapon_l: usize,
    pub weapon_r: usize,
    pub shin_l: usize,
    pub shin_r: usize,
    pub foot_l: usize,
    pub foot_r: usize,
}

impl Ji {
    fn new(d: &Data) -> Ji {
        let j = |n: &str| joint_index(&d.rig, n);
        Ji {
            spine: j("spine"),
            chest: j("chest"),
            neck: j("neck"),
            head: j("head"),
            upper_arm_l: j("upper-arm-l"),
            lower_arm_l: j("lower-arm-l"),
            hand_l: j("hand-l"),
            hand_r: j("hand-r"),
            weapon_l: j("weapon-l"),
            weapon_r: j("weapon-r"),
            shin_l: j("shin-l"),
            shin_r: j("shin-r"),
            foot_l: j("foot-l"),
            foot_r: j("foot-r"),
        }
    }
}

/// The look knobs DRAW-FIGHTER and the hooks read (tuning.json / tables.json, never retyped; computed constants made once).
pub struct Knobs<'d> {
    /// `*face-hides*`: per face (neutral shout hurt) the two face tags DRAW-BODY hides.
    pub face_hides: [[&'d str; 2]; 3],
    /// `*ghost-ink*`, `*hurt-cines*`, tables.json `grip_clips` (`*grip-clips*`), `*super-flash*` (frames).
    pub ghost_ink: [f32; 3],
    pub hurt_cines: Vec<&'d str>,
    pub grip_clips: Vec<&'d duel_data::Clip>,
    pub super_flash: f32,
    /// body.lisp `*weapon-m*` = (xform :pitch (deg 90) :roll pi), `*super-rim*` = (rim-vec #xFFFFFF 3.0), tables.json `mirror_tint`.
    pub weapon_m: Mat4,
    pub super_rim: [f32; 3],
    pub mirror_tint: [f32; 3],
    /// The game's *KEY-EASE* (rig.json).
    pub key_ease: u8,
    pub ji: Ji,
    pub ken: super::ken::Knobs,
    pub ic: super::ichigo::Knobs<'d>,
}

impl<'d> Knobs<'d> {
    fn new(d: &'d Data) -> Knobs<'d> {
        let t = |k: &str| d.tuning.get(k).unwrap_or_else(|| panic!("tuning {k}"));
        let fh = t("*FACE-HIDES*").as_array().expect("*FACE-HIDES*");
        let row = |face: &str| -> [&'d str; 2] {
            let r = fh.iter().map(|r| r.as_array().unwrap()).find(|r| r[0].as_str() == Some(face)).expect("*FACE-HIDES* row");
            [r[1].as_str().unwrap(), r[2].as_str().unwrap()]
        };
        let f3 = |v: &duel_data::tuning::Value| -> [f32; 3] {
            let a = v.as_array().expect("3 floats");
            [0, 1, 2].map(|i| a[i].as_f64().unwrap() as f32)
        };
        let strs = |v: &'d duel_data::tuning::Value| -> Vec<&'d str> { v.as_array().expect("a list").iter().map(|x| x.as_str().unwrap()).collect() };
        // (deg 90): (* 90.0 #.(float (/ pi 180) 1f0)); the roll (f32 pi)
        let weapon_m = crate::mesh::meshgen::m4_euler(0.0, 0.0, 0.0, 0.0, 90.0 * (std::f64::consts::PI / 180.0) as f32, std::f64::consts::PI as f32, 1.0, 1.0, 1.0);
        Knobs {
            face_hides: [row("neutral"), row("shout"), row("hurt")],
            ghost_ink: f3(t("*GHOST-INK*")),
            hurt_cines: strs(t("*HURT-CINES*")),
            grip_clips: strs(d.tables.get("grip_clips").expect("tables.json grip_clips")).into_iter().map(|n| &d.clips[n]).collect(),
            super_flash: t("*SUPER-FLASH*").as_f64().expect("*SUPER-FLASH*") as f32,
            weapon_m,
            super_rim: rim_vec(0xFFFFFF, 3.0),
            mirror_tint: f3(d.tables.get("mirror_tint").expect("tables.json mirror_tint")),
            key_ease: d.rig.key_ease as u8,
            ji: Ji::new(d),
            ken: super::ken::Knobs::new(d),
            ic: super::ichigo::Knobs::new(d),
        }
    }
}

/// port: engine/lisp/meshgen.lisp RIM-VEC — sRGB #xRRGGBB at strength K as linear rgb: `(* k (expt c 2.2))` per channel.
pub fn rim_vec(hex: u32, k: f32) -> [f32; 3] {
    super::frame::hexc(hex).map(|c| k * duel_sim::cl::musl_powf(c, 2.2))
}

/// The fighters' draw state the Lisp keeps outside MODEL (per side, never reset at a spawn), the mesh ids, the bodies' proportions
/// and the knobs.
pub struct FighterLooks<'d> {
    pub ids: Ids,
    /// The ported bodies' POSE-FK! proportions, by name.
    pub props: Vec<(&'d str, Proportions)>,
    pub kn: Knobs<'d>,
    /// body.lisp `*toon-body*`'s lane 1: the feet height of the last DRAW-BODY (0 after a planted weapon); a global the next draw reads.
    pub toon_y: f32,
    /// ken-look.lisp `*ke-look*`.
    pub ke_look: [f32; 32],
    /// ichigo-look.lisp's per-side state.
    pub ic: super::ichigo::IcState<'d>,
}

impl<'d> FighterLooks<'d> {
    pub fn new(d: &'d Data) -> FighterLooks<'d> {
        let ids = crate::mesh::Meshes::build(d).ids;
        let props = ids.bodies.keys().map(|n| {
            let (name, b) = d.bodies.get_key_value(n.as_str()).expect("a body of the data");
            (name.as_str(), Proportions::of(&d.rig, b))
        });
        FighterLooks { props: props.collect(), ids, kn: Knobs::new(d), toon_y: 0.0, ke_look: [0.0; 32], ic: super::ichigo::IcState::new() }
    }
    pub fn props(&self, body: &str) -> Option<&Proportions> {
        self.props.iter().find(|p| p.0 == body).map(|p| &p.1)
    }
}

/// What every fighter's draw this frame reads of both sides: the entity, alive with a fighter, its drawn place and yaw.
#[derive(Clone, Copy, Debug)]
pub struct Sides {
    pub e: [Entity; 2],
    pub alive: [bool; 2],
    pub p: [[f32; 3]; 2],
    pub yaw: [f32; 2],
}

impl Sides {
    pub fn of(sc: &Scene, m: &Match) -> Sides {
        let e = [m.p1, m.p2];
        let alive = e.map(|e| m.ents.alive(e) && m.fighter.get(e).is_some());
        Sides { e, alive, p: e.map(|e| sc.drawn_pos(m, e)), yaw: e.map(|e| sc.drawn_yaw(m, e)) }
    }
    /// E's drawn place and yaw (a side's), else the sim's.
    pub fn at(&self, m: &Match, e: Entity) -> ([f32; 3], f32) {
        match self.e.iter().position(|x| *x == e) {
            Some(i) => (self.p[i], self.yaw[i]),
            None => (duel_sim::fighter::pos_of(m, e), duel_sim::fighter::yaw_of(m, e)),
        }
    }
}

// ---------------------------------------------------------------- the body, the weapon, the shadow (body.lisp's drawing)

/// body.lisp `*toon-body*` with its feet lane, `*toon-ink*`, and DRAW-PARTS' hull lanes (mode 3, push 0.012 m, the body lanes' fog,
/// 1.8 px).
fn toon_body(y: f32) -> [f32; 4] {
    [2.0, y, 0.2, 0.0]
}
const TOON_INK: [f32; 4] = [3.0, 0.012, 0.2, 1.8];
const PART_INK: [f32; 4] = [3.0, 0.012, 0.2, 1.8];

/// DRAW-PARTS' HIDE test: a tag of the kit's hidden ones (MODEL-HIDE) or of the face's (FACE-HIDE).
#[derive(Clone, Copy)]
pub struct Hide<'a> {
    pub tags: &'a [String],
    pub extra: &'a [&'a str],
    pub face: [&'a str; 2],
}

impl Hide<'_> {
    fn hidden(&self, tag: Option<&str>) -> bool {
        tag.is_some_and(|t| self.face.contains(&t) || self.tags.iter().any(|x| x == t) || self.extra.contains(&t))
    }
}

/// port: engine/lisp/body.lisp DRAW-PARTS (HIDDEN 0, no RECOLOR, EMISSIVE 0): the solids by joint, the extras in their list order
/// (a glow in its own tint and emissive), then the ink hulls (TOON set, ALPHA 1) tinted INK-TINT. SOLIDS false: DRAW-GHOST's
/// `*no-parts*` (the hulls alone, no extra), HIDE then hides nothing.
#[allow(clippy::too_many_arguments)]
fn draw_parts(out: &mut FrameOut, b: &BodyIds, jm: &[Mat4; NJ], hide: Option<Hide>, solids: bool, tint: Option<[f32; 3]>, flash: f32, alpha: f32,
              rim: Option<[f32; 3]>, toon: [f32; 4], ink_tint: Option<[f32; 3]>) {
    let hid = |tag: Option<&str>| hide.is_some_and(|h| h.hidden(tag));
    let solid = DrawOpts { tint, flash, alpha, rim, toon: Some(toon), ..DrawOpts::default() };
    if solids {
        for (j, id) in b.parts.iter().enumerate() {
            if let Some(id) = id {
                draw_mesh(out, *id, &jm[j], &solid);
            }
        }
        for g in &b.extras {
            if hid(g.tag.as_deref()) {
                continue;
            }
            match g.tint {
                Some(t) => draw_mesh(out, g.id, &jm[g.joint], &DrawOpts { tint: Some(t), emissive: g.emissive, alpha, toon: Some(toon), ..DrawOpts::default() }),
                None => draw_mesh(out, g.id, &jm[g.joint], &solid),
            }
        }
    }
    if alpha >= 1.0 {
        let lanes = [PART_INK[0], PART_INK[1], toon[2], PART_INK[3]];
        for h in &b.hulls {
            if !hid(h.tag.as_deref()) {
                draw_mesh(out, h.id, &jm[h.joint], &DrawOpts { tint: ink_tint, toon: Some(lanes), ..DrawOpts::default() });
            }
        }
    }
}

/// port: body.lisp DRAW-WEAPON — the weapon's sections at M (toon-shaded with the last feet height), then their ink hulls (ALPHA 1).
#[allow(clippy::too_many_arguments)]
fn draw_weapon(out: &mut FrameOut, parts: &[WeaponPartId], m: &Mat4, alpha: f32, flash: f32, emissive: f32, rim: Option<[f32; 3]>, tint: Option<[f32; 3]>, toon_y: f32) {
    let toon = Some(toon_body(toon_y));
    for p in parts {
        match p.tint {
            Some(t) => {
                let em = if emissive == 0.0 { p.emissive } else { p.emissive + emissive };
                draw_mesh(out, p.id, m, &DrawOpts { tint: Some(t), alpha, toon, emissive: em, ..DrawOpts::default() })
            }
            None => draw_mesh(out, p.id, m, &DrawOpts { flash, alpha, emissive, rim, tint, toon, ..DrawOpts::default() }),
        }
    }
    if alpha >= 1.0 {
        for p in parts {
            if let Some(h) = p.hull {
                draw_mesh(out, h, m, &DrawOpts { toon: Some(TOON_INK), ..DrawOpts::default() });
            }
        }
    }
}

/// port: body.lisp DRAW-SHADOW — the ink disc of radius R under (X Z), smaller the higher Y.
fn draw_shadow(out: &mut FrameOut, ids: &Ids, x: f32, y: f32, z: f32, r: f32) {
    let k = r * max_f32(0.3, 1.0 - 0.3 * y);
    let mut m = [0.0f32; 16];
    (m[0], m[5], m[10], m[15]) = (k, 1.0, k, 1.0);
    (m[12], m[13], m[14]) = (x, 0.012, z);
    draw_mesh(out, ids.shadow, &m, &DrawOpts { toon: Some(TOON_GROUND), ..DrawOpts::default() });
}

/// port: body.lisp %PLANTED-M! / DRAW-PLANTED-WEAPON — the weapon stuck in the ground AHEAD m before (X Z) along YAW and RIGHT m to
/// its right (the feet lane 0).
#[allow(clippy::too_many_arguments)]
fn draw_planted_weapon(out: &mut FrameOut, ids: &Ids, toon_y: &mut f32, d: &Data, key: &str, x: f32, z: f32, yaw: f32, ahead: f32, right: f32) {
    let len = d.weapons[key].len;
    let (fx, fz) = (-f_sin(yaw), -f_cos(yaw));
    let mut m = [0.0f32; 16];
    crate::rig::euler(&mut m, x + ahead * fx + right * -fz, 0.8 * len, z + ahead * fz + right * fx, yaw, 2.9415927, 0.0, 1.0);
    *toon_y = 0.0;
    if let Some(parts) = ids.weapons.get(key) {
        draw_weapon(out, parts, &m, 1.0, 0.0, 0.0, None, None, 0.0);
    }
}

/// DRAW-BODY's arguments.
pub struct BodyArgs<'a> {
    pub body: &'a Body,
    pub ids: &'a BodyIds,
    pub weapon: Option<&'a [WeaponPartId]>,
    pub hide: Hide<'a>,
    pub tint: Option<[f32; 3]>,
    pub rim: Option<[f32; 3]>,
    pub flash: f32,
    pub alpha: f32,
    pub shadow: bool,
}

/// What DRAW-BODY reads and writes besides its arguments: the mesh ids, `*weapon-m*` and :weapon-r, and `*toon-body*`'s feet lane.
pub struct BodyCtx<'a> {
    pub ids: &'a Ids,
    pub weapon_m: &'a Mat4,
    pub weapon_r: usize,
    pub toon_y: &'a mut f32,
}

/// port: body.lisp DRAW-BODY — the body's parts posed by JM (the feet lane Y), the held weapon on :weapon-r (x `*weapon-m*`), the
/// ink shadow (1.2 x ALPHA x the hurt radius). RIM NIL: the body's own.
#[allow(clippy::too_many_arguments)]
pub fn draw_body(out: &mut FrameOut, bc: &mut BodyCtx, jm: &[Mat4; NJ], x: f32, y: f32, z: f32, a: &BodyArgs) {
    let rim = a.rim.or_else(|| a.body.rim.as_ref().map(|r| [r[0], r[1], r[2]]));
    *bc.toon_y = y;
    draw_parts(out, a.ids, jm, Some(a.hide), true, a.tint, a.flash, a.alpha, rim, toon_body(y), a.tint);
    if let Some(w) = a.weapon {
        let dm2 = crate::draw::camera::m4_mul(&jm[bc.weapon_r], bc.weapon_m);
        draw_weapon(out, w, &dm2, a.alpha, a.flash, 0.0, rim, None, y);
    }
    if a.shadow {
        draw_shadow(out, bc.ids, x, y, z, 1.2 * a.alpha * a.body.hurt_r);
    }
}

// ---------------------------------------------------------------- the pose's looks

/// port: draw.lisp SMEAR-JOINTS! — every joint matrix premultiplied by T(c) S T(-c), S = 0.7 I + 0.8 d d^T along the ground direction
/// (DX DZ), about the body centre C.
fn smear_joints(jm: &mut [Mat4; NJ], cx: f32, cy: f32, cz: f32, dx: f32, dz: f32) {
    let (a, b) = (0.7f32, 0.8f32);
    for m in jm.iter_mut() {
        for col in 0..4 {
            let (k, tr) = (4 * col, col == 3);
            let vx = if tr { m[k] - cx } else { m[k] };
            let vy = if tr { m[k + 1] - cy } else { m[k + 1] };
            let vz = if tr { m[k + 2] - cz } else { m[k + 2] };
            let dd = b * (dx * vx + dz * vz);
            m[k] = a * vx + dd * dx + if tr { cx } else { 0.0 };
            m[k + 1] = a * vy + if tr { cy } else { 0.0 };
            m[k + 2] = a * vz + dd * dz + if tr { cz } else { 0.0 };
        }
    }
}

/// port: draw.lisp START-GHOST — the Hoho afterimage: the pose E vanishes in (MD's joints), smeared sideways about (P + 1 m up).
pub fn start_ghost(md: &mut Model, p: [f32; 3], yaw: f32) {
    md.ghost = md.joints;
    smear_joints(&mut md.ghost, p[0], p[1] + 1.0, p[2], fwd_z(yaw), -fwd_x(yaw));
    md.ghost_age = 0.0;
}

/// port: draw.lisp HOLD-POSE — hold the drawn pose for FRAMES (60 Hz, effect time).
pub fn hold_pose(md: &mut Model, frames: f32) {
    md.hold = max_f32(md.hold, frames / 60.0);
}

/// port: draw.lisp SMEAR — one smear drawing along the ground direction (DX DZ).
pub fn smear(md: &mut Model, dx: f32, dz: f32) {
    let l = max_f32(1e-4, duel_sim::math::hypot(dx, dz));
    (md.smear, md.smear_dir) = (1.0 / 60.0, [dx / l, dz / l]);
}

/// port: draw.lisp FACE-BEAT — hold FACE for SECS; HEAD-BACK: the head thrown back over them too.
pub fn face_beat(md: &mut Model, face: Face, secs: f32, head_back: bool) {
    (md.face, md.face_t) = (face, secs);
    if head_back {
        md.beat = secs;
    }
}

/// port: draw.lisp BEAT-POSE! — POSE with the head thrown back (head -35, chest -10, spine -8 degrees of flex) by the envelope of a
/// beat with BEAT s left of its 0.9 s.
fn beat_pose(pose: &Pose, beat: f32, ji: &Ji) -> Pose {
    let clamp = crate::fx::shapes::f_clamp;
    let u = 0.9 - beat;
    let w = f_min(clamp(u / 0.12, 0.0, 1.0), clamp(beat / 0.3, 0.0, 1.0));
    let mut out = *pose;
    out[3 * ji.head] += w * -0.61;
    out[3 * ji.chest] += w * -0.175;
    out[3 * ji.spine] += w * -0.14;
    out
}

/// port: body.lisp GRIP-TARGET-OK-P — may the left fist be pulled onto the handle: not when the target lies more than 0.10 m behind
/// the chest's frontal plane and below 0.2 m over the chest joint.
fn grip_target_ok(jm: &[Mat4; NJ], ji: &Ji) -> bool {
    let (ch, wr, wl) = (&jm[ji.chest], &jm[ji.weapon_r], &jm[ji.weapon_l]);
    let (ax, ay, az) = (wr[8], wr[9], wr[10]);
    let (ox, oy, oz) = (wr[12], wr[13], wr[14]);
    let s = crate::fx::shapes::f_clamp(((wl[12] - ox) * ax + (wl[13] - oy) * ay + (wl[14] - oz) * az) / f_max(1e-6, ax * ax + ay * ay + az * az), 0.14, 0.62);
    let (hx, hy, hz) = ((ox + s * ax) - ch[12], (oy + s * ay) - ch[13], (oz + s * az) - ch[14]);
    let (fx, fy, fz) = (-ch[8], -ch[9], -ch[10]);
    let (ux, uy, uz) = (ch[4], ch[5], ch[6]);
    (hx * fx + hy * fy + hz * fz) / f_max(1e-6, crate::fx::f_hypot3(fx, fy, fz)) > -0.10
        || (hx * ux + hy * uy + hz * uz) / f_max(1e-6, crate::fx::f_hypot3(ux, uy, uz)) > 0.2
}

/// port: body.lisp %ROT-TO! — (x y z) by the rotation taking unit A to B, K = A x B, C = A . B (Rodrigues).
#[inline]
fn rot_to(k: [f32; 3], c: f32, v: [f32; 3]) -> [f32; 3] {
    let [kx, ky, kz] = k;
    let [x, y, z] = v;
    let d = (kx * x + ky * y + kz * z) / (1.0 + c);
    [c * x + (ky * z - kz * y) + d * kx, c * y + (kz * x - kx * z) + d * ky, c * z + (kx * y - ky * x) + d * kz]
}

/// port: body.lisp %ROT-COLS! — joint J's three axis columns by %ROT-TO!'s rotation.
fn rot_cols(jm: &mut [Mat4; NJ], j: usize, k: [f32; 3], c: f32) {
    for col in 0..3 {
        let o = 4 * col;
        let m = &mut jm[j];
        let r = rot_to(k, c, [m[o], m[o + 1], m[o + 2]]);
        (m[o], m[o + 1], m[o + 2]) = (r[0], r[1], r[2]);
    }
}

/// port: body.lisp GRIP-LEFT! — two-bone IK after the FK: the left fist W of the way onto the right hand's handle (its :weapon-r +Z
/// axis, 0.14-0.62 m behind the grip, the point nearest the posed fist), the elbow bent in the plane the pose gave it; a second pass
/// at W 1.
fn grip_left(jm: &mut [Mat4; NJ], w: f32, ji: &Ji) {
    let (ua, la, hd, wl, wr) = (ji.upper_arm_l, ji.lower_arm_l, ji.hand_l, ji.weapon_l, ji.weapon_r);
    let clamp = crate::fx::shapes::f_clamp;
    let h3 = crate::fx::f_hypot3;
    for _ in 0..(if w >= 1.0 { 2 } else { 1 }) {
        let o = |j: usize| [jm[j][12], jm[j][13], jm[j][14]];
        let ([sx, sy, sz], [ex, ey, ez], [hx, hy, hz], [fx, fy, fz]) = (o(ua), o(la), o(hd), o(wl));
        let (ax, ay, az) = (jm[wr][8], jm[wr][9], jm[wr][10]);
        let [ox, oy, oz] = o(wr);
        let s = clamp(((fx - ox) * ax + (fy - oy) * ay + (fz - oz) * az) / f_max(1e-6, ax * ax + ay * ay + az * az), 0.14, 0.62);
        let (tx, ty, tz) = (hx + w * ((ox + s * ax) - fx), hy + w * ((oy + s * ay) - fy), hz + w * ((oz + s * az) - fz));
        let a = h3(ex - sx, ey - sy, ez - sz);
        let b = h3(hx - ex, hy - ey, hz - ez);
        let (dx, dy, dz) = (tx - sx, ty - sy, tz - sz);
        let d = clamp(h3(dx, dy, dz), 1e-3 + 1.01 * f_abs(a - b), 0.999 * (a + b));
        let dl = f_max(1e-5, h3(dx, dy, dz));
        let (ux, uy, uz) = (dx / dl, dy / dl, dz / dl);
        let pe = (ex - sx) * ux + (ey - sy) * uy + (ez - sz) * uz;
        let (px, py, pz) = (ex - sx - pe * ux, ey - sy - pe * uy, ez - sz - pe * uz);
        let pl = h3(px, py, pz);
        if !(pl > 1e-4 && a > 1e-4 && b > 1e-4) {
            continue;
        }
        let ca = clamp(((a * a + d * d) - b * b) / (2.0 * a * d), -1.0, 1.0);
        let sa = f_sqrt(f_max(0.0, 1.0 - ca * ca));
        let (nex, ney, nez) = (sx + a * (ca * ux + sa * (px / pl)), sy + a * (ca * uy + sa * (py / pl)), sz + a * (ca * uz + sa * (pz / pl)));
        let (nhx, nhy, nhz) = (sx + d * ux, sy + d * uy, sz + d * uz);
        let (a0x, a0y, a0z) = ((ex - sx) / a, (ey - sy) / a, (ez - sz) / a);
        let (a1x, a1y, a1z) = ((nex - sx) / a, (ney - sy) / a, (nez - sz) / a);
        let k1 = [a0y * a1z - a0z * a1y, a0z * a1x - a0x * a1z, a0x * a1y - a0y * a1x];
        let c1 = a0x * a1x + a0y * a1y + a0z * a1z;
        let b0 = [(hx - ex) / b, (hy - ey) / b, (hz - ez) / b];
        if c1 <= -0.999 {
            continue;
        }
        let [b0x, b0y, b0z] = rot_to(k1, c1, b0);
        let bl = f_max(1e-5, h3(nhx - nex, nhy - ney, nhz - nez));
        let (b1x, b1y, b1z) = ((nhx - nex) / bl, (nhy - ney) / bl, (nhz - nez) / bl);
        let k2 = [b0y * b1z - b0z * b1y, b0z * b1x - b0x * b1z, b0x * b1y - b0y * b1x];
        let c2 = b0x * b1x + b0y * b1y + b0z * b1z;
        let q = [fx - hx, fy - hy, fz - hz];
        if c2 <= -0.999 {
            continue;
        }
        rot_cols(jm, ua, k1, c1);
        rot_cols(jm, la, k1, c1);
        rot_cols(jm, la, k2, c2);
        rot_cols(jm, hd, k1, c1);
        rot_cols(jm, hd, k2, c2);
        rot_cols(jm, wl, k1, c1);
        rot_cols(jm, wl, k2, c2);
        let [qx, qy, qz] = rot_to(k2, c2, rot_to(k1, c1, q));
        (jm[la][12], jm[la][13], jm[la][14]) = (nex, ney, nez);
        (jm[hd][12], jm[hd][13], jm[hd][14]) = (nhx, nhy, nhz);
        (jm[wl][12], jm[wl][13], jm[wl][14]) = (nhx + qx, nhy + qy, nhz + qz);
    }
}

/// port: draw.lisp GRIP-STEP — LOOKS[0] eased toward 1 while ON, to 0 otherwise, over 0.1 s of effect time; GRIP-LEFT! by that much.
fn grip_step(md: &mut Model, on: bool, dt: f32, ji: &Ji) {
    let (g, to) = (md.looks[0], if on { 1.0 } else { 0.0 });
    let n = if to > g { f_min(to, g + 10.0 * dt) } else { f_max(to, g - 10.0 * dt) };
    md.looks[0] = n;
    if n > 0.0 {
        grip_left(&mut md.joints, n, ji);
    }
}

/// port: draw.lisp RUSH-DASHING-P.
fn rush_dashing(m: &Match, f: &Fighter) -> bool {
    match f.phase {
        Some(Phase::Dash) => true,
        Some(Phase::Follow) => f.dist > m.knobs.kikon_trigger + 0.05,
        _ => false,
    }
}

/// port: draw.lisp FACE-OF — the expression this frame: a held face first; in a cinematic the attacker shouts and a hurt cinematic's
/// victim is hurt; hurt while stunned, airborne, down or lost; shouting through a non-quick move near its hit; else the form's resting
/// face.
#[allow(clippy::too_many_arguments)]
fn face_of(m: &Match, kn: &Knobs, e: Entity, f: &Fighter, kit: &Kit, md: &Model, mv: Option<&Move>) -> Face {
    let resting = match kit.face.as_deref() {
        Some("shout") => Face::Shout,
        Some("hurt") => Face::Hurt,
        _ => Face::Neutral,
    };
    if md.face_t > 0.0 {
        return md.face;
    }
    if f.state == State::Cine {
        let Some(c) = &m.cine else { return resting };
        let name = c.name.lisp();
        return if e == c.a {
            if kit.calm || matches!(name, "INTRO-CINE" | "TIME-CINE" | "KO-CINE") { Face::Neutral } else { Face::Shout }
        } else if kn.hurt_cines.contains(&name) {
            Face::Hurt
        } else {
            resting
        };
    }
    if matches!(f.state, State::Stun | State::Air | State::Down | State::Lose) {
        return Face::Hurt;
    }
    if let Some(mv) = mv
        && f.state == State::Move
        && mv.kind != "quick"
        && (f.phase != Some(Phase::Main) || ((mv.s - 10) as i64 <= f.sf && f.sf <= (mv.s + mv.a + 12) as i64))
    {
        return if kit.calm { Face::Neutral } else { Face::Shout };
    }
    resting
}

/// port: vfx.lisp VFX-FACE-ACCENT — over the head of the body posed in JM, MS ms after the face changed: KIND 1 (shout) six ink
/// strokes bursting out of the head, KIND 2 (hurt) three white drops flung off it.
fn vfx_face_accent(c: &mut Ctx, jm: &[Mat4; NJ], ji: &Ji, kind: i32, ms: i64) {
    let age = 0.001 * ms as f32;
    let a = sage(c.clock, age, 2.0);
    let dr = drawing_no(c.clock, 12.0);
    let [hx, hy, hz] = joint_point(&jm[ji.head], [0.0, 0.12, 0.02]);
    let ([rx, ry, rz], [ux, uy, uz]) = (c.cam.right, c.cam.upv);
    let clamp = crate::fx::shapes::f_clamp;
    if kind == 1 {
        if ms < 350 {
            let k = 0.98 * clamp((0.35 - a) / 0.1, 0.0, 1.0);
            let g = f_min(1.0, 0.6 + 5.0 * a);
            for i in 0..6 {
                let f = i as f32;
                let th = 0.35 + 0.49 * f + 0.14 * (hash01(f + dr, 3.1) - 0.5);
                let (cc, sn) = (f_cos(th), f_sin(th));
                let l = g * (0.28 + 0.14 * hash01(f + dr, 1.7));
                let (dx, dy, dz) = (cc * rx + sn * ux, cc * ry + sn * uy, cc * rz + sn * uz);
                let r = 0.3 + 0.5 * l;
                fx_shard(c, hx + r * dx, hy + r * dy, hz + r * dz, dx, dy, dz, l, 0.045, 0.05, f + dr, PAL_BLACK_SMOKE, k, 0.3);
            }
        }
    } else if ms < 400 {
        for i in 0..3 {
            let f = i as f32;
            let side = if i == 1 { -1.0 } else { 1.0 };
            let (vx, vy) = (side * (1.2 + 0.5 * f), 1.6 - 0.3 * f);
            let (px, py, ty) = (vx * a, vy * a - 4.9 * a * a, vy - 9.8 * a);
            let tl = f_max(1e-3, f_sqrt(vx * vx + ty * ty));
            let k = 0.98 * clamp((0.4 - a) / 0.1, 0.0, 1.0);
            let o = side * 0.1 + px;
            fx_shard(c, hx + o * rx + py * ux, hy + o * ry + py * uy, hz + o * rz + py * uz, (vx * rx + ty * ux) / tl, (vx * ry + ty * uy) / tl,
                     (vx * rz + ty * uz) / tl, 0.2, 0.07, 0.05, 7.0 + f, PAL_HIT, k, 0.3);
        }
    }
}

/// port: draw.lisp FACE-ACCENT — FACE, noting when it changed; outside a cinematic a shout or a hurt face just put on shows its accent
/// over the head for a few drawings.
fn face_accent(c: &mut Ctx, m: &Match, md: &mut Model, ji: &Ji, face: Face) -> Face {
    if face != md.face_was {
        (md.face_was, md.looks[1]) = (face, c.clock);
    }
    if !(m.cine.is_some() || face == Face::Neutral) {
        let ms = floor_f32(1000.0 * (c.clock - md.looks[1]));
        if ms < 400 {
            vfx_face_accent(c, &md.joints, ji, if face == Face::Shout { 1 } else { 2 }, ms);
        }
    }
    face
}

/// port: draw.lisp DRAW-GHOST — the Hoho afterimage while it lasts: 2 drawings white, 2 as ink hulls (twos on the fx clock).
fn draw_ghost(c: &mut Ctx, md: &mut Model, ids: &Ids, kn: &Knobs, toon_y: &mut f32, d: &Data, dt: f32) {
    let mut age = md.ghost_age;
    if age < 0.0 {
        return;
    }
    let q = sage(c.clock, age, 2.0);
    let b = &d.bodies[md.body];
    let bids = &ids.bodies[md.body];
    if q < 2.0 / 24.0 {
        let a = BodyArgs {
            body: b,
            ids: bids,
            weapon: None,
            hide: Hide { tags: md.hide, extra: &[], face: kn.face_hides[0] },
            tint: md.tint.then_some(kn.mirror_tint),
            rim: None,
            flash: 1.0,
            alpha: 1.0,
            shadow: false,
        };
        let jm = md.ghost;
        draw_body(c.out, &mut BodyCtx { ids, weapon_m: &kn.weapon_m, weapon_r: kn.ji.weapon_r, toon_y }, &jm, 0.0, 0.0, 0.0, &a);
    } else if q < 4.0 / 24.0 {
        draw_parts(c.out, bids, &md.ghost, None, false, None, 0.0, 1.0, None, toon_body(*toon_y), Some(kn.ghost_ink));
    } else {
        age = -2.0;
    }
    md.ghost_age = if age < -1.0 { -1.0 } else { age + dt };
}

// ---------------------------------------------------------------- the auras (draw.lisp DRAW-FIGHTER's tail, DRAW-AURA, ONI-AURA-K)

/// DRAW-FIGHTER's values its aura tail reads.
pub struct AuraIn<'a> {
    pub e: Entity,
    pub side: usize,
    /// The drawn feet with the lift (x y z), the model body's hurt height, MODEL-ALPHA, E being `*aura-off*`, the flash step, the rush
    /// module's look.
    pub p: [f32; 3],
    pub hh: f32,
    pub alpha: f32,
    pub aura_off: bool,
    pub flashing: bool,
    pub look: Option<&'a str>,
}

/// The fighters' state an aura function (ICHIGO-AURA-BASE / -KESSA) reaches: the models, the knobs, the sides' drawn places.
pub struct AuraWorld<'a, 'd> {
    pub models: &'a mut [Model<'d>],
    pub kn: &'a Knobs<'d>,
    pub m: &'a Match,
    pub sides: &'a Sides,
}

/// port: draw.lisp ONI-AURA-K — the oni pillar's presence for side I, eased toward `*oni-k-attack*` while ATTACKING.
fn oni_aura_k(c: &mut Ctx, i: usize, attacking: bool, rdt: f32) -> f32 {
    let k = c.fx.oni_k[i];
    let want = if attacking { c.fx.knobs.oni_k_attack } else { 1.0 };
    c.fx.oni_k[i] = k + (want - k) * min_f32(1.0, 10.0 * rdt);
    c.fx.oni_k[i]
}

/// port: vfx.lisp VFX-AURA's dispatch: a kit's aura function (`(funcall kind x y z h ka dt)`, KA the capped presence) or a keyword
/// kind.
#[allow(clippy::too_many_arguments)]
fn aura(c: &mut Ctx, w: &mut AuraWorld, x: f32, y: f32, z: f32, h: f32, kind: &str, dt: f32, k: f32) -> Option<&'static str> {
    match kind {
        "ICHIGO-AURA-BASE" => {
            super::ichigo::aura_base(w, x, z);
            None
        }
        "ICHIGO-AURA-KESSA" => {
            let ka = crate::fx::vfx::aura_ka(c, x, y, z, h, k);
            super::ichigo::aura_kessa(c, w, x, z, ka, dt);
            None
        }
        _ => vfx_aura(c, x, y, z, h, kind, dt, k),
    }
}

/// port: draw.lisp DRAW-AURA — side I's body AURA (crossfaded over 350 / 300 ms when it changes), height H, presence K.
#[allow(clippy::too_many_arguments)]
fn draw_aura<'d>(c: &mut Ctx<'_, 'd>, w: &mut AuraWorld, i: usize, aura_kind: Option<&'d str>, x: f32, y: f32, z: f32, h: f32, rdt: f32, k: f32) -> Option<&'static str> {
    if aura_kind != c.fx.aura_now[i] {
        (c.fx.aura_was[i], c.fx.aura_now[i], c.fx.aura_t[i]) = (c.fx.aura_now[i], aura_kind, c.clock);
    }
    let ms = (floor_f32(1000.0 * (c.clock - c.fx.aura_t[i])) as i32).min(100000);
    let mut un = None;
    if let Some(was) = c.fx.aura_was[i]
        && ms < 350
    {
        un = un.or(aura(c, w, x, y, z, h, was, rdt, k * (1.0 - ms as f32 / 350.0)));
    }
    if let Some(a) = aura_kind {
        un = un.or(if ms >= 300 {
            aura(c, w, x, y, z, h, a, rdt, k)
        } else {
            aura(c, w, x, y, z, h * (1.0 + 0.35 * (1.0 - ms as f32 / 300.0)), a, rdt, k * min_f32(1.0, 0.2 + ms as f32 / 120.0))
        });
    }
    un
}

/// port: draw.lisp DRAW-FIGHTER's aura tail: the form's aura, the bind's ash, EVOLUTION, a burst, the Breaker, the Kikon rush.
#[allow(clippy::too_many_arguments)]
fn fighter_auras<'d>(c: &mut Ctx<'_, 'd>, w: &mut AuraWorld<'_, 'd>, kit: &'d Kit, f: &Fighter, mv: Option<&Move>, a: &AuraIn, rdt: f32) -> Option<&'static str> {
    let m = w.m;
    let [x, y, z] = a.p;
    let (hh, side, look) = (a.hh, a.side, a.look);
    let mut un = None;
    if !(a.flashing || a.alpha <= 0.0 || a.aura_off) {
        let aura_kind = kit.aura.as_deref();
        // ((getf (mv-params mv) :aura-k): no in-scope move has one; moves.json's params have no such key)
        let k = if look == Some("charge") && f.phase != Some(Phase::Main) {
            1.5
        } else if mv.is_some_and(|mv| mv.kind == "kikon") && aura_kind == Some("oni") {
            0.15
        } else if aura_kind == Some("oni") {
            let attacking = mv.is_some_and(|mv| f.phase == Some(Phase::Main) && matches!(mv.kind.as_str(), "quick" | "flash" | "sp"));
            oni_aura_k(c, side, attacking, rdt)
        } else {
            1.0
        };
        un = un.or(draw_aura(c, w, side, aura_kind, x, y, z, 1.1 * hh, rdt, k));
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
        if f.phase == Some(Phase::Main) && f.sf < mv.s as i64 {
            un = un.or(vfx_aura(c, x, y, z, hh, "breaker", rdt, 1.0 + f.sf as f32 / mv.s as f32));
        }
    }
    if let Some(mv) = mv
        && mv.kind == "kikon"
        && f.state == State::Move
        && !a.flashing
        && (f.phase != Some(Phase::Main) || f.sf < mv.s as i64)
    {
        un = un.or(vfx_aura(c, x, y, z, hh, "kikon", rdt, 1.0));
    }
    un
}

// ---------------------------------------------------------------- DRAW-FIGHTER

/// What a fighter's draw reaches that the Lisp keeps in specials beside MODEL: `*draw-scale-e*` / `*draw-scale*` (CINE-SCALE's giant)
/// and `*aura-off*` (a cinematic's: Task 8 sets them; their defaults here).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct CineLooks {
    pub draw_scale_e: Option<Entity>,
    pub draw_scale: f32,
    pub aura_off: Option<Entity>,
}

impl Default for CineLooks {
    fn default() -> Self {
        CineLooks { draw_scale_e: None, draw_scale: 1.0, aura_off: None }
    }
}

/// port: draw.lisp DRAW-FIGHTER — pose and queue fighter E: body, weapon (or the planted one), the hooks, the blade's trail, the
/// auras. RDT = this frame's effect seconds. Returns the first look not ported (a Yamamoto / Hisagi fighter, hook or aura: M4).
pub fn draw_fighter(sc: &mut Scene, m: &Match, e: Entity, sides: &Sides, rdt: f32, out: &mut FrameOut) -> Option<&'static str> {
    let Scene { data, models, cos, fx, draw, fl, sounds, hums, cine, .. } = sc;
    let data: &Data = data;
    let f = m.fighter.get(e)?;
    if !matches!(f.character, Some(duel_sim::components::Character::Kenpachi | duel_sim::components::Character::Ichigo)) {
        return Some("a Yamamoto / Hisagi fighter's look (M4)");
    }
    let kit = duel_sim::fighter::kit_of(m, e);
    let mi = models.iter().position(|md| md.e == e)?;
    let mut un: Option<&'static str> = None;
    let (p, yaw) = sides.at(m, e);
    let mv = duel_sim::fighter::current_move(f).map(|id| duel_sim::fighter::mv(m, id));
    let look = mv.filter(|mv| mv.kind == "kikon" || f.phase == Some(Phase::Follow)).and_then(|mv| mv.params.look.as_deref());
    let flashing = look == Some("flash-step") && rush_dashing(m, f);
    let planted: Option<(f32, f32)> = if kit.hooks.contains_key("planted") {
        un = un.or(Some("a kit's :planted hook (Yamamoto's Bankai: M4)"));
        None
    } else {
        mv.filter(|mv| mv.planted && f.phase == Some(Phase::Main)).map(|_| (0.7, 0.0))
    };
    let dsc = if cine.draw_scale_e == Some(e) { cine.draw_scale } else { 1.0 };
    let body_name = models[mi].body;
    let b: &Body = &data.bodies[body_name];
    // ponytail: RUSH-LIFT and BODY-LIFT are 0 in scope (no in-scope move has :lift, every in-scope kit's :lift is 0); BODY-LIFT kept
    let body_lift = if kit.lift != 0.0 && kit.body == body_name { kit.lift } else { 0.0 };
    let wname = models[mi].weapon;
    let weapon = if planted.is_some() || flashing || wname.is_empty() { None } else { Some(wname) };
    let (x, z) = (p[0], p[2]);
    let y = p[1] + 0.0 + if dsc == 1.0 { body_lift } else { dsc * body_lift };
    let FighterLooks { ids, props, kn, toon_y, ke_look, ic } = fl;
    let ji = kn.ji;
    {
        let md = &mut models[mi];
        md.flash = max_f32(0.0, md.flash - rdt);
        md.sup = max_f32(0.0, md.sup - rdt);
        let pose = if md.hold > 0.0 { md.anim.pose } else { *md.anim.eval(kn.key_ease) };
        let pose = if md.beat > 0.0 { beat_pose(&pose, md.beat, &ji) } else { pose };
        let pr = &props.iter().find(|q| q.0 == body_name).expect("a ported body's proportions").1;
        pose_fk(&pose, pr, x, y, z, yaw, if dsc == 1.0 { b.scale } else { dsc * b.scale }, b.hunch, &mut md.joints);
    }
    match kit.hooks.get("pose").map(String::as_str) {
        None => {}
        Some("ICHIGO-CLOAK-POSE") => super::ichigo::cloak_pose(&mut models[mi].joints, ic, f.side as usize, draw.post.fx_clock),
        Some(_) => un = un.or(Some("a kit's :pose hook (M4)")),
    }
    {
        let md = &mut models[mi];
        let on = weapon.is_some() && md.anim.clip.is_some_and(|c| kn.grip_clips.iter().any(|g| std::ptr::eq(*g, c))) && grip_target_ok(&md.joints, &ji);
        grip_step(md, on, rdt, &ji);
        md.hold = max_f32(0.0, md.hold - rdt);
        if rdt > 0.0 {
            md.face_t = max_f32(0.0, md.face_t - rdt);
            md.beat = max_f32(0.0, md.beat - rdt);
        }
        // port: draw.lisp MOVE-BEATS — Kenpachi's SP2 dash leaves an afterimage every 10 f, once per move frame drawn
        let prev = md.last_sf;
        let now = if mv.is_some() && f.state == State::Move { f.sf } else { -1 };
        md.last_sf = now;
        if let Some(mv) = mv
            && now != prev
            && mv.name == "ke-charge"
            && f.phase == Some(Phase::Main)
            && (mv.s as i64) <= now
            && now < (mv.s + mv.a) as i64
            && (now - mv.s as i64) % 10 == 0
        {
            start_ghost(md, p, yaw);
        }
        if md.smear > 0.0 {
            let v = md.smear_dir;
            smear_joints(&mut md.joints, x, y + 1.0, z, v[0], v[1]);
            if rdt > 0.0 {
                md.smear = 0.0;
            }
        }
        if flashing && rdt > 0.0 && f.hold % 4 == 0 {
            start_ghost(md, p, yaw);
        }
    }
    let clock = draw.post.fx_clock;
    let mut c = Ctx { out: &mut *out, cam: &draw.camera, cos, fx, clock };
    draw_ghost(&mut c, &mut models[mi], ids, kn, toon_y, data, rdt);
    if models[mi].alpha >= 0.999 && !flashing {
        // (VICTIM-LOOK: the opponent kit's :victim-look hook: Yamamoto's Bankai only)
        let o = if e == m.p1 { m.p2 } else { m.p1 };
        if m.ents.alive(o) && m.fighter.get(o).is_some() && duel_sim::fighter::kit_of(m, o).hooks.contains_key("victim-look") {
            un = un.or(Some("an opponent kit's :victim-look hook (Yamamoto's Bankai: M4)"));
        }
        if kit.hooks.contains_key("body-alpha") {
            un = un.or(Some("a kit's :body-alpha hook (M4)"));
        }
        let face = face_of(m, kn, e, f, kit, &models[mi], mv);
        let face = face_accent(&mut c, m, &mut models[mi], &ji, face);
        let md = &models[mi];
        let rim = if md.sup > 0.0 {
            Some(kn.super_rim)
        } else {
            match md.rim {
                Rim::None => None,
                Rim::Mirror => Some(m.mirror_rim),
                // port: ichigo.lisp PARRY-RIM: (rim-vec #xFFFFFF (* 0.45 i)), i = level + 1; (expt 1.0 2.2) = 1
                Rim::Parry(l) => Some([0.45 * (l as f32 + 1.0); 3]),
            }
        };
        let fi = match face {
            Face::Neutral => 0,
            Face::Shout => 1,
            Face::Hurt => 2,
        };
        let args = BodyArgs {
            body: b,
            ids: &ids.bodies[body_name],
            weapon: weapon.and_then(|w| ids.weapons.get(w)).map(Vec::as_slice),
            hide: Hide { tags: md.hide, extra: &[], face: kn.face_hides[fi] },
            tint: md.tint.then_some(kn.mirror_tint),
            rim,
            flash: if md.flash > 0.0 { 0.45 } else { 0.0 },
            alpha: 1.0,
            shadow: dsc == 1.0,
        };
        draw_body(c.out, &mut BodyCtx { ids, weapon_m: &kn.weapon_m, weapon_r: ji.weapon_r, toon_y }, &md.joints, x, y, z, &args);
        if dsc != 1.0 {
            draw_shadow(c.out, ids, x, y, z, 1.2 * dsc * b.hurt_r);
        }
    }
    let shake = (&mut draw.cam.shake, draw.knobs.shake_mult);
    match kit.hooks.get("draw").map(String::as_str) {
        None => {}
        Some("KEN-DRAW") => super::ken::ken_draw(&mut c, shake, m, e, sides, &models[mi], ke_look, &kn.ken, data),
        Some("ICHIGO-DRAW") => super::ichigo::ichigo_draw(&mut c, shake, m, e, sides, &models[mi], ic, kn, data, rdt),
        Some(_) => un = un.or(Some("a kit's :draw hook (Hisagi / Yamamoto: M4)")),
    }
    let md = &mut models[mi];
    if let Some((ahead, right)) = planted
        && !md.weapon.is_empty()
    {
        draw_planted_weapon(c.out, ids, toon_y, data, md.weapon, x, z, yaw, ahead, right);
    }
    if let Some(w) = weapon
        && md.alpha > 0.5
    {
        let wd = &data.weapons[w];
        let tip = body_weapon_point(&md.joints, wd.len);
        let base = body_weapon_point(&md.joints, wd.base);
        if let Some(mv) = mv
            && f.phase == Some(Phase::Hold)
            && !mv.flags.iter().any(|x| x == "stance")
        {
            if kit.hooks.contains_key("charge") {
                un = un.or(Some("a kit's :charge hook (M4)"));
            } else {
                let full = mv.hold.as_ref().map_or(1, |h| h[1]) as f32;
                crate::fx::stamps::vfx_charge(&mut c, tip[0], tip[1], tip[2], min_f32(1.0, f.hold as f32 / full), rdt);
            }
        }
        if let Some(mv) = mv
            && f.phase == Some(Phase::Main)
            && f.sf >= (mv.s - 4) as i64
            && f.sf < (mv.s + mv.a + 3) as i64
        {
            trail_push(&mut md.trail, base, tip);
        } else {
            trail_decay(&mut md.trail);
        }
        un = un.or(vfx_smear(&mut c, &md.trail, &mut md.blade_smear, kit.smear.unwrap_or(1)));
    }
    let a = AuraIn {
        e,
        side: f.side as usize,
        p: [x, y, z],
        hh: b.hurt_h,
        alpha: models[mi].alpha,
        aura_off: cine.aura_off == Some(e),
        flashing,
        look,
    };
    let mut w = AuraWorld { models, kn, m, sides };
    un = un.or(fighter_auras(&mut c, &mut w, kit, f, mv, &a, rdt));
    if !mv.is_some_and(|mv| mv.kind == "breaker") {
        // port: feedback.lisp STOP-HUM
        let i = f.side as usize;
        if hums[i] {
            hums[i] = false;
            push_sound(sounds, SoundReq::HumStop { side: i });
        }
    }
    un
}

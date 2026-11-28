//! port: engine/lisp/anim.lisp's rig and forward kinematics (*RIG*, MAKE-RIG-PROPORTIONS' vector, %POSE-FK!, JOINT-POINT!) and
//! duel/lisp/body.lisp's held-weapon points (BODY-WEAPON-POINT / -TIP / -BASE). Matrices are column-major `[f32; 16]`, the
//! engine's layout: a point p maps to m[0..3] px + m[4..7] py + m[8..11] pz + m[12..15].
use crate::anim::Pose;
use duel_data::{Body, Rig, Weapon};
use duel_sim::math::{f_cos, f_sin};

pub type Mat4 = [f32; 16];
pub type Vec3 = [f32; 3];
/// +NJ+.
pub const NJ: usize = 21;
/// (ji :weapon-r).
pub const WEAPON_R: usize = 9;

/// Everything POSE-FK! reads besides the pose: the rig's parents, flex signs and mirrors (*RIG-PARENT*, *RIG-FSIGN*,
/// *RIG-MIRROR*) and the body's bone offsets + pelvis height (its MAKE-RIG-PROPORTIONS vector, or *RIG-OFF* and 0.98 for the
/// standard rig). Made once per body.
#[derive(Clone, Debug, PartialEq)]
pub struct Proportions {
    pub parent: [usize; NJ],
    pub fsign: [f32; NJ],
    pub mirror: [f32; NJ],
    pub off: [f32; 3 * NJ],
    pub pelvis_h: f32,
}

/// port: engine/lisp/anim.lisp JOINT-INDEX over rig.json's joints (an unknown name panics, as the Lisp's ERROR).
pub fn joint_index(rig: &Rig, name: &str) -> usize {
    rig.joints.iter().position(|j| j.name == name).unwrap_or_else(|| panic!("unknown joint {name}"))
}

impl Proportions {
    /// The body's proportions: its `props` (the image's MAKE-RIG-PROPORTIONS output, 63 offsets + the pelvis height) or, when
    /// NIL, the standard rig's *RIG-OFF* and %POSE-FK!'s literal 0.98f0. (MAKE-RIG-PROPORTIONS itself is not ported: the data
    /// holds its result.)
    pub fn of(rig: &Rig, body: &Body) -> Proportions {
        assert_eq!(rig.joints.len(), NJ, "rig.json: {} joints", rig.joints.len());
        assert_eq!(rig.joints[WEAPON_R].name, "weapon-r");
        let mut p = Proportions { parent: [0; NJ], fsign: [0.0; NJ], mirror: [0.0; NJ], off: [0.0; 3 * NJ], pelvis_h: 0.98 };
        for (j, jt) in rig.joints.iter().enumerate() {
            p.parent[j] = jt.parent.as_deref().map_or(0, |n| joint_index(rig, n)); // (the pelvis: none, never read)
            p.fsign[j] = jt.flex_sign;
            p.mirror[j] = jt.mirror;
            p.off[3 * j..3 * j + 3].copy_from_slice(&jt.offset);
        }
        if let Some(v) = &body.props {
            assert_eq!(v.len(), 3 * NJ + 1, "pose-fk!: {v:?} is not a MAKE-RIG-PROPORTIONS vector");
            p.off.copy_from_slice(&v[..3 * NJ]);
            p.pelvis_h = v[3 * NJ];
        }
        p
    }
}

/// port: engine/lisp/anim.lisp %EULER! — T(p) Ry(yaw) Rx(pitch) Rz(roll) S(s).
#[allow(clippy::too_many_arguments)]
pub(crate) fn euler(m: &mut Mat4, px: f32, py: f32, pz: f32, yaw: f32, pitch: f32, roll: f32, ss: f32) {
    let (cy, sy, cp, sp, cr, sr) = (f_cos(yaw), f_sin(yaw), f_cos(pitch), f_sin(pitch), f_cos(roll), f_sin(roll));
    *m = [
        ss * (cy * cr + sy * sp * sr),
        ss * cp * sr,
        ss * (cy * sp * sr - sy * cr),
        0.0,
        ss * (sy * sp * cr - cy * sr),
        ss * cp * cr,
        ss * (sy * sr + cy * sp * cr),
        0.0,
        ss * sy * cp,
        ss * -sp,
        ss * cy * cp,
        0.0,
        px,
        py,
        pz,
        1.0,
    ];
}

/// port: engine/lisp/anim.lisp %AFFINE-MUL! — A x B for affine column-major 4x4s.
fn affine_mul(a: &Mat4, b: &Mat4) -> Mat4 {
    let mut out = [0.0; 16];
    for c in 0..4 {
        let (b0, b1, b2, b3) = (b[c * 4], b[c * 4 + 1], b[c * 4 + 2], b[c * 4 + 3]);
        for r in 0..3 {
            out[c * 4 + r] = a[r] * b0 + a[4 + r] * b1 + a[8 + r] * b2 + a[12 + r] * b3;
        }
        out[c * 4 + 3] = b3;
    }
    out
}

/// port: engine/lisp/anim.lisp %JOINT-ROT! — T(p) Rz(side) Rx(flex) Ry(twist).
fn joint_rot(m: &mut Mat4, px: f32, py: f32, pz: f32, tw: f32, fl: f32, sd: f32) {
    let (ca, sa, cb, sb, cc, sc) = (f_cos(fl), f_sin(fl), f_cos(tw), f_sin(tw), f_cos(sd), f_sin(sd));
    *m = [
        cc * cb - sc * sa * sb,
        sc * cb + cc * sa * sb,
        -(ca * sb),
        0.0,
        -(sc * ca),
        cc * ca,
        sa,
        0.0,
        cc * sb + sc * sa * cb,
        sc * sb - cc * sa * cb,
        ca * cb,
        0.0,
        px,
        py,
        pz,
        1.0,
    ];
}

/// port: engine/lisp/anim.lisp %POSE-FK! (POSE-FK!) — each joint's world matrix into OUT from POSE, the character at
/// (PX PY PZ) facing YAW, uniform SCALE, HUNCH (rad) more spine flex, the feet levelled against pelvis / thigh / knee flex.
/// (The brief's `root: &Mat4` is not taken: the Lisp adds the pose's root yaw to YAW before one cos / sin.)
#[allow(clippy::too_many_arguments)]
pub fn pose_fk(pose: &Pose, props: &Proportions, px: f32, py: f32, pz: f32, yaw: f32, scale: f32, hunch: f32, out: &mut [Mat4; NJ]) {
    let (mut la, mut lb) = ([0.0f32; 16], [0.0f32; 16]);
    let off = &props.off;
    euler(&mut la, px, py, pz, yaw + pose[66], 0.0, 0.0, scale);
    euler(&mut lb, pose[63], props.pelvis_h + pose[64], -pose[65], 0.0, -pose[67], 0.0, 1.0);
    let root = affine_mul(&la, &lb);
    joint_rot(&mut lb, 0.0, 0.0, 0.0, pose[1], -pose[0], pose[2]);
    out[0] = affine_mul(&root, &lb);
    for j in 1..NJ {
        let (p, m, o3) = (props.parent[j], props.mirror[j], 3 * j);
        let mut fl = props.fsign[j] * pose[o3];
        let tw = m * pose[o3 + 1];
        let sd = m * pose[o3 + 2];
        if j == 1 {
            fl -= hunch;
        }
        if j == 17 || j == 20 {
            let (tj, kj) = (3 * (j - 2), 3 * (j - 1));
            fl = fl + pose[0] + -pose[tj] + pose[kj];
        }
        joint_rot(&mut lb, off[o3], off[o3 + 1], off[o3 + 2], tw, fl, sd);
        out[j] = affine_mul(&out[p], &lb);
    }
}

/// port: engine/lisp/anim.lisp JOINT-POINT! — the world position of local point L in the frame of joint matrix M.
pub fn joint_point(m: &Mat4, l: Vec3) -> Vec3 {
    let [lx, ly, lz] = l;
    [
        m[0] * lx + m[4] * ly + m[8] * lz + m[12],
        m[1] * lx + m[5] * ly + m[9] * lz + m[13],
        m[2] * lx + m[6] * ly + m[10] * lz + m[14],
    ]
}

/// port: duel/lisp/body.lisp BODY-WEAPON-POINT — the point ALONG metres down the held weapon (:weapon-r's local (0 0 -along)).
pub fn body_weapon_point(joints: &[Mat4; NJ], along: f32) -> Vec3 {
    joint_point(&joints[WEAPON_R], [0.0, 0.0, -along])
}

/// port: duel/lisp/body.lisp BODY-WEAPON-TIP.
pub fn body_weapon_tip(joints: &[Mat4; NJ], w: &Weapon) -> Vec3 {
    body_weapon_point(joints, w.len)
}

/// port: duel/lisp/body.lisp BODY-WEAPON-BASE.
pub fn body_weapon_base(joints: &[Mat4; NJ], w: &Weapon) -> Vec3 {
    body_weapon_point(joints, w.base)
}

//! port: Kenpachi's cinematics (ken.lisp, ken-look.lisp): their names, lengths and the step-mode AT events that touch sim state. Every
//! other AT form (clips, shots, cards, captions, lenses, impact frames, silences, VFX, sounds, shakes, cine-scale / cine-slow, the
//! model's body / weapon / hide, the cosmetic `rnd-range` dust and chips) and every DURING (draw mode: never run in a turbo gate, where
//! the scene is not drawn) is a look.
use crate::cine::{cine_place, face_each_other};
use crate::ecs::Entity;
use crate::math::{deg, dir_yaw, hypot};
use crate::state::Match;

/// A Kenpachi DEFCINE.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum KenCine {
    Nozarashi,
    Bankai,
    KrKikon,
    ZhKikon,
    ZKikon1,
    ZKikon2,
    ZKikon3,
    SKikon1,
    SKikon2,
}

const ALL: [(KenCine, &str, i64); 9] = [
    (KenCine::Nozarashi, "KEN-NOZARASHI-CINE", 108),
    (KenCine::Bankai, "KEN-BANKAI-CINE", 186),
    (KenCine::KrKikon, "KEN-KR-KIKON-CINE", 180),
    (KenCine::ZhKikon, "KEN-ZH-KIKON-CINE", 180),
    (KenCine::ZKikon1, "KEN-Z-KIKON1-CINE", 196),
    (KenCine::ZKikon2, "KEN-Z-KIKON2-CINE", 206),
    (KenCine::ZKikon3, "KEN-Z-KIKON3-CINE", 204),
    (KenCine::SKikon1, "KEN-S-KIKON1-CINE", 170),
    (KenCine::SKikon2, "KEN-S-KIKON2-CINE", 290),
];

impl KenCine {
    pub fn from_lisp(s: &str) -> Option<KenCine> {
        ALL.iter().find(|x| x.1 == s).map(|x| x.0)
    }
    pub fn lisp(self) -> &'static str {
        ALL.iter().find(|x| x.0 == self).unwrap().1
    }
    /// `:len`.
    pub fn frames(self) -> i64 {
        ALL.iter().find(|x| x.0 == self).unwrap().2
    }
}

/// port: KE-KK-LINE: the line V -> A for the cinematic's moves (frame 0): V's x z, the unit from him toward A.
fn kk_line(m: &mut Match, a: Entity, v: Entity) {
    let (p, q) = (crate::fighter::pos_of(m, a), crate::fighter::pos_of(m, v));
    let (dx, dz) = (p[0] - q[0], p[2] - q[2]);
    let d = crate::cl::max_f32(0.01, hypot(dx, dz));
    m.ke_kk = [q[0], q[2], dx / d, dz / d];
}

/// port: KE-KK-AT: E put S metres from the victim along the line (S < 0: past him), Y up.
fn kk_at(m: &mut Match, e: Entity, s: f32, y: f32) {
    let k = m.ke_kk;
    m.transform.get_mut(e).expect("a transform").pos = [k[0] + s * k[2], y, k[1] + s * k[3]];
}

/// port: KE-KK-YAW: E turned to the line's direction plus ANG degrees.
fn kk_yaw(m: &mut Match, e: Entity, ang: f32) {
    let k = m.ke_kk;
    m.transform.get_mut(e).expect("a transform").yaw = dir_yaw(k[2], k[3]) + deg(ang);
}

/// The step-mode AT events of script C at frame CF that touch sim state.
pub fn script(c: KenCine, cf: i64, a: Entity, v: Entity, m: &mut Match) {
    match (c, cf) {
        (KenCine::Bankai, 0) => face_each_other(m, a, v, None), // (the base body for the kneel: the hurt volume is the kit's, M1_NOTES §1)
        (KenCine::KrKikon, 0) => {
            face_each_other(m, a, v, Some(2.0));
            kk_line(m, a, v);
        }
        (KenCine::KrKikon, 130) => kk_at(m, v, -7.0, 0.0),
        (KenCine::ZhKikon, 0) => {
            face_each_other(m, a, v, Some(2.4));
            kk_line(m, a, v);
        }
        (KenCine::ZhKikon, 126) => kk_at(m, v, -7.0, 0.0),
        (KenCine::ZKikon1 | KenCine::ZKikon3, 0) => {
            cine_place(m, a, v, 3.0);
            kk_line(m, a, v);
        }
        (KenCine::ZKikon1, 78) => {
            kk_at(m, a, -1.6, 0.0);
            kk_yaw(m, a, 0.0);
        }
        (KenCine::ZKikon1, 172) => kk_at(m, v, 3.4, 0.0),
        (KenCine::ZKikon2, 0) => {
            cine_place(m, a, v, 1.9);
            kk_line(m, a, v);
        }
        (KenCine::ZKikon2, 92) => kk_at(m, v, -1.2, 0.0),
        (KenCine::ZKikon2, 140) => kk_at(m, v, 0.0, 0.0),
        (KenCine::SKikon1, 0) => {
            cine_place(m, a, v, 3.2);
            kk_line(m, a, v);
        }
        (KenCine::SKikon1, 98) => face_each_other(m, a, v, None),
        (KenCine::SKikon2, 0) => {
            cine_place(m, a, v, 2.0);
            kk_line(m, a, v);
        }
        _ => {} // KEN-NOZARASHI-CINE: looks only
    }
}

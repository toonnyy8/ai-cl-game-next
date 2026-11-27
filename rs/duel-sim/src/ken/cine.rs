//! port: Kenpachi's cinematics (ken.lisp, ken-look.lisp): their names, lengths, the step-mode AT events that touch sim state and the
//! draw-mode DURING forms that do (`draw`). Every other AT form (clips, shots, cards, captions, lenses, impact frames, silences, VFX,
//! sounds, shakes, cine-scale / cine-slow, the model's body / weapon / hide, the cosmetic `rnd-range` dust and chips) and every other
//! DURING is a look.
//!
//! A Lisp quirk kept for parity (docs/bevy/DIVERGENCES.md): the DURING forms that move an actor (KE-KK-AT / KE-KK-YAW: the victim
//! blown away, looking round; Kenpachi through him) write his TRANSFORM, sim state, from CINE-DRAW, once per rendered frame after the
//! frame's steps, with the cine frame then. A turbo gate never draws (no write); a played cinematic (VS CPU) does, and the actors'
//! places then show in H and B until CINE-END gives the CINE-SAVE'd ones back (a yaw never: it stays as the last drawn frame left it).
use crate::cine::{cine_place, face_each_other};
use crate::ecs::Entity;
use crate::cl::{expt2, min_f32};
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
    m.cine.as_mut().expect("a cinematic").line = [q[0], q[2], dx / d, dz / d];
}

/// port: KE-KK-AT: E put S metres from the victim along the line (S < 0: past him), Y up.
fn kk_at(m: &mut Match, e: Entity, s: f32, y: f32) {
    let k = m.cine.as_ref().expect("a cinematic").line;
    m.transform.get_mut(e).expect("a transform").pos = [k[0] + s * k[2], y, k[1] + s * k[3]];
}

/// port: KE-KK-YAW: E turned to the line's direction plus ANG degrees.
fn kk_yaw(m: &mut Match, e: Entity, ang: f32) {
    let k = m.cine.as_ref().expect("a cinematic").line;
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

/// port: the draw mode of script C (CINE-DRAW's call, STEP-P NIL) at cine frame CF: its DURING forms that write sim state, each with U
/// 0..1 across its range (`(/ (float (- cf from)) (float (- to from)))`, singles). `(expt x 2)` is ECL's powf (`expt2`).
pub fn draw(c: KenCine, cf: i64, a: Entity, v: Entity, m: &mut Match) {
    // (the scripts' own literals, not pi: `(sin (* 3.1416 u))`, `(* 6.2832 …)`)
    #[allow(clippy::approx_constant)]
    const PI4: f32 = 3.1416;
    #[allow(clippy::approx_constant)]
    const TAU4: f32 = 6.2832;
    let during = |from: i64, to: i64| (from <= cf && cf < to).then(|| (cf - from) as f32 / (to - from) as f32);
    let blown = |u: f32| 1.0 - expt2(1.0 - u);
    match c {
        KenCine::KrKikon => {
            if let Some(u) = during(108, 130) {
                kk_at(m, v, -7.0 * blown(u), 1.6 * libm::sinf(PI4 * u)); // (blown away)
            }
        }
        KenCine::ZhKikon => {
            if let Some(u) = during(104, 126) {
                kk_at(m, v, -7.0 * blown(u), 1.4 * libm::sinf(PI4 * u));
            }
        }
        KenCine::ZKikon1 => {
            if let Some(u) = during(78, 108) {
                kk_yaw(m, v, 55.0 * libm::sinf(TAU4 * min_f32(1.0, 1.15 * u))); // (he looks left, right)
            }
            if let Some(u) = during(108, 122) {
                let k = u * u * (3.0 - 2.0 * u);
                kk_yaw(m, v, 120.0 * k); // (over his shoulder, turning back; the camera is a look)
            }
            if let Some(u) = during(144, 172) {
                kk_at(m, v, 3.4 * blown(u), 2.6 * libm::sinf(PI4 * u)); // (up and away from him)
            }
        }
        KenCine::SKikon1 => {
            if let Some(u) = during(76, 90) {
                kk_at(m, a, 3.2 - 6.4 * min_f32(1.0, 1.2 * u), 0.0); // (through him)
            }
            if let Some(u) = during(98, 112) {
                kk_at(m, a, -3.2 + 5.2 * u, 0.0); // (spun back through him)
            }
        }
        KenCine::SKikon2 => {
            if let Some(u) = during(77, 125) {
                kk_at(m, v, 0.0, 5.0 * blown(u)); // (up ...)
            }
            if let Some(u) = during(125, 196) {
                kk_at(m, v, 0.0, 5.0 + 0.2 * min_f32(1.0, u / 0.6)); // (... hung at the top)
            }
            if let Some(u) = during(196, 228) {
                kk_at(m, v, 0.0, 5.2 * (1.0 - u * u)); // (cut down)
            }
            if let Some(u) = during(122, 152) {
                kk_at(m, a, 2.0 - 0.9 * u, 5.8 * blown(u)); // (the leap skyward)
            }
            if let Some(u) = during(152, 196) {
                kk_at(m, a, 1.1, 5.8 + 0.1 * u); // (arched over him, the cut, held)
            }
            if let Some(u) = during(196, 228) {
                kk_at(m, a, 1.1 - 0.3 * u, 5.9 * (1.0 - u * u)); // (and down with him)
            }
        }
        KenCine::Nozarashi | KenCine::Bankai | KenCine::ZKikon2 | KenCine::ZKikon3 => {} // (looks only)
    }
}

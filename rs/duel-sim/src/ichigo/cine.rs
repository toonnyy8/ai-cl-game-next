//! port: Ichigo's cinematics (ichigo-look.lisp): their names, lengths and the step-mode events that touch sim state: FACE-EACH-OTHER
//! (no CINE-PLACE in his), and 血鎖's reel-in, a step-mode form run on frames 89-99. Every other AT form (clips, shots, cards, captions,
//! lenses, impact frames, silences, VFX, sounds, shakes, the stage's cracks, the model's weapon / hide, *aura-off*, the sky colours,
//! cine-shatter) and every DURING (draw mode, CINE-DRAW: VFX, cameras, the `*ic-w*` scratch; none writes sim state) is a look.
use crate::cine::face_each_other;
use crate::ecs::Entity;
use crate::state::Match;

/// An Ichigo DEFCINE the sim can start (IC-HASTE-KIKON-CINE: pointer 4's, left 2026-11, reached by debug 86110 only; the preview /
/// still cinematics are debug).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum IcCine {
    Kikon,
    KessaKikon,
    KessaGetsuga,
    HeavyKikon,
    RushKikon,
    ChainKikon,
    Kessa,
    Haste,
}

const ALL: [(IcCine, &str, i64, i64); 8] = [
    (IcCine::Kikon, "IC-KIKON-CINE", 186, 150),
    (IcCine::KessaKikon, "IC-KESSA-KIKON-CINE", 192, 124),
    (IcCine::KessaGetsuga, "IC-KESSA-GETSUGA-CINE", 180, 124),
    (IcCine::HeavyKikon, "IC-HEAVY-KIKON-CINE", 180, 124),
    (IcCine::RushKikon, "IC-RUSH-KIKON-CINE", 180, 124),
    (IcCine::ChainKikon, "IC-CHAIN-KIKON-CINE", 180, 124),
    (IcCine::Kessa, "IC-KESSA-CINE", 168, 120),
    (IcCine::Haste, "IC-HASTE-KIKON-CINE", 160, 110),
];

impl IcCine {
    pub fn from_lisp(s: &str) -> Option<IcCine> {
        ALL.iter().find(|x| x.1 == s).map(|x| x.0)
    }
    pub fn lisp(self) -> &'static str {
        ALL.iter().find(|x| x.0 == self).unwrap().1
    }
    /// `:len`.
    pub fn frames(self) -> i64 {
        ALL.iter().find(|x| x.0 == self).unwrap().2
    }
    /// `:hold`.
    pub fn hold_frame(self) -> i64 {
        ALL.iter().find(|x| x.0 == self).unwrap().3
    }
}

/// The step-mode events of script C at frame CF that touch sim state.
pub fn script(c: IcCine, cf: i64, a: Entity, v: Entity, m: &mut Match) {
    use IcCine::*;
    let gap = match (c, cf) {
        (Kessa, _) => None, // (the weapon, the hide, *aura-off*: looks)
        (_, 0) => Some(match c {
            KessaGetsuga => 6.0,
            _ => 2.6,
        }),
        (Kikon, 70) | (ChainKikon, 52) => Some(7.0),
        (KessaKikon, 120) | (RushKikon, 118) | (Haste, 106) => Some(3.2),
        (HeavyKikon, 52) => Some(4.2),
        (RushKikon, 104) => Some(2.4),
        // 血鎖: reeled in, 7 m -> 2.2 m ((- 7.0 (* 0.4 (- cf 88))): a single times a fixnum)
        (ChainKikon, 89..=99) => Some(7.0 - 0.4 * (cf - 88) as f32),
        _ => None,
    };
    if let Some(g) = gap {
        face_each_other(m, a, v, Some(g));
    }
}

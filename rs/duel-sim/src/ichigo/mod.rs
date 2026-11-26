//! port: duel/lisp/ichigo.lisp (and ichigo-look.lisp's cinematics) — Kurosaki Ichigo's sim side: his kits' hooks and his moves'
//! frame / land hooks (`hooks`), KESSA's clones, their strikes, the afterimages and the waves (`clones`), his cinematics' step events
//! (`cine`). His looks (ICHIGO-DRAW, -CLOAK-POSE, -DECK, -HUD-TAG / -LABEL, the auras, the look functions of his hazards), the pacing
//! counters (PACE, IC-KEY), his CPU (ICHIGO-AI-*, IC-P), the debug / test functions and ICHIGO-AB-GATE are not here.
pub mod cine;
pub mod clones;
pub mod hooks;

use crate::ecs::Entity;
use crate::state::Match;

/// An Ichigo hook symbol of the data (kits.json's `:hooks`, moves.json's `:on-frame` / `:on-land`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Hook {
    // the kits' :hooks (typed: each call site passes its own arguments; :tick takes E only)
    Hit,
    Ok,
    Struck,
    Catch,
    Threat,
    KikonWorth,
    Tick,
    // the moves' frame / land hooks: FIGHTER E only (`call`)
    Charge1,
    Charge2,
    GaeshiPull,
    Getsuga,
    HasteDash,
    Juji,
    JujiFirst,
    NsCloneA,
    NsCloneB,
    NsCloneX,
    NsXMark,
    ParryOpen,
    Renzan1,
    Renzan2,
    Renzan3,
    SogaVanish,
    TsukiDash,
    TsukiReturn,
    ZanzoOn,
    Pull,
}

const NAMES: [(&str, Hook); 27] = {
    use Hook::*;
    [
        ("ICHIGO-HIT", Hit), ("ICHIGO-OK", Ok), ("ICHIGO-STRUCK", Struck), ("ICHIGO-CATCH", Catch), ("ICHIGO-THREAT", Threat),
        ("ICHIGO-KIKON-WORTH", KikonWorth), ("ICHIGO-TICK", Tick), ("ICHIGO-CHARGE-1", Charge1), ("ICHIGO-CHARGE-2", Charge2),
        ("ICHIGO-GAESHI-PULL", GaeshiPull), ("ICHIGO-GETSUGA", Getsuga), ("ICHIGO-HASTE-DASH", HasteDash), ("ICHIGO-JUJI", Juji),
        ("ICHIGO-JUJI-FIRST", JujiFirst), ("ICHIGO-NS-CLONE-A", NsCloneA), ("ICHIGO-NS-CLONE-B", NsCloneB),
        ("ICHIGO-NS-CLONE-X", NsCloneX), ("ICHIGO-NS-X-MARK", NsXMark), ("ICHIGO-PARRY-OPEN", ParryOpen),
        ("ICHIGO-RENZAN-1", Renzan1), ("ICHIGO-RENZAN-2", Renzan2), ("ICHIGO-RENZAN-3", Renzan3), ("ICHIGO-SOGA-VANISH", SogaVanish),
        ("ICHIGO-TSUKI-DASH", TsukiDash), ("ICHIGO-TSUKI-RETURN", TsukiReturn), ("ICHIGO-ZANZO-ON", ZanzoOn), ("ICHIGO-PULL", Pull),
    ]
};

/// His looks the data names as hooks (`:draw`, `:pose`, `:deck`, `:hud-tag`): the sim never calls them.
pub const LOOKS: [&str; 4] = ["ICHIGO-DRAW", "ICHIGO-CLOAK-POSE", "ICHIGO-DECK", "ICHIGO-HUD-TAG"];

impl Hook {
    pub fn from_name(s: &str) -> Option<Hook> {
        NAMES.iter().find(|(n, _)| *n == s).map(|&(_, h)| h)
    }
}

/// FUNCALL of a hook that takes only E (a move's frame / land hook, the forms' :tick): T (the run goes on). A typed kit hook (:hit,
/// :ok, …) is called at its own site, never through here.
pub fn call(m: &mut Match, e: Entity, h: Hook) -> bool {
    use clones::*;
    use hooks::*;
    match h {
        Hook::Tick => tick(m, e),
        Hook::Charge1 | Hook::Charge2 | Hook::SogaVanish => {} // look: emit :sfx :getsuga / :hoho-out
        Hook::GaeshiPull => {
            let d = move_param(m, e).pull.expect("ZANGETSU-GAESHI's :pull");
            pull_opp_to(m, e, d, 6);
        }
        Hook::Pull => {
            let d = move_param(m, e).pull.expect("KUSARI-BIKI's :pull");
            pull_opp_to(m, e, d, 10);
        }
        Hook::Getsuga | Hook::Juji => {
            let look = crate::components::Sym(move_param(m, e).look.as_deref().expect("a wave's :look"));
            wave(m, e, look); // look: emit :sfx :getsuga
        }
        Hook::JujiFirst => juji_first(m, e),
        Hook::HasteDash => haste_dash(m, e),
        Hook::NsCloneA => {
            ns_clone(m, e, 1, Src::NsA);
        }
        Hook::NsCloneB => {
            ns_clone(m, e, -1, Src::NsB);
        }
        Hook::NsCloneX => ns_clone_x(m, e),
        Hook::NsXMark => ns_x_mark(m, e),
        Hook::ParryOpen => parry_open(m, e),
        Hook::Renzan1 => renzan(m, e, "ic-k-rz-a", 1),
        Hook::Renzan2 => renzan(m, e, "ic-k-rz-a", 2),
        Hook::Renzan3 => renzan(m, e, "ic-k-rz-b", 3),
        Hook::TsukiDash => tsuki_dash(m, e),
        Hook::TsukiReturn => tsuki_return(m, e),
        Hook::ZanzoOn => zanzo_on(m, e),
        Hook::Hit | Hook::Ok | Hook::Struck | Hook::Catch | Hook::Threat | Hook::KikonWorth => {
            unreachable!("{h:?} takes its own arguments: called at its own site")
        }
    }
    m.unported.is_none()
}

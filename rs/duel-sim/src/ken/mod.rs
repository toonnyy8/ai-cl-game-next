//! port: duel/lisp/ken.lisp (and ken-look.lisp's cinematics) — Zaraki Kenpachi's sim side: his kits' hooks and his moves' frame /
//! tick / release / land hooks (`hooks`), his cinematics' step events (`cine`). His looks (KEN-DRAW, KEN-BK-HIT-FX, KEN-HUD-LABEL,
//! the forest card, the sword wind), his CPU lines and KEN-DEBUG / KEN-CORE-DEBUG are not here.
pub mod cine;
pub mod hooks;

use crate::ecs::Entity;
use crate::state::Match;

/// A Kenpachi hook symbol of the data (kits.json's `:hooks`, moves.json's `:on-frame` / `:tick` / `:release` / `:on-land`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Hook {
    // the kits' :hooks (typed: each call site passes its own arguments)
    Armor,
    AsPick,
    DmgMult,
    Hit,
    LinkOk,
    Lv,
    // FIGHTER E only (`call`)
    BkTick,
    BankaiBurst,
    BankaiEnter,
    BkCost,
    BkSlam,
    BkSpecial,
    ChigiriBurst,
    ChigiriOpen,
    ChigiriQuake,
    ChigiriStill,
    GroundCrack,
    TategotoCut,
    TategotoSplit,
    Flurry,
    StanceRelease,
    ChargeTick,
}

const NAMES: [(&str, Hook); 22] = {
    use Hook::*;
    [
        ("KEN-ARMOR", Armor), ("KEN-AS-PICK", AsPick), ("KEN-DMG-MULT", DmgMult), ("KEN-HIT", Hit), ("KEN-LINK-OK", LinkOk),
        ("KEN-LV", Lv), ("KEN-BK-TICK", BkTick), ("KEN-BANKAI-BURST", BankaiBurst), ("KEN-BANKAI-ENTER", BankaiEnter),
        ("KEN-BK-COST", BkCost), ("KEN-BK-SLAM", BkSlam), ("KEN-BK-SPECIAL", BkSpecial), ("KEN-CHIGIRI-BURST", ChigiriBurst),
        ("KEN-CHIGIRI-OPEN", ChigiriOpen), ("KEN-CHIGIRI-QUAKE", ChigiriQuake), ("KEN-CHIGIRI-STILL", ChigiriStill),
        ("KEN-GROUND-CRACK", GroundCrack), ("KEN-TATEGOTO-CUT", TategotoCut), ("KEN-TATEGOTO-SPLIT", TategotoSplit),
        ("KEN-FLURRY", Flurry), ("KEN-STANCE-RELEASE", StanceRelease), ("KEN-CHARGE-TICK", ChargeTick),
    ]
};

/// His looks the data names as hooks (`:draw`, `:hit-fx`): the sim never calls them.
pub const LOOKS: [&str; 2] = ["KEN-DRAW", "KEN-BK-HIT-FX"];

impl Hook {
    pub fn from_name(s: &str) -> Option<Hook> {
        NAMES.iter().find(|(n, _)| *n == s).map(|&(_, h)| h)
    }
}

/// FUNCALL of a hook that takes only E (a move's frame / tick / release / land hook, the Bankai kits' :tick): T (the run goes on).
/// A typed kit hook (:armor, :dmg-mult, …) is called at its own site, never through here.
pub fn call(m: &mut Match, e: Entity, h: Hook) -> bool {
    use hooks::*;
    match h {
        Hook::BkTick => bk_tick(m, e),
        Hook::BankaiBurst | Hook::ChigiriStill | Hook::ChigiriQuake => {} // look: emit :ken-bk-burst
        Hook::BankaiEnter => bankai_enter(m, e),
        Hook::BkCost => bk_cost(m, e),
        Hook::BkSlam => bk_slam(m, e),
        Hook::BkSpecial => bk_special(m, e),
        Hook::ChigiriBurst => chigiri_burst(m, e),
        Hook::ChigiriOpen => chigiri_open(m, e),
        Hook::GroundCrack => ground_crack(m, e),
        Hook::TategotoCut => tategoto_cut(m, e),
        Hook::TategotoSplit => tategoto_split(m, e),
        Hook::Flurry => flurry(m, e),
        Hook::StanceRelease => stance_release(m, e),
        Hook::ChargeTick => charge_tick(m, e),
        Hook::Armor | Hook::AsPick | Hook::DmgMult | Hook::Hit | Hook::LinkOk | Hook::Lv => {
            panic!("{h:?} takes its own arguments: called at its own site")
        }
    }
    m.unported.is_none()
}

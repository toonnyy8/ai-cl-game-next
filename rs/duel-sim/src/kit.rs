//! port: duel/lisp/kit.lisp — the move / kit readers the sim calls, and the kits' hook tables. The kit data itself
//! (`parse-move`, `register-kit`, `build-core-classes`, `build-sp-costs`) is already built in `duel_data` (Kit.cls, Kit.sp).
use crate::sp::sp_start_p;
use duel_data::{Data, Kit, Move, MoveClass};

// port: kit.lisp FIND-MOVE (the global *moves* table; NIL = None)
// ponytail: a linear scan over 549 moves; index by name if a hot path calls it.
pub fn find_move<'d>(data: &'d Data, name: &str) -> Option<&'d Move> {
    data.moves.iter().find(|m| mv_name(m) == name)
}

/// MV-NAME: a move's symbol name (the data id is `character/form/name`; names are unique across the data).
pub fn mv_name(mv: &Move) -> &str {
    short(&mv.id)
}

fn short(id: &str) -> &str {
    id.rsplit('/').next().unwrap_or(id)
}

// port: kit.lisp KIT-MOVE — NAME among the kit's moves (Kit.moves holds their data ids).
pub fn kit_move<'d>(data: &'d Data, kit: &Kit, name: &str) -> Option<&'d Move> {
    let id = kit.moves.iter().find(|id| short(id) == name)?;
    data.moves.iter().find(|m| &m.id == id)
}

// port: kit.lisp MV-TOTAL
pub fn mv_total(mv: &Move) -> i64 {
    (mv.s + mv.a + mv.r) as i64
}

// port: kit.lisp MV-FIRST-HIT
pub fn mv_first_hit(mv: &Move) -> i64 {
    mv.hits.first().map_or(mv.s, |w| w.from) as i64
}

// port: kit.lisp MOVE-ACTIVE-END
pub fn move_active_end(mv: &Move) -> i64 {
    mv.hits.iter().map(|w| w.to).max().unwrap_or(mv.s + mv.a) as i64
}

// port: kit.lisp RANGED-WINDOW-LEAD (NIL = None)
pub fn ranged_window_lead(mv: &Move, sf: i64) -> Option<i64> {
    mv.hits.iter().filter(|w| w.flags.iter().any(|f| f == "ranged") && sf < w.to as i64).map(|w| 0.max(w.from as i64 - sf)).min()
}

// port: kit.lisp NEXT-WINDOW-LEAD (USED: the bit set of windows already used)
pub fn next_window_lead(mv: &Move, sf: i64, used: i64) -> Option<i64> {
    mv.hits
        .iter()
        .enumerate()
        .filter(|&(i, w)| sf + 1 < w.to as i64 && (used >> i) & 1 == 0)
        .map(|(_, w)| 1.max(w.from as i64 - sf))
        .min()
}

// port: kit.lisp MV-SP-DAMAGE
pub fn mv_sp_damage(mv: &Move) -> i64 {
    let h: i64 = mv.hits.iter().map(|w| w.dmg as i64).sum();
    if h > 0 { h } else { mv.params.dmg.unwrap_or(0) as i64 }
}

// port: kit.lisp KIT-SP-COST (the cost table BUILD-SP-COSTS filled: Kit.sp; NIL = None)
pub fn kit_sp_cost(kit: &Kit, mv: Option<&Move>) -> Option<f32> {
    kit.sp.get(mv_name(mv?)).copied()
}

// port: kit.lisp KIT-CLASS (Kit.cls, BUILD-CORE-CLASSES's table)
pub fn kit_class(kit: &Kit, mv: Option<&Move>) -> Option<MoveClass> {
    kit.cls.get(&mv?.id).copied() // (Kit.cls is keyed by data id: the Lisp table by move object)
}

// port: kit.lisp KIT-SP-FREE-P
pub fn kit_sp_free_p(kit: &Kit) -> bool {
    kit.core.sp_free
}

// port: kit.lisp KIT-SP-START-P (BURSTING: any burst mode)
pub fn kit_sp_start_p(kit: &Kit, mv: &Move, fs: f32, bursting: bool) -> bool {
    kit_sp_cost(kit, Some(mv)).is_none()
        || sp_start_p(kit_class(kit, Some(mv)), kit.core.ns.iter().any(|n| n == mv_name(mv)), fs, bursting || kit_sp_free_p(kit))
}

/// A core role of KIT-CORE-MOVE.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Role {
    Ns,
    As,
}

// port: kit.lisp KIT-CORE-MOVE (N from 1)
pub fn kit_core_move<'d>(data: &'d Data, kit: &Kit, role: Role, n: i64) -> Option<&'d Move> {
    let names = match role {
        Role::Ns => &kit.core.ns,
        Role::As => &kit.core.as_segs,
    };
    let name = names.get(usize::try_from(n - 1).ok()?)?;
    kit_move(data, kit, name)
}

// port: kit.lisp KIT-SA-MOVE
pub fn kit_sa_move<'d>(data: &'d Data, kit: &Kit) -> Option<&'d Move> {
    kit_move(data, kit, &kit.core.sa)
}

// port: kit.lisp MV-SA-MOVE
pub fn mv_sa_move<'d>(data: &'d Data, kit: &Kit, mv: &Move) -> Option<&'d Move> {
    kit_move(data, kit, mv.params.sa.as_deref()?)
}

// port: kit.lisp MV-NS-NEXT
pub fn mv_ns_next<'d>(data: &'d Data, kit: &Kit, mv: &Move) -> Option<&'d Move> {
    kit_move(data, kit, mv.params.ns_next.as_deref()?)
}

// ---------------------------------------------------------------- hooks (KIT-HOOK)

/// The hook points of a kit's `:hooks` plist (every key the data uses).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum HookKey {
    Armor, ArmoredFx, AsPick, Cancel, Clash, Command, Deck, DmgMult, Draw, Hash, Hit, HitFx, HudTag, KikonN, KikonWorth,
    LinkMove, LinkOk, Lv, MinReach, Ok, Parried, Planted, Pose, Reset, SoulBreakCine, SpGainMult, StepDist, Struck, Threat,
    Tick, Unscaled, VictimLook,
}

const HOOK_NAMES: [(&str, HookKey); 32] = {
    use HookKey::*;
    [
        ("armor", Armor), ("armored-fx", ArmoredFx), ("as-pick", AsPick), ("cancel", Cancel), ("clash", Clash),
        ("command", Command), ("deck", Deck), ("dmg-mult", DmgMult), ("draw", Draw), ("hash", Hash), ("hit", Hit),
        ("hit-fx", HitFx), ("hud-tag", HudTag), ("kikon-n", KikonN), ("kikon-worth", KikonWorth), ("link-move", LinkMove),
        ("link-ok", LinkOk), ("lv", Lv), ("min-reach", MinReach), ("ok", Ok), ("parried", Parried), ("planted", Planted),
        ("pose", Pose), ("reset", Reset), ("soul-break-cine", SoulBreakCine), ("sp-gain-mult", SpGainMult),
        ("step-dist", StepDist), ("struck", Struck), ("threat", Threat), ("tick", Tick), ("unscaled", Unscaled),
        ("victim-look", VictimLook),
    ]
};

impl HookKey {
    pub fn from_name(s: &str) -> Option<HookKey> {
        HOOK_NAMES.iter().find(|(n, _)| n.eq_ignore_ascii_case(s)).map(|&(_, k)| k)
    }
}

/// A resolved hook function. Each hook point has its own signature, so the kit tasks (11 Kenpachi, 12 Ichigo) add one
/// variant per ported function; until then every known kit symbol resolves to `Unported`, whose caller hits `unported!`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum HookFn {
    Unported,
}

/// A kit's hook table: one slot per hook key.
#[derive(Debug, Clone, Default)]
pub struct Hooks(pub [Option<HookFn>; 32]);

// port: the symbol a defkit's :hooks names → its function. A Kenpachi / Ichigo symbol is a load error once its task ports
// the kit (today all four characters' symbols are `Unported` stubs); any other unknown symbol is None (a load error).
pub fn resolve(name: &str) -> Option<HookFn> {
    const KITS: [&str; 7] = ["KEN-", "ICHIGO-", "IC-", "HS-", "HISAGI-", "YAMA-", "YAMAMOTO-"];
    KITS.iter().any(|p| name.starts_with(p)).then_some(HookFn::Unported)
}

/// The kit's hook table from its data (`Kit.hooks`, key → symbol), or an error naming a key / symbol that does not resolve.
pub fn hooks_of(kit: &Kit) -> Result<Hooks, String> {
    let mut h = Hooks::default();
    for (key, sym) in &kit.hooks {
        let k = HookKey::from_name(key).ok_or_else(|| format!("kit {} {}: unknown hook key {key}", kit.character, kit.form))?;
        h.0[k as usize] = Some(resolve(sym).ok_or_else(|| format!("kit {} {}: hook {key} names {sym}, not ported", kit.character, kit.form))?);
    }
    Ok(h)
}

// port: kit.lisp KIT-HOOK
pub fn kit_hook(hooks: &Hooks, key: HookKey) -> Option<HookFn> {
    hooks.0[key as usize]
}

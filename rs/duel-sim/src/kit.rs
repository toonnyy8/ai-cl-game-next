//! port: duel/lisp/kit.lisp — the move / kit readers the sim calls, and the kits' hook tables. The kit data itself
//! (`parse-move`, `register-kit`, `build-core-classes`, `build-sp-costs`) is already built in `duel_data` (Kit.cls, Kit.sp).
use crate::sp::sp_start_p;
use duel_data::{Data, Kit, Move, MoveClass};

// port: kit.lisp FIND-MOVE (the global *moves* table; NIL = None)
// ponytail: a linear scan over 549 moves; index by name if a hot path calls it.
pub fn find_move<'d>(data: &'d Data, name: &str) -> Option<&'d Move> {
    data.moves.iter().find(|m| mv_name(m) == name)
}

/// MV-NAME: a move's symbol name (`Move.name`; the data id is `character/form/name`, or `var/moves/name#0` for a move in no
/// kit, Ichigo's clone X, so the id's last segment is not the name).
pub fn mv_name(mv: &Move) -> &str {
    &mv.name
}


// port: kit.lisp KIT-MOVE — NAME among the kit's moves (Kit.moves holds their data ids; `Kit.move_ix` indexes them by name: the
// first entry of a name, as FIND's).
pub fn kit_move<'d>(data: &'d Data, kit: &Kit, name: &str) -> Option<&'d Move> {
    let ix = &kit.move_ix;
    let (n, i) = ix.get(ix.partition_point(|(n, _)| n.as_str() < name))?;
    (n == name).then(|| i.map(|i| &data.moves[i as usize]))?
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

// port: kit.lisp WINDOW-TOUCHES-P (ATT: the attacker, for a :seg-fn window's capsule)
#[allow(clippy::too_many_arguments)]
pub fn window_touches_p(
    m: &mut crate::state::Match, w: &'static duel_data::HitWin, _att: crate::ecs::Entity, ax: f32, ay: f32, az: f32, fx: f32,
    fz: f32, tx: f32, ty: f32, tz: f32, tr: f32, th: f32,
) -> bool {
    if let Some(seg) = &w.seg {
        crate::unported!(m, seg.as_str(), false); // (a :seg-fn: Hisagi's, M4)
    }
    w.vols.iter().any(|v| crate::hitvol::vol_hit_p(v, ax, ay, az, fx, fz, tx, ty, tz, tr, th, 0.0))
}

// port: kit.lisp SEG-GAP (NIL = None: no window of MV has a :seg-fn, every Kenpachi / Ichigo move)
pub fn seg_gap(m: &mut crate::state::Match, mv: &'static Move, _att: crate::ecs::Entity, _tx: f32, _tz: f32) -> Option<f32> {
    if let Some(seg) = mv.hits.iter().find_map(|w| w.seg.as_ref()) {
        crate::unported!(m, seg.as_str(), None); // (a :seg-fn: Hisagi's, M4)
    }
    None
}

// port: kit.lisp FIND-KIT (an unknown kit is the Lisp's ERROR: a panic naming it)
pub fn find_kit<'d>(data: &'d Data, character: &str, form: &str) -> &'d Kit {
    data.kits.kits.get(character).and_then(|f| f.get(form)).unwrap_or_else(|| panic!("unknown kit {character} {form}"))
}

// port: kit.lisp KIT-COMMAND-MOVE (without E: the :command hook is Hisagi's, M4; the form's :commands entry)
pub fn kit_command_move<'d>(data: &'d Data, kit: &Kit, command: &str) -> Option<&'d Move> {
    kit_move(data, kit, kit.commands.get(command)?.as_deref()?)
}

// port: kit.lisp KIT-NEXT
pub fn kit_next<'d>(data: &'d Data, kit: &Kit, move_name: &str, command: &str) -> Option<&'d Move> {
    let [_, _, to] = kit.strings.iter().find(|[from, cmd, _]| from == move_name && cmd == command)?;
    kit_move(data, kit, to)
}

// port: kit.lisp STRING-LINK-P
pub fn string_link_p(data: &Data, kit: &Kit, move_name: &str) -> bool {
    kit_next(data, kit, move_name, "q").is_some() || kit_next(data, kit, move_name, "f").is_some()
}

fn link_p(kit: &Kit, move_name: &str, command: &str) -> bool {
    kit.commands.get(command).is_some_and(|n| n.as_deref() == Some(move_name))
        || kit.strings.iter().any(|[_, cmd, to]| cmd == command && to == move_name)
}

// port: kit.lisp KIT-K-LINK-P
pub fn kit_k_link_p(kit: &Kit, move_name: &str) -> bool {
    link_p(kit, move_name, "f")
}

// port: kit.lisp KIT-J-LINK-P
pub fn kit_j_link_p(kit: &Kit, move_name: &str) -> bool {
    link_p(kit, move_name, "q")
}

// port: kit.lisp KIT-L-LINK ("T" = the form's :sig; a per-link plist, Rukia's, is not in the live data)
pub fn kit_l_link<'d>(data: &'d Data, kit: &Kit, move_name: &str) -> Option<&'d Move> {
    let l = if kit_k_link_p(kit, move_name) {
        kit.l_after_k.as_deref()
    } else if kit_j_link_p(kit, move_name) {
        kit.l_after_j.as_deref()
    } else {
        None
    }?;
    if l.eq_ignore_ascii_case("t") { kit_command_move(data, kit, "sig") } else { kit_move(data, kit, l) }
}

// port: kit.lisp STRING-LATCH (QUEUED / the result: the latched command, NIL = None)
pub fn string_latch<'a>(data: &Data, kit: &Kit, move_name: &str, command: &'a str, queued: Option<&'a str>) -> Option<&'a str> {
    if kit_next(data, kit, move_name, command).is_some() { Some(command) } else { queued }
}

// port: kit.lisp STRING-OPENER-P (without E, as KIT-COMMAND-MOVE)
pub fn string_opener_p(data: &Data, kit: &Kit, mv: &Move) -> bool {
    matches!(mv.kind.as_str(), "quick" | "flash")
        && !mv.flags.iter().any(|f| f == "no-close")
        && kit_command_move(data, kit, if mv.kind == "quick" { "q" } else { "f" }).is_some_and(|c| c.id == mv.id)
}

// port: kit.lisp MOVE-EDGE (a capsule volume: shape tag 1.0, radius at index 4)
pub fn move_edge(mv: &Move) -> f32 {
    match mv.hits.first().and_then(|w| w.vols.first()) {
        Some(v) if v[0] == 1.0 => mv.reach + v[4],
        _ => mv.reach,
    }
}

// port: kit.lisp SP-MOVE-P
pub fn sp_move_p(data: &Data, kit: &Kit, mv: &Move) -> bool {
    let is = |c| kit_command_move(data, kit, c).is_some_and(|x| x.id == mv.id);
    mv.kind == "sp" || is("sp1") || is("sp2")
}

// port: kit.lisp ENDER-PUSH-REACH
pub fn ender_push_reach(kit: &Kit, mv: &Move, opener: &Move) -> f32 {
    match kit.push_reach {
        Some(r) if mv.kind != "quick" => r,
        _ => move_edge(opener),
    }
}

// port: kit.lisp KIT-KIKON-CINE (the form's :soul-break-cine hook, else its :kikon move's :cine, else SOUL-BREAK-CINE)
pub fn kit_kikon_cine<'d>(data: &'d Data, kit: &'d Kit) -> &'d str {
    kit.hooks
        .get("soul-break-cine")
        .map(String::as_str)
        .or_else(|| kit_command_move(data, kit, "kikon").and_then(|m| m.cine.as_deref()))
        .unwrap_or("SOUL-BREAK-CINE")
}

// port: kit.lisp STUN-TOLERANCE-OF
pub fn stun_tolerance_of(k: &crate::knobs::Knobs, kit: &Kit) -> f32 {
    kit.stun_tolerance.unwrap_or(k.stun_tolerance)
}

// port: kit.lisp KIT-ATK-MODS (FORM-MULT: a move's :params :form-mult, NIL = None; a kit has a :core when it has NS routes)
pub fn kit_atk_mods(k: &crate::knobs::Knobs, kit: &Kit, lost: i64, hit_x: f32, form_mult: Option<f32>) -> crate::rules::AtkMods {
    let core = if kit.core.ns.is_empty() { 1.0 } else { k.core_damage * kit.core.mult };
    crate::rules::AtkMods { mult: form_mult.unwrap_or(kit.mult) * hit_x * core, cornered: kit.cornered, cornered_max: kit.cornered_max, lost }
}

// port: kit.lisp KIT-DEF-MODS
pub fn kit_def_mods(kit: &Kit) -> crate::rules::DefMods {
    crate::rules::DefMods { mult: kit.taken }
}

// port: kit.lisp CORE-SEGMENTS (FIND-MOVE's ERROR on an unknown name: a panic naming it)
pub fn core_segments(data: &Data, name: &str) -> Vec<String> {
    core_segments_iter(data, name).map(String::from).collect()
}

/// CORE-SEGMENTS without the list (no allocation: the sim's step reads it through this).
pub fn core_segments_iter<'d>(data: &'d Data, name: &'d str) -> impl Iterator<Item = &'d str> {
    std::iter::successors(Some(name), move |x| find_move(data, x).unwrap_or_else(|| panic!("unknown move {x}")).params.ns_next.as_deref())
}

// port: kit.lisp CORE-ROUTES
pub fn core_routes(core: &duel_data::Core) -> Vec<String> {
    core.ns.iter().chain(&core.as_segs).cloned().collect()
}

// port: kit.lisp CORE-SEGMENT-SAS
pub fn core_segment_sas(data: &Data, core: &duel_data::Core) -> Vec<String> {
    core.ns.iter().flat_map(|n| core_segments(data, n)).filter_map(|m| find_move(data, &m).and_then(|x| x.params.sa.clone())).collect()
}

// ---------------------------------------------------------------- hooks (KIT-HOOK)

/// The hook points of a kit's `:hooks` plist (every key the data uses).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum HookKey {
    Armor, ArmoredFx, AsPick, Cancel, Clash, Command, Deck, DmgMult, Draw, Hash, Hit, HitFx, HudTag, KikonN, KikonWorth,
    LinkMove, LinkOk, Lv, MinReach, Ok, P, Parried, Planted, Pose, Reset, SoulBreakCine, SpGainMult, StepDist, Struck, Threat,
    Tick, Unscaled, VictimLook,
}

const HOOK_NAMES: [(&str, HookKey); 33] = {
    use HookKey::*;
    [
        ("armor", Armor), ("armored-fx", ArmoredFx), ("as-pick", AsPick), ("cancel", Cancel), ("clash", Clash),
        ("command", Command), ("deck", Deck), ("dmg-mult", DmgMult), ("draw", Draw), ("hash", Hash), ("hit", Hit),
        ("hit-fx", HitFx), ("hud-tag", HudTag), ("kikon-n", KikonN), ("kikon-worth", KikonWorth), ("link-move", LinkMove),
        ("link-ok", LinkOk), ("lv", Lv), ("min-reach", MinReach), ("ok", Ok), ("p", P), ("parried", Parried), ("planted", Planted),
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

/// A resolved hook function. Each hook point has its own signature: a hook that takes only the fighter runs through
/// `fighter::call_hook`, a typed one (:armor, :dmg-mult, :lv, :as-pick, :link-ok, :hit) at its own call site.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum HookFn {
    /// Not ported yet (Hisagi's / Yamamoto's: M4): its caller hits `unported!`.
    Unported,
    /// A look the data names as a hook (`:draw`, `:hit-fx`, `:pose`, `:deck`, `:hud-tag`): the sim never calls it.
    Look,
    /// A cinematic's name in a hook slot (`:soul-break-cine`: KIT-KIKON-CINE reads the symbol, never calls it).
    Cine,
    Ken(crate::ken::Hook),
    Ichigo(crate::ichigo::Hook),
}

/// A kit's hook table: one slot per hook key.
#[derive(Debug, Clone)]
pub struct Hooks(pub [Option<HookFn>; 33]);

impl Default for Hooks {
    fn default() -> Self {
        Hooks([None; 33])
    }
}

// port: the symbol a defkit's :hooks (or a move's hook slot) names → its function. Kenpachi's and Ichigo's resolve to their ports
// (their looks to `Look`, a cinematic to `Cine`); anything else of theirs is None, so `hooks_of` fails at load naming it; a Hisagi /
// Yamamoto symbol is an `Unported` stub (M4).
pub fn resolve(name: &str) -> Option<HookFn> {
    if let Some(h) = crate::ken::Hook::from_name(name) {
        return Some(HookFn::Ken(h));
    }
    if let Some(h) = crate::ichigo::Hook::from_name(name) {
        return Some(HookFn::Ichigo(h));
    }
    if crate::ken::LOOKS.contains(&name) || crate::ichigo::LOOKS.contains(&name) {
        return Some(HookFn::Look);
    }
    if crate::cine::CineName::from_lisp(name).is_some() {
        return Some(HookFn::Cine);
    }
    const LATER: [&str; 4] = ["HS-", "HISAGI-", "YAMA-", "YAMAMOTO-"];
    LATER.iter().any(|p| name.starts_with(p)).then_some(HookFn::Unported)
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

// port: kit.lisp KIT-HOOK — takes the kit's resolved `Hooks` table (`hooks_of`), not the kit: the symbols are resolved once at load.
pub fn kit_hook(hooks: &Hooks, key: HookKey) -> Option<HookFn> {
    hooks.0[key as usize]
}

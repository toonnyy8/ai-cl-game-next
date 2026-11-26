//! port: duel/lisp/combat.lisp — what happens when fighters touch: HIT-SYSTEM (the Breaker clash, then COLLECT every fighter's and
//! hazard's hits, then APPLY them all in collection order: a trade is a trade; then the souls they broke, handed to round.rs),
//! APPLY-HIT (the triangle, damage, reactions, chip, gauges, hitstop; the Kikon rush's strike; the parry), DEAL-DAMAGE, the step's three
//! hit queues (`Match.pending`, `.kikons`, `.soul_breaks`, fixed capacity), a delayed hit (DELAY-HIT), Nozarashi's cuts, the
//! perfect-Hoho test (PERFECT-NOW-P). EMITs are looks (`// look:`). Every hook goes through `call_hook` (the kit tasks port them).
use crate::components::{Contact, HazardKind, HitWin, HzData, KikonUndo, MoveId, Phase, State, Sym};
use crate::core::Verdict;
use crate::core_sim::{
    core_break, core_charge_mult, core_dead_p, core_follow_cues, core_held_p, core_kikon_p, core_nohit, core_on_hit,
    core_set_kikon_n, core_start, core_verdicts, core_wave_follow, core_wave_strike, core_window_class, core_hazard_nohit,
};
use crate::ecs::Entity;
use crate::fighter::{
    breaker_phase, call_hook, defender_state, ender_push, fighter, fighter_mut, gauges_red_p, id_of, kit_hook_sym, kit_of, mv,
    passive_p, pos_of, respect, set_blockstun, set_reaction, set_slide, side_name, yaw_of,
};
use crate::gauges::{bind_hook, bind_of, drain_guard, gain_gauges, siphon_of, sp_atk_hit, sub_of};
use crate::hazards::{body_of, collect_hazard_hits, hazard_connected, hazard_threat_p, spawn_hazard, HzArgs};
use crate::kit::{kit_atk_mods, kit_class, kit_def_mods, kit_next, mv_total, sp_move_p, stun_tolerance_of, window_touches_p};
use crate::rules::{
    blockstun, chip_damage, combo_step, contact_of, first_land_p, hit_damage, hit_px, hitstun, in_front_p, kikon_follow_stun,
    kikon_follow_unguardable_p, kikon_outcome, perfect_hoho_p, ranged_hit_p, ranged_ward_p, resolve_contact, soul_break_p,
    stance_store, stun_add, stun_over_p, sub_taken_mods, threat_window_p, AtkMods, ContactKeys, DefMods, DefState, KikonOutcome,
    Res,
};
use crate::state::Match;
use duel_data::{MoveClass, Move};

// ---------------------------------------------------------------- the step's hit queues

/// A fixed-capacity queue in push order (no allocation per step). Overflow panics: the Lisp's lists have no cap, so a full queue is a
/// port limit to raise, never to drop silently.
#[derive(Clone, Copy, Debug)]
pub struct Queue<T: Copy, const N: usize> {
    len: usize,
    items: [Option<T>; N],
}

impl<T: Copy, const N: usize> Default for Queue<T, N> {
    fn default() -> Self {
        Queue { len: 0, items: [None; N] }
    }
}

impl<T: Copy, const N: usize> Queue<T, N> {
    pub fn push(&mut self, x: T) {
        assert!(self.len < N, "hit queue full ({N})");
        self.items[self.len] = Some(x);
        self.len += 1;
    }
    pub fn clear(&mut self) {
        *self = Self::default();
    }
    pub fn len(&self) -> usize {
        self.len
    }
    pub fn is_empty(&self) -> bool {
        self.len == 0
    }
    pub fn get(&self, i: usize) -> Option<T> {
        self.items[..self.len].get(i).copied().flatten()
    }
    pub fn iter(&self) -> impl Iterator<Item = T> + '_ {
        self.items[..self.len].iter().map(|x| x.unwrap())
    }
}

/// Hits one step may collect (both fighters' open windows, a perfect Hoho's strike, every hazard's contact).
pub const PENDING_MAX: usize = 32;
/// KIKONS / SOUL-BREAKS hold one entry per victim.
pub const SOULS_MAX: usize = 2;

/// `*kikons*`' (attacker victim move).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct KikonQ {
    pub att: Entity,
    pub def: Entity,
    pub mv: MoveId,
}

/// The hit window a pending hit deals: a move's window (by index), the perfect Hoho's (`*PERFECT-HW*`) or a hazard's own (HAZARD-HW;
/// a hazard lives until SETTLE-SOULS clears them, after every hit is applied).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum HwRef {
    Move(MoveId, usize),
    Perfect,
    Hazard(Entity),
}

/// port: PENDING: one hit collected this step, with what it needs of the attacker as he was then. I: the move's window index; HAZARD:
/// the hazard dealing it (None = melee); STATE RED: the defender's triangle state and red-ness; MV BONUS CRUSH: the attacker's move,
/// stored damage, guard crush.
#[derive(Clone, Copy, Debug)]
pub struct Pending {
    pub att: Entity,
    pub def: Entity,
    pub hw: HwRef,
    pub i: i64,
    pub sx: f32,
    pub sz: f32,
    pub hazard: Option<Entity>,
    pub state: DefState,
    pub red: bool,
    pub mv: Option<MoveId>,
    pub bonus: i64,
    pub crush: bool,
}

impl Pending {
    /// MAKE-PENDING's defaults with STATE (the slot every caller gives).
    pub fn new(state: DefState) -> Pending {
        Pending {
            att: Entity::NIL,
            def: Entity::NIL,
            hw: HwRef::Perfect,
            i: 0,
            sx: 0.0,
            sz: 0.0,
            hazard: None,
            state,
            red: false,
            mv: None,
            bonus: 0,
            crush: false,
        }
    }
}

/// `(push … *pending*)` (kept in push order: HIT-APPLY's NREVERSE is the identity here).
pub fn push_pending(m: &mut Match, h: Pending) {
    m.pending.push(h);
}

/// The hit window flags APPLY-HIT reads (the look-only :ice :blade :thread are not kept).
mod flag {
    pub const BREAKER: u16 = 1;
    pub const GUARD_CRUSH: u16 = 2;
    pub const UNGUARDABLE: u16 = 4;
    pub const REND: u16 = 8;
    pub const FLAT: u16 = 16;
    pub const UNSCALED: u16 = 32;
    pub const KEEP_BIND: u16 = 64;
    pub const SPARE: u16 = 128;
    pub const RANGED: u16 = 256;
}

fn flag_bits<'a>(flags: impl Iterator<Item = &'a str>) -> u16 {
    flags.fold(0, |b, f| {
        b | match f.trim_start_matches(':').to_ascii_lowercase().as_str() {
            "breaker" => flag::BREAKER,
            "guard-crush" => flag::GUARD_CRUSH,
            "unguardable" => flag::UNGUARDABLE,
            "rend" => flag::REND,
            "flat" => flag::FLAT,
            "unscaled" => flag::UNSCALED,
            "keep-bind" => flag::KEEP_BIND,
            "spare" => flag::SPARE,
            "ranged" => flag::RANGED,
            _ => 0,
        }
    })
}

/// A hit window as APPLY-HIT reads it (the HITWIN slots it uses, GUARD as a single: `(- gg v)` of a fixnum V is the same).
#[derive(Clone, Copy, Debug)]
pub struct Hw {
    pub dmg: i64,
    pub react: Phase,
    pub kb: f32,
    pub hs: i64,
    pub chip: Option<f32>,
    pub stun: Option<i64>,
    pub guard: Option<f32>,
    pub steal: Option<i64>,
    flags: u16,
}

impl Hw {
    fn has(&self, f: u16) -> bool {
        self.flags & f != 0
    }
}

fn hw_of_runtime(w: &HitWin) -> Hw {
    Hw {
        dmg: w.dmg,
        react: w.react,
        kb: w.kb,
        hs: w.hs,
        chip: w.chip,
        stun: w.stun,
        guard: w.guard.map(|g| match g {
            crate::components::Num::I(i) => i as f32,
            crate::components::Num::F(f) => f,
        }),
        steal: w.steal,
        flags: flag_bits(w.flags.iter().map(|s: &Sym| s.0)),
    }
}

/// The window HW names, now.
pub fn hw_of(m: &Match, hw: HwRef) -> Hw {
    match hw {
        HwRef::Move(id, i) => {
            let w = &mv(m, id).hits[i];
            Hw {
                dmg: w.dmg as i64,
                react: Phase::from_name(&w.react).unwrap_or_else(|| panic!("a hit window's react {}", w.react)),
                kb: w.kb,
                hs: w.hs as i64,
                chip: w.chip,
                stun: w.stun.map(i64::from),
                guard: w.guard.map(|g| g as f32),
                steal: w.steal.map(i64::from),
                flags: flag_bits(w.flags.iter().map(String::as_str)),
            }
        }
        // port: fighter.lisp *PERFECT-HW* (MAKE-HITWIN's defaults otherwise: kb 0.0, no chip / guard / flags)
        HwRef::Perfect => Hw {
            dmg: m.knobs.perfect_counter_damage,
            react: Phase::Stagger,
            kb: 0.0,
            hs: m.knobs.hitstop_heavy,
            chip: None,
            stun: Some(m.knobs.perfect_counter_stun),
            guard: None,
            steal: None,
            flags: 0,
        },
        HwRef::Hazard(h) => hw_of_runtime(m.hazard.get(h).expect("a pending hazard").hw.as_ref().expect("a hit hazard's window")),
    }
}

// ---------------------------------------------------------------- damage

/// port: DELAY-HIT: a hit whose damage and reaction come LATER frames after it (a move's :params :dmg-at): DEF held where he stands (a
/// stagger, no push) until then, a look-only :fx hazard of ATT carrying the rest (DELAY-HIT-HOOK).
#[allow(clippy::too_many_arguments)]
pub fn delay_hit(m: &mut Match, att: Entity, def: Entity, dmg: i64, n: i64, react: Phase, stun: i64, sx: f32, sz: f32, kb: f32, later: i64, mv: MoveId, red: bool) {
    let later = later.max(1);
    let hold = m.knobs.delay_hit_hold;
    set_reaction(m, def, Some(Phase::Stagger), later + hold, sx, sz, 0.0);
    spawn_hazard(
        m,
        HazardKind::Fx,
        att,
        HzArgs {
            x: sx,
            z: sz,
            life: later + 1,
            delay: later,
            hook: Some(Sym("DELAY-HIT-HOOK")),
            data: HzData::DelayHit { def, dmg, n, react, stun, sx, sz, kb, mv, red },
            ..HzArgs::default()
        },
    );
}

/// port: DELAY-HIT-HOOK (event :step): on the step its delay runs out, DEF takes the damage and the hit's own reaction; or, the
/// attacker still in MV with its SP held since the segment began (a core SP's Kikon hold), the Kikon's knockback and dash-in start now.
/// Always NIL (the generic step goes on).
pub fn delay_hit_hook(m: &mut Match, h: Entity) -> bool {
    let hz = m.hazard.get(h).unwrap();
    if hz.delay != 1 {
        return false;
    }
    let HzData::DelayHit { def, dmg, n, react, stun, sx, sz, kb, mv: id, red } = hz.data else { panic!("DELAY-HIT-HOOK's data") };
    let att = hz.owner;
    let fa = fighter(m, att);
    let kikon = fa.state == State::Move && fa.mv == Some(id) && core_kikon_p(m, att, Some(mv(m, id))) && fa.sp_held && core_held_p(m, att);
    if m.ents.alive(def) {
        crate::clog!(m, "{} delayed hit on {} {}{}", side_name(m, att), side_name(m, def), dmg, if kikon { " (Kikon hold)" } else { "" });
        if !deal_damage(m, att, def, dmg, n) {
            if kikon {
                let s = kikon_follow_stun(&m.knobs, red, mv(m, id).s as i64);
                let kb = m.knobs.kikon_follow_kb;
                set_reaction(m, def, Some(Phase::Stagger), s, sx, sz, kb);
                core_set_kikon_n(m, att, red);
                if m.unported.is_some() {
                    return false;
                }
                let fa = fighter_mut(m, att);
                (fa.kikon_undo, fa.phase, fa.hold, fa.follow) = (None, Some(Phase::Follow), 0, true);
                fighter_mut(m, def).kikon_lock = if red { 2 } else { 1 };
                crate::clog!(m, "{} KIKON FOLLOW-UP on {}{}", side_name(m, att), side_name(m, def), if red { " (red)" } else { "" });
            } else {
                set_reaction(m, def, Some(react), stun, sx, sz, kb);
            }
        }
    }
    false
}

/// port: DEAL-DAMAGE: DEF loses DMG Reishi (ATT dealt it); N the hit's combo index (both sides' gains, GAIN-GAUGES). Reishi at 0 is a Soul
/// Break, queued for the end of the step: true then. In a bind the loss is grey (Hisagi's, M4: no binder before it).
pub fn deal_damage(m: &mut Match, att: Entity, def: Entity, dmg: i64, n: i64) -> bool {
    let bd = bind_of(m, def);
    let h = bind_hook(m, bd, "bind-damage");
    let gd = m.gauges.get_mut(def).expect("gauges");
    gd.reishi = 0.max(gd.reishi - dmg);
    m.gauges.get_mut(att).expect("gauges").dealt += dmg;
    if bd.is_some() {
        m.gauges.get_mut(att).unwrap().grey += dmg;
    }
    if let Some(h) = h {
        crate::unported!(m, h, false) // (a binder's :bind-damage: Hisagi's, M4)
    }
    fighter_mut(m, def).combo_dmg += dmg;
    gain_gauges(m, att, dmg, 0, n);
    gain_gauges(m, def, 0, dmg, n);
    if bd.is_none() && soul_break_p(m.gauges.get(def).unwrap().reishi) {
        queue_soul_break(m, att, def);
        return true;
    }
    false
}

/// port: QUEUE-SOUL-BREAK!: DEF's soul breaks (by ATT), settled with the step's others; once per victim.
pub fn queue_soul_break(m: &mut Match, att: Entity, def: Entity) {
    if !m.soul_breaks.iter().any(|(_, d)| d == def) {
        m.soul_breaks.push((att, def));
    }
}

/// port: QUEUE-KIKON!: ATT's Kikon on DEF (move MV: its :cine and :callout), settled with the step's Soul Breaks; once per victim.
pub fn queue_kikon(m: &mut Match, att: Entity, def: Entity, mv: MoveId) {
    if !m.kikons.iter().any(|k| k.def == def) {
        m.kikons.push(KikonQ { att, def, mv });
    }
}

/// port: TAKE-BROKEN-SOULS: the step's two soul queues for SETTLE-SOULS (BROKEN-SOULS), both emptied.
pub fn take_broken_souls(m: &mut Match) -> (Queue<KikonQ, SOULS_MAX>, Queue<(Entity, Entity), SOULS_MAX>) {
    let out = crate::rules::broken_souls(&m.kikons, &m.soul_breaks, |k| k.def);
    m.kikons.clear();
    m.soul_breaks.clear();
    out
}

// ---------------------------------------------------------------- one hit

/// APPLY-HIT's keys: MV BONUS CRUSH, ATT's move and its state when the hit was collected; HAZARD; DEF-STATE and RED, DEF's triangle state
/// and red-ness then. (X Z, where to show it, are looks.)
#[derive(Clone, Copy, Debug)]
pub struct HitKeys {
    pub mv: Option<MoveId>,
    pub hazard: Option<Entity>,
    pub def_state: DefState,
    pub bonus: i64,
    pub crush: bool,
    pub red: bool,
}

fn res_name(r: Res) -> &'static str {
    match r {
        Res::StanceBreak => "STANCE-BREAK",
        Res::Parried => "PARRIED",
        Res::GuardBreak => "GUARD-BREAK",
        Res::Blocked => "BLOCKED",
        Res::Counter => "COUNTER",
        Res::Absorbed => "ABSORBED",
        Res::Hit => "HIT",
        Res::Armored => "ARMORED",
        Res::Kikon => "KIKON",
    }
}

fn has_flag(mvd: &Move, f: &str) -> bool {
    mvd.flags.iter().any(|x| x == f)
}

/// port: APPLY-HIT: hit HW of ATT on DEF from (SX SZ) (the attacker or the hazard: guard facing and push direction). Returns
/// RESOLVE-CONTACT's result (None = no effect). Stops (None, `m.unported` set) at the first unported hook, at the Lisp's point.
pub fn apply_hit(m: &mut Match, att: Entity, def: Entity, hwr: HwRef, sx: f32, sz: f32, k: HitKeys) -> Option<Res> {
    macro_rules! bail {
        () => {
            if m.unported.is_some() {
                return None;
            }
        };
    }
    let hw = hw_of(m, hwr);
    let HitKeys { mv: mvid, hazard, def_state, bonus, crush, red } = k;
    let mvd = mvid.map(|id| mv(m, id));
    let p = pos_of(m, def);
    let (dx, dz) = (p[0] - sx, p[2] - sz);
    let d2 = dx * dx + dz * dz; // DEF's distance (squared) from the attacker
    let ranged = ranged_hit_p(hazard.is_some(), hw.has(flag::RANGED), mvd.and_then(|x| x.params.melee_range), d2);
    let fd = fighter(m, def);
    let rward = ranged
        && fd.state == State::Move
        && fd.mv.is_some_and(|id| has_flag(mv(m, id), "ranged-ward"))
        && {
            let g = m.gauges.get(def).unwrap();
            ranged_ward_p(true, ranged, def_state, crate::rules::can_guard_p(g.gg, g.guardless))
        };
    let def_state = if rward { DefState::Guard } else { def_state };
    let ward = (def_state == DefState::Parry && passive_p(m, def, "parry-block")) || rward;
    let own = mvid.is_some() && fighter(m, att).mv == mvid;
    let wave = hazard.and_then(|_| core_wave_strike(m, att, hazard)); // a core SP's wave: its follow-up strike
    let rush = mvd.is_some_and(|x| x.kind == "kikon" || (own && hazard.is_none() && core_kikon_p(m, att, Some(x)))) || wave.is_some();
    let fstrike = rush && own && fighter(m, att).follow; // the dash-in's strike: the Kikon if it hits
    // (:crush-range, NOMIHOSE's: no live move has it; duel_data's Params denies unknown keys)
    let in_front = in_front_p(yaw_of(m, def), p[0], p[2], sx, sz, m.knobs.guard_arc);
    let mut res = resolve_contact(
        def_state,
        ContactKeys {
            breaker: hw.has(flag::BREAKER),
            guard_crush: hw.has(flag::GUARD_CRUSH) || crush,
            in_front,
            unguardable: hw.has(flag::UNGUARDABLE) || (fstrike && kikon_follow_unguardable_p(red)),
            hazard: ranged,
            ward,
            rend: hw.has(flag::REND),
        },
    );
    let flat = hw.has(flag::FLAT);
    let atk = if flat {
        AtkMods::default()
    } else {
        let fa = fighter(m, att);
        let charge = core_charge_mult(fa, mvd, own, hazard.is_some());
        let sub = sub_of(m, att);
        if let Some(h) = kit_hook_sym(m, att, "dmg-mult") {
            call_hook(m, att, h); // (a kit's distance x: KEN-DMG-MULT, Hisagi's tip: the kit tasks)
            return None;
        }
        let sps = match hazard {
            Some(h) => m.hazard.get(h).unwrap().sp_scale,
            None if own => crate::sp::sp_scale(fa.sp_paid, fa.sp_cost),
            None => 1.0,
        };
        let lost = m.knobs.konpaku_max - m.gauges.get(att).unwrap().konpaku;
        kit_atk_mods(&m.knobs, kit_of(m, att), lost, hit_px(&m.knobs, charge, sub, 1.0, sps), None) // (:form-mult: no live move)
    };
    let dmods = if flat { DefMods::default() } else { sub_taken_mods(&m.knobs, kit_def_mods(kit_of(m, def)), sub_of(m, def)) };
    let base = hw.dmg + bonus;
    let outcome = if rush {
        let held = if mvd.is_some_and(|x| x.kind == "kikon") {
            m.pilot.get(att).expect("a pilot").vpad.down(crate::components::Button::Kikon as usize)
        } else {
            fighter(m, att).sp_held && core_held_p(m, att)
        };
        kikon_outcome(held, res, fstrike)
    } else {
        None
    };
    let follow = outcome == Some(KikonOutcome::Follow)
        && !(own && hazard.is_none() && mvd.is_some_and(|x| x.params.dmg_at.is_some()) && !fstrike);
    if outcome == Some(KikonOutcome::Kikon) {
        res = Some(Res::Kikon);
        queue_kikon(m, att, def, mvid.expect("a Kikon strike's move")); // (KIKON-OUTCOME :kikon needs FSTRIKE, so OWN)
    }
    let r = res?;
    let first = {
        let fa = fighter(m, att);
        own && contact_of(res) == Some(Contact::Hit) && first_land_p(fa.contact, fa.hits) // its first real hit
    };
    if own {
        let fa = fighter_mut(m, att);
        fa.contact = if contact_of(res) == Some(Contact::Hit) { Some(Contact::Hit) } else { fa.contact.or(Some(Contact::Block)) };
        if fa.land_sf < 0 {
            fa.land_sf = fa.sf;
        }
    }
    {
        let what = match (mvd, hazard) {
            (Some(x), _) => x.name.to_uppercase(),
            (None, Some(h)) => m.hazard.get(h).unwrap().kind.map_or("NIL", |k| k.name()).to_string(),
            (None, None) => "COUNTER".to_string(),
        };
        crate::clog!(m, "{} {} -> {} {} {}", side_name(m, att), what, side_name(m, def), res_name(r), base);
    }
    if hazard.is_some() && contact_of(res) == Some(Contact::Hit) {
        fighter_mut(m, att).hz_hit = true; // (his move's :r-cancel-from)
    }
    if r == Res::Counter {
        respect(m, def);
    }
    let counter = r == Res::Counter;
    match r {
        Res::Kikon => {} // settled at the end of the step (SETTLE-SOULS)
        Res::Hit | Res::Counter => {
            let fd = fighter(m, def);
            let hreact = if follow { Phase::Stagger } else { hw.react };
            let (react, hits, launches, air) =
                combo_step(&m.knobs, hreact, fd.state == State::Air, fd.combo_hits, fd.combo_launches, fd.combo_air, hw.has(flag::KEEP_BIND));
            let fd = fighter_mut(m, def);
            (fd.combo_hits, fd.combo_launches, fd.combo_air) = (hits, launches, air);
            let combo_from = fd.combo_from;
            // the hidden stun; past his tolerance this hit blows him away (off since 2026-10-10: *STUN-BLOW-AWAY* nil)
            let heavy = mvd.is_some_and(|x| matches!(x.kind.as_str(), "sp" | "kikon"));
            let st = stun_add(&m.knobs, m.gauges.get(def).unwrap().stun, hreact.name(), heavy);
            let blow = m.knobs.stun_blow_away
                && !rush
                && m.gauges.get(att).unwrap().burst != Some(crate::components::Burst::Orange)
                && stun_over_p(st, stun_tolerance_of(&m.knobs, kit_of(m, def)));
            let react = if blow { Phase::Knockdown } else { react };
            let unscaled = flat
                || hw.has(flag::UNSCALED)
                || match hazard {
                    Some(h) => m.hazard.get(h).unwrap().sp,
                    None => mvd.is_some_and(|x| sp_move_p(m.data, kit_of(m, att), x)),
                }
                || match kit_hook_sym(m, att, "unscaled") {
                    Some(h) => {
                        call_hook(m, att, h); // (Hisagi's tip, M4)
                        return None;
                    }
                    None => false,
                };
            let idx = (hits - combo_from).max(1);
            let orange = m.gauges.get(att).unwrap().burst == Some(crate::components::Burst::Orange);
            let d = hit_damage(&m.knobs, base, atk, dmods, if unscaled { 1 } else { idx }, !flat && counter, orange);
            let dmg = if hw.has(flag::SPARE) { d.min(0.max(m.gauges.get(def).unwrap().reishi - 1)) } else { d };
            let stun = if follow {
                kikon_follow_stun(&m.knobs, red, mv(m, wave.or(mvid).expect("a follow's move")).s as i64)
            } else if let Some(s) = hw.stun.filter(|_| react == hw.react) {
                s
            } else {
                hitstun(&m.knobs, react.name(), counter)
            };
            {
                let gd = m.gauges.get_mut(def).unwrap();
                (gd.stun, gd.stun_idle) = (if blow { 0.0 } else { st }, 0);
            }
            crate::clog!(m, "{} dealt {}: {} stun {}", side_name(m, att), dmg, react.name().to_lowercase(), stun);
            {
                let gd = m.gauges.get_mut(def).unwrap();
                if ranged {
                    gd.taken_ranged += dmg;
                } else {
                    gd.taken_melee += dmg;
                }
                let ga = m.gauges.get_mut(att).unwrap();
                ga.best_combo = ga.best_combo.max(hits);
            }
            if own && hazard.is_none() && dmg > 0 {
                sp_atk_hit(m, att); // a J / SA hit window that dealt damage (DUEL_SP §5)
                bail!();
            }
            m.time.hitstop(hw.hs as f32);
            // look: emit :hit
            let n = (hits - fighter(m, def).combo_from).max(1);
            let dmg_at = mvd.and_then(|x| x.params.dmg_at).filter(|_| own && hazard.is_none() && !follow);
            if let Some(at) = dmg_at {
                // a :dmg-at move (千切): the hit holds him, the damage and its reaction later
                let later = at as i64 - fighter(m, att).sf;
                delay_hit(m, att, def, dmg, n, react, stun, sx, sz, hw.kb, later, mvid.unwrap(), red);
            } else if !deal_damage(m, att, def, dmg, n) {
                bail!();
                if blow {
                    let kb = m.knobs.stun_blow_kb;
                    set_reaction(m, def, Some(react), stun, sx, sz, kb);
                    // gate: (incf *blow-aways*) — the gate rows' count, not ported (gate.rs)
                    crate::clog!(m, "{} BLOWN AWAY by {} (stun tolerance {}, combo hit {})", side_name(m, def), side_name(m, att),
                        crate::cl::fmt_fixed_f32(stun_tolerance_of(&m.knobs, kit_of(m, def)), 1), hits);
                } else {
                    let confirm = m.knobs.core_kikon_confirm;
                    if follow && (own || wave.is_some()) && (wave.is_some() || core_kikon_p(m, att, mvd)) && confirm > 0 {
                        if matches!(hw.react, Phase::Knockdown | Phase::Launch) {
                            let hold = m.knobs.kikon_air_hold;
                            set_reaction(m, def, Some(Phase::Stagger), confirm + hold, sx, sz, 0.0);
                        } else {
                            let s = hw.stun.unwrap_or_else(|| hitstun(&m.knobs, hw.react.name(), counter));
                            set_reaction(m, def, Some(hw.react), s, sx, sz, hw.kb);
                        }
                    } else {
                        let kb = if follow { m.knobs.kikon_follow_kb } else { hw.kb };
                        set_reaction(m, def, Some(react), stun, sx, sz, kb);
                    }
                    if let Some(x) = mvd.filter(|x| own && hazard.is_none() && has_flag(x, "ender") && matches!(x.kind.as_str(), "quick" | "flash")) {
                        ender_push(m, att, def, id_of(m, x)); // J3 / K3: out of J1 / K1's reach at once
                        bail!();
                    }
                    if let Some(x) = mvd.filter(|_| own && hazard.is_none() && !fighter(m, att).chained)
                        && string_opener_p(m, att, x)
                    {
                        // a string's opener hit: the attacker dashes in to point-blank
                        let pull = libm::sqrtf(d2) - m.knobs.string_pull_to;
                        if pull > 0.01 {
                            let fr = m.knobs.string_pull_frames;
                            set_slide(m, att, pull, fr, dx, dz);
                        }
                    }
                    bail!();
                }
            }
            bail!();
            if let Some(id) = mvid.filter(|&id| hazard.is_none() && kit_class(kit_of(m, att), Some(mv(m, id))) == Some(MoveClass::As)) {
                core_on_hit(m, att, def, id, 1.0, hw.steal);
            }
            if follow && let Some(w) = wave {
                core_wave_follow(m, att, w); // a wave's: he flash-steps in to its strike
                bail!();
            }
            if follow && (own || wave.is_some()) {
                // the rush dashes in, then strikes again (KIKON-RUSH-STEP)
                let undo = (wave.is_some() || core_kikon_p(m, att, mvd)).then(|| KikonUndo {
                    def,
                    react: hw.react,
                    stun: hw.stun.unwrap_or_else(|| hitstun(&m.knobs, hw.react.name(), counter)),
                    sx,
                    sz,
                    kb: hw.kb,
                    wave: wave.is_some(),
                    kreact: Some(react),
                    kstun: stun,
                });
                let has_undo = undo.is_some();
                fighter_mut(m, att).kikon_undo = undo;
                if has_undo {
                    core_set_kikon_n(m, att, red);
                    bail!();
                }
                let fa = fighter_mut(m, att);
                (fa.phase, fa.hold, fa.follow) = (Some(Phase::Follow), 0, true);
                fighter_mut(m, def).kikon_lock = if red { 2 } else { 1 };
                if !has_undo {
                    core_follow_cues(m, att, def);
                }
                crate::clog!(m, "{} KIKON FOLLOW-UP on {}{}", side_name(m, att), side_name(m, def), if red { " (red)" } else { "" });
            }
        }
        Res::Armored => {
            // a move's armour (one hit spent; a kit's :armor hook pays its own price: its :struck)
            let fd = fighter_mut(m, def);
            if def_state == DefState::Armor && fd.armor_left > 0 {
                fd.armor_left -= 1;
            }
            m.time.hitstop(m.knobs.hitstop_block as f32);
            // look: emit :armored
            let d = hit_damage(&m.knobs, base, atk, dmods, 1, false, false);
            deal_damage(m, att, def, d, 1);
        }
        Res::Parried => {
            // the attacker staggers, the parry counters (its :land string)
            m.time.hitstop(m.knobs.hitstop_breaker as f32);
            respect(m, att);
            let (st, sl) = (m.knobs.parry_stun, m.knobs.parry_slide);
            set_reaction(m, att, Some(Phase::Stagger), st, p[0], p[2], sl);
            fighter_mut(m, att).armor_left = 0;
            if let Some(h) = kit_hook_sym(m, def, "parried")
                && siphon_of(m, def).is_none()
            {
                call_hook(m, def, h); // (its own catch: KESSA's, Task 12)
                return None;
            }
            // look: emit :parried
            let c = fighter(m, def).mv.and_then(|id| kit_next(m.data, kit_of(m, def), &mv(m, id).name, "land"));
            if let Some(c) = c {
                let c = id_of(m, c);
                core_start(m, def, c, None);
            }
        }
        Res::Absorbed => {
            let d = hit_damage(&m.knobs, base, atk, dmods, 1, false, false);
            let stored = stance_store(&m.knobs, fighter(m, def).stored, d);
            fighter_mut(m, def).stored = stored;
            m.time.hitstop(m.knobs.hitstop_block as f32);
            // look: emit :absorbed
            deal_damage(m, att, def, d, 1);
        }
        Res::Blocked => {
            // blockstun, chip, the guard gauge (at 0: GUARD CRUSH); a ward: no blockstun
            let adv = mvd.map_or(0, |x| match x.adv_block {
                Some(duel_data::AdvBlock::Frames(a)) => a as i64,
                _ => 0,
            }) - if mvd.is_some_and(|x| x.kind == "quick") { m.knobs.quick_block_adv } else { 0 };
            let stun = match mvd {
                Some(x) => blockstun(mv_total(x), fighter(m, att).sf, adv),
                None => m.knobs.hazard_blockstun,
            };
            let v = hw.guard.unwrap_or(m.knobs.gg_hazard as f32);
            let chip = chip_damage(base, hw.chip, m.gauges.get(def).unwrap().reishi);
            if drain_guard(m, def, v, "BLOCK") {
                let (st, kb) = (m.knobs.guard_crush_stun, m.knobs.block_pushback);
                set_reaction(m, def, Some(Phase::GuardBreak), st, sx, sz, kb);
                m.time.hitstop(m.knobs.hitstop_breaker as f32);
                // look: emit :guard-crush
                crate::clog!(m, "{} GUARD CRUSH", side_name(m, def));
            } else if ward {
                // super armour: no blockstun, what he does goes on
                let kb = m.knobs.block_pushback;
                set_slide(m, def, kb, 6, dx, dz);
                if rward {
                    let until = m.match_tick + m.knobs.hitstop_block + stun;
                    fighter_mut(m, def).ward_until = until; // the windmill: a guard's wait (+ its hitstop)
                }
                m.time.hitstop(m.knobs.hitstop_block as f32);
            } else {
                set_blockstun(m, def, stun, sx, sz);
                m.time.hitstop(m.knobs.hitstop_block as f32);
            } // look: emit :blocked
            if chip > 0 {
                deal_damage(m, att, def, chip, 1);
            }
        }
        Res::GuardBreak => {
            let gb = m.knobs.gg_breaker as f32;
            drain_guard(m, def, gb, "BREAKER");
            let (st, kb) = (m.knobs.guard_break_stun, m.knobs.guard_break_kb);
            set_reaction(m, def, Some(Phase::GuardBreak), st, sx, sz, kb);
            m.time.hitstop(m.knobs.hitstop_breaker as f32);
            // look: emit :guard-break
        }
        Res::StanceBreak => {
            let (st, kb) = (m.knobs.stance_break_stun, m.knobs.stance_break_kb);
            set_reaction(m, def, Some(Phase::Crumple), st, sx, sz, kb);
            m.time.hitstop(m.knobs.hitstop_breaker as f32);
            // look: emit :stance-break
        }
    }
    bail!();
    for (e, key) in [(att, "hit"), (def, "struck")] {
        if let Some(h) = kit_hook_sym(m, e, key) {
            call_hook(m, e, h); // a character's own hit rules (ICHIGO-HIT / -STRUCK, KEN-HIT: the kit tasks)
            return None;
        }
    }
    if matches!(r, Res::Hit | Res::Counter) {
        core_break(m, att, def); // a real hit in an exchange after a cancel: the breakthrough (DUEL_SP §6)
    }
    if first
        && m.cine.is_none()
        && let Some(h) = mvd.and_then(|x| x.on_land.as_deref())
    {
        call_hook(m, att, h);
        return None;
    }
    res
}

/// port: kit.lisp STRING-OPENER-P with E: MVD a J / K string's opener in E's kit (the :q / :f command's move, E's :command hook
/// consulted) that takes the generic close-in, not :no-close.
fn string_opener_p(m: &mut Match, e: Entity, mvd: &Move) -> bool {
    if !(matches!(mvd.kind.as_str(), "quick" | "flash") && !has_flag(mvd, "no-close")) {
        return false;
    }
    if let Some(h) = kit_hook_sym(m, e, "command") {
        call_hook(m, e, h); // (KIT-COMMAND-MOVE with E: Hisagi's :command hook, M4)
        return false;
    }
    crate::kit::string_opener_p(m.data, kit_of(m, e), mvd)
}

// ---------------------------------------------------------------- the system

/// port: COLLECT-MELEE: E's move windows open this frame that touch the opponent (each window hits once), and a perfect Hoho's counter
/// strike on its frame (it always connects).
pub fn collect_melee(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    let (o, p) = (f.opp, pos_of(m, e));
    if !m.ents.alive(o) {
        return;
    }
    if f.state == State::Hoho && f.perfect && f.sf == m.knobs.hoho_counter_strike {
        let state = defender_state(m, o);
        if m.unported.is_some() {
            return;
        }
        push_pending(m, Pending { att: e, def: o, hw: HwRef::Perfect, sx: p[0], sz: p[2], ..Pending::new(state) });
    }
    let f = fighter(m, e);
    let Some(id) = f.mv.filter(|_| f.state == State::Move && f.phase == Some(Phase::Main) && !core_dead_p(f)) else { return };
    let (sf, q, yaw) = (f.sf, pos_of(m, o), yaw_of(m, e));
    let (fx, fz) = (crate::math::fwd_x(yaw), crate::math::fwd_z(yaw));
    let (tr, th) = body_of(m, o);
    let mvd = mv(m, id);
    for (i, w) in mvd.hits.iter().enumerate() {
        let f = fighter(m, e);
        if !((w.from as i64) <= sf && sf < w.to as i64 && (f.hits >> i) & 1 == 0) {
            continue;
        }
        if w.min.is_some()
            && let Some(h) = kit_hook_sym(m, e, "min-reach")
        {
            call_hook(m, e, h); // (Hisagi's cancel unlock, M4)
            return;
        }
        let far = w.min.is_none_or(|mn| f.follow || crate::math::hypot(q[0] - p[0], q[2] - p[2]) >= mn);
        let touches = far && window_touches_p(m, w, e, p[0], p[1], p[2], fx, fz, q[0], q[1], q[2], tr, th);
        if m.unported.is_some() {
            return;
        }
        if touches {
            let state = defender_state(m, o);
            if m.unported.is_some() {
                return;
            }
            let f = fighter(m, e);
            let red = gauges_red_p(&m.knobs, m.gauges.get(o).unwrap());
            let (bonus, crush) = (f.dmg_bonus, f.crush);
            push_pending(
                m,
                Pending { att: e, def: o, hw: HwRef::Move(id, i), i: i as i64, sx: p[0], sz: p[2], mv: Some(id), red, bonus, crush, ..Pending::new(state) },
            );
        }
    }
}

/// port: CUT-HAZARDS: Nozarashi (:projectile-cut): an open window of E's move judges each opponent hazard it touches by the triangle, as
/// the hazard's own hit on him would be: his class beats it or either side has no class: cut; a cancel: CORE-HAZARD-NOHIT! and gone;
/// the wave's class wins: it flies on.
pub fn cut_hazards(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    if !(passive_p(m, e, "projectile-cut") && f.state == State::Move && f.phase == Some(Phase::Main) && !core_dead_p(f)) {
        return;
    }
    let id = f.mv.expect("a move in :move");
    let (sf, p, yaw) = (f.sf, pos_of(m, e), yaw_of(m, e));
    let (fx, fz) = (crate::math::fwd_x(yaw), crate::math::fwd_z(yaw));
    for w in mv(m, id).hits.iter() {
        if !((w.from as i64) <= sf && sf < w.to as i64) {
            continue;
        }
        m.do_entities(|m, h| m.hazard.has(h) && m.unported.is_none(), |m, h| {
            let hz = m.hazard.get(h).unwrap();
            let touched = hz.owner != e
                && hz.kind == Some(HazardKind::Wave) // (:fireball / :bind left with the retired kits)
                && hz.delay <= 0
                && w.vols.iter().any(|v| {
                    crate::hitvol::vol_hit_p(v, p[0], p[1], p[2], fx, fz, hz.x, 0.0, hz.z, crate::cl::max_f32(0.5, hz.size), 1.8, 0.0)
                });
            if !touched {
                return;
            }
            let (wc, owner, kind, src) = (hz.cls, hz.owner, hz.kind, hz.sp_src);
            let f = fighter(m, e);
            let bc = core_window_class(m, f);
            let v = match (wc, bc) {
                (Some(a), Some(b)) => crate::core::core_verdict(Some(a.into()), Some(b.into()), false, Some(src), Some(f.cls_t)),
                _ => Verdict::Absorb,
            };
            let vs = match v {
                Verdict::Hit => "passes",
                Verdict::Cancel => "cancel",
                Verdict::Absorb => "absorb",
            };
            crate::clog!(m, "{} blade x {}'s {} {}: {}", side_name(m, e), side_name(m, owner),
                kind.map_or("nil", |k| k.name()).to_lowercase(), wc.map_or("nil", |c| c.name()).to_lowercase(), vs);
            if v != Verdict::Hit {
                core_hazard_nohit(m, h, e, v);
                m.destroy(h);
            }
        });
    }
}

/// port: CLASH!: Breaker vs Breaker: both pushed *CLASH-PUSH* apart and stunned *CLASH-STUN*, no damage.
pub fn clash(m: &mut Match, a: Entity, b: Entity) {
    let (p, q) = (pos_of(m, a), pos_of(m, b));
    let (st, push) = (m.knobs.clash_stun, 0.5 * m.knobs.clash_push);
    set_reaction(m, a, Some(Phase::Clash), st, q[0], q[2], push);
    set_reaction(m, b, Some(Phase::Clash), st, p[0], p[2], push);
    m.time.hitstop(m.knobs.hitstop_breaker as f32);
    // look: emit :clash
    crate::clog!(m, "CLASH");
}

/// port: HIT-SYSTEM: the clash first; then every melee and hazard hit of this step, collected then applied (HIT-APPLY); the bind's
/// drained check (BIND-STEP! :hits); then the souls they broke, settled (TAKE-BROKEN-SOULS, round.rs SETTLE-SOULS).
pub fn hit_system(m: &mut Match) {
    let (mut a, mut b) = (None, None);
    m.do_entities(|m, e| m.fighter.has(e), |_, e| {
        if a.is_some() {
            b = Some(e);
        } else {
            a = Some(e);
        }
    });
    if let (Some(a), Some(b)) = (a, b) {
        let (pa, pb) = (breaker_phase(m, a), breaker_phase(m, b));
        if pa.is_some() && pb.is_some() && crate::rules::breaker_clash_p(&m.knobs, pa, pb, fighter(m, a).dist) {
            clash(m, a, b);
        }
    }
    hit_apply(m);
    if m.unported.is_some() {
        return;
    }
    if let Some(a) = a {
        crate::gauges::bind_step(m, a, "hits");
    }
    let (kk, sb) = take_broken_souls(m);
    crate::round::settle_souls(m, &kk, &sb);
}

/// port: HIT-APPLY: Nozarashi's cuts, then the melee and hazard hits collected, then applied together, in collection order.
pub fn hit_apply(m: &mut Match) {
    m.do_entities(|m, e| m.fighter.has(e) && m.unported.is_none(), cut_hazards);
    m.do_entities(|m, e| m.fighter.has(e) && m.unported.is_none(), collect_melee);
    collect_hazard_hits(m);
    if m.unported.is_some() {
        return;
    }
    let hits = m.pending;
    let verdicts = core_verdicts(m, &hits);
    m.pending.clear();
    for (h, verdict) in hits.iter().zip(verdicts.iter()) {
        let hit = if verdict == Verdict::Hit {
            let k = HitKeys { mv: h.mv, hazard: h.hazard, def_state: h.state, bonus: h.bonus, crush: h.crush, red: h.red };
            apply_hit(m, h.att, h.def, h.hw, h.sx, h.sz, k).is_some()
        } else {
            core_nohit(m, &h, verdict);
            true
        };
        if m.unported.is_some() {
            return;
        }
        if hit {
            if let Some(hz) = h.hazard {
                hazard_connected(m, hz);
            } else if h.mv.is_some() && h.mv == fighter(m, h.att).mv {
                // (an on-land hook may have started the next move)
                fighter_mut(m, h.att).hits |= 1 << h.i;
            }
        }
    }
}

// ---------------------------------------------------------------- perfect Hoho

/// port: PERFECT-NOW-P: would a Hoho started now by E be PERFECT? An opponent hit volume (move or hazard) active now or within
/// *PERFECT-LEAD* frames overlaps E's hurt cylinder grown by *PERFECT-INFLATE*, or his Breaker / Kikon rush dash is within 0.5 m of its
/// trigger range.
pub fn perfect_now_p(m: &mut Match, e: Entity) -> bool {
    let o = fighter(m, e).opp;
    let fo = fighter(m, o);
    let (p, q) = (pos_of(m, e), pos_of(m, o));
    let (tr, th) = body_of(m, e);
    let yaw = yaw_of(m, o);
    if let Some(id) = fo.mv.filter(|_| fo.state == State::Move && fo.phase == Some(Phase::Main)) {
        let (sf, inf) = (fo.sf, m.knobs.perfect_inflate);
        for w in mv(m, id).hits.iter() {
            let hit = if w.seg.is_some() {
                threat_window_p(&m.knobs, sf, w.from as i64, w.to as i64)
                    && window_touches_p(m, w, o, 0.0, 0.0, 0.0, 0.0, 0.0, p[0], p[1], p[2], tr + inf, th + inf)
            } else {
                let (fx, fz) = (crate::math::fwd_x(yaw), crate::math::fwd_z(yaw));
                perfect_hoho_p(&m.knobs, sf, w.from as i64, w.to as i64, &w.vols, q[0], q[1], q[2], fx, fz, p[0], p[1], p[2], tr, th)
            };
            if m.unported.is_some() {
                return false;
            }
            if hit {
                return true;
            }
        }
    }
    let fo = fighter(m, o);
    if let Some(id) = fo.mv.filter(|_| fo.state == State::Move && fo.phase == Some(Phase::Dash)) {
        let trig = if mv(m, id).kind == "kikon" { m.knobs.kikon_trigger } else { m.knobs.breaker_trigger };
        if fo.dist <= trig + 0.5 {
            return true;
        }
    }
    hazard_threat_p(m, o, e)
}

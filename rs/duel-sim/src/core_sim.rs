//! port: duel/lisp/core-sim.lisp — the core system's side of the sim (DUEL_CORE): what the two buttons start, the triangle's verdicts
//! applied, the SP pointer, the Kikon hold and its cancel. Pure rules are core.rs'. Every function of core-sim.lisp, same names
//! snake-cased; the phone's (`*one-hand*`) branches are M2's (CORE-TOUCH-P is NIL in the sim: no thumb pad).
use crate::cl::fmt_fixed_f32;
use crate::components::{Button, Cls, Contact, Fighter, HazardKind, KikonUndo, MoveId, Phase, Queued, State};
use crate::core::{
    core_as_pointer, core_as_sa_out_p, core_cancel_land_sf, core_cancelled_p, core_kikon_count, core_kikon_ptr, core_sa_open_p,
    core_seg_dead_p, core_soul_break_count, core_turn_armor_verdict, core_verdict, core_xch_as_p, Verdict,
};
use crate::combat::{Pending, Queue, PENDING_MAX};
use crate::ecs::Entity;
use crate::gauges::pay_gauges;
use crate::fighter::{
    call_hook, enter_main, fighter, fighter_mut, id_of, ken_hook, kit_hook_sym, kit_of, mv, opp_of, pos_of, refund_fs, run_velocity,
    set_reaction, set_slide, side_name, spend_fs, start_move, stick_relative, to_idle, turn_to_opp, yaw_of,
};
use crate::kit::{kit_class, kit_core_move, kit_move, kit_sa_move, kit_sp_cost, kit_sp_free_p, kit_sp_start_p, mv_first_hit, mv_ns_next, mv_sa_move, mv_total, Role};
use crate::rules::{cancel_open_p, kikon_follow_speed, kikon_follow_wait, track_step, DefState};
use crate::sp::{sp_atk_gain, sp_break_take, sp_exchange_open_p, sp_neutral_p, sp_pay, sp_recancel_p, sp_scale, sp_switch_ok_p};
use crate::state::Match;
use duel_data::{Move, MoveClass};

fn mc(c: Option<Cls>) -> Option<MoveClass> {
    c.map(MoveClass::from)
}

/// KIT-CLASS of E's form for move MVD, as a fighter class.
fn class_of(m: &Match, e: Entity, mvd: Option<&Move>) -> Option<Cls> {
    kit_class(kit_of(m, e), mvd).map(Cls::from)
}

fn f32s(x: f32) -> String {
    fmt_fixed_f32(x, 1)
}

// ---------------------------------------------------------------- classes of the move in play

/// port: CORE-NOTE-START!: move ID starts (OLD: the move it replaces): its class, its start tick, the attack press counted.
pub fn core_note_start(m: &mut Match, e: Entity, id: MoveId, old: Option<MoveId>) {
    let mvd = mv(m, id);
    let cls = class_of(m, e, Some(mvd));
    let old_ns = old.is_some_and(|o| class_of(m, e, Some(mv(m, o))) == Some(Cls::Ns));
    let tick = m.match_tick;
    let f = fighter_mut(m, e);
    (f.cls, f.cls_t) = (cls, tick);
    // port: touch stub (core-sim.lisp 14): SP-HELD's :rearm (a phone tap, CORE-TOUCH-P) never: no `*one-hand*` in the sim yet.
    // Carry to the touch deck (M3); needs its own test: no trace has touch input, the gate cannot see it (M1_NOTES §10).
    f.sp_held = matches!(cls, Some(Cls::Ns | Cls::As));
    f.charge_mult = match mvd.params.charge_mult {
        Some(c) => c, // a charged SA arms it; its string keeps it
        None if old.is_some() && matches!(cls, Some(Cls::Na | Cls::As)) => f.charge_mult,
        None => 1.0,
    };
    if cls != Some(Cls::Ns) {
        (f.tmp, f.csa) = (0, None); // a temporary pointer lasts the NS route
    }
    if cls == Some(Cls::Ns) && !old_ns {
        f.clash_n = 0; // a fresh NS route counts its cancels from 0
    }
    if matches!(cls, Some(Cls::Na | Cls::Sa)) {
        f.presses += 1;
    }
}

/// port: CORE-PRE-ROLL: frames move MVD, about to start (F still in the old move), waits before its startup: *CORE-XCH-AS-DELAY* for an
/// AS out of a cancel (CORE-XCH-AS-P), else 0.
pub fn core_pre_roll(m: &Match, e: Entity, mvd: &Move) -> i64 {
    let f = fighter(m, e);
    if f.state == State::Move
        && mvd.hold.is_none()
        && !matches!(mvd.kind.as_str(), "breaker" | "kikon")
        && core_xch_as_p(kit_class(kit_of(m, e), Some(mvd)), mc(f.cls), f.xch, f.cls_t, f.xch_done)
    {
        m.knobs.core_xch_as_delay
    } else {
        0
    }
}

/// port: CORE-CHARGE-MULT: the damage x of attacker FA's hit with MV: a charged SA's x on the string it opened, not on the SA itself
/// nor on a hazard. OWN: MV is FA's move.
pub fn core_charge_mult(fa: &Fighter, mvd: Option<&Move>, own: bool, hazard: bool) -> f32 {
    if own && !hazard && mvd.is_some_and(|x| x.params.charge_mult.is_none()) { fa.charge_mult } else { 1.0 }
}

/// port: CORE-DEAD-P (research R3: never while *CORE-CANCEL-DEAD* is off, nothing marks one).
pub fn core_dead_p(f: &Fighter) -> bool {
    core_seg_dead_p(f.mv, f.cls_t, f.dead_mv, f.dead_t)
}

/// port: CORE-WINDOW-CLASS: the class of the move F is inside the startup or active frames of, else NIL (a dead segment: none).
pub fn core_window_class(m: &Match, f: &Fighter) -> Option<Cls> {
    let id = f.mv?;
    let mvd = mv(m, id);
    (f.state == State::Move && f.phase == Some(Phase::Main) && f.cls.is_some() && f.sf < (mvd.s + mvd.a) as i64 && !core_dead_p(f))
        .then_some(f.cls)
        .flatten()
}

// ---------------------------------------------------------------- starting moves

/// port: CORE-START!: start core move ID (START-MOVE with BUTTON: the Lisp's default :quick is the caller's `Some(Button::Quick)`; an
/// explicit NIL, the parry's catch, is None), the one place an SP segment pays. T when it started.
pub fn core_start(m: &mut Match, e: Entity, id: MoveId, button: Option<Button>) -> bool {
    let (kit, mvd) = (kit_of(m, e), mv(m, id));
    let Some(cost) = kit_sp_cost(kit, Some(mvd)) else {
        start_move(m, e, id, button);
        return true;
    };
    let g = m.gauges.get(e).expect("gauges");
    let (fs, gb) = (g.fs, g.burst);
    if !kit_sp_start_p(kit, mvd, fs, gb.is_some()) {
        // look: emit :refused
        crate::clog!(m, "{} SP {} refused (fs {})", side_name(m, e), mvd.name.to_uppercase(), f32s(fs));
        return false;
    }
    let burst = gb.is_some() || kit_sp_free_p(kit); // (free as in a burst: :sp-free)
    let (_, paid) = sp_pay(fs, cost, burst);
    start_move(m, e, id, button);
    if !burst {
        spend_fs(m, e, paid); // (at 0 too: the regen waits again)
    }
    let f = fighter_mut(m, e);
    (f.sp_paid, f.sp_cost) = (paid, if burst { 0.0 } else { cost });
    let x = sp_scale(f.sp_paid, f.sp_cost);
    crate::clog!(
        m,
        "{} SP {} fs {} cost {} paid {} x{}",
        side_name(m, e),
        mvd.name.to_uppercase(),
        f32s(fs),
        f32s(cost),
        f32s(paid),
        fmt_fixed_f32(x, 2)
    );
    true
}

/// port: CORE-SNAP-LV!: a new NS route or AS starts: its unlock level is the kit's :lv hook now (KEN-LV), else 99. False when the
/// hook is unported.
pub fn core_snap_lv(m: &mut Match, e: Entity) -> bool {
    let cap = match kit_hook_sym(m, e, "lv") {
        None => 99,
        Some(h) => match ken_hook(h) {
            Some(crate::ken::Hook::Lv) => crate::ken::hooks::lv(m, e),
            _ => crate::unported!(m, h, false),
        },
    };
    fighter_mut(m, e).lv_cap = cap;
    true
}

/// port: CORE-SEG-OK-P: is segment MVD open in F's route (its :params :lv at most the route's level)?
pub fn core_seg_ok_p(f: &Fighter, mvd: &Move) -> bool {
    mvd.params.lv.map_or(0, i64::from) <= f.lv_cap
}

/// port: CORE-SP-START!: SP from a free state: NS under the pointer. T when it started.
pub fn core_sp_start(m: &mut Match, e: Entity) -> bool {
    let ptr = fighter(m, e).ptr;
    let Some(mvd) = kit_core_move(m.data, kit_of(m, e), Role::Ns, ptr) else { return false };
    let f = fighter_mut(m, e);
    (f.sp_ptr, f.tmp, f.csa) = (ptr, 0, None);
    if !core_snap_lv(m, e) {
        return false;
    }
    let id = id_of(m, mvd);
    core_start(m, e, id, Some(Button::Quick))
}

/// port: CORE-NEXT-AS: the AS an SP pressed now would start in F's combo (the move's :as-ptr, else CORE-AS-POINTER).
pub fn core_next_as(m: &Match, e: Entity) -> i64 {
    let f = fighter(m, e);
    let core = &kit_of(m, e).core;
    let src = core.as_by_press.as_deref().unwrap_or(&[]);
    let mut by_press = [0i64; 16]; // (widened on the stack: the 0 B / step rule; a kit's :as-by-press is a few entries)
    for (d, &x) in by_press.iter_mut().zip(src) {
        *d = x as i64;
    }
    let by_press = &by_press[..src.len()]; // (panics past 16 entries rather than truncate)
    let n = f.mv.and_then(|id| mv(m, id).params.as_ptr).map_or_else(|| core_as_pointer(&m.knobs, f.presses, by_press), i64::from);
    n.min(1.max(core.as_segs.len() as i64)) // (no AS of that number in this kit: the last it has)
}

/// port: CORE-AS-START!: SP after an attack hit: the AS of the attack press count, writing the pointer (its :as-writes; a kit's :as-pick
/// hook may pick another move and the pointer it writes: KEN-AS-PICK). T when it started.
pub fn core_as_start(m: &mut Match, e: Entity) -> bool {
    if !core_snap_lv(m, e) {
        return false;
    }
    let n = core_next_as(m, e);
    let pick = match kit_hook_sym(m, e, "as-pick") {
        None => None,
        Some(h) => match ken_hook(h) {
            Some(crate::ken::Hook::AsPick) => crate::ken::hooks::as_pick(m, e, n),
            _ => crate::unported!(m, h, false), // (Hisagi's may also answer :TAKEN, M4)
        },
    };
    let kit = kit_of(m, e);
    let (id, w) = match pick {
        Some((id, pw)) => (id, pw),
        None => {
            let w = match &kit.core.as_writes {
                Some(ws) => ws.get((n - 1) as usize).copied().flatten().map(i64::from),
                None => [1, 2, 3].get((n - 1) as usize).copied(), // (the default '(1 2 3))
            };
            let Some(mvd) = kit_core_move(m.data, kit, Role::As, n) else { return false };
            (id_of(m, mvd), w)
        }
    };
    let f = fighter_mut(m, e);
    f.sp_ptr = f.ptr;
    core_start(m, e, id, Some(Button::Quick));
    let f = fighter_mut(m, e);
    (f.ptr, f.as_done) = (w.unwrap_or(f.ptr), true);
    match w {
        Some(w) => crate::clog!(m, "{} AS{} pointer {}", side_name(m, e), n, w),
        None => crate::clog!(m, "{} AS{} pointer kept {}", side_name(m, e), n, fighter(m, e).ptr),
    }
    true
}

/// port: CORE-MOVE-SP!: SP pressed inside move ID (MOVE-COMMANDS): AS off a landed attack, or the next NS / AS segment (or a pointer
/// switch) latched. T when something started.
pub fn core_move_sp(m: &mut Match, e: Entity, id: MoveId, _sf: i64, button: Button) -> bool {
    let mvd = mv(m, id);
    let f = fighter(m, e);
    match f.cls {
        Some(Cls::Na | Cls::Sa) => {
            f.contact == Some(Contact::Hit) && !f.as_done && cancel_open_p(f.sf, f.land_sf, mv_total(mvd), true) && core_as_start(m, e)
        }
        Some(c @ (Cls::Ns | Cls::As)) => {
            let to = if c == Cls::Ns { core_switch_target(m, e) } else { None };
            let eat = |m: &mut Match| m.pilot.get_mut(e).unwrap().vpad.consume(button as usize);
            if matches!(fighter(m, e).queued, Some(Queued::Sw | Queued::SwNs)) {
                fighter_mut(m, e).queued = Some(Queued::SwNs); // a press after a latched switch: its next segment, behind it
                eat(m);
            } else if let Some(to) = to {
                let f = fighter_mut(m, e);
                (f.queued, f.sw) = (Some(Queued::Sw), to);
                eat(m);
            } else if mv_ns_next(m.data, kit_of(m, e), mvd).is_some_and(|nx| core_seg_ok_p(fighter(m, e), nx)) {
                fighter_mut(m, e).queued = Some(Queued::Ns);
                eat(m);
            }
            false
        }
        None => false,
    }
}

/// port: CORE-SWITCH-OPEN-P: may E switch pointer now (SP-SWITCH-OK-P: not switched yet, a second NS route, the awakening gauge full
/// once (AW-FULL-P), SP above 0)?
pub fn core_switch_open_p(m: &Match, e: Entity) -> bool {
    let (g, f) = (m.gauges.get(e).expect("gauges"), fighter(m, e));
    sp_switch_ok_p(g.fs, crate::gauges::aw_full_p(&m.knobs, g), f.tmp > 0, kit_of(m, e).core.ns.len() as i64)
}

/// port: CORE-SWITCH-TARGET: the pointer a stick left / right + SP in an NS gap switches to, or NIL.
pub fn core_switch_target(m: &mut Match, e: Entity) -> Option<i64> {
    let n = kit_of(m, e).core.ns.len() as i64;
    if !core_switch_open_p(m, e) {
        return None;
    }
    let st = stick_relative(m, e).1;
    if st.abs() <= 0.5 {
        return None;
    }
    let ptr = fighter(m, e).ptr;
    let to = 1 + crate::cl::modulo(ptr - 1 + if st > 0.0 { 1 } else { -1 }, n);
    (to != ptr && kit_core_move(m.data, kit_of(m, e), Role::Ns, to).is_some()).then_some(to)
}

/// port: CORE-SA-MOVE: the SA an attack in F's NS segment MVD starts: a carried charge (CSA), the segment's :sa, the kit's.
pub fn core_sa_move(m: &Match, e: Entity, mvd: &Move) -> Option<MoveId> {
    let (f, kit) = (fighter(m, e), kit_of(m, e));
    f.csa.or_else(|| mv_sa_move(m.data, kit, mvd).or_else(|| kit_sa_move(m.data, kit)).map(|x| id_of(m, x)))
}

/// port: CORE-SEG-CANCELLED-P: has F's move in play taken part in a cancel?
pub fn core_seg_cancelled_p(f: &Fighter) -> bool {
    core_cancelled_p(f.xch, f.cls_t)
}

/// port: CORE-SA-START!: an attack pressed inside an NS segment: latch the SA, or start it at once after a cancel. T when it started.
pub fn core_sa_start(m: &mut Match, e: Entity, id: MoveId, _sf: i64, button: Button) -> bool {
    if kit_sa_move(m.data, kit_of(m, e)).is_none() {
        return false;
    }
    m.pilot.get_mut(e).unwrap().vpad.consume(button as usize);
    if core_seg_cancelled_p(fighter(m, e)) {
        fighter_mut(m, e).queued = None;
        let sa = core_sa_move(m, e, mv(m, id)).expect("an SA");
        core_start(m, e, sa, Some(Button::Quick))
    } else {
        fighter_mut(m, e).queued = Some(Queued::Sa);
        false
    }
}

/// port: CORE-AS-SA-PRESS! (research R4, *CORE-AS-SA-OUT*): an attack pressed in an AS segment. T when the SA started.
pub fn core_as_sa_press(m: &mut Match, e: Entity, id: MoveId, button: Button) -> bool {
    if kit_sa_move(m.data, kit_of(m, e)).is_none() {
        return false;
    }
    let f = fighter(m, e);
    if core_as_sa_out_p(m.knobs.core_as_sa_out, mc(f.cls), core_seg_cancelled_p(f)) {
        m.pilot.get_mut(e).unwrap().vpad.consume(button as usize);
        fighter_mut(m, e).queued = None;
        let sa = core_sa_move(m, e, mv(m, id)).expect("an SA");
        core_start(m, e, sa, Some(Button::Quick))
    } else {
        if f.queued.is_none() {
            m.pilot.get_mut(e).unwrap().vpad.consume(button as usize);
            fighter_mut(m, e).queued = Some(Queued::Sa);
        }
        false
    }
}

/// port: CORE-LATCH-STEP: a latched NS continuation, pointer switch or SA starts once the segment's active frames are over (an SA also
/// once the segment took part in a cancel: started on the cancel's tick). T when it started.
pub fn core_latch_step(m: &mut Match, e: Entity, id: MoveId, sf: i64) -> bool {
    let mvd = mv(m, id);
    let f = fighter(m, e);
    let q = f.queued;
    let cancelled = q == Some(Queued::Sa) && core_seg_cancelled_p(f);
    let sa_end = (mvd.s + mvd.a) as i64;
    let Some(q) = q.filter(|q| matches!(q, Queued::Ns | Queued::Sa | Queued::Sw | Queued::SwNs)) else { return false };
    let open = if q == Queued::Sa {
        if m.knobs.core_as_sa_out && f.cls == Some(Cls::As) { cancelled } else { core_sa_open_p(sf, mvd.s as i64, mvd.a as i64, cancelled) }
    } else {
        sf >= sa_end
    };
    if !(open && sf < mv_total(mvd)) {
        return false;
    }
    if cancelled && sf < sa_end {
        // fired early by the cancel: a guess, started on the cancel's tick
        let xch = f.xch;
        fighter_mut(m, e).queued = None;
        let sa = core_sa_move(m, e, mvd).expect("an SA");
        if core_start(m, e, sa, Some(Button::Quick)) {
            fighter_mut(m, e).cls_t = xch;
        }
        return true;
    }
    fighter_mut(m, e).queued = None;
    if matches!(q, Queued::Sw | Queued::SwNs) {
        // the temporary pointer: its NS route from segment 1, paid in SP like any NS segment
        let (to, from) = (fighter(m, e).sw, fighter(m, e).ptr);
        if let Some(sa) = mv_sa_move(m.data, kit_of(m, e), mvd)
            && sa.params.charge_mult.is_some()
        {
            fighter_mut(m, e).csa = Some(id_of(m, sa)); // a charge on the segment he leaves stays for his next SA
        }
        fighter_mut(m, e).sp_ptr = to;
        let ns = id_of(m, kit_core_move(m.data, kit_of(m, e), Role::Ns, to).expect("the switched route"));
        if core_start(m, e, ns, Some(Button::Quick)) {
            let f = fighter_mut(m, e);
            f.tmp = to;
            if q == Queued::SwNs {
                f.queued = Some(Queued::Ns);
            }
            let g = m.gauges.get(e).unwrap();
            let (drive, sub) = (g.drive, g.sub);
            crate::clog!(m, "{} NS pointer {} -> {} (SP; DRIVE {} SUB {} unchanged)", side_name(m, e), from, to, f32s(drive), f32s(sub));
        }
        return true;
    }
    let next = if q == Queued::Ns { mv_ns_next(m.data, kit_of(m, e), mvd).map(|x| id_of(m, x)) } else { core_sa_move(m, e, mvd) };
    match next {
        Some(n) if q != Queued::Ns || core_seg_ok_p(fighter(m, e), mv(m, n)) => core_start(m, e, n, Some(Button::Quick)),
        _ => false,
    }
}

// ---------------------------------------------------------------- judging a step's hits

/// port: CORE-VERDICTS: the triangle's verdict on each pending hit of this step, all judged against the states they were collected in.
pub fn core_verdicts(m: &Match, hits: &Queue<Pending, PENDING_MAX>) -> Queue<Verdict, PENDING_MAX> {
    let mut out = Queue::default();
    for h in hits.iter() {
        out.push({
            let (fa, fd) = (fighter(m, h.att), fighter(m, h.def));
            let hz = h.hazard.map(|x| m.hazard_of(x).expect("a hazard"));
            let ca = match hz {
                Some(hz) => hz.cls,
                None => h.mv.filter(|&x| Some(x) == fa.mv).and(fa.cls),
            };
            let cd = core_window_class(m, fd);
            if ca.is_some() && cd.is_some() && h.state != DefState::Parry {
                let simul = hits.iter().any(|h2| h2.att == h.def && h2.def == h.att && h2.mv.is_some() && h2.hazard.is_none());
                let att_t = hz.map_or(fa.cls_t, |hz| hz.sp_src);
                core_turn_armor_verdict(core_verdict(mc(ca), mc(cd), simul, Some(att_t), Some(fd.cls_t)), mc(ca), core_turn_armor_p(m, fd))
            } else {
                Verdict::Hit
            }
        });
    }
    out
}

/// port: CORE-TURN-ARMOR-P: is F inside the turn-move armour of his move (:params :turn-armor, *ARMOR-FROM* to its startup's end)?
pub fn core_turn_armor_p(m: &Match, f: &Fighter) -> bool {
    f.mv.is_some_and(|id| {
        let mvd = mv(m, id);
        f.state == State::Move && f.phase == Some(Phase::Main) && mvd.params.turn_armor && m.knobs.armor_from <= f.sf && f.sf < mvd.s as i64
    })
}

/// port: CORE-NOHIT!: apply a :cancel or :absorb verdict of pending hit H: no damage (a hazard's: CORE-HAZARD-NOHIT!).
pub fn core_nohit(m: &mut Match, h: &Pending, verdict: Verdict) {
    let (att, def) = (h.att, h.def);
    // (MX / MZ, the midpoint: only the cues' place, looks)
    if let Some(hz) = h.hazard {
        return core_hazard_nohit(m, hz, def, verdict);
    }
    let fa = fighter(m, att);
    if !(fa.state == State::Move && h.mv == fa.mv) {
        return;
    }
    let (dw, dm) = (core_window_class(m, fighter(m, def)), fighter(m, def).mv); // (his window now)
    let name = match h.mv {
        Some(x) if m.log_on => mv(m, x).name.to_uppercase(), // (the log lines' only: no allocation with the log off)
        _ => String::new(),
    };
    match verdict {
        Verdict::Cancel => {
            core_cancel_landed(m, att, true);
            if dw.is_some() {
                core_cancel_landed(m, def, true);
            }
            m.time.hitstop(m.knobs.hitstop_block as f32);
            m.time.slowmo(m.knobs.core_clash_slowmo_scale, m.knobs.core_clash_slowmo_seconds, false);
            // look: emit :clash
            crate::clog!(m, "{} {} x {}: CANCEL", side_name(m, att), name, side_name(m, def));
            core_xch_open(m, att, def);
            core_clash(m, att, def);
            core_cancel_hook(m, att, def, h.mv, None);
            if dw.is_some() {
                core_cancel_hook(m, def, att, dm, None);
            }
            let fd = fighter(m, def);
            if fighter(m, att).cls == core_window_class(m, fd) && fd.state == State::Move {
                core_bounce(m, att, def); // a same-class tie: both to neutral
            }
        }
        Verdict::Absorb => {
            let fa = fighter_mut(m, att);
            fa.contact = fa.contact.or(Some(Contact::Block));
            m.time.hitstop(m.knobs.hitstop_block as f32);
            // look: emit :armored
            crate::clog!(m, "{} {} x {}: ABSORBED", side_name(m, att), name, side_name(m, def));
        }
        Verdict::Hit => panic!("CORE-NOHIT!: ecase fell through on :HIT"),
    }
}

/// port: CORE-CANCEL-LANDED!: E took part in a cancel in his classed move: it counts as landed; an NS / AS segment's SP back once
/// (REFUND NIL: not this time); a J / SA's +30 once per move.
pub fn core_cancel_landed(m: &mut Match, e: Entity, refund: bool) {
    let tick = m.match_tick;
    let f = fighter(m, e);
    let first = mv_first_hit(mv(m, f.mv.expect("a move in a cancel")));
    let oxch = fighter(m, f.opp).xch;
    let (dead, no_refund, gain_once) = (m.knobs.core_cancel_dead, m.knobs.sp_recancel_no_refund, m.knobs.sp_cancel_gain_once);
    let f = fighter_mut(m, e);
    (f.contact, f.land_sf) = (Some(Contact::Hit), core_cancel_land_sf(f.land_sf, f.sf, first));
    if dead {
        (f.dead_mv, f.dead_t) = (f.mv, f.cls_t); // (research R3)
    }
    let recancel = sp_recancel_p(f.xch, oxch, tick);
    if refund && matches!(f.cls, Some(Cls::Ns | Cls::As)) && !f.sp_back && !(no_refund && recancel) {
        f.sp_back = true;
        let paid = f.sp_paid;
        refund_fs(m, e, paid);
        let fs = m.gauges.get(e).unwrap().fs;
        crate::clog!(m, "{} SP refund {} (fs {})", side_name(m, e), f32s(paid), f32s(fs));
    }
    let f = fighter_mut(m, e);
    if matches!(f.cls, Some(Cls::Na | Cls::Sa)) && f.sp_gain_t != f.cls_t && !(gain_once && recancel) {
        f.sp_gain_t = f.cls_t;
        let cls = f.cls;
        let fs0 = m.gauges.get(e).unwrap().fs;
        pay_gauges(m, e, sp_atk_gain(&m.knobs, mc(cls), true));
        let fs = m.gauges.get(e).unwrap().fs;
        crate::clog!(m, "{} SP cancel gain {} (fs {})", side_name(m, e), f32s(fs - fs0), f32s(fs));
    }
}

/// `~(~a ~a~)` of a hazard's kind and class.
fn hz_tag(kind: Option<HazardKind>, cls: Option<Cls>) -> String {
    format!("{} {}", kind.map_or("NIL", |k| k.name()), cls.map_or("NIL", |c| c.name())).to_lowercase()
}

/// port: CORE-HAZARD-NOHIT!: a :cancel or :absorb verdict between hazard HZ (judged as the segment that fired it) and fighter OTHER.
/// The caller removes the hazard.
pub fn core_hazard_nohit(m: &mut Match, hz: Entity, other: Entity, verdict: Verdict) {
    let h = m.hazard_of(hz).expect("a hazard").clone();
    let owner = h.owner;
    match verdict {
        Verdict::Cancel => {
            let paid = h.sp_paid;
            m.hazard_of_mut(hz).unwrap().sp_paid = 0.0; // ponytail (the Lisp's): one refund per hazard
            let fo = fighter(m, owner);
            if fo.state == State::Move && fo.cls_t == h.sp_src {
                core_cancel_landed(m, owner, paid > 0.0);
            } else if paid > 0.0 {
                refund_fs(m, owner, paid);
                let fs = m.gauges.get(owner).unwrap().fs;
                crate::clog!(m, "{} SP refund {} (fs {}), out of the move", side_name(m, owner), f32s(paid), f32s(fs));
            }
            let dw = core_window_class(m, fighter(m, other));
            if dw.is_some() {
                core_cancel_landed(m, other, true);
            }
            m.time.hitstop(m.knobs.hitstop_block as f32);
            m.time.slowmo(m.knobs.core_clash_slowmo_scale, m.knobs.core_clash_slowmo_seconds, false);
            // look: emit :clash
            crate::clog!(m, "{} {} x {}: CANCEL", side_name(m, owner), hz_tag(h.kind, h.cls), side_name(m, other));
            core_xch_open(m, owner, other);
            core_clash(m, owner, other);
            core_cancel_hook(m, owner, other, None, Some(hz));
            if dw.is_some() {
                let dm = fighter(m, other).mv;
                core_cancel_hook(m, other, owner, dm, None);
            }
        }
        Verdict::Absorb => {
            // look: emit :hazard-cut
            crate::clog!(m, "{} beats {}'s {}", side_name(m, other), side_name(m, owner), hz_tag(h.kind, h.cls));
        }
        Verdict::Hit => panic!("CORE-HAZARD-NOHIT!: ecase fell through on :HIT"),
    }
}

/// port: CORE-CANCEL-HOOK!: E's kit :cancel hook (Yamamoto's, M4; no Kenpachi / Ichigo kit has one).
pub fn core_cancel_hook(m: &mut Match, e: Entity, _other: Entity, _mv: Option<MoveId>, _hz: Option<Entity>) {
    if let Some(h) = kit_hook_sym(m, e, "cancel") {
        call_hook(m, e, h);
    }
}

/// port: CORE-CLASH!: each side's kit :clash hook, once a step for the pair (Hisagi's, M4).
pub fn core_clash(m: &mut Match, a: Entity, b: Entity) {
    let tick = m.match_tick;
    if fighter(m, a).clash_t == tick || fighter(m, b).clash_t == tick {
        return;
    }
    fighter_mut(m, a).clash_t = tick;
    fighter_mut(m, b).clash_t = tick;
    for x in [a, b] {
        if let Some(h) = kit_hook_sym(m, x, "clash")
            && !call_hook(m, x, h)
        {
            return;
        }
    }
}

// ---------------------------------------------------------------- the exchange after a cancel and its breakthrough

/// port: CORE-XCH-OPEN!: a cancel opens an exchange on both (this step's tick, its breakthrough not taken).
pub fn core_xch_open(m: &mut Match, a: Entity, b: Entity) {
    let tick = m.match_tick;
    for e in [a, b] {
        let f = fighter_mut(m, e);
        (f.xch, f.xch_done) = (tick, false);
    }
}

/// port: CORE-BREAK!: ATT's real hit on DEF inside their open exchange, breakthrough not taken: SP-BREAK-TAKE, once per exchange.
pub fn core_break(m: &mut Match, att: Entity, def: Entity) {
    let (fa, fd) = (fighter(m, att), fighter(m, def));
    if !(sp_exchange_open_p(fa.xch, fd.xch) && !fa.xch_done) {
        return;
    }
    fighter_mut(m, att).xch_done = true;
    fighter_mut(m, def).xch_done = true;
    let (take, gain) = sp_break_take(&m.knobs, m.gauges.get(def).unwrap().fs);
    if take > 0.0 {
        spend_fs(m, def, take);
    }
    let fs0 = m.gauges.get(att).unwrap().fs;
    pay_gauges(m, att, gain);
    let (dfs, afs) = (m.gauges.get(def).unwrap().fs, m.gauges.get(att).unwrap().fs);
    crate::clog!(m, "{} BREAK fs {} from {} (fs {}), gains {} (fs {})", side_name(m, att), f32s(take), side_name(m, def), f32s(dfs), f32s(afs - fs0), f32s(afs));
    // look: emit :sp-break
}

/// port: CORE-XCH-STEP: an open exchange ends at the first step both fighters are back in neutral, or when a cinematic has begun.
pub fn core_xch_step(m: &mut Match) {
    let (Some(a), Some(b)) = (m.fighter.get(m.p1), m.fighter.get(m.p2)) else { return };
    let sliding = |e| m.motion.get(e).is_some_and(|mo| mo.kb_left > 0);
    if sp_exchange_open_p(a.xch, b.xch)
        && (m.cine.is_some() || (sp_neutral_p(a.state, sliding(m.p1)) && sp_neutral_p(b.state, sliding(m.p2))))
    {
        for e in [m.p1, m.p2] {
            let f = m.fighter.get_mut(e).unwrap();
            (f.xch, f.xch_done) = (-1, false);
        }
        crate::clog!(m, "exchange over");
    }
}

/// port: CORE-BOUNCE!: A and B back to neutral, pushed apart.
pub fn core_bounce(m: &mut Match, a: Entity, b: Entity) {
    let (p, q) = (pos_of(m, a), pos_of(m, b)); // (TO-IDLE doesn't move them)
    for x in [a, b] {
        let f = fighter_mut(m, x);
        (f.follow, f.kikon_lock) = (false, 0);
        to_idle(m, x);
    }
    let d = 0.5 * m.knobs.clash_push;
    set_slide(m, a, d, 12, p[0] - q[0], p[2] - q[2]);
    set_slide(m, b, d, 12, q[0] - p[0], q[2] - p[2]);
}

// ---------------------------------------------------------------- the Kikon hold

/// port: CORE-KIKON-P: is MVD (a move of E's kit) an SP that holds into the Kikon (NS / AS, not :no-kikon)?
pub fn core_kikon_p(m: &Match, e: Entity, mvd: Option<&Move>) -> bool {
    mvd.is_some_and(|x| matches!(class_of(m, e, Some(x)), Some(Cls::Ns | Cls::As)) && !x.params.no_kikon)
}

/// port: CORE-HOLD-STEP: inside an NS / AS segment a let-go of the SP button clears the hold. Its value: T only for a phone's :rearm
/// (none in the sim), so always NIL here.
pub fn core_hold_step(m: &mut Match, e: Entity) -> bool {
    // port: touch stub (core-sim.lisp 418-423): the :rearm arm (a new SP touch re-arms the hold) is missing;
    // touch deck (M3), needs its own test: no trace has touch input, the gate cannot see it (M1_NOTES §10).
    if fighter(m, e).sp_held && !core_held_p(m, e) {
        fighter_mut(m, e).sp_held = false;
    }
    false
}

/// port: CORE-TOUCH-P: is F P1 on the phone's thumb pad (`*one-hand*`)? NIL: the sim has no thumb pad (M3).
pub fn core_touch_p(_m: &Match, _e: Entity) -> bool {
    // port: touch stub (core-sim.lisp 423-425, `*one-hand*` P1): a constant NIL;
    // touch deck (M3), needs its own test: no trace has touch input, the gate cannot see it (M1_NOTES §10).
    false
}

/// port: CORE-TOUCH-SP-P: a contact down in the pad's SP zone. NIL without a thumb pad (M3).
pub fn core_touch_sp_p(_m: &Match) -> bool {
    // port: touch stub (core-sim.lisp 427-431, the thumb pad's SP zone): a constant NIL;
    // touch deck (M3), needs its own test: no trace has touch input, the gate cannot see it (M1_NOTES §10).
    false
}

/// port: CORE-HELD-P: is ATT still holding the SP button (the attack button) this step?
pub fn core_held_p(m: &Match, att: Entity) -> bool {
    m.pilot.get(att).expect("a pilot").vpad.down(Button::Quick as usize) || (core_touch_p(m, att) && core_touch_sp_p(m))
}

/// port: CORE-KIKON-CINE: the cinematic of ATT's Kikon by the pointer of the SP that struck.
pub fn core_kikon_cine(m: &Match, att: Entity) -> Option<&'static str> {
    core_pointer_cine(m, att, fighter(m, att).sp_ptr)
}

/// port: CORE-POINTER-CINE: pointer PTR's Kikon cinematic in ATT's kit (:core :kikon-cines), or NIL.
pub fn core_pointer_cine(m: &Match, att: Entity, ptr: i64) -> Option<&'static str> {
    let i = 1.max(m.knobs.core_pointer_max.min(ptr)) - 1;
    kit_of(m, att).core.kikon_cines.get(i as usize).map(String::as_str)
}

/// port: CORE-SOUL-BREAK-CINE: the current pointer's Kikon cinematic, else the kit's (KIT-KIKON-CINE).
pub fn core_soul_break_cine(m: &Match, att: Entity) -> &'static str {
    core_pointer_cine(m, att, fighter(m, att).ptr).unwrap_or_else(|| crate::kit::kit_kikon_cine(m.data, kit_of(m, att)))
}

/// port: CORE-SET-KIKON-N!: the Konpaku the Kikon about to follow takes (CORE-KIKON-COUNT; a kit's :kikon-n hook, Yamamoto's, M4).
pub fn core_set_kikon_n(m: &mut Match, att: Entity, red: bool) {
    let n = core_kikon_count(&m.knobs, kit_of(m, att).kikon_konpaku as i64, fighter(m, att).sp_ptr, red);
    if let Some(h) = kit_hook_sym(m, att, "kikon-n") {
        call_hook(m, att, h);
        return;
    }
    fighter_mut(m, att).kikon_n = n;
}

/// port: CORE-CONFIRM-FRAMES: frames of the dash-in the hold is judged on (*CORE-KIKON-CONFIRM*; the phone's, M3).
pub fn core_confirm_frames(m: &Match, _f: &Fighter, _mvd: &Move) -> i64 {
    // port: touch stub (core-sim.lisp 463): `*core-kikon-confirm-touch*` (and its :dash) for a CORE-TOUCH-P fighter is missing; touch
    // deck (M3), needs its own test: no trace has touch input, the gate cannot see it (M1_NOTES §10).
    m.knobs.core_kikon_confirm
}

/// port: CORE-KIKON-DEFER: frames after the hitstop a core SP's held hit waits before the knockback (0 for an old-style rush).
pub fn core_kikon_defer(m: &Match, f: &Fighter) -> i64 {
    if f.kikon_undo.is_some() { m.knobs.core_kikon_confirm } else { 0 }
}

/// port: CORE-FOLLOW-STEP: the Kikon's dash-in after the struck SP (phase :follow): stand CORE-KIKON-DEFER frames, then knock the
/// victim back and chase him KIKON-FOLLOW-WAIT frames, then the same strike again; a let-go inside the confirm drops it.
pub fn core_follow_step(m: &mut Match, e: Entity, id: MoveId) {
    let mvd = mv(m, id);
    fighter_mut(m, e).hold += 1;
    let f = fighter(m, e);
    if f.hold <= core_confirm_frames(m, f, mvd) && !core_held_p(m, e) && f.kikon_undo.is_some() {
        crate::clog!(m, "{} lets go: no Kikon", side_name(m, e));
        return core_kikon_undo(m, e);
    }
    let d = core_kikon_defer(m, f);
    if d == 0 {
        // look: the follow cues on frame 1
    } else if f.hold == d {
        core_kikon_knock(m, e);
    }
    let hold = fighter(m, e).hold;
    let left = kikon_follow_wait(&m.knobs, mvd.s as i64) + d - hold;
    crate::fighter::halt(m, e);
    turn_to_opp(m, e, track_step(360.0));
    if hold >= d {
        let sp = kikon_follow_speed(&m.knobs, fighter(m, e).dist, left, mvd.params.follow_cap.unwrap_or(22.0));
        let y = yaw_of(m, e);
        run_velocity(m, e, sp, y);
    }
    if left <= 0 {
        let f = fighter_mut(m, e);
        (f.hits, f.contact, f.land_sf) = (0, None, -1);
        enter_main(m, e);
    }
}

/// port: CORE-KIKON-KNOCK!: the hold confirmed: the victim knocked back into the Kikon's reel (the cues: looks).
pub fn core_kikon_knock(m: &mut Match, e: Entity) {
    let KikonUndo { def, sx, sz, kreact, kstun, .. } = fighter(m, e).kikon_undo.clone().expect("a Kikon undo");
    set_reaction(m, def, kreact, kstun, sx, sz, m.knobs.kikon_follow_kb);
}

/// port: CORE-FOLLOW-CUES: the KIKON call-out and the dash-in's take-off: cosmetic.
pub fn core_follow_cues(_m: &mut Match, _att: Entity, _def: Entity) {
    // look: emit :kikon-follow, :rush-dash
}

/// port: CORE-KIKON-UNDO!: a let-go inside the confirm: the held SP's hit was an ordinary one after all (the victim in its own
/// reaction, E back in his move where it hit; a wave's strike: E free again).
pub fn core_kikon_undo(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    let KikonUndo { def, react, stun, sx, sz, kb, wave, .. } = f.kikon_undo.clone().expect("a Kikon undo");
    let hold = f.hold;
    let knocked = hold > core_kikon_defer(m, f) || matches!(react, Phase::Knockdown | Phase::Launch);
    let f = fighter_mut(m, e);
    (f.follow, f.kikon_undo) = (false, None);
    fighter_mut(m, def).kikon_lock = 0;
    crate::fighter::halt(m, e);
    if knocked {
        set_reaction(m, def, Some(react), 1.max(stun - hold), sx, sz, kb);
    }
    if wave {
        to_idle(m, e);
    } else {
        fighter_mut(m, e).phase = Some(Phase::Main);
    }
}

/// port: CORE-WAVE-STRIKE: the follow-up strike (:params :kikon-strike) of the wave HZ that ATT's segment fired, when its hit may be a
/// Kikon's first strike (the hold kept, ATT still in that segment or free). Else NIL.
pub fn core_wave_strike(m: &Match, att: Entity, hz: Option<Entity>) -> Option<MoveId> {
    let f = fighter(m, att);
    let from = hz.and_then(|h| m.hazard_of(h)).and_then(|h| h.sp_mv)?;
    if !(f.sp_held && ((f.state == State::Move && f.mv == Some(from)) || f.state == State::Idle)) {
        return None;
    }
    let name = mv(m, from).params.kikon_strike.as_deref()?;
    kit_move(m.data, kit_of(m, att), name).map(|x| id_of(m, x))
}

/// port: CORE-WAVE-FOLLOW!: a wave's hit held: ATT flash-steps in after the victim, STRIKE the follow-up.
pub fn core_wave_follow(m: &mut Match, att: Entity, strike: MoveId) {
    start_move(m, att, strike, Some(Button::Quick));
}

/// port: CORE-KIKON-CANCEL!: the victim attacked while the Kikon's follow-up was coming (not red): cancelled, both bounce to neutral;
/// the victim's +30 (once per exchange under research R1), an exchange opens.
pub fn core_kikon_cancel(m: &mut Match, victim: Entity) {
    let o = opp_of(m, victim);
    crate::clog!(m, "{} cancels the Kikon follow-up", side_name(m, victim));
    let (xa, xb) = (fighter(m, victim).xch, fighter(m, o).xch);
    if !(m.knobs.sp_cancel_gain_once && sp_recancel_p(xa, xb, m.match_tick)) {
        let fs0 = m.gauges.get(victim).unwrap().fs;
        pay_gauges(m, victim, sp_atk_gain(&m.knobs, Some(MoveClass::Na), true));
        let fs = m.gauges.get(victim).unwrap().fs;
        crate::clog!(m, "{} SP cancel gain {} (fs {})", side_name(m, victim), f32s(fs - fs0), f32s(fs));
    }
    core_xch_open(m, victim, o);
    core_clash(m, victim, o);
    m.time.hitstop(m.knobs.hitstop_block as f32);
    m.time.slowmo(m.knobs.core_clash_slowmo_scale, m.knobs.core_clash_slowmo_seconds, false);
    // look: emit :clash
    core_bounce(m, victim, o);
}

/// port: CORE-ON-HIT!: a landed hit of a core AS besides damage, at MULT: :steal-fs (the hit window's STEAL, else the move's) takes
/// flash-step from DEF and gives *STEAL-FS-GAIN* of it to ATT.
pub fn core_on_hit(m: &mut Match, att: Entity, def: Entity, id: MoveId, mult: f32, hw_steal: Option<i64>) {
    let Some(fs) = hw_steal.or(mv(m, id).params.steal_fs.map(i64::from)).filter(|&x| x > 0) else { return };
    let (take, gain) = crate::rules::steal_take(&m.knobs, mult * fs as f32, m.gauges.get(def).unwrap().fs);
    if take > 0.0 {
        spend_fs(m, def, take);
    }
    pay_gauges(m, att, gain);
    crate::clog!(m, "{} STEAL fs {} from {}, gains {}", side_name(m, att), f32s(take), side_name(m, def), f32s(gain));
}

// STEAL-SCENE-FS! / STEAL-FS-LINE: debug 83815 / 74908 / 83816 / 74909's `log-msg` lines (not the sim, never in a trace): not ported.

/// port: CORE-KONPAKU-RESULT: Konpaku (left, lost, ko-p) after a Kikon or a Soul Break by ATT.
pub fn core_konpaku_result(m: &Match, konpaku: i64, att: Entity, soul_break: bool) -> (i64, i64, bool) {
    let f = fighter(m, att);
    let base = kit_of(m, att).kikon_konpaku as i64;
    let ptr = core_kikon_ptr(mc(f.cls), f.sp_ptr, f.ptr);
    let lost = konpaku.min(if soul_break { core_soul_break_count(&m.knobs, base, ptr) } else { f.kikon_n });
    (konpaku - lost, lost, konpaku - lost <= 0)
}

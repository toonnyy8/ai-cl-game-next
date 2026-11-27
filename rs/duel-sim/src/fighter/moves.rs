//! port: fighter.lisp — starting a move (START-MOVE, ENTER-MAIN), the `:move` step and its phases (hold, Breaker, Kikon rush, the
//! core SP's :follow, main), the chains and cancels inside a move (MOVE-COMMANDS, CANCEL-INTO), the ender push and HOHO-RESUME!.
//! Hook symbols (a move's :on-frame / :tick / :release / :on-land, a kit's :hooks) go through `call_hook`.
use super::*;
use crate::cl::{fmt_fixed_f32, max_f32, min_f32};
use crate::components::{Cls, Queued};
use crate::core_sim::*;
use crate::kit::{kit_command_move, kit_next, kit_sa_move, mv_ns_next, mv_sa_move, mv_total, string_link_p};
use crate::math::{fwd_x, fwd_z};
use crate::rules::{
    breaker_next_phase, breaker_speed, cancel_open_p, chain_open_p, chain_startup_cut, kikon_follow_speed, kikon_follow_wait,
    kikon_rush_next_phase, move_end_frame, ray_room, string_chase_speed, track_step,
};

/// port: FUNCALL of hook symbol NAME on E alone (a move's :on-frame / :tick / :release / :on-land, a kit's :tick / :reset / ...),
/// resolved through `kit::resolve`. True when the run goes on; an unported hook (Hisagi's / Yamamoto's: M4)
/// records `unported!(NAME)` and returns false: the caller returns.
pub fn call_hook(m: &mut Match, e: Entity, name: &'static str) -> bool {
    match crate::kit::resolve(name) {
        Some(crate::kit::HookFn::Ken(h)) => crate::ken::call(m, e, h),
        Some(crate::kit::HookFn::Ichigo(h)) => crate::ichigo::call(m, e, h),
        Some(crate::kit::HookFn::Look) => true,
        Some(crate::kit::HookFn::Cine) => unreachable!("{name}: a cinematic, never called"),
        Some(crate::kit::HookFn::Unported) | None => crate::unported!(m, name, false),
    }
}

/// The Ichigo hook symbol NAME names, if it is one (a typed hook's call site dispatches on it).
pub fn ichigo_hook(name: &str) -> Option<crate::ichigo::Hook> {
    match crate::kit::resolve(name) {
        Some(crate::kit::HookFn::Ichigo(h)) => Some(h),
        _ => None,
    }
}

/// The Kenpachi hook symbol NAME names, if it is one (a typed hook's call site dispatches on it).
pub fn ken_hook(name: &str) -> Option<crate::ken::Hook> {
    match crate::kit::resolve(name) {
        Some(crate::kit::HookFn::Ken(h)) => Some(h),
        _ => None,
    }
}

/// port: KIT-HOOK of E's form: the symbol of its KEY hook, if any.
pub fn kit_hook_sym(m: &Match, e: Entity, key: &str) -> Option<&'static str> {
    kit_of(m, e).hooks.get(key).map(String::as_str)
}

/// MV-ON-FRAME: the move's (frame hook) entries.
fn on_frame(mvd: &'static Move) -> impl Iterator<Item = (i64, &'static str)> {
    mvd.on_frame.iter().map(|x| (x[0].as_f32().expect("a frame") as i64, x[1].as_str().expect("a hook symbol")))
}

/// Runs MVD's frame hooks of frame FR on E; false once one is unported.
fn run_on_frame(m: &mut Match, e: Entity, mvd: &'static Move, fr: i64) -> bool {
    for (hf, hook) in on_frame(mvd) {
        if hf == fr && !call_hook(m, e, hook) {
            return false;
        }
    }
    true
}

fn kind_in(mvd: &Move, kinds: &[&str]) -> bool {
    kinds.contains(&mvd.kind.as_str())
}

fn has_flag(mvd: &Move, flag: &str) -> bool {
    mvd.flags.iter().any(|f| f == flag)
}

/// MOVE-END-FRAME of MVD for F's contact.
fn end_frame(m: &Match, f: &Fighter, mvd: &Move) -> i64 {
    move_end_frame(&m.knobs, mvd.s as i64, mvd.a as i64, mvd.r as i64, Some(mvd.whiff as i64), f.contact, mvd.hits.is_empty(), Some(&mvd.kind))
}

// ---------------------------------------------------------------- starting a move

/// port: START-MOVE: enter move ID (of E's kit). Frame (MV-ENTER mv) is this step; MOVE-STEP advances it. An AS out of a cancel
/// (CORE-PRE-ROLL) starts PRE frames before it. Returns ID.
pub fn start_move(m: &mut Match, e: Entity, id: MoveId, button: Option<Button>) -> MoveId {
    let mvd = mv(m, id);
    let enter = mvd.enter as i64;
    let f = fighter(m, e);
    let old = current_move(f);
    let pre = core_pre_roll(m, e, mvd);
    let off_ender = f.chain > 0 // ORANGE's restart, or a move started off a J / K ender that hit, or J1 / K1 off a landed Breaker
        || old.is_some_and(|o| {
            let od = mv(m, o);
            has_flag(od, "ender") && kind_in(od, &["quick", "flash"]) && f.contact == Some(Contact::Hit)
        })
        || old.is_some_and(|o| mv(m, o).kind == "breaker" && f.contact == Some(Contact::Hit));
    let phase = if kind_in(mvd, &["breaker", "kikon"]) {
        Phase::Aura
    } else if mvd.hold.is_some() {
        Phase::Hold
    } else {
        Phase::Main
    };
    {
        let f = fighter_mut(m, e);
        f.end_chase = off_ender;
        (f.state, f.mv, f.sf, f.pre, f.hits) = (State::Move, Some(id), enter - pre, pre, 0);
        (f.contact, f.hz_hit, f.queued, f.chained, f.land_sf, f.dmg_bonus, f.crush) = (None, false, None, false, -1, 0, false);
        f.stored = 0; // an interrupted stance keeps nothing
        (f.button, f.hold, f.perfect, f.follow, f.hoho_hold) = (button, 0, false, false, false);
        f.armor_left = mvd.armor_hits as i64;
        (f.sp_paid, f.sp_cost, f.sp_back) = (0.0, 0.0, false); // (CORE-START! sets them after for an SP segment)
        f.phase = Some(phase);
    }
    core_note_start(m, e, id, old);
    halt(m, e);
    // look: play-clip of the form's clip (a pre-roll's wind-up slower)
    if mvd.kind == "kikon" {
        callout(m, e, "KIKON");
    } else if let Some(c) = &mvd.callout {
        callout(m, e, c);
    }
    if mvd.kind == "sp" {
        // super flash: the opponent alone freezes
        let (o, sf) = (opp_of(m, e), m.knobs.super_freeze);
        let fo = fighter_mut(m, o);
        fo.freeze_next = fo.freeze_next.max(sf);
    } // look: emit :super / :breaker / :rush
    crate::clog!(m, "{} move {}{}", side_name(m, e), mvd.name.to_uppercase(), crate::fighter::why_suffix(m, e));
    if phase == Phase::Main && pre == 0 && !run_on_frame(m, e, mvd, enter) {
        return id; // (a hook on the move's first frame; a pre-roll's: MAIN-PHASE-STEP runs it on that frame)
    }
    if fighter(m, e).chain > 0 {
        // ORANGE: the first move after the cancel starts later in its startup (the skipped frames' hooks run now)
        fighter_mut(m, e).chain = 0;
        let cut = if phase == Phase::Main && pre == 0 { chain_startup_cut(&m.knobs, mvd.s as i64, enter) } else { 0 };
        if cut > 0 {
            for fr in enter + 1..=enter + cut {
                if fighter(m, e).mv != Some(id) {
                    break;
                }
                if !run_on_frame(m, e, mvd, fr) {
                    return id;
                }
            }
            if fighter(m, e).mv == Some(id) {
                fighter_mut(m, e).sf = enter + cut;
                // look: play-clip at the cut
                crate::clog!(m, "{} chain cut {} f", side_name(m, e), cut);
            }
        }
    }
    id
}

/// port: ENTER-MAIN: a hold / Breaker move leaves its pre-strike phase: the move proper starts at frame 0.
pub fn enter_main(m: &mut Match, e: Entity) {
    let f = fighter_mut(m, e);
    (f.phase, f.sf) = (Some(Phase::Main), 0);
    halt(m, e);
    // look: the move's :clip-2, emit :breaker-end
}

// ---------------------------------------------------------------- the :move step

/// port: MOVE-STEP: advance the current move one frame: its pre-strike phase, or the move proper.
pub fn move_step(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    let id = f.mv.expect("a move in :move");
    match f.phase {
        Some(Phase::Hold) => hold_phase_step(m, e, id),
        Some(Phase::Aura | Phase::Dash | Phase::Follow) => {
            if mv(m, id).kind == "kikon" {
                kikon_rush_step(m, e, id)
            } else if f.phase == Some(Phase::Follow) {
                core_follow_step(m, e, id) // a core SP's Kikon (core-sim.lisp)
            } else {
                breaker_phase_step(m, e, id)
            }
        }
        _ => main_phase_step(m, e, id),
    }
}

/// port: HOLD-PHASE-STEP: charge / stance: hold until the button is released (min..max frames), then the move proper.
pub fn hold_phase_step(m: &mut Match, e: Entity, id: MoveId) {
    let mvd = mv(m, id);
    fighter_mut(m, e).hold += 1;
    if let Some(t) = &mvd.tick
        && !call_hook(m, e, t)
    {
        return;
    }
    let [lo, hi] = mvd.hold.as_deref().map(|h| [h[0] as i64, h[1] as i64]).expect("a hold move");
    let f = fighter(m, e);
    let down = f.button.is_some_and(|b| m.pilot.get(e).unwrap().vpad.down(b as usize));
    if f.mv == Some(id) && f.phase == Some(Phase::Hold) && (f.hold >= hi || (f.hold >= lo && !down)) {
        let f = fighter_mut(m, e);
        f.charge = f.hold;
        if let Some(r) = &mvd.release
            && !call_hook(m, e, r)
        {
            return;
        }
        if fighter(m, e).mv == Some(id) {
            enter_main(m, e);
        }
    }
}

/// port: BREAKER-PHASE-STEP: the aura, then the dash while held (BREAKER-NEXT-PHASE), then the strike.
pub fn breaker_phase_step(m: &mut Match, e: Entity, id: MoveId) {
    let f = fighter_mut(m, e);
    f.hold += 1;
    let (phase, hold, dist, button) = (f.phase.expect("a Breaker phase"), f.hold, f.dist, f.button);
    let held = button.is_some_and(|b| m.pilot.get(e).unwrap().vpad.down(b as usize));
    let next = breaker_next_phase(&m.knobs, phase, hold, held, dist);
    if next == Phase::Strike {
        enter_main(m, e);
    } else {
        if next != phase {
            let f = fighter_mut(m, e);
            (f.phase, f.hold) = (Some(next), 0);
        }
        halt(m, e);
        if next == Phase::Dash {
            turn_to_opp(m, e, track_step(mv(m, id).track));
            let (sp, yaw) = (breaker_speed(&m.knobs, fighter(m, e).hold), yaw_of(m, e));
            let v = &mut m.motion.get_mut(e).unwrap().vel;
            (v[0], v[2]) = (sp * fwd_x(yaw), sp * fwd_z(yaw));
        }
    }
}

/// port: RUSH-DASH-MAX: the rush's dash frames (its :dash-max; at least *ENDER-O-DASH*, or its :ender-dash, off a pushing ender).
pub fn rush_dash_max(m: &Match, f: &Fighter, mvd: &Move) -> i64 {
    let dm = mvd.params.dash_max.expect("a rush's :dash-max") as i64;
    if f.end_chase { mvd.params.ender_dash.map_or(m.knobs.ender_o_dash, i64::from).max(dm) } else { dm }
}

/// port: RUSH-DASH-SPEED: the rush's :speed, at least *ENDER-O-SPEED* off a pushing ender.
pub fn rush_dash_speed(m: &Match, f: &Fighter, mvd: &Move) -> f32 {
    let s = mvd.params.speed.expect("a rush's :speed");
    if f.end_chase { max_f32(m.knobs.ender_o_speed, s) } else { s }
}

/// port: KIKON-RUSH-STEP: the aura (turning at :aim), the dash at :speed (turning at :dash-track) until KIKON-RUSH-NEXT-PHASE says
/// strike; phase :follow: dash in after the knocked-back victim for KIKON-FOLLOW-WAIT frames, then the strike again.
pub fn kikon_rush_step(m: &mut Match, e: Entity, id: MoveId) {
    let mvd = mv(m, id);
    let p = &mvd.params;
    fighter_mut(m, e).hold += 1;
    halt(m, e);
    let f = fighter(m, e);
    let (phase, hold, dist) = (f.phase.expect("a rush phase"), f.hold, f.dist);
    if phase == Phase::Follow {
        let left = kikon_follow_wait(&m.knobs, mvd.s as i64) - hold;
        turn_to_opp(m, e, track_step(p.aim.expect("a rush's :aim")));
        let cap = p.follow_speed.unwrap_or_else(|| max_f32(14.0, p.speed.expect("a rush's :speed")));
        let sp = kikon_follow_speed(&m.knobs, fighter(m, e).dist, left, cap);
        let y = yaw_of(m, e);
        run_velocity(m, e, sp, y);
        if left <= 0 {
            let f = fighter_mut(m, e);
            (f.hits, f.contact, f.land_sf) = (0, None, -1);
            enter_main(m, e);
        }
        return;
    }
    let dash_max = rush_dash_max(m, f, mvd);
    let mut next = kikon_rush_next_phase(&m.knobs, phase, hold, dist, p.aura.expect("a rush's :aura") as i64, dash_max);
    if next == Phase::Strike && phase == Phase::Dash && f.end_chase && hold < dash_max && m.motion.get(f.opp).unwrap().kb_left > 0 {
        next = Phase::Dash; // off a pushing ender: he still slides away, dash on
    }
    if next == Phase::Strike {
        enter_main(m, e);
    } else {
        if next != phase {
            let f = fighter_mut(m, e);
            (f.phase, f.hold) = (Some(next), 0);
            // look: emit :rush-dash
        }
        if next == Phase::Dash {
            turn_to_opp(m, e, track_step(p.dash_track.expect("a rush's :dash-track")));
            let sp = rush_dash_speed(m, fighter(m, e), mvd);
            let y = yaw_of(m, e);
            run_velocity(m, e, sp, y);
        } else {
            turn_to_opp(m, e, track_step(p.aim.expect("a rush's :aim")));
        }
    }
}

/// port: SKIP-AURA: the O ender's rush skips its aura (its strike at once within reach, else its dash). Reached only from MOVE-COMMANDS'
/// :kikon clause, and :kikon is not in `*commands*`; kept for the CPU's / a later command table.
pub fn skip_aura(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    let mvd = mv(m, f.mv.expect("a rush"));
    let dm = rush_dash_max(m, f, mvd);
    if !f.end_chase && kikon_rush_next_phase(&m.knobs, Phase::Aura, 0, f.dist, 0, dm) == Phase::Strike {
        enter_main(m, e);
    } else {
        let f = fighter_mut(m, e);
        (f.phase, f.hold) = (Some(Phase::Dash), 0);
        // look: emit :rush-dash
    }
}

/// port: MAIN-PHASE-STEP: the move proper, one frame: tracking and lunge in the startup, frame hooks, chains and cancels, the end.
pub fn main_phase_step(m: &mut Match, e: Entity, id: MoveId) {
    let mvd = mv(m, id);
    let s = mvd.s as i64;
    let f = fighter_mut(m, e);
    f.sf += 1;
    let sf = f.sf;
    halt(m, e);
    if sf < s {
        let f = fighter(m, e);
        let chained = f.chained;
        let chase = if f.end_chase || (chained && !kind_in(mvd, &["quick", "flash"])) {
            let cap = if f.end_chase { m.knobs.ender_chase_max } else { m.knobs.chase_max };
            string_chase_speed(&m.knobs, f.dist, mvd.reach, s - sf, cap)
        } else {
            0.0
        };
        let slide = if mvd.slide > 0.0 && f.dist > m.knobs.lunge_stop { 60.0 * (mvd.slide / s as f32) } else { 0.0 };
        let sp = max_f32(chase, slide);
        let track = if chained { max_f32(mvd.track, m.knobs.chase_track) } else { mvd.track };
        turn_to_opp(m, e, track_step(track));
        if sp > 0.0 && sf > mvd.enter as i64 {
            // (a pre-roll's frames: no lunge yet)
            let yaw = yaw_of(m, e);
            let v = &mut m.motion.get_mut(e).unwrap().vel;
            (v[0], v[2]) = (sp * fwd_x(yaw), sp * fwd_z(yaw));
        }
    }
    // look: a pre-roll's anim speed back at the hit pose (sf = s)
    if !run_on_frame(m, e, mvd, sf) {
        return;
    }
    if let Some(t) = &mvd.tick
        && !call_hook(m, e, t)
    {
        return;
    }
    // look: emit :swing on a window's first frame
    if fighter(m, e).mv != Some(id) {
        return; // a hook may have started another move
    }
    if fighter(m, e).lock == 0 && move_commands(m, e, id, sf) {
        return;
    }
    // ponytail: the guard cancel (GUARD-CANCEL-OPEN-P and GUARD-HELD-P) never fires: GUARD-HELD-P is NIL in the core system
    if sf >= end_frame(m, fighter(m, e), mvd) {
        to_idle(m, e);
    } // look: else RECOVERY-PACE (anim speed only)
}

/// port: PUSH-APART: push B DIST metres away from A over FRAMES; what the arena's edge leaves no room for pushes A back. (B's, A's).
pub fn push_apart(m: &mut Match, a: Entity, b: Entity, dist: f32, frames: i64) -> (f32, f32) {
    let (p, q) = (pos_of(m, a), pos_of(m, b));
    let (dx, dz) = (q[0] - p[0], q[2] - p[2]);
    let l = max_f32(1e-4, crate::math::hypot(dx, dz));
    let (ux, uz) = (dx / l, dz / l);
    let room = ray_room(q[0], q[2], ux, uz, m.knobs.arena_radius - hurt_r(m, b));
    let mb = min_f32(dist, room);
    let ma = dist - mb;
    if mb > 0.01 {
        set_slide(m, b, mb, frames, ux, uz);
    }
    if ma > 0.01 {
        set_slide(m, a, ma, frames, -ux, -uz);
    }
    (mb, ma)
}

/// port: ENDER-PUSH (combat.lisp calls it): E's J / K string ender ID just hit O: O pushed out of the reach of E's J1 / K1.
pub fn ender_push(m: &mut Match, e: Entity, o: Entity, id: MoveId) {
    let mvd = mv(m, id);
    if let Some(h) = kit_hook_sym(m, e, "command") {
        crate::unported!(m, h) // (KIT-COMMAND-MOVE with E: Hisagi's :command hook, M4)
    }
    let kit = kit_of(m, e);
    let Some(opener) = kit_command_move(m.data, kit, if mvd.kind == "quick" { "q" } else { "f" }) else { return };
    let push = crate::kit::ender_push_reach(kit, mvd, opener) + opener.slide + hurt_r(m, o) + m.knobs.ender_push - fighter(m, e).dist;
    if push > 0.0 {
        let (mb, ma) = push_apart(m, e, o, push, m.knobs.ender_push_frames);
        crate::clog!(m, "{} ender push {} {} m (attacker {})", side_name(m, e), mvd.name.to_uppercase(), fmt_fixed_f32(mb, 1), fmt_fixed_f32(ma, 1));
    }
}

/// STRING-LATCH's command → the latch.
fn queued_cmd(q: Queued) -> &'static str {
    match q {
        Queued::Q => "q",
        Queued::F => "f",
        q => panic!("not a string link latch: {q}"),
    }
}

/// port: MOVE-COMMANDS: chains and cancels during move ID, in `*commands*` order (a refused one doesn't hide the next), then the Kikon
/// hold's let-go, the core latch, the latched string link once the chain opens. T when a new move / action started. Of `*commands*`
/// only :hoho :burst :sp :q are in its list: the :kikon (O ender, SKIP-AURA), :f, :sig (the L link latch), :sp1 / :sp2 clauses
/// can't be reached (FIGHTER-QUEUED never holds :sig).
pub fn move_commands(m: &mut Match, e: Entity, id: MoveId, sf: i64) -> bool {
    let mvd = mv(m, id);
    let (kit, name) = (kit_of(m, e), mvd.name.as_str());
    let landed = fighter(m, e).contact;
    for (cmd, button, md) in COMMANDS {
        if !matches!(cmd, Cmd::Hoho | Cmd::Burst | Cmd::Sp | Cmd::Q) || !vpad(m, e).command_pressed_p(button as usize, md) {
            continue;
        }
        let started = match cmd {
            Cmd::Sp => core_move_sp(m, e, id, sf, button), // AS off a landed attack, the next NS segment
            Cmd::Q => {
                let cls = fighter(m, e).cls;
                if cls == Some(Cls::Ns) {
                    core_sa_start(m, e, id, sf, button) // an attack in an NS gap: the SA
                } else if m.knobs.core_as_sa_out && cls == Some(Cls::As) && core_as_sa_press(m, e, id, button) {
                    true
                } else if string_link_p(m.data, kit, name) {
                    // the latch takes every J press (STRING-LATCH)
                    if kit_next(m.data, kit, name, "q").is_some() {
                        fighter_mut(m, e).queued = Some(Queued::Q);
                    }
                    vpad(m, e).consume(button as usize);
                    false
                } else if mvd.kind == "breaker" {
                    let f = fighter(m, e);
                    cancel_open_p(sf, f.land_sf, mv_total(mvd), landed == Some(Contact::Hit)) && try_command(m, e, cmd, Some(button))
                } else if mvd.params.r_cancel.as_ref().is_some_and(|c| c.iter().any(|x| x == "q")) {
                    // (:r-cancel-from is in no move of the data: its recovery, once it hit)
                    sf >= (mvd.s + mvd.a) as i64 && landed == Some(Contact::Hit) && try_command(m, e, cmd, Some(button))
                } else {
                    false
                }
            }
            Cmd::Burst => try_command(m, e, cmd, Some(button)), // ORANGE (BURST-OK-P: his hit landed)
            _ => cancel_into(m, e, id, sf, landed, cmd, button),
        };
        if started {
            vpad(m, e).consume(button as usize);
            return true;
        }
    }
    if core_hold_step(m, e) || core_latch_step(m, e, id, sf) {
        return true;
    }
    let f = fighter(m, e);
    let Some(q) = f.queued else { return false };
    let contact = landed.or(f.chained.then_some(Contact::Block)); // ((or landed chained): a T takes the block timing)
    if matches!(q, Queued::Ns | Queued::Sa | Queued::Sw | Queued::SwNs)
        || !chain_open_p(&m.knobs, sf, mvd.s as i64, mvd.a as i64, mvd.r as i64, contact)
    {
        return false;
    }
    let n = kit_next(m.data, kit, name, queued_cmd(q)).expect("a latched link");
    if let Some(h) = kit_hook_sym(m, e, "link-move") {
        crate::unported!(m, h, false) // (a kit's :link-move: Hisagi's gathered J, M4)
    }
    if let Some(h) = kit_hook_sym(m, e, "link-ok") {
        let ok = match ken_hook(h) {
            Some(crate::ken::Hook::LinkOk) => crate::ken::hooks::link_ok(m, e, n),
            _ => crate::unported!(m, h, false),
        };
        if !ok {
            fighter_mut(m, e).queued = None; // the kit refuses this link: it ends
            return false;
        }
    }
    let next = id_of(m, n);
    start_move(m, e, next, Some(if q == Queued::Q { Button::Quick } else { Button::Flash }));
    fighter_mut(m, e).chained = true;
    true
}

/// port: CANCEL-INTO: an on-hit cancel out of J / K link ID (SPs, Hoho, a :cancel L); Hoho also out of any NA / SA / NS move.
pub fn cancel_into(m: &mut Match, e: Entity, id: MoveId, sf: i64, landed: Option<Contact>, cmd: Cmd, button: Button) -> bool {
    let mvd = mv(m, id);
    let f = fighter(m, e);
    // ((not (eq cmd :sig)): :sig is not in *commands*)
    (kind_in(mvd, &["quick", "flash"]) || (cmd == Cmd::Hoho && matches!(f.cls, Some(Cls::Na | Cls::Sa | Cls::Ns))))
        && cancel_open_p(sf, f.land_sf, mv_total(mvd), landed == Some(Contact::Hit))
        && try_command(m, e, cmd, Some(button))
}

// ---------------------------------------------------------------- a combo's Hoho resumed

/// port: HOHO-RESUME!: resume the combo F's Hoho cancelled with CMD (:q J / :sp SP). T when a move started (or a later NS segment
/// refused at 0 ate the press).
pub fn hoho_resume(m: &mut Match, e: Entity, cmd: Cmd) -> bool {
    let f = fighter(m, e);
    let (from, cls, presses) = (mv(m, f.hoho_from.expect("a combo's Hoho")), f.hoho_cls, f.hoho_presses);
    let kit = kit_of(m, e);
    let next = if cls == Some(Cls::Ns) {
        if cmd == Cmd::Sp { mv_ns_next(m.data, kit, from) } else { mv_sa_move(m.data, kit, from).or_else(|| kit_sa_move(m.data, kit)) }
    } else if cmd == Cmd::Q {
        kit_next(m.data, kit, &from.name, "q")
    } else {
        None
    };
    let as_ = next.is_none() && cmd == Cmd::Sp && cls != Some(Cls::Ns);
    {
        let f = fighter_mut(m, e);
        (f.hoho_from, f.hoho_left, f.queued) = (None, 0, None);
    }
    if next.is_none() && !as_ {
        return false;
    }
    {
        let f = fighter_mut(m, e);
        (f.cls, f.presses) = (cls, presses);
    }
    let started = match next {
        Some(n) => {
            let n = id_of(m, n);
            core_start(m, e, n, Some(Button::Quick))
        }
        None => core_as_start(m, e),
    };
    if started {
        let f = fighter_mut(m, e);
        if matches!(f.cls, Some(Cls::Na | Cls::As)) {
            f.charge_mult = f.hoho_mult;
        }
        (f.hoho_hold, f.chained) = (true, true);
        let name = fighter(m, e).mv.map_or(String::new(), |id| mv(m, id).name.to_uppercase());
        crate::clog!(m, "{} HOHO -> {}", side_name(m, e), name);
        true
    } else if next.is_some() {
        fighter_mut(m, e).cls = None;
        true
    } else {
        false
    }
}

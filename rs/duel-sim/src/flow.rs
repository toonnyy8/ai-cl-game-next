//! port: duel/lisp/main.lisp (the frame, the fixed step, the systems' order), duel/lisp/flow.lisp (the match flow) and
//! ENGINE::RUN-FRAME's sim part. Menus, pause and the camera read devices or are looks: not here (M2 / M3).
use crate::cine::{self, After, CineName};
use crate::components::{Character, Flow, State};
use crate::cpu::Search;
use crate::ecs::Entity;
use crate::fighter::{fighter_system, spawn_fighter, to_idle};
use crate::math::deg;
use crate::state::{Match, Mode, Winner};
use crate::time::STEP;

/// Where the pilots' vpads get their input: `read` is the vpad reader (PILOT-SYSTEM after VPAD-BEGIN-STEP!, and PILOT-READ
/// without it), `step_end` is `*step-hook*`, `after_brain` the recorder's `*oracle-brain-hook*` (right after BRAIN-SYSTEM, on a
/// sim frame only).
pub trait PilotInput {
    fn read(&mut self, m: &mut Match, side: usize);
    fn step_end(&mut self, m: &mut Match, s: &mut Search);
    fn after_brain(&mut self, _m: &mut Match, _s: &mut Search) {}
    /// The vpad reader's call inside a CPU rollout (the stand-in brain's VPAD-BEGIN-STEP!, the rollout's PILOT-READ): a device writes
    /// its held state again and never advances (a human's keys are still down while the CPU searches). Required, so a device can't
    /// forget it (M3's touch deck and keys); an input with no device writes nothing (a CPU's vpad has no reader, the recorder's
    /// REC-READER skips rollouts).
    fn rollout_read(&mut self, m: &mut Match, side: usize);
}

/// The vpad readers as a rollout's lean steps see them: each read is the device's in-rollout call (`PilotInput::rollout_read`); no
/// step-end or brain hook runs inside a rollout.
pub struct InRollout<'a>(pub &'a mut dyn PilotInput);
impl PilotInput for InRollout<'_> {
    fn read(&mut self, m: &mut Match, side: usize) {
        self.0.rollout_read(m, side);
    }
    fn step_end(&mut self, _m: &mut Match, _s: &mut Search) {}
    fn rollout_read(&mut self, m: &mut Match, side: usize) {
        self.0.rollout_read(m, side);
    }
}

/// The headless platform's real seconds for frame K (tools/simgate/stubs.c pf_pump: virtual time, whole nanoseconds, so
/// ~0.016666666, a hair under +STEP+), clamped as RUN-FRAME clamps it.
pub fn raw_dt(k: i64) -> f32 {
    let ns = |f: i64| ((f as f64 * (50.0 / 3.0)) * 1e6) as u64;
    let raw = (ns(k) - ns(k - 1)) as f32 * 1e-9f32;
    #[allow(clippy::manual_clamp)] // (CL MIN / MAX, in their order)
    f32::min(0.1, f32::max(0.0, raw))
}

/// port: ENGINE::RUN-FRAME's sim part (the queued debug commands, then GAME-FRAME's FLOW-UPDATE, GATE-UPDATE and the fixed
/// steps). False once the sim has reached an `unported!` path, in the match (`m.unported` names it) or in a CPU rollout (`Search.cut`:
/// the CPU's value was wrong): no step runs past either (the rest of the frame's steps are skipped, and a frame called again does
/// nothing and returns false), so the game loop must stop and show the name instead of freezing or playing on silently (M1_NOTES §10).
/// The Lisp never stops (it has no unported path).
pub fn frame(m: &mut Match, s: &mut Search, input: &mut dyn PilotInput) -> bool {
    if m.unported.is_some() || s.cut.is_some() {
        return false;
    }
    m.frame_n += 1;
    let rdt = raw_dt(m.frame_n);
    while let Some(c) = m.cmds.pop_front() {
        crate::debug::debug_command(m, s, c);
    }
    // look: screen-fx-update, onehand-frame
    flow_update(m, rdt);
    crate::gate::gate_update(m, s);
    if sim_running_p(m) {
        advance_sim(m, s, rdt, input);
    } else {
        m.time.step_acc = 0.0;
        // look: the menus' idle clips
    }
    // look: slow-draw (it puts back what it moves), the fx clock, the camera
    if !m.turbo {
        cine::cine_draw(m); // (DRAW-SCENE's CINE-DRAW: a script's DURING forms, some writing sim state; the rest of the scene a look)
    }
    // (FQ-MATCH-END's Search half for a GO-RESULTS outside `sim_step`, e.g. M3's cinematic skip in FLOW-UPDATE; a no-op when empty)
    crate::cpu::fq::fq_match_end_apply(m, s);
    // look: the HUD
    m.unported.is_none() && s.cut.is_none()
}

/// port: FLOW-UPDATE. ponytail: the screens (menus, pause, a skip press) read the devices, none in the headless sim (M2).
pub fn flow_update(m: &mut Match, rdt: f32) {
    if !m.paused {
        m.ft += rdt;
    }
}

/// port: ADVANCE-SIM (RUN-FIXED-STEPS, or 120 steps in turbo).
pub fn advance_sim(m: &mut Match, s: &mut Search, rdt: f32, input: &mut dyn PilotInput) {
    if m.turbo {
        for _ in 0..120 {
            if sim_running_p(m) && m.unported.is_none() && s.cut.is_none() {
                sim_step(m, s, input);
            }
        }
        return;
    }
    m.time.step_acc += rdt;
    let mut n = 0;
    // (`m.unported`, `s.cut`: a step past an unported path, in the match or a CPU rollout, would run on a state the Lisp never had; the
    // replay stops there anyway)
    while m.time.step_acc >= STEP && n < 6 && sim_running_p(m) && m.unported.is_none() && s.cut.is_none() {
        m.time.step_acc -= STEP;
        n += 1;
        sim_step(m, s, input);
    }
    if m.time.step_acc >= STEP {
        m.time.step_acc = 0.0;
    }
}

/// A pilot input that reads nothing (the vpads keep what they hold): a rollout's (no device; the recorder's reader skips rollouts).
pub struct NoInput;
impl PilotInput for NoInput {
    fn read(&mut self, _m: &mut Match, _side: usize) {}
    fn step_end(&mut self, _m: &mut Match, _s: &mut Search) {}
    fn rollout_read(&mut self, _m: &mut Match, _side: usize) {}
}

/// port: SIM-STEP: the lean step, then (`look:` feedback-system) HASH-LOG's `*step-hook*` and MC-FULL-STEP.
pub fn sim_step(m: &mut Match, s: &mut Search, input: &mut dyn PilotInput) {
    sim_core(m, s, input);
    crate::cpu::fq::fq_match_end_apply(m, s); // (FQ-MATCH-END's Search half: GO-RESULTS ran in this step)
    // look: feedback-system
    // port: HASH-LOG — cup-acc-step is the gate's debug bookkeeping (never read by the sim); the 600-tick hash is a log-msg
    input.step_end(m, s);
    crate::cpu::mcts::mc_full_step(m, s, input);
}

/// port: sim-state.lisp SIM-STEP-LEAN — SIM-STEP for a rollout: the sim without the presentation (no slow-motion snapshot, no
/// feedback, no hash log, no full-sim step; TAKE-EVENTS drops the events: none in the port yet, M3).
pub fn sim_step_lean(m: &mut Match, s: &mut Search, input: &mut dyn PilotInput) {
    sim_core(m, s, input);
}

/// SIM-STEP's and SIM-STEP-LEAN's shared part: the tick, then the cinematic, a hitstop step, a slow-motion wait or the systems.
fn sim_core(m: &mut Match, s: &mut Search, input: &mut dyn PilotInput) {
    m.match_tick += 1;
    if m.cine.is_some() {
        pilot_read(m, input);
        cine::cine_step(m);
    } else if !m.time.step() {
        pilot_read(m, input);
    } else {
        m.slow_acc += m.time.slowmo_scale(false);
        if m.slow_acc >= 1.0 {
            m.slow_acc -= 1.0;
            // look: slow-snapshot
            pilot_system(m, input);
            sim_systems(m, s, input);
        } else {
            pilot_read(m, input);
        }
    }
    // debug: god-update, probe-update (*god* / *probe*: set only by commands M1 does not port)
}

/// port: SIM-SYSTEMS (INPUT's `after_brain`: the recorder's hook after BRAIN-SYSTEM).
pub fn sim_systems(m: &mut Match, s: &mut Search, input: &mut dyn PilotInput) {
    crate::cpu::brain_system(m, s, input);
    if m.unported.is_some() {
        return; // (a step past an unported path would run on a state the Lisp never had)
    }
    input.after_brain(m, s);
    fighter_system(m);
    if m.cine.is_none() {
        crate::hazards::hazard_system(m);
    }
    if m.cine.is_none() {
        crate::combat::hit_system(m);
    }
    if m.cine.is_none() {
        crate::gauges::gauge_system(m);
    }
    if m.cine.is_none() {
        match_system(m);
    }
    crate::core_sim::core_xch_step(m);
}

// ---------------------------------------------------------------- the replay's stubbed mode (docs/bevy/M1_NOTES.md §3)
// Not a port: `Match.stubs` (empty unless a tool sets it) lets a replay run past the forms' :tick hooks while the kit tasks have not
// ported them. Each stub does nothing only while the real hook provably writes nothing outside the fields the replay masks and logs
// nothing; else it is `unported!` with its name. Delete with those ports.

fn stubbed(m: &Match, name: &str) -> bool {
    m.stubs.iter().any(|s| s == name)
}

/// A form's :tick hook H (GAUGE-SYSTEM, every step) the run may skip: stubbed by its name and provably writing nothing unmasked and
/// logging nothing now. HS-TICK (M4): always skipped. It writes his HSS (masked `hss-`); its other writes (the K1 copy
/// swapped into FIGHTER-MOVE, the SICKLE / KIN off / ZANDEN log lines) each need a state only one of his own unported hooks sets first
/// (`hss-kstr`: HS-KAZA-TICK / HS-KAZA-START; `:out`: HS-THROW-OUT; `hss-kin`: HS-CLASH; `zan-pend`: HS-HIT), and the run stops at that
/// hook, so the skip is exact on every state it can reach. (A skipped move swap would not show as DIVERGED: B prints a move by name
/// only, and the copy has the same name. Whoever ports one of those hooks must replace this skip with a bail.) YAMA-TICK (M4): nothing
/// in the Shikai with the heat below the top (YA-FORM-NEXT is NIL; 爆炎 comes only through his hooks).
pub(crate) fn stub_tick(m: &Match, e: Entity, h: &str) -> bool {
    if !stubbed(m, h) {
        return false;
    }
    let f = m.fighter.get(e).unwrap();
    match h {
        "HS-TICK" => true,
        "YAMA-TICK" => {
            let max = crate::fighter::kit_of(m, e).meter.max.unwrap_or(0) as f32; // (*ya-heat-max* 100.0 = his Shikai meter's :max)
            f.form == crate::components::Form::Base && m.gauges.get(e).unwrap().meter < max
        }
        _ => false,
    }
}

fn side_of(m: &Match, e: Entity) -> usize {
    m.fighter.get(e).map_or(0, |f| f.side as usize)
}

/// port: PILOT-READ: a step without a sim frame reads the devices without advancing the vpad clock.
pub fn pilot_read(m: &mut Match, input: &mut dyn PilotInput) {
    m.do_entities(|m, e| m.pilot.has(e), |m, e| {
        let side = side_of(m, e);
        input.read(m, side);
    });
}

/// port: PILOT-SYSTEM: every brainless fighter's vpad starts the step, then reads.
pub fn pilot_system(m: &mut Match, input: &mut dyn PilotInput) {
    m.do_entities(|m, e| m.pilot.has(e) && m.fighter.has(e), |m, e| {
        if !m.fighter.get(e).unwrap().has_brain() {
            m.pilot.get_mut(e).unwrap().vpad.begin_step();
            let side = side_of(m, e);
            input.read(m, side);
        }
    });
}

pub fn battle_p(m: &Match) -> bool {
    matches!(m.flow, Flow::Intro | Flow::Battle | Flow::Finish)
}

pub fn sim_running_p(m: &Match) -> bool {
    battle_p(m) && !m.paused
}

/// port: SET-FLOW (the menu cursor and the log line are the menus').
pub fn set_flow(m: &mut Match, st: Flow) {
    m.flow = st;
    m.ft = 0.0;
}

/// port: SPAWN-PAIR: a fresh plaza with the picks reset-distance apart, facing.
pub fn spawn_pair(m: &mut Match, cpu1: bool, cpu2: bool) {
    m.clear_entities();
    // look: take-events, fx-clear, stage-clear-cracks
    m.time.reset();
    let [c1, c2]: [Character; 2] = m.picks;
    let h = m.knobs.reset_distance / 2.0;
    let p1 = spawn_fighter(m, 0, c1, -h, 0.0, deg(-90.0), cpu1);
    let p2 = spawn_fighter(m, 1, c2, h, 0.0, deg(90.0), cpu2);
    m.fighter.get_mut(p1).unwrap().opp = p2;
    m.fighter.get_mut(p2).unwrap().opp = p1;
    (m.p1, m.p2) = (p1, p2);
    cine::face_each_other(m, p1, p2, None);
}

/// port: GO-TITLE (START-GAME's last step: the title's pair).
pub fn go_title(m: &mut Match) {
    m.paused = false;
    cine::abort_cine(m);
    spawn_pair(m, false, false);
    for e in [m.p1, m.p2] {
        m.fighter.get_mut(e).unwrap().state = State::Intro;
    }
    // look: the title music
    set_flow(m, Flow::Title);
}

/// port: START-MATCH (S: MC-FULL-RESET's jobs, stats and picks; then its snapshot slots made, outside the battle).
pub fn start_match(m: &mut Match, s: &mut Search) {
    // (a GO-RESULTS whose FQ-MATCH-END Search half is still queued: applied before FQ-ATTACH! hands this match its copy; Lisp does
    // both halves at once, so nothing can start a match between them)
    crate::cpu::fq::fq_match_end_apply(m, s);
    m.paused = false;
    m.winner = None;
    m.match_tick = 0;
    m.timer = 60 * m.knobs.match_seconds;
    m.pending.clear(); // (*kikons* is not cleared by the Lisp: TAKE-BROKEN-SOULS empties it every HIT-SYSTEM, so it is empty here)
    m.soul_breaks.clear();
    m.slow_acc = 0.0;
    crate::cpu::mcts::mc_full_reset(m, s); // (*mc-next* is not reset)
    cine::abort_cine(m);
    // look: clear-words
    m.rng.seed(m.match_seed);
    // port: SET-CAM-BEHIND *cam-behind* (the CAMERA setting: BEHIND, the default; `*one-hand*` NIL headless): humans steer by the
    // behind view in VS CPU / PRACTICE (*cam-cut* is the camera's, a look)
    m.view_behind = matches!(m.mode, Mode::VsCpu | Mode::Practice);
    spawn_pair(m, m.mode == Mode::CpuCpu, m.mode != Mode::VsPlayer);
    crate::cpu::start_match_cpu(m, s);
    for e in [m.p1, m.p2] {
        // (*konpaku-start*: *konpaku-max* unless debug 2101, not ported)
        m.gauges.get_mut(e).unwrap().konpaku = m.knobs.konpaku_max;
        m.fighter.get_mut(e).unwrap().state = State::Intro;
    }
    if m.mode == Mode::Practice {
        crate::unported!(m, "practice")
    }
    // look: music; log-msg: the match seed line, debug-knobs-line
    set_flow(m, Flow::Intro);
    let (p1, p2) = (m.p1, m.p2);
    cine::start_cine(m, CineName::Intro, p1, p2, Some(After::BeginBattle));
    s.warm(m); // (not Lisp's: the slots a battle step's snapshot writes, made here so a step allocates nothing)
}

/// port: BEGIN-BATTLE.
pub fn begin_battle(m: &mut Match) {
    for e in [m.p1, m.p2] {
        // look: refresh-look
        to_idle(m, e);
    }
    m.match_tick = 0;
    let (p1, p2) = (m.p1, m.p2);
    crate::fighter::view_step(m, p1, p2, true);
    // look: duel-camera
    set_flow(m, Flow::Battle);
}

/// port: MATCH-OVER: WINNER the fighter who won, None a draw.
pub fn match_over(m: &mut Match, winner: Option<Entity>) {
    if m.mode == Mode::Practice {
        crate::unported!(m, "practice match-over")
    }
    let w = match winner {
        None => Winner::Draw,
        Some(e) if e == m.p1 => Winner::Side(0),
        Some(_) => Winner::Side(1),
    };
    let (we, le) = if w == Winner::Side(1) { (m.p2, m.p1) } else { (m.p1, m.p2) };
    m.winner = Some(w);
    set_flow(m, Flow::Finish);
    cine::start_cine(m, CineName::Ko, we, le, Some(After::GoResults));
}

/// port: TIME-UP.
pub fn time_up(m: &mut Match) {
    if [m.p1, m.p2].iter().any(|&e| m.fighter.get(e).is_some_and(|f| f.character == Some(Character::Hisagi))) {
        crate::unported!(m, "bind-resolve!") // (Hisagi's bind: M4)
    }
    let (g1, g2) = (m.gauges.get(m.p1).unwrap(), m.gauges.get(m.p2).unwrap());
    let w = match crate::rules::time_up_winner(g1.konpaku, g1.reishi, g1.reishi_max, g2.konpaku, g2.reishi, g2.reishi_max) {
        Some(k) => Winner::Side(k),
        None => Winner::Draw,
    };
    m.winner = Some(w);
    set_flow(m, Flow::Finish);
    let (a, v) = if w == Winner::Side(1) { (m.p2, m.p1) } else { (m.p1, m.p2) };
    cine::start_cine(m, CineName::Time, a, v, Some(After::GoResults));
}

/// port: GO-RESULTS (a rollout's K.O. stops at :finish: no results, no learner).
pub fn go_results(m: &mut Match) {
    if m.in_rollout {
        return;
    }
    crate::cpu::fq::fq_match_end_take(m); // (FQ-MATCH-END: its Search half at this step's end, `sim_step`)
    // log-msg: the RESULTS line (`duel-tools cvc` prints it), MC-FULL-LOG and STRAT-LOG (cost lines with milliseconds, never compared:
    // not ported, `Search.mc_stats` / `strat_stats` hold their counts)
    set_flow(m, Flow::Results);
    for e in [m.p1, m.p2] {
        let f = m.fighter.get_mut(e).unwrap();
        let won = m.winner == Some(Winner::Side(f.side));
        f.state = if won { State::Win } else { State::Lose };
        // look: refresh-look, the win / lose clip
    }
    let (p1, p2) = (m.p1, m.p2);
    cine::face_each_other(m, p1, p2, None);
    // look: music
}

/// port: MATCH-SYSTEM.
pub fn match_system(m: &mut Match) {
    if m.flow == Flow::Battle {
        if m.mode == Mode::Practice {
            crate::unported!(m, "practice-step")
        }
        m.timer -= 1;
        if m.timer <= 0 {
            time_up(m);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    struct Null;
    impl PilotInput for Null {
        fn read(&mut self, _m: &mut Match, _side: usize) {}
        fn step_end(&mut self, _m: &mut Match, _s: &mut Search) {}
        fn rollout_read(&mut self, _m: &mut Match, _side: usize) {}
    }

    #[test]
    fn raw_dt_is_under_a_step() {
        assert!(raw_dt(1) < STEP);
        assert_eq!(raw_dt(1), 16_666_666u64 as f32 * 1e-9f32);
        assert_eq!(raw_dt(3), 16_666_667u64 as f32 * 1e-9f32);
    }

    /// cvc-ki-s1's start (START-CVC) and its 300 intro steps: the battle begins at tick 0, both IDLE; step 301 runs
    /// every system, ICHIGO-TICK attaching his ICS (the pacing log on: START-CVC's).
    #[test]
    fn intro_runs_300_steps_into_the_battle() {
        let mut m = crate::hashline::tests::new_match();
        go_title(&mut m);
        crate::gate::start_cvc(&mut m, &mut Search::new(), 1, Some([Character::Kenpachi, Character::Ichigo]));
        assert_eq!((m.flow, m.cine.as_ref().map(|c| c.cf)), (Flow::Intro, Some(0)));
        assert_eq!(m.p1.0, 256); // generation 1: the title's pair was cleared
        for e in [m.p1, m.p2] {
            m.fighter.get_mut(e).unwrap().brain = None; // (the replay's detach)
        }
        let s = &mut Search::new();
        for _ in 0..300 {
            sim_step(&mut m, s, &mut Null);
        }
        assert_eq!((m.match_tick, m.flow, m.cine.is_none()), (0, Flow::Battle, true));
        assert!([m.p1, m.p2].iter().all(|&e| m.fighter.get(e).unwrap().state == State::Idle));
        assert_eq!(m.unported, None);
        sim_step(&mut m, s, &mut Null);
        assert_eq!((m.match_tick, m.unported, m.pacing_log), (1, None, true));
        assert!(m.ics.has(m.p2) && !m.ics.has(m.p1));
    }
}

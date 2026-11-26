//! Port of tests/duel-rules/sim.lisp's checks that need only the neutral fighter (Task 7; the rest: PORTED.md), same values.
use duel_data::Data;
use duel_sim::components::{Button, Character, Contact, MoveId, Phase, State};
use duel_sim::ecs::Entity;
use duel_sim::fighter::*;
use duel_sim::state::Match;
use std::sync::OnceLock;

fn data() -> &'static Data {
    static D: OnceLock<Data> = OnceLock::new();
    D.get_or_init(Data::embedded)
}

/// sim.lisp T-PAIR: P1 in KA's :base kit, P2 in KB's, facing each other (CPU seats: no camera-relative stick).
fn t_pair(ka: Character, kb: Character) -> (Match, Entity, Entity) {
    let mut m = Match::new(data());
    m.picks = [ka, kb];
    duel_sim::flow::spawn_pair(&mut m, true, true);
    let (a, b) = (m.p1, m.p2);
    (m, a, b)
}

fn move_id(m: &Match, name: &str) -> MoveId {
    MoveId(m.data.moves.iter().position(|x| x.name == name).unwrap() as u16)
}

/// sim.lisp 33: *RUN-COMMANDS-P* is *RUN-COMMANDS* with :awaken in front.
#[test]
fn run_commands_p() {
    assert!(RUN_COMMANDS_P.contains(&Cmd::Awaken) && !RUN_COMMANDS.contains(&Cmd::Awaken) && RUN_COMMANDS_P[1..] == RUN_COMMANDS);
}

/// sim.lisp 49, 136: awakened, a kit without :p: P (TRY-COMMAND :awaken) does nothing.
#[test]
fn awaken_command_without_p() {
    let (mut m, a, b) = t_pair(Character::Ichigo, Character::Kenpachi);
    m.gauges.get_mut(a).unwrap().awakened = true;
    assert!(!try_command(&mut m, a, Cmd::Awaken, None)); // 49
    m.gauges.get_mut(b).unwrap().awakened = true;
    m.gauges.get_mut(a).unwrap().awaken = 0.0;
    assert!(!try_command(&mut m, a, Cmd::Awaken, None)); // 136
    assert_eq!(m.unported, None);
}

/// sim.lisp 176, 178, 180: the Kikon lock holds while the rusher's follow-up is coming.
#[test]
fn kikon_lock_holds() {
    let (mut m, a, b) = t_pair(Character::Ichigo, Character::Kenpachi);
    let kikon = move_id(&m, "ic-kikon");
    let fa = m.fighter.get_mut(a).unwrap();
    (fa.state, fa.mv, fa.follow, fa.phase) = (State::Move, Some(kikon), true, Some(Phase::Follow));
    assert!(kikon_lock_holds_p(&m, m.fighter.get(b).unwrap())); // 176
    let fa = m.fighter.get_mut(a).unwrap();
    (fa.phase, fa.sf, fa.contact) = (Some(Phase::Main), 0, Some(Contact::Hit));
    assert!(!kikon_lock_holds_p(&m, m.fighter.get(b).unwrap())); // 178 (the strike connected)
    let fa = m.fighter.get_mut(a).unwrap();
    (fa.contact, fa.follow) = (None, false);
    assert!(!kikon_lock_holds_p(&m, m.fighter.get(b).unwrap())); // 180 (not a follow-up)
}

/// sim.lisp 222-224, 226: an open exchange bars the Hoho for both; a press reaching TRY-COMMAND is refused and eaten. (The
/// exchange is set directly here: sim.lisp opens it with CORE-NOHIT!'s cancel, whose check 221 waits for Task 10.)
#[test]
fn hoho_refused_in_an_exchange() {
    let (mut m, a, b) = t_pair(Character::Kenpachi, Character::Ichigo);
    let fs_max = m.knobs.fs_max;
    for e in [a, b] {
        let f = m.fighter.get_mut(e).unwrap();
        (f.state, f.xch) = (State::Move, 40);
        m.gauges.get_mut(e).unwrap().fs = fs_max;
    }
    assert!(!(hoho_ready_p(&m, a) || hoho_ready_p(&m, b))); // 222
    let step = Button::Step as usize;
    for e in [a, b] {
        let vp = &mut m.pilot.get_mut(e).unwrap().vpad;
        vp.begin_step();
        vp.set(step, true);
    }
    assert!(!try_command(&mut m, b, Cmd::Hoho, Some(Button::Step)));
    assert!(m.fighter.get(b).unwrap().state == State::Move && !m.pilot.get(b).unwrap().vpad.pressed(step, None)); // 223 (eaten)
    assert!(!try_command(&mut m, a, Cmd::Hoho, Some(Button::Step)) && m.fighter.get(a).unwrap().state == State::Move); // 224
    for e in [a, b] {
        m.fighter.get_mut(e).unwrap().xch = -1; // (the exchange over: CORE-XCH-STEP)
    }
    assert!(hoho_ready_p(&m, a) && hoho_ready_p(&m, b)); // 226
}

/// sim.lisp 276, 293, 295, 297: ACT-START of a state that is no move: idle -1, a guard's / Hoho's STATE-T, a reaction -1.
#[test]
fn act_start_of_states() {
    let (mut m, a, _) = t_pair(Character::Kenpachi, Character::Hisagi);
    let f = m.fighter.get_mut(a).unwrap();
    (f.state, f.mv, f.xch) = (State::Idle, None, -1);
    assert_eq!(act_start(f), -1); // 276
    (f.state, f.state_t, f.guard_t) = (State::Guard, 120, 3);
    m.match_tick = 160;
    let f = m.fighter.get_mut(a).unwrap();
    assert_eq!(act_start(f), 120); // 293
    f.state = State::Hoho;
    assert_eq!(act_start(f), 120); // 295
    f.state = State::Stun;
    assert_eq!(act_start(f), -1); // 297
}

/// sim.lisp 28: no kit but Hisagi's Bankai forms holds a bind hook or :p (every reader then does what the old code did).
#[test]
fn no_bind_hooks_outside_hisagi_bankai() {
    const BIND_HOOKS: [&str; 8] = ["bind", "bind-damage", "bind-heal", "bind-step", "bind-resolve", "bind-snapshot", "p", "p-label"];
    for (c, forms) in &data().kits.kits {
        for (f, k) in forms {
            let exempt = c == "hisagi" && (f == "bankai" || f == "bankai-bind");
            assert!(exempt || !BIND_HOOKS.iter().any(|h| k.hooks.contains_key(*h)), "{c} {f}");
        }
    }
}

/// sim.lisp 110, 114, 116: SPEND-FS (the regen's wait restarts) and REFUND-FS (exactly what was paid, capped, also in a burst,
/// no SUBLIMATION factor, the wait untouched). (Lines 101-108's PAY-GAUGES set fs 165 there: Task 9; set directly here.)
#[test]
fn spend_and_refund_fs() {
    let (mut m, a, _) = t_pair(Character::Ichigo, Character::Kenpachi);
    m.gauges.get_mut(a).unwrap().fs = 165.0;
    spend_fs(&mut m, a, 30.0);
    let g = m.gauges.get(a).unwrap();
    assert!(g.fs == 135.0 && g.fs_idle == 0); // 110
    let sub_max = m.knobs.sub_max;
    let g = m.gauges.get_mut(a).unwrap();
    (g.fs_idle, g.burst, g.sub) = (17, Some(duel_sim::components::Burst::Orange), sub_max);
    refund_fs(&mut m, a, 40.0);
    let g = m.gauges.get(a).unwrap();
    assert!(g.fs == 175.0 && g.fs_idle == 17); // 114
    refund_fs(&mut m, a, 200.0);
    assert_eq!(m.gauges.get(a).unwrap().fs, m.knobs.fs_max); // 116
}

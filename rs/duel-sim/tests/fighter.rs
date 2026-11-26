//! Port of tests/duel-rules/sim.lisp's checks that need only the neutral fighter (Task 7; the rest: PORTED.md), same values.
use duel_data::Data;
use duel_sim::components::{Button, Character, Contact, MoveId, Phase, State};
use duel_sim::ecs::Entity;
use duel_sim::fighter::*;
use duel_sim::gauges::{bind_grey_frac, bind_grey_souls, bind_of, bind_resolve, bind_snapshot_of, bind_step, heal, pay_gauges};
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

/// sim.lisp 37, 40, 41, 51: no binder (no kit holds a :bind hook); HEAL! caps at max; no snapshot, no grey; the bind's fixed points
/// call nothing unbound (Task 9).
#[test]
fn heal_and_no_bind() {
    let (mut m, a, b) = t_pair(Character::Ichigo, Character::Kenpachi);
    assert!(bind_of(&m, a).is_none() && bind_of(&m, b).is_none()); // 37
    m.gauges.get_mut(a).unwrap().reishi = 1200;
    heal(&mut m, a, 500);
    let g = m.gauges.get(a).unwrap();
    assert_eq!(g.reishi, g.reishi_max); // 40
    assert!(bind_snapshot_of(&mut m, a).is_none() && bind_grey_frac(&mut m, a) == 0.0 && bind_grey_souls(&mut m, a) == 0); // 41
    bind_step(&mut m, a, "hits");
    bind_step(&mut m, a, "release");
    bind_resolve(&mut m, a);
    assert!(bind_of(&m, a).is_none() && m.unported.is_none()); // 51
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
    // the branch it skips: a form with a :p hook (sim.lisp's test binder; Hisagi's bind throw, M4) is not ported yet
    let mut d = Data::embedded();
    d.kits.kits.get_mut("ichigo").unwrap().get_mut("base").unwrap().hooks.insert("p".into(), "HS-TEST-P".into());
    let mut m = Match::new(Box::leak(Box::new(d)));
    m.picks = [Character::Ichigo, Character::Kenpachi];
    duel_sim::flow::spawn_pair(&mut m, true, true);
    let a = m.p1;
    assert!(!try_command(&mut m, a, Cmd::Awaken, None));
    assert_eq!(m.unported, Some("HS-TEST-P"));
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

/// sim.lisp 101, 105, 108, 110, 114, 116: PAY-GAUGES (nothing in a burst), SPEND-FS (the regen's wait restarts) and REFUND-FS
/// (exactly what was paid, capped, also in a burst, no SUBLIMATION factor, the wait untouched).
#[test]
fn spend_and_refund_fs() {
    let (mut m, a, _) = t_pair(Character::Ichigo, Character::Kenpachi);
    m.gauges.get_mut(a).unwrap().fs = 50.0;
    pay_gauges(&mut m, a, 10.0);
    assert_eq!(m.gauges.get(a).unwrap().fs, 60.0); // 101
    m.gauges.get_mut(a).unwrap().burst = Some(duel_sim::components::Burst::White);
    let refund = m.knobs.kikon_fs_refund;
    pay_gauges(&mut m, a, refund);
    pay_gauges(&mut m, a, 50.0);
    assert_eq!(m.gauges.get(a).unwrap().fs, 60.0); // 105
    m.gauges.get_mut(a).unwrap().burst = None;
    pay_gauges(&mut m, a, refund);
    assert_eq!(m.gauges.get(a).unwrap().fs, 165.0); // 108
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

fn kit_id(m: &Match, character: &str, form: &str, name: &str) -> MoveId {
    MoveId(m.data.moves.iter().position(|x| x.id == format!("{character}/{form}/{name}")).unwrap() as u16)
}

/// sim.lisp 182, 184, 186: in the Kikon's reel, lock 1 (not red): an attack cancels the follow-up (CORE-KIKON-CANCEL!: both bounce
/// to neutral); lock 2 (red): nothing does; no attack: he reels on. (sim.lisp stubs CORE-KIKON-CANCEL!; here it runs, its log line
/// and the bounce are the "cancelled".)
#[test]
fn kikon_reel_cancel() {
    let (mut m, a, b) = t_pair(Character::Ichigo, Character::Kenpachi);
    m.log_on = true;
    let kikon = kit_id(&m, "ichigo", "base", "ic-kikon");
    let quick = Button::Quick as usize;
    let reel = |m: &mut Match, lock: i64, press: bool| {
        let fa = m.fighter.get_mut(a).unwrap();
        (fa.state, fa.mv, fa.follow, fa.phase) = (State::Move, Some(kikon), true, Some(Phase::Follow));
        let fb = m.fighter.get_mut(b).unwrap();
        (fb.state, fb.stun, fb.sf, fb.kikon_lock) = (State::Stun, 40, 0, lock);
        let vp = &mut m.pilot.get_mut(b).unwrap().vpad;
        vp.begin_step();
        if press {
            vp.stamp(quick, false);
        } else {
            vp.consume(quick);
        }
        m.log.clear();
        stun_step(m, b);
        m.log.iter().any(|l| l.contains("P2 cancels the Kikon follow-up"))
    };
    assert!(reel(&mut m, 1, true) && m.fighter.get(b).unwrap().state == State::Idle && m.fighter.get(a).unwrap().state == State::Idle); // 182
    let fb = |m: &Match| (m.fighter.get(b).unwrap().state, m.fighter.get(b).unwrap().sf);
    assert!(!reel(&mut m, 2, true) && fb(&m) == (State::Stun, 1)); // 184 (red: nothing does)
    assert!(!reel(&mut m, 1, false) && fb(&m) == (State::Stun, 1)); // 186 (no attack: he reels on)
    assert_eq!(m.unported, None);
}

/// sim.lisp 210-212, 221, 230, 234: CORE-NOHIT!'s :cancel counts as landed for both (the defender only inside his classed window);
/// it opens the exchange on both; a same-class tie bounces both after landing. (sim.lisp stubs CORE-CLASH! / CORE-BOUNCE!; here they
/// run: Hisagi's :clash hook is M4, so `unported` is set and ignored; the bounce shows as both idle.)
#[test]
fn cancel_lands_for_both() {
    use duel_sim::components::{Cls, Form, KitId};
    use duel_sim::core::Verdict;
    use duel_sim::core_sim::{core_nohit, Pending};
    let (mut m, a, b) = t_pair(Character::Kenpachi, Character::Hisagi);
    m.fighter.get_mut(b).unwrap().kit = Some(KitId { character: Character::Hisagi, form: Form::Bankai });
    let (ns, j1, kj1) = (kit_id(&m, "kenpachi", "base", "ke-z-n1a"), kit_id(&m, "hisagi", "bankai", "hs-r-j1"), kit_id(&m, "kenpachi", "base", "ke-z-j1"));
    assert_eq!(duel_sim::kit::kit_core_move(m.data, kit_of(&m, a), duel_sim::kit::Role::Ns, 1).unwrap().name, "ke-z-n1a");
    let first = |m: &Match, id: MoveId| duel_sim::kit::mv_first_hit(mv(m, id));
    let put = |m: &mut Match, e, id, cls, sf| {
        let f = m.fighter.get_mut(e).unwrap();
        (f.state, f.phase, f.mv, f.cls, f.sf, f.contact, f.land_sf) = (State::Move, Some(Phase::Main), Some(id), Some(cls), sf, None, -1);
    };
    let cancel = |m: &mut Match| {
        let mvid = m.fighter.get(a).unwrap().mv;
        core_nohit(m, &Pending { att: a, def: b, mv: mvid, hazard: None, state: None }, Verdict::Cancel);
    };
    let (fns, fj1) = (first(&m, ns), first(&m, j1));
    put(&mut m, a, ns, Cls::Ns, fns);
    put(&mut m, b, j1, Cls::Na, 5);
    cancel(&mut m);
    let (fa, fb) = (m.fighter.get(a).unwrap().clone(), m.fighter.get(b).unwrap().clone());
    assert!(fa.contact == Some(Contact::Hit) && fa.land_sf == fns); // 210
    assert!(fb.contact == Some(Contact::Hit) && fb.land_sf == fj1 && fj1 > 5); // 211
    assert!(fa.state == State::Move && fb.state == State::Move); // 212 (cross-class: no bounce)
    assert!(fa.xch >= 0 && fa.xch == fb.xch); // 221 (222-226: hoho_refused_in_an_exchange)
    let sa = { let mvd = mv(&m, j1); (mvd.s + mvd.a) as i64 };
    put(&mut m, a, ns, Cls::Ns, fns);
    put(&mut m, b, j1, Cls::Na, sa); // (he is in his recovery: no cancel for him)
    cancel(&mut m);
    let (fa, fb) = (m.fighter.get(a).unwrap().clone(), m.fighter.get(b).unwrap().clone());
    assert!(fa.contact == Some(Contact::Hit) && fb.contact.is_none() && fb.land_sf == -1); // 230
    m.fighter.get_mut(b).unwrap().kit = Some(KitId { character: Character::Kenpachi, form: Form::Base });
    let fk = first(&m, kj1);
    put(&mut m, a, kj1, Cls::Na, fk);
    put(&mut m, b, kj1, Cls::Na, fk);
    cancel(&mut m);
    let (fa, fb) = (m.fighter.get(a).unwrap().clone(), m.fighter.get(b).unwrap().clone());
    assert!(fa.contact == Some(Contact::Hit) && fb.contact == Some(Contact::Hit) && fa.state == State::Idle && fb.state == State::Idle); // 234
}

/// sim.lisp 255-259: START-MOVE of an AS out of a J1 that took part in a cancel starts *CORE-XCH-AS-DELAY* (6) frames early, its start
/// tick the press's, its first-frame hook not run yet (here: a first-frame hook ran = `unported` names it, Task 11); after a real hit
/// since the cancel, without one, or for a J link, as before.
#[test]
fn pre_roll_out_of_a_cancel() {
    use duel_sim::components::{Cls, Form, KitId};
    let (mut m, a, _) = t_pair(Character::Kenpachi, Character::Hisagi);
    m.fighter.get_mut(a).unwrap().kit = Some(KitId { character: Character::Kenpachi, form: Form::Bankai });
    m.match_tick = 50;
    let kit = kit_of(&m, a);
    let j1 = duel_sim::kit::kit_command_move(m.data, kit, "q").unwrap();
    let as1 = duel_sim::kit::kit_core_move(m.data, kit, duel_sim::kit::Role::As, 1).unwrap();
    let link = duel_sim::kit::kit_next(m.data, kit, &j1.name, "q").unwrap();
    let (j1, as1, link) = (id_of(&m, j1), id_of(&m, as1), id_of(&m, link));
    let enter = mv(&m, as1).enter as i64;
    assert!(mv(&m, as1).on_frame.iter().any(|x| x[0].as_f32() == Some(enter as f32))); // 255 (KE-KR-AS1 has a first-frame hook)
    let from_j1 = |m: &mut Match, xch: i64, done: bool, id: MoveId| {
        let f = m.fighter.get_mut(a).unwrap();
        (f.state, f.phase, f.mv, f.cls, f.cls_t, f.contact, f.xch, f.xch_done) =
            (State::Move, Some(Phase::Main), Some(j1), Some(Cls::Na), 30, Some(Contact::Hit), xch, done);
        m.unported = None;
        start_move(m, a, id, Some(Button::Quick));
        let f = m.fighter.get(a).unwrap();
        (f.sf, f.pre, f.cls_t, m.unported.is_some())
    };
    assert_eq!(from_j1(&mut m, 40, false, as1), (enter - 6, 6, 50, false)); // 256 (out of the cancel: 6 more, hook later)
    assert_eq!(from_j1(&mut m, 40, true, as1), (enter, 0, 50, true)); // 257 (a real hit since: as before)
    assert_eq!(from_j1(&mut m, -1, false, as1), (enter, 0, 50, true)); // 258 (no cancel: a normal combo)
    assert_eq!(from_j1(&mut m, 40, false, link).1, 0); // 259 (the J link out of the cancel: no wait)
}

/// sim.lisp 279, 285-287, 291: ACT-START of a started move is its start tick, kept through hitstop / slow motion / a hold reset; an AS
/// out of the cancel starts on its press tick despite its pre-roll.
#[test]
fn act_start_of_moves() {
    use duel_sim::components::{Form, KitId};
    let (mut m, a, _) = t_pair(Character::Kenpachi, Character::Hisagi);
    m.fighter.get_mut(a).unwrap().kit = Some(KitId { character: Character::Kenpachi, form: Form::Bankai });
    m.match_tick = 50;
    let kit = kit_of(&m, a);
    let (j1, as1) = (duel_sim::kit::kit_command_move(m.data, kit, "q").unwrap(), duel_sim::kit::kit_core_move(m.data, kit, duel_sim::kit::Role::As, 1).unwrap());
    let (j1, as1) = (id_of(&m, j1), id_of(&m, as1));
    let f = m.fighter.get_mut(a).unwrap();
    (f.state, f.mv, f.xch) = (State::Idle, None, -1);
    start_move(&mut m, a, j1, Some(Button::Quick));
    assert_eq!(act_start(m.fighter.get(a).unwrap()), 50); // 279
    m.fighter.get_mut(a).unwrap().sf += 3;
    m.match_tick += 3 + 12; // (3 plain frames, the cancel's hitstop: ticks, no frame)
    let f = m.fighter.get_mut(a).unwrap();
    (f.xch, f.contact) = (65, Some(Contact::Hit));
    for _ in 0..5 {
        m.fighter.get_mut(a).unwrap().sf += 1;
        m.match_tick += 5;
    }
    m.fighter.get_mut(a).unwrap().hold = 0;
    let f = m.fighter.get(a).unwrap();
    assert_eq!(act_start(f), 50); // 285
    assert_ne!(m.match_tick - f.sf - f.hold, 50); // 286 (the old read: drifted)
    assert!(65 > act_start(f)); // 287
    let press = m.match_tick;
    start_move(&mut m, a, as1, Some(Button::Quick));
    let f = m.fighter.get(a).unwrap();
    assert!(f.pre == 6 && act_start(f) == press && act_start(f) > 65); // 291
}

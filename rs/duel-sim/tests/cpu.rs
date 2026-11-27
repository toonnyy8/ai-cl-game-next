//! M2's CPU checks: perception and presses (Task 3; cpu-perceive.lisp), the brain branches of the sim (M1_NOTES §7).
use duel_data::Data;
use duel_sim::components::{Character, Difficulty, Flow, MoveId, Phase, State, Sym};
use duel_sim::cpu::perceive::*;
use duel_sim::cpu::{Brain, Search};
use duel_sim::ecs::Entity;
use duel_sim::flow::PilotInput;
use duel_sim::state::Match;
use std::sync::OnceLock;

fn data() -> &'static Data {
    static D: OnceLock<Data> = OnceLock::new();
    D.get_or_init(Data::embedded)
}

fn move_id(m: &Match, name: &str) -> MoveId {
    MoveId(m.data.moves.iter().position(|x| x.name == name).unwrap() as u16)
}

/// cvc-ki-s1's start (debug 2001 01 03: START-CVC seed 1, Kenpachi vs Ichigo) run to its first battle step.
fn ki_battle() -> Match {
    let mut m = Match::new(data());
    duel_sim::flow::go_title(&mut m);
    duel_sim::gate::start_cvc(&mut m, 1, Some([Character::Kenpachi, Character::Ichigo]));
    m
}

/// A hand-made SNAP whose SF is K (the step it was taken).
fn snap_at(k: i64) -> Snap {
    Snap { sf: k, ..Snap::default() }
}

/// BRAIN-PERCEIVE's ring: a ring of 3 and a delay of 2 see the opponent 2 steps late; the first step (fresh) fills every slot with
/// that step's view, so the first DELAY steps see the round's start. BRAIN-SNAP-AGO reads after the head moved on.
#[test]
fn snap_ring_sees_delay_steps_late() {
    let mut ring: [Option<Snap>; 3] = [None; 3];
    let (mut head, mut fresh) = (0i64, true);
    let mut seen = vec![];
    for k in 1..=6 {
        let s = perceive_ring(&mut ring, &mut head, &mut fresh, 2, |_| snap_at(k));
        seen.push(s.sf);
    }
    assert_eq!(seen, [1, 1, 1, 2, 3, 4]);
    assert!(!fresh);
    assert_eq!(head, 0); // (6 steps around a ring of 3)
    assert_eq!(snap_ago(&ring, head, 0).map(|s| s.sf), Some(6));
    assert_eq!(snap_ago(&ring, head, 2).map(|s| s.sf), Some(4));
}

/// SNAP-TAKE!'s two branches: a move fills its frame data; out of a move a reused slot keeps its S and ACTIVE-END (the Lisp sets
/// neither there) while KIND / PHASE / FLAGS / CONTACT / MOVE go NIL and REACH 0.
#[test]
fn snap_take_keeps_s_on_a_reused_slot() {
    let mut m = ki_battle();
    let o = m.p2;
    let id = move_id(&m, "ic-j1");
    let mvd = &m.data.moves[id.0 as usize];
    let (ms, ma) = (mvd.s as i64, mvd.a as i64);
    {
        let f = m.fighter.get_mut(o).unwrap();
        (f.state, f.mv, f.phase, f.sf) = (State::Move, Some(id), Some(Phase::Main), 2);
    }
    let s = snap_take(&m, Snap::default(), o);
    assert_eq!((s.state, s.mv, s.s, s.active_end, s.sf), (State::Move, Some(id), ms, ms + ma, 2));
    assert_eq!(s.kind(m.data), Some("quick"));
    assert!(s.left > 0 && s.left < 99);
    let f = m.fighter.get_mut(o).unwrap();
    (f.state, f.mv, f.phase, f.stun, f.sf) = (State::Stun, None, None, 20, 5);
    let s2 = snap_take(&m, s, o);
    assert_eq!((s2.s, s2.active_end, s2.left, s2.mv, s2.reach, s2.phase), (ms, ms + ma, 15, None, 0.0, None));
    assert_eq!(snap_take(&m, Snap::default(), o).s, 0);
}

/// AI-PRESS / AI-PRESS-WRITE!: the button down while PRESS-LEFT lasts (CORE-BRAIN-STEP counts it down before the write), then up;
/// a modded press holds :MOD too; a press of 0 frames lasts 1.
#[test]
fn press_releases_after_its_length() {
    let m = ki_battle();
    let mut vp = m.pilot.get(m.p1).unwrap().vpad.clone();
    let (q, md) = (vp.index("quick").unwrap(), vp.index("mod").unwrap());
    let mut b = Brain::new(Difficulty::Normal, 14);
    ai_press(&mut b, Sym(":QUICK"), 2, true, Sym(":QUICK"));
    let mut downs = vec![];
    for _ in 0..4 {
        ai_press_write(&b, &mut vp);
        downs.push((vp.downs[q], vp.downs[md]));
        b.press_left = (b.press_left - 1).max(0);
    }
    assert_eq!(downs, [(1, 1), (1, 1), (0, 0), (0, 0)]);
    ai_press(&mut b, Sym(":STEP"), 0, false, Sym(":DASH"));
    assert_eq!((b.press_left, b.act, b.press_mod), (1, Some(Sym(":DASH")), false));
}

/// The `P move` / `P step` / `P dash` lines print a brain's WHY (`~@[ ~a~]`: a keyword without its colon). No live CPU sets one
/// (only scripted.lisp's trial player), so cvc-ki-s1's lines have none: its first CPU move line is `[    58] P1 move KE-Z-N1A`.
#[test]
fn why_suffix_text() {
    let mut m = ki_battle();
    let p1 = m.p1;
    (m.log_on, m.match_tick, m.flow) = (true, 58, Flow::Battle);
    let n1a = move_id(&m, "ke-z-n1a");
    duel_sim::fighter::to_idle(&mut m, p1);
    duel_sim::fighter::start_move(&mut m, p1, n1a, None);
    assert_eq!(m.log.iter().find(|l| l.contains(" move ")).unwrap(), "[    58] P1 move KE-Z-N1A");
    m.log.clear();
    m.fighter.get_mut(p1).unwrap().brain.as_mut().unwrap().why = Some(Sym(":TRIAL"));
    duel_sim::fighter::to_idle(&mut m, p1);
    duel_sim::fighter::start_move(&mut m, p1, n1a, None);
    assert_eq!(m.log.iter().find(|l| l.contains(" move ")).unwrap(), "[    58] P1 move KE-Z-N1A TRIAL");
    m.log.clear();
    duel_sim::fighter::start_step(&mut m, p1);
    assert_eq!(m.log, ["[    58] P1 step TRIAL"]);
}

/// %EXPT2 is musl's powf (X, 2.0), not X x X: pinned where they differ (from musl's powf on the native preload, build/simgate/muslm.so).
#[test]
fn expt2_is_musl_powf() {
    let e = |x: u32| duel_sim::cl::expt2(f32::from_bits(x)).to_bits();
    assert_eq!(e(0x3c407123), 0x3910a9e7); // (x*x: 3910a9e6)
    assert_eq!(e(0x3d6f1123), 0x3b5f4101); // (x*x: 3b5f4100)
    assert_eq!(e(0xbd6f1123), 0x3b5f4101);
    assert_eq!(e(0x40400000), 0x41100000); // (3 -> 9)
    assert_eq!(e(0x80000000), 0x80000000); // (-0 x 2)
}

/// Every one of the 2^32 inputs against musl: the FNV-1a hash of `x == 0 ? x*2 : powf(x, 2)` over all bit patterns, computed by a
/// C harness dlopen-ing build/simgate/muslm.so (gcc -m32 -msse2 -mfpmath=sse -ffp-contract=off). ~1 min in release.
#[test]
#[ignore]
fn expt2_equals_musl_on_every_input() {
    let mut h: u64 = 0xcbf29ce484222325;
    for u in 0..=u32::MAX {
        h ^= duel_sim::cl::expt2(f32::from_bits(u)).to_bits() as u64;
        h = h.wrapping_mul(0x100000001b3);
    }
    assert_eq!(h, 0x6d43542f09460075);
}

/// DROP-OLD-JSTARTS keeps the ticks within WINDOW of NOW, in order (newest first, as the Lisp list).
#[test]
fn jstarts_drop_keeps_order() {
    let mut l = vec![300, 250, 190, 181, 100];
    drop_old_jstarts(&mut l, 300, 119);
    assert_eq!(l, [300, 250, 190, 181]);
    drop_old_jstarts(&mut l, 400, 150);
    assert_eq!(l, [300, 250]);
    drop_old_jstarts(&mut l, 1000, 1);
    assert!(l.is_empty());
}

/// The recorder's C split (ruling 1): the CPU's vpad reader fires in CORE-BRAIN-STEP after VPAD-BEGIN-STEP!, inside BRAIN-SYSTEM;
/// PILOT-SYSTEM never reads a brain's vpad. A line logged earlier in the frame (a debug command, GATE-UPDATE) is before that read.
#[test]
fn brain_read_fires_inside_brain_system() {
    struct Spy(Vec<(usize, usize, i64)>);
    impl PilotInput for Spy {
        fn read(&mut self, m: &mut Match, side: usize) {
            let e = if side == 0 { m.p1 } else { m.p2 };
            self.0.push((side, m.log.len(), m.pilot.get(e).unwrap().vpad.tick));
        }
        fn step_end(&mut self, _m: &mut Match, _s: &mut Search) {}
    }
    let mut m = ki_battle();
    let (s, mut spy) = (&mut Search::new(), Spy(vec![]));
    for _ in 0..300 {
        duel_sim::flow::sim_step(&mut m, s, &mut spy); // (the intro: PILOT-READ reads every vpad, the clock not advanced)
    }
    assert!(spy.0.iter().all(|&(_, _, vt)| vt == 0));
    spy.0.clear();
    m.log_on = true;
    duel_sim::clog!(&mut m, "a frame line");
    duel_sim::flow::sim_step(&mut m, s, &mut spy);
    assert_eq!(spy.0, [(0, 1, 1)]); // (P1's brain: after its vpad clock moved, after the frame's line; then core-brain-step stops)
    assert_eq!(m.unported, Some("core-brain-step"));
}

/// BRAIN-PERCEIVE on the first battle step: the fresh ring holds 32 views of Ichigo at the round's start, the head moved to 1.
#[test]
fn first_perceive_fills_the_ring() {
    let mut m = ki_battle();
    let s = &mut Search::new();
    struct Null;
    impl PilotInput for Null {
        fn read(&mut self, _m: &mut Match, _side: usize) {}
        fn step_end(&mut self, _m: &mut Match, _s: &mut Search) {}
    }
    for _ in 0..301 {
        duel_sim::flow::sim_step(&mut m, s, &mut Null);
    }
    let b = m.fighter.get(m.p1).unwrap().brain.as_ref().unwrap();
    assert_eq!((b.head, b.fresh), (1, false));
    let x = m.transform.get(m.p2).unwrap().pos[0];
    assert!(b.ring.iter().all(|s| s.is_some_and(|s| s.x == x && s.state == State::Idle && s.start == -1)));
    let _ = Entity::NIL;
}

/// TIME-UP (M1 minor T13): Konpaku decides first even with a float Reishi; only the tie on Konpaku reads the Reishi (a float there is
/// still `unported!`).
#[test]
fn time_up_reads_reishi_only_on_a_konpaku_tie() {
    let mut m = ki_battle();
    for _ in 0..300 {
        struct Null;
        impl PilotInput for Null {
            fn read(&mut self, _m: &mut Match, _side: usize) {}
            fn step_end(&mut self, _m: &mut Match, _s: &mut Search) {}
        }
        duel_sim::flow::sim_step(&mut m, &mut Search::new(), &mut Null);
    }
    let (p1, p2) = (m.p1, m.p2);
    m.gauges.get_mut(p1).unwrap().reishi = duel_sim::cl::Num::F(512.5);
    m.gauges.get_mut(p2).unwrap().konpaku -= 1;
    duel_sim::flow::time_up(&mut m);
    assert_eq!((m.unported, m.winner), (None, Some(duel_sim::state::Winner::Side(0))));
    let mut m = ki_battle();
    m.gauges.get_mut(m.p1).unwrap().reishi = duel_sim::cl::Num::F(512.5);
    duel_sim::flow::time_up(&mut m);
    assert_eq!(m.unported, Some("time-up of a float Reishi"));
}

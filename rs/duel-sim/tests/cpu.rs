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

/// The FNV-1a hash of F over every single-float bit pattern, as tools/port/musl-hash.c computes it.
fn fnv_all(f: fn(f32) -> f32) -> u64 {
    let mut h: u64 = 0xcbf29ce484222325;
    for u in 0..=u32::MAX {
        h ^= f(f32::from_bits(u)).to_bits() as u64;
        h = h.wrapping_mul(0x100000001b3);
    }
    h
}

/// Every one of the 2^32 inputs against musl: the hash of `x == 0 ? x*2 : powf(x, 2)`, from `build/musl-hash expt2`
/// (tools/port/musl-hash.c over build/simgate/muslm.so, gcc -m32 -msse2 -mfpmath=sse -ffp-contract=off). ~27 s in release.
#[test]
#[ignore]
fn expt2_equals_musl_on_every_input() {
    assert_eq!(fnv_all(duel_sim::cl::expt2), 0x6d43542f09460075);
}

/// musl's expf (ruling R6) on every input: `build/musl-hash expf`. ~30 s in release.
#[test]
#[ignore]
fn expf_equals_musl_on_every_input() {
    assert_eq!(fnv_all(duel_sim::cl::expf), 0xeae4f603b90fd236);
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
    // (P1's brain: after its vpad clock moved, after the frame's line; then P2's, Ichigo's style)
    assert_eq!(spy.0[0], (0, 1, 1));
    assert_eq!((spy.0.len(), spy.0[1].0, spy.0[1].2), (2, 1, 1));
    assert_eq!(m.unported, None); // (both styles ported: Tasks 6-7)
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
    for _ in 0..300 {
        duel_sim::flow::sim_step(&mut m, s, &mut Null);
    }
    let x = m.transform.get(m.p2).unwrap().pos[0]; // (where P1's first perceive sees him: the step then moves him)
    duel_sim::flow::sim_step(&mut m, s, &mut Null);
    let b = m.fighter.get(m.p1).unwrap().brain.as_ref().unwrap();
    assert_eq!((b.head, b.fresh), (1, false));
    assert!(b.ring.iter().all(|s| s.is_some_and(|s| s.x == x && s.state == State::Idle && s.start == -1)));
    let _ = Entity::NIL;
}

/// A null vpad reader.
struct Null;
impl PilotInput for Null {
    fn read(&mut self, _m: &mut Match, _side: usize) {}
    fn step_end(&mut self, _m: &mut Match, _s: &mut Search) {}
}

/// TIME-UP (M1 minor T13): Konpaku decides first; on a Konpaku tie a float Reishi is compared as CL does (float x fixnum products).
#[test]
fn time_up_reads_a_float_reishi_on_a_konpaku_tie() {
    let mut m = ki_battle();
    for _ in 0..300 {
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
    assert_eq!((m.unported, m.winner), (None, Some(duel_sim::state::Winner::Side(1))));
    use duel_sim::cl::Num::{F, I};
    use duel_sim::rules::time_up_winner;
    assert_eq!(time_up_winner(2, F(650.0), 1300, 2, I(650), 1300), None); // (845000.0 = 845000: CL's exact compare)
    assert_eq!(time_up_winner(2, F(650.5), 1300, 2, I(650), 1300), Some(0));
}

/// Review Focus 5: the CPU's integer maths at its edges. CAI-NEUTRAL's decide-t draws (floor (* 12 (sim-rnd01))) in singles: the
/// stream's top value 0.99999994 (0xFFFFFF / 2^24) gives 11, never 12. CL ROUND is banker's at .5 ties, FLOOR rounds toward -inf,
/// STRAT-MUL's integer wait rounds half up by (floor (+ x 0.5)).
#[test]
fn cpu_floor_round_edges() {
    use duel_sim::cl::{floor_div, floor_f32, round_f32};
    let top = 0xFFFFFF as f32 * (1.0 / 16_777_216.0);
    assert_eq!(top, 0.99999994);
    assert_eq!(floor_f32(12.0 * top), 11);
    assert_eq!(floor_f32(12.0 * 0.0), 0);
    assert_eq!(floor_f32(12.0 * (11.0 / 12.0)), 11);
    for (x, n) in [(0.5, 0), (1.5, 2), (2.5, 2), (-0.5, 0), (-1.5, -2), (-2.5, -2), (2.4999998, 2), (1000.0 * 0.0125, 12)] {
        assert_eq!(round_f32(x), n, "round {x}");
    }
    assert_eq!((floor_f32(-0.5), floor_f32(-2.0), floor_div(-7, 2), floor_div(7, -2), floor_div(-6, 3)), (-1, -2, -4, -4, -2));
    assert_eq!([2.5f32, 1.5, -0.5].map(|x| floor_f32(x + 0.5)), [3, 2, 0]); // (half up, not to even)
}

/// The CPU's Reishi readers over a float Reishi (`cl::Num`), against the native image.
#[test]
fn reishi_readers_take_a_float_reishi() {
    use duel_sim::cl::Num::{F, I};
    use duel_sim::rules::{ai_burst_wanted_p, ai_hoho_spare_p};
    let m = ki_battle();
    let k = &m.knobs;
    let mut g = m.gauges.get(m.p1).unwrap().clone();
    g.reishi_max = 1300;
    g.reishi = F(333.25);
    assert_eq!(duel_sim::fighter::reishi_frac(&g), 0.25634617);
    g.reishi = I(333);
    assert_eq!(duel_sim::fighter::reishi_frac(&g), 0.25615385);
    // (*fs-hoho* 100, *fs-burst* 100, *ai-burst-low* 0.5: the line at 650 of 1300)
    assert!(!ai_hoho_spare_p(k, 150.0, F(300.5), 1300));
    assert!(!ai_hoho_spare_p(k, 150.0, I(300), 1300));
    assert!(ai_hoho_spare_p(k, 100.0, F(650.0), 1300));
    assert!(!ai_hoho_spare_p(k, 100.0, F(649.5), 1300));
    assert!(!ai_hoho_spare_p(k, 100.0, I(649), 1300));
    assert!(ai_hoho_spare_p(k, 200.0, I(649), 1300));
    assert!(ai_hoho_spare_p(k, 100.0, I(650), 1300));
    assert!(ai_burst_wanted_p(k, F(400.5), 1300, F(120.25)));
    assert!(ai_burst_wanted_p(k, I(600), 1300, I(300)));
    assert!(!ai_burst_wanted_p(k, F(1000.5), 1300, F(10.25)));
}

/// FINISH-ROLE against the native image: NIL before *cai-finish-at* (0.6) of the clock, :AHEAD at once, a level bell (a float
/// Reishi's product equal to the integer one) :EVEN only once quiet.
#[test]
fn finish_role_cases() {
    use duel_sim::cl::Num::{F, I};
    use duel_sim::rules::{finish_role, FinishRole::*};
    let m = ki_battle();
    let k = &m.knobs;
    assert_eq!(finish_role(k, 0, 18000, 0, 34, 2, F(650.5), 1300, 2, I(650), 1300), Some(Ahead));
    assert_eq!(finish_role(k, 0, 18000, 10, 34, 2, F(650.0), 1300, 2, I(650), 1300), None);
    assert_eq!(finish_role(k, 0, 18000, 40, 34, 2, F(650.0), 1300, 2, I(650), 1300), Some(Even));
    assert_eq!(finish_role(k, 7201, 18000, 40, 34, 3, I(650), 1300, 2, I(650), 1300), None);
    assert_eq!(finish_role(k, 7200, 18000, 40, 34, 2, I(600), 1300, 2, F(650.25), 1300), Some(Behind));
}

/// MC-PLAN-APPLY: the plan is cleared either way; a pick past the budget takes the best with no roll; the softmax's factor is musl's
/// expf (the native image: (* (+ 1.0 (exp (/ (- (/ (- 520 545) 1000.0)) 0.03))) 0.4) = 1.3203905); a Hoho the CPU may not take now is
/// dropped; a CPU no longer free presses nothing.
#[test]
fn mc_plan_apply_picks_and_clears() {
    use duel_sim::cpu::core_ai::mc_plan_apply;
    assert_eq!((1.0 + duel_sim::cl::expf(-((520 - 545) as f32 / 1000.0) / 0.03)) * 0.4, 1.3203905);
    let mut m = ki_battle();
    for _ in 0..300 {
        duel_sim::flow::sim_step(&mut m, &mut Search::new(), &mut Null);
    }
    let e = m.p1;
    let mut b = m.fighter.get_mut(e).unwrap().brain.take().unwrap();
    m.mc_plan[..5].copy_from_slice(&[2, 7, 8, 900, 100]); // (a gap of 0.8 > NORMAL's budget 0.05: the best, :wait)
    let rng = m.rng;
    assert!(mc_plan_apply(&mut m, e, &mut b));
    assert_eq!((m.mc_plan[0], b.press, b.press_left, m.rng.state()), (0, Some(Sym(":NONE")), 20, rng.state()));
    m.mc_plan[..5].copy_from_slice(&[1, 2, -1, 0, 0]); // (still running: the light model's best, a Hoho)
    m.fighter.get_mut(e).unwrap().xch = 5; // (an open exchange: no Hoho)
    b.press = None;
    assert!(!mc_plan_apply(&mut m, e, &mut b));
    assert_eq!((m.mc_plan[0], b.press), (0, None));
    m.fighter.get_mut(e).unwrap().state = State::Move;
    m.mc_plan[..5].copy_from_slice(&[1, 0, -1, 0, 0]);
    assert!(!mc_plan_apply(&mut m, e, &mut b));
    assert_eq!(m.mc_plan[0], 0);
}

/// The generic CPU with no strategy (every brain's BRAIN-STRAT cleared) in a Kenpachi mirror (no matchup style): it plays its
/// neutral until the MCTS neutral's search, which is Task 8's, and never panics on the way.
#[test]
fn generic_cpu_runs_to_the_mcts() {
    let mut m = Match::new(data());
    duel_sim::flow::go_title(&mut m);
    duel_sim::gate::start_cvc(&mut m, 2, Some([Character::Kenpachi, Character::Kenpachi]));
    let s = &mut Search::new();
    for _ in 0..300 {
        duel_sim::flow::sim_step(&mut m, s, &mut Null);
    }
    for e in [m.p1, m.p2] {
        m.fighter.get_mut(e).unwrap().brain.as_mut().unwrap().strat = None;
    }
    let mut n = 0;
    while m.unported.is_none() && n < 2000 {
        duel_sim::flow::sim_step(&mut m, s, &mut Null);
        n += 1;
    }
    assert_eq!(m.unported, Some("mc-neutral"));
    assert!(n > 1, "it walked in first ({n} steps)");
}


/// tests/duel-rules/core.lisp's CPU helper checks deferred to M2: lines 307-317 (FINISH-ROLE, *cai-finish-at* 0.6 = the explicit AT
/// of 307-314), 468 (AI-HOHO-SPARE-P), 471 (AI-BURST-WANTED-P), 576 (WEIGHTED-PICK).
#[test]
fn cpu_helpers_core_lisp() {
    use duel_sim::cl::Num::I;
    use duel_sim::cpu::xch_ai::weighted_pick;
    use duel_sim::rules::{ai_burst_wanted_p, ai_hoho_spare_p, finish_role, FinishRole::*};
    let m = ki_battle();
    let k = &m.knobs;
    let fr = |l, t, q, w, k0, r0, m0, k1, r1, m1| finish_role(k, l, t, q, w, k0, I(r0), m0, k1, I(r1), m1);
    assert_eq!(k.cai_finish_at, 0.6);
    assert_eq!(fr(7201, 18000, 99, 24, 6, 100, 1000, 3, 900, 1000), None);
    assert_eq!(fr(7200, 18000, 0, 24, 6, 100, 1000, 3, 900, 1000), Some(Ahead));
    assert_eq!(fr(7200, 18000, 23, 24, 3, 900, 1000, 6, 100, 1000), None);
    assert_eq!(fr(7200, 18000, 24, 24, 3, 900, 1000, 6, 100, 1000), Some(Behind));
    assert_eq!(fr(600, 18000, 24, 24, 2, 900, 1000, 4, 1000, 1000), Some(Behind));
    assert_eq!(fr(600, 18000, 5, 24, 4, 500, 1000, 4, 525, 1050), None);
    assert_eq!(fr(600, 18000, 30, 24, 4, 500, 1000, 4, 525, 1050), Some(Even));
    assert_eq!(fr(60, 18000, 0, 24, 4, 600, 1000, 4, 500, 1000), Some(Ahead));
    let total = 60 * k.match_seconds;
    assert_eq!(fr(total, total, 0, 0, 9, 0, 1, 1, 0, 1), None);
    let at = duel_sim::cl::floor_f32(total as f32 * (1.0 - k.cai_finish_at));
    assert!(fr(at, total, 0, 0, 9, 0, 1, 1, 0, 1).is_some());
    assert!(0.0 < k.cai_finish_at && k.cai_finish_at < 1.0);
    assert!(ai_hoho_spare_p(k, 100.0, I(1000), 1100) && !ai_hoho_spare_p(k, 190.0, I(400), 1100) && ai_hoho_spare_p(k, 200.0, I(400), 1100));
    assert!(ai_burst_wanted_p(k, I(540), 1100, I(10)) && !ai_burst_wanted_p(k, I(600), 1100, I(10)));
    assert!(ai_burst_wanted_p(k, I(600), 1100, I(280)) && !ai_burst_wanted_p(k, I(600), 1100, I(260)));
    assert_eq!(weighted_pick(0.0, &[('a', 1.0), ('b', 1.0)]), Some('a'));
    assert_eq!(weighted_pick(0.5, &[('a', 1.0), ('b', 1.0)]), Some('b'));
    assert_eq!(weighted_pick(0.1, &[('a', 0.0), ('b', 1.0)]), Some('b'));
    assert_eq!(weighted_pick(0.5, &[('a', 0.0)]), None);
}

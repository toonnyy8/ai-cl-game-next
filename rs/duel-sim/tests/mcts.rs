//! M2 Task 8: the light model (tests/duel-rules/mcts.lisp), the full-sim rollouts and their snapshot boundary (tools/simgate/fulltest.lisp
//! and snaptest.lisp's ideas; the plan's Review Focus 1-3, 5), the rollouts' seed.
use duel_data::Data;
use duel_sim::components::{Character, Difficulty, Flow, State};
use duel_sim::cpu::mcts::{mc_full_step, mc_outcomes_of, mc_plan_write, sim_snapshot_ok_p, with_rollout};
use duel_sim::cpu::mcts_lite::*;
use duel_sim::cpu::{McJob, Search};
use duel_sim::flow::{sim_step, NoInput};
use duel_sim::kit::{find_kit, kit_command_move, kit_core_move, kit_move, Role};
use duel_sim::knobs::Knobs;
use duel_sim::rng::crn_seed;
use duel_sim::state::Match;
use std::sync::OnceLock;

fn data() -> &'static Data {
    static D: OnceLock<Data> = OnceLock::new();
    D.get_or_init(Data::embedded)
}

fn knobs() -> Knobs {
    Knobs::from(data()).unwrap()
}

// ---------------------------------------------------------------- the light model (tests/duel-rules/mcts.lisp)

struct Recs {
    kj1: Rec,
    kns: Rec,
    ij1: Rec,
    ins1: Rec,
}

fn recs(k: &Knobs) -> Recs {
    let d = data();
    let (kk, ik) = (find_kit(d, "kenpachi", "base"), find_kit(d, "ichigo", "base"));
    let rec = |kit, mv| mc_move_rec(k, kit, mv);
    Recs {
        kj1: rec(kk, kit_command_move(d, kk, "q").unwrap()),
        kns: rec(kk, kit_core_move(d, kk, Role::Ns, 1).unwrap()),
        ij1: rec(ik, kit_command_move(d, ik, "q").unwrap()),
        ins1: rec(ik, kit_core_move(d, ik, Role::Ns, 1).unwrap()),
    }
}

/// mcts.lisp's SETUP: side 0 Kenpachi, side 1 Ichigo, both at the base form's outcome values (milli), the given distance and his state.
fn setup(k: &Knobs, r: &Recs, dist: i64, kind: i64, t: i64, len: i64, opp_move: Option<Rec>) -> Lite {
    let mut l = Lite::default();
    (l.slots[0], l.slots[1], l.slots[8], l.slots[9], l.slots[10]) = (Some(r.kj1), Some(r.kns), Some(r.ij1), Some(r.ins1), opp_move);
    let row = |c: &str, kn: &[(Option<String>, Option<String>, [f32; 7])]| {
        kn.iter().find(|x| x.0.as_deref() == Some(c) && x.1.as_deref() == Some("base")).unwrap().2.map(|v| duel_sim::cl::round_f32(1000.0 * v))
    };
    l.vals = [row("kenpachi", &k.mc_outcomes.0), row("ichigo", &k.mc_outcomes.0)];
    l.i = [mc_init_fighter(K_FREE, 0, 0, 350, 73, 1, 0), mc_init_fighter(kind, t, len, 350, 70, 1, 0)];
    (l.g[0], l.g[1], l.g[3], l.g[4], l.g[5], l.g[6]) = (dist, 350, 60, 14, 700, 500);
    for (i, &x) in k.mc_prior.0.iter().enumerate() {
        l.w[i] = x;
    }
    (l.legal, l.legal2) = ([1; 10], [1; 10]);
    l.seed(12345);
    l
}

/// mcts.lisp: the records (frames and classes from the kit, Ichigo's NS2 third segment GETSUGA JUJISHO a wave), the rollouts' cases
/// (a reeling opponent hit by the J1, a lying one never, the triangle's cancel, a perfect Hoho's counter, a J1 into her perfect Hoho),
/// the tree search's determinism.
#[test]
fn light_model_mcts_lisp() {
    let (k, d) = (knobs(), data());
    let r = recs(&k);
    let (kk, ik) = (find_kit(d, "kenpachi", "base"), find_kit(d, "ichigo", "base"));
    assert_eq!(r.kj1[R_S], kit_command_move(d, kk, "q").unwrap().s as i64);
    assert_eq!((r.kj1[R_CLS], r.kns[R_CLS], r.ins1[R_CLS]), (1, 2, 2));
    let getsuga = mc_move_rec(&k, ik, kit_move(d, ik, "ic-n2c").unwrap());
    assert!(getsuga[R_WAVE_V] > 0 && getsuga[R_WAVE_RANGE] > 0);
    let v0 = |l: &Lite, o: usize| l.vals[0][o];
    // a reeling opponent at 1.5 m: Kenpachi's J1 lands before he can act, worth exactly the NA hit
    let mut l = setup(&k, &r, 1500, K_REEL, 0, 60, None);
    assert_eq!(l.rollout(0, -1), v0(&l, O_NA));
    // he is lying (invulnerable) through the horizon: nothing connects
    let mut l = setup(&k, &r, 1500, K_LIE, 0, 90, None);
    assert_eq!((l.rollout(0, -1), l.rollout(1, -1)), (0, 0));
    // his NS segment's startup (frame 0) at 1.2 m: Kenpachi's J1 (NA) meets it first: the triangle's cancel, 0
    let mut l = setup(&k, &r, 1200, K_MOVE, 0, r.ins1[R_END], Some(r.ins1));
    assert!(r.kj1[R_FROM] < r.ins1[R_FROM]);
    assert_eq!(l.rollout(0, -1), 0);
    // his J1 (NA) 5 frames before its window: Kenpachi's Hoho now is perfect: the counter's value
    let mut l = setup(&k, &r, 1200, K_MOVE, 0.max(r.ij1[R_FROM] - 5), r.ij1[R_END], Some(r.ij1));
    assert_eq!(l.rollout(2, -1), v0(&l, O_COUNTER));
    // she waits with her Hoho ready and always answers (react 1000): Kenpachi's J1 at 1.2 m meets her perfect Hoho
    let mut l = setup(&k, &r, 1200, K_WAIT, 0, 60, None);
    l.g[1] = 1000;
    assert_eq!(l.rollout(0, -1), -l.vals[1][O_COUNTER]);
    // the same seed gives the same values (the search is deterministic)
    let mut a = setup(&k, &r, 2500, K_FREE, 0, 0, None);
    a.search(60, false, k.mc_ucb_c, true);
    let mut b = setup(&k, &r, 2500, K_FREE, 0, 0, None);
    b.search(60, false, k.mc_ucb_c, true);
    assert_eq!((a.n, a.sum), (b.n, b.sum));
    assert_eq!(a.n.iter().sum::<i64>(), 60);
    assert!(a.n.iter().all(|&x| x > 0));
}

/// mcts.lisp: decoupled UCT plays every rollout, the same seed the same values; a J1 into a raised guard ends at the block's value.
#[test]
fn light_model_duct_and_guard() {
    let k = knobs();
    let r = recs(&k);
    let run = || {
        let mut l = setup(&k, &r, 2500, K_FREE, 0, 0, None);
        (l.g[1], l.slots[10]) = (20, None);
        l.seed(777);
        l.search(60, true, k.mc_ucb_c, true);
        (l.n, l.sum)
    };
    let (x, y) = (run(), run());
    assert_eq!(x, y);
    assert_eq!(x.0.iter().sum::<i64>(), 60);
    let mut l = setup(&k, &r, 1200, K_GUARD, 4, 60, None);
    (l.slots[1], l.slots[9]) = (None, None);
    l.i[1][F_HOHO] = 0;
    (l.g[1], l.g[5], l.g[6]) = (0, 0, 0);
    l.seed(5);
    assert_eq!(l.rollout(0, -1), l.vals[0][O_BLOCK]);
}

/// `*mc-cls-codes*` #(nil :na :ns :as :sa) is `cls_code`'s order; MC-OUTCOMES-OF falls back to (character T) then (T T), HARD reading
/// its own table.
#[test]
fn cls_codes_and_outcome_rows() {
    use duel_data::MoveClass::*;
    let raw = &data().tuning["*MC-CLS-CODES*"];
    let names: Vec<Option<&str>> = raw.as_array().unwrap().iter().map(|v| v.as_str()).collect();
    assert_eq!(names, [None, Some("na"), Some("ns"), Some("as"), Some("sa")]);
    for (i, c) in [None, Some(Na), Some(Ns), Some(As), Some(Sa)].into_iter().enumerate() {
        assert_eq!(cls_code(c), i as i64);
    }
    let k = knobs();
    assert_eq!(k.mc_outcomes.row("kenpachi", "bankai-2"), k.mc_outcomes.row("kenpachi", "zzz")); // ((:kenpachi t))
    assert_eq!(k.mc_outcomes.row("kenpachi", "bankai-2")[0], 0.115);
    assert_eq!(k.mc_outcomes_hard.row("kenpachi", "bankai-2")[0], 0.202); // (HARD has its own row)
    assert_eq!(k.mc_outcomes.row("rukia", "base")[0], 0.129); // ((t t))
    let m = ki_battle(&mut Search::new());
    assert_eq!(mc_outcomes_of(&m.knobs, &m, m.p2, Difficulty::Hard)[0], k.mc_outcomes_hard.row("ichigo", "base")[0]);
}

// ---------------------------------------------------------------- the full sim's rollouts (cpu-mcts.lisp)

/// cvc-ki-s1's start (START-CVC seed 1, Kenpachi vs Ichigo) through its intro: the first battle step next.
fn ki_battle(s: &mut Search) -> Match {
    let mut m = Match::new(data());
    duel_sim::flow::go_title(&mut m);
    duel_sim::gate::start_cvc(&mut m, s, 1, Some([Character::Kenpachi, Character::Ichigo]));
    m
}

/// The match's state as fulltest's digest sees it: the B line (every sim field), the A line's brains and pilots (past the plan and
/// `*mc-next*`, before the job sections), the sim stream, the tick.
fn digest(m: &Match, s: &Search) -> (String, String, u32, i64) {
    let a = duel_sim::cpu::a_line(m, s);
    let brains: Vec<&str> = a[..a.find(" |").unwrap()].split(' ').skip(13).collect();
    (duel_sim::hashline::bits_line(m), brains.join(" "), m.rng.state(), m.match_tick)
}

/// KI seed 1 played live (both CPUs thinking, no reader) until a job holds its snapshot with a rollout to go.
fn with_a_job() -> (Match, Search) {
    let mut s = Search::new();
    let mut m = ki_battle(&mut s);
    for _ in 0..30_000 {
        sim_step(&mut m, &mut s, &mut NoInput);
        assert_eq!(m.unported, None);
        if s.mc_jobs.first().is_some_and(|j| j.snap.is_some() && j.n < 2) {
            return (m, s);
        }
    }
    panic!("no job in 30000 steps");
}

/// Everything of `Search` a rollout must leave alone (the port's rollouts run on a scratch match, so pollution could only show here):
/// the jobs after the first, the strategy jobs, the decisions count, the strategy stats and picks, the page, a cut.
fn search_rest(s: &Search) -> String {
    let jobs: Vec<String> = s.mc_jobs.iter().skip(1).map(|j| format!("{} {} {} {:?} {} {} {} {}", j.side, j.a1, j.a2, j.dif, j.n, j.v1, j.v2, j.rng)).collect();
    let st: Vec<String> = s.strat_jobs.iter().map(|j| format!("{} {:?} {:?} {:?} {:?} {}", j.side, j.sums, j.ns, j.hsums, j.hns, j.n)).collect();
    format!("{jobs:?} {st:?} {} {:?} {:?} {:?} {:?}", s.mc_stats[0], s.strat_stats, s.strat_picks, s.page, s.cut)
}

/// Review Focus 1 (fulltest.lisp): one extra rollout of the oldest job, the way MC-FULL-STEP runs one: the live match is as before
/// (the B line, the brains, the plan, the sim stream), the job holds the new score, and the rest of `Search` is untouched.
#[test]
fn rollout_leaves_live_state_and_keeps_search() {
    let (mut m, mut s) = with_a_job();
    let before = digest(&m, &s);
    let n = s.mc_jobs[0].n;
    let pool = s.pool.len();
    m.mc_plan[5 * s.mc_jobs[0].side as usize] = 1; // (its plan still running)
    let plan = m.mc_plan;
    let (jobs, rest) = (s.mc_jobs.len(), search_rest(&s));
    mc_full_step(&mut m, &mut s);
    assert_eq!(digest(&m, &s), before);
    if n == 0 {
        assert_eq!(search_rest(&s), rest);
    }
    assert_eq!(m.mc_plan == plan, n == 0, "the plan is written only when both actions are scored");
    if n == 0 {
        assert_eq!((s.mc_jobs.len(), s.mc_jobs[0].n), (jobs, 1), "the job's first score kept");
        assert!(s.mc_jobs[0].v1.is_finite());
    } else {
        let k = 5 * (m.mc_plan[5] != plan[5]) as usize;
        assert_eq!((s.mc_jobs.len(), s.pool.len(), m.mc_plan[k]), (jobs - 1, pool + 1, 2), "scored: the plan written, the slot back");
    }
    assert_eq!((s.mc_stats[1] > 0, s.cut_rollouts), (true, 0));
    // the live state stays usable: the match plays on with no allocation surprise and no unported path
    for _ in 0..600 {
        sim_step(&mut m, &mut s, &mut NoInput);
    }
    assert_eq!(m.unported, None);
}

/// Review Focus 2: a cinematic, a pause or the match's end while jobs are pending (SIM-SNAPSHOT-OK-P false): the jobs are dropped
/// (their slots back in the pool) and every plan cleared.
#[test]
fn jobs_dropped_when_snapshot_not_ok() {
    let (m0, mut s) = with_a_job();
    let slots = s.pool.len() + s.mc_jobs.iter().filter(|j| j.snap.is_some()).count();
    let cine = {
        let mut x = m0.clone();
        let (a, v) = (x.p1, x.p2);
        duel_sim::cine::start_cine(&mut x, duel_sim::cine::CineName::Intro, a, v, None);
        x.cine.clone()
    };
    assert!(cine.is_some());
    let cases: [fn(&mut Match, &Option<duel_sim::cine::Cine>); 3] =
        [|m, c| m.cine = c.clone(), |m, _| m.paused = true, |m, _| m.flow = Flow::Finish];
    for (i, set) in cases.into_iter().enumerate() {
        let mut m = m0.clone();
        if s.mc_jobs.is_empty() {
            s.mc_jobs.push(McJob { e: m.p1, side: 0, a1: 3, a2: 8, dif: Difficulty::Normal, snap: None, n: 0, v1: 0.0, v2: 0.0, rng: 0 });
        }
        set(&mut m, &cine);
        assert!(!sim_snapshot_ok_p(&m), "case {i}");
        m.mc_plan = [1, 3, 8, 0, 0, 2, 1, 2, 10, 5];
        mc_full_step(&mut m, &mut s);
        assert!(s.mc_jobs.is_empty(), "case {i}");
        assert_eq!((m.mc_plan, s.pool.len()), ([0; 10], slots), "case {i}");
    }
}

/// Review Focus 2: a rollout that reaches a K.O. stops at :finish, without GO-RESULTS (no results screen, no win / lose states); the
/// live match's own K.O. still goes on to the results (cinematics skipped).
#[test]
fn rollout_never_ends_the_match() {
    let mut m = ki_battle(&mut Search::new());
    for _ in 0..301 {
        sim_step(&mut m, &mut Search::new(), &mut NoInput);
    }
    assert_eq!(m.flow, Flow::Battle);
    let mut r = m.clone();
    with_rollout(&mut r, true);
    let p1 = r.p1;
    duel_sim::flow::match_over(&mut r, Some(p1));
    assert_eq!(r.flow, Flow::Finish);
    assert!([r.p1, r.p2].iter().all(|&e| !matches!(r.fighter.get(e).unwrap().state, State::Win | State::Lose)));
    let n = duel_sim::cpu::mcts::sim_rollout(&mut r, &mut Search::new(), 40);
    assert_eq!((n, r.flow), (0, Flow::Finish), "a rollout stops when the flow leaves the battle");
    m.skip_cines = true;
    duel_sim::flow::match_over(&mut m, Some(p1));
    assert_eq!(m.flow, Flow::Results);
}

/// Review Focus 3: a human opponent (no brain, a camera-relative stick): the rollout plays him with a stand-in brain at the job's
/// difficulty and `cam_relative` false; the live match keeps him brainless.
#[test]
fn stand_in_brain_for_human() {
    let mut s = Search::new();
    let mut m = ki_battle(&mut s);
    for _ in 0..301 {
        sim_step(&mut m, &mut s, &mut NoInput);
    }
    let (p1, p2) = (m.p1, m.p2);
    m.fighter.get_mut(p1).unwrap().brain = None;
    m.pilot.get_mut(p1).unwrap().cam_relative = true;
    s.mc_jobs.push(McJob { e: p2, side: 1, a1: 7, a2: 8, dif: Difficulty::Hard, snap: None, n: 0, v1: 0.0, v2: 0.0, rng: 0 });
    m.mc_plan[5..].copy_from_slice(&[1, 7, 8, 0, 0]);
    let before = digest(&m, &s);
    mc_full_step(&mut m, &mut s);
    assert_eq!(s.mc_jobs[0].n, 1);
    assert_eq!(digest(&m, &s).0, before.0);
    assert!(m.fighter.get(p1).unwrap().brain.is_none() && m.pilot.get(p1).unwrap().cam_relative);
    let r = &s.scratch.as_ref().unwrap().0;
    let b = r.fighter.get(p1).unwrap().brain.as_ref().expect("the stand-in");
    assert_eq!((b.difficulty, b.delay, r.pilot.get(p1).unwrap().cam_relative), (Difficulty::Hard, 8, false));
    assert!(r.in_rollout && r.styles_off && !r.log_on && r.skip_cines);
}

/// Review Focus 5: MC-FULL-STEP's plan `(round (* 1000 v))` is banker's at ±x.5 (62.5 → 62, 187.5 → 188, -62.5 → -62), the better
/// first (`(< v1 v2)` swaps; a tie keeps the order).
#[test]
fn plan_score_rounding() {
    let mut p = [0i64; 10];
    mc_plan_write(&mut p, 0, 3, 8, 0.0625, 0.1875);
    assert_eq!(p[..5], [2, 8, 3, 188, 62]);
    mc_plan_write(&mut p, 5, 1, 2, -0.0625, -0.1875);
    assert_eq!(p[5..], [2, 1, 2, -62, -188]);
    mc_plan_write(&mut p, 0, 4, 5, 0.0025, 0.0025);
    assert_eq!(p[..5], [2, 4, 5, 2, 2]); // (0.0025 × 1000 is 2.4999998 in single-floats)
}

/// The rollouts' common random numbers: `(logior 1 (logand #xFFFFFFF (+ rng 7919)))` for rng 0, #xFFFFFFF and 7.
#[test]
fn crn_seed_values() {
    assert_eq!(crn_seed(0), 7919);
    assert_eq!(crn_seed(0xFFF_FFFF), 7919); // ((#xFFFFFFF + 7919) masked = 7918, then | 1)
    assert_eq!(crn_seed(7), 7927);
    assert_eq!(crn_seed(0xFFFF_FFFF), 7919); // (an unsigned state past 2^28: 28 bits kept)
}

/// STRAT-FULL-STEP / STRAT-ROLL (ruling R4: no strategy job occurs in play; host-tested only): a selection queued by STRAT-REQUEST
/// takes one rollout a step (MC-FULL-STEP with no action job), each from the snapshot of its first step, the live match untouched;
/// after `*strat-rolls*` the pick goes into his live brain (after the restore), `*strat-picks*` counts it, and its slot goes back.
#[test]
fn strat_full_step_picks_after_its_rolls() {
    use duel_sim::cpu::{glue, perceive};
    let mut s = Search::new();
    let mut m = ki_battle(&mut s);
    for _ in 0..301 {
        sim_step(&mut m, &mut s, &mut NoInput);
    }
    let e = m.p1;
    let mut b = m.fighter.get_mut(e).unwrap().brain.take().unwrap();
    let snap = perceive::brain_snap_ago(&b, b.delay).unwrap();
    let d = perceive::snap_dist(&m, &snap, e);
    glue::strat_request(&mut m, &mut s, e, &mut b, &snap, d);
    m.fighter.get_mut(e).unwrap().brain = Some(b);
    assert_eq!((s.strat_jobs.len(), s.strat_stats[0], s.mc_jobs.len()), (1, 1, 0));
    assert_eq!(s.strat_picks.len(), 2 * duel_sim::cpu::strategy::strat_library_len(data())); // (strategy.lisp line 91, MC-FULL-RESET)
    let before = digest(&m, &s);
    let rolls = m.knobs.strat_rolls;
    for k in 1..rolls {
        mc_full_step(&mut m, &mut s);
        assert_eq!((s.strat_jobs[0].n, s.strat_stats[1]), (k, k));
        assert_eq!(digest(&m, &s), before, "the live match after rollout {k}");
    }
    let tot: f32 = s.strat_jobs[0].ns.iter().sum::<f32>() + s.strat_jobs[0].hns.iter().sum::<f32>();
    assert!(tot > 0.0 && s.strat_jobs[0].snap.is_some() && s.cut_rollouts == 0);
    mc_full_step(&mut m, &mut s); // (the last rollout: its score counts before the pick)
    assert!(s.strat_jobs.is_empty());
    let st = m.fighter.get(e).unwrap().brain.as_ref().unwrap().strat.expect("the pick");
    assert_eq!(s.strat_picks.iter().sum::<i64>(), 1);
    let pos = duel_sim::cpu::strategy::strat_library_pos(data(), st.id().unwrap()).unwrap();
    assert_eq!(s.strat_picks[pos], 1, "P1's row");
    // (a cinematic or the match's end drops a pending selection)
    let mut b = m.fighter.get_mut(e).unwrap().brain.take().unwrap();
    glue::strat_request(&mut m, &mut s, e, &mut b, &snap, d);
    m.fighter.get_mut(e).unwrap().brain = Some(b);
    m.paused = true;
    mc_full_step(&mut m, &mut s);
    assert!(s.strat_jobs.is_empty());
}

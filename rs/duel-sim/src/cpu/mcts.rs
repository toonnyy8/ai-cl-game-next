//! port: duel/lisp/cpu-mcts.lisp (the MCTS neutral's search and the full sim's say, DUEL_AI_MCTS §12), rollout.lisp (WITH-ROLLOUT)
//! and sim-state.lisp (SIM-SNAPSHOT-OK-P, SIM-ROLLOUT). MC-NEUTRAL's head, MC-PLAN-APPLY and MC-PRESS are core_ai.rs's.
//!
//! The snapshot boundary is Lisp's (M2_NOTES §1). A job's snapshot is a `Slot` (a `Match` written with `clone_from`); a rollout plays
//! on `Search.scratch`, the job's snapshot restored into it, so the live match is never touched: Lisp's `(sim-restore live)` after
//! the rollout is then nothing to do, and WITH-ROLLOUT's bindings (`in_rollout`, `styles_off`, the logs, `skip_cines`) are fields of
//! the scratch match only. What the rollout writes into `Search` (the job's score) stays, as in Lisp.
use super::mcts_lite::{mc_init_fighter, mc_move_rec, Lite, K_FREE, K_GUARD, K_HOHO, K_LIE, K_MOVE, K_REEL, K_STEP};
use super::perceive::{ai_press, Snap};
use super::{Brain, McJob, Search};
use crate::cl::{max_f32, min_f32, round_f32, Num};
use crate::components::{Difficulty, Flow, Phase, State, Sym};
use crate::ecs::Entity;
use crate::fighter::{fighter, hoho_ready_p, hurt_r, kit_of, mv};
use crate::flow::{InRollout, PilotInput};
use crate::kit::{kit_class, kit_command_move, kit_core_move, kit_sa_move, mv_ns_next, Role};
use crate::knobs::Knobs;
use crate::state::Match;
use duel_data::{Kit, MoveClass};

/// port: SIM-SNAPSHOT-OK-P — only in battle, outside a cinematic, not paused.
pub fn sim_snapshot_ok_p(m: &Match) -> bool {
    m.flow == Flow::Battle && m.cine.is_none() && !m.paused
}

/// port: WITH-ROLLOUT's bindings on the rollout's match: `*in-rollout*`, every log off (the combat and pacing logs; `*log-mute*`,
/// `*gate-log*` and `*step-hook*` have no Rust reader inside a lean step), cinematics skipped; STYLES_OFF is MC-FULL-ROLLOUT's
/// `(*cai-styles* nil)`.
pub fn with_rollout(r: &mut Match, styles_off: bool) {
    (r.in_rollout, r.log_on, r.pacing_log, r.skip_cines, r.styles_off) = (true, false, false, true, styles_off);
}

/// port: SIM-ROLLOUT — up to STEPS lean steps as a search's rollout (the styles kept), stopping when the flow leaves the battle, a
/// cinematic runs, or an `unported!` path is hit (`r.unported`). Returns the steps run. R is a scratch match (the caller's restore).
/// DEV: the vpad readers inside it (a brainless human's device, read by PILOT-SYSTEM, writes his held keys).
pub fn sim_rollout(r: &mut Match, s: &mut Search, dev: &mut InRollout, steps: i64) -> i64 {
    with_rollout(r, false);
    let mut i = 0;
    while i < steps && r.flow == Flow::Battle && r.cine.is_none() && r.unported.is_none() {
        crate::flow::sim_step_lean(r, s, dev);
        i += 1;
    }
    i
}

// ---------------------------------------------------------------- the light model's start (MC-SETUP)

/// port: MC-PTR — F's SP pointer clamped to his three NS (1-3).
fn mc_ptr(m: &Match, e: Entity) -> i64 {
    1.max(3.min(fighter(m, e).ptr))
}

/// port: mcts-lite.lisp MC-OUTCOMES-OF — the outcome row of E's character in his form at DIF.
pub fn mc_outcomes_of(k: &Knobs, m: &Match, e: Entity, dif: Difficulty) -> [f32; 7] {
    let f = fighter(m, e);
    let tab = if dif == Difficulty::Hard { &k.mc_outcomes_hard } else { &k.mc_outcomes };
    tab.row(f.character.expect("a character").name(), f.form.name())
}

/// port: MC-SIDE-SETUP — side SIDE's records (J1, his NS under his pointer and its next segments, his SA), outcome values and
/// fighter vector.
fn mc_side_setup(l: &mut Lite, m: &Match, side: usize, e: Entity, kit: &Kit, dif: Difficulty) {
    let (d, k) = (m.data, &m.knobs);
    let q = kit_command_move(d, kit, "q");
    let ns = kit_core_move(d, kit, Role::Ns, mc_ptr(m, e));
    let ns2 = ns.and_then(|ns| mv_ns_next(d, kit, ns));
    let ns3 = ns2.and_then(|ns2| mv_ns_next(d, kit, ns2));
    l.slots[8 * side..8 * side + 8].fill(None);
    for (i, mv) in [q, ns, None, ns2, ns3, kit_sa_move(d, kit)].into_iter().enumerate() {
        if let Some(mv) = mv {
            l.slots[8 * side + i] = Some(mc_move_rec(k, kit, mv));
        }
    }
    for (i, v) in mc_outcomes_of(k, m, e, dif).into_iter().enumerate() {
        l.vals[side][i] = round_f32(1000.0 * v);
    }
    let (hurt, walk) = (round_f32(1000.0 * hurt_r(m, e)), round_f32(1000.0 * kit.walk / 60.0));
    l.i[side] = mc_init_fighter(K_FREE, 0, 0, hurt, walk, hoho_ready_p(m, e) as i64, mc_ptr(m, e) - 1);
}

/// port: MC-SETUP — the light model's start from E's view (his SNAP S of the opponent at distance D), or None when the opponent's
/// perceived state is not one the model starts from (:air / :down / :wakeup, a cinematic ...). DIF: what he expects of him.
pub fn mc_setup(m: &Match, e: Entity, s: &Snap, d: f32, dif: Difficulty) -> Option<Lite> {
    let (k, o) = (&m.knobs, fighter(m, e).opp);
    let (kit, okit) = (kit_of(m, e), kit_of(m, o));
    let mut l = Lite::default();
    mc_side_setup(&mut l, m, 0, e, kit, dif);
    mc_side_setup(&mut l, m, 1, o, okit, dif);
    let left = 1.max(90.min(s.left));
    let (kind, tt, len) = match s.state {
        State::Idle | State::Run => (l.i[1][0], l.i[1][1], l.i[1][2]),
        State::Move => match s.mv {
            Some(id) if s.phase == Some(Phase::Main) => {
                let mvd = mv(m, id);
                let r = mc_move_rec(k, okit, mvd);
                let n2 = mv_ns_next(m.data, okit, mvd);
                let n3 = n2.and_then(|n2| mv_ns_next(m.data, okit, n2));
                l.slots[10] = Some(r);
                l.i[1][super::mcts_lite::F_SLOT] = 2;
                l.slots[14] = n2.map(|x| mc_move_rec(k, okit, x));
                l.slots[15] = n3.map(|x| mc_move_rec(k, okit, x));
                (K_MOVE, s.sf, (1 + s.sf).max(r[super::mcts_lite::R_END]))
            }
            _ => (K_REEL, 0, left),
        },
        State::Stun => (K_REEL, 0, left),
        State::Guard | State::GuardHit => (K_GUARD, 4, 24),
        State::Step => (K_STEP, 7.max(s.sf), 24),
        State::Hoho => (K_HOHO, s.sf, 24),
        _ => return None,
    };
    (l.i[1][0], l.i[1][1], l.i[1][2]) = (kind, tt, len);
    let dn = dif.name();
    l.g[0] = round_f32(1000.0 * d);
    l.g[1] = round_f32(1000.0 * k.mc_react_p.get_or(dn, 0.1));
    l.g[4] = k.mc_opp_delay.get(dn, 14);
    l.g[5] = round_f32(1000.0 * k.cai_cont_p.get_or(dn, 0.7));
    l.g[6] = round_f32(1000.0 * k.cai_turn_p.get_or(dn, 0.5));
    let busy = if k.mc_wait_busy && (kind == K_REEL || kind == K_LIE) { len - tt } else { 0 };
    l.g[3] = k.mc_horizon_max.min(k.mc_horizon + busy);
    for (i, &x) in k.mc_prior.0.iter().enumerate() {
        l.w[i] = x;
    }
    let (he, ho) = (hoho_ready_p(m, e), hoho_ready_p(m, o));
    for a in 0..10 {
        l.legal[a] = match a {
            0 | 1 => l.slots[a].is_some(),
            2 => he,
            6 => false,
            _ => true,
        } as i64;
        l.legal2[a] = match a {
            0 | 1 => l.slots[8 + a].is_some(),
            2 => ho,
            6 => false,
            _ => true,
        } as i64;
    }
    Some(l)
}

// ---------------------------------------------------------------- the search and its decision (MC-NEUTRAL past its guard)

/// port: MC-EST — root action A's light estimate plus the active strategy's bias for it (:B-…; none: the estimate), or None.
fn mc_est(k: &Knobs, b: &Brain, l: &Lite, a: usize) -> Option<f32> {
    let m = l.mean(a)?;
    match (&k.strat_bias_keys.0[a], b.now.as_ref()) {
        (Some(key), Some(_)) => Some(match super::strategy::strat_out(&k.fz_sets, b.now.as_ref(), key, Some(Num::I(0))) {
            Some(Num::I(n)) => m + n as f32,
            Some(Num::F(x)) => m + x,
            None => m,
        }),
        _ => Some(m),
    }
}

/// MC-NEUTRAL from MC-SEED on (MC-SETUP gave L): the light search, the margin's deferral, then the full sim's job (MC-FULL-REQUEST)
/// or, without `*mc-full*`, a softmax pick. T when he pressed.
pub fn mc_decide(m: &mut Match, s: &mut Search, e: Entity, b: &mut Brain, mut l: Lite) -> bool {
    let side = fighter(m, e).side;
    l.seed(m.rng.state() as i64 ^ (7919 * m.match_tick + side + 1)); // (its own stream: the sim's is only read)
    let (k, dif) = (&m.knobs, b.difficulty);
    let dn = dif.name();
    let iters = if k.mc_full { k.mc_full_lite.get(dn, 16) } else { k.mc_iters.get(dn, 96) };
    let duct = k.mc_select_by.getf(dn).unwrap_or("tree").eq_ignore_ascii_case("duct");
    l.search(iters, duct, k.mc_ucb_c, k.mc_opp_search);
    let est: [Option<f32>; 10] = std::array::from_fn(|a| mc_est(k, b, &l, a));
    let best = est.iter().flatten().copied().reduce(max_f32).expect("a played action");
    let second = est.iter().flatten().copied().filter(|&x| x < best).reduce(max_f32);
    if second.is_some_and(|sec| best - sec < k.mc_sure.get_or(dn, 0.0)) {
        // (not decided enough: the CPU under it decides)
        m.mc_next[side as usize] = m.match_tick + k.mc_defer_gap;
        return false;
    }
    if k.mc_full {
        return mc_full_request(m, s, e, b, &est);
    }
    // (*mc-full* NIL: the light model alone, a softmax within the budget; dead while the knob is T)
    let (tau, lo) = (k.mc_tau.get_or(dn, 0.03), best - k.mc_budget.get_or(dn, 0.05));
    let mut ws = [0.0f32; 10];
    let mut tot = 0.0f32;
    for a in 0..10 {
        ws[a] = match est[a] {
            Some(x) if x >= lo => crate::cl::expf((x - lo) / tau),
            _ => 0.0,
        };
        tot += ws[a];
    }
    let mut r = tot * m.rng.rnd01();
    let actions = &m.knobs.mc_actions.0;
    for a in 0..10 {
        if ws[a] > 0.0 {
            r -= ws[a];
            if r <= 0.0 {
                super::core_ai::mc_press(b, &actions[a]);
                return true;
            }
        }
    }
    let a = (0..10).find(|&a| est[a] == Some(best)).expect("the best");
    super::core_ai::mc_press(b, &actions[a]);
    true
}

/// port: MC-FULL-REQUEST — after the light search: the best two go to the full sim (a job), he holds for his reaction time. T (he
/// pressed); NIL with no action at all.
fn mc_full_request(m: &mut Match, s: &mut Search, e: Entity, b: &mut Brain, est: &[Option<f32>; 10]) -> bool {
    let side = fighter(m, e).side;
    let k = 5 * side as usize;
    let (mut a1, mut a2, mut m1, mut m2) = (-1i64, -1i64, 0.0f32, 0.0f32);
    for (a, x) in est.iter().enumerate() {
        if let Some(x) = *x {
            if a1 < 0 || x > m1 {
                (a2, m2, a1, m1) = (a1, m1, a as i64, x);
            } else if a2 < 0 || x > m2 {
                (a2, m2) = (a as i64, x);
            }
        }
    }
    if a1 < 0 {
        return false;
    }
    if a2 < 0 {
        super::core_ai::mc_press(b, &m.knobs.mc_actions.0[a1 as usize]); // (one legal action: no question)
        return true;
    }
    m.mc_plan[k..k + 5].copy_from_slice(&[1, a1, a2, 0, 0]);
    let none = Sym(":NONE");
    let act = if b.press == Some(none) && b.act == Some(Sym(":DASH")) { Sym(":DASH") } else { none }; // (the hold: a walk goes on)
    ai_press(b, none, b.delay, false, act);
    s.mc_jobs.push(McJob { e, side, a1, a2, dif: b.difficulty, snap: None, n: 0, v1: 0.0, v2: 0.0, rng: 0 });
    s.mc_stats[0] += 1;
    true
}

// ---------------------------------------------------------------- the full sim's rollouts (§12)

/// port: MC-FULL-RESET — a match starts: no plan, no job, no stats; the strategy layer's selections too (START-MATCH).
pub fn mc_full_reset(m: &mut Match, s: &mut Search) {
    m.mc_plan = [0; 10];
    s.drop_mc_jobs();
    s.mc_stats = [0; 4];
    s.drop_strat_jobs();
    s.strat_stats = [0; 4];
    let n = 2 * super::strategy::strat_library_len(m.data);
    s.strat_picks.resize(n, 0); // (*strat-picks* is sized at load: 2 x the library)
    s.strat_picks.fill(0);
}

/// port: MC-FULL-HEALTH — the teacher's unit: Konpaku + 1.5 x the Reishi bar's fraction.
pub fn mc_full_health(m: &Match, e: Entity) -> f32 {
    let g = m.gauges.get(e).expect("gauges");
    let frac = match g.reishi {
        Num::I(n) => n as f32 / g.reishi_max as f32,
        Num::F(x) => x / g.reishi_max as f32,
    };
    g.konpaku as f32 + 1.5 * frac
}

/// port: MC-FULL-CONTACT — the outcome table's value, for E, of the contact attacker A just opened on D.
pub fn mc_full_contact(m: &Match, e: Entity, a: Entity, d: Entity, dif: Difficulty) -> f32 {
    let fa = fighter(m, a);
    let mvd = (fa.state == State::Move).then_some(fa.mv).flatten().map(|id| mv(m, id));
    let counter = fa.state == State::Hoho && fa.perfect;
    let cls = if counter { None } else { mvd.and_then(|x| kit_class(kit_of(m, a), Some(x))) };
    let row = mc_outcomes_of(&m.knobs, m, a, dif);
    let v = if fighter(m, d).state == State::GuardHit {
        row[6]
    } else if counter {
        row[5]
    } else {
        match cls {
            Some(MoveClass::Na) => row[0],
            Some(MoveClass::Ns) => row[mc_ptr(m, a) as usize],
            Some(MoveClass::As | MoveClass::Sa) => row[4],
            None => 0.0,
        }
    };
    if a == e { v } else { -v }
}

/// port: MC-FULL-ROLLOUT — one rollout from R's state now (lean steps, the generic CPUs' styles off): E's score, the health swing to
/// the first contact (or STEPS) plus the table's value of it. STOP false: no stop at a contact (the strategy layer's rollouts). An
/// `unported!` path stops it (the caller counts it). DEV: the vpad readers inside it (a human's device writes his held keys).
#[allow(clippy::too_many_arguments)]
pub fn mc_full_rollout(r: &mut Match, s: &mut Search, dev: &mut InRollout, e: Entity, o: Entity, steps: i64, dif: Difficulty, stop: bool) -> f32 {
    with_rollout(r, true);
    let (h0, ho0) = (mc_full_health(r, e), mc_full_health(r, o));
    let mut bonus = 0.0f32;
    let (mut pe, mut po) = (fighter(r, e).state, fighter(r, o).state);
    let opened = |st: State, prev: State| {
        stop && matches!(st, State::Stun | State::Air | State::Down | State::GuardHit) && !super::core_ai::mc_full_reel_p(prev)
    };
    for _ in 0..steps {
        if !(r.flow == Flow::Battle && r.cine.is_none()) || r.unported.is_some() {
            break;
        }
        crate::flow::sim_step_lean(r, s, dev);
        if r.unported.is_some() {
            break;
        }
        let (se, so) = (fighter(r, e).state, fighter(r, o).state);
        if opened(so, po) {
            bonus = mc_full_contact(r, e, e, o, dif);
            break;
        }
        if opened(se, pe) {
            bonus = mc_full_contact(r, e, o, e, dif);
            break;
        }
        (pe, po) = (se, so);
    }
    bonus + ((ho0 - mc_full_health(r, o)) - (h0 - mc_full_health(r, e)))
}

/// MC-FULL-ROLL's and STRAT-ROLL's start: the scratch match with snapshot SNAP restored, its sim stream reseeded from RNG (common
/// random numbers), a stand-in brain at DIF for a brainless opponent of E (the human, 「之後學玩家習慣」; a CPU's stick is not the
/// camera's). Returns the scratch and E's opponent.
pub fn rollout_start(s: &mut Search, snap: &Match, rng: u32, e: Entity, dif: Difficulty) -> (super::Slot, Entity) {
    let mut sc = match s.scratch.take() {
        Some(mut sc) => {
            // (the last rollout's stand-in, which the restore would drop, kept for this one)
            for f in [sc.0.p1, sc.0.p2] {
                if snap.fighter.get(f).is_some_and(|x| !x.has_brain())
                    && let Some(b) = sc.0.fighter.get_mut(f).and_then(|x| x.brain.take())
                {
                    s.spare_brain = Some(b);
                }
            }
            (*sc.0).clone_from(snap);
            sc
        }
        None => super::Slot(Box::new(snap.clone())),
    };
    let r = &mut *sc.0;
    r.rng.set_state(crate::rng::crn_seed(rng));
    let o = fighter(r, e).opp;
    if !fighter(r, o).has_brain() {
        let delay = r.knobs.ai_delay.get(dif.name(), 14);
        let b = match s.spare_brain.take() {
            Some(mut b) => {
                b.reset(dif, delay); // (MAKE-BRAIN, its reserves kept)
                b
            }
            None => Brain::new(dif, delay),
        };
        r.fighter.get_mut(o).unwrap().brain = Some(b);
        r.pilot.get_mut(o).expect("a pilot").cam_relative = false;
    }
    (sc, o)
}

/// A rollout's end: the scratch back, a cut rollout (an `unported!` path) counted.
pub fn rollout_end(s: &mut Search, sc: super::Slot, live_tick: i64) {
    if let Some(name) = sc.0.unported {
        s.cut_rollouts += 1;
        s.cut.get_or_insert((name, live_tick));
    }
    s.scratch = Some(sc);
}

/// port: MC-FULL-ROLL — the oldest job's next rollout (its N-th action) from its snapshot: that action planned for him.
fn mc_full_roll(s: &mut Search, dev: &mut InRollout, live_tick: i64) {
    let j = &s.mc_jobs[0];
    let (e, side, a1, a2, dif, n, rng) = (j.e, j.side, j.a1, j.a2, j.dif, j.n, j.rng);
    let snap = s.mc_jobs[0].snap.take().expect("a job's snapshot");
    let (mut sc, o) = rollout_start(s, &snap.0, rng, e, dif);
    s.mc_jobs[0].snap = Some(snap);
    let r = &mut *sc.0;
    let k = 5 * side as usize;
    (r.mc_plan[k], r.mc_plan[k + 1], r.mc_plan[k + 2]) = (2, if n == 0 { a1 } else { a2 }, -1);
    let steps = fighter(r, e).brain.as_ref().expect("his brain").delay + r.knobs.mc_full_h;
    let v = mc_full_rollout(r, s, dev, e, o, steps, dif, true);
    rollout_end(s, sc, live_tick);
    let j = &mut s.mc_jobs[0];
    if n == 0 {
        j.v1 = v;
    } else {
        j.v2 = v;
    }
    j.n = n + 1;
}

/// port: MC-FULL-STEP — at a step's end (SIM-STEP), outside every rollout: one rollout of the oldest job; a job both of whose actions
/// are scored writes them into the plan, the better first. Jobs made this step start from this state. No action job: a rollout of the
/// strategy layer's oldest selection (STRAT-FULL-STEP). INPUT: the live vpad readers (their in-rollout calls run in the rollouts).
pub fn mc_full_step(m: &mut Match, s: &mut Search, input: &mut dyn PilotInput) {
    let dev = &mut InRollout(input);
    if s.mc_jobs.is_empty() && !s.strat_jobs.is_empty() && !m.in_rollout {
        super::glue::strat_full_step(m, s, dev);
    }
    if s.mc_jobs.is_empty() || m.in_rollout {
        return;
    }
    if !sim_snapshot_ok_p(m) {
        s.drop_mc_jobs();
        m.mc_plan = [0; 10];
        return;
    }
    let t0 = (s.clock)();
    for i in 0..s.mc_jobs.len() {
        if s.mc_jobs[i].snap.is_none() {
            let slot = s.snapshot(m); // (one state for every job made this step: the Lisp shares one snapshot)
            (s.mc_jobs[i].snap, s.mc_jobs[i].rng) = (Some(slot), m.rng.state());
        }
    }
    let k = 5 * s.mc_jobs[0].side as usize;
    if m.mc_plan[k] != 1 {
        s.pop_mc_job(); // (its plan is gone: he was hit, or it came due)
    } else {
        mc_full_roll(s, dev, m.match_tick);
        s.mc_stats[1] += 1;
        if s.mc_jobs[0].n == 2 {
            let j = &s.mc_jobs[0];
            let (v1, v2, a1, a2) = (j.v1, j.v2, j.a1, j.a2);
            s.pop_mc_job();
            mc_plan_write(&mut m.mc_plan, k, a1, a2, v1, v2);
        }
    }
    let dt = (s.clock)().saturating_sub(t0) as i64;
    s.mc_stats[2] += dt;
    s.mc_stats[3] = s.mc_stats[3].max(dt);
}

/// MC-FULL-STEP's plan write for a job both of whose actions are scored: state 2, the better action first (`(< v1 v2)` swaps), the
/// values `(round (* 1000 v))` (banker's), the larger first. K is the side's first slot.
pub fn mc_plan_write(p: &mut [i64; 10], k: usize, a1: i64, a2: i64, v1: f32, v2: f32) {
    let swap = v1 < v2;
    (p[k], p[k + 1], p[k + 2]) = (2, if swap { a2 } else { a1 }, if swap { a1 } else { a2 });
    (p[k + 3], p[k + 4]) = (round_f32(1000.0 * max_f32(v1, v2)), round_f32(1000.0 * min_f32(v1, v2)));
}

/// port: MC-FULL-LOG's numbers (RESULTS; not one of G2's lines, never compared): decisions, rollouts, ms a decision, the worst step's
/// ms (the clock's units: milliseconds as `Search.clock` counts them), or None with no decision.
pub fn mc_full_log(s: &Search) -> Option<String> {
    let st = &s.mc_stats;
    (st[0] > 0).then(|| {
        format!(
            "duel mcfull decisions {} rollouts {} ms {} a decision, worst step {}",
            st[0],
            st[1],
            crate::cl::fmt_fixed(st[2] as f64 / st[0] as f64, 3),
            crate::cl::fmt_fixed(st[3] as f64, 2)
        )
    })
}

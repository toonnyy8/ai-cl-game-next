//! port: duel/lisp/strategy-glue.lisp — the strategy layer's glue between the strategies (strategy.rs: the library as data, its pure
//! maths) and the CPU that plays them (core_ai.rs CORE-BRAIN-STEP): the cues a strategy's rules read (STRAT-FEATS, STRAT-XFEATS), the
//! :HOLD-AWAKEN read, the style knobs, the composite / Q selector's judgement (STRAT-SWITCH-STEP) and its event layer
//! (STRAT-EVENT-STEP), the strategy layer's selections (STRAT-REQUEST, STRAT-LAYER-STEP; their rollouts, STRAT-FULL-STEP, are Task 8).
//!
//! The cross-style reads (strategy-glue.lisp's header, R12). A style CPU is a strategy's :FN (strat_styles); it reaches into another
//! style's file only through what this table lists:
//!   reader                                     reads                                                          from
//!   cpu-hisagi-range HISAGI-MERGED-STYLE       KEN-KI-STYLE (Hisagi plays Kenpachi's KI code outside the      cpu-ki-ken
//!                                              ranged mode: the one call across characters)
//!   cpu-kh-ken KEN-KH-STYLE, -STANDOFF-STYLE   KEN-KI-STYLE with :MEATY / :SAFE, the KKS struct (:INCLUDE),   cpu-ki-ken
//!                                              KKS-TICK / -PLAN / -APPR, KK-STICK
//!   cpu-hk-hisagi HISAGI-HK-STYLE              HISAGI-MERGED-STYLE, the HMS struct (:INCLUDE), HR-SP,         cpu-hisagi-range
//!                                              HR-TAKEN
//!   cpu-hisagi-own HISAGI-OWN-STYLE            HISAGI-HK-STYLE (its OWN rule), the HKS struct (:INCLUDE),     cpu-hk-hisagi,
//!                                              HKW-FITS-P; HR-SP, HR-TAKEN, HR-CORNERED-P, *HR-EDGE*          cpu-hisagi-range
//! Every style also uses the shared CPU: core_ai's presses and generic steps (`cai_press`, `cai_sp`, `cai_move_step`, `cai_neutral`
//! ...), the MCTS's MC-PRESS / MC-PTR / MC-PLAN-DROP, and STRAT-OUT over its brain's NOW (`style_knob` ...). Ichigo's KI style
//! (cpu-ki-ichigo) reads no other style.
use super::core_ai::chance_roll;
use super::perceive::Snap;
use super::strategy::{self, Cues, Strat};
use super::style::{self, StyleFn, StyleId};
use super::{Brain, Search, StratJob, Won};
use crate::cl::{floor_div, max_f32, min_f32, Num};
use crate::components::{Form, State};
use crate::core::core_clamp_pointer;
use crate::ecs::Entity;
use crate::fighter::{awaken_ready_p, fighter, gauges_red_p, hoho_ready_p, kit_of, pos_of};
use crate::knobs::{Knobs, KwNums};
use crate::kit::{kit_command_move, kit_core_move, Role};
use crate::state::Match;
use duel_data::tuning::Value;
use duel_data::Move;

/// port: STRAT-REACH — MV's reach plus its forward slide (m), 1 when there is no move.
pub fn strat_reach(mv: Option<&Move>) -> f32 {
    mv.map_or(1.0, |mv| mv.reach + crate::cl::max_f32(0.0, mv.slide))
}

/// port: cpu-mcts.lisp MC-PTR — a pointer clamped to the three NS (1-3).
pub fn mc_ptr(ptr: i64) -> i64 {
    1.max(3.min(ptr))
}

/// port: STRAT-FEATS — the strategies' cues for E seeing SNAP S at distance D, pushed on OUT (relative to the kits).
pub fn strat_feats_into(m: &Match, e: Entity, s: &Snap, d: f32, out: &mut Cues) {
    let (f, k) = (fighter(m, e), &m.knobs);
    let (kit, o) = (kit_of(m, e), f.opp);
    let okit = kit_of(m, o);
    let (g, go) = (m.gauges.get(e).expect("gauges"), m.gauges.get(o).expect("gauges"));
    let p = mc_ptr(f.ptr);
    let rj = strat_reach(kit_command_move(m.data, kit, "q"));
    let rn = strat_reach(kit_core_move(m.data, kit, Role::Ns, p));
    let ro = strat_reach(kit_command_move(m.data, okit, "q"));
    let mx = |r: f32| crate::cl::max_f32(0.5, r);
    out.push("dj", Num::F(d / mx(rj)));
    out.push("dn", Num::F(d / mx(rn)));
    out.push("do", Num::F(d / mx(ro)));
    out.push("lead", Num::I(g.konpaku - go.konpaku));
    out.push("mr", Num::F(g.reishi.f() / g.reishi_max as f32));
    out.push("or", Num::F(go.reishi.f() / go.reishi_max as f32));
    out.push("ored", Num::I(gauges_red_p(k, go) as i64));
    out.push("hoho", Num::I(hoho_ready_p(m, e) as i64));
    let ost = match s.state {
        State::Idle | State::Run | State::Guard => 0,
        State::Move => {
            if s.mv.is_some() && s.sf < s.s {
                1
            } else {
                2
            }
        }
        State::Step | State::Hoho => 3,
        _ => 4,
    };
    out.push("ost", Num::I(ost));
    let wave = kit.core.ns_range.as_ref().and_then(|v| v.get((p - 1) as usize).copied().flatten()).is_some();
    out.push("wave", Num::I(wave as i64));
    out.push("awk", Num::I(g.awakened as i64));
}

/// STRAT-FEATS as a fresh cue plist.
pub fn strat_feats(m: &Match, e: Entity, s: &Snap, d: f32) -> Cues {
    let mut c = Cues::default();
    strat_feats_into(m, e, s, d, &mut c);
    c
}

/// port: STRAT-FORM-INDEX — F's form as a cue: 0 the base form, 2 Hisagi's bind mode, 1 any other.
pub fn strat_form_index(form: Form) -> i64 {
    match form {
        Form::Base => 0,
        Form::BankaiBind => 2,
        _ => 1,
    }
}

/// port: STRAT-XFEATS — a Q selector's extra cues (its :XFEATS), pushed on OUT: :DM, :FORM, :OAWK, :GAUGE, :WALL, the SP cues, :RB-SP2's.
pub fn strat_xfeats(m: &Match, e: Entity, s: &Snap, d: f32, out: &mut Cues) {
    let (f, k) = (fighter(m, e), &m.knobs);
    let o = f.opp;
    let fo = fighter(m, o);
    let (g, go) = (m.gauges.get(e).expect("gauges"), m.gauges.get(o).expect("gauges"));
    let p = pos_of(m, e);
    let (x, z) = (p[0], p[2]);
    out.push("dm", Num::F(d));
    out.push("form", Num::I(strat_form_index(f.form)));
    out.push("oawk", Num::I(go.awakened as i64));
    out.push("gauge", Num::F(if g.awakened { g.drive / k.drive_max } else { g.sub / k.sub_max }));
    out.push("wall", Num::F(k.arena_radius - libm::sqrtf(x * x + z * z)));
    strategy::strat_sp_cues(g.fs, go.fs, g.burst.is_some(), go.burst.is_some(), f.xch, fo.xch, k.fs_cell, out);
    let owall = k.arena_radius - libm::sqrtf(s.x * s.x + s.z * s.z);
    let swopen = crate::gauges::aw_full_p(k, g);
    let (ptr, optr) = (strat_hud_ptr(k, f), strat_hud_ptr(k, fo));
    strategy::strat_sp2_cues(awaken_ready_p(m, e), g.awakened, owall, m.timer, 60 * k.match_seconds, ptr, optr, swopen, out);
}

/// port: STRAT-HUD-PTR — F's SP pointer as his plate shows it: a DRIVE switch's target while it runs, else his pointer.
pub fn strat_hud_ptr(k: &Knobs, f: &crate::components::Fighter) -> i64 {
    core_clamp_pointer(k, if f.tmp > 0 && f.state == State::Move { f.tmp } else { f.ptr })
}

/// STRAT-OUT over brain B's NOW: the active strategy's KEY (an integer stays one), or None.
pub fn strat_out(k: &Knobs, b: &Brain, key: &str) -> Option<Num> {
    strategy::strat_out(&k.fz_sets, b.now.as_ref(), key, None)
}

/// port: STRAT-HOLD-AWAKEN-P — E's active strategy's :HOLD-AWAKEN H: E keeps from awakening while its SUBLIMATION is below H of its
/// maximum. B is E's brain, `(brain e)` (taken out of its fighter while the CPU steps, so the caller passes it); none: NIL.
pub fn strat_hold_awaken_p(m: &Match, e: Entity, b: Option<&Brain>) -> bool {
    let h = b.and_then(|b| strat_out(&m.knobs, b, "hold-awaken"));
    h.is_some_and(|h| (m.gauges.get(e).unwrap().sub / m.knobs.sub_max) < h.f())
}

// ---------------------------------------------------------------- style knobs (§11.6): what the style CPUs read (Tasks 6-7)

/// port: STYLE-KNOB — brain B's style tunable KEY: the active strategy's value, else DEFAULT (the style's own).
pub fn style_knob(k: &Knobs, b: &Brain, key: &str, default: Num) -> Num {
    strat_out(k, b, key).unwrap_or(default)
}

/// port: STYLE-DIF — STYLE-KNOB over the per-difficulty PLIST: the arm's KEY replaces PLIST's value at B's difficulty (an integer
/// token stays one: `*iks-ns-wait*` 32).
pub fn style_dif(k: &Knobs, b: &Brain, key: &str, plist: &KwNums) -> Num {
    style_knob(k, b, key, plist.chance(b.difficulty))
}

/// port: STYLE-ROLL — a CHANCE-ROLL of the per-difficulty chance PLIST, the arm's KEY replacing its value.
pub fn style_roll(m: &mut Match, b: &Brain, key: &str, plist: &KwNums) -> bool {
    let p = style_dif(&m.knobs, b, key, plist);
    chance_roll(m, p.f())
}

/// port: STYLE-ON — a per-difficulty switch as the arm's number KEY (on at >= 0.5); no key: ON, the switch's value at B's
/// difficulty (the caller's BRAIN-CHANCE of its plist).
pub fn style_on(k: &Knobs, b: &Brain, key: &str, on: bool) -> bool {
    strat_out(k, b, key).map_or(on, |x| x.f() >= 0.5)
}

// ---------------------------------------------------------------- the composite / Q selector's judgement

/// port: STRAT-WINDOW-STEP — the lookup table's windows: at a window's first step, one roll of the difficulty's table chance decides
/// whether the Q selector SW plays it or its none arm (BRAIN-TW-OFF); only for a chance strictly between 0 and 1.
fn strat_window_step(m: &mut Match, b: &mut Brain, sw: Strat) {
    let p = m.knobs.strat_table_chance.chance(b.difficulty);
    if sw.fq().is_some() && 0.0 < p && p < 1.0 {
        let w = floor_div(m.match_tick, m.knobs.strat_table_window);
        if w != b.tw {
            b.tw = w;
            let off = !chance_roll(m, p);
            if off != b.tw_off {
                (b.tw_off, b.sw_t) = (off, -1);
            }
        }
    }
}

/// The style a strategy's :FN names (a name no style has: the Lisp's SYMBOL-FUNCTION error).
fn fn_of(st: Strat) -> Option<StyleId> {
    st.get("fn").map(|v| {
        let n = v.as_str().expect("a :fn name");
        StyleId::of(n).unwrap_or_else(|| panic!("no style function {n}"))
    })
}

/// STRAT-SWITCH-STEP's cues for a judgement of SW: a Q selector's `:prev` (the position of SUB, the previous arm, among its arms; NIL
/// finds a NIL arm; none: 0), then STRAT-FEATS, then its :XFEATS' (STRAT-XFEATS).
pub fn judge_feats(m: &Match, e: Entity, s: &Snap, d: f32, sw: Strat, sub: Option<Strat>) -> Cues {
    let mut feats = Cues::default();
    if let Some(fq) = sw.fq() {
        let arms = fq.get("arms").and_then(Value::as_array).map_or(&[][..], |a| a.as_slice());
        let prev = match sub {
            Some(st) => arms.iter().position(|a| std::ptr::eq(a, st.0)),
            None => arms.iter().position(Value::is_null),
        };
        feats.push("prev", Num::I(prev.map_or(0, |p| p as i64)));
    }
    strat_feats_into(m, e, s, d, &mut feats);
    if sw.fq().is_some_and(|q| strategy::plist_get(q, "xfeats").is_some()) {
        strat_xfeats(m, e, s, d, &mut feats); // (its extra cues, §8.19)
    }
    feats
}

/// port: STRAT-SWITCH-STEP — the active sub of the composite or Q selector SW for brain B: judged on the match's first step and every
/// period (the table's :PERIOD, else *strat-switch-period*) in neutral, else held. Counts the judgements (BRAIN-SW-N / -WON).
pub fn strat_switch_step(m: &mut Match, e: Entity, b: &mut Brain, s: &Snap, d: f32, sw: Strat) -> Option<Strat> {
    strat_window_step(m, b, sw);
    let fq = sw.fq();
    let period = fq.and_then(|q| strategy::plist_get(q, "period")).and_then(Value::as_i64).unwrap_or(m.knobs.strat_switch_period);
    let state = fighter(m, e).state;
    if !(b.sw_t < 0 || (matches!(state, State::Idle | State::Run) && m.match_tick - b.sw_t >= period)) {
        return b.sw_sub;
    }
    b.sw_t = m.match_tick;
    let arms: &'static [Value] = fq.and_then(|q| strategy::plist_get(q, "arms")).and_then(Value::as_array).map_or(&[], |a| a.as_slice());
    let (sub, i) = if b.tw_off {
        (None, arms.iter().position(Value::is_null).map_or(-1, |p| p as i64)) // (the window's none arm)
    } else {
        let feats = judge_feats(m, e, s, d, sw, b.sw_sub);
        // (*strat-judge-hook*: a tool's, NIL in the game)
        let judged = strategy::strat_judge(&m.knobs.fz_sets, sw, feats.as_slice());
        // (the online fuzzy Q's exploration and record, FQ-EXPLORE / FQ-NOTE, outside rollouts when the brain learns: Task 9)
        if fq.is_some()
            && !m.in_rollout
            && let Some(x) = b.fql
        {
            match x {}
        }
        judged
    };
    let st = sub.or_else(|| {
        // (a Q selector's NIL arm: no strategy, never the lookup)
        if fq.is_some() {
            return None;
        }
        let f = fighter(m, e);
        let vs = fighter(m, f.opp).character?;
        strategy::strat_lookup(m.data, &m.knobs, f.character?, vs, b.difficulty)
    });
    let fid = match st {
        Some(st) => fn_of(st),
        None => cai_style_fn(m, e),
    };
    if let Some(fid) = fid
        && Some(fid) != b.sw_fn
    {
        // (another style function takes over: its own state, not the last one's struct)
        if fq.is_some_and(|q| strategy::plist_get(q, "keep-state").is_some()) {
            if let Some(old) = b.sw_fn {
                match b.sw_keep.0.iter_mut().find(|c| c.0 == old) {
                    Some(c) => c.1 = b.style,
                    None => b.sw_keep.0.insert(0, (old, b.style)),
                }
            }
            b.style = b.sw_keep.0.iter().find(|c| c.0 == fid).and_then(|c| c.1);
            b.style_live = b.style.is_some(); // (the kept object itself: EQ to its entry from now on)
        } else if b.sw_fn.is_some() {
            (b.style, b.style_live) = (None, false);
        }
        b.sw_fn = Some(fid);
    }
    b.sw_sub = sub;
    if !m.in_rollout {
        // (the counts: outside rollouts only)
        let n = if fq.is_some() { arms.len() } else { sw.get("switch").and_then(Value::as_array).map_or(0, |a| a.len()) };
        let won = b.sw_won.get_or_insert_with(|| Won::new(n));
        b.sw_n += 1;
        if i >= 0 {
            won.v[i as usize] += 1;
        }
    }
    b.sw_sub
}

/// port: core-ai.lisp CAI-STYLE-FN — E's matchup style against his opponent (`*cai-styles*`), or NIL.
pub fn cai_style_fn(m: &Match, e: Entity) -> Option<StyleId> {
    if m.styles_off {
        return None; // (MC-FULL-ROLLOUT binds *cai-styles* to NIL)
    }
    let f = fighter(m, e);
    m.knobs.cai_styles.get(f.character?, fighter(m, f.opp).character?)
}

// ---------------------------------------------------------------- the event layer (§8.19 round 5 step 6)

/// port: STRAT-EVENT-STEP — the event arm that plays this step for brain B under the Q selector SW, else NIL; counts the takeovers.
pub fn strat_event_step(m: &Match, b: &mut Brain, s: &Snap, sw: Strat) -> Option<Strat> {
    let fq = sw.fq().expect("a Q selector");
    let (on, last) = strategy::strat_event_arm(fq, s.state, m.match_tick, b.ev_t, b.delay, m.knobs.strat_event_grace);
    b.ev_t = last;
    if !m.in_rollout {
        if on.is_some() && b.ev_on.is_none() {
            b.ev_n += 1;
        }
        if on.is_some() {
            b.ev_steps += 1;
        }
    }
    b.ev_on = on.map(Strat);
    b.ev_on
}

/// port: STRAT-EVENT-CALL — run the event arm's style F with its own state in BRAIN-STYLE (BRAIN-EV-STYLE), then put the table's back.
pub fn strat_event_call(m: &mut Match, s: &mut Search, f: StyleFn, e: Entity, b: &mut Brain, snap: Snap, d: f32) -> bool {
    let mine = std::mem::replace(&mut b.style, b.ev_style);
    let live = std::mem::take(&mut b.style_live); // (the event arm's struct is never a kept one)
    let r = f(m, s, e, b, snap, d);
    b.ev_style = std::mem::replace(&mut b.style, mine);
    b.style_live = live;
    r
}

/// The :FN clause of CORE-BRAIN-STEP: the active strategy's own tactics (its style), through the event arm's state when EV. T when
/// it decided; a style not ported yet stops the replay (`style <NAME>`).
pub fn strat_fn_step(m: &mut Match, s: &mut Search, e: Entity, b: &mut Brain, snap: Snap, d: f32, ev: bool) -> bool {
    let Some(fid) = b.now.as_ref().and_then(|n| fn_of(n.st)) else { return false };
    if ev && let Some(f) = style::resolve(fid.name()) {
        return strat_event_call(m, s, f, e, b, snap, d);
    }
    style::run(m, s, fid, e, b, snap, d)
}

// ---------------------------------------------------------------- the strategy layer (§5, §8.4; off: *strat-layer* NIL)

/// port: STRAT-LAYER-P — is E's CPU under the strategy layer? (*strat-layer* T; a list or a seat fails the knob's load.)
pub fn strat_layer_p(m: &Match) -> bool {
    m.knobs.strat_layer
}

/// port: BRAIN-SET-STRAT! — the strategy layer gives brain B strategy ST; another strategy than his starts its per-strategy state afresh.
pub fn brain_set_strat(b: &mut Brain, st: Option<Strat>) {
    if st != b.strat {
        (b.strat, b.style, b.style_live, b.sw_fn, b.sw_sub, b.sw_t) = (st, None, false, None, None, -1);
        b.sw_keep.0.clear();
        (b.sw_n, b.sw_won, b.ev_style, b.ev_on, b.ev_t) = (0, None, None, None, -1);
    }
}

/// port: STRAT-REQUEST — a selection for E: its arms seeded, a job queued; with no strategy yet, the seeds' and the prior's pick at once.
pub fn strat_request(m: &mut Match, s: &mut Search, e: Entity, b: &mut Brain, snap: &Snap, d: f32) {
    let f = fighter(m, e);
    let (Some(me), Some(vs), side) = (f.character, fighter(m, f.opp).character, f.side) else { return };
    let (dif, k) = (b.difficulty, &m.knobs);
    let (mine, his) = (strategy::strat_arms(m.data, me, vs), strategy::strat_arms(m.data, vs, me));
    let feats = strat_feats(m, e, snap, d);
    let p: Vec<f32> = mine.iter().map(|&st| strategy::strat_prior(&k.fz_sets, st, feats.as_slice())).collect();
    let ptot = p.iter().fold(0.0f32, |a, x| a + x); // ((reduce #'+ p): 0.0 + the first is the first)
    let prior: Vec<f32> = p.iter().map(|x| x / ptot).collect();
    let n0 = k.strat_n0;
    let seed = |a, b, st: &Strat| n0 as f32 * strategy::strat_seed_value(m.data, a, b, st.id().unwrap_or(""));
    let ns = vec![n0 as f32; mine.len()];
    let sums: Vec<f32> = mine.iter().map(|st| seed(me, vs, st)).collect();
    let hns = vec![n0 as f32; his.len()];
    let hsums: Vec<f32> = his.iter().map(|st| seed(vs, me, st)).collect();
    let hprior = vec![1.0 / 1.max(his.len()) as f32; his.len()];
    if b.strat.is_none() {
        let a = strategy::strat_final(&sums, &ns, &prior, k.strat_lambda.get_or(dif.name(), 0.35));
        brain_set_strat(b, mine.get(a).copied());
    }
    s.strat_jobs.push(StratJob { e, side, dif, mine, his, prior, sums, ns, hsums, hns, hprior, n: 0, snap: None, rng: 0 });
    s.strat_stats[0] += 1;
}

/// port: STRAT-LAYER-STEP — in CORE-BRAIN-STEP, outside rollouts: a selection when he is free and one is due (the period is over, or he
/// comes back to neutral after *strat-regain* steps out of it) and none of his is running.
pub fn strat_layer_step(m: &mut Match, s: &mut Search, e: Entity, b: &mut Brain, snap: &Snap, d: f32) {
    let f = fighter(m, e);
    if !(strat_layer_p(m) && !m.in_rollout && matches!(f.state, State::Idle | State::Run)) {
        return;
    }
    let side = f.side;
    let t = m.match_tick;
    if (t >= b.st_next || t - b.st_free > m.knobs.strat_regain) && !s.strat_jobs.iter().any(|j| j.side == side) {
        b.st_next = t + m.knobs.strat_period;
        strat_request(m, s, e, b, snap, d);
    }
    b.st_free = t;
}

/// port: STRAT-ROLL — the oldest selection's next rollout from its snapshot: both arms by their PUCT, both CPUs on them (a stand-in
/// brain for a brainless opponent), `*strat-h*` lean steps. Returns his arm, the opponent's and the 0-1 score; records nothing.
pub fn strat_roll(s: &mut Search, live_tick: i64) -> (usize, usize, f32) {
    let j = &s.strat_jobs[0];
    let c = j.snap.as_ref().expect("a selection's snapshot").0.knobs.strat_c;
    let (e, dif, rng) = (j.e, j.dif, j.rng);
    let i = strategy::strat_puct(&j.sums, &j.ns, &j.prior, c);
    let k = strategy::strat_puct(&j.hsums, &j.hns, &j.hprior, c);
    let (mine, his) = (j.mine[i], j.his[k]);
    let snap = s.strat_jobs[0].snap.take().unwrap();
    let (mut sc, o) = super::mcts::rollout_start(s, &snap.0, rng, e, dif);
    s.strat_jobs[0].snap = Some(snap);
    let r = &mut *sc.0;
    for (x, st) in [(e, mine), (o, his)] {
        brain_set_strat(r.fighter.get_mut(x).unwrap().brain.as_mut().expect("a brain"), Some(st));
    }
    let (h, swing) = (r.knobs.strat_h, r.knobs.strat_swing);
    let sw = super::mcts::mc_full_rollout(r, s, e, o, h, dif, false);
    super::mcts::rollout_end(s, sc, live_tick);
    (i, k, max_f32(0.0, min_f32(1.0, 0.5 + sw / (2.0 * swing))))
}

/// port: STRAT-FULL-STEP — one rollout of the oldest selection (MC-FULL-STEP, when no action rollout is due); its first takes the
/// live state as its start. After `*strat-rolls*` the pick goes into his brain (the live one: the rollout never touched it).
pub fn strat_full_step(m: &mut Match, s: &mut Search) {
    if !super::mcts::sim_snapshot_ok_p(m) {
        s.drop_strat_jobs(); // (a cinematic, the match's end: asked again on coming back)
        return;
    }
    let t0 = (s.clock)();
    if s.strat_jobs[0].snap.is_none() {
        let slot = s.snapshot(m);
        (s.strat_jobs[0].snap, s.strat_jobs[0].rng) = (Some(slot), m.rng.state());
    }
    let (i, k, v) = strat_roll(s, m.match_tick);
    s.strat_stats[1] += 1;
    let j = &mut s.strat_jobs[0];
    j.sums[i] += v;
    j.ns[i] += 1.0;
    j.hsums[k] += 1.0 - v;
    j.hns[k] += 1.0;
    j.n += 1;
    if j.n >= m.knobs.strat_rolls {
        let j = s.strat_jobs.remove(0);
        let a = strategy::strat_final(&j.sums, &j.ns, &j.prior, m.knobs.strat_lambda.get_or(j.dif.name(), 0.35));
        let d = m.data;
        if let Some(b) = m.fighter.get_mut(j.e).and_then(|f| f.brain.as_mut()) {
            brain_set_strat(b, j.mine.get(a).copied());
            let id = b.strat.and_then(|st| st.id()).expect("a library strategy");
            let pos = strategy::strat_library_pos(d, id).expect("in the library");
            s.strat_picks[strategy::strat_library_len(d) * j.side as usize + pos] += 1;
        }
        s.give_back(j.snap);
    }
    let dt = (s.clock)().saturating_sub(t0) as i64;
    s.strat_stats[2] += dt;
    s.strat_stats[3] = s.strat_stats[3].max(dt);
}

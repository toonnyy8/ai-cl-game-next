//! port: ichigo.lisp's hook functions (the kits' :hooks, the moves' frame / land hooks), his :tick (the stance, the parry from blockstun
//! and its tell, the afterimage watch, the clones' replay watch, O's charge, the pacing log's ICS slots). The EMITs are looks; PACE /
//! IC-KEY are the gate's debug counters (not in B: not ported).
use super::clones::*;
use crate::components::{Button, Contact, Difficulty, Form, HzData, Phase, State, Sym};
use crate::ecs::Entity;
use crate::fighter::{
    callout, fighter, fighter_mut, id_of, kit_command_ok_p, kit_of, mv, opp_of, pos_of, set_slide, side_name, start_move,
    turn_to_opp, yaw_of,
};
use crate::math::{dir_yaw, hypot};
use crate::rules::{contact_of, Res};
use crate::state::Match;
use crate::vpad::Mod;

/// port: MOVE-PARAM (the hooks' reader): E's current move's :params.
pub fn move_param(m: &Match, e: Entity) -> &'static duel_data::moves::Params {
    &mv(m, fighter(m, e).mv.expect("a hook's move")).params
}

/// port: PULL-OPP-TO: ATT's opponent dragged toward him to D metres over FRAMES (his slide replaced); T when he was farther.
pub fn pull_opp_to(m: &mut Match, att: Entity, d: f32, frames: i64) -> bool {
    let v = opp_of(m, att);
    let (p, q) = (pos_of(m, att), pos_of(m, v));
    let (dx, dz) = (p[0] - q[0], p[2] - q[2]);
    let dist = hypot(dx, dz);
    if dist > d {
        set_slide(m, v, dist - d, frames, dx, dz); // look: emit :sfx :chain-snap
        return true;
    }
    false
}

/// port: GG-SPEND!: E spends N of the guard gauge (the regen waits again; never guardless by it).
fn gg_spend(m: &mut Match, e: Entity, n: f32) {
    let g = m.gauges.get_mut(e).unwrap();
    (g.gg, g.gg_idle) = (crate::cl::max_f32(0.0, g.gg - n), 0);
}

/// port: IC: E's ICS, attached on the first call (a new fighter entity starts fresh).
pub fn ic(m: &mut Match, e: Entity) {
    if !m.ics.has(e) {
        m.ics.insert(e, Default::default());
    }
}

// ---------------------------------------------------------------- the kits' typed hooks

/// port: ICHIGO-HIT (both forms' :hit): a clone's hit tells its clone what it did (its string's gate and its fate); a replayed hit
/// carries his move's effects. HAZARD: the hazard that dealt it (its struct even if destroyed this HIT-APPLY).
pub fn hit(m: &mut Match, att: Entity, def: Entity, res: Res, hazard: Option<Entity>) {
    // pace: GETSUGA-WAVE / JUJI-WAVE by contact
    let Some(HzData::Icc(c)) = hazard.and_then(|h| m.hazard_of(h)).map(|hz| hz.data.clone()) else { return };
    let Some(ct) = contact_of(Some(res)) else { return };
    let cc = &mut m.iccs[c]; // pace: CLONE contact
    (cc.hit, cc.touched) = (Some(ct), true);
    if cc.state == IccState::Replay && ct == Contact::Hit {
        clone_replay_hit(m, att, def, c);
    }
    crate::clog!(m, "{} clone {}", side_name(m, att), crate::combat::res_name(res));
}

/// port: ICHIGO-STRUCK (both forms' :struck): a real hit clears his clones and afterimages; in PRACTICE a missed parry says EARLY /
/// LATE.
pub fn struck(m: &mut Match, def: Entity, _att: Entity, res: Res) {
    if !clone_vanish_p(Some(res)) {
        return;
    }
    vanish(m, def);
    if m.mode == crate::state::Mode::Practice && fighter(m, def).form == Form::Kessa {
        ic(m, def);
        let psf = m.ics.get(def).unwrap().parry_sf;
        let held = m.pilot.get(def).expect("a pilot").vpad.held_for(Button::Sig as usize);
        if psf >= 25 {
            callout(m, def, "EARLY");
        } else if (0..=1).contains(&psf) || (1..=3).contains(&held) {
            callout(m, def, "LATE");
        }
    }
}

/// port: ICHIGO-OK (KESSA's :ok): L (the parry) wants *KESSA-PARRY-COST* of the guard gauge and not guardless; SP2 is refused while
/// ZANZO runs. CMD: the kit command's name (`q`, `sig`, `sp2`, …).
pub fn ok(m: &Match, e: Entity, cmd: &str) -> bool {
    let g = m.gauges.get(e).unwrap();
    match cmd {
        "sig" => !g.guardless && g.gg >= m.knobs.kessa_parry_cost,
        "sp2" => !zanzo_p(m, e),
        _ => true,
    }
}

/// port: ICHIGO-CATCH (KESSA's :parried): +*KESSA-PARRY-CATCH* guard gauge, the staggered attacker held *KESSA-PARRY-STUN*, a 12 f
/// hitstop, 0.3 s of slow motion.
pub fn catch(m: &mut Match, e: Entity, att: Entity) {
    let (mx, add) = (m.knobs.gg_max, m.knobs.kessa_parry_catch);
    let g = m.gauges.get_mut(e).unwrap();
    (g.gg, g.gg_idle) = (crate::cl::min_f32(mx, g.gg + add), 0);
    let st = m.knobs.kessa_parry_stun;
    let fa = fighter_mut(m, att);
    if fa.state == State::Stun {
        fa.stun = st;
    }
    m.time.hitstop(12.0);
    m.time.slowmo(0.4, 0.3, false); // look: ui-flash, emit :sfx :parry-ting / :chain-snap
    let gg = crate::cl::round_f32(m.gauges.get(e).unwrap().gg);
    crate::clog!(m, "{} PARRY CATCH gg {}", side_name(m, e), gg);
}

/// port: ICHIGO-KIKON-WORTH (KESSA's :kikon-worth): what 千影 would take if O were pressed now.
pub fn kikon_worth(m: &mut Match, e: Entity) -> i64 {
    let n = clone_count(m, e);
    clone_konpaku(&m.knobs.clone_konpaku.0, n)
}

// ---------------------------------------------------------------- the moves' frame / land hooks

/// port: ICHIGO-JUJI-FIRST: JUJISHO f12: the long blade's crescent forms on the edge (a look hazard; the wave is f20's).
pub fn juji_first(m: &mut Match, e: Entity) {
    let (x, z) = ahead(m, e, 1.0);
    let yaw = yaw_of(m, e);
    crate::hazards::spawn_look(m, e, Sym("ICHIGO-FORM-LOOK"), Some(x), Some(z), yaw, 1.8, 10, 0, HzData::Nil); // look: emit :sfx
}

/// port: ICHIGO-HASTE-DASH: NUKI-GIRI's f0: facing him, a dash 0.8 m past him over 12 frames.
pub fn haste_dash(m: &mut Match, e: Entity) {
    let d = crate::cl::min_f32(6.0, fighter(m, e).dist + 0.8);
    let (s, c) = crate::math::sincosf(yaw_of(m, e)); // (FWD-X / FWD-Z of one yaw: gcc's fused sincosf)
    set_slide(m, e, d, 12, -s, -c); // look: emit :sfx
}

/// port: ICHIGO-RENZAN: KAGE-RENZAN's Nth cut: a strike with HWMOVE's window thrown from where he stands at the opponent, a slash on him.
pub fn renzan(m: &mut Match, e: Entity, hwmove: &str, n: i64) {
    let (p, q) = (pos_of(m, e), pos_of(m, opp_of(m, e)));
    let hw = &crate::kit::find_move(m.data, hwmove).expect("a renzan move").hits[0];
    strike(m, e, p[0], p[2], dir_yaw(q[0] - p[0], q[2] - p[2]), hw, 1.0, HzData::Kw(Sym(":RENZAN")), StrikeSp::None);
    crate::hazards::spawn_look(m, e, Sym("ICHIGO-RENZAN-LOOK"), Some(q[0]), Some(q[2]), 0.0, 1.0, 9, 0, HzData::Int(n));
}

/// port: ICHIGO-PARRY-OPEN: KUSARI-TATE f0: its price, the chains flaring (a look hazard).
pub fn parry_open(m: &mut Match, e: Entity) {
    let c = m.knobs.kessa_parry_cost;
    gg_spend(m, e, c);
    let yaw = yaw_of(m, e);
    crate::hazards::spawn_look(m, e, Sym("ICHIGO-FLARE-LOOK"), None, None, yaw, 1.0, 18, 0, HzData::Nil);
}

/// port: ICHIGO-TSUKI-DASH: TSUKIWATARI f0: 3.5 m in the stick direction (neutral: at him; a brain's: at him) over 12 f, iframes 9.
pub fn tsuki_dash(m: &mut Match, e: Entity) {
    let (to, st) = if fighter(m, e).has_brain() { (1.0, 0.0) } else { crate::fighter::stick_relative(m, e) };
    if m.unported.is_some() {
        return;
    }
    let (to, st) = crate::rules::step_direction(to, st, 1.0);
    let (dx, dz) = crate::fighter::world_dir(m, e, to, st);
    set_slide(m, e, 3.5, 12, dx, dz);
    fighter_mut(m, e).invuln = 9; // look: emit :hoho-out, :sfx
}

/// port: ICHIGO-TSUKI-RETURN: TSUKIWATARI f11: back in the stance, a fresh window.
pub fn tsuki_return(m: &mut Match, e: Entity) {
    let n = crate::kit::kit_next(m.data, kit_of(m, e), "ic-tsuki-dash", "tsuki-back").expect("the stance's re-entry");
    let id = id_of(m, n);
    start_move(m, e, id, None);
}

// ---------------------------------------------------------------- the Shikai's stance

/// port: TSUKI-PRESSED: the stance's follow-up a human pressed (buffered, unmodified), with its button.
fn tsuki_pressed(m: &Match, e: Entity) -> Option<(&'static str, Button)> {
    let vp = &m.pilot.get(e).expect("a pilot").vpad;
    [("tsuki-j", Button::Quick), ("tsuki-k", Button::Flash), ("tsuki-l", Button::Sig), ("tsuki-step", Button::Step)]
        .into_iter()
        .find(|&(_, b)| vp.command_pressed_p(b as usize, Mod::No))
}

/// port: ICHIGO-AI-STANCE: the CPU's branch at the stance's f6 (sim state only: the opponent's state, the distance, the gauges; one draw).
fn ai_stance(m: &mut Match, e: Entity) -> &'static str {
    let o = opp_of(m, e);
    let (fo, d, r) = (fighter(m, o).state, fighter(m, e).dist, m.rng.rnd01());
    let dash = !m.ics.get(e).unwrap().dashed && m.gauges.get(e).unwrap().fs >= m.knobs.tsuki_dash_fs;
    if matches!(fo, State::Stun | State::Air) {
        if r < 0.5 { "tsuki-j" } else if r < 0.8 { "tsuki-k" } else { "tsuki-l" }
    } else if d <= 4.2 {
        if matches!(fo, State::Guard | State::GuardHit) || m.gauges.get(o).unwrap().gg < 50.0 {
            if r < 0.6 { "tsuki-k" } else { "tsuki-j" }
        } else if r < 0.7 {
            "tsuki-j"
        } else {
            "tsuki-k"
        }
    } else if d <= 6.4 {
        if dash && r < 0.5 { "tsuki-step" } else { "tsuki-k" }
    } else if dash && d <= 7.5 && r < 0.6 {
        "tsuki-step"
    } else {
        "tsuki-l" // ((getsuga t): the (dash :tsuki-step) clause after it is never reached)
    }
}

/// port: TSUKI-STEP: one step of the stance: it re-aims; from f6 the first J / K / L / Step fires its branch (a CPU's picked once at
/// f6); past the hold (30 f, 60 while L is held) it recovers.
fn tsuki_step(m: &mut Match, e: Entity, mvname: &str) {
    let sf = fighter(m, e).sf;
    turn_to_opp(m, e, crate::rules::track_step(360.0));
    let (up, tap, max) = (m.knobs.tsuki_up, m.knobs.tsuki_tap, m.knobs.tsuki_max);
    let b = fighter(m, e).has_brain();
    if sf >= up {
        let cmd = if b {
            (sf == up).then(|| ai_stance(m, e)).map(|c| (c, Button::Quick))
        } else {
            tsuki_pressed(m, e)
        };
        let ok = match cmd {
            Some(("tsuki-step", _)) => {
                !m.ics.get(e).unwrap().dashed && m.gauges.get(e).unwrap().fs >= m.knobs.tsuki_dash_fs
            }
            Some(_) => true,
            None => false,
        };
        if let Some((cmd, button)) = cmd.filter(|_| ok) {
            if !b {
                m.pilot.get_mut(e).unwrap().vpad.consume(button as usize);
            }
            if cmd == "tsuki-step" {
                let c = m.knobs.tsuki_dash_fs;
                crate::fighter::spend_fs(m, e, c);
                m.ics.get_mut(e).unwrap().dashed = true;
            }
            let n = crate::kit::kit_next(m.data, kit_of(m, e), mvname, cmd).expect("a stance branch");
            let id = id_of(m, n);
            start_move(m, e, id, None);
            return;
        }
    }
    let held = m.pilot.get(e).unwrap().vpad.down(Button::Sig as usize);
    if up + tap <= sf && sf < up + max && !held {
        fighter_mut(m, e).sf = up + max;
    }
}

// ---------------------------------------------------------------- KESSA: the parry from blockstun, its tell

/// port: IC-P — a chance by difficulty DIF: EASY <= NORMAL <= HARD.
fn ic_p(dif: Difficulty, easy: f32, normal: f32, hard: f32) -> f32 {
    match dif {
        Difficulty::Easy => easy,
        Difficulty::Hard => hard,
        Difficulty::Normal => normal,
    }
}

/// PARRY-FROM-BLOCKSTUN's CPU part: on a new blockstun, after his blocked K link (*AI-IC-PARRY-BS-P* by difficulty) or a J masher's
/// blocked J (HARD 0.6), the frame that puts his next hit in the parry window; L pressed on it. The brain sits on its fighter here
/// (FIGHTER-SYSTEM); the masher and a switched-off brain get no help.
fn cpu_parry_from_blockstun(m: &mut Match, e: Entity) {
    let Some(b) = fighter(m, e).brain.as_ref().filter(|b| !b.off && !b.masher) else { return };
    let (dif, habit, mash) = (b.difficulty, b.habit.is_some(), crate::cpu::perceive::ai_mash_p(&m.knobs, b));
    let (sf, stun) = (fighter(m, e).sf, fighter(m, e).stun);
    let key = m.ics.get(e).unwrap().bs_key;
    if key < 0 || sf < key {
        // a new blockstun (a block restarts it at 0)
        m.ics.get_mut(e).unwrap().bs_at = -1;
        if let Some(om) = fighter(m, opp_of(m, e)).mv.map(|id| mv(m, id)) {
            let p = m.knobs.ai_ic_parry_bs_p;
            let go = (om.kind == "flash" && m.rng.rnd01() < ic_p(dif, 0.6 * p, p, 0.8))
                // v2: a J masher's blocked J: his next J lands in the window (EASY 0 / NORMAL 0 / HARD 0.6)
                || (om.kind == "quick" && !habit && mash && m.rng.rnd01() < ic_p(dif, 0.0, 0.0, 0.6));
            if go {
                m.ics.get_mut(e).unwrap().bs_at = 1.max(stun - 6);
            }
        }
    }
    let ics = m.ics.get_mut(e).unwrap();
    ics.bs_key = sf;
    if sf == ics.bs_at {
        ics.bs_at = -1;
        let b = fighter_mut(m, e).brain.as_mut().unwrap();
        crate::cpu::perceive::ai_press(b, Sym(":SIG"), 2, false, Sym(":SIG"));
    }
}

/// port: PARRY-FROM-BLOCKSTUN: in blockstun L starts the parry at once, under its price; a CPU presses it after a blocked K link
/// *AI-IC-PARRY-BS-P* of the time, on the frame that puts the string's next hit in the window.
fn parry_from_blockstun(m: &mut Match, e: Entity) {
    cpu_parry_from_blockstun(m, e);
    let vp = &m.pilot.get(e).expect("a pilot").vpad;
    if !vp.command_pressed_p(Button::Sig as usize, Mod::No)
        || !kit_command_ok_p(m, e, "sig", None)
        || crate::fighter::guard_locked_now_p(fighter(m, e))
    {
        return;
    }
    m.pilot.get_mut(e).unwrap().vpad.consume(Button::Sig as usize);
    let n = crate::kit::kit_command_move(m.data, kit_of(m, e), "sig").expect("KESSA's parry");
    let id = id_of(m, n);
    start_move(m, e, id, None);
    crate::clog!(m, "{} parry from blockstun", side_name(m, e));
}

/// port: PARRY-WATCH: the parry frame kept for the practice judge (ICHIGO-STRUCK); the window's white rim saves the model's rim (a look
/// value, in ICS: NIL but for a mirror's P2).
fn parry_watch(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    let mvd = crate::fighter::current_move(f).map(|id| mv(m, id));
    let inw = mvd.is_some_and(|x| x.flags.iter().any(|f| f == "parry")) && f.phase == Some(Phase::Main);
    let sf = f.sf;
    m.ics.get_mut(e).unwrap().parry_sf = if inw { sf } else { -1 };
    let win = mvd.and_then(|x| x.params.window).map(|[a, b]| (a as i64, b as i64));
    let st = m.ics.get(e).unwrap();
    if inw && crate::rules::parry_frame_p(&m.knobs, sf, win) {
        if !st.rim_saved {
            // (the model's rim, saved: SPAWN-FIGHTER's `:rim (and mirror *mirror-rim*)`, a mirror match's P2 (flow.lisp 103:
            // `:mirror (eq c1 c2)` on side 1); nothing else writes model-rim but this hook, which restores it)
            let mirror = fighter(m, m.p1).character == fighter(m, m.p2).character && fighter(m, e).side == 1;
            let rim = mirror.then_some(m.mirror_rim); // (tables.json, body.lisp's *mirror-rim*, read at load)
            let st = m.ics.get_mut(e).unwrap();
            (st.rim_saved, st.rim) = (true, rim); // look: model-rim = parry-rim
        }
    } else if st.rim_saved {
        m.ics.get_mut(e).unwrap().rim_saved = false; // look: model-rim restored
    }
}

/// port: IC-ACC-WATCH's ICS slots (the pacing log, on in a gate: START-CVC's *pacing-log*): each move instance of his and its contact,
/// the Kikons he took. (Its PACE counts are the gate's debug lines.)
fn acc_watch(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    let (mvid, sf, contact) = (crate::fighter::current_move(f), f.sf, f.contact);
    let kikons = m.gauges.get(e).unwrap().kikons;
    let st = m.ics.get_mut(e).unwrap();
    if st.acc_mv.is_some() && (mvid != st.acc_mv || sf < st.acc_sf) {
        st.acc_mv = None; // pace: NAME-HIT / -BLK / -WHF
    }
    if mvid.is_some() && st.acc_mv.is_none() {
        (st.acc_mv, st.acc_hit) = (mvid, None); // pace: the move (and the stance's distance)
    }
    if mvid.is_some() {
        st.acc_sf = sf;
        if let Some(c) = contact {
            st.acc_hit = Some(if c == Contact::Hit || st.acc_hit == Some(Contact::Hit) { Contact::Hit } else { Contact::Block });
        }
    }
    if kikons > st.acc_kikons {
        st.acc_kikons = kikons; // pace: KIKON form worth
    }
}

/// port: ICHIGO-TICK (both forms' :tick, every step after the hits): JUJISHO's cut; the Shikai's stance; KESSA's clones (their replay of
/// his J / AS; the O charge), the parry from blockstun and its tell, the afterimages.
pub fn tick(m: &mut Match, e: Entity) {
    ic(m, e);
    if m.pacing_log {
        acc_watch(m, e);
    }
    cut(m, e);
    let f = fighter(m, e);
    if f.form == Form::Kessa {
        let state = f.state;
        let mvid = f.mv.filter(|_| state == State::Move);
        hist_push(m, e);
        clone_replay_watch(m, e); // (the core system: the clones replay him; no press answers, no Step / Hoho clone)
        if mvid.is_some_and(|id| mv(m, id).kind == "kikon") {
            if !m.ics.get(e).unwrap().o_live {
                m.ics.get_mut(e).unwrap().o_live = true;
                o_press(m, e);
            }
        } else {
            m.ics.get_mut(e).unwrap().o_live = false;
        }
        if state == State::GuardHit {
            parry_from_blockstun(m, e);
            if m.unported.is_some() {
                return;
            }
        } else {
            m.ics.get_mut(e).unwrap().bs_key = -1;
        }
        parry_watch(m, e);
        if m.unported.is_some() {
            return;
        }
        echo_watch(m, e);
    } else {
        let name = crate::fighter::current_move(f).map(|id| mv(m, id).name.as_str());
        match name {
            Some(n @ ("ic-tsuki" | "ic-tsuki-k2" | "ic-tsuki-re")) => tsuki_step(m, e, n),
            Some("ic-tsuki-dash") => {}
            _ => m.ics.get_mut(e).unwrap().dashed = false,
        }
    }
}


#[cfg(test)]
mod tests {
    use super::*;
    use crate::components::{Character, Difficulty};

    /// A CPU match, Ichigo (P1) against Kenpachi, at the first battle step's state; P1's ICS attached.
    fn ik_battle() -> Match {
        let mut m = Match::new(crate::hashline::tests::data());
        crate::flow::go_title(&mut m);
        crate::gate::start_cvc(&mut m, 1, Some([Character::Ichigo, Character::Kenpachi]));
        let e = m.p1;
        ic(&mut m, e);
        m
    }

    /// ICHIGO-AI-STANCE's pick at the stance's f6, one draw: for each band (him reeling; within 4.2 m, him guarding, then free; to
    /// 6.4 m; beyond, within 7.5 m; beyond 7.5 m) a fixed roll below and above its thresholds picks the band's command.
    #[test]
    fn ai_stance_pick() {
        // (band setup, the roll's range, the command)
        type Setup = fn(&mut Match);
        // (a seed whose first draw falls in LO..HI: the fixed rolls at each band's edges)
        let seed_in = |lo: f32, hi: f32| {
            (1u32..)
                .find(|&s| {
                    let mut g = crate::rng::SimRng::default();
                    g.set_state(s);
                    (lo..hi).contains(&g.rnd01())
                })
                .unwrap()
        };
        let reel: Setup = |m| (fighter_mut(m, m.p2).state, fighter_mut(m, m.p1).dist) = (State::Stun, 3.0);
        let guard: Setup = |m| (fighter_mut(m, m.p2).state, fighter_mut(m, m.p1).dist) = (State::Guard, 3.0);
        let near: Setup = |m| fighter_mut(m, m.p1).dist = 4.2;
        let mid: Setup = |m| fighter_mut(m, m.p1).dist = 6.4;
        let far: Setup = |m| fighter_mut(m, m.p1).dist = 7.5;
        let away: Setup = |m| fighter_mut(m, m.p1).dist = 7.6;
        let cases: [(Setup, f32, f32, &str); 12] = [
            (reel, 0.0, 0.5, "tsuki-j"),
            (reel, 0.5, 0.8, "tsuki-k"),
            (reel, 0.8, 1.0, "tsuki-l"),
            (guard, 0.0, 0.6, "tsuki-k"),
            (guard, 0.6, 1.0, "tsuki-j"),
            (near, 0.0, 0.7, "tsuki-j"),
            (near, 0.7, 1.0, "tsuki-k"),
            (mid, 0.0, 0.5, "tsuki-step"),
            (mid, 0.5, 1.0, "tsuki-k"),
            (far, 0.0, 0.6, "tsuki-step"),
            (far, 0.6, 1.0, "tsuki-l"),
            (away, 0.0, 1.0, "tsuki-l"),
        ];
        for (setup, lo, hi, want) in cases {
            for s in [seed_in(lo, lo + 0.02), seed_in(hi - 0.02, hi)] {
                let mut m = ik_battle();
                setup(&mut m);
                m.rng.set_state(s);
                let mut g = m.rng;
                let x = g.rnd01();
                let e = m.p1;
                assert_eq!(ai_stance(&mut m, e), want, "r {x} in {lo}..{hi}");
                assert_eq!(m.rng, g, "one draw");
            }
        }
        // (no flash-step for the dash: the mid band's low roll takes TSUKI-OTOSHI)
        let mut m = ik_battle();
        mid(&mut m);
        m.gauges.get_mut(m.p1).unwrap().fs = 0.0;
        m.rng.set_state(seed_in(0.0, 0.5));
        let e = m.p1;
        assert_eq!(ai_stance(&mut m, e), "tsuki-k");
    }

    /// PARRY-FROM-BLOCKSTUN's CPU roll: on a new blockstun after his blocked K (a :flash move) one draw against *AI-IC-PARRY-BS-P* by
    /// difficulty (EASY its single-float x 0.6), the parry frame set 6 before the stun's end (at least 1) and L pressed on it; a J
    /// masher's blocked J draws too, a chance only at HARD; an old blockstun draws nothing; a switched-off brain gets no help.
    #[test]
    fn cpu_parry_roll_by_difficulty() {
        let d = crate::hashline::tests::data();
        let kind_move = |k: &str| crate::components::MoveId(d.moves.iter().position(|x| x.kind == k).unwrap() as u16);
        let p = crate::knobs::Knobs::from(d).unwrap().ai_ic_parry_bs_p;
        let mut seen = [[false; 2]; 3];
        for (i, (dif, chance)) in [(Difficulty::Easy, 0.6 * p), (Difficulty::Normal, p), (Difficulty::Hard, 0.8)].into_iter().enumerate() {
            for seed in (1u32..40).map(|k| k.wrapping_mul(0x9e37_79b9)) {
                let mut m = ik_battle();
                let (e, o) = (m.p1, m.p2);
                fighter_mut(&mut m, e).brain.as_mut().unwrap().difficulty = dif;
                fighter_mut(&mut m, o).mv = Some(kind_move("flash"));
                (fighter_mut(&mut m, e).sf, fighter_mut(&mut m, e).stun) = (0, 20);
                m.rng.set_state(seed);
                let mut g = m.rng;
                let go = g.rnd01() < chance;
                seen[i][go as usize] = true;
                cpu_parry_from_blockstun(&mut m, e);
                assert_eq!(m.rng, g, "one draw");
                let ics = m.ics.get(e).unwrap();
                assert_eq!((ics.bs_key, ics.bs_at), (0, if go { 14 } else { -1 }), "{dif:?} {seed}");
                // (the same blockstun on: no draw; on the parry frame L is pressed)
                fighter_mut(&mut m, e).sf = 14;
                cpu_parry_from_blockstun(&mut m, e);
                assert_eq!(m.rng, g, "no draw in an old blockstun");
                let b = fighter(&m, e).brain.as_ref().unwrap();
                if go {
                    assert_eq!((b.press, b.press_mod, b.press_left, b.act), (Some(Sym(":SIG")), false, 2, Some(Sym(":SIG"))));
                    assert_eq!(m.ics.get(e).unwrap().bs_at, -1);
                } else {
                    assert_eq!(b.press_left, 0);
                }
            }
        }
        assert_eq!(seen, [[true; 2]; 3], "both outcomes at each difficulty");
        // (a J masher's blocked J: a draw at every difficulty, a parry only at HARD; not a masher: no draw)
        for (dif, can) in [(Difficulty::Normal, false), (Difficulty::Hard, true)] {
            let mut hits = 0;
            for seed in (1u32..40).map(|k| k.wrapping_mul(0x9e37_79b9)) {
                let mut m = ik_battle();
                let (e, o) = (m.p1, m.p2);
                let n = m.knobs.ai_mash_starts as usize;
                let b = fighter_mut(&mut m, e).brain.as_mut().unwrap();
                b.difficulty = dif;
                b.jstarts = vec![0; n];
                fighter_mut(&mut m, o).mv = Some(kind_move("quick"));
                fighter_mut(&mut m, e).stun = 20;
                m.rng.set_state(seed);
                let mut g = m.rng;
                let go = g.rnd01() < if can { 0.6 } else { 0.0 };
                cpu_parry_from_blockstun(&mut m, e);
                assert_eq!((m.rng, m.ics.get(e).unwrap().bs_at), (g, if go { 14 } else { -1 }));
                hits += go as i32;
            }
            assert_eq!(hits > 0, can, "{dif:?}");
        }
        let mut m = ik_battle();
        let (e, o) = (m.p1, m.p2);
        fighter_mut(&mut m, o).mv = Some(kind_move("quick"));
        let g = m.rng;
        cpu_parry_from_blockstun(&mut m, e);
        assert_eq!(m.rng, g, "not a masher: no draw");
        fighter_mut(&mut m, o).mv = Some(kind_move("flash"));
        fighter_mut(&mut m, e).brain.as_mut().unwrap().off = true;
        m.ics.get_mut(e).unwrap().bs_key = -1;
        cpu_parry_from_blockstun(&mut m, e);
        assert_eq!((m.rng, m.ics.get(e).unwrap().bs_key), (g, -1), "brain off: nothing");
    }
}

//! port: duel/lisp/gauges.lisp — the fighters' gauges and what writes them outside a hit's own rules: the gains, heals and the
//! awakening gauge's fill, the guard gauge's drain, the bind's readers, Burst Reverse, forms / awakening / Kenpachi's Bankai, and
//! GAUGE-SYSTEM. Every function of gauges.lisp, same names snake-cased. Decisions are rules.rs'; the EMITs are looks (feedback).
use crate::cl::fmt_fixed_f32;
use crate::components::{Burst, Contact, Form, Gauges, KitId, Phase, State};
use crate::ecs::Entity;
use crate::fighter::{call_hook, fighter, fighter_mut, kit_hook_sym, kit_of, mv, opp_of, pos_of, respect, set_slide, side_name, state_of, to_idle};
use crate::knobs::Knobs;
use crate::rules;
use crate::state::Match;

fn g_of(m: &Match, e: Entity) -> &Gauges {
    m.gauges.get(e).expect("gauges")
}
fn g_mut(m: &mut Match, e: Entity) -> &mut Gauges {
    m.gauges.get_mut(e).expect("gauges")
}
fn f1(x: f32) -> String {
    fmt_fixed_f32(x, 1)
}

// ---------------------------------------------------------------- gains, heals, the bind

/// port: SIPHON-OF: the fighter taking E's gains now (the opponent's kit's :siphon hook), or NIL. ponytail: always NIL — no kit
/// can hold a :siphon hook (HookKey has no such key, so `Match::new`'s `hooks_of` check refuses the data); the hook's call comes
/// with the kit that adds the key.
pub fn siphon_of(_m: &Match, _e: Entity) -> Option<Entity> {
    None
}

/// port: BIND-OF: the binder while E is in a bind (a form's :bind hook), else NIL. ponytail: always NIL, as SIPHON-OF (no :bind
/// key in HookKey; Hisagi's bind, M4).
pub fn bind_of(_m: &Match, _e: Entity) -> Option<Entity> {
    None
}

/// port: BIND-HOOK: binder B's kit hook POINT, or NIL.
pub fn bind_hook(m: &Match, b: Option<Entity>, point: &str) -> Option<&'static str> {
    b.and_then(|b| kit_hook_sym(m, b, point))
}

/// port: BIND-STEP!: the bind's fixed points of the step (PHASE :release / :hits); nothing unbound.
pub fn bind_step(m: &mut Match, e: Entity, _phase: &str) {
    let b = if e == Entity::NIL { None } else { bind_of(m, e) };
    if let Some(h) = bind_hook(m, b, "bind-step") {
        call_hook(m, e, h);
    }
}

/// port: BIND-RESOLVE!: time-up while E is in a bind: the binder's :bind-resolve.
pub fn bind_resolve(m: &mut Match, e: Entity) {
    let b = if m.ents.alive(e) { bind_of(m, e) } else { None };
    if let Some(h) = bind_hook(m, b, "bind-resolve") {
        call_hook(m, e, h);
    }
}

/// port: BIND-SNAPSHOT-OF: E's Reishi and Konpaku when his bind started, else NIL NIL.
pub fn bind_snapshot_of(m: &mut Match, e: Entity) -> Option<(i64, i64)> {
    let b = bind_of(m, e);
    if let Some(h) = bind_hook(m, b, "bind-snapshot") {
        crate::unported!(m, h, None)
    }
    None
}

/// port: BIND-GREY-FRAC: the grey band's end on E's Reishi bar (a fraction of max), else 0.
pub fn bind_grey_frac(m: &mut Match, e: Entity) -> f32 {
    match bind_snapshot_of(m, e) {
        None => 0.0,
        Some((_, k0)) if g_of(m, e).konpaku < k0 => 1.0,
        Some((r0, _)) => r0 as f32 / g_of(m, e).reishi_max as f32,
    }
}

/// port: BIND-GREY-SOULS: E's grey souls (his Konpaku at a bind's start), else 0.
pub fn bind_grey_souls(m: &mut Match, e: Entity) -> i64 {
    bind_snapshot_of(m, e).map_or(0, |(_, k0)| k0)
}

/// port: HEAL!: E's Reishi + N, at most his max; in a bind the binder's :bind-heal follows.
pub fn heal(m: &mut Match, e: Entity, n: i64) {
    let g = g_mut(m, e);
    g.reishi = g.reishi_max.min(g.reishi + n);
    let b = bind_of(m, e);
    if let Some(h) = bind_hook(m, b, "bind-heal") {
        call_hook(m, e, h);
    }
}

/// port: DEALT-REAL: the damage E dealt this match that counts (without a bind's grey part).
pub fn dealt_real(m: &Match, e: Entity) -> i64 {
    let g = g_of(m, e);
    g.dealt - g.grey
}

/// port: AWAKEN-FILL!: X more awakening for G's owner (XS of it from attacking: SUBLIMATION / SPIRIT DRIVE); latches AW-FULL.
pub fn awaken_fill(k: &Knobs, g: &mut Gauges, x: f32, xs: f32) {
    let (aw, sub, drive) = rules::awaken_overflow(k, g.awakened, g.awaken, g.sub, g.drive, x, xs);
    (g.awaken, g.sub, g.drive) = (aw, sub, drive);
    if g.awakened || aw >= k.awaken_max {
        g.aw_full = true;
    }
}

/// port: AW-FULL-P: has G's awakening gauge been full this match (the latch, awakened, or set full directly)?
pub fn aw_full_p(k: &Knobs, g: &Gauges) -> bool {
    g.aw_full || g.awakened || g.awaken >= k.awaken_max
}

/// port: SUB-OF: E's SUBLIMATION / SPIRIT DRIVE bonus fraction (SUB-FRAC).
pub fn sub_of(m: &Match, e: Entity) -> f32 {
    let g = g_of(m, e);
    rules::sub_frac(&m.knobs, g.awakened, g.sub, g.sub_s, g.drive)
}

/// port: SUB-SPEED-MULT: walk / run speed x (1 + *SUB-SPEED* x SUB-OF).
pub fn sub_speed_mult(m: &Match, e: Entity) -> f32 {
    1.0 + m.knobs.sub_speed * sub_of(m, e)
}

/// port: PAY-GAUGES: E gains FS flash-step (capped at *FS-MAX*; nothing in a burst: FS-GAIN, x (1 + *SUB-FS* x SUB-OF)).
pub fn pay_gauges(m: &mut Match, e: Entity, fs: f32) {
    let sub = sub_of(m, e);
    let g = g_of(m, e);
    let v = rules::gauge_add(g.fs, rules::fs_gain(&m.knobs, fs, g.burst, sub), m.knobs.fs_max);
    g_mut(m, e).fs = v;
}

/// port: SP-ATK-HIT!: ATT's J / SA hit window just dealt damage: SP-ATK-GAIN of his move's class (x his kit's :sp-gain-mult hook)
/// through PAY-GAUGES; logs `SP hit gain`. (FA, the Lisp's second argument, is APPLY-HIT's `(fighter att)`.)
pub fn sp_atk_hit(m: &mut Match, att: Entity) {
    let g = crate::sp::sp_atk_gain(&m.knobs, fighter(m, att).cls.map(Into::into), false);
    if g > 0.0 {
        if let Some(h) = kit_hook_sym(m, att, "sp-gain-mult") {
            crate::unported!(m, h) // (HS-SP-GAIN-MULT: Hisagi's Bankai, M4)
        }
        let fs0 = g_of(m, att).fs;
        pay_gauges(m, att, g);
        let fs = g_of(m, att).fs;
        crate::clog!(m, "{} SP hit gain {} (fs {})", side_name(m, att), f1(fs - fs0), f1(fs));
    }
}

/// port: GAIN-GAUGES: flash-step and Fighting Spirit for dealing DEALT / taking TAKEN damage at the combo's Nth hit (HIT-GAINS).
pub fn gain_gauges(m: &mut Match, e: Entity, dealt: i64, taken: i64, n: i64) {
    let to = siphon_of(m, e);
    let mult = rules::burst_gain_mult(&m.knobs, g_of(m, e).burst);
    let (fs, aw, sfs) = rules::hit_gains(&m.knobs, dealt, taken, to.is_some(), mult, n);
    pay_gauges(m, e, fs);
    if let Some(to) = to {
        pay_gauges(m, to, sfs);
    }
    let xs = if to.is_some() { 0.0 } else { rules::sub_attack_gain(&m.knobs, dealt, 0, rules::burst_gain_mult(&m.knobs, g_of(m, e).burst)) };
    let k = &m.knobs;
    awaken_fill(k, m.gauges.get_mut(e).expect("gauges"), aw, xs);
}

// ---------------------------------------------------------------- the guard gauge

/// port: DRAIN-GUARD: E's guard gauge loses V (its regen waits again); at 0 he is guardless (WHY: the keyword's name, `BLOCK`).
/// T when this drain emptied it.
pub fn drain_guard(m: &mut Match, e: Entity, v: f32, why: &str) -> bool {
    let g = g_mut(m, e);
    let (n, crushed) = rules::gg_drain(g.gg, v);
    (g.gg, g.gg_idle) = (n, 0);
    if crushed && !g.guardless {
        g.guardless = true;
        crate::clog!(m, "{} GUARDLESS {}", side_name(m, e), why);
    }
    crushed
}

// ---------------------------------------------------------------- Burst Reverse

/// port: BURST-MODE-OF: the burst mode E's state gives a press now (rules BURST-MODE), or NIL.
pub fn burst_mode_of(m: &Match, e: Entity) -> Option<Burst> {
    let f = fighter(m, e);
    let st = f.state;
    let os = if m.ents.alive(f.opp) { state_of(m, f.opp) } else { None };
    if matches!(st, State::Idle | State::Guard | State::Run) && matches!(os, Some(State::Stun | State::Air)) && f.lock == 0 {
        return Some(Burst::Orange);
    }
    let chain_open = st == State::Move
        && f.phase == Some(Phase::Main)
        && f.mv.is_some_and(|id| {
            let mv = mv(m, id);
            if matches!(mv.kind.as_str(), "sig" | "kikon") {
                matches!(os, Some(State::Stun | State::GuardHit | State::Air))
            } else {
                matches!(os, Some(State::Stun | State::Air))
                    || rules::cancel_open_p(f.sf, f.land_sf, crate::kit::mv_total(mv), f.contact == Some(Contact::Hit))
            }
        });
    rules::burst_mode(&m.knobs, st, f.lock > 0, f.combo_hits, chain_open)
}

/// port: BURST-OK-P: may E burst now: the mode or NIL.
pub fn burst_ok_p(m: &Match, e: Entity) -> Option<Burst> {
    let md = burst_mode_of(m, e);
    let g = g_of(m, e);
    if rules::burst_allowed_p(&m.knobs, md, g.fs, g.burst.is_some()) { md } else { None }
}

/// port: REPEL!: E breaks free (a Burst Reverse, an awakening): neutral on the ground, invulnerable, his combo over; the opponent's
/// move / Hoho / step / run ends and he slides away; a coming Kikon follow-up is over on both sides.
pub fn repel(m: &mut Match, e: Entity) {
    let o = fighter(m, e).opp;
    for x in [e, o] {
        let fx = fighter_mut(m, x);
        (fx.follow, fx.kikon_undo, fx.kikon_lock) = (false, None, 0);
    }
    m.transform.get_mut(e).expect("a transform").pos[1] = 0.0;
    let mo = m.motion.get_mut(e).expect("a motion");
    (mo.grounded, mo.kb_left) = (true, 0);
    to_idle(m, e);
    fighter_mut(m, e).invuln = m.knobs.burst_invuln;
    if matches!(state_of(m, o), Some(State::Move | State::Hoho | State::Step | State::Run)) {
        to_idle(m, o);
        // look: model-alpha 1
    }
    let (p, q) = (pos_of(m, e), pos_of(m, o));
    let (d, n) = (m.knobs.burst_push, m.knobs.burst_push_frames);
    set_slide(m, o, d, n, q[0] - p[0], q[2] - p[2]);
    respect(m, o);
}

/// port: BURST!: a burst of MODE starts (FIGHTER-SYSTEM applies it once both stepped): the flash-step drains from now; BLUE breaks
/// free (REPEL!), ORANGE cancels his recovery (*CHAIN-WINDOW*); a short global hitstop.
pub fn burst(m: &mut Match, e: Entity, mode: Burst) {
    let o = opp_of(m, e);
    let budget = rules::burst_budget(&m.knobs, Some(mode));
    let g = g_mut(m, e);
    (g.burst, g.burst_t, g.fs_idle, g.burn) = (Some(mode), 0, 0, budget);
    match mode {
        Burst::Blue => repel(m, e),
        Burst::Orange => {
            to_idle(m, e);
            fighter_mut(m, e).chain = m.knobs.chain_window;
            let fo = fighter_mut(m, o);
            fo.combo_from = fo.combo_hits; // (his combo's scaling starts over)
        }
        Burst::White => {}
    }
    let hs = m.knobs.burst_hitstop as f32;
    m.time.hitstop(hs);
    // look: emit :burst
    crate::clog!(m, "{} BURST {} fs {}", side_name(m, e), mode, f1(g_of(m, e).fs));
}

/// port: BURST-END!: E's burst ends: the regen delay restarts.
pub fn burst_end(m: &mut Match, e: Entity) {
    if let Some(b) = g_of(m, e).burst {
        crate::clog!(m, "{} BURST END {} fs {}", side_name(m, e), b, f1(g_of(m, e).fs));
        let g = g_mut(m, e);
        (g.burst, g.burst_t, g.burn, g.fs_idle) = (None, 0, 0.0, 0);
        fighter_mut(m, e).chain = 0;
        // look: emit :burst-end
    }
}

/// port: WHITE-REGEN!: WHITE's regen on E's frame N (1-based): Reishi (HEAL!) and the awakening gauge.
pub fn white_regen(m: &mut Match, e: Entity, n: i64) {
    let r = rules::burst_heal(n, m.knobs.white_reishi);
    heal(m, e, r);
    let x = m.knobs.white_awaken / 60.0; // a Burst counts as attacking (DUEL_SUBLIMATION §18)
    let k = &m.knobs;
    awaken_fill(k, m.gauges.get_mut(e).expect("gauges"), x, x);
}

/// port: BURST-STEP: a running burst, one frame: the flash-step drains (BURST-BURN), WHITE's regen; spent, it ends.
pub fn burst_step(m: &mut Match, e: Entity) {
    let (fs, burn) = {
        let g = g_of(m, e);
        rules::burst_burn(&m.knobs, g.fs, g.burn)
    };
    let g = g_mut(m, e);
    g.burst_t += 1;
    let n = g.burst_t;
    (g.fs, g.burn) = (fs, burn);
    if g.burst == Some(Burst::White) {
        white_regen(m, e, n);
    }
    let g = g_of(m, e);
    if g.fs <= 0.0 || g.burn <= 0.0 {
        burst_end(m, e);
    }
}

/// port: AWAKE-REGEN-FRAMES: as long as a burst from a full flash-step gauge (*FS-MAX* / *BURST-DRAIN*), 333.
pub fn awake_regen_frames(k: &Knobs) -> i64 {
    crate::cl::round_f32(60.0 * (k.fs_max / k.burst_drain))
}

/// port: START-AWAKE-REGEN!: WHITE's regen for AWAKE-REGEN-FRAMES on its own clock.
pub fn start_awake_regen(k: &Knobs, g: &mut Gauges) {
    (g.awake_regen, g.awake_t) = (awake_regen_frames(k), 0);
}

// ---------------------------------------------------------------- forms, awakening

/// port: SET-FORM: E's character changes to FORM: the old form's exit hook, the new kit, its timer, the pointer within its NS,
/// the entry hook. False once a hook is unported.
pub fn set_form(m: &mut Match, e: Entity, form: Form) -> bool {
    let old = kit_of(m, e);
    let character = fighter(m, e).character.expect("a character");
    let new = crate::kit::find_kit(m.data, &character.name().to_lowercase(), &form.name().to_lowercase());
    if let Some(h) = &old.exit_hook
        && !std::ptr::eq(old, new)
        && !call_hook(m, e, h)
    {
        return false;
    }
    let f = fighter_mut(m, e);
    (f.kit, f.form) = (Some(KitId { character, form }), form);
    let n = new.core.ns.len() as i64; // the core system: the pointer within the form's NS
    if n > 0 {
        f.ptr = f.ptr.min(n);
    }
    let g = g_mut(m, e);
    g.burn_step = 0;
    g.form_left = new.duration.map_or(0, rules::seconds_to_frames);
    // look: refresh-look (the body's hurt volume is read from the current kit: docs/bevy/M1_NOTES.md §1)
    if let Some(h) = &new.enter_hook
        && !call_hook(m, e, h)
    {
        return false;
    }
    // look: emit :form
    crate::clog!(m, "{} form {}", side_name(m, e), form);
    true
}

fn form_named(s: &Option<String>) -> Form {
    Form::from_name(s.as_deref().expect("a form name")).expect("a form of the data")
}

/// port: AWAKEN!: once per match: E breaks free (REPEL!), the awakening's regen, SUBLIMATION frozen, the awakened form, the meter's
/// :start, *AWAKEN-HEAL* of max Reishi, then the form's :cine (both idle after it) or idle.
pub fn awaken(m: &mut Match, e: Entity) {
    repel(m, e);
    let k = &m.knobs;
    let g = m.gauges.get_mut(e).expect("gauges");
    start_awake_regen(k, g);
    g.sub_s = g.sub / k.sub_max; // SUBLIMATION freezes (kept x *SUB-KEEP*), SPIRIT DRIVE takes over
    (g.awakened, g.awaken, g.evolution) = (true, 0.0, false);
    if !set_form(m, e, form_named(&kit_of(m, e).awaken_form)) {
        return;
    }
    if let Some(st) = kit_of(m, e).meter.start {
        let g = g_mut(m, e); // (NOME's :start 0 counts: Lisp 0 is true)
        (g.meter, g.meter_idle) = (st as f32, 0);
    }
    let r = crate::cl::round_f32(m.knobs.awaken_heal * g_of(m, e).reishi_max as f32);
    heal(m, e, r);
    // look: emit :awaken
    match &kit_of(m, e).cine {
        Some(c) => start_kit_cine(m, e, c),
        None => to_idle(m, e),
    }
}

// ---------------------------------------------------------------- Kenpachi's Bankai (DUEL_KEN_V3 §26)

/// port: BANKAI!: E into FORM, his Konpaku kept; RESTORE: the awakening's regen and his Reishi refilled; then the form's :cine
/// (CINE NIL: none) or idle.
pub fn bankai(m: &mut Match, e: Entity, form: Form, restore: bool, cine: bool) {
    let lost = 0; // (his Konpaku kept, the user 2026-10-31: 「改成不扣」; KEEP is constant T, so LOST is 0 and Konpaku is left as it is)
    repel(m, e);
    if restore {
        let k = &m.knobs;
        start_awake_regen(k, m.gauges.get_mut(e).expect("gauges"));
    }
    if !set_form(m, e, form) {
        return;
    }
    if restore {
        let g = g_mut(m, e);
        g.reishi = g.reishi_max;
    }
    // look: refresh-look, emit :bankai
    crate::clog!(m, "{} BANKAI (konpaku kept, -{})", side_name(m, e), lost);
    match &kit_of(m, e).cine {
        Some(c) if cine => start_kit_cine(m, e, c),
        _ => to_idle(m, e),
    }
}

/// START-CINE of E's form's :cine C, both fighters idle after it (an unported one, Ichigo's: `unported!`).
fn start_kit_cine(m: &mut Match, e: Entity, c: &'static str) {
    let Some(name) = crate::cine::CineName::from_lisp(c) else { crate::unported!(m, c) };
    let o = opp_of(m, e);
    crate::cine::start_cine(m, name, e, o, Some(crate::cine::After::IdleBoth(e, o)));
}

// ---------------------------------------------------------------- gauges per step

/// port: GAUGE-SYSTEM: regen (flash-step, the guard gauge after their delays: a full guard gauge ends guardless), the awakening's
/// regen, the hidden stun's decay, timed forms, the form's :tick hook, EVOLUTION. GUARD HOLD: one guarding test gates the guard
/// gauge's refill and its delay counter.
pub fn gauge_system(m: &mut Match) {
    m.do_entities(|m, e| m.fighter.has(e) && m.gauges.has(e), |m, e| {
        if m.unported.is_some() {
            return; // (a step past an unported path: the replay stops at it)
        }
        let kit = kit_of(m, e); // (bound before SET-FORM: the burn and the :tick hook are the old form's on its last step)
        let st = fighter(m, e).state;
        let guarding = matches!(st, State::Guard | State::GuardHit) && !g_of(m, e).guardless;
        if g_of(m, e).burst.is_some() {
            burst_step(m, e); // a burst: the gauge drains, no regen
        } else {
            let k = &m.knobs;
            let g = m.gauges.get_mut(e).expect("gauges");
            (g.fs, g.fs_idle) = (rules::fs_regen(k, g.fs, g.fs_idle, k.fs_regen), 9999.min(g.fs_idle + 1));
        }
        if g_of(m, e).awake_regen > 0 {
            let g = g_mut(m, e); // the awakening's regen (overlaps a burst)
            g.awake_regen -= 1;
            g.awake_t += 1;
            let n = g.awake_t;
            white_regen(m, e, n);
        }
        let k = &m.knobs;
        let g = m.gauges.get_mut(e).expect("gauges");
        g.gg = rules::gg_regen(k, g.gg, g.gg_idle, g.guardless, guarding, g.burst == Some(Burst::Blue), kit.gg_regen, k.gg_max);
        g.gg_idle = rules::gg_idle_next(g.gg_idle, guarding);
        (g.stun, g.stun_idle) = (rules::stun_decay(k, g.stun, g.stun_idle), 9999.min(g.stun_idle + 1)); // the hidden stun's decay
        if g.guardless && g.gg >= k.gg_max {
            g.guardless = false;
            // look: emit :guard-back
            crate::clog!(m, "{} GUARD BACK", side_name(m, e));
        }
        let f = fighter_mut(m, e);
        if f.combo_dmg > 0 && !matches!(f.state, State::Stun | State::Air | State::Down | State::Wakeup | State::GuardHit) {
            f.combo_dmg = 0; // the combo's damage shows until he is up again
        }
        if g_of(m, e).form_left > 0 {
            let g = g_mut(m, e);
            if kit.burn > 0.0 {
                g.reishi = rules::burn(g.reishi, rules::burn_amount(g.reishi_max, kit.burn, g.burn_step));
            }
            g.burn_step += 1;
            g.form_left -= 1;
            if g.form_left == 0 && !set_form(m, e, form_named(&kit.inherit)) {
                return;
            }
        }
        if let Some(h) = kit.hooks.get("tick") {
            // the form's own per-step mechanics (ICHIGO-TICK Task 12, KEN-BK-TICK Task 11, HS- / YAMA- M4)
            if !crate::flow::stub_tick(m, e, h) && !call_hook(m, e, h) {
                return;
            }
        }
        let (k, tick) = (&m.knobs, m.match_tick);
        let g = m.gauges.get_mut(e).expect("gauges");
        if !g.awakened && !g.evolution && g.awaken >= k.awaken_max {
            g.evolution = true;
            if g.evo_t < 0 {
                g.evo_t = tick;
            }
            // look: emit :evolution
            crate::clog!(m, "{} EVOLUTION", side_name(m, e));
        }
    });
}

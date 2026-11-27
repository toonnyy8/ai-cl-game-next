//! port: duel/lisp/debug.lisp DEBUG-COMMAND, the ranges the gate traces use (any other code is `unported!("debug N")`), and the
//! scenario helpers a trial trace's E lines apply (tools/port/oracle/trace.lisp TR-APPLY-EVENT): ENSURE-BATTLE, PLACE, FORCE-FORM,
//! FULL-GAUGES!, and the fields an `E set` line names.
use crate::cl::Num;
use crate::components::Character::{Ichigo, Kenpachi};
use crate::components::{Burst, Character, Difficulty, Flow, Form, State};
use crate::ecs::Entity;
use crate::gate::{start_cvc, start_pair_gate};
use crate::cpu::Search;
use crate::state::{Match, Mode};

/// port: DEBUG-COMMAND (`*stats-log*` is the logs'). Every command sets `*learn-debug-off*`: no CPU learns in a debug run (debug 2504
/// clears it again); any but a cinematic still's (CINE-STILL-COMMAND-P) clears `*cine-hold*`.
pub fn debug_command(m: &mut Match, s: &mut Search, c: i64) {
    m.log_on = true;
    s.learn_debug_off = true;
    // log-msg: "debug cmd C"
    if !matches!(c, 2200..=2299 | 10000..=19999 | 35000..=35999) {
        m.cine_hold = false;
    }
    match c {
        2000..=2099 => start_cvc(m, s, c - 2000, None),
        2200..=2299 => force_cine(m, s, c - 2200),
        10000..=19999 => cine_at(m, s, (c - 10000) / 1000, c % 1000),
        35000..=35999 => cine_at(m, s, 9 + (c - 35000) / 1000, c % 1000),
        75000..=75599 => {
            use crate::ichigo::cine::IcCine::*;
            let i = ((c - 75000) / 80).min(6) as usize;
            ichigo_cine_at(m, s, [Kikon, KessaKikon, Kessa, KessaGetsuga, HeavyKikon, RushKikon, ChainKikon][i], 3 * ((c - 75000) % 80));
        }
        86110 => ichigo_cine_at(m, s, crate::ichigo::cine::IcCine::Haste, 40),
        84006..=84008 | 84094..=84097 => ken_core_cine(m, s, c),
        2504 => debug_vs_learner(m, s),
        2102 => m.turbo = !m.turbo,
        3000..=3999 => start_cvc(m, s, c - 3000, Some([Ichigo, Ichigo])),
        4000..=4999 => start_cvc(m, s, c - 4000, Some([Ichigo, Kenpachi])),
        5000..=5999 => start_cvc(m, s, c - 5000, Some([Kenpachi, Kenpachi])),
        30000..=30999 => m.gate_seed0 = c - 30000,
        31101..=31199 => m.gate_seeds = c - 31100,
        81020..=81022 => m.gate_difficulty = [Difficulty::Easy, Difficulty::Normal, Difficulty::Hard][(c - 81020) as usize],
        200000..=209999 => start_pair_gate(m, s, c / 100 % 10, c / 10 % 10),
        2394..=2397 => string_test(m, s, (c - 2394) as usize),
        2500..=2503 => debug_vs_idle(m, s, (c - 2500) as usize),
        2505 => lhud_scene(m, s),
        2508 => lhud_p2_form(m),
        2513 => m.time.slowmo(m.knobs.core_clash_slowmo_scale, 3.0, false),
        84000 | 84001 | 84004 | 84005 => ken_core_scene(m, s, c),
        // ponytail: leaked once per run, on the path that stops it
        _ => crate::unported!(m, Box::leak(format!("debug {c}").into_boxed_str())),
    }
}

/// port: debug 2504 — human Kenpachi vs a HARD Ichigo CPU that learns (DUEL_AI_STRATEGY §8.14): VS CPU, the learner on as in play,
/// `*fq-tables*` forgotten (the attach reads the page), the match started with its cinematics skipped. (`*probe*` is never set here;
/// `*one-hand*` is ONE-HAND-EFFECTIVE-P, NIL headless: the touch deck's branches are M3's.)
fn debug_vs_learner(m: &mut Match, s: &mut Search) {
    (m.picks, m.mode, m.difficulty) = ([Kenpachi, Ichigo], Mode::VsCpu, crate::components::Difficulty::Hard);
    s.learn_debug_off = false;
    s.fq_tables.clear();
    let skip = std::mem::replace(&mut m.skip_cines, true); // (let ((*skip-cines* t)) …)
    crate::flow::start_match(m, s);
    m.skip_cines = skip;
}

/// port: debug 2500+k — human P1 vs an idle CPU P2 (its brain off), VS CPU, `*match-seed*` 1, the match started with its cinematics
/// skipped: K 0 Ichigo vs Kenpachi, 1 Kenpachi vs Ichigo, 2 Ichigo vs Ichigo, 3 Kenpachi vs Kenpachi. (`*probe*` is never set here;
/// `*one-hand*` is ONE-HAND-EFFECTIVE-P: the page's, `Match.settings.one_hand`.)
fn debug_vs_idle(m: &mut Match, s: &mut Search, k: usize) {
    m.picks = [[Ichigo, Kenpachi], [Kenpachi, Ichigo], [Ichigo, Ichigo], [Kenpachi, Kenpachi]][k];
    (m.mode, m.match_seed) = (Mode::VsCpu, 1);
    let skip = std::mem::replace(&mut m.skip_cines, true); // (let ((*skip-cines* t)) …)
    crate::flow::start_match(m, s);
    m.skip_cines = skip;
    brain_off(m, m.p2, true);
}

/// port: debug.lisp LHUD-SCENE (2505: PRACTICE nil, no intro, the default picks) — human Ichigo (P1) vs Kenpachi with his CPU off, VS
/// CPU, `*match-seed*` 1, cinematics skipped. (`*probe*` NIL: never set by a ported command. `*one-hand*` is ONE-HAND-EFFECTIVE-P: the
/// page's, `Match.settings.one_hand`, left as the caller set it.)
fn lhud_scene(m: &mut Match, s: &mut Search) {
    (m.picks, m.mode, m.match_seed) = ([Ichigo, Kenpachi], Mode::VsCpu, 1);
    let skip = std::mem::replace(&mut m.skip_cines, true); // (let ((*skip-cines* (not intro))) …)
    crate::flow::start_match(m, s);
    m.skip_cines = skip;
    brain_off(m, m.p2, true);
    brain_off(m, m.p1, true); // ((when (brain *p1*) …): a human P1 has none)
}

/// port: debug.lisp LHUD-P2-FORM (2508) — P2 to his next form: sealed -> the Shikai (meter 2, its idle timer cleared) -> the Bankai
/// KYORAN -> ZANKAI -> sealed.
fn lhud_p2_form(m: &mut Match) {
    let p2 = m.p2;
    let next = match m.fighter.get(p2).expect("P2").form {
        Form::Base => Form::Nozarashi,
        Form::Nozarashi => Form::Bankai,
        Form::Bankai => Form::Bankai2,
        _ => Form::Base,
    };
    force_form(m, p2, next);
    if next == Form::Nozarashi {
        let g = m.gauges.get_mut(p2).expect("gauges");
        (g.meter, g.meter_idle) = (2.0, 0);
    }
}

/// port: debug.lisp STRING-TEST (2394+k): human P1 in form K (Ichigo's Shikai, KESSA, Kenpachi's base, his Shikai) 2.2 m from an idle
/// Kenpachi.
fn string_test(m: &mut Match, s: &mut Search, k: usize) {
    let (c, form) = [(Ichigo, Form::Base), (Ichigo, Form::Kessa), (Kenpachi, Form::Base), (Kenpachi, Form::Nozarashi)][k];
    ensure_battle(m, s, c, Kenpachi, false);
    let p1 = m.p1;
    if m.fighter.get(p1).expect("P1").form != form {
        force_form(m, p1, form);
    }
    place(m, 2.2);
}

/// port: ken.lisp KEN-CORE-DEBUG's scene (84000 / 84001 / 84004 / 84005): human P1 Kenpachi and an idle Ichigo P2 2.2 m apart, both
/// CPUs off, gauges full, P1's awakening / SUBLIMATION / DRIVE cleared; 84001 in the Shikai (awakened, L 0), 84004 / 84005 in the
/// Bankai KYORAN / ZANKAI (awakened).
fn ken_core_scene(m: &mut Match, s: &mut Search, c: i64) {
    ensure_battle(m, s, Kenpachi, Ichigo, false);
    brain_off(m, m.p1, true);
    place(m, 2.2);
    let (p1, p2) = (m.p1, m.p2);
    full_gauges(m, p1, None);
    full_gauges(m, p2, None);
    let g = m.gauges.get_mut(p1).expect("gauges");
    (g.awakened, g.aw_full, g.awaken, g.sub, g.sub_s, g.drive) = (false, false, 0.0, 0.0, 0.0, 0.0);
    match c {
        84001 => {
            force_form(m, p1, Form::Nozarashi);
            let g = m.gauges.get_mut(p1).unwrap();
            (g.awakened, g.meter) = (true, 0.0);
        }
        84004 | 84005 => {
            force_form(m, p1, if c == 84004 { Form::Bankai } else { Form::Bankai2 });
            m.gauges.get_mut(p1).unwrap().awakened = true;
            let kit = crate::look::KitRef(crate::fighter::kit_of(m, p1));
            m.look(crate::look::LookEvent::RefreshLook { e: p1, kit }); // look: (refresh-look *p1*)
        }
        _ => {}
    }
}

/// debug.lisp `*cine-names*` (FORCE-CINE's numbering; the NILs: retired kits' and removed cinematics).
fn cine_name(k: i64) -> Option<crate::cine::CineName> {
    use crate::cine::CineName;
    use crate::ken::cine::KenCine;
    match k {
        1 => Some(CineName::Ken(KenCine::Nozarashi)),
        6 => Some(CineName::SoulBreak),
        7 => Some(CineName::Intro),
        8 => Some(CineName::Ko),
        9 => Some(CineName::Ken(KenCine::Bankai)),
        _ => None,
    }
}

/// port: debug.lisp FORCE-CINE (2200+k): cinematic K of `*cine-names*` now, held at its `:hold` frame.
fn force_cine(m: &mut Match, s: &mut Search, k: i64) {
    use crate::cine::{start_cine, CineName};
    use crate::ken::cine::KenCine;
    m.cine_hold = false;
    match k {
        1 | 9 => {
            ensure_battle(m, s, Kenpachi, Ichigo, false);
            place(m, 5.0);
            let p1 = m.p1;
            force_form(m, p1, if k == 1 { Form::Nozarashi } else { Form::Bankai });
            start_cine(m, CineName::Ken(if k == 1 { KenCine::Nozarashi } else { KenCine::Bankai }), m.p1, m.p2, None);
        }
        6 | 8 => {
            let (c1, c2, name) = if k == 6 { (Kenpachi, Ichigo, CineName::SoulBreak) } else { (Ichigo, Kenpachi, CineName::Ko) };
            ensure_battle(m, s, c1, c2, false);
            place(m, 3.0);
            start_cine(m, name, m.p1, m.p2, None);
        }
        7 => crate::flow::start_match(m, s),
        _ => crate::unported!(m, "force-cine of a retired kit's cinematic"),
    }
    m.cine_hold = true;
    if let Some(c) = m.cine.as_mut() {
        c.hold = Some(c.name.hold_frame());
    }
}

/// port: debug.lisp CINE-AT (10000 + 1000 k + f; 35000 + f for k 9): cinematic K held at frame F; when it already runs, it goes on to F.
fn cine_at(m: &mut Match, s: &mut Search, k: i64, f: i64) {
    if m.cine.is_none() || m.cine.as_ref().map(|c| c.name) != cine_name(k) {
        crate::cine::abort_cine(m); // (another one held: its looks end first)
        force_cine(m, s, k);
    }
    if let Some(c) = m.cine.as_mut() {
        m.cine_hold = true;
        c.hold = Some(f);
    }
}

/// port: ichigo.lisp ICHIGO-CINE-AT (75000 + 80 i + k: cinematic i at frame 3k; 86110 the 超速連斬 at 40): P1 Ichigo 3 m from Kenpachi
/// in its form (4 Kikon souls for 千影), the cinematic held at frame F; when it already runs, it goes on to F.
fn ichigo_cine_at(m: &mut Match, s: &mut Search, name: crate::ichigo::cine::IcCine, f: i64) {
    use crate::ichigo::cine::IcCine::*;
    let cn = crate::cine::CineName::Ichigo(name);
    if m.cine.as_ref().map(|c| c.name) != Some(cn) {
        crate::cine::abort_cine(m);
        m.cine_hold = false;
        ensure_battle(m, s, Ichigo, Kenpachi, false);
        place(m, 3.0);
        let p1 = m.p1;
        force_form(m, p1, if matches!(name, Kikon | HeavyKikon | RushKikon) { Form::Base } else { Form::Kessa });
        if name == KessaKikon {
            m.fighter.get_mut(p1).unwrap().kikon_n = 4;
        }
        crate::cine::start_cine(m, cn, m.p1, m.p2, None);
    }
    if let Some(c) = m.cine.as_mut() {
        m.cine_hold = true;
        c.hold = Some(f);
    }
}

/// port: ken.lisp KEN-CORE-DEBUG's played Kikon cinematics, each on its scene 3 m apart: 84094 / 84095 the Shikai's pointer 1 / 2 (on
/// 84001), 84096 / 84097 the Bankai's 狂嵐 / 斬壞 (on 84004 / 84005, 4 souls, CINE-STAGE), 84006-84008 the sealed form's 鈴 / 斬ってみろよ /
/// 両断 (on 84000, 3 souls, CINE-STAGE).
fn ken_core_cine(m: &mut Match, s: &mut Search, c: i64) {
    use crate::cine::{cine_stage, start_cine, CineName};
    use crate::ken::cine::KenCine::*;
    let (scene, name, souls) = match c {
        84094 => (84001, SKikon1, None),
        84095 => (84001, SKikon2, None),
        84096 => (84004, KrKikon, Some(4)),
        84097 => (84005, ZhKikon, Some(4)),
        84006 => (84000, ZKikon1, Some(3)),
        84007 => (84000, ZKikon2, Some(3)),
        _ => (84000, ZKikon3, Some(3)),
    };
    ken_core_scene(m, s, scene);
    place(m, 3.0);
    m.cine_hold = false;
    let (p1, p2) = (m.p1, m.p2);
    if let Some(n) = souls {
        m.fighter.get_mut(p1).unwrap().kikon_n = n;
        cine_stage(m, p1, p2);
    }
    start_cine(m, CineName::Ken(name), p1, p2, None);
}

/// `(setf (brain-off (brain e)) off)` when E has a brain.
fn brain_off(m: &mut Match, e: Entity, off: bool) {
    if let Some(b) = m.fighter.get_mut(e).and_then(|f| f.brain.as_mut()) {
        b.off = off;
    }
}

/// port: trace.lisp TR-VS-START — a VS CPU match as the menu starts it (MODE's VS CPU row, SELECT's picks and difficulty, NEW-SEED
/// fixed to SEED, START-MATCH): human C1 vs a CPU C2 at DIF, the intro played; `*learn-debug-off*` left as it is.
pub fn vs_start(m: &mut Match, s: &mut Search, c1: Character, c2: Character, dif: crate::components::Difficulty, seed: i64) {
    (m.mode, m.picks, m.difficulty, m.match_seed) = (Mode::VsCpu, [c1, c2], dif, seed);
    crate::flow::start_match(m, s);
}

// ---------------------------------------------------------------- scenario helpers

/// port: ENSURE-BATTLE: a battle of C1 and C2 (CPU vs CPU when CPU, else VS CPU), cinematics skipped into the fight, unless one of
/// exactly those is already in battle; the brains on when CPU, else off (a trace records `:cpu t` only; the debug scenes NIL).
pub fn ensure_battle(m: &mut Match, s: &mut Search, c1: Character, c2: Character, cpu: bool) {
    let ch = |e: Entity| m.fighter.get(e).and_then(|f| f.character);
    if m.flow == Flow::Battle && ch(m.p1) == Some(c1) && ch(m.p2) == Some(c2) {
        return;
    }
    (m.picks, m.mode) = ([c1, c2], if cpu { Mode::CpuCpu } else { Mode::VsCpu });
    let skip = std::mem::replace(&mut m.skip_cines, true); // (let ((*skip-cines* t)) …)
    crate::flow::start_match(m, s);
    m.skip_cines = skip;
    for e in [m.p2, m.p1] {
        brain_off(m, e, !cpu); // ((setf (brain-off …) (not cpu)): P2's brain, then P1's when he has one)
    }
}

/// port: PLACE of P1 and P2: DIST m apart on the x axis around the centre, facing, idle; no hazards (FX-CLEAR, `*punch-t*` and the
/// models' flash / super are looks: `LookEvent::Place`).
pub fn place(m: &mut Match, dist: f32) {
    crate::hazards::clear_hazards(m);
    m.look(crate::look::LookEvent::Place); // look: (fx-clear) (setf *punch-t* 0.0) the models' flash / super 0
    m.time.reset();
    let (a, b) = (m.p1, m.p2);
    m.transform.get_mut(a).expect("P1").pos = [-0.5 * dist, 0.0, 0.0];
    m.transform.get_mut(b).expect("P2").pos = [0.5 * dist, 0.0, 0.0];
    crate::cine::face_each_other(m, a, b, None);
    for e in [a, b] {
        crate::fighter::to_idle(m, e, 0.0);
        m.fighter.get_mut(e).unwrap().lock = 0;
    }
}

/// port: FORCE-FORM: SET-FORM, then awakened when the new kit is an awakening.
pub fn force_form(m: &mut Match, e: Entity, form: Form) {
    if crate::gauges::set_form(m, e, form) && crate::fighter::kit_of(m, e).awakening {
        m.gauges.get_mut(e).unwrap().awakened = true;
    }
}

/// port: FULL-GAUGES!: cooldowns cleared, flash-step and guard gauges full, not guardless, Reishi at its cap; with METER the kit
/// meter set to it and its idle timer cleared.
pub fn full_gauges(m: &mut Match, e: Entity, meter: Option<f32>) {
    m.fighter.get_mut(e).expect("fighter").cd.fill(0);
    let (fs, gg) = (m.knobs.fs_max, m.knobs.gg_max);
    let g = m.gauges.get_mut(e).expect("gauges");
    (g.fs, g.gg, g.guardless, g.reishi) = (fs, gg, false, Num::I(g.reishi_max));
    if let Some(x) = meter {
        (g.meter, g.meter_idle) = (x, 0);
    }
}

/// A value an E line prints (Lisp-printed): an integer, a single-float, `:KEYWORD`, `T`, `NIL`.
#[derive(Clone, Debug, PartialEq)]
pub enum LispValue {
    Int(i64),
    Float(f32),
    /// The keyword's name, upper case, without the colon.
    Kw(String),
    T,
    Nil,
}

impl LispValue {
    pub fn parse(s: &str) -> Result<LispValue, String> {
        Ok(match s {
            "T" => LispValue::T,
            "NIL" => LispValue::Nil,
            _ if s.starts_with(':') && s.len() > 1 => LispValue::Kw(s[1..].to_string()),
            _ => match s.parse::<i64>() {
                Ok(n) => LispValue::Int(n),
                Err(_) if s.contains(['.', 'e']) => LispValue::Float(s.parse().map_err(|_| format!("not a Lisp value: {s}"))?),
                Err(_) => return Err(format!("not a Lisp value: {s}")),
            },
        })
    }

    pub fn int(&self) -> Result<i64, String> {
        if let LispValue::Int(n) = self { Ok(*n) } else { Err(format!("{self:?}: not an integer")) }
    }
    pub fn float(&self) -> Result<f32, String> {
        if let LispValue::Float(x) = self { Ok(*x) } else { Err(format!("{self:?}: not a single-float")) }
    }
    /// A number as a single-float (a distance, a meter: `(f32 x)`, or a float the reader made).
    pub fn real(&self) -> Result<f32, String> {
        match self {
            LispValue::Int(n) => Ok(*n as f32),
            LispValue::Float(x) => Ok(*x),
            _ => Err(format!("{self:?}: not a number")),
        }
    }
    fn bool(&self) -> Result<bool, String> {
        match self {
            LispValue::T => Ok(true),
            LispValue::Nil => Ok(false),
            _ => Err(format!("{self:?}: not T / NIL")),
        }
    }
    pub fn kw(&self) -> Result<&str, String> {
        if let LispValue::Kw(k) = self { Ok(k) } else { Err(format!("{self:?}: not a keyword")) }
    }
}

/// port: TR-APPLY-EVENT's `set`: SIDE None = a global (`*TR-GLOBALS*`), else that side's field (`*TR-SIDE-FIELDS*`), NAME as the
/// trace prints it (upper case). A value of a type the slot never holds is an error (only Reishi takes an integer or a float: the
/// trials' `:p2-reishi` writes `(f32 x)` into the fixnum slot), and so is a name outside those lists. `hss-*`: Hisagi's (M4).
pub fn set_field(m: &mut Match, side: Option<usize>, name: &str, v: &LispValue) -> Result<(), String> {
    let Some(k) = side else {
        match name {
            "*COMBAT-LOG*" => m.log_on = v.bool()?,
            "*SKIP-CINES*" => m.skip_cines = v.bool()?,
            "*TIMER*" => m.timer = v.int()?,
            "SIM-RND-STATE" => m.rng.set_state(u32::try_from(v.int()?).map_err(|e| format!("SIM-RND-STATE: {e}"))?),
            _ => return Err(format!("set: no global {name}")),
        }
        return Ok(());
    };
    let e = if k == 0 { m.p1 } else { m.p2 };
    if matches!(name, "HSS-BOUND" | "HSS-BIND-ARM" | "HSS-UNBIND") {
        crate::unported!(m, "hss-* (E set)", Ok(()))
    }
    if let Some(slot) = name.strip_prefix("GAUGES-") {
        let g = m.gauges.get_mut(e).ok_or("set: no gauges")?;
        match slot {
            "AWAKENED" => g.awakened = v.bool()?,
            "KONPAKU" => g.konpaku = v.int()?,
            "SUB" => g.sub = v.float()?,
            "SUB-S" => g.sub_s = v.float()?,
            "DRIVE" => g.drive = v.float()?,
            "AWAKEN" => g.awaken = v.float()?,
            "METER" => g.meter = v.float()?,
            "FS" => g.fs = v.float()?,
            "BURN" => g.burn = v.float()?,
            "BURST" => {
                g.burst = match v {
                    LispValue::Nil => None,
                    _ => Some(Burst::from_name(v.kw()?).ok_or(format!("set: no burst {v:?}"))?),
                }
            }
            "REISHI" => {
                g.reishi = match v {
                    LispValue::Int(n) => Num::I(*n),
                    _ => Num::F(v.float()?),
                }
            }
            _ => return Err(format!("set: no field {name}")),
        }
        return Ok(());
    }
    if let Some(slot) = name.strip_prefix("FIGHTER-") {
        let f = m.fighter.get_mut(e).ok_or("set: no fighter")?;
        match slot {
            "XCH" => f.xch = v.int()?,
            "XCH-DONE" => f.xch_done = v.bool()?,
            "HOHO-LOCK" => f.hoho_lock = v.int()?,
            "PTR" => f.ptr = v.int()?,
            "GUARD-T" => f.guard_t = v.int()?,
            "STATE" => f.state = State::from_name(v.kw()?).ok_or(format!("set: no state {v:?}"))?,
            _ => return Err(format!("set: no field {name}")),
        }
        return Ok(());
    }
    Err(format!("set: no field {name}"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn lisp_value_parses() {
        let p = |s| LispValue::parse(s).unwrap();
        let LispValue::Float(z) = p("-0.0") else { panic!() };
        assert!(z == 0.0 && z.is_sign_negative());
        assert_eq!(p("300"), LispValue::Int(300));
        assert_eq!(p("300.0"), LispValue::Float(300.0));
        assert_eq!(p("1.6"), LispValue::Float(1.6));
        assert_eq!(p(":NOZARASHI"), LispValue::Kw("NOZARASHI".into()));
        assert_eq!((p("NIL"), p("T")), (LispValue::Nil, LispValue::T));
        assert!(LispValue::parse("BOGUS").is_err());
    }

    #[test]
    fn set_unknown_field_is_error() {
        let mut m = crate::hashline::tests::new_match();
        crate::flow::go_title(&mut m);
        assert!(set_field(&mut m, Some(0), "GAUGES-NOPE", &LispValue::Int(1)).is_err());
        assert!(set_field(&mut m, Some(0), "FIGHTER-NOPE", &LispValue::Int(1)).is_err());
        assert!(set_field(&mut m, None, "*NOPE*", &LispValue::Int(1)).is_err());
        assert!(set_field(&mut m, Some(0), "GAUGES-KONPAKU", &LispValue::Float(9.0)).is_err()); // a fixnum slot
        assert!(set_field(&mut m, Some(0), "GAUGES-FS", &LispValue::Int(300)).is_err()); // a single-float slot
        set_field(&mut m, Some(1), "GAUGES-REISHI", &LispValue::Float(300.0)).unwrap();
        assert_eq!(m.gauges.get(m.p2).unwrap().reishi, Num::F(300.0));
        set_field(&mut m, Some(1), "FIGHTER-STATE", &LispValue::Kw("GUARD".into())).unwrap();
        set_field(&mut m, None, "SIM-RND-STATE", &LispValue::Int(1779033703)).unwrap();
        assert_eq!((m.fighter.get(m.p2).unwrap().state, m.rng.state()), (State::Guard, 1779033703));
        assert_eq!(set_field(&mut m, Some(0), "HSS-BOUND", &LispValue::T), Ok(()));
        assert_eq!(m.unported, Some("hss-* (E set)"));
    }
}

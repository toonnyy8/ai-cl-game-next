//! port: duel/lisp/debug.lisp DEBUG-COMMAND, the ranges the gate traces use (any other code is `unported!("debug N")`), and the
//! scenario helpers a trial trace's E lines apply (tools/port/oracle/trace.lisp TR-APPLY-EVENT): ENSURE-BATTLE, PLACE, FORCE-FORM,
//! FULL-GAUGES!, and the fields an `E set` line names.
use crate::cl::Num;
use crate::components::Character::{Ichigo, Kenpachi};
use crate::components::{Burst, Character, Flow, Form, State};
use crate::ecs::Entity;
use crate::gate::{start_cvc, start_pair_gate};
use crate::state::{Match, Mode};

/// port: DEBUG-COMMAND (`*stats-log*` / `*learn-debug-off*` are the logs' and the learner's; `*cine-hold*` is never set by
/// these commands, so clearing it is moot).
pub fn debug_command(m: &mut Match, c: i64) {
    m.log_on = true;
    // log-msg: "debug cmd C"
    match c {
        2102 => m.turbo = !m.turbo,
        3000..=3999 => start_cvc(m, c - 3000, Some([Ichigo, Ichigo])),
        4000..=4999 => start_cvc(m, c - 4000, Some([Ichigo, Kenpachi])),
        5000..=5999 => start_cvc(m, c - 5000, Some([Kenpachi, Kenpachi])),
        30000..=30999 => m.gate_seed0 = c - 30000,
        31101..=31199 => m.gate_seeds = c - 31100,
        200000..=209999 => start_pair_gate(m, c / 100 % 10, c / 10 % 10),
        // ponytail: leaked once per run, on the path that stops it
        _ => crate::unported!(m, Box::leak(format!("debug {c}").into_boxed_str())),
    }
}

// ---------------------------------------------------------------- scenario helpers

/// port: ENSURE-BATTLE with `:cpu t` (the only form a trace records): a CPU vs CPU battle of C1 and C2, cinematics skipped into the
/// fight, unless one of exactly those is already in battle. (BRAIN-OFF: the CPU's, M2; a replay detaches the brains anyway.)
pub fn ensure_battle(m: &mut Match, c1: Character, c2: Character) {
    let ch = |e: Entity| m.fighter.get(e).and_then(|f| f.character);
    if m.flow == Flow::Battle && ch(m.p1) == Some(c1) && ch(m.p2) == Some(c2) {
        return;
    }
    (m.picks, m.mode) = ([c1, c2], Mode::CpuCpu);
    let skip = std::mem::replace(&mut m.skip_cines, true); // (let ((*skip-cines* t)) …)
    crate::flow::start_match(m);
    m.skip_cines = skip;
}

/// port: PLACE of P1 and P2: DIST m apart on the x axis around the centre, facing, idle; no hazards. (fx-clear, `*punch-t*` and
/// the models' flash are looks.)
pub fn place(m: &mut Match, dist: f32) {
    crate::hazards::clear_hazards(m);
    m.time.reset();
    let (a, b) = (m.p1, m.p2);
    m.transform.get_mut(a).expect("P1").pos = [-0.5 * dist, 0.0, 0.0];
    m.transform.get_mut(b).expect("P2").pos = [0.5 * dist, 0.0, 0.0];
    crate::cine::face_each_other(m, a, b, None);
    for e in [a, b] {
        crate::fighter::to_idle(m, e);
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

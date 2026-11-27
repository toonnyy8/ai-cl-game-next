//! The style CPUs' registry (ruling R1): a style function's Lisp name (`*cai-styles*`, a strategy's :FN) to its port. A style runs
//! on every step its CPU is free to press, before the generic CPU, and says whether it decided this step.
use super::{perceive::Snap, Brain, Search};
use crate::components::Character;
use crate::ecs::Entity;
use crate::hashline::Enc;
use crate::state::Match;
use duel_data::tuning::Value;
use duel_data::Data;

/// A style function: (e b f kit s d) -> T when it decided this step. The brain is taken out of its fighter while the CPU steps.
pub type StyleFn = fn(&mut Match, &mut Search, Entity, &mut Brain, Snap, f32) -> bool;

/// Every style function a strategy or `*cai-styles*` names, with the stop its replay reports while it is not ported.
const STYLES: [(&str, &str); 10] = [
    ("KEN-KI-STYLE", "style KEN-KI-STYLE"),
    ("KEN-KH-STYLE", "style KEN-KH-STYLE"),
    ("KEN-KH-STANDOFF-STYLE", "style KEN-KH-STANDOFF-STYLE"),
    ("ICHIGO-KI-STYLE", "style ICHIGO-KI-STYLE"),
    ("ICHIGO-KI-R2B2A1-STYLE", "style ICHIGO-KI-R2B2A1-STYLE"),
    ("HISAGI-MERGED-STYLE", "style HISAGI-MERGED-STYLE"),
    ("HISAGI-RANGE-STYLE", "style HISAGI-RANGE-STYLE"),
    ("HISAGI-HK-STYLE", "style HISAGI-HK-STYLE"),
    ("HISAGI-IHR1B2A0-STYLE", "style HISAGI-IHR1B2A0-STYLE"),
    ("HISAGI-OWN-STYLE", "style HISAGI-OWN-STYLE"),
];

/// A style function's identity (BRAIN-SW-FN, a `*cai-styles*` entry): Lisp compares them EQ, which is the same name.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct StyleId(u8);

impl StyleId {
    /// The style named NAME (any case), or None (no such style: the Lisp's SYMBOL-FUNCTION would error).
    pub fn of(name: &str) -> Option<StyleId> {
        STYLES.iter().position(|(n, _)| n.eq_ignore_ascii_case(name)).map(|i| StyleId(i as u8))
    }
    pub fn name(self) -> &'static str {
        STYLES[self.0 as usize].0
    }
}

/// TR-B-ENC of a function: `#FN`.
impl Enc for StyleId {
    fn enc(&self, _: &Data, s: &mut String) {
        s.push_str("#FN");
    }
}

/// The port of the style named NAME (upper case, `KEN-KI-STYLE`), or None (not ported: its caller is `unported!`).
pub fn resolve(_name: &str) -> Option<StyleFn> {
    None // (Kenpachi's KEN-KI / -KH / -KH-STANDOFF: Task 6; Ichigo's ICHIGO-KI / -KI-R2B2A1: Task 7; Hisagi's HISAGI-*: M4)
}

/// Run style ID for E's step (`(funcall fn e b f kit s d)`): T when it decided. Not ported: `unported!("style <NAME>")`.
pub fn run(m: &mut Match, s: &mut Search, id: StyleId, e: Entity, b: &mut Brain, snap: Snap, d: f32) -> bool {
    match resolve(id.name()) {
        Some(f) => f(m, s, e, b, snap, d),
        None => crate::unported!(m, STYLES[id.0 as usize].1, false),
    }
}

/// `*cai-styles*` (core-ai.lisp; `(own (opp fn ...) ...)`, filled by CAI-DEFSTYLE at load): typed once from tuning.json.
#[derive(Debug, Clone, Default)]
pub struct CaiStyles(pub Vec<(String, Vec<(String, StyleId)>)>);

impl CaiStyles {
    /// port: CAI-STYLE-FN's lookup: ME's style against VS (GETF of GETF), or NIL.
    pub fn get(&self, me: Character, vs: Character) -> Option<StyleId> {
        let (_, opps) = self.0.iter().find(|(c, _)| c.eq_ignore_ascii_case(me.name()))?;
        opps.iter().find(|(c, _)| c.eq_ignore_ascii_case(vs.name())).map(|&(_, f)| f)
    }
}

impl duel_data::tuning::Knob for CaiStyles {
    const KIND: &'static str = "a plist (own (opp style-name ...) ...)";
    fn from_value(v: &Value) -> Option<CaiStyles> {
        fn pl(v: &Value) -> Option<std::slice::Chunks<'_, Value>> {
            v.as_array().filter(|a| a.len() % 2 == 0).map(|a| a.chunks(2))
        }
        let own = pl(v)?.map(|c| {
            let opps = pl(&c[1])?.map(|o| Some((o[0].as_str()?.to_string(), StyleId::of(o[1].as_str()?)?))).collect::<Option<Vec<_>>>()?;
            Some((c[0].as_str()?.to_string(), opps))
        });
        own.collect::<Option<Vec<_>>>().map(CaiStyles)
    }
}

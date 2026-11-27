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
pub fn resolve(name: &str) -> Option<StyleFn> {
    use super::{ichigo_ki, ken_ki};
    match name {
        "KEN-KI-STYLE" => Some(ken_ki::ken_ki_style),
        "KEN-KH-STYLE" => Some(ken_ki::ken_kh_style),
        "KEN-KH-STANDOFF-STYLE" => Some(ken_ki::ken_kh_standoff_style),
        "ICHIGO-KI-STYLE" => Some(ichigo_ki::ichigo_ki_style),
        "ICHIGO-KI-R2B2A1-STYLE" => Some(ichigo_ki::ichigo_ki_r2b2a1_style),
        _ => None, // (Hisagi's HISAGI-*: M4)
    }
}

/// BRAIN-STYLE: a style's state struct (each style makes its own on a NIL or another type's slot, or a lower tick: a new match).
/// Every slot is a scalar, so it is `Copy` and a step allocates nothing.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum StyleState {
    /// cpu-ki-ken.lisp KKS (KEN-KI-STYLE's).
    Kks(super::ken_ki::Kks),
    /// cpu-kh-ken.lisp KHS (:include kks; KEN-KH-STYLE's).
    Khs(super::ken_ki::Khs),
    /// cpu-kh-ken.lisp KSO (:include kks; KEN-KH-STANDOFF-STYLE's).
    Kso(super::ken_ki::Kso),
    /// cpu-ki-ichigo.lisp IKST (ICHIGO-KI-STYLE's).
    Ikst(super::ichigo_ki::Ikst),
    /// cpu-ki-ichigo-r2b2a1.lisp IKW (:include ikst; ICHIGO-KI-R2B2A1-STYLE's).
    Ikw(super::ichigo_ki::Ikw),
}

impl StyleState {
    /// The included KKS of Kenpachi's structs (KKS-P), else None.
    pub fn kks(&self) -> Option<&super::ken_ki::Kks> {
        match self {
            StyleState::Kks(k) => Some(k),
            StyleState::Khs(h) => Some(&h.k),
            StyleState::Kso(o) => Some(&o.k),
            _ => None,
        }
    }
    /// The included KKS. ponytail: panics on another style's struct (the Lisp's KKS-TICK would error); callers took it through
    /// `take_style` with a Kenpachi variant check.
    pub fn kks_mut(&mut self) -> &mut super::ken_ki::Kks {
        match self {
            StyleState::Kks(k) => k,
            StyleState::Khs(h) => &mut h.k,
            StyleState::Kso(o) => &mut o.k,
            _ => panic!("not a KKS"),
        }
    }
    /// The included IKST of Ichigo's structs (IKST-P), else None.
    pub fn ikst_mut(&mut self) -> Option<&mut super::ichigo_ki::Ikst> {
        match self {
            StyleState::Ikst(k) => Some(k),
            StyleState::Ikw(w) => Some(&mut w.k),
            _ => None,
        }
    }
}

/// TR-B-ENC of a struct: `#TYPE{slot,...}`.
impl Enc for StyleState {
    fn enc(&self, d: &Data, s: &mut String) {
        match self {
            StyleState::Kks(k) => {
                s.push_str("#KKS{");
                k.enc(d, s);
            }
            StyleState::Khs(h) => {
                s.push_str("#KHS{");
                h.enc(d, s);
            }
            StyleState::Kso(o) => {
                s.push_str("#KSO{");
                o.enc(d, s);
            }
            StyleState::Ikst(k) => {
                s.push_str("#IKST{");
                k.enc(d, s);
            }
            StyleState::Ikw(w) => {
                s.push_str("#IKW{");
                w.enc(d, s);
            }
        }
        s.push('}');
    }
}

/// Take E's style struct out of B for a style's step: the slot's own when OK says so, else a fresh one from MAKE (the old one stays
/// in a kept entry it was EQ to: `Brain::style_replaced`).
pub(crate) fn take_style(b: &mut Brain, ok: impl FnOnce(&StyleState) -> bool, make: impl FnOnce() -> StyleState) -> StyleState {
    match b.style.take() {
        Some(st) if ok(&st) => st,
        old => {
            b.style_replaced(old);
            make()
        }
    }
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

//! port: duel/lisp/fuzzy.lisp (the sets, the difficulty scaling, the rule bases: knobs from tuning.json) and engine/lisp/fuzzy.lisp
//! (FZ-MU, FZ-INFER: a zero-order Sugeno over trapezoids). A set's corners and a cue are CL numbers (`cl::Num`): `(:near -1 0 1.6 2.4)`
//! mixes integers and singles, and `(- x a)` of two integers stays exact before its division by a single.
use crate::cl::Num;
use crate::components::Difficulty;
use crate::knobs::Knobs;
use duel_data::tuning::{Knob, Value};

fn num_of(v: &Value) -> Option<Num> {
    if v.is_i64() { v.as_i64().map(Num::I) } else { v.as_f64().map(|x| Num::F(x as f32)) }
}

/// `*fz-sets*`: name -> trapezoid (A B C D).
#[derive(Debug, Clone, Default)]
pub struct FzSets(pub Vec<(String, [Num; 4])>);

impl Knob for FzSets {
    const KIND: &'static str = "a list of (name a b c d)";
    fn from_value(v: &Value) -> Option<FzSets> {
        let set = |e: &Value| -> Option<(String, [Num; 4])> {
            let e = e.as_array().filter(|e| e.len() == 5)?;
            Some((e[0].as_str()?.to_string(), [num_of(&e[1])?, num_of(&e[2])?, num_of(&e[3])?, num_of(&e[4])?]))
        };
        v.as_array()?.iter().map(set).collect::<Option<Vec<_>>>().map(FzSets)
    }
}

/// One rule (ANTECEDENTS OUTPUT [:MUST]): every (FEATURE SET) must hold.
#[derive(Debug, Clone)]
pub struct FzRule {
    pub ante: Vec<(String, String)>,
    pub out: f32,
    pub must: bool,
}

/// A rule base (`*fz-as-now*` …).
#[derive(Debug, Clone, Default)]
pub struct FzRules(pub Vec<FzRule>);

impl Knob for FzRules {
    const KIND: &'static str = "a list of (((feature set) ...) output [:must])";
    fn from_value(v: &Value) -> Option<FzRules> {
        let rule = |r: &Value| -> Option<FzRule> {
            let r = r.as_array()?;
            let ante = r.first()?.as_array()?.iter().map(|c| Some((c[0].as_str()?.to_string(), c[1].as_str()?.to_string())));
            let must = match r.get(2) {
                None => false,
                Some(x) => (x.as_str()? == "must").then_some(true)?,
            };
            Some(FzRule { ante: ante.collect::<Option<Vec<_>>>()?, out: r.get(1)?.as_f64()? as f32, must })
        };
        v.as_array()?.iter().map(rule).collect::<Option<Vec<_>>>().map(FzRules)
    }
}

/// A rule base's kind (FZ-SCALE).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Kind {
    /// A read, a Hoho, a hold: times the skill.
    Skill,
    /// One option or another: pulled toward 1/2 as the skill falls.
    Choice,
}

/// The cue plist a CPU fills (`(:ons 1 :press 0.2)`): (name, value), names in lower case.
pub type Feats<'a> = [(&'a str, Num)];

/// port: FZ-MU — X's membership in the set named SET (a name missing from `*fz-sets*` is the Lisp's error: a panic).
pub fn fz_mu(sets: &FzSets, x: Num, set: &str) -> f32 {
    let [a, b, c, d] = sets.0.iter().find(|(n, _)| n.eq_ignore_ascii_case(set)).unwrap_or_else(|| panic!("no fuzzy set {set}")).1;
    if x.lt(a) || d.lt(x) {
        0.0
    } else if x.lt(b) {
        (x - a).f() / (b - a).f()
    } else if !c.lt(x) {
        1.0
    } else {
        (d - x).f() / (d - c).f()
    }
}

/// port: FZ-INFER — RULES' answer for FEATS (a cue missing reads 0): a :MUST rule holding at least half way alone, else the outputs
/// averaged by the rules' strengths, DEFAULT if none fires.
pub fn fz_infer(sets: &FzSets, rules: &FzRules, feats: &Feats, default: f32) -> f32 {
    let cue = |f: &str| feats.iter().find(|(n, _)| n.eq_ignore_ascii_case(f)).map_or(Num::I(0), |&(_, v)| v);
    let (mut num, mut den) = (0.0f32, 0.0f32);
    for r in &rules.0 {
        let mut w: Option<f32> = None; // (LOOP MINIMIZE: the first value, then each lower one)
        for (f, set) in &r.ante {
            let mu = fz_mu(sets, cue(f), set);
            if w.is_none_or(|w| mu < w) {
                w = Some(mu);
            }
        }
        let w = w.unwrap_or(0.0);
        if r.must && w >= 0.5 {
            return r.out;
        }
        num += w * r.out;
        den += w;
    }
    if den > 0.0 { num / den } else { default }
}

/// port: FZ-SCALE — chance P of the HARD player at difficulty DIF.
pub fn fz_scale(k: &Knobs, p: f32, dif: Difficulty, kind: Kind) -> f32 {
    let s = k.fz_skill.get_or(dif.name(), 0.62);
    match kind {
        Kind::Skill => p * s,
        Kind::Choice => 0.5 + (p - 0.5) * s,
    }
}

/// port: FZ-CHANCE — RULES' chance for FEATS at DIF.
pub fn fz_chance(k: &Knobs, rules: &FzRules, feats: &Feats, dif: Difficulty, kind: Kind, default: f32) -> f32 {
    fz_scale(k, fz_infer(&k.fz_sets, rules, feats, default), dif, kind)
}

//! port: duel/lisp/xch-ai.lisp — the core CPU's exchange after a cancel and its clash, as pure functions over the triangle
//! (core.rs); core_ai.rs plays them (CAI-XCH-NEW, CAI-XCH-STEP, CAI-CLASH).
use crate::cl::{max_f32, min_f32};
use crate::components::{Contact, Difficulty};
use crate::core::{core_cancelled_p, core_verdict, Verdict};
use duel_data::tuning::{Knob, Value};
use duel_data::MoveClass::{self, As, Na, Ns, Sa};

/// Which side of a cancel a move stands on (XCH-SIDE's :J / :NS).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum XchSide {
    J,
    Ns,
}

/// The J side's answer (XCH-J-ANSWER's :AS / :J).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum JAnswer {
    As,
    J,
}

/// A J side's weight plist `(:as A :j J)`.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct XchW {
    pub as_w: f32,
    pub j: f32,
}

/// `*cai-xch-j*`: a weight plist per difficulty.
#[derive(Debug, Clone, Default)]
pub struct XchJ(pub Vec<(String, XchW)>);

impl XchJ {
    /// port: BRAIN-CHANCE over it: DIF's plist, else NORMAL's (the Lisp's 0.0 fallback is no plist: a panic).
    pub fn get(&self, dif: Difficulty) -> XchW {
        let find = |k: &str| self.0.iter().find(|(n, _)| n.eq_ignore_ascii_case(k)).map(|&(_, w)| w);
        find(dif.name()).or_else(|| find("normal")).expect("*cai-xch-j* has no NORMAL")
    }
}

impl Knob for XchJ {
    const KIND: &'static str = "a plist of difficulty / (:as a :j j)";
    fn from_value(v: &Value) -> Option<XchJ> {
        let a = v.as_array()?;
        let ws = |w: &Value| -> Option<XchW> {
            let w = w.as_array()?;
            let get = |k: &str| w.chunks(2).find(|c| c[0].as_str() == Some(k)).map_or(Some(0.0), |c| c.get(1)?.as_f64());
            Some(XchW { as_w: get("as")? as f32, j: get("j")? as f32 })
        };
        a.chunks(2).map(|c| Some((c[0].as_str()?.to_string(), ws(c.get(1)?)?))).collect::<Option<Vec<_>>>().map(XchJ)
    }
}

/// port: XCH-SIDE — the side of a cancel a CPU's move in play (class CLS, CONTACT, begun on tick CLS-T; his exchange XCH) stands on.
pub fn xch_side(cls: Option<MoveClass>, contact: Option<Contact>, xch: i64, cls_t: i64) -> Option<XchSide> {
    if !core_cancelled_p(xch, cls_t) {
        return None;
    }
    let hit = contact == Some(Contact::Hit);
    match cls? {
        Ns => Some(XchSide::Ns),
        Na => hit.then_some(XchSide::J),
        Sa => (hit && xch > cls_t).then_some(XchSide::J),
        As => None,
    }
}

/// port: engine/lisp/math.lisp WEIGHTED-PICK — the key whose share of the total weight contains R (0 <= R < 1); NIL if all are 0.
pub fn weighted_pick<K: Copy>(r: f32, kv: &[(K, f32)]) -> Option<K> {
    let sum = kv.iter().fold(0.0f32, |s, &(_, w)| s + w);
    if sum > 0.0 {
        let mut x = sum * r;
        for &(key, w) in kv {
            x -= w;
            if x < 0.0 && w > 0.0 {
                return Some(key);
            }
        }
    }
    None
}

/// port: XCH-J-ANSWER — the J side's answer for the roll R over WS, only when REACH-OK (else NIL: he holds).
pub fn xch_j_answer(r: f32, ws: XchW, reach_ok: bool) -> Option<JAnswer> {
    if reach_ok { weighted_pick(r, &[(JAnswer::As, ws.as_w), (JAnswer::J, ws.j)]) } else { None }
}

/// port: XCH-J-WEIGHTS — WS under a strategy's scale K on the J's share (within 0-1, the AS the rest); K NIL or no weight: WS.
pub fn xch_j_weights(ws: XchW, k: Option<f32>) -> XchW {
    let tot = ws.as_w + ws.j;
    match k {
        Some(k) if tot > 0.0 => {
            let j1 = max_f32(0.0, min_f32(1.0, k * (ws.j / tot)));
            XchW { as_w: 1.0 - j1, j: j1 }
        }
        _ => ws,
    }
}

/// port: XCH-TURN-SEEN-P — does the NS side see a J side's attack its SA beats (his perceived move OCLS begun on OSTART)?
pub fn xch_turn_seen_p(ocls: Option<MoveClass>, ostart: i64, xch: i64, own_hit: bool) -> bool {
    (matches!(ocls, Some(As | Na)) && ostart > xch) || (own_hit && matches!(ocls, Some(Na | Sa)))
}

/// port: CLASH-OPENER — the class (:NA or :NS) thrown into his OCLS to cancel it whichever hit lands first.
pub fn clash_opener(ocls: Option<MoveClass>) -> Option<MoveClass> {
    ocls?;
    [Na, Ns].into_iter().find(|&c| core_verdict(Some(c), ocls, false, None, None) == Verdict::Cancel && core_verdict(ocls, Some(c), false, None, None) == Verdict::Cancel)
}

/// port: CLASH-WINDOW — (the frame after which his hit is spent, its reach): his own windows (HITS-N > 0), else a later hit
/// (:hit-at, :hit-reach); NIL when neither.
pub fn clash_window(hits_n: i64, active_end: i64, reach: f32, hit_at: Option<i64>, hit_reach: Option<f32>) -> Option<(i64, Option<f32>)> {
    if hits_n > 0 {
        Some((active_end, Some(reach)))
    } else {
        hit_at.map(|h| (h + 1, hit_reach))
    }
}

/// port: XCH-SA-NOW-P — press the NS side's SA now on tick NOW?
pub fn xch_sa_now_p(ocls: Option<MoveClass>, ostart: i64, xch: i64, own_hit: bool, now: i64, wait: i64) -> bool {
    xch_turn_seen_p(ocls, ostart, xch, own_hit) && ((matches!(ocls, Some(As | Na)) && ostart > xch) || now - xch >= wait)
}

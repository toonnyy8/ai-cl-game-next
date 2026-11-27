//! port: duel/lisp/strategy.lisp's code (lines 1-843 and 4439-end). The library is data: tables.json `strat_library` (expanded at
//! load, as *STRAT-LIBRARY*), `strat_units_expanded`, `strat_units`, `strat_data`, `strat_styles`, `strat_rule_bases`, `strat_payoff`,
//! `strat_lookup`; nothing is retyped. A strategy is read straight from that JSON (`Strat`, a `&'static` value compared by EQ), so
//! a battle step allocates nothing.
//!
//! The JSON plists: the extractor writes a plist as an object with GETF's first-wins rule applied (extract.lisp X-STRAT; no shipped
//! plist repeats a key), and `plist_get` also reads a flat array `[k, v, k, v ...]` first-match, the form a composite's `:switch`
//! entry takes (`[OWN, k, v ...]`, a dotted cons) and the one a test uses for a repeated key. NIL is `null`.
//!
//! Not ported (tools only): STRAT-FINGERPRINT, STRAT-SIMILARITY.
use super::fuzzy::{fz_mu, num_of, FzSets};
use crate::cl::{floor_f32, max_f32, min_f32, modulo, round_f32, Num};
use crate::components::{Character, Difficulty, State};
use crate::hashline::Enc;
use crate::knobs::Knobs;
use duel_data::tuning::Value;
use duel_data::Data;

/// Arms a Q selector may have (the library's largest has 8; `*strat-picks*`-style vectors are sized by it).
pub const MAX_ARMS: usize = 16;

/// port: GETF over a JSON plist: an object's key, or a flat array's first match; NIL (`null`, or no such key) is None.
pub fn plist_get<'a>(v: &'a Value, key: &str) -> Option<&'a Value> {
    let r = match v {
        Value::Object(o) => o.get(key),
        Value::Array(a) => a.chunks(2).find(|c| c[0].as_str() == Some(key)).and_then(|c| c.get(1)),
        _ => None,
    };
    r.filter(|x| !x.is_null())
}

fn arr(v: Option<&Value>) -> &[Value] {
    v.and_then(Value::as_array).map_or(&[], |a| a.as_slice())
}

/// A strategy plist (a library entry, a Q selector's arm, a composite's sub): the tables.json value, `'static`, compared by EQ
/// (`std::ptr::eq`), as BRAIN-STRAT / -SW-SUB / -EV-ON and NOW hold the Lisp plist. ponytail: a player's fq copy (Task 9, FQ-TABLE)
/// is a fresh table, not in tables.json: Task 9 turns this into an enum with an owned case.
#[derive(Clone, Copy)]
pub struct Strat(pub &'static Value);

impl PartialEq for Strat {
    fn eq(&self, o: &Strat) -> bool {
        std::ptr::eq(self.0, o.0)
    }
}

impl std::fmt::Debug for Strat {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "#s::{}", self.id().unwrap_or("?").to_uppercase())
    }
}

impl Strat {
    /// GETF on the strategy: an object's key, or a composite entry's plist (`[OWN, k, v ...]`: from its second element).
    pub fn get(self, key: &str) -> Option<&'static Value> {
        match self.0 {
            Value::Array(a) if a.len() % 2 == 1 => {
                a[1..].chunks(2).find(|c| c[0].as_str() == Some(key)).and_then(|c| c.get(1)).filter(|x| !x.is_null())
            }
            v => plist_get(v, key),
        }
    }
    /// Its :ID (lower case, as tables.json: "t0-ki-ichigo").
    pub fn id(self) -> Option<&'static str> {
        self.get("id").and_then(Value::as_str)
    }
    /// Its Q selector (:FQ), if it is one.
    pub fn fq(self) -> Option<&'static Value> {
        self.get("fq")
    }
}

/// trace.lisp TR-A-STRAT: `#s:` + the :ID keyword.
impl Enc for Strat {
    fn enc(&self, _: &Data, s: &mut String) {
        s.push_str("#s::");
        s.push_str(&self.id().unwrap_or("?").to_uppercase());
    }
}

/// port: STRAT-BY-ID — the library entry ID, or NIL.
pub fn strat_by_id(d: &'static Data, id: &str) -> Option<Strat> {
    arr(d.tables.get("strat_library")).iter().find(|s| s["id"].as_str().is_some_and(|x| x.eq_ignore_ascii_case(id))).map(Strat)
}

// ---------------------------------------------------------------- the cues

/// A cue plist (STRAT-FEATS' list, a judgement's `(:prev p ...)`): (name, value) pairs read first-match, a missing cue 0. Fixed
/// capacity (the longest, a judgement's, has 28), so a step allocates nothing.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Cues {
    n: u8,
    kv: [(&'static str, Num); 32],
}

impl Default for Cues {
    fn default() -> Cues {
        Cues { n: 0, kv: [("", Num::I(0)); 32] }
    }
}

impl Cues {
    pub fn push(&mut self, k: &'static str, v: Num) {
        self.kv[self.n as usize] = (k, v);
        self.n += 1;
    }
    pub fn as_slice(&self) -> &[(&'static str, Num)] {
        &self.kv[..self.n as usize]
    }
    /// `(getf feats key 0)`.
    pub fn get(&self, key: &str) -> Num {
        cue(self.as_slice(), key)
    }
}

/// `(getf feats key 0)` over a cue slice.
pub fn cue(feats: &[(&str, Num)], key: &str) -> Num {
    feats.iter().find(|(k, _)| *k == key).map_or(Num::I(0), |&(_, v)| v)
}

/// The brain's NOW (CORE-BRAIN-STEP): the active strategy and its cue plist this step (STRAT-FEATS), `(strategy . cues)`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Now {
    pub st: Strat,
    pub cues: Cues,
}

/// TR-B-ENC of the cons `(strategy . cues)` (never in a step-end A line: NOW is NIL there).
impl Enc for Now {
    fn enc(&self, d: &Data, s: &mut String) {
        s.push('(');
        self.st.enc(d, s);
        for (k, v) in self.cues.as_slice() {
            s.push_str(",:");
            s.push_str(&k.to_uppercase());
            s.push(',');
            v.enc(d, s);
        }
        s.push(')');
    }
}

// ---------------------------------------------------------------- outputs

/// port: STRAT-ANTE — the strength of one antecedent ANTE `((cue set) ...)` for FEATS: the minimum of the cues' memberships (1 for none).
pub fn strat_ante(sets: &FzSets, ante: &Value, feats: &[(&str, Num)]) -> f32 {
    let mut w = 1.0f32;
    for c in arr(Some(ante)) {
        let mu = fz_mu(sets, cue(feats, c[0].as_str().expect("a cue")), c[1].as_str().expect("a set"));
        if mu < w {
            w = mu;
        }
    }
    w
}

/// port: STRAT-VALUE — ST's output KEY for FEATS: the rules naming KEY averaged by strength, else its :BASE value (an integer stays
/// one), else NIL.
pub fn strat_value(sets: &FzSets, st: Strat, key: &str, feats: &[(&str, Num)]) -> Option<Num> {
    let (mut num, mut den) = (0.0f32, 0.0f32);
    for r in arr(st.get("rules")) {
        if let Some(v) = plist_get(&r[1], key).and_then(num_of) {
            let w = strat_ante(sets, &r[0], feats);
            if w > 0.0 {
                num += w * v.f();
                den += w;
            }
        }
    }
    if den > 0.0 { Some(Num::F(num / den)) } else { st.get("base").and_then(|b| plist_get(b, key)).and_then(num_of) }
}

/// port: STRAT-OUT — the active strategy's KEY now, or DEFAULT (no strategy, or it leaves KEY alone).
pub fn strat_out(sets: &FzSets, now: Option<&Now>, key: &str, default: Option<Num>) -> Option<Num> {
    now.and_then(|n| strat_value(sets, n.st, key, n.cues.as_slice())).or(default)
}

/// port: STRAT-SCALE — chance P times the active strategy's scale KEY (none: P), kept within 0-1.
pub fn strat_scale(sets: &FzSets, now: Option<&Now>, key: &str, p: f32) -> f32 {
    strat_out(sets, now, key, None).map_or(p, |k| max_f32(0.0, min_f32(1.0, p * k.f())))
}

/// port: STRAT-MUL of a float V (a margin): V times KEY, kept >= 0, not clamped above (none: V).
pub fn strat_mul(sets: &FzSets, now: Option<&Now>, key: &str, v: f32) -> f32 {
    strat_out(sets, now, key, None).map_or(v, |k| max_f32(0.0, v * k.f()))
}

/// port: STRAT-MUL of an integer V (a wait in frames): V times KEY rounded half up, kept >= 0 (none: V).
pub fn strat_mul_int(sets: &FzSets, now: Option<&Now>, key: &str, v: i64) -> i64 {
    strat_out(sets, now, key, None).map_or(v, |k| match k {
        Num::I(k) => 0.max(floor_f32((v * k) as f32 + 0.5)),
        Num::F(k) => 0.max(floor_f32(v as f32 * k + 0.5)),
    })
}

// ---------------------------------------------------------------- the DRIVE switch's target (DUEL_AI_STRATEGY §8.16)

/// port: STRAT-SWITCH-TO — the pointer a switch from PTR (of N) goes to at distance D: TO when its NS opener's band holds D, else the
/// first of the next pointers (cyclic) whose band does; BANDS = a (lo hi) per pointer (index 0 = pointer 1; None: no NS). None: none.
pub fn strat_switch_to(ptr: i64, n: i64, d: f32, bands: &[Option<(f32, f32)>], to: Option<i64>) -> Option<i64> {
    let ok = |p: i64| {
        1 <= p && p <= n && p != ptr && bands.get((p - 1) as usize).copied().flatten().is_some_and(|(lo, hi)| lo <= d && d <= hi)
    };
    match to {
        Some(to) => ok(to).then_some(to),
        None => (1..n).map(|k| 1 + modulo(ptr - 1 + k, n)).find(|&p| ok(p)),
    }
}

/// port: STRAT-SWITCH-DIR — the stick's strafe sign that switches PTR (of N) to TO: +1 the next (cyclic), -1 the previous.
pub fn strat_switch_dir(ptr: i64, to: i64, n: i64) -> i64 {
    if to == 1 + modulo(ptr, n) { 1 } else { -1 }
}

// ---------------------------------------------------------------- composites and Q selectors

/// port: STRAT-OWN — OWN's strength for FEATS: the maximum over its antecedents.
pub fn strat_own(sets: &FzSets, own: &Value, feats: &[(&str, Num)]) -> f32 {
    arr(Some(own)).iter().fold(0.0f32, |w, a| max_f32(w, strat_ante(sets, a, feats)))
}

/// port: STRAT-JUDGE — the composite SW's sub for FEATS and its index (the first :SWITCH entry whose OWN fires at >= 0.5, else its
/// :ELSE and -1); a Q selector's chosen arm (None: its NIL arm) and the arm's index.
pub fn strat_judge(sets: &FzSets, sw: Strat, feats: &[(&str, Num)]) -> (Option<Strat>, i64) {
    if let Some(fq) = sw.fq() {
        let k = strat_fq_pick(sets, fq, feats);
        let arm = arr(plist_get(fq, "arms")).get(k).filter(|a| !a.is_null());
        return (arm.map(Strat), k as i64);
    }
    for (i, en) in arr(sw.get("switch")).iter().enumerate() {
        if strat_own(sets, &en[0], feats) >= 0.5 {
            return (Some(Strat(en)), i as i64);
        }
    }
    (sw.get("else").map(Strat), -1)
}

/// A Q selector's value per arm (STRAT-FQ-Q's simple-vector): the first `n` of `q`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Qv {
    pub n: usize,
    pub q: [f32; MAX_ARMS],
}

impl Qv {
    pub fn as_slice(&self) -> &[f32] {
        &self.q[..self.n]
    }
}

/// The rule's q of arm K (`(nth (1+ k) r)`).
fn rule_q(r: &Value, k: usize) -> f32 {
    num_of(&r[k + 1]).expect("a q").f()
}

/// port: STRAT-FQ-Q — FQ's value per arm for FEATS: the q averaged by the rules' firing strengths (0 when none fires); with :GROUPS,
/// each group averaged on its own and Q their sum.
pub fn strat_fq_q(sets: &FzSets, fq: &Value, feats: &[(&str, Num)]) -> Qv {
    let n = arr(plist_get(fq, "arms")).len();
    assert!(n <= MAX_ARMS, "a Q selector with {n} arms");
    let rules = arr(plist_get(fq, "rules"));
    let mut out = Qv { n, q: [0.0; MAX_ARMS] };
    let fire = |rs: &[Value], num: &mut [f32; MAX_ARMS]| -> f32 {
        let mut den = 0.0f32;
        for r in rs {
            let w = strat_ante(sets, &r[0], feats);
            if w > 0.0 {
                den += w;
                for (k, x) in num.iter_mut().enumerate().take(n.min(r.as_array().map_or(0, |a| a.len() - 1))) {
                    *x += w * rule_q(r, k);
                }
            }
        }
        den
    };
    match plist_get(fq, "groups") {
        Some(groups) => {
            let mut at = 0;
            for g in arr(Some(groups)) {
                let g = g.as_u64().expect("a group size") as usize;
                let mut num = [0.0f32; MAX_ARMS];
                let den = fire(&rules[at..at + g], &mut num);
                at += g;
                if den > 0.0 {
                    for (x, y) in out.q.iter_mut().zip(num).take(n) {
                        *x += y / den;
                    }
                }
            }
        }
        None => {
            let den = fire(rules, &mut out.q);
            if den > 0.0 {
                for x in &mut out.q[..n] {
                    *x /= den;
                }
            }
        }
    }
    out
}

/// port: STRAT-FQ-PICK — FQ's arm index for FEATS: argmax Q (ties: the first), the previous arm (:PREV) while it trails by less
/// than :MARGIN.
pub fn strat_fq_pick(sets: &FzSets, fq: &Value, feats: &[(&str, Num)]) -> usize {
    let q = strat_fq_q(sets, fq, feats);
    let q = q.as_slice();
    let mut best = 0;
    for k in 0..q.len() {
        if q[k] > q[best] {
            best = k;
        }
    }
    let p = cue(feats, "prev").int().expect(":prev an integer");
    match plist_get(fq, "margin").and_then(num_of) {
        Some(m) if 0 <= p && (p as usize) < q.len() && q[best] - q[p as usize] < m.f() => p as usize,
        _ => best,
    }
}

// ---------------------------------------------------------------- the online fuzzy Q's pure part (§8.14; the glue is Task 9's)

/// port: FQ-U01 — a uniform 0-1 number from (SEED TICK SIDE) alone: Park-Miller stirred four times.
pub fn fq_u01(seed: i64, tick: i64, side: i64) -> f64 {
    let mut x = 1 + modulo(seed * 1000003 + tick * 7919 + side * 104729, 2147483646);
    for _ in 0..4 {
        x = modulo(x * 48271, 2147483647);
    }
    x as f64 / 2147483647.0
}

/// port: FQ-EXPLORE-ARM — the arm a judgement of arm I (of N) plays for the uniform U: I unless U < EPS, then one of the others.
pub fn fq_explore_arm(u: f64, eps: f64, i: i64, n: i64) -> i64 {
    if eps > 0.0 && n > 1 && 0 <= i && u < eps {
        let k = (n - 2).min((u / eps * (n - 1) as f64).floor() as i64);
        if k >= i { k + 1 } else { k }
    } else {
        i
    }
}

/// port: FQ-QUANT — Q at the storage's resolution (*FQ-UNIT* UNIT).
pub fn fq_quant(q: f32, unit: i64) -> f32 {
    round_f32(q * unit as f32) as f32 / unit as f32
}

/// port: STRAT-FQ-FIRE — FQ's rules' firing strengths for FEATS, normalised to sum 1 (per group with :GROUPS; all 0 when none fires).
pub fn strat_fq_fire(sets: &FzSets, fq: &Value, feats: &[(&str, Num)]) -> Vec<f32> {
    let rules = arr(plist_get(fq, "rules"));
    let mut w: Vec<f32> = rules.iter().map(|r| strat_ante(sets, &r[0], feats)).collect();
    let groups: Vec<usize> = match plist_get(fq, "groups") {
        Some(g) => arr(Some(g)).iter().map(|x| x.as_u64().expect("a group size") as usize).collect(),
        None => vec![w.len()],
    };
    let mut i = 0;
    for g in groups {
        let den: f32 = w[i..i + g].iter().fold(0.0, |a, x| a + x);
        if den > 0.0 {
            w[i..i + g].iter_mut().for_each(|x| *x /= den);
        }
        i += g;
    }
    w
}

/// port: FQ-Q-AT — Q(s, A) of FQ at the normalised firing vector FIRE.
pub fn fq_q_at(fq: &Value, fire: &[f32], a: usize) -> f32 {
    arr(plist_get(fq, "rules")).iter().zip(fire).fold(0.0, |s, (r, x)| s + x * rule_q(r, a))
}

/// port: FQ-V-AT — V(s) of FQ at FIRE: sum_r alpha_r max_a q_r(a); with :GROUPS max_a Q(s, a).
pub fn fq_v_at(fq: &Value, fire: &[f32]) -> f32 {
    if plist_get(fq, "groups").is_some() {
        let n = arr(plist_get(fq, "arms")).len();
        (1..n).fold(fq_q_at(fq, fire, 0), |m, a| max_f32(m, fq_q_at(fq, fire, a)))
    } else {
        arr(plist_get(fq, "rules")).iter().zip(fire).fold(0.0, |s, (r, x)| {
            let n = r.as_array().unwrap().len() - 1;
            s + x * (1..n).fold(rule_q(r, 0), |m, k| max_f32(m, rule_q(r, k)))
        })
    }
}

/// One TD transition (FQ-TRANSITIONS' `(fire arm r next-fire)`).
#[derive(Clone, Debug, PartialEq)]
pub struct Trans {
    pub fire: Vec<f32>,
    pub arm: usize,
    pub r: f32,
    pub next: Option<Vec<f32>>,
}

/// port: FQ-TRANSITIONS — a match's transitions from RECS (its judgements in order: (fire arm h), H my health balance then): r =
/// SCALE x the change of H to the next judgement (to H-END at the last, plus WON).
pub fn fq_transitions(recs: &[(Vec<f32>, usize, f32)], h_end: f32, won: f32, scale: f32) -> Vec<Trans> {
    (0..recs.len())
        .map(|i| {
            let (fire, arm, h) = &recs[i];
            let nxt = recs.get(i + 1);
            let r = scale * (nxt.map_or(h_end, |n| n.2) - h) + if nxt.is_some() { 0.0 } else { won };
            Trans { fire: fire.clone(), arm: *arm, r, next: nxt.map(|n| n.0.clone()) }
        })
        .collect()
}

/// port: FQ-TD-UPDATE! — apply TRANS to the Q selector FQ in place (q_r(a) += ETA x alpha_r x delta / sum alpha^2), each q clamped
/// within BASE's +- CAP (None: unclamped) at the storage's resolution UNIT.
pub fn fq_td_update(fq: &mut Value, base: &Value, trans: &[Trans], eta: f32, gamma: f32, cap: Option<f32>, unit: i64) {
    for tr in trans {
        let ss = max_f32(1e-6, tr.fire.iter().fold(0.0, |s, x| s + x * x));
        let v = tr.next.as_ref().map_or(0.0, |nf| gamma * fq_v_at(fq, nf));
        let delta = (tr.r + v - fq_q_at(fq, &tr.fire, tr.arm)) / ss;
        let base_rules = arr(plist_get(base, "rules"));
        let rules = fq.get_mut("rules").and_then(Value::as_array_mut).expect("a Q selector's :rules");
        for ((rule, b0), &x) in rules.iter_mut().zip(base_rules).zip(&tr.fire) {
            if x > 0.0 {
                let q0 = rule_q(b0, tr.arm);
                let q = rule_q(rule, tr.arm) + eta * x * delta;
                let q = cap.map_or(q, |c| max_f32(q0 - c, min_f32(q0 + c, q)));
                rule[tr.arm + 1] = Value::from(fq_quant(q, unit) as f64);
            }
        }
    }
}

/// port: FQ-CHECKSUM — a small checksum of FQ's arms (each id's characters, NIL as nothing) and every q at UNIT.
pub fn fq_checksum(fq: &Value, unit: i64) -> i64 {
    let rules = arr(plist_get(fq, "rules"));
    let mut s = rules.len() as i64;
    let mut mix = |k: i64| s = modulo(31 * s + k, 999983);
    for a in arr(plist_get(fq, "arms")) {
        mix(1);
        let id = if a.is_string() { a.as_str() } else { plist_get(a, "id").and_then(Value::as_str) };
        for c in id.unwrap_or("").to_uppercase().chars() {
            mix(c as i64);
        }
    }
    for r in rules {
        for k in 0..r.as_array().unwrap().len() - 1 {
            mix(round_f32(rule_q(r, k) * unit as f32));
        }
    }
    s
}

/// port: FQ-ENCODE — the page's integers for the online FQ grown from BASE over N matches: format 1, BASE's checksum, N, every q x UNIT.
pub fn fq_encode(fq: &Value, base: &Value, n: i64, unit: i64) -> Vec<i64> {
    let mut v = vec![1, fq_checksum(base, unit), n];
    for r in arr(plist_get(fq, "rules")) {
        v.extend((0..r.as_array().unwrap().len() - 1).map(|k| round_f32(rule_q(r, k) * unit as f32)));
    }
    v
}

/// port: FQ-DECODE — the online table saved as CODES for the offline BASE: a copy of BASE with the saved q and its match count, or
/// None (empty, another format, another offline table's or the wrong size).
pub fn fq_decode(codes: &[i64], base: &Value, unit: i64) -> Option<(Value, i64)> {
    let nq: usize = arr(plist_get(base, "rules")).iter().map(|r| r.as_array().unwrap().len() - 1).sum();
    if !(codes.len() == 3 + nq && codes[0] == 1 && codes[1] == fq_checksum(base, unit)) {
        return None;
    }
    let mut fq = base.clone();
    let mut qs = codes[3..].iter();
    for r in fq.get_mut("rules").and_then(Value::as_array_mut).expect(":rules") {
        for c in r.as_array_mut().unwrap()[1..].iter_mut() {
            *c = Value::from((*qs.next().unwrap() as f32 / unit as f32) as f64);
        }
    }
    Some((fq, codes[2]))
}

// ---------------------------------------------------------------- the SP cues (§11.3, PLAN4 §2)

/// port: STRAT-SP-CUES — :MCELL / :OCELL the full flash-step cells (0-3), :MBURST / :OBURST, :XCH (an exchange open), pushed on OUT.
#[allow(clippy::too_many_arguments)]
pub fn strat_sp_cues(fs: f32, ofs: f32, burst: bool, oburst: bool, xch: i64, oxch: i64, fs_cell: f32, out: &mut Cues) {
    let cells = |x: f32| 3.min(floor_f32(x / fs_cell));
    out.push("mcell", Num::I(cells(fs)));
    out.push("ocell", Num::I(cells(ofs)));
    out.push("mburst", Num::I(burst as i64));
    out.push("oburst", Num::I(oburst as i64));
    out.push("xch", Num::I(crate::sp::sp_exchange_open_p(xch, oxch) as i64));
}

/// port: STRAT-SP2-CUES — :AWST (0 / 1 ready / 2 awakened), :OWALL, :TIME (LEFT of TOTAL frames), :MPTR / :OPTR (1-3), :SWOPEN.
#[allow(clippy::too_many_arguments)]
pub fn strat_sp2_cues(ready: bool, awakened: bool, owall: f32, left: i64, total: i64, ptr: i64, optr: i64, swopen: bool, out: &mut Cues) {
    let p3 = |p: i64| 1.max(3.min(p));
    out.push("awst", Num::I(if awakened { 2 } else { ready as i64 }));
    out.push("owall", Num::F(owall));
    out.push("time", Num::F(crate::rules::match_elapsed(left, total)));
    out.push("mptr", Num::I(p3(ptr)));
    out.push("optr", Num::I(p3(optr)));
    out.push("swopen", Num::I(swopen as i64));
}

// ---------------------------------------------------------------- the library's units (§10): load-time forms, owned values

/// port: STRAT-UNIT-FIND — the unit ID in UNITS (a list of plists keyed :ID), or the Lisp's error.
pub fn strat_unit_find<'a>(id: &str, units: &'a Value) -> &'a Value {
    arr(Some(units)).iter().find(|u| plist_get(u, "id").and_then(Value::as_str) == Some(id)).unwrap_or_else(|| panic!("strategy library: no unit {id}"))
}

/// The pairs of an object / flat-array plist, in order (NIL values kept).
fn pairs(v: &Value) -> Vec<(String, Value)> {
    match v {
        Value::Object(o) => o.iter().map(|(k, v)| (k.clone(), v.clone())).collect(),
        Value::Array(a) => a.chunks(2).map(|c| (c[0].as_str().expect("a key").to_string(), c[1].clone())).collect(),
        _ => vec![],
    }
}

/// Pairs to an object, GETF's first-wins (the extractor's rule).
fn object(ps: Vec<(String, Value)>) -> Value {
    let mut out = Value::Object(Default::default());
    let o = out.as_object_mut().unwrap();
    for (k, v) in ps {
        o.entry(k).or_insert(v);
    }
    out
}

/// port: STRAT-COMPOSE — U with its :STYLE and :DATA units expanded: the style's keys, then U's own, then the data's; :BASE the data's
/// then U's (first wins), :RULES likewise in order. U itself when it names neither.
pub fn strat_compose(d: &Data, u: &Value) -> Value {
    let (style, data) = (plist_get(u, "style"), arr(plist_get(u, "data")));
    if style.is_none() && data.is_empty() {
        return u.clone();
    }
    let style = style.map(|s| strat_unit_find(s.as_str().expect("a style id"), &d.tables["strat_styles"]));
    let data: Vec<&Value> = data.iter().map(|x| strat_unit_find(x.as_str().expect("a data id"), &d.tables["strat_data"])).collect();
    let mut out = vec![("id".to_string(), plist_get(u, "id").cloned().unwrap_or(Value::Null))];
    let mut base: Vec<(String, Value)> = data.iter().flat_map(|x| plist_get(x, "base").map(pairs).unwrap_or_default()).collect();
    base.extend(plist_get(u, "base").map(pairs).unwrap_or_default());
    let mut rules: Vec<Value> = data.iter().flat_map(|x| arr(plist_get(x, "rules")).to_vec()).collect();
    rules.extend(arr(plist_get(u, "rules")).iter().cloned());
    for pl in std::iter::once(u).chain(style).chain(data.iter().copied()) {
        for (k, v) in pairs(pl) {
            if !["id", "style", "data", "base", "rules"].contains(&k.as_str()) && !out.iter().any(|(kk, _)| *kk == k) {
                out.push((k, v));
            }
        }
    }
    if !base.is_empty() {
        out.push(("base".into(), object(base)));
    }
    if !rules.is_empty() {
        out.push(("rules".into(), Value::Array(rules)));
    }
    object(out)
}

/// port: STRAT-ARM — a table's or a composite's arm A: NIL stays NIL, an arm id its expanded unit, an inline plist composed.
pub fn strat_arm(d: &Data, a: &Value) -> Option<Value> {
    match a {
        Value::Null => None,
        Value::String(id) => Some(strat_unit_find(id, &d.tables["strat_units_expanded"]).clone()),
        _ => Some(strat_compose(d, a)),
    }
}

/// The output keys a rule `(ante outputs)` names.
fn rule_keys(r: &Value) -> Vec<String> {
    pairs(&r[1]).into_iter().map(|(k, _)| k).collect()
}

/// port: STRAT-WITH — ARM with the data UNITS (ids of `strat_data`, or inline plists) laid under it: ARM's own keys win (a top-level
/// key, its :BASE, a rule's output), an earlier unit over a later one; NIL stays NIL; no UNITS: ARM.
pub fn strat_with(d: &Data, arm: Option<Value>, units: &[Value]) -> Option<Value> {
    let arm = arm?;
    if units.is_empty() {
        return Some(arm);
    }
    let mut out: Vec<(String, Value)> = pairs(&arm).into_iter().filter(|(k, _)| k != "base" && k != "rules").collect();
    let mut base = plist_get(&arm, "base").map(pairs).unwrap_or_default();
    let mut rules: Vec<Value> = arr(plist_get(&arm, "rules")).to_vec();
    let mut named: Vec<String> = out.iter().chain(&base).map(|(k, _)| k.clone()).chain(rules.iter().flat_map(rule_keys)).collect();
    for u in units {
        let u = if let Value::String(id) = u { strat_unit_find(id, &d.tables["strat_data"]) } else { u };
        let mut new = vec![];
        for (k, v) in pairs(u) {
            if !["id", "base", "rules"].contains(&k.as_str()) && !named.contains(&k) {
                new.push(k.clone());
                out.push((k, v));
            }
        }
        for (k, v) in plist_get(u, "base").map(pairs).unwrap_or_default() {
            if !named.contains(&k) {
                new.push(k.clone());
                base.push((k, v));
            }
        }
        for r in arr(plist_get(u, "rules")) {
            let o: Vec<(String, Value)> = pairs(&r[1]).into_iter().filter(|(k, _)| !named.contains(k)).collect();
            if !o.is_empty() {
                new.extend(o.iter().map(|(k, _)| k.clone()));
                rules.push(Value::Array(vec![r[0].clone(), object(o)]));
            }
        }
        new.extend(named);
        named = new;
    }
    if !base.is_empty() {
        out.push(("base".into(), object(base)));
    }
    if !rules.is_empty() {
        out.push(("rules".into(), Value::Array(rules)));
    }
    Some(object(out))
}

/// port: STRAT-EXPAND — one raw library entry ST in the runtime's form: a Q table's arms (its :WITH under each) and rules (its
/// :RULE-BASE's antecedents with its :Q), a composite's subs, a strategy's units. The Lisp's ASSERTs panic.
pub fn strat_expand(d: &Data, st: &Value) -> Value {
    if let Some(fq) = plist_get(st, "fq") {
        let rb = plist_get(fq, "rule-base").map(|id| strat_unit_find(id.as_str().expect("a rule base id"), &d.tables["strat_rule_bases"]));
        let with = arr(plist_get(fq, "with"));
        let arms: Vec<Value> = arr(plist_get(fq, "arms")).iter().map(|a| strat_with(d, strat_arm(d, a), with).unwrap_or(Value::Null)).collect();
        let rules: Vec<Value> = match rb {
            Some(rb) => {
                let (antes, q) = (arr(plist_get(rb, "antes")), arr(plist_get(fq, "q")));
                assert_eq!(antes.len(), q.len());
                antes
                    .iter()
                    .zip(q)
                    .map(|(a, q)| {
                        let q = q.as_array().expect("a q row");
                        assert_eq!(q.len(), arms.len());
                        Value::Array(std::iter::once(a.clone()).chain(q.iter().cloned()).collect())
                    })
                    .collect()
            }
            None => arr(plist_get(fq, "rules")).to_vec(),
        };
        let groups = plist_get(fq, "groups").or_else(|| rb.and_then(|rb| plist_get(rb, "groups"))).cloned();
        // (an arm twice: STRAT-SWITCH-STEP's :PREV would see the first; NIL arms are EQ too)
        for (i, a) in arms.iter().enumerate() {
            assert!(!arms[..i].contains(a) || (a.is_null() && arms[..i].iter().filter(|x| x.is_null()).count() == 0), "an arm twice");
        }
        assert!(!rb.is_some_and(|rb| plist_get(rb, "xfeats").is_some()) || plist_get(fq, "xfeats").is_some(), "a rule base's cues without :XFEATS");
        let mut out = vec![("arms".to_string(), Value::Array(arms)), ("rules".to_string(), Value::Array(rules))];
        if let Some(g) = groups {
            out.push(("groups".into(), g));
        }
        for (k, v) in pairs(fq) {
            if !["arms", "rules", "groups", "rule-base", "q", "with"].contains(&k.as_str()) {
                let v = if k == "event-arms" {
                    Value::Array(arr(Some(&v)).iter().map(|ev| event_arm_expand(d, ev)).collect())
                } else {
                    v
                };
                out.push((k, v));
            }
        }
        let fq = object(out);
        return object(pairs(st).into_iter().map(|(k, v)| if k == "fq" { (k, fq.clone()) } else { (k, v) }).collect());
    }
    if plist_get(st, "switch").is_some() {
        let ps = pairs(st).into_iter().map(|(k, v)| {
            let v = match k.as_str() {
                "switch" => Value::Array(arr(Some(&v)).iter().map(|en| switch_entry_expand(d, en)).collect()),
                "else" => strat_arm(d, &v).unwrap_or(Value::Null),
                _ => v,
            };
            (k, v)
        });
        return object(ps.collect());
    }
    strat_compose(d, st)
}

/// A composite entry `(OWN . ARM)`, as the extractor writes it (`[OWN, id]` or `[OWN, k, v ...]`), with its arm expanded (flat).
fn switch_entry_expand(d: &Data, en: &Value) -> Value {
    let a = en.as_array().expect("a switch entry");
    let arm = if a.len() == 2 { strat_arm(d, &a[1]) } else { strat_arm(d, &object(pairs(&Value::Array(a[1..].to_vec())))) };
    let mut out = vec![a[0].clone()];
    for (k, v) in arm.as_ref().map(pairs).unwrap_or_default() {
        out.push(Value::String(k));
        out.push(v);
    }
    Value::Array(out)
}

/// An :EVENT-ARMS entry `(event arm ...)` with its arm expanded: an object `{event: arm ...}` or a flat `[event, arm ...]`.
fn event_arm_expand(d: &Data, ev: &Value) -> Value {
    match ev {
        Value::Object(o) => Value::Object(o.iter().enumerate().map(|(i, (k, v))| (k.clone(), if i == 0 { strat_arm(d, v).unwrap_or(Value::Null) } else { v.clone() })).collect()),
        Value::Array(a) => Value::Array(a.iter().enumerate().map(|(i, v)| if i == 1 { strat_arm(d, v).unwrap_or(Value::Null) } else { v.clone() }).collect()),
        _ => ev.clone(),
    }
}

// ---------------------------------------------------------------- the event layer's window (§8.19 round 5 step 6)

/// The :KNOCKDOWN event arm of FQ's :EVENT-ARMS, or None (`(second (assoc :knockdown ...))`).
fn knockdown_arm(fq: &Value) -> Option<&Value> {
    arr(plist_get(fq, "event-arms"))
        .iter()
        .find_map(|ev| match ev {
            Value::Object(o) => o.get("knockdown"),
            Value::Array(a) if a.first().and_then(Value::as_str) == Some("knockdown") => a.get(1),
            _ => None,
        })
        .filter(|a| !a.is_null())
}

/// port: STRAT-EVENT-ARM — FQ's :KNOCKDOWN event arm if it holds the step at tick NOW (the opponent perceived in state SS; LAST the
/// last tick he was perceived down, -1 never; DELAY the brain's), and LAST updated. Down = launched, down or waking up; it holds through
/// DELAY + GRACE (*STRAT-EVENT-GRACE*) frames after. None whenever FQ names no :EVENT-ARMS (LAST then unchanged).
pub fn strat_event_arm(fq: &Value, ss: State, now: i64, last: i64, delay: i64, grace: i64) -> (Option<&Value>, i64) {
    let Some(arm) = knockdown_arm(fq) else { return (None, last) };
    let mut last = if last > now { -1 } else { last }; // (a tick from an earlier match: forgotten)
    if matches!(ss, State::Air | State::Down | State::Wakeup) {
        last = now;
    }
    ((last >= 0 && now - last <= delay + grace).then_some(arm), last)
}

// ---------------------------------------------------------------- the strategy layer's pure parts (§5, §8.4)

/// port: STRAT-ARMS — the library's strategies ME may play against VS (their :APPLY (me vs) or (me), or none), in library order.
pub fn strat_arms(d: &'static Data, me: Character, vs: Character) -> Vec<Strat> {
    let is = |v: &Value, c: Character| v.as_str().is_some_and(|x| x.eq_ignore_ascii_case(c.name()));
    arr(d.tables.get("strat_library"))
        .iter()
        .filter(|st| {
            let ap = arr(plist_get(st, "apply"));
            ap.is_empty() || (is(&ap[0], me) && (ap.len() < 2 || is(&ap[1], vs)))
        })
        .map(Strat)
        .collect()
}

/// port: STRAT-LOOKUP — *STRAT-LOOKUP*'s strategy for ME against VS at DIF (HARD's row at a difficulty whose *STRAT-TABLE-CHANCE*
/// is above 0), or NIL.
pub fn strat_lookup(d: &'static Data, k: &Knobs, me: Character, vs: Character, dif: Difficulty) -> Option<Strat> {
    let dif = if k.strat_table_chance.get_or(dif.name(), 0.0) > 0.0 { Difficulty::Hard } else { dif };
    let is = |v: &Value, s: &str| v.as_str().is_some_and(|x| x.eq_ignore_ascii_case(s));
    let r = arr(d.tables.get("strat_lookup")).iter().find(|r| is(&r[0], me.name()) && is(&r[1], vs.name()) && is(&r[2], dif.name()))?;
    strat_by_id(d, r[3].as_str()?)
}

/// port: STRAT-SEED-VALUE — ME's expected win share with strategy ID against VS's equilibrium mix (*STRAT-PAYOFF*), 0.5 when the
/// pairing or ID is not in it.
pub fn strat_seed_value(d: &Data, me: Character, vs: Character, id: &str) -> f32 {
    let is = |v: &Value, c: Character| v.as_str().is_some_and(|x| x.eq_ignore_ascii_case(c.name()));
    let f = |v: &Value| v.as_f64().expect("a payoff") as f32;
    let pos = |l: &Value| arr(Some(l)).iter().position(|x| x.as_str().is_some_and(|x| x.eq_ignore_ascii_case(id)));
    for row in arr(d.tables.get("strat_payoff")) {
        let [a, b, rows, cols, m, x, y] = row.as_array().expect("a payoff row").as_slice() else { panic!("a payoff row") };
        if is(a, me) && is(b, vs) && let Some(r) = pos(rows) {
            return arr(Some(&arr(Some(m))[r])).iter().zip(arr(Some(y))).fold(0.0, |s, (v, w)| s + f(v) * f(w));
        }
        if is(a, vs) && is(b, me) && let Some(c) = pos(cols) {
            return 1.0 - arr(Some(m)).iter().zip(arr(Some(x))).fold(0.0, |s, (r, w)| s + f(w) * f(&r[c]));
        }
    }
    0.5
}

/// port: STRAT-PRIOR — strategy ST's fuzzy prior weight for FEATS (its :P; 1 when it names none).
pub fn strat_prior(sets: &FzSets, st: Strat, feats: &[(&str, Num)]) -> f32 {
    strat_value(sets, st, "p", feats).map_or(1.0, Num::f)
}

/// port: STRAT-PUCT — Decoupled UCT's choice for one side: argmax mean + C x prior x sqrt(N) / (1 + n). Ties: the first.
pub fn strat_puct(sums: &[f32], ns: &[f32], prior: &[f32], c: f32) -> usize {
    let tot = ns.iter().fold(0.0f32, |s, x| s + x);
    let sq = libm::sqrtf(if tot > 1.0 { tot } else { 1.0 }); // ((max 1 tot): 1 on a tie, (float 1) the same)
    let mut best = (0, None::<f32>);
    for k in 0..ns.len() {
        let v = sums[k] / max_f32(1e-6, ns[k]) + c * prior[k] * sq / (1.0 + ns[k]);
        if best.1.is_none_or(|bv| v > bv) {
            best = (k, Some(v));
        }
    }
    best.0
}

/// port: STRAT-FINAL — the selection's pick: argmax (1 - LAM) x mean + LAM x prior / the largest prior. Ties: the first.
pub fn strat_final(sums: &[f32], ns: &[f32], prior: &[f32], lam: f32) -> usize {
    let pm = max_f32(1e-6, prior.iter().skip(1).fold(prior[0], |m, &x| max_f32(m, x)));
    let mut best = (0, None::<f32>);
    for k in 0..ns.len() {
        let v = (1.0 - lam) * (sums[k] / max_f32(1e-6, ns[k])) + lam * (prior[k] / pm);
        if best.1.is_none_or(|bv| v > bv) {
            best = (k, Some(v));
        }
    }
    best.0
}

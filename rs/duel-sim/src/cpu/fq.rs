//! port: duel/lisp/fq-online.lisp — the online fuzzy Q against a human (DUEL_AI_STRATEGY §8.14): which CPU learns (FQ-ATTACH!), its
//! record (FQ-EXPLORE, FQ-NOTE), the TD updates at the match's end and the player's copy on the page (FQ-MATCH-END, FQ-TABLE), RESET
//! LEARNING (FQ-RESET-ALL). The pure part (FQ-TD-UPDATE!, FQ-TRANSITIONS, the codec) is strategy.rs's.
//!
//! **The copy's identity** (M2 ledger T5). A player's copy is a fresh plist (FQ-TABLE: COPY-TREE of the library entry, or the page's
//! q in a copy), so BRAIN-STRAT, BRAIN-SW-SUB and :PREV's POSITION hold objects EQ to no library entry, and FQ-MATCH-END updates it in
//! place. The port leaks each copy into a `&'static Value`: `Strat` stays a Copy pointer compared by `ptr::eq` (a library entry's case
//! unchanged), and the copy's arms are values of their own, as COPY-TREE's. FQ-MATCH-END's in-place update makes a new leaked value
//! and repoints the cell and every brain that held the old one (`fq_match_end_apply`). Nothing writes a copy during a match (the TD
//! update runs only from GO-RESULTS, which returns in a rollout), so the Lisp snapshot's walk into the copy's conses has nothing to
//! undo (M2 ledger T2, docs/bevy/M2_NOTES.md §1 and §8).
//! ponytail: one table leaked per load and per learned match (tens of kB each, a human's matches only); an arena of copies in
//! `Search` if a session's count ever matters.
use super::strategy::{fq_decode, fq_encode, fq_explore_arm, fq_td_update, fq_transitions, fq_u01, plist_get, strat_fq_fire, Strat};
use super::{Brain, Search};
use crate::components::{Character, Difficulty};
use crate::ecs::Entity;
use crate::fighter::fighter;
use crate::hashline::Enc;
use crate::state::{Match, Mode, Winner};
use duel_data::tuning::Value;
use duel_data::Data;

/// +PG-FQ+: page 40000 + 1000 (10 me + vs) holds CPU ME's online table against VS (its length, then entry j at + j).
pub const PG_FQ: i64 = 40000;

/// One `*fq-tables*` cell: roster indices (me . vs) -> (strategy . matches).
#[derive(Clone, Copy, Debug)]
pub struct FqCell {
    pub me: i64,
    pub vs: i64,
    /// The player's copy (a leaked value: see the module's header).
    pub st: Strat,
    /// The matches it learned from.
    pub n: i64,
}

/// One judgement's record (FQ-NOTE): the firing vector, the arm played, my health balance then.
pub type Rec = (Vec<f32>, usize, f32);

/// BRAIN-FQL: (me vs base recs) — the learning CPU's record this match; BASE is the library entry's :FQ (the offline table). RECS in
/// order (the Lisp PUSHes, newest first, and FQ-MATCH-END reverses them).
#[derive(Clone, Debug)]
pub struct Fql {
    pub me: i64,
    pub vs: i64,
    pub base: &'static Value,
    pub recs: Vec<Rec>,
}

impl PartialEq for Fql {
    fn eq(&self, o: &Fql) -> bool {
        (self.me, self.vs) == (o.me, o.vs) && std::ptr::eq(self.base, o.base) && self.recs == o.recs
    }
}

impl Fql {
    /// trace.lisp TR-A-FQL: `(me,vs,#fq:<checksum of base>,<record count>,<newest record>)`, the record `([fire],arm,h)` or NIL.
    pub fn enc(&self, d: &Data, unit: i64, s: &mut String) {
        use std::fmt::Write;
        write!(s, "({},{},#fq:{},{},", self.me, self.vs, super::strategy::fq_checksum(self.base, unit), self.recs.len()).unwrap();
        match self.recs.last() {
            Some((fire, arm, h)) => {
                s.push('(');
                super::enc_vec(fire, d, s);
                write!(s, ",{arm},").unwrap();
                h.enc(d, s);
                s.push(')');
            }
            None => s.push_str("NIL"),
        }
        s.push(')');
    }
}

/// FQ-MATCH-END's part GO-RESULTS does (`fq_match_end_take`): a learning brain's record, his health balance and result at the end.
#[derive(Clone, Debug, PartialEq)]
pub struct FqEnd {
    pub fql: Fql,
    pub h: f32,
    pub won: f32,
}

/// PAGE-GET: 0 for a key never set (the stub's and an empty page's answer).
pub fn page_get(s: &Search, k: i64) -> i64 {
    s.page.get(&k).copied().unwrap_or(0)
}

/// PAGE-SET.
pub fn page_set(s: &mut Search, k: i64, v: i64) {
    s.page.insert(k, v);
}

/// port: FQ-PAGE-BASE.
pub fn fq_page_base(me: i64, vs: i64) -> i64 {
    PG_FQ + 1000 * (10 * me + vs)
}

/// The roster index of a character (`(position c *roster*)`: the enum's order is `*roster*`'s).
fn roster(c: Character) -> i64 {
    c as i64
}

/// A leaked copy of the strategy plist LIB with its :FQ replaced by FQ (FQ-TABLE's `(list* :fq fq <lib's other entries>)`; the order of
/// a JSON object's keys is GETF-neutral: no library plist repeats a key).
fn leak_with_fq(lib: &Value, fq: Option<Value>) -> Strat {
    let mut copy = lib.clone();
    if let Some(fq) = fq {
        *copy.get_mut("fq").expect("a Q selector's :fq") = fq;
    }
    Strat(Box::leak(Box::new(copy)))
}

/// port: FQ-TABLE — the cell of the player's copy of LIB (the lookup's Q selector) for roster indices ME / VS: in memory, else the
/// page's when it was saved from this same offline table, else a fresh copy (made the newest cell). Returns its index in `fq_tables`.
pub fn fq_table(s: &mut Search, me: i64, vs: i64, lib: Strat, unit: i64) -> usize {
    if let Some(i) = s.fq_tables.iter().position(|c| (c.me, c.vs) == (me, vs)) {
        return i; // (ASSOC's first match; a key is never pushed twice)
    }
    let base = fq_page_base(me, vs);
    let n = page_get(s, base).clamp(0, 999);
    let codes: Vec<i64> = (1..=n).map(|j| page_get(s, base + j)).collect();
    let (fq, m) = match fq_decode(&codes, lib.fq().expect("a Q selector"), unit) {
        Some((fq, m)) => (Some(fq), m),
        None => (None, 0),
    };
    // log-msg: "duel fq load ME VS page|fresh matches M checksum C" (a console line: the trace's R line, never compared)
    s.fq_tables.insert(0, FqCell { me, vs, st: leak_with_fq(lib.0, fq), n: m }); // (PUSH)
    0
}

/// port: FQ-RESET-ALL — RESET LEARNING (SETTINGS): every online table forgotten, in memory and on the page (length 0 loads as fresh).
pub fn fq_reset_all(m: &Match, s: &mut Search) {
    s.fq_tables.clear();
    let playable: Vec<Character> = Character::ALL.iter().copied().filter(|c| !m.knobs.retired.has(c.name())).collect();
    for &me in &playable {
        for &vs in &playable {
            page_set(s, fq_page_base(roster(me), roster(vs)), 0);
        }
    }
    // log-msg: "duel fq reset"
}

/// port: FQ-ATTACH! — CPU E learns this match when his strategy is a Q selector played whole (his difficulty's table chance is 1)
/// at HARD and he faces a human (VS CPU, the LEARNING CPU setting on, no debug command run; or a tool's `fq_learn_force`): his brain
/// plays the player's copy and keeps the match's record.
pub fn fq_attach(m: &mut Match, s: &mut Search, e: Entity) {
    let (f, unit) = (fighter(m, e), m.knobs.fq_unit);
    let o = f.opp;
    let Some(b) = f.brain.as_ref() else { return };
    let Some(lib) = b.strat else { return };
    let Some(base) = lib.fq() else { return };
    let human = !fighter(m, o).has_brain();
    if !(m.knobs.strat_table_chance.chance(b.difficulty) >= 1.0
        && b.difficulty == Difficulty::Hard
        && (s.fq_learn_force || (m.mode == Mode::VsCpu && human && s.learn == 0 && !s.learn_debug_off)))
    {
        return;
    }
    let me = roster(f.character.expect("a character"));
    let vs = roster(fighter(m, o).character.expect("a character"));
    let i = fq_table(s, me, vs, lib, unit);
    let st = s.fq_tables[i].st;
    let b = m.fighter.get_mut(e).unwrap().brain.as_mut().unwrap();
    (b.strat, b.fql) = (Some(st), Some(Fql { me, vs, base, recs: Vec::new() }));
}

/// port: FQ-EXPLORE — a learning CPU E's judgement (SUB, arm I) of his Q selector SW, or another arm with chance `*fq-online-eps*`
/// (FQ-EXPLORE-ARM over one FQ-U01 draw of the match seed, tick and side; no sim stream).
pub fn fq_explore(m: &Match, e: Entity, sw: Strat, sub: Option<Strat>, i: i64) -> (Option<Strat>, i64) {
    let arms = sw.fq().and_then(|q| plist_get(q, "arms")).and_then(Value::as_array).map_or(&[][..], |a| a.as_slice());
    let u = fq_u01(m.match_seed, m.match_tick, fighter(m, e).side);
    let j = fq_explore_arm(u, m.knobs.fq_online_eps as f64, i, arms.len() as i64);
    if j == i { (sub, i) } else { (arms.get(j as usize).filter(|a| !a.is_null()).map(Strat), j) }
}

/// port: FQ-NOTE — record a judgement of CPU E (brain B, learning): the firing vector of his copy's rules for FEATS, the ARM played,
/// his health balance (MC-FULL-HEALTH).
pub fn fq_note(m: &Match, e: Entity, b: &mut Brain, feats: &[(&str, crate::cl::Num)], arm: i64) {
    let fq = b.strat.and_then(Strat::fq).expect("a learning brain's Q selector");
    let fire = strat_fq_fire(&m.knobs.fz_sets, fq, feats);
    let h = super::mcts::mc_full_health(m, e) - super::mcts::mc_full_health(m, fighter(m, e).opp);
    let arm = usize::try_from(arm).expect("a judged arm");
    b.fql.as_mut().expect("a learning brain").recs.push((fire, arm, h));
}

/// port: FQ-MATCH-END's first half, at GO-RESULTS: each learning brain's record taken (BRAIN-FQL NIL), with his health balance and
/// result now (1.0 a win, 0.0 a draw, -1.0 a loss), queued in `Match.fq_end` for `fq_match_end_apply`.
pub fn fq_match_end_take(m: &mut Match) {
    for e in [m.p1, m.p2] {
        let Some(f) = m.fighter.get(e) else { continue };
        let (side, o) = (f.side, f.opp);
        let Some(fql) = m.fighter.get_mut(e).and_then(|f| f.brain.as_mut()).and_then(|b| b.fql.take()) else { continue };
        let h = super::mcts::mc_full_health(m, e) - super::mcts::mc_full_health(m, o);
        let won = match m.winner {
            Some(Winner::Side(k)) if k == side => 1.0,
            Some(Winner::Draw) => 0.0,
            _ => -1.0,
        };
        m.fq_end.push(FqEnd { fql, h, won });
    }
}

/// port: FQ-MATCH-END's second half: every queued record (in side order) updates its cell's copy (FQ-TD-UPDATE! of its transitions,
/// the table's own :SCALE / :GAMMA), counts the match and saves the copy to the page (the codes, then their count). An empty record
/// changes nothing. The copy is replaced by an updated one (see the module's header): the cell and every brain holding the old one
/// point to the new.
pub fn fq_match_end_apply(m: &mut Match, s: &mut Search) {
    if m.fq_end.is_empty() {
        return;
    }
    let k = &m.knobs;
    let (unit, eta, cap) = (k.fq_unit, k.fq_online_eta, k.fq_online_cap.0);
    for FqEnd { fql: Fql { me, vs, base, recs }, h, won } in std::mem::take(&mut m.fq_end) {
        if recs.is_empty() {
            continue;
        }
        let ci = s.fq_tables.iter().position(|c| (c.me, c.vs) == (me, vs)).expect("the learner's cell");
        let old = s.fq_tables[ci].st;
        let q0 = old.fq().expect("a Q selector");
        let num = |key: &str, default: f32| plist_get(q0, key).and_then(super::fuzzy::num_of).map_or(default, |v| v.f());
        let (scale, gamma) = (num("scale", m.knobs.fq_online_scale), num("gamma", m.knobs.fq_online_gamma));
        let mut copy = old.0.clone();
        let fq = copy.get_mut("fq").expect("a Q selector's :fq");
        fq_td_update(fq, base, &fq_transitions(&recs, h, won, scale), eta, gamma, cap, unit);
        let st = Strat(Box::leak(Box::new(copy)));
        let cell = &mut s.fq_tables[ci];
        cell.st = st;
        cell.n += 1;
        let n = cell.n;
        for e in [m.p1, m.p2] {
            if let Some(b) = m.fighter.get_mut(e).and_then(|f| f.brain.as_mut())
                && b.strat == Some(old)
            {
                b.strat = Some(st);
            }
        }
        let codes = fq_encode(st.fq().unwrap(), base, n, unit);
        let pg = fq_page_base(me, vs);
        for (j, &c) in codes.iter().enumerate() {
            page_set(s, pg + 1 + j as i64, c);
        }
        page_set(s, pg, codes.len() as i64);
        // log-msg: "duel fq learn ME VS matches N judgements J moved M flips F" (a console line, never compared)
    }
}

/// TR-A-STRAT's suffix for a player's copy (the strategy of a cell): `/fq(<matches>,<q codes>...)` (FQ-ENCODE's codes after its
/// three-word head), else nothing.
pub fn enc_copy(st: Strat, cells: &[FqCell], unit: i64, s: &mut String) {
    use std::fmt::Write;
    if let Some(c) = cells.iter().find(|c| c.st == st) {
        write!(s, "/fq({}", c.n).unwrap();
        for x in &fq_encode(st.fq().unwrap(), st.fq().unwrap(), c.n, unit)[3..] {
            write!(s, ",{x}").unwrap();
        }
        s.push(')');
    }
}

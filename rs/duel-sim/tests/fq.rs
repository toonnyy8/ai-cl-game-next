//! M2 Task 9: the online learner's glue (fq-online.lisp): the page round trip (FQ-MATCH-END's save, FQ-TABLE's load), FQ-ATTACH!'s
//! test (CPU vs CPU never learns; a debug command stops it; debug 2504 and the tool's force turn it on). Not Lisp checks: no
//! tests/duel-rules file covers this glue (strategy.lisp checks its pure part: tests/strategy.rs `online_fq_td_and_page`).
use duel_data::Data;
use duel_sim::cl::Num::I;
use duel_sim::components::{Character, Difficulty};
use duel_sim::cpu::fq::*;
use duel_sim::cpu::strategy::{fq_checksum, fq_encode, strat_by_id, strat_fq_fire, Strat};
use duel_sim::cpu::{Brain, Search};
use duel_sim::state::{Match, Mode};
use std::sync::OnceLock;

fn data() -> &'static Data {
    static D: OnceLock<Data> = OnceLock::new();
    D.get_or_init(Data::embedded)
}

/// The q of each rule as the sim reads them (single-floats: the JSON's decimal and a decoded code / unit are the same single).
fn qs(st: Strat) -> Vec<Vec<f32>> {
    let rules = st.fq().unwrap()["rules"].as_array().unwrap();
    rules.iter().map(|r| r.as_array().unwrap()[1..].iter().map(|q| q.as_f64().unwrap() as f32).collect()).collect()
}

/// FQ-TABLE makes a fresh copy (its own value, not EQ to the library's, the same q); FQ-MATCH-END's save writes the codes then their
/// count at 40000 + 1000 (10 me + vs); with the tables forgotten (debug 2504) FQ-TABLE loads it back from the page: the learned q, one
/// match, the same checksum. A page saved from another offline table loads as fresh.
#[test]
fn page_roundtrip() {
    let mut m = Match::new(data());
    let mut s = Search::new();
    let unit = m.knobs.fq_unit;
    let lib = strat_by_id(data(), "q1-ichigo-ken").unwrap();
    let base = lib.fq().unwrap();
    let i = fq_table(&mut s, 3, 1, lib, unit);
    let c = s.fq_tables[i];
    assert!(c.st != lib && c.n == 0 && qs(c.st) == qs(lib) && c.st.id() == lib.id());
    assert_eq!(fq_table(&mut s, 3, 1, lib, unit), 0); // (in memory: the same cell)
    assert_eq!(s.fq_tables.len(), 1);
    // (a learned match: two crisp judgements, a win)
    let feats = [("lead", I(-1)), ("ored", I(0)), ("ost", I(0)), ("awk", I(0)), ("prev", I(0))];
    let fire = strat_fq_fire(&m.knobs.fz_sets, base, &feats);
    assert_eq!(fire.iter().filter(|&&x| x > 0.0).count(), 1);
    let recs = vec![(fire.clone(), 0, 1.0), (fire, 1, 0.5)];
    m.fq_end.push(FqEnd { fql: Fql { me: 3, vs: 1, base, recs }, h: 0.25, won: 1.0 });
    fq_match_end_apply(&mut m, &mut s);
    assert!(m.fq_end.is_empty());
    let learned = s.fq_tables[0];
    assert!(learned.n == 1 && learned.st != c.st && qs(learned.st) != qs(lib));
    assert_eq!(qs(lib), qs(c.st)); // (the library entry and the old copy are never written)
    let pg = fq_page_base(3, 1);
    assert_eq!(pg, 71000);
    let codes = fq_encode(learned.st.fq().unwrap(), base, 1, unit);
    assert_eq!(page_get(&s, pg), codes.len() as i64);
    assert!((1..=codes.len()).all(|j| page_get(&s, pg + j as i64) == codes[j - 1]));
    // (forgotten, then loaded from the page)
    s.fq_tables.clear();
    let i = fq_table(&mut s, 3, 1, lib, unit);
    let back = s.fq_tables[i];
    assert_eq!((back.n, qs(back.st)), (1, qs(learned.st)));
    assert_eq!(fq_checksum(back.st.fq().unwrap(), unit), fq_checksum(learned.st.fq().unwrap(), unit));
    assert_eq!(back.st.id(), lib.id());
    // (another offline table on the same page slot: fresh)
    s.fq_tables.clear();
    let other = strat_by_id(data(), "t0-ki-ichigo").unwrap();
    let i = fq_table(&mut s, 3, 1, other, unit);
    let fresh = s.fq_tables[i];
    assert_eq!((fresh.n, qs(fresh.st)), (0, qs(other)));
    // (RESET LEARNING: every playable pairing's length 0, the tables gone)
    fq_reset_all(&m, &mut s);
    assert!(s.fq_tables.is_empty() && page_get(&s, pg) == 0 && page_get(&s, pg + 1) == codes[0]);
    assert!(!s.page.contains_key(&fq_page_base(2, 1))); // (Rukia: retired)
}

fn start(m: &mut Match, s: &mut Search, mode: Mode, dif: Difficulty) {
    (m.picks, m.mode, m.difficulty) = ([Character::Kenpachi, Character::Ichigo], mode, dif);
    duel_sim::flow::go_title(m);
    duel_sim::flow::start_match(m, s);
}

fn brains(m: &Match) -> [Option<&Brain>; 2] {
    [m.p1, m.p2].map(|e| m.fighter.get(e).unwrap().brain.as_deref())
}

/// FQ-ATTACH!: CPU vs CPU never learns, even at HARD with a Q selector played whole; VS CPU after a debug command does not either;
/// debug 2504 (VS CPU, HARD, the learner on as in play) gives the CPU the player's copy and a record; the tool's force makes every
/// Q-selector CPU learn, both in a CPU vs CPU match.
#[test]
fn cvc_never_learns() {
    let mut m = Match::new(data());
    let mut s = Search::new();
    start(&mut m, &mut s, Mode::CpuCpu, Difficulty::Hard);
    for b in brains(&m) {
        let b = b.unwrap();
        assert!(b.fql.is_none() && b.strat.and_then(Strat::fq).is_some());
        assert!(b.strat == strat_by_id(data(), b.strat.unwrap().id().unwrap())); // (the library entry itself)
    }
    assert!(s.fq_tables.is_empty());
    // (VS CPU at HARD after a debug command: no learning)
    s.learn_debug_off = true;
    start(&mut m, &mut s, Mode::VsCpu, Difficulty::Hard);
    assert!(brains(&m)[0].is_none() && brains(&m)[1].unwrap().fql.is_none() && s.fq_tables.is_empty());
    // (debug 2504: the learner)
    duel_sim::debug::debug_command(&mut m, &mut s, 2504);
    assert!(!s.learn_debug_off);
    let b = brains(&m)[1].unwrap();
    let l = b.fql.as_ref().expect("a learner");
    let lib = strat_by_id(data(), "t0-ki-ichigo").unwrap();
    assert!((l.me, l.vs, l.recs.len()) == (3, 1, 0) && std::ptr::eq(l.base, lib.fq().unwrap()));
    assert!(b.strat == Some(s.fq_tables[0].st) && b.strat != Some(lib) && b.strat.unwrap().id() == lib.id());
    // (NORMAL never learns, VS CPU or not)
    s.fq_tables.clear();
    s.learn_debug_off = false;
    start(&mut m, &mut s, Mode::VsCpu, Difficulty::Normal);
    assert!(brains(&m)[1].unwrap().fql.is_none() && s.fq_tables.is_empty());
    // (the tool's force: both CPUs of a CPU vs CPU match at HARD)
    s.fq_learn_force = true;
    start(&mut m, &mut s, Mode::CpuCpu, Difficulty::Hard);
    assert!(brains(&m).iter().all(|b| b.unwrap().fql.is_some()) && s.fq_tables.len() == 2);
}

/// A learning brain's A field (TR-A-FQL) and its strategy's (TR-A-STRAT's `/fq(...)`), as the vs-learn key prints them.
#[test]
fn a_line_prints_the_copy_and_the_record() {
    let mut m = Match::new(data());
    let mut s = Search::new();
    duel_sim::debug::debug_command(&mut m, &mut s, 2504);
    let a = duel_sim::cpu::a_line(&m, &s);
    let fq = s.fq_tables[0].st.fq().unwrap();
    let codes: Vec<String> = fq_encode(fq, fq, 0, m.knobs.fq_unit)[3..].iter().map(i64::to_string).collect();
    assert!(a.contains(&format!(" #s::T0-KI-ICHIGO/fq(0,{}) ", codes.join(","))), "{a}");
    assert!(a.contains(" (3,1,#fq:179296,0,NIL) "));
}

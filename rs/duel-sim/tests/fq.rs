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

/// The q of each rule as the sim reads them (single-floats: the JSON's decimal and a decoded code / unit are the same single), flat in
/// rule order (a cell's overlay's shape).
fn qs(st: Strat) -> Vec<f32> {
    let rules = st.fq().unwrap()["rules"].as_array().unwrap();
    rules.iter().flat_map(|r| r.as_array().unwrap()[1..].iter().map(|q| q.as_f64().unwrap() as f32)).collect()
}

/// FQ-TABLE makes a fresh copy (its own value, not EQ to the library's, the same q); FQ-MATCH-END updates the cell's q in place (the
/// copy keeps its identity, as the Lisp's in-place update) and its save writes the codes then their count at 40000 + 1000 (10 me +
/// vs); with the tables forgotten (debug 2504) FQ-TABLE loads it back from the page: the learned q, one match, the same checksum. A
/// page saved from another offline table loads as fresh.
#[test]
fn page_roundtrip() {
    let mut m = Match::new(data());
    let mut s = Search::new();
    let unit = m.knobs.fq_unit;
    let lib = strat_by_id(data(), "q1-ichigo-ken").unwrap();
    let base = lib.fq().unwrap();
    let i = fq_table(&mut s, 3, 1, lib, unit);
    let c = s.fq_tables[i].clone();
    assert!(c.st != lib && c.n == 0 && qs(c.st) == qs(lib) && c.q == qs(lib) && c.st.id() == lib.id());
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
    let learned = s.fq_tables[0].clone();
    assert!(learned.n == 1 && learned.st == c.st && learned.q != qs(lib));
    assert_eq!(qs(lib), qs(c.st)); // (the library entry and the copy's leaked structure are never written: the q are the cell's)
    assert_eq!(s.fq_pool.len(), 1);
    let pg = fq_page_base(3, 1);
    assert_eq!(pg, 71000);
    let codes = fq_encode(&with_q(learned.st, &learned.q), base, 1, unit);
    assert_eq!(page_get(&s, pg), codes.len() as i64);
    assert!((1..=codes.len()).all(|j| page_get(&s, pg + j as i64) == codes[j - 1]));
    // (forgotten, then loaded from the page)
    s.fq_tables.clear();
    let i = fq_table(&mut s, 3, 1, lib, unit);
    let back = s.fq_tables[i].clone();
    assert_eq!((back.n, &back.q, back.st), (1, &learned.q, c.st)); // (the page's q in the cell; the pooled structure reused)
    assert_eq!(fq_checksum(&with_q(back.st, &back.q), unit), fq_checksum(&with_q(learned.st, &learned.q), unit));
    assert_eq!(back.st.id(), lib.id());
    // (another offline table on the same page slot: fresh)
    s.fq_tables.clear();
    let other = strat_by_id(data(), "t0-ki-ichigo").unwrap();
    let i = fq_table(&mut s, 3, 1, other, unit);
    let fresh = s.fq_tables[i].clone();
    assert_eq!((fresh.n, qs(fresh.st), fresh.q), (0, qs(other), qs(other)));
    // (RESET LEARNING: every playable pairing's length 0, the tables gone)
    fq_reset_all(&m, &mut s);
    assert!(s.fq_tables.is_empty() && page_get(&s, pg) == 0 && page_get(&s, pg + 1) == codes[0]);
    assert!(!s.page.contains_key(&fq_page_base(2, 1))); // (Rukia: retired)
}

/// The copy ST's :FQ with the q Q (rule order), as the Lisp's in-place copy holds them.
fn with_q(st: Strat, q: &[f32]) -> duel_data::tuning::Value {
    let mut fq = st.fq().unwrap().clone();
    let mut it = q.iter();
    for r in fq.get_mut("rules").unwrap().as_array_mut().unwrap() {
        for c in r.as_array_mut().unwrap()[1..].iter_mut() {
            *c = duel_data::tuning::Value::from(*it.next().unwrap() as f64);
        }
    }
    fq
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

/// M3a Task 10 (M2_NOTES §12): a learned match leaks nothing. 100 learned matches in a row (the tool's force: both HARD CPUs of a CPU
/// vs CPU match learn, each match's record non-empty, its K.O. or time-up's GO-RESULTS applying FQ-MATCH-END): the copies' leaked
/// structures, the cells and their q stay as they were after the first, while every match is learned (the cells' match counts) and
/// the brains keep the same copy.
#[test]
fn fq_arena_no_leak() {
    use duel_sim::components::Flow;
    let mut m = Match::new(data());
    let mut s = Search::new();
    s.fq_learn_force = true;
    std::sync::Arc::make_mut(&mut m.knobs).match_seconds = 3; // (a time-up after 3 s of battle: GO-RESULTS)
    let mut sizes = None;
    for k in 0..100 {
        m.match_seed = 1 + k;
        start(&mut m, &mut s, Mode::CpuCpu, Difficulty::Hard);
        m.skip_cines = true;
        let mut frames = 0;
        while m.flow != Flow::Results {
            assert!(duel_sim::flow::frame_headless(&mut m, &mut s, &mut duel_sim::flow::NoInput, &mut duel_sim::look::NoLook), "{:?}", m.unported);
            frames += 1;
            assert!(frames < 60 * 60, "match {k} never reached RESULTS");
        }
        assert!(s.fq_tables.iter().all(|c| c.n == k + 1), "match {k}: every cell learned ({:?})", s.fq_tables.iter().map(|c| c.n).collect::<Vec<_>>());
        let now = (s.fq_pool.len(), s.fq_tables.len(), s.fq_tables.iter().map(|c| (c.st, c.q.len(), c.q.capacity())).collect::<Vec<_>>());
        match &sizes {
            None => sizes = Some(now),
            Some(first) => assert_eq!(&now, first, "match {k}: the arena grew"),
        }
    }
    let (leaks, cells, _) = sizes.unwrap();
    assert_eq!((leaks, cells), (2, 2));
}

/// M3a Task 10: the cell's q after learned matches are what the old in-value update gave. A reference copy of the library's :FQ is
/// updated in place by FQ-TD-UPDATE! over the same records each match (the Lisp's in-place copy, and the port's repointed copy before
/// the arena); after each of 5 matches the cell's q equal its q bit for bit, and STRAT-FQ-Q over the cell's q (`strat_fq_q_of`, what
/// STRAT-JUDGE reads for a copy) equals STRAT-FQ-Q of the reference over 300 cue vectors. Both shapes: a plain Q selector
/// (q1-ichigo-ken) and one with :GROUPS (t0-ki-ichigo, the one a HARD Ichigo learns with).
#[test]
fn learned_q_read_from_the_cell() {
    use duel_data::tuning::Value;
    use duel_sim::cl::Num::F;
    use duel_sim::cpu::strategy::{fq_td_update, fq_transitions, plist_get, strat_fq_q, strat_fq_q_of};
    let m0 = Match::new(data());
    let k = &m0.knobs;
    let sets = &k.fz_sets;
    let seed = std::cell::Cell::new(12345u64);
    let rnd = |n: u64| {
        seed.set(seed.get().wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407));
        (seed.get() >> 33) % n
    };
    for id in ["q1-ichigo-ken", "t0-ki-ichigo"] {
        let lib = strat_by_id(data(), id).unwrap();
        let base = lib.fq().unwrap();
        assert_eq!(plist_get(base, "groups").is_some(), id.starts_with("t0"));
        let narms = base["arms"].as_array().unwrap().len() as u64;
        let mut cues: Vec<&str> = vec![];
        for r in base["rules"].as_array().unwrap() {
            for c in r[0].as_array().unwrap() {
                let c = c[0].as_str().unwrap();
                if !cues.contains(&c) {
                    cues.push(c);
                }
            }
        }
        let vals = [-1.0f32, -0.4, 0.0, 0.3, 0.7, 1.0, 2.5];
        let feats = || {
            let mut f: Vec<(&str, duel_sim::cl::Num)> = cues.iter().map(|&c| (c, F(vals[rnd(vals.len() as u64) as usize]))).collect();
            f.push(("prev", I(rnd(narms) as i64)));
            f
        };
        let (mut m, mut s) = (Match::new(data()), Search::new());
        let i = fq_table(&mut s, 3, 1, lib, k.fq_unit);
        let mut reference = base.clone();
        let num = |key: &str, d: f32| plist_get(base, key).and_then(|v| v.as_f64()).map_or(d, |v| v as f32);
        let (scale, gamma) = (num("scale", k.fq_online_scale), num("gamma", k.fq_online_gamma));
        for round in 0..5 {
            let recs: Vec<Rec> = (0..8).map(|_| (strat_fq_fire(sets, base, &feats()), rnd(narms) as usize, rnd(1000) as f32 / 100.0 - 5.0)).collect();
            let (h, won) = (rnd(1000) as f32 / 100.0 - 5.0, [1.0, 0.0, -1.0][rnd(3) as usize]);
            m.fq_end.push(FqEnd { fql: Fql { me: 3, vs: 1, base, recs: recs.clone() }, h, won });
            fq_match_end_apply(&mut m, &mut s);
            fq_td_update(&mut reference, base, &fq_transitions(&recs, h, won, scale), k.fq_online_eta, gamma, k.fq_online_cap.0, k.fq_unit);
            let cell = &s.fq_tables[i];
            assert_eq!(cell.n, round + 1);
            assert_eq!(cell.q.iter().map(|x| x.to_bits()).collect::<Vec<_>>(), q_of(&reference).iter().map(|x| x.to_bits()).collect::<Vec<_>>(), "{id} match {round}: the cell's q");
            assert_ne!(cell.q, q_of(base), "{id} match {round}: learned");
            let fq: &Value = cell.st.fq().unwrap();
            for _ in 0..300 {
                let f = feats();
                assert_eq!(strat_fq_q_of(sets, fq, &f, Some(&cell.q)), strat_fq_q(sets, &reference, &f), "{id} match {round}: STRAT-FQ-Q at {f:?}");
            }
        }
    }
}

/// Ruling R27: the copies' structures are pooled by (me, vs, library entry). Ten rounds of one pairing, each a learned match then a
/// forgetting (debug 2504's `fq_tables.clear()` on odd rounds, RESET LEARNING on even ones): the pool holds one structure throughout,
/// every cell made again is that structure, and its q start where FQ-TABLE says: after RESET LEARNING the entry's fresh q (the page's
/// length 0), after a clear the page's learned q with their match count, never the forgotten cell's own (a stale-q slip fails here).
#[test]
fn fq_pool_reuses_the_structure_across_resets() {
    let m = Match::new(data());
    let mut s = Search::new();
    let unit = m.knobs.fq_unit;
    let lib = strat_by_id(data(), "q1-ichigo-ken").unwrap();
    let base = lib.fq().unwrap();
    let feats = [("lead", I(-1)), ("ored", I(0)), ("ost", I(0)), ("awk", I(0)), ("prev", I(0))];
    let fire = strat_fq_fire(&m.knobs.fz_sets, base, &feats);
    let mut st0 = None;
    let mut m = m;
    for round in 0..10 {
        let i = fq_table(&mut s, 3, 1, lib, unit);
        let st = *st0.get_or_insert(s.fq_tables[i].st);
        assert_eq!((s.fq_tables[i].st, s.fq_pool.len()), (st, 1), "round {round}: the pooled structure");
        let before = s.fq_tables[i].clone();
        m.fq_end.push(FqEnd { fql: Fql { me: 3, vs: 1, base, recs: vec![(fire.clone(), 0, 1.0), (fire.clone(), 1, 0.5)] }, h: 0.25, won: 1.0 });
        fq_match_end_apply(&mut m, &mut s);
        let learned = s.fq_tables[0].clone();
        assert!(learned.q != before.q && learned.n == before.n + 1, "round {round}: learned");
        if round % 2 == 1 {
            s.fq_tables.clear(); // (debug 2504: the cells forgotten, the page kept)
            let i = fq_table(&mut s, 3, 1, lib, unit);
            assert_eq!((&s.fq_tables[i].q, s.fq_tables[i].n), (&learned.q, learned.n), "round {round}: the page's q after a clear");
            s.fq_tables.clear();
        } else {
            fq_reset_all(&m, &mut s); // (RESET LEARNING: the page's lengths 0)
            let i = fq_table(&mut s, 3, 1, lib, unit);
            assert_eq!((&s.fq_tables[i].q, s.fq_tables[i].n), (&qs(lib), 0), "round {round}: the fresh q after a reset");
            fq_reset_all(&m, &mut s);
        }
    }
    assert_eq!(s.fq_pool.len(), 1);
}

//! tests/duel-rules/strategy.lisp's checks on the ported functions (strategy.lisp's code, its library as tables.json holds it), the CPU
//! checks of style-knob.lisp, Review Focus 4 (GETF order and NIL in a strategy), the library's load, and the native judgement dump
//! (tests/fixtures/strat-judgements.txt: real cues of the T0 tables, their Q and pick, bit for bit). Not ported: the checks that read
//! the style sources' text or KNOBS.md, and STRAT-FINGERPRINT / -SIMILARITY (tools only).
use duel_data::tuning::Value;
use duel_data::Data;
use duel_sim::cl::Num::{self, F, I};
use duel_sim::components::{Character::*, Difficulty::*, State};
use duel_sim::cpu::strategy::*;
use duel_sim::cpu::style::StyleId;
use duel_sim::knobs::Knobs;
use std::sync::OnceLock;

fn data() -> &'static Data {
    static D: OnceLock<Data> = OnceLock::new();
    D.get_or_init(Data::embedded)
}
fn k() -> &'static Knobs {
    static K: OnceLock<Knobs> = OnceLock::new();
    K.get_or_init(|| Knobs::from(data()).unwrap())
}
fn sets() -> &'static duel_sim::cpu::fuzzy::FzSets {
    &k().fz_sets
}
/// A JSON plist written as text, kept for the test's life (a strategy is a `'static` value).
fn j(s: &str) -> &'static Value {
    Box::leak(Box::new(s.parse::<Value>().unwrap_or_else(|e| panic!("{e}: {s}"))))
}
fn leak(v: Value) -> &'static Value {
    Box::leak(Box::new(v))
}
fn st(s: &str) -> Strat {
    Strat(j(s))
}
fn approx(a: f32, b: f32) -> bool {
    (a - b).abs() < 1e-4
}
fn fq(id: &str) -> &'static Value {
    strat_by_id(data(), id).unwrap_or_else(|| panic!("no {id}")).fq().unwrap()
}
fn arms(fq: &Value) -> &[Value] {
    fq["arms"].as_array().unwrap()
}
fn rules(fq: &Value) -> &[Value] {
    fq["rules"].as_array().unwrap()
}
fn groups_sum(fq: &Value) -> u64 {
    fq["groups"].as_array().unwrap().iter().map(|g| g.as_u64().unwrap()).sum()
}
fn arm_id(a: &Value) -> Option<&str> {
    a.get("id").and_then(Value::as_str)
}
fn arm_fn(a: &Value) -> Option<&str> {
    Strat(leak(a.clone())).get("fn").and_then(Value::as_str)
}
/// The q of every rule as singles (a q a TD update wrote is the f64 of a single; one read from the data its decimal).
fn qs(fq: &Value) -> Vec<Vec<f32>> {
    rules(fq).iter().map(|r| r.as_array().unwrap()[1..].iter().map(|q| q.as_f64().unwrap() as f32).collect()).collect()
}
fn now(st: Strat, feats: &[(&'static str, Num)]) -> Now {
    let mut cues = Cues::default();
    feats.iter().for_each(|&(k, v)| cues.push(k, v));
    Now { st, cues, gap_off: false }
}
fn unit() -> i64 {
    k().fq_unit
}
fn panics(f: impl FnOnce() + std::panic::UnwindSafe) -> bool {
    std::panic::catch_unwind(f).is_err()
}

// ---------------------------------------------------------------- strategies as data (§2)

#[test]
fn strat_value_and_out() {
    let s = st(r#"{"id":"t1","base":{"range":1.0,"b-j1":0.0},
                   "rules":[[[["dj","in"]],{"b-j1":0.2,"ns":0.9}],[[["dj","afar"],["ost","free"]],{"range":0.7}]]}"#);
    let v = |key: &str, feats: &[(&str, Num)]| strat_value(sets(), s, key, feats).map(Num::f);
    // a rule that holds answers; no rule: the base; neither names the key: NIL (the CPU's own value)
    assert!(approx(v("b-j1", &[("dj", F(0.5))]).unwrap(), 0.2));
    assert!(approx(v("b-j1", &[("dj", F(3.0))]).unwrap(), 0.0));
    assert!(approx(v("range", &[("dj", F(3.0)), ("ost", I(0))]).unwrap(), 0.7));
    assert!(approx(v("range", &[("dj", F(3.0)), ("ost", I(2))]).unwrap(), 1.0));
    assert_eq!(v("hoho", &[("dj", F(0.5))]), None);
    // one rule firing at any strength gives its value alone
    assert!(approx(v("ns", &[("dj", F(0.9))]).unwrap(), 0.9));
    // no active strategy: the CPU's own value, and a chance unchanged
    assert_eq!(strat_out(sets(), None, "ns", Some(F(0.3))), Some(F(0.3)));
    assert_eq!(strat_scale(sets(), None, "hoho", 0.3), 0.3);
    let n = now(st(r#"{"base":{"hoho":2.0,"ns":0.1}}"#), &[]);
    assert!(approx(strat_out(sets(), Some(&n), "ns", Some(F(0.3))).unwrap().f(), 0.1));
    assert!(approx(strat_scale(sets(), Some(&n), "hoho", 0.3), 0.6));
    assert!(approx(strat_scale(sets(), Some(&n), "hoho", 0.7), 1.0));
}

/// Review Focus 4: GETF's first match on a repeated key (base and a rule's outputs), a rule naming no output for the key, :BASE missing,
/// a NIL value, an integer that stays one.
#[test]
fn strat_value_first_match_and_nil() {
    let v = |s: &str, key: &str, feats: &[(&str, Num)]| strat_value(sets(), st(s), key, feats);
    // (a flat plist: the first occurrence of a key wins, as GETF; the extractor writes the data's plists as objects first-wins too)
    assert_eq!(v(r#"{"base":["range",0.5,"range",0.9]}"#, "range", &[]), Some(F(0.5)));
    assert_eq!(v(r#"{"rules":[[null,["ns",0.2,"ns",0.8]]]}"#, "ns", &[]), Some(F(0.2)));
    // (a NIL first occurrence is NIL: GETF stops there, so the CPU's own value)
    assert_eq!(v(r#"{"base":["range",null,"range",0.9]}"#, "range", &[]), None);
    assert_eq!(strat_out(sets(), Some(&now(st(r#"{"base":{"range":null}}"#), &[])), "range", Some(F(1.5))), Some(F(1.5)));
    // (a rule naming another key does not dilute: only the rules naming KEY average)
    assert_eq!(v(r#"{"rules":[[null,{"ns":0.4}],[null,{"hoho":9.0}]]}"#, "ns", &[]), Some(F(0.4)));
    // (two rules naming it, averaged by strength: low 1, the empty antecedent 1)
    assert!(approx(v(r#"{"rules":[[[["mr","low"]],{"ns":1.0}],[null,{"ns":0.0}]]}"#, "ns", &[("mr", F(0.1))]).unwrap().f(), 0.5));
    // (a rule that does not fire leaves the base; :BASE missing and no rule firing: NIL)
    assert_eq!(v(r#"{"base":{"ns":0.3},"rules":[[[["mr","low"]],{"ns":1.0}]]}"#, "ns", &[("mr", F(0.9))]), Some(F(0.3)));
    assert_eq!(v(r#"{"rules":[[[["mr","low"]],{"ns":1.0}]]}"#, "ns", &[("mr", F(0.9))]), None);
    assert_eq!(v(r#"{"id":"x"}"#, "ns", &[]), None);
    // (a :BASE integer is returned as it is: a style's frames knob, *KSO-STALE*'s 60; a rule's average is a single)
    assert_eq!(v(r#"{"base":{"kso-stale":60}}"#, "kso-stale", &[]), Some(I(60)));
    assert_eq!(v(r#"{"rules":[[null,{"kso-stale":60}]]}"#, "kso-stale", &[]), Some(F(60.0)));
    // (a missing cue reads 0: :lead 0 is :even)
    assert_eq!(v(r#"{"rules":[[[["lead","even"]],{"ns":0.7}]]}"#, "ns", &[]), Some(F(0.7)));
    // (STRAT-MUL keeps an integer an integer, half up; a float scale on a float)
    let n = now(st(r#"{"base":{"xch-sa-wait":2,"clash-margin":2}}"#), &[]);
    assert_eq!(strat_mul_int(sets(), Some(&n), "xch-sa-wait", 4), 8);
    assert_eq!(strat_mul(sets(), Some(&n), "clash-margin", 1.5), 3.0);
    // (a composite's sub is a flat dotted cons [OWN, k, v ...])
    let sub = st(r#"[[[["lead","behind"]]], "id", "a", "fn", "KEN-KI-STYLE"]"#);
    assert_eq!((sub.id(), sub.get("fn").and_then(Value::as_str)), (Some("a"), Some("KEN-KI-STYLE")));
    // (every shipped strategy's :BASE is an object: the extractor resolved any repeat first-wins)
    for s in data().tables["strat_library"].as_array().unwrap() {
        assert!(s.get("base").is_none_or(Value::is_object), "{s}");
    }
}

// ---------------------------------------------------------------- the strategy layer's pure parts (§5, §8.4)

#[test]
fn layer_arms_seeds_puct_final_prior() {
    let ids = |me, vs| strat_arms(data(), me, vs).iter().map(|s| s.id().unwrap()).collect::<Vec<_>>();
    assert_eq!(
        ids(Kenpachi, Ichigo),
        ["s0-generic", "s1-brawler", "s3-zoner", "ki-ken", "q1-ken-ichigo", "qks-ichigo", "qks2-ichigo", "qks3-ichigo", "f-ki-kenpachi", "t0-ki-kenpachi"]
    );
    assert_eq!(
        ids(Kenpachi, Hisagi),
        ["s0-generic", "s1-brawler", "s3-zoner", "q1-ken-hisagi", "qks-hisagi", "qks2-hisagi", "qks3-hisagi", "qks4-hisagi", "qks5-hisagi", "f-kh-kenpachi", "t0-kh-kenpachi"]
    );
    assert!(ids(Hisagi, Ichigo).contains(&"h1-range")); // (:apply (:hisagi): against anyone)
    assert!(approx(strat_seed_value(data(), Kenpachi, Ichigo, "ki-ken"), 0.7)); // (against her equilibrium column)
    assert!(approx(strat_seed_value(data(), Ichigo, Kenpachi, "ki-ichigo"), 0.3)); // (the column side: 1 - his equilibrium row's cell)
    assert!(approx(strat_seed_value(data(), Ichigo, Kenpachi, "s0-generic"), 0.0));
    assert!(approx(strat_seed_value(data(), Ichigo, Ichigo, "s0-generic"), 0.5)); // (no matrix for the mirror)
    assert_eq!(strat_puct(&[3.0, 2.0], &[4.0, 4.0], &[0.5, 0.5], 1.0), 0); // (the better mean, equal visits)
    assert_eq!(strat_puct(&[3.0, 0.0], &[4.0, 0.0], &[0.5, 0.5], 1.0), 1); // (an unvisited arm is tried)
    assert_eq!(strat_final(&[3.0, 2.0], &[4.0, 4.0], &[0.2, 0.8], 0.0), 0); // (HARD-like: the values)
    assert_eq!(strat_final(&[3.0, 2.0], &[4.0, 4.0], &[0.2, 0.8], 1.0), 1); // (all prior)
    let lib = data().tables["strat_library"].as_array().unwrap();
    assert!(approx(strat_prior(sets(), Strat(&lib[1]), &[("lead", I(-3)), ("or", F(0.9))]), 1.5)); // (the brawler behind on Konpaku)
}

/// The shipped cue plists of strategy.lisp's checks (`(:lead 0 :ored 0 ...)`).
fn shikai(prev: i64, awk: i64, form: i64, dm: f32) -> Vec<(&'static str, Num)> {
    vec![("lead", I(0)), ("ored", I(0)), ("ost", I(0)), ("awk", I(awk)), ("prev", I(prev)), ("form", I(form)), ("dm", F(dm)),
         ("gauge", F(0.0)), ("wall", F(9.0)), ("oawk", I(0))]
}

#[test]
fn library_tables_as_the_lisp_checks() {
    let u = unit();
    let q3 = fq("qhs3-ichigo"); // (press wins in the Shikai by less than 0.1 here: not a +1.0 pin)
    let fs = shikai(0, 0, 0, 2.0);
    assert_eq!(strat_fq_pick(sets(), q3, &fs), 0);
    let q = strat_fq_q(sets(), q3, &fs);
    assert!(q.q[0] - q.as_slice()[1..].iter().fold(f32::MIN, |m, &x| m.max(x)) < 0.1);
    assert_eq!(fq_encode(q3, q3, 0, u).len(), 448);
    let p = fq("qhs-ichigo"); // (the pilot: six arms, the last aimed at Ichigo, kept state)
    assert_eq!(arms(p).len(), 6);
    assert_eq!(arm_id(&arms(p)[5]), Some("a-ken-ki"));
    assert_eq!((p["period"].as_i64(), p["keep-state"].as_bool(), p["xfeats"].as_bool(), p["gamma"].as_f64().map(|g| g as f32)), (Some(30), Some(true), Some(true), Some(0.966)));
    let p2 = fq("qhs2-ichigo"); // (round 2's refit: five arms, four general then one aimed at Ichigo; 89 rules in 5 groups)
    assert_eq!(arms(p2).len(), 5);
    assert_eq!((arm_id(&arms(p2)[0]), arm_id(&arms(p2)[4])), (Some("a-hisagi-pressd"), Some("a-ken-ki")));
    assert!(arms(p2)[..4].iter().all(|a| a["apply"] == *j(r#"["hisagi"]"#)));
    assert!(arms(p2).iter().all(|a| arm_id(a) != Some("a-zoner")));
    assert_eq!((rules(p2).len() as u64, groups_sum(p2)), (89, 89));
    assert!(rules(p2).iter().all(|r| r.as_array().unwrap().len() == 6));
    assert_eq!((p2["period"].as_i64(), p2.get("keep-state"), p2["xfeats"].as_bool(), p2["gamma"].as_f64().map(|g| g as f32)), (Some(30), None, Some(true), Some(0.98)));
    assert_eq!(strat_fq_pick(sets(), p2, &shikai(3, 0, 0, 2.0)), 0); // (the Shikai: arm 0, pinned)
    let codes = fq_encode(p2, p2, 3, u);
    assert_eq!(codes.len(), 448); // (the page's online copy: 3 + 5 x 89 integers)
    assert_eq!(qs(&fq_decode(&codes, p2, u).unwrap().0), qs(p2)); // (read back equal)
    // (every difficulty plays HARD's row whole since 2026-11-15, §11.28)
    let lk = |d| strat_lookup(data(), k(), Hisagi, Ichigo, d);
    assert!(lk(Easy) == lk(Hard) && lk(Normal) == lk(Hard) && lk(Hard).is_some());
    let m4 = fq("qhs4-mirror"); // (ranged close: Kenpachi's KI style code, as the data put it, no pin)
    assert_eq!(arm_fn(&arms(m4)[strat_fq_pick(sets(), m4, &shikai(1, 1, 1, 1.5))]), Some("KEN-KI-STYLE"));
    assert_eq!((arms(m4).len(), arm_id(&arms(m4)[0]), arm_id(&arms(m4)[4])), (5, Some("a-hisagi-kite"), Some("a-ken-ki")));
    assert_eq!((rules(m4).len() as u64, groups_sum(m4), m4["period"].as_i64(), m4.get("keep-state")), (89, 89, Some(30), None));
    assert_eq!(fq_encode(m4, m4, 0, u).len(), 448);
    for id in ["qh-ichigo", "qh-ken", "qh-mirror"] {
        // (arm 0 the merged style; ahead, free, no flags: arm 0)
        let q = fq(id);
        assert_eq!(arm_fn(&arms(q)[0]), Some("HISAGI-MERGED-STYLE"));
        assert_eq!(rules(q).len(), 48);
        assert_eq!(strat_fq_pick(sets(), q, &[("lead", I(99))]), 0);
    }
    let qk = fq("qis-ken");
    assert_eq!((arms(qk).len(), rules(qk).len(), qk["period"].as_i64(), arm_fn(&arms(qk)[0])), (5, 89, Some(30), Some("KEN-KI-STYLE")));
    assert_eq!(fq_encode(qk, qk, 0, u).len(), 448);
    // (c1: her own style behind / on his red, else Kenpachi's)
    let c1 = strat_by_id(data(), "c1-ichigo-ken").unwrap();
    let judged_fn = |feats: &[(&str, Num)]| strat_judge(sets(), c1, feats, None).0.and_then(|s| s.get("fn")).and_then(Value::as_str);
    assert_eq!(judged_fn(&[("ost", I(0)), ("lead", I(-2))]), Some("ICHIGO-KI-STYLE"));
    assert_eq!(judged_fn(&[("ost", I(0)), ("lead", I(2)), ("ored", I(0))]), Some("KEN-KI-STYLE"));
    // (§8.18 / §8.19 round 4: arm 0 NIL: no strategy; 89 rules in 5 groups; 0.5 s)
    for (me, vs, id, na) in [("kenpachi", "ichigo", "qks3-ichigo", 6), ("kenpachi", "hisagi", "qks5-hisagi", 8), ("kenpachi", "kenpachi", "qks-ken", 5)] {
        let s = strat_by_id(data(), id).unwrap();
        let q = s.fq().unwrap();
        assert_eq!(s.get("apply"), Some(j(&format!(r#"["{me}","{vs}"]"#))));
        assert_eq!((arms(q).len(), arms(q)[0].is_null()), (na, true));
        assert_eq!((rules(q).len() as u64, groups_sum(q), q["period"].as_i64(), q["xfeats"].as_bool(), q.get("keep-state")), (89, 89, Some(30), Some(true), None));
        assert_eq!(fq_encode(q, q, 0, u).len(), 3 + na * 89);
    }
    let q5 = fq("qks5-hisagi");
    assert_eq!((arm_fn(&arms(q5)[5]), arm_fn(&arms(q5)[6]), arm_fn(&arms(q5)[7])), (Some("ICHIGO-KI-STYLE"), Some("KEN-KH-STYLE"), Some("KEN-KH-STANDOFF-STYLE")));
    let (ev, _) = strat_event_arm(q5, State::Down, 10, -1, 8, k().strat_event_grace); // (the bait as its :KNOCKDOWN event layer)
    assert_eq!(ev.and_then(arm_fn), Some("KEN-KH-STYLE"));
    let ken_kh = strat_unit_find("st-ken-kh", &data().tables["strat_styles"]);
    assert_eq!(ken_kh["fn"].as_str(), Some("KEN-KH-STYLE"));
    for id in ["q1-ken-ichigo", "q1-ken-hisagi", "q1-ken-ken", "q1-ichigo-hisagi"] {
        assert_eq!((arms(fq(id)).len(), rules(fq(id)).len()), (2, 48));
    }
    let qi = strat_by_id(data(), "qis-hisagi").unwrap(); // (§8.19 round 5: Ichigo vs Hisagi's rebuilt table, 5 arms)
    let q = qi.fq().unwrap();
    assert_eq!((qi.get("apply"), arms(q).len(), rules(q).len() as u64, groups_sum(q)), (Some(j(r#"["ichigo","hisagi"]"#)), 5, 89, 89));
    assert_eq!(arm_fn(&arms(q)[strat_fq_pick(sets(), q, &shikai(1, 0, 0, 2.0))]), Some("KEN-KI-STYLE"));
    assert_eq!(fq_encode(q, q, 0, u).len(), 448);
    let qii = strat_by_id(data(), "q1-ichigo-ichigo").unwrap();
    assert_eq!((qii.get("apply"), arms(qii.fq().unwrap()).len(), arms(qii.fq().unwrap())[0].is_null()), (Some(j(r#"["ichigo","ichigo"]"#)), 2, true));
    assert!(strat_lookup(data(), k(), Ichigo, Ichigo, Easy) == strat_lookup(data(), k(), Ichigo, Ichigo, Hard));
    assert_eq!(arm_fn(&arms(fq("qks3-ichigo"))[1]), Some("ICHIGO-KI-STYLE")); // (KI's arm 1: the whole-game replacement)
    // (§8.19 round 5 step 7: :qks5-hisagi = :qks3-hisagi's q with the stand-off arm's column 1 below every row)
    for (r5, r3) in qs(q5).iter().zip(qs(fq("qks3-hisagi"))) {
        assert_eq!(&r5[..r5.len() - 1], &r3[..]);
        assert!(r5[r5.len() - 1] < r3.iter().fold(f32::MAX, |m, &x| m.min(x)));
    }
    // (no lookup table has an event layer)
    for r in data().tables["strat_lookup"].as_array().unwrap() {
        assert!(fq(r[3].as_str().unwrap()).get("event-arms").is_none());
    }
}

#[test]
fn library_units_and_tables_well_formed() {
    let t = &data().tables;
    let mut ids: Vec<&str> = ["strat_styles", "strat_data", "strat_units", "strat_rule_bases", "strat_library"]
        .iter()
        .flat_map(|n| t[*n].as_array().unwrap().iter().map(|u| u["id"].as_str().unwrap()))
        .collect();
    let n = ids.len();
    ids.sort();
    ids.dedup();
    assert_eq!(ids.len(), n); // (every unit id unique)
    let plays: Vec<Value> = t["strat_units_expanded"]
        .as_array()
        .unwrap()
        .iter()
        .map(|u| {
            let mut u = u.clone();
            u.as_object_mut().unwrap().retain(|k, _| k != "id" && k != "apply");
            u
        })
        .collect();
    for (i, p) in plays.iter().enumerate() {
        assert!(!plays[..i].contains(p), "two arm units play the same"); // (every arm unit a different strategy)
    }
    for s in t["strat_library"].as_array().unwrap() {
        if let Some(q) = s.get("fq") {
            let a = arms(q);
            assert!(a.iter().all(|a| a.is_null() || arm_id(a).is_some()));
            assert!(a.len() <= 8, "{} arms", a.len());
            for (i, x) in a.iter().enumerate() {
                assert!(!a[..i].iter().any(|y| arm_id(y) == arm_id(x)), "an arm twice in {}", s["id"]);
            }
            assert!(rules(q).iter().all(|r| r.as_array().unwrap().len() == a.len() + 1));
            assert!(q.get("groups").is_none() || groups_sum(q) == rules(q).len() as u64);
        }
    }
    // (PLAN3 X1 / PLAN4 B4: thirteen exchange arm units :x-*, six exchange data units :d-x-*)
    let count = |n: &str, pre: &str| t[n].as_array().unwrap().iter().filter(|u| u["id"].as_str().unwrap().starts_with(pre)).count();
    assert_eq!((count("strat_units", "x-"), count("strat_data", "d-x-")), (13, 6));
}

/// strat_units_expanded is STRAT-COMPOSE of strat_units, unit by unit (`:rules` in order; `:base` first-wins).
#[test]
fn compose_reproduces_the_expanded_units() {
    let t = &data().tables;
    let (raw, exp) = (t["strat_units"].as_array().unwrap(), t["strat_units_expanded"].as_array().unwrap());
    assert_eq!(raw.len(), exp.len());
    for (u, e) in raw.iter().zip(exp) {
        assert_eq!(&strat_compose(data(), u), e, "{}", u["id"]);
    }
    assert_eq!(strat_arm(data(), &Value::String("a-ken-kh-standoff".into())).unwrap()["fn"].as_str(), Some("KEN-KH-STANDOFF-STYLE"));
    assert_eq!(strat_arm(data(), &Value::Null), None);
    // (an arm turns several one-job rules on together: :a-hk-all's play; each one-job arm only its own key)
    let plays = |id: &str| {
        let mut a = strat_arm(data(), &Value::String(id.into())).unwrap();
        a.as_object_mut().unwrap().remove("id");
        a
    };
    assert_eq!(plays("a-hk-all"), *j(r#"{"fn":"HISAGI-HK-STYLE","ken-ranged":true,"apply":["hisagi"],"base":{"hk-wake":1.0,"hk-pot":1.0,"hk-kite":1.0}}"#));
    assert_eq!(plays("a-hk-wake"), *j(r#"{"fn":"HISAGI-HK-STYLE","ken-ranged":true,"apply":["hisagi"],"base":{"hk-wake":1.0}}"#));
    for (id, on) in [("a-hk-wake", [true, false, false]), ("a-hk-pot", [false, true, false]), ("a-hk-kite", [false, false, true]), ("a-hk-all", [true, true, true])] {
        let n = now(Strat(leak(strat_arm(data(), &Value::String(id.into())).unwrap())), &[("lead", I(0))]);
        let got = ["hk-wake", "hk-pot", "hk-kite"].map(|k| strat_out(sets(), Some(&n), k, None).is_some());
        assert_eq!(got, on, "{id}");
    }
    assert_eq!(strat_out(sets(), None, "hk-wake", None), None); // (no strategy: every rule off)
}

// ---------------------------------------------------------------- composites and Q selectors (§8.7, §8.12, §8.19)

#[test]
fn composite_judgement() {
    // (the first entry whose OWN fires at >= 0.5, else :ELSE, else NIL; OR across antecedents, AND within)
    let entries = r#"[[[[["lead","behind"],["mr","low"]]],"id","a"],[[[["lead","even"],["dj","in"]],[["lead","ahead"]]],"id","b"]]"#;
    let sw = st(&format!(r#"{{"id":"sw","switch":{entries}}}"#));
    let swe = st(&format!(r#"{{"id":"sw","switch":{entries},"else":{{"id":"c"}}}}"#));
    let id = |s: Strat, f: &[(&str, Num)]| strat_judge(sets(), s, f, None).0.and_then(|x| x.id());
    let ix = |s: Strat, f: &[(&str, Num)]| strat_judge(sets(), s, f, None).1;
    assert_eq!(id(sw, &[("lead", I(-5)), ("mr", F(0.1)), ("dj", I(9))]), Some("a")); // (behind and low)
    assert_eq!(id(sw, &[("lead", I(5)), ("mr", F(0.9)), ("dj", I(9))]), Some("b")); // (the OR's second antecedent)
    assert_eq!(id(sw, &[("lead", I(-5)), ("mr", F(0.9)), ("dj", I(9))]), None); // (behind, not low; no :else)
    assert_eq!(ix(sw, &[("lead", I(0)), ("dj", F(0.5))]), 1); // (even and in range)
    assert_eq!(ix(sw, &[("lead", I(-5)), ("mr", F(0.9)), ("dj", I(9))]), -1);
    assert_eq!(id(swe, &[("lead", I(-5)), ("mr", F(0.9)), ("dj", I(9))]), Some("c")); // (:else)
    assert_eq!(id(swe, &[("lead", I(-5)), ("mr", F(0.1))]), Some("a")); // (an entry before :else)
    assert_eq!(id(st(r#"{"switch":[[[[["lead","ahead"],["lead","behind"]]],"id","n"]]}"#), &[("lead", I(5))]), None); // (an OWN that never fires)
}

#[test]
fn q_selector_judgement() {
    // (Q = the rules' q averaged by firing strength, the arm = argmax (ties: the first), :MARGIN keeps :PREV)
    let q = j(r#"{"arms":[{"id":"a"},{"id":"b"}],"rules":[[[["mr","low"]],1.0,0.0],[[["mr","high"]],0.0,2.0],[null,0.5,0.5]]}"#);
    assert_eq!(strat_fq_q(sets(), q, &[("mr", F(0.1))]).as_slice(), [0.75, 0.25]); // (low at 1, the empty antecedent at 1)
    assert_eq!(strat_fq_q(sets(), q, &[("mr", F(0.9))]).as_slice(), [0.25, 1.25]);
    assert!(approx(strat_fq_q(sets(), q, &[("mr", F(0.375))]).q[0], 0.6666667)); // (low at 0.5: (0.5 + 0.5) / 1.5)
    assert_eq!(strat_fq_pick(sets(), q, &[("mr", F(0.1))]), 0);
    assert_eq!(strat_fq_pick(sets(), q, &[("mr", F(0.9))]), 1);
    assert_eq!(strat_fq_pick(sets(), j(r#"{"arms":["a","b"],"rules":[[[["mr","low"]],1.0,1.0]]}"#), &[("mr", F(0.1))]), 0); // (a tie: the first)
    assert_eq!(strat_fq_pick(sets(), j(r#"{"arms":["a","b"],"rules":[[[["mr","low"]],0.0,1.0]]}"#), &[("mr", F(0.9))]), 0); // (none fires: arm 0)
    let with_margin = |m: f32| {
        let mut v = q.clone();
        v.as_object_mut().unwrap().insert("margin".into(), Value::from(m as f64));
        leak(v)
    };
    assert_eq!(strat_fq_pick(sets(), with_margin(1.5), &[("mr", F(0.9)), ("prev", I(0))]), 0); // (b leads by 1 < the margin: kept)
    assert_eq!(strat_fq_pick(sets(), with_margin(0.5), &[("mr", F(0.9)), ("prev", I(0))]), 1);
    assert_eq!(strat_fq_pick(sets(), j(r#"{"arms":["a","b"],"rules":[[[["prev","yes"]],0.0,1.0],[[["prev","no"]],1.0,0.0]]}"#), &[("prev", I(1))]), 1);
    let sel = Strat(leak(Value::Object([("id".to_string(), Value::from("q")), ("fq".to_string(), q.clone())].into_iter().collect())));
    let (sub, k) = strat_judge(sets(), sel, &[("mr", F(0.9))], None);
    assert_eq!((sub.and_then(|s| s.id()), k), (Some("b"), 1));
    // (a crisp partition reproduces the composite c1 on every state of its cues)
    let c1 = strat_by_id(data(), "c1-ichigo-ken").unwrap();
    let crisp = j(&format!(
        r#"{{"fq":{{"arms":[{},{}],"rules":[[[["ost","free"],["lead","behind"]],0.0,1.0],[[["ost","free"],["lead","even"],["ored","yes"]],0.0,1.0],
            [[["ost","free"],["lead","ahead"],["ored","yes"]],0.0,1.0],[[["ost","free"],["lead","even"],["ored","no"]],1.0,0.0],
            [[["ost","free"],["lead","ahead"],["ored","no"]],1.0,0.0],[[["ost","busy"]],1.0,0.0]]}}}}"#,
        c1.get("else").unwrap(),
        // (the first entry's plist as an object)
        {
            let e = c1.get("switch").unwrap()[0].as_array().unwrap();
            Value::Object(e[1..].chunks(2).map(|c| (c[0].as_str().unwrap().to_string(), c[1].clone())).collect())
        }
    ));
    for lead in -9..=9 {
        for ored in 0..2 {
            for ost in 0..=4 {
                let ft = [("lead", I(lead)), ("ored", I(ored)), ("ost", I(ost))];
                assert_eq!(strat_judge(sets(), c1, &ft, None).0.and_then(|s| s.id()), strat_judge(sets(), Strat(crisp), &ft, None).0.and_then(|s| s.id()));
            }
        }
    }
}

#[test]
fn additive_q_selector() {
    // (each group averaged on its own, Q their sum; a group with no rule firing adds 0; the firing normalised per group)
    let q = j(r#"{"arms":["a","b"],"groups":[2,2],"rules":[[[["mr","low"]],1.0,0.0],[[["mr","high"]],0.0,1.0],
                  [[["dm","m-close"]],0.0,0.5],[[["dm","m-far"]],0.25,0.0]]}"#);
    assert_eq!(strat_fq_q(sets(), q, &[("mr", F(0.1)), ("dm", F(2.0))]).as_slice(), [1.0, 0.5]);
    assert_eq!(strat_fq_q(sets(), q, &[("mr", F(0.1)), ("dm", F(9.0))]).as_slice(), [1.25, 0.0]);
    assert_eq!(strat_fq_q(sets(), q, &[("mr", F(0.1)), ("dm", F(4.0))]).as_slice(), [1.0, 0.0]); // (mid: group 1 silent)
    assert_eq!(strat_fq_pick(sets(), q, &[("mr", F(0.9)), ("dm", F(2.0))]), 1);
    let w = strat_fq_fire(sets(), q, &[("mr", F(0.1)), ("dm", F(3.15))]);
    assert_eq!(w, [1.0, 0.0, 1.0, 0.0]);
    assert!(approx(fq_q_at(q, &w, 1), 0.5));
    assert!(approx(fq_v_at(q, &w), 1.0)); // (max_a Q, not the per-group maxima's 1.0 + 0.5)
    // (a grouped table whose extra groups are all 0 plays the shipped table: Hisagi vs Ichigo's 48 rules + 3 more groups)
    let ship = fq("qh-ichigo");
    let mut rs: Vec<Value> = rules(ship)
        .iter()
        .map(|r| {
            let mut r = r.as_array().unwrap().clone();
            let m = r[1..].iter().map(|x| x.as_f64().unwrap() as f32).fold(f32::MAX, f32::min);
            r.push(Value::from((m - 1.0) as f64));
            Value::Array(r)
        })
        .collect();
    for a in [r#"[["form","no"],["dm","m-close"]]"#, r#"[["form","yes"],["dm","m-close"]]"#, r#"[["gauge","g-high"]]"#, r#"[["wall","w-near"]]"#] {
        rs.push(j(&format!("[{a},0.0,0.0,0.0]")).clone());
    }
    let g = leak(Value::Object(
        [("arms", j(r#"["a","b","c"]"#).clone()), ("groups", j("[48,2,1,1]").clone()), ("xfeats", Value::Bool(true)), ("rules", Value::Array(rs))]
            .into_iter()
            .map(|(k, v)| (k.to_string(), v))
            .collect(),
    ));
    for lead in [-1, 0, 1] {
        for ored in 0..2 {
            for ost in [0, 2] {
                for awk in 0..2 {
                    for prev in 0..2 {
                        let fs = [("lead", I(lead)), ("ored", I(ored)), ("ost", I(ost)), ("awk", I(awk)), ("prev", I(prev)), ("form", I(1)),
                                  ("dm", F(2.0)), ("gauge", F(0.5)), ("wall", F(1.0))];
                        assert_eq!(strat_fq_pick(sets(), ship, &fs), strat_fq_pick(sets(), g, &fs));
                    }
                }
            }
        }
    }
}

// ---------------------------------------------------------------- the online fuzzy Q's pure part (§8.14)

#[test]
fn online_fq_td_and_page() {
    let u = unit();
    let base = j(r#"{"arms":[{"id":"a"},{"id":"b"}],"rules":[[[["mr","low"]],0.1,0.2],[[["mr","high"]],0.3,0.0]]}"#);
    let (f0, f1, fh) = (strat_fq_fire(sets(), base, &[("mr", F(0.1))]), strat_fq_fire(sets(), base, &[("mr", F(0.9))]), vec![0.75f32, 0.25]);
    assert_eq!(f0, [1.0, 0.0]);
    let w = strat_fq_fire(sets(), j(r#"{"rules":[[[["mr","low"]],0.0],[null,0.0]]}"#), &[("mr", F(0.375))]); // (low at 0.5, the empty one at 1)
    assert!(approx(w[0], 1.0 / 3.0) && approx(w[1], 2.0 / 3.0));
    assert!(strat_fq_fire(sets(), j(r#"{"rules":[[[["mr","low"]],1.0]]}"#), &[("mr", F(0.9))]).iter().all(|&x| x == 0.0)); // (none fires)
    // (r = scale x the balance's change to the next judgement; the last: to the end's, plus the result)
    let tr = fq_transitions(&[(f0.clone(), 0, 1.0), (f1.clone(), 1, 1.5)], 0.5, -1.0, 0.1);
    assert!(tr.len() == 2 && approx(tr[0].r, 0.05) && tr[0].next.as_ref() == Some(&f1));
    assert!(approx(tr[1].r, -1.1) && tr[1].next.is_none() && tr[1].arm == 1);
    assert!(fq_transitions(&[], 0.0, 1.0, 0.1).is_empty());
    let t = |fire: &[f32], arm, r, next: Option<&Vec<f32>>| Trans { fire: fire.to_vec(), arm, r, next: next.cloned() };
    // (one step: delta = 0.05 + 0.9 x 0.3 - 0.1 = 0.22; q += eta x alpha x delta, the rest untouched)
    let mut q = base.clone();
    fq_td_update(&mut q, base, &[t(&f0, 0, 0.05, Some(&f1))], 0.5, 0.9, Some(1.0), u);
    assert!((qs(&q)[0][0] - 0.21).abs() < 1e-5);
    assert_eq!((qs(&q)[1].clone(), qs(&q)[0][1]), (vec![0.3, 0.0], 0.2));
    // (the clamp: a huge reward moves q only to the offline value + cap, and - cap the other way)
    let mut q = base.clone();
    fq_td_update(&mut q, base, &[t(&f0, 1, 50.0, None), t(&f0, 1, 50.0, None)], 0.5, 0.9, Some(0.05), u);
    assert!((qs(&q)[0][1] - 0.25).abs() < 1e-5);
    fq_td_update(&mut q, base, &[t(&f1, 0, -50.0, None)], 0.5, 0.9, Some(0.05), u);
    assert!((qs(&q)[1][0] - 0.25).abs() < 1e-5);
    // (exploration over N arms: eps 0 or u >= eps keeps I; below eps never I, every other arm reached, evenly)
    assert_eq!((fq_explore_arm(0.01, 0.0, 2, 4), fq_explore_arm(0.5, 0.1, 2, 4), fq_explore_arm(0.0, 0.1, 0, 1)), (2, 2, 0));
    let seen: Vec<i64> = (0..300).map(|k| fq_explore_arm(0.1 * (k as f64 / 300.0), 0.1, 2, 4)).collect();
    assert!(!seen.contains(&2) && [0, 1, 3].iter().all(|j| seen.iter().filter(|&&x| x == *j).count() == 100));
    assert_eq!(fq_explore_arm(0.05, 0.1, 0, 2), 1);
    // (no cap: the same reward moves q past offline + 0.05)
    let mut q = base.clone();
    fq_td_update(&mut q, base, &[t(&f0, 1, 50.0, None)], 0.5, 0.9, None, u);
    assert!((qs(&q)[0][1] - (0.2 + 0.5 * (50.0 - 0.2))).abs() < 1e-4);
    // (a no-op match leaves the table equal; so does a transition whose delta is 0)
    let mut q = base.clone();
    fq_td_update(&mut q, base, &[], 0.05, 0.9, None, u);
    assert_eq!(qs(&q), qs(base));
    fq_td_update(&mut q, base, &[t(&f1, 0, 0.3, None)], 0.05, 0.9, None, u);
    assert_eq!(qs(&q), qs(base));
    // (split firing: each rule moves by its share, the step over the firing's sum of squares, so Q(s, a) moves by eta x delta)
    let mut q = base.clone();
    fq_td_update(&mut q, base, &[t(&fh, 0, 1.0, None)], 0.1, 0.9, Some(1.0), u);
    let x = fh[0];
    let d = 1.0 - (x * 0.1 + (1.0 - x) * 0.3);
    let n = d / (x * x + (1.0 - x) * (1.0 - x));
    assert!((qs(&q)[0][0] - (0.1 + 0.1 * x * n)).abs() < 1e-4);
    assert!((qs(&q)[1][0] - (0.3 + 0.1 * (1.0 - x) * n)).abs() < 1e-4);
    assert!((fq_q_at(&q, &fh, 0) - ((1.0 - d) + 0.1 * d)).abs() < 1e-4);
    // (the page: format, the offline table's checksum, the matches, every q; read back equal; another offline table or format: none)
    let mut q = base.clone();
    fq_td_update(&mut q, base, &[t(&fh, 0, 1.0, Some(&f1)), t(&f1, 1, -0.4, None)], 0.05, 0.9, None, u);
    let codes = fq_encode(&q, base, 7, u);
    assert_eq!(codes.len(), 3 + 4);
    let (back, n) = fq_decode(&codes, base, u).unwrap();
    assert_eq!((qs(&back), n), (qs(&q), 7));
    assert!(fq_decode(&codes, &q, u).is_none()); // (saved from another offline table)
    let mut c99 = codes.clone();
    c99[0] = 99;
    assert!(fq_decode(&c99, base, u).is_none() && fq_decode(&[], base, u).is_none() && fq_decode(&codes[..codes.len() - 1], base, u).is_none());
    // (the shipped table: its copy decodes from its own encoding, and the library entry is never written by an update of a copy)
    let lib = fq("q1-ichigo-ken");
    let keep = lib.clone();
    let f = strat_fq_fire(sets(), lib, &[("lead", I(-1)), ("ored", I(0)), ("ost", I(0)), ("awk", I(0)), ("prev", I(0))]);
    assert_eq!(f.iter().filter(|&&x| x > 0.0).count(), 1); // (crisp: one rule fires)
    let mut q = lib.clone();
    fq_td_update(&mut q, lib, &[t(&f, 0, -2.0, None)], 0.05, 0.9, None, u);
    assert!(*lib == keep && qs(&q) != qs(lib));
    assert_eq!(qs(&fq_decode(&fq_encode(&q, lib, 1, u), lib, u).unwrap().0), qs(&q));
}

/// FQ-CHECKSUM of a shipped table against the key: the vs-learn trace logs `duel fq load 3 1 fresh matches 0 checksum 179296`
/// (Ichigo against Kenpachi: t0-ki-ichigo).
#[test]
fn fq_checksum_matches_the_key() {
    assert_eq!(fq_checksum(fq("t0-ki-ichigo"), unit()), 179296);
}

// ---------------------------------------------------------------- the DRIVE switch's target (§8.16)

#[test]
fn drive_switch_target_and_dir() {
    let bk = [Some((0.0, 3.4)), Some((2.5, 4.55))]; // (Hisagi's Bankai: WA 0-3 + slack, TABA 2.5-4.15 + slack)
    let sh = [Some((3.6, 6.6)), Some((0.0, 2.4)), Some((0.0, 4.9))]; // (a three-pointer kit)
    assert_eq!(strat_switch_to(1, 2, 4.5, &bk, Some(2)), Some(2)); // (WA pushed him to 4.5: TABA reaches)
    assert_eq!(strat_switch_to(1, 2, 1.5, &bk, Some(2)), None); // (WA whiffed, he is close: TABA's dead zone)
    assert_eq!(strat_switch_to(2, 2, 3.0, &bk, Some(2)), None); // (the pointer he is on is no target)
    assert_eq!(strat_switch_to(1, 2, 3.0, &bk, None), Some(2)); // (no map: the next pointer that reaches)
    assert_eq!(strat_switch_to(1, 3, 4.5, &sh, None), Some(3)); // (the next, 2, does not reach; 3 does)
    assert_eq!(strat_switch_to(3, 3, 2.0, &sh, None), Some(2)); // (cyclic: from 3 the next is 1 (no), then 2)
    assert_eq!(strat_switch_to(1, 3, 7.0, &sh, None), None);
    assert_eq!((strat_switch_dir(1, 2, 2), strat_switch_dir(2, 1, 2), strat_switch_dir(3, 1, 3), strat_switch_dir(1, 3, 3)), (1, 1, 1, -1));
}

// ---------------------------------------------------------------- the event layer (§8.19 round 5 step 6)

#[test]
fn event_arm_window() {
    let arm = r#"{"id":"ev-test","fn":"KEN-KH-STYLE"}"#;
    let delay = 8;
    let g = k().strat_event_grace;
    for q in [j(&format!(r#"{{"arms":[null],"event-arms":[{{"knockdown":{arm}}}]}}"#)), j(&format!(r#"{{"arms":[null],"event-arms":[["knockdown",{arm}]]}}"#))] {
        let ev = |ss, now, last| {
            let (on, l) = strat_event_arm(q, ss, now, last, delay, g);
            (on.and_then(arm_id), l)
        };
        assert_eq!(ev(State::Idle, 100, -1), (None, -1)); // (never down: off)
        assert_eq!(ev(State::Down, 100, -1), (Some("ev-test"), 100)); // (knocked down: fires)
        assert_eq!(ev(State::Wakeup, 130, 100), (Some("ev-test"), 130)); // (waking up: holds)
        assert_eq!(ev(State::Idle, 130 + delay + g, 130), (Some("ev-test"), 130));
        assert_eq!(ev(State::Idle, 131 + delay + g, 130), (None, 130)); // (hands back)
        assert_eq!(ev(State::Hoho, 50, 130), (None, -1)); // (a tick from an earlier match)
    }
    assert_eq!(strat_event_arm(j(r#"{"arms":[null]}"#), State::Down, 100, -1, delay, g).1, -1); // (no key: nothing)
    // (a table's :EVENT-ARMS ids expand to their units' plists)
    let st = strat_expand(data(), j(r#"{"id":"ev-x","fq":{"arms":[null,"a-ken-ki"],"rules":[[[["lead","even"]],0.0,0.0]],"event-arms":[["knockdown","a-ken-kh"]]}}"#));
    let (on, _) = strat_event_arm(&st["fq"], State::Down, 5, -1, delay, g);
    assert_eq!(on.and_then(arm_fn), Some("KEN-KH-STYLE"));
}

// ---------------------------------------------------------------- the SP cues and their rule bases (§11.3, §11.28)

fn rb(id: &str) -> &'static Value {
    strat_unit_find(id, &data().tables["strat_rule_bases"])
}
fn sp_cues(fs: f32, ofs: f32, burst: bool, oburst: bool, xch: i64, oxch: i64) -> Vec<(&'static str, Num)> {
    let mut c = Cues::default();
    strat_sp_cues(fs, ofs, burst, oburst, xch, oxch, k().fs_cell, &mut c);
    c.as_slice().to_vec()
}
/// A raw T table on rule base RB with arms (nil :a-generic), its q from Q per antecedent, its extra keys KEYS (`"xfeats":true,...`).
fn tbl(rb_id: &str, keys: &str, q: impl Fn(&Value) -> [f32; 2]) -> Value {
    let qrows: Vec<Value> = rb(rb_id)["antes"].as_array().unwrap().iter().map(|a| Value::from(q(a).map(|x| x as f64).to_vec())).collect();
    let raw = format!(r#"{{"id":"t","fq":{{"arms":[null,"a-generic"],"rule-base":"{rb_id}"{keys},"q":{}}}}}"#, Value::Array(qrows));
    strat_expand(data(), j(&raw))
}

#[test]
fn sp_cues_and_rb_sp() {
    let cell = |fs| sp_cues(fs, 0.0, false, false, -1, -1)[0].1;
    assert_eq!([0.0, 99.9, 100.0, 199.9, 200.0, 299.9, 300.0].map(cell), [0, 0, 1, 1, 2, 2, 3].map(I));
    let names = ["mcell", "ocell", "mburst", "oburst", "xch"];
    let zip = |v: [i64; 5]| names.iter().zip(v).map(|(&k, v)| (k, I(v))).collect::<Vec<_>>();
    assert_eq!(sp_cues(250.0, 100.0, true, false, 7, 7), zip([2, 1, 1, 0, 1]));
    assert_eq!(sp_cues(0.0, 300.0, false, true, 7, 9), zip([0, 3, 0, 1, 0]));
    assert_eq!(sp_cues(0.0, 0.0, false, false, -1, -1), zip([0, 0, 0, 0, 0]));
    let r = rb("rb-sp");
    let antes = r["antes"].as_array().unwrap();
    assert_eq!((antes.len() as u64, groups_sum(r), r["xfeats"].as_bool()), (42, 42, Some(true)));
    assert!(antes.iter().all(|a| !a.as_array().unwrap().iter().any(|c| c[0] == "gauge")));
    // (every group's firing adds up to 1 on a grid over every cue's points and the distance's ramps)
    for lead in [-2, 0, 1] {
        for ost in [0, 1, 4] {
            for prev in [0, 1, 3] {
                for dm in [1.0, 3.1, 5.0, 8.0] {
                    for c in [0i64, 1, 3] {
                        let mut feats = sp_cues(100.0 * c as f32, 100.0 * (3 - c) as f32, c == 1, c == 3, if c == 0 { 5 } else { -1 }, 5);
                        feats.extend([("lead", I(lead)), ("ost", I(ost)), ("prev", I(prev)), ("form", I(c % 3)), ("dm", F(dm))]);
                        let mut at = 0;
                        for g in r["groups"].as_array().unwrap() {
                            let g = g.as_u64().unwrap() as usize;
                            let sum: f32 = antes[at..at + g].iter().map(|a| strat_ante(sets(), a, &feats)).sum();
                            assert!((1.0 - sum).abs() < 1e-5);
                            at += g;
                        }
                    }
                }
            }
        }
    }
    let q = |a: &Value| {
        if *a == *j(r#"[["xch","yes"]]"#) {
            [0.0, 2.0]
        } else if a.as_array().unwrap().contains(j(r#"["mcell","no"]"#)) {
            [0.0, 1.0]
        } else {
            [0.0, 0.0]
        }
    };
    let s = leak(tbl("rb-sp", r#","xfeats":true,"period":30"#, q));
    let f = &s["fq"];
    assert_eq!((rules(f).len(), f["groups"].clone(), f["xfeats"].as_bool()), (42, j("[18,9,9,4,2]").clone(), Some(true)));
    let base = |m: i64, o: i64, x: i64| {
        vec![("mcell", I(m)), ("ocell", I(o)), ("xch", I(x)), ("lead", I(0)), ("ost", I(0)), ("prev", I(0)), ("form", I(0)), ("dm", F(3.0)),
             ("mburst", I(0)), ("oburst", I(0))]
    };
    assert_eq!(strat_fq_pick(sets(), f, &base(0, 2, 0)), 1); // (my gauge empty: arm 1)
    assert_eq!(strat_fq_pick(sets(), f, &base(2, 2, 0)), 0); // (two cells: arm 0, the tie's first)
    assert_eq!(strat_fq_pick(sets(), f, &base(3, 0, 1)), 1); // (an exchange open: arm 1)
    assert_eq!(strat_judge(sets(), Strat(s), &base(0, 0, 0), None).0.and_then(|x| x.id()), Some("a-generic"));
    assert_eq!(fq_encode(f, f, 0, unit()).len(), 3 + 2 * 42);
    assert!(panics(move || drop(tbl("rb-sp", r#","period":30"#, q)))); // (no :XFEATS: refused)
}

#[test]
fn sp2_cues_and_rb_sp2() {
    let sp2 = |ready, aw, owall, left, total, p, o, sw| {
        let mut c = Cues::default();
        strat_sp2_cues(ready, aw, owall, left, total, p, o, sw, &mut c);
        c.as_slice().to_vec()
    };
    let names = ["awst", "owall", "time", "mptr", "optr", "swopen"];
    let zip = |v: [Num; 6]| names.iter().zip(v).map(|(&k, v)| (k, v)).collect::<Vec<_>>();
    assert_eq!(sp2(false, false, 4.0, 18000, 18000, 1, 2, false), zip([I(0), F(4.0), F(0.0), I(1), I(2), I(0)]));
    assert_eq!(sp2(true, false, 1.5, 9000, 18000, 3, 4, true), zip([I(1), F(1.5), F(0.5), I(3), I(3), I(1)])); // (KESSA's 4th reads 3)
    assert_eq!(sp2(true, true, 0.0, -5, 18000, 2, 1, true), zip([I(2), F(0.0), F(1.0), I(2), I(1), I(1)])); // (awakened wins; clock clamped)
    let r = rb("rb-sp2");
    let antes = r["antes"].as_array().unwrap();
    assert_eq!((antes.len() as u64, groups_sum(r), r["groups"].clone(), r["xfeats"].as_bool()), (104, 104, j("[36,9,12,9,4,2,4,4,9,6,9]").clone(), Some(true)));
    assert!(antes.iter().all(|a| !a.as_array().unwrap().iter().any(|c| c[0] == "prev" || c[0] == "gauge")));
    // (each group's firing adds up to 1 on a grid over its cues wherever at most one cue sits on a ramp; above 0.999 with two)
    let grid: Vec<(&str, Vec<Num>)> = vec![
        ("lead", vec![I(-2), I(-1), F(-0.5), I(0), F(0.5), I(1), I(3)]), ("ored", vec![I(0), I(1)]), ("awst", vec![I(0), I(1), I(2)]),
        ("oawk", vec![I(0), I(1)]), ("form", vec![I(0), I(1), I(2)]), ("ost", (0..5).map(I).collect()), ("mcell", (0..4).map(I).collect()),
        ("ocell", (0..4).map(I).collect()), ("mburst", vec![I(0), I(1)]), ("oburst", vec![I(0), I(1)]), ("xch", vec![I(0), I(1)]),
        ("swopen", vec![I(0), I(1)]), ("mptr", (1..4).map(I).collect()), ("optr", (1..4).map(I).collect()),
        ("dm", [0.5, 2.9, 3.15, 3.4, 4.5, 5.25, 6.0, 9.0].map(F).to_vec()), ("wall", [0.0, 2.0, 2.5, 3.0, 6.0].map(F).to_vec()),
        ("owall", [0.0, 2.0, 2.5, 3.0, 6.0].map(F).to_vec()), ("mr", [0.0, 0.45, 0.5, 0.55, 1.0].map(F).to_vec()),
        ("or", [0.0, 0.45, 0.5, 0.55, 1.0].map(F).to_vec()), ("time", [0.0, 0.3, 0.35, 0.4, 0.5, 0.6, 0.65, 0.7, 1.0].map(F).to_vec()),
    ];
    let mut at = 0;
    for g in r["groups"].as_array().unwrap() {
        let g = g.as_u64().unwrap() as usize;
        let rs = &antes[at..at + g];
        at += g;
        let mut cues: Vec<&str> = vec![];
        for a in rs {
            for c in a.as_array().unwrap() {
                let c = c[0].as_str().unwrap();
                if !cues.contains(&c) {
                    cues.push(c);
                }
            }
        }
        let ramp = |c: &str, v: Num| {
            rs.iter().any(|a| a.as_array().unwrap().iter().any(|x| x[0] == c && {
                let mu = duel_sim::cpu::fuzzy::fz_mu(sets(), v, x[1].as_str().unwrap());
                0.0 < mu && mu < 1.0
            }))
        };
        fn walk(cs: &[&'static str], feats: &mut Vec<(&'static str, Num)>, nr: usize, grid: &[(&str, Vec<Num>)], rs: &[Value], ramp: &dyn Fn(&str, Num) -> bool) {
            let Some((c, rest)) = cs.split_first() else {
                let sum: f32 = rs.iter().map(|a| strat_ante(sets(), a, feats)).sum();
                assert!(if nr <= 1 { (1.0 - sum).abs() < 1e-5 } else { sum > 0.999 }, "{feats:?} {sum}");
                return;
            };
            for &v in &grid.iter().find(|(n, _)| n == c).unwrap_or_else(|| panic!("{c} off the grid")).1 {
                feats.push((c, v));
                walk(rest, feats, nr + ramp(c, v) as usize, grid, rs, ramp);
                feats.pop();
            }
        }
        let cues: Vec<&'static str> = cues.iter().map(|c| grid.iter().find(|(n, _)| n == c).map(|(n, _)| *n).unwrap()).collect();
        let cues: Vec<&'static str> = cues.into_iter().map(|c| -> &'static str { Box::leak(c.to_string().into_boxed_str()) }).collect();
        walk(&cues, &mut vec![], 0, &grid, rs, &ramp);
    }
    let base: Vec<(&'static str, Num)> = vec![
        ("lead", I(0)), ("ored", I(0)), ("awst", I(0)), ("oawk", I(0)), ("form", I(0)), ("ost", I(0)), ("mcell", I(0)), ("ocell", I(0)),
        ("mburst", I(0)), ("oburst", I(0)), ("xch", I(0)), ("swopen", I(0)), ("mptr", I(1)), ("optr", I(1)), ("dm", F(3.0)), ("wall", F(5.0)),
        ("owall", F(5.0)), ("mr", F(1.0)), ("or", F(1.0)), ("time", F(0.1)),
    ];
    let at = |key: &'static str, v: Num| {
        let mut f = base.clone();
        match f.iter_mut().find(|(k, _)| *k == key) {
            Some(x) => x.1 = v,
            None => f.insert(0, (key, v)),
        }
        f
    };
    let only = |cue: &str, set: &str| {
        let pair = Value::from(vec![Value::from(cue), Value::from(set)]);
        move |a: &Value| if a.as_array().unwrap().contains(&pair) { [0.0, 1.0] } else { [0.0, 0.0] }
    };
    for (c, set, v) in [("awst", "yes", I(1)), ("awst", "k2", I(2)), ("owall", "w-near", F(1.0)), ("time", "t-late", F(0.9)), ("time", "t-mid", F(0.5)),
                        ("mptr", "k3", I(3)), ("optr", "k2", I(2)), ("swopen", "yes", I(1)), ("mr", "r-low", F(0.3)), ("or", "r-low", F(0.2)),
                        ("ost", "atk", I(1)), ("ost", "atk", I(2)), ("ost", "evade", I(3)), ("ost", "down", I(4))] {
        let t = leak(tbl("rb-sp2", r#","xfeats":true,"period":30"#, only(c, set)));
        assert_eq!(strat_fq_pick(sets(), &t["fq"], &base), 0, "{c} {set}"); // (the cue elsewhere: arm 0)
        assert_eq!(strat_fq_pick(sets(), &t["fq"], &at(c, v)), 1, "{c} {set}"); // (that cue alone moved: arm 1)
    }
    let t = tbl("rb-sp2", r#","xfeats":true"#, only("awst", "no"));
    assert_eq!((rules(&t["fq"]).len(), t["fq"]["groups"].clone()), (104, j("[36,9,12,9,4,2,4,4,9,6,9]").clone()));
    assert_eq!(fq_encode(&t["fq"], &t["fq"], 0, unit()).len(), 3 + 2 * 104);
    assert!(panics(move || drop(tbl("rb-sp2", "", only("awst", "no"))))); // (no :XFEATS: refused)
}

// ---------------------------------------------------------------- the nine T0 tables of the lookup (§11.29, PLAN4 B4)

#[test]
fn t0_lookup_rows() {
    let u = unit();
    type Row = (duel_sim::components::Character, duel_sim::components::Character, &'static str, usize, &'static str, Option<&'static str>, i64, Vec<(&'static str, Num)>, Vec<(&'static str, Num)>);
    let rows: Vec<Row> = vec![
        (Ichigo, Kenpachi, "t0-ki-ichigo", 6, "a4-i-all", Some("d-x-ki-i"), 812408, vec![("xch", I(1))], vec![]), // (arm 1 answer: an exchange open)
        (Kenpachi, Ichigo, "t0-ki-kenpachi", 4, "c-ki-k-r2-b1a2", Some("d-x-ki-k"), 255846, vec![("dm", F(2.0))], vec![("dm", F(7.0))]),
        (Kenpachi, Hisagi, "t0-kh-kenpachi", 2, "c-ki-k-r2-b1a2", Some("d-x-kh-k"), 575073, vec![("ost", I(4))], vec![]), // (wake: he is down)
        (Hisagi, Kenpachi, "t0-kh-hisagi", 3, "h5-all", Some("d-x-kh-h"), 195522, vec![("xch", I(1))], vec![("ost", I(0))]),
        (Ichigo, Hisagi, "t0-ih-ichigo", 4, "a4-i-brawl", Some("d-x-ih-i"), 76462, vec![("ocell", I(1))], vec![("optr", I(3))]),
        (Hisagi, Ichigo, "t0-ih-hisagi", 4, "h5-all", Some("d-x-ih-h"), 671538, vec![("form", I(1)), ("dm", F(4.5))], vec![]), // (tip: form 1 at mid)
        (Kenpachi, Kenpachi, "t0-kk-kenpachi", 3, "c-ki-k-r2-b1a2", None, 255846, vec![("ost", I(4))], vec![]),
        (Ichigo, Ichigo, "t0-ii-ichigo", 5, "a4-i-all", None, 812408, vec![("xch", I(1))], vec![]),
        (Hisagi, Hisagi, "t0-hh-hisagi", 3, "a-generic", None, 101019, vec![("form", I(1)), ("ost", I(1))], vec![]),
    ];
    for (me, vs, id, na, arm0, with, old, job1_cues, base_cues) in rows {
        let s = strat_lookup(data(), k(), me, vs, Hard).unwrap();
        let q = s.fq().unwrap();
        let mut base = base_cues.clone();
        base.push(("swopen", I((me != Hisagi) as i64))); // (Kenpachi's climb owns "switch not open", KH Hisagi's range "open")
        base.extend([("lead", I(0)), ("ored", I(0)), ("awst", I(0)), ("oawk", I(0)), ("form", I(0)), ("ost", I(1)), ("mcell", I(0)), ("ocell", I(0)),
                     ("mburst", I(0)), ("oburst", I(0)), ("xch", I(0)), ("mptr", I(1)), ("optr", I(1)), ("dm", F(3.0)), ("wall", F(5.0)),
                     ("owall", F(5.0)), ("mr", F(1.0)), ("or", F(1.0)), ("time", F(0.1)), ("prev", I(0))]);
        let job1: Vec<_> = job1_cues.iter().copied().chain(base.iter().copied()).collect();
        assert_eq!(s.id(), Some(id));
        assert_eq!(s.get("apply"), Some(j(&format!(r#"["{}","{}"]"#, me.name().to_lowercase(), vs.name().to_lowercase()))));
        assert_eq!((arms(q).len(), arm_id(&arms(q)[0])), (na, Some(arm0)));
        assert_eq!((rules(q).len() as u64, groups_sum(q), q["xfeats"].as_bool(), q["keep-state"].as_bool(), q["period"].as_i64()), (104, 104, Some(true), Some(true), Some(30)));
        assert_eq!(strat_fq_pick(sets(), q, &base), 0, "{id}"); // (arm 0 where no job cue fires)
        assert_eq!(strat_fq_pick(sets(), q, &job1), 1, "{id}");
        if let Some(w) = with {
            // (the exchange unit under every arm: an arm's own key wins)
            let ub = strat_unit_find(w, &data().tables["strat_data"])["base"].as_object().unwrap();
            assert!(arms(q).iter().all(|a| ub.keys().all(|key| a["base"].get(key).is_some())));
        }
        let codes = fq_encode(q, q, 2, u);
        assert_eq!(fq_decode(&codes, q, u).unwrap().1, 2); // (its own copy reads back, with its match count)
        assert_ne!(old, fq_checksum(q, u)); // (B4's copy, even at this size, loads fresh)
        let with_sum = |c: i64| codes.iter().enumerate().map(|(i, &x)| if i == 1 { c } else { x }).collect::<Vec<_>>();
        assert!(fq_decode(&with_sum(old), q, u).is_none());
        assert!(fq_decode(&with_sum(codes[1] + 1), q, u).is_none()); // (the right size, another checksum: fresh)
        let mut other = q.clone(); // (§11.17: the checksum covers the arms)
        other["arms"].as_array_mut().unwrap().reverse();
        assert_ne!(fq_checksum(&other, u), fq_checksum(q, u));
        assert!(fq_decode(&fq_encode(&other, &other, 2, u), q, u).is_none());
    }
    // (q2-ptr: the pointer rows move the pick: IH Ichigo plays i6-punish at his pointer 2 mid, brawl at his pointer 1 close)
    let base: Vec<(&'static str, Num)> = vec![
        ("lead", I(0)), ("ored", I(0)), ("awst", I(0)), ("oawk", I(0)), ("form", I(0)), ("ost", I(0)), ("mcell", I(0)), ("ocell", I(0)),
        ("mburst", I(0)), ("oburst", I(0)), ("xch", I(0)), ("mptr", I(1)), ("optr", I(3)), ("dm", F(7.0)), ("wall", F(5.0)), ("owall", F(5.0)),
        ("mr", F(1.0)), ("or", F(1.0)), ("time", F(0.1)), ("prev", I(0)),
    ];
    let ih = strat_lookup(data(), k(), Ichigo, Hisagi, Hard).unwrap().fq().unwrap();
    let pick = |cues: &[(&'static str, Num)]| strat_fq_pick(sets(), ih, &cues.iter().copied().chain(base.iter().copied()).collect::<Vec<_>>());
    assert_eq!(pick(&[("swopen", I(1)), ("optr", I(3)), ("dm", F(4.5))]), 0);
    assert_eq!(pick(&[("swopen", I(1)), ("optr", I(2)), ("dm", F(4.5))]), 2);
    assert_eq!(pick(&[("swopen", I(1)), ("ocell", I(1)), ("optr", I(3)), ("dm", F(1.0))]), 1); // (economy's cell job ...)
    assert_eq!(pick(&[("swopen", I(1)), ("ocell", I(1)), ("optr", I(2)), ("dm", F(1.0))]), 1);
    assert_eq!(pick(&[("swopen", I(1)), ("ocell", I(1)), ("optr", I(1)), ("dm", F(1.0))]), 0); // (... yields to brawl at his pointer 1 close)
}

// ---------------------------------------------------------------- a table's :WITH (PLAN4 §3)

#[test]
fn with_units_under_arms() {
    let unit = strat_unit_find("d-brawler", &data().tables["strat_data"]);
    let st = strat_expand(data(), j(r#"{"id":"t-with","fq":{"arms":[null,"a-ken-ki","a-zoner"],"with":["d-brawler"],"rules":[[[["lead","even"]],0.0,0.0,0.0]]}}"#));
    let a = arms(&st["fq"]);
    let (ken, zon) = (&a[1], &a[2]);
    assert!(a[0].is_null() && st["fq"].get("with").is_none());
    let mut want = strat_arm(data(), &Value::from("a-ken-ki")).unwrap(); // (no keys of its own: the unit's)
    want["base"] = unit["base"].clone();
    want["rules"] = unit["rules"].clone();
    assert_eq!(*ken, want);
    assert_eq!(zon["base"]["range"].as_f64().map(|x| x as f32), Some(1.5)); // (the zoner's own :range wins over the brawler's 0.7)
    assert_eq!(zon["base"]["b-step-in"].as_f64().map(|x| x as f32), Some(0.03)); // (a key only the unit names comes in)
    let z = Strat(leak(zon.clone()));
    assert!(approx(strat_value(sets(), z, "range", &[("dj", F(2.0)), ("ost", I(0)), ("dn", F(1.0)), ("do", F(1.0))]).unwrap().f(), 1.5));
    let zoner = strat_arm(data(), &Value::from("a-zoner")).unwrap();
    let own_rules = zoner["rules"].as_array().map_or(0, |r| r.len());
    let zb = zoner["base"].as_object().unwrap();
    assert!(zon["rules"].as_array().unwrap()[own_rules..].iter().all(|r| r[1].as_object().unwrap().keys().all(|k| !zb.contains_key(k))));
    // (an inline unit: only its new key comes in)
    let got = strat_with(data(), Some(ken.clone()), &[j(r#"{"id":"x","base":{"clash-p":2.0,"range":9.0}}"#).clone()]).unwrap();
    let mut want = ken.clone();
    want["base"]["clash-p"] = Value::from(2.0);
    assert_eq!(got, want);
    // (no :WITH, or an empty one: as before)
    let tbl = r#"{"id":"t-nowith","fq":{"arms":[null,"a-ken-ki","a-zoner"],"rules":[[[["lead","even"]],0.0,0.0,0.0]],"period":30}}"#;
    let tbl0 = r#"{"id":"t-nowith","fq":{"arms":[null,"a-ken-ki","a-zoner"],"rules":[[[["lead","even"]],0.0,0.0,0.0]],"period":30,"with":null}}"#;
    let e = strat_expand(data(), j(tbl));
    assert_eq!(e, strat_expand(data(), j(tbl0)));
    assert_eq!(arms(&e["fq"]), [Value::Null, strat_arm(data(), &Value::from("a-ken-ki")).unwrap(), zoner]);
}

// ---------------------------------------------------------------- style-knob.lisp's CPU checks (§11.6, §11.23)

#[test]
fn style_knobs_and_exchange_keys() {
    // (an arm's :BASE sets a knob, a firing rule replaces it, a rule that does not fire leaves the base; absent: the style's own value)
    for key in ["kk-hin-fs", "iks-wait-max", "kso-stale", "khf-bait-fs", "hb-band", "hr-near", "hkk-kite-p"] {
        let arm = Strat(leak(Value::Object(
            [("base".to_string(), Value::Object([(key.to_string(), Value::from(7.0))].into_iter().collect())),
             ("rules".to_string(), Value::Array(vec![Value::Array(vec![j(r#"[["dj","in"]]"#).clone(), Value::Object([(key.to_string(), Value::from(3.0))].into_iter().collect())])]))]
                .into_iter()
                .collect(),
        )));
        let out = |n: Option<&Now>| strat_out(sets(), n, key, Some(F(1.0))).unwrap().f();
        assert!(approx(out(Some(&now(arm, &[("dj", F(3.0))]))), 7.0));
        assert!(approx(out(Some(&now(arm, &[("dj", F(0.5))]))), 3.0));
        assert_eq!(out(Some(&now(st(r#"{"base":{"range":0.7,"ns":0.3}}"#), &[("dj", F(0.5))]))), 1.0);
        assert_eq!(out(None), 1.0);
    }
    // (the exchange keys: no key, the value itself; a key scales it, a chance kept within 0-1, a wait rounded half up and >= 0)
    let n = now(st(r#"{"base":{"range":0.7}}"#), &[("dj", F(1.0))]);
    let p = 0.55;
    assert_eq!((strat_scale(sets(), Some(&n), "clash-p", p), strat_scale(sets(), None, "clash-p", p)), (p, p));
    assert_eq!((strat_mul_int(sets(), Some(&n), "xch-sa-wait", 4), strat_mul_int(sets(), None, "xch-sa-wait", 4)), (4, 4));
    assert_eq!(strat_mul(sets(), Some(&n), "clash-margin", k().cai_clash_margin), k().cai_clash_margin);
    let arm = |key: &str, v: f32| now(Strat(leak(Value::Object([("base".to_string(), Value::Object([(key.to_string(), Value::from(v as f64))].into_iter().collect()))].into_iter().collect()))), &[("dj", F(1.0))]);
    assert!(approx(strat_scale(sets(), Some(&arm("clash-p", 2.0)), "clash-p", 0.6), 1.0));
    assert!(approx(strat_scale(sets(), Some(&arm("clash-p", -1.0)), "clash-p", 0.6), 0.0));
    assert!(approx(strat_scale(sets(), Some(&arm("awaken-kikon-p", 0.5)), "awaken-kikon-p", 0.6), 0.3));
    assert_eq!(strat_mul_int(sets(), Some(&arm("xch-sa-wait", 1.5)), "xch-sa-wait", 4), 6); // (frames: a fixnum)
    assert_eq!(strat_mul_int(sets(), Some(&arm("xch-sa-wait", 1.125)), "xch-sa-wait", 4), 5); // (4.5: half up)
    assert_eq!(strat_mul_int(sets(), Some(&arm("xch-sa-wait", -2.0)), "xch-sa-wait", 4), 0); // (kept >= 0)
    assert!(approx(strat_mul(sets(), Some(&arm("clash-margin", 1.5)), "clash-margin", 1.0), 1.5));
    assert!(approx(strat_mul(sets(), Some(&arm("clash-margin", -1.0)), "clash-margin", 1.0), 0.0));
    for kk in [0.0, 0.5, 1.0, 1.5, 3.0] {
        for pl in [&k().cai_xch_sa_p, &k().cai_clash_p, &k().cai_awaken_break_p, &k().cai_awaken_kikon_p] {
            let s = |d| strat_scale(sets(), Some(&arm("clash-p", kk)), "clash-p", pl.chance(d));
            assert!(s(Easy) <= s(Normal) && s(Normal) <= s(Hard)); // (EASY <= NORMAL <= HARD under any one scale)
        }
    }
}

// ---------------------------------------------------------------- the library's load and the lookup

#[test]
fn library_loads_and_lookup_rows() {
    let t = &data().tables;
    let rows = t["strat_lookup"].as_array().unwrap();
    assert_eq!(rows.len(), 9);
    let m2 = ["KEN-KI-STYLE", "KEN-KH-STYLE", "KEN-KH-STANDOFF-STYLE", "ICHIGO-KI-STYLE", "ICHIGO-KI-R2B2A1-STYLE"];
    for r in rows {
        let s = strat_by_id(data(), r[3].as_str().unwrap()).expect("a lookup row's table");
        let ki = ["kenpachi", "ichigo"].contains(&r[0].as_str().unwrap()) && ["kenpachi", "ichigo"].contains(&r[1].as_str().unwrap());
        for a in arms(s.fq().unwrap()) {
            match arm_fn(a) {
                Some(f) if ki => assert!(m2.contains(&f), "{f}"), // (the four K / I rows: M2's styles)
                Some(f) => assert!(f.starts_with("HISAGI-") || m2.contains(&f), "{f}"),
                None => assert!(!ki), // (a NIL arm or the generic CPU: only Hisagi's mirror)
            }
        }
    }
    // (the four K / I rows resolve at every difficulty, to the T0 tables)
    for (me, vs, id) in [(Kenpachi, Kenpachi, "t0-kk-kenpachi"), (Kenpachi, Ichigo, "t0-ki-kenpachi"), (Ichigo, Kenpachi, "t0-ki-ichigo"), (Ichigo, Ichigo, "t0-ii-ichigo")] {
        for d in [Easy, Normal, Hard] {
            assert_eq!(strat_lookup(data(), k(), me, vs, d).and_then(|s| s.id()), Some(id));
        }
    }
    // (every :fn the library names, in an arm, a composite's sub, its :else or an event arm, is a known style)
    fn fns(v: &Value, out: &mut Vec<String>) {
        match v {
            Value::Object(o) => o.iter().for_each(|(k, x)| if k == "fn" { out.push(x.as_str().unwrap().into()) } else { fns(x, out) }),
            Value::Array(a) => {
                a.iter().for_each(|x| fns(x, out));
                a.chunks(2).filter(|c| c[0] == "fn").for_each(|c| out.push(c[1].as_str().unwrap().into()));
            }
            _ => {}
        }
    }
    let mut all = vec![];
    fns(&t["strat_library"], &mut all);
    assert!(!all.is_empty() && all.iter().all(|f| StyleId::of(f).is_some()), "{all:?}");
    // (*cai-styles*: the KI matchup's styles, typed once)
    let cs = &k().cai_styles;
    assert_eq!(cs.get(Kenpachi, Ichigo).map(StyleId::name), Some("KEN-KI-STYLE"));
    assert_eq!(cs.get(Ichigo, Kenpachi).map(StyleId::name), Some("ICHIGO-KI-STYLE"));
    assert_eq!(cs.get(Kenpachi, Kenpachi), None);
}

// ---------------------------------------------------------------- the native judgement dump

/// Every judgement of tests/fixtures/strat-judgements.txt (strat-judge-dump.lisp over the frozen native image): the table's Q per arm
/// for the dumped cues equals the dump's bit for bit, and so does the pick.
#[test]
fn judgements_match_the_native_dump() {
    let text = include_str!("fixtures/strat-judgements.txt");
    let num = |s: &str| if s.contains(['.', 'e']) { F(s.parse().unwrap()) } else { I(s.parse().unwrap()) };
    let mut n = 0;
    for line in text.lines() {
        let (head, q) = line.split_once(" | ").unwrap();
        let w: Vec<&str> = head.split(' ').collect();
        let (id, pick) = (w[4], w[5].parse::<usize>().unwrap());
        let feats: Vec<(&str, Num)> = w[6..].iter().map(|c| c.split_once('=').map(|(k, v)| (k, num(v))).unwrap()).collect();
        let table = fq(id);
        let got = strat_fq_q(sets(), table, &feats);
        let want: Vec<u32> = q.split(' ').map(|x| x.parse::<f32>().unwrap().to_bits()).collect();
        assert_eq!(got.as_slice().iter().map(|x| x.to_bits()).collect::<Vec<_>>(), want, "{line}");
        assert_eq!(strat_fq_pick(sets(), table, &feats), pick, "{line}");
        n += 1;
    }
    assert_eq!(n, 155);
}

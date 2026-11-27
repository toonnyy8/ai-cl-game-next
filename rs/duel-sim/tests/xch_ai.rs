//! tests/duel-rules/xch-ai.lisp's checks (the core CPU's exchange after a cancel and its clash), with the same values; the unit
//! checks read `*strat-data*` as tables.json holds it (STRAT-UNIT-FIND is Task 5's).
use duel_data::{Data, MoveClass::*};
use duel_sim::components::{Contact, Difficulty, Difficulty::*};
use duel_sim::cpu::xch_ai::*;
use duel_sim::kit::find_move;
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
fn approx(a: f32, b: f32) -> bool {
    (a - b).abs() < 1e-3
}
const DIFS: [Difficulty; 3] = [Easy, Normal, Hard];
fn rising(v: [f32; 3]) -> bool {
    v[0] <= v[1] && v[1] <= v[2]
}

#[test]
fn which_side_of_a_cancel() {
    let hit = Some(Contact::Hit);
    assert_eq!(xch_side(Some(Na), hit, 40, 30), Some(XchSide::J)); // (his J link took part: AS / next J open)
    assert_eq!(xch_side(Some(Sa), hit, 40, 30), Some(XchSide::J)); // (an SA that took part)
    assert_eq!(xch_side(Some(Ns), hit, 40, 30), Some(XchSide::Ns)); // (an NS segment: its SA open at once)
    assert_eq!(xch_side(Some(Ns), None, 30, 30), Some(XchSide::Ns)); // (on its first frame)
    assert_eq!(xch_side(Some(Sa), hit, 30, 30), None); // (an SA the cancel fired, stamped with its tick: took no part)
    assert_eq!(xch_side(Some(Na), None, 40, 30), None); // (no contact: not landed)
    assert_eq!(xch_side(Some(As), hit, 40, 30), None); // (an AS: no answer to make)
    assert_eq!(xch_side(Some(Na), hit, -1, 30), None); // (a real hit: no exchange)
    assert_eq!(xch_side(Some(Ns), hit, 20, 30), None); // (an exchange from an earlier move)
}

#[test]
fn j_side_answer_and_its_knobs() {
    let ws = XchW { as_w: 0.6, j: 0.4 };
    assert_eq!(xch_j_answer(0.1, ws, true), Some(JAnswer::As));
    assert_eq!(xch_j_answer(0.7, ws, true), Some(JAnswer::J));
    assert_eq!(xch_j_answer(0.1, ws, false), None); // (out of reach: he holds)
    // every difficulty's plist names :as and no :hoho (DUEL_CORE §2.1.2); the NS side's Hoho knob left with the rule
    let raw = data().tuning["*CAI-XCH-J*"].as_array().unwrap();
    for w in raw.chunks(2).map(|c| c[1].as_array().unwrap()) {
        let keys: Vec<_> = w.chunks(2).map(|c| c[0].as_str().unwrap()).collect();
        assert!(keys.contains(&"as") && !keys.contains(&"hoho"));
    }
    assert!(!data().tuning.contains_key("*CAI-XCH-NS-HOHO-P*"));
    assert!(rising(DIFS.map(|d| k().cai_xch_j.get(d).j))); // (the mix grows with the difficulty)
}

#[test]
fn ns_side_sees_his_turn() {
    assert!(xch_turn_seen_p(Some(As), 41, 40, false));
    assert!(xch_turn_seen_p(Some(Na), 45, 40, false));
    assert!(!xch_turn_seen_p(Some(Na), 35, 40, false)); // (the J his hit cancelled with: not his turn)
    assert!(xch_turn_seen_p(Some(Na), 35, 40, true)); // (her segment's hit cancelled his J in its startup)
    assert!(xch_turn_seen_p(Some(Sa), 35, 40, true));
    assert!(!xch_turn_seen_p(Some(Ns), 45, 40, true));
    assert!(!xch_turn_seen_p(None, 45, 40, true));
}

#[test]
fn clash_opener_and_window() {
    assert_eq!(clash_opener(Some(Ns)), Some(Na));
    assert_eq!(clash_opener(Some(Na)), Some(Ns));
    assert_eq!(clash_opener(Some(As)), Some(Na));
    assert_eq!(clash_opener(Some(Sa)), Some(Ns));
    assert_eq!(clash_opener(None), None);
    assert_eq!(clash_window(1, 14, 2.0, None, None), Some((14, Some(2.0))));
    assert_eq!(clash_window(0, 18, 0.0, Some(16), Some(2.6)), Some((17, Some(2.6))));
    assert_eq!(clash_window(0, 18, 0.0, None, None), None);
}

#[test]
fn knobs_keep_their_order() {
    let k = k();
    assert!(rising(DIFS.map(|d| k.cai_xch_sa_p.chance(d))));
    assert!(DIFS.iter().all(|&d| k.cai_xch_early_p.chance(d) == 1.0));
    assert!(DIFS.iter().all(|&d| k.cai_xch_early_his_p.chance(d) == 0.0));
    assert_eq!(k.cai_xch_carry_watch_p.0, k.cai_xch_carry_p.0);
    // each mix key of the four units within 0-1 where it is the chance itself
    let units = data().tables["strat_data"].as_array().unwrap();
    for id in ["d-x-ki-k", "d-x-ki-i", "d-x-kh-k", "d-x-kh-h"] {
        let u = units.iter().find(|u| u["id"] == id).unwrap_or_else(|| panic!("no unit {id}"));
        for key in ["xch-early-his-p", "xch-carry-watch-p"] {
            let v = u["base"][key].as_f64().unwrap();
            assert!((0.0..=1.0).contains(&v), "{id} {key}");
        }
    }
    assert!(rising(DIFS.map(|d| k.cai_clash_p.chance(d))));
    assert!((4..=8).contains(&k.cai_xch_sa_wait)); // (the measured winning window)
    assert!(rising(DIFS.map(|d| k.cai_awaken_break_p.chance(d))));
    assert!(rising(DIFS.map(|d| k.cai_awaken_kikon_p.chance(d))));
    // the clash's reaction: never slower at a harder difficulty; NORMAL's in time for n3b's cut
    let dl = DIFS.map(|d| k.cai_clash_delay.chance(d));
    assert!(dl[0] >= dl[1] && dl[1] >= dl[2]);
    let n3b = find_move(data(), "ic-k-n3b").unwrap();
    assert!(dl[1] < n3b.params.hit_at.unwrap() as i64);
}

/// KESSA's NS3 summons: :hit-at = the clone's on-frame + its cut's S - 1 (the X's clones start 2 frames early).
#[test]
fn kessa_summons_hit_at() {
    let d = data();
    let mvd = |n: &str| find_move(d, n).unwrap_or_else(|| panic!("no move {n}"));
    let at = |n: &str| mvd(n).params.hit_at.unwrap() as i32;
    let on = |n: &str| mvd(n).on_frame[0][0].as_f32().unwrap() as i32;
    assert_eq!(at("ic-k-n3a"), on("ic-k-n3a") + mvd("ic-c-light").s - 1);
    assert_eq!(at("ic-k-n3b"), on("ic-k-n3b") + mvd("ic-c-light").s - 1);
    assert_eq!(at("ic-k-n3c"), on("ic-k-n3c") + 2 + mvd("ic-c-xa").s - 1);
    assert!(["ic-k-n3a", "ic-k-n3b", "ic-k-n3c"].iter().all(|n| at(n) < mvd(n).s)); // (inside the summon's startup)
}

#[test]
fn ns_side_sa_timing() {
    assert!(xch_sa_now_p(Some(As), 41, 40, false, 42, 4));
    assert!(xch_sa_now_p(Some(Na), 45, 40, false, 46, 4));
    assert!(!xch_sa_now_p(Some(Na), 35, 40, true, 42, 4)); // (2 frames after the cancel: his AS would start later and win)
    assert!(xch_sa_now_p(Some(Na), 35, 40, true, 44, 4));
    assert!(!xch_sa_now_p(Some(Na), 35, 40, false, 50, 4)); // (not seen: no own hit, not his turn)
}

/// The arm key :XCH-J: the J's share x k within 0-1, the AS the rest; no key: the plist itself.
#[test]
fn xch_j_weights_scale_the_share() {
    let ws = k().cai_xch_j.get(Hard);
    assert_eq!(xch_j_weights(ws, None), ws);
    let w1 = xch_j_weights(ws, Some(1.0));
    assert!(approx(0.4, w1.j) && approx(0.6, w1.as_w));
    let w2 = xch_j_weights(ws, Some(2.0));
    assert!(approx(0.8, w2.j) && approx(0.2, w2.as_w));
    let w5 = xch_j_weights(ws, Some(5.0));
    assert!(approx(1.0, w5.j) && approx(0.0, w5.as_w)); // (clamped: all J)
    assert_eq!(xch_j_answer(0.99, xch_j_weights(ws, Some(0.0)), true), Some(JAnswer::As)); // (k 0: always the AS)
    assert_eq!(xch_j_answer(0.01, xch_j_weights(ws, Some(3.0)), true), Some(JAnswer::J));
    let none = XchW { as_w: 0.0, j: 0.0 };
    assert_eq!(xch_j_weights(none, Some(2.0)), none); // (no weight: unchanged)
    for kk in [0.0, 0.5, 1.0, 1.5, 3.0] {
        assert!(rising(DIFS.map(|d| xch_j_weights(k().cai_xch_j.get(d), Some(kk)).j)));
    }
    // (the native image's bits: (xch-j-weights (getf *cai-xch-j* :normal) 1.3))
    assert_eq!(xch_j_weights(k().cai_xch_j.get(Normal), Some(1.3)), XchW { as_w: 0.61, j: 0.39000002 });
}

/// WEIGHTED-PICK at its edges, against the native image: a remainder of exactly 0 goes on to the next key; a zero weight never wins.
#[test]
fn weighted_pick_edges() {
    assert_eq!(weighted_pick(0.6, &[('a', 0.6), ('j', 0.4)]), Some('j'));
    assert_eq!(weighted_pick(0.99999994, &[('a', 0.7), ('j', 0.3)]), Some('j'));
    assert_eq!(weighted_pick(0.0, &[('a', 0.0), ('j', 0.3)]), Some('j'));
    assert_eq!(weighted_pick(0.5, &[('a', 0.0), ('j', 0.0)]), None);
}

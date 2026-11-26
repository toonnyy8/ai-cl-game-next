//! Port of tests/duel-rules/core.lisp's checks over rules.lisp (one assert per Lisp `(check …)`, same expected values).
use duel_data::Data;
use duel_sim::components::{Burst, Contact, State};
use duel_sim::knobs::Knobs;
use duel_sim::rules::*;

fn k() -> Knobs {
    Knobs::from(&Data::embedded()).unwrap()
}
fn ap(a: f32, b: f32) -> bool {
    (a - b).abs() < 1e-3
}
const H: Option<Contact> = Some(Contact::Hit);
const B: Option<Contact> = Some(Contact::Block);

#[test]
fn frames() {
    let k = &k();
    assert!(!chain_open_p(k, 12, 9, 3, 12, contact_of(Some(Res::Armored))));
    assert_eq!(blockstun(24, 9, -2), 13);
    assert_eq!(hitstun(k, "flinch", false), 18);
    assert_eq!(hitstun(k, "stagger", true), 36);
    assert_eq!(recovery_frames(k, 12, H, None, None), 12);
    assert_eq!(recovery_frames(k, 12, None, None, None), 18);
    assert_eq!(recovery_frames(k, 18, None, Some(30), None), 30);
    assert!(chain_open_p(k, 12, 9, 3, 12, H) && !chain_open_p(k, 11, 9, 3, 12, H));
    assert!((0..=30).all(|sf| !chain_open_p(k, sf, 9, 3, 12, None)));
    assert!(chain_open_p(k, 21, 9, 3, 12, B) && !chain_open_p(k, 20, 9, 3, 12, B) && !chain_open_p(k, 24, 9, 3, 12, B));
    // (line 103: a contact of T, which is neither :hit nor :block: the block timing)
    assert!(chain_open_p(k, 21, 9, 3, 12, B) && !chain_open_p(k, 20, 9, 3, 12, B) && !chain_open_p(k, 24, 9, 3, 12, B));
}

#[test]
fn damage() {
    let k = &k();
    let cs = |n, o| combo_scale(k, n, o);
    assert!(
        ap(cs(1, false), 1.0) && ap(cs(3, false), 1.0) && ap(cs(4, false), 0.85) && ap(cs(6, false), 0.55) && ap(cs(7, false), 0.4)
            && ap(cs(8, false), 0.25) && ap(cs(9, false), 0.2) && ap(cs(12, false), 0.2)
    );
    let d = DefMods::default();
    let a = AtkMods::default();
    assert!(
        ap(cs(3, true), 1.0) && ap(cs(4, true), 0.9) && ap(cs(7, true), 0.6) && ap(cs(8, true), 0.5) && ap(cs(20, true), 0.5)
            && hit_damage(k, 100, a, d, 20, false, true) == 50
    );
    assert_eq!(hit_damage(k, 100, a, d, 1, false, false), 100);
    assert_eq!(hit_damage(k, 100, AtkMods { mult: 1.3, ..a }, d, 1, false, false), 130);
    assert_eq!(hit_damage(k, 100, AtkMods { cornered: 0.05, cornered_max: 0.25, lost: 2, ..a }, d, 1, false, false), 110);
    assert_eq!(hit_damage(k, 100, AtkMods { cornered: 0.05, cornered_max: 0.25, lost: 6, ..a }, d, 1, false, false), 125);
    assert_eq!(hit_damage(k, 100, AtkMods { mult: 1.15, cornered: 0.05, cornered_max: 0.25, lost: 3 }, d, 5, true, false), 116);
    assert_eq!(hit_damage(k, 100, a, d, 20, false, false), 20);
    assert_eq!(hit_damage(k, 1, a, d, 12, false, false), 1);
    assert_eq!(hit_damage(k, 0, AtkMods { mult: 2.0, ..a }, d, 1, true, false), 0);
    assert!(chip_damage(110, Some(0.12), 5) == 4 && chip_damage(110, Some(0.12), 1) == 0);
    assert_eq!(chip_damage(110, None, 500), 0);
    assert_eq!((0..60).map(|s| burn_amount(1000, 0.02, s)).sum::<i64>(), 20);
    assert_eq!(cornered_mult(0.05, 10, 0.25), 1.25);
    assert!(red_p(k, 299, 1000) && !red_p(k, 300, 1000));
}

#[test]
fn kikon_and_time_up() {
    let k = &k();
    for (kp, c, sb, want) in [
        (6, 2, false, (4, 2, false)),
        (6, 3, false, (3, 3, false)),
        (6, 2, true, (3, 3, false)),
        (6, 4, true, (1, 5, false)),
        (6, 3, true, (2, 4, false)),
        (2, 2, false, (0, 2, true)),
        (1, 3, true, (0, 1, true)),
    ] {
        assert_eq!(kikon_result(k, kp, c, sb), want);
    }
    assert_eq!(time_up_winner(3, 100, 1000, 2, 900, 1000), Some(0));
    assert_eq!(time_up_winner(2, 900, 1000, 3, 100, 1000), Some(1));
    assert_eq!(time_up_winner(2, 600, 1000, 2, 500, 1000), Some(0));
    assert_eq!(time_up_winner(2, 500, 1000, 2, 525, 1050), None);
    assert_eq!(match_elapsed(18000, 18000), 0.0);
    assert_eq!(match_elapsed(0, 18000), 1.0);
    assert_eq!(match_elapsed(-5, 18000), 1.0);
}

#[test]
fn systems_lisp() {
    // tests/duel-rules/systems.lisp line 16
    assert!(
        burst_mode(&k(), State::GuardHit, false, 0, false) == Some(Burst::Blue)
            && !guard_locked_p(State::Idle, true, 5, State::Move, Some(duel_sim::components::Phase::Main), 20, 10, 3, 12, true, true)
    );
}

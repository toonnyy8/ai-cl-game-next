//! Port of tests/duel-rules/triangle.lisp's checks over core.lisp (one assert per Lisp `(check …)` line, same expected values).
use duel_data::Data;
use duel_data::kits::MoveClass::{self, As, Na, Ns, Sa};
use duel_sim::core::Verdict::{self, Absorb, Cancel, Hit};
use duel_sim::core::*;
use duel_sim::knobs::Knobs;

fn k() -> Knobs {
    Knobs::from(&Data::embedded()).unwrap()
}
fn v(a: MoveClass, d: MoveClass) -> Verdict {
    core_verdict(Some(a), Some(d), false, None, None)
}
fn vt(a: MoveClass, d: MoveClass, at: i64, dt: i64) -> Verdict {
    core_verdict(Some(a), Some(d), false, Some(at), Some(dt))
}

#[test]
fn triangle_verdicts() {
    for (a, d, w) in [
        (Na, Na, Hit), (Na, Ns, Cancel), (Na, As, Cancel), (Na, Sa, Absorb),
        (Ns, Na, Cancel), (Ns, Ns, Hit), (Ns, As, Absorb), (Ns, Sa, Cancel),
        (As, Na, Cancel), (As, Ns, Hit),
        (Sa, Na, Hit), (Sa, Ns, Cancel),
    ] {
        assert_eq!(v(a, d), w);
    }
    assert_eq!(core_verdict(Some(Na), None, false, None, None), Hit);
    assert_eq!(core_verdict(Some(Na), Some(Na), true, None, None), Cancel);
    assert_eq!(core_verdict(Some(Ns), Some(Ns), true, None, None), Cancel);
    assert_eq!(core_verdict(Some(Na), Some(Ns), true, None, None), Cancel);
    assert_eq!(vt(As, Sa, 20, 10), Hit);
    assert_eq!(vt(As, Sa, 10, 20), Absorb);
    assert_eq!(vt(Sa, As, 10, 10), Cancel);
    assert_eq!(vt(Sa, As, 30, 10), Hit);
    assert!(v(Na, Ns) == Cancel && v(Ns, Na) == Cancel);
    assert!(v(As, Ns) == Hit && v(Ns, As) == Absorb);
    assert!(v(Sa, Na) == Hit && v(Na, Sa) == Absorb);
    assert!(vt(As, Sa, 5, 4) == Hit && vt(Sa, As, 4, 5) == Absorb);
    assert!(v(As, Na) == Cancel && v(As, Ns) == Hit && v(Sa, Na) == Hit && v(Sa, Ns) == Cancel);
    // (not a triangle.lisp check: the turn-move armour, core.lisp CORE-TURN-ARMOR-VERDICT)
    assert_eq!(core_turn_armor_verdict(Cancel, Some(Na), true), Absorb);
    assert_eq!(core_turn_armor_verdict(Hit, Some(As), true), Hit);
}

#[test]
fn triangle_cancels_and_exchanges() {
    let k = &k();
    assert_eq!(core_cancel_land_sf(-1, 14, 14), 14);
    assert_eq!(core_cancel_land_sf(-1, 6, 14), 14);
    assert_eq!(core_cancel_land_sf(-1, 16, 14), 16);
    assert_eq!(core_cancel_land_sf(9, 20, 14), 9);
    assert_eq!(core_cancel_land_sf(-1, 0, 22), 22);
    assert!(core_cancelled_p(40, 30));
    assert!(core_cancelled_p(30, 30));
    assert!(!core_cancelled_p(-1, 30));
    assert!(core_seg_dead_p(Some("j1"), 30, Some("j1"), 30));
    assert!(!core_seg_dead_p(Some("j1"), 45, Some("j1"), 30));
    assert!(!core_seg_dead_p(Some("j2"), 30, Some("j1"), 30));
    assert!(!core_seg_dead_p(Some("j1"), 30, None, -1));
    assert!(!k.core_cancel_dead);
    assert!(core_as_sa_out_p(true, Some(As), true));
    assert!(!core_as_sa_out_p(false, Some(As), true));
    assert!(!core_as_sa_out_p(true, Some(As), false));
    assert!(!core_as_sa_out_p(true, Some(Ns), true));
    assert!(!core_as_sa_out_p(true, Some(Na), true));
    assert!(!k.core_as_sa_out);
    assert!(!core_cancelled_p(20, 30));
    assert!(core_sa_open_p(3, 14, 4, true));
    assert!(!core_sa_open_p(3, 14, 4, false));
    assert!(!core_sa_open_p(17, 14, 4, false) && core_sa_open_p(18, 14, 4, false));
    assert!(core_hoho_open_p(-1, false));
    assert!(!core_hoho_open_p(40, false));
    assert!(!core_hoho_open_p(0, false));
    assert!(core_hoho_open_p(40, true));
    assert_eq!(k.core_xch_as_delay, 6);
    assert!(core_xch_as_p(Some(As), Some(Na), 40, 30, false));
    assert!(core_xch_as_p(Some(As), Some(Na), 30, 30, false));
    assert!(!core_xch_as_p(Some(As), Some(Na), 40, 30, true));
    assert!(!core_xch_as_p(Some(As), Some(Na), -1, 30, false));
    assert!(!core_xch_as_p(Some(As), Some(Na), 20, 30, false));
    assert!(!core_xch_as_p(Some(Na), Some(Na), 40, 30, false));
    assert!(!core_xch_as_p(Some(As), Some(As), 40, 30, false));
    assert!(core_xch_as_p(Some(As), Some(Sa), 40, 30, false));
    assert!(!core_xch_as_p(Some(As), Some(Sa), 30, 30, false));
}

#[test]
fn triangle_pointer_profiles() {
    let k = &k();
    let m = |f: &dyn Fn(i64) -> i64, xs: &[i64]| xs.iter().map(|&x| f(x)).collect::<Vec<_>>();
    assert_eq!(m(&|p| core_as_pointer(k, p, &[]), &[0, 1, 2, 3, 4, 5]), [1, 1, 2, 3, 4, 4]);
    assert_eq!(m(&|b| core_kikon_count(k, b, 1, false), &[2, 3, 4]), [1, 2, 3]);
    assert_eq!(m(&|b| core_kikon_count(k, b, 1, true), &[2, 3, 4]), [1, 2, 3]);
    assert_eq!(m(&|b| core_kikon_count(k, b, 2, false), &[2, 3, 4]), [2, 3, 4]);
    assert_eq!(m(&|b| core_kikon_count(k, b, 2, true), &[2, 3, 4]), [3, 4, 5]);
    assert_eq!(m(&|b| core_kikon_count(k, b, 3, false), &[1, 2, 3, 4]), [1, 1, 2, 3]);
    assert_eq!(m(&|b| core_soul_break_count(k, b, 1), &[2, 3, 4]), [3, 4, 5]);
    assert_eq!(m(&|b| core_soul_break_count(k, b, 2), &[2, 3, 4]), [3, 4, 5]);
    assert_eq!(m(&|b| core_soul_break_count(k, b, 3), &[2, 3, 4]), [5, 5, 5]);
    assert_eq!(core_kikon_count(k, 2, 2, true), core_soul_break_count(k, 2, 2));
    assert_eq!([core_kikon_ptr(Some(Ns), 2, 3), core_kikon_ptr(Some(As), 1, 3), core_kikon_ptr(Some(Na), 1, 3), core_kikon_ptr(None, 1, 2)], [2, 1, 3, 2]);
    assert_eq!(m(&|p| core_kikon_stake(k, 9, 2, None, 1, p, false, None), &[1, 2, 3]), [1, 2, 1]);
    assert_eq!(m(&|p| core_kikon_stake(k, 9, 2, None, 1, p, true, None), &[1, 2, 3]), [1, 3, 1]);
    assert_eq!(core_kikon_stake(k, 9, 2, Some(Ns), 2, 3, false, None), 2);
    assert_eq!([core_kikon_stake(k, 9, 4, None, 1, 2, true, None), core_kikon_stake(k, 2, 4, None, 1, 2, true, None)], [5, 2]);
    assert_eq!(core_kikon_stake(k, 9, 2, None, 1, 1, false, Some(3)), 3);
    // (core.lisp's by-press list, Ichigo's (1 1 2 2 3): not a triangle.lisp check)
    assert_eq!(m(&|p| core_as_pointer(k, p, &[1, 1, 2, 2, 3]), &[1, 2, 3, 4, 5, 6]), [1, 1, 2, 2, 3, 3]);
}

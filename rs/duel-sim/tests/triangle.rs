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
fn triangle_first_land() {
    use duel_sim::components::Contact;
    use duel_sim::rules::first_land_p;
    assert!(first_land_p(None, 0));
    assert!(first_land_p(Some(Contact::Block), 1));
    assert!(first_land_p(Some(Contact::Hit), 0));
    assert!(!first_land_p(Some(Contact::Hit), 1));
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

#[test]
fn steal() {
    let k = &duel_sim::knobs::Knobs::from(&duel_data::Data::embedded()).unwrap();
    use duel_sim::rules::steal_take as st;
    // triangle.lisp lines 268, 270-278
    assert_eq!(k.steal_fs_gain, 0.5);
    assert_eq!(st(k, 30.0, 300.0), (30.0, 15.0));
    assert_eq!(st(k, 80.0, 300.0), (80.0, 40.0));
    assert_eq!(st(k, 120.0, 25.0), (25.0, 12.5));
    assert_eq!(st(k, 30.0, 0.0), (0.0, 0.0));
    assert_eq!(st(k, 3.0, 300.0), (3.0, 1.5));
    assert_eq!([5.0, 10.0, 15.0, 20.0].iter().map(|&w| st(k, w, 300.0).0).sum::<f32>(), 50.0);
    assert!(st(k, 120.0, 100.0) == (100.0, 50.0) && st(k, 500.0, 300.0) == (300.0, 150.0));
    let (mut v, mut tot) = (300.0, 0.0);
    for w in [120.0, 120.0, 120.0] {
        let tk = st(k, w, v).0;
        v -= tk;
        tot += tk;
    }
    assert!(v == 0.0 && tot == 300.0);
}

#[test]
fn ichigo_core_moves() {
    use duel_sim::kit::*;
    let d = duel_data::Data::embedded();
    let k = &d.kits.kits["ichigo"]["base"];
    let m = |n: &str| kit_move(&d, k, n).unwrap();
    let id = |x: Option<&duel_data::Move>| x.map(|m| m.id.clone());
    // lines 107-109
    assert!(["ic-j1", "ic-n1a", "ic-n2a", "ic-n3a"].iter().all(|n| m(n).s >= 14));
    assert!(m("ic-n1a").s > m("ic-n1b").s);
    assert!(m("ic-n2a").hits.is_empty() && m("ic-n2b").hits.is_empty() && m("ic-n2c").params.range.unwrap() >= 10.0);
    // line 113
    assert!(
        id(mv_sa_move(&d, k, m("ic-n2a"))) == id(Some(m("ic-sa-g1"))) && id(mv_sa_move(&d, k, m("ic-n2b"))) == id(Some(m("ic-sa-g2")))
            && mv_sa_move(&d, k, m("ic-n1a")).is_none()
            && ["ic-sa", "ic-sa-g1", "ic-sa-g2"].iter().all(|n| kit_class(k, Some(m(n))) == Some(duel_data::MoveClass::Sa))
            && m("ic-sa").dmg < m("ic-sa-g1").dmg && m("ic-sa-g1").dmg < m("ic-sa-g2").dmg
            && ["ic-sa", "ic-sa-g1", "ic-sa-g2"].iter().all(|n| kit_next(&d, k, n, "q").is_some())
    );
    // line 118
    assert_eq!(k.core.stances, ["ic-st-heavy", "ic-tsuki", "ic-st-rush"]);
    // lines 148-152 (KESSA)
    let kk = &d.kits.kits["ichigo"]["kessa"];
    let mk = |n: &str| kit_move(&d, kk, n).unwrap();
    assert_eq!(id(kit_core_move(&d, kk, Role::Ns, 3)), id(Some(mk("ic-k-n3a"))));
    assert!(["ic-k-n3a", "ic-k-n3b", "ic-k-n3c"].iter().all(|n| mk(n).hits.is_empty() && id(mv_sa_move(&d, kk, mk(n))) == id(Some(mk("ic-k-sa")))));
    assert_eq!(kk.core.stances, ["ic-k-st-chain", "ic-tsuki", "ic-k-stance"]);
    assert_eq!(id(kit_core_move(&d, k, Role::Ns, 3)), id(Some(m("ic-n3a"))));
    // line 169
    assert!(kk.core.kikon_cines.iter().map(|c| c.to_ascii_lowercase()).eq(["ic-chain-kikon-cine", "ic-kessa-getsuga-cine", "ic-kessa-kikon-cine"]));
}

#[test]
fn ichigo_steal_values() {
    // triangle.lisp lines 282-283: per-hit steal values as written
    let d = duel_data::Data::embedded();
    let vals = |f: &str, n: &str| {
        let k = &d.kits.kits["ichigo"][f];
        let mv = duel_sim::kit::kit_move(&d, k, n).unwrap();
        mv.hits.iter().map(|w| w.steal.or(mv.params.steal_fs)).collect::<Vec<_>>()
    };
    assert_eq!(vals("base", "ic-as1"), [Some(40)]);
    assert_eq!(vals("kessa", "ic-k-as1"), [Some(15); 4]);
}

#[test]
fn first_window_first() {
    // triangle.lisp line 36: in every kit's moves, no hit window starts before the first one
    let d = duel_data::Data::embedded();
    for forms in d.kits.kits.values() {
        for k in forms.values() {
            for id in &k.moves {
                let w = &d.moves.iter().find(|m| &m.id == id).unwrap().hits;
                assert!(w.iter().skip(1).all(|x| x.from >= w[0].from), "{id}");
            }
        }
    }
}

#[test]
fn five_j_pointer() {
    // triangle.lisp line 171: J1-2 -> AS1, J3-4 -> AS2, J5 -> AS3
    let k = &k();
    assert_eq!((0..=6).map(|n| core_as_pointer(k, n, &[1, 1, 2, 2, 3])).collect::<Vec<_>>(), [1, 1, 1, 2, 2, 3, 3]);
}

/// triangle.lisp 137, 138, 140, 142, 144: a charged SA's x on its string (J2 / J3 / the AS), not on itself, a hazard, or a new opener.
#[test]
fn charged_sa_string() {
    use duel_sim::components::{Character, MoveId};
    use duel_sim::core_sim::{core_charge_mult, core_note_start};
    let d: &'static Data = Box::leak(Box::new(Data::embedded()));
    let mut m = duel_sim::state::Match::new(d);
    m.picks = [Character::Ichigo, Character::Kenpachi];
    duel_sim::flow::spawn_pair(&mut m, true, true);
    let a = m.p1;
    let id = |n: &str| MoveId(d.moves.iter().position(|x| x.id == format!("ichigo/base/{n}")).unwrap() as u16);
    let (sa, j2, as1, j1, n2b) = (id("ic-sa-g2"), id("ic-j2"), id("ic-as1"), id("ic-j1"), id("ic-n2b"));
    let mvd = |x: MoveId| Some(&d.moves[x.0 as usize]);
    core_note_start(&mut m, a, sa, Some(n2b));
    let f = || m.fighter.get(a).unwrap().clone();
    assert_eq!(f().charge_mult, 1.7); // 137
    assert_eq!(core_charge_mult(&f(), mvd(sa), true, false), 1.0); // 138
    core_note_start(&mut m, a, j2, Some(sa));
    let f = m.fighter.get(a).unwrap().clone();
    assert!(core_charge_mult(&f, mvd(j2), true, false) == 1.7 && core_charge_mult(&f, mvd(j2), true, true) == 1.0); // 140
    core_note_start(&mut m, a, as1, Some(j2));
    assert_eq!(core_charge_mult(m.fighter.get(a).unwrap(), mvd(as1), true, false), 1.7); // 142
    core_note_start(&mut m, a, j1, None);
    assert_eq!(core_charge_mult(m.fighter.get(a).unwrap(), mvd(j1), true, false), 1.0); // 144
}

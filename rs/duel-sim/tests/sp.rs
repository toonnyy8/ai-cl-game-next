//! Port of tests/duel-rules/sp.lisp's checks over sp.lisp (one assert per Lisp `(check …)`, same expected values).
use duel_data::Data;
use duel_data::MoveClass::{self, As, Na, Ns, Sa};
use duel_sim::components::State;
use duel_sim::knobs::Knobs;
use duel_sim::sp::*;

fn k() -> Knobs {
    Knobs::from(&Data::embedded()).unwrap()
}
fn ap(a: f32, b: f32) -> bool {
    (a - b).abs() < 1e-3
}

#[test]
fn sp_spending() {
    let k = &k();
    assert!(
        ap(k.fs_cell, 100.0) && ap(k.sp_cost_rate, 0.4) && ap(k.sp_cost_min, 10.0) && ap(k.sp_cost_max, 60.0)
            && ap(k.sp_gain_j, 10.0) && ap(k.sp_gain_sa, 15.0) && ap(k.sp_gain_cancel, 30.0) && ap(k.sp_break_share, 1.0)
            && ap(k.sp_break_gain, 0.5) && ap(k.sp_break_flat, 50.0)
    );
    // sp-cost
    for (d, m, o, want) in [
        (100.0, 1.0, None, 40.0),
        (110.0, 1.0, None, 45.0),
        (105.0, 1.0, None, 40.0),
        (0.0, 1.0, None, 10.0),
        (10.0, 1.0, None, 10.0),
        (150.0, 1.0, None, 60.0),
        (300.0, 1.0, None, 60.0),
        (100.0, 0.76, None, 30.0),
        (100.0, 0.51, None, 20.0),
        (100.0, 1.0, Some(25.0), 25.0),
        (500.0, 0.1, Some(5.0), 5.0),
    ] {
        assert!(ap(sp_cost(k, d, m, o), want), "sp-cost {d} {m} {o:?}");
    }
    // sp-start-p
    assert!(sp_start_p(Some(As), false, 0.0, false) && sp_start_p(Some(As), false, 0.0, true) && sp_start_p(Some(As), true, 50.0, false));
    assert!(sp_start_p(Some(Ns), true, 0.0, false));
    assert!(!sp_start_p(Some(Ns), false, 0.0, false));
    assert!(sp_start_p(Some(Ns), false, 0.5, false));
    assert!(sp_start_p(Some(Ns), false, 0.0, true));
    // sp-pay
    for (fs, cost, b, wfs, wp) in [(300.0, 40.0, false, 260.0, 40.0), (30.0, 40.0, false, 0.0, 30.0), (0.0, 40.0, false, 0.0, 0.0), (120.0, 40.0, true, 120.0, 0.0)] {
        let (f, p) = sp_pay(fs, cost, b);
        assert!(ap(f, wfs) && ap(p, wp));
    }
    // sp-scale
    for (p, c, w) in [(40.0, 40.0, 1.0), (0.0, 40.0, 0.5), (30.0, 60.0, 0.75), (0.0, 0.0, 1.0), (99.0, 40.0, 1.0)] {
        assert!(ap(sp_scale(p, c), w));
    }
    // sp-refund
    assert!(ap(sp_refund(k, 100.0, 40.0), 140.0));
    assert!(ap(sp_refund(k, 290.0, 40.0), k.fs_max));
    assert!(ap(sp_refund(k, 300.0, 0.0), 300.0));
    // sp-atk-gain
    assert!(ap(sp_atk_gain(k, Some(Na), false), 10.0) && ap(sp_atk_gain(k, Some(Sa), false), 15.0));
    assert!(ap(sp_atk_gain(k, Some(Na), true), 30.0) && ap(sp_atk_gain(k, Some(Sa), true), 30.0));
    assert!(
        [(Some(Ns), false), (Some(As), false), (Some(Ns), true), (Some(As), true), (None, false)].iter().all(|&(c, x)| sp_atk_gain(k, c, x) == 0.0)
    ); // (:kikon is a non-class: None)
    // sp-break-take
    for (v, wt, wg) in [(300.0, 200.0, 150.0), (140.0, 40.0, 70.0), (100.0, 0.0, 50.0), (40.0, 0.0, 50.0), (0.0, 0.0, 50.0)] {
        let (t, g) = sp_break_take(k, v);
        assert!(ap(t, wt) && ap(g, wg), "break-take {v}");
    }
    // exchanges
    assert!(sp_exchange_open_p(120, 120));
    assert!(!sp_exchange_open_p(120, 121));
    assert!(sp_recancel_p(120, 120, 130));
    assert!(!sp_recancel_p(130, 130, 130));
    assert!(!sp_recancel_p(-1, -1, 130));
    assert!(!sp_recancel_p(120, 121, 130));
    assert!(!k.sp_cancel_gain_once);
    assert!(!k.sp_recancel_no_refund);
    assert!(!sp_exchange_open_p(-1, -1));
    assert!(sp_exchange_open_p(0, 0));
    // sp-neutral-p
    use State::*;
    assert!([Idle, Guard, Step, Run, Hoho].iter().all(|&s| sp_neutral_p(s, false)));
    assert!(![Move, Stun, GuardHit, Air, Down, Wakeup].iter().any(|&s| sp_neutral_p(s, false)));
    assert!(!sp_neutral_p(Idle, true));
    assert!(sp_neutral_p(Step, true));
    // sp-switch-ok-p
    assert!(sp_switch_ok_p(50.0, true, false, 2));
    assert!(!sp_switch_ok_p(0.0, true, false, 2));
    assert!(!sp_switch_ok_p(50.0, false, false, 2));
    assert!(!sp_switch_ok_p(50.0, true, true, 2));
    assert!(!sp_switch_ok_p(50.0, true, false, 1));
}

fn kit<'d>(d: &'d Data, c: &str, f: &str) -> &'d duel_data::Kit {
    &d.kits.kits[c][f]
}

#[test]
fn kit_sp_costs() {
    use duel_sim::kit::*;
    let d = Data::embedded();
    // line 125: every NS / AS segment but a Kikon strike has a single-float cost, everything else none (Kenpachi / Ichigo kits;
    // the Hisagi rows of *sp-table* are M4)
    for c in ["kenpachi", "ichigo"] {
        for k in d.kits.kits[c].values() {
            let by_id = |n: &str| d.moves.iter().find(|m| m.id == n);
            let strikes: Vec<&str> = k.cls.keys().filter_map(|n| by_id(n)?.params.kikon_strike.as_deref()).collect();
            for (n, cls) in &k.cls {
                let mv = by_id(n);
                let want = matches!(cls, MoveClass::Ns | MoveClass::As) && !strikes.contains(&mv_name(mv.unwrap()));
                assert_eq!(kit_sp_cost(k, mv).is_some(), want, "{c} {n}");
            }
        }
    }
    let ic = kit(&d, "ichigo", "base");
    let ke = kit(&d, "kenpachi", "base");
    assert!(kit_sp_cost(ic, kit_move(&d, ic, &ic.core.sa)).is_none());
    let (n1a, n1b) = (kit_move(&d, ic, "ic-n1a").unwrap(), kit_move(&d, ic, "ic-n1b").unwrap());
    let n2a = kit_core_move(&d, ic, Role::Ns, 2).unwrap();
    assert!(kit_sp_start_p(ic, n1a, 0.0, false));
    assert!(kit_sp_start_p(ic, n2a, 0.0, false));
    assert!(!kit_sp_start_p(ic, n1b, 0.0, false));
    assert!(kit_sp_start_p(ic, n1b, 0.5, false));
    assert!(kit_sp_start_p(ic, n1b, 0.0, true));
    let n3b = kit_move(&d, ke, "ke-z-n3b").unwrap();
    assert!(!kit_sp_start_p(ke, n3b, 0.0, false));
    assert!(kit_sp_start_p(ke, n3b, 20.0, false));
    assert!(kit_sp_start_p(ic, kit_core_move(&d, ic, Role::As, 3).unwrap(), 0.0, false));
    assert!(kit_sp_start_p(ic, kit_move(&d, ic, "ic-j1").unwrap(), 0.0, false));
    assert!(kit_sp_start_p(ic, kit_sa_move(&d, ic).unwrap(), 0.0, false));
}

#[test]
fn hooks_load() {
    use duel_sim::kit::*;
    let d = Data::embedded();
    for forms in d.kits.kits.values() {
        for k in forms.values() {
            hooks_of(k).unwrap();
        }
    }
    let kb = kit(&d, "kenpachi", "base");
    assert_eq!(kit_hook(&hooks_of(kb).unwrap(), HookKey::Armor), Some(HookFn::Ken(duel_sim::ken::Hook::Armor)));
    let ib = kit(&d, "ichigo", "base");
    let (key, _) = ib.hooks.iter().next().unwrap();
    assert_eq!(kit_hook(&hooks_of(ib).unwrap(), HookKey::from_name(key).unwrap()), Some(HookFn::Unported)); // (Task 12)
    assert!(resolve("NOT-A-KIT-FN").is_none());
}

#[test]
fn hit_px_sp_scale() {
    let k = &k();
    // lines 81-82 (line 78's row with 0.6d0 is a double: the sim's only caller passes singles)
    assert!(ap(duel_sim::rules::hit_px(k, 1.0, 0.0, 1.0, 0.5), 0.5));
    assert!(ap(duel_sim::rules::hit_px(k, 1.3, 0.0, 1.0, sp_scale(30.0, 60.0)), 1.3 * 0.75));
}

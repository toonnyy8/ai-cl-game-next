//! Task 11: tests/duel-rules/ken.lisp's checks (line numbers in the comments, same values) and core.lisp 745; then checks of
//! Kenpachi's hooks and cinematics on paths the KK traces do not reach (BANKAI! with its restore and cinematic, the timed-form burn,
//! the burst / special / Bankai picks, TATE-GOTO's looks, the stance, the charge, the Bankai Kikon cinematics' moves). Their expected
//! values are read off ken.lisp / gauges.lisp; the paths the traces reach are proved by the four KK traces' bit-exact replay.
use duel_data::{Data, Kit, Move, MoveClass};
use duel_sim::components::{Character, Cls, Contact, Form, Phase, State};
use duel_sim::ecs::Entity;
use duel_sim::kit::*;
use duel_sim::knobs::Knobs;
use duel_sim::rules::{kikon_result, resolve_contact, ContactKeys, DefState, Res};
use duel_sim::state::Match;
use std::sync::OnceLock;

fn data() -> &'static Data {
    static D: OnceLock<Data> = OnceLock::new();
    D.get_or_init(Data::embedded)
}
fn kit(f: &str) -> &'static Kit {
    &data().kits.kits["kenpachi"][f]
}
fn km(k: &Kit, n: &str) -> &'static Move {
    kit_move(data(), k, n).unwrap_or_else(|| panic!("no move {n}"))
}
fn on_hit(x: &Move) -> Option<&str> {
    x.hits.first().map(|w| w.react.as_str())
}
fn chain(k: &Kit, n: &str) -> usize {
    let mut c = 0;
    let mut x = Some(n.to_string());
    while let Some(y) = x {
        c += 1;
        x = km(k, &y).params.ns_next.clone();
    }
    c
}
fn s_of(k: &Kit, ns: &[&str]) -> Vec<i32> {
    ns.iter().map(|n| km(k, n).s).collect()
}
fn dmg_of(k: &Kit, ns: &[&str]) -> Vec<i32> {
    ns.iter().map(|n| km(k, n).dmg).collect()
}
fn cls(k: &Kit, n: &str) -> Option<MoveClass> {
    kit_class(k, Some(km(k, n)))
}

#[test]
fn ken_lisp_kikon_bankai_forms() {
    let (d, kn) = (data(), Knobs::from(data()).unwrap());
    assert!(duel_sim::kit::find_move(d, "ke-buttagiru").unwrap().hits[0].flags.iter().any(|f| f == "ranged")); // 5
    assert!(kit("nozarashi").kikon_konpaku == 2 && kit("base").kikon_konpaku == 2); // 6
    let lost = |c, sb| kikon_result(&kn, 9, c, sb).1;
    assert_eq!([lost(2, false), lost(2, true), lost(3, false), lost(3, true), lost(4, false), lost(4, true), lost(5, false), lost(5, true)], [2, 3, 3, 4, 4, 5, 4, 5]); // 7
    assert!(kn.soul_break_max_event == 5 && kn.kikon_max_event == 4);
    assert!(d.kits.kits["kenpachi"].values().all(|k| kit_kikon_cine(d, k) == "SOUL-BREAK-CINE")); // 12
    for k in [kit("bankai"), kit("bankai-2")] {
        // 17
        assert!(k.cine.as_deref() == Some("KEN-BANKAI-CINE") && k.awakening && k.body == "kenpachi-oni" && k.weapon == "ke-broken");
        assert!(k.aura.as_deref() == Some("oni") && k.hide.iter().any(|h| h == "arm-wreck") && (k.mult - 1.2).abs() < 1e-6);
        assert!(k.meter.max.is_none() && k.meter.lv.is_none() && k.kikon_konpaku == 4);
    }
    assert!(kit("bankai").form_name == "KYORAN" && kit("bankai-2").form_name == "ZANKAI"); // 21
    // 23: rend
    let rc = |st, f: fn(&mut ContactKeys)| {
        let mut c = ContactKeys { in_front: true, rend: true, ..Default::default() };
        f(&mut c);
        resolve_contact(st, c)
    };
    assert_eq!(rc(DefState::Armor, |_| {}), Some(Res::Hit));
    assert_eq!(rc(DefState::Stance, |_| {}), Some(Res::StanceBreak));
    assert_eq!(rc(DefState::StanceIn, |_| {}), Some(Res::StanceBreak));
    assert_eq!(rc(DefState::Guard, |_| {}), Some(Res::Blocked));
    assert_eq!(rc(DefState::Guard, |c| (c.ward, c.in_front) = (true, false)), Some(Res::Blocked));
    assert_eq!(rc(DefState::Parry, |_| {}), Some(Res::Parried));
    assert_eq!(resolve_contact(DefState::Armor, ContactKeys { in_front: true, ..Default::default() }), Some(Res::Armored));
    // 30, 32: over core.lisp's *forms* (Kenpachi's, Ichigo's, Hisagi's)
    for c in ["kenpachi", "ichigo", "hisagi"] {
        for k in d.kits.kits[c].values() {
            assert!(kit_command_move(d, k, "breaker").is_none_or(|br| br.reach + 0.34 > kn.breaker_trigger));
            assert!(kit_command_move(d, k, "kikon").is_none_or(|o| o.reach > kn.kikon_trigger + 0.3));
        }
    }
    assert!(["bankai", "bankai-2"].iter().all(|f| kit(f).hooks.get("tick").map(String::as_str) == Some("KEN-BK-TICK"))); // 36
    assert_eq!(kit("nozarashi").cine.as_deref(), Some("KEN-NOZARASHI-CINE")); // core.lisp 745
}

#[test]
fn ken_lisp_sealed_form() {
    let k = kit("base");
    let is = |ns: &[&str], c| ns.iter().all(|n| cls(k, n) == Some(c));
    assert!(is(&["ke-z-j1", "ke-z-j2", "ke-z-j3", "ke-z-j4", "ke-z-j5"], MoveClass::Na)); // 42
    assert!(is(&["ke-z-n1a", "ke-z-n1b", "ke-z-n1c", "ke-z-n2a", "ke-z-n2b", "ke-z-n3a", "ke-z-n3b", "ke-z-n3c"], MoveClass::Ns)); // 43
    assert!(is(&["ke-z-as1", "ke-z-as2", "ke-z-as2b", "ke-z-as3", "ke-z-as3b", "ke-z-as3c"], MoveClass::As)); // 44
    assert!(is(&["ke-z-sa1", "ke-z-sa2", "ke-z-sa3"], MoveClass::Sa)); // 45
    assert_eq!(s_of(k, &["ke-z-j1", "ke-z-j2", "ke-z-j3", "ke-z-j4", "ke-z-j5"]), [9, 6, 7, 8, 10]); // 49
    assert_eq!(s_of(k, &["ke-z-as1", "ke-z-as2", "ke-z-as2b", "ke-z-as3", "ke-z-as3b", "ke-z-as3c", "ke-z-sa1", "ke-z-sa3"]), [16, 14, 12, 12, 10, 14, 8, 7]); // 50
    assert_eq!(dmg_of(k, &["ke-z-j1", "ke-z-j2", "ke-z-j3", "ke-z-j4", "ke-z-j5"]), [35, 35, 40, 45, 55]); // 54
    assert_eq!(s_of(k, &["ke-z-n1a", "ke-z-n1b", "ke-z-n1c", "ke-z-n2a", "ke-z-n2b", "ke-z-n3a", "ke-z-n3b", "ke-z-n3c"]), [14, 10, 12, 16, 14, 14, 12, 14]); // 55
    assert_eq!(dmg_of(k, &["ke-z-n1a", "ke-z-n1b", "ke-z-n1c", "ke-z-n2a", "ke-z-n2b", "ke-z-n3b", "ke-z-n3c", "ke-z-as1", "ke-z-as2b", "ke-z-as3c"]), [65, 55, 70, 85, 95, 70, 95, 90, 100, 140]); // 57
    assert!(k.open_s.is_none() && k.core.as_by_press.as_deref() == Some(&[1, 1, 2, 2, 3][..])); // 59
    assert!(["ke-z-n1a", "ke-z-n2a", "ke-z-n3a"].iter().all(|n| km(k, n).s >= 14)); // 61
    assert_eq!(k.core.stances, ["ke-z-st-1", "ke-z-st-2", "ke-z-st-3"]); // 62
    assert_eq!(k.core.kikon_cines, ["KEN-Z-KIKON1-CINE", "KEN-Z-KIKON2-CINE", "KEN-Z-KIKON3-CINE"]); // 63
    let sa = |ns: &[&str], s: &str| ns.iter().all(|n| km(k, n).params.sa.as_deref() == Some(s));
    assert!(sa(&["ke-z-n1a", "ke-z-n1b", "ke-z-n1c"], "ke-z-sa1") && sa(&["ke-z-n2a", "ke-z-n2b"], "ke-z-sa2") && sa(&["ke-z-n3a", "ke-z-n3b", "ke-z-n3c"], "ke-z-sa3")); // 64
    assert_eq!(["ke-z-as1", "ke-z-as2", "ke-z-as3", "ke-z-n1a", "ke-z-n2a", "ke-z-n3a"].map(|n| chain(k, n)), [1, 2, 3, 3, 2, 3]); // 69
    let downs = |x: &Move| matches!(on_hit(x), Some("knockdown" | "launch"));
    assert!(!["ke-z-n1a", "ke-z-n1b", "ke-z-n1c", "ke-z-n2a", "ke-z-n2b", "ke-z-n3b", "ke-z-n3c", "ke-z-as2", "ke-z-as3", "ke-z-as3b"].iter().any(|n| downs(km(k, n)))); // 70
    assert_eq!(["ke-z-as1", "ke-z-as2b", "ke-z-as3c"].map(|n| on_hit(km(k, n))), [Some("knockdown"), Some("launch"), Some("knockdown")]); // 72
    assert!(km(k, "ke-z-as3c").flags.iter().any(|f| f == "guard-crush")); // 73
    assert!(km(k, "ke-z-n2a").armor_hits == 1 && km(k, "ke-z-n2b").armor_hits == 1 && km(k, "ke-z-n2a").params.armor_act && km(k, "ke-z-n2b").params.armor_act); // 75
    assert_eq!(km(k, "ke-z-as2").armor_hits, 0);
    let t = km(k, "ke-z-n3a");
    assert!(t.a == 0 && t.flags.iter().any(|f| f == "parry") && t.params.window == Some([2, 28])); // 78
    assert_eq!(kit_next(data(), k, "ke-z-n3a", "land").unwrap().name, "ke-z-n3b");
    assert!(k.cls.keys().all(|id| data().moves.iter().find(|x| &x.id == id).unwrap().params.charge_mult.is_none())); // 81 (:clash-count: duel_data's Params denies unknown keys)
    assert!(data().kits.kits["kenpachi"].values().all(|k| k.hooks.get("armor").map(String::as_str) == Some("KEN-ARMOR") && !k.hooks.contains_key("clash"))); // 84
    use duel_sim::core::{core_verdict, Verdict};
    assert_eq!(core_verdict(Some(MoveClass::Na), Some(MoveClass::Ns), false, None, None), Verdict::Cancel); // 86
}

#[test]
fn ken_lisp_bankai_kits() {
    type Spec = (&'static str, &'static str, [i32; 4], [i32; 4], [i32; 5], [i32; 5], i32, i32);
    let specs: [Spec; 2] = [
        ("bankai", "ke-kr-", [14, 10, 10, 8], [80, 70, 70, 40], [7, 7, 8, 8, 10], [40, 40, 45, 45, 65], 110, 300),
        ("bankai-2", "ke-zh-", [16, 12, 14, 16], [100, 90, 100, 130], [9, 10, 10, 11, 13], [50, 55, 55, 60, 85], 150, 320),
    ];
    for (form, pre, ns_s, ns_d, j_s, j_d, fin_d, sp_d) in specs {
        let k = kit(form);
        let n = |x: &str| format!("{pre}{x}");
        let m = |x: &str| km(k, &n(x));
        assert!(["na", "nb", "nc", "nd"].iter().all(|x| cls(k, &n(x)) == Some(MoveClass::Ns))); // 97
        assert!(["as1", "as2", "as3", "as3b", "as4", "as4b", "as4c", "fin", "sp"].iter().all(|x| cls(k, &n(x)) == Some(MoveClass::As))); // 98
        assert_eq!(cls(k, &n("sa")), Some(MoveClass::Sa)); // 99
        assert!(k.core.ns.len() == 1 && k.core.as_segs.len() == 5 && k.core.as_writes == Some(vec![Some(1); 5])); // 100
        assert_eq!(["j1", "j2", "j3", "j4", "j5", "sa"].map(|x| m(x).params.as_ptr), [1, 2, 3, 4, 5, 1].map(Some)); // 102
        assert_eq!(["as1", "as2", "as3", "as4", "na", "sp"].map(|x| chain(k, &n(x))), [1, 2, 3, 4, 4, 1]); // 104
        assert_eq!(["na", "nb", "nc", "nd"].map(|x| m(x).s), ns_s); // 105
        assert_eq!(["j1", "j2", "j3", "j4", "j5"].map(|x| m(x).s), j_s); // 106
        assert_eq!(["j1", "j2", "j3", "j4", "j5"].map(|x| m(x).dmg), j_d); // 107
        assert_eq!((m("fin").dmg, m("sp").dmg), (fin_d, sp_d)); // 108
        assert_eq!(["na", "nb", "nc"].map(|x| m(x).dmg), [ns_d[0], ns_d[1], ns_d[2]]); // 109
        assert!(m("na").s >= 14); // 110
        let downs = |x: &Move| matches!(on_hit(x), Some("knockdown" | "launch"));
        assert!(!["na", "nb", "nc", "nd", "as2", "as3", "as3b", "as4", "as4b", "as4c"].iter().any(|x| downs(m(x)))); // 112
        assert!(["fin", "as1", "sp"].iter().all(|x| on_hit(m(x)) == Some("knockdown"))); // 113
        let f0 = |x: &Move, h: &str| x.on_frame.first().is_some_and(|e| e[0].as_f32() == Some(0.0) && e[1].as_str() == Some(h));
        assert!(["na", "nb", "nc", "nd", "as2", "as3b", "as4c", "fin", "as1"].iter().all(|x| m(x).on_frame.len() == 1 && f0(m(x), "KEN-BK-COST"))); // 115
        assert!(f0(m("sp"), "KEN-BK-SPECIAL")); // 116
        assert_eq!(m("sp").params.dmg_at, Some(if form == "bankai" { 40 } else { 34 })); // 117
        assert!(!["lv", "as-pick", "hit", "link-ok"].iter().any(|h| k.hooks.contains_key(*h))); // 118
    }
    assert_eq!(Knobs::from(data()).unwrap().ken_bk_cost, 40); // 119
}

#[test]
fn ken_lisp_cadence_and_shikai() {
    assert!(["base", "nozarashi", "bankai", "bankai-2"].iter().all(|f| kit(f).open_s.is_none())); // 125
    let s = |f: &str, n: &str| km(kit(f), n).s;
    assert_eq!([s("base", "ke-z-n1a"), s("base", "ke-z-n2a"), s("nozarashi", "ke-s-n1a"), s("nozarashi", "ke-s-n2a"), s("bankai", "ke-kr-na"), s("bankai-2", "ke-zh-na")], [14, 16, 16, 14, 14, 16]); // 126
    let ic = &data().kits.kits["ichigo"]["base"];
    assert!(km(kit("nozarashi"), "ke-s-n2e").hits[0].hs == 14 && km(kit("base"), "ke-z-j1").hits[0].hs == 4 && km(kit("base"), "ke-z-as2b").hits[0].hs == 11); // 130
    assert!(ic.hs_dmg.is_none() && ic.open_s.is_none());

    let k = kit("nozarashi");
    let is = |ns: &[&str], c| ns.iter().all(|n| cls(k, n) == Some(c));
    assert!(is(&["ke-s-n1a", "ke-s-n1b", "ke-s-n1c", "ke-s-n1d", "ke-s-n1e", "ke-s-n2a", "ke-s-n2b", "ke-s-n2c", "ke-s-n2d", "ke-s-n2e"], MoveClass::Ns)); // 137
    assert!(is(&["ke-s-as1", "ke-s-as1b", "ke-s-as1c", "ke-s-as1d", "ke-s-as2", "ke-s-as2b", "ke-s-as2c", "ke-s-as2d", "ke-s-burst1", "ke-s-burst2", "ke-s-sp1", "ke-s-sp2"], MoveClass::As)); // 138
    assert_eq!(cls(k, "ke-s-sa"), Some(MoveClass::Sa)); // 140
    assert!(k.core.ns.len() == 2 && k.core.as_by_press.as_deref() == Some(&[1, 1, 2][..])); // 141
    let lv = ["ke-s-n1a", "ke-s-n1b", "ke-s-n1c", "ke-s-n1d", "ke-s-n1e", "ke-s-n2a", "ke-s-n2b", "ke-s-n2c", "ke-s-n2d", "ke-s-n2e", "ke-s-as1", "ke-s-as1b", "ke-s-as1c",
        "ke-s-as1d", "ke-s-as2", "ke-s-as2b", "ke-s-as2c", "ke-s-as2d", "ke-s-j3", "ke-s-j4", "ke-s-j5", "ke-s-j6", "ke-s-j7"]
        .map(|n| km(k, n).params.lv.unwrap_or(0));
    assert_eq!(lv, [0, 1, 2, 3, 3, 0, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 3, 3, 3, 3]); // 143
    let p = |n: &str| &km(k, n).params;
    assert!(["ke-s-j4", "ke-s-j5", "ke-s-j6"].iter().all(|n| p(n).special_as) && p("ke-s-j7").bankai_as && !p("ke-s-j7").special_as); // 147
    assert!(["ke-s-as1", "ke-s-as1b", "ke-s-as1c", "ke-s-as1d", "ke-s-as2", "ke-s-as2b", "ke-s-as2c", "ke-s-as2d"].iter().all(|n| p(n).lv_up)); // 148
    assert!(!["ke-s-burst1", "ke-s-burst2", "ke-s-sp1", "ke-s-sp2"].iter().any(|n| p(n).lv_up)); // 149
    assert!(["ke-s-burst1", "ke-s-burst2"].iter().all(|n| p(n).burst == Some([100, 150, 200, 260]))); // 150
    assert_eq!(s_of(k, &["ke-s-j1", "ke-s-j2", "ke-s-j3", "ke-s-j4", "ke-s-j5", "ke-s-j6", "ke-s-j7", "ke-s-sa", "ke-s-n1a", "ke-s-n1b", "ke-s-n1c", "ke-s-n1d", "ke-s-n1e",
        "ke-s-n2a", "ke-s-n2b", "ke-s-n2c", "ke-s-n2d", "ke-s-n2e", "ke-s-burst1", "ke-s-burst2", "ke-s-sp1", "ke-s-sp2"]),
        [9, 9, 11, 9, 9, 10, 12, 8, 16, 12, 12, 10, 14, 14, 10, 16, 14, 18, 14, 12, 12, 20]); // 152
    assert_eq!(dmg_of(k, &["ke-s-j1", "ke-s-j3", "ke-s-j7", "ke-s-n1a", "ke-s-n1e", "ke-s-n2a", "ke-s-n2e", "ke-s-as1d", "ke-s-as2d", "ke-s-sp2"]), [40, 55, 70, 70, 100, 45, 140, 110, 150, 260]); // 156
    assert_eq!(km(k, "ke-s-sp1").hits.iter().map(|w| w.dmg).collect::<Vec<_>>(), [60, 60, 120]); // 158
    assert_eq!(km(k, "ke-s-n1d").hits.iter().map(|w| w.dmg).collect::<Vec<_>>(), [35, 35]); // 159
    let downs = |x: &Move| matches!(on_hit(x), Some("knockdown" | "launch"));
    assert!(!["ke-s-n1a", "ke-s-n1b", "ke-s-n1c", "ke-s-n1e", "ke-s-n2a", "ke-s-n2b", "ke-s-n2c", "ke-s-n2d", "ke-s-n2e"].iter().any(|n| downs(km(k, n)))); // 160
    let h = |k: &Kit, x: &str| k.hooks.get(x).cloned();
    assert_eq!(["lv", "as-pick", "hit", "link-ok"].map(|x| h(k, x)), ["KEN-LV", "KEN-AS-PICK", "KEN-HIT", "KEN-LINK-OK"].map(|s| Some(s.to_string()))); // 163
    assert!(!["lv", "as-pick", "hit", "link-ok"].iter().any(|x| kit("bankai").hooks.contains_key(*x))); // 164
    assert!(h(kit("bankai"), "tick").as_deref() == Some("KEN-BK-TICK") && h(kit("base"), "lv").is_none()); // 165
    assert!(k.meter.lv == Some(true) && k.meter.max == Some(3) && k.meter.start == Some(0) && k.open_s.is_none()); // 166
    let mut js = vec![];
    let mut n = "ke-s-j1".to_string();
    while let Some(x) = kit_next(data(), k, &n, "q") {
        js.push(x.name.clone());
        n = x.name.clone();
    }
    assert_eq!(js, ["ke-s-j2", "ke-s-j3", "ke-s-j4", "ke-s-j5", "ke-s-j6", "ke-s-j7"]); // 168
}

// ---------------------------------------------------------------- the hooks and cinematics off the traces' paths

/// A battle-ready Kenpachi (P1) vs Kenpachi pair, 2.2 m apart on x, the log on.
fn pair_in(d: &'static Data, form: Form) -> (Match, Entity, Entity) {
    let mut m = Match::new(d);
    m.picks = [Character::Kenpachi, Character::Kenpachi];
    duel_sim::flow::spawn_pair(&mut m, true, true);
    m.log_on = true;
    let (a, b) = (m.p1, m.p2);
    m.transform.get_mut(a).unwrap().pos = [-1.1, 0.0, 0.0];
    m.transform.get_mut(b).unwrap().pos = [1.1, 0.0, 0.0];
    duel_sim::cine::face_each_other(&mut m, a, b, None);
    if form != Form::Base {
        assert!(duel_sim::gauges::set_form(&mut m, a, form));
    }
    m.log.clear();
    (m, a, b)
}
fn id(m: &Match, form: &str, n: &str) -> duel_sim::components::MoveId {
    duel_sim::fighter::id_of(m, km(kit(form), n))
}

/// BANKAI! (gauges.lisp 246-266) with RESTORE and CINE (not the burst AS's path, which the traces take): the awakening's regen, his
/// Reishi refilled, Konpaku kept, the log line, KEN-BANKAI-CINE (186 frames, its frame 0 facing them); both idle after it. Without
/// them: neither restored, no cinematic, idle at once.
#[test]
fn bankai_restore_cine_and_not() {
    let (mut m, a, b) = pair_in(data(), Form::Nozarashi);
    let g = m.gauges.get_mut(a).unwrap();
    (g.reishi, g.konpaku, g.awake_regen) = (500, 3, 0);
    m.transform.get_mut(a).unwrap().yaw = 1.0;
    duel_sim::gauges::bankai(&mut m, a, Form::Bankai, true, true);
    let (g, f) = (m.gauges.get(a).unwrap(), m.fighter.get(a).unwrap());
    assert_eq!((g.awake_regen, g.reishi, g.konpaku, f.form), (333, 1300, 3, Form::Bankai));
    assert!(m.log.iter().any(|l| l.ends_with("P1 BANKAI (konpaku kept, -0)")));
    let c = m.cine.as_ref().map(|c| (c.name.lisp(), c.len, c.after));
    assert_eq!(c, Some(("KEN-BANKAI-CINE", 186, Some(duel_sim::cine::After::IdleBoth(a, b)))));
    assert_eq!(m.transform.get(a).unwrap().yaw, duel_sim::math::dir_yaw(2.2, 0.0)); // FACE-EACH-OTHER at frame 0
    while m.cine.is_some() {
        duel_sim::cine::cine_step(&mut m);
    }
    assert!([a, b].iter().all(|&e| m.fighter.get(e).unwrap().state == State::Idle) && m.unported.is_none());

    let (mut m, a, _) = pair_in(data(), Form::Nozarashi);
    let g = m.gauges.get_mut(a).unwrap();
    (g.reishi, g.awake_regen) = (500, 0);
    duel_sim::gauges::bankai(&mut m, a, Form::Bankai2, false, false);
    let (g, f) = (m.gauges.get(a).unwrap(), m.fighter.get(a).unwrap());
    assert_eq!((g.awake_regen, g.reishi, f.form, f.state, m.cine.is_none()), (0, 500, Form::Bankai2, State::Idle, true));
}

/// GAUGE-SYSTEM's timed form (no kit in the data has a :duration: a copy gives the Bankai 0.5 s and a 5 %/s burn): BURN-AMOUNT's whole
/// points (round(1300 x 0.05) = 65 a second: floor(65 (n+1) / 60) - floor(65 n / 60), so 1 a step but 2 on step 11, 23 of 30), then
/// SET-FORM of its :inherit on the last step.
#[test]
fn timed_form_burn_and_end() {
    let mut d = Data::embedded();
    let b = d.kits.kits.get_mut("kenpachi").unwrap().get_mut("bankai").unwrap();
    (b.duration, b.burn) = (Some(0.5), 0.05);
    let d: &'static Data = Box::leak(Box::new(d));
    let (mut m, a, _) = pair_in(d, Form::Bankai);
    assert_eq!(m.gauges.get(a).unwrap().form_left, 30);
    let r0 = m.gauges.get(a).unwrap().reishi;
    let mut burnt = vec![];
    for _ in 0..30 {
        let r = m.gauges.get(a).unwrap().reishi;
        duel_sim::gauges::gauge_system(&mut m);
        burnt.push(r - m.gauges.get(a).unwrap().reishi);
    }
    let want: Vec<i64> = (0..30).map(|n| (65 * (n + 1)) / 60 - (65 * n) / 60).collect();
    assert_eq!(burnt, want);
    assert_eq!(r0 - m.gauges.get(a).unwrap().reishi, 32);
    let f = m.fighter.get(a).unwrap();
    assert_eq!((f.form, m.gauges.get(a).unwrap().form_left), (Form::Base, 0)); // (its :inherit, :base)
    assert!(m.log.iter().any(|l| l.ends_with("P1 form BASE")));
}

/// KEN-DMG-MULT: a burst's damage by the route's level (clamped to its list), 1.0 for anything else; KEN-LV rounds the meter
/// (banker's: 2.5 -> 2); KEN-LINK-OK: J4-J7 only at L3.
#[test]
fn dmg_mult_lv_link_ok() {
    use duel_sim::ken::hooks::*;
    let (mut m, a, _) = pair_in(data(), Form::Nozarashi);
    let (k, burst1, j1) = (kit("nozarashi"), km(kit("nozarashi"), "ke-s-burst1"), km(kit("nozarashi"), "ke-s-j1"));
    for (lv, want) in [(0, 1.0f32), (2, 2.0), (3, 2.6), (7, 2.6), (-1, 1.0)] {
        m.fighter.get_mut(a).unwrap().lv_cap = lv;
        assert_eq!(dmg_mult(&mut m, a, 100, Some(burst1), false), want);
    }
    assert!(m.log.iter().any(|l| l.ends_with("P1 BURST 260 (L7)")));
    assert_eq!((dmg_mult(&mut m, a, 100, Some(burst1), true), dmg_mult(&mut m, a, 0, Some(burst1), false), dmg_mult(&mut m, a, 40, Some(j1), false)), (1.0, 1.0, 1.0));
    for (meter, l) in [(0.0, 0), (2.5, 2), (3.0, 3), (1.5, 2)] {
        m.gauges.get_mut(a).unwrap().meter = meter;
        assert_eq!(lv(&m, a), l);
    }
    m.gauges.get_mut(a).unwrap().meter = 2.0;
    assert!(link_ok(&m, a, km(k, "ke-s-j3")) && !link_ok(&m, a, km(k, "ke-s-j4")));
    m.gauges.get_mut(a).unwrap().meter = 3.0;
    assert!(link_ok(&m, a, km(k, "ke-s-j4")));
}

/// KEN-HIT: an NS segment's (or a :lv-up AS's) first clean hit of a combo raises L, once a combo (the victim's first hit starts one), up
/// to 3; a block, a hazard or a non-:lv-up AS does nothing.
#[test]
fn hit_raises_l_once_a_combo() {
    use duel_sim::ken::hooks::hit;
    let (mut m, a, b) = pair_in(data(), Form::Nozarashi);
    let (n1a, burst) = (km(kit("nozarashi"), "ke-s-n1a"), km(kit("nozarashi"), "ke-s-burst1"));
    let meter = |m: &Match| m.gauges.get(a).unwrap().meter;
    m.fighter.get_mut(a).unwrap().cls = Some(Cls::Ns);
    m.fighter.get_mut(b).unwrap().combo_hits = 1;
    hit(&mut m, a, b, Res::Hit, Some(n1a), false);
    assert_eq!((meter(&m), m.log.last().map(|l| l.ends_with("P1 L1"))), (1.0, Some(true)));
    m.fighter.get_mut(b).unwrap().combo_hits = 2;
    hit(&mut m, a, b, Res::Hit, Some(n1a), false); // the same combo: no more
    assert_eq!(meter(&m), 1.0);
    m.fighter.get_mut(b).unwrap().combo_hits = 1;
    hit(&mut m, a, b, Res::Blocked, Some(n1a), false); // a block neither resets nor raises
    hit(&mut m, a, b, Res::Hit, Some(n1a), true); // a hazard: the new combo starts, nothing raised
    assert_eq!((meter(&m), m.fighter.get(a).unwrap().lv_got), (1.0, false));
    m.fighter.get_mut(a).unwrap().cls = Some(Cls::As);
    hit(&mut m, a, b, Res::Counter, Some(burst), false); // an AS without :lv-up
    assert_eq!(meter(&m), 1.0);
    m.fighter.get_mut(a).unwrap().cls = Some(Cls::Ns);
    for want in [2.0, 3.0, 3.0] {
        hit(&mut m, a, b, Res::Hit, Some(n1a), false);
        assert_eq!(meter(&m), want);
    }
}

/// KEN-AS-PICK: after J7 the Bankai's burst AS (pointer kept), after J4-J6 the pointer's special AS, an AS of the other pointer the
/// burst to it (L 0, the log line), else NIL.
#[test]
fn as_pick_branches() {
    use duel_sim::ken::hooks::as_pick;
    let (mut m, a, _) = pair_in(data(), Form::Nozarashi);
    let put = |m: &mut Match, n: &str, ptr: i64| {
        let i = id(m, "nozarashi", n);
        let f = m.fighter.get_mut(a).unwrap();
        (f.mv, f.ptr, f.lv_cap) = (Some(i), ptr, 2);
        m.gauges.get_mut(a).unwrap().meter = 2.0;
    };
    put(&mut m, "ke-s-j7", 2);
    assert_eq!(as_pick(&mut m, a, 2), Some((id(&m, "nozarashi", "ke-s-bankai"), None)));
    put(&mut m, "ke-s-j5", 2);
    assert_eq!(as_pick(&mut m, a, 2), Some((id(&m, "nozarashi", "ke-s-sp2"), None)));
    put(&mut m, "ke-s-j4", 1);
    assert_eq!(as_pick(&mut m, a, 2), Some((id(&m, "nozarashi", "ke-s-sp1"), None)));
    put(&mut m, "ke-s-j3", 1);
    assert_eq!(as_pick(&mut m, a, 2), Some((id(&m, "nozarashi", "ke-s-burst2"), Some(2))));
    assert!(m.gauges.get(a).unwrap().meter == 0.0 && m.log.last().unwrap().ends_with("P1 BURST to pointer 2 (L2)"));
    put(&mut m, "ke-s-j1", 1);
    assert_eq!(as_pick(&mut m, a, 1), None);
    assert_eq!(m.gauges.get(a).unwrap().meter, 2.0);
}

/// KEN-BK-COST / -SPECIAL / -TICK: the cost burns 40 but never below 1; the special marks the way back, taken once he is out of
/// :move / :cine: the Shikai on 斬壞's pointer 2, L 0, -1 Konpaku unless it is his last.
#[test]
fn bankai_cost_and_way_back() {
    use duel_sim::ken::hooks::*;
    let (mut m, a, _) = pair_in(data(), Form::Bankai2);
    m.gauges.get_mut(a).unwrap().reishi = 41;
    bk_cost(&mut m, a);
    bk_cost(&mut m, a);
    assert_eq!(m.gauges.get(a).unwrap().reishi, 1);
    assert!(m.log.last().unwrap().ends_with("P1 bankai cost 40, reishi 1"));
    bk_special(&mut m, a);
    let f = m.fighter.get_mut(a).unwrap();
    (f.state, f.ptr) = (State::Move, 1);
    m.gauges.get_mut(a).unwrap().konpaku = 4;
    bk_tick(&mut m, a); // still in the move
    assert_eq!(m.fighter.get(a).unwrap().form, Form::Bankai2);
    m.fighter.get_mut(a).unwrap().state = State::Idle;
    bk_tick(&mut m, a);
    let (f, g) = (m.fighter.get(a).unwrap(), m.gauges.get(a).unwrap());
    assert_eq!((f.form, f.ptr, f.bk_out, g.konpaku, g.meter), (Form::Nozarashi, 2, false, 3, 0.0));
    assert!(m.log.last().unwrap().ends_with("P1 BANKAI ends: Shikai pointer 2, konpaku 3"));
    let (mut m, a, _) = pair_in(data(), Form::Bankai);
    m.fighter.get_mut(a).unwrap().bk_out = true;
    m.gauges.get_mut(a).unwrap().konpaku = 1;
    bk_tick(&mut m, a);
    let (f, g) = (m.fighter.get(a).unwrap(), m.gauges.get(a).unwrap());
    assert_eq!((f.form, f.ptr, g.konpaku), (Form::Nozarashi, 1, 1)); // (his last Konpaku kept)
}

/// The look hazards: 千切's draw (life *CHIGIRI-BURST* + 4 = 32), TATE-GOTO's rift 2.2 m ahead (life 16), its wave (his yaw, 14), its
/// ground line (16 m, 70, :METEOR) in that order; the cracks (3.5 / 2.4 m); the bursts' hitstops (8 / 10).
#[test]
fn look_hazards_and_hitstops() {
    use duel_sim::components::HazardKind;
    use duel_sim::ken::hooks::*;
    let (mut m, a, _) = pair_in(data(), Form::Bankai2);
    let yaw = m.transform.get(a).unwrap().yaw;
    tategoto_split(&mut m, a);
    chigiri_open(&mut m, a);
    ground_crack(&mut m, a);
    bk_slam(&mut m, a);
    let hz: Vec<_> = m.hazard.iter().map(|(_, h)| (h.kind, h.look.map(|s| s.0), h.life, h.size, h.yaw, h.x, h.z)).collect();
    let fx = |y: f32| (duel_sim::math::fwd_x(y), duel_sim::math::fwd_z(y));
    let (fxx, fxz) = fx(yaw);
    assert_eq!(hz.len(), 6);
    assert_eq!(hz[0], (Some(HazardKind::Fx), Some("KEN-TATEGOTO-LOOK"), 16, 1.0, 0.0, -1.1 + 2.2 * fxx, 0.0 + 2.2 * fxz));
    assert_eq!(hz[1], (Some(HazardKind::Fx), Some("KEN-TATEGOTO-WAVE"), 14, 1.0, yaw, -1.1, 0.0));
    assert_eq!(hz[2], (Some(HazardKind::Line), Some(":METEOR"), 70, 16.0, yaw, -1.1, 0.0));
    assert_eq!((hz[3].1, hz[3].2), (Some("KEN-CHIGIRI-LOOK"), 32));
    assert_eq!((hz[4].1, hz[4].2, hz[4].3, hz[5].2, hz[5].3), (Some(":CRACK"), 50, 3.5, 40, 2.4));
    chigiri_burst(&mut m, a);
    assert_eq!(m.time.hitstop, 8);
    tategoto_cut(&mut m, a);
    assert_eq!(m.time.hitstop, 10);
}

/// APPLY-HIT through one HIT-SYSTEM call (not a whole step) with Kenpachi's real hooks, ECL-verified (Task 11 review, re-run in Task 12
/// on tools/simgate's native sim): both seats CPUs (`spawn-pair :cpu1 t :cpu2 t`), P1 at 0, P2 at 1.5, FACE-EACH-OTHER, P1 in his move
/// at its first window's frame with fs 100. The moves are the base kit's structs (KIT-MOVE), not FIND-MOVE's `*moves*` registry copies:
/// KE-Z-N2A's hs is 10 in the kit, 8 in the registry, so the hitstop below is 10 (8 with FIND-MOVE). ARMORED via KEN-ARMOR: P2 in
/// KE-Z-N2A at sf = s + 1 (past the startup: only the hook covers it), classless (two NS segments would cancel) → `ARMORED 65`, Reishi
/// 1267, armour spent; P2's own window lands too (`HIT 85`, hitstop 10). BLOCKED: P2 guarding (guard-t 99) → `BLOCKED 35`, blockstun 10,
/// guard gauge 92, hitstop 3.
#[test]
fn apply_hit_armored_and_blocked_as_ecl() {
    let setup = |p1: &str| {
        let mut m = Match::new(data());
        m.picks = [Character::Kenpachi, Character::Kenpachi];
        duel_sim::flow::spawn_pair(&mut m, true, true);
        m.log_on = true;
        let (a, b) = (m.p1, m.p2);
        m.transform.get_mut(a).unwrap().pos = [0.0, 0.0, 0.0];
        m.transform.get_mut(b).unwrap().pos = [1.5, 0.0, 0.0];
        duel_sim::cine::face_each_other(&mut m, a, b, None);
        let x = id(&m, "base", p1);
        duel_sim::fighter::start_move(&mut m, a, x, None);
        m.fighter.get_mut(a).unwrap().sf = km(kit("base"), p1).hits[0].from as i64;
        m.gauges.get_mut(a).unwrap().fs = 100.0;
        (m, a, b)
    };
    let tail = |m: &Match| m.log.iter().map(|l| l.split_once("] ").unwrap().1.to_string()).collect::<Vec<_>>();
    let (mut m, _, b) = setup("ke-z-n1a");
    let n2a = id(&m, "base", "ke-z-n2a");
    duel_sim::fighter::start_move(&mut m, b, n2a, None);
    m.fighter.get_mut(b).unwrap().sf = km(kit("base"), "ke-z-n2a").s as i64 + 1;
    m.fighter.get_mut(b).unwrap().cls = None; // (classless: two NS segments would cancel)
    m.log.clear();
    duel_sim::combat::hit_system(&mut m);
    assert_eq!(m.unported, None);
    assert_eq!(tail(&m), ["P1 KE-Z-N1A -> P2 ARMORED 65", "P2 KE-Z-N2A -> P1 HIT 85", "P2 dealt 43: crumple stun 40"]);
    assert_eq!((m.gauges.get(b).unwrap().reishi, m.fighter.get(b).unwrap().armor_left, m.time.hitstop), (1267, 0, 10));

    let (mut m, _, b) = setup("ke-z-j1");
    let f = m.fighter.get_mut(b).unwrap();
    (f.state, f.guard_t) = (State::Guard, 99);
    m.log.clear();
    duel_sim::combat::hit_system(&mut m);
    assert_eq!(m.unported, None);
    assert_eq!(tail(&m), ["P1 KE-Z-J1 -> P2 BLOCKED 35"]);
    let (fb, gb) = (m.fighter.get(b).unwrap(), m.gauges.get(b).unwrap());
    assert_eq!((fb.state, fb.stun, gb.gg, m.time.hitstop), (State::GuardHit, 10, 92.0, 3));
}

/// KEN-STANCE-RELEASE (100 + stored, guard-crushing at 150), KEN-CHARGE-TICK (crush when the button is down on frame S; the dash at
/// 14 m/s while active, untouched and beyond 1.2 m) and KEN-FLURRY (the :land string on a hit).
#[test]
fn stance_charge_flurry() {
    use duel_sim::components::Button;
    use duel_sim::ken::hooks::*;
    let (mut m, a, _) = pair_in(data(), Form::Base);
    for (stored, bonus, crush) in [(40, 40, false), (150, 150, true)] {
        m.fighter.get_mut(a).unwrap().stored = stored;
        stance_release(&mut m, a);
        let f = m.fighter.get(a).unwrap();
        assert_eq!((f.dmg_bonus, f.crush, f.stored), (bonus, crush, 0));
    }
    assert_eq!(m.fighter.get(a).unwrap().callout.map(|s| s.0), Some("KITTE MIRO YO!"));
    let ch = id(&m, "base", "ke-charge");
    let s = km(kit("base"), "ke-charge").s as i64;
    let f = m.fighter.get_mut(a).unwrap();
    (f.state, f.mv, f.phase, f.sf, f.button, f.crush, f.contact, f.dist) = (State::Move, Some(ch), Some(Phase::Main), s, Some(Button::Quick), false, None, 2.2);
    m.pilot.get_mut(a).unwrap().vpad.set(Button::Quick as usize, true);
    charge_tick(&mut m, a);
    let yaw = m.transform.get(a).unwrap().yaw;
    assert!(m.fighter.get(a).unwrap().crush);
    assert_eq!(m.motion.get(a).unwrap().vel, [14.0 * duel_sim::math::fwd_x(yaw), 0.0, 14.0 * duel_sim::math::fwd_z(yaw)]);
    m.motion.get_mut(a).unwrap().vel = [0.0; 3];
    m.fighter.get_mut(a).unwrap().dist = 1.0;
    charge_tick(&mut m, a);
    assert_eq!(m.motion.get(a).unwrap().vel, [0.0; 3]);
    m.fighter.get_mut(a).unwrap().contact = Some(Contact::Block);
    flurry(&mut m, a);
    assert_eq!(m.fighter.get(a).unwrap().mv, Some(ch));
    m.fighter.get_mut(a).unwrap().contact = Some(Contact::Hit);
    flurry(&mut m, a);
    let f = m.fighter.get(a).unwrap();
    assert_eq!((f.mv, f.contact, f.land_sf), (Some(id(&m, "base", "ke-flurry")), Some(Contact::Hit), 0));
}

/// The Kikon cinematics' moves (ken.lisp 690-913): 狂嵐's A 2.0 m before V at frame 0 and V blown 7 m past his mark at 130; 斬壞's 2.4 m
/// and 126; 鈴's A placed 3.0 m, behind V on 78 facing the line, V 3.4 m toward A's side on 172; 斬ってみろよ's V 1.2 m back on 92 and on
/// his mark on 140 (each AT once: cine-test.lisp 41, 42). CINE-PLACE's own save gives its places back at the end; the bare START-CINE
/// here has no CINE-STAGE before it, so FACE-EACH-OTHER's gap stays (in play SETTLE-SOULS' CINE-STAGE saves both first).
#[test]
fn kikon_cines_move_the_actors() {
    use duel_sim::cine::{cine_step, start_cine, CineName};
    use duel_sim::ken::cine::KenCine;
    let run_to = |m: &mut Match, cf: i64| {
        while m.cine.as_ref().is_some_and(|c| c.cf < cf) {
            cine_step(m);
        }
    };
    let p = |m: &Match, e: Entity| m.transform.get(e).unwrap().pos;
    for (c, gap, at, s) in [(KenCine::KrKikon, 2.0f32, 130, -7.0f32), (KenCine::ZhKikon, 2.4, 126, -7.0)] {
        let (mut m, a, v) = pair_in(data(), Form::Bankai);
        start_cine(&mut m, CineName::Ken(c), a, v, None);
        assert_eq!(p(&m, a), [1.1 - gap, 0.0, 0.0]);
        assert_eq!(m.cine.as_ref().unwrap().line, [1.1, 0.0, -1.0, 0.0]);
        run_to(&mut m, at - 1);
        assert_eq!(p(&m, v), [1.1, 0.0, 0.0]);
        cine_step(&mut m);
        assert_eq!(p(&m, v), [1.1 - s, 0.0, 0.0]);
        run_to(&mut m, 999);
        assert_eq!((m.cine.is_none(), p(&m, v)), (true, [1.1 - s, 0.0, 0.0])); // (no CINE-SAVE in these: kept)
    }
    let (mut m, a, v) = pair_in(data(), Form::Base);
    start_cine(&mut m, CineName::Ken(KenCine::ZKikon1), a, v, None);
    assert_eq!(p(&m, a), [1.1 - 3.0, 0.0, 0.0]);
    run_to(&mut m, 78);
    assert_eq!((p(&m, a), m.transform.get(a).unwrap().yaw), ([1.1 + 1.6, 0.0, 0.0], duel_sim::math::dir_yaw(-1.0, 0.0)));
    run_to(&mut m, 172);
    assert_eq!(p(&m, v), [1.1 - 3.4, 0.0, 0.0]);
    run_to(&mut m, 999);
    assert_eq!((p(&m, a), p(&m, v)), ([-1.1, 0.0, 0.0], [1.1, 0.0, 0.0])); // CINE-PLACE's save given back
    let (mut m, a, v) = pair_in(data(), Form::Base);
    start_cine(&mut m, CineName::Ken(KenCine::ZKikon2), a, v, None);
    assert_eq!(p(&m, a), [1.1 - 1.9, 0.0, 0.0]);
    run_to(&mut m, 92);
    assert_eq!(p(&m, v), [1.1 + 1.2, 0.0, 0.0]);
    m.transform.get_mut(v).unwrap().pos = [5.0, 0.0, 0.0];
    run_to(&mut m, 139);
    assert_eq!(p(&m, v), [5.0, 0.0, 0.0]); // cine-test.lisp 41, 42: an AT fires once, on its frame
    run_to(&mut m, 140);
    assert_eq!(p(&m, v), [1.1, 0.0, 0.0]);
    assert!(KenCine::from_lisp("KEN-S-KIKON2-CINE").is_some_and(|c| c.frames() == 290 && c.lisp() == "KEN-S-KIKON2-CINE"));
}

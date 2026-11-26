//! kit.lisp's run-time readers: triangle.lisp's / core.lisp's checks over them (same expected values) and the hook rule.
use duel_data::{Data, Kit};
use duel_sim::kit::*;
use duel_sim::knobs::Knobs;
use duel_sim::rules::{hit_damage, DefMods};

fn kit<'d>(d: &'d Data, c: &str, f: &str) -> &'d Kit {
    &d.kits.kits[c][f]
}
fn names(v: Vec<String>) -> Vec<String> {
    v
}
fn s(v: &[&str]) -> Vec<String> {
    v.iter().map(|x| x.to_string()).collect()
}

#[test]
fn core_segments_routes() {
    let d = Data::embedded();
    let k = kit(&d, "ichigo", "base");
    // triangle.lisp line 109 (its first clause)
    assert_eq!(names(core_segments(&d, "ic-n2a")), s(&["ic-n2a", "ic-n2b", "ic-n2c"]));
    // line 127
    assert_eq!(k.core.as_segs.iter().map(|n| core_segments(&d, n).len()).collect::<Vec<_>>(), vec![1, 2, 3]);
    // line 128
    assert!(k.core.as_segs.iter().all(|n| core_segments(&d, n).iter().all(|m| kit_class(k, kit_move(&d, k, m)) == Some(duel_data::MoveClass::As))));
    // line 147
    assert_eq!(core_segments(&d, "ic-k-n3a"), s(&["ic-k-n3a", "ic-k-n3b", "ic-k-n3c"]));
    // CORE-ROUTES: the NS, then the AS
    let r = core_routes(&k.core);
    assert_eq!(r.len(), 6);
    assert_eq!(r[0], "ic-n1a");
    assert_eq!(r[3], k.core.as_segs[0]);
}

#[test]
fn strings_and_links() {
    let d = Data::embedded();
    // triangle.lisp lines 162-163: every form's SAs go on into its own J2
    for f in ["base", "kessa"] {
        let k = kit(&d, "ichigo", f);
        let j2 = kit_next(&d, k, k.commands["q"].as_deref().unwrap(), "q").unwrap();
        let mut sas = vec![k.core.sa.clone()];
        sas.extend(core_segment_sas(&d, &k.core));
        assert!(sas.iter().all(|n| kit_next(&d, k, n, "q").map(|m| &m.id) == Some(&j2.id)));
    }
    // line 164
    let kk = kit(&d, "ichigo", "kessa");
    assert_eq!(kit_next(&d, kk, "ic-k-sa-g1", "q").map(|m| &m.id), kit_move(&d, kk, "ic-k-j2").map(|m| &m.id));
    // lines 173-175: five J in both forms, the last the ender
    for f in ["base", "kessa"] {
        let k = kit(&d, "ichigo", f);
        let mut m = kit_command_move(&d, k, "q").unwrap();
        let mut n = 1;
        while let Some(nx) = kit_next(&d, k, mv_name(m), "q") {
            if n >= 9 {
                break;
            }
            m = nx;
            n += 1;
        }
        assert_eq!(n, 5);
        assert!(m.flags.iter().any(|f| f == "ender"));
    }
    // ken.lisp line 79's KIT-NEXT on :land
    let kb = kit(&d, "kenpachi", "base");
    assert_eq!(kit_next(&d, kb, "ke-z-n3a", "land").map(mv_name), Some("ke-z-n3b"));
    // the latch: J1 goes on with :q, link 3 does not; a press that can't go on is eaten
    let j1 = kb.commands["q"].as_deref().unwrap();
    assert!(string_link_p(&d, kb, j1) && kit_j_link_p(kb, j1) && !kit_k_link_p(kb, j1));
    assert_eq!(string_latch(&d, kb, j1, "q", None), Some("q"));
    assert_eq!(string_latch(&d, kb, j1, "zz", Some("q")), Some("q"));
    assert!(string_opener_p(&d, kb, kit_move(&d, kb, j1).unwrap()));
    assert!(kit_l_link(&d, kb, j1).is_none()); // (no live form has an L link)
    // SP-MOVE-P: kind :sp, or the :sp1 / :sp2 command's move
    let sp1 = kit_command_move(&d, kb, "sp1").unwrap();
    assert!(sp_move_p(&d, kb, sp1) && !sp_move_p(&d, kb, kit_move(&d, kb, j1).unwrap()));
    assert!(kit_command_move(&d, kb, "kikon").is_none());
}

#[test]
fn atk_def_mods() {
    let d = Data::embedded();
    let k = &Knobs::from(&d).unwrap();
    // core.lisp line 215: the Shikai x1.0 x the core damage x its :mult, Cornered with 4 lost
    let kn = kit(&d, "kenpachi", "nozarashi");
    assert_eq!(hit_damage(k, 100, kit_atk_mods(k, kn, 4, 1.0, None), DefMods::default(), 1, false, false), 60);
    assert_eq!(kit_def_mods(kn).mult, kn.taken);
}

#[test]
fn hooks_resolve_or_fail_by_name() {
    let d = Data::embedded();
    for c in ["kenpachi", "ichigo"] {
        for k in d.kits.kits[c].values() {
            hooks_of(k).unwrap();
        }
    }
    assert!(resolve("KEN-NO-SUCH-HOOK").is_none());
    let mut k = kit(&d, "kenpachi", "base").clone();
    k.hooks.insert("hit".into(), "KEN-NO-SUCH-HOOK".into());
    assert!(hooks_of(&k).unwrap_err().contains("KEN-NO-SUCH-HOOK"));
}

#[test]
fn pending_hooks_are_the_live_symbols() {
    // PENDING_HOOKS lists exactly the Kenpachi / Ichigo hook symbols of the data (no stale or missing entry)
    let d = Data::embedded();
    let mut live: Vec<&str> = ["kenpachi", "ichigo"].iter().flat_map(|c| d.kits.kits[*c].values()).flat_map(|k| k.hooks.values().map(|s| s.as_str())).collect();
    live.sort();
    live.dedup();
    assert_eq!(live, PENDING_HOOKS.to_vec());
}

#[test]
fn kit_run() {
    // core.lisp lines 569, 571
    let d = Data::embedded();
    let (b, n) = (kit(&d, "kenpachi", "base"), kit(&d, "kenpachi", "nozarashi"));
    assert!((b.run - 10.0).abs() < 1e-3 && (n.run - 10.0).abs() < 1e-3);
    assert!(n.run_clips == b.run_clips && b.run_clips[0].eq_ignore_ascii_case("ke-run"));
}

#[test]
fn kit_sanity() {
    let d = Data::embedded();
    // core.lisp lines 631, 634 (every form of the data): each command names a move or is empty; each string resolves
    for forms in d.kits.kits.values() {
        for k in forms.values() {
            assert!(k.commands.iter().all(|(c, m)| m.is_none() || kit_command_move(&d, k, c).is_some()), "{} {}", k.character, k.form);
            assert!(k.strings.iter().all(|[from, cmd, _]| kit_move(&d, k, from).is_some() && kit_next(&d, k, from, cmd).is_some()));
        }
    }
    // lines 651, 665, 666, 668
    let (kb, kn) = (kit(&d, "kenpachi", "base"), kit(&d, "kenpachi", "nozarashi"));
    assert!((kn.mult - 1.0).abs() < 1e-3 && (kb.mult - 1.0).abs() < 1e-3);
    assert!(kn.duration.is_none());
    assert!((kn.walk - 4.4).abs() < 1e-3);
    assert_eq!(kit_next(&d, kn, "ke-s-j1", "q").map(|m| &m.id), kit_move(&d, kn, "ke-s-j2").map(|m| &m.id));
    // line 743
    assert_eq!(d.kits.roster, s(&["yamamoto", "kenpachi", "rukia", "ichigo", "senjumaru", "lille", "barro", "hisagi"]));
    // line 749: the flurry, 4 more cuts + the launcher
    let fl = find_move(&d, "ke-flurry").unwrap();
    assert!(fl.hits.len() == 5 && fl.hits[4].dmg == 60 && fl.hits[4].react.eq_ignore_ascii_case("launch"));
    assert_eq!(25 + 4 * 25 + 60, find_move(&d, "ke-charge").unwrap().dmg + fl.hits.iter().map(|w| w.dmg).sum::<i32>());
}

fn adv(m: &duel_data::Move) -> Option<i64> {
    match m.adv_block {
        Some(duel_data::moves::AdvBlock::Frames(n)) => Some(n as i64),
        _ => None,
    }
}

/// core.lisp FREE-STEPS (systems.lisp LOCKED-FREE-STEPS when MORE is Some): MV blocked on its first hit; the attacker's and the
/// defender's first actionable step.
fn free_steps(k: &Knobs, mv: &duel_data::Move, more: Option<bool>) -> (i64, i64) {
    use duel_sim::components::{Contact, Phase, State};
    use duel_sim::rules::{blockstun, guard_locked_p, move_end_frame};
    let enter = mv.enter as i64;
    let h = mv_first_hit(mv) - enter;
    let end = move_end_frame(k, mv.s as i64, mv.a as i64, mv.r as i64, Some(mv.whiff as i64), Some(Contact::Block), false, None);
    let stun = blockstun(mv_total(mv), mv_first_hit(mv), adv(mv).unwrap());
    let att = (1..).find(|st| enter + st >= end).unwrap() + 1;
    let mut lock = false;
    let mut def = 0;
    for (step, sf) in (h + 1..).zip(1..) {
        if sf >= stun && !lock {
            def = step + 1;
            break;
        }
        if let Some(more) = more {
            let fr = enter + step;
            let st = if fr >= end { State::Idle } else { State::Move };
            lock = guard_locked_p(State::GuardHit, lock, 0, st, Some(Phase::Main), fr, mv.s as i64, mv.a as i64, mv.r as i64, true, more);
        }
    }
    (att, def)
}

#[test]
fn kenpachi_ichigo_data_rules() {
    use duel_sim::rules::{kikon_follow_stun, kikon_follow_wait};
    let d = Data::embedded();
    let k = &Knobs::from(&d).unwrap();
    let kb = kit(&d, "kenpachi", "base");
    let mb = |n: &str| kit_move(&d, kb, n).unwrap();
    let live = || ["kenpachi", "ichigo"].into_iter().flat_map(|c| d.kits.kits[c].values());
    // core.lisp line 53
    assert!((find_move(&d, "ke-buttagiru").unwrap().params.melee_range.unwrap() - 2.6).abs() < 1e-3);
    // line 71
    assert!((mb("ke-j1").s as i64) < k.breaker_aura + k.breaker_startup);
    // line 86 (every live form with a Breaker: J beats the grab)
    for kt in live() {
        if let (Some(br), Some(j1)) = (kit_command_move(&d, kt, "breaker"), kit_command_move(&d, kt, "q")) {
            let v = k.breaker_speed_max / 60.0;
            let (s, a) = (j1.s as i64, j1.a as i64);
            let d_hi = j1.reach + 0.34 + v * (s + a - 1) as f32;
            let d_lo = k.breaker_trigger + v * 0.max(s - br.s as i64) as f32;
            assert!(br.reach < j1.reach && j1.reach + 0.34 > k.breaker_trigger && d_lo < d_hi, "{} {}", kt.character, kt.form);
        }
    }
    // line 137 / systems.lisp line 33: block advantage end to end, plain and with the guard lock
    for kt in live() {
        for id in &kt.moves {
            let m = d.moves.iter().find(|m| &m.id == id).unwrap();
            if let (Some(a), false) = (adv(m), m.hits.is_empty()) {
                let (att, def) = free_steps(k, m, None);
                assert_eq!(def - att, a, "{id}");
                let link = string_link_p(&d, kt, mv_name(m));
                let (att, def) = free_steps(k, m, Some(link));
                assert_eq!(def - att, if link { 0.max(a) } else { a }, "lock {id}");
            }
        }
    }
    // line 179
    let kn = kit(&d, "kenpachi", "nozarashi");
    let mn = |n: &str| kit_move(&d, kn, n).unwrap();
    assert!(mn("ke-j1").s == 7 && mn("ke-k1").s == 16 && mn("ke-k2").enter == 6);
    // line 183
    let dm = |ns: &[&str]| ns.iter().zip(1..).map(|(n, i)| hit_damage(k, mb(n).dmg as i64, Default::default(), DefMods::default(), i, false, false)).sum::<i64>();
    assert!(dm(&["ke-j1", "ke-j2", "ke-j3"]) == 112 && dm(&["ke-k1", "ke-k2", "ke-k3"]) == 210 && dm(&["ke-k1", "ke-j2s", "ke-j3"]) == 147);
    assert_eq!(hit_damage(k, 70, Default::default(), DefMods::default(), 4, false, false), 60);
    // lines 187, 435, 440-442
    let gv = |n: &str| mb(n).hits[0].guard.unwrap() as i64;
    assert_eq!(gv("ke-j1") + gv("ke-j2") + gv("ke-j3"), 24);
    assert!(gv("ke-j3") == 8 && gv("ke-k3") == 18);
    assert_eq!(gv("ke-k1") + gv("ke-k2") + gv("ke-k3"), 46);
    let gm = k.gg_max;
    assert!(4.0 * 24.0 < gm && 5.0 * 24.0 >= gm && 2.0 * 46.0 < gm && 3.0 * 46.0 >= gm);
    // line 463
    assert_eq!(k.guard_crush_stun - (mv_total(mb("ke-j1")) - mv_first_hit(mb("ke-j1"))), 25);
    // line 623: the §5 table (None = no value in §5)
    type Row = (&'static str, i32, Option<i32>, Option<i32>, i32, Option<i64>); // name S A R dmg block
    let table: [Row; 10] = [
        ("ke-j1", 7, Some(3), Some(12), 35, Some(-2)), ("ke-j2", 7, Some(3), Some(13), 35, Some(-2)), ("ke-j3", 8, Some(3), Some(18), 42, Some(-4)),
        ("ke-k1", 16, Some(4), Some(20), 70, Some(-3)), ("ke-k2", 20, Some(4), Some(24), 60, Some(-3)), ("ke-k3", 20, Some(5), Some(34), 80, Some(-20)),
        ("ke-stance", 8, Some(4), Some(24), 100, Some(-14)), ("ke-buttagiru", 22, Some(4), Some(26), 180, Some(-14)),
        ("ke-charge", 14, None, None, 25, Some(-16)), ("ke-breaker", 8, Some(4), Some(18), 150, None),
    ];
    for (n, s, a, r, dmg, ab) in table {
        let m = find_move(&d, n).unwrap();
        assert!(m.s == s && a.is_none_or(|a| m.a == a) && r.is_none_or(|r| m.r == r) && m.dmg == dmg, "{n}");
        match ab {
            Some(x) => assert_eq!(adv(m), Some(x), "{n}"),
            None => assert!(matches!(m.adv_block, Some(duel_data::moves::AdvBlock::Key(_))), "{n} :guard-break"),
        }
    }
    // line 625
    assert_eq!(find_move(&d, "ke-stance").unwrap().hold, Some(vec![6, 60]));
    // lines 259-260, 658: each live form's :kikon move (none: Kenpachi)
    let kk1 = mb("ke-k1").reach;
    for kt in live() {
        let m = kit_command_move(&d, kt, "kikon");
        assert!(m.is_some() || kt.character == "kenpachi");
        if let Some(m) = m {
            let s = m.s as i64;
            assert_eq!(kikon_follow_stun(k, false, s), kikon_follow_stun(k, true, s));
            assert!(kikon_follow_stun(k, true, s) > kikon_follow_wait(k, s) + s);
            assert!(m.kind == "kikon" && m.cine.is_some() && m.hits.len() == 1 && adv(m).unwrap() <= -12 && m.reach > k.kikon_trigger && m.dmg > 0);
            assert!(k.kikon_trigger + k.block_pushback <= kk1);
        }
    }
}

#[test]
fn move_active_end_fake_moves() {
    // systems.lisp lines 47-48 (the fake moves PARSE-MOVE builds, copied onto a data move's frame fields)
    let d = Data::embedded();
    let mut shot = find_move(&d, "ke-j1").unwrap().clone();
    shot.s = 4;
    shot.a = 2;
    shot.hits.truncate(1);
    (shot.hits[0].from, shot.hits[0].to) = (4, 6);
    assert_eq!(move_active_end(&shot), 6);
    let mut sanren = shot.clone();
    (sanren.s, sanren.a) = (12, 2);
    sanren.hits = [(12, 14), (22, 24), (32, 34)].iter().map(|&(f, t)| duel_data::moves::HitWin { from: f, to: t, ..shot.hits[0].clone() }).collect();
    assert_eq!(move_active_end(&sanren), 34);
}

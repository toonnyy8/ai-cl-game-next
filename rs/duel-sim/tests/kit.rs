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

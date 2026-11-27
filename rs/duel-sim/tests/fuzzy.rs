//! tests/duel-rules/fuzzy.lisp's checks (the CPU's fuzzy reactive layer), with the same values, plus points on the shipped rule
//! bases computed on the frozen native image (build/simgate/duel.fas: FZ-CHANCE / FZ-MU printed with ~S).
use duel_data::Data;
use duel_sim::cl::Num::{self, F, I};
use duel_sim::components::Difficulty::{Easy, Hard, Normal};
use duel_sim::cpu::fuzzy::{fz_chance, fz_infer, fz_mu, fz_scale, FzRule, FzRules, Kind};
use duel_sim::knobs::Knobs;
use std::sync::OnceLock;

fn k() -> &'static Knobs {
    static K: OnceLock<Knobs> = OnceLock::new();
    K.get_or_init(|| {
        static D: OnceLock<Data> = OnceLock::new();
        Knobs::from(D.get_or_init(Data::embedded)).unwrap()
    })
}

/// (defun ~= (a b &optional (eps 1e-3)) ...)
fn approx(a: f32, b: f32) -> bool {
    (a - b).abs() < 1e-3
}

/// A hand-made rule: (antecedents, output, :must).
type R<'a> = (&'a [(&'a str, &'a str)], f32, bool);

fn rules(rs: &[R]) -> FzRules {
    FzRules(rs.iter().map(|&(a, out, must)| FzRule { ante: a.iter().map(|&(f, s)| (f.into(), s.into())).collect(), out, must }).collect())
}

#[test]
fn memberships_are_trapezoids() {
    let s = &k().fz_sets;
    assert_eq!(fz_mu(s, I(1), "yes"), 1.0);
    assert_eq!(fz_mu(s, I(0), "yes"), 0.0);
    assert!(approx(fz_mu(s, F(2.0), "near"), 0.5)); // (halfway down near's slope, 1.6 -> 2.4)
    assert!(approx(fz_mu(s, F(2.0), "mid"), 0.5));
    // (the native image's bits: a float on an integer-cornered slope, an integer on a float-cornered one)
    assert_eq!(fz_mu(s, F(0.45), "early"), 0.5000001);
    assert_eq!(fz_mu(s, I(1), "edge"), 0.50000006);
}

#[test]
fn inference_averages_by_strength() {
    let s = &k().fz_sets;
    let r = rules(&[(&[("d", "near")], 1.0, false), (&[("d", "mid")], 0.0, false)]);
    assert!(approx(fz_infer(s, &r, &[("d", F(2.0))], 0.0), 0.5));
    assert_eq!(fz_infer(s, &rules(&[(&[("d", "far")], 1.0, false)]), &[("d", F(0.5))], 0.25), 0.25); // (none fires: the default)
    // the rank step: a :MUST rule holding answers alone; below half way it is averaged as usual
    let must = rules(&[(&[("d", "near")], 0.9, true), (&[("d", "near")], 0.1, false)]);
    assert_eq!(fz_infer(s, &must, &[("d", F(0.5))], 0.0), 0.9);
    let weak = rules(&[(&[("d", "near")], 0.9, true), (&[("d", "mid")], 0.1, false)]);
    assert!(approx(fz_infer(s, &weak, &[("d", F(2.2))], 0.0), 0.25 * 0.9 + 0.75 * 0.1));
}

#[test]
fn difficulty_scales_skill_and_choice() {
    assert!(approx(fz_scale(k(), 0.8, Hard, Kind::Skill), 0.8));
    assert!(approx(fz_scale(k(), 0.8, Easy, Kind::Skill), 0.24));
    assert!(approx(fz_scale(k(), 0.1, Easy, Kind::Choice), 0.38));
}

fn ch(r: &FzRules, feats: &[(&str, Num)], d: duel_sim::components::Difficulty, kind: Kind) -> f32 {
    fz_chance(k(), r, feats, d, kind, 0.0)
}

#[test]
fn rule_bases_read_as_intended() {
    let k = k();
    assert!(ch(&k.fz_as_now, &[("ons", I(1)), ("press", F(0.2))], Hard, Kind::Choice) > 0.9); // (the read against an NS)
    assert!(ch(&k.fz_as_now, &[("ons", I(0)), ("press", F(0.2))], Hard, Kind::Choice) < 0.3);
    assert_eq!(ch(&k.fz_ns_turn, &[("ona", I(0)), ("ownsa", I(0)), ("d", F(1.0))], Hard, Kind::Skill), 0.0); // (no turn without a cue)
    assert!(ch(&k.fz_ns_turn, &[("ona", I(1)), ("ownsa", I(0)), ("d", F(1.0))], Hard, Kind::Skill) > 0.8);
    assert!(ch(&k.fz_kikon, &[("ored", I(1))], Normal, Kind::Skill) > ch(&k.fz_kikon, &[("ored", I(0))], Normal, Kind::Skill)); // (red Kikons)
    assert_eq!(ch(&k.fz_cancel, &[("red", I(1))], Hard, Kind::Skill), 0.0); // (no cancel while red)
    let hoho = [("margin", F(-0.5)), ("frames", I(4))];
    assert!(ch(&k.fz_hoho, &hoho, Easy, Kind::Skill) < ch(&k.fz_hoho, &hoho, Hard, Kind::Skill));
}

/// The shipped rule bases at cue points between their sets, bit for bit against the native image.
#[test]
fn rule_bases_match_the_native_image() {
    let k = k();
    type Case<'a> = (&'a FzRules, &'a [(&'a str, Num)], duel_sim::components::Difficulty, Kind, f32);
    let cases: [Case; 11] = [
        (&k.fz_as_now, &[("ons", I(0)), ("ored", I(0)), ("press", F(0.4))], Normal, Kind::Choice, 0.35533333),
        (&k.fz_as_now, &[("ons", I(0)), ("ored", I(1)), ("press", F(0.75))], Easy, Kind::Choice, 0.59000003),
        (&k.fz_hoho, &[("margin", F(0.05)), ("frames", I(11))], Normal, Kind::Skill, 0.11366667),
        (&k.fz_hoho, &[("margin", F(0.9)), ("frames", I(0))], Hard, Kind::Skill, 0.1),
        (&k.fz_ns_turn, &[("ona", I(1)), ("d", F(2.1)), ("ownsa", I(1))], Easy, Kind::Skill, 0.18937503),
        (&k.fz_ns_turn, &[("ona", I(0)), ("d", F(1.9)), ("ownsa", I(1))], Hard, Kind::Skill, 0.5),
        (&k.fz_ns_cont, &[("hit", I(0)), ("d", F(3.7))], Hard, Kind::Choice, 0.475),
        (&k.fz_kikon, &[("ored", I(0)), ("lead", I(-1))], Normal, Kind::Skill, 0.27899998),
        (&k.fz_kikon, &[("ored", I(0)), ("lead", I(0))], Normal, Kind::Skill, 0.217),
        (&k.fz_burst, &[("hits", I(3)), ("red", I(0))], Hard, Kind::Skill, 0.35),
        (&k.fz_cancel, &[("red", I(0))], Easy, Kind::Skill, 0.285),
    ];
    for (i, (r, f, d, kind, want)) in cases.into_iter().enumerate() {
        assert_eq!(ch(r, f, d, kind), want, "case {i}");
    }
}

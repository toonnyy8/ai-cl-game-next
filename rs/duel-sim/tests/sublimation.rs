//! Port of tests/duel-rules/sublimation.lisp (one assert per Lisp `(check …)`, same expected values; PORTED.md), plus checks of
//! gauges.lisp's writers no trace reaches yet (Task 9): Burst Reverse, the awakening, GAUGE-SYSTEM's GUARD BACK and EVOLUTION.
use duel_data::Data;
use duel_sim::components::{Burst, Character, Form, Gauges, State};
use duel_sim::gauges::*;
use duel_sim::kit::{find_kit, kit_core_move, kit_move, kit_next, Role};
use duel_sim::knobs::Knobs;
use duel_sim::rules::{awaken_overflow, hit_damage, sub_attack_gain, sub_frac, sub_taken_mods, AtkMods, DefMods};
use duel_sim::state::Match;
use std::sync::OnceLock;

fn data() -> &'static Data {
    static D: OnceLock<Data> = OnceLock::new();
    D.get_or_init(Data::embedded)
}
fn k() -> Knobs {
    Knobs::from(data()).unwrap()
}
/// core.lisp `~=` (eps 1e-3).
fn ap(a: f32, b: f32) -> bool {
    (a - b).abs() < 1e-3
}

#[test]
fn sublimation_knobs_and_fill() {
    let k = &k();
    // 4: the knobs
    assert!(ap(k.sub_dmg, 0.20) && ap(k.sub_taken, 0.20) && ap(k.sub_speed, 0.10) && ap(k.sub_fs, 0.30) && ap(k.sub_keep, 0.5) && ap(k.drive_add, 0.5));
    // (5: `*DRIVE-SWITCH*` unbound: not ported, Knobs has no such field)
    let ov = |a: bool, aw, sub, dr, x, xs| awaken_overflow(k, a, aw, sub, dr, x, xs);
    let (aw, sub, dr) = ov(false, 50.0, 0.0, 0.0, 20.0, 5.0);
    assert!(ap(aw, 70.0) && ap(sub, 0.0) && ap(dr, 0.0)); // 7
    let (aw, sub, dr) = ov(false, 90.0, 0.0, 0.0, 25.0, 25.0);
    assert!(ap(aw, 100.0) && ap(sub, 0.0) && ap(dr, 0.0)); // 8: the overflow is dropped
    let (aw, sub, dr) = ov(false, 100.0, 30.0, 0.0, 10.0, 0.0);
    assert!(ap(aw, 100.0) && ap(sub, 30.0) && ap(dr, 0.0)); // 9: taken, nothing
    let (aw, sub, dr) = ov(false, 100.0, 30.0, 0.0, 10.0, 6.0);
    assert!(ap(aw, 100.0) && ap(sub, 36.0) && ap(dr, 0.0)); // 10
    let (_, sub, dr) = ov(false, 100.0, 95.0, 0.0, 10.0, 10.0);
    assert!(ap(sub, 100.0) && ap(dr, 0.0)); // 11
    let (aw, sub, dr) = ov(true, 0.0, 0.0, 0.0, 12.0, 0.0);
    assert!(ap(aw, 0.0) && ap(sub, 0.0) && ap(dr, 0.0)); // 12
    let (aw, sub, dr) = ov(true, 0.0, 0.0, 0.0, 12.0, 12.0);
    assert!(ap(aw, 0.0) && ap(sub, 0.0) && ap(dr, 12.0)); // 13
    let (_, _, dr) = ov(true, 0.0, 0.0, 95.0, 12.0, 12.0);
    assert!(ap(dr, 100.0)); // 14
    assert!(ap(k.sub_gain, 1.0)); // 17
    let xs = sub_attack_gain(k, 100, 0, 1.0); // 18
    let (_, _, d1) = ov(true, 0.0, 0.0, 0.0, 0.0, xs);
    let (_, sub1, _) = ov(false, 100.0, 0.0, 0.0, 0.0, xs);
    assert!(ap(d1, xs) && ap(sub1, xs));
}

/// 25-30: AW-FULL latched by AWAKEN-FILL!, kept after; an awakened fighter counts; a gauge set full directly counts through AW-FULL-P.
#[test]
fn aw_full() {
    let k = &k();
    let mut g = Gauges::new(k);
    assert!(!aw_full_p(k, &g)); // 25
    awaken_fill(k, &mut g, 60.0, 0.0);
    assert!(!g.aw_full); // 26
    awaken_fill(k, &mut g, 60.0, 0.0);
    assert!(g.aw_full && aw_full_p(k, &g) && ap(g.awaken, k.awaken_max)); // 27
    g.awaken = 0.0;
    assert!(g.aw_full && aw_full_p(k, &g)); // 28: kept after it drops
    let mut g = Gauges::new(k);
    g.awakened = true;
    assert!(aw_full_p(k, &g)); // 29
    awaken_fill(k, &mut g, 0.0, 0.0);
    assert!(g.aw_full); // 29
    let mut g = Gauges::new(k);
    g.awaken = k.awaken_max;
    assert!(aw_full_p(k, &g) && !g.aw_full); // 30
}

#[test]
fn attacking_fraction_boosts() {
    let k = &k();
    // 32: 0.035 x 1.5 per point, ORANGE x1.5 on top, 10.5 per Konpaku taken
    let per = 100.0 / sub_attack_gain(k, 1, 0, 1.0);
    assert!(
        ap(k.sub_attack_mult, 1.5) && ap(sub_attack_gain(k, 100, 0, 1.0), 5.25) && ap(sub_attack_gain(k, 100, 0, k.orange_gain), 7.875)
            && ap(sub_attack_gain(k, 0, 2, 1.0), 21.0) && 1904.0 < per && per < 1906.0
    );
    // 35, 36: the bonus fraction
    let sf = |a, s, ss, d| sub_frac(k, a, s, ss, d);
    assert!(ap(sf(false, 0.0, 0.0, 0.0), 0.0) && ap(sf(false, 60.0, 0.0, 0.0), 0.6) && ap(sf(false, 100.0, 0.0, 0.0), 1.0));
    assert!(
        ap(sf(true, 0.0, 1.0, 0.0), 0.5) && ap(sf(true, 0.0, 1.0, 100.0), 1.0) && ap(sf(true, 0.0, 0.4, 100.0), 0.7)
            && ap(sf(true, 0.0, 0.0, 0.0), 0.0) && ap(sf(true, 0.0, 0.0, 100.0), 0.5)
    );
    // 39: the boosts at a full gauge
    let d = |x| DefMods { mult: x };
    assert!(ap(sub_taken_mods(k, d(1.0), 1.0).mult, 0.8) && ap(sub_taken_mods(k, d(1.15), 0.5).mult, 1.15 * 0.9) && sub_taken_mods(k, d(1.0), 0.0).mult == 1.0);
    // 42: 100 x 1.2 x 0.8 = 96
    let atk = AtkMods { mult: 1.0 * (1.0 + k.sub_dmg * 1.0), ..AtkMods::default() };
    assert_eq!(hit_damage(k, 100, atk, sub_taken_mods(k, d(1.0), 1.0), 1, false, false), 96);
}

/// 45-53: Ichigo's pointers, the original tables.
#[test]
fn ichigo_pointers() {
    let d = data();
    let (b, kk) = (find_kit(d, "ichigo", "base"), find_kit(d, "ichigo", "kessa"));
    // 45 (:locks null in both): structural, duel_data's Core has no such key and denies unknown ones
    assert_eq!(b.core.as_by_press.as_deref(), Some(&[1, 1, 2, 2, 3][..])); // 46
    assert_eq!(kk.core.as_by_press.as_deref(), Some(&[1, 1, 2, 2, 3][..])); // 47
    assert!(kk.core.ns.len() == 3 && kk.core.as_segs.len() == 3); // 48
    assert!(std::ptr::eq(kit_core_move(d, kk, Role::Ns, 2).unwrap(), kit_move(d, kk, "ic-k-n2a").unwrap())); // 49
    assert_eq!(kit_move(d, kk, "ic-k-n2c").unwrap().callout.as_deref(), Some("GETSUGA TENSHO")); // 50
    assert!(!b.hooks.contains_key("link-ok")); // 51
    assert!(!kk.hooks.contains_key("link-ok")); // 52
    assert!(kit_next(d, kk, "ic-k-j3", "q").is_none()); // 53
}

fn pair(a: Character, b: Character) -> Match {
    let mut m = Match::new(data());
    m.picks = [a, b];
    duel_sim::flow::spawn_pair(&mut m, true, true);
    m.log_on = true;
    m
}

/// BURST! (WHITE) / BURST-STEP / BURST-END!: nothing spent, the gauge drains *BURST-DRAIN* / 60 a frame, WHITE heals by whole points
/// crossed, the end restarts the regen delay; the hitstop and the log lines.
#[test]
fn white_burst_runs_out() {
    let mut m = pair(Character::Kenpachi, Character::Ichigo);
    let a = m.p1;
    let g = m.gauges.get_mut(a).unwrap();
    (g.fs, g.reishi) = (2.0, 100.into());
    burst(&mut m, a, Burst::White);
    let g = m.gauges.get(a).unwrap();
    assert_eq!((g.burst, g.burst_t, g.burn, m.time.hitstop), (Some(Burst::White), 0, m.knobs.fs_max, 8));
    assert_eq!(m.log.last().unwrap(), "[     0] P1 BURST WHITE fs 2.0");
    burst_step(&mut m, a); // frame 1: 0.9 drained; 70/s → 1 point on frame 1 (floor 70/60)
    let g = m.gauges.get(a).unwrap();
    assert_eq!((g.burst_t, g.reishi.int()), (1, Some(101)));
    assert!(ap(g.fs, 1.1));
    burst_step(&mut m, a);
    burst_step(&mut m, a); // 2.0 - 2.7 → 0: the end
    let g = m.gauges.get(a).unwrap();
    assert_eq!((g.burst, g.burst_t, g.burn, g.fs_idle, g.fs), (None, 0, 0.0, 0, 0.0));
    assert_eq!(m.log.last().unwrap(), "[     0] P1 BURST END WHITE fs 0.0");
    assert!(!g.aw_full && g.awaken > 0.0); // the awakening gauge filled by 1.4/60 a frame
}

/// BURST! BLUE breaks free (REPEL!): neutral, invulnerable, the opponent's move ends and he slides; ORANGE: *CHAIN-WINDOW*, his combo's
/// scaling restarts.
#[test]
fn blue_and_orange() {
    let mut m = pair(Character::Kenpachi, Character::Ichigo);
    let (a, b) = (m.p1, m.p2);
    m.fighter.get_mut(a).unwrap().state = State::GuardHit;
    m.fighter.get_mut(b).unwrap().state = State::Step;
    burst(&mut m, a, Burst::Blue);
    let (fa, fb) = (m.fighter.get(a).unwrap(), m.fighter.get(b).unwrap());
    assert_eq!((fa.state, fa.invuln, fb.state), (State::Idle, m.knobs.burst_invuln, State::Idle));
    let mo = m.motion.get(b).unwrap();
    assert!(mo.kb[0] > 0.0 && mo.kb_left == m.knobs.burst_push_frames); // P2 (at +x) slides away
    assert_eq!(m.gauges.get(a).unwrap().burn, m.knobs.blue_burn);
    let mut m = pair(Character::Kenpachi, Character::Ichigo);
    let (a, b) = (m.p1, m.p2);
    m.fighter.get_mut(b).unwrap().combo_hits = 4;
    burst(&mut m, a, Burst::Orange);
    assert_eq!((m.fighter.get(a).unwrap().chain, m.fighter.get(b).unwrap().combo_from), (m.knobs.chain_window, 4));
}

/// AWAKEN!: the regen (333 f), SUBLIMATION frozen, the awakened form and its meter's :start, *AWAKEN-HEAL*; the kit's cinematic
/// starts (both actors in :cine), and both are idle once it ends.
#[test]
fn awaken_into_nozarashi() {
    let mut m = pair(Character::Kenpachi, Character::Ichigo);
    let a = m.p1;
    let g = m.gauges.get_mut(a).unwrap();
    (g.sub, g.awaken, g.reishi, g.meter_idle) = (60.0, 100.0, 1000.into(), 5);
    awaken(&mut m, a);
    let (g, f) = (m.gauges.get(a).unwrap(), m.fighter.get(a).unwrap());
    assert_eq!((g.awake_regen, g.awakened, g.awaken, f.form), (333, true, 0.0, Form::Nozarashi));
    assert!(ap(g.sub_s, 0.6));
    assert_eq!((g.meter, g.meter_idle), (0.0, 0)); // NOME's :start 0 still writes
    assert_eq!(g.reishi, (1000 + (0.2f32 * g.reishi_max as f32).round_ties_even() as i64).min(g.reishi_max));
    assert!(m.log.iter().any(|l| l.ends_with("P1 form NOZARASHI")));
    let c = m.cine.as_ref().map(|c| (c.name.lisp(), c.len, c.a, c.v));
    assert_eq!((m.unported, c), (None, Some(("KEN-NOZARASHI-CINE", 108, a, m.p2))));
    assert!([a, m.p2].iter().all(|&e| m.fighter.get(e).unwrap().state == duel_sim::components::State::Cine));
    while m.cine.is_some() {
        duel_sim::cine::cine_step(&mut m, &mut duel_sim::look::NoLook);
    }
    assert!([a, m.p2].iter().all(|&e| m.fighter.get(e).unwrap().state == duel_sim::components::State::Idle)); // (its :after)
}

/// GAUGE-SYSTEM: a full guard gauge ends guardless (GUARD BACK); EVOLUTION once at a full awakening gauge, its tick kept.
#[test]
fn gauge_system_guard_back_evolution() {
    let mut m = pair(Character::Kenpachi, Character::Kenpachi);
    m.match_tick = 77;
    let a = m.p1;
    let gg = m.knobs.gg_max;
    let g = m.gauges.get_mut(a).unwrap();
    (g.guardless, g.gg, g.awaken) = (true, gg, 100.0);
    gauge_system(&mut m);
    let g = m.gauges.get(a).unwrap();
    assert!(!g.guardless && g.evolution && g.evo_t == 77);
    assert_eq!(m.log, ["[    77] P1 GUARD BACK", "[    77] P1 EVOLUTION"]);
    assert!(drain_guard(&mut m, a, 9999.0, "BLOCK"));
    assert_eq!(m.log.last().unwrap(), "[    77] P1 GUARDLESS BLOCK");
    assert_eq!(m.unported, None);
}

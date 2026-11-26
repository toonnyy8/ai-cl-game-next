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
    // lines 4-13: the guard lock
    use duel_sim::components::Phase as P;
    use State::*;
    let gl = |was, cl, st, ph, sf, s, a, r, t, more| guard_locked_p(GuardHit, was, cl, st, ph, sf, s, a, r, t, more);
    assert!(gl(false, 0, Move, Some(P::Main), 20, 10, 3, 12, true, true));
    assert!(!gl(false, 0, Move, Some(P::Main), 24, 10, 3, 12, true, true));
    assert!(!gl(false, 0, Move, Some(P::Main), 20, 10, 3, 12, true, false));
    assert!(!gl(false, 0, Move, Some(P::Main), 20, 10, 3, 12, false, true));
    assert!(!gl(true, 0, Idle, None, 0, 0, 0, 0, false, false));
    assert!(!gl(true, 0, Step, None, 0, 0, 0, 0, false, false));
    assert!(
        gl(true, 0, Move, Some(P::Main), 3, 10, 3, 12, true, false)
            && gl(true, 0, Move, Some(P::Hold), 0, 10, 3, 12, true, false)
            && gl(true, 0, Move, Some(P::Main), 12, 10, 3, 12, true, false)
            && !gl(true, 0, Move, Some(P::Main), 13, 10, 3, 12, true, false)
    );
    assert!(gl(true, 5, Idle, None, 0, 0, 0, 0, false, false) && !gl(true, 5, Step, None, 0, 0, 0, 0, false, false));
    // line 53: no live move has :x-axis / :reflectable (the Kenpachi / Ichigo / Hisagi / Yamamoto kits' moves)
    let d = Data::embedded();
    for forms in d.kits.kits.values() {
        for kit in forms.values() {
            for id in &kit.moves {
                let m = d.moves.iter().find(|m| &m.id == id).unwrap();
                assert!(!m.flags.iter().any(|f| f == "x-axis" || f == "reflectable"), "{id}");
            }
        }
    }
}

/// RESOLVE-CONTACT's keys at their Lisp defaults (IN-FRONT T).
fn ck() -> ContactKeys {
    ContactKeys { in_front: true, ..Default::default() }
}

#[test]
fn triangle_clash_matrix() {
    use DefState::*;
    let k = &k();
    let rc = resolve_contact;
    let c = ck();
    assert_eq!(rc(Neutral, c), Some(Res::Hit));
    assert_eq!(rc(Guard, c), Some(Res::Blocked));
    assert_eq!(rc(Guard, ContactKeys { in_front: false, ..c }), Some(Res::Hit));
    assert_eq!(rc(Guard, ContactKeys { breaker: true, ..c }), Some(Res::GuardBreak));
    assert_eq!(rc(Guard, ContactKeys { guard_crush: true, ..c }), Some(Res::GuardBreak));
    assert_eq!(rc(Breaker, c), Some(Res::Counter));
    assert_eq!(rc(Neutral, ContactKeys { breaker: true, ..c }), Some(Res::Hit));
    assert_eq!(rc(Stance, c), Some(Res::Absorbed));
    assert_eq!(rc(Stance, ContactKeys { breaker: true, ..c }), Some(Res::StanceBreak));
    assert_eq!(rc(StanceIn, c), Some(Res::Counter));
    assert_eq!(rc(StanceIn, ContactKeys { breaker: true, ..c }), Some(Res::StanceBreak));
    assert_eq!(rc(Invuln, ContactKeys { breaker: true, ..c }), None);
    // line 39: Bankai West's ward
    let w = ContactKeys { ward: true, ..c };
    let back = ContactKeys { in_front: false, ..c };
    assert!(
        rc(Guard, ContactKeys { ward: true, ..back }) == Some(Res::Blocked)
            && rc(Guard, back) == Some(Res::Hit)
            && rc(Guard, ContactKeys { hazard: true, ward: true, ..back }) == Some(Res::Blocked)
            && rc(Guard, ContactKeys { breaker: true, ward: true, ..back }) == Some(Res::GuardBreak)
            && rc(Guard, ContactKeys { guard_crush: true, ..w }) == Some(Res::GuardBreak)
            && rc(Guard, ContactKeys { unguardable: true, ..w }) == Some(Res::Hit)
            && rc(Parry, ContactKeys { hazard: true, ..w }) == Some(Res::Blocked)
            && rc(Parry, ContactKeys { hazard: true, ..c }) == Some(Res::Hit)
            && rc(Parry, w) == Some(Res::Parried)
            && rc(Parry, ContactKeys { unguardable: true, ..w }) == Some(Res::Hit)
            && rc(Invuln, w).is_none()
    );
    // line 50: the melee / ranged split
    assert!(
        ranged_hit_p(true, false, None, 0.0)
            && !ranged_hit_p(false, false, None, 100.0)
            && ranged_hit_p(false, true, None, 1.0)
            && !ranged_hit_p(false, true, Some(3.4), 3.4 * 3.4)
            && ranged_hit_p(false, true, Some(3.4), 3.5 * 3.5)
    );
    // lines 55-57: the contact rule
    use Res as R;
    assert!([R::Hit, R::Counter, R::GuardBreak, R::StanceBreak, R::Kikon].iter().all(|&r| contact_of(Some(r)) == H));
    assert!([R::Blocked, R::Armored, R::Absorbed, R::Parried].iter().all(|&r| contact_of(Some(r)) == B));
    assert_eq!(contact_of(None), None);
    // lines 59-69: the Breaker's phases
    use duel_sim::components::Phase as P;
    assert!(breaker_clash_p(k, Some(P::Dash), Some(P::Strike), 2.5));
    assert!(!breaker_clash_p(k, Some(P::Dash), Some(P::Aura), 1.0));
    assert!(!breaker_clash_p(k, Some(P::Dash), Some(P::Dash), 3.5));
    let bn = |p, f, h, d| breaker_next_phase(k, p, f, h, d);
    assert!(bn(P::Aura, 11, true, 9.0) == P::Aura && bn(P::Aura, 12, true, 9.0) == P::Dash);
    assert_eq!(bn(P::Dash, 20, true, 9.0), P::Dash);
    assert_eq!(bn(P::Dash, 1, true, 0.9), P::Strike);
    assert_eq!(bn(P::Dash, 5, false, 9.0), P::Dash);
    assert_eq!(bn(P::Dash, 12, false, 9.0), P::Strike);
    assert_eq!(bn(P::Dash, 45, true, 9.0), P::Strike);
    assert!(ap(breaker_speed(k, 0), 9.0) && ap(breaker_speed(k, 45), 10.0));
    // line 79
    assert!(k.breaker_trigger > 0.9 && k.breaker_reach + 0.34 > k.breaker_trigger);
}

#[test]
fn block_whiff_advantage() {
    let k = &k();
    // lines 105-115: the follow-up's chase (STRING-CHASE-SPEED's cap defaults to *CHASE-MAX*)
    let sc = |d, r, l| string_chase_speed(k, d, r, l, k.chase_max);
    let g = k.lunge_stop.max(2.6 - k.chase_margin);
    assert!(ap(sc(g + 1.4, 2.6, 7), 60.0 * (1.4 / 7.0)));
    assert!(ap(sc(20.0, 2.6, 7), k.chase_max));
    assert_eq!(sc(g, 2.6, 7), 0.0);
    assert_eq!(sc(5.0, 2.6, 0), 0.0);
    assert!(sc(3.0, 2.6, 1) / 60.0 <= 3.0 - g);
    assert_eq!(sc(k.lunge_stop, 1.2, 5), 0.0);
    let mut d: f32 = 6.0;
    for left in (1..=14).rev() {
        d -= sc(d, 2.6, left) / 60.0;
    }
    assert!(d <= 2.6 && d >= g - 1e-4);
    // line 116
    assert!(cancel_open_p(9, 9, 24, true) && cancel_open_p(23, 9, 24, true) && !cancel_open_p(24, 9, 24, true) && !cancel_open_p(10, 9, 24, false));
    // lines 188-189: MOVE-END-FRAME
    assert_eq!(move_end_frame(k, 9, 3, 12, Some(18), None, false, None), 30);
    assert!(move_end_frame(k, 9, 3, 12, Some(18), B, false, None) == 24 && move_end_frame(k, 2, 1, 20, Some(26), None, true, None) == 23);
}

#[test]
fn kikon_konpaku_soul_break() {
    use DefState::*;
    use KikonOutcome as O;
    let k = &k();
    let c = ck();
    // line 221
    assert!(burn(30, 50) == 1 && burn(1, 5) == 1 && burn(500, 30) == 470);
    // lines 230-235
    assert_eq!(kikon_outcome(true, Some(Res::Hit), false), Some(O::Follow));
    assert_eq!(kikon_outcome(true, Some(Res::Counter), false), Some(O::Follow));
    assert_eq!(kikon_outcome(false, Some(Res::Hit), true), Some(O::Kikon));
    assert_eq!(kikon_outcome(true, Some(Res::Hit), true), Some(O::Kikon));
    assert_eq!(kikon_outcome(false, Some(Res::Hit), false), None);
    let rest = [Res::Blocked, Res::Armored, Res::Absorbed, Res::Parried, Res::GuardBreak];
    assert!(rest.iter().all(|&r| kikon_outcome(true, Some(r), false).is_none() && kikon_outcome(true, Some(r), true).is_none()));
    assert!(kikon_outcome(true, None, false).is_none() && kikon_outcome(true, None, true).is_none());
    // line 240
    assert!(
        k.kikon_follow_gap == 24
            && k.kikon_follow_stun + 1 + k.kikon_follow_gap == 41
            && kikon_follow_wait(k, 6) == k.kikon_follow_stun + 1 + k.kikon_follow_gap - 6
            && kikon_follow_wait(k, 99) == 0
            && ap(k.kikon_follow_kb, 2.5)
    );
    // line 245
    use duel_sim::components::Phase as P;
    let kl = |st, f, ph, ct, sf| kikon_lock_p(st, f, Some(ph), ct, sf, 8, 3);
    assert!(
        kl(State::Move, true, P::Follow, None, 0)
            && kl(State::Move, true, P::Main, None, 10)
            && !kl(State::Move, true, P::Main, H, 10)
            && !kl(State::Move, true, P::Main, B, 9)
            && !kl(State::Move, true, P::Main, None, 11)
            && !kl(State::Move, false, P::Follow, None, 0)
            && !kl(State::Move, false, P::Main, None, 2)
            && !kl(State::Idle, true, P::Follow, None, 0)
            && !kl(State::Stun, true, P::Main, None, 2)
    );
    // lines 250-251
    assert!(!kikon_follow_unguardable_p(false) && kikon_follow_unguardable_p(true));
    let ug = |r| ContactKeys { unguardable: kikon_follow_unguardable_p(r), ..c };
    assert!(
        resolve_contact(Guard, ug(false)) == Some(Res::Blocked)
            && resolve_contact(Guard, ug(true)) == Some(Res::Hit)
            && resolve_contact(Stance, ug(true)) == Some(Res::Hit)
            && resolve_contact(Parry, ug(true)) == Some(Res::Hit)
            && resolve_contact(Invuln, ug(true)).is_none()
    );
    // line 262
    assert!(
        ap(kikon_follow_speed(k, 4.6, 10, 99.0), 18.0)
            && ap(kikon_follow_speed(k, 4.6, 10, 12.0), 12.0)
            && ap(kikon_follow_speed(k, 1.0, 10, 99.0), 0.0)
            && ap(kikon_follow_speed(k, 4.6, 0, 99.0), 99.0)
    );
    // lines 265-271
    let u = ContactKeys { unguardable: true, ..c };
    assert_eq!(resolve_contact(Guard, c), Some(Res::Blocked));
    assert_eq!(resolve_contact(Guard, u), Some(Res::Hit));
    assert_eq!(resolve_contact(Guard, ContactKeys { unguardable: false, ..c }), Some(Res::Blocked));
    assert_eq!(resolve_contact(Stance, u), Some(Res::Hit));
    assert_eq!(resolve_contact(StanceIn, u), Some(Res::Hit));
    assert_eq!(resolve_contact(Invuln, u), None);
    assert_eq!(resolve_contact(Breaker, u), Some(Res::Counter));
    // line 275
    let nx = |ph, f, d, dm| kikon_rush_next_phase(k, ph, f, d, 5, dm);
    assert!(
        nx(P::Aura, 4, 9.0, 22) == P::Aura
            && nx(P::Aura, 5, 9.0, 22) == P::Dash
            && nx(P::Aura, 5, k.kikon_trigger, 22) == P::Strike
            && nx(P::Dash, 3, 9.0, 22) == P::Dash
            && nx(P::Dash, 3, k.kikon_trigger - 0.1, 22) == P::Strike
            && nx(P::Dash, 22, 9.0, 22) == P::Strike
            && nx(P::Aura, 5, 9.0, 0) == P::Strike
    );
    // line 278
    assert!(ap(kikon_rush_reach(k, 36.0, 14), 10.0) && ap(kikon_rush_reach(k, 13.0, 36), 9.4) && ap(kikon_rush_reach(k, 18.0, 30), 10.6));
    // line 281
    assert!(
        resolve_contact(Armor, c) == Some(Res::Armored)
            && resolve_contact(Armor, ContactKeys { in_front: false, ..c }) == Some(Res::Armored)
            && resolve_contact(Armor, ContactKeys { breaker: true, ..c }) == Some(Res::Hit)
            && resolve_contact(Armor, u) == Some(Res::Hit)
    );
    // line 290
    assert!(soul_break_p(0) && !soul_break_p(1));
    // line 319
    let (ax, az, bx, bz) = reset_placement(k, 10.0, 0.0, 12.0, 0.0);
    assert!(ap(ax, -4.0) && ap(az, 0.0) && ap(bx, 4.0) && ap(bz, 0.0));
}

#[test]
fn gauges() {
    use Burst::*;
    use State::*;
    let k = &k();
    let cg = |n| combo_gain_mult(k, n);
    assert!(ap(1.0, cg(1)) && ap(1.0, cg(0)) && ap(1.1, cg(2)) && ap(1.5, cg(6)) && ap(2.0, cg(11)) && ap(2.0, cg(30)));
    let (fs, aw, _) = hit_gains(k, 500, 0, false, 1.0, 1);
    let (ft, _, _) = hit_gains(k, 0, 100, false, 1.0, 6);
    assert!(ap(ft, 20.25) && fs == 0.0 && aw > 0.0);
    assert!(ap(awakening_gain(k, 100, 100, 1), 18.9));
    assert!(ap(k.awaken_dealt, 0.035) && ap(k.awaken_taken, 0.049) && ap(k.awaken_per_konpaku, 10.5));
    assert!(ap(gauge_add(290.0, 20.0, 300.0), 300.0) && ap(gauge_add(5.0, -10.0, 300.0), 0.0));
    let ha = |st, fs, lo, b| hoho_allowed_p(st, fs, lo, b, k.fs_hoho);
    assert!(ha(false, 100.0, 0, None) && !ha(true, 300.0, 0, None) && !ha(false, 300.0, 10, None) && !ha(false, 99.0, 0, None));
    let aa = |f, g, u| awaken_allowed_p(k, f, g, u);
    assert!(aa(true, 100.0, false) && !aa(true, 100.0, true) && !aa(false, 100.0, false) && !aa(true, 99.0, false));
    assert!([Idle, Guard, GuardHit, Stun, Air, Down, Wakeup, Move, Step, Run].iter().all(|&s| awaken_state_ok_p(s, false, false)));
    assert!([Hoho, Cine, Intro, Win, Lose].iter() /* (NIL: a fighter's state is never NIL in the port) */.all(|&s| !awaken_state_ok_p(s, false, false)));
    assert!([Idle, Stun, Air, Move, Down].iter().all(|&s| !awaken_state_ok_p(s, true, false)));
    assert!([Idle, Stun, Air, Move, Down].iter().all(|&s| !awaken_state_ok_p(s, false, true)));
    assert!(aa(awaken_state_ok_p(Stun, false, false), 100.0, false) && !aa(awaken_state_ok_p(Stun, false, false), 100.0, true));
    let bm = |s, l, h, c| burst_mode(k, s, l, h, c);
    assert!(
        bm(Stun, false, 2, false) == Some(Blue) && bm(Air, false, 3, false) == Some(Blue) && bm(Stun, false, 1, false).is_none()
            && bm(GuardHit, false, 0, false) == Some(Blue)
            && bm(Move, false, 0, true) == Some(Orange) && bm(Move, false, 0, false).is_none()
            && bm(Idle, false, 0, false) == Some(White) && bm(Guard, false, 0, false) == Some(White) && bm(Run, false, 0, false) == Some(White)
            && bm(Step, false, 0, false).is_none() && bm(Hoho, false, 0, false).is_none() && bm(Down, false, 5, false).is_none()
            && bm(Cine, false, 0, false).is_none() && bm(Idle, true, 0, false).is_none() && bm(Stun, true, 5, false).is_none()
    );
    let ba = |m, fs, act| burst_allowed_p(k, m, fs, act);
    assert!(
        ba(Some(White), 100.0, false) && ba(Some(Orange), 100.0, false) && ba(Some(Blue), 100.0, false) && ba(Some(Blue), 300.0, false)
            && !ba(Some(White), 99.9, false) && !ba(Some(Blue), 99.0, false) && !ba(Some(Orange), 70.0, false)
            && !ba(None, 300.0, false) && !ba(Some(White), 300.0, true)
    );
    assert!(k.burst_drain == 54.0 && ap(burst_drain(k, 50.0), 50.0 - 0.9) && ap(burst_drain(k, 0.1), 0.0));
    let frames = |mut fs: f32| (1..).find(|_| { fs = burst_drain(k, fs); fs <= 0.0 }).unwrap();
    assert!((110..=112).contains(&frames(100.0)) && (221..=223).contains(&frames(200.0)) && (332..=334).contains(&frames(300.0)));
    assert!(ap(burst_fs_gain(12.0, None), 12.0) && ap(burst_fs_gain(12.0, Some(White)), 0.0) && ap(burst_fs_gain(15.0, Some(Orange)), 0.0));
    assert!(
        ha(false, 12.0, 0, Some(White)) && ha(false, 0.1, 0, Some(Blue)) && !ha(false, 0.0, 0, Some(Blue))
            && !ha(false, 12.0, 0, None) && !ha(false, 12.0, 5, Some(White)) && !ha(true, 50.0, 0, Some(White))
    );
    let hc = |fs, b, burn| hoho_cost(k, fs, b, burn);
    let fm = k.fs_max;
    assert!(ap(hc(12.0, Some(White), fm), 12.0) && ap(hc(180.0, Some(White), fm), 100.0) && ap(hc(180.0, None, fm), 100.0));
    assert!(k.blue_burn == 100.0 && ap(burst_budget(k, Some(Blue)), 100.0) && ap(burst_budget(k, Some(White)), 300.0) && ap(burst_budget(k, Some(Orange)), 300.0));
    let run = |mut fs: f32, mut burn: f32| {
        for n in 1.. {
            (fs, burn) = burst_burn(k, fs, burn);
            if fs <= 0.0 || burn <= 0.0 {
                return (n, fs, burn);
            }
        }
        unreachable!()
    };
    let r = run(100.0, 100.0);
    assert!((110..=112).contains(&r.0) && r.1 == 0.0 && r.2 <= 0.01);
    let r = run(100.0, 300.0);
    assert!((110..=112).contains(&r.0) && r.1 == 0.0 && (r.2 - 200.0).abs() < 0.01);
    let r = run(300.0, 100.0);
    assert!((111..=113).contains(&r.0) && ap(r.1, 200.0) && r.2 == 0.0);
    let r = run(230.0, 100.0);
    assert!((111..=113).contains(&r.0) && ap(r.1, 130.0) && r.2 == 0.0);
    let r = run(300.0, 300.0);
    assert!((332..=334).contains(&r.0) && r.1 == 0.0);
    let r = run(40.0, 100.0);
    assert!((44..=46).contains(&r.0) && r.1 == 0.0 && ap(r.2, 60.0));
    let r = run(0.5, 100.0);
    assert!(r.1 == 0.0 && ap(r.2, 99.5));
    assert!(
        ap(hc(300.0, Some(Blue), 60.0), 60.0) && ap(hc(300.0, Some(Blue), 100.0), 100.0) && ap(hc(300.0, Some(Blue), 0.5), 0.5)
            && ap(hc(30.0, Some(Blue), 60.0), 30.0) && ap(hc(300.0, Some(Orange), 60.0), 100.0) && ap(hc(300.0, Some(White), fm), 100.0)
    );
    assert!(
        (1..=60).map(|n| burst_heal(n, k.white_reishi)).sum::<i64>() == 70 && (1..=333).map(|n| burst_heal(n, 12.0)).sum::<i64>() == 66
            && burst_heal(5, 12.0) == 1 && burst_heal(4, 12.0) == 0
    );
    assert!(ap(k.white_reishi, 70.0) && ap(k.white_awaken, 1.4));
    let gm = k.gg_max;
    let gr = |g, i, gl, gd, b, m| gg_regen(k, g, i, gl, gd, b, m, gm);
    assert!(ap(gr(50.0, 999, false, false, false, 0.25), 50.0 + (0.25 * k.gg_regen) / 60.0) && ap(gr(50.0, 999, true, false, false, 0.25), 50.0 + k.gg_regen_guardless / 60.0));
    assert!(
        ap(gr(50.0, 0, false, false, true, 1.0), 50.0 + 11.0 / 60.0) && ap(gr(50.0, 0, false, true, true, 1.0), 50.0 + 2.75 / 60.0)
            && ap(gr(50.0, 0, true, false, true, 1.0), 50.0 + 13.0 / 60.0) && ap(gr(99.99, 0, false, true, true, 1.0), 100.0)
            && ap(gr(50.0, 999, false, true, false, 1.0), 50.0)
    );
    assert!(cancel_open_p(12, 10, 30, true) && !cancel_open_p(9, 10, 30, true) && !cancel_open_p(30, 10, 30, true) && !cancel_open_p(12, 10, 30, false));
    let gc = |sf, c| guard_cancel_open_p(k, sf, 21, 4, 24, c, None, None, None);
    assert!(
        k.guard_cancel == 0.75 && !gc(30, H) && gc(31, H) && gc(48, H) && !gc(49, H) && !gc(40, B) && !gc(40, None)
    );
    assert!(
        (ray_room(0.0, 0.0, 1.0, 0.0, 5.0) - 5.0).abs() < 1e-4 && (ray_room(4.0, 0.0, 1.0, 0.0, 5.0) - 1.0).abs() < 1e-4
            && (ray_room(4.0, 0.0, -1.0, 0.0, 5.0) - 9.0).abs() < 1e-4 && ray_room(5.0, 0.0, 1.0, 0.0, 5.0) == 0.0
    );
}

#[test]
fn gauges_2() {
    use Burst::*;
    let k = &k();
    // line 402
    let kw = |x: &duel_sim::knobs::KwInts| ["quick", "flash", "kikon"].map(|n| x.get(n, -1));
    assert!(kw(&k.block_add) == [4, 6, 6] && kw(&k.whiff_add) == [8, 8, 8] && k.block_add.0.len() == 3 && k.whiff_add.0.len() == 3);
    // line 403
    let gc = |sf, s, a, r, c, kind, wh| guard_cancel_open_p(k, sf, s, a, r, c, kind, wh, None);
    let q = Some("quick");
    assert!(
        gc(16, 9, 3, 12, B, q, None) && !gc(15, 9, 3, 12, B, q, None) && gc(27, 9, 3, 12, B, q, None) && !gc(28, 9, 3, 12, B, q, None)
            && gc(19, 9, 3, 12, None, q, Some(20)) && !gc(18, 9, 3, 12, None, q, Some(20))
            && gc(15, 9, 3, 12, H, q, None) && !gc(14, 9, 3, 12, H, q, None)
            && !gc(40, 21, 4, 24, None, Some("sig"), Some(30)) && !gc(40, 21, 4, 24, B, Some("sp"), None)
    );
    // line 408
    let rf = |r, c, w, kind| recovery_frames(k, r, c, w, Some(kind));
    assert!(
        rf(12, B, None, "quick") == 16 && rf(20, B, None, "flash") == 26 && rf(24, B, None, "kikon") == 30 && rf(12, H, None, "quick") == 12
            && rf(12, None, Some(20), "quick") == 28 && rf(20, None, Some(32), "flash") == 40 && rf(30, None, Some(30), "kikon") == 38
            && rf(24, B, None, "sp") == 24 && rf(24, None, Some(30), "sig") == 30
    );
    // line 412
    assert_eq!(move_end_frame(k, 9, 3, 12, Some(20), B, false, q), 28);
    // line 413
    let cut = |s, e| chain_startup_cut(k, s, e);
    assert!(cut(10, 0) == 4 && cut(20, 0) == 8 && cut(2, 0) == 0 && cut(1, 0) == 0 && cut(3, 0) == 1 && cut(12, 2) == 4 && k.chain_window == 12);
    // lines 415-416
    assert!(ap(burst_gain_mult(k, Some(Orange)), 1.5) && ap(burst_gain_mult(k, Some(White)), 1.0) && ap(burst_gain_mult(k, None), 1.0));
    assert!(ap(hit_gains(k, 100, 0, false, 1.5, 1).1, 5.25) && ap(hit_gains(k, 0, 100, false, 1.5, 1).0, hit_gains(k, 0, 100, false, 1.0, 1).0));
    // lines 420-423
    assert!(ap(fs_gain(k, 10.0, None, 0.0), 10.0) && ap(fs_gain(k, 10.0, Some(Blue), 0.5), 0.0) && ap(fs_gain(k, 10.0, None, 1.0), 10.0 * (1.0 + k.sub_fs)));
    assert!(k.kikon_fs_refund == 105.0 && ap(burst_fs_gain(k.kikon_fs_refund, None), 105.0) && ap(burst_fs_gain(k.kikon_fs_refund, Some(White)), 0.0));
    assert!(k.fs_hoho == 100.0 && k.fs_burst == 100.0 && ap(k.fs_taken, 0.135) && k.fs_max == 300.0); // ((boundp '*fs-refund*): no such knob)
    // lines 424-429
    let fr = |f, i| fs_regen(k, f, i, k.fs_regen);
    assert!(ap(fr(50.0, 59), 50.0) && ap(fr(50.0, 60), 50.075) && ap(fr(99.99, 600), 100.0));
    let mut f = 40.0;
    for _ in 0..2000 {
        f = fr(f, 600);
    }
    assert!(ap(f, 100.0));
    assert!(fr(100.0, 600) == 100.0 && fr(180.0, 600) == 180.0 && fr(300.0, 600) == 300.0 && fr(180.0, 0) == 180.0);
    let mut f = 0.0;
    for _ in 0..60 {
        f = fr(f, 60);
    }
    assert!(ap(4.5, f));
    assert!((1333.0 - k.fs_hoho / (k.fs_regen / 60.0)).abs() < 0.5);
    // line 431
    let gv = |kind, adv, o| guard_value(k, kind, adv, o);
    assert!(
        gv(q, Some(-2), None) == 8 && gv(q, Some(-12), None) == 12 && gv(Some("flash"), Some(-4), None) == 14
            && gv(Some("flash"), Some(-14), None) == 18 && gv(Some("sig"), Some(-6), None) == 18 && gv(Some("sig"), Some(-14), None) == 22
            && gv(Some("sp"), Some(-16), None) == 22 && gv(Some("kikon"), Some(-14), None) == 20 && gv(None, None, None) == 12
            && gv(Some("sig"), Some(-6), Some(10)) == 10
    );
    // lines 443-460
    assert_eq!(gg_drain(100.0, 8.0), (92.0, false));
    assert_eq!(gg_drain(5.0, 8.0), (0.0, true));
    assert!(k.gg_delay == 60 && ap(k.gg_regen, 5.5) && ap(k.gg_regen_guardless, 6.5));
    let gm = k.gg_max;
    let gr = |g, i, gl, gd| gg_regen(k, g, i, gl, gd, false, 1.0, gm);
    assert!(ap(gr(50.0, 59, false, false), 50.0) && ap(gr(50.0, 60, false, false), 50.0 + 5.5 / 60.0) && ap(gr(50.0, 60, true, false), 50.0 + 6.5 / 60.0) && ap(gr(99.99, 99, false, false), 100.0));
    let mut g = 0.0;
    let n = (0..).find(|&f| { if g >= gm { return true; } g = gr(g, f, true, false); false }).unwrap();
    assert!((983..=984).contains(&n));
    assert!(ap(gr(50.0, 999, false, true), 50.0) && gg_idle_next(40, true) == 40 && gg_idle_next(40, false) == 41 && gg_idle_next(9999, false) == 9999);
    let mut idle = 0;
    (0..40).for_each(|_| idle = gg_idle_next(idle, false));
    (0..30).for_each(|_| idle = gg_idle_next(idle, true));
    (0..20).for_each(|_| idle = gg_idle_next(idle, false));
    assert_eq!(idle, 60);
    assert_eq!(chip_damage(85, Some(1.0), 50), 49);
    assert!(ap(gr(40.0, 9999, false, true), 40.0) && gg_idle_next(30, true) == 30);
    assert!(can_guard_p(1.0, false) && !can_guard_p(0.0, false) && !can_guard_p(99.0, true));
    // line 464 (463's Kenpachi J1 rides with Task 11), 469
    assert_eq!(k.gg_breaker, 35);
    assert_eq!(k.reishi_max, 1300);
    // lines 473-476
    assert!(seconds_to_frames(10.0) == 600 && ap(timer_fill(300, 600, 100.0), 50.0));
    assert!(stance_store(k, 150, 80) == 200 && stance_store(k, 0, 45) == 45);
    assert_eq!(stance_release(k, 150), (250, true));
    assert_eq!(stance_release(k, 100), (200, false));
}

#[test]
fn combo_limits() {
    use duel_sim::components::Phase::*;
    let k = &k();
    let cs = |r, a, h, l, ah, kb| combo_step(k, r, a, h, l, ah, kb);
    assert_eq!(cs(Launch, false, 0, 0, 0, false), (Launch, 1, 1, 0));
    assert_eq!(cs(Launch, false, 2, 1, 0, false), (Knockback, 3, 1, 0));
    assert_eq!(cs(Flinch, true, 3, 1, 1, false), (Flinch, 4, 1, 2));
    assert_eq!(cs(Flinch, true, 4, 1, 2, false), (Knockdown, 5, 1, 3));
    assert_eq!(cs(Flinch, false, 9, 0, 0, false), (Flinch, 10, 0, 0));
    assert_eq!(cs(Bind, false, 0, 0, 0, false), (Bind, k.burst_min_hits, 0, 0));
    assert_eq!(cs(Bind, false, 3, 0, 0, false), (Flinch, 4, 0, 0));
    assert_eq!(cs(Bind, false, 0, 0, 0, true), (Bind, k.burst_min_hits, 0, 0));
    assert_eq!(cs(Bind, false, 3, 0, 0, true), (Bind, 4, 0, 0));
    assert_eq!(cs(Stagger, false, 3, 0, 0, true), (Stagger, 4, 0, 0));
    assert_eq!(stun_weight(k, "flinch", false), 1);
    assert_eq!(stun_weight(k, "stagger", false), 2);
    assert!(["crumple", "knockback", "launch", "knockdown"].iter().all(|r| stun_weight(k, r, false) == 3));
    assert_eq!(stun_weight(k, "flinch", true), 3);
    assert_eq!(stun_weight(k, "clash", false), 1);
    assert_eq!(stun_add(k, 4.0, "stagger", false), 6.0);
    assert_eq!(stun_decay(k, 10.0, k.stun_delay - 1), 10.0);
    assert!(ap(stun_decay(k, 10.0, k.stun_delay), 10.0 - k.stun_decay / 60.0));
    assert_eq!(stun_decay(k, 0.01, 999), 0.0);
    let mut s = 12.0;
    for i in 0..k.stun_delay + 60 {
        s = stun_decay(k, s, i);
    }
    assert!((s - (12.0 - k.stun_decay)).abs() < 0.05);
    assert!(!stun_over_p(16.0, 16.0) && stun_over_p(16.5, 16.0));
    // stun-tolerance-of per kit (lines 503-508)
    let d = Data::embedded();
    let kit = |c: &str, f: &str| &d.kits.kits[c][f];
    use duel_sim::kit::stun_tolerance_of;
    assert_eq!(stun_tolerance_of(k, kit("ichigo", "base")), 16.0);
    assert_eq!(stun_tolerance_of(k, kit("kenpachi", "base")), 26.0);
    assert_eq!(stun_tolerance_of(k, kit("kenpachi", "bankai")), 26.0);
    assert_eq!(stun_tolerance_of(k, kit("ichigo", "kessa")), 16.0);
    assert!(d.kits.kits.values().flat_map(|f| f.values()).all(|x| stun_tolerance_of(k, x) > 0.0));
    let mut bare = kit("ichigo", "base").clone();
    bare.stun_tolerance = None;
    assert_eq!(stun_tolerance_of(k, &bare), k.stun_tolerance);
    // lines 510, 519: strings to the stun limit
    let (mut s, mut idle, tol, mut strings) = (0.0, 0, 16.0, 0);
    for _ in 0..20 {
        if stun_over_p(s, tol) {
            break;
        }
        strings += 1;
        for r in ["flinch", "flinch", "stagger"] {
            if !stun_over_p(s, tol) {
                s = stun_add(k, s, r, false);
                idle = 0;
                for _ in 0..20 {
                    s = stun_decay(k, s, idle);
                    idle += 1;
                }
            }
        }
        for _ in 0..20 {
            s = stun_decay(k, s, idle);
            idle += 1;
        }
    }
    assert!(stun_over_p(s, tol) && strings <= 5);
    let (mut s, mut idle, mut over) = (0.0, 0, false);
    for _ in 0..20 {
        for r in ["flinch", "flinch", "stagger"] {
            s = stun_add(k, s, r, false);
            idle = 0;
            over = over || stun_over_p(s, 16.0);
        }
        for _ in 0..120 {
            s = stun_decay(k, s, idle);
            idle += 1;
        }
    }
    assert!(!over);
}

#[test]
fn perfect_hoho_facing() {
    use duel_sim::math::{angle_wrap, deg, turn_toward};
    let k = &k();
    // lines 532-540
    let vols: [duel_sim::hitvol::Vol; 1] = [[0.0, 1.4, deg(100.0 / 2.0), -0.5, 2.5, 0.0]]; // (MAKE-VOL :arc: 0 r half-angle y0 y1)
    let perfect = |sf, from, to, z: f32| perfect_hoho_p(k, sf, from, to, &vols, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0, 0.0, z, 0.4, 1.8);
    assert!(perfect(3, 9, 12, -2.0));
    assert!(perfect(0, 9, 12, -2.0));
    assert!(!perfect(0, 13, 16, -2.0));
    assert!(perfect(10, 9, 12, -2.0));
    assert!(!perfect(12, 9, 12, -2.0));
    assert!(perfect(3, 9, 12, -2.2));
    assert!(perfect(3, 9, 12, -2.6));
    assert!(!perfect(3, 9, 12, -3.0));
    // lines 543-568
    assert!(ap(turn_toward(0.0, deg(90.0), deg(18.0)), deg(18.0)));
    assert!(ap(turn_toward(0.0, deg(10.0), deg(18.0)), deg(10.0)));
    assert!(ap(angle_wrap(turn_toward(deg(170.0), deg(-170.0), deg(18.0))), deg(-172.0)));
    assert!(ap(track_step(360.0), deg(6.0)));
    assert!(
        in_front_p(0.0, 0.0, 0.0, deg(95.0).sin(), -deg(95.0).cos(), k.guard_arc)
            && !in_front_p(0.0, 0.0, 0.0, deg(105.0).sin(), -deg(105.0).cos(), k.guard_arc)
    );
    let (to, st) = stick_toward_strafe(0.0, 1.0, 0.0, 0.0, 0.0, 0.0, -5.0);
    assert!(ap(to, 1.0) && ap(st, 0.0));
    let (to, st) = stick_toward_strafe(1.0, 0.0, 0.0, 0.0, 0.0, 0.0, -5.0);
    assert!(ap(to, 0.0) && ap(st, 1.0));
    let (to, st) = stick_toward_strafe(0.0, 1.0, 0.0, 0.0, 0.0, 5.0, 0.0);
    assert!(ap(to, 0.0) && ap(st, -1.0));
    let (dx, dz) = toward_strafe_dir(0.6, 0.8, 1.0, 1.0, 1.0, -4.0);
    let (to, st) = stick_toward_strafe(dx, -dz, 0.0, 1.0, 1.0, 1.0, -4.0);
    assert!(ap(to, 0.6) && ap(st, 0.8));
    let (x, z) = clamp_to_circle(20.0, 0.0, 15.0);
    assert!(ap(x, 15.0) && ap(z, 0.0));
    let (x, z) = clamp_to_circle(3.0, 4.0, 15.0);
    assert!(ap(x, 3.0) && ap(z, 4.0));
    let (x, z, yaw) = hoho_destination(k, 0.0, 0.0, 0.0);
    assert!(ap(x, 0.0) && ap(z, 1.6) && ap(yaw, 0.0));
    assert_eq!(step_direction(0.0, 0.1, -1.0), (-1.0, 0.0));
    assert_eq!(step_direction(0.0, 0.1, 1.0), (1.0, 0.0));
    assert!(!run_stop_p(k, 1.4, 1.0, 8.0) && run_stop_p(k, 1.3, 1.0, 8.0) && !run_stop_p(k, 1.0, -1.0, 8.0) && !run_stop_p(k, 1.25, 0.0, 10.0));
    assert!(ap(run_carry(k, 5.0), 1.0) && ap(run_carry(k, 1.7), 0.5) && ap(run_carry(k, 1.0), 0.0));
    assert!(ap(brake_speed(k, 9.0, 3), 4.5) && ap(brake_speed(k, 9.0, 6), 0.0) && ap(brake_speed(k, 9.0, 9), 0.0));
}

#[test]
fn hit_volumes() {
    use duel_sim::hitvol::*;
    use duel_sim::math::deg;
    let hits = |v: &Vol, x: f32, z: f32, y: f32| vol_hit_p(v, 0.0, 0.0, 0.0, 0.0, -1.0, x, y, z, 0.38, 1.8, 0.0);
    // lines 584-590 (MAKE-VOL: :arc 0 r half-angle y0 y1; :cap 1 a b h r yaw; :sph 2 fwd up r)
    let arc: Vol = [0.0, 2.4, deg(100.0 / 2.0), 0.2, 2.0, 0.0];
    assert!(ap(arc[2], deg(50.0)));
    assert!(hits(&arc, 0.0, -2.0, 0.0));
    assert!(!hits(&arc, 0.0, 2.0, 0.0));
    assert!(!hits(&arc, 0.0, -3.0, 0.0));
    assert!(!hits(&arc, 0.0, -2.0, 3.0));
    assert!(hits(&[1.0, 0.3, 8.0, 1.0, 0.5, 0.0], 0.5, -7.5, 0.0));
    assert!(hits(&[2.0, 2.0, 0.0, 1.0, 0.0, 0.0], 0.0, -2.5, 0.0));
    let yaw = deg(90.0);
    assert!(capsule_cyl_hit_p(0.0, 1.0, 0.0, 0.0, 1.0, -9.0, 0.3, 0.5, 0.0, -5.0, 0.4, 1.8)); // line 592
    assert!(!capsule_cyl_hit_p(0.0, 1.0, 0.0, 0.0, 1.0, -9.0, 0.3, 1.0, 0.0, -5.0, 0.4, 1.8)); // line 593
    assert!(!capsule_cyl_hit_p(0.0, 1.0, 0.0, 0.0, 1.0, -9.0, 0.3, 0.0, 0.0, -10.0, 0.4, 1.8)); // line 594
    assert!(!capsule_cyl_hit_p(0.0, 3.0, 0.0, 0.0, 3.0, -9.0, 0.3, 0.0, 0.0, -5.0, 0.4, 1.8)); // line 595
    assert!(capsule_cyl_hit_p(0.0, 0.5, 0.0, 2.0, 1.5, 0.0, 0.3, 2.5, 0.0, 0.0, 0.4, 1.8)); // line 596
    assert!(capsule_cyl_hit_p(0.0, 1.0, -5.0, 0.0, 1.0, -5.0, 0.5, 0.6, 0.0, -5.0, 0.4, 1.8)); // line 597
    assert!(obox_cyl_hit_p(0.0, 1.0, -5.0, 0.0, 3.0, 1.0, 0.5, 2.5, 0.0, -5.0, 0.4, 1.8)); // line 598
    assert!(!obox_cyl_hit_p(0.0, 1.0, -5.0, 0.0, 3.0, 1.0, 0.5, 3.5, 0.0, -5.0, 0.4, 1.8)); // line 599
    assert!(obox_cyl_hit_p(0.0, 1.0, -5.0, 0.0, 3.0, 1.0, 0.5, 0.0, 0.0, -5.8, 0.4, 1.8)); // line 600
    assert!(!obox_cyl_hit_p(0.0, 1.0, -5.0, 0.0, 3.0, 1.0, 0.5, 0.0, 0.0, -6.0, 0.4, 1.8)); // line 601
    assert!(obox_cyl_hit_p(0.0, 1.0, -5.0, yaw, 3.0, 1.0, 0.5, 0.0, 0.0, -7.5, 0.4, 1.8)); // line 603
    assert!(!obox_cyl_hit_p(0.0, 1.0, -5.0, yaw, 3.0, 1.0, 0.5, 0.0, 0.0, -8.5, 0.4, 1.8)); // line 604
    assert!(!obox_cyl_hit_p(0.0, 1.0, -5.0, 0.0, 3.0, 1.0, 0.5, 0.0, 3.0, -5.0, 0.4, 1.8)); // line 605
    assert!(cyl_cyl_hit_p(3.0, 0.0, 0.0, 0.6, 3.0, 3.8, 0.0, 0.0, 0.4, 1.8)); // line 606
    assert!(!cyl_cyl_hit_p(3.0, 0.0, 0.0, 0.6, 3.0, 4.1, 0.0, 0.0, 0.4, 1.8)); // line 607
    assert!(!cyl_cyl_hit_p(3.0, 0.0, 0.0, 0.6, 3.0, 3.5, 3.5, 0.0, 0.4, 1.8)); // line 608
}

/// core.lisp 118: the Step's and the Hoho's invulnerable frames (*STEP-IFRAMES* (3 9), *HOHO-IFRAMES* (1 14), inclusive).
#[test]
fn iframes() {
    let k = &k();
    let (st, ho) = (Some((k.step_iframes.0, k.step_iframes.1)), Some((k.hoho_iframes.0, k.hoho_iframes.1)));
    assert!(
        invulnerable_frame_p(3, st) && invulnerable_frame_p(9, st) && !invulnerable_frame_p(10, st) && invulnerable_frame_p(14, ho)
            && !invulnerable_frame_p(0, ho)
    );
}

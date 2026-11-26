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

//! port: duel/lisp/rules.lisp — the pure rules (frames, gauges, damage, contact). Types: frames / reishi / konpaku / hits
//! are fixnums (i64); positions, gauges, speeds are single-floats (f32): the sim's callers pass those. Where a Lisp
//! function has a single-float fast path (gauge-add, fs-regen, gg-regen, stun-decay, toward-strafe-dir, red-p) that path is
//! the one ported, bit for bit. CPU-only rules (ai-burst-wanted-p, ai-guard-mult, ai-hoho-spare-p, finish-role) are M2.
use crate::cl::{floor_div, floor_f32, max_f32, min_f32, round_f32};
use crate::components::{Burst, Contact, Phase};
use crate::knobs::Knobs;
use crate::math::{deg, f_cos, f_sqrt, fwd_x, fwd_z, hypot};

// port: rules.lisp DIR-YAW — already math::dir_yaw (Task 2).
pub use crate::math::dir_yaw;

// port: rules.lisp TRACK-STEP
pub fn track_step(deg_per_second: f32) -> f32 {
    deg(deg_per_second / 60.0)
}

// port: rules.lisp CLAMP-TO-CIRCLE
pub fn clamp_to_circle(x: f32, z: f32, r: f32) -> (f32, f32) {
    let d = hypot(x, z);
    if d <= r { (x, z) } else { (x * (r / d), z * (r / d)) }
}

// port: rules.lisp STICK-TOWARD-STRAFE
pub fn stick_toward_strafe(sx: f32, sy: f32, cam_yaw: f32, px: f32, pz: f32, ox: f32, oz: f32) -> (f32, f32) {
    let (fx, fz) = (fwd_x(cam_yaw), fwd_z(cam_yaw));
    let wx = sy * fx + sx * -fz;
    let wz = sy * fz + sx * fx;
    let (ax, az) = (ox - px, oz - pz);
    let d = hypot(ax, az);
    if d < 1e-4 {
        (sy, sx)
    } else {
        let (ux, uz) = (ax / d, az / d);
        (wx * ux + wz * uz, wx * -uz + wz * ux)
    }
}

// port: rules.lisp TOWARD-STRAFE-DIR (its single-float path: WITH-TOWARD-STRAFE-DIR, sqrt of the sum, NaN guard)
pub fn toward_strafe_dir(toward: f32, strafe: f32, px: f32, pz: f32, ox: f32, oz: f32) -> (f32, f32) {
    let (ax, az) = (ox - px, oz - pz);
    let h = f_sqrt(ax * ax + az * az);
    let d = if h.is_nan() || 1e-4 >= h { 1e-4 } else { h };
    let (ux, uz) = (ax / d, az / d);
    (toward * ux + strafe * -uz, toward * uz + strafe * ux)
}

// port: rules.lisp IN-FRONT-P
pub fn in_front_p(yaw: f32, px: f32, pz: f32, ax: f32, az: f32, arc_deg: f32) -> bool {
    let (dx, dz) = (ax - px, az - pz);
    let d = hypot(dx, dz);
    d < 1e-4 || (dx * fwd_x(yaw) + dz * fwd_z(yaw)) / d >= f_cos(deg(arc_deg / 2.0))
}

// port: rules.lisp HOHO-DESTINATION
pub fn hoho_destination(k: &Knobs, ox: f32, oz: f32, oyaw: f32) -> (f32, f32, f32) {
    let (x, z) = clamp_to_circle(ox - k.hoho_distance * fwd_x(oyaw), oz - k.hoho_distance * fwd_z(oyaw), k.arena_radius);
    (x, z, oyaw)
}

// port: rules.lisp RESET-PLACEMENT
pub fn reset_placement(k: &Knobs, ax: f32, az: f32, bx: f32, bz: f32) -> (f32, f32, f32, f32) {
    let (mut dx, mut dz) = (bx - ax, bz - az);
    let d = hypot(dx, dz);
    let h = k.reset_distance / 2.0;
    if d < 1e-3 {
        (dx, dz) = (0.0, 1.0);
    } else {
        (dx, dz) = (dx / d, dz / d);
    }
    (dx * -h, dz * -h, dx * h, dz * h)
}

// port: rules.lisp STEP-DIRECTION (NEUTRAL default -1.0)
pub fn step_direction(toward: f32, strafe: f32, neutral: f32) -> (f32, f32) {
    let m = hypot(toward, strafe);
    if m < 0.3 { (neutral, 0.0) } else { (toward / m, strafe / m) }
}

// port: rules.lisp RUN-STOP-P — (* speed closing (/ 1.0 60)) left to right
pub fn run_stop_p(k: &Knobs, dist: f32, closing: f32, speed: f32) -> bool {
    closing > 0.0 && dist - speed * closing * (1.0f32 / 60.0) < k.run_stop
}

// port: rules.lisp RUN-CARRY
pub fn run_carry(k: &Knobs, dist: f32) -> f32 {
    max_f32(0.0, min_f32(k.run_carry, dist - k.run_stop))
}

// port: rules.lisp BRAKE-SPEED
pub fn brake_speed(k: &Knobs, speed: f32, frame: i64) -> f32 {
    speed * max_f32(0.0, 1.0 - frame as f32 / k.run_brake as f32)
}

/// RESOLVE-CONTACT's defender states.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DefState {
    Invuln,
    Parry,
    Guard,
    Breaker,
    StanceIn,
    Stance,
    Armor,
    Neutral,
}

/// RESOLVE-CONTACT's results (NIL = `None`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Res {
    StanceBreak,
    Parried,
    GuardBreak,
    Blocked,
    Counter,
    Absorbed,
    Hit,
    Armored,
    Kikon,
}

/// RESOLVE-CONTACT's keys (IN-FRONT defaults to T: `Default` gives false, so callers set it).
#[derive(Debug, Clone, Copy, Default)]
pub struct ContactKeys {
    pub breaker: bool,
    pub guard_crush: bool,
    pub in_front: bool,
    pub unguardable: bool,
    pub hazard: bool,
    pub ward: bool,
    pub rend: bool,
}

// port: rules.lisp RESOLVE-CONTACT
pub fn resolve_contact(def_state: DefState, c: ContactKeys) -> Option<Res> {
    use DefState as D;
    let crush = c.breaker || c.guard_crush;
    let state = if def_state == D::Guard && !c.in_front && !c.ward {
        D::Neutral
    } else if c.unguardable && matches!(def_state, D::Guard | D::StanceIn | D::Stance | D::Parry) {
        D::Neutral
    } else if c.hazard && def_state == D::Parry {
        if c.ward { D::Guard } else { D::Neutral }
    } else {
        def_state
    };
    Some(match state {
        D::Invuln => return None,
        D::Parry => if c.breaker { Res::StanceBreak } else { Res::Parried },
        D::Guard => if crush { Res::GuardBreak } else { Res::Blocked },
        D::Breaker => Res::Counter,
        D::StanceIn => if c.breaker || c.rend { Res::StanceBreak } else { Res::Counter },
        D::Stance => if c.breaker || c.rend { Res::StanceBreak } else { Res::Absorbed },
        D::Armor => if c.breaker || c.unguardable || c.rend { Res::Hit } else { Res::Armored },
        D::Neutral => Res::Hit,
    })
}

// port: rules.lisp CONTACT-OF
pub fn contact_of(res: Option<Res>) -> Option<Contact> {
    match res? {
        Res::Hit | Res::Counter | Res::GuardBreak | Res::StanceBreak | Res::Kikon => Some(Contact::Hit),
        _ => Some(Contact::Block),
    }
}

// port: rules.lisp BREAKER-CLASH-P
pub fn breaker_clash_p(k: &Knobs, phase_a: Option<Phase>, phase_b: Option<Phase>, dist: f32) -> bool {
    let ds = |p: Option<Phase>| matches!(p, Some(Phase::Dash) | Some(Phase::Strike));
    ds(phase_a) && ds(phase_b) && dist <= k.clash_range
}

// port: rules.lisp BREAKER-NEXT-PHASE
pub fn breaker_next_phase(k: &Knobs, phase: Phase, frames: i64, held: bool, dist: f32) -> Phase {
    match phase {
        Phase::Aura => if frames >= k.breaker_aura { Phase::Dash } else { Phase::Aura },
        Phase::Dash => {
            if dist <= k.breaker_trigger || frames >= k.breaker_dash_max || (!held && frames >= k.breaker_dash_min) {
                Phase::Strike
            } else {
                Phase::Dash
            }
        }
        p => panic!("BREAKER-NEXT-PHASE: ecase fell through on {p}"),
    }
}

// port: rules.lisp KIKON-RUSH-NEXT-PHASE (keys AURA DASH-MAX)
pub fn kikon_rush_next_phase(k: &Knobs, phase: Phase, frames: i64, dist: f32, aura: i64, dash_max: i64) -> Phase {
    match phase {
        Phase::Aura => {
            if frames < aura {
                Phase::Aura
            } else if dash_max == 0 || dist <= k.kikon_trigger {
                Phase::Strike
            } else {
                Phase::Dash
            }
        }
        Phase::Dash => if dist <= k.kikon_trigger || frames >= dash_max { Phase::Strike } else { Phase::Dash },
        p => panic!("KIKON-RUSH-NEXT-PHASE: ecase fell through on {p}"),
    }
}

// port: rules.lisp PARRY-FRAME-P (WINDOW `None` = *parry-window*)
pub fn parry_frame_p(k: &Knobs, sf: i64, window: Option<(i64, i64)>) -> bool {
    invulnerable_frame_p(sf, Some(window.unwrap_or((k.parry_window.0, k.parry_window.1))))
}

// port: rules.lisp KIKON-RUSH-REACH
pub fn kikon_rush_reach(k: &Knobs, speed: f32, dash_max: i64) -> f32 {
    k.kikon_trigger + speed * (dash_max as f32 / 60.0)
}

// port: rules.lisp BREAKER-SPEED
pub fn breaker_speed(k: &Knobs, frames: i64) -> f32 {
    k.breaker_speed_min + (k.breaker_speed_max - k.breaker_speed_min) * min_f32(1.0, frames as f32 / k.breaker_dash_max as f32)
}

// port: rules.lisp BLOCKSTUN
pub fn blockstun(total: i64, hit_frame: i64, adv: i64) -> i64 {
    1.max(total - hit_frame + adv)
}

// port: rules.lisp MOVE-END-FRAME
#[allow(clippy::too_many_arguments)]
pub fn move_end_frame(k: &Knobs, s: i64, a: i64, r: i64, whiff: Option<i64>, contact: Option<Contact>, hitless: bool, kind: Option<&str>) -> i64 {
    s + a + if hitless { r } else { recovery_frames(k, r, contact, whiff, kind) }
}

// port: rules.lisp HITSTUN (REACT: a hitwin's react keyword name)
pub fn hitstun(k: &Knobs, react: &str, counter: bool) -> i64 {
    k.reaction_frames.get(react, 0) + if counter { k.counter_stun } else { 0 }
}

// port: rules.lisp RECOVERY-FRAMES (KIND: the move's kind name, "" = NIL)
pub fn recovery_frames(k: &Knobs, r: i64, contact: Option<Contact>, whiff: Option<i64>, kind: Option<&str>) -> i64 {
    let kind = kind.unwrap_or("");
    match contact {
        Some(Contact::Block) => r + k.block_add.get(kind, 0),
        Some(Contact::Hit) => r,
        None => whiff.unwrap_or(r + k.whiff_extra) + k.whiff_add.get(kind, 0),
    }
}

// port: rules.lisp CHAIN-OPEN-P
pub fn chain_open_p(k: &Knobs, sf: i64, s: i64, a: i64, r: i64, contact: Option<Contact>) -> bool {
    let total = s + a + r;
    match contact {
        None => false,
        Some(c) => sf < total && if c == Contact::Hit { sf >= s + a } else { sf >= total - k.chain_lead },
    }
}

// port: rules.lisp STRING-CHASE-SPEED (CAP default *chase-max*)
pub fn string_chase_speed(k: &Knobs, d: f32, reach: f32, left: i64, cap: f32) -> f32 {
    let goal = max_f32(k.lunge_stop, reach - k.chase_margin);
    if d > goal && left > 0 { min_f32(cap, 60.0 * ((d - goal) / left as f32)) } else { 0.0 }
}

// port: rules.lisp RAY-ROOM
pub fn ray_room(x: f32, z: f32, ux: f32, uz: f32, r: f32) -> f32 {
    let b = x * ux + z * uz;
    let c = (x * x + z * z) - r * r;
    let disc = b * b - c;
    if c >= 0.0 || disc < 0.0 { 0.0 } else { max_f32(0.0, -b + f_sqrt(disc)) }
}

// port: rules.lisp FIRST-LAND-P
pub fn first_land_p(contact: Option<Contact>, hits: i64) -> bool {
    contact != Some(Contact::Hit) || hits == 0
}

// port: rules.lisp CANCEL-OPEN-P
pub fn cancel_open_p(sf: i64, hit_frame: i64, total: i64, landed: bool) -> bool {
    landed && sf >= hit_frame && sf < total
}

// port: rules.lisp GUARD-CANCEL-OPEN-P (FROM `None` = NIL)
#[allow(clippy::too_many_arguments)]
pub fn guard_cancel_open_p(k: &Knobs, sf: i64, s: i64, a: i64, r: i64, contact: Option<Contact>, kind: Option<&str>, whiff: Option<i64>, from: Option<i64>) -> bool {
    if let Some(from) = from {
        return sf >= from && sf < s + a + r;
    }
    let rec = recovery_frames(k, r, contact, whiff, kind);
    let total = s + a + rec;
    (contact == Some(Contact::Hit) || matches!(kind, Some("quick" | "flash" | "kikon")))
        && sf >= total - floor_f32(rec as f32 * k.guard_cancel)
        && sf < total
}

// port: rules.lisp GUARD-LOCKED-P (STATE / DEF-STATE as fighter states)
#[allow(clippy::too_many_arguments)]
pub fn guard_locked_p(def_state: crate::components::State, was: bool, chain_left: i64, state: crate::components::State, phase: Option<Phase>, sf: i64, s: i64, a: i64, r: i64, touched: bool, more: bool) -> bool {
    use crate::components::State as St;
    def_state == St::GuardHit
        && ((chain_left > 0 && matches!(state, St::Idle | St::Guard))
            || (state == St::Move && ((was && (phase != Some(Phase::Main) || sf < s + a)) || (touched && more && sf + 1 < s + a + r))))
}

// port: rules.lisp INVULNERABLE-FRAME-P
pub fn invulnerable_frame_p(sf: i64, window: Option<(i64, i64)>) -> bool {
    window.is_some_and(|(lo, hi)| lo <= sf && sf <= hi)
}

// port: rules.lisp COMBO-SCALE
pub fn combo_scale(k: &Knobs, n: i64, orange: bool) -> f32 {
    if n <= k.combo_full_hits {
        1.0
    } else {
        let (floor, decay) = if orange { (k.orange_combo_floor, k.orange_combo_decay) } else { (k.combo_floor, k.combo_decay) };
        max_f32(floor, 1.0 - decay * (n - k.combo_full_hits) as f32)
    }
}

// port: rules.lisp HIT-PX (SP-SCALE default 1.0; the sim's only caller, combat.lisp, passes singles)
pub fn hit_px(k: &Knobs, charge: f32, sub_frac: f32, dmg_mult: f32, sp_scale: f32) -> f32 {
    charge * (1.0 + k.sub_dmg * sub_frac) * dmg_mult * sp_scale
}

// port: rules.lisp CORNERED-MULT
pub fn cornered_mult(per: f32, lost: i64, cap: f32) -> f32 {
    1.0 + min_f32(cap, per * lost as f32)
}

/// HIT-DAMAGE's ATK-MODS plist (:mult :cornered :lost :cornered-max; GETF defaults 1.0 0.0 0 0.0).
#[derive(Debug, Clone, Copy)]
pub struct AtkMods {
    pub mult: f32,
    pub cornered: f32,
    pub lost: i64,
    pub cornered_max: f32,
}
impl Default for AtkMods {
    fn default() -> Self {
        AtkMods { mult: 1.0, cornered: 0.0, lost: 0, cornered_max: 0.0 }
    }
}

/// The DEF-MODS plist (:mult, default 1.0).
#[derive(Debug, Clone, Copy)]
pub struct DefMods {
    pub mult: f32,
}
impl Default for DefMods {
    fn default() -> Self {
        DefMods { mult: 1.0 }
    }
}

// port: rules.lisp HIT-DAMAGE — the product left to right in f32, banker's ROUND
pub fn hit_damage(k: &Knobs, base: i64, atk: AtkMods, def: DefMods, combo_index: i64, counter_hit: bool, orange: bool) -> i64 {
    if base <= 0 {
        return 0;
    }
    let x = base as f32 * atk.mult * cornered_mult(atk.cornered, atk.lost, atk.cornered_max) * def.mult * combo_scale(k, combo_index, orange)
        * if counter_hit { k.counter_mult } else { 1.0 };
    1.max(round_f32(x))
}

// port: rules.lisp CHIP-DAMAGE (RATE `None` = NIL)
pub fn chip_damage(dmg: i64, rate: Option<f32>, reishi: i64) -> i64 {
    match rate {
        Some(r) if r > 0.0 => 0.max(round_f32(dmg as f32 * r).min(reishi - 1)),
        _ => 0,
    }
}

// port: rules.lisp BURN-AMOUNT — PER-SECOND is a fixnum after ROUND, so both FLOORs are integer
pub fn burn_amount(max_reishi: i64, fraction_per_second: f32, step: i64) -> i64 {
    let per_second = round_f32(max_reishi as f32 * fraction_per_second);
    floor_div(per_second * (step + 1), 60) - floor_div(per_second * step, 60)
}

// port: rules.lisp BURN
pub fn burn(reishi: i64, amount: i64) -> i64 {
    if reishi <= 1 { reishi } else { 1.max(reishi - amount) }
}

// port: rules.lisp RED-P (the fixnum / single path)
pub fn red_p(k: &Knobs, reishi: i64, max_reishi: i64) -> bool {
    (reishi as f32) < max_reishi as f32 * k.red_threshold
}

/// KIKON-OUTCOME's results.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum KikonOutcome {
    Kikon,
    Follow,
}

// port: rules.lisp KIKON-OUTCOME (CONTACT: a RESOLVE-CONTACT result)
pub fn kikon_outcome(held: bool, contact: Option<Res>, follow: bool) -> Option<KikonOutcome> {
    if !matches!(contact, Some(Res::Hit | Res::Counter)) {
        return None;
    }
    if follow {
        Some(KikonOutcome::Kikon)
    } else if held {
        Some(KikonOutcome::Follow)
    } else {
        None
    }
}

// port: rules.lisp KIKON-FOLLOW-UNGUARDABLE-P
pub fn kikon_follow_unguardable_p(red: bool) -> bool {
    red
}

// port: rules.lisp KIKON-FOLLOW-WAIT
pub fn kikon_follow_wait(k: &Knobs, s: i64) -> i64 {
    0.max(k.kikon_follow_stun + 1 + k.kikon_follow_gap - s)
}

// port: rules.lisp KIKON-FOLLOW-STUN (RED ignored)
pub fn kikon_follow_stun(k: &Knobs, _red: bool, s: i64) -> i64 {
    kikon_follow_wait(k, s) + s + 2
}

// port: rules.lisp KIKON-LOCK-P
#[allow(clippy::too_many_arguments)]
pub fn kikon_lock_p(state: crate::components::State, follow: bool, phase: Option<Phase>, contact: Option<Contact>, sf: i64, s: i64, a: i64) -> bool {
    state == crate::components::State::Move
        && follow
        && (phase == Some(Phase::Follow) || (phase == Some(Phase::Main) && contact.is_none() && sf < s + a))
}

// port: rules.lisp KIKON-FOLLOW-SPEED
pub fn kikon_follow_speed(k: &Knobs, dist: f32, frames_left: i64, cap: f32) -> f32 {
    if dist <= k.kikon_trigger { 0.0 } else { min_f32(cap, 60.0 * ((dist - k.kikon_trigger) / 1.max(frames_left) as f32)) }
}

// port: rules.lisp SOUL-BREAK-P
pub fn soul_break_p(reishi: i64) -> bool {
    reishi <= 0
}

// port: rules.lisp KIKON-RESULT → (left, lost, out)
pub fn kikon_result(k: &Knobs, konpaku: i64, count: i64, soul_break: bool) -> (i64, i64, bool) {
    let cap = if soul_break { k.soul_break_max_event } else { k.kikon_max_event };
    let lost = konpaku.min(cap).min(count + if soul_break { k.soul_break_extra } else { 0 });
    let left = konpaku - lost;
    (left, lost, left <= 0)
}

// port: rules.lisp TIME-UP-WINNER → Some(0 / 1), None = :DRAW
pub fn time_up_winner(konpaku_0: i64, reishi_0: i64, max_0: i64, konpaku_1: i64, reishi_1: i64, max_1: i64) -> Option<i64> {
    if konpaku_0 > konpaku_1 {
        Some(0)
    } else if konpaku_0 < konpaku_1 {
        Some(1)
    } else if reishi_0 * max_1 > reishi_1 * max_0 {
        Some(0)
    } else if reishi_0 * max_1 < reishi_1 * max_0 {
        Some(1)
    } else {
        None
    }
}

// port: rules.lisp MATCH-ELAPSED
pub fn match_elapsed(left: i64, total: i64) -> f32 {
    max_f32(0.0, min_f32(1.0, 1.0 - left as f32 / 1.max(total) as f32))
}

// port: rules.lisp GAUGE-ADD (the single-float path)
pub fn gauge_add(g: f32, n: f32, max: f32) -> f32 {
    let s = g + n;
    if s.is_nan() || max <= s {
        if max.is_nan() || 0.0 >= max { 0.0 } else { max }
    } else if 0.0 >= s {
        0.0
    } else {
        s
    }
}

// port: rules.lisp COMBO-GAIN-MULT
pub fn combo_gain_mult(k: &Knobs, n: i64) -> f32 {
    min_f32(k.combo_gain_max, 1.0 + k.combo_gain_step * (1.max(n) - 1) as f32)
}

// port: rules.lisp AWAKENING-GAIN (DEALT / TAKEN / LOST fixnums)
pub fn awakening_gain(k: &Knobs, dealt: i64, taken: i64, lost: i64) -> f32 {
    dealt as f32 * k.awaken_dealt + taken as f32 * k.awaken_taken + lost as f32 * k.awaken_per_konpaku
}

// port: rules.lisp HIT-GAINS → (fs, awaken, siphon); MULT default 1.0, N default 1
pub fn hit_gains(k: &Knobs, dealt: i64, taken: i64, siphoned: bool, mult: f32, n: i64) -> (f32, f32, f32) {
    let fs = combo_gain_mult(k, n) * taken as f32 * k.fs_taken;
    if siphoned { (0.0, 0.0, fs) } else { (fs, mult * awakening_gain(k, dealt, 0, 0) + awakening_gain(k, 0, taken, 0), 0.0) }
}

// port: rules.lisp SECONDS->FRAMES (S a single)
pub fn seconds_to_frames(s: f32) -> i64 {
    round_f32(s * 60.0)
}

// port: rules.lisp PLAY-TICKS
pub fn play_ticks(match_seconds: i64, frames_left: i64) -> i64 {
    60 * match_seconds - 0.max(frames_left)
}

// port: rules.lisp TIMER-FILL
pub fn timer_fill(frames_left: i64, total_frames: i64, max: f32) -> f32 {
    if total_frames <= 0 { 0.0 } else { max * (frames_left as f32 / total_frames as f32) }
}

// port: rules.lisp SUB-FRAC
pub fn sub_frac(k: &Knobs, awakened: bool, sub: f32, sub_s: f32, drive: f32) -> f32 {
    if awakened { k.sub_keep * sub_s + k.drive_add * (drive / k.drive_max) } else { sub / k.sub_max }
}

// port: rules.lisp AWAKEN-OVERFLOW → (aw, sub, drive)
pub fn awaken_overflow(k: &Knobs, awakened: bool, aw: f32, sub: f32, drive: f32, x: f32, xs: f32) -> (f32, f32, f32) {
    if awakened {
        (aw, sub, gauge_add(drive, xs * k.sub_gain, k.drive_max))
    } else if aw >= k.awaken_max {
        (aw, gauge_add(sub, xs * k.sub_gain, k.sub_max), drive)
    } else {
        (min_f32(k.awaken_max, aw + x), sub, drive)
    }
}

// port: rules.lisp SUB-ATTACK-GAIN
pub fn sub_attack_gain(k: &Knobs, dealt: i64, lost: i64, mult: f32) -> f32 {
    dealt as f32 * k.awaken_dealt * k.sub_attack_mult * mult + lost as f32 * k.awaken_per_konpaku
}

// port: rules.lisp SUB-TAKEN-MODS
pub fn sub_taken_mods(k: &Knobs, dmods: DefMods, frac: f32) -> DefMods {
    if frac == 0.0 { dmods } else { DefMods { mult: dmods.mult * (1.0 - k.sub_taken * frac) } }
}

// port: rules.lisp HOHO-ALLOWED-P (NEED default *fs-hoho*)
pub fn hoho_allowed_p(stunned: bool, fs: f32, lockout_left: i64, bursting: Option<Burst>, need: f32) -> bool {
    !stunned && if bursting.is_some() { fs > 0.0 } else { fs >= need } && lockout_left <= 0
}

// port: rules.lisp HOHO-COST (BURN default *fs-max*)
pub fn hoho_cost(k: &Knobs, fs: f32, bursting: Option<Burst>, burn: f32) -> f32 {
    match bursting {
        Some(Burst::Blue) => min_f32(fs, burn),
        Some(_) => min_f32(fs, k.fs_hoho),
        None => k.fs_hoho,
    }
}

// port: rules.lisp AWAKEN-ALLOWED-P
pub fn awaken_allowed_p(k: &Knobs, free: bool, gauge: f32, used: bool) -> bool {
    free && !used && gauge >= k.awaken_max
}

// port: rules.lisp AWAKEN-STATE-OK-P
pub fn awaken_state_ok_p(state: crate::components::State, locked: bool, cine: bool) -> bool {
    use crate::components::State::*;
    !locked && !cine && matches!(state, Idle | Guard | GuardHit | Stun | Air | Down | Wakeup | Move | Step | Run)
}

// port: rules.lisp BURST-MODE
pub fn burst_mode(k: &Knobs, state: crate::components::State, locked: bool, combo_hits: i64, chain_open: bool) -> Option<Burst> {
    use crate::components::State::*;
    if locked {
        return None;
    }
    match state {
        Stun | Air => (combo_hits >= k.burst_min_hits).then_some(Burst::Blue),
        GuardHit => Some(Burst::Blue),
        Move => chain_open.then_some(Burst::Orange),
        Idle | Guard | Run => Some(Burst::White),
        _ => None,
    }
}

// port: rules.lisp BURST-ALLOWED-P
pub fn burst_allowed_p(k: &Knobs, mode: Option<Burst>, fs: f32, active: bool) -> bool {
    mode.is_some() && !active && fs >= k.fs_burst
}

// port: rules.lisp BURST-DRAIN
pub fn burst_drain(k: &Knobs, fs: f32) -> f32 {
    max_f32(0.0, fs - k.burst_drain / 60.0)
}

// port: rules.lisp BURST-BUDGET
pub fn burst_budget(k: &Knobs, mode: Option<Burst>) -> f32 {
    if mode == Some(Burst::Blue) { k.blue_burn } else { k.fs_max }
}

// port: rules.lisp BURST-BURN → (fs, burn)
pub fn burst_burn(k: &Knobs, fs: f32, burn: f32) -> (f32, f32) {
    let d = min_f32(min_f32(k.burst_drain / 60.0, burn), fs);
    (max_f32(0.0, fs - d), max_f32(0.0, burn - d))
}

// port: rules.lisp BURST-FS-GAIN
pub fn burst_fs_gain(gain: f32, mode: Option<Burst>) -> f32 {
    if mode.is_some() { 0.0 } else { gain }
}

// port: rules.lisp FS-GAIN
pub fn fs_gain(k: &Knobs, gain: f32, mode: Option<Burst>, sub: f32) -> f32 {
    burst_fs_gain(gain, mode) * (1.0 + k.sub_fs * sub)
}

// port: rules.lisp BURST-HEAL — RATE a single: (floor single 60) is an f32 divide then a floor
pub fn burst_heal(n: i64, rate: f32) -> i64 {
    floor_f32(n as f32 * rate / 60.0) - floor_f32((n - 1) as f32 * rate / 60.0)
}

// port: rules.lisp BURST-GAIN-MULT
pub fn burst_gain_mult(k: &Knobs, mode: Option<Burst>) -> f32 {
    if mode == Some(Burst::Orange) { k.orange_gain } else { 1.0 }
}

// port: rules.lisp CHAIN-STARTUP-CUT
pub fn chain_startup_cut(k: &Knobs, s: i64, enter: i64) -> i64 {
    0.max(floor_f32(k.chain_cut * (s - enter) as f32).min(s - enter - 1))
}

// port: rules.lisp FS-REGEN (RATE default *fs-regen*; the single-float path)
pub fn fs_regen(k: &Knobs, fs: f32, idle: i64, rate: f32) -> f32 {
    let mx = k.fs_cell;
    if idle >= k.fs_delay && fs < mx {
        let s = fs + rate / 60.0;
        if s.is_nan() || mx <= s { mx } else { s }
    } else {
        fs
    }
}

// port: rules.lisp GUARD-VALUE (KIND the move kind name, None = a hazard; ADV None when not an integer; OVERRIDE None = NIL)
pub fn guard_value(k: &Knobs, kind: Option<&str>, adv: Option<i64>, override_: Option<i64>) -> i64 {
    if let Some(o) = override_ {
        return o;
    }
    match kind {
        Some(kind) => {
            k.gg_kind.get(kind, 0)
                + if matches!(kind, "quick" | "flash" | "sig") && adv.is_some_and(|a| a <= k.gg_ender_adv) { k.gg_ender } else { 0 }
        }
        None => k.gg_hazard,
    }
}

// port: rules.lisp GG-DRAIN → (gg, broken)
pub fn gg_drain(gg: f32, v: i64) -> (f32, bool) {
    let n = max_f32(0.0, gg - v as f32);
    (n, n <= 0.0)
}

// port: rules.lisp GG-REGEN (BLUE, MULT default 1.0, CAP default *gg-max*; the single-float path)
#[allow(clippy::too_many_arguments)]
pub fn gg_regen(k: &Knobs, gg: f32, idle: i64, guardless: bool, guarding: bool, blue: bool, mult: f32, cap: f32) -> f32 {
    if !blue && (guarding || idle < k.gg_delay) {
        return gg;
    }
    let rate = (if guardless { k.gg_regen_guardless } else { mult * k.gg_regen }) / 60.0;
    let s = gg + if blue { rate * if guarding { k.blue_gg_guarding } else { k.blue_gg_mult } } else { rate };
    if s.is_nan() || cap <= s { cap } else { s }
}

// port: rules.lisp GG-IDLE-NEXT
pub fn gg_idle_next(idle: i64, guarding: bool) -> i64 {
    if guarding { idle } else { 9999.min(idle + 1) }
}

// port: rules.lisp CAN-GUARD-P
pub fn can_guard_p(gg: f32, guardless: bool) -> bool {
    gg > 0.0 && !guardless
}

// port: rules.lisp RANGED-HIT-P (RANGED: :ranged in the move's flags; MELEE-RANGE None = NIL)
pub fn ranged_hit_p(hazard: bool, ranged: bool, melee_range: Option<f32>, d2: f32) -> bool {
    hazard || (ranged && !melee_range.is_some_and(|m| d2 <= m * m))
}

// port: rules.lisp RANGED-WARD-P
pub fn ranged_ward_p(warding: bool, ranged: bool, def_state: DefState, can_guard: bool) -> bool {
    warding && ranged && can_guard && def_state != DefState::Invuln
}

// port: rules.lisp STANCE-STORE
pub fn stance_store(k: &Knobs, stored: i64, taken: i64) -> i64 {
    k.stance_store_cap.min(stored + round_f32(taken as f32 * k.stance_store_rate))
}

// port: rules.lisp STANCE-RELEASE → (damage, crush)
pub fn stance_release(k: &Knobs, stored: i64) -> (i64, bool) {
    (k.stance_base_damage + stored, stored >= k.stance_crush_at)
}

// port: rules.lisp COMBO-STEP → (react, hits, launches, air-hits)
pub fn combo_step(k: &Knobs, react: Phase, airborne: bool, hits: i64, launches: i64, air_hits: i64, keep_bind: bool) -> (Phase, i64, i64, i64) {
    let open = react == Phase::Bind && hits == 0;
    let bind = open || (keep_bind && react == Phase::Bind);
    let hits = if open { k.burst_min_hits } else { hits + 1 };
    let air_hits = if airborne { air_hits + 1 } else { air_hits };
    let react = if bind {
        Phase::Bind
    } else if react == Phase::Bind {
        Phase::Flinch
    } else if airborne && air_hits >= k.combo_air_hits {
        Phase::Knockdown
    } else if react == Phase::Launch && launches >= k.combo_launches {
        Phase::Knockback
    } else {
        react
    };
    (react, hits, if react == Phase::Launch { launches + 1 } else { launches }, air_hits)
}

// port: rules.lisp STUN-WEIGHT
pub fn stun_weight(k: &Knobs, react: &str, heavy: bool) -> i64 {
    k.stun_weights.get(react, 1).max(if heavy { k.stun_weights.get("heavy", 3) } else { 0 })
}

// port: rules.lisp STUN-ADD (STUN a single)
pub fn stun_add(k: &Knobs, stun: f32, react: &str, heavy: bool) -> f32 {
    stun + stun_weight(k, react, heavy) as f32
}

// port: rules.lisp STUN-DECAY (the single-float path)
pub fn stun_decay(k: &Knobs, stun: f32, idle: i64) -> f32 {
    if idle < k.stun_delay {
        return stun;
    }
    let x = stun - k.stun_decay / 60.0;
    if x.is_nan() || 0.0 >= x { 0.0 } else { x }
}

// port: rules.lisp STUN-OVER-P
pub fn stun_over_p(stun: f32, tolerance: f32) -> bool {
    stun > tolerance
}

// port: rules.lisp THREAT-WINDOW-P
pub fn threat_window_p(k: &Knobs, sf: i64, from: i64, to: i64) -> bool {
    sf < to && from - sf <= k.perfect_lead
}

// port: rules.lisp PERFECT-HOHO-P
#[allow(clippy::too_many_arguments)]
pub fn perfect_hoho_p(k: &Knobs, sf: i64, from: i64, to: i64, vols: &[crate::hitvol::Vol], ax: f32, ay: f32, az: f32, fx: f32, fz: f32, tx: f32, ty: f32, tz: f32, tr: f32, th: f32) -> bool {
    let (r, h) = (tr + k.perfect_inflate, th + k.perfect_inflate);
    threat_window_p(k, sf, from, to) && vols.iter().any(|v| crate::hitvol::vol_hit_p(v, ax, ay, az, fx, fz, tx, ty, tz, r, h, 0.0))
}

// port: rules.lisp STEAL-TAKE → (take, gain)
pub fn steal_take(k: &Knobs, want: f32, victim_fs: f32) -> (f32, f32) {
    let take = max_f32(0.0, min_f32(want, victim_fs));
    (take, take * k.steal_fs_gain)
}

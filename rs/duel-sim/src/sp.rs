//! port: duel/lisp/sp.lisp — SP spending on the flash-step gauge (DUEL_SP), pure functions of numbers.
use crate::components::State;
use crate::knobs::Knobs;
use duel_data::kits::MoveClass;

// port: sp.lisp SP-COST (MULT default 1.0; OVERRIDE `None` = NIL). DAMAGE is a fixnum or a single: f32 either way.
pub fn sp_cost(k: &Knobs, damage: f32, mult: f32, override_: Option<f32>) -> f32 {
    if let Some(o) = override_ {
        return o;
    }
    let r = 5.0f32 * crate::cl::floor_f32(damage * k.sp_cost_rate * mult / 5.0 + 0.5) as f32;
    crate::cl::max_f32(k.sp_cost_min, crate::cl::min_f32(k.sp_cost_max, r))
}

// port: sp.lisp SP-START-P
pub fn sp_start_p(cls: Option<MoveClass>, first: bool, fs: f32, bursting: bool) -> bool {
    cls == Some(MoveClass::As) || first || fs > 0.0 || bursting
}

// port: sp.lisp SP-PAY → (new-fs, paid)
pub fn sp_pay(fs: f32, cost: f32, bursting: bool) -> (f32, f32) {
    if bursting {
        (fs, 0.0)
    } else {
        let p = crate::cl::max_f32(0.0, crate::cl::min_f32(cost, fs));
        (fs - p, p)
    }
}

// port: sp.lisp SP-SCALE
pub fn sp_scale(paid: f32, cost: f32) -> f32 {
    if cost <= 0.0 { 1.0 } else { 0.5 + 0.5 * crate::cl::min_f32(1.0, paid / cost) }
}

// port: sp.lisp SP-REFUND
pub fn sp_refund(k: &Knobs, fs: f32, paid: f32) -> f32 {
    crate::cl::min_f32(k.fs_max, fs + paid)
}

// port: sp.lisp SP-ATK-GAIN (CLS `None` = NIL / :kikon / anything else)
pub fn sp_atk_gain(k: &Knobs, cls: Option<MoveClass>, cancel: bool) -> f32 {
    match cls {
        Some(MoveClass::Na) => if cancel { k.sp_gain_cancel } else { k.sp_gain_j },
        Some(MoveClass::Sa) => if cancel { k.sp_gain_cancel } else { k.sp_gain_sa },
        _ => 0.0,
    }
}

// port: sp.lisp SP-BREAK-TAKE → (take, gain)
pub fn sp_break_take(k: &Knobs, victim_fs: f32) -> (f32, f32) {
    let take = k.sp_break_share * crate::cl::max_f32(0.0, victim_fs - k.fs_cell);
    (take, k.sp_break_flat + take * k.sp_break_gain)
}

// port: sp.lisp SP-EXCHANGE-OPEN-P
pub fn sp_exchange_open_p(xch_a: i64, xch_b: i64) -> bool {
    xch_a >= 0 && xch_a == xch_b
}

// port: sp.lisp SP-RECANCEL-P
pub fn sp_recancel_p(xch_a: i64, xch_b: i64, tick: i64) -> bool {
    sp_exchange_open_p(xch_a, xch_b) && xch_a < tick
}

// port: sp.lisp SP-NEUTRAL-P
pub fn sp_neutral_p(state: State, sliding: bool) -> bool {
    use State::*;
    !matches!(state, Move | Stun | GuardHit | Air | Down | Wakeup) && !(state == Idle && sliding)
}

// port: sp.lisp SP-SWITCH-OK-P
pub fn sp_switch_ok_p(fs: f32, was_full: bool, switched: bool, routes: i64) -> bool {
    !switched && routes > 1 && was_full && fs > 0.0
}

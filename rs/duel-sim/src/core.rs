//! port: duel/lisp/core.lisp — the attack / SP triangle, pure functions (DUEL_CORE). A class NIL is `None`.
use crate::knobs::Knobs;
use duel_data::kits::MoveClass::{self, As, Na, Ns, Sa};

/// The triangle's verdict keywords (:HIT :CANCEL :ABSORB).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Verdict {
    Hit,
    Cancel,
    Absorb,
}
use Verdict::{Absorb, Cancel, Hit};

// port: core.lisp CORE-VERDICT (keys SIMUL ATT-T DEF-T)
pub fn core_verdict(att: Option<MoveClass>, def: Option<MoveClass>, simul: bool, att_t: Option<i64>, def_t: Option<i64>) -> Verdict {
    let (Some(att), Some(def)) = (att, def) else { return Hit };
    let tie = if simul { Cancel } else { Hit };
    match (att, def) {
        (Na, Na) => tie,
        (Na, Ns) | (Na, As) => Cancel,
        (Na, Sa) => Absorb,
        (Ns, Na) => Cancel,
        (Ns, Ns) => tie,
        (Ns, As) => Absorb,
        (Ns, Sa) => Cancel,
        (As, Na) => Cancel,
        (As, Ns) => Hit,
        (Sa, Na) => Hit,
        (Sa, Ns) => Cancel,
        (As | Sa, As | Sa) => core_later(att_t, def_t),
    }
}

// port: core.lisp CORE-TURN-ARMOR-VERDICT
pub fn core_turn_armor_verdict(verdict: Verdict, att: Option<MoveClass>, armored: bool) -> Verdict {
    if armored && att == Some(Na) && verdict == Cancel { Absorb } else { verdict }
}

// port: core.lisp CORE-LATER
pub fn core_later(att_t: Option<i64>, def_t: Option<i64>) -> Verdict {
    match (att_t, def_t) {
        (Some(a), Some(d)) if a != d => {
            if a > d {
                Hit
            } else {
                Absorb
            }
        }
        _ => Cancel,
    }
}

// port: core.lisp CORE-CANCEL-LAND-SF
pub fn core_cancel_land_sf(land_sf: i64, sf: i64, first_hit: i64) -> i64 {
    if land_sf >= 0 { land_sf } else { sf.max(first_hit) }
}

// port: core.lisp CORE-SEG-DEAD-P — moves compared by identity: the caller passes ids (`None` = NIL).
pub fn core_seg_dead_p<T: PartialEq>(mv: Option<T>, cls_t: i64, dead_mv: Option<T>, dead_t: i64) -> bool {
    dead_mv.is_some() && mv == dead_mv && cls_t == dead_t
}

// port: core.lisp CORE-CANCELLED-P — (>= xch cls-t 0)
pub fn core_cancelled_p(xch: i64, cls_t: i64) -> bool {
    xch >= cls_t && cls_t >= 0
}

// port: core.lisp CORE-SA-OPEN-P
pub fn core_sa_open_p(sf: i64, s: i64, a: i64, cancelled: bool) -> bool {
    cancelled || sf >= s + a
}

// port: core.lisp CORE-AS-SA-OUT-P
pub fn core_as_sa_out_p(on: bool, cls: Option<MoveClass>, cancelled: bool) -> bool {
    on && cls == Some(As) && cancelled
}

// port: core.lisp CORE-XCH-AS-P
pub fn core_xch_as_p(cls: Option<MoveClass>, old_cls: Option<MoveClass>, xch: i64, old_cls_t: i64, done: bool) -> bool {
    cls == Some(As)
        && !done
        && match old_cls {
            Some(Na) => core_cancelled_p(xch, old_cls_t),
            Some(Sa) => xch > old_cls_t && old_cls_t > -1,
            _ => false,
        }
}

// port: core.lisp CORE-HOHO-OPEN-P
pub fn core_hoho_open_p(xch: i64, done: bool) -> bool {
    xch < 0 || done
}

// port: core.lisp CORE-CLAMP-POINTER
pub fn core_clamp_pointer(k: &Knobs, n: i64) -> i64 {
    1.max(k.core_pointer_max.min(n))
}

// port: core.lisp CORE-AS-POINTER (BY-PRESS: a kit's :core :as-by-press, empty = NIL)
pub fn core_as_pointer(k: &Knobs, presses: i64, by_press: &[i64]) -> i64 {
    if by_press.is_empty() {
        core_clamp_pointer(k, presses)
    } else {
        by_press[(1.max((by_press.len() as i64).min(presses)) - 1) as usize]
    }
}

// port: core.lisp CORE-KIKON-COUNT
pub fn core_kikon_count(k: &Knobs, base: i64, pointer: i64, red: bool) -> i64 {
    match core_clamp_pointer(k, pointer) {
        1 | 3 => k.core_kikon_max.min(1.max(base - 1)),
        2 | 4 => {
            if red {
                k.core_soul_break_max.min(base + 1)
            } else {
                k.core_kikon_max.min(base)
            }
        }
        p => panic!("CORE-KIKON-COUNT: ecase fell through on pointer {p}"),
    }
}

// port: core.lisp CORE-SOUL-BREAK-COUNT
pub fn core_soul_break_count(k: &Knobs, base: i64, pointer: i64) -> i64 {
    k.core_soul_break_max.min(base + 1 + if core_clamp_pointer(k, pointer) == 3 { 2 } else { 0 })
}

// port: core.lisp CORE-KIKON-PTR
pub fn core_kikon_ptr(cls: Option<MoveClass>, sp_ptr: i64, ptr: i64) -> i64 {
    if matches!(cls, Some(Ns | As)) { sp_ptr } else { ptr }
}

// port: core.lisp CORE-KIKON-STAKE (FIXED: FIGHTER-KIKON-N, `None` = NIL)
#[allow(clippy::too_many_arguments)]
pub fn core_kikon_stake(k: &Knobs, konpaku: i64, base: i64, cls: Option<MoveClass>, sp_ptr: i64, ptr: i64, red: bool, fixed: Option<i64>) -> i64 {
    konpaku.min(fixed.unwrap_or_else(|| core_kikon_count(k, base, core_kikon_ptr(cls, sp_ptr, ptr), red)))
}

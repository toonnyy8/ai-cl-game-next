//! port: engine/lisp/time.lisp — hitstop, slow motion, the step clock.
use crate::cl::{max_f32, min_f32, round_f32};

/// +STEP+ = (/ 1f0 60f0).
pub const STEP: f32 = 1.0 / 60.0;
const SLOWMO_N: usize = 8;

#[derive(Clone, Debug, PartialEq)]
pub struct Time {
    /// Frames of global sim freeze left (`*hitstop*`).
    pub hitstop: i64,
    /// Fixed steps since start; advances during hitstop too (`*tick*`).
    pub tick: i64,
    /// Per slot: scale, real seconds left, who (0 everyone / 1 the others only).
    pub slowmo: [f32; 24],
    /// Real seconds not yet simulated (`*step-acc*`, a bare `0.0`: single).
    pub step_acc: f32,
    /// ponytail: `*hitstop-mult*` is an engine defparameter (1.0, not in tuning.json); kept here in case a tool rebinds it.
    pub hitstop_mult: f32,
}

impl Default for Time {
    fn default() -> Self {
        Time {
            hitstop: 0,
            tick: 0,
            slowmo: [0.0; 24],
            step_acc: 0.0,
            hitstop_mult: 1.0,
        }
    }
}

impl Time {
    /// port: hitstop. Concurrent requests take the max.
    pub fn hitstop(&mut self, frames: f32) {
        let f = round_f32(frames * self.hitstop_mult);
        if f > self.hitstop {
            self.hitstop = f;
        }
    }

    /// port: slowmo. Replaces the slot with the least time left (the first such).
    pub fn slowmo(&mut self, scale: f32, secs: f32, others: bool) {
        let (mut best, mut bl) = (0, f32::MAX);
        for i in 0..SLOWMO_N {
            let left = self.slowmo[i * 3 + 1];
            if left < bl {
                bl = left;
                best = i;
            }
        }
        self.slowmo[best * 3] = scale;
        self.slowmo[best * 3 + 1] = secs;
        self.slowmo[best * 3 + 2] = if others { 1.0 } else { 0.0 };
    }

    /// port: slowmo-scale. The lowest active scale; eases to 1 over the last 0.1 s.
    pub fn slowmo_scale(&self, others: bool) -> f32 {
        let mut sc = 1.0f32;
        for i in 0..SLOWMO_N {
            let o = i * 3;
            let left = self.slowmo[o + 1];
            if left > 0.0 && (others || self.slowmo[o + 2] < 0.5) {
                let k = self.slowmo[o];
                let e = if left < 0.1 {
                    k + (1.0 - k) * (1.0 - left * 10.0)
                } else {
                    k
                };
                sc = min_f32(sc, e);
            }
        }
        sc
    }

    /// port: time-reset (`tick` keeps counting).
    pub fn reset(&mut self) {
        self.hitstop = 0;
        self.slowmo = [0.0; 24];
    }

    /// port: time-step. True when the sim runs this step.
    pub fn step(&mut self) -> bool {
        self.tick += 1;
        for i in 0..SLOWMO_N {
            let o = i * 3 + 1;
            self.slowmo[o] = max_f32(0.0, self.slowmo[o] - STEP);
        }
        if self.hitstop > 0 {
            self.hitstop -= 1;
            false
        } else {
            true
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn hitstop_takes_max() {
        let mut t = Time::default();
        t.hitstop(8.0);
        t.hitstop(5.0);
        assert_eq!(t.hitstop, 8);
        t.hitstop(12.5); // banker's: 12
        assert_eq!(t.hitstop, 12);
        t.hitstop(13.5); // 14
        assert_eq!(t.hitstop, 14);
        assert!(!t.step());
        assert_eq!((t.hitstop, t.tick), (13, 1));
        t.reset();
        assert!(t.step());
        assert_eq!(t.tick, 2);
    }

    #[test]
    fn slowmo_eases_last_tenth() {
        let mut t = Time::default();
        t.slowmo(0.25, 1.0, false);
        assert_eq!(t.slowmo_scale(false), 0.25);
        t.slowmo[1] = 0.05; // half of the last 0.1 s: k + (1-k)(1-0.5)
        assert_eq!(t.slowmo_scale(false), 0.25 + 0.75 * (1.0 - 0.05f32 * 10.0));
        t.slowmo(0.5, 2.0, true); // takes slot 1 (0 s left beats 0.05)
        assert_eq!(&t.slowmo[3..6], &[0.5, 2.0, 1.0]);
        assert_eq!(t.slowmo_scale(false), 0.25 + 0.75 * (1.0 - 0.05f32 * 10.0)); // the others' slot is not the main side's
        assert_eq!(t.slowmo_scale(true), 0.5);
        for _ in 0..3 {
            t.step();
        }
        assert_eq!(t.slowmo[1], 0.0); // floored at 0
        assert_eq!(t.slowmo[4], 2.0 - STEP - STEP - STEP);
    }
}

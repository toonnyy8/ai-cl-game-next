//! The sim stream SIM-RND01: xorshift32 in C (engine/c/engine.h rng2_float, engine/c/rng.c rng_seed), one per match.

/// port: engine/c/rng.c rng2_state (the generator word, never 0).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct SimRng {
    pub state: u32,
}

impl Default for SimRng {
    /// port: engine/c/rng.c `unsigned rng2_state = 0x6A09E667u`.
    fn default() -> Self {
        SimRng { state: 0x6A09_E667 }
    }
}

impl SimRng {
    /// port: engine/lisp/package.lisp SIM-RND-SEED → rng.c rng_seed: murmur3's fmix32 of the seed as a C int, 0 → 0x9E3779B9.
    pub fn seed(&mut self, seed: i64) {
        let mut x = seed as i32 as u32;
        x ^= x >> 16;
        x = x.wrapping_mul(0x85EB_CA6B);
        x ^= x >> 13;
        x = x.wrapping_mul(0xC2B2_AE35);
        x ^= x >> 16;
        self.state = if x != 0 { x } else { 0x9E37_79B9 };
    }
    /// port: engine/lisp/package.lisp SIM-RND01 → engine.h rng2_float: uniform [0,1), the top 24 bits × 2^-24.
    pub fn rnd01(&mut self) -> f32 {
        let mut s = self.state;
        s ^= s << 13;
        s ^= s >> 17;
        s ^= s << 5;
        self.state = s;
        (s >> 8) as f32 * (1.0 / 16_777_216.0)
    }
    /// port: engine/lisp/package.lisp SIM-RND-STATE.
    pub fn state(&self) -> u32 {
        self.state
    }
    /// port: engine/lisp/package.lisp (SETF SIM-RND-STATE): 0 becomes 1.
    pub fn set_state(&mut self, s: u32) {
        self.state = if s != 0 { s } else { 1 };
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::cl::vectors::rows;

    #[test]
    fn rng_matches_c() {
        // the image: (sim-rnd-seed 1) (sim-rnd-state) (sim-rnd01) x3, tools/port/cl-vectors.lisp
        let mut r = SimRng::default();
        r.seed(1);
        assert_eq!(r.state(), 1364076727);
        assert_eq!(r.rnd01().to_bits(), 0x3DFA4688);
        assert_eq!(r.rnd01().to_bits(), 0x3F2B81DB);
        assert_eq!(r.rnd01().to_bits(), 0x3F0DDBF5);
        assert_eq!(r.state(), 2380002740);
    }

    #[test]
    fn rng_vectors() {
        for v in rows("rng-seed") {
            let mut r = SimRng::default();
            r.seed(v.args[0].i());
            assert_eq!(r.state() as i64, v.out[0].i());
            for t in &v.out[1..4] {
                assert_eq!(r.rnd01().to_bits(), t.s().to_bits());
            }
            assert_eq!(r.state() as i64, v.out[4].i());
        }
        let mut r = SimRng::default();
        r.set_state(0);
        assert_eq!(r.state() as i64, rows("rng-set-state")[0].out[0].i());
    }
}

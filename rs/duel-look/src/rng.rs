//! port: engine/engine.h rng_float, engine/c/rng.c — the cosmetic stream RND01 (fx, shake, sparks). Never the sim's stream and never
//! inside `Match`: the Lisp's C global is never restored by a rollout and never reseeded by the game, so it runs from boot.
use duel_sim::rng::SimRng;

/// The cosmetic generator (`rng_state`): the sim stream's xorshift32 and `>> 8` x 2^-24, its own state.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct CosRng(SimRng);

impl Default for CosRng {
    /// port: engine/c/rng.c `unsigned rng_state = 0x9E3779B9u` (the boot state every draw-key scene starts from).
    fn default() -> Self {
        let mut r = SimRng::default();
        r.set_state(0x9E37_79B9);
        CosRng(r)
    }
}

impl CosRng {
    /// port: engine/lisp/package.lisp RND-SEED → rng.c rng_seed (fmix32 of the seed as a C int; 0 → 0x9E3779B9).
    pub fn seed(&mut self, seed: u32) {
        self.0.seed(seed as i32 as i64);
    }
    /// port: RND01 → rng_float: uniform [0, 1), the top 24 bits x 2^-24.
    pub fn rnd01(&mut self) -> f32 {
        self.0.rnd01()
    }
    /// port: RND-STATE (the draw key records it per keyed frame).
    pub fn state(&self) -> u32 {
        self.0.state()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// rng_float from the boot state, by hand from engine.h: x ^= x << 13; x ^= x >> 17; x ^= x << 5.
    #[test]
    fn rng_float_from_boot() {
        let mut r = CosRng::default();
        assert_eq!(r.state(), 0x9E37_79B9);
        let mut x: u32 = 0x9E37_79B9;
        for _ in 0..3 {
            x ^= x << 13;
            x ^= x >> 17;
            x ^= x << 5;
            assert_eq!(r.rnd01().to_bits(), ((x >> 8) as f32 * (1.0f32 / 16_777_216.0)).to_bits());
            assert_eq!(r.state(), x);
        }
        r.seed(0);
        assert_eq!(r.state(), 0x9E37_79B9); // (fmix32(0) = 0 → the fallback)
    }
}

//! The deterministic sim (no Bevy): port of the Lisp core, fixed 60 Hz steps.
pub mod cl;
pub mod consts;
pub mod hitvol;
pub mod knobs;
pub mod math;
pub mod rng;
pub mod vpad;

pub const VERSION: &str = "0.0.0";

#[cfg(test)]
mod tests {
    #[test]
    fn sim_crate_builds() {
        assert_eq!(super::VERSION, "0.0.0");
    }
}

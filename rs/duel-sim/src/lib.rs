//! The deterministic sim (no Bevy): port of the Lisp core, fixed 60 Hz steps.
pub mod cl;
pub mod components;
pub mod consts;
pub mod control;
pub mod core;
pub mod sp;
pub mod ecs;
pub mod flow;
pub mod hashline;
pub mod hitvol;
pub mod kit;
pub mod knobs;
pub mod log;
pub mod math;
pub mod rng;
pub mod rules;
pub mod state;
pub mod time;
pub mod vpad;

/// A sim path not ported yet: records NAME in `m.unported` (the first one wins) and returns from the calling function
/// (with `Default::default()`, or the value given as a third argument).
#[macro_export]
macro_rules! unported {
    ($m:expr, $name:expr) => {
        $crate::unported!($m, $name, Default::default())
    };
    ($m:expr, $name:expr, $ret:expr) => {{
        if $m.unported.is_none() {
            $m.unported = Some($name);
        }
        return $ret;
    }};
}

/// port: CLOG — `clog!(m, "fmt", args…)` with `m: &mut Match` (an owned match: `clog!(&mut m, …)`); the arguments are not evaluated while the log is off.
#[macro_export]
macro_rules! clog {
    ($m:expr, $($arg:tt)*) => {
        if $m.log_on {
            // (formatted first: the arguments may read the match `$m` is the `&mut` of)
            let line = format!($($arg)*);
            $crate::log::clog($m, format_args!("{line}"));
        }
    };
}

pub const VERSION: &str = "0.0.0";

#[cfg(test)]
mod tests {
    #[test]
    fn sim_crate_builds() {
        assert_eq!(super::VERSION, "0.0.0");
    }

    fn first_unported_wins(m: &mut crate::state::Match, name: &'static str) -> i64 {
        crate::unported!(m, name, 7)
    }

    #[test]
    fn unported_records_first_and_returns() {
        let mut m = crate::hashline::tests::new_match();
        assert_eq!(first_unported_wins(&mut m, "CPU-A"), 7);
        assert_eq!(first_unported_wins(&mut m, "CPU-B"), 7);
        assert_eq!(m.unported, Some("CPU-A"));
    }
}

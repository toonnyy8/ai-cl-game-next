//! port: components.lisp CLOG — the combat log line `[tick] …` (prefix `"[~6d] "`) while `*combat-log*` is on.
//! Call through `clog!(m, "…", args)`, which, as the Lisp macro, evaluates nothing when the log is off.
use crate::state::Match;
use std::fmt::{self, Write};

pub fn clog(m: &mut Match, args: fmt::Arguments) {
    if m.log_on {
        let mut s = format!("[{:6}] ", m.match_tick);
        s.write_fmt(args).unwrap();
        m.log.push(s);
    }
}

#[cfg(test)]
mod tests {
    use crate::state::Match;

    fn f(m: &mut Match) {
        crate::clog!(m, "P1 form {} t {}", m.flow, m.timer);
    }

    #[test]
    fn clog_prefix_is_six_wide() {
        let mut m = crate::hashline::tests::new_match();
        f(&mut m);
        assert!(m.log.is_empty());
        m.log_on = true;
        m.match_tick = 10529;
        m.timer = 7;
        f(&mut m);
        assert_eq!(m.log, ["[ 10529] P1 form TITLE t 7"]);
    }
}

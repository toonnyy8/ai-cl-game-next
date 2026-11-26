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
    #[test]
    fn clog_prefix_is_six_wide() {
        let mut m = crate::hashline::tests::new_match();
        crate::clog!(m, "P1 move {}", "IC-J1");
        assert!(m.log.is_empty());
        m.log_on = true;
        m.match_tick = 10529;
        crate::clog!(m, "P1 form {}", "BASE");
        assert_eq!(m.log, ["[ 10529] P1 form BASE"]);
    }
}

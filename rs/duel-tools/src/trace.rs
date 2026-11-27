//! The oracle trace (tools/port/oracle/trace.lisp's header is the grammar): a streaming parser. Traces reach ~1 GB, so
//! `Reader` yields one item at a time; `read` collects them (tests, small traces).
use std::io::{BufRead, BufReader};

/// One `T` line: tick, per side (vpad tick, nine buttons, stick), the sim stream state.
#[derive(Debug, Clone, PartialEq)]
pub struct TLine {
    pub tick: i64,
    pub vt: [i64; 2],
    pub downs: [u16; 2],
    pub stick: [(f32, f32); 2],
    pub rnd: u32,
}

#[derive(Debug, Clone, PartialEq)]
pub enum Item {
    /// A step's record: its sim log lines (`[`; `C` lines dropped), T, H (the text after `H `), B (after `B `, `=` expanded).
    Step { log: Vec<String>, t: TLine, h: String, b: String },
    /// An `E` line (its words after `E`) and the `e` lines that follow it.
    Event { words: Vec<String>, e_lines: Vec<String> },
    /// `F`: run one frame.
    Frame,
}

#[derive(Debug, Default)]
pub struct Trace {
    pub start: Vec<String>,
    pub b_fields: Vec<String>,
    pub items: Vec<Item>,
}

const E_ACTIONS: &[&str] = &[
    "set", "battle", "form", "hisagi-reset", "place", "vpad-clear", "clear-hazards", "skip-cine", "burst-end",
    "full-gauges", "cmd", "core-start",
];

pub fn parse_t(s: &str) -> Result<TLine, String> {
    let w: Vec<&str> = s.split(' ').filter(|x| !x.is_empty()).collect();
    if w.len() != 10 {
        return Err(format!("T line has {} fields, want 10", w.len()));
    }
    let int = |x: &str| x.parse::<i64>().map_err(|e| format!("T {x}: {e}"));
    let hex = |x: &str| u32::from_str_radix(x, 16).map_err(|e| format!("T {x}: {e}"));
    let fl = |x: &str| x.parse::<f32>().map_err(|e| format!("T {x}: {e}"));
    Ok(TLine {
        tick: int(w[0])?,
        vt: [int(w[1])?, int(w[5])?],
        downs: [hex(w[2])? as u16, hex(w[6])? as u16],
        stick: [(fl(w[3])?, fl(w[4])?), (fl(w[7])?, fl(w[8])?)],
        rnd: hex(w[9])?,
    })
}

/// The streaming parser: `start()` reads the header up to the `S` line, then iterate items.
pub struct Reader<R: BufRead> {
    lines: std::iter::Peekable<std::io::Lines<R>>,
    pub line_no: usize,
    last_b: String,
}

impl<R: BufRead> Reader<R> {
    pub fn new(r: R) -> Self {
        Reader { lines: r.lines().peekable(), line_no: 0, last_b: String::new() }
    }

    fn next_line(&mut self) -> Option<Result<String, String>> {
        let l = self.lines.next()?;
        self.line_no += 1;
        Some(l.map_err(|e| e.to_string()))
    }

    /// The header: returns (`S` words, B field names).
    pub fn start(&mut self) -> Result<(Vec<String>, Vec<String>), String> {
        let mut fields = Vec::new();
        while let Some(l) = self.next_line() {
            let l = l?;
            if let Some(f) = l.strip_prefix("# B fields: ") {
                fields = f.split(' ').map(String::from).collect();
            } else if let Some(s) = l.strip_prefix("S ") {
                return Ok((s.split(' ').map(String::from).collect(), fields));
            } else if !l.starts_with('#') {
                return Err(format!("line {}: before the S line: {l}", self.line_no));
            }
        }
        Err("truncated trace: no S line".into())
    }

    fn err<T>(&self, msg: impl std::fmt::Display) -> Option<Result<T, String>> {
        Some(Err(format!("line {}: {msg}", self.line_no)))
    }
}

impl<R: BufRead> Iterator for Reader<R> {
    type Item = Result<Item, String>;
    fn next(&mut self) -> Option<Self::Item> {
        let mut log = Vec::new();
        let mut t = None;
        let mut h = None;
        loop {
            let Some(l) = self.next_line() else {
                return if log.is_empty() && t.is_none() { None } else { self.err("truncated trace: a step without its B line") };
            };
            let l = match l { Ok(l) => l, Err(e) => return Some(Err(e)) };
            let in_step = !log.is_empty() || t.is_some();
            match l.split_once(' ').map_or((l.as_str(), ""), |(a, b)| (a, b)) {
                // `A` (M2 Task 1, the CPU state after B) is skipped until the live replayer parses it (M2 Task 2).
                ("#", _) | ("R", _) | ("C", _) | ("A", _) => {}
                ("F", _) if !in_step => return Some(Ok(Item::Frame)),
                ("E", rest) if !in_step => {
                    let words: Vec<String> = rest.split(' ').map(String::from).collect();
                    if !E_ACTIONS.contains(&words[0].as_str()) {
                        return self.err(format!("unknown event: {l}"));
                    }
                    let mut e_lines = Vec::new();
                    while let Some(Ok(n)) = self.lines.peek() {
                        let Some(e) = n.strip_prefix("e ") else { break };
                        e_lines.push(e.to_string());
                        self.lines.next();
                        self.line_no += 1;
                    }
                    return Some(Ok(Item::Event { words, e_lines }));
                }
                ("T", rest) if t.is_none() => match parse_t(rest) {
                    Ok(x) => t = Some(x),
                    Err(e) => return self.err(e),
                },
                ("H", rest) if t.is_some() && h.is_none() => h = Some(rest.to_string()),
                ("B", rest) if h.is_some() => {
                    if rest != "=" {
                        self.last_b = rest.to_string();
                    } else if self.last_b.is_empty() {
                        return self.err("B = before any B line");
                    }
                    return Some(Ok(Item::Step { log, t: t.unwrap(), h: h.unwrap(), b: self.last_b.clone() }));
                }
                _ if l.starts_with('[') && t.is_none() => log.push(l),
                _ => return self.err(format!("unexpected line: {}", &l[..l.len().min(80)])),
            }
        }
    }
}

pub fn open(path: &str) -> Result<Reader<BufReader<std::fs::File>>, String> {
    let f = std::fs::File::open(path).map_err(|e| format!("{path}: {e}"))?;
    Ok(Reader::new(BufReader::with_capacity(1 << 20, f)))
}

pub fn read(path: &str) -> Result<Trace, String> {
    let mut r = open(path)?;
    let (start, b_fields) = r.start()?;
    let items = r.collect::<Result<_, _>>()?;
    Ok(Trace { start, b_fields, items })
}

/// port: TR-LOG-EQUAL — equal line for line, but a recorded line may end in " TRIAL" (a brain's why).
pub fn log_equal(want: &[String], got: &[String]) -> bool {
    want.len() == got.len()
        && want.iter().zip(got).all(|(w, g)| w == g || w.strip_prefix(g.as_str()) == Some(" TRIAL"))
}

#[cfg(test)]
pub(crate) fn parse_str(s: &str) -> Result<Trace, String> {
    let mut r = Reader::new(s.as_bytes());
    let (start, b_fields) = r.start()?;
    let items = r.collect::<Result<_, _>>()?;
    Ok(Trace { start, b_fields, items })
}

#[cfg(test)]
mod tests {
    use super::*;

    const FIX: &str = "# oracle trace v1\n# B fields: *timer* p1.x\nS trials f.lisp\nE set - *TIMER* 0\ne [     0] set\nR [     0] simf 0\nF\n[     1] P1 step\nC [     1] cpu why\nT 1 1 001 0.5 -0.0 1 000 0.0 0.0 514E28B7\nH duel hash t=1\nB 18000 3F800000\n";

    #[test]
    fn parses_all_line_kinds() {
        let t = parse_str(&format!("{FIX}T 2 2 000 0.0 0.0 2 000 0.0 0.0 00000001\nH duel hash t=2\nB =\n")).unwrap();
        assert_eq!(t.start, ["trials", "f.lisp"]);
        assert_eq!(t.b_fields, ["*timer*", "p1.x"]);
        assert_eq!(t.items.len(), 4);
        assert_eq!(t.items[0], Item::Event { words: vec!["set".into(), "-".into(), "*TIMER*".into(), "0".into()], e_lines: vec!["[     0] set".into()] });
        assert_eq!(t.items[1], Item::Frame);
        let Item::Step { log, t: tl, h, b } = &t.items[2] else { panic!() };
        assert_eq!(log, &["[     1] P1 step"]);
        assert_eq!((tl.tick, tl.vt, tl.downs, tl.stick[0], tl.rnd), (1, [1, 1], [1, 0], (0.5, -0.0), 0x514E28B7));
        assert!(tl.stick[0].1.is_sign_negative());
        assert_eq!((h.as_str(), b.as_str()), ("duel hash t=1", "18000 3F800000"));
        let Item::Step { b, .. } = &t.items[3] else { panic!() };
        assert_eq!(b, "18000 3F800000");
    }

    #[test]
    fn truncated_trace_is_an_error() {
        let cut = FIX.trim_end().rsplit_once('\n').unwrap().0;
        assert!(parse_str(cut).unwrap_err().contains("truncated"));
        assert!(parse_str("# x\n").unwrap_err().contains("truncated"));
    }

    #[test]
    fn unknown_event_is_an_error() {
        assert!(parse_str("S trials f\nE teleport 0\n").unwrap_err().contains("unknown event"));
    }

    #[test]
    fn log_equal_allows_trial_suffix() {
        let s = |v: &[&str]| v.iter().map(|x| x.to_string()).collect::<Vec<_>>();
        assert!(log_equal(&s(&["[ 1] P1 move J1 TRIAL"]), &s(&["[ 1] P1 move J1"])));
        assert!(!log_equal(&s(&["[ 1] P1 move J1 X"]), &s(&["[ 1] P1 move J1"])));
        assert!(!log_equal(&s(&["a"]), &s(&["a", "b"])));
    }
}

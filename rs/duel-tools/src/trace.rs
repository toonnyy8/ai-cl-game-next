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
    /// A step's record: its sim log lines (`[`), the CPUs' (`C`, without the `C `), T, H (the text after `H `), B (after `B `, `=`
    /// expanded), A (after `A `, `=` expanded; None in a trace from before M2).
    Step { log: Vec<String>, c: Vec<String>, t: TLine, h: String, b: String, a: Option<String> },
    /// An `E` line (its words after `E`) and the `e` lines that follow it.
    Event { words: Vec<String>, e_lines: Vec<String> },
    /// `F`: run one frame.
    Frame,
}

#[derive(Debug, Default)]
pub struct Trace {
    pub start: Vec<String>,
    pub b_fields: Vec<String>,
    pub a_fields: Vec<String>,
    pub items: Vec<Item>,
}

const E_ACTIONS: &[&str] = &[
    "set", "battle", "form", "hisagi-reset", "place", "vpad-clear", "clear-hazards", "skip-cine", "burst-end",
    "full-gauges", "cmd", "core-start", "vs-start",
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
    last_a: String,
    /// The header's `# A fields:` names (empty: a trace from before M2).
    pub a_fields: Vec<String>,
}

impl<R: BufRead> Reader<R> {
    pub fn new(r: R) -> Self {
        Reader { lines: r.lines().peekable(), line_no: 0, last_b: String::new(), last_a: String::new(), a_fields: Vec::new() }
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
            } else if let Some(f) = l.strip_prefix("# A fields: ") {
                self.a_fields = f.split(' ').map(String::from).collect();
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
        let mut c = Vec::new();
        let mut t = None;
        let mut h = None;
        loop {
            let Some(l) = self.next_line() else {
                return if log.is_empty() && c.is_empty() && t.is_none() { None } else { self.err("truncated trace: a step without its B line") };
            };
            let l = match l { Ok(l) => l, Err(e) => return Some(Err(e)) };
            let in_step = !log.is_empty() || !c.is_empty() || t.is_some();
            match l.split_once(' ').map_or((l.as_str(), ""), |(a, b)| (a, b)) {
                ("#", _) | ("R", _) => {}
                ("C", rest) if t.is_none() => c.push(rest.to_string()),
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
                    // (the step's A line follows its B line)
                    let a = match self.lines.peek() {
                        Some(Ok(n)) if n.starts_with("A ") => {
                            let n = self.lines.next().unwrap().unwrap();
                            self.line_no += 1;
                            if n != "A =" {
                                self.last_a = n[2..].to_string();
                            } else if self.last_a.is_empty() {
                                return self.err("A = before any A line");
                            }
                            Some(self.last_a.clone())
                        }
                        _ => None,
                    };
                    return Some(Ok(Item::Step { log, c, t: t.unwrap(), h: h.unwrap(), b: self.last_b.clone(), a }));
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
    let a_fields = r.a_fields.clone();
    let items = r.collect::<Result<_, _>>()?;
    Ok(Trace { start, b_fields, a_fields, items })
}

/// port: TR-LOG-EQUAL — equal line for line, but a recorded line may end in " TRIAL" (a brain's why).
pub fn log_equal(want: &[String], got: &[String]) -> bool {
    want.len() == got.len()
        && want.iter().zip(got).all(|(w, g)| w == g || w.strip_prefix(g.as_str()) == Some(" TRIAL"))
}

/// port: TR-A-DIFF — the first field where the A texts WANT and GOT (after `A `) differ, named through the header's NAMES (a job's
/// as `job<k>.<field>`, a strategy job's `stjob<k>.<field>`), or None if equal.
pub fn a_diff(names: &[String], want: &str, got: &str) -> Option<String> {
    let (w, g): (Vec<&str>, Vec<&str>) = (want.split(' ').collect(), got.split(' ').collect());
    let i = (0..w.len().max(g.len())).find(|&i| w.get(i) != g.get(i))?;
    let bar = |v: &[&str], from: usize| v.iter().skip(from).position(|x| *x == "|").map(|p| p + from);
    let (s1, w1) = (names.iter().position(|n| n == "|"), bar(&w, 0));
    let (s2, w2) = (s1.and_then(|s| names.iter().skip(s + 1).position(|n| n == "|").map(|p| p + s + 1)), w1.and_then(|b| bar(&w, b + 1)));
    let name = match (s1, s2, w1, w2) {
        (Some(s1), Some(s2), Some(w1), _) if i > w1 && w2.is_none_or(|w2| i <= w2) => {
            let nj = s2 - s1 - 1;
            format!("job{}.{}", (i - w1 - 1) / nj, names[s1 + 1 + (i - w1 - 1) % nj].trim_start_matches("job."))
        }
        (Some(_), Some(s2), Some(_), Some(w2)) if i > w2 => {
            let ns = names.len() - s2 - 1;
            format!("stjob{}.{}", (i - w2 - 1) / ns, names[s2 + 1 + (i - w2 - 1) % ns].trim_start_matches("stjob."))
        }
        _ => names.get(i).map_or("?", String::as_str).to_string(),
    };
    Some(format!("A field {name}: want {} got {}", w.get(i).unwrap_or(&"<none>"), g.get(i).unwrap_or(&"<none>")))
}

#[cfg(test)]
pub(crate) fn parse_str(s: &str) -> Result<Trace, String> {
    let mut r = Reader::new(s.as_bytes());
    let (start, b_fields) = r.start()?;
    let a_fields = r.a_fields.clone();
    let items = r.collect::<Result<_, _>>()?;
    Ok(Trace { start, b_fields, a_fields, items })
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
        let Item::Step { log, t: tl, h, b, .. } = &t.items[2] else { panic!() };
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

    /// M2's `A` line: the header's names, `A =` expanded, C lines kept; `a_diff` names a side's field and a job's (`job<k>.<f>`).
    #[test]
    fn a_line_parses_and_names_field() {
        let s = "# B fields: *timer*\n# A fields: *mc-plan*[0] p1.brain-strat p1.pilot-vpad-tick | job.side job.v1 | stjob.side stjob.n\nS cmds 1\n\
                 C [     1] cpu holds\nT 1 1 000 0.0 0.0 1 000 0.0 0.0 00000001\nH h\nB 1\nA 0 #s::T0-KI-ICHIGO 1 | |\n\
                 T 2 2 000 0.0 0.0 2 000 0.0 0.0 00000001\nH h\nB =\nA =\n";
        let t = parse_str(s).unwrap();
        assert_eq!(t.a_fields.len(), 9);
        let Item::Step { c, a, .. } = &t.items[0] else { panic!() };
        assert_eq!((c.as_slice(), a.as_deref()), (&["[     1] cpu holds".to_string()][..], Some("0 #s::T0-KI-ICHIGO 1 | |")));
        let Item::Step { a: a2, .. } = &t.items[1] else { panic!() };
        assert_eq!(a2, a);
        let n = &t.a_fields;
        assert_eq!(a_diff(n, "0 #s::T0-KI-ICHIGO 1 | |", "0 #s::T0-KI-ICHIGO 1 | |"), None);
        assert_eq!(a_diff(n, "0 #s::T0-KI-ICHIGO 1 | |", "0 NIL 1 | |").unwrap(), "A field p1.brain-strat: want #s::T0-KI-ICHIGO got NIL");
        assert_eq!(a_diff(n, "0 NIL 1 | 0 3F800000 1 3F800000 |", "0 NIL 1 | 0 3F800000 1 00000000 |").unwrap(), "A field job1.v1: want 3F800000 got 00000000");
        assert_eq!(a_diff(n, "0 NIL 1 | | 1 2", "0 NIL 1 | | 1 3").unwrap(), "A field stjob0.n: want 2 got 3");
        assert_eq!(a_diff(n, "0 NIL 1 | |", "0 NIL 1 | 0 3F800000 |").unwrap(), "A field job0.side: want | got 0");
        // (a pre-M2 trace: no A lines, no names)
        let Item::Step { a, .. } = &parse_str(FIX).unwrap().items[2] else { panic!() };
        assert_eq!(a, &None);
    }

    #[test]
    fn log_equal_allows_trial_suffix() {
        let s = |v: &[&str]| v.iter().map(|x| x.to_string()).collect::<Vec<_>>();
        assert!(log_equal(&s(&["[ 1] P1 move J1 TRIAL"]), &s(&["[ 1] P1 move J1"])));
        assert!(!log_equal(&s(&["[ 1] P1 move J1 X"]), &s(&["[ 1] P1 move J1"])));
        assert!(!log_equal(&s(&["a"]), &s(&["a", "b"])));
    }
}

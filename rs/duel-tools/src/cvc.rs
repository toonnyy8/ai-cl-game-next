//! `duel-tools cvc [--seed N] [--pairs ii,ik,kk] [--check FILE]`: G2's CPU-vs-CPU matches (tools/simgate.py --cvc, tests/style-gates.py
//! cvc) with both CPUs thinking: per pair, debug 2102 (turbo) then 3000 / 4000 / 5000 + SEED (START-CVC: II / IK / KK, seed 7 by
//! default), played to its end. Prints GO-RESULTS's RESULTS line and HASH-LOG's 600-tick hash lines, each after its pair's name:
//! build/oracle/cvc-tag.txt's format (MC-FULL-LOG's and STRAT-LOG's cost lines are not G2's: not printed, never compared).
//! `--check FILE`: those lines against FILE's lines of the same pairs (its `#` lines skipped); exit 1 on any difference.
use duel_sim::components::Flow;
use duel_sim::cpu::Search;
use duel_sim::flow::{self, PilotInput};
use duel_sim::hashline::state_hash_line;
use duel_sim::state::{Match, Winner};
use std::process::ExitCode;

const USAGE: &str = "usage: duel-tools cvc [--seed N] [--pairs ii,ik,kk] [--check FILE]";

/// HASH-LOG and GO-RESULTS's log lines of one match (no device: both seats are CPUs).
struct Lines {
    pair: &'static str,
    out: Vec<String>,
    results: bool,
}

impl PilotInput for Lines {
    fn read(&mut self, _m: &mut Match, _side: usize) {}
    fn rollout_read(&mut self, _m: &mut Match, _side: usize) {}
    /// `*step-hook*`'s place in SIM-STEP is HASH-LOG's; GO-RESULTS ran earlier in this step if the flow became RESULTS (its line: the
    /// tick and Konpaku are the step's last).
    fn step_end(&mut self, m: &mut Match, _s: &mut Search) {
        if m.flow == Flow::Battle && m.match_tick > 0 && m.match_tick % 600 == 0 {
            self.out.push(format!("{} {}", self.pair, state_hash_line(m)));
        }
        if m.flow == Flow::Results && !self.results {
            self.results = true;
            let k = |e| m.gauges.get(e).map_or(0, |g| g.konpaku);
            let w = match m.winner {
                Some(Winner::Side(0)) => "P1",
                Some(Winner::Side(_)) => "P2",
                _ => "DRAW",
            };
            self.out.push(format!(
                "{} duel -> RESULTS winner {w} konpaku {}-{} ticks {} secs {}",
                self.pair,
                k(m.p1),
                k(m.p2),
                m.match_tick,
                duel_sim::cl::fmt_fixed_f32(m.match_tick as f32 / 60.0, 1)
            ));
        }
    }
}

/// One pair's match (`ii` / `ik` / `kk`) at SEED: its lines, or the unported path that stopped it.
pub fn run_pair(data: &'static duel_data::Data, pair: &'static str, seed: i64) -> Result<Vec<String>, String> {
    let base = match pair {
        "ii" => 3000,
        "ik" => 4000,
        "kk" => 5000,
        _ => return Err(format!("no pair {pair}")),
    };
    let mut m = Match::new(data);
    flow::go_title(&mut m);
    m.cmds.extend([2102, base + seed]);
    let (s, mut l) = (&mut Search::new(), Lines { pair, out: vec![], results: false });
    for _ in 0..2_000_000 {
        let go = flow::frame_headless(&mut m, s, &mut l, &mut duel_sim::look::NoLook);
        m.log.clear();
        if !go {
            return Err(format!("{pair}: unported {}", m.unported.or(s.cut.map(|c| c.0)).unwrap_or("?")));
        }
        if m.gate.is_empty() && !m.gate_busy && m.gate_results.is_empty() && !flow::battle_p(&m) {
            return Ok(l.out);
        }
    }
    Err(format!("{pair}: no end after 2000000 frames"))
}

pub fn cvc_cmd(args: &[String]) -> ExitCode {
    let (mut seed, mut pairs, mut check) = (7, vec!["ii", "ik", "kk"], None);
    let mut it = args.iter();
    while let Some(k) = it.next() {
        let v = it.next();
        match (k.as_str(), v) {
            ("--seed", Some(v)) if v.parse::<i64>().is_ok_and(|n| (0..1000).contains(&n)) => seed = v.parse().unwrap(),
            ("--pairs", Some(v)) if v.split(',').all(|p| ["ii", "ik", "kk"].contains(&p)) => {
                pairs = ["ii", "ik", "kk"].into_iter().filter(|p| v.split(',').any(|x| x == *p)).collect()
            }
            ("--check", Some(v)) => check = Some(v.clone()),
            _ => {
                eprintln!("cvc: bad argument {k:?}{}\n{USAGE}", v.map_or(String::new(), |v| format!(" {v:?}")));
                return ExitCode::from(2);
            }
        }
    }
    let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
    let mut got = vec![];
    for p in &pairs {
        match run_pair(data, p, seed) {
            Ok(l) => got.extend(l),
            Err(e) => {
                println!("cvc: {e}");
                return ExitCode::from(3);
            }
        }
    }
    let Some(file) = check else {
        got.iter().for_each(|l| println!("{l}"));
        return ExitCode::SUCCESS;
    };
    let want: Vec<String> = match std::fs::read_to_string(&file) {
        Ok(t) => t.lines().filter(|l| !l.starts_with('#') && pairs.iter().any(|p| l.starts_with(&format!("{p} ")))).map(String::from).collect(),
        Err(e) => {
            println!("cvc: {file}: {e}");
            return ExitCode::FAILURE;
        }
    };
    match (0..want.len().max(got.len())).find(|&i| want.get(i) != got.get(i)) {
        None => {
            println!("cvc OK seed {seed} {}: {} lines equal to {file}", pairs.join(","), got.len());
            ExitCode::SUCCESS
        }
        Some(i) => {
            println!("cvc DIFFERS at line {} of {} (want {}):\n  want {:?}\n  got  {:?}", i + 1, got.len(), want.len(), want.get(i), got.get(i));
            ExitCode::FAILURE
        }
    }
}

#[cfg(test)]
mod tests {
    /// G2's three matches at seed 7 equal build/oracle/cvc-tag.txt line for line (the gate's step 1; skipped without the key).
    #[test]
    fn cvc_equals_the_tag() {
        let dir = std::env::var("ORACLE").unwrap_or_else(|_| concat!(env!("CARGO_MANIFEST_DIR"), "/../../build/oracle").into());
        let Ok(tag) = std::fs::read_to_string(format!("{dir}/cvc-tag.txt")) else {
            eprintln!("skipped: no {dir}/cvc-tag.txt (set ORACLE)");
            return;
        };
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        let mut got = vec![];
        for p in ["ii", "ik", "kk"] {
            got.extend(super::run_pair(data, p, 7).unwrap());
        }
        let want: Vec<&str> = tag.lines().filter(|l| !l.starts_with('#')).collect();
        assert_eq!(got, want);
    }
}

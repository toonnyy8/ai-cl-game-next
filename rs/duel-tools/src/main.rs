//! Port tools. `check-data [dir]`: load the data (from DIR, else the embedded copy), print the counts and the float checksum,
//! exit 1 unless both equal the manifest's. `replay <trace> [--max-steps N] [--data DIR]`: the brainless replay of an oracle
//! trace (exit 0 OK, 1 diverged / trace error, 3 unported).
#[allow(dead_code)] // ponytail: compare / Diverged / read wait for the frame loop (rest of Task 6)
mod replay;
#[allow(dead_code)]
mod trace;
use duel_data::{checksum, Data};
use std::process::ExitCode;

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    match args.first().map(String::as_str) {
        Some("check-data") => check_data(args.get(1)),
        Some("parse-trace") if args.len() > 1 => parse_trace(&args[1]),
        Some("replay") if args.len() > 1 => replay_cmd(&args[1..]),
        _ => {
            eprintln!("usage: duel-tools check-data [dir] | replay <trace> [--max-steps N] [--data DIR]");
            ExitCode::from(2)
        }
    }
}

fn check_data(dir: Option<&String>) -> ExitCode {
    let d = match dir {
        Some(p) => match Data::load(p.as_ref()) {
            Ok(d) => d,
            Err(e) => {
                eprintln!("load failed: {e}");
                return ExitCode::FAILURE;
            }
        },
        None => Data::embedded(),
    };
    let mut ok = true;
    for (f, n) in d.counts() {
        let want = d.manifest.counts.get(&f).copied();
        ok &= want == Some(n);
        println!("{f:<18} {n:>6}{}", if want == Some(n) { "" } else { "  MISMATCH manifest" });
    }
    let sum = format!("{:016x}", checksum::floats(&d));
    ok &= sum == d.manifest.float_checksum;
    println!("float_checksum {sum} manifest {}", d.manifest.float_checksum);
    println!("{}", if ok { "check-data PASS" } else { "check-data FAIL" });
    if ok { ExitCode::SUCCESS } else { ExitCode::FAILURE }
}

fn replay_cmd(args: &[String]) -> ExitCode {
    let opt = |k: &str| args.iter().position(|a| a == k).and_then(|i| args.get(i + 1));
    let max = opt("--max-steps").and_then(|s| s.parse().ok());
    let data = match opt("--data") {
        Some(p) => match Data::load(p.as_ref()) {
            Ok(d) => d,
            Err(e) => {
                println!("replay: data: {e}");
                return ExitCode::FAILURE;
            }
        },
        None => Data::embedded(),
    };
    match replay::run(&args[0], max, Box::leak(Box::new(data))) {
        replay::Outcome::Ok(n) => {
            println!("replay OK {n} ticks");
            ExitCode::SUCCESS
        }
        replay::Outcome::Diverged(s) => {
            println!("replay DIVERGED at {s}");
            ExitCode::FAILURE
        }
        replay::Outcome::Unported(s) => {
            println!("replay UNPORTED {s}");
            ExitCode::from(3)
        }
        replay::Outcome::Error(s) => {
            println!("replay: {s}");
            ExitCode::FAILURE
        }
    }
}

/// `parse-trace <trace>`: stream the whole trace through the parser, print the item counts (exit 1 on a trace error).
fn parse_trace(path: &str) -> ExitCode {
    let res = (|| {
        let mut r = trace::open(path)?;
        let (_, fields) = r.start()?;
        let (mut steps, mut events, mut frames) = (0u64, 0u64, 0u64);
        for it in r {
            match it? {
                trace::Item::Step { .. } => steps += 1,
                trace::Item::Event { .. } => events += 1,
                trace::Item::Frame => frames += 1,
            }
        }
        Ok::<_, String>(format!("{} B fields, {steps} steps, {events} events, {frames} frames", fields.len()))
    })();
    match res {
        Ok(s) => {
            println!("parse-trace OK {s}");
            ExitCode::SUCCESS
        }
        Err(e) => {
            println!("parse-trace: {e}");
            ExitCode::FAILURE
        }
    }
}

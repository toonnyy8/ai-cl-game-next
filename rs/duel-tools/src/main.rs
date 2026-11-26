//! Port tools. `check-data [dir]`: load the data (from DIR, else the embedded copy), print the counts and the float checksum,
//! exit 1 unless both equal the manifest's. `replay <trace> [--max-steps N] [--data DIR]`: the brainless replay of an oracle
//! trace (exit 0 OK, 1 diverged / trace error, 3 unported). `--stub a,b --mask x,y`: the stubbed mode (docs/bevy/M1_NOTES.md §3).
//! `--snap N`: a 40-step rollout every N battle ticks, restored from a clone (must stay OK; its summary line after the outcome).
//! `--bench`: a cmds trace's T lines read first, then the match timed on them alone, 11 runs (`steps <n> secs <s> steps/s <r>`, the
//! median; exit 1 unless every run's steps and last H equal the trace's).
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
            eprintln!("usage: duel-tools check-data [dir] | replay <trace> [--max-steps N] [--data DIR] [--stub S,..] [--mask F,..] [--snap N] [--bench]");
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
    let list = |k: &str| -> Vec<String> { opt(k).map_or(vec![], |s| s.split(',').filter(|x| !x.is_empty()).map(String::from).collect()) };
    let (stubs, mask) = (list("--stub"), list("--mask"));
    let snap = opt("--snap").and_then(|s| s.parse().ok());
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
    let data: &'static Data = Box::leak(Box::new(data));
    if args.iter().any(|a| a == "--bench") {
        return match replay::bench(&args[0], data, 11) {
            Ok((n, secs, same)) => {
                let med = secs[secs.len() / 2];
                println!(
                    "steps {n} secs {med:.4} steps/s {:.0} (median of {} runs; {:.0}-{:.0}){}",
                    n as f64 / med,
                    secs.len(),
                    n as f64 / secs[secs.len() - 1],
                    n as f64 / secs[0],
                    if same { "" } else { "  (NOT the trace's run)" }
                );
                if same { ExitCode::SUCCESS } else { ExitCode::FAILURE }
            }
            Err(e) => {
                println!("replay: {e}");
                ExitCode::FAILURE
            }
        };
    }
    let (out, snaps) = replay::run_snap(&args[0], max, data, &stubs, &mask, snap);
    // (the outcome line first: replay-gate.sh reads the first line)
    let code = match out {
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
    };
    if snap.is_some() {
        println!("snap: {} rollouts of 40 sim steps, {} reached an unported path", snaps.0, snaps.1);
    }
    code
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

/// The test binary's allocator: the system's, counting this thread's allocations (`replay::tests::bench_allocs`).
#[cfg(test)]
pub mod alloc_count {
    use std::alloc::{GlobalAlloc, Layout, System};
    use std::cell::Cell;
    thread_local! { static N: Cell<u64> = const { Cell::new(0) }; }
    pub struct Counting;
    unsafe impl GlobalAlloc for Counting {
        unsafe fn alloc(&self, l: Layout) -> *mut u8 {
            let _ = N.try_with(|n| n.set(n.get() + 1));
            unsafe { System.alloc(l) }
        }
        unsafe fn realloc(&self, p: *mut u8, l: Layout, size: usize) -> *mut u8 {
            let _ = N.try_with(|n| n.set(n.get() + 1));
            unsafe { System.realloc(p, l, size) }
        }
        unsafe fn dealloc(&self, p: *mut u8, l: Layout) {
            unsafe { System.dealloc(p, l) }
        }
    }
    #[global_allocator]
    static A: Counting = Counting;
    /// This thread's allocations so far.
    pub fn count() -> u64 {
        N.with(Cell::get)
    }
}

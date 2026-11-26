//! Port tools. `check-data [dir]`: load the data (from DIR, else the embedded copy), print the counts and the float checksum,
//! exit 1 unless both equal the manifest's.
use duel_data::{checksum, Data};
use std::process::ExitCode;

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    match args.first().map(String::as_str) {
        Some("check-data") => check_data(args.get(1)),
        _ => {
            eprintln!("usage: duel-tools check-data [dir]");
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

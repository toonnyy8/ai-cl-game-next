#!/usr/bin/env python3
"""M0a speed test (docs/bevy/plans/2026-11-26-m0a-speed-test.md, Task 5): the frozen build (A, the G3 scene 4003 + the perf log 2106)
against the Bevy replay page (B, and B with ?msaa=off), in turns A B B' A B B' A B B', 45 s real time each at 1280x720 (the G3
pattern of tests/style-gates.py perf). Prints one table: frame ms (mean of the perf windows after the first two), the worst window max,
startup (page to the `startup:` line), startup heap, index.wasm raw / gzip. The perf windows are A's 5 s (render.c r_timing) and B's
2 s. Exits 1 if any cell is missing or any run failed: a lost GPU device, a page exception, a nonzero run.mjs exit, or fewer perf
windows than 60 % of what its run time allows (the review of 2026-11-26 found B' quitting on DeviceLost unreported).
Usage: python3 tools/port/m0a-perf.py dist/duel dist/bevy-m0a"""
import gzip, os, re, statistics, subprocess, sys, json

TMP = "build/port/perf"
SECS = 45

def run(dist, query, log):
    script = f"{TMP}/a.json"
    json.dump([{"at": 9.0, "eval": "Module._debug_cmd(4003)"}, {"at": 9.1, "eval": "Module._debug_cmd(2106)"}], open(script, "w"))
    env = dict(os.environ, RUN_QUERY=query)
    args = ["node", "tools/run.mjs", dist, "--secs", str(SECS), "--size", "1280x720"] + (["--script", script] if not query and "duel" in dist else [])
    with open(log, "w") as f:
        rc = subprocess.run(["timeout", str(SECS + 90)] + args, stdout=f, stderr=subprocess.STDOUT, env=env).returncode
    t = open(log).read()
    period = 5.0 if re.search(r"render: SDL_GPU", t) else 2.0          # A's r_timing windows, B's own
    nwin = len(re.findall(r"perf: ", t))
    problems = [p for p, bad in (("DeviceLost", "DeviceLost" in t), ("exception", "EXCEPTION" in t), (f"run.mjs exit {rc}", rc != 0),
                                 (f"{nwin} perf windows", nwin < 0.6 * (SECS - 5) / period)) if bad]
    if problems: print(f"FAILED RUN {log}: {', '.join(problems)}")
    wins = [(float(a), float(b)) for a, b in re.findall(r"perf: .*?frame ([\d.]+) ms avg .*?max ([\d.]+)", t)][2:]
    heap = [float(x) for x in re.findall(r"startup: heap ([\d.]+) MB", t)]
    first = [float(x) * 1000 for x in re.findall(r"\[run\] startup done ([\d.]+) s", t)]
    return (statistics.mean(w[0] for w in wins) if wins else None, max((w[1] for w in wins), default=None),
            first[0] if first else None, heap[0] if heap else None, not problems)

def main():
    a, b = sys.argv[1], sys.argv[2]
    os.makedirs(TMP, exist_ok=True)
    sides = [("A frozen", a, ""), ("B Bevy MSAA 4x", b, ""), ("B' Bevy MSAA off", b, "?msaa=off")]
    res = {n: [] for n, _, _ in sides}
    for i in range(3):
        for n, d, q in sides:
            res[n].append(run(d, q, f"{TMP}/{n.split()[0].strip(chr(39))}{'p' if q else ''}-{i}.log"))
    ok = True
    print("| Side | frame ms (3 runs) | median | worst window max | startup ms | heap MB | wasm raw / gzip |")
    print("|---|---|---|---|---|---|---|")
    for n, d, q in sides:
        rs = res[n]
        cells = [x for r in rs for x in r[:4]]
        ok &= all(c is not None for c in cells) and all(r[4] for r in rs)
        w = os.path.join(d, "index.wasm"); raw = os.path.getsize(w); gz = len(gzip.compress(open(w, "rb").read(), 9))
        fm = [r[0] for r in rs if r[0] is not None]
        print(f"| {n} | {' '.join(f'{x:.1f}' for x in fm)} | {statistics.median(fm) if fm else float('nan'):.1f} | "
              f"{max((r[1] for r in rs if r[1] is not None), default=float('nan')):.1f} | "
              f"{statistics.median([r[2] for r in rs if r[2] is not None] or [float('nan')]):.0f} | "
              f"{max((r[3] for r in rs if r[3] is not None), default=float('nan')):.1f} | {raw:,} / {gz:,} |")
    print("ALL CELLS FOUND, NO FAILED RUN" if ok else "MISSING CELLS OR FAILED RUNS (see FAILED RUN lines)")
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()

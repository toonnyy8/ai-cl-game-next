#!/usr/bin/env python3
"""M0a speed test (docs/bevy/plans/2026-11-26-m0a-speed-test.md, Task 5): the frozen build (A, the G3 scene 4003 + the perf log 2106)
against the Bevy replay page (B, and B with ?msaa=off), in turns A B B' A B B' A B B', 45 s real time each at 1280x720 (the G3
pattern of tests/style-gates.py perf). Prints one table: frame ms (mean of the 2 s windows after the first two), the worst window max,
startup (page to the `startup:` line), startup heap, index.wasm raw / gzip. Exits 1 if any cell is missing.
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
        subprocess.run(["timeout", str(SECS + 90)] + args, stdout=f, stderr=subprocess.STDOUT, env=env)
    t = open(log).read()
    wins = [(float(a), float(b)) for a, b in re.findall(r"perf: .*?frame ([\d.]+) ms avg .*?max ([\d.]+)", t)][2:]
    heap = [float(x) for x in re.findall(r"startup: heap ([\d.]+) MB", t)]
    first = [float(x) * 1000 for x in re.findall(r"\[run\] startup done ([\d.]+) s", t)]
    return (statistics.mean(w[0] for w in wins) if wins else None, max((w[1] for w in wins), default=None),
            first[0] if first else None, heap[0] if heap else None)

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
        cells = [x for r in rs for x in r]
        ok &= all(c is not None for c in cells)
        w = os.path.join(d, "index.wasm"); raw = os.path.getsize(w); gz = len(gzip.compress(open(w, "rb").read(), 9))
        fm = [r[0] for r in rs if r[0] is not None]
        print(f"| {n} | {' '.join(f'{x:.1f}' for x in fm)} | {statistics.median(fm) if fm else float('nan'):.1f} | "
              f"{max((r[1] for r in rs if r[1] is not None), default=float('nan')):.1f} | "
              f"{statistics.median([r[2] for r in rs if r[2] is not None] or [float('nan')]):.0f} | "
              f"{max((r[3] for r in rs if r[3] is not None), default=float('nan')):.1f} | {raw:,} / {gz:,} |")
    print("ALL CELLS FOUND" if ok else "MISSING CELLS")
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()

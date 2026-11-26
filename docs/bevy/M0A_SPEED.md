# M0a speed test: the numbers

The Bevy port's go / no-go measurement (docs/bevy/BEVY_PORT.md §7 M0a; plan docs/bevy/plans/2026-11-26-m0a-speed-test.md).
Headless Chrome (SwiftShader WebGPU, `tools/run.mjs`, real time, 1280x720) on the lead's machine: only before / after comparisons
mean anything; the feel is judged on the user's Android + Chrome phone.

## Frozen build (A): `lisp-freeze` = 395fd0b6, v492 (2026-11-26)

Scene: debug 4003 (seeded CvC Ichigo vs Kenpachi, the G3 scene) + 2106 (the perf log); six 45 s runs
(`python3 tests/style-gates.py perf dist/duel dist/duel duel`).

| Measure | Value |
|---|---|
| Frame ms (mean per run, first two windows skipped) | 38.3 41.6 41.6 39.6 39.9 38.2, median **39.8** |
| Worst 2 s window max frame | 140.9 ms |
| Startup (page to first frame) | **3220 ms** (median) |
| Startup heap | 76.0 MB |
| Render | render-scale 1.00 (1280x720 scene px), pixel-lights 8, draws 121-145, tris about 18k |
| `index.wasm` | 11,899,490 B raw, 3,761,561 B gzip -9 |
